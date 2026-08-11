import Mathlib

/-!
# Adjacency–degree algebras: basic objects

This file sets up the objects appearing in the "adjacency-degree algebra" circle of ideas
(McKay-type spectral determination of trees):

* `AdjDeg.degMatrix G` — the diagonal degree matrix `D_G`;
* `AdjDeg.adjDegAlgebra G` — the unital `ℝ`-subalgebra `𝒜(G) = ⟨I, A_G, D_G⟩` of matrices;
* `AdjDeg.cyclicModule G` — the cyclic module `M_G = 𝒜(G) 𝟏`;
* `AdjDeg.orbitModule G` — the automorphism-orbit module `U_G` of `Aut(G)`-invariant vectors.

The two main results here are

* `AdjDeg.cyclicModule_le_orbitModule` : `M_G ≤ U_G` for **every** finite simple graph,
  obtained from the fact that `A_G` and `D_G` generate a subalgebra of `Aut(G)`-equivariant
  matrices; and
* `AdjDeg.cyclicModule_eq_span_one_iff_regular` : `M_G` is the line spanned by `𝟏` exactly
  when `G` is regular.
-/

namespace AdjDeg

open Matrix Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The diagonal degree matrix `D_G` of a finite simple graph. -/
def degMatrix : Matrix V V ℝ := Matrix.diagonal fun v => (G.degree v : ℝ)

@[simp] lemma degMatrix_apply (u v : V) :
    degMatrix G u v = if u = v then (G.degree u : ℝ) else 0 := by
  unfold degMatrix
  by_cases h : u = v <;> simp [h]
  subst h; rfl

@[simp] lemma degMatrix_mulVec (f : V → ℝ) (v : V) :
    (degMatrix G *ᵥ f) v = (G.degree v : ℝ) * f v := by
  simp [degMatrix, Matrix.mulVec_diagonal]

/-- The adjacency-degree algebra `𝒜(G) = ⟨I, A_G, D_G⟩`. -/
def adjDegAlgebra : Subalgebra ℝ (Matrix V V ℝ) :=
  Algebra.adjoin ℝ ({G.adjMatrix ℝ, degMatrix G} : Set (Matrix V V ℝ))

lemma adjMatrix_mem_adjDegAlgebra : G.adjMatrix ℝ ∈ adjDegAlgebra G :=
  Algebra.subset_adjoin (by simp)

lemma degMatrix_mem_adjDegAlgebra : degMatrix G ∈ adjDegAlgebra G :=
  Algebra.subset_adjoin (by simp)

/-- Acting on the all-ones vector, as a linear map `Matrix V V ℝ →ₗ[ℝ] (V → ℝ)`. -/
def actOnOnes : Matrix V V ℝ →ₗ[ℝ] (V → ℝ) where
  toFun X := X *ᵥ (1 : V → ℝ)
  map_add' X Y := by ext v; simp [Matrix.add_mulVec]
  map_smul' c X := by ext v; simp [Matrix.smul_mulVec]

omit [DecidableEq V] in
@[simp] lemma actOnOnes_apply (X : Matrix V V ℝ) (v : V) :
    actOnOnes X v = ∑ u, X v u := by
  simp [actOnOnes, Matrix.mulVec, dotProduct]

/-- The cyclic module `M_G = 𝒜(G) 𝟏 ⊆ ℝ^V`. -/
def cyclicModule : Submodule ℝ (V → ℝ) :=
  (Subalgebra.toSubmodule (adjDegAlgebra G)).map actOnOnes

lemma mem_cyclicModule_of_mem {X : Matrix V V ℝ} (hX : X ∈ adjDegAlgebra G) :
    X *ᵥ (1 : V → ℝ) ∈ cyclicModule G :=
  ⟨X, hX, rfl⟩

/-- The automorphism-orbit module `U_G`: vectors constant on `Aut(G)`-orbits. -/
def orbitModule : Submodule ℝ (V → ℝ) where
  carrier := {f | ∀ (σ : G ≃g G) (v : V), f (σ v) = f v}
  add_mem' hf hg := by intro σ v; simp [hf σ v, hg σ v]
  zero_mem' := by intro σ v; simp
  smul_mem' c f hf := by intro σ v; simp [hf σ v]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma mem_orbitModule {f : V → ℝ} :
    f ∈ orbitModule G ↔ ∀ (σ : G ≃g G) (v : V), f (σ v) = f v := Iff.rfl

/-! ## Equivariant matrices -/

/-- The subalgebra of matrices invariant under simultaneous row/column relabelling by
graph automorphisms. -/
def equivariantAlgebra : Subalgebra ℝ (Matrix V V ℝ) where
  carrier := {X | ∀ (σ : G ≃g G) (u v : V), X (σ u) (σ v) = X u v}
  mul_mem' := by
    intro X Y hX hY σ u v
    simp only [Matrix.mul_apply]
    rw [← Equiv.sum_comp (σ : V ≃ V) (fun w => X (σ u) w * Y w (σ v))]
    refine Finset.sum_congr rfl fun w _ => ?_
    exact congrArg₂ (· * ·) (hX σ u w) (hY σ w v)
  add_mem' := by intro X Y hX hY σ u v; simp [hX σ u v, hY σ u v]
  algebraMap_mem' := by
    intro c σ u v
    simp only [Matrix.algebraMap_matrix_apply]
    by_cases h : u = v
    · simp [h]
    · have hne : ¬ (σ u = σ v) := fun hc => h ((σ : V ≃ V).injective hc)
      rw [if_neg hne, if_neg h]

lemma adjMatrix_mem_equivariantAlgebra : G.adjMatrix ℝ ∈ equivariantAlgebra G := by
  intro σ u v
  simp only [SimpleGraph.adjMatrix_apply]
  by_cases h : G.Adj u v
  · simp [h, (σ.map_adj_iff).mpr h]
  · have : ¬ G.Adj (σ u) (σ v) := fun hc => h ((σ.map_adj_iff).mp hc)
    simp [h, this]

lemma degMatrix_mem_equivariantAlgebra : degMatrix G ∈ equivariantAlgebra G := by
  intro σ u v
  by_cases h : u = v
  · subst h; simp [degMatrix_apply, σ.degree_eq u]
  · have hne : ¬ (σ u = σ v) := fun hc => h ((σ : V ≃ V).injective hc)
    simp [degMatrix_apply, h, hne]

lemma adjDegAlgebra_le_equivariantAlgebra : adjDegAlgebra G ≤ equivariantAlgebra G := by
  apply Algebra.adjoin_le
  rintro X (rfl | rfl)
  · exact adjMatrix_mem_equivariantAlgebra G
  · simpa using degMatrix_mem_equivariantAlgebra G

/-- Every vector in `M_G` is constant on automorphism orbits: `M_G ≤ U_G`. -/
theorem cyclicModule_le_orbitModule : cyclicModule G ≤ orbitModule G := by
  rintro _ ⟨X, hX, rfl⟩
  have hXe : X ∈ equivariantAlgebra G := adjDegAlgebra_le_equivariantAlgebra G hX
  intro σ v
  simp only [actOnOnes_apply]
  rw [← Equiv.sum_comp (σ : V ≃ V) (fun u => X (σ v) u)]
  exact Finset.sum_congr rfl fun u _ => hXe σ v u

/-! ## A general stability tool -/

/-- Matrices preserving a submodule of `ℝ^V` form a subalgebra. -/
def stabilizerAlgebra (N : Submodule ℝ (V → ℝ)) : Subalgebra ℝ (Matrix V V ℝ) where
  carrier := {X | ∀ f ∈ N, X *ᵥ f ∈ N}
  mul_mem' := by
    intro X Y hX hY f hf
    rw [← Matrix.mulVec_mulVec]
    exact hX _ (hY f hf)
  add_mem' := by
    intro X Y hX hY f hf
    rw [Matrix.add_mulVec]
    exact N.add_mem (hX f hf) (hY f hf)
  algebraMap_mem' := by
    intro c f hf
    have hc : (algebraMap ℝ (Matrix V V ℝ) c) *ᵥ f = c • f := by
      ext v
      simp [Algebra.algebraMap_eq_smul_one, Matrix.smul_mulVec, Matrix.one_mulVec]
    rw [hc]
    exact N.smul_mem c hf

/-- If a submodule contains `𝟏` and is stable under `A_G` and `D_G`, it contains `M_G`.
This is the basic mechanism bounding the cyclic module from above. -/
theorem cyclicModule_le_of_stable (N : Submodule ℝ (V → ℝ)) (hone : (1 : V → ℝ) ∈ N)
    (hA : ∀ f ∈ N, G.adjMatrix ℝ *ᵥ f ∈ N) (hD : ∀ f ∈ N, degMatrix G *ᵥ f ∈ N) :
    cyclicModule G ≤ N := by
  rintro _ ⟨X, hX, rfl⟩
  have hle : adjDegAlgebra G ≤ stabilizerAlgebra N := by
    apply Algebra.adjoin_le
    rintro Y (rfl | rfl)
    · exact hA
    · exact hD
  exact hle hX _ hone

/-! ## Triviality of `M_G` detects regularity -/

/-- The subalgebra of matrices with constant row sums. -/
def constRowSumAlgebra : Subalgebra ℝ (Matrix V V ℝ) where
  carrier := {X | ∃ c : ℝ, X *ᵥ (1 : V → ℝ) = c • (1 : V → ℝ)}
  mul_mem' := by
    rintro X Y ⟨c, hc⟩ ⟨d, hd⟩
    refine ⟨d * c, ?_⟩
    rw [← Matrix.mulVec_mulVec, hd, Matrix.mulVec_smul, hc]
    ext v; simp [mul_comm]
  add_mem' := by
    rintro X Y ⟨c, hc⟩ ⟨d, hd⟩
    exact ⟨c + d, by rw [Matrix.add_mulVec, hc, hd, add_smul]⟩
  algebraMap_mem' := by
    intro c
    refine ⟨c, ?_⟩
    ext v
    simp [Matrix.algebraMap_matrix_apply, Matrix.mulVec, dotProduct]

lemma one_mem_cyclicModule : (1 : V → ℝ) ∈ cyclicModule G := by
  refine ⟨1, show (1 : Matrix V V ℝ) ∈ adjDegAlgebra G from one_mem _, ?_⟩
  ext v; simp [actOnOnes, Matrix.one_mulVec]

/-- `M_G` is the line spanned by the all-ones vector iff `G` is regular. -/
theorem cyclicModule_eq_span_one_iff_regular :
    cyclicModule G = Submodule.span ℝ {(1 : V → ℝ)} ↔ ∃ k, G.IsRegularOfDegree k := by
  constructor
  · intro h
    have hD : degMatrix G *ᵥ (1 : V → ℝ) ∈ Submodule.span ℝ {(1 : V → ℝ)} := by
      rw [← h]; exact mem_cyclicModule_of_mem G (degMatrix_mem_adjDegAlgebra G)
    rw [Submodule.mem_span_singleton] at hD
    obtain ⟨c, hc⟩ := hD
    rcases isEmpty_or_nonempty V with hV | hV
    · exact ⟨0, fun v => (hV.false v).elim⟩
    · obtain ⟨v0⟩ := hV
      refine ⟨G.degree v0, fun v => ?_⟩
      have h1 : ∀ w : V, (G.degree w : ℝ) = c := by
        intro w
        have := congrFun hc w
        simpa [degMatrix, Matrix.mulVec_diagonal] using this.symm
      have : (G.degree v : ℝ) = (G.degree v0 : ℝ) := by rw [h1 v, h1 v0]
      exact_mod_cast this
  · rintro ⟨k, hk⟩
    apply le_antisymm
    · rintro _ ⟨X, hX, rfl⟩
      have hsub : adjDegAlgebra G ≤ constRowSumAlgebra (V := V) := by
        apply Algebra.adjoin_le
        rintro Y (rfl | rfl)
        · refine ⟨k, ?_⟩
          ext v
          have : ∑ u, (G.adjMatrix ℝ) v u = (G.degree v : ℝ) := by
            simp [SimpleGraph.adjMatrix_apply, SimpleGraph.degree,
              SimpleGraph.neighborFinset_eq_filter]
          simp only [Matrix.mulVec, dotProduct, Pi.one_apply, mul_one, Pi.smul_apply,
            smul_eq_mul, this, hk v]
        · refine ⟨k, ?_⟩
          ext v
          simp [degMatrix, Matrix.mulVec_diagonal, hk v]
      obtain ⟨c, hc⟩ := hsub hX
      exact Submodule.mem_span_singleton.2 ⟨c, hc.symm⟩
    · rw [Submodule.span_le, Set.singleton_subset_iff]
      exact one_mem_cyclicModule G

end AdjDeg