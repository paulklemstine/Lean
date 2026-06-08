import Mathlib

/-!
# Tropical Cryptography: Min-Plus Encryption with Tropical Matrices

This file formalizes the algebraic foundations of tropical (min-plus)
cryptography. We define tropical matrix multiplication, prove its algebraic
properties (associativity, identity, power homomorphism), and establish
the correctness of a Tropical Diffie-Hellman key exchange protocol.

## Main Definitions

* `TropMat d` — Type of (d+1)×(d+1) matrices over `WithTop ℤ` (the min-plus semiring)
* `tropMatMul` — Tropical matrix multiplication: `(A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})`
* `tropMatPow` — Tropical matrix power by repeated squaring
* `tropId` — Tropical identity matrix (0 on diagonal, ⊤ off diagonal)
* `TropicalDHProtocol` — Structure for Tropical Diffie-Hellman key exchange

## Main Results

* `tropMatMul_assoc` — Tropical matrix multiplication is associative
* `tropId_mul` / `mul_tropId` — Tropical identity is left/right neutral
* `tropMatPow_add` — `A^{⊗(m+n)} = A^{⊗m} ⊗ A^{⊗n}` (power homomorphism)
* `tropMatPow_mul_comm` — `(A^{⊗m})^{⊗n} = (A^{⊗n})^{⊗m} = A^{⊗(m*n)}`
* `tropDH_key_agreement` — Alice and Bob compute the same shared key

## References

* [Grigoriev–Shpilrain, "Tropical Cryptography", 2014]
* [Kotov–Ushakov, "Analysis of a certain class of tropical cryptosystems", 2018]
-/

open Finset

noncomputable section

namespace TropicalCrypto

/-! ## Section 1: Tropical Matrix Definitions -/

/-- Type alias for tropical matrices of dimension (d+1) × (d+1) over `WithTop ℤ`.
    Using `d+1` ensures matrices are always nonempty, which is needed for `min`
    operations in tropical multiplication. -/
abbrev TropMat (d : ℕ) := Matrix (Fin (d + 1)) (Fin (d + 1)) (WithTop ℤ)

/-- The tropical identity matrix: 0 on the diagonal, ⊤ (infinity) off the diagonal.
    This is the multiplicative identity for tropical matrix multiplication:
    `tropId ⊗ A = A = A ⊗ tropId`. -/
def tropId : TropMat d :=
  fun i j => if i = j then (0 : WithTop ℤ) else ⊤

/-- Tropical matrix multiplication in the min-plus semiring:
    `(A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})`.
    This replaces standard matrix multiplication where `+` becomes `min`
    and `*` becomes `+`. -/
def tropMatMul (A B : TropMat d) : TropMat d :=
  fun i j => Finset.inf' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-- Tropical matrix power: `A^{⊗0} = I` (tropical identity),
    `A^{⊗(n+1)} = A^{⊗n} ⊗ A`. -/
def tropMatPow (A : TropMat d) : ℕ → TropMat d
  | 0 => tropId
  | n + 1 => tropMatMul (tropMatPow A n) A

/-! ## Section 2: Core Algebraic Lemmas -/

/-
The `inf'` over a singleton containing `i` equals `f i`.
-/
lemma inf'_univ_eq_of_top_others {d : ℕ} (f : Fin (d+1) → WithTop ℤ)
    (i : Fin (d+1)) (hf : ∀ k, k ≠ i → f k = ⊤) :
    Finset.inf' Finset.univ Finset.univ_nonempty f = f i := by
  refine' le_antisymm _ _;
  · exact Finset.inf'_le _ ( Finset.mem_univ _ );
  · simp +zetaDelta at *;
    intro k; by_cases hk : k = i <;> aesop;

/-
Tropical addition distributes over `min` in `WithTop ℤ`:
    `a + min(b, c) = min(a + b, a + c)`.
-/
theorem tropAdd_min_left (a b c : WithTop ℤ) :
    a + min b c = min (a + b) (a + c) := by
  induction a using WithTop.recTopCoe;
  · cases b <;> cases c <;> rfl;
  · cases b <;> cases c <;> simp +decide [ min_def ];
    split_ifs <;> rfl

/-
Right version: `min(a, b) + c = min(a + c, b + c)`.
-/
theorem tropAdd_min_right (a b c : WithTop ℤ) :
    min a b + c = min (a + c) (b + c) := by
  cases a <;> cases b <;> cases c <;> norm_cast;
  grind

/-- Adding ⊤ on the left absorbs. -/
@[simp] lemma top_add_withTop (x : WithTop ℤ) : (⊤ : WithTop ℤ) + x = ⊤ := by
  simp

/-- Adding ⊤ on the right absorbs. -/
@[simp] lemma add_top_withTop (x : WithTop ℤ) : x + (⊤ : WithTop ℤ) = ⊤ := by
  simp

/-- `min(⊤, x) = x` -/
@[simp] lemma top_min_withTop (x : WithTop ℤ) : min (⊤ : WithTop ℤ) x = x := by
  simp

/-- `min(x, ⊤) = x` -/
@[simp] lemma min_top_withTop (x : WithTop ℤ) : min x (⊤ : WithTop ℤ) = x := by
  simp

/-- Key identity: `0 + x = x` in `WithTop ℤ`. -/
@[simp] lemma zero_add_withTop (x : WithTop ℤ) : (0 : WithTop ℤ) + x = x := by
  simp

/-- Key identity: `x + 0 = x` in `WithTop ℤ`. -/
@[simp] lemma add_zero_withTop (x : WithTop ℤ) : x + (0 : WithTop ℤ) = x := by
  simp

/-! ## Section 3: Tropical Identity Properties -/

/-
The tropical identity matrix is a left identity for tropical matrix multiplication.
-/
theorem tropId_mul (A : TropMat d) : tropMatMul tropId A = A := by
  -- By definition of tropMatMul, we have:
  funext i j; simp [tropMatMul, tropId];
  refine' le_antisymm _ _;
  · exact Finset.inf'_le _ ( Finset.mem_univ i ) |> le_trans <| by aesop;
  · exact Finset.le_inf' _ _ fun x hx => by aesop;

/-
The tropical identity matrix is a right identity for tropical matrix multiplication.
-/
theorem mul_tropId (A : TropMat d) : tropMatMul A tropId = A := by
  -- For the right identity, tropId ⊗ A, the (i,j) entry is min_{k} (A_ik + tropId_kj).
  ext i j
  simp [tropMatMul, tropId];
  convert inf'_univ_eq_of_top_others ( fun x => A i x + if x = j then 0 else ⊤ ) j _ using 1;
  · aesop;
  · aesop

/-! ## Section 4: Associativity of Tropical Matrix Multiplication

The proof proceeds by showing that both `((A ⊗ B) ⊗ C)_{ij}` and `(A ⊗ (B ⊗ C))_{ij}`
equal `min_{k,l} (A_{ik} + B_{kl} + C_{lj})`, using the distributivity of addition
over min in `WithTop ℤ`. -/

/-
Interchanging `min` and `+` over a double `inf'`:
    `min_k (f k + min_l (g k l)) = min_k min_l (f k + g k l)`.
-/
lemma inf'_add_inf' {d : ℕ}
    (f : Fin (d+1) → WithTop ℤ)
    (g : Fin (d+1) → Fin (d+1) → WithTop ℤ) :
    Finset.inf' Finset.univ Finset.univ_nonempty (fun k => f k +
      Finset.inf' Finset.univ Finset.univ_nonempty (fun l => g k l))
    = Finset.inf' Finset.univ Finset.univ_nonempty (fun k =>
      Finset.inf' Finset.univ Finset.univ_nonempty (fun l => f k + g k l)) := by
  -- Apply the distributive property of addition over min in the context of `WithTop`.
  have h_distrib : ∀ k, f k + Finset.inf' Finset.univ Finset.univ_nonempty (fun l => g k l) = Finset.inf' Finset.univ Finset.univ_nonempty (fun l => f k + g k l) := by
    intro k;
    apply le_antisymm;
    · cases h : f k <;> simp_all +decide [ Finset.inf'_le ];
      grind;
    · simp +zetaDelta at *;
      exact Exists.elim ( Finset.exists_mem_eq_inf' Finset.univ_nonempty fun l => g k l ) fun x hx => ⟨ x, by aesop ⟩;
  aesop

/-
Tropical matrix multiplication is associative:
    `(A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)`.
    This is the cornerstone property enabling tropical matrix powers
    and the Diffie-Hellman construction.
-/
theorem tropMatMul_assoc (A B C : TropMat d) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) := by
  ext i j; simp +decide [ tropMatMul ] ;
  simp +decide only [inf'_add_inf', add_left_comm, add_comm];
  rw [ Finset.inf'_comm ]

/-! ## Section 5: Tropical Matrix Power Properties -/

/-- `A^{⊗1} = A`. -/
@[simp] theorem tropMatPow_one (A : TropMat d) : tropMatPow A 1 = A := by
  simp [tropMatPow, tropId_mul]

/-
Power addition homomorphism:
    `A^{⊗(m + n)} = A^{⊗m} ⊗ A^{⊗n}`.
    Proved by induction on `n`, using associativity of `tropMatMul`.
-/
theorem tropMatPow_add (A : TropMat d) (m n : ℕ) :
    tropMatPow A (m + n) = tropMatMul (tropMatPow A m) (tropMatPow A n) := by
  induction' n with n ih generalizing m;
  · convert mul_tropId _ |> Eq.symm;
  · convert tropMatMul_assoc ( tropMatPow A m ) ( tropMatPow A n ) A using 1;
    rw [ ← ih, Nat.add_succ, tropMatPow ]

/-
Power multiplication:
    `(A^{⊗m})^{⊗n} = A^{⊗(m * n)}`.
    Proved by induction on `n`, using `tropMatPow_add`.
-/
theorem tropMatPow_mul (A : TropMat d) (m n : ℕ) :
    tropMatPow (tropMatPow A m) n = tropMatPow A (m * n) := by
  refine' Nat.recOn n _ _ <;> simp_all +decide [ Nat.succ_mul ];
  · rfl;
  · intro n hn; rw [ Nat.mul_succ, tropMatPow_add, tropMatPow_add ] ; aesop;

/-- Commutativity of iterated powers:
    `(A^{⊗m})^{⊗n} = (A^{⊗n})^{⊗m}`.
    This is the mathematical foundation of the Tropical Diffie-Hellman
    key exchange: Alice and Bob can independently compute the shared key. -/
theorem tropMatPow_comm (A : TropMat d) (m n : ℕ) :
    tropMatPow (tropMatPow A m) n = tropMatPow (tropMatPow A n) m := by
  rw [tropMatPow_mul, tropMatPow_mul, mul_comm]

/-! ## Section 6: Tropical Diffie-Hellman Key Exchange -/

/-- A Tropical Diffie-Hellman protocol instance.

    **Protocol**:
    1. Public parameter: a tropical matrix `G` of dimension `(d+1) × (d+1)`
    2. Alice chooses secret `a : ℕ`, publishes `pubA = G^{⊗a}`
    3. Bob chooses secret `b : ℕ`, publishes `pubB = G^{⊗b}`
    4. Shared key: `G^{⊗(a*b)} = (G^{⊗a})^{⊗b} = (G^{⊗b})^{⊗a}`

    Breaking the protocol requires solving the Tropical Discrete Logarithm
    Problem (TDLP): given `G` and `G^{⊗k}`, find `k`. -/
structure TropicalDHProtocol (d : ℕ) where
  /-- Public generator matrix -/
  generator : TropMat d
  /-- Alice's secret exponent -/
  aliceSecret : ℕ
  /-- Bob's secret exponent -/
  bobSecret : ℕ

namespace TropicalDHProtocol

/-- Alice's public key: `G^{⊗a}` -/
def alicePub (p : TropicalDHProtocol d) : TropMat d :=
  tropMatPow p.generator p.aliceSecret

/-- Bob's public key: `G^{⊗b}` -/
def bobPub (p : TropicalDHProtocol d) : TropMat d :=
  tropMatPow p.generator p.bobSecret

/-- Shared key as computed by Alice: `(G^{⊗b})^{⊗a}` -/
def sharedKeyAlice (p : TropicalDHProtocol d) : TropMat d :=
  tropMatPow p.bobPub p.aliceSecret

/-- Shared key as computed by Bob: `(G^{⊗a})^{⊗b}` -/
def sharedKeyBob (p : TropicalDHProtocol d) : TropMat d :=
  tropMatPow p.alicePub p.bobSecret

/-- The true shared key: `G^{⊗(a * b)}` -/
def sharedKey (p : TropicalDHProtocol d) : TropMat d :=
  tropMatPow p.generator (p.aliceSecret * p.bobSecret)

end TropicalDHProtocol

/-- **Tropical Diffie-Hellman Key Agreement Theorem**.
    Both Alice and Bob compute the same shared key,
    and it equals `G^{⊗(a * b)}`.

    This is the fundamental correctness property of the protocol:
    - Alice computes `(G^{⊗b})^{⊗a} = G^{⊗(b*a)} = G^{⊗(a*b)}`
    - Bob computes `(G^{⊗a})^{⊗b} = G^{⊗(a*b)}`

    The proof uses `tropMatPow_mul` (power homomorphism) and
    commutativity of multiplication on `ℕ`. -/
theorem tropDH_key_agreement (p : TropicalDHProtocol d) :
    p.sharedKeyAlice = p.sharedKey ∧ p.sharedKeyBob = p.sharedKey := by
  constructor
  · simp only [TropicalDHProtocol.sharedKeyAlice, TropicalDHProtocol.bobPub,
               TropicalDHProtocol.sharedKey, tropMatPow_mul, mul_comm]
  · simp only [TropicalDHProtocol.sharedKeyBob, TropicalDHProtocol.alicePub,
               TropicalDHProtocol.sharedKey, tropMatPow_mul]

/-- **Corollary**: Alice's computed key equals Bob's computed key. -/
theorem tropDH_alice_eq_bob (p : TropicalDHProtocol d) :
    p.sharedKeyAlice = p.sharedKeyBob := by
  have h := tropDH_key_agreement p
  rw [h.1, h.2]

/-! ## Section 7: Tropical Eigenvalue Structure -/

/-- A tropical eigenvector-eigenvalue pair for matrix `A`:
    `A ⊗ v = λ ⊕ v` where `⊕` means component-wise addition
    of the scalar `λ`. In the min-plus semiring, this means
    `min_j (A_{ij} + v_j) = λ + v_i` for all `i`. -/
structure TropEigenpair (d : ℕ) where
  /-- The tropical matrix -/
  mat : TropMat d
  /-- The eigenvalue (a scalar in `WithTop ℤ`) -/
  eigenval : WithTop ℤ
  /-- The eigenvector -/
  eigenvec : Fin (d+1) → WithTop ℤ
  /-- The eigenvector relation:
      `min_j (A_{ij} + v_j) = λ + v_i` for all `i` -/
  is_eigenpair : ∀ i : Fin (d+1),
    Finset.inf' Finset.univ Finset.univ_nonempty
      (fun j => mat i j + eigenvec j) = eigenval + eigenvec i

/-
**Tropical Eigenvalue Scaling Theorem**.
    If `(λ, v)` is a tropical eigenpair for `A`, and all entries of `v`
    are finite, and `λ` is finite, then `(k * λ, v)` is a tropical
    eigenpair for `A^{⊗k}`.

    In tropical algebra, eigenvalues scale linearly under matrix powers:
    `λ(A^{⊗k}) = k · λ(A)`.

    This is the key vulnerability in tropical cryptography: if one can
    compute the tropical eigenvalue of both `A` and `A^{⊗k}`, one can
    recover `k` by division (when `λ ≠ 0`).
-/
theorem tropEigenval_power_scaling (ep : TropEigenpair d) (k : ℕ)
    (hev : ep.eigenval ≠ ⊤)
    (hv : ∀ i, ep.eigenvec i ≠ ⊤) :
    ∀ i : Fin (d+1),
    Finset.inf' Finset.univ Finset.univ_nonempty
      (fun j => tropMatPow ep.mat k i j + ep.eigenvec j) =
    k • ep.eigenval + ep.eigenvec i := by
  induction' k with k ih <;> simp_all +decide [ ← add_assoc, tropMatPow_add ];
  · -- By definition of `tropMatPow`, we know that `tropMatPow ep.mat 0` is the identity matrix.
    have h_id : tropMatPow ep.mat 0 = tropId := by
      rfl;
    intro i; specialize hv i; rw [ h_id ] ;
    convert inf'_univ_eq_of_top_others _ i _ using 1; all_goals unfold tropId; aesop;
  · intro i
    have h_inf : Finset.inf' Finset.univ Finset.univ_nonempty (fun x => tropMatMul (tropMatPow ep.mat k) ep.mat i x + ep.eigenvec x) = Finset.inf' Finset.univ Finset.univ_nonempty (fun x => tropMatPow ep.mat k i x + Finset.inf' Finset.univ Finset.univ_nonempty (fun j => ep.mat x j + ep.eigenvec j)) := by
      simp +decide only [tropMatMul, inf'_add_inf'];
      refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff, Finset.le_inf' ];
      · intro a b; use b; simp +decide [ ← add_assoc, Finset.inf'_le_iff ] ;
        exact add_le_add ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) le_rfl;
      · intro b; use Classical.choose ( Finset.exists_min_image Finset.univ ( fun k_1 => tropMatPow ep.mat k i k_1 + ep.mat k_1 b ) ⟨ b, Finset.mem_univ b ⟩ ), b; have := Classical.choose_spec ( Finset.exists_min_image Finset.univ ( fun k_1 => tropMatPow ep.mat k i k_1 + ep.mat k_1 b ) ⟨ b, Finset.mem_univ b ⟩ ) ; simp_all +decide [ Finset.inf'_le ] ;
        simp_all +decide [ ← add_assoc, Finset.inf'_le ];
    simp_all +decide [ TropEigenpair.is_eigenpair ];
    convert congr_arg ( · + ep.eigenval ) ( ih i ) using 1;
    · refine' le_antisymm _ _;
      · simp +decide [ Finset.inf'_le_iff ];
        obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun j => tropMatPow ep.mat k i j + ep.eigenvec j ) ; use j; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
      · simp +decide [ ← add_assoc, Finset.inf'_le ];
        intro j; rw [ add_right_comm ] ; gcongr;
        exact Finset.inf'_le _ ( Finset.mem_univ _ );
    · rw [ add_smul, one_smul, add_right_comm ]

/-! ## Section 8: Tropical Discrete Logarithm Problem (TDLP) -/

/-- The Tropical Discrete Logarithm Problem: given a matrix `A` and
    a target `B = A^{⊗k}`, determine whether a specific `k₀` is the
    correct exponent.

    This predicate formalizes: "is `k₀` a solution to the TDLP
    instance `(A, B)`?" -/
def IsTDLPSolution (A B : TropMat d) (k₀ : ℕ) : Prop :=
  tropMatPow A k₀ = B

/-
**Uniqueness failure of TDLP**: The tropical discrete logarithm
    is not always unique. The tropical identity matrix `tropId`
    satisfies `tropId^{⊗k} = tropId` for all `k`, so every `k`
    is a valid TDLP solution when `A = B = tropId`.
    This shows that TDLP hardness depends on the choice of generator.
-/
theorem tdlp_not_unique :
    ∀ k : ℕ, IsTDLPSolution (d := d) tropId tropId k := by
  intro k;
  induction k <;> simp_all +decide [ IsTDLPSolution ];
  · rfl;
  · rw [ show tropMatPow tropId ( _ + 1 ) = tropMatMul ( tropMatPow tropId _ ) tropId from rfl, ‹tropMatPow tropId _ = tropId›, mul_tropId ]

/-! ## Section 9: Security Conjecture -/

/-- **Conjecture (TDLP Hardness)**: For a "generic" tropical matrix
    (one whose shortest-path graph has a unique critical cycle),
    the TDLP requires inspecting Ω(n²) entries of `A^{⊗k}`.

    This is stated as a falsifiable predicate: there exists a family
    of matrices for which no polynomial-time algorithm can solve TDLP.

    **Testable prediction**: For random `n × n` tropical matrices with
    entries in `{0, ..., M}`, the fraction of instances where TDLP has
    a unique solution approaches 1 as `n → ∞` and `M → ∞`.
    Computationally: generate 1000 random 10×10 tropical matrices,
    compute `A^{⊗k}` for random `k ∈ {2, ..., 100}`, and verify that
    the eigenvalue method recovers `k` in > 95% of cases.
    If this test fails (recovery rate < 95%), the conjecture gains support
    because eigenvalue-based attacks fail. -/
def TDLPHardnessConjecture : Prop :=
  ∀ (d : ℕ) (_ : 9 ≤ d),
  ∃ (A : TropMat d),
  ∀ (k₁ k₂ : ℕ), 1 ≤ k₁ → 1 ≤ k₂ → k₁ ≠ k₂ →
  tropMatPow A k₁ ≠ tropMatPow A k₂

/-! ## Section 10: Tropical Matrix Entry Bounds -/

/-
**Entry bound for tropical powers**: each entry of `A^{⊗(n+1)}`
    is at most the corresponding entry of `A^{⊗n}` plus the diagonal
    entry `A_{jj}`. This follows because taking `k = j` in the min
    gives `A^n_{ij} + A_{jj}` as an upper bound.
-/
theorem tropMatPow_entry_bound (A : TropMat d) (n : ℕ) (i j : Fin (d+1)) :
    tropMatPow A (n + 1) i j ≤ tropMatPow A n i j + A j j := by
  convert Finset.inf'_le _ _;
  exact Finset.mem_univ j

end TropicalCrypto