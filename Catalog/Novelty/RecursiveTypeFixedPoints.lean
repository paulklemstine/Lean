import Mathlib
import Catalog.Logic.StrangeLoops.Core

/-!
# Recursive Type Fixed Points and Diagonal Boundaries

The equation `T ≃ Π x : T, P x` is separated here from the stronger assertion
that a type internally names every predicate on itself.  The former equation can
hold for a finite, decidable type; the latter is blocked by diagonalization.
This distinction gives a precise boundary for claims connecting recursive types,
self-knowledge, and undecidability.

A second construction records alternating universal and existential layers in a
reflective syntax.  Dualization exchanges the two quantifiers without changing
rank, while canonical towers witness every finite rank.  Thus the robust
hierarchy obtained from the proposed picture is an unbounded finite syntactic
hierarchy, not a cardinality assertion about the Church--Kleene ordinal.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The conjectures, ranked by expected impact, were:
-- (1) complete internal naming of predicates forces a Lawvere fixed point;
-- (2) propositional negation therefore prevents complete self-knowledge;
-- (3) the bare equation `T ≃ Π x : T, P x` already forces undecidability;
-- (4) alternating reflective quantifiers form a rank-stratified hierarchy;
-- (5) duality exchanges universal and existential strata and preserves rank;
-- (6) finite rank strata exhaust an ordinal-sized collection of recursive types.
-- The first, fourth, and sixth were the bold cross-domain targets, connecting
-- dependent products, diagonal logic, syntax, and ordinal hierarchies.
--
-- Experiment (Experimenter): Conjectures (1), (2), (4), and (5) survived.
-- Conjecture (3) was refuted by the one-element type with the constantly true
-- predicate.  Conjecture (6) could not survive its stated form: a cardinality of
-- types is universe-dependent, whereas the Church--Kleene ordinal measures
-- computable well-order types rather than the size of an unqualified class of
-- types.
--
-- Analysis (Analyst): Recursive presentation and semantic completeness are
-- different resources.  An equivalence with one dependent product may be small
-- and decidable.  Diagonal obstruction appears only when every predicate is
-- uniformly represented.  Independently, alternation depth gives a canonical
-- natural-number filtration whose strictness is witnessed syntactically.
--
-- Critique (Critic): No identification of type cardinality with an ordinal is
-- asserted.  The hierarchy theorem concerns syntax, not completeness for the
-- classical arithmetical hierarchy.  The counterexample is retained because it
-- rules out the proposed undecidability theorem under exactly its stated
-- hypothesis.  The diagonal results use genuine surjectivity rather than an
-- impossible or vacuous premise hidden in a definition.
--
-- Synthesis (Principal Investigator): The defensible theory has three parts: a
-- finite countermodel to bare recursive-product undecidability, a diagonal
-- theorem for complete predicate self-models, and an unbounded finite hierarchy
-- of alternating reflective codes equipped with rank-preserving duality.
-- !-- End Lab Notes -- !--
-/

namespace RecursiveTypeFixedPoints

open Function

universe u

/-- A recursive dependent-product presentation of a type. -/
structure RecursivePresentation (T : Type u) where
  predicate : T → Prop
  unfoldEquiv : T ≃ ((x : T) → predicate x)

/-- The one-element type has a recursive presentation by the constantly true
predicate.  This is the decisive finite countermodel to bare undecidability. -/
def unitPresentation : RecursivePresentation PUnit where
  predicate := fun _ => True
  unfoldEquiv := Equiv.ofUnique PUnit ((x : PUnit) → True)

/-- The recursively presented one-element type still has decidable equality. -/
theorem recursive_presentation_does_not_force_undecidable :
    Nonempty (RecursivePresentation PUnit) ∧
      (∃ eqb : PUnit → PUnit → Bool, ∀ x y, eqb x y = true ↔ x = y) := by
  constructor
  · exact ⟨unitPresentation⟩
  · refine ⟨fun _ _ => true, ?_⟩
    intro x y
    constructor
    · intro _
      cases x
      cases y
      rfl
    · intro _
      rfl

/-- A semantic self-model assigns to each code a predicate on its own code
space. -/
structure SemanticSelfModel (T : Type u) where
  inspect : T → (T → Prop)

/-- Completeness means that every predicate on the code space is internally
named. -/
def SemanticSelfModel.Complete {T : Type u} (M : SemanticSelfModel T) : Prop :=
  Surjective M.inspect

/-- The diagonal predicate differs from every predicate named by a given
semantic self-model. -/
theorem diagonal_predicate_omitted {T : Type u} (M : SemanticSelfModel T) :
    ∀ t, M.inspect t ≠ (fun x => ¬ M.inspect x x) := by
  intro t ht
  have hself := congrFun ht t
  simp at hself

/-- No type, finite or infinite, admits a complete propositional self-model. -/
theorem no_complete_semantic_self_model (T : Type u) :
    ¬ ∃ M : SemanticSelfModel T, M.Complete := by
  rintro ⟨M, hcomplete⟩
  obtain ⟨t, ht⟩ := hcomplete (fun x => ¬ M.inspect x x)
  exact diagonal_predicate_omitted M t ht

/-- More generally, complete naming of `B`-valued observations forces every
endomorphism of `B` to possess a fixed point. -/
theorem complete_observation_forces_fixed_point {T B : Type u}
    (name : T → (T → B)) (hname : Surjective name) (g : B → B) :
    ∃ b, g b = b := by
  exact lawvere_fixed_point name hname g

/-- Quantifier polarity for the reflective hierarchy. -/
inductive Polarity where
  | universal
  | existential
  deriving DecidableEq

/-- Duality exchanges universal and existential quantification. -/
def Polarity.dual : Polarity → Polarity
  | .universal => .existential
  | .existential => .universal

/-- Reflective codes with explicit self-binding and quantifier layers. -/
inductive ReflectiveCode (Atom : Type u) where
  | atom : Atom → ReflectiveCode Atom
  | truth : ReflectiveCode Atom
  | falsity : ReflectiveCode Atom
  | conj : ReflectiveCode Atom → ReflectiveCode Atom → ReflectiveCode Atom
  | neg : ReflectiveCode Atom → ReflectiveCode Atom
  | quant : Polarity → ReflectiveCode Atom → ReflectiveCode Atom
  | self : ReflectiveCode Atom → ReflectiveCode Atom
  deriving DecidableEq

/-- Quantifier rank, with self-binding counted as a genuine recursive layer. -/
def ReflectiveCode.rank {Atom : Type u} : ReflectiveCode Atom → Nat
  | .atom _ | .truth | .falsity => 0
  | .conj A B => max A.rank B.rank
  | .neg A => A.rank
  | .quant _ A => A.rank + 1
  | .self A => A.rank + 1

/-- De Morgan duality on reflective codes. -/
def ReflectiveCode.dual {Atom : Type u} : ReflectiveCode Atom → ReflectiveCode Atom
  | .atom a => .neg (.atom a)
  | .truth => .falsity
  | .falsity => .truth
  | .conj A B => .neg (.conj A.dual B.dual)
  | .neg A => A
  | .quant p A => .quant p.dual A.dual
  | .self A => .self A.dual

/-- Polarity duality is involutive. -/
theorem Polarity.dual_dual (p : Polarity) : p.dual.dual = p := by
  cases p <;> rfl

/-- Dualization preserves every finite level of the reflective hierarchy. -/
theorem ReflectiveCode.rank_dual {Atom : Type u} (A : ReflectiveCode Atom) :
    A.dual.rank = A.rank := by
  induction A with
  | atom a => rfl
  | truth => rfl
  | falsity => rfl
  | conj A B ihA ihB => simp [ReflectiveCode.dual, ReflectiveCode.rank, ihA, ihB]
  | neg A ih => simp [ReflectiveCode.dual, ReflectiveCode.rank]
  | quant p A ih => simp [ReflectiveCode.dual, ReflectiveCode.rank, ih]
  | self A ih => simp [ReflectiveCode.dual, ReflectiveCode.rank, ih]

/-- Canonical alternating towers, beginning with an atomic code. -/
def alternatingTower (a : Atom) : Nat → ReflectiveCode Atom
  | 0 => .atom a
  | n + 1 => .quant (if Even n then .universal else .existential)
      (alternatingTower a n)

/-- The canonical tower at level `n` has exactly rank `n`. -/
theorem alternatingTower_rank (a : Atom) (n : Nat) :
    (alternatingTower a n).rank = n := by
  induction n with
  | zero => rfl
  | succ n ih =>
      change (alternatingTower a n).rank + 1 = n + 1
      omega

/-- Distinct levels of the alternating hierarchy contain distinct canonical
codes. -/
theorem alternatingTower_injective (a : Atom) :
    Function.Injective (alternatingTower a) := by
  intro m n hmn
  have h_rank : (alternatingTower a m).rank = (alternatingTower a n).rank :=
    congrArg ReflectiveCode.rank hmn
  simpa only [alternatingTower_rank] using h_rank

/-- Reflective syntax has unbounded finite rank. -/
theorem reflective_rank_unbounded (a : Atom) :
    ∀ n, ∃ A : ReflectiveCode Atom, A.rank > n := by
  intro n
  refine ⟨alternatingTower a (n + 1), ?_⟩
  rw [alternatingTower_rank]
  omega

/-- Combining diagonal semantics with hierarchy syntax: every finite syntactic
rank is inhabited, while every semantic self-model omits a single predicate. -/
theorem hierarchy_and_diagonal_boundary (T : Type u)
    (M : SemanticSelfModel T) :
    (∀ n, ∃ A : ReflectiveCode PUnit, A.rank = n) ∧
      (∃ P : T → Prop, ∀ t, M.inspect t ≠ P) := by
  constructor
  · intro n
    exact ⟨alternatingTower PUnit.unit n, alternatingTower_rank PUnit.unit n⟩
  · exact ⟨fun x => ¬ M.inspect x x, diagonal_predicate_omitted M⟩

end RecursiveTypeFixedPoints