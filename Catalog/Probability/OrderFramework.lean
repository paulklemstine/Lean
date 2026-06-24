/-
  Minor-Closed Graph Classes — Order-Theoretic Framework
  ======================================================

  This file develops the abstract order-theoretic backbone of the theory of
  *minor-closed graph classes*.  We work in a generic ordered type `α` in which
  the relation `x ≤ y` is read as "`x` is a minor of `y`".  Every concrete model
  of the graph-minor relation (or any sub-relation of it, such as the subgraph
  order — see `ForestDensity.lean`) is an instance of this framework.

  A *graph class* is a set `C : Set α`; it is **minor-closed** when it is downward
  closed under the minor relation.  The fundamental construction is `excl S`, the
  class of objects that exclude every member of `S` as a minor.  The key results
  formalise the *easy half of the Robertson–Seymour philosophy*:

  * `excl_minorClosed`              : every excluded-minor class is minor-closed.
  * `minorClosed_excl_obstructions` : conversely, over a well-founded minor order
                                      every minor-closed class is the class of
                                      graphs excluding its set of minimal
                                      obstructions.
  * `obstructions_excl_singleton`   : the obstruction set of a single-excluded-minor
                                      class `excl {H}` is exactly `{H}`.
  * `singleExcludedMinor_iff_obstructions_singleton`
                                    : a minor-closed class is characterised by a
                                      single forbidden minor **iff** its obstruction
                                      set is a singleton.

  The last statement is the abstract form of the mission's target: *being
  characterised by a single forbidden minor* is equivalent to *having a single
  minimal obstruction*.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): "Minor-closed = exclude a set of forbidden minors"
    should be a theorem, not a definition, given well-foundedness of the order.
  Experiment (Experimenter): formalised `excl`, `obstructions`, and proved the
    round trip `MinorClosed C ↔ C = excl (obstructions C)` under `WellFoundedLT`.
  Analysis (Analyst): the forward direction needs only downward closure +
    transitivity; the reverse direction is exactly where well-foundedness enters
    (to extract a *minimal* forbidden minor below any excluded graph).
  Critique (Critic): uniqueness of the obstruction of `excl {H}` genuinely needs
    antisymmetry (`PartialOrder`), not merely a preorder — a preorder allows
    `H ≤ m ≤ H` with `m ≠ H`.  Statement guarded accordingly.
  Synthesis (PI): the single-forbidden-minor property reduces to a singleton
    obstruction set; this is the order-theoretic core of the 3/2 conjecture.
  -- !-- Lab Notes -- !--
-/
import Mathlib

namespace MinorTheory

variable {α : Type*}

section Preorder
variable [Preorder α]

/-- A graph class `C` is **minor-closed** when it is downward closed under the
minor relation `· ≤ ·`. -/
def MinorClosed (C : Set α) : Prop := ∀ ⦃x y : α⦄, x ≤ y → y ∈ C → x ∈ C

/-- `excl S` is the class of objects excluding every member of `S` as a minor. -/
def excl (S : Set α) : Set α := {x | ∀ ⦃s⦄, s ∈ S → ¬ s ≤ x}

theorem mem_excl {S : Set α} {x : α} : x ∈ excl S ↔ ∀ ⦃s⦄, s ∈ S → ¬ s ≤ x := Iff.rfl

/-- Every excluded-minor class is minor-closed. -/
theorem excl_minorClosed (S : Set α) : MinorClosed (excl S) := by
  intro x y hxy hy s hs hsx
  exact hy hs (le_trans hsx hxy)

/-- `excl` is antitone: excluding more graphs yields a smaller class. -/
theorem excl_anti {S T : Set α} (h : S ⊆ T) : excl T ⊆ excl S := by
  intro x hx s hs
  exact hx (h hs)

theorem minorClosed_univ : MinorClosed (Set.univ : Set α) := by
  intro x y _ _; trivial

theorem minorClosed_empty : MinorClosed (∅ : Set α) := by
  intro x y _ hy; exact hy

/-- Minor-closed classes are closed under arbitrary intersection. -/
theorem MinorClosed.sInter {𝒮 : Set (Set α)} (h : ∀ C ∈ 𝒮, MinorClosed C) :
    MinorClosed (⋂₀ 𝒮) := by
  intro x y hxy hy C hC
  exact h C hC hxy (hy C hC)

/-- Minor-closed classes are closed under arbitrary union. -/
theorem MinorClosed.sUnion {𝒮 : Set (Set α)} (h : ∀ C ∈ 𝒮, MinorClosed C) :
    MinorClosed (⋃₀ 𝒮) := by
  rintro x y hxy ⟨C, hC, hyC⟩
  exact ⟨C, hC, h C hC hxy hyC⟩

/-- The set of **minimal obstructions** of a class `C`: graphs outside `C` all of
whose proper minors lie in `C`. -/
def obstructions (C : Set α) : Set α := {m | m ∉ C ∧ ∀ x, x < m → x ∈ C}

/-- A class is characterised by a **single forbidden minor** if it equals
`excl {H}` for some `H`. -/
def SingleExcludedMinor (C : Set α) : Prop := ∃ H : α, C = excl {H}

/-- Forward half of the obstruction characterisation: a minor-closed class is
contained in the class excluding its obstructions. -/
theorem subset_excl_obstructions {C : Set α} (hC : MinorClosed C) :
    C ⊆ excl (obstructions C) := by
  intro x hx m hm hmx
  exact hm.1 (hC hmx hx)

end Preorder

section WellFounded
variable [Preorder α] [WellFoundedLT α]

/-- Reverse half (needs well-foundedness): every graph excluding all obstructions
of a minor-closed class lies in the class. -/
theorem excl_obstructions_subset (C : Set α) :
    excl (obstructions C) ⊆ C := by
  intro x hx
  by_contra hxC
  have hne : {y : α | y ≤ x ∧ y ∉ C}.Nonempty := ⟨x, le_refl x, hxC⟩
  obtain ⟨m, hm, hmin⟩ := wellFounded_lt.has_min {y : α | y ≤ x ∧ y ∉ C} hne
  have hmobs : m ∈ obstructions C := by
    refine ⟨hm.2, ?_⟩
    intro z hz
    by_contra hzC
    exact hmin z ⟨le_trans (le_of_lt hz) hm.1, hzC⟩ hz
  exact hx hmobs hm.1

/-- **Excluded-minor characterisation.** Over a well-founded minor order, a class
is minor-closed iff it is the class of graphs excluding its minimal obstructions. -/
theorem minorClosed_excl_obstructions {C : Set α} (hC : MinorClosed C) :
    C = excl (obstructions C) :=
  Set.Subset.antisymm (subset_excl_obstructions hC) (excl_obstructions_subset C)

end WellFounded

section PartialOrder
variable [PartialOrder α]

/-- The obstruction set of a single-excluded-minor class `excl {H}` is exactly
`{H}`.  This identifies the unique minimal forbidden minor. -/
theorem obstructions_excl_singleton (H : α) :
    obstructions (excl ({H} : Set α)) = {H} := by
  ext m
  simp only [obstructions, Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hmnot, hmin⟩
    have hHm : H ≤ m := by
      by_contra h
      exact hmnot (fun s hs => by rw [Set.mem_singleton_iff] at hs; subst hs; exact h)
    by_contra hmH
    have hlt : H < m := lt_of_le_of_ne hHm (fun he => hmH he.symm)
    exact (hmin H hlt) (Set.mem_singleton H) (le_refl H)
  · rintro rfl
    refine ⟨fun h => h (Set.mem_singleton m) (le_refl m), ?_⟩
    intro x hx s hs
    rw [Set.mem_singleton_iff] at hs; subst hs
    exact fun hHx => absurd (lt_of_le_of_lt hHx hx) (lt_irrefl s)

end PartialOrder

section Characterisation
variable [PartialOrder α] [WellFoundedLT α]

/-- **Single-forbidden-minor characterisation.** A minor-closed class is described
by a single excluded minor iff its obstruction set is a singleton.  This is the
order-theoretic form of the mission target. -/
theorem singleExcludedMinor_iff_obstructions_singleton {C : Set α}
    (hC : MinorClosed C) :
    SingleExcludedMinor C ↔ ∃ H : α, obstructions C = {H} := by
  constructor
  · rintro ⟨H, rfl⟩
    exact ⟨H, obstructions_excl_singleton H⟩
  · rintro ⟨H, hH⟩
    refine ⟨H, ?_⟩
    rw [minorClosed_excl_obstructions hC, hH]

end Characterisation

end MinorTheory