/-! # CatalogBuild.Tropical.Core.TropicalOracleFormalization

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 15
-/

import Mathlib

theorem truthSet_eq_range {α : Type*} (O : α → α) (hO : IsIdempotent O) :
    TruthSet O = range O := by
      -- To prove equality of sets, we show each set is a subset of the other.
      apply Set.ext
      intro x
      simp [TruthSet, Set.mem_range];
      exact ⟨ fun hx => ⟨ x, hx ⟩, fun ⟨ y, hy ⟩ => hy ▸ hO y ⟩


theorem fixedPoints_subset_range {α : Type*} (O : α → α) :
    ∀ x, O x = x → x ∈ range O := by
      exact fun x hx => ⟨ x, hx ⟩


theorem idempotent_one_step_convergence {α : Type*} (O : α → α) (hO : IsIdempotent O) :
    ∀ x, O x ∈ TruthSet O := by
      exact fun x => hO x


theorem tropicalGate_nonpos (x : ℝ) : tropicalGate x ≤ 0 := by
  exact min_le_right _ _


theorem tropicalGate_of_nonpos {x : ℝ} (hx : x ≤ 0) : tropicalGate x = x := by
  exact min_eq_left hx


theorem tropicalGate_of_pos {x : ℝ} (hx : 0 < x) : tropicalGate x = 0 := by
  exact min_eq_right hx.le


theorem compression_of_noninjective {α : Type*} [Fintype α] [DecidableEq α]
    (O : α → α) (hO : IsIdempotent O) (hninj : ¬ Injective O) :
    Fintype.card (range O) < Fintype.card α := by
      simp +zetaDelta at *;
      -- Since O is not injective, there exist x and y such that x ≠ y but O x = O y. This means that the image of O has at least one fewer element than the domain.
      have h_image_card : ∃ x y : α, x ≠ y ∧ O x = O y := by
        simpa [ Function.Injective, and_comm ] using hninj;
      refine' Finset.card_lt_card _;
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
      contrapose! h_image_card;
      exact fun x y hxy h => hxy ( by obtain ⟨ z, rfl ⟩ := h_image_card x; obtain ⟨ w, rfl ⟩ := h_image_card y; have := hO z; have := hO w; aesop )


theorem idempotent_injective_iff_id {α : Type*} [Fintype α] [DecidableEq α]
    (O : α → α) (hO : IsIdempotent O) :
    Injective O ↔ O = id := by
      refine' ⟨ fun h => _, fun h x => _ ⟩ <;> aesop


theorem idempotent_surjective_iff_id {α : Type*} [Fintype α] [DecidableEq α]
    (O : α → α) (hO : IsIdempotent O) :
    Surjective O ↔ O = id := by
      refine' ⟨ fun h => _, fun href => _ ⟩;
      · -- Since O is surjective, it is also injective on a finite type.
        have h_inj : Function.Injective O := by
          exact Finite.injective_iff_surjective.mpr h;
        exact?;
      · exact href.symm ▸ Function.surjective_id


theorem truthSet_comp_supset {α : Type*} (O₁ O₂ : α → α) :
    TruthSet O₁ ∩ TruthSet O₂ ⊆ TruthSet (O₁ ∘ O₂) := by
      intro x hx; unfold TruthSet at hx ⊢; aesop;


theorem idempotent_self_comp {α : Type*} (O : α → α) (hO : IsIdempotent O) :
    O ∘ O = O := by
      exact funext hO


theorem fisher_metric_nonneg (grad_sq : ℝ) (hgrad : 0 ≤ grad_sq) :
    0 ≤ 0.99 * 0 + 0.01 * grad_sq := by
      norm_num; positivity;


theorem geodesic_step_welldefined (g_accum : ℝ) (hg : 0 ≤ g_accum) (ε : ℝ) (hε : 0 < ε) :
    0 < Real.sqrt g_accum + ε := by
      positivity


theorem effective_lr_bounded (η : ℝ) (hη : 0 < η) (g_accum : ℝ) (hg : 0 ≤ g_accum)
    (ε : ℝ) (hε : 0 < ε) :
    η / (Real.sqrt g_accum + ε) ≤ η / ε := by
      gcongr ; linarith [ Real.sqrt_nonneg g_accum ]


theorem rank_composition_bound {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ) (B : Matrix (Fin n) (Fin p) ℝ) :
    (A * B).rank ≤ min A.rank B.rank := by
      exact le_min ( Matrix.rank_mul_le_left _ _ ) ( Matrix.rank_mul_le_right _ _ )

