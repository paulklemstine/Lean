import Mathlib

/-! # CatalogBuild.Algebra.DivisionAlgebras.NormHierarchy

Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 37
-/

/-- The second form: (a²+b²)(c²+d²) = (ac+bd)²+(ad-bc)²
Obtained by using z₁z̄₂ instead of z₁z₂, or equivalently by
replacing d with -d in the first form. The existence of two forms
is what creates collisions and enables factoring. -/
theorem brahmagupta_fibonacci_identity' (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c + b*d)^2 + (a*d - b*c)^2 := by
  ring




/-- The two forms of the Brahmagupta-Fibonacci identity produce
equal values — they are two different representations of the
same product on the factoring circle. -/
theorem two_composition_equality (a b c d : ℤ) :
    (a*c - b*d)^2 + (a*d + b*c)^2 = (a*c + b*d)^2 + (a*d - b*c)^2 := by
  ring




/-- Degen's eight-square identity (1818): the product of two sums of
eight squares is itself a sum of eight squares.
This is the norm-multiplicativity of the octonions: |x₁|²|x₂|² = |x₁x₂|².
The octonions are the last normed division algebra (dimension 8).
They are non-associative but alternative. -/
theorem degen_eight_square_identity
    (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2) *
    (b₁^2 + b₂^2 + b₃^2 + b₄^2 + b₅^2 + b₆^2 + b₇^2 + b₈^2) =
      (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄ - a₅*b₅ - a₆*b₆ - a₇*b₇ - a₈*b₈)^2 +
      (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃ + a₅*b₆ - a₆*b₅ - a₇*b₈ + a₈*b₇)^2 +
      (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂ + a₅*b₇ + a₆*b₈ - a₇*b₅ - a₈*b₆)^2 +
      (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁ + a₅*b₈ - a₆*b₇ + a₇*b₆ - a₈*b₅)^2 +
      (a₁*b₅ - a₂*b₆ - a₃*b₇ - a₄*b₈ + a₅*b₁ + a₆*b₂ + a₇*b₃ + a₈*b₄)^2 +
      (a₁*b₆ + a₂*b₅ - a₃*b₈ + a₄*b₇ - a₅*b₂ + a₆*b₁ - a₇*b₄ + a₈*b₃)^2 +
      (a₁*b₇ + a₂*b₈ + a₃*b₅ - a₄*b₆ - a₅*b₃ + a₆*b₄ + a₇*b₁ - a₈*b₂)^2 +
      (a₁*b₈ - a₂*b₇ + a₃*b₆ + a₄*b₅ - a₅*b₄ - a₆*b₃ + a₇*b₂ + a₈*b₁)^2 := by
  ring




/-- The collision-norm identity (the mathematical heart of collision-based factoring):
If a²+b² = N and c²+d² = N, then (ad-bc)²+(ac+bd)² = N².
Proof: by the Brahmagupta-Fibonacci identity applied to N·N. -/
theorem collision_norm_identity (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    (a*d - b*c)^2 + (a*c + b*d)^2 = N^2 := by
  have := brahmagupta_fibonacci_identity' a b c d
  rw [h1, h2] at this
  linarith




/-- The collision product identity: from two representations a²+b² = c²+d²,
we get (a-c)(a+c) = (d-b)(d+b). -/
theorem collision_product_identity (a b c d : ℤ)
    (h : a^2 + b^2 = c^2 + d^2) :
    (a - c) * (a + c) = (d - b) * (d + b) := by
  nlinarith [sq_abs (a - c), sq_abs (d - b)]




/-- The cross-term ad-bc is bounded: (ad-bc)² ≤ N². -/
theorem cross_term_sq_le_N_sq (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    (a*d - b*c)^2 ≤ N^2 := by
  have := collision_norm_identity a b c d N h1 h2
  nlinarith [sq_nonneg (a*c + b*d)]




/-- The symmetric cross-term ac+bd is also bounded: (ac+bd)² ≤ N². -/
theorem symmetric_cross_term_bound (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    (a*c + b*d)^2 ≤ N^2 := by
  have := collision_norm_identity a b c d N h1 h2
  nlinarith [sq_nonneg (a*d - b*c)]




/-- GCD cascade: gcd(ad-bc, N) always divides N.
The interesting case is when 1 < gcd(ad-bc, N) < N. -/
theorem collision_gcd_divides (a b c d N : ℤ)
    (_h1 : a^2 + b^2 = N) (_h2 : c^2 + d^2 = N) :
    (Int.gcd (a*d - b*c) N : ℤ) ∣ N :=
  Int.gcd_dvd_right (a*d - b*c) N




/-- GCD cascade for the symmetric cross-term: gcd(ac+bd, N) also divides N. -/
theorem symmetric_gcd_divides (a b c d N : ℤ)
    (_h1 : a^2 + b^2 = N) (_h2 : c^2 + d^2 = N) :
    (Int.gcd (a*c + b*d) N : ℤ) ∣ N :=
  Int.gcd_dvd_right (a*c + b*d) N




/-- If gcd(ad-bc, N) is nontrivial (i.e., 1 < g < N), then g is
a proper divisor of N, witnessing that N is composite. -/
theorem collision_factoring_complete {g N : ℕ} (hg1 : 1 < g) (hgN : g < N)
    (hdvd : g ∣ N) : ¬ Nat.Prime N := by
  intro hp
  exact (Nat.Prime.eq_one_or_self_of_dvd hp g hdvd).elim
    (fun h => by omega) (fun h => by omega)




/-- Four-dimensional collision-norm identity: if two quaternion norms equal N,
then the Euler identity gives a representation of N² as a sum of 4 squares. -/
theorem collision_norm_dim4 (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ N : ℤ)
    (h1 : a₁^2 + a₂^2 + a₃^2 + a₄^2 = N)
    (h2 : b₁^2 + b₂^2 + b₃^2 + b₄^2 = N) :
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 = N^2 := by
  have := euler_four_square_identity a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄
  rw [h1, h2] at this
  linarith




/-- Key algebraic identity for the GCD mechanism:
If a² + b² = N and c² + d² = N, then
(ad-bc)(ad+bc) = N(a+c)(a-c).
This shows that N divides the product of cross-terms, which is why
gcd(ad-bc, N) is often a nontrivial factor. -/
theorem gcd_mechanism_identity (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    (a*d - b*c) * (a*d + b*c) = N * (a + c) * (a - c) := by
  have hab : b^2 = N - a^2 := by linarith
  have hcd : d^2 = N - c^2 := by linarith
  nlinarith [sq_nonneg (a*d), sq_nonneg (b*c)]




/-- The symmetric version:
(ac+bd)(ac-bd) = N(c+b)(c-b). -/
theorem gcd_mechanism_identity_symmetric (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    (a*c + b*d) * (a*c - b*d) = N * (c + b) * (c - b) := by
  have hab : b^2 = N - a^2 := by linarith
  have hcd : d^2 = N - c^2 := by linarith
  nlinarith [sq_nonneg (a*c), sq_nonneg (b*d)]




/-- From the GCD mechanism identity, N divides (ad-bc)(ad+bc). -/
theorem N_divides_cross_product (a b c d N : ℤ)
    (h1 : a^2 + b^2 = N) (h2 : c^2 + d^2 = N) :
    N ∣ (a*d - b*c) * (a*d + b*c) := by
  have : (a*d - b*c) * (a*d + b*c) = N * ((a + c) * (a - c)) := by
    have hab : b^2 = N - a^2 := by linarith
    have hcd : d^2 = N - c^2 := by linarith
    nlinarith [sq_nonneg (a*d), sq_nonneg (b*c)]
  rw [this]
  exact dvd_mul_right N _




/-- If a natural number divides both the cross-term and N,
it divides their GCD. This is how shared prime factors are detected. -/
theorem shared_factor_divides_gcd (cross N : ℤ) (d : ℕ)
    (hc : (d : ℤ) ∣ cross) (hN : (d : ℤ) ∣ N) :
    d ∣ Int.gcd cross N :=
  Int.dvd_gcd hc hN




/-- Lagrange's four-square theorem (1770): every natural number can be
represented as a sum of four squares. This ensures the dimension-4
factoring framework works for ALL integers. -/
theorem four_square_representation_exists (n : ℕ) :
    ∃ a b c d : ℕ, a^2 + b^2 + c^2 + d^2 = n :=
  Nat.sum_four_squares n




/-- Fermat's theorem on sums of two squares (1640, proved by Euler 1749):
A prime p with p % 4 ≠ 3 can be written as a sum of two squares. -/
theorem prime_two_square_representation (p : ℕ) [Fact (Nat.Prime p)] (hp : p % 4 ≠ 3) :
    ∃ a b : ℕ, a^2 + b^2 = p :=
  Nat.Prime.sq_add_sq hp




/-- If N = (a²+b²)(c²+d²), then the BF identity constructively produces
two representations of N as a sum of two squares. -/
theorem collision_guaranteed_dim2 (a b c d : ℤ) :
    let N := (a^2 + b^2) * (c^2 + d^2)
    N = (a*c - b*d)^2 + (a*d + b*c)^2 ∧
    N = (a*c + b*d)^2 + (a*d - b*c)^2 := by
  constructor
  · exact brahmagupta_fibonacci_identity a b c d
  · exact brahmagupta_fibonacci_identity' a b c d




/-- The two representations from `collision_guaranteed_dim2` are distinct
when bd ≠ 0 (i.e., the representations of the factors are non-degenerate).
The first components differ: (ac - bd) ≠ (ac + bd) when bd ≠ 0. -/
theorem collision_reps_distinct (a b c d : ℤ) (h : b * d ≠ 0) :
    (a*c - b*d, a*d + b*c) ≠ (a*c + b*d, a*d - b*c) := by
  intro heq
  have h1 := congr_arg Prod.fst heq
  simp at h1
  exact h (by linarith)




/-- Eight-square representations exist for every natural number:
this follows trivially from the four-square theorem by setting
the last four components to zero. -/
theorem eight_square_representation_exists (n : ℕ) :
    ∃ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ : ℕ,
      a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2 = n := by
  obtain ⟨a, b, c, d, h⟩ := Nat.sum_four_squares n
  exact ⟨a, b, c, d, 0, 0, 0, 0, by simp [h]⟩




/-- The peel identity in dimension 2: for a²+b² = N,
(N-a)(N+a) = b² + N(N-1). -/
theorem peel_identity_dim2 (a b N : ℤ) (h : a^2 + b^2 = N) :
    (N - a) * (N + a) = b^2 + N * (N - 1) := by
  nlinarith




/-- The peel identity in dimension 4. -/
theorem peel_identity_dim4 (a b c d N : ℤ) (h : a^2 + b^2 + c^2 + d^2 = N) :
    (N - a) * (N + a) = b^2 + c^2 + d^2 + N * (N - 1) := by
  nlinarith




/-- The peel identity in dimension 8. -/
theorem peel_identity_dim8 (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ N : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2 = N) :
    (N - a₁) * (N + a₁) =
      a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2 + N * (N - 1) := by
  nlinarith




/-- Cross-collision count in dimension 4: C(4,2) = 6. -/
theorem cross_collision_count_dim4 : Nat.choose 4 2 = 6 := by decide




/-- Cross-collision count in dimension 8: C(8,2) = 28. -/
theorem cross_collision_count_dim8 : Nat.choose 8 2 = 28 := by decide




/-- General cross-collision count bound. -/
theorem cross_collision_count (k m : ℕ) (_hk : 1 ≤ k) (hm : 2 ≤ m) :
    k * (m.choose 2) ≥ k := by
  suffices h : m.choose 2 ≥ 1 by
    calc k * m.choose 2 ≥ k * 1 := by exact Nat.mul_le_mul_left k h
         _ = k := Nat.mul_one k
  rw [Nat.choose_two_right]
  have hm1 : 1 ≤ m - 1 := by omega
  have hm2 : 2 ≤ m * (m - 1) := by
    calc m * (m - 1) ≥ 2 * 1 := Nat.mul_le_mul hm hm1
    _ = 2 := by ring
  omega




/-- In a Pythagorean triple with positive legs and hypotenuse, the hypotenuse
exceeds each leg. This ensures Pythagorean descent terminates. -/
theorem hypotenuse_gt_leg {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c)
    (h : a^2 + b^2 = c^2) : c > a ∧ c > b := by
  constructor
  · nlinarith [sq_nonneg b]
  · nlinarith [sq_nonneg a]




/-- A natural number with a nontrivial divisor is composite. -/
theorem nontrivial_divisor_composite {N d : ℕ} (_hN : 1 < N) (hd1 : 1 < d)
    (hd2 : d < N) (hdvd : d ∣ N) : ¬ Nat.Prime N := by
  intro hp
  exact Nat.Prime.eq_one_or_self_of_dvd hp d hdvd |>.elim
    (fun h => by omega) (fun h => by omega)




/-- The Gaussian integer norm is multiplicative: |z₁z₂|² = |z₁|²·|z₂|². -/
theorem gaussian_integer_norm_multiplicative (a b c d : ℤ) :
    (a*c - b*d)^2 + (a*d + b*c)^2 = (a^2 + b^2) * (c^2 + d^2) := by
  ring




/-- The two product forms give the same norm. -/
theorem gaussian_norm_both_forms (a b c d : ℤ) :
    (a*c - b*d)^2 + (a*d + b*c)^2 = (a*c + b*d)^2 + (a*d - b*c)^2 := by
  ring




/-- Dimension 2: 1 + 4 = 5 total channels. -/
theorem dim2_total_channels : Nat.choose 2 2 + 2 * 2 = 5 := by decide




/-- Dimension 4: 6 + 8 = 14 total channels. -/
theorem dim4_total_channels : Nat.choose 4 2 + 2 * 4 = 14 := by decide




/-- Dimension 8: 28 + 16 = 44 total channels. -/
theorem dim8_total_channels : Nat.choose 8 2 + 2 * 8 = 44 := by decide




/-- The 112 integer-type roots: C(8,2) ways to choose 2 coordinates,
2² sign choices, giving 4 · 28 = 112. -/
theorem e8_integer_roots : 4 * Nat.choose 8 2 = 112 := by decide




/-- The Weyl group of E₈ has order 696,729,600 = 2¹⁴ · 3⁵ · 5² · 7. -/
theorem e8_weyl_group_order_factored :
    696729600 = 2^14 * 3^5 * 5^2 * 7 := by decide




/-- Quaternion conjugation: N(q) = q·q̄ = a₁²+a₂²+a₃²+a₄². -/
theorem quaternion_norm_from_conjugate (a₁ a₂ a₃ a₄ : ℤ) :
    (a₁*a₁ - a₂*(-a₂) - a₃*(-a₃) - a₄*(-a₄)) = a₁^2 + a₂^2 + a₃^2 + a₄^2 := by
  ring




/-- The quaternion cross-product norm: if q₁, q₂ both have norm N,
then q₁·q̄₂ has norm N², and its components provide factoring data. -/
theorem quaternion_cross_product_norm (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ N : ℤ)
    (h1 : a₁^2 + a₂^2 + a₃^2 + a₄^2 = N)
    (h2 : b₁^2 + b₂^2 + b₃^2 + b₄^2 = N) :
    (a₁*b₁ + a₂*b₂ + a₃*b₃ + a₄*b₄)^2 +
    (a₁*b₂ - a₂*b₁ - a₃*b₄ + a₄*b₃)^2 +
    (a₁*b₃ + a₂*b₄ - a₃*b₁ - a₄*b₂)^2 +
    (a₁*b₄ - a₂*b₃ + a₃*b₂ - a₄*b₁)^2 = N^2 := by
  have := euler_four_square_identity a₁ a₂ a₃ a₄ b₁ (-b₂) (-b₃) (-b₄)
  simp only [mul_neg, sub_neg_eq_add] at this
  rw [h1] at this
  have hb : b₁^2 + (-b₂)^2 + (-b₃)^2 + (-b₄)^2 = N := by ring_nf; linarith
  rw [hb] at this
  linarith



