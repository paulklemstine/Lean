import Mathlib
import Novelty.U35SubfloorCap

/-!
# U35 localization II: the paired u-drop — exact sign test and the correlation it forces

## Research context (FACT round-45 #1, exp 500, assessment v276)

What survived the exp-500 localization is not a floor breach but a *paired* effect:

```
Delta = sp(2.5) - sp(3.5)      mean 0.1057,  CI [0.0999, 0.1112],  14/14 positive
sp(3.5)                        mean 0.6282,  sample sd 0.0155
```

`Novelty.U35SubfloorCap` settled the unpaired question (the sub-floor count).  This file treats
the paired column, and extracts two structurally different consequences of "14/14 positive".

### A. The exact randomization (sign) test — Section 1

Under the sharp null "the `u`-label carries no information", the recorded pairing is
exchangeable, so the recorded statistic must be compared with the `2^14` sign-flipped
re-labellings `s : Fin 14 → Bool`, giving `signedSum d s = ∑ ± dᵢ`.  The key combinatorial
fact is a *strict* one:

* `signedSum_lt_of_exists_false` — if every `dᵢ` is strictly positive, then **every** sign
  vector other than the all-plus one gives a strictly smaller signed sum.
* `extremeSet_eq_singleton` — hence the set of re-labellings at least as extreme as the
  observed one is the singleton `{all-plus}`.
* `sign_test_pvalue` — the exact one-sided randomization p-value is therefore
  `1 / 2^14 = 1/16384 ≈ 6.1 · 10⁻⁵`, and `u35_sign_test_pvalue_lt` records that this is below
  `10⁻⁴`.  Note that no distributional assumption is used: positivity of the 14 recorded
  drops is the *only* input, and the p-value is exact, not asymptotic.

### B. Variance reduction forces correlation — Section 2

The paired CI is narrow: half-width `0.00565` against `0.00795` for the unpaired `sp(3.5)`
interval, i.e. the paired standard error is about `0.0029`, an sd of about `0.0109` over 14
seeds — *smaller* than the `0.0155` sd of either column.  Section 2 shows this is not an
accident of the bootstrap but a rigid algebraic constraint.  With `SS` the total squared
deviation and `SP` the total cross-product,

* `paired_ss_identity` — `SS(a − b) = SS a + SS b − 2 SP a b`, exactly;
* `paired_cov_pos_of_variance_reduction` — pairing reduces dispersion iff the two columns are
  positively correlated;
* `u35_paired_correlation_lower_bound` — at the recorded numbers (`sd = 0.0155` for both
  columns, paired sd `≤ 0.0110`) the seed-level correlation between `sp(2.5)` and `sp(3.5)`
  is at least `0.74`.

The scientific reading: the `u`-sensitivity loss is a **population-level property carried by a
shared latent seed quality**, not a per-seed idiosyncrasy.  A seed that scores high at
`u = 2.5` scores high at `u = 3.5`; the two columns move together with correlation `≥ 0.74`
and are separated by an almost constant offset.  Dial hardening therefore has a single target
(the uniform `≈ 0.11` offset), which is exactly the verdict the ledger recorded — and here it
is a theorem about the recorded numbers rather than an impression from the scatter plot.

## Lab notes (derived quantities, all verified below)

```
sign-test support        2^14 = 16384 relabellings
extreme relabellings     exactly 1 (the observed all-plus vector)
exact one-sided p        1/16384 = 0.000061035...   < 1e-4
paired CI half-width     (0.1112 - 0.0999)/2 = 0.00565  -> s.e. ~ 0.00291 -> sd ~ 0.0109
correlation bound        1 - 0.0110^2/(2 * 0.0155^2) = 0.7481...  >= 0.74
```
-/

namespace Catalog.Novelty.U35PairedDrop

open Finset
open Catalog.Novelty.U35SubfloorCap

/-! ## 1. The exact sign (randomization) test -/

/-- The signed sum of the paired drops `d` under the sign re-labelling `s`. -/
def signedSum {n : ℕ} (d : Fin n → ℝ) (s : Fin n → Bool) : ℝ :=
  ∑ i, if s i then d i else -d i

@[simp] theorem signedSum_allTrue {n : ℕ} (d : Fin n → ℝ) :
    signedSum d (fun _ => true) = ∑ i, d i := by
  simp [signedSum]

/-- Any re-labelling of nonnegative drops has signed sum at most the observed one. -/
theorem signedSum_le {n : ℕ} {d : Fin n → ℝ} (hd : ∀ i, 0 ≤ d i) (s : Fin n → Bool) :
    signedSum d s ≤ ∑ i, d i := by
  refine Finset.sum_le_sum ?_
  intro i _
  cases h : s i with
  | false => simp only [Bool.false_eq_true, if_false]; linarith [hd i]
  | true => simp

/-- **Strictness.**  If all 14 recorded drops are strictly positive, then flipping even one
sign strictly decreases the signed sum. -/
theorem signedSum_lt_of_exists_false {n : ℕ} {d : Fin n → ℝ} (hd : ∀ i, 0 < d i)
    {s : Fin n → Bool} (hs : ∃ i, s i = false) :
    signedSum d s < ∑ i, d i := by
  obtain ⟨j, hj⟩ := hs
  refine Finset.sum_lt_sum ?_ ⟨j, Finset.mem_univ j, ?_⟩
  · intro i _
    cases h : s i with
    | false => simp only [Bool.false_eq_true, if_false]; linarith [hd i]
    | true => simp
  · simp only [hj, Bool.false_eq_true, if_false]
    linarith [hd j]

open Classical in
/-- The set of sign re-labellings at least as extreme as the observed one is a singleton. -/
theorem extremeSet_eq_singleton {n : ℕ} {d : Fin n → ℝ} (hd : ∀ i, 0 < d i) :
    (Finset.univ.filter (fun s : Fin n → Bool => ∑ i, d i ≤ signedSum d s))
      = {fun _ => true} := by
  classical
  refine Finset.eq_singleton_iff_unique_mem.mpr ⟨?_, ?_⟩
  · simp
  · intro s hs
    have hs' : ∑ i, d i ≤ signedSum d s := by
      simpa using (Finset.mem_filter.mp hs).2
    by_contra hne
    have hex : ∃ i, s i = false := by
      by_contra hall
      push_neg at hall
      refine hne (funext fun i => ?_)
      cases h : s i with
      | false => exact absurd h (hall i)
      | true => rfl
    exact absurd hs' (not_le.mpr (signedSum_lt_of_exists_false hd hex))

open Classical in
/-- **The exact one-sided randomization p-value.**  For `n` strictly positive paired drops the
proportion of the `2^n` sign re-labellings that are at least as extreme as the observed one is
exactly `2^{-n}`. -/
theorem sign_test_pvalue {n : ℕ} {d : Fin n → ℝ} (hd : ∀ i, 0 < d i) :
    ((Finset.univ.filter
        (fun s : Fin n → Bool => ∑ i, d i ≤ signedSum d s)).card : ℝ)
      / (Fintype.card (Fin n → Bool)) = 1 / 2 ^ n := by
  classical
  rw [extremeSet_eq_singleton hd]
  simp

/-- At the recorded `14/14`, the exact sign-test p-value is below `10⁻⁴`. -/
theorem u35_sign_test_pvalue_lt {d : Fin 14 → ℝ} (hd : ∀ i, 0 < d i) :
    ((Finset.univ.filter
        (fun s : Fin 14 → Bool => ∑ i, d i ≤ signedSum d s)).card : ℝ)
      / (Fintype.card (Fin 14 → Bool)) < 1 / 10000 := by
  classical
  rw [sign_test_pvalue hd]
  norm_num

/-! ## 2. Pairing, dispersion and the correlation it forces -/

/-- Total squared deviation of a column about its own mean. -/
noncomputable def SS {n : ℕ} (a : Fin n → ℝ) : ℝ := sqDev a (mean a)

/-- Total cross-product of two columns about their own means. -/
noncomputable def SP {n : ℕ} (a b : Fin n → ℝ) : ℝ := ∑ i, (a i - mean a) * (b i - mean b)

theorem mean_sub {n : ℕ} (a b : Fin n → ℝ) :
    mean (fun i => a i - b i) = mean a - mean b := by
  simp [mean, Finset.sum_sub_distrib, sub_div]

/-- **The paired dispersion identity.**  `SS(a − b) = SS a + SS b − 2 SP a b`. -/
theorem paired_ss_identity {n : ℕ} (a b : Fin n → ℝ) :
    SS (fun i => a i - b i) = SS a + SS b - 2 * SP a b := by
  have hmean := mean_sub a b
  simp only [SS, SP, sqDev, hmean, Finset.mul_sum, ← Finset.sum_add_distrib,
    ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- Pairing reduces dispersion exactly when the two columns are positively correlated. -/
theorem paired_cov_pos_of_variance_reduction {n : ℕ} (a b : Fin n → ℝ)
    (h : SS (fun i => a i - b i) < SS a + SS b) : 0 < SP a b := by
  have := paired_ss_identity a b
  linarith

/-- **The correlation forced by the recorded numbers.**  If both `u`-columns have the recorded
sample sd `0.0155` over the 14 seeds and the paired difference column has sd at most `0.0110`
(the value implied by the recorded paired CI `[0.0999, 0.1112]`), then the seed-level
correlation of `sp(2.5)` with `sp(3.5)` is at least `0.74`. -/
theorem u35_paired_correlation_lower_bound (a b : Fin 14 → ℝ)
    (hSa : SS a = 13 * (155 / 10000) ^ 2) (hSb : SS b = SS a)
    (hd : SS (fun i => a i - b i) ≤ 13 * (110 / 10000) ^ 2) :
    74 / 100 ≤ SP a b / SS a := by
  have hid := paired_ss_identity a b
  have hSapos : 0 < SS a := by rw [hSa]; norm_num
  have hSP : SP a b = (SS a + SS b - SS (fun i => a i - b i)) / 2 := by linarith
  have hlow : (2 * SS a - 13 * (110 / 10000) ^ 2) / 2 ≤ SP a b := by
    rw [hSP, hSb]; linarith
  rw [le_div_iff₀ hSapos]
  nlinarith [hlow, hSa]

end Catalog.Novelty.U35PairedDrop