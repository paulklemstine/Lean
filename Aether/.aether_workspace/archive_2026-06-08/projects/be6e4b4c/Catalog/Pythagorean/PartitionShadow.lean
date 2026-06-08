/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Shadow Structure of Partition Functions and Phase Transitions

This file builds a bridge between combinatorial geometry and statistical mechanics
by studying the **active second shadow** of partition functions — the set of
coordinate pairs whose second logarithmic response is nonzero.

## Main Definitions

* `PartitionShadow.logLinear` — Log-linear energy ⟨y, a(s)⟩
* `PartitionShadow.Z` — Multivariate partition function
* `PartitionShadow.gibbs` — Gibbs probability measure
* `PartitionShadow.gibbsExpect` — Expectation under Gibbs measure
* `PartitionShadow.covObs` — Covariance of observables under Gibbs measure
* `PartitionShadow.covarianceEntry` — Covariance matrix entry for coordinate observables
* `PartitionShadow.varianceEntry` — Variance of a coordinate observable
* `PartitionShadow.secondLogPartition` — Second log-partition derivative (algebraic)
* `PartitionShadow.activeShadow2` — Active second shadow
* `PartitionShadow.quadFormCovariance` — Quadratic form of the covariance matrix

## Main Results

* `PartitionShadow.Z_pos` — Partition function is strictly positive for positive weights
* `PartitionShadow.gibbs_sum_one` — Gibbs probabilities sum to 1
* `PartitionShadow.gibbs_pos` — Each Gibbs probability is strictly positive
* `PartitionShadow.d2_logPartition_eq_covariance` — Hessian–covariance identity
* `PartitionShadow.variance_zero_iff_constant_on_support` — Variance vanishes iff observable constant
* `PartitionShadow.mem_activeShadow2_iff_covariance_ne_zero` — Active shadow = covariance support
* `PartitionShadow.logPartition_hessian_posSemidef` — Hessian is positive semidefinite

## Cross-Domain Connections

- **Information geometry**: The covariance matrix is a Fisher information matrix for the
  exponential family parametrized by `y`.
- **Convex analysis**: Positive semidefiniteness of the Hessian implies `log Z` is convex.
- **Combinatorics**: The active shadow connects to weighted support shadow patterns from
  `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean`.
-/

open Finset BigOperators

noncomputable section

namespace PartitionShadow

variable {ι : Type*} [Fintype ι] [Nonempty ι] {n : ℕ}

/-! ## Core Definitions -/

/-- Log-linear energy: ⟨y, a(s)⟩ = ∑_i y_i · a(s, i). -/
def logLinear (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (s : ι) : ℝ :=
  ∑ i, y i * (a s i : ℝ)

/-- Partition function Z(y) = ∑_s w(s) · exp(⟨y, a(s)⟩). -/
def Z (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) : ℝ :=
  ∑ s, w s * Real.exp (logLinear a y s)

/-- Gibbs probability: μ_y(s) = w(s) · exp(⟨y, a(s)⟩) / Z(y). -/
def gibbs (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (s : ι) : ℝ :=
  w s * Real.exp (logLinear a y s) / Z w a y

/-- Gibbs expectation: E_μ[f] = ∑_s μ(s) · f(s). -/
def gibbsExpect (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (f : ι → ℝ) : ℝ :=
  ∑ s, gibbs w a y s * f s

/-- Covariance of observables: Cov_μ(f, g) = E_μ[f·g] - E_μ[f]·E_μ[g]. -/
def covObs (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (f g : ι → ℝ) : ℝ :=
  gibbsExpect w a y (fun s => f s * g s) - gibbsExpect w a y f * gibbsExpect w a y g

/-- Covariance matrix entry: Cov_μ(a_i, a_j). -/
def covarianceEntry (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (i j : Fin n) : ℝ :=
  covObs w a y (fun s => (a s i : ℝ)) (fun s => (a s j : ℝ))

/-- Variance of coordinate observable: Var_μ(a_i) = Cov_μ(a_i, a_i). -/
def varianceEntry (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) (i : Fin n) : ℝ :=
  covarianceEntry w a y i i

/-- Second derivative of log Z (algebraic quotient-rule formula). -/
def secondLogPartition (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ)
    (i j : Fin n) : ℝ :=
  (∑ s, w s * (a s i : ℝ) * (a s j : ℝ) * Real.exp (logLinear a y s)) / Z w a y
  - ((∑ s, w s * (a s i : ℝ) * Real.exp (logLinear a y s)) / Z w a y)
    * ((∑ s, w s * (a s j : ℝ) * Real.exp (logLinear a y s)) / Z w a y)

/-- **Active second shadow**: coordinate pairs with nonzero covariance. -/
def activeShadow2 (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ) :
    Set (Fin n × Fin n) :=
  {ij | covarianceEntry w a y ij.1 ij.2 ≠ 0}

/-- Quadratic form: v^T · Cov · v = Var_μ(⟨v, a⟩). -/
def quadFormCovariance (w : ι → ℝ) (a : ι → Fin n → ℕ) (y : Fin n → ℝ)
    (v : Fin n → ℝ) : ℝ :=
  covObs w a y (fun s => ∑ i, v i * (a s i : ℝ)) (fun s => ∑ i, v i * (a s i : ℝ))

/-! ## Foundational Lemmas -/

/-
Z > 0 when all weights are positive and the state space is nonempty.
-/
theorem Z_pos (w : ι → ℝ) (a : ι → Fin n → ℕ) (hw : ∀ s, 0 < w s)
    (y : Fin n → ℝ) : 0 < Z w a y := by
  exact Finset.sum_pos ( fun s _ => mul_pos ( hw s ) ( Real.exp_pos _ ) ) Finset.univ_nonempty

/-
Each Gibbs weight is strictly positive.
-/
theorem gibbs_pos (w : ι → ℝ) (a : ι → Fin n → ℕ) (hw : ∀ s, 0 < w s)
    (y : Fin n → ℝ) (s : ι) : 0 < gibbs w a y s := by
  exact div_pos ( mul_pos ( hw s ) ( Real.exp_pos _ ) ) ( Z_pos w a hw y )

/-
Gibbs probabilities sum to 1.
-/
theorem gibbs_sum_one (w : ι → ℝ) (a : ι → Fin n → ℕ) (hw : ∀ s, 0 < w s)
    (y : Fin n → ℝ) : ∑ s, gibbs w a y s = 1 := by
  unfold gibbs
  have hZ_pos : 0 < Z w a y := PartitionShadow.Z_pos w a hw y
  exact (by
  rw [ ← Finset.sum_div, div_eq_iff ] <;> linarith! [ show ∑ s, w s * Real.exp ( logLinear a y s ) = Z w a y from rfl ])

/-- Gibbs weights are nonneg. -/
theorem gibbs_nonneg (w : ι → ℝ) (a : ι → Fin n → ℕ) (hw : ∀ s, 0 < w s)
    (y : Fin n → ℝ) (s : ι) : 0 ≤ gibbs w a y s :=
  le_of_lt (gibbs_pos w a hw y s)

/-! ## Covariance as Centered Variance -/

/-
Var(f) = ∑_s μ(s) · (f(s) - E[f])².
-/
theorem covObs_self_eq_sum_sq_dev
    (w : ι → ℝ) (a : ι → Fin n → ℕ) (hw : ∀ s, 0 < w s)
    (y : Fin n → ℝ) (f : ι → ℝ) :
    covObs w a y f f =
      ∑ s, gibbs w a y s * (f s - gibbsExpect w a y f) ^ 2 := by
  -- We'll use the fact that $E[f^2] - E[f]^2$ can be rewritten as $E[(f - E[f])^2]$.
  have h_var : covObs w a y f f = (∑ s, gibbs w a y s * (f s)^2) - (∑ s, gibbs w a y s * f s)^2 := by
    unfold covObs gibbsExpect; ring;
  simp_all +decide [ gibbsExpect, sub_sq, mul_sub, sub_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ];
  simp +decide [ mul_add, mul_sub, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, Finset.sum_mul, sq ];
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, gibbs_sum_one _ _ hw ] ; ring;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, gibbs_sum_one _ _ hw ] ; ring

/-
Variance is nonneg.
-/
theorem covObs_self_nonneg
    (w : ι → ℝ) (a : ι → Fin n → ℕ) (hw : ∀ s, 0 < w s)
    (y : Fin n → ℝ) (f : ι → ℝ) :
    0 ≤ covObs w a y f f := by
  rw [ covObs_self_eq_sum_sq_dev ];
  · exact Finset.sum_nonneg fun s _ => mul_nonneg ( gibbs_nonneg w a hw y s ) ( sq_nonneg _ );
  · assumption

/-
Variance = 0 iff f is constant on support.
-/
theorem covObs_self_eq_zero_iff
    (w : ι → ℝ) (a : ι → Fin n → ℕ) (hw : ∀ s, 0 < w s)
    (y : Fin n → ℝ) (f : ι → ℝ) :
    covObs w a y f f = 0 ↔ ∀ s : ι, f s = gibbsExpect w a y f := by
  have h_var_zero_iff_const : covObs w a y f f = 0 ↔ ∀ s, gibbs w a y s * (f s - gibbsExpect w a y f) ^ 2 = 0 := by
    rw [ covObs_self_eq_sum_sq_dev w a hw y f ];
    exact ⟨ fun h => fun s => by rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => mul_nonneg ( gibbs_nonneg w a hw y _ ) ( sq_nonneg _ ) ] at h; aesop, fun h => Finset.sum_eq_zero fun _ _ => h _ ⟩;
  simp_all +decide [ sub_eq_iff_eq_add, gibbs_pos ];
  exact ⟨ fun h s => Or.resolve_left ( h s ) ( ne_of_gt ( gibbs_pos w a hw y s ) ), fun h s => Or.inr ( h s ) ⟩

/-! ## Theorem 1: Hessian–Covariance Identity -/

/-
**Hessian–Covariance Identity.** The algebraic second log-partition derivative
equals the covariance entry. This converts a geometric support problem into
a thermodynamic response theorem.
-/
omit [Nonempty ι] in
theorem d2_logPartition_eq_covariance
    (w : ι → ℝ) (a : ι → Fin n → ℕ)
    (_hw : ∀ s, 0 < w s) :
    ∀ y : Fin n → ℝ, ∀ i j : Fin n,
      secondLogPartition w a y i j = covarianceEntry w a y i j := by
  unfold covarianceEntry secondLogPartition;
  unfold covObs gibbsExpect gibbs; ring;
  simp +decide [ sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _];
  exact fun y i j => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring )

/-! ## Theorem 2: Variance Zero iff Constant -/

/-
**Variance-Zero Characterization.** Under positive weights, variance of a
coordinate observable vanishes iff that coordinate is constant across all states.
-/
theorem variance_zero_iff_constant_on_support
    (w : ι → ℝ) (a : ι → Fin n → ℕ)
    (hw : ∀ s, 0 < w s) :
    ∀ y : Fin n → ℝ, ∀ i : Fin n,
      varianceEntry w a y i = 0 ↔
        ∃ c : ℕ, ∀ s : ι, a s i = c := by
  intro y i;
  have h_var_zero_iff_const : varianceEntry w a y i = 0 ↔ ∀ s, (a s i : ℝ) = gibbsExpect w a y (fun s => (a s i : ℝ)) := by
    convert covObs_self_eq_zero_iff w a hw y ( fun s => ( a s i : ℝ ) ) using 1;
  constructor <;> intro h <;> simp_all +decide only [];
  · exact ⟨ a ( Classical.arbitrary ι ) i, fun s => Nat.cast_injective ( h_var_zero_iff_const.mp trivial s |> Eq.trans <| h_var_zero_iff_const.mp trivial ( Classical.arbitrary ι ) |> Eq.symm ) ⟩;
  · obtain ⟨ c, hc ⟩ := h; simp +decide [ hc, gibbsExpect ] ;
    rw [ ← Finset.sum_mul _ _ _, gibbs_sum_one ] ; norm_num [ hw ];
    exact hw

/-! ## Theorem 3: Active Shadow = Covariance Support -/

omit [Nonempty ι] in
/-- **Active Shadow Characterization.** Definitional bridge between the
geometric shadow concept and thermodynamic response. -/
theorem mem_activeShadow2_iff_covariance_ne_zero
    (w : ι → ℝ) (a : ι → Fin n → ℕ) :
    ∀ y : Fin n → ℝ, ∀ ij : Fin n × Fin n,
      ij ∈ activeShadow2 w a y ↔
        covarianceEntry w a y ij.1 ij.2 ≠ 0 := by
  exact fun _y _ij => Iff.rfl

/-! ## Theorem 5: Positive Semidefiniteness -/

/-
**PSD of Covariance / Hessian.** v^T · Cov · v = Var(⟨v,a⟩) ≥ 0.
Connects statistical mechanics to convex analysis and information geometry.
-/
theorem logPartition_hessian_posSemidef
    (w : ι → ℝ) (a : ι → Fin n → ℕ)
    (hw : ∀ s, 0 < w s) :
    ∀ y : Fin n → ℝ, ∀ v : Fin n → ℝ,
      0 ≤ quadFormCovariance w a y v := by
  -- Apply the lemma that states the variance of any observable is non-negative.
  intros y v
  apply covObs_self_nonneg w a hw y (fun s => ∑ i, v i * (a s i : ℝ))

end PartitionShadow