import Mathlib

/-!
# Shared divisor combinatorics for the round-3 factoring closures

Basic structure of the divisor lattice of a semiprime `N = p*q`, used by the
CONG-DIV, MODPAR-CERT and RS-MIND closures.
-/

namespace Semiprime

/-- Every divisor of a product of two primes is `1`, `p`, `q` or `p*q`. -/
theorem dvd_cases {p q d : ℕ} (hp : p.Prime) (hq : q.Prime) (hdvd : d ∣ p * q) :
    d = 1 ∨ d = p ∨ d = q ∨ d = p * q := by
  have hdmem : d ∈ (p * q).divisors :=
    Nat.mem_divisors.mpr ⟨hdvd, Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
  rw [Nat.divisors_mul, hp.divisors, hq.divisors, Finset.mem_mul] at hdmem
  obtain ⟨a, ha, b, hb, hab⟩ := hdmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at ha hb
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl
  · exact Or.inl (by omega)
  · exact Or.inr (Or.inr (Or.inl (by omega)))
  · exact Or.inr (Or.inl (by omega))
  · exact Or.inr (Or.inr (Or.inr (by omega)))

/-- The proper divisors of a product of two primes `p*q` are `{1, p, q}` (a
two-element set when `p = q`). -/
theorem properDivisors_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    (p * q).properDivisors = {1, p, q} := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  ext d
  simp only [Nat.mem_properDivisors, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hdvd, hlt⟩
    rcases dvd_cases hp hq hdvd with h | h | h | h
    · exact Or.inl h
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr h)
    · omega
  · rintro (rfl | rfl | rfl)
    · exact ⟨one_dvd _, by nlinarith⟩
    · exact ⟨dvd_mul_right _ _, by nlinarith⟩
    · exact ⟨dvd_mul_left _ _, by nlinarith⟩

/-- `1`, `p`, `q` are pairwise distinct for distinct primes `p ≠ q`. -/
theorem one_ne_prime {p : ℕ} (hp : p.Prime) : (1 : ℕ) ≠ p := by
  have := hp.two_le; omega

end Semiprime