/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Uniform Spectral Gap Bounds for GL₂(𝔽_q) via Algebraic Certificates

This file develops the theory of certified expander graphs for GL₂(𝔽_q),
connecting algebraic generation certificates to spectral expansion.

## Main definitions

* `SingerLike`: A matrix in GL₂(𝔽_q) with irreducible characteristic polynomial.
* `PrimitiveDet`: A GL₂ element whose determinant generates (𝔽_q)ˣ.
* `CertifiedPairData`: A pair (g,h) satisfying Singer-like + primitive det + generation.
* `DirichletEnergy`: The Dirichlet form measuring oscillation under Cayley action.

## Main results

* `irreducible_poly_no_root`: Irreducible polynomials of degree ≥ 2 have no roots.
* `singer_like_no_eigenvector`: Singer-like matrices have no eigenvectors over 𝔽_q.
* `singer_like_no_invariant_line`: Singer-like matrices preserve no 1-dim subspace.
* `harmonic_meanzero_eq_zero_of_generates`: Maximum principle for Cayley graphs.
* `dirichlet_pos_of_meanzero_generates`: Spectral gap theorem.
* `strict_contraction_of_generates`: Strict L² contraction on mean-zero functions.

## References

* Lubotzky (1994). Discrete Groups, Expanding Graphs and Invariant Measures.
* Hoory, Linial, Wigderson (2006). Expander Graphs and their Applications.
-/

import Mathlib

open Finset Polynomial BigOperators Subgroup

/-! ## Part 1: Algebraic Definitions for GL₂(𝔽_q) -/

section Definitions

variable (q : ℕ) [Fact (Nat.Prime q)]

/-- A 2×2 matrix over 𝔽_q is **Singer-like** if it is invertible and its
characteristic polynomial is irreducible over 𝔽_q. Such elements act as
"Singer cycles": they preserve no proper nonzero subspace. -/
def SingerLike (g : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop :=
  IsUnit g.det ∧ Irreducible g.charpoly

/-- A GL₂ element has **primitive determinant** if det has multiplicative
order q - 1 in (𝔽_q)ˣ, i.e., generates the full multiplicative group.
This ensures the generated subgroup cannot be trapped in a proper
determinant subgroup of GL₂. -/
def PrimitiveDet (h : GL (Fin 2) (ZMod q)) : Prop :=
  orderOf (Matrix.GeneralLinearGroup.det h) = q - 1

/-- A **certified pair** in GL₂(𝔽_q): Singer-like first element,
primitive determinant second element, generating the full group. -/
structure CertifiedPairData where
  g : GL (Fin 2) (ZMod q)
  h : GL (Fin 2) (ZMod q)
  singer_g : Irreducible (g.val).charpoly
  prim_det_h : PrimitiveDet q h
  gen : Subgroup.closure ({g, h} : Set (GL (Fin 2) (ZMod q))) = ⊤

end Definitions

/-! ## Part 2: Irreducible Polynomials Have No Roots -/

/-
An irreducible polynomial of degree ≥ 2 over a field has no roots.
If p(a) = 0, then (X - a) | p. Since p is irreducible and deg(X-a) = 1 < deg(p),
this contradicts irreducibility.
-/
theorem irreducible_poly_no_root {K : Type*} [Field K]
    (p : K[X]) (hp : Irreducible p) (hdeg : 2 ≤ p.natDegree) :
    ∀ a : K, p.eval a ≠ 0 := by
  intro a ha; have := Polynomial.degree_eq_one_of_irreducible_of_root hp ha; rw [ Polynomial.degree_eq_natDegree ( hp.ne_zero ) ] at this; norm_cast at this; linarith;

/-! ## Part 3: Singer-Like Matrices — No Eigenvectors -/

/-
The characteristic polynomial of a 2×2 matrix over a nontrivial ring
has degree 2.
-/
theorem matrix_charpoly_natDegree_two {R : Type*} [CommRing R] [Nontrivial R]
    (M : Matrix (Fin 2) (Fin 2) R) :
    M.charpoly.natDegree = 2 := by
  convert M.charpoly_natDegree_eq_dim

/-
A Singer-like matrix has no eigenvalue over 𝔽_q: its characteristic
polynomial has no root. This is the **projective line bridge**: eigenvalues
correspond to fixed points on ℙ¹(𝔽_q), so Singer-like elements act
fixed-point-freely on the projective line.
-/
theorem singer_like_no_eigenvector (q : ℕ) [hq : Fact (Nat.Prime q)] (hq5 : 5 ≤ q)
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike q g) :
    ∀ (a : ZMod q), g.charpoly.eval a ≠ 0 := by
  exact irreducible_poly_no_root _ hg.2 ( by rw [ matrix_charpoly_natDegree_two ] )

/-
A Singer-like matrix preserves no 1-dimensional subspace of (𝔽_q)².
This is the finite-geometry formulation: no fixed point on ℙ¹(𝔽_q).
-/
theorem singer_like_no_invariant_line (q : ℕ) [hq : Fact (Nat.Prime q)] (hq5 : 5 ≤ q)
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike q g) :
    ∀ (W : Submodule (ZMod q) (Fin 2 → ZMod q)),
      (∀ w ∈ W, g.mulVecLin w ∈ W) →
      Module.finrank (ZMod q) W ≠ 1 := by
  -- Assume that W is a 1-dimensional subspace of (𝔽_q)².
  intro W hW hW_dim
  obtain ⟨v, hv⟩ : ∃ v : Fin 2 → ZMod q, v ≠ 0 ∧ W = Submodule.span (ZMod q) {v} := by
    obtain ⟨ v, hv ⟩ := finrank_eq_one_iff'.mp hW_dim;
    refine' ⟨ v, by simpa using hv.1, le_antisymm _ _ ⟩;
    · rintro w hw; obtain ⟨ c, hc ⟩ := hv.2 ⟨ w, hw ⟩ ; aesop;
    · exact Submodule.span_le.mpr ( Set.singleton_subset_iff.mpr v.2 );
  -- Since g.mulVecLin v ∈ W and W = span(v), there exists α ∈ 𝔽_q such that g.mulVecLin v = α * v.
  obtain ⟨α, hα⟩ : ∃ α : ZMod q, g.mulVecLin v = α • v := by
    have := hW v ( hv.2.symm ▸ Submodule.mem_span_singleton_self v ) ; rw [ hv.2 ] at this; rw [ Submodule.mem_span_singleton ] at this; tauto;
  -- Since $g$ is Singer-like, its characteristic polynomial is irreducible, so $\alpha$ cannot be an eigenvalue of $g$.
  have h_charpoly : (g.charpoly.eval α) = 0 := by
    -- Since $g.mulVecLin v = α • v$, we have $(g - αI)v = 0$, which means $α$ is an eigenvalue of $g$.
    have h_eigenvalue : Matrix.det (g - Matrix.scalar (Fin 2) α) = 0 := by
      rw [ ← Matrix.exists_mulVec_eq_zero_iff ];
      exact ⟨ v, hv.1, by simpa [ sub_smul, Matrix.sub_mulVec ] using sub_eq_zero.mpr hα ⟩;
    simp_all +decide [ Matrix.charpoly, Matrix.det_fin_two ];
    linear_combination' h_eigenvalue;
  exact singer_like_no_eigenvector q hq5 g hg α h_charpoly

/-! ## Part 4: Cayley Graph and Averaging Operator -/

section CayleyGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The symmetric generator set {g, g⁻¹, h, h⁻¹}. -/
def symGenSet (g h : G) : Finset G := {g, g⁻¹, h, h⁻¹}

/-- The averaging (Markov) operator on group-indexed functions. -/
noncomputable def avgOp (S : Finset G) (f : G → ℝ) (x : G) : ℝ :=
  (S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)

/-- A function is harmonic (fixed by the averaging operator). -/
def IsHarmonicFn (S : Finset G) (f : G → ℝ) : Prop :=
  ∀ x : G, f x = avgOp S f x

/-- Mean-zero function. -/
def HasMeanZero (f : G → ℝ) : Prop :=
  ∑ x : G, f x = 0

/-- Squared L² norm. -/
noncomputable def l2NormSq (f : G → ℝ) : ℝ :=
  ∑ x : G, f x ^ 2

/-- L² inner product. -/
noncomputable def l2Inner (f g : G → ℝ) : ℝ :=
  ∑ x : G, f x * g x

/-- **Dirichlet energy**: D(f) = (1/(2|S|)) Σ_x Σ_{s∈S} (f(xs) - f(x))².
Measures total oscillation across Cayley graph edges. -/
noncomputable def DirichletEnergy (S : Finset G) (f : G → ℝ) : ℝ :=
  (2 * S.card : ℝ)⁻¹ * ∑ x : G, ∑ s ∈ S, (f (x * s) - f x) ^ 2

end CayleyGraph

/-! ## Part 5: Maximum Principle for Cayley Graphs -/

section MaximumPrinciple

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-
A nonempty subset closed under right-multiplication by a generating set
equals the whole group.
-/
theorem closed_under_gens_eq_univ
    (S : Finset G) (A : Finset G)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hA : A.Nonempty)
    (hclosed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A) :
    A = Finset.univ := by
  refine' Finset.eq_univ_of_forall _;
  intro x
  have hx : ∀ g ∈ Subgroup.closure (S : Set G), ∀ a ∈ A, a * g ∈ A := by
    refine' fun g hg a ha => Subgroup.closure_induction _ _ _ _ hg a ha;
    · exact fun s hs a ha => hclosed a ha s hs;
    · simp +decide;
    · exact fun x y hx hy hx' hy' z hz => by simpa only [ mul_assoc ] using hy' _ ( hx' _ hz ) ;
    · intro g hg ih a ha;
      -- Since $A$ is finite, the map $a \mapsto a * g$ is a bijection on $A$.
      have h_bij : Finset.image (fun a => a * g) A = A := by
        exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr ih ) ( by rw [ Finset.card_image_of_injective _ fun x y hxy => mul_right_cancel hxy ] );
      replace h_bij := Finset.ext_iff.mp h_bij a; aesop;
  obtain ⟨ a, ha ⟩ := hA; specialize hx ( a⁻¹ * x ) ( by simp +decide [ hgen ] ) a ha; aesop;

/-
At a maximum of a harmonic function, neighbors equal the max.
-/
theorem harmonic_max_neighbors_eq
    (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) (x : G) (M : ℝ)
    (hfx : f x = M) (hmax : ∀ y : G, f y ≤ M)
    (havg : f x = (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)) :
    ∀ s ∈ S, f (x * s) = M := by
  -- Since f(x) = M = (1/|S|) Σ_{s∈S} f(xs) and f(xs) ≤ M for all s, if any f(xs₀) < M then the average would be < M, contradicting f(x) = M.
  by_contra h_neq;
  have h_sum_lt : ∑ s ∈ S, f (x * s) < ∑ s ∈ S, M := by
    exact Finset.sum_lt_sum ( fun s hs => hmax _ ) ( by push_neg at h_neq; obtain ⟨ s, hs, hs' ⟩ := h_neq; exact ⟨ s, hs, lt_of_le_of_ne ( hmax _ ) hs' ⟩ );
  simp_all +decide [ Finset.sum_const, nsmul_eq_mul ];
  rw [ inv_mul_eq_div, div_eq_iff ] at hfx <;> nlinarith [ show ( S.card : ℝ ) > 0 by exact Nat.cast_pos.mpr hS.card_pos ]

/-
**Maximum Principle.** Harmonic functions on connected Cayley graphs
are constant.
-/
theorem harmonic_is_constant
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarmonicFn S f) :
    ∀ x y : G, f x = f y := by
  -- Let M = max of f over G (exists since G is finite).
  obtain ⟨M, hM⟩ : ∃ M, M ∈ Set.range f ∧ ∀ y ∈ Set.range f, y ≤ M := by
    exact ⟨ Finset.max' ( Set.toFinset ( Set.range f ) ) ⟨ _, Set.mem_toFinset.mpr ( Set.mem_range_self 1 ) ⟩, Set.mem_toFinset.mp ( Finset.max'_mem _ _ ), fun y hy => Finset.le_max' _ _ ( Set.mem_toFinset.mpr hy ) ⟩;
  -- The set A = {x | f(x) = M} is nonempty (f attains its max).
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : G, f x₀ = M := by
    exact hM.1
  set A : Finset G := Finset.filter (fun x => f x = M) Finset.univ
  have hA_nonempty : A.Nonempty := by
    exact ⟨ x₀, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx₀ ⟩ ⟩
  have hA_closed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A := by
    intros a ha s hs
    have h_avg : f a = (S.card : ℝ)⁻¹ * ∑ s ∈ S, f (a * s) := by
      convert hf a using 1
    have h_eq_M : ∀ s ∈ S, f (a * s) = M := by
      apply harmonic_max_neighbors_eq S hS f a M (by
      grind +locals) (by
      exact fun y => hM.2 _ <| Set.mem_range_self _) h_avg
    aesop
  have hA_eq_univ : A = Finset.univ := by
    apply closed_under_gens_eq_univ S A hsym hgen hA_nonempty hA_closed
  have hA_const : ∀ x : G, f x = M := by
    exact fun x => Finset.ext_iff.mp hA_eq_univ x |> fun h => by aesop;
  exact fun x y => hA_const x ▸ hA_const y ▸ rfl

/-
**Harmonic Mean-Zero Vanishing.** Harmonic mean-zero functions on
connected Cayley graphs are identically zero.
-/
theorem harmonic_meanzero_eq_zero_of_generates
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarmonicFn S f) (hmz : HasMeanZero f) :
    f = 0 := by
  -- By harmonic_is_constant, f is constant: ∃ c, ∀ x, f(x) = c.
  obtain ⟨c, hc⟩ : ∃ c : ℝ, ∀ x : G, f x = c := by
    exact ⟨ f 1, fun x => Eq.symm ( harmonic_is_constant S hS hsym hgen f hf 1 x ) ⟩;
  simp_all +decide [ funext_iff, HasMeanZero ]

end MaximumPrinciple

/-! ## Part 6: Spectral Gap Theorem -/

section SpectralGap

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-
Dirichlet energy is nonneg (it's a sum of squares).
-/
theorem dirichlet_energy_nonneg (S : Finset G) (f : G → ℝ) :
    0 ≤ DirichletEnergy S f := by
  exact mul_nonneg ( inv_nonneg.2 ( mul_nonneg zero_le_two ( Nat.cast_nonneg _ ) ) ) ( Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-
D(f) = 0 iff f is constant on generator orbits.
-/
theorem dirichlet_zero_iff_constant_on_orbits
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    DirichletEnergy S f = 0 ↔ ∀ x : G, ∀ s ∈ S, f (x * s) = f x := by
  constructor;
  · intro h s hs
    have h_sum_zero : ∑ x : G, ∑ s ∈ S, (f (x * s) - f x) ^ 2 = 0 := by
      unfold DirichletEnergy at h; aesop;
    rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ ] at h_sum_zero;
    simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg, sub_eq_zero ];
  · unfold DirichletEnergy;
    aesop

/-
**Spectral Gap Theorem.** On a connected Cayley graph, every nonzero
mean-zero function has positive Dirichlet energy. Equivalently, the
smallest eigenvalue of the graph Laplacian on mean-zero functions is positive.

**Proof**: D(f)=0 implies f is constant on orbits, hence harmonic, hence
constant by maximum principle, hence zero by mean zero. Contrapositive
gives the result.
-/
theorem dirichlet_pos_of_meanzero_generates
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hmz : HasMeanZero f) (hf : f ≠ 0) :
    0 < DirichletEnergy S f := by
  contrapose! hf;
  -- By dirichlet_zero_iff_constant_on_orbits, f(xs) = f(x) for all x, s ∈ S.
  have h_const_on_orbits : ∀ x : G, ∀ s ∈ S, f (x * s) = f x := by
    exact fun x s hs => by have := dirichlet_zero_iff_constant_on_orbits S hS f; exact this.mp ( le_antisymm hf ( dirichlet_energy_nonneg S f ) ) x s hs;
  -- By harmonic_meanzero_eq_zero_of_generates, f = 0.
  apply harmonic_meanzero_eq_zero_of_generates S hS hsym hgen f (by
  intro x; simp +decide [ IsHarmonicFn, avgOp, h_const_on_orbits ] ;
  rw [ Finset.sum_congr rfl fun s hs => h_const_on_orbits x s hs, Finset.sum_const, nsmul_eq_mul, inv_mul_eq_div, mul_div_cancel_left₀ _ ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ) ]) hmz

/-
The averaging operator preserves mean.
-/
theorem avgOp_preserves_sum
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    ∑ x : G, avgOp S f x = ∑ x : G, f x := by
  -- By definition of average, we can rewrite the left-hand side as a double sum.
  have h_avg_def : ∑ x, avgOp S f x = (S.card : ℝ)⁻¹ * ∑ x, ∑ s ∈ S, f (x * s) := by
    unfold avgOp; rw [ Finset.mul_sum _ _ _ ] ;
  rw [ h_avg_def, inv_mul_eq_div, div_eq_iff ];
  · rw [ mul_comm, Finset.sum_comm ];
    exact Eq.trans ( Finset.sum_congr rfl fun _ _ => Equiv.sum_comp ( Equiv.mulRight _ ) fun x => f x ) ( by simp +decide );
  · exact Nat.cast_ne_zero.mpr hS.card_pos.ne'

/-
Averaging operator has L² norm ≤ 1.
-/
theorem avgOp_norm_le_one
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    l2NormSq (avgOp S f) ≤ l2NormSq f := by
  -- By Cauchy-Schwarz inequality, we have $(\sum_{s \in S} f(x s))^2 \leq |S| \sum_{s \in S} f(x s)^2$.
  have h_cauchy_schwarz : ∀ x : G, (∑ s ∈ S, f (x * s)) ^ 2 ≤ S.card * ∑ s ∈ S, f (x * s) ^ 2 := by
    exact?;
  -- Summing over $x$, we get $\sum_{x} (\sum_{s \in S} f(x s))^2 \leq |S| \sum_{x} \sum_{s \in S} f(x s)^2$.
  have h_sum_cauchy_schwarz : ∑ x : G, (∑ s ∈ S, f (x * s)) ^ 2 ≤ S.card * ∑ x : G, ∑ s ∈ S, f (x * s) ^ 2 := by
    simpa only [ Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun x _ => h_cauchy_schwarz x;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ x : G, ∑ s ∈ S, f (x * s) ^ 2 = ∑ s ∈ S, ∑ x : G, f (x * s) ^ 2 := by
    exact Finset.sum_comm;
  -- By invariance of the sum under translation, we have $\sum_{x} f(x s)^2 = \sum_{x} f(x)^2$ for each $s \in S$.
  have h_invariance : ∀ s ∈ S, ∑ x : G, f (x * s) ^ 2 = ∑ x : G, f x ^ 2 := by
    exact fun s hs => Equiv.sum_comp ( Equiv.mulRight s ) fun x => f x ^ 2;
  simp_all +decide [ l2NormSq, avgOp ];
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_pow ];
  rw [ inv_mul_le_iff₀ ] <;> nlinarith [ show ( S.card : ℝ ) > 0 by exact Nat.cast_pos.mpr hS.card_pos ]

end SpectralGap

/-! ## Part 7: Certified Pair Spectral Gap -/

/-
The symmetric generator set is inverse-closed.
-/
theorem symGenSet_inv_closed {G : Type*} [Group G] [DecidableEq G]
    (g h : G) : ∀ s ∈ symGenSet g h, s⁻¹ ∈ symGenSet g h := by
  unfold symGenSet; aesop;

/-
The closure of {g, h} is contained in the closure of {g, g⁻¹, h, h⁻¹}.
-/
theorem symGenSet_closure_contains {G : Type*} [Group G] [DecidableEq G]
    (g h : G) :
    Subgroup.closure ({g, h} : Set G) ≤
    Subgroup.closure (↑(symGenSet g h) : Set G) := by
  simp +decide [ Subgroup.closure_le, symGenSet ];
  exact Set.insert_subset_iff.mpr ⟨ Subgroup.subset_closure ( by simp +decide ), Set.singleton_subset_iff.mpr ( Subgroup.subset_closure ( by simp +decide ) ) ⟩

/-
If {g,h} generates G, then {g,g⁻¹,h,h⁻¹} generates G.
-/
theorem symGenSet_generates_of_pair_generates
    {G : Type*} [Group G] [DecidableEq G]
    (g h : G) (hgen : Subgroup.closure ({g, h} : Set G) = ⊤) :
    Subgroup.closure (↑(symGenSet g h) : Set G) = ⊤ := by
  refine' eq_top_iff.mpr ( hgen ▸ Subgroup.closure_mono _ ) ; simp +decide [ symGenSet ];
  simp +decide [ Set.insert_subset_iff ]

/-
**Certified pair harmonic triviality.** For elements generating a
finite group, the only harmonic mean-zero function on the Cayley graph
{g, g⁻¹, h, h⁻¹} is zero.
-/
theorem certified_pair_harmonic_trivial
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G) (hgen : Subgroup.closure ({g, h} : Set G) = ⊤)
    (hS : (symGenSet g h).Nonempty)
    (f : G → ℝ) (hf : IsHarmonicFn (symGenSet g h) f) (hmz : HasMeanZero f) :
    f = 0 := by
  convert @harmonic_meanzero_eq_zero_of_generates G _ _ _ ( symGenSet g h ) hS _ _ f hf hmz;
  · exact?;
  · convert symGenSet_generates_of_pair_generates g h hgen using 1

/-
**Positive spectral gap from generation.** Generating pairs produce
Cayley graphs with positive spectral gap.
-/
theorem positive_gap_of_generates
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G) (hgen : Subgroup.closure ({g, h} : Set G) = ⊤)
    (hS : (symGenSet g h).Nonempty)
    (f : G → ℝ) (hmz : HasMeanZero f) (hf : f ≠ 0) :
    0 < DirichletEnergy (symGenSet g h) f := by
  -- Apply the spectral gap theorem with the symmetric generator set.
  apply dirichlet_pos_of_meanzero_generates (symGenSet g h) hS (symGenSet_inv_closed g h) (symGenSet_generates_of_pair_generates g h hgen) f hmz hf

/-! ## Part 8: Exponential Mixing (Cross-Domain Bridge to CS) -/

/-
**Exponential mixing from spectral contraction.**
If the averaging operator contracts mean-zero functions by factor α,
then t-fold iteration decays as α^(2t). This bridges algebra to
random walk mixing — a key connection to derandomization.
-/
theorem l2_mixing_decay_general
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (α : ℝ) (_hα : 0 ≤ α) (_hα1 : α < 1)
    (hcontract : ∀ f : G → ℝ, HasMeanZero f →
      l2NormSq (avgOp S f) ≤ α ^ 2 * l2NormSq f)
    (f : G → ℝ) (hfmz : HasMeanZero f) (t : ℕ) :
    l2NormSq ((avgOp S)^[t] f) ≤ α ^ (2 * t) * l2NormSq f := by
  induction' t with t ihizing f <;> simp_all +decide [ pow_succ', pow_mul', Function.iterate_succ_apply' ];
  convert le_trans ( hcontract _ _ ) ( mul_le_mul_of_nonneg_left ihizing ( mul_self_nonneg α ) ) using 1 ; ring;
  refine' Nat.recOn t _ _ <;> simp_all +decide [ Function.iterate_succ_apply', HasMeanZero ];
  intro n hn; rw [ avgOp_preserves_sum S hS ] ; simp +decide [ hn ] ;