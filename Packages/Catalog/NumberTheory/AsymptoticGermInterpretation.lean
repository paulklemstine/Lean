import Mathlib

/-!
# Asymptotic comparison beyond coefficient extensionality

A formal series `∑ aₙ xⁿ`-style statement (Hahn / Laurent series with
coefficients on ranks) is an *exact* algebraic object: two such series are equal
exactly when all their coefficients agree.  Passing to analysis, one is tempted
to read this as "two functions with the same asymptotic expansion are equal".
**That reading is false.**  This file makes both halves precise.

## The rank scale

Ranks are integers, and the monomial of rank `r` is the germ at `+∞` of
`x ↦ x ^ r` (`monoZ`).  We prove

* `monoZ_isLittleO_of_lt` — *smaller ranks are asymptotically negligible
  relative to larger ranks*: `r < s → monoZ r =o[atTop] monoZ s`.

The decaying part of the scale, `monoN n x = x⁻¹ ^ n = monoZ (-n) x`, carries the
convergent fragment.

## The convergent fragment

`BddSeries` is the fragment of formal series `∑ₙ aₙ x⁻ⁿ` with *bounded*
coefficients.  Such a series converges for `x > 1`, giving a germ
`BddSeries.eval : ℝ → ℝ` at `+∞`.  The quantitative heart is
`BddSeries.tail_bound`.

* `BddSeries.eventually_pos_of_leading` / `eventually_neg_of_leading` /
  `eventually_sign` — *the leading nonzero monomial controls the eventual sign*.
* `BddSeries.eval_hasExpansion` — the germ really has the formal series as its
  classical asymptotic expansion.
* `expansion_unique` — asymptotic expansions have unique coefficients.
* `BddSeries.eval_eventuallyEq_iff` — *the interpretation is injective on the
  fragment*, and conversely formal agreement at all ranks implies equality of
  eventual germs.

## The boundary: flat functions

* `exp_neg_isLittleO_monoN` — `e^{-x}` is negligible against every rank.
* `expansion_not_germ_injective` — two functions with identical expansions to all
  orders that are *not* eventually equal.  So `expansion_unique` cannot be
  upgraded to a statement about arbitrary functions; the formal principle is
  strictly weaker than the analytic claim.
* `BddSeries.exp_neg_not_eval` — no bounded series represents the flat germ.

-/

namespace Catalog.NumberTheory.AsymptoticGerm

open Filter Asymptotics
open scoped Topology

/-! ## Generic tail estimates -/

/-- Comparison of the tail of a real series with a dominating series. -/
lemma abs_tsum_sub_sum_le {f g : ℕ → ℝ} (hf : Summable f) (hg : Summable g)
    (hk : ∀ i, |f i| ≤ g i) (k : ℕ) :
    |(∑' n, f n) - ∑ n ∈ Finset.range k, f n| ≤ (∑' n, g n) - ∑ n ∈ Finset.range k, g n := by
  have h1 : (∑' n, f n) - ∑ n ∈ Finset.range k, f n = ∑' i, f (i + k) := by
    have := hf.sum_add_tsum_nat_add k; linarith
  have h2 : (∑' n, g n) - ∑ n ∈ Finset.range k, g n = ∑' i, g (i + k) := by
    have := hg.sum_add_tsum_nat_add k; linarith
  rw [h1, h2]
  have hfk : Summable (fun i => f (i + k)) := (summable_nat_add_iff k).mpr hf
  have hgk : Summable (fun i => g (i + k)) := (summable_nat_add_iff k).mpr hg
  have hnorm : Summable (fun i => ‖f (i + k)‖) := by
    simpa [Real.norm_eq_abs] using hfk.abs
  have hstep := norm_tsum_le_tsum_norm hnorm
  have habs : Summable (fun i => |f (i + k)|) := by simpa [Real.norm_eq_abs] using hnorm
  calc |∑' i, f (i + k)| ≤ ∑' i, |f (i + k)| := by simpa [Real.norm_eq_abs] using hstep
    _ ≤ ∑' i, g (i + k) := habs.tsum_mono hgk (fun i => hk (i + k))

/-- The geometric tail in closed form. -/
lemma geom_tail (M : ℝ) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) (k : ℕ) :
    (∑' n : ℕ, M * t ^ n) - ∑ n ∈ Finset.range k, M * t ^ n = M * t ^ k / (1 - t) := by
  have h : (1 : ℝ) - t ≠ 0 := by linarith
  have hgeom : ∑ n ∈ Finset.range k, t ^ n = (1 - t ^ k) / (1 - t) := by
    rw [geom_sum_eq (by linarith : t ≠ 1), div_eq_div_iff (by intro hc; apply h; linarith) h]
    ring
  rw [tsum_mul_left, tsum_geometric_of_lt_one ht0 ht1, ← Finset.mul_sum, hgeom]
  field_simp
  ring

/-! ## The rank scale -/

/-- The monomial of integer rank `r`, as a function of `x` near `+∞`. -/
noncomputable def monoZ (r : ℤ) (x : ℝ) : ℝ := x ^ r

/-- The decaying monomial `x⁻¹ ^ n`; it is the monomial of rank `-n`. -/
noncomputable def monoN (n : ℕ) (x : ℝ) : ℝ := x⁻¹ ^ n

lemma monoN_eq_monoZ (n : ℕ) (x : ℝ) : monoN n x = monoZ (-(n : ℤ)) x := by
  simp [monoN, monoZ, zpow_neg, zpow_natCast, inv_pow]

lemma monoN_pos {x : ℝ} (hx : 0 < x) (n : ℕ) : 0 < monoN n x :=
  pow_pos (inv_pos.mpr hx) n

/-- **Smaller ranks are asymptotically negligible relative to larger ranks.** -/
theorem monoZ_isLittleO_of_lt {r s : ℤ} (h : r < s) : monoZ r =o[atTop] monoZ s := by
  have h1 : ∀ᶠ x : ℝ in atTop, monoZ s x = 0 → monoZ r x = 0 := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx hz
    exact absurd hz (zpow_ne_zero _ (ne_of_gt hx))
  rw [isLittleO_iff_tendsto' h1]
  have heq : (fun x : ℝ => monoZ r x / monoZ s x) =ᶠ[atTop] fun x : ℝ => x ^ (r - s) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
    simp [monoZ, zpow_sub₀ (ne_of_gt hx)]
  exact (tendsto_zpow_atTop_zero (by omega : r - s < 0)).congr' heq.symm

/-- In the decaying part of the scale: a higher index (= lower rank) is
negligible against a lower index (= higher rank). -/
theorem monoN_isLittleO_of_lt {n m : ℕ} (h : n < m) : monoN m =o[atTop] monoN n := by
  have hZ := monoZ_isLittleO_of_lt (r := -(m : ℤ)) (s := -(n : ℤ)) (by omega)
  refine hZ.congr' ?_ ?_ <;>
    · filter_upwards with x
      exact (monoN_eq_monoZ _ x).symm

/-! ## Classical asymptotic expansions -/

/-- `f` has the coefficient sequence `a` as its asymptotic expansion at `+∞`
along the scale `x⁻ⁿ`. -/
def HasExpansion (f : ℝ → ℝ) (a : ℕ → ℝ) : Prop :=
  ∀ N : ℕ, (fun x => f x - ∑ n ∈ Finset.range (N + 1), a n * monoN n x) =o[atTop] monoN N

lemma HasExpansion.congr_germ {f g : ℝ → ℝ} {a : ℕ → ℝ} (h : HasExpansion f a)
    (hfg : f =ᶠ[atTop] g) : HasExpansion g a := by
  intro N
  refine (h N).congr' ?_ (EventuallyEq.refl _ _)
  filter_upwards [hfg] with x hx
  rw [hx]

/-- If `C · g` is negligible against `g` (with `g` eventually nonzero), then `C = 0`. -/
lemma eq_zero_of_const_mul_isLittleO {C : ℝ} {g : ℝ → ℝ}
    (hg : ∀ᶠ x : ℝ in atTop, g x ≠ 0) (h : (fun x => C * g x) =o[atTop] g) : C = 0 := by
  by_contra hC
  have hCpos : 0 < |C| := abs_pos.mpr hC
  have hev := (isLittleO_iff.mp h) (show (0:ℝ) < |C| / 2 by linarith)
  obtain ⟨x, hx1, hx2⟩ := (hev.and hg).exists
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_mul] at hx1
  have hgx : 0 < |g x| := abs_pos.mpr hx2
  nlinarith

/-- **Uniqueness of asymptotic expansion coefficients.**  A function determines
its formal expansion along the rank scale. -/
theorem expansion_unique {f : ℝ → ℝ} {a b : ℕ → ℝ}
    (ha : HasExpansion f a) (hb : HasExpansion f b) : a = b := by
  funext N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    have hdiff : (fun x : ℝ => (b N - a N) * monoN N x) =o[atTop] monoN N := by
      have hsub := (ha N).sub (hb N)
      refine hsub.congr' ?_ (EventuallyEq.refl _ _)
      filter_upwards with x
      have hsingle : ∑ n ∈ Finset.range (N + 1), (b n - a n) * monoN n x
          = (b N - a N) * monoN N x := by
        rw [Finset.sum_eq_single N]
        · intro c hc hne
          have hcN : c < N := by have := Finset.mem_range.mp hc; omega
          rw [ih c hcN]
          ring
        · intro h
          exact absurd (Finset.mem_range.mpr (Nat.lt_succ_self N)) h
      rw [← hsingle]
      simp only [sub_mul]
      rw [Finset.sum_sub_distrib]
      ring
    have hne : ∀ᶠ x : ℝ in atTop, monoN N x ≠ 0 := by
      filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
      exact ne_of_gt (monoN_pos hx N)
    have := eq_zero_of_const_mul_isLittleO hne hdiff
    linarith

/-! ## The convergent fragment -/

/-- A formal series `∑ₙ coeff n · x⁻ⁿ` with uniformly bounded coefficients.
This is the normalized, summable fragment on which the germ interpretation is
defined. -/
structure BddSeries where
  coeff : ℕ → ℝ
  bound : ℝ
  le_bound : ∀ n, |coeff n| ≤ bound

namespace BddSeries

lemma bound_nonneg (c : BddSeries) : 0 ≤ c.bound := le_trans (abs_nonneg _) (c.le_bound 0)

instance : Neg BddSeries := ⟨fun c => ⟨-c.coeff, c.bound, by intro n; simpa using c.le_bound n⟩⟩

instance : Sub BddSeries := ⟨fun c d => ⟨c.coeff - d.coeff, c.bound + d.bound, by
  intro n
  simp only [Pi.sub_apply]
  exact (abs_sub _ _).trans (add_le_add (c.le_bound n) (d.le_bound n))⟩⟩

@[simp] lemma neg_coeff (c : BddSeries) : (-c).coeff = -c.coeff := rfl
@[simp] lemma sub_coeff (c d : BddSeries) : (c - d).coeff = c.coeff - d.coeff := rfl

lemma summable_term (c : BddSeries) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) :
    Summable (fun n => c.coeff n * t ^ n) := by
  apply Summable.of_norm_bounded (g := fun n => c.bound * t ^ n)
    ((summable_geometric_of_lt_one ht0 ht1).mul_left _)
  intro n
  rw [norm_mul, Real.norm_eq_abs, Real.norm_eq_abs, abs_pow, abs_of_nonneg ht0]
  exact mul_le_mul_of_nonneg_right (c.le_bound n) (pow_nonneg ht0 n)

/-- Evaluation in the variable `t = x⁻¹`. -/
noncomputable def evalT (c : BddSeries) (t : ℝ) : ℝ := ∑' n, c.coeff n * t ^ n

/-- The germ of the series at `+∞`. -/
noncomputable def eval (c : BddSeries) (x : ℝ) : ℝ := c.evalT x⁻¹

lemma evalT_neg (c : BddSeries) (t : ℝ) : (-c).evalT t = -c.evalT t := by
  simp only [evalT, neg_coeff, Pi.neg_apply, neg_mul]
  exact tsum_neg

lemma eval_neg (c : BddSeries) (x : ℝ) : (-c).eval x = -c.eval x := evalT_neg c _

lemma evalT_sub (c d : BddSeries) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) :
    (c - d).evalT t = c.evalT t - d.evalT t := by
  simp only [evalT, sub_coeff, Pi.sub_apply, sub_mul]
  exact (c.summable_term ht0 ht1).tsum_sub (d.summable_term ht0 ht1)

/-- **The quantitative tail bound**: truncating the series at rank `-k` costs at
most `bound · tᵏ / (1 - t)`. -/
lemma tail_bound (c : BddSeries) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) (k : ℕ) :
    |c.evalT t - ∑ n ∈ Finset.range k, c.coeff n * t ^ n| ≤ c.bound * t ^ k / (1 - t) := by
  have hb : ∀ i, |c.coeff i * t ^ i| ≤ c.bound * t ^ i := by
    intro i
    rw [abs_mul, abs_pow, abs_of_nonneg ht0]
    exact mul_le_mul_of_nonneg_right (c.le_bound i) (pow_nonneg ht0 i)
  have h := abs_tsum_sub_sum_le (c.summable_term ht0 ht1)
    ((summable_geometric_of_lt_one ht0 ht1).mul_left c.bound) hb k
  rwa [geom_tail c.bound ht0 ht1 k] at h

/-- Positivity from the leading monomial, in the variable `t`. -/
lemma evalT_pos_of_leading {c : BddSeries} {n₀ : ℕ} (hvan : ∀ n, n < n₀ → c.coeff n = 0)
    (hlead : 0 < c.coeff n₀) {t : ℝ} (ht0 : 0 < t)
    (ht : t * (c.bound + c.coeff n₀) < c.coeff n₀) : 0 < c.evalT t := by
  have hbpos : 0 < c.bound := lt_of_lt_of_le hlead ((le_abs_self _).trans (c.le_bound n₀))
  have ht1 : t < 1 := by nlinarith
  have hsum : ∑ n ∈ Finset.range (n₀ + 1), c.coeff n * t ^ n = c.coeff n₀ * t ^ n₀ := by
    rw [Finset.sum_eq_single n₀]
    · intro b hb hne
      rcases lt_or_gt_of_ne hne with h | h
      · rw [hvan b h, zero_mul]
      · exact absurd (Finset.mem_range.mp hb) (by omega)
    · intro h; exact absurd (Finset.mem_range.mpr (Nat.lt_succ_self n₀)) h
  have htb := c.tail_bound ht0.le ht1 (n₀ + 1)
  rw [hsum] at htb
  have htpow : 0 < t ^ n₀ := pow_pos ht0 n₀
  have hkey : c.bound * t ^ (n₀ + 1) / (1 - t) < c.coeff n₀ * t ^ n₀ := by
    rw [div_lt_iff₀ (by linarith)]
    have hsplit : t ^ (n₀ + 1) = t ^ n₀ * t := by ring
    rw [hsplit]
    nlinarith [htpow]
  linarith [(abs_le.mp htb).1]

/-- **The leading nonzero monomial controls the eventual sign** (positive case). -/
theorem eventually_pos_of_leading {c : BddSeries} {n₀ : ℕ} (hvan : ∀ n, n < n₀ → c.coeff n = 0)
    (hlead : 0 < c.coeff n₀) : ∀ᶠ x : ℝ in atTop, 0 < c.eval x := by
  have hbpos : 0 < c.bound := lt_of_lt_of_le hlead ((le_abs_self _).trans (c.le_bound n₀))
  filter_upwards [eventually_gt_atTop ((c.bound + c.coeff n₀) / c.coeff n₀)] with x hx
  have hden : 0 < (c.bound + c.coeff n₀) / c.coeff n₀ := div_pos (by linarith) hlead
  have hx0 : 0 < x := lt_trans hden hx
  refine evalT_pos_of_leading hvan hlead (inv_pos.mpr hx0) ?_
  rw [inv_mul_eq_div, div_lt_iff₀ hx0]
  rw [div_lt_iff₀ hlead] at hx
  linarith

/-- **The leading nonzero monomial controls the eventual sign** (negative case). -/
theorem eventually_neg_of_leading {c : BddSeries} {n₀ : ℕ} (hvan : ∀ n, n < n₀ → c.coeff n = 0)
    (hlead : c.coeff n₀ < 0) : ∀ᶠ x : ℝ in atTop, c.eval x < 0 := by
  have hvan' : ∀ n, n < n₀ → (-c).coeff n = 0 := by
    intro n hn; simp [hvan n hn]
  have hlead' : 0 < (-c).coeff n₀ := by simpa using hlead
  filter_upwards [eventually_pos_of_leading hvan' hlead'] with x hx
  rw [eval_neg] at hx
  linarith

/-- Unified sign statement: eventually `eval` has the sign of the leading coefficient. -/
theorem eventually_sign {c : BddSeries} {n₀ : ℕ} (hvan : ∀ n, n < n₀ → c.coeff n = 0)
    (hlead : c.coeff n₀ ≠ 0) : ∀ᶠ x : ℝ in atTop, 0 < c.coeff n₀ * c.eval x := by
  rcases lt_or_gt_of_ne hlead with h | h
  · filter_upwards [eventually_neg_of_leading hvan h] with x hx
    exact mul_pos_of_neg_of_neg h hx
  · filter_upwards [eventually_pos_of_leading hvan h] with x hx
    exact mul_pos h hx

/-- Nonvanishing of the germ of a nonzero series. -/
theorem eventually_ne_zero {c : BddSeries} {n₀ : ℕ} (hvan : ∀ n, n < n₀ → c.coeff n = 0)
    (hlead : c.coeff n₀ ≠ 0) : ∀ᶠ x : ℝ in atTop, c.eval x ≠ 0 := by
  filter_upwards [eventually_sign hvan hlead] with x hx h0
  rw [h0, mul_zero] at hx
  exact lt_irrefl 0 hx

/-- **The germ of a bounded series has the series as its classical asymptotic
expansion.** -/
theorem eval_hasExpansion (c : BddSeries) : HasExpansion c.eval c.coeff := by
  intro N
  rw [isLittleO_iff]
  intro ε hε
  filter_upwards [eventually_ge_atTop (2 : ℝ),
    eventually_ge_atTop (2 * (c.bound + 1) / ε)] with x hx2 hxe
  have hx0 : (0 : ℝ) < x := by linarith
  have hxt : x⁻¹ * x = 1 := inv_mul_cancel₀ (ne_of_gt hx0)
  have ht0 : 0 < x⁻¹ := inv_pos.mpr hx0
  have ht12 : x⁻¹ ≤ 1 / 2 := by
    rw [inv_le_comm₀ hx0 (by norm_num)]
    linarith
  have ht1 : x⁻¹ < 1 := by linarith
  have htb := c.tail_bound ht0.le ht1 (N + 1)
  have hgoal : c.eval x - ∑ n ∈ Finset.range (N + 1), c.coeff n * monoN n x
      = c.evalT x⁻¹ - ∑ n ∈ Finset.range (N + 1), c.coeff n * x⁻¹ ^ n := by
    simp [eval, monoN]
  have hmono : |monoN N x| = x⁻¹ ^ N := by
    rw [monoN, abs_pow, abs_of_nonneg ht0.le]
  rw [Real.norm_eq_abs, Real.norm_eq_abs, hgoal, hmono]
  refine htb.trans ?_
  have hpowN : (0 : ℝ) ≤ x⁻¹ ^ N := pow_nonneg ht0.le N
  have hsplit : x⁻¹ ^ (N + 1) = x⁻¹ ^ N * x⁻¹ := by ring
  have hdenom : (1 : ℝ) / 2 ≤ 1 - x⁻¹ := by linarith
  have hstep1 : c.bound * x⁻¹ ^ (N + 1) / (1 - x⁻¹) ≤ 2 * (c.bound * x⁻¹ ^ (N + 1)) := by
    rw [div_le_iff₀ (by linarith)]
    have hnn : 0 ≤ c.bound * x⁻¹ ^ (N + 1) :=
      mul_nonneg c.bound_nonneg (pow_nonneg ht0.le _)
    nlinarith
  have hcoef : 2 * c.bound * x⁻¹ ≤ ε := by
    have h1 : 2 * (c.bound + 1) ≤ ε * x := by
      rw [div_le_iff₀ hε] at hxe; linarith
    nlinarith [mul_le_mul_of_nonneg_left h1 ht0.le]
  calc c.bound * x⁻¹ ^ (N + 1) / (1 - x⁻¹)
      ≤ 2 * (c.bound * x⁻¹ ^ (N + 1)) := hstep1
    _ = (2 * c.bound * x⁻¹) * x⁻¹ ^ N := by rw [hsplit]; ring
    _ ≤ ε * x⁻¹ ^ N := mul_le_mul_of_nonneg_right hcoef hpowN

/-- **Injectivity of the germ interpretation on the summable fragment**, together
with its converse: two bounded series have the same germ at `+∞` iff they agree
at every rank. -/
theorem eval_eventuallyEq_iff (c d : BddSeries) :
    c.eval =ᶠ[atTop] d.eval ↔ c.coeff = d.coeff := by
  constructor
  · intro h
    exact expansion_unique (c.eval_hasExpansion)
      ((d.eval_hasExpansion).congr_germ h.symm)
  · intro h
    have : c.eval = d.eval := by
      funext x; simp only [eval, evalT, h]
    exact EventuallyEq.of_eq this

/-- Restatement of injectivity. -/
theorem eval_injective {c d : BddSeries} (h : c.eval =ᶠ[atTop] d.eval) : c.coeff = d.coeff :=
  (eval_eventuallyEq_iff c d).mp h

end BddSeries

/-! ## The boundary: flat functions -/

/-- The flat germ `e^{-x}` is negligible against every rank of the scale. -/
theorem exp_neg_isLittleO_monoN (n : ℕ) :
    (fun x : ℝ => Real.exp (-x)) =o[atTop] monoN n := by
  have hne : ∀ᶠ x : ℝ in atTop, monoN n x = 0 → Real.exp (-x) = 0 := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx hz
    exact absurd hz (ne_of_gt (monoN_pos hx n))
  rw [isLittleO_iff_tendsto' hne]
  have heq : (fun x : ℝ => Real.exp (-x) / monoN n x) =ᶠ[atTop] fun x : ℝ => x ^ n * Real.exp (-x) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
    rw [monoN, inv_pow, div_inv_eq_mul, mul_comm]
  exact (Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero n).congr' heq.symm

/-- **The analytic claim is false.**  There are two functions with identical
asymptotic expansions to all ranks whose germs at `+∞` differ. -/
theorem expansion_not_germ_injective :
    ∃ f g : ℝ → ℝ, HasExpansion f 0 ∧ HasExpansion g 0 ∧ ¬ f =ᶠ[atTop] g := by
  refine ⟨0, fun x => Real.exp (-x), ?_, ?_, ?_⟩
  · intro N
    have : (fun x : ℝ => (0 : ℝ → ℝ) x - ∑ n ∈ Finset.range (N + 1), (0 : ℕ → ℝ) n * monoN n x)
        = fun _ => (0 : ℝ) := by
      funext x; simp
    rw [this]
    exact isLittleO_zero _ _
  · intro N
    refine (exp_neg_isLittleO_monoN N).congr' ?_ (EventuallyEq.refl _ _)
    filter_upwards with x
    simp
  · intro h
    obtain ⟨x, hx⟩ := h.exists
    exact absurd hx.symm (Real.exp_ne_zero _)

/-- No bounded series represents the flat germ `e^{-x}`: the germ interpretation
of the summable fragment misses exactly the flat functions. -/
theorem BddSeries.exp_neg_not_eval (c : BddSeries) :
    ¬ (c.eval =ᶠ[atTop] fun x : ℝ => Real.exp (-x)) := by
  intro h
  have hexp : HasExpansion (fun x : ℝ => Real.exp (-x)) 0 := by
    intro N
    refine (exp_neg_isLittleO_monoN N).congr' ?_ (EventuallyEq.refl _ _)
    filter_upwards with x
    simp
  have hzero : c.coeff = 0 :=
    expansion_unique (c.eval_hasExpansion) (hexp.congr_germ h.symm)
  have hev : c.eval = fun _ : ℝ => (0 : ℝ) := by
    funext x
    simp [BddSeries.eval, BddSeries.evalT, hzero]
  rw [hev] at h
  obtain ⟨x, hx⟩ := h.exists
  exact absurd hx.symm (Real.exp_ne_zero _)

end Catalog.NumberTheory.AsymptoticGerm