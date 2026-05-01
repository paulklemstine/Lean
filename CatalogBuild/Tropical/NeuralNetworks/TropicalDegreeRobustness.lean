/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalDegreeRobustness

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 12
-/

import Mathlib

noncomputable section

/-- The L∞ norm on `Fin n → ℝ`, defined as `max |xᵢ|`. Returns 0 for n=0. -/
def linftyNorm {n : ℕ} (x : Fin n → ℝ) : ℝ :=
  ⨆ i : Fin n, |x i|


/-- [Section: ## Part 1: Tropical Monomial Lipschitz Bound] -/
lemma linftyNorm_nonneg {n : ℕ} (x : Fin n → ℝ) : 0 ≤ linftyNorm x := by
  exact Real.iSup_nonneg fun _ => abs_nonneg _


lemma abs_le_linftyNorm {n : ℕ} (x : Fin n → ℝ) (i : Fin n) :
    |x i| ≤ linftyNorm x := by
  exact le_ciSup ( Finite.bddAbove_range fun i => |x i| ) i


lemma tropical_monomial_lipschitz {n : ℕ} (a : ℝ) (w : Fin n → ℝ)
    (x y : Fin n → ℝ) :
    |(a + ∑ i, w i * x i) - (a + ∑ i, w i * y i)| ≤
      (∑ i, |w i|) * linftyNorm (x - y) := by
  simp +zetaDelta at *;
  rw [ ← Finset.sum_sub_distrib, Finset.sum_mul ];
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => by rw [ ← mul_sub ] ; exact by rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_left ( abs_le.mpr ⟨ by linarith [ abs_le.mp ( show |x i - y i| ≤ linftyNorm ( x - y ) from by simpa using abs_le_linftyNorm ( x - y ) i ) ], by linarith [ abs_le.mp ( show |x i - y i| ≤ linftyNorm ( x - y ) from by simpa using abs_le_linftyNorm ( x - y ) i ) ] ⟩ ) ( abs_nonneg _ ) )


/-- Lipschitz condition w.r.t. the L∞ norm on `Fin n → ℝ`, scalar output. -/
def IsLinftyLipschitz {n : ℕ} (f : (Fin n → ℝ) → ℝ) (L : ℝ) : Prop :=
  0 ≤ L ∧ ∀ x y : Fin n → ℝ, |f x - f y| ≤ L * linftyNorm (x - y)


/-- [Section: ## Part 2: Supremum / Infimum of Lipschitz Functions] -/
lemma sup_of_lipschitz_is_lipschitz {n d : ℕ} [NeZero d]
    (fs : Fin d → (Fin n → ℝ) → ℝ) (L : ℝ)
    (hL : ∀ j, IsLinftyLipschitz (fs j) L) :
    IsLinftyLipschitz
      (fun x => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => fs j x)) L := by
  use (hL 0).left;
  intro x y; rw [ abs_sub_le_iff ] ; constructor <;> norm_num;
  · intro j; linarith [ abs_le.mp ( hL j |>.2 x y ), Finset.le_sup' ( fun j => fs j y ) ( Finset.mem_univ j ) ] ;
  · intro j;
    have := hL j;
    obtain ⟨ hL₁, hL₂ ⟩ := this;
    linarith [ abs_le.mp ( hL₂ x y ), Finset.le_sup' ( fun j => fs j x ) ( Finset.mem_univ j ) ]


lemma inf_of_lipschitz_is_lipschitz {n d : ℕ} [NeZero d]
    (fs : Fin d → (Fin n → ℝ) → ℝ) (L : ℝ)
    (hL : ∀ j, IsLinftyLipschitz (fs j) L) :
    IsLinftyLipschitz
      (fun x => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => fs j x)) L := by
  unfold IsLinftyLipschitz at *;
  refine' ⟨ hL 0 |>.1, fun x y => abs_sub_le_iff.mpr ⟨ _, _ ⟩ ⟩;
  · simp +zetaDelta at *;
    obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) fun j => fs j y;
    exact ⟨ j, by linarith [ abs_le.mp ( hL j |>.2 x y ) ] ⟩;
  · obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun j => fs j x;
    simp_all +decide [ abs_le ];
    exact ⟨ j, by linarith [ hL j |>.2 x y ] ⟩


/-- A classifier `f : ℝⁿ → ℝᵐ` is *certified robust* at input `x` for
true label `y_true` with radius `r` if no L∞ perturbation smaller than `r`
can change the argmax from `y_true`. -/
def CertifiedRobust {n m : ℕ} (f : (Fin n → ℝ) → (Fin m → ℝ))
    (x : Fin n → ℝ) (y_true : Fin m) (r : ℝ) : Prop :=
  ∀ δ : Fin n → ℝ, linftyNorm δ < r →
    ∀ j : Fin m, j ≠ y_true → f (x + δ) j < f (x + δ) y_true


/-- The classification margin: score of true class minus max of other scores.
Here we take the sup over *all* classes j ≠ y_true. We require `m ≥ 2`
so that this set is nonempty. -/
def classMargin {n m : ℕ} (f : (Fin n → ℝ) → (Fin m → ℝ))
    (x : Fin n → ℝ) (y_true : Fin m) : ℝ :=
  ⨅ j : {j : Fin m // j ≠ y_true}, (f x y_true - f x j)


/-- [Section: ## Part 3: Certified Robustness from Lipschitz + Margin] -/
theorem margin_preservation {n m : ℕ}
    (f : (Fin n → ℝ) → (Fin m → ℝ))
    (L : ℝ) (hL_pos : 0 < L)
    (hLip : ∀ k : Fin m, IsLinftyLipschitz (fun x => f x k) L)
    (x : Fin n → ℝ) (y_true : Fin m)
    (_h_margin_pos : 0 < classMargin f x y_true) :
    CertifiedRobust f x y_true (classMargin f x y_true / (2 * L)) := by
  intros δ hδ j hj_ne_y_true
  have h_lip_j : |f (x + δ) j - f x j| ≤ L * linftyNorm δ := by
    simpa using hLip j |>.2 ( x + δ ) x
  have h_lip_y_true : |f (x + δ) y_true - f x y_true| ≤ L * linftyNorm δ := by
    simpa using hLip y_true |>.2 ( x + δ ) x;
  -- By definition of classMargin, we have classMargin f x y_true ≤ f x y_true - f x j.
  have h_classMargin_le : classMargin f x y_true ≤ f x y_true - f x j := by
    refine' ciInf_le_of_le _ _ _;
    exacts [ Set.finite_range _ |> Set.Finite.bddBelow, ⟨ j, hj_ne_y_true ⟩, rfl.le ];
  rw [ lt_div_iff₀ ] at hδ <;> nlinarith [ abs_le.mp h_lip_j, abs_le.mp h_lip_y_true ]


/-- [Section: ## Part 4: Main Theorem — Tropical Degree Certified Robustness] -/
theorem tropicalLipschitzBound {n m : ℕ}
    (f : (Fin n → ℝ) → (Fin m → ℝ))
    (d : ℕ) (K : ℝ) (hK : 0 < K) (hd : 0 < d)
    (hLip : ∀ k : Fin m, IsLinftyLipschitz (fun x => f x k) (K * d))
    (x : Fin n → ℝ) (y_true : Fin m)
    (h_margin_pos : 0 < classMargin f x y_true) :
    CertifiedRobust f x y_true (classMargin f x y_true / (2 * (K * ↑d))) := by
  exact margin_preservation f ( K * d ) ( mul_pos hK ( Nat.cast_pos.mpr hd ) ) hLip x y_true h_margin_pos


theorem certifiedRobustness_from_margin {n m : ℕ}
    (f : (Fin n → ℝ) → (Fin m → ℝ))
    (d : ℕ) (K : ℝ) (hK : 0 < K) (hd : 0 < d)
    (hLip : ∀ k : Fin m, IsLinftyLipschitz (fun x => f x k) (K * ↑d))
    (x : Fin n → ℝ) (y_true : Fin m)
    (margin : ℝ) (h_margin_eq : margin = classMargin f x y_true)
    (h_margin_pos : 0 < margin) :
    CertifiedRobust f x y_true (margin / (2 * K * ↑d)) := by
  convert tropicalLipschitzBound f d K hK hd hLip x y_true _ using 1;
  · rw [ h_margin_eq, mul_assoc ];
  · linarith


end
