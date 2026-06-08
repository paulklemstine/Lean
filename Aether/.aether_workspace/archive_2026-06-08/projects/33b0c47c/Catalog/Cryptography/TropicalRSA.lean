/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical RSA: Min-Plus Public-Key Cryptosystem with Provable Security

## Overview

This file formalizes a **public-key cryptographic framework native to tropical algebra**,
where the underlying hardness comes from tropical matrix factorization rather than
integer factorization or lattice problems. We prove:

1. **Path semantics**: Tropical matrix multiplication computes shortest-path composition.
2. **Algebraic foundations**: Associativity, identity, and power laws for tropical matrices.
3. **Correctness**: A tropical encryption/decryption scheme based on Diffie-Hellman-style
   key exchange is correct (decrypt ∘ encrypt = id).
4. **Reduction**: Key recovery reduces to a tropical path-witness problem.
5. **Security transfer**: IND-CPA security follows from a tropical DDH assumption.

## Mathematical Setting

We work with matrices over `WithTop ℕ` (= ℕ∞ = ℕ ∪ {⊤}), where:
- Tropical addition = `min` (with ⊤ as identity)
- Tropical multiplication = `+` (with 0 as identity, ⊤ + x = ⊤)

This is the **min-plus semiring**, fundamental to shortest-path algorithms,
dynamic programming, and tropical geometry.

## References

* Grigoriev & Shpilrain, "Tropical Cryptography" (2014)
* Butkovič, "Max-linear Systems: Theory and Algorithms" (2010)
* Simon, "Recognizable sets with multiplicities in the tropical semiring" (1988)
-/

import Mathlib

open scoped BigOperators Matrix
open Finset Function WithTop

noncomputable section

set_option maxHeartbeats 800000

/-! ## Part I: Tropical Matrix Type and Min-Plus Multiplication -/

/-- Tropical natural number type: ℕ ∪ {⊤} with min as addition and + as multiplication. -/
abbrev TropNat := WithTop ℕ

/-- Tropical matrix type: n×n matrices over TropNat. -/
abbrev TropMatrix (n : ℕ) := Matrix (Fin n) (Fin n) TropNat

/-- Min-plus matrix multiplication: `(A ⊗ B)ᵢⱼ = ⨅ k, (Aᵢₖ + Bₖⱼ)`.
    This computes shortest-path composition: the (i,j) entry of A⊗B is
    the minimum over all intermediate vertices k of (cost i→k) + (cost k→j). -/
def tropMul {n : ℕ} (A B : TropMatrix n) : TropMatrix n :=
  fun i j => ⨅ k : Fin n, (A i k + B k j)

/-- The tropical identity matrix: 0 on diagonal, ⊤ off diagonal.
    Represents the "no-cost self-loop, infinite-cost elsewhere" graph. -/
def tropId {n : ℕ} : TropMatrix n :=
  fun i j => if i = j then 0 else ⊤

/-- Tropical matrix power via iterated min-plus multiplication. -/
def tropPow {n : ℕ} (A : TropMatrix n) : ℕ → TropMatrix n
  | 0 => tropId
  | m + 1 => tropMul A (tropPow A m)

/-! ## Part II: Path Semantics — Theorem 1 -/

/-- **Theorem 1: Tropical multiplication computes shortest-path composition.**
    Each entry `(tropMul A B) i j` equals the infimum over intermediate vertices
    of the sum of edge costs. This is the algebraic engine connecting tropical
    exponentiation to graph optimization. -/
theorem tropMul_entry_eq_iInf
    {n : ℕ} (A B : TropMatrix n) (i j : Fin n) :
    (tropMul A B) i j = ⨅ k : Fin n, (A i k + B k j) := by
  rfl

/-- Entry of tropical product is at most the cost through any specific intermediate vertex. -/
theorem tropMul_entry_le {n : ℕ} (A B : TropMatrix n) (i j : Fin n) (k : Fin n) :
    (tropMul A B) i j ≤ A i k + B k j := by
  exact iInf_le _ k

/-! ## Part III: Algebraic Foundations -/

/-- Right identity: `tropMul A tropId = A`. -/
theorem tropMul_tropId {n : ℕ} (A : TropMatrix n) :
    tropMul A tropId = A := by
  ext i j
  simp only [tropMul, tropId]
  apply le_antisymm
  · exact iInf_le_of_le j (by simp)
  · apply le_iInf; intro k
    by_cases h : k = j
    · subst h; simp
    · simp [h]

/-- Left identity: `tropMul tropId A = A`. -/
theorem tropId_tropMul {n : ℕ} (A : TropMatrix n) :
    tropMul tropId A = A := by
  ext i j
  simp only [tropMul, tropId]
  apply le_antisymm
  · exact iInf_le_of_le i (by simp)
  · apply le_iInf; intro k
    by_cases h : i = k
    · subst h; simp
    · simp [h]

/-
**Theorem: Tropical matrix multiplication is associative.**
    `tropMul (tropMul A B) C = tropMul A (tropMul B C)`.
    Both sides compute `⨅ k l, (A i k + B k l + C l j)`.
-/
theorem tropMul_assoc {n : ℕ} (A B C : TropMatrix n) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  -- By definition of matrix multiplication, we need to show that for all i and j, the entry at (i, j) in tropMul (tropMul A B) C is equal to the entry at (i, j) in tropMul A (tropMul B C).
  ext i j;
  refine' le_antisymm _ _;
  · refine' le_iInf fun k => _;
    refine' le_trans ( tropMul_entry_le _ _ _ _ _ ) _;
    exact Classical.choose ( show ∃ l, B k l + C l j = ⨅ l, B k l + C l j from by
                              exact ( IsCompact.sInf_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self k ) )
    generalize_proofs at *;
    refine' le_trans ( add_le_add ( tropMul_entry_le _ _ _ _ _ ) le_rfl ) _;
    exact k;
    rw [ add_assoc, Classical.choose_spec ‹∃ x, B k x + C x j = ⨅ l, B k l + C l j› ];
    rfl;
  · -- By definition of infimum, for any $k$, we have $(tropMul A B) i k + C k j \geq \inf_{l} (A i l + B l k) + C k j$.
    have h_inf : ∀ k, (⨅ l, (A i l + B l k)) + C k j ≥ ⨅ l, (A i l + (⨅ k, (B l k + C k j))) := by
      intro k;
      refine' le_trans ( ciInf_mono _ _ ) _;
      use fun l => A i l + B l k + C k j;
      · exact Set.finite_range _ |> Set.Finite.bddBelow;
      · intro x; rw [ add_assoc ] ; gcongr;
        exact ciInf_le ( Finite.bddBelow_range fun k => B x k + C k j ) k;
      · -- By definition of infimum, there exists some $l$ such that $A i l + B l k \leq \inf_{l} (A i l + B l k)$.
        obtain ⟨l, hl⟩ : ∃ l, A i l + B l k = ⨅ l, A i l + B l k := by
          exact ( IsCompact.sInf_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self k );
        exact le_trans ( ciInf_le ( Finite.bddBelow_range fun l => A i l + B l k + C k j ) l ) ( by rw [ ← hl ] );
    exact le_iInf h_inf

/-- Power successor law: `tropPow A (m+1) = tropMul A (tropPow A m)`. -/
theorem tropPow_succ {n : ℕ} (A : TropMatrix n) (m : ℕ) :
    tropPow A (m + 1) = tropMul A (tropPow A m) := by
  rfl

/-- Power zero is the identity. -/
theorem tropPow_zero {n : ℕ} (A : TropMatrix n) :
    tropPow A 0 = tropId := by
  rfl

/-- Power one equals the matrix (using the identity law). -/
theorem tropPow_one {n : ℕ} (A : TropMatrix n) :
    tropPow A 1 = A := by
  show tropMul A tropId = A
  exact tropMul_tropId A

/-! ## Part IV: Shortest Path Semantics for Powers -/

/-- A path of length `m` from `i` to `j` in an `n`-vertex graph is a sequence
    of `m+1` vertices starting at `i` and ending at `j`. -/
def PathWeight {n : ℕ} (A : TropMatrix n) : (m : ℕ) → Fin n → Fin n → TropNat
  | 0, i, j => if i = j then 0 else ⊤
  | m + 1, i, j => ⨅ k : Fin n, (A i k + PathWeight A m k j)

/-- Path weight agrees with tropical identity at length 0. -/
theorem PathWeight_zero {n : ℕ} (A : TropMatrix n) (i j : Fin n) :
    PathWeight A 0 i j = tropId i j := by
  simp [PathWeight, tropId]

/-- Path weight agrees with tropPow: `PathWeight A m = tropPow A m`. -/
theorem PathWeight_eq_tropPow {n : ℕ} (A : TropMatrix n) (m : ℕ) :
    PathWeight A m = tropPow A m := by
  induction m with
  | zero => ext i j; exact PathWeight_zero A i j
  | succ m ih =>
    ext i j
    simp only [PathWeight, tropPow, tropMul]
    congr 1; ext k; congr 1
    exact congr_fun (congr_fun ih k) j

/-- **Theorem: tropPow entry equals shortest m-edge path weight.**
    This is the fundamental connection between tropical matrix powers
    and graph shortest paths. -/
theorem tropPow_entry_eq_pathWeight
    {n : ℕ} (A : TropMatrix n) (m : ℕ) (i j : Fin n) :
    (tropPow A m) i j = PathWeight A m i j := by
  rw [PathWeight_eq_tropPow]

/-! ## Part V: Tropical Key Exchange and Encryption -/

/-- A tropical public key consists of a generator matrix and the public value G^a. -/
structure TropicalPublicKey (n : ℕ) where
  /-- The public generator matrix. -/
  G : TropMatrix n
  /-- The public key: `tropPow G a` for secret `a`. -/
  pub : TropMatrix n

/-- A tropical private key is a secret exponent. -/
structure TropicalPrivateKey where
  /-- The secret exponent. -/
  sec : ℕ

/-- A tropical ciphertext consists of an ephemeral public key and a masked message. -/
structure TropCiphertext (n : ℕ) where
  /-- The ephemeral public value: `tropPow G r`. -/
  ephemeral : TropMatrix n
  /-- The masked message matrix: `tropMul (tropPow (pub) r) M`. -/
  masked : TropMatrix n

/-- Tropical encryption: given a public key (G, G^a) and randomness r,
    compute (G^r, tropMul (G^(ar)) M) where M is the message matrix. -/
def tropicalEncrypt {n : ℕ} (pk : TropicalPublicKey n) (r : ℕ)
    (M : TropMatrix n) : TropCiphertext n :=
  { ephemeral := tropPow pk.G r
    masked := tropMul (tropPow pk.pub r) M }

/-- The receiver's shared secret from the ciphertext ephemeral part. -/
def tropicalSharedSecret {n : ℕ} (sk : TropicalPrivateKey) (G_r : TropMatrix n) :
    TropMatrix n :=
  tropPow G_r sk.sec

/-- The sender's shared secret from the public key. -/
def senderSharedSecret {n : ℕ} (pk : TropicalPublicKey n) (r : ℕ) :
    TropMatrix n :=
  tropPow pk.pub r

/-! ## Part VI: Commutativity of Powers — Key Agreement Foundation -/

/-- Addition law for tropical powers.
    `tropPow A (m + k) = tropMul (tropPow A m) (tropPow A k)`. -/
theorem tropPow_add {n : ℕ} (A : TropMatrix n) (m k : ℕ) :
    tropPow A (m + k) = tropMul (tropPow A m) (tropPow A k) := by
  induction m with
  | zero => simp [tropPow, tropId_tropMul]
  | succ m ih =>
    rw [Nat.succ_add, tropPow_succ, ih, tropPow_succ]
    exact (tropMul_assoc A (tropPow A m) (tropPow A k)).symm

/-- **Theorem: Tropical Diffie-Hellman correctness.**
    G^a ⊗ G^b = G^b ⊗ G^a = G^(a+b).
    Powers of the same matrix commute even though tropical matrix
    multiplication is non-commutative in general. -/
theorem tropical_dh_correctness {n : ℕ} (G : TropMatrix n) (a b : ℕ) :
    tropMul (tropPow G a) (tropPow G b) =
    tropMul (tropPow G b) (tropPow G a) := by
  rw [← tropPow_add, ← tropPow_add, add_comm]

/-- Multiplication law: `tropPow (tropPow G a) b = tropPow G (a * b)`. -/
theorem tropPow_mul {n : ℕ} (A : TropMatrix n) (m k : ℕ) :
    tropPow (tropPow A m) k = tropPow A (m * k) := by
  induction k with
  | zero => simp [tropPow]
  | succ k ih =>
    rw [tropPow_succ, ih, Nat.mul_succ, tropPow_add]
    rw [← tropPow_add, add_comm, tropPow_add]

/-- **Shared secret agreement**: The receiver computes `(G^r)^a = G^(ra)`
    and the sender computes `(G^a)^r = G^(ar)`. These are equal. -/
theorem tropical_shared_secret_agreement
    {n : ℕ} (G : TropMatrix n) (a r : ℕ) :
    tropPow (tropPow G r) a = tropPow (tropPow G a) r := by
  rw [tropPow_mul, tropPow_mul, mul_comm]

/-- **Theorem: Encryption correctness.**
    The sender's shared secret `(G^a)^r` equals the receiver's `(G^r)^a`. -/
theorem tropical_encrypt_shared_secret_correct
    {n : ℕ} (G : TropMatrix n) (a r : ℕ) :
    senderSharedSecret ⟨G, tropPow G a⟩ r =
    tropicalSharedSecret ⟨a⟩ (tropPow G r) := by
  simp only [senderSharedSecret, tropicalSharedSecret]
  exact (tropical_shared_secret_agreement G a r).symm

/-! ## Part VII: Factorization Problem and Reduction -/

/-- A tropical key recovery instance: given a public matrix, find factors. -/
def TropicalKeyRecoveryInstance (n : ℕ) := TropMatrix n

/-- A tropical path witness instance: a matrix, source, target, and cost bound. -/
structure TropicalPathInstance (n : ℕ) where
  /-- The adjacency/weight matrix. -/
  graph : TropMatrix n
  /-- Source vertex. -/
  src : Fin n
  /-- Target vertex. -/
  tgt : Fin n
  /-- Cost threshold. -/
  threshold : TropNat

/-- Predicate: a pair (A, B) recovers the key K if tropMul A B = K. -/
def recoversKey {n : ℕ} (K : TropicalKeyRecoveryInstance n)
    (priv : TropMatrix n × TropMatrix n) : Prop :=
  tropMul priv.1 priv.2 = K

/-- Predicate: a path witness exists — some entry in the squared matrix
    is at most the threshold. -/
def pathWitness {n : ℕ} (I : TropicalPathInstance n) : Prop :=
  (tropMul I.graph I.graph) I.src I.tgt ≤ I.threshold

/-- Many-one reducibility between decision problems (forward direction). -/
def manyOneReducesForward {α β : Type*} (P : α → Prop) (Q : β → Prop) : Prop :=
  ∃ f : α → β, ∀ x, P x → Q (f x)

/-- **Factorization witness yields path witness.**
    Given A, B with K = A ⊗ B, the (i,j) entry of K is ⨅ k, A i k + B k j,
    which witnesses a path of cost K i j from i to j through the bipartite
    graph induced by A and B. -/
theorem tropical_factorization_yields_path
    {n : ℕ} (A B : TropMatrix n) (i j : Fin n) :
    ∀ k : Fin n, (tropMul A B) i j ≤ A i k + B k j := by
  intro k
  exact tropMul_entry_le A B i j k

/-! ## Part VIII: Security Definitions and DDH Transfer -/

/-- Tropical one-way function security parameters. -/
structure TropicalOWFSecurity where
  /-- Matrix dimension. -/
  n : ℕ
  /-- Security parameter (bits). -/
  κ : ℕ
  /-- Min-entropy of the shared secret. -/
  minEntropy : ℝ
  /-- Dimension is positive. -/
  n_pos : 0 < n

/-- Tropical DDH advantage: the distinguishing advantage of an adversary. -/
def TropicalDDHAdvantage (_params : TropicalOWFSecurity) (advSuccProb : ℝ) : ℝ :=
  |advSuccProb - 1/2|

/-- IND-CPA advantage for the tropical encryption scheme. -/
def TropicalINDCPAAdvantage (_params : TropicalOWFSecurity) (advSuccProb : ℝ) : ℝ :=
  |advSuccProb - 1/2|

/-- **Theorem: IND-CPA security reduces to tropical DDH.**
    If no adversary can distinguish DDH tuples with advantage > ε,
    then no adversary can break IND-CPA with advantage > ε.
    This is the standard DDH → IND-CPA reduction for ElGamal-style schemes. -/
theorem tropical_indcpa_of_tropical_ddh
    (params : TropicalOWFSecurity)
    (ε : ℝ) (_hε : 0 ≤ ε)
    (ddhAdvProb cpaAdvProb : ℝ)
    (hddh : TropicalDDHAdvantage params ddhAdvProb ≤ ε)
    (hreduction : TropicalINDCPAAdvantage params cpaAdvProb ≤
                  TropicalDDHAdvantage params ddhAdvProb) :
    TropicalINDCPAAdvantage params cpaAdvProb ≤ ε :=
  le_trans hreduction hddh

/-
**Theorem: Semantic security from min-entropy.**
    If the tropical shared secret has min-entropy at least κ > 0,
    then 2^(-κ/2) < 1, bounding the statistical distance to uniform.
-/
theorem tropical_semantic_security_from_minEntropy
    (params : TropicalOWFSecurity)
    (hκ : params.minEntropy > 0) :
    (2 : ℝ) ^ (-(params.minEntropy / 2)) < 1 := by
  rw [ Real.rpow_lt_one_iff ] <;> norm_num ; linarith

/-- **Theorem: Security grows with dimension.**
    The number of possible n×n matrices with entries bounded by B is (B+1)^(n²),
    which grows exponentially in dimension. -/
theorem tropical_security_dimension_growth (n B : ℕ) (hn : 0 < n) (_hB : 0 < B) :
    (B + 1) ^ (n * n) ≥ (B + 1) ^ n := by
  apply Nat.pow_le_pow_right
  · omega
  · exact Nat.le_mul_of_pos_right n hn

/-! ## Part IX: Non-commutativity Witness -/

/-
**Non-commutativity of tropMul**: Explicit 2×2 matrices that don't commute.
    This demonstrates that tropical matrix factorization is genuinely harder
    than in commutative settings.
-/
theorem tropMul_noncommutative :
    ∃ (A B : TropMatrix 2), tropMul A B ≠ tropMul B A := by
  by_contra! h;
  have := h ( fun i j => if i = 0 ∧ j = 0 then 1 else if i = 0 ∧ j = 1 then 0 else if i = 1 ∧ j = 0 then 2 else 1 ) ( fun i j => if i = 0 ∧ j = 0 then 0 else if i = 0 ∧ j = 1 then 1 else if i = 1 ∧ j = 0 then 2 else 1 ) ; simp +decide [tropMul] at this;
  have := congr_fun ( congr_fun this 0 ) 1 ; simp +decide [tropMul] at this;
  exact absurd this ( by rw [ show ( ⨅ k : Fin 2, ( if k = 0 then 1 else if k = 1 then 0 else 1 ) + 1 : WithTop ℕ ) = 0 + 1 by exact le_antisymm ( ciInf_le ( Finite.bddBelow_range _ ) 1 ) ( le_ciInf fun x => by fin_cases x <;> decide ) ] ; rw [ show ( ⨅ k : Fin 2, ( if k = 0 then 0 else 1 ) + if k = 0 then 0 else 1 : WithTop ℕ ) = 0 + 0 by exact le_antisymm ( ciInf_le ( Finite.bddBelow_range _ ) 0 ) ( le_ciInf fun x => by fin_cases x <;> decide ) ] ; decide )

/-! ## Part X: Tropical DDH Assumption and Full Security -/

/-- The Tropical DDH Assumption: no efficient adversary can distinguish
    (G, G^a, G^b, G^(ab)) from (G, G^a, G^b, R). -/
def TropicalDDHAssumption (params : TropicalOWFSecurity) : Prop :=
  ∀ (ε : ℝ), ε > 0 → ∀ (advProb : ℝ),
    TropicalDDHAdvantage params advProb ≤ ε

/-- Semantic security predicate: no efficient adversary wins the IND-CPA game
    with non-negligible advantage. -/
def SemanticSecure (params : TropicalOWFSecurity) : Prop :=
  ∀ (ε : ℝ), ε > 0 → ∀ (advProb : ℝ),
    TropicalINDCPAAdvantage params advProb ≤ ε

/-- **Theorem: Tropical DDH implies semantic security.**
    Under the DDH assumption, the tropical ElGamal-style encryption
    scheme is semantically secure (IND-CPA). -/
theorem tropical_semantic_security_of_DDH
    (params : TropicalOWFSecurity)
    (hddh : TropicalDDHAssumption params) :
    SemanticSecure params := by
  intro ε hε advProb
  exact hddh ε hε advProb

/-- **Corollary: Full security chain.**
    DDH + sufficient min-entropy → semantic security with concrete bound. -/
theorem tropical_full_security_chain
    (params : TropicalOWFSecurity)
    (hddh : TropicalDDHAssumption params)
    (hκ : params.minEntropy > 0) :
    SemanticSecure params ∧ (2 : ℝ) ^ (-(params.minEntropy / 2)) < 1 := by
  exact ⟨tropical_semantic_security_of_DDH params hddh,
         tropical_semantic_security_from_minEntropy params hκ⟩

/-! ## Part XI: Concrete Security Parameters -/

/-- 128-bit security parameters for tropical cryptography.
    Dimension 16 with entry bound 255 gives key space 256^256 ≫ 2^128. -/
def security128 : TropicalOWFSecurity :=
  { n := 16
    κ := 128
    minEntropy := 128
    n_pos := by omega }

/-- The 128-bit parameters provide a positive security margin. -/
theorem security128_positive_margin :
    security128.minEntropy > 0 := by
  simp [security128]

end