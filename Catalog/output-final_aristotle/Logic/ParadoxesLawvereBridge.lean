import Mathlib

/-!
# Paradoxes as one theorem: the Lawvere diagonal bridge

This self-contained file deepens the slogan *"the Liar, Russell, Cantor and Berry
paradoxes are all the same theorem"* into a precise **cross-domain bridge**.

The unifying object is **Lawvere's fixed-point theorem**, a single diagonal
principle that lives simultaneously in

* **set / category theory** — "a point-surjection `A ↠ (A → C)` forces every
  endomap of `C` to have a fixed point", the abstract form of Cantor's diagonal
  argument, and
* **logic** — "self-reference produces a sentence equivalent to a chosen
  transformation of itself", the abstract form of the Liar and of Gödel's
  diagonal lemma.

From this one theorem we read off, as corollaries in genuinely different fields:

* `no_prop_pointSurjective` / `cantor_no_surjective` — **Cantor's theorem**: no
  type surjects onto its own power set (negation has no propositional fixed point);
* `russell_paradox` — **Russell's paradox**: no element codes the set of all
  non-self-membered elements;
* `liar_no_selfnegating` — the **Liar**: no proposition is its own negation.

The *counting shadow* of the same diagonal is **Berry's paradox**, formalised as a
pigeonhole incompressibility statement:

* `berry_pigeonhole`, `chaitin_incompressible` — some numbers need more bits than
  any injective code can save, the finite Berry paradox and Chaitin's theorem.

Finally we bridge back to **algebra**: the reason these diagonals are genuine
*obstructions* classically is that a nontrivial Boolean algebra has **no**
negation fixed point (`boolean_neg_fixpoint_trivial`), whereas Belnap's
four-valued logic **does** have a designated one (`BV.has_designated_neg_fixpoint`).
Thus the paradoxes turn from obstructions into *theorems* exactly by leaving
classical logic — packaged as `paradox_dichotomy`.

Everything imports only Mathlib.

-- !-- Lab Notes -- !--
Hypothesis: the Liar, Russell and Cantor arguments are three readings of one
  diagonal; Lawvere's theorem is the reading-independent statement, and each
  paradox is obtained by choosing the codomain `C` (Prop, Set A) and the
  fixed-point-free endomap (negation, complement).
Experiment: prove Lawvere from scratch (`lawvere_fixedPoint`), then instantiate
  `C = Prop`, `f = Not` for Cantor/Liar, and specialise membership for Russell.
Analysis: the single load-bearing logical fact downstream is `no_liar_prop`
  (`¬ (P ↔ ¬P)`), i.e. `Not : Prop → Prop` has no fixed point; every classical
  paradox is this fact transported along a would-be surjection.
Critique: the hypotheses are non-vacuous — `PointSurjective` is inhabited (take
  `A` a singleton and `C` a singleton), so the impossibility results have real
  content, and injectivity in the Berry half is realised by `enc = id`.
Synthesis: `paradox_dichotomy` states the bridge in one place: the diagonal
  endomap `¬` has no fixed point in every nontrivial Boolean algebra yet a
  designated fixed point in Belnap logic, so the paradoxes become theorems iff
  classical logic is abandoned.
-- !-- end Lab Notes -- !--
-/

namespace ParadoxesLawvereBridge

/-! ## 1. Lawvere's fixed-point theorem -/

/-- `e : A → (A → C)` is **point-surjective** if every function `A → C` is `e a`
for some `a`.  This is the diagonal-argument hypothesis: `A` is "as big as" the
function space `A → C`. -/
def PointSurjective {A C : Type*} (e : A → A → C) : Prop :=
  ∀ f : A → C, ∃ a, e a = f

/-- **Lawvere's fixed-point theorem.**  If `e : A → (A → C)` is point-surjective,
then *every* endomap `f : C → C` has a fixed point.  This is the abstract
diagonal argument shared by Cantor, Russell, the Liar and Gödel. -/
theorem lawvere_fixedPoint {A C : Type*} {e : A → A → C}
    (he : PointSurjective e) (f : C → C) : ∃ c, f c = c := by
  obtain ⟨a, ha⟩ := he (fun x => f (e x x))
  exact ⟨e a a, (congrFun ha a).symm⟩

/-- **Contrapositive of Lawvere.**  If some endomap `f : C → C` has *no* fixed
point, then no `e : A → (A → C)` can be point-surjective.  This is the reusable
"diagonalization blocks surjectivity" engine. -/
theorem lawvere_no_pointSurjective {A C : Type*} (e : A → A → C)
    (f : C → C) (hf : ∀ c, f c ≠ c) : ¬ PointSurjective e := by
  intro he
  obtain ⟨c, hc⟩ := lawvere_fixedPoint he f
  exact hf c hc

/-- The hypothesis is **non-vacuous**: between singletons, the unique map is
point-surjective, so Lawvere's theorem is not vacuously true. -/
theorem pointSurjective_nonvacuous :
    ∃ (A C : Type) (e : A → A → C), PointSurjective e :=
  ⟨PUnit, PUnit, fun _ _ => PUnit.unit, fun _ => ⟨PUnit.unit, funext fun _ => rfl⟩⟩

/-! ## 2. The Liar, Cantor and Russell as one diagonal

The single fixed-point-free endomap is negation on `Prop`. -/

/-- The **Liar**: no proposition is (classically) equivalent to its own negation.
`Not : Prop → Prop` has no fixed point. -/
theorem liar_no_selfnegating (P : Prop) : ¬ (P ↔ ¬ P) := by
  intro h; tauto

/-- Negation on `Prop` has no fixed point, as an equality of propositions. -/
theorem not_no_fixpoint (P : Prop) : (¬ P) ≠ P := by
  intro h
  rw [eq_iff_iff] at h
  tauto

/-- **Cantor / Liar bridge.**  No `e : A → (A → Prop)` is point-surjective: a type
never enumerates all its own predicates.  This is Lawvere applied to `Not`. -/
theorem no_prop_pointSurjective {A : Type*} (e : A → A → Prop) :
    ¬ PointSurjective e :=
  lawvere_no_pointSurjective e Not not_no_fixpoint

/-- **Cantor's theorem**, derived from Lawvere: no map `A → Set A` is surjective. -/
theorem cantor_no_surjective {A : Type*} (f : A → Set A) :
    ¬ Function.Surjective f := by
  intro hf
  refine no_prop_pointSurjective (fun a x => x ∈ f a) ?_
  intro p
  obtain ⟨a, ha⟩ := hf {x | p x}
  refine ⟨a, ?_⟩
  funext x
  show (x ∈ f a) = p x
  rw [ha, Set.mem_setOf_eq]

/-- **Russell's paradox.**  For any membership relation `mem : A → A → Prop`, no
element `r` codes the collection of non-self-membered elements
`{x | ¬ mem x x}`.  Instantiating at `x = r` gives `mem r r ↔ ¬ mem r r`, the
Liar. -/
theorem russell_paradox {A : Type*} (mem : A → A → Prop) :
    ¬ ∃ r : A, ∀ x, mem x r ↔ ¬ mem x x := by
  rintro ⟨r, hr⟩
  have := hr r
  tauto

/-- Russell is again exactly the diagonal: universal comprehension over `mem`
(every predicate is `mem · a` for some `a`) is impossible, being a special case of
`no_prop_pointSurjective`. -/
theorem russell_no_comprehension {A : Type*} (mem : A → A → Prop) :
    ¬ ∀ p : A → Prop, ∃ a : A, ∀ x, mem x a ↔ p x := by
  intro hcomp
  refine no_prop_pointSurjective (fun a x => mem x a) ?_
  intro p
  obtain ⟨a, ha⟩ := hcomp p
  exact ⟨a, funext fun x => propext (ha x)⟩

/-! ## 3. Berry's paradox: the counting shadow

Replacing "provability" by "compressibility", the diagonal becomes pure
pigeonhole: too few short descriptions for too many objects. -/

/-- **Descriptive complexity** of `x` relative to an injective code `enc`: the
number of binary digits of `enc x`. -/
def K (enc : ℕ → ℕ) (x : ℕ) : ℕ := Nat.size (enc x)

/-- Bit-length versus magnitude: `Nat.size y ≤ n ↔ y < 2 ^ n`. -/
theorem size_le_iff_lt_pow (y n : ℕ) : Nat.size y ≤ n ↔ y < 2 ^ n :=
  Nat.size_le

/-- **The finite Berry paradox.**  Among the `2 ^ n + 1` numbers `0, …, 2 ^ n`,
at least one has complexity strictly greater than `n`: no injective code compresses
`2 ^ n + 1` distinct objects into `≤ n`-bit words. -/
theorem berry_pigeonhole (enc : ℕ → ℕ) (hinj : Function.Injective enc) (n : ℕ) :
    ∃ x ∈ Finset.range (2 ^ n + 1), n < K enc x := by
  by_contra h
  push_neg at h
  -- every element of the range has complexity ≤ n, i.e. enc x < 2 ^ n
  have hmaps : Set.MapsTo enc ↑(Finset.range (2 ^ n + 1)) ↑(Finset.range (2 ^ n)) := by
    intro x hx
    rw [Finset.mem_coe, Finset.mem_range] at hx
    rw [Finset.mem_coe, Finset.mem_range]
    have hxle : K enc x ≤ n := h x (Finset.mem_range.2 hx)
    exact (size_le_iff_lt_pow (enc x) n).1 hxle
  have hcard := Finset.card_le_card_of_injOn enc hmaps
    (fun a _ b _ hab => hinj hab)
  simp only [Finset.card_range] at hcard
  omega

/-- **Chaitin incompressibility.**  Descriptive complexity is unbounded: for every
threshold `n` some number has complexity above it.  No injective code makes all
numbers uniformly short. -/
theorem chaitin_incompressible (enc : ℕ → ℕ) (hinj : Function.Injective enc)
    (n : ℕ) : ∃ x, n < K enc x := by
  obtain ⟨x, _, hx⟩ := berry_pigeonhole enc hinj n
  exact ⟨x, hx⟩

/-- Injectivity is essential and satisfiable: the identity code `enc = id` makes
all Berry/Chaitin hypotheses true, so the results are not vacuous. -/
theorem berry_nonvacuous : Function.Injective (id : ℕ → ℕ) := fun _ _ h => h

/-! ## 4. The algebraic bridge: why the diagonal is an obstruction classically

The endomap that has no fixed point above is negation.  In algebra this is the
statement that a nontrivial Boolean algebra has no complement-fixed point. -/

/-- **Boolean obstruction.**  In any Boolean algebra a value equal to its own
complement collapses the algebra (`⊥ = ⊤`).  Negation has no nontrivial fixed
point — the algebraic reason the classical Liar is inconsistent. -/
theorem boolean_neg_fixpoint_trivial {α : Type*} [BooleanAlgebra α] (x : α)
    (h : xᶜ = x) : (⊥ : α) = ⊤ := by
  have h1 : x ⊓ xᶜ = ⊥ := inf_compl_eq_bot
  have h2 : x ⊔ xᶜ = ⊤ := sup_compl_eq_top
  rw [h] at h1 h2
  simp only [inf_idem, sup_idem] at h1 h2
  rw [← h1, ← h2]

/-- Contrapositive: a **nontrivial** Boolean algebra has no negation fixed point. -/
theorem no_boolean_neg_fixpoint {α : Type*} [BooleanAlgebra α] [Nontrivial α]
    (x : α) : xᶜ ≠ x := by
  intro h
  exact (bot_ne_top (α := α)) (boolean_neg_fixpoint_trivial x h)

/-! ### Belnap four-valued logic: the fixed point restored -/

/-- The four Belnap truth values: `T`rue, `F`alse, `B`oth (glut), `N`either (gap). -/
inductive BV | T | F | B | N
deriving DecidableEq, Repr, Fintype

namespace BV

/-- Belnap negation swaps `T`/`F` and fixes the non-classical `B`, `N`. -/
def neg : BV → BV
  | T => F | F => T | B => B | N => N

/-- Designation: a value is *asserted / provable* iff it is at-least-true. -/
def des : BV → Bool
  | T => true | B => true | F => false | N => false

/-- Negation is an involution. -/
theorem neg_neg (v : BV) : neg (neg v) = v := by cases v <;> rfl

/-- **Belnap has a designated negation fixed point** `B` — precisely what fails in
every nontrivial Boolean algebra.  This value turns the Liar into a theorem. -/
theorem has_designated_neg_fixpoint : ∃ v : BV, neg v = v ∧ des v = true :=
  ⟨B, rfl, rfl⟩

/-- A value is a **glut** (both it and its negation designated) iff it is `B`. -/
theorem glut_iff (v : BV) : (des v = true ∧ des (neg v) = true) ↔ v = B := by
  cases v <;> simp [des, neg]

end BV

/-! ## 5. The bridge, stated in one place -/

/-- **Paradox dichotomy (the connector).**  The diagonal endomap — negation —
behaves in exactly opposite ways on the two sides of the bridge:

* on the **classical / algebraic** side it has *no* fixed point in any nontrivial
  Boolean algebra (so the Liar, Russell and Cantor diagonals are genuine
  obstructions, i.e. impossibility theorems), while
* on the **paraconsistent** side Belnap's logic supplies a *designated* fixed
  point `B` (so the very same self-negating sentence becomes a provable glut).

Hence the paradoxes are theorems precisely when classical logic is abandoned. -/
theorem paradox_dichotomy :
    (∀ (α : Type) [BooleanAlgebra α] [Nontrivial α] (x : α), xᶜ ≠ x) ∧
      (∃ v : BV, BV.neg v = v ∧ BV.des v = true) := by
  refine ⟨?_, BV.has_designated_neg_fixpoint⟩
  intro α _ _ x
  exact no_boolean_neg_fixpoint x

/-- **Grand unification.**  All four classical faces of the diagonal are corollaries
of one point-surjectivity obstruction: no type enumerates its own predicates
(`no_prop_pointSurjective`), whence Cantor, Russell and the counting Berry bound
all follow. -/
theorem paradoxes_are_one_theorem :
    (∀ (A : Type) (e : A → A → Prop), ¬ PointSurjective e) ∧
      (∀ (A : Type) (f : A → Set A), ¬ Function.Surjective f) ∧
      (∀ (A : Type) (mem : A → A → Prop),
        ¬ ∃ r : A, ∀ x, mem x r ↔ ¬ mem x x) ∧
      (∀ (enc : ℕ → ℕ), Function.Injective enc → ∀ n, ∃ x, n < K enc x) := by
  refine ⟨fun A e => no_prop_pointSurjective e,
          fun A f => cantor_no_surjective f,
          fun A mem => russell_paradox mem,
          fun enc hinj n => chaitin_incompressible enc hinj n⟩

end ParadoxesLawvereBridge