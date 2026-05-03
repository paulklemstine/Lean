--- a/EML/VectorStoneWeierstrass.lean
+++ b/EML/VectorStoneWeierstrass.lean
@@ -1,272 +1,372 @@
 /-
-# Finite-Dimensional Vector-Valued Stone–Weierstrass via Dual-Basis Scalarization
-
-This file establishes a finite-dimensional vector-valued extension of the scalar
-Stone–Weierstrass theorem by reducing approximation in `C(X, V)` to simultaneous
-scalar approximation along a finite basis of `V`.
+# Vector-Valued EML Stone–Weierstrass Theorem
+
+This file lifts the scalar Stone–Weierstrass density theorem from `C(X, ℝ)` to
+finite-dimensional vector-valued codomains `C(X, Fin m → ℝ)`.
+
+## Main definitions
+
+* `coordMap i` — the `i`-th coordinate projection as a continuous map
+* `VecClass A m` — the coordinatewise vector class attached to a scalar class `A`
+* `CoupledVecClass A m` — shared-feature class with continuous output coupling
 
 ## Main results
 
-* `VectorSW.norm_reconstruction_le` — operator norm bound on the reconstruction map.
-* `VectorSW.dist_reconstructCM_le` — sup-norm reconstruction error bound.
-* `VectorSW.closure_eq_top_findim` — general finite-dim density from scalar density.
-* `VectorSW.dense_of_scalar_density` — abstract density lifting from scalar to vector.
-* `VectorSW.eml_uniform_dense_finvec` — EML corollary for `Fin n → ℝ`.
-* `VectorSW.eml_closure_eq_top_of_scalar_dense` — simplified version for natural model classes.
-
-## References
-
-The argument applies finite-dimensional norm equivalence to reduce vector-valued
-uniform approximation to coordinatewise scalar approximation.
+* `closure_vecClass_eq_univ_of_scalar` — if `A` is dense in `C(X, ℝ)`, then
+  `VecClass A m` is dense in `C(X, Fin m → ℝ)`
+* `exists_mem_vecClass_uniformApprox` — ε-approximation form
+* `dense_coupledVecClass_of_dense_scalar` — density of the coupled class
+* `comp_mem_coupledVecClass` — closure under continuous output postcomposition
+* `dense_into_compactRange_of_retraction` — density with retraction onto compact target
+* `softmaxMap_mem_stdSimplex` — softmax maps into the standard simplex
+* `eml_vec_stoneWeierstrass` — EML specialization
+
+## Mathematical significance
+
+This development upgrades scalar EML universality into a genuinely usable
+vector-valued approximation theory, providing the formal bridge from scalar
+universality to multiclass classifiers, controllers, and constrained outputs.
 -/
 import Mathlib
 
 noncomputable section
 
-open Module Finset ContinuousMap Topology
-
-namespace VectorSW
-
-/-! ### Algebraic identities -/
-
-section Algebra
-
-variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V] [Fintype ι]
-
-/-
-Key algebraic identity: the difference of two reconstructions equals
-    reconstruction of the differences.
--/
-theorem reconstruction_sub (b : Basis ι ℝ V) (a c : ι → ℝ) :
-    (∑ i, a i • b i) - (∑ i, c i • b i) = ∑ i, (a i - c i) • b i := by
-  simp +decide only [sub_smul, sum_sub_distrib]
-
-/-
-Reconstruction error identity: the difference between a reconstructed approximant
-    and the target equals reconstruction of coordinate errors.
--/
-theorem reconstruction_error_eq (b : Basis ι ℝ V) (v : V) (c : ι → ℝ) :
-    (∑ i, c i • b i) - v = ∑ i, (c i - b.coord i v) • b i := by
-  simp +decide [ sub_smul, b.sum_repr ]
-
-end Algebra
-
-/-! ### Reconstruction norm bound -/
-
-section NormBound
-
-variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
-  [FiniteDimensional ℝ V] [Fintype ι]
-
-/-
-Norm of reconstruction is bounded by a constant times the norm of coordinate vector.
-    This follows from finite-dimensional norm equivalence: every linear map from a
-    finite-dimensional space is bounded.
--/
-omit [FiniteDimensional ℝ V] in
-theorem norm_reconstruction_le (b : Basis ι ℝ V) :
-    ∃ C > 0, ∀ c : ι → ℝ, ‖∑ i, c i • b i‖ ≤ C * ‖c‖ := by
-  have h_linear : ∃ T : (ι → ℝ) →ₗ[ℝ] V, ∀ c : ι → ℝ, T c = ∑ i, c i • b i := by
-    exact ⟨ ∑ i, LinearMap.smulRight ( LinearMap.proj i ) ( b i ), fun c => by simp +decide [LinearMap.sum_apply] ⟩;
-  cases' h_linear with T hT;
-  have h_linear : ∃ C > 0, ∀ c : ι → ℝ, ‖T c‖ ≤ C * ‖c‖ := by
-    have h_linear_map : ∃ T' : (ι → ℝ) →L[ℝ] V, T = T'.toLinearMap := by
-      exact ⟨ T.toContinuousLinearMap, rfl ⟩
-    obtain ⟨ T', rfl ⟩ := h_linear_map;
-    exact ContinuousLinearMap.bound T';
-  aesop
-
-end NormBound
-
-/-! ### Continuous map reconstruction -/
-
-section CMapReconstruction
-
-variable {X : Type*} [TopologicalSpace X] [CompactSpace X]
-variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
-  [FiniteDimensional ℝ V] [Fintype ι]
-
-/-- The coordinate map: extract the i-th basis coordinate of a vector-valued continuous map. -/
-def basisCoordMap (b : Basis ι ℝ V) (i : ι) (f : C(X, V)) : C(X, ℝ) :=
-  ⟨fun x => b.coord i (f x),
-    (LinearMap.continuous_of_finiteDimensional (b.coord i)).comp f.continuous⟩
-
-/-- Reconstruct a vector-valued continuous map from scalar coordinate maps. -/
-def reconstructCM (b : Basis ι ℝ V) (φ : ι → C(X, ℝ)) : C(X, V) :=
-  ⟨fun x => ∑ i, (φ i x) • b i,
-    continuous_finset_sum _ (fun i _ => (φ i).continuous.smul continuous_const)⟩
-
-omit [CompactSpace X] [FiniteDimensional ℝ V] in
+open ContinuousMap Set Topology Real
+
+variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
+
+/-! ## Core Definitions -/
+
+/-- The `i`-th coordinate projection as a continuous map `C(Fin m → ℝ, ℝ)`. -/
+def coordMap (m : ℕ) (i : Fin m) : C(Fin m → ℝ, ℝ) :=
+  ⟨fun x => x i, continuous_apply i⟩
+
+/-- The coordinatewise vector class: `F ∈ VecClass A m` iff every coordinate
+    projection `(coordMap m i).comp F` belongs to the scalar class `A`. -/
+def VecClass (A : Set C(X, ℝ)) (m : ℕ) : Set C(X, Fin m → ℝ) :=
+  {F | ∀ i : Fin m, (coordMap m i).comp F ∈ A}
+
+omit [CompactSpace X] [T2Space X] in
+/-- Membership characterization for `VecClass`. -/
+theorem mem_vecClass_iff {A : Set C(X, ℝ)} {m : ℕ} {F : C(X, Fin m → ℝ)} :
+    F ∈ VecClass A m ↔ ∀ i : Fin m, (coordMap m i).comp F ∈ A :=
+  Iff.rfl
+
+/-- Assemble a vector-valued continuous map from coordinate functions. -/
+def assembleVec {m : ℕ} (g : Fin m → C(X, ℝ)) : C(X, Fin m → ℝ) :=
+  ⟨fun x i => g i x, continuous_pi (fun i => (g i).continuous)⟩
+
+omit [CompactSpace X] [T2Space X] in
 @[simp]
-theorem reconstructCM_apply (b : Basis ι ℝ V) (φ : ι → C(X, ℝ)) (x : X) :
-    reconstructCM b φ x = ∑ i, (φ i x) • b i := rfl
-
-omit [CompactSpace X] in
-/-- Exact reconstruction: if `φ i = basisCoordMap b i f` then `reconstructCM b φ = f`. -/
-theorem reconstructCM_eq_of_coord (b : Basis ι ℝ V) (f : C(X, V))
-    (φ : ι → C(X, ℝ)) (hφ : ∀ i, φ i = basisCoordMap b i f) :
-    reconstructCM b φ = f := by
-  ext x
-  simp only [reconstructCM_apply, hφ, basisCoordMap, ContinuousMap.coe_mk]
-  exact b.sum_repr (f x)
-
-/-
-**Pointwise reconstruction bound**: the error at each point is bounded.
--/
-omit [CompactSpace X] [FiniteDimensional ℝ V] in
-theorem norm_sub_reconstructCM_le (b : Basis ι ℝ V) (g : C(X, V)) (φ : ι → C(X, ℝ))
-    {C_val : ℝ} (_hC : 0 < C_val)
-    (hC_bound : ∀ (c : ι → ℝ), ‖∑ i, c i • b i‖ ≤ C_val * ‖c‖)
-    (x : X) :
-    ‖reconstructCM b φ x - g x‖ ≤ C_val * ‖fun i => φ i x - b.coord i (g x)‖ := by
-  convert hC_bound _ using 1;
-  simp +decide [ sub_smul, Finset.sum_sub_distrib, reconstructCM_apply ]
-
-/-
-**Sup-norm reconstruction bound**: the sup norm of the reconstruction error is bounded
-    by a constant times the maximum coordinate error.
--/
-theorem dist_reconstructCM_le [Nonempty ι] (b : Basis ι ℝ V) :
-    ∃ C > 0, ∀ (g : C(X, V)) (φ : ι → C(X, ℝ)),
-      dist (reconstructCM b φ) g ≤
-        C * (Finset.univ.sup' Finset.univ_nonempty
-          (fun i => dist (φ i) (basisCoordMap b i g))) := by
-  -- Use norm_reconstruction_le to get a constant C.
-  obtain ⟨C, hC⟩ := (norm_reconstruction_le b);
-  refine' ⟨ C, hC.1, _ ⟩;
-  intro g φ
-  have h_dist_le : ∀ x : X, ‖reconstructCM b φ x - g x‖ ≤ C * (Finset.univ.sup' (by simp) (fun i => ‖φ i x - b.coord i (g x)‖)) := by
-    intro x
-    have h_error : ‖reconstructCM b φ x - g x‖ ≤ C * ‖(fun i => φ i x - b.coord i (g x))‖ := by
-      convert norm_sub_reconstructCM_le b g φ hC.1 hC.2 x using 1;
-    refine' h_error.trans ( mul_le_mul_of_nonneg_left _ hC.1.le );
-    exact pi_norm_le_iff_of_nonneg ( by exact le_trans ( norm_nonneg _ ) ( Finset.le_sup' ( fun i => ‖ ( φ i ) x - ( b.coord i ) ( g x )‖ ) ( Finset.mem_univ ( Classical.arbitrary ι ) ) ) ) |>.2 fun i => Finset.le_sup' ( fun i => ‖ ( φ i ) x - ( b.coord i ) ( g x )‖ ) ( Finset.mem_univ i );
-  simp_all +decide [ dist_eq_norm, ContinuousMap.norm_le ];
-  intro x
-  specialize h_dist_le x
-  refine' le_trans h_dist_le _;
-  gcongr;
-  · linarith;
-  · exact ContinuousMap.norm_coe_le_norm ( φ _ - basisCoordMap b _ g ) x
-
-/-- The set of scalar coordinate projections of elements of `A` along basis element `i`. -/
-def scalarProjections (b : Basis ι ℝ V) (A : Set C(X, V)) (i : ι) : Set C(X, ℝ) :=
-  (fun f => basisCoordMap b i f) '' A
-
-end CMapReconstruction
-
-/-! ### Main density theorems -/
-
-section Density
-
-variable {X : Type*} [TopologicalSpace X] [CompactSpace X]
-variable {V ι : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
-  [FiniteDimensional ℝ V] [Fintype ι] [Nonempty ι]
-
-/-
-**Main theorem: Finite-dimensional vector-valued density from scalar density**.
-
-    For a compact space `X` and finite-dimensional normed space `V` with basis `b`,
-    a set `A ⊆ C(X, V)` has dense closure if:
-    1. For each basis coordinate `i`, the scalar projections are dense in `C(X, ℝ)`.
-    2. Reconstructed maps from coordinate-wise closure elements lie in `closure A`.
--/
-omit [CompactSpace X] [Nonempty ι] in
-theorem closure_eq_top_findim
-    (b : Basis ι ℝ V)
-    (A : Set C(X, V))
-    (hscalar_dense : ∀ i : ι, closure (scalarProjections b A i) = ⊤)
-    (hreconstruct : ∀ φ : ι → C(X, ℝ),
-      (∀ i, φ i ∈ closure (scalarProjections b A i)) →
-      reconstructCM b φ ∈ closure A) :
-    closure A = ⊤ := by
-  -- By definition of scalarProjections and hscalar_dense, for all f ∈ C(X, V) and i, basisCoordMap b i f ∈ closure (scalarProjections b A i).
-  have h_all_in_closure : ∀ f : C(X, V), ∀ i : ι, basisCoordMap b i f ∈ closure (scalarProjections b A i) := by
+theorem assembleVec_apply {m : ℕ} (g : Fin m → C(X, ℝ)) (x : X) (i : Fin m) :
+    assembleVec g x i = g i x := rfl
+
+omit [CompactSpace X] [T2Space X] in
+theorem coordMap_comp_assembleVec {m : ℕ} (g : Fin m → C(X, ℝ)) (i : Fin m) :
+    (coordMap m i).comp (assembleVec g) = g i := by
+  ext x; simp [coordMap, assembleVec]
+
+omit [CompactSpace X] [T2Space X] in
+theorem assembleVec_mem_vecClass {A : Set C(X, ℝ)} {m : ℕ}
+    {g : Fin m → C(X, ℝ)} (hg : ∀ i, g i ∈ A) :
+    assembleVec g ∈ VecClass A m := by
+  intro i; rw [coordMap_comp_assembleVec]; exact hg i
+
+/-! ## Coordinatewise Norm Estimates -/
+
+/-
+Pointwise bound: if every coordinate is bounded by `δ`, then the pi-norm
+    (which is the sup norm on `Fin m → ℝ`) is bounded by `δ`.
+-/
+theorem norm_pi_le_of_coord_bound {m : ℕ} {v : Fin m → ℝ} {δ : ℝ} (hδ : 0 ≤ δ)
+    (h : ∀ i, |v i| ≤ δ) : ‖v‖ ≤ δ := by
+  exact pi_norm_le_iff_of_nonneg hδ |>.2 h
+
+omit [T2Space X] in
+/-
+Uniform bound on continuous maps: if coordinates are pointwise bounded,
+    the overall continuous map norm is bounded.
+-/
+theorem norm_sub_continuousMap_le_of_coord_bound {m : ℕ}
+    {F G : C(X, Fin m → ℝ)} {δ : ℝ} (hδ : 0 ≤ δ)
+    (h : ∀ x i, |F x i - G x i| ≤ δ) :
+    ‖F - G‖ ≤ δ := by
+  rw [ ContinuousMap.norm_le _ hδ ];
+  exact fun x => norm_pi_le_of_coord_bound hδ fun i => h x i
+
+/-! ## Main Density Theorem -/
+
+/-
+**Coordinatewise density in `C(X, Fin m → ℝ)`.**
+    If the scalar class `A` is dense in `C(X, ℝ)`, then every vector-valued
+    function is in the closure of `VecClass A m`.
+-/
+omit [T2Space X] in
+theorem closure_vecClass_eq_univ_of_scalar
+    {A : Set C(X, ℝ)} {m : ℕ}
+    (hA : ∀ f : C(X, ℝ), f ∈ closure A) :
+    ∀ F : C(X, Fin m → ℝ), F ∈ closure (VecClass A m) := by
+  -- Fix an arbitrary $F \in C(X, Fin m → ℝ)$ and an arbitrary $\epsilon > 0$.
+  have h_eps : ∀ F : C(X, Fin m → ℝ), ∀ ε > 0, ∃ G : C(X, Fin m → ℝ), G ∈ VecClass A m ∧ ‖F - G‖ < ε := by
+    intro F ε hε
+    have h_coord : ∀ i : Fin m, ∃ g : C(X, ℝ), g ∈ A ∧ ‖(coordMap m i).comp F - g‖ < ε := by
+      intro i;
+      simpa [ dist_eq_norm ] using Metric.mem_closure_iff.mp ( hA _ ) ε hε;
+    choose g hg hg' using h_coord
+    use assembleVec g
+    constructor
+    · exact assembleVec_mem_vecClass hg
+    ·
+      rw [ ContinuousMap.norm_lt_iff _ hε ] at *;
+      simp_all +decide [ ContinuousMap.norm_lt_iff, Pi.norm_def ];
+      intro x; induction' ( Finset.univ : Finset ( Fin m ) ) using Finset.induction <;> aesop;
+  intro F;
+  rw [ Metric.mem_closure_iff ];
+  simpa only [ dist_eq_norm ] using h_eps F
+
+/-
+**ε-approximation form.**
+-/
+omit [T2Space X] in
+theorem exists_mem_vecClass_uniformApprox
+    {A : Set C(X, ℝ)} {m : ℕ}
+    (hA : ∀ f : C(X, ℝ), f ∈ closure A)
+    (F : C(X, Fin m → ℝ)) {ε : ℝ} (hε : 0 < ε) :
+    ∃ G ∈ VecClass A m, ‖F - G‖ < ε := by
+  -- Apply the closure result to the vector function $F$ to find a sequence of functions in $VecClass A m$ converging to $F$.
+  have h_closure : F ∈ closure (VecClass A m) :=
+    closure_vecClass_eq_univ_of_scalar hA F
+  -- Apply the Metric.mem_closure_iff theorem to get the existence of such a G.
+  rw [Metric.mem_closure_iff] at h_closure;
+  simpa only [ dist_eq_norm ] using h_closure ε hε
+
+omit [T2Space X] in
+/-- Closure form. -/
+theorem closure_vecClass_eq_top
+    {A : Set C(X, ℝ)} {m : ℕ}
+    (hA : closure A = Set.univ) :
+    closure (VecClass A m) = Set.univ := by
+  ext F; simp only [mem_univ, iff_true]
+  exact closure_vecClass_eq_univ_of_scalar (fun f => hA ▸ mem_univ _) F
+
+/-! ## Coupled Vector Class -/
+
+/-- The coupled-output class: vector maps obtained by applying a continuous
+    readout to finitely many shared scalar features from `A`. -/
+def CoupledVecClass (A : Set C(X, ℝ)) (m : ℕ) : Set C(X, Fin m → ℝ) :=
+  {F | ∃ k : ℕ, ∃ g : Fin k → C(X, ℝ),
+      (∀ j, g j ∈ A) ∧
+      ∃ φ : C(Fin k → ℝ, Fin m → ℝ),
+        F = φ.comp ⟨fun x j => g j x, continuous_pi (fun j => (g j).continuous)⟩}
+
+/-
+`VecClass A m ⊆ CoupledVecClass A m`: use identity readout with `k = m`.
+-/
+omit [CompactSpace X] [T2Space X] in
+theorem vecClass_subset_coupledVecClass
+    {A : Set C(X, ℝ)} {m : ℕ} :
+    VecClass A m ⊆ CoupledVecClass A m := by
+  intro F hF;
+  use m;
+  -- Let `g j` be the `j`-th coordinate projection of `F`, which is in `A` by definition of `VecClass`.
+  use fun j => (coordMap m j).comp F;
+  exact ⟨ hF, ⟨ ContinuousMap.id _, by ext; rfl ⟩ ⟩
+
+omit [T2Space X] in
+/-- Density of the coupled class follows from density of the coordinatewise class. -/
+theorem dense_coupledVecClass_of_dense_scalar
+    {A : Set C(X, ℝ)} {m : ℕ}
+    (hA : ∀ f : C(X, ℝ), f ∈ closure A) :
+    ∀ F : C(X, Fin m → ℝ), F ∈ closure (CoupledVecClass A m) := by
+  intro F
+  exact closure_mono vecClass_subset_coupledVecClass (closure_vecClass_eq_univ_of_scalar hA F)
+
+/-
+Closure under continuous output postcomposition.
+-/
+omit [CompactSpace X] [T2Space X] in
+theorem comp_mem_coupledVecClass
+    {A : Set C(X, ℝ)} {m p : ℕ}
+    {F : C(X, Fin m → ℝ)} (hF : F ∈ CoupledVecClass A m)
+    (ψ : C(Fin m → ℝ, Fin p → ℝ)) :
+    ψ.comp F ∈ CoupledVecClass A p := by
+  obtain ⟨ k, g, hg, φ, rfl ⟩ := hF;
+  exact ⟨ k, g, hg, ψ.comp φ, rfl ⟩
+
+/-! ## Retraction onto Compact Targets -/
+
+/-
+Density into a compact target `K` via a continuous retraction `r`.
+    If `r` fixes `K` pointwise and maps everything into `K`, and `F` maps into `K`,
+    then `F` can be approximated by coupled-class maps that also map into `K`.
+-/
+omit [T2Space X] in
+theorem dense_into_compactRange_of_retraction
+    {A : Set C(X, ℝ)} {m : ℕ}
+    (hA : ∀ f : C(X, ℝ), f ∈ closure A)
+    {r : C(Fin m → ℝ, Fin m → ℝ)}
+    {K : Set (Fin m → ℝ)}
+    (hrK : ∀ y ∈ K, r y = y)
+    (hrange : ∀ y, r y ∈ K)
+    {F : C(X, Fin m → ℝ)} (hFK : ∀ x, F x ∈ K) :
+    ∀ ε > 0, ∃ G : C(X, Fin m → ℝ),
+      G ∈ CoupledVecClass A m ∧ (∀ x, G x ∈ K) ∧ dist F G < ε := by
+  -- By the continuity of `r`, we have `r.comp F = F`.
+  have h_comp_eq : r.comp F = F := by
     aesop;
-  exact Set.eq_univ_iff_forall.mpr fun f => by simpa [ reconstructCM_eq_of_coord b f _ fun i => rfl ] using hreconstruct _ fun i => h_all_in_closure f i;
-
-/-
-**Abstract vector density from scalar density**: if a dense scalar set `S` can be
-    lifted to vector approximants via basis reconstruction, then `A` is dense.
--/
-theorem dense_of_scalar_density
-    (b : Basis ι ℝ V)
-    (S : Set C(X, ℝ))
-    (hS_dense : closure S = ⊤)
-    (A : Set C(X, V))
-    (h_contains_reconst : ∀ ψ : ι → C(X, ℝ),
-        (∀ i, ψ i ∈ S) → reconstructCM b ψ ∈ A) :
-    closure A = ⊤ := by
-  refine' eq_top_iff.2 fun f hf => _;
-  -- Use dist_reconstructCM_le to get constant C.
-  obtain ⟨C, hC_pos, hC_bound⟩ : ∃ C > 0, ∀ (g : C(X, V)) (φ : ι → C(X, ℝ)),
-    dist (reconstructCM b φ) g ≤ C * (Finset.univ.sup' Finset.univ_nonempty (fun i => dist (φ i) (basisCoordMap b i g))) := dist_reconstructCM_le b;
-  -- Given f : C(X, V) and ε > 0, we can find ψ_i ∈ S with dist(ψ_i, basisCoordMap b i f) < ε/C.
-  have h_approx : ∀ ε > 0, ∃ ψ : ι → C(X, ℝ), (∀ i, ψ i ∈ S) ∧ Finset.univ.sup' Finset.univ_nonempty (fun i => dist (ψ i) (basisCoordMap b i f)) < ε / C := by
-    intro ε ε_pos
-    have h_approx : ∀ i : ι, ∃ ψ_i ∈ S, dist ψ_i (basisCoordMap b i f) < ε / C := by
-      intro i
-      have h_approx_i : basisCoordMap b i f ∈ closure S := by
-        aesop;
-      rw [ Metric.mem_closure_iff ] at h_approx_i;
-      simpa only [ dist_comm ] using h_approx_i ( ε / C ) ( div_pos ε_pos hC_pos );
-    choose ψ hψ using h_approx;
-    have h_sup_lt : ∃ i, ∀ j, dist (ψ j) (basisCoordMap b j f) ≤ dist (ψ i) (basisCoordMap b i f) := by
-      simpa using Finset.exists_max_image Finset.univ ( fun i => dist ( ψ i ) ( basisCoordMap b i f ) ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩;
-    exact ⟨ ψ, fun i => hψ i |>.1, lt_of_le_of_lt ( Finset.sup'_le _ _ fun i _ => h_sup_lt.choose_spec i ) ( hψ _ |>.2 ) ⟩;
-  rw [ Metric.mem_closure_iff ];
-  exact fun ε ε_pos => by rcases h_approx ε ε_pos with ⟨ ψ, hψS, hψε ⟩ ; exact ⟨ _, h_contains_reconst ψ hψS, by rw [ dist_comm ] ; exact lt_of_le_of_lt ( hC_bound _ _ ) ( by rwa [ lt_div_iff₀' hC_pos ] at hψε ) ⟩ ;
-
-end Density
-
-/-! ### EML corollary for `Fin n → ℝ` -/
-
-section EML
-
-variable {X : Type*} [TopologicalSpace X] [CompactSpace X]
-
-/-
-**EML multi-output approximation for `Fin n → ℝ`**.
-
-    If each scalar coordinate output can be densely approximated, and coordinate
-    approximants can be assembled into vector-valued model outputs, then the model
-    class is dense in `C(X, Fin n → ℝ)`.
--/
-omit [CompactSpace X] in
-theorem eml_uniform_dense_finvec (n : ℕ) (_hn : 0 < n)
-    (A : Set C(X, Fin n → ℝ))
-    (hcoord : ∀ i : Fin n,
-        closure {φ : C(X, ℝ) | ∃ f ∈ A, ∀ x, φ x = f x i} = ⊤)
-    (hassemble : ∀ ψ : Fin n → C(X, ℝ),
-        (∀ i, ψ i ∈ closure {φ : C(X, ℝ) | ∃ f ∈ A, ∀ x, φ x = f x i}) →
-        (⟨fun x i => ψ i x,
-          continuous_pi (fun i => (ψ i).continuous)⟩ : C(X, Fin n → ℝ))
-          ∈ closure A) :
-    closure A = ⊤ := by
-  simp_all +decide [ Set.ext_iff ];
-  intro f;
-  convert hassemble ( fun i => ⟨ fun x => f x i, f.continuous.comp continuous_id' |> Continuous.comp ( continuous_apply i ) ⟩ )
-
-/-
-**Simplified EML vector approximation**: when `A` naturally contains all
-    coordinate-wise assemblies from a dense scalar set `S`.
--/
-theorem eml_closure_eq_top_of_scalar_dense (n : ℕ) (hn : 0 < n)
-    (S : Set C(X, ℝ))
-    (hS_dense : closure S = ⊤)
-    (A : Set C(X, Fin n → ℝ))
-    (h_contains_pi : ∀ ψ : Fin n → C(X, ℝ),
-        (∀ i, ψ i ∈ S) →
-        (⟨fun x i => ψ i x,
-          continuous_pi (fun i => (ψ i).continuous)⟩ : C(X, Fin n → ℝ))
-          ∈ A) :
-    closure A = ⊤ := by
-  convert dense_of_scalar_density (ι := Fin n) (Pi.basisFun ℝ (Fin n)) _ hS_dense _ _
-  · exact Fin.pos_iff_nonempty.mp hn
-  · intro ψ hψ
-    convert h_contains_pi ψ hψ
-    simp +decide [reconstructCM, Pi.single_apply]
-
-end EML
-
-end VectorSW+  intro ε hε;
+  -- By the continuity of `r`, we have `r.comp` is continuous.
+  have h_comp_cont : Continuous (r.comp · : C(X, Fin m → ℝ) → C(X, Fin m → ℝ)) :=
+    continuous_postcomp r
+  -- Since `r.comp` is continuous, for any `ε > 0`, there exists a `δ > 0` such that if `dist G F < δ`, then `dist (r.comp G) (r.comp F) < ε`.
+  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ G : C(X, Fin m → ℝ), dist G F < δ → dist (r.comp G) (r.comp F) < ε := by
+    exact Metric.continuous_iff.mp h_comp_cont F ε hε;
+  obtain ⟨ G, hG₁, hG₂ ⟩ := exists_mem_vecClass_uniformApprox hA F hδ_pos;
+  refine' ⟨ r.comp G, _, _, _ ⟩;
+  · exact comp_mem_coupledVecClass ( vecClass_subset_coupledVecClass hG₁ ) r;
+  · exact fun x => hrange _;
+  · simpa [ dist_eq_norm', h_comp_eq, norm_sub_rev ] using hδ G ( by simpa [ dist_eq_norm', norm_sub_rev ] using hG₂ )
+
+/-! ## Simplex and Softmax -/
+
+/-- The softmax map sends any vector to the probability simplex `stdSimplex ℝ (Fin m)`.
+    Requires `m > 0` so that the denominator is positive. -/
+def softmaxMap (m : ℕ) (hm : 0 < m) : C(Fin m → ℝ, Fin m → ℝ) :=
+  ⟨fun y i => exp (y i) / ∑ j, exp (y j), by
+    apply continuous_pi; intro i
+    apply Continuous.div
+    · exact (continuous_apply i).rexp
+    · exact continuous_finset_sum _ (fun j _ => (continuous_apply j).rexp)
+    · intro y
+      apply ne_of_gt
+      apply Finset.sum_pos (fun j _ => exp_pos _)
+      rw [Finset.univ_nonempty_iff]; exact ⟨⟨0, hm⟩⟩⟩
+
+/-
+Softmax output lies in the standard simplex.
+-/
+theorem softmaxMap_mem_stdSimplex {m : ℕ} (hm : 0 < m) (y : Fin m → ℝ) :
+    softmaxMap m hm y ∈ stdSimplex ℝ (Fin m) := by
+  constructor <;> norm_num [ softmaxMap ];
+  · exact fun i => div_nonneg ( Real.exp_nonneg _ ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ );
+  · rw [ ← Finset.sum_div, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ ⟨ 0, hm ⟩, Finset.mem_univ _ ⟩ ]
+
+/-
+Interior-simplex density: strictly positive simplex-valued maps can be
+    approximated by softmax-composed coupled-class maps.
+-/
+omit [T2Space X] in
+theorem approx_simplex_interior
+    {A : Set C(X, ℝ)} {m : ℕ} (hm : 0 < m)
+    (hA : ∀ f : C(X, ℝ), f ∈ closure A)
+    {F : C(X, Fin m → ℝ)}
+    (hF : ∀ x, F x ∈ stdSimplex ℝ (Fin m))
+    (hpos : ∀ x i, 0 < F x i) :
+    F ∈ closure {G | ∃ H ∈ CoupledVecClass A m, G = (softmaxMap m hm).comp H} := by
+  -- Let z be the logit coordinates of F.
+  set z : C(X, Fin m → ℝ) := ⟨fun x i => Real.log (F x i), by
+    exact continuous_pi_iff.mpr fun i => Continuous.log ( F.continuous.comp continuous_id' |> Continuous.comp ( continuous_apply i ) ) fun x => ne_of_gt ( hpos x i )⟩
+  generalize_proofs at *;
+  -- Since softmaxMap is continuous, for H close enough to z, softmax(H) is close to softmax(z) = F.
+  have h_cont : Continuous (fun H : C(X, Fin m → ℝ) => (softmaxMap m hm).comp H) := by
+    refine' ContinuousMap.continuous_of_continuous_uncurry _ _;
+    apply Continuous.comp (softmaxMap m hm).continuous;
+    fun_prop
+  generalize_proofs at *;
+  -- Since $z$ is in the closure of $CoupledVecClass A m$, there exists a sequence $\{H_n\}$ in $CoupledVecClass A m$ such that $H_n \to z$.
+  obtain ⟨H_seq, hH_seq⟩ : ∃ H_seq : ℕ → C(X, Fin m → ℝ), (∀ n, H_seq n ∈ CoupledVecClass A m) ∧ Filter.Tendsto H_seq Filter.atTop (nhds z) := by
+    have h_dense : z ∈ closure (CoupledVecClass A m) := by
+      convert dense_coupledVecClass_of_dense_scalar hA z;
+    rw [ mem_closure_iff_seq_limit ] at h_dense ; tauto;
+  have hF_eq_softmax_z : F = (softmaxMap m hm).comp z := by
+    ext x i; simp +decide [ softmaxMap ] ;
+    simp +decide [ z, Real.exp_log ( hpos x _ ), hF x |>.2 ];
+  exact hF_eq_softmax_z ▸ mem_closure_of_tendsto ( h_cont.continuousAt.tendsto.comp hH_seq.2 ) ( Filter.Eventually.of_forall fun n => ⟨ H_seq n, hH_seq.1 n, rfl ⟩ )
+
+/-! ## EML Specialization -/
+
+section EMLSpecialization
+
+variable {n : ℕ} (Φ : Fin n → C(X, ℝ))
+
+/-- The logistic (sigmoid) activation function. -/
+private def logistic' (x : ℝ) : ℝ := 1 / (1 + exp (-x))
+
+private lemma logistic'_continuous : Continuous logistic' := by
+  unfold logistic'
+  apply Continuous.div continuous_const
+  · exact continuous_const.add continuous_neg.rexp
+  · intro x; positivity
+
+/-- EML exponential generator: `exp(∑ᵢ wᵢ Φᵢ(x) + b)`. -/
+private def emlExpGen' (w : Fin n → ℝ) (b : ℝ) : C(X, ℝ) :=
+  ⟨fun x => exp (∑ i, w i * Φ i x + b),
+    (continuous_finset_sum _ (fun i _ => continuous_const.mul (Φ i).continuous) |>.add
+      continuous_const).rexp⟩
+
+/-- EML logistic generator: `σ(∑ᵢ wᵢ Φᵢ(x) + b)`. -/
+private def emlLogisticGen' (w : Fin n → ℝ) (b : ℝ) : C(X, ℝ) :=
+  ⟨fun x => logistic' (∑ i, w i * Φ i x + b),
+    logistic'_continuous.comp
+      (continuous_finset_sum _ (fun i _ => continuous_const.mul (Φ i).continuous) |>.add
+        continuous_const)⟩
+
+/-- The set of all EML generators (exponential and logistic). -/
+private def emlGenerators' : Set C(X, ℝ) :=
+  {f | ∃ w b, f = emlExpGen' Φ w b} ∪ {f | ∃ w b, f = emlLogisticGen' Φ w b}
+
+/-- The ℝ-subalgebra of C(X, ℝ) generated by the EML generators. -/
+def emlSubalgebra' : Subalgebra ℝ C(X, ℝ) :=
+  Algebra.adjoin ℝ (emlGenerators' Φ)
+
+/-- The EML scalar class: the carrier set of the EML subalgebra. -/
+def EMLScalarClass : Set C(X, ℝ) := ↑(emlSubalgebra' Φ)
+
+omit [CompactSpace X] [T2Space X] in
+/-- The EML subalgebra separates points. -/
+private lemma emlSubalgebra'_separatesPoints
+    (_hn : 1 ≤ n)
+    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y) :
+    (emlSubalgebra' Φ).SeparatesPoints := by
+  intro x y hxy
+  obtain ⟨j, hj⟩ := hΦ x y hxy
+  let w : Fin n → ℝ := fun i => if i = j then 1 else 0
+  refine ⟨⇑(emlExpGen' Φ w 0), ⟨emlExpGen' Φ w 0, Algebra.subset_adjoin (Set.mem_union_left _ ⟨w, 0, rfl⟩), rfl⟩, ?_⟩
+  simp only [emlExpGen', ContinuousMap.coe_mk, w]
+  intro h; apply hj
+  have := exp_eq_exp.mp h; simp at this; linarith
+
+/-- The EML subalgebra has dense carrier in `C(X, ℝ)`. -/
+private lemma eml_scalar_dense
+    (hn : 1 ≤ n)
+    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y) :
+    ∀ f : C(X, ℝ), f ∈ closure (EMLScalarClass Φ) := by
+  intro f
+  have hcl : (emlSubalgebra' Φ).topologicalClosure = ⊤ :=
+    ContinuousMap.subalgebra_topologicalClosure_eq_top_of_separatesPoints _
+      (emlSubalgebra'_separatesPoints Φ hn hΦ)
+  have hmem : f ∈ (emlSubalgebra' Φ).topologicalClosure := hcl ▸ Algebra.mem_top
+  show f ∈ closure ↑(emlSubalgebra' Φ)
+  rwa [← Subalgebra.topologicalClosure_coe]
+
+/-- **Vector-valued EML Stone–Weierstrass.**
+    The coordinatewise EML vector class is dense in `C(X, Fin m → ℝ)`. -/
+theorem eml_vec_stoneWeierstrass
+    {m : ℕ}
+    (hn : 1 ≤ n)
+    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y) :
+    closure (VecClass (EMLScalarClass Φ) m) = Set.univ := by
+  ext F; simp only [mem_univ, iff_true]
+  exact closure_vecClass_eq_univ_of_scalar (eml_scalar_dense Φ hn hΦ) F
+
+/-- **Coupled EML vector class density.** -/
+theorem eml_coupled_vec_stoneWeierstrass
+    {m : ℕ}
+    (hn : 1 ≤ n)
+    (hΦ : ∀ x y : X, x ≠ y → ∃ i : Fin n, Φ i x ≠ Φ i y) :
+    ∀ F : C(X, Fin m → ℝ), F ∈ closure (CoupledVecClass (EMLScalarClass Φ) m) :=
+  dense_coupledVecClass_of_dense_scalar (eml_scalar_dense Φ hn hΦ)
+
+end EMLSpecialization
+
+end