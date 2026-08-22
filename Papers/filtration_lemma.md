# Computational Evidence — Clock-and-Switch Representability

All searches below were run before (and while) the Lean proofs were written.  They
concern the question:

> for which finite preorders `P` is there a **surjective bounded morphism**
> `CWorld (Fin n) (Fin m) ↠ P`, where `CWorld (Fin n) (Fin m)` is the product of an
> `n`-chain with the `m`-dimensional Boolean cube?

A bounded morphism is a monotone `f` with `f(↑x) = ↑f(x)`.  The search assigns values
to the cube in order of decreasing popcount, so when a point `S` is assigned all of its
strict supersets are already assigned and openness at `S` can be tested exactly;
monotonicity is tested against the covers.  The search is therefore **exhaustive**: a
reported failure means no bounded morphism of that dimension exists.

## 1. Exhaustive small-case verification

| points | labelled bounded posets | all representable? | cube dimension needed |
|-------:|------------------------:|:------------------:|----------------------:|
| 4      | 36                      | yes                | `m ≤ 3`               |
| 5      | 380                     | yes                | `m ≤ 4`               |

(`bounded` = has a least and a greatest element = finite + rooted + directed.)

Minimal dimensions by isomorphism class:

| poset                                   | minimal `m` |
|-----------------------------------------|------------:|
| 3-chain                                  | 2 |
| diamond `0 < a,b < 1`                    | 2 |
| 4-chain                                  | 3 |
| 5-point, three incomparable middles      | 3 |
| 5-point, other height-3 shapes           | 3 |
| 5-chain                                  | 4 |
| 6-point "bowtie" `0 < a,b < c,d < 1`     | 3 |

An explicit bowtie morphism found by the search (`0 = ⊥`, `a,b` low middles, `c,d` high
middles, `5 = ⊤`):

```
000 ↦ 0    001 ↦ c    010 ↦ a    100 ↦ b
011 ↦ c    101 ↦ c    110 ↦ d    111 ↦ ⊤
```

These data motivated, and are consistent with, the proved theorems: representability of
every finite bounded poset (`representable_of_rooted_directed`), the sharp upper bound
`m ≤ |P| - 1` (`representable_card_sub_one`), and the two lower bounds
`|P| ≤ n·2^m`, `height ≤ n + m - 1` (`representation_lower_bounds`).

## 2. Counterexample hunt: is the naive greedy walk monotone?

The representation is built from a *greedy climb* along a linear extension.  The naive
version — "when switch `i` is on and you are below `t i`, jump to `t i`, otherwise do
nothing" — is **not** monotone:

* diamond `0 < a,b < 1`, linear extension `0, a, b, 1`;
* switches `{b}` climb to `b`; switches `{a,b}` climb to `a` (the `a`-jump happens first
  and blocks the `b`-jump);
* `b ≰ a`, so adding a switch moved the value *down*.

This is why the formalised `walk` jumps to the **top** whenever the current point is not
below `t i`.  With that repair monotonicity is provable (`walk.mono`) and the linear
extension property makes it open (`walk.open_step`).

## 3. Counterexample hunt: preorders with clusters

Searching for a bounded morphism onto the two-element cluster `{p ≤ q ≤ p}` from cubes
of dimension `≤ 4` returns nothing, and the reason generalises: in a finite source poset
take a maximal preimage of `{p, q}` and push it up with the back condition.  This is the
proved theorem `BddMorphism.antisymm_image`, and it shows the literal mission statement
("every finite rooted directed *preorder*") is false; the corrected statement replaces
"preorder" by "partial order" (`representable_iff`, `not_representable_cluster`).

## 4. Refuted conjecture: `m = max(height, ⌈log₂ |P|⌉)`

The two proved lower bounds suggest the guess

> minimal switch count `= max(height(P), ⌈log₂ |P|⌉)`.

It fits every poset on `≤ 5` points and the bowtie.  A randomised search over 60 random
**6-point** bounded posets found **2 counterexamples**, e.g.

```
0 < 1, 2, 3        1 < 4        2, 3, 4 < 5
```

which has height 3 and `⌈log₂ 6⌉ = 3`, but needs `m = 4` (dimension 3 exhaustively
fails).  So the switch number is *not* a function of height and cardinality alone; some
width-like or "branching-profile" invariant is missing.  This is recorded as a live
conjecture in `FUTURE_DIRECTIONS.md`.

## 4b. Phases and clusters (no search needed)

The cluster-tolerant extension (`Catalog/Combinatorics/CWorldClusterTolerant.lean`) was
not guided by search: both directions are proved outright, and they match exactly, so
there is no gap left for experiments to probe.  Concretely, `c` phases suffice for a
finite rooted directed preorder `P` iff every cluster of `P` has at most `c` elements
(`clusterSize_eq_min_phases`), the `≤` direction being a maximal-preimage argument and
the `≥` direction the greedy climb on the antisymmetrisation `P/≈` with the phase used
to choose a point inside the reached cluster.  The smallest instance — the two-element
cluster, which needs `c = 2` and no number of switches — is itself a Lean theorem pair
(`not_representable_cluster`, `representableC_cluster`) rather than a computation.

## 5. Reproduction

The searches are ordinary exhaustive/backtracking enumerations (Python, ≈60 lines):
enumerate posets on `n` labelled points by brute force over relations with transitivity
and antisymmetry filters, keep the bounded ones, and run the assignment search described
above for `m = 1, 2, …`.  Nothing in the Lean development depends on these computations;
they only guided which statements to attempt.  The claims marked *verified* in the
project are exactly the Lean theorems, all of which compile with no `sorry` and no
`native_decide`.
