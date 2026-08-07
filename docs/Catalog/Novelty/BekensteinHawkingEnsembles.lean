import Novelty.BekensteinHawkingThermodynamics

/-!
# Ensemble inequivalence at the Hagedorn point of the quantum horizon

`Novelty.BekensteinHawkingThermodynamics` shows that the canonical partition
function of the horizon gas,

`Z(x) = ∑_A W(A) x^A`,   `x = e^{-β}` per area quantum,

converges exactly for `x < x_c := 1/(2+√2)` and equals `(1-x)²/(2x²-4x+1)` there.
This file analyses the *approach* to the critical fugacity `x_c`, i.e. to the
Hagedorn temperature `T_H = 1/log (2+√2)`.

## Main results

* `half_le_hStates_mul_crit_pow` : at the critical fugacity every area
  contributes at least `1/2` to the partition sum — the microcanonical
  degeneracy exactly cancels the Boltzmann weight;
* `partitionFunction_tendsto_atTop` : consequently `Z(x) → ∞` as `x ↑ x_c`, the
  Hagedorn divergence;
* `meanArea_tendsto_atTop` : **ensemble inequivalence.**  The canonical mean
  horizon area `⟨A⟩(x) = (∑_A A W(A) x^A)/Z(x)` diverges to `+∞` as `x ↑ x_c`.
  Hence no finite horizon area can be prepared at temperatures approaching
  `T_H`, and the canonical description of the horizon breaks down there even
  though the microcanonical entropy density is perfectly finite.

The proof of the divergence of `⟨A⟩` is purely microcanonical: it uses only the
lower bound `W(A) ≥ (2+√2)^A/2` (`hStates_bounds`) together with the tail
decomposition of the partition sum, and never differentiates the closed form.
This closes the mean-area part of Conjecture 5 of `FUTURE_DIRECTIONS.md`.
-/

open Finset Filter Topology

namespace BekensteinHawking

/-- The critical (Hagedorn) fugacity `x_c = 1/(2+√2)`. -/
noncomputable def hagedornFugacity : ℝ := growth⁻¹

lemma hagedornFugacity_pos : 0 < hagedornFugacity := inv_pos.2 growth_pos

/-- The canonical partition function of the horizon gas. -/
noncomputable def partitionFunction (x : ℝ) : ℝ := ∑' n : ℕ, (hStates n : ℝ) * x ^ n

/-- The area-weighted partition sum `∑ A W(A) x^A`. -/
noncomputable def areaWeighted (x : ℝ) : ℝ := ∑' n : ℕ, (n : ℝ) * ((hStates n : ℝ) * x ^ n)

/-- The canonical mean horizon area at fugacity `x`. -/
noncomputable def meanArea (x : ℝ) : ℝ := areaWeighted x / partitionFunction x

lemma term_nonneg {x : ℝ} (hx : 0 ≤ x) (n : ℕ) : 0 ≤ (hStates n : ℝ) * x ^ n := by
  have : (0:ℝ) ≤ (hStates n : ℝ) := Nat.cast_nonneg _
  positivity

lemma summable_partition {x : ℝ} (hx0 : 0 ≤ x) (hx : x < hagedornFugacity) :
    Summable (fun n : ℕ => (hStates n : ℝ) * x ^ n) :=
  (partition_function_summable_iff x hx0).mpr hx

/-- The area-weighted sum converges below the Hagedorn point. -/
lemma summable_areaWeighted {x : ℝ} (hx0 : 0 ≤ x) (hx : x < hagedornFugacity) :
    Summable (fun n : ℕ => (n : ℝ) * ((hStates n : ℝ) * x ^ n)) := by
  have hgpos : (0:ℝ) < growth := growth_pos
  simp only [hagedornFugacity] at hx
  have hgx : growth * x < 1 := by
    have h := mul_lt_mul_of_pos_left hx hgpos
    rwa [mul_inv_cancel₀ (ne_of_gt hgpos)] at h
  have hr : ‖growth * x‖ < 1 := by
    rw [Real.norm_eq_abs, abs_of_nonneg (by positivity)]
    exact hgx
  refine Summable.of_nonneg_of_le (fun n => by
    have := term_nonneg hx0 n
    positivity) (fun n => ?_)
    (summable_pow_mul_geometric_of_norm_lt_one 1 hr)
  have h1 : (hStates n : ℝ) * x ^ n ≤ (growth * x) ^ n := by
    rw [mul_pow]
    have hx' : (0:ℝ) ≤ x ^ n := by positivity
    nlinarith [hStates_le_pow n]
  have hn : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg _
  calc (n : ℝ) * ((hStates n : ℝ) * x ^ n) ≤ (n : ℝ) * (growth * x) ^ n := by nlinarith
    _ = (n : ℝ) ^ 1 * (growth * x) ^ n := by ring

lemma partitionFunction_pos {x : ℝ} (hx0 : 0 ≤ x) (hx : x < hagedornFugacity) :
    0 < partitionFunction x := by
  refine (summable_partition hx0 hx).tsum_pos (fun n => term_nonneg hx0 n) 0 ?_
  simp

lemma sum_le_partitionFunction {x : ℝ} (hx0 : 0 ≤ x) (hx : x < hagedornFugacity) (N : ℕ) :
    ∑ n ∈ range N, (hStates n : ℝ) * x ^ n ≤ partitionFunction x :=
  (summable_partition hx0 hx).sum_le_tsum _ (fun i _ => term_nonneg hx0 i)

/-! ## The critical fugacity exactly cancels the degeneracy -/

/-- At the Hagedorn fugacity each area of at least one quantum contributes at
least `1/2` to the partition sum: the exponential growth `W(A) ≥ (2+√2)^A/2` of
the microstate count exactly compensates the Boltzmann factor `x_c^A`. -/
lemma half_le_hStates_mul_crit_pow (n : ℕ) (hn : 1 ≤ n) :
    (1:ℝ)/2 ≤ (hStates n : ℝ) * hagedornFugacity ^ n := by
  have hgpos : (0:ℝ) < growth := growth_pos
  have hpow : (0:ℝ) < growth ^ n := by positivity
  have hxc : hagedornFugacity ^ n = (growth ^ n)⁻¹ := by
    rw [hagedornFugacity, inv_pow]
  have hlow : growth ^ n / 2 ≤ (hStates n : ℝ) := (hStates_bounds n hn).1
  rw [hxc]
  have hinv : (0:ℝ) < (growth ^ n)⁻¹ := by positivity
  have h1 := mul_le_mul_of_nonneg_right hlow (le_of_lt hinv)
  have h2 : (growth ^ n / 2) * (growth ^ n)⁻¹ = 1/2 := by
    field_simp
  linarith

/-- The partial sums of the partition function at the critical fugacity grow at
least linearly. -/
lemma half_mul_le_sum_crit (N : ℕ) :
    (N : ℝ)/2 ≤ ∑ n ∈ range (N + 1), (hStates n : ℝ) * hagedornFugacity ^ n := by
  induction N with
  | zero => simp
  | succ N ih =>
      rw [Finset.sum_range_succ]
      have h := half_le_hStates_mul_crit_pow (N + 1) (by omega)
      push_cast
      push_cast at ih
      linarith

/-! ## Hagedorn divergence of the partition function -/

lemma eventually_pos_nhdsWithin :
    ∀ᶠ x in 𝓝[<] hagedornFugacity, 0 < x :=
  nhdsWithin_le_nhds (Ioi_mem_nhds hagedornFugacity_pos)

lemma continuous_partialSum (N : ℕ) :
    Continuous (fun x : ℝ => ∑ n ∈ range (N + 1), (hStates n : ℝ) * x ^ n) := by
  refine continuous_finset_sum _ (fun n _ => ?_)
  exact continuous_const.mul (continuous_pow n)

/-- **Hagedorn divergence.**  The canonical partition function of the horizon gas
blows up as the fugacity approaches the critical value `1/(2+√2)`, i.e. as the
temperature approaches `T_H = 1/log (2+√2)` from below. -/
theorem partitionFunction_tendsto_atTop :
    Tendsto partitionFunction (𝓝[<] hagedornFugacity) atTop := by
  rw [tendsto_atTop]
  intro K
  obtain ⟨N, hN⟩ : ∃ N : ℕ, K + 1 ≤ (N : ℝ)/2 := by
    refine ⟨⌈2 * K + 2⌉₊, ?_⟩
    have h := Nat.le_ceil (2 * K + 2)
    linarith
  set P : ℝ → ℝ := fun x => ∑ n ∈ range (N + 1), (hStates n : ℝ) * x ^ n with hP
  have hPc : K < P hagedornFugacity := by
    have := half_mul_le_sum_crit N
    simp only [hP]
    linarith
  have hev : ∀ᶠ x in 𝓝 hagedornFugacity, K < P x :=
    Filter.Tendsto.eventually_const_lt hPc ((continuous_partialSum N).tendsto _)
  filter_upwards [hev.filter_mono nhdsWithin_le_nhds, eventually_pos_nhdsWithin,
    self_mem_nhdsWithin] with x h1 h2 h3
  have h3' : x < hagedornFugacity := h3
  exact le_trans (le_of_lt h1) (sum_le_partitionFunction (le_of_lt h2) h3' (N + 1))

/-! ## Divergence of the mean area: ensemble inequivalence -/

set_option maxHeartbeats 1000000 in
/-- **Ensemble inequivalence at the Hagedorn point.**  The canonical mean horizon
area diverges as the fugacity approaches `x_c = 1/(2+√2)`.  Therefore the
canonical ensemble cannot describe a horizon of any prescribed finite area at
temperatures near the Hagedorn temperature, while the microcanonical ensemble is
perfectly well defined at every area: the two ensembles are inequivalent. -/
theorem meanArea_tendsto_atTop :
    Tendsto meanArea (𝓝[<] hagedornFugacity) atTop := by
  rw [tendsto_atTop]
  intro K
  set M : ℕ := ⌈K⌉₊ + 1 with hM
  have hKM : K ≤ (M : ℝ) - 1 := by
    have := Nat.le_ceil K
    simp only [hM]
    push_cast
    linarith
  have hM1 : (1:ℝ) ≤ (M : ℝ) := by
    have : (1:ℕ) ≤ M := by omega
    exact_mod_cast this
  set C : ℝ := ∑ n ∈ range M, (hStates n : ℝ) * hagedornFugacity ^ n with hC
  have hC0 : 0 ≤ C := by
    refine Finset.sum_nonneg (fun n _ => term_nonneg (le_of_lt hagedornFugacity_pos) n)
  have hbig : ∀ᶠ x in 𝓝[<] hagedornFugacity, (M : ℝ) * C + 1 ≤ partitionFunction x :=
    (tendsto_atTop.1 partitionFunction_tendsto_atTop) ((M : ℝ) * C + 1)
  filter_upwards [hbig, eventually_pos_nhdsWithin, self_mem_nhdsWithin] with x hS hx0 hxlt
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxlt' : x < hagedornFugacity := hxlt
  have hsumW := summable_partition hx0' hxlt'
  have hsumA := summable_areaWeighted hx0' hxlt'
  have hSpos : 0 < partitionFunction x := partitionFunction_pos hx0' hxlt'
  -- the head of the partition sum is bounded by its critical value
  have hPM : ∑ n ∈ range M, (hStates n : ℝ) * x ^ n ≤ C := by
    refine Finset.sum_le_sum (fun n _ => ?_)
    have hpow : x ^ n ≤ hagedornFugacity ^ n :=
      pow_le_pow_left₀ hx0' (le_of_lt hxlt') n
    have : (0:ℝ) ≤ (hStates n : ℝ) := Nat.cast_nonneg _
    nlinarith
  -- the tail of the partition sum
  have htail : partitionFunction x - ∑ n ∈ range M, (hStates n : ℝ) * x ^ n
      = ∑' i : ℕ, (hStates (i + M) : ℝ) * x ^ (i + M) := by
    have := hsumW.sum_add_tsum_nat_add M
    simp only [partitionFunction]
    linarith
  have hsumWtail : Summable (fun i : ℕ => (hStates (i + M) : ℝ) * x ^ (i + M)) :=
    (summable_nat_add_iff M).2 hsumW
  have hsumAtail : Summable (fun i : ℕ => ((i + M : ℕ) : ℝ) * ((hStates (i + M) : ℝ) * x ^ (i + M)))
      := (summable_nat_add_iff M).2 hsumA
  -- the area-weighted sum dominates `M` times the tail
  have hnum : (M : ℝ) * (∑' i : ℕ, (hStates (i + M) : ℝ) * x ^ (i + M)) ≤ areaWeighted x := by
    have h2 : ∑' i : ℕ, (M : ℝ) * ((hStates (i + M) : ℝ) * x ^ (i + M))
        ≤ ∑' i : ℕ, ((i + M : ℕ) : ℝ) * ((hStates (i + M) : ℝ) * x ^ (i + M)) := by
      refine Summable.tsum_le_tsum (fun i => ?_) (hsumWtail.mul_left _) hsumAtail
      have hterm := term_nonneg hx0' (i + M)
      have hcast : (M : ℝ) ≤ ((i + M : ℕ) : ℝ) := by
        have : M ≤ i + M := by omega
        exact_mod_cast this
      nlinarith
    rw [tsum_mul_left] at h2
    have h3 := hsumA.sum_add_tsum_nat_add M
    have h4 : 0 ≤ ∑ n ∈ range M, (n : ℝ) * ((hStates n : ℝ) * x ^ n) := by
      refine Finset.sum_nonneg (fun n _ => ?_)
      have := term_nonneg hx0' n
      positivity
    simp only [areaWeighted]
    linarith
  rw [meanArea, le_div_iff₀ hSpos]
  have hkey : (M : ℝ) * (partitionFunction x - ∑ n ∈ range M, (hStates n : ℝ) * x ^ n)
      ≤ areaWeighted x := by rw [htail]; exact hnum
  set S := partitionFunction x with hSdef
  set P := ∑ n ∈ range M, (hStates n : ℝ) * x ^ n with hPdef
  have e0 : K * S ≤ ((M:ℝ) - 1) * S := mul_le_mul_of_nonneg_right hKM (le_of_lt hSpos)
  have e0' : K * S ≤ (M:ℝ) * S - S := by
    have : ((M:ℝ) - 1) * S = (M:ℝ) * S - S := by ring
    linarith
  have e2 : (M:ℝ) * P ≤ (M:ℝ) * C := mul_le_mul_of_nonneg_left hPM (by linarith)
  have e3 : (M:ℝ) * (S - P) = (M:ℝ) * S - (M:ℝ) * P := by ring
  linarith

end BekensteinHawking