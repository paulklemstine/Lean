/-
# Almost-lossless (Monte-Carlo) compression: the random-hash core

Part of the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: can random number generators help?).

This file develops, from scratch, the counting core of Shannon's random-coding
argument in a purely finitary, `Finset`-based form:

* `AlmostLossless.pigeonhole_barrier` — the exact/all-strings barrier:
  an injective encoder into `Fin M` forces `M ≥ |α|`.
* `AlmostLossless.collisionEvent` — the event `H p = H q` inside the finite
  probability space of *all* codebooks `H : ι → Fin M`.
* `AlmostLossless.card_collisionEvent_mul` — the exact marginal count
  `M * |{H | H p = H q}| = M ^ |ι|` for `p ≠ q`, i.e. the collision
  probability of a fixed pair is exactly `1/M`.
* `AlmostLossless.card_multiCollision_mul_le` — the union bound in counting
  form for an arbitrary finite family of pairs.

Everything is stated with integer arithmetic (no measure theory), so all
probability statements are exact counting identities/inequalities.
-/
import Mathlib

namespace AlmostLossless

open Finset

/-! ## 1. The pigeonhole barrier for exact decoding -/

/-- **Pigeonhole barrier.** If a code `enc : α → Fin M` admits a decoder that is
exact on *all* of `α`, then the codebook must be at least as large as the source
alphabet. This is the bound that almost-lossless coding has to circumvent. -/
theorem pigeonhole_barrier {α : Type*} [Fintype α] {M : ℕ}
    (enc : α → Fin M) (dec : Fin M → α) (h : ∀ x, dec (enc x) = x) :
    Fintype.card α ≤ M := by
  have hinj : Function.Injective enc := Function.LeftInverse.injective h
  simpa using Fintype.card_le_of_injective enc hinj

/-- Contrapositive form: below the counting bound *some* pair of source strings is
confused by every encoder, so no decoder can be exact everywhere. -/
theorem exists_collision_of_lt {α : Type*} [Fintype α] {M : ℕ}
    (enc : α → Fin M) (hM : M < Fintype.card α) :
    ∃ x y : α, x ≠ y ∧ enc x = enc y := by
  by_contra hcon
  push_neg at hcon
  have hinj : Function.Injective enc := by
    intro x y hxy
    by_contra hne
    exact absurd hxy (hcon x y hne)
  have := Fintype.card_le_of_injective enc hinj
  simp only [Fintype.card_fin] at this
  omega

/-! ## 2. The finite probability space of codebooks

The sample space is the (finite) set of *all* functions `H : ι → Fin M`;
"probability" means normalised counting measure, and we keep everything in the
integers by multiplying through by the total number `M ^ |ι|` of codebooks. -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {M : ℕ}

/-- Total number of codebooks. -/
theorem card_codebooks (ι : Type*) [Fintype ι] [DecidableEq ι] (M : ℕ) :
    Fintype.card (ι → Fin M) = M ^ Fintype.card ι := by
  simp

/-- The event that a random codebook collides on the (distinct) pair `p, q`. -/
def collisionEvent (M : ℕ) (p q : ι) : Finset (ι → Fin M) :=
  univ.filter (fun H => H p = H q)

/-- **Exact marginal count.** For `p ≠ q` the collision event has probability
exactly `1/M`: `M * |{H | H p = H q}| = M ^ |ι|`. -/
theorem card_collisionEvent_mul {p q : ι} (hpq : p ≠ q) :
    M * (collisionEvent M p q).card = M ^ Fintype.card ι := by
  classical
  -- `(H, v) ↦ update H p v` is a bijection from `collisionEvent ×ˢ Fin M` onto all codebooks.
  have hcard : ((collisionEvent M p q) ×ˢ (univ : Finset (Fin M))).card
      = (univ : Finset (ι → Fin M)).card := by
    apply Finset.card_bij (fun z _ => Function.update z.1 p z.2)
    · intro z _; exact mem_univ _
    · rintro ⟨H, v⟩ hH ⟨H', v'⟩ hH' heq
      have hHc : H p = H q := by
        simpa [collisionEvent] using (mem_product.1 hH).1
      have hHc' : H' p = H' q := by
        simpa [collisionEvent] using (mem_product.1 hH').1
      have hv : v = v' := by
        have := congrArg (fun f => f p) heq
        simpa using this
      have hoff : ∀ a, a ≠ p → H a = H' a := by
        intro a ha
        have := congrArg (fun f => f a) heq
        simpa [Function.update_apply, ha] using this
      have hHH : H = H' := by
        funext a
        rcases eq_or_ne a p with ha | ha
        · rw [ha, hHc, hHc', hoff q (Ne.symm hpq)]
        · exact hoff a ha
      exact Prod.ext hHH hv
    · intro H _
      refine ⟨(Function.update H p (H q), H p), ?_, ?_⟩
      · simp only [mem_product, collisionEvent, mem_filter, mem_univ, true_and, and_true]
        rw [Function.update_apply, Function.update_apply, if_pos rfl,
          if_neg (Ne.symm hpq)]
      · funext a
        rcases eq_or_ne a p with ha | ha
        · rw [ha]; simp
        · simp [ha]
  rw [Finset.card_product, Finset.card_univ, Fintype.card_fin, Finset.card_univ,
    card_codebooks] at hcard
  simpa [mul_comm] using hcard

/-- The event that a random codebook collides on *some* pair from a finite list of
pairs of distinct points. -/
def multiCollision (M : ℕ) (P : Finset (ι × ι)) : Finset (ι → Fin M) :=
  univ.filter (fun H => ∃ p ∈ P, H p.1 = H p.2)

/-- **Union bound, counting form.** The probability that a random codebook
collides on one of `|P|` prescribed pairs is at most `|P| / M`. -/
theorem card_multiCollision_mul_le (P : Finset (ι × ι)) (hP : ∀ p ∈ P, p.1 ≠ p.2) :
    M * (multiCollision M P).card ≤ P.card * M ^ Fintype.card ι := by
  classical
  have hsub : multiCollision M P ⊆ P.biUnion (fun p => collisionEvent M p.1 p.2) := by
    intro H hH
    simp only [multiCollision, mem_filter, mem_univ, true_and] at hH
    obtain ⟨p, hp, hHp⟩ := hH
    exact mem_biUnion.2 ⟨p, hp, by simp [collisionEvent, hHp]⟩
  have h1 : (multiCollision M P).card ≤ ∑ p ∈ P, (collisionEvent M p.1 p.2).card :=
    le_trans (Finset.card_le_card hsub) Finset.card_biUnion_le
  calc M * (multiCollision M P).card
      ≤ M * ∑ p ∈ P, (collisionEvent M p.1 p.2).card := Nat.mul_le_mul_left _ h1
    _ = ∑ p ∈ P, M * (collisionEvent M p.1 p.2).card := by rw [Finset.mul_sum]
    _ = ∑ _p ∈ P, M ^ Fintype.card ι :=
        Finset.sum_congr rfl (fun p hp => card_collisionEvent_mul (hP p hp))
    _ = P.card * M ^ Fintype.card ι := by rw [Finset.sum_const, smul_eq_mul]

end AlmostLossless