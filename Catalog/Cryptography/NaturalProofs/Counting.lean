/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Cryptography.NaturalProofs.Core

/-!
# The counting side of the barrier: existence vs. constructivity

The Razborov–Rudich barrier is *not* about the **existence** of large, useful
properties — those are abundant by a trivial counting argument.  The barrier is
about the **constructivity** of such properties.  This file isolates exactly that
dichotomy.

Given a generator `G : S → Tbl m` indexed by a *small* seed set (`|S| < 2^m`),
the "small-circuit class" `genImage G` is a *proper* subset of all truth tables.
Therefore the **membership test**

  `notInImage G f := f ∉ genImage G`

is automatically *useful* against `genImage G` (it rejects every easy function)
and *large* (its density is `1 - |image G|/2^m > 0`).  By the forward direction
of the barrier (`natural_property_distinguishes`) it is even a *perfect
distinguisher* with positive advantage.

The only reason this does **not** refute pseudorandomness in practice is that
`notInImage G` is **not constructive**: evaluating it requires deciding the image
membership of `G`, i.e. searching the exponential seed space.  Razborov–Rudich
naturality demands a *polynomial-time* test, and the barrier says that demand is
exactly what a secure generator rules out.

## Main theorems

* `NaturalProofs.useful_notInImage`        — the membership test rejects every easy function.
* `NaturalProofs.accRandom_notInImage_pos` — the membership test is large when `|S| < 2^m`.
* `NaturalProofs.image_test_distinguishes` — it distinguishes `G` from uniform with
                                             strictly positive advantage.
* `NaturalProofs.exists_large_useful`      — large + useful properties exist unconditionally.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Useful + large properties are rare" is FALSE; they
are generic. The genuinely scarce resource is *constructivity*. Conjecture: for
every seed-bounded generator there is a (non-constructive) perfect distinguisher,
so the barrier's content lives entirely in the polynomial-time clause.

Experiment (Experimenter): Take the property `· ∉ image G`. Usefulness is by
definition; largeness reduces to `image G ≠ univ`, which follows from
`card (image G) ≤ card S < card (Tbl m)` via `Finset.card_image_le`. Feed it to
`natural_property_distinguishes` to upgrade largeness to positive advantage.

Analysis (Analyst): The proof never uses any structure of `G`; only the seed
count matters. This confirms the hypothesis: information-theoretically the test
exists for *every* compressing map. The barrier is therefore a statement about
*efficiency*, not *existence* — separating the two is the structural payoff.

Critique (Critic): Is `image_test_distinguishes` vacuous? No — its hypothesis
`card S < card (Tbl m)` is satisfiable (e.g. `S = Fin 1`, `m ≥ 1`), and the
conclusion is a *strict* inequality `0 < advantage`, ruling out the trivial
`0 ≤ 0`. The companion `Examples` file instantiates it concretely.

Synthesis (PI): Pairing `Core.barrier` (constructive ⇒ breaks PRG) with
`exists_large_useful` (non-constructive always exists) pinpoints the barrier:
the entire obstruction is the gap between "exists" and "polynomial-time".
-/

open Finset

namespace NaturalProofs

variable {m : ℕ} {S : Type*} [Fintype S]

/-- The "small-circuit class" realized by a generator: the finite set of truth
tables actually output by `G` over all seeds. -/
def genImage (G : S → Tbl m) : Finset (Tbl m) := Finset.image G univ

theorem mem_genImage (G : S → Tbl m) (s : S) : G s ∈ genImage G := by
  unfold genImage
  exact Finset.mem_image_of_mem G (Finset.mem_univ s)

theorem card_genImage_le (G : S → Tbl m) :
    (genImage G).card ≤ Fintype.card S := by
  unfold genImage
  calc (Finset.image G univ).card ≤ (univ : Finset S).card := Finset.card_image_le
    _ = Fintype.card S := Finset.card_univ

/-- The **membership test**: reject exactly the truth tables that `G` can output.
This is the canonical *useful* property against the class `genImage G`. -/
def notInImage (G : S → Tbl m) : Tbl m → Prop := fun f => f ∉ genImage G

instance (G : S → Tbl m) : DecidablePred (notInImage G) := by
  unfold notInImage; infer_instance

/-- The membership test rejects every easy function (every generator output). -/
theorem useful_notInImage (G : S → Tbl m) : Useful (notInImage G) (genImage G) := by
  intro f hf
  unfold notInImage
  exact fun h => h hf

/-- When the seed set is strictly smaller than the space of truth tables, the
membership test is satisfied by *some* truth table, so its density is positive:
the test is **large**. -/
theorem accRandom_notInImage_pos (G : S → Tbl m)
    (hlt : Fintype.card S < Fintype.card (Tbl m)) :
    0 < accRandom (notInImage G) := by
  have hlt2 : (genImage G).card < Fintype.card (Tbl m) :=
    lt_of_le_of_lt (card_genImage_le G) hlt
  unfold accRandom
  apply div_pos
  · rw [Nat.cast_pos, Finset.card_pos]
    obtain ⟨f, hf⟩ : ∃ f, f ∉ genImage G := by
      by_contra h
      push_neg at h
      have hsub : (Finset.univ : Finset (Tbl m)) ⊆ genImage G := fun x _ => h x
      have hle := Finset.card_le_card hsub
      rw [Finset.card_univ] at hle
      omega
    exact ⟨f, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hf⟩⟩
  · rw [Nat.cast_pos]
    exact Fintype.card_pos

/-- **Perfect distinguisher from the membership test.**
Any generator with fewer seeds than truth tables is distinguished from uniform
with strictly positive advantage by the (non-constructive) membership test. -/
theorem image_test_distinguishes (G : S → Tbl m)
    (hlt : Fintype.card S < Fintype.card (Tbl m)) :
    0 < accRandom (notInImage G) - accGen G (notInImage G) := by
  have hpos := accRandom_notInImage_pos G hlt
  have huseful : ∀ s, ¬ notInImage G (G s) := by
    intro s h
    exact h (mem_genImage G s)
  have hadv := natural_property_distinguishes (P := notInImage G) (G := G)
    (le_refl (accRandom (notInImage G))) huseful
  exact lt_of_lt_of_le hpos hadv

/-- **Existence of large, useful properties is unconditional.**
For any seed-bounded generator there is a property that is useful against its
image and has positive density. The barrier therefore concerns *constructivity*,
not existence. -/
theorem exists_large_useful (G : S → Tbl m)
    (hlt : Fintype.card S < Fintype.card (Tbl m)) :
    ∃ P : Tbl m → Prop, ∃ _ : DecidablePred P,
      Useful P (genImage G) ∧ 0 < accRandom P := by
  refine ⟨notInImage G, inferInstance, useful_notInImage G, ?_⟩
  exact accRandom_notInImage_pos G hlt

end NaturalProofs