# Future Directions — Hodge–Laplacian Message Passing, Fourth Cycle

## Synthesis

This cycle promoted the *Hodge–Betti dimension count* of `HodgeBettiRank.lean` from a numerical
equality to two genuinely structural theorems, completing the local-to-global core of the
spectral-depth / full-Hodge-decomposition program at the operator level.

* **`HodgeThreeWayDecomposition.lean` — the strong (three-way) Hodge decomposition
  (Research Direction 2).** For a two-step cochain complex `U --e--> V --d--> W` with the chain
  condition `d ∘ e = 0`, the middle cochain space splits as a triple **orthogonal direct sum**
  `V = range d* ⊕ range e ⊕ ker Δ` (coexact ⊕ exact ⊕ harmonic). The three summands are pairwise
  orthogonal (`range_e_le_orthogonal_range_adjoint_d`, `harmonic_le_orthogonal_range_e`,
  `harmonic_le_orthogonal_range_adjoint_d`), they jointly span `V` (`hodge_three_way_span`), and
  their dimensions add to `dim V` (`hodge_three_way_finrank`). The structural engine is the Hodge
  split of the *closed* space `range e ⊔ ker Δ = ker d` (`closed_eq_exact_sup_harmonic`), built
  from the relative orthogonal complement law and the coexact identity `(ker d)ᗮ = range d*`
  (`orthogonal_ker_d_eq_range_adjoint_d`).

* **`HodgeIsomorphism.lean` — the Hodge isomorphism `harmonic ≅ cohomology`
  (Research Direction 1).** The Hodge–Betti *equidimensionality* `dim (ker Δ) = dim ker d − rank e`
  is upgraded to a canonical **linear isomorphism** `(ker d / range e) ≃ₗ ker Δ`
  (`hodgeCohomologyEquiv`): every cohomology class contains *exactly one* harmonic representative.
  This is split into existence (`harmonic_representative_exists`: every closed cochain is exact plus
  harmonic) and uniqueness (`harmonic_representative_unique`, from `harmonic_inf_exact_eq_bot`:
  harmonic ∩ exact `= 0`). The two combine, inside the ambient module `↥(ker d)`, into the
  complementarity `hodge_isCompl`, which `Submodule.quotientEquivOfIsCompl` turns into the explicit
  equivalence.

The unifying picture is now sharp: message passing is a deformation retraction onto the harmonic
core; the harmonic core *is* the cohomology — not merely equidimensional with it, but canonically
isomorphic — and the cochain space splits orthogonally into exact, coexact, and harmonic channels.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `orthogonal_ker_d_eq_range_adjoint_d` | ThreeWay | `(ker d)ᗮ = range d*` |
| `closed_eq_exact_sup_harmonic` | ThreeWay | `range e ⊔ ker Δ = ker d` |
| `hodge_three_way_span` | ThreeWay | `range d* ⊔ range e ⊔ ker Δ = ⊤` |
| `hodge_three_way_finrank` | ThreeWay | `dim range d* + dim range e + dim ker Δ = dim V` |
| `harmonic_inf_exact_eq_bot` | Isomorphism | `ker Δ ⊓ range e = ⊥` |
| `harmonic_representative_exists` | Isomorphism | every closed cochain `= e u + h`, `h` harmonic |
| `harmonic_representative_unique` | Isomorphism | one harmonic representative per class |
| `hodge_isCompl` | Isomorphism | `range e`, `ker Δ` complementary inside `ker d` |
| `hodgeCohomologyEquiv` | Isomorphism | **Hodge isomorphism** `(ker d / range e) ≃ₗ ker Δ` |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Hodge isomorphism is an isometry for the quotient norm
`hodgeCohomologyEquiv` is currently a *linear* equivalence `(ker d / range e) ≃ₗ ker Δ`. Conjecture:
it is in fact an **isometry**, i.e. the harmonic representative is the unique minimal-norm element of
its cohomology class, and `‖[x]‖ = ‖P x‖` where `P` is the orthogonal projection onto `ker Δ`.
Falsifiable: any closed cochain whose harmonic part has strictly larger norm than some other class
representative would refute it. **The key insight is** that `harmonic_representative_exists` writes
`x = e u + h` with `h ⊥ e u` (because `harmonic_le_orthogonal_range_e` gives `h ⊥ range e`), so
Pythagoras yields `‖x‖² = ‖e u‖² + ‖h‖² ≥ ‖h‖²` with equality iff `e u = 0`; hence the harmonic
representative is the norm-minimizer and the class norm equals `‖h‖`. **Why now?** Both halves are
theorems already: `harmonic_inf_exact_eq_bot` for uniqueness of the minimizer and
`harmonic_le_orthogonal_range_e` for the orthogonality that powers Pythagoras, so only the quotient
`Submodule.norm_mk`/`norm_quotient` comparison remains.

### 2. The harmonic projector as an idempotent on the cochain space
The three-way split `hodge_three_way_span` + `hodge_three_way_finrank` makes `ker Δ` an orthogonal
direct summand of `V`. Conjecture: the orthogonal projection `P : V →ₗ V` onto `ker Δ` satisfies
`P ∘ P = P`, `range P = ker Δ`, `ker P = range d* ⊔ range e`, and `P` commutes with `Δ`
(`P ∘ Δ = Δ ∘ P = 0`). Falsifiable by exhibiting a cochain `x` with `P (P x) ≠ P x` or
`P (Δ x) ≠ 0`. **The key insight is** that `closed_eq_exact_sup_harmonic` together with
`harmonic_le_orthogonal_range_e` identifies `ker Δ` as the orthogonal complement of
`range d* ⊔ range e` inside `V`, so `P = Submodule.orthogonalProjection (ker Δ)` and the idempotency
plus kernel description follow from `Submodule.orthogonalProjection` API on the proven decomposition.
**Why now?** `hodge_three_way_span` gives the spanning and `harmonic_le_orthogonal_range_adjoint_d`
/ `harmonic_le_orthogonal_range_e` give that the complement is exactly the other two summands, so the
projector is pinned down with no new geometry.

### 3. Euler characteristic as a telescoping alternating sum of harmonic dimensions
For a finite cochain complex `0 → V₀ → V₁ → … → Vₙ → 0`, conjecture the discrete **Hodge–Euler
theorem**: `Σ (−1)ᵏ dim(ker Δₖ) = Σ (−1)ᵏ dim Vₖ`, identifying the analytic Euler characteristic
(alternating sum of Betti numbers) with the combinatorial one. Falsifiable by any finite complex whose
harmonic Euler sum differs from its space Euler sum. **The key insight is** that the per-degree
identity `dim(ker Δₖ) = dim ker dₖ − rank eₖ` (a direct corollary of `hodge_betti`) combined with
rank–nullity `rank dₖ + dim ker dₖ = dim Vₖ` makes the consecutive `rank` terms cancel in pairs once
summed with alternating signs (the boundary identification `eₖ = dₖ₊₁` shares each rank between two
degrees). **Why now?** `hodge_betti` supplies every per-degree input, so the global statement is a
finite alternating-sum induction over `Finset.range n` using only `Module.finrank` arithmetic already
in Mathlib — no further analysis.

### 4. Message passing converges to the harmonic projector at the spectral-gap rate
Conjecture: for an admissible step `0 < α < 2/λ_max` the iterate `(id − αΔ)^[k]` converges to the
projector `P` of Direction 2, with `‖(id − αΔ)^[k] x − P x‖ ≤ ρᵏ ‖x − P x‖` for
`ρ = max|1 − αλ|` over nonzero Hodge eigenvalues `λ`. Falsifiable by a complex with an eigenvalue
outside `(0, 2/α)` that fails to contract. **The key insight is** that the three-way decomposition
(Direction 2) makes `ker Δ` and its complement simultaneously `Δ`-invariant; on the harmonic block
`Δ = 0` so the iterate is fixed, while on the complement the self-adjoint `Δ` (it is symmetric by the
`hodgeLap_quadform` energy split) has strictly positive eigenvalues, giving geometric contraction
with the stated `ρ`. **Why now?** With `P` available from Direction 2 and the finite-dimensional
spectral theorem for the symmetric `Δ`, the limit assembles from `id = P + (id − P)`, and the tight
logarithmic clock `hodgeDepth_tight` (previous cycle) already pins the exact rate.

### 5. Functoriality: chain maps induce maps on harmonic spaces
Conjecture: a morphism of two-step complexes (a commuting ladder of linear maps between
`U --e--> V --d--> W` and `U' --e'--> V' --d'--> W'`) induces a well-defined linear map on harmonic
spaces `ker Δ → ker Δ'` that agrees, under `hodgeCohomologyEquiv`, with the induced map on cohomology.
Falsifiable by a chain map whose harmonic-space map fails to commute with the cohomology map through
the isomorphism. **The key insight is** that `hodgeCohomologyEquiv` is *canonical* (built from
orthogonal complementation, not a choice of basis), so naturality reduces to checking that the middle
map sends closed cochains to closed cochains and exact to exact — exactly the two squares of the
ladder — after which `Submodule.mapQ` provides the induced cohomology map and the equivalence
transports it. **Why now?** The isomorphism is now a concrete `LinearEquiv` rather than a dimension
count, so `LinearMap.mapQ`/`Submodule.mapQ` can be composed with it directly, making functoriality a
diagram chase over already-proven complementarity rather than a fresh construction.
