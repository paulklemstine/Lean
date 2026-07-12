import Mathlib

/-!
# The limit law for descendants in random `d`-DAGs: the Gamma target distribution

In the random recursive DAG `G_n` with out-degree `d ≥ 2`, the rescaled number of
descendants `|D_n| / n^{1/d}` converges in distribution to a **Gamma distribution with
shape parameter `d` and rate parameter `1`** (Janson, 2023).

This file develops, fully formally, the *target* of that convergence: the Gamma`(d, 1)`
distribution, its density, and — most importantly for the method of moments used to prove
such limit theorems — the complete description of its moments.

The main results are:

* `gammaDensity_integral` : the Gamma`(d,1)` density integrates to `1` (it is a genuine
  probability density);
* `gammaMoment_eq_integral` : the `p`-th moment of the density equals `Γ(d+p)/Γ(d)`;
* `gammaMoment_succ` : the moment recurrence `m_{p+1} = (d+p)·m_p`, which is the exact
  characterisation used in method-of-moments proofs of convergence to Gamma`(d,1)`;
* `gammaMoment_nat_eq_prod` : the integer moments are the rising factorials
  `∏_{i<k} (d+i)`;
* `gammaMoment_one` / `gamma_variance` : the mean is `d` and the variance is `d`.

All densities and moments are taken with respect to Lebesgue measure on `(0, ∞)`.
-/

open Real MeasureTheory
open scoped Real

namespace DDAG

/-- The probability density of the Gamma distribution with shape `d > 0` and rate `1`,
`f(x) = e^{-x} · x^{d-1} / Γ(d)` on `(0, ∞)`. -/
noncomputable def gammaDensity (d x : ℝ) : ℝ := Real.exp (-x) * x ^ (d - 1) / Real.Gamma d

/-- The `p`-th moment of the Gamma`(d,1)` distribution, `Γ(d+p)/Γ(d)`.
For `d = shape` this is exactly the limiting moment of `|D_n| / n^{1/d}`. -/
noncomputable def gammaMoment (d p : ℝ) : ℝ := Real.Gamma (d + p) / Real.Gamma d

/-
The Gamma density is nonnegative on the positive half-line.
-/
lemma gammaDensity_nonneg {d : ℝ} (hd : 0 < d) {x : ℝ} (hx : 0 ≤ x) :
    0 ≤ gammaDensity d x := by
  exact div_nonneg ( mul_nonneg ( Real.exp_nonneg _ ) ( Real.rpow_nonneg hx _ ) ) ( Real.Gamma_nonneg_of_nonneg hd.le )

/-
The core moment computation: the `p`-th moment of the Gamma`(d,1)` density,
`∫₀^∞ x^p f(x) dx`, equals `Γ(d+p)/Γ(d)`.
-/
theorem gammaMoment_eq_integral {d p : ℝ} (hd : 0 < d) (hp : 0 ≤ p) :
    ∫ x in Set.Ioi (0 : ℝ), x ^ p * gammaDensity d x = gammaMoment d p := by
  unfold gammaDensity gammaMoment;
  rw [ Real.Gamma_eq_integral ( by linarith : 0 < d + p ) ];
  rw [ ← MeasureTheory.integral_div ] ; refine' MeasureTheory.setIntegral_congr_fun measurableSet_Ioi fun x hx => _ ; rw [ show d + p - 1 = p + ( d - 1 ) by ring, Real.rpow_add hx ] ; ring;

/-
The Gamma`(d,1)` density integrates to `1`; it is a genuine probability density.
-/
theorem gammaDensity_integral {d : ℝ} (hd : 0 < d) :
    ∫ x in Set.Ioi (0 : ℝ), gammaDensity d x = 1 := by
  have h_gamma_int : ∫ x in Set.Ioi 0, x ^ (d - 1) * Real.exp (-x) = Real.Gamma d := by
    simp +decide only [Gamma_eq_integral hd, mul_comm];
  rw [ show gammaDensity d = fun x => x ^ ( d - 1 ) * Real.exp ( -x ) / Real.Gamma d by ext; unfold gammaDensity; ring, MeasureTheory.integral_div, h_gamma_int, div_self ( ne_of_gt ( Real.Gamma_pos_of_pos hd ) ) ]

/-
The zeroth moment is `1`.
-/
@[simp] lemma gammaMoment_zero {d : ℝ} (hd : 0 < d) : gammaMoment d 0 = 1 := by
  unfold gammaMoment; norm_num [ ne_of_gt ( Real.Gamma_pos_of_pos hd ) ] ;

/-
The **moment recurrence** `m_{p+1} = (d + p) · m_p`.
This is the identity that pins down the Gamma`(d,1)` law in method-of-moments arguments.
-/
theorem gammaMoment_succ {d p : ℝ} (hd : 0 < d) (hp : 0 ≤ p) :
    gammaMoment d (p + 1) = (d + p) * gammaMoment d p := by
  unfold gammaMoment;
  rw [ ← mul_div_assoc, ← add_assoc, Real.Gamma_add_one ( by linarith ), mul_comm ]

/-
The integer moments are rising factorials: `m_k = ∏_{i<k} (d + i)`.
-/
theorem gammaMoment_nat_eq_prod {d : ℝ} (hd : 0 < d) (k : ℕ) :
    gammaMoment d k = ∏ i ∈ Finset.range k, (d + i) := by
  induction' k with k ih;
  · norm_num [ gammaMoment_zero hd ];
  · simp_all +decide [ Finset.prod_range_succ ];
    rw [ ← ih, mul_comm, gammaMoment_succ hd ( Nat.cast_nonneg k ) ]

/-
The mean of Gamma`(d,1)` is `d`.
-/
theorem gammaMoment_one {d : ℝ} (hd : 0 < d) : gammaMoment d 1 = d := by
  convert gammaMoment_succ hd ( show 0 ≤ 0 by linarith ) using 1;
  · norm_num;
  · norm_num [ gammaMoment_zero hd ]

/-
The second moment of Gamma`(d,1)` is `d(d+1)`.
-/
theorem gammaMoment_two {d : ℝ} (hd : 0 < d) : gammaMoment d 2 = d * (d + 1) := by
  convert gammaMoment_succ hd zero_le_one using 1 <;> norm_num [ gammaMoment_one hd ] ; ring!;

/-
The variance of Gamma`(d,1)` is `d` (second moment minus mean squared).
-/
theorem gamma_variance {d : ℝ} (hd : 0 < d) :
    gammaMoment d 2 - (gammaMoment d 1) ^ 2 = d := by
  rw [ gammaMoment_two, gammaMoment_one ] <;> nlinarith

end DDAG