import Cryptography.MordellDenominators.Basic

/-!
# Reduction modulo `ℓ` and the meaning of a denominator prime

This file explains *why* good primes can occur in denominators.  Writing a
rational point of `E_N : y² = x³ + N` as `x = a/e²`, `y = b/e³` we obtain the
integral model `b² = a³ + N e⁶` (`curve_integral_model`, proved in
`Basic.lean`), and then a clean dichotomy for every prime
`ℓ`:

* if `ℓ ∤ x.den`, the point **reduces to an affine point** of `E_N(𝔽_ℓ)`
  (`MordellDenominators.exists_reduction`);
* if `ℓ ∣ x.den`, the point has **no affine reduction** — it reduces to the
  point at infinity `O` (`MordellDenominators.no_affine_reduction`).

Consequently a prime — good or bad — occurs in a denominator exactly when the
point falls into the kernel of reduction at that prime
(`MordellDenominators.dvd_den_iff_no_affine_reduction`).  Nothing in this
mechanism refers to the discriminant, which is the structural reason why the
"only bad primes" conjecture had to fail.
-/

namespace MordellDenominators

/-- **Good reduction of the point.**  If `ℓ` does not divide the denominator of
`x`, the point reduces to an affine point of `E_N` over `𝔽_ℓ = ZMod ℓ`. -/
theorem exists_reduction {N : ℤ} {x y : ℚ} (h : OnCurve N x y) {l : ℕ}
    (hl : l.Prime) (hnd : ¬ l ∣ x.den) :
    ∃ X Y : ZMod l, Y ^ 2 = X ^ 3 + (N : ZMod l) ∧
      X * (x.den : ZMod l) = (x.num : ZMod l) ∧
      Y * (y.den : ZMod l) = (y.num : ZMod l) := by
  haveI : Fact l.Prime := ⟨hl⟩
  obtain ⟨e, he0, hxe, hye⟩ := exists_den_param h
  have hle : ¬ (l ∣ e) := by
    intro hcon
    exact hnd (by rw [hxe]; exact Dvd.dvd.trans hcon (dvd_pow_self e (by norm_num)))
  have hez : (e : ZMod l) ≠ 0 := by
    intro hcon
    exact hle ((ZMod.natCast_eq_zero_iff e l).mp hcon)
  have hmodel := curve_integral_model h hxe hye
  have hmodelZ : ((y.num : ZMod l)) ^ 2 =
      ((x.num : ZMod l)) ^ 3 + (N : ZMod l) * ((e : ZMod l)) ^ 6 := by
    have hcast : ((y.num ^ 2 : ℤ) : ZMod l) = ((x.num ^ 3 + N * (e : ℤ) ^ 6 : ℤ) : ZMod l) := by
      rw [hmodel]
    push_cast at hcast
    exact hcast
  refine ⟨(x.num : ZMod l) * ((e : ZMod l) ^ 2)⁻¹,
    (y.num : ZMod l) * ((e : ZMod l) ^ 3)⁻¹, ?_, ?_, ?_⟩
  · field_simp
    linear_combination hmodelZ
  · rw [hxe]
    push_cast
    field_simp
  · rw [hye]
    push_cast
    field_simp

/-- **The kernel of reduction.**  If `ℓ` divides the denominator of `x`, then
the point has no affine reduction modulo `ℓ`: there is no `X ∈ 𝔽_ℓ` with
`X · den(x) = num(x)`.  In other words the point reduces to `O`. -/
theorem no_affine_reduction {x : ℚ} {l : ℕ} (hl : l.Prime) (hd : l ∣ x.den) :
    ¬ ∃ X : ZMod l, X * (x.den : ZMod l) = (x.num : ZMod l) := by
  haveI : Fact l.Prime := ⟨hl⟩
  rintro ⟨X, hX⟩
  have hden : (x.den : ZMod l) = 0 := (ZMod.natCast_eq_zero_iff _ _).mpr hd
  rw [hden, mul_zero] at hX
  have hnum : (l : ℤ) ∣ x.num := by
    have : ((x.num : ZMod l)) = 0 := hX.symm
    exact_mod_cast (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp this
  have h1 : l ∣ x.num.natAbs := by simpa using Int.natAbs_dvd_natAbs.mpr hnum
  have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left h1 x.reduced) hd
  exact hl.one_lt.ne' this

/-- **The mechanism.**  For a rational point on `E_N` and any prime `ℓ`, the
prime divides the denominator of `x` exactly when the point fails to reduce to
an affine point modulo `ℓ` — i.e. exactly when it reduces to `O`.  The
condition involves the point, not the discriminant, which is why primes of
good reduction can and do occur. -/
theorem dvd_den_iff_no_affine_reduction {N : ℤ} {x y : ℚ} (h : OnCurve N x y)
    {l : ℕ} (hl : l.Prime) :
    l ∣ x.den ↔ ¬ ∃ X : ZMod l, X * (x.den : ZMod l) = (x.num : ZMod l) := by
  constructor
  · exact no_affine_reduction hl
  · intro hcon
    by_contra hnd
    obtain ⟨X, _, _, hX, _⟩ := exists_reduction h hl hnd
    exact hcon ⟨X, hX⟩

end MordellDenominators