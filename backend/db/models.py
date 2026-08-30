from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


class CervicalScreeningStat(Base):
    __tablename__ = "cervical_screening_participation"

    id: Mapped[int] = mapped_column(primary_key=True)
    state: Mapped[str] = mapped_column(index=True)
    reporting_period: Mapped[str] = mapped_column(index=True)
    age_group: Mapped[str]
    number: Mapped[int]
    crude_rate: Mapped[float]
    as_rate: Mapped[float | None]
