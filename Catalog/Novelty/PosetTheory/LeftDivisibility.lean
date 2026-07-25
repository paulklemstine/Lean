/-
# Left-divisibility orders, LCIF monoids, and the upho prototype

This file develops the *order-theoretic* half of the research mission
**"Multiplicability of Upho Posets from Vertex-Transitive Graphs"**.

The mission's notion of **multiplicability** is: an upho poset `P` is multiplicable
iff it carries an **LCIF monoid** structure (Left-Cancellative, Identity-Free of
nontrivial units, locally finite) whose **left-divisibility order**
`a ≼ b ⟺ ∃ c, b = a * c` recovers the poset order of `P`.

This file isolates and proves the structural facts about left-divisibility that
make this definition meaningful:

* `LeftDvd` is always a **preorder** (reflexive + transitive) on any monoid.
* In a **group**, left-divisibility *collapses*: every element divides every
  other, so the induced order is the indiscrete one.  Consequently the order is
  a genuine partial order (antisymmetric) **iff the group is trivial**
  (`group_leftDvd_antisymm_iff_subsingleton`).  This is exactly why the
  *automorphism group* of a vertex-transitive graph cannot itself be the upho
  poset — the grading must come from elsewhere.
* The **free monoid** on an alphabet (= words = walks) is the canonical LCIF
  example: its left-divisibility order is the **prefix order**, which is a
  partial order (`freeMonoid_leftDvd_antisymm`) and is **finitary**
  (`freeMonoid_leftDvd_finitary`: every element has only finitely many
  left-divisors).  This is the prototype of a finitary upho poset.

Together with `Sabidussi.lean`, the picture is: a Cayley structure (regular
group action, the *symmetry* side) plus a free/walk monoid (the *grading*,
LCIF/order side) is what an upho poset needs to be multiplicable.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Multiplicability is fundamentally an order condition:
"left-divisibility recovers the poset".  Conjecture: groups are the *wrong*
monoid (their divisibility order is trivial) while free monoids are the *right*
prototype (prefix order = upho poset).  Bold sub-conjecture: antisymmetry of
left-divisibility in a group is equivalent to triviality.

EXPERIMENT (Experimenter).  We defined `LeftDvd` and verified reflexivity and
transitivity directly.  For groups we found `b = a * (a⁻¹ * b)` collapses the
order; for free monoids `List.IsPrefix` and `List.inits` deliver antisymmetry and
finitariness.

ANALYSIS (Analyst).  Survived: preorder laws, group collapse, the
antisymmetry↔subsingleton dichotomy, free-monoid partial order + finitariness.
Structural insight: *cancellativity + absence of nontrivial units* is precisely
what upgrades the preorder to a partial order; groups maximally violate the
second (every element is a unit), free monoids maximally satisfy it.

CRITIQUE (Critic).  We were careful that `LeftDvd` matches Mathlib's `IsPrefix`
only up to the orientation of the defining equation, and proved the bridge lemma
`freeMonoid_leftDvd_iff_isPrefix` rather than assuming it.  The group dichotomy is
an honest iff, not a one-way triviality.

SYNTHESIS (PI).  These give the LCIF/order scaffolding; see `FUTURE_DIRECTIONS.md`
for the conjectural fusion with the Sabidussi/regular-subgroup side.
-/
import Mathlib

namespace UphoMultiplicability

/-- **Left-divisibility**: `a` left-divides `b` when `b = a * c` for some `c`. -/
def LeftDvd {M : Type*} [Monoid M] (a b : M) : Prop := ∃ c, b = a * c

/-- Left-divisibility is reflexive. -/
theorem leftDvd_refl {M : Type*} [Monoid M] (a : M) : LeftDvd a a := ⟨1, by simp⟩

/-- Left-divisibility is transitive. -/
theorem leftDvd_trans {M : Type*} [Monoid M] {a b c : M}
    (h1 : LeftDvd a b) (h2 : LeftDvd b c) : LeftDvd a c := by
  obtain ⟨x, rfl⟩ := h1
  obtain ⟨y, rfl⟩ := h2
  exact ⟨x * y, by rw [mul_assoc]⟩

/-- Left-divisibility as a `Preorder` on any monoid. -/
def leftDvdPreorder (M : Type*) [Monoid M] : Preorder M where
  le := LeftDvd
  le_refl := leftDvd_refl
  le_trans _ _ _ := leftDvd_trans

/-! ## Groups: the order collapses -/

/-- In a group, every element left-divides every other element. -/
theorem group_leftDvd {G : Type*} [Group G] (a b : G) : LeftDvd a b :=
  ⟨a⁻¹ * b, by group⟩

/-- In a group, left-divisibility is a partial order (antisymmetric) **iff** the
group is trivial.  This is the precise obstruction: a nontrivial group can never
serve as the LCIF monoid of an upho poset, because its divisibility order is
indiscrete. -/
theorem group_leftDvd_antisymm_iff_subsingleton (G : Type*) [Group G] :
    (∀ a b : G, LeftDvd a b → LeftDvd b a → a = b) ↔ Subsingleton G := by
  constructor
  · intro h
    refine ⟨fun a b => ?_⟩
    exact h a b (group_leftDvd a b) (group_leftDvd b a)
  · intro hsub a b _ _
    exact Subsingleton.elim a b

/-! ## Free monoids: the upho prototype -/

/-- Left-divisibility in a free monoid is exactly the prefix relation on words. -/
theorem freeMonoid_leftDvd_iff_isPrefix {α : Type*} (a b : FreeMonoid α) :
    LeftDvd a b ↔ (a : List α) <+: (b : List α) := by
  constructor
  · rintro ⟨c, rfl⟩; exact ⟨c, rfl⟩
  · rintro ⟨t, ht⟩; exact ⟨t, ht.symm⟩

/-- Left-divisibility in a free monoid is antisymmetric: it is a genuine partial
order (the prefix order), the prototype of a multiplicable upho poset. -/
theorem freeMonoid_leftDvd_antisymm {α : Type*} (a b : FreeMonoid α)
    (h1 : LeftDvd a b) (h2 : LeftDvd b a) : a = b := by
  rw [freeMonoid_leftDvd_iff_isPrefix] at h1 h2
  have l1 := h1.length_le
  have l2 := h2.length_le
  have hlen : (a : List α).length = (b : List α).length := le_antisymm l1 l2
  exact h1.eq_of_length hlen

/-- Left-divisibility in a free monoid is **finitary**: every word has only
finitely many left-divisors (its prefixes).  This is the finiteness condition in
"finitary upho poset". -/
theorem freeMonoid_leftDvd_finitary {α : Type*} (b : FreeMonoid α) :
    {a : FreeMonoid α | LeftDvd a b}.Finite := by
  apply Set.Finite.subset (List.finite_toSet (List.inits b))
  intro a ha
  obtain ⟨c, hc⟩ := ha
  show a ∈ List.inits b
  rw [List.mem_inits]
  exact ⟨c, hc.symm⟩

/-- The left-divisibility partial order on a free monoid, packaged.  This is the
canonical LCIF/upho order. -/
def freeMonoidLeftDvdPartialOrder (α : Type*) : PartialOrder (FreeMonoid α) where
  le := LeftDvd
  le_refl := leftDvd_refl
  le_trans _ _ _ := leftDvd_trans
  le_antisymm := freeMonoid_leftDvd_antisymm

end UphoMultiplicability