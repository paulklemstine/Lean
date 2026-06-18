# Future Directions: Impossible Geometries Where Parallel Lines Converge AND Diverge

The file `Geometry/ImpossibleParallels.lean` establishes a clean combinatorial
dichotomy: affine "parallel lines" have a rigidly constant gap
(`gap_const_of_affine`), so they can *neither* converge nor diverge, while a
single explicit oscillating pair (`impossible`) does *both* — its gap drops
below every `ε` and rises above every `M` (`impossible_geometry`) yet the lines
never meet (`gap_pos`), and indeed the gap has no limit at all
(`impossible_no_limit`). The cross-over corollary `converges_not_affine` shows
that *convergence detects curvature*. The directions below push this from a
single witness toward a structural theory.

## 1. A liminf/limsup invariant classifying parallel pairs

Define the *spread invariant* of a `ParallelPair` as the pair
`(liminf gap, limsup gap) ∈ [0,∞]²`. Euclidean parallels sit on the diagonal
`(c, c)` with `c > 0`; the `impossible` pair realizes the extreme corner
`(0, ∞)`. **Conjecture:** every point of `[0,∞]²` with first coordinate ≤ second
is realized by some parallel pair, and the diagonal `{(c,c) : c>0}` is *exactly*
the set of pairs that are asymptotically affine (bounded slope difference).
*The key insight is* that `liminf` and `limsup` of the gap are independent
deformation parameters that decouple "elliptic-like" and "hyperbolic-like"
tendencies into orthogonal axes. *Why now?* The Lean witnesses `impossible` and
`gap_const_of_affine` already pin the two extreme regimes, so the surjectivity
proof reduces to interpolating gap profiles between them — directly buildable
with `Filter.liminf`/`limsup` API now in Mathlib.

## 2. Quantitative rigidity: gaps that converge force curvature lower bounds

`converges_not_affine` is qualitative. **Conjecture:** if a `ParallelPair`
converges with rate `gap n ≤ C / n^p` along a subsequence, then the discrete
second difference of `g - f` (a discrete curvature) must have
`∑ |Δ² gap| = ∞` — i.e. fast convergence costs *unbounded* total curvature, a
discrete Gauss–Bonnet-style budget. *The key insight is* that the gap is a
telescoping sum of slope increments, so forcing it small infinitely often while
keeping it large elsewhere is exactly a total-variation lower bound on the slope
sequence. *Why now?* The catalog already contains `Geometry/DiscreteGaussBonnet.lean`
and `Geometry/Convergence.lean`; this conjecture is the natural bridge between
their curvature-budget and limit machinery and the rigidity result proved here.

## 3. Two-sided "both-meeting" geometry on the circle

Replace `ℕ` by `ZMod n` (or the discrete circle) and ask for pairs whose gap
*vanishes at two antipodal indices* (genuine intersections) yet is bounded
strictly positive between them. **Conjecture:** on `ZMod n` with `n ≥ 4` there
exist pairs meeting at exactly two points with a prescribed maximal gap in
between, and the count of such configurations is a polynomial in `n` of degree
related to the maximal gap. *The key insight is* that compactifying the index
set turns "converge AND diverge" into "meet twice", making the impossible
Euclidean picture an honest closed-curve phenomenon (elliptic geodesics meeting
twice). *Why now?* Finiteness makes the counting `Decidable`, so conjectured
polynomial formulas can be machine-checked against `#eval` for small `n` before
attempting a closed-form proof.

## 4. Spectral signature of the impossible pair

Treat `gap : ℕ → ℝ` as a signal and study the Cesàro / Abel means of the
`impossible` profile `n ↦ if Even n then n+1 else 1/(n+1)`. **Conjecture:** the
Cesàro means `(1/N)∑_{n<N} gap n` diverge like `N/4`, while the *odd-restricted*
Cesàro means converge to `0`; thus the single sequence carries two coexisting
"temperatures". *The key insight is* that parity acts as a hidden two-state
partition under which one state is hyperbolic (linear growth) and the other
elliptic (harmonic decay), so averaging mixes the two geometries linearly.
*Why now?* The explicit closed form of `impossibleGap` makes the partial sums
exactly computable (`Finset.sum` over even/odd splits), so the asymptotics are a
finite-combinatorics induction the subagent can close.

## 5. Category of parallel pairs and a deformation monoid

Equip `ParallelPair` with morphisms given by monotone reindexings `ℕ → ℕ` and a
"stacking" operation (interleaving two gap profiles). **Conjecture:** stacking
is associative with the constant-gap (Euclidean) pairs as a sub-monoid of
idempotent-like neutral elements, and the spread invariant of Direction 1 is a
*monoid homomorphism* into `([0,∞]², (min, max))`. The `impossible` pair is then
an absorbing element on the `max` axis and a generator on the `min` axis.
*The key insight is* that "convergence" and "divergence" behave like the two
lattice operations `min`/`max`, so the geometry of impossible parallels is
secretly the algebra of a tropical-style semiring. *Why now?* The catalog has a
substantial `Tropical/` library; identifying the spread invariant as a tropical
homomorphism would be a genuine cross-domain bridge (Geometry ↔ Tropical) with
the algebraic scaffolding already available to import.
