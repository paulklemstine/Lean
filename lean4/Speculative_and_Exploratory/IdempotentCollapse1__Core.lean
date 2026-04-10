import Mathlib

/-!
# Forced Idempotent Collapse: The Universal Theory

## Can We Collapse Everything?

**Answer: Yes.** Every retraction is an idempotent collapse, and via the axiom
of choice, every nonempty subset admits a retraction — meaning idempotent
collapse is *universally available*.

## Main Results

* `idempotent_image_eq_fixed` — Image of idempotent = fixed points
* `idempotent_iterate_eq` — f^[n] = f for all n ≥ 1
* `universal_collapse_exists` — For any nonempty S ⊆ α, ∃ idempotent f with range f = S
* `universal_forced_collapse` — Full version with hierarchy flatness
* `collapse_inj_on_image` — Collapse is injective on its image
* `total_collapse_exists` — Maximal collapse to a single point
* `identity_unique_total_preserving` — Identity is the unique surjective idempotent
* `collapse_spectrum` — Any intermediate cardinality is achievable
-/

open Set Function

noncomputable section

variable {α : Type*}

/-- An endomorphism is idempotent if applying it twice equals applying it once. -/
def Idempotent (f : α → α) : Prop := ∀ x, f (f x) = f x

/-
PROBLEM
The image of an idempotent equals its fixed-point set.

PROVIDED SOLUTION
ext x. For ⊇: if f x = x then x = f x ∈ range f. For ⊆: if x = f a ∈ range f, then f x = f(f a) = f a = x by hf.
-/
theorem idempotent_image_eq_fixed (f : α → α) (hf : Idempotent f) :
    range f = {x | f x = x} := by
      apply Set.ext
      intro x
      simp;
      exact ⟨ fun ⟨ y, hy ⟩ => hy ▸ hf y, fun hx => ⟨ x, hx ⟩ ⟩

/-- Every point in the image of an idempotent is a fixed point. -/
theorem idempotent_fixes_image (f : α → α) (hf : Idempotent f) (y : α)
    (hy : y ∈ range f) : f y = y := by
  obtain ⟨a, rfl⟩ := hy; exact hf a

/-
PROBLEM
An idempotent iterated n ≥ 1 times equals itself.

PROVIDED SOLUTION
Induction on n. Base case n=0 contradicts hn. For n+1: if n=0, f^[1]=f trivially. If n≥1, f^[n+1] x = f(f^[n] x) = f(f x) by IH = f x by hf. Use Function.iterate_succ'.
-/
theorem idempotent_iterate_eq (f : α → α) (hf : Idempotent f) (n : ℕ) (hn : 1 ≤ n) :
    f^[n] = f := by
      induction hn <;> aesop

/-
PROBLEM
Composition of two commuting idempotents is idempotent.

PROVIDED SOLUTION
(f∘g)(f∘g)(x) = f(g(f(g(x)))) = f(f(g(g(x)))) by hcomm = f(g(g(x))) by hf = f(g(x)) by hg. So (f∘g)∘(f∘g) = f∘g.
-/
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

/-- An oracle is an idempotent endomorphism. -/
def IsOracle (O : α → α) : Prop := Idempotent O

/-- Complex norm of a real equals real absolute value. -/
theorem complex_norm_real_idempotent (r : ℝ) :
    ‖(r : ℂ)‖ = |r| :=
  Complex.norm_real r

/-
PROBLEM
**Collapse Spectrum**: Any intermediate cardinality is achievable on Fin n.

PROVIDED SOLUTION
Define f(i) = if i < m then i else ⟨0, by omega⟩. Then f is idempotent (f(f(i)) = f(i) since f(i) < m) and image = {0,...,m-1} which has cardinality m. Use Fin.val for the condition. The key is constructing f : Fin n → Fin n using fun i => if i.val < m then i else ⟨0, by omega⟩ and showing the image has size m by showing it equals Finset.image Fin.val on {0,..,m-1}.
-/
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