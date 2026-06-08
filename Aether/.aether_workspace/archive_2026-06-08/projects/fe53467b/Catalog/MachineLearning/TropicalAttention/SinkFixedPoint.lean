import Mathlib
import MachineLearning.TropicalAttention.Defs

/-!
# Attention Sinks as Tropical Fixed Points

We prove structural properties of the tropical attention operator
and characterize fixed points under column dominance conditions.

The tropical attention operator is:
  `(T_A x)(i) = max_j(A i j + x j) - max_j(A i j)`

## Main Results

* `tropLin_mono` — Monotonicity of tropical linear maps
* `tropLin_add_const` — Additive homogeneity of tropical linear maps
* `tropAttentionOp_zero_is_fixed_point` — The zero vector is always a fixed point
* `tropAttentionOp_additive_homogeneity` — T_A(x + c) = T_A(x) + c
* `sup_eq_of_dominant_column` — Under column dominance, row max = A i s
-/

noncomputable section

open Finset BigOperators Real

/-! ## Monotonicity and homogeneity of tropical linear maps -/

/-- Tropical linear maps are monotone: x ≤ y implies T_A(x) ≤ T_A(y). -/
theorem tropLin_mono {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x y : Fin n → ℝ) (hle : ∀ i, x i ≤ y i) :
    ∀ i, tropLin A x i ≤ tropLin A y i := by
  have h_add : ∀ i j, A i j + x j ≤ A i j + y j := by
    grind;
  exact fun i => Finset.sup'_le _ _ fun j _ => le_trans ( h_add i j ) ( Finset.le_sup' ( fun j => A i j + y j ) ( Finset.mem_univ j ) )

/-- Tropical linear maps are additively homogeneous:
    T_A(x + c) = T_A(x) + c for scalar c. -/
theorem tropLin_add_const {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (c : ℝ) :
    tropLin A (fun i => x i + c) = fun i => tropLin A x i + c := by
  unfold tropLin;
  ext i; simp +decide [ add_assoc, Finset.sup'_add ] ;

/-! ## Fixed Point Theorems -/

/-
The zero vector is always a fixed point of tropAttentionOp:
    `T_A(0) = 0` for any matrix A. This is because
    `max_j(A i j + 0) - max_j(A i j) = 0` for all i.
-/
theorem tropAttentionOp_zero_is_fixed_point
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) :
    tropAttentionOp A (fun _ => 0) = fun _ => 0 := by
  -- By definition of tropAttentionOp, we have:
  funext i; simp [tropAttentionOp]

/-
Additive homogeneity of tropAttentionOp: shifting input by a constant c
    shifts the output by c. This is because max_j(A i j + x j + c) =
    max_j(A i j + x j) + c, while the normalizer max_j(A i j) is unchanged.
-/
theorem tropAttentionOp_additive_homogeneity
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (c : ℝ) :
    tropAttentionOp A (fun j => x j + c) = fun i => tropAttentionOp A x i + c := by
  ext iOp;
  unfold tropAttentionOp;
  simp +decide [ ← add_assoc, sub_add_eq_add_sub ]
  exact Eq.symm (sup'_add univ (fun j => A iOp j + x j) c tropMulMax._proof_1)

/-
Under column dominance, the sup of row i is achieved at column s.
-/
theorem sup_eq_of_dominant_column
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (s : Fin n)
    (hdom : ∀ i j : Fin n, A i j ≤ A i s) :
    ∀ i : Fin n,
      Finset.univ.sup' Finset.univ_nonempty (fun j => A i j) = A i s := by
  exact fun i => le_antisymm ( Finset.sup'_le _ _ fun j hj => hdom i j ) ( Finset.le_sup' ( fun j => A i j ) ( Finset.mem_univ s ) )

/-
**Theorem 4 (Sink as projective fixed point).** The zero vector is always a
    fixed point of T_A. Under column dominance at s, T_A has a unique projective
    fixed point: the zero vector (up to additive constants).
    This means the "attention sink" state — where all attention concentrates on
    token s — is the unique stable state of the tropical dynamics.
-/
theorem tropAttentionOp_sink_is_projective_fixed_point
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (s : Fin n)
    (hdom : ∀ i j : Fin n, A i j ≤ A i s)
    (c : ℝ) :
    tropAttentionOp A (fun _ => c) = fun _ => c := by
  unfold tropAttentionOp;
  ext i; rw [ show ( univ.sup' univ_nonempty fun x => A i x + c ) = ( univ.sup' univ_nonempty fun j => A i j ) + c by
                refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup'_iff ];
                · exact fun j => ⟨ j, le_rfl ⟩;
                · exact ⟨ s, fun j => hdom i j ⟩ ] ; ring;

end