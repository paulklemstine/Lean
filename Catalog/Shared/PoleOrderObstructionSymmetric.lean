import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.PoleOrderObstructionRoots

/-!
# Cycle 4: the pole order modulo `n`, and symmetric functions in the tail

Cycle 3 (`Shared.PoleOrderObstructionRoots`) proved that a nonzero Laurent series
is an `n`-th power exactly when `n` divides its order.  This cycle turns that
statement into a *structural classification* and pushes the coefficient side of
the theory from the first two Newton identities of cycle 2 to a closed formula.

1. **The power classes of `ℂ⸨X⸩ˣ`** (`PoleOrderObstruction.unitsModPowEquiv`):
   for every `n ≥ 1` the group of `n`-th power classes is cyclic of order `n`,
   `ℂ⸨X⸩ˣ / (ℂ⸨X⸩ˣ)ⁿ ≃ ℤ/n`, the isomorphism being *pole order mod n*.  So the
   pole order is not merely an obstruction: it is a complete invariant of the
   `n`-th power class, and it is *sharp* — every residue occurs.
   For the Monster product, the class is `194 mod n`
   (`PoleOrderObstruction.orderModHom_prod_traceLaurent_194`), which vanishes
   exactly for `n ∈ {1, 2, 97, 194}`.

2. **Elementary symmetric functions in the tail.**  The master identity
   `PoleOrderObstruction.coeff_prod_normalized_shift` says that all Laurent
   coefficients of a Monster-type product are power-series coefficients of the
   corrected product.  For the "linear" normalized series `q⁻¹ + a` this yields a
   closed formula (`PoleOrderObstruction.coeff_prod_linTrace`): the coefficient of
   the product at degree `k - m` is the `k`-th **elementary symmetric function**
   of the constant terms `a i`.  Cycles 1 and 2 computed the cases `k = 1, 2` by
   hand; this is the whole sequence at once, and it identifies the coefficients of
   a Monster-type product as a combinatorial (subset-sum) invariant.

3. **Consequences.**  The pole-order profile is then completely explicit: the
   Monster-sized linear product has `194` nonzero Laurent coefficients at most,
   at degrees `-194, …, 0`, and vanishes strictly above degree `0`
   (`PoleOrderObstruction.coeff_prod_linTrace_eq_zero_of_gt`).
-/

namespace PoleOrderObstruction

open HahnSeries Finset

variable {ι : Type*}

/-! ## 1. The pole order modulo `n` -/

/-- The order of the monomial `q ^ k` (`k ∈ ℤ`). -/
theorem order_single_one (k : ℤ) : (HahnSeries.single k (1 : ℂ) : LC).order = k := by
  have hne : (HahnSeries.single k (1 : ℂ) : LC) ≠ 0 := HahnSeries.single_ne_zero one_ne_zero
  have h := HahnSeries.orderTop_single (Γ := ℤ) (a := k) (one_ne_zero (α := ℂ))
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne] at h
  exact_mod_cast h

/-- The pole order read modulo `n`, as a group homomorphism
`ℂ⸨X⸩ˣ →* Multiplicative (ZMod n)`. -/
noncomputable def orderModHom (n : ℕ) : (LC)ˣ →* Multiplicative (ZMod n) where
  toFun u := Multiplicative.ofAdd (((u : LC).order : ZMod n))
  map_one' := by simp
  map_mul' u v := by
    have h : ((u * v : (LC)ˣ) : LC).order = (u : LC).order + (v : LC).order :=
      order_mul_of_ne_zero' u.ne_zero v.ne_zero
    simp only [h, Int.cast_add]
    exact ofAdd_add _ _

@[simp] theorem orderModHom_apply (n : ℕ) (u : (LC)ˣ) :
    orderModHom n u = Multiplicative.ofAdd (((u : LC).order : ZMod n)) := rfl

/-- Every residue class occurs as a pole order: `orderModHom n` is surjective. -/
theorem orderModHom_surjective (n : ℕ) : Function.Surjective (orderModHom n) := by
  intro k
  obtain ⟨m, hm⟩ := ZMod.intCast_surjective (n := n) (Multiplicative.toAdd k)
  refine ⟨singleUnit m, ?_⟩
  rw [orderModHom_apply, singleUnit_val, order_single_one, hm]
  rfl

/-- The subgroup of `n`-th powers of `ℂ⸨X⸩ˣ`. -/
def nthPowerSubgroup (n : ℕ) : Subgroup (LC)ˣ where
  carrier := Set.range (fun v : (LC)ˣ => v ^ n)
  mul_mem' := by
    rintro _ _ ⟨a, rfl⟩ ⟨b, rfl⟩
    exact ⟨a * b, mul_pow a b n⟩
  one_mem' := ⟨1, one_pow n⟩
  inv_mem' := by
    rintro _ ⟨a, rfl⟩
    exact ⟨a⁻¹, (inv_pow a n).symm ▸ rfl⟩

@[simp] theorem mem_nthPowerSubgroup {n : ℕ} {u : (LC)ˣ} :
    u ∈ nthPowerSubgroup n ↔ ∃ v : (LC)ˣ, v ^ n = u := Iff.rfl

/-- `ℂ⸨X⸩ˣ` is abelian, so the subgroup of `n`-th powers is normal. -/
instance nthPowerSubgroup_normal (n : ℕ) : (nthPowerSubgroup n).Normal := by
  constructor
  intro a ha b
  have hcomm : b * a * b⁻¹ = a := by
    rw [mul_comm b a, mul_assoc, mul_inv_cancel, mul_one]
  rw [hcomm]
  exact ha

/-- **The kernel is the group of `n`-th powers.**  A unit of `ℂ⸨X⸩` has pole order
divisible by `n` iff it is an `n`-th power.  (This is cycle 3's root-extraction
theorem, transported to the unit group.) -/
theorem ker_orderModHom (n : ℕ) (hn : n ≠ 0) :
    MonoidHom.ker (orderModHom n) = nthPowerSubgroup n := by
  ext u
  constructor
  · intro hu
    have hdvd : (n : ℤ) ∣ (u : LC).order := by
      have : (((u : LC).order : ZMod n)) = 0 := by
        have := MonoidHom.mem_ker.mp hu
        simpa [orderModHom] using this
      exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp this
    obtain ⟨y, hy⟩ := (exists_pow_eq_iff_dvd_order (x := (u : LC)) u.ne_zero hn).mpr hdvd
    have hyne : y ≠ 0 := by
      intro h
      exact u.ne_zero (by rw [← hy, h, zero_pow hn])
    refine ⟨Units.mk0 y hyne, ?_⟩
    apply Units.ext
    simpa using hy
  · rintro ⟨v, rfl⟩
    have hpow : (((v ^ n : (LC)ˣ)) : LC) = (v : LC) ^ n := by simp
    rw [MonoidHom.mem_ker, orderModHom_apply, hpow, order_pow_of_ne_zero v.ne_zero]
    have : (((n : ℤ) * (v : LC).order : ℤ) : ZMod n) = 0 := by
      push_cast
      simp
    rw [this]
    rfl

/-- **Classification of power classes.**  For every `n ≥ 1`,
`ℂ⸨X⸩ˣ / (ℂ⸨X⸩ˣ)ⁿ ≃ ℤ/n` via the pole order mod `n`.  The pole-order obstruction
is therefore a *complete and sharp* invariant of the `n`-th power class. -/
noncomputable def unitsModPowEquiv (n : ℕ) (hn : n ≠ 0) :
    ((LC)ˣ ⧸ nthPowerSubgroup n) ≃* Multiplicative (ZMod n) :=
  (QuotientGroup.quotientMulEquivOfEq (ker_orderModHom n hn).symm).trans
    (QuotientGroup.quotientKerEquivOfSurjective _ (orderModHom_surjective n))

/-- The `n`-th power class of the Monster-sized product is `-194 mod n`. -/
theorem orderModHom_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) (n : ℕ) :
    orderModHom n (Units.mk0 (∏ i, traceLaurent (c i))
        (prod_normalized_ne_zero Finset.univ _ (fun i _ => isNormalized_traceLaurent (c i))))
      = Multiplicative.ofAdd ((-194 : ℤ) : ZMod n) := by
  rw [orderModHom_apply]
  congr 1
  rw [Units.val_mk0,
    order_prod_normalized Finset.univ _ (fun i _ => isNormalized_traceLaurent (c i))]
  norm_num [monsterClassCount]

/-- The class is trivial exactly for the divisors of `194`: the power-class
invariant sees precisely the arithmetic of the Monster's class number. -/
theorem orderModHom_prod_traceLaurent_194_eq_one_iff (c : Fin monsterClassCount → ℕ → ℂ)
    (n : ℕ) :
    orderModHom n (Units.mk0 (∏ i, traceLaurent (c i))
        (prod_normalized_ne_zero Finset.univ _ (fun i _ => isNormalized_traceLaurent (c i))))
      = 1 ↔ n ∣ 194 := by
  rw [orderModHom_prod_traceLaurent_194 c n]
  rw [show (1 : Multiplicative (ZMod n)) = Multiplicative.ofAdd (0 : ZMod n) from rfl]
  rw [Multiplicative.ofAdd.apply_eq_iff_eq]
  rw [ZMod.intCast_zmod_eq_zero_iff_dvd, dvd_neg]
  exact_mod_cast Iff.rfl

/-! ## 2. The master coefficient identity -/

/-- **Master identity.**  Every Laurent coefficient of a product of `m` normalized
series is a power-series coefficient of the `q ^ m`-corrected product: the
coefficient at degree `k - m` equals the `k`-th coefficient of `∏ normalizedPart`.
Cycle 1 (`coeff_prod_normalized_subleading`, `k = 1`) and cycle 2
(`coeff_prod_normalized_subsubleading`, `k = 2`) are the first two instances. -/
theorem coeff_prod_normalized_shift (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) :
    (∏ i ∈ s, f i).coeff ((k : ℤ) - (s.card : ℤ))
      = PowerSeries.coeff k (∏ i ∈ s, normalizedPart (f i)) := by
  classical
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff ((k : ℕ) : ℤ)
      = PowerSeries.coeff k (∏ i ∈ s, normalizedPart (f i)) :=
    HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) k
  rw [ofPowerSeries_prod_normalizedPart s f h, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  exact hcoe

/-! ## 3. Linear normalized series and elementary symmetric functions -/

/-- The *linear* normalized series `q⁻¹ + a`: a McKay–Thompson-shaped series whose
tail consists of the single constant term `a`. -/
noncomputable def linTrace (a : ℂ) : LC := traceLaurent (fun n => if n = 0 then a else 0)

theorem isNormalized_linTrace (a : ℂ) : IsNormalized (linTrace a) :=
  isNormalized_traceLaurent _

/-- All nonnegative coefficients of a trace series. -/
theorem coeff_traceLaurent (c : ℕ → ℂ) (n : ℕ) : (traceLaurent c).coeff ((n : ℤ)) = c n := by
  have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff ((n : ℕ) : ℤ) = c n := by
    simp
  have h2 : ((n : ℤ)) ≠ (-1 : ℤ) := by omega
  simp [traceLaurent, h1, h2]

/-- The unit power series attached to `q⁻¹ + a` is the linear polynomial `a·X + 1`. -/
theorem normalizedPart_linTrace (a : ℂ) :
    normalizedPart (linTrace a) = PowerSeries.C a * PowerSeries.X + 1 := by
  ext n
  rw [coeff_normalizedPart (isNormalized_linTrace a) n]
  match n with
  | 0 =>
      rw [show ((0 : ℕ) : ℤ) - 1 = (-1 : ℤ) by norm_num]
      simp [(isNormalized_linTrace a).coeff_neg_one]
  | 1 =>
      rw [show ((1 : ℕ) : ℤ) - 1 = ((0 : ℕ) : ℤ) by norm_num, linTrace, coeff_traceLaurent]
      simp
  | (m + 2) =>
      rw [show (((m + 2 : ℕ)) : ℤ) - 1 = (((m + 1 : ℕ)) : ℤ) by push_cast; ring,
        linTrace, coeff_traceLaurent]
      simp

/-- **Elementary symmetric functions from a product of linear factors.**  The
`k`-th coefficient of `∏ (a i · X + 1)` is the `k`-th elementary symmetric
function of the `a i`. -/
theorem coeff_prod_one_add_linear (s : Finset ι) (a : ι → ℂ) (k : ℕ) :
    PowerSeries.coeff k (∏ i ∈ s, (PowerSeries.C (a i) * PowerSeries.X + 1))
      = ∑ t ∈ s.powersetCard k, ∏ i ∈ t, a i := by
  classical
  rw [Finset.prod_add (fun i => PowerSeries.C (a i) * PowerSeries.X) (fun _ => 1) s]
  rw [map_sum]
  have hterm : ∀ t ∈ s.powerset,
      PowerSeries.coeff k ((∏ i ∈ t, (PowerSeries.C (a i) * PowerSeries.X)) *
        ∏ _i ∈ s \ t, (1 : PowerSeries ℂ))
        = if t.card = k then ∏ i ∈ t, a i else 0 := by
    intro t _
    rw [Finset.prod_const_one, mul_one, Finset.prod_mul_distrib, ← map_prod, Finset.prod_const,
      PowerSeries.coeff_C_mul, PowerSeries.coeff_X_pow]
    by_cases hc : t.card = k
    · simp [hc]
    · simp [hc, Ne.symm hc]
  rw [Finset.sum_congr rfl hterm, Finset.powersetCard_eq_filter, Finset.sum_filter]

/-- **Closed formula for the Laurent coefficients of a Monster-type product of
linear factors.**  For `m` linear normalized series `q⁻¹ + a i`, the coefficient at
degree `k - m` is the `k`-th elementary symmetric function of the `a i`. -/
theorem coeff_prod_linTrace (s : Finset ι) (a : ι → ℂ) (k : ℕ) :
    (∏ i ∈ s, linTrace (a i)).coeff ((k : ℤ) - (s.card : ℤ))
      = ∑ t ∈ s.powersetCard k, ∏ i ∈ t, a i := by
  classical
  rw [coeff_prod_normalized_shift s (fun i => linTrace (a i))
    (fun i _ => isNormalized_linTrace (a i)) k]
  rw [Finset.prod_congr rfl (fun i _ => normalizedPart_linTrace (a i))]
  exact coeff_prod_one_add_linear s a k

/-- Above the constant term the product of `m` linear normalized series vanishes:
its Laurent expansion is the finite sum `∑_{k ≤ m} e_k q^{k-m}`. -/
theorem coeff_prod_linTrace_eq_zero_of_gt (s : Finset ι) (a : ι → ℂ) (k : ℕ)
    (hk : s.card < k) :
    (∏ i ∈ s, linTrace (a i)).coeff ((k : ℤ) - (s.card : ℤ)) = 0 := by
  rw [coeff_prod_linTrace s a k, Finset.powersetCard_eq_empty.mpr hk, Finset.sum_empty]

/-- Leading behaviour: the top coefficient (degree `0`) of the product of `m`
linear factors is the product of all the `a i`. -/
theorem coeff_prod_linTrace_top (s : Finset ι) (a : ι → ℂ) :
    (∏ i ∈ s, linTrace (a i)).coeff 0 = ∏ i ∈ s, a i := by
  have h := coeff_prod_linTrace s a s.card
  rw [sub_self] at h
  rw [h, Finset.powersetCard_self, Finset.sum_singleton]

/-! ## 4. The Monster instance -/

/-- For the Monster-sized product of linear trace series, the coefficient at
degree `k - 194` is the `k`-th elementary symmetric function of the `194`
constants. -/
theorem coeff_prod_linTrace_194 (a : Fin monsterClassCount → ℂ) (k : ℕ) :
    (∏ i, linTrace (a i)).coeff ((k : ℤ) - 194)
      = ∑ t ∈ (Finset.univ : Finset (Fin monsterClassCount)).powersetCard k, ∏ i ∈ t, a i := by
  have h := coeff_prod_linTrace (Finset.univ : Finset (Fin monsterClassCount)) a k
  rw [Finset.card_univ, Fintype.card_fin] at h
  simpa [monsterClassCount] using h

/-- The pole coefficient (`q⁻¹⁹⁴`) is `1`, and the last coefficient (`q⁰`) is the
product of all `194` constants: a Monster-sized Vieta relation. -/
theorem coeff_prod_linTrace_194_endpoints (a : Fin monsterClassCount → ℂ) :
    (∏ i, linTrace (a i)).coeff (-194 : ℤ) = 1 ∧
      (∏ i, linTrace (a i)).coeff 0 = ∏ i, a i := by
  constructor
  · have h := coeff_prod_linTrace_194 a 0
    rw [show ((0 : ℕ) : ℤ) - 194 = (-194 : ℤ) by norm_num] at h
    rw [h, Finset.powersetCard_zero, Finset.sum_singleton, Finset.prod_empty]
  · have h := coeff_prod_linTrace_top (Finset.univ : Finset (Fin monsterClassCount)) a
    simpa using h

/-! ## 5. Lab notes: numerical instances verified inside Lean

Two hand-computable instances of the symmetric-function formula, checked against
explicit expansions:

* `(q⁻¹ + 2)(q⁻¹ + 3) = q⁻² + 5 q⁻¹ + 6`, so `e₁ = 5` sits in degree `1 - 2 = -1`;
* `(q⁻¹ + 2)(q⁻¹ + 3)(q⁻¹ + 5) = q⁻³ + 10 q⁻² + 31 q⁻¹ + 30`, so `e₂ = 31` sits in
  degree `2 - 3 = -1`.
-/

/-- Two linear factors: `e₁(2, 3) = 5` appears in degree `-1`. -/
theorem coeff_prod_linTrace_example_two :
    (∏ i : Fin 2, linTrace (![2, 3] i)).coeff (-1 : ℤ) = 5 := by
  have h := coeff_prod_linTrace (Finset.univ : Finset (Fin 2)) ![2, 3] 1
  norm_num [Fin.prod_univ_two] at h ⊢
  rw [h, show (Finset.univ : Finset (Fin 2)).powersetCard 1 = {{0}, {1}} from by decide]
  norm_num

/-- Three linear factors: `e₂(2, 3, 5) = 6 + 10 + 15 = 31` appears in degree `-1`. -/
theorem coeff_prod_linTrace_example_three :
    (∏ i : Fin 3, linTrace (![2, 3, 5] i)).coeff (-1 : ℤ) = 31 := by
  have h := coeff_prod_linTrace (Finset.univ : Finset (Fin 3)) ![2, 3, 5] 2
  norm_num at h
  rw [h, show (Finset.univ : Finset (Fin 3)).powersetCard 2 = {{0, 1}, {0, 2}, {1, 2}}
    from by decide]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [Finset.prod_pair (by decide), Finset.prod_pair (by decide), Finset.prod_pair (by decide)]
  norm_num [Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons]

end PoleOrderObstruction