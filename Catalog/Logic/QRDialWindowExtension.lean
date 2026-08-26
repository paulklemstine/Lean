/-
# Cycle 3: the capture *budget* of a prime window, and what the `ℓ ≤ 10⁶` extension must supply

Cycle 2 (`Logic.QRDialMultiCapture`) proved that for a pairwise-uncorrelated family of dials
the total linearly explained fraction of the target is exactly the sum of the individual
squared correlations, so the pre-registered `H1` bar is met only if
`Σ_j r_j² ≥ 0.30`.  This file turns that sum into a *budget* and derives the structural
constraints the named follow-up experiment (a product-form dial over all primes `ℓ ≤ 10⁶`,
~78k Legendre symbols) has to satisfy.

Main results.

* `capture_budget_le_one` — **Bessel inequality for dials.**  For any orthogonal family the
  capture budget `Σ_j r_j²` is at most `1`.  The explained shares of orthogonal dials add,
  and they can never overdraw the variance of the target.  Consequence: a family of `m`
  orthogonal dials of *equal* strength has `r² ≤ 1/m` per dial
  (`uniform_correlation_ceiling`), so "many weak symbols" is a genuine constraint, not a
  free lunch.
* `var_sum_of_orthogonal`, `aggregate_le_family` — **collapsing a window into one count
  statistic can only lose.**  The single aggregated dial `S = Σ_j s_j` (which is exactly
  what a product-form count `#{ℓ : N is a QR mod ℓ}` is: a sum of per-prime indicators)
  satisfies `r²(y, S) ≤ Σ_j r²(y, s_j)`.  So the recorded `S_prod` reading is a *lower*
  bound for the window it summarises, and the family bound of cycle 2 is the right ceiling
  to test against.
* `window_transfer_requirement` — **the pre-registered decision rule for the follow-up.**
  With the tested window `ℓ ≤ 400` capped at `0.1422` of squared correlation, meeting the
  `0.30` bar forces the extension window `400 < ℓ ≤ 10⁶` to supply at least `0.1578` on its
  own.
* `carrier_dimension_lower_bound`, `exp576_carrier_dimension` — **how many mechanisms the
  carrier needs.**  If no single orthogonal dial exceeds `c`, reaching the bar takes at least
  `0.3/c` of them; at the recorded ceiling `c = 0.0781` that is at least four mutually
  uncorrelated mechanisms.
* `extension_per_symbol_requirement`, `exp576_window_extension_target` — **a per-symbol
  target.**  Spreading `0.1578` over at most `78 498` primes forces at least one individual
  Legendre-symbol dial to carry `r² ≥ 2·10⁻⁶`.  That is a falsifiable, per-symbol
  prediction: if every symbol in the extension window measures below `2·10⁻⁶`, the
  scale-shift hypothesis is refuted and the residual `u ≈ 10` clustering is carried by
  structure outside the QR dial family altogether.

Everything is exact finite-sample algebra; the measured numbers enter only as hypotheses.
-/
import Logic.QRDialMultiCapture

open Finset

namespace Logic.QRDial

variable {ι : Type*} [Fintype ι] [Nonempty ι]
variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-! ## Nonnegativity plumbing -/

omit [Nonempty ι] in
lemma avg_nonneg_of_nonneg (x : ι → ℝ) (h : ∀ i, 0 ≤ x i) : 0 ≤ avg x :=
  div_nonneg (Finset.sum_nonneg fun i _ => h i) (by positivity)

omit [Nonempty ι] [DecidableEq κ] in
lemma mseFamily_nonneg (y : ι → ℝ) (s : κ → ι → ℝ) (a : ℝ) (b : κ → ℝ) :
    0 ≤ mseFamily y s a b :=
  avg_nonneg_of_nonneg _ fun _ => sq_nonneg _

omit [Nonempty ι] [DecidableEq κ] in
/-- The capture budget of a family, rewritten with the variance of the target factored out. -/
lemma capture_budget_mul (y : ι → ℝ) (s : κ → ι → ℝ) (hy : 0 < var y)
    (hs : ∀ j, 0 < var (s j)) :
    ∑ j, (cov y (s j)) ^ 2 / var (s j) = (∑ j, corrSq y (s j)) * var y := by
  rw [Finset.sum_mul]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [corrSq]
  field_simp [(hs j).ne', hy.ne']

/-! ## A Bessel inequality for orthogonal dials -/

/-- **Bessel inequality for dials.**  Orthogonal dials cannot jointly explain more than the
whole variance of the target: the capture budget `Σ_j r_j²` never exceeds `1`.  In
particular no enlargement of a dial family can push the explained fraction past `100%`,
and each additional prime competes for a finite budget. -/
theorem capture_budget_le_one (y : ι → ℝ) (s : κ → ι → ℝ) (hy : 0 < var y)
    (hs : ∀ j, 0 < var (s j)) (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0) :
    ∑ j, corrSq y (s j) ≤ 1 := by
  have htight := family_capture_bound_tight y s hs horth
  have hnn := mseFamily_nonneg y s (avg y - ∑ j, (cov y (s j) / var (s j)) * avg (s j))
    (fun j => cov y (s j) / var (s j))
  rw [htight, capture_budget_mul y s hy hs] at hnn
  nlinarith [hnn, hy]

/-- **Dilution ceiling.**  If all `m` dials of an orthogonal family have squared correlation
at least `rho`, then `rho ≤ 1/m`: a window of many mutually orthogonal symbols can only
consist of individually very weak dials. -/
theorem uniform_correlation_ceiling (y : ι → ℝ) (s : κ → ι → ℝ) (hy : 0 < var y)
    (hs : ∀ j, 0 < var (s j)) (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0)
    (rho : ℝ) (hrho : ∀ j, rho ≤ corrSq y (s j)) (hne : 0 < Fintype.card κ) :
    rho ≤ 1 / (Fintype.card κ : ℝ) := by
  have hsum : (Fintype.card κ : ℝ) * rho ≤ ∑ j, corrSq y (s j) := by
    have := Finset.sum_le_sum (s := (Finset.univ : Finset κ)) (f := fun _ : κ => rho)
      (g := fun j => corrSq y (s j)) (fun j _ => hrho j)
    simpa [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_comm] using this
  have hb := capture_budget_le_one y s hy hs horth
  have hcard : (0 : ℝ) < (Fintype.card κ : ℝ) := by exact_mod_cast hne
  rw [le_div_iff₀ hcard]
  nlinarith [hsum, hb]

/-! ## Aggregating a window into a single count statistic -/

/-- The variance of a sum of pairwise uncorrelated dials is the sum of the variances. -/
lemma var_sum_of_orthogonal (s : κ → ι → ℝ) (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0) :
    var (fun i => ∑ j, s j i) = ∑ j, var (s j) := by
  classical
  rw [var, cov_sum_left]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [cov_sum_right, Finset.sum_eq_single j]
  · rfl
  · intro l _ hl
    exact horth j l (Ne.symm hl)
  · intro hj
    exact absurd (Finset.mem_univ j) hj

/-- **Collapsing a window into one count statistic can only lose information.**  The
aggregate dial `S = Σ_j s_j` — the shape of a product-form count such as
`#{ℓ ≤ L : N is a QR mod ℓ}` — has squared correlation at most the capture budget of the
family it aggregates.  Hence a measured `S_prod` reading is a lower bound for its window,
and the family ceiling of cycle 2 is the correct quantity to test the `H1` bar against. -/
theorem aggregate_le_family (y : ι → ℝ) (s : κ → ι → ℝ) (hy : 0 < var y)
    (hs : ∀ j, 0 < var (s j)) (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0) :
    corrSq y (fun i => ∑ j, s j i) ≤ ∑ j, corrSq y (s j) := by
  classical
  have hcov : cov y (fun i => ∑ j, s j i) = ∑ j, cov y (s j) := cov_sum_right _ _ _
  have hvar : var (fun i => ∑ j, s j i) = ∑ j, var (s j) := var_sum_of_orthogonal s horth
  have hCS := Finset.sq_sum_div_le_sum_sq_div Finset.univ (fun j => cov y (s j))
    (g := fun j => var (s j)) (fun j _ => hs j)
  have hrhs : ∑ j, corrSq y (s j) = (∑ j, (cov y (s j)) ^ 2 / var (s j)) / var y := by
    rw [Finset.sum_div]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [corrSq]
    field_simp [(hs j).ne', hy.ne']
  have hlhs : corrSq y (fun i => ∑ j, s j i)
      = ((∑ j, cov y (s j)) ^ 2 / ∑ j, var (s j)) / var y := by
    rw [corrSq, hcov, hvar, div_div, mul_comm]
  rw [hlhs, hrhs]
  gcongr

/-! ## The decision rule for the `ℓ ≤ 10⁶` follow-up -/

omit [Nonempty ι] in
/-- **Window transfer.**  If the already-tested window `t` is capped at `0.1422` of squared
correlation and the family as a whole meets the `0.30` bar, then the untested extension
window `tᶜ` must contribute at least `0.1578` by itself. -/
theorem window_transfer_requirement (y : ι → ℝ) (s : κ → ι → ℝ) (t : Finset κ)
    (htested : ∑ j ∈ t, corrSq y (s j) ≤ 1422 / 10000)
    (hbar : 3 / 10 ≤ ∑ j, corrSq y (s j)) :
    1578 / 10000 ≤ ∑ j ∈ tᶜ, corrSq y (s j) := by
  have hsplit : ∑ j ∈ t, corrSq y (s j) + ∑ j ∈ tᶜ, corrSq y (s j) = ∑ j, corrSq y (s j) :=
    Finset.sum_add_sum_compl t _
  linarith

omit [Nonempty ι] [Fintype κ] [DecidableEq κ] in
/-- **Per-symbol target.**  A budget `b` spread over a nonempty window `u` forces some single
dial in `u` to carry at least `b / |u|`. -/
theorem extension_per_symbol_requirement (y : ι → ℝ) (s : κ → ι → ℝ) (u : Finset κ)
    (hu : u.Nonempty) (b : ℝ) (hb : b ≤ ∑ j ∈ u, corrSq y (s j)) :
    ∃ j ∈ u, b / (u.card : ℝ) ≤ corrSq y (s j) := by
  classical
  have hcard : (0 : ℝ) < (u.card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr hu
  by_contra hcon
  push_neg at hcon
  have hlt : ∑ j ∈ u, corrSq y (s j) < ∑ _j ∈ u, b / (u.card : ℝ) :=
    Finset.sum_lt_sum_of_nonempty hu fun j hj => hcon j hj
  rw [Finset.sum_const, nsmul_eq_mul, mul_div_cancel₀ _ hcard.ne'] at hlt
  linarith

omit [Nonempty ι] in
/-- **exp 576, follow-up target.**  Certified consequence of the recorded readings: if the
`ℓ ≤ 400` window is capped at `0.1422`, the `ℓ ≤ 10⁶` family meets the `0.30` bar, and the
extension window contains at most `78 498` primes, then at least one *individual* Legendre
symbol in `400 < ℓ ≤ 10⁶` must reach `r² ≥ 2·10⁻⁶`.  Measuring every extension symbol below
that threshold refutes the scale-shift hypothesis. -/
theorem exp576_window_extension_target (y : ι → ℝ) (s : κ → ι → ℝ) (t : Finset κ)
    (htested : ∑ j ∈ t, corrSq y (s j) ≤ 1422 / 10000)
    (hbar : 3 / 10 ≤ ∑ j, corrSq y (s j))
    (hne : tᶜ.Nonempty) (hsize : ((tᶜ).card : ℝ) ≤ 78498) :
    ∃ j ∈ tᶜ, (2 : ℝ) / 1000000 ≤ corrSq y (s j) := by
  classical
  have hbudget := window_transfer_requirement y s t htested hbar
  obtain ⟨j, hj, hjb⟩ :=
    extension_per_symbol_requirement y s tᶜ hne (1578 / 10000) hbudget
  refine ⟨j, hj, le_trans ?_ hjb⟩
  have hcard : (0 : ℝ) < ((tᶜ).card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr hne
  rw [le_div_iff₀ hcard]
  nlinarith [hsize, hcard]

/-! ## How many orthogonal mechanisms the carrier needs -/

omit [Nonempty ι] [DecidableEq κ] in
/-- **Carrier-dimension lower bound.**  If no single dial of an orthogonal family carries
more than `c` of squared correlation, then meeting the `0.30` bar needs at least `0.3 / c`
dials.  Weak mechanisms can only reach the bar in numbers. -/
theorem carrier_dimension_lower_bound (y : ι → ℝ) (s : κ → ι → ℝ) (c : ℝ) (hc : 0 < c)
    (hcap : ∀ j, corrSq y (s j) ≤ c) (hbar : 3 / 10 ≤ ∑ j, corrSq y (s j)) :
    3 / (10 * c) ≤ (Fintype.card κ : ℝ) := by
  have hsum : ∑ j, corrSq y (s j) ≤ (Fintype.card κ : ℝ) * c := by
    have := Finset.sum_le_sum (s := (Finset.univ : Finset κ)) (f := fun j => corrSq y (s j))
      (g := fun _ : κ => c) (fun j _ => hcap j)
    simpa [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using this
  rw [div_le_iff₀ (by positivity : (0:ℝ) < 10 * c)]
  nlinarith [hbar, hsum]

omit [Nonempty ι] [DecidableEq κ] in
/-- **exp 576, carrier dimension.**  No recorded dial exceeds `r² = 0.0781`; if the carrier
of the `u ≈ 10` clustering decomposes into dials of that strength that are pairwise
uncorrelated, at least four of them are needed to reach the pre-registered bar. -/
theorem exp576_carrier_dimension (y : ι → ℝ) (s : κ → ι → ℝ)
    (hcap : ∀ j, corrSq y (s j) ≤ 781 / 10000)
    (hbar : 3 / 10 ≤ ∑ j, corrSq y (s j)) :
    4 ≤ Fintype.card κ := by
  have hkey := carrier_dimension_lower_bound y s (781 / 10000) (by norm_num) hcap hbar
  by_contra hcon
  push_neg at hcon
  have hle : (Fintype.card κ : ℝ) ≤ 3 := by
    have : Fintype.card κ ≤ 3 := by omega
    exact_mod_cast this
  norm_num at hkey
  linarith

end Logic.QRDial