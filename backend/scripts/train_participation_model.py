"""
Training pipeline: Ridge regression predicting SA3 participation rate from
demographic inputs.

Uses the 2020-2024 AIHW window paired with the 2021 Census.
"""

import pandas as pd
from sklearn.linear_model import Ridge
from sklearn.model_selection import GridSearchCV, KFold
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sqlalchemy import select

from db.models import Sa3Linked
from db.session import SessionLocal

AIHW_YEAR_END = 2024  # the only window that overlaps the 2021 Census
N_FOLDS = 5

FEATURE_NAMES: list[str] = [
    'pct_born_overseas',
    'pct_other_language',
    'pct_low_proficiency',
]


def load_training_data(feature_names: list[str]) -> tuple[pd.DataFrame, pd.Series]:
    feature_columns = [getattr(Sa3Linked, name) for name in feature_names]

    with SessionLocal() as session:
        rows = session.execute(
            select(Sa3Linked.geo_code, Sa3Linked.rate_pct, *feature_columns).where(
                Sa3Linked.year_end == AIHW_YEAR_END,
                Sa3Linked.is_suppressed.is_(False),
                Sa3Linked.over_100.is_(False),
            )
        ).all()

    data = (
        pd.DataFrame(rows, columns=['geo_code', 'rate_pct', *feature_names])
        .set_index('geo_code')
        .dropna()
    )

    X = data[feature_names]
    y = data['rate_pct']
    return X, y


def normalise_features(X: pd.DataFrame) -> pd.DataFrame:
    """
    No normalisation needed for the current feature set: 
        pct_born_overseas, 
        pct_other_language
        pct_low_proficiency are already shares, computed by v_sa3_linked.
    Standardising them is handled inside the model pipeline(StandardScaler).
    """
    return X


def build_pipeline() -> Pipeline:
    """
    StandardScaler + Ridge Regressor
    """
    return Pipeline(
        [
            ('scale', StandardScaler()),
            ('ridge', Ridge()),
        ]
    )


def train_and_evaluate(X: pd.DataFrame, y: pd.Series) -> GridSearchCV:
    """
    K-fold cross-validated Ridge, searching over alpha (regularisation
    strength). GridSearchCV controls the alpha search and the fold
    splitting.
    """
    cv = KFold(n_splits=N_FOLDS, shuffle=True, random_state=42)
    search = GridSearchCV(
        build_pipeline(),
        param_grid={'ridge__alpha': [0.01, 0.1, 1.0, 10.0, 100.0]},
        cv=cv,
        scoring='r2',
    )
    search.fit(X, y)
    return search


def get_feature_weights(search: GridSearchCV, feature_names: list[str]) -> pd.Series:
    """
    Standardised Ridge coefficients, one per feature, sorted by magnitude.
    """
    ridge: Ridge = search.best_estimator_.named_steps['ridge']
    weights = pd.Series(ridge.coef_, index=feature_names)
    return weights.reindex(weights.abs().sort_values(ascending=False).index)


def main():
    X, y = load_training_data(FEATURE_NAMES)
    print(f'{len(X)} SA3 areas with complete data for {len(FEATURE_NAMES)} feature(s)')

    X = normalise_features(X)

    search = train_and_evaluate(X, y)
    print(f"best alpha: {search.best_params_['ridge__alpha']}")
    print(f'cross-validated R^2: {search.best_score_:.3f}')

    weights = get_feature_weights(search, FEATURE_NAMES)
    print('\nstandardised coefficients, by magnitude:')
    print(weights)


if __name__ == '__main__':
    main()
