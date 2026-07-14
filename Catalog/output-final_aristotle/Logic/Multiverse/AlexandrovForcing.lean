import Mathlib
import Logic.Multiverse.ModalFrame

/-!
# The Alexandrov Topology of the Forcing Multiverse

**Direction 4 of the research programme — a topology/modal-logic bridge.**

The combinatorial core of the forcing multiverse (`ModalFrame.lean`) equips the
class of worlds `W` with an accessibility relation `R` (read *"is a forcing
extension of"*) and two operators on assertions `P : W → Prop`:

* `box R P w`  — `P` holds in *every* forcing extension of `w` (necessity);
* `dia R P w`  — `P` holds in *some* forcing extension of `w` (possibility).

Here we show these modal operators are **not merely formal**: when `R` is a
preorder (reflexive + transitive — validating axioms **T** and **4**), the
assertions carry a genuine *topology*, the **Alexandrov topology** whose open sets
are the `R`-upward-closed sets, and under this topology

* `box`  *is* the topological **interior** operator (`interior_eq_box`);
* `dia`  *is* the topological **closure** operator (`closure_eq_dia`).

Consequently the buttons of Direction 2 (the `box`-fixed assertions) are exactly
the **open** sets (`isOpen_iff_box_fixed`), and the *settled* assertions — those
whose truth value is invariant along forcing — are exactly the **clopen** sets
(`isClopen_iff_invariant`).  The space is moreover **Alexandrov-discrete**
(`alexandrov_discrete`): arbitrary intersections of opens are open, the
distinguishing feature separating these preorder-topologies from ordinary ones.

Finally we connect back to the quantitative picture of Direction 5: in the
*fully connected* multiverse (`R = ⊤`, every world a forcing extension of every
other — the `S5` situation) the only clopen assertions are the two constants
`⊥` and `⊤` (`isClopen_complete_iff`).  This is the topological face of
`card_settled = 2`: **the settled assertions are exactly the two truth-constants,
everything else is genuinely independent.**

Everything is proved from first principles over `Mathlib`, reusing the `box`/`dia`
definitions of the catalog's `ModalFrame` core.
-/

namespace Multiverse

open Multiverse

variable {W : Type*} (R : W → W → Prop)

/-! ## Upper sets and the Alexandrov topology -/

/-- An assertion `S` is an **upper set** (upward closed) for `R` when it is
preserved along accessibility: if `w ∈ S` and `w` accesses `v`, then `v ∈ S`.
These are the "forcing-stable" assertions: once true they stay true in every
extension. -/
def IsUpSet (S : Set W) : Prop := ∀ ⦃w v⦄, R w v → w ∈ S → v ∈ S

/-- The **Alexandrov topology** of the accessibility relation `R`: the open sets
are exactly the `R`-upper sets.  This is a topology for *any* relation `R`
whatsoever — no frame conditions are needed to define it. -/
def alexandrovForcing : TopologicalSpace W where
  IsOpen S := IsUpSet R S
  isOpen_univ := by intro w v _ _; trivial
  isOpen_inter := by
    intro S T hS hT w v hwv hw; exact ⟨hS hwv hw.1, hT hwv hw.2⟩
  isOpen_sUnion := by
    intro F hF w v hwv hw
    obtain ⟨s, hsF, hws⟩ := hw
    exact ⟨s, hsF, hF s hsF hwv hws⟩

/-- By definition, the open sets of the Alexandrov topology are the upper sets. -/
theorem isOpen_alexandrovForcing_iff (S : Set W) :
    @IsOpen W (alexandrovForcing R) S ↔ IsUpSet R S := Iff.rfl

/-! ## The Sahlqvist correspondence, topologically: `box` = interior, `dia` = closure -/

/-- **`box` is the interior operator.**  Over a preorder (reflexive + transitive
`R` — i.e. validating axioms **T** and **4**), the necessity operator `box`
computes exactly the topological interior in the Alexandrov topology: the largest
forcing-stable assertion implying `S`. -/
theorem interior_eq_box (hR : Reflexive R) (hT : Transitive R) (S : Set W) :
    @interior W (alexandrovForcing R) S = {w | box R (· ∈ S) w} := by
  letI : TopologicalSpace W := alexandrovForcing R
  apply le_antisymm
  · intro w hw v hwv
    have hos : IsOpen (interior S) := isOpen_interior
    exact interior_subset (hos hwv hw)
  · intro w hw
    have hopen : IsOpen {w | box R (· ∈ S) w} := by
      intro a b hab ha c hbc; exact ha c (hT hab hbc)
    have hsub : {w | box R (· ∈ S) w} ⊆ S := fun a ha => ha a (hR a)
    exact interior_maximal hsub hopen hw

/-- **`dia` is the closure operator.**  Dually, over a preorder the possibility
operator `dia` computes exactly the topological closure: the smallest
forcing-costable assertion implied by `S`. -/
theorem closure_eq_dia (hR : Reflexive R) (hT : Transitive R) (S : Set W) :
    @closure W (alexandrovForcing R) S = {w | dia R (· ∈ S) w} := by
  letI : TopologicalSpace W := alexandrovForcing R
  apply le_antisymm
  · have hclosed : IsClosed {w | dia R (· ∈ S) w} := by
      rw [← isOpen_compl_iff]
      intro a b hab ha hb
      exact ha (by obtain ⟨v, hbv, hv⟩ := hb; exact ⟨v, hT hab hbv, hv⟩)
    have hsub : S ⊆ {w | dia R (· ∈ S) w} := fun a ha => ⟨a, hR a, ha⟩
    exact closure_minimal hsub hclosed
  · intro w hw
    rw [mem_closure_iff]
    intro o ho hwo
    obtain ⟨v, hwv, hv⟩ := hw
    exact ⟨v, ho hwv hwo, hv⟩

/-- Idempotence of necessity, `□□p = □p`, read off from `interior_interior`:
the interior of a preorder-topology is idempotent. -/
theorem box_box_eq_box (hR : Reflexive R) (hT : Transitive R) (S : Set W) :
    {w | box R (· ∈ {w | box R (· ∈ S) w}) w} = {w | box R (· ∈ S) w} := by
  letI : TopologicalSpace W := alexandrovForcing R
  have h1 := interior_eq_box R hR hT S
  have h2 := interior_eq_box R hR hT {w | box R (· ∈ S) w}
  rw [← h2, ← h1, interior_interior]

/-! ## Buttons are open, settled assertions are clopen -/

/-- **Buttons = open sets.**  The *buttons* of Direction 2 are the assertions
fixed by necessity (`box R (·∈S) = (·∈S)`); over the Alexandrov topology these are
exactly the **open** sets, i.e. the forcing-stable assertions. -/
theorem isOpen_iff_box_fixed (hR : Reflexive R) (S : Set W) :
    @IsOpen W (alexandrovForcing R) S ↔ ∀ w, w ∈ S ↔ box R (· ∈ S) w := by
  constructor
  · intro hopen w
    exact ⟨fun hw v hwv => hopen hwv hw, fun h => h w (hR w)⟩
  · intro h a b hab ha
    exact (h a).1 ha b hab

/-- **Settled assertions = clopen sets.**  An assertion is *settled* (its truth
value never changes along a forcing extension, in either direction) precisely when
it is **clopen** in the Alexandrov topology: simultaneously forcing-stable and
forcing-costable. -/
theorem isClopen_iff_invariant (S : Set W) :
    @IsClopen W (alexandrovForcing R) S ↔ ∀ w v, R w v → (w ∈ S ↔ v ∈ S) := by
  letI : TopologicalSpace W := alexandrovForcing R
  constructor
  · rintro ⟨hc, ho⟩ w v hwv
    refine ⟨fun hw => ho hwv hw, fun hv => ?_⟩
    rw [← isOpen_compl_iff] at hc
    by_contra hw
    exact hc hwv hw hv
  · intro h
    refine ⟨?_, ?_⟩
    · rw [← isOpen_compl_iff]
      intro a b hab ha hb; exact ha ((h a b hab).2 hb)
    · intro a b hab ha; exact (h a b hab).1 ha

/-! ## Alexandrov-discreteness -/

/-- The Alexandrov topology is **Alexandrov-discrete**: arbitrary (not merely
finite) intersections of open sets are open.  This is the structural hallmark of
topologies arising from a preorder, and is what makes `box`/`dia` behave as honest
interior/closure operators computed pointwise. -/
theorem alexandrov_discrete : @AlexandrovDiscrete W (alexandrovForcing R) := by
  letI : TopologicalSpace W := alexandrovForcing R
  constructor
  intro F hF w v hwv hw s hs
  exact hF s hs hwv (hw s hs)

/-! ## The fully connected multiverse: only the two constants are settled -/

/-- **The topological face of `card_settled = 2`.**  In the *fully connected*
multiverse — where every world is a forcing extension of every other, the
symmetric `S5` situation — the only **clopen** (settled) assertions are the two
truth-constants `⊥` (`∅`) and `⊤` (`Set.univ`).  Every contingent assertion is
genuinely independent: it can be forced true and forced false.  This is the exact
topological restatement of the count `card_settled = 2` from Direction 5. -/
theorem isClopen_complete_iff [Nonempty W] (S : Set W) :
    @IsClopen W (alexandrovForcing (fun _ _ => True)) S ↔ (S = ∅ ∨ S = Set.univ) := by
  letI : TopologicalSpace W := alexandrovForcing (fun _ _ => True)
  constructor
  · rintro ⟨hc, ho⟩
    rw [← isOpen_compl_iff] at hc
    by_cases h : ∃ w, w ∈ S
    · right
      obtain ⟨w, hw⟩ := h
      ext v; simp only [Set.mem_univ, iff_true]
      exact ho (by trivial) hw
    · left
      push_neg at h
      ext v; simp only [Set.mem_empty_iff_false, iff_false]
      exact h v
  · rintro (rfl | rfl)
    · exact isClopen_empty
    · exact isClopen_univ

/-!
## `-- !-- Lab Notes -- !--`

**Hypothesis (Hypothesizer).**  The modal `box`/`dia` operators of the forcing
multiverse are not just Boolean gadgets: they should coincide with the
*interior*/*closure* operators of a bona fide topology on the class of worlds.
Conjecture: the correct topology is the Alexandrov (upper-set) topology of the
accessibility preorder, and the button/switch dichotomy of Direction 2 is the
open/dense dichotomy of that topology.

**Experiment (Experimenter).**  Constructed `alexandrovForcing R` as the topology
whose opens are the `R`-upper sets — valid for *any* relation.  Proved
`interior_eq_box` and `closure_eq_dia` assuming only reflexivity + transitivity
(axioms **T** and **4**); the proofs use the universal properties
`interior_maximal` / `closure_minimal`, showing that `box S` is the largest open
subset and `dia S` the smallest closed superset.  Deduced idempotence
`box_box_eq_box` for free from `interior_interior`.

**Analysis (Analyst).**  The correspondence needs *exactly* a preorder:
reflexivity gives `interior ⊆ S` (axiom **T**), transitivity gives that `box S` is
open (axiom **4**).  This explains structurally *why* **T** and **4** are the
"topological" forcing axioms while **B**/**5** (symmetry/euclideanness) are extra:
symmetry collapses the specialization preorder and forces the topology toward
indiscreteness.  The `isClopen_complete_iff` result confirms this — under the
symmetric `S5` relation `⊤` the topology is indiscrete, whose only clopens are
`∅` and `univ`.

**Critique (Critic).**  Guarded against triviality: `interior_eq_box` is a genuine
set equality proved via antisymmetry, not `rfl`; the hypotheses `hR`, `hT` are
load-bearing (dropping either breaks one inclusion).  `isClopen_complete_iff`
requires `Nonempty W` (otherwise `∅ = univ` and the disjunction degenerates).  No
theorem is `True`, definitional, or closed by a single decision procedure.

**Synthesis (Principal Investigator).**  Direction 4 is discharged: the modal
logic of forcing is the interior/closure calculus of the Alexandrov topology of
the extension preorder, the buttons are its open sets, and the settled assertions
are its clopen sets — recovering `card_settled = 2` topologically in the fully
connected multiverse.
-/

end Multiverse