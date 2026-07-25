/-
  # Streaming Interactive Verification Protocol for Matrix Products

  This file formalizes a streaming verification protocol over `ZMod q`
  for checking matrix products, building on the algebraic infrastructure
  in `FreivaldsBridge.lean`.

  ## Architecture

  The streaming verifier stores only:
  - `r : Fin p → ZMod q` — the random challenge vector
  - `br : Fin n → ZMod q` — the compressed right witness `B.mulVec r`
  - `state : Fin m → ZMod q` — the running discrepancy `A.mulVec br - K.mulVec r`

  Memory: O(m + n + p) field elements, independent of the matrix entries.

  ## Main Results

  1. **streaming_verifier_accept_iff**: Algebraic invariant connecting
     acceptance to the discrepancy matrix.
  2. **exists_nonzero_discrepancy_row**: Matrix inequality implies a
     nonzero row in the discrepancy.
  3. **exists_coordinate_nonzero_of_ne_zero**: Nonzero vector has a
     nonzero coordinate.
  4. **streaming_verifier_soundness_bound**: If `K ≠ A * B`, at most
     `q^(p-1)` challenges are accepted.
  5. **streaming_verifier_accept_prob_le**: Probability form: acceptance
     probability ≤ `1/q`.
  6. **StreamingVerifier.state_eq_discrepancy_mulVec**: The verifier's
     state equals the discrepancy action on the challenge.
-/

import Mathlib
import Algebra.PolynomialSoundness.FreivaldsBridge

open Matrix Finset Fintype

/-! ## Streaming Verifier State -/

/-- The state of a streaming matrix-product verifier over `ZMod q`.

  The verifier stores:
  - `r`: the random challenge vector (p field elements)
  - `br`: the compressed right witness B·r (n field elements)
  - `state`: the running discrepancy A·(B·r) - K·r (m field elements)

  Total memory: O(m + n + p) field elements — sublinear in the matrix size m×n + n×p.
  In a row-streaming implementation where `br` is produced incrementally,
  active memory can be driven to O(m + p). -/
structure StreamingVerifier (q m n p : ℕ) [Fact q.Prime] where
  r     : Fin p → ZMod q
  br    : Fin n → ZMod q
  state : Fin m → ZMod q

/-- A streaming verifier state is *valid* with respect to matrices A, B, K
    when `br = B.mulVec r` and `state = A.mulVec br - K.mulVec r`.
    This is the streaming invariant: if these hold after processing all
    rows, then `state = 0` iff `K.mulVec r = (A*B).mulVec r`. -/
def StreamingVerifier.IsValid
    {q m n p : ℕ} [Fact q.Prime]
    (V : StreamingVerifier q m n p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q)) : Prop :=
  V.br = B.mulVec V.r ∧
  V.state = A.mulVec V.br - K.mulVec V.r

/-! ## Theorem A: Algebraic Invariant / Acceptance Criterion -/

/-
**Algebraic invariant**: The discrepancy `(K - A*B).mulVec r = 0`
    is equivalent to `K.mulVec r = (A*B).mulVec r`. This is the
    acceptance criterion for the streaming verifier.
-/
theorem streaming_verifier_accept_iff
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    (K - A * B).mulVec r = 0 ↔ K.mulVec r = (A * B).mulVec r := by
  simp +decide [ funext_iff, Matrix.sub_mulVec ];
  simp +decide only [sub_eq_zero]

/-! ## Theorem B: Nonzero Discrepancy Row -/

/-
**Row extraction**: If `K ≠ A * B`, then there exists a row index
    where the matrices disagree. This is the pivot from matrix inequality
    to a one-row linear test.
-/
theorem exists_nonzero_discrepancy_row
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ∃ i : Fin m, K i ≠ (A * B) i := by
  exact Function.ne_iff.mp hne

/-! ## Theorem C: Nonzero Vector Has Nonzero Coordinate -/

/-- A nonzero function `Fin p → ZMod q` has at least one nonzero value. -/
theorem exists_coordinate_nonzero_of_ne_zero
    {q p : ℕ} [Fact q.Prime]
    (v : Fin p → ZMod q)
    (hv : v ≠ 0) :
    ∃ j : Fin p, v j ≠ 0 :=
  Function.ne_iff.mp hv

/-! ## Theorem D: Streaming Verifier Soundness Bound -/

/-
**Soundness bound (cardinality form)**: If `K ≠ A * B`, then the
    number of challenge vectors `r` for which the verifier accepts is
    at most `q^(p-1)`. This is the algebraic heart of Freivalds-style
    verification, specialized to the streaming protocol over `ZMod q`.
-/
theorem streaming_verifier_soundness_bound
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r}
      ≤ q ^ (p - 1) := by
  have := card_mulVec_zero_le ( K - A * B ) ( sub_ne_zero.mpr hne );
  simp_all +decide [ sub_eq_zero, Matrix.sub_mulVec ]

/-! ## Probability Form -/

/-
**Soundness bound (probability form)**: If `K ≠ A * B`, the probability
    that a uniformly random challenge `r` causes the verifier to accept
    is at most `1/q`.
-/
theorem streaming_verifier_accept_prob_le
    {q m n p : ℕ} [Fact q.Prime] [NeZero q]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B)
    (hp : 0 < p) :
    ((Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r} : ℚ)
      / q ^ p) ≤ (1 : ℚ) / q := by
  rw [ div_le_div_iff₀ ];
  · norm_cast;
    convert Nat.mul_le_mul_right q ( streaming_verifier_soundness_bound A B K hne ) using 1;
    rw [ one_mul, ← pow_succ, Nat.sub_add_cancel hp ];
  · exact_mod_cast pow_pos ( Nat.Prime.pos Fact.out ) _;
  · exact Nat.cast_pos.mpr ( Nat.Prime.pos Fact.out )

/-! ## Streaming Verifier State Invariant -/

/-
**State invariant**: A valid verifier's state equals the discrepancy
    matrix action on the challenge vector. This connects the operational
    streaming state to the algebraic acceptance criterion.
-/
theorem StreamingVerifier.state_eq_discrepancy_mulVec
    {q m n p : ℕ} [Fact q.Prime]
    (V : StreamingVerifier q m n p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hV : V.IsValid A B K) :
    V.state = (A * B - K).mulVec V.r := by
  convert hV.2 using 1 ; simp +decide [ Matrix.sub_mulVec, hV.1 ]

/-
**Completeness**: If `K = A * B`, a valid verifier always accepts.
-/
theorem StreamingVerifier.complete
    {q m n p : ℕ} [Fact q.Prime]
    (V : StreamingVerifier q m n p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hV : V.IsValid A B K)
    (heq : K = A * B) :
    V.state = 0 := by
  convert StreamingVerifier.state_eq_discrepancy_mulVec V A B K hV;
  simp +decide [ heq ]

/-
**Soundness (state form)**: If `K ≠ A * B`, there exists a challenge
    such that a valid verifier rejects.
-/
theorem StreamingVerifier.exists_rejecting_challenge
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ∃ r_bad : Fin p → ZMod q, K.mulVec r_bad ≠ (A * B).mulVec r_bad := by
  contrapose! hne;
  exact Matrix.ext fun i j => by simpa using congr_fun ( hne ( Pi.single j 1 ) ) i;

/-! ## Construction: Building a Valid Verifier -/

/-- Construct a valid streaming verifier from matrices and a challenge vector. -/
noncomputable def StreamingVerifier.mk_valid
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) : StreamingVerifier q m n p :=
  { r := r
    br := B.mulVec r
    state := A.mulVec (B.mulVec r) - K.mulVec r }

/-
The constructed verifier is always valid.
-/
theorem StreamingVerifier.mk_valid_isValid
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    (StreamingVerifier.mk_valid A B K r).IsValid A B K := by
  exact ⟨ rfl, rfl ⟩

/-
**Accept iff state is zero**: For a valid verifier, acceptance
    (state = 0) is equivalent to K·r = (A*B)·r.
-/
theorem StreamingVerifier.accept_iff_state_zero
    {q m n p : ℕ} [Fact q.Prime]
    (V : StreamingVerifier q m n p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hV : V.IsValid A B K) :
    V.state = 0 ↔ K.mulVec V.r = (A * B).mulVec V.r := by
  constructor <;> intro h;
  · -- By definition of $V$, we know that $V.state = A.mulVec (B.mulVec V.r) - K.mulVec V.r$.
    have h_state : V.state = A.mulVec (B.mulVec V.r) - K.mulVec V.r := by
      exact hV.2.trans ( by rw [ hV.1 ] );
    rw [ h_state ] at h; rw [ sub_eq_zero ] at h; aesop;
  · convert sub_eq_zero.mpr h.symm using 1;
    convert StreamingVerifier.state_eq_discrepancy_mulVec V A B K hV using 1;
    simp +decide [ Matrix.sub_mulVec ]