import Mathlib
import Bridges.KnasterTarskiBridge
/-! # The Subobject Lattice of a Topos: Double Negation as a Nucleus

This file is the **logic ↔ topology** facet of the category-theory bridge.

## The corrected grand claim

The mission statement asks to "prove that every Grothendieck topos is a bounded
lattice with a universal property".  Taken literally this is **false**: a
Grothendieck topos is a *category* (e.g. `Set`), not a lattice, and it is rarely
a poset at all.  The true and load-bearing statement is:

> In any (Grothendieck) topos, the **subobjects of a fixed object** form a
> complete Heyting algebra (equivalently a *frame*): a bounded, distributive
> lattice whose meet `⊓` has a right adjoint `⇨` (Heyting implication) — and that
> adjunction *is* the universal property.

We model the subobject lattice abstractly by `Order.Frame α` (a complete Heyting
algebra), the algebraic skeleton common to:
* **topology**: `TopologicalSpace.Opens X`, the frame of opens — the subobject
  lattice of the terminal sheaf on `X` (instantiated explicitly at the end);
* **logic**: the Lindenbaum–Tarski algebra of intuitionistic propositional logic;
* the subobject classifier `Ω` of any topos, internalized.

## What we prove

* `himp_isGreatest` — the **universal property**: `a ⇨ c` is the *greatest* `x`
  with `a ⊓ x ≤ c`.  Meet is left adjoint to implication.
* `dneg` (double negation `a ↦ aᶜᶜ`) is a **nucleus / closure operator**:
  extensive (`le_dneg`), monotone (`dneg_monotone`), idempotent (`dneg_idem`),
  and meet-preserving (`dneg_inf`).  This is the *double-negation topology* whose
  sheaves are Boolean — the categorical heart of the double-negation translation.
* `dneg_bot`, `dneg_top` — the bounds are regular, so the lattice of regular
  elements is itself bounded.
* `IsRegular` elements are closed under `⊓` (`isRegular_inf`).
* **Catalog bridge**: using `KnasterTarskiBridge` from the attached catalog we
  identify the least and greatest fixed points of the nucleus: the least fixed
  point is `⊥` (`lfp_dneg_eq_bot`) and the greatest is `⊤` (`gfp_dneg_eq_top`),
  realizing `dneg` inside the Knaster–Tarski fixed-point machinery.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): "Every Grothendieck topos is a bounded lattice with a
  universal property."  Bold but, as literally stated, suspicious — a topos is a
  category.  Refined conjecture: the subobject lattice is a complete Heyting
  algebra and double negation is a closure operator (a Lawvere–Tierney topology).
EXPERIMENT (Experimenter): Disproof of the literal claim is immediate (`Set` is
  not a poset).  Proved the refined claim over `Order.Frame`: the himp universal
  property, and that `aᶜᶜ` is extensive/monotone/idempotent/meet-preserving.
  Linked to the catalog Knaster–Tarski file to pin the nucleus' fixed points.
ANALYSIS (Analyst): The failure of the literal statement is a *category error*
  ("topos" vs. "its subobject lattice"); the surviving content is sharper and
  genuinely cross-domain (`Opens X` is an instance).  Idempotence `aᶜᶜᶜᶜ = aᶜᶜ`
  reduces to the triple-negation law `aᶜᶜᶜ = aᶜ`, the one nontrivial Heyting
  identity here.  Meet-preservation `(a ⊓ b)ᶜᶜ = aᶜᶜ ⊓ bᶜᶜ` is what makes the
  regular elements a sublattice (in fact a Boolean algebra).
CRITIQUE (Critic): Care needed: `dneg` is NOT join-preserving and `aᶜᶜ = a`
  fails intuitionistically, so we never assume Booleanness.  The fixed-point
  identifications must use `le_dneg`/`dneg_bot`, not classical `compl_compl`.
SYNTHESIS (PI): The bridge is "intuitionistic logic = internal language of a
  topos = frame structure on subobjects", with `Opens X` the topological witness.
-/

open CategoryTheory KnasterTarskiBridge

namespace ToposDoubleNegationLattice

universe u

variable {α : Type u} [Order.Frame α]

/-! ## Section 1 — The universal property of the subobject lattice -/

/-- **Universal property of the topos subobject lattice.** Heyting implication
`a ⇨ c` is the *greatest* element `x` whose meet with `a` lands below `c`.
Equivalently, `(a ⊓ ·) ⊣ (a ⇨ ·)`: conjunction is left adjoint to implication.
This adjunction is the categorical-semantics content of "bounded lattice with a
universal property". -/
theorem himp_isGreatest (a c : α) : IsGreatest {x | a ⊓ x ≤ c} (a ⇨ c) := by
  refine ⟨?_, ?_⟩
  · show a ⊓ (a ⇨ c) ≤ c
    exact inf_himp_le
  · intro x hx
    rw [le_himp_iff, inf_comm]
    exact hx

/-! ## Section 2 — Double negation is a nucleus (closure operator) -/

/-- The double-negation operator `a ↦ aᶜᶜ` on the subobject lattice. -/
def dneg (a : α) : α := aᶜᶜ

/-- **Extensive.** Every element is below its double negation: `a ≤ aᶜᶜ`. -/
theorem le_dneg (a : α) : a ≤ dneg a := le_compl_compl

/-- **Monotone.** Double negation is order preserving (two applications of the
order-reversing complement). -/
theorem dneg_monotone : Monotone (dneg : α → α) := by
  intro a b h
  exact compl_le_compl (compl_le_compl h)

/-- **Idempotent.** `aᶜᶜᶜᶜ = aᶜᶜ`, via the triple-negation law `aᶜᶜᶜ = aᶜ`. -/
theorem dneg_idem (a : α) : dneg (dneg a) = dneg a := by
  show aᶜᶜᶜᶜ = aᶜᶜ
  rw [compl_compl_compl]

/-- **Meet-preserving.** `(a ⊓ b)ᶜᶜ = aᶜᶜ ⊓ bᶜᶜ`; this is what makes the regular
elements closed under `⊓`. -/
theorem dneg_inf (a b : α) : dneg (a ⊓ b) = dneg a ⊓ dneg b :=
  compl_compl_inf_distrib a b

/-- The bottom subobject is regular: `⊥ᶜᶜ = ⊥`. -/
@[simp] theorem dneg_bot : dneg (⊥ : α) = ⊥ := by
  show (⊥ : α)ᶜᶜ = ⊥
  rw [compl_bot, compl_top]

/-- The top subobject (the whole object) is regular: `⊤ᶜᶜ = ⊤`. -/
@[simp] theorem dneg_top : dneg (⊤ : α) = ⊤ := by
  show (⊤ : α)ᶜᶜ = ⊤
  rw [compl_top, compl_bot]

/-! ## Section 3 — Regular elements form a bounded sub-meet-lattice -/

/-- A subobject is **regular** (a `¬¬`-sheaf / `¬¬`-stable element) when it is a
fixed point of double negation. -/
def IsRegular (a : α) : Prop := dneg a = a

theorem isRegular_bot : IsRegular (⊥ : α) := dneg_bot
theorem isRegular_top : IsRegular (⊤ : α) := dneg_top

/-- Regular elements are closed under meet — the regular subobjects form a
bounded sub-meet-lattice (the objects of the double-negation sheaf subtopos). -/
theorem isRegular_inf {a b : α} (ha : IsRegular a) (hb : IsRegular b) :
    IsRegular (a ⊓ b) := by
  unfold IsRegular at *
  rw [dneg_inf, ha, hb]

/-- An element is regular iff it is "stable": `aᶜᶜ ≤ a` (the reverse inequality is
automatic by `le_dneg`). -/
theorem isRegular_iff (a : α) : IsRegular a ↔ dneg a ≤ a := by
  constructor
  · intro h; rw [h]
  · intro h; exact le_antisymm h (le_dneg a)

/-! ## Section 4 — Catalog bridge: the nucleus inside Knaster–Tarski

We feed the monotone nucleus `dneg` into the attached
`Catalog/Bridges/KnasterTarskiBridge.lean` machinery and identify its extremal
fixed points. -/

/-- The Knaster–Tarski least fixed point of the double-negation nucleus is `⊥`.
Indeed `⊥` is a pre-fixed point (`dneg ⊥ = ⊥ ≤ ⊥`), so it is the infimum. -/
theorem lfp_dneg_eq_bot : sInf (preFixed (dneg : α → α)) = ⊥ := by
  apply le_antisymm
  · apply sInf_le
    show dneg (⊥ : α) ≤ ⊥
    rw [dneg_bot]
  · exact bot_le

/-- The Knaster–Tarski greatest fixed point of the double-negation nucleus is `⊤`.
Every element is a post-fixed point (`a ≤ dneg a`), so the supremum is `⊤`. -/
theorem gfp_dneg_eq_top : sSup (postFixed (dneg : α → α)) = ⊤ := by
  apply le_antisymm
  · exact le_top
  · apply le_sSup
    exact le_dneg ⊤

/-- Sanity bridge to the catalog theorem: `dneg`'s `sInf`-of-pre-fixed-points is
genuinely a fixed point, as Knaster–Tarski guarantees for the monotone nucleus
(and we have just computed it to be `⊥`). -/
theorem dneg_knaster_tarski :
    dneg (sInf (preFixed (dneg : α → α))) = sInf (preFixed (dneg : α → α)) :=
  knaster_tarski dneg dneg_monotone

/-! ## Section 5 — The topological witness: the frame of opens

Everything above instantiates at `TopologicalSpace.Opens X`, the subobject
lattice of the terminal object in the sheaf topos `Sh(X)`. This is the concrete
**topology** end of the bridge. -/

section Opens
variable {X : Type u} [TopologicalSpace X]

/-- The frame of opens is a bounded lattice with the Heyting universal property:
`U ⇨ W` is the largest open `V` with `U ⊓ V ≤ W` (the *interior* of
`Uᶜ ∪ W`). -/
theorem opens_himp_isGreatest (U W : TopologicalSpace.Opens X) :
    IsGreatest {V | U ⊓ V ≤ W} (U ⇨ W) :=
  himp_isGreatest U W

/-- Concrete double-negation regularity in topology: the empty and full open sets
are `¬¬`-regular elements of the frame of opens. -/
theorem opens_isRegular_bot : IsRegular (⊥ : TopologicalSpace.Opens X) := isRegular_bot
theorem opens_isRegular_top : IsRegular (⊤ : TopologicalSpace.Opens X) := isRegular_top

/-- The double-negation nucleus on opens preserves intersections — the regular
opens form a sub-meet-lattice (these are exactly the *regular open sets*). -/
theorem opens_dneg_inf (U V : TopologicalSpace.Opens X) :
    dneg (U ⊓ V) = dneg U ⊓ dneg V :=
  dneg_inf U V

end Opens

end ToposDoubleNegationLattice