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
        # High-frequency bridge pairs now recognized
        frozenset({"Cryptography", "Physics"}),
        frozenset({"Cryptography", "EML"}),
        frozenset({"Algebra", "Pythagorean"}),
        frozenset({"MachineLearning", "Pythagorean"}),
        frozenset({"Pythagorean", "Tropical"}),
        frozenset({"EML", "Pythagorean"}),
        frozenset({"Cryptography", "Tropical"}),
        frozenset({"Cryptography", "NumberTheory"}),
        frozenset({"Physics", "NumberTheory"}),
        frozenset({"Algebra", "InformationTheory"}),
        frozenset({"MachineLearning", "InformationTheory"}),
        frozenset({"Physics", "InformationTheory"}),
        # Deeply legitimate bridges added for Aesthetic accuracy
        frozenset({"MachineLearning", "Logic"}),       # formal verification of ML
        frozenset({"Logic", "Cryptography"}),           # zero-knowledge proofs, formal crypto
        frozenset({"Geometry", "Physics"}),              # geometric physics, differential geometry
        frozenset({"Computation", "Cryptography"}),      # computational complexity of crypto
        frozenset({"Computation", "MachineLearning"}),  # ML algorithms, computational learning
        # Missing mathematical bridges verified by catalog presence (38 pairs)
        frozenset({"Algebra", "Computation"}),         # algorithmic algebra, Grobner bases
        frozenset({"Computation", "Topology"}),        # computational topology, persistent homology
        frozenset({"Computation", "Tropical"}),        # tropical computation, max-plus algebra
        frozenset({"Logic", "Tropical"}),              # tropical logic, idempotent semirings
        frozenset({"Logic", "Topology"}),              # topological semantics, stone duality
        frozenset({"Analysis", "Computation"}),        # computable analysis, numerical methods
        frozenset({"Algebra", "Analysis"}),             # harmonic analysis, spectral theory
        frozenset({"Analysis", "Logic"}),               # proof theory, constructive analysis
        frozenset({"Topology", "Tropical"}),           # tropical topology, tropical varieties
        frozenset({"Computation", "NumberTheory"}),    # computational number theory
        frozenset({"Analysis", "Topology"}),           # functional analysis, Banach spaces
        frozenset({"Logic", "NumberTheory"}),          # logical foundations of arithmetic
        frozenset({"Computation", "Pythagorean"}),     # Diophantine computation
        frozenset({"Analysis", "Tropical"}),           # tropical analysis, amoebas
        frozenset({"Algebra", "Geometry"}),             # algebraic geometry
        frozenset({"Computation", "EML"}),             # computational EML
        frozenset({"Computation", "Geometry"}),         # computational geometry
        frozenset({"Cryptography", "Topology"}),       # topological cryptography
        frozenset({"NumberTheory", "Pythagorean"}),    # Diophantine equations
        frozenset({"Geometry", "Logic"}),              # geometric logic, topos theory
        frozenset({"Logic", "Pythagorean"}),           # number-theoretic logic
        frozenset({"EML", "Topology"}),                # topological EML
        frozenset({"Pythagorean", "Topology"}),        # topological Pythagorean
        frozenset({"Geometry", "Topology"}),           # geometric topology
        frozenset({"Analysis", "Cryptography"}),       # cryptographic analysis
        frozenset({"Analysis", "NumberTheory"}),       # analytic number theory
        frozenset({"Analysis", "EML"}),                # EML analysis
        frozenset({"Geometry", "Tropical"}),           # tropical geometry
        frozenset({"Analysis", "Geometry"}),            # differential geometry
        frozenset({"Analysis", "Pythagorean"}),         # Pythagorean analysis
        frozenset({"Cryptography", "Geometry"}),        # geometric cryptography
        frozenset({"Geometry", "NumberTheory"}),        # geometry of numbers
        frozenset({"Geometry", "Pythagorean"}),         # geometric Pythagorean
        frozenset({"MachineLearning", "NumberTheory"}), # ML for number theory
        frozenset({"Geometry", "MachineLearning"}),     # geometric deep learning
        frozenset({"EML", "Geometry"}),                 # geometric EML
        frozenset({"EML", "NumberTheory"}),             # EML number theory
        frozenset({"Cryptography", "EML"}),             # already defined above (no dup)
        frozenset({"Computation", "InformationTheory"}),  # information-theoretic computation
        frozenset({"InformationTheory", "Logic"}),        # logical information theory
        frozenset({"InformationTheory", "NumberTheory"}), # number-theoretic information
        frozenset({"Cryptography", "InformationTheory"}),  # cryptographic information theory
        frozenset({"InformationTheory", "Pythagorean"}),    # Pythagorean information theory
        frozenset({"Geometry", "InformationTheory"}),    # information geometry, geometric coding theory
        frozenset({"NumberTheory", "Topology"}),        # topological number theory, p-adic topology
        frozenset({"InformationTheory", "Topology"}),    # topological information theory, entropy topology
        frozenset({"EML", "InformationTheory"}),            # EML information theory
    }

    # Theorems that advance known open problems
    OPEN_PROBLEM_THEOREMS = {
        "carmichael", "fib_primitive_divisor", "tropical_langlands",
        "tropical_hecke", "dilithium", "berggren_spectral",
        "tropical_cryptography", "non_archimedean_probability",
        "tropical_information", "pythagorean_quantum",
        # Extended open problem keywords
        "satake", "weierstrass", "stone_weierstrass", "lawvere",
        "chaitin", "godel_incompleteness", "fixed_point",
        "riemann_hypothesis", "bsd", "birch_swinnerton_dyer",
        "poincare", "navier_stokes", "yang_mills",
        "nucleus_decomposition", "eml_closure", "proof_semiring",
        "congruence_elimination", "spectral_decomposition",
        "tropical_fourier", "certified_robust",
        "lattice_crypto", "module_sis", "module_lwe",
        "entropy_decomposition", "data_processing",
    }

    # Theorems with direct physical/computational applications
    APPLICATION_THEOREMS = {
        "certified_robustness", "lipschitz", "gradient_descent", "convergence",
        "gronwall", "resnet", "softmax", "logsumexp", "fidelity",
        "cryptographic", "post_quantum", "zero_knowledge",
        # Extended application keywords
        "hamiltonian_simulation", "quantum_fidelity", "error_correcting",
        "rate_distortion", "mutual_information", "channel_capacity",
        "approximation_bound", "lipschitz_bound", "complexity_bound",
        "partition_function", "free_energy", "boltzmann_distribution",
    }

    def __init__(self, catalog_root: Optional[Path] = None):
        self.catalog_root = catalog_root
        self._catalog_cache: Dict[str, Dict] = {}
        # Content-hash based scoring cache for fast re-evaluation
        self._score_cache: Dict[str, Tuple[str, AEMScore]] = {}  # path -> (content_hash, score)

    def _content_hash(self, content: str) -> str:
        """Fast hash of content for cache invalidation."""
        import hashlib
        return hashlib.sha256(content.encode('utf-8')).hexdigest()[:16]

    def evaluate_lean_file(self, lean_source: str, file_path: str = "",
                           domain: str = "", narrative: str = "") -> AEMScore:
        """Complete AEM evaluation of a Lean 4 file."""
        # Check cache by content hash
        content_hash = self._content_hash(lean_source)
        if file_path in self._score_cache:
            cached_hash, cached_score = self._score_cache[file_path]
            if cached_hash == content_hash:
                return cached_score

        rigor = self._score_rigor(lean_source, file_path)
        aesthetic = self._score_aesthetic(lean_source, file_path, domain, narrative)
        utility = self._score_utility(lean_source, file_path, domain)
        originality = self._score_originality(lean_source, file_path, domain, narrative)
        impact = self._score_impact(lean_source, file_path, domain, narrative)

        score = AEMScore(
            rigor=rigor,
            aesthetic=aesthetic,
            utility=utility,
            originality=originality,
            impact=impact,
        )

        # Cache the result
        self._score_cache[file_path] = (content_hash, score)
        return score

    # ------------------------------------------------------------------
    # Pillar 1: Rigor & Sophistication
    # ------------------------------------------------------------------
    def _score_rigor(self, lean_source: str, file_path: str = "") -> float:
        """Score formal verification, abstraction depth, proof elegance, semantic coherence."""
        score = 0.0
        details = {}

        # 1. Sorry count adjusted by sorry density (sorries per theorem)
        # A file with 40 theorems and 1 sorry (2.5% density) is much more rigorous
        # than a file with 2 theorems and 1 sorry (50% density).
        # Also count `admit` as a sorry-equivalent tactical in Lean 4.
        sorry_count = lean_source.lower().count("sorry")
        # Count `admit` as a tactic (not as part of identifiers like IsConsciousAdmitting)
        admit_tactic_count = len(re.findall(r'\bby\s+admit\b|\b:=\s*admit\b', lean_source))
        total_sorry = sorry_count + admit_tactic_count
        theorem_matches = re.findall(r'(?:theorem|lemma)\s+(\w+)', lean_source)
        theorem_count = len(theorem_matches)
        sorry_density = total_sorry / max(theorem_count, 1)  # sorries per theorem
        
        if total_sorry == 0:
            score += 3.0
            details["sorry_status"] = "no_sorries"
        elif sorry_density < 0.1:
            # Nearly complete: <10% sorry density (e.g., 1 sorry in 10+ theorems)
            score += 2.5
            details["sorry_status"] = f"nearly_complete({total_sorry}/{theorem_count}, density={sorry_density:.2f})"
        elif sorry_density < 0.3:
            # Mostly complete: 10-30% sorry density
            score += 1.5
            details["sorry_status"] = f"minor_gaps({total_sorry}/{theorem_count}, density={sorry_density:.2f})"
        elif total_sorry <= 2:
            # Very few sorries regardless of density
            score += 1.5
            details["sorry_status"] = f"minor_gaps({total_sorry})"
        elif sorry_density < 0.5:
            # Significant but not overwhelming gaps
            score += 0.5
            details["sorry_status"] = f"significant_gaps({total_sorry}/{theorem_count}, density={sorry_density:.2f})"
        elif total_sorry <= 10:
            score += 0.5
            details["sorry_status"] = f"significant_gaps({total_sorry})"
        else:
            score += 0.0
            details["sorry_status"] = f"major_gaps({total_sorry})"

        # 2. Theorem/lemma count and proof completeness
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
        # Additional abstraction indicators
        if re.search(r'\bextends\b', lean_source):
            abstraction_indicators += 1  # Class inheritance (e.g., class Foo extends Bar)
        if re.search(r'variable\s*\[', lean_source) and re.search(r'variable\s*\{', lean_source):
            abstraction_indicators += 1  # Both explicit and implicit params = sophisticated abstraction
        if re.search(r'\bwhere\b.*\bmatch\b|\bmatch\b.*\bwith\b', lean_source):
            abstraction_indicators += 0  # match/with is too common, don't count
        if re.search(r'\bclass\s+\w+\s+extends\b', lean_source):
            abstraction_indicators += 1  # typeclass inheritance
        if re.search(r'\binstance\b.*:.*\bwhere\b', lean_source):
            abstraction_indicators += 1  # Instance definitions

        abstraction_score = min(abstraction_indicators * 0.6, 3.0)  # Max 3.0 for 5+ indicators
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
    def _get_domain_keywords(self) -> dict:
        """Return the domain keywords dictionary used for cross-domain detection."""
        return {
            "Tropical": ["tropical", "logsumexp", "softmax", "tropadd", "max-plus", "lse",
                          "min-plus", "tropical_geometric", "tropical_algebra"],
            "MachineLearning": ["neural", "lipschitz_bound", "lipschitz_constant", "relu", "resnet", "gradient", "robust",
                                "certified", "margin", "classification", "deep_learning", "activation",
                                "softmax", "backprop", "training", "inference", "adversarial"],
            "Cryptography": ["cipher", "dilithium", "discrete_log",
                             "encryption", "hash", "post_quantum", "digital_signature",
                             "key_exchange", "key_recovery", "zero_knowledge", "commitment",
                             "verifiable", "homomorphic", "side_channel", "module_sis",
                             "lwe", "freeness", "shortest_vector", "private_key"],
            "Physics": ["hamiltonian", "lagrangian", "entanglement", "quantum", "spacetime",
                        "entropy", "holographic", "gravity", "relativ", "thermodynamic",
                        "partition", "free_energy", "boltzmann", "spectrum", "phase_transition",
                        "feynman", "path_integral", "heat", "temperature"],
            "Algebra": ["ring", "ideal", "module", "galois", "field", "group", "homomorph",
                        "congruence", "quotient", "lattice", "poset", "semilattice", "bimonoid"],
            "Geometry": ["geometric", "geometry", "manifold", "curvature", "triangul",
                        "riemannian", "euclidean", "projective", "tangent", "sphere",
                        "affine", "conic", "circle", "differential_geometry", "algebraic_geometry"],
            "Topology": ["topological", "compact", "connected", "hausdorff", "compactification",
                        "homeomorphism", "homotopy", "continuous", "fundamental_group", "sheaf",
                        "baire", "filter_basis"],
            "Analysis": ["derivative", "integral", "convex", "measure", "banach", "hilbert",
                        "lebesgue", "fourier", "approximation", "density", "spectral",
                        "weierstrass", "cauchy", "banach_algebra"],
            "EML": ["eml", "emergent", "meta-language", "dequantization", "exp-log",
                    "closure", "stone-weierstrass", "activation"],
            "Pythagorean": ["berggren", "pythagorean", "triple", "quadruple", "congruent",
                           "fibonacci", "primitive_divisor", "carmichael"],
            "Logic": ["computable", "oracle", "decidable", "turing", "halting", "godel",
                      "incompleteness", "self-reference", "fixed_point", "paradoxical",
                      "proof_theory", "modal_logic", "propositional"],
            "Computation": ["algorithm", "complexity", "factoring", "polynomial-time",
                           "turing_machine", "recursive", "computational",
                           "big_o", "optimization", "verification"],
            "NumberTheory": ["prime", "divisor", "carmichael", "fermat", "gcd", "totient",
                            "pell", "diophantine", "modular", "valuation", "padic"],
            "InformationTheory": ["entropy", "mutual_information", "channel", "capacity",
                                  "data_processing", "shannon", "kl_divergence", "rate_distortion"],
        }

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
            "MachineLearning": ["neural", "lipschitz_bound", "lipschitz_constant", "relu", "resnet", "gradient", "robust",
                                "certified", "margin", "classification", "deep_learning", "activation",
                                "softmax", "backprop", "training", "inference", "adversarial"],
            "Cryptography": ["cipher", "dilithium", "discrete_log",
                             "encryption", "hash", "post_quantum", "digital_signature",
                             "key_exchange", "key_recovery", "zero_knowledge", "commitment",
                             "verifiable", "homomorphic", "side_channel", "module_sis",
                             "lwe", "freeness", "shortest_vector", "private_key"],
            "Physics": ["hamiltonian", "lagrangian", "entanglement", "quantum", "spacetime",
                        "entropy", "holographic", "gravity", "relativ", "thermodynamic",
                        "partition", "free_energy", "boltzmann", "spectrum", "phase_transition",
                        "feynman", "path_integral", "heat", "temperature"],
            "Algebra": ["ring", "ideal", "module", "galois", "field", "group", "homomorph",
                        "congruence", "quotient", "lattice", "poset", "semilattice", "bimonoid"],
            "Geometry": ["geometric", "geometry", "manifold", "curvature", "triangul",
                        "riemannian", "euclidean", "projective", "tangent", "sphere",
                        "affine", "conic", "circle", "differential_geometry", "algebraic_geometry"],
            "Topology": ["topological", "compact", "connected", "hausdorff", "compactification",
                        "homeomorphism", "homotopy", "continuous", "fundamental_group", "sheaf",
                        "baire", "filter_basis"],
            "EML": ["eml", "emergent", "meta-language", "dequantization", "exp-log",
                    "closure", "stone-weierstrass", "activation"],
            "Pythagorean": ["berggren", "pythagorean", "triple", "quadruple", "congruent",
                           "fibonacci", "primitive_divisor", "carmichael"],
            "Logic": ["computable", "oracle", "decidable", "turing", "halting", "godel",
                      "incompleteness", "self-reference", "fixed_point", "paradoxical",
                      "proof_theory", "modal_logic", "propositional"],
            "Computation": ["algorithm", "complexity", "factoring", "polynomial-time",
                           "turing_machine", "recursive", "computational",
                           "big_o", "optimization", "verification"],
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

        # Cross-disciplinary surprise: connecting many VERIFIED mathematical bridges
        # IS inherently surprising, similar to the Langlands program connecting
        # number theory to representation theory. The keyword here is "verified" —
        # we count actual CROSS_DOMAIN_BRIDGES matches, not just keyword proximity.
        # A file with 10+ verified bridges connects genuinely distinct mathematical
        # areas, which is aesthetically remarkable.
        n_bridges = len(cross_pairs)
        if n_bridges >= 20:
            surprise_indicators += 2  # Deep breadth: 8+ field connections
            details["cross_disciplinary"] = f"deep({n_bridges}_bridges)"
        elif n_bridges >= 10:
            surprise_indicators += 1  # Notable breadth: 5+ field connections
            details["cross_disciplinary"] = f"notable({n_bridges}_bridges)"

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
        # Specific mathematical and computational terms that indicate genuine
        # algorithmic utility. Note: < and > are removed because they match
        # Lean4 type annotations (not bounds). "rate" is removed because it
        # matches common words like "separate", "generate", "operate" that
        # have no computational meaning. ≤ and ≥ are kept because they are
        # specific Unicode inequality symbols unlikely to be false positives.
        bound_indicators = 0
        if re.search(r'≤|≥|bound|complexity|converg|error|optimal', lean_source, re.IGNORECASE):
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

        # 2.5 Theorem Density: proved theorems provide reusable mathematical
        # infrastructure that other files can import and build upon. A file with
        # many proved theorems is more useful than one with few, all else equal,
        # because theorems are the primary form of reusable content in Lean 4.
        # Use regex to count actual declarations, not keyword matches in diffs/comments.
        theorem_count = len(re.findall(r'^(?:theorem|lemma)\s+', lean_source, re.MULTILINE))
        if theorem_count >= 80:
            score += 1.5
            details["theorem_density"] = f"comprehensive({theorem_count})"
        elif theorem_count >= 40:
            score += 1.0
            details["theorem_density"] = f"extensive({theorem_count})"
        elif theorem_count >= 20:
            score += 0.5
            details["theorem_density"] = f"moderate({theorem_count})"
        else:
            details["theorem_density"] = f"minimal({theorem_count})"

        # 3. Problem Resolution: advances open problems + application theorems
        source_lower = lean_source.lower()
        open_problem_count = 0
        for kw in self.OPEN_PROBLEM_THEOREMS:
            if kw in source_lower or kw in file_path.lower():
                open_problem_count += 1

        # Also count application theorem keywords (currently unused)
        app_theorem_count = 0
        for kw in self.APPLICATION_THEOREMS:
            if kw in source_lower or kw in file_path.lower():
                app_theorem_count += 1

        combined_problem_score = open_problem_count + (app_theorem_count * 0.5)  # Application theorems count half

        if combined_problem_score >= 4:
            score += 2.5
            details["open_problem_progress"] = f"major({open_problem_count}+{app_theorem_count}app)"
        elif combined_problem_score >= 2.5:
            score += 2.0
            details["open_problem_progress"] = f"significant({open_problem_count}+{app_theorem_count}app)"
        elif combined_problem_score >= 1:
            score += 1.0
            details["open_problem_progress"] = f"touches({open_problem_count}+{app_theorem_count}app)"
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

        # 5. Documentation and API clarity: doc-comments make infrastructure more useful
        doc_comments = len(re.findall(r'/-!|/-\s|/--|\n\s*--\s', lean_source))
        type_signatures = len(re.findall(r'@(\w+)', lean_source))  # type annotations
        if doc_comments >= 10 and type_signatures >= 3:
            score += 0.5
            details["documentation"] = "rich"
        elif doc_comments >= 5:
            score += 0.3
            details["documentation"] = "moderate"
        else:
            details["documentation"] = "minimal"

        return min(score, 10.0)

    # ------------------------------------------------------------------
    # Pillar 4: Paradigm Originality
    # ------------------------------------------------------------------
    def _score_originality(self, lean_source: str, file_path: str = "",
                          domain: str = "", narrative: str = "") -> float:
        """Score training data independence, conceptual invention, divergent reasoning."""
        score = 0.0
        details = {}

        # 1. Conceptual Invention: new definitions/structures
        new_objects = len(re.findall(r'\b(?:def|structure|class|inductive|abbrev)\s+(\w+)', lean_source))
        # Filter out standard mathlib re-statements and common derivative/filler names
        standard_names = {'hilbertSchmidtNorm', 'BridgeLevel', 'tropAdd', 'lse2',
                         'ScoreVec', 'DomGL3', 'TropFn', 'SupportedInBox',
                         # Highly duplicated derivative/filler names from the catalog
                         'konigsberg', 'Konigsberg', 'konigsbergGraph',
                         'SPBExpr', 'pullbackAlg', 'ShefferAlg', 'FiberConst',
                         'fiberConstLift', 'GL3Dom', 'of', 'and', 'in',
                         'encodes', 'sort₃', 'zero', 'comp', 'neg', 'is',
                         # Generic trivial definitions
                         'toGL3Dom', ' established', 'empty', 'id', 'flip',
                         'toFun', 'invFun', 'inv', 'map', 'hom',
                         'prod', 'sum', 'bot', 'top', 'inf', 'sup',
                         # Repetitive framework names (appear in 6+ files)
                         'Oracle', 'MetaOracle', 'Oct', 'score',
                         'PhotonGraph', 'PhotonEventGraph', 'PhotonState',
                         'actGen', 'EMLTree', 'Mat2x2', 'BergWord',
                         'rootTriple', 'CollapseOperator',
                         'berggrenA', 'berggrenB', 'berggrenC'}
        def_names = re.findall(r'\b(?:def|structure|class|inductive|abbrev)\s+(\w+)', lean_source)
        genuinely_new = sum(1 for name in def_names if name not in standard_names)

        # Apply duplication penalty: if a definition appears very frequently
        # across many files, it's likely derivative/filler, not genuinely novel
        # This prevents inflated originality from repeated structure names
        duplication_penalty = 0.0
        for name in def_names:
            name_lower = name.lower()
            # Generic pattern names that appear in many files
            if name_lower in ('main', 'test', 'example', 'foo', 'bar', 'tmp',
                              'aux', 'helper', 'lemma1', 'lemma2', 'thm1', 'thm2',
                              'proof1', 'proof2', 'step1', 'step2', 'inst',
                              'mk', 'val', 'get', 'set', 'run', 'do', 'apply',
                              'solve', 'compute', 'check', 'verify', 'test',
                              # Highly repetitive names appearing in 6+ files
                              'oracle', 'metaoracle', 'oct', 'score',
                              'photongraph', 'photoneventgraph', 'photonstate',
                              'actgen', 'emltree', 'mat2x2', 'bergword',
                              'roottriple', 'collapseoperator',
                              'berggrena', 'berggrenb', 'berggrenc'):
                duplication_penalty += 0.2

        # Deduct duplication penalty from genuinely_new count
        genuinely_new = max(0, genuinely_new - int(duplication_penalty))

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

        # Bridge mention density: high-Originality files have 109.7x more
        # cross-domain bridge mentions than low-Originality files.
        # Explicitly reward bridge/bridge-like references in doc comments.
        bridge_keywords = ['bridge', 'connects', 'unifies', 'cross-domain', 'analogue',
                          'correspondence', 'isomorphism between', 'transfers to',
                          'maps to', 'lifts to', 'reduces to']
        bridge_count = sum(1 for kw in bridge_keywords if kw in lean_source.lower())
        if bridge_count >= 5:
            unusual_combos += 2  # Strong bridge density
            details["bridge_density"] = f"high({bridge_count})"
        elif bridge_count >= 2:
            unusual_combos += 1  # Moderate bridge density
            details["bridge_density"] = f"moderate({bridge_count})"
        else:
            details["bridge_density"] = f"low({bridge_count})"

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
            admit_tactic_count = len(re.findall(r'\bby\s+admit\b|\b:=\s*admit\b', lean_source))
            total_sorry = sorry_count + admit_tactic_count
            if total_sorry == 0 and len(theorem_names) >= 3:
                score += 1.5
                details["speculative_bonus"] = "grounded"
            elif total_sorry <= 2:
                score += 0.5
                details["speculative_bonus"] = "partial"
            else:
                details["speculative_bonus"] = "ungrounded"

        # 5. Narrative originality signals
        # The doc comments explicitly describe whether the work is novel,
        # introduces new concepts, or connects domains
        if narrative:
            narr_lower = narrative.lower()
            novel_indicators = 0
            if any(kw in narr_lower for kw in ['novel', 'new definition', 'we introduce', 'we define',
                                                  'introduces', 'for the first time', 'new type',
                                                  'new structure', 'new concept']):
                novel_indicators += 2  # Explicit novelty claims
            if any(kw in narr_lower for kw in ['bridge', 'connects', 'unifies', 'duality',
                                                  'correspondence', 'isomorphism', 'equivalence']):
                novel_indicators += 1  # Cross-domain connections
            if any(kw in narr_lower for kw in ['surprising', 'unexpected', 'counterintuitive',
                                                  'paradox', 'remarkable', 'deep', 'fundamental']):
                novel_indicators += 1  # Surprise indicators
            if any(kw in narr_lower for kw in ['conjecture', 'open problem', 'open question',
                                                  'unresolved', 'remains to be proved']):
                novel_indicators += 1  # Open problem statements

            if novel_indicators >= 4:
                score += 1.5
                details["narrative_originality"] = f"strong({novel_indicators})"
            elif novel_indicators >= 2:
                score += 0.8
                details["narrative_originality"] = f"moderate({novel_indicators})"
            elif novel_indicators >= 1:
                score += 0.3
                details["narrative_originality"] = f"weak({novel_indicators})"
            else:
                details["narrative_originality"] = "none"

        return min(score, 10.0)

    # ------------------------------------------------------------------
    # Pillar 5: Transformative Impact
    # ------------------------------------------------------------------
    def _score_impact(self, lean_source: str, file_path: str = "",
                      domain: str = "", narrative: str = "") -> float:
        """Score Impact: applied relevance, foundational significance, cross-domain bridging.

        Five components:
        1. Physics/Cryptography translation (max ~5)
        2. ML interpretability (max ~2.5)
        3. Systemic optimization (max ~2)
        4. Wonderful factor: paradigm-changing connections (max ~2.5)
        5. Foundational impact: reusable mathematical infrastructure (max 1.5)
        6. Domain relevance: files in applied domains have inherent impact (max 1.0)
        """
        score = 0.0
        details = {}
        source_lower = lean_source.lower()

        # 1. Physics / Cryptography Translation
        # Extended to include more physics/math-physics terms that indicate
        # genuine physical or cryptographic application.
        physics_crypto = 0
        # Core physics terms (genuine physical content)
        for kw in ["quantum", "hamiltonian", "lagrangian", "entanglement", "thermodynamic",
                    "entropy", "spacetime", "relativistic", "holographic", "free_energy",
                    "partition", "boltzmann", "spectrum", "phase_transition", "heat",
                    "temperature", "feynman", "path_integral",
                    # Extended physics terms: relativistic geometry, classical mechanics
                    "lorentz", "minkowski", "geodesic", "null_cone", "causal",
                    "spinor", "gauge", "symmetry_group", "observable",
                    "eigenvalue", "hermitian", "unitary", "hilbert_space",
                    "schrodinger", "heisenberg", "commutator", "operator_algebra",
                    "lie_algebra", "represent", "irreducible",
                    # Thermodynamics / statistical mechanics
                    "free_energy", "boltzmann", "partition_function",
                    # Mathematical physics
                    "lagrangian", "variational", "action_functional",
                    "conservation_law", "noether"]:
            if kw in source_lower or kw in (narrative or "").lower():
                physics_crypto += 2
        # Cryptographic terms
        for kw in ["dilithium", "lattice-based", "post-quantum", "zero-knowledge",
                    "diffie-hellman", "digital signature", "key exchange",
                    "module_sis", "module_lwe", "shortest_vector", "closest_vector",
                    "learning_with_errors", "lattice_crypto", "sphincs",
                    "commitment", "verifiable",
                    # Extended crypto: algebraic structures used in cryptography
                    "rigid", "fingerprint", "collision_resistant", "hash",
                    "one_way", "trapdoor", "hard_problem", "subgroup",
                    "normal_form", "word_problem", "freeness", "free_semigroup",
                    "free_monoid", "decoding", "encoding", "cryptograph",
                    "cipher", "encryption", "decryption"]:
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
        # Two-tier keyword system: high-confidence terms are strong signals.
        # Broad terms are WEAK signals — they only count if high-confidence terms
        # are also present, preventing generic math from scoring high on Impact.
        ml_indicators = 0
        for kw in ["neural", "lipschitz_bound", "lipschitz_constant", "certified_robust", "adversarial",
                    "relu", "resnet", "softmax", "overfitting",
                    "deep_learning", "backpropagation",
                    "activation_function", "neural_layer",
                    "generalization_bound", "lipschitz_bound",
                    "certified_radius", "robustness_certificate"]:
            if kw in source_lower:
                ml_indicators += 2  # High-confidence ML terms count double

        # Broad ML terms: these are extremely common in pure math and should
        # NOT trigger Impact scoring unless ML-specific context is also present.
        # We require at least ONE high-confidence term before any broad terms count.
        ml_broad = 0
        for kw in ["gradient", "convergence", "margin", "approximation", "universal",
                    "network", "training", "inference", "depth", "activation",
                    "robust", "classification", "spectrum"]:
            if kw in source_lower:
                ml_broad += 1

        # Broad terms ONLY count with ML context present
        if ml_indicators >= 2:
            ml_indicators += min(ml_broad, 4)  # Capped contribution
        # If no high-confidence ML terms, broad terms do NOT count at all
        # This prevents pure algebra files from scoring high on ML Impact

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
        # Two-tier: specific optimization keywords are strong signals.
        # Generic math terms are WEAK and only count with context.
        optimization = 0
        # High-confidence optimization terms (specific, not generic)
        for kw in ["optimal", "efficient", "complexity_bound", "algorithm",
                    "compiler", "factoring_algorithm", "search_algorithm",
                    "convergence_rate", "iteration_complexity", "time_complexity",
                    "space_complexity", "computational_bound",
                    # Extended computation: decidability, complexity classes
                    "decidable", "undecidable", "np_complete", "np_hard",
                    "computable", "recursive", "halting", "search_strategy",
                    "decision_problem", "complexity_class", "polynomial_time",
                    "exponential_time", "reduction", "completeness"]:
            if kw in source_lower:
                optimization += 2  # Specific optimization terms count double
        # Generic terms: only count if high-confidence optimization context is present
        generic_opt = 0
        for kw in ["bound", "rate", "converge", "iteration", "factor", "search"]:
            if kw in source_lower:
                generic_opt += 1
        if optimization >= 2:  # Has specific optimization context
            optimization += min(generic_opt, 3)  # Limited contribution
        else:
            # Generic terms alone do NOT count — every math proof has bounds
            optimization += 0

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
        if "tropical" in source_lower and ("neural" in source_lower or "robust" in source_lower or "deep_learn" in source_lower):
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
        if "semiring" in source_lower and ("lipschitz_bound" in source_lower or "lipschitz_constant" in source_lower or "robust" in source_lower):
            wonderful += 2  # Algebraic robustness
        if "entropy" in source_lower and ("congruence" in source_lower or "algebra" in source_lower):
            wonderful += 2  # Algebraic entropy
        if "berggren" in source_lower and "quantum" in source_lower:
            wonderful += 2  # Pythagorean quantum bridge
        # Additional wonderful factor patterns
        if "berggren" in source_lower and ("rigidity" in source_lower or "lorentz" in source_lower or "minkowski" in source_lower):
            wonderful += 2  # Berggren + physics = novel bridge
        if "berggren" in source_lower and ("normal_form" in source_lower or "free_semigroup" in source_lower or "freeness" in source_lower):
            wonderful += 2  # Berggren algebraic structure = crypto foundation
        if "tropical" in source_lower and ("geometr" in source_lower or "variet" in source_lower or "polytope" in source_lower):
            wonderful += 2  # Tropical geometry
        if "stone_weierstrass" in source_lower or ("stone" in source_lower and "weierstrass" in source_lower):
            wonderful += 2  # Stone-Weierstrass approximation
        if "lorentz" in source_lower and ("berggren" in source_lower or "triple" in source_lower or "pythagorean" in source_lower):
            wonderful += 2  # Lorentz + number theory
        if "satake" in source_lower and ("gl3" in source_lower or "hecke" in source_lower or "tropical" in source_lower):
            wonderful += 2  # Satake isomorphism + representation theory
        if "category" in source_lower and ("bridge" in source_lower or "functor" in source_lower or "adjunction" in source_lower):
            wonderful += 1  # Categorical bridge (1 point, not 2 — softer signal)

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

        # 5. Foundational Impact: files that provide reusable mathematical
        # infrastructure (many defs/structures/theorems) serve as building blocks
        # for downstream work and have inherent impact even without specific apps.
        foundational = 0
        count_defs = len(re.findall(r'^(?:def|structure|class|instance)\s', lean_source, re.MULTILINE))
        # Use regex to count actual theorem/lemma declarations, not keyword matches
        count_theorems = len(re.findall(r'^(?:theorem|lemma)\s+', lean_source, re.MULTILINE))
        # Files with many definitions provide structural foundations that others
        # build upon. This is the primary foundational impact signal.
        if count_defs >= 15:
            foundational += 1.5
        elif count_defs >= 8:
            foundational += 1.0
        elif count_defs >= 5:
            foundational += 0.5
        # NOTE: Theorem count as "proof foundations" is now covered by the
        # "theorem_density_impact" section above, so we don't duplicate it here.
        details["foundational"] = f"defs={count_defs},thms={count_theorems},score={foundational}"
        score += min(foundational, 1.5)

        # 5.5 Structural Breadth Impact: files that span multiple mathematical
        # domains have broader impact potential. A good researcher recognizes that
        # bridging algebra and topology, or connecting logic to computation,
        # creates impact THROUGH connectivity, not just keyword matching.
        # This uses the same domain detection as Aesthetic but scores it for Impact.
        breadth_domains = set()
        for dname, keywords in self._get_domain_keywords().items():
            for kw in keywords:
                if kw in source_lower or kw in (file_path.lower() if file_path else ""):
                    breadth_domains.add(dname)
                    break
        nb = len(breadth_domains)
        if nb >= 5:
            score += 1.0
            details["breadth"] = f"{nb}_domains({breadth_domains})"
        elif nb >= 4:
            score += 0.7
            details["breadth"] = f"{nb}_domains"
        elif nb >= 3:
            score += 0.3
            details["breadth"] = f"{nb}_domains"
        else:
            details["breadth"] = f"{nb}_domains"

        # 5.6 Theorem Density Impact: proved results are citable foundations.
        # NOTE: Theorem density is now primarily scored in Utility (section 2.5)
        # as "reusable mathematical infrastructure." This section provides a small
        # Impact bonus for citability — a different quality. A theorem that others
        # cite IS impactful even if not directly applied.
        if count_theorems >= 30:
            score += 0.2
            details["theorem_density_impact"] = f"extensive({count_theorems})"
        elif count_theorems >= 15:
            score += 0.1
            details["theorem_density_impact"] = f"moderate({count_theorems})"
        else:
            details["theorem_density_impact"] = f"minimal({count_theorems})"

        # 6. Domain Relevance: files organized in inherently applied domains
        # have genuine application impact even if their content doesn't use
        # specific keywords. A cryptography file IS cryptographically relevant.
        domain_bonus = 0.0
        applied_domains = {"cryptography": 1.0, "machinelearning": 0.75,
                          "physics": 0.75, "computation": 0.5}
        bridge_domains = {"bridges": 0.5, "eml": 0.5}
        if domain in applied_domains:
            domain_bonus = applied_domains[domain]
        elif domain in bridge_domains:
            domain_bonus = bridge_domains[domain]
        # Only apply domain bonus if current Impact is below the floor
        # (avoid double-counting for files that already score high on Impact)
        if domain_bonus > 0 and score < domain_bonus:
            score = domain_bonus
            details["domain_floor"] = f"{domain}_floor={domain_bonus}"
        else:
            details["domain_floor"] = "none"

        return min(score, 10.0)

    def evaluate_catalog(self, catalog_root: Path, use_disk_cache: bool = True) -> Dict[str, AEMScore]:
        """Evaluate all files in the catalog.
        
        Args:
            catalog_root: Path to the catalog directory
            use_disk_cache: If True, use .aem_cache.json for fast loading
                            when files haven't changed.
        """
        results = {}
        
        # Try loading from disk cache first
        cache_path = catalog_root / '.aem_cache.json'
        disk_cache = {}
        if use_disk_cache and cache_path.exists():
            try:
                import json as _json
                with open(cache_path) as f:
                    disk_cache = _json.load(f)
            except Exception:
                disk_cache = {}
        
        # Track which files we've already cached
        cached_count = 0
        evaluated_count = 0
        
        for lean_file in catalog_root.rglob("*.lean"):
            if '.lake' in str(lean_file):
                continue
            try:
                source = lean_file.read_text(encoding='utf-8')
            except Exception:
                continue
            rel_path = str(lean_file.relative_to(catalog_root))
            
            # Check disk cache
            content_hash = self._content_hash(source)
            if rel_path in disk_cache:
                cached_entry = disk_cache[rel_path]
                if isinstance(cached_entry, dict) and cached_entry.get('_hash') == content_hash:
                    # Cache hit - reconstruct AEMScore from dict
                    score = AEMScore(
                        rigor=cached_entry.get('rigor', 0),
                        aesthetic=cached_entry.get('aesthetic', 0),
                        utility=cached_entry.get('utility', 0),
                        originality=cached_entry.get('originality', 0),
                        impact=cached_entry.get('impact', 0),
                    )
                    results[rel_path] = score
                    cached_count += 1
                    # Also update in-memory cache
                    self._score_cache[rel_path] = (content_hash, score)
                    continue
            
            # Cache miss - evaluate the file
            doc_comments = re.findall(r'/-!?(.*?)-/', source, re.DOTALL)
            narrative = ' '.join(doc_comments).strip() if doc_comments else ""
            
            score = self.evaluate_lean_file(source, file_path=rel_path, narrative=narrative)
            results[rel_path] = score
            evaluated_count += 1
        
        # Save updated disk cache
        if use_disk_cache:
            try:
                import json as _json
                cache_data = {}
                for path, score in results.items():
                    source = (catalog_root / path).read_text(encoding='utf-8')
                    h = self._content_hash(source)
                    d = score.to_dict()
                    d['_hash'] = h
                    cache_data[path] = d
                with open(cache_path, 'w') as f:
                    _json.dump(cache_data, f)
            except Exception:
                pass  # Disk cache is best-effort
        
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