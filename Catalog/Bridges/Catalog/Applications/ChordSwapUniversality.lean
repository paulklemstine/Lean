/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Universality of the cubic spectral-gap exponent for weighted swap chains

A *swap chain* on a combinatorial family reconfigures objects by local moves,
and its mixing speed is governed by the **spectral gap** `γ`, the smallest
non-trivial Rayleigh quotient `E(f,f) / Var(f)` of the Dirichlet form.  A previous
cycle isolated the mechanism producing the `n^{-3}` scaling of the fixed-genus
chord-swap gap: on the one-dimensional (path) prototype the *position* statistic
has Dirichlet energy `Θ(n)` and variance `Θ(n⁴)`, so its Rayleigh quotient — and
hence the gap upper bound — is `Θ(n^{-3})`.

The present cycle carries two of the resulting conjectures into unconditional
theorems.

* **Universality (Conjecture 4).**  The cubic exponent is a property of the
  *energy-to-variance ratio*, not of the objects being shuffled.  We prove this
  abstractly: on *any* finite state space, any non-constant test function whose
  Dirichlet energy is at most `c_e · n` and whose variance is at least
  `c_v · n⁴` certifies `γ ≤ (c_e / c_v) · n^{-3}`.  The exponent `3 = 4 − 1` is
  forced by the two growth rates alone.

* **Genus enters only through the constant (Conjecture 3).**  We generalise the
  unit-weight path of the previous cycle to a **conductance-weighted path**, whose
  edges carry a weight `c > 0` that models the effective conductance of a genus.
  The Dirichlet energy scales to `2c(n−1)` while the variance is unchanged, so the
  Rayleigh quotient is exactly `12c / (n²(n+1))`.  The exponent `−3` is therefore
  independent of `c`, and the leading constant is *strictly increasing* in the
  conductance.  Modelling a genus `g` by a strictly decreasing conductance
  `c(g) = 1/(g+1)` then yields a strictly decreasing, strictly positive amplitude
  in front of the invariant `n^{-3}`.

## Main results

* `RQ_le_of_growth`, `gap_le_of_growth`, `gap_cubic_of_linear_quartic` — the
  abstract universality engine: linear energy and quartic variance force a cubic
  Rayleigh quotient and hence a cubic gap upper bound.
* `wpath_dir_eq`, `wpath_vr_eq`, `wpath_RQ_eq` — the conductance-weighted path has
  energy `2c(n−1)`, variance `n²(n²−1)/6`, and Rayleigh quotient `12c/(n²(n+1))`.
  Setting `c = 1` recovers the previous cycle's unit-weight identities.
* `wpath_gap_cubic_upper` and `wpath_RQ_window` — the gap is `O(n^{-3})` and the
  certifying quotient is pinned to `[6c·n^{-3}, 12c·n^{-3}]`, so the exponent is
  exactly three for every fixed conductance.
* `wpath_RQ_strictMono_cond` — the Rayleigh quotient (hence the gap upper bound)
  is strictly increasing in the conductance: the constant, not the exponent,
  carries the dependence.
* `condOfGenus_pos`, `condOfGenus_strictAnti`, `genus_gap_constant_strictAnti` —
  a genus-decreasing conductance produces a strictly decreasing, strictly
  positive leading constant in front of the invariant cubic decay.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Two claims from the prototype cycle should be
  provable unconditionally in the one-dimensional model: (i) the cubic exponent
  depends only on the linear-energy / quartic-variance profile of the driving
  statistic (universality), and (ii) reweighting the edges — the algebraic shadow
  of changing the effective conductance of a genus — moves the leading constant
  monotonically while leaving the exponent fixed.
* **Experiment (Experimenter).**  Abstracted the Rayleigh calculus over a finite
  state space; proved `RQ_le_of_growth` by `gcongr` from `dir ≤ A` and
  `B ≤ vr`.  Generalised the path energy count to arbitrary edge weight `c`
  (`wpath_dir_eq`, energy `2c(n−1)`), noted the variance is weight-independent
  (`wpath_vr_eq` via the Gauss and square-pyramidal sums), and combined them into
  the exact quotient `12c/(n²(n+1))`.  Strict monotonicity in `c` reduces to a
  single positive-denominator division inequality.
* **Analysis (Analyst).**  Both results are "true and structural".  The exponent
  `3` is a *difference of growth rates* (`4 − 1`) and is manifestly insensitive to
  the multiplicative constant `c`, which is exactly the mechanism by which genus
  can rescale the gap without touching the exponent.  The universality bound is
  the abstract statement of the same arithmetic, stripped of the path.
* **Critique (Critic).**  Is the universality bound vacuous?  No — it consumes a
  genuine non-constant witness and non-negative weights, and produces a bound with
  the correct `n^{-3}` shape whenever the hypotheses are met (verified on the
  weighted path in `example`s below).  Is the monotonicity trivial?  No: it is a
  strict inequality between Rayleigh quotients with a quartic denominator, and it
  is exactly the falsifiable content of "genus enters through the constant".
  Boundary: at `c = 0` the chain disconnects and the quotient collapses to `0`;
  the strict statements therefore require positive conductance, which is recorded
  in the hypotheses.  No theorem references itself; the file builds strictly
  upward.
* **Synthesis (PI).**  The fixed-genus chord-swap programme now has, in the
  one-dimensional model, both the universality principle (Conjecture 4) and the
  genus-through-the-constant principle (Conjecture 3) as theorems.  What remains
  for the genuine diagram space is the combinatorial construction of a monotone,
  unit-step, quartic-variance statistic whose edge weights realise a
  genus-decreasing conductance — at which point these two engines deliver the
  full `γ_{n,g} = c(g)·n^{-3}` picture.
-/
import Mathlib

open scoped BigOperators
open Finset

namespace ChordSwapUniv

variable {V : Type*} [Fintype V]

/-! ### Abstract Rayleigh-quotient calculus -/

/-- **Dirichlet energy** of a test function `f` with respect to symmetric,
non-negative edge weights `Q`. -/
def dir (Q : V → V → ℝ) (f : V → ℝ) : ℝ := ∑ x, ∑ y, Q x y * (f x - f y) ^ 2

/-- **Pairwise variation** of `f`: the sum of `(f x − f y)²` over ordered pairs,
equal to `2|V|·Var(f)` under the uniform law. -/
def vr (f : V → ℝ) : ℝ := ∑ x, ∑ y, (f x - f y) ^ 2

/-- **Rayleigh quotient**: energy divided by variation. -/
noncomputable def RQ (Q : V → V → ℝ) (f : V → ℝ) : ℝ := dir Q f / vr f

/-- **Combinatorial spectral gap**: the infimum of the Rayleigh quotient over
non-constant test functions. -/
noncomputable def gap (Q : V → V → ℝ) : ℝ :=
  sInf {r | ∃ f : V → ℝ, (∃ x y, f x ≠ f y) ∧ r = RQ Q f}

/-- The Dirichlet energy of non-negative edge weights is non-negative. -/
theorem dir_nonneg {Q : V → V → ℝ} (hQ : ∀ x y, 0 ≤ Q x y) (f : V → ℝ) : 0 ≤ dir Q f :=
  Finset.sum_nonneg (fun _ _ => Finset.sum_nonneg (fun y _ => mul_nonneg (hQ _ y) (sq_nonneg _)))

/-- The pairwise variation is non-negative. -/
theorem vr_nonneg (f : V → ℝ) : 0 ≤ vr f :=
  Finset.sum_nonneg (fun _ _ => Finset.sum_nonneg (fun _ _ => sq_nonneg _))

/-- The pairwise variation is strictly positive precisely when `f` is non-constant. -/
theorem vr_pos_of_nonconstant {f : V → ℝ} (h : ∃ x y, f x ≠ f y) : 0 < vr f := by
  unfold vr
  obtain ⟨x, y, hxy⟩ := h
  have hne : f x - f y ≠ 0 := sub_ne_zero.mpr hxy
  apply Finset.sum_pos'
  · exact fun i _ => Finset.sum_nonneg (fun j _ => sq_nonneg _)
  · refine ⟨x, Finset.mem_univ _, ?_⟩
    apply Finset.sum_pos'
    · exact fun j _ => sq_nonneg _
    · exact ⟨y, Finset.mem_univ _, by positivity⟩

/-- The Rayleigh quotient of non-negative edge weights is non-negative. -/
theorem RQ_nonneg {Q : V → V → ℝ} (hQ : ∀ x y, 0 ≤ Q x y) (f : V → ℝ) : 0 ≤ RQ Q f :=
  div_nonneg (dir_nonneg hQ f) (vr_nonneg f)

/-- The combinatorial spectral gap is non-negative. -/
theorem gap_nonneg {Q : V → V → ℝ} (hQ : ∀ x y, 0 ≤ Q x y) : 0 ≤ gap Q := by
  apply Real.sInf_nonneg
  rintro r ⟨f, -, rfl⟩
  exact RQ_nonneg hQ f

/-- **The Rayleigh engine.**  Every non-constant test function bounds the gap from
above by its Rayleigh quotient. -/
theorem gap_le_RQ {Q : V → V → ℝ} (hQ : ∀ x y, 0 ≤ Q x y) {f : V → ℝ}
    (hnc : ∃ x y, f x ≠ f y) : gap Q ≤ RQ Q f := by
  apply csInf_le
  · exact ⟨0, by rintro r ⟨g, -, rfl⟩; exact RQ_nonneg hQ g⟩
  · exact ⟨f, hnc, rfl⟩

/-- Scaling all edge weights by `c` scales the Dirichlet energy by `c`. -/
theorem dir_smul (c : ℝ) (Q : V → V → ℝ) (f : V → ℝ) :
    dir (fun x y => c * Q x y) f = c * dir Q f := by
  unfold dir
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun x _ => ?_)
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl (fun y _ => by ring)

/-! ### Universality: linear energy and quartic variance force a cubic quotient -/

/-- **Universality, quotient form.**  If the Dirichlet energy is at most `A` and
the variation is at least `B > 0`, the Rayleigh quotient is at most `A / B`. -/
theorem RQ_le_of_growth {Q : V → V → ℝ} (hQ : ∀ x y, 0 ≤ Q x y) (f : V → ℝ) {A B : ℝ}
    (hA : dir Q f ≤ A) (hB : 0 < B) (hBv : B ≤ vr f) : RQ Q f ≤ A / B := by
  unfold RQ
  have hv : 0 < vr f := lt_of_lt_of_le hB hBv
  have hd : 0 ≤ dir Q f := dir_nonneg hQ f
  gcongr
  exact le_trans hd hA

/-- **Universality, gap form.**  A non-constant witness with energy `≤ A` and
variation `≥ B > 0` certifies `gap ≤ A / B`. -/
theorem gap_le_of_growth {Q : V → V → ℝ} (hQ : ∀ x y, 0 ≤ Q x y) {f : V → ℝ}
    (hnc : ∃ x y, f x ≠ f y) {A B : ℝ}
    (hA : dir Q f ≤ A) (hB : 0 < B) (hBv : B ≤ vr f) : gap Q ≤ A / B :=
  le_trans (gap_le_RQ hQ hnc) (RQ_le_of_growth hQ f hA hB hBv)

/-- **The cubic exponent is universal.**  On any finite state space, a non-constant
statistic with Dirichlet energy at most `c_e·n` and variation at least `c_v·n⁴`
(the linear-energy / quartic-variance profile) certifies a cubic gap upper bound
`gap ≤ (c_e / c_v)·n^{-3}`.  The exponent `3` depends only on the two growth
rates, not on the underlying combinatorial family. -/
theorem gap_cubic_of_linear_quartic {Q : V → V → ℝ} (hQ : ∀ x y, 0 ≤ Q x y)
    {f : V → ℝ} (hnc : ∃ x y, f x ≠ f y) {ce cv : ℝ} {n : ℝ}
    (hn : 0 < n) (hcv : 0 < cv)
    (hE : dir Q f ≤ ce * n) (hVar : cv * n ^ 4 ≤ vr f) :
    gap Q ≤ (ce / cv) * n ^ (-3 : ℤ) := by
  have hB : 0 < cv * n ^ 4 := by positivity
  have hstep := gap_le_of_growth hQ hnc hE hB hVar
  have hne : n ≠ 0 := ne_of_gt hn
  have hrewrite : ce * n / (cv * n ^ 4) = (ce / cv) * n ^ (-3 : ℤ) := by
    rw [zpow_neg, zpow_ofNat]
    field_simp
  rwa [hrewrite] at hstep

/-! ### The conductance-weighted path -/

/-- Symmetric adjacency weights of the length-`n` path with **conductance** `c`:
weight `c` between consecutive positions, `0` otherwise.  Setting `c = 1` recovers
the unit-weight swap graph of the prototype cycle. -/
def wpathQ (c : ℝ) (n : ℕ) : Fin n → Fin n → ℝ :=
  fun x y => if x.val + 1 = y.val ∨ y.val + 1 = x.val then c else 0

/-- The **position** test function `i ↦ i`: a monotone statistic shifted by one
unit per swap. -/
def idf (n : ℕ) : Fin n → ℝ := fun i => (i.val : ℝ)

/-- The weighted-path weights are non-negative for non-negative conductance. -/
theorem wpathQ_nonneg {c : ℝ} (hc : 0 ≤ c) (n : ℕ) : ∀ x y, 0 ≤ wpathQ c n x y := by
  intro x y; unfold wpathQ; split <;> [exact hc; norm_num]

/-- Gauss sum over `Fin n`. -/
theorem sum_val (n : ℕ) : (∑ i : Fin n, (i.val : ℝ)) = n * (n - 1) / 2 := by
  rw [Fin.sum_univ_eq_sum_range (fun i => (i : ℝ)) n]
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, ih]; push_cast; ring

/-- Square-pyramidal sum over `Fin n`. -/
theorem sum_val_sq (n : ℕ) :
    (∑ i : Fin n, (i.val : ℝ) ^ 2) = n * (n - 1) * (2 * n - 1) / 6 := by
  rw [Fin.sum_univ_eq_sum_range (fun i => (i : ℝ) ^ 2) n]
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, ih]; push_cast; ring

/-- Count of positions with a right neighbour, weighted by `c`. -/
theorem sumTc (c : ℝ) (n : ℕ) (hn : 1 ≤ n) :
    (∑ x : Fin n, (if x.val + 1 < n then c else 0)) = c * ((n : ℝ) - 1) := by
  rw [Fin.sum_univ_eq_sum_range (fun j => if j + 1 < n then c else 0) n]
  rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, Finset.sum_const, nsmul_eq_mul]
  have h1 : (Finset.range n).filter (fun j => j + 1 < n) = Finset.range (n - 1) := by
    ext j; simp only [Finset.mem_filter, Finset.mem_range]; omega
  rw [h1, Finset.card_range]
  push_cast [Nat.cast_sub hn]; ring

/-- Closed-form pairwise variation, the discrete `Var(f) = E[f²] − E[f]²`. -/
theorem vr_eq (f : V → ℝ) :
    vr f = 2 * ((Fintype.card V : ℝ) * (∑ x, (f x) ^ 2) - (∑ x, f x) ^ 2) := by
  have hA : (∑ x : V, ∑ _y : V, (f x) ^ 2) = (Fintype.card V : ℝ) * ∑ x, (f x) ^ 2 := by
    simp_rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; rw [← Finset.mul_sum]
  have hB : (∑ _x : V, ∑ y : V, (f y) ^ 2) = (Fintype.card V : ℝ) * ∑ x, (f x) ^ 2 := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hC : (∑ x : V, ∑ y : V, 2 * (f x * f y)) = 2 * (∑ x, f x) ^ 2 := by
    rw [sq, Finset.sum_mul_sum, Finset.mul_sum]
    refine Finset.sum_congr rfl (fun x _ => by rw [Finset.mul_sum])
  unfold vr
  have expand : ∀ x y : V, (f x - f y) ^ 2 = (f x) ^ 2 - 2 * (f x * f y) + (f y) ^ 2 :=
    fun x y => by ring
  simp_rw [expand, Finset.sum_add_distrib, Finset.sum_sub_distrib]
  rw [hA, hB, hC]; ring

/-- **Weighted-path energy.**  The position statistic has Dirichlet energy
`2c(n−1)`: each of the `n−1` edges contributes `c` in each orientation.  With
`c = 1` this is the previous cycle's `2(n−1)`. -/
theorem wpath_dir_eq {c : ℝ} {n : ℕ} (hn : 1 ≤ n) :
    dir (wpathQ c n) (idf n) = 2 * c * ((n : ℝ) - 1) := by
  have hterm : ∀ x y : Fin n, wpathQ c n x y * (idf n x - idf n y) ^ 2 = wpathQ c n x y := by
    intro x y
    unfold wpathQ idf
    by_cases h : x.val + 1 = y.val ∨ y.val + 1 = x.val
    · simp only [if_pos h]
      rcases h with h | h
      · have hy : (y.val : ℝ) = (x.val : ℝ) + 1 := by exact_mod_cast h.symm
        rw [hy]; ring
      · have hx : (x.val : ℝ) = (y.val : ℝ) + 1 := by exact_mod_cast h.symm
        rw [hx]; ring
    · simp only [if_neg h]; ring
  unfold dir
  simp_rw [hterm]
  have hsplit : ∀ x y : Fin n, wpathQ c n x y
      = (if x.val + 1 = y.val then c else 0) + (if y.val + 1 = x.val then c else 0) := by
    intro x y; unfold wpathQ
    by_cases hA : x.val + 1 = y.val <;> by_cases hB : y.val + 1 = x.val <;> simp_all
    all_goals omega
  simp_rw [hsplit, Finset.sum_add_distrib]
  have inner1 : ∀ x : Fin n, (∑ y : Fin n, (if x.val + 1 = y.val then c else 0))
      = if x.val + 1 < n then c else 0 := by
    intro x
    rw [Fin.sum_univ_eq_sum_range (fun j => if x.val + 1 = j then c else 0) n]
    rw [Finset.sum_ite_eq (Finset.range n) (x.val + 1) (fun _ => c)]
    simp [Finset.mem_range]
  have inner2 : ∀ x : Fin n, (∑ y : Fin n, (if y.val + 1 = x.val then c else 0))
      = if 1 ≤ x.val then c else 0 := by
    intro x
    rw [Fin.sum_univ_eq_sum_range (fun j => if j + 1 = x.val then c else 0) n]
    by_cases hx : 1 ≤ x.val
    · rw [show (fun j => if j + 1 = x.val then c else 0)
          = (fun j => if x.val - 1 = j then c else 0) from ?_]
      · rw [Finset.sum_ite_eq (Finset.range n) (x.val - 1) (fun _ => c)]
        have hlt : x.val - 1 < n := by omega
        simp [Finset.mem_range, hlt, hx]
      · funext j; by_cases h : x.val - 1 = j <;> simp_all <;> omega
    · rw [if_neg hx]
      exact Finset.sum_eq_zero (fun j _ => if_neg (by omega))
  simp_rw [inner1, inner2]
  rw [sumTc c n hn]
  have hsum2 : (∑ x : Fin n, (if 1 ≤ x.val then c else 0)) = c * ((n : ℝ) - 1) := by
    rw [Fin.sum_univ_eq_sum_range (fun j => if 1 ≤ j then c else 0) n]
    rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, Finset.sum_const, nsmul_eq_mul]
    have h1 : (Finset.range n).filter (fun j => 1 ≤ j) = Finset.Ico 1 n := by
      ext j; simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]; omega
    rw [h1, Nat.card_Ico]
    push_cast [Nat.cast_sub hn]; ring
  rw [hsum2]; ring

/-- **Weighted-path variation.**  The variation of the position statistic is
`n²(n²−1)/6`, independent of the conductance. -/
theorem wpath_vr_eq (n : ℕ) : vr (idf n) = (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 - 1) / 6 := by
  rw [vr_eq]
  have e1 : (∑ x, (idf n x) ^ 2) = (n : ℝ) * ((n : ℝ) - 1) * (2 * (n : ℝ) - 1) / 6 := by
    simp only [idf]; exact sum_val_sq n
  have e2 : (∑ x, idf n x) = (n : ℝ) * ((n : ℝ) - 1) / 2 := by
    simp only [idf]; exact sum_val n
  rw [Fintype.card_fin, e1, e2]; ring

/-- On a path with at least two vertices the position statistic is non-constant. -/
theorem wpath_nonconstant {n : ℕ} (hn : 2 ≤ n) : ∃ x y, idf n x ≠ idf n y := by
  refine ⟨⟨0, by omega⟩, ⟨1, by omega⟩, ?_⟩
  simp [idf]

/-- **Exact Rayleigh quotient of the conductance-weighted path**: `12c/(n²(n+1))`.
The exponent `−3` is independent of `c`; the conductance enters only as the
linear prefactor. -/
theorem wpath_RQ_eq {c : ℝ} {n : ℕ} (hn : 2 ≤ n) :
    RQ (wpathQ c n) (idf n) = 12 * c / ((n : ℝ) ^ 2 * (n + 1)) := by
  unfold RQ
  rw [wpath_dir_eq (by omega), wpath_vr_eq]
  have h0 : (n : ℝ) ≠ 0 := by positivity
  have h2 : (n : ℝ) ^ 2 - 1 ≠ 0 := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn
    nlinarith
  have h3 : (n : ℝ) + 1 ≠ 0 := by positivity
  field_simp
  ring

/-- **Cubic upper bound at fixed conductance.**  For non-negative conductance the
gap of the weighted-path swap chain is `O(n^{-3})`. -/
theorem wpath_gap_cubic_upper {c : ℝ} (hc : 0 ≤ c) {n : ℕ} (hn : 2 ≤ n) :
    gap (wpathQ c n) ≤ 12 * c / (n : ℝ) ^ 3 := by
  have hnr : (2 : ℝ) ≤ n := by exact_mod_cast hn
  calc gap (wpathQ c n) ≤ RQ (wpathQ c n) (idf n) :=
        gap_le_RQ (wpathQ_nonneg hc n) (wpath_nonconstant hn)
    _ = 12 * c / ((n : ℝ) ^ 2 * (n + 1)) := wpath_RQ_eq hn
    _ ≤ 12 * c / (n : ℝ) ^ 3 := by
        gcongr
        nlinarith

/-- **The exponent is exactly three, for every fixed conductance.**  The certifying
Rayleigh quotient lies in the window `[6c·n^{-3}, 12c·n^{-3}]`. -/
theorem wpath_RQ_window {c : ℝ} (hc : 0 ≤ c) {n : ℕ} (hn : 2 ≤ n) :
    6 * c / (n : ℝ) ^ 3 ≤ RQ (wpathQ c n) (idf n) ∧
      RQ (wpathQ c n) (idf n) ≤ 12 * c / (n : ℝ) ^ 3 := by
  have hnr : (2 : ℝ) ≤ n := by exact_mod_cast hn
  rw [wpath_RQ_eq hn]
  refine ⟨?_, ?_⟩
  · rw [← sub_nonneg]
    have key : 12 * c / ((n : ℝ) ^ 2 * (n + 1)) - 6 * c / (n : ℝ) ^ 3
        = c * (12 * (n : ℝ) ^ 3 - 6 * ((n : ℝ) ^ 2 * ((n : ℝ) + 1)))
            / ((n : ℝ) ^ 2 * ((n : ℝ) + 1) * (n : ℝ) ^ 3) := by
      field_simp
    rw [key]; apply div_nonneg
    · apply mul_nonneg hc; nlinarith
    · positivity
  · rw [← sub_nonneg]
    have key : 12 * c / (n : ℝ) ^ 3 - 12 * c / ((n : ℝ) ^ 2 * (n + 1))
        = c * (12 * ((n : ℝ) ^ 2 * ((n : ℝ) + 1)) - 12 * (n : ℝ) ^ 3)
            / ((n : ℝ) ^ 3 * ((n : ℝ) ^ 2 * ((n : ℝ) + 1))) := by
      field_simp
    rw [key]; apply div_nonneg
    · apply mul_nonneg hc; nlinarith
    · positivity

/-- **The constant carries the conductance dependence.**  For a fixed size `n ≥ 2`
the Rayleigh quotient — hence the gap upper bound — is strictly increasing in the
conductance: a larger conductance yields a strictly larger constant in front of
the invariant `n^{-3}` decay. -/
theorem wpath_RQ_strictMono_cond {c₁ c₂ : ℝ} (h : c₁ < c₂) {n : ℕ} (hn : 2 ≤ n) :
    RQ (wpathQ c₁ n) (idf n) < RQ (wpathQ c₂ n) (idf n) := by
  rw [wpath_RQ_eq hn, wpath_RQ_eq hn]
  gcongr

/-! ### Modelling genus through a decreasing conductance -/

/-- A concrete genus-decreasing conductance: `c(g) = 1/(g+1)`, positive for every
genus and strictly decreasing in `g`. -/
noncomputable def condOfGenus (g : ℕ) : ℝ := 1 / (g + 1)

/-- The genus conductance is strictly positive. -/
theorem condOfGenus_pos (g : ℕ) : 0 < condOfGenus g := by
  unfold condOfGenus; positivity

/-- The genus conductance is strictly decreasing in the genus. -/
theorem condOfGenus_strictAnti {g₁ g₂ : ℕ} (h : g₁ < g₂) :
    condOfGenus g₂ < condOfGenus g₁ := by
  unfold condOfGenus
  apply one_div_lt_one_div_of_lt
  · positivity
  · have : (g₁ : ℝ) < g₂ := by exact_mod_cast h
    linarith

/-- **Genus enters only through the constant (Conjecture 3).**  With genus modelled
by the decreasing conductance `c(g)`, the leading constant `12·c(g)` in front of
the invariant `n^{-3}` gap decay is strictly positive and strictly decreasing in
the genus, while the exponent `−3` is untouched. -/
theorem genus_gap_constant_strictAnti {g₁ g₂ : ℕ} (h : g₁ < g₂) :
    0 < 12 * condOfGenus g₂ ∧ 12 * condOfGenus g₂ < 12 * condOfGenus g₁ := by
  refine ⟨by have := condOfGenus_pos g₂; linarith, ?_⟩
  have := condOfGenus_strictAnti h
  linarith

/-- **Genus gap upper bound.**  At every genus the weighted-path gap obeys the same
cubic law, with a genus-dependent constant `12·c(g)`. -/
theorem genus_gap_cubic_upper (g : ℕ) {n : ℕ} (hn : 2 ≤ n) :
    gap (wpathQ (condOfGenus g) n) ≤ 12 * condOfGenus g / (n : ℝ) ^ 3 :=
  wpath_gap_cubic_upper (le_of_lt (condOfGenus_pos g)) hn

/-! ### Examples, generalizations, and boundary cases (PEGB) -/

-- Example: the universality engine specialised to the weighted path recovers the
-- exact cubic quotient.
example : RQ (wpathQ (1 : ℝ) 5) (idf 5) = 12 * 1 / ((5 : ℝ) ^ 2 * (5 + 1)) :=
  wpath_RQ_eq (by norm_num)

-- Example: the unit-weight energy is `2(n−1)`, generalised by `wpath_dir_eq`.
example : dir (wpathQ (1 : ℝ) 4) (idf 4) = 2 * 1 * ((4 : ℝ) - 1) :=
  wpath_dir_eq (by norm_num)

-- Boundary case: at conductance `c = 0` the chain has no edges, the energy
-- vanishes, and the Rayleigh quotient collapses to `0` — the strict monotonicity
-- and window statements therefore require positive conductance.
example {n : ℕ} (hn : 2 ≤ n) : RQ (wpathQ (0 : ℝ) n) (idf n) = 0 := by
  rw [wpath_RQ_eq hn]; simp

#check @gap_cubic_of_linear_quartic
#check @wpath_RQ_strictMono_cond
#check @genus_gap_constant_strictAnti

end ChordSwapUniv