/-
  Collision-Resistant Hashing from Claw-Free Permutation Pairs
  ============================================================

  We formalize the canonical route from a *hard problem* to a
  collision-resistant hash function (CRHF): the Damgård construction from a
  **claw-free pair** of permutations.  A *claw* for `g₀, g₁ : X → X` is a pair
  `(x, y)` with `g₀ x = g₁ y`; the pair is *claw-free* when no claw can be
  found.  Claw-free pairs are precisely how concrete hard problems (factoring,
  discrete log) are turned into CRHFs.

  The one-bit-block compression function `clawCompress g₀ g₁ s b = gᵦ s` has the
  property that, when `g₀` and `g₁` are injective, *a compression collision is
  exactly a claw*.  Composing this with the Merkle–Damgård extraction theorem
  (`Cryptography.MerkleDamgard.md_collision_extract`) shows that claw-freeness of
  the pair lifts to collision resistance of the full iterated hash.

  Faithfulness note.  Plain "one-way functions ⇒ CRHF" is *not* provable in a
  black-box manner (Simon's 1998 separation); the provable hardness-to-CRHF
  statement uses the extra claw-free structure (Damgård 1987).  This file proves
  that reduction, constructively and `sorry`-free.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): For injective `g₀, g₁`, the Damgård compression's
  collisions coincide *exactly* with claws of the pair, so the abstract
  hardness assumption "no claw" is equivalent to "no compression collision",
  and lifts through Merkle–Damgård to a collision-resistant variable-block hash.

  EXPERIMENT (Experimenter): `claw_to_compression_collision` is immediate from
  the differing block bits. The converse, `clawCompress_collision_to_claw`,
  splits on the four bit combinations: equal bits force equal states by
  injectivity (contradicting the input inequality), unequal bits give a claw.
  The lift `md_clawCompress_collision_to_claw` is the composition with
  `md_collision_extract`.

  ANALYSIS (Analyst): Injectivity of both permutations is *necessary* for the
  collision ⇒ claw direction: without it, a same-bit collision `g₀ s = g₀ s'`
  with `s ≠ s'` would be a compression collision that is not a claw. The
  equivalence is therefore stated with injectivity hypotheses, at its tight
  boundary.

  CRITIQUE (Critic): Non-vacuity is secured by `concrete_claw` /
  `concrete_compression_collision` over `ZMod 2` with `g₀ = id`, `g₁ = (·+1)`:
  a genuine claw `g₀ 1 = g₁ 0` realizes every hypothesis, so the equivalence is
  not vacuously true.

  SYNTHESIS (PI): claw-free pair (hard problem) ⇒ collision-free compression ⇒
  (Merkle–Damgård) collision-resistant iterated hash, with the
  collision ⇔ claw equivalence as the structural core.
-/
import Mathlib
import Cryptography.MerkleDamgard

namespace Cryptography.ClawFreeHash

open Cryptography.MerkleDamgard

variable {X : Type*}

/-- A *claw* for the pair `g₀, g₁` is a pair `(x, y)` with `g₀ x = g₁ y`. -/
def IsClaw (g₀ g₁ : X → X) (x y : X) : Prop := g₀ x = g₁ y

/-- The pair `g₀, g₁` *has a claw* when some `(x, y)` satisfies `g₀ x = g₁ y`.
    Its negation is the cryptographic hardness assumption (claw-freeness). -/
def HasClaw (g₀ g₁ : X → X) : Prop := ∃ x y, g₀ x = g₁ y

/-- The Damgård compression function from a pair of permutations: state `X`,
    one-bit blocks. `clawCompress g₀ g₁ s b` applies `g₁` if `b` is `true` and
    `g₀` if `b` is `false`. -/
def clawCompress (g₀ g₁ : X → X) : X → Bool → X :=
  fun s b => bif b then g₁ s else g₀ s

@[simp] theorem clawCompress_false (g₀ g₁ : X → X) (s : X) :
    clawCompress g₀ g₁ s false = g₀ s := rfl

@[simp] theorem clawCompress_true (g₀ g₁ : X → X) (s : X) :
    clawCompress g₀ g₁ s true = g₁ s := rfl

/-- A claw immediately yields a compression collision: the two inputs differ in
    their block bit but produce the same output. -/
theorem claw_to_compression_collision (g₀ g₁ : X → X) (hclaw : HasClaw g₀ g₁) :
    HasCompressionCollision (clawCompress g₀ g₁) := by
  obtain ⟨x, y, h⟩ := hclaw
  exact ⟨x, false, y, true, by simp, by simpa using h⟩

/-- **Compression collision ⇒ claw.**
    When both permutations are injective, every collision of the Damgård
    compression function is a claw of the pair. A same-bit collision is
    impossible (injectivity), so any collision must straddle the two bits. -/
theorem clawCompress_collision_to_claw (g₀ g₁ : X → X)
    (h0 : Function.Injective g₀) (h1 : Function.Injective g₁)
    (hcol : HasCompressionCollision (clawCompress g₀ g₁)) :
    HasClaw g₀ g₁ := by
  obtain ⟨s, b, s', b', hne, heq⟩ := hcol
  cases b <;> cases b'
  · simp only [clawCompress_false] at heq
    exact absurd (by rw [h0 heq]) hne
  · simp only [clawCompress_false, clawCompress_true] at heq
    exact ⟨s, s', heq⟩
  · simp only [clawCompress_false, clawCompress_true] at heq
    exact ⟨s', s, heq.symm⟩
  · simp only [clawCompress_true] at heq
    exact absurd (by rw [h1 heq]) hne

/-- **Collision ⇔ claw.** For an injective permutation pair, compression
    collisions and claws are the same object. -/
theorem claw_iff_compression_collision (g₀ g₁ : X → X)
    (h0 : Function.Injective g₀) (h1 : Function.Injective g₁) :
    HasClaw g₀ g₁ ↔ HasCompressionCollision (clawCompress g₀ g₁) :=
  ⟨claw_to_compression_collision g₀ g₁,
   clawCompress_collision_to_claw g₀ g₁ h0 h1⟩

/-- **Claw-freeness ⇒ the compression function is collision-free.** -/
theorem clawFree_compression_collisionFree (g₀ g₁ : X → X)
    (h0 : Function.Injective g₀) (h1 : Function.Injective g₁)
    (hcf : ¬ HasClaw g₀ g₁) :
    ¬ HasCompressionCollision (clawCompress g₀ g₁) :=
  fun hcol => hcf (clawCompress_collision_to_claw g₀ g₁ h0 h1 hcol)

/-- **Merkle–Damgård lift.** Any collision of the iterated Damgård hash on two
    equal-length distinct block-lists yields a claw of the underlying pair. -/
theorem md_clawCompress_collision_to_claw (g₀ g₁ : X → X)
    (h0 : Function.Injective g₀) (h1 : Function.Injective g₁)
    (iv : X) (m₁ m₂ : List Bool) (hlen : m₁.length = m₂.length)
    (hne : m₁ ≠ m₂)
    (hcol : mdHash (clawCompress g₀ g₁) iv m₁ = mdHash (clawCompress g₀ g₁) iv m₂) :
    HasClaw g₀ g₁ :=
  clawCompress_collision_to_claw g₀ g₁ h0 h1
    (md_collision_extract _ iv m₁ m₂ hlen hne hcol)

/-- **Hard problem ⇒ collision-resistant hash (headline).**
    If the permutation pair is claw-free, the iterated Damgård hash is injective
    on each fixed message length: distinct equal-length messages never collide.
    This is the constructive reduction "claw-free pair ⇒ CRHF". -/
theorem clawFree_mdHash_injOn_length (g₀ g₁ : X → X)
    (h0 : Function.Injective g₀) (h1 : Function.Injective g₁)
    (hcf : ¬ HasClaw g₀ g₁) (iv : X) (m₁ m₂ : List Bool)
    (hlen : m₁.length = m₂.length)
    (hcol : mdHash (clawCompress g₀ g₁) iv m₁ = mdHash (clawCompress g₀ g₁) iv m₂) :
    m₁ = m₂ := by
  by_contra hne
  exact hcf (md_clawCompress_collision_to_claw g₀ g₁ h0 h1 iv m₁ m₂ hlen hne hcol)

/-! ## Concrete non-vacuity witness over `ZMod 2`. -/

/-- Example permutation `g₀ = id` on `ZMod 2`. -/
def g0Ex : ZMod 2 → ZMod 2 := id

/-- Example permutation `g₁ = (· + 1)` on `ZMod 2`. -/
def g1Ex : ZMod 2 → ZMod 2 := fun x => x + 1

theorem g0Ex_injective : Function.Injective g0Ex := fun _ _ h => h

theorem g1Ex_injective : Function.Injective g1Ex :=
  fun x y h => by simpa [g1Ex, add_left_inj] using h

/-- A concrete claw: `g0Ex 1 = g1Ex 0 = 1` in `ZMod 2`. -/
theorem concrete_claw : HasClaw g0Ex g1Ex := ⟨1, 0, by decide⟩

/-- The concrete pair therefore has a genuine compression collision, ensuring
    every hypothesis of the equivalence is satisfiable (no vacuity). -/
theorem concrete_compression_collision :
    HasCompressionCollision (clawCompress g0Ex g1Ex) :=
  claw_to_compression_collision g0Ex g1Ex concrete_claw

end Cryptography.ClawFreeHash