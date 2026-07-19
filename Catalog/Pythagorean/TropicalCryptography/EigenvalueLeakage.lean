import Mathlib

/-!
# Tropical matrix powers leak a nonzero eigenvalue

This file gives a self-contained min-plus development over real matrices.  It proves
that a tropical eigenpair `(λ,v)` of `A` remains an eigenpair of the positive power
`A^[k]`, with eigenvalue `(k+1)λ`.  Consequently, equality of two positive powers
forces equality of their exponents whenever `λ ≠ 0`.

The result isolates a rigorous limitation of the proposed tropical discrete-logarithm
construction: once a nonzero eigenpair is available, the exponent is algebraically
identifiable from its eigenvalue.  No computational-hardness or security claim is made.
-/

namespace TropicalCryptography

open Finset

noncomputable section

variable {n : ℕ} [NeZero n]

/-- Min-plus matrix multiplication on finite nonempty real matrices. -/
def minPlusMul (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => univ.inf' univ_nonempty (fun k => A i k + B k j)

/-- Min-plus action of a matrix on a vector. -/
def minPlusAct (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => univ.inf' univ_nonempty (fun j => A i j + v j)

/-- Positive min-plus powers: `positivePower A k` denotes exponent `k+1`. -/
def positivePower (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | k + 1 => minPlusMul A (positivePower A k)

/-- A min-plus eigenpair satisfies `A ⊗ v = λ + v` entrywise. -/
def IsEigenpair (A : Matrix (Fin n) (Fin n) ℝ) (lambda : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, minPlusAct A v i = lambda + v i

/-
Matrix multiplication and matrix action associate in min-plus algebra.
-/
theorem minPlusAct_mul (A B : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    minPlusAct (minPlusMul A B) v = minPlusAct A (minPlusAct B v) := by
  funext i;
  refine' le_antisymm _ _;
  · obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun k => A i k + ( Finset.inf' Finset.univ Finset.univ_nonempty fun j => B k j + v j );
    obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun j => B k j + v j;
    simp_all +decide [ minPlusMul, minPlusAct ];
    exact ⟨ j, by linarith [ show ( Finset.inf' Finset.univ Finset.univ_nonempty fun k => A i k + B k j ) ≤ A i k + B k j from Finset.inf'_le _ ( Finset.mem_univ k ) ] ⟩;
  · simp +decide only [minPlusAct];
    simp +decide [ minPlusMul ];
    intro b; exact (by
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => A i k + B k b ) ; use k; simp_all +decide [ add_assoc ] ;
    exact ⟨ b, le_rfl ⟩);

/-
Min-plus action commutes with tropical scalar translation.
-/
theorem minPlusAct_shift (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (c : ℝ) :
    minPlusAct A (fun i => c + v i) = fun i => c + minPlusAct A v i := by
  ext i; simp [minPlusAct]; (
  refine' le_antisymm _ _ <;> simp_all +decide [ add_left_comm ];
  · simpa using Finset.exists_min_image Finset.univ ( fun j => A i j + v j ) ⟨ i, Finset.mem_univ i ⟩;
  · exact fun b => ⟨ b, le_rfl ⟩);

/-
**Eigenvalue leakage under powers.**  A known eigenvector of `A` is an
    eigenvector of every positive power, and its eigenvalue scales exactly with
    the exponent.
-/
theorem eigenpair_positivePower (A : Matrix (Fin n) (Fin n) ℝ)
    (lambda : ℝ) (v : Fin n → ℝ) (h : IsEigenpair A lambda v) (k : ℕ) :
    IsEigenpair (positivePower A k) ((k + 1 : ℕ) * lambda) v := by
  induction k <;> simp_all +decide [ add_mul, IsEigenpair ];
  · exact h;
  · intro i; erw [ minPlusAct_mul ] ;
    rw [ show minPlusAct ( positivePower A _ ) v = fun i => ↑_ * lambda + lambda + v i from funext ‹_› ] ; simp +decide [ *, minPlusAct_shift ] ; ring;

/-
Equality of positive powers is impossible at distinct exponents when a nonzero
    eigenvalue is known.  Thus the power map is injective on positive exponents in
    this regime.
-/
theorem positivePower_injective_of_nonzero_eigenvalue
    (A : Matrix (Fin n) (Fin n) ℝ) (lambda : ℝ) (v : Fin n → ℝ)
    (h : IsEigenpair A lambda v) (hlambda : lambda ≠ 0)
    {a b : ℕ} (hab : positivePower A a = positivePower A b) :
    a = b := by
  -- By the eigenpair property, we have that for any index i, minPlusAct (positivePower A a) v i = (a + 1) * lambda + v i and minPlusAct (positivePower A b) v i = (b + 1) * lambda + v i.
  have h_eigenpairs : ∀ i, minPlusAct (positivePower A a) v i = (a + 1) * lambda + v i ∧ minPlusAct (positivePower A b) v i = (b + 1) * lambda + v i := by
    exact fun i => ⟨ mod_cast eigenpair_positivePower A lambda v h a i, mod_cast eigenpair_positivePower A lambda v h b i ⟩;
  simp_all +decide;
  exact_mod_cast ( mul_left_cancel₀ hlambda <| by linarith [ h_eigenpairs ⟨ 0, NeZero.pos n ⟩ ] : ( a : ℝ ) = b )

/-
The eigenvalue observed on the same eigenvector determines the positive exponent:
    it must be exactly `(k+1)λ`.
-/
theorem observed_eigenvalue_of_power
    (A B : Matrix (Fin n) (Fin n) ℝ) (lambda mu : ℝ) (v : Fin n → ℝ)
    (hA : IsEigenpair A lambda v) (k : ℕ) (hB : B = positivePower A k)
    (hobs : IsEigenpair B mu v) :
    mu = (k + 1 : ℕ) * lambda := by
  have := eigenpair_positivePower A lambda v hA k; simp_all +decide [ IsEigenpair ] ;

/-
A collision of distinct positive powers forces every eigenvalue admitting an
    eigenvector to vanish.  This is the contrapositive cryptanalytic criterion.
-/
theorem eigenvalue_zero_of_positivePower_collision
    (A : Matrix (Fin n) (Fin n) ℝ) (lambda : ℝ) (v : Fin n → ℝ)
    (h : IsEigenpair A lambda v) {a b : ℕ} (hne : a ≠ b)
    (hab : positivePower A a = positivePower A b) :
    lambda = 0 := by
  exact Classical.not_not.1 fun hlambda => hne <| positivePower_injective_of_nonzero_eigenvalue A _ _ h hlambda hab

/-- Add a public scalar offset to every matrix entry. -/
def shiftMatrix (c : ℝ) (A : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => c + A i j

/-
Uniformly shifting all edge weights shifts a tropical eigenvalue by the same
    amount while preserving its eigenvector.
-/
theorem eigenpair_shiftMatrix
    (A : Matrix (Fin n) (Fin n) ℝ) (lambda c : ℝ) (v : Fin n → ℝ)
    (h : IsEigenpair A lambda v) :
    IsEigenpair (shiftMatrix c A) (c + lambda) v := by
  intro i;
  -- By definition of minPlusAct, we have:
  have h_minPlusAct : minPlusAct (shiftMatrix c A) v i = c + minPlusAct A v i := by
    unfold minPlusAct;
    simp +decide [ shiftMatrix, add_assoc ];
    refine' le_antisymm _ _ <;> simp +decide;
    · simpa using Finset.exists_min_image Finset.univ ( fun j => A i j + v j ) ⟨ i, Finset.mem_univ i ⟩;
    · exact fun j => ⟨ j, le_rfl ⟩;
  linarith [ h i ]

/-
Except for the unique offset `c = -λ`, uniform scalar shifting makes the
    positive-power map injective.
-/
theorem shifted_positivePower_injective
    (A : Matrix (Fin n) (Fin n) ℝ) (lambda c : ℝ) (v : Fin n → ℝ)
    (h : IsEigenpair A lambda v) (hc : c + lambda ≠ 0) :
    Function.Injective (positivePower (shiftMatrix c A)) := by
  -- Apply the positivePower_injective_of_nonzero_eigenvalue theorem to the shifted matrix with eigenvalue c+lambda and vector v.
  intros a b hab;
  convert positivePower_injective_of_nonzero_eigenvalue _ _ _ _ _ hab;
  exacts [ c + lambda, v, eigenpair_shiftMatrix A lambda c v h, hc ]

end

end TropicalCryptography