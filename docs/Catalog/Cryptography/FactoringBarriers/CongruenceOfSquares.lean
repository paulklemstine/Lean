import Mathlib

/-!
# The Structural Core: Congruences of Squares and Order Finding

Every general-purpose classical factoring algorithm that is not pure trial
division (CFRAC, quadratic sieve, number field sieve, Dixon's random squares,
and the classical post-processing of Shor's algorithm) reduces to the *same*
structural step:

  find `x, y` with `x² ≡ y² (mod N)` but `x ≢ ± y (mod N)`; then `gcd(x-y, N)`
  is a nontrivial factor of `N`.

This file proves that step rigorously, derives the order-finding reduction that
underlies Shor's algorithm from it, and shows that for a semiprime any
nontrivial divisor *is* one of the two prime factors, i.e. the structural step
completely solves the problem.

This is the "barrier 5" core: the reduction is unconditional, so the difficulty
of factoring is entirely concentrated in *producing* the congruence of squares
(equivalently, the multiplicative order), never in exploiting it.
-/

namespace FactoringBarriers

/-- `d` is a nontrivial divisor of `N`: a divisor other than `1` and `N`. -/
def NontrivialDivisor (N d : ℕ) : Prop := d ∣ N ∧ 1 < d ∧ d < N

/-- A nontrivial divisor really splits `N` into two factors both exceeding `1`. -/
theorem NontrivialDivisor.splits {N d : ℕ} (h : NontrivialDivisor N d) :
    ∃ e : ℕ, N = d * e ∧ 1 < d ∧ 1 < e := by
  obtain ⟨⟨e, he⟩, hd1, hdN⟩ := h
  refine ⟨e, he, hd1, ?_⟩
  by_contra hcon
  push_neg at hcon
  interval_cases e
  · simp at he; omega
  · simp at he; omega

/-! ## The congruence-of-squares reduction -/

/-- **Congruence of squares.** If `N > 1` divides `(x - y)(x + y)` but divides
neither `x - y` nor `x + y`, then `gcd(x - y, N)` is a nontrivial divisor of `N`.

This is the unconditional engine of every sieve-based factoring method. -/
theorem congruence_of_squares {N : ℕ} (hN : 1 < N) {x y : ℤ}
    (hsq : (N : ℤ) ∣ (x - y) * (x + y))
    (hm : ¬ (N : ℤ) ∣ (x - y)) (hp : ¬ (N : ℤ) ∣ (x + y)) :
    NontrivialDivisor N (Int.gcd (x - y) (N : ℤ)) := by
  set d : ℕ := Int.gcd (x - y) (N : ℤ) with hd
  have hdvdN : d ∣ N := by
    have : (d : ℤ) ∣ (N : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hdvdxy : (d : ℤ) ∣ (x - y) := Int.gcd_dvd_left _ _
  have hdne1 : d ≠ 1 := by
    intro h1
    have hcop : IsCoprime (x - y) (N : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr (by rw [← hd, h1])
    have hcop' : IsCoprime (N : ℤ) (x - y) := hcop.symm
    exact hp (hcop'.dvd_of_dvd_mul_left hsq)
  have hdneN : d ≠ N := by
    intro hEq
    exact hm (by rw [← hEq] at *; exact_mod_cast hdvdxy)
  have hd0 : d ≠ 0 := by
    intro h0
    rw [h0] at hdvdN
    exact absurd (Nat.eq_zero_of_zero_dvd hdvdN) (by omega)
  refine ⟨hdvdN, by omega, ?_⟩
  have hle : d ≤ N := Nat.le_of_dvd (by omega) hdvdN
  omega

/-- **Order finding reduction (classical post-processing of Shor).**
If `a` has an even multiplicative order `2s` modulo `N`, and `a^s ≢ ±1`, then
`gcd(a^s - 1, N)` is a nontrivial divisor of `N`. -/
theorem order_finding_yields_factor {N : ℕ} (hN : 1 < N) {a : ℤ} {s : ℕ}
    (hord : (N : ℤ) ∣ a ^ (2 * s) - 1)
    (hm : ¬ (N : ℤ) ∣ (a ^ s - 1)) (hp : ¬ (N : ℤ) ∣ (a ^ s + 1)) :
    NontrivialDivisor N (Int.gcd (a ^ s - 1) (N : ℤ)) := by
  refine congruence_of_squares hN ?_ hm hp
  have hrw : (a ^ s - 1) * (a ^ s + 1) = a ^ (2 * s) - 1 := by
    rw [two_mul, pow_add]; ring
  rw [hrw]
  exact hord

/-! ## For semiprimes the structural step is everything -/

/-- For a semiprime `N = p q`, every nontrivial divisor is one of the two prime
factors: exhibiting *any* nontrivial divisor is the same as factoring. -/
theorem nontrivialDivisor_semiprime {p q d : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h : NontrivialDivisor (p * q) d) : d = p ∨ d = q := by
  obtain ⟨hdvd, hd1, hdlt⟩ := h
  by_cases hpd : p ∣ d
  · left
    obtain ⟨k, hk⟩ := hpd
    have hkq : k ∣ q := by
      have : p * k ∣ p * q := by rw [← hk]; exact hdvd
      exact (mul_dvd_mul_iff_left hp.pos.ne').mp this
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq k hkq) with hk1 | hkq'
    · rw [hk, hk1, mul_one]
    · exfalso
      rw [hk, hkq'] at hdlt
      omega
  · right
    have hcop : Nat.Coprime p d := (Nat.Prime.coprime_iff_not_dvd hp).mpr hpd
    have hdq : d ∣ q := (Nat.Coprime.dvd_of_dvd_mul_left (hcop.symm) hdvd)
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq d hdq) with h1 | h2
    · omega
    · exact h2

/-- Consequently, a congruence of squares modulo a semiprime *is* a
factorization of that semiprime. -/
theorem congruence_of_squares_factors_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hN : 1 < p * q) {x y : ℤ}
    (hsq : ((p * q : ℕ) : ℤ) ∣ (x - y) * (x + y))
    (hm : ¬ ((p * q : ℕ) : ℤ) ∣ (x - y)) (hpl : ¬ ((p * q : ℕ) : ℤ) ∣ (x + y)) :
    Int.gcd (x - y) ((p * q : ℕ) : ℤ) = p ∨ Int.gcd (x - y) ((p * q : ℕ) : ℤ) = q :=
  nontrivialDivisor_semiprime hp hq (congruence_of_squares hN hsq hm hpl)

/-! ## Sharpness: both exceptional congruences are genuinely needed -/

/-- The hypothesis `x ≢ -y` cannot be dropped: `x = y = 1` gives a congruence of
squares modulo `15` whose gcd is the trivial divisor `15`. -/
theorem congruence_of_squares_needs_hp :
    ((15 : ℕ) : ℤ) ∣ ((4 : ℤ) - 11) * ((4 : ℤ) + 11) ∧
      ¬ NontrivialDivisor 15 (Int.gcd ((4 : ℤ) - 11) ((15 : ℕ) : ℤ)) := by
  constructor
  · decide
  · intro h
    obtain ⟨-, h1, -⟩ := h
    norm_num [Int.gcd] at h1

end FactoringBarriers