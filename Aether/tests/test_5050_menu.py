"""TDD tests for the 50/50 research menu split.

Run with: pytest tests/test_5050_menu.py -v
"""
import pytest

from research_memory import FutureDirection, FutureDirectionsManager


@pytest.fixture
def fd_manager(tmp_path):
    return FutureDirectionsManager(tmp_path / "ws")


class TestDirectionCategory:
    def test_explicit_category_preserved(self, fd_manager):
        d = FutureDirection(
            id="cat_001",
            title="Famous subtask",
            description="A direction targeting a named hard problem.",
            source_exp_id="seed",
            source_path="seed",
            category="famous_subtask",
        )
        fd_manager.add_direction(d)
        loaded = fd_manager.get_direction_by_id("cat_001")
        assert loaded.category == "famous_subtask"

    def test_category_inference_cross_domain(self, fd_manager):
        d = FutureDirection(
            id="cat_002",
            title="Bridge",
            description="Connect two fields.",
            source_exp_id="seed",
            source_path="seed",
            domain_bridges=["NumberTheory <-> Tropical"],
        )
        assert d.get_category() == "cross_domain_bridge"

    def test_category_inference_famous(self, fd_manager):
        d = FutureDirection(
            id="cat_003",
            title="Riemann Hypothesis subtask",
            description="Partial progress.",
            source_exp_id="seed",
            source_path="seed",
            ambition_level="grand_challenge",
        )
        assert d.get_category() == "famous_subtask"


class TestSelectionBalancing:
    def test_empty_history_is_balanced(self, fd_manager):
        assert fd_manager._category_balance_penalty("famous_subtask") == 1.0
        assert fd_manager._category_balance_penalty("cross_domain_bridge") == 1.0

    def test_overrepresented_category_penalized(self, fd_manager):
        for _ in range(20):
            fd_manager._record_selection_category("famous_subtask")
        penalty = fd_manager._category_balance_penalty("famous_subtask")
        boost = fd_manager._category_balance_penalty("cross_domain_bridge")
        assert penalty < 1.0
        assert boost > 1.0
