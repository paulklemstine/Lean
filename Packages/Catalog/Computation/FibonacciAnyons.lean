/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Fibonacci anyons: fusion, the F-move, and braid computation

This file builds on the catalog's presented Artin braid group.  It formalizes the
Fibonacci fusion rule `τ ⊗ τ = 𝟙 ⊕ τ`, the two-dimensional fusion-space F-move,
and the algebraic interface turning matrices satisfying the Yang--Baxter equation
into a representation of `B₃`.
-/
import Cryptography.KnotAndBraidTheory.BraidGroup

noncomputable section

open Matrix Complex

namespace FibonacciAnyons

/-- The two simple charges in the Fibonacci theory. -/
inductive Charge where
  | vacuum
  | tau
  deriving DecidableEq, Fintype, Repr

/-- Fusion multiplicity for the Fibonacci theory. -/
def fusionMultiplicity : Charge → Charge → Charge → ℕ
  | .vacuum, b, c => if b = c then 1 else 0
  | a, .vacuum, c => if a = c then 1 else 0
  | .tau, .tau, .vacuum => 1
  | .tau, .tau, .tau => 1

/-- Fusion with vacuum has the original charge as its unique output. -/
theorem fusion_vacuum_unique (a c : Charge) :
    fusionMultiplicity .vacuum a c = 1 ↔ a = c := by
  cases a <;> cases c <;> simp [fusionMultiplicity]

/-- The nontrivial Fibonacci fusion rule has both allowed channels. -/
theorem tau_fusion_channels (c : Charge) :
    fusionMultiplicity .tau .tau c = 1 := by
  cases c <;> simp [fusionMultiplicity]

/-- The golden ratio, the quantum dimension of `τ`. -/
def phi : ℝ := (1 + Real.sqrt 5) / 2

/-- The defining quadratic identity for the Fibonacci quantum dimension. -/
theorem phi_sq : phi ^ 2 = phi + 1 := by
  unfold phi
  nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 5 by norm_num)]

/-- The Fibonacci quantum dimension is irrational. -/
theorem phi_irrational : Irrational phi := by
  exact_mod_cast Nat.Prime.irrational_sqrt (by norm_num) |>
    Irrational.ratCast_add 1 |> Irrational.div_ratCast <| by norm_num

/-- The Fibonacci quantum dimension is strictly positive. -/
theorem phi_pos : 0 < phi := by
  unfold phi
  positivity

/-- The reciprocal identity used to normalize the F-matrix. -/
theorem phi_inv_sq_add_phi_inv : (phi⁻¹) ^ 2 + phi⁻¹ = 1 := by
  have hne : phi ≠ 0 := phi_pos.ne'
  field_simp
  nlinarith [phi_sq]

/-- The positive off-diagonal coefficient of the Fibonacci F-move. -/
def fOff : ℝ := Real.sqrt phi⁻¹

/-- The squared off-diagonal coefficient is `φ⁻¹`. -/
theorem fOff_sq : fOff ^ 2 = phi⁻¹ := by
  unfold fOff
  exact Real.sq_sqrt (inv_nonneg.mpr phi_pos.le)

/-- The Fibonacci F-matrix on the two-dimensional `τττ → τ` fusion space. -/
def fMatrix : Matrix (Fin 2) (Fin 2) ℝ :=
  !![phi⁻¹, fOff;
     fOff, -phi⁻¹]

/-- The Fibonacci F-move is an involution.  In particular it is orthogonal. -/
theorem fMatrix_sq : fMatrix * fMatrix = 1 := by
  have hoff : fOff * fOff = phi⁻¹ := by simpa [pow_two] using fOff_sq
  have hphi : phi⁻¹ * phi⁻¹ + phi⁻¹ = 1 := by
    simpa [pow_two] using phi_inv_sq_add_phi_inv
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [fMatrix, Matrix.mul_apply] <;>
    nlinarith

/-- The determinant of the F-move is `-1`. -/
theorem fMatrix_det : fMatrix.det = -1 := by
  have hoff : fOff * fOff = phi⁻¹ := by simpa [pow_two] using fOff_sq
  have hphi : phi⁻¹ * phi⁻¹ + phi⁻¹ = 1 := by
    simpa [pow_two] using phi_inv_sq_add_phi_inv
  simp [fMatrix, Matrix.det_fin_two]
  nlinarith

/-- Complexification of the real Fibonacci F-matrix. -/
def fMatrixC : Matrix (Fin 2) (Fin 2) ℂ := fMatrix.map (algebraMap ℝ ℂ)

/-- Complexification preserves the involution equation. -/
theorem fMatrixC_sq : fMatrixC * fMatrixC = 1 := by
  change fMatrix.map (algebraMap ℝ ℂ) * fMatrix.map (algebraMap ℝ ℂ) = 1
  rw [← Matrix.map_mul, fMatrix_sq]
  simp

/-- The `R`-phase for two `τ` anyons fusing through vacuum. -/
def rVacuum : ℂ := Complex.exp ((-4 * Real.pi / 5 : ℝ) * Complex.I)

/-- The `R`-phase for two `τ` anyons fusing through `τ`. -/
def rTau : ℂ := Complex.exp ((3 * Real.pi / 5 : ℝ) * Complex.I)

/-- Both Fibonacci braiding eigenvalues are phases. -/
theorem rVacuum_norm : ‖rVacuum‖ = 1 := by
  exact Complex.norm_exp_ofReal_mul_I (-4 * Real.pi / 5)

/-- Both Fibonacci braiding eigenvalues are phases. -/
theorem rTau_norm : ‖rTau‖ = 1 := by
  exact Complex.norm_exp_ofReal_mul_I (3 * Real.pi / 5)

/-- The diagonal Fibonacci R-matrix in the two fusion channels. -/
def rMatrix : Matrix (Fin 2) (Fin 2) ℂ :=
  !![rVacuum, 0;
     0, rTau]

/-- The determinant of the R-matrix is the product of its two phases. -/
theorem rMatrix_det : rMatrix.det = rVacuum * rTau := by
  simp [rMatrix, Matrix.det_fin_two]

/-- An algebraic two-generator gate model for three anyons.  Gates are
invertible matrices, and the sole nontrivial Artin relation for `B₃` is stored
as the Yang--Baxter equation. -/
structure BraidGateModel where
  sigma0 : Matrix.GeneralLinearGroup (Fin 2) ℂ
  sigma1 : Matrix.GeneralLinearGroup (Fin 2) ℂ
  yangBaxter : sigma0 * sigma1 * sigma0 = sigma1 * sigma0 * sigma1

/-- Every two-gate model satisfying Yang--Baxter induces a representation of
`B₃` (the catalog indexes `B_{n+1}` by its `n` Artin generators). -/
noncomputable def BraidGateModel.toBraidRepresentation (M : BraidGateModel) :
    BraidGroup.BraidGrp 2 →* Matrix.GeneralLinearGroup (Fin 2) ℂ :=
  BraidGroup.toGroup_of_braid_rels
    (fun i => if i = (0 : Fin 2) then M.sigma0 else M.sigma1)
    (by intro i j h; fin_cases i <;> fin_cases j <;> omega)
    (by
      intro i hi
      have hi0 : i = (0 : Fin 2) := by omega
      subst i
      simpa using M.yangBaxter)

/-- The induced representation sends the first Artin generator to `sigma0`. -/
theorem toBraidRepresentation_sigma_zero (M : BraidGateModel) :
    M.toBraidRepresentation (BraidGroup.sigma (0 : Fin 2)) = M.sigma0 := by
  simp [BraidGateModel.toBraidRepresentation, BraidGroup.toGroup_of_braid_rels,
    BraidGroup.sigma]

/-- The induced representation sends the second Artin generator to `sigma1`. -/
theorem toBraidRepresentation_sigma_one (M : BraidGateModel) :
    M.toBraidRepresentation (BraidGroup.sigma (1 : Fin 2)) = M.sigma1 := by
  simp [BraidGateModel.toBraidRepresentation, BraidGroup.toGroup_of_braid_rels,
    BraidGroup.sigma]

/-- Density is stated as density of the range of the braid representation in a
chosen topological matrix group.  This predicate avoids conflating density with
mere infinitude or with irrationality of one scalar parameter. -/
def UniversalIn (G : Type*) [TopologicalSpace G]
    (ρ : BraidGroup.BraidGrp 2 → G) : Prop := DenseRange ρ

/-- Universality immediately supplies an approximating braid in every
neighborhood of every target gate. -/
theorem UniversalIn.approximate {G : Type*} [TopologicalSpace G]
    {ρ : BraidGroup.BraidGrp 2 → G} (hρ : UniversalIn G ρ)
    (g : G) {s : Set G} (hs : IsOpen s) (hg : g ∈ s) :
    ∃ b, ρ b ∈ s := by
  exact hρ.exists_mem_open hs ⟨g, hg⟩

end FibonacciAnyons