# Future Directions: The Library of Babel

The file `Computation/HammingCoding.lean` now establishes, sorry-free, the
geometric backbone of classical coding theory over an arbitrary finite alphabet
`α` indexed by a finite type `ι`:

* `hammingBall_disjoint` and `hammingBall_card_center_indep` — the disjointness
  and translation-invariance lemmas;
* `sphere_packing_bound` — the abstract Hamming bound `|C|·V ≤ qⁿ`;
* `card_fixed_support`, `hammingSphere_zero_card`, `hammingBall_zero_card` — the
  *exact* sphere and ball volumes `C(n,k)(q-1)ᵏ` and `∑_{k≤r} C(n,k)(q-1)ᵏ`;
* `weight_distribution_sum` — the binomial identity `∑_k C(n,k)(q-1)ᵏ = qⁿ`
  obtained intrinsically (the radius-`n` ball is the whole space);
* `hamming_bound_explicit` — the packing bound with the explicit volume plugged in;
* `singleton_bound` — the Singleton bound `|C| ≤ q^{n-d+1}`.

These results are the catalog foundations referenced below. The directions that
follow each *extend or combine* them rather than reproving them.

## 1. The Gilbert–Varshamov bound: from "no overlap" to "covering"

The sphere-packing bound says correcting balls cannot overlap; the
Gilbert–Varshamov (GV) bound says that a *maximal* code of minimum distance `d`
must have its radius-`(d-1)` balls *cover* the whole space, giving a matching
lower bound `|C| ≥ qⁿ / V(n, d-1)`. The exact volume `hammingBall_zero_card`
(together with its center-independent restatement
`hammingBall_card_center_indep`) is precisely the `V(n,d-1)` appearing in the
denominator.

The key insight is that maximality is a *covering* statement dual to the
*packing* statement we already proved: if some word `x` were at distance `≥ d`
from every codeword, then `C ∪ {x}` would still have minimum distance `d`,
contradicting maximality — so the radius-`(d-1)` balls around `C` cover `ι → α`,
and `|C| · V(n,d-1) ≥ qⁿ`. Formally this is a greedy/maximal-element argument
(`Finset.exists_maximal` on the poset of `d`-separated codes) glued to
`card_words`.

Why now? We have a sorry-free `hammingBall_zero_card` giving the exact ball
volume and `sphere_packing_bound` giving the dual inequality. The GV bound is the
mirror image using the same `biUnion`/`card_words` machinery, and would close the
classical packing–covering duality in one file. To our knowledge no Lean 4 / Mathlib
formalization of GV exists.

## 2. Perfect codes as equality in `sphere_packing_bound`

Define a code `C` to be `t`-*perfect* when the radius-`t` balls around its
codewords *tile* the space, i.e. equality `|C| · V(n,t) = qⁿ` holds in
`sphere_packing_bound`. The first concrete target is the binary Hamming code:
for `n = 2^r − 1`, `t = 1`, the volume is `V(n,1) = 1 + n = 2^r`, so
`2^{n−r} · 2^r = 2^n` exactly.

The key insight is that perfection is equivalent to the radius-`t` balls forming
a *partition* of `ι → α`: the `≤` in our packing proof came from
`Finset.card_le_card` on a `biUnion ⊆ univ`, and equality holds iff that
`biUnion` *is* `univ`. So "perfect" can be stated cleanly as
`C.biUnion (hammingBall · t) = Finset.univ`, and the numerical identity
`2^{2^r−1} = 2^{2^r−1−r} · (1 + (2^r−1))` is exactly the divisibility witness our
`weight_distribution_sum` style arithmetic already handles.

Why now? `weight_distribution_sum` shows our framework can carry out the binomial
arithmetic, and `sphere_packing_bound` exposes the precise inequality whose
equality case we want. Verifying `2^n = 2^{n−r}·V(n,1)` for `n = 2^r−1` is a
finite arithmetic identity, and the partition reformulation needs only the
`biUnion`/`card` lemmas already in play.

## 3. The Plotkin bound by double-counting pairwise distances

When `d > n/2` the sphere-packing bound degenerates; the Plotkin bound
`|C| ≤ 2d/(2d−n)` (binary) fills the gap. Its proof double-counts
`S = ∑_{x,y∈C} hammingDist x y`: summing over pairs gives `S ≥ |C|(|C|−1)d`,
while summing over the `n` coordinate columns gives `S ≤ n·|C|²/2` (each column
of `|C|` bits contributes at most `⌊|C|²/4⌋·2` to the total disagreement).

The key insight is that `hammingDist` is itself a sum over coordinates
(`hammingDist x y = #{i | x i ≠ y i}`), so the whole argument is a Fubini swap
`∑_{x,y} ∑_i [x i ≠ y i] = ∑_i ∑_{x,y} [x i ≠ y i]` — exactly the column/row
exchange that our coordinate-wise definitions make available, with the per-column
bound being the elementary `a·b ≤ ((a+b)/2)²` inequality on the two color classes.

Why now? Our metric layer already exposes `hammingDist` as a coordinate sum and
provides `hammingDist_triangle`/`hammingDist_comm`; the Plotkin bound needs only
this elementary double-counting, not the algebraic theory of linear or polynomial
codes. It is the natural complement to `singleton_bound` in the small-rate regime.

## 4. Metric entropy and exact covering numbers of the Library

The covering number `N(r)` is the least number of radius-`r` Hamming balls needed
to cover `ι → α`; the metric entropy is `log N(r)`. Packing (our
`sphere_packing_bound`) and covering (Direction 1) sandwich `N(r)` between
`qⁿ / V(n,2r)` and `qⁿ / V(n,r)`, and the exact volume `hammingBall_zero_card`
turns these bounds into explicit closed forms.

The key insight is that the *packing number* `P(r)` (max number of `2r+1`-separated
points) and the *covering number* `N(r)` obey `P(2r) ≤ N(r) ≤ P(r)`, and *both*
are controlled by the single quantity `V(n,·)` we computed exactly — so the
discrete metric-entropy of the Library is pinned down to a ratio of explicit
binomial sums rather than mere asymptotics.

Why now? With `hammingBall_zero_card` (exact volume) and `card_words`
(`|ι → α| = qⁿ`) in hand, the covering/packing sandwich is a direct consequence
of the union and pigeonhole lemmas already used in `sphere_packing_bound`. This
would be a novel formalized bridge from finite coding theory to the
covering-number language of approximation theory.

## 5. Kolmogorov-style incompressibility over the Hamming model

`weight_distribution_sum` and `hammingSphere_zero_card` quantify exactly how the
`qⁿ` words distribute by weight; this is the counting core of an incompressibility
argument. Defining a description-length map `ℓ : (ι → α) → ℕ` (e.g. via a prefix
encoding whose code lengths satisfy a Kraft inequality) lets one prove
`#{x | ℓ(x) < n·log q − c} ≤ qⁿ · q^{−c}`: "most words are incompressible".

The key insight is that the Kraft inequality `∑_x q^{−ℓ(x)} ≤ 1` plays exactly
the role that ball-disjointness played in `sphere_packing_bound` — a single
global budget constraint forcing a counting bound — so the incompressibility
theorem is a re-skinning of our packing argument with "balls" replaced by
"codeword-length classes".

Why now? The hard combinatorial accounting (`hammingSphere_zero_card`,
`weight_distribution_sum`) is already done, and Lean 4 handles the requisite
recursive length functions well. Connecting our exact weight enumerator to a
Kraft-based length function would give a self-contained, fully formal version of
the "most strings are random" theorem grounded in the same Hamming space.
