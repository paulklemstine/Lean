/-! # CatalogBuild.Computation.Factoring.GaussianBridge

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 16
-/

import Mathlib

/-- The Brahmagupta-Fibonacci Identity over ℤ.
This is the norm multiplicativity of Gaussian integers:
N((a+bi)(c+di)) = N(a+bi) · N(c+di). -/
theorem brahmagupta_fibonacci_Z (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring




/-- Brahmagupta-Fibonacci over ℕ (for computational use). -/
theorem brahmagupta_fibonacci_N (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Sum-of-Two-Squares Closure
-- ═══════════════════════════════════════════════════════════════




/-- The set of integers representable as sums of two squares
is closed under multiplication. -/
theorem sum_two_squares_mul (m n : ℤ)
    (hm : ∃ a b : ℤ, m = a ^ 2 + b ^ 2)
    (hn : ∃ c d : ℤ, n = c ^ 2 + d ^ 2) :
    ∃ x y : ℤ, m * n = x ^ 2 + y ^ 2 := by
  obtain ⟨a, b, rfl⟩ := hm
  obtain ⟨c, d, rfl⟩ := hn
  exact ⟨a * c - b * d, a * d + b * c, by ring⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Pythagorean Triple Composition
-- ═══════════════════════════════════════════════════════════════




/-- If (a₁,b₁,c₁) and (a₂,b₂,c₂) are Pythagorean triples,
then the Gaussian composition gives a new Pythagorean triple
with hypotenuse c₁·c₂. -/
theorem pythagorean_composition (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 = (c₁ * c₂) ^ 2 := by
  nlinarith [brahmagupta_fibonacci_Z a₁ b₁ a₂ b₂]

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Euler's Factoring Method
-- ═══════════════════════════════════════════════════════════════




/-- Euler's factoring lemma (1749): If N has two distinct representations
as a sum of two squares, N = a²+b² = c²+d², then N has a non-trivial
factor given by gcd(a²-c², N) when it's between 1 and N.
The identity: a²+b² = c²+d² implies a²-c² = d²-b²,
so (a-c)(a+c) = (d-b)(d+b). -/
theorem euler_two_squares_factor (N a b c d : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N)
    (h2 : c ^ 2 + d ^ 2 = N) :
    (a - c) * (a + c) = (d - b) * (d + b) := by linarith




/-- The key algebraic identity behind Euler's method. -/
theorem euler_factoring_identity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2 + d ^ 2) :
    (a ^ 2 - c ^ 2) = (d ^ 2 - b ^ 2) := by linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Difference-of-Squares Factoring Identity
-- ═══════════════════════════════════════════════════════════════




/-- The fundamental factoring identity for Pythagorean triples:
if a² + b² = c², then (c-b)(c+b) = a².
This is the mechanism by which tree nodes reveal factors. -/
theorem pyth_factoring_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by linarith




/-- If gcd(c-b, N) is non-trivial, it divides N.
This is the factor extraction step of the A* algorithm. -/
theorem factor_extraction (N d : ℕ) (hd : 1 < Nat.gcd d N) :
    Nat.gcd d N ∣ N ∧ 1 < Nat.gcd d N := by
  exact ⟨Nat.gcd_dvd_right d N, hd⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Gaussian Norm Properties
-- ═══════════════════════════════════════════════════════════════




/-- The Gaussian norm is non-negative. -/
theorem gaussian_norm_nonneg (a b : ℤ) : 0 ≤ a ^ 2 + b ^ 2 := by positivity




/-- The Gaussian norm is zero iff both components are zero. -/
theorem gaussian_norm_zero_iff (a b : ℤ) :
    a ^ 2 + b ^ 2 = 0 ↔ a = 0 ∧ b = 0 := by
  constructor
  · intro h
    have ha : a ^ 2 = 0 := by nlinarith [sq_nonneg a, sq_nonneg b]
    have hb : b ^ 2 = 0 := by nlinarith [sq_nonneg a, sq_nonneg b]
    exact ⟨by nlinarith [sq_nonneg a], by nlinarith [sq_nonneg b]⟩
  · rintro ⟨rfl, rfl⟩; ring




/-- The Gaussian norm is multiplicative (restated for emphasis). -/
theorem gaussian_norm_mul (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 :=
  brahmagupta_fibonacci_Z a b c d

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Connection to the Berggren Tree
-- ═══════════════════════════════════════════════════════════════




/-- The Euclid parametrization: from (m,n) to a Pythagorean triple.
If gcd(m,n) = 1 and m > n > 0 with m-n odd, the triple is primitive. -/
def euclid_triple (m n : ℤ) : ℤ × ℤ × ℤ :=
  (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)




/-- The Euclid parametrization always gives a Pythagorean triple. -/
theorem euclid_triple_pyth (m n : ℤ) :
    let (a, b, c) := euclid_triple m n
    a ^ 2 + b ^ 2 = c ^ 2 := by
  simp [euclid_triple]; ring




/-- The Gaussian integer z = m + ni gives rise to a triple via z².
z² = (m²-n²) + 2mni, and |z²| = |z|² = m²+n². -/
theorem gaussian_square_is_euclid (m n : ℤ) :
    let z_real := m ^ 2 - n ^ 2  -- Re(z²)
    let z_imag := 2 * m * n      -- Im(z²)
    let z_norm := m ^ 2 + n ^ 2  -- |z|²
    z_real ^ 2 + z_imag ^ 2 = z_norm ^ 2 := by ring




/-- Composing two Euclid parameters via Gaussian multiplication
corresponds to composing the underlying Pythagorean triples. -/
theorem euclid_composition (m₁ n₁ m₂ n₂ : ℤ) :
    let m₃ := m₁ * m₂ - n₁ * n₂
    let n₃ := m₁ * n₂ + n₁ * m₂
    -- The composed hypotenuse is the product of hypotenuses
    (euclid_triple m₃ n₃).2.2 = (euclid_triple m₁ n₁).2.2 * (euclid_triple m₂ n₂).2.2 := by
  simp [euclid_triple]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 8: The Bridge Theorem
-- ═══════════════════════════════════════════════════════════════




/-- The Bridge Theorem: Gaussian integer multiplication composes
Pythagorean triples, and the composed triple preserves the
Pythagorean property. This bridges the additive tree structure
(matrix multiplication) with the multiplicative Gaussian structure. -/
theorem bridge_theorem (m₁ n₁ m₂ n₂ : ℤ) :
    let m₃ := m₁ * m₂ - n₁ * n₂
    let n₃ := m₁ * n₂ + n₁ * m₂
    -- The composed parameters give a valid Pythagorean triple
    (m₃ ^ 2 - n₃ ^ 2) ^ 2 + (2 * m₃ * n₃) ^ 2 = (m₃ ^ 2 + n₃ ^ 2) ^ 2
    -- with hypotenuse = product of original hypotenuses
    ∧ m₃ ^ 2 + n₃ ^ 2 = (m₁ ^ 2 + n₁ ^ 2) * (m₂ ^ 2 + n₂ ^ 2) := by
  constructor
  · ring
  · ring



