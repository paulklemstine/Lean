import Mathlib

/-!
# Charge-Reversal Symmetry for Tropical Matrices

This file establishes a **charge-reversal involution theorem**: reversing the charge
parameter `q ↦ -q` in the charged weight of a matrix is equivalent to transposing
the underlying data. This is a tropical analogue of charge conjugation symmetry
(CPT-like duality) relating positive-charge and negative-charge tropical geometries.

## Main definitions

* `chargedWeight W A q` — A charged deformation of a weight matrix `W` by an
  antisymmetrized perturbation from `A`, controlled by charge parameter `q`.
  Defined as `(chargedWeight W A q) i j = W i j + q * (A i j - A j i)`.

* `tropMatDist M N` — The tropical (L∞) distance between matrices, defined as
  the supremum over entries of `|M i j - N i j|`.

## Main results

* `chargedWeight_neg_eq_transpose` — The core structural theorem:
  `(chargedWeight W A q)ᵀ = chargedWeight Wᵀ A (-q)`.

* `chargedWeight_symm_neg_eq_transpose` — When `W` is symmetric:
  `(chargedWeight W A q)ᵀ = chargedWeight W A (-q)`.

* `chargedWeight_neg_neg` — Charge reversal is an involution.

* `tropMatDist_transpose_invariant` — Tropical distance is transpose-invariant.

* `tropMatDist_charge_reversal` — Charge reversal preserves tropical distances.

## Cross-domain significance

This is the tropical analogue of:
- **Charge conjugation** in physics (particle ↔ antiparticle)
- **Primal/dual exchange** in optimization
- **Edge reversal** in directed graph theory
- **Adjoint/transpose duality** in spectral theory
-/

open Matrix Finset

noncomputable section

variable {n : ℕ}

/-! ## Section 1: Charged Weight Definition -/

/-- The **charged weight matrix**: deforms a base weight `W` by an antisymmetrized
perturbation from `A`, controlled by charge `q`. The antisymmetrization
`A i j - A j i` ensures the perturbation reverses sign under transpose,
which is the key property enabling charge-reversal symmetry. -/
def chargedWeight (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => W i j + q * (A i j - A j i)

/-! ## Section 2: Core Charge-Reversal Theorems -/

/-- Entrywise formula for charged weight. -/
@[simp]
theorem chargedWeight_apply (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ)
    (i j : Fin n) :
    chargedWeight W A q i j = W i j + q * (A i j - A j i) := rfl

/-
**Core structural theorem**: Transposing a charged weight is equivalent to
reversing the charge on the transposed base weight.

  `(chargedWeight W A q)ᵀ = chargedWeight Wᵀ A (-q)`
-/
theorem chargedWeight_neg_eq_transpose
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) :
    (chargedWeight W A q)ᵀ = chargedWeight Wᵀ A (-q) := by
  ext i j; simp +decide [ chargedWeight ] ; ring;

/-
When the base weight `W` is symmetric,
charge reversal is exactly transpose.

  `(chargedWeight W A q)ᵀ = chargedWeight W A (-q)`
-/
theorem chargedWeight_symm_neg_eq_transpose
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ)
    (hW : W.IsSymm) :
    (chargedWeight W A q)ᵀ = chargedWeight W A (-q) := by
  convert chargedWeight_neg_eq_transpose W A q using 2 ; ext i j ; simp +decide;
  exact hW.apply i j ▸ rfl

/-
Negating charge twice returns the original.
-/
theorem chargedWeight_neg_neg
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) :
    chargedWeight W A (-(-q)) = chargedWeight W A q := by
  norm_num [ chargedWeight ]

/-
At charge zero, the charged weight equals the base weight.
-/
theorem chargedWeight_zero
    (W A : Matrix (Fin n) (Fin n) ℝ) :
    chargedWeight W A 0 = W := by
  exact funext fun i => funext fun j => by simp +decide [ chargedWeight ] ;

/-
The combined "transpose then negate charge" is an involution
when `W` is symmetric.
-/
theorem chargedWeight_transpose_transpose_involution
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (hW : W.IsSymm) :
    (chargedWeight W A (-q))ᵀ = chargedWeight W A q := by
  grind +suggestions

/-
Linearity in charge parameter.
-/
theorem chargedWeight_add_charge
    (W A : Matrix (Fin n) (Fin n) ℝ) (q₁ q₂ : ℝ) :
    chargedWeight W A (q₁ + q₂) =
      chargedWeight W A q₁ + chargedWeight (0 : Matrix _ _ ℝ) A q₂ := by
  exact funext fun i => funext fun j => by unfold chargedWeight; simp +decide ; ring;

/-
Scaling the charge parameter.
-/
theorem chargedWeight_smul_charge
    (W A : Matrix (Fin n) (Fin n) ℝ) (c q : ℝ) :
    chargedWeight W A (c * q) =
      W + c • (chargedWeight (0 : Matrix _ _ ℝ) A q) := by
  -- By definition of charged weight, we expand both sides.
  ext i j
  simp [chargedWeight, Matrix.add_apply, Matrix.smul_apply];
  ring

/-
Edge reversal: swapping indices equals charge reversal on transposed base.
-/
theorem chargedWeight_reverse_edges
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (i j : Fin n) :
    chargedWeight W A q j i = chargedWeight Wᵀ A (-q) i j := by
  unfold chargedWeight; norm_num;
  ring

/-! ## Section 3: Tropical Distance -/

/-- The **tropical matrix distance** (L∞ / Chebyshev distance on matrix entries). -/
def tropMatDist (M N : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) : ℝ :=
  Finset.sup' (univ ×ˢ univ)
    (univ_nonempty.product univ_nonempty)
    (fun p => |M p.1 p.2 - N p.1 p.2|)

/-
Tropical distance is symmetric.
-/
theorem tropMatDist_symm (M N : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    tropMatDist M N = tropMatDist N M := by
  unfold tropMatDist;
  grind +revert

/-
**Tropical distance is transpose-invariant**.
-/
theorem tropMatDist_transpose_invariant
    (M N : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    tropMatDist Mᵀ Nᵀ = tropMatDist M N := by
  unfold tropMatDist;
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) ( Finset.sup'_le _ _ _ );
  · aesop;
  · simp +zetaDelta at *;
    exact fun a b => ⟨ b, a, by rw [ abs_sub_comm ] ⟩

/-! ## Section 4: Charge-Reversal Distance Theorems -/

/-
**General charge-reversal distance**: distances relate via transpose of base.
-/
theorem tropMatDist_charge_reversal_general
    (W A B : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) (q : ℝ) :
    tropMatDist (chargedWeight Wᵀ A (-q)) (chargedWeight Wᵀ B (-q))
      = tropMatDist (chargedWeight W A q) (chargedWeight W B q) := by
  grind +locals

/-
**Symmetric base charge-reversal distance**: when `W` is symmetric,
charge reversal preserves tropical distances exactly.
-/
theorem tropMatDist_charge_reversal
    (W A B : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) (q : ℝ) (_hW : W.IsSymm) :
    tropMatDist (chargedWeight W A (-q)) (chargedWeight W B (-q))
      = tropMatDist (chargedWeight W A q) (chargedWeight W B q) := by
  grind +locals

/-! ## Section 5: Spectral Corollary -/

/-- The tropical spectral radius (maximum diagonal entry). -/
def tropSpecRadius (M : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) : ℝ :=
  Finset.sup' univ univ_nonempty (fun i => M i i)

/-
Transpose preserves the tropical spectral radius (diagonal is unchanged).
-/
theorem tropSpecRadius_transpose
    (M : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    tropSpecRadius Mᵀ = tropSpecRadius M := by
  exact Real.ext_cauchy rfl

/-
**Spectral corollary**: For symmetric `W`, the tropical spectral radius
is invariant under charge reversal.

The key insight is that the diagonal entries of a charged weight matrix
satisfy `chargedWeight W A q i i = W i i` (since `A i i - A i i = 0`),
so the spectral radius does not depend on `q` at all.
-/
theorem tropSpecRadius_charge_reversal
    (W A : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) (q : ℝ) :
    tropSpecRadius (chargedWeight W A (-q)) = tropSpecRadius (chargedWeight W A q) := by
  unfold tropSpecRadius chargedWeight;
  grind

/-
The diagonal of a charged weight matrix equals the diagonal of the base.
-/
theorem chargedWeight_diag
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (i : Fin n) :
    chargedWeight W A q i i = W i i := by
  grind +locals

/-
The tropical spectral radius of a charged weight equals that of the base.
-/
theorem tropSpecRadius_chargedWeight_eq_base
    (W A : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) (q : ℝ) :
    tropSpecRadius (chargedWeight W A q) = tropSpecRadius W := by
  grind +locals

end