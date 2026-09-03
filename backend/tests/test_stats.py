from unittest.mock import MagicMock, patch

import pytest
from fastapi import HTTPException

from services import stats


def make_window(year_start, year_end, percent):
    return stats._Window(year_start, year_end, percent)


class TestParticipationPercentage:

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    def test_returns_latest_reporting_window(
        self, mock_totals, mock_session_local
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_totals.return_value = [
            make_window(2018, 2022, 72.1),
            make_window(2019, 2023, 71.5),
            make_window(2020, 2024, 70.8),
        ]

        result = stats.participation_percentage()

        assert result.percent == 70.8
        assert result.year_start == 2020
        assert result.year_end == 2024

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    def test_returns_correct_percentage(
        self, mock_totals, mock_session_local
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_totals.return_value = [
            make_window(2020, 2024, 73.4),
        ]

        result = stats.participation_percentage()

        assert result.percent == 73.4

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    def test_returns_correct_reporting_years(
        self, mock_totals, mock_session_local
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_totals.return_value = [
            make_window(2020, 2024, 73.4),
        ]

        result = stats.participation_percentage()

        assert result.year_start == 2020
        assert result.year_end == 2024

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    def test_raises_404_when_no_data(
        self, mock_totals, mock_session_local
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_totals.return_value = []

        with pytest.raises(HTTPException) as exc:
            stats.participation_percentage()

        assert exc.value.status_code == 404
        assert exc.value.detail == "No participation data available"

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    def test_uses_australia_as_national_geography(
        self, mock_totals, mock_session_local
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_totals.return_value = [
            make_window(2020, 2024, 70.8),
        ]

        stats.participation_percentage()

        mock_totals.assert_called_once_with(
            mock_session,
            "Australia",
        )

        
class TestParticipationGraph:
    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    @patch("services.stats._resolve_geo_code")
    def test_returns_requested_state(
        self,
        mock_resolve,
        mock_totals,
        mock_session_local,
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_resolve.return_value = "Vic"
        mock_totals.return_value = [
            make_window(2020, 2024, 71.2),
        ]

        result = stats.participation_graph("Victoria")

        assert result.state == "Vic"

        mock_resolve.assert_called_once_with(
            mock_session,
            "Victoria",
        )

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    @patch("services.stats._resolve_geo_code")
    def test_returns_all_reporting_windows(
        self,
        mock_resolve,
        mock_totals,
        mock_session_local,
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_resolve.return_value = "Vic"
        mock_totals.return_value = [
            make_window(2018, 2022, 72.1),
            make_window(2019, 2023, 71.5),
            make_window(2020, 2024, 70.8),
        ]

        result = stats.participation_graph("Victoria")

        assert len(result.points) == 3

        assert result.points[0].year_start == 2018
        assert result.points[0].year_end == 2022

        assert result.points[1].year_start == 2019
        assert result.points[1].year_end == 2023

        assert result.points[2].year_start == 2020
        assert result.points[2].year_end == 2024

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    @patch("services.stats._resolve_geo_code")
    def test_returns_correct_percentages(
        self,
        mock_resolve,
        mock_totals,
        mock_session_local,
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_resolve.return_value = "NSW"
        mock_totals.return_value = [
            make_window(2018, 2022, 74.2),
            make_window(2019, 2023, 73.6),
            make_window(2020, 2024, 72.9),
        ]

        result = stats.participation_graph("NSW")

        assert result.points[0].percent == 74.2
        assert result.points[1].percent == 73.6
        assert result.points[2].percent == 72.9

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    @patch("services.stats._resolve_geo_code")
    def test_returns_empty_points_when_no_data(
        self,
        mock_resolve,
        mock_totals,
        mock_session_local,
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_resolve.return_value = "Tas"
        mock_totals.return_value = []

        result = stats.participation_graph("Tas")

        assert result.state == "Tas"
        assert result.points == []

    @patch("services.stats.SessionLocal")
    @patch("services.stats._participation_totals")
    @patch("services.stats._resolve_geo_code")
    def test_raises_404_for_unknown_state(
        self,
        mock_resolve,
        mock_totals,
        mock_session_local,
    ):
        mock_session = MagicMock()
        mock_session_local.return_value.__enter__.return_value = mock_session

        mock_resolve.side_effect = HTTPException(
            status_code=404,
            detail="Unknown state: 'Unknown'",
        )

        with pytest.raises(HTTPException) as exc:
            stats.participation_graph("Unknown")

        assert exc.value.status_code == 404
        assert exc.value.detail == "Unknown state: 'Unknown'"