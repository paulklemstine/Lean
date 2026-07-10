import Mathlib

/-!
# Exponential size of Vietoris–Rips complexes and the doubling dimension

This file develops, from first principles, the combinatorial core behind the
statement

> *"Bounded doubling dimension is a geometric necessity for linear-size sparse
>   approximations of the Vietoris–Rips filtration."*

We formalize the Vietoris–Rips filtration of a finite metric space as a monotone
family of simplicial complexes, prove its basic structural properties
(monotonicity, downward closure, multiplicative interleaving), and then analyze
the **equilateral hard instance** `X_n`: `n` points that are pairwise at distance
`1`.  For this family we prove two facts that pull in opposite directions:

* the Vietoris–Rips complex is **exponentially large**: at every scale
  `r ∈ [1, √2)` (indeed every `r ≥ 1`) it is the full simplex on `n` vertices and
  therefore has exactly `2 ^ n` faces (`card_ripsComplex_equiDist`);
* the space nevertheless has **small (logarithmic) doubling dimension**: at the
  critical scale the covering number is exactly `n`, so the doubling dimension is
  exactly `log₂ n` (`covering_number_equiDist`, `doublingDim_equiDist`).

Combining the two, any simplicial complex that contains `Rips(X_n, 1)` — in
particular any *exact* finitely presented representative of the filtration — must
have at least `2 ^ n` faces, while the ambient geometry is only `log₂ n`-doubling
(`representation_size_lower_bound`).  This is the exact-scale (`c = 1`) instance
of the exponential lower bound; the general `c ∈ [1, √2)` statement, which
requires persistent homology and homotopy interleavings, is discussed in
`FUTURE_DIRECTIONS.md`.

## Main definitions

* `IsMetric d`         — `d : α → α → ℝ` is a metric.
* `ripsComplex d r`    — the Vietoris–Rips complex at scale `r` (faces of diameter `≤ r`).
* `equiDist n`         — the equilateral metric on `Fin n` (distinct points at distance `1`).
* `closedBall d x r`   — the closed ball, as a `Finset`.

## Main results

* `ripsComplex_mono`, `ripsComplex_downClosed`, `ripsComplex_interleave` — the
  Rips filtration is a monotone, downward-closed, multiplicatively-interleaved
  family of complexes.
* `equiDist_isMetric` — the equilateral distance really is a metric.
* `card_ripsComplex_equiDist` — `|Rips(X_n, r)| = 2 ^ n` for `r ≥ 1`.
* `representation_size_lower_bound` — any complex containing `Rips(X_n, 1)` has
  `≥ 2 ^ n` faces.
* `card_lt_two_pow` — the exponential bound is genuinely super-linear.
* `doubling_number_le_card` — *every* `n`-point space is `n`-doubling.
* `covering_number_equiDist` — at the critical scale the equilateral space needs
  exactly `n` half-radius balls, so its doubling dimension is `log₂ n`.
-/

noncomputable section

open Finset
open scoped Classical

namespace RipsDoubling

variable {α : Type*}

/-! ## §1. Metrics on a finite type -/

/-- A bundled predicate: `d` is a metric (identity of indiscernibles via `pos`). -/
structure IsMetric (d : α → α → ℝ) : Prop where
  refl : ∀ x, d x x = 0
  pos : ∀ x y, x ≠ y → 0 < d x y
  symm : ∀ x y, d x y = d y x
  triangle : ∀ x y z, d x z ≤ d x y + d y z

/-- Distances in a metric are non-negative. -/
theorem IsMetric.nonneg {d : α → α → ℝ} (h : IsMetric d) (x y : α) : 0 ≤ d x y := by
  nlinarith [h.triangle x y x, h.refl x, h.symm y x]

/-! ## §2. The Vietoris–Rips complex -/

/-- The **Vietoris–Rips complex** at scale `r`: all faces of diameter `≤ r`. -/
def ripsComplex [Fintype α] (d : α → α → ℝ) (r : ℝ) : Finset (Finset α) :=
  Finset.univ.filter (fun σ => ∀ x ∈ σ, ∀ y ∈ σ, d x y ≤ r)

@[simp] theorem mem_ripsComplex [Fintype α] (d : α → α → ℝ) (r : ℝ) (σ : Finset α) :
    σ ∈ ripsComplex d r ↔ ∀ x ∈ σ, ∀ y ∈ σ, d x y ≤ r := by
  simp only [ripsComplex, Finset.mem_filter, Finset.mem_univ, true_and]

/-- The empty face is always present. -/
theorem empty_mem_ripsComplex [Fintype α] (d : α → α → ℝ) (r : ℝ) :
    (∅ : Finset α) ∈ ripsComplex d r := by
  simp [mem_ripsComplex]

/-- **Monotonicity of the filtration**: enlarging the scale enlarges the complex. -/
theorem ripsComplex_mono [Fintype α] (d : α → α → ℝ) {r s : ℝ} (h : r ≤ s) :
    ripsComplex d r ⊆ ripsComplex d s := by
  intro σ hσ
  rw [mem_ripsComplex] at hσ ⊢
  intro x hx y hy
  exact le_trans (hσ x hx y hy) h

/-- **Downward closure**: the Rips complex is an abstract simplicial complex. -/
theorem ripsComplex_downClosed [Fintype α] (d : α → α → ℝ) (r : ℝ) {σ τ : Finset α}
    (hτσ : τ ⊆ σ) (hσ : σ ∈ ripsComplex d r) : τ ∈ ripsComplex d r := by
  rw [mem_ripsComplex] at hσ ⊢
  intro x hx y hy
  exact hσ x (hτσ hx) y (hτσ hy)

/-- **Multiplicative interleaving (one inclusion)**: for `c ≥ 1` and `r ≥ 0`, the
complex at scale `r` sits inside the complex at scale `c · r`.  This is the
containment that a `c`-approximation must respect. -/
theorem ripsComplex_interleave [Fintype α] (d : α → α → ℝ) {c r : ℝ}
    (hc : 1 ≤ c) (hr : 0 ≤ r) : ripsComplex d r ⊆ ripsComplex d (c * r) := by
  have : r ≤ c * r := by nlinarith
  exact ripsComplex_mono d this

/-! ## §3. The equilateral hard instance `X_n` -/

/-- The **equilateral metric** on `Fin n`: distinct points are at distance `1`. -/
def equiDist (n : ℕ) : Fin n → Fin n → ℝ := fun i j => if i = j then 0 else 1

@[simp] theorem equiDist_self (n : ℕ) (i : Fin n) : equiDist n i i = 0 := by
  simp [equiDist]

theorem equiDist_of_ne (n : ℕ) {i j : Fin n} (h : i ≠ j) : equiDist n i j = 1 := by
  simp [equiDist, h]

theorem equiDist_le_one (n : ℕ) (i j : Fin n) : equiDist n i j ≤ 1 := by
  unfold equiDist; split <;> norm_num

theorem equiDist_nonneg (n : ℕ) (i j : Fin n) : 0 ≤ equiDist n i j := by
  unfold equiDist; split <;> norm_num

/-
The equilateral distance is a genuine metric.
-/
theorem equiDist_isMetric (n : ℕ) : IsMetric (equiDist n) := by
  constructor <;> norm_num [ equiDist ];
  · aesop;
  · grind;
  · grind

/-! ## §4. Exponential size of the Rips complex -/

/-
At every scale `r ≥ 1` the equilateral Rips complex is the **full simplex**.
-/
theorem ripsComplex_equiDist_eq_univ (n : ℕ) {r : ℝ} (hr : 1 ≤ r) :
    ripsComplex (equiDist n) r = (Finset.univ : Finset (Finset (Fin n))) := by
  refine' Finset.eq_univ_of_forall _;
  intro σ; rw [ mem_ripsComplex ] ; intro x hx y hy; exact le_trans ( equiDist_le_one n x y ) hr;

/-
**Exponential size**: the equilateral Rips complex has exactly `2 ^ n` faces
for every scale `r ≥ 1` (in particular for all `r ∈ [1, √2)`).
-/
theorem card_ripsComplex_equiDist (n : ℕ) {r : ℝ} (hr : 1 ≤ r) :
    (ripsComplex (equiDist n) r).card = 2 ^ n := by
  rw [ ripsComplex_equiDist_eq_univ ];
  · simp +decide [ Finset.card_univ ];
  · linarith

/-- The exponential bound is genuinely super-linear: `n < 2 ^ n`. -/
theorem card_lt_two_pow (n : ℕ) : n < 2 ^ n := by
  exact Nat.lt_two_pow_self

/-
**Exact-scale size lower bound.**  Any abstract simplicial complex `K` that
contains the Rips complex at the critical scale must have at least `2 ^ n` faces.
Applied to a finitely presented representative of the filtration, this is the
`c = 1` instance of the exponential lower bound.
-/
theorem representation_size_lower_bound (n : ℕ) (K : Finset (Finset (Fin n)))
    (hK : ripsComplex (equiDist n) 1 ⊆ K) : 2 ^ n ≤ K.card := by
  exact le_trans ( by rw [ card_ripsComplex_equiDist ] ; norm_num ) ( Finset.card_mono hK )

/-! ## §5. Doubling dimension -/

/-- The closed ball of radius `r` about `x`, as a `Finset`. -/
def closedBall [Fintype α] (d : α → α → ℝ) (x : α) (r : ℝ) : Finset α :=
  Finset.univ.filter (fun y => d x y ≤ r)

@[simp] theorem mem_closedBall [Fintype α] (d : α → α → ℝ) (x : α) (r : ℝ) (y : α) :
    y ∈ closedBall d x r ↔ d x y ≤ r := by
  simp only [closedBall, Finset.mem_filter, Finset.mem_univ, true_and]

/-
**Every finite metric space is trivially `card`-doubling**: any closed ball
is covered by at most `Fintype.card α` half-radius balls.
-/
theorem doubling_number_le_card [Fintype α] (d : α → α → ℝ) (hd : IsMetric d)
    (x : α) {R : ℝ} (hR : 0 ≤ R) :
    ∃ C : Finset α, C.card ≤ Fintype.card α ∧
      closedBall d x R ⊆ C.biUnion (fun c => closedBall d c (R / 2)) := by
  refine' ⟨ Finset.univ.filter fun y => d x y ≤ R, _, _ ⟩;
  · grind +splitImp;
  · simp [Finset.subset_iff];
    exact fun y hy => ⟨ y, hy, by linarith [ hd.refl y ] ⟩

/-
At the **critical scale** `R ∈ [1, 2)` every half-radius ball in the
equilateral space is a single point, so `univ` cannot be covered by fewer than
`n` of them: the covering number is exactly `n`.  Hence the doubling dimension of
`X_n` is exactly `log₂ n`, which grows unboundedly but only logarithmically.
-/
theorem covering_number_equiDist (n : ℕ) (x : Fin n) {R : ℝ} (h1 : 1 ≤ R) (h2 : R < 2)
    (C : Finset (Fin n))
    (hC : closedBall (equiDist n) x R ⊆
      C.biUnion (fun c => closedBall (equiDist n) c (R / 2))) :
    n ≤ C.card := by
  -- Since $R/2 < 1$, each half-ball is a singleton: $i \in \text{closedBall}(\text{equiDist } n, c, R/2) \to i = c$.
  have h_singleton : ∀ c ∈ C, ∀ i ∈ closedBall (equiDist n) c (R / 2), i = c := by
    simp +contextual [ closedBall, equiDist ];
    grind;
  -- Since $closedBall (equiDist n) x R = Finset.univ$, we have $Finset.univ ⊆ C.biUnion (fun c => closedBall (equiDist n) c (R / 2))$.
  have h_univ_subset : Finset.univ ⊆ C.biUnion (fun c => closedBall (equiDist n) c (R / 2)) := by
    grind +locals;
  exact le_trans ( by rw [ Finset.card_fin ] ) ( Finset.card_le_card ( show Finset.univ ⊆ C from fun i hi => by have := h_univ_subset hi; obtain ⟨ c, hc, hi ⟩ := Finset.mem_biUnion.mp this; specialize h_singleton c hc i hi; aesop ) )

/-
**The doubling dimension of `X_n` is exactly `log₂ n`.**  At the critical
scale `R ∈ [1, 2)` the smallest cover of the whole space by half-radius balls has
size exactly `n`: there is a cover of size `n`, and every cover has size at least
`n`.  Consequently the doubling dimension `log₂ (covering number)` equals
`log₂ n` — unbounded, but only logarithmic.
-/
theorem doublingDim_equiDist (n : ℕ) (x : Fin n) {R : ℝ} (h1 : 1 ≤ R) (h2 : R < 2) :
    (∃ C : Finset (Fin n), C.card = n ∧
        closedBall (equiDist n) x R ⊆
          C.biUnion (fun c => closedBall (equiDist n) c (R / 2)))
    ∧ (∀ C : Finset (Fin n),
        closedBall (equiDist n) x R ⊆
          C.biUnion (fun c => closedBall (equiDist n) c (R / 2)) → n ≤ C.card) := by
  refine' ⟨ _, fun C hC => _ ⟩;
  · refine' ⟨ Finset.univ, _, _ ⟩ <;> norm_num;
    intro y hy; simp_all +decide;
    exact ⟨ y, by rw [ equiDist ] ; norm_num; linarith ⟩;
  · convert covering_number_equiDist n x h1 h2 C hC using 1

/-! ## §6. The central tension, in one statement -/

/-
**Exponential representation size versus logarithmic doubling dimension.**
For the equilateral hard instance `X_n`, at the critical scale `R ∈ [1, 2)` the
two sides of the mission collide simultaneously:

* *(size)* any simplicial complex containing the critical-scale Rips complex has
  at least `2 ^ n` faces, and this bound is genuinely super-linear (`n < 2 ^ n`);
* *(geometry)* the space is tame — the smallest cover of `X_n` by half-radius
  balls has size exactly `n`, so its doubling dimension is only `log₂ n`.

Thus exponential representation size is forced even though the doubling dimension
grows only logarithmically: bounded doubling dimension is a genuine geometric
prerequisite for small representatives.  This packages the exact-scale (`c = 1`)
instance of the exponential lower bound together with the small-doubling side.
-/
theorem rips_size_vs_doubling (n : ℕ) (x : Fin n) {R : ℝ} (h1 : 1 ≤ R) (h2 : R < 2) :
    -- exponential, super-linear size lower bound
    (∀ K : Finset (Finset (Fin n)), ripsComplex (equiDist n) 1 ⊆ K → 2 ^ n ≤ K.card)
    ∧ n < 2 ^ n
    -- but only `n` half-radius balls are ever needed to cover the whole space,
    -- and this many are in fact required: the covering number is exactly `n`
    ∧ (∃ C : Finset (Fin n), C.card = n ∧
        closedBall (equiDist n) x R ⊆
          C.biUnion (fun c => closedBall (equiDist n) c (R / 2)))
    ∧ (∀ C : Finset (Fin n),
        closedBall (equiDist n) x R ⊆
          C.biUnion (fun c => closedBall (equiDist n) c (R / 2)) → n ≤ C.card) := by
  refine ⟨fun K hK => representation_size_lower_bound n K hK, card_lt_two_pow n,
    (doublingDim_equiDist n x h1 h2).1, (doublingDim_equiDist n x h1 h2).2⟩

end RipsDoubling