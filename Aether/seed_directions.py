"""Seed directions for the Aether Future Directions system.

v4: Diversified — culled tropical echo chamber, added grand challenges
from MathWorld, Hilbert, Landau, Clay, and other frontier problem lists.
Aristotle decides where research goes.
"""

from research_memory import FutureDirection

_ID = 0

def _sd(title, desc, domains, priority=0.85):
    global _ID
    _ID += 1
    return FutureDirection(
        id=f"seed_{_ID:03d}", title=title, description=desc,
        source_exp_id="seed", source_path="seed:manual_v4",
        domains=domains, priority_score=priority,
    )


def get_seed_directions() -> list[FutureDirection]:
    global _ID
    _ID = 0
    return [
        # ══════════════════════════════════════════════════════════
        # MathWorld Unsolved Problems
        # ══════════════════════════════════════════════════════════
        _sd("Goldbach Conjecture", "Prove that every even integer greater than 2 is the sum of two primes. Formalize partial results such as Vinogradov's theorem for sufficiently large odd integers, or Chen's theorem that every sufficiently large even number is the sum of a prime and a semiprime. Explore connections to sieve methods and the circle method.", ["NumberTheory", "Algebra"], 0.95),
        _sd("Riemann Hypothesis", "Prove that all non-trivial zeros of the Riemann zeta function lie on Re(s)=1/2. Formalize equivalent statements: the prime counting function error bound, the Mertens conjecture connection, or the spectral interpretation via random matrix theory. Explore connections to quantum chaos and the Hilbert-Polya conjecture.", ["NumberTheory", "Analysis"], 0.95),
        _sd("Hadamard Matrix Conjecture", "Prove that a Hadamard matrix exists for every positive multiple of 4. Formalize known constructions (Sylvester, Paley, tensor products) and establish bounds on the smallest open order. Connect to combinatorial designs, error-correcting codes, and signal processing.", ["Algebra", "Combinatorics"], 0.88),
        _sd("Twin Prime Conjecture", "Prove that there are infinitely many pairs of primes differing by 2. Formalize Zhang's bounded gaps result and Maynard-Tao improvements. Explore connections to the Hardy-Littlewood conjecture and sieve theory.", ["NumberTheory"], 0.93),
        _sd("P vs NP Problem", "Prove or disprove that P = NP. Formalize known barriers: relativization, natural proofs, algebrization. Explore circuit complexity lower bounds, proof complexity, and connections to cryptographic hardness assumptions.", ["Computation", "Logic"], 0.96),
        _sd("Collatz Conjecture", "Prove that the 3n+1 iteration eventually reaches 1 for all positive integers. Formalize partial results on density of convergent integers, stopping times, and connections to ergodic theory and p-adic dynamics.", ["NumberTheory", "Computation"], 0.85),
        _sd("196-Algorithm Non-Termination", "Prove that the reverse-and-add algorithm applied to 196 never produces a palindrome. Formalize the concept of Lychrel numbers and establish structural properties of the iteration on digit sequences.", ["NumberTheory"], 0.72),
        _sd("10 is a Solitary Number", "Prove that 10 is a solitary number — no other integer shares its abundancy index σ(n)/n. Formalize the theory of friendly numbers and abundancy, connecting to the distribution of divisor sums.", ["NumberTheory"], 0.70),
        _sd("Symmetric Group Generation Probability", "Find a formula for the probability that two elements chosen uniformly at random generate the symmetric group S_n. Formalize known asymptotic results and connect to the theory of random permutations.", ["Algebra", "Combinatorics", "Probability"], 0.78),
        _sd("Happy End Problem", "Solve the happy end problem for arbitrary n: determine the minimum number of points in general position in the plane that guarantee a convex n-gon. Formalize the Erdős–Szekeres theorem and improve known bounds.", ["Geometry", "Combinatorics"], 0.82),
        _sd("Perfect Cuboid (Euler Brick)", "Find an Euler brick whose space diagonal is also an integer, or prove none exists. Formalize the parametric families of near-misses and connect to Diophantine equations on algebraic surfaces.", ["NumberTheory", "Geometry"], 0.80),
        _sd("Sums of Three Cubes", "Determine which integers can be represented as a sum of three cubes. Formalize known computational results and the density conjecture. Connect to the geometry of cubic surfaces and the Hasse principle.", ["NumberTheory", "Algebra"], 0.83),
        _sd("Odd Perfect Numbers", "Prove that no odd perfect numbers exist. Formalize known constraints: must exceed 10^1500, have at least 101 prime factors, satisfy Euler's form p^a * m^2. Connect to the structure of multiplicative functions.", ["NumberTheory"], 0.88),

        # ══════════════════════════════════════════════════════════
        # Clay Millennium Problems
        # ══════════════════════════════════════════════════════════
        _sd("Hodge Conjecture", "Prove that every Hodge class on a non-singular projective algebraic variety is a rational linear combination of classes of algebraic cycles. Formalize the Hodge decomposition and explore the conjecture for specific varieties like abelian varieties and K3 surfaces.", ["Geometry", "Algebra"], 0.94),
        _sd("Yang-Mills Mass Gap", "Prove that for any compact simple gauge group, quantum Yang-Mills theory on R^4 exists and has a mass gap. Formalize the mathematical framework of gauge theory and connect to lattice gauge theory computations.", ["Physics", "Analysis"], 0.93),
        _sd("Navier-Stokes Existence and Smoothness", "Prove existence and smoothness of solutions to the 3D Navier-Stokes equations, or find a counterexample. Formalize known partial regularity results (Caffarelli-Kohn-Nirenberg) and explore connections to turbulence.", ["Analysis", "Physics"], 0.94),
        _sd("Birch and Swinnerton-Dyer Conjecture", "Prove that the rank of an elliptic curve equals the order of vanishing of its L-function at s=1. Formalize the BSD formula including the regulator, Tate-Shafarevich group, and Tamagawa numbers.", ["NumberTheory", "Algebra"], 0.94),

        # ══════════════════════════════════════════════════════════
        # Hilbert's Remaining Open Problems
        # ══════════════════════════════════════════════════════════
        _sd("Hilbert 6: Axiomatization of Physics", "Develop a rigorous axiomatic foundation for physics, particularly for probability and mechanics. Formalize Kolmogorov's axioms, explore constructive quantum mechanics, and connect to topos-theoretic physics.", ["Physics", "Logic"], 0.82),
        _sd("Hilbert 11: Quadratic Forms over Algebraic Fields", "Extend results on quadratic forms to arbitrary algebraic number fields. Formalize the Hasse-Minkowski theorem and explore the classification of quadratic forms over number fields via class field theory.", ["Algebra", "NumberTheory"], 0.80),
        _sd("Hilbert 12: Kronecker-Weber Generalization", "Extend the Kronecker-Weber theorem to arbitrary algebraic fields by constructing Hilbert class fields. Formalize explicit class field theory and connect to the Langlands program.", ["Algebra", "NumberTheory"], 0.85),
        _sd("Hilbert 13: 7th-Degree Equations via 2-Variable Functions", "Resolve whether the general 7th-degree equation can be solved using functions of only 2 variables. Formalize Kolmogorov's superposition theorem and explore its implications for approximation theory.", ["Algebra", "Analysis"], 0.78),
        _sd("Hilbert 15: Schubert Calculus Rigorization", "Provide rigorous foundations for Schubert's enumerative geometry. Formalize intersection theory on Grassmannians and flag varieties, proving Schubert calculus results via modern algebraic geometry.", ["Geometry", "Algebra"], 0.80),
        _sd("Hilbert 16: Topology of Algebraic Curves", "Study the topology of real algebraic curves and surfaces. Formalize the Harnack bound, classify real algebraic curves by arrangement of ovals, and connect to the second part on limit cycles of planar polynomial ODEs.", ["Geometry", "Topology"], 0.83),

        # ══════════════════════════════════════════════════════════
        # Landau's Problems
        # ══════════════════════════════════════════════════════════
        _sd("Legendre's Conjecture", "Prove that for every positive integer n, there exists a prime between n² and (n+1)². Formalize known partial results on prime gaps and connect to the Cramér model of primes.", ["NumberTheory"], 0.87),
        _sd("Primes of the Form n²+1", "Prove that there are infinitely many primes of the form n²+1. Formalize Iwaniec's result on semi-primes of this form and connect to Friedlander-Iwaniec theorem on primes of form a²+b⁴.", ["NumberTheory"], 0.86),

        # ══════════════════════════════════════════════════════════
        # Additional Grand Challenges
        # ══════════════════════════════════════════════════════════
        _sd("Lehmer's Mahler Measure Problem", "Determine whether Lehmer's polynomial has the smallest Mahler measure among non-cyclotomic polynomials. Formalize the Mahler measure and its connections to heights, entropy, and algebraic dynamics.", ["NumberTheory", "Algebra"], 0.79),
        _sd("Euler-Mascheroni Constant Irrationality", "Prove that the Euler-Mascheroni constant γ ≈ 0.5772 is irrational (or transcendental). Formalize continued fraction expansions and connect to the theory of special values of L-functions.", ["Analysis", "NumberTheory"], 0.82),
        _sd("Percolation Threshold", "Derive an analytic form for the square site percolation threshold. Formalize bond vs site percolation, prove known exact thresholds for triangular lattices, and connect to conformal invariance.", ["Probability", "Physics"], 0.76),
        _sd("ABC Conjecture Formalization", "Formalize the ABC conjecture and its implications in Lean 4. Prove consequences: Fermat's Last Theorem for large exponents, Roth's theorem strengthening, Mordell conjecture. Explore Mochizuki's claimed proof structure.", ["NumberTheory", "Algebra"], 0.90),
        _sd("Invariant Subspace Problem", "Prove or disprove that every bounded linear operator on a separable Hilbert space has a non-trivial closed invariant subspace. Formalize known results for compact operators and normal operators.", ["Analysis", "Algebra"], 0.84),
        _sd("Frankl's Union-Closed Conjecture", "Prove that for every finite union-closed family of sets (not all empty), some element belongs to at least half the sets. Formalize the lattice-theoretic reformulation and known partial results.", ["Combinatorics", "Algebra"], 0.80),
        _sd("Erdős–Straus Conjecture", "Prove that for every integer n ≥ 2, the fraction 4/n can be written as a sum of three unit fractions. Formalize computational verification and parametric families of solutions.", ["NumberTheory"], 0.77),
        _sd("Schanuel's Conjecture", "Prove Schanuel's conjecture: if z₁,...,zₙ are Q-linearly independent complex numbers, then the transcendence degree of {z₁,...,zₙ,e^z₁,...,e^zₙ} over Q is at least n. Formalize implications for the Lindemann-Weierstrass theorem.", ["NumberTheory", "Analysis"], 0.85),
        _sd("Jacobian Conjecture", "Prove that if a polynomial map F: Cⁿ → Cⁿ has constant non-zero Jacobian determinant, then F is invertible. Formalize the reduction to degree 3 and connect to the Dixmier conjecture.", ["Algebra", "Geometry"], 0.83),
        _sd("Kakeya Conjecture", "Prove the Kakeya conjecture: a Besicovitch set in Rⁿ has Hausdorff dimension n. Formalize the connection to restriction estimates and additive combinatorics.", ["Geometry", "Analysis"], 0.84),
        _sd("Beal's Conjecture", "Prove that if A^x + B^y = C^z where A,B,C,x,y,z are positive integers with x,y,z > 2, then A,B,C share a common prime factor. Formalize the connection to Fermat-Catalan and ABC conjecture.", ["NumberTheory"], 0.82),
        _sd("Cramér's Conjecture on Prime Gaps", "Prove that the gap between consecutive primes p_n satisfies p_{n+1} - p_n = O((log p_n)²). Formalize probabilistic models of primes and known unconditional bounds.", ["NumberTheory"], 0.83),

        # ══════════════════════════════════════════════════════════
        # Cross-Domain Frontiers (non-tropical)
        # ══════════════════════════════════════════════════════════
        _sd("Langlands Program: Functoriality", "Prove specific cases of Langlands functoriality: the transfer from GL(2) to GL(3), or symmetric power liftings. Formalize automorphic representations and L-functions in Lean 4.", ["Algebra", "NumberTheory", "Bridges"], 0.92),
        _sd("Quantum Error Correction Bounds", "Prove tight bounds on quantum error-correcting codes. Formalize the quantum Singleton bound, quantum Hamming bound, and construct optimal stabilizer codes. Connect to topological quantum computing.", ["Physics", "Computation", "Algebra"], 0.87),
        _sd("Homotopy Type Theory Foundations", "Formalize core HoTT results in Lean 4: the univalence axiom, higher inductive types, and the fundamental theorem of identity types. Prove that HoTT provides a constructive foundation for mathematics.", ["Logic", "Topology", "Algebra"], 0.86),
        _sd("Machine Learning Generalization Bounds", "Prove tighter generalization bounds for deep neural networks. Formalize PAC-Bayes bounds, compression-based bounds, and connect network architecture to sample complexity. Establish when overparameterized networks provably generalize.", ["MachineLearning", "Computation", "Algebra"], 0.85),
        _sd("Category-Theoretic Neural Architectures", "Formalize neural network architectures as morphisms in a monoidal category. Prove that ResNet skip connections are categorical products, attention is a natural transformation, and architecture search is optimization in a functor category.", ["MachineLearning", "Algebra", "Bridges"], 0.84),
        _sd("Certified Adversarial Robustness via Sheaf Cohomology", "Prove that vanishing first sheaf cohomology on neural network weight spaces implies certified L-infinity perturbation radius. Construct explicit sheaf structures on decision boundaries whose stalk cohomology detects adversarial vulnerability.", ["MachineLearning", "Algebra", "Bridges"], 0.88),
        _sd("Spectral Graph Theory Meets Network Robustness", "Prove that the algebraic connectivity of a neural network's computation graph bounds its certified robustness radius. Formalize the connection between graph spectra and function Lipschitz constants.", ["MachineLearning", "Algebra", "Geometry"], 0.83),
        _sd("Reversible Computing and Thermodynamic Efficiency", "Prove that reversible circuits achieve Landauer's bound for erasure. Formalize the connection between computational complexity and thermodynamic entropy. Construct provably optimal reversible implementations of common algorithms.", ["Computation", "Physics"], 0.82),
        _sd("EML Universal Approximation", "Prove that Exponential-Multiplicative-Logarithmic closures are universal approximators with provable complexity bounds. Show that minimum EML depth for ε-approximation is O(K(f)/ε), connecting to Kolmogorov complexity.", ["EML", "MachineLearning", "Algebra"], 0.85),
        _sd("Pythagorean Triple Group Structure", "Prove deep structural theorems about the Berggren tree of Pythagorean triples. Formalize the groupoid action on SL(3,Z), the prime distribution along hypotenuse lengths, and computational applications of the tree structure.", ["Pythagorean", "Algebra", "NumberTheory"], 0.82),

        # ══════════════════════════════════════════════════════════
        # Tropical Geometry (kept — genuine tropical seeds)
        # ══════════════════════════════════════════════════════════
        _sd("Tropical Riemann-Roch Theorem", "Prove the tropical Riemann-Roch theorem: for a tropical curve of genus g and a divisor D of degree d, the tropical rank r(D) satisfies r(D) - r(K-D) = d - g + 1. Formalize chip-firing and Baker-Norine theory.", ["Tropical", "Algebra", "Geometry"], 0.86),
        _sd("Tropical Brill-Noether Theory", "Prove that a general tropical curve of genus g has a divisor of degree d and rank r iff the Brill-Noether number ρ = g - (r+1)(g-d+r) ≥ 0. Formalize the connection to classical algebraic geometry.", ["Tropical", "Geometry", "Algebra"], 0.84),
        _sd("Tropical Satake Isomorphism for GL_n", "Extend the tropical Satake isomorphism from GL_2 to GL_n. Prove that it defines a bijection between min-plus Hecke operators and W-invariant tropical polynomials, connecting representation theory to combinatorics.", ["Tropical", "Algebra", "Bridges"], 0.87),
        _sd("Tropical Intersection Theory", "Prove that the tropicalization functor preserves intersection numbers. Formalize tropical varieties as polyhedral complexes and establish the tropical Bézout theorem with explicit bounds.", ["Tropical", "Geometry"], 0.82),
        _sd("Tropical Convexity and Helly Theorem", "Prove a tropical analogue of Helly's theorem: characterize when tropical convex sets have non-empty intersection. Formalize tropical convex hulls and their connection to optimization.", ["Tropical", "Geometry", "Computation"], 0.78),

        # ══════════════════════════════════════════════════════════
        # Meta-Research (kept — Aether self-improvement)
        # ══════════════════════════════════════════════════════════
        _sd("Certified Novelty Detection for Theorem Provers", "Design and prove correct a novelty certification system that formally verifies each research output contains genuinely new mathematics. Construct a theorem embedding space where distance bounds novelty.", ["Logic", "Computation", "Bridges"], 0.92),
        _sd("Proof Strategy Mining from Deep Mathematics", "Reverse-engineer proof strategies from deep results (FLT, Poincaré, classification of finite simple groups) and extract reusable structural patterns as higher-order proof schemata.", ["Logic", "Algebra", "Bridges"], 0.90),
        _sd("Research Depth via Proof-Theoretic Ordinal Analysis", "Prove that proof-theoretic ordinal analysis provides a rigorous depth metric for mathematical research. Construct a formalization that computes the proof-theoretic ordinal of research output.", ["Logic", "Computation"], 0.88),
        _sd("Self-Modifying Research via Reflective Type Theory", "Formalize a research system as a dependent type where the type of the next cycle depends on outcomes of previous cycles. Prove that reflective self-improvement converges.", ["Logic", "Algebra"], 0.91),

        # ══════════════════════════════════════════════════════════
        # Speculative / Fun (kept — non-tropical versions)
        # ══════════════════════════════════════════════════════════
        _sd("Consciousness as Integrated Information", "Formalize integrated information theory (IIT) in Lean 4. Define Phi as a measure on causal structures, prove its key properties (composition, exclusion), and explore connections to category theory and complexity.", ["Speculative", "Logic", "Computation"], 0.80),
        _sd("Alien Mathematics: Non-Standard Arithmetic", "Explore what theorems hold in non-standard models of arithmetic. Formalize ultrapower constructions, transfer principles, and prove which classical theorems survive in non-Archimedean settings.", ["Speculative", "Logic", "Algebra"], 0.76),
        _sd("Game of Life Universality", "Prove Conway's Game of Life is Turing complete via a direct constructive embedding. Formalize cellular automata in Lean 4 and establish complexity bounds on the simulation overhead.", ["Computation", "Speculative"], 0.77),
        _sd("Musical Counterpoint as Constraint Satisfaction", "Formalize the rules of species counterpoint as a constraint satisfaction problem. Prove that optimal voice leading minimizes a well-defined cost function and connect to lattice theory.", ["Bridges", "Algebra"], 0.72),
    ]