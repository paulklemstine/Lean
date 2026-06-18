# Future Directions: Fenchel–Moreau, Supporting Lines, and Tropical Duality

## Synthesis

This cycle extended the catalog's Legendre–Fenchel development
(`Catalog/Tropical/LegendreDuality.lean`, `Catalog/Tropical/FenchelMoreau.lean`),
which had established only the *inequality* `f★★ ≤ f`, into the first genuine
*equality* fragment of the **Fenchel–Moreau theorem**.

The new file `Catalog/Tropical/FenchelMoreauSupporting.lean` isolates the
geometric heart of the theorem in the **affine minorant principle**: the
biconjugate `f★★` dominates every affine function lying below `f`
(`biconjugate_ge_affine_minorant`). Sandwiching this with the catalog's
`biconjugate_le_self` yields the local Fenchel–Moreau equality
`f★★ x = f x` at any point where `f` has a *supporting line*
(`biconjugate_eq_at_supporting`). We also added a small calculus of conjugates
(constant shifts, translations) and a fully non-vacuous instance recovering the
quadratic seed's self-duality `(x²/2)★★ = x²/2` *as a corollary of the general
theorem* rather than by hand.

### Results Summary

* `conjugate_le_of_affine_minorant` — `p·t + q ≤ f` ⟹ `f★ p ≤ −q`.
* `biconjugate_ge_affine_minorant` — `f★★` dominates every affine minorant.
* `biconjugate_eq_at_supporting` — **Fenchel–Moreau, local form**: exactness at supporting lines.
* `legendreTransform_add_const`, `legendreTransform_translate` — conjugate calculus.
* `halfSq_supporting_line`, `halfSq_biconjugate_eq` — quadratic instance via the general theorem.

All main results have `sorry = 0` and depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Global Fenchel–Moreau from convexity + lower semicontinuity

We have the *local* equality at supporting points. The global theorem
(`f★★ = f` everywhere ⟺ `f` is convex and lsc) reduces, by our framework, to a
single existence statement: *every point of a proper convex lsc function admits a
supporting line*. The key insight is that our `biconjugate_eq_at_supporting`
already converts that purely geometric input into the analytic conclusion, so the
remaining work is exactly one application of the supporting-hyperplane theorem and
nothing more. **Why now?** Mathlib has `ConvexOn`, `LowerSemicontinuous`, and
`geometric_hahn_banach_point_closed`/`inner_le_nnorm` separation machinery; the
epigraph of a convex lsc function is closed and convex, so a supporting functional
exists and feeds directly into our lemma. This is falsifiable: exhibit a convex
lsc `f` and a point with no supporting line, or close the gap.

## Direction 2 — The biconjugate is the convex-lsc envelope (closure operator)

`FenchelMoreau` already shows every conjugate is convex and `f★★ ≤ f`; this cycle
shows `f★★` dominates all affine minorants. Together these say `f★★` is the
*largest convex minorant of `f` that is a sup of affine functions*. The key
insight is that `f ↦ f★★` is therefore an idempotent, extensive, order-preserving
**closure operator** whose fixed points are exactly the convex lsc functions —
making Fenchel–Moreau a Galois-connection statement rather than an analytic one.
**Why now?** The order-reversal (`legendreTransform_antitone`) and extensivity
(`biconjugate_le_self`) lemmas are already in the catalog; proving idempotence
`f★★★ = f★` (the conjugate is always closed) is a short step and would formalize
the Galois connection `(★, ★)` on functions. Falsifiable: test idempotence on a
non-convex seed such as `f(x) = -|x|`.

## Direction 3 — Infimal convolution and the additive conjugate law

Define the sup/inf-convolution `(f □ g)(x) = sInf_y {f y + g (x − y)}`. The key
insight is that conjugation turns this tropical convolution into ordinary
addition: `(f □ g)★ = f★ + g★`, the exact dual of `(f + g)★ = f★ □ g★`. Our new
`legendreTransform_translate` and `legendreTransform_add_const` are the rank-one
special cases (convolution against an affine/translated atom), so the general law
is the natural completion of the conjugate calculus. **Why now?** The proof is a
`sSup`/`sInf` interchange of exactly the kind already automated in
`legendreTransform_translate`; the bookkeeping (BddAbove/BddBelow side conditions)
matches the threading pattern proven robust this cycle. Falsifiable by a numeric
check at a single triple `(f, g, y)`.

## Direction 4 — Tropical Varadhan lemma as a biconjugate identity

Varadhan's lemma states `lim (1/n) log E[exp(n·φ)] = sup_x {φ(x) − I(x)}`, i.e. the
right-hand side is a Legendre–Fenchel pairing against the rate function `I`. The
key insight is that this is precisely a *tropical (max-plus) integral* of `φ`
against the idempotent measure `exp(−I)`, so Varadhan's limit equals
`legendreTransform` evaluated against `I` — turning a probabilistic limit theorem
into the algebraic identity this cycle has been formalizing. **Why now?** With
`legendreTransform`, the affine-minorant principle, and `CGF.rateFunction` already
present, the missing piece is a thin `IdempotentMeasure` wrapper (a `sSup`-valued
set function) plus the observation that its integral *is* `legendreTransform`.
Falsifiable: instantiate with a Gaussian `I = x²/2` and check the limit equals
`halfSq_biconjugate_eq`.

## Direction 5 — Max-plus spectral characterization of random-walk rate functions

For a max-plus walk `S_n = max(X_1,…,X_n)`, the rate function should be computable
from the **max-plus Perron–Frobenius eigenvalue** of the transition operator, and
its Legendre–Fenchel transform gives the large-deviation rate. The key insight is
that the tropical spectral radius plays the role of the cumulant generating
function, so `rateFunction = (log spectral radius)★`, unifying the project's
`Tropical/PerronFrobenius/` eigenvalue theory with this Legendre development.
**Why now?** Both halves exist in the catalog as separate formalizations; the
bridge is one definition (`spectralRadius` ↦ `legendreTransform`) plus a
monotonicity argument already mirrored by `legendreTransform_antitone`.
Falsifiable on a 2×2 max-plus matrix where both sides are finite computations.
