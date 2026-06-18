# Future Directions

## Hypothesis A: Full Bidirectional Fredholm Alternative

**Conjecture:** For a compact operator $K$ on an infinite-dimensional Banach space, $I - K$ is surjective if and only if $I - K$ is injective.

**Lean formalization target:**
```lean
theorem IsCompactOperator.surjective_iff_injective_one_sub
    {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E]
    [CompleteSpace E] {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hinfin : ¬FiniteDimensional 𝕜 E) :
    Surjective (1 - K : E →L[𝕜] E) ↔ Injective (1 - K : E →L[𝕜] E)
```

**Test:** Formalize both directions. The forward direction (surjective ⟹ injective) requires applying the existing result to the Banach space adjoint $K^*$, using the fact that:
- $K$ compact implies $K^*$ compact (needs formalization of adjoint compactness)
- $I - K$ surjective iff $I - K^*$ injective (from duality theory)

**Impact:** Completes the Fredholm Alternative. Together with the existing result, packages as a single `iff` theorem. Opens the door to the full Riesz-Schauder theory.

---

## Hypothesis B: Nonzero Spectrum of Compact Operators is Discrete

**Conjecture:** If $K$ is a compact operator on an infinite-dimensional Banach space, then:
1. Every nonzero $\lambda \in \text{spectrum}(K)$ is an eigenvalue of $K$
2. Each nonzero eigenvalue has finite-dimensional eigenspace
3. The set of nonzero eigenvalues is at most countable with accumulation only at $0$

**Lean formalization target:**
```lean
theorem IsCompactOperator.eigenspace_finiteDimensional
    {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E]
    [CompleteSpace E] {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    {λ : 𝕜} (hλ : λ ≠ 0)
    (hinfin : ¬FiniteDimensional 𝕜 E) :
    FiniteDimensional 𝕜 (LinearMap.ker (λ • (1 : E →L[𝕜] E) - K).toLinearMap)
```

**Test:** 
- Prove finite-dimensionality of each nonzero eigenspace
- Prove that nonzero spectral values are isolated points of the spectrum
- Both should follow from the Fredholm Alternative applied to $\lambda^{-1}K$

**Impact:** Establishes the Riesz-Schauder spectral theorem for compact operators. This is the foundation for spectral decomposition and functional calculus of compact operators.

---

## Hypothesis C: Atkinson Prototype — Fredholm Index Zero

**Conjecture:** For a compact operator $K$, the operator $I - K$ is Fredholm of index zero, i.e., $\dim \ker(I - K) = \dim \text{coker}(I - K) < \infty$.

**Lean formalization target:**
```lean
-- First, define a minimal Fredholm predicate
structure IsFredholm {𝕜 E F : Type*} [RCLike 𝕜]
    [NormedAddCommGroup E] [NormedSpace 𝕜 E]
    [NormedAddCommGroup F] [NormedSpace 𝕜 F]
    (T : E →L[𝕜] F) : Prop where
  closedRange : IsClosed (Set.range T)
  finiteDimKer : FiniteDimensional 𝕜 (LinearMap.ker T.toLinearMap)
  finiteDimCoker : FiniteDimensional 𝕜 (E ⧸ LinearMap.range T.toLinearMap)

theorem IsCompactOperator.isFredholm_one_sub
    {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E]
    [CompleteSpace E] {K : E →L[𝕜] E} (hK : IsCompactOperator K) :
    IsFredholm (1 - K : E →L[𝕜] E)

theorem IsCompactOperator.index_zero_one_sub
    {𝕜 E : Type*} [RCLike 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E]
    [CompleteSpace E] {K : E →L[𝕜] E} (hK : IsCompactOperator K) :
    Module.finrank 𝕜 (LinearMap.ker (1 - K : E →L[𝕜] E).toLinearMap) =
    Module.finrank 𝕜 (E ⧸ LinearMap.range (1 - K : E →L[𝕜] E).toLinearMap)
```

**Test:**
- Define `IsFredholm` as a structure with closed range, finite-dimensional kernel, and finite-dimensional cokernel
- Prove $I - K$ is Fredholm
- Prove the index (dim ker - dim coker) equals zero
- The kernel and cokernel dimension equality can be proved using the descending chain argument or the quotient space argument

**Impact:** This is the prototype for general Fredholm index theory. Once established, extends to: stability of index under compact perturbations, Atkinson's theorem (invertible modulo compacts iff Fredholm), and eventually connections to K-theory and the Atiyah-Singer index theorem.

---

## Hypothesis D: Compact Operator Invariant Subspace Theorem

**Conjecture:** A nonzero compact operator on a complex infinite-dimensional Banach space has a nontrivial closed invariant subspace.

**Lean formalization target:**
```lean
theorem IsCompactOperator.exists_invariantSubspace
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℂ E] [CompleteSpace E]
    {K : E →L[ℂ] E} (hK : IsCompactOperator K) (hne : K ≠ 0)
    (hinfin : ¬FiniteDimensional ℂ E) :
    ∃ V : Submodule ℂ E, V ≠ ⊥ ∧ V ≠ ⊤ ∧ IsClosed (V : Set E) ∧
      ∀ x ∈ V, K x ∈ V
```

**Test:**
- First prove that $K$ has a nonzero eigenvalue (using spectral theory from Hypothesis B)
- The eigenspace is a nontrivial closed invariant subspace
- For the complex case, existence of eigenvalues follows from the analytic Fredholm theorem

**Impact:** This is a special case of the Lomonosov invariant subspace theorem. It demonstrates that spectral theory for compact operators produces geometric structure (invariant subspaces). Bridges to invariant subspace theory and provides the compact-operator beachhead into one of the major open problems in operator theory.

---

## Hypothesis E: Spectral Projections for Normal Compact Operators

**Conjecture:** For a normal compact operator $T$ on a Hilbert space, clopen subsets of the spectrum yield reducing orthogonal projections via the continuous functional calculus.

**Lean formalization target:**
```lean
theorem NormalCompactOperator.spectral_projection
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
    {T : H →L[ℂ] H} (hT : IsCompactOperator T) (hN : T.IsNormal)
    {λ : ℂ} (hλ : λ ∈ spectrum ℂ T) (hλ_ne : λ ≠ 0) :
    ∃ P : H →L[ℂ] H,
      IsIdempotentElem P ∧
      (∀ x, ⟪P x, (1 - P) x⟫_ℂ = 0) ∧
      (∀ x, T (P x) = P (T x)) ∧
      LinearMap.range P.toLinearMap = LinearMap.ker (T - λ • 1 : H →L[ℂ] H).toLinearMap
```

**Test:**
- For each isolated nonzero eigenvalue $\lambda$ of a normal compact operator, construct the spectral projection onto $\ker(T - \lambda I)$
- Prove it is an orthogonal projection (idempotent and self-adjoint)
- Prove it commutes with $T$
- Prove its range is exactly the $\lambda$-eigenspace

**Impact:** This connects compact operator theory to the continuous functional calculus and spectral measures. It provides the foundation for:
- Spectral decomposition of compact normal operators
- Mercer's theorem for positive integral operators
- Connections to quantum mechanics (observable theory)
- The compact-operator approach to invariant subspaces for normal operators
