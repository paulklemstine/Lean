import Mathlib
import Shared.PoleOrderObstruction

/-!
# Cycle 7: the pole filtration and a Riemann–Roch style dimension count

Earlier cycles measured the pole-order obstruction *multiplicatively*: the order
of a product of `m` normalized `q`-series is exactly `-m`
(`PoleOrderObstruction.orderTop_prod_normalized`), the pole order is the
complete obstruction to extracting `n`-th roots
(`PoleOrderObstruction.exists_pow_eq_iff_dvd_order`), and it classifies power
classes (`PoleOrderObstruction.unitsModPowEquiv`).

This file studies the same invariant *linearly*.  The sets

`poleSpace m = {x : ℂ⸨q⸩ | x.coeff n = 0 for all n < -m}`

form an increasing filtration of `ℂ⸨q⸩` by `ℂ`-subspaces, `poleSpace 0` being
the subspace of honest power series.  Passing to the quotient `ℂ⸨q⸩ / poleSpace 0`
— the space of *principal parts* — the image of `poleSpace m` is exactly
`m`-dimensional:

* `PoleOrderObstruction.polePartEquiv` — `(Fin m → ℂ) ≃ₗ[ℂ] polePartSpace m`,
  the isomorphism sending a vector to the Laurent polynomial
  `c₀ q⁻¹ + c₁ q⁻² + ⋯ + c_{m-1} q^{-m}`;
* `PoleOrderObstruction.finrank_polePartSpace` — hence `finrank = m`;
* `PoleOrderObstruction.finrank_gradedPiece` — each graded piece
  `poleSpace (m+1) / poleSpace m` is one-dimensional, so the filtration jumps by
  exactly one dimension per unit of pole order.

This is the formal-Laurent shadow of the Riemann–Roch dimension count
`ℓ(D) - ℓ(D - P) ≤ 1` for divisors supported at a single point: the pole-order
obstruction of a product of `m` normalized series is not just a number, it is a
vector in an `m`-dimensional space, and pole order is the position of that
vector in the filtration.

Specialising to the Monster: the product of the `194` McKay–Thompson-shaped
series lies in `poleSpace 194` but not in `poleSpace 193`
(`PoleOrderObstruction.prod_traceLaurent_194_notMem_poleSpace_193`), and its
principal-part vector has deepest coordinate `1`
(`PoleOrderObstruction.principalPart_prod_traceLaurent_194_top`), so it occupies
the top graded piece of the filtration exactly.
-/

namespace PoleOrderObstruction

open HahnSeries Finset

/-! ## Coefficient functionals -/

/-- The `n`-th coefficient of a Laurent series, as a `ℂ`-linear functional. -/
noncomputable def coeffLin (n : ℤ) : LC →ₗ[ℂ] ℂ where
  toFun x := x.coeff n
  map_add' := by intro x y; simp
  map_smul' := by intro c x; simp

@[simp] theorem coeffLin_apply (n : ℤ) (x : LC) : coeffLin n x = x.coeff n := rfl

/-! ## The pole filtration -/

/-- `poleSpace m` is the `ℂ`-subspace of Laurent series with at most a pole of
order `m` at `q = 0`: all coefficients in degrees `< -m` vanish. -/
noncomputable def poleSpace (m : ℕ) : Submodule ℂ LC where
  carrier := {x : LC | ∀ n : ℤ, n < -(m : ℤ) → x.coeff n = 0}
  add_mem' := by intro x y hx hy n hn; simp [hx n hn, hy n hn]
  zero_mem' := by intro n _; simp
  smul_mem' := by intro c x hx n hn; simp [hx n hn]

theorem mem_poleSpace_iff (m : ℕ) (x : LC) :
    x ∈ poleSpace m ↔ ∀ n : ℤ, n < -(m : ℤ) → x.coeff n = 0 := Iff.rfl

/-- The filtration is increasing. -/
theorem poleSpace_mono {m k : ℕ} (h : m ≤ k) : poleSpace m ≤ poleSpace k := by
  intro x hx n hn
  have : (m : ℤ) ≤ (k : ℤ) := by exact_mod_cast h
  exact hx n (by omega)

/-- `poleSpace 0` consists exactly of the series with no pole. -/
theorem mem_poleSpace_zero_iff (x : LC) :
    x ∈ poleSpace 0 ↔ ∀ n : ℤ, n < 0 → x.coeff n = 0 := by
  simp [mem_poleSpace_iff]

/-- Membership in `poleSpace m` is exactly the valuation condition
`-m ≤ orderTop x`, linking the linear filtration to the multiplicative theory. -/
theorem mem_poleSpace_iff_orderTop (m : ℕ) (x : LC) :
    x ∈ poleSpace m ↔ ((-(m : ℤ) : ℤ) : WithTop ℤ) ≤ x.orderTop := by
  constructor
  · intro hx
    by_contra hcon
    push_neg at hcon
    have hx0 : x ≠ 0 := by
      rintro rfl
      simp at hcon
    have hord : ((x.order : ℤ) : WithTop ℤ) = x.orderTop :=
      HahnSeries.order_eq_orderTop_of_ne_zero hx0
    rw [← hord] at hcon
    have hlt : x.order < -(m : ℤ) := by exact_mod_cast hcon
    exact hx0 (HahnSeries.coeff_order_eq_zero.mp (hx _ hlt))
  · intro hx n hn
    refine HahnSeries.coeff_eq_zero_of_lt_orderTop (lt_of_lt_of_le ?_ hx)
    exact_mod_cast hn

/-- A normalized series lies in `poleSpace 1`. -/
theorem isNormalized_mem_poleSpace_one {f : LC} (h : IsNormalized f) :
    f ∈ poleSpace 1 := by
  intro n hn
  exact h.coeff_eq_zero_of_lt n (by exact_mod_cast hn)

/-- A product of `m` normalized series lies in `poleSpace m` — the linear form of
the pole-order obstruction. -/
theorem prod_normalized_mem_poleSpace {ι : Type*} (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i) ∈ poleSpace s.card := by
  rw [mem_poleSpace_iff_orderTop, orderTop_prod_normalized s f h]

/-- The pole filtration is multiplicative: pole orders add under multiplication.
This is the compatibility that makes the filtration of the next sections a
filtration of `ℂ⸨q⸩` as an algebra, not merely as a vector space. -/
theorem poleSpace_mul_mem (a b : ℕ) {x y : LC} (hx : x ∈ poleSpace a)
    (hy : y ∈ poleSpace b) : x * y ∈ poleSpace (a + b) := by
  rw [mem_poleSpace_iff_orderTop] at hx hy ⊢
  rw [HahnSeries.orderTop_mul]
  have h := add_le_add hx hy
  rw [← WithTop.coe_add] at h
  convert h using 2
  push_cast
  ring

/-! ## Principal parts -/

/-- The principal part of a Laurent series: its coefficients in degrees
`-1, -2, …, -m`, as a `ℂ`-linear map. -/
noncomputable def principalPart (m : ℕ) : LC →ₗ[ℂ] (Fin m → ℂ) :=
  LinearMap.pi fun i : Fin m => coeffLin (-(i : ℤ) - 1)

@[simp] theorem principalPart_apply (m : ℕ) (x : LC) (i : Fin m) :
    principalPart m x i = x.coeff (-(i : ℤ) - 1) := rfl

/-- The Laurent polynomial `c₀ q⁻¹ + c₁ q⁻² + ⋯ + c_{m-1} q^{-m}` with prescribed
principal part, as a `ℂ`-linear map. -/
noncomputable def principalPartLift (m : ℕ) : (Fin m → ℂ) →ₗ[ℂ] LC where
  toFun c := ∑ i : Fin m, HahnSeries.single (-(i : ℤ) - 1) (c i)
  map_add' a b := by simp [HahnSeries.single_add, Finset.sum_add_distrib]
  map_smul' r a := by
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.smul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    ext n
    simp [HahnSeries.coeff_single]

theorem coeff_principalPartLift (m : ℕ) (c : Fin m → ℂ) (n : ℤ) :
    (principalPartLift m c).coeff n
      = ∑ i : Fin m, if n = -(i : ℤ) - 1 then c i else 0 := by
  simp only [principalPartLift, LinearMap.coe_mk, AddHom.coe_mk, HahnSeries.coeff_sum,
    HahnSeries.coeff_single]
  exact Finset.sum_congr rfl fun i _ => by congr 1

theorem coeff_principalPartLift_index (m : ℕ) (c : Fin m → ℂ) (j : Fin m) :
    (principalPartLift m c).coeff (-(j : ℤ) - 1) = c j := by
  classical
  rw [coeff_principalPartLift, Finset.sum_eq_single j]
  · simp
  · intro i _ hij
    have h : ¬ ((-(j : ℤ) - 1) = -(i : ℤ) - 1) := by
      intro h
      exact hij (Fin.ext (by omega))
    simp [h]
  · intro h; exact absurd (Finset.mem_univ j) h

theorem principalPartLift_mem (m : ℕ) (c : Fin m → ℂ) :
    principalPartLift m c ∈ poleSpace m := by
  intro n hn
  rw [coeff_principalPartLift]
  refine Finset.sum_eq_zero fun i _ => ?_
  have hi : (i : ℤ) < (m : ℤ) := by exact_mod_cast i.isLt
  have : n ≠ -(i : ℤ) - 1 := by omega
  simp [this]

@[simp] theorem principalPart_principalPartLift (m : ℕ) (c : Fin m → ℂ) :
    principalPart m (principalPartLift m c) = c := by
  funext j
  rw [principalPart_apply, coeff_principalPartLift_index]

/-- Subtracting its principal-part polynomial removes the pole of a series in
`poleSpace m`. -/
theorem sub_principalPartLift_mem (m : ℕ) {x : LC} (hx : x ∈ poleSpace m) :
    x - principalPartLift m (principalPart m x) ∈ poleSpace 0 := by
  rw [mem_poleSpace_zero_iff]
  intro n hn
  by_cases hnm : n < -(m : ℤ)
  · have h1 : x.coeff n = 0 := hx n hnm
    have h2 : (principalPartLift m (principalPart m x)).coeff n = 0 :=
      principalPartLift_mem m _ n hnm
    simp [h1, h2]
  · have hlt : (-n - 1).toNat < m := by omega
    let j : Fin m := ⟨(-n - 1).toNat, hlt⟩
    have hj : -(j : ℤ) - 1 = n := by
      have : ((j : ℕ) : ℤ) = -n - 1 := Int.toNat_of_nonneg (by omega)
      omega
    have h2 : (principalPartLift m (principalPart m x)).coeff n = x.coeff n := by
      rw [← hj, coeff_principalPartLift_index, principalPart_apply]
    simp [h2]

/-! ## The space of principal parts is `m`-dimensional -/

/-- The image of `poleSpace m` in the quotient `ℂ⸨q⸩ / poleSpace 0`: the space of
principal parts of pole order at most `m`. -/
noncomputable def polePartSpace (m : ℕ) : Submodule ℂ (LC ⧸ poleSpace 0) :=
  Submodule.map (poleSpace 0).mkQ (poleSpace m)

/-- The tautological parametrisation of principal parts by vectors. -/
noncomputable def polePartMap (m : ℕ) : (Fin m → ℂ) →ₗ[ℂ] (LC ⧸ poleSpace 0) :=
  (poleSpace 0).mkQ.comp (principalPartLift m)

theorem polePartMap_injective (m : ℕ) : Function.Injective (polePartMap m) := by
  rw [injective_iff_map_eq_zero]
  intro c hc
  have hmem : principalPartLift m c ∈ poleSpace 0 := by
    have := (Submodule.Quotient.mk_eq_zero (poleSpace 0)).mp hc
    exact this
  funext i
  have hi : (-(i : ℤ) - 1) < 0 := by omega
  have := (mem_poleSpace_zero_iff _).mp hmem _ hi
  rw [coeff_principalPartLift_index] at this
  simpa using this

theorem range_polePartMap (m : ℕ) :
    LinearMap.range (polePartMap m) = polePartSpace m := by
  apply le_antisymm
  · rintro y ⟨c, rfl⟩
    exact ⟨principalPartLift m c, principalPartLift_mem m c, rfl⟩
  · rintro y ⟨x, hx, rfl⟩
    refine ⟨principalPart m x, ?_⟩
    have hsub : principalPartLift m (principalPart m x) - x ∈ poleSpace 0 := by
      have := sub_principalPartLift_mem m hx
      simpa using (neg_mem this)
    exact (Submodule.Quotient.eq _).mpr hsub

/-- **Riemann–Roch style isomorphism.** Principal parts of pole order at most `m`
are parametrised faithfully by `m` complex numbers. -/
noncomputable def polePartEquiv (m : ℕ) : (Fin m → ℂ) ≃ₗ[ℂ] polePartSpace m :=
  (LinearEquiv.ofInjective _ (polePartMap_injective m)).trans
    (LinearEquiv.ofEq _ _ (range_polePartMap m))

/-- The dimension count: the space of principal parts of pole order at most `m`
has dimension exactly `m`. -/
theorem finrank_polePartSpace (m : ℕ) :
    Module.finrank ℂ (polePartSpace m) = m := by
  rw [← (polePartEquiv m).finrank_eq, Module.finrank_fin_fun]

/-! ## The graded pieces are one-dimensional -/

/-- The `m`-th graded piece of the pole filtration, realised inside
`ℂ⸨q⸩ / poleSpace m`. -/
noncomputable def gradedPiece (m : ℕ) : Submodule ℂ (LC ⧸ poleSpace m) :=
  Submodule.map (poleSpace m).mkQ (poleSpace (m + 1))

/-- The parametrisation of the `m`-th graded piece by the coefficient of
`q^{-(m+1)}`. -/
noncomputable def gradedPieceMap (m : ℕ) : ℂ →ₗ[ℂ] (LC ⧸ poleSpace m) :=
  (poleSpace m).mkQ.comp
    (LinearMap.toSpanSingleton ℂ LC (HahnSeries.single (-(m : ℤ) - 1) (1 : ℂ)))

theorem gradedPieceMap_apply (m : ℕ) (c : ℂ) :
    gradedPieceMap m c = (poleSpace m).mkQ (HahnSeries.single (-(m : ℤ) - 1) c) := by
  have : c • (HahnSeries.single (-(m : ℤ) - 1) (1 : ℂ) : LC)
      = HahnSeries.single (-(m : ℤ) - 1) c := by
    ext n
    simp [HahnSeries.coeff_single]
  simp [gradedPieceMap, LinearMap.toSpanSingleton_apply, this]

theorem single_neg_succ_mem (m : ℕ) (c : ℂ) :
    (HahnSeries.single (-(m : ℤ) - 1) c : LC) ∈ poleSpace (m + 1) := by
  intro n hn
  have : n ≠ -(m : ℤ) - 1 := by push_cast at hn; omega
  simp [this]

theorem gradedPieceMap_injective (m : ℕ) : Function.Injective (gradedPieceMap m) := by
  rw [injective_iff_map_eq_zero]
  intro c hc
  rw [gradedPieceMap_apply] at hc
  have hmem : (HahnSeries.single (-(m : ℤ) - 1) c : LC) ∈ poleSpace m :=
    (Submodule.Quotient.mk_eq_zero (poleSpace m)).mp hc
  have := hmem (-(m : ℤ) - 1) (by omega)
  simpa [HahnSeries.coeff_single] using this

theorem range_gradedPieceMap (m : ℕ) :
    LinearMap.range (gradedPieceMap m) = gradedPiece m := by
  apply le_antisymm
  · rintro y ⟨c, rfl⟩
    exact ⟨HahnSeries.single (-(m : ℤ) - 1) c, single_neg_succ_mem m c,
      (gradedPieceMap_apply m c).symm ▸ rfl⟩
  · rintro y ⟨x, hx, rfl⟩
    refine ⟨x.coeff (-(m : ℤ) - 1), ?_⟩
    rw [gradedPieceMap_apply]
    refine (Submodule.Quotient.eq _).mpr ?_
    intro n hn
    by_cases hnm : n < -((m : ℤ) + 1)
    · have h1 : x.coeff n = 0 := hx n (by push_cast; omega)
      have h2 : (HahnSeries.single (-(m : ℤ) - 1) (x.coeff (-(m : ℤ) - 1)) : LC).coeff n = 0 := by
        have : n ≠ -(m : ℤ) - 1 := by omega
        simp [this]
      simp [h1, h2]
    · have hn' : n = -(m : ℤ) - 1 := by omega
      subst hn'
      simp

/-- Each graded piece of the pole filtration is one-dimensional: pole order
increases the dimension of the principal-part space by exactly one. -/
theorem finrank_gradedPiece (m : ℕ) : Module.finrank ℂ (gradedPiece m) = 1 := by
  have e : ℂ ≃ₗ[ℂ] gradedPiece m :=
    (LinearEquiv.ofInjective _ (gradedPieceMap_injective m)).trans
      (LinearEquiv.ofEq _ _ (range_gradedPieceMap m))
  rw [← e.finrank_eq, Module.finrank_self]

/-! ## The Monster-sized product in the filtration -/

/-- The Monster-sized product of `194` normalized series lies in `poleSpace 194`. -/
theorem prod_traceLaurent_194_mem_poleSpace (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i)) ∈ poleSpace 194 := by
  rw [mem_poleSpace_iff_orderTop, orderTop_prod_traceLaurent_194 c]
  norm_num

theorem coeff_prod_traceLaurent_194_deep (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i)).coeff (-194) = 1 := by
  have hord : (∏ i, traceLaurent (c i)).order = -194 := by
    have := order_prod_normalized (Finset.univ : Finset (Fin monsterClassCount))
      (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i))
    simpa [monsterClassCount] using this
  have hlead := leadingCoeff_prod_traceLaurent_194 c
  rw [HahnSeries.leadingCoeff_eq, hord] at hlead
  exact hlead

/-- The deepest coordinate of the principal part of the Monster-sized product
equals `1`. -/
theorem principalPart_prod_traceLaurent_194_top (c : Fin monsterClassCount → ℕ → ℂ) :
    principalPart 194 (∏ i, traceLaurent (c i)) ⟨193, by norm_num⟩ = 1 := by
  rw [principalPart_apply]
  have : (-(((⟨193, by norm_num⟩ : Fin 194) : ℕ) : ℤ) - 1) = -194 := by norm_num
  rw [this]
  exact coeff_prod_traceLaurent_194_deep c

/-- **The Monster-sized product occupies the top graded piece.** It lies in
`poleSpace 194` but not in `poleSpace 193`: its principal part is a nonzero
vector in the `194`-dimensional space `polePartSpace 194`, with nonzero deepest
coordinate. -/
theorem prod_traceLaurent_194_notMem_poleSpace_193 (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i)) ∈ poleSpace 194 ∧
      (∏ i, traceLaurent (c i)) ∉ poleSpace 193 := by
  refine ⟨prod_traceLaurent_194_mem_poleSpace c, fun hmem => ?_⟩
  have h0 : (∏ i, traceLaurent (c i)).coeff (-194) = 0 := hmem (-194) (by norm_num)
  have h1 := coeff_prod_traceLaurent_194_deep c
  rw [h0] at h1
  exact zero_ne_one h1

/-- The Monster-sized product has a nonzero class in the `194`-dimensional space
of principal parts, and that space is exactly `194`-dimensional. -/
theorem monster_polePartSpace (c : Fin monsterClassCount → ℕ → ℂ) :
    Module.finrank ℂ (polePartSpace 194) = 194 ∧
      (poleSpace 0).mkQ (∏ i, traceLaurent (c i)) ≠ 0 := by
  refine ⟨finrank_polePartSpace 194, fun h => ?_⟩
  have hmem : (∏ i, traceLaurent (c i)) ∈ poleSpace 0 :=
    (Submodule.Quotient.mk_eq_zero (poleSpace 0)).mp h
  have h0 : (∏ i, traceLaurent (c i)).coeff (-194) = 0 :=
    (mem_poleSpace_zero_iff _).mp hmem (-194) (by norm_num)
  rw [coeff_prod_traceLaurent_194_deep c] at h0
  exact one_ne_zero h0

end PoleOrderObstruction