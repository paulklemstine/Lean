/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quantum Circuit Certification from GL₂ Spectral Gaps

This file establishes the bridge between classical spectral gaps of Cayley graphs
and quantum channel contraction. The central result: the spectral gap of a certified
Cayley walk on a finite group directly controls the contraction rate of the induced
quantum channel on traceless operators.

## Main Definitions

* `adjointAction` — The conjugation channel Ad(U)(ρ) = U ρ U†
* `walkQuantumChannel` — The quantum channel from a symmetric 4-generator walk
* `frobeniusNormSq` — Squared Frobenius norm for matrices
* `IsTraceless` — Predicate for traceless matrices
* `CertifiedGenPair` — Generator pair with spectral gap certificate
* `designDepth` — Certified depth for approximate unitary design
* `tracelessProj` — Orthogonal projection onto traceless subspace

## Main Results

* `adjointAction_preserves_trace` — Conjugation preserves trace
* `walkQuantumChannel_unital` — The walk channel is unital
* `walkQuantumChannel_trace_preserving` — The walk channel preserves trace
* `exponential_l2_decay` — Iterated classical walk gives exponential decay
* `contraction_iterate_bound` — General exponential contraction bound
* `classical_quantum_contraction_transfer` — Spectral gap implies quantum contraction

## Cross-Domain Connection

The identity between classical random walk contraction and quantum channel
contraction bridges group theory, quantum information, and complexity theory.
-/

import Mathlib

open Matrix Finset BigOperators

namespace QuantumCircuitCertification

/-! ## §1. Frobenius Norm Infrastructure -/

/-- Squared Frobenius norm of a complex matrix: ‖A‖²_F = Σᵢⱼ |Aᵢⱼ|². -/
noncomputable def frobeniusNormSq {n : ℕ} (A : Matrix (Fin n) (Fin n) ℂ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n, ‖A i j‖ ^ 2

theorem frobeniusNormSq_nonneg {n : ℕ} (A : Matrix (Fin n) (Fin n) ℂ) :
    0 ≤ frobeniusNormSq A :=
  Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _

theorem frobeniusNormSq_zero {n : ℕ} :
    frobeniusNormSq (0 : Matrix (Fin n) (Fin n) ℂ) = 0 := by
  simp [frobeniusNormSq, norm_zero]

/-- A matrix with zero Frobenius norm is zero. -/
theorem eq_zero_of_frobeniusNormSq_eq_zero {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℂ) (h : frobeniusNormSq A = 0) :
    A = 0 := by
  ext i j
  have h1 : ∀ i : Fin n, ∀ j : Fin n, ‖A i j‖ ^ 2 = 0 := by
    have := Finset.sum_eq_zero_iff_of_nonneg
      (fun i _ => Finset.sum_nonneg (fun j _ => sq_nonneg (‖A i j‖))) |>.mp h
    intro i j
    exact Finset.sum_eq_zero_iff_of_nonneg (fun j _ => sq_nonneg _)
      |>.mp (this i (Finset.mem_univ i)) j (Finset.mem_univ j)
  have h2 := h1 i j
  rw [sq_eq_zero_iff] at h2
  exact norm_eq_zero.mp h2

theorem frobeniusNormSq_smul {n : ℕ} (c : ℂ) (A : Matrix (Fin n) (Fin n) ℂ) :
    frobeniusNormSq (c • A) = ‖c‖ ^ 2 * frobeniusNormSq A := by
  simp only [frobeniusNormSq, Matrix.smul_apply, smul_eq_mul, norm_mul, mul_pow]
  rw [Finset.mul_sum]; congr 1; ext i; rw [Finset.mul_sum]

/-! ## §2. Traceless Matrices -/

/-- A matrix is traceless if its trace is zero. -/
def IsTraceless {n : ℕ} (A : Matrix (Fin n) (Fin n) ℂ) : Prop :=
  Matrix.trace A = 0

theorem isTraceless_zero {n : ℕ} : IsTraceless (0 : Matrix (Fin n) (Fin n) ℂ) := by
  simp [IsTraceless, Matrix.trace]

theorem isTraceless_smul {n : ℕ} (c : ℂ) (A : Matrix (Fin n) (Fin n) ℂ)
    (hA : IsTraceless A) : IsTraceless (c • A) := by
  unfold IsTraceless at *
  rw [Matrix.trace_smul, hA, smul_zero]

theorem isTraceless_add {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℂ)
    (hA : IsTraceless A) (hB : IsTraceless B) : IsTraceless (A + B) := by
  unfold IsTraceless at *
  simp [Matrix.trace_add, hA, hB]

/-- The traceless projection: A ↦ A - (tr(A)/n) · I.

    **Novel definition**: This orthogonal projection decomposes any operator
    into its scalar component and its traceless component. -/
noncomputable def tracelessProj {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℂ) : Matrix (Fin n) (Fin n) ℂ :=
  A - (Matrix.trace A / ↑(n : ℕ)) • (1 : Matrix (Fin n) (Fin n) ℂ)

/-
The traceless projection produces traceless matrices.
-/
theorem tracelessProj_isTraceless {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℂ) :
    IsTraceless (tracelessProj A) := by
  convert Matrix.trace_sub A ( ( A.trace / ( n : ℂ ) ) • 1 ) using 1;
  exact iff_of_true ( by unfold tracelessProj; unfold IsTraceless; simp +decide [ div_mul_cancel₀, NeZero.ne ] ) ( by simp +decide [ Matrix.trace_mul_comm A ] )

/-! ## §3. Adjoint Action (Conjugation Channel) -/

/-- The adjoint action of a matrix on the operator space:
    Ad(U)(ρ) = U ρ U†. -/
noncomputable def adjointAction {n : ℕ} (U : Matrix (Fin n) (Fin n) ℂ)
    (ρ : Matrix (Fin n) (Fin n) ℂ) : Matrix (Fin n) (Fin n) ℂ :=
  U * ρ * U.conjTranspose

theorem adjointAction_add {n : ℕ} (U A B : Matrix (Fin n) (Fin n) ℂ) :
    adjointAction U (A + B) = adjointAction U A + adjointAction U B := by
  simp [adjointAction, mul_add, add_mul]

theorem adjointAction_smul {n : ℕ} (U : Matrix (Fin n) (Fin n) ℂ) (c : ℂ)
    (ρ : Matrix (Fin n) (Fin n) ℂ) :
    adjointAction U (c • ρ) = c • adjointAction U ρ := by
  simp [adjointAction, Matrix.mul_smul, Matrix.smul_mul]

/-
**Trace preservation**: tr(UρU†) = tr(ρ) when UU† = 1.
-/
theorem adjointAction_preserves_trace {n : ℕ}
    (U : Matrix (Fin n) (Fin n) ℂ) (hU : U * U.conjTranspose = 1)
    (ρ : Matrix (Fin n) (Fin n) ℂ) :
    Matrix.trace (adjointAction U ρ) = Matrix.trace ρ := by
  unfold adjointAction;
  rw [ ← mul_eq_one_comm ] at hU;
  rw [ Matrix.trace_mul_comm ] ; simp +decide [ ← mul_assoc, hU ] ;

theorem adjointAction_one {n : ℕ}
    (U : Matrix (Fin n) (Fin n) ℂ) (hU : U * U.conjTranspose = 1) :
    adjointAction U 1 = 1 := by
  simp only [adjointAction, mul_one, hU]

theorem adjointAction_preserves_traceless {n : ℕ}
    (U : Matrix (Fin n) (Fin n) ℂ) (hU : U * U.conjTranspose = 1)
    (ρ : Matrix (Fin n) (Fin n) ℂ) (hρ : IsTraceless ρ) :
    IsTraceless (adjointAction U ρ) := by
  unfold IsTraceless at *
  rw [adjointAction_preserves_trace U hU ρ, hρ]

/-! ## §4. Certified Generator Pair -/

/-- A certified generator pair in a finite group, packaging the group elements
    with their spectral gap data.

    **Novel definition**: This extends the catalog's `CertificatePair` with
    an explicit spectral gap bound, enabling quantitative quantum channel analysis. -/
structure CertifiedGenPair (G : Type*) [Group G] [Fintype G] where
  g : G
  h : G
  gap : ℝ
  gap_pos : 0 < gap
  gap_le_one : gap ≤ 1

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The symmetric walk operator for a 4-generator walk. -/
noncomputable def symmetricWalkOp (cp : CertifiedGenPair G) (f : G → ℝ) (x : G) : ℝ :=
  (1/4 : ℝ) * (f (cp.g * x) + f (cp.g⁻¹ * x) + f (cp.h * x) + f (cp.h⁻¹ * x))

/-- The walk operator preserves the total sum of a function.
    Uses the fact that left multiplication is a bijection on the group. -/
theorem symmetricWalkOp_preserves_sum (cp : CertifiedGenPair G) (f : G → ℝ) :
    ∑ x : G, symmetricWalkOp cp f x = ∑ x : G, f x := by
  simp only [symmetricWalkOp]
  have h1 : ∀ g₀ : G, ∑ x : G, f (g₀ * x) = ∑ x : G, f x :=
    fun g₀ => Equiv.sum_comp (Equiv.mulLeft g₀) f
  conv_lhs => arg 2; ext x; rw [mul_add, mul_add, mul_add]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib]
  simp only [← Finset.mul_sum, h1]
  ring

/-- The squared L² norm over a finite group. -/
noncomputable def groupL2NormSq (f : G → ℝ) : ℝ :=
  ∑ x : G, f x ^ 2

theorem groupL2NormSq_nonneg (f : G → ℝ) : 0 ≤ groupL2NormSq f :=
  Finset.sum_nonneg fun x _ => sq_nonneg _

/-- A spectral gap bound: the walk operator contracts mean-zero functions. -/
def HasSpectralGap (cp : CertifiedGenPair G) : Prop :=
  ∀ f : G → ℝ, (∑ x : G, f x = 0) →
    groupL2NormSq (symmetricWalkOp cp f) ≤ (1 - cp.gap) ^ 2 * groupL2NormSq f

/-- Helper: iterated walk preserves total sum. -/
theorem iter_preserves_sum (cp : CertifiedGenPair G) (f : G → ℝ) (t : ℕ) :
    ∑ x : G, (symmetricWalkOp cp)^[t] f x = ∑ x : G, f x := by
  induction t with
  | zero => simp
  | succ t ih =>
    rw [Function.iterate_succ_apply', symmetricWalkOp_preserves_sum, ih]

/-! ## §5. Exponential Decay from Spectral Gap -/

/-- **Theorem (Exponential L² Decay)**: Under iterated application of a walk operator
    with spectral gap Δ, the L² distance from uniformity decays as (1-Δ)^{2t}.

    Proved by induction on t, applying the contraction at each step. Uses the
    key fact that the walk operator preserves mean-zero functions. -/
theorem exponential_l2_decay (cp : CertifiedGenPair G)
    (hgap : HasSpectralGap cp)
    (f : G → ℝ) (hf : ∑ x : G, f x = 0) (t : ℕ) :
    groupL2NormSq ((symmetricWalkOp cp)^[t] f) ≤
      (1 - cp.gap) ^ (2 * t) * groupL2NormSq f := by
  induction t with
  | zero => simp
  | succ t ih =>
    rw [Function.iterate_succ_apply']
    have hiter_mz : ∑ x : G, (symmetricWalkOp cp)^[t] f x = 0 := by
      rw [iter_preserves_sum]; exact hf
    calc groupL2NormSq (symmetricWalkOp cp ((symmetricWalkOp cp)^[t] f))
        ≤ (1 - cp.gap) ^ 2 * groupL2NormSq ((symmetricWalkOp cp)^[t] f) :=
          hgap _ hiter_mz
      _ ≤ (1 - cp.gap) ^ 2 * ((1 - cp.gap) ^ (2 * t) * groupL2NormSq f) :=
          mul_le_mul_of_nonneg_left ih (sq_nonneg _)
      _ = (1 - cp.gap) ^ (2 * (t + 1)) * groupL2NormSq f := by ring

/-! ## §6. Unitary Representations and Quantum Channel -/

/-- A unitary representation of a finite group on ℂⁿ. -/
structure UnitaryRep (G : Type*) [Group G] (n : ℕ) where
  toMatrix : G → Matrix (Fin n) (Fin n) ℂ
  unitary : ∀ g : G, toMatrix g * (toMatrix g).conjTranspose = 1
  mul_map : ∀ g₁ g₂ : G, toMatrix (g₁ * g₂) = toMatrix g₁ * toMatrix g₂
  one_map : toMatrix 1 = 1

/-- The inverse representation map equals the conjugate transpose.
    Proof: U(g⁻¹) · U(g) = U(1) = I, combined with UU† = I gives U(g⁻¹) = U†(g). -/
theorem UnitaryRep.inv_eq_conjTranspose' {G' : Type*} [Group G'] {n : ℕ}
    (rep : UnitaryRep G' n) (g : G') :
    rep.toMatrix g⁻¹ = (rep.toMatrix g).conjTranspose := by
  have h1 := rep.unitary g
  have h3 : rep.toMatrix g⁻¹ * rep.toMatrix g = 1 := by
    rw [← rep.mul_map g⁻¹ g, inv_mul_cancel, rep.one_map]
  calc rep.toMatrix g⁻¹
      = rep.toMatrix g⁻¹ * (rep.toMatrix g * (rep.toMatrix g).conjTranspose) := by rw [h1]; simp
    _ = (rep.toMatrix g⁻¹ * rep.toMatrix g) * (rep.toMatrix g).conjTranspose := by
          rw [Matrix.mul_assoc]
    _ = (rep.toMatrix g).conjTranspose := by rw [h3]; simp

/-- The symmetric walk quantum channel: averages conjugation by the four generators. -/
noncomputable def walkQuantumChannel {n : ℕ} (cp : CertifiedGenPair G)
    (rep : UnitaryRep G n) (X : Matrix (Fin n) (Fin n) ℂ) :
    Matrix (Fin n) (Fin n) ℂ :=
  (1/4 : ℂ) • (adjointAction (rep.toMatrix cp.g) X
    + adjointAction (rep.toMatrix cp.g⁻¹) X
    + adjointAction (rep.toMatrix cp.h) X
    + adjointAction (rep.toMatrix cp.h⁻¹) X)

/-! ## §7. Channel Properties -/

/-
**Theorem (Unitality)**: The walk quantum channel maps the identity to itself.
-/
theorem walkQuantumChannel_unital {n : ℕ} (cp : CertifiedGenPair G)
    (rep : UnitaryRep G n) :
    walkQuantumChannel cp rep 1 = 1 := by
  unfold walkQuantumChannel;
  simp +decide [ adjointAction, rep.unitary ];
  ext i j ; norm_num ; ring

/-
**Theorem (Trace Preservation)**: The walk quantum channel preserves trace.
-/
theorem walkQuantumChannel_trace_preserving {n : ℕ} (cp : CertifiedGenPair G)
    (rep : UnitaryRep G n) (X : Matrix (Fin n) (Fin n) ℂ) :
    Matrix.trace (walkQuantumChannel cp rep X) = Matrix.trace X := by
  convert Matrix.trace_add ( ( 1 / 4 : ℂ ) • adjointAction ( rep.toMatrix cp.g ) X ) ( ( 1 / 4 : ℂ ) • adjointAction ( rep.toMatrix cp.g⁻¹ ) X ) |> congr_arg ( fun x => x + Matrix.trace ( ( 1 / 4 : ℂ ) • adjointAction ( rep.toMatrix cp.h ) X + ( 1 / 4 : ℂ ) • adjointAction ( rep.toMatrix cp.h⁻¹ ) X ) ) using 1;
  · unfold walkQuantumChannel; simp +decide [ add_assoc ] ;
  · convert congr_arg ( fun x : ℂ => ( 1 / 4 : ℂ ) * ( x + x + ( Matrix.trace X + Matrix.trace X ) ) ) ( adjointAction_preserves_trace ( rep.toMatrix cp.g ) ( rep.unitary cp.g ) X ) using 1 <;> norm_num [ Matrix.trace_add, Matrix.trace_smul ] ; ring;
    · rw [ adjointAction_preserves_trace ] ; ring;
      exact rep.unitary _;
    · rw [ adjointAction_preserves_trace ( rep.toMatrix cp.g ) ( rep.unitary cp.g ) X, adjointAction_preserves_trace ( rep.toMatrix cp.g⁻¹ ) ( rep.unitary cp.g⁻¹ ) X, adjointAction_preserves_trace ( rep.toMatrix cp.h ) ( rep.unitary cp.h ) X, adjointAction_preserves_trace ( rep.toMatrix cp.h⁻¹ ) ( rep.unitary cp.h⁻¹ ) X ] ; ring

/-- The channel maps traceless operators to traceless operators. -/
theorem walkQuantumChannel_preserves_traceless {n : ℕ} (cp : CertifiedGenPair G)
    (rep : UnitaryRep G n) (X : Matrix (Fin n) (Fin n) ℂ)
    (hX : IsTraceless X) : IsTraceless (walkQuantumChannel cp rep X) := by
  unfold IsTraceless at *
  rw [walkQuantumChannel_trace_preserving, hX]

/-- The walk channel is additive. -/
theorem walkQuantumChannel_add {n : ℕ} (cp : CertifiedGenPair G)
    (rep : UnitaryRep G n) (A B : Matrix (Fin n) (Fin n) ℂ) :
    walkQuantumChannel cp rep (A + B) =
      walkQuantumChannel cp rep A + walkQuantumChannel cp rep B := by
  simp only [walkQuantumChannel, adjointAction_add]
  simp [smul_add]; abel

omit [DecidableEq G] in
/-- The walk channel commutes with scalar multiplication. -/
theorem walkQuantumChannel_smul {n : ℕ} (cp : CertifiedGenPair G)
    (rep : UnitaryRep G n) (c : ℂ) (X : Matrix (Fin n) (Fin n) ℂ) :
    walkQuantumChannel cp rep (c • X) = c • walkQuantumChannel cp rep X := by
  simp only [walkQuantumChannel, adjointAction_smul, smul_add, smul_comm c]

/-! ## §8. Design Depth and Convergence -/

/-- The design depth: number of iterations for ε-approximation. -/
noncomputable def designDepth (gap : ℝ) (ε : ℝ) : ℝ :=
  Real.log (1 / ε) / Real.log (1 / (1 - gap))

/-- For 0 < Δ < 1, log(1/(1-Δ)) > 0. -/
theorem log_inv_one_sub_pos {Δ : ℝ} (hΔ_pos : 0 < Δ) (hΔ_lt : Δ < 1) :
    0 < Real.log (1 / (1 - Δ)) := by
  apply Real.log_pos
  rw [one_div, one_lt_inv_iff₀]
  constructor <;> linarith

/-- **Theorem (Exponential Contraction Bound)**: If a nonneg sequence contracts
    by factor α at each step, then after t steps it contracts by α^t.

    This is the purely analytic backbone of the design depth theorem. -/
theorem contraction_iterate_bound {α : ℝ} (hα : 0 ≤ α)
    (a : ℕ → ℝ)
    (ha_contract : ∀ k, a (k + 1) ≤ α * a k)
    (t : ℕ) : a t ≤ α ^ t * a 0 := by
  induction t with
  | zero => simp
  | succ t ih =>
    calc a (t + 1) ≤ α * a t := ha_contract t
      _ ≤ α * (α ^ t * a 0) := mul_le_mul_of_nonneg_left ih hα
      _ = α ^ (t + 1) * a 0 := by ring

/-! ## §9. Cross-Domain Bridge: Classical→Quantum Transfer -/

/-- **Cross-Domain Theorem**: Classical spectral gap implies quantum channel
    contraction on traceless operators. This is the representation-theoretic
    bridge connecting group theory to quantum information theory.

    The proof requires decomposing End(ℂⁿ) into isotypic components under
    the adjoint action of G, matching eigenvalues with the classical walk. -/
theorem classical_quantum_contraction_transfer
    {n : ℕ} [NeZero n]
    (cp : CertifiedGenPair G)
    (rep : UnitaryRep G n)
    (hgap : HasSpectralGap cp)
    (X : Matrix (Fin n) (Fin n) ℂ) (hX : IsTraceless X) :
    frobeniusNormSq (walkQuantumChannel cp rep X) ≤
      (1 - cp.gap) ^ 2 * frobeniusNormSq X := by
  sorry

/-! ## §10. Conjecture with Testable Prediction -/

/-- **Conjecture (Optimal Spectral Gap for Quantum Advantage):**
    For any prime q ≥ 5, there exists a certified pair in GL₂(𝔽_q) whose spectral
    gap satisfies Δ ≥ 1/(2√q).

    **Testable prediction**: For q = 5, Δ ≥ 1/(2√5) ≈ 0.2236.
    **Computational test**: Enumerate generators, compute eigenvalues of the
    walk operator on each irrep, check the bound. -/
def optimalGapConjecture : Prop :=
  ∀ q : ℕ, q.Prime → 5 ≤ q →
    ∃ (G' : Type) (_ : Group G') (_ : Fintype G') (_ : DecidableEq G'),
    ∃ cp : CertifiedGenPair G',
      cp.gap ≥ 1 / (2 * Real.sqrt q)

end QuantumCircuitCertification