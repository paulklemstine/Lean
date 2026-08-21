import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Computation.PoleOrderTorsor

/-!
# Orbits of the corrected product, and the invariants that separate them

`Computation.PoleOrderTorsor` proved that the corrected product `f ⋆ g = q · f · g` is a
closed operation on normalized `q`-series (`PoleOrderTorsor.isNormalized_q_mul_mul`) and in fact
makes them a commutative group `PoleOrderTorsor.Norm ≃* 1 + X·ℂ⟦X⟧`.

This file answers the question that closure makes well posed: *what invariant distinguishes the
`⋆`-orbits?*  The answer is a complete hierarchy.

* `PoleOrderTorsor.LowVanish` and the coefficient calculus
  (`PoleOrderTorsor.coeff_mul_split`, `PoleOrderTorsor.coeff_pow_of_lowVanish`): if the first
  `k-1` non-constant coefficients of two one-units vanish, the `k`-th coefficient of a product is
  the *sum* of the `k`-th coefficients.  So each level of the filtration is additive.
* `PoleOrderTorsor.deepSubgroup` — the resulting descending chain of subgroups of `Norm`,
  with graded homomorphisms `PoleOrderTorsor.gradedHom` onto `(ℂ, +)`
  (`PoleOrderTorsor.gradedHom_surjective`), whose kernels are the next stage
  (`PoleOrderTorsor.mem_deepSubgroup_succ_iff`), and whose intersection is trivial
  (`PoleOrderTorsor.eq_one_of_forall_coeffAt_eq_zero`).
* `PoleOrderTorsor.a₀_not_complete` — the *first* invariant `a₀` (the constant Laurent
  coefficient, `PoleOrderTorsor.leadCoeffHom`) is **not** complete: an explicit normalized series
  `q⁻¹ + q` is `≠ 1` with `a₀ = 0`.  The filtration is genuinely needed.
* `PoleOrderTorsor.first_invariant` — but the *first non-vanishing* invariant always works: for
  `f ≠ 1` there is a unique level `k` at which `f` first differs from the base point, its value
  `c ≠ 0` there, and every iterate satisfies `coeffAt k (f^{⋆n}) = n · c`.  In particular:
* `PoleOrderTorsor.Norm.pow_eq_one_iff` — the group is **torsion-free**;
* `PoleOrderTorsor.Norm.orbit_injective` — every non-trivial `⋆`-orbit is infinite;
* `PoleOrderTorsor.Norm.existsUnique_root` — and it is **uniquely divisible**: every normalized
  series has a unique `n`-th `⋆`-root for every `n ≥ 1`.  Existence uses the binomial series
  `(1 + X)^{1/n}` substituted into `q·f - 1`; uniqueness uses torsion-freeness.

Consequently `Norm` is a divisible torsion-free abelian group — a `ℚ`-vector space — so no
finite-order phenomenon can ever appear among corrected-product orbits, and the invariant that
separates two orbits is always the first level of the coefficient filtration at which they differ.
-/

namespace PoleOrderTorsor

open HahnSeries PoleOrderObstruction PowerSeries

/-! ## Coefficient calculus for deep one-units -/

/-- `LowVanish k a` says that the coefficients of `a` in degrees `1, …, k-1` vanish. -/
def LowVanish (k : ℕ) (a : PowerSeries ℂ) : Prop := ∀ i, 0 < i → i < k → coeff i a = 0

theorem lowVanish_one (k : ℕ) : LowVanish k (1 : PowerSeries ℂ) := by
  intro i hi _
  rw [PowerSeries.coeff_one, if_neg (by omega)]

/-- Below the vanishing threshold, multiplication only sees the constant term of the left
factor. -/
theorem coeff_mul_of_lowVanish_left {a b : PowerSeries ℂ} {k : ℕ} (ha : LowVanish k a)
    (m : ℕ) (hm : m < k) : coeff m (a * b) = constantCoeff a * coeff m b := by
  rw [PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk,
    Finset.sum_range_succ']
  have hmid : ∑ i ∈ Finset.range m, coeff (i + 1) a * coeff (m - (i + 1)) b = 0 := by
    refine Finset.sum_eq_zero ?_
    intro i hi
    rw [Finset.mem_range] at hi
    rw [ha (i + 1) (by omega) (by omega), zero_mul]
  rw [hmid, zero_add]
  simp [PowerSeries.coeff_zero_eq_constantCoeff]

/-- A product of two `k`-deep series is `k`-deep. -/
theorem lowVanish_mul {a b : PowerSeries ℂ} {k : ℕ} (ha : LowVanish k a) (hb : LowVanish k b) :
    LowVanish k (a * b) := by
  intro m hm0 hmk
  rw [PowerSeries.coeff_mul]
  refine Finset.sum_eq_zero ?_
  rintro ⟨x, y⟩ hxy
  rw [Finset.mem_antidiagonal] at hxy
  rcases Nat.eq_zero_or_pos x with hx | hx
  · rw [hb y (by omega) (by omega), mul_zero]
  · rw [ha x hx (by omega), zero_mul]

/-- **Additivity at the first surviving level.**  At the threshold `k` the coefficient of a
product of two `k`-deep series splits as a sum. -/
theorem coeff_mul_split {a b : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (ha : LowVanish k a) (hb : LowVanish k b) :
    coeff k (a * b) = constantCoeff a * coeff k b + coeff k a * constantCoeff b := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  rw [PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk,
    Finset.sum_range_succ, Finset.sum_range_succ']
  have hmid : ∑ i ∈ Finset.range j, coeff (i + 1) a * coeff (j + 1 - (i + 1)) b = 0 := by
    refine Finset.sum_eq_zero ?_
    intro i hi
    rw [Finset.mem_range] at hi
    rw [ha (i + 1) (by omega) (by omega), zero_mul]
  rw [hmid, zero_add]
  simp [PowerSeries.coeff_zero_eq_constantCoeff]

/-- The inverse of a `k`-deep one-unit is `k`-deep. -/
theorem lowVanish_inv {a : PowerSeries ℂ} {k : ℕ} (ha0 : constantCoeff a = 1)
    (ha : LowVanish k a) : LowVanish k a⁻¹ := by
  intro m hm0 hmk
  have hcancel : a * a⁻¹ = 1 := PowerSeries.mul_inv_cancel a (by rw [ha0]; exact one_ne_zero)
  have h := coeff_mul_of_lowVanish_left (b := a⁻¹) ha m hmk
  rw [hcancel, ha0, one_mul, PowerSeries.coeff_one, if_neg (by omega)] at h
  exact h.symm

/-- At the threshold level, inversion negates the invariant. -/
theorem coeff_inv_of_lowVanish {a : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (ha0 : constantCoeff a = 1) (ha : LowVanish k a) : coeff k a⁻¹ = -coeff k a := by
  have ha0' : constantCoeff a ≠ 0 := by rw [ha0]; exact one_ne_zero
  have hcancel : a * a⁻¹ = 1 := PowerSeries.mul_inv_cancel a ha0'
  have hinv0 : constantCoeff a⁻¹ = 1 := by rw [PowerSeries.constantCoeff_inv, ha0, inv_one]
  have h := coeff_mul_split hk ha (lowVanish_inv ha0 ha)
  rw [hcancel, ha0, hinv0, one_mul, mul_one, PowerSeries.coeff_one, if_neg (by omega)] at h
  linear_combination -h

/-- **Iteration formula.**  For a `k`-deep one-unit the `k`-th coefficient of the `n`-th power is
`n` times the `k`-th coefficient — the invariant scales linearly along an orbit. -/
theorem coeff_pow_of_lowVanish {a : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (ha0 : constantCoeff a = 1) (ha : LowVanish k a) (n : ℕ) :
    LowVanish k (a ^ n) ∧ constantCoeff (a ^ n) = 1 ∧ coeff k (a ^ n) = n * coeff k a := by
  induction n with
  | zero =>
      refine ⟨by simpa using lowVanish_one k, by simp, ?_⟩
      rw [pow_zero, PowerSeries.coeff_one, if_neg (by omega)]
      simp
  | succ n ih =>
      obtain ⟨ih1, ih2, ih3⟩ := ih
      refine ⟨by rw [pow_succ]; exact lowVanish_mul ih1 ha, by simp [ha0], ?_⟩
      rw [pow_succ, coeff_mul_split hk ih1 ha, ih2, ha0, one_mul, mul_one, ih3]
      push_cast
      ring

/-! ## Torsion-freeness of the one-unit group -/

/-- **Torsion-freeness.**  In characteristic zero a one-unit power series with `uⁿ = 1`,
`n ≥ 1`, is `1`.  The proof isolates the first coefficient where `u` differs from `1` and uses
the linear iteration formula `coeff k (uⁿ) = n · coeff k u`. -/
theorem pow_eq_one_of_constantCoeff_one {u : PowerSeries ℂ} (hu : constantCoeff u = 1)
    {n : ℕ} (hn : n ≠ 0) (hpow : u ^ n = 1) : u = 1 := by
  classical
  by_contra hne
  have hex : ∃ k, coeff k u ≠ coeff k (1 : PowerSeries ℂ) := by
    by_contra h
    push_neg at h
    exact hne (PowerSeries.ext h)
  set k := Nat.find hex with hk
  have hkspec : coeff k u ≠ coeff k (1 : PowerSeries ℂ) := Nat.find_spec hex
  have hk0 : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h | h
    · exfalso
      apply hkspec
      rw [h]
      simp [PowerSeries.coeff_zero_eq_constantCoeff, hu]
    · exact h
  have hdeep : LowVanish k u := by
    intro i hi0 hik
    have := Nat.find_min hex (m := i) (by omega)
    push_neg at this
    rw [this, PowerSeries.coeff_one, if_neg (by omega)]
  have hcoeff1 : coeff k (1 : PowerSeries ℂ) = 0 := by
    rw [PowerSeries.coeff_one, if_neg (by omega)]
  obtain ⟨-, -, hiter⟩ := coeff_pow_of_lowVanish hk0 hu hdeep n
  rw [hpow, hcoeff1] at hiter
  have hn' : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  have : coeff k u = 0 := by
    rcases mul_eq_zero.mp hiter.symm with h | h
    · exact absurd h hn'
    · exact h
  exact hkspec (by rw [this, hcoeff1])

/-! ## Divisibility: `n`-th roots via the binomial series -/

/-- Powers of the binomial series multiply the exponent. -/
theorem powerSeries_binomialSeries_pow (r : ℂ) (n : ℕ) :
    (PowerSeries.binomialSeries ℂ r) ^ n = PowerSeries.binomialSeries ℂ ((n : ℂ) * r) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, ih, ← PowerSeries.binomialSeries_add]
      congr 1
      push_cast
      ring

/-- **Existence of `n`-th roots of one-units.**  Substituting `u - 1` into the binomial series
`(1 + X)^{1/n}` produces an `n`-th root, which is then rescaled to have constant term `1`. -/
theorem exists_pow_eq_of_constantCoeff_one {u : PowerSeries ℂ} (hu : constantCoeff u = 1)
    {n : ℕ} (hn : n ≠ 0) : ∃ v : PowerSeries ℂ, constantCoeff v = 1 ∧ v ^ n = u := by
  have hw : constantCoeff (u - 1) = 0 := by simp [hu]
  have hsub : PowerSeries.HasSubst (u - 1) := PowerSeries.HasSubst.of_constantCoeff_zero' hw
  have hn' : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  set B : PowerSeries ℂ := PowerSeries.binomialSeries ℂ ((n : ℂ)⁻¹) with hB
  have hBn : B ^ n = 1 + PowerSeries.X := by
    rw [hB, powerSeries_binomialSeries_pow, mul_inv_cancel₀ hn']
    have : (1 : ℂ) = ((1 : ℕ) : ℂ) := by norm_num
    rw [this, PowerSeries.binomialSeries_nat, pow_one]
  set v₀ : PowerSeries ℂ := PowerSeries.subst (u - 1) B with hv₀
  have hv₀n : v₀ ^ n = u := by
    rw [hv₀, ← PowerSeries.subst_pow hsub, hBn, PowerSeries.subst_add hsub,
      PowerSeries.subst_X hsub]
    have hone : PowerSeries.subst (u - 1) (1 : PowerSeries ℂ) = 1 := by
      rw [← PowerSeries.coe_substAlgHom hsub, map_one]
    rw [hone]
    ring
  set c : ℂ := constantCoeff v₀ with hc
  have hcn : c ^ n = 1 := by
    have := congrArg constantCoeff hv₀n
    rwa [map_pow, hu] at this
  have hc0 : c ≠ 0 := by
    intro h
    rw [h, zero_pow hn] at hcn
    exact zero_ne_one hcn
  refine ⟨PowerSeries.C c⁻¹ * v₀, ?_, ?_⟩
  · rw [map_mul, PowerSeries.constantCoeff_C, ← hc, inv_mul_cancel₀ hc0]
  · rw [mul_pow, ← map_pow, inv_pow, hcn, inv_one, map_one, one_mul, hv₀n]

/-! ## The group-level consequences on `Norm` -/

theorem toOneUnit_one : toOneUnit (1 : Norm) = 1 := map_one normEquivOneUnit

theorem toOneUnit_pow (f : Norm) (n : ℕ) : toOneUnit (f ^ n) = toOneUnit f ^ n :=
  map_pow normEquivOneUnit f n

namespace Norm

/-- The level-`k` coefficient invariant of a normalized series: the `k`-th coefficient of the
one-unit `q · f`.  Equivalently the Laurent coefficient of `f` in degree `k - 1`. -/
noncomputable def coeffAt (k : ℕ) (f : Norm) : ℂ := coeff k (toOneUnit f : PowerSeries ℂ)

theorem coeffAt_eq_coeff (k : ℕ) (f : Norm) :
    coeffAt k f = (f : LC).coeff ((k : ℤ) - 1) :=
  coeff_normalizedPart f.2 k

@[simp] theorem coeffAt_zero (f : Norm) : coeffAt 0 f = 1 := by
  rw [coeffAt, PowerSeries.coeff_zero_eq_constantCoeff]
  exact (toOneUnit f).constantCoeff_val

theorem coeffAt_one (k : ℕ) (hk : 0 < k) : coeffAt k (1 : Norm) = 0 := by
  have h1 : (toOneUnit (1 : Norm) : PowerSeries ℂ) = 1 := by rw [toOneUnit_one]; rfl
  rw [coeffAt, h1, PowerSeries.coeff_one, if_neg (by omega)]

theorem coeffAt_toOneUnit (k : ℕ) (f : Norm) :
    coeffAt k f = coeff k (toOneUnit f : PowerSeries ℂ) := rfl

/-- Two normalized series with the same one-unit coefficients coincide. -/
theorem eq_of_forall_coeffAt_eq {f g : Norm} (h : ∀ k, coeffAt k f = coeffAt k g) : f = g :=
  normEquivOneUnit.injective (OneUnit.ext (PowerSeries.ext h))

/-- **Separation.**  Only the base point `q⁻¹` has all higher invariants zero. -/
theorem eq_one_of_forall_coeffAt_eq_zero {f : Norm} (h : ∀ k, 0 < k → coeffAt k f = 0) :
    f = 1 := by
  refine eq_of_forall_coeffAt_eq (fun k => ?_)
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · rw [coeffAt_zero, coeffAt_zero]
  · rw [h k hk, coeffAt_one k hk]

/-- **Torsion-freeness of the corrected-product group.** -/
theorem pow_eq_one_iff {f : Norm} {n : ℕ} (hn : n ≠ 0) : f ^ n = 1 ↔ f = 1 := by
  constructor
  · intro hpow
    have h : (toOneUnit f : PowerSeries ℂ) ^ n = 1 := by
      have h2 : toOneUnit (f ^ n) = 1 := by rw [hpow, toOneUnit_one]
      rw [toOneUnit_pow] at h2
      have := congrArg (fun w : OneUnit => (w : PowerSeries ℂ)) h2
      simpa [OneUnit.val_pow] using this
    have hv := pow_eq_one_of_constantCoeff_one (toOneUnit f).constantCoeff_val hn h
    refine normEquivOneUnit.injective ?_
    show toOneUnit f = toOneUnit 1
    rw [toOneUnit_one]
    exact OneUnit.ext (by simpa using hv)
  · rintro rfl
    exact one_pow n

/-- Taking `n`-th `⋆`-powers is injective for `n ≥ 1`. -/
theorem pow_left_injective {n : ℕ} (hn : n ≠ 0) :
    Function.Injective (fun f : Norm => f ^ n) := by
  intro f g h
  simp only at h
  have hone : (f * g⁻¹) ^ n = 1 := by
    rw [mul_pow, inv_pow, h, mul_inv_cancel]
  exact mul_inv_eq_one.1 ((pow_eq_one_iff hn).1 hone)

/-- **Unique divisibility.**  Every normalized series has a unique `n`-th corrected-product root
for every `n ≥ 1`: the corrected-product group is a `ℚ`-vector space. -/
theorem existsUnique_root (f : Norm) {n : ℕ} (hn : n ≠ 0) : ∃! g : Norm, g ^ n = f := by
  obtain ⟨v, hv1, hvn⟩ :=
    exists_pow_eq_of_constantCoeff_one (toOneUnit f).constantCoeff_val hn
  have hroot : (normEquivOneUnit.symm ⟨v, hv1⟩ : Norm) ^ n = f := by
    apply normEquivOneUnit.injective
    rw [map_pow, MulEquiv.apply_symm_apply]
    exact OneUnit.ext (by simpa using hvn)
  refine ⟨normEquivOneUnit.symm ⟨v, hv1⟩, hroot, fun g hg => ?_⟩
  exact pow_left_injective hn (show g ^ n = (normEquivOneUnit.symm ⟨v, hv1⟩ : Norm) ^ n by
    rw [hg, hroot])

/-- **Every non-trivial orbit is infinite.** -/
theorem orbit_injective {f : Norm} (hf : f ≠ 1) : Function.Injective (fun n : ℕ => f ^ n) := by
  have key : ∀ p q : ℕ, p < q → f ^ p = f ^ q → False := by
    intro p q hpq h
    have hcancel : f ^ (q - p) * f ^ p = 1 * f ^ p := by
      rw [← _root_.pow_add, one_mul, show q - p + p = q by omega, ← h]
    exact hf ((pow_eq_one_iff (by omega)).1 (mul_right_cancel hcancel))
  intro m n hmn
  simp only at hmn
  rcases lt_trichotomy m n with h | h | h
  · exact absurd hmn (fun hc => key m n h hc)
  · exact h
  · exact absurd hmn.symm (fun hc => key n m h hc)

/-! ### The coefficient filtration -/

/-- The `k`-th stage of the coefficient filtration: normalized series agreeing with the base
point `q⁻¹` to order `k`. -/
def deepSubgroup (k : ℕ) : Subgroup Norm where
  carrier := {f | LowVanish k (toOneUnit f : PowerSeries ℂ)}
  mul_mem' {f g} hf hg := by
    show LowVanish k ((toOneUnit (f * g) : PowerSeries ℂ))
    rw [toOneUnit_mul]
    simpa only [OneUnit.val_mul] using lowVanish_mul hf hg
  one_mem' := by
    show LowVanish k ((toOneUnit (1 : Norm) : PowerSeries ℂ))
    rw [toOneUnit_one]
    simpa only [OneUnit.val_one] using lowVanish_one k
  inv_mem' {f} hf := by
    show LowVanish k ((toOneUnit f⁻¹ : PowerSeries ℂ))
    rw [show toOneUnit f⁻¹ = (toOneUnit f)⁻¹ from map_inv normEquivOneUnit f]
    simpa only [OneUnit.val_inv] using
      lowVanish_inv (toOneUnit f).constantCoeff_val hf

theorem mem_deepSubgroup_iff (k : ℕ) (f : Norm) :
    f ∈ deepSubgroup k ↔ ∀ i, 0 < i → i < k → coeffAt i f = 0 := Iff.rfl

/-- The filtration is descending, and passing from stage `k` to stage `k+1` is exactly the
vanishing of the level-`k` invariant. -/
theorem mem_deepSubgroup_succ_iff (k : ℕ) (f : Norm) :
    f ∈ deepSubgroup (k + 1) ↔ f ∈ deepSubgroup k ∧ (0 < k → coeffAt k f = 0) := by
  constructor
  · intro h
    exact ⟨fun i hi0 hik => h i hi0 (by omega), fun hk => h k hk (by omega)⟩
  · rintro ⟨h1, h2⟩ i hi0 hik
    rcases Nat.lt_or_ge i k with h | h
    · exact h1 i hi0 h
    · have : i = k := by omega
      subst this
      exact h2 hi0

/-- **The graded invariant.**  On the `k`-th stage of the filtration, the level-`k` coefficient
is a group homomorphism onto `(ℂ, +)`. -/
noncomputable def gradedHom (k : ℕ) (hk : 0 < k) : deepSubgroup k →* Multiplicative ℂ where
  toFun f := Multiplicative.ofAdd (coeffAt k (f : Norm))
  map_one' := by
    show Multiplicative.ofAdd (coeffAt k (1 : Norm)) = 1
    rw [coeffAt_one k hk]
    rfl
  map_mul' f g := by
    show Multiplicative.ofAdd (coeffAt k ((f : Norm) * (g : Norm))) = _
    have hsplit : coeffAt k ((f : Norm) * (g : Norm)) = coeffAt k (f : Norm) +
        coeffAt k (g : Norm) := by
      have h := coeff_mul_split (a := (toOneUnit (f : Norm) : PowerSeries ℂ))
        (b := (toOneUnit (g : Norm) : PowerSeries ℂ)) hk f.2 g.2
      rw [(toOneUnit (f : Norm)).constantCoeff_val, (toOneUnit (g : Norm)).constantCoeff_val,
        one_mul, mul_one] at h
      rw [coeffAt_toOneUnit, toOneUnit_mul, OneUnit.val_mul, h]
      exact add_comm _ _
    rw [hsplit]
    rfl

@[simp] theorem gradedHom_apply (k : ℕ) (hk : 0 < k) (f : deepSubgroup k) :
    gradedHom k hk f = Multiplicative.ofAdd (coeffAt k (f : Norm)) := rfl

/-- Each graded piece of the filtration surjects onto `(ℂ, +)`: the invariants are independent. -/
theorem gradedHom_surjective (k : ℕ) (hk : 0 < k) : Function.Surjective (gradedHom k hk) := by
  intro c
  set z : ℂ := Multiplicative.toAdd c with hz
  have hcoeff : ∀ i : ℕ,
      PowerSeries.coeff i ((1 : PowerSeries ℂ) + PowerSeries.C z * PowerSeries.X ^ k)
      = (if i = 0 then (1 : ℂ) else 0) + (if i = k then z else 0) := by
    intro i
    rw [map_add, PowerSeries.coeff_one, PowerSeries.coeff_C_mul, PowerSeries.coeff_X_pow]
    by_cases h : i = k <;> simp [h]
  have hcc : constantCoeff ((1 : PowerSeries ℂ) + PowerSeries.C z * PowerSeries.X ^ k) = 1 := by
    have h0 := hcoeff 0
    rw [PowerSeries.coeff_zero_eq_constantCoeff_apply, if_pos rfl, if_neg (by omega)] at h0
    rw [h0]
    ring
  set u : OneUnit := ⟨1 + PowerSeries.C z * PowerSeries.X ^ k, hcc⟩ with hu
  have huval : ((u : OneUnit) : PowerSeries ℂ)
      = 1 + PowerSeries.C z * PowerSeries.X ^ k := rfl
  have hsymm : toOneUnit (normEquivOneUnit.symm u) = u := normEquivOneUnit.apply_symm_apply u
  have hmem : normEquivOneUnit.symm u ∈ deepSubgroup k := by
    intro i hi0 hik
    rw [hsymm, huval, hcoeff i, if_neg (by omega), if_neg (by omega)]
    ring
  refine ⟨⟨normEquivOneUnit.symm u, hmem⟩, ?_⟩
  rw [gradedHom_apply]
  have hval : coeffAt k (normEquivOneUnit.symm u : Norm) = z := by
    rw [coeffAt_toOneUnit, hsymm, huval, hcoeff k, if_neg (by omega), if_pos rfl]
    ring
  rw [hval, hz]
  rfl

/-! ### The first invariant is not complete, but the first *non-vanishing* one is -/

/-- **The constant Laurent coefficient is not a complete invariant.**  The normalized series
`q⁻¹ + q` differs from the base point `q⁻¹` but has `a₀ = 0`. -/
theorem a₀_not_complete : ∃ f : Norm, f ≠ 1 ∧ a₀ f = 0 := by
  have hcoeff : ∀ i : ℕ, PowerSeries.coeff i ((1 : PowerSeries ℂ) + PowerSeries.X ^ 2)
      = (if i = 0 then (1 : ℂ) else 0) + (if i = 2 then 1 else 0) := by
    intro i
    rw [map_add, PowerSeries.coeff_one, PowerSeries.coeff_X_pow]
  have hcc : constantCoeff ((1 : PowerSeries ℂ) + PowerSeries.X ^ 2) = 1 := by
    have h0 := hcoeff 0
    rw [PowerSeries.coeff_zero_eq_constantCoeff_apply, if_pos rfl, if_neg (by omega)] at h0
    rw [h0]; ring
  set u : OneUnit := ⟨1 + PowerSeries.X ^ 2, hcc⟩ with hu
  have huval : ((u : OneUnit) : PowerSeries ℂ) = 1 + PowerSeries.X ^ 2 := rfl
  refine ⟨ofOneUnit u, ?_, ?_⟩
  · intro h
    have h2 : (u : PowerSeries ℂ) = 1 := by
      rw [← toOneUnit_ofOneUnit u, h, toOneUnit_one]
      rfl
    have h3 := congrArg (fun w : PowerSeries ℂ => PowerSeries.coeff 2 w) h2
    simp only [huval] at h3
    rw [hcoeff 2, if_neg (by omega), if_pos rfl, PowerSeries.coeff_one, if_neg (by omega)] at h3
    norm_num at h3
  · rw [a₀_ofOneUnit, huval, hcoeff 1, if_neg (by omega), if_neg (by omega)]
    ring

/-- Consequently the first invariant does not separate normalized series. -/
theorem leadCoeffHom_not_injective : ¬ Function.Injective leadCoeffHom := by
  obtain ⟨f, hf, hf0⟩ := a₀_not_complete
  intro hinj
  refine hf (hinj ?_)
  rw [leadCoeffHom_apply, leadCoeffHom_apply, hf0, a₀_one]

/-- **The first non-vanishing invariant separates orbits.**  For any normalized series `f` other
than the base point there is a unique first level `k ≥ 1` at which `f` differs from `q⁻¹`; the
value `c = coeffAt k f` there is nonzero, and along the `⋆`-orbit of `f` it grows linearly,
`coeffAt k (f^{⋆n}) = n · c`.  In particular distinct iterates are distinguished by this single
invariant. -/
theorem first_invariant {f : Norm} (hf : f ≠ 1) :
    ∃ k : ℕ, 0 < k ∧ (∀ i, 0 < i → i < k → coeffAt i f = 0) ∧ coeffAt k f ≠ 0 ∧
      ∀ n : ℕ, coeffAt k (f ^ n) = n * coeffAt k f := by
  classical
  set u : PowerSeries ℂ := (toOneUnit f : PowerSeries ℂ) with hu
  have hu0 : constantCoeff u = 1 := (toOneUnit f).constantCoeff_val
  have hune : u ≠ 1 := by
    intro h
    refine hf (normEquivOneUnit.injective ?_)
    show toOneUnit f = toOneUnit 1
    rw [toOneUnit_one]
    exact OneUnit.ext (by simpa using h)
  have hex : ∃ k, coeff k u ≠ coeff k (1 : PowerSeries ℂ) := by
    by_contra h
    push_neg at h
    exact hune (PowerSeries.ext h)
  set k := Nat.find hex with hk
  have hkspec : coeff k u ≠ coeff k (1 : PowerSeries ℂ) := Nat.find_spec hex
  have hk0 : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h | h
    · exact absurd (by rw [h]; simp [PowerSeries.coeff_zero_eq_constantCoeff, hu0]) hkspec
    · exact h
  have hcoeff1 : coeff k (1 : PowerSeries ℂ) = 0 := by
    rw [PowerSeries.coeff_one, if_neg (by omega)]
  have hdeep : LowVanish k u := by
    intro i hi0 hik
    have hmin := Nat.find_min hex (m := i) (by omega)
    push_neg at hmin
    rw [hmin, PowerSeries.coeff_one, if_neg (by omega)]
  refine ⟨k, hk0, fun i hi0 hik => hdeep i hi0 hik, ?_, ?_⟩
  · rw [coeffAt, ← hu]
    rw [hcoeff1] at hkspec
    exact hkspec
  · intro n
    obtain ⟨-, -, hiter⟩ := coeff_pow_of_lowVanish hk0 hu0 hdeep n
    rw [coeffAt, toOneUnit_pow, OneUnit.val_pow, ← hu, hiter, coeffAt, ← hu]

/-! ### Finite corrected products and the Monster-sized instance -/

variable {ι : Type*}

/-- The corrected product over a finite family, on the Laurent level. -/
theorem val_finset_prod (s : Finset ι) (F : ι → Norm) :
    qSeries * ((∏ i ∈ s, F i : Norm) : LC) = ∏ i ∈ s, (qSeries * (F i : LC)) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using qSeries_mul_qInv
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.prod_insert ha, Norm.val_mul, ← ih]
      ring

/-- `a₀` of a finite corrected product is the sum of the `a₀`'s. -/
theorem a₀_finset_prod (s : Finset ι) (F : ι → Norm) :
    a₀ (∏ i ∈ s, F i) = ∑ i ∈ s, a₀ (F i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha, a₀_mul, ih]

/-- **Monster-sized corrected product.**  The `⋆`-product of the `194` McKay–Thompson-shaped
normalized series is `q¹⁹³` times their ordinary product: exactly the pole correction predicted
by `PoleOrderObstruction.orderTop_prod_normalized`. -/
theorem val_prod_monster (T : Fin 194 → Norm) :
    ((∏ i, T i : Norm) : LC) = qSeries ^ 193 * ∏ i, (T i : LC) := by
  have h := val_finset_prod Finset.univ T
  rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ, Fintype.card_fin] at h
  refine mul_left_cancel₀ qSeries_ne_zero ?_
  rw [h]
  ring

/-- For genuine McKay–Thompson series (constant term `0`) the Monster-sized `⋆`-product lies in
the **second** stage of the filtration: its first invariant vanishes. -/
theorem monster_prod_mem_deepSubgroup_two
    (T : Fin 194 → Norm) (hT : ∀ i, a₀ (T i) = 0) :
    (∏ i, T i) ∈ deepSubgroup 2 := by
  intro i hi0 hi2
  have hi1 : i = 1 := by omega
  subst hi1
  have h1 : coeffAt 1 (∏ i, T i) = a₀ (∏ i, T i) :=
    (coeffAt_toOneUnit 1 _).trans (a₀_toOneUnit _)
  show PowerSeries.coeff 1 ((toOneUnit (∏ i, T i) : PowerSeries ℂ)) = 0
  rw [← coeffAt_toOneUnit, h1, a₀_finset_prod]
  simp [hT]

end Norm

end PoleOrderTorsor