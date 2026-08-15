# Computational evidence — NET-24 carry-chain formalisation

All numbers below were produced with `#eval` inside Lean (same definitions as the proofs
in `Catalog/NumberTheory/CarryChainStatefulCell.lean` and
`Catalog/NumberTheory/CarryChainDepthBound.lean`), not in an external script.
Each item is also backed by a machine-checked theorem, which is what actually certifies
the general claim; the evaluations only motivated the statements.

## 1. The separating pair (base 10)

`xHi 10 = (1, 9, 9, 9, …)`, `xLo 10 = (0, 9, 9, 9, …)`, `yWit 10 = (9, 0, 0, 0, …)`
(column `0` is the least significant). The two inputs differ **only** in column `0`.

| column `i` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| `carry 10 (xHi 10) (yWit 10) i` | false | true | true | true | true | true | true | true |
| `digit 10 (xHi 10) (yWit 10) i` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `digit 10 (xLo 10) (yWit 10) i` | 9 | 9 | 9 | 9 | 9 | 9 | 9 | 9 |

Every column `i ≥ 1` differs (`0` vs `9`) although the inputs agree there. Any answer
function whose receptive field at column `i` misses column `0` must therefore be wrong at
some column — the content of `no_local_state_free_readout` and `depth_lower_bound`.

## 2. Sanity check of the stateful cell

`x = 39947`-style column stream `[7,4,9,9,9,3,0,0]`, `y = [8,5,0,0,0,4,0,0]`:

```
digits = [5, 0, 0, 0, 0, 8, 0, 0]     value x = 399947   value y = 400058
value(digits) = 800005 = 399947 + 400058,  final carry = false
```

and `(carryCell 2).run` agrees with `carry 2` on the first six columns of the base-2
witness. Certified in general by `value_digits_add` and `carryCell_correct`.

## 3. Counterexample hunt for the cocycle identity

The universal claim `c(u,v) + c(u+v mod b, w) = c(v,w) + c(u, v+w mod b)`, with
`c(u,v) = ⌊(u+v)/b⌋`, was exhaustively tested by `#eval`:

* all `1000` triples `(u,v,w) ∈ [0,10)³` for `b = 10`: **no counterexample**;
* all triples `(u,v,w) ∈ [0,b)³` for every base `2 ≤ b ≤ 21` (`≈ 34 000` cases):
  **no counterexample**.

Proved in general as `carryOf_cocycle` (both sides equal `⌊(u+v+w)/b⌋`).

## 4. Sequence note

The kill/propagate/generate signal monoid on `{kill, prop, gen}` has `3` elements and the
number of distinct maps `Bool → Bool` realised by it is `3` (the monotone ones out of
`4`): the carry monoid is the monoid of monotone self-maps of the two-element chain. This
is folklore rather than an OEIS entry, and no new integer sequence arose in this project,
so no OEIS identification is claimed.
