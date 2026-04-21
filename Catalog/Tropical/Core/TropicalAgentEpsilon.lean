/-! # CatalogBuild.Tropical.Core.TropicalAgentEpsilon

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 16
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Tropical.Core.TropicalAgentEpsilon
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 16] -/
theorem translation_preserves_max (c a b : ℝ) :
    max a b + c = max (a + c) (b + c) :=
  (max_add_add_right a b c).symm




/-- [Section: # CatalogBuild.Tropical.Core.TropicalAgentEpsilon
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 16] -/
theorem nonneg_scale_preserves_max (c : ℝ) (hc : 0 ≤ c) (a b : ℝ) :
    c * max a b = max (c * a) (c * b) := by
  rcases le_total a b with h | h
  · rw [max_eq_right h, max_eq_right (mul_le_mul_of_nonneg_left h hc)]
  · rw [max_eq_left h, max_eq_left (mul_le_mul_of_nonneg_left h hc)]




theorem partition_function_bound {n : ℕ} (E : Fin (n+1) → ℝ) (β : ℝ) :
    exp (β * Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ (fun i => -E i))
    ≤ ∑ i, exp (β * (-E i)) := by
      obtain ⟨k, hk⟩ : ∃ k, ∀ i, -E i ≤ -E k := by
        simpa using Finset.exists_max_image Finset.univ ( fun i => -E i ) ⟨ 0, Finset.mem_univ 0 ⟩;
      have h_sup_eq : (Finset.univ.sup' (by
      exact ⟨ k, Finset.mem_univ _ ⟩) fun i => -E i) = -E k := by
        exact le_antisymm ( Finset.sup'_le _ _ fun i _ => hk i ) ( Finset.le_sup' ( fun i => -E i ) ( Finset.mem_univ k ) )
      generalize_proofs at *;
      rw [ h_sup_eq ] ; exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg _ ) ( Finset.mem_univ k ) ) ;




theorem successive_updates (logPrior : ℝ) (xs : List ℝ) :
    logPrior + xs.sum = (logPrior :: xs).sum := by
  induction xs with
  | nil => simp
  | cons h t ih => simp [add_assoc]




theorem learning_rate_sum_pos (N : ℕ) (hN : 0 < N) :
    (0 : ℝ) < Finset.sum (Finset.range N) (fun k => (1 : ℝ) / (k + 1)) := by
  exact Finset.sum_pos (fun k _ => by positivity) (Finset.nonempty_range_iff.mpr (by omega))




theorem max_preserves_convexity (f g : ℝ → ℝ)
    (hf : ConvexOn ℝ Set.univ f) (hg : ConvexOn ℝ Set.univ g) :
    ConvexOn ℝ Set.univ (fun x => max (f x) (g x)) := by
      refine' ⟨ convex_univ, fun x _ y _ a b ha hb hab => _ ⟩;
      -- Apply the definition of convexity to $f$ and $g$ separately.
      have h_convex_f : f (a • x + b • y) ≤ a • f x + b • f y := by
        exact hf.2 trivial trivial ha hb hab
      have h_convex_g : g (a • x + b • y) ≤ a • g x + b • g y := by
        exact hg.2 trivial trivial ha hb hab;
      simp +zetaDelta at *;
      constructor <;> nlinarith [ le_max_left ( f x ) ( g x ), le_max_right ( f x ) ( g x ), le_max_left ( f y ) ( g y ), le_max_right ( f y ) ( g y ) ]




theorem affine_convex (a b : ℝ) : ConvexOn ℝ Set.univ (fun x => a * x + b) := by
  -- To prove convexity, we use the definition of convexity.
  unfold ConvexOn;
  simp +zetaDelta at *;
  exact ⟨ convex_univ, fun x y a b ha hb hab => by rw [ ← eq_sub_iff_add_eq' ] at hab; subst hab; nlinarith ⟩




noncomputable def tropContract {m n p : ℕ}
    (A : Fin (m+1) → Fin (p+1) → ℝ) (B : Fin (p+1) → Fin (n+1) → ℝ) :
    Fin (m+1) → Fin (n+1) → ℝ :=
  fun i j => Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ (fun k => A i k + B k j)




theorem tropContract_mono {m n p : ℕ}
    (A A' : Fin (m+1) → Fin (p+1) → ℝ) (B : Fin (p+1) → Fin (n+1) → ℝ)
    (h : ∀ i k, A i k ≤ A' i k) (i : Fin (m+1)) (j : Fin (n+1)) :
    tropContract A B i j ≤ tropContract A' B i j := by
      apply_rules [ Finset.sup'_le ];
      intro k hk;
      refine' le_trans _ ( Finset.le_sup' _ ( Finset.mem_univ k ) );
      grind




def tropHamming {n : ℕ} (a b : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, |a i - b i|




theorem tropHamming_symm {n : ℕ} (a b : Fin n → ℝ) :
    tropHamming a b = tropHamming b a := by
  unfold tropHamming; congr 1; ext i; rw [abs_sub_comm]




theorem tropHamming_nonneg {n : ℕ} (a b : Fin n → ℝ) : 0 ≤ tropHamming a b :=
  Finset.sum_nonneg (fun _ _ => abs_nonneg _)




theorem tropHamming_eq_zero {n : ℕ} (a b : Fin n → ℝ) :
    tropHamming a b = 0 ↔ a = b := by
      unfold tropHamming;
      simp +decide [ funext_iff, Finset.sum_eq_zero_iff_of_nonneg, abs_nonneg ];
      simp +decide only [sub_eq_zero]




noncomputable def tropEntropy {n : ℕ} [NeZero n] (v : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ v - (∑ i, v i) / n




theorem tropEntropy_nonneg {n : ℕ} [NeZero n] (v : Fin n → ℝ) : 0 ≤ tropEntropy v := by
  unfold tropEntropy
  generalize_proofs at *; (
  simp +zetaDelta at *;
  exact ⟨ Classical.choose ( Finset.exists_max_image Finset.univ ( fun i => v i ) ( Finset.univ_nonempty ) ), by have := Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun i => v i ) ( Finset.univ_nonempty ) ) ; rw [ div_le_iff₀ ( Nat.cast_pos.mpr <| NeZero.pos n ) ] ; have := Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => this.2 i hi; norm_num at *; linarith ⟩)




theorem tropEntropy_const {n : ℕ} [NeZero n] (c : ℝ) :
    tropEntropy (fun _ : Fin n => c) = 0 := by
      -- By definition of tropEntropy, we have:
      simp [tropEntropy];
      rw [ mul_div_cancel_left₀ _ ( NeZero.ne _ ), sub_self ]




end
