/-
# A domain where the principal filtration at a nonzero non-unit is *not* separated

`SeparatedPrincipalFiltration.lean` proves that in a domain with well-founded
divisibility (Noetherian domains, UFDs, ...) every non-unit `a` satisfies
`⨅ n, (aⁿ) = ⊥`.  Here we show that some hypothesis of that kind is unavoidable, by
computing the intersection exactly in the classical `D + M` construction

  `S = ℤ + X·ℚ[X] ⊆ ℚ[X]`,

the subring of rational polynomials whose constant coefficient is an integer.

`S` is a domain, `2 ∈ S` is a nonzero non-unit, yet

  `⨅ n, ((2 : S)ⁿ) = X·ℚ[X] ≠ ⊥`,

because `X = 2ⁿ · (2⁻ⁿ X)` for every `n`.  Consequently `S` is not a `WfDvdMonoid`,
hence neither Noetherian nor a UFD, and no `ℕ`-valued height function can exist for
`2` in `S`.  This delimits exactly the boundary of the Krull-type theorems.
-/
import Mathlib
import Shared.SeparatedPrincipalFiltration
import Shared.SeparatedPrincipalFiltrationStructure

namespace SeparatedPrincipalFiltration

open Polynomial

/-! ## The ring `ℤ + X·ℚ[X]` -/

/-- `intConst = ℤ + X·ℚ[X]`, the subring of `ℚ[X]` of polynomials with integral
constant coefficient. -/
def intConst : Subring (Polynomial ℚ) :=
  Subring.comap (Polynomial.evalRingHom (0 : ℚ)) (Int.castRingHom ℚ).range

lemma mem_intConst {p : Polynomial ℚ} : p ∈ intConst ↔ ∃ m : ℤ, p.coeff 0 = (m : ℚ) := by
  simp only [intConst, Subring.mem_comap, RingHom.mem_range, coeff_zero_eq_eval_zero,
    coe_evalRingHom, eq_intCast]
  exact ⟨fun ⟨m, h⟩ => ⟨m, h.symm⟩, fun ⟨m, h⟩ => ⟨m, h.symm⟩⟩

/-- The constant coefficient, as a ring homomorphism `S → ℚ`. -/
def constCoeff : intConst →+* ℚ := (Polynomial.evalRingHom (0 : ℚ)).comp intConst.subtype

@[simp] lemma constCoeff_apply (p : intConst) : constCoeff p = (p : Polynomial ℚ).coeff 0 := by
  simp [constCoeff, coeff_zero_eq_eval_zero]

lemma coe_two : ((2 : intConst) : Polynomial ℚ) = 2 := rfl

lemma two_pow_eq_C (n : ℕ) : ((2 : Polynomial ℚ)) ^ n = Polynomial.C ((2 : ℚ) ^ n) := by
  rw [map_pow, C_ofNat]

/-- `2` is not a unit of `ℤ + X·ℚ[X]`: its inverse in `ℚ[X]` has constant coefficient
`1/2`, which is not an integer. -/
theorem not_isUnit_two : ¬ IsUnit (2 : intConst) := by
  intro hu
  obtain ⟨b, hb⟩ := isUnit_iff_exists_inv.mp hu
  obtain ⟨m, hm⟩ := mem_intConst.mp b.2
  have hcoe : (2 : Polynomial ℚ) * (b : Polynomial ℚ) = 1 := by
    have := congrArg (fun z : intConst => (z : Polynomial ℚ)) hb
    simpa [coe_two] using this
  have hcoeff := congrArg (fun p : Polynomial ℚ => p.coeff 0) hcoe
  simp only [mul_coeff_zero, coeff_one_zero, coeff_ofNat_zero, hm] at hcoeff
  have hQ : ((2 * m : ℤ) : ℚ) = ((1 : ℤ) : ℚ) := by push_cast; linarith [hcoeff]
  have hZ : (2 : ℤ) * m = 1 := by exact_mod_cast hQ
  omega

/-- `X`, viewed as an element of `ℤ + X·ℚ[X]`. -/
noncomputable def Xs : intConst := ⟨X, mem_intConst.mpr ⟨0, by simp⟩⟩

lemma Xs_ne_zero : Xs ≠ 0 := by
  intro h
  have : (X : Polynomial ℚ) = 0 := congrArg (fun z : intConst => (z : Polynomial ℚ)) h
  exact X_ne_zero this

/-- `2⁻ⁿ · X` lies in `ℤ + X·ℚ[X]` (its constant coefficient is `0`). -/
noncomputable def halfPow (n : ℕ) : intConst :=
  ⟨C ((2 : ℚ) ^ n)⁻¹ * X, mem_intConst.mpr ⟨0, by simp⟩⟩

/-- The crucial divisibility: `X` is divisible by every power of `2` inside
`ℤ + X·ℚ[X]`. -/
theorem two_pow_dvd_Xs (n : ℕ) : (2 : intConst) ^ n ∣ Xs := by
  refine ⟨halfPow n, ?_⟩
  apply Subtype.ext
  have h2 : ((2 : ℚ) ^ n) ≠ 0 := by positivity
  push_cast [Xs, halfPow, coe_two]
  rw [← mul_assoc, two_pow_eq_C, ← C_mul, mul_inv_cancel₀ h2, C_1, one_mul]

/-! ## The intersection, computed exactly -/

/-- **The filtration is not separated.** -/
theorem not_isSeparated_two : ¬ IsSeparated (2 : intConst) := by
  intro h
  exact Xs_ne_zero (h.eq_zero two_pow_dvd_Xs)

/-- The intersection `⨅ n, (2ⁿ)` in `ℤ + X·ℚ[X]` is *exactly* the ideal `X·ℚ[X]` of
elements with vanishing constant coefficient. -/
theorem iInf_filt_two : (⨅ n, filt (2 : intConst) n) = RingHom.ker constCoeff := by
  apply le_antisymm
  · intro p hp
    rw [mem_iInf_filt_iff] at hp
    obtain ⟨m, hm⟩ := mem_intConst.mp p.2
    have hmdvd : ∀ n : ℕ, (2 : ℤ) ^ n ∣ m := by
      intro n
      obtain ⟨q, hq⟩ := hp n
      obtain ⟨k, hk⟩ := mem_intConst.mp q.2
      refine ⟨k, ?_⟩
      have hcoe : (p : Polynomial ℚ) = 2 ^ n * (q : Polynomial ℚ) := by
        have := congrArg (fun z : intConst => (z : Polynomial ℚ)) hq
        simpa [coe_two] using this
      have := congrArg (fun r : Polynomial ℚ => r.coeff 0) hcoe
      simp only [mul_coeff_zero] at this
      rw [hm, hk] at this
      have h2 : ((2 : Polynomial ℚ) ^ n).coeff 0 = ((2 : ℚ) ^ n) := by
        rw [two_pow_eq_C, coeff_C_zero]
      rw [h2] at this
      exact_mod_cast this
    have hm0 : m = 0 := int_two_isSeparated.eq_zero hmdvd
    simp [RingHom.mem_ker, hm, hm0]
  · intro p hp
    rw [RingHom.mem_ker, constCoeff_apply] at hp
    rw [mem_iInf_filt_iff]
    intro n
    have h2 : ((2 : ℚ) ^ n) ≠ 0 := by positivity
    refine ⟨⟨C ((2 : ℚ) ^ n)⁻¹ * (p : Polynomial ℚ), mem_intConst.mpr ⟨0, by simp [hp]⟩⟩, ?_⟩
    apply Subtype.ext
    push_cast [coe_two]
    rw [← mul_assoc, two_pow_eq_C, ← C_mul, mul_inv_cancel₀ h2, C_1, one_mul]

/-- The intersection is nontrivial. -/
theorem iInf_filt_two_ne_bot : (⨅ n, filt (2 : intConst) n) ≠ ⊥ := by
  intro h
  exact not_isSeparated_two h

/-! ## Consequences: sharpness of the Krull hypotheses -/

/-- `ℤ + X·ℚ[X]` is not a `WfDvdMonoid`; the well-founded divisibility hypothesis in
`isSeparated_of_not_isUnit` cannot be dropped. -/
theorem not_wfDvdMonoid_intConst : ¬ WfDvdMonoid intConst := by
  intro h
  exact not_isSeparated_two (isSeparated_of_not_isUnit not_isUnit_two)

/-- Consequently `ℤ + X·ℚ[X]` is not Noetherian. -/
theorem not_isNoetherianRing_intConst : ¬ IsNoetherianRing intConst := by
  intro h
  exact not_wfDvdMonoid_intConst inferInstance

/-- Consequently `ℤ + X·ℚ[X]` is not a unique factorisation domain. -/
theorem not_uniqueFactorizationMonoid_intConst : ¬ UniqueFactorizationMonoid intConst := by
  intro h
  exact not_wfDvdMonoid_intConst inferInstance

/-- Read through the fixed-point description of the intersection: the ideal `X·ℚ[X]` is
the *greatest* `2`-divisible ideal of `ℤ + X·ℚ[X]`. -/
theorem isGreatest_two_divisible :
    IsGreatest {I : Ideal intConst | I ≤ Ideal.span {(2 : intConst)} * I}
      (RingHom.ker constCoeff) := by
  rw [← iInf_filt_two]
  exact isGreatest_iInf_filt 2

/-- No `ℕ`-valued height function can witness separation at `2` in `ℤ + X·ℚ[X]`: for
every `v` there is a nonzero element on which multiplication by `2` fails to increase
`v`.  This is the exact failure of the height criterion. -/
theorem no_height_function (v : intConst → ℕ) :
    ∃ x : intConst, x ≠ 0 ∧ ¬ (v x < v (2 * x)) := by
  by_contra hcon
  push_neg at hcon
  exact not_isSeparated_two (isSeparated_of_height 2 v fun x hx => hcon x hx)

end SeparatedPrincipalFiltration