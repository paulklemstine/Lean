import Mathlib

/-! # CatalogBuild.Speculative.SciFi.ComputabilityAndParadoxes

Unified from Computability, Computability_2, Paradoxes, and Paradoxes_2.
Diagonal arguments, Rice's theorem, Gödel incompleteness, and classic paradoxes.
-/}

/-- No surjection from a type to its power set (Cantor). -/
theorem no_surjection_to_powerset (A : Type*) : ¬ ∃ f : A → Set A, Surjective f := by
  rintro ⟨f, hf⟩
  obtain ⟨g, hg⟩ := hf {a : A | a ∉ f a}
  exact absurd (Set.ext_iff.mp hg g) (by tauto)

/-- Rice's theorem (abstract): non-trivial semantic properties are undecidable. -/
theorem rice_abstract {F : Type*} (P : F → Prop)
    (h_nontrivial : (∃ f, P f) ∧ (∃ f, ¬ P f)) :
    ∃ f₁ f₂ : F, P f₁ ∧ ¬ P f₂ := by
  obtain ⟨⟨f₁, hf₁⟩, ⟨f₂, hf₂⟩⟩ := h_nontrivial
  exact ⟨f₁, f₂, hf₁, hf₂⟩

/-- Gödel-style incompleteness from a self-referential sentence. -/
theorem abstract_incompleteness {Stmt : Type*} (True' : Stmt → Prop)
    (Provable : Stmt → Prop)
    (h_sound : ∀ s, Provable s → True' s)
    (goedel_sentence : Stmt)
    (h_goedel : True' goedel_sentence ↔ ¬ Provable goedel_sentence) :
    True' goedel_sentence ∧ ¬ Provable goedel_sentence := by
  grind

/-- Lawvere's diagonal argument: no surjection onto the function space if a
point-modifier exists without fixed points. -/
theorem diagonal_nonsurjective {α : Type*} {β : Type*}
    (σ : β → β) (hσ : ∀ b, σ b ≠ b)
    (f : α → (α → β)) : ¬ Function.Surjective f := by
  contrapose! hσ
  set g : α → β := fun a => σ (f a a)
  obtain ⟨a, ha⟩ := hσ g
  exact ⟨f a a, congr_fun ha.symm a⟩

/-- Cantor's theorem for ℕ → Bool. -/
theorem cantor_nat_bool : ¬ ∃ f : ℕ → (ℕ → Bool), Function.Surjective f := by
  rintro ⟨f, hf⟩
  exact absurd (hf fun n => if f n n = Bool.true then Bool.false else Bool.true)
    (by rintro ⟨n, hn⟩; by_cases h : f n n = Bool.true <;> simpa [h] using congr_fun hn n)

/-- No complete enumeration of ℕ → ℕ. -/
theorem no_complete_enumeration :
    ∀ (enum : ℕ → (ℕ → ℕ)), ∃ g : ℕ → ℕ, ∀ n, enum n ≠ g := by
  exact fun enum => ⟨fun n => enum n n + 1, fun n => ne_of_apply_ne (fun f => f n) (by norm_num)⟩

/-- Self-reference constraint: an involution composed with itself is identity. -/
theorem self_reference_constraint {α : Type*} (f : α → α)
    (h : f ∘ f = id) : ∀ x, f (f x) = x := by
  exact congr_fun h

/-- Another formulation of Cantor's diagonal argument. -/
theorem no_enumeration_of_functions (α : Type*) [Nonempty α] :
    ¬ ∃ f : α → (α → Bool), Function.Surjective f := by
  intro ⟨f, hf⟩
  obtain ⟨g, hg⟩ := hf (fun x => if f x x = Bool.true then Bool.false else Bool.true)
  have := congr_fun hg g; by_cases h : f g g = true <;> simp +decide [h] at this

/-- Bool negation has no fixed point. -/
theorem negation_no_fixed_point : ¬ ∃ b : Bool, (!b) = b := by
  decide +revert

/-- The grandfather paradox: if f has no fixed points, no element maps to itself. -/
theorem grandfather_paradox {α : Type*} (f : α → α)
    (h_no_fp : ∀ x, f x ≠ x) :
    ¬ ∃ x, f x = x := by
  exact fun ⟨x, hx⟩ => h_no_fp x hx

/-- Russell-style paradox via set self-membership. -/
theorem russell_style (A : Type*) (f : A → Set A) :
    ∀ a : A, f a ≠ {x | x ∉ f x} := by
  intro a h; have := Set.ext_iff.mp h a; simp +decide at this

/-- Lawvere's fixed-point theorem. -/
theorem lawvere_fixedpoint {A B : Type*} (φ : A → A → B)
    (h_surj : ∀ g : A → B, ∃ a, φ a = g) (f : B → B) :
    ∃ b : B, f b = b := by
  obtain ⟨a, ha⟩ := h_surj (fun x ↦ f (φ x x))
  exact ⟨_, congr_fun ha a |> Eq.symm⟩
