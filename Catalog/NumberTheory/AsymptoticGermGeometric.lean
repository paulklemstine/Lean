import Mathlib
import Catalog.NumberTheory.AsymptoticGermInterpretation

/-!
# The geometric fragment: a multiplicatively closed germ interpretation

Fifth research cycle on the germ interpretation of the rank scale.

Cycle 4 (`Catalog.NumberTheory.AsymptoticGermCauchy`) showed that the bounded
fragment `BddSeries` is *not* closed under the Cauchy product, although the germ
interpretation is multiplicative wherever both sides make sense.  The defect is
in the choice of norm on coefficient space, not in the interpretation.  Here we
fix it.

`GeoSeries` is the fragment of formal series `∑ₙ aₙ x⁻ⁿ` with geometrically
bounded coefficients `|aₙ| ≤ M ρⁿ`; such a series converges for `x > ρ`.

* `GeoSeries.tail_bound`, `GeoSeries.eval_hasExpansion` — the analytic core,
  generalising cycle 1 from `ρ = 1` to arbitrary `ρ > 0`.
* `GeoSeries.eval_eventuallyEq_iff` — the interpretation is still injective.
* `GeoSeries.mulG` — **the geometric fragment is closed under the Cauchy
  product** (with the ratio doubled), and
  `GeoSeries.eval_mulG_eventually` shows the interpretation carries it to the
  pointwise product of germs.
* `GeoSeries.mul_hasExpansion` — consequently the asymptotic expansion of a
  product of two fragment germs is the Cauchy product of their expansions.
-/

namespace Catalog.NumberTheory.AsymptoticGerm

open Filter Asymptotics
open scoped Topology

/-- A formal series `∑ₙ coeff n · x⁻ⁿ` with geometrically bounded coefficients
`|coeff n| ≤ bound · ratioⁿ`. -/
structure GeoSeries where
  coeff : ℕ → ℝ
  bound : ℝ
  ratio : ℝ
  ratio_pos : 0 < ratio
  le_bound : ∀ n, |coeff n| ≤ bound * ratio ^ n

namespace GeoSeries

lemma bound_nonneg (c : GeoSeries) : 0 ≤ c.bound := by
  have := c.le_bound 0
  simpa using le_trans (abs_nonneg _) this

/-- Evaluation in the variable `t = x⁻¹`. -/
noncomputable def evalT (c : GeoSeries) (t : ℝ) : ℝ := ∑' n, c.coeff n * t ^ n

/-- The germ of the series at `+∞`. -/
noncomputable def eval (c : GeoSeries) (x : ℝ) : ℝ := c.evalT x⁻¹

lemma abs_term_le (c : GeoSeries) {t : ℝ} (ht0 : 0 ≤ t) (n : ℕ) :
    |c.coeff n * t ^ n| ≤ c.bound * (c.ratio * t) ^ n := by
  rw [abs_mul, abs_pow, abs_of_nonneg ht0, mul_pow, ← mul_assoc]
  exact mul_le_mul_of_nonneg_right (c.le_bound n) (pow_nonneg ht0 n)

lemma summable_term (c : GeoSeries) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : c.ratio * t < 1) :
    Summable (fun n => c.coeff n * t ^ n) := by
  have hr0 : 0 ≤ c.ratio * t := mul_nonneg c.ratio_pos.le ht0
  apply Summable.of_norm_bounded (g := fun n => c.bound * (c.ratio * t) ^ n)
    ((summable_geometric_of_lt_one hr0 ht1).mul_left _)
  intro n
  simpa [Real.norm_eq_abs] using c.abs_term_le ht0 n

/-- The quantitative tail bound on the geometric fragment. -/
lemma tail_bound (c : GeoSeries) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : c.ratio * t < 1) (k : ℕ) :
    |c.evalT t - ∑ n ∈ Finset.range k, c.coeff n * t ^ n|
      ≤ c.bound * (c.ratio * t) ^ k / (1 - c.ratio * t) := by
  have hr0 : 0 ≤ c.ratio * t := mul_nonneg c.ratio_pos.le ht0
  have h := abs_tsum_sub_sum_le (c.summable_term ht0 ht1)
    ((summable_geometric_of_lt_one hr0 ht1).mul_left c.bound) (c.abs_term_le ht0) k
  rwa [geom_tail c.bound hr0 ht1 k] at h

/-- **The germ of a geometrically bounded series has the series as its classical
asymptotic expansion.** -/
theorem eval_hasExpansion (c : GeoSeries) : HasExpansion c.eval c.coeff := by
  intro N
  rw [isLittleO_iff]
  intro ε hε
  have hρ := c.ratio_pos
  filter_upwards [eventually_ge_atTop (2 * c.ratio),
    eventually_ge_atTop ((2 * c.bound * c.ratio ^ (N + 1) + 1) / ε),
    eventually_gt_atTop (0 : ℝ)] with x hx1 hx2 hx0
  have ht0 : 0 < x⁻¹ := inv_pos.mpr hx0
  have hxt : x⁻¹ * x = 1 := inv_mul_cancel₀ (ne_of_gt hx0)
  have hρt : c.ratio * x⁻¹ ≤ 1 / 2 := by
    rw [mul_comm, inv_mul_eq_div, div_le_iff₀ hx0]
    linarith
  have hρt0 : 0 ≤ c.ratio * x⁻¹ := mul_nonneg hρ.le ht0.le
  have hρt1 : c.ratio * x⁻¹ < 1 := by linarith
  have htb := c.tail_bound ht0.le hρt1 (N + 1)
  have hgoal : c.eval x - ∑ n ∈ Finset.range (N + 1), c.coeff n * monoN n x
      = c.evalT x⁻¹ - ∑ n ∈ Finset.range (N + 1), c.coeff n * x⁻¹ ^ n := by
    simp [eval, monoN]
  have hmono : |monoN N x| = x⁻¹ ^ N := by
    rw [monoN, abs_pow, abs_of_nonneg ht0.le]
  rw [Real.norm_eq_abs, Real.norm_eq_abs, hgoal, hmono]
  refine htb.trans ?_
  have hpowN : (0 : ℝ) ≤ x⁻¹ ^ N := pow_nonneg ht0.le N
  have hnn : 0 ≤ c.bound * (c.ratio * x⁻¹) ^ (N + 1) :=
    mul_nonneg c.bound_nonneg (pow_nonneg hρt0 _)
  have hstep1 : c.bound * (c.ratio * x⁻¹) ^ (N + 1) / (1 - c.ratio * x⁻¹)
      ≤ 2 * (c.bound * (c.ratio * x⁻¹) ^ (N + 1)) := by
    rw [div_le_iff₀ (by linarith)]
    nlinarith
  have hcoef : 2 * c.bound * c.ratio ^ (N + 1) * x⁻¹ ≤ ε := by
    have h1 : 2 * c.bound * c.ratio ^ (N + 1) + 1 ≤ ε * x := by
      rw [div_le_iff₀ hε] at hx2; linarith
    nlinarith [mul_le_mul_of_nonneg_left h1 ht0.le]
  calc c.bound * (c.ratio * x⁻¹) ^ (N + 1) / (1 - c.ratio * x⁻¹)
      ≤ 2 * (c.bound * (c.ratio * x⁻¹) ^ (N + 1)) := hstep1
    _ = (2 * c.bound * c.ratio ^ (N + 1) * x⁻¹) * x⁻¹ ^ N := by
        rw [mul_pow, pow_succ x⁻¹ N]; ring
    _ ≤ ε * x⁻¹ ^ N := mul_le_mul_of_nonneg_right hcoef hpowN

/-- The interpretation remains injective on the geometric fragment. -/
theorem eval_eventuallyEq_iff (c d : GeoSeries) :
    c.eval =ᶠ[atTop] d.eval ↔ c.coeff = d.coeff := by
  constructor
  · intro h
    exact expansion_unique (c.eval_hasExpansion)
      ((d.eval_hasExpansion).congr_germ h.symm)
  · intro h
    exact EventuallyEq.of_eq (by funext x; simp only [eval, evalT, h])

/-! ## Closure under the Cauchy product -/

/-- The formal Cauchy product of the coefficient sequences. -/
def convCoeff (c d : GeoSeries) (n : ℕ) : ℝ :=
  ∑ p ∈ Finset.antidiagonal n, c.coeff p.1 * d.coeff p.2

/-- The Cauchy product coefficients are bounded by a *linear* multiple of the
common geometric rate. -/
lemma abs_convCoeff_le_linear (c d : GeoSeries) (n : ℕ) :
    |convCoeff c d n|
      ≤ ((n : ℝ) + 1) * ((c.bound * d.bound) * (max c.ratio d.ratio) ^ n) := by
  set ρ := max c.ratio d.ratio with hρdef
  have hρ : 0 < ρ := lt_of_lt_of_le c.ratio_pos (le_max_left _ _)
  have hterm : ∀ p ∈ Finset.antidiagonal n,
      |c.coeff p.1 * d.coeff p.2| ≤ (c.bound * d.bound) * ρ ^ n := by
    intro p hp
    have hp' : p.1 + p.2 = n := Finset.mem_antidiagonal.mp hp
    have h1 : |c.coeff p.1| ≤ c.bound * ρ ^ p.1 :=
      (c.le_bound p.1).trans (mul_le_mul_of_nonneg_left
        (pow_le_pow_left₀ c.ratio_pos.le (le_max_left _ _) _) c.bound_nonneg)
    have h2 : |d.coeff p.2| ≤ d.bound * ρ ^ p.2 :=
      (d.le_bound p.2).trans (mul_le_mul_of_nonneg_left
        (pow_le_pow_left₀ d.ratio_pos.le (le_max_right _ _) _) d.bound_nonneg)
    rw [abs_mul]
    calc |c.coeff p.1| * |d.coeff p.2| ≤ (c.bound * ρ ^ p.1) * (d.bound * ρ ^ p.2) :=
          mul_le_mul h1 h2 (abs_nonneg _) (mul_nonneg c.bound_nonneg (pow_nonneg hρ.le _))
      _ = (c.bound * d.bound) * ρ ^ n := by rw [← hp', pow_add]; ring
  calc |convCoeff c d n| ≤ ∑ p ∈ Finset.antidiagonal n, |c.coeff p.1 * d.coeff p.2| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _p ∈ Finset.antidiagonal n, (c.bound * d.bound) * ρ ^ n := Finset.sum_le_sum hterm
    _ = ((n : ℝ) + 1) * ((c.bound * d.bound) * ρ ^ n) := by
        rw [Finset.sum_const, Finset.Nat.card_antidiagonal, nsmul_eq_mul]
        push_cast
        ring

lemma abs_convCoeff_le (c d : GeoSeries) (n : ℕ) :
    |convCoeff c d n| ≤ (c.bound * d.bound) * (2 * max c.ratio d.ratio) ^ n := by
  have hρ : 0 < max c.ratio d.ratio := lt_of_lt_of_le c.ratio_pos (le_max_left _ _)
  have hcard : ((n : ℝ) + 1) ≤ 2 ^ n := by
    have h : n < 2 ^ n := Nat.lt_two_pow_self
    have h' : (n : ℝ) + 1 ≤ ((2 ^ n : ℕ) : ℝ) := by exact_mod_cast h
    simpa using h'
  calc |convCoeff c d n|
      ≤ ((n : ℝ) + 1) * ((c.bound * d.bound) * (max c.ratio d.ratio) ^ n) :=
        abs_convCoeff_le_linear c d n
    _ ≤ 2 ^ n * ((c.bound * d.bound) * (max c.ratio d.ratio) ^ n) :=
        mul_le_mul_of_nonneg_right hcard
          (mul_nonneg (mul_nonneg c.bound_nonneg d.bound_nonneg) (pow_nonneg hρ.le n))
    _ = (c.bound * d.bound) * (2 * max c.ratio d.ratio) ^ n := by rw [mul_pow]; ring

/-- **The geometric fragment is closed under the Cauchy product**, at the cost of
doubling the ratio. -/
def mulG (c d : GeoSeries) : GeoSeries where
  coeff := convCoeff c d
  bound := c.bound * d.bound
  ratio := 2 * max c.ratio d.ratio
  ratio_pos := by
    have : 0 < max c.ratio d.ratio := lt_of_lt_of_le c.ratio_pos (le_max_left _ _)
    linarith
  le_bound := abs_convCoeff_le c d

@[simp] lemma mulG_coeff (c d : GeoSeries) : (mulG c d).coeff = convCoeff c d := rfl

/-- Multiplicativity of the interpretation on the geometric fragment. -/
theorem evalT_mulG (c d : GeoSeries) {t : ℝ} (ht0 : 0 ≤ t)
    (hc : c.ratio * t < 1) (hd : d.ratio * t < 1) :
    (mulG c d).evalT t = c.evalT t * d.evalT t := by
  have hcn : Summable (fun n => ‖c.coeff n * t ^ n‖) := by
    simpa [Real.norm_eq_abs] using (c.summable_term ht0 hc).abs
  have hdn : Summable (fun n => ‖d.coeff n * t ^ n‖) := by
    simpa [Real.norm_eq_abs] using (d.summable_term ht0 hd).abs
  rw [evalT, evalT, evalT, tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm hcn hdn]
  congr 1
  funext n
  rw [mulG_coeff, convCoeff, Finset.sum_mul]
  refine Finset.sum_congr rfl ?_
  intro p hp
  have hp' : p.1 + p.2 = n := Finset.mem_antidiagonal.mp hp
  rw [← hp', pow_add]
  ring

/-- The germ-level form of multiplicativity. -/
theorem eval_mulG_eventually (c d : GeoSeries) :
    ∀ᶠ x : ℝ in atTop, (mulG c d).eval x = c.eval x * d.eval x := by
  filter_upwards [eventually_gt_atTop (max c.ratio d.ratio),
    eventually_gt_atTop (0 : ℝ)] with x hx hx0
  have ht0 : 0 < x⁻¹ := inv_pos.mpr hx0
  have hc : c.ratio * x⁻¹ < 1 := by
    rw [mul_comm, inv_mul_eq_div, div_lt_one hx0]
    exact lt_of_le_of_lt (le_max_left _ _) hx
  have hd : d.ratio * x⁻¹ < 1 := by
    rw [mul_comm, inv_mul_eq_div, div_lt_one hx0]
    exact lt_of_le_of_lt (le_max_right _ _) hx
  exact evalT_mulG c d ht0.le hc hd

/-- **The asymptotic expansion of a product is the Cauchy product of the
expansions.** -/
theorem mul_hasExpansion (c d : GeoSeries) :
    HasExpansion (fun x => c.eval x * d.eval x) (convCoeff c d) := by
  have h := (mulG c d).eval_hasExpansion
  rw [mulG_coeff] at h
  exact h.congr_germ (eval_mulG_eventually c d)

/-! ## Sharpness of the ratio inflation -/

/-- A Bernoulli-type bound: for `q > 1` the linear factor `n + 1` is absorbed by
`q ^ n` at the cost of a constant. -/
lemma succ_le_const_mul_pow {q : ℝ} (hq : 1 < q) (n : ℕ) :
    (n : ℝ) + 1 ≤ (1 + 1 / (q - 1)) * q ^ n := by
  have hq1 : 0 < q - 1 := by linarith
  have hbern : 1 + (n : ℝ) * (q - 1) ≤ q ^ n := by
    have h := one_add_mul_le_pow (a := q - 1) (by linarith) n
    simpa using h
  have hKpos : (0 : ℝ) < 1 + 1 / (q - 1) := by positivity
  have hK : (1 : ℝ) ≤ 1 + 1 / (q - 1) := by
    have : 0 < 1 / (q - 1) := by positivity
    linarith
  have hexp : (1 + 1 / (q - 1)) * (1 + (n : ℝ) * (q - 1)) = (1 + 1 / (q - 1)) + n * q := by
    field_simp
    ring
  have h1 : (n : ℝ) + 1 ≤ (1 + 1 / (q - 1)) * (1 + (n : ℝ) * (q - 1)) := by
    rw [hexp]
    nlinarith [Nat.cast_nonneg (α := ℝ) n]
  exact h1.trans (mul_le_mul_of_nonneg_left hbern hKpos.le)

/-- **The ratio inflation can be made arbitrarily small.**  For any rate strictly
larger than the common rate of the two factors, the Cauchy product is
geometrically bounded at that rate. -/
theorem convCoeff_geometric_bound (c d : GeoSeries) {r : ℝ}
    (hr : max c.ratio d.ratio < r) : ∃ M : ℝ, ∀ n, |convCoeff c d n| ≤ M * r ^ n := by
  set ρ := max c.ratio d.ratio with hρdef
  have hρ : 0 < ρ := lt_of_lt_of_le c.ratio_pos (le_max_left _ _)
  have hq : 1 < r / ρ := (one_lt_div hρ).mpr hr
  refine ⟨(1 + 1 / (r / ρ - 1)) * (c.bound * d.bound), fun n => ?_⟩
  have hBnn : 0 ≤ (c.bound * d.bound) * ρ ^ n :=
    mul_nonneg (mul_nonneg c.bound_nonneg d.bound_nonneg) (pow_nonneg hρ.le n)
  have hpow : (r / ρ) ^ n * ρ ^ n = r ^ n := by
    rw [div_pow, div_mul_cancel₀]
    exact pow_ne_zero _ (ne_of_gt hρ)
  calc |convCoeff c d n| ≤ ((n : ℝ) + 1) * ((c.bound * d.bound) * ρ ^ n) :=
        abs_convCoeff_le_linear c d n
    _ ≤ ((1 + 1 / (r / ρ - 1)) * (r / ρ) ^ n) * ((c.bound * d.bound) * ρ ^ n) :=
        mul_le_mul_of_nonneg_right (succ_le_const_mul_pow hq n) hBnn
    _ = ((1 + 1 / (r / ρ - 1)) * (c.bound * d.bound)) * r ^ n := by rw [← hpow]; ring

/-- The all-ones series, at geometric rate `1`. -/
def onesG : GeoSeries := ⟨fun _ => 1, 1, 1, one_pos, fun n => by norm_num⟩

@[simp] lemma convCoeff_onesG (n : ℕ) : convCoeff onesG onesG n = (n : ℝ) + 1 := by
  rw [convCoeff]
  simp [onesG, Finset.Nat.card_antidiagonal]

/-- **But the inflation cannot be removed.**  At the *same* rate as the factors
the Cauchy product leaves the fragment: squaring the all-ones series of rate `1`
gives the coefficients `n + 1`, which admit no bound `M · 1ⁿ`.  Together with
`convCoeff_geometric_bound` this pins the closure property down exactly: the
geometric fragments form a directed system closed under products, but no single
rate is preserved. -/
theorem convCoeff_ratio_not_attained :
    ¬ ∃ M : ℝ, ∀ n : ℕ, |convCoeff onesG onesG n| ≤ M * onesG.ratio ^ n := by
  rintro ⟨M, hM⟩
  obtain ⟨n, hn⟩ := exists_nat_gt M
  have h := hM n
  rw [convCoeff_onesG, abs_of_nonneg (by positivity)] at h
  simp only [onesG, one_pow, mul_one] at h
  linarith

end GeoSeries

end Catalog.NumberTheory.AsymptoticGerm