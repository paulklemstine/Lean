# Computational evidence — aggregate dichotomy for families of Pythagorean triples

All numbers below were produced by `#eval` inside this Lean 4 / Mathlib environment
(plain kernel evaluation, no `native_decide`).  A Pythagorean triple `(a,b,c)` with
`a² + b² = c²`, `c ≥ 0`, is identified with the Gaussian integer `z = a + bi`, whose norm
`|z|² = c²` is a perfect square.  The *unlabeled product* of a family is `∏ zᵢ` (with
hypotenuse `∏ cᵢ`); the *interleaved aggregate* is the iterated Cantor pairing of the
coordinate streams; the *positional aggregate* is `∑ zᵢ Bⁱ`.

## 1. Small-case census

| quantity | value |
|---|---|
| Gaussian integers `z ≠ 0` with `|Re z|,|Im z| ≤ 12` and square norm | `80` |
| unordered pairs from the `|·| ≤ 8` census | `1176` |
| distinct products of those pairs | `248` |
| product values arising from **≥ 2** distinct unordered pairs | `248` (i.e. *all* of them) |
| maximum collision multiplicity | `8` |

The third and fourth rows are the numerical shadow of the theorem
`Pythagorean.uprod_two_nowhere_injective`: experimentally *every* product value in the census
is attained by at least two different unordered pairs, so the product map has no injectivity
point at all.  The multiplicity `8 = 4 · 2` is the rotation orbit (`|{±1, ±i}| = 4`,
`Pythagorean.uprod_four_to_one`) combined with conjugation-type coincidences.

## 2. Fibre over the identity

Ordered pairs `(z,w)` of triples with `z · w = 1`, taken from the `|·| ≤ 3` census:

```
[((-1,0),(-1,0)), ((0,-1),(0,1)), ((0,1),(0,-1)), ((1,0),(1,0))]      -- 4 solutions
```

exactly the four pairs of mutually inverse rotations, matching the theorem
`Pythagorean.uprod_fiber_one_ncard : Set.ncard {f : Fin 2 → PTriple | uprod f = 1} = 4`, and
its general-length strengthening `Pythagorean.uprod_fiber_one_ncard_general`, which gives
`4 ^ n` for families of length `n + 1` (so `4` when `n = 1`, as observed here).

## 3. Counterexample hunt: can hypotenuse data restore rigidity?

There are exactly `36` Gaussian integers of norm `65² = 4225`, i.e. `36` Pythagorean triples
with hypotenuse `65`:

```
(±65,0), (0,±65), (±63,±16), (±16,±63), (±60,±25), (±25,±60), (±56,±33), (±33,±56),
(±52,±39), (±39,±52)
```

Among the `528` unordered pairs of *nondegenerate* (no vanishing leg) triples of hypotenuse
`65`, there are `1536` colliding pairs-of-pairs (two different unordered pairs with the same
product).  One of them is the witness formalised in `Catalog/Pythagorean/CollisionWitnesses.lean`:

```
(63 - 16i)(63 + 16i) = 4225 = (-33 + 56i)(-33 - 56i)
```

Both families consist of two nondegenerate triples of hypotenuse `65`, so they have the *same*
multiset of hypotenuses and the *same* product, yet they are different families.  This kills
the natural repair conjecture "product + hypotenuse multiset ⇒ rigidity"
(`Pythagorean.hypotenuse_data_does_not_rigidify`).

## 4. Interleaved aggregate versus product: information content

Over all `6400 = 80²` ordered length-two families from the `|·| ≤ 12` census:

| aggregate | number of distinct values |
|---|---|
| interleaved aggregate (Cantor pairing) | `6400` (injective on the sample) |
| unlabeled product | `644` |

so on this sample the product loses a factor of about `10` in resolution, while the
interleaved aggregate loses nothing — the computational counterpart of
`Pythagorean.aggregate_dichotomy`.

Concrete separation of a swap:

```
interleave ((3,4,5), (5,12,13))  = 118323616394
interleave ((5,12,13), (3,4,5))  = 24701486
product     of both families     = (-33, 56, 65)
positional aggregate, base 100   = 503 + 1204 i   versus   305 + 412 i
```

which is exactly `Pythagorean.gaggr_separates_swap`.

## 5. Sharpness probe for the positional aggregate

In base `B = 2` the balanced bound `2|·| < B` fails by exactly one unit for the digit `±1`,
and injectivity indeed breaks:

```
gaggr 2 ((1,0,1), (0,0,0))   = 1 + 0i
gaggr 2 ((-1,0,1), (1,0,1))  = -1 + 2 = 1 + 0i
```

formalised as `Pythagorean.gaggr_bound_sharp`.

## 6. OEIS

No OEIS lookup was performed (this environment is offline), so no OEIS identifiers are
claimed.  The census sequence "number of Gaussian integers with square norm and coordinates
bounded by *m*" (`80` for `m = 12`) is recorded here only as raw experimental data.
