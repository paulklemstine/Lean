# Future Directions: Tropical Residuation and Proof Theory

## 1. Extended Tropical Residuation on `WithBot ℝ`

**Objective:** Formalize tropical residuation over the complete tropical semiring `ℝ ∪ {−∞}`, modeled as `WithBot ℝ` in Lean/Mathlib.

**Hypothesis:** The residuation theorems extend to `WithBot ℝ` with explicit handling of the `−∞` cases:
- `sup(∅) = −∞` is naturally handled by `Finset.sup` with `OrderBot`.
- The residual `c − a` when `c = −∞` should yield `−∞`.
- When `a = −∞`, the translation `x + (−∞) = −∞` for all `x`, and the residual degenerates.

**Proof Strategy:**
1. Use `WithBot ℝ` which already has `OrderBot` and `SemilatticeSup` instances in Mathlib.
2. Define tropical addition as `WithBot.map₂ (· + ·)` or via the existing `Tropical` type in Mathlib.
3. Prove residuation with case analysis on `⊥` vs. `some x`.
4. The matrix-level theorem should follow by the same pattern.

**Key Lemmas to Prove:**
- `tropical_translation_residuation_extended : ∀ (a y c : WithBot ℝ), a + y ≤ c ↔ y ≤ c - a` (with appropriate extended subtraction)
- `tropical_finset_sup_residuation_extended` using `Finset.sup` instead of `sup'`

**Cross-Domain Impact:** Enables modeling of truly tropical (max-plus) systems where `−∞` represents "no information" or "infeasible," which is essential for dynamic programming, scheduling, and automata theory over the tropical semiring.

---

## 2. Residuated Category of Tropical Layers

**Objective:** Define a category whose objects are finite-dimensional real vector spaces (or types with a partial order) and whose morphisms are residuated monotone maps. Prove that this category is closed under composition, products, and coproducts.

**Hypothesis:** The structure `ResiduatedMap α β` (a pair of forward/backward maps satisfying the Galois connection) forms a category:
- Identity: `(id, id)` is residuated.
- Composition: proven by `residual_comp`.
- Products: `(f × g, f♯ × g♯)` is residuated when `f` and `g` are.

**Proof Strategy:**
1. Define `ResiduatedMap` as a structure with `toFun`, `residual`, and the `gc` proof.
2. Define `ResiduatedMap.id` and `ResiduatedMap.comp`.
3. Show this satisfies the category laws (use `CategoryStruct` from Mathlib).
4. Prove the product and coproduct constructions.

**Key Definitions:**
```
structure ResiduatedMap (α β : Type*) [Preorder α] [Preorder β] where
  toFun : α → β
  residual : β → α
  gc : ∀ x y, toFun x ≤ y ↔ x ≤ residual y
```

**Cross-Domain Impact:** This is the categorical foundation for compositional neural network certification. Each layer of a certified network becomes a morphism in this category, and global certificates are computed by categorical composition.

---

## 3. Tropical Cut-Elimination for Proof Networks

**Objective:** Build a formal sequent calculus where:
- Formulas carry real-valued thresholds (not just Boolean truth values).
- Inference rules are tropical residuated maps.
- Cut-elimination is proven by the `residual_comp` theorem.

**Hypothesis:** A "tropical sequent" `Γ ⊢_t A` (where `t ∈ ℝ` is a threshold) admits cut-elimination: if `Γ ⊢_s B` and `B ⊢_t A`, then `Γ ⊢_{s+t} A` (or similar composition rule depending on the calculus design).

**Proof Strategy:**
1. Define tropical sequents as pairs `(context, threshold)`.
2. Define derivations as residuated maps between threshold spaces.
3. The cut rule corresponds to composition of residuated maps.
4. Cut-elimination follows from `residual_comp`: the composite residual is computable.

**Key Theorems:**
- Soundness: every tropical derivation corresponds to a residuated map.
- Cut-elimination: the cut rule is admissible (provable from `residual_comp`).
- Subformula property: cuts can be eliminated, and the resulting derivation only uses subformulas.

**Cross-Domain Impact:** This would be the first formally verified quantitative proof system, connecting tropical algebra to proof theory in a machine-checked way.

---

## 4. Certified Robustness for Max-Plus Neural Architectures

**Objective:** Use the matrix residuation theorems to derive exact backward certificates for layered tropical (max-plus affine) neural networks, and compare with existing interval/abstract-interpretation methods.

**Hypothesis:** For a max-plus network `F = F_{W_L} ∘ ... ∘ F_{W_1}`:
- The backward bound `B_{W_1}(B_{W_2}(...B_{W_L}(z)...))` is the exact tightest input bound.
- This is strictly tighter than interval arithmetic propagation.
- The computation has complexity `O(L · m · n)` where `m, n` are layer dimensions.

**Proof Strategy:**
1. Instantiate `tropical_two_layer_composition_residuation` for `L` layers by induction.
2. Prove that the compositional residual is strictly tighter than naive interval propagation.
3. Implement and benchmark against existing abstract interpretation tools.

**Experimental Validation:**
- Implement the backward pass in Python/NumPy (already done in `algorithms.py`).
- Compare with CROWN, DeepPoly, and other verifiers on max-plus benchmarks.
- Measure the gap between exact tropical certificates and over-approximate methods.

**Cross-Domain Impact:** Provides the first exact (not over-approximate) backward certification method for a class of neural architectures, with formal guarantees.

---

## 5. Morphological Adjunction Equivalence

**Objective:** Prove formally that the tropical aggregation residuation theorem, when instantiated for local neighborhoods on images, recovers the classical dilation-erosion adjunction of mathematical morphology.

**Hypothesis:** For a structuring element `B` and weight function `w : B → ℝ`:
- Dilation `δ_w(f)(x) = sup_{b ∈ B} (f(x-b) + w(b))` is tropical aggregation.
- Erosion `ε_w(g)(x) = inf_{b ∈ B} (g(x+b) - w(b))` is the tropical residual.
- `δ_w(f) ≤ g ↔ f ≤ ε_w(g)` is a direct instance of `tropical_finset_aggregation_residuation`.

**Proof Strategy:**
1. Define dilation and erosion for functions `ℤ → ℝ` (or `Fin n → ℝ`) with finite structuring elements.
2. Show they are instances of `tropicalMatMul` and `tropicalBackward` for appropriate matrices.
3. The Galois connection follows from `tropical_matmul_gc`.

**Key Definitions:**
- `morphDilation (B : Finset ℤ) (w : ℤ → ℝ) (f : ℤ → ℝ) : ℤ → ℝ`
- `morphErosion (B : Finset ℤ) (w : ℤ → ℝ) (g : ℤ → ℝ) : ℤ → ℝ`

**Cross-Domain Impact:** Unifies two independently developed mathematical frameworks (tropical algebra and mathematical morphology) under a single formally verified umbrella, enabling transfer of results in both directions.

---

## 6. Tropical Galois Connections and Fixed-Point Theory

**Objective:** Develop the fixed-point theory of tropical residuated maps. Prove tropical analogues of the Knaster-Tarski theorem and connect to iterative algorithms in dynamic programming.

**Hypothesis:** If `f : ℝⁿ → ℝⁿ` is a tropical affine map (i.e., `f(x) = W ⊗ x` in max-plus notation), then:
- `f` has a greatest fixed point computable as the infimum of the descending chain `f^k(⊤)`.
- The residual `f♯` can accelerate convergence by providing tighter bounds.
- The cycle time vector (tropical eigenvalue) is computable from the critical graph.

**Proof Strategy:**
1. Use Knaster-Tarski for complete lattices (available in Mathlib via `OrderHom.lfp`).
2. Show tropical affine maps are order-preserving (from `tropicalMatMul_monotone`).
3. Connect cycle time computation to strongly connected components.

**Cross-Domain Impact:** Provides formally verified foundations for value iteration in MDPs, max-plus spectral theory, and periodic scheduling.

---

## 7. Multi-Objective Tropical Optimization

**Objective:** Extend tropical residuation to handle multiple output thresholds simultaneously, formalizing Pareto-optimal input bounds.

**Hypothesis:** For a tropical network with output dimension `p`, the set of inputs satisfying `F(x) ≤ z` for a fixed `z` is a downward-closed set in `ℝᵐ`, and the backward residual gives its unique maximal element (componentwise).

**Proof Strategy:**
1. Prove that `{x | ∀ j, F(x)_j ≤ z_j}` is a principal downward ideal in `(ℝᵐ, ≤)`.
2. The generator of this ideal is exactly `tropicalBackward W z`.
3. For multi-layer networks, this extends by `tropical_two_layer_composition_residuation`.

**Cross-Domain Impact:** Provides foundations for multi-objective robust optimization in tropical settings, with applications to multi-criteria scheduling and multi-output neural network verification.
