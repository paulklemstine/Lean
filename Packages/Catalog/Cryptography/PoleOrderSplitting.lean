import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep

/-!
# Cycle 3: the pole-order obstruction is a *split* extension, and a complete invariant

Cycles 1 and 2 (`Shared.PoleOrderObstruction`, `Shared.PoleOrderObstructionDeep`)
established that a product of `m` normalized `q`-series has `orderTop = -m`, that
`194` Monster-sized factors give a pole of order `194`, and that multiplying by
`q ^ m` restores order `0`.

This file explains the *group-theoretic reason* why `q ^ m` is the canonical (and
only) correction, by producing the full structure of the unit group of
`ℂ⸨X⸩ = LaurentSeries ℂ`:

1. **Splitting** (`PoleOrderSplitting.laurentUnitsEquiv`): the multiplicative group
   `ℂ⸨X⸩ˣ` is canonically isomorphic to `ℂ⟦X⟧ˣ × Multiplicative ℤ`, the
   isomorphism sending `(p, k)` to `p · q ^ k`.  The short exact sequence
   `1 → ℂ⟦X⟧ˣ → ℂ⸨X⸩ˣ → ℤ → 0` is therefore split, with the splitting given by
   `k ↦ q ^ k`.  The pole-order obstruction is exactly the `ℤ`-component.

2. **Kernel description** (`PoleOrderSplitting.order_eq_zero_iff_exists_psUnit`): a
   Laurent unit has order `0` iff it comes from a unit power series.  Combined
   with 1, this shows that the obstruction of cycles 1–2 is not merely *an*
   invariant but a *complete* invariant of the coset space
   `ℂ⸨X⸩ˣ / ℂ⟦X⟧ˣ ≃ ℤ` (`PoleOrderSplitting.exists_unitMul_iff_order_eq`).

3. **Blinding invariance and unique unmasking** — the cryptographic reading.  The
   "pole leak" `poleLeak u = order u` is invariant under multiplication by any
   unit power series (`poleLeak_mul_psUnitHom`), so no blinding by invertible
   power series can change it; and the subgroup that fixes the leak is *exactly*
   `ℂ⟦X⟧ˣ` (`poleLeak_mul_eq_iff`).  A shift by `q ^ k` moves the leak by exactly
   `k`, and for every target value there is a unique such shift
   (`existsUnique_shift_poleLeak`).  Pole order therefore behaves as a perfect
   one-time-pad-over-`ℤ` invariant: unmaskable by the `ℂ⟦X⟧ˣ`-action, perfectly
   randomizable by the `q^ℤ`-action.

4. **A Newton identity in every degree**
   (`PoleOrderSplitting.coeff_prod_normalized_general`): for a product of `m`
   normalized series, the Laurent coefficient at degree `n - m` is the full
   convolution `∑_{ν : ∑ νᵢ = n} ∏ᵢ fᵢ.coeff (νᵢ - 1)`.  This subsumes the
   subleading (cycle 1) and sub-subleading (cycle 2) identities, the cases
   `n = 1, 2`, and is proved by transporting `PowerSeries.coeff_prod` through the
   `q^m`-correction.

5. **Monster specializations**: the class of the Monstrous Moonshine product in
   `ℂ⸨X⸩ˣ / ℂ⟦X⟧ˣ ≅ ℤ` is `-194`, it is unchanged by blinding, and `q ^ 194` is
   the unique monomial correction landing in `ℂ⟦X⟧ˣ`.
-/

namespace PoleOrderSplitting

open HahnSeries Finset PoleOrderObstruction

/-! ## 0. Units coming from power series -/

/-- The image of a power series with nonzero constant term has `orderTop = 0`. -/
theorem orderTop_ofPowerSeries_of_constantCoeff_ne_zero {p : PowerSeries ℂ}
    (hp : PowerSeries.constantCoeff p ≠ 0) :
    (HahnSeries.ofPowerSeries ℤ ℂ p).orderTop = ((0 : ℤ) : WithTop ℤ) := by
  refine HahnSeries.orderTop_eq_of_le (g := (0 : ℤ)) ?_ ?_
  · rw [HahnSeries.mem_support, PowerSeries.coeff_coe]
    simpa using hp
  · intro g' hg'
    by_contra hlt
    push_neg at hlt
    refine (HahnSeries.mem_support _ _).mp hg' ?_
    rw [PowerSeries.coeff_coe, if_pos (by omega)]

theorem ofPowerSeries_ne_zero_of_constantCoeff_ne_zero {p : PowerSeries ℂ}
    (hp : PowerSeries.constantCoeff p ≠ 0) :
    HahnSeries.ofPowerSeries ℤ ℂ p ≠ (0 : LC) := by
  intro h
  apply hp
  have h0 : (HahnSeries.ofPowerSeries ℤ ℂ p).coeff (0 : ℤ) = 0 := by rw [h]; simp
  rw [PowerSeries.coeff_coe, if_neg (by norm_num)] at h0
  simpa using h0

/-- The image of a power series with nonzero constant term has `order = 0`. -/
theorem order_ofPowerSeries_of_constantCoeff_ne_zero {p : PowerSeries ℂ}
    (hp : PowerSeries.constantCoeff p ≠ 0) :
    (HahnSeries.ofPowerSeries ℤ ℂ p : LC).order = 0 := by
  have hne := ofPowerSeries_ne_zero_of_constantCoeff_ne_zero hp
  have h := orderTop_ofPowerSeries_of_constantCoeff_ne_zero hp
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at h
  exact_mod_cast h

theorem constantCoeff_ne_zero_of_isUnit {p : PowerSeries ℂ} (hp : IsUnit p) :
    PowerSeries.constantCoeff p ≠ 0 :=
  (PowerSeries.isUnit_iff_constantCoeff.mp hp).ne_zero

/-- The unit group homomorphism `ℂ⟦X⟧ˣ →* ℂ⸨X⸩ˣ` induced by `ofPowerSeries`. -/
noncomputable def psUnitHom : (PowerSeries ℂ)ˣ →* (LC)ˣ :=
  Units.map (HahnSeries.ofPowerSeries ℤ ℂ).toMonoidHom

@[simp] theorem psUnitHom_val (p : (PowerSeries ℂ)ˣ) :
    (psUnitHom p : LC) = HahnSeries.ofPowerSeries ℤ ℂ (p : PowerSeries ℂ) := rfl

@[simp] theorem order_psUnitHom (p : (PowerSeries ℂ)ˣ) : ((psUnitHom p : (LC)ˣ) : LC).order = 0 := by
  rw [psUnitHom_val]
  exact order_ofPowerSeries_of_constantCoeff_ne_zero (constantCoeff_ne_zero_of_isUnit p.isUnit)

/-- The splitting `Multiplicative ℤ →* ℂ⸨X⸩ˣ`, `k ↦ q ^ k`. -/
noncomputable def qPowHom : Multiplicative ℤ →* (LC)ˣ where
  toFun k := singleUnit (Multiplicative.toAdd k)
  map_one' := by
    apply Units.ext
    simp [singleUnit]
  map_mul' k l := by
    apply Units.ext
    simp only [Units.val_mul, singleUnit_val]
    rw [HahnSeries.single_mul_single, mul_one]
    rfl

@[simp] theorem qPowHom_val (k : Multiplicative ℤ) :
    (qPowHom k : LC) = HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) := rfl

@[simp] theorem order_qPowHom (k : Multiplicative ℤ) :
    ((qPowHom k : LC)).order = Multiplicative.toAdd k := by
  have hne : HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) ≠ (0 : LC) :=
    HahnSeries.single_ne_zero one_ne_zero
  have h := HahnSeries.orderTop_single (Γ := ℤ) (a := Multiplicative.toAdd k)
    (one_ne_zero (α := ℂ))
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at h
  rw [qPowHom_val]
  exact_mod_cast h

/-! ## 1. The splitting isomorphism `ℂ⟦X⟧ˣ × ℤ ≃* ℂ⸨X⸩ˣ` -/

/-- The comparison homomorphism `(p, k) ↦ p · q ^ k`. -/
noncomputable def unitsCompare : (PowerSeries ℂ)ˣ × Multiplicative ℤ →* (LC)ˣ where
  toFun pk := psUnitHom pk.1 * qPowHom pk.2
  map_one' := by simp
  map_mul' a b := by
    simp only [Prod.fst_mul, Prod.snd_mul, map_mul]
    exact mul_mul_mul_comm (psUnitHom a.1) (psUnitHom b.1) (qPowHom a.2) (qPowHom b.2)

@[simp] theorem unitsCompare_apply (p : (PowerSeries ℂ)ˣ) (k : Multiplicative ℤ) :
    unitsCompare (p, k) = psUnitHom p * qPowHom k := rfl

theorem unitsCompare_val (p : (PowerSeries ℂ)ˣ) (k : Multiplicative ℤ) :
    ((unitsCompare (p, k) : (LC)ˣ) : LC)
      = HahnSeries.ofPowerSeries ℤ ℂ (p : PowerSeries ℂ)
          * HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) := by
  rw [unitsCompare_apply, Units.val_mul, psUnitHom_val, qPowHom_val]

theorem order_unitsCompare (p : (PowerSeries ℂ)ˣ) (k : Multiplicative ℤ) :
    ((unitsCompare (p, k) : (LC)ˣ) : LC).order = Multiplicative.toAdd k := by
  rw [unitsCompare_apply, Units.val_mul,
    order_mul_of_ne_zero' (psUnitHom p).ne_zero (qPowHom k).ne_zero, order_psUnitHom,
    order_qPowHom, zero_add]

theorem unitsCompare_injective : Function.Injective unitsCompare := by
  rw [injective_iff_map_eq_one]
  rintro ⟨p, k⟩ hpk
  have hk : Multiplicative.toAdd k = 0 := by
    have h := order_unitsCompare p k
    rw [hpk] at h
    simpa using h.symm
  have hk' : k = 1 := hk
  subst hk'
  have hval : (HahnSeries.ofPowerSeries ℤ ℂ (p : PowerSeries ℂ) : LC) = 1 := by
    have h : ((unitsCompare (p, (1 : Multiplicative ℤ)) : (LC)ˣ) : LC) = 1 := by
      rw [hpk]; rfl
    rw [unitsCompare_val] at h
    simpa using h
  have hp1 : (p : PowerSeries ℂ) = 1 := by
    apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
    simpa using hval
  simp [Prod.ext_iff, Units.ext_iff, hp1]

theorem unitsCompare_surjective : Function.Surjective unitsCompare := by
  intro u
  set x : LC := (u : LC) with hx
  have hxne : x ≠ 0 := u.ne_zero
  have hconst : PowerSeries.constantCoeff (x.powerSeriesPart) ≠ 0 := by
    rw [← PowerSeries.coeff_zero_eq_constantCoeff, LaurentSeries.powerSeriesPart_coeff]
    simpa [HahnSeries.leadingCoeff_eq] using
      (HahnSeries.leadingCoeff_ne_zero (x := x)).mpr hxne
  have hpu : IsUnit (x.powerSeriesPart) :=
    PowerSeries.isUnit_iff_constantCoeff.mpr (isUnit_iff_ne_zero.mpr hconst)
  refine ⟨(hpu.unit, Multiplicative.ofAdd x.order), ?_⟩
  apply Units.ext
  rw [unitsCompare_val]
  rw [show ((hpu.unit : PowerSeries ℂ)) = x.powerSeriesPart from rfl]
  rw [LaurentSeries.ofPowerSeries_powerSeriesPart]
  rw [show Multiplicative.toAdd (Multiplicative.ofAdd x.order) = x.order from rfl]
  rw [mul_comm, ← mul_assoc, HahnSeries.single_mul_single, add_neg_cancel, mul_one,
    single_zero_one, one_mul]

/-- **Splitting theorem.** `ℂ⟦X⟧ˣ × Multiplicative ℤ ≃* ℂ⸨X⸩ˣ`: every Laurent unit
is uniquely a unit power series times a power of `q`.  The pole-order obstruction
of cycles 1–2 is precisely the `ℤ`-coordinate of this decomposition. -/
noncomputable def laurentUnitsEquiv :
    (PowerSeries ℂ)ˣ × Multiplicative ℤ ≃* (LC)ˣ :=
  MulEquiv.ofBijective unitsCompare ⟨unitsCompare_injective, unitsCompare_surjective⟩

@[simp] theorem laurentUnitsEquiv_apply (p : (PowerSeries ℂ)ˣ) (k : Multiplicative ℤ) :
    laurentUnitsEquiv (p, k) = psUnitHom p * qPowHom k := rfl

/-- The splitting is compatible with the order homomorphism: the `ℤ`-coordinate is
recovered by `orderMonoidHom`.  Hence the exact sequence
`1 → ℂ⟦X⟧ˣ → ℂ⸨X⸩ˣ → ℤ → 0` splits. -/
theorem orderMonoidHom_laurentUnitsEquiv (p : (PowerSeries ℂ)ˣ) (k : Multiplicative ℤ) :
    orderMonoidHom (laurentUnitsEquiv (p, k)) = k :=
  order_unitsCompare p k

/-- The order homomorphism is a retraction of `qPowHom`: `order (q ^ k) = k`. -/
theorem orderMonoidHom_qPowHom (k : Multiplicative ℤ) :
    orderMonoidHom (qPowHom k) = k := order_qPowHom k

/-! ## 2. Kernel of the order map and completeness of the invariant -/

/-- **Kernel description.** A Laurent unit has order `0` exactly when it is the
image of a unit power series. -/
theorem order_eq_zero_iff_exists_psUnit (u : (LC)ˣ) :
    (u : LC).order = 0 ↔ ∃ p : (PowerSeries ℂ)ˣ, psUnitHom p = u := by
  constructor
  · intro h
    obtain ⟨⟨p, k⟩, rfl⟩ := unitsCompare_surjective u
    have hk : Multiplicative.toAdd k = 0 := by
      rw [← order_unitsCompare p k]; exact h.symm ▸ rfl
    have hk' : k = 1 := hk
    subst hk'
    exact ⟨p, by simp⟩
  · rintro ⟨p, rfl⟩
    exact order_psUnitHom p

/-- The kernel of `orderMonoidHom` is exactly the range of `ℂ⟦X⟧ˣ`. -/
theorem ker_orderMonoidHom : orderMonoidHom.ker = psUnitHom.range := by
  ext u
  rw [MonoidHom.mem_ker, MonoidHom.mem_range, ← order_eq_zero_iff_exists_psUnit]
  constructor
  · intro h
    simpa using congrArg Multiplicative.toAdd h
  · intro h
    rw [orderMonoidHom_apply, h]
    rfl

/-- **Completeness of the pole-order invariant.** Two Laurent units differ by
multiplication by a unit power series iff they have the same order.  Thus
`ℂ⸨X⸩ˣ / ℂ⟦X⟧ˣ ≅ ℤ`, and the order is a complete invariant of the coset. -/
theorem exists_unitMul_iff_order_eq (u v : (LC)ˣ) :
    (∃ p : (PowerSeries ℂ)ˣ, u = psUnitHom p * v) ↔ (u : LC).order = (v : LC).order := by
  constructor
  · rintro ⟨p, rfl⟩
    rw [Units.val_mul, order_mul_of_ne_zero' (psUnitHom p).ne_zero v.ne_zero,
      order_psUnitHom, zero_add]
  · intro h
    have hmem : ((u * v⁻¹ : (LC)ˣ) : LC).order = 0 := by
      rw [Units.val_mul, order_mul_of_ne_zero' u.ne_zero (v⁻¹ : (LC)ˣ).ne_zero, h]
      have hvv : ((v * v⁻¹ : (LC)ˣ) : LC).order = 0 := by simp
      rw [Units.val_mul, order_mul_of_ne_zero' v.ne_zero (v⁻¹ : (LC)ˣ).ne_zero] at hvv
      exact hvv
    obtain ⟨p, hp⟩ := (order_eq_zero_iff_exists_psUnit _).mp hmem
    exact ⟨p, by rw [hp]; group⟩

/-! ## 3. The cryptographic reading: pole leak, blinding, one-time shift -/

/-- The *pole leak* of a Laurent unit: its order.  Positive values mean a zero at
`q = 0`, negative values a pole. -/
noncomputable def poleLeak (u : (LC)ˣ) : ℤ := (u : LC).order

@[simp] theorem poleLeak_mul (u v : (LC)ˣ) : poleLeak (u * v) = poleLeak u + poleLeak v :=
  order_mul_of_ne_zero' u.ne_zero v.ne_zero

@[simp] theorem poleLeak_psUnitHom (p : (PowerSeries ℂ)ˣ) : poleLeak (psUnitHom p) = 0 :=
  order_psUnitHom p

@[simp] theorem poleLeak_qPowHom (k : ℤ) :
    poleLeak (qPowHom (Multiplicative.ofAdd k)) = k := order_qPowHom _

/-- **Blinding invariance.** Multiplying by any invertible power series leaves the
leak unchanged: no power-series blinding can hide the pole. -/
@[simp] theorem poleLeak_mul_psUnitHom (u : (LC)ˣ) (p : (PowerSeries ℂ)ˣ) :
    poleLeak (u * psUnitHom p) = poleLeak u := by
  rw [poleLeak_mul, poleLeak_psUnitHom, add_zero]

/-- Conversely, the subgroup of `ℂ⸨X⸩ˣ` fixing the leak *is* exactly `ℂ⟦X⟧ˣ`. -/
theorem poleLeak_mul_eq_iff (u w : (LC)ˣ) :
    poleLeak (u * w) = poleLeak u ↔ ∃ p : (PowerSeries ℂ)ˣ, w = psUnitHom p := by
  rw [poleLeak_mul]
  constructor
  · intro h
    have hw : (w : LC).order = 0 := by
      have : poleLeak w = 0 := by omega
      exact this
    obtain ⟨p, hp⟩ := (order_eq_zero_iff_exists_psUnit w).mp hw
    exact ⟨p, hp.symm⟩
  · rintro ⟨p, rfl⟩
    rw [poleLeak_psUnitHom, add_zero]

/-- Shifting by `q ^ k` moves the leak by exactly `k`. -/
theorem poleLeak_mul_qPowHom (u : (LC)ˣ) (k : ℤ) :
    poleLeak (u * qPowHom (Multiplicative.ofAdd k)) = poleLeak u + k := by
  rw [poleLeak_mul, poleLeak_qPowHom]

/-- **One-time-pad property.** For every target leak value there is a *unique*
monomial shift achieving it. -/
theorem existsUnique_shift_poleLeak (u : (LC)ˣ) (t : ℤ) :
    ∃! k : ℤ, poleLeak (u * qPowHom (Multiplicative.ofAdd k)) = t := by
  refine ⟨t - poleLeak u, ?_, ?_⟩
  · show poleLeak (u * qPowHom (Multiplicative.ofAdd (t - poleLeak u))) = t
    rw [poleLeak_mul_qPowHom]; ring
  · intro k hk
    rw [poleLeak_mul_qPowHom] at hk
    omega

/-! ## 4. A Newton identity in every degree -/

/-- **General coefficient formula.** For a product of `m` normalized series, the
Laurent coefficient at degree `n - m` is the full `n`-th convolution of the
coefficient sequences, shifted by one.  Cycle 1's subleading identity is `n = 1`,
cycle 2's sub-subleading identity is `n = 2`. -/
theorem coeff_prod_normalized_general {ι : Type*} [DecidableEq ι] (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (n : ℕ) :
    (∏ i ∈ s, f i).coeff ((n : ℤ) - (s.card : ℤ))
      = ∑ l ∈ s.finsuppAntidiag n, ∏ i ∈ s, (f i).coeff ((l i : ℤ) - 1) := by
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff (n : ℤ)
      = PowerSeries.coeff n (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) n
  rw [ofPowerSeries_prod_normalizedPart s f h, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  rw [hcoe, PowerSeries.coeff_prod]
  refine Finset.sum_congr rfl (fun l _ => Finset.prod_congr rfl (fun i hi => ?_))
  exact coeff_normalizedPart (h i hi) (l i)

/-! ## 5. Monster specializations -/

/-- The Monstrous-Moonshine-sized product, as a unit of `ℂ⸨X⸩`. -/
noncomputable def monsterUnit (c : Fin monsterClassCount → ℕ → ℂ) : (LC)ˣ :=
  Units.mk0 (∏ i, traceLaurent (c i))
    (prod_normalized_ne_zero Finset.univ _ (fun i _ => isNormalized_traceLaurent (c i)))

/-- **The Monster class in `ℂ⸨X⸩ˣ / ℂ⟦X⟧ˣ ≅ ℤ` is `-194`.** -/
theorem poleLeak_monsterUnit (c : Fin monsterClassCount → ℕ → ℂ) :
    poleLeak (monsterUnit c) = -194 := by
  have h := order_prod_normalized Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  simpa [poleLeak, monsterUnit, monsterClassCount] using h

/-- **Blinding cannot remove the Monster pole.** For every unit power series `p`
the blinded product still has leak `-194`. -/
theorem poleLeak_monsterUnit_blinded (c : Fin monsterClassCount → ℕ → ℂ)
    (p : (PowerSeries ℂ)ˣ) : poleLeak (monsterUnit c * psUnitHom p) = -194 := by
  rw [poleLeak_mul_psUnitHom, poleLeak_monsterUnit]

/-- `q ^ 194` is the unique monomial shift making the Monster product a unit power
series. -/
theorem existsUnique_shift_monsterUnit (c : Fin monsterClassCount → ℕ → ℂ) :
    ∃! k : ℤ, ∃ p : (PowerSeries ℂ)ˣ,
      monsterUnit c * qPowHom (Multiplicative.ofAdd k) = psUnitHom p := by
  refine ⟨194, ?_, ?_⟩
  · have h0 : ((monsterUnit c * qPowHom (Multiplicative.ofAdd (194 : ℤ)) : (LC)ˣ) : LC).order
        = 0 := by
      have := poleLeak_mul_qPowHom (monsterUnit c) 194
      rw [poleLeak_monsterUnit] at this
      simpa [poleLeak] using this
    obtain ⟨p, hp⟩ := (order_eq_zero_iff_exists_psUnit _).mp h0
    exact ⟨p, hp.symm⟩
  · rintro k ⟨p, hp⟩
    have h1 : poleLeak (monsterUnit c * qPowHom (Multiplicative.ofAdd k)) = 0 := by
      rw [hp, poleLeak_psUnitHom]
    rw [poleLeak_mul_qPowHom, poleLeak_monsterUnit] at h1
    omega

/-- The general Newton identity, specialized to the Monster: the coefficient of
the moonshine product at degree `n - 194`. -/
theorem coeff_prod_traceLaurent_194_general (c : Fin monsterClassCount → ℕ → ℂ) (n : ℕ) :
    (∏ i, traceLaurent (c i)).coeff ((n : ℤ) - 194)
      = ∑ l ∈ (Finset.univ : Finset (Fin monsterClassCount)).finsuppAntidiag n,
          ∏ i, (traceLaurent (c i)).coeff ((l i : ℤ) - 1) := by
  have h := coeff_prod_normalized_general (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i)) n
  simpa [monsterClassCount] using h

end PoleOrderSplitting