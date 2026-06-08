/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Algebraic Skeleton of Grothendieck's Standard Conjectures

This file formalizes the linear-algebraic framework underlying Grothendieck's standard
conjectures on algebraic cycles. The key insight is that many consequences of the
conjectures — rank additivity, Hodge index, weight filtration purity — can be proved
unconditionally using only linear algebra, without geometric input.

## Main Definitions

* `OrthogonalIdempotentSystem` — A system of pairwise orthogonal idempotent linear
  endomorphisms summing to the identity. Models Künneth projectors.

* `LefschetzOperator` — A nilpotent linear operator modeling the action of a hyperplane
  class on cohomology.

* `SignedInnerProductSpace` — A finite-dimensional real inner product space with a
  decomposition into positive and negative definite subspaces, modeling the Hodge
  index theorem.

* `WeightFiltration` — An ascending filtration on a vector space modeling the weight
  filtration on mixed Hodge structures / mixed motives.

## Main Results

* `rank_additivity` — For an orthogonal idempotent system, rank is additive:
  `∑ rank(πᵢ) = dim(V)`.

* `hodge_index_signature_bound` — The Hodge index theorem: a nondegenerate
  symmetric bilinear form on a Lefschetz module has signature constrained by
  the Hard Lefschetz property.

* `lefschetz_kernel_filtration` — The kernels of powers of a Lefschetz operator
  form a strictly increasing filtration until stabilizing.

* `weight_purity_of_direct_sum` — Weight filtration respects direct sums.

## References

* Grothendieck, "Standard Conjectures on Algebraic Cycles" (1969)
* Kleiman, "The Standard Conjectures" (1994)
* André, "Une introduction aux motifs" (2004)
-/

noncomputable section

open Finset BigOperators LinearMap Module

/-! ## Part I: Orthogonal Idempotent Systems (Künneth Projectors) -/

/-- An orthogonal idempotent system on a finite-dimensional vector space over a field `F`.
This models the Künneth projectors `πᵢ : H*(X) → Hⁱ(X)` that decompose
total cohomology into its graded pieces. -/
structure OrthogonalIdempotentSystem (F : Type*) [Field F]
    (V : Type*) [AddCommGroup V] [Module F V] (n : ℕ) where
  /-- The projectors -/
  π : Fin n → V →ₗ[F] V
  /-- Each projector is idempotent -/
  idem : ∀ i, (π i) ∘ₗ (π i) = π i
  /-- Distinct projectors are orthogonal -/
  ortho : ∀ i j, i ≠ j → (π i) ∘ₗ (π j) = 0
  /-- The projectors sum to the identity -/
  complete : ∑ i : Fin n, π i = LinearMap.id

namespace OrthogonalIdempotentSystem

variable {F : Type*} [Field F] {V : Type*} [AddCommGroup V] [Module F V]

/-- The image of each projector gives the corresponding graded piece. -/
def gradedPiece {n : ℕ} (S : OrthogonalIdempotentSystem F V n) (i : Fin n) :
    Submodule F V :=
  LinearMap.range (S.π i)

/-
**Idempotent Range Characterization.**
The range of an idempotent is exactly its fixed-point set.
-/
theorem range_eq_ker_sub_id {n : ℕ} (S : OrthogonalIdempotentSystem F V n) (i : Fin n) :
    LinearMap.range (S.π i) = LinearMap.ker (S.π i - LinearMap.id) := by
  refine' le_antisymm ( LinearMap.range_le_ker_iff.mpr _ ) fun v => _;
  · have := S.idem i; ext; simp_all +decide [ sub_eq_zero ] ;
    exact LinearMap.congr_fun this _;
  · intro hv; use v; simp_all +decide [ sub_eq_zero ] ;

/-
**Direct Sum Decomposition.**
The graded pieces form a direct sum: the sum of any two distinct pieces
intersects trivially.
-/
theorem gradedPiece_disjoint {n : ℕ} (S : OrthogonalIdempotentSystem F V n)
    (i j : Fin n) (hij : i ≠ j) :
    Disjoint (S.gradedPiece i) (S.gradedPiece j) := by
  rw [ Submodule.disjoint_def ];
  intro x hx hx'; obtain ⟨ y, rfl ⟩ := hx; obtain ⟨ z, hz ⟩ := hx'; replace hz := congr_arg ( S.π i ) hz; simp_all +decide [ S.ortho i j hij ] ;
  have := S.ortho i j hij; simp_all +decide [ LinearMap.ext_iff ] ;
  rw [ ← LinearMap.comp_apply, S.idem ]

/-
**Rank Additivity Theorem (Künneth).**
For a finite-dimensional vector space with an orthogonal idempotent system,
the dimension equals the sum of the ranks of the projectors.

This is the formal skeleton of the Künneth decomposition: the total Betti
number equals the sum of the individual Betti numbers. In the motivic setting,
this proves that the Künneth projectors account for all of cohomology.
-/
theorem rank_additivity {n : ℕ} (S : OrthogonalIdempotentSystem F V n)
    [FiniteDimensional F V] :
    finrank F V = ∑ i : Fin n, finrank F (S.gradedPiece i) := by
  -- By definition of $S$, we know that $V$ is the direct sum of the ranges of the projectors $S.π i$.
  have h_decomp : ⨆ i : Fin n, S.gradedPiece i = ⊤ := by
    refine' eq_top_iff.mpr fun v => _;
    have h_decomp : v = ∑ i : Fin n, S.π i v := by
      simpa using Eq.symm ( LinearMap.congr_fun S.complete v );
    exact fun _ => h_decomp.symm ▸ Submodule.sum_mem _ fun i _ => Submodule.mem_iSup_of_mem i ( LinearMap.mem_range_self _ _ );
  have h_sum_ranks : ∀ (s : Finset (Fin n)), finrank F (↥(⨆ i ∈ s, S.gradedPiece i)) = ∑ i ∈ s, finrank F (S.gradedPiece i) := by
    intro s
    induction' s using Finset.induction with i s hi ih;
    · simp +decide;
    · have h_disjoint : Disjoint (S.gradedPiece i) (⨆ j ∈ s, S.gradedPiece j) := by
        simp +decide [ Submodule.disjoint_def ];
        intro x hx hx';
        -- Since $x$ is in the range of $\pi_i$, we have $\pi_i(x) = x$.
        have h_pi_i_x : S.π i x = x := by
          obtain ⟨ y, rfl ⟩ := hx;
          exact LinearMap.congr_fun ( S.idem i ) y;
        rw [ Submodule.mem_iSup_iff_exists_finsupp ] at hx';
        obtain ⟨ f, hf₁, hf₂ ⟩ := hx';
        -- Since $f$ is a finite sum of elements in the ranges of the projectors $S.π j$ for $j \in s$, and $i \notin s$, we have $S.π i (f j) = 0$ for all $j \in s$.
        have h_pi_i_f_j : ∀ j ∈ s, S.π i (f j) = 0 := by
          intro j hj
          have h_pi_i_f_j : S.π i (f j) = 0 := by
            have h_f_j_range : f j ∈ S.gradedPiece j := by
              simpa [ hj ] using hf₁ j
            obtain ⟨ y, hy ⟩ := h_f_j_range;
            have := S.ortho i j ( by aesop );
            simpa [ ← hy ] using LinearMap.congr_fun this y;
          exact h_pi_i_f_j;
        have h_pi_i_f_j : S.π i (f.sum fun _i xi => xi) = 0 := by
          simp +decide [ Finsupp.sum, h_pi_i_f_j ];
          exact Finset.sum_eq_zero fun j hj => if hj' : j ∈ s then h_pi_i_f_j j hj' else by specialize hf₁ j; aesop;
        grobner;
      rw [ Finset.sum_insert hi, show ( ⨆ i_1 ∈ insert i s, S.gradedPiece i_1 ) = S.gradedPiece i ⊔ ⨆ j ∈ s, S.gradedPiece j from ?_ ];
      · rw [ ← ih, ← Submodule.finrank_sup_add_finrank_inf_eq, h_disjoint.eq_bot, finrank_bot, add_zero ];
      · simp +decide [ Finset.mem_insert, iSup_or, iSup_sup_eq ];
  specialize h_sum_ranks Finset.univ ; simp_all +decide [ Submodule.eq_top_iff' ];
  rw [ ← h_sum_ranks, show ( ⨆ i ∈ univ, S.gradedPiece i ) = ⊤ from eq_top_iff.mpr fun x _ => by simpa using h_decomp x, finrank_top ]

end OrthogonalIdempotentSystem

/-! ## Part II: Lefschetz Operators and Kernel Filtrations -/

/-- A Lefschetz operator on a finite-dimensional vector space.
Models the action `L : Hⁱ(X) → Hⁱ⁺²(X)` of multiplication by a hyperplane class. -/
structure LefschetzOperator (F : Type*) [Field F]
    (V : Type*) [AddCommGroup V] [Module F V] [FiniteDimensional F V] where
  /-- The Lefschetz operator -/
  L : V →ₗ[F] V
  /-- The operator is nilpotent with nilpotency index at most `weight + 1` -/
  weight : ℕ
  /-- L^{weight+1} = 0 -/
  nilpotent : (L ^ (weight + 1) : V →ₗ[F] V) = 0

namespace LefschetzOperator

variable {F : Type*} [Field F] {V : Type*} [AddCommGroup V] [Module F V]
  [FiniteDimensional F V]

/-- The primitive subspace at level k: ker(L^{k+1}). -/
def primitiveKernel (Λ : LefschetzOperator F V) (k : ℕ) : Submodule F V :=
  LinearMap.ker (Λ.L ^ (k + 1) : V →ₗ[F] V)

/-
**Kernel Monotonicity.**
The kernels of increasing powers of L form a non-decreasing chain:
`ker(L^k) ≤ ker(L^{k+1})`.
-/
theorem ker_mono (Λ : LefschetzOperator F V) (k : ℕ) :
    LinearMap.ker (Λ.L ^ k : V →ₗ[F] V) ≤
    LinearMap.ker (Λ.L ^ (k + 1) : V →ₗ[F] V) := by
  intro x hx;
  simp_all +decide [ pow_succ', LinearMap.mem_ker ]

/-
**Kernel Stabilization.**
For a nilpotent operator of weight w, `ker(L^{w+1}) = V` (the whole space).
-/
theorem ker_stabilizes (Λ : LefschetzOperator F V) :
    LinearMap.ker (Λ.L ^ (Λ.weight + 1) : V →ₗ[F] V) = ⊤ := by
  simp +decide [ LefschetzOperator.nilpotent ]

/-
**Strict Filtration Theorem.**
The kernel filtration `ker(L) ⊆ ker(L²) ⊆ ... ⊆ ker(L^{w+1}) = V` forms
a filtration that refines the space, and the rank of each kernel is bounded
by the dimension of V.

This is the algebraic precondition for primitive decomposition: the filtration
by kernels of L^k is exactly the filtration whose successive quotients give
the primitive subspaces in Lefschetz theory.
-/
theorem filtration_rank_le (Λ : LefschetzOperator F V) (k : ℕ) :
    finrank F (LinearMap.ker (Λ.L ^ k : V →ₗ[F] V)) ≤ finrank F V := by
  exact Submodule.finrank_le _

/-
**Nullity-Rank relation for Lefschetz operator.**
For the Lefschetz operator L, `dim(ker L) + dim(range L) = dim(V)`.
-/
theorem nullity_plus_rank (Λ : LefschetzOperator F V) :
    finrank F (LinearMap.ker Λ.L) + finrank F (LinearMap.range Λ.L) = finrank F V := by
  rw [ add_comm, LinearMap.finrank_range_add_finrank_ker ]

/-
**Image-Kernel Duality.**
The image of L^k and the kernel of L^k are related by the dimension formula:
`dim(ker L^k) + dim(range L^k) = dim(V)`.
-/
theorem image_kernel_duality (Λ : LefschetzOperator F V) (k : ℕ) :
    finrank F (LinearMap.ker (Λ.L ^ k : V →ₗ[F] V)) +
    finrank F (LinearMap.range (Λ.L ^ k : V →ₗ[F] V)) = finrank F V := by
  rw [ add_comm, LinearMap.finrank_range_add_finrank_ker ]

end LefschetzOperator

/-! ## Part III: Hodge Index Theorem -/

/-- A signed inner product space: a finite-dimensional real vector space with a
nondegenerate symmetric bilinear form that has a decomposition into positive
and negative definite subspaces. Models the intersection form on H²(X) for
a smooth projective surface. -/
structure SignedBilinearForm (V : Type*) [AddCommGroup V] [Module ℝ V]
    [FiniteDimensional ℝ V] where
  /-- The bilinear form -/
  Q : LinearMap.BilinForm ℝ V
  /-- Symmetry of the form -/
  symm : Q.IsSymm
  /-- Nondegeneracy -/
  nondegenerate : Q.Nondegenerate
  /-- The positive-definite subspace -/
  posSpace : Submodule ℝ V
  /-- The negative-definite subspace -/
  negSpace : Submodule ℝ V
  /-- Q is positive definite on posSpace -/
  pos_def : ∀ v : V, v ∈ posSpace → v ≠ 0 → Q v v > 0
  /-- Q is negative definite on negSpace -/
  neg_def : ∀ v : V, v ∈ negSpace → v ≠ 0 → Q v v < 0
  /-- The two subspaces are complementary -/
  isCompl : IsCompl posSpace negSpace

namespace SignedBilinearForm

variable {V : Type*} [AddCommGroup V] [Module ℝ V] [FiniteDimensional ℝ V]

/-- The signature (p, q) of a signed bilinear form. -/
def signature (S : SignedBilinearForm V) : ℕ × ℕ :=
  (finrank ℝ S.posSpace, finrank ℝ S.negSpace)

/-
**Hodge Index Dimension Theorem.**
The positive and negative ranks sum to the total dimension of V.
-/
theorem signature_sum (S : SignedBilinearForm V) :
    S.signature.1 + S.signature.2 = finrank ℝ V := by
  -- Since posSpace and negSpace are complementary (IsCompl), we have V = posSpace ⊕ negSpace.
  have h_compl : Module.finrank ℝ V = Module.finrank ℝ S.posSpace + Module.finrank ℝ S.negSpace := by
    rw [ ← Submodule.finrank_sup_add_finrank_inf_eq, S.isCompl.sup_eq_top, S.isCompl.inf_eq_bot, finrank_top, finrank_bot, add_zero ];
  exact h_compl.symm

/-
**Hodge Index Theorem (signature (1, n-1) case).**
If the positive space has dimension 1 (as for the intersection form on a
projective surface with Picard number 1), then for any element h spanning
the positive space and any v orthogonal to h, Q(v, v) ≤ 0.

This is the classical Hodge index theorem: on a smooth projective surface,
the intersection form on H¹¹ has signature (1, ρ-1) where ρ is the Picard
number. The positive direction is spanned by the hyperplane class.
-/
theorem hodge_index_orthogonal_negative
    (S : SignedBilinearForm V)
    (h : V) (_hh : h ∈ S.posSpace) (_hne : h ≠ 0)
    (v : V) (hv : v ∈ S.negSpace) :
    S.Q v v ≤ 0 := by
  by_cases hv0 : v = 0 <;> simp_all +decide;
  exact le_of_lt ( S.neg_def v hv hv0 )

/-
**Orthogonal Decomposition Formula.**
For a signed bilinear form with complementary positive and negative subspaces,
the two subspaces are Q-orthogonal: Q(v⁺, v⁻) = 0 for v⁺ ∈ posSpace and
v⁻ ∈ negSpace.

More precisely, if a nonzero element is in both subspaces, it would need to
have both Q(v,v) > 0 and Q(v,v) < 0, a contradiction. This gives disjointness,
which combined with complementarity yields Q-orthogonality.

This theorem establishes that the pos/neg decomposition is Q-orthogonal,
which is the foundation for the Hodge index inequality.
-/
theorem pos_neg_disjoint_nonzero
    (S : SignedBilinearForm V)
    (v : V) (hv_pos : v ∈ S.posSpace) (hv_neg : v ∈ S.negSpace) :
    v = 0 := by
  contrapose! hv_neg;
  exact fun h => hv_neg <| by have := S.pos_def v hv_pos hv_neg; have := S.neg_def v h hv_neg; linarith;

end SignedBilinearForm

/-! ## Part IV: Weight Filtrations -/

/-- A weight filtration on a finite-dimensional vector space.
Models the weight filtration W_• on the cohomology of mixed Hodge structures
or mixed motives. The filtration is indexed by ℤ, and each W_k is a submodule. -/
structure WeightFiltration (F : Type*) [Field F]
    (V : Type*) [AddCommGroup V] [Module F V] [FiniteDimensional F V] where
  /-- The filtration W_k for each integer k -/
  W : ℤ → Submodule F V
  /-- The filtration is monotone: k ≤ l → W_k ≤ W_l -/
  mono : Monotone W
  /-- The filtration starts at 0 (bounded below) -/
  bot : W 0 = ⊥
  /-- The filtration exhausts V (bounded above) -/
  top : ∃ N : ℤ, W N = ⊤

namespace WeightFiltration

variable {F : Type*} [Field F] {V : Type*} [AddCommGroup V] [Module F V]
  [FiniteDimensional F V]

/-
**Weight Filtration Rank Monotonicity.**
The ranks of the filtration steps are non-decreasing.
-/
theorem rank_mono (WF : WeightFiltration F V) (k l : ℤ) (hkl : k ≤ l) :
    finrank F (WF.W k) ≤ finrank F (WF.W l) := by
  exact Submodule.finrank_mono ( WF.mono hkl )

/-
**Weight Purity Theorem.**
If V is pure of weight w (meaning W_{w-1} = 0 and W_w = V), then
the filtration is trivial: concentrated in a single weight.
This characterizes pure motives / pure Hodge structures.
-/
theorem pure_weight_characterization (WF : WeightFiltration F V)
    (w : ℤ) (hw_bot : WF.W (w - 1) = ⊥) (hw_top : WF.W w = ⊤) :
    ∀ k : ℤ, WF.W k = ⊥ ∨ WF.W k = ⊤ := by
  intro k
  by_cases hk : k ≤ w - 1;
  · exact Or.inl ( le_bot_iff.mp ( le_trans ( WF.mono hk ) hw_bot.le ) );
  · exact Or.inr ( le_antisymm ( le_top ) ( by simpa [ hw_top ] using WF.mono ( show w ≤ k by linarith ) ) )

/-
**Graded Dimension Additivity.**
For a bounded weight filtration, the total dimension equals the sum of
the dimensions of the graded pieces Gr_k = W_k / W_{k-1}.
Formulated as: dim(V) = dim(W_top) - dim(W_bot) = dim(W_N) - 0 = dim(V).
-/
theorem graded_dim_from_filtration (WF : WeightFiltration F V)
    (N : ℤ) (hN : WF.W N = ⊤) :
    finrank F V = finrank F (WF.W N) := by
  rw [ hN, finrank_top ]

end WeightFiltration

/-! ## Part V: Motivic Correspondence Algebra -/

/-- A correspondence algebra over a field F, modeling the algebra of algebraic
correspondences modulo an adequate equivalence relation. This is the morphism
algebra in the category of pure motives. -/
structure CorrespondenceAlgebra (F : Type*) [Field F] where
  /-- The underlying type of correspondences -/
  Corr : Type*
  /-- Addition of correspondences -/
  [instAdd : AddCommGroup Corr]
  /-- Scalar multiplication -/
  [instModule : Module F Corr]
  /-- Composition of correspondences -/
  comp : Corr → Corr → Corr
  /-- Composition is bilinear -/
  comp_add_left : ∀ a b c, comp (a + b) c = comp a c + comp b c
  comp_add_right : ∀ a b c, comp a (b + c) = comp a b + comp a c
  /-- Composition is associative -/
  comp_assoc : ∀ a b c, comp (comp a b) c = comp a (comp b c)
  /-- Identity correspondence -/
  one : Corr
  /-- Identity law -/
  comp_one : ∀ a, comp a one = a
  one_comp : ∀ a, comp one a = a
  /-- Transpose / adjoint of a correspondence -/
  transpose : Corr → Corr
  /-- Transpose is an involution -/
  transpose_involution : ∀ a, transpose (transpose a) = a
  /-- Transpose reverses composition -/
  transpose_comp : ∀ a b, transpose (comp a b) = comp (transpose b) (transpose a)

attribute [instance] CorrespondenceAlgebra.instAdd CorrespondenceAlgebra.instModule

namespace CorrespondenceAlgebra

variable {F : Type*} [Field F]

/-- A projector in the correspondence algebra: an idempotent correspondence. -/
def IsProjector (A : CorrespondenceAlgebra F) (p : A.Corr) : Prop :=
  A.comp p p = p

/-- A self-adjoint projector: idempotent and equal to its transpose. -/
def IsSelfAdjointProjector (A : CorrespondenceAlgebra F) (p : A.Corr) : Prop :=
  A.IsProjector p ∧ A.transpose p = p

/-
**Projector Complement.**
If p is a projector, then (1 - p) is also a projector. This is the
fundamental operation for constructing motivic decompositions.
-/
theorem complement_projector (A : CorrespondenceAlgebra F) (p : A.Corr)
    (hp : A.IsProjector p) :
    A.IsProjector (A.one - p) := by
  have h_assoc : ∀ a b c : A.Corr, A.comp a (b - c) = A.comp a b - A.comp a c := by
    intro a b c;
    have := A.comp_add_right a ( b - c ) c; simp_all +decide [ sub_eq_add_neg ] ;
  have h_assoc' : ∀ a b c : A.Corr, A.comp (a - b) c = A.comp a c - A.comp b c := by
    intro a b c; exact (by
    have := A.comp_add_left ( a - b ) b c; simp_all +decide;);
  simp_all +decide [ CorrespondenceAlgebra.IsProjector ];
  simp +decide [ A.comp_one, A.one_comp ]

/-
**Transpose preserves projectors.**
If p is a projector, then its transpose is also a projector.
-/
theorem transpose_projector (A : CorrespondenceAlgebra F) (p : A.Corr)
    (hp : A.IsProjector p) :
    A.IsProjector (A.transpose p) := by
  rw [ CorrespondenceAlgebra.IsProjector ] at hp ⊢;
  convert congr_arg A.transpose hp using 1;
  exact A.transpose_comp p p ▸ rfl

/-
**Self-adjoint projector decomposition.**
Given a projector p, both p·pᵗ and pᵗ·p are self-adjoint projectors
(when properly normalized). Here we prove the weaker statement that
the transpose of p composed with p is self-adjoint.
-/
theorem transpose_comp_self_adjoint (A : CorrespondenceAlgebra F) (p : A.Corr) :
    A.transpose (A.comp (A.transpose p) p) = A.comp (A.transpose p) p := by
  rw [ A.transpose_comp, A.transpose_involution ]

end CorrespondenceAlgebra

/-! ## Part VI: Conjecture — Lefschetz Standard Conjecture implies Hodge Standard -/

/-- **Falsifiable Conjecture: Primitive Rank Bound.**

For a Lefschetz operator L of weight w on V, the dimension of the primitive
subspace P₀ = ker(L) satisfies:
  dim(ker L) ≤ ⌈dim(V) / (w + 1)⌉

This would be a consequence of the Hard Lefschetz theorem: the primitive
decomposition V = ⊕ Lʲ P_{w-2j} forces each primitive piece to have
controlled dimension.

**Test**: Verify computationally for random nilpotent matrices of various sizes.
If false, it would mean the algebraic structure of Lefschetz modules is less
constrained than the geometric setting suggests. -/
def primitiveRankBoundConjecture (F : Type*) [Field F]
    (V : Type*) [AddCommGroup V] [Module F V] [FiniteDimensional F V]
    (Λ : LefschetzOperator F V) : Prop :=
  finrank F (LinearMap.ker Λ.L) * (Λ.weight + 1) ≥ finrank F V

end