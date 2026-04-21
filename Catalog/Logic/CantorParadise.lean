/-! # CatalogBuild.Logic.CantorParadise

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 12
-/

import Mathlib

/-- [Section: # CatalogBuild.Logic.CantorParadise
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 12] -/
theorem power_set_strictly_larger (α : Type*) [Infinite α] :
    #α < #(Set α) := by
      convert Cardinal.cantor _ using 1 ; aesop;




/-- The diagonal set: given f : α → Set α, the set of elements not in their own image.
This is the "rebel set" that cannot be in the range of f. -/
def diagonalSet (f : α → Set α) : Set α := {x | x ∉ f x}




/-- [Section: # CatalogBuild.Logic.CantorParadise
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 12] -/
theorem diagonal_not_in_range (f : α → Set α) : diagonalSet f ∉ Set.range f := by
  by_contra! h_contra;
  obtain ⟨ a, ha ⟩ := h_contra ; have := Set.ext_iff.mp ha a ; tauto;




theorem aleph0_eq_nat_card : ℵ₀ = #ℕ := by
  aesop




theorem aleph_strictMono : StrictMono aleph := by
  exact?




theorem cardinal_pow_gt (κ : Cardinal) : κ < 2 ^ κ := by
  exact?




theorem nat_countably_infinite : #ℕ = ℵ₀ := by
  exact Cardinal.mk_nat




theorem int_countably_infinite : #ℤ = ℵ₀ := by
  aesop




theorem rat_countably_infinite : #ℚ = ℵ₀ := by
  exact?




theorem reals_eq_continuum : #ℝ = 2 ^ ℵ₀ := by
  -- Apply the theorem that states the cardinality of the real numbers is 2^ℵ₀.
  apply Cardinal.mk_real




/-- König's theorem: if κᵢ < λᵢ for all i, then Σκᵢ < Πλᵢ.
We state a consequence: cofinality of 2^ℵ₀ is uncountable. -/
theorem konig_cofinality : ℵ₀ < ((2 : Cardinal) ^ ℵ₀).ord.cof := by
  by_contra h
  push_neg at h
  have h1 : aleph0 ≤ (2 : Cardinal) ^ aleph0 := (cantor aleph0).le
  have h2 := lt_power_cof h1
  have hne : (2 : Cardinal) ^ aleph0 ≠ 0 := ne_of_gt (lt_trans aleph0_pos (cantor ℵ₀))
  have h3 := power_le_power_left hne h
  have h5 : ((2 : Cardinal) ^ aleph0) ^ aleph0 = (2 : Cardinal) ^ aleph0 := by
    rw [← power_mul, aleph0_mul_aleph0]
  exact absurd (lt_of_lt_of_le h2 (h3.trans h5.le)) (not_lt.mpr le_rfl)




theorem schroder_bernstein {α β : Type*}
    (f : α → β) (g : β → α) (hf : Injective f) (hg : Injective g) :
    ∃ h : α → β, Bijective h := by
      obtain ⟨h, hh⟩ : ∃ h : α ≃ β, True := by
        have h_schroeder : Nonempty (α ↪ β) ∧ Nonempty (β ↪ α) → Nonempty (α ≃ β) := by
          simp +zetaDelta at *;
          exact?;
        exact ⟨ h_schroeder ⟨ ⟨ f, hf ⟩, ⟨ g, hg ⟩ ⟩ |> Classical.choice, trivial ⟩;
      exact ⟨ h, h.bijective ⟩



