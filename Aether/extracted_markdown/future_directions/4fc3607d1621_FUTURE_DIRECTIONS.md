# Future Directions: Tropical Hodge Theory

This cycle completed the analytic core of Hodge theory for the weighted
two-term cochain complex `WeightedCoboundary` introduced in
`Tropical/HodgeDecomposition/Defs.lean`. On top of the catalog's
`ker_laplacianUp_eq_ker_d` we proved, in
`Tropical/HodgeDecomposition/Decomposition.lean`:

* the **Dirichlet energy identity** `⟨Δ^up v, v⟩_src = ⟨d v, d v⟩_tgt`,
* **self-adjointness** of the up-Laplacian for the weighted inner product,
* **Hodge orthogonality** `im(d) ⊥ ker(δ)`, and
* the **dual kernel theorem** `ker(Δ^down) = ker(δ)`.

Together these are exactly the ingredients that, over ℝ, force the orthogonal
splitting `ℝⁿ = im(d) ⊕ ker(δ)`. The directions below push from these local
identities toward the global decomposition theorem and its tropical shadow.

---

## Direction 1: The full orthogonal Hodge decomposition `ℝⁿ = im(d) ⊕ ker(δ)`

We proved that `im(d)` and `ker(δ)` are orthogonal under the target weighted
inner product (`image_d_perp_ker_delta`). The natural next theorem is that they
are *complementary*: every cochain `x : Fin n → ℝ` decomposes uniquely as
`x = d u + h` with `δ h = 0`, and the two summands are the weighted-orthogonal
projections of `x`. Concretely, the harmonic part is `h = x - d u` where `u`
solves the consistent normal equations `Δ^up u = δ x`.

**Falsifiable prediction.** For *every* `WeightedCoboundary m n` and every
`x : Fin n → ℝ` there exist `u` and `h` with `x = W.d.mulVec u + h`,
`W.delta.mulVec h = 0`, and `weightedIP W.tgtWeight (W.d.mulVec u) h = 0`; the
pair `(d u, h)` is unique. A single computed counterexample (a small explicit
matrix where no such splitting exists) would refute it.

**The key insight is** that orthogonality plus a dimension count already pins
the decomposition down: `dim im(d) + dim ker(δ) = n` because
`ker(δ) = (im d)^⊥` for the positive-definite weighted pairing, so the orthogonal
complement of `im(d)` is exactly the coclosed cochains we characterized.

**Why now?** The two hard halves — orthogonality and the kernel identification
`ker(Δ^down) = ker(δ)` — are already formal theorems in this file, so the
remaining step is the elementary linear-algebra fact
`im(d) ⊕ (im d)^⊥ = ℝⁿ`, for which Mathlib's `Submodule.orthogonal` and
finite-dimensional `Submodule.isCompl_orthogonal_of_completeSpace` machinery is
directly applicable.

---

## Direction 2: A spectral theorem and a Cheeger-type spectral-gap bound

`laplacianUp_self_adjoint` says `Δ^up` is symmetric for the weighted inner
product, hence (after the standard weight change of variables) orthogonally
diagonalizable with real non-negative eigenvalues — the smallest being `0` on
`ker(d)`. The conjecture is a **tropical Cheeger inequality**: the first nonzero
eigenvalue `λ₁` of the graph specialization is bounded below by `h²/(2·d_max)`,
where `h` is the weighted edge-boundary isoperimetric constant and `d_max` the
maximal weighted degree.

**Falsifiable prediction.** Over all connected weighted graphs,
`λ₁ ≥ h² / (2 d_max)`. A weighted graph violating this bound refutes it.

**The key insight is** that the Dirichlet energy identity already rewrites the
Rayleigh quotient `⟨Δ^up v, v⟩ / ⟨v, v⟩` as `⟨d v, d v⟩_tgt / ⟨v, v⟩_src`, i.e.
as a ratio of a *boundary* energy to a *bulk* mass — exactly the form on which
the Cheeger test-function argument operates.

**Why now?** With self-adjointness and the energy identity proven, the Rayleigh
characterization of `λ₁` is immediate, and Mathlib's spectral theorem for
self-adjoint operators on finite-dimensional inner-product spaces supplies the
eigenbasis without further infrastructure.

---

## Direction 3: Tropical/min-plus degeneration of the harmonic projector

The catalog's `Foundations.lean` shows the *idempotent* (min-plus) harmonic
projection converges in **one step** (`tropHarmonicProjection_idempotent`),
whereas the ℝ-linear projector of Direction 1 is reached by solving a linear
system. The conjecture is that these two are the two ends of a single
one-parameter family: scaling the weights as `w ↦ exp(w/t)` (Maslov
dequantization) deforms the ℝ-linear weighted projector into the min-plus
projector as `t → 0⁺`.

**Falsifiable prediction.** For fixed data, the `t`-rescaled linear harmonic
projection `P_t(x)` converges pointwise as `t → 0⁺` to the tropical projection
`tropHarmonicProjection x`. A family where the limit exists but differs from the
tropical projection refutes it.

**The key insight is** that the energy identity `⟨Δ^up v,v⟩ = ⟨d v, d v⟩`
becomes, under `w = exp(·/t)`, a log-sum-exp Dirichlet form whose `t → 0` limit
is the tropical (max/min) Dirichlet form — so the minimizers (harmonic
representatives) degenerate accordingly.

**Why now?** Both endpoints are now formalized in the same project (linear side
here, tropical side in `Foundations.lean`), making the degeneration a concrete,
checkable bridge rather than an analogy.

---

## Direction 4: Tropical Poincaré duality and the Hard Lefschetz property

`Defs.lean` records `SatisfiesHLP` and a tropical Hodge-star `tropicalHodgeStar`
swapping `(p,q) ↦ (q,p)`. Combining it with the kernel theorems proven here
suggests a **tropical Poincaré duality**: the Hodge star restricts to a
weight-pairing isomorphism between the harmonic space `ker(Δ^up)` in degree `p`
and the harmonic space `ker(Δ^down)` in the complementary degree, so the Betti
numbers satisfy `b_p = b_{n-p}` and, for matroidal fans, the unimodality
`SatisfiesHLP`.

**Falsifiable prediction.** For the uniform matroid `U_{2,4}` the harmonic Betti
sequence is `(1, 3, 1)`, palindromic and unimodal; any balanced matroidal fan
whose computed harmonic Betti numbers fail `b_p = b_{n-p}` refutes the duality.

**The key insight is** that `image_d_perp_ker_delta` together with
`ker_laplacianDown_eq_ker_delta` identifies the harmonic representatives in
adjoint degrees, and the Hodge star is exactly the involution intertwining the
src/tgt weighted pairings — so duality becomes the statement that this involution
preserves harmonicity.

**Why now?** The harmonic spaces in *both* degrees are now characterized as honest
kernels (`ker d` and `ker δ`), and the Hodge-star definition already exists in the
catalog, so checking that the star maps one harmonic kernel onto the other is a
finite, fully formalizable computation.
