import MachineLearning.QRResidual.MeasurableCeiling

/-!
# What a null `R²` certifies: margin ceilings for the MA-1 effectivity criterion

Experiment 566 asks whether the quadratic-character L-mass `P(m) = Σ_χ |L(1,χ)|` supplies a
*computable per-modulus criterion* for the MA-1 averaging assumption, by regressing the
AP-deviation readout on `P`.  The recorded verdict is a pre-registered null: `R² = 0.0187`
at `x = 2^26` and `R² = 0.0785` at `x = 2^28`, against an `H1` bar of `0.8`; meanwhile the
pure size feature `log m` alone explains `R² = 0.790`.

A number is not yet a theorem.  This file supplies the deductive layer that converts the
recorded `R²` numbers into *bounds on what any criterion can do*, and conversely explains
why a size feature must dominate.  Everything is exact finite-sample algebra, reusing the
regression theory of `QRResidual` (`rss`, `rsq`, `tss`, `measurableClass`, `withinSS`).

Main results.

* `sqNorm_add_ge` — the pointwise inequality `‖u+v‖² ≥ ‖u‖²/2 − ‖v‖²` (no Cauchy–Schwarz).
* `rsq_affine_ge_of_noise` — **size domination.**  If the response is affine in a feature up
  to a residual of energy `≤ η`, and the feature's centred spread satisfies `2η < b²‖x̃‖²`,
  then the affine class in that feature already explains at least
  `1 − η/(b²‖x̃‖²/2 − η)` of the variance.  A single size covariate can honestly reach
  `R² ≈ 0.79`; that is not evidence of arithmetic content.
* `two_group_rss` — the exact two-group (between/within) identity
  `‖y − ĝ‖² = TSS − (n₁n₂/n)(m₁−m₂)²`.
* `margin_criterion_rsq_lower` — **a criterion has to show up in `R²`.**  If some threshold
  on the feature `P` separates the response into a high group (`≥ μ+δ`) and a low group
  (`≤ μ−δ`), then `R²` of the *whole* class of functions of `P` is at least
  `4δ²n₁n₂/(n·TSS)`.
* `criterion_margin_le_of_rsq`, `exp566_margin_ceiling`, `exp566_balanced_margin_ceiling` —
  the contrapositive, which is the theorem-level meaning of the null: with the recorded
  `R² ≤ 0.0785`, **every** threshold criterion built from the L-mass — of any functional
  form — separates the deviation field with squared margin at most `0.0785` times the
  sample variance, i.e. margin `≤ 0.281` standard deviations.
* `lmass_increment_ceiling` — after a size baseline, a bounded incremental `R²` forces a
  bounded residual correlation with the L-mass feature.
* `lmass_nonlinear_floor` — the nonlinear residual floor for the L-mass feature.

Together with `Bridges.Ma1EffectivitySignBlind` (which shows the readout is sign-blind and
its permutation control vacuous), this is the honest scope of the negative result: the
magnitude route is capped, and the cap is a theorem, not a p-value.
-/

namespace Ma1Effectivity

open Finset QRResidual

open scoped Classical

variable {ι : Type*} [Fintype ι]

/-! ## The affine class of a feature -/

/-- All affine functions of the feature `x`: the model class of the registered log-log fit. -/
def affineClass (x : ι → ℝ) : Set (ι → ℝ) := {h : ι → ℝ | ∃ α β : ℝ, h = fun i => α + β * x i}

omit [Fintype ι] in
theorem affineClass_nonempty (x : ι → ℝ) : (affineClass x).Nonempty :=
  ⟨fun _ => 0, 0, 0, by funext i; simp⟩

omit [Fintype ι] in
/-- An affine function of a feature is in particular a function of that feature. -/
theorem affineClass_subset_measurableClass (x : ι → ℝ) :
    affineClass x ⊆ measurableClass x := by
  rintro h ⟨α, β, rfl⟩
  exact ⟨fun p => α + β * p, rfl⟩

/-! ## Size domination: a small residual forces a large `R²` -/

/-- `‖u + v‖² ≥ ‖u‖²/2 − ‖v‖²`, proved pointwise; no Cauchy–Schwarz needed. -/
theorem sqNorm_add_ge (u v : ι → ℝ) : sqNorm u / 2 - sqNorm v ≤ sqNorm (u + v) := by
  have hpt : ∀ i : ι, (u i) ^ 2 / 2 - (v i) ^ 2 ≤ (u i + v i) ^ 2 := by
    intro i; nlinarith [sq_nonneg (u i / 2 + v i), sq_nonneg (u i), sq_nonneg (v i)]
  have hsum : ∑ i, ((u i) ^ 2 / 2 - (v i) ^ 2) ≤ ∑ i, (u i + v i) ^ 2 :=
    Finset.sum_le_sum fun i _ => hpt i
  have hleft : ∑ i, ((u i) ^ 2 / 2 - (v i) ^ 2) = sqNorm u / 2 - sqNorm v := by
    simp only [sqNorm, Finset.sum_sub_distrib, ← Finset.sum_div]
  simpa [hleft] using hsum.trans_eq (by simp [sqNorm])

/-- **Size domination.**  Suppose the centred response decomposes as `ỹ = b·x̃ + r` with a
residual of energy at most `η`, and the feature's centred spread dominates the residual in
the sense `2η < b²‖x̃‖²`.  Then the affine class in that single feature already explains at
least `1 − η/(b²‖x̃‖²/2 − η)` of the variance.

This is why the sweep's size baseline `OBS ~ log m` reaching `R² = 0.790` carries no
arithmetic information: near-affinity in a size covariate is sufficient. -/
theorem rsq_affine_ge_of_noise {y x r : ι → ℝ} {b η : ℝ}
    (hdecomp : ∀ i, y i - mean y = b * (x i - mean x) + r i)
    (hr : sqNorm r ≤ η)
    (hspread : 2 * η < b ^ 2 * sqNorm (x - fun _ => mean x)) :
    1 - η / (b ^ 2 * sqNorm (x - fun _ => mean x) / 2 - η) ≤ rsq y (affineClass x) := by
  set X : ℝ := sqNorm (x - fun _ => mean x) with hX
  set T₀ : ℝ := b ^ 2 * X / 2 - η with hT₀
  have hηnonneg : 0 ≤ η := le_trans (sqNorm_nonneg r) hr
  have hT₀pos : 0 < T₀ := by rw [hT₀]; linarith
  -- the centred decomposition identifies the total sum of squares
  have hy : (y - fun _ => mean y) = (b • (x - fun _ => mean x)) + r := by
    funext i
    simpa [Pi.add_apply, Pi.smul_apply, Pi.sub_apply, smul_eq_mul] using hdecomp i
  have hsmul : sqNorm (b • (x - fun _ => mean x)) = b ^ 2 * X := by
    simp only [sqNorm, Pi.smul_apply, smul_eq_mul, mul_pow, hX, ← Finset.mul_sum]
  have htss : T₀ ≤ tss y := by
    have := sqNorm_add_ge (b • (x - fun _ => mean x)) r
    rw [hsmul] at this
    have h2 : sqNorm (y - fun _ => mean y) = sqNorm ((b • (x - fun _ => mean x)) + r) := by
      rw [hy]
    rw [tss, h2, hT₀]
    linarith
  have htsspos : 0 < tss y := lt_of_lt_of_le hT₀pos htss
  -- the fit `mean y + b (x − mean x)` is affine in `x` and leaves exactly the residual `r`
  have hmem : (fun i => (mean y - b * mean x) + b * x i) ∈ affineClass x :=
    ⟨mean y - b * mean x, b, rfl⟩
  have hres : (y - fun i => (mean y - b * mean x) + b * x i) = r := by
    funext i
    have := hdecomp i
    simp only [Pi.sub_apply]
    linarith
  have hrss : rss y (affineClass x) ≤ η := by
    have h := rss_le_of_mem (y := y) hmem
    rw [hres] at h
    exact h.trans hr
  have hrssnn : 0 ≤ rss y (affineClass x) := rss_nonneg y (affineClass_nonempty x)
  have hquot : rss y (affineClass x) / tss y ≤ η / T₀ := by
    rw [div_le_div_iff₀ htsspos hT₀pos]
    nlinarith
  rw [rsq]
  linarith

/-! ## The exact two-group decomposition -/

variable [Nonempty ι]

/-- **Two-group identity.**  For the two-valued predictor taking the group means on `S` and
on its complement, the residual energy is the total energy minus the between-group term
`(n₁n₂/n)(m₁−m₂)²`. -/
theorem two_group_rss (S : Finset ι) (y : ι → ℝ) (hS : S.Nonempty) (hSc : Sᶜ.Nonempty) :
    sqNorm (y - fun i => if i ∈ S then (∑ j ∈ S, y j) / S.card
        else (∑ j ∈ Sᶜ, y j) / (Sᶜ).card)
      = tss y - ((S.card : ℝ) * (Sᶜ.card : ℝ) / (Fintype.card ι : ℝ))
          * ((∑ j ∈ S, y j) / S.card - (∑ j ∈ Sᶜ, y j) / (Sᶜ).card) ^ 2 := by
  classical
  set n₁ : ℝ := (S.card : ℝ) with hn₁
  set n₂ : ℝ := ((Sᶜ).card : ℝ) with hn₂
  set m₁ : ℝ := (∑ j ∈ S, y j) / n₁ with hm₁
  set m₂ : ℝ := (∑ j ∈ Sᶜ, y j) / n₂ with hm₂
  have hn₁pos : 0 < n₁ := by
    rw [hn₁]; exact_mod_cast Finset.card_pos.2 hS
  have hn₂pos : 0 < n₂ := by
    rw [hn₂]; exact_mod_cast Finset.card_pos.2 hSc
  have hn : n₁ + n₂ = (Fintype.card ι : ℝ) := by
    rw [hn₁, hn₂, ← Nat.cast_add, Finset.card_add_card_compl S]
  have hnpos : (0 : ℝ) < (Fintype.card ι : ℝ) := by rw [← hn]; linarith
  set g : ι → ℝ := fun i => if i ∈ S then m₁ else m₂ with hg
  -- split both sides over `S` and `Sᶜ`
  have hsplit : ∀ f : ι → ℝ, ∑ i, f i = (∑ i ∈ S, f i) + ∑ i ∈ Sᶜ, f i := by
    intro f
    rw [← Finset.sum_add_sum_compl S f]
  have hres : sqNorm (y - g) = (∑ i ∈ S, (y i - m₁) ^ 2) + ∑ i ∈ Sᶜ, (y i - m₂) ^ 2 := by
    simp only [sqNorm, Pi.sub_apply]
    rw [hsplit fun i => (y i - g i) ^ 2]
    congr 1
    · exact Finset.sum_congr rfl fun i hi => by simp [hg, hi]
    · refine Finset.sum_congr rfl fun i hi => ?_
      have : i ∉ S := Finset.mem_compl.1 hi
      simp [hg, this]
  have htss : tss y = (∑ i ∈ S, (y i - mean y) ^ 2) + ∑ i ∈ Sᶜ, (y i - mean y) ^ 2 := by
    simp only [tss, sqNorm, Pi.sub_apply]
    rw [hsplit fun i => (y i - mean y) ^ 2]
  -- the cell identity on each of the two groups
  have hS1 := sum_sub_sq_split S y (mean y) (by positivity)
  have hS2 := sum_sub_sq_split (Sᶜ) y (mean y) (by positivity)
  -- the overall mean is the weighted average of the two group means
  have hsum : (∑ j ∈ S, y j) + ∑ j ∈ Sᶜ, y j = (Fintype.card ι : ℝ) * mean y := by
    rw [mean, ← hsplit y]
    field_simp
  have hmean : n₁ * m₁ + n₂ * m₂ = (Fintype.card ι : ℝ) * mean y := by
    rw [hm₁, hm₂]
    field_simp
    linarith [hsum]
  -- algebraic identity for the between-group term
  have hbetween : n₁ * (mean y - m₁) ^ 2 + n₂ * (mean y - m₂) ^ 2
      = (n₁ * n₂ / (Fintype.card ι : ℝ)) * (m₁ - m₂) ^ 2 := by
    have hmeanval : mean y = (n₁ * m₁ + n₂ * m₂) / (Fintype.card ι : ℝ) := by
      rw [hmean]; field_simp
    rw [hmeanval, ← hn]
    field_simp
    ring
  rw [hres, htss, hS1, hS2, hm₁.symm, hm₂.symm]
  have := hbetween
  linarith [hbetween]

/-! ## A criterion must show up in `R²` -/

/-- **Margin lower bound.**  Suppose a threshold `t` on the feature `P` splits the sample
into a high group on which the response is at least `μ + δ` and a low group on which it is
at most `μ − δ`.  Then the class of *all* functions of `P` explains at least
`4δ²n₁n₂/n` of the total sum of squares. -/
theorem margin_criterion_rsq_lower {y P : ι → ℝ} {t μ δ : ℝ}
    (hhigh : ∀ i, t ≤ P i → μ + δ ≤ y i) (hlow : ∀ i, ¬ t ≤ P i → y i ≤ μ - δ)
    (hδ : 0 ≤ δ) (hS : (univ.filter fun i => t ≤ P i).Nonempty)
    (hSc : (univ.filter fun i => t ≤ P i)ᶜ.Nonempty) (htss : 0 < tss y) :
    4 * δ ^ 2 * ((univ.filter fun i => t ≤ P i).card : ℝ)
        * (((univ.filter fun i => t ≤ P i)ᶜ).card : ℝ) / (Fintype.card ι : ℝ)
      ≤ rsq y (measurableClass P) * tss y := by
  classical
  set S : Finset ι := univ.filter fun i => t ≤ P i with hSdef
  set n₁ : ℝ := (S.card : ℝ) with hn₁
  set n₂ : ℝ := ((Sᶜ).card : ℝ) with hn₂
  set m₁ : ℝ := (∑ j ∈ S, y j) / n₁ with hm₁
  set m₂ : ℝ := (∑ j ∈ Sᶜ, y j) / n₂ with hm₂
  have hn₁pos : 0 < n₁ := by rw [hn₁]; exact_mod_cast Finset.card_pos.2 hS
  have hn₂pos : 0 < n₂ := by rw [hn₂]; exact_mod_cast Finset.card_pos.2 hSc
  have hnpos : (0 : ℝ) < (Fintype.card ι : ℝ) := by
    have : (0 : ℕ) < Fintype.card ι := Fintype.card_pos
    exact_mod_cast this
  -- the two-valued predictor is a function of `P`
  have hmemS : ∀ i, i ∈ S ↔ t ≤ P i := by
    intro i; simp [hSdef]
  have hmem : (fun i => if i ∈ S then m₁ else m₂) ∈ measurableClass P := by
    refine ⟨fun p => if t ≤ p then m₁ else m₂, ?_⟩
    funext i
    by_cases hi : t ≤ P i
    · simp only [if_pos ((hmemS i).2 hi), if_pos hi]
    · simp only [if_neg fun h => hi ((hmemS i).1 h), if_neg hi]
  -- group means inherit the margin
  have hm₁ge : μ + δ ≤ m₁ := by
    have hsum : (S.card : ℝ) * (μ + δ) ≤ ∑ j ∈ S, y j := by
      have : ∀ j ∈ S, μ + δ ≤ y j := fun j hj => hhigh j ((hmemS j).1 hj)
      calc (S.card : ℝ) * (μ + δ) = ∑ _j ∈ S, (μ + δ) := by
            rw [Finset.sum_const, nsmul_eq_mul]
        _ ≤ ∑ j ∈ S, y j := Finset.sum_le_sum this
    rw [hm₁, le_div_iff₀ hn₁pos]
    linarith [hsum]
  have hm₂le : m₂ ≤ μ - δ := by
    have hsum : ∑ j ∈ Sᶜ, y j ≤ ((Sᶜ).card : ℝ) * (μ - δ) := by
      have : ∀ j ∈ Sᶜ, y j ≤ μ - δ := by
        intro j hj
        exact hlow j fun h => (Finset.mem_compl.1 hj) ((hmemS j).2 h)
      calc ∑ j ∈ Sᶜ, y j ≤ ∑ _j ∈ Sᶜ, (μ - δ) := Finset.sum_le_sum this
        _ = ((Sᶜ).card : ℝ) * (μ - δ) := by rw [Finset.sum_const, nsmul_eq_mul]
    rw [hm₂, div_le_iff₀ hn₂pos]
    linarith [hsum]
  have hgap : 2 * δ ≤ m₁ - m₂ := by linarith
  have hgapsq : 4 * δ ^ 2 ≤ (m₁ - m₂) ^ 2 := by nlinarith
  -- the two-group identity plus optimality of the best `P`-measurable fit
  have hid := two_group_rss S y hS hSc
  have hrss : rss y (measurableClass P) ≤ tss y - (n₁ * n₂ / (Fintype.card ι : ℝ)) * (m₁ - m₂) ^ 2 := by
    have h := rss_le_of_mem (y := y) hmem
    rw [hid] at h
    exact h
  have hpos : 0 < n₁ * n₂ / (Fintype.card ι : ℝ) := by positivity
  have hbig : 4 * δ ^ 2 * n₁ * n₂ / (Fintype.card ι : ℝ)
      ≤ (n₁ * n₂ / (Fintype.card ι : ℝ)) * (m₁ - m₂) ^ 2 := by
    have := mul_le_mul_of_nonneg_left hgapsq (le_of_lt hpos)
    calc 4 * δ ^ 2 * n₁ * n₂ / (Fintype.card ι : ℝ)
        = (n₁ * n₂ / (Fintype.card ι : ℝ)) * (4 * δ ^ 2) := by ring
      _ ≤ (n₁ * n₂ / (Fintype.card ι : ℝ)) * (m₁ - m₂) ^ 2 := this
  have hrsq : rsq y (measurableClass P) * tss y = tss y - rss y (measurableClass P) := by
    rw [rsq]
    field_simp
  rw [hrsq]
  linarith

/-- **The contrapositive: a null `R²` caps every threshold criterion.**  If the class of all
functions of `P` explains at most a fraction `ρ` of the variance, then any threshold on `P`
that separates the response by a margin `δ` on both sides obeys
`4δ²n₁n₂/n ≤ ρ·TSS`. -/
theorem criterion_margin_le_of_rsq {y P : ι → ℝ} {t μ δ ρ : ℝ}
    (hhigh : ∀ i, t ≤ P i → μ + δ ≤ y i) (hlow : ∀ i, ¬ t ≤ P i → y i ≤ μ - δ)
    (hδ : 0 ≤ δ) (hS : (univ.filter fun i => t ≤ P i).Nonempty)
    (hSc : (univ.filter fun i => t ≤ P i)ᶜ.Nonempty) (htss : 0 < tss y)
    (hrsq : rsq y (measurableClass P) ≤ ρ) :
    4 * δ ^ 2 * ((univ.filter fun i => t ≤ P i).card : ℝ)
        * (((univ.filter fun i => t ≤ P i)ᶜ).card : ℝ) / (Fintype.card ι : ℝ)
      ≤ ρ * tss y := by
  have h := margin_criterion_rsq_lower hhigh hlow hδ hS hSc htss
  have : rsq y (measurableClass P) * tss y ≤ ρ * tss y :=
    mul_le_mul_of_nonneg_right hrsq (le_of_lt htss)
  linarith

/-- **Experiment 566, stage B, as a theorem.**  With the recorded ceiling
`R² ≤ 0.0785` for every function of the L-mass feature, any threshold criterion on the
L-mass separating the deviation field with margin `δ` satisfies
`4δ²n₁n₂/n ≤ 0.0785 · TSS`. -/
theorem exp566_margin_ceiling {y P : ι → ℝ} {t μ δ : ℝ}
    (hhigh : ∀ i, t ≤ P i → μ + δ ≤ y i) (hlow : ∀ i, ¬ t ≤ P i → y i ≤ μ - δ)
    (hδ : 0 ≤ δ) (hS : (univ.filter fun i => t ≤ P i).Nonempty)
    (hSc : (univ.filter fun i => t ≤ P i)ᶜ.Nonempty) (htss : 0 < tss y)
    (hrsq : rsq y (measurableClass P) ≤ 0.0785) :
    4 * δ ^ 2 * ((univ.filter fun i => t ≤ P i).card : ℝ)
        * (((univ.filter fun i => t ≤ P i)ᶜ).card : ℝ) / (Fintype.card ι : ℝ)
      ≤ 0.0785 * tss y :=
  criterion_margin_le_of_rsq hhigh hlow hδ hS hSc htss hrsq

/-- **The quotable form.**  For a balanced split (`n₁ = n₂ = n/2`) the stage-B ceiling says
that the separating margin of *any* L-mass criterion is at most `√0.0785 ≈ 0.28` sample
standard deviations: `δ² · n ≤ 0.0785 · TSS`. -/
theorem exp566_balanced_margin_ceiling {y P : ι → ℝ} {t μ δ : ℝ}
    (hhigh : ∀ i, t ≤ P i → μ + δ ≤ y i) (hlow : ∀ i, ¬ t ≤ P i → y i ≤ μ - δ)
    (hδ : 0 ≤ δ) (hS : (univ.filter fun i => t ≤ P i).Nonempty)
    (hSc : (univ.filter fun i => t ≤ P i)ᶜ.Nonempty) (htss : 0 < tss y)
    (hrsq : rsq y (measurableClass P) ≤ 0.0785)
    (hbal : ((univ.filter fun i => t ≤ P i).card : ℝ) = (Fintype.card ι : ℝ) / 2)
    (hbal' : (((univ.filter fun i => t ≤ P i)ᶜ).card : ℝ) = (Fintype.card ι : ℝ) / 2) :
    δ ^ 2 * (Fintype.card ι : ℝ) ≤ 0.0785 * tss y := by
  have h := exp566_margin_ceiling hhigh hlow hδ hS hSc htss hrsq
  rw [hbal, hbal'] at h
  have hnpos : (0 : ℝ) < (Fintype.card ι : ℝ) := by
    have : (0 : ℕ) < Fintype.card ι := Fintype.card_pos
    exact_mod_cast this
  have hrw : 4 * δ ^ 2 * ((Fintype.card ι : ℝ) / 2) * ((Fintype.card ι : ℝ) / 2)
      / (Fintype.card ι : ℝ) = δ ^ 2 * (Fintype.card ι : ℝ) := by
    field_simp; ring
  linarith [hrw ▸ h]

/-! ## Incremental ceiling over the size baseline, and the nonlinear floor -/

omit [Nonempty ι] in
/-- **Incremental ceiling.**  If a size baseline `g` is augmented by the L-mass feature `v`
and the total `R²` of the enlarged class exceeds the baseline by at most `Δ`, then the
residual correlation of the L-mass with the size residual is bounded:
`⟨y − g, v⟩² ≤ Δ · ‖v‖² · TSS`.  Contrapositively, a genuine criterion would have had to
show up as a residual correlation. -/
theorem lmass_increment_ceiling {y : ι → ℝ} {T : Set (ι → ℝ)} {g v : ι → ℝ} {Δ : ℝ}
    (hT : ∀ t : ℝ, g + t • v ∈ T) (hv : sqNorm v ≠ 0) (htss : 0 < tss y)
    (hsmall : rsq y T ≤ rsqOf y g + Δ) :
    (dot (y - g) v) ^ 2 ≤ Δ * (sqNorm v * tss y) := by
  have h := rsq_augment_ge hT hv htss (g := g) (v := v)
  have hpos : 0 < sqNorm v * tss y := by
    have : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hv)
    positivity
  have hle : (dot (y - g) v) ^ 2 / (sqNorm v * tss y) ≤ Δ := by linarith
  rw [div_le_iff₀ hpos] at hle
  exact hle

omit [Nonempty ι] in
/-- **Nonlinear floor for the L-mass feature.**  If the deviation readout retains a fraction
`θ` of its energy *within* the level sets of the L-mass, then no predictor built from the
L-mass — linear, monotone, or arbitrary — explains more than `1 − θ`.  This is the form in
which the sweep's cell-level secondary readout (`R² = 0.00052` over 1902 discriminant
cells) constrains the criterion. -/
theorem lmass_nonlinear_floor {y P : ι → ℝ} {θ : ℝ} (htss : 0 < tss y)
    (h : θ * tss y ≤ withinSS y P) : rsq y (measurableClass P) ≤ 1 - θ :=
  residual_floor_of_within htss h

end Ma1Effectivity