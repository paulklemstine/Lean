# Future Directions: Tropical Spectral Theory — Eigenvalue Localization

## Synthesis

This cycle moved tropical spectral theory from the *geometry of the eigen-ray*
(established in `Catalog/Tropical/SpectralCausality.lean`, where a tropical
eigenvector is read as a causal geodesic ray and the eigenvalue as its
displacement budget) to the *arithmetic of the eigenvalue itself*. The new file
`Catalog/Tropical/SpectralBounds.lean` proves, in fully machine-checked Lean 4
and with only the bare eigenpair equation as a hypothesis, that the min-plus
eigenvalue `d` of a real matrix `A` is trapped inside the range of `A`'s entries:

> `minᵢₖ A i k  ≤  d  ≤  minᵢ A i i`.

We additionally established eigenvalue *rigidity* (a fixed eigenvector determines
a unique eigenvalue) and the *power spectral mapping theorem* (the `k`-fold
tropical power has the same eigenvector with eigenvalue `k·d`, the additive
analogue of `σ(Aᵏ) = σ(A)ᵏ`). Tightness is witnessed by the constant matrix
`A i k ≡ c`, where every vector is an eigenvector with `d = c` and both bounds
collapse to equality.

## Results Summary

- `tropEigenvalue_le_diag` / `tropEigenvalue_le_min_diag` — diagonal upper bounds.
- `tropEigenvalue_ge_min_entry` — global-entry lower bound (via the argmin of `v`).
- `tropEigenvalue_unique` — eigenvalue rigidity for a shared eigenvector.
- `tropPow_spectral_mapping` — additive spectral mapping `d ↦ k·d` for powers.

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The eigenvalue equals the minimal cycle mean (tropical Perron–Frobenius)
The localization `minᵢₖ A i k ≤ d ≤ minᵢ A i i` is the crude outer shell of the
true identity: for an irreducible matrix, the tropical eigenvalue equals the
**minimum cycle mean** `min_C (weight(C) / length(C))` over directed cycles `C` of
the weighted digraph of `A`. The key insight is that the lower-bound argument
already used here — evaluate the eigen-equation at the argmin coordinate of `v`
and watch the `v`-weights cancel — is exactly the seed of the cycle-extraction
greedy walk, so the cycle-mean formula should fall out by iterating that
selection along a closed orbit. **Why now?** We have a self-contained, axiom-clean
`tropMatVecMul`/`IsTropicalEigenpair` API and a working `tropMatPowMul` with drift
lemmas; the only missing primitive is a `Finset`-indexed cycle weight, which is a
mechanical addition rather than new theory.

### 2. Existence of an eigenpair via the Bellman–Ford / Kleene-star fixpoint
We have so far reasoned about eigenpairs *assuming they exist*. The natural next
target is an **existence theorem**: every matrix with at least one finite cycle
admits a tropical eigenpair, constructed as a column of the Kleene star
`A* = ⨅ₖ A^{⊗k}` normalized by the minimal cycle mean. The key insight is that
`eigenray_iterate_drift` already shows iterates drift linearly at rate `d`, so
subtracting the drift `k·d` should make the normalized iterates converge to a
fixed point that is automatically an eigenvector. **Why now?** The catalog already
contains `Catalog/Tropical/BellmanFord.lean`; bridging its shortest-path fixpoint
to our `IsTropicalEigenpair` predicate is a cross-file synthesis with both halves
already formalized.

### 3. Max-plus mirror and a sandwich duality theorem
Everything here is min-plus; the order-dual max-plus product
`(A ⊙ v)(i) = maxₖ (A i k + v k)` should obey the mirror bounds
`maxᵢ A i i ≤ d⁺ ≤ maxᵢₖ A i k`. The key insight is that negation
`v ↦ -v`, `A ↦ -A` is an order-reversing semiring isomorphism min-plus ↔
max-plus, so each min-plus theorem in this file transports to a max-plus theorem
*for free* once that isomorphism is formalized as a single transfer lemma.
**Why now?** Proving the transfer lemma once doubles the theorem count and yields
a falsifiable prediction (the max-plus eigenvalue is sandwiched on the *opposite*
side of the entry range), immediately testable on small explicit matrices.

### 4. Lipschitz / non-expansiveness of the tropical operator and uniqueness of `d`
`tropMatVecMul` is non-expansive in the sup-norm: `‖A⊗x − A⊗y‖∞ ≤ ‖x−y‖∞`. The
key insight is that combining non-expansiveness with the additive drift from
`eigenray_iterate_drift` should upgrade `tropEigenvalue_unique` from "unique per
fixed eigenvector" to "unique across *all* eigenvectors of an irreducible
matrix" — the genuine Perron–Frobenius uniqueness — because two different
eigenvalues would force the gap between the corresponding rays to grow linearly,
contradicting non-expansiveness. **Why now?** Non-expansiveness is a two-line
`Finset.inf'` estimate analogous to `tropMatVecMul_const_add` already proven
here, so the hard analytic input is essentially in hand.

### 5. Spectral mapping for tropical polynomials in `A`
`tropPow_spectral_mapping` covers monomials `A^{⊗k} ↦ k·d`. The key insight is
that a tropical polynomial `p(A) = ⨅ⱼ (cⱼ + A^{⊗j})` acting on the eigenvector
`v` should yield eigenvalue `minⱼ (cⱼ + j·d)`, the *tropical evaluation* of `p`
at `d`, because each monomial contributes its drift `j·d` and the outer `⨅`
selects the minimizer pointwise and uniformly in the coordinate. **Why now?**
This is the direct fusion of `tropPow_spectral_mapping` (this cycle) with the
tropical-polynomial machinery in `Catalog/Tropical/Core/TropicalPolynomials.lean`,
turning two existing components into a single functional-calculus statement.
