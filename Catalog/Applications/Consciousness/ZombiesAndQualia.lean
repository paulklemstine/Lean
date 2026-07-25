import Mathlib
import Novelty.GameTheory.IntegratedInformation
import Logic.MindDiagonalSentences.MindVsGodel

/-!
# Zombies, qualia, and semantic incompleteness

A functional description records an externally visible profile, while an
experience model supplies an additional, potentially invisible coordinate.  The
central distinction in this chapter is between an unconditional claim about a
fixed model and a conservative-extension claim.  A fixed model need not contain
a zombie.  Nevertheless, every functional profile admits a two-sheeted extension
whose sheets are functionally identical and differ only in whether experience is
present.

The same two-sheeted construction also gives a semantic system with a true but
unaccepted code on one sheet.  For the canonical constructions, zombie witnesses
and semantic-gap witnesses are equivalent types.  Thus the asserted analogy with
incompleteness is an exact isomorphism for a specified model, not an identification
of consciousness with arithmetic and not a consequence of functional data alone.
-/

namespace ZombiesAndQualia

/-- A system with an observable functional profile and an experiential coordinate. -/
structure ExperienceModel where
  World : Type*
  Function : Type*
  Experience : Type*
  behavior : World → Function
  experience : World → Experience
  void : Experience

namespace ExperienceModel

variable (M : ExperienceModel)

/-- Functional indistinguishability forgets the experiential coordinate. -/
def FunctionalTwin (x y : M.World) : Prop := M.behavior x = M.behavior y

/-- A world is experientially nonvoid. -/
def Conscious (x : M.World) : Prop := M.experience x ≠ M.void

/-- `z` is a zombie twin of `x` when it has the same functional profile and no experience. -/
def ZombieOf (x z : M.World) : Prop := M.FunctionalTwin x z ∧ M.experience z = M.void

/-- A directional witness to the functional–experiential gap. -/
structure ZombieWitness where
  original : M.World
  zombie : M.World
  sameFunction : M.FunctionalTwin original zombie
  original_nonvoid : M.Conscious original
  zombie_void : M.experience zombie = M.void

/-
A zombie twin of a conscious world exhibits an experiential contrast hidden by behavior.
-/
theorem zombie_has_hidden_contrast {x z : M.World} (hx : M.Conscious x)
    (hz : M.ZombieOf x z) : M.FunctionalTwin x z ∧ M.experience x ≠ M.experience z := by
  grind +locals

end ExperienceModel

/-! ## The conservative two-sheeted extension -/

/-- Every experience model has a two-sheeted extension.  The Boolean sheet is
invisible to behavior; `true` retains experience and `false` is void. -/
def zombieExtension (M : ExperienceModel) : ExperienceModel where
  World := M.World × Bool
  Function := M.Function
  Experience := Option M.Experience
  behavior := fun x => M.behavior x.1
  experience := fun x => if x.2 then some (M.experience x.1) else none
  void := none

/-- The experience-preserving inclusion into the extension. -/
def alive (M : ExperienceModel) (x : M.World) : (zombieExtension M).World := (x, true)

/-- The void inclusion into the extension. -/
def zombie (M : ExperienceModel) (x : M.World) : (zombieExtension M).World := (x, false)

/-
Every world acquires a canonical functionally identical zombie in the extension.
-/
theorem extension_zombie_twin (M : ExperienceModel) (x : M.World) :
    (zombieExtension M).ZombieOf (alive M x) (zombie M x) := by
  exact ⟨ rfl, rfl ⟩

/-
The retained sheet is always nonvoid.
-/
theorem extension_alive_conscious (M : ExperienceModel) (x : M.World) :
    (zombieExtension M).Conscious (alive M x) := by
  exact ne_of_apply_ne Option.isSome ( by simp +decide [ alive, zombieExtension ] )

/-
No predicate depending only on functional behavior separates the two sheets.
In particular, any purely functional definition of consciousness inherited by
the retained copy is inherited by its zombie copy as well.
-/
theorem functional_definition_transfers_to_zombie (M : ExperienceModel)
    (P : M.Function → Prop) (x : M.World) (hx : P (M.behavior x)) :
    P ((zombieExtension M).behavior (zombie M x)) ∧
      (zombieExtension M).ZombieOf (alive M x) (zombie M x) := by
  exact ⟨hx, extension_zombie_twin M x⟩

/-
The extension simultaneously preserves the original functional profile and
creates an experientially contrasting twin.
-/
theorem conservative_extension_gap (M : ExperienceModel) (x : M.World) :
    (zombieExtension M).behavior (alive M x) = M.behavior x ∧
    (zombieExtension M).behavior (zombie M x) = M.behavior x ∧
    (zombieExtension M).experience (alive M x) ≠
      (zombieExtension M).experience (zombie M x) := by
  refine ⟨rfl, rfl, ?_⟩
  exact ((zombieExtension M).zombie_has_hidden_contrast
    (extension_alive_conscious M x) (extension_zombie_twin M x)).2

/-! ## Canonical finite-fiber model and exact gap coding -/

/-- The canonical model over profiles `X`: two worlds per profile, with presence
or absence of the unique qualitative marker. -/
def canonicalZombieModel (X : Type*) : ExperienceModel where
  World := X × Bool
  Function := X
  Experience := Option Unit
  behavior := Prod.fst
  experience := fun x => if x.2 then some () else none
  void := none

/-- A profile determines its canonical zombie witness. -/
def canonicalZombieWitness (X : Type*) (x : X) :
    (canonicalZombieModel X).ZombieWitness where
  original := (x, true)
  zombie := (x, false)
  sameFunction := rfl
  original_nonvoid := by simp [ExperienceModel.Conscious, canonicalZombieModel]
  zombie_void := by simp [canonicalZombieModel]

/-- In the canonical model, every zombie witness is uniquely determined by its
functional profile.  Hence profiles and zombie gaps are equivalent. -/
def canonicalZombieEquiv (X : Type*) :
    X ≃ (canonicalZombieModel X).ZombieWitness where
  toFun := canonicalZombieWitness X
  invFun := fun w => w.original.1
  left_inv := by
    intro x
    rfl
  right_inv := by
    rintro ⟨⟨x, b⟩, ⟨y, c⟩, sameFunction, original_nonvoid, zombie_void⟩
    change x = y at sameFunction
    change (if b then some () else none) ≠ none at original_nonvoid
    change (if c then some () else none) = none at zombie_void
    cases b <;> simp at original_nonvoid
    cases c <;> simp at zombie_void
    subst y
    rfl

/-! ## Semantic gaps -/

/-- A semantic-gap witness is true in the intended semantics but not accepted by
the system. -/
def SemanticGap {Code : Type*} (S : MindVsGodel.SemanticSystem Code) :=
  {c : Code // S.trueAt c ∧ ¬ S.accepts c}

/-- The canonical semantic system has one accepted and one unaccepted code per
profile; all codes are semantically true. -/
def canonicalSemanticSystem (X : Type*) : MindVsGodel.SemanticSystem (X × Bool) where
  accepts := fun c => c.2 = true
  trueAt := fun _ => True

/-
The canonical semantic system is sound.
-/
theorem canonicalSemantic_sound (X : Type*) :
    (canonicalSemanticSystem X).Sound := by
  exact fun x hx => trivial

/-
Every code on the unaccepted sheet is Gödelian for the canonical system.
-/
theorem canonicalSemantic_godel (X : Type*) (x : X) :
    (canonicalSemanticSystem X).IsGodelCode (x, false) := by
  unfold canonicalSemanticSystem
  simp [MindVsGodel.SemanticSystem.IsGodelCode]

/-- The abstract incompleteness theorem yields a true but unaccepted code on
 each canonical false sheet. -/
theorem canonical_godel_incompleteness (X : Type*) (x : X) :
    (canonicalSemanticSystem X).trueAt (x, false) ∧
      ¬ (canonicalSemanticSystem X).accepts (x, false) := by
  exact MindVsGodel.SemanticSystem.godel_truth_and_unrecognizability
    (canonicalSemanticSystem X) (canonicalSemantic_godel X x)
      (canonicalSemantic_sound X)

/-- Profiles are equivalent to the true-but-unaccepted witnesses of the
canonical semantic system. -/
def canonicalSemanticGapEquiv (X : Type*) :
    X ≃ SemanticGap (canonicalSemanticSystem X) where
  toFun := fun x => ⟨(x, false), by simp [canonicalSemanticSystem]⟩
  invFun := fun g => g.1.1
  left_inv := by
    intro x
    rfl
  right_inv := by
    rintro ⟨⟨x, b⟩, htrue, hnot⟩
    have hb : b = false := by
      cases b <;> simp [canonicalSemanticSystem] at hnot ⊢
    subst b
    rfl

/-- **Zombie–Gödel gap isomorphism.**  In the canonical two-sheeted models,
the type of functionally invisible experiential contrasts is equivalent to the
type of semantically true but unaccepted codes. -/
def zombieGapEquivSemanticGap (X : Type*) :
    (canonicalZombieModel X).ZombieWitness ≃
      SemanticGap (canonicalSemanticSystem X) :=
  (canonicalZombieEquiv X).symm.trans (canonicalSemanticGapEquiv X)

/-
Every canonical zombie witness corresponds under the gap isomorphism to a
true, unaccepted Gödel code.
-/
theorem zombie_maps_to_godel_gap (X : Type*)
    (w : (canonicalZombieModel X).ZombieWitness) :
    let g := zombieGapEquivSemanticGap X w
    (canonicalSemanticSystem X).trueAt g.1 ∧
      ¬ (canonicalSemanticSystem X).accepts g.1 ∧
      (canonicalSemanticSystem X).IsGodelCode g.1 := by
  obtain ⟨x, hx⟩ := w;
  convert canonicalSemantic_godel X x.1 using 1;
  unfold zombieGapEquivSemanticGap canonicalSemanticGapEquiv canonicalZombieEquiv canonicalSemanticSystem canonicalZombieModel; aesop;

/-! ## Boundary theorem: why the unguarded philosophical claim is false -/

/-- A one-world model in which all experience is void. -/
def allVoidModel : ExperienceModel where
  World := Unit
  Function := Unit
  Experience := Unit
  behavior := fun _ => ()
  experience := fun _ => ()
  void := ()

/-
The all-void model has no zombie witness because a witness requires a
nonvoid original.
-/
theorem allVoid_has_no_zombieWitness :
    IsEmpty allVoidModel.ZombieWitness := by
  constructor
  rintro ⟨original, zombieWorld, sameFunction, original_nonvoid, zombie_void⟩
  exact original_nonvoid rfl

/-
There can be no unconditional isomorphism between experiential and semantic
gaps: the all-void experiential model has no witness, while the one-profile
canonical semantic system does.
-/
theorem no_unconditional_gap_isomorphism :
    ¬ Nonempty (allVoidModel.ZombieWitness ≃
      SemanticGap (canonicalSemanticSystem Unit)) := by
  rintro ⟨ e ⟩;
  exact allVoid_has_no_zombieWitness.false ( e.symm ⟨ (Unit.unit, false), by simp [canonicalSemanticSystem] ⟩ )

/-! ## Bridge to minimum-information partitions -/

/-
A finite IIT system with at least two elements has a minimum-information
partition, while every chosen functional profile has a canonical zombie witness
and a corresponding semantic-gap witness.  This combines minimization over
functional decompositions with the orthogonal two-sheeted experiential gap.
-/
theorem mip_zombie_and_semantic_gap {n : ℕ} (S : IIT.System n) (hn : 2 ≤ n)
    {X : Type*} (x : X) :
    (∃ A ∈ IIT.parts n, S.ei A = IIT.Phi S hn) ∧
    Nonempty (canonicalZombieModel X).ZombieWitness ∧
    Nonempty (SemanticGap (canonicalSemanticSystem X)) := by
  exact ⟨ IIT.exists_MIP S hn, ⟨ canonicalZombieWitness X x ⟩, ⟨ ⟨ ( x, false ), by simp +decide [ canonicalSemanticSystem ] ⟩ ⟩ ⟩

-- !-- Lab Notes -- !--
-- Hypothesis (ranked by expected impact):
-- (1) A purely functional consciousness predicate is invariant under adding an
--     experientially void sheet, so it cannot exclude zombie twins.
-- (2) The resulting experiential gap and a true-but-unaccepted semantic gap can
--     be made isomorphic by a common two-sheeted construction.
-- (3) The isomorphism can send every zombie witness to a Gödelian code, not just
--     to an arbitrary omitted semantic truth.
-- (4) Minimum-information partitions and experiential gaps coexist without the
--     former determining the latter.
-- (5) Every fixed experience model already contains a zombie twin.
-- (6) Experiential and semantic gaps are isomorphic without any shared coding
--     or cardinality assumptions.
-- Experiment:
-- The two-sheeted extension was constructed for an arbitrary experience model.
-- A canonical profile-indexed model was then coded both as experiential worlds
-- and as semantic codes.  The IIT minimum-partition theorem was combined with
-- these constructions.  Finally, the all-void singleton model was tested against
-- the unconditional claims.
-- Analysis:
-- Conjectures (1)--(4) survive.  Conjecture (5) fails for the all-void model and
-- therefore needs the conservative-extension formulation.  Conjecture (6) is
-- false because witness types can have different cardinalities; the singleton
-- countermodel already separates empty and inhabited gap types.  The unifying
-- pattern is a forgetful map with a nontrivial fiber: behavior forgets the
-- Boolean experience sheet, while acceptance omits the false Boolean sheet.
-- Critique:
-- The extension theorem does not infer absent experience from behavior.  It
-- proves underdetermination by constructing another model.  The semantic system
-- is an abstract fixed-point model, not an arithmetization theorem.  The gap
-- isomorphism is guarded by explicit canonical constructions, and the boundary
-- theorem rules out presenting it as universal.  None of the headline results
-- reduces to a definitional equality or a finite decision procedure.
-- Synthesis:
-- Functional data alone is compatible with a conservative zombie extension;
-- canonical zombie witnesses are classified exactly by functional profiles;
-- the same profiles classify true, unaccepted Gödelian codes; and an exact
-- equivalence connects the two witness spaces.  IIT minimization concerns the
-- functional cut landscape and can coexist with this independent hidden fiber.
-- !-- End Lab Notes -- !--

end ZombiesAndQualia