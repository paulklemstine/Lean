/-! # CatalogBuild.Speculative.IdempotentCollapse.QuantumCollapse

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 9
-/

import Mathlib

noncomputable section

/-- A self-adjoint idempotent operator. -/
structure QProjection (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V] where
  toFun : V →L[ℝ] V
  idem : ∀ x, toFun (toFun x) = toFun x
  sa : ∀ x y, @inner ℝ V _ (toFun x) y = @inner ℝ V _ x (toFun y)

namespace QProjection

variable (P : QProjection V)


/-- The complement Q = 1 - P is idempotent: Q(Qx) = Qx.
Proof: P(x - Px) = Px - P²x = 0, so Q(Qx) = (x-Px) - P(x-Px) = (x-Px) - 0 = x - Px = Qx. -/
theorem complementary_is_idempotent (x : V) :
    let Q := fun v => v - P.toFun v
    Q (Q x) = Q x := by
  simp only
  have h : P.toFun (x - P.toFun x) = 0 := by
    rw [map_sub]; simp [P.idem]
  simp [h]


/-- Image = fixed-point set. -/
theorem image_eq_fixed : {x | P.toFun x = x} = Set.range P.toFun := by
  ext x; constructor
  · intro h; exact ⟨x, h⟩
  · rintro ⟨y, rfl⟩; exact P.idem y


/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.QuantumCollapse
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 9] -/
theorem norm_le (x : V) : ‖P.toFun x‖ ≤ ‖x‖ := by
  -- By the properties of the inner product and the definition of a projection, we have ‖P(x)‖² = ⟨P(x), P(x)⟩ = ⟨x, P²(x)⟩ = ⟨x, P(x)⟩.
  have h_inner : ‖P.toFun x‖^2 = inner ℝ x (P.toFun x) := by
    rw [ ← real_inner_self_eq_norm_sq, P.sa ];
    rw [ P.idem ];
  nlinarith [ norm_nonneg x, norm_nonneg ( P.toFun x ), abs_le.mp ( abs_real_inner_le_norm x ( P.toFun x ) ) ]


/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.QuantumCollapse
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 9] -/
theorem pythagorean (x : V) :
    ‖x‖ ^ 2 = ‖P.toFun x‖ ^ 2 + ‖x - P.toFun x‖ ^ 2 := by
      have := P.sa x ( x - P.toFun x );
      simp_all +decide [ inner_sub_left, inner_sub_right ];
      rw [ @norm_sub_sq ℝ ] ; simp_all +decide [ real_inner_comm, P.idem ] ; linarith;


/-- Post-measurement stability. -/
theorem post_measurement_stable (x : V) : P.toFun (P.toFun x) = P.toFun x := P.idem x


/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.QuantumCollapse
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 9] -/
theorem iterate_eq_self (n : ℕ) (hn : 1 ≤ n) (x : V) :
    (P.toFun)^[n] x = P.toFun x := by
      induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ];
      exact P.idem x


/-- A projection-valued measure models a quantum observable. -/
structure PVM (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V] (n : ℕ) where
  proj : Fin n → QProjection V
  orthogonal : ∀ i j, i ≠ j → ∀ x, (proj i).toFun ((proj j).toFun x) = 0
  complete : ∀ x, ∑ i : Fin n, (proj i).toFun x = x


/-- Decoherence: diagonal extraction is idempotent. -/
theorem decoherence_is_idempotent {n : ℕ} (ρ : Matrix (Fin n) (Fin n) ℝ) :
    let diag := fun (M : Matrix (Fin n) (Fin n) ℝ) => Matrix.diagonal (fun i => M i i)
    diag (diag ρ) = diag ρ := by
  simp only
  ext i j
  simp only [Matrix.diagonal]
  by_cases h : i = j <;> simp [h]


end
