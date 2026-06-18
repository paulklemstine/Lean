# Future Research Directions: Hamming Fiber Algebra

## Synthesis

This research cycle established the formal theory of fiber graphs in Hamming spaces, proving seven core theorems about the structure of level sets of additive scoring functions. The Bridge Duality Theorem emerged as the central result: for two equal-score configurations differing at exactly two positions, the ability to construct a score-preserving bridge through one position is logically equivalent to the ability through the other. This symmetric obstruction reveals that fiber disconnection in additive scoring is not a local phenomenon at one position, but a global constraint linking all differing positions.

The most promising cross-domain connections are: (a) the link between fiber expansion and spectral graph theory, where the conjectured expansion bound would establish mixing time guarantees for Markov chains on fibers — connecting to `Computation/InfoEfficientAlgorithms.lean` where efficient exploration of structured spaces is studied; (b) the Plotkin bound's double-counting technique, which generalizes naturally to tropical scoring functions in `Algebra/TropicalDragon.lean` via the min-plus semiring; and (c) the connection between fiber connectivity and neutral network theory in evolutionary biology, where the Hamming graph models the space of genotypes and additive fitness functions model non-epistatic fitness landscapes.

The highest breakthrough potential lies in Direction 1 (Spectral Fiber Theory), because proving the fiber expansion conjecture would immediately yield polynomial-time algorithms for sampling from fibers of generic additive maps — a problem with direct applications in coding theory, statistical physics, and combinatorial optimization. The bridge duality theorem provides the key structural insight needed: understanding exactly when and why fibers disconnect is the first step toward proving they usually don't.

---

### Direction 1: Spectral Theory of Fiber Graphs

**Conjecture**: For an additive flavor map f: H(n,m) → ℤ with all slot functions injective and m ≥ 3, the second eigenvalue λ₂ of the normalized Laplacian of each non-trivial fiber subgraph satisfies λ₂ ≥ c/n for some universal constant c > 0.

**Test**: Compute the spectrum of fiber graphs for all injective additive maps on H(4,3) and H(3,4). Check whether λ₂ · n is bounded below by a positive constant across all non-singleton fibers. A single fiber with λ₂ = 0 (disconnected) would refute the conjecture.

**Impact**: If true, this would establish that fibers of generic additive maps are expanders, implying O(n log|F|) mixing time for random walks on fibers. This would yield practical algorithms for uniform sampling from equal-score configurations. If false, the counterexample would identify a new class of "fiber bottleneck" structures with independent combinatorial interest.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean`, `Cryptography/HammingFiberAlgebra.lean`

**Proof Strategy**: The bridge duality theorem shows that fiber disconnection requires slot-flavor collisions (φᵢ(a) = φᵢ(b) for a ≠ b). For injective maps, no such collisions exist. The strategy is: (1) prove that injective additive maps have connected fibers (using induction on n with the bridge construction theorem); (2) establish the Cheeger inequality relating edge expansion to spectral gap; (3) prove edge expansion ≥ c/n using the regularity of the Hamming graph (degree n(m-1)) and the bridge existence theorem.

**Domain Bridges**: Spectral graph theory ↔ Hamming coding theory ↔ Markov chain mixing

**Lineage**: Builds on `fiber_bridge_duality`, `fiber_bridge_exists_of_slot_equal`, and `hamming_neighbor_card` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Fiber Theory

**Conjecture**: For the tropical (min-plus) analog of additive flavor maps, where f(w) = min_i φᵢ(wᵢ) + Σⱼ≠ᵢ ψⱼ(wⱼ), the fiber geometry undergoes a phase transition: fibers of tropical scoring functions are always connected for m ≥ n+1, and disconnected fibers exist for m ≤ n.

**Test**: Enumerate all tropical scoring functions on H(3,3) and H(3,4). Compute fiber connectivity for each. If the conjecture holds, H(3,3) should have disconnected fibers while H(3,4) should have all fibers connected.

**Impact**: Would establish the first connection between tropical geometry and Hamming fiber theory. The phase transition at m = n+1 would parallel the triangle dichotomy (phase transition at m = 3) in a higher-order setting.

**Catalog References**: `Algebra/TropicalDragon.lean`, `Bridges/MinPlusVerificationCore.lean`, `Cryptography/TropicalPostQuantumPrimitives.lean`

**Proof Strategy**: (1) Define the tropical scoring function using the min-plus semiring structure from `tropical_plus_distributes_over_min`. (2) Prove that for m ≥ n+1, any two words in a tropical fiber can be connected by showing the tropical bridge condition is always satisfiable (pigeonhole on alphabet values). (3) Construct explicit counterexamples for m ≤ n using diagonal tropical maps.

**Domain Bridges**: Tropical geometry ↔ Hamming spaces ↔ optimization landscapes

**Lineage**: Builds on `tropical_plus_distributes_over_min` from `Cryptography/TropicalPostQuantumPrimitives.lean` and the fiber bridge theory from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Plotkin Bound Generalization to q-ary Codes

**Conjecture**: For q-ary codes (alphabet size m = q ≥ 2) with minimum distance d > n(q-1)/q, the code size satisfies |C| ≤ qd/(qd - n(q-1)).

**Test**: Enumerate all codes in H(4,3) and H(5,3) for various d values. Verify the bound is tight by constructing codes achieving it.

**Impact**: Would extend the Plotkin bound from binary to arbitrary alphabets. The binary case (q=2, d > n/2) is already proved in this cycle. The q-ary generalization requires a refined coordinate-contribution analysis.

**Catalog References**: `Cryptography/HammingFiberAlgebra.lean` (Plotkin bound proof), `Cryptography/HammingSubstitutionAlgebra.lean` (Singleton bound)

**Proof Strategy**: Generalize the double-counting argument: (1) the lower bound T(C) ≥ d·|C|·(|C|-1) holds unchanged; (2) for the upper bound, at each coordinate the contribution is 2k(|C|-k)(q-1)/q where k counts codewords with a particular value, maximized at k=|C|/q; (3) this gives 2T(C) ≤ n·|C|²·(q-1)/q; (4) combining yields the bound.

**Domain Bridges**: Coding theory ↔ combinatorial optimization ↔ information theory

**Lineage**: Directly extends `plotkin_bound` and `total_dist_upper_bound_binary` from this cycle.

**Ambition**: extension

---

### Direction 4: Fiber Connectivity Classification for Small Parameters

**Conjecture**: An additive map f: H(n,2) → ℤ has all fibers connected in the Hamming graph if and only if all slot functions φᵢ are constant (in which case there is only one fiber).

**Test**: Enumerate all additive maps on H(4,2) and H(5,2). For each non-constant map, find a disconnected fiber. This should always succeed if the conjecture is true.

**Impact**: Would provide a complete classification for the binary case, showing that binary fiber connectivity is maximally fragile — any non-trivial additive scoring immediately creates disconnected fibers. This contrasts sharply with the expectation (from Direction 1) that larger alphabets have mostly connected fibers.

**Catalog References**: `Cryptography/HammingFiberAlgebra.lean` (bridge duality), `Cryptography/HammingSubstitutionAlgebra.lean` (binary triangle-free theorem)

**Proof Strategy**: (1) For binary alphabets, the bridge duality condition requires φᵢ(0) = φᵢ(1) at the differing position — meaning the slot function is constant there. (2) If any slot function is non-constant, construct two words in the same fiber differing at that slot and one other non-constant slot. (3) Show the bridge condition fails (since both slot functions are non-constant, the slot flavor values differ). (4) Conclude that all non-trivially distinct fiber pairs at distance 2 lack bridges, implying disconnection.

**Domain Bridges**: Binary coding theory ↔ Boolean function theory ↔ matroid theory

**Lineage**: Builds on `fiber_bridge_duality` and the binary triangle-free theorem from `HammingSubstitutionAlgebra.lean`.

**Ambition**: extension

---

### Direction 5: Hamming Fiber Entropy and Counting

**Conjecture**: For a uniform additive map f: H(n,m) → ℤ where φᵢ(j) = j for all i, the maximum fiber size is achieved at the "middle" target value t = ⌊n(m-1)/2⌋, and equals Θ(mⁿ / √n) as n → ∞ with m fixed.

**Test**: Compute fiber sizes for uniform additive maps on H(n,3) for n = 3, 4, ..., 10. Plot max fiber size vs mⁿ/√n and check convergence of the ratio.

**Impact**: Would establish a local central limit theorem for Hamming fiber sizes, connecting combinatorial fiber geometry to probability theory. The fiber sizes are precisely the coefficients of the polynomial (1 + x + x² + ... + x^{m-1})ⁿ, which are amenable to saddle-point analysis.

**Catalog References**: `Cryptography/HammingFiberAlgebra.lean`, `Cryptography/Commitments.lean` (entropy bounds)

**Proof Strategy**: (1) Recognize that fiber sizes are multinomial coefficients: |f⁻¹(t)| = [x^t](1+x+...+x^{m-1})ⁿ. (2) Apply the saddle-point method to estimate the coefficient at the maximum. (3) Use Stirling's approximation and the central limit theorem for independent random variables to derive the Θ(mⁿ/√n) asymptotics.

**Domain Bridges**: Combinatorics ↔ probability theory ↔ analytic number theory

**Lineage**: Builds on `hamming_neighbor_card` and `hamming_ball_one_card` from this cycle, extending the counting theme to fiber-level asymptotics.

**Ambition**: extension
