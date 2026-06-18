# Future Directions: Causal Integration Algebra

## What We Built

We formalized the **Causal Integration Algebra** in two Lean 4 files (`Shared/CausalIntegration/Core.lean` and `Shared/CausalIntegration/Composition.lean`), establishing a rigorous lattice-theoretic foundation connecting Integrated Information Theory (IIT) to minimum cuts of weighted directed graphs. The framework defines:

- `CausalSystem n`: weighted directed graphs on `Fin n` with nonneg edge weights
- `crossInfo C S`: total weight crossing a bipartition (cut value)
- `phi C hn`: integrated information Φ as the minimum cut over nontrivial bipartitions

We proved **11 theorems** with zero sorries:
1. `crossInfo_nonneg` — cut values are nonneg
2. `phi_nonneg` — Φ ≥ 0
3. `phi_le_crossInfo` — Φ ≤ any specific cut
4. `phi_zero_of_disconnected` — disconnected ⟹ Φ = 0
5. `crossInfo_scale` / `phi_scale` — Φ scales linearly with weights
6. `crossInfo_mono` / `phi_mono_of_weight_le` — monotonicity under pointwise weight increase
7. `crossInfo_le_totalWeight` / `phi_le_totalWeight` — upper bound by total weight
8. `symmetrize_crossInfo` — symmetrization decomposes into two directed cuts
9. `crossInfo_pos_of_stronglyPositive` / `phi_pos_of_stronglyPositive` — strongly positive systems have Φ > 0

---

## Direction 1: Spectral Lower Bound via Cheeger Inequality

The Fiedler value λ₂ (second-smallest eigenvalue of the graph Laplacian) provides a spectral lower bound on the minimum cut. For a symmetric causal system, the Cheeger inequality gives λ₂/2 ≤ h(G) where h(G) is the Cheeger constant (normalized minimum cut). The key insight is that our `phi` is closely related to the unnormalized Cheeger constant, so formalizing the graph Laplacian and its spectral gap would yield a computable lower bound on Φ — avoiding exponential brute-force enumeration. Why now? We have `phi_mono_of_weight_le` and `symmetrize_crossInfo` as the foundation; the missing piece is the Rayleigh quotient characterization of λ₂, which requires formalizing inner products on `Fin n → ℝ` and the Laplacian as a linear map.

## Direction 2: Converse of Disconnectedness — Characterizing Φ = 0

We proved `phi_zero_of_disconnected`: if a zero-weight cut exists, Φ = 0. The converse — Φ = 0 implies disconnectedness — is more subtle and amounts to showing that the minimum of a finite set of nonneg reals is zero iff some element is zero. The key insight is that this follows from `Finset.inf'` equaling zero in a linearly ordered type with no infinitesimals, which is elementary but requires careful handling of the `inf'` API. Why now? The proof is a direct corollary of our existing `phi_nonneg` and `phi_le_crossInfo`, combined with the fact that ℝ has no positive infinitesimals — the minimum of finitely many nonneg reals is zero iff at least one is zero.

## Direction 3: Subadditivity and the Exclusion Postulate

IIT's exclusion postulate states that Φ picks out a unique "grain" of causal structure. Formally, if C has a k-partition P = {P₁, ..., Pₖ}, then Φ(C) ≤ Σᵢ Φ(C|Pᵢ) + cross-terms. The key insight is that restricting a causal system to a subset S induces a sub-system, and the global minimum cut either aligns with the partition (giving a cross-term) or cuts through some part (giving a term bounded by that part's Φ). Why now? Our `crossInfo_mono` and monotonicity infrastructure provide the inequalities needed to relate restricted and global cuts; the missing formalization is the notion of restriction `C.restrict S` and its interaction with `crossInfo`.

## Direction 4: Compositional Φ for Direct Sums

For two causal systems C₁ on n₁ nodes and C₂ on n₂ nodes, the direct sum C₁ ⊕ C₂ on n₁ + n₂ nodes (with zero cross-weights) should satisfy Φ(C₁ ⊕ C₂) = 0, since the natural bipartition has zero cross-info. More interestingly, for a "weakly coupled" direct sum with small cross-weights ε, one expects Φ(C₁ ⊕ε C₂) = O(ε). The key insight is that `phi_mono_of_weight_le` already gives Φ(C₁ ⊕ε C₂) ≤ Φ(C₁ ⊕0 C₂) + O(ε·n²), but the tight bound requires analyzing which cut achieves the minimum — if ε is small enough, the minimum cut is the natural partition. Why now? The `scale` and `mono` theorems provide the analytical tools; formalizing `directSum` on `Fin (n₁ + n₂)` using `Fin.addCases` would make this immediately accessible.

## Direction 5: Information-Theoretic Interpretation via Mutual Information

When edge weights represent conditional mutual information I(Xᵢ; Xⱼ | X_rest), the cross-info of a bipartition S measures the total information flow between S and Sᶜ. Under this interpretation, Φ becomes the minimum information bottleneck. The key insight is that mutual information satisfies submodularity, which would strengthen our monotonicity results to give a submodular Φ function on the lattice of partitions — connecting to the extensive theory of submodular optimization. Why now? Our `crossInfo` is defined abstractly enough that any interpretation of weights applies; the missing piece is formalizing the submodularity inequality crossInfo(S ∪ T) + crossInfo(S ∩ T) ≤ crossInfo(S) + crossInfo(T) and showing it holds when weights satisfy the triangle inequality.
