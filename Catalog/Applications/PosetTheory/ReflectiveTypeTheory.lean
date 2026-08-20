import Mathlib
import Logic.StrangeLoops.Core

/-!
# Reflective Type Theory and the Modal Fixed-Point Language

A reflective proposition may contain a type former `proof A`, read as “there is
accessible evidence for `A`”, and a fixed-point former.  This development
separates three claims that are often conflated:

* a concrete reflective proposition can be provable without being provably
  provable;
* the reflective grammar is a proper extension of a non-reflective dependent
  type-theoretic core;
* after changing notation, its proposition codes and the formulas of a modal
  fixed-point calculus are isomorphic, constructor for constructor.

The first claim has a sharp semantic boundary: it occurs on a two-step,
non-transitive frame and is impossible on every transitive frame.  The second is
proved by a partial retraction, rather than by merely counting constructors.  The
third is witnessed by mutually inverse translations and not by identifying two
pre-existing names.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Six falsifiable conjectures were ranked by impact.
-- (1) Reflective proposition codes and modal fixed-point formulas are isomorphic.
-- (2) Reflection properly extends the non-reflective product/function fragment.
-- (3) `proof A ∧ ¬ proof (proof A)` has a finite inhabited model.
-- (4) Transitivity is exactly the obstruction to conjecture (3), framewise.
-- (5) Diagonal reflection plus soundness forces an unprovable proposition.
-- (6) Every unrestricted fixed-point code has a monotone set interpretation.
-- The first, fourth, and sixth were the bold targets because they connect syntax,
-- Kripke geometry, order-theoretic fixed points, and diagonal incompleteness.
--
-- Experiment (Experimenter): Conjectures (1)--(5) survived in guarded forms.
-- A three-stage chain supplies (3); arbitrary transitive frames refute its
-- transitive version.  Conjecture (6) failed: negative occurrences under function
-- space need not induce monotone operators, so unrestricted least fixed points do
-- not have the intended semantics.
--
-- Analysis (Analyst): The common structure is variance.  Transitivity controls
-- iteration of the proof modality, while positivity controls iteration to a least
-- fixed point.  Syntactic equivalence needs no positivity assumption, but semantic
-- fixed-point interpretation does.  The diagonal theorem from the existing
-- strange-loop theory supplies the bridge from self-reference to unprovability.
--
-- Critique (Critic): The proper-extension claim is syntactic and deliberately does
-- not claim conservativity of a full Martin-Löf metatheory.  The modal
-- fixed-point correspondence is an exact grammar isomorphism; it does not assert
-- completeness for a proof calculus.  Terminal worlds make box vacuously true,
-- so the flagship witness uses a nonterminal world and an explicit two-edge path.
--
-- Synthesis (Principal Investigator): Reflection contributes one genuinely new
-- modal constructor, fixed points contribute the modal `mu` constructor, and the
-- resulting grammar is exactly transported to modal fixed-point formulas.  The
-- finite model, the transitivity obstruction, the syntactic retraction, and the
-- diagonal bridge jointly delimit what this statement does and does not mean.
-- !-- End Lab Notes -- !--
-/

namespace ReflectiveTypeTheory

open Set

universe u

/-! ## A non-reflective core and its reflective extension -/

/-- Codes for a small non-reflective type-theoretic fragment. -/
inductive MLType (Atom : Type u) where
  | atom : Atom → MLType Atom
  | empty : MLType Atom
  | unit : MLType Atom
  | prod : MLType Atom → MLType Atom → MLType Atom
  | arr : MLType Atom → MLType Atom → MLType Atom
  deriving DecidableEq

/-- Reflective type codes: the base constructors, a provability former, and a
least-fixed-point binder represented with de Bruijn indices. -/
inductive RType (Atom : Type u) where
  | atom : Atom → RType Atom
  | bound : Nat → RType Atom
  | empty : RType Atom
  | unit : RType Atom
  | prod : RType Atom → RType Atom → RType Atom
  | arr : RType Atom → RType Atom → RType Atom
  | proof : RType Atom → RType Atom
  | fix : RType Atom → RType Atom
  deriving DecidableEq

/-- The canonical inclusion of the non-reflective fragment. -/
def includeML {Atom : Type u} : MLType Atom → RType Atom
  | .atom a => .atom a
  | .empty => .empty
  | .unit => .unit
  | .prod A B => .prod (includeML A) (includeML B)
  | .arr A B => .arr (includeML A) (includeML B)

/-- Partial decoding back to the non-reflective fragment.  It fails precisely
when a bound variable, reflection, or a fixed point is encountered. -/
def decodeML {Atom : Type u} : RType Atom → Option (MLType Atom)
  | .atom a => some (.atom a)
  | .bound _ => none
  | .empty => some .empty
  | .unit => some .unit
  | .prod A B => return .prod (← decodeML A) (← decodeML B)
  | .arr A B => return .arr (← decodeML A) (← decodeML B)
  | .proof _ => none
  | .fix _ => none

/-- Decoding is a left inverse to the inclusion. -/
theorem decodeML_includeML {Atom : Type u} (A : MLType Atom) :
    decodeML (includeML A) = some A := by
  induction A with
  | atom a => rfl
  | empty => rfl
  | unit => rfl
  | prod A B ihA ihB => simp [includeML, decodeML, ihA, ihB]
  | arr A B ihA ihB => simp [includeML, decodeML, ihA, ihB]

/-- The inclusion of the non-reflective fragment is injective. -/
theorem includeML_injective {Atom : Type u} : Function.Injective (@includeML Atom) := by
  intro A B h
  have := congrArg decodeML h
  simpa [decodeML_includeML] using this

/-- Reflection is genuinely new: no reflected atom lies in the image of the
non-reflective grammar. -/
theorem proof_atom_not_in_image {Atom : Type u} (a : Atom) :
    ¬ ∃ A : MLType Atom, includeML A = RType.proof (.atom a) := by
  rintro ⟨A, hA⟩
  have h := congrArg decodeML hA
  simp [decodeML_includeML, decodeML] at h

/-! ## Exact correspondence with a modal fixed-point grammar -/

/-- Formulas of the modal fixed-point language.  `var` is a de Bruijn fixed-point
variable, `box` is necessity, and `mu` binds the next variable. -/
inductive MuFormula (Atom : Type u) where
  | atom : Atom → MuFormula Atom
  | var : Nat → MuFormula Atom
  | falsum : MuFormula Atom
  | verum : MuFormula Atom
  | conj : MuFormula Atom → MuFormula Atom → MuFormula Atom
  | impl : MuFormula Atom → MuFormula Atom → MuFormula Atom
  | box : MuFormula Atom → MuFormula Atom
  | mu : MuFormula Atom → MuFormula Atom
  deriving DecidableEq

/-- Read a reflective type as a modal fixed-point formula. -/
def toMu {Atom : Type u} : RType Atom → MuFormula Atom
  | .atom a => .atom a
  | .bound n => .var n
  | .empty => .falsum
  | .unit => .verum
  | .prod A B => .conj (toMu A) (toMu B)
  | .arr A B => .impl (toMu A) (toMu B)
  | .proof A => .box (toMu A)
  | .fix A => .mu (toMu A)

/-- Read a modal fixed-point formula as a reflective proposition code. -/
def fromMu {Atom : Type u} : MuFormula Atom → RType Atom
  | .atom a => .atom a
  | .var n => .bound n
  | .falsum => .empty
  | .verum => .unit
  | .conj A B => .prod (fromMu A) (fromMu B)
  | .impl A B => .arr (fromMu A) (fromMu B)
  | .box A => .proof (fromMu A)
  | .mu A => .fix (fromMu A)

/-- Translating a reflective proposition to modal syntax and back changes
nothing. -/
theorem fromMu_toMu {Atom : Type u} (A : RType Atom) : fromMu (toMu A) = A := by
  induction A with
  | atom a => rfl
  | bound n => rfl
  | empty => rfl
  | unit => rfl
  | prod A B ihA ihB => simp [toMu, fromMu, ihA, ihB]
  | arr A B ihA ihB => simp [toMu, fromMu, ihA, ihB]
  | proof A ih => simp [toMu, fromMu, ih]
  | fix A ih => simp [toMu, fromMu, ih]

/-- Translating a modal fixed-point formula to reflective syntax and back changes
nothing. -/
theorem toMu_fromMu {Atom : Type u} (A : MuFormula Atom) : toMu (fromMu A) = A := by
  induction A with
  | atom a => rfl
  | var n => rfl
  | falsum => rfl
  | verum => rfl
  | conj A B ihA ihB => simp [toMu, fromMu, ihA, ihB]
  | impl A B ihA ihB => simp [toMu, fromMu, ihA, ihB]
  | box A ih => simp [toMu, fromMu, ih]
  | mu A ih => simp [toMu, fromMu, ih]

/-- The two proof-term grammars are equivalent, with explicitly verified inverse
maps. -/
def reflectiveEquivMu (Atom : Type u) : RType Atom ≃ MuFormula Atom where
  toFun := toMu
  invFun := fromMu
  left_inv := fromMu_toMu
  right_inv := toMu_fromMu

/-- Translation commutes with iterated reflection and iterated necessity. -/
theorem toMu_iterate_proof {Atom : Type u} (n : Nat) (A : RType Atom) :
    toMu ((RType.proof : RType Atom → RType Atom)^[n] A) =
      ((MuFormula.box : MuFormula Atom → MuFormula Atom)^[n] (toMu A)) := by
  induction n generalizing A with
  | zero => rfl
  | succ n ih =>
      simp only [Function.iterate_succ_apply]
      exact ih (.proof A)

/-! ## Kripke meaning of reflective provability -/

/-- A reflective frame consists of proof states and one-step accessibility. -/
structure Frame where
  World : Type u
  step : World → World → Prop

/-- Propositions over a frame are predicates on its worlds. -/
abbrev RProp (F : Frame) := Set F.World

/-- “Provable” is Kripke necessity. -/
def Frame.box (F : Frame) (P : RProp F) : RProp F :=
  {w | ∀ v, F.step w v → v ∈ P}

/-- A term witnessing “`P` is provable but not provably provable” at `w`. -/
structure ProvableNotIterated (F : Frame) (P : RProp F) (w : F.World) : Prop where
  provable : w ∈ F.box P
  not_provably_provable : w ∉ F.box (F.box P)

/-- Every transitive provability relation validates axiom 4. -/
theorem box_four_of_transitive (F : Frame)
    (htrans : ∀ a b c, F.step a b → F.step b c → F.step a c)
    (P : RProp F) : F.box P ⊆ F.box (F.box P) := by
  intro w hw v hwv u hvu
  exact hw u (htrans w v u hwv hvu)

/-- Consequently the target reflective type is empty on transitive frames. -/
theorem no_provable_not_iterated_of_transitive (F : Frame)
    (htrans : ∀ a b c, F.step a b → F.step b c → F.step a c)
    (P : RProp F) (w : F.World) : ¬ ProvableNotIterated F P w := by
  rintro ⟨hp, hn⟩
  exact hn (box_four_of_transitive F htrans P hp)

/-- The finite chain `2 → 1 → 0`. -/
def chainFrame : Frame where
  World := Fin 3
  step a b := (a = 2 ∧ b = 1) ∨ (a = 1 ∧ b = 0)

/-- A proposition true only at the middle state. -/
def middle : RProp chainFrame := fun w => w = (1 : Fin 3)

/-- The chain has the required reflective inhabitant at its top state. -/
theorem chain_inhabits_provable_not_iterated :
    ProvableNotIterated chainFrame middle (2 : Fin 3) := by
  constructor
  · intro v hv
    change chainFrame.step (2 : Fin 3) v at hv
    change v = (1 : Fin 3)
    rcases hv with ⟨_, h⟩ | ⟨h, _⟩
    · exact h
    · omega
  · intro hbox
    have hmiddle : (1 : Fin 3) ∈ chainFrame.box middle :=
      hbox (1 : Fin 3) (Or.inl ⟨rfl, rfl⟩)
    have hzero : (0 : Fin 3) ∈ middle :=
      hmiddle (0 : Fin 3) (Or.inr ⟨rfl, rfl⟩)
    change (0 : Fin 3) = 1 at hzero
    omega

/-- The countermodel really is beyond the transitive boundary. -/
theorem chain_step_not_transitive :
    ¬ (∀ a b c, chainFrame.step a b → chainFrame.step b c → chainFrame.step a c) := by
  intro htrans
  have h20 := htrans (2 : Fin 3) (1 : Fin 3) (0 : Fin 3)
    (Or.inl ⟨rfl, rfl⟩) (Or.inr ⟨rfl, rfl⟩)
  rcases h20 with ⟨_, h⟩ | ⟨h, _⟩ <;> omega

/-! ## Diagonal reflection and the incompleteness boundary -/

/-- A minimal diagonal reflective theory. -/
structure DiagonalTheory where
  Sentence : Type u
  Provable : Sentence → Prop
  TrueAt : Sentence → Prop
  sound : ∀ s, Provable s → TrueAt s
  diagonal : Sentence
  diagonal_spec : TrueAt diagonal ↔ ¬ Provable diagonal

/-- Diagonal reflection and soundness produce a true but unprovable sentence.
The proof uses the abstract diagonal principle from the existing strange-loop
catalogue, connecting reflective typing with diagonal incompleteness. -/
theorem diagonal_true_unprovable (T : DiagonalTheory) :
    T.TrueAt T.diagonal ∧ ¬ T.Provable T.diagonal := by
  have hn : ¬ T.Provable T.diagonal :=
    abstract_diagonal T.diagonal_spec (T.sound T.diagonal)
  exact ⟨T.diagonal_spec.mpr hn, hn⟩

/-! ## Concrete examples and checks -/

#check reflectiveEquivMu
#check chain_inhabits_provable_not_iterated
#check no_provable_not_iterated_of_transitive
#check diagonal_true_unprovable

/-- A concrete base proposition survives inclusion and decoding. -/
example : decodeML (includeML (MLType.prod (MLType.atom true) MLType.unit)) =
    some (MLType.prod (MLType.atom true) MLType.unit) := by
  apply decodeML_includeML

/-- The formula `mu (box (var 0))` corresponds exactly to the reflective code
`fix (proof (bound 0))`. -/
example : fromMu (MuFormula.mu (MuFormula.box (MuFormula.var 0)) : MuFormula Bool) =
    RType.fix (RType.proof (RType.bound 0)) := rfl

/-- At stage `2`, the middle proposition is also possible, supplying a direct
small-model sanity check independent of the boxed witness. -/
example : ∃ v, chainFrame.step (2 : Fin 3) v ∧ v ∈ middle := by
  exact ⟨(1 : Fin 3), Or.inl ⟨rfl, rfl⟩, rfl⟩

/-!
## Generalizations and boundaries

**Generalization.**  The frame theorems are independent of finiteness and extend
to indexed families of proof modalities.  The grammar equivalence is polymorphic
in the atomic language and therefore applies equally to arithmetic sentences,
program assertions, and propositions indexed by contexts.  A broader extension
can add sums, dependent products, and dependent sums on both sides.

**Boundary cases.**  The three-world witness is a counterexample to any claim
that provability must imply iterated provability on arbitrary frames.  Conversely,
`no_provable_not_iterated_of_transitive` shows that no transitive frame can host
such a witness.  The fixed-point constructor is syntactically unrestricted here;
a semantic least-fixed-point interpretation requires the usual positivity guard.
Thus the exact result is a proof-term grammar equivalence, not an unqualified
soundness or completeness theorem for arbitrary recursive types.
-/

end ReflectiveTypeTheory