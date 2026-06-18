# Future Directions: M-Convex Shadow Compression Theory

## Synthesis

The Universal M-Convex Compression Theorem establishes that derivative recognition complexity for Lorentzian polynomials is controlled by the shadow geometry of M-convex supports. This opens five interconnected research directions. The first two are paradigm-shifting conjectures that would extend the theory from nonneg-coefficient polynomials to the full signed case and from discrete to tropical geometry. The remaining three are solid extensions building directly on the proven theorems, strengthening the algorithmic, algebraic-combinatorial, and statistical-physical aspects of the theory. Together, these directions aim to make M-convex shadow geometry the universal language for polynomial certificate complexity.

---

## Direction 1: Signed Coefficient Extension via Exchange-Separation

**Conjecture:** For polynomials with signed coefficients and M-convex Newton support, the exchange-visible shadow is exactly characterized by a purely combinatorial *exchange-separation* condition: α ∈ EVShadow if and only if no two distinct fiber elements β₁, β₂ ∈ QFiber(S, α) produce derivative terms with canceling signs after accounting for multinomial weights.

**Test:** Implement a systematic search over small M-convex sets (|S| ≤ 15, n ≤ 5) with randomly signed coefficients. For each shadow element, compute the derivative coefficient as a weighted sum over the fiber. Compare the set of nonzero-derivative shadow elements with the prediction from exchange-separation. Quantify the gap between EVShadow and full shadow as a function of the sign distribution.

**Impact:** This would identify the exact boundary between universal compression (nonneg case) and partial compression (signed case), potentially revealing a phase transition in certificate complexity as the coefficient sign distribution varies.

**Catalog References:**
- `Catalog/Pythagorean/MConvexCompression.lean` — `exchangeVisible_eq_degreeShadow` (proves the nonneg case)
- `Catalog/Pythagorean/MConvexCompression.lean` — `NoCancellationOnFiber` (the definition to generalize)

**Proof Strategy:** Define *exchange-separation* as a condition on pairs (β₁, β₂) in the fiber: they are separated if the residuals β₁ − α and β₂ − α do not share a common two-step decomposition. Prove that M-convex exchange forces separation for "generic" support elements. The key step is a counting argument: the number of potential collision pairs is bounded by the fiber size, while exchange provides enough degrees of freedom to avoid all collisions.

**Domain Bridges:** Algebraic geometry (Newton polygon theory), computational algebra (Gröbner basis support analysis)

**Lineage:** Direct extension of `exchangeVisible_eq_degreeShadow`

**Ambition:** Grand challenge — would complete the compression theory for all Lorentzian polynomials, not just nonneg ones

---

## Direction 2: Tropical Shadow Compression and Valuated Matroids

**Conjecture:** For a valuated M-convex set (a tropical analogue of an M-convex set equipped with a valuation function), the tropical shadow at degree k encodes the certificate complexity of the corresponding tropical Lorentzian polynomial. The tropical shadow cardinality equals the number of "tropically nonzero" quadratic derivative leaves.

**Test:** Implement valuated M-convex sets using tropical arithmetic. Compute tropical derivatives (min-plus convolutions) and tropical shadows. Compare with the classical shadow on the underlying M-convex support after forgetting valuations. Test on valuated matroids from the literature (e.g., Dress-Wenzel valuations on uniform matroids).

**Impact:** Would establish M-convex shadow compression as a tool in tropical geometry, connecting derivative complexity to polyhedral subdivision theory. This could lead to polynomial-time algorithms for tropical Lorentzian certification via polyhedral methods.

**Catalog References:**
- `Catalog/Pythagorean/MConvexCompression.lean` — `MConvexShadowFinset` (the shadow to tropicalize)
- `Catalog/Pythagorean/TropicalMConvexity.lean` — tropical M-convex framework
- `Catalog/Pythagorean/TropicalLorentzianShadows.lean` — prior tropical shadow work

**Proof Strategy:** Define the tropical shadow as the min-plus projection of the valuated support. Use the tropical exchange property (which generalizes M-convex exchange to the valuated setting) to prove that tropical fibers are nonempty exactly when the tropical shadow element exists. The key insight is that tropical nonzeroness corresponds to the min-plus analog of the derivative weight being finite.

**Domain Bridges:** Tropical geometry, polyhedral combinatorics, algorithmic optimization

**Lineage:** Extends `MConvexShadowFinset` to the valuated/tropical setting

**Ambition:** Grand challenge — would unify discrete convex and tropical approaches to Lorentzian theory

---

## Direction 3: Efficient Shadow Algorithms via Exchange Enumeration

**Conjecture:** The degree-k shadow of an M-convex set S ⊆ ℕⁿ with |S| = m and max coordinate value C can be computed in time O(m · n · |Shadow_k(S)|) using an exchange-based enumeration that avoids generating the full downward closure.

**Test:** Implement a BFS/DFS exchange-based shadow enumeration starting from known shadow elements (obtained by dropping coordinates from support elements). Benchmark against the naive enumeration (iterating over all α ≤ β for each β ∈ S) on uniform matroid supports with n up to 20 and r up to 10.

**Impact:** Would make the compression theorem practically applicable to large-scale instances where the naive shadow computation is infeasible. The key insight is that M-convex exchange provides a local navigation structure on the shadow.

**Catalog References:**
- `Catalog/Pythagorean/MConvexCompression.lean` — `MConvexShadowFinset` (current O(|S| · C^n) algorithm)
- `Catalog/Pythagorean/MConvexCompression.lean` — `exchange_direction_exists` (the navigation primitive)

**Proof Strategy:** Define a graph on Shadow_k(S) where edges connect α and α − eᵢ + eⱼ when both are in the shadow. Prove this graph is connected using M-convex exchange on the support. Then enumerate shadow elements by BFS from any initial shadow element, using the exchange direction lemma to generate neighbors.

**Domain Bridges:** Combinatorial optimization (polytope vertex enumeration), computational complexity

**Lineage:** Builds on `exchange_direction_exists` and `mconvex_fiber_exchange`

**Ambition:** Solid extension — practical algorithmic improvement

---

## Direction 4: Shadow Compression for Symmetric Function Supports

**Conjecture:** For the Newton support of a Schur-positive symmetric function (expressed in monomial symmetric polynomials), the M-convex compression theorem gives the exact count of nonzero quadratic derivatives, and this count has a closed-form expression in terms of Young tableau combinatorics.

**Test:** Compute Newton supports of Schur polynomials s_λ for small partitions λ. Verify M-convexity. Compare shadow cardinality with the number of semistandard Young tableaux of shape λ truncated to degree |λ| − 2. Test whether the fiber sizes correspond to Kostka numbers or similar tableau statistics.

**Impact:** Would connect the compression theorem to the rich combinatorics of symmetric functions, potentially revealing new positivity phenomena. The key insight is that Schur-positivity already implies nonneg coefficients in the monomial basis, so the compression theorem applies directly.

**Catalog References:**
- `Catalog/Pythagorean/MConvexCompression.lean` — `nonzero_leaf_count_eq_shadow_card` (the counting formula)
- `Catalog/Pythagorean/MConvexCompression.lean` — `matroidBasisSupport_homogeneous` (matroid specialization)

**Proof Strategy:** Express the Newton support of s_λ as the set of content vectors of semistandard Young tableaux. Verify that this set satisfies M-convex exchange (a known result in the combinatorics of RSK correspondence). Apply the compression theorem. Derive the closed-form shadow size using the hook-length formula or similar combinatorial identity.

**Domain Bridges:** Algebraic combinatorics (symmetric functions, Young tableaux), representation theory

**Lineage:** Extends `matroid_compression_corollary` from matroid bases to symmetric function supports

**Ambition:** Solid extension — connects to a major area of algebraic combinatorics

---

## Direction 5: Partition Function Derivative Complexity in Statistical Physics

**Conjecture:** For the partition function Z = Σ_σ exp(−βH(σ)) of a ferromagnetic lattice system, where σ ranges over spin configurations and H is the Hamiltonian, the number of nonzero second-order fluctuation observables (quadratic derivative leaves) is controlled by the M-convex shadow of the occupation number support. Specifically, the shadow cardinality gives the exact count of independent two-point correlation functions.

**Test:** Compute the Newton support of Z for small Ising/Potts models on lattices with n ≤ 8 sites. Verify M-convexity of the support (which holds for ferromagnetic systems by the FKG inequality framework). Compare the shadow cardinality with the number of independent two-point correlators as predicted by the compression theorem.

**Impact:** Would connect the compression theorem to statistical physics, providing a new tool for analyzing the complexity of correlation structure in lattice models. The key insight is that ferromagnetic systems have nonneg Boltzmann weights, so the compression theorem applies, and the occupation number supports are M-convex by the exchange property of spin configurations.

Why now? The connection between Lorentzian polynomials and log-concavity in statistical physics (via the Lee-Yang theorem and its extensions) has been recently clarified. The M-convex compression theorem provides the missing link between the algebraic structure (Lorentzian property) and the physical structure (correlation complexity).

**Catalog References:**
- `Catalog/Pythagorean/MConvexCompression.lean` — `derivWeight_pos` (weight positivity = no cancellation)
- `Catalog/Pythagorean/MConvexCompression.lean` — `derivative_nonzero_iff_in_shadow` (survival criterion)

**Proof Strategy:** Model the partition function as a polynomial in fugacity variables. Express the Newton support as the set of feasible occupation vectors. Use the Fortuin-Kasteleyn representation to establish M-convex exchange for ferromagnetic supports. Apply the compression theorem to count independent correlators.

**Domain Bridges:** Statistical physics (Ising/Potts models, correlation inequalities), probability theory (negative dependence)

**Lineage:** Extends `derivative_nonzero_iff_in_shadow` to a physical interpretation

**Ambition:** Solid extension with potential for paradigm shift — bridges pure mathematics and physics
