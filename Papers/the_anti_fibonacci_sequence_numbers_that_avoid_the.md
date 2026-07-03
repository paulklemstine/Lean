# Computational Evidence — The greedy anti-Fibonacci sequence

## 1. Small-case simulation of the greedy rule

Rule: start from `1`; each new term is the **smallest positive integer that is not the sum of
two consecutive earlier terms**. Direct simulation:

```
1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 16, 17, 19, 20, 22, 23, ...
```

These are exactly the positive integers **not divisible by 3**.

The *avoided* values (the consecutive sums that get skipped) are:

```
3, 6, 9, 12, 15, 18, 21, 24, ...
```

exactly the positive **multiples of 3**. Indeed `antiFib k + antiFib (k+1) = 3(k+1)`.

## 2. Closed form

The simulation matches `antiFib k = ⌊(3k+2)/2⌋` on every tested prefix (verified by `decide`
on the first 12 terms). Consecutive differences alternate `1, 2, 1, 2, …`.

## 3. Testing the informal conjectures (counterexample hunt)

| Informal claim | Verdict | Evidence |
|---|---|---|
| Terms are `1,1,2,4,7,11,16,…` | **False for the greedy rule** | greedy gives `1,2,4,5,7,8,…`; the listed terms are the *lazy-caterer* numbers `1+C(n,2)`, a different (quadratic) object |
| `A(n) ~ n²/4` | **False** | `antiFib n ≈ 3n/2` (linear); the lazy-caterer object grows like `n²/2`, not `n²/4` |
| Ratio `A(n+1)/A(n)` does not converge | **False** | ratios `2, 2, 1.25, 1.4, 1.14, 1.25, …` converge to `1` |
| Complement/avoided set has density 0 | **False** | avoided set = multiples of 3, density `1/3`; terms have density `2/3` |
| Sequence never equals a sum of two previous terms | **True for the greedy object** | terms are non-multiples of 3, sums are multiples of 3, so disjoint |
| Listed terms `1,1,2,4,7,11,16` are sum-free | **False** | `2 = 1+1` (index 2) and `11 = 7+4` (index 5) are Fibonacci-type coincidences |

## 4. OEIS

* Greedy anti-Fibonacci terms `1,2,4,5,7,8,10,11,…` — the non-multiples of 3 (A001651).
* Listed terms `1,1,2,4,7,11,16,22,…` — the lazy-caterer / central polygonal numbers `1+C(n,2)`
  (A000124).

## 5. Summary

The genuine greedy anti-Fibonacci sequence is the arithmetic progression of non-multiples of 3.
It grows linearly (density 2/3), its consecutive ratio converges to `1` (not the golden ratio),
and it is provably sum-free. The listed terms in the informal problem are a *different*,
quadratic sequence that is in fact **not** sum-free. Both objects are formalized and the
corrected statements are proved with 0 sorries.
