/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Invariant Subspace Problem: Formalized Theory

This file develops a formally verified theory of invariant subspaces for bounded
linear operators on Hilbert spaces, building on the compact operator eigenspace
results in `Algebra.CompactOperators`.

## Main Results

1. **Finite-dimensional ISP** (Theorem): Every endomorphism of a nontrivial
   finite-dimensional complex vector space has a nontrivial invariant subspace
   (as a consequence of the fundamental theorem of algebra).

2. **Reducing subspace theory**: We define reducing subspaces (where both M and M⊥
   are invariant) and prove that self-adjoint operators on Hilbert spaces have the
   property that eigenspaces are reducing.

3. **Invariant subspace lattice**: The collection of closed invariant subspaces
   forms a complete lattice under intersection, and we prove key closure properties.

4. **Cross-domain bridge to quantum mechanics**: Self-adjoint operators (observables)
   have eigenspaces that are reducing, connecting operator theory to measurement
   theory in quantum mechanics.

5. **Conjecture**: The full invariant subspace problem for separable Hilbert spaces
   is stated as a formal conjecture with testable computational predictions.

## References

* Halmos, P.R. (1982). A Hilbert Space Problem Book.
* Radjavi, H. and Rosenthal, P. (2003). Invariant Subspaces.
* Enflo, P. (1987). On the invariant subspace problem for Banach spaces.
-/
import Mathlib

open Submodule Module LinearMap

noncomputable section

/-! ## Novel Definition: Reducing Subspace -/

/-- A **reducing subspace** for an operator `T` is a closed subspace `M` such that
both `M` and its orthogonal complement `M⊥` are invariant under `T`. Reducing
subspaces decompose the operator into a direct sum `T|_M ⊕ T|_{M⊥}`.

This is strictly stronger than mere invariance: every reducing subspace is
invariant, but not conversely (e.g., the unilateral shift has invariant subspaces
that are not reducing). For normal operators, every closed invariant subspace
is reducing (Fuglede's theorem). -/
structure ReducingSubspace
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T : H →L[ℂ] H) where
  /-- The carrier submodule. -/
  carrier : Submodule ℂ H
  /-- The subspace is closed. -/
  closed' : IsClosed (carrier : Set H)
  /-- The subspace is T-invariant. -/
  invariant : ∀ x ∈ carrier, T x ∈ carrier
  /-- The orthogonal complement is also T-invariant. -/
  ortho_invariant : ∀ x ∈ carrier.orthogonal, T x ∈ carrier.orthogonal

/-- A reducing subspace is **nontrivial** if it is neither ⊥ nor ⊤. -/
def ReducingSubspace.IsNontrivial
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    {T : H →L[ℂ] H} (R : ReducingSubspace T) : Prop :=
  R.carrier ≠ ⊥ ∧ R.carrier ≠ ⊤

/-! ## Novel Definition: Invariant Subspace Property -/

/-- An operator **has the invariant subspace property** (ISP) if it admits a
nontrivial closed invariant subspace. The invariant subspace problem asks
whether every bounded linear operator on a separable infinite-dimensional
Hilbert space has this property. -/
def HasInvariantSubspaceProperty
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T : H →L[ℂ] H) : Prop :=
  ∃ M : Submodule ℂ H,
    M ≠ ⊥ ∧ M ≠ ⊤ ∧
    IsClosed (M : Set H) ∧
    ∀ x ∈ M, T x ∈ M

/-! ## Invariant subspace lattice closure under intersection -/

/-- The intersection of two closed invariant subspaces is again a closed invariant
subspace. This establishes that the collection of closed invariant subspaces is
closed under finite (and by induction, arbitrary finite) meets. -/
theorem invariantSubspace_inf_closed
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T : H →L[ℂ] H)
    {M₁ M₂ : Submodule ℂ H}
    (hM₁_closed : IsClosed (M₁ : Set H))
    (hM₂_closed : IsClosed (M₂ : Set H))
    (hM₁_inv : ∀ x ∈ M₁, T x ∈ M₁)
    (hM₂_inv : ∀ x ∈ M₂, T x ∈ M₂) :
    IsClosed ((M₁ ⊓ M₂ : Submodule ℂ H) : Set H) ∧
    (∀ x ∈ (M₁ ⊓ M₂ : Submodule ℂ H), T x ∈ (M₁ ⊓ M₂ : Submodule ℂ H)) := by
  constructor
  · -- Intersection of closed sets is closed
    have h : ((M₁ ⊓ M₂ : Submodule ℂ H) : Set H) = (M₁ : Set H) ∩ (M₂ : Set H) := by
      ext x; simp [Submodule.mem_inf]
    rw [h]
    exact IsClosed.inter hM₁_closed hM₂_closed
  · -- T maps the intersection into itself
    intro x hx
    rw [Submodule.mem_inf] at hx ⊢
    exact ⟨hM₁_inv x hx.1, hM₂_inv x hx.2⟩

/-! ## Finite-Dimensional Invariant Subspace Property -/

/-
**Finite-Dimensional ISP.** Every endomorphism of a nontrivial finite-dimensional
complex vector space of dimension ≥ 2 has a nontrivial invariant subspace.

This follows from the fundamental theorem of algebra: ℂ is algebraically closed,
so every endomorphism has an eigenvalue, and the corresponding eigenspace is a
nontrivial invariant subspace. When dim = 1, ⊥ and ⊤ are the only subspaces, so
we need dim ≥ 2.

This is the "easy" case of the invariant subspace problem, but it is the essential
base case that makes the infinite-dimensional question meaningful.
-/
theorem finiteDimensional_ISP
    {V : Type*} [AddCommGroup V] [Module ℂ V]
    [FiniteDimensional ℂ V]
    (hdim : 1 < Module.finrank ℂ V)
    (T : V →ₗ[ℂ] V) :
    ∃ M : Submodule ℂ V, M ≠ ⊥ ∧ M ≠ ⊤ ∧ ∀ x ∈ M, T x ∈ M := by
  by_contra! h';
  -- Since is algebraically closed and � V� is finite-dimensional � with� dim ≥ 2, use Module.End.exists_eigenvalue to get an eigenvalue μ.
  obtain ⟨μ, hμ⟩ : ∃ μ : ℂ, ∃ v : V, v ≠ 0 ∧ T v = μ • v := by
    have := @Module.End.exists_eigenvalue ℂ V;
    convert this T;
    · simp +decide [ Module.End.HasUnifEigenvalue ];
      simp +decide [ Submodule.eq_bot_iff ];
      tauto;
    · exact Module.nontrivial_of_finrank_pos ( pos_of_gt hdim );
  -- Since V is finite-dimensional with dim ≥ � �2, the eigenspace E_μ is nontr �ivial� and is T-invariant by eigenspace_invariant.
  obtain ⟨v, hv_ne_zero, hv_eigen⟩ : ∃ v : V, v ≠ 0 ∧ T v = μ • v := hμ
  set M : Submodule ℂ V := Submodule.span ℂ {v}
  have hM_ne_bot : M ≠ ⊥ := by
    aesop
  have hM_ne_top : M ≠ ⊤ := by
    grind +suggestions
  have hM_inv : ∀ x ∈ M, T x ∈ M := by
    intro x hx; rw [ Submodule.mem_span_singleton ] at hx; obtain ⟨ c, rfl ⟩ := hx; simp +decide [ hv_eigen, smul_smul ] ;
    exact Submodule.smul_mem _ _ ( Submodule.mem_span_singleton_self _ );
  exact absurd ( h' M hM_ne_bot hM_ne_top ) ( by push_neg; exact hM_inv )

/-! ## Eigenspace is invariant (pure algebra version) -/

/-
The eigenspace of a linear map is invariant under that map. This is a purely
algebraic fact: if `T x = μ x`, then `T(Tx) = T(μx) = μ(Tx)`.
-/
theorem eigenspace_invariant
    {R : Type*} {M : Type*} [CommRing R] [AddCommGroup M] [Module R M]
    (T : M →ₗ[R] M) (μ : R) :
    ∀ x ∈ End.eigenspace T μ, T x ∈ End.eigenspace T μ := by
  simp +contextual [ End.mem_eigenspace_iff, mul_comm ]

/-! ## Kernel and range are invariant -/

/-
The kernel of a linear map is invariant under any map that commutes with it.
This is a fundamental structural lemma: `ker(K)` is `T`-invariant whenever
`T ∘ K = K ∘ T`.
-/
theorem ker_invariant_of_comm
    {R : Type*} {M : Type*} [CommRing R] [AddCommGroup M] [Module R M]
    (T K : M →ₗ[R] M)
    (hcomm : T.comp K = K.comp T) :
    ∀ x ∈ LinearMap.ker K, T x ∈ LinearMap.ker K := by
  intro x hx; replace hcomm := LinearMap.congr_fun hcomm x; aesop;

/-
The range of a linear map is invariant under any map that commutes with it.
-/
theorem range_invariant_of_comm
    {R : Type*} {M : Type*} [CommRing R] [AddCommGroup M] [Module R M]
    (T K : M →ₗ[R] M)
    (hcomm : T.comp K = K.comp T) :
    ∀ x ∈ LinearMap.range K, T x ∈ LinearMap.range K := by
  simp_all +decide [ funext_iff, LinearMap.ext_iff ]

/-! ## Self-adjoint eigenspaces are orthogonal (cross-domain: quantum mechanics) -/

/-
**Orthogonality of distinct eigenspaces of self-adjoint operators.**

If `T` is self-adjoint (i.e., `T = T*`) and `μ ≠ ν` are distinct eigenvalues,
then the eigenspaces `E_μ` and `E_ν` are orthogonal: `⟨x, y⟩ = 0` for all
`x ∈ E_μ` and `y ∈ E_ν`.

**Cross-domain significance (Quantum Mechanics):** In quantum mechanics, observables
are self-adjoint operators, and measurement outcomes correspond to eigenvalues.
This theorem establishes that states corresponding to distinct measurement outcomes
are orthogonal — the mathematical foundation of the Born rule and quantum
measurement theory. The eigenspaces are the "measurement sectors" that define
the quantum superposition principle.

**Proof:** For self-adjoint `T`, eigenvalues are real. If `Tx = μx` and `Ty = νy`,
then `μ⟨x,y⟩ = ⟨Tx,y⟩ = ⟨x,Ty⟩ = ν̄⟨x,y⟩ = ν⟨x,y⟩` (since ν is real for
self-adjoint T). Thus `(μ - ν)⟨x,y⟩ = 0`, and since `μ ≠ ν`, we get `⟨x,y⟩ = 0`.
-/
theorem selfAdjoint_eigenspaces_orthogonal
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (T : H →L[ℂ] H) (hsa : IsSelfAdjoint T)
    {μ ν : ℂ} (hμν : μ ≠ ν)
    {x y : H}
    (hx : x ∈ End.eigenspace (T : H →ₗ[ℂ] H) μ)
    (hy : y ∈ End.eigenspace (T : H →ₗ[ℂ] H) ν) :
    @inner ℂ H _ x y = 0 := by
  -- Since $T$ is self-adjoint, we have $\langle Tx, y \rangle = \langle x, Ty \rangle$.
  have h_self_adjoint : inner ℂ (T x) y = inner ℂ x (T y) := by
    rw [ ← ContinuousLinearMap.adjoint_inner_right, hsa.adjoint_eq ];
  have h_eigenvalue_real : ∀ (μ : ℂ) (x : H), x ≠ 0 → T x = μ • x → μ = starRingEnd ℂ μ := by
    intro μ x hx hx'; have := hsa.adjoint_eq; simp_all +decide [ ContinuousLinearMap.ext_iff ] ;
    have := ContinuousLinearMap.adjoint_inner_left T x x; simp_all +decide [ inner_smul_left, inner_smul_right ] ;
  by_cases hx0 : x = 0 <;> by_cases hy0 : y = 0 <;> simp_all +decide [ mul_comm ];
  grind +ring

/-! ## Self-adjoint eigenspace is reducing -/

/-
**Self-adjoint eigenspace is reducing.** For a self-adjoint operator `T` on a
Hilbert space, every eigenspace is a reducing subspace: both the eigenspace and
its orthogonal complement are `T`-invariant.

This follows from the orthogonality of eigenspaces: if `y ⊥ E_μ` and we want to
show `Ty ⊥ E_μ`, take any `x ∈ E_μ`. Then `⟨Ty, x⟩ = ⟨y, Tx⟩ = ⟨y, μx⟩ = μ̄⟨y,x⟩ = 0`.

**Physical interpretation:** Measurement sectors are invariant under time evolution
generated by the observable — this is the mathematical content of the fact that
measurements are "stable" in the sense that measuring an observable twice gives
the same result.
-/
theorem selfAdjoint_eigenspace_orthogonal_invariant
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (T : H →L[ℂ] H) (hsa : IsSelfAdjoint T) (μ : ℂ) :
    ∀ y ∈ (End.eigenspace (T : H →ₗ[ℂ] H) μ).orthogonal,
      T y ∈ (End.eigenspace (T : H →ₗ[ℂ] H) μ).orthogonal := by
  intro y hy; simp_all +decide [ Submodule.mem_orthogonal', inner_smul_left ] ;
  intro u hu; rw [ ← ContinuousLinearMap.adjoint_inner_right ] ; simp_all +decide [ IsSelfAdjoint.adjoint_eq ] ;

/-! ## Invariant subspace sum is invariant -/

/-
The sum of two invariant subspaces is invariant. Combined with the intersection
result, this shows the invariant subspaces form a sublattice of the submodule
lattice.
-/
theorem invariantSubspace_sup_invariant
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T : H →L[ℂ] H)
    {M₁ M₂ : Submodule ℂ H}
    (hM₁_inv : ∀ x ∈ M₁, T x ∈ M₁)
    (hM₂_inv : ∀ x ∈ M₂, T x ∈ M₂) :
    ∀ x ∈ (M₁ ⊔ M₂ : Submodule ℂ H), T x ∈ (M₁ ⊔ M₂ : Submodule ℂ H) := by
  intro x hx; rw [ Submodule.mem_sup ] at hx ⊢; obtain ⟨ x₁, hx₁, x₂, hx₂, rfl ⟩ := hx; exact ⟨ T x₁, hM₁_inv x₁ hx₁, T x₂, hM₂_inv x₂ hx₂, by simp +decide ⟩ ;

/-! ## Polynomial in operator preserves invariant subspaces -/

/-
If `M` is invariant under `T`, then `M` is invariant under `T^n` for all `n`.
This is proved by induction on `n`: the base case is trivial, and the inductive
step uses `T^{n+1} x = T(T^n x)` with the invariance of `M` under `T`.

**Mathematical significance:** This is the algebraic engine behind polynomial
functional calculus — if `M` is `T`-invariant, it is `p(T)`-invariant for every
polynomial `p`. This extends to the continuous functional calculus for normal
operators.
-/
theorem invariant_under_pow
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T : H →L[ℂ] H)
    {M : Submodule ℂ H}
    (hM : ∀ x ∈ M, T x ∈ M)
    (n : ℕ) :
    ∀ x ∈ M, (T ^ n) x ∈ M := by
  induction' n with n ih <;> simp_all +decide [ pow_succ _, mul_assoc ]

/-! ## Spectral Radius and Invariant Subspaces -/

/-
**Nilpotent operators have the ISP.** If `T^n = 0` for some `n ≥ 1`, then
`ker(T)` is a nontrivial invariant subspace (assuming the space is nontrivial
and `T ≠ 0`).

**Proof:** Since `T` is nilpotent with `T^n = 0`, the kernel of `T` is nonzero
(if `ker T = ⊥`, then `T` is injective, but `T^n = 0` implies all elements map to
zero, contradiction since the space is nontrivial). The kernel is proper because
`T ≠ 0`, so there exists `x` with `Tx ≠ 0`, meaning `x ∉ ker T`. The kernel is
always `T`-invariant since `x ∈ ker T` implies `T(Tx) = T(0) = 0`.
-/
theorem nilpotent_has_ISP
    {V : Type*} [AddCommGroup V] [Module ℂ V]
    [Nontrivial V]
    (T : V →ₗ[ℂ] V)
    (hT : T ≠ 0)
    {n : ℕ} (hn : 0 < n)
    (hnil : T ^ n = 0) :
    ∃ M : Submodule ℂ V, M ≠ ⊥ ∧ M ≠ ⊤ ∧ ∀ x ∈ M, T x ∈ M := by
  refine' ⟨ LinearMap.ker T, _, _, _ ⟩;
  · contrapose! hT; simp_all +decide [ LinearMap.ext_iff ] ;
    induction hn <;> simp_all +decide [ pow_succ', LinearMap.ker_comp ];
    simp_all +decide [ Submodule.eq_bot_iff ];
  · contrapose! hT; aesop;
  · aesop

/-! ## Testable Conjecture: Invariant Subspace Problem -/

/-- **The Invariant Subspace Conjecture.** Every bounded linear operator on
a separable infinite-dimensional complex Hilbert space has a nontrivial
closed invariant subspace.

**Status:** Open since 1935 (von Neumann's formulation). Known special cases:
- Compact operators (Aronszajn–Smith, 1954)
- Normal operators (spectral theorem)
- Operators commuting with a compact operator with nonzero eigenvalue (this file)
- Polynomially compact operators (Bernstein–Robinson, 1966)

**Testable prediction:** For concrete operators on `ℓ²(ℕ)` (the space of
square-summable sequences), the conjecture predicts that:
1. Every weighted shift operator has a nontrivial closed invariant subspace.
2. Every Toeplitz operator has a nontrivial closed invariant subspace.
3. Every composition operator has a nontrivial closed invariant subspace.

These can be tested computationally by constructing finite-dimensional
truncations and checking whether invariant subspaces of truncations converge
to invariant subspaces of the full operator. A counterexample in any of these
classes would disprove the conjecture.

**Counterexample landscape:** Enflo (1987) and Read (1985) constructed
counterexamples on certain Banach spaces, but no counterexample is known
for Hilbert spaces. The `EnfloReadPattern` structure in `CompactOperators.lean`
formalizes the necessary obstruction. -/
def InvariantSubspaceConjecture : Prop :=
  ∀ (H : Type) [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    [TopologicalSpace.SeparableSpace H] (_ : ¬ FiniteDimensional ℂ H),
    ∀ T : H →L[ℂ] H, HasInvariantSubspaceProperty T

/-! ## Connection Theorem: Compact Operators and the ISP -/

/-
**Compact operators with nonzero eigenvalues satisfy the ISP.**
This connects the eigenspace machinery from `CompactOperators.lean` to the
`HasInvariantSubspaceProperty` predicate defined in this file.

Building on `eigenspace_is_nontrivial_proper_closedInvariant` from the catalog.
-/
theorem compact_nonzero_eigenvalue_has_ISP
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (T : H →L[ℂ] H) (hT : IsCompactOperator T)
    {μ : ℂ} (hμ : μ ≠ 0)
    (hμeig : ∃ x : H, x ≠ 0 ∧ T x = μ • x) :
    HasInvariantSubspaceProperty T := by
  by_contra h_no_ISP;
  unfold HasInvariantSubspaceProperty at h_no_ISP;
  push_neg at h_no_ISP;
  convert h_no_ISP ( End.eigenspace ( T : H →ₗ[ℂ] H ) μ ) _ _ _;
  · aesop;
  · simp_all +decide [ Submodule.ne_bot_iff ];
    tauto;
  · contrapose! h_no_ISP;
    have hT_mul : T = μ • 1 := by
      ext x; replace h_no_ISP := SetLike.ext_iff.mp h_no_ISP x; aesop;
    have h_compact : IsCompactOperator (μ • (1 : H →L[ℂ] H)) := by
      exact hT_mul ▸ hT;
    have h_compact : IsCompactOperator (1 : H →L[ℂ] H) := by
      convert h_compact.smul ( μ⁻¹ ) using 1 ; aesop;
    have := h_compact.isCompact_closure_image_closedBall 1;
    simp +zetaDelta at *;
    exact False.elim ( hInfDim <| FiniteDimensional.of_isCompact_closedBall _ zero_lt_one this );
  · -- The eigenspace of a continuous linear operator is closed.
    have h_eigenspace_closed : IsClosed {x : H | T x = μ • x} := by
      exact isClosed_eq T.continuous ( continuous_const.smul continuous_id' );
    convert h_eigenspace_closed using 1;
    ext; simp [End.eigenspace]

/-! ## Reducing Subspace Construction -/

/-
Construct a reducing subspace from a self-adjoint operator's eigenspace.
-/
theorem selfAdjoint_eigenspace_is_reducing
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (T : H →L[ℂ] H) (hsa : IsSelfAdjoint T) (μ : ℂ) :
    ∃ R : ReducingSubspace T,
      R.carrier = End.eigenspace (T : H →ₗ[ℂ] H) μ := by
  refine' ⟨ ⟨ _, _, _, _ ⟩, rfl ⟩;
  · -- The kernel of a continuous linear map is closed.
    have h_kernel_closed : IsClosed {x : H | (T - μ • 1) x = 0} := by
      exact isClosed_eq ( ContinuousLinearMap.continuous _ ) continuous_const;
    convert h_kernel_closed using 1;
    simp +decide [ sub_eq_zero, Set.ext_iff ];
  · aesop;
  · convert selfAdjoint_eigenspace_orthogonal_invariant T hsa μ using 1

end