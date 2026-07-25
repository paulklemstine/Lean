import Mathlib
import Novelty.HilbertSpace.MultiverseModalForcing

/-!
# Anti-axioms as finite relational set universes

Negating a first-order axiom is not the same as adopting a replacement axiom.  This
study isolates three claims that can be tested without conflating those operations.
A universe is represented by a type of set-codes and a membership relation.  The
results identify the exact observational content of failed extensionality, establish
a hereditary-finiteness theorem for finite universes, and classify the compatibility
of extensionality and membership cycles under that finiteness condition.

The often-repeated claim that failure of Choice makes every set measurable is not a
logical consequence of the negation alone: measurability is additional structure and
requires separate hypotheses.  Accordingly no such implication is asserted here.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer). Six falsifiable targets were ranked by impact. (1, famous-
problem subtask) A bare negation of Choice implies universal real measurability.
(2, cross-domain) Failed extensionality is precisely nontrivial kernel data for the
map from set-codes to membership observations. (3, cross-domain) Passing to those
observations restores extensional equality. (4, foundations/combinatorics) every
finite relational universe is hereditarily finite, with an explicit cardinal bound
on every transitive membership closure. (5, cross-domain) finite anti-Infinity is
compatible with each combination of extensionality and acyclicity. (6, bold
foundations) anti-Extensionality forces non-well-founded membership.

EXPERIMENT (Experimenter). Two-element empty-membership and one-element cyclic
universes separate extensionality from acyclicity. Their product-pattern witnesses
all four combinations. Cardinal bounds replace unsupported claims about the full
first-order negation of Infinity.

ANALYSIS (Analyst). Targets (2)--(5) survive. Targets (1) and (6) fail at the level
of logical form: Choice does not define a sigma-algebra, while duplicate codes can
have no membership edges at all. The unifying invariant is the observation map
`x ↦ {z | z ∈ x}`; anti-Extensionality is exactly its failure of injectivity.

CRITIQUE (Critic). “Not-Infinity yields hereditarily finite set theory” is too strong
unless the ambient axioms and the meaning of finite are fixed. The guarded theorem
uses a finite carrier and proves finiteness of the full reflexive-transitive closure,
not merely of immediate members. The four witnesses prevent hidden implications
between extensionality and acyclicity. No result relies on a vacuous premise.

SYNTHESIS (Principal Investigator). The kernel characterization, extensional
observation shadow, quantitative hereditary-finiteness bound, impossibility of an
injective omega-chain, and four-way compatibility theorem form a single finite-model
classification. The imported modal-forcing development supplies the surrounding
catalog connection: the same relational semantics discipline distinguishes frame
conditions from propositions evaluated on frames.
-- !-- End Lab Notes -- !--
-/

namespace AntiMathematics

open Classical

/-- A relational universe of set-codes. `Mem x y` reads “`x` is a member of `y`”. -/
structure SetUniverse where
  Obj : Type
  Mem : Obj → Obj → Prop

namespace SetUniverse

/-- The observable extension of a set-code. -/
def observation (U : SetUniverse) (x : U.Obj) : Set U.Obj := {z | U.Mem z x}

/-- Extensionality says that equal membership observations determine equal codes. -/
def Extensional (U : SetUniverse) : Prop :=
  ∀ x y, (∀ z, U.Mem z x ↔ U.Mem z y) → x = y

/-- Anti-extensionality is the literal negation of Extensionality. -/
def AntiExtensional (U : SetUniverse) : Prop := ¬ U.Extensional

/-- Two codes are observationally indistinguishable when they have the same members. -/
def Indistinguishable (U : SetUniverse) (x y : U.Obj) : Prop :=
  ∀ z, U.Mem z x ↔ U.Mem z y

/-- Membership acyclicity, the finite relational core of Foundation. -/
def Acyclic (U : SetUniverse) : Prop := ∀ x, ¬ Relation.TransGen U.Mem x x

/-- The reflexive-transitive hereditary membership closure of a code. -/
def hereditaryClosure (U : SetUniverse) (x : U.Obj) : Set U.Obj :=
  {z | Relation.ReflTransGen U.Mem z x}

/-- The observational shadow consists of extensions actually represented in `U`. -/
def Shadow (U : SetUniverse) := Set.range U.observation

/-- A set-code viewed as a Boolean world whose atoms are possible members. -/
noncomputable def membershipWorld (U : SetUniverse) (x : U.Obj) :
    MultiverseModalForcing.World U.Obj := fun z => decide (U.Mem z x)

instance (U : SetUniverse) : SetLike U.Shadow U.Obj where
  coe P := P.1
  coe_injective' := by intro P Q h; cases P; cases Q; simp_all

/-
Anti-extensionality produces two genuinely distinct but indistinguishable codes.
-/
theorem antiExtensional_iff_nontrivial_kernel (U : SetUniverse) :
    U.AntiExtensional ↔ ∃ x y, x ≠ y ∧ U.Indistinguishable x y := by
  unfold SetUniverse.AntiExtensional SetUniverse.Indistinguishable;
  unfold SetUniverse.Extensional;
  grind

/-
Extensionality is exactly injectivity of the observation map.
-/
theorem extensional_iff_observation_injective (U : SetUniverse) :
    U.Extensional ↔ Function.Injective U.observation := by
  unfold SetUniverse.Extensional Function.Injective;
  simp +decide [ Set.ext_iff, SetUniverse.observation ]

/-
Relational indistinguishability is equality of the corresponding Boolean worlds,
linking membership semantics to the catalog's Kripke-world representation.
-/
theorem indistinguishable_iff_membershipWorld_eq (U : SetUniverse) (x y : U.Obj) :
    U.Indistinguishable x y ↔ U.membershipWorld x = U.membershipWorld y := by
  simp +decide [ funext_iff, SetUniverse.Indistinguishable, SetUniverse.membershipWorld ]

/-
Equality in the observational shadow is determined by membership in the
underlying carrier; duplicate codes have disappeared.
-/
theorem shadow_extensional (U : SetUniverse) (P Q : U.Shadow)
    (h : ∀ z, z ∈ P ↔ z ∈ Q) : P = Q := by
  exact Subtype.ext <| Set.ext h

/-
Every hereditary closure in a finite universe is finite, quantitatively bounded
by the number of available set-codes.
-/
theorem hereditaryClosure_finite_bound (U : SetUniverse) [Fintype U.Obj]
    (x : U.Obj) : (U.hereditaryClosure x).ncard ≤ Fintype.card U.Obj := by
  rw [ Set.ncard_eq_toFinset_card' ];
  exact Finset.card_le_univ _

/-
A finite anti-Infinity universe admits no injective omega-indexed list of
pairwise different set-codes.
-/
theorem no_injective_omega_enumeration (U : SetUniverse) [Fintype U.Obj] :
    ¬ ∃ f : ℕ → U.Obj, Function.Injective f := by
  exact fun ⟨ f, hf ⟩ => not_injective_infinite_finite f hf

end SetUniverse

/-! ## Four finite witnesses -/

/-- Two empty set-codes: anti-extensional but acyclic. -/
def duplicateEmpty : SetUniverse := ⟨Bool, fun _ _ => False⟩

/-- One empty set-code: extensional and acyclic. -/
def singletonEmpty : SetUniverse := ⟨Unit, fun _ _ => False⟩

/-- One self-membered code: extensional but cyclic. -/
def singletonLoop : SetUniverse := ⟨Unit, fun _ _ => True⟩

/-- Two universally self/member-related codes: anti-extensional and cyclic. -/
def duplicateLoop : SetUniverse := ⟨Bool, fun _ _ => True⟩

lemma duplicateEmpty_antiExtensional : duplicateEmpty.AntiExtensional := by
  unfold SetUniverse.AntiExtensional;
  unfold SetUniverse.Extensional;
  simp +decide [ duplicateEmpty ]

lemma duplicateEmpty_acyclic : duplicateEmpty.Acyclic := by
  intro x hx;
  cases hx <;> tauto

lemma singletonEmpty_extensional : singletonEmpty.Extensional := by
  exact fun x y h => by cases x; cases y; trivial;

lemma singletonEmpty_acyclic : singletonEmpty.Acyclic := by
  intro x hx;
  cases hx <;> tauto

lemma singletonLoop_extensional : singletonLoop.Extensional := by
  exact fun x y h => by cases x; cases y; trivial;

lemma singletonLoop_not_acyclic : ¬ singletonLoop.Acyclic := by
  exact fun h => h () ( Relation.TransGen.single trivial )

lemma duplicateLoop_antiExtensional : duplicateLoop.AntiExtensional := by
  unfold SetUniverse.AntiExtensional;
  unfold duplicateLoop; simp +decide [ SetUniverse.Extensional ] ;

lemma duplicateLoop_not_acyclic : ¬ duplicateLoop.Acyclic := by
  exact fun h => h true ( Relation.TransGen.single trivial )

/-
Under finite anti-Infinity, extensionality and acyclicity are logically
independent: every Boolean combination has a concrete relational universe.
-/
theorem finite_anti_axiom_compatibility :
    (∃ U : SetUniverse, Finite U.Obj ∧ U.Extensional ∧ U.Acyclic) ∧
    (∃ U : SetUniverse, Finite U.Obj ∧ U.AntiExtensional ∧ U.Acyclic) ∧
    (∃ U : SetUniverse, Finite U.Obj ∧ U.Extensional ∧ ¬ U.Acyclic) ∧
    (∃ U : SetUniverse, Finite U.Obj ∧ U.AntiExtensional ∧ ¬ U.Acyclic) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · refine ⟨singletonEmpty, ?_,
      singletonEmpty_extensional, singletonEmpty_acyclic⟩
    change Finite Unit
    infer_instance
  · refine ⟨duplicateEmpty, ?_,
      duplicateEmpty_antiExtensional, duplicateEmpty_acyclic⟩
    change Finite Bool
    infer_instance
  · refine ⟨singletonLoop, ?_,
      singletonLoop_extensional, singletonLoop_not_acyclic⟩
    change Finite Unit
    infer_instance
  · refine ⟨duplicateLoop, ?_,
      duplicateLoop_antiExtensional, duplicateLoop_not_acyclic⟩
    change Finite Bool
    infer_instance

end AntiMathematics