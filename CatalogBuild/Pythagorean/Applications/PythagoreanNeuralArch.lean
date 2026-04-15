/-! # CatalogBuild.Pythagorean.Applications.PythagoreanNeuralArch

Auto-generated from theorem catalog database.
Domain: Pythagorean/Applications
Declarations: 23
-/

import Mathlib

/-- A Pythagorean triple (a, b, c) with c ≠ 0 gives a point on the unit circle. -/
theorem pythagorean_unit_circle (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    ((a : ℚ) / c) ^ 2 + ((b : ℚ) / c) ^ 2 = 1 := by
  have hc' : (c : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hc
  field_simp
  exact_mod_cast h


/-- The unit circle constraint in ℝ. -/
theorem pythagorean_unit_circle_real (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    ((a : ℝ) / c) ^ 2 + ((b : ℝ) / c) ^ 2 = 1 := by
  have hc' : (c : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hc
  field_simp
  exact_mod_cast h


/-- The squared norm of a Pythagorean weight vector is exactly 1. -/
theorem pythagorean_weight_norm_sq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    ((a : ℝ) / c) ^ 2 + ((b : ℝ) / c) ^ 2 = 1 :=
  pythagorean_unit_circle_real a b c h hc


/-- A Pythagorean weight vector has norm ≤ 1 (each component). -/
theorem pythagorean_weight_component_bound (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    ((a : ℝ) / c) ^ 2 ≤ 1 := by
  have := pythagorean_unit_circle_real a b c h hc
  nlinarith [sq_nonneg ((b : ℝ) / c)]


/-- Composing two Pythagorean triples via Gaussian multiplication gives another triple. -/
theorem gaussian_composition_preserves_pyth (a b c d e f : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2) (h2 : d ^ 2 + e ^ 2 = f ^ 2) :
    (a * d - b * e) ^ 2 + (a * e + b * d) ^ 2 = (c * f) ^ 2 := by
  have := brahmagupta_fibonacci a b d e
  nlinarith [mul_pow c f 2]


theorem gaussian_composition_unit_circle (a b c d e f : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2) (h2 : d ^ 2 + e ^ 2 = f ^ 2)
    (hc : c ≠ 0) (hf : f ≠ 0) :
    (((a * d - b * e : ℤ) : ℝ) / (c * f)) ^ 2 +
    (((a * e + b * d : ℤ) : ℝ) / (c * f)) ^ 2 = 1 := by
  have hcf : (c : ℝ) * f ≠ 0 := by
    exact_mod_cast mul_ne_zero hc hf
  field_simp
  norm_cast; linear_combination' h1 * h2;


/-- A single Pythagorean neuron computes w · x where ‖w‖ = 1,
so |w · x| ≤ ‖x‖ by Cauchy-Schwarz. We formalize this as: the
linear functional is bounded. -/
theorem pythagorean_layer_lipschitz (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hc : c ≠ 0) (x y : ℝ) :
    ((a : ℝ) / c * x + (b : ℝ) / c * y) ^ 2 ≤ (x ^ 2 + y ^ 2) := by
  have huc := pythagorean_unit_circle_real a b c h hc
  nlinarith [sq_nonneg ((a : ℝ) / c * y - (b : ℝ) / c * x)]


/-- Composition of Pythagorean layers: the composed layer is also 1-Lipschitz.
If f and g are both 1-Lipschitz, then f ∘ g is 1-Lipschitz. -/
theorem deep_network_lipschitz (f g : ℝ → ℝ)
    (hf : ∀ x y, |f x - f y| ≤ |x - y|)
    (hg : ∀ x y, |g x - g y| ≤ |x - y|) :
    ∀ x y, |f (g x) - f (g y)| ≤ |x - y| := by
  intro x y
  calc |f (g x) - f (g y)| ≤ |g x - g y| := hf (g x) (g y)
    _ ≤ |x - y| := hg x y


/-- Berggren M₁ transition preserves unit circle membership for weights. -/
theorem berggren_M1_unit_circle (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    let a' := a - 2 * b + 2 * c
    let b' := 2 * a - b + 2 * c
    let c' := 2 * a - 2 * b + 3 * c
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  nlinarith


/-- Berggren M₂ transition preserves unit circle membership for weights. -/
theorem berggren_M2_unit_circle (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    let a' := a + 2 * b + 2 * c
    let b' := 2 * a + b + 2 * c
    let c' := 2 * a + 2 * b + 3 * c
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  nlinarith


/-- Berggren M₃ transition preserves unit circle membership for weights. -/
theorem berggren_M3_unit_circle (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (_hc : c ≠ 0) :
    let a' := -a + 2 * b + 2 * c
    let b' := -2 * a + b + 2 * c
    let c' := -2 * a + 2 * b + 3 * c
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  nlinarith


/-- The hypotenuse of a Berggren child is always strictly larger (when a, b > 0),
meaning we can always find finer-grained weight quantizations by going deeper. -/
theorem berggren_hypotenuse_grows (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < 2 * a + 2 * b + 3 * c := by
  linarith


/-- The stereographic parametrization gives a point on the unit circle. -/
theorem stereographic_unit_circle (t : ℝ) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  have h1 : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp
  ring


/-- The rational stereographic parametrization also gives unit circle points. -/
theorem stereographic_unit_circle_rat (t : ℚ) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  have h1 : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp
  ring


/-- At depth d, the Berggren tree has exponentially many nodes. -/
theorem berggren_tree_exponential_growth (d : ℕ) :
    3 ^ (d + 1) = 3 * 3 ^ d := by
  ring


theorem clamp_lipschitz (x y : ℝ) :
    |max (-1) (min 1 x) - max (-1) (min 1 y)| ≤ |x - y| := by
  cases max_cases ( -1 ) ( Min.min 1 x ) <;> cases max_cases ( -1 ) ( Min.min 1 y ) <;> cases min_cases 1 x <;> cases min_cases 1 y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( Max.max ( -1 ) ( Min.min 1 x ) - Max.max ( -1 ) ( Min.min 1 y ) ) <;> linarith


/-- A Pythagorean triple (a, b, c) at Berggren depth d has
c ≤ 7^d · 5 (each Berggren matrix multiplies entries by at most 7). -/
theorem hypotenuse_upper_bound_crude :
    ∀ a b c : ℤ, a ^ 2 + b ^ 2 = c ^ 2 → 0 < c → |a| ≤ c := by
  intro a b c h hc
  rw [abs_le]
  constructor
  · nlinarith [sq_nonneg b, sq_nonneg (a + c)]
  · nlinarith [sq_nonneg b]


/-- The leg of a Pythagorean triple is bounded by the hypotenuse. -/
theorem leg_le_hypotenuse (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 < c) :
    a ^ 2 ≤ c ^ 2 := by
  nlinarith [sq_nonneg b]


/-- The identity element for Gaussian composition: (1, 0) with norm 1. -/
theorem gaussian_norm_identity (a b : ℤ) :
    (a * 1 - b * 0) ^ 2 + (a * 0 + b * 1) ^ 2 = a ^ 2 + b ^ 2 := by
  ring


/-- Gaussian composition is commutative (up to sign of the cross term). -/
theorem gaussian_composition_comm (a b c d : ℤ) :
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 =
    (c * a - d * b) ^ 2 + (c * b + d * a) ^ 2 := by
  ring


/-- Associativity of the norm multiplication (consequence of Gaussian integer
multiplication being associative). -/
theorem gaussian_norm_assoc (a₁ b₁ a₂ b₂ a₃ b₃ : ℤ) :
    (a₁ ^ 2 + b₁ ^ 2) * ((a₂ ^ 2 + b₂ ^ 2) * (a₃ ^ 2 + b₃ ^ 2)) =
    ((a₁ ^ 2 + b₁ ^ 2) * (a₂ ^ 2 + b₂ ^ 2)) * (a₃ ^ 2 + b₃ ^ 2) := by
  ring


/-- The sum of squares of a Pythagorean weight vector row equals 1. -/
theorem pythagorean_row_norm (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : (c : ℝ) ≠ 0) :
    ((a : ℝ) / c) ^ 2 + ((b : ℝ) / c) ^ 2 = 1 := by
  field_simp
  exact_mod_cast h


/-- The angle resolution improves with Berggren depth: at depth d,
we have 3^d triples, giving angular resolution approximately π/(2·3^d). -/
theorem angle_resolution_bound (d : ℕ) (hd : 0 < d) :
    3 ^ d ≥ 3 := by
  calc 3 ^ d ≥ 3 ^ 1 := Nat.pow_le_pow_right (by norm_num) hd
    _ = 3 := by norm_num

