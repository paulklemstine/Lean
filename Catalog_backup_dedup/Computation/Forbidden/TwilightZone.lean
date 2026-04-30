import Mathlib

/-! # CatalogBuild.Speculative.Forbidden.TwilightZone

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Forbidden.TwilightZone
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7] -/
theorem cantor_twilight : ¬ ∃ f : ℕ → ℝ, Surjective f := by
  by_contra! h' ; have := Cardinal.mk_le_of_surjective h'.choose_spec ; simp_all +decide [ Cardinal.aleph0_lt_continuum ] ;
  exact absurd this ( by rw [ Cardinal.mk_real ] ; exact not_le_of_gt ( Cardinal.aleph0_lt_continuum ) )

/-- [Section: # CatalogBuild.Speculative.Forbidden.TwilightZone
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7] -/
theorem choice_gives_sections {α β : Type*} (f : α → β) (hf : Surjective f) :
    ∃ g : β → α, f ∘ g = id := by
  exact ⟨ fun b => Classical.choose ( hf b ), funext fun b => Classical.choose_spec ( hf b ) ⟩

theorem no_liar : ¬ ∃ P : Prop, P ↔ ¬P := by
  tauto

theorem irrationals_dense (a b : ℚ) (hab : a < b) :
    ∃ r : ℝ, Irrational r ∧ (a : ℝ) < r ∧ r < (b : ℝ) := by
  exact exists_irrational_btwn ( mod_cast hab )

theorem almost_all_functions_uncomputable :
    ¬ ∃ f : ℕ → (ℕ → ℕ), Surjective f := by
  by_contra h_contra
  obtain ⟨f, hf⟩ := h_contra
  have h_surjective : Function.Surjective f := hf;
  exact absurd ( h_surjective ( fun n => f n n + 1 ) ) ( by rintro ⟨ n, hn ⟩ ; have := congr_fun hn n; linarith )

theorem cantor_bernstein {α β : Type*} (f : α → β) (g : β → α)
    (hf : Injective f) (hg : Injective g) :
    ∃ h : α → β, Bijective h := by
  exact?

theorem infinite_sequence_transition (f : ℕ → Bool)
    (h0 : ∀ k, ∃ m, m > k ∧ f m = true)
    (h1 : ∀ k, ∃ m, m > k ∧ f m = false) :
    ∃ n, f n ≠ f (n + 1) := by
  -- By contradiction, assume there are no transitions.
  by_contra h_no_transitions;
  -- If there are no transitions, then $f$ is constant.
  have h_const : ∀ n, f n = f 0 := by
    exact fun n => Nat.recOn n rfl fun n ih => by push_neg at h_no_transitions; exact h_no_transitions n ▸ ih;
  cases h0 0 ; cases h1 0 ; aesop

end
