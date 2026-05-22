import Mathlib
import MachineLearning.TropicalAttention.Defs

/-!
# Theorem E: Deep Transformer Convergence via Tropical Spectral Bounds

Growth bound for iterated tropical linear maps:
  sup_i (T_A^[t] x)_i ≤ sup_i x_i + t * maxEntry(A)

This is the tropical analogue of spectral radius control for deep layers.
-/

noncomputable section

open Finset BigOperators Real

/-! ## Monotonicity and homogeneity of tropical linear maps -/

/-
Tropical linear maps are monotone: x ≤ y implies T_A(x) ≤ T_A(y).
-/
theorem tropLin_mono {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x y : Fin n → ℝ) (hle : ∀ i, x i ≤ y i) :
    ∀ i, tropLin A x i ≤ tropLin A y i := by
  -- For any i, we need to show that (tropLin A x) i ≤ (tropLin A y) i.
  intro i
  simp [tropLin, hle];
  -- Since $x j \leq y j$ for all $j$, we have $A i j + x j \leq A i j + y j$ for all $j$.
  have h_le : ∀ j, A i j + x j ≤ A i j + y j := by
    grind;
  exact ⟨ Classical.choose ( Finset.exists_max_image Finset.univ ( fun j => A i j + y j ) ⟨ i, Finset.mem_univ i ⟩ ), fun j => le_trans ( h_le j ) ( Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun j => A i j + y j ) ⟨ i, Finset.mem_univ i ⟩ ) |>.2 j ( Finset.mem_univ j ) ) ⟩

/-
Tropical linear maps are additively homogeneous:
    T_A(x + c) = T_A(x) + c for scalar c.
-/
theorem tropLin_add_const {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (c : ℝ) :
    tropLin A (fun i => x i + c) = fun i => tropLin A x i + c := by
  -- By definition of tropLin, we have
  unfold tropLin;
  ext i; rw [ @Finset.sup'_eq_csSup_image ] ;
  rw [ @csSup_eq_of_forall_le_of_forall_lt_exists_gt ] <;> norm_num;
  · exact ⟨ _, ⟨ i, rfl ⟩ ⟩;
  · exact fun j => by linarith [ Finset.le_sup' ( fun j => A i j + x j ) ( Finset.mem_univ j ) ] ;
  · exact fun w hw => by rcases Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun j => A i j + x j ) with ⟨ a, ha ⟩ ; exact ⟨ a, by linarith ⟩ ;

/-! ## Growth bound for iterates -/

/-
One-step bound: sup of T_A(x) ≤ maxEntry(A) + sup of x.
-/
theorem tropLin_sup_bound {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) :
    Finset.univ.sup' Finset.univ_nonempty (tropLin A x) ≤
      maxEntry A + Finset.univ.sup' Finset.univ_nonempty x := by
  simp +decide only [tropLin, maxEntry, sup'_le_iff];
  exact fun i _ j _ => add_le_add ( Finset.le_sup' ( fun i => Finset.sup' Finset.univ Finset.univ_nonempty fun j => A i j ) ( Finset.mem_univ i ) |> le_trans ( Finset.le_sup' ( fun j => A i j ) ( Finset.mem_univ j ) ) ) ( Finset.le_sup' ( fun i => x i ) ( Finset.mem_univ j ) )

/-
**Theorem E: Subadditive growth bound for iterated tropical attention.**
    sup_i (T_A^[t] x)_i ≤ sup_i x_i + t * maxEntry(A).
-/
theorem tropical_iterate_sup_bound {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) :
    ∀ t : ℕ,
      Finset.univ.sup' Finset.univ_nonempty (tropLinIter A t x) ≤
        Finset.univ.sup' Finset.univ_nonempty x + t * maxEntry A := by
  intro t;
  induction' t with t ih <;> simp_all +decide [ add_mul, Function.iterate_succ_apply' ];
  · exact ⟨ Classical.choose ( Finset.exists_max_image Finset.univ ( fun i => x i ) ( Finset.univ_nonempty ) ), fun i => Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun i => x i ) ( Finset.univ_nonempty ) ) |>.2 i ( Finset.mem_univ i ) ⟩;
  · intro b
    have := tropLin_sup_bound A (tropLinIter A t x)
    simp_all +decide [ add_assoc ];
    exact le_trans ( this b ) ( by linarith! [ show Finset.univ.sup' Finset.univ_nonempty ( tropLinIter A t x ) ≤ Finset.univ.sup' Finset.univ_nonempty x + t * maxEntry A from Finset.sup'_le _ _ fun i _ => ih i ] )

/-! ## Tropical eigenvector existence under strong dominance -/

/-
Under a constant-row matrix (all rows identical), the tropical operator
    has an explicit eigenvector. This is a restricted but clean eigenvector theorem.
-/
theorem tropLin_const_row_eigenvector {n : ℕ} [Nonempty (Fin n)]
    (a : Fin n → ℝ)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : ∀ i, A i = a) :
    ∃ eigval : ℝ, tropLin A (fun _ => 0) = fun _ => eigval := by
  unfold tropLin;
  aesop

end