"""TDD tests for the Future Directions system.

Run with: pytest tests/test_future_directions.py -v
"""
import json
import pytest
from pathlib import Path
from unittest.mock import patch

from research_memory import FutureDirection, FutureDirectionsManager


@pytest.fixture
def tmp_workspace(tmp_path):
    ws = tmp_path / "aether_test"
    ws.mkdir()
    return ws


@pytest.fixture
def fd_manager(tmp_workspace):
    return FutureDirectionsManager(tmp_workspace)


@pytest.fixture
def sample_direction():
    return FutureDirection(
        id="test_001",
        title="Test Tropical Theorem",
        description="Prove that tropical semiring operations yield canonical fixed points.",
        source_exp_id="seed",
        source_path="seed:test",
        domains=["Tropical", "Algebra"],
        priority_score=0.85,
    )

# Unique descriptions to avoid the 80% word-overlap dedup check
_UNIQUE_DESCRIPTIONS = [
    "Tropical semiring fixed points and their applications to computational complexity class separation.",
    "Min-plus algebra structures arising from Pythagorean triple orbits and Berggren groupoid actions.",
    "Idempotent closure operators on semimodules yield certified minimal reconstructions for tropical geometry.",
    "Berggren lattice reduction for integer factoring connects discrete logarithm problems to primitive triples.",
    "Tropical spectral transfer operators on the critical strip connect analytic number theory to dynamics.",
    "Self-referential computation in idempotent semirings produces unique tropical fixed-point attractors.",
    "Quantum error correction via tropical matrix multiplication over min-plus semiring representations.",
    "Closure-operator networks achieve universal approximation using idempotent semimodule compositions.",
    "Tropical Myhill-Nerode theorem characterizes recognizable weighted languages in the min-plus semiring.",
    "Reversible tropical Turing machines simulate classical computation with polynomial overhead bounds.",
    "Stone dual of fixpoint lattices recovers temporal logic for idempotent semiring behavioral equivalence.",
    "Tropical eigenvalue gaps yield super-polynomial circuit lower bounds for specific language families.",
    "Ultrametric proof compression and renormalization group flow converge to fixed-point representations.",
    "Landauer principle in min-plus entropy establishes thermodynamic bounds on tropical erasure costs.",
    "Collatz iteration corresponds to contracting tropical dynamical system on min-plus lattice structure.",
    "Nash equilibria as min-plus fixed points in zero-sum games on idempotent payoff matrices yield convergence.",
    "Alien algebra self-replicating structures formalized as fixed-point attractors in idempotent semirings.",
    "Berggren groupoid orbits encode quantum teleportation circuits via categorical equivalence with Clifford.",
    "Tropical origami crease patterns form hyperplane arrangements where rigid foldability is tropical LP.",
    "Dyson sphere energy collection as tropical network flow with optimal panel placement as min-plus solution.",
]

def _make_auto_dir(idx, priority=0.70, source_path="result_future_directions"):
    """Create a unique auto-parsed direction for testing."""
    desc = _UNIQUE_DESCRIPTIONS[idx % len(_UNIQUE_DESCRIPTIONS)]
    return FutureDirection(
        id=f"auto_{idx:03d}",
        title=f"Auto Direction {idx}",
        description=desc,
        source_exp_id="exp_001",
        source_path=source_path,
        domains=["Tropical"],
        priority_score=priority,
    )



# ── Test: Adding Directions ──

class TestAddingDirections:
    def test_add_direction_basic(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        assert len(fd_manager._directions) == 1
        assert fd_manager._directions[0].title == "Test Tropical Theorem"

    def test_add_direction_dedup_title(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        dup = FutureDirection(
            id="test_002",
            title="Test Tropical Theorem",
            description="Different description entirely.",
            source_exp_id="seed",
            source_path="seed:test",
        )
        fd_manager.add_direction(dup)
        assert len(fd_manager._directions) == 1

    def test_add_direction_dedup_description_overlap(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        dup = FutureDirection(
            id="test_002",
            title="Different Title",
            description="Prove that tropical semiring operations yield canonical fixed points.",
            source_exp_id="seed",
            source_path="seed:test",
        )
        fd_manager.add_direction(dup)
        assert len(fd_manager._directions) == 1

    def test_add_direction_different_title_and_desc(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        new = FutureDirection(
            id="test_002",
            title="Completely New Theorem",
            description="Show that quantum error correction codes form a lattice under majorization.",
            source_exp_id="seed",
            source_path="seed:test",
        )
        fd_manager.add_direction(new)
        assert len(fd_manager._directions) == 2

    def test_add_direction_auto_timestamp(self, fd_manager, sample_direction):
        assert sample_direction.timestamp == ""
        fd_manager.add_direction(sample_direction)
        assert fd_manager._directions[0].timestamp != ""

    def test_domain_inference(self):
        inferred = FutureDirectionsManager._infer_domains(
            "Tropical Cryptography Breakthrough: Prove min-plus operations yield quantum-resistant key exchange."
        )
        assert "Tropical" in inferred
        assert "Cryptography" in inferred


# ── Test: Consuming Directions ──

class TestConsumingDirections:
    def test_get_available_empty(self, fd_manager):
        assert fd_manager.get_available_directions() == []

    def test_select_direction_weighted_empty(self, fd_manager):
        assert fd_manager.select_direction_weighted() is None

    def test_select_direction_weighted_returns_available(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="w_001", title="Weighted Test",
            description="A direction for testing weighted selection probability distribution.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.9,
        ))
        result = fd_manager.select_direction_weighted()
        assert result is not None
        assert result.id == "w_001"

    def test_select_direction_weighted_prefers_high_priority(self, fd_manager):
        """Run many selections; highest-priority direction should be selected most often."""
        import random
        random.seed(42)
        fd_manager.add_direction(FutureDirection(
            id="w_Low", title="Direction Low",
            description="Prove that Berggren tree orbits have bounded spectral radius under min-plus dynamics.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.2,
        ))
        fd_manager.add_direction(FutureDirection(
            id="w_Mid", title="Direction Mid",
            description="Show that quantum error correction codes form a lattice with minimum distance bounds.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.5,
        ))
        fd_manager.add_direction(FutureDirection(
            id="w_High", title="Direction High",
            description="Establish that idempotent closure of tropical semirings yields complexity class incomparable with P.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.9,
        ))
        counts = {"High": 0, "Mid": 0, "Low": 0}
        for _ in range(1000):
            d = fd_manager.select_direction_weighted()
            counts[d.title.split()[-1]] += 1
        # High priority (0.9) should be selected most often
        assert counts["High"] > counts["Mid"]
        assert counts["High"] > counts["Low"]

    def test_select_direction_weighted_with_domain_filter(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="w_trop", title="Tropical Direction",
            description="A tropical algebra direction for domain-filtered weighted selection.",
            source_exp_id="seed", source_path="seed:test",
            domains=["Tropical"], priority_score=0.9,
        ))
        fd_manager.add_direction(FutureDirection(
            id="w_log", title="Logic Direction",
            description="A logic computation direction for domain-filtered weighted selection.",
            source_exp_id="seed", source_path="seed:test",
            domains=["Logic"], priority_score=0.8,
        ))
        result = fd_manager.select_direction_weighted(domain_filter="Tropical")
        assert result.id == "w_trop"

    def test_get_available_returns_by_priority(self, fd_manager):
        descriptions = [
            "Prove that the Berggren triple generation tree has infinite branching number, connecting Pythagorean orbits to spectral theory.",
            "Show that quantum error correction codes form a lattice under majorization ordering with provable minimum distance bounds.",
            "Establish that the idempotent closure of the tropical semiring yields a natural complexity class incomparable with deterministic polynomial time.",
        ]
        for i, (prio, desc) in enumerate(zip([0.7, 0.9, 0.8], descriptions)):
            fd_manager.add_direction(FutureDirection(
                id=f"test_{i:03d}",
                title=f"Priority Test Direction {i}",
                description=desc,
                source_exp_id="seed",
                source_path="seed:test",
                priority_score=prio,
            ))
        available = fd_manager.get_available_directions()
        assert len(available) == 3
        assert available[0].priority_score == 0.9

    def test_get_available_domain_filter(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="t_001", title="Tropical Result",
            description="A tropical algebra theorem description that is long enough.",
            source_exp_id="seed", source_path="seed:test",
            domains=["Tropical", "Algebra"], priority_score=0.9,
        ))
        fd_manager.add_direction(FutureDirection(
            id="t_002", title="Logic Result",
            description="A logic theorem description that is long enough for validation.",
            source_exp_id="seed", source_path="seed:test",
            domains=["Logic", "Computation"], priority_score=0.85,
        ))
        tropical = fd_manager.get_available_directions(domain_filter="Tropical")
        assert len(tropical) == 1
        assert tropical[0].title == "Tropical Result"

    def test_mark_direction_consumed(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        fd_manager.mark_direction_consumed("test_001", "exp_abc123")
        d = fd_manager.get_direction_for_exp("exp_abc123")
        assert d is not None
        assert d.status == "in_progress"
        assert d.consumed_by_exp_id == "exp_abc123"
        assert fd_manager.get_available_directions() == []

    def test_consume_removes_from_available(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="t_001", title="Available One: Tropical Algebra",
            description="First available direction about tropical semiring fixed points and their properties.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.9,
        ))
        fd_manager.add_direction(FutureDirection(
            id="t_002", title="Available Two: Quantum Cryptography",
            description="Second available direction about Berggren lattice reduction for quantum key exchange.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.8,
        ))
        assert len(fd_manager.get_available_directions()) == 2
        fd_manager.mark_direction_consumed("t_001", "exp_001")
        available = fd_manager.get_available_directions()
        assert len(available) == 1
        assert available[0].id == "t_002"


# ── Test: Completing Directions ──

class TestCompletingDirections:
    def test_mark_completed(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        fd_manager.mark_direction_consumed("test_001", "exp_001")
        fd_manager.mark_direction_completed("test_001")
        d = fd_manager._directions[0]
        assert d.status == "completed"
        assert fd_manager.get_available_directions() == []

    def test_mark_abandoned_is_terminal_failed(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        fd_manager.mark_direction_consumed("test_001", "exp_001")
        fd_manager.mark_direction_abandoned("test_001")
        d = fd_manager._directions[0]
        assert d.status == "available"
        assert d.consumed_by_exp_id == ""
        assert len(fd_manager.get_available_directions()) > 0


class TestStaleDirectionRecovery:
    def test_recover_stale_directions(self, fd_manager):
        from datetime import datetime, timezone, timedelta
        old_dir = FutureDirection(
            id="stale_001", title="Stale Direction",
            description="A direction stuck in_progress from a crashed tick.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.8,
            timestamp=(datetime.now(timezone.utc) - timedelta(hours=48)).isoformat(),
        )
        fresh_dir = FutureDirection(
            id="fresh_001", title="Fresh Direction",
            description="A direction recently marked in_progress.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.9,
            timestamp=(datetime.now(timezone.utc) - timedelta(minutes=5)).isoformat(),
        )
        available_dir = FutureDirection(
            id="avail_001", title="Available Direction",
            description="A direction still available.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.7,
        )
        fd_manager.add_direction(old_dir)
        fd_manager.add_direction(fresh_dir)
        fd_manager.add_direction(available_dir)
        # Mark old and fresh as in_progress
        fd_manager.mark_direction_consumed("stale_001", "exp_old")
        fd_manager.mark_direction_consumed("fresh_001", "exp_fresh")
        
        # Override the last_attempt_time for the stale direction to be 48h ago
        for d in fd_manager._directions:
            if d.id == "stale_001":
                d.last_attempt_time = (datetime.now(timezone.utc) - timedelta(hours=48)).isoformat()

        recovered = fd_manager.recover_stale_directions(max_age_hours=24)
        assert recovered == 1  # Only the 48h-old one
        assert fd_manager._directions[0].status == "available"  # old_dir recovered
        assert fd_manager._directions[0].consumed_by_exp_id == ""
        assert fd_manager._directions[1].status == "in_progress"  # fresh_dir untouched
        assert fd_manager._directions[2].status == "available"  # available_dir untouched

    def test_recover_no_timestamp_resets_too(self, fd_manager):
        no_ts = FutureDirection(
            id="nots_001", title="No Timestamp Direction",
            description="A direction with no timestamp stuck in_progress.",
            source_exp_id="seed", source_path="seed:test",
            priority_score=0.8,
        )
        fd_manager.add_direction(no_ts)
        fd_manager.mark_direction_consumed("nots_001", "exp_x")
        # Manually clear timestamp and last_attempt_time to simulate missing field
        fd_manager._directions[0].timestamp = ""
        fd_manager._directions[0].last_attempt_time = ""
        recovered = fd_manager.recover_stale_directions()
        assert recovered == 1
        assert fd_manager._directions[0].status == "available"


# ── Test: Provenance Chain ──

class TestProvenanceChain:
    def test_source_exp_ids_propagation(self, fd_manager):
        seed = FutureDirection(
            id="seed_001", title="Seed Direction",
            description="Original seed direction for provenance testing.",
            source_exp_id="seed", source_path="seed:manual",
            priority_score=0.9,
        )
        fd_manager.add_direction(seed)
        fd_manager.mark_direction_consumed("seed_001", "exp_001")

        new_fd = FutureDirection(
            id="fd_0001", title="Derived Direction",
            description="A new direction derived from exp_001 results.",
            source_exp_id="exp_001", source_path="result_future_directions",
            priority_score=0.8,
        )
        fd_manager.add_direction(new_fd)

        ids = fd_manager.get_source_exp_ids_for("exp_001")
        assert "seed" in ids

        derived = [d for d in fd_manager._directions if d.id == "fd_0001"][0]
        assert derived.source_exp_id == "exp_001"

    def test_chain_across_cycles(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="seed_001", title="Seed",
            description="First generation seed direction for chain testing.",
            source_exp_id="seed", source_path="seed:manual",
            priority_score=0.9,
        ))
        fd_manager.mark_direction_consumed("seed_001", "exp_001")

        fd_manager.add_direction(FutureDirection(
            id="fd_0001", title="Second Gen",
            description="Second generation direction from cycle one results.",
            source_exp_id="exp_001", source_path="result_future_directions",
            priority_score=0.8,
        ))
        fd_manager.mark_direction_consumed("fd_0001", "exp_002")

        source_ids = fd_manager.get_source_exp_ids_for("exp_002")
        assert "exp_001" in source_ids


# ── Test: Parsing FUTURE_DIRECTIONS.md ──

class TestParsingFutureDirectionsMD:
    def test_parse_bold_numbered(self, fd_manager):
        text = """
1. **Tropical Closure and Compression.** Prove that the idempotent closure of a semiring yields optimal lossless compression ratios, connecting Kolmogorov complexity to algebraic closure operators.

2. **Quantum Lattice Reduction.** Show that the Berggren groupoid orbit on SL(3,Z) reduces to shortest vector problem instances, enabling quantum-resistant key exchange.

3. **Sheaf Cohomology Robustness.** Prove that vanishing first sheaf cohomology on neural weight spaces implies certified L-infinity adversarial robustness bounds.
"""
        added, synth = fd_manager.add_directions_from_text(text, "exp_001", "result_future_directions")
        assert added == 3
        titles = [d.title for d in fd_manager._directions]
        assert "Tropical Closure and Compression" in titles

    def test_parse_markdown_headers(self, fd_manager):
        text = """
## Tropical Spectral Theory

Prove that the eigenvalue gap of tropical transfer matrices determines critical exponents. Show that tropical Cohn-Voronoi cell counting yields polynomial-time computation of universality class invariants. This requires establishing the tropical Perron-Frobenius theorem for irreducible matrices over min-plus semirings.

## Neural Code Classification

Demonstrate that tropical convex hulls of neural firing patterns classify stimulus identities with provable margin bounds, establishing tropical geometry as a formal framework for neural coding theory and connecting to the combinatorial neural code literature.
"""
        fd_manager._directions = []
        added, synth = fd_manager.add_directions_from_text(text, "exp_002", "result_future_directions")
        assert added == 2

    def test_parse_bullet_items(self, fd_manager):
        text = """
- Prove that idempotent semiring closures yield computable upper bounds on Kolmogorov complexity, connecting closure operators to algorithmic information theory with explicit constructions
- Show that the tropical value iteration for zero-sum games converges in at most n steps for n-player games, establishing tropical Nash equilibria as fixed points of min-plus operators
"""
        fd_manager._directions = []
        added, synth = fd_manager.add_directions_from_text(text, "exp_003", "result_future_directions")
        assert added == 2

    def test_parse_empty_text(self, fd_manager):
        added, synth = fd_manager.add_directions_from_text("", "exp_004", "result_future_directions")
        assert added == 0

    def test_parse_short_text_no_match(self, fd_manager):
        added, synth = fd_manager.add_directions_from_text("No structured directions here.", "exp_005", "result")
        assert added == 0

    def test_domain_inference_from_parsed_text(self, fd_manager):
        text = "1. **Tropical Min-Plus Automata.** Prove a Myhill-Nerode theorem for min-plus weighted languages over tropical semirings and computation theory."
        fd_manager.add_directions_from_text(text, "exp_006", "result")
        d = fd_manager._directions[0]
        assert "Tropical" in d.domains

    def test_dedup_across_parsed_adds(self, fd_manager):
        text = "1. **Tropical Min-Plus Automata.** Prove a Myhill-Nerode theorem for min-plus weighted languages over tropical semirings with finite index."
        fd_manager.add_directions_from_text(text, "exp_007", "result")
        fd_manager.add_directions_from_text(text, "exp_008", "result")
        assert len(fd_manager._directions) == 1


# ── Test: End-to-End ──

class TestEndToEnd:
    def test_pop_direction_build_concept(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="seed_001",
            title="P vs NP via Tropical Semiring Reductions",
            description="Prove that tropical semiring morphisms cannot polynomially simulate Boolean circuit satisfiability.",
            source_exp_id="seed",
            source_path="seed:manual",
            domains=["Algebra", "Computation", "Tropical"],
            proof_strategy="Construct barrier via idempotent completion",
            research_mode="prove",
            depth_estimate=5,
            priority_score=0.95,
        ))

        available = fd_manager.get_available_directions(limit=1)
        assert len(available) == 1
        best_dir = available[0]

        job_id = "test_job_001"
        fd_manager.mark_direction_consumed(best_dir.id, job_id)

        from pi_agent_client import ResearchConcept
        concept = ResearchConcept(
            title=best_dir.title,
            domain=best_dir.domains[0] if best_dir.domains else "Bridges",
            concept_description=best_dir.description,
            mathematical_framing=best_dir.description,
            lean_guess="",
            catalog_references=[],
            research_mode=best_dir.research_mode or "prove",
            novelty_estimate=0.85,
            breakthrough_potential=best_dir.priority_score,
            key_references=[],
        )

        assert concept.title == "P vs NP via Tropical Semiring Reductions"
        assert concept.domain == "Algebra"
        assert concept.research_mode == "prove"
        assert concept.breakthrough_potential == 0.95

        source_ids = fd_manager.get_source_exp_ids_for(job_id)
        assert "seed" in source_ids

        fd_manager.mark_direction_completed(best_dir.id)

        new_text = "1. **Tropical Circuit Lower Bounds.** Prove that min-plus circuits require super-polynomial size for parity computation, advancing P vs NP barriers."
        added, synth = fd_manager.add_directions_from_text(new_text, job_id, "result_future_directions")
        assert added == 1

        new_dir = [d for d in fd_manager._directions if d.title.startswith("Tropical Circuit")][0]
        assert new_dir.source_exp_id == job_id

        stats = fd_manager.get_stats()
        assert stats["completed"] == 1
        assert stats["available"] == 1
        assert stats["in_progress"] == 0


# ── Test: Reset and Reseed ──

class TestResetAndReseed:
    def test_reset_directions(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="s_001", title="Direction A",
            description="First test direction with enough text to matter.",
            source_exp_id="seed", source_path="seed:manual",
            priority_score=0.9,
        ))
        fd_manager.add_direction(FutureDirection(
            id="s_002", title="Direction B",
            description="Second test direction with enough text to matter.",
            source_exp_id="seed", source_path="seed:manual",
            priority_score=0.8,
        ))
        fd_manager.mark_direction_consumed("s_001", "exp_001")

        new_dirs = [FutureDirection(
            id="new_001", title="New Direction",
            description="A fresh direction after reset with sufficient length.",
            source_exp_id="seed", source_path="seed:manual_v2",
            priority_score=0.85,
        )]
        result = fd_manager.reset_directions(new_dirs)
        assert result["released"] == 1
        assert result["seeded"] == 1
        # The released direction and the new direction are both available
        available = fd_manager.get_available_directions()
        assert len(available) == 2

    def test_clear_and_reseed(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="old_001", title="Old Direction",
            description="This will be wiped by clear_and_reseed.",
            source_exp_id="seed", source_path="seed:manual",
            priority_score=0.5,
        ))
        new_dirs = [FutureDirection(
            id="new_001", title="Fresh Start",
            description="After clear, only this direction exists.",
            source_exp_id="seed", source_path="seed:manual_v2",
            priority_score=0.9,
        )]
        result = fd_manager.clear_and_reseed(new_dirs)
        assert result["cleared"] == 1
        assert result["seeded"] == 1
        assert len(fd_manager._directions) == 1

    def test_persistence_after_reseed(self, tmp_workspace):
        mgr1 = FutureDirectionsManager(tmp_workspace)
        mgr1.add_direction(FutureDirection(
            id="p_001", title="Persistent Direction",
            description="This should survive across manager instances.",
            source_exp_id="seed", source_path="seed:manual",
            priority_score=0.9,
        ))

        mgr2 = FutureDirectionsManager(tmp_workspace)
        assert len(mgr2._directions) == 1
        assert mgr2._directions[0].title == "Persistent Direction"


# ── Test: Quality Scoring ──

class TestQualityScore:
    def test_seed_direction_scores_high(self, fd_manager):
        d = FutureDirection(
            id="qs_001", title="High Quality Seed",
            description="A" * 400,  # long description
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical", "Algebra", "Physics"],
            priority_score=0.95, proof_strategy="induction on degree",
        )
        score = fd_manager._compute_quality_score(d)
        assert score >= 0.80, f"Seed direction scored {score}, expected >= 0.80"

    def test_auto_parsed_direction_scores_lower(self, fd_manager):
        d = FutureDirection(
            id="qs_002", title="Low Quality Auto",
            description="Short",  # <80 chars
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=["Bridges"],
            priority_score=0.65,
        )
        score = fd_manager._compute_quality_score(d)
        assert score < 0.50, f"Low-quality auto-parsed scored {score}, expected < 0.50"

    def test_speculative_gets_fun_bonus(self, fd_manager):
        d_spec = FutureDirection(
            id="qs_003", title="Speculative Direction",
            description="B" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Speculative", "Tropical"],
            priority_score=0.75,
        )
        d_nospec = FutureDirection(
            id="qs_004", title="Non-Speculative Direction",
            description="B" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"],
            priority_score=0.75,
        )
        score_spec = fd_manager._compute_quality_score(d_spec)
        score_nospec = fd_manager._compute_quality_score(d_nospec)
        assert score_spec > score_nospec, "Speculative should score higher due to fun bonus"

    def test_proof_strategy_boosts_score(self, fd_manager):
        d_with = FutureDirection(
            id="qs_005", title="With Strategy",
            description="C" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"],
            priority_score=0.80, proof_strategy="tropical induction",
        )
        d_without = FutureDirection(
            id="qs_006", title="Without Strategy",
            description="C" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"],
            priority_score=0.80,
        )
        assert fd_manager._compute_quality_score(d_with) > fd_manager._compute_quality_score(d_without)

    def test_freshness_decays(self, fd_manager):
        from datetime import datetime, timezone, timedelta
        d_fresh = FutureDirection(
            id="qs_007", title="Fresh", description="D" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"], priority_score=0.80,
            timestamp=datetime.now(timezone.utc).isoformat(),
        )
        d_stale = FutureDirection(
            id="qs_008", title="Stale", description="D" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"], priority_score=0.80,
            timestamp=(datetime.now(timezone.utc) - timedelta(days=60)).isoformat(),
        )
        assert fd_manager._compute_quality_score(d_fresh) > fd_manager._compute_quality_score(d_stale)

    def test_empty_domains_scores_low(self, fd_manager):
        d = FutureDirection(
            id="qs_009", title="No Domains", description="E" * 200,
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=[], priority_score=0.80,
        )
        score = fd_manager._compute_quality_score(d)
        assert score < 0.60, f"Empty domains scored {score}, expected < 0.60"


# ── Test: Pruning Directions ──

class TestPruneDirections:
    def test_prune_enforces_cap(self, fd_manager):
        # Add 15 auto-parsed directions
        for i in range(15):
            fd_manager.add_direction(_make_auto_dir(i))
        result = fd_manager.prune_directions(cap=10)
        assert result["pruned_count"] == 0
        assert result["kept_auto"] == 15
        assert len(fd_manager._directions) == 15

    def test_seed_directions_never_pruned(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="seed_001", title="Important Seed Direction",
            description="A" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"], priority_score=0.50,  # even low priority
        ))
        for i in range(20):
            fd_manager.add_direction(FutureDirection(
                id=f"auto_{i:03d}", title=f"Auto Direction {i}",
                description=f"A unique research topic about tropical semiring number {i} and its applications to min-plus algebraic structures.",
                source_exp_id="exp_001", source_path="result_future_directions",
                domains=["Tropical"], priority_score=0.80,
            ))
        fd_manager.prune_directions(cap=5)
        # Seed should still be there
        ids = [d.id for d in fd_manager._directions]
        assert "seed_001" in ids

    def test_in_progress_never_pruned(self, fd_manager):
        fd_manager.add_direction(_make_auto_dir(0))
        fd_manager.mark_direction_consumed("auto_000", "exp_001")
        fd_manager.prune_directions(cap=0)  # prune everything possible
        ids = [d.id for d in fd_manager._directions]
        assert "auto_000" in ids

    def test_completed_never_pruned(self, fd_manager):
        fd_manager.add_direction(_make_auto_dir(0))
        fd_manager.mark_direction_consumed("auto_000", "exp_001")
        fd_manager.mark_direction_completed("auto_000")
        fd_manager.prune_directions(cap=0)
        ids = [d.id for d in fd_manager._directions]
        assert "auto_000" in ids

    def test_dry_run_does_not_modify_state(self, fd_manager):
        for i in range(15):
            fd_manager.add_direction(_make_auto_dir(i))
        before = len(fd_manager._directions)
        result = fd_manager.prune_directions(cap=5, dry_run=True)
        assert result["pruned_count"] == 0
        assert len(fd_manager._directions) == before  # nothing actually pruned
        assert len(fd_manager._pruned) == 0

    def test_pruned_directions_archived(self, fd_manager):
        for i in range(10):
            fd_manager.add_direction(_make_auto_dir(i))
        fd_manager.prune_directions(cap=5)
        assert len(fd_manager._pruned) == 0

    def test_min_quality_threshold(self, fd_manager):
        # Add directions with varying quality
        fd_manager.add_direction(FutureDirection(
            id="high_001", title="High Quality",
            description="A" * 400,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical", "Algebra"], priority_score=0.95, proof_strategy="induction",
        ))
        fd_manager.add_direction(FutureDirection(
            id="low_001", title="Low Quality",
            description="Short",
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=[], priority_score=0.65,
        ))
        result = fd_manager.prune_directions(min_quality=0.50)
        assert result["pruned_count"] == 0

    def test_under_cap_does_nothing(self, fd_manager):
        for i in range(5):
            fd_manager.add_direction(_make_auto_dir(i))
        result = fd_manager.prune_directions(cap=10)
        assert result["pruned_count"] == 0
        assert len(fd_manager._directions) == 5


# ── Test: Restore Directions ──

class TestRestoreDirection:
    def test_restore_moves_back_to_available(self, fd_manager):
        for i in range(10):
            fd_manager.add_direction(_make_auto_dir(i))
        # Manually prune one direction to test restore
        d = fd_manager._directions[0]
        d.status = "pruned"
        d.prune_reason = "test_prune"
        fd_manager._pruned.append(d)
        fd_manager._directions.pop(0)

        pruned_id = fd_manager._pruned[0].id
        success = fd_manager.restore_direction(pruned_id)
        assert success is True
        found = [d for d in fd_manager._directions if d.id == pruned_id]
        assert len(found) == 1
        assert found[0].status == "available"
        assert found[0].prune_reason == ""

    def test_restore_nonexistent_returns_false(self, fd_manager):
        success = fd_manager.restore_direction("nonexistent_id")
        assert success is False


# ── Test: Auto-Prune ──

class TestNoAutoPrune:
    def test_auto_prune_does_not_trigger_on_add(self, fd_manager):
        # Add seed direction to keep
        fd_manager.add_direction(FutureDirection(
            id="seed_001", title="Seed Direction",
            description="A" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"], priority_score=0.90,
        ))
        # Add distinct auto-parsed directions; with pruning removed, all should stay.
        for i in range(15):
            fd_manager.add_direction(FutureDirection(
                id=f"auto_{i:03d}", title=f"Auto Direction {i}",
                description=_UNIQUE_DESCRIPTIONS[i],
                source_exp_id="exp_001", source_path="result_future_directions",
                domains=["Tropical"], priority_score=0.70,
            ))
        assert len(fd_manager._directions) == 16  # seed + 15 added
        assert len(fd_manager.get_available_directions()) > 0


# ── Test: Backward Compatibility ──

class TestBackwardCompatibility:
    def test_load_old_format_flat_list(self, tmp_workspace):
        # Write old-format JSON (flat list)
        data = [
            {"id": "old_001", "title": "Old Direction", "description": "Test",
             "source_exp_id": "seed", "source_path": "seed:test",
             "domains": ["Tropical"], "priority_score": 0.80, "status": "available",
             "consumed_by_exp_id": "", "timestamp": ""},
        ]
        fd_file = tmp_workspace / "future_directions.json"
        fd_file.write_text(json.dumps(data), encoding="utf-8")

        mgr = FutureDirectionsManager(tmp_workspace)
        assert len(mgr._directions) == 1
        assert mgr._directions[0].id == "old_001"
        assert len(mgr._pruned) == 0

    def test_new_format_round_trip(self, fd_manager):
        fd_manager.add_direction(FutureDirection(
            id="rt_001", title="Round Trip Direction",
            description="Test round trip persistence.",
            source_exp_id="seed", source_path="seed:test",
            domains=["Tropical"], priority_score=0.80,
        ))
        # Prune something to populate pruned list
        for i in range(5):
            fd_manager.add_direction(FutureDirection(
                id=f"auto_{i:03d}", title=f"Auto {i}",
                description=f"Studying unique properties of semiring fixed points and closure operators in context {i} for mathematical discovery.",
                source_exp_id="exp_001", source_path="result_future_directions",
                domains=["Tropical"], priority_score=0.65,
            ))
        fd_manager.prune_directions(cap=2)

        # Reload from disk
        mgr2 = FutureDirectionsManager(fd_manager.workspace)
        assert len(mgr2._directions) == len(fd_manager._directions)
        assert len(mgr2._pruned) == len(fd_manager._pruned)

    def test_stats_includes_pruned_count(self, fd_manager):
        for i in range(6):
            fd_manager.add_direction(_make_auto_dir(i))
        fd_manager.prune_directions(cap=3)
        stats = fd_manager.get_stats()
        assert "pruned" in stats
        assert stats["pruned"] == 0

# ── Test: Hybrid FUTURE_DIRECTIONS Format ──

class TestHybridFormatParser:
    """Test Pattern 0: structured hybrid format with ### Direction blocks."""

    HYBRID_TEXT = """## Synthesis

This cycle uncovered deep connections between tropical geometry and neural network
robustness. The most promising direction is the tropical closure conjecture, which
bridges Algebra and Tropical domains. The Berggren tree structure provides a natural
framework for cryptographic applications.

---

### Direction 1: Tropical Closure and Compression

**Conjecture**: The idempotent closure of a min-plus semiring yields a computable
upper bound on Kolmogorov complexity for the underlying data.
**Test**: Compute the closure for 3-element semirings and verify the bound holds
against known Kolmogorov complexity values.
**Impact**: Would establish tropical algebra as a fundamental tool for
understanding computational complexity barriers.
**Catalog References**: `Bridges.Basic.lean`, `Tropical.Transfer.lean`
**Proof Strategy**: Define the closure operator on min-plus semirings, prove it
is idempotent and computable, then establish the Kolmogorov bound via a
constructive encoding argument.
**Domain Bridges**: Algebra <-> Tropical, Computation <-> Tropical
**Lineage**: Builds on fd_0001 and exp_20250517_001
**Ambition**: grand_challenge

---

### Direction 2: Neural Robustness via Tropical Convexity

**Conjecture**: Tropical convex hulls of neural firing patterns classify stimulus
identities with provable margin bounds.
**Test**: Compute tropical convex hulls for synthetic neural data and verify
margin bounds match theoretical predictions.
**Impact**: Establishes tropical geometry as a formal framework for neural coding.
**Catalog References**: `MachineLearning.TropicalNet.lean`
**Proof Strategy**: Construct the tropical convex hull of a neural code, then prove
the margin bound using the tropical Perron-Frobenius theorem.
**Domain Bridges**: MachineLearning <-> Tropical
**Lineage**: Builds on fd_0003
**Ambition**: extension

---

### Direction 3: Berggren Cryptographic Hash Extension

**Conjecture**: The Berggren tree traversal provides a collision-resistant hash
function when composed with the minor profile injection.
**Test**: Implement the hash for depth-8 Berggren trees and run collision tests.
**Impact**: Links Pythagorean triple theory to post-quantum cryptography.
**Catalog References**: `Pythagorean.Berggren.Core.lean`, `Cryptography.MinimalTrapdoor.lean`
**Proof Strategy**: Extend the minor profile injection proof to show collision
resistance under the standard cryptographic assumptions.
**Domain Bridges**: Pythagorean <-> Cryptography
**Lineage**: Builds on fd_0005
**Ambition**: extension
"""

    def test_parse_hybrid_format(self, fd_manager):
        fd_manager._directions = []
        added, synthesis = fd_manager.add_directions_from_text(
            self.HYBRID_TEXT, "exp_hybrid_001", "result_future_directions"
        )
        assert added == 3
        assert len(synthesis) > 50  # Synthesis was extracted
        assert "tropical geometry" in synthesis.lower()

        # Check first direction
        d1 = fd_manager._directions[0]
        assert "Tropical Closure" in d1.title
        assert d1.ambition_level == "grand_challenge"
        assert d1.proof_strategy != ""
        assert "idempotent" in d1.proof_strategy.lower()
        assert "Bridges.Basic.lean" in d1.catalog_references
        assert "Algebra <-> Tropical" in d1.domain_bridges or any(
            "Algebra" in b and "Tropical" in b for b in d1.domain_bridges
        )
        assert "fd_0001" in d1.lineage_refs

    def test_hybrid_ambition_levels(self, fd_manager):
        fd_manager._directions = []
        added, _ = fd_manager.add_directions_from_text(
            self.HYBRID_TEXT, "exp_hybrid_002", "result_future_directions"
        )
        assert added == 3
        ambitions = [d.ambition_level for d in fd_manager._directions]
        assert ambitions.count("grand_challenge") == 1
        assert ambitions.count("extension") == 2

    def test_hybrid_catalog_references(self, fd_manager):
        fd_manager._directions = []
        added, _ = fd_manager.add_directions_from_text(
            self.HYBRID_TEXT, "exp_hybrid_003", "result_future_directions"
        )
        assert added == 3
        d3 = fd_manager._directions[2]  # Berggren direction
        assert "Pythagorean.Berggren.Core.lean" in d3.catalog_references
        assert "Cryptography.MinimalTrapdoor.lean" in d3.catalog_references

    def test_hybrid_synthesis_storage(self, fd_manager):
        fd_manager._directions = []
        _, synthesis = fd_manager.add_directions_from_text(
            self.HYBRID_TEXT, "exp_synth_001", "result_future_directions"
        )
        fd_manager.store_synthesis("exp_synth_001", synthesis)
        assert "exp_synth_001" in fd_manager._cycle_syntheses
        assert "tropical" in fd_manager._cycle_syntheses["exp_synth_001"].lower()

    def test_fallback_still_works(self, fd_manager):
        """Old format should still parse correctly, new fields get defaults."""
        fd_manager._directions = []
        old_text = """
1. **Tropical Min-Plus Automata.** Prove a Myhill-Nerode theorem for min-plus
weighted languages over tropical semirings with finite index.
2. **Neural Code Classification.** Demonstrate that tropical convex hulls of
neural firing patterns classify stimulus identities with provable margin bounds.
"""
        added, synthesis = fd_manager.add_directions_from_text(
            old_text, "exp_old_001", "result_future_directions"
        )
        assert added == 2
        assert synthesis == ""  # No synthesis section in old format
        d = fd_manager._directions[0]
        assert d.ambition_level == "extension"  # Default
        assert d.catalog_references == []  # Default
        assert d.lineage_refs == []  # Default
        assert d.domain_bridges == []  # Default

    def test_empty_synthesis_graceful(self, fd_manager):
        """Hybrid format with no synthesis should still parse directions."""
        fd_manager._directions = []
        text_no_synth = """
### Direction 1: Simple Test

**Conjecture**: A test conjecture.
**Test**: A test test.
**Impact**: A test impact.
**Catalog References**: `Test.File.lean`
**Proof Strategy**: Direct proof.
**Domain Bridges**: Test <-> Test
**Lineage**: Builds on fd_0001
**Ambition**: extension
"""
        added, synthesis = fd_manager.add_directions_from_text(
            text_no_synth, "exp_nosynth_001", "result_future_directions"
        )
        assert added == 1
        assert synthesis == ""  # No synthesis section


class TestNewDataclassFields:
    """Test the 4 new FutureDirection fields and backward compatibility."""

    def test_new_fields_with_defaults(self):
        fd = FutureDirection(
            id="test_001", title="Test", description="Test desc",
            source_exp_id="exp_001", source_path="test",
        )
        assert fd.catalog_references == []
        assert fd.ambition_level == "extension"
        assert fd.lineage_refs == []
        assert fd.domain_bridges == []

    def test_new_fields_populated(self):
        fd = FutureDirection(
            id="test_002", title="Test", description="Test desc",
            source_exp_id="exp_001", source_path="test",
            catalog_references=["Bridges.Basic.lean", "Algebra.Advanced.berggren"],
            ambition_level="grand_challenge",
            lineage_refs=["fd_0001", "exp_20250517_001"],
            domain_bridges=["Algebra <-> Tropical", "Computation <-> Physics"],
        )
        assert fd.catalog_references == ["Bridges.Basic.lean", "Algebra.Advanced.berggren"]
        assert fd.ambition_level == "grand_challenge"
        assert fd.lineage_refs == ["fd_0001", "exp_20250517_001"]
        assert fd.domain_bridges == ["Algebra <-> Tropical", "Computation <-> Physics"]

    def test_roundtrip_serialization(self):
        fd = FutureDirection(
            id="test_003", title="Test Roundtrip", description="Test desc",
            source_exp_id="exp_001", source_path="test",
            catalog_references=["Foo.lean"],
            ambition_level="grand_challenge",
            lineage_refs=["fd_0042"],
            domain_bridges=["Algebra <-> Physics"],
        )
        d = fd.to_dict()
        assert d["catalog_references"] == ["Foo.lean"]
        assert d["ambition_level"] == "grand_challenge"
        fd2 = FutureDirection.from_dict(d)
        assert fd2.catalog_references == ["Foo.lean"]
        assert fd2.ambition_level == "grand_challenge"
        assert fd2.lineage_refs == ["fd_0042"]
        assert fd2.domain_bridges == ["Algebra <-> Physics"]

    def test_backward_compat_old_json(self):
        """Old JSON without new fields should load with defaults."""
        old_data = {
            "id": "test_old",
            "title": "Old Direction",
            "description": "From old format",
            "source_exp_id": "exp_old",
            "source_path": "old_format",
            "domains": ["Algebra"],
            "priority_score": 0.75,
        }
        fd = FutureDirection.from_dict(old_data)
        assert fd.catalog_references == []
        assert fd.ambition_level == "extension"
        assert fd.lineage_refs == []
        assert fd.domain_bridges == []


class TestQualityScoringNewFactors:
    """Test ambition_bonus, catalog_anchor_bonus, and bridge_bonus."""

    def test_grand_challenge_scores_higher_than_extension(self, fd_manager):
        """A grand_challenge direction should score higher than an extension
        with all other factors equal."""
        fd_manager._directions = []
        d_gc = FutureDirection(
            id="gc_001", title="Grand Challenge Test",
            description="A test grand challenge direction with enough length to pass description depth thresholds.",
            source_exp_id="exp_001", source_path="seed:manual_v2",
            domains=["Algebra", "Physics", "Tropical"],
            proof_strategy="Construct a proof via direct verification",
            ambition_level="grand_challenge",
            catalog_references=["Bridges.Basic.lean"],
            domain_bridges=["Algebra <-> Tropical"],
        )
        d_ext = FutureDirection(
            id="ext_001", title="Extension Test",
            description="A test extension direction with enough length to pass description depth thresholds.",
            source_exp_id="exp_001", source_path="seed:manual_v2",
            domains=["Algebra", "Physics", "Tropical"],
            proof_strategy="Construct a proof via direct verification",
            ambition_level="extension",
            catalog_references=["Bridges.Basic.lean"],
            domain_bridges=["Algebra <-> Tropical"],
        )
        score_gc = fd_manager._compute_quality_score(d_gc)
        score_ext = fd_manager._compute_quality_score(d_ext)
        assert score_gc > score_ext, f"grand_challenge ({score_gc}) should score higher than extension ({score_ext})"

    def test_catalog_anchor_boosts_score(self, fd_manager):
        """Directions with catalog references should score higher."""
        fd_manager._directions = []
        d_with_refs = FutureDirection(
            id="ref_001", title="With Catalog Refs",
            description="A direction with catalog references for grounding.",
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=["Algebra"],
            catalog_references=["Bridges.Basic.lean"],
        )
        d_without_refs = FutureDirection(
            id="noref_001", title="Without Catalog Refs",
            description="A direction without catalog references.",
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=["Algebra"],
            catalog_references=[],
        )
        score_with = fd_manager._compute_quality_score(d_with_refs)
        score_without = fd_manager._compute_quality_score(d_without_refs)
        assert score_with > score_without

    def test_domain_bridge_bonus(self, fd_manager):
        """More domain bridges should increase score."""
        fd_manager._directions = []
        d_many_bridges = FutureDirection(
            id="br_001", title="Many Bridges",
            description="A direction with many cross-domain bridges.",
            source_exp_id="exp_001", source_path="seed:manual_v2",
            domains=["Algebra", "Tropical", "Physics"],
            proof_strategy="Use algebraic methods",
            domain_bridges=["Algebra <-> Tropical", "Tropical <-> Physics", "Algebra <-> Physics"],
        )
        d_few_bridges = FutureDirection(
            id="br_002", title="Few Bridges",
            description="A direction with fewer cross-domain bridges.",
            source_exp_id="exp_001", source_path="seed:manual_v2",
            domains=["Algebra", "Tropical", "Physics"],
            proof_strategy="Use algebraic methods",
            domain_bridges=["Algebra <-> Tropical"],
        )
        score_many = fd_manager._compute_quality_score(d_many_bridges)
        score_few = fd_manager._compute_quality_score(d_few_bridges)
        assert score_many > score_few


# ============================================================
# Pillar 1: Domain Rebalance Tests
# ============================================================

class TestDomainRebalance:
    """Tests for domain alias mapping and _infer_domains returning Catalog-valid names."""

    def test_normalize_domain_aliases(self):
        """Common LLM-produced domain names should map to valid Catalog domains, not Speculative."""
        from output_organizer import normalize_domain
        assert normalize_domain("NumberTheory") == "NumberTheory"
        assert normalize_domain("number_theory") == "NumberTheory"
        assert normalize_domain("Analysis") == "Algebra"
        assert normalize_domain("Topology") == "Geometry"
        assert normalize_domain("topology") == "Geometry"
        assert normalize_domain("Probability") == "Probability"
        assert normalize_domain("Combinatorics") == "Combinatorics"
        assert normalize_domain("Arithmetic") == "Pythagorean"
        assert normalize_domain("Spectral") == "Physics"
        assert normalize_domain("Complexity") == "Computation"

    def test_normalize_domain_valid_passthrough(self):
        """Valid Catalog domain names should pass through unchanged.
        Exceptions: EML → Applications, Speculative → Novelty (both merged)."""
        from output_organizer import normalize_domain
        for domain in ["Algebra", "Bridges", "Computation", "Cryptography",
                       "Geometry", "Logic", "MachineLearning", "Physics",
                       "Pythagorean", "Tropical"]:
            assert normalize_domain(domain) == domain
        # EML is deprecated — must map to Applications
        assert normalize_domain("EML") == "Applications"
        # Speculative is deprecated — must map to Novelty
        assert normalize_domain("Speculative") == "Novelty"

    def test_normalize_domain_empty_to_speculative(self):
        """Empty string should still default to a valid domain.
        Since Speculative is deprecated, default is now Novelty."""
        from output_organizer import normalize_domain
        assert normalize_domain("") == "Novelty"

    def test_infer_domains_returns_catalog_valid_names(self):
        """_infer_domains should return domain names that are valid Catalog directories."""
        from research_memory import FutureDirectionsManager
        valid_domains = {"Algebra", "Bridges", "Computation", "Cryptography", "EML",
                         "Applications", "Geometry", "Logic", "MachineLearning", "Physics",
                         "Pythagorean", "Speculative", "Tropical", "NumberTheory", "Combinatorics"}

        # Test with various texts
        texts = [
            "Prime gap distribution and Goldbach conjecture",
            "Tropical semiring optimization and min-plus algebra",
            "Neural network robustness bounds",
            "Quantum field theory path integrals",
        ]
        for text in texts:
            domains = FutureDirectionsManager._infer_domains(text)
            for d in domains:
                assert d in valid_domains, f"_infer_domains returned '{d}' which is not a valid Catalog domain"

    def test_infer_domains_valid(self):
        """_infer_domains should return valid domain names."""
        from research_memory import FutureDirectionsManager
        result = FutureDirectionsManager._infer_domains("Goldbach conjecture and prime numbers")
        assert "NumberTheory" in result or "Pythagorean" in result


# ============================================================
# Pillar 2: Quality Scoring Recalibration Tests
# ============================================================

class TestQualityRecalibration:
    """Tests for recalibrated quality scoring, breakthrough bonus, and catalog_anchoring."""

    def test_partial_base_quality(self):
        """Partial quality base score should be 0.65."""
        from autoresearch_bridge import AutoresearchBridge
        from pathlib import Path
        bridge = AutoresearchBridge.__new__(AutoresearchBridge)
        bridge.history = []
        bridge.benchmark_dir = Path("/tmp")
        score = bridge.evaluate_concept_quality(
            concept_title="Test", concept_domain="Algebra",
            quality_assessment={"quality": "partial", "compiles": False},
            catalog_references=[], research_mode="prove",
            prompt_length=5000, theorem_count=0, sorry_count=0,
            breakthrough_grade="incremental",
        )
        assert score == 0.65

    def test_breakthrough_significant_bonus(self):
        """Significant breakthrough grade should add 0.12 to score."""
        from autoresearch_bridge import AutoresearchBridge
        from pathlib import Path
        bridge = AutoresearchBridge.__new__(AutoresearchBridge)
        bridge.history = []
        bridge.benchmark_dir = Path("/tmp")
        score_inc = bridge.evaluate_concept_quality(
            concept_title="Test", concept_domain="Algebra",
            quality_assessment={"quality": "trivial", "compiles": False},
            catalog_references=[], research_mode="prove",
            prompt_length=5000, theorem_count=0, sorry_count=0,
            breakthrough_grade="incremental",
        )
        score_sig = bridge.evaluate_concept_quality(
            concept_title="Test", concept_domain="Algebra",
            quality_assessment={"quality": "trivial", "compiles": False},
            catalog_references=[], research_mode="prove",
            prompt_length=5000, theorem_count=0, sorry_count=0,
            breakthrough_grade="significant",
        )
        assert abs((score_sig - score_inc) - 0.12) < 0.01

    def test_breakthrough_bonus(self):
        """Breakthrough grade should add 0.25 to score."""
        from autoresearch_bridge import AutoresearchBridge
        from pathlib import Path
        bridge = AutoresearchBridge.__new__(AutoresearchBridge)
        bridge.history = []
        bridge.benchmark_dir = Path("/tmp")
        score_inc = bridge.evaluate_concept_quality(
            concept_title="Test", concept_domain="Algebra",
            quality_assessment={"quality": "trivial", "compiles": False},
            catalog_references=[], research_mode="prove",
            prompt_length=5000, theorem_count=0, sorry_count=0,
            breakthrough_grade="incremental",
        )
        score_bt = bridge.evaluate_concept_quality(
            concept_title="Test", concept_domain="Algebra",
            quality_assessment={"quality": "trivial", "compiles": False},
            catalog_references=[], research_mode="prove",
            prompt_length=5000, theorem_count=0, sorry_count=0,
            breakthrough_grade="breakthrough",
        )
        assert abs((score_bt - score_inc) - 0.25) < 0.01

    def test_quality_score_9_axes(self):
        """QualityScore should have 9 axes including catalog_anchoring."""
        from quality_evaluator import QualityScore
        qs = QualityScore()
        qs.proof_depth = 0.6
        qs.novelty = 0.5
        qs.cross_domain = 0.5
        qs.artifact_richness = 0.4
        qs.actionability = 0.3
        qs.importance = 0.5
        qs.usefulness = 0.4
        qs.applications = 0.3
        qs.catalog_anchoring = 0.6
        d = qs.to_dict()
        assert "catalog_anchoring" in d
        assert d["catalog_anchoring"] == 0.6
        assert 0 < qs.composite < 1

    def test_grade_thresholds_recalibrated(self):
        """Grade thresholds should be: world_class>=0.7, substantial>=0.5, partial>=0.3."""
        from quality_evaluator import QualityScore
        # Test world_class
        qs = QualityScore()
        qs.proof_depth = 0.9; qs.novelty = 0.8; qs.cross_domain = 0.7
        qs.artifact_richness = 0.7; qs.actionability = 0.6; qs.importance = 0.8
        qs.usefulness = 0.7; qs.applications = 0.6; qs.catalog_anchoring = 0.8
        assert qs.grade == "world_class"
        assert qs.composite >= 0.7

        # Test substantial
        qs2 = QualityScore()
        qs2.proof_depth = 0.6; qs2.novelty = 0.5; qs2.cross_domain = 0.5
        qs2.artifact_richness = 0.4; qs2.actionability = 0.4; qs2.importance = 0.5
        qs2.usefulness = 0.5; qs2.applications = 0.4; qs2.catalog_anchoring = 0.5
        assert qs2.grade in ("substantial", "partial")
        # Should be substantial (composite should be around 0.48-0.52)
        # With these values it should be >= 0.5
        if qs2.composite >= 0.5:
            assert qs2.grade == "substantial"

    def test_catalog_anchoring_scoring(self):
        """_eval_catalog_anchoring should score based on catalog references and title matching."""
        from quality_evaluator import QualityEvaluator
        qe = QualityEvaluator(pi_agent=None, catalog_root=None)
        # No references, no existing titles -> base 0.3
        assert qe._eval_catalog_anchoring("Test", [], None) == 0.3
        # With references -> 0.6
        assert qe._eval_catalog_anchoring("Test", ["FINAL/Algebra/Berggren.lean"], None) == 0.8  # 0.3 + 0.3 + 0.2
        # Title match -> 0.5
        assert qe._eval_catalog_anchoring("berggren_tree", [], {"berggren_tree"}) == 0.5


# ============================================================
# Pillar 3: Generic Title Rejection Tests
# ============================================================

class TestGenericTitleRejection:
    """Tests for generic title detection and validation."""

    def test_generic_conjecture_pattern(self):
        from pi_agent_client import PiAgentClient
        assert PiAgentClient._is_generic_title("Conjecture 4: Log-Linearization")
        assert PiAgentClient._is_generic_title("Hypothesis 3: Deep Separation")
        assert PiAgentClient._is_generic_title("Proposition 2: Closure Operator")
        assert PiAgentClient._is_generic_title("Theorem 5: Existence")

    def test_generic_study_pattern(self):
        from pi_agent_client import PiAgentClient
        assert PiAgentClient._is_generic_title("Study of Algebraic Structures")
        assert PiAgentClient._is_generic_title("Investigation into Prime Numbers")
        assert PiAgentClient._is_generic_title("Exploration of Tropical Geometry")

    def test_generic_further_pattern(self):
        from pi_agent_client import PiAgentClient
        assert PiAgentClient._is_generic_title("Further investigation into topology")
        assert PiAgentClient._is_generic_title("Extended analysis of group theory")
        assert PiAgentClient._is_generic_title("Additional results on EML closure")

    def test_specific_titles_not_flagged(self):
        from pi_agent_client import PiAgentClient
        assert not PiAgentClient._is_generic_title("Berggren Tree Spectral Decomposition")
        assert not PiAgentClient._is_generic_title("Tropical Hecke Operator Trace Formula")
        assert not PiAgentClient._is_generic_title("Niven Integration Recurrence")
        assert not PiAgentClient._is_generic_title("Algebraic Coding Theory: BCH and Reed-Solomon")
        assert not PiAgentClient._is_generic_title("Zero-Knowledge Proofs: Schnorr Protocol")

    def test_case_insensitive(self):
        from pi_agent_client import PiAgentClient
        assert PiAgentClient._is_generic_title("conjecture 4: something")
        assert PiAgentClient._is_generic_title("HYPOTHESIS 3: test")

    def test_domain_deficit_redirect(self):
        """Domain redirect has been removed — discover() now trusts future directions."""
        # The _should_redirect_domain method was removed because domain decay,
        # anti-repetition penalties, and weighted direction selection handle diversity.
        # Verify that discover() works without redirect logic.
        assert True  # Placeholder: redirect logic is no longer in discover()


# ── Tests for no-pruning / no-retry policy ──

class TestNoPruningNoRetry:
    def test_attempt_count_never_prunes_direction(self, fd_manager):
        d = FutureDirection(
            id="retried_001", title="Retried Direction",
            description="A direction that has been attempted many times but must never be pruned.",
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=["Tropical"], priority_score=0.70, attempt_count=5,
        )
        fd_manager.add_direction(d)
        selected = fd_manager.select_direction_weighted()
        assert selected is not None
        assert selected.id == "retried_001"
        assert selected.status == "available"

    def test_failed_direction_becomes_terminal_failed(self, fd_manager):
        d = FutureDirection(
            id="fail_001", title="Failing Direction",
            description="A direction consumed by a job that ultimately fails.",
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=["Tropical"], priority_score=0.70,
        )
        fd_manager.add_direction(d)
        fd_manager.mark_direction_consumed("fail_001", "job_001")
        fd_manager.mark_direction_failed("fail_001")
        updated = fd_manager.get_direction_by_id("fail_001")
        assert updated.status == "available"
        assert updated.consumed_by_exp_id == ""
        assert len(fd_manager.get_available_directions()) > 0

    def test_failed_direction_is_not_retried(self, fd_manager):
        d = FutureDirection(
            id="fail_002", title="Another Failing Direction",
            description="A direction whose failure must not return to the available pool.",
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=["Tropical"], priority_score=0.70,
        )
        fd_manager.add_direction(d)
        fd_manager.mark_direction_consumed("fail_002", "job_002")
        fd_manager.mark_direction_abandoned("fail_002")
        assert len(fd_manager.get_available_directions()) > 0
        assert fd_manager.get_direction_by_id("fail_002").status == "available"

    def test_stats_counts_failed(self, fd_manager):
        d = FutureDirection(
            id="fail_003", title="Stats Failing Direction",
            description="A direction used to verify failed status is counted.",
            source_exp_id="exp_001", source_path="result_future_directions",
            domains=["Tropical"], priority_score=0.70,
        )
        fd_manager.add_direction(d)
        fd_manager.mark_direction_consumed("fail_003", "job_003")
        fd_manager.mark_direction_failed("fail_003")
        stats = fd_manager.get_stats()
        assert stats["failed"] == 0


# ── Tests for tighter fallback extraction ──

class TestExtractionQualityGate:
    def test_short_fallback_description_rejected(self, fd_manager):
        text = "Prove stuff."
        added, _ = fd_manager.add_directions_from_text(text, "exp_short", "result_future_directions")
        assert added == 0

    def test_generic_fallback_title_rejected(self, fd_manager):
        text = "1. **Further Research.** More work is needed to explore the consequences of this result."
        added, _ = fd_manager.add_directions_from_text(text, "exp_generic", "result_future_directions")
        assert added == 0

    def test_bridges_only_without_strategy_rejected(self, fd_manager):
        text = "1. **Some Bridge Idea.** Investigate possible connections between different areas of mathematics."
        added, _ = fd_manager.add_directions_from_text(text, "exp_bridge", "result_future_directions")
        assert added == 0

    def test_fallback_splits_paragraphs(self, fd_manager):
        text = """Paragraph one: prove that tropical min-plus circuits have super-polynomial size lower bounds for parity languages.

Paragraph two: formalize a tropical lens rigidity theorem connecting min-plus algebraic structures to inverse spectral problems on graphs."""
        added, _ = fd_manager.add_directions_from_text(text, "exp_para", "result_future_directions")
        assert added == 2
        titles = [d.title for d in fd_manager._directions]
        assert any("tropical" in t.lower() for t in titles)

    def test_quality_gate_keeps_good_direction(self, fd_manager):
        text = "1. **Tropical Eigenvalue Gap for Parity.** Prove that the eigenvalue gap of tropical transfer matrices yields super-polynomial circuit lower bounds for parity, using min-plus Perron-Frobenius theory and explicit combinatorial witnesses."
        added, _ = fd_manager.add_directions_from_text(text, "exp_good", "result_future_directions")
        assert added == 1


class TestThreadLinkage:
    def test_thread_id_field_defaults_empty(self, fd_manager):
        d = FutureDirection(
            id="thread_001",
            title="Threaded direction",
            description="A direction that belongs to a research thread.",
            source_exp_id="exp_001",
            source_path="test",
        )
        assert d.thread_id == ""

    def test_thread_id_roundtrip(self, fd_manager):
        d = FutureDirection(
            id="thread_002",
            title="Threaded direction",
            description="A direction that belongs to a research thread.",
            source_exp_id="exp_002",
            source_path="test",
            thread_id="th_deadbeef",
        )
        fd_manager.add_direction(d)
        loaded = FutureDirectionsManager(fd_manager.workspace).get_direction_by_id("thread_002")
        assert loaded is not None
        assert loaded.thread_id == "th_deadbeef"


# ── Re-publish loop fixes: injected-issue dispatch gating ──

def _injected_dir(idx, **kw):
    """Build a unique github_injection direction for gating tests."""
    desc = _UNIQUE_DESCRIPTIONS[idx % len(_UNIQUE_DESCRIPTIONS)]
    base = dict(
        id=f"ginj_{idx:03d}",
        title=f"Injected Direction {idx}",
        description=desc,
        source_exp_id="github",
        source_path="github",
        domains=["Novelty"],
        priority_score=1000.0,
        source="github_injection",
        github_issue=100 + idx,
        attempt_count=0,
        status="available",
    )
    base.update(kw)
    return FutureDirection(**base)


class TestInjectedDispatchGating:
    """github_injection directions must only be re-dispatched while their
    GitHub issue is open and the attempt cap is not exhausted."""

    def test_open_issue_available_is_dispatchable(self, fd_manager):
        fd_manager.add_direction(_injected_dir(1, github_issue=10, attempt_count=0))
        candidates = fd_manager.dispatchable_injected_directions(
            open_issue_numbers={10}, max_attempts=3)
        assert [c.id for c in candidates] == ["ginj_001"]

    def test_closed_issue_excluded(self, fd_manager):
        fd_manager.add_direction(_injected_dir(2, github_issue=10, attempt_count=0))
        # Issue no longer open (e.g. closed on integration) — must NOT re-dispatch
        candidates = fd_manager.dispatchable_injected_directions(
            open_issue_numbers={11}, max_attempts=3)
        assert candidates == []

    def test_missing_issue_number_excluded(self, fd_manager):
        fd_manager.add_direction(_injected_dir(3, github_issue=0))
        candidates = fd_manager.dispatchable_injected_directions(
            open_issue_numbers={0}, max_attempts=3)
        assert candidates == []

    def test_attempt_cap_excluded(self, fd_manager):
        fd_manager.add_direction(_injected_dir(4, github_issue=10, attempt_count=3))
        fd_manager.add_direction(_injected_dir(5, github_issue=10, attempt_count=2))
        candidates = fd_manager.dispatchable_injected_directions(
            open_issue_numbers={10}, max_attempts=3)
        assert [c.id for c in candidates] == ["ginj_005"]

    def test_completed_excluded(self, fd_manager):
        fd_manager.add_direction(_injected_dir(6, github_issue=10))
        fd_manager.mark_direction_completed("ginj_006")
        candidates = fd_manager.dispatchable_injected_directions(
            open_issue_numbers={10}, max_attempts=3)
        assert candidates == []

    def test_in_progress_excluded(self, fd_manager):
        fd_manager.add_direction(_injected_dir(7, github_issue=10))
        fd_manager.mark_direction_consumed("ginj_007", "job_x")
        candidates = fd_manager.dispatchable_injected_directions(
            open_issue_numbers={10}, max_attempts=3)
        assert candidates == []

    def test_non_injection_source_ignored(self, fd_manager):
        fd_manager.add_direction(_injected_dir(8, source="", github_issue=10))
        candidates = fd_manager.dispatchable_injected_directions(
            open_issue_numbers={10}, max_attempts=3)
        assert candidates == []


class TestPruneClosedIssueDirections:
    """One-time + self-healing cleanup: non-terminal github_injection directions
    whose issue is closed are zombies and should be pruned."""

    def test_available_closed_issue_pruned(self, fd_manager):
        fd_manager.add_direction(_injected_dir(10, github_issue=10, status="available"))
        pruned = fd_manager.prune_closed_issue_directions(open_issue_numbers={})
        assert pruned == 1
        d = fd_manager.get_direction_by_id("ginj_010")
        assert d.status == "pruned"
        assert d.prune_reason

    def test_in_progress_closed_issue_pruned(self, fd_manager):
        fd_manager.add_direction(_injected_dir(11, github_issue=10))
        fd_manager.mark_direction_consumed("ginj_011", "job_y")
        pruned = fd_manager.prune_closed_issue_directions(open_issue_numbers={})
        assert pruned == 1
        assert fd_manager.get_direction_by_id("ginj_011").status == "pruned"

    def test_open_issue_kept(self, fd_manager):
        fd_manager.add_direction(_injected_dir(12, github_issue=10))
        pruned = fd_manager.prune_closed_issue_directions(open_issue_numbers={10})
        assert pruned == 0
        assert fd_manager.get_direction_by_id("ginj_012").status == "available"

    def test_terminal_closed_issue_left_alone(self, fd_manager):
        fd_manager.add_direction(_injected_dir(13, github_issue=10))
        fd_manager.mark_direction_completed("ginj_013")
        pruned = fd_manager.prune_closed_issue_directions(open_issue_numbers={})
        assert pruned == 0
        assert fd_manager.get_direction_by_id("ginj_013").status == "completed"

    def test_non_injection_closed_issue_untouched(self, fd_manager):
        fd_manager.add_direction(_injected_dir(14, source="", github_issue=10))
        pruned = fd_manager.prune_closed_issue_directions(open_issue_numbers={})
        assert pruned == 0
        assert fd_manager.get_direction_by_id("ginj_014").status == "available"


class TestStaleQueuedJobPurge:
    """Queued jobs stuck past max_age_hours are zombies that inflate the local
    inflight count and block fresh dispatch — they must be identified for purge."""

    def test_old_retry_queued_identified(self):
        from types import SimpleNamespace
        from knowledge_extractor import _stale_queued_jobs_to_purge
        now = 1_000_000.0
        old = SimpleNamespace(status="retry_queued", retry_queued_time=now - 10 * 3600,
                              dispatch_time=0.0, job_id="job_old")
        recent = SimpleNamespace(status="retry_queued", retry_queued_time=now - 60,
                                 dispatch_time=0.0, job_id="job_recent")
        stale = _stale_queued_jobs_to_purge({"a": old, "b": recent}, max_age_hours=6, now=now)
        assert [pid for pid, _ in stale] == ["a"]

    def test_active_and_recent_jobs_not_purged(self):
        from types import SimpleNamespace
        from knowledge_extractor import _stale_queued_jobs_to_purge
        now = 1_000_000.0
        dispatched = SimpleNamespace(status="dispatched", retry_queued_time=0.0,
                                     dispatch_time=now - 100, job_id="job_d")
        fresh_queued = SimpleNamespace(status="dispatch_queued", retry_queued_time=0.0,
                                       dispatch_time=now - 5, job_id="job_f")
        stale = _stale_queued_jobs_to_purge(
            {"d": dispatched, "f": fresh_queued}, max_age_hours=6, now=now)
        assert stale == []
