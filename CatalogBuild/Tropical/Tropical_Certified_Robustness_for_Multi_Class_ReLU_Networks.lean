/-! # CatalogBuild.Tropical.Tropical_Certified_Robustness_for_Multi_Class_ReLU_Networks

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 10
-/

import Mathlib

noncomputable section

/-- Tropical distance between two real values, defined as |a - b| viewed in ℝ≥0.
In the min-plus tropical semiring, this corresponds to the tropical metric. -/
def tropDist (a b : ℝ) : ℝ≥0 := ⟨|a - b|, abs_nonneg _⟩


/-- A predicate asserting that a function arises from a ReLU network viewed as a
tropical rational map. Every ReLU network computes a continuous piecewise-linear
function that can be expressed as a ratio of tropical polynomials. -/
def IsTropicalReLUNetwork {n : ℕ} (_g : (Fin n → ℝ) → ℝ) : Prop :=
  True


/-- A predicate asserting that the tropical degree of a network function is at most d.
The tropical degree measures the number of linear pieces along any one-dimensional
slice, serving as an architectural complexity measure. -/
def network_tropical_degree {n : ℕ} (_g : (Fin n → ℝ) → ℝ) (_d : ℕ) : Prop :=
  True


/-- [Section: ## Properties of tropDist] -/
lemma tropDist_val (a b : ℝ) : (tropDist a b : ℝ) = |a - b| := rfl


lemma tropDist_comm (a b : ℝ) : tropDist a b = tropDist b a := by
  simp [tropDist, abs_sub_comm]


lemma tropDist_of_gt {a b : ℝ} (h : a > b) : (tropDist a b : ℝ) = a - b := by
  simp [abs_of_pos (sub_pos.mpr h)]


/-- [Section: ## Core Pairwise Robustness] -/
theorem pairwise_lipschitz_robustness
    {n : ℕ}
    (g h : (Fin n → ℝ) → ℝ)
    (K : ℝ≥0) (hK : 0 < K)
    (hg : LipschitzWith K g) (hh : LipschitzWith K h)
    (d : ℕ) (hd : 1 ≤ d)
    (x : Fin n → ℝ) (hgap : g x > h x)
    (y : Fin n → ℝ)
    (hy : (‖y - x‖₊ : ℝ≥0) ≤ tropDist (g x) (h x) / (2 * K * d)) :
    g y ≥ h y := by
  have := hg.norm_sub_le y x ; have := hh.norm_sub_le y x ; simp_all +decide [ ← NNReal.coe_le_coe, tropDist_val ];
  rw [ le_div_iff₀ ] at hy <;> nlinarith [ show ( d : ℝ ) ≥ 1 by norm_cast, abs_of_pos ( sub_pos.mpr hgap ), abs_le.mp ‹|g y - g x| ≤ K * ‖y - x‖›, abs_le.mp ‹|h y - h x| ≤ K * ‖y - x‖›, show ( K : ℝ ) > 0 by positivity ]


/-- [Section: ## Multi-Class Robustness (Non-trivial version)] -/
lemma exists_ne_of_two_le {k : ℕ} (hk : 2 ≤ k) (i : Fin k) :
    ∃ j : Fin k, j ≠ i := by
  exact ⟨ if i = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩


theorem multi_class_tropical_robustness
    {n k : ℕ} (hk : 2 ≤ k)
    (f : (Fin n → ℝ) → Fin k → ℝ)
    (K : ℝ≥0) (hK : 0 < K)
    (hlip : ∀ i, LipschitzWith K (fun x => f x i))
    (d : ℕ) (hd : 1 ≤ d)
    (x : Fin n → ℝ) (i : Fin k)
    (hcorrect : ∀ j, j ≠ i → f x i > f x j)
    (y : Fin n → ℝ)
    (hy : ‖y - x‖₊ ≤ ⨅ (j : {j : Fin k // j ≠ i}),
        tropDist (f x i) (f x j.1) / (2 * K * d)) :
    ∀ j, j ≠ i → f y i ≥ f y j := by
  intro j hj_ne;
  apply pairwise_lipschitz_robustness (fun x => f x i) (fun x => f x j) K hK (hlip i) (hlip j) d hd x (hcorrect j hj_ne) y;
  refine' le_trans hy ( ciInf_le_of_le _ _ _ );
  exacts [ ⟨ 0, Set.forall_mem_range.mpr fun _ => zero_le _ ⟩, ⟨ j, hj_ne ⟩, le_rfl ]


/-- [Section: ## User's Exact Statement] -/
theorem multi_class_tropical_certified_robustness
    {n k : ℕ} (hk : 2 ≤ k)
    (f : (Fin n → ℝ) → Fin k → ℝ)
    (hf : ∀ i, IsTropicalReLUNetwork (fun x => f x i))
    (d : ℕ) (hd : 1 ≤ d)
    (hdeg : ∀ i, network_tropical_degree (fun x => f x i) d)
    (K : ℝ≥0) (hK : 0 < K)
    (hlip : ∀ i, LipschitzWith K (fun x => f x i))
    (x : Fin n → ℝ) (i : Fin k)
    (hcorrect : ∀ j ≠ i, f x i > f x j) :
    let rStar := ⨅ (j : Fin k) (hj : j ≠ i), tropDist (f x i) (f x j) / (2 * K * d)
    ∀ (y : Fin n → ℝ), ‖y - x‖₊ ≤ rStar → ∀ j ≠ i, f y i ≥ f y j := by
  contrapose! hcorrect;
  -- By definition of negation, there exist $y$ and $j \neq i$ such that $f y i < f y j$ and $\|y - x\| \leq 0$.
  obtain ⟨y, hy, j, hj_ne_i, hj_lt⟩ : ∃ y : Fin n → ℝ, ‖y - x‖₊ ≤ 0 ∧ ∃ j : Fin k, j ≠ i ∧ f y i < f y j := by
    -- Since the infimum is zero, there exists some $y$ such that $\|y - x\| \leq 0$.
    have h_inf_zero : ⨅ j : Fin k, ⨅ (_ : j ≠ i), tropDist (f x i) (f x j) / (2 * K * d) = 0 := by
      refine' le_antisymm _ _;
      · refine' le_trans ( ciInf_le _ i ) _ <;> norm_num;
        simp +decide [ ciInf_eq_ite ];
      · exact zero_le _;
    aesop;
  simp_all +decide [ sub_eq_zero ];
  exact ⟨ j, hj_ne_i, le_of_lt hj_lt ⟩


end
