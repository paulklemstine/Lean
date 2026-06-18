# Future Directions — Spectral Depth Thresholds for Hodge-Laplacian Message Passing

## Synthesis

`Catalog/Geometry/HodgeSpectralThreshold.lean` extracts a rigorous, sorry-free
linear-algebraic skeleton from the (informal, ML-flavoured) conjecture *"Spectral
Universality Threshold for Hypergraph Neural Tangent Kernels on Simplicial
Complexes."* One layer of linearized / infinite-width message passing on `k`-cochains
is modelled as the self-adjoint operator `T = 1 - t·Δ`, where `Δ = up + down` is the
abstract combinatorial **Hodge Laplacian** (the sum of a positive-semidefinite upper
Laplacian `δδ*` and lower Laplacian `d*d`). Depth-`L` message passing is the iterate
`Tᴸ` (`depthMap`).

Two halves of the conjecture are now theorems, and — pleasingly — *no
finite-dimensionality hypothesis is needed* on the harmonic side:

* **Topology is depth-invariant.** The harmonic subspace `ker Δ` — which by discrete
  Hodge theory is the cohomology of the complex — consists of *exact fixed points of
  `Tᴸ` at every depth* (`harmonic_depth_invariant`), is characterised intrinsically as
  `ker Δ = ker up ⊓ ker down` (`harmonic_iff`, `ker_hodgeLaplacian`), and has
  `T`-invariant orthogonal complement (`harmonic_orthogonal_invariant`). The enabling
  lemma is the Hodge vanishing principle `⟪Δx,x⟫ = 0 ⇒ Δx = 0` for symmetric PSD
  operators (`psd_inner_self_eq_zero`), proved by a one-parameter quadratic-positivity
  (semidefinite Cauchy–Schwarz) argument.
* **Everything non-harmonic is geometrically suppressed.** A mode of eigenvalue
  `λ ≥ μ > 0` (spectral gap `μ`) evolves by `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ → 0`
  (`mode_decay`, `gap_mode_tendsto_zero`), giving the explicit, spectrum-uniform depth
  threshold `L_c` of `depth_threshold`: above `L_c` every non-harmonic mode of gap
  `≥ μ` is below any tolerance `ε`, while harmonic modes stay at amplitude `1`
  (`harmonic_mode_invariant`).

This is the precise, provable shadow of the conjectured topology-sensitive →
topology-blind phase transition: depth acts as a low-pass filter on the Hodge spectrum
whose only fixed amplitudes are the topological (harmonic) ones, and the transition
scale is `L_c ≈ log ε / log(1 - tμ)`, governed *explicitly* by the spectral gap.

## Results summary

| Theorem | Statement |
|---|---|
| `psd_inner_self_eq_zero` | symmetric PSD + zero Dirichlet energy ⇒ operator kills the vector |
| `harmonic_iff` | `Δx = 0 ⇔ up x = 0 ∧ down x = 0` (harmonic = closed and coclosed) |
| `ker_hodgeLaplacian` | `ker Δ = ker up ⊓ ker down` (discrete Hodge harmonics) |
| `harmonic_depth_invariant` | `Δx = 0 ⇒ Tᴸ x = x` for all depths `L` |
| `harmonic_orthogonal_invariant` | `(ker Δ)ᗮ` is invariant under `T = 1 - t·Δ` |
| `mode_decay` | `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ` for `λ ≥ μ`, normalised step |
| `harmonic_mode_invariant` | harmonic (`λ = 0`) mode keeps amplitude `1` at all depths |
| `gap_mode_tendsto_zero` | `(1 - tμ)ᴸ → 0` as `L → ∞` |
| `depth_threshold` | explicit `L_c` suppressing all non-harmonic modes below `ε` uniformly |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Lift the scalar threshold to a uniform operator-norm contraction

We proved geometric decay *mode-by-mode*; the next step is the operator statement
`‖Tᴸ x − P_𝓗 x‖ ≤ (1 − tμ)ᴸ ‖x‖`, where `P_𝓗` is the orthogonal projection onto the
harmonic space `ker Δ`. This is exactly the convergence of depth-`L` message passing to
the harmonic projector, i.e. to cohomology.
**The key insight is** that on a finite-dimensional inner product space a symmetric `Δ`
orthogonally diagonalises, so `Tᴸ` is block-diagonal with the harmonic block equal to
the identity and the non-harmonic block of operator norm `≤ (1 − tμ)ᴸ`; the only
nontrivial Lean ingredient is that a product of commuting PSD self-adjoint operators is
PSD.
**Why now?** Mathlib's `LinearMap.IsSymmetric.eigenvectorBasis` and the
finite-dimensional spectral theorem already provide the orthonormal eigenbasis and
eigenvalue data, so the bridge from our scalar lemmas (`mode_decay`,
`gap_mode_tendsto_zero`) to the operator bound is a packaging exercise rather than new
analysis. `harmonic_orthogonal_invariant` already supplies the block decomposition at
the subspace level.

### 2. Make `L_c` a sharp two-sided threshold (lower bound on retained signal)

`depth_threshold` is the "above-threshold" half. The "below-threshold" half should
assert that for `L < L_c` a non-harmonic mode of eigenvalue `λ` with `tλ` small retains
amplitude `(1 − tλ)ᴸ ≥ 1 − Ltλ ≥ δ`, i.e. topological-vs-nonharmonic discriminability
persists, giving matching `Θ(log(1/ε)/(tμ))` upper and lower bounds on the critical
depth.
**The key insight is** that `(1 − tλ)ᴸ` is monotone in both `λ` and `L`, so a single
Bernoulli-type inequality `(1 − a)ᴸ ≥ 1 − La` converts the gap `μ` and the largest
eigenvalue `λ_max` into a genuine *interval* `[L_-, L_+]` of "transitional" depths whose
width is controlled by the spectral spread `λ_max / μ`.
**Why now?** Both bounds are elementary real-analysis facts (`one_sub_le_pow`,
`pow_le_pow_left₀`) already adjacent to what `mode_decay` and `depth_threshold` used;
pairing them closes the conjecture's "sharp threshold" clause at the eigenmode level
with no new infrastructure.

### 3. A genuine sheaf / local-to-global formulation of the harmonic obstruction

Reformulate `ker Δ = ker up ⊓ ker down` (`ker_hodgeLaplacian`) as a local-to-global
gluing statement: define a cellular cosheaf of cochains on the face poset of the
complex, with `down` the local coboundary obstruction and `up` the local boundary
obstruction; harmonic cochains are then the *global sections that are simultaneously
locally closed and locally coclosed*.
**The key insight is** that `harmonic_iff` is precisely a stalk-level reduction —
global harmonicity is detected by two independent local conditions — which is the
defining shape of a cohomological obstruction class `[Δx]` vanishing.
**Why now?** This connects directly to the catalog's
`Catalog/Geometry/HodgeTheory/Filtration.lean` (`recover_H11`, opposition), which
already reconstructs harmonic pieces from local filtration data; a discrete cosheaf
layer would unify the continuous and combinatorial Hodge stories under one roof.

### 4. Topology-blindness as a quantitative two-family indistinguishability theorem

Formalize the conjecture's *refutable* core: given two complexes `X, X'` with identical
local face-degree statistics (hence identical non-harmonic spectral law in the
universality regime) but different cohomology dimensions `b ≠ b'`, prove that for
`L > L_c` the centered iterated kernels satisfy
`‖(Tᴸ − P_𝓗)_X − (Tᴸ − P_𝓗)_{X'}‖ ≤ ε`, while for small `L` the difference is bounded
*below* by a function of `|b − b'|`.
**The key insight is** that the only depth-stable difference between the two kernels
lives in the harmonic blocks, whose ranks are `b` and `b'`; above threshold the
non-harmonic parts agree to `ε` (direction 1) and the harmonic parts are the *only*
surviving discriminant, making "topology-blindness" a precise rank-vs-tolerance
trade-off.
**Why now?** Once direction 1 supplies the operator bound and `ker_hodgeLaplacian` pins
the harmonic rank to Betti numbers, this becomes a clean inequality between two
block-diagonal operators — the first fully formal, falsifiable version of the
universality claim.

### 5. Polynomial (graph-filter) updates and the heat-kernel limit

Replace the affine layer `T = 1 − t·Δ` (`layer`) by an arbitrary polynomial filter
`p(Δ)` (the "polynomially local on `k`-faces" hypothesis) and identify the class of `p`
for which the threshold phenomenon survives, with the heat semigroup `e^{−tΔ}` as the
continuous-depth limit `(1 − (t/L)·Δ)ᴸ → e^{−tΔ}`.
**The key insight is** that the harmonic space is `ker Δ ⊆ ker(p(Δ) − p(0)·I)` for
every polynomial with `p(0) = 1`, so depth-invariance of topology (the analogue of
`harmonic_depth_invariant`) is automatic for *all* such filters, and the threshold is
governed by `sup_{λ ≥ μ} |p(λ)| < 1` — a single spectral condition on the filter.
**Why now?** Mathlib has `Polynomial.aeval` on endomorphisms and `NormedSpace.exp`;
expressing depth as filter iteration generalises every theorem in the file at once and
pinpoints exactly which architectures are topology-preserving vs topology-erasing.
