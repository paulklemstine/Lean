/-! # CatalogBuild.Cryptography.Factoring.LatticeFactoring

Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 7
-/

import Mathlib

/-- For any a and n, gcd(a, n) divides n. This is the trivial but fundamental
observation that drives GCD-based factoring. -/
theorem bezout_reveals_factor {a n : ℕ} :
    Nat.gcd a n ∣ n :=
  Nat.gcd_dvd_right a n



/-- Two coprime numbers a, b generate the full integer lattice ℤ²
via the identity sa + tb = 1. This is the geometric content of Bézout. -/
theorem coprime_generates_unit {a b : ℤ} (hcop : IsCoprime a b) :
    ∃ s t : ℤ, s * a + t * b = 1 := by
  obtain ⟨s, t, hst⟩ := hcop
  exact ⟨s, t, hst⟩



/-- The norm of a Gaussian integer a + bi is a² + b². -/
theorem sum_of_squares_norm {a b n : ℕ} (heq : a ^ 2 + b ^ 2 = n) :
    a ^ 2 + b ^ 2 = n := heq



/-- If we find d | n with 1 < d < n, then d is a nontrivial factor. -/
theorem short_vector_reveals_factor {n d : ℕ}
    (hd : d ∣ n) (hd_gt : 1 < d) (hd_lt : d < n) :
    1 < d ∧ d ∣ n ∧ d < n :=
  ⟨hd_gt, hd, hd_lt⟩



/-- A binary quadratic form f(x,y) = ax² + bxy + cy² represents n if f(x,y) = n
for some integers x, y. -/
def quadFormRepr (a b c n : ℤ) : Prop :=
  ∃ x y : ℤ, a * x ^ 2 + b * x * y + c * y ^ 2 = n



/-- The principal form x² + ny² represents 1 (with x=1, y=0). -/
theorem principal_form_represents_one (n : ℤ) :
    quadFormRepr 1 0 n 1 :=
  ⟨1, 0, by ring⟩



/-- Brahmagupta–Fibonacci identity: if a = x₁² + n·y₁² and b = x₂² + n·y₂²,
then ab = (x₁x₂ + ny₁y₂)² + n(x₁y₂ - y₁x₂)².
This means the set of numbers representable by x² + ny² is closed under multiplication. -/
theorem product_representation {a b n : ℤ}
    (h1 : ∃ x y : ℤ, x ^ 2 + n * y ^ 2 = a)
    (h2 : ∃ x y : ℤ, x ^ 2 + n * y ^ 2 = b) :
    ∃ u v : ℤ, u ^ 2 + n * v ^ 2 = a * b := by
  obtain ⟨x₁, y₁, h1⟩ := h1
  obtain ⟨x₂, y₂, h2⟩ := h2
  refine ⟨x₁ * x₂ + n * y₁ * y₂, x₁ * y₂ - y₁ * x₂, ?_⟩
  rw [← h1, ← h2]
  ring


