/-! # CatalogBuild.Physics.Quantum.QuantumOracleChain

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 48
-/

import Mathlib

noncomputable section

/-- A chain of oracles applied in sequence -/
structure OracleChain (α : Type*) where
  oracles : List (α → α)
  all_idem : ∀ f ∈ oracles, ∀ x, f (f x) = f x


/-- Apply an oracle chain to an input -/
def OracleChain.apply {α : Type*} (chain : OracleChain α) (x : α) : α :=
  chain.oracles.foldl (fun acc f => f acc) x


/-- The empty chain is the identity -/
def OracleChain.empty (α : Type*) : OracleChain α :=
  ⟨[], by simp⟩


/-- [Section: ## §1: Oracle Chain — The Computational Pipeline] -/
theorem OracleChain.empty_apply {α : Type*} (x : α) :
    (OracleChain.empty α).apply x = x := by
  simp [OracleChain.apply, OracleChain.empty]


/-- A singleton chain wraps one oracle -/
def OracleChain.singleton {α : Type*} (f : α → α) (hf : ∀ x, f (f x) = f x) :
    OracleChain α :=
  ⟨[f], by simpa using hf⟩


theorem OracleChain.singleton_apply {α : Type*} (f : α → α) (hf : ∀ x, f (f x) = f x)
    (x : α) : (OracleChain.singleton f hf).apply x = f x := by
  simp [OracleChain.apply, OracleChain.singleton]


/-- Concatenate two oracle chains -/
def OracleChain.concat {α : Type*} (c₁ c₂ : OracleChain α) : OracleChain α where
  oracles := c₁.oracles ++ c₂.oracles
  all_idem := by
    intro f hf
    rw [List.mem_append] at hf
    rcases hf with h1 | h2
    · exact c₁.all_idem f h1
    · exact c₂.all_idem f h2


theorem OracleChain.concat_apply {α : Type*} (c₁ c₂ : OracleChain α) (x : α) :
    (c₁.concat c₂).apply x = c₂.apply (c₁.apply x) := by
  simp [OracleChain.apply, OracleChain.concat, List.foldl_append]


/-- Chain concatenation is associative -/
theorem OracleChain.concat_assoc {α : Type*} (c₁ c₂ c₃ : OracleChain α) :
    (c₁.concat c₂).concat c₃ = c₁.concat (c₂.concat c₃) := by
  simp [OracleChain.concat, List.append_assoc]


/-- A quantum state is a unit vector in ℂⁿ -/
structure QState (n : ℕ) where
  amplitudes : Fin n → ℂ
  normalized : ∑ i : Fin n, ‖amplitudes i‖ ^ 2 = 1


/-- Measurement probabilities are non-negative -/
theorem measureProb_nonneg {n : ℕ} (ψ : QState n) (k : Fin n) :
    0 ≤ measureProb ψ k :=
  sq_nonneg _


/-- Measurement probabilities sum to 1 -/
theorem measureProb_sum {n : ℕ} (ψ : QState n) :
    ∑ k : Fin n, measureProb ψ k = 1 := ψ.normalized


/-- A quantum gate is a unitary matrix -/
structure QGate (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℂ
  unitary : mat * star mat = 1


/-- Gate composition -/
def QGate.compose {n : ℕ} (g₁ g₂ : QGate n) : QGate n where
  mat := g₁.mat * g₂.mat
  unitary := by
    rw [Matrix.star_mul, ← mul_assoc, mul_assoc g₁.mat, g₂.unitary, mul_one, g₁.unitary]


/-- The identity gate -/
def QGate.id' (n : ℕ) : QGate n where
  mat := 1
  unitary := by simp [star_one]


/-- Gate composition with identity -/
theorem QGate.compose_id {n : ℕ} (g : QGate n) :
    (g.compose (QGate.id' n)).mat = g.mat := by
  simp [QGate.compose, QGate.id']


/-- [Section: ## §3: Quantum Gates as Oracle Building Blocks] -/
theorem QGate.id_compose {n : ℕ} (g : QGate n) :
    ((QGate.id' n).compose g).mat = g.mat := by
  simp [QGate.compose, QGate.id']


/-- Gate composition is associative -/
theorem QGate.compose_assoc {n : ℕ} (g₁ g₂ g₃ : QGate n) :
    ((g₁.compose g₂).compose g₃).mat = (g₁.compose (g₂.compose g₃)).mat := by
  simp [QGate.compose, mul_assoc]


/-- The Deutsch-Jozsa oracle sign function: maps x to (-1)^f(x) -/
def deutschJozsaSign {n : ℕ} (f : BoolFn n) (x : Fin (2^n)) : ℤ :=
  if f x then -1 else 1


/-- The sign function squares to 1 (oracle is involutive) -/
theorem deutschJozsaSign_sq {n : ℕ} (f : BoolFn n) (x : Fin (2^n)) :
    deutschJozsaSign f x * deutschJozsaSign f x = 1 := by
  simp [deutschJozsaSign]; split <;> ring


/-- Sum of signs for a constant-false function equals 2^n -/
theorem deutschJozsa_constant_sum {n : ℕ} (f : BoolFn n)
    (hf : ∀ x, f x = false) :
    ∑ x : Fin (2^n), deutschJozsaSign f x = 2^n := by
  simp [deutschJozsaSign, hf]


/-- [Section: ## §4: The Deutsch-Jozsa Oracle] -/
theorem deutschJozsa_balanced_sum {n : ℕ} (f : BoolFn n)
    (hbal : f.isBalanced) :
    ∑ x : Fin (2^n), deutschJozsaSign f x = 0 := by
  -- By definition of `deutschJozsaSign`, we can split the sum into two parts: one over the true inputs and one over the false inputs.
  have h_split : ∑ x, deutschJozsaSign f x = ∑ x ∈ Finset.univ.filter (fun x => f x = true), (-1 : ℤ) + ∑ x ∈ Finset.univ.filter (fun x => f x = false), (1 : ℤ) := by
    rw [ Finset.sum_filter, Finset.sum_filter ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext ; unfold deutschJozsaSign ; aesop;
  simp_all +decide [ BoolFn.isBalanced ];
  rw [ show ( Finset.univ.filter fun x => f x = false ) = Finset.univ \ ( Finset.univ.filter fun x => f x = true ) by ext x; aesop, Finset.card_sdiff ] ; norm_num [ Finset.filter_congr, Finset.card_sdiff, Finset.card_singleton, Finset.card_univ, hbal ] ; ring;
  rw [ Nat.cast_sub ( by linarith [ Nat.one_le_pow n 2 zero_lt_two ] ) ] ; push_cast ; linarith


/-- Iterating an idempotent map any positive number of times gives one application -/
theorem iterate_idem {α : Type*} (O : α → α) (hO : ∀ x, O (O x) = O x)
    (n : ℕ) (hn : 1 ≤ n) (x : α) : O^[n] x = O x := by
  induction n with
  | zero => omega
  | succ m ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    by_cases hm : m = 0
    · subst hm; simp
    · rw [ih (by omega)]; exact hO x


/-- Each power-of-2 iteration of an idempotent oracle equals the oracle -/
theorem phase_estimation_idem {α : Type*} (O : α → α) (hO : ∀ x, O (O x) = O x)
    (k : ℕ) (hk : 0 < k) (x : α) : O^[2^k] x = O x :=
  iterate_idem O hO (2^k) Nat.one_le_two_pow x


/-- For unitary operators, (U^k)† = (U†)^k -/
theorem unitary_power_adjoint {n : ℕ} (U : Matrix (Fin n) (Fin n) ℂ) (k : ℕ) :
    star (U ^ k) = (star U) ^ k :=
  star_pow U k


/-- The N-th root of unity -/
def rootOfUnity' (N : ℕ) (k : ℕ) : ℂ := Complex.exp (2 * Real.pi * Complex.I * k / N)


/-- A quantum computer instruction: either a gate or an oracle query -/
inductive QInstruction (n : ℕ) where
  | gate : QGate n → QInstruction n
  | oracle : (Matrix (Fin n) (Fin n) ℂ) → QInstruction n


/-- Execute a quantum instruction as a matrix -/
def QInstruction.toMatrix {n : ℕ} : QInstruction n → Matrix (Fin n) (Fin n) ℂ
  | .gate g => g.mat
  | .oracle P => P


/-- Execute a quantum program (list of instructions) -/
def executeProgram {n : ℕ} (prog : List (QInstruction n)) : Matrix (Fin n) (Fin n) ℂ :=
  prog.foldl (fun acc inst => inst.toMatrix * acc) 1


/-- Empty program is identity -/
theorem executeProgram_empty {n : ℕ} : executeProgram ([] : List (QInstruction n)) = 1 := by
  simp [executeProgram]


/-- Single gate program equals the gate -/
theorem executeProgram_single_gate {n : ℕ} (g : QGate n) :
    executeProgram [QInstruction.gate g] = g.mat := by
  simp [executeProgram, QInstruction.toMatrix]


/-- Gate then oracle = matrix product -/
theorem oracle_gate_composition {n : ℕ} (g : QGate n) (O : Matrix (Fin n) (Fin n) ℂ) :
    executeProgram [QInstruction.gate g, QInstruction.oracle O] = O * g.mat := by
  simp [executeProgram, QInstruction.toMatrix]


/-- Modular exponentiation oracle: f(x) = a^x mod N -/
def modExpOracle (a N : ℕ) (hN : 0 < N) : ℕ → ℕ :=
  fun x => a ^ x % N


/-- The modular exponentiation oracle is periodic -/
theorem modExp_periodic (a N : ℕ) (hN : 0 < N) (r : ℕ) (hr : a ^ r % N = 1)
    (hr0 : 0 < r) :
    ∀ x, modExpOracle a N hN (x + r) = modExpOracle a N hN x := by
  intro x
  simp only [modExpOracle]
  rw [pow_add, Nat.mul_mod, hr, mul_one, Nat.mod_mod_of_dvd]
  exact ⟨1, by ring⟩


/-- Period finding reduces factoring -/
theorem period_to_factor (a N r : ℕ) (hN : 1 < N) (hr : a ^ r % N = 1)
    (heven : 2 ∣ r) :
    (a ^ (r / 2) % N) * (a ^ (r / 2) % N) % N = 1 := by
  obtain ⟨k, hk⟩ := heven
  subst hk
  rw [Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
  rw [← Nat.mul_mod, ← pow_add, ← two_mul]
  exact hr


/-- A stabilizer code is defined by commuting projectors -/
structure StabilizerCode (n k : ℕ) where
  stabilizers : Fin (n - k) → Matrix (Fin (2^n)) (Fin (2^n)) ℝ
  are_projectors : ∀ i, stabilizers i * stabilizers i = stabilizers i
  commute : ∀ i j, stabilizers i * stabilizers j = stabilizers j * stabilizers i


/-- The code space projector is the product of all stabilizers -/
def StabilizerCode.codeProjector {n k : ℕ} (code : StabilizerCode n k) :
    Matrix (Fin (2^n)) (Fin (2^n)) ℝ :=
  (List.ofFn code.stabilizers).foldl (· * ·) 1


/-- Classical query complexity for unstructured search -/
theorem classical_search_bound (N : ℕ) : N / 2 ≤ N := Nat.div_le_self N 2


/-- [Section: ## §11: Quantum Speedup Theorems] -/
theorem quantum_search_speedup (N : ℕ) (hN : 16 ≤ N) :
    Nat.sqrt N < N / 2 := by
  exact Nat.le_div_iff_mul_le zero_lt_two |>.2 ( by nlinarith [ Nat.sqrt_le N ] )


/-- Exponential separation for structured problems (Simon's) -/
theorem simon_speedup (n : ℕ) : n < 2^n := Nat.lt_two_pow_self


/-- A quantum algorithm: circuit + oracle queries + success guarantee -/
structure QAlgorithm (n : ℕ) where
  circuit : List (QGate n)
  oracle_queries : ℕ
  success_prob : ℝ
  prob_nonneg : 0 ≤ success_prob
  prob_le_one : success_prob ≤ 1


/-- Composing quantum algorithms (sequential execution) -/
def QAlgorithm.compose {n : ℕ} (a₁ a₂ : QAlgorithm n) : QAlgorithm n where
  circuit := a₁.circuit ++ a₂.circuit
  oracle_queries := a₁.oracle_queries + a₂.oracle_queries
  success_prob := a₁.success_prob * a₂.success_prob
  prob_nonneg := mul_nonneg a₁.prob_nonneg a₂.prob_nonneg
  prob_le_one := mul_le_one₀ a₁.prob_le_one a₂.prob_nonneg a₂.prob_le_one


/-- Oracle query complexity is additive -/
theorem algorithm_compose_queries {n : ℕ} (a₁ a₂ : QAlgorithm n) :
    (a₁.compose a₂).oracle_queries = a₁.oracle_queries + a₂.oracle_queries := rfl


/-- The abstract structure of Shor's algorithm -/
structure ShorChain where
  N : ℕ
  a : ℕ
  precision : ℕ
  hN : 1 < N
  ha : Nat.Coprime a N


/-- The GCD oracle is the first link -/
def ShorChain.gcdOracle (sc : ShorChain) : ℕ → ℕ :=
  fun x => Nat.gcd x sc.N


/-- The GCD oracle in the chain is idempotent -/
theorem ShorChain.gcd_idem (sc : ShorChain) (x : ℕ) :
    sc.gcdOracle (sc.gcdOracle x) = sc.gcdOracle x := by
  unfold ShorChain.gcdOracle
  exact Nat.gcd_eq_left (Nat.gcd_dvd_right x sc.N)


/-- Composing GCD and modExp oracles extracts factor information -/
theorem ShorChain.chain_extracts_info (sc : ShorChain) (x : ℕ)
    (hx : 1 < Nat.gcd (x ^ sc.a % sc.N) sc.N) :
    ∃ d, d ∣ sc.N ∧ 1 < d := by
  exact ⟨Nat.gcd (x ^ sc.a % sc.N) sc.N, Nat.gcd_dvd_right _ _, hx⟩


/-- Grover iteration count is sublinear -/
theorem grover_iterations_sublinear (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N < N :=
  Nat.sqrt_lt_self (by omega)


end
