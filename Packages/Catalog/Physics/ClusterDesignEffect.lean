/-
# Why 76.8 million pairs are not 76.8 million observations

## Provenance (round-75 #3, exp 569b, paper 220)

`exp569b` drew `600 000` samples for each of `128` band-9 bitlen-96 semiprimes: `76.8M`
paired evaluations, `2.15×` the paper-214 pilot.  The reported intervals are *cluster*
bootstrap intervals — resampled over the `128` moduli, not over the `76.8M` pairs — and the
audit needs the reason why that is not conservatism but necessity.

This file proves the reason exactly.  In a two-level design with `k` clusters (the moduli)
and `m` draws inside each cluster (the samples per modulus), sharing a cluster-level
component of correlation `ρ`, the variance of the grand mean is

  `Var = σ² (1 + (m-1)ρ) / (k m)`,

the classical *design effect* `1 + (m-1)ρ`, and — the operative consequence —

  `Var ≥ ρ σ² / k`   *for every* `m`.

Enlarging `m` from `150 000` to `600 000` per modulus cannot buy precision beyond the
cluster ceiling `ρσ²/k`; only enlarging `k`, or drawing a *fresh population of moduli under a
different master seed*, can.  This is the quantitative form of the lab-wide rule adopted in
this round: replication legs must vary the master seed, because more samples on the same `128`
moduli converge to a *biased-looking* limit of finite precision, not to the truth.

## Main results

* `ClusterModel.var_grandMean` — the design-effect identity `σ²(1 + (m-1)ρ)/(km)`.
* `ClusterModel.designEffect_ge_one` — sub-sampling within a cluster never beats i.i.d.
* `ClusterModel.var_grandMean_ge_cluster_floor` — **the ceiling**: `Var ≥ ρσ²/k`, uniformly
  in `m`.  The `76.8M` pairs are worth at most `k/ρ` independent draws.
* `ClusterModel.effectiveSampleSize_le` — the effective sample size is `≤ k/ρ`.
* `var_grandMean_tendsto_cluster_floor` — the limit is *attained*: as `m → ∞` the variance
  decreases to exactly `ρσ²/k`, so the ceiling is sharp, not a slack bound.
* `exp569b_effective_size_bound` — with the run's `k = 128` and an intra-modulus correlation of
  only `ρ = 1/100`, the whole `76.8M`-pair run carries no more information than `12 800`
  independent evaluations, whatever `m`.
* `clusterModel_exists` — the axioms are satisfiable for every `0 ≤ ρ ≤ 1`, so none of the
  above is vacuous.
-/
import Mathlib

namespace Catalog.Physics.ClusterDesign

open Finset RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- A two-level (clustered) measurement: `k` clusters — here the semiprime moduli — each
carrying `m` draws.  Readouts inside a cluster are equicorrelated with intra-cluster
correlation `ρ`; readouts in different clusters are uncorrelated.  Inner product =
covariance. -/
structure ClusterModel (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (k m : ℕ) where
  /-- the centred readout of draw `j` in cluster `i` -/
  obs : Fin k → Fin m → E
  /-- per-draw standard deviation -/
  sigma : ℝ
  /-- intra-cluster correlation -/
  rho : ℝ
  sigma_pos : 0 < sigma
  rho_nonneg : 0 ≤ rho
  rho_le_one : rho ≤ 1
  self : ∀ i j, ⟪obs i j, obs i j⟫ = sigma ^ 2
  within : ∀ i j j', j ≠ j' → ⟪obs i j, obs i j'⟫ = rho * sigma ^ 2
  between : ∀ i i' j j', i ≠ i' → ⟪obs i j, obs i' j'⟫ = 0

namespace ClusterModel

variable {k m : ℕ} (C : ClusterModel E k m)

/-- The grand mean over all `k m` draws. -/
noncomputable def grandMean : E :=
  (((k : ℝ) * (m : ℝ))⁻¹) • ∑ i : Fin k, ∑ j : Fin m, C.obs i j

/-- Covariance of a single readout with the total sum: only its own cluster contributes, and
inside that cluster all `m - 1` siblings contribute `ρσ²`. -/
theorem inner_obs_total (i : Fin k) (j : Fin m) :
    ⟪C.obs i j, ∑ i' : Fin k, ∑ j' : Fin m, C.obs i' j'⟫
      = C.sigma ^ 2 * (1 + ((m : ℝ) - 1) * C.rho) := by
  have hclusters : ⟪C.obs i j, ∑ i' : Fin k, ∑ j' : Fin m, C.obs i' j'⟫
      = ⟪C.obs i j, ∑ j' : Fin m, C.obs i j'⟫ := by
    rw [inner_sum]
    refine Finset.sum_eq_single_of_mem i (Finset.mem_univ i) ?_
    intro b _ hb
    rw [inner_sum, Finset.sum_eq_zero]
    intro j' _
    exact C.between i b j j' (Ne.symm hb)
  rw [hclusters, inner_sum]
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  rw [C.self i j]
  have hrest : ∑ j' ∈ (Finset.univ : Finset (Fin m)).erase j, ⟪C.obs i j, C.obs i j'⟫
      = ((m : ℝ) - 1) * (C.rho * C.sigma ^ 2) := by
    rw [Finset.sum_congr rfl (fun j' hj' => C.within i j j' (Ne.symm (Finset.mem_erase.1 hj').1))]
    rw [Finset.sum_const, Finset.card_erase_of_mem (Finset.mem_univ j)]
    have hm : 1 ≤ m := Fin.pos_iff_nonempty.2 ⟨j⟩
    rw [Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    congr 1
    push_cast [Nat.cast_sub hm]
    ring
  rw [hrest]
  ring

/-- **The design-effect identity.**  `Var(grand mean) = σ²(1 + (m-1)ρ)/(km)`. -/
theorem var_grandMean (hk : 0 < k) (hm : 0 < m) :
    ⟪C.grandMean, C.grandMean⟫
      = C.sigma ^ 2 * (1 + ((m : ℝ) - 1) * C.rho) / ((k : ℝ) * (m : ℝ)) := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [grandMean, real_inner_smul_left, real_inner_smul_right]
  rw [sum_inner]
  have h1 : ∀ i : Fin k, ⟪∑ j : Fin m, C.obs i j, ∑ i' : Fin k, ∑ j' : Fin m, C.obs i' j'⟫
      = (m : ℝ) * (C.sigma ^ 2 * (1 + ((m : ℝ) - 1) * C.rho)) := by
    intro i
    rw [sum_inner, Finset.sum_congr rfl (fun j _ => C.inner_obs_total i j), Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [Finset.sum_congr rfl (fun i _ => h1 i), Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- The design effect of the two-level design. -/
noncomputable def designEffect : ℝ := 1 + ((m : ℝ) - 1) * C.rho

/-- Clustering never helps: the design effect is at least `1`. -/
theorem designEffect_ge_one (hm : 0 < m) : 1 ≤ C.designEffect := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have := C.rho_nonneg
  rw [designEffect]
  nlinarith

/-- **The cluster ceiling.**  However many draws are taken inside each cluster, the variance of
the grand mean never drops below `ρσ²/k`: precision is bounded by the *number of clusters*.
For `exp569b` this is the `128` moduli, not the `76.8M` pairs. -/
theorem var_grandMean_ge_cluster_floor (hk : 0 < k) (hm : 0 < m) :
    C.rho * C.sigma ^ 2 / (k : ℝ) ≤ ⟪C.grandMean, C.grandMean⟫ := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hσ : 0 < C.sigma ^ 2 := by have := C.sigma_pos; positivity
  rw [C.var_grandMean hk hm, div_le_div_iff₀ hkR (by positivity)]
  have hρ1 := C.rho_le_one
  nlinarith [mul_pos hkR hmR, mul_nonneg (sub_nonneg.2 hρ1) hσ.le]

/-- The effective (independent-equivalent) sample size of the clustered design. -/
noncomputable def effectiveSampleSize : ℝ := (k : ℝ) * (m : ℝ) / C.designEffect

/-- **The information ceiling in sample-size units.**  With positive intra-cluster correlation
the effective sample size never exceeds `k/ρ`, whatever `m` is. -/
theorem effectiveSampleSize_le (hk : 0 < k) (hm : 0 < m) (hρ : 0 < C.rho) :
    C.effectiveSampleSize ≤ (k : ℝ) / C.rho := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hdeff : 0 < C.designEffect := by
    have : (1 : ℝ) ≤ C.designEffect := C.designEffect_ge_one hm
    linarith
  have hρ1 := C.rho_le_one
  rw [effectiveSampleSize, div_le_div_iff₀ hdeff hρ, designEffect]
  nlinarith [mul_pos hkR (lt_of_lt_of_le zero_lt_one hmR)]

end ClusterModel

/-- **The ceiling is sharp.**  As the number of draws per cluster grows, the variance
`σ²(1 + (m-1)ρ)/(km)` decreases to exactly `ρσ²/k`; no amount of intra-cluster sampling
crosses it.  (Stated for the arithmetic expression, so it applies to every model.) -/
theorem var_grandMean_tendsto_cluster_floor {k : ℕ} {s r : ℝ} (hk : 0 < k) :
    Filter.Tendsto
      (fun m : ℕ => s ^ 2 * (1 + ((m : ℝ) - 1) * r) / ((k : ℝ) * (m : ℝ)))
      Filter.atTop (nhds (r * s ^ 2 / (k : ℝ))) := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hev : ∀ᶠ m : ℕ in Filter.atTop,
      s ^ 2 * (1 + ((m : ℝ) - 1) * r) / ((k : ℝ) * (m : ℝ))
        = r * s ^ 2 / (k : ℝ) + (s ^ 2 * (1 - r) / (k : ℝ)) * ((m : ℝ)⁻¹) := by
    filter_upwards [Filter.eventually_gt_atTop 0] with m hm
    have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    field_simp
    ring
  rw [Filter.tendsto_congr' hev]
  have h1 : Filter.Tendsto (fun m : ℕ => ((m : ℝ)⁻¹)) Filter.atTop (nhds 0) :=
    tendsto_inv_atTop_nhds_zero_nat
  have := ((h1.const_mul (s ^ 2 * (1 - r) / (k : ℝ))).const_add (r * s ^ 2 / (k : ℝ)))
  simpa using this

/-- **The run, in numbers.**  `exp569b` used `k = 128` moduli.  If the readouts inside one
modulus carry even a `1%` correlation, the entire `76.8M`-pair run has effective sample size at
most `12 800` — three orders of magnitude below the nominal pair count, and independent of the
`600 000` samples per modulus. -/
theorem exp569b_effective_size_bound {m : ℕ} (C : ClusterModel E 128 m) (hm : 0 < m)
    (hρ : C.rho = 1 / 100) : C.effectiveSampleSize ≤ 12800 := by
  have h := C.effectiveSampleSize_le (by norm_num) hm (by rw [hρ]; norm_num)
  rw [hρ] at h
  norm_num at h ⊢
  linarith

/-! ### Non-vacuity: the clustered axioms are realisable -/

private theorem inner_single_single {ι : Type*} [DecidableEq ι] (p q : ι) (a b : ℝ) :
    ⟪(lp.single 2 p a : lp (fun _ : ι => ℝ) 2), (lp.single 2 q b : lp (fun _ : ι => ℝ) 2)⟫
      = if p = q then a * b else 0 := by
  simp only [lp.inner_single_left, lp.single_apply, RCLike.inner_apply, conj_trivial,
    Pi.single_apply]
  by_cases h : p = q
  · simp [h, mul_comm]
  · simp [h]

/-- Every admissible parameter triple `(k, m, σ, ρ)` with `0 ≤ ρ ≤ 1` is realised by an
explicit model: a shared cluster component of size `√ρ σ` plus an independent private
component of size `√(1-ρ) σ`.  Hence the clustered theorems above are never vacuous. -/
theorem clusterModel_exists (k m : ℕ) {s r : ℝ} (hs : 0 < s) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    ∃ C : ClusterModel (lp (fun _ : Fin k ⊕ (Fin k × Fin m) => ℝ) 2) k m,
      C.sigma = s ∧ C.rho = r := by
  set a : ℝ := Real.sqrt r * s with ha
  set b : ℝ := Real.sqrt (1 - r) * s with hb
  have hsr : Real.sqrt r ^ 2 = r := Real.sq_sqrt hr0
  have hsr' : Real.sqrt (1 - r) ^ 2 = 1 - r := Real.sq_sqrt (by linarith)
  have hA : a ^ 2 = r * s ^ 2 := by rw [ha, mul_pow, hsr]
  have hB : b ^ 2 = (1 - r) * s ^ 2 := by rw [hb, mul_pow, hsr']
  refine ⟨{ obs := fun i j => lp.single 2 (Sum.inl i) a + lp.single 2 (Sum.inr (i, j)) b
            sigma := s
            rho := r
            sigma_pos := hs
            rho_nonneg := hr0
            rho_le_one := hr1
            self := ?_
            within := ?_
            between := ?_ }, rfl, rfl⟩
  · intro i j
    simp only [inner_add_left, inner_add_right, inner_single_single]
    simp only [reduceCtorEq, if_true, if_false, add_zero, zero_add]
    nlinarith [hA, hB]
  · intro i j j' hjj
    simp [inner_add_left, inner_add_right, inner_single_single, hjj]
    nlinarith [hA]
  · intro i i' j j' hii
    simp [inner_add_left, inner_add_right, inner_single_single, hii]

end Catalog.Physics.ClusterDesign