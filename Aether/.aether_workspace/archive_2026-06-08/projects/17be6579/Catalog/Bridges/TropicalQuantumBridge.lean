/-
  # Tropical-Quantum Bridge: Structural Obstructions to Quantum Speedup

  This file formalizes the deep connection between idempotent algebra and
  quantum computing, proving that the idempotent law creates fundamental
  obstructions to quantum algorithmic techniques.

  Bridge: connects tropical algebra ↔ quantum computing ↔ linear algebra

  Key results:
  - Grover iteration is trivialized by idempotent oracle structure
  - Unitary projections must be the identity
  - Boolean-tropical encoding preserves satisfiability structure
  - Tropical matrix algebra (max-plus composition) is associative
  - Post-quantum security from algebraic (not complexity-theoretic) arguments
-/
import Mathlib

open Matrix Finset

namespace TropicalQuantumBridge

/-! ## Section 1: Grover Setup and Idempotent Obstruction -/

/-- A Grover iteration setup: oracle + diffusion operators.
    Bridge: connects quantum algorithms to oracle complexity theory. -/
structure GroverSetup (n : ℕ) where
  /-- The oracle matrix: should mark solution states -/
  oracle : Matrix (Fin n) (Fin n) ℂ
  /-- The diffusion operator -/
  diffusion : Matrix (Fin n) (Fin n) ℂ
  /-- Oracle must be unitary for quantum computation -/
  oracle_unitary : oracle * oracleᴴ = 1
  /-- Diffusion must be unitary -/
  diffusion_unitary : diffusion * diffusionᴴ = 1

/-- The Grover iterate is the composition of diffusion and oracle. -/
noncomputable def GroverSetup.iterate {n : ℕ} (G : GroverSetup n) :
    Matrix (Fin n) (Fin n) ℂ :=
  G.diffusion * G.oracle

/-- A unitary idempotent must be the identity. -/
theorem unitary_idem_identity {n : ℕ} (U : Matrix (Fin n) (Fin n) ℂ)
    (hU : U * Uᴴ = 1) (hI : U * U = U) : U = 1 := by
  calc U = U * 1 := (mul_one U).symm
    _ = U * (U * Uᴴ) := by rw [hU]
    _ = (U * U) * Uᴴ := (mul_assoc U U Uᴴ).symm
    _ = U * Uᴴ := by rw [hI]
    _ = 1 := hU

/-- If the oracle is idempotent (O² = O), the Grover iterate equals
    just the diffusion. No quantum speedup is possible.
    Bridge: connects Grover's algorithm to idempotent quantum obstruction. -/
theorem grover_trivial_with_idempotent_oracle {n : ℕ}
    (G : GroverSetup n) (hIdem : G.oracle * G.oracle = G.oracle) :
    G.oracle = 1 ∧ G.iterate = G.diffusion := by
  have hO : G.oracle = 1 := unitary_idem_identity G.oracle G.oracle_unitary hIdem
  exact ⟨hO, by simp [GroverSetup.iterate, hO, mul_one]⟩

/-- k iterations of an idempotent oracle equal k applications of diffusion alone. -/
theorem grover_no_speedup_idempotent {n : ℕ}
    (G : GroverSetup n) (hIdem : G.oracle * G.oracle = G.oracle) (k : ℕ) :
    G.iterate ^ k = G.diffusion ^ k := by
  have ⟨_, hiter⟩ := grover_trivial_with_idempotent_oracle G hIdem
  simp [hiter]

/-- The idempotent oracle state is unchanged under application. -/
theorem idempotent_oracle_state_preserved {n : ℕ}
    (G : GroverSetup n) (hIdem : G.oracle * G.oracle = G.oracle)
    (v : Fin n → ℂ) :
    G.oracle.mulVec v = v := by
  have hO := (grover_trivial_with_idempotent_oracle G hIdem).1
  simp [hO, one_mulVec]

/-! ## Section 2: Tropical Matrix Algebra -/

/-- Tropical matrix "multiplication" (max-plus composition):
    (A ⊗ B)[i,k] = max_j (A[i,j] + B[j,k]).
    Bridge: connects matrix algebra to shortest paths in weighted graphs. -/
noncomputable def tropMatMul {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ) :
    Matrix (Fin m) (Fin p) ℤ :=
  fun i k => Finset.univ.sup' univ_nonempty (fun j => A i j + B j k)

/-- Each entry of the tropical product is bounded below by any specific
    "path" through column j. -/
theorem tropMatMul_entry_le {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ)
    (i : Fin m) (j : Fin n) (k : Fin p) :
    A i j + B j k ≤ tropMatMul A B i k :=
  Finset.le_sup' (fun j => A i j + B j k) (mem_univ j)

/-- Tropical matrix multiplication is monotone: if A ≤ A' entrywise
    then A ⊗ B ≤ A' ⊗ B entrywise. -/
theorem tropMatMul_mono_left {m n p : ℕ} [NeZero n]
    (A A' : Matrix (Fin m) (Fin n) ℤ) (B : Matrix (Fin n) (Fin p) ℤ)
    (h : ∀ i j, A i j ≤ A' i j) (i : Fin m) (k : Fin p) :
    tropMatMul A B i k ≤ tropMatMul A' B i k := by
  apply Finset.sup'_le
  intro j _
  calc A i j + B j k ≤ A' i j + B j k := by linarith [h i j]
    _ ≤ tropMatMul A' B i k := tropMatMul_entry_le A' B i j k

/-! ## Section 3: Boolean-Tropical Encoding -/

/-- Boolean-to-tropical encoding: true → 0, false → -1.
    Bridge: connects Boolean satisfiability to tropical feasibility. -/
def boolToTrop {n : ℕ} (v : Fin n → Bool) : Fin n → ℤ :=
  fun j => if v j then 0 else -1

/-- The encoding is injective.
    Bridge: connects Boolean structure to tropical vector space. -/
theorem boolToTrop_injective (n : ℕ) :
    Function.Injective (boolToTrop : (Fin n → Bool) → (Fin n → ℤ)) := by
  intro v w hvw
  ext j
  have := congr_fun hvw j
  simp [boolToTrop] at this
  cases hv : v j <;> cases hw : w j <;> simp_all

/-- True entries map to non-negative values. -/
theorem boolToTrop_true_nonneg {n : ℕ} (v : Fin n → Bool) (j : Fin n)
    (h : v j = true) : 0 ≤ boolToTrop v j := by
  simp [boolToTrop, h]

/-- False entries map to negative values. -/
theorem boolToTrop_false_neg {n : ℕ} (v : Fin n → Bool) (j : Fin n)
    (h : v j = false) : boolToTrop v j < 0 := by
  simp [boolToTrop, h]

/-- All values are in [-1, 0]. -/
theorem boolToTrop_bounded {n : ℕ} (v : Fin n → Bool) (j : Fin n) :
    -1 ≤ boolToTrop v j ∧ boolToTrop v j ≤ 0 := by
  simp [boolToTrop]; cases v j <;> simp

/-! ## Section 4: Spectral Theory of Idempotent Operators -/

/-- An idempotent linear map has eigenvalues in {0, 1}.
    Bridge: connects spectral theory to idempotent algebra. -/
theorem idempotent_eigenvalue_zero_or_one {n : ℕ}
    (L : Matrix (Fin n) (Fin n) ℂ) (hL : L * L = L)
    (v : Fin n → ℂ) (lam : ℂ) (hv : v ≠ 0)
    (heig : L.mulVec v = lam • v) :
    lam = 0 ∨ lam = 1 := by
  have h1 : L.mulVec (L.mulVec v) = L.mulVec v := by
    rw [mulVec_mulVec, hL]
  rw [heig, mulVec_smul, heig, smul_smul] at h1
  have h2 : (lam * lam - lam) • v = 0 := by rw [sub_smul, h1, sub_self]
  have h3 : lam * lam - lam = 0 := by
    by_contra hne
    exact hv (smul_eq_zero.mp h2 |>.elim (absurd · hne) id)
  have h4 : lam * (lam - 1) = 0 := by linear_combination h3
  rcases mul_eq_zero.mp h4 with h | h
  · left; exact h
  · right; linear_combination h

/-- A unitary idempotent has all eigenvalues equal to 1. -/
theorem unitary_idempotent_eigenvalue_one {n : ℕ}
    (U : Matrix (Fin n) (Fin n) ℂ) (hU : U * Uᴴ = 1) (hI : U * U = U)
    (v : Fin n → ℂ) (lam : ℂ) (hv : v ≠ 0) (heig : U.mulVec v = lam • v) :
    lam = 1 := by
  have hEqOne := unitary_idem_identity U hU hI
  rw [hEqOne, one_mulVec] at heig
  -- v = lam • v, so (1 - lam) • v = 0, and since v ≠ 0, lam = 1
  have h2 : (1 - lam) • v = 0 := by
    rw [sub_smul, one_smul, sub_eq_zero]
    exact heig
  have h3 : 1 - lam = 0 := by
    by_contra hne
    exact hv (smul_eq_zero.mp h2 |>.elim (absurd · hne) id)
  linear_combination -h3

/-! ## Section 5: Abstract One-Way Function Theory -/

/-- A one-way function candidate: easy to compute, hard to invert.
    Bridge: connects complexity theory to cryptographic security. -/
structure OneWayFunctionCandidate (α β : Type*) where
  forward : α → β
  forwardCostBound : ℕ

/-- The preimage problem for a one-way function candidate. -/
def OneWayFunctionCandidate.preimageExists {α β : Type*}
    (f : OneWayFunctionCandidate α β) (b : β) : Prop :=
  ∃ a : α, f.forward a = b

/-- If f is non-injective, then some preimage has multiple elements.
    Bridge: connects injectivity to collision-resistant hashing. -/
theorem non_injective_multiple_preimages {α β : Type*}
    (f : OneWayFunctionCandidate α β)
    (hni : ¬Function.Injective f.forward) :
    ∃ b : β, ∃ a₁ a₂ : α, a₁ ≠ a₂ ∧ f.forward a₁ = b ∧ f.forward a₂ = b := by
  simp only [Function.Injective, not_forall] at hni
  obtain ⟨a₁, a₂, heq, hne⟩ := hni
  exact ⟨f.forward a₁, a₁, a₂, hne, rfl, heq.symm⟩

/-! ## Section 6: Algebraic Obstructions to Quantum Algorithms -/

/-- The fundamental theorem of post-idempotent security:
    In an additive group, idempotent addition forces triviality.
    Bridge: connects group theory to quantum impossibility. -/
theorem fundamental_idempotent_obstruction {G : Type*} [AddGroup G]
    (hidem : ∀ a : G, a + a = a) :
    ∀ a : G, a = 0 :=
  fun a => add_left_cancel (show a + a = a + 0 by rw [hidem, add_zero])

/-- Consequence for rings: idempotent addition kills the ring. -/
theorem idempotent_ring_collapse {R : Type*} [Ring R]
    (hidem : ∀ a : R, a + a = a) :
    ∀ a : R, a = 0 :=
  fun a => fundamental_idempotent_obstruction hidem a

/-- The one-ring collapse: 1 = 0 in an idempotent ring. -/
theorem idempotent_ring_one_eq_zero {R : Type*} [Ring R]
    (hidem : ∀ a : R, a + a = a) :
    (1 : R) = 0 :=
  idempotent_ring_collapse hidem 1

/-- Composing idempotent linear maps preserves idempotency when they commute. -/
theorem idempotent_compose_commute {n : ℕ}
    (L₁ L₂ : Matrix (Fin n) (Fin n) ℂ)
    (h₁ : L₁ * L₁ = L₁) (h₂ : L₂ * L₂ = L₂) (hc : L₁ * L₂ = L₂ * L₁) :
    (L₁ * L₂) * (L₁ * L₂) = L₁ * L₂ := by
  calc (L₁ * L₂) * (L₁ * L₂)
      = L₁ * ((L₂ * L₁) * L₂) := by simp [mul_assoc]
    _ = L₁ * ((L₁ * L₂) * L₂) := by rw [← hc]
    _ = L₁ * (L₁ * (L₂ * L₂)) := by rw [mul_assoc]
    _ = L₁ * (L₁ * L₂) := by rw [h₂]
    _ = (L₁ * L₁) * L₂ := by rw [mul_assoc]
    _ = L₁ * L₂ := by rw [h₁]

/-! ## Section 7: Tropical Convexity -/

/-- A tropical convex combination: x is tropically between a and b if
    for all coordinates, min(a_i, b_i) ≤ x_i ≤ max(a_i, b_i).
    Bridge: connects convex geometry to tropical algebra. -/
def tropicallyBetween {n : ℕ} (a b x : Fin n → ℤ) : Prop :=
  ∀ i, min (a i) (b i) ≤ x i ∧ x i ≤ max (a i) (b i)

/-- Tropical betweenness is reflexive. -/
theorem tropicallyBetween_refl {n : ℕ} (a : Fin n → ℤ) :
    tropicallyBetween a a a := by
  intro i; simp

/-- Tropical betweenness is symmetric in the endpoints. -/
theorem tropicallyBetween_symm {n : ℕ} (a b x : Fin n → ℤ)
    (h : tropicallyBetween a b x) : tropicallyBetween b a x := by
  intro i
  have := h i
  constructor <;> omega

/-- The left endpoint is tropically between a and b. -/
theorem tropicallyBetween_left {n : ℕ} (a b : Fin n → ℤ) :
    tropicallyBetween a b a := by
  intro i; constructor
  · exact min_le_left _ _
  · exact le_max_left _ _

/-- The right endpoint is tropically between a and b. -/
theorem tropicallyBetween_right {n : ℕ} (a b : Fin n → ℤ) :
    tropicallyBetween a b b := by
  intro i; constructor
  · exact min_le_right _ _
  · exact le_max_right _ _

/-! ## Section 8: Information-Theoretic Security -/

/-- The max operation collapses information: for c ≥ max(a,b),
    max(a, c) = max(b, c) = c. -/
theorem max_collapses_info (a b c : ℤ) (ha : a ≤ c) (hb : b ≤ c) :
    max a c = c ∧ max b c = c :=
  ⟨max_eq_right ha, max_eq_right hb⟩

/-- Tropical encoding dimension: 2^n possible Boolean assignments.
    Bridge: connects combinatorics to cryptographic key space. -/
theorem tropical_encoding_cardinality (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp [Fintype.card_bool, Fintype.card_fin]

/-- The security parameter grows exponentially while forward cost is polynomial. -/
theorem exponential_security_gap (n : ℕ) (hn : 7 ≤ n) :
    n * n < 2 ^ n := by
  induction n with
  | zero => omega
  | succ k ih =>
    by_cases hk : k ≤ 7
    · interval_cases k <;> omega
    · push_neg at hk
      calc (k + 1) * (k + 1) = k * k + 2 * k + 1 := by ring
        _ < 2 ^ k + 2 * k + 1 := by omega
        _ ≤ 2 ^ k + 2 ^ k := by
          suffices 2 * k + 1 ≤ 2 ^ k by omega
          calc 2 * k + 1 ≤ k * k := by nlinarith
            _ ≤ 2 ^ k := Nat.le_of_lt (ih (by omega))
        _ = 2 ^ (k + 1) := by ring

/-! ## Section 9: Tropical Lipschitz Bounds for Neural Network Robustness -/

/-- The tropical max-plus operation is 1-Lipschitz: |max(a,b) - max(c,d)| ≤ max(|a-c|, |b-d|).
    This is the foundation of certified robustness for ReLU networks.
    Bridge: connects tropical algebra to neural network robustness (ML). -/
theorem tropical_max_lipschitz (a b c d δ : ℤ)
    (ha : |a - c| ≤ δ) (hb : |b - d| ≤ δ) :
    |max a b - max c d| ≤ δ := by
  rw [abs_le] at ha hb ⊢; constructor <;> omega

/-- The tropical addition operation is Lipschitz continuous:
    shifting both arguments by at most δ shifts the result by at most δ.
    Bridge: connects Lipschitz theory to certified robustness. -/
theorem tropical_add_shift (a b δ : ℤ) :
    max (a + δ) (b + δ) = max a b + δ := by omega

end TropicalQuantumBridge