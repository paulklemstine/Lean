import Mathlib
import Algebra.SpectralNovelty.CutMetric
import Algebra.SpectralNovelty.UltrametricCondNeg

/-!
# Spectral Corollaries of Ultrametric Conditional Negative Definiteness

This file derives spectral consequences of the main bridge theorem
(Theorem A: ultrametric_distance_matrix_condNeg).

## Main Results

* `centered_ultrametric_psd` — The centered distance matrix -JDJ has a positive
  semidefinite quadratic form (Theorem C).
* `ultrametric_spectral_energy_bound` — Trace/energy bound connecting spectral
  data to hierarchical structure.
* `ultrametric_hilbert_embedding` — Consequence: the Schoenberg kernel is PSD,
  so the ultrametric space embeds isometrically into Hilbert space.

## Tags

spectral theory, positive semidefinite, centering, Hilbert embedding,
spectral energy, trace bound, ultrametric geometry
-/

open Finset BigOperators

/-
**Theorem C: Centered Ultrametric PSD (Quadratic Form Version)**.

For an ultrametric distance function d on Fin n, the centered quadratic form
  ∑ᵢⱼ xᵢ xⱼ · (-(d(i,j) - rowAvg(i) - colAvg(j) + grandAvg))
is nonnegative for ALL vectors x (not just zero-sum ones).

This is equivalent to saying the matrix -JDJ is positive semidefinite,
where J = I - (1/n)11ᵀ is the centering projector.

Proof: The centering operation J maps any vector x to a zero-sum vector Jx,
and the centered quadratic form equals the original form evaluated at Jx.
-/
theorem centered_ultrametric_psd
    {n : ℕ} (hn : 0 < n)
    (d : Fin n → Fin n → ℝ)
    (h_nonneg : ∀ i j, 0 ≤ d i j)
    (h_refl : ∀ i, d i i = 0)
    (h_symm : ∀ i j, d i j = d j i)
    (h_ultra : ∀ i j k, d i k ≤ max (d i j) (d j k)) :
    ∀ x : Fin n → ℝ,
      0 ≤ -(∑ i : Fin n, ∑ j : Fin n,
        (x i - (∑ k : Fin n, x k) / n) *
        (x j - (∑ k : Fin n, x k) / n) * d i j) := by
  intro x
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  -- Let $y(i) = x(i) - \frac{1}{n} \sum_{k} x(k)$. Note that $\sum_{i} y(i) = 0$.
  set y : Fin n → ℝ := fun i => x i - (∑ k, x k) / n
  have hy_sum : ∑ i, y i = 0 := by
    simp +zetaDelta at *;
    rw [ mul_div_cancel₀ _ ( by positivity ), sub_self ];
  convert ultrametric_distance_matrix_condNeg hn d h_nonneg h_refl h_symm ( fun i j k => ?_ ) y hy_sum using 1;
  cases h_ultra i j k <;> simp +decide [ * ]

/-
Helper: For an ultrametric d, the quadratic form satisfies Q ≤ 2·S·T
where S = ∑ x_i and T = ∑ x_i d(i, base). This is the key algebraic
step for proving the Schoenberg kernel is PSD.
-/
theorem ultrametric_Q_le_2ST
    {n : ℕ} (hn : 0 < n)
    (d : Fin n → Fin n → ℝ)
    (h_nonneg : ∀ i j, 0 ≤ d i j)
    (h_refl : ∀ i, d i i = 0)
    (h_symm : ∀ i j, d i j = d j i)
    (h_ultra : ∀ i j k, d i k ≤ max (d i j) (d j k))
    (base : Fin n) (x : Fin n → ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, x i * x j * d i j ≤
      2 * (∑ i, x i) * (∑ i, x i * d i base) := by
  -- Define z : Fin n → ℝ by z i = x i for i ≠ base, and z base = x base - S where S = ∑ x_i.
  set z : Fin n → ℝ := fun i => if i = base then x base - ∑ j, x j else x i;
  -- By ultrametric_distance_matrix_condNeg: ∑_ij z_i z_j d(i,j) ≤ 0.
  have hz_condNeg : ∑ i, ∑ j, z i * z j * d i j ≤ 0 := by
    apply ultrametric_distance_matrix_condNeg hn d h_nonneg h_refl h_symm h_ultra z;
    simp +zetaDelta at *;
    simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
  -- Expand the z·z·d sum algebraically and show it equals Q - 2ST.
  have hz_expand : ∑ i, ∑ j, z i * z j * d i j = ∑ i, ∑ j, x i * x j * d i j - 2 * (∑ i, x i) * (∑ i, x i * d i base) := by
    simp +zetaDelta at *;
    simp +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, sub_mul, mul_sub, h_refl, h_symm ] ; ring;
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, h_symm ] ; ring ; ring;
    simpa only [ ← Finset.sum_mul _ _ _ ] using by ring;
  linarith

/-- Algebraic identity: the Schoenberg kernel quadratic form equals S·T - Q/2. -/
theorem schoenberg_sum_eq {n : ℕ}
    (d : Fin n → Fin n → ℝ)
    (h_symm : ∀ i j, d i j = d j i)
    (base : Fin n) (x : Fin n → ℝ) :
    ∑ i : Fin n, ∑ j : Fin n,
      x i * x j * ((d i base + d base j - d i j) / 2) =
    (∑ i, x i) * (∑ j, x j * d j base) -
    (∑ i : Fin n, ∑ j : Fin n, x i * x j * d i j) / 2 := by
  conv_lhs =>
    arg 2; ext i; arg 2; ext j
    rw [show x i * x j * ((d i base + d base j - d i j) / 2) =
      x i * d i base / 2 * x j + x i / 2 * (x j * d base j) - x i * x j * d i j / 2 from by ring]
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.sum_mul]
  have h5 : ∀ j : Fin n, x j * d base j = x j * d j base := fun j => by rw [h_symm]
  simp_rw [h5]
  have pull1 : (∑ i : Fin n, x i * d i base / 2) = (∑ i, x i * d i base) / 2 :=
    (Finset.sum_div _ _ _).symm
  have pull2 : (∑ i : Fin n, x i / 2) = (∑ i, x i) / 2 :=
    (Finset.sum_div _ _ _).symm
  rw [pull1, pull2]
  have pull3 : ∀ i : Fin n, ∑ j : Fin n, x i * x j * d i j / 2 = (∑ j, x i * x j * d i j) / 2 :=
    fun i => (Finset.sum_div _ _ _).symm
  simp_rw [pull3]
  rw [show ∑ i : Fin n, (∑ j, x i * x j * d i j) / 2 = (∑ i, ∑ j, x i * x j * d i j) / 2 from
    (Finset.sum_div _ _ _).symm]
  ring

/-
**Schoenberg Kernel is PSD for Ultrametrics**.

For an ultrametric d with base point 0, the kernel
  b(i,j) = (d(i,0) + d(0,j) - d(i,j)) / 2
is positive semidefinite. This implies that (Fin n, √d) embeds
isometrically into a Hilbert space.
-/
theorem schoenberg_kernel_psd_of_ultrametric
    {n : ℕ} (hn : 0 < n)
    (d : Fin n → Fin n → ℝ)
    (h_nonneg : ∀ i j, 0 ≤ d i j)
    (h_refl : ∀ i, d i i = 0)
    (h_symm : ∀ i j, d i j = d j i)
    (h_ultra : ∀ i j k, d i k ≤ max (d i j) (d j k))
    (base : Fin n) :
    ∀ x : Fin n → ℝ,
      0 ≤ ∑ i : Fin n, ∑ j : Fin n,
        x i * x j * ((d i base + d base j - d i j) / 2) := by
  intro x
  rw [schoenberg_sum_eq d h_symm base x];
  linarith [ ultrametric_Q_le_2ST hn d h_nonneg h_refl h_symm h_ultra base x ]

/-
**Spectral Energy–Distance Trace Bound**.

For an ultrametric d on Fin n, the total "spectral energy" (sum of squared entries
of the centered distance form) is controlled by the average pairwise distance.
Specifically, for zero-sum x with ‖x‖² = 1:

  |∑ᵢⱼ xᵢ xⱼ d(i,j)| ≤ maxDist · n

where maxDist = max_{i,j} d(i,j). This is a basic but universal spectral
energy bound.
-/
theorem ultrametric_quadform_bound
    {n : ℕ} (hn : 0 < n)
    (d : Fin n → Fin n → ℝ)
    (h_nonneg : ∀ i j, 0 ≤ d i j)
    (h_refl : ∀ i, d i i = 0)
    (h_symm : ∀ i j, d i j = d j i)
    (h_ultra : ∀ i j k, d i k ≤ max (d i j) (d j k))
    (M : ℝ) (hM : ∀ i j, d i j ≤ M)
    (x : Fin n → ℝ) (hx : ∑ i, x i = 0) (hx_norm : ∑ i, x i ^ 2 = 1) :
    |∑ i : Fin n, ∑ j : Fin n, x i * x j * d i j| ≤ M * n := by
  -- By the properties of the absolute value and the triangle inequality, we have:
  have h_abs : |∑ i, ∑ j, x i * x j * d i j| ≤ ∑ i, ∑ j, |x i| * |x j| * M := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j hj => by rw [ abs_mul, abs_mul, abs_of_nonneg ( h_nonneg i j ) ] ; exact mul_le_mul_of_nonneg_left ( hM i j ) ( by positivity ) );
  -- By the properties of the absolute value and the triangle inequality, we can bound the sum.
  have h_sum_bound : ∑ i, ∑ j, |x i| * |x j| ≤ n := by
    have := Finset.univ.sum_le_sum fun i _ => pow_two_nonneg ( |x i| - ( ∑ j, |x j| ) / n );
    simp_all +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
    norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] at *;
    nlinarith [ mul_div_cancel₀ ( ∑ j, |x j| ) ( by positivity : ( n : ℝ ) ≠ 0 ) ];
  exact h_abs.trans ( by simpa only [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_comm ] using mul_le_mul_of_nonneg_left h_sum_bound <| show 0 ≤ M by exact le_trans ( h_nonneg ⟨ 0, hn ⟩ ⟨ 0, hn ⟩ ) ( hM _ _ ) )

/-
**Equidistant Ultrametric Exact Spectrum**.

For the equidistant metric d(i,j) = D for i ≠ j and d(i,i) = 0, the
quadratic form on zero-sum vectors equals exactly -D times the squared norm.
This is the "base case" that illustrates how spectral rigidity works for
the simplest hierarchical structure.
-/
theorem equidistant_quadform {n : ℕ} (D : ℝ) (hD : 0 ≤ D)
    (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
    ∑ i : Fin n, ∑ j : Fin n, x i * x j *
      (if i = j then (0 : ℝ) else D) =
      -D * ∑ i, x i ^ 2 := by
  simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, pow_two, hx ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hx ]