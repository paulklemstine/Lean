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

    def test_mark_abandoned_resets_to_available(self, fd_manager, sample_direction):
        fd_manager.add_direction(sample_direction)
        fd_manager.mark_direction_consumed("test_001", "exp_001")
        fd_manager.mark_direction_abandoned("test_001")
        d = fd_manager._directions[0]
        assert d.status == "available"
        assert d.consumed_by_exp_id == ""


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
        added = fd_manager.add_directions_from_text(text, "exp_001", "result_future_directions")
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
        added = fd_manager.add_directions_from_text(text, "exp_002", "result_future_directions")
        assert added == 2

    def test_parse_bullet_items(self, fd_manager):
        text = """
- Prove that idempotent semiring closures yield computable upper bounds on Kolmogorov complexity, connecting closure operators to algorithmic information theory with explicit constructions
- Show that the tropical value iteration for zero-sum games converges in at most n steps for n-player games, establishing tropical Nash equilibria as fixed points of min-plus operators
"""
        fd_manager._directions = []
        added = fd_manager.add_directions_from_text(text, "exp_003", "result_future_directions")
        assert added == 2

    def test_parse_empty_text(self, fd_manager):
        added = fd_manager.add_directions_from_text("", "exp_004", "result_future_directions")
        assert added == 0

    def test_parse_short_text_no_match(self, fd_manager):
        added = fd_manager.add_directions_from_text("No structured directions here.", "exp_005", "result")
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
        added = fd_manager.add_directions_from_text(new_text, job_id, "result_future_directions")
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
        assert result["pruned_count"] == 5
        assert result["kept_auto"] == 10
        available = fd_manager.get_available_directions()
        assert len(available) == 10

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
        assert result["pruned_count"] == max(0, before - 5)
        assert len(fd_manager._directions) == before  # nothing actually pruned
        assert len(fd_manager._pruned) == 0

    def test_pruned_directions_archived(self, fd_manager):
        for i in range(10):
            fd_manager.add_direction(_make_auto_dir(i))
        fd_manager.prune_directions(cap=5)
        assert len(fd_manager._pruned) == 5
        assert all(d.status == "pruned" for d in fd_manager._pruned)
        assert all(d.prune_reason == "quality_below_threshold" for d in fd_manager._pruned)
        assert all(d.pruned_at != "" for d in fd_manager._pruned)

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
        assert result["pruned_count"] >= 1
        # The low-quality one should be pruned
        pruned_ids = result["pruned_ids"]
        assert "low_001" in pruned_ids

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
        fd_manager.prune_directions(cap=5)
        assert len(fd_manager._pruned) == 5

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

class TestAutoPrune:
    def test_auto_prune_triggers_on_add(self, fd_manager):
        # Add seed direction to keep
        fd_manager.add_direction(FutureDirection(
            id="seed_001", title="Seed Direction",
            description="A" * 200,
            source_exp_id="seed", source_path="seed:manual_v2",
            domains=["Tropical"], priority_score=0.90,
        ))
        # Add auto-parsed directions up to cap
        from unittest.mock import patch
        original_cap = 5
        for i in range(original_cap + 5):
            fd_manager.add_direction(FutureDirection(
                id=f"auto_{i:03d}", title=f"Auto Direction {i}",
                description=f"Exploring novel approaches to tropical mathematics and idempotent algebra topic number {i} for advanced research.",
                source_exp_id="exp_001", source_path="result_future_directions",
                domains=["Tropical"], priority_score=0.70,
            ))
        # Auto-prune should have been triggered; list should be manageable
        assert len(fd_manager._directions) <= original_cap + 1  # +1 for seed


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
        assert stats["pruned"] == 3