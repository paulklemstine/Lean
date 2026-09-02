import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.PoleOrderObstructionRoots

/-!
# Cycle 6: the obstruction dissolves over a divisible value group

Cycles 3–5 identified the pole order as the *complete* obstruction to extracting
roots of a Monster-type product: `∏ T_g` has an `n`-th root in `ℂ⸨X⸩` iff
`n ∣ 194`.  The proof located the obstruction entirely in the value group `ℤ`.
This cycle confirms that diagnosis by *removing* the obstruction: after enlarging
the exponent lattice from `ℤ` to the divisible group `ℚ` — that is, after passing
to the Hahn field `ℂ⟦q^ℚ⟧` of Puiseux-type series — the Monster product becomes an
`n`-th power for **every** `n ≥ 1`.

* `PoleOrderObstruction.puiseuxEmb` — the exponent-lattice extension
  `ℂ⸨X⸩ ↪ ℂ⟦q^ℚ⟧`, a ring embedding multiplying nothing and preserving order.
* `PoleOrderObstruction.exists_pow_eq_puiseuxEmb_prod_normalized` — every product
  of normalized series has an `n`-th root over `ℚ`-exponents, for every `n ≥ 1`.
  The root is explicit: `q^{-m/n}` times the binomial `n`-th root of the unit part.
* `PoleOrderObstruction.exists_root_194_orderTop_neg_one` — the `194`-th root of
  the Monster product has order exactly `-1`: it is again a *simple-pole* series.
  So the Monstrous product is, over `ℚ`-exponents, the `194`-th power of a single
  normalized-type series.

This is the exact converse of cycles 3–5: the obstruction is a property of the
value group `ℤ`, not of the series.
-/

namespace PoleOrderObstruction

open HahnSeries Finset

variable {ι : Type*}

/-- Puiseux-type Hahn series: complex coefficients, rational exponents. -/
abbrev PC := HahnSeries ℚ ℂ

/-! ## 1. The exponent-lattice extension `ℂ⸨X⸩ ↪ ℂ⟦q^ℚ⟧` -/

theorem intCast_le_iff (g g' : ℤ) :
    (Int.castAddHom ℚ) g ≤ (Int.castAddHom ℚ) g' ↔ g ≤ g' := by
  simp only [Int.coe_castAddHom]
  exact_mod_cast Iff.rfl

/-- The extension of scalars on exponents `ℤ ↪ ℚ`, as a ring embedding of Hahn
series. -/
noncomputable def puiseuxEmb : LC →+* PC :=
  HahnSeries.embDomainRingHom (Int.castAddHom ℚ) Int.cast_injective intCast_le_iff

@[simp] theorem puiseuxEmb_single (k : ℤ) (c : ℂ) :
    puiseuxEmb (HahnSeries.single k c) = HahnSeries.single ((k : ℚ)) c := by
  simp [puiseuxEmb]

/-- `puiseuxEmb` really is an embedding. -/
theorem puiseuxEmb_injective : Function.Injective puiseuxEmb :=
  HahnSeries.embDomain_injective

/-- The embedding transports orders along `ℤ ↪ ℚ`. -/
theorem orderTop_puiseuxEmb (x : LC) (k : ℤ) (hx : x.orderTop = (k : WithTop ℤ)) :
    (puiseuxEmb x).orderTop = (((k : ℚ)) : WithTop ℚ) := by
  have h : (puiseuxEmb x).orderTop
      = WithTop.map (⟨⟨Int.castAddHom ℚ, Int.cast_injective⟩, intCast_le_iff _ _⟩ : ℤ ↪o ℚ)
          x.orderTop :=
    HahnSeries.orderTop_embDomain
  rw [h, hx]
  rfl

/-- A power series with nonzero constant term has `orderTop = 0`. -/
theorem orderTop_ofPowerSeries_of_constantCoeff_ne_zero {u : PowerSeries ℂ}
    (hu : PowerSeries.constantCoeff u ≠ 0) :
    (HahnSeries.ofPowerSeries ℤ ℂ u).orderTop = ((0 : ℤ) : WithTop ℤ) := by
  have hne : HahnSeries.ofPowerSeries ℤ ℂ u ≠ 0 := by
    intro h
    apply hu
    have h0 : (HahnSeries.ofPowerSeries ℤ ℂ u).coeff (0 : ℤ) = PowerSeries.constantCoeff u := by
      simpa using HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) u 0
    rw [← h0, h]
    simp
  rw [← HahnSeries.order_eq_orderTop_of_ne_zero hne,
    order_ofPowerSeries_of_constantCoeff_ne_zero hu]

/-! ## 2. Every Monster-type product is an `n`-th power over `ℚ`-exponents -/

theorem constantCoeff_prod_normalizedPart (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    PowerSeries.constantCoeff (∏ i ∈ s, normalizedPart (f i)) = 1 := by
  rw [map_prod,
    Finset.prod_congr rfl (fun i hi => constantCoeff_normalizedPart (f i) (h i hi)),
    Finset.prod_const_one]

/-- **Dissolution of the obstruction.**  Over the divisible exponent group `ℚ`,
every product of `m` normalized `q`-series is an `n`-th power, for every `n ≥ 1`:
the root is `q^{-m/n}` times the binomial `n`-th root of the corrected unit. -/
theorem exists_pow_eq_puiseuxEmb_prod_normalized (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) {n : ℕ} (hn : n ≠ 0) :
    ∃ y : PC, y ^ n = puiseuxEmb (∏ i ∈ s, f i) := by
  obtain ⟨W, hW1, hWn⟩ := exists_pow_eq_of_constantCoeff_one
    (∏ i ∈ s, normalizedPart (f i)) (constantCoeff_prod_normalizedPart s f h) hn
  refine ⟨HahnSeries.single (-(s.card : ℚ) / (n : ℚ)) (1 : ℂ) *
    puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W), ?_⟩
  have hmap : (puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W)) ^ n
      = puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))) := by
    rw [← map_pow, ← map_pow, hWn]
  have hnq : (n : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  rw [mul_pow, HahnSeries.single_pow, one_pow, hmap,
    show (n • (-(s.card : ℚ) / (n : ℚ))) = (((-(s.card : ℤ)) : ℤ) : ℚ) by
      rw [nsmul_eq_mul]; field_simp; push_cast; ring,
    ← puiseuxEmb_single, ← map_mul]
  exact congrArg puiseuxEmb (prod_normalized_factorization s f h).symm

/-! ## 3. The Monster: a `194`-th root with a simple pole -/

/-- **The Monster product is a `194`-th power of a simple-pole series.**  Over
`ℚ`-exponents there is `y` with `y ^ 194 = ∏ T_g` and `orderTop y = -1`: the
`194`-fold pole is exactly `194` copies of one simple pole. -/
theorem exists_root_194_orderTop_neg_one (c : Fin monsterClassCount → ℕ → ℂ) :
    ∃ y : PC, y ^ 194 = puiseuxEmb (∏ i, traceLaurent (c i)) ∧
      y.orderTop = ((-1 : ℚ) : WithTop ℚ) := by
  classical
  set s : Finset (Fin monsterClassCount) := Finset.univ with hs
  set f : Fin monsterClassCount → LC := fun i => traceLaurent (c i) with hf
  have hnorm : ∀ i ∈ s, IsNormalized (f i) := fun i _ => isNormalized_traceLaurent (c i)
  have hcard : (s.card : ℚ) = 194 := by
    rw [hs, Finset.card_univ, Fintype.card_fin]
    norm_num [monsterClassCount]
  obtain ⟨W, hW1, hWn⟩ := exists_pow_eq_of_constantCoeff_one
    (∏ i ∈ s, normalizedPart (f i)) (constantCoeff_prod_normalizedPart s f hnorm)
    (n := 194) (by norm_num)
  refine ⟨HahnSeries.single (-1 : ℚ) (1 : ℂ) *
    puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W), ?_, ?_⟩
  · have hmap : (puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W)) ^ 194
        = puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))) := by
      rw [← map_pow, ← map_pow, hWn]
    rw [mul_pow, HahnSeries.single_pow, one_pow, hmap,
      show ((194 : ℕ) • (-1 : ℚ)) = (((-(s.card : ℤ)) : ℤ) : ℚ) by
        rw [nsmul_eq_mul]; push_cast [hcard]; norm_num,
      ← puiseuxEmb_single, ← map_mul]
    exact congrArg puiseuxEmb (prod_normalized_factorization s f hnorm).symm
  · have hW : PowerSeries.constantCoeff W ≠ 0 := by rw [hW1]; exact one_ne_zero
    have h1 : (HahnSeries.single (-1 : ℚ) (1 : ℂ) : PC).orderTop = ((-1 : ℚ) : WithTop ℚ) :=
      HahnSeries.orderTop_single (one_ne_zero (α := ℂ))
    have h2 : (puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W)).orderTop = ((0 : ℚ) : WithTop ℚ) := by
      have := orderTop_puiseuxEmb (HahnSeries.ofPowerSeries ℤ ℂ W) 0
        (orderTop_ofPowerSeries_of_constantCoeff_ne_zero hW)
      simpa using this
    rw [HahnSeries.orderTop_mul, h1, h2, ← WithTop.coe_add]
    norm_num

/-- Complementary statement: over `ℚ`-exponents **every** exponent works, in
contrast with the `ℤ`-graded answer `n ∣ 194` of cycle 3. -/
theorem exists_pow_eq_puiseuxEmb_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ)
    {n : ℕ} (hn : n ≠ 0) :
    ∃ y : PC, y ^ n = puiseuxEmb (∏ i, traceLaurent (c i)) :=
  exists_pow_eq_puiseuxEmb_prod_normalized Finset.univ _
    (fun i _ => isNormalized_traceLaurent (c i)) hn

end PoleOrderObstruction