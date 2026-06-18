# Future Directions: Formal Metamathematical Novelty Theory

## Conjecture 1: Coordinate Completeness for Finite Sup-Norm Spaces

**Conjecture:** For any finite novelty space where `dist(x,y) = sup_n |emb(x,n) - emb(y,n)|` (i.e., the distance equals the supremum of coordinate differences), every novelty certificate at radius r is witnessed by a single coordinate at radius r.

**Precise statement:**
```
∀ (S : NoveltySpace α) (C : Finset α) (x : α) (r : ℝ),
  (∀ x y, S.dist x y = ⨆ n, |S.emb x n - S.emb y n|) →
  CorpusNovel S {y | y ∈ C} x r →
  ∃ n : ℕ, ∀ y ∈ C, r ≤ |S.emb x n - S.emb y n|
```

**Why it might be true:** When the distance is defined as the supremum of coordinates, the minimum distance to the corpus is realized by a supremum over coordinates of a minimum over corpus elements. By a minimax argument, the order might interchange for finite sets.

**Test:** Construct explicit finite sup-norm spaces and verify computationally. If true, prove formally. If false, the counterexample would show that the minimax interchange fails, which would be interesting in its own right.

**Impact:** If true, this would show that for sup-norm spaces, the coordinate scan algorithm (Algorithm 2) is *optimal* — it finds the exact novelty radius, not just a lower bound. This would eliminate the gap between cheap coordinate certification and expensive direct computation for a natural class of spaces.

---

## Conjecture 2: Novelty Witness Complexity is Sublinear

**Conjecture:** For a finite novelty space with N embedding coordinates, the minimum number of coordinates needed to certify novelty at radius r/2 (given that full-metric novelty holds at radius r) is O(log |C|) where |C| is the corpus size.

**Precise statement:** Define witness complexity as
```
W(S, C, x, r) := min { k | ∃ n₁,...,nₖ, ∀ y ∈ C, ∃ i ≤ k, r/2 ≤ |emb x nᵢ - emb y nᵢ| }
```
Conjecture: W(S, C, x, r) = O(log |C|) for "random" novelty spaces.

**Why it might be true:** Each coordinate roughly halves the set of corpus elements that are "close" along that coordinate. By a probabilistic argument analogous to set cover, O(log |C|) coordinates should suffice to separate the candidate from all corpus elements.

**Test:** Generate random novelty spaces with |C| ranging from 10 to 10,000 and measure the empirical witness complexity. Plot W vs. log |C| to test the predicted scaling.

**Impact:** If true, this would mean novelty certification is *doubly efficient*: not only is each coordinate check O(|C|), but only O(log |C|) coordinates are needed. Total cost: O(|C| log |C|), which is nearly linear.

---

## Conjecture 3: Triangle Inequality Enables Novelty Transitivity

**Conjecture:** If the novelty space satisfies the triangle inequality (`dist(x,z) ≤ dist(x,y) + dist(y,z)`), then novelty is "transitive" in the following sense: if x is r₁-novel w.r.t. C and y is r₂-novel w.r.t. C with dist(x,y) ≤ δ, then y is (r₁ - δ)-novel w.r.t. C.

**Precise statement:**
```
theorem novelty_transfer_triangle
  (S : NoveltySpace α)
  (triangle : ∀ x y z, S.dist x z ≤ S.dist x y + S.dist y z)
  (C : Set α) (x y : α) (r δ : ℝ)
  (hx : CorpusNovel S C x r)
  (hxy : S.dist x y ≤ δ) :
  CorpusNovel S C y (r - δ)
```

**Why it might be true:** For any z ∈ C, dist(y,z) ≥ dist(x,z) - dist(x,y) ≥ r - δ by the triangle inequality.

**Test:** Formalize the statement in Lean and attempt to prove it. The proof should follow directly from the triangle inequality.

**Impact:** This would enable *incremental* novelty updates: when a new theorem y is added near a known novel theorem x, its novelty can be bounded without recomputing distances to the entire corpus. This is crucial for scalable library maintenance.

---

## Conjecture 4: Information-Theoretic Bound on Novelty Degradation

**Conjecture:** For any two novelty spaces S and T connected by an L-Lipschitz map f, the "novelty entropy" (defined as the logarithm of the novelty radius) degrades by at most log(L):

```
log(novelty_T(f(x), f(C))) ≥ log(novelty_S(x, C)) - log(L)
```

**Precise statement:** This is equivalent to novelty_pullback_lipschitz (already proved), but the information-theoretic reformulation suggests a deeper connection.

**Why it might be true:** This follows immediately from our Theorem 3.10, which states r_source ≥ r_target / L. Taking logarithms gives the information-theoretic form. The deeper conjecture is whether an *additive* version holds with better constants when additional structure (e.g., metric entropy bounds) is available.

**Test:** Explore whether the log-form has better composition properties. Specifically, test whether log-novelty composes additively under map composition: log(novelty after g∘f) ≥ log(novelty before) - log(L_f) - log(L_g), which should follow from lipschitz_comp.

**Impact:** If the additive log-form has natural extensions, it would establish a formal "information theory of mathematical novelty" where theorem transformations act as information channels with bounded capacity. This could lead to a Shannon-style channel coding theorem for mathematical knowledge.

---

## Conjecture 5: Novelty Spaces from Proof Terms Have Bounded Dimension

**Conjecture:** For novelty spaces constructed from proof term features of a typed lambda calculus (such as the Calculus of Inductive Constructions used by Lean), the "effective dimension" — the number of coordinates needed to recover 90% of the full distance — is bounded by O(log(proof_size)).

**Why it might be true:** Proof terms have recursive structure, and structural features at different depths capture exponentially more information per level. The analogy is to the efficiency of tree-based representations: a tree of depth d with branching factor b has b^d leaves but only d levels of structural features.

**Test:** Implement a concrete novelty space for Lean proof terms using features such as: type depth, number of applications, number of lambda abstractions, number of match expressions, maximum de Bruijn index, etc. Measure the effective dimension on the Mathlib library by computing pairwise distances and checking how many coordinates are needed to approximate them.

**Impact:** If true, this would mean that novelty certification for real proof libraries requires checking only O(log n) features where n is the proof size — making the theory practically efficient even for large proofs. Combined with Conjecture 2, the total complexity of novelty certification would be O(|C| · log(proof_size) · log(|C|)), which is extremely practical.
