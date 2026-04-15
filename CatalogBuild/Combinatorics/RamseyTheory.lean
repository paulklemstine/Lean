/-! # CatalogBuild.Combinatorics.RamseyTheory

Auto-generated from theorem catalog database.
Domain: Combinatorics
Declarations: 6
-/

import Mathlib

/-- [Section: ## Party Problem: R(3,3) = 6] -/
theorem ramsey_3_3_upper :
    ∀ (f : Fin 6 → Fin 6 → Bool),
      (∀ i j, f i j = f j i) →
      (∀ i, f i i = false) →
      ∃ a b c : Fin 6, a ≠ b ∧ b ≠ c ∧ a ≠ c ∧
        ((f a b = true ∧ f b c = true ∧ f a c = true) ∨
         (f a b = false ∧ f b c = false ∧ f a c = false)) := by
  intro f h1 h2;
  -- By the pigeonhole principle, for any vertex $v$, there are at least 3 vertices connected to $v$ with the same color.
  obtain ⟨v, hv⟩ : ∃ v : Fin 6, (Finset.card (Finset.filter (fun w => f v w = true) (Finset.univ.erase v)) ≥ 3 ∨ Finset.card (Finset.filter (fun w => f v w = false) (Finset.univ.erase v)) ≥ 3) := by
    have h_pigeonhole : ∀ v : Fin 6, (Finset.card (Finset.filter (fun w => f v w = true) (Finset.univ.erase v))) + (Finset.card (Finset.filter (fun w => f v w = false) (Finset.univ.erase v))) = 5 := by
      intro v; rw [ Finset.card_filter, Finset.card_filter ] ; rw [ ← Finset.sum_add_distrib ] ; rw [ Finset.sum_congr rfl fun x hx => by aesop ] ; simp +decide ;
    contrapose! h_pigeonhole; simp_all +arith +decide;
    exact ⟨ 0, by linarith [ h_pigeonhole 0 ] ⟩;
  obtain h | h := hv <;> obtain ⟨ a, ha, b, hb, hab ⟩ := Finset.two_lt_card.1 ( by linarith ) <;> simp_all +decide [ Finset.filter_congr ] ;
  · grind +ring;
  · grind +ring


theorem ramsey_3_3_lower :
    ∃ (f : Fin 5 → Fin 5 → Bool),
      (∀ i j, f i j = f j i) ∧
      (∀ i, f i i = false) ∧
      ¬∃ a b c : Fin 5, a ≠ b ∧ b ≠ c ∧ a ≠ c ∧
        ((f a b = true ∧ f b c = true ∧ f a c = true) ∨
         (f a b = false ∧ f b c = false ∧ f a c = false)) := by
  by_contra! h_contra;
  convert h_contra ( fun i j => if ( i - j : Fin 5 ) = 1 ∨ ( j - i : Fin 5 ) = 1 ∨ ( i - j : Fin 5 ) = 4 ∨ ( j - i : Fin 5 ) = 4 then Bool.true else Bool.false ) ?_ ?_ using 1 <;> simp +decide


/-- [Section: ## Schur's Theorem] -/
theorem schur_two_colors :
    ∀ (f : Fin 5 → Bool),
      ∃ x y z : Fin 5, f x = f y ∧ f y = f z ∧
        (x.val + 1) + (y.val + 1) = (z.val + 1) := by
  native_decide +revert


/-- [Section: ## Pigeonhole Ramsey-Type Results] -/
theorem pigeonhole_mod (n : ℕ) (hn : 0 < n) (f : Fin (n + 1) → ℤ) :
    ∃ i j : Fin (n + 1), i ≠ j ∧ f i % n = f j % n := by
  by_contra! h;
  exact absurd ( Finset.card_le_card ( show Finset.image ( fun i => f i % n ) Finset.univ ⊆ Finset.Ico 0 ( n : ℤ ) from Finset.image_subset_iff.mpr fun i _ => Finset.mem_Ico.mpr ⟨ Int.emod_nonneg _ ( by positivity ), Int.emod_lt_of_pos _ ( by positivity ) ⟩ ) ) ( by rw [ Finset.card_image_of_injective _ fun i j hij => not_imp_not.mp ( h i j ) hij ] ; norm_num )


/-- Among any 5 integers, two have the same remainder mod 4. -/
theorem five_ints_mod4 (f : Fin 5 → ℤ) :
    ∃ i j : Fin 5, i ≠ j ∧ f i % 4 = f j % 4 := by
  exact pigeonhole_mod 4 (by omega) f


/-- [Section: ## Hales-Jewett Consequence] -/
theorem combinatorial_line_exists (n : ℕ) (hn : 2 ≤ n) :
    ∀ (f : (Fin n → Bool) → Bool),
      ∃ i : Fin n, ∀ b : Bool,
        f (fun j => if j = i then b else true) =
        f (fun j => if j = i then true else true) ∨
        f (fun j => if j = i then b else false) =
        f (fun j => if j = i then false else false) := by
  induction hn <;> simp_all +decide [ Fin.forall_fin_succ ]
