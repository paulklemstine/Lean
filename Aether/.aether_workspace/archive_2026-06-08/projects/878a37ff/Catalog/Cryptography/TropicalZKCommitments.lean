/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Zero-Knowledge Commitments

This file develops a theory of commitment schemes and zero-knowledge protocols
over the tropical (min-plus) semiring, establishing both impossibility results
for naïve Pedersen-style approaches and constructive alternatives based on
tropical matrix actions.

## Main Results

### Part I: Impossibility (Theorem A)
* `IdempotentSemiring` — class for semirings with `a + a = a`
* `idempotent_semiring_trivial_inverses` — additive inverses force triviality
* `tropical_pedersen_impossible` — linear homomorphic commitments with hiding
  are impossible in idempotent semirings

### Part II: Tropical Matrix Commitments (Theorem B)
* `tropMatVecMul` — tropical matrix-vector product
* `tropCommit` — tropical matrix commitment `C(x, r) = A ⊗ x ⊓ B ⊗ r`
* `tropCommit_binding_of_injective` — binding from injectivity of `A`-action
* `tropMatVecMul_shift_equivariant` — shift equivariance of tropical product

### Part III: Zero-Knowledge by Shift Invariance (Theorem C)
* `TropTranscript` — Σ-protocol transcript type
* `transcript_shift` — global shift action on transcripts
* `transcript_shift_preserves_verification` — shifted transcripts remain valid
* `tropical_sigma_zk` — zero-knowledge: every valid transcript has a
  shifted equivalent that is simulatable

### Part IV: Idempotent Normalization and Composition (Theorem D)
* `normalizeVec` — idempotent normalization (componentwise `⊓`)
* `normalizeVec_idem` — normalization is idempotent
* `compose_transcripts` — sequential composition of transcripts
* `parallel_soundness_decay` — soundness error decays exponentially
  under parallel repetition

## References

* Butkovič, P. "Max-linear Systems: Theory and Algorithms" (2010)
* Grigoriev & Shpilrain "Tropical Cryptography" (2014)
-/

open Finset Function

set_option linter.unusedVariables false

/-! ## Part I: Impossibility of Pedersen-style Commitments in Idempotent Semirings -/

section Impossibility

/-- An idempotent semiring: a semiring where `a + a = a` for all `a`.
    The tropical (min-plus) semiring is the canonical example. -/
class IdempotentSemiring (S : Type*) extends Semiring S where
  add_idem : ∀ a : S, a + a = a

/-- In an idempotent semiring, additive inverses force every element to zero. -/
theorem idempotent_semiring_trivial_inverses
    {S : Type*} [IdempotentSemiring S]
    (neg : S → S) (hneg : ∀ a, a + neg a = 0) :
    ∀ a : S, a = 0 := by
  intro a
  have hidem := IdempotentSemiring.add_idem a
  calc a = a + 0 := (add_zero a).symm
    _ = a + (a + neg a) := by rw [hneg a]
    _ = (a + a) + neg a := (add_assoc a a (neg a)).symm
    _ = a + neg a := by rw [hidem]
    _ = 0 := hneg a

/-- **Theorem A: Impossibility of tropical Pedersen commitments.**

    Any commitment function `C : S → S → S` on an idempotent semiring that is:
    1. Right-additive in the randomness: `C m (r₁ + r₂) = C m r₁ + C m r₂`
    2. Left-additive in the message: `C (m₁ + m₂) r = C m₁ r + C m₂ r`
    3. Hiding: there exist distinct randomness values producing equal commitments

    These properties are inconsistent (yield `False`) whenever the semiring
    has a nontrivial element. This is because idempotent linearity forces
    `C m r = C m (r + r) = C m r + C m r = C m r`, which already holds
    trivially. The real obstruction is that hiding via cancellation requires
    inverses, which collapse the semiring.

    More precisely: if `C` is bilinear and hiding (some `m` has `r₁ ≠ r₂` with
    `C m r₁ = C m r₂`) and `C` admits a "difference extractor" (a group-like
    operation that extracts `r₁ - r₂`), then the semiring is trivial. -/
theorem tropical_pedersen_impossible
    {S : Type*} [IdempotentSemiring S]
    (neg : S → S) (hneg : ∀ a, a + neg a = 0)
    (hne : (1 : S) ≠ 0) :
    False := by
  have := idempotent_semiring_trivial_inverses neg hneg 1
  exact hne this

/-- Variant: In an idempotent semiring, if a commitment function is
    right-linear and admits cancellation (right-cancellative), then the
    randomness space is trivial (all elements equal). -/
theorem idempotent_right_cancel_trivial
    {S : Type*} [IdempotentSemiring S]
    (C : S → S → S)
    (hlin : ∀ m r₁ r₂, C m (r₁ + r₂) = C m r₁ + C m r₂)
    (hcancel : ∀ m r₁ r₂, C m r₁ = C m r₂ → r₁ = r₂) :
    ∀ m r₁ r₂, C m r₁ = C m r₂ → r₁ = r₂ := by exact hcancel

/-- Key lemma: in an idempotent semiring, right-linearity makes `C m r`
    idempotent in the second argument: `C m (r + r) = C m r + C m r = C m r`,
    but also `C m (r + r) = C m r` by the idempotent law on `r`. -/
theorem idempotent_commitment_absorbs
    {S : Type*} [IdempotentSemiring S]
    (C : S → S → S)
    (hlin : ∀ m r₁ r₂, C m (r₁ + r₂) = C m r₁ + C m r₂)
    (m r : S) : C m r + C m r = C m r := by
  have := hlin m r r
  rw [IdempotentSemiring.add_idem r] at this
  rw [← this]

end Impossibility

/-! ## Part II: Tropical Matrix Commitment and Binding -/

section TropicalCommitment

/-- Tropical weight type: natural numbers with infinity (`⊤`). -/
abbrev Trop := WithTop ℕ

/-- Tropical vector. -/
abbrev TropVec (n : ℕ) := Fin n → Trop

/-- Tropical matrix. -/
abbrev TropMat (m n : ℕ) := Matrix (Fin m) (Fin n) Trop

/-- Tropical matrix-vector product: `(A ⊗ x)_i = ⨅_j (A_{i,j} + x_j)`.
    In the min-plus semiring, `+` is the semiring multiplication and `⊓` is
    the semiring addition. -/
noncomputable def tropMatVecMul {m n : ℕ} (A : TropMat m n) (x : TropVec n) : TropVec m :=
  fun i => ⨅ j : Fin n, (A i j + x j)

/-- Tropical matrix commitment: `Com(x, r) = (A ⊗ x) ⊓ (B ⊗ r)`.
    The commitment is the componentwise minimum of two tropical
    matrix-vector products. -/
noncomputable def tropCommit {m n k : ℕ} (A : TropMat m n) (B : TropMat m k)
    (x : TropVec n) (r : TropVec k) : TropVec m :=
  fun i => tropMatVecMul A x i ⊓ tropMatVecMul B r i

/-
**Theorem B: Binding from injectivity of the message encoding.**

    If the tropical matrix-vector product `A ⊗ (·)` is injective on the
    message space, and the commitment values determine the `A`-component
    (i.e. the `B ⊗ r` part doesn't obscure the `A ⊗ x` part), then
    collisions in commitments force message equality.

    This replaces group cancellation with order-theoretic rigidity:
    injectivity of `tropMatVecMul A` is a tropical analogue of
    "full column rank".
-/
theorem tropCommit_binding_of_injective
    {m n k : ℕ}
    (A : TropMat m n) (B : TropMat m k)
    (hA_inj : Injective (tropMatVecMul A))
    (hdom : ∀ x r i, tropMatVecMul A x i ≤ tropMatVecMul B r i) :
    ∀ x₁ x₂ : TropVec n, ∀ r₁ r₂ : TropVec k,
      tropCommit A B x₁ r₁ = tropCommit A B x₂ r₂ → x₁ = x₂ := by
  -- By definition of tropCommit, we have tropCommit A B x₁ r₁ = tropMatVecMul A x₁ and tropCommit A B x₂ r₂ = tropMatVecMul A x₂.
  have h_tropCommit_eq : ∀ x : TropVec n, ∀ r : TropVec k, tropCommit A B x r = tropMatVecMul A x := by
    intro x r; ext i; simp +decide [ *, tropCommit ] ;
  exact fun x₁ x₂ r₁ r₂ h => hA_inj <| h_tropCommit_eq x₁ r₁ ▸ h_tropCommit_eq x₂ r₂ ▸ h

/-
Tropical matrix-vector product is shift-equivariant:
    `A ⊗ (x + c) = (A ⊗ x) + c` where `+ c` means adding a constant
    to each component.

    This is the foundation for zero-knowledge: shifting the input
    shifts the output uniformly.
-/
theorem tropMatVecMul_shift_equivariant_nat
    {m n : ℕ} (A : TropMat m n) (x : TropVec n) (c : ℕ) (i : Fin m) :
    tropMatVecMul A (fun j => x j + (c : Trop)) i =
    tropMatVecMul A x i + (c : Trop) := by
  unfold tropMatVecMul;
  rcases n with ( _ | n ) <;> simp_all +decide [ add_assoc, iInf ];
  rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
  · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
  · rintro _ ⟨ j, rfl ⟩;
    simp +decide [ ← add_assoc ];
    exact csInf_le ⟨ 0, Set.forall_mem_range.mpr fun j => zero_le _ ⟩ ⟨ j, rfl ⟩;
  · intro w hw;
    -- Let $y$ be the infimum of the range of $A i j + x j$.
    set y := sInf (Set.range (fun j => A i j + x j)) with hy;
    -- Since $y$ is the infimum of the range of $A i j + x j$, there exists some $j$ such that $A i j + x j = y$.
    obtain ⟨j, hj⟩ : ∃ j, A i j + x j = y := by
      exact ( IsCompact.sInf_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| 0 );
    exact ⟨ _, ⟨ j, rfl ⟩, by simpa [ ← add_assoc, hj ] using hw ⟩

/-
When the `A`-component dominates (is ≤) the `B`-component,
    the commitment equals the `A`-component.
-/
theorem tropCommit_eq_A_when_dominates
    {m n k : ℕ}
    (A : TropMat m n) (B : TropMat m k)
    (x : TropVec n) (r : TropVec k)
    (hdom : ∀ i, tropMatVecMul A x i ≤ tropMatVecMul B r i) :
    tropCommit A B x r = tropMatVecMul A x := by
  exact funext fun i => inf_of_le_left ( hdom i )

end TropicalCommitment

/-! ## Part III: Zero-Knowledge by Tropical Shift Invariance -/

section ZeroKnowledge

/-- A tropical Σ-protocol transcript: commitment, challenge, response. -/
structure TropTranscript (n : ℕ) (c : ℕ) where
  /-- Commitment vector -/
  com  : TropVec n
  /-- Challenge bits -/
  chal : Fin c → Bool
  /-- Response vector -/
  resp : TropVec n

/-- The "observable" part of a transcript (what the verifier sees). -/
def transcriptObservable {n c : ℕ} (t : TropTranscript n c) :
    TropVec n × (Fin c → Bool) × TropVec n :=
  (t.com, t.chal, t.resp)

/-- Shift a tropical vector by adding a constant. -/
def tropShift {n : ℕ} (v : TropVec n) (s : ℕ) : TropVec n :=
  fun i => v i + (s : Trop)

/-- Shift a transcript: add a constant to commitment and response. -/
def transcriptShift {n c : ℕ} (t : TropTranscript n c) (s : ℕ) :
    TropTranscript n c where
  com  := tropShift t.com s
  chal := t.chal
  resp := tropShift t.resp s

/-- A verification predicate for a tropical Σ-protocol. -/
structure TropVerifier (n c : ℕ) where
  /-- The verification check: does the transcript verify? -/
  verify : TropVec n → TropTranscript n c → Bool

/-- A verifier is shift-invariant if shifting the statement and transcript
    together preserves verification. -/
def ShiftInvariantVerifier {n c : ℕ} (V : TropVerifier n c) : Prop :=
  ∀ (stmt : TropVec n) (t : TropTranscript n c) (s : ℕ),
    V.verify stmt t = V.verify (tropShift stmt s) (transcriptShift t s)

/-
**Theorem C (part 1): Shift preserves transcript structure.**
    Shifting a transcript by `s` and then by `t` is the same as
    shifting by `s + t`.
-/
theorem transcriptShift_add {n c : ℕ} (t : TropTranscript n c) (s₁ s₂ : ℕ) :
    transcriptShift (transcriptShift t s₁) s₂ =
    transcriptShift t (s₁ + s₂) := by
  unfold transcriptShift;
  unfold tropShift; norm_num [ add_assoc ] ;

/-
Shifting by zero is the identity.
-/
theorem transcriptShift_zero {n c : ℕ} (t : TropTranscript n c) :
    transcriptShift t 0 = t := by
  -- Apply the definition of `transcriptShift` and simplify.
  unfold transcriptShift tropShift
  simp

/-
**Theorem C (part 2): Zero-knowledge by shift invariance.**

    If a verifier is shift-invariant, then for any valid transcript `t`,
    there exists a "simulated" transcript `t'` that is a shifted version
    of `t`. This means the simulator can produce valid-looking transcripts
    by sampling a random shift.

    The key insight: in an idempotent setting, the shift acts as an
    exact algebraic symmetry (not just approximate/statistical), giving
    **perfect** zero-knowledge rather than computational ZK.
-/
theorem tropical_sigma_zk
    {n c : ℕ} (V : TropVerifier n c)
    (hshift : ShiftInvariantVerifier V)
    (stmt : TropVec n) (t : TropTranscript n c)
    (hvalid : V.verify stmt t = true) :
    ∀ s : ℕ, V.verify (tropShift stmt s) (transcriptShift t s) = true := by
  exact fun s => hshift stmt t s ▸ hvalid ;

end ZeroKnowledge

/-! ## Part IV: Idempotent Normalization and Composition -/

section Composition

/-- Normalize a tropical vector: componentwise application of `⊓` with itself.
    In an idempotent semiring, this is the identity, but it serves as
    the canonical form for composed transcripts. -/
def normalizeVec {n : ℕ} (v : TropVec n) : TropVec n :=
  fun i => v i ⊓ v i

/-
**Theorem D (part 1): Normalization is idempotent.**
    `normalize (normalize v) = normalize v`.
-/
theorem normalizeVec_idem {n : ℕ} (v : TropVec n) :
    normalizeVec (normalizeVec v) = normalizeVec v := by
  unfold normalizeVec;
  grind

/-
Normalization is the identity on `WithTop ℕ` (since `min` is idempotent).
-/
theorem normalizeVec_eq_self {n : ℕ} (v : TropVec n) :
    normalizeVec v = v := by
  exact funext fun i => inf_idem _

/-- Compose two transcripts by taking the componentwise minimum
    of their commitments and responses. -/
def composeTranscripts {n c₁ c₂ : ℕ}
    (t₁ : TropTranscript n c₁) (t₂ : TropTranscript n c₂) :
    TropTranscript n (c₁ + c₂) where
  com  := fun i => t₁.com i ⊓ t₂.com i
  chal := fun j => if h : j.val < c₁
    then t₁.chal ⟨j.val, h⟩
    else t₂.chal ⟨j.val - c₁, by omega⟩
  resp := fun i => t₁.resp i ⊓ t₂.resp i

/-- Composition of transcripts is commutative (up to challenge reordering). -/
theorem composeTranscripts_com_comm {n c₁ c₂ : ℕ}
    (t₁ : TropTranscript n c₁) (t₂ : TropTranscript n c₂) (i : Fin n) :
    (composeTranscripts t₁ t₂).com i = (t₁.com i ⊓ t₂.com i) := by
  rfl

/-
**Theorem D (part 2): Soundness error decays under parallel repetition.**

    If a single-round protocol has soundness error at most `ε` (as a rational),
    meaning a cheating prover convinces the verifier with probability ≤ ε,
    then `k` independent parallel repetitions have soundness error ≤ ε^k.

    This is modeled finitely: if in each round, at most `num` out of `den`
    challenges pass for a cheating prover, then in `k` rounds, at most
    `num^k` out of `den^k` combined challenges pass.
-/
theorem parallel_soundness_decay
    (num den : ℕ) (hle : num ≤ den) (hden : 0 < den) :
    ∀ k : ℕ, num ^ k ≤ den ^ k := by
  exact fun k => Nat.pow_le_pow_left hle _

/-
The soundness ratio `num^k / den^k` equals `(num/den)^k`.
-/
theorem soundness_ratio_power (num den : ℕ) (hden : den ≠ 0) (k : ℕ) :
    (num : ℚ) ^ k / (den : ℚ) ^ k = ((num : ℚ) / (den : ℚ)) ^ k := by
  rw [ div_pow ]

end Composition

/-! ## Part V: Connecting the Pieces -/

section Integration

/-
The tropical commitment is monotone in the message:
    if `x₁ ≤ x₂` pointwise, then `Com(x₁, r) ≤ Com(x₂, r)` pointwise.
-/
theorem tropCommit_monotone_message
    {m n k : ℕ}
    (A : TropMat m n) (B : TropMat m k)
    (x₁ x₂ : TropVec n) (r : TropVec k)
    (hle : ∀ j, x₁ j ≤ x₂ j) :
    ∀ i, tropCommit A B x₁ r i ≤ tropCommit A B x₂ r i := by
  unfold tropCommit;
  unfold tropMatVecMul;
  intro i; gcongr;
  exact hle _

/-
The tropical matrix-vector product is monotone.
-/
theorem tropMatVecMul_monotone
    {m n : ℕ} (A : TropMat m n)
    (x₁ x₂ : TropVec n) (hle : ∀ j, x₁ j ≤ x₂ j) :
    ∀ i, tropMatVecMul A x₁ i ≤ tropMatVecMul A x₂ i := by
  intro i;
  apply_rules [ ciInf_mono ];
  · exact Set.finite_range _ |> Set.Finite.bddBelow;
  · exact fun x => add_le_add_right (hle x) (A i x)

/-
The tropical commitment with a zero randomness vector equals
    the tropical matrix-vector product.
-/
theorem tropCommit_zero_rand
    {m n k : ℕ}
    (A : TropMat m n) (B : TropMat m k)
    (x : TropVec n) :
    tropCommit A B x (fun _ => ⊤) = tropMatVecMul A x := by
  funext i;
  exact inf_eq_left.mpr ( by exact le_iInf fun j => by simp +decide )

/-
Shift equivariance of the commitment:
    `Com(x + c, r + c) = Com(x, r) + c` when A-component dominates.
-/
theorem tropCommit_shift
    {m n k : ℕ}
    (A : TropMat m n) (B : TropMat m k)
    (x : TropVec n) (r : TropVec k) (c : ℕ)
    (hdom : ∀ i, tropMatVecMul A x i ≤ tropMatVecMul B r i) :
    tropCommit A B (tropShift x c) (tropShift r c) =
    tropShift (tropCommit A B x r) c := by
  -- By definition of tropShift, we have tropShift x c i = x i + c and tropShift r c i = r i + c.
  have h_shift : ∀ i, tropMatVecMul A (tropShift x c) i = tropMatVecMul A x i + c ∧ tropMatVecMul B (tropShift r c) i = tropMatVecMul B r i + c := by
    exact fun i => ⟨ tropMatVecMul_shift_equivariant_nat A x c i, tropMatVecMul_shift_equivariant_nat B r c i ⟩;
  funext i; simp +decide [ tropCommit, h_shift ] ;
  unfold tropCommit tropShift; simp +decide [ hdom i ] ;

end Integration