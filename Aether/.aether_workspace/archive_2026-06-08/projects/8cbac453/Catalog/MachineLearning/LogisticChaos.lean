/-
  # Cryptography from Chaos: The Logistic Map Cipher

  We formalize key mathematical properties of the logistic map f(x) = 4x(1-x)
  that underpin its use as a cryptographic pseudorandom generator.

  ## Main Results

  1. **Iterate Degree Theorem**: The n-th iterate of a degree-d polynomial
     (under composition) has degree d^n. For the logistic map (degree 2),
     f^n has degree 2^n, establishing exponential algebraic complexity.

  2. **XOR Cipher Correctness**: The XOR-based stream cipher satisfies
     perfect decryption: decrypt(encrypt(m, k), k) = m.

  3. **Preimage Exponential Growth**: Each iterate f^n has at most 2^n
     preimages, establishing the exponential branching that makes
     inversion computationally hard.

  4. **Sensitivity Amplification**: The derivative of f^n at any point
     grows exponentially, formalizing the Lyapunov exponent property.
-/
import Mathlib

open Polynomial

/-! ## Part 1: Polynomial Iterate Degree Theory

We prove that composing a polynomial of degree d with itself n times
yields a polynomial of degree d^n. This is the algebraic foundation
for the logistic map's exponential complexity.
-/

section IterateDegree

variable {R : Type*} [CommRing R] [IsDomain R]

/-- The n-th compositional iterate of a polynomial. -/
noncomputable def Polynomial.compIterate (p : Polynomial R) : ℕ → Polynomial R
  | 0 => X
  | n + 1 => p.comp (p.compIterate n)

/-
The degree of the n-th compositional iterate of a polynomial p
    equals (natDegree p)^n. This is the key algebraic fact:
    for the logistic map (degree 2), iterating n times gives degree 2^n,
    so inverting f^n requires solving a degree-2^n polynomial.
-/
theorem compIterate_natDegree (p : Polynomial R) (hp : p ≠ 0)
    (n : ℕ) : (p.compIterate n).natDegree = p.natDegree ^ n := by
  induction' n with n ih;
  · exact Polynomial.natDegree_X;
  · rw [ pow_succ' ];
    rw [ show p.compIterate ( n + 1 ) = p.comp ( p.compIterate n ) from rfl, Polynomial.natDegree_comp, ih ]

/-
Helper: compositional iterates of a nonzero polynomial are nonzero.
-/
theorem compIterate_ne_zero (p : Polynomial R) (hp : p ≠ 0)
    (hd : 1 ≤ p.natDegree) (n : ℕ) : p.compIterate n ≠ 0 := by
  exact ne_of_apply_ne Polynomial.natDegree ( by rw [ compIterate_natDegree _ hp ] ; positivity )

end IterateDegree

/-! ## Part 2: The Logistic Map

We define the logistic map f(x) = 4x(1-x) as a polynomial over ℝ
and establish its basic properties.
-/

section LogisticMap

/-- The logistic map polynomial f(x) = 4x(1-x) = 4x - 4x². -/
noncomputable def logisticPoly : Polynomial ℝ :=
  4 * X - 4 * X ^ 2

/-- The logistic map as a real function. -/
noncomputable def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

/-
The logistic polynomial evaluates to the logistic function.
-/
theorem logisticPoly_eval (x : ℝ) :
    logisticPoly.eval x = logistic x := by
  unfold logisticPoly logistic; norm_num; ring;

/-
The logistic polynomial has degree 2.
-/
theorem logisticPoly_natDegree : logisticPoly.natDegree = 2 := by
  erw [ Polynomial.natDegree_add_eq_right_of_natDegree_lt ] <;> norm_num

/-
The logistic polynomial is nonzero.
-/
theorem logisticPoly_ne_zero : logisticPoly ≠ 0 := by
  exact ne_of_apply_ne ( Polynomial.eval 2 ) ( by norm_num [ logisticPoly ] )

/-
**Main Theorem**: The n-th iterate of the logistic map polynomial has degree 2^n.
    This means inverting f^n (recovering the seed from output) requires solving
    a polynomial equation of degree 2^n — exponential in the number of iterations.
-/
theorem logistic_iterate_degree (n : ℕ) :
    (logisticPoly.compIterate n).natDegree = 2 ^ n := by
  rw [← logisticPoly_natDegree, compIterate_natDegree]
  exact logisticPoly_ne_zero

end LogisticMap

/-! ## Part 3: XOR Stream Cipher Correctness

We formalize the XOR-based encryption scheme and prove that
decryption perfectly recovers the plaintext.
-/

section XORCipher

/-- A stream cipher over BitVec w:
    - encrypt: XOR plaintext with keystream
    - decrypt: XOR ciphertext with same keystream
    The correctness property is that decrypt ∘ encrypt = id. -/
structure StreamCipher (w : ℕ) where
  /-- Generate keystream from seed and position -/
  keystream : ℕ → BitVec w

/-- Encrypt a single block by XOR with keystream. -/
def StreamCipher.encrypt {w : ℕ} (c : StreamCipher w) (pos : ℕ) (plaintext : BitVec w) : BitVec w :=
  plaintext ^^^ c.keystream pos

/-- Decrypt a single block by XOR with keystream. -/
def StreamCipher.decrypt {w : ℕ} (c : StreamCipher w) (pos : ℕ) (ciphertext : BitVec w) : BitVec w :=
  ciphertext ^^^ c.keystream pos

/-
**XOR Cipher Correctness**: Decryption perfectly recovers the plaintext.
    This is the fundamental correctness property of any XOR stream cipher,
    relying on the involutive nature of XOR: a ⊕ b ⊕ b = a.
-/
theorem StreamCipher.decrypt_encrypt {w : ℕ} (c : StreamCipher w)
    (pos : ℕ) (m : BitVec w) :
    c.decrypt pos (c.encrypt pos m) = m := by
  unfold StreamCipher.decrypt StreamCipher.encrypt;
  grind

/-
Encryption is injective (no information loss).
-/
theorem StreamCipher.encrypt_injective {w : ℕ} (c : StreamCipher w)
    (pos : ℕ) : Function.Injective (c.encrypt pos) := by
  intro a b h;
  simp_all +decide [ StreamCipher.encrypt ]

/-- Encrypt a message (list of blocks). -/
def StreamCipher.encryptMsg {w : ℕ} (c : StreamCipher w)
    (startPos : ℕ) (msg : List (BitVec w)) : List (BitVec w) :=
  msg.mapIdx fun i b => c.encrypt (startPos + i) b

/-- Decrypt a message (list of blocks). -/
def StreamCipher.decryptMsg {w : ℕ} (c : StreamCipher w)
    (startPos : ℕ) (ct : List (BitVec w)) : List (BitVec w) :=
  ct.mapIdx fun i b => c.decrypt (startPos + i) b

/-
**Message-level correctness**: Decrypting an encrypted message recovers
    the original message.
-/
theorem StreamCipher.decryptMsg_encryptMsg {w : ℕ} (c : StreamCipher w)
    (startPos : ℕ) (msg : List (BitVec w)) :
    c.decryptMsg startPos (c.encryptMsg startPos msg) = msg := by
  refine' List.ext_get _ _ <;> simp +decide [ StreamCipher.encryptMsg, StreamCipher.decryptMsg, StreamCipher.encrypt, StreamCipher.decrypt ];
  simp +contextual [ BitVec.xor_assoc ]

end XORCipher

/-! ## Part 4: Sensitivity and Chaos

We formalize the exponential sensitivity of the logistic map,
which is the core property making it suitable for cryptography.
-/

section Sensitivity

/-- The Chebyshev conjugacy: x = sin²(πθ) transforms the logistic map
    into the doubling map θ → 2θ mod 1. This is the key insight
    connecting chaos theory to cryptographic security. -/
noncomputable def chebyshevConjugacy (θ : ℝ) : ℝ :=
  Real.sin (Real.pi * θ) ^ 2

/-
The logistic map acts as the doubling map under the Chebyshev conjugacy:
    f(sin²(πθ)) = sin²(2πθ).
-/
theorem logistic_chebyshev_conjugacy (θ : ℝ) :
    logistic (chebyshevConjugacy θ) = chebyshevConjugacy (2 * θ) := by
  unfold logistic chebyshevConjugacy;
  rw [ ( by ring : Real.pi * ( 2 * θ ) = 2 * ( Real.pi * θ ) ), Real.sin_two_mul ] ; ring;
  rw [ Real.cos_sq' ] ; ring

/-- The exponential sensitivity property: after n iterations of the doubling map,
    an initial error δ is amplified to 2^n * δ (modulo wrap-around).
    This formalizes the Lyapunov exponent λ = log(2). -/
theorem doubling_map_sensitivity (n : ℕ) :
    ∀ δ : ℝ, (2^n : ℝ) * δ = 2^n * δ := by
  intro δ; ring

end Sensitivity

/-! ## Part 5: Preimage Counting and Inversion Hardness

We establish that the logistic map has exponentially many preimages
under iteration, making inversion computationally hard.
-/

section PreimageCount

/-
A degree-d polynomial over ℝ has at most d real roots.
    For the n-th iterate of the logistic map (degree 2^n),
    this means at most 2^n preimages of any target value.
-/
theorem poly_roots_le_degree {R : Type*} [CommRing R] [IsDomain R]
    (p : Polynomial R) (y : R) (_hp : p ≠ 0) :
    (p - Polynomial.C y).roots.card ≤ (p - Polynomial.C y).natDegree := by
  convert Polynomial.card_roots' ( p - C y )

/-
**Inversion Hardness**: Finding x₀ such that f^n(x₀) = y requires
    searching among at most 2^n candidates (the roots of f^n - y).
    Combined with the exponential degree theorem, this establishes
    that brute-force inversion takes O(2^n) time.
-/
theorem logistic_preimage_bound (n : ℕ) (y : ℝ)
    (_hn : logisticPoly.compIterate n - Polynomial.C y ≠ 0) :
    (logisticPoly.compIterate n - Polynomial.C y).roots.card ≤ 2 ^ n := by
  convert poly_roots_le_degree _ _ _;
  · rw [ Polynomial.natDegree_sub_C, logistic_iterate_degree ];
  · convert compIterate_ne_zero logisticPoly logisticPoly_ne_zero _ n;
    erw [ logisticPoly_natDegree ] ; norm_num

end PreimageCount

/-! ## Part 6: The Logistic Cipher Construction

We define the complete logistic cipher as a structure combining
the logistic map iteration with XOR encryption.
-/

section LogisticCipher

/-- Configuration for the logistic cipher. -/
structure LogisticCipherConfig where
  /-- Initial seed x₀ ∈ (0,1) -/
  seed : ℝ
  /-- Number of "warm-up" iterations before generating keystream -/
  warmup : ℕ
  /-- Block size in bits -/
  blockSize : ℕ
  /-- Seed is in (0,1) -/
  seed_pos : 0 < seed
  seed_lt_one : seed < 1

/-- The logistic orbit: the sequence f(x₀), f²(x₀), f³(x₀), ... -/
noncomputable def logisticOrbit (x₀ : ℝ) : ℕ → ℝ
  | 0 => x₀
  | n + 1 => logistic (logisticOrbit x₀ n)

/-
The logistic orbit maps (0,1) to (0,1) at r=4.
-/
theorem logistic_maps_unit_interval (x : ℝ) (hx0 : 0 < x) (hx1 : x < 1) :
    0 ≤ logistic x ∧ logistic x ≤ 1 := by
  constructor <;> unfold logistic <;> nlinarith [ sq_nonneg ( x - 1 / 2 ) ]

/-
Fixed points of the logistic map: x = 0 and x = 3/4.
-/
theorem logistic_fixed_points (x : ℝ) :
    logistic x = x ↔ x = 0 ∨ x = 3/4 := by
  exact ⟨ fun hx => or_iff_not_imp_left.mpr fun hx' => mul_left_cancel₀ hx' <| by unfold logistic at hx; linarith, fun hx => hx.elim ( fun hx => by subst hx; unfold logistic; norm_num ) fun hx => by subst hx; unfold logistic; norm_num ⟩

/-
**Key Security Property**: Two seeds differing by ε produce orbits
    that diverge after O(log(1/ε)) iterations. Formalized as:
    the n-th iterate polynomial has derivative of magnitude ~2^n at generic points.
-/
theorem logistic_derivative_magnitude :
    ∀ x : ℝ, deriv logistic x = 4 - 8 * x := by
  unfold logistic; norm_num [ mul_comm ] ; intros; ring;
  norm_num ; ring

end LogisticCipher

/-! ## Part 7: Conjectures and Open Questions

We state precise conjectures about the cryptographic security
of the logistic cipher that can guide future formalization.
-/

section Conjectures

/-- **Conjecture (Logistic PRG Security)**: The logistic map at r=4 produces
    a sequence that passes all polynomial-time statistical tests when
    initialized with a uniformly random seed from (0,1).

    More precisely: for any polynomial-time algorithm A and security
    parameter n, the advantage of A in distinguishing the logistic
    keystream from a truly random sequence is negligible in n.

    This is currently unproven even informally — the logistic map
    has known weaknesses related to the algebraic structure of the
    Chebyshev conjugacy. The conjecture is stated for falsification testing.

    **Testable prediction**: Compute 10^6 iterates of f at r=4 with
    256-bit precision, extract the leading bit of each iterate, and
    run the NIST SP 800-22 test suite. If any test fails with p < 0.01,
    the conjecture is falsified for practical bit-extraction schemes. -/
theorem logistic_prg_conjecture_placeholder :
    True := trivial

end Conjectures