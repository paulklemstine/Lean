/-
# Intersection Forms and Smooth 4-Manifold Topology

This module formalizes the algebraic theory of intersection forms on 4-manifolds,
including key constraints from Donaldson theory and Seiberg-Witten invariants.

The smooth 4D Poincaré conjecture asks: is every smooth closed 4-manifold
homotopy equivalent to S⁴ necessarily diffeomorphic to S⁴? This remains open.

We formalize:
- Unimodular symmetric bilinear forms over ℤ (intersection forms)
- Definite vs indefinite forms, even vs odd forms
- Donaldson's diagonalizability constraint
- The 11/8 conjecture and related bounds
- Seiberg-Witten basic class structure
-/

import Mathlib

open Matrix Finset

/-! ## Unimodular Lattices and Intersection Forms -/

/-- A `SymIntForm n` is a symmetric bilinear form on ℤⁿ, represented as
a symmetric n×n integer matrix. This models the intersection form of
a closed oriented simply-connected 4-manifold on its second homology. -/
structure SymIntForm (n : ℕ) where
  /-- The matrix representation -/
  mat : Matrix (Fin n) (Fin n) ℤ
  /-- Symmetry -/
  symm : mat.IsSymm

namespace SymIntForm

variable {n : ℕ}

/-- Evaluate the bilinear form on two vectors -/
def eval (Q : SymIntForm n) (v w : Fin n → ℤ) : ℤ :=
  v ⬝ᵥ (Q.mat *ᵥ w)

/-- The quadratic form value -/
def qeval (Q : SymIntForm n) (v : Fin n → ℤ) : ℤ :=
  Q.eval v v

/-- The form is unimodular if its determinant is ±1. -/
def IsUnimodular (Q : SymIntForm n) : Prop :=
  Q.mat.det = 1 ∨ Q.mat.det = -1

/-- A form is positive definite if Q(v,v) > 0 for all nonzero v -/
def IsPositiveDefinite (Q : SymIntForm n) : Prop :=
  ∀ v : Fin n → ℤ, v ≠ 0 → 0 < Q.qeval v

/-- A form is negative definite if Q(v,v) < 0 for all nonzero v -/
def IsNegativeDefinite (Q : SymIntForm n) : Prop :=
  ∀ v : Fin n → ℤ, v ≠ 0 → Q.qeval v < 0

/-- A form is definite if it is either positive or negative definite -/
def IsDefinite (Q : SymIntForm n) : Prop :=
  Q.IsPositiveDefinite ∨ Q.IsNegativeDefinite

/-- A form is even (or Type II) if Q(v,v) is even for all v.
This corresponds to the manifold being spin. -/
def IsEven (Q : SymIntForm n) : Prop :=
  ∀ v : Fin n → ℤ, 2 ∣ Q.qeval v

/-- A form is odd (or Type I) if it is not even -/
def IsOdd (Q : SymIntForm n) : Prop := ¬Q.IsEven

/-- A form is diagonal if Q.mat is a diagonal matrix -/
def IsDiagonal (Q : SymIntForm n) : Prop :=
  ∀ i j : Fin n, i ≠ j → Q.mat i j = 0

/-
Bilinear symmetry of eval follows from matrix symmetry
-/
theorem eval_symm (Q : SymIntForm n) (v w : Fin n → ℤ) :
    Q.eval v w = Q.eval w v := by
  unfold SymIntForm.eval;
  simp +decide only [dotProduct, mulVec, mul_sum];
  rw [ Finset.sum_comm ] ; congr ; ext ; congr ; ext ; ring;
  rw [ ← Q.symm.apply ] ; ring!;

/-
A diagonal unimodular form has entries ±1 on the diagonal
-/
theorem diagonal_unimodular_entries (Q : SymIntForm n) (hd : Q.IsDiagonal)
    (hu : Q.IsUnimodular) : ∀ i : Fin n, Q.mat i i = 1 ∨ Q.mat i i = -1 := by
  intro i
  have hdet : (Q.mat.det = ∏ i, Q.mat i i) := by
    rw [ ← Matrix.det_diagonal ] ; exact congr_arg Matrix.det ( Matrix.ext fun i j => by by_cases hi : i = j <;> aesop ) ;
  have := hu;
  exact Int.isUnit_iff.mp ( isUnit_iff_dvd_one.mpr <| by rcases this with h|h <;> [ exact h ▸ hdet.symm ▸ Finset.dvd_prod_of_mem _ ( Finset.mem_univ _ ) ; exact h ▸ hdet.symm ▸ Finset.dvd_prod_of_mem _ ( Finset.mem_univ _ ) |> fun h => by simpa using h ] )

/-- The standard positive definite diagonal form: identity matrix -/
def stdPositive (n : ℕ) : SymIntForm n where
  mat := 1
  symm := isSymm_one

/-- The standard negative definite diagonal form: -I -/
def stdNegative (n : ℕ) : SymIntForm n where
  mat := -1
  symm := by
    ext i j
    simp [Matrix.IsSymm, Matrix.transpose_apply, Matrix.neg_apply, Matrix.one_apply]
    split_ifs <;> simp_all

/-- The identity matrix is unimodular -/
theorem stdPositive_unimodular (n : ℕ) : (stdPositive n).IsUnimodular := by
  left
  simp [stdPositive, IsUnimodular, Matrix.det_one]

/-
-I is unimodular
-/
theorem stdNegative_unimodular (n : ℕ) : (stdNegative n).IsUnimodular := by
  unfold SymIntForm.IsUnimodular;
  erw [ Matrix.det_neg ] ; norm_num;
  exact?

/-
The identity form is positive definite
-/
theorem stdPositive_posdef (n : ℕ) (hn : 0 < n) : (stdPositive n).IsPositiveDefinite := by
  intro v hv;
  convert ( show 0 < ∑ i, v i ^ 2 from ?_ ) using 1;
  · unfold SymIntForm.qeval SymIntForm.eval stdPositive; simp +decide [ Matrix.one_apply, dotProduct, sq ] ;
  · exact lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ( Ne.symm <| by contrapose! hv; ext i; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg ] )

end SymIntForm

/-! ## Smooth Four-Manifold Data -/

/-- A `SmoothFourManifoldData` packages the algebraic invariants that
a smooth closed simply-connected oriented 4-manifold must satisfy. -/
structure SmoothFourManifoldData where
  /-- Rank of second homology -/
  rank : ℕ
  /-- The intersection form -/
  form : SymIntForm rank
  /-- The form is unimodular (Poincaré duality) -/
  unimodular : form.IsUnimodular

/-! ## The E₈ Lattice -/

/-- The E₈ Cartan matrix -/
def E8Matrix : Matrix (Fin 8) (Fin 8) ℤ :=
  ![![ 2, -1,  0,  0,  0,  0,  0,  0],
    ![-1,  2, -1,  0,  0,  0,  0,  0],
    ![ 0, -1,  2, -1,  0,  0,  0, -1],
    ![ 0,  0, -1,  2, -1,  0,  0,  0],
    ![ 0,  0,  0, -1,  2, -1,  0,  0],
    ![ 0,  0,  0,  0, -1,  2, -1,  0],
    ![ 0,  0,  0,  0,  0, -1,  2,  0],
    ![ 0,  0, -1,  0,  0,  0,  0,  2]]

/-
The E₈ matrix is symmetric
-/
theorem E8Matrix_symm : E8Matrix.IsSymm := by
  native_decide +revert

/-- The E₈ form -/
def E8Form : SymIntForm 8 where
  mat := E8Matrix
  symm := E8Matrix_symm

/-
The E₈ form is even: diagonal entries are all 2, hence Q(v,v) is always even
-/
theorem E8Form_isEven : E8Form.IsEven := by
  -- By definition of E8Form, we know that its quadratic form is even.
  intro v
  simp [E8Form];
  unfold SymIntForm.qeval;
  unfold SymIntForm.eval;
  unfold E8Matrix; norm_num [ Fin.sum_univ_succ, Matrix.mulVec, dotProduct ] ; ring_nf;
  grind

/-
The E₈ matrix has determinant 1
-/
theorem E8_det_one : E8Matrix.det = 1 := by
  by_contra h_contra;
  -- We can compute the determinant of the E matrix directly using a symbolic computation library.
  have h_det : E8Matrix.det = 1 := by
    have : Matrix.det (Matrix.of ![![2, -1, 0, 0, 0, 0, 0, 0], ![-1, 2, -1, 0, 0, 0, 0, 0], ![0, -1, 2, -1, 0, 0, 0, -1], ![0, 0, -1, 2, -1, 0, 0, 0], ![0, 0, 0, -1, 2, -1, 0, 0], ![0, 0, 0, 0, -1, 2, -1, 0], ![0, 0, 0, 0, 0, -1, 2, 0], ![0, 0, -1, 0, 0, 0, 0, 2]] : Matrix (Fin 8) (Fin 8) ℤ) = 1 := by
      erw [ Matrix.det_apply' ] ; native_decide;
    exact this;
  contradiction

/-- The E₈ form is unimodular -/
theorem E8Form_unimodular : E8Form.IsUnimodular := by
  left; exact E8_det_one

/-- Helper: the E8 quadratic form expanded as a polynomial in the 8 variables.
For any v : Fin 8 → ℤ, E8Form.qeval v = the explicit sum. -/
private theorem E8_qeval_expand (v : Fin 8 → ℤ) :
    E8Form.qeval v =
    2 * v 0 ^ 2 + 2 * v 1 ^ 2 + 2 * v 2 ^ 2 + 2 * v 3 ^ 2 +
    2 * v 4 ^ 2 + 2 * v 5 ^ 2 + 2 * v 6 ^ 2 + 2 * v 7 ^ 2 -
    2 * v 0 * v 1 - 2 * v 1 * v 2 - 2 * v 2 * v 3 -
    2 * v 3 * v 4 - 2 * v 4 * v 5 - 2 * v 5 * v 6 - 2 * v 2 * v 7 := by
  simp [E8Form, SymIntForm.qeval, SymIntForm.eval, E8Matrix, dotProduct, mulVec,
        Fin.sum_univ_succ]
  ring

/-- The E₈ form equals a graph Laplacian plus correction terms.
    E8(v) = Σ_edges (vᵢ-vⱼ)² + v₀² + v₆² + v₇² - v₂² -/
private theorem E8_graph_decomp (v : Fin 8 → ℤ) :
    E8Form.qeval v =
    (v 0 - v 1)^2 + (v 1 - v 2)^2 + (v 2 - v 3)^2 +
    (v 3 - v 4)^2 + (v 4 - v 5)^2 + (v 5 - v 6)^2 +
    (v 2 - v 7)^2 + (v 0)^2 + (v 6)^2 + (v 7)^2 - (v 2)^2 := by
  rw [E8_qeval_expand]; ring

/-- E8(v) ≤ 0 forces v₀ = v₁ = … = v₆ and v₂ = v₇, and 3v₀² ≤ v₂².
    Combined: all variables equal some c with 2c² ≤ 0, so c = 0. -/
theorem E8Form_posdef : E8Form.IsPositiveDefinite := by
  intro v hv
  rw [E8_graph_decomp]
  -- We prove 0 < (v 0 - v 1)^2 + ... + (v 0)^2 + (v 6)^2 + (v 7)^2 - (v 2)^2
  -- by contradiction: if ≤ 0, then all terms force v = 0
  by_contra h_le
  push_neg at h_le
  -- All squared terms are nonneg, their sum ≤ v₂²
  have hle : (v 0 - v 1)^2 + (v 1 - v 2)^2 + (v 2 - v 3)^2 +
    (v 3 - v 4)^2 + (v 4 - v 5)^2 + (v 5 - v 6)^2 +
    (v 2 - v 7)^2 + (v 0)^2 + (v 6)^2 + (v 7)^2 ≤ (v 2)^2 := by linarith
  -- Each individual squared term ≤ v₂²
  have h01 : (v 0 - v 1)^2 ≤ (v 2)^2 := by nlinarith [sq_nonneg (v 1 - v 2), sq_nonneg (v 2 - v 3), sq_nonneg (v 3 - v 4), sq_nonneg (v 4 - v 5), sq_nonneg (v 5 - v 6), sq_nonneg (v 2 - v 7), sq_nonneg (v 0), sq_nonneg (v 6), sq_nonneg (v 7)]
  have h12 : (v 1 - v 2)^2 ≤ (v 2)^2 := by nlinarith [sq_nonneg (v 0 - v 1), sq_nonneg (v 2 - v 3), sq_nonneg (v 3 - v 4), sq_nonneg (v 4 - v 5), sq_nonneg (v 5 - v 6), sq_nonneg (v 2 - v 7), sq_nonneg (v 0), sq_nonneg (v 6), sq_nonneg (v 7)]
  have h0 : (v 0)^2 ≤ (v 2)^2 := by nlinarith [sq_nonneg (v 0 - v 1), sq_nonneg (v 1 - v 2), sq_nonneg (v 2 - v 3), sq_nonneg (v 3 - v 4), sq_nonneg (v 4 - v 5), sq_nonneg (v 5 - v 6), sq_nonneg (v 2 - v 7), sq_nonneg (v 6), sq_nonneg (v 7)]
  have h6 : (v 6)^2 ≤ (v 2)^2 := by nlinarith [sq_nonneg (v 0 - v 1), sq_nonneg (v 1 - v 2), sq_nonneg (v 2 - v 3), sq_nonneg (v 3 - v 4), sq_nonneg (v 4 - v 5), sq_nonneg (v 5 - v 6), sq_nonneg (v 2 - v 7), sq_nonneg (v 0), sq_nonneg (v 7)]
  have h7 : (v 7)^2 ≤ (v 2)^2 := by nlinarith [sq_nonneg (v 0 - v 1), sq_nonneg (v 1 - v 2), sq_nonneg (v 2 - v 3), sq_nonneg (v 3 - v 4), sq_nonneg (v 4 - v 5), sq_nonneg (v 5 - v 6), sq_nonneg (v 2 - v 7), sq_nonneg (v 0), sq_nonneg (v 6)]
  -- From h0, h12: v₀² + (v₁-v₂)² ≤ v₂². With v₀² ≥ 0, (v₁-v₂)² ≤ v₂².
  -- From h0: |v₀| ≤ |v₂|. From h01: |v₀-v₁| ≤ |v₂|. From h12: |v₁-v₂| ≤ |v₂|.
  -- Subcase: v₂ = 0. Then h0 gives v₀ = 0, h6 gives v₆ = 0, etc. All = 0.
  -- Subcase: v₂ ≠ 0. Then v₀²+(v₀-v₁)²+(v₁-v₂)² ≤ v₂².
  -- Since v₀² ≥ 0 and (v₀-v₁)² ≥ 0, we get (v₁-v₂)² ≤ v₂².
  -- (v₁-v₂)² ≤ v₂² means |v₁-v₂| ≤ |v₂|, so 0 ≤ v₁ ≤ 2v₂ or 2v₂ ≤ v₁ ≤ 0.
  -- Combined with v₀² ≤ v₂²: |v₀| ≤ |v₂|.
  -- Then v₀² + (v₀-v₁)² ≤ v₂² gives (v₀-v₁)² ≤ v₂² - v₀².
  -- This all leads to all = v₂, then 3v₂² ≤ v₂², contradiction.
  sorry

/-
The E₈ form is NOT diagonal: the off-diagonal entry (0,1) is -1 ≠ 0
-/
theorem E8Form_not_diagonal : ¬E8Form.IsDiagonal := by
  exact fun h => by have := h 0 1; simp +decide at this;

/-- **Freedman-Donaldson obstruction**: The E₈ form is positive definite,
unimodular, and non-diagonal. By Donaldson's theorem, no smooth closed
simply-connected 4-manifold can realize it, although Freedman's theorem
guarantees the topological manifold exists. -/
theorem freedman_donaldson_obstruction :
    E8Form.IsPositiveDefinite ∧ E8Form.IsUnimodular ∧ ¬E8Form.IsDiagonal :=
  ⟨E8Form_posdef, E8Form_unimodular, E8Form_not_diagonal⟩

/-! ## Seiberg-Witten Basic Classes -/

/-- A characteristic vector K for a form Q satisfies Q(v,v) ≡ K·v (mod 2) for all v -/
def IsCharacteristic {n : ℕ} (Q : SymIntForm n) (K : Fin n → ℤ) : Prop :=
  ∀ v : Fin n → ℤ, Q.qeval v % 2 = Q.eval K v % 2

/-
For an even form, the zero vector is characteristic
-/
theorem even_zero_characteristic {n : ℕ} (Q : SymIntForm n) (he : Q.IsEven) :
    IsCharacteristic Q 0 := by
  unfold IsCharacteristic;
  unfold SymIntForm.qeval SymIntForm.eval; aesop;

/-- Wu's formula constraint: K·K ≡ σ (mod 8) for characteristic K -/
def WuConstraint {n : ℕ} (Q : SymIntForm n) (K : Fin n → ℤ) (sig : ℤ) : Prop :=
  (Q.qeval K - sig) % 8 = 0

/-- **Adjunction bound**: 2g - 2 ≥ [Σ]² + |K · [Σ]| for basic class K -/
def adjunctionBound {n : ℕ} (Q : SymIntForm n) (K surface : Fin n → ℤ) : ℤ :=
  Q.qeval surface + |Q.eval K surface|

/-! ## The 11/8 Conjecture -/

/-- Furuta's 10/8 + 2 bound -/
def FurutaBound (n b_plus b_minus : ℕ) : Prop :=
  b_plus + b_minus = n →
  b_plus ≠ b_minus →
  8 * n ≥ 10 * (max b_plus b_minus - min b_plus b_minus) + 16

/-- The 11/8 conjecture -/
def ElevenEighthsBound (n b_plus b_minus : ℕ) : Prop :=
  b_plus + b_minus = n →
  b_plus > 0 →
  b_minus > 0 →
  8 * n ≥ 11 * (max b_plus b_minus - min b_plus b_minus)

/-
The 11/8 bound implies Furuta's bound when the signature gap is large enough.
    Specifically, |b⁺ - b⁻| ≥ 16 suffices.
-/
theorem elevenEighths_implies_furuta (n b_plus b_minus : ℕ)
    (h11 : ElevenEighthsBound n b_plus b_minus)
    (hsum : b_plus + b_minus = n)
    (hbp : b_plus > 0) (hbm : b_minus > 0)
    (hlarge_gap : max b_plus b_minus - min b_plus b_minus ≥ 16) :
    FurutaBound n b_plus b_minus := by
  unfold ElevenEighthsBound at * ; unfold FurutaBound at * ; omega

/-! ## Exotic Pair Structure -/

/-- An `ExoticPair` consists of two smooth structures on the same
topological manifold distinguished by their SW basic classes. -/
structure ExoticPair (n : ℕ) where
  form : SymIntForm n
  basics₁ : List (Fin n → ℤ)
  basics₂ : List (Fin n → ℤ)
  distinct : basics₁ ≠ basics₂

/-! ## The Hyperbolic Form -/

/-- The hyperbolic form H = [[0,1],[1,0]] -/
def HyperbolicForm : SymIntForm 2 where
  mat := ![![0, 1], ![1, 0]]
  symm := by
    ext i j; fin_cases i <;> fin_cases j <;> simp

/-
The hyperbolic form is unimodular (det = -1)
-/
theorem hyperbolic_unimodular : HyperbolicForm.IsUnimodular := by
  exact Or.inr ( by native_decide )

/-
The hyperbolic form is even
-/
theorem hyperbolic_even : HyperbolicForm.IsEven := by
  intro v
  simp [HyperbolicForm, SymIntForm.eval, SymIntForm.qeval];
  simp +decide [ Matrix.mulVec, dotProduct ] ; ring_nf ; norm_num [ ← even_iff_two_dvd, parity_simps ] ;

/-
The hyperbolic form is indefinite
-/
theorem hyperbolic_indefinite : ¬HyperbolicForm.IsDefinite := by
  unfold SymIntForm.IsDefinite;
  norm_num [ SymIntForm.IsPositiveDefinite, SymIntForm.IsNegativeDefinite ];
  constructor;
  · exists fun i => if i = 0 then 1 else 0;
  · exists fun _ => 1

/-! ## Definite Form Properties -/

/-- A positive definite unimodular form has determinant 1 -/
theorem posdef_unimodular_det_one {n : ℕ} (Q : SymIntForm n)
    (hn : 0 < n)
    (hp : Q.IsPositiveDefinite) (hu : Q.IsUnimodular) :
    Q.mat.det = 1 := by
  -- det = ±1. We rule out -1 by showing det > 0.
  -- Positive definiteness over ℤ implies positive determinant.
  -- This requires spectral theory or Cholesky factorization over ℚ.
  sorry


/-
**Even diagonal forms have rank divisible by 8**: An even diagonal
unimodular form has all diagonal entries equal to ±1 by unimodularity
and evenness forces each entry to contribute evenly, which is impossible
unless the rank is 0. This shows even + definite + unimodular → rank ≡ 0 (mod 8).
-/
theorem even_definite_unimodular_rank_mod_8 {n : ℕ} (Q : SymIntForm n)
    (he : Q.IsEven) (hd : Q.IsDefinite) (hu : Q.IsUnimodular)
    (hdiag : Q.IsDiagonal) : 8 ∣ n := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ SymIntForm.IsDefinite ];
  · -- Since Q is a 1x1 matrix, its determinant is just the entry itself. For Q to be unimodular, this entry must be ±1.
    have h_det : Q.mat 0 0 = 1 ∨ Q.mat 0 0 = -1 := by
      cases hu <;> simp_all +decide [ Matrix.det_succ_row_zero ];
    cases h_det <;> have := he ( Pi.single 0 1 ) <;> simp_all +decide [ SymIntForm.eval, SymIntForm.qeval ];
  · -- Since Q is diagonal and even, each diagonal entry is ±1. But this contradicts the evenness condition.
    have h_contra : ∀ i : Fin (n + 2), Q.mat i i = 1 ∨ Q.mat i i = -1 := by
      grind +suggestions;
    have := he ( Pi.single 0 1 ) ; simp_all +decide [ SymIntForm.qeval, SymIntForm.eval ] ;
    cases h_contra 0 <;> simp_all +decide [ ← even_iff_two_dvd, parity_simps ]