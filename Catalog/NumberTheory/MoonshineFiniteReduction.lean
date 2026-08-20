import Mathlib
import Shared.PoleOrderObstructionDeep
import NumberTheory.MoonshineHeadTable

/-!
# The Monstrous-Moonshine head product as a *decidable* arithmetic statement

This file is cycle 4 of the research thread
`Shared.PoleOrderObstruction` → `Shared.PoleOrderObstructionDeep` →
`NumberTheory.MoonshineHeadTable`.

The earlier cycles established:

* the product of the `194` McKay–Thompson series `T_g = q⁻¹ + c_g(1) q + ⋯` has a
  pole of order exactly `194`, and its first two Laurent coefficients above the
  pole are `0` and `∑_g c_g(1)`;
* for the eta-quotient classes, the numbers `c_g(1)` are themselves *computable*
  from the frame shape of `g`.

Here we finish the reduction programme.  The point is a **stable-range additivity
theorem**: if every factor of a finite product of power series is `≡ 1 mod qᵈ`,
then in the whole range `1 ≤ k < 2d` the `k`-th coefficient of the product is the
plain *sum* of the `k`-th coefficients — no symmetric-function corrections at all
(`MoonshineFiniteReduction.coeff_prod_of_isOneMod`).  McKay–Thompson series are
normalized so that `q · T_g ≡ 1 mod q²`, i.e. `d = 2`, so the first **three**
Laurent coefficients above the pole of the `194`-fold product are

`0`,  `∑_g c_g(1)`,  `∑_g c_g(2)`

(`MoonshineFiniteReduction.coeff_prod_normalized_head`).  This strictly extends
cycle 2, which reached only the second one, and it removes the Newton correction
term that appeared there.

Consequences formalized below.

* `MoonshineFiniteReduction.monster_head_reduction` — for an arbitrary integral
  table `c : Fin 194 → ℕ → ℤ` of moonshine-normalized coefficients, the *analytic*
  statement `(∏ T_g).coeff (-192) = N` over `ℂ` is **equivalent** to the finite
  *integer* statement `∑ g, c_g(1) = N`.
* `MoonshineFiniteReduction.decidableMonsterHead` — hence a genuine `Decidable`
  instance for that analytic statement: once the table is entered, the conjecture
  is discharged by `decide`.
* `MoonshineFiniteReduction.coeff_prod_etaClasses` — a worked, `decide`-checked
  instance: for the eight eta-quotient classes with balanced frame shapes
  `1^(-e) n^(e)`, whose head coefficients `276, 54, 20, 9, 2, 0, -1, -1` were
  *derived* in `NumberTheory.MoonshineHeadTable`, the eight-fold product satisfies
  `(∏ T_g).coeff (-6) = 359`, whatever the higher coefficients of the eight series
  are.
-/

namespace MoonshineFiniteReduction

open PowerSeries Finset PoleOrderObstruction

/-! ## 1. Stable-range additivity for power series congruent to `1` mod `q ^ d` -/

section StableRange

variable {R : Type*} [CommRing R] {ι : Type*}

/-- `f ≡ 1 mod qᵈ`: constant term `1` and vanishing coefficients in degrees
`1, …, d - 1`. -/
structure IsOneMod (d : ℕ) (f : R⟦X⟧) : Prop where
  /-- The constant term is `1`. -/
  const : constantCoeff f = 1
  /-- All coefficients strictly between `0` and `d` vanish. -/
  vanish : ∀ j, 0 < j → j < d → coeff j f = 0

/-- The class `IsOneMod d` is closed under multiplication. -/
theorem IsOneMod.mul {d : ℕ} {f g : R⟦X⟧} (hf : IsOneMod d f) (hg : IsOneMod d g) :
    IsOneMod d (f * g) := by
  refine ⟨by rw [map_mul, hf.const, hg.const, one_mul], ?_⟩
  intro j hj hjd
  rw [PowerSeries.coeff_mul]
  refine Finset.sum_eq_zero ?_
  rintro ⟨p, q⟩ hpq
  have hsum : p + q = j := Finset.mem_antidiagonal.mp hpq
  rcases Nat.eq_zero_or_pos p with rfl | hp
  · have hq : q = j := by omega
    subst hq
    rw [hg.vanish q hj hjd, mul_zero]
  · rw [hf.vanish p hp (by omega), zero_mul]

/-- **Stable-range additivity, two factors.**  If `f, g ≡ 1 mod qᵈ` then for every
degree `k` with `1 ≤ k < 2d` the `k`-th coefficient of `f * g` is
`coeff k f + coeff k g`: the quadratic cross terms all sit in degrees `≥ 2d`. -/
theorem coeff_mul_of_isOneMod {d k : ℕ} {f g : R⟦X⟧} (hf : IsOneMod d f)
    (hg : IsOneMod d g) (hk : 0 < k) (hk2 : k < 2 * d) :
    coeff k (f * g) = coeff k f + coeff k g := by
  have hmem1 : ((0, k) : ℕ × ℕ) ∈ Finset.antidiagonal k := Finset.mem_antidiagonal.mpr (by omega)
  have hmem2 : ((k, 0) : ℕ × ℕ) ∈ Finset.antidiagonal k := Finset.mem_antidiagonal.mpr (by omega)
  have hne : ((0, k) : ℕ × ℕ) ≠ (k, 0) := by
    simp only [ne_eq, Prod.mk.injEq, not_and]
    intro h
    omega
  have hzero : ∀ x ∈ Finset.antidiagonal k, x ≠ (0, k) ∧ x ≠ (k, 0) →
      coeff x.1 f * coeff x.2 g = 0 := by
    rintro ⟨p, q⟩ hmem ⟨hne1, hne2⟩
    have hsum : p + q = k := Finset.mem_antidiagonal.mp hmem
    have hp : 0 < p := by
      rcases Nat.eq_zero_or_pos p with hp0 | hp0
      · exact absurd (by subst hp0; rw [show q = k by omega]) hne1
      · exact hp0
    have hq : 0 < q := by
      rcases Nat.eq_zero_or_pos q with hq0 | hq0
      · exact absurd (by subst hq0; rw [show p = k by omega]) hne2
      · exact hq0
    rcases lt_or_ge p d with hpd | hpd
    · rw [hf.vanish p hp hpd, zero_mul]
    · have hqd : q < d := by omega
      rw [hg.vanish q hq hqd, mul_zero]
  rw [PowerSeries.coeff_mul, Finset.sum_eq_add_of_mem (0, k) (k, 0) hmem1 hmem2 hne hzero]
  simp only [coeff_zero_eq_constantCoeff, hf.const, hg.const]
  ring

/-- A finite product of series `≡ 1 mod qᵈ` is again `≡ 1 mod qᵈ`. -/
theorem isOneMod_prod {d : ℕ} (s : Finset ι) (g : ι → R⟦X⟧)
    (h : ∀ i ∈ s, IsOneMod d (g i)) : IsOneMod d (∏ i ∈ s, g i) := by
  classical
  induction s using Finset.induction with
  | empty =>
      exact ⟨map_one _, fun j hj _ => by
        simp [PowerSeries.coeff_one, show j ≠ 0 by omega]⟩
  | insert a s ha ih =>
      rw [Finset.prod_insert ha]
      exact (h a (Finset.mem_insert_self a s)).mul
        (ih fun i hi => h i (Finset.mem_insert_of_mem hi))

/-- **Stable-range additivity.**  For a finite family of power series all `≡ 1 mod qᵈ`
and any degree `1 ≤ k < 2d`, the `k`-th coefficient of the product is the sum of the
`k`-th coefficients.  All elementary-symmetric corrections vanish in this range. -/
theorem coeff_prod_of_isOneMod {d k : ℕ} (s : Finset ι) (g : ι → R⟦X⟧)
    (h : ∀ i ∈ s, IsOneMod d (g i)) (hk : 0 < k) (hk2 : k < 2 * d) :
    coeff k (∏ i ∈ s, g i) = ∑ i ∈ s, coeff k (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [PowerSeries.coeff_one, show k ≠ 0 by omega]
  | insert a s ha ih =>
      have hsub : ∀ i ∈ s, IsOneMod d (g i) := fun i hi => h i (Finset.mem_insert_of_mem hi)
      rw [Finset.prod_insert ha,
        coeff_mul_of_isOneMod (h a (Finset.mem_insert_self a s)) (isOneMod_prod s g hsub) hk hk2,
        ih hsub, Finset.sum_insert ha]

end StableRange

/-! ## 2. The first three Laurent coefficients above the pole -/

variable {ι : Type*}

/-- For a normalized Laurent series with vanishing constant term — the standard
normalization `T_g = q⁻¹ + O(q)` of a McKay–Thompson series — the associated power
series `q · T_g` is `≡ 1 mod q²`. -/
theorem isOneMod_two_normalizedPart {f : LC} (h : IsNormalized f) (h0 : f.coeff 0 = 0) :
    IsOneMod 2 (normalizedPart f) := by
  refine ⟨constantCoeff_normalizedPart f h, ?_⟩
  intro j hj hj2
  have : j = 1 := by omega
  subst this
  rw [coeff_one_normalizedPart f h, h0]

/-- **Head coefficients of a Monster-type product.**  Let `f i`, `i ∈ s`, be
`m = s.card` normalized series with vanishing constant terms.  Then for `j = 0, 1, 2`
the Laurent coefficient of `∏ f i` in degree `j + 1 - m` is exactly `∑ i, (f i).coeff j`.

For `j = 0` this says the subleading coefficient vanishes; for `j = 1` it recovers
`∑_g c_g(1)` (cycle 2, but now with no Newton correction term); for `j = 2` it is
new: the third coefficient above the pole is `∑_g c_g(2)`. -/
theorem coeff_prod_normalized_head (s : Finset ι) (f : ι → LC)
    (hn : ∀ i ∈ s, IsNormalized (f i)) (h0 : ∀ i ∈ s, (f i).coeff 0 = 0)
    {j : ℕ} (hj : j ≤ 2) :
    (∏ i ∈ s, f i).coeff ((j : ℤ) + 1 - (s.card : ℤ)) = ∑ i ∈ s, (f i).coeff (j : ℤ) := by
  classical
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff
        ((j + 1 : ℕ) : ℤ)
      = PowerSeries.coeff (j + 1) (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) (j + 1)
  rw [ofPowerSeries_prod_normalizedPart s f hn, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  have hkey : PowerSeries.coeff (j + 1) (∏ i ∈ s, normalizedPart (f i))
      = ∑ i ∈ s, (f i).coeff (j : ℤ) := by
    rw [coeff_prod_of_isOneMod (d := 2) s _
      (fun i hi => isOneMod_two_normalizedPart (hn i hi) (h0 i hi)) (by omega) (by omega)]
    refine Finset.sum_congr rfl (fun i hi => ?_)
    rw [coeff_normalizedPart (hn i hi) (j + 1)]
    congr 1
    push_cast
    ring
  rw [show ((j : ℤ) + 1 - (s.card : ℤ)) = (((j + 1 : ℕ) : ℤ) - (s.card : ℤ)) by push_cast; ring,
    hcoe, hkey]

/-! ## 3. Integral tables and the decidable reduction -/

/-- The McKay–Thompson-shaped Laurent series attached to a row `c : ℕ → ℤ` of an
integral coefficient table:  `q⁻¹ + ∑_{n ≥ 0} c n qⁿ`. -/
noncomputable def mtSeries (c : ℕ → ℤ) : LC := traceLaurent (fun n => (c n : ℂ))

theorem isNormalized_mtSeries (c : ℕ → ℤ) : IsNormalized (mtSeries c) :=
  isNormalized_traceLaurent _

@[simp] theorem coeff_zero_mtSeries (c : ℕ → ℤ) : (mtSeries c).coeff 0 = (c 0 : ℂ) :=
  coeff_zero_traceLaurent _

theorem coeff_succ_mtSeries (c : ℕ → ℤ) (n : ℕ) :
    (mtSeries c).coeff ((n : ℤ) + 1) = (c (n + 1) : ℂ) := by
  have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk (fun n => (c n : ℂ)))).coeff
      ((n : ℤ) + 1) = (c (n + 1) : ℂ) := by
    have h := HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (PowerSeries.mk (fun n => (c n : ℂ))) (n + 1)
    rw [show ((n + 1 : ℕ) : ℤ) = (n : ℤ) + 1 by push_cast; ring] at h
    simpa using h
  have hne : ((n : ℤ) + 1) ≠ (-1 : ℤ) := by omega
  simp [mtSeries, traceLaurent, h1, hne]

@[simp] theorem coeff_one_mtSeries (c : ℕ → ℤ) : (mtSeries c).coeff (1 : ℤ) = (c 1 : ℂ) := by
  simpa using coeff_succ_mtSeries c 0

@[simp] theorem coeff_two_mtSeries (c : ℕ → ℤ) : (mtSeries c).coeff (2 : ℤ) = (c 2 : ℂ) := by
  simpa using coeff_succ_mtSeries c 1

/-- **Reduction theorem for an integral table.**  For `m` moonshine-normalized rows
the Laurent coefficient of the product in degree `2 - m` is the integer
`∑ i, c i 1`, viewed in `ℂ`. -/
theorem coeff_prod_mtSeries_head (m : ℕ) (c : Fin m → ℕ → ℤ) (h0 : ∀ i, c i 0 = 0) :
    (∏ i, mtSeries (c i)).coeff (2 - (m : ℤ)) = ((∑ i, c i 1 : ℤ) : ℂ) := by
  have hcard : (Finset.univ : Finset (Fin m)).card = m := by simp
  have h := coeff_prod_normalized_head (Finset.univ : Finset (Fin m)) (fun i => mtSeries (c i))
    (fun i _ => isNormalized_mtSeries (c i))
    (fun i _ => by rw [coeff_zero_mtSeries, h0 i]; norm_num) (j := 1) (by omega)
  rw [hcard] at h
  rw [show (2 - (m : ℤ)) = ((1 : ℕ) : ℤ) + 1 - (m : ℤ) by push_cast; ring, h]
  push_cast
  refine Finset.sum_congr rfl (fun i _ => ?_)
  norm_num

/-- The analogous statement one degree higher: the coefficient in degree `3 - m` is
`∑ i, c i 2`.  This coefficient was out of reach of the Newton identities of
cycle 2. -/
theorem coeff_prod_mtSeries_head_two (m : ℕ) (c : Fin m → ℕ → ℤ) (h0 : ∀ i, c i 0 = 0) :
    (∏ i, mtSeries (c i)).coeff (3 - (m : ℤ)) = ((∑ i, c i 2 : ℤ) : ℂ) := by
  have hcard : (Finset.univ : Finset (Fin m)).card = m := by simp
  have h := coeff_prod_normalized_head (Finset.univ : Finset (Fin m)) (fun i => mtSeries (c i))
    (fun i _ => isNormalized_mtSeries (c i))
    (fun i _ => by rw [coeff_zero_mtSeries, h0 i]; norm_num) (j := 2) (by omega)
  rw [hcard] at h
  rw [show (3 - (m : ℤ)) = ((2 : ℕ) : ℤ) + 1 - (m : ℤ) by push_cast; ring, h]
  push_cast
  refine Finset.sum_congr rfl (fun i _ => ?_)
  norm_num

/-- **The conjecture becomes finite arithmetic.**  For an arbitrary integral table of
`m` moonshine-normalized McKay–Thompson coefficient rows, the analytic identity
`(∏ T_g).coeff (2 - m) = N` in `ℂ` holds **iff** the integer identity
`∑ g, c_g(1) = N` holds. -/
theorem head_reduction_iff (m : ℕ) (c : Fin m → ℕ → ℤ) (h0 : ∀ i, c i 0 = 0) (N : ℤ) :
    (∏ i, mtSeries (c i)).coeff (2 - (m : ℤ)) = (N : ℂ) ↔ ∑ i, c i 1 = N := by
  rw [coeff_prod_mtSeries_head m c h0]
  exact ⟨fun h => by exact_mod_cast h, fun h => by exact_mod_cast congrArg (fun z : ℤ => (z : ℂ)) h⟩

/-- Specialization to the `194` conjugacy classes of the Monster. -/
theorem monster_head_reduction (c : Fin PoleOrderObstruction.monsterClassCount → ℕ → ℤ)
    (h0 : ∀ i, c i 0 = 0) (N : ℤ) :
    (∏ i, mtSeries (c i)).coeff (-192 : ℤ) = (N : ℂ) ↔ ∑ i, c i 1 = N := by
  have := head_reduction_iff PoleOrderObstruction.monsterClassCount c h0 N
  simpa [PoleOrderObstruction.monsterClassCount] using this

/-- **Decidability of the analytic statement.**  Because of the reduction, the
statement `(∏_{g} T_g).coeff (-192) = N` about a product of `194` complex Laurent
series is *decidable* as soon as the integer table is given: it is discharged by
evaluating a sum of `194` integers.  This is the precise sense in which the
Monstrous-Moonshine head identity has become a finite, checkable arithmetic
statement. -/
noncomputable instance decidableMonsterHead
    (c : Fin PoleOrderObstruction.monsterClassCount → ℕ → ℤ) (h0 : ∀ i, c i 0 = 0) (N : ℤ) :
    Decidable ((∏ i, mtSeries (c i)).coeff (-192 : ℤ) = (N : ℂ)) :=
  decidable_of_iff _ (monster_head_reduction c h0 N).symm

/-! ## 4. A worked, `decide`-checked instance: the eight eta-quotient classes -/

open MoonshineHeadTable

/-- **The eight eta-quotient classes.**  Let `T₁, …, T₈` be normalized McKay–Thompson
series whose head coefficients are the eight numbers *derived* from the balanced
frame shapes `1^(-e) n^(e)` in `NumberTheory.MoonshineHeadTable` (namely
`276, 54, 20, 9, 2, 0, -1, -1`).  Whatever their higher coefficients, the product
`T₁ ⋯ T₈` has Laurent coefficient `359` in degree `-6`, one above its pole of
order `8`. -/
theorem coeff_prod_etaClasses (c : Fin 8 → ℕ → ℤ) (h0 : ∀ i, c i 0 = 0)
    (h1 : ∀ i, c i 1 = etaHeadTable i) :
    (∏ i, mtSeries (c i)).coeff (-6 : ℤ) = (359 : ℂ) := by
  have hiff := head_reduction_iff 8 c h0 359
  norm_num at hiff
  rw [hiff]
  rw [Finset.sum_congr rfl (fun i _ => h1 i)]
  exact sum_etaHeadTable

/-! ## 5. The boundary of the stable range, and its sharpness

The additivity of §1 holds for `1 ≤ k < 2d` and *fails* at `k = 2d`
(`MoonshineFiniteReduction.stable_range_sharp`).  At the boundary degree the
correction is exactly the second elementary symmetric function of the degree-`d`
coefficients, so the reduction to finite arithmetic survives — with an extra term.
For McKay–Thompson series (`d = 2`) this computes the *fourth* Laurent coefficient
above the pole. -/

section Boundary

variable {R : Type*} [CommRing R] {ι : Type*}

/-- Two-factor identity at the boundary degree `4 = 2 · 2`. -/
theorem coeff_four_mul_of_isOneMod_two {f g : R⟦X⟧} (hf : IsOneMod 2 f) (hg : IsOneMod 2 g) :
    coeff 4 (f * g) = coeff 4 f + coeff 4 g + coeff 2 f * coeff 2 g := by
  have hanti : Finset.antidiagonal (4 : ℕ) = {(0, 4), (1, 3), (2, 2), (3, 1), (4, 0)} := rfl
  rw [PowerSeries.coeff_mul, hanti]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  simp only [coeff_zero_eq_constantCoeff, hf.const, hg.const,
    hf.vanish 1 (by omega) (by omega), hg.vanish 1 (by omega) (by omega)]
  ring

/-- **Newton correction at the boundary.**  For a finite family of power series
`≡ 1 mod q²`, the coefficient in the boundary degree `4` of the product is the sum of
the individual degree-`4` coefficients *plus* the second elementary symmetric function
of the degree-`2` coefficients. -/
theorem two_mul_coeff_four_prod_of_isOneMod_two (s : Finset ι) (g : ι → R⟦X⟧)
    (h : ∀ i ∈ s, IsOneMod 2 (g i)) :
    2 * coeff 4 (∏ i ∈ s, g i) =
      2 * (∑ i ∈ s, coeff 4 (g i)) + (∑ i ∈ s, coeff 2 (g i)) ^ 2
        - ∑ i ∈ s, (coeff 2 (g i)) ^ 2 := by
  classical
  induction s using Finset.induction with
  | empty => simp [PowerSeries.coeff_one]
  | insert a s ha ih =>
      have hsub : ∀ i ∈ s, IsOneMod 2 (g i) := fun i hi => h i (Finset.mem_insert_of_mem hi)
      have hcoeff2 : coeff 2 (∏ i ∈ s, g i) = ∑ i ∈ s, coeff 2 (g i) :=
        coeff_prod_of_isOneMod (d := 2) s g hsub (by omega) (by omega)
      have ihs := ih hsub
      rw [Finset.prod_insert ha,
        coeff_four_mul_of_isOneMod_two (h a (Finset.mem_insert_self a s))
          (isOneMod_prod s g hsub),
        hcoeff2, Finset.sum_insert ha, Finset.sum_insert ha, Finset.sum_insert ha]
      linear_combination ihs

/-- **Sharpness of the stable range.**  Additivity genuinely fails at the boundary
degree `k = 2d`: for `f = g = 1 + q²` (which are `≡ 1 mod q²`) the degree-`4`
coefficient of the product is `1`, not `0 + 0`. -/
theorem stable_range_sharp :
    ∃ f g : ℤ⟦X⟧, IsOneMod 2 f ∧ IsOneMod 2 g ∧ coeff 4 (f * g) ≠ coeff 4 f + coeff 4 g := by
  refine ⟨1 + X ^ 2, 1 + X ^ 2, ?_, ?_, ?_⟩
  · exact ⟨by simp, fun j hj hj2 => by
      rw [show j = 1 by omega]
      simp [PowerSeries.coeff_one, PowerSeries.coeff_X_pow]⟩
  · exact ⟨by simp, fun j hj hj2 => by
      rw [show j = 1 by omega]
      simp [PowerSeries.coeff_one, PowerSeries.coeff_X_pow]⟩
  · rw [show ((1 : ℤ⟦X⟧) + X ^ 2) * (1 + X ^ 2) = 1 + X ^ 2 + X ^ 2 + X ^ 4 by ring]
    simp [PowerSeries.coeff_one, PowerSeries.coeff_X_pow]

end Boundary

/-- **Fourth Laurent coefficient above the pole.**  For `m` normalized series with
vanishing constant terms the coefficient in degree `4 - m` is
`∑ c_g(3) + e₂(c_g(1))`, written without division. -/
theorem two_mul_coeff_prod_normalized_head_four (s : Finset ι) (f : ι → LC)
    (hn : ∀ i ∈ s, IsNormalized (f i)) (h0 : ∀ i ∈ s, (f i).coeff 0 = 0) :
    2 * (∏ i ∈ s, f i).coeff (4 - (s.card : ℤ)) =
      2 * (∑ i ∈ s, (f i).coeff 3) + (∑ i ∈ s, (f i).coeff 1) ^ 2
        - ∑ i ∈ s, ((f i).coeff 1) ^ 2 := by
  classical
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff
        ((4 : ℕ) : ℤ) = PowerSeries.coeff 4 (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) 4
  rw [ofPowerSeries_prod_normalizedPart s f hn, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  have hone : ∀ i ∈ s, IsOneMod 2 (normalizedPart (f i)) :=
    fun i hi => isOneMod_two_normalizedPart (hn i hi) (h0 i hi)
  have e4 : ∀ i ∈ s, PowerSeries.coeff 4 (normalizedPart (f i)) = (f i).coeff 3 := by
    intro i hi
    rw [coeff_normalizedPart (hn i hi) 4]
    norm_num
  have e2 : ∀ i ∈ s, PowerSeries.coeff 2 (normalizedPart (f i)) = (f i).coeff 1 := by
    intro i hi
    rw [coeff_normalizedPart (hn i hi) 2]
    norm_num
  rw [show (4 - (s.card : ℤ)) = (((4 : ℕ) : ℤ) - (s.card : ℤ)) by push_cast; ring, hcoe,
    two_mul_coeff_four_prod_of_isOneMod_two s _ hone,
    Finset.sum_congr rfl e4, Finset.sum_congr rfl e2,
    Finset.sum_congr rfl (fun i hi => by rw [e2 i hi] :
      ∀ i ∈ s, PowerSeries.coeff 2 (normalizedPart (f i)) ^ 2 = ((f i).coeff 1) ^ 2)]

/-! ## 6. The Monster: three reduced head coefficients -/

/-- Laurent coefficient of the `194`-fold Monster product in degree `-192`:
`∑_g c_g(1)`. -/
theorem monster_coeff_neg_192 (c : Fin PoleOrderObstruction.monsterClassCount → ℕ → ℤ)
    (h0 : ∀ i, c i 0 = 0) :
    (∏ i, mtSeries (c i)).coeff (-192 : ℤ) = ((∑ i, c i 1 : ℤ) : ℂ) := by
  have := coeff_prod_mtSeries_head PoleOrderObstruction.monsterClassCount c h0
  simpa [PoleOrderObstruction.monsterClassCount] using this

/-- Laurent coefficient of the `194`-fold Monster product in degree `-191`:
`∑_g c_g(2)`. -/
theorem monster_coeff_neg_191 (c : Fin PoleOrderObstruction.monsterClassCount → ℕ → ℤ)
    (h0 : ∀ i, c i 0 = 0) :
    (∏ i, mtSeries (c i)).coeff (-191 : ℤ) = ((∑ i, c i 2 : ℤ) : ℂ) := by
  have := coeff_prod_mtSeries_head_two PoleOrderObstruction.monsterClassCount c h0
  simpa [PoleOrderObstruction.monsterClassCount] using this

end MoonshineFiniteReduction