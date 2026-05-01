import Mathlib

/-! # Novel Factoring Algorithms — Formal Foundations

This file formalizes the mathematical foundations underlying the 50 novel
factoring algorithms described in FACTORING_RESEARCH_PAPER.md.

## Main Results

- Congruence of squares identities for factoring
- Quaternion/Brahmagupta-Fibonacci cross-term divisibility
- Tropical valuation constraints on semiprimes
- Fibonacci GCD identity applications
- Shor's algebraic core identity
- RSA totient structure
-/

noncomputable section

/-! ## Congruence of Squares -/

/-- x² - y² = (x-y)(x+y): the engine behind all modern factoring. -/
theorem novel_diff_sq (x y : ℤ) : x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring

/-- If N | x²-y² then N | (x-y)(x+y). -/
theorem novel_sq_cong_factor (N x y : ℤ) (h : N ∣ x ^ 2 - y ^ 2) :
    N ∣ (x - y) * (x + y) := by
  rwa [show x ^ 2 - y ^ 2 = (x - y) * (x + y) from by ring] at h

/-- Congruence of squares in ZMod: x²=y² implies (x-y)(x+y)=0. -/
theorem novel_sq_cong_zmod (N : ℕ) (x y : ZMod N) (h : x ^ 2 = y ^ 2) :
    (x - y) * (x + y) = 0 := by
  have : (x - y) * (x + y) = x ^ 2 - y ^ 2 := by ring
  rw [this, h, sub_self]

/-- Shor's algebraic core: a^(2r)-1 = (a^r-1)(a^r+1). -/
theorem novel_shor_core (a : ℤ) (r : ℕ) :
    a ^ (2 * r) - 1 = (a ^ r - 1) * (a ^ r + 1) := by
  rw [pow_mul]; ring

/-- Shor's identity in ZMod. -/
theorem novel_shor_zmod (N : ℕ) (a : ZMod N) (k : ℕ) (h : a ^ (2 * k) = 1) :
    (a ^ k - 1) * (a ^ k + 1) = 0 := by
  have : (a ^ k - 1) * (a ^ k + 1) = a ^ (2 * k) - 1 := by rw [pow_mul]; ring
  rw [this, h, sub_self]

/-! ## Brahmagupta-Fibonacci and Quaternions -/

/-- BF identity: product of sums of 2 squares is a sum of 2 squares. -/
theorem novel_bf (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring

/-- Alternate BF identity. -/
theorem novel_bf_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

/-- Two reps of N as sum of 2 squares gives cross-product divisibility. -/
theorem novel_two_reps_div (a b c d : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2 + d ^ 2) :
    (a ^ 2 + b ^ 2) ∣ (a * d - b * c) * (a * d + b * c) := by
  exact ⟨a ^ 2 - c ^ 2, by nlinarith⟩

/-- The cross-product for two-square reps. -/
theorem novel_cross_product (a b c d : ℤ) :
    (a * d - b * c) * (a * d + b * c) = a ^ 2 * d ^ 2 - b ^ 2 * c ^ 2 := by ring

/-- Euler four-square identity (quaternion norm multiplicativity). -/
theorem novel_euler_4sq (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by ring

/-- Sum of four squares equals zero implies all components zero. -/
theorem novel_four_sq_zero (a b c d : ℤ) (h : a^2 + b^2 + c^2 + d^2 = 0) :
    a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  exact ⟨by nlinarith, by nlinarith, by nlinarith, by nlinarith⟩

/-! ## Tropical / p-adic Valuations -/

/-- Tropical additivity: v_p(ab) = v_p(a) + v_p(b). -/
theorem novel_trop_add (ℓ : ℕ) [Fact ℓ.Prime] {a b : ℕ}
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat ℓ (a * b) = padicValNat ℓ a + padicValNat ℓ b :=
  padicValNat.mul ha hb

/-- For semiprime pq, valuation at unrelated prime is 0. -/
theorem novel_semi_val {p q ℓ : ℕ} [hℓ : Fact ℓ.Prime]
    (hp : Nat.Prime p) (hq : Nat.Prime q) (h1 : ℓ ≠ p) (h2 : ℓ ≠ q) :
    padicValNat ℓ (p * q) = 0 := by
  rw [padicValNat.mul hp.ne_zero hq.ne_zero]
  have : padicValNat ℓ p = 0 := by
    rw [padicValNat.eq_zero_iff]
    right; right; intro hdvd
    exact h1 ((Nat.prime_dvd_prime_iff_eq hℓ.1 hp).mp hdvd)
  have : padicValNat ℓ q = 0 := by
    rw [padicValNat.eq_zero_iff]
    right; right; intro hdvd
    exact h2 ((Nat.prime_dvd_prime_iff_eq hℓ.1 hq).mp hdvd)
  omega

/-- Smoothness ↔ tropical vanishing. -/
theorem novel_smooth_trop {n B : ℕ} (hn : n ≠ 0) :
    (∀ p : ℕ, Nat.Prime p → p ∣ n → p ≤ B) ↔
    (∀ p : ℕ, Nat.Prime p → B < p → padicValNat p n = 0) := by
  constructor
  · intro h p hp hpB
    exact padicValNat.eq_zero_of_not_dvd fun hd => not_le.mpr hpB (h p hp hd)
  · intro h p hp hd
    by_contra hgt
    push_neg at hgt
    haveI : Fact p.Prime := ⟨hp⟩
    have := h p hp hgt
    rw [padicValNat.eq_zero_iff] at this
    rcases this with h1 | h2 | h3
    · exact hp.one_lt.ne' h1
    · exact hn h2
    · exact h3 hd

/-! ## Fibonacci Foundations -/

/-- GCD of Fibonacci numbers = Fibonacci of GCD. -/
theorem novel_fib_gcd' (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-- Fibonacci divisibility chain. -/
theorem novel_fib_dvd (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd _ _ h

/-- F(n) ≤ 2^n. -/
theorem novel_fib_exp (n : ℕ) : Nat.fib n ≤ 2 ^ n := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    match n with
    | 0 => simp
    | 1 => simp [Nat.fib]
    | n + 2 =>
      rw [Nat.fib_add_two]
      have h1 := ih (n+1) (by omega)
      have h2 := ih n (by omega)
      have : 2^n ≤ 2^(n+1) := Nat.pow_le_pow_right (by omega) (by omega)
      linarith [show 2^(n+2) = 2^(n+1) + 2^(n+1) from by ring]

/-- Fermat's little theorem in ZMod. -/
theorem novel_fermat' (p : ℕ) (hp : Nat.Prime p) (a : ZMod p) :
    a ^ p = a := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact ZMod.pow_card a

/-! ## Lattice and Geometric -/

/-- On the hyperbola xy = N, divisors give lattice points. -/
theorem novel_hyp_point {N d : ℕ} (hN : 0 < N) (hd : d ∣ N) :
    d * (N / d) = N :=
  Nat.mul_div_cancel' hd

/-- Any divisor ≤ N. -/
theorem novel_div_le {N d : ℕ} (hN : 0 < N) (hd : d ∣ N) : d ≤ N :=
  Nat.le_of_dvd hN hd

/-- σ decomposition for semiprimes. -/
theorem novel_sigma_decomp (p q : ℕ) :
    (1 + p) * (1 + q) = 1 + p + q + p * q := by ring

/-- Discriminant identity for factor recovery. -/
theorem novel_discriminant (p q : ℤ) :
    (p + q) ^ 2 - 4 * (p * q) = (p - q) ^ 2 := by ring

/-- GCD always divides both arguments. -/
theorem novel_gcd_dvd_left (a b : ℕ) : Nat.gcd a b ∣ a := Nat.gcd_dvd_left a b
theorem novel_gcd_dvd_right (a b : ℕ) : Nat.gcd a b ∣ b := Nat.gcd_dvd_right a b

/-- A nontrivial GCD with N gives a factorization. -/
theorem novel_gcd_factor {N d : ℕ} (hN : 1 < N) (h1 : 1 < Nat.gcd d N)
    (h2 : Nat.gcd d N < N) :
    Nat.gcd d N ∣ N ∧ 1 < N / Nat.gcd d N := by
  refine ⟨Nat.gcd_dvd_right d N, ?_⟩
  have hg := Nat.gcd_dvd_right d N
  have := Nat.div_pos (Nat.le_of_dvd (by omega) hg) (by omega)
  have := Nat.mul_div_cancel' hg
  by_contra hle
  push_neg at hle
  interval_cases (N / Nat.gcd d N) <;> omega

end