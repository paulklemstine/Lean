# Computational Evidence

All numbers below were obtained by `#eval` on the Lean definitions in
`Catalog/Novelty/` (`shuf`, `unsh`, `deconc`, `deconcShufProd`) before the
corresponding general theorems were proved.

**Honest caveat.** `shuf` and `unsh` are defined by well-founded recursion, so
`decide` does *not* kernel-reduce goals about them; the evaluations below are
*exploratory* only and are **not** machine-verified. The verified artifacts of
this project are the general theorems in the `.lean` files, all of which are
sorry-free.

## 1. Shuffle product of words

| input | `shuf u v` |
|---|---|
| `u = [1,2]`, `v = [3]` | `{[1,2,3], [1,3,2], [3,1,2]}` |
| `u = [1,1]`, `v = [1]` | `{[1,1,1], [1,1,1], [1,1,1]}` (multiplicity 3) |
| `u = [1,2]`, `v = [3,4]` | 6 words |

Cardinalities `(shuf u v).card` match `C(|u|+|v|, |u|)`, which is the content of
`FreeMonoidShuffle.shuf_card`.

## 2. A sequence: central binomial coefficients

`[(shuf (replicate k a) (replicate k b)).card | k = 0..4] = [1, 2, 6, 20, 70]`.

This is OEIS **A000984** (central binomial coefficients `C(2k,k)`), as forced by
`shuf_card`.

## 3. Unshuffle coproduct

* `unsh [1,2] = {([1,2],[]), ([1],[2]), ([2],[1]), ([],[1,2])}`
* `(unsh [1,2,3]).card = 8`, consistent with `unsh_card : (unsh w).card = 2^|w|`.

## 4. Shuffle / unshuffle duality

`count [1,1,1] (shuf [1] [1,1]) = 3 = count ([1],[1,1]) (unsh [1,1,1])`.

More such spot-checks all agreed; the general statement is
`count_shuf_eq_count_unsh`.

## 5. Counterexample hunt for the shuffle bialgebra axiom

The claim tested was `(shuf u v).bind deconc = deconcShufProd u v`
(deconcatenation is a morphism for the shuffle product). `#eval` returned `true`
for every pair `u = a^i`, `v = b^j` with `i, j < 3`, and for `u = v = [0,1]`.
**No counterexample was found**, and the statement is now proved as
`DeconcatenationShuffle.deconc_bind_shuf`.

## 6. Hankel determinants of `[1/(m+n)!]`

`det [1/(i+j)!]_{0 ≤ i,j ≤ N}` for `N = 0..4`:

```
1,  -1/2,  -1/144,  1/1036800,  1/1463132160000
```

All nonzero, i.e. the Hankel matrix of the exponential shuffle character has
infinite rank — the numerical shadow of
`ShuffleCharacterNotRational.factorial_relation_vanishes`, which is what powers
`not_isRepresentative_expPlane`.

## 7. Where the evidence pointed

The only conjecture that the evidence *killed* was the naive guess that
representative functions are closed under all the coproducts considered in the
paper in a "grading-preserving" way: the exponential shuffle character
`w ↦ 1/|w|!`-type series is a genuine shuffle character but is not rational, so
shuffle characters and rational series are transverse notions. This became the
separation theorem in `ShuffleCharacterNotRational.lean`.
