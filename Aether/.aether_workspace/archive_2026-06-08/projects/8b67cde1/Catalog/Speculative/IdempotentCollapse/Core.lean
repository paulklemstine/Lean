import Mathlib

/-! # CatalogBuild.Speculative.IdempotentCollapse.Core

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 17
-/

noncomputable section

/-- An endomorphism is idempotent if applying it twice equals applying it once. -/
def Idempotent (f : α → α) : Prop := ∀ x, f (f x) = f x

/-- Every point in the image of an idempotent is a fixed point. -/
theorem idempotent_fixes_image (f : α → α) (hf : Idempotent f) (y : α)
    (hy : y ∈ range f) : f y = y := by
  obtain ⟨a, rfl⟩ := hy; exact hf a

/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.Core
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 17] -/
theorem idempotent_iterate_eq (f : α → α) (hf : Idempotent f) (n : ℕ) (hn : 1 ≤ n) :
    f^[n] = f := by
      induction hn <;> aesop

/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.Core
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 17] -/
theorem idempotent_comp_comm (f g : α → α) (hf : Idempotent f) (hg : Idempotent g)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    Idempotent (f ∘ g) := by
      unfold Idempotent at *; aesop;

/-- The identity is idempotent. -/
theorem idempotent_id : Idempotent (id : α → α) := fun _ => rfl

/-- A constant function is idempotent. -/
theorem idempotent_const (c : α) : Idempotent (fun _ => c) := fun _ => rfl

/-- A retraction onto S is idempotent. -/
theorem retraction_is_idempotent (f : α → α) (S : Set α)
    (h_into : ∀ x, f x ∈ S) (h_fixes : ∀ x ∈ S, f x = x) :
    Idempotent f :=
  fun x => h_fixes (f x) (h_into x)

/-- For any nonempty subset S, there exists a retraction onto S. -/
theorem retraction_exists (S : Set α) (hS : S.Nonempty) :
    ∃ f : α → α, (∀ x, f x ∈ S) ∧ (∀ x ∈ S, f x = x) := by
  have : ∀ x : α, ∃ y ∈ S, (x ∈ S → y = x) := by
    intro x
    by_cases hx : x ∈ S
    · exact ⟨x, hx, fun _ => rfl⟩
    · exact ⟨hS.some, hS.some_mem, fun h => absurd h hx⟩
  choose g hg_mem hg_fix using this
  exact ⟨g, hg_mem, fun x hx => hg_fix x hx⟩

/-- **Universal Collapse Theorem**: For ANY nonempty S ⊆ α, there exists an
idempotent f with range f = S. -/
theorem universal_collapse_exists (S : Set α) (hS : S.Nonempty) :
    ∃ f : α → α, Idempotent f ∧ range f = S := by
  obtain ⟨f, h_into, h_fixes⟩ := retraction_exists S hS
  refine ⟨f, retraction_is_idempotent f S h_into h_fixes, ?_⟩
  ext x; constructor
  · rintro ⟨a, rfl⟩; exact h_into a
  · intro hx; exact ⟨x, h_fixes x hx⟩

/-- **The Full Universal Collapse Theorem** with hierarchy flatness. -/
theorem universal_forced_collapse (S : Set α) (hS : S.Nonempty) :
    ∃ f : α → α,
      Idempotent f ∧
      range f = S ∧
      (∀ x ∈ S, f x = x) ∧
      (∀ n, 1 ≤ n → f^[n] = f) := by
  obtain ⟨f, hf_idem, hf_range⟩ := universal_collapse_exists S hS
  refine ⟨f, hf_idem, hf_range, ?_, fun n hn => idempotent_iterate_eq f hf_idem n hn⟩
  intro x hx
  exact idempotent_fixes_image f hf_idem x (hf_range ▸ hx)

/-- Collapse is injective on its image. -/
theorem collapse_inj_on_image (f : α → α) (hf : Idempotent f) : InjOn f (range f) := by
  intro a ha b hb hab
  rwa [idempotent_fixes_image f hf a ha, idempotent_fixes_image f hf b hb] at hab

/-- Total collapse to a single point. -/
theorem total_collapse_exists [Nonempty α] :
    ∃ f : α → α, Idempotent f ∧ ∃ c : α, ∀ x, f x = c := by
  obtain ⟨c⟩ : Nonempty α := inferInstance
  exact ⟨fun _ => c, idempotent_const c, c, fun _ => rfl⟩

/-- The identity is the unique surjective idempotent. -/
theorem identity_unique_total_preserving (f : α → α)
    (hf : Idempotent f) (h_surj : Surjective f) :
    f = id := by
  ext x; exact idempotent_fixes_image f hf x (h_surj x)

/-- At a fixed point, iteration is trivial. -/
theorem fixed_point_iterate' (f : α → α) (x : α) (hx : f x = x) (n : ℕ) :
    f^[n] x = x := by
  induction n with
  | zero => simp
  | succ n ih => simp [Function.iterate_succ, ih, hx]

/-- Tropical: max is idempotent as a self-operation. -/
theorem tropical_self_max_idempotent (a : ℝ) : max a a = a := max_self a

/-- Complex norm of a real equals real absolute value. -/
theorem complex_norm_real_idempotent (r : ℝ) :
    ‖(r : ℂ)‖ = |r| :=
  Complex.norm_real r

theorem collapse_spectrum {n m : ℕ} (hm : 0 < m) (hmn : m ≤ n) :
    ∃ f : Fin n → Fin n, Idempotent f ∧
      Finset.card (Finset.image f Finset.univ) = m := by
        -- Define the function $f$ as follows: for $x < m$, $f(x) = x$, and for $x \geq m$, $f(x) = 0$.
        use fun x => if x.val < m then x else ⟨0, by linarith⟩;
        refine' ⟨ fun x => _, _ ⟩;
        · grind;
        · rw [ Finset.card_eq_of_bijective ];
          use fun i hi => ⟨ i, by linarith ⟩;
          · aesop;
          · aesop;
          · aesop

end
