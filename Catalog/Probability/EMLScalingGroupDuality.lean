import Mathlib

/-!
# The scaling group side of the EML exp–log duality

The companion file `EMLExpLogDuality.lean` establishes the *infinitesimal*
statement: the EML generator algebra is the Lie algebra `𝔞𝔣𝔣(1)` of the group of
continuous scaling transformations of the positive half line.  This file proves
the corresponding *global* statement, and connects it to the catalog operation
`eml x y = exp x - log y`.

## Main results

* `EMLScalingGroup.ScalingMap` : the group of continuous scaling
  transformations `y ↦ c * y ^ k` of `(0, ∞)` (`c > 0`, `k ≠ 0`), with an
  explicit `Group` instance.
* `EMLScalingGroup.AffMap` : the affine group `x ↦ k * x + b` of `ℝ`, with an
  explicit `Group` instance.
* `EMLScalingGroup.expLogEquiv : AffMap ≃* ScalingMap` : the exp–log
  isomorphism, together with `expLogEquiv_act` showing that it is precisely
  conjugation of the affine action by `exp`.
* `EMLScalingGroup.scalingMap_not_commutative` : the scaling group is not
  abelian, matching `⁅D, T⁆ = T` on the Lie algebra side.
* `EMLScalingGroup.emlValueHom` : for each fixed exponential slot `x`, the
  scaling group acts on the *EML values* `eml x y = exp x - log y` through an
  explicit group homomorphism into the affine group, and
  `EMLScalingGroup.eml_scaling_act` says that this action is intertwined by
  `y ↦ eml x y`.  Pure scalings (`k = 1`) act by pure translations of the EML
  value (`eml_scaling_translates`), which is the global shadow of the relation
  `⁅D, T⁆ = T`.

The definition `eml` is the catalog operation of
`Catalog/Shared/AbstractAlgebra/Eml.lean`, restated here because catalog
modules are standalone.
-/

noncomputable section

namespace EMLScalingGroup

/-! ## The group of continuous scaling transformations -/

/-- A continuous scaling transformation `y ↦ c * y ^ k` of the positive half
line, with `c > 0` and `k ≠ 0`. -/
structure ScalingMap where
  /-- The multiplicative prefactor. -/
  coeff : ℝ
  /-- The power. -/
  expo : ℝ
  coeff_pos : 0 < coeff
  expo_ne : expo ≠ 0

namespace ScalingMap

theorem ext' {d e : ScalingMap} (h1 : d.coeff = e.coeff) (h2 : d.expo = e.expo) : d = e := by
  cases d; cases e; simp_all

/-- The action of a scaling transformation on the positive half line. -/
def act (d : ScalingMap) (y : ℝ) : ℝ := d.coeff * y ^ d.expo

theorem act_pos (d : ScalingMap) {y : ℝ} (hy : 0 < y) : 0 < d.act y :=
  mul_pos d.coeff_pos (Real.rpow_pos_of_pos hy _)

instance : One ScalingMap := ⟨⟨1, 1, one_pos, one_ne_zero⟩⟩

instance : Mul ScalingMap :=
  ⟨fun d e => ⟨d.coeff * e.coeff ^ d.expo, d.expo * e.expo,
      mul_pos d.coeff_pos (Real.rpow_pos_of_pos e.coeff_pos _),
      mul_ne_zero d.expo_ne e.expo_ne⟩⟩

instance : Inv ScalingMap :=
  ⟨fun d => ⟨d.coeff ^ (-d.expo⁻¹), d.expo⁻¹, Real.rpow_pos_of_pos d.coeff_pos _,
      inv_ne_zero d.expo_ne⟩⟩

@[simp] lemma one_coeff : (1 : ScalingMap).coeff = 1 := rfl
@[simp] lemma one_expo : (1 : ScalingMap).expo = 1 := rfl
@[simp] lemma mul_coeff (d e : ScalingMap) :
    (d * e).coeff = d.coeff * e.coeff ^ d.expo := rfl
@[simp] lemma mul_expo (d e : ScalingMap) : (d * e).expo = d.expo * e.expo := rfl
@[simp] lemma inv_coeff (d : ScalingMap) : d⁻¹.coeff = d.coeff ^ (-d.expo⁻¹) := rfl
@[simp] lemma inv_expo (d : ScalingMap) : d⁻¹.expo = d.expo⁻¹ := rfl

/-- Multiplication is composition of the corresponding maps. -/
theorem act_mul (d e : ScalingMap) {y : ℝ} (hy : 0 < y) :
    (d * e).act y = d.act (e.act y) := by
  have hyk : (y ^ e.expo) ^ d.expo = y ^ (d.expo * e.expo) := by
    rw [← Real.rpow_mul hy.le, mul_comm]
  simp only [act, mul_coeff, mul_expo]
  rw [Real.mul_rpow e.coeff_pos.le (Real.rpow_pos_of_pos hy _).le, hyk, mul_assoc]

instance : Group ScalingMap where
  mul_assoc d e f := by
    refine ext' ?_ ?_
    · have h1 : (e.coeff * f.coeff ^ e.expo) ^ d.expo
          = e.coeff ^ d.expo * f.coeff ^ (d.expo * e.expo) := by
        rw [Real.mul_rpow e.coeff_pos.le (Real.rpow_pos_of_pos f.coeff_pos _).le,
          ← Real.rpow_mul f.coeff_pos.le, mul_comm e.expo d.expo]
      simp only [mul_coeff, mul_expo, h1, mul_assoc]
    · simp [mul_assoc]
  one_mul d := ext' (by simp) (by simp)
  mul_one d := ext' (by simp) (by simp)
  inv_mul_cancel d := by
    refine ext' ?_ ?_
    · simp only [mul_coeff, inv_coeff, inv_expo, one_coeff]
      rw [← Real.rpow_add d.coeff_pos]
      simp
    · simp [inv_mul_cancel₀ d.expo_ne]

/-- The action is faithful. -/
theorem act_injective {d e : ScalingMap} (h : ∀ y : ℝ, 0 < y → d.act y = e.act y) : d = e := by
  have h1 := h 1 one_pos
  simp only [act, Real.one_rpow, mul_one] at h1
  have h2 := h (Real.exp 1) (Real.exp_pos 1)
  simp only [act, h1] at h2
  have hpow : (Real.exp 1) ^ d.expo = (Real.exp 1) ^ e.expo :=
    mul_left_cancel₀ (h1 ▸ e.coeff_pos.ne') h2
  rw [Real.rpow_def_of_pos (Real.exp_pos 1), Real.rpow_def_of_pos (Real.exp_pos 1),
    Real.log_exp] at hpow
  have := Real.exp_injective hpow
  exact ext' h1 (by linarith [this])

end ScalingMap

/-! ## The affine group -/

/-- An invertible affine transformation `x ↦ k * x + b` of `ℝ`. -/
structure AffMap where
  /-- The linear part. -/
  lin : ℝ
  /-- The translation part. -/
  trans : ℝ
  lin_ne : lin ≠ 0

namespace AffMap

theorem ext' {f g : AffMap} (h1 : f.lin = g.lin) (h2 : f.trans = g.trans) : f = g := by
  cases f; cases g; simp_all

/-- The affine action on `ℝ`. -/
def act (f : AffMap) (x : ℝ) : ℝ := f.lin * x + f.trans

instance : One AffMap := ⟨⟨1, 0, one_ne_zero⟩⟩

instance : Mul AffMap :=
  ⟨fun f g => ⟨f.lin * g.lin, f.lin * g.trans + f.trans, mul_ne_zero f.lin_ne g.lin_ne⟩⟩

instance : Inv AffMap := ⟨fun f => ⟨f.lin⁻¹, -(f.trans / f.lin), inv_ne_zero f.lin_ne⟩⟩

@[simp] lemma one_lin : (1 : AffMap).lin = 1 := rfl
@[simp] lemma one_trans : (1 : AffMap).trans = 0 := rfl
@[simp] lemma mul_lin (f g : AffMap) : (f * g).lin = f.lin * g.lin := rfl
@[simp] lemma mul_trans (f g : AffMap) : (f * g).trans = f.lin * g.trans + f.trans := rfl
@[simp] lemma inv_lin (f : AffMap) : f⁻¹.lin = f.lin⁻¹ := rfl
@[simp] lemma inv_trans (f : AffMap) : f⁻¹.trans = -(f.trans / f.lin) := rfl

theorem act_mul (f g : AffMap) (x : ℝ) : (f * g).act x = f.act (g.act x) := by
  simp [act]; ring

instance : Group AffMap where
  mul_assoc f g h := ext' (by simp [mul_assoc]) (by simp; ring)
  one_mul f := ext' (by simp) (by simp)
  mul_one f := ext' (by simp) (by simp)
  inv_mul_cancel f := ext' (by simp [inv_mul_cancel₀ f.lin_ne]) (by simp [div_eq_inv_mul])

end AffMap

/-! ## The global exp–log isomorphism -/

/-- **The exp–log group isomorphism.**  Conjugating an affine transformation of
`ℝ` by `exp` produces a continuous scaling transformation of `(0, ∞)`, and this
correspondence is a group isomorphism. -/
def expLogEquiv : AffMap ≃* ScalingMap where
  toFun f := ⟨Real.exp f.trans, f.lin, Real.exp_pos _, f.lin_ne⟩
  invFun d := ⟨d.expo, Real.log d.coeff, d.expo_ne⟩
  left_inv f := AffMap.ext' rfl (by simp [Real.log_exp])
  right_inv d := ScalingMap.ext' (by simp [Real.exp_log d.coeff_pos]) rfl
  map_mul' f g := by
    refine ScalingMap.ext' ?_ rfl
    simp only [ScalingMap.mul_coeff, AffMap.mul_trans, Real.exp_add]
    rw [Real.rpow_def_of_pos (Real.exp_pos _), Real.log_exp, mul_comm f.lin g.trans]
    ring_nf

@[simp] theorem expLogEquiv_coeff (f : AffMap) : (expLogEquiv f).coeff = Real.exp f.trans := rfl
@[simp] theorem expLogEquiv_expo (f : AffMap) : (expLogEquiv f).expo = f.lin := rfl

/-- The isomorphism is exactly conjugation of the affine action by `exp`. -/
theorem expLogEquiv_act (f : AffMap) {y : ℝ} (hy : 0 < y) :
    (expLogEquiv f).act y = Real.exp (f.act (Real.log y)) := by
  simp only [ScalingMap.act, expLogEquiv_coeff, expLogEquiv_expo, AffMap.act,
    Real.rpow_def_of_pos hy, ← Real.exp_add]
  ring_nf

/-- Equivalently: `log` conjugates the scaling action back to the affine
action. -/
theorem log_scaling_act (f : AffMap) {y : ℝ} (hy : 0 < y) :
    Real.log ((expLogEquiv f).act y) = f.act (Real.log y) := by
  rw [expLogEquiv_act f hy, Real.log_exp]

/-- The scaling group is not abelian: squaring and doubling do not commute.
This is the global counterpart of `⁅D, T⁆ = T`. -/
theorem scalingMap_not_commutative :
    ∃ d e : ScalingMap, d * e ≠ e * d := by
  refine ⟨⟨1, 2, one_pos, two_ne_zero⟩, ⟨2, 1, two_pos, one_ne_zero⟩, ?_⟩
  intro h
  have := congrArg ScalingMap.coeff h
  simp only [ScalingMap.mul_coeff] at this
  rw [Real.rpow_two, Real.rpow_one] at this
  norm_num at this

/-! ## Action on EML values

`eml` is the catalog exp-minus-log operation. -/

/-- The EML ("exp minus log") binary operation `eml x y = exp x - log y`. -/
def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- A pure scaling `y ↦ c * y` translates the EML value by `-log c`. -/
theorem eml_scaling_translates (x c y : ℝ) (hc : 0 < c) (hy : 0 < y) :
    eml x (c * y) = eml x y - Real.log c := by
  simp only [eml, Real.log_mul hc.ne' hy.ne']
  ring

/-- A general scaling transformation acts *affinely* on EML values. -/
theorem eml_scaling_affine (x : ℝ) (d : ScalingMap) {y : ℝ} (hy : 0 < y) :
    eml x (d.act y) = d.expo * eml x y + (1 - d.expo) * Real.exp x - Real.log d.coeff := by
  simp only [eml, ScalingMap.act,
    Real.log_mul d.coeff_pos.ne' (Real.rpow_pos_of_pos hy _).ne',
    Real.log_rpow hy]
  ring

/-- **The EML value representation.**  For a fixed exponential slot `x`, the
scaling group acts on the line of EML values through this explicit group
homomorphism into the affine group. -/
def emlValueHom (x : ℝ) : ScalingMap →* AffMap where
  toFun d := ⟨d.expo, (1 - d.expo) * Real.exp x - Real.log d.coeff, d.expo_ne⟩
  map_one' := AffMap.ext' (by simp) (by simp)
  map_mul' d e := by
    refine AffMap.ext' (by simp) ?_
    have hlog : Real.log (d.coeff * e.coeff ^ d.expo)
        = Real.log d.coeff + d.expo * Real.log e.coeff := by
      rw [Real.log_mul d.coeff_pos.ne' (Real.rpow_pos_of_pos e.coeff_pos _).ne',
        Real.log_rpow e.coeff_pos]
    simp only [AffMap.mul_trans, ScalingMap.mul_expo, ScalingMap.mul_coeff, hlog]
    ring

@[simp] theorem emlValueHom_lin (x : ℝ) (d : ScalingMap) : (emlValueHom x d).lin = d.expo := rfl

/-- **Intertwining property.**  The map `y ↦ eml x y` intertwines the scaling
action on states with the affine action on EML values. -/
theorem eml_scaling_act (x : ℝ) (d : ScalingMap) {y : ℝ} (hy : 0 < y) :
    eml x (d.act y) = (emlValueHom x d).act (eml x y) := by
  rw [eml_scaling_affine x d hy]
  simp only [AffMap.act, emlValueHom, MonoidHom.coe_mk, OneHom.coe_mk]
  ring

/-- Composed with the exp–log isomorphism, the EML value representation is a
homomorphism of the affine group into itself; on the derived subgroup of pure
translations `k = 1` it is the identity up to the shift `-log c`, so pure
scalings act on EML values by pure translations. -/
theorem emlValueHom_translation (x : ℝ) (d : ScalingMap) (hd : d.expo = 1) :
    emlValueHom x d = ⟨1, -Real.log d.coeff, one_ne_zero⟩ := by
  refine AffMap.ext' (by simp [hd]) ?_
  simp only [emlValueHom, MonoidHom.coe_mk, OneHom.coe_mk, hd]
  ring

/-- The EML value representation is faithful for every fixed `x`. -/
theorem emlValueHom_injective (x : ℝ) : Function.Injective (emlValueHom x) := by
  intro d e h
  have hl := congrArg AffMap.lin h
  have ht := congrArg AffMap.trans h
  simp only [emlValueHom_lin] at hl
  simp only [emlValueHom, MonoidHom.coe_mk, OneHom.coe_mk, hl] at ht
  have hlog : Real.log d.coeff = Real.log e.coeff := by linarith
  refine ScalingMap.ext' ?_ hl
  have := congrArg Real.exp hlog
  rwa [Real.exp_log d.coeff_pos, Real.exp_log e.coeff_pos] at this


/-! ## Rigidity of the scaling group

Two global counterparts of the Lie algebra structure theory: the centre is
trivial (matching `center_trivial` for `EMLGen`), yet — unlike a nilpotent or
simply connected group — the scaling group has torsion, namely the inversions
`y ↦ c / y`.  These are exactly the elements *outside* the image of the
exponential map.
-/

/-- **The centre of the scaling group is trivial.** -/
theorem ScalingMap.center_trivial (d : ScalingMap) (h : ∀ e : ScalingMap, d * e = e * d) :
    d = 1 := by
  have hsq := congrArg ScalingMap.coeff (h ⟨1, 2, one_pos, two_ne_zero⟩)
  simp only [ScalingMap.mul_coeff, Real.one_rpow, mul_one, Real.rpow_two] at hsq
  have hc : d.coeff = 1 := by
    have hpos := d.coeff_pos
    nlinarith [hsq, hpos]
  have hdb := congrArg ScalingMap.coeff (h ⟨2, 1, two_pos, one_ne_zero⟩)
  simp only [ScalingMap.mul_coeff, Real.rpow_one, hc, one_mul, mul_one] at hdb
  have hk : d.expo = 1 := by
    have h2 := congrArg Real.log hdb
    rw [Real.log_rpow two_pos] at h2
    have hlog2 : Real.log 2 ≠ 0 := Real.log_ne_zero_of_pos_of_ne_one two_pos (by norm_num)
    exact mul_right_cancel₀ hlog2 (h2.trans (one_mul _).symm)
  exact ScalingMap.ext' hc hk

/-- The involutions of the scaling group are exactly the inversions
`y ↦ c / y`. -/
theorem ScalingMap.sq_eq_one_iff (d : ScalingMap) :
    d * d = 1 ↔ d = 1 ∨ d.expo = -1 := by
  constructor
  · intro h
    have hk := congrArg ScalingMap.expo h
    have hc := congrArg ScalingMap.coeff h
    simp only [ScalingMap.mul_expo, ScalingMap.one_expo] at hk
    simp only [ScalingMap.mul_coeff, ScalingMap.one_coeff] at hc
    have : d.expo = 1 ∨ d.expo = -1 := by
      rcases mul_self_eq_one_iff.mp hk with h' | h'
      · exact Or.inl h'
      · exact Or.inr h'
    rcases this with h' | h'
    · left
      rw [h', Real.rpow_one] at hc
      have : d.coeff = 1 := by nlinarith [d.coeff_pos]
      exact ScalingMap.ext' this h'
    · exact Or.inr h'
  · rintro (h | h)
    · rw [h, one_mul]
    · refine ScalingMap.ext' ?_ ?_
      · simp only [ScalingMap.mul_coeff, ScalingMap.one_coeff, h]
        rw [Real.rpow_neg_one, mul_inv_cancel₀ d.coeff_pos.ne']
      · simp [h]

/-- An inversion acts by `y ↦ c / y`. -/
theorem ScalingMap.act_of_expo_neg_one (d : ScalingMap) (h : d.expo = -1) (y : ℝ) :
    d.act y = d.coeff / y := by
  rw [ScalingMap.act, h, Real.rpow_neg_one, div_eq_mul_inv]

/-! ## The EML state space is a torsor over the scaling group -/

/-- The affine group acts simply transitively on ordered pairs of distinct
reals. -/
theorem AffMap.existsUnique_of_pair {u₁ u₂ v₁ v₂ : ℝ} (hu : u₁ ≠ u₂) (hv : v₁ ≠ v₂) :
    ∃! f : AffMap, f.act u₁ = v₁ ∧ f.act u₂ = v₂ := by
  have hu' : u₁ - u₂ ≠ 0 := sub_ne_zero.mpr hu
  have hv' : v₁ - v₂ ≠ 0 := sub_ne_zero.mpr hv
  refine ⟨⟨(v₁ - v₂) / (u₁ - u₂), v₁ - (v₁ - v₂) / (u₁ - u₂) * u₁,
    div_ne_zero hv' hu'⟩, ⟨?_, ?_⟩, ?_⟩
  · simp [AffMap.act]
  · simp only [AffMap.act]
    field_simp
    ring
  · rintro g ⟨h1, h2⟩
    simp only [AffMap.act] at h1 h2
    have hlin : g.lin = (v₁ - v₂) / (u₁ - u₂) := by
      have hsub : g.lin * (u₁ - u₂) = v₁ - v₂ := by linarith [h1, h2, mul_sub g.lin u₁ u₂]
      field_simp at hsub ⊢
      linarith [hsub]
    refine AffMap.ext' hlin ?_
    simp only [← hlin]
    linarith [h1]

/-- **Simple transitivity.**  For any two ordered pairs of distinct points of
the positive half line there is exactly one continuous scaling transformation
carrying the first pair to the second: the EML state space is a torsor over the
scaling group. -/
theorem ScalingMap.existsUnique_of_pair {y₁ y₂ z₁ z₂ : ℝ} (hy₁ : 0 < y₁) (hy₂ : 0 < y₂)
    (hz₁ : 0 < z₁) (hz₂ : 0 < z₂) (hy : y₁ ≠ y₂) (hz : z₁ ≠ z₂) :
    ∃! d : ScalingMap, d.act y₁ = z₁ ∧ d.act y₂ = z₂ := by
  have hlogy : Real.log y₁ ≠ Real.log y₂ := by
    intro h
    exact hy (by rw [← Real.exp_log hy₁, ← Real.exp_log hy₂, h])
  have hlogz : Real.log z₁ ≠ Real.log z₂ := by
    intro h
    exact hz (by rw [← Real.exp_log hz₁, ← Real.exp_log hz₂, h])
  obtain ⟨f₀, ⟨hf₁, hf₂⟩, hfuniq⟩ := AffMap.existsUnique_of_pair hlogy hlogz
  refine ⟨expLogEquiv f₀, ⟨?_, ?_⟩, ?_⟩
  · rw [expLogEquiv_act f₀ hy₁, hf₁, Real.exp_log hz₁]
  · rw [expLogEquiv_act f₀ hy₂, hf₂, Real.exp_log hz₂]
  · rintro d ⟨hd₁, hd₂⟩
    have hd : d = expLogEquiv (expLogEquiv.symm d) := (expLogEquiv.apply_symm_apply d).symm
    have e₁ : (expLogEquiv.symm d).act (Real.log y₁) = Real.log z₁ := by
      rw [← log_scaling_act _ hy₁, ← hd, hd₁]
    have e₂ : (expLogEquiv.symm d).act (Real.log y₂) = Real.log z₂ := by
      rw [← log_scaling_act _ hy₂, ← hd, hd₂]
    rw [hd, hfuniq _ ⟨e₁, e₂⟩]

/-! ## Probabilistic shadow: the action on cumulant generating functions

If `Y` is a positive random variable with finitely many values `y i` and weights
`p i`, its *cumulant generating function of `log Y`* is
`K(s) = log 𝔼[Y ^ s] = log ∑ᵢ p i * y i ^ s`.  A scaling transformation of the
state `Y ↦ c Y ^ k` acts on `K` by the affine substitution
`K ↦ (s ↦ s log c + K (k s))`, and this substitution is a genuine action of the
scaling group on the space of functions `ℝ → ℝ`.  So the EML scaling group acts
on log-Laplace transforms exactly as it acts on states.
-/

variable {ι : Type*} [Fintype ι]

/-- The cumulant generating function `K(s) = log ∑ᵢ p i * (y i) ^ s` of a finite
positive random variable. -/
def discreteCGF (p y : ι → ℝ) (s : ℝ) : ℝ := Real.log (∑ i, p i * y i ^ s)

/-- The induced action of a scaling transformation on cumulant generating
functions. -/
def cgfAction (d : ScalingMap) (K : ℝ → ℝ) : ℝ → ℝ :=
  fun s => s * Real.log d.coeff + K (d.expo * s)

/-- The action on cumulant generating functions is a group action. -/
theorem cgfAction_mul (d e : ScalingMap) (K : ℝ → ℝ) :
    cgfAction (d * e) K = cgfAction d (cgfAction e K) := by
  funext s
  simp only [cgfAction, ScalingMap.mul_coeff, ScalingMap.mul_expo,
    Real.log_mul d.coeff_pos.ne' (Real.rpow_pos_of_pos e.coeff_pos _).ne',
    Real.log_rpow e.coeff_pos]
  ring_nf

@[simp] theorem cgfAction_one (K : ℝ → ℝ) : cgfAction 1 K = K := by
  funext s
  simp [cgfAction]

/-- **The cumulant generating function intertwines the two actions.**  Scaling
the state `y ↦ c * y ^ k` transforms the CGF by `K ↦ (s ↦ s log c + K (k s))`. -/
theorem discreteCGF_scaling (p y : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hpos : ∃ i, 0 < p i)
    (hy : ∀ i, 0 < y i) (d : ScalingMap) :
    discreteCGF p (fun i => d.act (y i)) = cgfAction d (discreteCGF p y) := by
  funext s
  have hsum : 0 < ∑ i, p i * y i ^ (d.expo * s) := by
    obtain ⟨i₀, hi₀⟩ := hpos
    refine Finset.sum_pos' (fun i _ => mul_nonneg (hp i) (Real.rpow_pos_of_pos (hy i) _).le)
      ⟨i₀, Finset.mem_univ i₀, mul_pos hi₀ (Real.rpow_pos_of_pos (hy i₀) _)⟩
  have hterm : ∀ i : ι, p i * (d.act (y i)) ^ s
      = d.coeff ^ s * (p i * y i ^ (d.expo * s)) := by
    intro i
    rw [ScalingMap.act, Real.mul_rpow d.coeff_pos.le (Real.rpow_pos_of_pos (hy i) _).le,
      ← Real.rpow_mul (hy i).le]
    ring
  simp only [discreteCGF, cgfAction, hterm, ← Finset.mul_sum]
  rw [Real.log_mul (Real.rpow_pos_of_pos d.coeff_pos s).ne' hsum.ne',
    Real.log_rpow d.coeff_pos]

end EMLScalingGroup