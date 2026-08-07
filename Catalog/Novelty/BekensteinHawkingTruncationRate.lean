import Novelty.BekensteinHawkingCharacteristicRootGeneral

/-!
# An exponential truncation rate: a finite certificate for the entropy density

`Novelty.BekensteinHawkingCharacteristicRootGeneral` identifies the entropy density of an
arbitrary puncture model with `-log r`, where `r` solves the isolated-horizon characteristic
equation `∑_{k ≥ 1} deg(k) r^k = 1`.  Qualitatively this makes the densities of the truncated
models `deg_K` (only puncture areas `≤ K` allowed) converge upwards to the density of the
full model.  `FUTURE_DIRECTIONS.md`, Conjecture 4, asks for the *rate*, i.e. for an effective
version: how large must `K` be before the truncated model certifies the density — and with it
the Barbero–Immirzi parameter `γ = 4L` — to a prescribed accuracy?

This file closes that conjecture with explicit constants.  Under the standing hypotheses
`deg k ≤ B^k` and `B·r < 1` (the characteristic root lies strictly inside the radius of
convergence forced by the growth bound):

* `charRoot_trunc_ge` : the truncated root dominates, `r ≤ r_K`;
* `charTail_le` : the characteristic tail is geometric,
  `1 - ∑_{k ≤ K} deg(k) r^k ≤ (Br)^{K+1}/(1 - Br)`;
* `charRoot_trunc_sub_le` : hence `r_K - r ≤ (Br)^{K+1}/(1 - Br)`.  The linear term
  `deg(1)·(r_K - r) ≥ r_K - r` of the truncated characteristic function is what converts the
  tail bound into a bound on the root;
* `density_truncation_rate` : **the effective statement.**
  `0 ≤ L - L_K ≤ (B/(1 - Br))·(Br)^K`.  So `L`, and therefore `γ = 4L`, is certified to
  accuracy `ε` by the finite model of size `K = O(log (1/ε))`;
* `density_truncation_tendsto` : consequently the truncated densities converge to `L`.

Together with `gDensity_strict_mono` (the truncated densities increase strictly) this makes
the entropy density of an infinite puncture model a genuinely computable quantity.
-/

open Finset Filter Topology

namespace BekensteinHawking
namespace Universal

section TruncationRate

variable {deg : ℕ → ℕ} {B K : ℕ} {r : ℝ}

/-- Under the growth bound `deg k ≤ B^k` each characteristic term is dominated by the
corresponding term of the geometric series with ratio `Br`. -/
lemma charTerm_le_geom (hdegB : ∀ k, deg k ≤ B ^ k) (hr0 : 0 ≤ r) (i : ℕ) :
    charTerm deg r i ≤ ((B : ℝ) * r) ^ (i + 1) := by
  have hd : ((deg (i + 1) : ℕ) : ℝ) ≤ ((B : ℝ)) ^ (i + 1) := by
    have h := hdegB (i + 1)
    have : ((deg (i + 1) : ℕ) : ℝ) ≤ ((B ^ (i + 1) : ℕ) : ℝ) := by exact_mod_cast h
    simpa using this
  have hp : (0:ℝ) ≤ r ^ (i + 1) := by positivity
  rw [charTerm, mul_pow]
  exact mul_le_mul_of_nonneg_right hd hp

/-- **The characteristic tail is geometric.**  The mass of the characteristic series carried
by puncture areas larger than `K` is at most `(Br)^{K+1}/(1-Br)`. -/
lemma charTail_le (hdegB : ∀ k, deg k ≤ B ^ k) (hr0 : 0 < r) (hbr : (B : ℝ) * r < 1)
    (htsum : ∑' i, charTerm deg r i = 1) :
    1 - charPoly (degTrunc deg K) K r ≤ ((B : ℝ) * r) ^ (K + 1) / (1 - (B : ℝ) * r) := by
  have hsum := summable_charTerm deg htsum
  have hbr0 : (0:ℝ) ≤ (B : ℝ) * r := by positivity
  have hgeo : Summable (fun i : ℕ => ((B : ℝ) * r) ^ i) :=
    summable_geometric_of_lt_one hbr0 hbr
  have hgeo' : Summable (fun i : ℕ => ((B : ℝ) * r) ^ (K + 1) * ((B : ℝ) * r) ^ i) :=
    hgeo.mul_left _
  have htailsum : Summable (fun i : ℕ => charTerm deg r (i + K)) :=
    (summable_nat_add_iff K).2 hsum
  have hsplit := hsum.sum_add_tsum_nat_add (f := charTerm deg r) K
  rw [htsum] at hsplit
  have hle : ∑' i : ℕ, charTerm deg r (i + K)
      ≤ ∑' i : ℕ, ((B : ℝ) * r) ^ (K + 1) * ((B : ℝ) * r) ^ i := by
    refine htailsum.tsum_le_tsum (fun i => ?_) hgeo'
    have h := charTerm_le_geom hdegB (le_of_lt hr0) (i + K)
    calc charTerm deg r (i + K) ≤ ((B : ℝ) * r) ^ (i + K + 1) := h
      _ = ((B : ℝ) * r) ^ (K + 1) * ((B : ℝ) * r) ^ i := by rw [← pow_add]; ring_nf
  rw [tsum_mul_left, tsum_geometric_of_lt_one hbr0 hbr] at hle
  have hcp : charPoly (degTrunc deg K) K r = ∑ i ∈ range K, charTerm deg r i :=
    charPoly_degTrunc deg K r
  rw [hcp]
  have : ((B : ℝ) * r) ^ (K + 1) * (1 - (B : ℝ) * r)⁻¹
      = ((B : ℝ) * r) ^ (K + 1) / (1 - (B : ℝ) * r) := by
    rw [div_eq_mul_inv]
  linarith [hle, hsplit, this ▸ hle]

/-- The truncated root dominates the true root. -/
lemma charRoot_trunc_ge (hdeg1 : 1 ≤ deg 1) (hK : 1 ≤ K) (hr0 : 0 < r)
    (htsum : ∑' i, charTerm deg r i = 1) {rK : ℝ} (hrK0 : 0 < rK)
    (hrK : charPoly (degTrunc deg K) K rK = 1) : r ≤ rK := by
  have hd1 : 1 ≤ degTrunc deg K 1 := by rw [degTrunc_one deg hK]; exact hdeg1
  have hsum := summable_charTerm deg htsum
  have hcp : charPoly (degTrunc deg K) K r = ∑ i ∈ range K, charTerm deg r i :=
    charPoly_degTrunc deg K r
  have hle : charPoly (degTrunc deg K) K r ≤ 1 := by
    rw [hcp]
    exact sum_charTerm_le_one deg (le_of_lt hr0) htsum K
  by_contra hcon
  push_neg at hcon
  have := (charPoly_strictMonoOn (degTrunc deg K) K hd1 hK) (le_of_lt hrK0) (le_of_lt hr0) hcon
  rw [hrK] at this
  linarith

/-- **The root moves by at most the tail.**  The linear term of the truncated characteristic
function converts the geometric tail bound into a bound on the displacement of the root. -/
theorem charRoot_trunc_sub_le (hdeg1 : 1 ≤ deg 1) (hdegB : ∀ k, deg k ≤ B ^ k) (hK : 1 ≤ K)
    (hr0 : 0 < r) (hbr : (B : ℝ) * r < 1) (htsum : ∑' i, charTerm deg r i = 1)
    {rK : ℝ} (hrK0 : 0 < rK) (hrK : charPoly (degTrunc deg K) K rK = 1) :
    rK - r ≤ ((B : ℝ) * r) ^ (K + 1) / (1 - (B : ℝ) * r) := by
  have hge : r ≤ rK := charRoot_trunc_ge hdeg1 hK hr0 htsum hrK0 hrK
  have hd1 : 1 ≤ degTrunc deg K 1 := by rw [degTrunc_one deg hK]; exact hdeg1
  -- the difference of the truncated characteristic function dominates its linear term
  have hlin : rK - r ≤ charPoly (degTrunc deg K) K rK - charPoly (degTrunc deg K) K r := by
    rw [charPoly, charPoly, ← Finset.sum_sub_distrib]
    have hterm : ∀ i ∈ range K, (0:ℝ) ≤ (degTrunc deg K (i + 1) : ℝ) * rK ^ (i + 1)
        - (degTrunc deg K (i + 1) : ℝ) * r ^ (i + 1) := by
      intro i _
      have hp : r ^ (i + 1) ≤ rK ^ (i + 1) := pow_le_pow_left₀ (le_of_lt hr0) hge _
      have hd : (0:ℝ) ≤ (degTrunc deg K (i + 1) : ℝ) := Nat.cast_nonneg _
      nlinarith
    have hmem : (0:ℕ) ∈ range K := Finset.mem_range.2 hK
    have hsingle : (degTrunc deg K (0 + 1) : ℝ) * rK ^ (0 + 1)
        - (degTrunc deg K (0 + 1) : ℝ) * r ^ (0 + 1)
        ≤ ∑ i ∈ range K, ((degTrunc deg K (i + 1) : ℝ) * rK ^ (i + 1)
            - (degTrunc deg K (i + 1) : ℝ) * r ^ (i + 1)) :=
      Finset.single_le_sum hterm hmem
    have hd1' : (1:ℝ) ≤ (degTrunc deg K 1 : ℝ) := by exact_mod_cast hd1
    simp only [zero_add, pow_one] at hsingle
    nlinarith
  have htail := charTail_le (K := K) hdegB hr0 hbr htsum
  rw [hrK] at hlin
  linarith

/-- **The effective area law: an exponentially small truncation error.**  For a model with
degeneracies bounded by `B^k` whose characteristic root satisfies `Br < 1`, the entropy
density `L` of the full model and the density `L_K` of the model truncated at puncture area
`K` differ by at most `(B/(1-Br))·(Br)^K`.  Hence `L` — and with it the Barbero–Immirzi
parameter fixed by the Bekenstein–Hawking normalisation — is certified to accuracy `ε` by a
computation with `O(log (1/ε))` puncture types. -/
theorem density_truncation_rate (hdeg1 : 1 ≤ deg 1) (hdegB : ∀ k, deg k ≤ B ^ k) (hK : 1 ≤ K)
    (hr0 : 0 < r) (hbr : (B : ℝ) * r < 1) (htsum : ∑' i, charTerm deg r i = 1)
    {L LK : ℝ}
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L))
    (hLK : Tendsto (fun n : ℕ => Real.log (gW (degTrunc deg K) n) / n) atTop (nhds LK)) :
    0 ≤ L - LK ∧ L - LK ≤ ((B : ℝ) / (1 - (B : ℝ) * r)) * ((B : ℝ) * r) ^ K := by
  have hd1 : 1 ≤ degTrunc deg K 1 := by rw [degTrunc_one deg hK]; exact hdeg1
  obtain ⟨rK, hrK0, _, hrK⟩ := exists_charRoot (degTrunc deg K) K hd1 hK
  have hLKval : LK = -Real.log rK :=
    tendsto_nhds_unique hLK
      (gEntropy_eq_neg_log_charRoot (degTrunc deg K) K hd1 (degTrunc_supp deg K) hrK0 hrK)
  have hLval : L = -Real.log r := gEntropy_eq_neg_log_charRoot_general deg hdeg1 hr0 htsum hL
  have hge : r ≤ rK := charRoot_trunc_ge hdeg1 hK hr0 htsum hrK0 hrK
  have hsub := charRoot_trunc_sub_le hdeg1 hdegB hK hr0 hbr htsum hrK0 hrK
  have hlogmono : Real.log r ≤ Real.log rK := Real.log_le_log hr0 hge
  refine ⟨by rw [hLval, hLKval]; linarith, ?_⟩
  -- `log rK - log r ≤ (rK - r)/r`
  have hquot : Real.log rK - Real.log r ≤ (rK - r) / r := by
    have h1 : Real.log (rK / r) ≤ rK / r - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (ne_of_gt hrK0) (ne_of_gt hr0)] at h1
    have h2 : rK / r - 1 = (rK - r) / r := by field_simp
    linarith [h1, h2 ▸ h1]
  have hden : 0 < 1 - (B : ℝ) * r := by linarith
  have hstep : (rK - r) / r ≤ ((B : ℝ) / (1 - (B : ℝ) * r)) * ((B : ℝ) * r) ^ K := by
    have h1 : (rK - r) / r ≤ (((B : ℝ) * r) ^ (K + 1) / (1 - (B : ℝ) * r)) / r :=
      div_le_div_of_nonneg_right hsub (le_of_lt hr0)
    have h2 : (((B : ℝ) * r) ^ (K + 1) / (1 - (B : ℝ) * r)) / r
        = ((B : ℝ) / (1 - (B : ℝ) * r)) * ((B : ℝ) * r) ^ K := by
      rw [pow_succ]
      field_simp
    linarith [h1, h2 ▸ h1]
  rw [hLval, hLKval]
  linarith

/-- **Convergence of the finite certificates.**  The densities of the truncated models
converge to the density of the full model (exponentially fast, by
`density_truncation_rate`). -/
theorem density_truncation_tendsto (hdeg1 : 1 ≤ deg 1) (hdegB : ∀ k, deg k ≤ B ^ k)
    (hr0 : 0 < r) (hbr : (B : ℝ) * r < 1) (htsum : ∑' i, charTerm deg r i = 1)
    {L : ℝ} (LK : ℕ → ℝ)
    (hL : Tendsto (fun n : ℕ => Real.log (gW deg n) / n) atTop (nhds L))
    (hLK : ∀ K, 1 ≤ K →
      Tendsto (fun n : ℕ => Real.log (gW (degTrunc deg K) n) / n) atTop (nhds (LK K))) :
    Tendsto LK atTop (nhds L) := by
  have hbr0 : (0:ℝ) ≤ (B : ℝ) * r := by positivity
  have hden : 0 < 1 - (B : ℝ) * r := by linarith
  have hpow : Tendsto (fun K : ℕ => ((B : ℝ) / (1 - (B : ℝ) * r)) * ((B : ℝ) * r) ^ K) atTop
      (nhds 0) := by
    have := tendsto_pow_atTop_nhds_zero_of_lt_one hbr0 hbr
    simpa using this.const_mul ((B : ℝ) / (1 - (B : ℝ) * r))
  have hlow : Tendsto (fun K : ℕ => L - ((B : ℝ) / (1 - (B : ℝ) * r)) * ((B : ℝ) * r) ^ K)
      atTop (nhds L) := by
    have := (tendsto_const_nhds (x := L) (f := atTop (α := ℕ))).sub hpow
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with K hK
    exact (sub_le_comm.mp
      (density_truncation_rate hdeg1 hdegB hK hr0 hbr htsum hL (hLK K hK)).2)
  · filter_upwards [eventually_ge_atTop 1] with K hK
    linarith [(density_truncation_rate hdeg1 hdegB hK hr0 hbr htsum hL (hLK K hK)).1]

end TruncationRate

/-! ## The concrete isolated-horizon model -/

lemma succ_le_two_pow (k : ℕ) : k + 1 ≤ 2 ^ k := Nat.lt_two_pow_self

lemma charTerm_concrete (y : ℝ) (i : ℕ) :
    charTerm (fun k => k + 1) y i = ((i : ℝ) + 2) * y ^ (i + 1) := by
  rw [charTerm]
  push_cast
  ring

lemma two_mul_inv_growth_lt_one : 2 * growth⁻¹ < 1 := by
  have hg : (0:ℝ) < growth := growth_pos
  rw [mul_inv_lt_iff₀ hg, one_mul]
  unfold growth
  nlinarith [one_lt_sqrt_two]

/-- **A concrete finite certificate for the Bekenstein–Hawking area quantum.**  For the
Ashtekar–Baez–Corichi–Krasnov model `deg k = k+1`, truncating at spin label `K` under-
estimates the entropy density `log (2+√2)` by at most `(2/(1-2x_c))·(2x_c)^K` with
`x_c = 1/(2+√2)`, i.e. by at most `4.83·(0.586)^K`: the area quantum is computable to any
prescribed accuracy from finitely many puncture types. -/
theorem entropyDensity_truncation_rate {K : ℕ} (hK : 1 ≤ K) {LK : ℝ}
    (hLK : Tendsto (fun n : ℕ =>
      Real.log (gW (degTrunc (fun k => k + 1) K) n) / n) atTop (nhds LK)) :
    0 ≤ entropyDensity - LK ∧
      entropyDensity - LK ≤ (2 / (1 - 2 * growth⁻¹)) * (2 * growth⁻¹) ^ K := by
  have hr0 : (0:ℝ) < growth⁻¹ := inv_pos.2 growth_pos
  have htsum : ∑' i, charTerm (fun k => k + 1) growth⁻¹ i = 1 := by
    rw [tsum_congr (charTerm_concrete growth⁻¹)]
    exact characteristic_equation
  have hbr : ((2:ℕ) : ℝ) * growth⁻¹ < 1 := by
    push_cast
    exact two_mul_inv_growth_lt_one
  have h := density_truncation_rate (deg := fun k => k + 1) (B := 2) (by norm_num)
    (fun k => succ_le_two_pow k) hK hr0 hbr htsum entropyDensity_eq_universal_limit hLK
  simpa using h

end Universal
end BekensteinHawking