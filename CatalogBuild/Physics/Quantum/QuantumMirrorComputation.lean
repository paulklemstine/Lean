/-! # CatalogBuild.Physics.Quantum.QuantumMirrorComputation

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 19
-/

import Mathlib

noncomputable section

/-- A QuantumMirror is a projection operator: P² = P and P† = P. -/
structure QuantumMirror (n : ℕ) where
  proj : Matrix (Fin n) (Fin n) ℂ
  idem : proj * proj = proj
  selfAdj : proj.conjTranspose = proj

/-- The identity mirror. -/

def identityMirror (n : ℕ) : QuantumMirror n where
  proj := 1
  idem := by simp [Matrix.mul_one]
  selfAdj := by simp [Matrix.conjTranspose_one]

/-- The zero mirror. -/

def zeroMirror (n : ℕ) : QuantumMirror n where
  proj := 0
  idem := by simp
  selfAdj := by simp [Matrix.conjTranspose_zero]

/-
PROBLEM
**Theorem Ψ.1**: The complement of a mirror is a mirror (idempotent).

PROVIDED SOLUTION
(1-P)(1-P) = 1 - P - P + P*P = 1 - P - P + P = 1 - P. Use P.idem and matrix arithmetic. Try simp with mul_sub, sub_mul, mul_one, one_mul, then use P.idem to simplify.
-/

theorem mirror_complement_idem_qm {n : ℕ} (P : QuantumMirror n) :
    (1 - P.proj) * (1 - P.proj) = (1 - P.proj) := by
  -- Expand the left-hand side using the distributive property.
  simp [mul_sub, sub_mul];
  rw [ P.idem, sub_self ]

/-- **Theorem Ψ.1b**: The complement is self-adjoint. -/

theorem mirror_complement_selfAdj_qm {n : ℕ} (P : QuantumMirror n) :
    (1 - P.proj).conjTranspose = (1 - P.proj) := by
  simp [Matrix.conjTranspose_sub, Matrix.conjTranspose_one, P.selfAdj]

/-- The complement mirror construction. -/

def complementMirror_qm {n : ℕ} (P : QuantumMirror n) : QuantumMirror n where
  proj := 1 - P.proj
  idem := mirror_complement_idem_qm P
  selfAdj := mirror_complement_selfAdj_qm P

/-
PROBLEM
**Theorem Ψ.2**: Mirror and complement are orthogonal: P(I-P) = 0.

PROVIDED SOLUTION
P(1-P) = P - P*P = P - P = 0. Use P.idem.
-/

theorem mirror_complement_orthogonal_qm {n : ℕ} (P : QuantumMirror n) :
    P.proj * (1 - P.proj) = 0 := by
  simp +decide [ mul_sub, P.idem ]

/-- **Theorem Ψ.3**: Mirrors partition the space: P + (I-P) = I. -/

theorem mirror_partition_qm {n : ℕ} (P : QuantumMirror n) :
    P.proj + (1 - P.proj) = 1 := by
  simp [add_sub_cancel]

/-! ## §2: Mirror Chains -/

/-- A quantum mirror chain. -/

structure QuantumMirrorChain (n : ℕ) where
  mirrors : List (Matrix (Fin n) (Fin n) ℂ)
  all_mirrors : ∀ M ∈ mirrors, M * M = M

/-- Execute a mirror chain. -/

def QuantumMirrorChain.execute {n : ℕ} (chain : QuantumMirrorChain n) :
    Matrix (Fin n) (Fin n) ℂ :=
  chain.mirrors.foldl (· * ·) 1

/-- Cost = number of mirrors. -/

def QuantumMirrorChain.cost {n : ℕ} (chain : QuantumMirrorChain n) : ℕ :=
  chain.mirrors.length

/-- **Theorem Φ.1**: Empty chain = identity. -/

theorem empty_chain_is_identity_qm (n : ℕ) :
    (⟨[], fun _ h => by exact absurd h (by simp)⟩ :
      QuantumMirrorChain n).execute = 1 := by
  simp [QuantumMirrorChain.execute]

/-
PROBLEM
**Theorem Φ.2**: Commuting mirrors compose to a mirror.

PROVIDED SOLUTION
(PQ)(PQ) = P(QP)Q = P(PQ)Q = (PP)(QQ) = PQ. Use hcomm to swap QP to PQ, then hP and hQ.
-/

theorem commuting_mirrors_compose_qm {n : ℕ}
    (P Q : Matrix (Fin n) (Fin n) ℂ)
    (hP : P * P = P) (hQ : Q * Q = Q) (hcomm : P * Q = Q * P) :
    (P * Q) * (P * Q) = P * Q := by
  grind

/-! ## §3: Grover's Algorithm as a Mirror Chain -/

/-
PROBLEM
**Theorem Χ.1**: A reflection R = 2P - I satisfies R² = I when P² = P.

PROVIDED SOLUTION
(2P-I)(2P-I) = 4PP - 2P - 2P + I = 4P - 4P + I = I. Use hP : P*P = P and matrix smul/sub arithmetic.
-/

theorem reflection_squared_qm {n : ℕ} (P : Matrix (Fin n) (Fin n) ℂ)
    (hP : P * P = P) :
    (2 • P - 1) * (2 • P - 1) = 1 := by
  simp +decide [ two_smul, sub_mul, mul_sub, hP ];
  norm_num [ add_mul, mul_add, hP ]

/-- **Theorem Χ.2**: Grover's quadratic speedup bound. -/

theorem grover_iterations_bound_qm (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N ≤ N := Nat.sqrt_le_self N

/-
PROBLEM
**Theorem Χ.3**: Grover overshooting detection.

PROVIDED SOLUTION
Since N < k*k, we have sqrt(N) ≤ N < k*k. By Nat.sqrt properties, sqrt(N) < k. Use Nat.sqrt_lt' or similar.
-/

theorem grover_overshooting_qm (k N : ℕ) (hN : 0 < N) (hk : N < k * k) :
    Nat.sqrt N < k := by
  rw [ Nat.sqrt_lt ] ; linarith

/-! ## §4: Mirror Duality -/

/-- **Theorem Θ.1**: Trace of orthogonal mirror product is zero. -/

theorem orthogonal_mirrors_trace_qm {n : ℕ}
    (P Q : Matrix (Fin n) (Fin n) ℂ)
    (hPQ : P * Q = 0) :
    (P * Q).trace = 0 := by
  rw [hPQ]; exact Matrix.trace_zero _ _

/-- **Theorem Θ.2**: Transposition is an involution. -/

theorem transposition_involution_qm {n : ℕ} (i j : Fin n) :
    Equiv.swap i j ∘ Equiv.swap i j = id := by
  ext x; simp

/-- **Theorem Θ.3**: Transposition is its own inverse. -/

theorem transposition_self_inverse_qm {n : ℕ} (i j : Fin n) :
    (Equiv.swap i j).symm = Equiv.swap i j := by
  ext x; simp


end
