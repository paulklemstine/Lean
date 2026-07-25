/-
  Merkle–Damgård Collision Resistance Preservation
  =================================================

  We formalize the Merkle–Damgård (MD) iterated-hash construction and prove the
  classical theorem that it *preserves collision resistance*: any collision in
  the iterated hash (on equal-length messages) can be turned, constructively,
  into a collision of the underlying compression function.

  This is the combinatorial heart of the statement "collision-resistant hash
  functions can be built from a collision-resistant compression function".
  No probability is needed: the reduction is an explicit extraction.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): If `f` is collision-free, the left-fold MD hash is
  injective on each fixed message length; equivalently, an MD collision on
  equal-length messages yields an `f`-collision.

  EXPERIMENT (Experimenter): Proved `md_collision_extract` by reverse induction
  on the first message (induction on `l ++ [b]`), generalizing over the second
  message. The last-block comparison either gives the collision immediately or
  reduces to strictly shorter prefixes.

  ANALYSIS (Analyst): The equal-length hypothesis is *necessary*, not cosmetic:
  without length padding, different-length messages can collide via an IV/free-
  start collision rather than a genuine compression collision (see
  `ComputationalEvidence.md`). The theorem is therefore stated at its tight
  boundary.

  CRITIQUE (Critic): Checked the base case is genuinely handled (empty vs empty
  forces equality, contradicting `m₁ ≠ m₂`) so the theorem is not vacuous. Added
  a finite pigeonhole theorem `compression_collision_of_card` proving collisions
  always exist, ruling out an information-theoretic reading and confirming the
  result is about *extraction*, not existence.

  SYNTHESIS (PI): `mdHash` + `HasCompressionCollision` + extraction theorem +
  injectivity corollary + pigeonhole inevitability give a self-contained MD
  collision-resistance package.
-/
import Mathlib

namespace Cryptography.MerkleDamgard

variable {State Block : Type*}

/-- The Merkle–Damgård iterated hash: fold the compression function `f` over the
    message blocks, starting from the initialization vector `iv`. -/
def mdHash (f : State → Block → State) (iv : State) (msg : List Block) : State :=
  msg.foldl f iv

/-- A compression function `f` has a *collision* when two distinct inputs
    `(s, b) ≠ (s', b')` are mapped to the same output. -/
def HasCompressionCollision (f : State → Block → State) : Prop :=
  ∃ s b s' b', (s, b) ≠ (s', b') ∧ f s b = f s' b'

@[simp] theorem mdHash_nil (f : State → Block → State) (iv : State) :
    mdHash f iv [] = iv := rfl

@[simp] theorem mdHash_concat (f : State → Block → State) (iv : State)
    (l : List Block) (b : Block) :
    mdHash f iv (l ++ [b]) = f (mdHash f iv l) b := by
  simp [mdHash]

/-- The MD hash composes along message concatenation: hashing `a ++ b` equals
    hashing `b` starting from the chaining value obtained after `a`. -/
theorem mdHash_append (f : State → Block → State) (iv : State) (a b : List Block) :
    mdHash f iv (a ++ b) = mdHash f (mdHash f iv a) b := by
  simp [mdHash, List.foldl_append]

/-- **Merkle–Damgård collision extraction.**
    Any collision of the iterated hash on two *equal-length* distinct messages
    yields an explicit collision of the compression function `f`. -/
theorem md_collision_extract (f : State → Block → State) (iv : State)
    (m₁ m₂ : List Block) (hlen : m₁.length = m₂.length) (hne : m₁ ≠ m₂)
    (hcol : mdHash f iv m₁ = mdHash f iv m₂) :
    HasCompressionCollision f := by
  induction' m₁ using List.reverseRecOn with m₁ b₁ ih generalizing m₂;
  · cases m₂ <;> trivial;
  · obtain ⟨p₂, b₂, hp₂⟩ : ∃ p₂ b₂, m₂ = p₂ ++ [b₂] := by
      exact ⟨ m₂.dropLast, m₂.getLast ( by aesop ), by rw [ List.dropLast_append_getLast ( by aesop ) ] ⟩;
    grind +locals

/-- **Collision resistance is preserved (contrapositive form).**
    If the compression function has no collision, then the MD hash is injective
    on each fixed message length. -/
theorem mdHash_injOn_length (f : State → Block → State) (iv : State)
    (hf : ¬ HasCompressionCollision f) (m₁ m₂ : List Block)
    (hlen : m₁.length = m₂.length) (hcol : mdHash f iv m₁ = mdHash f iv m₂) :
    m₁ = m₂ := by
  by_contra hne
  exact hf (md_collision_extract f iv m₁ m₂ hlen hne hcol)

/-- **Collisions are inevitable (pigeonhole).**
    A compression function over finite types with more than one possible block
    and a nonempty state space necessarily has a collision. This shows collision
    resistance must be a *computational* notion: collisions always exist, the
    difficulty is in *finding* them. -/
theorem compression_collision_of_card [Fintype State] [Fintype Block]
    [Nonempty State] (hB : 1 < Fintype.card Block) (f : State → Block → State) :
    HasCompressionCollision f := by
  -- By the pigeonhole principle, since there are more blocks than states, there must be at least two distinct blocks that map to the same state.
  have h_pigeonhole : ∃ s b s' b', (s, b) ≠ (s', b') ∧ f s b = f s' b' := by
    have h_card : Fintype.card (State × Block) > Fintype.card State := by
      simpa using by nlinarith [ show Fintype.card State > 0 from Fintype.card_pos ] ;
    contrapose! h_card;
    exact Fintype.card_le_of_injective ( fun p => f p.1 p.2 ) fun p q h => Classical.not_not.1 fun hpq => h_card _ _ _ _ hpq h;
  exact h_pigeonhole

end Cryptography.MerkleDamgard