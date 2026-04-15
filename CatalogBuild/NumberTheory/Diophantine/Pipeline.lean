/-! # CatalogBuild.NumberTheory.Diophantine.Pipeline

Auto-generated from theorem catalog database.
Domain: NumberTheory/Diophantine
Declarations: 14
-/

import Mathlib

/-- A Diophantine equation in two variables is a polynomial `p(x, y)` with integer
coefficients. A solution is a pair `(a, b) ∈ ℤ²` such that `p(a, b) = 0`. -/
def DiophantineSolution (p : ℤ → ℤ → ℤ) (a b : ℤ) : Prop := p a b = 0


/-- Verification is decidable: given a polynomial and a candidate, we can check. -/
instance diophantine_verification_decidable (p : ℤ → ℤ → ℤ) (a b : ℤ) :
    Decidable (DiophantineSolution p a b) :=
  inferInstanceAs (Decidable (p a b = 0))


/-- A constant function is idempotent. -/
theorem const_is_idempotent {α : Type*} (c : α) : IsIdempotent (fun _ => c) := by
  intro x; rfl


/-- [Section: ## Stage 4: Idempotent Projections] -/
theorem idempotent_composition {α : Type*} (f g : α → α)
    (hf : IsIdempotent f) (hg : IsIdempotent g)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    IsIdempotent (f ∘ g) := by
  intro x; exact (by
  have := hf ( g x ) ; have := hg ( f x ) ; aesop;);


theorem idempotent_fixed_point_iff {α : Type*} (f : α → α)
    (hf : IsIdempotent f) (x : α) :
    f x = x ↔ ∃ y, f y = x := by
  aesop


/-- [Section: ## Stage 3: Stereographic Parametrization] -/
theorem stereographic_on_circle (t : ℚ) (h : 1 + t ^ 2 ≠ 0) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  grind +revert


/-- The base triple (3, 4, 5) satisfies the Pythagorean equation. -/
theorem base_triple_pythagorean : (3 : ℤ) ^ 2 + (4 : ℤ) ^ 2 = (5 : ℤ) ^ 2 := by norm_num


theorem berggren_A_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 =
    (2 * a - 2 * b + 3 * c) ^ 2 := by
  lia


theorem berggren_B_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2 * b + 2 * c) ^ 2 + (2 * a + b + 2 * c) ^ 2 =
    (2 * a + 2 * b + 3 * c) ^ 2 := by
  grind +qlia


theorem berggren_C_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2 * b + 2 * c) ^ 2 + (-2 * a + b + 2 * c) ^ 2 =
    (-2 * a + 2 * b + 3 * c) ^ 2 := by
  lia


/-- A verified Diophantine solution bundles the solution with its proof. -/
structure VerifiedSolution (p : ℤ → ℤ → ℤ) where
  x : ℤ
  y : ℤ
  proof : p x y = 0


/-- Example: (3, 4) is a verified solution to x² + y² = 25. -/
def pythagorean_3_4 : VerifiedSolution (fun x y => x ^ 2 + y ^ 2 - 25) :=
  ⟨3, 4, by norm_num⟩


/-- Example: (5, 12) is a verified solution to x² + y² = 169. -/
def pythagorean_5_12 : VerifiedSolution (fun x y => x ^ 2 + y ^ 2 - 169) :=
  ⟨5, 12, by norm_num⟩


/-- The pipeline is sound: if it outputs a VerifiedSolution, the solution is correct. -/
theorem pipeline_soundness (p : ℤ → ℤ → ℤ) (sol : VerifiedSolution p) :
    p sol.x sol.y = 0 := sol.proof
