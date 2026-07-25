/-
# Vector-Valued EML Stone–Weierstrass via Affine Partition-of-Unity Coding

This file proves the vector-valued EML density theorem: scalar EML primitives
suffice to synthesize finite-dimensional output geometry through barycentric coding.

The main result (`vecEML_dense_of_scalar_dense`) states that if `S` is uniformly dense
in `C(X, ℝ)`, then the set of finite linear combinations `∑ᵢ φᵢ • vᵢ` with `φᵢ ∈ S`
and `vᵢ : Fin m → ℝ` constant vectors is uniformly dense in `C(X, Fin m → ℝ)`.

## Main definitions

* `scalarVec f v` — the continuous map `x ↦ (f x) • v` for `f : C(X, ℝ)` and `v : Fin m → ℝ`
* `VecEML S m` — the set of finite sums `∑ᵢ scalarVec (φ i) (v i)` with `φ i ∈ S`

## Main results

* `affine_coding_error_bound_pointwise` — pointwise perturbation bound for affine codings
* `affine_coding_error_bound` — sup-norm perturbation bound for affine codings
* `vecEML_dense_of_scalar_dense` — density of `VecEML S m` when `S` is dense in `C(X, ℝ)`
* `eml_vec_uniform_approx` — vector-valued EML approximation corollary
* `eml_vec_dense` — density of vector EML in `C(X, Fin m → ℝ)`
-/
import Mathlib

noncomputable section

open Finset ContinuousMap Real

/-! ## Core definitions -/

/-- Scalar-vector product: the continuous map `x ↦ f(x) * v j` for each coordinate `j`. -/
def scalarVec {X : Type*} [TopologicalSpace X] {m : ℕ}
    (f : C(X, ℝ)) (v : Fin m → ℝ) : C(X, Fin m → ℝ) where
  toFun x j := f x * v j
  continuous_toFun := continuous_pi fun _ => f.continuous.mul continuous_const

/-- `VecEML S m` is the set of continuous maps `F : C(X, Fin m → ℝ)` that can be written
as finite linear combinations `∑ᵢ scalarVec (φ i) (v i)` with each `φ i ∈ S`.
This is the vector class of "affine codings" using scalar weight functions from `S`. -/
def VecEML {X : Type*} [TopologicalSpace X]
    (S : Set C(X, ℝ)) (m : ℕ) : Set C(X, Fin m → ℝ) :=
  {F | ∃ n : ℕ, ∃ φ : Fin n → C(X, ℝ), ∃ v : Fin n → (Fin m → ℝ),
      (∀ i, φ i ∈ S) ∧
      F = ∑ i, scalarVec (φ i) (v i)}

/-! ## Basic properties of scalarVec -/

@[simp]
theorem scalarVec_apply {X : Type*} [TopologicalSpace X] {m : ℕ}
    (f : C(X, ℝ)) (v : Fin m → ℝ) (x : X) (j : Fin m) :
    scalarVec f v x j = f x * v j := rfl

/-! ## Membership in VecEML -/

/-- A finite sum of scalar-vector products with coefficients in `S` belongs to `VecEML S m`. -/
theorem sum_scalarVec_mem_VecEML {X : Type*} [TopologicalSpace X]
    {m n : ℕ} {S : Set C(X, ℝ)}
    {φ : Fin n → C(X, ℝ)} {v : Fin n → (Fin m → ℝ)}
    (hφ : ∀ i, φ i ∈ S) :
    (∑ i, scalarVec (φ i) (v i)) ∈ VecEML S m :=
  ⟨n, φ, v, hφ, rfl⟩

/-! ## Perturbation bounds for affine codings -/

/-
Pointwise perturbation bound: replacing scalar weights `ψ i` by `φ i` in an affine coding
with output vectors `y i` incurs at most `∑ i, |ψ i x - φ i x| * ‖y i‖` error at point `x`.
-/
theorem affine_coding_error_bound_pointwise {X : Type*} [TopologicalSpace X]
    {m n : ℕ} (ψ φ : Fin n → C(X, ℝ)) (y : Fin n → (Fin m → ℝ)) (x : X) :
    ‖(∑ i, scalarVec (ψ i) (y i)) x - (∑ i, scalarVec (φ i) (y i)) x‖ ≤
      ∑ i : Fin n, |ψ i x - φ i x| * ‖y i‖ := by
  -- By definition of scalarVec, we can rewrite the difference as a sum of scalar products.
  have h_diff : (∑ i, scalarVec (ψ i) (y i)) x - (∑ i, scalarVec (φ i) (y i)) x = ∑ i, (ψ i x - φ i x) • y i := by
    simp +decide [ sub_smul, Finset.sum_sub_distrib ];
    rfl;
  exact h_diff ▸ le_trans ( norm_sum_le _ _ ) ( Finset.sum_le_sum fun i _ => by rw [ norm_smul, Real.norm_eq_abs ] )

/-
Sup-norm perturbation bound: replacing scalar weights in an affine coding
incurs at most `(∑ i, ‖ψ i - φ i‖) * B` error when output vectors are bounded by `B`.
-/
theorem affine_coding_error_bound
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {m n : ℕ} (ψ φ : Fin n → C(X, ℝ)) (y : Fin n → (Fin m → ℝ))
    (B : ℝ) (hy : ∀ i, ‖y i‖ ≤ B) :
    ‖(∑ i, scalarVec (ψ i) (y i)) - (∑ i, scalarVec (φ i) (y i))‖ ≤
      (∑ i : Fin n, ‖(ψ i - φ i : C(X, ℝ))‖) * B := by
  -- Apply the pointwise bound to each term in the sum.
  have h_pointwise : ∀ x, ‖(∑ i, scalarVec (ψ i) (y i)) x - (∑ i, scalarVec (φ i) (y i)) x‖ ≤ (∑ i, ‖ψ i - φ i‖) * B := by
    intro x
    have h_pointwise : ∀ i, |ψ i x - φ i x| * ‖y i‖ ≤ ‖ψ i - φ i‖ * B := by
      exact fun i => mul_le_mul ( ContinuousMap.norm_coe_le_norm ( ψ i - φ i ) x ) ( hy i ) ( norm_nonneg _ ) ( norm_nonneg _ );
    simpa only [ Finset.sum_mul _ _ _ ] using le_trans ( affine_coding_error_bound_pointwise ψ φ y x ) ( Finset.sum_le_sum fun i _ => h_pointwise i );
  by_cases h : (∑ i, ‖ψ i - φ i‖) * B ≥ 0;
  · exact (norm_le (∑ i, scalarVec (ψ i) (y i) - ∑ i, scalarVec (φ i) (y i)) h).mpr h_pointwise;
  · exact False.elim ( h ( mul_nonneg ( Finset.sum_nonneg fun _ _ => norm_nonneg _ ) ( le_trans ( norm_nonneg _ ) ( hy ⟨ 0, Nat.pos_of_ne_zero ( by aesop_cat ) ⟩ ) ) ) )

/-! ## Main density theorem -/

/-
**Vector-valued density from scalar density.** If `S` is uniformly dense in `C(X, ℝ)`,
then `VecEML S m` is uniformly dense in `C(X, Fin m → ℝ)`.

The proof constructs the approximation coordinate-by-coordinate: for each `j : Fin m`,
approximate the j-th coordinate projection `x ↦ F x j` by some `gⱼ ∈ S`, then form
`G = ∑ⱼ scalarVec gⱼ eⱼ` where `eⱼ` is the j-th standard basis vector.
Since `G x j = gⱼ x` and each `|F x j - gⱼ x| < ε`, we get `‖F - G‖ < ε`.
This `G` belongs to `VecEML S m` by definition.
-/
theorem vecEML_dense_of_scalar_dense
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (S : Set C(X, ℝ))
    (h_dense : ∀ f : C(X, ℝ), ∀ ε > 0, ∃ g ∈ S, ‖f - g‖ < ε)
    {m : ℕ} (hm : 0 < m)
    (F : C(X, Fin m → ℝ)) (ε : ℝ) (hε : 0 < ε) :
    ∃ G ∈ VecEML S m, ‖F - G‖ < ε := by
  choose φ hφ using h_dense;
  -- By definition of $F$, we can write it as a finite sum of coordinate projections.
  obtain ⟨n, φ, hφ⟩ : ∃ n : ℕ, ∃ φ : Fin m → C(X, ℝ), F = ∑ j, scalarVec (φ j) (Pi.single j 1) := by
    refine' ⟨ m, fun j => F.comp ( ContinuousMap.id X ) |> ContinuousMap.comp ( ContinuousMap.mk fun x => x j ), _ ⟩;
    ext x j; simp +decide [ scalarVec ] ;
    simp +decide [ Pi.single_apply ];
  -- For each $j$, choose $g_j \in S$ such that $\| \phi_j - g_j \| < \frac{\epsilon}{m}$.
  obtain ⟨g, hg⟩ : ∃ g : Fin m → C(X, ℝ), (∀ j, g j ∈ S) ∧ ∀ j, ‖φ j - g j‖ < ε / m := by
    rename_i h₁ h₂;
    exact ⟨ _, fun j => ( h₂ _ _ ( div_pos hε ( Nat.cast_pos.mpr hm ) ) ) |>.1, fun j => ( h₂ _ _ ( div_pos hε ( Nat.cast_pos.mpr hm ) ) ) |>.2 ⟩;
  refine' ⟨ ∑ j, scalarVec ( g j ) ( Pi.single j 1 ), _, _ ⟩;
  · exact sum_scalarVec_mem_VecEML hg.1;
  · refine' lt_of_le_of_lt ( _ : ‖F - ∑ j, scalarVec ( g j ) ( Pi.single j 1 )‖ ≤ ∑ j, ‖φ j - g j‖ ) _;
    · convert affine_coding_error_bound ( fun j => φ j ) ( fun j => g j ) ( fun j => Pi.single j 1 ) 1 _ using 1;
      · rw [ hφ ];
      · ring;
      · intro j; rw [ pi_norm_le_iff_of_nonneg ] <;> norm_num;
        intro i; by_cases hi : i = j <;> simp +decide [ hi, Pi.single_apply ] ;
    · exact lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, hm ⟩, Finset.mem_univ _ ⟩ fun j _ => hg.2 j ) ( by simp +decide [ mul_div_cancel₀, hm.ne' ] )

/-! ## EML-specific definitions and corollaries -/

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
variable {n : ℕ} (Φ : Fin n → C(X, ℝ))

/-- The logistic (sigmoid) activation function. -/
def logistic' (x : ℝ) : ℝ := 1 / (1 + exp (-x))

/-- EML exponential generator: `exp(∑ᵢ wᵢ Φᵢ(x) + b)`. -/
def emlExpGen' (w : Fin n → ℝ) (b : ℝ) : C(X, ℝ) :=
  ⟨fun x => exp (∑ i : Fin n, w i * Φ i x + b),
    (continuous_finset_sum _ (fun i _ => continuous_const.mul (Φ i).continuous) |>.add
      continuous_const).rexp⟩

/-- EML logistic generator: `σ(∑ᵢ wᵢ Φᵢ(x) + b)`. -/
def emlLogisticGen' (w : Fin n → ℝ) (b : ℝ) : C(X, ℝ) :=
  ⟨fun x => logistic' (∑ i : Fin n, w i * Φ i x + b),
    (by unfold logistic'
        apply Continuous.div continuous_const
        · exact continuous_const.add (continuous_neg.rexp)
        · intro x; positivity : Continuous logistic').comp
      (continuous_finset_sum _ (fun i _ => continuous_const.mul (Φ i).continuous) |>.add
        continuous_const)⟩

/-- The set of all EML generators (exponential and logistic). -/
def emlGenerators' : Set C(X, ℝ) :=
  {f | ∃ w b, f = emlExpGen' Φ w b} ∪ {f | ∃ w b, f = emlLogisticGen' Φ w b}

/-- The ℝ-subalgebra of C(X, ℝ) generated by the EML generators. -/
def emlSubalgebra' : Subalgebra ℝ C(X, ℝ) :=
  Algebra.adjoin ℝ (emlGenerators' Φ)

/-- The EML subalgebra closure, as a set in `C(X, ℝ)`. -/
def EMLClosure : Set C(X, ℝ) :=
  ↑(emlSubalgebra' Φ).topologicalClosure

omit [CompactSpace X] [T2Space X] in
/-- The EML subalgebra separates points of X. -/
lemma emlSubalgebra'_separatesPoints
    (_hn : 1 ≤ n)
    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y) :
    (emlSubalgebra' Φ).SeparatesPoints := by
  intro x y hxy
  obtain ⟨j, hj⟩ := hΦ x y hxy
  let w : Fin n → ℝ := fun i => if i = j then 1 else 0
  refine ⟨(fun p => p) (emlExpGen' Φ w 0), ?_, ?_⟩
  · exact ⟨emlExpGen' Φ w 0, Algebra.subset_adjoin (Set.mem_union_left _ ⟨w, 0, rfl⟩), rfl⟩
  · simp only [emlExpGen', ContinuousMap.coe_mk, w]
    intro h
    apply hj
    have := exp_eq_exp.mp h
    simp at this
    linarith

/-- The EML subalgebra closure is all of `C(X, ℝ)`. -/
theorem eml_closure_eq_top
    (hn : 1 ≤ n)
    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y) :
    (emlSubalgebra' Φ).topologicalClosure = ⊤ :=
  ContinuousMap.subalgebra_topologicalClosure_eq_top_of_separatesPoints _
    (emlSubalgebra'_separatesPoints Φ hn hΦ)

/-
EML closure is dense in `C(X, ℝ)`: for any `f` and `ε > 0`, there exists `g` in the
EML closure with `‖f - g‖ < ε`.
-/
theorem eml_closure_dense
    [Nonempty X]
    (hn : 1 ≤ n)
    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y) :
    ∀ f : C(X, ℝ), ∀ ε > 0, ∃ g ∈ EMLClosure Φ, ‖f - g‖ < ε := by
  exact fun f ε εpos => ⟨ f, by simp [ EMLClosure, eml_closure_eq_top Φ hn hΦ ], by simpa using εpos ⟩

/-- **Vector-valued EML uniform approximation.** Any continuous map `F : X → ℝ^m`
can be uniformly approximated by finite affine codings with scalar weights from the
EML closure. -/
theorem eml_vec_uniform_approx
    [Nonempty X]
    (hn : 1 ≤ n)
    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y)
    {m : ℕ} (hm : 0 < m)
    (F : C(X, Fin m → ℝ)) (ε : ℝ) (hε : 0 < ε) :
    ∃ G ∈ VecEML (EMLClosure Φ) m, ‖F - G‖ < ε :=
  vecEML_dense_of_scalar_dense _ (eml_closure_dense Φ hn hΦ) hm F ε hε

/-- **Dense image of vector EML.** The set of affine codings with EML scalar weights
is dense in `C(X, Fin m → ℝ)`. -/
theorem eml_vec_dense
    [Nonempty X]
    (hn : 1 ≤ n)
    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y)
    {m : ℕ} (hm : 0 < m) :
    Dense (VecEML (EMLClosure Φ) m : Set C(X, Fin m → ℝ)) := by
  rw [Metric.dense_iff]
  intro F ε hε
  obtain ⟨G, hGmem, hGclose⟩ := eml_vec_uniform_approx Φ hn hΦ hm F ε hε
  exact ⟨G, ⟨by rwa [Metric.mem_ball, dist_comm, dist_eq_norm], hGmem⟩⟩