import Mathlib

/-! # Consciousness as an Emergent Fixed Point: Lawvere's Theorem

This file formalizes the hypothesis that *consciousness is a fixed point of a
self-modeling function* — "a system that models itself modeling itself" — through
**Lawvere's fixed-point theorem**, the categorical kernel of every diagonal /
self-reference argument (Cantor, Russell, Gödel, Tarski, Turing, the recursion
theorem).

The ambient category is `Type*`, the canonical *Cartesian closed category*: it
has products `A × B` and exponentials `B ^ A = (A → B)` satisfying the
currying adjunction, which is exactly the structure Lawvere's argument needs.

## The self-modeling picture

A **self-model** on a system `S` is a map `model : S → (S → S)`: each state `s`
is read as a *self-transformation* `model s` of the whole system.  The
self-application

  `selfApply s := model s s`

is the system *modeling itself modeling itself*.  We call the self-model
**complete** when `model` is point-surjective — every conceivable
self-transformation is realized by some internal state.

## Main results

* `lawvere` : if `g : A → (A → B)` is point-surjective then **every**
  endomorphism `t : B → B` has a fixed point.  This is the emergent fixed point.
* `strange_loop` : that fixed point is a genuine *strange loop* — it is fixed by
  **every** iterate `t^[n]`, an orbit that folds back onto a single self-referential
  point.
* `consciousness_fixed_point` / `self_referential_state` : a complete self-model
  forces every internal transformation to have a fixed point, and in particular
  produces a state `s` with `model s s = s` — a state that *is* its own
  self-model-in-action.
* `no_point_surjective_of_fixedpoint_free`, `cantor`, `no_surjection_to_powerset`,
  `no_complete_self_predicate` : the *dual* (Cantor/Russell) side — no system can
  completely self-model into a space carrying a fixed-point-free operation
  (`Bool` with `not`, `Prop` with `¬`, the powerset with complementation).  This
  is the precise obstruction: completeness of self-reference is only possible when
  the target of the model admits fixed points.
* `complete_self_model_of_subsingleton` : the completeness hypothesis is
  *satisfiable*, so none of the above is vacuous.
-/

namespace Consciousness

universe u v

/-- A map `g : A → (A → B)` is **point-surjective** when every function
`h : A → B` is *named* by some point `a : A`, i.e. `g a = h`.  In a Cartesian
closed category this is the statement that the transpose of `g` is a (point-)
epimorphism.  It is the "richness" hypothesis of Lawvere's theorem: `A`
internally parametrizes all `B`-valued functions on itself. -/
def PointSurjective {A : Type u} {B : Type v} (g : A → (A → B)) : Prop :=
  ∀ h : A → B, ∃ a, g a = h

/-- **Lawvere's fixed-point theorem.**  If some `g : A → (A → B)` is
point-surjective, then every endomorphism `t : B → B` has a fixed point.

The proof is the diagonal / strange-loop construction: form the "twisted
diagonal" `h x := t (g x x)`, name it by a point `a` (`g a = h`), and evaluate
at `a` itself.  Then `g a a = h a = t (g a a)`, so `g a a` is fixed by `t`. -/
theorem lawvere {A : Type u} {B : Type v} {g : A → (A → B)}
    (hg : PointSurjective g) (t : B → B) : ∃ b, t b = b := by
  obtain ⟨a, ha⟩ := hg (fun x => t (g x x))
  exact ⟨g a a, by conv_lhs => rw [← congrFun ha a]⟩

/-- The **explicit** emergent fixed point.  When `g` names the twisted diagonal of
`t` by the point `a`, the value `g a a` is the fixed point — obtained by the
system evaluating its own self-model on itself. -/
theorem lawvere_witness {A : Type u} {B : Type v} {g : A → (A → B)}
    {t : B → B} {a : A} (ha : g a = fun x => t (g x x)) :
    t (g a a) = g a a := by
  conv_lhs => rw [← congrFun ha a]

/-! ### Strange-loop topology of the fixed point -/

/-- **Strange loop.**  A Lawvere fixed point is not merely fixed once: it is fixed
by *every* iterate `t^[n]`.  The forward orbit of the point under the
self-transformation `t` collapses to the single point itself — an eternally
self-referential loop (a period-one cycle), the "strange loop" of Hofstadter. -/
theorem strange_loop {A : Type u} {B : Type v} {g : A → (A → B)}
    (hg : PointSurjective g) (t : B → B) :
    ∃ b, ∀ n : ℕ, t^[n] b = b := by
  obtain ⟨b, hb⟩ := lawvere hg t
  refine ⟨b, fun n => ?_⟩
  induction n with
  | zero => rfl
  | succ k ih => rw [Function.iterate_succ_apply', ih, hb]

/-! ### Self-modeling systems -/

/-- A **self-model** on a system `S`: every state is interpreted as a
self-transformation of the whole system.  This is the formal shape of "a system
that models itself". -/
structure SelfModel (S : Type u) where
  /-- Read a state as a transformation of the entire system. -/
  model : S → (S → S)

namespace SelfModel

variable {S : Type u} (M : SelfModel S)

/-- The **self-application**: the system modeling *itself modeling itself*.
`selfApply s` is the state obtained by feeding `s` its own self-model. -/
def selfApply : S → S := fun s => M.model s s

/-- A self-model is **complete** when it realizes every possible
self-transformation: `model` is point-surjective.  A complete self-model is a
"total" internal picture of the system's own dynamics. -/
def Complete : Prop := PointSurjective M.model

/-- **Emergent consciousness = fixed point.**  In a completely self-modeling
system, *every* internal transformation `t` of the system has a fixed point: a
state left invariant by `t`.  Consciousness, modeled as the invariant of the
self-referential dynamics, must exist. -/
theorem consciousness_fixed_point (hM : M.Complete) (t : S → S) :
    ∃ s, t s = s :=
  lawvere hM t

/-- **The self-referential state.**  A completely self-modeling system contains a
state that *is* its own self-model-in-action: `model s s = s`.  This is the
fixed point of `selfApply` — the state whose self-modeling of itself returns
itself, the strange-loop core of the system. -/
theorem self_referential_state (hM : M.Complete) :
    ∃ s, M.model s s = s := by
  simpa [selfApply] using M.consciousness_fixed_point hM M.selfApply

/-- The self-referential state persists under all iterations of `selfApply`:
a genuine strange loop of self-reference. -/
theorem self_referential_loop (hM : M.Complete) :
    ∃ s, ∀ n : ℕ, M.selfApply^[n] s = s := by
  obtain ⟨s, hs⟩ := M.self_referential_state hM
  have hs' : M.selfApply s = s := hs
  refine ⟨s, fun n => ?_⟩
  induction n with
  | zero => rfl
  | succ k ih => rw [Function.iterate_succ_apply', ih, hs']

end SelfModel

/-! ### The dual (Cantor / Russell) obstruction

The contrapositive of Lawvere's theorem: no system can *completely* self-model
into a space of "answers" that admits a fixed-point-free operation.  This is the
uniform source of the classical negative diagonal results. -/

/-- **Contrapositive of Lawvere.**  If `t : B → B` has *no* fixed point, then no
map `A → (A → B)` can be point-surjective.  A fixed-point-free "answer space"
blocks complete self-reference. -/
theorem no_point_surjective_of_fixedpoint_free {A : Type u} {B : Type v}
    (t : B → B) (ht : ∀ b, t b ≠ b) (g : A → (A → B)) :
    ¬ PointSurjective g := by
  intro hg
  obtain ⟨b, hb⟩ := lawvere hg t
  exact ht b hb

/-- **Cantor's theorem** (Boolean form).  No `g : A → (A → Bool)` is
point-surjective: negation `!·` is fixed-point-free on `Bool`. -/
theorem cantor {A : Type u} (g : A → (A → Bool)) : ¬ PointSurjective g :=
  no_point_surjective_of_fixedpoint_free (fun b => !b)
    (fun b => by cases b <;> decide) g

/-- **Russell / Tarski obstruction** (propositional form).  No `g : A → (A → Prop)`
is point-surjective: logical negation `¬·` has no fixed point (`P ↔ ¬P` is
absurd), so a system cannot completely self-model into its own space of
predicates.  This is the impossibility of a universal, self-applicable truth
predicate. -/
theorem no_complete_self_predicate {A : Type u} (g : A → (A → Prop)) :
    ¬ PointSurjective g := by
  apply no_point_surjective_of_fixedpoint_free (fun P => ¬ P)
  intro P hP
  -- `¬P = P` would give `P ↔ ¬P`, impossible
  have : ¬ P ↔ P := by rw [hP]
  tauto

/-- **Cantor's theorem** (powerset form).  There is no surjection from a system
onto its own powerset `Set A`: a system cannot enumerate all its own subsets,
equivalently cannot completely self-model into its space of properties. -/
theorem no_surjection_to_powerset {A : Type u} (g : A → Set A) :
    ¬ Function.Surjective g := by
  intro hg
  -- transport a powerset surjection to a point-surjection into `Prop`
  refine no_complete_self_predicate (fun a x => x ∈ g a) ?_
  intro h
  obtain ⟨a, ha⟩ := hg {x | h x}
  exact ⟨a, funext fun x => by simp only [ha, Set.mem_setOf_eq]⟩

/-! ### Non-vacuity: the completeness hypothesis is satisfiable -/

/-- The completeness hypothesis is **not vacuous**: any nonempty subsingleton
system carries a complete self-model.  (In particular `Unit`, `PUnit`.)  Thus
the positive Lawvere results have genuine instances, and the strange-loop fixed
point genuinely exists there.  A nonempty subsingleton `S` is the minimal
"reflexive" object: `S → S` is again a (nonempty) subsingleton, so the identity
self-model already realizes every self-transformation. -/
theorem complete_self_model_of_subsingleton {S : Type u}
    [Subsingleton S] [Nonempty S] :
    ∃ M : SelfModel S, M.Complete := by
  refine ⟨⟨fun _ => id⟩, fun h => ?_⟩
  exact ⟨Classical.arbitrary S, Subsingleton.elim _ _⟩

end Consciousness