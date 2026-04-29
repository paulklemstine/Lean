import Mathlib

/-! # Hamming Distance Bridge

Proves Hamming distance properties connecting coding theory to
certified adversarial robustness:

1. Hamming distance metric: symmetry, triangle inequality, identity
2. Distance positivity implies distinctness (analog of L∞ margin)
3. Connection to error-detection in coding theory
-/

namespace HammingDistanceBridge

/-! ## Section 1: Metric Properties -/

/-- Hamming distance is symmetric: d(x,y) = d(y,x). -/
theorem hamming_symmetric {n : ℕ} (x y : Fin n → Bool) :
    hammingDist x y = hammingDist y x :=
  hammingDist_comm x y

/-- Hamming distance satisfies the triangle inequality:
    d(x,z) ≤ d(x,y) + d(y,z). -/
theorem hamming_triangle {n : ℕ} (x y z : Fin n → Bool) :
    hammingDist x z ≤ hammingDist x y + hammingDist y z :=
  hammingDist_triangle x y z

/-- Hamming distance to self is zero: d(x,x) = 0. -/
theorem hamming_self {n : ℕ} (x : Fin n → Bool) :
    hammingDist x x = 0 :=
  hammingDist_self x

/-- Hamming distance equals 0 iff strings are equal. -/
theorem hamming_eq_zero {n : ℕ} (x y : Fin n → Bool) :
    hammingDist x y = 0 ↔ x = y := by
  constructor
  · intro h; exact hammingDist_eq_zero.mp h
  · intro h; subst h; exact hammingDist_self x

/-- Hamming distance is non-negative. -/
theorem hamming_nonneg {n : ℕ} (x y : Fin n → Bool) :
    (0 : ℕ) ≤ hammingDist x y :=
  Nat.zero_le _

/-! ## Section 2: Certified Robustness Analog -/

/-- Distance positivity implies distinctness.
    If Hamming distance > 0, then x ≠ y.
    This is the analog of: L∞ distance > 0 implies points are distinct. -/
theorem distance_positive_distinct {n : ℕ} (x y : Fin n → Bool)
    (hd : 0 < hammingDist x y) :
    x ≠ y := by
  intro h
  subst h
  simp [hammingDist_self] at hd

/-- Minimum distance ≥ d > 0 implies distinct codewords.
    This is the coding-theoretic analog of certified robustness:
    if the minimum distance of a code is d > 0, then any two distinct
    codewords differ in at least d positions, giving certified detection
    of up to d-1 errors and certified correction of up to ⌊(d-1)/2⌋ errors. -/
theorem minimum_distance_distinct {n : ℕ} (x y : Fin n → Bool) (d : ℕ)
    (hdist : d ≤ hammingDist x y) (hd_pos : 0 < d) :
    x ≠ y := by
  intro h_eq
  subst h_eq
  simp [hammingDist_self] at hdist
  omega

end HammingDistanceBridge
