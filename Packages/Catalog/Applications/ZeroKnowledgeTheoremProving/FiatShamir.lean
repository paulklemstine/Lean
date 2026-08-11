import Applications.ZeroKnowledgeTheoremProving.EntropyAndBoundaries

/-!
# The Fiat–Shamir Inversion: Non-Interactive Soundness Holds Exactly for False Statements

Cycle 2 of the research loop. Having proved (in `ProvabilityAmplification`) that
the *interactive* affine Σ-protocol has soundness error `(1/2)^n`, the obvious
next conjecture is that removing interaction — replacing the verifier's coin by
a public hash of the commitment, the Fiat–Shamir transform — preserves
soundness. It does not, and the failure is *unconditional*: it has nothing to do
with the quality of the hash.

Fix a public hash `Hash : H → Bool`. A non-interactive proof is a pair `(a, z)`
accepted when `Accepts s ⟨a, Hash a, z⟩` (`NIZKAccepts`). Call the hash
*forgery-free* for the statement when no such pair exists at all.

The main results are:

* `nizk_exists_iff` — accepted non-interactive proofs correspond exactly to
  solutions of the fixed-point equation `Hash (f z - c · target) = c`;
* `forgeryFree_iff` — forgery-freeness is the conjunction of two rigid colouring
  conditions: `Hash` must be constantly `true` on the image of the public
  homomorphism and constantly `false` on the image translated by `-target`;
* `nizk_exists_of_isWitness` — **if the statement is true, every hash whatsoever
  admits an accepted non-interactive proof**;
* `exists_forgeryFree_iff_no_witness` — **a forgery-free hash exists if and only
  if the statement is false**.

So in the information-theoretic model, a Fiat–Shamir proof of a *true* statement
is never evidence of knowledge: an accepted pair exists unconditionally, for
every hash function. Non-interactive conviction therefore cannot be
information-theoretic; it must rest on the computational hardness of *finding*
the pair. This is the exact boundary of the "prove a theorem without revealing
why" programme: interaction (or computational hardness) is not a convenience but
a necessity, and `zk_convinces_provable` genuinely needs *two* transcripts.

`constantHash_forgeable` records the extreme case: with a constant hash, an
accepted non-interactive proof exists for *every* statement, true or false.
-/

namespace ZeroKnowledgeTheoremProving.AffineDuality

variable {G H : Type*} [AddCommGroup G] [AddCommGroup H]

/-- A non-interactive (Fiat–Shamir) proof is a commitment/response pair accepted
when the challenge is the hash of the commitment. -/
def NIZKAccepts (s : Statement (G := G) (H := H)) (Hash : H → Bool) (a : H) (z : G) : Prop :=
  Accepts s ⟨a, Hash a, z⟩

/-- **Fixed-point description of non-interactive proofs.** An accepted pair
exists iff the hash agrees with its own challenge on some simulated
commitment. -/
theorem nizk_exists_iff (s : Statement (G := G) (H := H)) (Hash : H → Bool) :
    (∃ a z, NIZKAccepts s Hash a z) ↔
      ∃ (z : G) (c : Bool), Hash (s.hom z - challengeTerm c s.target) = c := by
  constructor
  · rintro ⟨a, z, hz⟩
    refine ⟨z, Hash a, ?_⟩
    have hacc : s.hom z = a + challengeTerm (Hash a) s.target := hz
    have : s.hom z - challengeTerm (Hash a) s.target = a := by
      rw [hacc, add_sub_cancel_right]
    rw [this]
  · rintro ⟨z, c, hc⟩
    refine ⟨s.hom z - challengeTerm c s.target, z, ?_⟩
    show s.hom z = (s.hom z - challengeTerm c s.target) +
      challengeTerm (Hash (s.hom z - challengeTerm c s.target)) s.target
    rw [hc, sub_add_cancel]

/-- With a constant hash, every statement — true or false — admits an accepted
non-interactive proof. -/
theorem constantHash_forgeable (s : Statement (G := G) (H := H)) (b : Bool) (z : G) :
    NIZKAccepts s (fun _ => b) (s.hom z - challengeTerm b s.target) z := by
  show s.hom z = (s.hom z - challengeTerm b s.target) + challengeTerm b s.target
  rw [sub_add_cancel]

/-- A hash is *forgery-free* for a statement when no non-interactive proof is
accepted. -/
def ForgeryFree (s : Statement (G := G) (H := H)) (Hash : H → Bool) : Prop :=
  ¬ ∃ a z, NIZKAccepts s Hash a z

/-- **Rigidity of forgery-free hashes.** Forgery-freeness forces the hash to be
constantly `true` on the image of the public homomorphism and constantly `false`
on that image translated by `-target`. -/
theorem forgeryFree_iff (s : Statement (G := G) (H := H)) (Hash : H → Bool) :
    ForgeryFree s Hash ↔
      ((∀ z : G, Hash (s.hom z) = true) ∧ ∀ z : G, Hash (s.hom z - s.target) = false) := by
  rw [ForgeryFree, nizk_exists_iff]
  constructor
  · intro h
    constructor
    · intro z
      by_contra hz
      exact h ⟨z, false, by simpa [challengeTerm] using Bool.not_eq_true _ |>.mp hz⟩
    · intro z
      by_contra hz
      have : Hash (s.hom z - s.target) = true := by
        simpa using Bool.not_eq_false _ |>.mp hz
      exact h ⟨z, true, by simpa [challengeTerm] using this⟩
  · rintro ⟨h₁, h₂⟩ ⟨z, c, hc⟩
    cases c with
    | false =>
        simp only [challengeTerm, if_neg (Bool.false_ne_true), sub_zero] at hc
        rw [h₁ z] at hc
        exact Bool.noConfusion hc
    | true =>
        simp only [challengeTerm, if_true] at hc
        rw [h₂ z] at hc
        exact Bool.noConfusion hc

/-- **Unconditional Fiat–Shamir failure on true statements.** If the statement
has a witness then *every* hash function admits an accepted non-interactive
proof. No choice of hash can make the transform information-theoretically
sound. -/
theorem nizk_exists_of_isWitness (s : Statement (G := G) (H := H)) {w : G}
    (hw : IsWitness s w) (Hash : H → Bool) :
    ∃ a z, NIZKAccepts s Hash a z := by
  have hw' : s.hom w = s.target := hw
  rw [nizk_exists_iff]
  cases hb : Hash (0 : H) with
  | false =>
      refine ⟨0, false, ?_⟩
      simpa [challengeTerm] using hb
  | true =>
      refine ⟨w, true, ?_⟩
      have : s.hom w - challengeTerm true s.target = 0 := by
        simp [challengeTerm, hw']
      rw [this, hb]

/-- If some hash is forgery-free then the statement is false. -/
theorem no_witness_of_forgeryFree (s : Statement (G := G) (H := H)) {Hash : H → Bool}
    (hff : ForgeryFree s Hash) : ∀ w : G, ¬ IsWitness s w := by
  intro w hw
  exact hff (nizk_exists_of_isWitness s hw Hash)

open scoped Classical in
/-- The canonical candidate: colour the image of the public homomorphism
`true` and everything else `false`. -/
noncomputable def imageHash (s : Statement (G := G) (H := H)) : H → Bool :=
  fun a => decide (∃ z : G, s.hom z = a)

open scoped Classical in
/-- For a false statement the image colouring is forgery-free. -/
theorem imageHash_forgeryFree (s : Statement (G := G) (H := H))
    (hno : ∀ w : G, ¬ IsWitness s w) : ForgeryFree s (imageHash s) := by
  rw [forgeryFree_iff]
  constructor
  · intro z
    simp [imageHash]
  · intro z
    simp only [imageHash, decide_eq_false_iff_not]
    rintro ⟨y, hy⟩
    refine hno (z - y) ?_
    show s.hom (z - y) = s.target
    rw [map_sub, hy]
    abel

open scoped Classical in
/-- **Fiat–Shamir inversion.** A forgery-free hash exists for a statement if and
only if that statement is *false*. Non-interactive soundness in the
information-theoretic model is therefore equivalent to the statement being
unprovable — precisely the opposite of what a proof system needs. -/
theorem exists_forgeryFree_iff_no_witness (s : Statement (G := G) (H := H)) :
    (∃ Hash : H → Bool, ForgeryFree s Hash) ↔ (∀ w : G, ¬ IsWitness s w) := by
  constructor
  · rintro ⟨Hash, hff⟩
    exact no_witness_of_forgeryFree s hff
  · intro hno
    exact ⟨imageHash s, imageHash_forgeryFree s hno⟩

/-- **Interaction is necessary.** Contrast with the interactive protocol: for a
false statement, a committed prover fails all but at most one of `2 ^ n`
challenge vectors, whereas for a *true* statement every non-interactive hash
already admits an accepted proof. Conviction from a Fiat–Shamir transcript is
thus never information-theoretic. -/
theorem interaction_necessary (s : Statement (G := G) (H := H)) (n : ℕ) :
    ((∀ w : G, ¬ IsWitness s w) →
        ∀ P : ParallelProver G H n,
          ((cheatSet s n P).card : ℚ) / (Finset.univ : Finset (Fin n → Bool)).card
            ≤ (1 / 2) ^ n) ∧
      ((∃ w : G, IsWitness s w) → ∀ Hash : H → Bool, ∃ a z, NIZKAccepts s Hash a z) := by
  refine ⟨fun hno P => soundness_error_le s n hno P, ?_⟩
  rintro ⟨w, hw⟩ Hash
  exact nizk_exists_of_isWitness s hw Hash

end ZeroKnowledgeTheoremProving.AffineDuality