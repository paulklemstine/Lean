# Future Directions: Tropical Transversality and Polyhedral Stratification Theory

This document outlines concrete next steps for extending the formally verified tropical transversality framework, each with precise theorem statements, proof strategies, and cross-domain connections.

---

## Direction 1: Polyhedral Active Strata and Bounded Cell Theorem

### Exact Theorem Statement

```lean
/-- The active stratum for index set s: points where exactly the indices in s
    achieve the maximum (and the max-affine value exceeds all other indices). -/
def activeStratum {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (s : Finset α) : Set (E n) :=
  {x | (∀ i ∈ s, ∀ j ∈ s, affineFun w b i x = affineFun w b j x) ∧
       (∀ i ∈ s, ∀ j ∉ s, affineFun w b j x < affineFun w b i x)}

theorem activeStratum_is_polyhedral {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (s : Finset α) (hs : s.Nonempty)
    (i0 : α) (hi0 : i0 ∈ s)
    (h_ind : LinearIndependent ℝ (fun i : {i // i ∈ s.erase i0} => w i.1 - w i0)) :
    ∃ (S : AffineSubspace ℝ (E n)) (ineqs : Finset ({j // j ∉ s} × {i // i ∈ s})),
      activeStratum w b s =
        ↑S ∩ ⋂ p ∈ ineqs, {x | affineFun w b p.2.1 x > affineFun w b p.1.1 x} := by
  sorry
```

### Proof Strategy

1. Reuse `tieSet_eq_preimage` to characterize the equality constraints as an affine subspace.
2. The strict inequality constraints are half-spaces intersected with the affine subspace.
3. The result is a (relatively open) polyhedron inside the affine subspace.
4. Use Mathlib's `Convex` and `Polyhedron` infrastructure (or build it) to formalize the polyhedral structure.

### Cross-Domain Connection

**Nonsmooth optimization.** Active strata are the natural domains for Clarke subdifferential analysis of max-affine functions. On each active stratum, the function is smooth (affine), and the subdifferential at a boundary point is the convex hull of the gradients of adjacent strata. Formalizing polyhedral active strata is the first step toward certified nonsmooth sensitivity analysis.

---

## Direction 2: Generic Bias Theorem via Explicit Bad-Parameter Hyperplanes

### Exact Theorem Statement

```lean
/-- The set of biases that cause unexpected rank drop for some stratum. -/
def badBiasSet {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (w : α → E n) : Set (α → ℝ) :=
  {b | ∃ s : Finset α, ∃ i0 ∈ s,
    LinearIndependent ℝ (fun i : {i // i ∈ s.erase i0} => w i.1 - w i0) →
    ∃ j ∉ s,
      ∀ x ∈ tieSet w b s, affineFun w b j x = affineFun w b i0 x}

theorem badBiasSet_is_finite_union_of_affine_subspaces {n : ℕ} {α : Type*}
    [Fintype α] [DecidableEq α]
    (w : α → E n)
    (hw : ∀ i j : α, i ≠ j → w i ≠ w j) :
    ∃ (H : Finset (Submodule ℝ (α → ℝ))),
      badBiasSet w ⊆ ⋃ V ∈ H, (V : Set (α → ℝ)) ∧
      ∀ V ∈ H, V ≠ ⊤ := by
  sorry

theorem exists_good_biases {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (w : α → E n)
    (hw : ∀ i j : α, i ≠ j → w i ≠ w j) :
    ∃ b : α → ℝ, b ∉ badBiasSet w := by
  sorry
```

### Proof Strategy

1. For each subset s and each "extra" index j ∉ s, the condition that j is accidentally tied on the tie set of s translates to a linear equation in the bias vector b.
2. Each such equation defines a proper affine hyperplane in the bias space ℝ^α.
3. The total bad set is a finite union of these hyperplanes (finite because α is finite).
4. A finite union of proper subspaces of a vector space over ℝ (an infinite field) cannot be all of ℝ^α.

### Cross-Domain Connection

**Neural network genericity.** For ReLU networks, the biases are learnable parameters. This theorem would prove that for generic bias initialization, the activation boundary structure is as "clean" as possible — no unexpected degeneracies. This provides theoretical backing for the empirical observation that random initialization leads to well-behaved activation patterns.

---

## Direction 3: Tropical Sard Theorem for Piecewise-Linear Maps

### Exact Theorem Statement

```lean
/-- A piecewise-linear map between Euclidean spaces defined by max-affine components. -/
def maxAffineMap {m n : ℕ} {α : Type*} [Fintype α]
    (W : (Fin m) → α → E n) (B : (Fin m) → α → ℝ)
    (x : E n) : EuclideanSpace ℝ (Fin m) :=
  fun j => ⨆ i : α, affineFun (W j) (B j) i x

theorem tropical_sard {m n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (W : (Fin m) → α → E n) (B : (Fin m) → α → ℝ)
    (hm : m < n) :
    ∃ (bad : Finset (Set (EuclideanSpace ℝ (Fin m)))),
      (∀ S ∈ bad, ∃ V : AffineSubspace ℝ (EuclideanSpace ℝ (Fin m)),
        S ⊆ ↑V ∧ V ≠ ⊤) ∧
      ∀ c ∉ ⋃₀ bad.toSet,
        ∀ x, IsRegularPoint (maxAffineMap W B) x (c) := by
  sorry
```

### Proof Strategy

1. On each activation pattern (combinatorial type), the max-affine map restricts to an affine map.
2. The affine map is a "regular value" computation: critical points occur where the affine Jacobian drops rank.
3. By linear algebra, rank drop conditions define proper affine subspaces of the target.
4. Take the finite union over all activation patterns.

### Cross-Domain Connection

**Computational topology.** A formal tropical Sard theorem would enable certified computation of tropical homology groups, by guaranteeing that generic linear projections of tropical varieties have the expected fiber structure. This connects to persistent homology and topological data analysis.

---

## Direction 4: Polyhedral Morse Inequalities

### Exact Theorem Statement

```lean
/-- The number of k-dimensional active strata of a max-affine function. -/
def numActiveStrata {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (k : ℕ) : ℕ :=
  Finset.card {s ∈ Finset.univ.powerset |
    s.card = n - k + 1 ∧ (activeStratum w b s).Nonempty}

theorem polyhedral_morse_inequality {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (c : E n)
    (h_generic : ∀ s : Finset α, s.card ≥ 2 →
      ¬ c ∈ (tieDirection w s).orthogonal)
    (h_bounded : IsBounded (cornerLocus w b)) :
    ∀ k, numCriticalPoints w b c k ≤ numActiveStrata w b k := by
  sorry
```

### Proof Strategy

1. On each active stratum, the linear functional c has at most one critical point (by non-constancy theorem and convexity).
2. The total number of critical points is bounded by the number of strata.
3. Formalize using Euler characteristic / Betti number bounds from discrete Morse theory (Forman's theory).

### Cross-Domain Connection

**Stratified Morse theory.** Goresky-MacPherson's stratified Morse theory provides Morse inequalities for Whitney-stratified spaces. The polyhedral version should give analogous bounds for tropical varieties, connecting the combinatorics of the max-affine decomposition to the topology of the level sets. This would be foundational for formal tropical homology.

---

## Direction 5: Certified Robustness for Max-Affine Neural Architectures

### Exact Theorem Statement

```lean
/-- A maxout network layer with k groups of m neurons each. -/
def maxoutLayer {n₁ n₂ : ℕ} {m : ℕ}
    (W : Fin n₂ → Fin m → E n₁) (B : Fin n₂ → Fin m → ℝ)
    (x : E n₁) : EuclideanSpace ℝ (Fin n₂) :=
  fun j => ⨆ i : Fin m, inner ℝ (W j i) x + B j i

theorem maxout_lipschitz_bound {n₁ n₂ m : ℕ}
    (W : Fin n₂ → Fin m → E n₁) (B : Fin n₂ → Fin m → ℝ) :
    LipschitzWith (⨆ j : Fin n₂, ⨆ i : Fin m, ‖W j i‖₊)
      (maxoutLayer W B) := by
  sorry

theorem maxout_decision_boundary_stable {n₁ n₂ m : ℕ}
    (W : Fin n₂ → Fin m → E n₁) (B : Fin n₂ → Fin m → ℝ)
    (h_transversal : ∀ (j : Fin n₂) (s : Finset (Fin m)),
      s.card ≥ 2 →
      LinearIndependent ℝ (fun i : {i // i ∈ s.erase (s.min' (by omega))} =>
        W j i.1 - W j (s.min' (by omega)))) :
    ∃ ε > 0, ∀ B' : Fin n₂ → Fin m → ℝ,
      (∀ j i, |B' j i - B j i| < ε) →
      SameActivationPattern (maxoutLayer W B) (maxoutLayer W B') := by
  sorry
```

### Proof Strategy

1. The Lipschitz bound follows from the fact that max preserves Lipschitz constants and inner products are bounded by norms.
2. The stability theorem uses the transversality condition: when difference vectors are linearly independent, the tie strata are robust under small bias perturbations. A small enough perturbation cannot create new intersections between strata or collapse existing ones.
3. Quantify "small enough" using the minimum gap between non-tied affine functions on each stratum.

### Cross-Domain Connection

**Adversarial robustness in AI.** Certified robustness bounds for neural networks are a major open challenge. The transversality framework provides exact structural guarantees about how decision boundaries move under parameter perturbation. This connects formal mathematics to the practical problem of certifying that small input or parameter perturbations don't change network predictions.

---

## Research Program Summary

These five directions form a coherent research program:

1. **Direction 1** (polyhedral strata) extends the affine theory to full polyhedral structure.
2. **Direction 2** (generic biases) proves that "most" parameters give non-degenerate geometry.
3. **Direction 3** (tropical Sard) generalizes from single functions to maps.
4. **Direction 4** (Morse inequalities) connects geometry to topology.
5. **Direction 5** (certified robustness) applies the theory to neural networks.

Each direction builds on the infrastructure established in this work (tie sets, difference maps, codimension computations) and creates reusable formal components for the next. Together, they would constitute a comprehensive formal framework for **generic tropical stratified geometry** — a new direction in formalized mathematics.
