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

/-! ## Stage 4: Idempotent Projections -/

/-- A function is idempotent if applying it twice equals applying it once. -/

theorem const_is_idempotent {α : Type*} (c : α) : IsIdempotent (fun _ => c) := by
  intro x; rfl

/-
PROBLEM
If f is idempotent and g is idempotent and they commute (f ∘ g = g ∘ f),
    then f ∘ g is idempotent.

PROVIDED SOLUTION
(f∘g)(f∘g)(x) = f(g(f(g(x)))). By commutativity hcomm on g(x): g(f(g(x))) = f(g(g(x))). Wait, hcomm says f(g(x)) = g(f(x)). So f(g(f(g(x)))) -- apply hcomm to the inner g(f(g(x))): we need f(g(y)) where y = f(g(x)). Actually let's be more careful. IsIdempotent (f ∘ g) means (f ∘ g) ((f ∘ g) x) = (f ∘ g) x, i.e., f(g(f(g(x)))) = f(g(x)). By hcomm: g(f(y)) = f(g(y)) for all y. So g(f(g(x))) = f(g(g(x))) = f(g(x)) by hg. Then f(g(f(g(x)))) = f(f(g(x))) = f(g(x)) by hf. Use simp [IsIdempotent, Function.comp] and rewrite with hcomm, hf, hg.
-/

theorem idempotent_composition {α : Type*} (f g : α → α)
    (hf : IsIdempotent f) (hg : IsIdempotent g)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    IsIdempotent (f ∘ g) := by
  intro x; exact (by
  have := hf ( g x ) ; have := hg ( f x ) ; aesop;);

/-
PROBLEM
Fixed points of an idempotent map are exactly its range.

PROVIDED SOLUTION
Forward: if f x = x, take y = x. Backward: if f y = x, then f x = f (f y) = f y = x by hf.
-/

theorem idempotent_fixed_point_iff {α : Type*} (f : α → α)
    (hf : IsIdempotent f) (x : α) :
    f x = x ↔ ∃ y, f y = x := by
  aesop

/-! ## Stage 3: Stereographic Parametrization -/

/-
PROBLEM
The stereographic parametrization of the unit circle:
    t ↦ ((1 - t²)/(1 + t²), 2t/(1 + t²)) maps ℚ → ℚ × ℚ on x² + y² = 1.

PROVIDED SOLUTION
Use field_simp to clear denominators, then ring.
-/

theorem stereographic_on_circle (t : ℚ) (h : 1 + t ^ 2 ≠ 0) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  grind +revert

/-! ## Stage 5: The Berggren Tree -/

/-- The three Berggren matrices generate all primitive Pythagorean triples from (3,4,5). -/

theorem base_triple_pythagorean : (3 : ℤ) ^ 2 + (4 : ℤ) ^ 2 = (5 : ℤ) ^ 2 := by norm_num

/-
PROBLEM
Berggren matrix A preserves the Pythagorean property:
    if a² + b² = c², then (a - 2b + 2c)² + (2a - b + 2c)² = (2a - 2b + 3c)².

PROVIDED SOLUTION
Use nlinarith with h.
-/

theorem berggren_A_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 =
    (2 * a - 2 * b + 3 * c) ^ 2 := by
  lia

/-
PROBLEM
Berggren matrix B preserves the Pythagorean property.

PROVIDED SOLUTION
Use nlinarith with h.
-/

theorem berggren_B_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2 * b + 2 * c) ^ 2 + (2 * a + b + 2 * c) ^ 2 =
    (2 * a + 2 * b + 3 * c) ^ 2 := by
  grind +qlia

/-
PROBLEM
Berggren matrix C preserves the Pythagorean property.

PROVIDED SOLUTION
Use nlinarith with h.
-/

theorem berggren_C_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2 * b + 2 * c) ^ 2 + (-2 * a + b + 2 * c) ^ 2 =
    (-2 * a + 2 * b + 3 * c) ^ 2 := by
  lia

/-! ## Stage 6–7: Decode and Verify -/

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
