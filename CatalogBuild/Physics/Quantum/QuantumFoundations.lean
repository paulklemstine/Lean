/-! # CatalogBuild.Physics.Quantum.QuantumFoundations

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 5
-/

import Mathlib

/-- [Section: ## Section 1: Norm Properties] -/
theorem norm_triangle_pf {V : Type*} [SeminormedAddCommGroup V] (x y : V) :
    ‖x + y‖ ≤ ‖x‖ + ‖y‖ := by
      exact norm_add_le x y


theorem inner_mul_le_norm_pf {V : Type*} [SeminormedAddCommGroup V] [InnerProductSpace ℝ V] (x y : V) :
    @inner ℝ V _ x y ≤ ‖x‖ * ‖y‖ := by
      exact?


/-- [Section: ## Section 2: Unitary Matrix Properties] -/
theorem unitary_mul_unitary {n : Type*} [DecidableEq n] [Fintype n]
    (U V : Matrix n n ℂ) (hU : U * star U = 1) (hV : V * star V = 1) :
    (U * V) * star (U * V) = 1 := by
      simp +decide [ ← mul_assoc, hU, hV ];
      simp +decide [ mul_assoc, hU, hV ]


theorem unitary_inv_eq_star {n : Type*} [DecidableEq n] [Fintype n]
    (U : Matrix n n ℂ) (hU : U * star U = 1) :
    star U * U = 1 := by
      rw [ ← mul_eq_one_comm, hU ]


/-- [Section: ## Section 3: Quantum State Properties] -/
theorem tensor_normalized (a b c d : ℂ)
    (h1 : Complex.normSq a + Complex.normSq b = 1)
    (h2 : Complex.normSq c + Complex.normSq d = 1) :
    Complex.normSq (a * c) + Complex.normSq (a * d) +
    Complex.normSq (b * c) + Complex.normSq (b * d) = 1 := by
      simpa [ Complex.normSq_mul ] using by linear_combination' h1 * h2;

