import Probability.EMLScalingGroupDuality

/-!
# Cycle 4: centralizers in the global scaling group

`Catalog/Probability/EMLNilpotentCentralizer.lean` determined the centralizer of
an EML *vector field*: for `g ≠ 0` it is exactly the line `ℝ · emlField g`.
This file integrates that infinitesimal statement to the group level, i.e. it
computes centralizers inside the group `ScalingMap` of continuous scaling
transformations `y ↦ c y ^ k` of `(0, ∞)` and inside its exp–log partner
`AffMap`.

The outcome differs from the naive guess "the centralizer is the one-parameter
subgroup through the element":

* `AffMap.commute_iff` : `f` and `g` commute **iff**
  `g.trans (f.lin − 1) = f.trans (g.lin − 1)`.  This single bilinear identity
  covers all cases at once.
* `AffMap.commute_iff_fixes_fixedPoint` : if `f.lin ≠ 1` then `f` has a unique
  fixed point `x* = f.trans / (1 − f.lin)`, and `g` commutes with `f` **iff**
  `g` fixes `x*`.  The centralizer is therefore the full stabilizer of a point,
  a group isomorphic to `ℝˣ` — strictly larger than the one-parameter subgroup
  through `f`, which only produces positive linear parts.
* `AffMap.commute_iff_of_lin_eq_one` : if `f` is a nontrivial translation, the
  centralizer is exactly the translation subgroup.
* `AffMap.centralizer_commutative` / `ScalingMap.centralizer_commutative` : in
  both cases the centralizer of a non-identity element is abelian.  This is the
  group-level shadow of the one-dimensionality of the infinitesimal centralizer:
  the centralizer of a nontrivial element is a one-dimensional (albeit
  disconnected) subgroup.
* Everything is transported to `ScalingMap` along the exp–log isomorphism
  `expLogEquiv` (`ScalingMap.commute_iff`,
  `ScalingMap.commute_iff_fixes_fixedPoint`), where the fixed point of a scaling
  map with `expo ≠ 1` is the positive real `exp (log coeff / (1 − expo))`.
-/

noncomputable section

namespace EMLScalingGroup

/-! ## 1.  The commutation identity in the affine group -/

/-- **The commutation criterion.**  Two affine maps commute exactly when the
bilinear expression `trans · (lin − 1)` is symmetric in them.  The linear parts
always commute, so all the information sits in the translation parts. -/
theorem AffMap.commute_iff (f g : AffMap) :
    f * g = g * f ↔ g.trans * (f.lin - 1) = f.trans * (g.lin - 1) := by
  constructor
  · intro h
    have ht := congrArg AffMap.trans h
    simp only [AffMap.mul_trans] at ht
    linarith [ht]
  · intro h
    refine AffMap.ext' ?_ ?_
    · simp [mul_comm]
    · simp only [AffMap.mul_trans]
      nlinarith [h]

/-- The fixed point of an affine map whose linear part is not `1`. -/
def AffMap.fixedPoint (f : AffMap) : ℝ := f.trans / (1 - f.lin)

/-- It really is fixed. -/
theorem AffMap.act_fixedPoint (f : AffMap) (hf : f.lin ≠ 1) :
    f.act f.fixedPoint = f.fixedPoint := by
  have h1 : (1 : ℝ) - f.lin ≠ 0 := sub_ne_zero.mpr (Ne.symm hf)
  simp only [AffMap.act, AffMap.fixedPoint]
  field_simp
  ring

/-- It is the *only* fixed point. -/
theorem AffMap.fixedPoint_unique (f : AffMap) (hf : f.lin ≠ 1) {x : ℝ} (hx : f.act x = x) :
    x = f.fixedPoint := by
  have h1 : (1 : ℝ) - f.lin ≠ 0 := sub_ne_zero.mpr (Ne.symm hf)
  simp only [AffMap.act] at hx
  simp only [AffMap.fixedPoint]
  field_simp
  linarith [hx]

/-- **Centralizer of a map with a fixed point.**  If `f.lin ≠ 1`, the maps
commuting with `f` are exactly those fixing the fixed point of `f`: the
centralizer is the stabilizer of `x*`. -/
theorem AffMap.commute_iff_fixes_fixedPoint (f g : AffMap) (hf : f.lin ≠ 1) :
    f * g = g * f ↔ g.act f.fixedPoint = f.fixedPoint := by
  have h1 : (1 : ℝ) - f.lin ≠ 0 := sub_ne_zero.mpr (Ne.symm hf)
  rw [AffMap.commute_iff]
  constructor
  · intro h
    simp only [AffMap.act, AffMap.fixedPoint]
    field_simp
    nlinarith [h]
  · intro h
    simp only [AffMap.act, AffMap.fixedPoint] at h
    field_simp at h
    nlinarith [h]

/-- **Centralizer of a nontrivial translation.**  A translation commutes only
with translations. -/
theorem AffMap.commute_iff_of_lin_eq_one (f g : AffMap) (h1 : f.lin = 1)
    (h2 : f.trans ≠ 0) : f * g = g * f ↔ g.lin = 1 := by
  rw [AffMap.commute_iff, h1]
  constructor
  · intro h
    have : f.trans * (g.lin - 1) = 0 := by linarith [h]
    rcases mul_eq_zero.mp this with h' | h'
    · exact absurd h' h2
    · linarith [h']
  · intro h
    rw [h]
    ring

/-- **The centralizer of a non-identity affine map is abelian.**  This is the
group-level counterpart of the one-dimensionality of the centralizer of a
nonzero EML vector field. -/
theorem AffMap.centralizer_commutative (f g₁ g₂ : AffMap) (hf : f ≠ 1)
    (h₁ : f * g₁ = g₁ * f) (h₂ : f * g₂ = g₂ * f) : g₁ * g₂ = g₂ * g₁ := by
  by_cases hlin : f.lin = 1
  · have htr : f.trans ≠ 0 := by
      intro htr
      exact hf (AffMap.ext' (by simp [hlin]) (by simp [htr]))
    have k₁ : g₁.lin = 1 := (AffMap.commute_iff_of_lin_eq_one f g₁ hlin htr).mp h₁
    have k₂ : g₂.lin = 1 := (AffMap.commute_iff_of_lin_eq_one f g₂ hlin htr).mp h₂
    rw [AffMap.commute_iff, k₁, k₂]
    ring
  · have e₁ := (AffMap.commute_iff_fixes_fixedPoint f g₁ hlin).mp h₁
    have e₂ := (AffMap.commute_iff_fixes_fixedPoint f g₂ hlin).mp h₂
    simp only [AffMap.act] at e₁ e₂
    have t₁ : g₁.trans = f.fixedPoint * (1 - g₁.lin) := by nlinarith [e₁]
    have t₂ : g₂.trans = f.fixedPoint * (1 - g₂.lin) := by nlinarith [e₂]
    rw [AffMap.commute_iff, t₁, t₂]
    ring

/-! ## 2.  Transport along the exp–log isomorphism -/

@[simp] theorem expLogEquiv_symm_lin (d : ScalingMap) :
    (expLogEquiv.symm d).lin = d.expo := rfl

@[simp] theorem expLogEquiv_symm_trans (d : ScalingMap) :
    (expLogEquiv.symm d).trans = Real.log d.coeff := rfl

/-- Commutation in the scaling group is detected in the affine group. -/
theorem ScalingMap.commute_iff_affine (d e : ScalingMap) :
    d * e = e * d ↔ expLogEquiv.symm d * expLogEquiv.symm e
      = expLogEquiv.symm e * expLogEquiv.symm d := by
  rw [← map_mul, ← map_mul]
  exact ⟨fun h => by rw [h], fun h => expLogEquiv.symm.injective h⟩

/-- **The commutation criterion for scaling maps.**  `y ↦ c y ^ k` and
`y ↦ c' y ^ k'` commute exactly when `log c' (k − 1) = log c (k' − 1)`. -/
theorem ScalingMap.commute_iff (d e : ScalingMap) :
    d * e = e * d ↔
      Real.log e.coeff * (d.expo - 1) = Real.log d.coeff * (e.expo - 1) := by
  rw [ScalingMap.commute_iff_affine, AffMap.commute_iff]
  simp

/-- The fixed point in `(0, ∞)` of a scaling map whose exponent is not `1`. -/
def ScalingMap.fixedPoint (d : ScalingMap) : ℝ :=
  Real.exp (Real.log d.coeff / (1 - d.expo))

theorem ScalingMap.fixedPoint_pos (d : ScalingMap) : 0 < d.fixedPoint := Real.exp_pos _

theorem ScalingMap.act_fixedPoint (d : ScalingMap) (hd : d.expo ≠ 1) :
    d.act d.fixedPoint = d.fixedPoint := by
  have hf : (expLogEquiv.symm d).lin ≠ 1 := hd
  have hrec : expLogEquiv (expLogEquiv.symm d) = d := expLogEquiv.apply_symm_apply d
  have hact := expLogEquiv_act (expLogEquiv.symm d) (y := d.fixedPoint) (Real.exp_pos _)
  rw [hrec] at hact
  rw [hact]
  have hlog : Real.log d.fixedPoint = (expLogEquiv.symm d).fixedPoint := by
    simp [ScalingMap.fixedPoint, AffMap.fixedPoint]
  rw [hlog, AffMap.act_fixedPoint _ hf]
  simp [ScalingMap.fixedPoint, AffMap.fixedPoint]

/-- **Centralizer of a scaling map with a fixed point.**  For `d.expo ≠ 1` the
maps commuting with `d` are exactly those fixing the fixed point of `d`. -/
theorem ScalingMap.commute_iff_fixes_fixedPoint (d e : ScalingMap) (hd : d.expo ≠ 1) :
    d * e = e * d ↔ e.act d.fixedPoint = d.fixedPoint := by
  have hf : (expLogEquiv.symm d).lin ≠ 1 := hd
  have hrec : expLogEquiv (expLogEquiv.symm e) = e := expLogEquiv.apply_symm_apply e
  have hlog : Real.log d.fixedPoint = (expLogEquiv.symm d).fixedPoint := by
    simp [ScalingMap.fixedPoint, AffMap.fixedPoint]
  rw [ScalingMap.commute_iff_affine,
    AffMap.commute_iff_fixes_fixedPoint _ _ hf]
  have hact := expLogEquiv_act (expLogEquiv.symm e) (y := d.fixedPoint) (Real.exp_pos _)
  rw [hrec] at hact
  constructor
  · intro h
    rw [hact, hlog, h]
    simp [ScalingMap.fixedPoint, AffMap.fixedPoint]
  · intro h
    rw [hact] at h
    rw [hlog] at h
    have hlogh := congrArg Real.log h
    rw [Real.log_exp] at hlogh
    rw [hlogh]
    exact hlog

/-- **The centralizer of a non-identity scaling map is abelian.**  Transported
from the affine picture; it is the global counterpart of the fact that the
centralizer of a nonzero EML vector field is one-dimensional. -/
theorem ScalingMap.centralizer_commutative (d e₁ e₂ : ScalingMap) (hd : d ≠ 1)
    (h₁ : d * e₁ = e₁ * d) (h₂ : d * e₂ = e₂ * d) : e₁ * e₂ = e₂ * e₁ := by
  have hd' : expLogEquiv.symm d ≠ 1 := by
    intro hcon
    exact hd (by
      have := congrArg expLogEquiv hcon
      rwa [expLogEquiv.apply_symm_apply, map_one] at this)
  have k₁ := (ScalingMap.commute_iff_affine d e₁).mp h₁
  have k₂ := (ScalingMap.commute_iff_affine d e₂).mp h₂
  exact (ScalingMap.commute_iff_affine e₁ e₂).mpr
    (AffMap.centralizer_commutative _ _ _ hd' k₁ k₂)

/-- **The centralizer contains elements of negative exponent.**  The inversion
`y ↦ 1 / y` commutes with `y ↦ y ^ 2`.  Every element in the image of the
exponential map of the EML algebra has *positive* exponent
(`EMLExpLogDuality.emlExpMap_expo_pos`), so the centralizer of an element with a
fixed point is strictly larger than the one-parameter subgroup through it: it is
the full stabilizer of the fixed point. -/
theorem ScalingMap.centralizer_has_negative_expo_element :
    ∃ d e : ScalingMap, d.expo ≠ 1 ∧ e.expo < 0 ∧ d * e = e * d := by
  refine ⟨⟨1, 2, one_pos, two_ne_zero⟩, ⟨1, -1, one_pos, by norm_num⟩, by norm_num,
    by norm_num, ?_⟩
  rw [ScalingMap.commute_iff]
  simp

end EMLScalingGroup