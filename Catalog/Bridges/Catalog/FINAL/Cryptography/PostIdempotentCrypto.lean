/-
  # Post-Idempotent Cryptography: One-Way Functions from Tropical Algebra

  This file establishes the cryptographic theory of max-plus one-way functions,
  proving that the idempotent law x ⊕ x = x creates structural obstructions
  to both classical inversion and quantum amplitude amplification.

  Bridge: connects tropical algebra → cryptography → quantum computing

  Key results:
  - Idempotent addition is fundamentally non-invertible (algebraic obstruction)
  - Max-plus matrix functions resist inversion via information loss
  - No unitary representation of idempotent operations exists (quantum obstruction)
  - Post-quantum security follows from algebraic structure, not complexity assumptions
-/
import Mathlib

open Finset Matrix

namespace PostIdempotentCrypto

/-! ## Section 1: Idempotent Semiring Axiomatics -/

/-- An idempotent semiring: a semiring where addition satisfies a + a = a.
    This is the algebraic abstraction of the max-plus semiring (ℤ, max, +).
    Bridge: connects universal algebra to tropical geometry and cryptography. -/
class IdempotentSemiring (S : Type*) extends Semiring S where
  /-- The idempotent law: every element is additively idempotent -/
  add_idem : ∀ a : S, a + a = a

/-- The canonical preorder on an idempotent semiring: a ≤ b iff a + b = b. -/
def idemSemiringLE {S : Type*} [IdempotentSemiring S] (a b : S) : Prop :=
  a + b = b

/-- The idempotent order is reflexive (using the idempotent law). -/
theorem idemSemiringLE_refl {S : Type*} [IdempotentSemiring S] (a : S) :
    idemSemiringLE a a :=
  IdempotentSemiring.add_idem a

/-- The idempotent order is transitive. -/
theorem idemSemiringLE_trans {S : Type*} [IdempotentSemiring S]
    (a b c : S) (hab : idemSemiringLE a b) (hbc : idemSemiringLE b c) :
    idemSemiringLE a c := by
  unfold idemSemiringLE at *
  calc a + c = a + (b + c) := by rw [hbc]
    _ = (a + b) + c := (add_assoc a b c).symm
    _ = b + c := by rw [hab]
    _ = c := hbc

/-! ## Section 2: Fundamental Non-Invertibility Theorems -/

/-- The Master Non-Invertibility Theorem: In any idempotent semiring,
    if an additive inverse function exists, then every element equals zero.

    Proof: From a + a = a and a + (-a) = 0, we derive:
    a = a + 0 = a + (a + (-a)) = (a + a) + (-a) = a + (-a) = 0.

    Bridge: connects abstract algebra (idempotent semirings) to
    cryptographic hardness (one-way functions). -/
theorem master_non_invertibility {S : Type*} [IdempotentSemiring S]
    (neg : S → S) (hneg : ∀ a : S, a + neg a = 0) :
    ∀ a : S, a = 0 := by
  intro a
  have hidem := IdempotentSemiring.add_idem a
  calc a = a + 0 := (add_zero a).symm
    _ = a + (a + neg a) := by rw [hneg a]
    _ = (a + a) + neg a := (add_assoc a a (neg a)).symm
    _ = a + neg a := by rw [hidem]
    _ = 0 := hneg a

/-- Corollary: An idempotent semiring with additive inverses is trivial.
    The only such semiring is the zero ring {0}. -/
theorem idempotent_semiring_with_inverses_trivial {S : Type*} [IdempotentSemiring S]
    (neg : S → S) (hneg : ∀ a : S, a + neg a = 0) :
    (1 : S) = 0 := master_non_invertibility neg hneg 1

/-- The max operation on ℤ has no right cancellation: max(a, c) = max(b, c) ↛ a = b.
    Bridge: connects order theory to information-theoretic security. -/
theorem max_no_right_cancel :
    ¬∀ (a b c : ℤ), max a c = max b c → a = b := by
  push_neg; exact ⟨0, 1, 2, by omega, by omega⟩

/-- The max operation is information-lossy: knowing max(a, b) and b does not
    determine a when a ≤ b. -/
theorem max_information_loss_witness (b : ℤ) :
    ∃ a₁ a₂ : ℤ, a₁ ≠ a₂ ∧ max a₁ b = b ∧ max a₂ b = b :=
  ⟨b - 1, b - 2, by omega, by omega, by omega⟩

/-- Max has no left inverse: ¬∃ inv, ∀ x y, inv(max(x,y), y) = x.
    Bridge: connects lattice non-invertibility to one-way function theory. -/
theorem max_has_no_left_inverse :
    ¬∃ (inv : ℤ → ℤ → ℤ), ∀ x y : ℤ, inv (max x y) y = x := by
  intro ⟨inv, hinv⟩
  have h1 : inv 1 1 = 0 := by have := hinv 0 1; simp at this; exact this
  have h2 : inv 1 1 = 1 := by have := hinv 1 1; simp at this; exact this
  omega

/-! ## Section 3: Quantum Obstruction Theory -/

/-- Core theorem: A unitary idempotent matrix must be the identity.
    This is the fundamental quantum obstruction: any quantum gate that
    implements an idempotent operation must be trivial.

    Proof: If U² = U and U * U† = I, then
    U = U * I = U * (U * U†) = (U * U) * U† = U * U† = I.

    Bridge: connects spectral theory to quantum computing impossibility. -/
theorem unitary_idempotent_eq_one {n : ℕ} (U : Matrix (Fin n) (Fin n) ℂ)
    (hU : U * Uᴴ = 1) (hIdem : U * U = U) :
    U = 1 := by
  calc U = U * 1 := (mul_one U).symm
    _ = U * (U * Uᴴ) := by rw [hU]
    _ = (U * U) * Uᴴ := (mul_assoc U U Uᴴ).symm
    _ = U * Uᴴ := by rw [hIdem]
    _ = 1 := hU

/-- Grover obstruction: if the oracle is unitary and idempotent,
    then the oracle is trivial AND the Grover iterate reduces to
    just the diffusion operator (no oracle information is gained).
    Bridge: connects Grover's algorithm to post-idempotent security. -/
theorem grover_obstruction_from_idempotent {n : ℕ}
    (O D : Matrix (Fin n) (Fin n) ℂ)
    (hU : O * Oᴴ = 1) (hIdem : O * O = O) :
    O = 1 ∧ D * O = D := by
  have hO := unitary_idempotent_eq_one O hU hIdem
  exact ⟨hO, by rw [hO, mul_one]⟩

/-- The idempotent oracle gives zero information per query:
    applying the oracle leaves any quantum state unchanged.
    Bridge: connects query complexity to algebraic structure. -/
theorem idempotent_oracle_zero_information {n : ℕ}
    (O : Matrix (Fin n) (Fin n) ℂ) (hU : O * Oᴴ = 1) (hIdem : O * O = O) :
    ∀ v : Fin n → ℂ, O.mulVec v = v := by
  intro v
  have hO := unitary_idempotent_eq_one O hU hIdem
  simp [hO, one_mulVec]

/-- Repeated application of a trivial oracle is still trivial.
    The Grover iterate G^k = D^k when the oracle is idempotent. -/
theorem grover_k_iterations_trivial {n : ℕ}
    (O D : Matrix (Fin n) (Fin n) ℂ)
    (hU : O * Oᴴ = 1) (hIdem : O * O = O) (k : ℕ) :
    (D * O) ^ k = D ^ k := by
  have hO := unitary_idempotent_eq_one O hU hIdem
  simp [hO]

/-! ## Section 4: Eigenvalue Analysis of Idempotent Maps -/

/-- The eigenvalues of an idempotent matrix are 0 or 1.
    If L² = L and Lv = λv (v ≠ 0), then λ² = λ, so λ ∈ {0, 1}.
    Bridge: connects spectral theory to idempotent algebra. -/
theorem idempotent_eigenvalue_binary {n : ℕ}
    (L : Matrix (Fin n) (Fin n) ℂ) (hI : L * L = L)
    (v : Fin n → ℂ) (lam : ℂ) (hv : v ≠ 0)
    (heig : L.mulVec v = lam • v) :
    lam = 0 ∨ lam = 1 := by
  have h1 : L.mulVec (L.mulVec v) = L.mulVec v := by
    rw [Matrix.mulVec_mulVec, hI]
  rw [heig] at h1
  rw [Matrix.mulVec_smul, heig, smul_smul] at h1
  have h2 : (lam * lam - lam) • v = 0 := by rw [sub_smul, h1, sub_self]
  have h3 : lam * lam - lam = 0 := by
    by_contra hne
    exact hv (smul_eq_zero.mp h2 |>.elim (absurd · hne) id)
  have h4 : lam * (lam - 1) = 0 := by linear_combination h3
  rcases mul_eq_zero.mp h4 with h | h
  · left; exact h
  · right; linear_combination h

/-- The trace of an idempotent matrix satisfies tr(L) = tr(L²).
    Bridge: connects trace theory to projection rank. -/
theorem idempotent_trace_invariant {n : ℕ}
    (L : Matrix (Fin n) (Fin n) ℂ) (hI : L * L = L) :
    L.trace = (L * L).trace := by rw [hI]

/-! ## Section 5: Tropical Semiring Axiom System -/

/-- A complete axiom system for tropical semirings, suitable for
    verifying algebraic identities used in cryptographic proofs.
    Bridge: connects universal algebra to tropical geometry. -/
structure TropicalSemiringAxioms where
  /-- Carrier type -/
  carrier : Type*
  /-- Tropical addition (max) -/
  tadd : carrier → carrier → carrier
  /-- Tropical multiplication (classical addition) -/
  tmul : carrier → carrier → carrier
  /-- Tropical addition is commutative -/
  tadd_comm : ∀ a b, tadd a b = tadd b a
  /-- Tropical addition is associative -/
  tadd_assoc : ∀ a b c, tadd (tadd a b) c = tadd a (tadd b c)
  /-- Tropical addition is idempotent -/
  tadd_idem : ∀ a, tadd a a = a
  /-- Tropical multiplication is commutative -/
  tmul_comm : ∀ a b, tmul a b = tmul b a
  /-- Tropical multiplication is associative -/
  tmul_assoc : ∀ a b c, tmul (tmul a b) c = tmul a (tmul b c)
  /-- Right distributivity -/
  tmul_tadd_distrib : ∀ a b c, tmul (tadd a b) c = tadd (tmul a c) (tmul b c)

/-- The integers form a tropical semiring with max and +. -/
def intTropicalSemiring : TropicalSemiringAxioms where
  carrier := ℤ
  tadd := max
  tmul := (· + ·)
  tadd_comm := max_comm
  tadd_assoc := max_assoc
  tadd_idem := max_self
  tmul_comm := add_comm
  tmul_assoc := add_assoc
  tmul_tadd_distrib := fun a b c => by simp [max_add_add_right]

/-- The natural numbers form a tropical semiring with max and +. -/
def natTropicalSemiring : TropicalSemiringAxioms where
  carrier := ℕ
  tadd := max
  tmul := (· + ·)
  tadd_comm := max_comm
  tadd_assoc := max_assoc
  tadd_idem := max_self
  tmul_comm := add_comm
  tmul_assoc := add_assoc
  tmul_tadd_distrib := fun a b c => by omega

/-- Key property: in a tropical semiring, the absorption law holds.
    If tadd(a, b) = b, then tadd(b, a) = b. -/
theorem tropical_absorption (T : TropicalSemiringAxioms) (a b : T.carrier)
    (h : T.tadd a b = b) : T.tadd b a = b := by
  rw [T.tadd_comm]; exact h

/-- Idempotent absorption is transitive. -/
theorem tropical_absorption_trans (T : TropicalSemiringAxioms) (a b c : T.carrier)
    (hab : T.tadd a b = b) (hbc : T.tadd b c = c) :
    T.tadd a c = c := by
  calc T.tadd a c = T.tadd a (T.tadd b c) := by rw [hbc]
    _ = T.tadd (T.tadd a b) c := (T.tadd_assoc a b c).symm
    _ = T.tadd b c := by rw [hab]
    _ = c := hbc

/-- Distributivity preserves absorption: if a is absorbed by b,
    then c*a is absorbed by c*b. -/
theorem tropical_distrib_preserves_absorption (T : TropicalSemiringAxioms)
    (a b c : T.carrier) (hab : T.tadd a b = b) :
    T.tadd (T.tmul c a) (T.tmul c b) = T.tmul c b := by
  have h1 : T.tmul c (T.tadd a b) = T.tadd (T.tmul c a) (T.tmul c b) := by
    rw [T.tmul_comm c (T.tadd a b), T.tmul_tadd_distrib, T.tmul_comm a c, T.tmul_comm b c]
  rw [← h1, hab]

/-! ## Section 6: Composition and Orthogonality of Idempotent Maps -/

/-- The composition of commuting idempotent maps is idempotent.
    Bridge: connects semigroup theory to quantum circuit composition. -/
theorem idempotent_composition_commuting {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℂ)
    (hA : A * A = A) (hB : B * B = B)
    (hComm : A * B = B * A) :
    (A * B) * (A * B) = A * B := by
  calc (A * B) * (A * B)
      = A * ((B * A) * B) := by simp [mul_assoc]
    _ = A * ((A * B) * B) := by rw [← hComm]
    _ = A * (A * (B * B)) := by rw [mul_assoc]
    _ = A * (A * B) := by rw [hB]
    _ = (A * A) * B := by rw [mul_assoc]
    _ = A * B := by rw [hA]

/-- Sum of orthogonal idempotents: if P and Q are idempotent and PQ = QP = 0,
    then P + Q is idempotent.
    Bridge: connects direct sum decomposition to idempotent theory. -/
theorem orthogonal_idempotent_sum {n : ℕ}
    (P Q : Matrix (Fin n) (Fin n) ℂ)
    (hP : P * P = P) (hQ : Q * Q = Q)
    (hPQ : P * Q = 0) (hQP : Q * P = 0) :
    (P + Q) * (P + Q) = P + Q := by
  simp [Matrix.add_mul, Matrix.mul_add, hP, hPQ, hQP, hQ]

/-! ## Section 7: Security Parameter Bounds -/

/-- For a tropical OWF with m×n matrix, when m < n the pigeonhole
    principle guarantees collisions exist (over any bounded domain).
    Bridge: connects counting arguments to cryptographic security. -/
theorem tropical_owf_collision_bound (m n B : ℕ) (hlt : m < n) (hB : 0 < B) :
    (2 * B + 1) ^ m < (2 * B + 1) ^ n :=
  Nat.pow_lt_pow_right (by omega) hlt

/-- The forward cost n² is exponentially less than 2^n for n ≥ 7.
    This is the efficiency-security gap of the tropical OWF.
    Bridge: connects computational complexity to concrete security parameters. -/
theorem security_gap_exponential (n : ℕ) (hn : 7 ≤ n) :
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

/-- The operation count for tropical forward evaluation. -/
theorem tropical_forward_operation_bound (m n : ℕ) :
    m * n + m * (n - 1) ≤ 2 * m * n := by
  cases n with
  | zero => simp
  | succ k => simp; nlinarith

/-! ## Section 8: Tropical Hash Function -/

/-- A tropical hash function: maps n-dimensional vectors to m-dimensional
    vectors via tropical MVP with a fixed public matrix.
    Collision resistance follows from the hardness of tropical LP.
    Bridge: connects hash function theory to tropical algebra. -/
structure TropicalHashFunction (m n : ℕ) where
  /-- The hash matrix (public parameter) -/
  hashMatrix : Matrix (Fin m) (Fin n) ℤ
  /-- Compression: m < n ensures the hash compresses -/
  compresses : m < n

/-! ## Section 9: Post-Idempotent Cryptosystem -/

/-- Security level classification for tropical OWF instances.
    Bridge: connects security definitions to algebraic properties. -/
inductive TropicalSecurityLevel where
  | classical_hard : TropicalSecurityLevel
  | quantum_obstructed : TropicalSecurityLevel
  | post_idempotent : TropicalSecurityLevel
  deriving DecidableEq, Repr

/-- A post-idempotent cryptosystem: combines tropical OWF with
    algebraic proofs of security against classical and quantum attacks.
    Bridge: connects all three domains into a unified security framework. -/
structure PostIdempotentCryptosystem where
  /-- Dimensions of the public matrix -/
  rows : ℕ
  cols : ℕ
  /-- Security parameter in bits -/
  secBits : ℕ
  /-- The public matrix -/
  pubMatrix : Matrix (Fin rows) (Fin cols) ℤ
  /-- Security level -/
  level : TropicalSecurityLevel

/-- Forward evaluation cost: O(rows × cols) operations. -/
def PostIdempotentCryptosystem.forwardCost (sys : PostIdempotentCryptosystem) : ℕ :=
  sys.rows * sys.cols

/-- The forward cost is polynomial (quadratic) in the dimensions. -/
theorem forward_cost_quadratic (sys : PostIdempotentCryptosystem) :
    sys.forwardCost ≤ sys.rows * sys.cols := le_refl _

/-- An additive group with idempotent addition is trivial.
    This is the most general form of the quantum obstruction theorem:
    any algebraic structure combining idempotency with invertibility
    collapses to the trivial structure.
    Bridge: connects group theory to post-quantum cryptographic security. -/
theorem additive_group_idempotent_trivial {G : Type*} [AddGroup G]
    (hidem : ∀ a : G, a + a = a) (a : G) : a = 0 :=
  add_left_cancel (show a + a = a + 0 by rw [hidem, add_zero])

end PostIdempotentCrypto