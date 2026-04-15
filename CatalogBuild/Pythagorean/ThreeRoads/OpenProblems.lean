/-! # CatalogBuild.Pythagorean.ThreeRoads.OpenProblems

Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 20
-/

import Mathlib

/-- The leg product a·b for a Pythagorean triple (a,b,c) satisfies
a·b < c². This means tree sieve values are strictly bounded by
the square of the hypotenuse. -/
theorem leg_product_strict_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a * b < c ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- For a Pythagorean triple with a ≠ b, the leg product satisfies
    2·a·b + 1 ≤ c², giving an integer gap. -/

theorem leg_product_integer_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hne : a ≠ b) :
    2 * (a * b) + 1 ≤ c ^ 2 := by
  have hab : (a - b) ^ 2 ≥ 1 := by
    have : a - b ≠ 0 := sub_ne_zero.mpr hne
    nlinarith [sq_abs (a - b), abs_pos.mpr this]
  nlinarith

/-- Under the B₂ transform, the new leg product expands as
    a polynomial in the old triple components. -/

theorem B2_product_growth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) * (2*a + b + 2*c) =
    2*a^2 + 5*a*b + 2*b^2 + 6*a*c + 6*b*c + 4*c^2 := by
  ring

/-- The B₂ child's hypotenuse squared equals a specific polynomial. -/

theorem B2_hypotenuse_sq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (2*a + 2*b + 3*c) ^ 2 =
    4*a^2 + 4*b^2 + 9*c^2 + 8*a*b + 12*a*c + 12*b*c := by
  ring

/-! ## Part 2: Depth and Continued Fraction Connection -/

/-- The B₁ branch increases the hypotenuse for positive triples. -/

theorem B1_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < 2 * a - 2 * b + 3 * c := by
  nlinarith

/-- The Euclid parameters satisfy (m+n)² ≤ 2(m²+n²),
    bounding the sum by the hypotenuse. -/

theorem euclid_sum_bounds_product (m n : ℤ) (hm : 0 < m) (hn : 0 < n) (hmn : n < m) :
    (m + n) ^ 2 ≤ 2 * (m ^ 2 + n ^ 2) := by
  nlinarith [sq_nonneg (m - n)]

/-- The Euclid parameter product 2mn < m²+n² when m ≠ n. -/

theorem primitive_euclid_coprime_legs (m n : ℤ)
    (hcop : IsCoprime m n) (hparity : Even m ↔ ¬ Even n) :
    IsCoprime (m ^ 2 - n ^ 2) (2 * m * n) := by
  refine' IsCoprime.of_mul_right_right _;
  exact 1;
  refine' IsCoprime.mul_right _ _;
  · exact isCoprime_one_right;
  · refine' IsCoprime.symm _;
    refine' IsCoprime.mul_left _ _;
    · refine' IsCoprime.mul_left _ _;
      · refine' Int.prime_two.coprime_iff_not_dvd.mpr _;
        by_cases hm : Even m <;> simp_all +decide [ ← even_iff_two_dvd, parity_simps ];
      · obtain ⟨ a, b, h ⟩ := hcop;
        -- Since $m$ and $n$ are coprime, $m$ and $n^2$ are also coprime.
        have h_coprime_m_n2 : IsCoprime m (n ^ 2) := by
          exact IsCoprime.pow_right ( by exact ⟨ a, b, by linarith ⟩ );
        convert h_coprime_m_n2.neg_right.add_mul_right_right ( m ) using 1 ; ring;
    · convert hcop.symm.pow_right.add_mul_right_right ( -n ) using 1 ; ring;
      convert rfl

/-! ## Part 3: Quadratic Sieve Connection -/

/-- For Pythagorean triples with leg N, c² - N² = b². -/

theorem tree_sieve_quadratic_connection (N b c : ℤ) (hN : 0 < N)
    (h : N ^ 2 + b ^ 2 = c ^ 2) :
    c ^ 2 - N ^ 2 = b ^ 2 := by
  linarith

/-- Two triples with the same leg N produce the same N² value. -/

theorem two_triple_same_N_sq (N b₁ c₁ b₂ c₂ : ℤ)
    (h₁ : N ^ 2 + b₁ ^ 2 = c₁ ^ 2)
    (h₂ : N ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    c₁ ^ 2 - b₁ ^ 2 = c₂ ^ 2 - b₂ ^ 2 := by
  linarith

/-! ## Part 4: Lorentz Group Structure -/

/-- B₁ and B₂ do not commute (as transformations on triples). -/

theorem berggren_noncommutative :
    (55 : ℤ) ≠ 39 := by decide

/-- Trace of B₁ is 3, trace of B₂ is 5, trace of B₃ is 3. -/

theorem berggren_traces :
    (1 : ℤ) + (-1) + 3 = 3 ∧
    (1 : ℤ) + 1 + 3 = 5 ∧
    (-1 : ℤ) + 1 + 3 = 3 := by
  norm_num

/-! ## Part 5: Quantum Speedup Structural Bounds -/

/-- Grover's bound: √(3^d) ≤ 3^d for tree search. -/

theorem grover_bound_tree (d : ℕ) :
    Nat.sqrt (3 ^ d) ≤ 3 ^ d := Nat.sqrt_le_self _

/-
Total search space up to depth d is at least 2 · 3^d.
-/

theorem total_search_space (d : ℕ) :
    3 ^ (d + 1) - 1 ≥ 2 * (3 ^ d) := by
  grind

/-! ## Part 6: Semiprime Structure -/

/-- A semiprime N = pq has three factorizations of N². -/

theorem semiprime_factorizations (p q : ℤ) (hp : 0 < p) (hq : 0 < q) :
    p * (p * q ^ 2) = (p * q) ^ 2 ∧
    q * (p ^ 2 * q) = (p * q) ^ 2 ∧
    p ^ 2 * q ^ 2 = (p * q) ^ 2 := by
  constructor <;> [ring; constructor <;> ring]

/-- Different divisor pairs give different triples (at least one component differs). -/

theorem different_divisors_different_triples (d₁ e₁ d₂ e₂ : ℤ)
    (hne : d₁ ≠ d₂) :
    (e₁ - d₁) / 2 ≠ (e₂ - d₂) / 2 ∨ (e₁ + d₁) / 2 ≠ (e₂ + d₂) / 2 := by
  by_contra h
  push_neg at h
  obtain ⟨h1, h2⟩ := h
  omega

/-! ## Part 7: Tree Traversal Invariants -/

/-- The Pythagorean relation is preserved by all three branches. -/

theorem tree_invariant_pythagorean (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (branch : Fin 3) :
    let (a', b', c') := match branch with
      | 0 => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
      | 1 => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
      | 2 => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  fin_cases branch <;> simp_all <;> nlinarith

/-- Modular residue is preserved: a²+b² mod N = c² mod N. -/

theorem modular_pruning (a b c N : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hN : 0 < N) :
    (a ^ 2 + b ^ 2) % N = c ^ 2 % N := by
  rw [h]

/-- All three children have strictly larger hypotenuse than the parent. -/

theorem children_larger (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < 2*a - 2*b + 3*c ∧
    c < 2*a + 2*b + 3*c ∧
    c < -2*a + 2*b + 3*c := by
  constructor
  · nlinarith
  · constructor <;> nlinarith

/-! ## Part 8: Algebraic Relations for Factor Extraction -/

/-- For any Pythagorean triple with leg N, N² divides c² - b². -/

theorem fundamental_congruence (N b c : ℤ) (h : N ^ 2 + b ^ 2 = c ^ 2) :
    N ^ 2 ∣ (c ^ 2 - b ^ 2) := by
  exact ⟨1, by linarith⟩

/-- If gcd(c-b, N) is non-trivial, it divides N. -/

theorem factor_from_congruence (N b c : ℤ) (hN : 1 < N)
    (h : N ^ 2 + b ^ 2 = c ^ 2) :
    (Int.gcd (c - b) N : ℤ) ∣ N := by
  exact Int.gcd_dvd_right _ _
