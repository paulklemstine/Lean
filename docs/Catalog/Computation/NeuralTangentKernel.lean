import Mathlib
import Catalog.Computation.EML.AdvancedTheory

/-! # Neural Tangent Kernels and Linearized Gradient Descent

This chapter isolates the finite-sample mechanism behind the infinite-width neural
tangent regime.  A Jacobian is viewed as a family of feature vectors, its neural
tangent kernel is their Gram matrix, and training is studied directly in prediction
space.  The results separate three ingredients: positivity of the Gram kernel,
stability of that kernel under controlled Jacobian drift, and geometric convergence
of the resulting kernel iteration.
-/

noncomputable section

namespace NeuralTangentKernel

open scoped BigOperators

abbrev SampleVector (n : ℕ) := Fin n → ℝ
abbrev Jacobian (n p : ℕ) := Fin n → Fin p → ℝ
abbrev Kernel (n : ℕ) := Fin n → Fin n → ℝ

/-- Euclidean pairing on a finite sample. -/
def dot {n : ℕ} (u v : SampleVector n) : ℝ := ∑ i, u i * v i

/-- Squared Euclidean norm, used to state rates without square roots. -/
def sqNorm {n : ℕ} (u : SampleVector n) : ℝ := dot u u

/-- The neural tangent kernel is the Gram kernel of the parameter Jacobian. -/
def ntk {n p : ℕ} (J : Jacobian n p) : Kernel n :=
  fun i k => ∑ a, J i a * J k a

/-- Action of a finite kernel on sample vectors. -/
def kernelApply {n : ℕ} (K : Kernel n) (v : SampleVector n) : SampleVector n :=
  fun i => ∑ k, K i k * v k

/-- The parameter-space gradient induced by a residual vector. -/
def parameterGradient {n p : ℕ} (J : Jacobian n p) (r : SampleVector n) :
    Fin p → ℝ := fun a => ∑ i, J i a * r i

/-- One residual update for kernel gradient descent. -/
def residualStep {n : ℕ} (K : Kernel n) (η : ℝ) (r : SampleVector n) :
    SampleVector n := fun i => r i - η * kernelApply K r i

/-- Prediction-space gradient descent with a fixed kernel. -/
def kernelTraining {n : ℕ} (K : Kernel n) (η : ℝ) (target initial : SampleVector n) :
    ℕ → SampleVector n
  | 0 => initial
  | t + 1 => fun i => kernelTraining K η target initial t i +
      η * kernelApply K (fun j => target j - kernelTraining K η target initial t j) i

/-- Iteration of the linear residual operator. -/
def residualIteration {n : ℕ} (K : Kernel n) (η : ℝ) (initial : SampleVector n) :
    ℕ → SampleVector n
  | 0 => initial
  | t + 1 => residualStep K η (residualIteration K η initial t)

/-- Every NTK is symmetric. -/
theorem ntk_symmetric {n p : ℕ} (J : Jacobian n p) (i k : Fin n) :
    ntk J i k = ntk J k i := by
  unfold ntk
  apply Finset.sum_congr rfl
  intro a _
  ring

/-- Kernel energy is exactly the squared parameter-gradient norm. -/
theorem ntk_energy_identity {n p : ℕ} (J : Jacobian n p) (r : SampleVector n) :
    dot r (kernelApply (ntk J) r) = ∑ a, (parameterGradient J r a) ^ 2 := by
  simp only [dot, kernelApply, ntk, parameterGradient, Finset.mul_sum, Finset.sum_mul]
  conv_lhs =>
    enter [2, k]
    rw [Finset.sum_comm]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro a _
  rw [sq]
  simp only [Finset.sum_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro k _
  ring

/-- Gram structure makes every neural tangent kernel positive semidefinite. -/
theorem ntk_positive_semidefinite {n p : ℕ} (J : Jacobian n p) (r : SampleVector n) :
    0 ≤ dot r (kernelApply (ntk J) r) := by
  rw [ntk_energy_identity]
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- A linearized parameter update changes predictions by the NTK action. -/
theorem jacobian_gradient_is_kernel_action {n p : ℕ}
    (J : Jacobian n p) (r : SampleVector n) (i : Fin n) :
    (∑ a, J i a * parameterGradient J r a) = kernelApply (ntk J) r i := by
  simp only [parameterGradient, kernelApply, ntk, Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro k _
  apply Finset.sum_congr rfl
  intro a _
  ring

/-- Squared norm is nonnegative. -/
theorem sqNorm_nonneg {n : ℕ} (v : SampleVector n) : 0 ≤ sqNorm v := by
  unfold sqNorm dot
  exact Finset.sum_nonneg fun _ _ => mul_self_nonneg _

/-- Prediction residuals obey precisely the fixed-kernel linear recurrence. -/
theorem kernelTraining_residual_succ {n : ℕ} (K : Kernel n) (η : ℝ)
    (target initial : SampleVector n) (t : ℕ) :
    (fun i => target i - kernelTraining K η target initial (t + 1) i) =
      residualStep K η (fun i => target i - kernelTraining K η target initial t i) := by
  funext i
  simp only [kernelTraining, residualStep]
  ring

/-- The entire prediction trajectory is represented by iteration of the residual operator. -/
theorem kernelTraining_residual_eq_iteration {n : ℕ} (K : Kernel n) (η : ℝ)
    (target initial : SampleVector n) (t : ℕ) :
    (fun i => target i - kernelTraining K η target initial t i) =
      residualIteration K η (fun i => target i - initial i) t := by
  induction t with
  | zero => rfl
  | succ t ih =>
      rw [kernelTraining_residual_succ, residualIteration]
      rw [ih]

/-- A uniform one-step contraction yields a geometric training-error rate. -/
theorem residualIteration_geometric {n : ℕ} (K : Kernel n) (η q : ℝ)
    (hq : 0 ≤ q)
    (contract : ∀ v : SampleVector n, sqNorm (residualStep K η v) ≤ q * sqNorm v)
    (initial : SampleVector n) (t : ℕ) :
    sqNorm (residualIteration K η initial t) ≤ q ^ t * sqNorm initial := by
  induction t with
  | zero => simp [residualIteration]
  | succ t ih =>
      rw [residualIteration]
      calc
        sqNorm (residualStep K η (residualIteration K η initial t))
            ≤ q * sqNorm (residualIteration K η initial t) := contract _
        _ ≤ q * (q ^ t * sqNorm initial) := mul_le_mul_of_nonneg_left ih hq
        _ = q ^ (t + 1) * sqNorm initial := by ring

/-- In the NTK regime, prediction error converges at the contraction rate of the Gram kernel. -/
theorem ntk_training_geometric {n p : ℕ} (J : Jacobian n p) (η q : ℝ)
    (hq : 0 ≤ q)
    (contract : ∀ v : SampleVector n,
      sqNorm (residualStep (ntk J) η v) ≤ q * sqNorm v)
    (target initial : SampleVector n) (t : ℕ) :
    sqNorm (fun i => target i - kernelTraining (ntk J) η target initial t i) ≤
      q ^ t * sqNorm (fun i => target i - initial i) := by
  rw [kernelTraining_residual_eq_iteration]
  exact residualIteration_geometric (ntk J) η q hq contract _ t

/-- A pointwise Jacobian perturbation gives a quantitative entrywise NTK perturbation.
The factor `2pBδ` exposes the width dependence before normalization. -/
theorem ntk_entry_stability {n p : ℕ} (J₀ J₁ : Jacobian n p) (B δ : ℝ)
    (hB : 0 ≤ B)
    (bound₀ : ∀ i a, |J₀ i a| ≤ B)
    (bound₁ : ∀ i a, |J₁ i a| ≤ B)
    (drift : ∀ i a, |J₁ i a - J₀ i a| ≤ δ)
    (i k : Fin n) :
    |ntk J₁ i k - ntk J₀ i k| ≤ (p : ℝ) * (2 * B * δ) := by
  unfold ntk
  have h : ∀ a, |J₁ i a * J₁ k a - J₀ i a * J₀ k a| ≤ 2 * B * δ := by
    intro a
    have hj1 : |J₁ i a| ≤ B := bound₁ i a
    have hj0 : |J₀ i a| ≤ B := bound₀ i a
    have hjk0 : |J₀ k a| ≤ B := bound₀ k a
    have hd1 : |J₁ k a - J₀ k a| ≤ δ := drift k a
    have hd2 : |J₁ i a - J₀ i a| ≤ δ := drift i a
    calc |J₁ i a * J₁ k a - J₀ i a * J₀ k a|
        = |J₁ i a * (J₁ k a - J₀ k a) + J₀ k a * (J₁ i a - J₀ i a)| := by ring_nf
      _ ≤ |J₁ i a * (J₁ k a - J₀ k a)| + |J₀ k a * (J₁ i a - J₀ i a)| := abs_add_le _ _
      _ = |J₁ i a| * |J₁ k a - J₀ k a| + |J₀ k a| * |J₁ i a - J₀ i a| := by rw [abs_mul, abs_mul]
      _ ≤ B * δ + B * δ := by gcongr
      _ = 2 * B * δ := by ring
  calc |∑ a, J₁ i a * J₁ k a - ∑ a, J₀ i a * J₀ k a|
      = |∑ a, (J₁ i a * J₁ k a - J₀ i a * J₀ k a)| := by rw [← Finset.sum_sub_distrib]
    _ ≤ ∑ a : Fin p, |J₁ i a * J₁ k a - J₀ i a * J₀ k a| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _ : Fin p, 2 * B * δ := Finset.sum_le_sum (fun a _ => h a)
    _ = p * (2 * B * δ) := by simp

/-- Small learning rates keep the NTK nearly constant whenever Jacobian drift is
Lipschitz along a bounded scalar parameter path. -/
theorem ntk_nearly_constant_along_training {n p : ℕ}
    (J : ℝ → Jacobian n p) (θ₀ : ℝ) (η G L B : ℝ) (t : ℕ)
    (hB : 0 ≤ B) (hL : 0 ≤ L)
    (bounded : ∀ θ i a, |J θ i a| ≤ B)
    (lipschitz : ∀ θ i a, |J θ i a - J θ₀ i a| ≤ L * |θ - θ₀|)
    (path : ℝ)
    (path_radius : |path - θ₀| ≤ (t : ℝ) * η * G)
    (i k : Fin n) :
    |ntk (J path) i k - ntk (J θ₀) i k| ≤
      (p : ℝ) * (2 * B * (L * ((t : ℝ) * η * G))) := by
  apply ntk_entry_stability (J θ₀) (J path) B (L * ((t : ℝ) * η * G)) hB
  · exact bounded θ₀
  · exact bounded path
  · intro i a
    calc
      |J path i a - J θ₀ i a| ≤ L * |path - θ₀| := lipschitz path i a
      _ ≤ L * ((t : ℝ) * η * G) := mul_le_mul_of_nonneg_left path_radius hL

/-- The catalog's inverse-time optimization bound is compatible with NTK training:
for nonnegative initial error it is itself nonnegative. -/
theorem ntk_catalog_convergence_bound_compatible (initialError η : ℝ) (t : ℕ)
    (he : 0 ≤ initialError) (hη : 0 < η) (ht : 0 < t) :
    0 ≤ gdConvergenceBound initialError η t := by
  exact gd_convergence_nonneg initialError η t he hη ht

-- !-- Lab Notes -- !--
-- Hypothesis: Gram structure alone should supply positivity, while a separate
-- contraction hypothesis should isolate the exact spectral input needed for convergence.
-- Experiment: Expanding the Jacobian-gradient product produced the NTK action, and
-- induction on the residual recurrence produced a geometric finite-time rate.
-- Analysis: Infinite width is not needed for the algebraic convergence mechanism;
-- it enters through concentration and drift estimates that justify a fixed kernel.
-- Critique: Positive semidefiniteness by itself does not imply strict contraction;
-- null directions and oversized learning rates are genuine boundary cases.  The rate
-- theorem therefore states contraction explicitly rather than hiding invertibility.
-- Synthesis: Gram positivity, exact linearized dynamics, geometric convergence, and
-- an entrywise `2pBδ` drift estimate form a reusable deterministic NTK core.
-- !-- End Lab Notes -- !--

end NeuralTangentKernel