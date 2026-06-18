# Future Directions — Tropicalized Berggren Dynamics

## Synthesis

This cycle established a *tropical / valuation shadow* of the Berggren–Lorentz dynamics
on Pythagorean triples (`Catalog/Bridges/TropicalBerggrenDepth.lean`, built on
`Algebra/BerggrenLorentz/Core.lean`). The organizing object is the **content**
`gcd3 a b c = gcd(gcd(a,b),c)`, which is the additive valuation-depth profile: for every
prime `p`, `v_p(content)` is the min-plus (tropical) aggregate of the coordinate
`p`-adic valuations (`gcd3_eq_tropical_min`).

The headline finding upgrades the original conjecture. We expected only a one-sided
monotonicity `T(B·t) ≥ F(T(t))`. In fact the content is an **exact orbit invariant**:
each generator preserves it on the nose (`gcd3_childA/B/C`), because every Berggren
generator is unimodular (integer-invertible: `invA/invB/invC` in the catalog). This is the
*valuation* conserved quantity, parallel to the *quadratic* conserved quantity
`childX_preserves_Q` (the Lorentz light-cone form). Two conserved quantities — one
quadratic, one multiplicative/valuative — coexist on the same discrete Lorentz flow.

## Results Summary

- `gcd3_childA`, `gcd3_childB`, `gcd3_childC`: exact content invariance along each branch.
- `gcd3_eq_tropical_min`: content valuation = min-plus convolution of coordinate valuations
  (the bridge from `IsPythag` data to the tropical preorder).
- `tropDepth_childA/B/C`: per-prime tropical depth is branch-invariant.
- `berggren_preserves_primitivity`: the primitive locus (`content = 1`) is closed under the
  whole monoid, in both directions.
- `content_pruning`: a search target whose content differs from a node's content is none of
  its three children, so its entire subtree is discarded — an O(1) pruning oracle.

## Conjectures for the Next Cycle

### 1. Word-level conservation and a content-graded transfer operator
We proved invariance for single generators; it should lift verbatim to arbitrary Berggren
words `wordMatrix w` acting on triples, giving a *content-graded* decomposition of the whole
orbit semigroup. **The key insight is** that unimodularity is closed under products, so the
content is a homomorphism-invariant on the entire free monoid, and the Berggren tree foliates
into content-level sheets that never mix. **Why now?** `wordMatrix` and the parity grading
`wordParity` already exist in `Core.lean`; the only missing piece is an induction over
`List (Fin 3)` reusing `gcd3_childA/B/C` as the inductive step — fully within reach this cycle.
Falsifiable: exhibit a word whose action changes the content (predicted impossible).

### 2. Quadratic–valuative independence: content does NOT determine the Q-orbit
We have two conserved quantities, `lorentzQ` (`= 0` on the light cone) and `content`.
Conjecture: on the light cone they are *independent invariants* — there exist primitive
Pythagorean triples (content 1, Q = 0) in **different** Berggren orbits, so content alone is
not a complete orbit separator. **The key insight is** that the Berggren monoid does not act
transitively on primitive triples without the standard normalization (parity / ordering of
legs), so a finer invariant beyond `(Q, content)` is required. **Why now?** The catalog already
proves the seed and its descendants are primitive; a single counterexample pair (e.g. comparing
descendants under the leg-swap symmetry `lorentzQ_swap_legs`) would settle it computationally.
Falsifiable by either a separating invariant or an explicit same-orbit witness.

### 3. Strict valuation growth for the *non-unimodular* scaling extension
Augment the three unimodular generators with a genuine non-invertible map (e.g. uniform
scaling `t ↦ k·t`, or a degenerate Lorentz projector). On this enlarged system the equality
collapses to a *strict* inequality `tropDepth p (S·t) > tropDepth p t` exactly at primes
`p ∣ k`. **The key insight is** that strict valuation growth is precisely the obstruction to
invertibility — the tropical depth measures the cokernel of the integer map, so it detects
*non-unimodularity quantitatively*. **Why now?** `gcd3_dvd_of` already gives the monotone
(`∣`) direction for any integer map; only the strictness witness at `p ∣ k` is new, and
`gcd3_eq_tropical_min` converts it directly into a `padicValNat` statement.

### 4. A tropical height/Lipschitz dictionary via `CategoricalTropicalUltrametric`
Reconstruct the content profile as an ultrametric seminorm on triples using the functorial
machinery in `Bridges/CategoricalTropicalUltrametric.lean`, and conjecture that Berggren steps
are *isometries* for this seminorm while the Euclidean hypotenuse grows geometrically
(`hypB_pythag_lower`: `5c < hypB`). **The key insight is** that the Berggren flow is
simultaneously hyperbolic in the Archimedean metric and isometric in the non-Archimedean one —
a single dynamical system witnessing both expansion and conservation. **Why now?** Both halves
already exist as catalog lemmas (`hypB_strict_growth` / `hypB_pythag_lower` for the Archimedean
side, `gcd3_childX` for the non-Archimedean side); the conjecture is to fuse them into one
quantitative product formula.

### 5. Effective pruning bound: orbit search is content-stratified and O(log c)
Combine `content_pruning` with the catalog depth bound (`iterB_hypotenuse_growth`,
`3c ≤ childB.2.2`) to conjecture a certified algorithm: deciding whether a target triple lies
in the Berggren tree below a hypotenuse threshold runs in `O(log c)` content-checked steps,
because mismatched content prunes whole subtrees before any arithmetic. **The key insight is**
that content is an O(1)-checkable *necessary* condition that is also orbit-*invariant*, so it
filters the exponential tree without traversing it. **Why now?** The pruning theorem and the
logarithmic-depth growth bounds are both already formalized; what remains is to package them
into a single `Decidable`-backed search procedure with a proven step count.
