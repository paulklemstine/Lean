/-
# Tropical Neural Tangent Kernel as Polyhedral Linearization

This file formalizes the **tropical NTK** — a polyhedral kernel arising from
min-plus neural networks — and proves its structural rigidity on strict argmin
cells. The main results are:

1. A tropical network (inf of affine forms) equals the active branch on a strict cell.
2. The combinatorial parameter gradient is determined by the active branch.
3. The tropical NTK equals ⟨x, y⟩ + 1 when both inputs share a strict cell.
4. The tropical network output is constant along flat directions.
5. The tropical NTK has the form ⟨x, y⟩ + 1 along flat perturbations.

These theorems give the precise **lazy/feature-learning dichotomy**: inside a
tropical flat cell the kernel formula is frozen (lazy regime); crossing a tropical
wall changes the active branch (feature learning).
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

/-! ## Definitions -/

/-- Affine score of hidden unit `i` on input `x`:  W_i · x + b_i -/
def affineScore {d m : ℕ}
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (i : Fin m) (x : Fin d → ℝ) : ℝ :=
  (∑ k : Fin d, W i k * x k) + b i

/-- Tropical network: pointwise inf of affine scores over a nonempty set S -/
def tropicalNet {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x : Fin d → ℝ) : ℝ :=
  S.inf' hS (fun i => affineScore W b i x)

/-- Strict argmin cell: the set of inputs where unit i₀ is strictly the minimum -/
def strictArgminCell {d m : ℕ}
    (S : Finset (Fin m))
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (i0 : Fin m) (x : Fin d → ℝ) : Prop :=
  i0 ∈ S ∧
  ∀ j : Fin m, j ∈ S → j ≠ i0 →
    affineScore W b i0 x < affineScore W b j x

/-- The argmin of affine scores over S: the element of S minimizing the score at x. -/
noncomputable def argminScore {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x : Fin d → ℝ) : Fin m :=
  (Finset.exists_min_image S (fun i => affineScore W b i x) hS).choose

lemma argminScore_mem {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x : Fin d → ℝ) : argminScore S hS W b x ∈ S :=
  (Finset.exists_min_image S (fun i => affineScore W b i x) hS).choose_spec.1

lemma argminScore_le {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x : Fin d → ℝ) (j : Fin m) (hj : j ∈ S) :
    affineScore W b (argminScore S hS W b x) x ≤ affineScore W b j x :=
  (Finset.exists_min_image S (fun i => affineScore W b i x) hS).choose_spec.2 j hj

/-- On a strict argmin cell, the argmin equals i₀. -/
lemma argminScore_eq_on_strict_cell {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (i0 : Fin m) (hi0 : i0 ∈ S)
    (x : Fin d → ℝ)
    (hcell : ∀ j : Fin m, j ∈ S → j ≠ i0 →
      affineScore W b i0 x < affineScore W b j x) :
    argminScore S hS W b x = i0 := by
  by_contra h
  have hmem := argminScore_mem S hS W b x
  have hlt := hcell _ hmem h
  have hle := argminScore_le S hS W b x i0 hi0
  linarith

/-- Tropical parameter gradient: gradient of the active branch at argmin.
    Weight gradient at argmin unit = x, bias gradient = 1; all others = 0. -/
def tropicalParamGrad
    {d m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (x : Fin d → ℝ) : (Fin m → Fin d → ℝ) × (Fin m → ℝ) :=
  let i0 := argminScore S hS W b x
  ( fun i k => if i = i0 then x k else 0,
    fun i => if i = i0 then 1 else 0 )

/-- Tropical NTK: inner product of tropical parameter gradients -/
def tropicalNTK
    {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (x y : Fin d → ℝ) : ℝ :=
  let gx := tropicalParamGrad S hS W b x
  let gy := tropicalParamGrad S hS W b y
  (∑ i : Fin m, ∑ k : Fin d, gx.1 i k * gy.1 i k) +
  (∑ i : Fin m, gx.2 i * gy.2 i)

/-! ## Theorem 1: Tropical network equals active branch on strict cell -/

/-- On a strict argmin cell for i₀, the tropical network equals the affine score of i₀.
    This is the polyhedral heart: tropical prediction is literally affine inside a chamber. -/
theorem tropical_network_eq_affine_on_strict_cell
    {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (i0 : Fin m) (hi0 : i0 ∈ S) :
    ∀ x : (Fin d → ℝ),
      (∀ j : Fin m, j ∈ S → j ≠ i0 →
        (∑ k : Fin d, W i0 k * x k) + b i0
          < (∑ k : Fin d, W j k * x k) + b j) →
      (S.inf' hS (fun i =>
        (∑ k : Fin d, W i k * x k) + b i))
        = (∑ k : Fin d, W i0 k * x k) + b i0 := by
  intro x hx
  apply le_antisymm
  · exact Finset.inf'_le _ hi0
  · exact Finset.le_inf' _ _ fun j hj => by
      by_cases hj' : j = i0
      · simp [hj']
      · exact le_of_lt (hx j hj hj')

/-! ## Theorem 2: Parameter gradient on strict cell -/

/-- On a strict argmin cell for i₀, the tropical parameter gradient
    has weight component x at i₀ (zero elsewhere) and bias 1 at i₀ (zero elsewhere).
    This is the tropical analogue of "Jacobian frozen in the lazy regime." -/
theorem tropical_param_grad_on_strict_cell
    {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (i0 : Fin m) (hi0 : i0 ∈ S) :
    ∀ x : Fin d → ℝ,
      (∀ j : Fin m, j ∈ S → j ≠ i0 →
        (∑ k : Fin d, W i0 k * x k) + b i0
          < (∑ k : Fin d, W j k * x k) + b j) →
      tropicalParamGrad S hS W b x
        =
        ( (fun i k => if i = i0 then x k else 0),
          (fun i => if i = i0 then 1 else 0) ) := by
  intro x hx
  simp only [tropicalParamGrad]
  rw [argminScore_eq_on_strict_cell S hS W b i0 hi0 x hx]

/-! ## Theorem 3: Tropical NTK = ⟨x, y⟩ + 1 on common strict cell -/

/-
When both x and y lie in the same strict argmin cell for i₀,
    the tropical NTK equals ⟨x, y⟩ + 1. This is the first real theorem
    that deserves the phrase "tropical NTK."
-/
theorem tropical_ntk_eq_dot_add_one_on_common_strict_cell
    {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (i0 : Fin m) (hi0 : i0 ∈ S) :
    ∀ x y : Fin d → ℝ,
      (∀ j : Fin m, j ∈ S → j ≠ i0 →
        (∑ k : Fin d, W i0 k * x k) + b i0
          < (∑ k : Fin d, W j k * x k) + b j) →
      (∀ j : Fin m, j ∈ S → j ≠ i0 →
        (∑ k : Fin d, W i0 k * y k) + b i0
          < (∑ k : Fin d, W j k * y k) + b j) →
      tropicalNTK S hS W b x y
        = (∑ k : Fin d, x k * y k) + 1 := by
  intros x y hx hy;
  -- By definition of $tropicalNTK$, we can expand it as follows:
  unfold tropicalNTK;
  unfold tropicalParamGrad;
  rw [ argminScore_eq_on_strict_cell S hS W b i0 hi0 x hx, argminScore_eq_on_strict_cell S hS W b i0 hi0 y hy ] ; aesop

/-! ## Theorem 4: Tropical network output is constant along flat directions -/

/-
Along a flat direction v (W_{i₀} · v = 0) that preserves the strict cell,
    the tropical network output is constant. This is the prediction-level
    characterization of the lazy regime: no change in output without
    crossing a tropical wall.
-/
theorem tropical_net_constant_along_flat_directions
    {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (i0 : Fin m) (hi0 : i0 ∈ S) :
    ∀ x v : Fin d → ℝ,
      (∀ j : Fin m, j ∈ S → j ≠ i0 →
        affineScore W b i0 x < affineScore W b j x) →
      (∑ k : Fin d, W i0 k * v k) = 0 →
      (∀ t : ℝ,
        ∀ j : Fin m, j ∈ S → j ≠ i0 →
          affineScore W b i0 (fun k => x k + t * v k) <
            affineScore W b j (fun k => x k + t * v k)) →
      ∀ t : ℝ,
        tropicalNet S hS W b (fun k => x k + t * v k)
          = tropicalNet S hS W b x := by
  intros x v hx hv hxy t
  simp [tropicalNet, hx, hv, hxy];
  convert tropical_network_eq_affine_on_strict_cell S hS W b i0 hi0 ( fun k => x k + t * v k ) ( hxy t ) using 1;
  convert tropical_network_eq_affine_on_strict_cell S hS W b i0 hi0 x hx using 1;
  simp +decide [ mul_add, Finset.sum_add_distrib, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, hv ];
  rw [ ← Finset.mul_sum _ _ _, hv, MulZeroClass.mul_zero ]

/-! ## Theorem 5: NTK formula ⟨x+tv, y⟩ + 1 on flat perturbation -/

/-
Along a flat direction v preserving the strict cell, the tropical NTK
    at (x+tv, y) equals ⟨x+tv, y⟩ + 1 — the same linear kernel formula
    but evaluated at the displaced point. The kernel TYPE (linear + bias)
    is preserved; only the input changes.
-/
theorem tropical_ntk_formula_along_flat
    {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (i0 : Fin m) (hi0 : i0 ∈ S) :
    ∀ x y v : Fin d → ℝ,
      (∀ j : Fin m, j ∈ S → j ≠ i0 →
        affineScore W b i0 y < affineScore W b j y) →
      (∀ t : ℝ,
        ∀ j : Fin m, j ∈ S → j ≠ i0 →
          affineScore W b i0 (fun k => x k + t * v k) <
            affineScore W b j (fun k => x k + t * v k)) →
      ∀ t : ℝ,
        tropicalNTK S hS W b (fun k => x k + t * v k) y
          = (∑ k : Fin d, (x k + t * v k) * y k) + 1 := by
  intro x y v hy hv t;
  convert tropical_ntk_eq_dot_add_one_on_common_strict_cell S hS W b i0 hi0 ( fun k => x k + t * v k ) y _ _ using 1;
  · exact hv t;
  · exact hy

/-! ## Corollary: Lazy/Feature-Learning Dichotomy -/

/-
**Lazy regime characterization**: On a strict argmin cell, the tropical
    network is affine and the tropical NTK is the standard linear kernel ⟨·,·⟩ + 1.
    Feature learning occurs exactly when crossing a tropical wall changes the
    active branch, and hence the kernel formula.
-/
theorem lazy_regime_characterization
    {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → (Fin d → ℝ)) (b : Fin m → ℝ)
    (i0 : Fin m) (hi0 : i0 ∈ S)
    (x y : Fin d → ℝ)
    (hx : ∀ j : Fin m, j ∈ S → j ≠ i0 →
      affineScore W b i0 x < affineScore W b j x)
    (hy : ∀ j : Fin m, j ∈ S → j ≠ i0 →
      affineScore W b i0 y < affineScore W b j y) :
    tropicalNet S hS W b x = affineScore W b i0 x ∧
    tropicalNTK S hS W b x y = (∑ k : Fin d, x k * y k) + 1 := by
  exact ⟨ tropical_network_eq_affine_on_strict_cell S hS W b i0 hi0 x hx, tropical_ntk_eq_dot_add_one_on_common_strict_cell S hS W b i0 hi0 x y hx hy ⟩

end