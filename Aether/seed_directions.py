"""Seed directions for the Aether Future Directions system.

Each direction is a specific mathematical claim or conjecture designed to
drive productive research cycles. Categories cover sci-fi/speculative,
computation, AI/ML, millennial problems, factoring, compression, and fun topics.
"""

from research_memory import FutureDirection


def get_seed_directions() -> list[FutureDirection]:
    directions = [
        # ── Millennial Problems (3) ──
        FutureDirection(
            id="seed_001",
            title="P vs NP: Tropical Semiring Barrier",
            description="Prove that tropical semiring morphisms cannot polynomially simulate Boolean circuit satisfiability, establishing a structural barrier via min-plus idempotent completions that separates P from NP. Construct a family of Boolean formulas whose tropical evaluation requires super-polynomial min-plus circuit size, and prove that the idempotent closure of the tropical semiring yields a natural complexity class incomparable with P.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Algebra", "Computation", "Tropical"],
            priority_score=0.95,
        ),
        FutureDirection(
            id="seed_002",
            title="Riemann Hypothesis via Tropical Spectral Transfer",
            description="Formulate the Riemann Hypothesis as a statement about the spectrum of a tropical transfer operator on the critical strip. Prove that all non-trivial zeros lie on Re(s)=1/2 if and only if the tropical eigenvalue gap vanishes, connecting analytic number theory to tropical dynamics via a constructive spectral correspondence.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Algebra", "Physics", "Speculative"],
            priority_score=0.94,
        ),
        FutureDirection(
            id="seed_003",
            title="Collatz Convergence via Tropical Contracting Dynamics",
            description="Prove that the Collatz iteration corresponds to a contracting tropical dynamical system on a min-plus lattice, and that convergence follows from tropical spectral radius bounds. Show that the 3n+1 map is a piecewise-tropical contraction with unique fixed point at 1, establishing global convergence through idempotent metric arguments.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Computation", "Tropical", "Speculative"],
            priority_score=0.78,
        ),

        # ── Factoring (2) ──
        FutureDirection(
            id="seed_004",
            title="Pythagorean Lattice Reduction for Integer Factoring",
            description="Prove that factoring n reduces to finding short vectors in the Berggren Pythagorean triple lattice L_n, and construct a polynomial-time quantum algorithm via LLL reduction on L_n. Formalize the Berggren primitive triple generation as a groupoid action on SL(3,Z), then show that the shortest vector in L_n encodes a non-trivial factor of n.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Cryptography", "Pythagorean", "Algebra"],
            priority_score=0.90,
        ),
        FutureDirection(
            id="seed_005",
            title="Tropical Quadratic Sieve: Min-Plus Factoring Algorithm",
            description="Prove that tropical min-plus matrix multiplication yields a subexponential factoring algorithm by encoding the quadratic sieve as a tropical convolution. Show that the tropical sieve step computes smoothness via idempotent arithmetic, and establish complexity bounds matching classical QS with tropical arithmetic replacing ring arithmetic.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Cryptography", "Tropical", "Computation"],
            priority_score=0.83,
        ),

        # ── Compression (2) ──
        FutureDirection(
            id="seed_006",
            title="Kolmogorov Complexity Closure and Idempotent Compression Duality",
            description="Prove that the idempotent closure of a semiring yields optimal lossless compression ratios, and establish a duality between Kolmogorov complexity and closure operators that gives computable upper bounds on minimal description length. Show that the tropical semiring's idempotent property induces a canonical compression scheme whose fixed points are exactly the Kolmogorov-random strings.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Computation", "EML", "Tropical"],
            priority_score=0.88,
        ),
        FutureDirection(
            id="seed_007",
            title="Tropical Arithmetic Coding: Shannon-Optimal Min-Plus Compression",
            description="Prove that tropical arithmetic coding achieves Shannon entropy for min-plus sources, and construct provably optimal tropical Huffman codes with explicit efficiency bounds. Show that the min-plus convolution of source distributions yields the optimal code length function, establishing a constructive duality between tropical information theory and universal source coding.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Computation", "Tropical", "Cryptography"],
            priority_score=0.81,
        ),

        # ── AI/ML (3) ──
        FutureDirection(
            id="seed_008",
            title="Sheaf Cohomology and Certified Adversarial Robustness",
            description="Formalize the relationship between sheaf cohomology groups on neural network weight spaces and adversarial robustness bounds. Prove that vanishing first cohomology implies certified L-infinity perturbation radius, and construct explicit sheaf structures on ReLU network decision boundaries whose stalk cohomology detects vulnerability to adversarial examples.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["MachineLearning", "EML", "Bridges"],
            priority_score=0.92,
        ),
        FutureDirection(
            id="seed_009",
            title="Closure-Operator Networks: Universal Approximation via Idempotent Semimodules",
            description="Prove that any continuous function on a compact domain can be approximated arbitrarily well by a finite composition of closure operators on idempotent semimodules, establishing a new universal approximation theorem. Show that closure-operator networks achieve the same approximation order as ReLU networks while being provably robust to adversarial perturbations within the semimodule's closure radius.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["MachineLearning", "EML", "Algebra"],
            priority_score=0.87,
        ),
        FutureDirection(
            id="seed_010",
            title="Tropical Neural Code Classification with Provable Margins",
            description="Prove that tropical convex hulls of neural firing patterns classify stimulus identities with provable margin bounds, establishing tropical geometry as a formal framework for neural coding theory. Show that the tropical convex hull of a neural code's receptive fields determines its combinatorial classification capacity.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["MachineLearning", "Tropical", "Bridges"],
            priority_score=0.84,
        ),

        # ── Computation (4) ──
        FutureDirection(
            id="seed_011",
            title="Tropical Myhill-Nerode Theorem for Min-Plus Automata",
            description="Prove a tropical analogue of the Myhill-Nerode theorem: a min-plus weighted language is recognizable by a tropical finite automaton if and only if its Nerode congruence has finite index in the tropical semiring. Establish minimality of the tropical Nerode automaton and prove that tropical regular languages are exactly those with finite idempotent syntactic monoids.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Computation", "Tropical", "Logic"],
            priority_score=0.85,
        ),
        FutureDirection(
            id="seed_012",
            title="Reversible Computing via Tropical Isomorphisms",
            description="Construct a reversible Turing machine model where each transition corresponds to a tropical semiring isomorphism, and prove that reversible tropical computation simulates classical computation with at most polynomial overhead. Show that the Landauer erasure cost in tropical entropy is exactly kT ln(2) per bit, formalizing thermodynamic computation bounds via min-plus algebra.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Computation", "Tropical", "Physics"],
            priority_score=0.82,
        ),
        FutureDirection(
            id="seed_013",
            title="Temporal Stone Duality: Recovering Temporal Logic from Idempotent Semiring Fixpoints",
            description="Prove that the Stone dual of an idempotent semiring's fixpoint lattice recovers precisely the temporal logic specifying that semiring's behavioral equivalence, establishing a categorical duality between algebraic semantics and temporal specification. Show that LTL model checking reduces to computing the greatest fixpoint in the corresponding idempotent semiring, and prove decidability for the finite semiring case.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Logic", "Computation", "Bridges"],
            priority_score=0.86,
        ),
        FutureDirection(
            id="seed_014",
            title="Circuit Lower Bounds from Tropical Spectral Theory",
            description="Prove that tropical eigenvalue gaps of circuit matrices yield super-polynomial circuit lower bounds for specific language families, advancing structural complexity theory. Show that the min-plus permanent of a circuit matrix bounds its computational depth, and that tropical spectral analysis provides a constructive path to separating complexity classes via idempotent linear algebra.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Computation", "Algebra", "Tropical"],
            priority_score=0.80,
        ),

        # ── Sci-fi / Speculative (4) ──
        FutureDirection(
            id="seed_015",
            title="Holographic Proof Renormalization: Ultrametric Compression of Formal Derivations",
            description="Develop an ultrametric theory of proof compression where the p-adic valuation of a derivation measures its local complexity, and prove that renormalization group flow on proof spaces converges to fixed points representing minimal proofs. Show that the tropical ultrametric distance between two proofs bounds their semantic distance, and that holographic renormalization yields a decidable approximation to theoremhood.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Speculative", "Logic", "Physics"],
            priority_score=0.93,
        ),
        FutureDirection(
            id="seed_016",
            title="Thermodynamic Computation via Tropical Landauer's Principle",
            description="Formalize Landauer's principle in Lean: prove that any erasure operation on a semiring element costs at least kT ln 2 in tropical entropy, establishing tropical thermodynamics as a computational bound. Show that the min-plus free energy of a computation equals its tropical circuit depth, connecting physical and computational complexity through idempotent analysis.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Physics", "Computation", "Tropical"],
            priority_score=0.91,
        ),
        FutureDirection(
            id="seed_017",
            title="Self-Referential Proof Systems and Tropical Godel Sentences",
            description="Prove that idempotent semiring fixpoints encode self-referential statements, and construct a Lean 4 formalization of a tropical Godel sentence. Show that the tropical fixed-point combinator yields an undecidable proposition in min-plus arithmetic, establishing incompleteness for tropical proof systems and connecting diagonalization to idempotent closure operators.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Logic", "Computation", "Algebra"],
            priority_score=0.89,
        ),
        FutureDirection(
            id="seed_018",
            title="Emergent Computation in Pythagorean Orbit Lattices",
            description="Prove that the Berggren groupoid orbit lattice on SL(3,Z) supports universal computation via a constructed cellular automaton, establishing Pythagorean triples as a computational substrate. Show that the orbit structure of primitive triples encodes Turing-complete transition rules, and that the lattice's geometric properties guarantee computational universality with polynomial overhead.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Pythagorean", "Computation", "Speculative"],
            priority_score=0.90,
        ),

        # ── Fun / Epic / Wonder-Filled (4) ──
        FutureDirection(
            id="seed_019",
            title="Pythagorean Music Theory: Harmonic Ratios from Triple Lattices",
            description="Prove that Berggren-generated Pythagorean triples map to harmonic frequency ratios via tropical logarithm, and formalize the musical intervals of primitive triples as consonance/dissonance classifications. Show that the (3,4,5) triple corresponds to a perfect fourth, and that the orbit structure of the Berggren tree encodes the circle of fifths in min-plus arithmetic.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Pythagorean", "Bridges", "Physics"],
            priority_score=0.79,
        ),
        FutureDirection(
            id="seed_020",
            title="Alien Algebra: Non-Archimedean Life Forms in Idempotent Semirings",
            description="Prove that idempotent semiring algebras support self-replicating computational structures formalized as fixed-point attractors, establishing a mathematical framework for non-Archimedean 'life' that satisfies key axioms of artificial chemistry. Show that tropical cell automata on min-plus lattices exhibit universal self-replication with provable mutation bounds, opening a formal theory of alien computation.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Speculative", "EML", "Algebra"],
            priority_score=0.77,
        ),
        FutureDirection(
            id="seed_021",
            title="Tropical Rainfall: Nash Equilibria as Min-Plus Fixed Points",
            description="Prove that tropical semiring fixed points correspond to Nash equilibria in zero-sum games on idempotent payoff matrices, and show that the tropical value iteration converges in at most n steps for n-player games. Construct a tropical min-max theorem analogous to von Neumann's, proving that every finite tropical game has a unique idempotent equilibrium.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Tropical", "Bridges", "Computation"],
            priority_score=0.76,
        ),
        FutureDirection(
            id="seed_022",
            title="Quantum Pythagorean Teleportation: Berggren Orbits as Clifford Circuits",
            description="Prove that Berggren groupoid orbits on SL(3,Z) encode quantum teleportation circuits via a categorical equivalence between Pythagorean lattices and stabilizer subgroups of the Clifford group. Show that primitive triple matrices form universal quantum gates under tropical composition, and that the Berggren tree structure yields an optimal teleportation protocol.",
            source_exp_id="seed",
            source_path="seed:manual_v2",
            domains=["Pythagorean", "Physics", "Cryptography"],
            priority_score=0.92,
        ),
    ]
    return directions