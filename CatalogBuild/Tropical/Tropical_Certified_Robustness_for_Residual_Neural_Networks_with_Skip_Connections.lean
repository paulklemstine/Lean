/-! # CatalogBuild.Tropical.Tropical_Certified_Robustness_for_Residual_Neural_Networks_with_Skip_Connections

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 5
-/

import Mathlib

/-- A residual block: the identity skip connection plus a learned transformation. -/
def resnetBlock (f : ℝ → ℝ) (x : ℝ) : ℝ := x + f x


/-- A deep ResNet of depth `n`, composing residual blocks sequentially. -/
def deepResNet (blocks : ℕ → ℝ → ℝ) : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => resnetBlock (blocks n) (deepResNet blocks n x)


/-- [Section: ## Theorem 1: Skip connections preserve Lipschitz bounds] -/
theorem resnet_block_lipschitz {f : ℝ → ℝ} {L : ℝ}
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (_hL : 0 ≤ L) :
    ∀ x y, |resnetBlock f x - resnetBlock f y| ≤ (1 + L) * |x - y| := by
  -- Rewrite $|resnetBlock f x - resnetBlock f y|$ as $|(x - y) + (f x - f y)|$.
  intro x y
  unfold resnetBlock;
  exact abs_le.mpr ⟨ by cases abs_cases ( x - y ) <;> nlinarith [ abs_le.mp ( hf x y ) ], by cases abs_cases ( x - y ) <;> nlinarith [ abs_le.mp ( hf x y ) ] ⟩


/-- [Section: ## Theorem 2: Tropical degree shift through skip connections] -/
theorem resnet_block_tropical_shift (ms : List TropicalMonomial) (x : ℝ)
    (hne : ms ≠ []) :
    x + tropicalEval ms x =
    tropicalEval (ms.map (fun m => ⟨m.coefficient, m.degree + 1⟩)) x := by
  induction ms <;> simp_all +decide [ List.map ];
  rename_i k l ih;
  cases l <;> simp_all +decide [ tropicalEval ];
  · ring;
  · rw [ ← ih, add_max ] ; ring


/-- [Section: ## Theorem 3: Deep ResNet robustness certificate] -/
theorem deep_resnet_robustness (blocks : ℕ → ℝ → ℝ) (c : ℕ → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (hlip : ∀ i x y, |blocks i x - blocks i y| ≤ c i * |x - y|)
    (L : ℕ) (x δ : ℝ) (ε : ℝ) (hδ : |δ| ≤ ε) :
    |deepResNet blocks L (x + δ) - deepResNet blocks L x| ≤
    (∏ i ∈ Finset.range L, (1 + c i)) * ε := by
  induction' L with L ih generalizing x δ ε;
  · simpa [ deepResNet ] using hδ;
  · rw [ Finset.prod_range_succ ];
    convert le_trans _ ( mul_le_mul_of_nonneg_left ( ih x δ ε hδ ) ( add_nonneg zero_le_one ( hc L ) ) ) using 1;
    · ring;
    · convert resnet_block_lipschitz ( hlip L ) ( hc L ) _ _ using 1
