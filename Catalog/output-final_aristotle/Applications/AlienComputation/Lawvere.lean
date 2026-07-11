import Mathlib

/-!
# The universal core of diagonalization: Lawvere's fixed-point theorem

**Research theme: Computational Complexity of Alien Civilizations.**

A recurring claim in the philosophy of computation is that *any* technological
civilization — regardless of its biological or physical substrate — must
rediscover the same structural obstructions to computation.  The purpose of this
file is to isolate the single mathematical fact that underlies *all* of the
classical obstructions (Cantor's theorem, the undecidability of the halting
problem, Gödel's first incompleteness theorem, Tarski's undefinability of truth,
Russell's paradox): **Lawvere's fixed-point theorem**.

Lawvere's theorem is a statement of pure function theory.  It mentions no Turing
machines, no bits, no physical resources — only a type `A` of "codes", a type
`B` of "answers", and a way `φ : A → (A → B)` of indexing `A`-parameterised
answer-functions by codes.  Because it is substrate-free, the same theorem is
available to any civilization that can express the notion of a function.  This is
the precise sense in which the diagonal argument is *universal*.

## Main results

* `AlienComputation.lawvere` : if some indexing `φ : A → (A → B)` is
  *point-surjective* then every endofunction `f : B → B` has a fixed point.
* `AlienComputation.no_pointSurjective_of_fixpointFree` : the contrapositive —
  a fixed-point-free `f : B → B` forbids any point-surjective indexing.
* `AlienComputation.cantor_bool` : no map `A → (A → Bool)` is surjective
  (Cantor's theorem, the `Bool`-valued diagonal).
* `AlienComputation.cantor_pow` : the `Bool`-power `A → Bool` is strictly larger
  than `A` (no surjection, but a canonical injection exists).
-/

namespace AlienComputation

universe u v

/-- An indexing `φ : A → (A → B)` is **point-surjective** when every
`A`-parameterised answer function `g : A → B` is named by some code `a : A`,
i.e. `φ a = g`.  This is the abstract form of "the model has a program for every
behaviour" / "the coding scheme is complete". -/
def PointSurjective {A : Type u} {B : Type v} (φ : A → (A → B)) : Prop :=
  ∀ g : A → B, ∃ a : A, φ a = g

/-- **Lawvere's fixed-point theorem.**  If a type `A` admits a point-surjective
indexing `φ : A → (A → B)` of its own answer-functions, then *every* endofunction
`f : B → B` has a fixed point.

This is the load-bearing lemma of diagonalization: the "self-application" `φ a a`
is the diagonal, and `f` is the transformation the diagonal is asked to evade. -/
theorem lawvere {A : Type u} {B : Type v} (φ : A → (A → B))
    (hφ : PointSurjective φ) (f : B → B) : ∃ b : B, f b = b := by
  obtain ⟨a, ha⟩ := hφ (fun x => f (φ x x))
  refine ⟨φ a a, ?_⟩
  have h := congrFun ha a
  simpa using h.symm

/-- **Contrapositive of Lawvere (the abstract diagonal argument).**  If some
answer-transformation `f : B → B` has *no* fixed point, then no indexing of
`A`'s answer-functions by `A` can be point-surjective.  Every classical
diagonalization is an instance of this statement. -/
theorem no_pointSurjective_of_fixpointFree {A : Type u} {B : Type v}
    (f : B → B) (hf : ∀ b : B, f b ≠ b) (φ : A → (A → B)) :
    ¬ PointSurjective φ := by
  intro hφ
  obtain ⟨b, hb⟩ := lawvere φ hφ f
  exact hf b hb

/-- Boolean negation has no fixed point.  This is the *only* substrate-specific
input to the `Bool`-valued diagonal argument, and it is a two-element triviality
that any civilization possessing a notion of "yes/no" has access to. -/
theorem not_fixpointFree : ∀ b : Bool, (!b) ≠ b := by decide

/-- **Cantor's theorem, Boolean form.**  No indexing `φ : A → (A → Bool)` is
point-surjective: there is always a decision behaviour that no code realises.
Substrate-free, hence forced on every civilization. -/
theorem no_pointSurjective_bool {A : Type u} (φ : A → (A → Bool)) :
    ¬ PointSurjective φ :=
  no_pointSurjective_of_fixpointFree (A := A) (fun b => !b) not_fixpointFree φ

/-- A `Function.Surjective` map to `A → Bool` is in particular point-surjective. -/
theorem pointSurjective_of_surjective {A : Type u} {B : Type v} {φ : A → (A → B)}
    (h : Function.Surjective φ) : PointSurjective φ :=
  fun g => h g

/-- **Cantor's theorem.**  No function `A → (A → Bool)` is surjective; the space
of decision procedures on `A` is strictly richer than `A` itself. -/
theorem cantor_bool {A : Type u} (φ : A → (A → Bool)) : ¬ Function.Surjective φ :=
  fun h => no_pointSurjective_bool φ (pointSurjective_of_surjective h)

/-- The canonical embedding `A ↪ (A → Bool)` sending `a` to its "indicator"
decision procedure `fun x => decide (x = a)`.  Combined with `cantor_bool` this
witnesses that `A → Bool` is *strictly* larger than `A`. -/
noncomputable def indicator {A : Type u} (a : A) : A → Bool :=
  fun x => by classical exact decide (x = a)

theorem indicator_injective {A : Type u} :
    Function.Injective (indicator (A := A)) := by
  classical
  intro a b h
  have hb : indicator a b = indicator b b := by rw [h]
  have : (decide (b = a) : Bool) = decide (b = b) := hb
  have hba : b = a := by simpa using this
  exact hba.symm

/-- **The `Bool`-power is strictly larger.**  There is an injection `A ↪ A → Bool`
but no surjection `A ↠ A → Bool`.  This is the single "step" of the universal
complexity hierarchy developed in `Hierarchy.lean`. -/
theorem cantor_pow {A : Type u} :
    (∃ f : A → (A → Bool), Function.Injective f) ∧
      (∀ φ : A → (A → Bool), ¬ Function.Surjective φ) :=
  ⟨⟨indicator, indicator_injective⟩, cantor_bool⟩

end AlienComputation