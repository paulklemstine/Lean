#!/usr/bin/env python3
"""One-time script: Generate a rich, actionable future_directions.json.

Seeds are cycle-sized — specific enough for Aristotle to make real progress
in a single research cycle, not vague "solve millennium problem" directives.
"""
import json, sys, os
from datetime import datetime, timezone
from pathlib import Path

# Add parent to path so we can import research_memory
sys.path.insert(0, str(Path(__file__).parent))

def sd(title, desc, domains, priority=0.85):
    """Create a seed direction dict."""
    sd.counter += 1
    return {
        "id": f"seed_{sd.counter:03d}",
        "title": title,
        "description": desc,
        "source_exp_id": "seed",
        "source_path": "seed:manual_v5",
        "domains": domains,
        "proof_strategy": "",
        "research_mode": "prove",
        "depth_estimate": 3,
        "priority_score": priority,
        "status": "available",
        "consumed_by_exp_id": "",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
sd.counter = 0

SEEDS = [
    # ════════════════════════════════════════════
    # NUMBER THEORY — Actionable sub-problems
    # ════════════════════════════════════════════
    sd("Goldbach Verification Framework",
       "Formalize Goldbach's conjecture in Lean 4. Prove the conjecture holds for all even n ≤ 10^6 computationally, formalize Vinogradov's theorem (every sufficiently large odd number is the sum of three primes), and construct the Hardy-Littlewood circle method framework for additive problems. Deliver a working Lean verification tactic.",
       ["NumberTheory", "Algebra"], 0.95),
    sd("Twin Prime Gaps: Zhang-Maynard Formalization",
       "Formalize the Maynard-Tao sieve in Lean 4 and prove that lim inf(p_{n+1} - p_n) ≤ 246. Construct the GPY sieve weight optimization as a variational problem. Prove the key lemma on the level of distribution of primes in arithmetic progressions.",
       ["NumberTheory"], 0.93),
    sd("Riemann Zeta: Zero-Free Regions and Density Estimates",
       "Formalize the classical zero-free region of the Riemann zeta function: ζ(s) ≠ 0 for Re(s) > 1 - c/log(|Im(s)|+2). Prove the Riemann-von Mangoldt formula N(T) ~ T/(2π) log(T/(2πe)). Formalize the connection between zero-free regions and prime counting error bounds.",
       ["NumberTheory", "Analysis"], 0.94),
    sd("Collatz Stopping Times: Density Analysis",
       "Prove that the set of positive integers with finite Collatz stopping time has density 1. Formalize the Terras density result and the Krasikov-Lagarias bound. Construct the 3-adic analysis of the Collatz map and prove local convergence properties.",
       ["NumberTheory", "Computation"], 0.82),
    sd("Perfect Numbers: Structure of Even Perfects",
       "Formalize the Euclid-Euler theorem: n is an even perfect number iff n = 2^(p-1)(2^p - 1) where 2^p - 1 is prime. Prove that odd perfect numbers, if they exist, must have at least 101 prime factors (Nielsen's bound). Formalize the abundancy index σ(n)/n framework.",
       ["NumberTheory"], 0.87),
    sd("Continued Fractions and Diophantine Approximation",
       "Formalize the theory of continued fractions in Lean 4: convergents, best rational approximations, Hurwitz's theorem (|α - p/q| < 1/(√5 q²) for infinitely many p/q). Prove Liouville's theorem on transcendental numbers via Diophantine approximation bounds.",
       ["NumberTheory", "Analysis"], 0.84),
    sd("Quadratic Reciprocity: Five Proofs Formalized",
       "Formalize at least three distinct proofs of quadratic reciprocity in Lean 4: Gauss's original (via Gauss sums), Eisenstein's (via lattice point counting), and a modern proof via class field theory. Prove the supplementary laws for (-1/p) and (2/p).",
       ["NumberTheory", "Algebra"], 0.86),
    sd("Primality Testing: Miller-Rabin and AKS Formalization",
       "Formalize the Miller-Rabin primality test in Lean 4 and prove its error bounds. Formalize the AKS deterministic primality test and prove correctness: PRIMES ∈ P. Construct efficient modular arithmetic tactics for Lean.",
       ["NumberTheory", "Computation"], 0.88),
    sd("Euler-Mascheroni Constant: Irrationality Approaches",
       "Formalize the Euler-Mascheroni constant γ = lim(H_n - ln n). Prove key integral representations and series accelerations. Establish Apéry-like sequences that provide good rational approximations. Explore connections to the Stieltjes constants.",
       ["Analysis", "NumberTheory"], 0.80),
    sd("ABC Conjecture: Consequences and Partial Results",
       "Formalize the ABC conjecture statement and prove its major consequences: Fermat's Last Theorem for large exponents, Roth's theorem strengthening, the Szpiro conjecture for elliptic curves. Construct the radical rad(n) function framework in Lean 4.",
       ["NumberTheory", "Algebra"], 0.90),

    # ════════════════════════════════════════════
    # ALGEBRA — Concrete formalizations
    # ════════════════════════════════════════════
    sd("Galois Theory: Solvability of Polynomials",
       "Formalize the fundamental theorem of Galois theory in Lean 4. Prove the Abel-Ruffini theorem: the general quintic is not solvable by radicals. Construct explicit Galois groups for specific polynomials and prove solvability criteria via the derived series.",
       ["Algebra"], 0.91),
    sd("Representation Theory: Character Tables of S_n",
       "Formalize the representation theory of finite groups. Compute and verify character tables for S_3, S_4, S_5. Prove Burnside's theorem (groups of order p^a q^b are solvable). Formalize Maschke's theorem and Schur's lemma.",
       ["Algebra"], 0.85),
    sd("Homological Algebra: Derived Functors",
       "Formalize Ext and Tor functors in Lean 4. Prove the long exact sequence in cohomology. Construct projective and injective resolutions for concrete modules. Prove the universal coefficient theorem for homology.",
       ["Algebra", "Topology"], 0.86),
    sd("Jacobian Conjecture: Degree 2 and 3 Cases",
       "Prove the Jacobian conjecture for polynomial maps of degree 2 in all dimensions. Formalize the reduction to degree 3 (Drużkowski's theorem). Construct explicit counterexample candidates and verify they fail. Prove the conjecture implies the Dixmier conjecture.",
       ["Algebra", "Geometry"], 0.83),
    sd("Quaternion Algebras and Rotations",
       "Formalize quaternion algebras and their classification over number fields. Prove the isomorphism between unit quaternions and SO(3). Construct the Cayley-Dickson construction and prove properties of octonions. Apply to gimbal lock avoidance in 3D rotation.",
       ["Algebra", "Geometry", "Bridges"], 0.82),

    # ════════════════════════════════════════════
    # ANALYSIS — Concrete theorems
    # ════════════════════════════════════════════
    sd("Navier-Stokes: 2D Regularity and Partial 3D Results",
       "Formalize global existence and uniqueness for 2D Navier-Stokes (Ladyzhenskaya's theorem). Prove the Caffarelli-Kohn-Nirenberg partial regularity theorem in 3D: the singular set has 1-dimensional Hausdorff measure zero. Formalize energy inequalities.",
       ["Analysis", "Physics"], 0.93),
    sd("Invariant Subspace Problem: Special Cases",
       "Prove the invariant subspace theorem for compact operators on Hilbert spaces (Aronszajn-Smith). Formalize Lomonosov's theorem: operators commuting with a nonzero compact operator have invariant subspaces. Explore the Enflo-Read counterexample structure.",
       ["Analysis", "Algebra"], 0.84),
    sd("Spectral Theory: Self-Adjoint Operators",
       "Formalize the spectral theorem for bounded self-adjoint operators on Hilbert spaces. Prove the min-max theorem for eigenvalues. Construct the functional calculus and prove the spectral mapping theorem. Apply to quantum mechanical observables.",
       ["Analysis", "Physics", "Algebra"], 0.87),
    sd("Fixed Point Theorems: Brouwer, Banach, Schauder",
       "Formalize three fundamental fixed point theorems in Lean 4. Prove Brouwer via Sperner's lemma, Banach via the contraction mapping iteration, and Schauder via Brouwer + compactness. Apply to existence proofs for ODEs and integral equations.",
       ["Analysis", "Topology"], 0.85),
    sd("Fourier Analysis on Finite Groups",
       "Formalize the discrete Fourier transform as representation theory of cyclic groups. Prove Parseval's theorem and the convolution theorem. Extend to arbitrary finite abelian groups. Prove the uncertainty principle: supp(f) · supp(f̂) ≥ |G|.",
       ["Analysis", "Algebra"], 0.83),

    # ════════════════════════════════════════════
    # GEOMETRY & TOPOLOGY
    # ════════════════════════════════════════════
    sd("Kakeya Conjecture: Known Cases and Bounds",
       "Prove that Besicovitch sets in R^2 have Hausdorff dimension 2 (Davies's theorem). Formalize the Wolff bound in R^3: dimension ≥ 5/2. Connect to restriction estimates for the Fourier transform and to additive combinatorics via the Katz-Tao framework.",
       ["Geometry", "Analysis"], 0.84),
    sd("Knot Invariants: Jones Polynomial Formalization",
       "Formalize the Jones polynomial via the Kauffman bracket. Prove invariance under Reidemeister moves. Compute Jones polynomials for the trefoil, figure-eight, and torus knots. Prove that the Jones polynomial detects the unknot for alternating knots.",
       ["Topology", "Algebra"], 0.85),
    sd("Euler Characteristic and Gauss-Bonnet",
       "Formalize the Euler characteristic for CW complexes. Prove the Gauss-Bonnet theorem for compact surfaces: ∫ K dA = 2πχ(M). Prove the Poincaré-Hopf index theorem. Apply to classify surfaces by genus.",
       ["Geometry", "Topology"], 0.86),
    sd("Homotopy Groups of Spheres: Low-Dimensional",
       "Compute and formalize π_n(S^m) for small n, m. Prove π_3(S^2) ≅ ℤ via the Hopf fibration. Construct the Hopf invariant and prove it detects the generator. Formalize the long exact sequence of a fibration.",
       ["Topology", "Algebra"], 0.88),
    sd("Convex Geometry: Brunn-Minkowski Theory",
       "Formalize the Brunn-Minkowski inequality: vol(A+B)^{1/n} ≥ vol(A)^{1/n} + vol(B)^{1/n}. Prove the isoperimetric inequality as a consequence. Formalize support functions and the Minkowski sum. Prove the Alexandrov-Fenchel inequality.",
       ["Geometry", "Analysis"], 0.83),

    # ════════════════════════════════════════════
    # COMBINATORICS & PROBABILITY
    # ════════════════════════════════════════════
    sd("Ramsey Theory: Bounds and Constructions",
       "Formalize Ramsey's theorem and prove tight bounds: R(3,3)=6, R(3,4)=9, R(4,4)=18. Prove the Erdős-Szekeres bound R(s,t) ≤ C(s+t-2, s-1). Construct the best known lower bound via the probabilistic method. Formalize the Hales-Jewett theorem.",
       ["Combinatorics"], 0.85),
    sd("Frankl's Union-Closed Conjecture: Partial Results",
       "Formalize Frankl's conjecture and prove it for families of size ≤ 50 (Bošnjak-Marković). Prove the conjecture for families with a 3-element universe. Formalize the lattice-theoretic reformulation and Reimer's entropy approach.",
       ["Combinatorics", "Algebra"], 0.80),
    sd("Graph Coloring: Chromatic Polynomial Theory",
       "Formalize chromatic polynomials and prove deletion-contraction. Prove the four-color theorem is equivalent to χ(G) ≤ 4 for all planar G. Formalize Brooks' theorem: χ(G) ≤ Δ(G) unless G is complete or an odd cycle. Prove the chromatic polynomial is T-positive for claw-free graphs.",
       ["Combinatorics", "Algebra"], 0.83),
    sd("Random Graphs: Erdős-Rényi Threshold Phenomena",
       "Formalize the Erdős-Rényi random graph model G(n,p). Prove the sharp threshold for connectivity at p = ln(n)/n. Prove the phase transition for giant components at p = 1/n. Formalize the second moment method for subgraph counting.",
       ["Combinatorics", "Probability"], 0.82),
    sd("Extremal Graph Theory: Turán and Szemerédi",
       "Formalize Turán's theorem: ex(n, K_r) = (1-1/(r-1))n²/2. Prove the Kruskal-Katona theorem. Formalize Szemerédi's regularity lemma and prove the triangle removal lemma. Apply to prove Roth's theorem on 3-APs.",
       ["Combinatorics"], 0.86),

    # ════════════════════════════════════════════
    # COMPUTATION & LOGIC
    # ════════════════════════════════════════════
    sd("Circuit Complexity: Monotone Lower Bounds",
       "Formalize Boolean circuit complexity. Prove Razborov's lower bound: monotone circuits for CLIQUE require exponential size. Formalize the approximation method. Prove the Karchmer-Wigderson connection between circuit depth and communication complexity.",
       ["Computation", "Logic"], 0.87),
    sd("Proof Complexity: Resolution and Cutting Planes",
       "Formalize the resolution proof system. Prove exponential lower bounds for resolution proofs of the pigeonhole principle (Haken's theorem). Formalize cutting planes and prove the separation from resolution. Connect to SAT solver performance.",
       ["Computation", "Logic"], 0.85),
    sd("Constructive Mathematics: Bishop's Analysis",
       "Formalize key results of Bishop's constructive analysis in Lean 4. Prove the constructive intermediate value theorem (with explicit modulus). Construct computable real numbers and prove completeness. Compare with classical results.",
       ["Logic", "Analysis"], 0.82),
    sd("Type Theory: Cubical Type Theory Foundations",
       "Formalize cubical type theory primitives in Lean 4. Construct the interval type and path types. Prove function extensionality and the univalence axiom. Implement higher inductive types: circles, torus, suspension.",
       ["Logic", "Topology", "Algebra"], 0.86),
    sd("Lambda Calculus: Church-Rosser and Normalization",
       "Formalize the untyped lambda calculus. Prove the Church-Rosser theorem (confluence). Formalize the simply-typed lambda calculus and prove strong normalization. Construct the Böhm tree for undecidability of equivalence.",
       ["Logic", "Computation"], 0.84),

    # ════════════════════════════════════════════
    # PHYSICS (Mathematical)
    # ════════════════════════════════════════════
    sd("Quantum Mechanics: Spectral Theory of Hydrogen",
       "Formalize the hydrogen atom Hamiltonian in Lean 4. Prove the spectrum is {-1/n² : n ∈ ℕ+} ∪ [0,∞). Construct the spherical harmonics as eigenfunctions of the angular momentum operator. Prove the selection rules for transitions.",
       ["Physics", "Analysis"], 0.88),
    sd("Noether's Theorem: Symmetries and Conservation Laws",
       "Formalize Noether's theorem in Lean 4: every continuous symmetry of the action yields a conserved quantity. Prove energy conservation from time-translation, momentum from space-translation, angular momentum from rotational symmetry. Apply to Kepler problem.",
       ["Physics", "Algebra", "Analysis"], 0.90),
    sd("Statistical Mechanics: Ising Model Phase Transition",
       "Formalize the 2D Ising model. Prove Onsager's solution: the critical temperature is T_c = 2/ln(1+√2). Construct the transfer matrix method. Prove spontaneous magnetization below T_c via the Peierls argument.",
       ["Physics", "Probability", "Analysis"], 0.87),
    sd("Quantum Information: No-Cloning and Teleportation",
       "Formalize the no-cloning theorem in Lean 4 using the framework of C*-algebras. Prove the quantum teleportation protocol is correct. Formalize quantum entanglement measures and prove monogamy of entanglement for qubits.",
       ["Physics", "Algebra", "Computation"], 0.86),

    # ════════════════════════════════════════════
    # MACHINE LEARNING (Mathematical)
    # ════════════════════════════════════════════
    sd("Universal Approximation: Quantitative Bounds",
       "Formalize the universal approximation theorem for ReLU networks. Prove depth-width tradeoffs: width-bounded networks of depth d can approximate functions that require exponential width at depth d-1. Construct explicit approximation rates for Sobolev functions.",
       ["MachineLearning", "Analysis"], 0.86),
    sd("PAC-Bayes Generalization Bounds",
       "Formalize the PAC-Bayes framework in Lean 4. Prove the Catoni bound and McAllester bound. Apply to neural networks via Gaussian perturbation priors. Prove that PAC-Bayes bounds are asymptotically tight for linear classifiers.",
       ["MachineLearning", "Probability", "Computation"], 0.84),
    sd("Attention Mechanisms: Mathematical Properties",
       "Formalize the self-attention mechanism as a kernel method. Prove that softmax attention is a universal approximator of sequence-to-sequence functions. Analyze the rank of attention matrices and prove the attention sink phenomenon for large context.",
       ["MachineLearning", "Algebra", "Analysis"], 0.83),
    sd("Optimal Transport and Wasserstein Distances",
       "Formalize the Kantorovich optimal transport problem. Prove existence of optimal transport maps (Brenier's theorem for quadratic cost). Formalize Wasserstein distances and prove the Wasserstein GAN convergence properties.",
       ["MachineLearning", "Analysis", "Geometry"], 0.85),

    # ════════════════════════════════════════════
    # CRYPTOGRAPHY — Formal verification
    # ════════════════════════════════════════════
    sd("Lattice Cryptography: LWE Hardness",
       "Formalize the Learning With Errors (LWE) problem. Prove Regev's quantum reduction: LWE is as hard as worst-case lattice problems (GapSVP). Construct the Dual-Regev encryption scheme and prove CPA security. Formalize the ring-LWE variant.",
       ["Cryptography", "Algebra", "Computation"], 0.89),
    sd("Elliptic Curve Arithmetic: Group Law Formalization",
       "Formalize the group law on elliptic curves over finite fields in Lean 4. Prove associativity via the chord-tangent construction. Implement and verify point multiplication. Prove Hasse's bound: |#E(F_p) - p - 1| ≤ 2√p.",
       ["Cryptography", "Algebra", "NumberTheory"], 0.88),
    sd("Zero-Knowledge Proofs: Schnorr Protocol",
       "Formalize the Schnorr identification protocol in Lean 4. Prove completeness, soundness, and honest-verifier zero-knowledge. Formalize the Fiat-Shamir heuristic for non-interactive proofs. Prove security in the random oracle model.",
       ["Cryptography", "Logic", "Computation"], 0.85),

    # ════════════════════════════════════════════
    # TROPICAL GEOMETRY (genuine, non-forced)
    # ════════════════════════════════════════════
    sd("Tropical Curves and Chip-Firing Games",
       "Formalize tropical curves as metric graphs. Prove the tropical Riemann-Roch theorem via chip-firing: r(D) - r(K-D) = deg(D) - g + 1. Construct explicit divisor classes on complete graphs and prove Baker-Norine's theorem.",
       ["Tropical", "Algebra", "Combinatorics"], 0.86),
    sd("Tropical Convexity and Linear Programming",
       "Formalize tropical convex sets and tropical polytopes. Prove the tropical analogue of the Minkowski-Weyl theorem. Show that tropical linear programming is solvable in polynomial time. Connect to mean payoff games.",
       ["Tropical", "Computation", "Geometry"], 0.82),

    # ════════════════════════════════════════════
    # CROSS-DOMAIN BRIDGES
    # ════════════════════════════════════════════
    sd("Langlands Correspondence: GL(1) Case",
       "Formalize global class field theory as the GL(1) case of Langlands. Prove the Artin reciprocity law. Construct the adèle ring and idèle class group. Prove that 1-dimensional Galois representations correspond to Hecke characters.",
       ["Algebra", "NumberTheory", "Bridges"], 0.91),
    sd("Categorical Foundations: Yoneda and Adjunctions",
       "Formalize the Yoneda lemma in Lean 4 with concrete applications. Prove that representable functors determine objects up to isomorphism. Formalize adjunctions and prove the general adjoint functor theorem. Apply to free-forgetful adjunctions.",
       ["Algebra", "Logic", "Bridges"], 0.87),
    sd("Information Geometry: Fisher Metric on Statistical Models",
       "Formalize the Fisher information metric on parametric statistical models. Prove the Cramér-Rao bound as a geometric statement. Construct the alpha-connections and prove the dually flat structure. Apply to exponential families.",
       ["Geometry", "Probability", "Bridges"], 0.84),
    sd("Algebraic Coding Theory: BCH and Reed-Solomon",
       "Formalize BCH and Reed-Solomon codes over finite fields. Prove the BCH bound on minimum distance. Construct the Berlekamp-Massey decoding algorithm and prove correctness. Apply to concrete error-correction scenarios.",
       ["Algebra", "Computation", "Cryptography"], 0.85),

    # ════════════════════════════════════════════
    # META-RESEARCH (Aether self-improvement)
    # ════════════════════════════════════════════
    sd("Proof Automation: Custom Lean 4 Tactics",
       "Develop custom Lean 4 tactics for common proof patterns in the Catalog: a tropical_simp tactic for min-plus simplification, a number_theory_decide for small cases, and a spectral_bound for eigenvalue estimates. Prove each tactic is sound.",
       ["Logic", "Computation", "Bridges"], 0.92),
    sd("Formal Verification of Algorithms",
       "Formalize classic algorithms with full correctness proofs in Lean 4: binary search (with loop invariants), Dijkstra's shortest path (with graph formalization), and FFT (with number-theoretic transform). Prove complexity bounds.",
       ["Computation", "Logic"], 0.88),
]

def main():
    workspace = Path(__file__).parent / ".aether_workspace"
    workspace.mkdir(exist_ok=True)
    out_path = workspace / "future_directions.json"

    # Back up existing
    if out_path.exists():
        backup = workspace / "future_directions_backup.json"
        import shutil
        shutil.copy2(out_path, backup)
        print(f"Backed up existing to {backup}")

    data = {"directions": SEEDS, "pruned": []}
    out_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {len(SEEDS)} seeds to {out_path}")

    # Domain distribution
    from collections import Counter
    domain_counts = Counter()
    for s in SEEDS:
        for d in s["domains"]:
            domain_counts[d] += 1
    print("\nDomain distribution:")
    for domain, count in domain_counts.most_common():
        print(f"  {domain:20s} {'█' * count} {count}")

if __name__ == "__main__":
    main()
