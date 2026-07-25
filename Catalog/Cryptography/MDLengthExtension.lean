/-
  Merkle–Damgård Length Extension: the Indifferentiability Obstruction
  ====================================================================

  An idealized hash function — a *random oracle* — assigns independent outputs to
  distinct inputs; in particular distinct messages collide only by accident, and
  knowing `RO(m)` reveals nothing about `RO(m ++ s)`.  Plain Merkle–Damgård
  fails this badly: `mdHash f iv (m ++ s)` is *determined* by `mdHash f iv m`
  and `s`, with no further knowledge of `m`.  This is the **length-extension**
  property, and it is exactly why plain MD is *not* indifferentiable from a
  random oracle (Coron–Dodis–Malinaud–Puniya 2005), forcing the use of a
  finalization (chopping / HMAC / prefix-free encoding) in practice — the design
  philosophy behind treating SHA-256's compression function (not the bare MD
  iteration) as the random-oracle primitive.

  We prove:
  * `mdHash_length_extension` — the structural length-extension identity;
  * `md_collision_extends` / `md_collision_family` — one MD collision spawns an
    infinite suffix-closed family of collisions;
  * `injectiveOracle_no_collision` — an ideal (injective) oracle has no such
    family, giving the distinguisher;
  * `finalize_collision_iff` — an *injective* finalization exactly preserves the
    collision structure (so finalization never weakens collision resistance).

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): The kernel relation `m₁ ∼ m₂ ↔ mdHash m₁ = mdHash m₂`
  is a right congruence for concatenation, a property no injective oracle shares;
  hence a single collision produces an entire suffix-closed family, the explicit
  length-extension distinguisher.

  EXPERIMENT (Experimenter): `md_collision_extends` is a two-step rewrite by
  `mdHash_append`. `md_collision_family` packages it with the inequality
  `m₁ ++ s ≠ m₂ ++ s`, which is right-cancellation of `++`. `finalize_collision_iff`
  is `Function.Injective` unfolded in both directions.

  ANALYSIS (Analyst): The obstruction is purely structural — it needs no
  probability and no finiteness. It is the *necessity* half of indifferentiability:
  any construction with a non-trivial right-congruence kernel is distinguishable
  from a random oracle. Finalization with an injective map keeps the kernel
  unchanged, so it cannot *create* collisions, but (crucially) also cannot remove
  the length-extension structure on its own — matching the known fact that a
  mere output chop is insufficient and prefix-free domain separation is required.

  CRITIQUE (Critic): Non-vacuity — `md_collision_family` is only interesting when
  an MD collision exists; `compression_collision_of_card` (imported) guarantees
  collisions are inevitable on finite state/block types, so the family theorem is
  not vacuous. The `finalize_collision_iff` lemma is a genuine ↔, not a one-way
  triviality, and uses injectivity essentially in the forward direction.

  SYNTHESIS (PI): length-extension identity ⇒ suffix-closed collision family ⇒
  distinguisher from an injective oracle, with injective finalization shown to
  preserve (not repair) the structure — a self-contained indifferentiability
  obstruction package complementing the MD collision-resistance results.
-/
import Mathlib
import Cryptography.MerkleDamgard

namespace Cryptography.MDLengthExtension

open Cryptography.MerkleDamgard

variable {State Block Digest : Type*}

/-- **Length-extension identity.** The MD hash of an extended message is fully
    determined by the chaining value after the prefix and by the extension. -/
theorem mdHash_length_extension (f : State → Block → State) (iv : State)
    (m s : List Block) :
    mdHash f iv (m ++ s) = mdHash f (mdHash f iv m) s :=
  mdHash_append f iv m s

/-- One MD collision extends along every common suffix. -/
theorem md_collision_extends (f : State → Block → State) (iv : State)
    (m₁ m₂ : List Block)
    (hcol : mdHash f iv m₁ = mdHash f iv m₂) (s : List Block) :
    mdHash f iv (m₁ ++ s) = mdHash f iv (m₂ ++ s) := by
  rw [mdHash_append, mdHash_append, hcol]

/-- **Length-extension distinguisher.** A single collision of distinct messages
    spawns an infinite, suffix-closed family of distinct colliding messages —
    structure that a random oracle does not have. -/
theorem md_collision_family (f : State → Block → State) (iv : State)
    (m₁ m₂ : List Block) (hne : m₁ ≠ m₂)
    (hcol : mdHash f iv m₁ = mdHash f iv m₂) :
    ∀ s : List Block,
      m₁ ++ s ≠ m₂ ++ s ∧ mdHash f iv (m₁ ++ s) = mdHash f iv (m₂ ++ s) := by
  intro s
  exact ⟨fun h => hne (List.append_cancel_right h),
    md_collision_extends f iv m₁ m₂ hcol s⟩

/-- An ideal (injective) random oracle has no collisions on distinct messages —
    the contrast that makes the MD family above a genuine distinguisher. -/
theorem injectiveOracle_no_collision (H : List Block → State)
    (hH : Function.Injective H) (m₁ m₂ : List Block) (hne : m₁ ≠ m₂) :
    H m₁ ≠ H m₂ :=
  fun h => hne (hH h)

/-- **Finalization preserves collision structure.** Post-composing the MD hash
    with an *injective* finalization `g` neither creates nor removes collisions:
    a finalized collision is exactly an MD collision. Hence an injective
    finalization cannot weaken collision resistance. -/
theorem finalize_collision_iff (f : State → Block → State) (iv : State)
    (g : State → Digest) (hg : Function.Injective g) (m₁ m₂ : List Block) :
    g (mdHash f iv m₁) = g (mdHash f iv m₂) ↔
      mdHash f iv m₁ = mdHash f iv m₂ :=
  ⟨fun h => hg h, fun h => by rw [h]⟩

end Cryptography.MDLengthExtension