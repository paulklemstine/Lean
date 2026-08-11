import Physics.AdjacencyDegree.DegreeRecovery

/-!
# When does the cyclic module exhaust the orbit module?

The paper's forest theorem asserts `M_G = U_G` for every forest.  Here we isolate a general,
checkable *criterion* for that equality and verify it for an infinite family of trees.

* `AdjDeg.degIndicator_mem_cyclicModule` : the indicator of a degree class always lies in
  `M_G` (Lagrange interpolation applied to `D`);
* `AdjDeg.mem_cyclicModule_of_degree_constant` : consequently every function constant on
  degree classes lies in `M_G`;
* `AdjDeg.cyclicModule_eq_orbitModule_of_degree_transitive` : if vertices of equal degree are
  always related by an automorphism, then `M_G = U_G`;
* `AdjDeg.starGraph_cyclicModule_eq_orbitModule` : the stars `K_{1,n}` — an infinite family of
  trees — satisfy `M_G = U_G`.
-/

namespace AdjDeg

open Matrix Finset Polynomial

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- Powers of `D` act on `𝟏` by degree powers. -/
lemma degMatrix_pow_mulVec_ones (i : ℕ) (v : V) :
    (degMatrix G ^ i *ᵥ (1 : V → ℝ)) v = (G.degree v : ℝ) ^ i := by
  have hpow : degMatrix G ^ i = Matrix.diagonal fun v => (G.degree v : ℝ) ^ i := by
    rw [degMatrix, Matrix.diagonal_pow]
    congr 1
  rw [hpow, Matrix.mulVec_diagonal]
  simp

/-- Every polynomial function of the degree belongs to the cyclic module. -/
theorem degPoly_mem_cyclicModule (q : ℝ[X]) :
    (fun v : V => q.eval (G.degree v : ℝ)) ∈ cyclicModule G := by
  have hsum : (fun v : V => q.eval (G.degree v : ℝ))
      = ∑ i ∈ Finset.range (q.natDegree + 1),
          q.coeff i • (degMatrix G ^ i *ᵥ (1 : V → ℝ)) := by
    funext v
    rw [Polynomial.eval_eq_sum_range]
    rw [Finset.sum_apply]
    exact Finset.sum_congr rfl fun i _ => by
      rw [Pi.smul_apply, degMatrix_pow_mulVec_ones, smul_eq_mul]
  rw [hsum]
  refine Submodule.sum_mem _ fun i _ => Submodule.smul_mem _ _ ?_
  exact mem_cyclicModule_of_mem G (pow_mem (degMatrix_mem_adjDegAlgebra G) i)

/-- The indicator function of a degree class lies in the cyclic module. -/
theorem degIndicator_mem_cyclicModule (d : ℕ) :
    (fun v : V => if G.degree v = d then (1 : ℝ) else 0) ∈ cyclicModule G := by
  by_cases hd : d < Fintype.card V
  · set q : ℝ[X] := Lagrange.basis (Finset.range (Fintype.card V)) (fun j : ℕ => (j : ℝ)) d
      with hq
    have hval : ∀ v : V, q.eval (G.degree v : ℝ) = if G.degree v = d then (1 : ℝ) else 0 := by
      intro v
      have hmem : G.degree v ∈ Finset.range (Fintype.card V) :=
        Finset.mem_range.mpr (G.degree_lt_card_verts v)
      by_cases hv : G.degree v = d
      · rw [hv, if_pos rfl]
        exact Lagrange.eval_basis_self (injOn_cast_range _) (Finset.mem_range.mpr hd)
      · rw [if_neg hv]
        exact Lagrange.eval_basis_of_ne (Ne.symm hv) hmem
    have := degPoly_mem_cyclicModule G q
    rwa [funext hval] at this
  · push_neg at hd
    have hzero : (fun v : V => if G.degree v = d then (1 : ℝ) else 0) = 0 := by
      funext v
      have := G.degree_lt_card_verts v
      rw [if_neg (by omega)]
      rfl
    rw [hzero]
    exact Submodule.zero_mem _

/-- Every function that is constant on degree classes lies in the cyclic module. -/
theorem mem_cyclicModule_of_degree_constant {f : V → ℝ}
    (hf : ∀ u v : V, G.degree u = G.degree v → f u = f v) : f ∈ cyclicModule G := by
  classical
  set g : ℕ → ℝ := fun d => if h : ∃ u : V, G.degree u = d then f h.choose else 0 with hg
  have hgval : ∀ v : V, g (G.degree v) = f v := by
    intro v
    have hex : ∃ u : V, G.degree u = G.degree v := ⟨v, rfl⟩
    rw [hg]
    simp only
    rw [dif_pos hex]
    exact hf _ _ hex.choose_spec
  have hdecomp : f = ∑ d ∈ Finset.range (Fintype.card V),
      g d • (fun v : V => if G.degree v = d then (1 : ℝ) else 0) := by
    funext v
    rw [Finset.sum_apply]
    rw [Finset.sum_eq_single (G.degree v)]
    · rw [Pi.smul_apply, if_pos rfl, smul_eq_mul, mul_one, hgval]
    · intro d _ hd
      rw [Pi.smul_apply, if_neg (by exact fun h => hd h.symm), smul_eq_mul, mul_zero]
    · intro hnot
      exact absurd (Finset.mem_range.mpr (G.degree_lt_card_verts v)) hnot
  rw [hdecomp]
  exact Submodule.sum_mem _ fun d _ =>
    Submodule.smul_mem _ _ (degIndicator_mem_cyclicModule G d)

/-- **A criterion for `M_G = U_G`.** If any two vertices of the same degree are related by an
automorphism, the cyclic module is exactly the automorphism-orbit module. -/
theorem cyclicModule_eq_orbitModule_of_degree_transitive
    (h : ∀ u v : V, G.degree u = G.degree v → ∃ σ : G ≃g G, σ u = v) :
    cyclicModule G = orbitModule G := by
  refine le_antisymm (cyclicModule_le_orbitModule G) ?_
  intro f hf
  refine mem_cyclicModule_of_degree_constant G fun u v huv => ?_
  obtain ⟨σ, hσ⟩ := h u v huv
  have := hf σ u
  rw [hσ] at this
  exact this.symm

/-! ## The stars `K_{1,n}` -/

/-- The star `K_{1,n}` on `Fin (n+1)`, with centre `0`. -/
def starGraph (n : ℕ) : SimpleGraph (Fin (n + 1)) where
  Adj i j := (i = 0 ∧ j ≠ 0) ∨ (j = 0 ∧ i ≠ 0)
  symm := by
    intro i j h
    exact h.symm
  loopless := ⟨fun i h => by rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> exact h2 h1⟩

instance (n : ℕ) : DecidableRel (starGraph n).Adj := fun i j =>
  inferInstanceAs (Decidable ((i = 0 ∧ j ≠ 0) ∨ (j = 0 ∧ i ≠ 0)))

lemma starGraph_adj_iff {n : ℕ} (i j : Fin (n + 1)) :
    (starGraph n).Adj i j ↔ (i = 0 ∧ j ≠ 0) ∨ (j = 0 ∧ i ≠ 0) := Iff.rfl

/-- Swapping two leaves is an automorphism of the star. -/
def starSwap {n : ℕ} {i j : Fin (n + 1)} (hi : i ≠ 0) (hj : j ≠ 0) :
    starGraph n ≃g starGraph n where
  toEquiv := Equiv.swap i j
  map_rel_iff' := by
    intro a b
    have hzero : ∀ x : Fin (n + 1), Equiv.swap i j x = 0 ↔ x = 0 := by
      intro x
      constructor
      · intro hx
        by_cases hxi : x = i
        · subst hxi; rw [Equiv.swap_apply_left] at hx; exact absurd hx hj
        · by_cases hxj : x = j
          · subst hxj; rw [Equiv.swap_apply_right] at hx; exact absurd hx hi
          · rwa [Equiv.swap_apply_of_ne_of_ne hxi hxj] at hx
      · intro hx
        subst hx
        rw [Equiv.swap_apply_of_ne_of_ne (Ne.symm hi) (Ne.symm hj)]
    simp only [starGraph_adj_iff, hzero, ne_eq]

lemma starGraph_degree_center (n : ℕ) : (starGraph n).degree 0 = n := by
  have : (starGraph n).neighborFinset 0 = Finset.univ.erase 0 := by
    ext j
    simp [SimpleGraph.mem_neighborFinset, starGraph_adj_iff]
  rw [← SimpleGraph.card_neighborFinset_eq_degree, this]
  simp

lemma starGraph_degree_leaf {n : ℕ} {i : Fin (n + 1)} (hi : i ≠ 0) :
    (starGraph n).degree i = 1 := by
  have : (starGraph n).neighborFinset i = {0} := by
    ext j
    simp only [SimpleGraph.mem_neighborFinset, starGraph_adj_iff, Finset.mem_singleton]
    constructor
    · rintro (⟨h1, _⟩ | ⟨h1, _⟩)
      · exact absurd h1 hi
      · exact h1
    · rintro rfl
      exact Or.inr ⟨rfl, hi⟩
  rw [← SimpleGraph.card_neighborFinset_eq_degree, this]
  simp

/-- For `n = 1` the star is `K₂`, whose vertex swap is an automorphism. -/
def starK2Swap : starGraph 1 ≃g starGraph 1 where
  toEquiv := Equiv.swap 0 1
  map_rel_iff' := by
    intro a b
    revert a b
    decide

/-- **The stars satisfy the forest identity `M_G = U_G`.** -/
theorem starGraph_cyclicModule_eq_orbitModule (n : ℕ) :
    cyclicModule (starGraph n) = orbitModule (starGraph n) := by
  refine cyclicModule_eq_orbitModule_of_degree_transitive _ fun u v huv => ?_
  by_cases hu : u = 0
  · by_cases hv : v = 0
    · exact ⟨SimpleGraph.Iso.refl, by rw [hu, hv]; rfl⟩
    · -- centre and leaf have the same degree only if `n = 1`, i.e. the star is `K₂`
      subst hu
      rw [starGraph_degree_center, starGraph_degree_leaf hv] at huv
      subst huv
      have hv1 : v = 1 := by
        fin_cases v
        · exact absurd rfl hv
        · rfl
      refine ⟨starK2Swap, ?_⟩
      rw [hv1]
      simp [starK2Swap]
  · by_cases hv : v = 0
    · subst hv
      rw [starGraph_degree_leaf hu, starGraph_degree_center] at huv
      subst huv
      have hu1 : u = 1 := by
        fin_cases u
        · exact absurd rfl hu
        · rfl
      refine ⟨starK2Swap, ?_⟩
      rw [hu1]
      simp [starK2Swap]
    · exact ⟨starSwap hu hv, Equiv.swap_apply_left _ _⟩

end AdjDeg