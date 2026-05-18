/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Causal Ordering

This file establishes a **causal preorder** framework derived from tropical distance-like
functionals. The central insight is that any function `τ : α → α → ℝ` satisfying a
(standard additive) triangle inequality `τ x z ≤ τ x y + τ y z` induces:

1. A **budgeted causal relation** `TropicalCausal τ T x y := τ x y ≤ T`,
   with composable budgets under transitivity.
2. A **zero-budget future relation** `TropicalFuture τ x y := τ x y ≤ 0`,
   which is a preorder when `τ x x ≤ 0`.
3. **Functoriality**: tropical nonexpansive maps preserve the causal order.
4. **Concrete instantiation**: the tropical (sup) norm triangle inequality
   on `Fin n → ℝ` yields a concrete causal preorder on finite-dimensional
   tropical vector spaces.
5. **Matrix/path causality**: for min-plus weighted directed graphs,
   path-cost reachability is transitive by concatenation.

## Main definitions

- `TropicalCausal` — budgeted causal reachability
- `TropicalFuture` — zero-budget future relation
- `TropicalNonexpansive` — maps that do not increase tropical distance
- `tropicalFuturePreorder` — the induced `Preorder` instance
- `PathCost` — cost of a path in a weighted digraph
- `MatrixCausal` — path-based causal reachability in a matrix

## Main results

- `tropical_causal_transitive_budget` — budget composition under transitivity
- `tropical_future_transitive` — zero-budget transitivity
- `tropical_future_monotone_of_nonexpansive` — functoriality of causality
- `tropicalNorm_causal_transitive` — concrete instantiation via sup-norm
- `matrix_causal_transitive` — path concatenation transitivity

## References

Builds on:
- `tropical_triangle_inequality` from `Bridges/TropicalUltrametricDuality`
- `tropicalNorm_triangle` from `Tropical/RieszRepresentation/Applications`
- `tropMatMul` and `WeightedDigraph` from `Tropical/MinPlusAlgebra`
-/

open Finset

/-! ## §1. Abstract Budgeted Tropical Causality -/

/-- A point `x` can causally precede `y` under tropical displacement `τ`
with time budget `T` if the tropical displacement `τ x y ≤ T`. -/
def TropicalCausal {α : Type*} (τ : α → α → ℝ) (T : ℝ) (x y : α) : Prop :=
  τ x y ≤ T

/-- The zero-budget future relation: `y` lies in the tropical future of `x`
if the displacement `τ x y ≤ 0`. -/
def TropicalFuture {α : Type*} (τ : α → α → ℝ) (x y : α) : Prop :=
  τ x y ≤ 0

/-- **Budgeted causal transitivity**: if `x` causally precedes `y` with budget `T₁`,
and `y` causally precedes `z` with budget `T₂`, then `x` causally precedes `z`
with combined budget `T₁ + T₂`. This follows directly from the triangle inequality. -/
theorem tropical_causal_transitive_budget
    {α : Type*} {τ : α → α → ℝ}
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    {x y z : α} {T₁ T₂ : ℝ}
    (hxy : TropicalCausal τ T₁ x y)
    (hyz : TropicalCausal τ T₂ y z) :
    TropicalCausal τ (T₁ + T₂) x z := by
  unfold TropicalCausal at *
  calc τ x z ≤ τ x y + τ y z := htri x y z
    _ ≤ T₁ + T₂ := add_le_add hxy hyz

/-- **Zero-budget future transitivity**: the `TropicalFuture` relation is transitive
whenever `τ` satisfies the triangle inequality. This is the core theorem that turns
tropical distance data into causal structure. -/
theorem tropical_future_transitive
    {α : Type*} {τ : α → α → ℝ}
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    {x y z : α}
    (hxy : TropicalFuture τ x y)
    (hyz : TropicalFuture τ y z) :
    TropicalFuture τ x z := by
  unfold TropicalFuture at *
  calc τ x z ≤ τ x y + τ y z := htri x y z
    _ ≤ 0 + 0 := add_le_add hxy hyz
    _ = 0 := by ring

/-- **Causal reflexivity**: if `τ x x ≤ 0` for all `x`, then every point
lies in its own future. -/
theorem tropical_future_refl
    {α : Type*} {τ : α → α → ℝ}
    (hrefl : ∀ x, τ x x ≤ 0)
    (x : α) :
    TropicalFuture τ x x :=
  hrefl x

/-- **Budgeted causal reflexivity**: every point causally precedes itself with
any nonneg budget, provided `τ x x ≤ 0`. -/
theorem tropical_causal_refl
    {α : Type*} {τ : α → α → ℝ}
    (hrefl : ∀ x, τ x x ≤ 0)
    (x : α) {T : ℝ} (hT : 0 ≤ T) :
    TropicalCausal τ T x x := by
  unfold TropicalCausal
  exact le_trans (hrefl x) hT

/-! ## §2. Preorder Packaging -/

/-- The **tropical future preorder**: given a displacement functional `τ` satisfying
the triangle inequality and reflexivity (`τ x x ≤ 0`), the zero-budget future
relation forms a preorder. This packages tropical causality into reusable
order-theoretic infrastructure. -/
noncomputable def tropicalFuturePreorder
    {α : Type*} (τ : α → α → ℝ)
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    (hrefl : ∀ x, τ x x ≤ 0) : Preorder α where
  le x y := TropicalFuture τ x y
  le_refl x := tropical_future_refl hrefl x
  le_trans _ _ _ hxy hyz := tropical_future_transitive htri hxy hyz

/-! ## §3. Nonexpansive Maps and Functoriality -/

/-- A map `f : α → β` is **tropical nonexpansive** from `(α, τ₁)` to `(β, τ₂)` if
it does not increase displacement: `τ₂ (f x) (f y) ≤ τ₁ x y` for all `x, y`. -/
def TropicalNonexpansive {α β : Type*} (τ₁ : α → α → ℝ) (τ₂ : β → β → ℝ) (f : α → β) : Prop :=
  ∀ x y, τ₂ (f x) (f y) ≤ τ₁ x y

/-- **Monotonicity of causality under nonexpansive maps**: if `f` is tropical nonexpansive
and `x` lies in the tropical future of `y` in the source space, then `f x` lies in the
tropical future of `f y` in the target space. This makes `TropicalFuture` functorial. -/
theorem tropical_future_monotone_of_nonexpansive
    {α β : Type*} {τ₁ : α → α → ℝ} {τ₂ : β → β → ℝ} {f : α → β}
    (hnonexp : TropicalNonexpansive τ₁ τ₂ f)
    {x y : α}
    (hxy : TropicalFuture τ₁ x y) :
    TropicalFuture τ₂ (f x) (f y) := by
  unfold TropicalFuture at *
  exact le_trans (hnonexp x y) hxy

/-- **Budgeted causality is preserved by nonexpansive maps**: if `x` causally precedes `y`
with budget `T` in the source, then `f x` causally precedes `f y` with the same budget
in the target. -/
theorem tropical_causal_monotone_of_nonexpansive
    {α β : Type*} {τ₁ : α → α → ℝ} {τ₂ : β → β → ℝ} {f : α → β}
    (hnonexp : TropicalNonexpansive τ₁ τ₂ f)
    {x y : α} {T : ℝ}
    (hxy : TropicalCausal τ₁ T x y) :
    TropicalCausal τ₂ T (f x) (f y) := by
  unfold TropicalCausal at *
  exact le_trans (hnonexp x y) hxy

/-- **Composition of nonexpansive maps is nonexpansive**: the composition of two
tropical nonexpansive maps is again tropical nonexpansive. -/
theorem tropicalNonexpansive_comp
    {α β γ : Type*} {τ₁ : α → α → ℝ} {τ₂ : β → β → ℝ} {τ₃ : γ → γ → ℝ}
    {f : α → β} {g : β → γ}
    (hf : TropicalNonexpansive τ₁ τ₂ f)
    (hg : TropicalNonexpansive τ₂ τ₃ g) :
    TropicalNonexpansive τ₁ τ₃ (g ∘ f) := by
  intro x y
  exact le_trans (hg (f x) (f y)) (hf x y)

/-- **Identity is nonexpansive**: the identity map is tropical nonexpansive. -/
theorem tropicalNonexpansive_id
    {α : Type*} (τ : α → α → ℝ) :
    TropicalNonexpansive τ τ id := by
  intro x y
  simp

/-! ## §4. Budgeted Chain Composition -/

/-
**Chain composition**: a causal chain `x₀ → x₁ → ⋯ → xₙ` with individual
budgets `T₀, T₁, …, Tₙ₋₁` yields a global causal link from `x₀` to `xₙ`
with budget equal to the sum of all budgets.
-/
theorem tropical_causal_chain
    {α : Type*} {τ : α → α → ℝ}
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    (hrefl : ∀ x, τ x x ≤ 0)
    {n : ℕ} (xs : Fin (n + 1) → α) (Ts : Fin n → ℝ)
    (hchain : ∀ i : Fin n, TropicalCausal τ (Ts i) (xs i.castSucc) (xs i.succ)) :
    TropicalCausal τ (∑ i : Fin n, Ts i) (xs 0) (xs (Fin.last n)) := by
  induction' n with n ih;
  · exact hrefl _;
  · convert le_trans ( htri _ _ _ ) ( add_le_add ( ih ( fun i => xs i.castSucc ) ( fun i => Ts i.castSucc ) fun i => hchain i.castSucc ) ( hchain ( Fin.last n ) ) ) using 1 ; simp +decide [ Fin.sum_univ_castSucc ];
    rfl

/-
**Future chain**: a chain of `TropicalFuture` links composes into a single
`TropicalFuture` link. Simplified version of `tropical_causal_chain` for zero budgets.
-/
theorem tropical_future_chain
    {α : Type*} {τ : α → α → ℝ}
    (htri : ∀ x y z, τ x z ≤ τ x y + τ y z)
    (hrefl : ∀ x, τ x x ≤ 0)
    {n : ℕ} (xs : Fin (n + 1) → α)
    (hchain : ∀ i : Fin n, TropicalFuture τ (xs i.castSucc) (xs i.succ)) :
    TropicalFuture τ (xs 0) (xs (Fin.last n)) := by
  have h := tropical_causal_chain htri hrefl xs (fun _ => 0) (fun i => hchain i)
  simp at h
  exact h

/-! ## §5. Concrete Instantiation: Sup-Norm Tropical Displacement -/

/-- The **sup-norm tropical displacement** on `Fin n → ℝ`: the maximum absolute
difference of coordinates. This is a standard metric and satisfies the triangle
inequality. -/
noncomputable def tropicalSupDisplacement {n : ℕ} [NeZero n] (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (Finset.univ_nonempty) (fun i => |x i - y i|)

/-
The sup-norm displacement satisfies the triangle inequality.
-/
theorem tropicalSupDisplacement_triangle {n : ℕ} [NeZero n]
    (x y z : Fin n → ℝ) :
    tropicalSupDisplacement x z ≤ tropicalSupDisplacement x y + tropicalSupDisplacement y z := by
  unfold tropicalSupDisplacement;
  simp +zetaDelta at *;
  exact fun i => le_trans ( abs_sub_le _ _ _ ) ( add_le_add ( Finset.le_sup' ( fun i => |x i - y i| ) ( Finset.mem_univ i ) ) ( Finset.le_sup' ( fun i => |y i - z i| ) ( Finset.mem_univ i ) ) )

/-
The sup-norm displacement is reflexive (zero on the diagonal).
-/
theorem tropicalSupDisplacement_refl {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    tropicalSupDisplacement x x ≤ 0 := by
  exact Finset.sup'_le _ _ fun i _ => by simp +decide ;

/-- **Concrete tropical future preorder** on `Fin n → ℝ` using the sup-norm
displacement. Points `y` are in the future of `x` when `‖y - x‖_∞ ≤ 0`,
i.e., when `x = y`. This is a degenerate but mathematically correct preorder. -/
noncomputable def tropicalSupPreorder {n : ℕ} [NeZero n] : Preorder (Fin n → ℝ) :=
  tropicalFuturePreorder
    tropicalSupDisplacement
    tropicalSupDisplacement_triangle
    tropicalSupDisplacement_refl

/-- Concrete transitivity theorem using the sup-norm displacement. -/
theorem tropicalNorm_causal_transitive {n : ℕ} [NeZero n]
    {x y z : Fin n → ℝ} {T₁ T₂ : ℝ}
    (hxy : TropicalCausal tropicalSupDisplacement T₁ x y)
    (hyz : TropicalCausal tropicalSupDisplacement T₂ y z) :
    TropicalCausal tropicalSupDisplacement (T₁ + T₂) x z :=
  tropical_causal_transitive_budget tropicalSupDisplacement_triangle hxy hyz

/-! ## §6. One-Sided Tropical Causality -/

/-- **One-sided tropical displacement**: measures the maximum amount any coordinate
of `y` exceeds the corresponding coordinate of `x`. When this is ≤ 0, we have
`y ≤ x` coordinatewise, giving a nontrivial partial order. -/
noncomputable def tropicalOneSidedDisplacement {n : ℕ} [NeZero n] (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => y i - x i)

/-
The one-sided displacement satisfies the triangle inequality.
-/
theorem tropicalOneSidedDisplacement_triangle {n : ℕ} [NeZero n]
    (x y z : Fin n → ℝ) :
    tropicalOneSidedDisplacement x z ≤
      tropicalOneSidedDisplacement x y + tropicalOneSidedDisplacement y z := by
  unfold tropicalOneSidedDisplacement;
  simp +zetaDelta at *;
  exact fun i => by linarith [ Finset.le_sup' ( fun i => y i - x i ) ( Finset.mem_univ i ), Finset.le_sup' ( fun i => z i - y i ) ( Finset.mem_univ i ) ] ;

/-
The one-sided displacement is zero on the diagonal.
-/
theorem tropicalOneSidedDisplacement_refl {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    tropicalOneSidedDisplacement x x ≤ 0 := by
  exact Finset.sup'_le _ _ fun i _ => by simp +decide ;

/-- **One-sided tropical future preorder**: `y` is in the future of `x` when
`max_i (y_i - x_i) ≤ 0`, equivalently when `y ≤ x` coordinatewise.
This is a nontrivial partial order capturing the idea that the future lies
"below" in the tropical (min-plus) sense. -/
noncomputable def tropicalOneSidedPreorder {n : ℕ} [NeZero n] : Preorder (Fin n → ℝ) :=
  tropicalFuturePreorder
    tropicalOneSidedDisplacement
    tropicalOneSidedDisplacement_triangle
    tropicalOneSidedDisplacement_refl

/-
**Characterization**: `TropicalFuture` for the one-sided displacement is equivalent
to coordinatewise `≤`. This connects tropical causality to the natural product order.
-/
theorem tropicalOneSided_future_iff {n : ℕ} [NeZero n] (x y : Fin n → ℝ) :
    TropicalFuture tropicalOneSidedDisplacement x y ↔ ∀ i, y i ≤ x i := by
  unfold TropicalFuture tropicalOneSidedDisplacement;
  aesop

/-! ## §7. Matrix / Path Causality -/

/-- The cost of traversing a path in a weighted directed graph, defined as the
sum of edge weights along the path. An empty or singleton path has cost 0. -/
noncomputable def PathCost {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : List (Fin n) → ℝ
  | [] => 0
  | [_] => 0
  | i :: j :: rest => A i j + PathCost A (j :: rest)

/-- A path is **valid** if it is nonempty and its first and last elements match
the given source and target. -/
def ValidPath {n : ℕ} (p : List (Fin n)) (i j : Fin n) : Prop :=
  p ≠ [] ∧ p.head? = some i ∧ p.getLast? = some j

/-- **Matrix causal reachability**: vertex `i` can causally reach vertex `j` with
budget `T` if there exists a valid path from `i` to `j` with total cost ≤ `T`. -/
def MatrixCausal {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) (i j : Fin n) : Prop :=
  ∃ p : List (Fin n), ValidPath p i j ∧ PathCost A p ≤ T

/-
Concatenation of valid paths: if `p` is a valid path from `i` to `j` and
`q` is a valid path from `j` to `k`, then `p ++ q.tail` is a valid path from
`i` to `k`.
-/
theorem validPath_concat {n : ℕ} {p q : List (Fin n)} {i j k : Fin n}
    (hp : ValidPath p i j) (hq : ValidPath q j k) :
    ValidPath (p ++ q.tail) i k := by
  rcases p with ( _ | ⟨ x, p ⟩ ) <;> rcases q with ( _ | ⟨ y, q ⟩ ) <;> simp_all +decide [ ValidPath ];
  grind

/-
Cost of concatenated paths is bounded by the sum of individual path costs
plus the connecting edge weight.
-/
theorem pathCost_concat_le {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    {p q : List (Fin n)} {j : Fin n}
    (hp : p.getLast? = some j) (hq : q.head? = some j) :
    PathCost A (p ++ q.tail) ≤ PathCost A p + PathCost A q := by
  rcases p with ( _ | ⟨ x, _ | ⟨ y, p ⟩ ⟩ ) <;> rcases q with ( _ | ⟨ z, _ | ⟨ w, q ⟩ ⟩ ) <;> norm_num at *;
  all_goals simp_all +decide [ PathCost ];
  have h_cost_append : ∀ (p : List (Fin n)) (y w : Fin n) (q : List (Fin n)), PathCost A (y :: (p ++ w :: q)) = PathCost A (y :: p) + A (p.getLast?.getD y) w + PathCost A (w :: q) := by
    intros p y w q; induction' p with p ih generalizing y w q <;> simp_all +decide [ PathCost ] ;
    grind;
  grind

/-
**Matrix causal transitivity**: if `i` can causally reach `j` with budget `T₁`
and `j` can causally reach `k` with budget `T₂`, then `i` can causally reach `k`
with budget `T₁ + T₂`. This is the path-concatenation analogue of budgeted
causal transitivity.
-/
theorem matrix_causal_transitive
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) {T₁ T₂ : ℝ} {i j k : Fin n}
    (hij : MatrixCausal A T₁ i j)
    (hjk : MatrixCausal A T₂ j k) :
    MatrixCausal A (T₁ + T₂) i k := by
  obtain ⟨ p, hp₁, hp₂ ⟩ := hij
  obtain ⟨ q, hq₁, hq₂ ⟩ := hjk;
  refine' ⟨ p ++ q.tail, validPath_concat hp₁ hq₁, _ ⟩;
  exact le_trans ( pathCost_concat_le A hp₁.2.2 hq₁.2.1 ) ( add_le_add hp₂ hq₂ )

/-! ## §8. Bridge: Nonexpansive Maps Compose Causal Morphisms -/

/-- **Causal morphism composition theorem**: composing two causal morphisms
(nonexpansive maps) yields another causal morphism, and the induced preorders
are compatible. This is the categorical backbone of tropical causal semantics. -/
theorem causal_morphism_comp
    {α β γ : Type*}
    {τ₁ : α → α → ℝ} {τ₂ : β → β → ℝ} {τ₃ : γ → γ → ℝ}
    {f : α → β} {g : β → γ}
    (hf : TropicalNonexpansive τ₁ τ₂ f)
    (hg : TropicalNonexpansive τ₂ τ₃ g)
    {x y : α} (hxy : TropicalFuture τ₁ x y) :
    TropicalFuture τ₃ (g (f x)) (g (f y)) :=
  tropical_future_monotone_of_nonexpansive (tropicalNonexpansive_comp hf hg) hxy

/-! ## §9. Bridge: Norm-Induced Causality from Decomposition -/

/-
A tropical norm `ν` induces a displacement functional `τ x y = ν (y - x)`.
If `ν` satisfies the triangle inequality `ν (u + v) ≤ ν u + ν v` and
`ν 0 ≤ 0`, then the induced `τ` satisfies the tropical triangle inequality
and reflexivity.
-/
theorem norm_induced_triangle
    {V : Type*} [AddCommGroup V]
    (ν : V → ℝ)
    (htri_ν : ∀ u v : V, ν (u + v) ≤ ν u + ν v)
    (x y z : V) :
    ν (z - x) ≤ ν (y - x) + ν (z - y) := by
  convert htri_ν ( y - x ) ( z - y ) using 1 ; abel_nf

/-- The displacement from `x` to `x` is zero under a norm with `ν 0 ≤ 0`. -/
theorem norm_induced_refl
    {V : Type*} [AddCommGroup V]
    (ν : V → ℝ)
    (hzero : ν 0 ≤ 0)
    (x : V) :
    ν (x - x) ≤ 0 := by
  simp [hzero]

/-- **Norm-induced causal preorder**: any tropical seminorm on an additive group
induces a preorder via `x ≤ y ↔ ν(y - x) ≤ 0`. -/
noncomputable def normInducedPreorder
    {V : Type*} [AddCommGroup V]
    (ν : V → ℝ)
    (htri_ν : ∀ u v : V, ν (u + v) ≤ ν u + ν v)
    (hzero : ν 0 ≤ 0) : Preorder V :=
  tropicalFuturePreorder
    (fun x y => ν (y - x))
    (norm_induced_triangle ν htri_ν)
    (fun x => norm_induced_refl ν hzero x)

/-! ## §10. Security Propagation Along Causal Chains -/

/-
**Security propagation**: if `f` is tropical nonexpansive and `x` causally
precedes `y` with budget `T`, then any norm-bound security certificate at `y`
pulls back to a weakened certificate at `x`. Concretely: if `‖f y‖ ≥ λ` and
`f` is nonexpansive with respect to `τ₁, τ₂`, then the budget-adjusted bound
`‖f x‖ ≥ λ - T` holds (under the displacement metric).
-/
theorem security_propagation
    {α : Type*} {τ : α → α → ℝ}
    {f : α → ℝ}
    (hnonexp : ∀ x y, |f x - f y| ≤ τ x y)
    {x y : α} {T secLevel : ℝ}
    (hbudget : TropicalCausal τ T x y)
    (hsec : secLevel ≤ f y) :
    secLevel - T ≤ f x := by
  -- From hnonexp x y we get |f x - f y| ≤ τ x y. From hbudget we get τ x y ≤ T. So |f x - f y| ≤ T. This gives f y - f x ≤ T (since a ≤ |a|). Thus f x ≥ f y - T ≥ secLevel - T.
  have h_abs : |f x - f y| ≤ τ x y := by
    exact hnonexp x y
  have h_le : f y - f x ≤ T := by
    exact le_trans ( by linarith [ abs_le.mp h_abs ] ) hbudget
  linarith [hsec]