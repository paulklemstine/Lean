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

/-
PROBLEM
Every element in the range of an idempotent is a fixed point.

PROVIDED SOLUTION
If y ∈ range O, then y = O x for some x. Then O y = O(O x) = O x = y by idempotency.
-/

theorem fixedPoints_subset_range {α : Type*} (O : α → α) :
    ∀ x, O x = x → x ∈ range O := by
      exact fun x hx => ⟨ x, hx ⟩

/-
PROBLEM
Idempotent maps reach their fixed point in exactly one application.

PROVIDED SOLUTION
O(O x) = O x by idempotency, so O x is a fixed point, i.e. O x ∈ TruthSet O.
-/

theorem idempotent_one_step_convergence {α : Type*} (O : α → α) (hO : IsIdempotent O) :
    ∀ x, O x ∈ TruthSet O := by
      exact fun x => hO x

/-
PROBLEM
An idempotent map is a retraction onto its truth set.

PROVIDED SOLUTION
x ∈ TruthSet O means O x = x, which is the conclusion.
-/

theorem tropicalGate_nonpos (x : ℝ) : tropicalGate x ≤ 0 := by
  exact min_le_right _ _

/-
PROBLEM
Tropical gate is the identity on non-positive reals.

PROVIDED SOLUTION
If x ≤ 0, then min x 0 = x by min_eq_left.
-/

theorem tropicalGate_of_nonpos {x : ℝ} (hx : x ≤ 0) : tropicalGate x = x := by
  exact min_eq_left hx

/-
PROBLEM
Tropical gate sends positive reals to 0.

PROVIDED SOLUTION
If 0 < x, then min x 0 = 0 by min_eq_right (le_of_lt hx).
-/

theorem tropicalGate_of_pos {x : ℝ} (hx : 0 < x) : tropicalGate x = 0 := by
  exact min_eq_right hx.le

/-
PROBLEM
The truth set of the tropical gate is (-∞, 0].

PROVIDED SOLUTION
x ∈ TruthSet tropicalGate ↔ min x 0 = x ↔ x ≤ 0 ↔ x ∈ Iic 0. Use ext, unfold, and min_eq_left_iff or similar.
-/

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

/-
PROBLEM
An idempotent is injective iff it is the identity.

PROVIDED SOLUTION
Forward: If O is idempotent and injective, then O(O x) = O x implies O x = x by injectivity, so O = id. Backward: id is injective.
-/

theorem idempotent_injective_iff_id {α : Type*} [Fintype α] [DecidableEq α]
    (O : α → α) (hO : IsIdempotent O) :
    Injective O ↔ O = id := by
      refine' ⟨ fun h => _, fun h x => _ ⟩ <;> aesop

/-
PROBLEM
An idempotent is surjective iff it is the identity.

PROVIDED SOLUTION
Forward: If O is idempotent and surjective on a finite type, then it's bijective, hence injective, so by idempotent_injective_iff_id it's the identity. Backward: id is surjective.
-/

theorem idempotent_surjective_iff_id {α : Type*} [Fintype α] [DecidableEq α]
    (O : α → α) (hO : IsIdempotent O) :
    Surjective O ↔ O = id := by
      refine' ⟨ fun h => _, fun href => _ ⟩;
      · -- Since O is surjective, it is also injective on a finite type.
        have h_inj : Function.Injective O := by
          exact Finite.injective_iff_surjective.mpr h;
        exact?;
      · exact href.symm ▸ Function.surjective_id

/-! ## Section 4: Strange Loop — Composition of Oracles -/

/-
PROBLEM
Composition of two commuting idempotents is idempotent.

PROVIDED SOLUTION
(O₁ ∘ O₂)(((O₁ ∘ O₂) x)) = O₁(O₂(O₁(O₂ x))) = O₁(O₁(O₂(O₂ x))) [by commutativity] = O₁(O₂(O₂ x)) [by h1] = O₁(O₂ x) [by h2]. So it equals (O₁ ∘ O₂) x.
-/

theorem truthSet_comp_supset {α : Type*} (O₁ O₂ : α → α) :
    TruthSet O₁ ∩ TruthSet O₂ ⊆ TruthSet (O₁ ∘ O₂) := by
      intro x hx; unfold TruthSet at hx ⊢; aesop;

/-
PROBLEM
Self-composition of an idempotent equals itself.

PROVIDED SOLUTION
funext x, then apply hO x.
-/

theorem idempotent_self_comp {α : Type*} (O : α → α) (hO : IsIdempotent O) :
    O ∘ O = O := by
      exact funext hO

/-! ## Section 5: Geodesic Gradient Descent — Metric Properties -/

/-
PROBLEM
The diagonal Fisher metric g(θ) = E[grad²] is always non-negative.

PROVIDED SOLUTION
0.99 * 0 + 0.01 * grad_sq = 0.01 * grad_sq ≥ 0 since grad_sq ≥ 0. Use positivity or linarith.
-/

theorem fisher_metric_nonneg (grad_sq : ℝ) (hgrad : 0 ≤ grad_sq) :
    0 ≤ 0.99 * 0 + 0.01 * grad_sq := by
      norm_num; positivity;

/-
PROBLEM
The geodesic update step is well-defined (denominator is positive).

PROVIDED SOLUTION
sqrt(g_accum) ≥ 0 and ε > 0, so sqrt(g_accum) + ε > 0. Use add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε.
-/

theorem geodesic_step_welldefined (g_accum : ℝ) (hg : 0 ≤ g_accum) (ε : ℝ) (hε : 0 < ε) :
    0 < Real.sqrt g_accum + ε := by
      positivity

/-
PROBLEM
The effective learning rate η/√(g+ε) is bounded above by η/ε.

PROVIDED SOLUTION
Since sqrt(g_accum) ≥ 0, we have sqrt(g_accum) + ε ≥ ε > 0. So η/(sqrt(g_accum) + ε) ≤ η/ε by div_le_div_of_nonneg_left or div_le_div_left.
-/

theorem effective_lr_bounded (η : ℝ) (hη : 0 < η) (g_accum : ℝ) (hg : 0 ≤ g_accum)
    (ε : ℝ) (hε : 0 < ε) :
    η / (Real.sqrt g_accum + ε) ≤ η / ε := by
      gcongr ; linarith [ Real.sqrt_nonneg g_accum ]

/-! ## Section 6: Holographic Bottleneck — Dimension Reduction -/

/-
PROBLEM
Linear maps compose to give rank reduction: rank(AB) ≤ min(rank A, rank B).
    This formalizes the bottleneck in the IdempotentOracleHead.

PROVIDED SOLUTION
Use Matrix.rank_mul_le_left and Matrix.rank_mul_le_right to get rank(AB) ≤ rank A and rank(AB) ≤ rank B, then combine with le_min.
-/

theorem rank_composition_bound {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ) (B : Matrix (Fin n) (Fin p) ℝ) :
    (A * B).rank ≤ min A.rank B.rank := by
      exact le_min ( Matrix.rank_mul_le_left _ _ ) ( Matrix.rank_mul_le_right _ _ )

/-! ## Section 7: Convergence and Fixed Points -/

/-
PROBLEM
Iterating an idempotent any positive number of times gives the same result.

PROVIDED SOLUTION
By induction on n. Base case n=1: O^[1] = O. Inductive step: O^[n+1] = O ∘ O^[n] = O ∘ O = O (by IH and idempotent_self_comp).
-/
