# Computational Evidence — GL(10,2)-orbits of Boolean cubic forms

## Setup

* Boolean cubic forms in `n` variables = the Reed–Muller layer `RM(3,n)/RM(2,n)`, a
  `GL(n,2)`-invariant sub-quotient of dimension `C(n,3)`.
* For `n = 10`: dimension `C(10,3) = 120`, so there are `2^120` cubic forms, hence
  `2^120 − 1` **nonzero** forms.
* The published classification value: number of nonzero orbits `N = 3 691 560`.

## Key numbers (computed exactly)

| quantity | value |
|---|---|
| `C(10,3)` | `120` |
| total cubic forms `2^120` | `1329227995784915872903807060280344576` |
| nonzero forms `2^120 − 1` | `1329227995784915872903807060280344575` |
| `\|GL(10,2)\| = ∏_{i<10}(2^10 − 2^i)` | `366440137299948128422802227200` |
| bit-length of `\|GL(10,2)\|` | `99` |
| published `N` | `3691560` |
| `N · \|GL(10,2)\|` | `1352735753250996512960479789842432000` |

## Orbit–stabilizer consistency check

Every orbit has size at most `|G|` (orbit–stabilizer), and the orbits partition the
`2^120 − 1` nonzero forms. Hence a **necessary** condition on any valid orbit count `N` is

```
N · |GL(10,2)|  ≥  2^120 − 1.
```

Check:
```
N · |GL(10,2)| = 1352735753250996512960479789842432000
2^120 − 1      = 1329227995784915872903807060280344575
                 ≥   ✓  (passes with margin)
```

So the published figure **clears the elementary lower bound**. Had it failed, the paper's
count would have been disproved outright.

## The forced lower bound

```
⌊(2^120 − 1) / |GL(10,2)|⌋ = 3 627 408
⌈(2^120 − 1) / |GL(10,2)|⌉ = 3 627 409
```

So any `GL(10,2)`-set of size `2^120 − 1` has **at least `3 627 409` orbits**. The published
value `3 691 560` exceeds this forced bound by `3 691 560 − 3 627 409 = 64 151`, the surplus
being exactly the contribution of forms with nontrivial stabilizers.

## Counterexample hunt / disproof

**Conjecture (naive):** "the action on nonzero cubic forms is regular (free), so the orbit
count is exactly `(2^120 − 1)/|GL(10,2)|`."

**Disproof.** `|GL(10,2)| = ∏_{i<10}(2^10 − 2^i)` is even (the `i=0` factor `2^10 − 1` is
odd but e.g. the `i=1` factor `2^10 − 2 = 1022` is even; overall the product is divisible by
`2`). But `2^120 − 1` is **odd**. Therefore

```
|GL(10,2)| ∤ (2^120 − 1).
```

For a free action all orbits would have size `|G|`, forcing `|G| ∣ |X|` — contradiction.
Hence the action is **not** free: some nonzero cubic form is fixed by a nontrivial
invertible linear substitution, and the orbit count can never equal the naive quotient
`3 627 408`. This is proved formally as `booleanCubic10_not_free`.

## Factorisation of `N`

```
3 691 560 = 2^3 · 3 · 5 · 30763 = 120 · 30763,   with 30763 prime.
```
(Established in `BooleanCubicFormsBurnside.lean` as `orbitCount10_factorization`.)

## Verification method

All the integer facts above are verified in Lean 4 by `decide` (kernel evaluation) in
`BooleanCubicFormsOrbitBounds.lean`, and the value of `|GL(10,2)|` is obtained rigorously
from `Matrix.card_GL_field` (not merely asserted). The general orbit–stabilizer inequalities
are proved for arbitrary finite group actions.
