import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Cryptography.PoleOrderSplitting

/-!
# Cycle 4: valuation rigidity, torsion-freeness, and positivity of the pole-order obstruction

Cycle 3 (`Cryptography.PoleOrderSplitting`) showed that `ℂ⸨X⸩ˣ ≃ ℂ⟦X⟧ˣ × ℤ` and
that pole order is a complete invariant of the coset space.  This cycle asks
*how robust* that invariant is, and answers with four theorems.

1. **Valuation subring** (`PoleOrderValuation.mem_range_ofPowerSeries_iff`): the
   image of `ℂ⟦X⟧` inside `ℂ⸨X⸩` is *exactly* the non-negative part of the
   valuation, `{x | 0 ≤ x.orderTop}`.  Combined with cycle 1's
   `prod_notMem_range_ofPowerSeries` this upgrades a non-membership statement to
   a characterization, and yields the sharp threshold
   `PoleOrderValuation.qPow_mul_prod_mem_range_iff`: `q ^ k · ∏ᵢ fᵢ` is a power
   series **iff** `k ≥ m`.

2. **Rigidity of the valuation** (`PoleOrderValuation.hom_eq_order_smul`): *any*
   group homomorphism `ℂ⸨X⸩ˣ →* Multiplicative ℤ` killing `ℂ⟦X⟧ˣ` is an integer
   multiple of the order.  So the pole-order obstruction is not one invariant
   among many: up to scaling it is the *only* `ℤ`-valued multiplicative
   invariant insensitive to power-series blinding.

3. **Torsion-freeness / no root trick**
   (`PoleOrderValuation.pow_mem_range_psUnitHom_iff`): the obstruction cannot be
   destroyed by passing to powers.  If `u ^ n` is a unit power series with
   `n ≥ 1`, then already `order u = 0`.  In particular no power of the
   Monster-sized moonshine product is a power series
   (`PoleOrderValuation.monsterUnit_pow_notMem_range`).

4. **Positivity propagation** (`PoleOrderValuation.isNonnegReal_coeff_prod`): if
   every factor of a Monster-type product has non-negative real coefficients —
   as genuine McKay–Thompson series do, their coefficients being dimensions of
   graded pieces — then *every* coefficient of the product is a non-negative
   real.  The proof runs through cycle 3's all-degree convolution identity, so
   the analytic positivity statement is a consequence of the combinatorial
   Newton identity.

Together: the obstruction is complete (cycle 3), unique (2), indestructible (1,
3) and compatible with the representation-theoretic positivity of moonshine (4).
-/

namespace PoleOrderValuation

open HahnSeries Finset PoleOrderObstruction PoleOrderSplitting

/-! ## 1. The valuation subring: `ℂ⟦X⟧ = {orderTop ≥ 0}` -/

theorem orderTop_nonneg_of_coeff_neg_eq_zero {x : LC}
    (h : ∀ n : ℤ, n < 0 → x.coeff n = 0) : (0 : WithTop ℤ) ≤ x.orderTop := by
  by_contra hlt
  push_neg at hlt
  have hx : x ≠ 0 := by
    rintro rfl
    simp at hlt
  have hord : (x.order : WithTop ℤ) < ((0 : ℤ) : WithTop ℤ) := by
    rw [HahnSeries.order_eq_orderTop_of_ne_zero hx]
    simpa using hlt
  have hord' : x.order < 0 := by exact_mod_cast hord
  have hne : x.coeff x.order ≠ 0 := by
    have := (HahnSeries.leadingCoeff_ne_zero (x := x)).mpr hx
    rwa [HahnSeries.leadingCoeff_eq] at this
  exact hne (h x.order hord')

theorem coeff_neg_eq_zero_of_mem_range {x : LC}
    (hx : x ∈ Set.range (HahnSeries.ofPowerSeries ℤ ℂ)) (n : ℤ) (hn : n < 0) :
    x.coeff n = 0 := by
  obtain ⟨p, rfl⟩ := hx
  rw [PowerSeries.coeff_coe, if_pos hn]

/-- **The image of `ℂ⟦X⟧` is the valuation subring.** A Laurent series is a power
series exactly when its `orderTop` is non-negative. -/
theorem mem_range_ofPowerSeries_iff (x : LC) :
    x ∈ Set.range (HahnSeries.ofPowerSeries ℤ ℂ) ↔ (0 : WithTop ℤ) ≤ x.orderTop := by
  constructor
  · intro hx
    exact orderTop_nonneg_of_coeff_neg_eq_zero (coeff_neg_eq_zero_of_mem_range hx)
  · intro h
    rcases eq_or_ne x 0 with rfl | hx
    · exact ⟨0, by simp⟩
    have hord : (0 : ℤ) ≤ x.order := by
      rw [← HahnSeries.order_eq_orderTop_of_ne_zero hx] at h
      exact_mod_cast h
    refine ⟨PowerSeries.X ^ x.order.toNat * x.powerSeriesPart, ?_⟩
    rw [map_mul, HahnSeries.ofPowerSeries_X_pow,
      LaurentSeries.ofPowerSeries_powerSeriesPart, ← mul_assoc,
      show ((x.order.toNat : ℤ)) = x.order from Int.toNat_of_nonneg hord,
      HahnSeries.single_mul_single, add_neg_cancel, mul_one, single_zero_one, one_mul]

/-- **Sharp threshold.** For a product of `m` normalized series, `q ^ k · ∏ fᵢ`
is a power series precisely when `k ≥ m`.  Cycle 1 proved the case `k = 0`,
`m ≥ 1` of the negative direction. -/
theorem qPow_mul_prod_mem_range_iff {ι : Type*} (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) :
    (qSeries ^ k * ∏ i ∈ s, f i) ∈ Set.range (HahnSeries.ofPowerSeries ℤ ℂ)
      ↔ s.card ≤ k := by
  rw [mem_range_ofPowerSeries_iff, HahnSeries.orderTop_mul, orderTop_qSeries_pow,
    orderTop_prod_normalized s f h, ← WithTop.coe_add]
  constructor
  · intro hle
    have : (0 : ℤ) ≤ (k : ℤ) + -(s.card : ℤ) := by exact_mod_cast hle
    omega
  · intro hle
    have : (0 : ℤ) ≤ (k : ℤ) + -(s.card : ℤ) := by omega
    exact_mod_cast this

/-! ## 2. Rigidity: the order is the only blinding-invariant `ℤ`-valued invariant -/

/-- The uniformizer `q`, as a unit of `ℂ⸨X⸩`. -/
noncomputable def qUnit : (LC)ˣ := qPowHom (Multiplicative.ofAdd (1 : ℤ))

@[simp] theorem poleLeak_qUnit : poleLeak qUnit = 1 := poleLeak_qPowHom 1

/-- **Rigidity theorem.** Any group homomorphism `φ : ℂ⸨X⸩ˣ →* Multiplicative ℤ`
that is trivial on the power-series units is completely determined by its value
on `q`: it equals `order` scaled by `φ(q)`.  Hence, up to an integer factor, the
pole-order obstruction is the *unique* multiplicative `ℤ`-valued invariant that
power-series blinding cannot see. -/
theorem hom_eq_order_smul (φ : (LC)ˣ →* Multiplicative ℤ)
    (hφ : ∀ p : (PowerSeries ℂ)ˣ, φ (psUnitHom p) = 1) (u : (LC)ˣ) :
    Multiplicative.toAdd (φ u) = poleLeak u * Multiplicative.toAdd (φ qUnit) := by
  obtain ⟨⟨p, k⟩, hk⟩ := unitsCompare_surjective u
  have hu : u = psUnitHom p * qPowHom k := by rw [← hk]; rfl
  have hleak : poleLeak u = Multiplicative.toAdd k := by
    rw [poleLeak, ← hk]
    exact order_unitsCompare p k
  have hq : qPowHom k = qUnit ^ (Multiplicative.toAdd k) := by
    rw [qUnit, ← map_zpow]
    congr 1
    apply Multiplicative.toAdd.injective
    simp
  rw [hleak, hu, map_mul, hφ p, one_mul, hq, map_zpow]
  simp

/-- Consequence: two blinding-invariant homomorphisms agreeing on `q` agree
everywhere. -/
theorem hom_ext_of_trivial_on_psUnits (φ ψ : (LC)ˣ →* Multiplicative ℤ)
    (hφ : ∀ p : (PowerSeries ℂ)ˣ, φ (psUnitHom p) = 1)
    (hψ : ∀ p : (PowerSeries ℂ)ˣ, ψ (psUnitHom p) = 1)
    (hq : φ qUnit = ψ qUnit) : φ = ψ := by
  ext u
  have h1 := hom_eq_order_smul φ hφ u
  have h2 := hom_eq_order_smul ψ hψ u
  have : Multiplicative.toAdd (φ u) = Multiplicative.toAdd (ψ u) := by
    rw [h1, h2, hq]
  simpa using this

/-! ## 3. Torsion-freeness: powers cannot destroy the obstruction -/

@[simp] theorem poleLeak_pow (u : (LC)ˣ) (n : ℕ) : poleLeak (u ^ n) = n * poleLeak u := by
  induction n with
  | zero => simp [poleLeak]
  | succ n ih =>
      rw [pow_succ, poleLeak_mul, ih]
      push_cast
      ring

/-- **No root trick.** For `n ≥ 1`, a power `u ^ n` is a unit power series only if
`u` itself already had order `0`: the obstruction group `ℤ` is torsion-free. -/
theorem pow_mem_range_psUnitHom_iff (u : (LC)ˣ) {n : ℕ} (hn : n ≠ 0) :
    (∃ p : (PowerSeries ℂ)ˣ, psUnitHom p = u ^ n)
      ↔ ∃ p : (PowerSeries ℂ)ˣ, psUnitHom p = u := by
  rw [← order_eq_zero_iff_exists_psUnit, ← order_eq_zero_iff_exists_psUnit]
  have hpow : poleLeak (u ^ n) = n * poleLeak u := poleLeak_pow u n
  constructor
  · intro h
    have h0 : (n : ℤ) * poleLeak u = 0 := by rw [← hpow]; exact h
    have hn0 : (n : ℤ) ≠ 0 := by exact_mod_cast hn
    rcases mul_eq_zero.mp h0 with h' | h'
    · exact absurd h' hn0
    · exact h'
  · intro h
    have : poleLeak u = 0 := h
    rw [show ((u ^ n : (LC)ˣ) : LC).order = poleLeak (u ^ n) from rfl, hpow, this, mul_zero]

/-- No power of the Monster-sized moonshine product is a power series. -/
theorem monsterUnit_pow_notMem_range (c : Fin monsterClassCount → ℕ → ℂ) {n : ℕ} (hn : n ≠ 0) :
    ¬ ∃ p : (PowerSeries ℂ)ˣ, psUnitHom p = monsterUnit c ^ n := by
  rw [pow_mem_range_psUnitHom_iff _ hn, ← order_eq_zero_iff_exists_psUnit]
  intro h
  have : poleLeak (monsterUnit c) = -194 := poleLeak_monsterUnit c
  rw [show ((monsterUnit c : (LC)ˣ) : LC).order = poleLeak (monsterUnit c) from rfl,
    this] at h
  omega

/-- The pole order of the `n`-th power of the moonshine product is `-194 n`. -/
theorem poleLeak_monsterUnit_pow (c : Fin monsterClassCount → ℕ → ℂ) (n : ℕ) :
    poleLeak (monsterUnit c ^ n) = -194 * n := by
  rw [poleLeak_pow, poleLeak_monsterUnit]
  ring

/-! ## 4. Positivity propagation -/

/-- A complex number that is a non-negative real. -/
def IsNonnegReal (z : ℂ) : Prop := ∃ r : ℝ, 0 ≤ r ∧ z = (r : ℂ)

theorem IsNonnegReal.zero : IsNonnegReal 0 := ⟨0, le_refl _, by norm_num⟩

theorem IsNonnegReal.one : IsNonnegReal 1 := ⟨1, by norm_num, by norm_num⟩

theorem IsNonnegReal.add {z w : ℂ} (hz : IsNonnegReal z) (hw : IsNonnegReal w) :
    IsNonnegReal (z + w) := by
  obtain ⟨r, hr, rfl⟩ := hz
  obtain ⟨t, ht, rfl⟩ := hw
  exact ⟨r + t, by linarith, by push_cast; ring⟩

theorem IsNonnegReal.mul {z w : ℂ} (hz : IsNonnegReal z) (hw : IsNonnegReal w) :
    IsNonnegReal (z * w) := by
  obtain ⟨r, hr, rfl⟩ := hz
  obtain ⟨t, ht, rfl⟩ := hw
  exact ⟨r * t, mul_nonneg hr ht, by push_cast; ring⟩

theorem IsNonnegReal.sum {ι : Type*} (s : Finset ι) (g : ι → ℂ)
    (h : ∀ i ∈ s, IsNonnegReal (g i)) : IsNonnegReal (∑ i ∈ s, g i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using IsNonnegReal.zero
  | insert a s ha ih =>
      rw [Finset.sum_insert ha]
      exact (h a (Finset.mem_insert_self a s)).add
        (ih (fun i hi => h i (Finset.mem_insert_of_mem hi)))

theorem IsNonnegReal.prod {ι : Type*} (s : Finset ι) (g : ι → ℂ)
    (h : ∀ i ∈ s, IsNonnegReal (g i)) : IsNonnegReal (∏ i ∈ s, g i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using IsNonnegReal.one
  | insert a s ha ih =>
      rw [Finset.prod_insert ha]
      exact (h a (Finset.mem_insert_self a s)).mul
        (ih (fun i hi => h i (Finset.mem_insert_of_mem hi)))

/-- **Positivity propagation.** If every factor of a Monster-type product is
normalized with non-negative real coefficients in all non-negative degrees, then
every coefficient of the product — in every degree — is a non-negative real.
The proof is a corollary of the all-degree convolution identity of cycle 3. -/
theorem isNonnegReal_coeff_prod {ι : Type*} [DecidableEq ι] (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i))
    (hpos : ∀ i ∈ s, ∀ k : ℕ, IsNonnegReal ((f i).coeff (k : ℤ))) (n : ℕ) :
    IsNonnegReal ((∏ i ∈ s, f i).coeff ((n : ℤ) - (s.card : ℤ))) := by
  rw [coeff_prod_normalized_general s f h n]
  refine IsNonnegReal.sum _ _ (fun l _ => IsNonnegReal.prod _ _ (fun i hi => ?_))
  rcases Nat.eq_zero_or_pos (l i) with hli | hli
  · rw [hli]
    simpa [(h i hi).coeff_neg_one] using IsNonnegReal.one
  · obtain ⟨k, hk⟩ : ∃ k : ℕ, l i = k + 1 := ⟨l i - 1, by omega⟩
    rw [hk, show (((k + 1 : ℕ) : ℤ) - 1) = (k : ℤ) by push_cast; ring]
    exact hpos i hi k

/-- Coefficients of the product in degrees below the pole vanish, so the previous
theorem covers every degree. -/
theorem coeff_prod_eq_zero_of_lt {ι : Type*} (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (d : ℤ) (hd : d < -(s.card : ℤ)) :
    (∏ i ∈ s, f i).coeff d = 0 := by
  refine HahnSeries.coeff_eq_zero_of_lt_orderTop ?_
  rw [orderTop_prod_normalized s f h]
  exact_mod_cast hd

/-- **Moonshine positivity.** For the Monster-sized product of `194` trace series
with non-negative real coefficients, every Laurent coefficient at degree
`n - 194` is a non-negative real. -/
theorem isNonnegReal_coeff_prod_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ)
    (hc : ∀ i k, IsNonnegReal (c i k)) (n : ℕ) :
    IsNonnegReal ((∏ i, traceLaurent (c i)).coeff ((n : ℤ) - 194)) := by
  have hcoeff : ∀ i : Fin monsterClassCount, ∀ k : ℕ,
      (traceLaurent (c i)).coeff (k : ℤ) = c i k := by
    intro i k
    have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk (c i))).coeff (k : ℤ) = c i k := by
      simp [HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk (c i)) k]
    have h2 : ((k : ℤ)) ≠ (-1 : ℤ) := by omega
    simp [traceLaurent, h1, h2]
  have h := isNonnegReal_coeff_prod (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i))
    (fun i _ k => by rw [hcoeff i k]; exact hc i k) n
  simpa [monsterClassCount] using h

end PoleOrderValuation