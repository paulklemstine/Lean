#!/usr/bin/env python3
"""MillennialProblems: Curated database of famous unsolved mathematical problems.

Provides a structured list of well-known open problems (Millennium Prize problems,
famous conjectures, and catalog-connected open questions) that Aristotle can target.
Each problem includes a tractable sub-problem suitable for formal verification.
"""

from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class MillennialProblem:
    """A famous unsolved mathematical problem with a tractable sub-problem."""
    name: str
    field: str
    description: str
    formal_statement: str
    catalog_domains: List[str]
    proof_strategy_hints: List[str]
    difficulty: str  # "open_problem", "phd", "master"
    relevance_to_catalog: str
    sub_problem: str
    sub_problem_formal: str


MILLENNIAL_PROBLEMS: List[MillennialProblem] = [
    # === MILLENNIUM PRIZE PROBLEMS ===
    MillennialProblem(
        name="Riemann Hypothesis",
        field="Number Theory",
        description="All non-trivial zeros of the Riemann zeta function have real part 1/2. "
                    "The most important unsolved problem in mathematics, connecting prime "
                    "distribution to complex analysis.",
        formal_statement="∀ s : ℂ, ζ(s) = 0 → (Re(s) = 1 ∨ Re(s) = 1/2)",
        catalog_domains=["Algebra", "Bridges"],
        proof_strategy_hints=[
            "Prove that the Berggren tree zeta function (analog of Riemann zeta on Pythagorean triples) has all zeros on the critical line",
            "Establish a functional equation for the tropical zeta function and prove its zeros are real",
            "Prove that the prime counting error bound |π(x) - li(x)| = O(x^{1/2+ε}) for specific x ranges",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has Pythagorean and tropical number theory infrastructure. "
                            "Proving a tropical analogue of RH would be a breakthrough for tropical geometry.",
        sub_problem="Tropical Riemann Hypothesis: Prove that all zeros of the tropical zeta function "
                    "ζ_trop(s) = ⊕_p (0 ⊗ p^{-s}) lie on the tropical critical line",
        sub_problem_formal="theorem tropical_riemann_hypothesis : ∀ s, zeta_trop s = ⊥ → on_critical_line_trop s",
    ),
    MillennialProblem(
        name="P vs NP",
        field="Computational Complexity",
        description="Determine whether every problem whose solution can be verified in polynomial "
                    "time can also be solved in polynomial time. The most impactful question in "
                    "computer science.",
        formal_statement="P = NP ↔ ∀ (L : Language), PolyVerifiable L → PolyDecidable L",
        catalog_domains=["Computation", "Logic", "Cryptography"],
        proof_strategy_hints=[
            "Prove that tropical 3-SAT is NP-complete over the tropical semiring (min-plus algebra)",
            "Show that tropical circuit complexity is strictly lower than classical circuit complexity for certain functions",
            "Prove a super-polynomial lower bound on tropical circuit size for an explicit function",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has Computation and Cryptography domains with circuit complexity infrastructure.",
        sub_problem="Tropical P vs Tropical NP: Prove that tropical 3-SAT over the min-plus semiring "
                    "is NP-complete and that tropical 2-SAT is polynomial-time decidable",
        sub_problem_formal="theorem tropical_3_sat_np_complete : tropical_three_sat ∈ NP_trop ∧ tropical_three_sat ∈ NP_hard_trop",
    ),
    MillennialProblem(
        name="Birch and Swinnerton-Dyer Conjecture",
        field="Algebraic Geometry / Number Theory",
        description="The rank of the Mordell-Weil group of an elliptic curve over Q equals the order "
                    "of vanishing of its L-function at s=1.",
        formal_statement="rank(E(ℚ)) = ord_{s=1} L(E, s)",
        catalog_domains=["Algebra", "Pythagorean", "Bridges"],
        proof_strategy_hints=[
            "Prove BSD for a specific family of Pythagorean elliptic curves",
            "Establish the rank formula for tropical elliptic curves over the tropical semiring",
            "Connect the Berggren tree structure to elliptic curve ranks via descent",
        ],
        difficulty="open_problem",
        relevance_to_catalog="Pythagorean triples parameterize rational points on elliptic curves. "
                            "The Catalog's Pythagorean infrastructure provides concrete test cases.",
        sub_problem="Prove that Pythagorean elliptic curves x² + y² = z² + n satisfy BSD "
                    "for n = 1, 2, 3 by computing the rank and L-function order of vanishing",
        sub_problem_formal="theorem pythagorean_elliptic_BSD (n : ℕ) (hn : n ≤ 3) : rank (E_pythag n) = ord_L (E_pythag n) 1",
    ),
    MillennialProblem(
        name="Navier-Stokes Existence and Smoothness",
        field="Partial Differential Equations",
        description="Prove or disprove that smooth solutions to the Navier-Stokes equations "
                    "always exist in three dimensions.",
        formal_statement="∀ (f : ℝ³ → ℝ³) (smooth), ∃ u : Solution NS, Smooth u",
        catalog_domains=["Physics", "EML"],
        proof_strategy_hints=[
            "Prove that EML closures satisfy a tropical Navier-Stokes regularity condition",
            "Establish that tropical PDEs have smooth solutions via min-plus viscosity theory",
            "Prove finite-time blowup cannot occur in the tropical Navier-Stokes equation",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The EML domain has closure and approximation infrastructure that can model "
                            "fluid flow regularity.",
        sub_problem="Prove that the tropical Navier-Stokes equation (min-plus analogue) has smooth "
                    "solutions for all time, establishing a tropical regularity theorem",
        sub_problem_formal="theorem tropical_navier_stokes_smooth : ∀ f, ∃ u, tropical_NS_solution u f ∧ smooth_trop u",
    ),
    MillennialProblem(
        name="Hodge Conjecture",
        field="Algebraic Geometry",
        description="Every Hodge class on a projective complex manifold is a rational linear "
                    "combination of cohomology classes of algebraic subvarieties.",
        formal_statement="∀ (X : ProjectiveComplex) (h : HodgeClass X), IsAlgebraic h",
        catalog_domains=["Algebra", "Geometry", "Bridges"],
        proof_strategy_hints=[
            "Prove a tropical Hodge theorem: tropical Hodge classes are tropical linear combinations",
            "Establish that Berggren tree cohomology classes satisfy a tropical Hodge decomposition",
            "Prove the tropical analogue for tropical curves of genus g",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Geometry and Algebra domains have sheaf and cohomology infrastructure.",
        sub_problem="Prove the tropical Hodge theorem: on a tropical projective variety, "
                    "every tropical Hodge class is a tropical cycle class",
        sub_problem_formal="theorem tropical_hodge (X : TropicalProjective) (h : TropicalHodgeClass X) : IsTropicalCycleClass h",
    ),
    MillennialProblem(
        name="Yang-Mills Mass Gap",
        field="Mathematical Physics",
        description="Prove that quantum Yang-Mills theory on R^4 exists and has a mass gap: "
                    "the lowest-lying particle state has strictly positive mass.",
        formal_statement="MassGap YM₄ ∧ Exists YM₄",
        catalog_domains=["Physics", "EML", "Computation"],
        proof_strategy_hints=[
            "Prove that the tropical Yang-Mills action has a spectral gap bounded below by the tropical mass",
            "Connect EML closure depth to the Yang-Mills spectral gap",
            "Prove that min-plus gauge theory on tropical R^4 has a mass gap via tropical lattice theory",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Physics domain has gauge theory infrastructure; EML has closure depth theorems.",
        sub_problem="Prove that tropical Yang-Mills theory on min-plus R^4 has a strictly positive "
                    "spectral gap (tropical mass gap theorem)",
        sub_problem_formal="theorem tropical_yang_mills_mass_gap : spectral_gap tropical_YM₄ > 0",
    ),

    # === FAMOUS CONJECTURES ===
    MillennialProblem(
        name="Goldbach's Conjecture",
        field="Number Theory",
        description="Every even integer greater than 2 is the sum of two primes.",
        formal_statement="∀ n : ℕ, n > 2 → Even n → ∃ p q, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n",
        catalog_domains=["Algebra", "Pythagorean"],
        proof_strategy_hints=[
            "Prove Goldbach for a density 1 subset of even numbers using tropical sieve methods",
            "Establish that Berggren tree paths connect primes that sum to even numbers",
            "Prove a tropical Goldbach: every tropical even number is the tropical sum of two tropical primes",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has prime infrastructure in Algebra and Pythagorean domains.",
        sub_problem="Prove the ternary Goldbach conjecture: every odd number > 5 is the sum of three primes",
        sub_problem_formal="theorem ternary_goldbach (n : ℕ) (hn : n > 5) (ho : Odd n) : ∃ p q r, Nat.Prime p ∧ Nat.Prime q ∧ Nat.Prime r ∧ p + q + r = n",
    ),
    MillennialProblem(
        name="Twin Prime Conjecture",
        field="Number Theory",
        description="There are infinitely many pairs of primes that differ by 2.",
        formal_statement="∀ N : ℕ, ∃ p > N, Nat.Prime p ∧ Nat.Prime (p + 2)",
        catalog_domains=["Algebra", "Pythagorean"],
        proof_strategy_hints=[
            "Prove bounded gap: lim inf(p_{n+1} - p_n) < ∞ (Zhang's theorem, simplified proof)",
            "Prove that the tropical prime distribution has bounded gaps",
            "Establish that Pythagorean primes have bounded gaps on the Berggren tree",
        ],
        difficulty="open_problem",
        relevance_to_catalog="Pythagorean domain has prime triple infrastructure.",
        sub_problem="Prove that lim inf(p_{n+1} - p_n) ≤ 246 (Polymath project bound)",
        sub_problem_formal="theorem bounded_prime_gaps : ∃ (B : ℕ), ∀ n, ∃ p, Nat.Prime p ∧ Nat.Prime (p + B)",
    ),
    MillennialProblem(
        name="Collatz Conjecture",
        field="Number Theory / Dynamical Systems",
        description="Starting from any positive integer, repeatedly applying f(n) = n/2 if even, "
                    "3n+1 if odd, always reaches 1.",
        formal_statement="∀ n : ℕ, n > 0 → CollatzTrajectory n ∋ 1",
        catalog_domains=["Algebra", "Computation"],
        proof_strategy_hints=[
            "Prove Collatz converges for numbers of the form 2^k (trivial) then extend to 2^k - 1",
            "Establish that the tropical Collatz map (min-plus version) always reaches a fixed point",
            "Prove Collatz for specific residue classes using EML closure techniques",
        ],
        difficulty="open_problem",
        relevance_to_catalog="Computation domain has reachability analysis; Algebra has number theory.",
        sub_problem="Prove that the tropical Collatz map T_trop(x) = min(x/2, 3x+1) on the tropical "
                    "semiring reaches the tropical zero from any tropical natural number",
        sub_problem_formal="theorem tropical_collatz_convergence (n : Tropicalℕ) : tropical_collatz_trajectory n ∋ ⊥",
    ),
    MillennialProblem(
        name="abc Conjecture",
        field="Number Theory",
        description="For any ε > 0, only finitely many coprime triples (a,b,c) with a+b=c satisfy "
                    "c > rad(abc)^(1+ε), where rad is the radical (product of distinct primes).",
        formal_statement="∀ ε > 0, FinitelyMany (λ (a,b,c), Coprime a b c ∧ a + b = c ∧ c > rad(abc)^(1+ε))",
        catalog_domains=["Algebra", "Pythagorean", "Bridges"],
        proof_strategy_hints=[
            "Prove a tropical abc theorem: tropical radical bounds the tropical sum",
            "Establish that Pythagorean triples satisfy abc with explicit bounds",
            "Prove abc for function fields using tropical geometry methods",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has Pythagorean triple and algebraic infrastructure.",
        sub_problem="Prove the abc conjecture for function fields over finite fields, or prove that "
                    "Pythagorean triples (a,b,c) satisfy c < rad(abc)^3",
        sub_problem_formal="theorem pythagorean_abc (a b c : ℕ) (h : IsPythagoreanTriple a b c) : c < (rad (a*b*c))^3",
    ),

    # === CATALOG-CONNECTED OPEN PROBLEMS ===
    MillennialProblem(
        name="Tropical Satake Isomorphism (Surjectivity)",
        field="Tropical Geometry / Representation Theory",
        description="The tropical Satake isomorphism for GL_n maps the tropical Hecke algebra "
                    "isomorphically onto the tropical representation ring. Surjectivity is proved for "
                    "GL_2; proving it for GL_3+ is open.",
        formal_statement="TropicalSatake.GL_n_surjective",
        catalog_domains=["Tropical", "Algebra", "Bridges"],
        proof_strategy_hints=[
            "Prove surjectivity for GL_3 by constructing explicit preimages under the tropical Satake map",
            "Use the tropical Plancherel formula to establish norm compatibility",
            "Connect to crystal bases via tropical R-matrices",
        ],
        difficulty="phd",
        relevance_to_catalog="The Catalog has tropical Satake for GL_2 already proved. GL_3 is the natural next step.",
        sub_problem="Prove that the tropical Satake map for GL_3 is surjective by constructing explicit "
                    "preimages for each tropical representation",
        sub_problem_formal="theorem tropical_satake_surjective_GL3 : Function.Surjective (tropicalSatakeMap GL₃)",
    ),
    MillennialProblem(
        name="Tropical Certified Robustness (General)",
        field="Tropical Geometry / Machine Learning",
        description="Prove that the tropical degree of a ReLU neural network provides a certified "
                    "L-infinity robustness bound. Proved for binary classifiers; the general case is open.",
        formal_statement="∀ (f : TropicalPolyNet), CertifiedRobust f (tropicalDegree f)",
        catalog_domains=["MachineLearning", "Tropical", "Bridges"],
        proof_strategy_hints=[
            "Extend the binary classifier proof to multi-class via tropical linear separability",
            "Prove that tropical degree bounds the Lipschitz constant of tropical rational functions",
            "Establish that min-plus polytope regions give certified robustness certificates",
        ],
        difficulty="phd",
        relevance_to_catalog="The Catalog has tropical robustness for binary classifiers already proved.",
        sub_problem="Prove that for any tropical rational function f with tropical degree d, "
                    "the L-infinity robustness radius is at least 1/d on any region where f is linear",
        sub_problem_formal="theorem tropical_robustness_general (f : TropicalRational) (d : ℕ) (hd : tropicalDegree f = d) : CertifiedRobust f (1/d)",
    ),
    MillennialProblem(
        name="EML Universal Computation",
        field="Emergent Meta-Language / Computation",
        description="Prove that EML closures achieve universal computation with provable depth bounds "
                    "related to Kolmogorov complexity. The key result: EML depth O(K(f)/ε) for "
                    "epsilon-approximation of any computable function.",
        formal_statement="∀ (f : ℕ → ℝ) (Computable f) (ε > 0), ∃ (n : ℕ), EMLDepth (Approx f ε) ≤ C * K(f) / ε",
        catalog_domains=["EML", "MachineLearning", "Computation"],
        proof_strategy_hints=[
            "Prove that EML closures can simulate any Turing machine with bounded depth overhead",
            "Establish that EML depth lower-bounds Kolmogorov complexity",
            "Use Stone-Weierstrass to prove EML density in C(K) for compact K, then bound depth",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has EML closure definitions and Stone-Weierstrass infrastructure.",
        sub_problem="Prove that EML closures can represent any boolean circuit with depth at most "
                    "3 times the circuit depth, establishing EML circuit simulation",
        sub_problem_formal="theorem eml_circuit_simulation (c : BooleanCircuit) : ∃ (n : ℕ), EMLDepth (simulate c) ≤ 3 * circuitDepth c",
    ),
    MillennialProblem(
        name="Berggren Tree Group Structure",
        field="Pythagorean Geometry / Group Theory",
        description="Prove that the Berggren matrices form a group under matrix multiplication "
                    "and that this group is a subgroup of SL(2,Z).",
        formal_statement="IsSubgroup berggrenMats SL(2,ℤ)",
        catalog_domains=["Pythagorean", "Algebra", "Cryptography"],
        proof_strategy_hints=[
            "Prove closure: the product of two Berggren matrices is a Berggren matrix",
            "Prove inverses: each Berggren matrix has an inverse in the group",
            "Establish that the group order is infinite and compute its generators",
        ],
        difficulty="phd",
        relevance_to_catalog="The Catalog has extensive Berggren tree infrastructure in the Pythagorean domain.",
        sub_problem="Prove that the three Berggren matrices A, B, C generate a free subgroup of SL(2,Z) "
                    "and that the group operation on Pythagorean triples corresponds to matrix multiplication",
        sub_problem_formal="theorem berggren_free_subgroup : IsFreeSubgroup berggrenMats SL(2,ℤ)",
    ),
    MillennialProblem(
        name="Tropical Information Theory Foundation",
        field="Tropical Geometry / Information Theory",
        description="Found tropical information theory: define tropical entropy, tropical mutual "
                    "information, and prove a tropical data processing inequality.",
        formal_statement="TropicalDataProcessingInequality",
        catalog_domains=["Tropical", "Bridges", "MachineLearning"],
        proof_strategy_hints=[
            "Define tropical entropy as H_trop(X) = ⊕_x (p(x) ⊗ log_trop(p(x))) and prove it's concave",
            "Prove that tropical mutual information I_trop(X;Y) ≤ I_trop(X;Z) when X→Y→Z forms a Markov chain",
            "Establish that tropical channel capacity equals tropical mutual information maximized over input distributions",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has tropical semiring and machine learning infrastructure.",
        sub_problem="Define tropical entropy H_trop over the min-plus semiring and prove that it is "
                    "concave and achieves its maximum at the uniform distribution",
        sub_problem_formal="theorem tropical_entropy_concave (X : FinDist n) : Concave (tropical_entropy X) ∧ Maximum tropical_entropy (uniform_dist n)",
    ),
    MillennialProblem(
        name="Non-Archimedean Central Limit Theorem",
        field="Tropical Probability Theory",
        description="Prove a tropical central limit theorem: the sum of independent tropical "
                    "random variables converges to a tropical Gaussian distribution.",
        formal_statement="TropicalCLT : TropicalSumConvergesTo TropicalGaussian",
        catalog_domains=["Tropical", "Bridges", "Logic"],
        proof_strategy_hints=[
            "Define tropical random variables as measurable functions over the tropical semiring",
            "Prove that the tropical characteristic function converges to the tropical Gaussian CF",
            "Use Maslov dequantization to connect classical CLT to tropical CLT",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has tropical algebra and logic infrastructure.",
        sub_problem="Prove that for i.i.d. tropical random variables X_i with finite tropical mean μ_trop "
                    "and tropical variance σ²_trop, the tropical average converges to μ_trop in tropical probability",
        sub_problem_formal="theorem tropical_law_of_large_numbers {X : ι → TropicalRV} (hiid : TropicalIID X) : TropicalProb (|tropical_avg X - μ_trop| > ε) → ⊥",
    ),
    MillennialProblem(
        name="Pythagorean Quantum Advantage",
        field="Quantum Computing / Cryptography",
        description="Prove that Berggren-based Pythagorean gate sets achieve provable quantum advantage "
                    "for Hamiltonian simulation problems: O(n log n) vs Ω(n²) classical.",
        formal_statement="BerggrenQuantumAdvantage : Depth BerggrenSim H ≤ O(n log n) ∧ Depth ClassicalSim H ≥ Ω(n²)",
        catalog_domains=["Pythagorean", "Physics", "Cryptography"],
        proof_strategy_hints=[
            "Construct Pythagorean quantum gates from Berggren matrices and prove they form a universal gate set",
            "Prove that Berggren tree depth for n-qubit simulation is O(n log n)",
            "Establish a classical lower bound of Ω(n²) for the same simulation",
        ],
        difficulty="open_problem",
        relevance_to_catalog="The Catalog has Berggren tree and Pythagorean infrastructure.",
        sub_problem="Prove that the Berggren matrices generate a universal quantum gate set by "
                    "showing they can approximate any unitary to epsilon precision",
        sub_problem_formal="theorem berggren_universal (U : Unitary n) (ε : ℝ) (hε : ε > 0) : ∃ (gates : List BerggrenGate), dist (apply gates) U < ε",
    ),
]


def get_millennial_problem(index: int) -> MillennialProblem:
    """Get a millennial problem by index (cycles through the list)."""
    return MILLENNIAL_PROBLEMS[index % len(MILLENNIAL_PROBLEMS)]


def get_problems_by_domain(domain: str) -> List[MillennialProblem]:
    """Get all millennial problems relevant to a given domain."""
    domain_lower = domain.lower()
    return [
        p for p in MILLENNIAL_PROBLEMS
        if any(d.lower() == domain_lower for d in p.catalog_domains)
    ]


def get_problems_by_difficulty(difficulty: str) -> List[MillennialProblem]:
    """Get all millennial problems at a given difficulty level."""
    return [p for p in MILLENNIAL_PROBLEMS if p.difficulty == difficulty]


def format_problem_for_prompt(problem: MillennialProblem) -> str:
    """Format a millennial problem as a rich prompt section for Aristotle."""
    return f"""## MILLLENNIUM-LEVEL TARGET: {problem.name}

**Field**: {problem.field}
**Difficulty**: {problem.difficulty}
**Catalog Domains**: {', '.join(problem.catalog_domains)}

**The Full Problem**: {problem.description}

**Formal Statement**: `{problem.formal_statement}`

**Your Assignment** (tractable sub-problem):
{problem.sub_problem}

**Sub-problem Formal Statement**: `{problem.sub_problem_formal}`

**Proof Strategy Hints**:
{chr(10).join(f'  {i+1}. {hint}' for i, hint in enumerate(problem.proof_strategy_hints))}

**Catalog Relevance**: {problem.relevance_to_catalog}

This is a sub-problem of one of the most important open problems in mathematics.
Attack it with every tool available. Build on existing catalog theorems.
If you can prove even a special case, it would be a significant result.
"""