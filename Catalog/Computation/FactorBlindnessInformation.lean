/-
# Finite mutual information, Gibbs' inequality, and the capacity ceiling

This file is the analytic base layer for the *factor-blindness* thread
(`Computation.FactorBlindnessWall`).  It develops, from scratch and over `ℝ`, the small
amount of finite information theory that the thread needs:

* `margL`, `margK` — the two marginals of a finite joint mass function on `L × K`;
* `mutualInfo` — the plug-in mutual information `∑ p log₂ (p / (p_L p_K))` in **bits**;
* `entropy` — the Shannon entropy in bits.

and the three facts that carry the whole programme:

* `sum_mul_log_div_nonneg` — Gibbs' inequality in the form
  `0 ≤ ∑ p log (p/q)` for a probability vector `p` and a sub-probability vector `q`
  that dominates `p` (absolute continuity).  Proved from `Real.log_le_sub_one_of_pos`.
* `mutualInfo_nonneg` — a plug-in mutual-information reading is **never negative**.
  This is exactly why a positive reading is not by itself evidence of dependence: the
  estimator is a one-sided statistic.
* `mutualInfo_eq_zero_of_product` — a product (independent) table reads exactly `0`.
* `entropy_le_logb_card` — the max-entropy/capacity ceiling `H ≤ log₂ |K|`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the "which-factor leakage" of a symmetric battery is not merely small,
  it is *exactly* zero, and the machinery needed to say so is only Gibbs' inequality plus a
  product-form criterion.
Experiment (Stage 2): formalised `mutualInfo` for arbitrary finite `L`, `K` and checked the
  three degenerate regimes that break naive formalisations: `p = 0` cells (handled by
  `Real.log 0 = 0` making the cell contribute `0 * 0`), zero marginals (handled by absolute
  continuity, which here is a *theorem* — `margL l = 0 → p l k = 0` — not an assumption),
  and the empty population (all quantities `0`).
Analysis (Stage 3): the only genuinely analytic input is `log x ≤ x - 1`; everything else is
  bookkeeping of nonnegative finite sums.  The same Gibbs step delivers both the
  nonnegativity of the reading and the `log₂ |K|` capacity ceiling, with the uniform vector
  as the comparison measure — the two halves of the battery claim come from one lemma.
Critique (Stage 4): `mutualInfo` is the *plug-in* functional; applied to an empirical table it
  is a biased estimator, and the nonnegativity proved here is precisely the source of that
  bias.  We therefore never call it "the" mutual information of a population unless the table
  fed to it is the population table.  That distinction is exploited in
  `Computation.FactorBlindnessWall`.
-/
import Mathlib

namespace Computation.FactorBlindness

open Finset

/-! ## Gibbs' inequality -/

/-- **Gibbs' inequality** (finite, plug-in form).  If `p` is a probability vector, `q` a
nonnegative sub-probability vector, and `q` dominates `p` in the sense that `q i = 0` forces
`p i = 0`, then the relative entropy `∑ p log (p/q)` is nonnegative. -/
theorem sum_mul_log_div_nonneg {ι : Type*} [Fintype ι] (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hac : ∀ i, q i = 0 → p i = 0)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i ≤ 1) :
    0 ≤ ∑ i, p i * Real.log (p i / q i) := by
  have key : ∀ i ∈ (univ : Finset ι), -(p i * Real.log (p i / q i)) ≤ q i - p i := by
    intro i _
    rcases eq_or_lt_of_le (hp i) with h | h
    · have : p i = 0 := h.symm
      simp [this, hq i]
    · have hqi : 0 < q i := by
        rcases eq_or_lt_of_le (hq i) with h0 | h0
        · exact absurd (hac i h0.symm) (ne_of_gt h)
        · exact h0
      have hlog : Real.log (p i / q i) = -Real.log (q i / p i) := by
        rw [← Real.log_inv]
        congr 1
        field_simp
      have hle : Real.log (q i / p i) ≤ q i / p i - 1 :=
        Real.log_le_sub_one_of_pos (div_pos hqi h)
      have : p i * Real.log (q i / p i) ≤ p i * (q i / p i - 1) :=
        mul_le_mul_of_nonneg_left hle (le_of_lt h)
      have hpi : p i * (q i / p i - 1) = q i - p i := by field_simp
      rw [hlog]
      linarith [this, hpi ▸ this]
  have hsum : ∑ i, -(p i * Real.log (p i / q i)) ≤ ∑ i, (q i - p i) :=
    Finset.sum_le_sum key
  have h1 : ∑ i, -(p i * Real.log (p i / q i)) = -∑ i, p i * Real.log (p i / q i) := by
    simp
  have h2 : ∑ i, (q i - p i) = (∑ i, q i) - ∑ i, p i := by
    rw [Finset.sum_sub_distrib]
  rw [h1, h2, hp1] at hsum
  linarith

/-! ## Marginals, mutual information, entropy -/

variable {L K : Type*} [Fintype L] [Fintype K]

/-- The `L`-marginal of a finite joint mass function. -/
def margL (p : L → K → ℝ) (l : L) : ℝ := ∑ k, p l k

/-- The `K`-marginal of a finite joint mass function. -/
def margK (p : L → K → ℝ) (k : K) : ℝ := ∑ l, p l k

/-- The plug-in mutual information of a finite joint table, **in bits**. -/
noncomputable def mutualInfo (p : L → K → ℝ) : ℝ :=
  ∑ l, ∑ k, p l k * Real.logb 2 (p l k / (margL p l * margK p k))

/-- Shannon entropy of a finite mass function, in bits. -/
noncomputable def entropy (r : K → ℝ) : ℝ := ∑ k, -(r k * Real.logb 2 (r k))

omit [Fintype L] in
lemma margL_nonneg {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k) (l : L) : 0 ≤ margL p l :=
  Finset.sum_nonneg fun k _ => hp l k

omit [Fintype K] in
lemma margK_nonneg {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k) (k : K) : 0 ≤ margK p k :=
  Finset.sum_nonneg fun l _ => hp l k

lemma sum_margL {p : L → K → ℝ} : ∑ l, margL p l = ∑ l, ∑ k, p l k := rfl

lemma sum_margK {p : L → K → ℝ} : ∑ k, margK p k = ∑ l, ∑ k, p l k := by
  simpa [margK] using Finset.sum_comm (s := (univ : Finset K)) (t := (univ : Finset L))
    (f := fun k l => p l k)

omit [Fintype L] in
/-- Absolute continuity is automatic: a vanishing `L`-marginal kills its whole row. -/
lemma eq_zero_of_margL_eq_zero {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k) {l : L}
    (h : margL p l = 0) (k : K) : p l k = 0 := by
  have := (Finset.sum_eq_zero_iff_of_nonneg (fun k _ => hp l k)).1 h k (mem_univ k)
  exact this

omit [Fintype K] in
/-- A vanishing `K`-marginal kills its whole column. -/
lemma eq_zero_of_margK_eq_zero {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k) {k : K}
    (h : margK p k = 0) (l : L) : p l k = 0 :=
  (Finset.sum_eq_zero_iff_of_nonneg (fun l _ => hp l k)).1 h l (mem_univ l)

/-- **A plug-in mutual-information reading is never negative.**  This one-sidedness is the
mechanism behind sparse plug-in bias: noise can only push the reading up. -/
theorem mutualInfo_nonneg {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k)
    (htot : ∑ l, ∑ k, p l k = 1) : 0 ≤ mutualInfo p := by
  set P : L × K → ℝ := fun x => p x.1 x.2 with hP
  set Q : L × K → ℝ := fun x => margL p x.1 * margK p x.2 with hQ
  have hPnn : ∀ x, 0 ≤ P x := fun x => hp x.1 x.2
  have hQnn : ∀ x, 0 ≤ Q x := fun x =>
    mul_nonneg (margL_nonneg hp x.1) (margK_nonneg hp x.2)
  have hac : ∀ x, Q x = 0 → P x = 0 := by
    rintro ⟨l, k⟩ hx
    rcases mul_eq_zero.1 hx with h | h
    · exact eq_zero_of_margL_eq_zero hp h k
    · exact eq_zero_of_margK_eq_zero hp h l
  have hP1 : ∑ x : L × K, P x = 1 := by
    rw [Fintype.sum_prod_type]; exact htot
  have hQ1 : ∑ x : L × K, Q x ≤ 1 := by
    have : ∑ x : L × K, Q x = (∑ l, margL p l) * ∑ k, margK p k := by
      rw [Fintype.sum_prod_type, Finset.sum_mul]
      exact Finset.sum_congr rfl fun l _ => by rw [Finset.mul_sum]
    rw [this, sum_margL, sum_margK, htot]
    norm_num
  have hgibbs := sum_mul_log_div_nonneg P Q hPnn hQnn hac hP1 hQ1
  have hmi : mutualInfo p = (∑ x : L × K, P x * Real.log (P x / Q x)) / Real.log 2 := by
    rw [Fintype.sum_prod_type, Finset.sum_div]
    refine Finset.sum_congr rfl fun l _ => ?_
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun k _ => by
      simp [Real.logb, hP, hQ, mul_div_assoc]
  rw [hmi]
  positivity

/-- **Independence reads exactly zero.**  If the table factors through its marginals, the
plug-in reading is `0` — no approximation, no null calibration needed. -/
theorem mutualInfo_eq_zero_of_product {p : L → K → ℝ}
    (hprod : ∀ l k, p l k = margL p l * margK p k) : mutualInfo p = 0 := by
  refine Finset.sum_eq_zero fun l _ => Finset.sum_eq_zero fun k _ => ?_
  rcases eq_or_ne (p l k) 0 with h | h
  · simp [h]
  · have hne : margL p l * margK p k ≠ 0 := by rw [← hprod l k]; exact h
    rw [hprod l k]
    rw [div_self hne]
    simp

/-- **Capacity ceiling.**  The entropy of any finite mass function on `K` is at most
`log₂ |K|` bits: the battery's readout alphabet caps its capacity. -/
theorem entropy_le_logb_card {r : K → ℝ} [Nonempty K] (hr : ∀ k, 0 ≤ r k)
    (htot : ∑ k, r k = 1) : entropy r ≤ Real.logb 2 (Fintype.card K) := by
  set N : ℝ := (Fintype.card K : ℝ) with hN
  have hcard : 0 < Fintype.card K := Fintype.card_pos
  have hNpos : 0 < N := by
    rw [hN]; exact_mod_cast hcard
  have hu : ∀ k : K, (0:ℝ) ≤ 1 / N := fun _ => by positivity
  have hac : ∀ k : K, (1 / N : ℝ) = 0 → r k = 0 := by
    intro k h
    exact absurd h (by positivity)
  have hu1 : ∑ _k : K, (1 / N : ℝ) ≤ 1 := by
    rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ, ← hN]
    rw [mul_one_div, div_self (ne_of_gt hNpos)]
  have hgibbs := sum_mul_log_div_nonneg r (fun _ => 1 / N) hr hu hac htot hu1
  have hterm : ∀ k : K, r k * Real.log (r k / (1 / N))
      = r k * Real.log (r k) + r k * Real.log N := by
    intro k
    rcases eq_or_lt_of_le (hr k) with h | h
    · simp [← h]
    · rw [show r k / (1 / N) = r k * N by field_simp,
        Real.log_mul (ne_of_gt h) (ne_of_gt hNpos)]
      ring
  rw [Finset.sum_congr rfl (fun k _ => hterm k), Finset.sum_add_distrib, ← Finset.sum_mul,
    htot, one_mul] at hgibbs
  have hstep : ∀ k : K, -(r k * Real.logb 2 (r k))
      = -(r k * Real.log (r k)) / Real.log 2 := by
    intro k; simp [Real.logb, mul_div_assoc, neg_div]
  have hentropy : entropy r = -(∑ k, r k * Real.log (r k)) / Real.log 2 := by
    unfold entropy
    rw [Finset.sum_congr rfl (fun k _ => hstep k), ← Finset.sum_div]
    congr 1
    simp
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [hentropy, Real.logb]
  gcongr
  linarith

end Computation.FactorBlindness