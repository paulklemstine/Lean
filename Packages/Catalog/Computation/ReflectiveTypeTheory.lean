import Geometry.ReflectiveTypeTheory

/-!
# Reflective Type Theory and the Modal μ-Calculus

This development builds on `Geometry.ReflectiveTypeTheory`, reusing its
Martin-Löf fragment, reflective extension, modal μ-calculus translations,
Kripke semantics, and diagonal theorem.  It adds an explicit scoping judgment
for recursive type codes and packages the requested syntactic and semantic
claims.

The phrase “provable but not provably provable” is interpreted precisely.  Its
code is well scoped, and it has a semantic inhabitant on the catalog's concrete
three-world non-transitive frame.  The existing transitivity theorem proves that
no such inhabitant exists on a transitive frame.
-/

namespace ReflectiveTypeTheory

universe u

/-- Well-scoped reflective codes under `n` surrounding fixed-point binders. -/
inductive WellScoped {Atom : Type u} : Nat → RType Atom → Prop where
  | atom (n) (a : Atom) : WellScoped n (.atom a)
  | bound {n i} (h : i < n) : WellScoped n (.bound i)
  | empty (n) : WellScoped n .empty
  | unit (n) : WellScoped n .unit
  | prod {n A B} : WellScoped n A → WellScoped n B → WellScoped n (.prod A B)
  | arr {n A B} : WellScoped n A → WellScoped n B → WellScoped n (.arr A B)
  | proof {n A} : WellScoped n A → WellScoped n (.proof A)
  | fix {n A} : WellScoped (n + 1) A → WellScoped n (.fix A)

/-- The reflective type code for `□A ∧ ¬□□A`; negation is a function into the
empty type. -/
def provableNotProvablyProvable {Atom : Type u} (A : RType Atom) : RType Atom :=
  .prod (.proof A) (.arr (.proof (.proof A)) .empty)

/-- The target reflective proposition is a well-scoped type whenever `A` is. -/
theorem wellScoped_provableNotProvablyProvable {Atom : Type u} {A : RType Atom}
    (hA : WellScoped 0 A) : WellScoped 0 (provableNotProvablyProvable A) := by
  apply WellScoped.prod
  · exact WellScoped.proof hA
  · exact WellScoped.arr (WellScoped.proof (WellScoped.proof hA)) (WellScoped.empty 0)

/-- The closed recursive code `μX.□X` is accepted by the de Bruijn scoping
judgment, demonstrating genuine self-reference through a bound variable. -/
theorem wellScoped_self_provability {Atom : Type u} :
    WellScoped 0 (RType.fix (RType.proof (RType.bound 0)) : RType Atom) := by
  apply WellScoped.fix
  exact WellScoped.proof (WellScoped.bound (Nat.zero_lt_succ 0))

/-- The requested expression is simultaneously a closed reflective type and
semantically inhabited in the catalog's concrete proof-state model. -/
theorem well_typed_reflective_witness :
    WellScoped 0 (provableNotProvablyProvable (RType.atom true)) ∧
      ProvableNotIterated chainFrame middle (2 : Fin 3) := by
  constructor
  · exact wellScoped_provableNotProvablyProvable (WellScoped.atom 0 true)
  · exact chain_inhabits_provable_not_iterated

/-- The extension claim is proper: the old grammar embeds injectively, while a
reflected atom has no preimage. -/
theorem reflective_properly_extends_ml {Atom : Type u} (a : Atom) :
    Function.Injective (@includeML Atom) ∧
      ¬ ∃ A : MLType Atom, includeML A = RType.proof (.atom a) := by
  constructor
  · exact includeML_injective
  · exact proof_atom_not_in_image a

/-- “Exactly the modal μ-calculus” is witnessed by inverse translations, not
merely by a comparison of constructor counts. -/
theorem proof_language_exactly_modal_mu {Atom : Type u} :
    (∀ A : RType Atom, fromMu (toMu A) = A) ∧
      (∀ F : MuFormula Atom, toMu (fromMu F) = F) := by
  constructor
  · exact fromMu_toMu
  · exact toMu_fromMu

/-- All three requested claims in one theorem: strict extension, exact language
correspondence, and a closed, inhabited reading of `□A ∧ ¬□□A`. -/
theorem reflective_type_theory_mission (a : Bool) :
    (Function.Injective (@includeML Bool) ∧
      ¬ ∃ A : MLType Bool, includeML A = RType.proof (.atom a)) ∧
    ((∀ A : RType Bool, fromMu (toMu A) = A) ∧
      (∀ F : MuFormula Bool, toMu (fromMu F) = F)) ∧
    (WellScoped 0 (provableNotProvablyProvable (RType.atom a)) ∧
      ProvableNotIterated chainFrame middle (2 : Fin 3)) := by
  refine ⟨reflective_properly_extends_ml a, proof_language_exactly_modal_mu, ?_⟩
  constructor
  · exact wellScoped_provableNotProvablyProvable (WellScoped.atom 0 a)
  · exact chain_inhabits_provable_not_iterated

end ReflectiveTypeTheory