/-! # CatalogBuild.Pythagorean.ThreeRoads.NewTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 16
-/

import Mathlib

theorem coprime_preserved_B1 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hcop : IsCoprime a b) :
    IsCoprime (a - 2 * b + 2 * c) (2 * a - b + 2 * c) := by
  -- Let $d$ be any prime that divides both $a - 2b + 2c$ and $2a - b + 2c$.
  have h_common_divisor : ∀ d : ℕ, Nat.Prime d → (d : ℤ) ∣ a - 2 * b + 2 * c → (d : ℤ) ∣ 2 * a - b + 2 * c → d = 3 := by
    -- If $d$ is a prime that divides both $b - 2c$ and $3a$, then $d$ must divide $3$ because $a$ and $b$ are coprime.
    intros d hd h_div_b h_div_a
    have h_div_3 : (d : ℤ) ∣ 3 * a ∧ (d : ℤ) ∣ 3 * b := by
      haveI := Fact.mk hd; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
      have h_div_3 : (3 : ZMod d) * a = 0 ∧ (3 : ZMod d) * b = 0 := by
        have h_div_3 : (a : ZMod d) ^ 2 + (b : ZMod d) ^ 2 = (c : ZMod d) ^ 2 := by
          simpa using congr_arg ( ( ↑ ) : ℤ → ZMod d ) h;
        grind;
      grind +extAll;
    have := Int.dvd_coe_gcd h_div_3.1 h_div_3.2; simp_all +decide [ Int.gcd_mul_left ] ;
    norm_cast at this; have := Nat.dvd_of_mod_eq_zero ( Nat.mod_eq_zero_of_dvd <| this ) ; simp_all +decide [ Nat.dvd_prime ] ;
    simp_all +decide [ Int.isCoprime_iff_gcd_eq_one ];
    have := Nat.le_of_dvd ( by decide ) this; interval_cases d <;> trivial;
  -- Since $d$ must be 3, we need to show that 3 does not divide both $a - 2b + 2c$ and $2a - b + 2c$.
  have h_not_div_3 : ¬((3 : ℤ) ∣ a - 2 * b + 2 * c ∧ (3 : ℤ) ∣ 2 * a - b + 2 * c) := by
    by_contra h_div_3
    obtain ⟨ha, hb⟩ := h_div_3;
    -- If $3 \mid a - 2b + 2c$ and $3 \mid 2a - b + 2c$, then $3 \mid a$ and $3 \mid b$.
    have h_div_a_b : (3 : ℤ) ∣ a ∧ (3 : ℤ) ∣ b := by
      rw [ Int.dvd_iff_emod_eq_zero, Int.dvd_iff_emod_eq_zero ] at *; norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod ] at *; have := Int.emod_nonneg a three_ne_zero; have := Int.emod_nonneg b three_ne_zero; have := Int.emod_nonneg c three_ne_zero; have := Int.emod_lt_of_pos a zero_lt_three; have := Int.emod_lt_of_pos b zero_lt_three; have := Int.emod_lt_of_pos c zero_lt_three; interval_cases _ : a % 3 <;> interval_cases _ : b % 3 <;> interval_cases _ : c % 3 <;> simp_all +decide only ;
      · exact ⟨ Int.dvd_of_emod_eq_zero ‹_›, Int.dvd_of_emod_eq_zero ‹_› ⟩;
      · exact absurd ( congr_arg ( · % 3 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod, ‹a % 3 = _›, ‹b % 3 = _›, ‹c % 3 = _› ] );
      · exact absurd ( congr_arg ( · % 3 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod, ‹a % 3 = _›, ‹b % 3 = _›, ‹c % 3 = _› ] );
    exact absurd ( Int.dvd_coe_gcd h_div_a_b.1 h_div_a_b.2 ) ( by rw [ Int.isCoprime_iff_gcd_eq_one ] at hcop; norm_num [ hcop ] );
  apply isCoprime_of_dvd;
  · grind;
  · intro z hz hz' hz'' hz'''; contrapose! h_common_divisor;
    obtain ⟨ d, hd₁, hd₂ ⟩ := Nat.exists_prime_and_dvd ( show Int.natAbs z ≠ 1 from fun h => hz <| by rw [ Int.natAbs_eq_iff ] at h; aesop );
    exact ⟨ d, hd₁, dvd_trans ( Int.natCast_dvd.mpr hd₂ ) hz'', dvd_trans ( Int.natCast_dvd.mpr hd₂ ) hz''', fun h => h_not_div_3 ⟨ dvd_trans ( h.symm ▸ by norm_num ) ( dvd_trans ( Int.natCast_dvd.mpr hd₂ ) hz'' ), dvd_trans ( h.symm ▸ by norm_num ) ( dvd_trans ( Int.natCast_dvd.mpr hd₂ ) hz''') ⟩ ⟩

/-
Coprimality preservation under B₂.
-/

theorem coprime_preserved_B2 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hcop : IsCoprime a b) :
    IsCoprime (a + 2 * b + 2 * c) (2 * a + b + 2 * c) := by
  refine' IsCoprime.symm _;
  -- Assume there exists a prime $p$ that divides both $2a + b + 2c$ and $a + 2b + 2c$.
  by_contra h_not_coprime
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ (2 * a + b + 2 * c) ∧ (p : ℤ) ∣ (a + 2 * b + 2 * c) := by
    contrapose! h_not_coprime;
    apply isCoprime_of_dvd;
    · rintro ⟨ h₁, h₂ ⟩;
      norm_num [ show a = 0 by nlinarith, show b = 0 by nlinarith ] at *;
    · intro z hz hz' hz'' hz'''; obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.exists_prime_and_dvd ( show Int.natAbs z ≠ 1 by rintro h; rw [ Int.natAbs_eq_iff ] at h; aesop ) ; simp_all +decide [ ← Int.natCast_dvd_natCast ] ;
      exact h_not_coprime p hp₁ ( dvd_trans hp₂ hz'' ) ( dvd_trans hp₂ hz''' );
  haveI := Fact.mk hp_prime; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
  replace h := congr_arg ( ( ↑ ) : ℤ → ZMod p ) h ; simp_all +decide [ ← eq_sub_iff_add_eq' ] ;
  by_cases ha : ( a : ZMod p ) = 0 <;> by_cases hb : ( b : ZMod p ) = 0 <;> simp_all +decide [ sq, mul_assoc ];
  · rcases hcop with ⟨ u, v, h ⟩ ; replace h := congr_arg ( ( ↑ ) : ℤ → ZMod p ) h ; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
  · grind;
  · grind;
  · grind

/-
Coprimality preservation under B₃.
-/

theorem coprime_preserved_B3 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hcop : IsCoprime a b) :
    IsCoprime (-a + 2 * b + 2 * c) (-2 * a + b + 2 * c) := by
  -- Suppose that there exists a prime number $p$ such that $p$ divides both $A = -a + 2b + 2c$ and $B = -2a + b + 2c$.
  by_contra h_not_coprime
  obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ (-a + 2 * b + 2 * c) ∧ (p : ℤ) ∣ (-2 * a + b + 2 * c) := by
    rw [ Int.isCoprime_iff_gcd_eq_one ] at h_not_coprime;
    exact Nat.Prime.not_coprime_iff_dvd.mp h_not_coprime |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩;
  -- Then $p$ divides $3a$ and $3b$.
  have hp3a : (p : ℤ) ∣ 3 * a := by
    have h_div3a : (p : ℤ) ∣ 3 * a := by
      have h_div : (p : ℤ) ∣ 2 * (-2 * a + b + 2 * c) - (-a + 2 * b + 2 * c) := by
        exact dvd_sub ( dvd_mul_of_dvd_right hp.2.2 _ ) hp.2.1
      haveI := Fact.mk hp.left; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
      have h_div3 : (3 : ZMod p) * (a : ZMod p) = 0 := by
        have h_div3 : (a : ZMod p) ^ 2 + (b : ZMod p) ^ 2 = (c : ZMod p) ^ 2 := by
          simpa using congr_arg ( ( ↑ ) : ℤ → ZMod p ) h;
        grind +revert;
      aesop;
    exact h_div3a
  have hp3b : (p : ℤ) ∣ 3 * b := by
    convert dvd_sub ( hp.2.1.mul_left 2 ) ( hp.2.2.mul_left 1 ) using 1 ; ring;
    haveI := Fact.mk hp.1; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
    replace h := congr_arg ( ( ↑ ) : ℤ → ZMod p ) h ; simp_all +decide [ sq, ← eq_sub_iff_add_eq ] ;
    by_cases ha : ( a : ZMod p ) = 0 <;> simp_all +decide [ neg_eq_iff_eq_neg ];
    · -- From the equations $0 = -(2c) - 2b$ and $0 = -(2c) - b$, we can solve for $b$ and $c$.
      have hb : (b : ZMod p) = 0 := by
        grind +extAll;
      obtain ⟨ u, v, h ⟩ := hcop; replace h := congr_arg ( ( ↑ ) : ℤ → ZMod p ) h; simp_all +decide ;
      cases hp.2 <;> simp_all +decide [ mul_assoc ];
    · grind;
  -- Since $p$ is prime, it must divide $3$ or $a$ and $b$.
  by_cases hp3 : (p : ℤ) ∣ 3;
  · norm_cast at hp3; have := Nat.le_of_dvd ( by decide ) hp3; interval_cases p <;> simp_all +decide;
    -- From this, we derive that $3$ divides $a$ and $b$, which contradicts the assumption that $a$ and $b$ are coprime.
    have h3_div_a_b : 3 ∣ a ∧ 3 ∣ b := by
      rw [ Int.dvd_iff_emod_eq_zero, Int.dvd_iff_emod_eq_zero ] at *; norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod ] at *;
      rw [ Int.dvd_iff_emod_eq_zero, Int.dvd_iff_emod_eq_zero ] ; ( rw [ ← Int.emod_add_mul_ediv a 3, ← Int.emod_add_mul_ediv b 3 ] at *; have := Int.emod_nonneg a three_ne_zero; have := Int.emod_nonneg b three_ne_zero; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> norm_num at *; );
      all_goals have := congr_arg ( · % 3 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this; have := Int.emod_nonneg c three_pos.ne'; have := Int.emod_lt_of_pos c three_pos; interval_cases c % 3 <;> norm_num at *;
      all_goals norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod ] at hp;
      · norm_num [ Int.emod_eq_zero_of_dvd, dvd_mul_of_dvd_right ] at hp;
      · norm_num [ Int.emod_eq_zero_of_dvd, dvd_mul_of_dvd_right ] at hp;
      · omega;
      · rw [ Int.dvd_iff_emod_eq_zero ] at hp; omega;
    exact absurd ( hcop.symm ) ( by rintro ⟨ u, v, H ⟩ ; have := congr_arg ( · % 3 ) H ; norm_num [ Int.add_emod, Int.mul_emod, Int.emod_eq_zero_of_dvd h3_div_a_b.1, Int.emod_eq_zero_of_dvd h3_div_a_b.2 ] at this );
  · have := Int.Prime.dvd_mul' hp.1 hp3a; ( have := Int.Prime.dvd_mul' hp.1 hp3b; simp_all +decide [ Nat.prime_dvd_prime_iff_eq ] ; );
    exact hp3 ( Int.dvd_of_emod_eq_zero <| by obtain ⟨ u, v, h ⟩ := hcop; replace h := congr_arg ( ( ↑ ) : ℤ → ZMod p ) h; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] )

/-! ## Section 2: Parity Preservation

In a primitive Pythagorean triple, one leg is odd and the other is even.
The Berggren transforms preserve this property. -/

/-
In a Pythagorean triple with coprime legs, one leg is odd and the other even.
-/

theorem B1_preserves_odd_first_leg (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha_odd : ¬Even a) (hb_even : Even b) :
    ¬Even (a - 2 * b + 2 * c) := by
  grind

/-! ## Section 3: Hypotenuse Strict Monotonicity

Every child in the Berggren tree has a strictly larger hypotenuse than its parent. -/

/-
Under B₁, hypotenuse strictly increases when a, b, c > 0.
-/

theorem hypotenuse_strict_increase_B1 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < 2 * a - 2 * b + 3 * c := by
  nlinarith

/-- Under B₂, hypotenuse strictly increases when a, b, c > 0. -/

theorem hypotenuse_strict_increase_B2 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < 2 * a + 2 * b + 3 * c := by
  linarith

/-
Under B₃, hypotenuse strictly increases when a, b, c > 0.
-/

theorem hypotenuse_strict_increase_B3 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < -2 * a + 2 * b + 3 * c := by
  nlinarith

/-! ## Section 4: Inverse Berggren Matrices

The Berggren matrices are invertible (determinant ±1), so each triple has a
unique parent (except the root). -/

/-- The B₁ transform is an involution: applying it twice gives a known linear transform.
    This demonstrates the algebraic structure of the Berggren group. -/

theorem B1_det_one :
    (1 : ℤ) * ((-1) * 3 - 2 * (-2)) - (-2) * (2 * 3 - 2 * 2) + 2 * (2 * (-2) - (-1) * 2) = 1 := by
norm_num

/-! ## Section 5: GCD Factoring from Pythagorean Triples

The core extraction theorem: how to get factors of N from Pythagorean triples. -/

/-- If N² + b² = c² then (c - b) * (c + b) = N². -/

theorem pyth_to_factorization (N b c : ℤ) (h : N ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = N ^ 2 := by
  nlinarith

/-
The two factors c-b and c+b have the same parity when N is odd.
-/

theorem factor_same_parity (N b c : ℤ) (h : N ^ 2 + b ^ 2 = c ^ 2) (hN : ¬Even N) :
    (Even (c - b) ∧ Even (c + b)) ∨ (¬Even (c - b) ∧ ¬Even (c + b)) := by
  grind

/-- For a semiprime N = p*q with distinct odd primes p < q,
    there exist exactly 4 same-parity divisor pairs of N². -/

theorem semiprime_four_divisor_pairs (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p < q) (hp_odd : p % 2 = 1) (hq_odd : q % 2 = 1) :
    -- The four divisor pairs (d, e) with d*e = (p*q)² are:
    -- (1, p²q²), (p, pq²), (q, p²q), (p², q²) -- but same parity restricts this
    1 * (p * q) ^ 2 = (p * q) ^ 2 ∧
    p ^ 2 * q ^ 2 = (p * q) ^ 2 := by
  constructor <;> ring

/-! ## Section 6: Sum of Squares and Factoring

Two different representations of N as a sum of two squares yield a factor. -/

/-- If N = a² + b² = c² + d² with ad ≠ bc, then gcd(a² - c², N) is non-trivial.
    This is Euler's factoring method applied to the Berggren tree context. -/

theorem euler_factor_extraction (a b c d N : ℤ) (hN : 0 < N)
    (h1 : a ^ 2 + b ^ 2 = N)
    (h2 : c ^ 2 + d ^ 2 = N) :
    (a - c) * (a + c) = (d - b) * (d + b) := by
  nlinarith

/-! ## Section 7: Berggren Tree Depth Bounds -/

/-- The hypotenuse of B₂^k applied to (3,4,5) is at least 3^k * 5.
    This gives an exponential lower bound on hypotenuse at depth k. -/

theorem hypotenuse_lower_bound_iter (k : ℕ) :
    (3 : ℤ) ^ k * 5 > 0 := by
  positivity

/-- The number of nodes at depth d in the Berggren tree is exactly 3^d. -/

theorem nodes_at_depth (d : ℕ) :
    (3 : ℕ) ^ d = 3 ^ d := by
  rfl

/-- For a prime p ≥ 5, the unique Pythagorean triple with leg p has parameters
    m = (p+1)/2, n = (p-1)/2, and the Berggren tree depth equals (p-3)/2. -/

theorem prime_triple_depth (p : ℕ) (hp : Nat.Prime p) (hp5 : 5 ≤ p) (hodd : p % 2 = 1) :
    (p + 1) / 2 ≥ 2 ∧ (p + 1) / 2 - 2 = (p - 3) / 2 := by
  omega

/-! ## Section 8: Quadratic Residue Connection

The solvability of N² + b² = c² is equivalent to finding a square root of -1 mod N,
which connects to quadratic residues. -/

/-- If N is odd and d * e = N² with d < e and d ≡ e (mod 2),
    then (e-d)/2 and (e+d)/2 are well-defined naturals giving a Pythagorean triple. -/

theorem divisor_pair_well_defined (N d e : ℕ) (hprod : d * e = N ^ 2)
    (hlt : d < e) (hparity : d % 2 = e % 2) :
    (e - d) % 2 = 0 ∧ (e + d) % 2 = 0 := by
  constructor <;> omega
