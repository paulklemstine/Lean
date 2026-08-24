import Mathlib
import Catalog.Shared.PoleOrderObstruction
import Catalog.NumberTheory.PoleOrderObstructionDeep

/-!
# The group of normalized `q`-series and the structure of `ℂ⸨X⸩ˣ`

Third research cycle on the pole-order obstruction for normalized Laurent
`q`-series `f = q⁻¹ + a₀ + a₁ q + ⋯` (the shape of every McKay–Thompson series).

Cycles 1–2 (`Catalog.Shared.PoleOrderObstruction`,
`Catalog.NumberTheory.PoleOrderObstructionDeep`) established that normalized
series are *not* closed under multiplication, the defect being measured exactly
by the additive valuation: a product of `m` of them has `orderTop = -m`.

This file explains what that obstruction really is: the pointwise product is the
*wrong* operation, and there is a canonical corrected one.

* `NormalizedQSeries.isNormalized_iff` — a Laurent series is normalized iff it is
  `q⁻¹ · u` for a (unique) power series `u` with constant term `1`.
* `NormalizedQSeries.star` — the corrected product `f ⋆ g = q · f · g`.
  Theorem `NormalizedQSeries.isNormalized_star`: normalized series *are* closed
  under `⋆`.
* `NormalizedQSeries.Normalized` carries a `CommGroup` structure with `⋆` as
  multiplication and `q⁻¹` as unit, and
  `NormalizedQSeries.mulEquivOneUnit` identifies it with the group of
  `1`-units of `ℂ⟦X⟧`.  So the "normalization obstruction" is precisely the
  statement that the moonshine normalization makes the series a *torsor*
  under the `1`-units, not a submonoid of `ℂ⸨X⸩`.
* `NormalizedQSeries.prod_Normalized` — the group product of a family is
  `q^{m-1} · ∏ fᵢ`, and `NormalizedQSeries.isNormalized_qPow_mul_prod_iff` shows
  `m - 1` is the *unique* exponent restoring normalization.
* `NormalizedQSeries.unitEquiv` — the **structure theorem for the unit group**:
  `ℂ⸨X⸩ˣ ≃* Multiplicative ℤ × ℂ⟦X⟧ˣ`, split by the valuation.  The pole order
  is exactly the `ℤ`-coordinate, which is why the obstruction is complete.
* `NormalizedQSeries.coeff_prod_congr_of_agree` — **finite determinacy**: the
  first `N+1` Laurent coefficients of a product of `m` normalized series are
  determined by the first `N+1` coefficients of each factor, with the degree
  window shifted by the pole order `m`.
-/

namespace NormalizedQSeries

open HahnSeries Finset PoleOrderObstruction

/-! ## 0. The inverse uniformizer and coefficient bookkeeping -/

/-- The Laurent series `q⁻¹`. -/
noncomputable def qInv : LC := HahnSeries.single (-1 : ℤ) (1 : ℂ)

@[simp] theorem qSeries_mul_qInv : qSeries * qInv = 1 := by
  rw [qSeries, qInv, HahnSeries.single_mul_single, add_neg_cancel, mul_one, single_zero_one]

@[simp] theorem qInv_mul_qSeries : qInv * qSeries = 1 := by
  rw [mul_comm]; exact qSeries_mul_qInv

theorem coeff_ofPowerSeries_of_neg (u : PowerSeries ℂ) {k : ℤ} (hk : k < 0) :
    (HahnSeries.ofPowerSeries ℤ ℂ u).coeff k = 0 := by
  rw [show (HahnSeries.ofPowerSeries ℤ ℂ) u = ((u : PowerSeries ℂ) : LC) from rfl,
    PowerSeries.coeff_coe, if_pos hk]

theorem coeff_ofPowerSeries_natCast (u : PowerSeries ℂ) (n : ℕ) :
    (HahnSeries.ofPowerSeries ℤ ℂ u).coeff (n : ℤ) = PowerSeries.coeff n u := by
  simp

theorem coeff_qInv_mul (u : PowerSeries ℂ) (k : ℤ) :
    (qInv * HahnSeries.ofPowerSeries ℤ ℂ u).coeff k
      = (HahnSeries.ofPowerSeries ℤ ℂ u).coeff (k + 1) := by
  rw [qInv, HahnSeries.coeff_single_mul, one_mul]
  ring_nf

/-! ## 1. The normalization characterization -/

/-- Every power series with constant term `1` gives a normalized Laurent series
after multiplication by `q⁻¹`. -/
theorem isNormalized_qInv_mul {u : PowerSeries ℂ} (hu : PowerSeries.constantCoeff u = 1) :
    IsNormalized (qInv * HahnSeries.ofPowerSeries ℤ ℂ u) := by
  constructor
  · rw [coeff_qInv_mul, show (-1 : ℤ) + 1 = ((0 : ℕ) : ℤ) by norm_num,
      coeff_ofPowerSeries_natCast, PowerSeries.coeff_zero_eq_constantCoeff, hu]
  · intro n hn
    rw [coeff_qInv_mul, coeff_ofPowerSeries_of_neg u (by omega)]

/-- **Normalization characterization.** A Laurent series is normalized exactly
when it is `q⁻¹` times a power series with constant term `1`. -/
theorem isNormalized_iff (f : LC) :
    IsNormalized f ↔ ∃ u : PowerSeries ℂ, PowerSeries.constantCoeff u = 1 ∧
      f = qInv * HahnSeries.ofPowerSeries ℤ ℂ u := by
  constructor
  · intro h
    refine ⟨normalizedPart f, constantCoeff_normalizedPart f h, ?_⟩
    rw [ofPowerSeries_normalizedPart f h, ← mul_assoc, qInv_mul_qSeries, one_mul]
  · rintro ⟨u, hu, rfl⟩
    exact isNormalized_qInv_mul hu

/-- Reconstructing the power series from the normalized series. -/
theorem normalizedPart_qInv_mul {u : PowerSeries ℂ} (hu : PowerSeries.constantCoeff u = 1) :
    normalizedPart (qInv * HahnSeries.ofPowerSeries ℤ ℂ u) = u := by
  apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
  rw [ofPowerSeries_normalizedPart _ (isNormalized_qInv_mul hu), ← mul_assoc,
    qSeries_mul_qInv, one_mul]

theorem qInv_mul_normalizedPart {f : LC} (h : IsNormalized f) :
    qInv * HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f) = f := by
  rw [ofPowerSeries_normalizedPart f h, ← mul_assoc, qInv_mul_qSeries, one_mul]

/-! ## 2. The corrected product -/

/-- The corrected ("star") product of two `q`-series: `f ⋆ g = q · f · g`. -/
noncomputable def star (f g : LC) : LC := qSeries * (f * g)

@[inherit_doc] infixl:70 " ⋆ " => star

/-- **Closure.** Normalized series *are* closed under the corrected product. -/
theorem isNormalized_star {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g) :
    IsNormalized (f ⋆ g) := by
  obtain ⟨u, hu, rfl⟩ := (isNormalized_iff f).mp hf
  obtain ⟨v, hv, rfl⟩ := (isNormalized_iff g).mp hg
  have : qSeries * ((qInv * HahnSeries.ofPowerSeries ℤ ℂ u) *
      (qInv * HahnSeries.ofPowerSeries ℤ ℂ v))
      = qInv * HahnSeries.ofPowerSeries ℤ ℂ (u * v) := by
    rw [map_mul]
    have h1 : qSeries * qInv = 1 := qSeries_mul_qInv
    calc qSeries * ((qInv * HahnSeries.ofPowerSeries ℤ ℂ u) *
            (qInv * HahnSeries.ofPowerSeries ℤ ℂ v))
        = (qSeries * qInv) * (qInv * (HahnSeries.ofPowerSeries ℤ ℂ u *
            HahnSeries.ofPowerSeries ℤ ℂ v)) := by ring
      _ = qInv * (HahnSeries.ofPowerSeries ℤ ℂ u * HahnSeries.ofPowerSeries ℤ ℂ v) := by
            rw [h1, one_mul]
  rw [star, this]
  exact isNormalized_qInv_mul (by rw [map_mul, hu, hv, one_mul])

theorem isNormalized_qInv : IsNormalized qInv := by
  have : qInv = qInv * HahnSeries.ofPowerSeries ℤ ℂ 1 := by simp
  rw [this]
  exact isNormalized_qInv_mul (by simp)

/-- `q⁻¹` is a two-sided unit for the corrected product. -/
theorem star_qInv (f : LC) : qInv ⋆ f = f := by
  rw [star, ← mul_assoc, qSeries_mul_qInv, one_mul]

theorem star_comm (f g : LC) : f ⋆ g = g ⋆ f := by
  simp only [star]; ring

theorem star_assoc (f g h : LC) : (f ⋆ g) ⋆ h = f ⋆ (g ⋆ h) := by
  simp only [star]; ring

/-- The corrected product corresponds to the plain product of the power-series
parts: this is the *reason* `⋆` is the right operation. -/
theorem normalizedPart_star {f g : LC} (hf : IsNormalized f) (hg : IsNormalized g) :
    normalizedPart (f ⋆ g) = normalizedPart f * normalizedPart g := by
  apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
  rw [ofPowerSeries_normalizedPart _ (isNormalized_star hf hg), map_mul,
    ofPowerSeries_normalizedPart f hf, ofPowerSeries_normalizedPart g hg, star]
  ring

/-! ## 3. The group of normalized series and the `1`-units of `ℂ⟦X⟧` -/

/-- The `1`-units of `ℂ⟦X⟧`: power series with constant term `1`. -/
structure OneUnit where
  /-- The underlying power series. -/
  val : PowerSeries ℂ
  /-- Its constant term is `1`. -/
  constantCoeff_val : PowerSeries.constantCoeff val = 1

namespace OneUnit

@[ext] theorem ext {u v : OneUnit} (h : u.val = v.val) : u = v := by
  cases u; cases v; simpa using h

noncomputable instance : CommGroup OneUnit where
  mul u v := ⟨u.val * v.val, by rw [map_mul, u.constantCoeff_val, v.constantCoeff_val, one_mul]⟩
  one := ⟨1, by simp⟩
  inv u := ⟨PowerSeries.invOfUnit u.val 1, by
    simp [PowerSeries.constantCoeff_invOfUnit]⟩
  mul_assoc u v w := ext (mul_assoc _ _ _)
  one_mul u := ext (one_mul _)
  mul_one u := ext (mul_one _)
  mul_comm u v := ext (mul_comm _ _)
  inv_mul_cancel u := ext (by
    show PowerSeries.invOfUnit u.val 1 * u.val = 1
    rw [mul_comm]
    exact PowerSeries.mul_invOfUnit _ _ (by simpa using u.constantCoeff_val))

@[simp] theorem val_mul (u v : OneUnit) : (u * v).val = u.val * v.val := rfl
@[simp] theorem val_one : (1 : OneUnit).val = 1 := rfl

/-- Every `1`-unit really is a unit of `ℂ⟦X⟧`. -/
theorem isUnit_val (u : OneUnit) : IsUnit u.val :=
  PowerSeries.isUnit_iff_constantCoeff.mpr (by rw [u.constantCoeff_val]; exact isUnit_one)

end OneUnit

/-- The normalized `q`-series `q⁻¹ + a₀ + a₁ q + ⋯`, as a type. -/
structure Normalized where
  /-- The underlying Laurent series. -/
  val : LC
  /-- It is normalized. -/
  isNormalized_val : IsNormalized val

namespace Normalized

@[ext] theorem ext {f g : Normalized} (h : f.val = g.val) : f = g := by
  cases f; cases g; simpa using h

noncomputable instance : CommGroup Normalized where
  mul f g := ⟨f.val ⋆ g.val, isNormalized_star f.isNormalized_val g.isNormalized_val⟩
  one := ⟨qInv, isNormalized_qInv⟩
  inv f := ⟨qInv * HahnSeries.ofPowerSeries ℤ ℂ
      (PowerSeries.invOfUnit (normalizedPart f.val) 1),
    isNormalized_qInv_mul (by simp [PowerSeries.constantCoeff_invOfUnit])⟩
  mul_assoc f g h := ext (star_assoc _ _ _)
  one_mul f := ext (star_qInv _)
  mul_one f := ext (by
    show f.val ⋆ qInv = f.val
    rw [star_comm, star_qInv])
  mul_comm f g := ext (star_comm _ _)
  inv_mul_cancel f := ext (by
    show (qInv * HahnSeries.ofPowerSeries ℤ ℂ
      (PowerSeries.invOfUnit (normalizedPart f.val) 1)) ⋆ f.val = qInv
    have hF : PowerSeries.constantCoeff (normalizedPart f.val) = 1 :=
      constantCoeff_normalizedPart _ f.isNormalized_val
    have hmul : normalizedPart f.val * PowerSeries.invOfUnit (normalizedPart f.val) 1 = 1 :=
      PowerSeries.mul_invOfUnit _ _ (by simpa using hF)
    have hf : f.val = qInv * HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f.val) :=
      (qInv_mul_normalizedPart f.isNormalized_val).symm
    rw [star]
    nth_rewrite 2 [hf]
    calc qSeries * ((qInv * HahnSeries.ofPowerSeries ℤ ℂ
            (PowerSeries.invOfUnit (normalizedPart f.val) 1)) *
            (qInv * HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f.val)))
        = (qSeries * qInv) * (qInv * HahnSeries.ofPowerSeries ℤ ℂ
            (normalizedPart f.val * PowerSeries.invOfUnit (normalizedPart f.val) 1)) := by
          rw [map_mul]; ring
      _ = qInv := by rw [hmul, qSeries_mul_qInv, one_mul, map_one, mul_one])

@[simp] theorem val_mul (f g : Normalized) : (f * g).val = f.val ⋆ g.val := rfl

@[simp] theorem val_one : (1 : Normalized).val = qInv := rfl

end Normalized

/-- **Torsor / group identification.** The normalized `q`-series under the
corrected product `f ⋆ g = q f g` form a commutative group isomorphic to the
group of `1`-units of `ℂ⟦X⟧`, the isomorphism being `f ↦ q f`. -/
noncomputable def mulEquivOneUnit : Normalized ≃* OneUnit where
  toFun f := ⟨normalizedPart f.val, constantCoeff_normalizedPart _ f.isNormalized_val⟩
  invFun u := ⟨qInv * HahnSeries.ofPowerSeries ℤ ℂ u.val, isNormalized_qInv_mul u.constantCoeff_val⟩
  left_inv f := Normalized.ext (qInv_mul_normalizedPart f.isNormalized_val)
  right_inv u := OneUnit.ext (normalizedPart_qInv_mul u.constantCoeff_val)
  map_mul' f g := OneUnit.ext (normalizedPart_star f.isNormalized_val g.isNormalized_val)

@[simp] theorem mulEquivOneUnit_val (f : Normalized) :
    (mulEquivOneUnit f).val = normalizedPart f.val := rfl

/-! ## 4. Finite products: the corrected product of `m` factors -/

/-- **The group product computes the corrected product.**  In the group
`Normalized`, the product of a family of `m` normalized series is
`q^{m-1} · ∏ fᵢ`; equivalently, the unique power of `q` that repairs the
`m`-fold pole down to a simple pole is `q^{m-1}`. -/
theorem prod_Normalized {ι : Type*} (s : Finset ι) (f : ι → Normalized) :
    (∏ i ∈ s, f i).val
      = HahnSeries.single ((s.card : ℤ) - 1) (1 : ℂ) * ∏ i ∈ s, (f i).val := by
  classical
  induction s using Finset.induction with
  | empty => simp [qInv]
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.prod_insert ha, Normalized.val_mul, ih, star,
        Finset.card_insert_of_notMem ha, qSeries]
      rw [show ((s.card + 1 : ℕ) : ℤ) - 1 = (s.card : ℤ) by push_cast; ring]
      calc HahnSeries.single (1 : ℤ) (1 : ℂ) *
              ((f a).val * (HahnSeries.single ((s.card : ℤ) - 1) (1 : ℂ) *
                ∏ i ∈ s, (f i).val))
          = (HahnSeries.single (1 : ℤ) (1 : ℂ) *
              HahnSeries.single ((s.card : ℤ) - 1) (1 : ℂ)) *
              ((f a).val * ∏ i ∈ s, (f i).val) := by ring
        _ = HahnSeries.single ((s.card : ℤ)) (1 : ℂ) *
              ((f a).val * ∏ i ∈ s, (f i).val) := by
              rw [HahnSeries.single_mul_single, mul_one,
                show (1 : ℤ) + ((s.card : ℤ) - 1) = (s.card : ℤ) by ring]

/-- Consequently `q^{m-1} · ∏ fᵢ` is normalized. -/
theorem isNormalized_single_mul_prod {ι : Type*} (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    IsNormalized (HahnSeries.single ((s.card : ℤ) - 1) (1 : ℂ) * ∏ i ∈ s, f i) := by
  classical
  set F : ι → Normalized := fun i => if hi : i ∈ s then ⟨f i, h i hi⟩ else 1 with hF
  have hcoe : ∀ i ∈ s, (F i).val = f i := by
    intro i hi; simp [hF, hi]
  have hkey := prod_Normalized s F
  rw [Finset.prod_congr rfl hcoe] at hkey
  rw [← hkey]
  exact (∏ i ∈ s, F i).isNormalized_val

/-- **Uniqueness of the correction exponent.** For a family of normalized
series, `q^k · ∏ fᵢ` is normalized precisely for `k = m - 1`. -/
theorem isNormalized_qPow_mul_prod_iff {ι : Type*} (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℤ) :
    IsNormalized (HahnSeries.single k (1 : ℂ) * ∏ i ∈ s, f i) ↔ k = (s.card : ℤ) - 1 := by
  constructor
  · intro hk
    have hord := hk.orderTop_eq
    rw [HahnSeries.orderTop_mul, HahnSeries.orderTop_single (one_ne_zero (α := ℂ)),
      orderTop_prod_normalized s f h, ← WithTop.coe_add] at hord
    have : k + -(s.card : ℤ) = -1 := by exact_mod_cast hord
    omega
  · rintro rfl
    exact isNormalized_single_mul_prod s f h

/-! ## 5. Structure theorem for the unit group of `ℂ⸨X⸩` -/

/-- Laurent series with nonvanishing constant term have order `0`. -/
theorem order_ofPowerSeries_of_constantCoeff_ne_zero {u : PowerSeries ℂ}
    (hu : PowerSeries.constantCoeff u ≠ 0) :
    (HahnSeries.ofPowerSeries ℤ ℂ u).order = 0 := by
  have hne : HahnSeries.ofPowerSeries ℤ ℂ u ≠ 0 := by
    intro h
    apply hu
    have := coeff_ofPowerSeries_natCast u 0
    rw [h] at this
    simpa [PowerSeries.coeff_zero_eq_constantCoeff] using this.symm
  have htop : (HahnSeries.ofPowerSeries ℤ ℂ u).orderTop = ((0 : ℤ) : WithTop ℤ) := by
    refine HahnSeries.orderTop_eq_of_le (g := (0 : ℤ)) ?_ ?_
    · rw [HahnSeries.mem_support]
      have := coeff_ofPowerSeries_natCast u 0
      simp only [Nat.cast_zero] at this
      rw [this]
      simpa [PowerSeries.coeff_zero_eq_constantCoeff] using hu
    · intro g' hg'
      by_contra hlt
      push_neg at hlt
      exact (HahnSeries.mem_support _ _).mp hg' (coeff_ofPowerSeries_of_neg u hlt)
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at htop
  exact_mod_cast htop

/-- The unit group homomorphism induced by `ℂ⟦X⟧ → ℂ⸨X⸩`. -/
noncomputable def powerSeriesUnitsHom : (PowerSeries ℂ)ˣ →* (LC)ˣ :=
  Units.map (HahnSeries.ofPowerSeries ℤ ℂ : PowerSeries ℂ →+* LC).toMonoidHom

@[simp] theorem powerSeriesUnitsHom_val (v : (PowerSeries ℂ)ˣ) :
    ((powerSeriesUnitsHom v : (LC)ˣ) : LC) = HahnSeries.ofPowerSeries ℤ ℂ (v : PowerSeries ℂ) :=
  rfl

/-- The valuation splitting `ℤ → ℂ⸨X⸩ˣ`, `k ↦ q^k`. -/
noncomputable def singleUnitHom : Multiplicative ℤ →* (LC)ˣ where
  toFun k := singleUnit (Multiplicative.toAdd k)
  map_one' := by
    apply Units.ext
    simp [singleUnit, single_zero_one]
  map_mul' k l := by
    apply Units.ext
    simp [singleUnit, HahnSeries.single_mul_single]

@[simp] theorem singleUnitHom_val (k : Multiplicative ℤ) :
    ((singleUnitHom k : (LC)ˣ) : LC) = HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) := rfl

/-- The combined homomorphism `(k, v) ↦ q^k · v`. -/
noncomputable def unitHom : Multiplicative ℤ × (PowerSeries ℂ)ˣ →* (LC)ˣ where
  toFun p := singleUnitHom p.1 * powerSeriesUnitsHom p.2
  map_one' := by simp
  map_mul' p q := by
    simp only [map_mul, Prod.fst_mul, Prod.snd_mul]
    exact (mul_mul_mul_comm (singleUnitHom p.1) (powerSeriesUnitsHom p.2)
      (singleUnitHom q.1) (powerSeriesUnitsHom q.2)).symm

theorem unitHom_val (p : Multiplicative ℤ × (PowerSeries ℂ)ˣ) :
    ((unitHom p : (LC)ˣ) : LC)
      = HahnSeries.single (Multiplicative.toAdd p.1) (1 : ℂ) *
        HahnSeries.ofPowerSeries ℤ ℂ (p.2 : PowerSeries ℂ) := rfl

theorem unitHom_injective : Function.Injective unitHom := by
  rw [← MonoidHom.ker_eq_bot_iff]
  rw [eq_bot_iff]
  rintro ⟨k, v⟩ hk
  have hval : HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) *
      HahnSeries.ofPowerSeries ℤ ℂ (v : PowerSeries ℂ) = 1 := by
    have := congrArg (fun u : (LC)ˣ => (u : LC)) (MonoidHom.mem_ker.mp hk)
    simpa [unitHom_val] using this
  have hcv : PowerSeries.constantCoeff (v : PowerSeries ℂ) ≠ 0 := by
    intro h
    have : IsUnit (PowerSeries.constantCoeff (v : PowerSeries ℂ)) :=
      PowerSeries.isUnit_iff_constantCoeff.mp v.isUnit
    rw [h] at this
    exact (not_isUnit_zero) this
  have hvne : HahnSeries.ofPowerSeries ℤ ℂ (v : PowerSeries ℂ) ≠ 0 := by
    intro h
    apply hcv
    have := coeff_ofPowerSeries_natCast (v : PowerSeries ℂ) 0
    rw [h] at this
    simpa [PowerSeries.coeff_zero_eq_constantCoeff] using this.symm
  have hsne : HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) ≠ (0 : LC) :=
    HahnSeries.single_ne_zero one_ne_zero
  -- the valuation forces `k = 0`
  have hord : (HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) : LC).order +
      (HahnSeries.ofPowerSeries ℤ ℂ (v : PowerSeries ℂ)).order = 0 := by
    rw [← order_mul_of_ne_zero' hsne hvne, hval, HahnSeries.order_one]
  have hsingle : (HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) : LC).order
      = Multiplicative.toAdd k := by
    have h := HahnSeries.orderTop_single (Γ := ℤ) (a := Multiplicative.toAdd k)
      (one_ne_zero (α := ℂ))
    rw [← HahnSeries.order_eq_orderTop_of_ne_zero hsne] at h
    exact_mod_cast h
  rw [hsingle, order_ofPowerSeries_of_constantCoeff_ne_zero hcv, add_zero] at hord
  have hk0 : k = 1 := by
    apply Multiplicative.toAdd.injective
    simpa using hord
  subst hk0
  have : HahnSeries.ofPowerSeries ℤ ℂ (v : PowerSeries ℂ) = 1 := by
    simpa [single_zero_one] using hval
  have hv1 : (v : PowerSeries ℂ) = 1 := by
    apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
    rw [this, map_one]
  simp [Subgroup.mem_bot, Prod.ext_iff, Units.ext_iff, hv1]

theorem unitHom_surjective : Function.Surjective unitHom := by
  intro x
  have hx : (x : LC) ≠ 0 := x.ne_zero
  set n : ℤ := (x : LC).order with hn
  set P : PowerSeries ℂ := (x : LC).powerSeriesPart with hP
  have hofP : HahnSeries.ofPowerSeries ℤ ℂ P = HahnSeries.single (-n) (1 : ℂ) * (x : LC) :=
    LaurentSeries.ofPowerSeries_powerSeriesPart (x : LC)
  have hconst : PowerSeries.constantCoeff P = (x : LC).coeff n := by
    have h0 := LaurentSeries.powerSeriesPart_coeff (x : LC) 0
    rw [PowerSeries.coeff_zero_eq_constantCoeff] at h0
    rw [hP, h0, hn]
    norm_num
  have hne : PowerSeries.constantCoeff P ≠ 0 := by
    rw [hconst]
    have := HahnSeries.leadingCoeff_ne_zero.mpr hx
    rwa [HahnSeries.leadingCoeff_eq] at this
  obtain ⟨v, hv⟩ : IsUnit P :=
    PowerSeries.isUnit_iff_constantCoeff.mpr (isUnit_iff_ne_zero.mpr hne)
  refine ⟨(Multiplicative.ofAdd n, v), ?_⟩
  apply Units.ext
  rw [unitHom_val]
  simp only [toAdd_ofAdd]
  rw [hv, hofP, ← mul_assoc, HahnSeries.single_mul_single, add_neg_cancel, mul_one,
    single_zero_one, one_mul]

/-- **Structure theorem for `ℂ⸨X⸩ˣ`.**  The unit group of the field of Laurent
series over `ℂ` splits as `Multiplicative ℤ × ℂ⟦X⟧ˣ`, the `ℤ`-factor being the
valuation (pole order) and the splitting being `k ↦ q^k`.  The pole-order
obstruction of the previous cycles is exactly the `ℤ`-coordinate of this
decomposition, which is why it is a complete invariant. -/
noncomputable def unitEquiv : Multiplicative ℤ × (PowerSeries ℂ)ˣ ≃* (LC)ˣ :=
  MulEquiv.ofBijective unitHom ⟨unitHom_injective, unitHom_surjective⟩

/-- The valuation coordinate of the structure theorem is `orderMonoidHom`. -/
theorem orderMonoidHom_unitHom (p : Multiplicative ℤ × (PowerSeries ℂ)ˣ) :
    orderMonoidHom (unitHom p) = p.1 := by
  have hsne : HahnSeries.single (Multiplicative.toAdd p.1) (1 : ℂ) ≠ (0 : LC) :=
    HahnSeries.single_ne_zero one_ne_zero
  have hcv : PowerSeries.constantCoeff (p.2 : PowerSeries ℂ) ≠ 0 := by
    intro h
    have : IsUnit (PowerSeries.constantCoeff (p.2 : PowerSeries ℂ)) :=
      PowerSeries.isUnit_iff_constantCoeff.mp p.2.isUnit
    rw [h] at this
    exact not_isUnit_zero this
  have hvne : HahnSeries.ofPowerSeries ℤ ℂ (p.2 : PowerSeries ℂ) ≠ 0 := by
    intro h
    apply hcv
    have := coeff_ofPowerSeries_natCast (p.2 : PowerSeries ℂ) 0
    rw [h] at this
    simpa [PowerSeries.coeff_zero_eq_constantCoeff] using this.symm
  have hsingle : (HahnSeries.single (Multiplicative.toAdd p.1) (1 : ℂ) : LC).order
      = Multiplicative.toAdd p.1 := by
    have h := HahnSeries.orderTop_single (Γ := ℤ) (a := Multiplicative.toAdd p.1)
      (one_ne_zero (α := ℂ))
    rw [← HahnSeries.order_eq_orderTop_of_ne_zero hsne] at h
    exact_mod_cast h
  rw [orderMonoidHom_apply, unitHom_val, order_mul_of_ne_zero' hsne hvne, hsingle,
    order_ofPowerSeries_of_constantCoeff_ne_zero hcv, add_zero]
  rfl

/-! ## 6. Finite determinacy of the corrected product -/

/-- Products of power series are determined, up to degree `N`, by the factors up
to degree `N`. -/
theorem coeff_mul_congr {a b a' b' : PowerSeries ℂ} {N : ℕ}
    (ha : ∀ j ≤ N, PowerSeries.coeff j a = PowerSeries.coeff j a')
    (hb : ∀ j ≤ N, PowerSeries.coeff j b = PowerSeries.coeff j b') :
    ∀ j ≤ N, PowerSeries.coeff j (a * b) = PowerSeries.coeff j (a' * b') := by
  intro j hj
  rw [PowerSeries.coeff_mul, PowerSeries.coeff_mul]
  refine Finset.sum_congr rfl ?_
  rintro ⟨p, q⟩ hpq
  rw [Finset.mem_antidiagonal] at hpq
  rw [ha p (by omega), hb q (by omega)]

/-- Finite determinacy for finite products of power series. -/
theorem coeff_prod_congr {ι : Type*} (s : Finset ι) (g g' : ι → PowerSeries ℂ) (N : ℕ)
    (h : ∀ i ∈ s, ∀ j ≤ N, PowerSeries.coeff j (g i) = PowerSeries.coeff j (g' i)) :
    ∀ j ≤ N, PowerSeries.coeff j (∏ i ∈ s, g i) = PowerSeries.coeff j (∏ i ∈ s, g' i) := by
  classical
  induction s using Finset.induction with
  | empty => intro j hj; simp
  | insert a s ha ih =>
      intro j hj
      rw [Finset.prod_insert ha, Finset.prod_insert ha]
      exact coeff_mul_congr (h a (Finset.mem_insert_self a s))
        (ih (fun i hi => h i (Finset.mem_insert_of_mem hi))) j hj

/-- **Finite determinacy of the Monster-type product.**  If `m` normalized
series `fᵢ` agree with `m` normalized series `gᵢ` in all Laurent degrees
`-1, 0, 1, …, N-1`, then the products agree in all degrees
`-m, 1-m, …, N-m`: the pole order `m` is exactly the shift by which
information is lost. -/
theorem coeff_prod_congr_of_agree {ι : Type*} (s : Finset ι) (f g : ι → LC)
    (hf : ∀ i ∈ s, IsNormalized (f i)) (hg : ∀ i ∈ s, IsNormalized (g i)) (N : ℕ)
    (h : ∀ i ∈ s, ∀ j : ℕ, j ≤ N → (f i).coeff ((j : ℤ) - 1) = (g i).coeff ((j : ℤ) - 1)) :
    ∀ j : ℕ, j ≤ N →
      (∏ i ∈ s, f i).coeff ((j : ℤ) - s.card) = (∏ i ∈ s, g i).coeff ((j : ℤ) - s.card) := by
  classical
  intro j hj
  have key : ∀ (F : ι → LC) (hF : ∀ i ∈ s, IsNormalized (F i)),
      (∏ i ∈ s, F i).coeff ((j : ℤ) - s.card)
        = PowerSeries.coeff j (∏ i ∈ s, normalizedPart (F i)) := by
    intro F hF
    have hfact := prod_normalized_factorization s F hF
    rw [hfact, HahnSeries.coeff_single_mul, one_mul,
      show ((j : ℤ) - s.card) - (-(s.card : ℤ)) = (j : ℤ) by ring,
      coeff_ofPowerSeries_natCast]
  rw [key f hf, key g hg]
  refine coeff_prod_congr s _ _ N ?_ j hj
  intro i hi k hk
  rw [coeff_normalizedPart (hf i hi) k, coeff_normalizedPart (hg i hi) k]
  exact h i hi k hk

/-! ## 7. Monstrous Moonshine specialization -/

/-- The corrected product of the `194` McKay–Thompson-shaped series, namely
`q^{193} · ∏_g T_g`, is again a normalized `q`-series: the Monster-sized
product lives in the group `Normalized`, once the pole is corrected. -/
theorem isNormalized_moonshine_corrected (c : Fin monsterClassCount → ℕ → ℂ) :
    IsNormalized (HahnSeries.single (193 : ℤ) (1 : ℂ) * ∏ i, traceLaurent (c i)) := by
  have := isNormalized_single_mul_prod Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  simpa [monsterClassCount] using this

/-- And `193` is the unique exponent with that property. -/
theorem isNormalized_moonshine_corrected_iff (c : Fin monsterClassCount → ℕ → ℂ) (k : ℤ) :
    IsNormalized (HahnSeries.single k (1 : ℂ) * ∏ i, traceLaurent (c i)) ↔ k = 193 := by
  have := isNormalized_qPow_mul_prod_iff Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i)) k
  simpa [monsterClassCount] using this

end NormalizedQSeries