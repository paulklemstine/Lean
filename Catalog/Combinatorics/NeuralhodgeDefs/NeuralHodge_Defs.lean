import Mathlib

/-!
# Neural Hodge theory: definitions

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/NeuralHodge/Defs.lean`.  It is reconstructed here as the
definitional layer of a discrete Hodge/Laplacian theory on a finite weighted graph
— the combinatorial substrate of "neural Hodge" constructions, in which the graph
is the architecture of a network and the Laplacian is its smoothing operator.

Definitions introduced here:

* `NeuralHodge.Weights` — a finite symmetric non-negative weight system with zero
  diagonal (an undirected weighted graph on `Fin n`);
* `NeuralHodge.degree`, `NeuralHodge.laplacian`, `NeuralHodge.energy`,
  `NeuralHodge.dot` — degree, graph Laplacian, Dirichlet energy and inner product;
* basic structural facts: the Laplacian is linear (`laplacian_add`,
  `laplacian_smul`) and kills constants (`laplacian_const`), and the harmonic
  (Hodge) space contains the constants.
-/

namespace NeuralHodge

variable {n : ℕ}

/-- A finite undirected weighted graph on the vertex set `Fin n`. -/
structure Weights (n : ℕ) where
  /-- the weight of the edge `{i, j}` -/
  w : Fin n → Fin n → ℝ
  /-- weights are symmetric -/
  w_symm : ∀ i j, w i j = w j i
  /-- weights are non-negative -/
  w_nonneg : ∀ i j, 0 ≤ w i j
  /-- there are no self-loops -/
  w_diag : ∀ i, w i i = 0

/-- The (weighted) degree of a vertex. -/
def degree (W : Weights n) (i : Fin n) : ℝ := ∑ j, W.w i j

/-- The graph Laplacian `L x i = deg(i) · x i − ∑ⱼ w i j · x j`. -/
def laplacian (W : Weights n) (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  degree W i * x i - ∑ j, W.w i j * x j

/-- The Dirichlet energy `E(x) = ½ ∑ᵢⱼ w i j (x i − x j)²`. -/
noncomputable def energy (W : Weights n) (x : Fin n → ℝ) : ℝ :=
  (1 / 2) * ∑ i, ∑ j, W.w i j * (x i - x j) ^ 2

/-- The Euclidean inner product on vertex functions. -/
def dot (x y : Fin n → ℝ) : ℝ := ∑ i, x i * y i

/-- A vertex function is **harmonic** (a discrete Hodge class) when the Laplacian
annihilates it. -/
def IsHarmonic (W : Weights n) (x : Fin n → ℝ) : Prop := ∀ i, laplacian W x i = 0

/-! ## Elementary properties -/

theorem degree_nonneg (W : Weights n) (i : Fin n) : 0 ≤ degree W i :=
  Finset.sum_nonneg fun j _ => W.w_nonneg i j

theorem laplacian_add (W : Weights n) (x y : Fin n → ℝ) (i : Fin n) :
    laplacian W (fun k => x k + y k) i = laplacian W x i + laplacian W y i := by
  simp only [laplacian, mul_add]
  rw [Finset.sum_add_distrib]
  ring

theorem laplacian_smul (W : Weights n) (c : ℝ) (x : Fin n → ℝ) (i : Fin n) :
    laplacian W (fun k => c * x k) i = c * laplacian W x i := by
  unfold laplacian
  have h : ∑ j, W.w i j * (c * x j) = c * ∑ j, W.w i j * x j := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [h]
  ring

/-- **Constants are harmonic.**  The Laplacian kills constant functions, so the
harmonic space is non-trivial whenever `n > 0`. -/
theorem laplacian_const (W : Weights n) (c : ℝ) (i : Fin n) :
    laplacian W (fun _ => c) i = 0 := by
  simp only [laplacian, degree, ← Finset.sum_mul]
  ring

theorem isHarmonic_const (W : Weights n) (c : ℝ) : IsHarmonic W (fun _ => c) :=
  fun i => laplacian_const W c i

@[simp] theorem energy_const (W : Weights n) (c : ℝ) : energy W (fun _ => c) = 0 := by
  simp [energy]

end NeuralHodge