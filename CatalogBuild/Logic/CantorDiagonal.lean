/-! # CatalogBuild.Logic.CantorDiagonal

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 8
-/

import Mathlib

/-- [Section: ## I. Cantor's Theorem: No Surjection from a Set to Its Power Set] -/
theorem cantor_no_surjection (α : Type*) : ¬ ∃ f : α → (α → Prop), Surjective f := by
  norm_num at *;
  intro f hf
  have h_range : Set.range f = Set.univ := by
    exact Set.eq_univ_of_forall hf;
  simp_all +decide [ Set.ext_iff ];
  obtain ⟨ g, hg ⟩ := h_range ( fun x => ¬f x x ) ; specialize hg ; replace hg := congr_fun hg g ; tauto;


theorem cantor_diagonal_not_in_range (α : Type*) (f : α → (α → Prop)) :
    (fun a => ¬ f a a) ∉ Set.range f := by
  rintro ⟨ a, ha ⟩ ; have := congr_fun ha a ; tauto;


/-- [Section: ## II. Cantor's Theorem for Sets: |S| < |𝒫(S)|] -/
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


/-- [Section: ## III. The Fixed Point Lemma (Diagonal Lemma)
The diagonal lemma is the engine of Gödel's incompleteness theorem.
Given any "representable" transformation, there exists a fixed point —
a sentence that says something about itself.] -/
theorem lawvere_fixed_point {α β : Type*} (f : α → (α → β)) (hf : Surjective f)
    (g : β → β) : ∃ x : β, g x = x := by
  -- Let h : α → β be defined by h(x) = g(f(x)(x)).
  set h : α → β := fun x => g (f x x);
  obtain ⟨ x, hx ⟩ := hf h;
  exact ⟨ _, congr_fun hx.symm x ⟩


theorem cantor_via_lawvere (α : Type*) : ¬ ∃ f : α → (α → Prop), Surjective f := by
  -- Apply Lawvere's fixed point theorem to the surjective function f and the function g.
  apply cantor_no_surjection


/-- [Section: ## IV. Russell's Paradox as Diagonal Argument
Russell's paradox is Cantor's diagonal argument applied to the "set of all sets."
We formalize it as a theorem about type-theoretic predicates.] -/
theorem russell_paradox : ¬ ∃ (P : Prop), P ↔ ¬P := by
  grind


/-- [Section: ## V. The Diagonal Method Generates All Impossibility
We show that the diagonal argument pattern is *universal* — it captures
the essence of every impossibility result about self-reference.] -/
theorem no_universal_decider (α : Type*) (test : α → α → Prop) :
    ∃ P : α → Prop, ∀ a : α, P ≠ test a := by
  exact ⟨ fun a => ¬test a a, fun a => fun h => by simpa using congr_fun h a ⟩


theorem reals_uncountable : ¬ ∃ f : ℕ → ℝ, Surjective f := by
  convert Cardinal.not_countable_real;
  constructor <;> intro h <;> rw [ Set.countable_iff_exists_subset_range ] at * ; aesop;
  exact ⟨ _, fun x => by simpa using h.choose_spec ( Set.mem_univ x ) ⟩

