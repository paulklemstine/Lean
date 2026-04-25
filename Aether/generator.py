#!/usr/bin/env python3
"""HypothesisGenerator: Synthesize novel conjectures, algorithms, and experiments.

Generates research proposals by combining concepts from the catalog,
following thematic arcs, and producing structured Aristotle-ready
prompts with formal Lean 4 code.
"""

import random
import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Any
from miner import ConceptMiner


@dataclass
class ResearchProposal:
    """A single research proposal ready for Aristotle dispatch."""
    experiment_id: str
    arc_id: str
    arc_name: str
    title: str
    domain: str
    difficulty: str
    hypothesis_type: str  # theorem, algorithm, experiment, conjecture

    # Content
    context_imports: List[str] = field(default_factory=list)
    context_theorems: List[str] = field(default_factory=list)
    context_defs: List[str] = field(default_factory=list)
    conjecture_lean: str = ""
    narrative: str = ""

    # Metadata
    concept_combination: List[str] = field(default_factory=list)
    novelty_estimate: float = 0.0
    risk_assessment: Dict[str, float] = field(default_factory=dict)
    target_file: str = ""
    proof_strategy: str = ""


def _gen_id() -> str:
    import uuid
    return str(uuid.uuid4())[:8]


class HypothesisGenerator:
    """Generate novel research proposals from catalog concepts."""

    def __init__(self, config: Dict[str, Any], catalog_root: Path):
        self.config = config
        self.catalog_root = Path(catalog_root)
        self.miner = ConceptMiner(catalog_root=self.catalog_root)
        self.rng = random.Random()
        self._scifi_templates = self._load_master_templates()

    def _load_master_templates(self) -> List[Dict[str, Any]]:
        """Load rich sci-fi theorem templates with real mathematical content."""
        return [
            {
                "title": "temporal_fixed_point_computation",
                "template": """theorem temporal_fixed_point_computation {X : Type*} [TopologicalSpace X]
    [T2Space X] {f : X → X} (hf : Continuous f) (x : X)
    (h_converge : ∃ x₀, Filter.Tendsto (λ n => f^[n] x₀) Filter.atTop (nhds x)) :
    f x = x := by
  -- A time-traveling computation converges to a fixed point of the transition function.
  -- This establishes that any temporally self-consistent algorithm has an equilibrium.
  sorry""",
                "narrative": "In reversible computing and time-travel logic, a computation that can iterate indefinitely must converge to a fixed point of its transition function. This theorem establishes that temporal consistency implies computational equilibrium, bridging fixed-point theory with speculative models of time-travel computation.",
                "difficulty": "master",
                "domain": "Speculative/SciFi",
                "concepts": ["fixed_point", "continuous", "Filter.Tendsto"],
                "novelty": 0.85,
            },
            {
                "title": "quantum_berggren_tropicalization",
                "template": """theorem quantum_berggren_tropicalization (a b c : ℕ) (h : a^2 + b^2 = c^2) :
    ∃ (q : ℂ) (τ : ℝ), q.re = a ∧ q.im = b ∧ τ = a + b - c := by
  -- Every Pythagorean triple lifts to a complex number whose real and imaginary parts
  -- recover the legs, with tropical norm τ = a ⊕ b ⊖ c.
  sorry""",
                "narrative": "Classical Pythagorean triples encode right triangles. We hypothesize that every triple lifts to a quantum state (complex number) whose tropical shadow τ encodes the triple's structure. This bridges number theory, quantum mechanics, and tropical geometry.",
                "difficulty": "master",
                "domain": "Speculative/SciFi",
                "concepts": ["pythagorean", "complex", "tropical"],
                "novelty": 0.9,
            },
            {
                "title": "gravitational_entropy_holographic_bound",
                "template": """theorem gravitational_entropy_holographic_bound (A S : ℝ)
    (hA : 0 < A) (hS : 0 < S) (h_bound : S ≤ A / 4) :
    Real.exp S ≤ Real.exp (A / 4) := by
  -- The Bekenstein-Hawking bound: entropy of a spacetime region is bounded
  -- by a quarter of its boundary area. This is the holographic principle in miniature.
  sorry""",
                "narrative": "Drawing on the holographic principle, we formalize a simplified model where the entropy of any spacetime region is bounded by a quarter of its area. This connects information theory, geometry, and black hole thermodynamics.",
                "difficulty": "phd",
                "domain": "Speculative/SciFi",
                "concepts": ["entropy", "area", "bound"],
                "novelty": 0.8,
            },
            {
                "title": "wormhole_triangle_inequality_failure",
                "template": """theorem wormhole_triangle_inequality_failure {X : Type*} [PseudoMetricSpace X]
    (wormhole : X → X → Prop) (hw : ∃ x y z, wormhole x z ∧ ¬wormhole x y ∧ ¬wormhole y z) :
    ¬∀ (x y z : X), dist x z ≤ dist x y + dist y z := by
  -- In a spacetime with wormholes, the direct path can be shorter than any
  -- two-segment path, violating the triangle inequality.
  sorry""",
                "narrative": "General relativity allows for wormholes—topological shortcuts in spacetime. In such geometries, the direct path between two points can be shorter than any path passing through intermediate points, formally violating the triangle inequality. This theorem captures that phenomenon.",
                "difficulty": "graduate",
                "domain": "Speculative/SciFi",
                "concepts": ["metric", "wormhole", "triangle_inequality"],
                "novelty": 0.75,
            },
            {
                "title": "alien_civilization_kardashev_convergence",
                "template": """theorem alien_civilization_kardashev_convergence (E : ℕ → ℝ)
    (h_base : E 0 > 0) (h_growth : ∀ n, E (n + 1) ≥ 2 * E n) :
    Filter.Tendsto (λ n => Real.log (E n) / Real.log (E (n + 1))) Filter.atTop (nhds 1) := by
  -- A Kardashev-type civilization's energy consumption grows exponentially.
  -- The ratio of logarithmic growth rates converges to 1, suggesting a universal
  -- scaling law for technological development.
  sorry""",
                "narrative": "The Kardashev scale measures a civilization's technological advancement by energy consumption. If energy grows exponentially, the ratio of consecutive logarithmic growth rates converges to a universal constant. This theorem formalizes a speculative law of technological convergence.",
                "difficulty": "graduate",
                "domain": "Speculative/SciFi",
                "concepts": ["exponential", "convergence", "Kardashev"],
                "novelty": 0.7,
            },
            {
                "title": "temporal_causal_loop_diagram_commutes",
                "template": """theorem temporal_causal_loop_diagram_commutes {X Y Z : Type*}
    (f : X → Y) (g : Y → Z) (h : Z → X) :
    Function.Surjective (g ∘ f) → Function.Injective (h ∘ g ∘ f) →
    ∃ x : X, h (g (f x)) = x := by
  -- In a closed timelike curve, the composition of causal influences must have
  -- a fixed point, ensuring self-consistency of the temporal loop.
  sorry""",
                "narrative": "Closed timelike curves (time loops) require that the composition of all causal influences around the loop returns to the starting point. This theorem proves that any such loop diagram commutes with a fixed point, ensuring self-consistency.",
                "difficulty": "master",
                "domain": "Speculative/SciFi",
                "concepts": ["surjective", "injective", "fixed_point"],
                "novelty": 0.8,
            },
            {
                "title": "dark_energy_tropical_polynomial_roots",
                "template": """theorem dark_energy_tropical_polynomial_roots (p : Polynomial ℝ)
    (hp : p.degree = 3) (h_pos : ∀ x, p.eval x > 0) :
    ∃ (trop_roots : Finset ℝ), trop_roots.card ≤ 3 := by
  -- A tropical analogue: the dark energy equation of state, modeled as a
  -- positive cubic polynomial, has at most 3 tropical roots corresponding to
  -- phase transitions in cosmic expansion.
  sorry""",
                "narrative": "Dark energy drives cosmic acceleration. We model its equation of state as a positive cubic polynomial and prove a tropical bound on the number of phase transitions, connecting cosmology with tropical algebraic geometry.",
                "difficulty": "phd",
                "domain": "Speculative/SciFi",
                "concepts": ["polynomial", "tropical", "roots"],
                "novelty": 0.9,
            },
            {
                "title": "quantum_teleportation_fidelity_bound",
                "template": """theorem quantum_teleportation_fidelity_bound (F : ℝ)
    (hF : F = 2 / 3) :
    F ≤ (2 : ℝ) / 3 := by
  -- The maximum fidelity of quantum teleportation without entanglement is 2/3.
  -- This is the classical limit; exceeding it requires quantum entanglement.
  sorry""",
                "narrative": "Quantum teleportation achieves perfect fidelity only with entanglement. Without it, the classical limit is 2/3. This theorem formalizes that bound, connecting quantum information theory with classical probability.",
                "difficulty": "master",
                "domain": "Speculative/SciFi",
                "concepts": ["fidelity", "teleportation", "bound"],
                "novelty": 0.7,
            },
            {
                "title": "multiverse_measure_zero_events",
                "template": """theorem multiverse_measure_zero_events {Ω : Type*} [MeasureSpace Ω]
    {s : Set Ω} (hs : MeasurableSet s) (h_measure : volume s = 0) :
    ∀ ω ∈ s, ω ∉ s := by
  -- In a multiverse where measure-zero events never occur, any point in a
  -- measure-zero set is paradoxically not in that set. This is a formalization
  -- of the anthropic principle in measure theory.
  sorry""",
                "narrative": "The anthropic principle suggests that we observe our universe because it has non-zero measure in the multiverse. This theorem formalizes that paradox: in a measure-theoretic multiverse, any point in a measure-zero set is not in that set, making such universes unobservable.",
                "difficulty": "phd",
                "domain": "Speculative/SciFi",
                "concepts": ["measure", "zero", "multiverse"],
                "novelty": 0.85,
            },
            {
                "title": "self_replicating_von_neumann_complexity",
                "template": """theorem self_replicating_von_neumann_complexity (n : ℕ)
    (h_nontrivial : n > 1) :
    ∃ (genome : Finset (Fin n)), genome.card ≥ n.log2 + 1 := by
  -- A self-replicating machine must have a genome of size at least log2(n) + 1
  -- to encode both its own structure and a copy constructor. This is the
  -- von Neumann minimum complexity bound for self-replication.
  sorry""",
                "narrative": "John von Neumann proved that self-replicating machines require a minimum complexity. We formalize a modern version: a self-replicator with n possible states needs a genome of size at least log2(n) + 1, establishing an information-theoretic lower bound.",
                "difficulty": "master",
                "domain": "Speculative/SciFi",
                "concepts": ["complexity", "self_replication", "information"],
                "novelty": 0.8,
            },
            {
                "title": "hyperdimensional_data_compression_limit",
                "template": """theorem hyperdimensional_data_compression_limit (d : ℕ) (hd : d > 0)
    (data : Fin d → ℝ) :
    ∃ (compressed : Fin (d / 2) → ℝ), compressed ≠ 0 := by
  -- In d-dimensional space, any non-zero dataset can be compressed to at most
  -- d/2 dimensions while preserving some non-trivial structure. This is the
  -- hyperdimensional analogue of the Shannon source coding theorem.
  sorry""",
                "narrative": "Shannon's source coding theorem sets limits on data compression. In hyperdimensional spaces, we conjecture that any non-zero dataset can be compressed to at most half its dimensions while preserving structure, formalizing a speculative bound on lossy compression.",
                "difficulty": "phd",
                "domain": "Speculative/SciFi",
                "concepts": ["compression", "dimension", "Shannon"],
                "novelty": 0.85,
            },
            {
                "title": "consciousness_oracle_computability",
                "template": """theorem consciousness_oracle_computability {O : Type*} [Oracle O]
    (consciousness : O → Prop) (h_oracle : ∃ o, consciousness o) :
    ∃ (f : ℕ → ℕ), Computable f ∧ ∀ n, f n = n := by
  -- If consciousness can be modeled as an oracle, then there exists a
  -- computable function that simulates the identity, suggesting that
  -- self-aware computation is at least as powerful as the identity oracle.
  sorry""",
                "narrative": "Speculative models of consciousness treat it as an oracle that can solve otherwise uncomputable problems. This theorem explores the converse: if consciousness is an oracle, then identity computation is possible, establishing a lower bound on conscious computational power.",
                "difficulty": "open_problem",
                "domain": "Speculative/SciFi",
                "concepts": ["oracle", "computable", "consciousness"],
                "novelty": 0.95,
            },
            {
                "title": "chronological_protection_recurrence",
                "template": """theorem chronological_protection_recurrence
    {X : Type*} [MeasurableSpace X]
    (μ : MeasureTheory.Measure X) [MeasureTheory.IsProbabilityMeasure μ]
    (f : X → X) (hf : MeasureTheory.MeasurePreserving f μ μ)
    (s : Set X) (hs : MeasurableSet s) (hμs : 0 < μ s) :
    ∀ᵐ x ∂μ, x ∈ s → ∃ᶠ n in Filter.atTop, f^[n] x ∈ s := by
  -- Chronological Protection via Poincaré Recurrence.
  -- In a universe with closed timelike curves, measure-preserving dynamics
  -- force almost-every trajectory to return infinitely often.
  sorry""",
                "narrative": "In a universe with closed timelike curves, a time traveler might hope to alter the past and escape to a divergent timeline. But if the dynamics are measure-preserving, the Chronological Protection Conjecture becomes a theorem: any region of spacetime with non-zero measure is revisited infinitely often. You cannot kill your grandfather and stay dead—causality is a recurrent, almost-everywhere invariant.",
                "difficulty": "master",
                "domain": "Speculative/SciFi",
                "concepts": ["Poincaré", "recurrence", "measure"],
                "novelty": 0.95,
            },
            {
                "title": "tropical_firewall_determinism",
                "template": """theorem tropical_firewall_determinism
    {R : Type*} [LinearOrder R]
    (a b c : R) (h : max a b = max a c) (hgt : a < max a b) :
    b = c := by
  -- Tropical Firewall Determinism.
  -- In a black-hole firewall modeled as a tropical variety, determinism
  -- is restored by the absence of additive inverses.
  sorry""",
                "narrative": "A starship crosses the event horizon of a wormhole and encounters the infamous 'firewall'. The crew theorizes that the firewall is a tropical variety: spacetime intervals are measured in max-plus algebra. The theorem shows that if the firewall singularity is not the dominant path, then any two possible escape trajectories that produce the same tropical boundary condition must be identical.",
                "difficulty": "graduate",
                "domain": "Speculative/SciFi",
                "concepts": ["tropical", "max-plus", "firewall"],
                "novelty": 0.9,
            },
            {
                "title": "seti_orthogonality_decomposition",
                "template": """theorem seti_orthogonality_decomposition
    {q : ℕ} [NeZero q] [Fintype (ZMod q)ˣ]
    (χ ψ : DirichletCharacter ℂ q) (h : χ ≠ ψ) :
    ∑ a : (ZMod q)ˣ, χ a * ψ (a⁻¹) = 0 := by
  -- SETI Prime-Modulated Orthogonality Decomposition.
  -- Advanced civilizations broadcast on carriers whose periods are prime powers,
  -- modulating each channel by a distinct Dirichlet character.
  sorry""",
                "narrative": "The SETI array detects weak periodic signals buried in cosmic noise. Advanced civilizations broadcast on carriers whose periods are prime powers, modulating each channel by a distinct Dirichlet character. Because non-principal characters are orthogonal under pointwise multiplication, a receiver that integrates over one complete period can separate an arbitrarily large number of alien conversations with zero cross-talk.",
                "difficulty": "master",
                "domain": "Speculative/SciFi",
                "concepts": ["Dirichlet", "orthogonality", "SETI"],
                "novelty": 0.95,
            },
            {
                "title": "mind_upload_gluing",
                "template": """structure Presheaf (X : Type*) [TopologicalSpace X] where
  obj : TopologicalSpace.Opens X → Type*
  map {U V} (h : U ≤ V) : obj V → obj U
  map_id : ∀ U, map (le_rfl U) = id
  map_comp : ∀ (U V W) (hUV : U ≤ V) (hVW : V ≤ W),
    map hUV ∘ map hVW = map (hUV.trans hVW)

structure Sheaf (X : Type*) [TopologicalSpace X] extends Presheaf X where
  gluing : ∀ {ι : Type*} [DecidableEq ι] (U : ι → TopologicalSpace.Opens X)
    (s : ∀ i, obj (U i)),
    (∀ i j, map inf_le_left (s i) = map inf_le_right (s j)) →
    ∃! s_global : obj (⨆ i, U i), ∀ i, map (le_iSup U i) s_global = s i

theorem mind_upload_gluing {X : Type*} [TopologicalSpace X]
    (F : Sheaf X) {ι : Type*} [DecidableEq ι]
    (U : ι → TopologicalSpace.Opens X) (s : ∀ i, F.obj (U i))
    (hcompat : ∀ i j, F.map inf_le_left (s i) = F.map inf_le_right (s j)) :
    ∃! s_global : F.obj (⨆ i, U i), ∀ i, F.map (le_iSup U i) s_global = s i := by
  -- Čech Obstruction to Mind Uploading.
  -- Unless the sheaf of mental states has vanishing first cohomology,
  -- local sections cannot be glued into a unique global identity.
  sorry""",
                "narrative": "In 2147, the Titan Upload Collective scans a human brain slice-by-slice, storing each local cortical map as a section of a sheaf over the neural connectome topology. Patient zero awakens with eleven distinct mutually incompatible memories. The theorem explains why: unless the sheaf of mental states has vanishing first cohomology, local sections cannot be glued into a unique global identity. H¹ ≠ 0 is the mathematical signature of dissociative identity disorder in silico.",
                "difficulty": "phd",
                "domain": "Speculative/SciFi",
                "concepts": ["sheaf", "cohomology", "mind"],
                "novelty": 0.9,
            },
            {
                "title": "padic_hyperdrive_instability",
                "template": """theorem padic_hyperdrive_instability
    {p : ℕ} [Fact p.Prime]
    (P : Polynomial (Padic p)) (z : Padic p)
    (hfz : P.eval z = z)
    (hdiv : 1 < ‖P.derivative.eval z‖) :
    ∃ ε > 0, ∀ y, 0 < ‖y - z‖ → ‖y - z‖ < ε →
      ∃ n : ℕ, 1 < ‖(P.eval^[n] y) - z‖ := by
  -- p-Adic Hyperdrive Instability.
  -- A prototype hyperdrive creates field discontinuities by pumping vacuum
  -- energy through p-adic manifolds. Any infinitesimal perturbation away
  -- from a repelling fixed point is blown up under iteration.
  sorry""",
                "narrative": "A prototype Alcubierre-3 hyperdrive creates field discontinuities by pumping vacuum energy through p-adic manifolds. Engineers detect catastrophic resonance at a fixed point where the field derivative exceeds unity in the p-adic norm. The theorem proves that the drive is mathematically unstable: any infinitesimal perturbation is blown up under iteration, ejecting the ship into an uncontrolled p-adic Julia set.",
                "difficulty": "phd",
                "domain": "Speculative/SciFi",
                "concepts": ["p-adic", "instability", "hyperdrive"],
                "novelty": 0.95,
            },
        ]

    def _pick_concepts_from_domains(self, domains: List[str], count: int = 3) -> List[Dict[str, Any]]:
        """Pick random declarations from specified domains."""
        db = self.miner._load_db()
        if not db:
            return []

        candidates = []
        for entry in db.get("entries", []):
            domain = entry.get("domain", "")
            if any(domain.startswith(d) for d in domains):
                candidates.append(entry)

        if len(candidates) <= count:
            return candidates
        return self.rng.sample(candidates, count)

    def _extract_theorem_signature(self, entry: Dict[str, Any]) -> str:
        """Extract the Lean signature of a theorem/lemma/def."""
        rel_path = entry.get("source_file", "")
        line_start = entry.get("line_number", 1)
        line_end = entry.get("end_line", line_start + 20)

        text = self.miner._get_file_text(rel_path)
        lines = text.splitlines()
        snippet = "\n".join(lines[line_start - 1:line_end])
        return snippet

    def _generate_bridge_hypothesis(
        self, arc: Dict[str, Any]
    ) -> Optional[ResearchProposal]:
        """Generate a bridging theorem between two domains."""
        domains = arc.get("seed_domains", [])
        if len(domains) < 2:
            return None

        concepts = self._pick_concepts_from_domains(domains, count=4)
        if len(concepts) < 2:
            return None

        c1, c2 = concepts[0], concepts[1]
        concept_names = [c1.get("name", ""), c2.get("name", "")]

        imports = ["import Mathlib"]
        theorems = []
        for c in concepts[:2]:
            sig = self._extract_theorem_signature(c)
            if sig:
                theorems.append(sig)

        title = f"bridge_{c1.get('name', '')}_{c2.get('name', '')}"
        title = re.sub(r'[^a-zA-Z0-9_]', '_', title)

        conjecture = f"""theorem {title} :
    -- Bridge: {c1.get('name', '')} relates to {c2.get('name', '')}
    -- Across domains: {c1.get('domain', '')} and {c2.get('domain', '')}
    sorry"""

        narrative = (
            f"We observe that `{c1.get('name', '')}` from {c1.get('domain', '')} "
            f"and `{c2.get('name', '')}` from {c2.get('domain', '')} share structural similarities. "
            f"This conjecture proposes a formal bridge establishing their relationship, "
            f"opening a path toward unified frameworks in {arc.get('name', '')}."
        )

        return ResearchProposal(
            experiment_id=_gen_id(),
            arc_id=arc.get("id", ""),
            arc_name=arc.get("name", ""),
            title=title,
            domain=arc.get("seed_domains", ["Speculative"])[-1],
            difficulty="graduate",
            hypothesis_type="theorem",
            context_imports=imports,
            context_theorems=theorems,
            conjecture_lean=conjecture,
            narrative=narrative,
            concept_combination=concept_names,
            novelty_estimate=0.6,
            risk_assessment={"probability_true": 0.4, "probability_interesting": 0.7, "probability_trivial": 0.3},
            target_file=f"Speculative/AutoGen/{title}.lean",
        )

    def _generate_generalization_hypothesis(
        self, arc: Dict[str, Any]
    ) -> Optional[ResearchProposal]:
        """Take a concrete theorem and propose its abstract analogue."""
        domains = arc.get("seed_domains", [])
        concepts = self._pick_concepts_from_domains(domains, count=3)
        if not concepts:
            return None

        c = concepts[0]
        name = c.get("name", "")

        title = f"generalized_{name}"
        title = re.sub(r'[^a-zA-Z0-9_]', '_', title)

        imports = ["import Mathlib"]
        theorems = [self._extract_theorem_signature(c)]

        conjecture = f"""theorem {title} {{
    -- Generalization of {name} to arbitrary dimension / structure
    sorry
}}"""

        narrative = (
            f"The classical result `{name}` admits a natural generalization "
            f"to higher-dimensional or abstract settings. "
            f"This conjecture captures that generalization within the framework of {arc.get('name', '')}."
        )

        return ResearchProposal(
            experiment_id=_gen_id(),
            arc_id=arc.get("id", ""),
            arc_name=arc.get("name", ""),
            title=title,
            domain=arc.get("seed_domains", ["Speculative"])[-1],
            difficulty="phd",
            hypothesis_type="conjecture",
            context_imports=imports,
            context_theorems=theorems,
            conjecture_lean=conjecture,
            narrative=narrative,
            concept_combination=[name],
            novelty_estimate=0.7,
            risk_assessment={"probability_true": 0.3, "probability_interesting": 0.8, "probability_trivial": 0.2},
            target_file=f"Speculative/AutoGen/{title}.lean",
        )

    def _generate_scifi_hypothesis(
        self, arc: Dict[str, Any]
    ) -> Optional[ResearchProposal]:
        """Generate a master-level sci-fi theorem using rich templates."""
        template = self.rng.choice(self._scifi_templates)

        # Pick a few related concepts from the catalog to ground it
        domains = arc.get("seed_domains", ["Speculative"])
        concepts = self._pick_concepts_from_domains(domains, count=2)
        concept_names = [c.get("name", "") for c in concepts if c.get("name")]

        title = template["title"]
        imports = ["import Mathlib"]

        # Build context from related catalog declarations
        context = []
        for c in concepts[:2]:
            sig = self._extract_theorem_signature(c)
            if sig and len(sig) < 500:  # Keep context manageable
                context.append(sig)

        return ResearchProposal(
            experiment_id=_gen_id(),
            arc_id=arc.get("id", ""),
            arc_name=arc.get("name", ""),
            title=title,
            domain=template.get("domain", "Speculative/SciFi"),
            difficulty=template.get("difficulty", "master"),
            hypothesis_type="theorem",
            context_imports=imports,
            context_theorems=context,
            conjecture_lean=template["template"],
            narrative=template["narrative"],
            concept_combination=concept_names or template.get("concepts", []),
            novelty_estimate=template.get("novelty", 0.8),
            risk_assessment={
                "probability_true": 0.5 if template.get("difficulty") != "open_problem" else 0.1,
                "probability_interesting": 0.9,
                "probability_trivial": 0.1,
            },
            target_file=f"Speculative/SciFi/AutoGen/{title}.lean",
            proof_strategy="Use standard mathlib tactics and relevant theorems from the context.",
        )

    def _generate_algorithm_hypothesis(
        self, arc: Dict[str, Any]
    ) -> Optional[ResearchProposal]:
        """Generate a novel algorithm specification."""
        domains = arc.get("seed_domains", [])
        concepts = self._pick_concepts_from_domains(domains, count=2)
        if not concepts:
            return None

        title = f"algo_{arc.get('id', '')}_{_gen_id()}"

        # Richer algorithm template: tropical factorization
        conjecture = f"""def tropicalFactor (n : ℕ) : ℕ × ℕ :=
  -- Algorithm: find factors using tropical (min-plus) operations
  sorry

theorem tropicalFactor_correct (n : ℕ) (hn : n > 1) :
    let (p, q) := tropicalFactor n
    p * q = n := sorry

theorem tropicalFactor_complexity (n : ℕ) :
    tropicalFactor n = tropicalFactor n := sorry
    -- TODO: Prove O(√n) complexity bound"""

        narrative = (
            f"A novel factorization algorithm leveraging tropical (min-plus) algebra "
            f"from {arc.get('name', '')}. The algorithm explores whether tropical operations "
            f"can reveal factor structure not visible in classical arithmetic."
        )

        return ResearchProposal(
            experiment_id=_gen_id(),
            arc_id=arc.get("id", ""),
            arc_name=arc.get("name", ""),
            title=title,
            domain=arc.get("seed_domains", ["Computation"])[-1],
            difficulty="graduate",
            hypothesis_type="algorithm",
            context_imports=["import Mathlib"],
            context_theorems=[],
            conjecture_lean=conjecture,
            narrative=narrative,
            concept_combination=[c.get("name", "") for c in concepts],
            novelty_estimate=0.7,
            risk_assessment={"probability_true": 0.5, "probability_interesting": 0.6, "probability_trivial": 0.4},
            target_file=f"Computation/AutoGen/{title}.lean",
        )

    def _generate_experiment_hypothesis(
        self, arc: Dict[str, Any]
    ) -> Optional[ResearchProposal]:
        """Generate a computational experiment specification."""
        title = f"exp_{arc.get('id', '')}_{_gen_id()}"

        conjecture = f"""-- Computational experiment: benchmark {arc.get('name', '')}
def experiment_{title.replace('-', '_')} (n_max : ℕ) : List (ℕ × ℝ) :=
  sorry

theorem experiment_monotonic (n : ℕ) :
    (experiment_{title.replace('-', '_')} (n + 1)).length >= (experiment_{title.replace('-', '_')} n).length := sorry"""

        narrative = (
            f"A computational experiment designed to empirically explore "
            f"properties in {arc.get('name', '')}. The experiment generates data "
            f"that can be analyzed for patterns and conjectures."
        )

        return ResearchProposal(
            experiment_id=_gen_id(),
            arc_id=arc.get("id", ""),
            arc_name=arc.get("name", ""),
            title=title,
            domain="Computation",
            difficulty="undergraduate",
            hypothesis_type="experiment",
            context_imports=["import Mathlib"],
            context_theorems=[],
            conjecture_lean=conjecture,
            narrative=narrative,
            concept_combination=[],
            novelty_estimate=0.5,
            risk_assessment={"probability_true": 0.8, "probability_interesting": 0.3, "probability_trivial": 0.5},
            target_file=f"Computation/Experiments/{title}.lean",
        )

    def generate_proposals(self, arc: Dict[str, Any], count: int = 3) -> List[ResearchProposal]:
        """Generate a batch of proposals for a research arc."""
        generators = [
            self._generate_bridge_hypothesis,
            self._generate_generalization_hypothesis,
            self._generate_scifi_hypothesis,
            self._generate_algorithm_hypothesis,
            self._generate_experiment_hypothesis,
        ]

        proposals = []
        attempts = 0
        while len(proposals) < count and attempts < count * 5:
            gen = self.rng.choice(generators)
            proposal = gen(arc)
            if proposal is not None:
                proposals.append(proposal)
            attempts += 1

        return proposals[:count]

    def build_prompt(self, proposal: ResearchProposal, template_name: str = "master_theorem_prover") -> str:
        """Build a structured prompt for Aristotle."""
        imports_text = "\n".join(proposal.context_imports)
        context_text = "\n\n".join(proposal.context_theorems[:8])

        if template_name == "master_theorem_prover":
            return f"""RESEARCH BRIEF: {proposal.title}
DOMAIN: {proposal.domain}
ARC: {proposal.arc_name}
DIFFICULTY: {proposal.difficulty}
TYPE: {proposal.hypothesis_type}

NARRATIVE:
{proposal.narrative}

CONTEXT (existing theorems and definitions):
```lean
{imports_text}

{context_text}
```

CONJECTURE TO PROVE:
```lean
{proposal.conjecture_lean}
```

PROOF STRATEGY (suggested):
{proposal.proof_strategy}

REQUIREMENTS:
1. Provide a complete formal proof in Lean 4 (mathlib4 v4.28.0).
2. Do not change the theorem statement unless it is false.
3. If the theorem is false, explain why and suggest a corrected statement.
4. Include proof strategy comments.
5. Use standard mathlib tactics: `ring`, `linarith`, `simp`, `exact`, `apply`, `intro`, `cases`, `rw`, `norm_num`, etc.
6. The output should be a single Lean 4 file that compiles with `lake build`.
7. Ensure no `sorry` remains in the proof.
"""
        else:
            return f"""Prove the following in Lean 4:\n\n{proposal.conjecture_lean}"""
