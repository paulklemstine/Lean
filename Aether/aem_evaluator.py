#!/usr/bin/env python3
"""AEM Evaluator: Aristotle Evaluation Matrix for mathematical research quality.

Scores generated mathematics across five core pillars:
1. Rigor & Sophistication (Is it World-class?)
2. Mathematical Aesthetic (Is it Interesting?)
3. Structural Utility (Is it Useful?)
4. Paradigm Originality (Is it New/Novel?)
5. Transformative Impact (Does it have Wonderful Applications?)

Each scored 0-10, max total 50.
"""

import re
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class AEMScore:
    """Single AEM evaluation result."""
    rigor: float = 0.0
    aesthetic: float = 0.0
    utility: float = 0.0
    originality: float = 0.0
    impact: float = 0.0
    total: float = 0.0
    details: Dict[str, str] = field(default_factory=dict)

    def __post_init__(self):
        self.total = self.rigor + self.aesthetic + self.utility + self.originality + self.impact

    def category(self) -> str:
        if self.total <= 15:
            return "Automated Drone"
        elif self.total <= 30:
            return "Graduate Researcher"
        elif self.total <= 42:
            return "Tenured Professor"
        else:
            return "Historical Master"

    def to_dict(self) -> Dict:
        return {
            "rigor": round(self.rigor, 2),
            "aesthetic": round(self.aesthetic, 2),
            "utility": round(self.utility, 2),
            "originality": round(self.originality, 2),
            "impact": round(self.impact, 2),
            "total": round(self.total, 2),
            "category": self.category(),
            "details": self.details,
        }


class AEMEvaluator:
    """Evaluate mathematical research outputs against the Aristotle Evaluation Matrix."""

    # Domain pairs that represent genuine cross-domain bridges
    CROSS_DOMAIN_BRIDGES = {
        frozenset({"Tropical", "MachineLearning"}),
        frozenset({"Tropical", "Cryptography"}),
        frozenset({"Tropical", "Algebra"}),
        frozenset({"MachineLearning", "Physics"}),
        frozenset({"Cryptography", "Pythagorean"}),
        frozenset({"EML", "Tropical"}),
        frozenset({"EML", "Physics"}),
        frozenset({"Logic", "Computation"}),
        frozenset({"Topology", "MachineLearning"}),
        frozenset({"Algebra", "Physics"}),
        frozenset({"Pythagorean", "Physics"}),
        frozenset({"Algebra", "Cryptography"}),
        # Extended bridges for richer cross-domain detection
        frozenset({"Tropical", "Physics"}),
        frozenset({"Tropical", "NumberTheory"}),
        frozenset({"Tropical", "InformationTheory"}),
        frozenset({"EML", "MachineLearning"}),
        frozenset({"EML", "Algebra"}),
        frozenset({"EML", "Logic"}),
        frozenset({"InformationTheory", "MachineLearning"}),
        frozenset({"InformationTheory", "Physics"}),
        frozenset({"Algebra", "MachineLearning"}),
        frozenset({"Algebra", "NumberTheory"}),
        frozenset({"NumberTheory", "Cryptography"}),
        frozenset({"NumberTheory", "Physics"}),
        frozenset({"Topology", "Physics"}),
        frozenset({"Topology", "Algebra"}),
        frozenset({"Logic", "Algebra"}),
        frozenset({"Logic", "Physics"}),
        frozenset({"Cryptography", "MachineLearning"}),
        frozenset({"Computation", "Physics"}),
        frozenset({"Analysis", "MachineLearning"}),
        frozenset({"Analysis", "Physics"}),
        frozenset({"Analysis", "InformationTheory"}),
    }

    # Theorems that advance known open problems
    OPEN_PROBLEM_THEOREMS = {
        "carmichael", "fib_primitive_divisor", "tropical_langlands",
        "tropical_hecke", "dilithium", "berggren_spectral",
        "tropical_cryptography", "non_archimedean_probability",
        "tropical_information", "pythagorean_quantum",
    }

    # Theorems with direct physical/computational applications
    APPLICATION_THEOREMS = {
        "certified_robustness", "lipschitz", "gradient_descent", "convergence",
        "gronwall", "resnet", "softmax", "logsumexp", "fidelity",
        "cryptographic", "post_quantum", "zero_knowledge",
    }

    def __init__(self, catalog_root: Optional[Path] = None):
        self.catalog_root = catalog_root
        self._catalog_cache: Dict[str, Dict] = {}

    def evaluate_lean_file(self, lean_source: str, file_path: str = "",
                           domain: str = "", narrative: str = "") -> AEMScore:
        """Complete AEM evaluation of a Lean 4 file."""
        rigor = self._score_rigor(lean_source, file_path)
        aesthetic = self._score_aesthetic(lean_source, file_path, domain, narrative)
        utility = self._score_utility(lean_source, file_path, domain)
        originality = self._score_originality(lean_source, file_path, domain)
        impact = self._score_impact(lean_source, file_path, domain, narrative)

        return AEMScore(
            rigor=rigor,
            aesthetic=aesthetic,
            utility=utility,
            originality=originality,
            impact=impact,
        )

    # ------------------------------------------------------------------
    # Pillar 1: Rigor & Sophistication
    # ------------------------------------------------------------------
    def _score_rigor(self, lean_source: str, file_path: str = "") -> float:
        """Score formal verification, abstraction depth, proof elegance, semantic coherence."""
        score = 0.0
        details = {}

        # 1. Sorry count (massive penalty)
        sorry_count = lean_source.lower().count("sorry")
        if sorry_count == 0:
            score += 3.0
            details["sorry_status"] = "no_sorries"
        elif sorry_count <= 2:
            score += 1.5
            details["sorry_status"] = f"minor_gaps({sorry_count})"
        elif sorry_count <= 10:
            score += 0.5
            details["sorry_status"] = f"significant_gaps({sorry_count})"
        else:
            score += 0.0
            details["sorry_status"] = f"major_gaps({sorry_count})"

        # 2. Theorem/lemma count and proof completeness
        theorem_matches = re.findall(r'(?:theorem|lemma)\s+(\w+)', lean_source)
        theorem_count = len(theorem_matches)
        if theorem_count == 0:
            score += 0.0
            details["theorem_count"] = "0"
        elif theorem_count <= 3:
            score += 1.0
            details["theorem_count"] = str(theorem_count)
        elif theorem_count <= 10:
            score += 2.0
            details["theorem_count"] = str(theorem_count)
        else:
            score += 3.0
            details["theorem_count"] = str(theorem_count)

        # 3. Abstraction depth: use of type classes, universes, general types
        abstraction_indicators = 0
        if re.search(r'Semiring|CommRing|Field|LinearOrder|TopologicalSpace', lean_source):
            abstraction_indicators += 1
        if re.search(r'Type\*|Type _', lean_source):
            abstraction_indicators += 1
        if re.search(r'FunLike|Category|Preorder', lean_source):
            abstraction_indicators += 1
        if re.search(r'variable\s*\{', lean_source):
            abstraction_indicators += 1
        if re.search(r'universe\s+', lean_source):
            abstraction_indicators += 1

        abstraction_score = min(abstraction_indicators * 0.6, 2.0)
        score += abstraction_score
        details["abstraction_depth"] = str(abstraction_indicators)

        # 4. Proof techniques: non-trivial tactics used
        advanced_tactics = set()
        tactic_patterns = {
            'induction': r'\binduction\b',
            'cases': r'\bcases\b',
            'rcases': r'\brcases\b',
            'obtain': r'\bobtain\b',
            'ext': r'\bext\b',
            'simp': r'\bsimp\b',
            'omega': r'\bomega\b',
            'linarith': r'\blinarith\b',
            'norm_num': r'\bnorm_num\b',
            'field_simp': r'\bfield_simp\b',
            'ring': r'\bring\b',
            'aesop': r'\baesop\b',
            'tauto': r'\btauto\b',
            'exact': r'\bexact\b',
            'refine': r'\brefine\b',
            'constructor': r'\bconstructor\b',
            'by_contra': r'\bby_contra\b',
            'push_cast': r'\bpush_cast\b',
            'decide': r'\bdecide\b',
            'native_decide': r'\bnative_decide\b',
        }
        for name, pattern in tactic_patterns.items():
            if re.search(pattern, lean_source):
                advanced_tactics.add(name)

        # Diversity of tactics = proof elegance
        tactic_diversity = len(advanced_tactics)
        if tactic_diversity >= 8:
            score += 1.5
        elif tactic_diversity >= 5:
            score += 1.0
        elif tactic_diversity >= 3:
            score += 0.5
        details["tactics_used"] = list(advanced_tactics)

        # 5. Semantic coherence: lemmas build on each other
        # (Check if later theorems reference earlier ones via `exact` or `apply`)
        self_refs = 0
        for thm in theorem_matches:
            if re.search(rf'\b{re.escape(thm)}\b', lean_source[lean_source.index(thm) + len(thm):]):
                self_refs += 1
        if self_refs >= 3:
            score += 0.5
            details["semantic_coherence"] = "strong"
        elif self_refs >= 1:
            score += 0.3
            details["semantic_coherence"] = "moderate"
        else:
            details["semantic_coherence"] = "weak"

        # Cap at 10
        return min(score, 10.0)

    # ------------------------------------------------------------------
    # Pillar 2: Mathematical Aesthetic
    # ------------------------------------------------------------------
    def _score_aesthetic(self, lean_source: str, file_path: str = "",
                         domain: str = "", narrative: str = "") -> float:
        """Score cross-domain bridges, surprise, axiomatic footprint, symmetry."""
        score = 0.0
        details = {}

        # 1. Cross-Domain Bridge Detection
        detected_domains = set()
        path_parts = file_path.lower().split('/') if file_path else []
        source_lower = lean_source.lower()

        # Domain keywords expanded for broader cross-domain detection
        domain_keywords = {
            "Tropical": ["tropical", "logsumexp", "softmax", "tropadd", "max-plus", "lse",
                          "min-plus", "tropical_geometric", "tropical_algebra"],
            "MachineLearning": ["neural", "lipschitz", "relu", "resnet", "gradient", "robust",
                                "certified", "margin", "classification", "deep_learning", "activation",
                                "softmax", "backprop", "training", "inference", "adversarial"],
            "Cryptography": ["cipher", "dilithium", "lattice", "discrete_log", "key",
                             "encryption", "hash", "post_quantum", "digital_signature",
                             "key_exchange", "zero_knowledge", "commitment", "verifiable",
                             "homomorphic", "side_channel", "module_sis"],
            "Physics": ["hamiltonian", "lagrangian", "entanglement", "quantum", "spacetime",
                        "entropy", "holographic", "gravity", "relativ", "thermodynamic",
                        "partition", "free_energy", "boltzmann", "spectrum", "phase_transition",
                        "feynman", "path_integral", "heat", "temperature"],
            "Algebra": ["ring", "ideal", "module", "galois", "field", "group", "homomorph",
                        "congruence", "quotient", "lattice", "poset", "semilattice", "bimonoid"],
            "Topology": ["topological", "compact", "connected", "hausdorff", "open", "closed",
                         "continuous", "baire", "stone", "compactification", "filter"],
            "EML": ["eml", "emergent", "meta-language", "dequantization", "exp-log",
                    "closure", "stone-weierstrass", "activation"],
            "Pythagorean": ["berggren", "pythagorean", "triple", "quadruple", "congruent",
                           "fibonacci", "primitive_divisor", "carmichael"],
            "Logic": ["computable", "oracle", "decidable", "turing", "halting", "godel",
                      "incompleteness", "self-reference", "fixed_point", "paradoxical"],
            "Computation": ["algorithm", "complexity", "factoring", "polynomial-time",
                           "turing_machine", "computable", "recursive", "decidable"],
            "Analysis": ["derivative", "integral", "convex", "measure", "banach", "hilbert",
                         "lebesgue", "fourier", "approximation", "density", "spectrum"],
            "NumberTheory": ["prime", "divisor", "carmichael", "fermat", "gcd", "totient",
                            "pell", "diophantine", "modular", "valuation", "padic"],
            "InformationTheory": ["entropy", "mutual_information", "channel", "capacity",
                                  "data_processing", "shannon", "kl_divergence", "rate_distortion"],
        }

        for dname, keywords in domain_keywords.items():
            for kw in keywords:
                if kw in source_lower or kw in " ".join(path_parts):
                    detected_domains.add(dname)
                    break

        # Cross-domain bonus: connecting 2+ distinct domains
        cross_pairs = set()
        for d1 in detected_domains:
            for d2 in detected_domains:
                if d1 < d2:
                    pair = frozenset({d1, d2})
                    if pair in self.CROSS_DOMAIN_BRIDGES:
                        cross_pairs.add(pair)

        if len(cross_pairs) >= 3:
            score += 3.0
            details["cross_domain_bridges"] = f"{len(cross_pairs)} strong bridges"
        elif len(cross_pairs) >= 2:
            score += 2.5
            details["cross_domain_bridges"] = f"{len(cross_pairs)} bridges"
        elif len(cross_pairs) >= 1:
            score += 2.0
            details["cross_domain_bridges"] = f"{len(cross_pairs)} bridge"
        elif len(detected_domains) >= 2:
            score += 1.0
            details["cross_domain_bridges"] = f"proximate ({detected_domains})"
        else:
            details["cross_domain_bridges"] = f"single_domain ({detected_domains})"

        # 2. Non-Triviality / Surprise
        # Check if narrative contains surprise language
        surprise_indicators = 0
        if narrative:
            surprise_words = ["surprising", "unexpected", "counterintuitive", "paradox",
                              "bridge", "connects", "unifies", "implies", "yields",
                              "fundamental", "deep", "remarkable", "sheds light"]
            for w in surprise_words:
                if w in narrative.lower():
                    surprise_indicators += 1
        # Also check for non-trivial theorem statements
        if re.search(r'∀.*→.*∃', lean_source) or re.search(r'∃.*∀', lean_source):
            surprise_indicators += 2  # Quantifier alternation = non-trivial
        if re.search(r'Function\.(Surjective|Injective|Bijective)', lean_source):
            surprise_indicators += 1
        if re.search(r'Filter\.(Tendsto|atTop|nhds|eventually)', lean_source):
            surprise_indicators += 1

        if surprise_indicators >= 5:
            score += 2.5
            details["surprise"] = f"high({surprise_indicators})"
        elif surprise_indicators >= 3:
            score += 1.5
            details["surprise"] = f"moderate({surprise_indicators})"
        elif surprise_indicators >= 1:
            score += 0.5
            details["surprise"] = f"low({surprise_indicators})"
        else:
            details["surprise"] = "none"

        # 3. Axiomatic Footprint: minimal assumptions → big result
        # Check if theorem has many hypotheses but powerful conclusion
        hypotheses = lean_source.count('(') - lean_source.count(')')
        # Simpler: count the number of hypotheses (things in parentheses before `:`)
        hyp_match = re.findall(r'\((\w+\s*:\s*[^)]+)\)', lean_source[:500])
        if len(hyp_match) <= 2 and theorem_count_indicator(lean_source) >= 3:
            score += 1.5  # Minimal assumptions, big result
            details["axiomatic_footprint"] = "minimal"
        elif len(hyp_match) <= 4:
            score += 0.7
            details["axiomatic_footprint"] = "moderate"
        else:
            details["axiomatic_footprint"] = "heavy"

        # 4. Symmetry / Geometric Interpretation
        symmetry_indicators = 0
        if re.search(r'symm|comm|symmetr|invariant|dual|adjoint', lean_source, re.IGNORECASE):
            symmetry_indicators += 2
        if re.search(r'lattice|poset|order|inf|sup|glb|lub', lean_source, re.IGNORECASE):
            symmetry_indicators += 1
        if re.search(r'group|ring|algebra|module|tensor', lean_source, re.IGNORECASE):
            symmetry_indicators += 1

        if symmetry_indicators >= 3:
            score += 1.5
        elif symmetry_indicators >= 2:
            score += 1.0
        elif symmetry_indicators >= 1:
            score += 0.5

        details["symmetry"] = str(symmetry_indicators)

        return min(score, 10.0)

    # ------------------------------------------------------------------
    # Pillar 3: Structural Utility
    # ------------------------------------------------------------------
    def _score_utility(self, lean_source: str, file_path: str = "",
                       domain: str = "") -> float:
        """Score algorithmic bounds, extensibility, problem resolution, simplification."""
        score = 0.0
        details = {}

        # 1. Algorithmic / Computational Bounds
        bound_indicators = 0
        if re.search(r'≤|≥|<|>|bound|complexity|converg|rate|error|optimal', lean_source, re.IGNORECASE):
            bound_indicators += 2
        if re.search(r'O\(|omega|Theta|big-O|asymptotic', lean_source, re.IGNORECASE):
            bound_indicators += 2
        if re.search(r'Iso|Equiv|Hom|Functor|Morphism', lean_source, re.IGNORECASE):
            bound_indicators += 1  # Algebraic structure = utility for composition
        if re.search(r'continuous|differentiable|lipschitz|measurable|integrable', lean_source, re.IGNORECASE):
            bound_indicators += 1

        if bound_indicators >= 4:
            score += 3.0
            details["computational_bounds"] = f"strong({bound_indicators})"
        elif bound_indicators >= 2:
            score += 2.0
            details["computational_bounds"] = f"moderate({bound_indicators})"
        else:
            score += 0.5
            details["computational_bounds"] = f"weak({bound_indicators})"

        # 2. Extensibility: well-defined API/interface
        def_count = len(re.findall(r'\bdef\s+', lean_source))
        structure_count = len(re.findall(r'\bstructure\s+|class\s+', lean_source))
        instance_count = len(re.findall(r'\binstance\s+', lean_source))

        extensibility = def_count + structure_count * 3 + instance_count * 2
        if extensibility >= 10:
            score += 2.5
            details["extensibility"] = f"rich({extensibility})"
        elif extensibility >= 5:
            score += 1.5
            details["extensibility"] = f"moderate({extensibility})"
        elif extensibility >= 2:
            score += 0.5
            details["extensibility"] = f"basic({extensibility})"
        else:
            details["extensibility"] = "minimal"

        # 3. Problem Resolution: advances open problems
        source_lower = lean_source.lower()
        open_problem_count = 0
        for kw in self.OPEN_PROBLEM_THEOREMS:
            if kw in source_lower or kw in file_path.lower():
                open_problem_count += 1

        if open_problem_count >= 3:
            score += 2.5
            details["open_problem_progress"] = f"major({open_problem_count})"
        elif open_problem_count >= 2:
            score += 2.0
            details["open_problem_progress"] = f"significant({open_problem_count})"
        elif open_problem_count >= 1:
            score += 1.0
            details["open_problem_progress"] = f"touches({open_problem_count})"
        else:
            details["open_problem_progress"] = "none"

        # 4. Simplification: provides a framework
        framework_indicators = 0
        if re.search(r'namespace\s+', lean_source):
            framework_indicators += 1
        if re.search(r'section\s+', lean_source):
            framework_indicators += 1
        if lean_source.count('theorem') >= 5 or lean_source.count('lemma') >= 5:
            framework_indicators += 1
        if re.search(r'variable\s*\[', lean_source):
            framework_indicators += 1

        if framework_indicators >= 3:
            score += 2.0
            details["framework"] = "structured"
        elif framework_indicators >= 1:
            score += 1.0
            details["framework"] = "basic"
        else:
            details["framework"] = "flat"

        return min(score, 10.0)

    # ------------------------------------------------------------------
    # Pillar 4: Paradigm Originality
    # ------------------------------------------------------------------
    def _score_originality(self, lean_source: str, file_path: str = "",
                          domain: str = "") -> float:
        """Score training data independence, conceptual invention, divergent reasoning."""
        score = 0.0
        details = {}

        # 1. Conceptual Invention: new definitions/structures
        new_objects = len(re.findall(r'\b(?:def|structure|class|inductive|abbrev)\s+(\w+)', lean_source))
        # Filter out standard mathlib re-statements
        standard_names = {'hilbertSchmidtNorm', 'BridgeLevel', 'tropAdd', 'lse2',
                         'ScoreVec', 'DomGL3', 'TropFn', 'SupportedInBox'}
        def_names = re.findall(r'\b(?:def|structure|class|inductive|abbrev)\s+(\w+)', lean_source)
        genuinely_new = sum(1 for name in def_names if name not in standard_names)

        if genuinely_new >= 5:
            score += 3.0
            details["new_objects"] = f"many({genuinely_new})"
        elif genuinely_new >= 3:
            score += 2.0
            details["new_objects"] = f"several({genuinely_new})"
        elif genuinely_new >= 1:
            score += 1.0
            details["new_objects"] = f"some({genuinely_new})"
        else:
            details["new_objects"] = "none"

        # 2. Non-derivative theorem names (not just restating mathlib)
        theorem_names = re.findall(r'(?:theorem|lemma)\s+(\w+)', lean_source)
        # Penalize names that are just restatements of mathlib or obvious properties
        derivative_patterns = [
            r'.*_prime$', r'.*_eq_zero$', r'.*_nonneg$', r'.*_symm$',
            r'.*_comm$', r'.*_self$', r'.*_trans$', r'.*_add_\w+$',
            r'.*_mul_\w+$', r'norm_sq_eq_.*', r'inner_add_.*',
            r'.*_le_*$', r'.*_ge_*$', r'.*_lt_*$', r'.*_gt_*$',
            r'.*_pos$', r'.*_neg$', r'.*_fin$', r'.*_inf$',
            r'.*_map_$', r'.*_comp_$', r'.*_prod_$',
            r'mem_.*', r'subset_.*', r'inter_.*', r'union_.*',
        ]
        derivative_count = 0
        for name in theorem_names:
            for pat in derivative_patterns:
                if re.match(pat, name):
                    derivative_count += 1
                    break
            # Also penalize purely descriptive names (verb_object pattern with generic objects)
            generic_names = {'add_zero', 'zero_add', 'mul_one', 'one_mul', 'add_comm',
                           'add_assoc', 'mul_assoc', 'mul_comm', 'left_distrib', 'right_distrib',
                           'eq_refl', 'eq_symm', 'eq_trans', 'le_refl', 'le_trans',
                           'le_antisymm', 'le_total', 'lt_irrefl', 'lt_asymm'}
            if name in generic_names:
                derivative_count += 1

        non_derivative = len(theorem_names) - derivative_count
        derivative_ratio = derivative_count / max(len(theorem_names), 1)

        if derivative_ratio <= 0.2 and len(theorem_names) >= 5:
            score += 2.5
            details["originality_ratio"] = f"high({non_derivative}/{len(theorem_names)})"
        elif derivative_ratio <= 0.5:
            score += 1.5
            details["originality_ratio"] = f"moderate({non_derivative}/{len(theorem_names)})"
        elif len(theorem_names) == 0:
            details["originality_ratio"] = "no_theorems"
        else:
            score += 0.5
            details["originality_ratio"] = f"low({non_derivative}/{len(theorem_names)})"

        # 3. Divergent reasoning: uses unexpected mathematical connections
        # Check for unusual type class combinations
        typeclasses = re.findall(r'\[(\w+)', lean_source)
        unusual_combos = 0
        tc_set = set(typeclasses)
        unusual_pairs = [
            {"LinearOrder", "Group"},
            {"TopologicalSpace", "Ring"},
            {"MeasureSpace", "Category"},
            {"NormedAddCommGroup", "Field"},
            {"PartialOrder", "TopologicalSpace"},
            {"Semiring", "LinearOrder"},
            {"MetricSpace", "Semiring"},
            # Extended unusual pairs for cross-domain originality
            {"Semiring", "MetricSpace"},
            {"NormedAddCommGroup", "Semiring"},
            {"Lattice", "MetricSpace"},
            {"TopologicalSpace", "Semiring"},
            {"OrderedAddCommGroup", "Semiring"},
            {"LinearOrder", "MetricSpace"},
            {"PartialOrder", "NormedAddCommGroup"},
            {"Lattice", "TopologicalSpace"},
            {"Field", "TopologicalSpace"},
            {"Group", "MetricSpace"},
            {"CompleteLinearOrder", "Semiring"},
            {"NormedField", "LinearOrder"},
        ]
        for pair in unusual_pairs:
            if pair.issubset(tc_set):
                unusual_combos += 1

        # Also reward cross-namespace references (structural novelty)
        namespaces = set(re.findall(r'open\s+(\w+)', lean_source))
        namespace_refs = set(re.findall(r'(\w+)\.\w+', lean_source))
        cross_namespace_refs = len(namespace_refs) + len(namespaces)
        if cross_namespace_refs >= 5:
            unusual_combos += 1  # Novel structural connections across modules
            if cross_namespace_refs >= 10:
                unusual_combos += 1  # Deep cross-module integration

        if unusual_combos >= 2:
            score += 2.0
            details["divergent_combos"] = f"paradigm_shift({unusual_combos})"
        elif unusual_combos >= 1:
            score += 1.0
            details["divergent_combos"] = f"unusual({unusual_combos})"
        else:
            details["divergent_combos"] = "standard"

        # 4. Sci-fi / speculative bonus (only if rigorously grounded)
        if 'Speculative' in file_path or 'scifi' in file_path.lower():
            # Sci-fi content gets bonus for creativity, but only if no sorry
            sorry_count = lean_source.lower().count('sorry')
            if sorry_count == 0 and len(theorem_names) >= 3:
                score += 1.5
                details["speculative_bonus"] = "grounded"
            elif sorry_count <= 2:
                score += 0.5
                details["speculative_bonus"] = "partial"
            else:
                details["speculative_bonus"] = "ungrounded"

        return min(score, 10.0)

    # ------------------------------------------------------------------
    # Pillar 5: Transformative Impact
    # ------------------------------------------------------------------
    def _score_impact(self, lean_source: str, file_path: str = "",
                      domain: str = "", narrative: str = "") -> float:
        """Score physics/crypto translation, ML interpretability, optimization, wonderful factor."""
        score = 0.0
        details = {}
        source_lower = lean_source.lower()

        # 1. Physics / Cryptography Translation
        physics_crypto = 0
        for kw in ["quantum", "hamiltonian", "lagrangian", "entanglement", "thermodynamic",
                    "entropy", "spacetime", "relativistic", "holographic", "free_energy",
                    "partition", "boltzmann", "spectrum", "phase_transition", "heat",
                    "temperature", "feynman", "path_integral"]:
            if kw in source_lower or kw in (narrative or "").lower():
                physics_crypto += 2
        for kw in ["dilithium", "lattice-based", "post-quantum", "zero-knowledge",
                    "diffie-hellman", "digital signature", "key exchange",
                    "module_sis", "module_lwe", "shortest_vector", "closest_vector",
                    "learning_with_errors", "lattice_crypto", "sphincs",
                    "commitment", "verifiable"]:
            if kw in source_lower or kw in (narrative or "").lower():
                physics_crypto += 2

        if physics_crypto >= 4:
            score += 3.0
            details["physics_crypto"] = f"strong({physics_crypto})"
        elif physics_crypto >= 2:
            score += 2.0
            details["physics_crypto"] = f"moderate({physics_crypto})"
        elif physics_crypto >= 1:
            score += 0.5
            details["physics_crypto"] = f"touches({physics_crypto})"
        else:
            details["physics_crypto"] = "none"

        # 2. ML Interpretability
        # Check for ML-specific terms first (high-confidence)
        ml_indicators = 0
        for kw in ["neural", "lipschitz", "certified_robust", "adversarial",
                    "relu", "resnet", "softmax", "overfitting",
                    "deep_learning", "backpropagation",
                    "activation_function", "neural_layer",
                    "generalization_bound", "lipschitz_bound",
                    "certified_radius", "robustness_certificate"]:
            if kw in source_lower:
                ml_indicators += 2  # High-confidence ML terms count double

        # Check for broad ML terms (need co-occurrence to count)
        ml_broad = 0
        for kw in ["gradient", "convergence", "margin", "approximation", "universal",
                    "network", "training", "inference", "depth", "activation",
                    "robust", "classification", "spectrum"]:
            if kw in source_lower:
                ml_broad += 1

        # Broad terms only count if at least one high-confidence term is present
        if ml_indicators >= 2:
            ml_indicators += min(ml_broad, 6)  # Cap broad term contribution
        else:
            ml_indicators += min(ml_broad, 2)  # Very limited contribution without ML context

        if ml_indicators >= 6:
            score += 2.5
            details["ml_interpretability"] = f"direct({ml_indicators})"
        elif ml_indicators >= 3:
            score += 1.5
            details["ml_interpretability"] = f"moderate({ml_indicators})"
        elif ml_indicators >= 1:
            score += 0.5
            details["ml_interpretability"] = f"touches({ml_indicators})"
        else:
            details["ml_interpretability"] = "none"

        # 3. Systemic Optimization
        optimization = 0
        for kw in ["optimal", "efficient", "complexity", "algorithm", "compiler",
                    "factor", "search", "bound", "rate", "converge", "iteration"]:
            if kw in source_lower:
                optimization += 1

        if optimization >= 5:
            score += 2.0
            details["optimization"] = f"direct({optimization})"
        elif optimization >= 3:
            score += 1.0
            details["optimization"] = f"moderate({optimization})"
        elif optimization >= 1:
            score += 0.5
            details["optimization"] = f"touches({optimization})"
        else:
            details["optimization"] = "none"

        # 4. "Wonderful" Factor: paradigm-changing connections
        wonderful = 0
        if "tropical" in source_lower and ("neural" in source_lower or "robust" in source_lower):
            wonderful += 2  # Tropical+ML = paradigm bridge
        if "carmichael" in source_lower or "primitive_divisor" in source_lower:
            wonderful += 2  # Number theory breakthrough
        if "satake" in source_lower or "hecke" in source_lower:
            wonderful += 2  # Langlands program
        if re.search(r'certified.*robust|robust.*certified', source_lower):
            wonderful += 2  # Certified robustness
        if "berggren" in source_lower and ("spectral" in source_lower or "factoring" in source_lower):
            wonderful += 2  # Novel factoring paradigm
        if "eml" in source_lower and "thermodynamic" in source_lower:
            wonderful += 2  # EML-thermodynamics bridge
        # Extended wonderful factors
        if "tropical" in source_lower and "cryptograph" in source_lower:
            wonderful += 2  # Tropical crypto
        if "tropical" in source_lower and ("entropy" in source_lower or "information" in source_lower):
            wonderful += 2  # Tropical information theory
        if "quantum" in source_lower and ("tropical" in source_lower or "semiring" in source_lower):
            wonderful += 2  # Quantum-tropical bridge
        if "lattice" in source_lower and ("crypto" in source_lower or "post_quantum" in source_lower):
            wonderful += 2  # Lattice-based post-quantum
        if "semiring" in source_lower and ("lipschitz" in source_lower or "robust" in source_lower):
            wonderful += 2  # Algebraic robustness
        if "entropy" in source_lower and ("congruence" in source_lower or "algebra" in source_lower):
            wonderful += 2  # Algebraic entropy
        if "berggren" in source_lower and "quantum" in source_lower:
            wonderful += 2  # Pythagorean quantum bridge

        if wonderful >= 4:
            score += 2.5
            details["wonderful"] = f"transformative({wonderful})"
        elif wonderful >= 2:
            score += 1.5
            details["wonderful"] = f"significant({wonderful})"
        elif wonderful >= 1:
            score += 0.5
            details["wonderful"] = f"touches({wonderful})"
        else:
            details["wonderful"] = "none"

        return min(score, 10.0)

    def evaluate_catalog(self, catalog_root: Path) -> Dict[str, AEMScore]:
        """Evaluate all files in the catalog."""
        results = {}
        for lean_file in catalog_root.rglob("*.lean"):
            if '.lake' in str(lean_file):
                continue
            try:
                source = lean_file.read_text(encoding='utf-8')
            except Exception:
                continue
            rel_path = str(lean_file.relative_to(catalog_root))
            score = self.evaluate_lean_file(source, file_path=rel_path)
            results[rel_path] = score
        return results


def theorem_count_indicator(source: str) -> int:
    """Quick count of theorems in source."""
    return len(re.findall(r'(?:theorem|lemma)\s+', source))


def main():
    """CLI: evaluate a single file or the entire catalog."""
    import sys
    if len(sys.argv) < 2:
        print("Usage: python aem_evaluator.py <path_or_catalog_root>")
        sys.exit(1)

    path = Path(sys.argv[1])
    evaluator = AEMEvaluator(catalog_root=path if path.is_dir() else None)

    if path.is_dir():
        # Evaluate entire catalog
        print("Evaluating catalog...")
        results = evaluator.evaluate_catalog(path)
        # Sort by total score
        sorted_results = sorted(results.items(), key=lambda x: x[1].total, reverse=True)

        print(f"\n{'File':<60} {'Rig':>4} {'Aes':>4} {'Uti':>4} {'Ori':>4} {'Imp':>4} {'Tot':>5} {'Cat':>20}")
        print("-" * 120)
        for fpath, score in sorted_results[:30]:
            print(f"{fpath:<60} {score.rigor:>4.1f} {score.aesthetic:>4.1f} "
                  f"{score.utility:>4.1f} {score.originality:>4.1f} "
                  f"{score.impact:>4.1f} {score.total:>5.1f} {score.category():>20}")

        # Averages
        if results:
            avg_rigor = sum(s.rigor for s in results.values()) / len(results)
            avg_aesthetic = sum(s.aesthetic for s in results.values()) / len(results)
            avg_utility = sum(s.utility for s in results.values()) / len(results)
            avg_originality = sum(s.originality for s in results.values()) / len(results)
            avg_impact = sum(s.impact for s in results.values()) / len(results)
            avg_total = sum(s.total for s in results.values()) / len(results)
            print(f"\n{'AVERAGE':<60} {avg_rigor:>4.1f} {avg_aesthetic:>4.1f} "
                  f"{avg_utility:>4.1f} {avg_originality:>4.1f} "
                  f"{avg_impact:>4.1f} {avg_total:>5.1f}")

            # Save JSON
            report = {
                "total_files": len(results),
                "averages": {
                    "rigor": round(avg_rigor, 2),
                    "aesthetic": round(avg_aesthetic, 2),
                    "utility": round(avg_utility, 2),
                    "originality": round(avg_originality, 2),
                    "impact": round(avg_impact, 2),
                    "total": round(avg_total, 2),
                },
                "top_files": [
                    {"path": fpath, "score": score.to_dict()}
                    for fpath, score in sorted_results[:20]
                ],
            }
            report_path = Path("aem_report.json")
            with open(report_path, "w") as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to {report_path}")
    else:
        # Evaluate single file
        source = path.read_text(encoding='utf-8')
        score = evaluator.evaluate_lean_file(source, file_path=str(path))
        print(f"AEM Score for {path.name}:")
        print(f"  Rigor:        {score.rigor:.1f}/10")
        print(f"  Aesthetic:    {score.aesthetic:.1f}/10")
        print(f"  Utility:      {score.utility:.1f}/10")
        print(f"  Originality:  {score.originality:.1f}/10")
        print(f"  Impact:       {score.impact:.1f}/10")
        print(f"  TOTAL:        {score.total:.1f}/50 ({score.category()})")
        print(f"\nDetails: {json.dumps(score.details, indent=2)}")


if __name__ == "__main__":
    main()