# Future Directions — Tropicalized Berggren Lattice Reduction

This cycle formalized a *max-plus length invariant* on the Berggren semigroup acting on
primitive Pythagorean triples (`Catalog/Tropical/BerggrenReductionLength.lean`). The core
objects are the height functional `tripleHeight`, the per-generator multiplicative growth
certificates `ubConst` (`A,C ↦ 5`, `B ↦ 7`), their multiplicative word-level composition
`wordUB`, the tropicalized additive weight `tropWeight = Σ log(ubConst)`, and the bridge
bound `log (tripleHeight (evalWord w t)) ≤ tropWeight w + log (tripleHeight t)`. The new
rigidity result `tropical_collision_obstruction` turns disjointness of the certified height
intervals `[5 + |w|, 5·wordUB w]` into a non-collision certificate, complementing the exact
injectivity of `evalAtRoot` from `Cryptography/BerggrenLatticeReduction.lean` and the
fingerprint rigidity of `Cryptography/BerggrenFingerprintRigidity.lean`. The directions
below are concrete, testable, and each builds directly on a named declaration in that file.

## Direction 1 — A sharp multiplicative *lower* certificate and a two-sided tropical sandwich

We proved a multiplicative *upper* certificate (`tripleHeight_actGen_upper`) and only an
*additive* lower certificate (`tripleHeight_evalWord_lower`). Conjecture: there is a matching
multiplicative lower constant `lbConst` (e.g. `B ↦ 3`, since `2a + 2b + 3c ≥ 3c`, and `A,C ↦
1` with strictness) such that `lbConst g * tripleHeight t ≤ tripleHeight (actGen g t)` for
every good triple, and hence `wordLB w * tripleHeight t ≤ tripleHeight (evalWord w t)`. The
key insight is that the all-positive generator `B` is *uniformly expanding by a factor ≥ 3*
because its row sums never cancel, so its growth is bounded below multiplicatively, not just
additively — exactly the tropical dual of the upper certificate. Why now: the upper-bound
machinery (`hyp_actGen_le` via `nlinarith` on `(a−c)²,(b−c)²`) transfers verbatim with
reversed inequalities, so a two-sided "tropical sandwich" `tropWeightLow w ≤
log(height/height₀) ≤ tropWeight w` is immediately within reach and would pin the growth rate
of every word between two explicit max-plus linear functionals.

## Direction 2 — Letter-frequency formula for the tropical growth exponent

Because `wordUB` is multiplicative (`wordUB_append`) and `ubConst` depends only on the
letter, `tropWeight w = (#A + #C)·log 5 + (#B)·log 7`, i.e. the tropical weight is an exact
linear function of the letter-count (Parikh) vector of the word. Conjecture: the asymptotic
height growth rate `limsup (log (tripleHeight (evalAtRoot w)) / |w|)` along any infinite ray
equals `p_B · log 7 + (1 − p_B) · log 5`, where `p_B` is the asymptotic frequency of `B`. The
key insight is that the tropical weight factors through the abelianization of the free monoid
on `{A,B,C}`, so growth is governed entirely by the simplex of letter frequencies — a genuine
tropical/ergodic bridge. Why now: `tropWeight_append` already establishes the homomorphism to
`(ℝ, +)`, and the Parikh decomposition is a one-line `List.count` rewrite, so the finite-word
identity is provable immediately and the asymptotic statement becomes a clean Cesàro limit.

## Direction 3 — Quantitative collision-free zones and a counting bound

`tropical_collision_obstruction` gives a *sufficient* separation condition
`5·wordUB u < 5 + |v|`. Conjecture: combining the two-sided sandwich (Direction 1) yields a
*pigeonhole* counting theorem — the number of words of length `n` whose evaluations land in a
height window `[H, H + Δ]` is at most polynomial in `Δ` and independent of `n`, because the
admissible Parikh vectors are confined to a thin tropical slab. The key insight is that the
height interval `[wordLB w · 5, wordUB w · 5]` is determined by letter frequencies, so a fixed
height window selects a bounded-width band of frequency vectors, capping the collision
multiplicity. Why now: `finite_nearby_words` in `Cryptography/BerggrenLatticeReduction.lean`
already proves *finiteness*; the tropical certificates upgrade finiteness to an *explicit*
quantitative bound, which is the missing complexity-theoretic ingredient for the lattice-
reduction search.

## Direction 4 — Subadditivity of the true height defect vs. the tropical surrogate

Define the *tropical defect* `defect w := tropWeight w − log (tripleHeight (evalAtRoot w) / 5)
≥ 0` (nonnegativity is exactly `log_tripleHeight_evalWord_le` at the root). Conjecture: the
defect is *subadditive under concatenation up to a universal constant*, `defect (u ++ v) ≤
defect u + defect v + log 3`, with the `log 3` matching the `log 3` log-sum error already
isolated in `Tropical/BerggrenTropicalBridge.lean` (`berggren_tropical_duality_error`). The
key insight is that the gap between the exact (additive in `log`) Berggren action and its
tropical max-plus shadow accumulates only through the three-term log-sum error per step, which
is bounded by `log 3` — so the two `BerggrenTropical` files are quantitatively the *same*
phenomenon viewed from the certificate side versus the dynamics side. Why now: both the
certificate side (this file) and the dynamics side (`BerggrenTropicalBridge.lean`) now exist
in the catalog, so the cross-file bridge theorem unifying their error terms is finally stateable.

## Direction 5 — Tropical signatures as a freeness invariant for arbitrary generating sets

`evalAtRoot` is injective for the standard generators. Conjecture: for any finite set `S` of
integer Lorentz matrices each strictly expanding the hypotenuse and admitting a uniform
multiplicative certificate `ubConst : S → ℕ`, the induced `tropWeight` is a *complete word
invariant on each fixed Parikh fiber up to the collision width of Direction 3*, and in
particular distinct tropical signatures force distinct triples (a generalization of
`tropical_collision_obstruction` away from the three classical Berggren matrices). The key
insight is that injectivity of the *action* and monotonicity of the *height* are logically
independent: the tropical certificate isolates exactly the monotone part, so freeness can be
detected purely from growth signatures without solving the action. Why now: the proof of
`tropical_collision_obstruction` uses only `tripleHeight_evalAtRoot_upper/lower`, both of
which are stated abstractly enough to re-run for any certified expanding generating set,
making the generalization a parametrization rather than a new proof.
