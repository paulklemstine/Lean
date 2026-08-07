import Novelty.BekensteinHawkingUniversality

/-!
# The entropy density is the characteristic root, and it is strictly monotone

`Novelty.BekensteinHawkingUniversality` produces the entropy density of a general
puncture model as a Fekete limit, with no formula for it.  For the concrete
isolated-horizon model the density was computed by hand to be `log (2 + √2)`, the
inverse of the root of the isolated-horizon characteristic equation
`∑_k deg(k) x^k = 1`.

This file proves that this is a *general* phenomenon for models with finitely
many puncture types: the entropy density is *exactly* `-log r`, where `r` is the
unique positive root of the characteristic equation, and it is *strictly*
increasing in the degeneracies.  This closes Conjecture 2 and Conjecture 3 of
`FUTURE_DIRECTIONS.md` in the finitely-supported case.

## The argument

Write `a n = gW deg n` for the microstate count and `f(x) = ∑_{k=1}^{K} deg(k) x^k`
for the characteristic function.

* `exists_charRoot` / `charRoot_unique` : `f` is a strictly increasing
  homeomorphism of `[0, ∞)` onto its image with `f 0 = 0` and `f 1 ≥ 1`, so
  `f r = 1` has exactly one positive solution `r ∈ (0, 1]`.
* `gW_le_inv_root_pow` : `a n ≤ r^{-n}` — a direct strong induction on the
  renewal recursion `a (n+1) = ∑_i deg(i+1) a (n-i)`, in which the characteristic
  equation is exactly what makes the induction close.
* `charRootMeasure_ge` : the normalised sequence `m n = a n · r^n` obeys
  `m n = ∑_k p_k m (n-k)` with `p_k = deg(k) r^k ≥ 0` summing to `1`; a renewal
  ("minimum propagates") argument then bounds `m` away from `0`.
* `gEntropy_eq_neg_log_charRoot` : squeezing `log m n / n → 0` between
  `log c / n` and `0` gives `log (a n)/n → -log r`.
* `gDensity_strict_mono` : `f` is strictly increasing in the degeneracies, hence
  the root strictly decreases and the density strictly increases — the
  Barbero–Immirzi rigidity statement.
-/

open Finset Filter

namespace BekensteinHawking
namespace Universal

/-- The characteristic function `f(x) = ∑_{k=1}^{K} deg(k) x^k` of a puncture
model with puncture areas bounded by `K`. -/
noncomputable def charPoly (deg : ℕ → ℕ) (K : ℕ) (x : ℝ) : ℝ :=
  ∑ i ∈ range K, (deg (i + 1) : ℝ) * x ^ (i + 1)

lemma charPoly_continuous (deg : ℕ → ℕ) (K : ℕ) : Continuous (charPoly deg K) := by
  refine continuous_finset_sum _ (fun i _ => ?_)
  exact continuous_const.mul (continuous_pow (i + 1))

@[simp] lemma charPoly_zero (deg : ℕ → ℕ) (K : ℕ) : charPoly deg K 0 = 0 := by
  refine Finset.sum_eq_zero (fun i _ => ?_)
  simp

/-- The characteristic function is strictly increasing on `[0, ∞)`. -/
lemma charPoly_strictMonoOn (deg : ℕ → ℕ) (K : ℕ) (hdeg1 : 1 ≤ deg 1) (hK : 1 ≤ K) :
    StrictMonoOn (charPoly deg K) (Set.Ici (0:ℝ)) := by
  intro a ha b hb hab
  have ha0 : (0:ℝ) ≤ a := ha
  refine Finset.sum_lt_sum (fun i _ => ?_) ⟨0, Finset.mem_range.2 hK, ?_⟩
  · have h1 : a ^ (i + 1) ≤ b ^ (i + 1) := pow_le_pow_left₀ ha0 (le_of_lt hab) _
    have h2 : (0:ℝ) ≤ (deg (i + 1) : ℝ) := Nat.cast_nonneg _
    nlinarith
  · have hd : (1:ℝ) ≤ (deg 1 : ℝ) := by exact_mod_cast hdeg1
    simp only [pow_one, zero_add]
    nlinarith

/-- At `x = 1` the characteristic function is at least `1`. -/
lemma one_le_charPoly_one (deg : ℕ → ℕ) (K : ℕ) (hdeg1 : 1 ≤ deg 1) (hK : 1 ≤ K) :
    1 ≤ charPoly deg K 1 := by
  have hmem : (0:ℕ) ∈ range K := Finset.mem_range.2 hK
  have hle : (deg (0 + 1) : ℝ) * (1:ℝ) ^ (0 + 1) ≤ charPoly deg K 1 :=
    Finset.single_le_sum (f := fun i => (deg (i + 1) : ℝ) * (1:ℝ) ^ (i + 1))
      (fun i _ => by positivity) hmem
  have hd : (1:ℝ) ≤ (deg 1 : ℝ) := by exact_mod_cast hdeg1
  simpa using le_trans hd (by simpa using hle)

/-- **Existence of the characteristic root.**  The isolated-horizon
characteristic equation `∑_k deg(k) x^k = 1` has a solution in `(0, 1]`. -/
theorem exists_charRoot (deg : ℕ → ℕ) (K : ℕ) (hdeg1 : 1 ≤ deg 1) (hK : 1 ≤ K) :
    ∃ r : ℝ, 0 < r ∧ r ≤ 1 ∧ charPoly deg K r = 1 := by
  have hcont : ContinuousOn (charPoly deg K) (Set.Icc 0 1) :=
    (charPoly_continuous deg K).continuousOn
  have hmem : (1:ℝ) ∈ Set.Icc (charPoly deg K 0) (charPoly deg K 1) := by
    constructor
    · rw [charPoly_zero]; norm_num
    · exact one_le_charPoly_one deg K hdeg1 hK
  obtain ⟨r, hrmem, hr⟩ := intermediate_value_Icc (by norm_num : (0:ℝ) ≤ 1) hcont hmem
  refine ⟨r, ?_, hrmem.2, hr⟩
  rcases lt_or_eq_of_le hrmem.1 with h | h
  · exact h
  · exfalso
    rw [← h, charPoly_zero] at hr
    norm_num at hr

/-- **Uniqueness of the characteristic root.** -/
theorem charRoot_unique (deg : ℕ → ℕ) (K : ℕ) (hdeg1 : 1 ≤ deg 1) (hK : 1 ≤ K)
    {r r' : ℝ} (hr0 : 0 < r) (hr : charPoly deg K r = 1)
    (hr0' : 0 < r') (hr' : charPoly deg K r' = 1) : r = r' := by
  have hmono := charPoly_strictMonoOn deg K hdeg1 hK
  rcases lt_trichotomy r r' with h | h | h
  · exact absurd (hmono (le_of_lt hr0) (le_of_lt hr0') h) (by rw [hr, hr']; exact lt_irrefl 1)
  · exact h
  · exact absurd (hmono (le_of_lt hr0') (le_of_lt hr0) h) (by rw [hr, hr']; exact lt_irrefl 1)

/-! ## The upper bound `W(A) ≤ r^{-A}` -/

/-- Truncated characteristic sums are bounded by the characteristic function. -/
lemma sum_le_charPoly (deg : ℕ → ℕ) (K : ℕ) (hsupp : ∀ k, K < k → deg k = 0) {x : ℝ}
    (hx : 0 ≤ x) (m : ℕ) :
    ∑ i ∈ range m, (deg (i + 1) : ℝ) * x ^ (i + 1) ≤ charPoly deg K x := by
  rcases le_total m K with hm | hm
  · exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_subset_range.mpr hm)
      (fun i _ _ => by positivity)
  · refine le_of_eq ?_
    refine (Finset.sum_subset (Finset.range_subset_range.mpr hm) (fun i hi hni => ?_)).symm
    have : K < i + 1 := by
      simp only [Finset.mem_range] at hi hni
      omega
    rw [hsupp _ this]
    simp

/-- **The characteristic root controls the microstate count from above.**
`W(A) ≤ r^{-A}`, by strong induction on the renewal recursion; the induction
closes precisely because `r` solves the characteristic equation. -/
theorem gW_le_inv_root_pow (deg : ℕ → ℕ) (K : ℕ) (hsupp : ∀ k, K < k → deg k = 0)
    {r : ℝ} (hr0 : 0 < r) (hr : charPoly deg K r = 1) (n : ℕ) :
    (gW deg n : ℝ) ≤ (r⁻¹) ^ n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp
    | (n + 1) =>
      have hstep : (gW deg (n + 1) : ℝ)
          = ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * (gW deg (n - i) : ℝ) := by
        rw [gW_succ]
        push_cast
        ring
      have hbound : ∀ i ∈ range (n + 1),
          (deg (i + 1) : ℝ) * (gW deg (n - i) : ℝ)
            ≤ (deg (i + 1) : ℝ) * ((r⁻¹) ^ (n + 1) * r ^ (i + 1)) := by
        intro i hi
        simp only [Finset.mem_range] at hi
        have hsplit : n + 1 = (n - i) + (i + 1) := by omega
        have hpow : (r⁻¹) ^ (n + 1) * r ^ (i + 1) = (r⁻¹) ^ (n - i) := by
          rw [hsplit, pow_add, mul_assoc, ← mul_pow, inv_mul_cancel₀ (ne_of_gt hr0),
            one_pow, mul_one]
        rw [hpow]
        have hIH := ih (n - i) (by omega)
        have hd : (0:ℝ) ≤ (deg (i + 1) : ℝ) := Nat.cast_nonneg _
        nlinarith
      have hsum : (gW deg (n + 1) : ℝ)
          ≤ ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * ((r⁻¹) ^ (n + 1) * r ^ (i + 1)) := by
        rw [hstep]
        exact Finset.sum_le_sum hbound
      have hfact : ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * ((r⁻¹) ^ (n + 1) * r ^ (i + 1))
          = (r⁻¹) ^ (n + 1) * ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * r ^ (i + 1) := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl (fun i _ => by ring)
      have hchar : ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * r ^ (i + 1) ≤ 1 := by
        rw [← hr]
        exact sum_le_charPoly deg K hsupp (le_of_lt hr0) (n + 1)
      have hinvpos : (0:ℝ) < (r⁻¹) ^ (n + 1) := by positivity
      calc (gW deg (n + 1) : ℝ)
          ≤ (r⁻¹) ^ (n + 1) * ∑ i ∈ range (n + 1), (deg (i + 1) : ℝ) * r ^ (i + 1) := by
            rw [← hfact]; exact hsum
        _ ≤ (r⁻¹) ^ (n + 1) * 1 := by nlinarith
        _ = (r⁻¹) ^ (n + 1) := by ring

/-! ## The lower bound: a renewal argument -/

/-- The normalised microstate count `m n = W(n) · r^n`. -/
noncomputable def renewalSeq (deg : ℕ → ℕ) (r : ℝ) (n : ℕ) : ℝ := (gW deg n : ℝ) * r ^ n

lemma renewalSeq_pos (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) {r : ℝ} (hr0 : 0 < r) (n : ℕ) :
    0 < renewalSeq deg r n := by
  have h : (1:ℝ) ≤ (gW deg n : ℝ) := by exact_mod_cast one_le_gW deg hdeg1 n
  have : (0:ℝ) < r ^ n := by positivity
  rw [renewalSeq]
  nlinarith

lemma renewalSeq_le_one (deg : ℕ → ℕ) (K : ℕ) (hsupp : ∀ k, K < k → deg k = 0)
    {r : ℝ} (hr0 : 0 < r) (hr : charPoly deg K r = 1) (n : ℕ) :
    renewalSeq deg r n ≤ 1 := by
  have h := gW_le_inv_root_pow deg K hsupp hr0 hr n
  have hpow : (0:ℝ) < r ^ n := by positivity
  have hid : (r⁻¹) ^ n * r ^ n = 1 := by
    rw [← mul_pow, inv_mul_cancel₀ (ne_of_gt hr0), one_pow]
  rw [renewalSeq]
  nlinarith

/-- The renewal identity: for areas above the maximal puncture area, the
normalised count is a convex combination of its predecessors, with the weights
`p_k = deg(k) r^k` summing to `1` by the characteristic equation. -/
lemma renewalSeq_eq (deg : ℕ → ℕ) (K : ℕ) (hsupp : ∀ k, K < k → deg k = 0)
    {r : ℝ} (n : ℕ) (hn : K ≤ n) (hn1 : 1 ≤ n) :
    renewalSeq deg r n
      = ∑ i ∈ range K, ((deg (i + 1) : ℝ) * r ^ (i + 1)) * renewalSeq deg r (n - 1 - i) := by
  obtain ⟨p, rfl⟩ : ∃ p, n = p + 1 := ⟨n - 1, by omega⟩
  have hstep : (gW deg (p + 1) : ℝ)
      = ∑ i ∈ range (p + 1), (deg (i + 1) : ℝ) * (gW deg (p - i) : ℝ) := by
    rw [gW_succ]
    push_cast
    ring
  have htrunc : ∑ i ∈ range (p + 1), (deg (i + 1) : ℝ) * (gW deg (p - i) : ℝ)
      = ∑ i ∈ range K, (deg (i + 1) : ℝ) * (gW deg (p - i) : ℝ) := by
    refine (Finset.sum_subset (Finset.range_subset_range.mpr (by omega : K ≤ p + 1)) (fun i hi hni => ?_)).symm
    have : K < i + 1 := by
      simp only [Finset.mem_range] at hi hni
      omega
    rw [hsupp _ this]
    simp
  rw [renewalSeq, hstep, htrunc, Finset.sum_mul]
  refine Finset.sum_congr rfl (fun i hi => ?_)
  simp only [Finset.mem_range] at hi
  have hsplit : p + 1 = (i + 1) + (p - i) := by omega
  have hidx : p + 1 - 1 - i = p - i := by omega
  rw [renewalSeq, hidx, hsplit, pow_add]
  ring

/-- **The renewal lower bound.**  The normalised count never drops below the
minimum of its first `K + 1` values, which is positive. -/
theorem renewalSeq_ge_inf (deg : ℕ → ℕ) (K : ℕ)
    (hsupp : ∀ k, K < k → deg k = 0) {r : ℝ} (hr0 : 0 < r) (hr : charPoly deg K r = 1)
    (n : ℕ) :
    ((range (K + 1)).inf' ⟨0, Finset.mem_range.2 (by omega)⟩ (renewalSeq deg r))
      ≤ renewalSeq deg r n := by
  set c : ℝ := (range (K + 1)).inf' ⟨0, Finset.mem_range.2 (by omega)⟩ (renewalSeq deg r) with hc
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hnK : n ≤ K
    · exact Finset.inf'_le _ (Finset.mem_range.2 (by omega))
    · have hn1 : 1 ≤ n := by omega
      rw [renewalSeq_eq deg K hsupp n (by omega) hn1]
      have hterm : ∀ i ∈ range K,
          ((deg (i + 1) : ℝ) * r ^ (i + 1)) * c
            ≤ ((deg (i + 1) : ℝ) * r ^ (i + 1)) * renewalSeq deg r (n - 1 - i) := by
        intro i hi
        simp only [Finset.mem_range] at hi
        have hIH := ih (n - 1 - i) (by omega)
        have hw : (0:ℝ) ≤ (deg (i + 1) : ℝ) * r ^ (i + 1) := by positivity
        exact mul_le_mul_of_nonneg_left hIH hw
      have hsum := Finset.sum_le_sum hterm
      have hfact : ∑ i ∈ range K, ((deg (i + 1) : ℝ) * r ^ (i + 1)) * c
          = (∑ i ∈ range K, (deg (i + 1) : ℝ) * r ^ (i + 1)) * c := by
        rw [Finset.sum_mul]
      rw [hfact] at hsum
      have hchar : ∑ i ∈ range K, (deg (i + 1) : ℝ) * r ^ (i + 1) = 1 := hr
      rw [hchar, one_mul] at hsum
      exact hsum

/-! ## The density equals `-log r` -/

set_option maxHeartbeats 1000000 in
/-- **The entropy density is the characteristic root.**  For a puncture model
with finitely many puncture types, the horizon entropy density is exactly
`-log r`, where `r` is the unique positive solution of the isolated-horizon
characteristic equation `∑_k deg(k) r^k = 1`. -/
theorem gEntropy_eq_neg_log_charRoot (deg : ℕ → ℕ) (K : ℕ) (hdeg1 : 1 ≤ deg 1)
    (hsupp : ∀ k, K < k → deg k = 0) {r : ℝ} (hr0 : 0 < r) (hr : charPoly deg K r = 1) :
    Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds (-Real.log r)) := by
  set c : ℝ := (range (K + 1)).inf' ⟨0, Finset.mem_range.2 (by omega)⟩ (renewalSeq deg r) with hc
  have hcpos : 0 < c := by
    rw [hc, Finset.lt_inf'_iff]
    exact fun b _ => renewalSeq_pos deg hdeg1 hr0 b
  -- `log (m n) / n` is squeezed between `log c / n` and `0`
  have hlow : ∀ n : ℕ, Real.log c / n ≤ Real.log (renewalSeq deg r n) / n := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have hnpos : (0:ℝ) < n := by exact_mod_cast hn
      have h := renewalSeq_ge_inf deg K hsupp hr0 hr n
      rw [← hc] at h
      have hlogle := Real.log_le_log hcpos h
      gcongr
  have hhigh : ∀ n : ℕ, Real.log (renewalSeq deg r n) / n ≤ 0 := by
    intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have hnpos : (0:ℝ) < n := by exact_mod_cast hn
      have h := renewalSeq_le_one deg K hsupp hr0 hr n
      have hlog : Real.log (renewalSeq deg r n) ≤ 0 :=
        Real.log_nonpos (le_of_lt (renewalSeq_pos deg hdeg1 hr0 n)) h
      exact div_nonpos_of_nonpos_of_nonneg hlog (le_of_lt hnpos)
  have hzero : Tendsto (fun n : ℕ => Real.log (renewalSeq deg r n) / n) atTop (nhds 0) := by
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le
      (tendsto_const_div_atTop_nhds_zero_nat (Real.log c)) tendsto_const_nhds hlow hhigh
  have hshift : Tendsto (fun n : ℕ => Real.log (renewalSeq deg r n) / n - Real.log r) atTop
      (nhds (-Real.log r)) := by
    have := hzero.sub_const (Real.log r)
    simpa using this
  refine hshift.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hgpos : (0:ℝ) < (gW deg n : ℝ) := by
    have : (1:ℝ) ≤ (gW deg n : ℝ) := by exact_mod_cast one_le_gW deg hdeg1 n
    linarith
  have hlogm : Real.log (renewalSeq deg r n) = Real.log (gW deg n) + n * Real.log r := by
    rw [renewalSeq, Real.log_mul (ne_of_gt hgpos) (by positivity), Real.log_pow]
  rw [hlogm]
  field_simp
  ring

/-! ## Strict monotonicity in the degeneracies -/

/-- The characteristic function is strictly increasing in the degeneracies. -/
lemma charPoly_lt_charPoly {deg deg' : ℕ → ℕ} (K : ℕ) (hmono : ∀ k, deg k ≤ deg' k)
    {i₀ : ℕ} (hi₀ : i₀ < K) (hlt : deg (i₀ + 1) < deg' (i₀ + 1)) {x : ℝ} (hx : 0 < x) :
    charPoly deg K x < charPoly deg' K x := by
  refine Finset.sum_lt_sum (fun i _ => ?_) ⟨i₀, Finset.mem_range.2 hi₀, ?_⟩
  · have h : (deg (i + 1) : ℝ) ≤ (deg' (i + 1) : ℝ) := by exact_mod_cast hmono (i + 1)
    have hp : (0:ℝ) < x ^ (i + 1) := by positivity
    nlinarith
  · have h : (deg (i₀ + 1) : ℝ) < (deg' (i₀ + 1) : ℝ) := by exact_mod_cast hlt
    have hp : (0:ℝ) < x ^ (i₀ + 1) := by positivity
    nlinarith

/-- **The characteristic root strictly decreases when a degeneracy increases.** -/
theorem charRoot_lt_charRoot {deg deg' : ℕ → ℕ} (K : ℕ) (hdeg1 : 1 ≤ deg 1) (hK : 1 ≤ K)
    (hmono : ∀ k, deg k ≤ deg' k) {i₀ : ℕ} (hi₀ : i₀ < K) (hlt : deg (i₀ + 1) < deg' (i₀ + 1))
    {r r' : ℝ} (hr0 : 0 < r) (hr : charPoly deg K r = 1)
    (hr0' : 0 < r') (hr' : charPoly deg' K r' = 1) : r' < r := by
  have hdeg1' : 1 ≤ deg' 1 := le_trans hdeg1 (hmono 1)
  have hstrict : charPoly deg' K r' < charPoly deg' K r := by
    rw [hr', ← hr]
    exact charPoly_lt_charPoly K hmono hi₀ hlt hr0
  exact ((charPoly_strictMonoOn deg' K hdeg1' hK).lt_iff_lt (le_of_lt hr0') (le_of_lt hr0)).1
    hstrict

/-- **Barbero–Immirzi rigidity.**  Increasing any single degeneracy strictly
increases the horizon entropy density; consequently the area quantum `γ = 4L`
fixed by the Bekenstein–Hawking normalisation `S = A/4` is a strictly increasing
function of the degeneracies. -/
theorem gDensity_strict_mono {deg deg' : ℕ → ℕ} (K : ℕ) (hdeg1 : 1 ≤ deg 1) (hK : 1 ≤ K)
    (hsupp : ∀ k, K < k → deg k = 0) (hsupp' : ∀ k, K < k → deg' k = 0)
    (hmono : ∀ k, deg k ≤ deg' k) {i₀ : ℕ} (hi₀ : i₀ < K) (hlt : deg (i₀ + 1) < deg' (i₀ + 1))
    {L L' : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L))
    (hL' : Tendsto (fun n : ℕ => Real.log (gW deg' n) / n) atTop (nhds L')) :
    L < L' := by
  have hdeg1' : 1 ≤ deg' 1 := le_trans hdeg1 (hmono 1)
  obtain ⟨r, hr0, _, hr⟩ := exists_charRoot deg K hdeg1 hK
  obtain ⟨r', hr0', _, hr'⟩ := exists_charRoot deg' K hdeg1' hK
  have hLr : L = -Real.log r :=
    tendsto_nhds_unique hL (gEntropy_eq_neg_log_charRoot deg K hdeg1 hsupp hr0 hr)
  have hLr' : L' = -Real.log r' :=
    tendsto_nhds_unique hL' (gEntropy_eq_neg_log_charRoot deg' K hdeg1' hsupp' hr0' hr')
  have hroot : r' < r := charRoot_lt_charRoot K hdeg1 hK hmono hi₀ hlt hr0 hr hr0' hr'
  rw [hLr, hLr']
  have := Real.log_lt_log hr0' hroot
  linarith

/-! ## A consistency check: the single-puncture-type model -/

/-- The model with a single puncture type of minimal area and `d` internal
states. -/
def singleDeg (d : ℕ) : ℕ → ℕ := fun k => if k = 1 then d else 0

lemma singleDeg_supp (d : ℕ) : ∀ k, 1 < k → singleDeg d k = 0 := by
  intro k hk
  simp only [singleDeg, if_neg (by omega : k ≠ 1)]

lemma singleDeg_one (d : ℕ) : singleDeg d 1 = d := by simp [singleDeg]

/-- In the single-type model the horizon has exactly `d^A` microstates. -/
lemma gW_singleDeg (d : ℕ) (n : ℕ) : gW (singleDeg d) n = d ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [gW_succ, Finset.sum_eq_single 0]
      · rw [singleDeg_one, Nat.sub_zero, ih, pow_succ]
        ring
      · intro i _ hi
        rw [singleDeg, if_neg (by omega : i + 1 ≠ 1)]
        ring
      · intro h
        exact absurd (Finset.mem_range.2 (Nat.succ_pos n)) h

lemma charPoly_singleDeg (d : ℕ) (hd : 1 ≤ d) : charPoly (singleDeg d) 1 (1 / d) = 1 := by
  have hdR : (0:ℝ) < d := by exact_mod_cast hd
  simp only [charPoly, Finset.sum_range_one, zero_add, pow_one, singleDeg_one]
  field_simp

/-- **Consistency check.**  Applying the characteristic-root theorem to the
single-puncture-type model recovers the obvious answer `log d`, matching the
exact count `W(A) = d^A`. -/
theorem gEntropy_singleType (d : ℕ) (hd : 1 ≤ d) :
    Tendsto (fun n : ℕ => Real.log (gW (singleDeg d) n) / n) atTop (nhds (Real.log d)) := by
  have hdR : (0:ℝ) < d := by exact_mod_cast hd
  have hr0 : (0:ℝ) < 1 / d := by positivity
  have h := gEntropy_eq_neg_log_charRoot (singleDeg d) 1 (by rw [singleDeg_one]; exact hd)
    (singleDeg_supp d) hr0 (charPoly_singleDeg d hd)
  have hlog : -Real.log (1 / d) = Real.log d := by
    rw [one_div, Real.log_inv, neg_neg]
  rwa [hlog] at h

end Universal
end BekensteinHawking