# Computational Evidence: Orbits of Boolean Cubic Forms under GL(10,2)

## 1. The objects

A *Boolean cubic form* in `n` variables over the two-element field is a squarefree
homogeneous cubic, i.e. a `GF(2)`-linear combination of the monomials `x_i x_j x_k`
(`i,j,k` distinct). It is determined by one coefficient bit per 3-subset of the
variables, so the form space has dimension `C(n,3)` and cardinality `2^{C(n,3)}`.
The group `GL(n,2)` acts by linear substitution of variables.

For `n = 10`:

| quantity | value |
|---|---|
| dimension `C(10,3)` | 120 |
| number of forms `2^120` | 1 329 227 995 784 915 872 903 807 060 280 344 576 |
| `\|GL(10,2)\| = ∏_{i=0}^{9}(2^{10}-2^i)` | 366 440 137 299 948 128 422 802 227 200 |

## 2. The pigeonhole (orbit-counting) bound

Each orbit has size dividing `|GL(10,2)|`, hence at most `|GL(10,2)|`. Partitioning
the `2^120 - 1` nonzero forms into nonzero orbits gives

```
(number of nonzero orbits) ≥ ceil((2^120 - 1) / |GL(10,2)|).
```

Direct integer computation:

```
ceil((2^120 - 1) / |GL(10,2)|) = 3 627 409
```

with the certifying inequalities

```
3 627 409 * |GL(10,2)|  - (2^120 - 1) = 256 218 151 667 670 221 543 884 980 225   (> 0)
(2^120 - 1) - 3 627 408 * |GL(10,2)|  = 110 221 985 632 277 906 878 917 246 975   (> 0)
```

so `3 627 409` is exactly the ceiling.

## 3. Comparison with the proposed exact count 3 691 560

```
lower bound (proven)   : 3 627 409
proposed exact count   : 3 691 560
excess                 :    64 151   (= 1.7685 %)
upper bound 2^120 - 1  : 1 329 227 995 784 915 872 903 807 060 280 344 575
```

The proposed count sits `1.77%` above the pigeonhole bound. Interpreted structurally,
the excess `64 151` is the aggregate "defect" contributed by forms lying in orbits
strictly shorter than `|GL(10,2)|` (forms with nontrivial stabiliser). If *every*
nonzero form were regular (trivial stabiliser), the orbit count would equal the
pigeonhole bound exactly; the small `1.77%` gap says almost all forms are regular.

## 4. Small-case sanity checks (dimension of the form space)

| n | C(n,3) = dim | number of forms 2^{C(n,3)} |
|---|---|---|
| 3 | 1  | 2 |
| 4 | 4  | 16 |
| 5 | 10 | 1024 |
| 6 | 20 | 1 048 576 |
| 10 | 120 | 2^120 |

For `n = 3` there is a single cubic monomial `x_1x_2x_3`, giving exactly one nonzero
orbit — consistent with the pigeonhole bound `ceil(1 / |GL(3,2)|) = 1`.

## 5. Method

All integer inequalities above are exact (no floating point) and are the ones
discharged in the accompanying development: the group order via the finite-field
formula, the form count via the number of 3-subsets, and the two-sided window for
the orbit count via the orbit-counting identity. The exact value `3 691 560` is a
reported classification result; it is not re-derived here (a closed-form derivation
is beyond the pigeonhole method), but it is shown to be consistent with the proven
window `[3 627 409, 2^120 - 1]`.
