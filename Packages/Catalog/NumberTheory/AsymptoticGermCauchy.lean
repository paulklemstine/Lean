import Mathlib
import Catalog.NumberTheory.AsymptoticGermInterpretation

/-!
# The Cauchy product: multiplicativity, and why the fragment is not a ring

Fourth research cycle on the germ interpretation of the rank scale
(`Catalog.NumberTheory.AsymptoticGermInterpretation`).

Cycles 1–3 established that the germ interpretation of the bounded summable
fragment is an injective, order preserving *linear* map whose defect against
arbitrary functions is exactly the flat germs.  It is natural to ask whether it
is an algebra map.  This cycle answers both halves.

* `BddSeries.evalT_mul` / `BddSeries.eval_mul_eventually` — **the interpretation
  is multiplicative for the formal Cauchy product**: the germ of the Cauchy
  product is the product of the germs.
* `BddSeries.abs_convCoeff_le` — the Cauchy product coefficients obey only the
  linear-in-`n` bound `(n+1)·M·M'`.
* `BddSeries.convCoeff_unbounded` — and that is best possible: the all-ones
  series squared has coefficients `n+1`, so **the bounded fragment is not closed
  under the Cauchy product**.  The germ interpretation is therefore an algebra
  map into germs, but its source is a module, not a ring: the correct
  multiplicatively closed source is a geometrically bounded fragment.
-/

namespace Catalog.NumberTheory.AsymptoticGerm

open Filter Asymptotics
open scoped Topology

namespace BddSeries

/-- The formal Cauchy product of the coefficient sequences of two series. -/
def convCoeff (c d : BddSeries) (n : ℕ) : ℝ :=
  ∑ p ∈ Finset.antidiagonal n, c.coeff p.1 * d.coeff p.2

lemma summable_norm_term (c : BddSeries) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) :
    Summable (fun n => ‖c.coeff n * t ^ n‖) := by
  have h := (c.summable_term ht0 ht1).abs
  simpa [Real.norm_eq_abs] using h

/-- **Multiplicativity of the interpretation.**  On the region of convergence the
product of two germs is the germ of the formal Cauchy product. -/
theorem evalT_mul (c d : BddSeries) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) :
    c.evalT t * d.evalT t = ∑' n, convCoeff c d n * t ^ n := by
  have hc := c.summable_norm_term ht0 ht1
  have hd := d.summable_norm_term ht0 ht1
  have hcauchy := tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm hc hd
  rw [evalT, evalT, hcauchy]
  congr 1
  funext n
  rw [convCoeff, Finset.sum_mul]
  refine Finset.sum_congr rfl ?_
  intro p hp
  have hp' : p.1 + p.2 = n := Finset.mem_antidiagonal.mp hp
  rw [← hp', pow_add]
  ring

/-- The germ-level form of multiplicativity. -/
theorem eval_mul_eventually (c d : BddSeries) :
    ∀ᶠ x : ℝ in atTop, c.eval x * d.eval x = ∑' n, convCoeff c d n * (x⁻¹) ^ n := by
  filter_upwards [eventually_gt_atTop (1 : ℝ)] with x hx
  have hx0 : (0 : ℝ) < x := by linarith
  have h0 : (0 : ℝ) ≤ x⁻¹ := (inv_pos.mpr hx0).le
  have h1 : x⁻¹ < 1 := by
    rw [inv_lt_one_iff₀]
    right; exact hx
  exact evalT_mul c d h0 h1

/-- The Cauchy product coefficients satisfy only a linear-in-`n` bound. -/
theorem abs_convCoeff_le (c d : BddSeries) (n : ℕ) :
    |convCoeff c d n| ≤ (n + 1) * (c.bound * d.bound) := by
  have hstep : ∀ p ∈ Finset.antidiagonal n, |c.coeff p.1 * d.coeff p.2| ≤ c.bound * d.bound := by
    intro p _
    rw [abs_mul]
    exact mul_le_mul (c.le_bound p.1) (d.le_bound p.2) (abs_nonneg _) c.bound_nonneg
  calc |convCoeff c d n| ≤ ∑ p ∈ Finset.antidiagonal n, |c.coeff p.1 * d.coeff p.2| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _p ∈ Finset.antidiagonal n, c.bound * d.bound := Finset.sum_le_sum hstep
    _ = (n + 1) * (c.bound * d.bound) := by
        rw [Finset.sum_const, Finset.Nat.card_antidiagonal, nsmul_eq_mul]
        push_cast
        ring

/-- The all-ones series, the extremal element of the bounded fragment. -/
def ones : BddSeries := ⟨fun _ => 1, 1, fun _ => by norm_num⟩

@[simp] lemma convCoeff_ones (n : ℕ) : convCoeff ones ones n = (n : ℝ) + 1 := by
  rw [convCoeff]
  simp [ones, Finset.Nat.card_antidiagonal]

/-- **The bounded fragment is not closed under the Cauchy product.**  Squaring the
all-ones series produces the unbounded coefficient sequence `n ↦ n + 1`. -/
theorem convCoeff_unbounded : ¬ ∃ M : ℝ, ∀ n : ℕ, |convCoeff ones ones n| ≤ M := by
  rintro ⟨M, hM⟩
  obtain ⟨n, hn⟩ := exists_nat_gt M
  have h := hM n
  rw [convCoeff_ones, abs_of_nonneg (by positivity)] at h
  linarith

/-- Consequently the germ interpretation, although multiplicative, cannot be a
ring homomorphism *with source the bounded fragment*: the product of two germs of
the fragment need not itself be the germ of a fragment element with the Cauchy
coefficients. -/
theorem no_bddSeries_with_conv_ones_coeff :
    ¬ ∃ e : BddSeries, e.coeff = convCoeff ones ones := by
  rintro ⟨e, he⟩
  exact convCoeff_unbounded ⟨e.bound, fun n => by rw [← he]; exact e.le_bound n⟩

end BddSeries

end Catalog.NumberTheory.AsymptoticGerm