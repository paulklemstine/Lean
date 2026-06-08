/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Compact Operators and Invariant Subspaces

This file develops a formally verified theory of invariant subspaces arising from
compact operators on complex Hilbert spaces. The central results establish that:

1. Eigenspaces of compact operators for nonzero eigenvalues are closed, T-invariant,
   and nontrivial proper subspaces (Theorem A).
2. Operators commuting with a compact operator preserve its eigenspaces, hence inherit
   nontrivial closed invariant subspaces (Theorem B).
3. Eigenspaces of compact operators for nonzero eigenvalues are finite-dimensional
   (Theorem C).
4. These results organize into a reusable "compactly generated invariant geometry"
   framework.

## Mathematical significance

These theorems formalize the core mechanism behind the Aronszajn–Smith theorem and
special cases of Lomonosov's theorem: compactness forces finite-dimensional spectral
nuclei that are preserved by commuting operators. This is the formal seed for a
verified theory of invariant subspaces, hyperinvariant subspaces, and counterexample
architectures (Enflo–Read).

## References

* Aronszajn, N. and Smith, K.T. (1954). Invariant subspaces of completely continuous
  operators.
* Lomonosov, V.I. (1973). Invariant subspaces of the family of operators that commute
  with a completely continuous operator.
-/
import Mathlib

open Submodule Module

noncomputable section

/-! ## Novel definitions -/

/-- An operator `T` commutes with some nonzero compact operator. This is the key
hypothesis in special cases of Lomonosov's theorem: operators in the commutant of
a nonzero compact operator admit nontrivial invariant subspaces (under additional
spectral hypotheses). -/
def CommutesWithCompact
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (T : H →L[ℂ] H) : Prop :=
  ∃ K : H →L[ℂ] H, K ≠ 0 ∧ IsCompactOperator K ∧ T.comp K = K.comp T

/-- A `CompactlyGeneratedInvariant` packages a nontrivial proper closed subspace
together with a set of operators that preserve it. This is instantiated from
eigenspaces of compact operators and their commutants. -/
structure CompactlyGeneratedInvariant
    (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H] where
  /-- The carrier submodule. -/
  carrier : Submodule ℂ H
  /-- The subspace is nontrivial (not ⊥). -/
  nontrivial : carrier ≠ ⊥
  /-- The subspace is proper (not ⊤). -/
  proper : carrier ≠ ⊤
  /-- The subspace is closed. -/
  closed' : IsClosed (carrier : Set H)
  /-- The set of operators that preserve this subspace. -/
  invariant_under : Set (H →L[ℂ] H)
  /-- Every operator in `invariant_under` maps the carrier into itself. -/
  stable' : ∀ T ∈ invariant_under, ∀ x ∈ carrier, T x ∈ carrier

/-- An `EnfloReadPattern` formalizes a necessary obstruction for operators without
nontrivial invariant subspaces: any compact operator commuting with such an operator
must be zero. This captures the anti-Lomonosov structure of genuine counterexamples
on Banach spaces. -/
structure EnfloReadPattern
    (H : Type*) [NormedAddCommGroup H] [NormedSpace ℂ H] where
  /-- The operator with no compact commutant structure. -/
  T : H →L[ℂ] H
  /-- Every compact operator commuting with T is zero. -/
  no_nonzero_compact_commutant :
    ∀ K : H →L[ℂ] H, IsCompactOperator K → T.comp K = K.comp T → K = 0

/-! ## Eigenspace closedness -/

/-
The eigenspace of a continuous linear map is closed, since it equals the kernel
of the continuous operator `T - μ • id`.
-/
theorem eigenspace_isClosed' {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T : H →L[ℂ] H) (μ : ℂ) :
    IsClosed (End.eigenspace (T : H →ₗ[ℂ] H) μ : Set H) := by
  -- The eigenvalue equation is linear, so the kernel of `T - μ • id` is a subspace.
  have h_kernel : End.eigenspace (T.toLinearMap) μ = LinearMap.ker (T.toLinearMap - μ • (LinearMap.id : H →ₗ[ℂ] H)) := by
    ext; simp +decide [ sub_eq_zero ] ;
  convert ( ContinuousLinearMap.isClosed_ker ( T - μ • ( ContinuousLinearMap.id ℂ H ) ) )

/-! ## Theorem A: Eigenspace is T-invariant -/

/-
The eigenspace of `T` for eigenvalue `μ` is invariant under `T`: if `T x = μ x`,
then `T(Tx) = T(μx) = μ(Tx)`, so `Tx` is also in the eigenspace.
-/
theorem eigenspace_invariant_under_self {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T : H →L[ℂ] H) (μ : ℂ) :
    ∀ x ∈ End.eigenspace (T : H →ₗ[ℂ] H) μ,
      T x ∈ End.eigenspace (T : H →ₗ[ℂ] H) μ := by
  simp +contextual [ End.mem_eigenspace_iff, mul_comm ]

/-! ## Key Lemma: Commuting operators preserve eigenspaces -/

/-
**Eigenspace transport through commutation.** If `T` and `K` commute
(`T ∘ K = K ∘ T`), then `T` preserves every eigenspace of `K`.

The proof is the algebraic identity: if `K x = μ x`, then
`K(Tx) = T(Kx) = T(μx) = μ(Tx)`, so `Tx ∈ Eμ(K)`.
-/
theorem eigenspace_map_of_commuting {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (T K : H →L[ℂ] H) {μ : ℂ}
    (hcomm : T.comp K = K.comp T) :
    ∀ x ∈ End.eigenspace (K : H →ₗ[ℂ] H) μ,
      T x ∈ End.eigenspace (K : H →ₗ[ℂ] H) μ := by
  simp_all +decide [ funext_iff, ContinuousLinearMap.ext_iff ];
  simp +contextual [ ← hcomm, ContinuousLinearMap.map_smul ]

/-
**Commutant preserves compact spectral sectors.** If every operator in `S`
commutes with `K`, then every operator in `S` preserves the eigenspace of `K`
for any eigenvalue. This is the engine for building invariant subspaces from
compact operator eigenspaces.
-/
theorem commutant_preserves_compact_spectral_sector {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (K : H →L[ℂ] H)
    (S : Set (H →L[ℂ] H))
    (hcomm : ∀ T ∈ S, T.comp K = K.comp T)
    {μ : ℂ} :
    ∀ T ∈ S, ∀ x ∈ End.eigenspace (K : H →ₗ[ℂ] H) μ,
      T x ∈ End.eigenspace (K : H →ₗ[ℂ] H) μ := by
  intro T hT
  exact eigenspace_map_of_commuting T K (hcomm T hT)

/-! ## Theorem C: Finite-dimensionality of nonzero eigenspaces of compact operators -/

/-
**Finite-dimensionality of nonzero eigenspaces.** For a compact operator `T`,
every eigenspace corresponding to a nonzero eigenvalue is finite-dimensional.

This is the crucial bridge: finite-dimensionality is what makes eigenspaces proper
in infinite-dimensional ambient spaces, converting compactness into invariant
geometry.

**Proof idea (Strategy C — orthogonality):** Assume for contradiction that the
eigenspace is infinite-dimensional. Then it contains an infinite orthonormal
sequence `(eₙ)`. Since `T eₙ = μ eₙ` and `‖μ eₙ - μ eₘ‖ = |μ| · √2` for
`n ≠ m`, the image sequence has no convergent subsequence when `μ ≠ 0`,
contradicting compactness.
-/
theorem finiteDimensional_eigenspace_of_isCompactOperator {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (T : H →L[ℂ] H)
    (hTcomp : IsCompactOperator T)
    {μ : ℂ}
    (hμ : μ ≠ 0) :
    FiniteDimensional ℂ (End.eigenspace (T : H →ₗ[ℂ] H) μ) := by
  -- Since $T$ is compact, the image of the closed unit ball in the eigenspace is relatively compact.
  have h_rel_compact : IsCompact (closure (T '' (Metric.closedBall (0 : H) 1 ∩ (End.eigenspace (T : H →ₗ[ℂ] H) μ)))) := by
    exact hTcomp.isCompact_closure_image_closedBall 1 |> fun h => h.of_isClosed_subset isClosed_closure ( closure_mono <| Set.image_mono <| Set.inter_subset_left );
  -- Since $T$ acts as scalar multiplication by $\mu$ on the eigenspace, the image of the closed unit ball in the eigenspace under $T$ is $\mu$ times the closed unit ball in the eigenspace.
  have h_image : T '' (Metric.closedBall (0 : H) 1 ∩ (End.eigenspace (T : H →ₗ[ℂ] H) μ)) = (fun x => μ • x) '' (Metric.closedBall (0 : H) 1 ∩ (End.eigenspace (T : H →ₗ[ℂ] H) μ)) := by
    ext; simp [Set.mem_image];
    grind +ring;
  -- Since μ is nonzero, the image of the closed unit ball in the eigenspace under scalar multiplication by μ is also relatively compact.
  have h_rel_compact_scaled : IsCompact (closure (Metric.closedBall (0 : H) 1 ∩ (End.eigenspace (T : H →ₗ[ℂ] H) μ))) := by
    convert h_rel_compact.smul ( μ⁻¹ ) using 1;
    simp +decide [ h_image, Set.ext_iff, Set.mem_smul_set, hμ ];
    intro x; constructor <;> intro hx;
    · refine' ⟨ μ • x, _, _ ⟩ <;> simp_all +decide [ Set.mem_smul_set, smul_smul ];
      exact mem_closure_image ( continuous_const_smul μ |> Continuous.continuousAt ) hx;
    · rcases hx with ⟨ y, hy, rfl ⟩;
      rw [ mem_closure_iff_seq_limit ] at *;
      rcases hy with ⟨ x, hx, hy ⟩;
      choose f hf using hx;
      refine' ⟨ f, fun n => hf n |>.1, _ ⟩;
      convert hy.const_smul μ⁻¹ using 1;
      exact funext fun n => by rw [ ← hf n |>.2, smul_smul, inv_mul_cancel₀ hμ, one_smul ] ;
  have h_finite_dimensional : IsCompact (Metric.closedBall (0 : ↥(End.eigenspace (T : H →ₗ[ℂ] H) μ)) 1) := by
    have h_finite_dimensional : IsCompact (Set.image (fun x : ↥(End.eigenspace (T : H →ₗ[ℂ] H) μ) => x.val) (Metric.closedBall (0 : ↥(End.eigenspace (T : H →ₗ[ℂ] H) μ)) 1)) := by
      convert h_rel_compact_scaled using 1;
      refine' Set.Subset.antisymm _ _ <;> intro x hx <;> simp_all +decide [ Set.image ];
      · exact subset_closure ⟨ mem_closedBall_zero_iff.mpr hx.1, by simpa [ Module.End.mem_eigenspace_iff ] using hx.2 ⟩;
      · rw [ mem_closure_iff_seq_limit ] at hx;
        obtain ⟨ y, hy, hy' ⟩ := hx;
        have h_closed : IsClosed (End.eigenspace (T : H →ₗ[ℂ] H) μ : Set H) := by
          exact?;
        exact ⟨ le_of_tendsto' ( hy'.norm ) fun n => by simpa using hy n |>.1, by simpa using h_closed.mem_of_tendsto hy' ( Filter.Eventually.of_forall fun n => hy n |>.2 ) ⟩;
    exact?;
  exact FiniteDimensional.of_isCompact_closedBall _ zero_lt_one h_finite_dimensional

/-! ## Submodule proper in infinite-dimensional space -/

/-
A finite-dimensional submodule is proper (≠ ⊤) in any space that is not
itself finite-dimensional.
-/
theorem Submodule.ne_top_of_fd_of_not_fd {K : Type*} {V : Type*}
    [DivisionRing K] [AddCommGroup V] [Module K V]
    (S : Submodule K V) [FiniteDimensional K S]
    (hV : ¬ FiniteDimensional K V) : S ≠ ⊤ := by
  contrapose! hV;
  -- Since $S = \top$, every element of $V$ is in $S$.
  have h_surjective : Function.Surjective (Submodule.subtype S) := by
    simp [hV, Function.Surjective];
  exact FiniteDimensional.of_surjective ( S.subtype ) h_surjective

/-! ## Theorem A (full): Eigenspace is nontrivial proper closed invariant subspace -/

/-
**Eigenspace invariant subspace theorem.** Let `T` be a compact operator on an
infinite-dimensional complex Hilbert space, and let `μ ≠ 0` be an eigenvalue of `T`.
Then the eigenspace `Eμ(T)` is a nontrivial proper closed `T`-invariant subspace.

This formalizes the core mechanism of the Aronszajn–Smith theorem: compactness
forces finite-dimensional spectral nuclei inside infinite-dimensional spaces.
-/
theorem eigenspace_is_nontrivial_proper_closedInvariant
    {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (T : H →L[ℂ] H)
    (hTcomp : IsCompactOperator T)
    {μ : ℂ}
    (hμ : μ ≠ 0)
    (hμeig : ∃ x : H, x ≠ 0 ∧ T x = μ • x) :
    ∃ K : Submodule ℂ H,
      K ≠ ⊥ ∧ K ≠ ⊤ ∧
      IsClosed (K : Set H) ∧
      ∀ x ∈ K, T x ∈ K := by
  refine' ⟨ End.eigenspace ( T : H →ₗ[ℂ] H ) μ, _, _, _, _ ⟩;
  · simp_all +decide [ Submodule.eq_bot_iff ];
    tauto;
  · convert Submodule.ne_top_of_fd_of_not_fd ( End.eigenspace ( T : H →ₗ[ℂ] H ) μ ) _;
    · convert finiteDimensional_eigenspace_of_isCompactOperator T hTcomp hμ;
    · exact hInfDim;
  · exact eigenspace_isClosed' T μ
  · exact fun x a => eigenspace_invariant_under_self T μ x a

/-! ## Theorem B: Commuting operator inherits invariant subspace -/

/-
**Commutant invariant subspace theorem.** If `T` commutes with a compact
operator `K` that has a nonzero eigenvalue, then `T` admits a nontrivial closed
invariant subspace.

This is a rigorous special case of Lomonosov's theorem: the eigenspace of `K`
for the nonzero eigenvalue is finite-dimensional (by compactness), hence proper
in the infinite-dimensional ambient space, nontrivial (an eigenvector exists),
closed (kernel of a continuous map), and `T`-invariant (by commutation).
-/
theorem commuting_operator_has_invariant_subspace_of_compact_eigenvalue
    {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (T K : H →L[ℂ] H)
    (hKcomp : IsCompactOperator K)
    (hcomm : T.comp K = K.comp T)
    {μ : ℂ}
    (hμ : μ ≠ 0)
    (hμeig : ∃ x : H, x ≠ 0 ∧ K x = μ • x) :
    ∃ M : Submodule ℂ H,
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      IsClosed (M : Set H) ∧
      (∀ x ∈ M, T x ∈ M) := by
  -- Let $M$ be the eigenspace of $K$ for the eigenvalue $\mu$.
  use End.eigenspace (K : H →ₗ[ℂ] H) μ;
  refine' ⟨ _, _, _, _ ⟩;
  · simp_all +decide [ Submodule.eq_bot_iff ];
    tauto;
  · convert Submodule.ne_top_of_fd_of_not_fd ( End.eigenspace ( K : H →ₗ[ℂ] H ) μ ) _;
    · convert finiteDimensional_eigenspace_of_isCompactOperator K hKcomp hμ;
    · exact hInfDim;
  · exact eigenspace_isClosed' K μ
  · exact fun x a => eigenspace_map_of_commuting T K hcomm x a

/-
**CommutesWithCompact implies invariant subspace** (under eigenvalue hypothesis).
An operator that commutes with a nonzero compact operator having a nonzero
eigenvalue admits a nontrivial closed invariant subspace.
-/
theorem commutesWithCompact_has_invariant_subspace_of_nonzero_eigenvalue
    {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (T : H →L[ℂ] H)
    (_hCWC : CommutesWithCompact T)
    {μ : ℂ} (hμ : μ ≠ 0)
    (hμeig : ∃ K : H →L[ℂ] H, IsCompactOperator K ∧ T.comp K = K.comp T ∧
      ∃ x : H, x ≠ 0 ∧ K x = μ • x) :
    ∃ M : Submodule ℂ H,
      M ≠ ⊥ ∧ M ≠ ⊤ ∧
      IsClosed (M : Set H) ∧
      (∀ x ∈ M, T x ∈ M) := by
  obtain ⟨ K, hKcomp, hcommK, x, hx0, hKx ⟩ := hμeig; exact commuting_operator_has_invariant_subspace_of_compact_eigenvalue hInfDim T K hKcomp hcommK hμ ⟨ x, hx0, hKx ⟩ ;

/-! ## Counterexample boundary theorem -/

/-
**Enflo–Read obstruction theorem.** If an operator `T` on an infinite-dimensional
complex Hilbert space has no nontrivial closed invariant subspace, then for every
compact operator `K` commuting with `T`, `K` can have no nonzero eigenvalue.

This is the contrapositive of the commutant invariant subspace theorem and
formalizes a necessary structural property of any genuine counterexample to the
invariant subspace problem.
-/
theorem noInvariantSubspace_implies_no_compact_eigenvalue_commutant
    {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (T : H →L[ℂ] H)
    (hno : ¬ ∃ M : Submodule ℂ H,
      M ≠ ⊥ ∧ M ≠ ⊤ ∧ IsClosed (M : Set H) ∧ ∀ x ∈ M, T x ∈ M) :
    ∀ K : H →L[ℂ] H, IsCompactOperator K → T.comp K = K.comp T →
      ∀ μ : ℂ, μ ≠ 0 → ¬ ∃ x : H, x ≠ 0 ∧ K x = μ • x := by
  intro K hK hcomm μ hμ hμeig
  by_contra h_contra;
  exact hno <| commuting_operator_has_invariant_subspace_of_compact_eigenvalue hInfDim T K hK hcomm hμ hμeig

/-! ## Self-adjoint compact operator: mode preservation (dynamical systems connection) -/

/-
**Compact self-adjoint mode preservation.** If `K` is compact and self-adjoint
and `T` commutes with `K`, then each nonzero eigenspace of `K` is a
finite-dimensional `T`-invariant "mode sector."

This connects to dynamical systems (Koopman operators): the eigenspaces are
observable modes preserved by the dynamics `T`, and compactness ensures they are
finite-dimensional.
-/
theorem selfAdjoint_compact_mode_preservation
    {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (_hInfDim : ¬ FiniteDimensional ℂ H)
    (K : H →L[ℂ] H)
    (hKcomp : IsCompactOperator K)
    (_hKsa : IsSelfAdjoint K)
    (T : H →L[ℂ] H)
    (hcomm : T.comp K = K.comp T)
    {μ : ℂ} (hμ : μ ≠ 0) :
    FiniteDimensional ℂ (End.eigenspace (K : H →ₗ[ℂ] H) μ) ∧
    (∀ x ∈ End.eigenspace (K : H →ₗ[ℂ] H) μ,
      T x ∈ End.eigenspace (K : H →ₗ[ℂ] H) μ) := by
  exact ⟨finiteDimensional_eigenspace_of_isCompactOperator K hKcomp hμ,
         eigenspace_map_of_commuting T K hcomm⟩

/-! ## Construction: CompactlyGeneratedInvariant from eigenspace -/

/-
Construct a `CompactlyGeneratedInvariant` from a compact operator's nonzero
eigenspace and the set of all operators commuting with it.
-/
theorem compactlyGeneratedInvariant_of_compact_eigenspace
    {H : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    (hInfDim : ¬ FiniteDimensional ℂ H)
    (K : H →L[ℂ] H)
    (hKcomp : IsCompactOperator K)
    {μ : ℂ} (hμ : μ ≠ 0)
    (hμeig : ∃ x : H, x ≠ 0 ∧ K x = μ • x) :
    ∃ cgi : CompactlyGeneratedInvariant H,
      (∀ T : H →L[ℂ] H, T.comp K = K.comp T → T ∈ cgi.invariant_under) ∧
      K ∈ cgi.invariant_under := by
  refine ⟨⟨End.eigenspace (K : H →ₗ[ℂ] H) μ, ?_, ?_, ?_, {T : H →L[ℂ] H | T.comp K = K.comp T}, ?_⟩, ?_, ?_⟩
  · simp_all +decide [Submodule.eq_bot_iff]; tauto
  · have := finiteDimensional_eigenspace_of_isCompactOperator K hKcomp hμ
    exact Submodule.ne_top_of_fd_of_not_fd _ hInfDim
  · exact eigenspace_isClosed' K μ
  · exact fun T hT x hx => eigenspace_map_of_commuting T K hT x hx
  · exact fun T a => a
  · exact rfl

end