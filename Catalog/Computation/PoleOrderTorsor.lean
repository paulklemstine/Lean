import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep

/-!
# The corrected-product torsor of normalized `q`-series

`Shared.PoleOrderObstruction` established the *pole-order obstruction*: a product of `m`
normalized Laurent series `f = q⁻¹ + a₀ + a₁ q + ⋯` has `orderTop = -m`, so normalized series
are **not** closed under multiplication, and the unique repair is to multiply by `q^{m-1}`.

This file takes the repaired operation seriously.  For two normalized series we set

`f ⋆ g := q · f · g`

(the *corrected product*).  The first result is the closure property
`PoleOrderTorsor.isNormalized_q_mul_mul`: `f ⋆ g` is again normalized.  Everything else in this
file is the structure theory this closure unlocks:

* `PoleOrderTorsor.isNormalized_iff` — a Laurent series is normalized **iff** it is
  `q⁻¹ · u` for a power series `u` with constant term `1`.  This is the coordinate system in
  which the corrected product becomes ordinary multiplication of power series.
* `PoleOrderTorsor.Norm` — the type of normalized series, equipped with a genuine
  `CommGroup` structure whose multiplication is `⋆`, whose unit is `q⁻¹`, and whose inverse is
  `f ↦ q⁻² · f⁻¹`.  So the normalized series are a *torsor*-like object: a group once the
  base point `q⁻¹` is chosen.
* `PoleOrderTorsor.normEquivOneUnit` — a multiplicative **isomorphism** between that group and
  the group `1 + X·ℂ⟦X⟧` of one-units of the formal power series ring.  This identifies the
  corrected-product structure completely.
* `PoleOrderTorsor.leadCoeffHom` — the *first invariant*: `f ↦ a₀(f) = f.coeff 0` is a group
  homomorphism `Norm →* Multiplicative ℂ`, surjective, with the explicit iteration formula
  `a₀(f^{⋆n}) = n · a₀(f)` (`PoleOrderTorsor.coeff_zero_npow`).

The Laurent-series-level shape of an iterate is recorded in
`PoleOrderTorsor.val_pow`: `f^{⋆n} = q^{n-1} · fⁿ`, which is exactly the `q^{m-1}`-correction of
the pole-order obstruction applied `n-1` times.
-/

namespace PoleOrderTorsor

open HahnSeries PoleOrderObstruction

/-- Laurent series over `ℂ`, as in `Shared.PoleOrderObstruction`. -/
abbrev LC := PoleOrderObstruction.LC

/-- The base point `q⁻¹` of the corrected-product structure. -/
noncomputable def qInv : LC := HahnSeries.single (-1 : ℤ) (1 : ℂ)

/-- The **corrected product** `f ⋆ g = q · f · g`. -/
noncomputable def cmul (f g : LC) : LC := qSeries * (f * g)

@[inherit_doc] scoped infixl:70 " ⋆ " => cmul

/-! ## Coordinates: normalized series are `q⁻¹` times a one-unit -/

theorem qSeries_mul_qInv : qSeries * qInv = 1 := by
  rw [qSeries, qInv, HahnSeries.single_mul_single, add_neg_cancel, mul_one, single_zero_one]

theorem qInv_mul_qSeries : qInv * qSeries = 1 := by
  rw [mul_comm]; exact qSeries_mul_qInv

/-- Any `q⁻¹ · u` with `u` a one-unit power series is normalized. -/
theorem isNormalized_qInv_mul {u : PowerSeries ℂ} (hu : PowerSeries.constantCoeff u = 1) :
    IsNormalized (qInv * HahnSeries.ofPowerSeries ℤ ℂ u) := by
  have key : ∀ n : ℤ, (qInv * HahnSeries.ofPowerSeries ℤ ℂ u).coeff n
      = (HahnSeries.ofPowerSeries ℤ ℂ u).coeff (n + 1) := by
    intro n
    rw [qInv, HahnSeries.coeff_single_mul, one_mul, sub_neg_eq_add]
  constructor
  · rw [key, show ((-1 : ℤ) + 1) = ((0 : ℕ) : ℤ) by norm_num,
      HahnSeries.ofPowerSeries_apply_coeff]
    simpa using hu
  · intro n hn
    rw [key]
    rw [show (HahnSeries.ofPowerSeries ℤ ℂ) u = ((u : PowerSeries ℂ) : LC) from rfl,
      PowerSeries.coeff_coe, if_pos (by omega)]

/-- **Coordinates for normalized series.**  `f` is normalized precisely when it is `q⁻¹` times
a power series with constant term `1`. -/
theorem isNormalized_iff (f : LC) :
    IsNormalized f ↔ ∃ u : PowerSeries ℂ, PowerSeries.constantCoeff u = 1 ∧
      f = qInv * HahnSeries.ofPowerSeries ℤ ℂ u := by
  constructor
  · intro h
    obtain ⟨u, ⟨hu, hfu⟩, -⟩ := exists_unique_unit_factorization h
    exact ⟨u, hu, hfu⟩
  · rintro ⟨u, hu, rfl⟩
    exact isNormalized_qInv_mul hu

/-- The base point `q⁻¹` is normalized. -/
theorem isNormalized_qInv : IsNormalized qInv := by
  refine (isNormalized_iff _).2 ⟨1, by simp, ?_⟩
  simp

/-! ## Closure of the corrected product -/

/-- **Closure property of the corrected product.**  If `f` and `g` are normalized then so is
`q · f · g`.  This is the repair of the pole-order obstruction of
`PoleOrderObstruction.prod_isNormalized_iff`, turned into an algebraic operation. -/
theorem isNormalized_q_mul_mul {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g) :
    IsNormalized (qSeries * (f * g)) := by
  obtain ⟨u, hu, rfl⟩ := (isNormalized_iff f).1 hf
  obtain ⟨v, hv, rfl⟩ := (isNormalized_iff g).1 hg
  refine (isNormalized_iff _).2 ⟨u * v, by simp [hu, hv], ?_⟩
  rw [map_mul]
  have : qSeries * (qInv * HahnSeries.ofPowerSeries ℤ ℂ u *
      (qInv * HahnSeries.ofPowerSeries ℤ ℂ v))
      = (qSeries * qInv) * (qInv *
          (HahnSeries.ofPowerSeries ℤ ℂ u * HahnSeries.ofPowerSeries ℤ ℂ v)) := by
    ring
  rw [this, qSeries_mul_qInv, one_mul]

/-- Closure, phrased with the `⋆` notation. -/
theorem isNormalized_cmul {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g) :
    IsNormalized (f ⋆ g) := isNormalized_q_mul_mul hf hg

/-- Closure under the corrected inverse `f ↦ q⁻² · f⁻¹`. -/
theorem isNormalized_cinv {f : LC} (hf : IsNormalized f) :
    IsNormalized (HahnSeries.single (-2 : ℤ) (1 : ℂ) * f⁻¹) := by
  obtain ⟨u, hu, rfl⟩ := (isNormalized_iff f).1 hf
  have hu0 : PowerSeries.constantCoeff u ≠ 0 := by rw [hu]; exact one_ne_zero
  have hinv : (qInv * HahnSeries.ofPowerSeries ℤ ℂ u)⁻¹
      = qSeries * HahnSeries.ofPowerSeries ℤ ℂ u⁻¹ := by
    refine (eq_inv_of_mul_eq_one_right ?_).symm
    have : qInv * HahnSeries.ofPowerSeries ℤ ℂ u * (qSeries * HahnSeries.ofPowerSeries ℤ ℂ u⁻¹)
        = (qSeries * qInv) * HahnSeries.ofPowerSeries ℤ ℂ (u * u⁻¹) := by
      rw [map_mul]; ring
    rw [this, qSeries_mul_qInv, PowerSeries.mul_inv_cancel u hu0, one_mul, map_one]
  refine (isNormalized_iff _).2 ⟨u⁻¹, by simp [hu], ?_⟩
  rw [hinv, ← mul_assoc, qInv, qSeries, HahnSeries.single_mul_single]
  norm_num

/-! ## The group of normalized series -/

/-- The type of normalized Laurent series. -/
def Norm : Type := {f : LC // IsNormalized f}

namespace Norm

instance : CoeOut Norm LC := ⟨Subtype.val⟩

@[ext] theorem ext {f g : Norm} (h : (f : LC) = (g : LC)) : f = g := Subtype.ext h

theorem prop (f : Norm) : IsNormalized (f : LC) := f.2

theorem val_ne_zero (f : Norm) : (f : LC) ≠ 0 := f.2.ne_zero

noncomputable instance : Mul Norm := ⟨fun f g => ⟨(f : LC) ⋆ (g : LC), isNormalized_cmul f.2 g.2⟩⟩
noncomputable instance : One Norm := ⟨⟨qInv, isNormalized_qInv⟩⟩
noncomputable instance : Inv Norm :=
  ⟨fun f => ⟨HahnSeries.single (-2 : ℤ) (1 : ℂ) * (f : LC)⁻¹, isNormalized_cinv f.2⟩⟩

@[simp] theorem val_mul (f g : Norm) : ((f * g : Norm) : LC) = qSeries * ((f : LC) * (g : LC)) :=
  rfl
@[simp] theorem val_one : ((1 : Norm) : LC) = qInv := rfl
@[simp] theorem val_inv (f : Norm) :
    ((f⁻¹ : Norm) : LC) = HahnSeries.single (-2 : ℤ) (1 : ℂ) * (f : LC)⁻¹ := rfl

/-- **The corrected product makes normalized series a commutative group**, with unit `q⁻¹`. -/
noncomputable instance : CommGroup Norm where
  mul_assoc f g h := by
    apply Norm.ext
    simp only [val_mul]
    ring
  one_mul f := by
    apply Norm.ext
    simp only [val_mul, val_one]
    rw [← mul_assoc, qSeries_mul_qInv, one_mul]
  mul_one f := by
    apply Norm.ext
    simp only [val_mul, val_one]
    rw [show qSeries * ((f : LC) * qInv) = (qSeries * qInv) * (f : LC) by ring,
      qSeries_mul_qInv, one_mul]
  inv_mul_cancel f := by
    apply Norm.ext
    simp only [val_mul, val_inv, val_one]
    rw [show qSeries * (HahnSeries.single (-2 : ℤ) (1 : ℂ) * (f : LC)⁻¹ * (f : LC))
        = (qSeries * HahnSeries.single (-2 : ℤ) (1 : ℂ)) * ((f : LC)⁻¹ * (f : LC)) by ring,
      inv_mul_cancel₀ f.val_ne_zero, mul_one, qSeries, HahnSeries.single_mul_single]
    norm_num [qInv]
  mul_comm f g := by
    apply Norm.ext
    simp only [val_mul]
    ring

end Norm

/-! ## The one-unit group of `ℂ⟦X⟧` -/

/-- Power series with constant term `1`: the one-units of `ℂ⟦X⟧`. -/
def OneUnit : Type := {u : PowerSeries ℂ // PowerSeries.constantCoeff u = 1}

namespace OneUnit

instance : CoeOut OneUnit (PowerSeries ℂ) := ⟨Subtype.val⟩

@[ext] theorem ext {u v : OneUnit} (h : (u : PowerSeries ℂ) = (v : PowerSeries ℂ)) : u = v :=
  Subtype.ext h

theorem constantCoeff_val (u : OneUnit) : PowerSeries.constantCoeff (u : PowerSeries ℂ) = 1 := u.2

theorem val_ne_zero (u : OneUnit) : (u : PowerSeries ℂ) ≠ 0 := by
  intro h
  have := u.constantCoeff_val
  rw [h] at this
  simp at this

noncomputable instance : Mul OneUnit := ⟨fun u v => ⟨(u : PowerSeries ℂ) * (v : PowerSeries ℂ), by
  simp [u.constantCoeff_val, v.constantCoeff_val]⟩⟩
noncomputable instance : One OneUnit := ⟨⟨1, by simp⟩⟩
noncomputable instance : Inv OneUnit := ⟨fun u => ⟨(u : PowerSeries ℂ)⁻¹, by
  simp [u.constantCoeff_val]⟩⟩

@[simp] theorem val_mul (u v : OneUnit) :
    ((u * v : OneUnit) : PowerSeries ℂ) = (u : PowerSeries ℂ) * (v : PowerSeries ℂ) := rfl
@[simp] theorem val_one : ((1 : OneUnit) : PowerSeries ℂ) = 1 := rfl
@[simp] theorem val_inv (u : OneUnit) :
    ((u⁻¹ : OneUnit) : PowerSeries ℂ) = ((u : PowerSeries ℂ))⁻¹ := rfl

/-- The one-units form a commutative group under multiplication of power series. -/
noncomputable instance : CommGroup OneUnit where
  mul_assoc u v w := by apply OneUnit.ext; simp [mul_assoc]
  one_mul u := by apply OneUnit.ext; simp
  mul_one u := by apply OneUnit.ext; simp
  inv_mul_cancel u := by
    apply OneUnit.ext
    simp only [val_mul, val_inv, val_one]
    exact PowerSeries.inv_mul_cancel _ (by rw [u.constantCoeff_val]; exact one_ne_zero)
  mul_comm u v := by apply OneUnit.ext; simp [mul_comm]

@[simp] theorem val_pow (u : OneUnit) (n : ℕ) :
    ((u ^ n : OneUnit) : PowerSeries ℂ) = (u : PowerSeries ℂ) ^ n := by
  induction n with
  | zero => simp
  | succ n ih => rw [pow_succ, pow_succ, val_mul, ih]

end OneUnit

/-! ## The isomorphism: corrected product = multiplication of one-units -/

/-- The one-unit attached to a normalized series: `u = q · f`. -/
noncomputable def toOneUnit (f : Norm) : OneUnit :=
  ⟨normalizedPart (f : LC), constantCoeff_normalizedPart _ f.2⟩

/-- The normalized series attached to a one-unit: `f = q⁻¹ · u`. -/
noncomputable def ofOneUnit (u : OneUnit) : Norm :=
  ⟨qInv * HahnSeries.ofPowerSeries ℤ ℂ (u : PowerSeries ℂ), isNormalized_qInv_mul u.2⟩

theorem ofPowerSeries_toOneUnit (f : Norm) :
    HahnSeries.ofPowerSeries ℤ ℂ ((toOneUnit f : PowerSeries ℂ)) = qSeries * (f : LC) :=
  ofPowerSeries_normalizedPart _ f.2

theorem ofOneUnit_toOneUnit (f : Norm) : ofOneUnit (toOneUnit f) = f := by
  apply Norm.ext
  simp only [ofOneUnit]
  rw [ofPowerSeries_toOneUnit, ← mul_assoc, qInv_mul_qSeries, one_mul]

theorem toOneUnit_ofOneUnit (u : OneUnit) : toOneUnit (ofOneUnit u) = u := by
  apply OneUnit.ext
  apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
  rw [show ((toOneUnit (ofOneUnit u) : OneUnit) : PowerSeries ℂ)
      = normalizedPart ((ofOneUnit u : Norm) : LC) from rfl,
    ofPowerSeries_normalizedPart _ (ofOneUnit u).2]
  show qSeries * (qInv * HahnSeries.ofPowerSeries ℤ ℂ (u : PowerSeries ℂ)) = _
  rw [← mul_assoc, qSeries_mul_qInv, one_mul]

theorem toOneUnit_mul (f g : Norm) : toOneUnit (f * g) = toOneUnit f * toOneUnit g := by
  apply OneUnit.ext
  apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
  rw [ofPowerSeries_toOneUnit, OneUnit.val_mul, map_mul, ofPowerSeries_toOneUnit,
    ofPowerSeries_toOneUnit, Norm.val_mul]
  ring

/-- **Structure theorem.**  The corrected-product group of normalized `q`-series is isomorphic
to the group `1 + X·ℂ⟦X⟧` of one-units of the power series ring, by `f ↦ q · f`. -/
noncomputable def normEquivOneUnit : Norm ≃* OneUnit where
  toFun := toOneUnit
  invFun := ofOneUnit
  left_inv := ofOneUnit_toOneUnit
  right_inv := toOneUnit_ofOneUnit
  map_mul' := toOneUnit_mul

@[simp] theorem normEquivOneUnit_apply (f : Norm) : normEquivOneUnit f = toOneUnit f := rfl
@[simp] theorem normEquivOneUnit_symm_apply (u : OneUnit) :
    normEquivOneUnit.symm u = ofOneUnit u := rfl

/-! ## Iterating the corrected product -/

/-- The `n`-th `⋆`-power of a normalized series is `q^{n-1} · fⁿ`: iterating the corrected
product applies the pole correction `n - 1` times. -/
theorem val_pow (f : Norm) (n : ℕ) :
    qSeries * ((f ^ n : Norm) : LC) = (qSeries * (f : LC)) ^ n := by
  induction n with
  | zero => rw [pow_zero, pow_zero, Norm.val_one, qSeries_mul_qInv]
  | succ n ih =>
      rw [pow_succ, pow_succ, Norm.val_mul, ← ih]
      ring

theorem val_pow_succ (f : Norm) (n : ℕ) :
    ((f ^ (n + 1) : Norm) : LC) = qSeries ^ n * (f : LC) ^ (n + 1) := by
  have h := val_pow f (n + 1)
  rw [mul_pow] at h
  have hq : qSeries * (qSeries ^ n * (f : LC) ^ (n + 1)) = qSeries ^ (n + 1) * (f : LC) ^ (n + 1) :=
    by ring
  refine mul_left_cancel₀ (a := qSeries) qSeries_ne_zero ?_
  rw [h, hq]

/-! ## The first invariant -/

/-- The first invariant of a normalized series: its constant Laurent coefficient `a₀`. -/
noncomputable def a₀ (f : Norm) : ℂ := (f : LC).coeff 0

/-- `a₀` linearises the corrected product: it is additive. -/
theorem a₀_mul (f g : Norm) : a₀ (f * g) = a₀ f + a₀ g := by
  have hcoe : PowerSeries.coeff 1
      ((toOneUnit f : PowerSeries ℂ) * (toOneUnit g : PowerSeries ℂ)) =
      PowerSeries.coeff 1 (toOneUnit f : PowerSeries ℂ) +
        PowerSeries.coeff 1 (toOneUnit g : PowerSeries ℂ) := by
    rw [PowerSeries.coeff_one_mul, (toOneUnit f).constantCoeff_val,
      (toOneUnit g).constantCoeff_val, mul_one, mul_one]
  have hf : PowerSeries.coeff 1 (toOneUnit f : PowerSeries ℂ) = a₀ f :=
    coeff_one_normalizedPart _ f.2
  have hg : PowerSeries.coeff 1 (toOneUnit g : PowerSeries ℂ) = a₀ g :=
    coeff_one_normalizedPart _ g.2
  have hfg : PowerSeries.coeff 1 (toOneUnit (f * g) : PowerSeries ℂ) = a₀ (f * g) :=
    coeff_one_normalizedPart _ (f * g).2
  rw [← hfg, toOneUnit_mul, OneUnit.val_mul, hcoe, hf, hg]

@[simp] theorem a₀_one : a₀ (1 : Norm) = 0 := by
  have : ((1 : Norm) : LC) = HahnSeries.single (-1 : ℤ) (1 : ℂ) := rfl
  rw [a₀, this, HahnSeries.coeff_single]
  norm_num

/-- The first invariant, as a group homomorphism to `(ℂ, +)` written multiplicatively. -/
noncomputable def leadCoeffHom : Norm →* Multiplicative ℂ where
  toFun f := Multiplicative.ofAdd (a₀ f)
  map_one' := by simp
  map_mul' f g := by
    show Multiplicative.ofAdd (a₀ (f * g)) = _
    rw [a₀_mul]
    rfl

@[simp] theorem leadCoeffHom_apply (f : Norm) :
    leadCoeffHom f = Multiplicative.ofAdd (a₀ f) := rfl

/-- **Iteration formula for the first invariant.** `a₀` of the `n`-th `⋆`-iterate is `n · a₀`. -/
theorem a₀_pow (f : Norm) (n : ℕ) : a₀ (f ^ n) = n * a₀ f := by
  induction n with
  | zero => simp
  | succ n ih => rw [pow_succ, a₀_mul, ih]; push_cast; ring

/-- In one-unit coordinates the first invariant is the linear coefficient. -/
theorem a₀_toOneUnit (f : Norm) :
    PowerSeries.coeff 1 (toOneUnit f : PowerSeries ℂ) = a₀ f :=
  coeff_one_normalizedPart _ f.2

theorem a₀_ofOneUnit (u : OneUnit) :
    a₀ (ofOneUnit u) = PowerSeries.coeff 1 (u : PowerSeries ℂ) := by
  rw [← a₀_toOneUnit, toOneUnit_ofOneUnit]

/-- Every complex number occurs as the first invariant: `leadCoeffHom` is surjective. -/
theorem leadCoeffHom_surjective : Function.Surjective leadCoeffHom := by
  intro c
  set z : ℂ := Multiplicative.toAdd c with hz
  have hu : PowerSeries.constantCoeff ((1 : PowerSeries ℂ) + PowerSeries.C z * PowerSeries.X)
      = 1 := by simp
  refine ⟨ofOneUnit ⟨1 + PowerSeries.C z * PowerSeries.X, hu⟩, ?_⟩
  rw [leadCoeffHom_apply, a₀_ofOneUnit]
  show Multiplicative.ofAdd
    (PowerSeries.coeff 1 ((1 : PowerSeries ℂ) + PowerSeries.C z * PowerSeries.X)) = c
  rw [map_add, PowerSeries.coeff_one, PowerSeries.coeff_C_mul]
  simp [hz]

end PoleOrderTorsor