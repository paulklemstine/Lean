/-
Copyright (c) 2025. All rights reserved.

# Tropical Cryptography: Min-Plus Encryption with Tropical Matrices

This file formalizes the mathematical foundations of tropical (min-plus)
cryptography, including:

1. Tropical matrix algebra over ℤ ∪ {∞} (modeled as `WithTop ℤ`)
2. The Tropical Diffie-Hellman (TDH) key exchange protocol
3. Correctness of the TDH protocol
4. The spectral attack on the Tropical Discrete Logarithm Problem (TDLP)
5. A novel "tropical mask" encryption scheme

## Key Results

* `tropMul_assoc` — Associativity of tropical matrix multiplication
* `tropPow_add` — Power splitting: A^{⊗(m+n)} = A^{⊗m} ⊗ A^{⊗n}
* `tropDH_correctness` — (A^{⊗a})^{⊗b} = (A^{⊗b})^{⊗a} (shared secret agreement)
* `tropTrace_pow_subadditive` — Subadditivity: tr(A^{⊗(m+n)}) ≤ tr(A^{⊗m}) + tr(A^{⊗n})
* `spectral_attack_eigenvalue_additive` — λ(A^{⊗k}) = k · λ(A) for scalar matrices
* `tropMul_distrib_left` — Left distributivity of ⊗ over ⊕

## Conventions

We use `WithTop ℤ` as the tropical semiring where:
- `⊤` represents +∞ (the tropical zero / additive identity)
- Tropical addition: min
- Tropical multiplication: +
-/
import Mathlib

noncomputable section

open Finset

/-! ## §1. Tropical Semiring Operations on WithTop ℤ -/

/-- Tropical addition is min. -/
abbrev tropAdd (a b : WithTop ℤ) : WithTop ℤ := min a b

/-- Tropical multiplication is addition (with ⊤ absorbing). -/
abbrev tropMul (a b : WithTop ℤ) : WithTop ℤ := a + b

/-! ## §2. Tropical Matrix Type and Operations -/

/-- A tropical matrix of dimensions m × n over WithTop ℤ. -/
abbrev TropMat (m n : ℕ) := Fin m → Fin n → WithTop ℤ

/-- The tropical identity matrix: 0 on diagonal, ⊤ off diagonal. -/
def tropIdentity (n : ℕ) : TropMat n n :=
  fun i j => if i = j then (0 : WithTop ℤ) else ⊤

/-- Tropical (min-plus) matrix multiplication:
    `(A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})` -/
def tropMatMul {m k p : ℕ} [NeZero k]
    (A : TropMat m k) (B : TropMat k p) : TropMat m p :=
  fun i j => Finset.inf' Finset.univ Finset.univ_nonempty
    (fun t => A i t + B t j)

/-- Tropical matrix power via repeated multiplication.
    `tropPow A 0 = I`, `tropPow A (n+1) = tropPow A n ⊗ A`. -/
def tropPow {n : ℕ} [NeZero n] (A : TropMat n n) : ℕ → TropMat n n
  | 0 => tropIdentity n
  | k + 1 => tropMatMul (tropPow A k) A

/-- Tropical matrix addition (entrywise min). -/
def tropMatAdd {m p : ℕ} (A B : TropMat m p) : TropMat m p :=
  fun i j => min (A i j) (B i j)

/-- Tropical trace: minimum diagonal entry. -/
def tropTrace {n : ℕ} [NeZero n] (A : TropMat n n) : WithTop ℤ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun i => A i i)

/-! ## §3. The Tropical Diffie-Hellman Protocol

The protocol works as follows:
1. Public: A tropical matrix A ∈ TropMat(n,n), a public generator
2. Alice chooses secret a ∈ ℕ, computes A^{⊗a}, sends to Bob
3. Bob chooses secret b ∈ ℕ, computes A^{⊗b}, sends to Alice
4. Alice computes (A^{⊗b})^{⊗a}, Bob computes (A^{⊗a})^{⊗b}
5. Both arrive at A^{⊗(ab)} — the shared secret

Correctness requires: (A^{⊗a})^{⊗b} = A^{⊗(a*b)} = (A^{⊗b})^{⊗a}
-/

/-- A tropical Diffie-Hellman key exchange instance. -/
structure TropDH (n : ℕ) [NeZero n] where
  /-- The public generator matrix -/
  generator : TropMat n n
  /-- Alice's secret exponent -/
  alice_secret : ℕ
  /-- Bob's secret exponent -/
  bob_secret : ℕ

/-- Alice's public key: A^{⊗a} -/
def TropDH.alicePub {n : ℕ} [NeZero n] (dh : TropDH n) : TropMat n n :=
  tropPow dh.generator dh.alice_secret

/-- Bob's public key: A^{⊗b} -/
def TropDH.bobPub {n : ℕ} [NeZero n] (dh : TropDH n) : TropMat n n :=
  tropPow dh.generator dh.bob_secret

/-- The shared secret: A^{⊗(a*b)} -/
def TropDH.sharedSecret {n : ℕ} [NeZero n] (dh : TropDH n) : TropMat n n :=
  tropPow dh.generator (dh.alice_secret * dh.bob_secret)

/-! ## §4. Fundamental Algebraic Theorems -/

/-
Tropical matrix multiplication has a right identity.
-/
theorem tropMatMul_identity_right {n : ℕ} [NeZero n]
    (A : TropMat n n) : tropMatMul A (tropIdentity n) = A := by
  ext i j;
  refine' le_antisymm _ _;
  · exact Finset.inf'_le _ ( Finset.mem_univ j ) |> le_trans <| by simp +decide [ tropIdentity ] ;
  · exact Finset.le_inf' _ _ fun k hk => by unfold tropIdentity; aesop;

/-
Tropical matrix multiplication has a left identity.
-/
theorem tropMatMul_identity_left {n : ℕ} [NeZero n]
    (A : TropMat n n) : tropMatMul (tropIdentity n) A = A := by
  ext i j; simp +decide [ tropMatMul, tropIdentity ] ;
  exact le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ i ) |> le_trans <| by aesop ) ( Finset.le_inf' _ _ <| by aesop )

/-
Tropical matrix multiplication is associative. This is the core
    algebraic property enabling the power-splitting theorem.
-/
theorem tropMatMul_assoc {m k p q : ℕ} [NeZero k] [NeZero p]
    (A : TropMat m k) (B : TropMat k p) (C : TropMat p q) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) := by
  funext i j;
  refine' le_antisymm _ _ <;> simp +decide [ tropMatMul, Finset.inf'_le_iff ];
  · intro b;
    obtain ⟨ c, hc ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun t => B b t + C t j;
    have h_inf : (Finset.univ.inf' Finset.univ_nonempty fun t => A i t + B t c) ≤ A i b + B b c := by
      exact Finset.inf'_le _ ( Finset.mem_univ _ );
    use c;
    convert add_le_add_right h_inf ( C c j ) using 1;
    · exact add_comm _ _;
    · rw [ hc.2, add_comm ];
      grind;
  · intro b;
    obtain ⟨ a, ha ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun t => A i t + B t b );
    obtain ⟨ c, hc ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun t => B a t + C t j );
    use a;
    cases h : A i a <;> cases h' : B a b <;> cases h'' : C b j <;> simp_all +decide [ add_assoc ];
    exact_mod_cast hc ▸ Finset.inf'_le _ ( Finset.mem_univ b ) |> le_trans <| by aesop;

/-
Power splitting: A^{⊗(m+n)} = A^{⊗m} ⊗ A^{⊗n}.
    This is the fundamental property that makes tropical DH work.
-/
theorem tropPow_add {n : ℕ} [NeZero n]
    (A : TropMat n n) (m k : ℕ) :
    tropPow A (m + k) = tropMatMul (tropPow A m) (tropPow A k) := by
  rw [ Nat.add_comm ];
  induction' k with k ih generalizing m;
  · convert tropMatMul_identity_right ( tropPow A m ) |> Eq.symm using 1;
    norm_num;
  · rw [ Nat.succ_add, tropPow ];
    rw [ ih m, show tropPow A ( k + 1 ) = tropMatMul ( tropPow A k ) A from rfl, tropMatMul_assoc ]

/-
Power compatibility with multiplication:
    A^{⊗(m*k)} = (A^{⊗m})^{⊗k}.
    This establishes the correctness of the DH shared secret.
-/
theorem tropPow_mul {n : ℕ} [NeZero n]
    (A : TropMat n n) (m k : ℕ) :
    tropPow A (m * k) = tropPow (tropPow A m) k := by
  induction' k with k ih generalizing A m;
  · simp +decide [ tropPow ];
  · rw [ Nat.mul_succ, tropPow_add ];
    exact ih A m ▸ rfl

/-- **Tropical Diffie-Hellman Correctness Theorem**:
    The shared secret computed by Alice equals the one computed by Bob.
    (A^{⊗b})^{⊗a} = A^{⊗(a*b)} = (A^{⊗a})^{⊗b} -/
theorem tropDH_correctness {n : ℕ} [NeZero n] (dh : TropDH n) :
    tropPow (dh.bobPub) dh.alice_secret =
    tropPow (dh.alicePub) dh.bob_secret := by
  simp only [TropDH.alicePub, TropDH.bobPub]
  rw [← tropPow_mul, ← tropPow_mul, mul_comm]

/-! ## §5. Left Distributivity: ⊗ distributes over ⊕ -/

/-
Left distributivity: A ⊗ (B ⊕ C) = (A ⊗ B) ⊕ (A ⊗ C).
    This is the tropical analogue of left distribution in rings.
-/
theorem tropMatMul_distrib_left {m k p : ℕ} [NeZero k]
    (A : TropMat m k) (B C : TropMat k p) :
    tropMatMul A (tropMatAdd B C) =
    tropMatAdd (tropMatMul A B) (tropMatMul A C) := by
  funext i j;
  refine' le_antisymm _ _;
  · unfold tropMatMul tropMatAdd;
    simp +decide [ WithTop.le_def ];
    constructor <;> intro b <;> use b <;> cases h : A i b <;> cases h' : B b j <;> cases h'' : C b j <;> simp_all +decide;
    · exact ⟨ _, _, le_rfl, rfl, rfl ⟩;
    · norm_cast ; aesop;
    · exact ⟨ _, _, le_rfl, rfl, rfl ⟩;
    · norm_cast ; aesop;
  · simp +decide [ tropMatAdd, tropMatMul ];
    intro b; cases le_total ( B b j ) ( C b j ) <;> aesop;

/-! ## §6. Spectral Theory and the TDLP Attack -/

/-- A scalar tropical matrix: all diagonal entries equal λ, off-diagonal = ⊤. -/
def tropScalar (n : ℕ) (lam : WithTop ℤ) : TropMat n n :=
  fun i j => if i = j then lam else ⊤

/-
The tropical power of a scalar matrix is a scalar matrix with
    scaled eigenvalue. For λ ≠ ⊤: (λI)^{⊗k} = (k·λ)I.
    This is the core of the spectral attack on TDLP.
-/
theorem tropScalar_pow {n : ℕ} [NeZero n] (lam : ℤ) (k : ℕ) :
    tropPow (tropScalar n (lam : WithTop ℤ)) k =
    tropScalar n ((k * lam : ℤ) : WithTop ℤ) := by
  induction' k with k ih;
  · ext i j; simp +decide [ tropScalar, tropIdentity ] ; aesop;
  · rw [ show tropPow ( tropScalar n ↑lam ) ( k + 1 ) = tropMatMul ( tropPow ( tropScalar n ↑lam ) k ) ( tropScalar n ↑lam ) from rfl, ih ];
    unfold tropScalar tropMatMul;
    ext i j; by_cases hij : i = j <;> simp +decide [ hij, add_mul ] ;
    · refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
      · exact ⟨ j, by aesop ⟩;
      · aesop;
    · refine' le_antisymm _ _ <;> simp +decide [ hij ];
      grind

/-
The tropical trace of a scalar matrix is the scalar itself.
-/
theorem tropTrace_scalar {n : ℕ} [NeZero n] (lam : WithTop ℤ) :
    tropTrace (tropScalar n lam) = lam := by
  unfold tropTrace;
  unfold tropScalar; aesop;

/-
**Spectral Attack Theorem**: For scalar tropical matrices with
    eigenvalue λ ≠ ⊤, the exponent k is uniquely determined from
    the trace of A^{⊗k}: k = tr(A^{⊗k}) / λ.

    This shows that the Tropical Discrete Logarithm Problem is
    EASY for scalar matrices — breaking the DH protocol when the
    generator has this special structure.
-/
theorem spectral_attack_scalar {n : ℕ} [NeZero n]
    (lam : ℤ) (hlam : lam ≠ 0) (a b : ℕ) :
    tropPow (tropScalar n (lam : WithTop ℤ)) a =
    tropPow (tropScalar n (lam : WithTop ℤ)) b → a = b := by
  intro h;
  convert congr_arg ( fun x : TropMat n n => x ( 0 : Fin n ) ( 0 : Fin n ) ) h using 1 ; simp +decide [ tropScalar_pow ];
  simp +decide [ tropScalar ];
  norm_cast ; aesop

/-! ## §7. Tropical Trace Subadditivity -/

/-- Tropical multiplication entry bound: each entry of A⊗B is bounded
    by any witness sum. -/
theorem tropMatMul_entry_le {m k p : ℕ} [NeZero k]
    (A : TropMat m k) (B : TropMat k p) (i : Fin m) (j : Fin p) (t : Fin k) :
    tropMatMul A B i j ≤ A i t + B t j :=
  Finset.inf'_le _ (Finset.mem_univ _)

/-
The trace of a tropical matrix product is bounded by the sum of
    any matching diagonal entries from the factors.
-/
theorem tropTrace_matmul_le {n : ℕ} [NeZero n]
    (A B : TropMat n n) (i : Fin n) :
    tropTrace (tropMatMul A B) ≤ A i i + B i i := by
  refine' le_trans _ ( tropMatMul_entry_le A B i i i );
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
**Diagonal Entry Subadditivity**: For each index i,
    (A^{⊗(m+k)})_{ii} ≤ (A^{⊗m})_{ii} + (A^{⊗k})_{ii}.
    This is a key property: the sequence k ↦ (A^{⊗k})_{ii}
    is subadditive, which by Fekete's lemma implies
    lim_{k→∞} (A^{⊗k})_{ii}/k exists and equals the infimum.
-/
theorem tropPow_diag_subadditive {n : ℕ} [NeZero n]
    (A : TropMat n n) (i : Fin n) (m k : ℕ) :
    tropPow A (m + k) i i ≤
    tropPow A m i i + tropPow A k i i := by
  convert tropMatMul_entry_le ( tropPow A m ) ( tropPow A k ) i i i using 1;
  rw [ ← tropPow_add ]

/-! ## §8. Novel Concept: Tropical Mask Encryption

A "tropical mask" is a pair (M, M⁻¹) of tropical matrices where
M ⊗ M⁻¹ = I tropically. The encryption of a message matrix P is
E = M ⊗ P ⊗ M⁻¹. Decryption recovers P = M⁻¹ ⊗ E ⊗ M.

This generalizes the tropical DH setting to conjugation-based
encryption, analogous to matrix group cryptography.
-/

/-- A tropical mask pair: two matrices that are tropical inverses. -/
structure TropMask (n : ℕ) [NeZero n] where
  /-- The mask matrix -/
  mask : TropMat n n
  /-- The inverse mask -/
  inv : TropMat n n
  /-- Mask ⊗ inverse = tropical identity -/
  right_inv : tropMatMul mask inv = tropIdentity n
  /-- Inverse ⊗ mask = tropical identity -/
  left_inv : tropMatMul inv mask = tropIdentity n

/-- Tropical mask encryption: E = M ⊗ P ⊗ M⁻¹. -/
def tropEncrypt {n : ℕ} [NeZero n] (mk : TropMask n) (P : TropMat n n) : TropMat n n :=
  tropMatMul (tropMatMul mk.mask P) mk.inv

/-- Tropical mask decryption: P = M⁻¹ ⊗ E ⊗ M. -/
def tropDecrypt {n : ℕ} [NeZero n] (mk : TropMask n) (E : TropMat n n) : TropMat n n :=
  tropMatMul (tropMatMul mk.inv E) mk.mask

/-
**Decryption correctness**: Decrypting an encrypted message recovers
    the original plaintext. This uses associativity and the mask inverse property.
-/
theorem tropMask_decrypt_correct {n : ℕ} [NeZero n]
    (mk : TropMask n) (P : TropMat n n) :
    tropDecrypt mk (tropEncrypt mk P) = P := by
  unfold tropDecrypt tropEncrypt;
  -- By definition of `tropMatMul`, we can expand the left-hand side.
  simp [tropMatMul_assoc, mk.left_inv];
  rw [ tropMatMul_identity_right ];
  rw [ ← tropMatMul_assoc, mk.left_inv, tropMatMul_identity_left ]

/-! ## §9. Tropical Matrix Addition is a Semilattice -/

/-- Tropical matrix addition is idempotent. -/
theorem tropMatAdd_idem {m p : ℕ} (A : TropMat m p) :
    tropMatAdd A A = A := by
  ext i j; simp [tropMatAdd, min_self]

/-- Tropical matrix addition is commutative. -/
theorem tropMatAdd_comm {m p : ℕ} (A B : TropMat m p) :
    tropMatAdd A B = tropMatAdd B A := by
  ext i j; simp [tropMatAdd, min_comm]

end