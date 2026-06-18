# Future Directions: Nonarchimedean Geometry of the Berggren Tree

## Synthesis

This cycle built a genuine **ultrametric bridge** between three previously disconnected
catalog regions: the Berggren/Pythagorean combinatorics in
`Catalog/Cryptography/BerggrenLatticeReduction.lean`, the abstract ultrametric machinery
that `Catalog/Bridges/CategoricalTropicalUltrametric.lean` motivates, and Mathlib's
`IsUltrametricDist` / `MetricSpace` typeclasses.

The deliverable file `Catalog/Bridges/BerggrenUltrametric.lean` proves that the
longest-common-prefix length `lcpLength` of Berggren addresses is a nonarchimedean
valuation: the distance `d(u,v) = 2^(-lcpLength u v)` (with `d(w,w)=0`) is a true
ultrametric, packaged as `instance : MetricSpace BWord` together with
`instance : IsUltrametricDist BWord`. Because evaluation from the root is injective
(`evalAtRoot_injective`, reused from the catalog), the metric transfers verbatim to the
subtype `ReachTriple` of reachable primitive Pythagorean triples, with `evalAtRoot`
realized as an isometry (`embed_isometry`). The "ancestor cylinders are balls" picture is
captured exactly by `wdist_le_iff`, and "shared ancestry shrinks distance" by the
nonexpansion theorem `wdist_append_left_le`.

## Results Summary

- `lcpLength_ultra` — the combinatorial heart `min(lcp u v, lcp v w) ≤ lcp u w`.
- `lcpLength_append_left` — depth is additive under a shared prefix: `lcp(p++u, p++v) = |p| + lcp(u,v)`.
- `wdist_strong_triangle`, `instance : IsUltrametricDist BWord` — the strong triangle law.
- `instance : MetricSpace BWord`, `instance : MetricSpace ReachTriple` — full Mathlib metric structures.
- `wdist_le_iff` — closed balls of radius `2^(-n)` are exactly cylinders of depth-`n` shared prefix.
- `wdist_append_left_le`, `wdist_append_left_ball` — left-concatenation is nonexpanding.
- `embed_isometry` — evaluation is an isometry onto reachable primitive triples.

All main results compile with `sorry = 0` and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Falsifiable Research Directions

### 1. The reachable-triple metric space is totally disconnected and not complete.

Conjecture: `(ReachTriple, dist)` is totally disconnected (every ball is clopen, as forced
by `IsUltrametricDist`), yet **not** Cauchy-complete — there exist Cauchy sequences of
addresses with no limiting reachable triple, because an infinite descending address has no
finite evaluation. The key insight is that the inverse-limit completion of the address
space (compatible families of finite prefixes) adds genuinely new "boundary" points that
are *infinite Berggren paths*, none of which are images of finite words. Why now: the
`NatInverseLimit` infrastructure in `Catalog/Computation/MegaSphere/Defs.lean` already
provides the exact universal-property tooling to build this completion as
`NatInverseLimit (fun n => prefixes of length n)`, so completeness can be both stated and
refuted formally rather than hand-waved. This is falsifiable: if every Cauchy address
sequence did converge in `ReachTriple`, the completion would be redundant and the
conjecture is wrong.

### 2. Evaluation is bi-Lipschitz between the word ultrametric and the geometric L∞ metric.

Conjecture: there are constants relating `wdist u v` to the catalog's `geoDist` on triples,
i.e. `geoDist` and `2^(-lcpLength)` induce the *same topology* (and the comparison is
one-sided Lipschitz: deeper shared prefix forces larger hypotenuse, hence the map from the
ultrametric to the additive geometric scale is controlled). The key insight is that
`height_lower_bound_root` already gives `5 + |w| ≤ tripleHeight (evalAtRoot w)`, so common
prefix depth `n` forces both triples to agree up to height `≈ 2^Θ(n)` — converting a
nonarchimedean radius into an archimedean one. Why now: every ingredient
(`height_ge_lcp_plus_five`, `geoDist_ge_hyp_diff`, `lcpLength_append_left`) is already
proven in the catalog, so the comparison reduces to arithmetic glue. Falsifiable: if the
hypotenuse could grow only polynomially (not exponentially) in tree depth, the bi-Lipschitz
equivalence with `2^(-n)` would fail.

### 3. The three Berggren generators act as strict contractions, giving a self-similar IFS.

Conjecture: each left-multiplication map `u ↦ g :: u` is a contraction with ratio exactly
`1/2` on `(BWord, wdist)` off the diagonal, so the Berggren tree is the attractor of an
*iterated function system* of three similarities, and the whole space is self-similar with
Hausdorff dimension `log 3 / log 2`. The key insight is that `wdist (g::u) (g::v) =
(1/2)·wdist u v` whenever `u ≠ v` — an exact (not merely bounded) scaling that upgrades the
nonexpansion theorem `wdist_append_left_le` to a strict similarity. Why now: the
single-letter case of `lcpLength_append_left` (with `|p| = 1`) makes this a one-line
corollary to state, and Mathlib's `IsUltrametricDist`/`PseudoMetricSpace` API supports
formalizing contraction ratios directly. Falsifiable: measure the ratio on the pair
`u=[A], v=[B]`; if it is not exactly `1/2`, the IFS-similarity claim is false.

### 4. Prefix balls form a basis realizing the address space as a profinite (Cantor) space.

Conjecture: the collection of cylinder balls `{ v | n ≤ lcpLength w v }` (from
`wdist_le_iff`) is a clopen basis under which the space of *infinite* Berggren addresses is
homeomorphic to the Cantor set `{A,B,C}^ℕ`, i.e. a profinite space, and the finite-word
metric space embeds densely. The key insight is that `wdist_le_iff` already proves balls are
prefix cylinders, and prefix cylinders are simultaneously open and closed — the defining
feature of profinite topology. Why now: `wdist_le_iff` plus `IsUltrametricDist`'s automatic
`isClosed_closedBall`/`isClopen` lemmas in Mathlib hand us clopenness for free, and
`NatInverseLimit` supplies the profinite limit object. Falsifiable: if two distinct infinite
addresses had `lcpLength → ∞` (distance `0` but unequal), separation would fail and the
homeomorphism with Cantor space would be impossible.

### 5. The valuation extends to a nonarchimedean absolute value compatible with the Lorentz form.

Conjecture: the depth valuation `v(t) := lcpLength (address t) (address of a fixed base
ray)` interacts with the Lorentzian quadratic form `lorentzForm` (from
`Catalog/Algebra/BerggrenLorentz/Core.lean`) so that generator action shifts valuation by a
fixed amount while preserving `Q = a²+b²-c² = 0`. The key insight is that the Berggren
generators live in `O(2,1;ℤ)` and act freely on the light cone, so the orbit structure that
defines tree depth is *intertwined* with the isometries of the Lorentz form — a discrete
nonarchimedean analogue of a Lorentz-equivariant height. Why now: the Lorentz-invariance
theorems for `matA/matB/matC` are already in the catalog's `BerggrenLorentz/Core.lean`, and
this cycle supplies the matching valuation, so the only new content is the equivariance
bookkeeping. Falsifiable: if some generator changed the valuation by a non-constant amount
depending on the triple, no Lorentz-equivariant height could exist.
