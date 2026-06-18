# Future Directions — Topological Error-Correcting Codes and the Topological/Geometric Split

## Synthesis

This cycle attacked the conjecture that *smooth structure is a usable computational resource*:
that homeomorphic-but-non-diffeomorphic manifolds support error-correcting codes whose logical
content is pinned by topology while their **distance** responds to finer geometric data. Rather
than formalizing exotic 4- and 7-manifolds directly (far beyond current Mathlib), we extracted
the *invariant-theoretic skeleton* of the claim and proved it cleanly on the simplest nontrivial
homological codes — the cycle codes of graphs over `ZMod 2`, the 1-dimensional members of the
CSS/homological code family.

The file `Catalog/Speculative/AutoResearch/TopologicalCodes.lean` establishes, for the `n`-cycle
`C_n`, modelled with index type `ZMod n` (vertices ≅ edges) and boundary `(∂x) j = x j + x (j+1)`:

* `cycleBoundary_eq_zero_iff` — the cycle space is exactly `{0, 𝟙}`;
* `cycleCode_card` — the **logical dimension is `k = 1 = b₁(C_n)`**, a topological invariant
  (the harmonic-kernel/Betti number computed basis-free in the catalog's `HodgeBettiRank`);
* `allOnes_hammingNorm` — the all-ones cycle has weight `n`;
* `cycleDistance_eq` — the **code distance is `d = n`**, the girth, a refinement-sensitive
  (geometric) invariant;
* `distance_not_homological_invariant` — `C₃` and `C₄` have *equal* `k` but *unequal* `d`;
* `distance_scales_with_refinement` — edge-subdivision (`C_n → C_{2n}`) fixes `k` and doubles `d`.

This is the conjecture's dichotomy made precise and machine-checked: **`k` lives in homology;
`d` lives one level finer.** It is also the missing quantum-information layer over the catalog's
discrete-Hodge thread (`HodgeBettiRank`, `HodgeFullDecomposition`), where the harmonic sector had
been computed but never read as a code space. All proofs depend only on `propext`,
`Classical.choice`, `Quot.sound`.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `cycleBoundary_eq_zero_iff` | cycles `= {0, 𝟙}` | structural core |
| `cycleCode_card` | `#code = 2`, i.e. `k = 1` | topological invariant |
| `allOnes_hammingNorm` | `wt(𝟙) = n` | distance ingredient |
| `cycleDistance_eq` | `d = n` | geometric invariant |
| `distance_not_homological_invariant` | equal `k`, unequal `d` | headline split |
| `distance_scales_with_refinement` | `k` fixed, `d` doubles | refinement law |

## Research Directions

### 1. Surface (toric-code) homology and the rate–distance frontier in 2D

Lift the 1D cycle code to the 2D toric code: a chain complex `C₂ →∂₂ C₁ →∂₁ C₀` over `ZMod 2`
on an `m × m` torus grid, with `k = dim H₁ = 2` (two independent loops) and `d = m`. Prove the
analogue of `distance_not_homological_invariant` by comparing two cellulations of the *same*
torus with the same `H₁` but different shortest noncontractible cycles. The key insight is that
the 1D proof's "constancy forces `{0, 𝟙}`" generalizes to "homology class is fixed by
`∂₁∂₂ = 0` while the minimal representative weight is a cellulation functional" — distance is a
*minimum over a homology coset*, never a coset invariant. Why now? The 1D
kernel-characterization technique and the catalog's entrywise Hodge decomposition already give
both halves (`ker ∂₁`, `im ∂₂`); only the coset-minimization Finset argument is new, and it is
decidable on fixed grids.

### 2. Triangulation-refinement invariance of `k`, formalized as a chain homotopy

We proved `k` is *constant* under the specific refinement `C_n → C_{2n}`. Conjecture and prove
the general statement: any edge-subdivision of a finite graph induces a chain isomorphism on
`H₁` over `ZMod 2`, hence preserves `k` exactly, while multiplying every cycle's length (and
thus the distance) by the subdivision factor. The key insight is that subdivision is the
discrete shadow of triangulation refinement, and homology's refinement-invariance is precisely
the "topology-only" half of the conjecture — so the split is *forced*, not accidental. Why now?
Mathlib's `SimpleGraph` plus the cycle-space kernel description make subdivision a concrete map
on `ZMod`-indexed chain spaces; the homotopy is an explicit `ZMod 2`-linear bijection.

### 3. Spectral certification: distance from the Laplacian spectrum, not the Betti number

Define the graph Hodge Laplacian `Δ = ∂₁ᵀ∂₁` on `1`-chains and prove that its kernel dimension
equals `k` (rank–nullity, exactly the catalog `HodgeBettiRank` mechanism) while a *spectral gap*
bound lower-bounds the distance: `d ≥ f(λ_min nonzero eigenvalue)`. Then exhibit two graphs with
identical `k` but different spectral gaps witnessing different `d`. The key insight is that
"smooth-structure-sensitive spectral invariants" in the conjecture become honest Laplacian
spectra here, and the harmonic kernel (topology) and spectral gap (geometry) are computed by the
*same operator* — unifying the two invariants in one object. Why now? The catalog already has
the discrete Hodge Laplacian and its rank–nullity Betti theorem; adding an eigenvalue/distance
inequality is a self-contained linear-algebra extension over `ℝ` or `ZMod 2`.

### 4. A decidable code-equivalence checker and its incompleteness for distance

Build a computable function `codeEquiv : ChainComplex → ChainComplex → Bool` deciding equality
of logical dimension `k`, and prove it is *correct for `k`* (`decide`-backed) but *provably blind
to `d`*: there exist inputs it accepts whose distances differ (instantiate with `C₃`, `C₄`,
already separated by `distance_not_homological_invariant`). The key insight is that algorithmic
topological-equivalence testing is sound but strictly weaker than geometric-equivalence testing —
the formal analogue of "homeomorphism is decidable data, diffeomorphism is not." Why now?
Everything here is finite and `Decidable`; the catalog's constructive/algorithmic mandate is
directly served, and the falsifier (a single distance gap) is already proved.

### 5. Higher-dimensional obstruction: when does `k` *force* `d`?

Conjecture the converse boundary: characterize the chain complexes for which `d` *is* determined
by `k` (e.g. complexes whose nonzero homology classes all have the same minimal weight), and
prove the cycle codes `C_n` are the *extremal* family saturating distance for `k = 1`. Refute the
naive "distance is always free" reading by proving that for `k = 0` (acyclic complexes) the
distance is vacuously `∞`/undefined — a genuine collapse exposed by the `sInf`-over-empty-set in
`cycleDistance`. The key insight is that the split is not universal: there is a sharp dividing
line between complexes where geometry adds information and where it cannot, and locating it tells
you exactly when exotic smooth structure could matter. Why now? The `cycleDistance`
`sInf`-over-weight-set definition already exposes the empty-set (acyclic) edge case, so the
collapse direction is immediate, and the extremal characterization is a clean optimization
statement over the proved `{0, 𝟙}` kernel.
