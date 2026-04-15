/-! # CatalogBuild.Pythagorean.Applications.PythagoreanPhotonics

Auto-generated from theorem catalog database.
Domain: Pythagorean/Applications
Declarations: 32
-/

import Mathlib

/-- A lattice null vector is a nonzero integer vector on the null cone -/
def IsLatticeNull (a b c : ℤ) : Prop :=
  a ^ 2 + b ^ 2 = c ^ 2 ∧ (a ≠ 0 ∨ b ≠ 0)

/-- The Minkowski form in (2+1) dimensions -/

def minkowski3 (a b c : ℤ) : ℤ :=
  a ^ 2 + b ^ 2 - c ^ 2

/-
PROBLEM
A lattice null vector has zero Minkowski norm

PROVIDED SOLUTION
Unfold IsLatticeNull and minkowski3. From h.1 we have a^2 + b^2 = c^2, so a^2 + b^2 - c^2 = 0. Use omega or linarith.
-/

theorem lattice_null_minkowski_zero (a b c : ℤ) (h : IsLatticeNull a b c) :
    minkowski3 a b c = 0 := by
  unfold IsLatticeNull at h; unfold minkowski3; linarith;

/-
PROBLEM
Negating components preserves the null property

PROVIDED SOLUTION
Unfold IsLatticeNull. neg_sq shows (-a)^2 = a^2, so the Pythagorean equation is preserved. The nonzero condition follows since -a ≠ 0 ↔ a ≠ 0.
-/

theorem lattice_null_neg (a b c : ℤ) (h : IsLatticeNull a b c) :
    IsLatticeNull (-a) (-b) c := by
  unfold IsLatticeNull at *; aesop;

/-
PROBLEM
Swapping legs preserves the null property

PROVIDED SOLUTION
Unfold IsLatticeNull. Use add_comm to swap a^2 + b^2 to b^2 + a^2. The nonzero condition: swap the disjunction.
-/

theorem lattice_null_swap (a b c : ℤ) (h : IsLatticeNull a b c) :
    IsLatticeNull b a c := by
  exact ⟨ by linarith [ h.1 ], by have := h.2; tauto ⟩

/-
PROBLEM
Scaling preserves the null property

PROVIDED SOLUTION
Unfold IsLatticeNull. (k*a)^2 + (k*b)^2 = k^2*(a^2+b^2) = k^2*c^2 = (k*c)^2 by ring and h.1. For nonzero: if a ≠ 0 then k*a ≠ 0 since k ≠ 0, similarly for b.
-/

theorem lattice_null_scale (a b c : ℤ) (k : ℤ) (hk : k ≠ 0) (h : IsLatticeNull a b c) :
    IsLatticeNull (k * a) (k * b) (k * c) := by
  exact ⟨ by linear_combination' h.1 * k ^ 2, by exact Or.imp ( fun ha => by aesop ) ( fun hb => by aesop ) h.2 ⟩

/-! ## Section 2: Euclid's Formula and Parametric Families -/

/-
PROBLEM
Every Euclid-parametrized triple is a lattice null vector (when m ≠ n)

PROVIDED SOLUTION
Unfold IsLatticeNull. The Pythagorean equation (m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2 follows by ring. For the nonzero condition, m^2 - n^2 = (m-n)(m+n). Since m ≠ n, m-n ≠ 0. Also m+n is nonzero if m and n are not both zero. Actually we just need to show m^2-n^2 ≠ 0 OR 2mn ≠ 0. Since m ≠ n, m^2 ≠ n^2 so m^2 - n^2 ≠ 0. Use sq_left_inj or similar to show m^2 ≠ n^2 from m ≠ n... Actually that's not true in general (could have m = -n). Let me think again. We have m ≠ n. If m^2 = n^2 then m = n or m = -n. Since m ≠ n, we'd need m = -n. Then 2mn = -2n^2. If n ≠ 0, then 2mn ≠ 0. If n = 0, then m = 0 too contradicting m ≠ n... wait m = -n and n = 0 means m = 0 = n, contradiction. So either m^2 - n^2 ≠ 0 or (m = -n and 2mn ≠ 0).
-/

theorem euclid_is_lattice_null (m n : ℤ) (hmn : m ≠ n) :
    IsLatticeNull (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  -- By definition of IsLatticeNull, we need to show that (m^2 - n^2)^2 + (2mn)^2 = (m^2 + n^2)^2 and that m^2 - n^2 ≠ 0 or 2mn ≠ 0.
  constructor;
  · grind;
  · contrapose! hmn; aesop;

/-
PROBLEM
The Euclid parametrization gives positive hypotenuse when m, n > 0

PROVIDED SOLUTION
m^2 > 0 and n^2 > 0, so m^2 + n^2 > 0. Use positivity or nlinarith [sq_nonneg m, sq_nonneg n, sq_pos_of_pos hm, sq_pos_of_pos hn].
-/

theorem euclid_hypotenuse_pos (m n : ℤ) (hm : 0 < m) (hn : 0 < n) :
    0 < m ^ 2 + n ^ 2 := by
  positivity

/-
PROBLEM
Euclid's formula: the algebraic identity underlying Pythagorean triples

PROVIDED SOLUTION
Pure algebraic identity. Use ring.
-/

theorem euclid_identity (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring

/-! ## Section 3: Berggren Tree Growth Bounds -/

/-
PROBLEM
Under Berggren M₂, the hypotenuse satisfies c' = 2a + 2b + 3c ≥ 3c for a,b > 0

PROVIDED SOLUTION
2*a + 2*b + 3*c > 3*c since a > 0 and b > 0. Use linarith.
-/

theorem berggren_B_hypotenuse_growth (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    3 * c < 2 * a + 2 * b + 3 * c := by
  linarith

/-
PROBLEM
Under any Berggren transformation, the hypotenuse strictly increases
    for positive primitive triples

PROVIDED SOLUTION
We need c < 2a - 2b + 3c, i.e., 2a - 2b + 2c > 0, i.e., a - b + c > 0. Since a^2 + b^2 = c^2, we have c ≥ b (since a > 0), so c - b ≥ 0, and a > 0, hence a + (c-b) > 0. Use nlinarith with h, ha, hb, hc.
-/

theorem berggren_A_hypotenuse_bound (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    c < 2 * a - 2 * b + 3 * c := by
  nlinarith only [ ha, hb, hc, hpyth ]

/-! ## Section 4: Gaussian Integers and Optical Superposition -/

/-
PROBLEM
The Brahmagupta-Fibonacci identity: sums of squares are multiplicative.
    Physical interpretation: combining two polarization states produces another.

PROVIDED SOLUTION
ring
-/

theorem brahmagupta_fibonacci_explicit (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring

/-
PROBLEM
Alternative form of Brahmagupta-Fibonacci

PROVIDED SOLUTION
ring
-/

theorem hypotenuse_product_is_sum_of_squares
    (a b c d : ℤ) (h1 : a ^ 2 + b ^ 2 = c ^ 2) (h2 : a ^ 2 + b ^ 2 = d ^ 2) :
    ∃ e f : ℤ, c ^ 2 * d ^ 2 = e ^ 2 + f ^ 2 := by
  exact ⟨ c * d, 0, by ring ⟩

/-! ## Section 5: Pythagorean Quadruples and 3D Light Cones -/

/-- The (3+1) Pythagorean quadruple relation -/

theorem quad_param_valid (m n p q : ℤ) :
    IsPythQuadruple
      (m^2 + n^2 - p^2 - q^2)
      (2 * (m*q + n*p))
      (2 * (n*q - m*p))
      (m^2 + n^2 + p^2 + q^2) := by
  exact Eq.symm ( by ring ) ;

/-
PROBLEM
Embedding: every Pythagorean triple gives a quadruple

PROVIDED SOLUTION
Unfold IsPythQuadruple. a^2 + b^2 + 0^2 = a^2 + b^2 = c^2 by h. Use simp and h, or nlinarith [sq_nonneg 0].
-/

theorem triple_embeds_in_quadruple (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    IsPythQuadruple a b 0 c := by
  exact Eq.trans ( by ring ) h

/-
PROBLEM
Permuting spatial components preserves the quadruple property

PROVIDED SOLUTION
Unfold IsPythQuadruple. b^2 + a^2 + c^2 = a^2 + b^2 + c^2 = d^2. Use linarith or ring_nf with h.
-/

theorem quad_perm_12 (a b c d : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple b a c d := by
  unfold IsPythQuadruple at *; linarith;

/-
PROBLEM
Permuting spatial components preserves the quadruple property

PROVIDED SOLUTION
Unfold IsPythQuadruple. c^2 + b^2 + a^2 = a^2 + b^2 + c^2 = d^2. Use linarith.
-/

theorem quad_perm_13 (a b c d : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple c b a d := by
  unfold IsPythQuadruple at h ⊢; linarith;

/-
PROBLEM
Scaling quadruples

PROVIDED SOLUTION
Unfold IsPythQuadruple. (ka)^2 + (kb)^2 + (kc)^2 = k^2(a^2+b^2+c^2) = k^2*d^2 = (kd)^2 by ring and h.
-/

theorem quad_scale (a b c d k : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple (k*a) (k*b) (k*c) (k*d) := by
  unfold IsPythQuadruple at h ⊢; linear_combination' k ^ 2 * h;

/-! ## Section 6: Dispersion Relation Properties -/

/-
PROBLEM
The lattice dispersion correction is negative (energy is always ≤ pc)

PROVIDED SOLUTION
This is sin(x) ≤ x for x = p*a/2 > 0. Use Real.sin_le from Mathlib or sin_le_of_nonneg or similar.
-/

theorem lattice_dispersion_correction_sign (p a : ℝ) (hp : 0 < p) (ha : 0 < a) :
    Real.sin (p * a / 2) ≤ p * a / 2 := by
  exact le_of_lt ( Real.sin_lt <| by positivity )

/-
PROBLEM
For small momenta, the lattice dispersion approaches the continuous limit

PROVIDED SOLUTION
Use |sin(x) - x| ≤ |x|^3 / 6 ≤ x^3 for 0 ≤ x ≤ 1. Use Real.abs_sin_sub_self_le or similar Mathlib bound. Or use abs_sin_lt_abs_of_ne_zero and bound carefully.
-/

theorem dispersion_small_momentum (x : ℝ) (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    |Real.sin x - x| ≤ x ^ 3 := by
  have h_sin_approx : ∀ x : ℝ, 0 ≤ x → x ≤ 1 → |Real.sin x - x| ≤ x^3 := by
    intro x hx hx1
    have h_sin_approx : ∀ x : ℝ, 0 ≤ x → x ≤ 1 → Real.sin x ≥ x - x^3 / 6 := by
      -- Let's choose any $x$ in the interval $[0, 1]$.
      intro x hx hx1
      have h_sin_approx : ∀ t ∈ Set.Icc 0 x, Real.cos t ≥ 1 - t^2 / 2 := by
        exact fun t a => Real.one_sub_sq_div_two_le_cos;
      -- Integrate both sides of $\cos t \geq 1 - t^2 / 2$ from $0$ to $x$.
      have h_integral_approx : ∫ t in (0 : ℝ)..x, Real.cos t ≥ ∫ t in (0 : ℝ)..x, (1 - t^2 / 2) := by
        refine' intervalIntegral.integral_mono_on _ _ _ _ <;> aesop;
      norm_num at h_integral_approx; linarith;
    have h_sin_approx : ∀ x : ℝ, 0 ≤ x → x ≤ 1 → Real.sin x ≤ x := by
      exact fun x hx hx1 => if h : x = 0 then by norm_num [ h ] else le_of_lt ( Real.sin_lt <| lt_of_le_of_ne hx <| Ne.symm h );
    exact abs_le.mpr ⟨ by nlinarith [ pow_nonneg hx 2, pow_nonneg hx 3, ‹∀ x : ℝ, 0 ≤ x → x ≤ 1 → Real.sin x ≥ x - x ^ 3 / 6› x hx hx1 ], by nlinarith [ pow_nonneg hx 2, pow_nonneg hx 3, h_sin_approx x hx hx1 ] ⟩;
  exact h_sin_approx x hx hx1

/-! ## Section 7: Number-Theoretic Properties of the Lattice -/

/-
PROBLEM
In any Pythagorean triple, at least one leg must be divisible by 3

PROVIDED SOLUTION
Work modulo 3. Squares mod 3 are 0 or 1. If neither a nor b is divisible by 3, then a^2 ≡ 1 and b^2 ≡ 1 mod 3, so a^2+b^2 ≡ 2 mod 3. But c^2 mod 3 is 0 or 1, contradiction. Use ZMod 3 or work with Int.emod directly, or use omega on cases of a%3 and b%3.
-/

theorem pyth_triple_div_3 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    3 ∣ a ∨ 3 ∣ b := by
  -- Consider the equation modulo 3. The possible values for squares modulo 3 are 0 or 1.
  have h_mod3 : (a ^ 2 + b ^ 2) % 3 = c ^ 2 % 3 := by
    rw [h];
  norm_num [ sq, Int.add_emod, Int.mul_emod ] at h_mod3;
  rw [ Int.dvd_iff_emod_eq_zero, Int.dvd_iff_emod_eq_zero ] ; have := Int.emod_nonneg a three_ne_zero; have := Int.emod_nonneg b three_ne_zero; have := Int.emod_nonneg c three_ne_zero; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial;

/-
PROBLEM
In any Pythagorean triple, at least one leg must be divisible by 4

PROVIDED SOLUTION
We need to show 4 | a*b. Work mod 2: at least one of a,b must be even (since if both odd, a^2+b^2 ≡ 2 mod 4 but c^2 ≡ 0 or 1 mod 4). So 2 | a or 2 | b, hence 2 | ab. Actually we need 4 | ab. If one is even, say 2|a, write a = 2k. Need 4 | 2kb, i.e. 2 | kb. Actually the stronger result: in a Pythagorean triple, at least one of a,b is divisible by 2, and actually ab is divisible by 4 because one leg is divisible by 4 or both legs are even. Let me try a different approach: work mod 4. If a is odd and b is odd: contradiction as before. If a ≡ 0 mod 2 and b is odd: a^2 + b^2 = c^2, b odd so b^2 ≡ 1 mod 4, c^2 - a^2 ≡ 1 mod 4. c must be odd (since a even, b odd). So c^2 ≡ 1, a^2 ≡ 0 mod 4 means a ≡ 0 mod 2. Then a^2 can be 0 mod 4, giving 0+1 = 1 = c^2 mod 4 ✓. So a is divisible by 2, and ab is divisible by 2. We need 4. Actually if a ≡ 2 mod 4, a^2 ≡ 4 ≡ 0 mod 4 still. Hmm. The key is a must be divisible by 4 if b is odd... Actually let me try: use omega/decide on all cases of a%4 and b%4.
-/

theorem pyth_triple_div_4 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    4 ∣ a * b := by
  rcases Int.even_or_odd' a with ⟨ x, rfl | rfl ⟩ <;> ( rcases Int.even_or_odd' b with ⟨ y, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *; );
  · rcases Int.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> ( rcases Int.even_or_odd' y with ⟨ l, rfl | rfl ⟩ <;> ring_nf at * <;> have := congr_arg ( · % 4 ) h <;> norm_num [ Int.add_emod, Int.mul_emod ] at this ⊢; );
    · exact absurd ( congr_arg ( · % 8 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 0 : ℤ ) < 8 ) ; interval_cases c % 8 <;> trivial );
    · exact absurd ( congr_arg ( · % 8 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg c ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos c ( by decide : ( 0 : ℤ ) < 8 ) ; interval_cases c % 8 <;> trivial );
  · rcases Int.even_or_odd' y with ⟨ k, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;
    exact absurd ( congr_arg ( · % 8 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg x ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos x ( by norm_num : ( 8 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 8 : ℤ ) > 0 ) ; interval_cases x % 8 <;> interval_cases c % 8 <;> trivial );
  · exact absurd ( congr_arg ( · % 4 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg c four_pos.ne'; have := Int.emod_lt_of_pos c four_pos; interval_cases c % 4 <;> trivial )

/-
PROBLEM
The hypotenuse of a primitive triple is always odd

PROVIDED SOLUTION
If c is even, then c^2 ≡ 0 mod 4, so a^2 + b^2 ≡ 0 mod 4. Squares mod 4 are 0 or 1. So both a,b must be even. But then gcd(a,b) ≥ 2, contradicting gcd(a,gcd(b,c)) = 1 (since gcd(a,b) divides gcd(a,gcd(b,c))). Work with Nat.gcd and modular arithmetic.
-/

theorem primitive_hypotenuse_odd (a b c : ℕ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hgcd : Nat.gcd a (Nat.gcd b c) = 1)
    (ha : 0 < a) (hb : 0 < b) :
    ¬ 2 ∣ c := by
  contrapose! hgcd; have := congr_arg ( · % 4 ) h; rcases Nat.even_or_odd' a with ⟨ b₁, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' b with ⟨ b₂, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' c with ⟨ b₃, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at *;
  · norm_num [ Nat.gcd_mul_right, Nat.gcd_mul_left ];
  · grind;
  · norm_num [ Nat.dvd_add_left ] at hgcd

/-
PROBLEM
The 3-4-5 triple has the smallest hypotenuse among nontrivial triples

PROVIDED SOLUTION
Since a ≤ b and a^2 + b^2 = c^2, we have c^2 = a^2 + b^2 ≥ a^2 + a^2 = 2a^2, so c ≥ a√2 > a. Also c^2 ≤ 2b^2, so c ≤ b√2. Since gcd(a,b) = 1 and a ≤ b, and a^2 + b^2 = c^2, we need a ≥ 1 and b ≥ 2 (if b=1 then a=1 but 1+1=2 not a perfect square; if a=1, b^2 = c^2-1 = (c-1)(c+1), need (c-1)(c+1) to be a perfect square). The smallest cases: a=1, b=1: c^2=2, not integer. a=1, b=2: c^2=5, no. a=2, b=2: gcd=2≠1. a=1, b=3: c^2=10, no. a=2, b=3: c^2=13, no. a=1, b=4: c^2=17, no. a=3, b=4: c^2=25, c=5. ✓. So c ≥ 5. Use interval_cases or omega after bounding c.
-/

theorem smallest_primitive_triple (a b c : ℕ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b)
    (hab : a ≤ b) (hprim : Nat.gcd a b = 1) :
    5 ≤ c := by
  by_contra h_contra;
  interval_cases c <;> norm_num at * <;> have := Nat.le_of_lt_succ ( show a < 6 by nlinarith only [ h ] ) <;> have := Nat.le_of_lt_succ ( show b < 6 by nlinarith only [ h ] ) <;> interval_cases a <;> interval_cases b <;> trivial

/-! ## Section 8: Infinitude and Density Results -/

/-
PROBLEM
There exist arbitrarily large primitive Pythagorean triples

PROVIDED SOLUTION
Use the triple (3*(N+1), 4*(N+1), 5*(N+1)). Then c = 5*(N+1) > N, and 9(N+1)^2 + 16(N+1)^2 = 25(N+1)^2. All components are positive.
-/

theorem arbitrarily_large_triples (N : ℕ) :
    ∃ a b c : ℕ, a ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < a ∧ 0 < b ∧ N < c := by
  exact ⟨ 3 * ( N + 1 ), 4 * ( N + 1 ), 5 * ( N + 1 ), by ring, by positivity, by positivity, by linarith ⟩

/-
PROBLEM
There are infinitely many Pythagorean quadruples

PROVIDED SOLUTION
Use (a,b,c,d) = (1*(N+1), 2*(N+1), 2*(N+1), 3*(N+1)). Check: 1+4+4=9. So (N+1)^2 + 4(N+1)^2 + 4(N+1)^2 = 9(N+1)^2. d = 3(N+1) > N.
-/

theorem arbitrarily_large_quadruples (N : ℕ) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ∧ 0 < a ∧ 0 < b ∧ 0 < c ∧ N < d := by
  exact ⟨ 3 * N + 3, 4 * N + 4, 12 * N + 12, 13 * N + 13, by ring, by linarith, by linarith, by linarith, by linarith ⟩

/-
PROBLEM
Between any two Euclid parameters, there is a Pythagorean triple

PROVIDED SOLUTION
Take m = m₂, n = 1 (assuming m₂ ≥ 2, handle m₂ = 1 separately). Then the Euclid triple has c = m₂^2 + 1. We need m₁^2 < m₂^2 + 1 (true since m₁ < m₂) and m₂^2 + 1 ≤ m₂^2 + 1 (trivially). a = m₂^2 - 1, b = 2*m₂. Both positive when m₂ ≥ 2. For m₁ = 0 and m₂ = 1: use (3,4,5), c=5, need 0 < 5 ≤ 2, doesn't work. Actually let me reconsider. We need c with m₁^2 < c ≤ m₂^2 + 1. Let's use (3,4,5) for small cases. Use ⟨3, 4, 5, by norm_num, ...⟩ and show 5 ≤ m₂^2 + 1 when m₂ ≥ 2, and m₁^2 < 5 when m₁ ≤ 1. Actually let's use the triple (3*(m₁+1), 4*(m₁+1), 5*(m₁+1)) with c = 5(m₁+1). Then m₁^2 < 5(m₁+1) iff m₁^2 - 5m₁ - 5 < 0, true for m₁ ≤ 5. And 5(m₁+1) ≤ m₂^2 + 1 needs m₂ large enough... This is getting complicated. Let me just use Euclid: m = m₁+1, n = 1, giving c = (m₁+1)^2 + 1. Need m₁^2 < (m₁+1)^2 + 1, which is m₁^2 < m₁^2 + 2m₁ + 2, always true. And c ≤ m₂^2+1: (m₁+1)^2+1 ≤ m₂^2+1 iff (m₁+1)^2 ≤ m₂^2 iff m₁+1 ≤ m₂, i.e. m₁ < m₂, which is given. a = (m₁+1)^2-1, b = 2(m₁+1). a > 0 iff m₁ ≥ 1. If m₁ = 0, a = 0 which is not positive. Use a = 2*(m₁+1) and b = (m₁+1)^2-1 (swap). If m₁ = 0, b = 0, still not positive. Hmm. Actually we're looking for ℕ triples with a^2+b^2=c^2, not necessarily a,b > 0. Actually the statement doesn't require a,b > 0. It just says ∃ a b c, a^2+b^2=c^2 ∧ m₁^2 < c ∧ c ≤ m₂^2 + 1. Take a=0, b=c for any c, then 0+c^2=c^2 ✓. Then need m₁^2 < c ≤ m₂^2+1. Take c = m₁^2+1. Then m₁^2 < m₁^2+1 ✓. Need m₁^2+1 ≤ m₂^2+1, i.e. m₁^2 ≤ m₂^2, which is true since m₁ < m₂. Use a = 0, b = m₁^2+1, c = m₁^2+1.
-/

theorem euclid_density (m₁ m₂ : ℕ) (hm : m₁ < m₂) :
    ∃ a b c : ℕ, a ^ 2 + b ^ 2 = c ^ 2 ∧ m₁ ^ 2 < c ∧ c ≤ m₂ ^ 2 + 1 := by
  exact ⟨ 0, m₁ ^ 2 + 1, m₁ ^ 2 + 1, by ring, by nlinarith, by nlinarith ⟩

/-! ## Section 9: Conservation Laws on the Lattice -/

/-
PROBLEM
The Minkowski norm is conserved under Berggren transformations

PROVIDED SOLUTION
Unfold minkowski3. Both sides equal a^2 + b^2 - c^2 after expansion. Use ring.
-/

theorem berggren_A_preserves_norm (a b c : ℤ) :
    minkowski3 (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) =
    minkowski3 a b c := by
  unfold minkowski3; ring;

/-
PROVIDED SOLUTION
Unfold minkowski3 and use ring.
-/

theorem berggren_B_preserves_norm (a b c : ℤ) :
    minkowski3 (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) =
    minkowski3 a b c := by
  unfold minkowski3; ring;

/-
PROVIDED SOLUTION
Unfold minkowski3 and use ring.
-/

theorem berggren_C_preserves_norm (a b c : ℤ) :
    minkowski3 (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) =
    minkowski3 a b c := by
  unfold minkowski3; ring;

/-! ## Section 10: The Sum-of-Squares Function and Photon Counting -/

/-
PROBLEM
The number 5 is expressible as a sum of two positive squares

PROVIDED SOLUTION
Use a=1, b=2. 1+4=5. exact ⟨1, 2, by norm_num, by norm_num, by norm_num⟩
-/

theorem seven_not_sum_of_squares : ¬ ∃ a b : ℕ, a ^ 2 + b ^ 2 = 7 := by
  exact fun ⟨ a, b, h ⟩ => by have := Nat.le_of_lt_succ ( show a < 3 by nlinarith ) ; have := Nat.le_of_lt_succ ( show b < 3 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial;

/-
PROBLEM
25 can be written as a sum of two squares in two ways

PROVIDED SOLUTION
Use (3,4) and (4,3): 9+16=25 and 16+9=25. Or use (3,4) and (5,0)... but need positive. Use (a₁,b₁)=(3,4) and (a₂,b₂)=(4,3). exact ⟨3, 4, 4, 3, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩
-/

theorem twentyfive_two_representations :
    ∃ a₁ b₁ a₂ b₂ : ℕ, a₁ ^ 2 + b₁ ^ 2 = 25 ∧ a₂ ^ 2 + b₂ ^ 2 = 25 ∧
    (a₁, b₁) ≠ (a₂, b₂) ∧ 0 < a₁ ∧ 0 < b₁ ∧ 0 < a₂ ∧ 0 < b₂ := by
  exists 3, 4, 4, 3

/-! ## Section 11: Verified Summary

### Theorems in this file:
- Lattice null vector properties (zero Minkowski norm, symmetries, scaling)
- Euclid's parametrization is a lattice null vector
- Berggren tree growth bounds
- Brahmagupta-Fibonacci identity (two forms)
- Pythagorean quadruple parametrization and properties
- Lattice dispersion correction bounds
- Divisibility properties (div by 3, div by 4, odd hypotenuse)
- Smallest primitive triple is (3,4,5)
- Infinitude of triples and quadruples
- Berggren transformations preserve Minkowski norm
- Sum-of-squares representations
-/
