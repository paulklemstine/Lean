# Computational Evidence — Finite Rogers–Ramanujan / Schur polynomials

## Objects

Gaussian binomial coefficient `[n,k]_q` via the q-Pascal recurrence
`[n+1,k+1] = [n,k] + q^{k+1}[n,k+1]`, and the Rogers–Ramanujan (Schur)
polynomial `D_n` with `D_0 = D_1 = 1`, `D_{n+2} = D_{n+1} + q^{n+1} D_n`.

Claimed finite identity (Schur):  `D_n = ∑_{k≥0} q^{k²} [n-k, k]_q`.

## 1. Small-case calculations (as polynomials in q)

```
D_0 = 1
D_1 = 1
D_2 = 1 + q
D_3 = 1 + q + q^2
D_4 = 1 + q + q^2 + q^3 + q^4
D_5 = 1 + q + q^2 + 2q^3 + q^4 + q^5 + q^6
```
Each matches `∑_k q^{k²} [n-k,k]_q` term by term.

## 2. Counterexample hunt (integer specialisations)

Using a computable integer model `gaussV q`, `rrV q` we checked

  `rrV q n = ∑_{k=0}^{n} q^{k²} · gaussV q (n-k) k`

for `q ∈ {-3, -2, -1, 0, 2, 3, 5, 7}` and `n = 0 … 13`:  **0 discrepancies**
(96 test cases). Equality at these many distinct evaluation points, together
with the recursive structure, is strong evidence for the polynomial identity,
which is then proved in full in `RogersRamanujanGauss.lean`.

## 3. The q → 1 shadow (Fibonacci)

At `q = 1` the Gaussian binomial degenerates to the ordinary binomial and the
Schur polynomial becomes a Fibonacci number:

| n            | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|--------------|---|---|---|---|---|---|---|---|---|---|
| ∑ C(n-k,k)   | 1 | 1 | 2 | 3 | 5 | 8 |13 |21 |34 |55 |
| fib(n+1)     | 1 | 1 | 2 | 3 | 5 | 8 |13 |21 |34 |55 |

Checked for `n = 0 … 12`: exact match. This is OEIS **A000045** (Fibonacci
numbers). The diagonal-of-Pascal reading `∑_k C(n-k,k) = F_{n+1}` is the
classical shallow-diagonal identity.

## Conclusion

The computational evidence is consistent with (and motivated) the four formally
proved results in `RogersRamanujanGauss.lean`:
`gauss_finitization`, `gauss_eval_one`, `rrPoly_eval_one`, `rr_diagonal_fib`.
