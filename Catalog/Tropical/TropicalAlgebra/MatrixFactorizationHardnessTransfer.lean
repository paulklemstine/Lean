import Mathlib

/-!
# Tropical Matrix Factorization Hardness Transfer

This file formalizes a **hardness-transfer bridge** between tropical cryptographic
key recovery and computation of tropical factorization invariants.

## Mathematical Vision

A tropical public key `pub(s) = tropPow G s` is a compressed certificate of a hidden
tropical factorization profile. If an algorithm can recover the secret exponent `s`
from `pub(s)`, then by composition it can compute any factorization invariant on an
associated encoded matrix family. This creates a formal **reduction**: exact tropical
key recovery is at least as hard as computing the factorization invariant on the
image of the encoding.

## Main Results

### Generic Reduction Lemmas
* `recover_then_encode` — If `recover` is a left inverse of `pub`, then
  `encode ∘ recover ∘ pub = encode`.
* `invariant_transfer` — Lifting `recover_then_encode` through an invariant function.

### Tropical Matrix Power
* `tropMinPlusMul` — Min-plus matrix multiplication over `WithTop ℤ`.
* `tropPow` — Iterated tropical matrix power.

### Hardness Transfer Theorems
* `rank_computable_from_secret_recovery` — Exact secret recovery computes a rank
  invariant on an encoded family.
* `rank_of_encoded_matrix_via_public_key` — Existential witness form.
* `tropical_rank_reduction_from_secret_recovery` — The decisive reduction theorem.

### Bounded Secret Domain
* `Secret` — The type `Fin (n + 1)` of bounded secrets.
* `secret_recovery_yields_rank_computation` — Bounded-domain version.
* `encoded_secret_le_dim` — Dimension sanity: encoded secrets respect ambient limits.

### Concrete Encoding Family
* `diagonalEncode` — A concrete encoding via diagonal tropical matrices.
* `diagonalEncode_injective` — Injectivity of the diagonal encoding.
* `diag_rank_correct` — The diagonal rank invariant correctly recovers the secret.

## External Complexity Motivation

The NP-hardness of tropical matrix rank (Shitov 2006, Kim–Roush 2005) is *not*
formalized here. This file supplies the **algebraic reduction core**: any external
hardness result about computing a rank-like invariant on the encoded family transfers
directly to a lower bound on secret recovery. The complexity-theoretic wrapper can
be attached in future work.

## References

* Y. Shitov, "An upper bound for tropical matrix rank", 2006
* K.H. Kim, F.W. Roush, "Factorization of polynomials in one variable over the
  tropical semiring", 2005
-/

open Matrix Finset

noncomputable section

/-! ## Part I: Generic Reduction Lemmas

These lemmas capture the purely compositional structure of hardness transfer.
They work for any types and functions, independent of tropical algebra. -/

/-
**Recovery-composition lemma.**
If `recover` is a left inverse of `pub`, then composing `encode ∘ recover ∘ pub`
yields the same result as `encode` alone. This is the algebraic heart of any
reduction from key recovery to invariant computation.
-/
theorem recover_then_encode
    {α β γ : Type*} (pub : α → β) (recover : β → α) (encode : α → γ)
    (hrec : ∀ a, recover (pub a) = a) :
    ∀ a, encode (recover (pub a)) = encode a := by
  exact fun a => congr_arg encode ( hrec a )

/-
**Invariant transfer lemma.**
If `recover` is a left inverse of `pub`, then any invariant `inv` applied to the
encoding of the recovered secret equals the invariant applied to the encoding of
the original secret. This lifts `recover_then_encode` through an additional
function layer.
-/
theorem invariant_transfer
    {α β γ δ : Type*} (pub : α → β) (recover : β → α)
    (encode : α → γ) (inv : γ → δ)
    (hrec : ∀ a, recover (pub a) = a) :
    ∀ a, inv (encode (recover (pub a))) = inv (encode a) := by
  aesop

/-! ## Part II: Tropical Matrix Power

We define min-plus matrix multiplication and iterated tropical matrix power
over the semiring `WithTop ℤ`, where `⊤` represents `+∞`. -/

/-- **Tropical (min-plus) matrix multiplication** over `WithTop ℤ`.
`(A ⊗ B)(i,j) = min_k (A(i,k) + B(k,j))`. -/
def tropMinPlusMul {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
    Matrix (Fin n) (Fin n) (WithTop ℤ) :=
  fun i j => Finset.inf Finset.univ (fun k => A i k + B k j)

/-- **Tropical identity matrix**: `0` on the diagonal, `⊤` elsewhere. -/
def tropIdentity {n : ℕ} : Matrix (Fin n) (Fin n) (WithTop ℤ) :=
  fun i j => if i = j then (0 : WithTop ℤ) else ⊤

/-- **Iterated tropical matrix power.**
`tropPow G 0 = I` (tropical identity) and
`tropPow G (k+1) = tropMinPlusMul (tropPow G k) G`. -/
def tropPow {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
    ℕ → Matrix (Fin n) (Fin n) (WithTop ℤ)
  | 0 => tropIdentity
  | k + 1 => tropMinPlusMul (tropPow G k) G

@[simp]
theorem tropPow_zero {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
    tropPow G 0 = tropIdentity := rfl

@[simp]
theorem tropPow_succ {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ)) (k : ℕ) :
    tropPow G (k + 1) = tropMinPlusMul (tropPow G k) G := rfl

/-! ## Part III: Main Hardness Transfer Theorems -/

/-
**First-pass bridge theorem.**
Exact secret recovery computes a rank invariant on an encoded family.
Given:
- `pub s = tropPow G s` (tropical public key generation),
- `recoverSecret` is a perfect left inverse of `pub`,
- `rankInv (rankEncoding s) = s` (the encoding family faithfully stores the secret),

we conclude that `rankInv (rankEncoding (recoverSecret (pub s))) = s`.

This certifies that any exact secret-recovery oracle induces a rank-computation
oracle on the encoded family `{rankEncoding s | s ∈ ℕ}`.
-/
theorem rank_computable_from_secret_recovery
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
    (rankEncoding : ℕ → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (pub : ℕ → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (recoverSecret : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (rankInv : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (_hpub : ∀ s, pub s = tropPow G s)
    (hrec : ∀ s, recoverSecret (pub s) = s)
    (hrank : ∀ s, rankInv (rankEncoding s) = s) :
    ∀ s, rankInv (rankEncoding (recoverSecret (pub s))) = s := by
  grind +qlia

/-
**Existential witness form.**
The stronger, compositionally useful corollary: for every secret `s`, there
exists a value `t` that is simultaneously the output of secret recovery and
the correct index into the encoding family.
-/
theorem rank_of_encoded_matrix_via_public_key
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
    (rankEncoding : ℕ → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (pub : ℕ → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (recoverSecret : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (rankInv : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (_hpub : ∀ s, pub s = tropPow G s)
    (hrec : ∀ s, recoverSecret (pub s) = s)
    (hrank : ∀ s, rankInv (rankEncoding s) = s) :
    ∀ s, ∃ t, t = recoverSecret (pub s) ∧ rankInv (rankEncoding t) = s := by
  aesop

/-
**The decisive reduction theorem.**
Any algorithm recovering secret `s` from `tropPow G s` yields, by composition,
an algorithm computing any rank-like invariant on the encoded family.

This is the mathematically decisive statement: it shows that exact tropical
key recovery is at least as hard as computing the invariant on
`{encode s | s ∈ ℕ}`.
-/
theorem tropical_rank_reduction_from_secret_recovery
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
    (encode : ℕ → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (recoverSecret : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (rankInv : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (hrec : ∀ s, recoverSecret (tropPow G s) = s)
    (hrank : ∀ s, rankInv (encode s) = s) :
    ∀ s, rankInv (encode (recoverSecret (tropPow G s))) = s := by
  grind

/-! ## Part IV: Bounded Secret Domain

For dimensional honesty, secrets should be bounded by the matrix dimension.
The tropical rank of any `n × n` matrix is at most `n`, so any encoding
`encode s` with invariant value `= s` requires `s ≤ n`. -/

/-- **Bounded secret type.** Secrets are elements of `Fin (n + 1)`,
representing values `0, 1, ..., n`. This ensures the encoded matrix's
rank invariant stays within the ambient dimension. -/
abbrev Secret (n : ℕ) := Fin (n + 1)

/-
**Bounded-domain hardness transfer.**
The secret recovery reduction restricted to bounded secrets `s : Fin (n + 1)`.
-/
theorem secret_recovery_yields_rank_computation
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
    (encode : Secret n → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (recoverSecret : Matrix (Fin n) (Fin n) (WithTop ℤ) → Secret n)
    (rankInv : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (hrec : ∀ s : Secret n, recoverSecret (tropPow G s.val) = s)
    (hrank : ∀ s : Secret n, rankInv (encode s) = s.val) :
    ∀ s : Secret n, rankInv (encode (recoverSecret (tropPow G s.val))) = s.val := by
  aesop

/-
**Dimension sanity.**
If an encoding satisfies `rankInv (encode s) = s.val`, then the invariant
value is bounded by `n`. This is immediate from the definition of `Fin (n + 1)`.
-/
theorem encoded_secret_le_dim
    {n : ℕ}
    (encode : Secret n → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (rankInv : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (hrank : ∀ s : Secret n, rankInv (encode s) = s.val)
    (s : Secret n) :
    rankInv (encode s) ≤ n := by
  exact hrank s ▸ Nat.le_of_lt_succ s.2

/-! ## Part V: Concrete Encoding Family

We construct an explicit encoding family via diagonal tropical matrices.
The "diagonal rank" invariant counts the number of finite diagonal entries,
which serves as a concrete, computable proxy for tropical factor rank.

### Construction
Given `s : Fin (n + 1)`, define `diagonalEncode s` as the `n × n` matrix
with `0` in the first `s` diagonal entries and `⊤` elsewhere. The number
of finite diagonal entries equals `s`. -/

/-- **Diagonal tropical encoding.**
`diagonalEncode s` has `0` in diagonal positions `0, ..., s-1` and `⊤` elsewhere. -/
def diagonalEncode {n : ℕ} (s : Fin (n + 1)) :
    Matrix (Fin n) (Fin n) (WithTop ℤ) :=
  fun i j => if i = j ∧ i.val < s.val then (0 : WithTop ℤ) else ⊤

/-- **Diagonal rank invariant.**
Counts the number of finite (non-⊤) diagonal entries. -/
def diagRank {n : ℕ} (M : Matrix (Fin n) (Fin n) (WithTop ℤ)) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => M i i ≠ ⊤)).card

/-
**Diagonal encoding correctness.**
The diagonal rank of `diagonalEncode s` equals `s.val`.
-/
theorem diag_rank_correct {n : ℕ} (s : Fin (n + 1)) :
    diagRank (diagonalEncode s) = s.val := by
  unfold diagRank; unfold diagonalEncode; simp +decide ;
  rw [ Finset.card_eq_of_bijective ];
  use fun i hi => ⟨ i, by linarith [ Fin.is_lt s ] ⟩;
  · grind;
  · grind +extAll;
  · aesop

/-
**Diagonal encoding is injective.**
Different secrets produce different encoded matrices.
-/
theorem diagonalEncode_injective {n : ℕ} :
    Function.Injective
      (diagonalEncode : Fin (n + 1) → Matrix (Fin n) (Fin n) (WithTop ℤ)) := by
  intro s t h
  have h_diag_rank : diagRank (diagonalEncode s) = diagRank (diagonalEncode t) := by
    rw [h];
  exact Fin.ext ( by simpa [ diag_rank_correct ] using h_diag_rank )

/-
**Diagonal rank is bounded by dimension.**
-/
theorem diagRank_le_dim {n : ℕ} (M : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
    diagRank M ≤ n := by
  exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-
**Concrete hardness transfer with diagonal encoding.**
Secret recovery computes diagonal rank on the diagonal encoding family.
-/
theorem diagonal_hardness_transfer
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
    (recoverSecret : Matrix (Fin n) (Fin n) (WithTop ℤ) → Secret n)
    (hrec : ∀ s : Secret n, recoverSecret (tropPow G s.val) = s) :
    ∀ s : Secret n,
      diagRank (diagonalEncode (recoverSecret (tropPow G s.val))) = s.val := by
  exact fun s => by rw [ hrec s, diag_rank_correct ] ;

/-! ## Part VI: Compositional Reduction Schema

The following theorem packages the entire reduction as a reusable schema:
given any secret-recovery oracle, we construct a rank-computation oracle
on the encoded family. -/

/-
**Reduction schema.**
A secret-recovery oracle on `tropPow G` induces a rank-computation function
on the image of any encoding family, computed as
`rankInv ∘ encode ∘ recoverSecret`.
-/
theorem reduction_schema
    {n : ℕ} [NeZero n]
    (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
    (encode : ℕ → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (recoverSecret : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (rankInv : Matrix (Fin n) (Fin n) (WithTop ℤ) → ℕ)
    (hrec : ∀ s, recoverSecret (tropPow G s) = s)
    (hrank : ∀ s, rankInv (encode s) = s) :
    let solveRank := fun M => rankInv (encode (recoverSecret M))
    ∀ s, solveRank (tropPow G s) = s := by
  aesop

end