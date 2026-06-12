/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.HardnessHierarchy

/-!
# One-Way Functions: Existence and Hierarchy

This module isolates the *conceptual core* of one-way function (OWF) theory: the
reason OWFs are a **computational** rather than an **information-theoretic** notion.

We formalize, over arbitrary (possibly infinite, only nonempty) domains, the fact
that every function admits a **weak inverse** — a map that recovers, for every
input `x`, *some* preimage of `f x`. Consequently no function can be one-way in the
information-theoretic sense: an unbounded adversary always inverts perfectly. This
makes precise the folklore slogan "one-wayness lives entirely in complexity", which
is the foundation of the whole hardness hierarchy `OWF → PRG → PRF → ENC`.

We then quantify the *combinatorial optimality* of inversion: over a finite domain,
the maximal number of exactly-recovered inputs of any inverter equals the image
size `|Im f|`, and this optimum is attained by the canonical inverter `Function.invFun f`.

Finally we expose the **order-theoretic skeleton** of the hardness hierarchy
(`CryptoLevel` from `Cryptography.HardnessHierarchy`): the rank map is injective, the
implication relation is a total order, OWF is its weakest and ENC its strongest level.

## Catalog synthesis

* Extends `Cryptography.HardnessHierarchy` (`CryptoLevel`, `LossyFunction`, `fiber`,
  `hierarchy_strict`): we add the *existence* layer beneath the hierarchy and turn the
  discrete `rank` chain into a genuine total order with extremal elements.
* Complements `Cryptography.OneWay` (`ProofSearch`): that file models OWF *hardness*
  (verification + exponential sparsity); here we explain why such hardness is
  *necessary* — information theory alone never yields one-wayness.

## Main results

* `exists_weakInverse`        — every function over a nonempty domain has a weak inverse.
* `not_infoTheoreticOneWay`   — no function is information-theoretically one-way.
* `weakInverse_inverts_all`   — a weak inverter succeeds on every one of the `|α|` inputs.
* `exact_inversions_le_image` — any inverter exactly recovers ≤ `|Im f|` inputs.
* `invFun_exact_inversions`   — `Function.invFun f` attains the optimum `|Im f|`.
* `level_total`/`owf_weakest`/`enc_strongest` — the hierarchy is a total order with extrema.
-/

open Function Finset

namespace OneWayHierarchy

/-! ## Section 1: Weak inverses and information-theoretic impossibility -/

variable {α β : Type*}

-- !-- Lab Notebook -- !--
-- Hypothesis: "One-wayness" of `f` should be impossible without a complexity bound,
--   because an adversary with no resource constraint can simply tabulate a preimage map.
-- Result: Confirmed. `Function.invFun f` is a weak inverse for ANY `f` over a nonempty
--   domain (Section 1), so the information-theoretic security game is always lost.
-- Insight: The only obstacle to inversion is *computation*, never *information*; this is
--   exactly why the hierarchy assumes (rather than proves) OWF existence.
-- Failure analysis: An early attempt phrased weak inversion as `g (f x) = x` (a genuine
--   left inverse); that is false for non-injective `f`. The correct invariant is
--   `f (g (f x)) = f x` — recover *a* preimage, not *the* input.

/-- `g` is a **weak inverse** of `f` when, for every input `x`, `g` maps `f x` back to
some genuine preimage of `f x` (equivalently `g (f x)` lies in the fiber of `f x`). -/
def WeakInverse (f : α → β) (g : β → α) : Prop := ∀ x, f (g (f x)) = f x

-- !-- comment: `Function.invFun_eq` applied to the witness `⟨x, rfl⟩` gives precisely
--   `f (invFun f (f x)) = f x`, so the canonical inverse is always weak. -- !--
theorem invFun_weakInverse [Nonempty α] (f : α → β) : WeakInverse f (invFun f) :=
  fun x => invFun_eq ⟨x, rfl⟩

-- !-- comment: Existence is witnessed by `Function.invFun f`. -- !--
theorem exists_weakInverse [Nonempty α] (f : α → β) : ∃ g : β → α, WeakInverse f g :=
  ⟨invFun f, invFun_weakInverse f⟩

/-- A function is **information-theoretically one-way** if *no* inverter recovers a
preimage of `f x` for every `x`; i.e. every candidate inverter fails somewhere. -/
def InfoTheoreticOneWay (f : α → β) : Prop := ∀ g : β → α, ∃ x, f (g (f x)) ≠ f x

-- !-- comment: Immediate from `exists_weakInverse`: the weak inverse refutes the
--   universally-failing requirement. This is the central conceptual theorem. -- !--
theorem not_infoTheoreticOneWay [Nonempty α] (f : α → β) : ¬ InfoTheoreticOneWay f := by
  rintro hOW
  obtain ⟨g, hg⟩ := exists_weakInverse f
  obtain ⟨x, hx⟩ := hOW g
  exact hx (hg x)

/-! ## Section 2: Quantitative inversion success over finite domains -/

variable [Fintype α] [DecidableEq α] [DecidableEq β]

-- !-- comment: A weak inverter succeeds on *every* input, so the set of successes is
--   all of `univ`, of cardinality `|α|` — perfect information-theoretic advantage. -- !--
omit [DecidableEq α] in
theorem weakInverse_inverts_all (f : α → β) (g : β → α) (h : WeakInverse f g) :
    (Finset.univ.filter (fun x => f (g (f x)) = f x)).card = Fintype.card α := by
  rw [Finset.filter_true_of_mem (fun x _ => h x), Finset.card_univ]

/-! ## Section 3: Combinatorial optimality of exact inversion -/

-- !-- Lab Notebook -- !--
-- Hypothesis: While *weak* inversion is always perfect, *exact* inversion
--   (`g (f x) = x`) is genuinely limited by collisions: an inverter can pin down at
--   most one input per fiber, hence at most `|Im f|` inputs total.
-- Result: Proven sharp. `exact_inversions_le_image` gives the upper bound for ALL `g`;
--   `invFun_exact_inversions` shows `Function.invFun f` attains it.
-- Insight: `|Im f|` is the information-theoretic capacity of *exact* recovery — the
--   precise bridge between collision structure (Section 6 of HardnessHierarchy) and
--   inversion. A lossy function with small image is intrinsically hard to invert exactly.
-- Failure analysis: The achievability direction needs the bijection
--   `Im f ≃ {fixed points of invFun∘f}`, `y ↦ invFun f y`; a naive `card_image` of `f`
--   over the fixed set only gives `≤`, not the reverse, so an explicit bijection is used.

/-- The set of inputs that `g` recovers **exactly**: `g (f x) = x`. -/
def exactInversions (f : α → β) (g : β → α) : Finset α :=
  Finset.univ.filter (fun x => g (f x) = x)

-- !-- comment: On the exact-inversion set `f` is injective (`x = g(f x)`), so `f`
--   embeds it into `Im f`; hence its size is `≤ |Im f|`. -- !--
theorem exact_inversions_le_image (f : α → β) (g : β → α) :
    (exactInversions f g).card ≤ (Finset.univ.image f).card := by
  refine Finset.card_le_card_of_injOn f ?_ ?_
  · intro x hx
    exact Finset.mem_image_of_mem f (Finset.mem_univ x)
  · intro x hx y hy hxy
    simp only [exactInversions, Finset.mem_coe, Finset.mem_filter] at hx hy
    calc x = g (f x) := hx.2.symm
      _ = g (f y) := by rw [hxy]
      _ = y := hy.2

-- !-- comment: The optimum `|Im f|` is attained by `invFun f`: the map `y ↦ invFun f y`
--   is a bijection from `Im f` onto the fixed-point set `{x | invFun f (f x) = x}`,
--   because `f (invFun f y) = y` for `y ∈ Im f`. -- !--
theorem invFun_exact_inversions [Nonempty α] (f : α → β) :
    (exactInversions f (invFun f)).card = (Finset.univ.image f).card := by
  have hset : exactInversions f (invFun f) = (Finset.univ.image f).image (invFun f) := by
    ext x
    simp only [exactInversions, Finset.mem_filter, Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · intro hx
      exact ⟨f x, ⟨x, rfl⟩, hx⟩
    · rintro ⟨y, ⟨a, rfl⟩, rfl⟩
      have : f (invFun f (f a)) = f a := invFun_eq ⟨a, rfl⟩
      rw [this]
  rw [hset, Finset.card_image_of_injOn]
  intro y hy z hz hyz
  simp only [Finset.mem_coe, Finset.mem_image, Finset.mem_univ, true_and] at hy hz
  obtain ⟨a, rfl⟩ := hy
  obtain ⟨b, rfl⟩ := hz
  have h1 : f (invFun f (f a)) = f a := invFun_eq ⟨a, rfl⟩
  have h2 : f (invFun f (f b)) = f b := invFun_eq ⟨b, rfl⟩
  rw [← h1, ← h2, hyz]

/-! ## Section 4: Order-theoretic skeleton of the hardness hierarchy -/

-- !-- Lab Notebook -- !--
-- Hypothesis: `CryptoLevel.rank` should turn the four-level hierarchy into a genuine
--   *total order* (a chain), with OWF the weakest and ENC the strongest primitive.
-- Result: Confirmed. `rank` is injective, the implication relation is total, and OWF/ENC
--   are the extremal elements. This upgrades `hierarchy_strict` (antisymmetry) to a chain.
-- Insight: The cryptographic hierarchy is order-isomorphic to `Fin 4`; "stronger
--   assumption" is literally "higher rank", a clean bridge from cryptography to order theory.
-- Failure analysis: The library `LE` instance reverses `rank` (`a ≤ b ↔ b.rank ≤ a.rank`),
--   so "weakest = top" in that order; we state extrema directly to avoid confusion.

-- !-- comment: Distinct levels have distinct ranks; case-split on the four constructors. -- !--
theorem rank_injective : Function.Injective CryptoLevel.rank := by
  intro a b h
  cases a <;> cases b <;> simp_all [CryptoLevel.rank]

-- !-- comment: `A ≤ OWF` unfolds to `OWF.rank ≤ A.rank`, i.e. `0 ≤ A.rank`. -- !--
theorem owf_weakest (A : CryptoLevel) : A ≤ CryptoLevel.OWF :=
  Nat.zero_le _

-- !-- comment: `ENC ≤ A` unfolds to `A.rank ≤ ENC.rank = 3`, true for all four ranks. -- !--
theorem enc_strongest (A : CryptoLevel) : CryptoLevel.ENC ≤ A := by
  cases A <;> decide

-- !-- comment: Totality of the implication relation is totality of `≤` on ranks. -- !--
theorem level_total (A B : CryptoLevel) : A ≤ B ∨ B ≤ A :=
  le_total B.rank A.rank

end OneWayHierarchy