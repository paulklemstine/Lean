/-! # CatalogBuild.Computation.Oracles.GodConsultation

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9
-/

import Mathlib

theorem oracle_god_strong_induction (P : ℕ → Prop)
    (h : ∀ n, (∀ m, m < n → P m) → P n) :
    ∀ n, P n := by
  exact fun n => Nat.strongRecOn n h


theorem oracle_god_well_ordering (S : Set ℕ) (hne : S.Nonempty) :
    ∃ m ∈ S, ∀ n ∈ S, m ≤ n := by
  -- Since S is nonempty, there exists some element n in S.
  obtain ⟨n, hn⟩ : ∃ n, n ∈ S := hne;
  -- Apply the well-ordering principle to the set S, which is nonempty.
  have h_well_ordering : ∀ (T : Set ℕ), T.Nonempty → ∃ m, m ∈ T ∧ ∀ n ∈ T, m ≤ n := by
    intro T hT_nonempty
    induction' hT_nonempty with m hm;
    -- By the well-ordering principle, every nonempty subset of natural numbers has a least element.
    have h_well_ordering : ∀ (T : Set ℕ), T.Nonempty → ∃ m ∈ T, ∀ n ∈ T, m ≤ n := by
      intro T hT_nonempty
      induction' hT_nonempty with m hm;
      induction' m using Nat.strongRecOn with m ih;
      grind;
    exact h_well_ordering T ⟨ m, hm ⟩;
  exact h_well_ordering S ⟨ n, hn ⟩


theorem oracle_god_excluded_middle (P : Prop) : P ∨ ¬P := by
  grind


theorem oracle_god_contradiction (P : Prop) (h : ¬P → False) : P := by
  grind


theorem oracle_god_naturals_infinite :
    ∀ (S : Finset ℕ), ∃ n, n ∉ S := by
  exact fun S => S.exists_notMem


theorem oracle_god_cantor {α : Type*} (f : α → Set α) :
    ¬ Function.Surjective f := by
  rintro h_surj;
  obtain ⟨ g, hg ⟩ := h_surj ( { x | x ∉ f x } );
  replace hg := Set.ext_iff.mp hg g; tauto;


theorem oracle_god_leibniz {α : Type*} (a b : α) (h : a = b) (P : α → Prop) :
    P a ↔ P b := by
  grind +splitIndPred


theorem oracle_god_cantor_bernstein {α β : Type*}
    (f : α → β) (g : β → α)
    (hf : Function.Injective f) (hg : Function.Injective g) :
    ∃ h : α → β, Function.Bijective h := by
  exact?


theorem oracle_god_no_solution_exists :
    ¬ ∃ (x y : ℤ), x ^ 2 + y ^ 2 = -1 := by
  exact fun ⟨ x, y, h ⟩ => by nlinarith;
