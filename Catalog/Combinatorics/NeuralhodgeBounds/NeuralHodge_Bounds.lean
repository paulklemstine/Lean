import Shared.NeuralhodgeDefs.NeuralHodge_Defs

/-!
# Neural Hodge theory: energy bounds

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/NeuralHodge/Bounds.lean`.  It is reconstructed here as
the quantitative layer on top of
`Shared.NeuralhodgeDefs.NeuralHodge_Defs`.

Main results:

* `NeuralHodge.dot_laplacian_eq_energy` — the **Dirichlet identity**
  `⟨x, L x⟩ = E(x)`, the discrete integration-by-parts formula;
* `NeuralHodge.energy_nonneg` and `NeuralHodge.laplacian_posSemidef` — the
  Laplacian is positive semidefinite;
* `NeuralHodge.energy_le_two_mul_degree_sum` — the **spectral upper bound**
  `E(x) ≤ 2 ∑ᵢ deg(i) · x(i)²`, whose Rayleigh-quotient form says that every
  Laplacian eigenvalue is at most twice the maximal degree;
* `NeuralHodge.eigenvalue_le_two_mul_maxDegree` — the eigenvalue form of the bound.
-/

namespace NeuralHodge

variable {n : ℕ}

/-! ## Auxiliary double sums -/

/-- `S₁ = ∑ᵢ ∑ⱼ w i j · x(i)²`. -/
private noncomputable def S1 (W : Weights n) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, W.w i j * x i ^ 2

/-- `S₂ = ∑ᵢ ∑ⱼ w i j · x(j)²`. -/
private noncomputable def S2 (W : Weights n) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, W.w i j * x j ^ 2

/-- `S₃ = ∑ᵢ ∑ⱼ w i j · x(i) x(j)`. -/
private noncomputable def S3 (W : Weights n) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, W.w i j * (x i * x j)

/-- Symmetry of the weights identifies the two "square" double sums. -/
private lemma S2_eq_S1 (W : Weights n) (x : Fin n → ℝ) : S2 W x = S1 W x := by
  unfold S1 S2
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  rw [W.w_symm j i]

/-- `S₁` is the degree-weighted square sum. -/
private lemma S1_eq_degree_sum (W : Weights n) (x : Fin n → ℝ) :
    S1 W x = ∑ i, degree W i * x i ^ 2 := by
  unfold S1 degree
  exact Finset.sum_congr rfl fun i _ => by rw [Finset.sum_mul]

/-! ## The Dirichlet identity -/

/-- **Discrete integration by parts.**  `⟨x, L x⟩ = E(x)`. -/
theorem dot_laplacian_eq_energy (W : Weights n) (x : Fin n → ℝ) :
    dot x (laplacian W x) = energy W x := by
  have hdot : dot x (laplacian W x) = S1 W x - S3 W x := by
    unfold dot laplacian S1 S3
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    have h1 : ∑ j, W.w i j * x i ^ 2 = (∑ j, W.w i j) * x i ^ 2 := (Finset.sum_mul ..).symm
    have h2 : ∑ j, W.w i j * (x i * x j) = x i * ∑ j, W.w i j * x j := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun j _ => by ring
    rw [h1, h2, degree]
    ring
  have key : ∑ i, ∑ j, W.w i j * (x i - x j) ^ 2 = S1 W x - 2 * S3 W x + S2 W x := by
    unfold S1 S2 S3
    simp only [Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring
  rw [hdot, energy, key, S2_eq_S1]
  ring

/-! ## Positivity -/

/-- The Dirichlet energy is non-negative. -/
theorem energy_nonneg (W : Weights n) (x : Fin n → ℝ) : 0 ≤ energy W x := by
  unfold energy
  have : (0 : ℝ) ≤ ∑ i, ∑ j, W.w i j * (x i - x j) ^ 2 :=
    Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
      mul_nonneg (W.w_nonneg i j) (sq_nonneg _)
  linarith

/-- **The Laplacian is positive semidefinite.** -/
theorem laplacian_posSemidef (W : Weights n) (x : Fin n → ℝ) : 0 ≤ dot x (laplacian W x) := by
  rw [dot_laplacian_eq_energy]
  exact energy_nonneg W x

/-! ## The upper bound -/

/-- **Spectral upper bound.**  `E(x) ≤ 2 ∑ᵢ deg(i) x(i)²`.  Combined with the
Dirichlet identity this says that the Rayleigh quotient of the Laplacian never
exceeds twice the maximal degree. -/
theorem energy_le_two_mul_degree_sum (W : Weights n) (x : Fin n → ℝ) :
    energy W x ≤ 2 * ∑ i, degree W i * x i ^ 2 := by
  have hpt : ∀ i : Fin n, ∀ j : Fin n,
      W.w i j * (x i - x j) ^ 2 ≤ W.w i j * (2 * x i ^ 2 + 2 * x j ^ 2) := by
    intro i j
    refine mul_le_mul_of_nonneg_left ?_ (W.w_nonneg i j)
    nlinarith [sq_nonneg (x i + x j)]
  have hsum : ∑ i, ∑ j, W.w i j * (x i - x j) ^ 2
      ≤ ∑ i, ∑ j, W.w i j * (2 * x i ^ 2 + 2 * x j ^ 2) :=
    Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => hpt i j
  have hexp : ∑ i, ∑ j, W.w i j * (2 * x i ^ 2 + 2 * x j ^ 2)
      = 2 * S1 W x + 2 * S2 W x := by
    unfold S1 S2
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring
  rw [hexp, S2_eq_S1, S1_eq_degree_sum] at hsum
  unfold energy
  linarith

/-- **Eigenvalue bound.**  If `x` is a Laplacian eigenvector with eigenvalue `μ` and
`x ≠ 0`, then `μ ≤ 2 · maxDegree`. -/
theorem eigenvalue_le_two_mul_maxDegree (W : Weights n) (x : Fin n → ℝ) (mu D : ℝ)
    (heig : ∀ i, laplacian W x i = mu * x i)
    (hD : ∀ i, degree W i ≤ D)
    (hx : 0 < ∑ i, x i ^ 2) :
    mu ≤ 2 * D := by
  have hdot : dot x (laplacian W x) = mu * ∑ i, x i ^ 2 := by
    unfold dot
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by rw [heig i]; ring
  have hle : ∑ i, degree W i * x i ^ 2 ≤ D * ∑ i, x i ^ 2 := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ =>
      mul_le_mul_of_nonneg_right (hD i) (sq_nonneg _)
  have hmain : mu * ∑ i, x i ^ 2 ≤ 2 * (D * ∑ i, x i ^ 2) := by
    calc mu * ∑ i, x i ^ 2 = dot x (laplacian W x) := hdot.symm
      _ = energy W x := dot_laplacian_eq_energy W x
      _ ≤ 2 * ∑ i, degree W i * x i ^ 2 := energy_le_two_mul_degree_sum W x
      _ ≤ 2 * (D * ∑ i, x i ^ 2) := by linarith
  nlinarith [hmain, hx]

end NeuralHodge