import Novelty.NET58BudgetCrossing

/-!
# NET-58: a 64-dimensional key cannot see a 1024-dimensional importance profile

Third layer of the NET-58 analysis (paper 143).  `Novelty.NET58RelationalImportance` bounds the
content-only family by the *relational* ceiling and, via ANOVA, bounds even nonlinear content
heads.  This file adds the ceiling that comes from **dimension alone**, and that applies to the
exact estimator the round used: an affine ridge probe

  `s i = ⟨w, kᵢ⟩ + b`,  `kᵢ ∈ ℝ⁶⁴`,

evaluated on a context of `n = 1024` keys.  The family of score vectors such a probe can produce
is the image of a linear map into `ℝ^{d+1}`; by rank–nullity, once `d + 1 < n` there is a large
space of importance profiles that *every* affine probe, with every weight vector, predicts no
better than the constant predictor.

## Results

* `momentMap` — the `(d+1)`-dimensional linear functional that an affine probe reads off an
  importance profile: the `d` key moments `∑ᵢ aᵢ kᵢⱼ` together with the total `∑ᵢ aᵢ`.
* `inner_eq_zero_of_blind` — profiles in its kernel are orthogonal to *every* affine probe
  score, simultaneously.
* `sstot_le_sse_of_blind`, `Rsq_nonpos_of_blind` — on such a profile every affine probe has
  `R² ≤ 0`: it is beaten by predicting the mean.  Ridge, ordinary least squares, and any weight
  vector whatsoever are covered — the statement quantifies over `w` and `b`.
* `exists_importance_linear_blind` — **the dimension obstruction**: whenever `d + 1 < n` such a
  profile exists, for *every* key configuration.  Content-blindness of the linear class is not a
  property of a particular model's keys; it is forced by `64 ≪ 1024`.
* `blind_finrank_ge` — quantitatively, the blind space has dimension at least `n - (d+1)`, and
  `net58_blind_dimension_1024_64` instantiates it at the measured geometry: **at least `959` of
  the `1024` importance directions are invisible to any 64-dimensional affine probe.**
* `net58_visible_fraction_small` — the visible fraction `65/1024 < 6.4 %`.  The measured mean
  `R² = 0.329` is therefore *far above* what an unstructured profile would give, which is the
  precise sense in which the probe is informative *and* the eviction policy still fails: the
  failure is not a fitting failure.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if the residual `1 - R² = 0.671` were pure estimation error it should
shrink with more probe capacity; if it is a rank obstruction it cannot, and the invisible
subspace should have codimension `d + 1` independent of the data.

Experiment (Experimenter): the numeric instantiation `n = 1024`, `d = 64` gives a blind subspace
of dimension `≥ 959` and a visible fraction `65/1024 = 0.0635`, recorded in
`ComputationalEvidence.md`.

Analysis (Analyst): three ceilings are now in place and they are ordered —
affine probes (this file, rank `d+1`) ⊆ arbitrary content functions
(`Rsq_le_intrinsic_ceiling`) ⊆ static policies (`static_content_ceiling`).  The measured probe
sits below the first; `P1` was refuted at the first level, and `P2` is guaranteed at the third.

Critique (Critic): `Rsq_nonpos_of_blind` is not vacuous — the profile it applies to is exhibited
with `sstot ≠ 0`, so `Rsq` is well defined and the conclusion `R² ≤ 0` is a genuine failure of
prediction, not a division-by-zero artefact.  The theorem does *not* say the measured probe has
`R² ≤ 0`; it says the class has a blind subspace of codimension `d+1`, which is compatible with
the measured `0.329` on the actual profile and is exactly the structural reason no reweighting
of a 64-dimensional key can be made to work in general.
-/

namespace Catalog.Novelty.NET58ProbeDimensionBlindness

open Finset Catalog.Novelty.ProbeRetentionLimits

variable {n d : ℕ}

/-- The score produced by an affine probe with weights `w` and intercept `b` on the key
matrix `key`. -/
def probeScore (key : Fin n → Fin d → ℝ) (w : Fin d → ℝ) (b : ℝ) : Fin n → ℝ :=
  fun i => (∑ j, w j * key i j) + b

/-- Everything an affine probe can extract from an importance profile: the `d` key moments and
the total mass.  Its rank is at most `d + 1`, whatever the key matrix. -/
def momentMap (key : Fin n → Fin d → ℝ) : (Fin n → ℝ) →ₗ[ℝ] ((Fin d → ℝ) × ℝ) where
  toFun a := (fun j => ∑ i, a i * key i j, ∑ i, a i)
  map_add' a b := by
    refine Prod.ext ?_ ?_
    · funext j
      simp [Finset.sum_add_distrib, add_mul]
    · simp [Finset.sum_add_distrib]
  map_smul' c a := by
    refine Prod.ext ?_ ?_
    · funext j
      simp [Finset.mul_sum, mul_assoc]
    · simp [Finset.mul_sum]

/-- A profile in the kernel of the moment map is orthogonal to every affine probe score at
once. -/
theorem inner_eq_zero_of_blind {key : Fin n → Fin d → ℝ} {a : Fin n → ℝ}
    (ha : momentMap key a = 0) (w : Fin d → ℝ) (b : ℝ) :
    ∑ i, a i * probeScore key w b i = 0 := by
  have hmom : ∀ j, ∑ i, a i * key i j = 0 := by
    intro j
    have := congrArg (fun p => p.1 j) ha
    simpa [momentMap] using this
  have hmean : ∑ i, a i = 0 := by
    have := congrArg (fun p => p.2) ha
    simpa [momentMap] using this
  have hsplit : ∀ i, a i * probeScore key w b i
      = (∑ j, a i * (w j * key i j)) + a i * b := by
    intro i
    simp [probeScore, mul_add, Finset.mul_sum]
  simp_rw [hsplit]
  rw [Finset.sum_add_distrib, ← Finset.sum_mul, hmean, zero_mul, add_zero, Finset.sum_comm]
  refine Finset.sum_eq_zero fun j _ => ?_
  have hj : ∑ i, a i * (w j * key i j) = w j * ∑ i, a i * key i j := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hj, hmom j, mul_zero]

/-- On a blind profile, every affine probe is *worse than the mean*: its squared error exceeds
the total dispersion. -/
theorem sstot_le_sse_of_blind {key : Fin n → Fin d → ℝ} {a : Fin n → ℝ}
    (ha : momentMap key a = 0) (w : Fin d → ℝ) (b : ℝ) :
    sstot a ≤ sse a (probeScore key w b) := by
  have hmean : ∑ i, a i = 0 := by
    have := congrArg (fun p => p.2) ha
    simpa [momentMap] using this
  have hmean0 : mean a = 0 := by simp [mean, hmean]
  have hss : sstot a = ∑ i, a i ^ 2 := by simp [sstot, hmean0]
  have hortho := inner_eq_zero_of_blind ha w b
  have hexp : sse a (probeScore key w b)
      = (∑ i, a i ^ 2) - 2 * (∑ i, a i * probeScore key w b i)
        + ∑ i, probeScore key w b i ^ 2 := by
    simp only [sse]
    rw [Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  have hsq : 0 ≤ ∑ i, probeScore key w b i ^ 2 :=
    Finset.sum_nonneg fun i _ => sq_nonneg _
  rw [hss, hexp, hortho]
  linarith

/-- Hence `R² ≤ 0` for the whole affine family on a blind profile. -/
theorem Rsq_nonpos_of_blind {key : Fin n → Fin d → ℝ} {a : Fin n → ℝ}
    (ha : momentMap key a = 0) (hpos : 0 < sstot a) (w : Fin d → ℝ) (b : ℝ) :
    Rsq a (probeScore key w b) ≤ 0 := by
  have h := sstot_le_sse_of_blind ha w b
  have h1 : 1 ≤ sse a (probeScore key w b) / sstot a := by
    rw [le_div_iff₀ hpos, one_mul]
    exact h
  simp only [Rsq]
  linarith

/-- A nonzero profile of zero total mass has positive dispersion. -/
theorem sstot_pos_of_blind {key : Fin n → Fin d → ℝ} {a : Fin n → ℝ}
    (ha : momentMap key a = 0) (hne : a ≠ 0) : 0 < sstot a := by
  have hmean : ∑ i, a i = 0 := by
    have := congrArg (fun p => p.2) ha
    simpa [momentMap] using this
  have hmean0 : mean a = 0 := by simp [mean, hmean]
  have hss : sstot a = ∑ i, a i ^ 2 := by simp [sstot, hmean0]
  obtain ⟨i₀, hi₀⟩ : ∃ i, a i ≠ 0 := by
    by_contra hcon
    exact hne (funext fun i => by simpa using not_not.mp (not_exists.mp hcon i))
  rw [hss]
  exact Finset.sum_pos' (fun i _ => sq_nonneg _)
    ⟨i₀, Finset.mem_univ i₀, by positivity⟩

/-- **The dimension obstruction.**  For every key configuration, as soon as the key dimension
plus one is below the context length there is an importance profile that *no* affine probe
predicts better than the constant predictor.  With `d = 64` and `n = 1024` the hypothesis is
satisfied by a factor of `15`. -/
theorem exists_importance_linear_blind (key : Fin n → Fin d → ℝ) (hd : d + 1 < n) :
    ∃ a : Fin n → ℝ, 0 < sstot a ∧ ∀ w b, Rsq a (probeScore key w b) ≤ 0 := by
  have hker : LinearMap.ker (momentMap key) ≠ ⊥ := by
    intro hbot
    have hinj : Function.Injective (momentMap key) := LinearMap.ker_eq_bot.mp hbot
    have hle : Module.finrank ℝ (Fin n → ℝ) ≤ Module.finrank ℝ ((Fin d → ℝ) × ℝ) :=
      LinearMap.finrank_le_finrank_of_injective hinj
    simp only [Module.finrank_pi, Module.finrank_prod, Module.finrank_self,
      Fintype.card_fin] at hle
    omega
  obtain ⟨a, hamem, hane⟩ := Submodule.ne_bot_iff _ |>.mp hker
  have ha : momentMap key a = 0 := hamem
  exact ⟨a, sstot_pos_of_blind ha hane, fun w b => Rsq_nonpos_of_blind ha
    (sstot_pos_of_blind ha hane) w b⟩

/-- **How big is the blind space?**  Its dimension is at least `n - (d+1)`: an affine probe of
key dimension `d` sees a `(d+1)`-dimensional shadow of an `n`-dimensional profile. -/
theorem blind_finrank_ge (key : Fin n → Fin d → ℝ) :
    n - (d + 1) ≤ Module.finrank ℝ (LinearMap.ker (momentMap key)) := by
  have hrk := LinearMap.finrank_range_add_finrank_ker (momentMap key)
  have hran : Module.finrank ℝ (LinearMap.range (momentMap key))
      ≤ Module.finrank ℝ ((Fin d → ℝ) × ℝ) := Submodule.finrank_le _
  simp only [Module.finrank_pi, Module.finrank_prod, Module.finrank_self,
    Fintype.card_fin] at hrk hran
  omega

/-- **The measured geometry.**  A 64-dimensional post-rope key, on the 1024-token context of the
round, leaves at least `959` of the `1024` importance directions completely invisible to every
affine probe. -/
theorem net58_blind_dimension_1024_64 (key : Fin 1024 → Fin 64 → ℝ) :
    959 ≤ Module.finrank ℝ (LinearMap.ker (momentMap key)) := by
  have := blind_finrank_ge key
  omega

/-- The visible fraction is under `6.4 %`, far below the measured mean `R² = 0.329`: the probe is
genuinely informative about the *actual* profile, and the eviction policy nevertheless fails.
The failure is structural, not a fitting failure. -/
theorem net58_visible_fraction_small : (64 + 1 : ℝ) / 1024 < 0.064 := by norm_num

end Catalog.Novelty.NET58ProbeDimensionBlindness