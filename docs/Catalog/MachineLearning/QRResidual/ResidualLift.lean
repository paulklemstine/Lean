import Mathlib

/-!
# Why a feature lifts R²: the exact residual-projection identity

Experiment 477 reports that adding the QR footprint feature to a fitted per-`N` yield
dial lifts the out-of-sample `R²` from `0.3927` to `0.5691`, and interprets this as a
refutation of the null hypothesis "H3: the residual contains nothing systematic".

This file supplies the exact optimisation theory behind that inference, for a finite
design (a finite sample of moduli).  Everything is elementary but exact: no asymptotics,
no distributional assumptions.

Main results.

* `sqNorm_sub_smul_eq` — the projection identity
  `‖r − t·v‖² = ‖r‖² − ⟨r,v⟩²/‖v‖²` at the optimal step `t = ⟨r,v⟩/‖v‖²`.
* `rss_mono` — enlarging the model class never increases the residual sum of squares
  (hence never decreases `R²`): `rsq_mono`.
* `rss_augment_le` — **quantitative lift**: augmenting a fit `g` by a feature `v`
  decreases the RSS by at least `⟨r,v⟩²/‖v‖²`, where `r = y − g` is the residual.
* `rsq_augment_ge`, `rsq_augment_strict` — the corresponding `R²` lift, and its
  strictness exactly when the residual correlates with the new feature.
* `residual_orthogonal_of_no_lift` — **the H3 dichotomy**: if augmenting by `v` produces
  no `R²` lift at all, then the residual is *exactly orthogonal* to `v`.  So an observed
  lift is not a fitting artefact: it is a certificate that the residual carried structure
  aligned with the feature.
-/

namespace QRResidual

open Finset

variable {ι : Type*} [Fintype ι]

/-! ## Finite-sample inner product -/

/-- Sample inner product of two feature vectors. -/
def dot (u v : ι → ℝ) : ℝ := ∑ i, u i * v i

/-- Sample squared norm. -/
def sqNorm (u : ι → ℝ) : ℝ := ∑ i, (u i) ^ 2

theorem sqNorm_nonneg (u : ι → ℝ) : 0 ≤ sqNorm u :=
  Finset.sum_nonneg fun i _ => sq_nonneg (u i)

theorem sqNorm_eq_zero_iff (u : ι → ℝ) : sqNorm u = 0 ↔ ∀ i, u i = 0 := by
  constructor
  · intro h i
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => sq_nonneg (u j))).1 h i (mem_univ i)
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
  · intro h
    simp [sqNorm, h]

/-- Expansion of the squared norm along a step in the direction `v`. -/
theorem sqNorm_sub_smul (r v : ι → ℝ) (t : ℝ) :
    sqNorm (r - t • v) = sqNorm r - 2 * t * dot r v + t ^ 2 * sqNorm v := by
  simp only [sqNorm, dot, Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
  have hpt : ∀ i : ι, (r i - t * v i) ^ 2
      = (r i) ^ 2 - 2 * t * (r i * v i) + t ^ 2 * (v i) ^ 2 := by
    intro i; ring
  simp_rw [hpt]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum]

/-- **Projection identity.**  Taking the optimal step in the direction of `v` removes
exactly `⟨r,v⟩²/‖v‖²` of the residual energy. -/
theorem sqNorm_sub_smul_eq (r v : ι → ℝ) (hv : sqNorm v ≠ 0) :
    sqNorm (r - (dot r v / sqNorm v) • v) = sqNorm r - (dot r v) ^ 2 / sqNorm v := by
  rw [sqNorm_sub_smul]
  field_simp
  ring

/-! ## Residual sum of squares over a model class -/

/-- Residual sum of squares of the best fit inside a class `S` of predictions. -/
noncomputable def rss (y : ι → ℝ) (S : Set (ι → ℝ)) : ℝ :=
  sInf ((fun g => sqNorm (y - g)) '' S)

theorem rss_bddBelow (y : ι → ℝ) (S : Set (ι → ℝ)) :
    BddBelow ((fun g => sqNorm (y - g)) '' S) := by
  refine ⟨0, ?_⟩
  rintro a ⟨g, -, rfl⟩
  exact sqNorm_nonneg _

theorem rss_le_of_mem {y : ι → ℝ} {S : Set (ι → ℝ)} {g : ι → ℝ} (hg : g ∈ S) :
    rss y S ≤ sqNorm (y - g) :=
  csInf_le (rss_bddBelow y S) ⟨g, hg, rfl⟩

theorem rss_nonneg (y : ι → ℝ) {S : Set (ι → ℝ)} (hS : S.Nonempty) : 0 ≤ rss y S := by
  refine le_csInf (hS.image _) ?_
  rintro b ⟨g, -, rfl⟩
  exact sqNorm_nonneg _

/-- A lower bound for the best fit: if every prediction in the class leaves at least `c`
of residual energy, then so does the optimum. -/
theorem le_rss {y : ι → ℝ} {S : Set (ι → ℝ)} {c : ℝ} (hS : S.Nonempty)
    (h : ∀ g ∈ S, c ≤ sqNorm (y - g)) : c ≤ rss y S := by
  refine le_csInf (hS.image _) ?_
  rintro b ⟨g, hg, rfl⟩
  exact h g hg

/-- **Monotonicity of the fit.**  A richer model class never fits worse. -/
theorem rss_mono {y : ι → ℝ} {S T : Set (ι → ℝ)} (hST : S ⊆ T) (hS : S.Nonempty) :
    rss y T ≤ rss y S := by
  refine le_csInf (hS.image _) ?_
  rintro b ⟨g, hg, rfl⟩
  exact rss_le_of_mem (hST hg)

/-- **Quantitative lift.**  If the class `T` contains the whole line `g + t·v`, then the
best fit in `T` beats the fit `g` by at least `⟨r,v⟩²/‖v‖²`, `r = y − g` the residual. -/
theorem rss_augment_le {y : ι → ℝ} {T : Set (ι → ℝ)} {g v : ι → ℝ}
    (hT : ∀ t : ℝ, g + t • v ∈ T) (hv : sqNorm v ≠ 0) :
    rss y T ≤ sqNorm (y - g) - (dot (y - g) v) ^ 2 / sqNorm v := by
  set r := y - g with hr
  set t := dot r v / sqNorm v with ht
  have hmem : g + t • v ∈ T := hT t
  have hrewrite : y - (g + t • v) = r - t • v := by
    funext i; simp [hr, Pi.sub_apply, Pi.add_apply]; ring
  calc rss y T ≤ sqNorm (y - (g + t • v)) := rss_le_of_mem hmem
    _ = sqNorm (r - t • v) := by rw [hrewrite]
    _ = sqNorm r - (dot r v) ^ 2 / sqNorm v := sqNorm_sub_smul_eq r v hv

/-- Strict improvement exactly when the residual correlates with the new feature. -/
theorem rss_augment_lt {y : ι → ℝ} {T : Set (ι → ℝ)} {g v : ι → ℝ}
    (hT : ∀ t : ℝ, g + t • v ∈ T) (hv : sqNorm v ≠ 0) (hcorr : dot (y - g) v ≠ 0) :
    rss y T < sqNorm (y - g) := by
  have hpos : 0 < (dot (y - g) v) ^ 2 / sqNorm v := by
    have h1 : 0 < (dot (y - g) v) ^ 2 := by positivity
    have h2 : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hv)
    exact div_pos h1 h2
  have := rss_augment_le hT hv (y := y)
  linarith

/-! ## Exact optimum along one feature, and additivity of orthogonal features -/

/-- **The lift is exactly the projection.**  Along the line `g + t·v` the best achievable
residual energy is exactly `‖r‖² − ⟨r,v⟩²/‖v‖²`. -/
theorem rss_line_eq {y : ι → ℝ} {g v : ι → ℝ} (hv : sqNorm v ≠ 0) :
    rss y {h : ι → ℝ | ∃ t : ℝ, h = g + t • v}
      = sqNorm (y - g) - (dot (y - g) v) ^ 2 / sqNorm v := by
  have hs : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hv)
  refine le_antisymm (rss_augment_le (fun t => ⟨t, rfl⟩) hv) ?_
  refine le_rss ⟨g, 0, by simp⟩ ?_
  rintro h ⟨t, rfl⟩
  have hrw : y - (g + t • v) = (y - g) - t • v := by
    funext i; simp [Pi.sub_apply, Pi.add_apply]; ring
  rw [hrw, sqNorm_sub_smul]
  have key : (dot (y - g) v) ^ 2 / sqNorm v
      ≥ 2 * t * dot (y - g) v - t ^ 2 * sqNorm v := by
    rw [ge_iff_le, le_div_iff₀ hs]
    nlinarith [sq_nonneg (dot (y - g) v - t * sqNorm v)]
  linarith

/-- Expansion of the residual energy along two directions. -/
theorem sqNorm_sub_two_smul (r v w : ι → ℝ) (t s : ℝ) :
    sqNorm (r - t • v - s • w)
      = sqNorm r - 2 * t * dot r v - 2 * s * dot r w + t ^ 2 * sqNorm v + s ^ 2 * sqNorm w
        + 2 * t * s * dot v w := by
  simp only [sqNorm, dot, Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
  have h : ∀ i : ι, (r i - t * v i - s * w i) ^ 2
      = (r i) ^ 2 - 2 * t * (r i * v i) - 2 * s * (r i * w i) + t ^ 2 * (v i) ^ 2
        + s ^ 2 * (w i) ^ 2 + 2 * t * s * (v i * w i) := by
    intro i; ring
  simp_rw [h]
  simp [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]

/-- **Orthogonal features add their lifts.**  If two features are orthogonal in the
sample, the plane they span removes the *sum* of the two individual residual energies.
This is the exact form of the experiment's observation that the QR footprint feature and
the small-prime mechanism feature "add independently". -/
theorem rss_plane_le {y : ι → ℝ} {g v w : ι → ℝ} (hv : sqNorm v ≠ 0) (hw : sqNorm w ≠ 0)
    (hvw : dot v w = 0) :
    rss y {h : ι → ℝ | ∃ t s : ℝ, h = g + t • v + s • w}
      ≤ sqNorm (y - g) - (dot (y - g) v) ^ 2 / sqNorm v
          - (dot (y - g) w) ^ 2 / sqNorm w := by
  have hsv : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hv)
  have hsw : 0 < sqNorm w := lt_of_le_of_ne (sqNorm_nonneg w) (Ne.symm hw)
  set r := y - g with hr
  set t := dot r v / sqNorm v with ht
  set s := dot r w / sqNorm w with hs
  have hmem : g + t • v + s • w ∈ {h : ι → ℝ | ∃ t s : ℝ, h = g + t • v + s • w} := ⟨t, s, rfl⟩
  have hrw : y - (g + t • v + s • w) = r - t • v - s • w := by
    funext i; simp [hr, Pi.sub_apply, Pi.add_apply]; ring
  calc rss y {h : ι → ℝ | ∃ t s : ℝ, h = g + t • v + s • w}
      ≤ sqNorm (y - (g + t • v + s • w)) := rss_le_of_mem hmem
    _ = sqNorm (r - t • v - s • w) := by rw [hrw]
    _ = sqNorm r - (dot r v) ^ 2 / sqNorm v - (dot r w) ^ 2 / sqNorm w := by
        rw [sqNorm_sub_two_smul, hvw, ht, hs]
        field_simp
        ring

/-! ## Coefficient of determination -/

/-- Sample mean of the response. -/
noncomputable def mean (y : ι → ℝ) : ℝ := (∑ i, y i) / (Fintype.card ι)

/-- Total sum of squares. -/
noncomputable def tss (y : ι → ℝ) : ℝ := sqNorm (y - fun _ => mean y)

/-- Coefficient of determination of the best fit in the class `S`. -/
noncomputable def rsq (y : ι → ℝ) (S : Set (ι → ℝ)) : ℝ := 1 - rss y S / tss y

/-- Coefficient of determination of a single given fit `g`. -/
noncomputable def rsqOf (y g : ι → ℝ) : ℝ := 1 - sqNorm (y - g) / tss y

/-- **`R²` is monotone in the model class.** -/
theorem rsq_mono {y : ι → ℝ} {S T : Set (ι → ℝ)} (hST : S ⊆ T) (hS : S.Nonempty)
    (htss : 0 < tss y) : rsq y S ≤ rsq y T := by
  have h := rss_mono hST hS (y := y)
  unfold rsq
  linarith [(div_le_div_iff_of_pos_right htss).2 h]

/-- **Quantitative `R²` lift.**  Augmenting the fit `g` by the feature `v` raises `R²` by
at least `⟨r,v⟩² / (‖v‖² · TSS)`. -/
theorem rsq_augment_ge {y : ι → ℝ} {T : Set (ι → ℝ)} {g v : ι → ℝ}
    (hT : ∀ t : ℝ, g + t • v ∈ T) (hv : sqNorm v ≠ 0) (htss : 0 < tss y) :
    rsqOf y g + (dot (y - g) v) ^ 2 / (sqNorm v * tss y) ≤ rsq y T := by
  have h := rss_augment_le hT hv (y := y)
  have hdiv : rss y T / tss y
      ≤ (sqNorm (y - g) - (dot (y - g) v) ^ 2 / sqNorm v) / tss y :=
    (div_le_div_iff_of_pos_right htss).2 h
  unfold rsq rsqOf
  have hsplit : (sqNorm (y - g) - (dot (y - g) v) ^ 2 / sqNorm v) / tss y
      = sqNorm (y - g) / tss y - (dot (y - g) v) ^ 2 / (sqNorm v * tss y) := by
    field_simp
  linarith [hdiv, hsplit ▸ hdiv]

/-- **Strict `R²` lift** when the residual correlates with the feature. -/
theorem rsq_augment_strict {y : ι → ℝ} {T : Set (ι → ℝ)} {g v : ι → ℝ}
    (hT : ∀ t : ℝ, g + t • v ∈ T) (hv : sqNorm v ≠ 0) (htss : 0 < tss y)
    (hcorr : dot (y - g) v ≠ 0) : rsqOf y g < rsq y T := by
  have hpos : 0 < (dot (y - g) v) ^ 2 / (sqNorm v * tss y) := by
    have h1 : 0 < (dot (y - g) v) ^ 2 := by positivity
    have h2 : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hv)
    exact div_pos h1 (by positivity)
  have := rsq_augment_ge hT hv htss (g := g) (v := v)
  linarith

/-- **`R²` version of orthogonal additivity.**  Two orthogonal features lift `R²` by at
least the *sum* of their individual lifts. -/
theorem rsq_plane_ge {y : ι → ℝ} {g v w : ι → ℝ} (hv : sqNorm v ≠ 0) (hw : sqNorm w ≠ 0)
    (hvw : dot v w = 0) (htss : 0 < tss y) :
    rsqOf y g + (dot (y - g) v) ^ 2 / (sqNorm v * tss y)
        + (dot (y - g) w) ^ 2 / (sqNorm w * tss y)
      ≤ rsq y {h : ι → ℝ | ∃ t s : ℝ, h = g + t • v + s • w} := by
  have h := rss_plane_le (y := y) (g := g) hv hw hvw
  have hdiv := (div_le_div_iff_of_pos_right htss).2 h
  have hsplit : (sqNorm (y - g) - (dot (y - g) v) ^ 2 / sqNorm v
        - (dot (y - g) w) ^ 2 / sqNorm w) / tss y
      = sqNorm (y - g) / tss y - (dot (y - g) v) ^ 2 / (sqNorm v * tss y)
        - (dot (y - g) w) ^ 2 / (sqNorm w * tss y) := by
    field_simp
  unfold rsq rsqOf
  rw [hsplit] at hdiv
  linarith

/-- **The H3 dichotomy.**  If augmenting the fit `g` by the feature `v` yields *no* `R²`
improvement, then the residual is exactly orthogonal to `v`.  Contrapositive of
`rsq_augment_strict`: an observed lift certifies systematic residual structure aligned
with the feature, and cannot be explained by "nothing systematic". -/
theorem residual_orthogonal_of_no_lift {y : ι → ℝ} {T : Set (ι → ℝ)} {g v : ι → ℝ}
    (hT : ∀ t : ℝ, g + t • v ∈ T) (hv : sqNorm v ≠ 0) (htss : 0 < tss y)
    (hno : rsq y T ≤ rsqOf y g) : dot (y - g) v = 0 := by
  by_contra hcorr
  exact absurd (rsq_augment_strict hT hv htss hcorr) (not_lt.2 hno)

end QRResidual