/-
# Isomorphisms of Meaning: structural invariance and semantic underdetermination

A Kripke model has worlds, atomic observations, a transition relation, and a valuation.
An isomorphism simultaneously renames worlds and atoms while preserving both transition and
valuation.  The central invariance theorem proves, by induction on formulas, that every modal
observation is transported along such an isomorphism.

The final construction separates this precise structural claim from the stronger philosophical
word “meaning.”  Two one-world models agree on every formula and are structurally isomorphic,
yet carry unequal external interpretations.  Thus the chosen language cannot recover arbitrary
extra-structural interpretation; this is a theorem about a specified observational language,
not an unrestricted claim about all conceivable languages.

The conjugation operation on model isomorphisms is an “isomorphism of isomorphisms”: changing
coordinates at source and target transports an analogy while preserving its commuting laws.
This groupoid calculus models the structural core of Copycat-style analogy: correspondences may
be composed or re-represented without changing invariant observations.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (1) modal truth is invariant under simultaneous renaming of atoms and
worlds; (2) valid theories are therefore invariant; (3) correspondences themselves admit a
conjugation action by changes of coordinates; (4) composition of analogies preserves truth;
(5, bold) no formula in the observational language can recover an unconstrained external
interpretation; (6, bold) structurally identical models can support opposite interpretations;
(7, bold) analogy networks should form a groupoid whose path-independent observations descend
to orbit invariants.

Experiment (Experimenter): formulas were tested against a two-sorted model isomorphism.  The
box case is decisive: inverse transport of an arbitrary target successor supplies the source
successor needed by the induction hypothesis.  Conjugation was then tested by expanding the
three equivalences and checking relation and valuation preservation in both directions.

Analysis (Analyst): conjectures (1)--(6) survive with an exact boundary.  The phrase “no formal
system” is too broad: a language enlarged by a predicate naming the interpretation distinguishes
the examples immediately.  The correct result quantifies over every formula of the fixed modal
language.  Conjecture (7) survives here at the groupoid-law level; descent on arbitrary analogy
networks remains open.

Critique (Critic): the main theorem is not definitional: it requires structural induction and a
nontrivial reversal through the world equivalence in the modal case.  The counterexample is not
vacuous: the worlds exist, all formulas are compared, and the external labels are provably
unequal.  External interpretation is deliberately absent from the model signature, making the
limitation explicit rather than hidden.

Synthesis (Principal Investigator): structural equivalence preserves modal truth, equivalences
can themselves be transported coherently by conjugation, and truth preservation composes.
Nevertheless, arbitrary annotations outside the observational signature do not descend along
structural isomorphism.  This cleanly separates invariance of truth from invariance of meaning.
-- !-- End Lab Notes -- !--
-/

import Mathlib
import Catalog.Applications.ProofTheoryAndLogic.MultiverseModalForcing

namespace IsomorphismsOfMeaning

universe u v u' v' u'' v''

/-- Modal formulas over a type of atomic observations. -/
inductive Formula (Atom : Type u) where
  | atom : Atom → Formula Atom
  | falsum : Formula Atom
  | imp : Formula Atom → Formula Atom → Formula Atom
  | box : Formula Atom → Formula Atom
  deriving DecidableEq

namespace Formula

/-- Uniform renaming of every atomic observation in a formula. -/
def rename {A : Type u} {B : Type v} (e : A ≃ B) : Formula A → Formula B
  | atom a => atom (e a)
  | falsum => falsum
  | imp p q => imp (rename e p) (rename e q)
  | box p => box (rename e p)

end Formula

/-- A relational model with atomic observations at worlds. -/
structure Model (Atom : Type u) (World : Type v) where
  step : World → World → Prop
  holds : World → Atom → Prop

/-- Satisfaction in a relational model. -/
def Satisfies {A : Type u} {W : Type v} (M : Model A W) (w : W) : Formula A → Prop
  | .atom a => M.holds w a
  | .falsum => False
  | .imp p q => Satisfies M w p → Satisfies M w q
  | .box p => ∀ x, M.step w x → Satisfies M x p

/-- An isomorphism of models renames both observational vocabulary and worlds. -/
structure ModelIso {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    (M : Model A W) (N : Model B X) where
  atoms : A ≃ B
  worlds : W ≃ X
  step_iff : ∀ w x, N.step (worlds w) (worlds x) ↔ M.step w x
  holds_iff : ∀ w a, N.holds (worlds w) (atoms a) ↔ M.holds w a

namespace ModelIso

/-- Identity structural analogy. -/
def refl {A : Type u} {W : Type v} (M : Model A W) : ModelIso M M where
  atoms := Equiv.refl A
  worlds := Equiv.refl W
  step_iff := by intros; rfl
  holds_iff := by intros; rfl

/-- Reverse a structural analogy. -/
def symm {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    {M : Model A W} {N : Model B X} (e : ModelIso M N) : ModelIso N M where
  atoms := e.atoms.symm
  worlds := e.worlds.symm
  step_iff := by
    intro x y
    simpa using (e.step_iff (e.worlds.symm x) (e.worlds.symm y)).symm
  holds_iff := by
    intro x b
    simpa using (e.holds_iff (e.worlds.symm x) (e.atoms.symm b)).symm

/-- Composition of structural analogies. -/
def trans {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    {C : Type u''} {Y : Type v''} {M : Model A W} {N : Model B X} {P : Model C Y}
    (e : ModelIso M N) (f : ModelIso N P) : ModelIso M P where
  atoms := e.atoms.trans f.atoms
  worlds := e.worlds.trans f.worlds
  step_iff := by
    intro w x
    exact (f.step_iff (e.worlds w) (e.worlds x)).trans (e.step_iff w x)
  holds_iff := by
    intro w a
    exact (f.holds_iff (e.worlds w) (e.atoms a)).trans (e.holds_iff w a)

/-- Changing coordinates at both ends transports an isomorphism.  This is the
precise groupoid-level “isomorphism of isomorphisms.” -/
def conjugate {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    {C : Type u''} {Y : Type v''} {M : Model A W} {N : Model B X}
    {M' : Model C Y} {N' : Model C Y} (left : ModelIso M M')
    (e : ModelIso M N) (right : ModelIso N N') : ModelIso M' N' :=
  (symm left).trans (e.trans right)

end ModelIso

/-
**Structural invariance of truth.** Every modal formula has the same truth value after
simultaneously transporting its vocabulary, world, transition relation, and valuation.
-/
theorem satisfies_rename_iff {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    {M : Model A W} {N : Model B X} (e : ModelIso M N) (w : W) (p : Formula A) :
    Satisfies N (e.worlds w) (p.rename e.atoms) ↔ Satisfies M w p := by
  revert w;
  induction p;
  · exact fun w => e.holds_iff w _;
  · aesop;
  · grind +locals;
  · intro w;
    constructor <;> intro h;
    · intro x hx; have := h ( e.worlds x ) ; simp_all +decide [ ModelIso.step_iff ] ;
    · exact fun x hx => by rename_i k hk; specialize hk ( e.worlds.symm x ) ; have := e.step_iff w ( e.worlds.symm x ) ; aesop;

/-
Isomorphic models validate exactly the transported formulas.
-/
theorem valid_rename_iff {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    {M : Model A W} {N : Model B X} (e : ModelIso M N) (p : Formula A) :
    (∀ x, Satisfies N x (p.rename e.atoms)) ↔ ∀ w, Satisfies M w p := by
  constructor;
  · exact fun h w => satisfies_rename_iff e w p |>.1 ( h _ );
  · exact fun h x => by simpa using satisfies_rename_iff e ( e.worlds.symm x ) p |>.2 ( h _ ) ;

/-
Truth transport is stable under a chain of two analogies.
-/
theorem analogy_composition_preserves_truth
    {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    {C : Type u''} {Y : Type v''} {M : Model A W} {N : Model B X} {P : Model C Y}
    (e : ModelIso M N) (f : ModelIso N P) (w : W) (p : Formula A) :
    Satisfies P ((e.trans f).worlds w) (p.rename (e.trans f).atoms) ↔ Satisfies M w p := by
  convert satisfies_rename_iff ( e.trans f ) w p using 1

/-
**Isomorphism of isomorphisms preserves truth.** Re-expressing an analogy in new
coordinates at both endpoints leaves every transported observation invariant.
-/
theorem conjugated_analogy_preserves_truth
    {A : Type u} {W : Type v} {B : Type u'} {X : Type v'}
    {C : Type u''} {Y : Type v''} {M : Model A W} {N : Model B X}
    {M' N' : Model C Y} (left : ModelIso M M') (e : ModelIso M N)
    (right : ModelIso N N') (w : Y) (p : Formula C) :
    Satisfies N' ((ModelIso.conjugate left e right).worlds w)
        (p.rename (ModelIso.conjugate left e right).atoms) ↔ Satisfies M' w p := by
  convert satisfies_rename_iff ( ModelIso.symm left |> ModelIso.trans <| e |> ModelIso.trans <| right ) w p using 1

/-- An interpretation layer deliberately external to the model signature. -/
structure InterpretedModel (Atom : Type u) (World : Type v) (Meaning : Type*) where
  model : Model Atom World
  interpretation : World → Meaning

/-- A structural isomorphism respects meaning only when the external interpretation commutes. -/
def MeaningCompatible {A : Type u} {W : Type v} {B : Type u'} {X : Type v'} {D : Type*}
    (I : InterpretedModel A W D) (J : InterpretedModel B X D)
    (e : ModelIso I.model J.model) : Prop :=
  ∀ w, J.interpretation (e.worlds w) = I.interpretation w

/-- The one-world, one-atom model in which the sole atom is observed. -/
def singletonModel : Model Unit Unit where
  step _ _ := True
  holds _ _ := True

/-- Two interpretations with identical formal structure and opposite external labels. -/
def interpretationFalse : InterpretedModel Unit Unit Bool :=
  ⟨singletonModel, fun _ => false⟩

def interpretationTrue : InterpretedModel Unit Unit Bool :=
  ⟨singletonModel, fun _ => true⟩

/-
**Truth does not determine external meaning.** The two interpreted models have an
isomorphism under which every modal formula agrees, while their external interpretations
disagree and the isomorphism is not meaning-compatible.
-/
theorem structurally_indistinguishable_meaning_collision :
    ∃ e : ModelIso interpretationFalse.model interpretationTrue.model,
      (∀ p : Formula Unit,
        Satisfies interpretationTrue.model (e.worlds ()) (p.rename e.atoms) ↔
          Satisfies interpretationFalse.model () p) ∧
      interpretationTrue.interpretation (e.worlds ()) ≠
        interpretationFalse.interpretation () ∧
      ¬ MeaningCompatible interpretationFalse interpretationTrue e := by
  refine' ⟨ _, _, _, _ ⟩;
  refine' ⟨ Equiv.refl _, Equiv.refl _, _, _ ⟩;
  all_goals norm_num [ MeaningCompatible, interpretationTrue, interpretationFalse ];
  intro p;
  convert satisfies_rename_iff ( ModelIso.refl _ ) () p

/-
Connection to the existing modal forcing semantics: renaming atoms in a world commutes
with atomic evaluation.  This anchors the abstract transport theorem in the catalog's
Kripke-semantic account of forcing.
-/
theorem forcing_atom_change_of_coordinates {A : Type u} {B : Type v}
    (e : A ≃ B) (w : MultiverseModalForcing.World A) (a : A)
    (R : MultiverseModalForcing.World A → MultiverseModalForcing.World A → Prop)
    (M : MultiverseModalForcing.Multiverse A) :
    MultiverseModalForcing.meval R M w (.atom a) ↔
      (fun b : B => w (e.symm b)) (e a) = true := by
  aesop

end IsomorphismsOfMeaning