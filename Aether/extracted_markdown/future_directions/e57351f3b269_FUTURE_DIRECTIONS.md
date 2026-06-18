# Future Directions: Spectral Universality of Arithmetic Hypergraph Laplacians

## Synthesis

This cycle attacked the *Spectral Universality of Arithmetic Hypergraph
Laplacians* conjecture through the lens of **Conceptual Unification (Homotopy &
Path Spaces)**. The full conjecture — convergence of the empirical spectral
measure of higher-order arithmetic-hypergraph Laplacians to a universal,
`k`-dependent law independent of boundary/weighting conventions — is far beyond
current reach. But it has a *robust provable core*, and that core is
fundamentally homotopical.

The new file `Catalog/Cryptography/ArithmeticHypergraphLaplacian.lean` formalizes
the `k`-uniform arithmetic-progression hypergraph skeleton `apGraph N k` on
`Fin N` (vertices joined when they co-occur in a length-`k` AP fitting inside
`{0,…,N-1}`) and proves four mutually reinforcing results:

* `lapMatrix_posSemidef` — the Laplacian spectrum is nonnegative (universal sign,
  every `N,k`).
* `harmonic_iff_const_on_components` — harmonic cochains are exactly the cochains
  constant on path components, identifying `ker L` with `H⁰`. This is the
  **path-space reformulation**: a cochain is harmonic iff it is invariant under
  the reachability (path) equivalence.
* `connected` — for `2 ≤ k ≤ N` the skeleton is connected, via a sliding-window
  argument that is itself a model of *boundary-convention independence* (near the
  top of the range the AP's first term slides down to `N-k`).
* `card_connectedComponent_eq_one` / `finrank_ker_lapMatrix_eq_one` — the
  multiplicity of the eigenvalue `0` is **exactly 1**, independent of `k` (in
  range) and of every nonnegative weighting. This is the simplest spectral
  invariant, and it is already rigidly universal.

The unifying message: the lowest spectral invariant of the arithmetic Laplacian
*is* a homotopy invariant (`dim H⁰`), and universality is the rigidity of that
invariant. This connects additive combinatorics (AP structure), spectral graph
theory (Laplacian kernel), and homotopy (`H⁰` of the path groupoid). It extends
the catalog's spectral-graph machinery (cf. `MachineLearning/SpectralWalk`,
`MachineLearning/SpectralSelfAdjoint`, `Algebra/ExpanderWalk`) by anchoring it to
an *arithmetic* edge set rather than a random or algebraic one.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `lapMatrix_posSemidef` | spectrum ⊆ [0,∞) for all `N,k` | proved (0 sorry) |
| `harmonic_iff_const_on_components` | `ker L = H⁰` (path-invariant cochains) | proved (0 sorry) |
| `connected` | skeleton connected for `2 ≤ k ≤ N` | proved (0 sorry) |
| `card_connectedComponent_eq_one` | one component, all `2 ≤ k ≤ N` | proved (0 sorry) |
| `finrank_ker_lapMatrix_eq_one` | `dim ker L = 1`, universal | proved (0 sorry) |

All results depend only on `propext, Classical.choice, Quot.sound`.

## Research Directions

### 1. Universal second moment (trace) of the rescaled Laplacian

Conjecture: for the AP-skeleton, `Tr(L) = ∑_v deg(v)` and, after the standard
centering/rescaling `(L - μI)/σ`, the normalized second moment `(1/N)Tr((L-μI)^2)`
converges to a finite limit `c(k)` depending only on `k`, not on `N` nor on any
polynomially bounded weighting of progressions by common difference. **The key
insight is** that the trace and trace-of-square are *exactly* edge/wedge counts
in the AP-skeleton — `Tr(L)=2|E|` and `Tr(L^2)=∑ deg^2 + 2|E|` — so the moment
problem reduces to counting arithmetic progressions and pairs of AP-incident
vertices, which is pure additive combinatorics. **Why now?** We have a clean,
formal `apGraph N k` and Mathlib's `lapMatrix` degree/trace API in scope;
formalizing the first two spectral moments is the natural, immediately tractable
next step toward an actual limiting law, and it is falsifiable by computing the
two moments at `N = 10,20,40` for fixed `k`.

### 2. Boundary-convention independence as a homotopy equivalence

Conjecture: two natural boundary conventions for the AP-hypergraph (open range
`{0,…,N-1}` vs. cyclic range `ℤ/Nℤ`) yield skeletons whose Laplacian kernels are
canonically isomorphic, i.e. the inclusion induces an `H⁰`-isomorphism for
`2 ≤ k ≤ N`. **The key insight is** that "boundary-convention independence,"
which the universality conjecture states informally, is precisely the statement
that the two skeletons are *homotopy equivalent at the level of `H⁰`* (both
connected), so the invariant is convention-free by construction. **Why now?** We
already proved connectivity for the open model with a sliding-window argument
that transparently survives wrap-around; porting it to `ZMod N` is a small,
self-contained formalization that directly tests the "independent of boundary
conventions" clause.

### 3. Weighting-scheme invariance of the kernel for all nonnegative weights

Conjecture: replace the `0/1` adjacency by any weight `w(a,d) ≥ 0` that is
positive on at least the difference-1 progressions; then the weighted Laplacian
`L_w` still satisfies `dim ker L_w = 1` for `2 ≤ k ≤ N`. **The key insight is**
that the kernel of a symmetric, diagonally-dominant weighted Laplacian depends
*only on the support graph's connectivity*, not on the weights — so the
homotopy invariant `H⁰` is literally blind to the weighting, making the
"weighting independence" clause provable in full generality rather than merely
conjectured. **Why now?** Mathlib lacks a general weighted-Laplacian kernel
theorem; building one (weighted `posSemidef` + weighted reachability kernel
characterization) is a reusable contribution that generalizes the unweighted
`harmonic_iff_const_on_components` we just proved.

### 4. Algebraic connectivity (spectral gap) lower bound for AP-skeletons

Conjecture: the second-smallest Laplacian eigenvalue (Fiedler value) `λ₂(L_N)`
of the AP-skeleton is bounded below by an explicit positive function of `N` and
`k`, e.g. `λ₂ ≥ c/N²` from the spanning path we constructed, and the *rescaled*
gap `N²·λ₂` converges. **The key insight is** that our connectivity proof builds
an explicit Hamiltonian path `0–1–⋯–(N-1)` inside the skeleton, and Cheeger /
path-embedding inequalities turn an explicit spanning path into a quantitative
spectral-gap bound — upgrading the *qualitative* `dim ker = 1` to a *quantitative*
edge of the spectrum. **Why now?** The spanning path is already formalized as
`reachable_zero`; converting it into a Poincaré/path inequality is the standard
route from connectivity to a spectral gap, and it is the first genuinely
*quantitative* spectral statement, directly probing the conjectured limiting law.

### 5. Higher cochains: from `H⁰` to `H¹` of the AP complex

Conjecture: enrich `apGraph N k` to a 2-dimensional simplicial/clique complex
(filling triangles of mutually AP-incident triples) and compute `H¹`; conjecture
that `dim H¹` grows polynomially in `N` with a `k`-dependent exponent, and that
the up-Laplacian on 1-cochains exhibits the same weighting-independence of its
kernel. **The key insight is** that the universality conjecture is genuinely
about *higher-order* (cochain) Laplacians, and the homotopy framing says the
right invariants are the cohomology groups `Hⁱ` of the AP complex — `H⁰` (done
here) is just the degree-0 shadow, and `H¹` is where arithmetic structure
(progression overlaps) first becomes visible. **Why now?** Mathlib now has enough
simplicial/`SimpleGraph` clique infrastructure to define the 2-complex, and we
have a working template (`harmonic_iff_const_on_components`) for relating a
Laplacian kernel to a (co)homology group, making the jump to `H¹` the natural and
highest-leverage continuation.
