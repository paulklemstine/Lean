import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep

/-!
# Cycle 3: the pole order as the *complete* root-extraction obstruction

This file is the third research cycle on the pole-order obstruction of
`Shared.PoleOrderObstruction` (products of normalized `q`-series have a pole of
order equal to the number of factors) and `Shared.PoleOrderObstructionDeep`
(valuation additivity, the order homomorphism, unique unit factorization).

Cycle 1 and 2 showed that the pole order `-m` is an *invariant* of a Monster-type
product.  This cycle shows that it is a **complete obstruction for extracting
roots**, and identifies the exact group-theoretic reason:

1. **Splitting of the valuation sequence**
   (`PoleOrderObstruction.laurentUnitsEquiv`): the multiplicative group of
   `ℂ⸨X⸩` splits as `Multiplicative ℤ × ℂ⟦X⟧ˣ`, the first factor being the order.
   Consequently `MonoidHom.ker orderMonoidHom` is exactly the group of unit power
   series (`PoleOrderObstruction.ker_orderMonoidHom`).

2. **Divisibility of unit power series** (`PoleOrderObstruction.exists_pow_eq_of_constantCoeff_one`):
   over `ℂ` every power series with constant term `1` has an `n`-th root with
   constant term `1`, for every `n ≥ 1`.  The proof substitutes `u - 1` into the
   binomial series `(1 + X) ^ (1/n)`; this is where the characteristic-zero and
   algebraically-closed hypotheses enter.

3. **Root-extraction theorem** (`PoleOrderObstruction.exists_pow_eq_iff_dvd_order`):
   a nonzero Laurent series `x` is an `n`-th power in `ℂ⸨X⸩` **iff** `n ∣ order x`.
   So the *only* obstruction to taking roots is the pole order — the arithmetic
   of the integer `order x`, nothing analytic.

4. **Monster corollaries** (`PoleOrderObstruction.exists_pow_eq_prod_traceLaurent_194_iff`):
   the Monstrous-Moonshine product of the `194` McKay–Thompson-shaped series is an
   `n`-th power exactly when `n ∣ 194 = 2 · 97`, i.e. for
   `n ∈ {1, 2, 97, 194}` (`PoleOrderObstruction.root_exponents_194`).  It is a
   square, it has no cube root, and no `4`-th root.

5. **Additive contrast** (`PoleOrderObstruction.orderTop_sum_normalized`): under
   *addition* the pole order does not grow — a sum of `m ≥ 1` normalized series
   still has order `-1`.  Pole-order growth is a purely multiplicative phenomenon,
   which is why the obstruction is a group homomorphism.
-/

namespace PoleOrderObstruction

open HahnSeries Finset

variable {ι : Type*}

/-! ## 0. Orders of powers -/

/-- The order of a power of a nonzero Laurent series. -/
theorem order_pow_of_ne_zero {x : LC} (hx : x ≠ 0) (n : ℕ) :
    (x ^ n).order = n * x.order := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, order_mul_of_ne_zero' (pow_ne_zero n hx) hx, ih]
      push_cast
      ring

/-- A power series with nonzero constant term has Laurent order `0`. -/
theorem order_ofPowerSeries_of_constantCoeff_ne_zero {u : PowerSeries ℂ}
    (hu : PowerSeries.constantCoeff u ≠ 0) :
    (HahnSeries.ofPowerSeries ℤ ℂ u).order = 0 := by
  have h0 : (HahnSeries.ofPowerSeries ℤ ℂ u).coeff (0 : ℤ) = PowerSeries.constantCoeff u := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) u 0
  have hne : HahnSeries.ofPowerSeries ℤ ℂ u ≠ 0 := by
    intro h
    apply hu
    rw [← h0, h]
    simp
  have htop : (HahnSeries.ofPowerSeries ℤ ℂ u).orderTop = ((0 : ℤ) : WithTop ℤ) := by
    refine HahnSeries.orderTop_eq_of_le (g := (0 : ℤ)) ?_ ?_
    · rw [HahnSeries.mem_support, h0]
      exact hu
    · intro g' hg'
      by_contra hlt
      push_neg at hlt
      refine (HahnSeries.mem_support _ _).mp hg' ?_
      rw [show (HahnSeries.ofPowerSeries ℤ ℂ) u = ((u : PowerSeries ℂ) : LC) from rfl,
        PowerSeries.coeff_coe, if_pos (by omega)]
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at htop
  exact_mod_cast htop

/-- The constant term of the power-series part of a nonzero Laurent series is its
leading coefficient, hence nonzero. -/
theorem constantCoeff_powerSeriesPart (x : LC) :
    PowerSeries.constantCoeff x.powerSeriesPart = x.leadingCoeff := by
  rw [← PowerSeries.coeff_zero_eq_constantCoeff, LaurentSeries.powerSeriesPart_coeff,
    HahnSeries.leadingCoeff_eq]
  norm_num

theorem constantCoeff_powerSeriesPart_ne_zero {x : LC} (hx : x ≠ 0) :
    PowerSeries.constantCoeff x.powerSeriesPart ≠ 0 := by
  rw [constantCoeff_powerSeriesPart x]
  simpa using HahnSeries.leadingCoeff_ne_zero.mpr hx

/-! ## 1. Splitting of the valuation exact sequence -/

/-- The image of the unit group of `ℂ⟦X⟧` inside the unit group of `ℂ⸨X⸩`. -/
noncomputable def ofPowerSeriesUnits : (PowerSeries ℂ)ˣ →* (LC)ˣ :=
  Units.map (HahnSeries.ofPowerSeries ℤ ℂ : PowerSeries ℂ →+* LC).toMonoidHom

@[simp] theorem ofPowerSeriesUnits_val (u : (PowerSeries ℂ)ˣ) :
    ((ofPowerSeriesUnits u : (LC)ˣ) : LC) = HahnSeries.ofPowerSeries ℤ ℂ (u : PowerSeries ℂ) := rfl

/-- The pure `q`-power part, as a homomorphism `Multiplicative ℤ →* ℂ⸨X⸩ˣ`. -/
noncomputable def singleUnitHom : Multiplicative ℤ →* (LC)ˣ where
  toFun k := singleUnit (Multiplicative.toAdd k)
  map_one' := by
    apply Units.ext
    simp [singleUnit]
  map_mul' k l := by
    apply Units.ext
    simp [singleUnit, HahnSeries.single_mul_single]

@[simp] theorem singleUnitHom_val (k : Multiplicative ℤ) :
    ((singleUnitHom k : (LC)ˣ) : LC) = HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) := rfl

/-- The comparison map `Multiplicative ℤ × ℂ⟦X⟧ˣ →* ℂ⸨X⸩ˣ`, `(k, u) ↦ qᵏ · u`. -/
noncomputable def laurentUnitsHom : Multiplicative ℤ × (PowerSeries ℂ)ˣ →* (LC)ˣ where
  toFun p := singleUnitHom p.1 * ofPowerSeriesUnits p.2
  map_one' := by simp
  map_mul' p q := by
    simp only [Prod.fst_mul, Prod.snd_mul, map_mul]
    exact mul_mul_mul_comm (singleUnitHom p.1) (singleUnitHom q.1)
      (ofPowerSeriesUnits p.2) (ofPowerSeriesUnits q.2)

theorem laurentUnitsHom_apply_val (k : Multiplicative ℤ) (u : (PowerSeries ℂ)ˣ) :
    ((laurentUnitsHom (k, u) : (LC)ˣ) : LC)
      = HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) *
          HahnSeries.ofPowerSeries ℤ ℂ (u : PowerSeries ℂ) := rfl

/-- The order of `qᵏ · u` is `k`: the power-series unit contributes nothing. -/
theorem order_laurentUnitsHom (k : Multiplicative ℤ) (u : (PowerSeries ℂ)ˣ) :
    ((laurentUnitsHom (k, u) : (LC)ˣ) : LC).order = Multiplicative.toAdd k := by
  have hu : PowerSeries.constantCoeff (u : PowerSeries ℂ) ≠ 0 := by
    have : IsUnit (PowerSeries.constantCoeff (u : PowerSeries ℂ)) :=
      PowerSeries.isUnit_iff_constantCoeff.mp u.isUnit
    exact this.ne_zero
  have h1 : (HahnSeries.single (Multiplicative.toAdd k) (1 : ℂ) : LC) ≠ 0 :=
    HahnSeries.single_ne_zero one_ne_zero
  have h2 : (HahnSeries.ofPowerSeries ℤ ℂ (u : PowerSeries ℂ) : LC) ≠ 0 := by
    intro h
    exact (ofPowerSeriesUnits u).ne_zero h
  rw [laurentUnitsHom_apply_val, order_mul_of_ne_zero' h1 h2,
    order_ofPowerSeries_of_constantCoeff_ne_zero hu, add_zero]
  have hs := HahnSeries.orderTop_single (Γ := ℤ) (a := Multiplicative.toAdd k)
    (one_ne_zero (α := ℂ))
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero h1] at hs
  exact_mod_cast hs

theorem laurentUnitsHom_injective : Function.Injective laurentUnitsHom := by
  rw [← MonoidHom.ker_eq_bot_iff]
  rw [eq_bot_iff]
  rintro ⟨k, u⟩ hku
  have hk : Multiplicative.toAdd k = 0 := by
    have := order_laurentUnitsHom k u
    rw [MonoidHom.mem_ker.mp hku] at this
    simpa using this.symm
  have hu : (u : PowerSeries ℂ) = 1 := by
    have hval : ((laurentUnitsHom (k, u) : (LC)ˣ) : LC) = 1 := by
      rw [MonoidHom.mem_ker.mp hku]; rfl
    rw [laurentUnitsHom_apply_val, hk, HahnSeries.single_zero_one, one_mul] at hval
    have : HahnSeries.ofPowerSeries ℤ ℂ (u : PowerSeries ℂ)
        = HahnSeries.ofPowerSeries ℤ ℂ (1 : PowerSeries ℂ) := by
      rw [hval, map_one]
    exact HahnSeries.ofPowerSeries_injective this
  simp only [Subgroup.mem_bot, Prod.ext_iff]
  refine ⟨?_, Units.ext hu⟩
  exact (Multiplicative.toAdd (α := ℤ)).injective (by simpa using hk)

theorem laurentUnitsHom_surjective : Function.Surjective laurentUnitsHom := by
  intro x
  have hx : (x : LC) ≠ 0 := x.ne_zero
  have hpu : IsUnit ((x : LC).powerSeriesPart) :=
    PowerSeries.isUnit_iff_constantCoeff.mpr
      (isUnit_iff_ne_zero.mpr (constantCoeff_powerSeriesPart_ne_zero hx))
  refine ⟨(Multiplicative.ofAdd ((x : LC).order), hpu.unit), ?_⟩
  apply Units.ext
  rw [laurentUnitsHom_apply_val, IsUnit.unit_spec]
  exact LaurentSeries.single_order_mul_powerSeriesPart (x : LC)

/-- **Splitting theorem.**  The unit group of the field of Laurent series splits
as the direct product of the value group `Multiplicative ℤ` (the pole order) and
the unit group of the power-series ring: `ℂ⸨X⸩ˣ ≃ ℤ × ℂ⟦X⟧ˣ`.  The pole-order
obstruction is the projection onto the first factor. -/
noncomputable def laurentUnitsEquiv :
    Multiplicative ℤ × (PowerSeries ℂ)ˣ ≃* (LC)ˣ :=
  MulEquiv.ofBijective laurentUnitsHom ⟨laurentUnitsHom_injective, laurentUnitsHom_surjective⟩

@[simp] theorem laurentUnitsEquiv_apply (k : Multiplicative ℤ) (u : (PowerSeries ℂ)ˣ) :
    laurentUnitsEquiv (k, u) = laurentUnitsHom (k, u) := rfl

/-- Under the splitting, `orderMonoidHom` is the first projection. -/
theorem orderMonoidHom_laurentUnitsEquiv (k : Multiplicative ℤ) (u : (PowerSeries ℂ)ˣ) :
    orderMonoidHom (laurentUnitsEquiv (k, u)) = k := by
  rw [laurentUnitsEquiv_apply, orderMonoidHom_apply, order_laurentUnitsHom]
  rfl

/-- **Exactness.**  The kernel of the order homomorphism is exactly the group of
unit power series: a Laurent series has order `0` iff it is a unit of `ℂ⟦X⟧`. -/
theorem ker_orderMonoidHom :
    MonoidHom.ker orderMonoidHom = MonoidHom.range ofPowerSeriesUnits := by
  ext x
  constructor
  · intro hx
    have hord : (x : LC).order = 0 := by
      have := MonoidHom.mem_ker.mp hx
      simpa [orderMonoidHom] using this
    have hpu : IsUnit ((x : LC).powerSeriesPart) :=
      PowerSeries.isUnit_iff_constantCoeff.mpr
        (isUnit_iff_ne_zero.mpr (constantCoeff_powerSeriesPart_ne_zero x.ne_zero))
    refine ⟨hpu.unit, ?_⟩
    apply Units.ext
    have := LaurentSeries.single_order_mul_powerSeriesPart (x : LC)
    rw [hord, HahnSeries.single_zero_one, one_mul] at this
    simpa using this
  · rintro ⟨u, rfl⟩
    have hu : PowerSeries.constantCoeff (u : PowerSeries ℂ) ≠ 0 :=
      (PowerSeries.isUnit_iff_constantCoeff.mp u.isUnit).ne_zero
    rw [MonoidHom.mem_ker, orderMonoidHom_apply, ofPowerSeriesUnits_val,
      order_ofPowerSeries_of_constantCoeff_ne_zero hu]
    rfl

/-! ## 2. Roots of unit power series via the binomial series -/

/-- Powers of the binomial series multiply the exponent. -/
theorem binomialSeries_pow (r : ℚ) (k : ℕ) :
    PowerSeries.binomialSeries ℂ r ^ k = PowerSeries.binomialSeries ℂ ((k : ℚ) * r) := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [pow_succ, ih, ← PowerSeries.binomialSeries_add]
      push_cast
      ring_nf

theorem subst_one_eq_one {a : PowerSeries ℂ} (hs : PowerSeries.HasSubst a) :
    PowerSeries.subst a (1 : PowerSeries ℂ) = 1 := by
  rw [← PowerSeries.coe_substAlgHom hs, map_one]

/-- **Divisibility of the group `1 + X·ℂ⟦X⟧`.**  Every power series over `ℂ` with
constant term `1` has an `n`-th root with constant term `1`, for every `n ≥ 1`.
The root is obtained by substituting `u - 1` into the binomial series
`(1 + X)^{1/n}`; this uses that `ℂ` has characteristic zero. -/
theorem exists_pow_eq_of_constantCoeff_one (u : PowerSeries ℂ)
    (hu : PowerSeries.constantCoeff u = 1) {n : ℕ} (hn : n ≠ 0) :
    ∃ w : PowerSeries ℂ, PowerSeries.constantCoeff w = 1 ∧ w ^ n = u := by
  set a : PowerSeries ℂ := u - 1 with ha
  have hac : PowerSeries.constantCoeff a = 0 := by simp [ha, hu]
  have hs : PowerSeries.HasSubst a := PowerSeries.HasSubst.of_constantCoeff_zero' hac
  have hg : PowerSeries.constantCoeff (PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹) - 1) = 0 := by
    simp
  refine ⟨PowerSeries.subst a (PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹)), ?_, ?_⟩
  · have hsplit : PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹)
        = 1 + (PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹) - 1) := by ring
    rw [hsplit, PowerSeries.subst_add hs, subst_one_eq_one hs]
    have hzero := PowerSeries.constantCoeff_subst_eq_zero (a := a) hac
      (PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹) - 1) hg
    simp only [map_add, map_one]
    rw [show ((PowerSeries.constantCoeff) (PowerSeries.subst a
      (PowerSeries.binomialSeries ℂ ((n : ℚ)⁻¹) - 1)) : ℂ) = 0 from hzero]
    ring
  · rw [← PowerSeries.subst_pow hs, binomialSeries_pow]
    rw [show ((n : ℚ) * ((n : ℚ)⁻¹)) = 1 by field_simp]
    have h1 : PowerSeries.binomialSeries ℂ (1 : ℚ) = 1 + (PowerSeries.X : PowerSeries ℂ) := by
      simpa using PowerSeries.binomialSeries_nat (R := ℚ) (A := ℂ) 1
    rw [h1, PowerSeries.subst_add hs, PowerSeries.subst_X hs, subst_one_eq_one hs, ha]
    ring

/-- Every power series with nonzero constant term has an `n`-th root (`n ≥ 1`):
combine the binomial root with an `n`-th root of the constant term, which exists
because `ℂ` is algebraically closed. -/
theorem exists_pow_eq_of_constantCoeff_ne_zero (P : PowerSeries ℂ)
    (hP : PowerSeries.constantCoeff P ≠ 0) {n : ℕ} (hn : n ≠ 0) :
    ∃ w : PowerSeries ℂ, PowerSeries.constantCoeff w ≠ 0 ∧ w ^ n = P := by
  obtain ⟨d, hd⟩ := IsAlgClosed.exists_pow_nat_eq (k := ℂ) (PowerSeries.constantCoeff P)
    (Nat.pos_of_ne_zero hn)
  have hdne : d ≠ 0 := by
    intro h
    apply hP
    rw [← hd, h, zero_pow hn]
  set v : PowerSeries ℂ := PowerSeries.C (PowerSeries.constantCoeff P)⁻¹ * P with hv
  have hvc : PowerSeries.constantCoeff v = 1 := by
    rw [hv, map_mul, PowerSeries.constantCoeff_C, inv_mul_cancel₀ hP]
  obtain ⟨w, hw1, hwn⟩ := exists_pow_eq_of_constantCoeff_one v hvc hn
  refine ⟨PowerSeries.C d * w, ?_, ?_⟩
  · rw [map_mul, PowerSeries.constantCoeff_C, hw1, mul_one]
    exact hdne
  · rw [mul_pow, hwn, ← map_pow, hd, hv, ← mul_assoc, ← map_mul, mul_inv_cancel₀ hP, map_one,
      one_mul]

/-! ## 3. The root-extraction theorem -/

/-- **The pole order is the complete obstruction to root extraction.**  A nonzero
Laurent series `x` over `ℂ` is an `n`-th power in `ℂ⸨X⸩` if and only if `n`
divides `order x`.  No analytic condition intervenes: the obstruction is exactly
the arithmetic of the integer `order x`. -/
theorem exists_pow_eq_iff_dvd_order {x : LC} (hx : x ≠ 0) {n : ℕ} (hn : n ≠ 0) :
    (∃ y : LC, y ^ n = x) ↔ (n : ℤ) ∣ x.order := by
  constructor
  · rintro ⟨y, rfl⟩
    have hy : y ≠ 0 := by
      intro h
      exact hx (by rw [h, zero_pow hn])
    exact ⟨y.order, order_pow_of_ne_zero hy n⟩
  · rintro ⟨k, hk⟩
    obtain ⟨w, hw, hwn⟩ := exists_pow_eq_of_constantCoeff_ne_zero x.powerSeriesPart
      (constantCoeff_powerSeriesPart_ne_zero hx) hn
    refine ⟨HahnSeries.single k (1 : ℂ) * HahnSeries.ofPowerSeries ℤ ℂ w, ?_⟩
    have hmap : (HahnSeries.ofPowerSeries ℤ ℂ w) ^ n
        = HahnSeries.ofPowerSeries ℤ ℂ (w ^ n) :=
      (map_pow (HahnSeries.ofPowerSeries ℤ ℂ) w n).symm
    rw [mul_pow, hmap, hwn, HahnSeries.single_pow, one_pow]
    rw [show (n • k) = x.order by rw [hk]; simp [mul_comm]]
    exact LaurentSeries.single_order_mul_powerSeriesPart x

/-- Reformulation: the set of exponents admitting an `n`-th root is the set of
divisors of the pole order. -/
theorem exists_pow_eq_prod_normalized_iff (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) {n : ℕ} (hn : n ≠ 0) :
    (∃ y : LC, y ^ n = ∏ i ∈ s, f i) ↔ (n : ℤ) ∣ (s.card : ℤ) := by
  rw [exists_pow_eq_iff_dvd_order (prod_normalized_ne_zero s f h) hn,
    order_prod_normalized s f h, dvd_neg]

/-! ## 4. The Monster -/

/-- **Monster root spectrum.**  The Monstrous-Moonshine product of the `194`
normalized McKay–Thompson-shaped series is an `n`-th power in `ℂ⸨X⸩` exactly when
`n ∣ 194`. -/
theorem exists_pow_eq_prod_traceLaurent_194_iff (c : Fin monsterClassCount → ℕ → ℂ)
    {n : ℕ} (hn : n ≠ 0) :
    (∃ y : LC, y ^ n = ∏ i, traceLaurent (c i)) ↔ n ∣ 194 := by
  have h := exists_pow_eq_prod_normalized_iff (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i)) hn
  rw [Finset.card_univ, Fintype.card_fin] at h
  rw [h, monsterClassCount]
  exact Int.natCast_dvd_natCast

/-- The Monster-sized product **is** a square: `194 = 2 · 97`. -/
theorem exists_sq_eq_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    ∃ y : LC, y ^ 2 = ∏ i, traceLaurent (c i) := by
  rw [exists_pow_eq_prod_traceLaurent_194_iff c (by norm_num)]
  norm_num

/-- The Monster-sized product has **no cube root**: `3 ∤ 194`. -/
theorem not_exists_cube_root_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    ¬ ∃ y : LC, y ^ 3 = ∏ i, traceLaurent (c i) := by
  rw [exists_pow_eq_prod_traceLaurent_194_iff c (by norm_num)]
  decide

/-- Nor a fourth root: `194 = 2 · 97` is squarefree, so `4 ∤ 194`. -/
theorem not_exists_fourth_root_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    ¬ ∃ y : LC, y ^ 4 = ∏ i, traceLaurent (c i) := by
  rw [exists_pow_eq_prod_traceLaurent_194_iff c (by norm_num)]
  decide

/-- **The exact root spectrum of the Monster product**: the exponents `n ≥ 1` for
which an `n`-th root exists are precisely `1, 2, 97, 194`. -/
theorem root_exponents_194 (c : Fin monsterClassCount → ℕ → ℂ) (n : ℕ) (hn : n ≠ 0) :
    (∃ y : LC, y ^ n = ∏ i, traceLaurent (c i)) ↔ n = 1 ∨ n = 2 ∨ n = 97 ∨ n = 194 := by
  rw [exists_pow_eq_prod_traceLaurent_194_iff c hn]
  constructor
  · intro hd
    have hmem : n ∈ Nat.divisors 194 := Nat.mem_divisors.mpr ⟨hd, by norm_num⟩
    have : Nat.divisors 194 = {1, 2, 97, 194} := by decide
    rw [this] at hmem
    simpa using hmem
  · rintro (rfl | rfl | rfl | rfl) <;> norm_num

/-! ## 5. Additive contrast: poles do not add under addition -/

/-- A sum of `m ≥ 1` normalized series has `orderTop = -1`: the pole order does
not grow.  (Contrast with `orderTop_prod_normalized`, where it grows by one per
factor.)  This is why the pole-order obstruction is multiplicative. -/
theorem orderTop_sum_normalized (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (hs : s.Nonempty) :
    (∑ i ∈ s, f i).orderTop = ((-1 : ℤ) : WithTop ℤ) := by
  classical
  have hcoeff : (∑ i ∈ s, f i).coeff (-1) = (s.card : ℂ) := by
    rw [HahnSeries.coeff_sum]
    rw [Finset.sum_congr rfl (fun i hi => (h i hi).coeff_neg_one)]
    simp
  have hcard : ((s.card : ℂ)) ≠ 0 := by
    have hpos : 0 < s.card := Finset.card_pos.mpr hs
    exact Nat.cast_ne_zero.mpr hpos.ne'
  refine HahnSeries.orderTop_eq_of_le (g := (-1 : ℤ)) ?_ ?_
  · rw [HahnSeries.mem_support, hcoeff]
    exact hcard
  · intro g' hg'
    by_contra hlt
    push_neg at hlt
    refine (HahnSeries.mem_support _ _).mp hg' ?_
    rw [HahnSeries.coeff_sum]
    exact Finset.sum_eq_zero (fun i hi => (h i hi).coeff_eq_zero_of_lt g' hlt)

/-- The sum of the `194` McKay–Thompson-shaped series has a **simple** pole,
whereas their product has a pole of order `194`. -/
theorem orderTop_sum_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) :
    (∑ i, traceLaurent (c i)).orderTop = ((-1 : ℤ) : WithTop ℤ) :=
  orderTop_sum_normalized Finset.univ _ (fun i _ => isNormalized_traceLaurent (c i))
    ⟨⟨0, by norm_num [monsterClassCount]⟩, Finset.mem_univ _⟩

end PoleOrderObstruction