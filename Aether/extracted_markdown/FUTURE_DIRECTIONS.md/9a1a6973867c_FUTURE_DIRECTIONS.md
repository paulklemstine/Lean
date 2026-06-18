# Future Directions — General Fenchel–Moreau Theory

## Synthesis of findings

The catalog previously treated Legendre–Fenchel duality as a collection of *closed-form
computations* anchored on the quadratic seed `f(x) = x²/2`
(`Catalog/Tropical/LegendreDuality.lean`: `legendre_half_sq`,
`legendre_biconjugate_half_sq`, `fenchel_young_quadratic`). The companion EML stream
(`Catalog/EML/GaloisDuality.lean`, `Catalog/EML/ClosureOperator.lean`) developed an
abstract closure-operator / Galois-connection language but never connected it to convex
conjugation.

The new module `Catalog/Tropical/FenchelMoreau.lean` builds the bridge. It promotes the
quadratic-only results to **arbitrary** `f : ℝ → ℝ` (threading a single honest
`BddAbove` hypothesis, which `legendre_quad_bddAbove` discharges in the seed case), and
isolates the structural core:

* `fenchel_young` — the general Fenchel–Young inequality `x·y ≤ f x + f★ y`;
* `legendreTransform_antitone` — the conjugate is order-reversing;
* `biconjugate_le_self` — the general biconjugate inequality `f★★ ≤ f` (the precise
  "natural next step" flagged in the prior cycle, now proven for *all* `f`, not just `x²/2`);
* `legendreTransform_convexOn` — **every conjugate is convex**, exhibiting `f ↦ f★★` as
  the convex-envelope closure operator;
* `convexOn_of_biconjugate_eq` — Fenchel–Moreau necessity: biconjugate fixed points must
  be convex.

Together these recast `f ↦ f★★` as a *closure operator* (`≤`-extensive from below,
order-bearing per transform, idempotent on convex closed elements), unifying the
Legendre and Galois-closure domains of the catalog.

## Results summary

| Theorem | Statement | Generalizes |
|---|---|---|
| `fenchel_young` | `x·y ≤ f x + f★ y` | `fenchel_young_quadratic` |
| `legendreTransform_antitone` | `f ≤ g ⟹ g★ ≤ f★` | (new) |
| `biconjugate_le_self` | `f★★ x ≤ f x` | `legendre_biconjugate_half_sq` (≤ half) |
| `legendreTransform_convexOn` | `f★` is convex | (new, structural) |
| `convexOn_of_biconjugate_eq` | `f = f★★ ⟹ f` convex | (new) |

All are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The full Fenchel–Moreau equality `f★★ = f` for closed convex `f`
We proved `f★★ ≤ f` unconditionally and `f = f★★ ⟹ f convex`. The converse — that a
proper lower-semicontinuous convex `f` *equals* its biconjugate — is the genuine
Fenchel–Moreau theorem and remains open in this development. **The key insight is** that
the missing inequality `f x ≤ f★★ x` is precisely a supporting-hyperplane (Hahn–Banach
separation) statement: at each point one must exhibit an affine minorant of `f` that is
tight, which is exactly an element of the subdifferential `∂f(x)`. **Why now?** With the
biconjugate already realized as a closure operator here, equality reduces to proving the
operator is *idempotent onto* the convex-lsc fixed-point set — a clean, falsifiable
target: produce a convex lsc `f` and a point where `f★★ x < f x` to refute it.

### 2. Order-isomorphism between convex functions and their conjugates
Conjecture: `legendreTransform` restricts to an *involutive, order-reversing bijection*
on the lattice of closed proper convex functions. **The key insight is** that
`legendreTransform_antitone` plus `biconjugate_le_self` already give a Galois connection
`f ↦ f★` with itself; an antitone Galois connection whose round-trip is the identity on
closed elements is exactly a Galois *coinsertion*, mirroring `eml_galois_insertion_closed`.
**Why now?** The closure-operator scaffolding from `EML/GaloisDuality.lean` can be reused
verbatim once Direction 1 supplies idempotence, turning a duality slogan into a packaged
`OrderIso`.

### 3. Tropical / idempotent limit and large deviations
Conjecture: under the scaling `f_ε(x) = ε·f(x/ε)`, the conjugate `f★` is the `ε→0`
idempotent (min-plus) limit of `log∑exp`, i.e. Legendre duality is the semiclassical
shadow of Fenchel–Young duality already formalized in `Catalog/EML/FenchelYoungBridge.lean`.
**The key insight is** that the `bregmanExp`/`klBregman` nonnegativity lemmas there are
the *finite-temperature* version of `biconjugate_le_self`, with the gap collapsing to the
Legendre gap as temperature `→ 0`. **Why now?** Both endpoints are already formalized in
the catalog; only the one-parameter interpolation `Γ`-convergence statement is missing,
and it is falsifiable by exhibiting an `f` whose rescaled conjugates fail to converge.

### 4. Subdifferential calculus and equality cases
Conjecture: `f★★ x = f x` holds *iff* the subdifferential `∂f(x)` is nonempty, and the
maximizer in `f★` attains exactly there. **The key insight is** that the `csSup_le`
proofs here become `IsGreatest` statements once the supremum is attained, converting
inequalities into equalities precisely on the support set. **Why now?** Mathlib's
`HasDerivAt`/`negEntropy_deriv` machinery (already used in the catalog) supplies attainment
for smooth `f`, giving an immediate first batch of provable equality cases.

### 5. Multivariate and Hilbert-space conjugates
Conjecture: every theorem in `FenchelMoreau.lean` lifts verbatim to `f : E → ℝ` for an
inner-product space `E`, with `x·y` replaced by `⟪x, y⟫`. **The key insight is** that the
proofs use only `le_csSup`/`csSup_le` and the affine identity `a + b = 1`, none of which
touch the dimension of the domain. **Why now?** The single-variable file is a literal
template; generalization is a mechanical port that immediately makes the duality usable
for optimization and ML losses (connecting to `Catalog/MachineLearning/*`).
