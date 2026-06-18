# Future Directions: Tropical Topological Learning Theory

## Synthesis

The formally verified results in this project establish a mathematical foundation for *tropical topological learning theory*: the study of neural loss landscapes through the lens of tropical degeneration and arithmetic invariants. The core results—sublevel convexity (Theorem 3.5), active-set complex monotonicity (Theorem 3.8), tropical max invariance under valuation equivalence (Theorem 4.4), and active complex bijection under sign-type equivalence (Theorem 4.7)—together demonstrate that the combinatorial topology of tropical loss landscapes is controlled by arithmetic/combinatorial data rather than analytic details.

The five directions below extend this foundation in complementary ways: Directions 1-2 are grand challenges that, if resolved, would establish tropical geometry as a fundamental tool in learning theory. Directions 3-5 are solid extensions that build directly on the verified theorems and are within reach of current methods.

All directions share a common thread: the passage from smooth, analytic, high-dimensional objects (loss functions, gradient flows, training dynamics) to finite, combinatorial, arithmetic objects (active-set complexes, valuation profiles, arrangement face lattices) that are computable and formally verifiable.

---

## Direction 1: Arithmetic Universality for Deep Compositions

**Conjecture:** For multi-layer ReLU networks L = σ_k ∘ W_k ∘ ··· ∘ σ_1 ∘ W_1 with tropical degeneration parameter t, the limiting active-set complex of the composed loss depends only on the *tropical composition diagram*: the sequence of weight matrices' valuation profiles and the combinatorial type of each layer's arrangement. Specifically, if two k-layer networks have valuation-equivalent weight matrices at each layer and the same activation pattern incidence structure, their tropical active-set complexes are isomorphic.

**Test:** Construct pairs of 3-layer ReLU networks with identical valuation profiles but different coefficients. Compute the linear region decomposition numerically (using the polyhedral tools of [Serra et al., 2018]). Verify that the number and incidence structure of linear regions agree. A single pair where the linear region counts disagree would refute the conjecture.

**Impact:** This would extend the single-layer universality results (Theorems 4.4, 4.7) to the architecturally relevant multi-layer setting, establishing that the "effective complexity" of a deep network is an arithmetic invariant of its weight matrices.

**Catalog References:** `Tropical/ArithmeticUniversality/Defs.lean` — Theorems `tropMax_eq_of_valuationEquivalent`, `activeComplex_bij_of_sameSignType`

**Proof Strategy:** Define tropical composition as the max-plus analogue of matrix multiplication. Show that the composed tropical function's Newton polytope is the Minkowski sum of layer polytopes. Prove that the active-set complex of the composition is determined by the face lattices of the summands, which are arrangement invariants. Key technical lemma: tropical composition preserves the sign-type equivalence relation.

**Domain Bridges:** Tropical geometry ↔ deep learning theory; arrangement combinatorics ↔ linear region counting; Newton polytope theory ↔ network expressivity

**Lineage:** Extends Theorems 4.4 and 4.7 from single-layer max to multi-layer compositions

**Ambition:** ★★★★★ (Grand Challenge — would unify tropical geometry with deep learning theory)

---

## Direction 2: Persistent Homology of Tropical Filtrations

**Conjecture:** For a tropical affine family F, the persistence diagram of the sublevel filtration {S_F(c)}_{c ∈ ℝ} has at most |𝒜_F| bars (where 𝒜_F is the active-set complex), and the endpoints of all bars correspond to critical values c where the active-set complex changes. Moreover, the normalized Betti vector β(c)/vol(S_F(c)) converges, as the number of affine forms grows, to a limit that depends only on the valuation profile of F.

**Test:** For families of 5, 10, 20, 50 random affine forms in ℝ², compute the persistence diagrams using Ripser or GUDHI. Count the number of bars and compare to |𝒜_F|. Plot normalized Betti numbers and check for convergence across valuation-equivalent families with different coefficients.

**Impact:** Would establish a precise bridge between tropical combinatorics and persistent homology, giving a finite combinatorial bound on the topological complexity of loss landscape filtrations. The convergence statement would be a *topological central limit theorem* for random tropical landscapes.

**Catalog References:** `Tropical/ArithmeticUniversality/Defs.lean` — Theorems `sublevel_mono`, `activeSetComplex_mono`, `tropMax_sublevel_convex`

**Proof Strategy:** The convexity theorem (Theorem 3.5) implies all sublevel sets are contractible when nonempty, so β₀ = 1 and higher Betti numbers vanish for the tropical max. The interesting topology arises for *tropical min* or *tropical polynomial* losses where sublevel sets are not convex. For these, use the Nerve theorem to relate the topology of the sublevel set to the nerve of the active-set cover, then bound the nerve complex size by |𝒜_F|.

**Domain Bridges:** Tropical geometry ↔ persistent homology; Nerve theorem ↔ Čech complexes; random matrix theory ↔ random hyperplane arrangements

**Lineage:** Builds on sublevel filtration monotonicity (Theorem 3.8) and convexity (Theorem 3.5)

**Ambition:** ★★★★★ (Grand Challenge — would create a new bridge between tropical and computational topology)

---

## Direction 3: Tropical Morse Theory via Active-Set Transitions

**Conjecture:** Define a *tropical critical value* as a threshold c where the active-set complex 𝒜_F^{sub}(c) strictly increases (gains a new cell). Then:
(a) The number of tropical critical values is at most C(k, 2) (the number of pairs of affine forms).
(b) At each tropical critical value, exactly one new maximal cell appears in the active-set complex.
(c) The sequence of cell additions determines a discrete Morse function on the arrangement, and its Morse inequalities bound the topology of the sublevel filtration.

**Test:** For 100 random tropical families in ℝ² with k = 3, 5, 10 forms, enumerate all critical values (thresholds where pairs of affine forms intersect the boundary of the sublevel set). Verify (a) and (b). Compute the Morse numbers and compare to Betti numbers.

**Impact:** Would provide a discrete Morse-theoretic framework for tropical loss landscapes without requiring smooth manifold theory. The Morse inequalities would give computable bounds on topological complexity.

**Catalog References:** `Tropical/ArithmeticUniversality/Defs.lean` — Theorems `activeSetComplex_mono`, `activeSet_iff_dominates`, `mem_sublevel_iff_forall_le`

**Proof Strategy:** Part (a): each new cell requires two affine forms to become equal at the boundary, giving at most C(k,2) transitions. Part (b): show that at a generic critical value, the new cell is the active set {i, j} where f_i = f_j = c, and this is maximal because all other forms are strictly less. Part (c): define the discrete Morse function by the order of cell additions; apply Forman's discrete Morse theory.

**Domain Bridges:** Tropical geometry ↔ discrete Morse theory; hyperplane arrangements ↔ critical event analysis; Morse inequalities ↔ topological bounds

**Lineage:** Direct extension of active-set complex monotonicity (Theorem 3.8)

**Ambition:** ★★★☆☆ (Solid extension — discrete Morse theory is well-developed)

---

## Direction 4: Zero-Temperature Correspondence with Error Bounds

**Conjecture:** For the softmax (log-sum-exp) smoothing L_β(x) = (1/β) log Σᵢ exp(β f_i(x)):
(a) |L_β(x) - T_F(x)| ≤ log(k)/β for all x (where k = |ι|).
(b) The active set of L_β (defined as indices within ε of the max) converges to A_F(x) as β → ∞.
(c) The sublevel set S_{L_β}(c) converges to S_F(c) in the Hausdorff metric as β → ∞.
(d) Two polynomial families that are valuation-equivalent have softmax losses whose sublevel topology agrees for all sufficiently large β.

**Test:** For a fixed tropical family with k = 5 forms in ℝ², compute sublevel sets of L_β for β = 1, 10, 100, 1000. Measure Hausdorff distance to the tropical sublevel set. Verify the log(k)/β bound. For valuation-equivalent families, compare sublevel topology (connected components, holes) and verify agreement for large β.

**Impact:** Would rigorously connect the formal tropical theory to the softmax functions used in practice. Part (d) would extend arithmetic universality from the tropical limit to the finite-temperature regime.

**Catalog References:** `Tropical/ArithmeticUniversality/Defs.lean` — Theorems `tropMax_eq_of_valuationEquivalent`, `sublevelSet_eq_of_valuationEquivalent`

**Proof Strategy:** Part (a) is a standard log-sum-exp bound. Part (b) follows from the fact that exp(β(f_i - max)) → δ_{i ∈ A_F}. Part (c) uses convexity and the uniform convergence from (a). Part (d) combines (c) with the sublevel set equality theorem (Theorem 4.5).

**Domain Bridges:** Statistical mechanics (zero-temperature limits) ↔ tropical geometry; Gibbs measures ↔ active-set distributions; free energy ↔ tropical max

**Lineage:** Extends Theorem 4.4 to the smooth (finite-temperature) regime

**Ambition:** ★★★☆☆ (Solid extension — standard analysis techniques apply)

---

## Direction 5: Counterexample Search for Gluing Regularity

**Conjecture (Negative):** There exist pairs of piecewise-polynomial functions with identical tropical support (same exponents and weights) but different *gluing data* (different transition maps between linear regions) such that:
(a) Their active-set complexes are isomorphic, but
(b) Their sublevel set homology differs for some threshold c.

If such counterexamples exist, they would show that arithmetic universality requires a *regularity hypothesis* beyond valuation equivalence—specifically, a condition on how the smooth (non-tropical) corrections interact at arrangement walls.

**Test:** Construct explicit spline functions in ℝ² with 3-4 pieces. Choose gluing data that creates or destroys a hole in the sublevel set at a specific threshold. Compute persistent homology using GUDHI. If a robust mismatch is found, characterize the minimal gluing obstruction.

**Impact:** Would sharpen the universality conjecture by identifying the precise boundary between "details that don't matter" and "details that do." A clean counterexample would be as valuable as a positive result, because it would define the regularity hypothesis needed for the full theory.

**Catalog References:** `Tropical/ArithmeticUniversality/Defs.lean` — `ValuationEquivalent`, `ActiveSetComplex`

**Proof Strategy:** For the counterexample: use a 3-piece piecewise-linear function in ℝ² where two pieces create a "fold" that introduces a 1-cycle in the sublevel set. The tropical data (max of affine forms) cannot detect this fold because it depends on the gluing. For the positive regularity result: impose a "tropical regularity" condition requiring that transition maps between linear regions preserve the sign of the tropical correction terms. Show that under this condition, the sublevel topology is determined by the active-set complex.

**Domain Bridges:** Tropical geometry ↔ piecewise-polynomial approximation; regularity theory ↔ sheaf conditions; spline theory ↔ tropical varieties

**Lineage:** Tests the boundaries of Theorems 4.4 and 4.5

**Ambition:** ★★☆☆☆ (Concrete and testable — computational search with clear success/failure criteria)
