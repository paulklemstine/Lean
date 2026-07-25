/-
  # Algebraic Circuit Complexity — Core Definitions and Foundational Lemmas

  Bridge: connects Algebra (polynomial rings, ideals) to Computation (circuit complexity).

  This file introduces algebraic circuits as an inductive type over commutative semirings,
  defines evaluation semantics, structural invariants (depth, size, degree bound),
  and proves foundational bounds relating these invariants.

  Key results:
  - Degree of a circuit-computed polynomial ≤ 2^depth (exponential degree-depth tradeoff)
  - Size ≥ depth + 1 (work ≥ span)
  - Evaluation semantics agree with MvPolynomial interpretation
  - Circuit addition/multiplication preserve structural bounds
  - Zero-function circuits form an ideal (closure under add/mul)
-/

import Mathlib

namespace AlgebraicCircuitComplexity

/-! ## Core Circuit Definition

An `AlgCircuit R n` represents a straight-line program over a commutative semiring `R`
with variables indexed by `Fin n`. This is the standard model in algebraic complexity theory.

Bridge: connects Algebra (polynomial ring `R[x₁,...,xₙ]`) to Computation (straight-line programs). -/

/-- An algebraic circuit over a commutative semiring `R` with `n` input variables.
    Each gate computes either a constant, a variable, or an addition/multiplication
    of two sub-circuits. This is the standard algebraic circuit model (Valiant 1979).

    Bridge: connects Algebra (polynomial evaluation) to Computation (circuit complexity). -/
inductive AlgCircuit (R : Type*) [CommSemiring R] (n : ℕ) : Type _ where
  | const : R → AlgCircuit R n
  | var : Fin n → AlgCircuit R n
  | add : AlgCircuit R n → AlgCircuit R n → AlgCircuit R n
  | mul : AlgCircuit R n → AlgCircuit R n → AlgCircuit R n
  deriving Inhabited

variable {R : Type*} [CommSemiring R] {n : ℕ}

/-! ## Evaluation Semantics -/

/-- Evaluate an algebraic circuit on an assignment of values to variables.
    This is the semantic function mapping circuits to the functions they compute.

    Bridge: connects Computation (circuit execution) to Algebra (polynomial evaluation). -/
def AlgCircuit.eval (C : AlgCircuit R n) (v : Fin n → R) : R :=
  match C with
  | .const r => r
  | .var i => v i
  | .add C₁ C₂ => C₁.eval v + C₂.eval v
  | .mul C₁ C₂ => C₁.eval v * C₂.eval v

/-! ## Structural Invariants -/

/-- The depth of an algebraic circuit — the length of the longest root-to-leaf path.
    Depth corresponds to parallel time complexity.

    Bridge: connects Computation (parallel complexity) to Machine Learning
    (neural network depth ↔ expressivity). -/
def AlgCircuit.depth : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 0
  | .add C₁ C₂ => 1 + max C₁.depth C₂.depth
  | .mul C₁ C₂ => 1 + max C₁.depth C₂.depth

/-- The size of an algebraic circuit — the total number of gates.
    Size corresponds to sequential time complexity / total work.

    Bridge: connects Computation (sequential complexity) to Cryptography
    (circuit size bounds for post-quantum hardness assumptions). -/
def AlgCircuit.size : AlgCircuit R n → ℕ
  | .const _ => 1
  | .var _ => 1
  | .add C₁ C₂ => 1 + C₁.size + C₂.size
  | .mul C₁ C₂ => 1 + C₁.size + C₂.size

/-- Upper bound on the degree of the polynomial computed by a circuit.
    For addition gates: max of sub-degrees. For multiplication: sum.
    This is the syntactic degree bound used in complexity analysis.

    Bridge: connects Algebra (polynomial degree) to Computation (degree as
    complexity measure, Strassen's degree bound). -/
def AlgCircuit.degreeBound : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 1
  | .add C₁ C₂ => max C₁.degreeBound C₂.degreeBound
  | .mul C₁ C₂ => C₁.degreeBound + C₂.degreeBound

/-- Number of multiplication gates in a circuit.
    The multiplicative complexity is a key measure in algebraic complexity,
    e.g., matrix multiplication lower bounds.

    Bridge: connects Computation (multiplicative complexity) to Cryptography
    (bilinear complexity of lattice operations). -/
def AlgCircuit.mulGates : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 0
  | .add C₁ C₂ => C₁.mulGates + C₂.mulGates
  | .mul C₁ C₂ => 1 + C₁.mulGates + C₂.mulGates

/-- Number of addition gates in a circuit. -/
def AlgCircuit.addGates : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 0
  | .add C₁ C₂ => 1 + C₁.addGates + C₂.addGates
  | .mul C₁ C₂ => C₁.addGates + C₂.addGates

/-! ## Mapping Circuits to MvPolynomial

This section bridges the computational (circuit) and algebraic (polynomial) worlds. -/

/-- Map an algebraic circuit to the multivariate polynomial it computes.
    This is the canonical homomorphism from circuits to the polynomial ring.

    Bridge: connects Computation (circuit semantics) to Algebra (polynomial ring `MvPolynomial`). -/
noncomputable def AlgCircuit.toMvPolynomial (C : AlgCircuit R n) : MvPolynomial (Fin n) R :=
  match C with
  | .const r => MvPolynomial.C r
  | .var i => MvPolynomial.X i
  | .add C₁ C₂ => C₁.toMvPolynomial + C₂.toMvPolynomial
  | .mul C₁ C₂ => C₁.toMvPolynomial * C₂.toMvPolynomial

/-! ## Foundational Theorems -/

/-- Evaluation of a circuit agrees with evaluation of its polynomial representation.
    This is the fundamental soundness theorem connecting the computational and algebraic models.

    Bridge: connects Computation (circuit evaluation) to Algebra (polynomial evaluation).
    Uses: structural induction, ring homomorphism properties. -/
theorem eval_eq_mvpolynomial_eval (C : AlgCircuit R n) (v : Fin n → R) :
    C.eval v = MvPolynomial.eval v C.toMvPolynomial := by
  induction C with
  | const r => simp [AlgCircuit.eval, AlgCircuit.toMvPolynomial, MvPolynomial.eval_C]
  | var i => simp [AlgCircuit.eval, AlgCircuit.toMvPolynomial, MvPolynomial.eval_X]
  | add C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.eval, AlgCircuit.toMvPolynomial, map_add]
    rw [ih₁, ih₂]
  | mul C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.eval, AlgCircuit.toMvPolynomial, map_mul]
    rw [ih₁, ih₂]

/-- Two circuits computing the same polynomial are semantically equivalent:
    they produce the same output on every input.

    Bridge: connects Computation (circuit equivalence) to Algebra (polynomial equality). -/
theorem circuits_with_same_poly_agree (C₁ C₂ : AlgCircuit R n)
    (h : C₁.toMvPolynomial = C₂.toMvPolynomial) (v : Fin n → R) :
    C₁.eval v = C₂.eval v := by
  rw [eval_eq_mvpolynomial_eval, eval_eq_mvpolynomial_eval, h]

/-- Size of a circuit is always positive. Every circuit has at least one gate. -/
theorem AlgCircuit.size_pos (C : AlgCircuit R n) : 0 < C.size := by
  cases C <;> simp [AlgCircuit.size] <;> omega

/-- Size of a circuit is at least its depth plus one.
    This encodes the fact that sequential computation subsumes parallel computation.

    Bridge: connects Computation (work ≥ span) to Machine Learning
    (total parameters ≥ network depth in neural architectures). -/
theorem size_ge_depth_succ (C : AlgCircuit R n) : C.depth + 1 ≤ C.size := by
  induction C with
  | const _ => simp [AlgCircuit.depth, AlgCircuit.size]
  | var _ => simp [AlgCircuit.depth, AlgCircuit.size]
  | add _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.depth, AlgCircuit.size]; omega
  | mul _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.depth, AlgCircuit.size]; omega

/-- The degree bound of a circuit is at most 2^depth.
    This is the fundamental degree-depth tradeoff: depth-d circuits compute
    polynomials of degree at most 2^d. The bound is tight (iterated squaring).

    Bridge: connects Computation (circuit depth) to Algebra (polynomial degree).
    Impact: This is the algebraic analogue of the depth-width tradeoff in
    neural networks — shallow circuits can only compute low-degree polynomials.

    Proof uses: induction, omega, Nat.pow monotonicity. -/
theorem degreeBound_le_two_pow_depth (C : AlgCircuit R n) :
    C.degreeBound ≤ 2 ^ C.depth := by
  induction C with
  | const _ => simp [AlgCircuit.degreeBound, AlgCircuit.depth]
  | var _ => simp [AlgCircuit.degreeBound, AlgCircuit.depth]
  | add C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.degreeBound, AlgCircuit.depth]
    apply max_le
    · calc C₁.degreeBound ≤ 2 ^ C₁.depth := ih₁
        _ ≤ 2 ^ max C₁.depth C₂.depth :=
            Nat.pow_le_pow_right (by omega) (le_max_left _ _)
        _ ≤ 2 ^ (1 + max C₁.depth C₂.depth) := by
            apply Nat.pow_le_pow_right (by omega); omega
    · calc C₂.degreeBound ≤ 2 ^ C₂.depth := ih₂
        _ ≤ 2 ^ max C₁.depth C₂.depth :=
            Nat.pow_le_pow_right (by omega) (le_max_right _ _)
        _ ≤ 2 ^ (1 + max C₁.depth C₂.depth) := by
            apply Nat.pow_le_pow_right (by omega); omega
  | mul C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.degreeBound, AlgCircuit.depth]
    calc C₁.degreeBound + C₂.degreeBound
        ≤ 2 ^ C₁.depth + 2 ^ C₂.depth := Nat.add_le_add ih₁ ih₂
      _ ≤ 2 ^ max C₁.depth C₂.depth + 2 ^ max C₁.depth C₂.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (le_max_right _ _)
      _ = 2 ^ (1 + max C₁.depth C₂.depth) := by ring

/-- Multiplicative gates count is bounded by circuit size.

    Bridge: connects Computation (multiplicative complexity) to Algebra
    (bilinear complexity in tensor rank theory). -/
theorem mulGates_le_size (C : AlgCircuit R n) : C.mulGates ≤ C.size := by
  induction C with
  | const _ => simp [AlgCircuit.mulGates, AlgCircuit.size]
  | var _ => simp [AlgCircuit.mulGates, AlgCircuit.size]
  | add _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.mulGates, AlgCircuit.size]; omega
  | mul _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.mulGates, AlgCircuit.size]; omega

/-- Addition gates count is bounded by circuit size. -/
theorem addGates_le_size (C : AlgCircuit R n) : C.addGates ≤ C.size := by
  induction C with
  | const _ => simp [AlgCircuit.addGates, AlgCircuit.size]
  | var _ => simp [AlgCircuit.addGates, AlgCircuit.size]
  | add _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.addGates, AlgCircuit.size]; omega
  | mul _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.addGates, AlgCircuit.size]; omega

/-- The sum of add and mul gates is at most the size of the circuit.
    The remaining gates are leaf nodes (constants and variables). -/
theorem addGates_plus_mulGates_le_size (C : AlgCircuit R n) :
    C.addGates + C.mulGates ≤ C.size := by
  induction C with
  | const _ => simp [AlgCircuit.addGates, AlgCircuit.mulGates, AlgCircuit.size]
  | var _ => simp [AlgCircuit.addGates, AlgCircuit.mulGates, AlgCircuit.size]
  | add _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.addGates, AlgCircuit.mulGates, AlgCircuit.size]; omega
  | mul _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.addGates, AlgCircuit.mulGates, AlgCircuit.size]; omega

/-- The constant circuit evaluates to its constant value on every input. -/
@[simp]
theorem eval_const (r : R) (v : Fin n → R) :
    (AlgCircuit.const r : AlgCircuit R n).eval v = r := rfl

/-- The variable circuit evaluates to the corresponding variable value. -/
@[simp]
theorem eval_var (i : Fin n) (v : Fin n → R) :
    (AlgCircuit.var i : AlgCircuit R n).eval v = v i := rfl

/-- Addition of circuits is semantically correct. -/
@[simp]
theorem eval_add (C₁ C₂ : AlgCircuit R n) (v : Fin n → R) :
    (AlgCircuit.add C₁ C₂).eval v = C₁.eval v + C₂.eval v := rfl

/-- Multiplication of circuits is semantically correct. -/
@[simp]
theorem eval_mul (C₁ C₂ : AlgCircuit R n) (v : Fin n → R) :
    (AlgCircuit.mul C₁ C₂).eval v = C₁.eval v * C₂.eval v := rfl

/-! ## Depth Properties -/

/-- The depth of an addition gate. -/
@[simp]
theorem depth_add (C₁ C₂ : AlgCircuit R n) :
    (AlgCircuit.add C₁ C₂).depth = 1 + max C₁.depth C₂.depth := rfl

/-- The depth of a multiplication gate. -/
@[simp]
theorem depth_mul (C₁ C₂ : AlgCircuit R n) :
    (AlgCircuit.mul C₁ C₂).depth = 1 + max C₁.depth C₂.depth := rfl

/-- Constant circuits have depth zero. -/
@[simp]
theorem depth_const (r : R) : (AlgCircuit.const r : AlgCircuit R n).depth = 0 := rfl

/-- Variable circuits have depth zero. -/
@[simp]
theorem depth_var (i : Fin n) : (AlgCircuit.var i : AlgCircuit R n).depth = 0 := rfl

/-! ## Degree Bound Properties -/

@[simp]
theorem degreeBound_const (r : R) :
    (AlgCircuit.const r : AlgCircuit R n).degreeBound = 0 := rfl

@[simp]
theorem degreeBound_var (i : Fin n) :
    (AlgCircuit.var i : AlgCircuit R n).degreeBound = 1 := rfl

theorem degreeBound_add_eq (C₁ C₂ : AlgCircuit R n) :
    (AlgCircuit.add C₁ C₂).degreeBound = max C₁.degreeBound C₂.degreeBound := rfl

theorem degreeBound_mul_eq (C₁ C₂ : AlgCircuit R n) :
    (AlgCircuit.mul C₁ C₂).degreeBound = C₁.degreeBound + C₂.degreeBound := rfl

/-! ## Circuit Identity Testing — Algebraic Foundation

The fundamental question: when does a circuit compute the zero polynomial?
This connects to the Polynomial Identity Testing (PIT) problem.

Bridge: connects Computation (PIT problem) to Algebra (polynomial identity)
and Cryptography (zero-knowledge proofs, polynomial commitments). -/

/-- A circuit computes the zero function iff its polynomial representation is zero
    when evaluated at every point. This is the semantic definition of PIT.

    Bridge: connects Computation (identity testing) to Algebra (polynomial vanishing). -/
def AlgCircuit.isZeroFunction (C : AlgCircuit R n) : Prop :=
  ∀ v : Fin n → R, C.eval v = 0

/-- If a circuit's MvPolynomial representation is zero, the circuit computes the zero function.
    This is the algebraic → computational direction of PIT.

    Bridge: connects Algebra (polynomial = 0) to Computation (circuit computes 0). -/
theorem zero_poly_implies_zero_function (C : AlgCircuit R n)
    (h : C.toMvPolynomial = 0) : C.isZeroFunction := by
  intro v
  rw [eval_eq_mvpolynomial_eval, h, map_zero]

/-- A constant-zero circuit is the zero function. -/
theorem const_zero_is_zero_function :
    (AlgCircuit.const (0 : R) : AlgCircuit R n).isZeroFunction := by
  intro v
  simp [AlgCircuit.eval]

/-- Adding two zero-function circuits yields a zero-function circuit.
    The zero functions form an additive subgroup of the function space.

    Bridge: connects Algebra (ideal structure) to Computation (closure properties of PIT). -/
theorem add_zero_functions_is_zero (C₁ C₂ : AlgCircuit R n)
    (h₁ : C₁.isZeroFunction) (h₂ : C₂.isZeroFunction) :
    (AlgCircuit.add C₁ C₂).isZeroFunction := by
  intro v
  simp only [AlgCircuit.eval, h₁ v, h₂ v, add_zero]

/-- Multiplying a zero-function circuit by any circuit yields a zero function.
    Zero functions form an ideal in the circuit algebra.

    Bridge: connects Algebra (ideal absorption) to Computation (PIT closure). -/
theorem mul_zero_function_left (C₁ C₂ : AlgCircuit R n)
    (h₁ : C₁.isZeroFunction) :
    (AlgCircuit.mul C₁ C₂).isZeroFunction := by
  intro v
  simp only [AlgCircuit.eval, h₁ v, zero_mul]

theorem mul_zero_function_right (C₁ C₂ : AlgCircuit R n)
    (h₂ : C₂.isZeroFunction) :
    (AlgCircuit.mul C₁ C₂).isZeroFunction := by
  intro v
  simp only [AlgCircuit.eval, h₂ v, mul_zero]

/-! ## Circuit Complexity Classes

Define circuit complexity classes analogous to VP and VNP (Valiant 1979).

Bridge: connects Computation (complexity classes) to Algebra (polynomial families). -/

/-- A complexity bound specifying limits on size, degree, and depth.
    This captures the notion of "bounded resources" in circuit complexity.

    Bridge: connects Computation (VP — Valiant's P) to Machine Learning
    (efficiently computable polynomial activations). -/
structure CircuitComplexityBound (R : Type*) [CommSemiring R] (n : ℕ) where
  sizeBound : ℕ
  degreeBnd : ℕ
  depthBound : ℕ

/-- A circuit satisfies a complexity bound if its structural invariants
    are all within the specified limits. -/
def AlgCircuit.satisfiesBound (C : AlgCircuit R n) (b : CircuitComplexityBound R n) : Prop :=
  C.size ≤ b.sizeBound ∧ C.degreeBound ≤ b.degreeBnd ∧ C.depth ≤ b.depthBound

/-- If a circuit satisfies a bound, its degree bound is at most 2^depthBound.
    This combines the degree-depth tradeoff with the complexity bound.

    Bridge: connects Computation (bounded-depth circuits) to Algebra
    (bounded-degree polynomials — the setting for Schwartz-Zippel). -/
theorem bounded_circuit_degree_bound (C : AlgCircuit R n) (b : CircuitComplexityBound R n)
    (hb : C.satisfiesBound b) :
    C.degreeBound ≤ 2 ^ b.depthBound := by
  obtain ⟨_, _, hdepth⟩ := hb
  calc C.degreeBound ≤ 2 ^ C.depth := degreeBound_le_two_pow_depth C
    _ ≤ 2 ^ b.depthBound := Nat.pow_le_pow_right (by omega) hdepth

/-- If a circuit satisfies a bound, its depth is at most its size bound minus one.
    This follows from size ≥ depth + 1.

    Bridge: connects Computation (resource tradeoffs) to Machine Learning
    (depth-width tradeoffs in neural network design). -/
theorem bounded_circuit_depth_size (C : AlgCircuit R n) (b : CircuitComplexityBound R n)
    (hb : C.satisfiesBound b) :
    C.depth + 1 ≤ b.sizeBound := by
  obtain ⟨hs, _, _⟩ := hb
  calc C.depth + 1 ≤ C.size := size_ge_depth_succ C
    _ ≤ b.sizeBound := hs

/-! ## Substitution and Composition -/

/-- Substitute a circuit for each variable in another circuit.
    This models circuit composition / function composition. -/
def AlgCircuit.substitute (C : AlgCircuit R n) (subs : Fin n → AlgCircuit R n) :
    AlgCircuit R n :=
  match C with
  | .const r => .const r
  | .var i => subs i
  | .add C₁ C₂ => .add (C₁.substitute subs) (C₂.substitute subs)
  | .mul C₁ C₂ => .mul (C₁.substitute subs) (C₂.substitute subs)

/-- Substitution with variable circuits is the identity. -/
theorem substitute_var_id (C : AlgCircuit R n) :
    C.substitute AlgCircuit.var = C := by
  induction C with
  | const _ => simp [AlgCircuit.substitute]
  | var _ => simp [AlgCircuit.substitute]
  | add _ _ ih₁ ih₂ => simp [AlgCircuit.substitute, ih₁, ih₂]
  | mul _ _ ih₁ ih₂ => simp [AlgCircuit.substitute, ih₁, ih₂]

/-- Substitution preserves evaluation semantics.
    eval(C[subs], v) = eval(C, λi ↦ eval(subs(i), v))

    Bridge: connects Computation (program composition) to Algebra (ring homomorphism composition). -/
theorem eval_substitute (C : AlgCircuit R n) (subs : Fin n → AlgCircuit R n)
    (v : Fin n → R) :
    (C.substitute subs).eval v = C.eval (fun i => (subs i).eval v) := by
  induction C with
  | const _ => simp [AlgCircuit.substitute, AlgCircuit.eval]
  | var _ => simp [AlgCircuit.substitute, AlgCircuit.eval]
  | add _ _ ih₁ ih₂ =>
    simp [AlgCircuit.substitute, AlgCircuit.eval, ih₁, ih₂]
  | mul _ _ ih₁ ih₂ =>
    simp [AlgCircuit.substitute, AlgCircuit.eval, ih₁, ih₂]

/-! ## Depth Lower Bound via Degree

The degree-depth tradeoff gives a lower bound on depth from degree.
If a circuit computes a polynomial of degree d, then depth ≥ ⌈log₂ d⌉.

Bridge: connects Algebra (polynomial degree) to Computation (circuit depth lower bounds)
and Machine Learning (neural network depth requirements). -/

/-- Degree bound of a depth-0 circuit is at most 1.
    Depth-0 circuits are constants (degree 0) or single variables (degree 1). -/
theorem degreeBound_depth_zero (C : AlgCircuit R n) (h : C.depth = 0) :
    C.degreeBound ≤ 1 := by
  cases C with
  | const _ => simp [AlgCircuit.degreeBound]
  | var _ => simp [AlgCircuit.degreeBound]
  | add C₁ C₂ => simp [AlgCircuit.depth] at h
  | mul C₁ C₂ => simp [AlgCircuit.depth] at h

/-- A circuit with degree bound > 2^d must have depth > d.
    This is the contrapositive of the degree-depth tradeoff,
    providing a depth lower bound from degree information.

    Bridge: connects Algebra (high-degree polynomials) to Computation (depth lower bounds)
    and Machine Learning (deep networks required for high-degree activations). -/
theorem depth_lower_bound_from_degree (C : AlgCircuit R n) (d : ℕ)
    (h : 2 ^ d < C.degreeBound) : d < C.depth := by
  by_contra hle
  push_neg at hle
  have := degreeBound_le_two_pow_depth C
  have := Nat.pow_le_pow_right (show 0 < 2 by omega) hle
  omega

end AlgebraicCircuitComplexity