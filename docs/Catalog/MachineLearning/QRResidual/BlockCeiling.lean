import MachineLearning.QRResidual.ResidualLift

/-!
# Ceilings for a block of covariates: how to certify a null result

`ResidualLift` supplies the *positive* half of feature-augmentation theory: a feature that
correlates with the residual of a baseline fit provably lifts `R²`.  Experiment 585 needs
the *negative* half.  There a block of four "neighbour smoothness" covariates
`[ω(N−1), ω(N+1), log lpf(N−1), log lpf(N+1)]` was appended to a baseline built from the
quadratic-residue footprint dial, and the observed incremental `R²` was
`ΔR² = 0.4307 − 0.4112 = 0.01946`, with best single residual correlation `|r| = 0.16`.
The pre-registered null was `ΔR² < 0.02`.

An observed small `ΔR²` is, by itself, only a measurement.  What turns it into a *bound*
is a theorem of the form "with these correlations and this design conditioning, no
`ΔR²` larger than … is possible".  That is what this file proves.

Main results.

* `key_amgm` — the scalar AM–GM step `2D ≤ λa + S/λ` from `D² ≤ aS`.
* `rss_block_ge` — **the block ceiling.**  If the block `v : Fin k → (ι → ℝ)` satisfies a
  lower frame bound `λ‖c‖² ≤ ‖Σ cⱼvⱼ‖²`, then *no* linear combination of the block can
  remove more than `(Σⱼ⟨r,vⱼ⟩²)/λ` of the residual energy.
* `rsq_block_le`, `rsq_block_le_of_corr` — the `R²` form, and the quotable certificate
  `ΔR² ≤ k ρ² (1 − R²₀)/λ` for a unit-normalised block whose residual correlations are all
  at most `ρ`.
* `block_lift_iff_exists_corr` — the exact dichotomy: a block lifts `R²` **iff** at least
  one of its features correlates with the baseline residual.
* `rss_blockPlus_le`, `rsq_blockPlus_ge` — **conditional dominance.**  A feature orthogonal
  to the block keeps its entire individual lift after the block has been fitted; the block
  cannot absorb it.
* `lift_asymmetry` — the capstone: under a correlation ceiling on the block and a lift
  floor on the dial, the dial's incremental value *given the block* strictly exceeds the
  block's incremental value *given the baseline*.  This is the formal shape of the
  experiment's verdict "nothing beyond the dial".
-/

namespace QRResidual

open Finset

variable {ι : Type*} [Fintype ι] {k : ℕ}

/-! ## Elementary bilinear algebra of the sample inner product -/

/-- Expansion of the residual energy after subtracting an arbitrary correction. -/
theorem sqNorm_sub (r u : ι → ℝ) : sqNorm (r - u) = sqNorm r - 2 * dot r u + sqNorm u := by
  simp only [sqNorm, dot, Pi.sub_apply]
  have h : ∀ i : ι, (r i - u i) ^ 2 = (r i) ^ 2 - 2 * (r i * u i) + (u i) ^ 2 := by
    intro i; ring
  simp_rw [h]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.mul_sum]

theorem dot_sub_left (r u w : ι → ℝ) : dot (r - u) w = dot r w - dot u w := by
  simp only [dot, Pi.sub_apply, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

theorem dot_comm (u w : ι → ℝ) : dot u w = dot w u := by
  simp only [dot]
  exact Finset.sum_congr rfl fun i _ => mul_comm _ _

/-! ## The linear span of a block of covariates -/

/-- The prediction contributed by the block `v` with coefficient vector `c`. -/
def blockSpan (v : Fin k → (ι → ℝ)) (c : Fin k → ℝ) : ι → ℝ := ∑ j, c j • v j

omit [Fintype ι] in
theorem blockSpan_apply (v : Fin k → (ι → ℝ)) (c : Fin k → ℝ) (i : ι) :
    blockSpan v c i = ∑ j, c j * v j i := by
  simp [blockSpan, Finset.sum_apply]

/-- The model class obtained by augmenting the baseline `g` with the whole block. -/
def blockClass (g : ι → ℝ) (v : Fin k → (ι → ℝ)) : Set (ι → ℝ) :=
  {h : ι → ℝ | ∃ c : Fin k → ℝ, h = g + blockSpan v c}

/-- A **lower frame bound** for the block: the design matrix is not arbitrarily
ill-conditioned.  For an orthonormal block one may take `λ = 1`; in general `λ` is the
smallest eigenvalue of the Gram matrix. -/
def FrameLower (lam : ℝ) (v : Fin k → (ι → ℝ)) : Prop :=
  ∀ c : Fin k → ℝ, lam * ∑ j, (c j) ^ 2 ≤ sqNorm (blockSpan v c)

theorem dot_blockSpan (r : ι → ℝ) (v : Fin k → (ι → ℝ)) (c : Fin k → ℝ) :
    dot r (blockSpan v c) = ∑ j, c j * dot r (v j) := by
  simp only [dot, blockSpan_apply, Finset.mul_sum]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun j _ => ?_
  exact Finset.sum_congr rfl fun i _ => by ring

omit [Fintype ι] in
/-- Selecting a single coordinate of the block recovers the single-feature line. -/
theorem blockSpan_single (v : Fin k → (ι → ℝ)) (j : Fin k) (t : ℝ) :
    blockSpan v (Pi.single j t) = t • v j := by
  funext i
  rw [blockSpan_apply]
  rw [Finset.sum_eq_single j]
  · simp
  · intro b _ hb; simp [Pi.single_eq_of_ne hb]
  · intro h; exact absurd (Finset.mem_univ j) h

omit [Fintype ι] in
/-- Every single-feature line through `g` lies in the block class. -/
theorem line_mem_blockClass (g : ι → ℝ) (v : Fin k → (ι → ℝ)) (j : Fin k) (t : ℝ) :
    g + t • v j ∈ blockClass g v :=
  ⟨Pi.single j t, by rw [blockSpan_single]⟩

/-- A frame bound forces every block feature to be nondegenerate. -/
theorem sqNorm_pos_of_frame {lam : ℝ} (hlam : 0 < lam) {v : Fin k → (ι → ℝ)}
    (hframe : FrameLower lam v) (j : Fin k) : 0 < sqNorm (v j) := by
  have h := hframe (Pi.single j (1 : ℝ))
  rw [blockSpan_single, one_smul] at h
  have hsum : (∑ j' : Fin k, ((Pi.single j (1 : ℝ) : Fin k → ℝ) j') ^ 2) = 1 := by
    rw [Finset.sum_eq_single j]
    · simp
    · intro b _ hb; simp [Pi.single_eq_of_ne hb]
    · intro h'; exact absurd (Finset.mem_univ j) h'
  rw [hsum, mul_one] at h
  linarith

/-! ## The scalar core: an AM–GM step -/

/-- **Scalar core of the ceiling.**  If `D² ≤ a S` with `a, S ≥ 0` and `λ > 0`, then
`2D ≤ λa + S/λ`.  Applied with `a = ‖c‖²`, `S = Σⱼ⟨r,vⱼ⟩²` this is exactly the statement
that no coefficient vector can extract more than `S/λ`. -/
theorem key_amgm {lam a S D : ℝ} (hlam : 0 < lam) (ha : 0 ≤ a) (hS : 0 ≤ S)
    (hD : D ^ 2 ≤ a * S) : 2 * D ≤ lam * a + S / lam := by
  rcases le_or_gt D 0 with hD0 | hD0
  · have h1 : 0 ≤ lam * a := mul_nonneg hlam.le ha
    have h2 : 0 ≤ S / lam := div_nonneg hS hlam.le
    linarith
  · have hmul : 4 * lam ^ 2 * D ^ 2 ≤ 4 * lam ^ 2 * (a * S) :=
      mul_le_mul_of_nonneg_left hD (by positivity)
    have h1 : (2 * lam * D) ^ 2 ≤ (lam ^ 2 * a + S) ^ 2 := by
      nlinarith [sq_nonneg (lam ^ 2 * a - S)]
    have h2 : (0 : ℝ) ≤ lam ^ 2 * a + S := by positivity
    have h3 : (0 : ℝ) ≤ 2 * lam * D := by positivity
    have h4 : 2 * lam * D ≤ lam ^ 2 * a + S := by nlinarith [h1, h2, h3]
    have heq : lam * a + S / lam - 2 * D = (lam ^ 2 * a + S - 2 * lam * D) / lam := by
      field_simp
    have h5 : 0 ≤ (lam ^ 2 * a + S - 2 * lam * D) / lam :=
      div_nonneg (by linarith) hlam.le
    linarith [heq ▸ h5]

/-! ## The block ceiling -/

/-- **The block ceiling (RSS form).**  Under a lower frame bound `λ`, no linear
combination of the block removes more than `(Σⱼ⟨r,vⱼ⟩²)/λ` of the residual energy of the
baseline `g`. -/
theorem rss_block_ge {lam : ℝ} (hlam : 0 < lam) {v : Fin k → (ι → ℝ)}
    (hframe : FrameLower lam v) (y g : ι → ℝ) :
    sqNorm (y - g) - (∑ j, (dot (y - g) (v j)) ^ 2) / lam ≤ rss y (blockClass g v) := by
  refine le_rss ⟨g + blockSpan v 0, ⟨0, rfl⟩⟩ ?_
  rintro h ⟨c, rfl⟩
  have hrw : y - (g + blockSpan v c) = (y - g) - blockSpan v c := by
    funext i; simp only [Pi.sub_apply, Pi.add_apply]; ring
  have hexp : sqNorm ((y - g) - blockSpan v c)
      = sqNorm (y - g) - 2 * dot (y - g) (blockSpan v c) + sqNorm (blockSpan v c) :=
    sqNorm_sub _ _
  rw [hrw, hexp]
  set a : ℝ := ∑ j, (c j) ^ 2 with ha'
  set S : ℝ := ∑ j, (dot (y - g) (v j)) ^ 2 with hS'
  set D : ℝ := dot (y - g) (blockSpan v c) with hD'
  have hcs : D ^ 2 ≤ a * S := by
    rw [hD', dot_blockSpan]
    exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _
  have haa : 0 ≤ a := Finset.sum_nonneg fun j _ => sq_nonneg _
  have hSS : 0 ≤ S := Finset.sum_nonneg fun j _ => sq_nonneg _
  have hfr : lam * a ≤ sqNorm (blockSpan v c) := hframe c
  have := key_amgm hlam haa hSS hcs
  linarith

/-- **The block ceiling (`R²` form).** -/
theorem rsq_block_le {lam : ℝ} (hlam : 0 < lam) {v : Fin k → (ι → ℝ)}
    (hframe : FrameLower lam v) (y g : ι → ℝ) (htss : 0 < tss y) :
    rsq y (blockClass g v)
      ≤ rsqOf y g + (∑ j, (dot (y - g) (v j)) ^ 2) / (lam * tss y) := by
  have h := rss_block_ge hlam hframe y g
  have hdiv := (div_le_div_iff_of_pos_right htss).2 h
  have hsplit : (sqNorm (y - g) - (∑ j, (dot (y - g) (v j)) ^ 2) / lam) / tss y
      = sqNorm (y - g) / tss y - (∑ j, (dot (y - g) (v j)) ^ 2) / (lam * tss y) := by
    field_simp
  rw [hsplit] at hdiv
  unfold rsq rsqOf
  linarith

/-- The residual energy of the baseline in terms of its `R²`. -/
theorem sqNorm_residual_eq {y g : ι → ℝ} (htss : 0 < tss y) :
    sqNorm (y - g) = (1 - rsqOf y g) * tss y := by
  unfold rsqOf
  field_simp
  ring

/-- **The quotable H0 certificate.**  For a unit-normalised block of `k` covariates with a
lower frame bound `λ`, all of whose residual correlations are at most `ρ` in absolute
value, the incremental `R²` over the baseline `g` cannot exceed `k ρ² (1 − R²₀)/λ`.

This is a *bound*, not a measurement: it holds for the population-optimal fit of the whole
block, so no amount of refitting can beat it. -/
theorem rsq_block_le_of_corr {lam rho : ℝ} (hlam : 0 < lam) {v : Fin k → (ι → ℝ)}
    (hframe : FrameLower lam v) (y g : ι → ℝ) (htss : 0 < tss y)
    (hcorr : ∀ j, (dot (y - g) (v j)) ^ 2 ≤ rho ^ 2 * sqNorm (y - g)) :
    rsq y (blockClass g v) - rsqOf y g ≤ k * rho ^ 2 * (1 - rsqOf y g) / lam := by
  have hceil := rsq_block_le hlam hframe y g htss
  have hsum : (∑ j, (dot (y - g) (v j)) ^ 2) ≤ k * (rho ^ 2 * sqNorm (y - g)) := by
    calc (∑ j, (dot (y - g) (v j)) ^ 2)
        ≤ ∑ _j : Fin k, rho ^ 2 * sqNorm (y - g) :=
          Finset.sum_le_sum fun j _ => hcorr j
      _ = k * (rho ^ 2 * sqNorm (y - g)) := by
          simp [Finset.sum_const, nsmul_eq_mul]
  have hr := sqNorm_residual_eq (y := y) (g := g) htss
  have hstep : (∑ j, (dot (y - g) (v j)) ^ 2) / (lam * tss y)
      ≤ k * rho ^ 2 * (1 - rsqOf y g) / lam := by
    rw [div_le_div_iff₀ (by positivity) hlam]
    have h2 : (k : ℝ) * rho ^ 2 * (1 - rsqOf y g) * (lam * tss y)
        = lam * ((k : ℝ) * (rho ^ 2 * ((1 - rsqOf y g) * tss y))) := by ring
    rw [h2, ← hr]
    have : (∑ j, (dot (y - g) (v j)) ^ 2) * lam
        ≤ (k * (rho ^ 2 * sqNorm (y - g))) * lam :=
      mul_le_mul_of_nonneg_right hsum hlam.le
    nlinarith [this]
  linarith

/-! ## The exact dichotomy for a block -/

/-- If every block feature is orthogonal to the baseline residual, the block cannot lift
`R²` at all. -/
theorem block_no_lift_of_orthogonal {lam : ℝ} (hlam : 0 < lam) {v : Fin k → (ι → ℝ)}
    (hframe : FrameLower lam v) {y g : ι → ℝ} (htss : 0 < tss y)
    (horth : ∀ j, dot (y - g) (v j) = 0) :
    rsq y (blockClass g v) ≤ rsqOf y g := by
  have h := rsq_block_le hlam hframe y g htss
  have hz : (∑ j, (dot (y - g) (v j)) ^ 2) = 0 := by
    refine Finset.sum_eq_zero fun j _ => ?_
    rw [horth j]; ring
  rw [hz] at h
  simpa using h

/-- **The block dichotomy.**  A block lifts `R²` over the baseline *if and only if* one of
its features correlates with the baseline residual.  A null result is therefore an exact
orthogonality statement, not a failure to find a fit. -/
theorem block_lift_iff_exists_corr {lam : ℝ} (hlam : 0 < lam) {v : Fin k → (ι → ℝ)}
    (hframe : FrameLower lam v) {y g : ι → ℝ} (htss : 0 < tss y) :
    rsqOf y g < rsq y (blockClass g v) ↔ ∃ j, dot (y - g) (v j) ≠ 0 := by
  constructor
  · intro hlift
    by_contra hno
    push_neg at hno
    exact absurd (block_no_lift_of_orthogonal hlam hframe htss hno) (not_le.2 hlift)
  · rintro ⟨j, hj⟩
    exact rsq_augment_strict (fun t => line_mem_blockClass g v j t)
      (sqNorm_pos_of_frame hlam hframe j).ne' htss hj

/-! ## Conditional dominance: the block cannot absorb an orthogonal feature -/

/-- The model class obtained by augmenting the block class further by one feature `w`. -/
def blockClassPlus (g : ι → ℝ) (v : Fin k → (ι → ℝ)) (w : ι → ℝ) : Set (ι → ℝ) :=
  {h : ι → ℝ | ∃ (c : Fin k → ℝ) (t : ℝ), h = g + blockSpan v c + t • w}

/-- **Conditional dominance (RSS form).**  If `w` is orthogonal to every block feature,
then fitting the block first costs `w` nothing: the joint fit still gains the full
`⟨r,w⟩²/‖w‖²` over the block-only fit. -/
theorem rss_blockPlus_le {v : Fin k → (ι → ℝ)} {w : ι → ℝ} (hw : sqNorm w ≠ 0)
    (horth : ∀ j, dot (v j) w = 0) (y g : ι → ℝ) :
    rss y (blockClassPlus g v w)
      ≤ rss y (blockClass g v) - (dot (y - g) w) ^ 2 / sqNorm w := by
  set r := y - g with hr
  set L : ℝ := (dot r w) ^ 2 / sqNorm w with hL
  refine le_of_forall_pos_le_add ?_
  intro ε hε
  -- pick a nearly optimal coefficient vector for the block
  obtain ⟨b, hbmem, hblt⟩ :
      ∃ b ∈ (fun h => sqNorm (y - h)) '' blockClass g v, b < rss y (blockClass g v) + ε := by
    have hne : ((fun h => sqNorm (y - h)) '' blockClass g v).Nonempty :=
      ⟨sqNorm (y - (g + blockSpan v 0)), ⟨_, ⟨0, rfl⟩, rfl⟩⟩
    exact exists_lt_of_csInf_lt hne (by linarith : rss y (blockClass g v)
      < rss y (blockClass g v) + ε)
  obtain ⟨h, ⟨c, rfl⟩, rfl⟩ := hbmem
  have hspan : y - (g + blockSpan v c) = r - blockSpan v c := by
    funext i; simp only [hr, Pi.sub_apply, Pi.add_apply]; ring
  -- the residual after the block still has the same correlation with `w`
  have hdotu : dot (blockSpan v c) w = 0 := by
    have : dot (blockSpan v c) w = ∑ j, c j * dot (v j) w := by
      rw [dot_comm, dot_blockSpan]
      exact Finset.sum_congr rfl fun j _ => by rw [dot_comm]
    rw [this]
    exact Finset.sum_eq_zero fun j _ => by rw [horth j]; ring
  have hdotr : dot (r - blockSpan v c) w = dot r w := by
    rw [dot_sub_left, hdotu, sub_zero]
  set t : ℝ := dot (r - blockSpan v c) w / sqNorm w with ht
  have hmem : g + blockSpan v c + t • w ∈ blockClassPlus g v w := ⟨c, t, rfl⟩
  have hrw2 : y - (g + blockSpan v c + t • w) = (r - blockSpan v c) - t • w := by
    funext i; simp only [hr, Pi.sub_apply, Pi.add_apply, Pi.smul_apply, smul_eq_mul]; ring
  have hcalc : sqNorm (y - (g + blockSpan v c + t • w))
      = sqNorm (r - blockSpan v c) - (dot (r - blockSpan v c) w) ^ 2 / sqNorm w := by
    rw [hrw2, ht]
    exact sqNorm_sub_smul_eq _ _ hw
  have hstep : rss y (blockClassPlus g v w)
      ≤ sqNorm (r - blockSpan v c) - L := by
    have := rss_le_of_mem (y := y) hmem
    rw [hcalc, hdotr] at this
    exact this
  have : sqNorm (r - blockSpan v c) = sqNorm (y - (g + blockSpan v c)) := by rw [hspan]
  linarith [hstep, hblt, this]

/-- **Conditional dominance (`R²` form).**  The incremental `R²` of an orthogonal feature
`w` *given* the block is at least its individual lift `⟨r,w⟩²/(‖w‖²·TSS)`. -/
theorem rsq_blockPlus_ge {v : Fin k → (ι → ℝ)} {w : ι → ℝ} (hw : sqNorm w ≠ 0)
    (horth : ∀ j, dot (v j) w = 0) (y g : ι → ℝ) (htss : 0 < tss y) :
    rsq y (blockClass g v) + (dot (y - g) w) ^ 2 / (sqNorm w * tss y)
      ≤ rsq y (blockClassPlus g v w) := by
  have h := rss_blockPlus_le hw horth y g
  have hdiv := (div_le_div_iff_of_pos_right htss).2 h
  have hsplit : (rss y (blockClass g v) - (dot (y - g) w) ^ 2 / sqNorm w) / tss y
      = rss y (blockClass g v) / tss y - (dot (y - g) w) ^ 2 / (sqNorm w * tss y) := by
    field_simp
  rw [hsplit] at hdiv
  unfold rsq
  linarith

/-! ## The asymmetry capstone -/

/-- **Lift asymmetry: "nothing beyond the dial".**

Hypotheses: the covariate block `v` is unit-normalised with lower frame bound `λ`, all of
its residual correlations are at most `ρ`; the dial feature `w` is orthogonal to the block
and its individual lift is at least `d`; and the block ceiling `k ρ²(1−R²₀)/λ` is below
`d`.

Conclusion: the *incremental* value of the dial given the block strictly exceeds the
incremental value of the whole block given the baseline.  The block is therefore not a
competing explanation of the response — it is a null layer sitting beside the dial. -/
theorem lift_asymmetry {lam rho d : ℝ} (hlam : 0 < lam) {v : Fin k → (ι → ℝ)} {w : ι → ℝ}
    (hframe : FrameLower lam v) (hw : sqNorm w ≠ 0) (horth : ∀ j, dot (v j) w = 0)
    (y g : ι → ℝ) (htss : 0 < tss y)
    (hcorr : ∀ j, (dot (y - g) (v j)) ^ 2 ≤ rho ^ 2 * sqNorm (y - g))
    (hd : d ≤ (dot (y - g) w) ^ 2 / (sqNorm w * tss y))
    (hgap : k * rho ^ 2 * (1 - rsqOf y g) / lam < d) :
    rsq y (blockClass g v) - rsqOf y g
      < rsq y (blockClassPlus g v w) - rsq y (blockClass g v) := by
  have hceil := rsq_block_le_of_corr hlam hframe y g htss hcorr
  have hdom := rsq_blockPlus_ge hw horth y g htss
  linarith

end QRResidual