/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Singer-Like Matrices: Algebraic-Geometric Obstruction Theorems

This file proves the key algebraic-geometric results about Singer-like matrices:

1. **Irreducible charpoly has no roots**: The characteristic polynomial of a
   Singer-like matrix has no roots in 𝔽_q.
2. **No eigenvectors**: Singer-like matrices have no eigenvectors over 𝔽_q.
3. **No invariant line**: Singer-like matrices preserve no 1-dimensional subspace.
4. **Non-scalar**: Singer-like matrices are not scalar matrices.

These results form the **algebraic-geometric obstruction** at the heart of
certified expansion: Singer-like elements act on ℙ¹(𝔽_q) without fixed points.
-/

import Mathlib
import GL2Expander.Defs

open Finset BigOperators Matrix Polynomial Submodule

/-! ## Irreducible Characteristic Polynomial Properties -/

/-
**Theorem (Irreducible degree-2 polynomial has no roots).**

An irreducible polynomial of degree ≥ 2 over a field has no roots in that field.
If it had a root `c`, then `(X - c)` would divide it, contradicting irreducibility.
-/
theorem irreducible_poly_no_root {K : Type*} [Field K]
    (p : K[X]) (hirr : Irreducible p) (hdeg : 2 ≤ p.natDegree) :
    ∀ c : K, Polynomial.eval c p ≠ 0 := by
  exact fun c hc => absurd ( Polynomial.degree_eq_one_of_irreducible_of_root hirr hc ) ( by rw [ Polynomial.degree_eq_natDegree hirr.ne_zero ] ; norm_cast; omega )

/-
**Theorem (Irreducible charpoly of 2×2 matrix has degree 2).**
-/
theorem charpoly_natDegree_two {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q)) :
    g.charpoly.natDegree = 2 := by
  rw [ Matrix.charpoly_natDegree_eq_dim ] ; norm_num

/-
**Theorem (Irreducible charpoly has no roots).**

The characteristic polynomial of a Singer-like matrix has no roots in 𝔽_q.
-/
theorem singerLike_charpoly_no_root {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ∀ c : ZMod q, Polynomial.eval c g.charpoly ≠ 0 := by
  exact irreducible_poly_no_root _ hg.2 ( by rw [ charpoly_natDegree_two ] )

/-
**Theorem (Singer-like matrices have no eigenvectors over 𝔽_q).**

If `g ∈ GL₂(𝔽_q)` has irreducible characteristic polynomial, then
for every `λ ∈ 𝔽_q`, the equation `gv = λv` has no nonzero solution.
Equivalently, `g` has no eigenvalue in 𝔽_q.

*Proof.* If `gv = λv` for nonzero `v`, then `λ` is a root of `charpoly(g)`,
contradicting `singerLike_charpoly_no_root`.
-/
theorem singerLike_no_eigenvalue {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ∀ c : ZMod q, ¬ ∃ v : Fin 2 → ZMod q, v ≠ 0 ∧ g.mulVecLin v = c • v := by
  intro c
  by_contra h_contra
  obtain ⟨v, hv_nonzero, hv_eigen⟩ := h_contra
  have h_charpoly_root : Polynomial.eval c g.charpoly = 0 := by
    -- By definition of eigenvalues, if $gv = cv$, then $c$ is a root of the characteristic polynomial of $g$.
    have h_charpoly_root : Matrix.det (g - c • 1) = 0 := by
      rw [ ← Matrix.exists_mulVec_eq_zero_iff ];
      simp_all +decide [ funext_iff, Matrix.mulVec, dotProduct ];
      exact ⟨ v, hv_nonzero, by linear_combination' hv_eigen.1, by linear_combination' hv_eigen.2 ⟩;
    simp_all +decide [ Matrix.det_fin_two, Matrix.charpoly ];
    linear_combination' h_charpoly_root;
  exact absurd h_charpoly_root ( singerLike_charpoly_no_root g hg c )

/-
**Theorem (Singer-like elements are non-scalar).**

A Singer-like matrix cannot be a scalar matrix `aI`. Indeed, `charpoly(aI) = (X-a)²`
which is reducible, contradicting irreducibility.
-/
theorem singerLike_not_scalar {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ¬ ∃ a : ZMod q, g = a • (1 : Matrix (Fin 2) (Fin 2) (ZMod q)) := by
  contrapose! hg;
  -- If g = a •  �1�, then charpoly(g) = charpoly(a • 1).
  obtain ⟨a, ha⟩ := hg;
  simp [ha, SingerLike];
  simp +decide [ Matrix.charpoly, Matrix.det_fin_two ];
  exact fun _ => fun h => absurd ( h.isUnit_or_isUnit rfl ) ( by rintro ( h | h ) <;> exact absurd ( Polynomial.degree_eq_zero_of_isUnit h ) ( by erw [ Polynomial.degree_X_sub_C ] ; norm_num ) )

/-
**Theorem (Singer-like matrices preserve no projective line).**

If `g ∈ GL₂(𝔽_q)` has irreducible characteristic polynomial, then no
1-dimensional subspace of 𝔽_q² is invariant under the linear action of `g`.

*Proof.* Suppose `W` is a 1-dimensional invariant subspace with basis `{v}`.
Since `g` maps `W` to itself, `gv = λv` for some `λ ∈ 𝔽_q`. But this means
`v` is an eigenvector of `g` with eigenvalue `λ`, contradicting
`singerLike_no_eigenvalue`.
-/
theorem singerLike_no_invariant_line {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ∀ (W : Submodule (ZMod q) (Fin 2 → ZMod q)),
      IsProjectiveLine W →
      ¬ PreservesSubspace g W := by
  intro W hW;
  -- By definition of $IsProject �ive�Line$, there exists � a� nonzero vector $v \in W$ such that $W$ is generated by $v$.
  obtain ⟨v, hv_ne_zero, hv_gen⟩ : ∃ v : Fin 2 → ZMod q, v ≠ 0 ∧ W = Submodule.span (ZMod q) {v} := by
    obtain ⟨v, hv⟩ : ∃ v : Fin 2 → ZMod q, v ∈ W ∧ v ≠ 0 := by
      contrapose! hW;
      rw [ show W = ⊥ by exact eq_bot_iff.mpr hW ] ; simp +decide [ IsProjectiveLine ];
    have h_span : Submodule.span (ZMod q) {v} = W := by
      refine' Submodule.eq_of_le_of_finrank_le ( Submodule.span_le.mpr ( Set.singleton_subset_iff.mpr hv.1 ) ) _;
      rw [ hW, finrank_span_singleton ] ; aesop;
    grind +qlia;
  contrapose! hv_ne_zero;
  -- Since $g$ preserves $W$, there exists some $c \in \mathbb{F}_q$ such that $g(v) = c v$.
  obtain ⟨c, hc⟩ : ∃ c : ZMod q, g.mulVecLin v = c • v := by
    have := hv_ne_zero v ( hv_gen.symm ▸ Submodule.mem_span_singleton_self v );
    rw [ hv_gen, Submodule.mem_span_singleton ] at this; tauto;
  exact Classical.not_not.1 fun h => singerLike_no_eigenvalue g hg c ⟨ v, h, hc ⟩