/-
# The yield dial is draw-regime invariant

Setting.  A finite population `ι` of "keys".  Each key `i` carries a *footprint* `x i`
(the weight used by the dial) and a *yield rate* `y i`.  A **draw regime** is a
probability weighting `p : ι → ℝ` (`p ≥ 0`, `∑ p = 1`): uniform draws, balanced draws
and genuinely unbalanced draws are all instances of the same object.

The experimental claim under test (`DIAL-IS-DRAW-INVARIANT`) is that the association
between the footprint dial and the yield rate does **not** get diluted when the draw
regime is changed.  This file isolates the exact structural reason, and quantifies the
residual regime dependence:

* `wcov_eq_half_double_sum` — the Hoeffding/Chebyshev pair identity: the weighted
  covariance is a *pairwise* functional of the population.
* `wcov_nonneg_of_comonotone` — if the population is comonotone (no discordant pair),
  the dial has nonnegative covariance with the rate **in every draw regime**.
* `wcov_pos_of_comonotone` — strict positivity survives as soon as one strictly ordered
  pair is charged by the regime; hence full-support regimes cannot dilute the signal.
* `dial_sign_draw_invariant` — the two-regime form of the claim (uniform vs unbalanced).
* `wcov_monotone_comp_nonneg` — the same holds after arbitrary monotone re-encodings of
  footprint and rate, i.e. for rank (Spearman-type) versions of the dial.
* `wcov_stability_tv` — a quantitative bound: changing the draw regime moves the dial's
  covariance by at most `(range x) * (range y)` times the ℓ¹ (twice total variation)
  distance between the regimes.  "Identical within noise" is therefore forced whenever
  the two regimes are ℓ¹-close, and cannot be worse than this bound in general.

All statements are for an arbitrary finite index type; nothing here is specific to a
sampling seed.
-/
import Mathlib

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-- Weighted (draw-regime) mean of `x`. -/
noncomputable def wmean (p x : ι → ℝ) : ℝ := ∑ i, p i * x i

/-- Weighted (draw-regime) covariance of `x` and `y`. -/
noncomputable def wcov (p x y : ι → ℝ) : ℝ :=
  ∑ i, p i * (x i - wmean p x) * (y i - wmean p y)

/-- Weighted (draw-regime) variance. -/
noncomputable def wvar (p x : ι → ℝ) : ℝ := wcov p x x

/-- A draw regime: a probability weighting of the population. -/
structure DrawRegime (ι : Type*) [Fintype ι] where
  /-- the probability mass of each key -/
  p : ι → ℝ
  nonneg : ∀ i, 0 ≤ p i
  total : ∑ i, p i = 1

lemma wcov_comm (p x y : ι → ℝ) : wcov p x y = wcov p y x := by
  simp only [wcov]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- Raw-moment form of the weighted covariance. -/
lemma wcov_eq_raw {p x y : ι → ℝ} (hp : ∑ i, p i = 1) :
    wcov p x y = (∑ i, p i * x i * y i) - (∑ i, p i * x i) * (∑ i, p i * y i) := by
  simp only [wcov, wmean]
  have key : ∀ i, p i * (x i - ∑ j, p j * x j) * (y i - ∑ j, p j * y j)
      = p i * x i * y i - (∑ j, p j * y j) * (p i * x i) - (∑ j, p j * x j) * (p i * y i)
        + (∑ j, p j * x j) * (∑ j, p j * y j) * p i := by
    intro i; ring
  rw [Finset.sum_congr rfl (fun i _ => key i)]
  simp [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, hp]
  ring

/-- **Hoeffding / Chebyshev pair identity.**  The weighted covariance is a sum over
*ordered pairs of keys* of the regime mass of the pair times the concordance product.
This is the structural reason the dial cannot be diluted: the summand
`(x i - x j) * (y i - y j)` is a property of the population alone, and the regime only
supplies nonnegative weights. -/
lemma wcov_eq_half_double_sum {p x y : ι → ℝ} (hp : ∑ i, p i = 1) :
    (2 : ℝ) * wcov p x y = ∑ i, ∑ j, p i * p j * ((x i - x j) * (y i - y j)) := by
  have expand : ∑ i, ∑ j, p i * p j * ((x i - x j) * (y i - y j))
      = ((∑ i, ∑ j, (p i * (x i * y i)) * p j) - (∑ i, ∑ j, (p i * x i) * (p j * y j))
        - (∑ i, ∑ j, (p i * y i) * (p j * x j))) + (∑ i, ∑ j, p i * (p j * (x j * y j))) := by
    rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [expand]
  simp only [← Finset.mul_sum, ← Finset.sum_mul, hp, mul_one]
  rw [wcov_eq_raw hp]
  have h1 : (∑ i, p i * (x i * y i)) = ∑ i, p i * x i * y i :=
    Finset.sum_congr rfl fun i _ => by ring
  rw [h1]; ring

/-- The population is *comonotone*: no pair of keys is discordant (a larger footprint is
never paired with a strictly smaller rate). -/
def Comonotone (x y : ι → ℝ) : Prop := ∀ i j, 0 ≤ (x i - x j) * (y i - y j)

/-- **No dilution, qualitative form.**  For a comonotone population the dial has
nonnegative covariance with the rate in *every* draw regime, however unbalanced. -/
theorem wcov_nonneg_of_comonotone {x y : ι → ℝ} (R : DrawRegime ι) (h : Comonotone x y) :
    0 ≤ wcov R.p x y := by
  have h2 := wcov_eq_half_double_sum (x := x) (y := y) R.total
  nlinarith [Finset.sum_nonneg (fun i (_ : i ∈ Finset.univ) =>
    Finset.sum_nonneg (fun j (_ : j ∈ Finset.univ) =>
      mul_nonneg (mul_nonneg (R.nonneg i) (R.nonneg j)) (h i j)) )]

/-- **No dilution, strict form.**  If the population is comonotone and the regime charges
two keys that are strictly concordant, the dial's covariance is strictly positive.  In
particular a full-support unbalanced regime signals exactly when a balanced one does. -/
theorem wcov_pos_of_comonotone {x y : ι → ℝ} (R : DrawRegime ι) (h : Comonotone x y)
    {a b : ι} (ha : 0 < R.p a) (hb : 0 < R.p b) (hab : 0 < (x a - x b) * (y a - y b)) :
    0 < wcov R.p x y := by
  have h2 := wcov_eq_half_double_sum (x := x) (y := y) R.total
  have hpos : 0 < ∑ i, ∑ j, R.p i * R.p j * ((x i - x j) * (y i - y j)) := by
    refine Finset.sum_pos' (fun i _ => Finset.sum_nonneg fun j _ =>
      mul_nonneg (mul_nonneg (R.nonneg i) (R.nonneg j)) (h i j)) ⟨a, Finset.mem_univ a, ?_⟩
    refine Finset.sum_pos' (fun j _ =>
      mul_nonneg (mul_nonneg (R.nonneg a) (R.nonneg j)) (h a j)) ⟨b, Finset.mem_univ b, ?_⟩
    exact mul_pos (mul_pos ha hb) hab
  linarith

/-- **DIAL-IS-DRAW-INVARIANT (two-regime form).**  For a comonotone population with at
least one strictly concordant pair, *any* two full-support draw regimes — e.g. a balanced
one and a genuinely unbalanced one — both report a strictly positive dial. -/
theorem dial_sign_draw_invariant {x y : ι → ℝ} (R S : DrawRegime ι)
    (hR : ∀ i, 0 < R.p i) (hS : ∀ i, 0 < S.p i) (h : Comonotone x y)
    {a b : ι} (hab : 0 < (x a - x b) * (y a - y b)) :
    0 < wcov R.p x y ∧ 0 < wcov S.p x y :=
  ⟨wcov_pos_of_comonotone R h (hR a) (hR b) hab,
   wcov_pos_of_comonotone S h (hS a) (hS b) hab⟩

omit [Fintype ι] in
/-- Comonotonicity is stable under monotone re-encoding of both coordinates. -/
lemma comonotone_comp {x y : ι → ℝ} {g h : ℝ → ℝ} (hg : Monotone g) (hh : Monotone h)
    (hxy : Comonotone x y) : Comonotone (g ∘ x) (h ∘ y) := by
  intro i j
  rcases lt_trichotomy (x i) (x j) with hx | hx | hx
  · have hy : y i ≤ y j := by
      by_contra hc
      push_neg at hc
      nlinarith [hxy i j]
    have h1 := hg hx.le; have h2 := hh hy
    simp only [Function.comp_apply]
    nlinarith
  · simp only [Function.comp_apply, hx, sub_self, zero_mul, le_refl]
  · have hy : y j ≤ y i := by
      by_contra hc
      push_neg at hc
      nlinarith [hxy i j]
    have h1 := hg hx.le; have h2 := hh hy
    simp only [Function.comp_apply]
    nlinarith

/-- **Rank (Spearman-type) version.**  Since comonotonicity is preserved by monotone
re-encodings, the nonnegativity of the dial in every draw regime also holds for the
rank-transformed dial, which is what a Spearman statistic measures. -/
theorem wcov_monotone_comp_nonneg {x y : ι → ℝ} (R : DrawRegime ι) {g h : ℝ → ℝ}
    (hg : Monotone g) (hh : Monotone h) (hxy : Comonotone x y) :
    0 ≤ wcov R.p (g ∘ x) (h ∘ y) :=
  wcov_nonneg_of_comonotone R (comonotone_comp hg hh hxy)

section Stability

variable {p q x y : ι → ℝ} {Mx My : ℝ}

omit [Fintype ι] in
private lemma range_nonneg (hx : ∀ i j, |x i - x j| ≤ Mx) [Nonempty ι] : 0 ≤ Mx := by
  obtain ⟨i⟩ := ‹Nonempty ι›
  have := hx i i
  simpa using this

/-- ℓ¹ control of the pair masses: `∑ᵢⱼ |pᵢpⱼ - qᵢqⱼ| ≤ 2 ∑ᵢ |pᵢ - qᵢ|`. -/
lemma pair_mass_l1 (hp0 : ∀ i, 0 ≤ p i) (hq0 : ∀ i, 0 ≤ q i)
    (hp : ∑ i, p i = 1) (hq : ∑ i, q i = 1) :
    ∑ i, ∑ j, |p i * p j - q i * q j| ≤ 2 * ∑ i, |p i - q i| := by
  set S := ∑ i, |p i - q i| with hS
  have step : ∀ i, ∑ j, |p i * p j - q i * q j| ≤ p i * S + |p i - q i| := by
    intro i
    have bound : ∀ j, |p i * p j - q i * q j| ≤ p i * |p j - q j| + |p i - q i| * q j := by
      intro j
      have : p i * p j - q i * q j = p i * (p j - q j) + (p i - q i) * q j := by ring
      rw [this]
      refine (abs_add_le _ _).trans ?_
      rw [abs_mul, abs_mul, abs_of_nonneg (hp0 i), abs_of_nonneg (hq0 j)]
    calc ∑ j, |p i * p j - q i * q j|
        ≤ ∑ j, (p i * |p j - q j| + |p i - q i| * q j) :=
          Finset.sum_le_sum fun j _ => bound j
      _ = p i * S + |p i - q i| := by
          rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hq, hS, mul_one]
  calc ∑ i, ∑ j, |p i * p j - q i * q j|
      ≤ ∑ i, (p i * S + |p i - q i|) := Finset.sum_le_sum fun i _ => step i
    _ = S + S := by rw [Finset.sum_add_distrib, ← Finset.sum_mul, hp, one_mul, ← hS]
    _ = 2 * S := by ring

/-- **Quantitative draw-regime invariance.**  If the footprint values span at most `Mx`
and the rates span at most `My`, then the dial's covariance under two draw regimes differs
by at most `Mx * My` times their ℓ¹ distance (= twice their total-variation distance).
Two regimes that are close in ℓ¹ therefore *must* report the dial "identical within
noise"; there is no room for a dilution effect. -/
theorem wcov_stability_tv (hp0 : ∀ i, 0 ≤ p i) (hq0 : ∀ i, 0 ≤ q i)
    (hp : ∑ i, p i = 1) (hq : ∑ i, q i = 1)
    (hx : ∀ i j, |x i - x j| ≤ Mx) (hy : ∀ i j, |y i - y j| ≤ My) :
    |wcov p x y - wcov q x y| ≤ Mx * My * ∑ i, |p i - q i| := by
  rcases isEmpty_or_nonempty ι with hι | hι
  · simp [wcov, wmean, Finset.sum_empty, Finset.univ_eq_empty]
  have hMx : 0 ≤ Mx := range_nonneg hx
  have hMy : 0 ≤ My := range_nonneg hy
  have hdiff : (2 : ℝ) * (wcov p x y - wcov q x y)
      = ∑ i, ∑ j, (p i * p j - q i * q j) * ((x i - x j) * (y i - y j)) := by
    have h1 := wcov_eq_half_double_sum (p := p) (x := x) (y := y) hp
    have h2 := wcov_eq_half_double_sum (p := q) (x := x) (y := y) hq
    have : ∑ i, ∑ j, (p i * p j - q i * q j) * ((x i - x j) * (y i - y j))
        = (∑ i, ∑ j, p i * p j * ((x i - x j) * (y i - y j)))
          - ∑ i, ∑ j, q i * q j * ((x i - x j) * (y i - y j)) := by
      rw [← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun i _ => ?_
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun j _ => by ring
    rw [this, ← h1, ← h2]; ring
  have habs : |(2 : ℝ) * (wcov p x y - wcov q x y)|
      ≤ Mx * My * ∑ i, ∑ j, |p i * p j - q i * q j| := by
    rw [hdiff]
    refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun i _ => ?_
    refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun j _ => ?_
    rw [abs_mul, abs_mul]
    have h1 : |x i - x j| * |y i - y j| ≤ Mx * My :=
      mul_le_mul (hx i j) (hy i j) (abs_nonneg _) hMx
    calc |p i * p j - q i * q j| * (|x i - x j| * |y i - y j|)
        ≤ |p i * p j - q i * q j| * (Mx * My) :=
          mul_le_mul_of_nonneg_left h1 (abs_nonneg _)
      _ = Mx * My * |p i * p j - q i * q j| := by ring
  have hl1 := pair_mass_l1 hp0 hq0 hp hq
  have hMM : 0 ≤ Mx * My := mul_nonneg hMx hMy
  have : |(2 : ℝ) * (wcov p x y - wcov q x y)| ≤ Mx * My * (2 * ∑ i, |p i - q i|) :=
    habs.trans (mul_le_mul_of_nonneg_left hl1 hMM)
  rw [abs_mul] at this
  simp only [abs_two] at this
  linarith

end Stability

end Catalog.UniformDial