import Applications.EML.TropicalGDConvergence

/-!
# Tropical `L¹` medians of arbitrary samples and clipped subgradient descent

The catalog files `Applications.EML.TropicalGradientFlow` and
`Applications.EML.TropicalGDConvergence` treat a scalar tropical monomial
`z ↦ z + θ` trained by clipped subgradient descent on **three** reduced samples.
This file removes the "three samples" restriction and upgrades the closed-form
iteration `gdIter` to a genuine iterate of a one-step optimizer.

Main contributions.

* `l1Loss` : the tropical `L¹` empirical loss of a scalar parameter on `n`
  reduced samples, generalizing `threePointLoss` (see `l1Loss_three`).
* `l1Loss_growth_right` / `l1Loss_growth_left` : a single counting mechanism —
  a block of indices below (resp. above) a pivot pushes the loss up with slope
  equal to the *imbalance* of the two blocks.  Every median statement below is a
  specialization of these two lemmas.
* `odd_l1Loss_growth` : for `2k+1` sorted samples the loss grows at least
  linearly away from the sample median `x k`:  `L (x k) + |θ - x k| ≤ L θ`.
  Hence `odd_minimizes_iff_median`.
* `tropicalFlow_trans` : the clipped flow is a one-parameter semigroup, hence
  `flow_iterate` : the catalog's closed-form `gdIter` really is the `n`-fold
  iterate of the one-step clipped update.
* `odd_descent_terminates_ceiling` / `odd_descent_before_ceiling` : clipped
  descent with step `η > 0` hits the unique median after `⌈|x₀ - m| / η⌉` steps,
  and the ceiling is sharp.
* `even_l1Loss_const_on_Icc`, `even_l1Loss_growth_right/left`,
  `even_minimizes_iff_mem_Icc` : for `2k+2` sorted samples the minimizer set is
  *exactly* the closed interval between the two central order statistics; the
  loss is constant there and grows with slope `2` outside it.
* `intervalStep`, `interval_descent_reaches_minimizer` : clipped descent onto
  that interval terminates in finite time for every positive step size, and the
  point it reaches is an empirical-risk minimizer.
* `l1Loss_slab_exact` : the growth bounds are attained — on a slab between two
  order statistics the loss is affine with slope exactly `j - (n - j)`, so none of
  the constants above can be improved.
* `l1Loss_lipschitz`, `odd_descent_loss_rate` : the loss is `n`-Lipschitz, hence an
  explicit excess-risk rate along the descent trajectory.
-/

noncomputable section

open Filter Set Topology
open EMLTropicalGradientFlow EMLTropicalGD

namespace TropicalMedianDescent

/-! ## The tropical `L¹` empirical loss -/

/-- Tropical `L¹` empirical loss of a scalar parameter on `n` reduced samples. -/
def l1Loss (n : ℕ) (x : ℕ → ℝ) (θ : ℝ) : ℝ := ∑ i ∈ Finset.range n, |θ - x i|

/-- A sample is sorted if it is monotone on the index range. -/
def SortedSample (n : ℕ) (x : ℕ → ℝ) : Prop := ∀ i j, i ≤ j → j < n → x i ≤ x j

/-- `l1Loss` on three samples is exactly the catalog's `threePointLoss`. -/
theorem l1Loss_three (a m c θ : ℝ) :
    l1Loss 3 (fun i => if i = 0 then a else if i = 1 then m else c) θ =
      threePointLoss a m c θ := by
  simp [l1Loss, threePointLoss, Finset.sum_range_succ]

/-- Splitting an index range at `j`. -/
theorem sum_range_split (n j : ℕ) (hj : j ≤ n) (f : ℕ → ℝ) :
    ∑ i ∈ Finset.range n, f i
      = ∑ i ∈ Finset.range j, f i + ∑ i ∈ Finset.Ico j n, f i := by
  rw [Finset.range_eq_Ico, (Finset.sum_Ico_consecutive f (Nat.zero_le j) hj).symm]

/-! ## The counting mechanism

Moving the parameter from a pivot `p` to the right by `δ` increases every term
indexed by a sample lying at or below `p` by exactly `δ`, and decreases the other
terms by at most `δ`.  So the loss increases at least at rate
`#(low block) - #(high block)`.  This single lemma (and its mirror) drives the
odd-sample and even-sample median theorems. -/

/-- **Right-hand growth bound.**  If the `j` samples with index `< j` all lie at
or below the pivot `p`, then moving right from `p` increases the loss with rate
at least `j - (n - j)`. -/
theorem l1Loss_growth_right {n j : ℕ} (hj : j ≤ n) {x : ℕ → ℝ} {p θ : ℝ} (hpθ : p ≤ θ)
    (hlow : ∀ i, i < j → x i ≤ p) :
    l1Loss n x p + ((j : ℝ) - ((n - j : ℕ) : ℝ)) * (θ - p) ≤ l1Loss n x θ := by
  unfold l1Loss
  rw [sum_range_split n j hj, sum_range_split n j hj]
  have hleft : ∑ i ∈ Finset.range j, |θ - x i|
      = (∑ i ∈ Finset.range j, |p - x i|) + (j : ℝ) * (θ - p) := by
    have h : ∀ i ∈ Finset.range j, |θ - x i| = |p - x i| + (θ - p) := by
      intro i hi
      have hip : x i ≤ p := hlow i (Finset.mem_range.mp hi)
      rw [abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]
      ring
    rw [Finset.sum_congr rfl h, Finset.sum_add_distrib, Finset.sum_const,
      Finset.card_range, nsmul_eq_mul]
  have hright : (∑ i ∈ Finset.Ico j n, |p - x i|) - ((n - j : ℕ) : ℝ) * (θ - p)
      ≤ ∑ i ∈ Finset.Ico j n, |θ - x i| := by
    have hle : ∑ i ∈ Finset.Ico j n, (|p - x i| - (θ - p))
        ≤ ∑ i ∈ Finset.Ico j n, |θ - x i| := by
      refine Finset.sum_le_sum fun i _ => ?_
      have h := abs_sub_abs_le_abs_sub (p - x i) (θ - x i)
      have he : |(p - x i) - (θ - x i)| = θ - p := by
        have hrw : (p - x i) - (θ - x i) = -(θ - p) := by ring
        rw [hrw, abs_neg, abs_of_nonneg (by linarith)]
      rw [he] at h
      linarith
    rwa [Finset.sum_sub_distrib, Finset.sum_const, Nat.card_Ico, nsmul_eq_mul] at hle
  have hexp : ((j : ℝ) - ((n - j : ℕ) : ℝ)) * (θ - p)
      = (j : ℝ) * (θ - p) - ((n - j : ℕ) : ℝ) * (θ - p) := by ring
  rw [hexp]
  linarith

/-- **Left-hand growth bound**, the mirror image of `l1Loss_growth_right`. -/
theorem l1Loss_growth_left {n j : ℕ} (hj : j ≤ n) {x : ℕ → ℝ} {p θ : ℝ} (hpθ : θ ≤ p)
    (hhigh : ∀ i, j ≤ i → i < n → p ≤ x i) :
    l1Loss n x p + (((n - j : ℕ) : ℝ) - (j : ℝ)) * (p - θ) ≤ l1Loss n x θ := by
  unfold l1Loss
  rw [sum_range_split n j hj, sum_range_split n j hj]
  have hright : ∑ i ∈ Finset.Ico j n, |θ - x i|
      = (∑ i ∈ Finset.Ico j n, |p - x i|) + ((n - j : ℕ) : ℝ) * (p - θ) := by
    have h : ∀ i ∈ Finset.Ico j n, |θ - x i| = |p - x i| + (p - θ) := by
      intro i hi
      obtain ⟨hi1, hi2⟩ := Finset.mem_Ico.mp hi
      have hip : p ≤ x i := hhigh i hi1 hi2
      rw [abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]
      ring
    rw [Finset.sum_congr rfl h, Finset.sum_add_distrib, Finset.sum_const, Nat.card_Ico,
      nsmul_eq_mul]
  have hleft : (∑ i ∈ Finset.range j, |p - x i|) - (j : ℝ) * (p - θ)
      ≤ ∑ i ∈ Finset.range j, |θ - x i| := by
    have hle : ∑ i ∈ Finset.range j, (|p - x i| - (p - θ))
        ≤ ∑ i ∈ Finset.range j, |θ - x i| := by
      refine Finset.sum_le_sum fun i _ => ?_
      have h := abs_sub_abs_le_abs_sub (p - x i) (θ - x i)
      have he : |(p - x i) - (θ - x i)| = p - θ := by
        have hrw : (p - x i) - (θ - x i) = p - θ := by ring
        rw [hrw, abs_of_nonneg (by linarith)]
      rw [he] at h
      linarith
    rwa [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hle
  have hexp : (((n - j : ℕ) : ℝ) - (j : ℝ)) * (p - θ)
      = ((n - j : ℕ) : ℝ) * (p - θ) - (j : ℝ) * (p - θ) := by ring
  rw [hexp]
  linarith

/-- **Exact slab formula.**  If in addition every sample index `≥ j` lies at or above
`θ`, the growth bound of `l1Loss_growth_right` is an *equality*: the loss is affine with
slope exactly `j - (n - j)` on the slab.  So the constants in the growth bounds above
cannot be improved. -/
theorem l1Loss_slab_exact {n j : ℕ} (hj : j ≤ n) {x : ℕ → ℝ} {p θ : ℝ} (hpθ : p ≤ θ)
    (hlow : ∀ i, i < j → x i ≤ p) (hhigh : ∀ i, j ≤ i → i < n → θ ≤ x i) :
    l1Loss n x θ = l1Loss n x p + ((j : ℝ) - ((n - j : ℕ) : ℝ)) * (θ - p) := by
  unfold l1Loss
  rw [sum_range_split n j hj, sum_range_split n j hj]
  have hleft : ∑ i ∈ Finset.range j, |θ - x i|
      = (∑ i ∈ Finset.range j, |p - x i|) + (j : ℝ) * (θ - p) := by
    have h : ∀ i ∈ Finset.range j, |θ - x i| = |p - x i| + (θ - p) := by
      intro i hi
      have hip : x i ≤ p := hlow i (Finset.mem_range.mp hi)
      rw [abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]
      ring
    rw [Finset.sum_congr rfl h, Finset.sum_add_distrib, Finset.sum_const,
      Finset.card_range, nsmul_eq_mul]
  have hright : ∑ i ∈ Finset.Ico j n, |θ - x i|
      = (∑ i ∈ Finset.Ico j n, |p - x i|) - ((n - j : ℕ) : ℝ) * (θ - p) := by
    have h : ∀ i ∈ Finset.Ico j n, |θ - x i| = |p - x i| - (θ - p) := by
      intro i hi
      obtain ⟨hi1, hi2⟩ := Finset.mem_Ico.mp hi
      have hip : θ ≤ x i := hhigh i hi1 hi2
      rw [abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]
      ring
    rw [Finset.sum_congr rfl h, Finset.sum_sub_distrib, Finset.sum_const, Nat.card_Ico,
      nsmul_eq_mul]
  rw [hleft, hright]
  ring

/-! ## Odd sample size: a unique median with linear loss growth -/

/-- **Odd-sample linear growth.**  For `2k+1` sorted samples the `L¹` loss at any
parameter exceeds the loss at the sample median `x k` by at least the parameter
displacement. -/
theorem odd_l1Loss_growth {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 1) x) (θ : ℝ) :
    l1Loss (2 * k + 1) x (x k) + |θ - x k| ≤ l1Loss (2 * k + 1) x θ := by
  rcases le_total (x k) θ with h | h
  · have hcoef : (((k + 1 : ℕ) : ℝ) - ((2 * k + 1 - (k + 1) : ℕ) : ℝ)) = 1 := by
      have h2 : (2 * k + 1 - (k + 1) : ℕ) = k := by omega
      rw [h2]; push_cast; ring
    have := l1Loss_growth_right (n := 2 * k + 1) (j := k + 1) (by omega) (x := x)
      (p := x k) (θ := θ) h (fun i hi => hx i k (Nat.lt_succ_iff.mp hi) (by omega))
    rw [hcoef, abs_of_nonneg (by linarith)] at *
    linarith
  · have hcoef : (((2 * k + 1 - k : ℕ) : ℝ) - (k : ℝ)) = 1 := by
      have h2 : (2 * k + 1 - k : ℕ) = k + 1 := by omega
      rw [h2]; push_cast; ring
    have := l1Loss_growth_left (n := 2 * k + 1) (j := k) (by omega) (x := x)
      (p := x k) (θ := θ) h (fun i hi hi2 => hx k i hi hi2)
    rw [hcoef, abs_of_nonpos (by linarith)] at *
    linarith

/-- The sample median minimizes the tropical `L¹` loss of an odd sample. -/
theorem odd_median_minimizes {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 1) x) (θ : ℝ) :
    l1Loss (2 * k + 1) x (x k) ≤ l1Loss (2 * k + 1) x θ := by
  have := odd_l1Loss_growth hx θ
  have := abs_nonneg (θ - x k)
  linarith

/-- **Odd-sample empirical-risk minimization is exactly the median condition.** -/
theorem odd_minimizes_iff_median {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 1) x)
    (θ : ℝ) :
    (∀ y : ℝ, l1Loss (2 * k + 1) x θ ≤ l1Loss (2 * k + 1) x y) ↔ θ = x k := by
  constructor
  · intro h
    have h1 := h (x k)
    have h2 := odd_l1Loss_growth hx θ
    have h3 : |θ - x k| ≤ 0 := by linarith
    have := abs_nonneg (θ - x k)
    have : θ - x k = 0 := by
      have h4 : |θ - x k| = 0 := le_antisymm h3 (abs_nonneg _)
      exact abs_eq_zero.mp h4
    linarith
  · rintro rfl
    exact odd_median_minimizes hx

/-! ## The clipped flow is a semigroup, and `gdIter` is a genuine iterate -/

/-- The clipped flow at time `0` is the identity. -/
theorem tropicalFlow_zero (m x : ℝ) : tropicalFlow m 0 x = x := by
  unfold tropicalFlow
  split_ifs with h
  · simp [min_eq_right h.le]
  · simp [max_eq_right (not_lt.mp h)]

/-- **Semigroup property** of the clipped tropical flow. -/
theorem tropicalFlow_trans {m s t x : ℝ} (hs : 0 ≤ s) :
    tropicalFlow m s (tropicalFlow m t x) = tropicalFlow m (t + s) x := by
  unfold tropicalFlow
  simp only [min_def, max_def]
  split_ifs <;> linarith

/-- The catalog's closed-form iteration is the `n`-fold iterate of the one-step
clipped subgradient update. -/
theorem flow_iterate {m η x : ℝ} (hη : 0 ≤ η) (n : ℕ) :
    (tropicalFlow m η)^[n] x = gdIter m η x n := by
  induction n with
  | zero => simp [gdIter, tropicalFlow_zero]
  | succ n ih =>
      rw [Function.iterate_succ_apply', ih]
      unfold gdIter
      rw [tropicalFlow_trans hη]
      push_cast
      ring_nf

/-! ## Exact termination time for odd samples -/

/-- Clipped descent with step `η > 0` reaches the median after `⌈|x₀ - m|/η⌉` steps. -/
theorem odd_descent_terminates_ceiling {m η x₀ : ℝ} (hη : 0 < η) :
    (tropicalFlow m η)^[⌈|x₀ - m| / η⌉₊] x₀ = m := by
  rw [flow_iterate hη.le]
  refine gdIter_eq_median_of_distance_le ?_
  have h := Nat.le_ceil (|x₀ - m| / η)
  calc |x₀ - m| = (|x₀ - m| / η) * η := by field_simp
    _ ≤ (⌈|x₀ - m| / η⌉₊ : ℝ) * η := by nlinarith

/-- Termination is *exactly* characterized by the covering condition. -/
theorem odd_descent_iterate_eq_iff {m η x₀ : ℝ} (hη : 0 < η) (n : ℕ) :
    (tropicalFlow m η)^[n] x₀ = m ↔ |x₀ - m| ≤ (n : ℝ) * η := by
  rw [flow_iterate hη.le]
  constructor
  · intro h
    have hd := gdIter_distance (m := m) (η := η) (x := x₀) n
    rw [h, sub_self, abs_zero] at hd
    have := le_max_right 0 (|x₀ - m| - (n : ℝ) * η)
    linarith [hd ▸ this]
  · exact gdIter_eq_median_of_distance_le

/-- **Sharpness of the ceiling bound**: no earlier iterate is at the median. -/
theorem odd_descent_before_ceiling {m η x₀ : ℝ} (hη : 0 < η) {n : ℕ}
    (hn : n < ⌈|x₀ - m| / η⌉₊) :
    (tropicalFlow m η)^[n] x₀ ≠ m := by
  intro heq
  rw [odd_descent_iterate_eq_iff hη] at heq
  have h : (n : ℝ) < |x₀ - m| / η := (Nat.lt_ceil).mp hn
  rw [lt_div_iff₀ hη] at h
  linarith

/-- **Odd-sample training theorem.**  For `2k+1` sorted reduced samples, clipped
subgradient descent with any positive step reaches the unique empirical-risk
minimizer after exactly `⌈|x₀ - m|/η⌉` iterations. -/
theorem odd_training_exact_termination {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 1) x)
    {η x₀ : ℝ} (hη : 0 < η) :
    (tropicalFlow (x k) η)^[⌈|x₀ - x k| / η⌉₊] x₀ = x k ∧
    (∀ n < ⌈|x₀ - x k| / η⌉₊, (tropicalFlow (x k) η)^[n] x₀ ≠ x k) ∧
    (∀ θ : ℝ, (∀ y : ℝ, l1Loss (2 * k + 1) x θ ≤ l1Loss (2 * k + 1) x y) ↔ θ = x k) := by
  exact ⟨odd_descent_terminates_ceiling hη, fun n hn => odd_descent_before_ceiling hη hn,
    fun θ => odd_minimizes_iff_median hx θ⟩

/-! ## Even sample size: the minimizer set is the central interval -/

/-- On the central interval the `L¹` loss of an even sample is *constant*. -/
theorem even_l1Loss_const_on_Icc {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 2) x)
    {θ : ℝ} (h1 : x k ≤ θ) (h2 : θ ≤ x (k + 1)) :
    l1Loss (2 * k + 2) x θ
      = (∑ i ∈ Finset.Ico (k + 1) (2 * k + 2), x i) - ∑ i ∈ Finset.range (k + 1), x i := by
  unfold l1Loss
  rw [sum_range_split (2 * k + 2) (k + 1) (by omega)]
  have hA : ∑ i ∈ Finset.range (k + 1), |θ - x i|
      = ((k : ℝ) + 1) * θ - ∑ i ∈ Finset.range (k + 1), x i := by
    have h : ∀ i ∈ Finset.range (k + 1), |θ - x i| = θ - x i := by
      intro i hi
      have hik : x i ≤ x k := hx i k (Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)) (by omega)
      exact abs_of_nonneg (by linarith)
    rw [Finset.sum_congr rfl h, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range,
      nsmul_eq_mul]
    push_cast
    ring
  have hB : ∑ i ∈ Finset.Ico (k + 1) (2 * k + 2), |θ - x i|
      = (∑ i ∈ Finset.Ico (k + 1) (2 * k + 2), x i) - ((k : ℝ) + 1) * θ := by
    have h : ∀ i ∈ Finset.Ico (k + 1) (2 * k + 2), |θ - x i| = x i - θ := by
      intro i hi
      obtain ⟨hi1, hi2⟩ := Finset.mem_Ico.mp hi
      have hik : x (k + 1) ≤ x i := hx (k + 1) i hi1 hi2
      rw [abs_of_nonpos (by linarith)]
      ring
    rw [Finset.sum_congr rfl h, Finset.sum_sub_distrib, Finset.sum_const, Nat.card_Ico,
      nsmul_eq_mul]
    have hcard : ((2 * k + 2 - (k + 1) : ℕ) : ℝ) = (k : ℝ) + 1 := by
      have h2 : (2 * k + 2 - (k + 1) : ℕ) = k + 1 := by omega
      rw [h2]; push_cast; ring
    rw [hcard]
  rw [hA, hB]
  ring

/-- Right of the upper central order statistic the even-sample loss grows with slope `2`. -/
theorem even_l1Loss_growth_right {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 2) x)
    {θ : ℝ} (hθ : x (k + 1) ≤ θ) :
    l1Loss (2 * k + 2) x (x (k + 1)) + 2 * (θ - x (k + 1)) ≤ l1Loss (2 * k + 2) x θ := by
  have hcoef : (((k + 2 : ℕ) : ℝ) - ((2 * k + 2 - (k + 2) : ℕ) : ℝ)) = 2 := by
    have h2 : (2 * k + 2 - (k + 2) : ℕ) = k := by omega
    rw [h2]; push_cast; ring
  have h := l1Loss_growth_right (n := 2 * k + 2) (j := k + 2) (by omega) (x := x)
    (p := x (k + 1)) (θ := θ) hθ
    (fun i hi => hx i (k + 1) (by omega) (by omega))
  rw [hcoef] at h
  exact h

/-- Left of the lower central order statistic the even-sample loss grows with slope `2`. -/
theorem even_l1Loss_growth_left {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 2) x)
    {θ : ℝ} (hθ : θ ≤ x k) :
    l1Loss (2 * k + 2) x (x k) + 2 * (x k - θ) ≤ l1Loss (2 * k + 2) x θ := by
  have hcoef : (((2 * k + 2 - k : ℕ) : ℝ) - (k : ℝ)) = 2 := by
    have h2 : (2 * k + 2 - k : ℕ) = k + 2 := by omega
    rw [h2]; push_cast; ring
  have h := l1Loss_growth_left (n := 2 * k + 2) (j := k) (by omega) (x := x)
    (p := x k) (θ := θ) hθ (fun i hi hi2 => hx k i hi hi2)
  rw [hcoef] at h
  exact h

/-- **Even-sample minimizer interval.**  The minimizers of the tropical `L¹` loss of
`2k+2` sorted samples are exactly the points of the closed interval spanned by the
two central order statistics. -/
theorem even_minimizes_iff_mem_Icc {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 2) x)
    (θ : ℝ) :
    (∀ y : ℝ, l1Loss (2 * k + 2) x θ ≤ l1Loss (2 * k + 2) x y) ↔
      θ ∈ Set.Icc (x k) (x (k + 1)) := by
  have hlohi : x k ≤ x (k + 1) := hx k (k + 1) (by omega) (by omega)
  have hconst : ∀ y : ℝ, x k ≤ y → y ≤ x (k + 1) →
      l1Loss (2 * k + 2) x y = l1Loss (2 * k + 2) x (x k) := by
    intro y hy1 hy2
    rw [even_l1Loss_const_on_Icc hx hy1 hy2,
      even_l1Loss_const_on_Icc hx (le_refl (x k)) hlohi]
  have hmin : ∀ y : ℝ, l1Loss (2 * k + 2) x (x k) ≤ l1Loss (2 * k + 2) x y := by
    intro y
    rcases le_total y (x k) with hy | hy
    · have := even_l1Loss_growth_left hx hy
      linarith
    · rcases le_total y (x (k + 1)) with hy2 | hy2
      · rw [hconst y hy hy2]
      · have h1 := even_l1Loss_growth_right hx hy2
        have h2 := hconst (x (k + 1)) hlohi (le_refl _)
        linarith
  constructor
  · intro h
    by_contra hmem
    simp only [Set.mem_Icc, not_and_or, not_le] at hmem
    rcases hmem with hlt | hgt
    · have hg := even_l1Loss_growth_left hx hlt.le
      have := h (x k)
      linarith
    · have hg := even_l1Loss_growth_right hx hgt.le
      have h2 := hconst (x (k + 1)) hlohi (le_refl _)
      have := h (x k)
      linarith
  · rintro ⟨h1, h2⟩ y
    rw [hconst θ h1 h2]
    exact hmin y

/-! ## Clipped descent onto the even-sample minimizer interval

When the minimizer set is an interval rather than a point, the clipped
subgradient update moves the parameter toward the *nearest* point of the
interval, i.e. toward its metric projection, and freezes once inside. -/

/-- Metric projection onto `[lo, hi]`. -/
def projIcc (lo hi θ : ℝ) : ℝ := max lo (min hi θ)

/-- One clipped subgradient step of size `η` toward the interval `[lo, hi]`. -/
def intervalStep (lo hi η θ : ℝ) : ℝ := tropicalFlow (projIcc lo hi θ) η θ

theorem projIcc_mem {lo hi θ : ℝ} (h : lo ≤ hi) :
    projIcc lo hi θ ∈ Set.Icc lo hi :=
  ⟨le_max_left _ _, max_le h (min_le_left _ _)⟩

/-- Points of the interval are their own projection, hence fixed points of the step. -/
theorem intervalStep_fixed {lo hi η θ : ℝ} (hη : 0 ≤ η) (h1 : lo ≤ θ) (h2 : θ ≤ hi) :
    intervalStep lo hi η θ = θ := by
  unfold intervalStep projIcc
  rw [min_eq_right h2, max_eq_right h1]
  unfold tropicalFlow
  simp [hη]

/-- The projection is a conserved quantity of the clipped dynamics. -/
theorem intervalStep_proj {lo hi η θ : ℝ} (hη : 0 ≤ η) (h : lo ≤ hi) :
    projIcc lo hi (intervalStep lo hi η θ) = projIcc lo hi θ := by
  unfold intervalStep projIcc tropicalFlow
  simp only [min_def, max_def]
  split_ifs <;> linarith

theorem intervalStep_iterate_proj {lo hi η θ : ℝ} (hη : 0 ≤ η) (h : lo ≤ hi) (n : ℕ) :
    projIcc lo hi ((intervalStep lo hi η)^[n] θ) = projIcc lo hi θ := by
  induction n with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply', intervalStep_proj hη h, ih]

/-- Closed form for interval descent: it is the clipped flow toward the projection. -/
theorem intervalStep_iterate {lo hi η θ : ℝ} (hη : 0 ≤ η) (h : lo ≤ hi) (n : ℕ) :
    (intervalStep lo hi η)^[n] θ = tropicalFlow (projIcc lo hi θ) ((n : ℝ) * η) θ := by
  induction n with
  | zero => simp [tropicalFlow_zero]
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      show tropicalFlow (projIcc lo hi ((intervalStep lo hi η)^[n] θ)) η
        ((intervalStep lo hi η)^[n] θ) = _
      rw [intervalStep_iterate_proj hη h, ih, tropicalFlow_trans hη]
      push_cast
      ring_nf

/-- Exact distance decay for interval descent. -/
theorem intervalStep_distance {lo hi η θ : ℝ} (hη : 0 ≤ η) (h : lo ≤ hi) (n : ℕ) :
    |(intervalStep lo hi η)^[n] θ - projIcc lo hi θ|
      = max 0 (|θ - projIcc lo hi θ| - (n : ℝ) * η) := by
  rw [intervalStep_iterate hη h]
  exact tropicalFlow_distance

/-- Interval descent reaches the projection after `⌈dist/η⌉` steps. -/
theorem intervalStep_terminates_ceiling {lo hi η θ : ℝ} (hη : 0 < η) (h : lo ≤ hi) :
    (intervalStep lo hi η)^[⌈|θ - projIcc lo hi θ| / η⌉₊] θ = projIcc lo hi θ := by
  rw [intervalStep_iterate hη.le h]
  refine tropicalFlow_eq_median ?_
  have hc := Nat.le_ceil (|θ - projIcc lo hi θ| / η)
  calc |θ - projIcc lo hi θ| = (|θ - projIcc lo hi θ| / η) * η := by field_simp
    _ ≤ (⌈|θ - projIcc lo hi θ| / η⌉₊ : ℝ) * η := by nlinarith

/-- **Even-sample descent theorem.**  For `2k+2` sorted reduced samples and any
positive step size, clipped subgradient descent onto the central interval reaches
an empirical-risk minimizer in finitely many steps and stays there. -/
theorem interval_descent_reaches_minimizer {k : ℕ} {x : ℕ → ℝ}
    (hx : SortedSample (2 * k + 2) x) {η θ : ℝ} (hη : 0 < η) :
    ∃ N : ℕ, ∀ n ≥ N,
      (intervalStep (x k) (x (k + 1)) η)^[n] θ = projIcc (x k) (x (k + 1)) θ ∧
      ∀ y : ℝ, l1Loss (2 * k + 2) x ((intervalStep (x k) (x (k + 1)) η)^[n] θ)
        ≤ l1Loss (2 * k + 2) x y := by
  have hlohi : x k ≤ x (k + 1) := hx k (k + 1) (by omega) (by omega)
  refine ⟨⌈|θ - projIcc (x k) (x (k + 1)) θ| / η⌉₊, fun n hn => ?_⟩
  have hreach : (intervalStep (x k) (x (k + 1)) η)^[n] θ = projIcc (x k) (x (k + 1)) θ := by
    rw [intervalStep_iterate hη.le hlohi]
    refine tropicalFlow_eq_median ?_
    have hc := Nat.le_ceil (|θ - projIcc (x k) (x (k + 1)) θ| / η)
    have hcast : ((⌈|θ - projIcc (x k) (x (k + 1)) θ| / η⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) := by
      exact_mod_cast hn
    have hdiv : |θ - projIcc (x k) (x (k + 1)) θ| / η ≤ (n : ℝ) := le_trans hc hcast
    rwa [div_le_iff₀ hη] at hdiv
  refine ⟨hreach, ?_⟩
  rw [hreach]
  exact (even_minimizes_iff_mem_Icc hx _).mpr (projIcc_mem hlohi)

/-! ## Sharpness of the growth bound, Lipschitz control and the loss rate -/

/-- **Exact loss in the central slab.**  For `2k+1` sorted samples the loss is exactly
affine with slope `1` between the median and the next order statistic, so the growth
bound `odd_l1Loss_growth` is attained: its constant cannot be improved. -/
theorem odd_l1Loss_slab {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 1) x)
    {θ : ℝ} (h1 : x k ≤ θ) (h2 : θ ≤ x (k + 1)) :
    l1Loss (2 * k + 1) x θ = l1Loss (2 * k + 1) x (x k) + (θ - x k) := by
  have hcoef : (((k + 1 : ℕ) : ℝ) - ((2 * k + 1 - (k + 1) : ℕ) : ℝ)) = 1 := by
    have hk : (2 * k + 1 - (k + 1) : ℕ) = k := by omega
    rw [hk]; push_cast; ring
  have h := l1Loss_slab_exact (n := 2 * k + 1) (j := k + 1) (by omega) (x := x)
    (p := x k) (θ := θ) h1 (fun i hi => hx i k (Nat.lt_succ_iff.mp hi) (by omega))
    (fun i hi hi2 => le_trans h2 (hx (k + 1) i hi hi2))
  rw [hcoef, one_mul] at h
  exact h

/-- The tropical `L¹` loss of `n` samples is `n`-Lipschitz in the parameter. -/
theorem l1Loss_lipschitz (n : ℕ) (x : ℕ → ℝ) (θ θ' : ℝ) :
    |l1Loss n x θ - l1Loss n x θ'| ≤ (n : ℝ) * |θ - θ'| := by
  unfold l1Loss
  rw [← Finset.sum_sub_distrib]
  calc |∑ i ∈ Finset.range n, (|θ - x i| - |θ' - x i|)|
      ≤ ∑ i ∈ Finset.range n, |(|θ - x i| - |θ' - x i|)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i ∈ Finset.range n, |θ - θ'| := by
        refine Finset.sum_le_sum fun i _ => ?_
        have h := abs_abs_sub_abs_le_abs_sub (θ - x i) (θ' - x i)
        have he : (θ - x i) - (θ' - x i) = θ - θ' := by ring
        rwa [he] at h
    _ = (n : ℝ) * |θ - θ'| := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]

/-- **Explicit training-loss rate for odd samples.**  The excess empirical risk after
`n` clipped steps is nonnegative and decays at rate `(2k+1) η` until it hits `0`. -/
theorem odd_descent_loss_rate {k : ℕ} {x : ℕ → ℝ} (hx : SortedSample (2 * k + 1) x)
    {η x₀ : ℝ} (hη : 0 ≤ η) (n : ℕ) :
    0 ≤ l1Loss (2 * k + 1) x ((tropicalFlow (x k) η)^[n] x₀) - l1Loss (2 * k + 1) x (x k) ∧
    l1Loss (2 * k + 1) x ((tropicalFlow (x k) η)^[n] x₀) - l1Loss (2 * k + 1) x (x k)
      ≤ (2 * (k : ℝ) + 1) * max 0 (|x₀ - x k| - (n : ℝ) * η) := by
  have hiter : (tropicalFlow (x k) η)^[n] x₀ = gdIter (x k) η x₀ n := flow_iterate hη n
  constructor
  · have := odd_median_minimizes hx ((tropicalFlow (x k) η)^[n] x₀)
    linarith
  · have hlip := l1Loss_lipschitz (2 * k + 1) x ((tropicalFlow (x k) η)^[n] x₀) (x k)
    have hdist : |(tropicalFlow (x k) η)^[n] x₀ - x k| = max 0 (|x₀ - x k| - (n : ℝ) * η) := by
      rw [hiter]
      exact gdIter_distance n
    rw [hdist] at hlip
    have hcast : ((2 * k + 1 : ℕ) : ℝ) = 2 * (k : ℝ) + 1 := by push_cast; ring
    rw [hcast] at hlip
    have habs := le_abs_self
      (l1Loss (2 * k + 1) x ((tropicalFlow (x k) η)^[n] x₀) - l1Loss (2 * k + 1) x (x k))
    linarith

/-! ## Kernel-checked instances

Five sorted samples `(-3, -1, 0, 4, 9)` with median `0`, and four sorted samples
`(-3, -1, 2, 5)` whose minimizer set is `[-1, 2]`. -/

/-- The five-sample data used in the examples below. -/
def sample5 : ℕ → ℝ := fun i => if i = 0 then -3 else if i = 1 then -1 else
  if i = 2 then 0 else if i = 3 then 4 else 9

/-- The four-sample data used in the examples below. -/
def sample4 : ℕ → ℝ := fun i => if i = 0 then -3 else if i = 1 then -1 else
  if i = 2 then 2 else 5

example : l1Loss 5 sample5 0 = 17 := by norm_num [l1Loss, sample5, Finset.sum_range_succ]
example : l1Loss 5 sample5 1 = 18 := by norm_num [l1Loss, sample5, Finset.sum_range_succ]
example : l1Loss 5 sample5 (-1) = 18 := by norm_num [l1Loss, sample5, Finset.sum_range_succ]
example : l1Loss 4 sample4 (-1) = 11 := by norm_num [l1Loss, sample4, Finset.sum_range_succ]
example : l1Loss 4 sample4 2 = 11 := by norm_num [l1Loss, sample4, Finset.sum_range_succ]
example : l1Loss 4 sample4 0 = 11 := by norm_num [l1Loss, sample4, Finset.sum_range_succ]
example : l1Loss 4 sample4 3 = 13 := by norm_num [l1Loss, sample4, Finset.sum_range_succ]

/-- `sample5` is sorted, so its median theory applies with `k = 2`. -/
theorem sample5_sorted : SortedSample 5 sample5 := by
  intro i j hij hj
  have hi : i < 5 := lt_of_le_of_lt hij hj
  interval_cases i <;> interval_cases j <;> simp_all [sample5] <;> norm_num

/-- `sample4` is sorted, so its interval theory applies with `k = 1`. -/
theorem sample4_sorted : SortedSample 4 sample4 := by
  intro i j hij hj
  have hi : i < 4 := lt_of_le_of_lt hij hj
  interval_cases i <;> interval_cases j <;> simp_all [sample4] <;> norm_num

/-- Concrete odd-sample minimality: `0` is the unique minimizer for `sample5`. -/
example (θ : ℝ) : l1Loss 5 sample5 0 ≤ l1Loss 5 sample5 θ := by
  have h : SortedSample (2 * 2 + 1) sample5 := sample5_sorted
  have hm := odd_median_minimizes h θ
  have h0 : sample5 2 = 0 := by norm_num [sample5]
  have hn : (2 * 2 + 1 : ℕ) = 5 := by norm_num
  rw [h0, hn] at hm
  exact hm

/-- Concrete even-sample interval: the minimizers of `sample4` are exactly `[-1, 2]`. -/
example (θ : ℝ) :
    (∀ y : ℝ, l1Loss 4 sample4 θ ≤ l1Loss 4 sample4 y) ↔ θ ∈ Set.Icc (-1 : ℝ) 2 := by
  have h : SortedSample (2 * 1 + 2) sample4 := sample4_sorted
  have hm := even_minimizes_iff_mem_Icc h θ
  have h1 : sample4 1 = -1 := by norm_num [sample4]
  have h2 : sample4 (1 + 1) = 2 := by norm_num [sample4]
  have hn : (2 * 1 + 2 : ℕ) = 4 := by norm_num
  rw [h1, h2, hn] at hm
  exact hm

end TropicalMedianDescent