# Future Directions: Tropical Hodge Theory

## 1. Full Hodge Decomposition for Multi-Degree Complexes

The current work proves the key ingredients — adjunction, harmonic characterization, and orthogonality — for a single-degree weighted coboundary map d : ℝ^m → ℝ^n. The natural next step is to formalize the full three-way orthogonal decomposition for a multi-degree cochain complex:

  C^p = im(d_{p-1}) ⊕ im(δ_p) ⊕ ker(Δ_p)

where Δ_p = δ_p d_p + d_{p-1} δ_{p-1} is the full Hodge Laplacian. This requires formalizing the chain complex condition d² = 0, which enables the exact-coexact orthogonality (currently stated but not proved in full generality). The key insight is that the finite-dimensional case avoids the functional-analytic subtleties of the infinite-dimensional Hodge theorem — the decomposition follows purely from linear algebra over ℝ with positive-definite inner products.

Why now? Mathlib's `Submodule.orthogonal` and finite-dimensional inner product space theory have matured enough to support this construction. The adjunction theorem we proved is the critical ingredient that was missing.

## 2. Tropical Kirchhoff's Matrix Tree Theorem

The graph Laplacian's determinantal structure encodes the number of spanning trees via Kirchhoff's theorem: for a connected graph G with Laplacian L, the number of spanning trees equals any cofactor of L. The tropical analog replaces the determinant with the tropical permanent (minimum weight perfect matching), giving:

  trop-det(L) = min over spanning trees T of (sum of edge weights in T)

The key insight is that the tropical determinant of the Laplacian computes the minimum spanning tree weight, connecting our Laplacian formalization to tropical optimization. This would bridge spectral graph theory (our `laplacian_kernel_eq_incidence_kernel`) to tropical combinatorial optimization in a single theorem.

Why now? The quadratic form identity and kernel characterization we proved provide the spectral foundation. Formalizing the tropical determinant requires only Mathlib's `Equiv.Perm` and `Finset.sum` machinery.

## 3. Spectral Gap and Tropical Cheeger Inequality

Our `rayleigh_quotient_pos` theorem shows that non-constant functions have positive Laplacian energy. The quantitative version is the Cheeger inequality:

  λ₁ ≥ h² / (2 · max_degree)

where λ₁ is the smallest nonzero eigenvalue and h is the Cheeger constant (edge expansion). The tropical analog replaces the Cheeger constant with a tropical bottleneck quantity: the minimum over all cuts of the maximum edge weight in the cut.

The key insight is that the tropical Cheeger constant — defined via the min-max structure of the tropical semiring — gives tighter bounds than the classical version for graphs arising from tropical varieties, because the tropical metric (sup-norm) is compatible with the Laplacian energy bound we proved in `laplacian_energy_le_sup_norm`.

Why now? The energy bound theorem provides the upper-bound direction. The lower bound (Cheeger) requires formalizing graph cuts, which are well within Mathlib's combinatorial reach.

## 4. Tropical Hodge Numbers from Matroids

The Adiprasito-Huh-Katz theorem (2018) proves that the Betti numbers of matroid Chow rings form a log-concave sequence: b_k² ≥ b_{k-1} · b_{k+1}. This is equivalent to the Hard Lefschetz property for a tropical fan associated to the matroid. Our `SatisfiesHLP` predicate (from the existing HodgeDecomposition/Defs.lean) captures this property.

The key insight is that the Laplacian kernel dimension equals the Betti number β_0 (number of connected components), and this can be extended to higher Betti numbers via the multi-degree Hodge Laplacian from Direction 1. Proving log-concavity of the kernel dimensions would formalize a central case of the Adiprasito-Huh-Katz theorem.

Why now? The kernel characterization `laplacian_kernel_eq_incidence_kernel` gives β_0 = dim(ker L) = dim(ker B). Extending to higher degrees via the multi-degree complex from Direction 1 would give all Betti numbers, and log-concavity could then be attacked via the Lefschetz operator formalization.

## 5. Tropical-to-Classical Transfer via Berkovich Analytification

The deepest direction: formalize the comparison map between tropical cohomology and classical étale or singular cohomology via Berkovich analytification. For a smooth projective variety X over a non-archimedean valued field, the tropicalization map trop: X^{an} → Σ induces a map on cohomology:

  H^p(Σ, ℤ) → H^p(X^{an}, ℤ)

The key insight is that our weighted cochain complex with positive weights is exactly the combinatorial model for the tropical cohomology of the tropicalization Σ, and the adjunction/Hodge theory we developed gives the spectral sequence connecting tropical and algebraic cohomology. The transfer principle would say: if a cycle class is representable tropically (which our `cycleClass` formalization captures), then it is algebraic classically.

Why now? This is the most ambitious direction, but the foundations are in place: the weighted inner product, adjunction, and Hodge decomposition provide the tropical side. Mathlib's algebraic geometry is approaching the point where Berkovich spaces could be formalized, and our work provides the target for the comparison map.
