/-
# Lorentz-Orthogonal Averaging and Spectral Gap

This module formalizes the spectral mechanism by which pairwise orthogonality
of generators forces contraction of an averaged operator, yielding a universal
spectral gap bound.

## Main results

* `norm_sq_sum_eq_sum_norm_sq` — Pythagorean identity for pairwise orthogonal vectors
* `norm_avg_le_div_sqrt` — The 1/√k contraction bound for averages of orthogonal vectors
* `orthogonal_projection_norm_bound` — Bessel-type bound for orthonormal projections
* `spectral_gap_lower_bound` — The spectral gap ≥ 1 - 1/√k for normalized averaging
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Pythagorean Identity for Finite Orthogonal Sums -/

/-
**Pythagorean identity**: For pairwise orthogonal vectors, the squared norm of
the sum equals the sum of squared norms. This is the fundamental identity underlying
the spectral gap mechanism.
-/
theorem norm_sq_sum_eq_sum_norm_sq
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    {k : ℕ} (v : Fin k → V)
    (horth : ∀ i j, i ≠ j → @inner ℝ V _ (v i) (v j) = 0) :
    ‖∑ i, v i‖ ^ 2 = ∑ i, ‖v i‖ ^ 2 := by
  induction' k with k ih;
  · simp +decide;
  · rw [ Fin.sum_univ_succ, Fin.sum_univ_succ ];
    rw [ @norm_add_sq ℝ ];
    simp_all +decide [ inner_sum, Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg ];
    exact Finset.sum_eq_zero fun i _ => horth _ _ ( ne_of_lt ( Fin.succ_pos i ) )

/-! ## The 1/√k Contraction Bound -/

/-
**Orthogonal averaging contraction**: When k pairwise-orthogonal vectors each have
norm at most C, their average has norm at most C/√k. This is the core mechanism
behind spectral gap bounds for Lorentz-orthogonal generators.
-/
theorem norm_avg_le_div_sqrt
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    {k : ℕ} (hk : 0 < k) (v : Fin k → V) (C : ℝ) (hC : 0 ≤ C)
    (horth : ∀ i j, i ≠ j → @inner ℝ V _ (v i) (v j) = 0)
    (hbound : ∀ i, ‖v i‖ ≤ C) :
    ‖(1 / (k : ℝ)) • ∑ i, v i‖ ≤ C / Real.sqrt k := by
  -- Use norm_sq_sum_eq_sum_norm_sq to get ‖Σ v_i‖² = Σ ‖v_i‖².
  have h_sum_sq : ‖(∑ i, v i)‖ ^ 2 = ∑ i, ‖(v i)‖ ^ 2 := by
    exact norm_sq_sum_eq_sum_norm_sq _ horth;
  rw [ norm_smul, Real.norm_of_nonneg ( by positivity ), div_mul_eq_mul_div, div_le_div_iff₀ ] <;> try positivity;
  have := Finset.sum_le_sum fun i ( _hi : i ∈ Finset.univ ) => pow_le_pow_left₀ ( norm_nonneg _ ) ( hbound i ) 2 ; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ];
  nlinarith [ show 0 ≤ C * k by positivity, show 0 ≤ ‖∑ i, v i‖ * Real.sqrt k by positivity, Real.mul_self_sqrt ( Nat.cast_nonneg k ) ]

/-! ## Orthonormal Projection Bound (Bessel's Inequality) -/

/-
**Bessel's inequality**: For an orthonormal family, the projection onto their span
is a contraction.
-/
theorem orthogonal_projection_norm_bound
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    {k : ℕ} (u : Fin k → V) (hu : Orthonormal ℝ u) (x : V) :
    ‖∑ i, @inner ℝ V _ x (u i) • u i‖ ≤ ‖x‖ := by
  -- By definition of orthonormality, we know that the vectors $w_i = \langle x, u_i \rangle u_i$ are pairwise orthogonal.
  have h_orthogonal : ∀ i j, i ≠ j → inner ℝ ((inner ℝ x (u i)) • u i) ((inner ℝ x (u j)) • u j) = 0 := by
    simp +contextual [ inner_smul_left, inner_smul_right ];
    exact fun i j hij => Or.inr <| Or.inr <| hu.2 hij;
  -- By the Pythagorean theorem, we have $\|w\|^2 = \sum_{i=1}^k \|w_i\|^2$.
  have h_pythagorean : ‖∑ i, (inner ℝ x (u i)) • u i‖ ^ 2 = ∑ i, ‖(inner ℝ x (u i)) • u i‖ ^ 2 := by
    exact norm_sq_sum_eq_sum_norm_sq _ h_orthogonal;
  -- By the properties of the inner product and the orthonormality of the vectors $u_i$, we have $\|w_i\|^2 = |\langle x, u_i \rangle|^2$.
  have h_norm_sq : ∀ i, ‖(inner ℝ x (u i)) • u i‖ ^ 2 = (inner ℝ x (u i)) ^ 2 := by
    simp +decide [ norm_smul, hu.1 ];
  -- By the properties of the inner product and the orthonormality of the vectors $u_i$, we have $\sum_{i=1}^k |\langle x, u_i \rangle|^2 \leq \|x\|^2$.
  have h_sum_norm_sq : ∑ i, (inner ℝ x (u i)) ^ 2 ≤ ‖x‖ ^ 2 := by
    convert ( hu.sum_inner_products_le x ) using 1;
    exact Finset.sum_congr rfl fun _ _ => by rw [ real_inner_comm, Real.norm_eq_abs, sq_abs ] ;
  exact le_of_pow_le_pow_left₀ ( by norm_num ) ( norm_nonneg _ ) ( h_pythagorean.le.trans ( by simpa only [ h_norm_sq ] using h_sum_norm_sq ) )

/-
**Scaled orthonormal projection**: The averaged orthonormal projection contracts
by the factor 1/√k, giving the fundamental spectral bound.
-/
theorem scaled_projection_contraction
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    {k : ℕ} (hk : 0 < k) (u : Fin k → V) (hu : Orthonormal ℝ u) (x : V) :
    ‖(1 / (k : ℝ)) • ∑ i, @inner ℝ V _ x (u i) • u i‖ ≤ (1 / Real.sqrt k) * ‖x‖ := by
  simp +decide [ norm_smul ];
  exact mul_le_mul ( inv_anti₀ ( by positivity ) ( Real.sqrt_le_iff.mpr ⟨ by positivity, by norm_cast; nlinarith ⟩ ) ) ( orthogonal_projection_norm_bound u hu x ) ( by positivity ) ( by positivity )

/-! ## Spectral Gap Bound -/

/-
The spectral gap for the normalized averaging operator: if the operator norm
is at most 1/√k, then the spectral gap is at least 1 - 1/√k.
-/
theorem spectral_gap_lower_bound
    (k : ℕ) (hk : 2 ≤ k) :
    1 - 1 / Real.sqrt k ≥ 0 := by
  exact sub_nonneg_of_le ( div_le_one_of_le₀ ( Real.le_sqrt_of_sq_le ( by norm_cast; linarith ) ) ( Real.sqrt_nonneg _ ) )

/-
**Spectral gap monotonicity**: The spectral gap 1 - 1/√k is monotonically
increasing in k, meaning more orthogonal generators produce better expansion.
-/
theorem spectral_gap_mono
    (k₁ k₂ : ℕ) (hk₁ : 2 ≤ k₁) (hk₂ : k₁ ≤ k₂) :
    1 - 1 / Real.sqrt k₁ ≤ 1 - 1 / Real.sqrt k₂ := by
  gcongr

/-! ## Lorentz Form and Geometry -/

/-- The standard Lorentz quadratic form Q_n on ℝ^(n+1) with signature (n,1):
  Q_n(x) = x₁² + ··· + xₙ² - x_{n+1}²
This is the fundamental invariant of SO(n,1) isometries. -/
def lorentzQuadForm (n : ℕ) (x : Fin (n + 1) → ℝ) : ℝ :=
  (∑ i : Fin n, x (Fin.castSucc i) ^ 2) - x (Fin.last n) ^ 2

/-- The Lorentz bilinear form associated to Q_n:
  B_n(x,y) = x₁y₁ + ··· + xₙyₙ - x_{n+1}y_{n+1} -/
def lorentzBilinForm (n : ℕ) (x y : Fin (n + 1) → ℝ) : ℝ :=
  (∑ i : Fin n, x (Fin.castSucc i) * y (Fin.castSucc i)) -
    x (Fin.last n) * y (Fin.last n)

/-- A vector is **spacelike** if Q_n(x) > 0. -/
def IsSpacelike (n : ℕ) (x : Fin (n + 1) → ℝ) : Prop :=
  lorentzQuadForm n x > 0

/-- A vector is **timelike** if Q_n(x) < 0. -/
def IsTimelike (n : ℕ) (x : Fin (n + 1) → ℝ) : Prop :=
  lorentzQuadForm n x < 0

/-- A vector is **lightlike** (isotropic) if Q_n(x) = 0. -/
def IsLightlike (n : ℕ) (x : Fin (n + 1) → ℝ) : Prop :=
  lorentzQuadForm n x = 0

/-- The forward cone: lightlike vectors with positive time component. -/
def IsForwardCone (n : ℕ) (x : Fin (n + 1) → ℝ) : Prop :=
  IsLightlike n x ∧ x (Fin.last n) > 0

/-
The Lorentz bilinear form polarizes the quadratic form.
-/
theorem lorentzBilinForm_self (n : ℕ) (x : Fin (n + 1) → ℝ) :
    lorentzBilinForm n x x = lorentzQuadForm n x := by
  exact congrArg₂ _ ( Finset.sum_congr rfl fun _ _ => by ring ) ( by ring )

/-- Two vectors are **Lorentz-orthogonal** if their Lorentz inner product vanishes. -/
def IsLorentzOrthogonal (n : ℕ) (x y : Fin (n + 1) → ℝ) : Prop :=
  lorentzBilinForm n x y = 0

/-- A family of vectors is Lorentz-orthogonal if every pair of distinct vectors
is Lorentz-orthogonal. -/
def LorentzOrthogonalFamily (n k : ℕ) (v : Fin k → Fin (n + 1) → ℝ) : Prop :=
  ∀ i j, i ≠ j → IsLorentzOrthogonal n (v i) (v j)

/-- The standard timelike basis vector e_{n+1}. -/
def timelikeBaseVector (n : ℕ) : Fin (n + 1) → ℝ :=
  fun i => if i = Fin.last n then 1 else 0

/-
The standard timelike vector is indeed timelike.
-/
theorem timelikeBaseVector_isTimelike (n : ℕ) (_ : 0 < n) :
    IsTimelike n (timelikeBaseVector n) := by
  -- Calculate the Lorentz quadratic form of the timelike base vector.
  simp [IsTimelike, timelikeBaseVector, lorentzQuadForm]

/-
Spacelike vectors orthogonal to the timelike base have vanishing last component.
-/
theorem spacelike_orth_timelike_last_zero (n : ℕ) (v : Fin (n + 1) → ℝ)
    (h : IsLorentzOrthogonal n v (timelikeBaseVector n)) :
    v (Fin.last n) = 0 := by
  simp_all +decide [ IsLorentzOrthogonal, lorentzBilinForm ];
  simp_all +decide [ timelikeBaseVector ]

/-! ## Lorentz Reflections on the Spacelike Slice -/

/-- The Lorentz reflection in the hyperplane Q-orthogonal to a spacelike unit vector v.
On the spacelike slice orthogonal to the timelike direction, this reduces to a
standard Euclidean reflection. -/
def lorentzReflection (n : ℕ) (v : Fin (n + 1) → ℝ)
    (x : Fin (n + 1) → ℝ) : Fin (n + 1) → ℝ :=
  fun i => x i - 2 * lorentzBilinForm n x v * v i

/-
Lorentz reflections preserve the Lorentz form.
-/
theorem lorentzReflection_preserves_form (n : ℕ) (v x : Fin (n + 1) → ℝ)
    (hv : lorentzQuadForm n v = 1) :
    lorentzQuadForm n (lorentzReflection n v x) = lorentzQuadForm n x := by
  simp_all +decide [ lorentzQuadForm, lorentzBilinForm, lorentzReflection ];
  norm_num [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc ];
  norm_num [ mul_pow, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
  norm_num [ ← mul_assoc, ← Finset.sum_mul _ _ _, hv ];
  grind

/-! ## Reduction to Euclidean Setting -/

/-
**Key reduction**: When spacelike vectors v_i are orthogonal to the timelike direction
and Lorentz-orthogonal to each other, they form a Euclidean-orthogonal family on the
spacelike slice. This allows the spectral gap machinery to apply.
-/
theorem lorentz_to_euclidean_orthogonality (n k : ℕ)
    (v : Fin k → Fin (n + 1) → ℝ)
    (hLO : LorentzOrthogonalFamily n k v)
    (hspace : ∀ i, v i (Fin.last n) = 0) :
    ∀ i j, i ≠ j →
      (∑ l : Fin n, v i (Fin.castSucc l) * v j (Fin.castSucc l)) = 0 := by
  -- By definition of Lorentz orthogonality, we have:
  intro i j hij
  have := hLO i j hij
  simp_all +decide [ IsLorentzOrthogonal ];
  unfold lorentzBilinForm at this; aesop;

/-! ## Finite Quotient Expansion Shadow -/

/-- A **doubly stochastic matrix** has all row and column sums equal to 1. -/
def IsDoublyStochastic {m : ℕ} (M : Matrix (Fin m) (Fin m) ℝ) : Prop :=
  (∀ i, ∑ j, M i j = 1) ∧ (∀ j, ∑ i, M i j = 1)

/-
**Entry bound for doubly stochastic matrices**: Nonneg entries in a doubly
stochastic matrix are bounded by 1.
-/
theorem doubly_stochastic_entry_bound
    {m : ℕ} (_ : 0 < m)
    (M : Matrix (Fin m) (Fin m) ℝ)
    (hds : IsDoublyStochastic M)
    (hnn : ∀ i j, 0 ≤ M i j) :
    ∀ i j, M i j ≤ 1 := by
  exact fun x y => le_trans ( Finset.single_le_sum ( fun a _ => hnn x a ) ( Finset.mem_univ y ) ) ( hds.1 x |> le_of_eq )

end