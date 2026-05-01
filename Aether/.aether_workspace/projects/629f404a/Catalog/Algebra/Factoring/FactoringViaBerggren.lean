import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.FactoringViaBerggren

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 35
-/

/-- The universal parent inverse. -/
def UP (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (|gp a b c|, |gq a b c|, gh a b c)

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Fundamental Ghost Identities
-- ═══════════════════════════════════════════════════════════════

/-- The ghost difference p - q always equals b - a. -/
theorem ghost_diff_eq_ba_diff (a b c : ℤ) :
    gp a b c - gq a b c = b - a := by
  simp only [gp, gq]; ring

/-- The ghost sum p + q = 3(a + b) - 4c. -/
theorem ghost_sum (a b c : ℤ) :
    gp a b c + gq a b c = 3 * (a + b) - 4 * c := by
  simp only [gp, gq]; ring

/-- **Lorentz Norm Preservation**: p² + q² - h² = a² + b² - c² (always). -/
theorem lorentz_norm_preservation (a b c : ℤ) :
    (gp a b c) ^ 2 + (gq a b c) ^ 2 - (gh a b c) ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [gp, gq, gh]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Split Triplet Fixed Point Theorem
-- ═══════════════════════════════════════════════════════════════

/-- Ghost p-parameter of the split triplet (N-x, x, N). -/
theorem split_gp (x N : ℤ) :
    gp (N - x) x N = x - N := by
  simp only [gp]; ring

/-- Ghost q-parameter of the split triplet (N-x, x, N). -/
theorem split_gq (x N : ℤ) :
    gq (N - x) x N = -x := by
  simp only [gq]; ring

/-- Ghost h-parameter of the split triplet (N-x, x, N). -/
theorem split_gh (x N : ℤ) :
    gh (N - x) x N = N := by
  simp only [gh]; ring

/-- **Split Triplet Fixed Point Theorem**: UP(N-x, x, N) = (N-x, x, N) for 0 < x < N. -/
theorem split_triplet_fixed_point (x N : ℤ) (hx : 0 < x) (hxN : x < N) :
    UP (N - x) x N = (N - x, x, N) := by
  simp only [UP, split_gp, split_gq, split_gh]
  congr 1
  · rw [abs_of_nonpos (by linarith : x - N ≤ 0)]; ring
  · congr 1
    rw [abs_of_nonpos (by linarith : -x ≤ 0)]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Divisor Triplet and Factor Gap
-- ═══════════════════════════════════════════════════════════════

/-- **Divisor Gap Theorem**: For divisor triplet (d, e, d*e), p - q = e - d. -/
theorem divisor_gap_theorem (d e : ℤ) :
    gp d e (d * e) - gq d e (d * e) = e - d := by
  simp only [gp, gq]; ring

/-- For balanced factors (d = e), the ghost triple is isoceles (p = q). -/
theorem divisor_gap_zero_iff_equal (d e : ℤ) :
    gp d e (d * e) = gq d e (d * e) ↔ d = e := by
  simp only [gp, gq]
  constructor
  · intro h; linarith
  · intro h; subst h; ring

/-- |p - q| of the divisor triplet equals |e - d|. -/
theorem abs_divisor_gap (d e : ℤ) :
    |gp d e (d * e) - gq d e (d * e)| = |e - d| := by
  rw [divisor_gap_theorem]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Factoring Triplet T(x) = (x, N, x² + N²)
-- ═══════════════════════════════════════════════════════════════

/-- Ghost p of factoring triplet (x, N, x² + N²). -/
theorem factoring_gp (x N : ℤ) :
    gp x N (x ^ 2 + N ^ 2) = x + 2 * N - 2 * x ^ 2 - 2 * N ^ 2 := by
  simp only [gp]; ring

/-- Ghost q of factoring triplet (x, N, x² + N²). -/
theorem factoring_gq (x N : ℤ) :
    gq x N (x ^ 2 + N ^ 2) = 2 * x + N - 2 * x ^ 2 - 2 * N ^ 2 := by
  simp only [gq]; ring

/-- Ghost h of factoring triplet (x, N, x² + N²). -/
theorem factoring_gh (x N : ℤ) :
    gh x N (x ^ 2 + N ^ 2) = 3 * x ^ 2 + 3 * N ^ 2 - 2 * x - 2 * N := by
  simp only [gh]; ring

/-- The factoring triplet ghost difference p - q = N - x. -/
theorem factoring_ghost_diff (x N : ℤ) :
    gp x N (x ^ 2 + N ^ 2) - gq x N (x ^ 2 + N ^ 2) = N - x := by
  simp only [gp, gq]; ring

/-- **Factoring Deficit Formula**: The Pythagorean deficit of (x, N, x² + N²). -/
theorem factoring_deficit_formula (x N : ℤ) :
    x ^ 2 + N ^ 2 - (x ^ 2 + N ^ 2) ^ 2 =
    -(x ^ 2 + N ^ 2) * (x ^ 2 + N ^ 2 - 1) := by ring

/-- The deficit is always non-positive for nontrivial inputs. -/
theorem factoring_deficit_nonpos (x N : ℤ) (h : x ^ 2 + N ^ 2 ≥ 1) :
    x ^ 2 + N ^ 2 - (x ^ 2 + N ^ 2) ^ 2 ≤ 0 := by nlinarith

/-- Ghost deficit equals the original deficit (Lorentz preservation). -/
theorem factoring_ghost_deficit (x N : ℤ) :
    (gp x N (x ^ 2 + N ^ 2)) ^ 2 + (gq x N (x ^ 2 + N ^ 2)) ^ 2 -
    (gh x N (x ^ 2 + N ^ 2)) ^ 2 =
    x ^ 2 + N ^ 2 - (x ^ 2 + N ^ 2) ^ 2 := by
  have := lorentz_norm_preservation x N (x ^ 2 + N ^ 2)
  linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Split Triplet Lorentz Norm
-- ═══════════════════════════════════════════════════════════════

/-- The Lorentz norm of the split triplet (N-x, x, N) is -2x(N-x). -/
theorem split_lorentz (x N : ℤ) :
    (N - x) ^ 2 + x ^ 2 - N ^ 2 = -2 * x * (N - x) := by ring

-- ═══════════════════════════════════════════════════════════════
-- Section 7: GCD-Based Factor Detection
-- ═══════════════════════════════════════════════════════════════

/-- When d | x and d | N, then d | gp(x, N, x² + N²). -/
theorem factor_propagation_p (x N d : ℤ) (hx : d ∣ x) (hN : d ∣ N) :
    d ∣ gp x N (x ^ 2 + N ^ 2) := by
  obtain ⟨a, rfl⟩ := hx
  obtain ⟨b, rfl⟩ := hN
  simp only [gp]
  exact ⟨a + 2 * b - 2 * d * a ^ 2 - 2 * d * b ^ 2, by ring⟩

/-- When d | x and d | N, then d | gq(x, N, x² + N²). -/
theorem factor_propagation_q (x N d : ℤ) (hx : d ∣ x) (hN : d ∣ N) :
    d ∣ gq x N (x ^ 2 + N ^ 2) := by
  obtain ⟨a, rfl⟩ := hx
  obtain ⟨b, rfl⟩ := hN
  simp only [gq]
  exact ⟨2 * a + b - 2 * d * a ^ 2 - 2 * d * b ^ 2, by ring⟩

/-- When d | x and d | N, then d | gh(x, N, x² + N²). -/
theorem factor_propagation_h (x N d : ℤ) (hx : d ∣ x) (hN : d ∣ N) :
    d ∣ gh x N (x ^ 2 + N ^ 2) := by
  obtain ⟨a, rfl⟩ := hx
  obtain ⟨b, rfl⟩ := hN
  simp only [gh]
  exact ⟨3 * d * a ^ 2 + 3 * d * b ^ 2 - 2 * a - 2 * b, by ring⟩

/-- **Factor Preservation Theorem**: If d | x and d | N,
then d divides all three ghost parameters of T(x) = (x, N, x²+N²). -/
theorem factor_preservation (x N d : ℤ) (hx : d ∣ x) (hN : d ∣ N) :
    d ∣ gp x N (x ^ 2 + N ^ 2) ∧
    d ∣ gq x N (x ^ 2 + N ^ 2) ∧
    d ∣ gh x N (x ^ 2 + N ^ 2) :=
  ⟨factor_propagation_p x N d hx hN,
   factor_propagation_q x N d hx hN,
   factor_propagation_h x N d hx hN⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Ghost Parameters Modular Arithmetic
-- ═══════════════════════════════════════════════════════════════

/-- Ghost p preserves parity: p ≡ a (mod 2). -/
theorem ghost_p_parity (a b c : ℤ) :
    gp a b c % 2 = a % 2 := by
  simp only [gp]; omega

/-- Ghost q preserves parity: q ≡ b (mod 2). -/
theorem ghost_q_parity (a b c : ℤ) :
    gq a b c % 2 = b % 2 := by
  simp only [gq]; omega

/-- Ghost h preserves parity: h ≡ c (mod 2). -/
theorem ghost_h_parity (a b c : ℤ) :
    gh a b c % 2 = c % 2 := by
  simp only [gh]; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Leg Swap and Factoring
-- ═══════════════════════════════════════════════════════════════

/-- Leg swap interchanges p and q: p(b,a,c) = q(a,b,c). -/
theorem leg_swap_pq (a b c : ℤ) :
    gp b a c = gq a b c := by
  simp only [gp, gq]; ring

/-- h is symmetric under leg swap. -/
theorem leg_swap_h (a b c : ℤ) :
    gh b a c = gh a b c := by
  simp only [gh]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Divisor Triplet Lorentz Norm
-- ═══════════════════════════════════════════════════════════════

/-- For the divisor triplet (d, e, d*e), the Lorentz deficit is
d² + e² - d²e² = -((d²-1)(e²-1) - 1). -/
theorem divisor_lorentz_factored (d e : ℤ) :
    d ^ 2 + e ^ 2 - (d * e) ^ 2 = -((d ^ 2 - 1) * (e ^ 2 - 1)) + 1 := by ring

/-- The divisor triplet deficit vanishes iff (d²-1)(e²-1) = 1. -/
theorem divisor_pythagorean_iff (d e : ℤ) :
    d ^ 2 + e ^ 2 = (d * e) ^ 2 ↔ (d ^ 2 - 1) * (e ^ 2 - 1) = 1 := by
  constructor <;> intro h <;> nlinarith

/-- [Section: # Factoring via Berggren Universal Parent
## Overview
We explore using the Universal Parent formula from the Berggren tree to extract
factoring information about a composite integer N. Several "factoring triplet"
constructions are analyzed:
1. **Factoring triplet** T(x) = (x, N, x² + N²)
2. **Split triplet** T₃(x) = (N - x, x, N): A fixed point of the Universal Parent.
3. **Divisor triplet** T₂(d) = (d, N/d, N): Encodes the factor gap in |p - q|.
## Key Theorems
- `split_triplet_fixed_point`: UP(N-x, x, N) = (N-x, x, N) for 0 < x < N.
- `divisor_gap_theorem`: For (d, e, d*e), p - q = e - d.
- `factoring_deficit_formula`: δ(x, N, x²+N²) = -(x²+N²)(x²+N²-1).
- `lorentz_norm_preservation`: p² + q² - h² = a² + b² - c² (always).
- `factor_preservation`: If d | x and d | N, then d divides all ghost parameters.] -/
theorem divisor_pythagorean_only_trivial (d e : ℤ) (hd : 0 < d) (he : 0 < e)
    (h : (d ^ 2 - 1) * (e ^ 2 - 1) = 1) :
    d = 1 ∧ e = 1 := by
  rcases Int.eq_one_or_neg_one_of_mul_eq_one h with ( h | h ) <;> constructor <;> nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 11: The h-Descent Obstruction
-- ═══════════════════════════════════════════════════════════════

/-- For the factoring triplet, h ≥ x² + N² when x ≥ 1 and N ≥ 2. -/
theorem factoring_h_large (x N : ℤ) (hx : 1 ≤ x) (hN : 2 ≤ N) :
    x ^ 2 + N ^ 2 ≤ gh x N (x ^ 2 + N ^ 2) := by
  simp only [gh]
  nlinarith [sq_nonneg x, sq_nonneg N, sq_nonneg (x - 1), sq_nonneg (N - 1)]

/-- The factoring triplet h can be written as 3(x²+N²) - 2(x+N). -/
theorem factoring_h_growth (x N : ℤ) :
    gh x N (x ^ 2 + N ^ 2) = 3 * (x ^ 2 + N ^ 2) - 2 * (x + N) := by
  simp only [gh]

-- ═══════════════════════════════════════════════════════════════
-- Section 12: The (3,4,5) Reverse-Solve Equations
-- ═══════════════════════════════════════════════════════════════

/-- Setting h = 5 for factoring triplet gives quadratic constraint. -/
theorem reverse_solve_h_eq_5 (x N : ℤ)
    (hh : gh x N (x ^ 2 + N ^ 2) = 5) :
    3 * x ^ 2 + 3 * N ^ 2 - 2 * x - 2 * N = 5 := by
  simp only [gh] at hh; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Split Factor GCD
-- ═══════════════════════════════════════════════════════════════

/-- If d | N, then d | gp(N-d, d, N) and d | gq(N-d, d, N). -/
theorem split_factor_gcd (d N : ℤ) (hd : d ∣ N) :
    d ∣ gp (N - d) d N ∧ d ∣ gq (N - d) d N := by
  rw [split_gp, split_gq]
  obtain ⟨k, rfl⟩ := hd
  exact ⟨⟨-(k - 1), by ring⟩, ⟨-1, by ring⟩⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Concrete Verifications
-- ═══════════════════════════════════════════════════════════════