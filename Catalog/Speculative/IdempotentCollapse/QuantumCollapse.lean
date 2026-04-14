import Mathlib

/-!
# Quantum Measurement as Idempotent Collapse

Measurement operators are orthogonal projections (P² = P, P* = P).
The Born rule emerges from the geometry of idempotent collapse.
-/

open Set Function

noncomputable section

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

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

/-
PROBLEM
Projection decreases norm: ‖Px‖ ≤ ‖x‖.

PROVIDED SOLUTION
‖Px‖² = ⟨Px,Px⟩ = ⟨x, P²x⟩ = ⟨x, Px⟩ ≤ ‖x‖‖Px‖ by Cauchy-Schwarz. So ‖Px‖ ≤ ‖x‖.
-/
theorem norm_le (x : V) : ‖P.toFun x‖ ≤ ‖x‖ := by
  -- By the properties of the inner product and the definition of a projection, we have ‖P(x)‖² = ⟨P(x), P(x)⟩ = ⟨x, P²(x)⟩ = ⟨x, P(x)⟩.
  have h_inner : ‖P.toFun x‖^2 = inner ℝ x (P.toFun x) := by
    rw [ ← real_inner_self_eq_norm_sq, P.sa ];
    rw [ P.idem ];
  nlinarith [ norm_nonneg x, norm_nonneg ( P.toFun x ), abs_le.mp ( abs_real_inner_le_norm x ( P.toFun x ) ) ]

/-
PROBLEM
Pythagorean: ‖x‖² = ‖Px‖² + ‖x - Px‖².

PROVIDED SOLUTION
x = Px + (x - Px). Inner product ⟨Px, x-Px⟩ = ⟨Px, x⟩ - ⟨Px, Px⟩ = ⟨x, Px⟩ - ⟨x, P²x⟩ = 0. Then ‖x‖² = ‖Px + (x-Px)‖² = ‖Px‖² + ‖x-Px‖² by Pythagorean theorem.
-/
theorem pythagorean (x : V) :
    ‖x‖ ^ 2 = ‖P.toFun x‖ ^ 2 + ‖x - P.toFun x‖ ^ 2 := by
      have := P.sa x ( x - P.toFun x );
      simp_all +decide [ inner_sub_left, inner_sub_right ];
      rw [ @norm_sub_sq ℝ ] ; simp_all +decide [ real_inner_comm, P.idem ] ; linarith;

/-- Post-measurement stability. -/
theorem post_measurement_stable (x : V) : P.toFun (P.toFun x) = P.toFun x := P.idem x

/-
PROBLEM
Iterating n ≥ 1 times = one application.

PROVIDED SOLUTION
Induction on hn : 1 ≤ n. Base: n=1, trivial. Step: f^[n+1] x = f(f^[n] x) = f(f x) by IH = f x by idem. Use Nat.le.step case and iterate_succ'.
-/
theorem iterate_eq_self (n : ℕ) (hn : 1 ≤ n) (x : V) :
    (P.toFun)^[n] x = P.toFun x := by
      induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ];
      exact P.idem x

end QProjection

/-- A projection-valued measure models a quantum observable. -/
structure PVM (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V] (n : ℕ) where
  proj : Fin n → QProjection V
  orthogonal : ∀ i j, i ≠ j → ∀ x, (proj i).toFun ((proj j).toFun x) = 0
  complete : ∀ x, ∑ i : Fin n, (proj i).toFun x = x

/-
PROBLEM
Born rule: ∑ ‖Pᵢ ψ‖² = ‖ψ‖².

PROVIDED SOLUTION
Use M.complete: x = ∑ Pᵢ x. Then ‖x‖² = ‖∑ Pᵢ x‖². Since Pᵢ are mutually orthogonal (Pᵢ Pⱼ = 0 for i≠j), and each Pᵢ is self-adjoint, ⟨Pᵢ x, Pⱼ x⟩ = ⟨x, Pᵢ(Pⱼ x)⟩ = 0 for i≠j. So ‖∑ Pᵢ x‖² = ∑ ‖Pᵢ x‖² by Pythagorean theorem for mutually orthogonal vectors.
-/
theorem born_probabilities_sum {n : ℕ} (M : PVM V n) (x : V) :
    ∑ i : Fin n, ‖(M.proj i).toFun x‖ ^ 2 = ‖x‖ ^ 2 := by
      -- By the properties of the inner product and the orthogonal projections, we can expand the norm squared of the sum.
      have h_expand : ‖∑ i, (M.proj i).toFun x‖ ^ 2 = ∑ i, ‖(M.proj i).toFun x‖ ^ 2 := by
        -- By the properties of the inner product and the orthogonality of the projections, we can expand the norm squared of the sum.
        have h_expand : ∀ i j, i ≠ j → inner ℝ ((M.proj i).toFun x) ((M.proj j).toFun x) = 0 := by
          intro i j hij;
          have := M.orthogonal i j hij x;
          have := ( M.proj i ).sa x ( ( M.proj j |> QProjection.toFun ) x ) ; aesop;
        induction' ( Finset.univ : Finset ( Fin n ) ) using Finset.induction <;> simp_all +decide [ Finset.sum_insert, inner_add_right, norm_add_sq_real ];
        rw [ inner_sum, Finset.sum_eq_zero ] ; aesop;
      rw [ ← h_expand, M.complete ]

/-- Decoherence: diagonal extraction is idempotent. -/
theorem decoherence_is_idempotent {n : ℕ} (ρ : Matrix (Fin n) (Fin n) ℝ) :
    let diag := fun (M : Matrix (Fin n) (Fin n) ℝ) => Matrix.diagonal (fun i => M i i)
    diag (diag ρ) = diag ρ := by
  simp only
  ext i j
  simp only [Matrix.diagonal]
  by_cases h : i = j <;> simp [h]

end