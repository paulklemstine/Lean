/-! # CatalogBuild.Computation.Factoring.Core

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 26
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Factoring.Core
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 26] -/
theorem fibonacci_search_reduction (k : ℕ) (hk : 2 ≤ k) :
    Nat.fib (k + 2) < 2 ^ k := by
  rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.pow_succ' ];
  induction' k with k ih <;> norm_num [ Nat.pow_succ', Nat.fib_add_two ] at * ; linarith [ Nat.zero_le ( 2 ^ k ) ]



/-- The bidirectional carry identity: 2·F(n+2) = F(n+3) + F(n).
This creates carries propagating both forward and backward. -/
theorem fib_carry_rule (n : ℕ) : 2 * Nat.fib (n + 2) = Nat.fib (n + 3) + Nat.fib n := by
  simp +arith +decide [Nat.fib_add_two]



/-- The adjacency normalization rule: F(n) + F(n+1) = F(n+2). -/
theorem fib_adjacency_rule (n : ℕ) : Nat.fib n + Nat.fib (n + 1) = Nat.fib (n + 2) := by
  exact Eq.symm fib_add_two



/-- On the hyperbola xy = N, every divisor gives a lattice point. -/
theorem hyperbola_gives_divisor {N d : ℕ} (hN : 0 < N) (hd : d ∣ N) (hd_pos : 0 < d) :
    d * (N / d) = N :=
  Nat.mul_div_cancel' hd



/-- Any divisor d of N satisfies d ≤ N. -/
theorem factor_bounded {N d : ℕ} (hN : 0 < N) (hd : d ∣ N) :
    d ≤ N :=
  Nat.le_of_dvd hN hd



/-- The squaring map on ZMod n. -/
noncomputable def sqMap (n : ℕ) : ZMod n → ZMod n := fun x => x * x



theorem sq_iter_eq_pow (n : ℕ) [NeZero n] (x : ZMod n) (k : ℕ) :
    (sqMap n)^[k] x = x ^ (2 ^ k) := by
  induction k <;> simp_all +decide [ pow_succ, pow_mul, Function.iterate_succ_apply' ];
  bound



theorem orbit_collision_gives_factor {n : ℕ} {x y : ℤ}
    (hn : 1 < n) (p : ℕ) (hp : Nat.Prime p) (hpn : p ∣ n) (hp_lt : p < n)
    (hmod_p : (x : ZMod p) = (y : ZMod p))
    (hmod_n : ¬((x : ZMod n) = (y : ZMod n))) :
    1 < Int.gcd (x - y) n := by
  -- Since $p$ divides both $(x - y)$ and $n$, it follows that $p$ divides their gcd.
  have h_div_gcd : (p : ℤ) ∣ Int.gcd (x - y) n := by
    refine' mod_cast Nat.dvd_gcd _ hpn;
    simp_all +decide [ ← Int.natCast_dvd_natCast, ZMod.intCast_eq_intCast_iff ];
    exact hmod_p.symm.dvd;
  exact lt_of_lt_of_le hp.one_lt ( Nat.cast_le.mp ( Int.le_of_dvd ( Int.natCast_pos.mpr ( Int.gcd_pos_of_ne_zero_right _ ( by positivity ) ) ) h_div_gcd ) )



/-- Fermat's little theorem: a^p ≡ a (mod p) for prime p. -/
theorem fermat_little (p : ℕ) (hp : Nat.Prime p) (a : ZMod p) :
    a ^ p = a := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact ZMod.pow_card a



/-- Brahmagupta-Fibonacci: product of sums of 2 squares is a sum of 2 squares. -/
theorem norm_mult_complex (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring



/-- Alternate form of Brahmagupta-Fibonacci. -/
theorem norm_mult_complex_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring



/-- Two representations N = a²+b² = c²+d² produce a factoring equation:
(a-c)(a+c) = (d-b)(d+b). -/
theorem two_representations_factor (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a - c) * (a + c) = (d - b) * (d + b) := by nlinarith



/-- Euler 4-square identity: product of sums of 4 squares is a sum of 4 squares. -/
theorem norm_mult_quaternion (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by ring



/-- Bézout's identity: coprime integers generate ℤ. -/
theorem bezout_generates {a b : ℤ} (h : IsCoprime a b) :
    ∃ s t : ℤ, s * a + t * b = 1 := by
  obtain ⟨s, t, hst⟩ := h
  exact ⟨s, t, hst⟩



/-- For any divisor d of n, d * (n/d) = n (the lattice point identity). -/
theorem divisor_vector_product {n d : ℕ} (hd : d ∣ n) :
    (d : ℤ) * (↑(n / d) : ℤ) = (n : ℤ) := by
  push_cast
  exact_mod_cast Nat.mul_div_cancel' hd



/-- Difference of squares factorization. -/
theorem diff_of_squares (x y : ℤ) : x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring



theorem congruence_of_squares {n x y : ℤ} (hn : 1 < n)
    (hcong : (n : ℤ) ∣ x ^ 2 - y ^ 2)
    (hne_sub : ¬ (n : ℤ) ∣ x - y)
    (hne_add : ¬ (n : ℤ) ∣ x + y) :
    1 < Int.gcd (x - y) n ∧ (Int.gcd (x - y) n : ℤ) < n := by
  refine' ⟨ _, _ ⟩;
  · by_contra! h;
    -- If gcd(x - y, n) = 1, then since n | (x - y)(x + y) and gcd(x - y, n) = 1 (i.e. IsCoprime), by Euclid's lemma n | (x + y), contradicting hne_add.
    have h_euclid : IsCoprime (x - y) n := by
      exact Int.isCoprime_iff_gcd_eq_one.mpr ( le_antisymm h ( Int.gcd_pos_of_ne_zero_right _ ( by linarith ) ) );
    exact hne_add <| h_euclid.symm.dvd_of_dvd_mul_left <| by convert hcong using 1; ring;
  · -- Since $n \nmid (x - y)$, we have $\gcd(x - y, n) \neq n$.
    have h_gcd_ne_n : Int.gcd (x - y) n ≠ Int.natAbs n := by
      exact fun h => hne_sub <| Int.natAbs_dvd_natAbs.mp <| h ▸ Nat.gcd_dvd_left _ _;
    exact_mod_cast lt_of_le_of_ne ( Int.le_of_dvd ( by linarith ) ( Int.gcd_dvd_right _ _ ) ) fun h => h_gcd_ne_n <| by linarith [ abs_of_pos ( zero_lt_one.trans hn ) ] ;



/-- If p * q = N with 1 < p and 1 < q, then N is composite and p, q are factors. -/
theorem unified_correctness {N p q : ℕ} (hp : 1 < p) (hq : 1 < q) (hpq : p * q = N) :
    ¬ Nat.Prime N ∧ p ∣ N ∧ q ∣ N := by
  refine ⟨?_, ⟨q, hpq.symm⟩, ⟨p, ?_⟩⟩
  · intro hprime
    have h := hprime.eq_one_or_self_of_dvd p ⟨q, hpq.symm⟩
    rcases h with rfl | rfl
    · omega
    · -- p = N = p * q, so q = 1, contradicting hq
      have : 1 * q < p * q := by nlinarith
      nlinarith
  · rw [mul_comm] at hpq; exact hpq.symm



/-- k independent halving constraints reduce the search space by 2^k.
Stated: S / 2^k < S for S > 0 and k ≥ 1. -/
theorem k_lens_reduction (S : ℕ) (k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S := by
  apply Nat.div_lt_self hS
  calc 2 ^ k ≥ 2 ^ 1 := Nat.pow_le_pow_right (by norm_num) hk
    _ = 2 := by norm_num



/-- 2^k ≥ 1: exponential growth is always at least 1. -/
theorem exponential_growth (k : ℕ) : 1 ≤ 2 ^ k := Nat.one_le_two_pow



/-- Lens 1 (Fibonacci): Search space reduction from non-adjacency. -/
theorem lens_fibonacci (k : ℕ) (hk : 2 ≤ k) :
    Nat.fib (k + 2) < 2 ^ k :=
  fibonacci_search_reduction k hk



/-- Lens 2 (Hyperbolic): Divisors are bounded by N. -/
theorem lens_hyperbolic {N d : ℕ} (hN : 0 < N) (hd : d ∣ N) :
    d ≤ N :=
  factor_bounded hN hd



/-- Lens 4 (Spectral): Fermat-Euler in ZMod. -/
theorem lens_spectral (p : ℕ) (hp : Nat.Prime p) (a : ZMod p) :
    a ^ p = a :=
  fermat_little p hp a



/-- Lens 5 (Division Algebra): Norm multiplicativity. -/
theorem lens_division_algebra (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 :=
  norm_mult_complex a b c d



/-- Lens 6 (Lattice): Bézout's identity. -/
theorem lens_lattice {a b : ℤ} (h : IsCoprime a b) :
    ∃ s t : ℤ, s * a + t * b = 1 :=
  bezout_generates h



/-- Lens 7 (Congruence of Squares): x²-y² = (x-y)(x+y). -/
theorem lens_congruence (x y : ℤ) :
    x ^ 2 - y ^ 2 = (x - y) * (x + y) :=
  diff_of_squares x y



end
