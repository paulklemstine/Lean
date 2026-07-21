import Mathlib
import Logic.PhysicsConsistency.Incompleteness

/-!
# Zombies and Qualia: Fibres of Functional Observation

A functional description is represented by a map `F : X → B` from total states to
observable behaviours.  Experience is a second coordinate `E : X → Bool`.  Two states
in one fibre of `F` are functionally indistinguishable; an oriented experiential gap is
a pair in one fibre whose first member is aware and whose second is not.

The central result is deliberately conditional.  Functional data alone cannot imply
that a zombie exists: the required mathematical hypothesis is that experience varies
inside a functional fibre.  In the split model `B × Bool`, that hypothesis is exact,
and every aware state has a unique void counterpart.  The space of oriented gaps is
then equivalent to `B`.

The final bridge compares this fibre geometry with the abstract Gödel gap developed in
`Logic.PhysicsConsistency.Incompleteness`.  An indexed Gödel gap records a behaviour
label together with the consistency sentence of the standard GL model and proofs that
neither it nor its negation is provable.  This gap space is also equivalent to `B`;
therefore the experiential and incompleteness gaps are isomorphic as labelled spaces.
This is an isomorphism of the explicit gap structures, not an identification of
phenomenology with arithmetic syntax.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven falsifiable conjectures were ranked by structural
impact. (1) A split state space has a canonical fibre-preserving qualia involution.
(2) Every aware split state has exactly one experientially void functional twin.
(3) Oriented experiential gaps are classified by behavioural profiles. (4) Pulling a
metric back along behaviour assigns zero functional separation to every zombie pair.
(5) The oriented gap space is isomorphic to a behaviour-indexed Gödel independence
space. (6) Functional observables determine experience exactly when experience is
constant on every fibre. (7) Without a fibre-splitting premise, zombie existence
follows from functional organization alone.

Experiment (Experimenter): Conjectures (1)--(6) survive in the definitions below.
The split involution, unique-zombie theorem, fibre classification, zero-distance
result, Gödel-gap classification, and factorization criterion are all established.
Conjecture (7) fails: a constant-true experience map is a countermodel, so the central
existence statement must retain an explicit variation or splitting hypothesis.

Analysis (Analyst): Three views coincide.  Geometrically, the gap is a nontrivial fibre
of the observation map.  Algebraically, it is the Boolean factor forgotten by the
projection `B × Bool → B`.  Logically, it is a labelled sentence with neither polarity
provable.  The common classifier `B` yields the bridge, while the internal two-sided
contrast supplies its orientation.

Critique (Critic): No conclusion is extracted from functional equivalence alone.
The countermodel theorem exposes that hidden assumption.  The Gödel side uses the
concrete consistent and sigma-sound standard GL model rather than postulating an
independent sentence.  The bridge preserves labels and orientation, but makes no claim
that subjective experience literally is formal provability.

Synthesis (Principal Investigator): The strongest defensible theorem is a
representation result: under an explicit Boolean qualia splitting, zombie twins are
unique, their functional pullback distance is zero, and their moduli space is
isomorphic to a behaviour-indexed Gödel independence gap.  Fibre constancy precisely
marks the boundary where experience is recoverable from functional data.
-- !-- Lab Notes -- !--
-/

namespace ZombiesAndQualia

open ProofSystemCollapse
open PhysicsConsistency PhysicsConsistency.Form

/-- Two total states are functionally identical when observation gives the same
behavioural profile. -/
def FunctionallyIdentical {X B : Type*} (F : X → B) (x y : X) : Prop := F x = F y

/-- An oriented zombie relation: `x` is aware, `z` is void, and both have exactly the
same functional description. -/
def ZombieTwin {X B : Type*} (F : X → B) (E : X → Bool) (x z : X) : Prop :=
  FunctionallyIdentical F x z ∧ E x = true ∧ E z = false

/-- The canonical split model separates behavioural profile from a Boolean experience
coordinate. -/
def splitBehavior {B : Type*} : B × Bool → B := Prod.fst

/-- Experience in the split model is its Boolean coordinate. -/
def splitExperience {B : Type*} : B × Bool → Bool := Prod.snd

/-- Toggle the experiential coordinate without changing any functional coordinate. -/
def qualiaFlip {B : Type*} (x : B × Bool) : B × Bool := (x.1, !x.2)

/-- The qualia flip is a fibre-preserving involution. -/
theorem qualiaFlip_involution {B : Type*} (x : B × Bool) :
    splitBehavior (qualiaFlip (qualiaFlip x)) = splitBehavior x ∧
      qualiaFlip (qualiaFlip x) = x := by
  rcases x with ⟨b, q⟩
  cases q <;> constructor <;> rfl

/-- Every aware state in the split model has a unique experientially void state in its
functional fibre. -/
theorem unique_zombie_twin {B : Type*} (x : B × Bool)
    (hx : splitExperience x = true) :
    ∃! z, ZombieTwin splitBehavior splitExperience x z := by
  rcases x with ⟨b, q⟩
  cases q <;> simp [splitExperience] at hx
  refine ⟨(b, false), ?_, ?_⟩
  · exact ⟨rfl, rfl, rfl⟩
  · rintro ⟨b', q'⟩ ⟨hb, _, hq⟩
    change b = b' at hb
    change q' = false at hq
    subst b'
    subst q'
    rfl

/-- Oriented gaps in the split model: a pair of functionally identical states with
opposite experiential orientation. -/
def ExperientialGap (B : Type*) :=
  {p : (B × Bool) × (B × Bool) //
    ZombieTwin splitBehavior splitExperience p.1 p.2}

/-- Every oriented experiential gap is completely classified by its behavioural
profile. -/
def experientialGapEquiv (B : Type*) : ExperientialGap B ≃ B where
  toFun p := p.1.1.1
  invFun b := ⟨((b, true), (b, false)), ⟨rfl, rfl, rfl⟩⟩
  left_inv := by
    rintro ⟨⟨⟨b, q⟩, ⟨b', q'⟩⟩, hb, hq, hq'⟩
    simp only [splitBehavior, FunctionallyIdentical, splitExperience] at hb hq hq'
    subst b'
    subst q
    subst q'
    rfl
  right_inv := by
    intro b
    rfl

/-- A behavioural metric pulls back to total states.  Every zombie pair has zero
functional distance, despite its experiential contrast. -/
theorem zombie_functional_distance_zero {X B : Type*} [PseudoMetricSpace B]
    (F : X → B) (E : X → Bool) {x z : X} (h : ZombieTwin F E x z) :
    dist (F x) (F z) = 0 := by
  rcases h with ⟨hF, _, _⟩
  rw [hF, dist_self]

/-- An indexed Gödel gap pairs a behavioural label with the standard model's
consistency sentence and its two-sided unprovability certificate. -/
def IndexedGodelGap (B : Type*) (i : ℕ) :=
  {p : B × Form //
    p.2 = Con i ∧
      (¬ Provable stdSys p.2 ∧ ¬ Provable stdSys (neg p.2))}

/-- The standard GL model supplies exactly one canonical Gödel gap over each label. -/
def indexedGodelGapEquiv (B : Type*) (i : ℕ) : IndexedGodelGap B i ≃ B where
  toFun p := p.1.1
  invFun b := ⟨(b, Con i), rfl, stdSys_con_independent i⟩
  left_inv := by
    rintro ⟨⟨b, a⟩, ha, hind⟩
    change a = Con i at ha
    subst a
    rfl
  right_inv := by
    intro b
    rfl

/-- **Experiential–Gödel gap isomorphism.**  For every behavioural space and theory
index, oriented split-model zombie gaps and labelled Gödel independence gaps are
isomorphic.  The isomorphism preserves the common behavioural label. -/
def experientialGodelGapEquiv (B : Type*) (i : ℕ) :
    ExperientialGap B ≃ IndexedGodelGap B i :=
  (experientialGapEquiv B).trans (indexedGodelGapEquiv B i).symm

/-- The bridge sends a zombie gap to the independent consistency sentence while
retaining its functional profile. -/
theorem experientialGodelGap_preserves_label (B : Type*) (i : ℕ)
    (g : ExperientialGap B) :
    (experientialGodelGapEquiv B i g).1.1 = g.1.1.1 ∧
      (experientialGodelGapEquiv B i g).1.2 = Con i := by
  constructor <;> rfl

/-- Experience is recoverable from functional data precisely when it is constant on
functional fibres.  This identifies the exact boundary at which a functional account
can determine the experiential coordinate. -/
theorem experience_factors_through_iff {X B : Type*} (F : X → B) (E : X → Bool) :
    (∃ e : Set.range F → Bool, ∀ x, E x = e ⟨F x, ⟨x, rfl⟩⟩) ↔
      ∀ x y, FunctionallyIdentical F x y → E x = E y := by
  constructor
  · rintro ⟨e, he⟩ x y hxy
    rw [he x, he y]
    have hsub : (⟨F x, ⟨x, rfl⟩⟩ : Set.range F) = ⟨F y, ⟨y, rfl⟩⟩ := by
      apply Subtype.ext
      exact hxy
    rw [hsub]
  · intro hconst
    let e : Set.range F → Bool := fun b => E (Classical.choose b.2)
    refine ⟨e, ?_⟩
    intro x
    apply hconst
    exact (Classical.choose_spec (show F x ∈ Set.range F from ⟨x, rfl⟩)).symm

/-- Functional organization alone does not force a zombie.  If experience is
constantly present, no state has an experientially void twin, regardless of the
observation map. -/
theorem functionalism_alone_countermodel {X B : Type*} (F : X → B) (x : X) :
    ¬ ∃ z, ZombieTwin F (fun _ => true) x z := by
  rintro ⟨z, _, _, hz⟩
  cases hz

end ZombiesAndQualia