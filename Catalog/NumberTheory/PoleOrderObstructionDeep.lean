import Mathlib
import Catalog.Shared.PoleOrderObstruction

/-!
# Deepening the pole-order obstruction

This file is the second research cycle built on `Shared.PoleOrderObstruction`.
Where the first cycle established that a product of `m` normalized `q`-series
has `orderTop` exactly `-m`, this file explains *why* that is the only possible
answer, by exhibiting the underlying structure:

1. **Valuation additivity in full generality**
   (`PoleOrderObstruction.orderTop_prod`): `orderTop` of any finite product of
   Laurent series over `ℂ` is the sum of the `orderTop`s, in `WithTop ℤ`.  The
   pole-order theorem of cycle 1 is the special case where every summand is `-1`.

2. **A group-theoretic reformulation**
   (`PoleOrderObstruction.orderMonoidHom`): the order defines a surjective group
   homomorphism `ℂ⸨X⸩ˣ →* Multiplicative ℤ`.  The pole-order obstruction is the
   statement that a Monster-sized product sits in the fibre over `-194`, and
   fibres are disjoint — this is what makes the obstruction *complete* rather
   than merely a bound.

3. **A unique factorization theorem for normalized series**
   (`PoleOrderObstruction.exists_unique_unit_factorization`): every normalized
   series factors *uniquely* as `q⁻¹ · u` with `u ∈ ℂ⟦X⟧` of constant term `1`,
   and consequently a product of `m` of them factors as `q^{-m} · ∏ uᵢ`
   (`PoleOrderObstruction.prod_normalized_factorization`).  This upgrades the
   valuation statement to an exact structural decomposition.

4. **Newton-type coefficient identities**.  Cycle 1 computed the subleading
   Laurent coefficient.  Here we compute the next one
   (`PoleOrderObstruction.coeff_prod_normalized_subsubleading`): the coefficient
   at degree `2 - m` obeys a Newton-style identity involving the square of the
   sum of constant terms minus the sum of their squares — the second elementary
   symmetric function in disguise.

Everything is proved for a general finite index type and then specialized to the
`194` conjugacy classes of the Monster.
-/

namespace PoleOrderObstruction

open HahnSeries Finset

variable {ι : Type*}

/-! ## 1. Valuation additivity in full generality -/

/-- `orderTop` turns finite products of Laurent series into finite sums in
`WithTop ℤ`.  No nonvanishing hypothesis is needed: `⊤` absorbs. -/
theorem orderTop_prod (s : Finset ι) (f : ι → LC) :
    (∏ i ∈ s, f i).orderTop = ∑ i ∈ s, (f i).orderTop := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha, HahnSeries.orderTop_mul, ih]

/-- If each factor has a prescribed finite order `d i`, the product has order
`∑ d i`. -/
theorem orderTop_prod_of_orderTop_eq (s : Finset ι) (f : ι → LC) (d : ι → ℤ)
    (h : ∀ i ∈ s, (f i).orderTop = ((d i : ℤ) : WithTop ℤ)) :
    (∏ i ∈ s, f i).orderTop = ((∑ i ∈ s, d i : ℤ) : WithTop ℤ) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, HahnSeries.orderTop_mul,
        h a (Finset.mem_insert_self a s), ih (fun i hi => h i (Finset.mem_insert_of_mem hi)),
        ← WithTop.coe_add, Finset.sum_insert ha]

/-- Cycle 1's pole-order theorem, recovered from the general additivity
statement. -/
theorem orderTop_prod_normalized' (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i).orderTop = ((-(s.card : ℤ) : ℤ) : WithTop ℤ) := by
  rw [orderTop_prod_of_orderTop_eq s f (fun _ => -1) (fun i hi => (h i hi).orderTop_eq)]
  simp

/-! ## 2. The order as a surjective group homomorphism -/

theorem order_mul_of_ne_zero' {x y : LC} (hx : x ≠ 0) (hy : y ≠ 0) :
    (x * y).order = x.order + y.order := by
  have hxy : x * y ≠ 0 := mul_ne_zero hx hy
  have h := HahnSeries.orderTop_mul (R := ℂ) x y
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hx,
    ← HahnSeries.order_eq_orderTop_of_ne_zero hy,
    ← HahnSeries.order_eq_orderTop_of_ne_zero hxy, ← WithTop.coe_add] at h
  exact_mod_cast h

/-- The order of an invertible Laurent series, packaged as a group homomorphism
to `Multiplicative ℤ`. -/
noncomputable def orderMonoidHom : (LC)ˣ →* Multiplicative ℤ where
  toFun u := Multiplicative.ofAdd ((u : LC).order)
  map_one' := by simp
  map_mul' u v := by
    have hu : (u : LC) ≠ 0 := u.ne_zero
    have hv : (v : LC) ≠ 0 := v.ne_zero
    simp only [Units.val_mul, order_mul_of_ne_zero' hu hv]
    rfl

@[simp] theorem orderMonoidHom_apply (u : (LC)ˣ) :
    orderMonoidHom u = Multiplicative.ofAdd ((u : LC).order) := rfl

/-- `single k 1` is invertible in `ℂ⸨X⸩`, with inverse `single (-k) 1`. -/
noncomputable def singleUnit (k : ℤ) : (LC)ˣ where
  val := HahnSeries.single k (1 : ℂ)
  inv := HahnSeries.single (-k) (1 : ℂ)
  val_inv := by rw [HahnSeries.single_mul_single, add_neg_cancel, mul_one, single_zero_one]
  inv_val := by rw [HahnSeries.single_mul_single, neg_add_cancel, mul_one, single_zero_one]

@[simp] theorem singleUnit_val (k : ℤ) : (singleUnit k : LC) = HahnSeries.single k (1 : ℂ) := rfl

/-- **The order is a surjective group homomorphism.**  Every integer, in
particular every pole order, is realized. -/
theorem orderMonoidHom_surjective : Function.Surjective orderMonoidHom := by
  intro k
  refine ⟨singleUnit (Multiplicative.toAdd k), ?_⟩
  have hne : HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) ≠ 0 :=
    HahnSeries.single_ne_zero one_ne_zero
  have : (HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) : LC).order
      = Multiplicative.toAdd k := by
    have := HahnSeries.orderTop_single (Γ := ℤ) (a := Multiplicative.toAdd k)
      (one_ne_zero (α := ℂ))
    rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at this
    exact_mod_cast this
  simp [orderMonoidHom, singleUnit, this]

/-- Every normalized series is a unit of `ℂ⸨X⸩`, and its class under the order
homomorphism is `-1`. -/
theorem isUnit_of_isNormalized {f : LC} (h : IsNormalized f) : IsUnit f :=
  isUnit_iff_ne_zero.mpr h.ne_zero

/-- **Completeness of the obstruction, group-theoretically.**  The unit
represented by a product of `m` normalized series lies in the fibre of
`orderMonoidHom` over `-m`, and (fibres being disjoint) in no other fibre. -/
theorem orderMonoidHom_prod_normalized (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    orderMonoidHom (Units.mk0 (∏ i ∈ s, f i) (prod_normalized_ne_zero s f h))
      = Multiplicative.ofAdd (-(s.card : ℤ)) := by
  simp only [orderMonoidHom_apply, Units.val_mk0]
  rw [order_prod_normalized s f h]

/-! ## 3. Unique unit factorization of normalized series -/

/-- **Structure theorem.** A normalized Laurent series is uniquely `q⁻¹` times a
power series with constant term `1`. -/
theorem exists_unique_unit_factorization {f : LC} (h : IsNormalized f) :
    ∃! u : PowerSeries ℂ, PowerSeries.constantCoeff u = 1 ∧
      f = HahnSeries.single (-1 : ℤ) (1 : ℂ) * HahnSeries.ofPowerSeries ℤ ℂ u := by
  refine ⟨normalizedPart f, ⟨constantCoeff_normalizedPart f h, ?_⟩, ?_⟩
  · rw [ofPowerSeries_normalizedPart f h, qSeries, ← mul_assoc,
      HahnSeries.single_mul_single, neg_add_cancel, mul_one, single_zero_one, one_mul]
  · rintro v ⟨-, hv⟩
    apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
    have h1 : HahnSeries.single (1 : ℤ) (1 : ℂ) *
        (HahnSeries.single (-1 : ℤ) (1 : ℂ) * HahnSeries.ofPowerSeries ℤ ℂ v)
        = HahnSeries.ofPowerSeries ℤ ℂ v := by
      rw [← mul_assoc, HahnSeries.single_mul_single, add_neg_cancel, mul_one,
        single_zero_one, one_mul]
    rw [ofPowerSeries_normalizedPart f h, qSeries, ← h1, hv]

/-- **Factorization of the Monster-type product.** A product of `m` normalized
series equals `q^{-m}` times the image of a unit power series, namely the
product of the unit power series attached to the individual factors. -/
theorem prod_normalized_factorization (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i)
      = HahnSeries.single (-(s.card : ℤ)) (1 : ℂ) *
          HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i)) := by
  rw [ofPowerSeries_prod_normalizedPart s f h, qSeries_pow, ← mul_assoc,
    HahnSeries.single_mul_single, neg_add_cancel, mul_one, single_zero_one, one_mul]

/-! ## 4. Newton-type coefficient identities -/

/-- Second coefficient of a product of two power series. -/
theorem coeff_two_mul (a b : PowerSeries ℂ) :
    PowerSeries.coeff 2 (a * b) =
      PowerSeries.constantCoeff a * PowerSeries.coeff 2 b
        + PowerSeries.coeff 1 a * PowerSeries.coeff 1 b
        + PowerSeries.coeff 2 a * PowerSeries.constantCoeff b := by
  have hanti : Finset.antidiagonal (2 : ℕ) = {(0, 2), (1, 1), (2, 0)} := rfl
  rw [PowerSeries.coeff_mul, hanti]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  simp [PowerSeries.coeff_zero_eq_constantCoeff]
  ring

/-- **Newton identity at level 2.**  For power series with constant term `1`, the
quadratic coefficient of a finite product is the sum of the quadratic
coefficients plus the second elementary symmetric function of the linear
coefficients (written without division as `((∑ c)² - ∑ c²)/2`). -/
theorem coeff_two_prod_of_constantCoeff_one (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1) :
    2 * PowerSeries.coeff 2 (∏ i ∈ s, g i) =
      2 * (∑ i ∈ s, PowerSeries.coeff 2 (g i))
        + (∑ i ∈ s, PowerSeries.coeff 1 (g i)) ^ 2
        - ∑ i ∈ s, (PowerSeries.coeff 1 (g i)) ^ 2 := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      have hsub : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1 :=
        fun i hi => h i (Finset.mem_insert_of_mem hi)
      have hconst : PowerSeries.constantCoeff (∏ i ∈ s, g i) = 1 := by
        rw [map_prod, Finset.prod_congr rfl hsub, Finset.prod_const_one]
      have hlin : PowerSeries.coeff 1 (∏ i ∈ s, g i)
          = ∑ i ∈ s, PowerSeries.coeff 1 (g i) :=
        coeff_one_prod_of_constantCoeff_one s g hsub
      have ihs := ih hsub
      rw [Finset.prod_insert ha, coeff_two_mul, hconst, hlin,
        h a (Finset.mem_insert_self a s), Finset.sum_insert ha, Finset.sum_insert ha,
        Finset.sum_insert ha]
      linear_combination ihs

/-- The coefficients of `normalizedPart f` are the coefficients of `f`, shifted
by one. -/
theorem coeff_normalizedPart {f : LC} (h : IsNormalized f) (n : ℕ) :
    PowerSeries.coeff n (normalizedPart f) = f.coeff ((n : ℤ) - 1) := by
  rw [normalizedPart, LaurentSeries.powerSeriesPart_coeff, order_qSeries_mul f h, zero_add,
    qSeries, HahnSeries.coeff_single_mul, one_mul]

/-- **Sub-subleading Laurent coefficient.**  For a product of `m` normalized
series the coefficient at degree `2 - m` satisfies a Newton-type identity in the
constant terms `a₀(fᵢ) = fᵢ.coeff 0` and the linear terms `a₁(fᵢ) = fᵢ.coeff 1`. -/
theorem coeff_prod_normalized_subsubleading (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    2 * (∏ i ∈ s, f i).coeff (2 - (s.card : ℤ)) =
      2 * (∑ i ∈ s, (f i).coeff 1)
        + (∑ i ∈ s, (f i).coeff 0) ^ 2
        - ∑ i ∈ s, ((f i).coeff 0) ^ 2 := by
  classical
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff (2 : ℤ)
      = PowerSeries.coeff 2 (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) 2
  rw [ofPowerSeries_prod_normalizedPart s f h, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  rw [hcoe, coeff_two_prod_of_constantCoeff_one s _
    (fun i hi => constantCoeff_normalizedPart (f i) (h i hi))]
  have h2 : ∀ i ∈ s, PowerSeries.coeff 2 (normalizedPart (f i)) = (f i).coeff 1 := by
    intro i hi
    rw [coeff_normalizedPart (h i hi) 2]
    norm_num
  have h1 : ∀ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i)) = (f i).coeff 0 := by
    intro i hi
    rw [coeff_normalizedPart (h i hi) 1]
    norm_num
  have e2 : ∑ i ∈ s, PowerSeries.coeff 2 (normalizedPart (f i)) = ∑ i ∈ s, (f i).coeff 1 :=
    Finset.sum_congr rfl h2
  have e1 : ∑ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i)) = ∑ i ∈ s, (f i).coeff 0 :=
    Finset.sum_congr rfl h1
  have e1sq : ∑ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i)) ^ 2
      = ∑ i ∈ s, ((f i).coeff 0) ^ 2 :=
    Finset.sum_congr rfl (fun i hi => by rw [h1 i hi])
  rw [e2, e1, e1sq]

/-! ## 5. Specialization to the Monster -/

/-- The Monster-sized product factors as `q^{-194}` times a unit power series. -/
theorem prod_traceLaurent_194_factorization (c : Fin monsterClassCount → ℕ → ℂ) :
    (∏ i, traceLaurent (c i))
      = HahnSeries.single (-194 : ℤ) (1 : ℂ) *
          HahnSeries.ofPowerSeries ℤ ℂ (∏ i, normalizedPart (traceLaurent (c i))) := by
  have := prod_normalized_factorization Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  simpa [monsterClassCount] using this

/-- Sub-subleading coefficient of the Monster-sized product, at degree `-192`. -/
theorem coeff_prod_traceLaurent_194_subsubleading (c : Fin monsterClassCount → ℕ → ℂ) :
    2 * (∏ i, traceLaurent (c i)).coeff (-192 : ℤ) =
      2 * (∑ i, (traceLaurent (c i)).coeff 1)
        + (∑ i, (traceLaurent (c i)).coeff 0) ^ 2
        - ∑ i, ((traceLaurent (c i)).coeff 0) ^ 2 := by
  have := coeff_prod_normalized_subsubleading Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  simpa [monsterClassCount] using this

/-- The first coefficient of `traceLaurent c` is `c 1`. -/
@[simp] theorem coeff_one_traceLaurent (c : ℕ → ℂ) : (traceLaurent c).coeff (1 : ℤ) = c 1 := by
  have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff (1 : ℤ) = c 1 := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk c) 1
  simp [traceLaurent, h1]

/-- **Moonshine normalization, second order.**  If all constant terms vanish
(the standard normalization of McKay–Thompson series `T_g = q⁻¹ + O(q)`), the
Monster-sized product begins
`q⁻¹⁹⁴ + 0·q⁻¹⁹³ + (∑_g c_g(1))·q⁻¹⁹² + ⋯`. -/
theorem coeff_prod_traceLaurent_194_subsubleading_of_normalized
    (c : Fin monsterClassCount → ℕ → ℂ) (hc : ∀ i, c i 0 = 0) :
    (∏ i, traceLaurent (c i)).coeff (-192 : ℤ) = ∑ i, c i 1 := by
  apply mul_left_cancel₀ (a := (2 : ℂ)) two_ne_zero
  rw [coeff_prod_traceLaurent_194_subsubleading c]
  simp [hc]

/-! ## 6. A Lean-verified numerical instance

The Newton identities above are checked here against genuine Monstrous Moonshine
data: the McKay–Thompson series `T_{1A} = J = q⁻¹ + 196884 q + ⋯` and
`T_{2A} = q⁻¹ + 4372 q + ⋯`.  Their product begins at `q⁻²` and its constant
coefficient is `196884 + 4372 = 201256`. -/

/-- Two normalized trace series with vanishing constant terms: the product has a
double pole and its constant Laurent coefficient is the sum of the two linear
coefficients. -/
theorem coeff_zero_prod_two_traceLaurent (c : Fin 2 → ℕ → ℂ) (h0 : ∀ i, c i 0 = 0) :
    (∏ i, traceLaurent (c i)).coeff (0 : ℤ) = c 0 1 + c 1 1 := by
  have key := coeff_prod_normalized_subsubleading Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  simp only [Finset.card_univ, Fintype.card_fin, coeff_zero_traceLaurent,
    coeff_one_traceLaurent, h0, Fin.sum_univ_two] at key
  norm_num at key
  rw [Fin.prod_univ_two]
  exact key

/-- The moonshine instance `J · T_{2A}` : constant coefficient `201256`. -/
theorem coeff_zero_prod_J_mul_T2A :
    (∏ i : Fin 2, traceLaurent
        (![fun n => if n = 1 then (196884 : ℂ) else 0,
           fun n => if n = 1 then (4372 : ℂ) else 0] i)).coeff (0 : ℤ) = 201256 := by
  rw [coeff_zero_prod_two_traceLaurent _ (by intro i; fin_cases i <;> norm_num)]
  norm_num

end PoleOrderObstruction