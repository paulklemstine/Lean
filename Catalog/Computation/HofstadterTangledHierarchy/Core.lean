import Mathlib
import Logic.StrangeLoops.Core
import Bridges.WellFoundedInductionBridge

/-!
# Tangled Hierarchies and Predicative Levels

A hierarchy is tangled when its strict dependency relation contains a two-cycle.
This chapter separates three phenomena that are often conflated: genuine cycles
in a strict relation, reversible changes of presentation across universe levels,
and diagonal self-representation.  Genuine cycles are incompatible with
well-foundedness.  By contrast, lifting an object to a larger universe and then
lowering it is reversible because it changes presentation rather than creating a
reverse edge in the universe ordering.  Finally, unrestricted representation of
all predicates is impossible by diagonalization; this is the precise fragment of
the `Type : Type` obstruction established here.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Seven conjectures were ranked by structural impact.
-- (1) Every well-founded dependency relation excludes two-cycles.  (2) Every
-- rank-decreasing hierarchy excludes cycles of arbitrary finite length.  (3) The
-- natural-number universe index is an infinite, untangled hierarchy.  (4)
-- universe lifting can produce reversible apparent back-links without a cycle in
-- level order.  (5) any asymmetric hierarchy becomes inconsistent when a genuine
-- tangle is postulated.  (6) unrestricted internal representation of all
-- predicates yields a diagonal contradiction.  (7) reversible universe lifting
-- alone yields unrestricted self-representation.  Conjectures (2), (6), and (7)
-- were the bold targets, connecting termination ranks, type levels, and semantic
-- diagonalization.
--
-- Experiment (Experimenter): Conjectures (1)--(6) survived in guarded forms.
-- Arbitrary finite cycles were reduced to an impossible strict descent of a
-- natural-valued rank.  Repeated lifting was tested at one and two levels and
-- found coherent after lowering.  Conjecture (7) failed: lifting supplies an
-- equivalence of presentations, not a surjection onto the predicate space.
--
-- Analysis (Analyst): The decisive invariant is a rank into a well-founded
-- order.  A genuine dependency edge must lower rank, whereas an `ULift` round
-- trip preserves the represented object and therefore is not a dependency edge.
-- Diagonal paradox requires the much stronger ability to represent every
-- predicate, not merely the ability to transport data between presentations.
--
-- Critique (Critic): A partial order cannot literally contain `x < y` and
-- `y < x`; calling the ambient object a poset while postulating such witnesses is
-- contradictory by definition.  Accordingly, tangles are defined first for an
-- arbitrary relation and then ruled out under well-foundedness or asymmetry.
-- The diagonal theorem is a structural obstruction, not a full internal
-- derivation of Girard's paradox.  The latter would require a separately defined
-- impredicative dependent calculus and its normalization or consistency theory.
-- No claim is made that universe polymorphism permits a lower universe to contain
-- a higher universe.
--
-- Synthesis (Principal Investigator): True tangles, reversible presentation
-- changes, and semantic self-enumeration occupy three distinct logical strengths.
-- Rank descent rules out the first, lifting safely realizes the second, and
-- Cantor--Lawvere diagonalization refutes the third.  Thus apparent hierarchy
-- loops are compatible with predicativity precisely when they do not become
-- reverse edges or universal semantic codes.
-- !-- End Lab Notes -- !--
-/

namespace HofstadterTangledHierarchy

open Function

universe u v

/-- A relation is tangled when two of its points lie strictly on both sides of
one another.  No order laws are built into the definition, so the contradiction
becomes visible only when structural hypotheses are imposed. -/
def Tangled {α : Type u} (r : α → α → Prop) : Prop :=
  ∃ x y, r x y ∧ r y x

/-- A tangle is exactly a directed closed walk of length two. -/
theorem tangled_iff_two_cycle {α : Type u} {r : α → α → Prop} :
    Tangled r ↔ ∃ x₀ x₁ x₂, x₂ = x₀ ∧ r x₀ x₁ ∧ r x₁ x₂ := by
  constructor
  · rintro ⟨x, y, hxy, hyx⟩
    exact ⟨x, y, x, rfl, hxy, hyx⟩
  · rintro ⟨x₀, x₁, x₂, hx, h₀, h₁⟩
    subst x₂
    exact ⟨x₀, x₁, h₀, h₁⟩

/-- Well-founded dependency relations cannot be tangled. -/
theorem wellFounded_not_tangled {α : Type u} {r : α → α → Prop}
    (hwf : WellFounded r) : ¬ Tangled r := by
  rintro ⟨x, y, hxy, hyx⟩
  exact (hwf.asymmetric x y hxy) hyx

/-- A strict hierarchy is represented by a natural-valued rank that decreases
along every dependency edge. -/
structure RankedHierarchy (α : Type u) where
  depends : α → α → Prop
  rank : α → ℕ
  rank_decreases : ∀ {child parent}, depends child parent → rank child < rank parent

/-- Every ranked dependency hierarchy is well-founded, since dependency is
contained in the inverse image of the well-founded order on natural numbers. -/
theorem RankedHierarchy.wellFounded {α : Type u} (H : RankedHierarchy α) :
    WellFounded H.depends := by
  apply (InvImage.wf H.rank wellFounded_lt).mono
  intro child parent h
  exact H.rank_decreases h

/-- Consequently a rank-decreasing hierarchy has no genuine tangle. -/
theorem RankedHierarchy.not_tangled {α : Type u} (H : RankedHierarchy α) :
    ¬ Tangled H.depends := by
  apply wellFounded_not_tangled
  exact H.wellFounded

/-- Along a finite dependency path, the rank at the endpoint is strictly below
that at the starting point. -/
theorem RankedHierarchy.rank_path_decreases {α : Type u} (H : RankedHierarchy α)
    (f : ℕ → α) : ∀ {n : ℕ}, 0 < n →
      (∀ i, i < n → H.depends (f (i + 1)) (f i)) →
      H.rank (f n) < H.rank (f 0) := by
  intro n hn hpath
  induction n with
  | zero => omega
  | succ n ih =>
      cases n with
      | zero =>
          simpa using H.rank_decreases (hpath 0 (by omega))
      | succ n =>
          have hprefix : ∀ i, i < n + 1 → H.depends (f (i + 1)) (f i) := by
            intro i hi
            exact hpath i (by omega)
          have hlong : H.rank (f (n + 1)) < H.rank (f 0) :=
            ih (by omega) hprefix
          have hlast : H.rank (f (n + 2)) < H.rank (f (n + 1)) :=
            H.rank_decreases (hpath (n + 1) (by omega))
          exact hlast.trans hlong

/-- No positive-length finite dependency path in a ranked hierarchy can return
exactly to its starting point. -/
theorem RankedHierarchy.no_finite_cycle {α : Type u} (H : RankedHierarchy α)
    (f : ℕ → α) {n : ℕ} (hn : 0 < n)
    (hpath : ∀ i, i < n → H.depends (f (i + 1)) (f i)) :
    f n ≠ f 0 := by
  intro hclosed
  have hlt := H.rank_path_decreases f hn hpath
  rw [hclosed] at hlt
  exact (Nat.lt_irrefl _ hlt)

/-- The ordinary universe-level index: level `i` is below level `j` precisely
when `i < j`. -/
def LevelBelow (i j : ℕ) : Prop := i < j

/-- Natural-number levels are well-founded in the dependency direction. -/
theorem levelBelow_wellFounded : WellFounded LevelBelow := by
  exact WellFoundedInductionBridge.nat_well_founded

/-- The natural-number hierarchy is not tangled. -/
theorem universe_levels_not_tangled : ¬ Tangled LevelBelow := by
  apply wellFounded_not_tangled
  exact levelBelow_wellFounded

/-- Every level has a strictly higher successor, so the untangled hierarchy has
no maximal universe index. -/
theorem universe_levels_unbounded : ∀ i : ℕ, ∃ j, LevelBelow i j := by
  intro i
  refine ⟨i + 1, ?_⟩
  exact Nat.lt_succ_self i

/-- A predicative change of presentation from a type to a copy living in a
larger universe. -/
def raiseUniverse (α : Type u) : Type (u + 1) := ULift.{u + 1, u} α

/-- The lifted presentation is equivalent to the original type even though it
resides in a higher universe. -/
def liftPresentationEquiv (α : Type u) : raiseUniverse α ≃ α :=
  Equiv.ulift

/-- Raising and lowering a value preserves it.  This is the basic source of an
apparent back-link across universe presentations. -/
theorem lower_raise (α : Type u) (x : α) :
    (ULift.up x : raiseUniverse α).down = x := by
  exact (liftPresentationEquiv α).apply_symm_apply x

/-- Two successive lifts are coherent with two successive projections.  The
same polymorphic construction is instantiated at different universe levels,
without identifying those levels. -/
theorem double_lift_coherent (α : Type u) (x : α) :
    ((ULift.up (ULift.up x : raiseUniverse α) :
      raiseUniverse (raiseUniverse α)).down).down = x := by
  calc
    ((ULift.up (ULift.up x : raiseUniverse α) :
      raiseUniverse (raiseUniverse α)).down).down =
        (ULift.up x : raiseUniverse α).down := by
          rw [lower_raise (raiseUniverse α)]
    _ = x := lower_raise α x

/-- Asymmetry is the exact local hierarchy law contradicted by a two-cycle. -/
theorem tangle_forces_hierarchy_failure {α : Type u} {r : α → α → Prop}
    (ht : Tangled r) : ¬ (∀ ⦃x y⦄, r x y → ¬ r y x) := by
  intro hasymm
  rcases ht with ⟨x, y, hxy, hyx⟩
  exact (hasymm hxy) hyx

/-- A consistent proposition-valued theory cannot combine an asymmetric strict
hierarchy with a genuine tangle.  Thus one must abandon the tangle or the strict
hierarchy law; no additional semantic assumptions are hidden here. -/
theorem consistency_or_hierarchy {α : Type u} {r : α → α → Prop}
    (hasymm : ∀ ⦃x y⦄, r x y → ¬ r y x) (ht : Tangled r) : False := by
  have hfailure := tangle_forces_hierarchy_failure ht
  exact hfailure hasymm

/-- The Cantor--Lawvere obstruction to an ultimate semantic tangle: no type can
index every predicate on itself.  An impredicative `Type : Type` calculus with
unrestricted internal coding would have to evade this diagonal boundary. -/
theorem no_unrestricted_self_representation (Code : Type u) :
    ¬ ∃ represent : Code → (Code → Prop), Surjective represent := by
  intro h
  exact cantor_from_lawvere Code h

/-- More generally, point-surjective self-representation would force every
operation on observations to have a fixed point. -/
theorem self_representation_diagonal_boundary {Code : Type u} {Obs : Type v}
    (represent : Code → Code → Obs) (hrepresent : Surjective represent)
    (transform : Obs → Obs) : ∃ observation, transform observation = observation := by
  obtain ⟨observation, hfixed⟩ :=
    lawvere_fixed_point represent hrepresent transform
  exact ⟨observation, hfixed⟩

end HofstadterTangledHierarchy