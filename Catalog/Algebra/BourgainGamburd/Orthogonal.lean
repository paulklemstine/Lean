import Mathlib
import BourgainGamburd.Convolution
import BourgainGamburd.SpectralGap
import BourgainGamburd.Machine

/-!
# Orthogonal Group Specialization of the Bourgain–Gamburd Machine

This file specializes the abstract Bourgain–Gamburd expansion machine
to finite orthogonal groups. We define:

- Orthogonal groups over `ZMod p` as matrix groups preserving a quadratic form
- Structured subgroup families for orthogonal geometry
- Concrete generating sets (signed permutations, reflections)
- The spectral gap theorem for orthogonal Cayley graphs

## Main results

- `orthogonal_structured_family` : the structured family for orthogonal groups
- `spectral_gap_orthogonal` : spectral gap from escape + growth in orthogonal setting

## Mathematical context

The Bourgain–Gamburd machine for orthogonal groups over finite fields is a
natural extension of the SL₂ theory. The key geometric input is:
- Structured subgroups = stabilizers of isotropic subspaces, coordinate planes
- Escape = random walks in generators avoid concentrating on these stabilizers
- Product growth = the Helfgott-type growth theorem for orthogonal groups

This connects expander graph theory to the geometry of quadratic forms
over finite fields.
-/

namespace OrthogonalBourgainGamburd

open Finset BigOperators FiniteGroupConvolution SpectralGapTheory BourgainGamburdMachine
open Matrix

/-! ### Orthogonal group over ZMod p -/

/-- A matrix preserves a symmetric bilinear form represented by the Gram matrix `Q`:
  `MᵀQM = Q`. We work with `ZMod p` entries. -/
def PreservesForm {n : ℕ} (Q : Matrix (Fin n) (Fin n) (ZMod p))
    (M : Matrix (Fin n) (Fin n) (ZMod p)) : Prop :=
  M.transpose * Q * M = Q

/-- The finite orthogonal group `O(Q, 𝔽_p)` as a set of matrices. -/
def orthogonalGroupSet {n : ℕ} (p : ℕ) [Fact p.Prime]
    (Q : Matrix (Fin n) (Fin n) (ZMod p)) :
    Set (Matrix (Fin n) (Fin n) (ZMod p)) :=
  { M | PreservesForm Q M ∧ M.det ≠ 0 }

/-- The standard quadratic form (identity Gram matrix). -/
noncomputable def standardForm (n : ℕ) (p : ℕ) : Matrix (Fin n) (Fin n) (ZMod p) :=
  (1 : Matrix (Fin n) (Fin n) (ZMod p))

/-- A signed permutation matrix: a matrix with exactly one nonzero entry (±1)
in each row and column. These generate the hyperoctahedral group. -/
def IsSignedPermutation {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  ∃ (σ : Equiv.Perm (Fin n)) (signs : Fin n → ℤ),
    (∀ i, signs i = 1 ∨ signs i = -1) ∧
    ∀ i j, M i j = if σ i = j then signs i else 0

/-
The hyperoctahedral group of signed permutation matrices preserves
the standard quadratic form (the identity matrix).
-/
theorem signedPerm_preserves_standard {n : ℕ}
    (M : Matrix (Fin n) (Fin n) ℤ) (hM : IsSignedPermutation M) :
    M.transpose * M = 1 := by
  obtain ⟨ σ, signs, h₁, h₂ ⟩ := hM; ext i j; simp +decide [ h₂, Matrix.mul_apply ] ;
  rw [ Finset.sum_eq_single ( σ.symm j ) ] <;> simp +decide [ *, Function.Injective.eq_iff σ.injective ];
  · cases h₁ ( σ.symm j ) <;> simp +decide [ * ];
    · simp +decide [ Matrix.one_apply, eq_comm ];
    · simp +decide [ Matrix.one_apply, eq_comm ];
  · exact fun k hk₁ hk₂ hk₃ => False.elim <| hk₁ <| σ.symm_apply_apply k ▸ hk₂ ▸ rfl

/-! ### Structured subgroup family for orthogonal groups -/

/-- In the orthogonal setting, a subgroup is "structured" if it is
contained in one of the natural geometric subgroups:
- stabilizers of coordinate subspaces
- stabilizers of isotropic lines
- block-diagonal subgroups

For the formalization, we use a simplified version: a subgroup is structured
if it is a proper subgroup. This is the most general escape hypothesis. -/
noncomputable def orthogonalStructuredFamily (G : Type*) [Group G] :
    StructuredFamily G where
  isStructured := fun H => H ≠ ⊤
  top_not_structured := fun h => h rfl

/-! ### Spectral gap for orthogonal groups -/

/-- **Spectral gap for finite orthogonal groups**: Given a finite group `G`
(intended to be an orthogonal group over `𝔽_p`), a symmetric generating set,
escape from all proper subgroups, and product growth, there exists a
positive spectral gap.

This instantiates the abstract Bourgain–Gamburd machine with the
orthogonal structured family. -/
theorem spectral_gap_orthogonal
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G)
    (ε δ κ η : ℝ)
    (hε : 0 < ε) (hδ : 0 < δ) (hκ : 0 < κ) (hη : 0 < η)
    (hS_symm : SymmetricSet S)
    (hS_gen : IsGenerating S)
    (hS_nonempty : S.Nonempty)
    (h_escape : EscapesStructuredFamily (genSetMeasure S)
      (orthogonalStructuredFamily G) κ)
    (h_growth : ProductGrowth (orthogonalStructuredFamily G) ε δ η) :
    ∃ gap : ℝ, 0 < gap ∧ HasSpectralGap S gap :=
  bourgain_gamburd_spectral_gap S (orthogonalStructuredFamily G)
    ε δ κ η hε hδ hκ hη hS_symm hS_gen hS_nonempty h_escape h_growth

/-! ### Cross-domain bridge: spectral smoothing -/

/-- The spectral gap of an expander Cayley graph implies that the averaging
operator is a contraction on mean-zero functions. This is the bridge
between spectral expansion and smoothing/robustness properties. -/
theorem averaging_contracts_mean_zero
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (gap : ℝ) (_hgap : 0 < gap)
    (hsgap : HasSpectralGap S gap)
    (f : G → ℝ) (hf : MeanZero f) :
    dirichletForm S f ≥ gap * l2NormSq f :=
  hsgap f hf

end OrthogonalBourgainGamburd