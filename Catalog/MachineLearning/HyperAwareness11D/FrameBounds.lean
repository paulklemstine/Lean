import MachineLearning.HyperAwareness11D.Injectivity

/-!
# Hyper-Awareness II: metric stability of the optimal 11-dimensional perception layer

`MachineLearning.HyperAwareness11D.Injectivity` shows that `22` units are necessary **and**
sufficient for a ReLU layer on `ℝ¹¹` to be injective, the optimum being realised by the
positive/negative split layer `Φ x = (x⁺, x⁻)`.

Injectivity alone is a set-theoretic statement: it does not by itself guarantee that the
percept can be *stably* recovered.  Here we upgrade it to a quantitative statement: the
optimal layer is a **frame** with sharp constants

  `(1/2) ‖x - y‖² ≤ ‖Φ x - Φ y‖² ≤ ‖x - y‖²`,

so the 11-dimensional percept is recovered with condition number exactly `√2`, uniformly
over all inputs.  Both constants are attained (`double_frame_upper_sharp`,
`double_frame_lower_sharp`), so no better bi-Lipschitz estimate exists for this layer.

We also record the general fact that *every* ReLU layer is contractive relative to its own
linear part (`reluLayer_sqdist_le`), which is what makes the upper bound `1` possible.
-/

namespace HyperAwareness11D

open Finset

noncomputable section

variable {ι : Type*} {n : ℕ}

/-- Squared Euclidean distance on a finite-dimensional coordinate space. -/
def sqdist [Fintype ι] (x y : ι → ℝ) : ℝ := ∑ i, (x i - y i) ^ 2

lemma sqdist_nonneg [Fintype ι] (x y : ι → ℝ) : 0 ≤ sqdist x y :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ## The coordinatewise sandwich -/

/-- The heart of the frame estimate: for a single coordinate, the pair
`(relu a - relu b, relu (-a) - relu (-b))` has squared length between `(a-b)²/2` and `(a-b)²`.
The lower bound is the Cauchy–Schwarz inequality `(u - v)² ≤ 2(u² + v²)` applied to the
identity `(relu a - relu b) - (relu (-a) - relu (-b)) = a - b`; the upper bound holds because
the two coordinates always move in opposite directions. -/
lemma relu_pair_sandwich (a b : ℝ) :
    (a - b) ^ 2 / 2 ≤ (relu a - relu b) ^ 2 + (relu (-a) - relu (-b)) ^ 2 ∧
      (relu a - relu b) ^ 2 + (relu (-a) - relu (-b)) ^ 2 ≤ (a - b) ^ 2 := by
  rcases le_total a 0 with ha | ha <;> rcases le_total b 0 with hb | hb
  · rw [relu_of_nonpos ha, relu_of_nonpos hb, relu_of_nonneg (neg_nonneg.mpr ha),
      relu_of_nonneg (neg_nonneg.mpr hb)]
    constructor <;> nlinarith [sq_nonneg (a - b)]
  · rw [relu_of_nonpos ha, relu_of_nonneg hb, relu_of_nonneg (neg_nonneg.mpr ha),
      relu_of_nonpos (neg_nonpos.mpr hb)]
    constructor <;> nlinarith [sq_nonneg (a + b), mul_nonneg (neg_nonneg.mpr ha) hb]
  · rw [relu_of_nonneg ha, relu_of_nonpos hb, relu_of_nonpos (neg_nonpos.mpr ha),
      relu_of_nonneg (neg_nonneg.mpr hb)]
    constructor <;> nlinarith [sq_nonneg (a + b), mul_nonneg ha (neg_nonneg.mpr hb)]
  · rw [relu_of_nonneg ha, relu_of_nonneg hb, relu_of_nonpos (neg_nonpos.mpr ha),
      relu_of_nonpos (neg_nonpos.mpr hb)]
    constructor <;> nlinarith [sq_nonneg (a - b)]

/-! ## The frame bounds for the optimal layer -/

lemma sqdist_double_eq (x y : Fin n → ℝ) :
    sqdist (reluLayer (doubleW n) 0 x) (reluLayer (doubleW n) 0 y)
      = ∑ i : Fin n, ((relu (x i) - relu (y i)) ^ 2 + (relu (-x i) - relu (-y i)) ^ 2) := by
  rw [sqdist, Fintype.sum_sum_type, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl ?_
  intro i _
  simp [reluLayer, preAct_doubleW_inl, preAct_doubleW_inr]

/-- **Frame bounds (upper).**  The optimal `2n`-unit layer is `1`-Lipschitz. -/
theorem double_frame_upper (x y : Fin n → ℝ) :
    sqdist (reluLayer (doubleW n) 0 x) (reluLayer (doubleW n) 0 y) ≤ sqdist x y := by
  rw [sqdist_double_eq, sqdist]
  refine Finset.sum_le_sum ?_
  intro i _
  exact (relu_pair_sandwich (x i) (y i)).2

/-- **Frame bounds (lower).**  The optimal `2n`-unit layer expands squared distances by at
least `1/2`: the 11-dimensional percept is recoverable with condition number `√2`. -/
theorem double_frame_lower (x y : Fin n → ℝ) :
    sqdist x y / 2 ≤ sqdist (reluLayer (doubleW n) 0 x) (reluLayer (doubleW n) 0 y) := by
  rw [sqdist_double_eq, sqdist, Finset.sum_div]
  refine Finset.sum_le_sum ?_
  intro i _
  exact (relu_pair_sandwich (x i) (y i)).1

/-- Bi-Lipschitz form: the two constants together. -/
theorem double_frame (x y : Fin n → ℝ) :
    sqdist x y / 2 ≤ sqdist (reluLayer (doubleW n) 0 x) (reluLayer (doubleW n) 0 y) ∧
      sqdist (reluLayer (doubleW n) 0 x) (reluLayer (doubleW n) 0 y) ≤ sqdist x y :=
  ⟨double_frame_lower x y, double_frame_upper x y⟩

/-- A frame lower bound immediately re-proves injectivity, independently of the
combinatorial argument in `Injectivity.lean`. -/
theorem injective_of_frame_lower :
    Function.Injective (reluLayer (doubleW n) 0) := by
  intro x y hxy
  have h := double_frame_lower x y
  have hzero : sqdist (reluLayer (doubleW n) 0 x) (reluLayer (doubleW n) 0 y) = 0 := by
    rw [hxy]; simp [sqdist]
  rw [hzero] at h
  have hs : sqdist x y ≤ 0 := by linarith
  have hnn : (0:ℝ) ≤ sqdist x y := sqdist_nonneg x y
  have heq : sqdist x y = 0 := le_antisymm hs hnn
  funext i
  have := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => sq_nonneg (x i - y i))).mp heq i
    (Finset.mem_univ i)
  have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
  linarith [this]

/-! ## Sharpness of both constants in dimension 11 -/

/-- The first standard basis vector of `ℝ¹¹`. -/
def e0 : Fin 11 → ℝ := fun j => if j = 0 then 1 else 0

lemma sqdist_e0_neg : sqdist e0 (fun j => -e0 j) = 4 := by
  simp [sqdist, e0, Fin.sum_univ_succ]
  norm_num

lemma sqdist_e0_zero : sqdist e0 (fun _ => 0) = 1 := by
  simp [sqdist, e0]

/-- **Sharpness of the upper constant `1`.**  Comparing `e₀` with the origin, the split layer
preserves the squared distance exactly. -/
theorem double_frame_upper_sharp :
    sqdist (reluLayer (doubleW 11) 0 e0) (reluLayer (doubleW 11) 0 (fun _ => 0))
      = sqdist e0 (fun _ => 0) := by
  rw [sqdist_double_eq, sqdist_e0_zero]
  simp [e0, relu, Fin.sum_univ_succ]

/-- **Sharpness of the lower constant `1/2`.**  Comparing the antipodal percepts `±e₀`, the
split layer loses exactly a factor `2` in squared distance, so the frame constant `1/2`
cannot be improved: antipodal 11-dimensional percepts are the worst case. -/
theorem double_frame_lower_sharp :
    sqdist (reluLayer (doubleW 11) 0 e0) (reluLayer (doubleW 11) 0 (fun j => -e0 j))
      = sqdist e0 (fun j => -e0 j) / 2 := by
  rw [sqdist_double_eq, sqdist_e0_neg]
  simp [e0, relu, Fin.sum_univ_succ]
  norm_num

/-! ## A general contraction estimate -/

/-- Every ReLU layer contracts distances relative to its own linear part; this is why the
upper frame constant of the optimal layer can be as small as `1`. -/
theorem reluLayer_sqdist_le [Fintype ι] (W : ι → Fin n → ℝ) (b : ι → ℝ) (x y : Fin n → ℝ) :
    sqdist (reluLayer W b x) (reluLayer W b y) ≤ ∑ i, (preAct W b x i - preAct W b y i) ^ 2 := by
  refine Finset.sum_le_sum ?_
  intro i _
  have h : |relu (preAct W b x i) - relu (preAct W b y i)|
      ≤ |preAct W b x i - preAct W b y i| := by
    simp only [relu]
    exact abs_max_sub_max_le_abs _ _ _
  calc (relu (preAct W b x i) - relu (preAct W b y i)) ^ 2
      = |relu (preAct W b x i) - relu (preAct W b y i)| ^ 2 := (sq_abs _).symm
    _ ≤ |preAct W b x i - preAct W b y i| ^ 2 := by
        exact pow_le_pow_left₀ (abs_nonneg _) h 2
    _ = (preAct W b x i - preAct W b y i) ^ 2 := sq_abs _

end

end HyperAwareness11D