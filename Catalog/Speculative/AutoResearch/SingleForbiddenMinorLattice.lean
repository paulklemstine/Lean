/-
  The Lattice of Minor-Closed Classes: Ideals, Coavoidance, and Single
  Forbidden Minors
  ====================================================================

  This file extends the order-theoretic backbone of the catalog's theory of
  *minor-closed graph classes* (`Catalog/Probability/OrderFramework.lean`,
  namespace `MinorTheory`), which already established the abstract
  single-forbidden-minor characterisation

      `SingleExcludedMinor C ↔ obstructions C is a singleton`

  (over a well-founded partial order modelling the graph-minor relation).  We push
  the *lattice* picture further, locating single-forbidden-minor classes inside the
  complete lattice of minor-closed classes, and we organise the two canonical
  "extremal" constructions that bracket the mission target:

  * `minorIdeal G`   — the principal down-set `↓G = {x | x ≤ G}`, the **smallest**
                       minor-closed class containing `G`.
  * `excl {H}`       — proved here to be the **largest** minor-closed class
                       *avoiding* `H` (i.e. not having `H` as a member), realised
                       concretely as `⋃₀ {C | MinorClosed C ∧ H ∉ C}`.

  Main new results (all 0-sorry):

  * `minorClosed_minorIdeal`            : principal down-sets are minor-closed.
  * `minorIdeal_subset_of_mem`          : `↓G` is the smallest minor-closed class
                                          containing `G`.
  * `excl_singleton_maximal_avoiding`   : any minor-closed class avoiding `H` is
                                          contained in `excl {H}`.
  * `excl_singleton_eq_sUnion_avoiding` : `excl {H}` *is* the union of all
                                          minor-closed classes avoiding `H` — the
                                          unique ⊆-maximal such class.
  * `minorClosed_sandwich`              : every minor-closed `C` containing `G` and
                                          avoiding `H` is sandwiched
                                          `↓G ⊆ C ⊆ excl {H}`.
  * `obstructions_antichain`            : the minimal obstructions of any class form
                                          an antichain (the easy half of
                                          Robertson–Seymour, in lattice form).
  * `singleExcludedMinor_iff_obstructions_singleton`
                                        : capstone, single forbidden minor ⇔ unique
                                          minimal obstruction (well-founded order).

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the catalog's iff is the "local" statement; the
    mission's "⊆-minimal class has a single forbidden minor" is fundamentally a
    *lattice* statement.  Conjecture: single-forbidden-minor classes are exactly
    the ⊆-maximal classes that avoid a fixed graph, while the dual extremal object
    — the smallest class containing a fixed graph — is a principal ideal that in
    general needs *many* forbidden minors.
  Experiment (Experimenter): formalised `minorIdeal`, `avoiding`, and proved both
    extremal characterisations.  The largest-avoiding identity reduces to two facts
    that need only transitivity of the minor order: `excl {H}` itself avoids `H`,
    and any minor-closed `C` with `H ∉ C` lies inside `excl {H}` because `H ≤ x`
    with `x ∈ C` would force `H ∈ C` by downward closure.
  Analysis (Analyst): the asymmetry is the key insight.  `excl {H}` (one forbidden
    minor) is *maximal* avoiding; `minorIdeal G` (the minimal class containing `G`)
    is generally *not* a single-forbidden-minor class, since its obstruction set is
    the antichain of minimal graphs that are not minors of `G`, which is typically
    large.  So "few forbidden minors" is a feature of *large* (maximal) classes,
    explaining why the mission restricts to ⊆-minimal classes *above a density
    threshold*: the density floor forces the class to be large enough that its
    obstruction antichain collapses to a single graph.
  Critique (Critic): `excl_singleton_maximal_avoiding` needs only a `Preorder`;
    antisymmetry is genuinely required for the obstruction *antichain* and the
    *uniqueness* statements, and well-foundedness for the round trip
    `C = excl (obstructions C)`.  Hypotheses are tracked at minimal strength per
    section.  None of the theorems is vacuous: `excl {H}` always strictly avoids
    `H` (`H_not_mem_excl_singleton`), so the avoiding family is non-degenerate.
  Synthesis (PI): the lattice of minor-closed classes has, for each `H`, a unique
    maximal element avoiding `H` (namely `excl {H}`), and the single-forbidden-minor
    classes are precisely these maximal coavoiders.  The density-`3/2` mission
    target is the assertion that ⊆-minimality above the threshold lands you exactly
    on one of these maximal coavoiders.
  -- !-- Lab Notes -- !--
-/
import Mathlib

namespace MinorTheory.Novelty

variable {α : Type*}

/-! ### Preorder layer: minor-closure, exclusion, ideals -/

section Preorder
variable [Preorder α]

/-- A class `C` is **minor-closed** when it is downward closed under the minor
relation `· ≤ ·`.  (Mirrors `MinorTheory.MinorClosed`.) -/
def MinorClosed (C : Set α) : Prop := ∀ ⦃x y : α⦄, x ≤ y → y ∈ C → x ∈ C

/-- `excl S` is the class of objects excluding every member of `S` as a minor.
(Mirrors `MinorTheory.excl`.) -/
def excl (S : Set α) : Set α := {x | ∀ ⦃s⦄, s ∈ S → ¬ s ≤ x}

theorem mem_excl {S : Set α} {x : α} : x ∈ excl S ↔ ∀ ⦃s⦄, s ∈ S → ¬ s ≤ x := Iff.rfl

/-- Every excluded-minor class is minor-closed (uses transitivity of the order). -/
theorem excl_minorClosed (S : Set α) : MinorClosed (excl S) := by
  intro x y hxy hy s hs hsx
  exact hy hs (le_trans hsx hxy)

/-- The **principal minor-ideal** `↓G = {x | x ≤ G}`: the down-set generated by a
single graph `G`. -/
def minorIdeal (G : α) : Set α := {x | x ≤ G}

@[simp] theorem mem_minorIdeal {G x : α} : x ∈ minorIdeal G ↔ x ≤ G := Iff.rfl

/-- Principal minor-ideals are minor-closed. -/
theorem minorClosed_minorIdeal (G : α) : MinorClosed (minorIdeal G) := by
  intro x y hxy hy
  exact le_trans hxy hy

theorem self_mem_minorIdeal (G : α) : G ∈ minorIdeal G := le_refl G

/-- **Smallest class containing `G`.** Any minor-closed class containing `G`
contains the whole principal ideal `↓G`. -/
theorem minorIdeal_subset_of_mem {C : Set α} (hC : MinorClosed C) {G : α}
    (hG : G ∈ C) : minorIdeal G ⊆ C :=
  fun _ hx => hC hx hG

/-! ### Coavoidance: `excl {H}` is the largest class avoiding `H` -/

/-- `H` is never a member of `excl {H}` (the exclusion is non-degenerate). -/
theorem H_not_mem_excl_singleton (H : α) : H ∉ excl ({H} : Set α) := by
  intro h; exact h (Set.mem_singleton H) (le_refl H)

/-- **Maximality of single exclusion.** Any minor-closed class `C` that does *not*
contain `H` is contained in `excl {H}`: if some `x ∈ C` had `H ≤ x`, downward
closure would force `H ∈ C`. -/
theorem excl_singleton_maximal_avoiding {H : α} {C : Set α} (hC : MinorClosed C)
    (hH : H ∉ C) : C ⊆ excl {H} := by
  intro x hx s hs hsx
  rw [Set.mem_singleton_iff] at hs; subst hs
  exact hH (hC hsx hx)

/-- The family of all minor-closed classes that avoid `H`. -/
def avoiding (H : α) : Set (Set α) := {C | MinorClosed C ∧ H ∉ C}

/-- **`excl {H}` is the largest class avoiding `H`.** It equals the union of *all*
minor-closed classes that avoid `H`; hence it is the unique ⊆-maximal such class.
This is the lattice-theoretic identity of single-forbidden-minor classes. -/
theorem excl_singleton_eq_sUnion_avoiding (H : α) :
    excl ({H} : Set α) = ⋃₀ avoiding H := by
  apply Set.Subset.antisymm
  · intro x hx
    exact ⟨excl {H}, ⟨excl_minorClosed _, H_not_mem_excl_singleton H⟩, hx⟩
  · rintro x ⟨C, ⟨hCmc, hCH⟩, hxC⟩
    exact excl_singleton_maximal_avoiding hCmc hCH hxC

/-- **Sandwich.** A minor-closed class containing `G` and avoiding `H` is squeezed
between the principal ideal `↓G` and the maximal coavoider `excl {H}`. -/
theorem minorClosed_sandwich {C : Set α} (hC : MinorClosed C) {G H : α}
    (hG : G ∈ C) (hH : H ∉ C) :
    minorIdeal G ⊆ C ∧ C ⊆ excl {H} :=
  ⟨minorIdeal_subset_of_mem hC hG, excl_singleton_maximal_avoiding hC hH⟩

end Preorder

/-! ### Partial-order layer: the obstruction antichain -/

section PartialOrder
variable [PartialOrder α]

/-- The set of **minimal obstructions** of a class `C`. (Mirrors
`MinorTheory.obstructions`.) -/
def obstructions (C : Set α) : Set α := {m | m ∉ C ∧ ∀ x, x < m → x ∈ C}

/-- **The obstruction set is an antichain** (easy half of Robertson–Seymour): no
minimal obstruction is a proper minor of another. -/
theorem obstructions_antichain (C : Set α) :
    IsAntichain (· ≤ ·) (obstructions C) := by
  intro a ha b hb hab hle
  exact ha.1 (hb.2 a (lt_of_le_of_ne hle hab))

/-- The obstruction set of `excl {H}` is exactly `{H}`. -/
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

/-! ### Well-founded layer: the single-forbidden-minor capstone -/

section WellFounded
variable [PartialOrder α] [WellFoundedLT α]

/-- A class is characterised by a **single forbidden minor** if it equals
`excl {H}` for some `H`. -/
def SingleExcludedMinor (C : Set α) : Prop := ∃ H : α, C = excl {H}

omit [WellFoundedLT α] in
theorem subset_excl_obstructions {C : Set α} (hC : MinorClosed C) :
    C ⊆ excl (obstructions C) := by
  intro x hx m hm hmx
  exact hm.1 (hC hmx hx)

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

/-- Every minor-closed class equals the class excluding its minimal obstructions. -/
theorem minorClosed_excl_obstructions {C : Set α} (hC : MinorClosed C) :
    C = excl (obstructions C) :=
  Set.Subset.antisymm (subset_excl_obstructions hC) (excl_obstructions_subset C)

/-- **Single-forbidden-minor capstone.** A minor-closed class is described by a
single excluded minor iff its obstruction set is a singleton. -/
theorem singleExcludedMinor_iff_obstructions_singleton {C : Set α}
    (hC : MinorClosed C) :
    SingleExcludedMinor C ↔ ∃ H : α, obstructions C = {H} := by
  constructor
  · rintro ⟨H, rfl⟩
    exact ⟨H, obstructions_excl_singleton H⟩
  · rintro ⟨H, hH⟩
    exact ⟨H, by rw [minorClosed_excl_obstructions hC, hH]⟩

end WellFounded

end MinorTheory.Novelty