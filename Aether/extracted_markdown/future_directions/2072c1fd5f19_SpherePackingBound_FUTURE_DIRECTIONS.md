# Future Directions — The Sphere-Packing Bound and Beyond

The file `Tropical/SpherePackingBound.lean` establishes the classical Hamming
(sphere-packing) bound over an arbitrary finite additive-group alphabet `G`
indexed by a finite type `ι`: for any code `C ⊆ (ι → G)` of minimum Hamming
distance at least `2t + 1`,

    |C| · V(t) ≤ qⁿ,   with   V(t) = ∑_{i=0}^{t} C(n, i) (q − 1)ⁱ,

where `q = |G|`, `n = |ι|`, and `V(t)` is the exact volume of a radius-`t`
Hamming ball, which we also compute in closed form (`hammingBall_card_formula`).
This complements the *compression* side of coding theory already present in the
catalog (`QarySourceCoding.lean`: q-ary entropy, the Kraft inequality, and the
Shannon source-coding bounds) with the *error-correction* side. Both rest on the
same volume/counting principle over q-ary alphabets, so several natural research
directions open up from the shared counting infrastructure.

## Direction 1 — Perfect codes and the equality case

The packing bound is tight precisely for *perfect codes*, where the radius-`t`
balls about the codewords tile the whole space. A formal characterization
`|C| · V(t) = qⁿ ↔ (the balls cover everything)` would let us certify
the Hamming, Golay, and repetition codes as perfect, and would connect to the
disjointness lemma `hammingBall_pairwise_disjoint` we already proved.
**The key insight is** that equality in the sphere-packing bound is equivalent to
the disjoint codeword balls forming a *partition* of `(ι → G)`, i.e. the
biUnion used in `sphere_packing_bound` equalling `Finset.univ`, which converts a
metric statement into a pure cardinality identity. **Why now?** The volume
formula and the disjoint-biUnion machinery are already in place, so the
equality case is a direct strengthening rather than new theory, and it gives a
falsifiable test: any code meeting the bound must cover the space exactly.

## Direction 2 — The Singleton bound and a unified comparison

Alongside the packing bound sits the Singleton bound `|C| ≤ q^{n−d+1}` for
minimum distance `d`. Formalizing it (codewords are distinguished by any
`n − d + 1` coordinates, so the projection to those coordinates is injective)
and then proving, in the same file, when each bound dominates the other would
give a comparative theory of code-size bounds.
**The key insight is** that the Singleton bound is a *projection/injectivity*
statement while the packing bound is a *volume/disjointness* statement, and the
two can be uniformly phrased through the Hamming metric on `(ι → G)` we already
use. **Why now?** Our codewords are already plain functions `ι → G`, so the
coordinate-projection argument is immediate with `Finset.card_le_card_of_injOn`,
and a head-to-head comparison with the proven packing bound is a falsifiable,
self-contained next step.

## Direction 3 — The Gilbert–Varshamov existence counterpart

The packing bound is an *upper* bound on code size; the Gilbert–Varshamov bound
is a matching *lower* bound: a code of minimum distance `d` exists with
`|C| ≥ qⁿ / V(d−1)`, proved greedily. Formalizing existence via a maximal code
argument would bracket the optimal code size between two volumes of Hamming
balls.
**The key insight is** that a code maximal under inclusion must have every word
within distance `d − 1` of some codeword (else it could be extended), so the
balls of radius `d − 1` *cover* the space, giving `|C| · V(d−1) ≥ qⁿ` — the exact
dual of the disjoint-covering inequality behind our packing bound. **Why now?**
The same `hammingBall` volume formula supplies the right-hand side, and the
covering argument reuses `mem_hammingBall` and the biUnion bookkeeping already
written, so upper and lower bounds become two faces of one counting lemma.

## Direction 4 — Linear codes and the Hamming bound over fields

Specializing `G` to a finite field `𝔽_q` and `C` to a *linear* subspace turns
`|C|` into `q^k` for dimension `k`, and the packing bound becomes the redundancy
inequality `n − k ≥ log_q V(t)`. Proving this for `Submodule`-valued codes would
bridge the present combinatorial result with linear algebra over finite fields.
**The key insight is** that for a linear code the minimum distance equals the
minimum Hamming *weight* of a nonzero codeword, exactly the quantity counted by
`hammingWeight_count`, so the whole theory collapses onto the weight enumerator
we already analyze. **Why now?** Mathlib's finite-field and `Module`/`Submodule`
infrastructure is mature, and `hammingWeight_count` already isolates the weight
distribution, making the linear specialization a matter of substituting
`Fintype.card C = q^k` into the proven bound.

## Direction 5 — Tropicalizing the bound: a min-plus packing principle

The catalog's tropical theme suggests reading the bound in the (min, +) semiring:
taking `log_q` of `|C| · V(t) ≤ qⁿ` gives `log_q|C| + log_q V(t) ≤ n`, an
additive (tropical) inequality linking *rate* and *packing radius*. Formalizing
an asymptotic version `R(δ) ≤ 1 − H_q(δ/2)` (the tropical/entropy form of the
Hamming bound) would directly tie this file to `qaryEntropy` from
`QarySourceCoding.lean`.
**The key insight is** that the binomial volume `V(t)` is governed, to first
order, by the q-ary entropy `H_q`, so the multiplicative packing bound becomes an
additive entropy inequality — precisely the tropical/min-plus shadow of the exact
count. **Why now?** Both `qaryEntropy` and the exact `hammingBall_card_formula`
already exist in the catalog, so the only missing piece is the asymptotic
volume–entropy estimate `V(δn) ≈ q^{n H_q(δ)}`, a concrete, falsifiable analytic
lemma that would unify the compression and error-correction halves of the
project under one tropical inequality.
