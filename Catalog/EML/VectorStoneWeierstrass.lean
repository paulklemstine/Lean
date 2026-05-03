/-
# Finite-Dimensional Vector-Valued Stone–Weierstrass via Dual-Basis Scalarization

This file establishes a finite-dimensional vector-valued extension of the scalar
Stone–Weierstrass theorem by reducing approximation in `C(X, V)` to simultaneous
scalar approximation along a finite basis of `V`.

## Main results

* `VectorSW.norm_reconstruction_le` — operator norm bound on the reconstruction map.
* `VectorSW.dist_reconstructCM_le` — sup-norm reconstruction error bound.
* `VectorSW.closure_eq_top_findim` — general finite-dim density from scalar density.
* `VectorSW.dense_of_scalar_density` — abstract density lifting from scalar to vector.
* `VectorSW.eml_uniform_dense_finvec` — EML corollary for `Fin n → ℝ`.
* `VectorSW.eml_closure_eq_top_of_scalar_dense` — simplified version for natural model classes.

## References

The argument applies finite-dimensional norm equivalence to reduce vector-valued
uniform approximation to coordinatewise scalar approximation.
-/
import Mathlib

noncomputable section

open Module Finset ContinuousMap Topology

namespace VectorSW

/-! ### Algebraic identities -/

section Algebra

variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V] [Fintype ι]

/-
Key algebraic identity: the difference of two reconstructions equals
    reconstruction of the differences.
-/
theorem reconstruction_sub (b : Basis ι ℝ V) (a c : ι → ℝ) :
    (∑ i, a i • b i) - (∑ i, c i • b i) = ∑ i, (a i - c i) • b i := by
  simp +decide only [sub_smul, sum_sub_distrib]

/-
Reconstruction error identity: the difference between a reconstructed approximant
    and the target equals reconstruction of coordinate errors.
-/
theorem reconstruction_error_eq (b : Basis ι ℝ V) (v : V) (c : ι → ℝ) :
    (∑ i, c i • b i) - v = ∑ i, (c i - b.coord i v) • b i := by
  simp +decide [ sub_smul, b.sum_repr ]

end Algebra

/-! ### Reconstruction norm bound -/

section NormBound

variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
  [FiniteDimensional ℝ V] [Fintype ι]

/-
Norm of reconstruction is bounded by a constant times the norm of coordinate vector.
    This follows from finite-dimensional norm equivalence: every linear map from a
    finite-dimensional space is bounded.
-/
omit [FiniteDimensional ℝ V] in
theorem norm_reconstruction_le (b : Basis ι ℝ V) :
    ∃ C > 0, ∀ c : ι → ℝ, ‖∑ i, c i • b i‖ ≤ C * ‖c‖ := by
  have h_linear : ∃ T : (ι → ℝ) →ₗ[ℝ] V, ∀ c : ι → ℝ, T c = ∑ i, c i • b i := by
    exact ⟨ ∑ i, LinearMap.smulRight ( LinearMap.proj i ) ( b i ), fun c => by simp +decide [LinearMap.sum_apply] ⟩;
  cases' h_linear with T hT;
  have h_linear : ∃ C > 0, ∀ c : ι → ℝ, ‖T c‖ ≤ C * ‖c‖ := by
    have h_linear_map : ∃ T' : (ι → ℝ) →L[ℝ] V, T = T'.toLinearMap := by
      exact ⟨ T.toContinuousLinearMap, rfl ⟩
    obtain ⟨ T', rfl ⟩ := h_linear_map;
    exact ContinuousLinearMap.bound T';
  aesop

end NormBound

/-! ### Continuous map reconstruction -/

section CMapReconstruction

variable {X : Type*} [TopologicalSpace X] [CompactSpace X]
variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
  [FiniteDimensional ℝ V] [Fintype ι]

/-- The coordinate map: extract the i-th basis coordinate of a vector-valued continuous map. -/
def basisCoordMap (b : Basis ι ℝ V) (i : ι) (f : C(X, V)) : C(X, ℝ) :=
  ⟨fun x => b.coord i (f x),
    (LinearMap.continuous_of_finiteDimensional (b.coord i)).comp f.continuous⟩

/-- Reconstruct a vector-valued continuous map from scalar coordinate maps. -/
def reconstructCM (b : Basis ι ℝ V) (φ : ι → C(X, ℝ)) : C(X, V) :=
  ⟨fun x => ∑ i, (φ i x) • b i,
    continuous_finset_sum _ (fun i _ => (φ i).continuous.smul continuous_const)⟩

omit [CompactSpace X] [FiniteDimensional ℝ V] in
@[simp]
theorem reconstructCM_apply (b : Basis ι ℝ V) (φ : ι → C(X, ℝ)) (x : X) :
    reconstructCM b φ x = ∑ i, (φ i x) • b i := rfl

omit [CompactSpace X] in
/-- Exact reconstruction: if `φ i = basisCoordMap b i f` then `reconstructCM b φ = f`. -/
theorem reconstructCM_eq_of_coord (b : Basis ι ℝ V) (f : C(X, V))
    (φ : ι → C(X, ℝ)) (hφ : ∀ i, φ i = basisCoordMap b i f) :
    reconstructCM b φ = f := by
  ext x
  simp only [reconstructCM_apply, hφ, basisCoordMap, ContinuousMap.coe_mk]
  exact b.sum_repr (f x)

/-
**Pointwise reconstruction bound**: the error at each point is bounded.
-/
omit [CompactSpace X] [FiniteDimensional ℝ V] in
theorem norm_sub_reconstructCM_le (b : Basis ι ℝ V) (g : C(X, V)) (φ : ι → C(X, ℝ))
    {C_val : ℝ} (_hC : 0 < C_val)
    (hC_bound : ∀ (c : ι → ℝ), ‖∑ i, c i • b i‖ ≤ C_val * ‖c‖)
    (x : X) :
    ‖reconstructCM b φ x - g x‖ ≤ C_val * ‖fun i => φ i x - b.coord i (g x)‖ := by
  convert hC_bound _ using 1;
  simp +decide [ sub_smul, Finset.sum_sub_distrib, reconstructCM_apply ]

/-
**Sup-norm reconstruction bound**: the sup norm of the reconstruction error is bounded
    by a constant times the maximum coordinate error.
-/
theorem dist_reconstructCM_le [Nonempty ι] (b : Basis ι ℝ V) :
    ∃ C > 0, ∀ (g : C(X, V)) (φ : ι → C(X, ℝ)),
      dist (reconstructCM b φ) g ≤
        C * (Finset.univ.sup' Finset.univ_nonempty
          (fun i => dist (φ i) (basisCoordMap b i g))) := by
  -- Use norm_reconstruction_le to get a constant C.
  obtain ⟨C, hC⟩ := (norm_reconstruction_le b);
  refine' ⟨ C, hC.1, _ ⟩;
  intro g φ
  have h_dist_le : ∀ x : X, ‖reconstructCM b φ x - g x‖ ≤ C * (Finset.univ.sup' (by simp) (fun i => ‖φ i x - b.coord i (g x)‖)) := by
    intro x
    have h_error : ‖reconstructCM b φ x - g x‖ ≤ C * ‖(fun i => φ i x - b.coord i (g x))‖ := by
      convert norm_sub_reconstructCM_le b g φ hC.1 hC.2 x using 1;
    refine' h_error.trans ( mul_le_mul_of_nonneg_left _ hC.1.le );
    exact pi_norm_le_iff_of_nonneg ( by exact le_trans ( norm_nonneg _ ) ( Finset.le_sup' ( fun i => ‖ ( φ i ) x - ( b.coord i ) ( g x )‖ ) ( Finset.mem_univ ( Classical.arbitrary ι ) ) ) ) |>.2 fun i => Finset.le_sup' ( fun i => ‖ ( φ i ) x - ( b.coord i ) ( g x )‖ ) ( Finset.mem_univ i );
  simp_all +decide [ dist_eq_norm, ContinuousMap.norm_le ];
  intro x
  specialize h_dist_le x
  refine' le_trans h_dist_le _;
  gcongr;
  · linarith;
  · exact ContinuousMap.norm_coe_le_norm ( φ _ - basisCoordMap b _ g ) x

/-- The set of scalar coordinate projections of elements of `A` along basis element `i`. -/
def scalarProjections (b : Basis ι ℝ V) (A : Set C(X, V)) (i : ι) : Set C(X, ℝ) :=
  (fun f => basisCoordMap b i f) '' A

end CMapReconstruction

/-! ### Main density theorems -/

section Density

variable {X : Type*} [TopologicalSpace X] [CompactSpace X]
variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
  [FiniteDimensional ℝ V] [Fintype ι] [Nonempty ι]

/-
**Main theorem: Finite-dimensional vector-valued density from scalar density**.

    For a compact space `X` and finite-dimensional normed space `V` with basis `b`,
    a set `A ⊆ C(X, V)` has dense closure if:
    1. For each basis coordinate `i`, the scalar projections are dense in `C(X, ℝ)`.
    2. Reconstructed maps from coordinate-wise closure elements lie in `closure A`.
-/
omit [CompactSpace X] [Nonempty ι] in
theorem closure_eq_top_findim
    (b : Basis ι ℝ V)
    (A : Set C(X, V))
    (hscalar_dense : ∀ i : ι, closure (scalarProjections b A i) = ⊤)
    (hreconstruct : ∀ φ : ι → C(X, ℝ),
      (∀ i, φ i ∈ closure (scalarProjections b A i)) →
      reconstructCM b φ ∈ closure A) :
    closure A = ⊤ := by
  -- By definition of scalarProjections and hscalar_dense, for all f ∈ C(X, V) and i, basisCoordMap b i f ∈ closure (scalarProjections b A i).
  have h_all_in_closure : ∀ f : C(X, V), ∀ i : ι, basisCoordMap b i f ∈ closure (scalarProjections b A i) := by
    aesop;
  exact Set.eq_univ_iff_forall.mpr fun f => by simpa [ reconstructCM_eq_of_coord b f _ fun i => rfl ] using hreconstruct _ fun i => h_all_in_closure f i;

/-
**Abstract vector density from scalar density**: if a dense scalar set `S` can be
    lifted to vector approximants via basis reconstruction, then `A` is dense.
-/
theorem dense_of_scalar_density
    (b : Basis ι ℝ V)
    (S : Set C(X, ℝ))
    (hS_dense : closure S = ⊤)
    (A : Set C(X, V))
    (h_contains_reconst : ∀ ψ : ι → C(X, ℝ),
        (∀ i, ψ i ∈ S) → reconstructCM b ψ ∈ A) :
    closure A = ⊤ := by
  refine' eq_top_iff.2 fun f hf => _;
  -- Use dist_reconstructCM_le to get constant C.
  obtain ⟨C, hC_pos, hC_bound⟩ : ∃ C > 0, ∀ (g : C(X, V)) (φ : ι → C(X, ℝ)),
    dist (reconstructCM b φ) g ≤ C * (Finset.univ.sup' Finset.univ_nonempty (fun i => dist (φ i) (basisCoordMap b i g))) := dist_reconstructCM_le b;
  -- Given f : C(X, V) and ε > 0, we can find ψ_i ∈ S with dist(ψ_i, basisCoordMap b i f) < ε/C.
  have h_approx : ∀ ε > 0, ∃ ψ : ι → C(X, ℝ), (∀ i, ψ i ∈ S) ∧ Finset.univ.sup' Finset.univ_nonempty (fun i => dist (ψ i) (basisCoordMap b i f)) < ε / C := by
    intro ε ε_pos
    have h_approx : ∀ i : ι, ∃ ψ_i ∈ S, dist ψ_i (basisCoordMap b i f) < ε / C := by
      intro i
      have h_approx_i : basisCoordMap b i f ∈ closure S := by
        aesop;
      rw [ Metric.mem_closure_iff ] at h_approx_i;
      simpa only [ dist_comm ] using h_approx_i ( ε / C ) ( div_pos ε_pos hC_pos );
    choose ψ hψ using h_approx;
    have h_sup_lt : ∃ i, ∀ j, dist (ψ j) (basisCoordMap b j f) ≤ dist (ψ i) (basisCoordMap b i f) := by
      simpa using Finset.exists_max_image Finset.univ ( fun i => dist ( ψ i ) ( basisCoordMap b i f ) ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩;
    exact ⟨ ψ, fun i => hψ i |>.1, lt_of_le_of_lt ( Finset.sup'_le _ _ fun i _ => h_sup_lt.choose_spec i ) ( hψ _ |>.2 ) ⟩;
  rw [ Metric.mem_closure_iff ];
  exact fun ε ε_pos => by rcases h_approx ε ε_pos with ⟨ ψ, hψS, hψε ⟩ ; exact ⟨ _, h_contains_reconst ψ hψS, by rw [ dist_comm ] ; exact lt_of_le_of_lt ( hC_bound _ _ ) ( by rwa [ lt_div_iff₀' hC_pos ] at hψε ) ⟩ ;

end Density

/-! ### EML corollary for `Fin n → ℝ` -/

section EML

variable {X : Type*} [TopologicalSpace X] [CompactSpace X]

/-
**EML multi-output approximation for `Fin n → ℝ`**.

    If each scalar coordinate output can be densely approximated, and coordinate
    approximants can be assembled into vector-valued model outputs, then the model
    class is dense in `C(X, Fin n → ℝ)`.
-/
omit [CompactSpace X] in
theorem eml_uniform_dense_finvec (n : ℕ) (_hn : 0 < n)
    (A : Set C(X, Fin n → ℝ))
    (hcoord : ∀ i : Fin n,
        closure {φ : C(X, ℝ) | ∃ f ∈ A, ∀ x, φ x = f x i} = ⊤)
    (hassemble : ∀ ψ : Fin n → C(X, ℝ),
        (∀ i, ψ i ∈ closure {φ : C(X, ℝ) | ∃ f ∈ A, ∀ x, φ x = f x i}) →
        (⟨fun x i => ψ i x,
          continuous_pi (fun i => (ψ i).continuous)⟩ : C(X, Fin n → ℝ))
          ∈ closure A) :
    closure A = ⊤ := by
  simp_all +decide [ Set.ext_iff ];
  intro f;
  convert hassemble ( fun i => ⟨ fun x => f x i, f.continuous.comp continuous_id' |> Continuous.comp ( continuous_apply i ) ⟩ )

/-
**Simplified EML vector approximation**: when `A` naturally contains all
    coordinate-wise assemblies from a dense scalar set `S`.
-/
theorem eml_closure_eq_top_of_scalar_dense (n : ℕ) (hn : 0 < n)
    (S : Set C(X, ℝ))
    (hS_dense : closure S = ⊤)
    (A : Set C(X, Fin n → ℝ))
    (h_contains_pi : ∀ ψ : Fin n → C(X, ℝ),
        (∀ i, ψ i ∈ S) →
        (⟨fun x i => ψ i x,
          continuous_pi (fun i => (ψ i).continuous)⟩ : C(X, Fin n → ℝ))
          ∈ A) :
    closure A = ⊤ := by
  convert dense_of_scalar_density (ι := Fin n) (Pi.basisFun ℝ (Fin n)) _ hS_dense _ _
  · exact Fin.pos_iff_nonempty.mp hn
  · intro ψ hψ
    convert h_contains_pi ψ hψ
    simp +decide [reconstructCM, Pi.single_apply]

end EML

end VectorSW