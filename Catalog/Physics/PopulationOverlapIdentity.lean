/-
# Shared populations: the overlap identity one level up

## Provenance (round-75 #3, exp 569b, paper 220)

The second independence failure of the round is subtler than the first.  The pilot (paper 214,
exp567) and `B` (exp569b) use *disjoint measurement machinery* — no draw is shared — but
recorder verification put all `24` pilot band-9 semiprimes inside `B`'s `128`-modulus pool.
The corrected joint `pilot × B` nevertheless assumed zero covariance, which is what the audit
recorded as "the point stays meaningful, the edge does not".

This file replaces that qualitative caveat with an identity.  Model each readout as

  `obs i t = clust i + priv i t`,

a per-modulus component of variance `ρσ²` shared by every draw on that modulus, plus a private
component of variance `(1-ρ)σ²`.  A *leg* is a mean over a modulus set `K` and a draw-index set
`T`.  Then for any two legs

  `Cov = ρσ² |K ∩ K'| / (|K| |K'|)  +  (1-ρ)σ² |K ∩ K'| |T ∩ T'| / (|K| |T| |K'| |T'|)`.

Both failure modes of the round are the two summands: sharing *draws* (second term, the
exp569/exp569b nesting) and sharing *populations* (first term, the pilot inside `B`).  Only a
leg with a disjoint modulus population is genuinely uncorrelated — which is exactly what a
fresh master seed buys.

## Main results

* `PopDesign.cov_legMean` — the two-term overlap identity above.
* `PopDesign.cov_legMean_of_disjoint_draws` — with disjoint draws the covariance is
  `ρσ²|K ∩ K'|/(|K||K'|)`: **the conjecture recorded as future direction 1, proved.**
* `PopDesign.var_legMean` — the design-effect specialisation `ρσ²/|K| + (1-ρ)σ²/(|K||T|)`.
* `PopDesign.cov_legMean_of_nested_population` — for `K ⊆ K'` and disjoint draws the covariance
  is `ρσ²/|K'|`, *strictly positive* whenever `ρ > 0` (`cov_legMean_pos_of_nested_population`).
  The pilot × B joint therefore understates its variance unless the moduli carry no
  correlation at all.
* `PopDesign.cov_legMean_of_disjoint_population` — and it is exactly zero when the modulus
  populations are disjoint: fresh population, honest pooling.
* `PopDesign.pooled_var_gt_naive_of_nested_population` — the quantitative consequence: for the
  audited configuration the honest variance of the pooled pilot × B estimator exceeds the
  reported inverse-variance value by `2w(1-w)ρσ²/|K'|`.
* `popDesign_exists` — the model is realisable for every `0 ≤ ρ ≤ 1`, so nothing here is
  vacuous.
-/
import Physics.PoolingIndependenceAudit

namespace Catalog.Physics.PopulationOverlap

open Finset RealInnerProductSpace
open Catalog.Physics.PoolingAudit (inner_sum_sum_of_orthogonal)

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- A two-level *population* design: readouts carry a per-modulus shared component and a
private per-draw component.  Inner product = covariance. -/
structure PopDesign (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E] where
  /-- the shared component of modulus `i` -/
  clust : ℕ → E
  /-- the private component of draw `t` on modulus `i` -/
  priv : ℕ → ℕ → E
  sigma : ℝ
  rho : ℝ
  sigma_pos : 0 < sigma
  rho_nonneg : 0 ≤ rho
  rho_le_one : rho ≤ 1
  clust_orth : ∀ i j, i ≠ j → ⟪clust i, clust j⟫ = 0
  clust_var : ∀ i, ⟪clust i, clust i⟫ = rho * sigma ^ 2
  priv_orth : ∀ p q : ℕ × ℕ, p ≠ q → ⟪priv p.1 p.2, priv q.1 q.2⟫ = 0
  priv_var : ∀ p : ℕ × ℕ, ⟪priv p.1 p.2, priv p.1 p.2⟫ = (1 - rho) * sigma ^ 2
  mixed : ∀ i j t, ⟪clust i, priv j t⟫ = 0

namespace PopDesign

variable (P : PopDesign E)

/-- The readout of draw `t` on modulus `i`. -/
def obs (i t : ℕ) : E := P.clust i + P.priv i t

/-- The unnormalised leg over modulus set `K` and draw-index set `T`. -/
noncomputable def legSum (K T : Finset ℕ) : E := ∑ i ∈ K, ∑ t ∈ T, P.obs i t

/-- The leg mean. -/
noncomputable def legMean (K T : Finset ℕ) : E :=
  (((K.card : ℝ) * (T.card : ℝ))⁻¹) • P.legSum K T

/-- A leg splits into a cluster part and a private part. -/
theorem legSum_eq (K T : Finset ℕ) :
    P.legSum K T
      = ((T.card : ℝ)) • (∑ i ∈ K, P.clust i) + ∑ q ∈ K ×ˢ T, P.priv q.1 q.2 := by
  rw [legSum, Finset.sum_product' (f := fun i t => P.priv i t), Finset.smul_sum,
    ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  simp only [obs, Finset.sum_add_distrib, Finset.sum_const]
  rw [Nat.cast_smul_eq_nsmul ℝ]

/-- The private parts of two legs are uncorrelated with the cluster parts. -/
private theorem inner_clust_priv (K K' T' : Finset ℕ) :
    ⟪∑ i ∈ K, P.clust i, ∑ q ∈ K' ×ˢ T', P.priv q.1 q.2⟫ = 0 := by
  rw [sum_inner, Finset.sum_eq_zero]
  intro i _
  rw [inner_sum, Finset.sum_eq_zero]
  intro q _
  exact P.mixed i q.1 q.2

/-- **The overlap identity, unnormalised.** -/
theorem inner_legSum (K T K' T' : Finset ℕ) :
    ⟪P.legSum K T, P.legSum K' T'⟫
      = P.rho * P.sigma ^ 2 * ((K ∩ K').card : ℝ) * (T.card : ℝ) * (T'.card : ℝ)
        + (1 - P.rho) * P.sigma ^ 2 * ((K ∩ K').card : ℝ) * ((T ∩ T').card : ℝ) := by
  have hmix : ⟪∑ q ∈ K ×ˢ T, P.priv q.1 q.2, ∑ i ∈ K', P.clust i⟫ = 0 := by
    rw [real_inner_comm]
    exact P.inner_clust_priv K' K T
  rw [legSum_eq, legSum_eq]
  simp only [inner_add_left, inner_add_right, real_inner_smul_left, real_inner_smul_right]
  rw [P.inner_clust_priv K K' T', hmix,
    inner_sum_sum_of_orthogonal P.clust (P.rho * P.sigma ^ 2) P.clust_orth P.clust_var K K',
    inner_sum_sum_of_orthogonal (fun q : ℕ × ℕ => P.priv q.1 q.2)
      ((1 - P.rho) * P.sigma ^ 2) P.priv_orth P.priv_var (K ×ˢ T) (K' ×ˢ T'),
    Finset.product_inter_product, Finset.card_product]
  push_cast
  ring

/-- **The overlap identity.**  Sharing draws and sharing populations are the two summands of a
single covariance law. -/
theorem cov_legMean {K T K' T' : Finset ℕ} (hK : K.Nonempty) (hT : T.Nonempty)
    (hK' : K'.Nonempty) (hT' : T'.Nonempty) :
    ⟪P.legMean K T, P.legMean K' T'⟫
      = P.rho * P.sigma ^ 2 * ((K ∩ K').card : ℝ) / ((K.card : ℝ) * (K'.card : ℝ))
        + (1 - P.rho) * P.sigma ^ 2 * ((K ∩ K').card : ℝ) * ((T ∩ T').card : ℝ)
            / ((K.card : ℝ) * (T.card : ℝ) * (K'.card : ℝ) * (T'.card : ℝ)) := by
  have hcK : (0 : ℝ) < (K.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hK
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hcK' : (0 : ℝ) < (K'.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hK'
  have hcT' : (0 : ℝ) < (T'.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT'
  rw [legMean, legMean, real_inner_smul_left, real_inner_smul_right, inner_legSum]
  field_simp

/-- **Future direction 1, proved.**  Legs with disjoint draws — disjoint measurement machinery —
still correlate through their shared modulus population, by exactly the draw-level master
identity one level up. -/
theorem cov_legMean_of_disjoint_draws {K T K' T' : Finset ℕ} (hK : K.Nonempty) (hT : T.Nonempty)
    (hK' : K'.Nonempty) (hT' : T'.Nonempty) (hdisj : Disjoint T T') :
    ⟪P.legMean K T, P.legMean K' T'⟫
      = P.rho * P.sigma ^ 2 * ((K ∩ K').card : ℝ) / ((K.card : ℝ) * (K'.card : ℝ)) := by
  rw [P.cov_legMean hK hT hK' hT', Finset.disjoint_iff_inter_eq_empty.1 hdisj]
  simp

/-- A fresh modulus population gives genuine independence. -/
theorem cov_legMean_of_disjoint_population {K T K' T' : Finset ℕ} (hK : K.Nonempty)
    (hT : T.Nonempty) (hK' : K'.Nonempty) (hT' : T'.Nonempty) (hdisj : Disjoint K K') :
    ⟪P.legMean K T, P.legMean K' T'⟫ = 0 := by
  rw [P.cov_legMean hK hT hK' hT', Finset.disjoint_iff_inter_eq_empty.1 hdisj]
  simp

/-- Variance of a single leg: the design-effect form. -/
theorem var_legMean {K T : Finset ℕ} (hK : K.Nonempty) (hT : T.Nonempty) :
    ⟪P.legMean K T, P.legMean K T⟫
      = P.rho * P.sigma ^ 2 / (K.card : ℝ)
        + (1 - P.rho) * P.sigma ^ 2 / ((K.card : ℝ) * (T.card : ℝ)) := by
  have hcK : (0 : ℝ) < (K.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hK
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  rw [P.cov_legMean hK hT hK hT, Finset.inter_self, Finset.inter_self]
  field_simp

/-- **The pilot inside `B`.**  Nested modulus populations with disjoint draws: the covariance is
`ρσ²/|K'|`. -/
theorem cov_legMean_of_nested_population {K T K' T' : Finset ℕ} (hKK : K ⊆ K')
    (hK : K.Nonempty) (hT : T.Nonempty) (hK' : K'.Nonempty) (hT' : T'.Nonempty)
    (hdisj : Disjoint T T') :
    ⟪P.legMean K T, P.legMean K' T'⟫ = P.rho * P.sigma ^ 2 / (K'.card : ℝ) := by
  have hcK : (0 : ℝ) < (K.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hK
  rw [P.cov_legMean_of_disjoint_draws hK hT hK' hT' hdisj, Finset.inter_eq_left.2 hKK]
  field_simp

/-- …and it is strictly positive as soon as the moduli carry any correlation at all, so the
"nominally independent" joint is not independent. -/
theorem cov_legMean_pos_of_nested_population {K T K' T' : Finset ℕ} (hKK : K ⊆ K')
    (hK : K.Nonempty) (hT : T.Nonempty) (hK' : K'.Nonempty) (hT' : T'.Nonempty)
    (hdisj : Disjoint T T') (hrho : 0 < P.rho) :
    0 < ⟪P.legMean K T, P.legMean K' T'⟫ := by
  have hcK' : (0 : ℝ) < (K'.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hK'
  have hσ : (0 : ℝ) < P.sigma ^ 2 := by have := P.sigma_pos; positivity
  rw [P.cov_legMean_of_nested_population hKK hK hT hK' hT' hdisj]
  positivity

/-- **The quantitative consequence for the corrected joint.**  Pooling two legs whose modulus
populations are nested, with any interior weight, has honest variance exceeding the
independence bookkeeping by `2w(1-w)ρσ²/|K'|` — strictly, whenever `ρ > 0`. -/
theorem pooled_var_gt_naive_of_nested_population {K T K' T' : Finset ℕ} {w : ℝ}
    (hKK : K ⊆ K') (hK : K.Nonempty) (hK' : K'.Nonempty) (hTd : Disjoint T T')
    (hT : T.Nonempty) (hT' : T'.Nonempty) (hrho : 0 < P.rho) (hw0 : 0 < w) (hw1 : w < 1) :
    ⟪w • P.legMean K T + (1 - w) • P.legMean K' T',
      w • P.legMean K T + (1 - w) • P.legMean K' T'⟫
      = w ^ 2 * ⟪P.legMean K T, P.legMean K T⟫
        + (1 - w) ^ 2 * ⟪P.legMean K' T', P.legMean K' T'⟫
        + 2 * w * (1 - w) * (P.rho * P.sigma ^ 2 / (K'.card : ℝ))
      ∧ 0 < 2 * w * (1 - w) * (P.rho * P.sigma ^ 2 / (K'.card : ℝ)) := by
  have hcK' : (0 : ℝ) < (K'.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hK'
  have hσ : (0 : ℝ) < P.sigma ^ 2 := by have := P.sigma_pos; positivity
  constructor
  · simp only [inner_add_left, inner_add_right, real_inner_smul_left, real_inner_smul_right]
    rw [real_inner_comm (P.legMean K T) (P.legMean K' T'),
      P.cov_legMean_of_nested_population hKK hK hT hK' hT' hTd]
    ring
  · have h2 : 0 < 2 * w * (1 - w) := by nlinarith
    positivity

end PopDesign

/-! ### Non-vacuity -/

private theorem inner_single_single' {ι : Type*} [DecidableEq ι] (p q : ι) (a b : ℝ) :
    ⟪(lp.single 2 p a : lp (fun _ : ι => ℝ) 2), (lp.single 2 q b : lp (fun _ : ι => ℝ) 2)⟫
      = if p = q then a * b else 0 := by
  simp only [lp.inner_single_left, lp.single_apply, RCLike.inner_apply, conj_trivial,
    Pi.single_apply]
  by_cases h : p = q
  · simp [h, mul_comm]
  · simp [h]

/-- The population design is realisable for every `σ > 0` and `0 ≤ ρ ≤ 1`. -/
theorem popDesign_exists {s r : ℝ} (hs : 0 < s) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    ∃ P : PopDesign (lp (fun _ : ℕ ⊕ (ℕ × ℕ) => ℝ) 2), P.sigma = s ∧ P.rho = r := by
  have hsr : Real.sqrt r ^ 2 = r := Real.sq_sqrt hr0
  have hsr' : Real.sqrt (1 - r) ^ 2 = 1 - r := Real.sq_sqrt (by linarith)
  refine ⟨{ clust := fun i => lp.single 2 (Sum.inl i) (Real.sqrt r * s)
            priv := fun i t => lp.single 2 (Sum.inr (i, t)) (Real.sqrt (1 - r) * s)
            sigma := s
            rho := r
            sigma_pos := hs
            rho_nonneg := hr0
            rho_le_one := hr1
            clust_orth := ?_
            clust_var := ?_
            priv_orth := ?_
            priv_var := ?_
            mixed := ?_ }, rfl, rfl⟩
  · intro i j hij
    simp [inner_single_single', hij]
  · intro i
    rw [inner_single_single' (Sum.inl i) (Sum.inl i), if_pos rfl]
    nlinarith [hsr]
  · intro p q hpq
    have : (Sum.inr p : ℕ ⊕ (ℕ × ℕ)) ≠ Sum.inr q := by simp [hpq]
    simp [inner_single_single', this]
  · intro p
    rw [inner_single_single' (Sum.inr p) (Sum.inr p), if_pos rfl]
    nlinarith [hsr']
  · intro i j t
    simp [inner_single_single']

end Catalog.Physics.PopulationOverlap