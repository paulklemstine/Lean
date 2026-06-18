# Future Directions — Tropical Fermat's Last Theorem

This research cycle established the core dichotomy: the classical Fermat equation
`aⁿ + bⁿ = cⁿ` has no nontrivial solutions for `n ≥ 3`, while its tropical analogue
`max(n•a, n•b) = n•c` is **always** uniquely solvable (by `c = max a b`). The engine is the
monotonicity of `x ↦ n•x`, which makes it commute with `max`/`min`. We formalized the
max-plus and min-plus identities, existence, uniqueness, classification, a multivariable
(`Finset.sup'`) generalization, the tropical Fermat curve, and a faithful embedding into
Mathlib's genuine `Tropical ℝ` semiring (all in `Core.lean`, 0 sorries).

Below are bold, precise, testable conjectures for follow-up cycles.

## C1. Tropical Fermat over arbitrary scalar exponents (semimodules)
**Conjecture.** Replace the natural-number exponent `n` by a scalar `r` from an ordered
semiring acting on an ordered module `M`. Then for `r > 0`, `max (r • a) (r • b) = r • max a b`
holds and the solution `c = max a b` is unique; for `r = 0` it degenerates (every `c` works);
for `r < 0` (when defined) the identity flips to `min`. 
*Test:* formalize `r : ℝ≥0` acting on `ℝ` via `smul`, prove the trichotomy, and identify the
exact `OrderedSMul`/`PosSMulStrictMono` hypotheses that make uniqueness hold.

## C2. Tropical Fermat hypersurfaces are always nonempty and balanced
**Conjecture.** For every `n ≥ 1` and every number of variables `k ≥ 2`, the tropical
Fermat hypersurface `corner-locus of  max_i (n•xᵢ) ⊕ 0` is a nonempty, pure-dimensional,
balanced polyhedral complex whose vertex is the origin, with exactly `k+1` top-dimensional
rays/cells through it. We proved the `k = 2` skeleton (symmetry, origin vertex, diagonal
ray). *Test:* generalize `OnFermatCurve` to `k` variables via `Finset`, prove nonemptiness
and the "attained at least twice somewhere" balancing condition for all `k`.

## C3. Stable-range / quantitative gap version
**Conjecture.** Define an `ε`-approximate tropical Fermat solution by
`|max (n•a) (n•b) − n•c| ≤ ε`. Then `c` is forced into the interval
`[max a b − ε/n, max a b + ε/n]`; in particular as `n → ∞` the approximate solution set
collapses to the exact one at rate `Θ(1/n)`. *Test:* prove the two-sided bound and the
collapse rate; connect to the `TropicalEquivalenceInvariance` gap-stability results already
in the catalog.

## C4. Bridge: classical FLT ⇒ tropical degeneration is "lossy"
**Conjecture (cross-domain bridge).** The non-Archimedean valuation/tropicalization map
`val : ℝ₊ → ℝ`, `val(t) = log t`, sends classical near-solutions of `aⁿ + bⁿ = cⁿ` to exact
tropical solutions, and the *failure* of classical FLT is exactly the statement that the
fiber of `val` over a tropical solution `(a,b,max a b)` contains no genuine classical triple
for `n ≥ 3`. *Test:* formalize the valuation-degeneration square commuting up to the
"dequantization" `max(x,y) = lim_{T→0} T·log(e^{x/T}+e^{y/T})`, proving the log-sum-exp
limit (`Real.logSumExp`-style) converges to `max`, giving a rigorous classical→tropical
limit theorem.

## C5. Tropical Catalan / Beal analogue
**Conjecture.** The tropical Beal equation `max (m•a) (n•b) = k•c` with mixed exponents is
solvable for **all** `m,n,k ≥ 1` (unlike the classical Beal conjecture), and admits a clean
parametric description of its full solution set: `c` is determined as a max of the two
"rescaled" terms `(m/k)•a` and `(n/k)•b`. *Test:* state and prove over `ℝ`, classify the
solution variety, and contrast with the still-open classical Beal conjecture.
