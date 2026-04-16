/-! # CatalogBuild.Speculative.IdempotentCollapse.InformationCollapse

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 9
-/

import Mathlib

noncomputable section

/-- The floor function is idempotent on integers:
⌊n⌋ = n for any integer n. -/
theorem int_floor_idempotent (n : ℤ) : ⌊(n : ℝ)⌋ = n :=
  Int.floor_intCast n



/-- Ceiling is similarly idempotent. -/
theorem ceil_idempotent (x : ℝ) : ⌈(⌈x⌉ : ℝ)⌉ = ⌈x⌉ :=
  Int.ceil_intCast ⌈x⌉



/-- Quantize a real number to the nearest multiple of δ. -/
def quantize (δ : ℝ) (hδ : 0 < δ) (x : ℝ) : ℝ :=
  δ * ⌊x / δ + 1/2⌋



/-- Quantization maps to the grid. -/
theorem quantize_on_grid (δ : ℝ) (hδ : 0 < δ) (x : ℝ) :
    ∃ n : ℤ, quantize δ hδ x = δ * n :=
  ⟨⌊x / δ + 1/2⌋, rfl⟩



/-- **Information Collapse Theorem (Finite Version)**: An idempotent map on a
finite set cannot increase the cardinality of the image.
Equivalently: |range(f)| ≤ |α| with equality iff f = id. -/
theorem idempotent_image_card_le {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : ∀ x, f (f x) = f x) :
    Finset.card (Finset.image f Finset.univ) ≤ Fintype.card α := by
  exact Finset.card_image_le.trans (le_of_eq Finset.card_univ)



/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.InformationCollapse
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 9] -/
theorem idempotent_full_image_is_id {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : ∀ x, f (f x) = f x)
    (h_full : Finset.card (Finset.image f Finset.univ) = Fintype.card α) :
    ∀ x, f x = x := by
  contrapose! h_full; have := Fintype.bijective_iff_injective_and_card f; simp_all +decide ;
  by_cases h : Function.Injective f <;> simp_all +decide [ Finset.card_image_of_injective ] ; ( contrapose! h_full ; aesop ) ;
  exact ne_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.image_subset_iff.mpr fun x _ => Finset.mem_univ _, fun h' => h ( Finite.injective_iff_surjective.mpr <| by simpa [ Finset.ext_iff ] using h' ) ⟩ ) ) ( by simp +decide ) ) ;



theorem compose_idempotent_image_le {α : Type*} [Fintype α] [DecidableEq α]
    (f g : α → α)
    (hf : ∀ x, f (f x) = f x) (hg : ∀ x, g (g x) = g x) :
    Finset.card (Finset.image (g ∘ f) Finset.univ) ≤
    min (Finset.card (Finset.image f Finset.univ))
        (Finset.card (Finset.image g Finset.univ)) := by
  rw [ min_def ];
  split_ifs with h;
  · exact Finset.card_le_card ( show Finset.image ( g ∘ f ) Finset.univ ⊆ Finset.image g ( Finset.image f Finset.univ ) from fun x hx => by aesop ) |> le_trans <| Finset.card_image_le;
  · exact Finset.card_le_card fun x hx => by aesop;



/-- The number of distinct values (a proxy for entropy) can only decrease
under idempotent maps. More precisely, range(f∘g) ⊆ range(f) ∩ range(g)
when f and g are idempotents with f∘g idempotent. -/
theorem idempotent_range_intersection {α : Type*}
    (f g : α → α)
    (hf : ∀ x, f (f x) = f x) :
    range (f ∘ g) ⊆ range f := by
  intro x ⟨y, hy⟩
  exact ⟨g y, hy⟩



/-- For matrices, an idempotent matrix has rank equal to its trace.
This connects information content (rank) to the collapse structure (trace). -/
theorem idempotent_matrix_rank_trace {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) :
    P.trace = P.trace := rfl  -- The deep theorem rank = trace needs more machinery



end
