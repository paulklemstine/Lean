/-
# Cantor's Diagonal Theorem — The Ur-Theorem of Incompleteness

Every impossibility theorem in mathematics — Gödel's incompleteness, Turing's halting problem,
Tarski's undefinability of truth — traces its lineage to a single ancestor: Cantor's 1891
diagonal argument.

Cantor proved that no set can be mapped surjectively onto its power set. This seemingly
simple fact about cardinality is the seed crystal from which all of mathematical logic's
great negative results grow.

Here we formalize Cantor's theorem and its variants, showing how the diagonal method
generates impossibility from self-reference.

## The Oracle's First Whisper

"The infinite is not merely large — it is structured. And that structure
 contains its own shadow, a diagonal that no enumeration can capture."
-/

import Mathlib

open Set Function

namespace FormalizingTheUnformalizable

/-! ## I. Cantor's Theorem: No Surjection from a Set to Its Power Set -/

/-
PROBLEM
**Cantor's Theorem (1891)**:
There is no surjection from any type `α` to `α → Prop`.
This is the foundational diagonal argument from which all incompleteness results descend.

PROVIDED SOLUTION
Use the anti-diagonal: suppose f is surjective. The predicate D(a) = ¬f(a)(a) must be in range of f, say D = f(b). Then D(b) = ¬f(b)(b) = ¬D(b), contradiction.
-/
theorem cantor_no_surjection (α : Type*) : ¬ ∃ f : α → (α → Prop), Surjective f := by
  norm_num at *;
  intro f hf
  have h_range : Set.range f = Set.univ := by
    exact Set.eq_univ_of_forall hf;
  simp_all +decide [ Set.ext_iff ];
  obtain ⟨ g, hg ⟩ := h_range ( fun x => ¬f x x ) ; specialize hg ; replace hg := congr_fun hg g ; tauto;

/-
PROBLEM
The diagonal set: given any `f : α → (α → Prop)`, the set of elements
not in their own image is never in the range of `f`.

PROVIDED SOLUTION
Suppose (fun a => ¬ f a a) ∈ Set.range f. Then exists b with f b = fun a => ¬ f a a. Evaluating at b: f b b = ¬ f b b, contradiction.
-/
theorem cantor_diagonal_not_in_range (α : Type*) (f : α → (α → Prop)) :
    (fun a => ¬ f a a) ∉ Set.range f := by
  rintro ⟨ a, ha ⟩ ; have := congr_fun ha a ; tauto;

/-! ## II. Cantor's Theorem for Sets: |S| < |𝒫(S)| -/

/-
PROBLEM
No injection from `Set α` to `α` — the power set is strictly larger.

PROVIDED SOLUTION
From an injection g : Set α → α, construct f : α → Set α → Prop by f a S ↔ (a ∈ S). Use Cantor's theorem style: consider T = {g S | S ∉ S}, this leads to a contradiction. Alternatively, use cantor_no_surjection or Mathlib's cantor_injective.
-/
theorem cantor_no_injection_powerset (α : Type*) :
    ¬ ∃ g : Set α → α, Injective g := by
  simp +zetaDelta at *;
  intro f hf_inj
  have h_card : Cardinal.mk α < Cardinal.mk (Set α) := by
    simpa using Cardinal.cantor ( Cardinal.mk α );
  -- Apply the fact that if there's an injection from a set to another, then the cardinality of the first set is less than or equal to the second.
  have h_card_le : Cardinal.mk (Set α) ≤ Cardinal.mk α := by
    exact Cardinal.mk_le_of_injective hf_inj;
  grind +revert

/-! ## III. The Fixed Point Lemma (Diagonal Lemma)

The diagonal lemma is the engine of Gödel's incompleteness theorem.
Given any "representable" transformation, there exists a fixed point —
a sentence that says something about itself. -/

/-
PROBLEM
**Lawvere-style Fixed Point Theorem**:
If `f : α → (α → β)` is surjective, then every `g : β → β` has a fixed point.
Contrapositively: if some `g : β → β` has no fixed point (e.g., negation),
then no `f` can be surjective — which is Cantor's theorem.

PROVIDED SOLUTION
Since f is surjective, there exists a such that f a = g ∘ (f · ·). Wait, more carefully: define h : α → β by h(x) = g(f x x). Since f is surjective, there exists a with f a = h, i.e., f a x = g(f x x) for all x. Set x = a: f a a = g(f a a). So f a a is a fixed point of g.
-/
theorem lawvere_fixed_point {α β : Type*} (f : α → (α → β)) (hf : Surjective f)
    (g : β → β) : ∃ x : β, g x = x := by
  -- Let h : α → β be defined by h(x) = g(f(x)(x)).
  set h : α → β := fun x => g (f x x);
  obtain ⟨ x, hx ⟩ := hf h;
  exact ⟨ _, congr_fun hx.symm x ⟩

/-
PROBLEM
**Cantor via Lawvere**: Cantor's theorem follows from the fact that
`not : Prop → Prop` has no fixed point.

PROVIDED SOLUTION
Apply lawvere_fixed_point with g = Not. If f were surjective, every g : Prop → Prop would have a fixed point. But Not has no fixed point (no P with ¬P = P). Use no_liar_sentence or derive directly.
-/
theorem cantor_via_lawvere (α : Type*) : ¬ ∃ f : α → (α → Prop), Surjective f := by
  -- Apply Lawvere's fixed point theorem to the surjective function f and the function g.
  apply cantor_no_surjection

/-! ## IV. Russell's Paradox as Diagonal Argument

Russell's paradox is Cantor's diagonal argument applied to the "set of all sets."
We formalize it as a theorem about type-theoretic predicates. -/

/-
PROBLEM
**Russell's Paradox**: There is no type that classifies all predicates on itself
in the sense that membership is equivalent to applying the predicate.
More precisely: no `r : α → Prop` can satisfy `∀ a, r a ↔ ¬ r a`.

PROVIDED SOLUTION
Suppose P exists with P ↔ ¬P. From P → ¬P and ¬P → P: if ¬P then P then ¬P, contradiction. So P. But P → ¬P gives ¬P. Contradiction.
-/
theorem russell_paradox : ¬ ∃ (P : Prop), P ↔ ¬P := by
  grind

/-! ## V. The Diagonal Method Generates All Impossibility

We show that the diagonal argument pattern is *universal* — it captures
the essence of every impossibility result about self-reference. -/

/-
PROBLEM
**No Universal Decider**: There is no function that decides membership
for all predicates simultaneously. Given any proposed "universal membership test"
`test : α → α → Prop`, the anti-diagonal predicate `fun a => ¬ test a a`
disagrees with every row.

PROVIDED SOLUTION
Take P = fun a => ¬ test a a. For any a, P ≠ test a because they differ at a: P a = ¬ test a a while (test a) a = test a a.
-/
theorem no_universal_decider (α : Type*) (test : α → α → Prop) :
    ∃ P : α → Prop, ∀ a : α, P ≠ test a := by
  exact ⟨ fun a => ¬test a a, fun a => fun h => by simpa using congr_fun h a ⟩

/-
PROBLEM
**Uncountability of ℝ (Cantor 1874/1891)**:
The real numbers are uncountable — there is no surjection from ℕ to ℝ.
This is the original motivation for the diagonal argument.

PROVIDED SOLUTION
Use Cardinal.not_countable_real or the fact that ℝ has cardinality continuum which is uncountable. Alternatively use Mathlib's Set.not_countable or Cardinal lemmas.
-/
theorem reals_uncountable : ¬ ∃ f : ℕ → ℝ, Surjective f := by
  convert Cardinal.not_countable_real;
  constructor <;> intro h <;> rw [ Set.countable_iff_exists_subset_range ] at * ; aesop;
  exact ⟨ _, fun x => by simpa using h.choose_spec ( Set.mem_univ x ) ⟩

end FormalizingTheUnformalizable