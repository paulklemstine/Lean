# Future Directions — Hodge–Laplacian Message Passing, Fifth Cycle

## Synthesis

This cycle did two things. First, it **repaired and re-established the foundation** of the
discrete Hodge program: the file `Speculative/AutoResearch/HodgeBettiRank.lean` — on which both
`HodgeThreeWayDecomposition.lean` and `HodgeIsomorphism.lean` depend — was absent, so the entire
Hodge stack failed to elaborate. It is now reconstructed and proven sorry-free, exporting the four
load-bearing facts of the theory: the Hodge Laplacian `Δ = d* d + e e*` (`hodgeLap`), the
image/cokernel duality `ker f* = (range f)ᗮ` (`ker_adjoint_eq_orthogonal_range`), the harmonic
characterization `ker Δ = ker d ⊓ ker e*` (`hodgeLap_ker`), the chain inclusion
`range e ≤ ker d` (`range_e_le_ker_d`), and the Hodge–Betti dimension count
`dim (ker Δ) + dim (range e) = dim (ker d)` (`hodge_betti`).

Second, building directly on that foundation and on the three-way splitting, it promoted the
*static* harmonic decomposition into the *operator and variational* statements of the fourth-cycle
program (Research Directions 1 and 2) in the new file
`Speculative/AutoResearch/HodgeHarmonicProjector.lean`:

* **Self-adjointness.** `Δ* = Δ` (`hodgeLap_isSelfAdjoint`), the algebraic backbone of the whole
  spectral picture, reduced to `adjoint_comp` + `adjoint_adjoint`.
* **Pythagoras + minimal norm (Direction 1).** A harmonic cochain is orthogonal to every exact
  cochain, so `‖h + e u‖² = ‖h‖² + ‖e u‖²` (`harmonic_exact_norm_add_sq`); consequently the
  harmonic representative is the *shortest* element of its cohomology class — `‖h‖ ≤ ‖y‖` for every
  cohomologous `y` (`harmonic_representative_norm_minimal`). This upgrades the *uniqueness* of the
  harmonic representative (`HodgeIsomorphism.harmonic_representative_unique`) to a genuine
  *variational* minimization.
* **The harmonic projector (Direction 2).** Writing `P = (ker Δ).starProjection`, the projector
  kills exact cochains (`harmonicProjection_exact_eq_zero`), is idempotent
  (`harmonicProjection_idempotent`), and on a *closed* cochain returns precisely the harmonic
  representative: `P (e u + h) = h` (`harmonicProjection_closed`). This is the operator that
  realizes the Hodge isomorphism `ker Δ ≅ ker d / range e`.

The unifying picture is now operator-theoretic: the Hodge Laplacian is self-adjoint, its kernel is
the harmonic core, the orthogonal projector onto that core *is* the cohomology projector, and the
harmonic representative it selects is the unique norm-minimizer of its class.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `ker_adjoint_eq_orthogonal_range` | HodgeBettiRank | `ker f* = (range f)ᗮ` |
| `hodgeLap_ker` | HodgeBettiRank | `ker Δ = ker d ⊓ ker e*` |
| `range_e_le_ker_d` | HodgeBettiRank | `range e ≤ ker d` |
| `hodge_betti` | HodgeBettiRank | `dim (ker Δ) + dim (range e) = dim (ker d)` |
| `hodgeLap_isSelfAdjoint` | HodgeHarmonicProjector | `Δ* = Δ` |
| `harmonic_exact_norm_add_sq` | HodgeHarmonicProjector | `‖h + e u‖² = ‖h‖² + ‖e u‖²`, `h` harmonic |
| `harmonic_representative_norm_minimal` | HodgeHarmonicProjector | `‖h‖ ≤ ‖y‖` for `y` cohomologous to harmonic `h` |
| `harmonicProjection_exact_eq_zero` | HodgeHarmonicProjector | `P (e u) = 0` |
| `harmonicProjection_idempotent` | HodgeHarmonicProjector | `P (P x) = P x` |
| `harmonicProjection_closed` | HodgeHarmonicProjector | `P (e u + h) = h` (Hodge projector) |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The harmonic projector is the full three-way idempotent splitting `id = P_coexact + P_exact + P_harmonic`
`harmonicProjection_idempotent` and `harmonicProjection_closed` establish `P = (ker Δ).starProjection`
as the harmonic projector, but only on the harmonic and exact channels. Conjecture: there is a
complete *orthogonal resolution of the identity* `id = (range d*).starProjection +
(range e).starProjection + (ker Δ).starProjection`, with the three star-projections pairwise
annihilating (`P_i ∘ P_j = 0` for `i ≠ j`). Falsifiable by any cochain `x` with `P_coexact x +
P_exact x + P_harmonic x ≠ x`. **The key insight is** that `hodge_three_way_span` (sup `= ⊤`) and
`hodge_three_way_finrank` (dimensions add to `dim V`) already certify that the three summands form an
*internal orthogonal direct sum*, so `Submodule.starProjection` on each summand, summed, must
telescope to the identity by `Submodule.starProjection_add_starProjection_orthogonal`-style API
applied twice along the nested split `V = range d* ⊕ (range e ⊕ ker Δ)`. **Why now?** The pairwise
orthogonality lemmas (`range_e_le_orthogonal_range_adjoint_d`, `harmonic_le_orthogonal_range_e`,
`harmonic_le_orthogonal_range_adjoint_d`) are all theorems, so the resolution of identity is pure
projector bookkeeping with no new geometry.

### 2. The Hodge isomorphism is a quotient isometry
`HodgeIsomorphism.hodgeCohomologyEquiv : (ker d / range e) ≃ₗ ker Δ` is currently only linear. With
`harmonic_representative_norm_minimal` now proven, conjecture it is an **isometry** for the quotient
norm: `‖[x]‖ = ‖P x‖`, i.e. the quotient norm of a cohomology class equals the norm of its harmonic
representative. Falsifiable by a class whose quotient norm differs from its harmonic representative's
norm. **The key insight is** that the quotient norm `‖[x]‖ = inf_{u} ‖x − e u‖` is, by
`harmonic_representative_norm_minimal`, attained exactly at the harmonic representative, since every
competitor `x − e u` is cohomologous to the same harmonic `h` and `‖h‖ ≤ ‖x − e u‖` with equality
when `x − e u = h`. **Why now?** The minimization half is a theorem; only the identification of the
Mathlib quotient norm `Submodule.Quotient.norm_mk_le` / `norm_quotient_le` with this infimum remains,
turning a linear equivalence into a `LinearIsometryEquiv`.

### 3. Spectral positivity: `Δ` is positive semidefinite with kernel exactly the harmonic space
Conjecture: the Hodge Laplacian satisfies `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖² ≥ 0` for all `x`, with
equality iff `x ∈ ker Δ`; consequently every eigenvalue of `Δ` is `≥ 0` and the `0`-eigenspace is
exactly `ker Δ`. Falsifiable by any `x` with `⟪Δ x, x⟫ < 0` or a nonzero harmonic eigenvalue at `0`
that is not harmonic. **The key insight is** that the same quadratic-form identity already used inside
`hodgeLap_ker` (`⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²`) is manifestly a sum of squares, so positivity is
immediate and the kernel description is the equality case — both already latent in the proof of
`hodgeLap_ker`. **Why now?** `hodgeLap_isSelfAdjoint` plus this positivity feed directly into the
finite-dimensional spectral theorem (`LinearMap.IsSymmetric.orthogonalProjection`-style API),
unlocking the eigenvalue analysis needed for message-passing convergence.

### 4. Message passing contracts onto the harmonic projector at the spectral-gap rate
Conjecture: for an admissible step `0 < α < 2/λ_max` the diffusion iterate `(id − αΔ)^[k]` converges
to the harmonic projector `P` of this cycle, with `‖(id − αΔ)^[k] x − P x‖ ≤ ρᵏ ‖x − P x‖` where
`ρ = max |1 − αλ|` over the nonzero eigenvalues `λ` of `Δ`. Falsifiable by a complex with an
eigenvalue outside `(0, 2/α)` that fails to contract. **The key insight is** that
`harmonicProjection_idempotent` + the (Direction 1) resolution of identity make `ker Δ` and its
complement simultaneously `Δ`-invariant; on the harmonic block `Δ = 0` so the iterate is fixed, while
on the complement Direction 3's strict positivity gives geometric contraction with the stated `ρ`.
**Why now?** The projector `P` is now a concrete idempotent operator and `Δ` is proven self-adjoint,
so `id = P + (id − P)` decomposes the iterate into a fixed harmonic part and a strictly contracting
complementary part with no further construction.

### 5. Functoriality of the harmonic projector under chain maps
Conjecture: a morphism of two-step complexes (a commuting ladder between `U --e--> V --d--> W` and
`U' --e'--> V' --d'--> W'`) induces a linear map `ker Δ → ker Δ'` that, via the harmonic projectors,
satisfies `P' ∘ φ = P' ∘ φ ∘ P` on closed cochains, and agrees with the induced map on cohomology
through `hodgeCohomologyEquiv`. Falsifiable by a chain map whose harmonic-space map fails to commute
with the cohomology map through the isomorphism. **The key insight is** that `harmonicProjection_closed`
identifies `P` as "extract the harmonic summand of a closed cochain," so naturality reduces to the two
squares of the ladder (closed ↦ closed, exact ↦ exact), after which `Submodule.mapQ` transports the
construction. **Why now?** With `P` a concrete idempotent and `hodgeCohomologyEquiv` a concrete
`LinearEquiv`, functoriality is a diagram chase over already-proven complementarity rather than a fresh
construction.
