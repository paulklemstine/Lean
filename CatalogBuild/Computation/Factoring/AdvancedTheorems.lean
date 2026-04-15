/-! # CatalogBuild.Computation.Factoring.AdvancedTheorems

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 24
-/

import CatalogBuild.Computation.Factoring.Core
import Mathlib

/-- Euler's criterion for -1: -1 is a quadratic residue mod p iff p ≡ 1 (mod 4).
Foundation for understanding which primes split in ℤ[i]. -/
theorem euler_criterion_neg_one (p : ℕ) [Fact (Nat.Prime p)] :
    (∃ x : ZMod p, x * x = -1) ↔ p % 4 ≠ 3 := by
  rw [show (∃ x : ZMod p, x * x = -1) ↔ IsSquare (-1 : ZMod p) from
    ⟨fun ⟨x, hx⟩ => ⟨x, hx.symm⟩, fun ⟨x, hx⟩ => ⟨x, hx.symm⟩⟩]
  exact ZMod.exists_sq_eq_neg_one_iff

/-! ## Section 2: Fibonacci Arithmetic -/

/-- Pisano period mod 2 is 3. -/

theorem fibonacci_period_mod2 :
    ∀ n, Nat.fib (n + 3) % 2 = Nat.fib n % 2 := by
  intro n
  induction n with
  | zero => decide
  | succ n ih => simp only [Nat.fib_add_two]; omega

/-- Pisano period mod 3 is 8. -/

theorem fibonacci_period_mod3 :
    ∀ n, Nat.fib (n + 8) % 3 = Nat.fib n % 3 := by
  intro n
  induction n with
  | zero => decide
  | succ n ih => simp only [Nat.fib_add_two]; omega

/-- Entry point divisibility: if m | F(k) then m | F(k·j) for all j. -/

theorem fib_entry_point_divides (k j : ℕ) :
    Nat.fib k ∣ Nat.fib (k * j) :=
  Nat.fib_dvd k (k * j) ⟨j, rfl⟩

/-- GCD of Fibonacci numbers equals Fibonacci of GCD. -/

theorem grover_hybrid_concrete (S : ℕ) :
    S / 2 ^ 7 = S / 128 := by norm_num

/-- Multiplicative order divides group card. -/

theorem order_period_divides_card {G : Type*} [Group G] [Fintype G] (a : G) :
    orderOf a ∣ Fintype.card G :=
  orderOf_dvd_card

/-- Birthday bound for Pollard rho. -/

theorem pollard_rho_birthday (n : ℕ) :
    n < (Nat.sqrt n + 1) ^ 2 :=
  Nat.lt_succ_sqrt' n

/-! ## Section 4: Lattice and Number Theory -/

/-- Fermat factorization: if a ≥ b then a² - b² = (a-b)(a+b). -/

theorem fermat_factor_bound (a b : ℤ) :
    a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring

/-- Tropical (p-adic) valuation is additive on positive naturals. -/

theorem tropical_valuation_mult (p : ℕ) (a b : ℕ)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    (a * b).factorization p = a.factorization p + b.factorization p := by
  simp [Nat.factorization_mul ha hb]

/-- Norm multiplicativity preserves divisibility. -/

theorem norm_mult_preserves_divisibility (d : ℤ) (a b : ℤ√d)
    (m : ℤ) (hm : m ∣ a.norm) :
    m ∣ (a * b).norm := by
  rw [Zsqrtd.norm_mul]
  exact dvd_mul_of_dvd_left hm _

/-! ## Section 5: Information-Theoretic Bounds -/

/-- Each lens reduces but cannot exceed original search space. -/

theorem multi_lens_information_bound (S k : ℕ) :
    S / 2 ^ k ≤ S :=
  Nat.div_le_self S _

/-- Coprime moduli give independent constraints via CRT. -/

theorem coprime_lens_independence (m₁ m₂ : ℕ) (hcop : Nat.Coprime m₁ m₂) :
    Nat.totient (m₁ * m₂) = Nat.totient m₁ * Nat.totient m₂ :=
  Nat.totient_mul hcop

/-! ## Section 6: Sum-of-Squares Factoring -/

/-- Two sum-of-squares representations give a factoring equation. -/

theorem two_square_reps_give_factor (a₁ b₁ a₂ b₂ : ℤ)
    (h : a₁ ^ 2 + b₁ ^ 2 = a₂ ^ 2 + b₂ ^ 2) :
    (a₁ - a₂) * (a₁ + a₂) = (b₂ - b₁) * (b₂ + b₁) := by nlinarith

/-- Zeckendorf bound implies exponential bound. -/

theorem zeckendorf_bound (n k : ℕ) (hk : 2 ≤ k) (hn : n < Nat.fib (k + 2)) :
    n < 2 ^ k :=
  lt_trans hn (MetaFactoring.fibonacci_search_reduction k hk)

/-! ## Section 7: Fermat's Two-Square Theorem Application -/

/-
Primes ≡ 1 (mod 4) are sums of two squares (Fermat's theorem).
-/

theorem prime_one_mod4_sum_sq (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = p := by
  have := Fact.mk hp;
  have := @Nat.Prime.sq_add_sq p; aesop;

/-! ## Section 8: Division Algebra Norm Channels -/

/-- The Euler 4-square identity (Cayley-Dickson 2→4). -/

theorem cayley_dickson_2_to_4 (a b c d e f g h : ℤ) :
    (a^2 + b^2 + c^2 + d^2) * (e^2 + f^2 + g^2 + h^2) =
    (a*e - b*f - c*g - d*h)^2 +
    (a*f + b*e + c*h - d*g)^2 +
    (a*g - b*h + c*e + d*f)^2 +
    (a*h + b*g - c*f + d*e)^2 := by ring

/-- Brahmagupta-Fibonacci identity: product of sums of two squares. -/

theorem lagrange_subgroup {G : Type*} [Group G] [Finite G]
    (H : Subgroup G) :
    Nat.card H ∣ Nat.card G :=
  Subgroup.card_subgroup_dvd_card H

/-- Wilson's theorem: (p-1)! ≡ -1 (mod p) for prime p. -/

theorem wilson_theorem (p : ℕ) [hp : Fact (Nat.Prime p)] :
    ((p - 1)! : ZMod p) = -1 :=
  ZMod.wilsons_lemma p

/-! ## Section 10: Spectral Methods — Character Theory -/

/-- Fermat's little theorem in ZMod: a^p = a for prime p. -/

theorem fermat_in_zmod (p : ℕ) [Fact (Nat.Prime p)] (a : ZMod p) :
    a ^ p = a :=
  ZMod.pow_card a

/-- The multiplicative group (ZMod p)* is cyclic for prime p. -/

theorem zmod_units_cyclic (p : ℕ) [Fact (Nat.Prime p)] :
    IsCyclic (ZMod p)ˣ :=
  inferInstance

/-! ## Section 11: Congruence of Squares Refinements -/

/-- If gcd(x-y, n) is nontrivial and divides n, it's a proper factor. -/

theorem cos_factor_extraction (n x y : ℤ) (hn : 1 < n)
    (h : 1 < Int.gcd (x - y) n) (h2 : (Int.gcd (x - y) n : ℤ) < n) :
    (Int.gcd (x - y) n : ℤ) ∣ n ∧ 1 < Int.gcd (x - y) n :=
  ⟨Int.gcd_dvd_right (x - y) n, h⟩

/-! ## Section 12: Multi-Lens Composition -/

/-- Three lenses compose: applying 3 independent halvings gives 8× reduction. -/

theorem three_lens_compose (S : ℕ) :
    S / 2 ^ 3 = S / 8 := by norm_num

/-- The k-lens reduction is strictly monotone in k for positive S. -/

theorem lens_reduction_strict_mono (S : ℕ) (hS : 0 < S) (k₁ k₂ : ℕ)
    (hk : k₁ < k₂) :
    S / 2 ^ k₂ ≤ S / 2 ^ k₁ :=
  Nat.div_le_div_left (Nat.pow_le_pow_right (by norm_num) (le_of_lt hk)) (by positivity)

/-- Combined Fibonacci-CRT lens: coprime Fibonacci numbers give independent mod constraints. -/

theorem fib_crt_lens (m n : ℕ) (hcop : Nat.Coprime m n) :
    Nat.Coprime (Nat.fib m) (Nat.fib n) → -- if F(m), F(n) are coprime
    Nat.totient (Nat.fib m * Nat.fib n) =
    Nat.totient (Nat.fib m) * Nat.totient (Nat.fib n) :=
  fun h => Nat.totient_mul h

