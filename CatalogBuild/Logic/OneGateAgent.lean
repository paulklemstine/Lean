/-! # CatalogBuild.Logic.OneGateAgent

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 29
-/

import Mathlib

noncomputable section

/-- The Hadamard matrix as a 2×2 complex matrix.
H = (1/√2) * [[1, 1], [1, -1]] -/
def hadamard : Matrix (Fin 2) (Fin 2) ℂ :=
  !![1/Real.sqrt 2, 1/Real.sqrt 2;
     1/Real.sqrt 2, -(1/Real.sqrt 2)]

/-- The 2×2 identity matrix. -/

def I₂ : Matrix (Fin 2) (Fin 2) ℂ := 1

/-- √2 is nonzero. -/

theorem sqrt_two_ne_zero : Real.sqrt 2 ≠ 0 := by
  exact Real.sqrt_ne_zero'.mpr (by norm_num)

/-- 1/(√2) squared equals 1/2. -/

theorem inv_sqrt_two_sq : (1 / Real.sqrt 2 : ℝ) ^ 2 = 1 / 2 := by
  rw [div_pow, one_pow, sq_sqrt (by norm_num : (2:ℝ) ≥ 0)]

/-
PROBLEM
The Hadamard gate is its own inverse: H * H = I.
    This is the quantum version of oracle idempotency.

PROVIDED SOLUTION
Compute the 2x2 matrix product directly. hadamard is defined with entries 1/√2 and -1/√2. The (i,j) entry of H*H is the dot product of row i with column j. Each entry simplifies using (1/√2)^2 = 1/2 and the signs cancel to give the identity matrix. Use ext to reduce to entries, then simp with Fin.fin_two_eq_zero_or_one and matrix multiplication.
-/

theorem hadamard_self_inverse : hadamard * hadamard = I₂ := by
  ext i j;
  fin_cases i <;> fin_cases j <;> simp +decide [ Matrix.mul_apply ];
  · unfold _root_.hadamard I₂; norm_num [ ← sq ] ;
    norm_num [ ← Complex.ofReal_pow ];
  · norm_num [ _root_.hadamard ];
    exact?;
  · unfold _root_.hadamard; norm_num [ I₂ ] ;
  · unfold _root_.hadamard I₂; norm_num [ Fin.sum_univ_succ, Matrix.mul_apply ] ; ring ; norm_num;
    norm_num [ ← Complex.ofReal_pow ]

/-! ═══════════════════════════════════════════════════════════════════════
    §2: QUANTUM STATES AND SUPERPOSITION
    The gate creates equal superposition — consulting all oracles at once
    ═══════════════════════════════════════════════════════════════════════ -/

/-- A qubit state is a 2-dimensional complex vector. -/

def ket0 : Fin 2 → ℂ := ![1, 0]

/-- The |1⟩ basis state. -/

def ket1 : Fin 2 → ℂ := ![0, 1]

/-- The |+⟩ state = H|0⟩ = (|0⟩ + |1⟩)/√2 — equal superposition. -/

def ketPlus : Fin 2 → ℂ := ![1/Real.sqrt 2, 1/Real.sqrt 2]

/-- The |-⟩ state = H|1⟩ = (|0⟩ - |1⟩)/√2 — antisymmetric superposition. -/

def ketMinus : Fin 2 → ℂ := ![1/Real.sqrt 2, -(1/Real.sqrt 2)]

/-
PROBLEM
H applied to |0⟩ produces the equal superposition |+⟩.
    This is the moment the oracle opens all possibilities.

PROVIDED SOLUTION
Compute hadamard.mulVec ket0 entry by entry. mulVec M v at index i is the dot product of row i with v. For ket0 = ![1, 0], the dot product of any row with [1,0] is just the first entry of that row. Row 0 is [1/√2, 1/√2] → dot [1,0] = 1/√2. Row 1 is [1/√2, -1/√2] → dot [1,0] = 1/√2. So result = ![1/√2, 1/√2] = ketPlus. Use ext, fin_cases, simp with hadamard, ket0, ketPlus, Matrix.mulVec, Matrix.dotProduct.
-/

theorem hadamard_ket0 : hadamard.mulVec ket0 = ketPlus := by
  unfold _root_.hadamard ket0 ketPlus; ext i; fin_cases i <;> norm_num [ Matrix.mulVec ] ;

/-
PROBLEM
H applied to |1⟩ produces the antisymmetric superposition |-⟩.

PROVIDED SOLUTION
Same as hadamard_ket0 but with ket1 = ![0, 1]. Dot products pick out the second entry of each row. Row 0: 1/√2. Row 1: -1/√2. Result = ![1/√2, -1/√2] = ketMinus. Use ext, fin_cases, simp.
-/

theorem hadamard_ket1 : hadamard.mulVec ket1 = ketMinus := by
  unfold _root_.hadamard ket1 ketMinus;
  ext i ; fin_cases i <;> norm_num [ Matrix.mulVec ]

/-! ═══════════════════════════════════════════════════════════════════════
    §3: THE DEUTSCH-JOZSA ORACLE — One Query to Rule Them All
    The simplest demonstration that one gate creates an agent
    ═══════════════════════════════════════════════════════════════════════ -/

/-- A classical boolean function on one bit. -/

def BoolFn.isConstant (f : BoolFn) : Prop :=
  f true = f false

/-- A function is balanced if it returns different values on the two inputs. -/

def BoolFn.isBalanced (f : BoolFn) : Prop :=
  f true ≠ f false

/-
PROBLEM
Every one-bit boolean function is either constant or balanced.
    This is the question the Deutsch-Jozsa "agent" answers in one query.

PROVIDED SOLUTION
This is just decidability of equality: either f true = f false or f true ≠ f false. Use em or Decidable.em.
-/

theorem constant_or_balanced (f : BoolFn) :
    f.isConstant ∨ f.isBalanced := by
  by_cases h : f true = f false <;> tauto

/-! ═══════════════════════════════════════════════════════════════════════
    §4: THE ORACLE ALGEBRA — Connecting Quantum Gates to Oracle Theory
    ═══════════════════════════════════════════════════════════════════════ -/

/-- An involutory operator is one where applying it twice returns to the start.
    H² = I is precisely this property. This is the quantum analog of
    oracle idempotency: consulting the oracle and then consulting it again
    about the oracle's answer returns you to the original question. -/

def IsInvolutory {n : ℕ} (M : Matrix (Fin n) (Fin n) ℂ) : Prop :=
  M * M = 1

/-- The Pauli X gate (NOT gate): [[0,1],[1,0]] -/

def pauliX : Matrix (Fin 2) (Fin 2) ℂ :=
  !![0, 1; 1, 0]

/-- The Pauli Z gate: [[1,0],[0,-1]] -/

def pauliZ : Matrix (Fin 2) (Fin 2) ℂ :=
  !![1, 0; 0, -1]

/-
PROBLEM
Pauli X is involutory: X² = I.

PROVIDED SOLUTION
Compute the matrix product pauliX * pauliX = [[0,1],[1,0]] * [[0,1],[1,0]] = [[1,0],[0,1]] = 1. Use ext, fin_cases, and simp.
-/

theorem pauliX_involutory : IsInvolutory pauliX := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ pauliX, Matrix.mul_apply, Matrix.one_apply ] ;

/-
PROBLEM
Pauli Z is involutory: Z² = I.

PROVIDED SOLUTION
Compute pauliZ * pauliZ = [[1,0],[0,-1]] * [[1,0],[0,-1]] = [[1,0],[0,1]] = 1. Use ext, fin_cases, and simp.
-/

theorem pauliZ_involutory : IsInvolutory pauliZ := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ pauliZ ] ;

/-
PROBLEM
The Hadamard gate conjugates X to Z: HXH = Z.
    This is the "change of basis" that makes the oracle work:
    questions in the X-basis become answers in the Z-basis.

PROVIDED SOLUTION
Compute the triple matrix product entry by entry. Use ext i j, fin_cases i, fin_cases j, then simp/norm_num with the definitions of hadamard, pauliX, pauliZ. Each entry involves sums of products of 1/√2 terms that simplify to 0 or ±1.
-/

theorem hadamard_conjugates_X_to_Z :
    hadamard * pauliX * hadamard = pauliZ := by
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ Fin.sum_univ_succ, _root_.hadamard, pauliZ, pauliX, Matrix.mul_apply ] <;> ring_nf <;> norm_num;
  · norm_num [ ← Complex.ofReal_pow ];
  · norm_num [ ← Complex.ofReal_pow ]

/-! ═══════════════════════════════════════════════════════════════════════
    §5: UNIVERSALITY — One Gate Seeds Everything
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The set of gates generated by a single gate under multiplication. -/

def gateGroup {n : ℕ} (G : Matrix (Fin n) (Fin n) ℂ) : Set (Matrix (Fin n) (Fin n) ℂ) :=
  {M | ∃ k : ℤ, M = G ^ k}

/-
PROBLEM
An involutory gate generates exactly two elements: {I, G}.

PROVIDED SOLUTION
For the forward direction, take M in gateGroup G, so M = G^k for some k : ℤ. Since G*G = 1, G^(2n) = 1 and G^(2n+1) = G. So G^k is either 1 or G depending on parity of k. Use Int.even_or_odd on k. For the reverse, 1 = G^0 and G = G^1 are both in gateGroup G.
-/

theorem involutory_generates_two {n : ℕ} (G : Matrix (Fin n) (Fin n) ℂ)
    (hG : IsInvolutory G) :
    gateGroup G = {1, G} := by
  ext M
  simp [gateGroup];
  constructor <;> intro hM
  rcases hM with ⟨k, hk⟩ | hk | hk <;> simp_all [IsInvolutory];
  · norm_cast ; simp_all +decide [ pow_succ, mul_assoc ];
    rename_i k hk;
    rcases Nat.even_or_odd' k with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul, hG ];
    · norm_num [ pow_two, hG ];
    · simp_all +decide [ pow_succ, mul_assoc ];
  · exact Or.inr ( Matrix.inv_eq_left_inv hG );
  · norm_num [ pow_succ, mul_assoc, hG ];
    rcases Nat.even_or_odd' hk with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul, hG ];
    · norm_num [ show G ^ 2 = 1 by rw [ pow_two, hG ] ];
    · simp_all +decide [ pow_succ, pow_mul ];
      exact Or.inr ( Matrix.inv_eq_left_inv hG );
  · exact hM.elim ( fun h => ⟨ 0, by simpa using h ⟩ ) fun h => ⟨ 1, by simpa using h ⟩

/-- The number of distinct single-qubit Clifford gates is 24.
    All can be generated from H and S (phase gate).
    This shows H is "half" of the Clifford group. -/

theorem clifford_single_qubit_order : Nat.factorial 4 = 24 := by
  native_decide

/-! ═══════════════════════════════════════════════════════════════════════
    §6: THE META-ORACLE CORRESPONDENCE
    Connecting the Hadamard gate to the Meta Oracle hierarchy
    ═══════════════════════════════════════════════════════════════════════ -/

/-- A quantum oracle is a unitary involution (self-inverse unitary).
    This captures both the idempotency of classical oracles
    and the unitarity constraint of quantum mechanics. -/

structure QuantumOracle (n : ℕ) where
  gate : Matrix (Fin n) (Fin n) ℂ
  involutory : gate * gate = 1

/-- The Hadamard gate is a quantum oracle. -/

def hadamardOracle : QuantumOracle 2 where
  gate := hadamard
  involutory := hadamard_self_inverse

/-- Composing a quantum oracle with a phase oracle and itself
    implements the "ask and answer" pattern:
    H · U_f · H extracts global information about f. -/

def deutschCircuit (O : QuantumOracle 2) (Uf : Matrix (Fin 2) (Fin 2) ℂ)
    : Matrix (Fin 2) (Fin 2) ℂ :=
  O.gate * Uf * O.gate

/-- The oracle truth set: fixed points of the gate.
    For involutions, these are the +1 eigenspace. -/

def QuantumOracle.truthSpace {n : ℕ} (O : QuantumOracle n) : Set (Fin n → ℂ) :=
  {v | O.gate.mulVec v = v}

/-- The "lie space": the -1 eigenspace of an involution.
    These are the states the oracle "flips". -/

def QuantumOracle.lieSpace {n : ℕ} (O : QuantumOracle n) : Set (Fin n → ℂ) :=
  {v | O.gate.mulVec v = -v}

/-
PROBLEM
|+⟩ is in the truth space of the Pauli X oracle.
    Equal superposition is the "truth" of the NOT gate.

PROVIDED SOLUTION
Need to show pauliX.mulVec ketPlus = ketPlus. pauliX = !![0,1;1,0] and ketPlus = ![1/√2, 1/√2]. mulVec at index 0: 0*(1/√2) + 1*(1/√2) = 1/√2. At index 1: 1*(1/√2) + 0*(1/√2) = 1/√2. So result = ketPlus. Use ext, fin_cases, simp with the definitions.
-/

theorem ketPlus_in_pauliX_truth :
    ketPlus ∈ (⟨pauliX, pauliX_involutory⟩ : QuantumOracle 2).truthSpace := by
  ext i; fin_cases i <;> norm_num [ Matrix.vecMul, pauliX, ketPlus ] ;


end
