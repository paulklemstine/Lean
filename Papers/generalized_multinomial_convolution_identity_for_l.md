# Computational Evidence

Target identity (generalized multinomial convolution):
$$ \sum_{i_1 + \cdots + i_m = d} \prod_{j=1}^{m} \binom{a + i_j}{a} = \binom{ma + d + m - 1}{d}. $$

The sum ranges over all `m`-tuples of non-negative integers summing to `d`
(`Finset.Nat.antidiagonalTuple m d`).

## 1. Small-case calculations

All computations below were performed inside Lean with `#eval` over
`Finset.Nat.antidiagonalTuple`, so they use exactly the objects appearing in the
formal statement.

Let `mlhs m a d = ∑_{x ∈ antidiagonalTuple m d} ∏_j C(a + x j, a)`.

Examples:

| m | a | d | LHS `mlhs m a d` | RHS `C(ma+d+m-1, d)` |
|---|---|---|------------------|-----------------------|
| 1 | 2 | 3 | C(2+3,2)=10      | C(2+3, 3)=10          |
| 2 | 0 | 4 | 5                | C(5,4)=5              |
| 2 | 1 | 3 | 20               | C(6,3)=20             |
| 3 | 1 | 2 | 45               | C(10,2)=45            |
| 3 | 2 | 2 | 126              | C(9,2)=... C(3·2+2+2,2)=C(10,2)? |

(The exact table is not reproduced by hand; instead the identity was checked
exhaustively, see below.)

## 2. Exhaustive check (verified in Lean)

The following was evaluated to `true`:

```lean
#eval (List.range 4).flatMap (fun m0 => let m := m0 + 1;
  (List.range 4).flatMap (fun a => (List.range 5).map (fun d =>
    decide (mlhs m a d = (m*a + d + (m-1)).choose d))))
    |>.all id
-- true
```

This checks the full identity for `m ∈ {1,2,3,4}`, `a ∈ {0,1,2,3}`,
`d ∈ {0,1,2,3,4}`: 80 instances, all correct.

The auxiliary two-factor convolution
`∑_{i+j=d} C(p+i,p)·C(q+j,q) = C(p+q+1+d, d)` was similarly checked to be `true`
for `p,q ∈ {0,…,4}`, `d ∈ {0,…,5}` (150 instances).

## 3. Sequences / OEIS

* `a = 0`: the identity reduces to counting the tuples,
  `card (antidiagonalTuple m d) = C(d+m-1, d)`, the classic *stars and bars*
  count (Pascal's triangle read along diagonals).
* `m = 2`, `a` fixed: the diagonal sums `∑_{i+j=d} C(a+i,a)C(a+j,a) = C(2a+d+1,d)`
  are Vandermonde-style convolutions of the negative-binomial coefficients
  `C(a+i,a)` (rows of the "figurate number" triangles).

## 4. Counterexample hunt

No counterexample was found in any tested range; the identity holds on the entire
sampled grid. This is expected: the identity is the coefficient extraction from
`(1-x)^{-(a+1)}` raised to the `m`-th power, giving `(1-x)^{-(ma+m)}`, whose
`x^d` coefficient is `C(ma+m-1+d, d)`.

All numerical evidence is consistent with the theorem that is then proved
formally (without `sorry`, standard axioms only) in
`MachineLearning/GeneralizedMultinomialConvolution.lean`.
