# Computational Evidence — Gaussian binomial coefficients

Companion to `GarsiaQBinomial.lean`.

We define the Gaussian binomial coefficient `⟦n,k⟧_q ∈ ℤ[q]` (with `q = X`) by the
q-Pascal recurrence

```
⟦n,0⟧      = 1
⟦0,k+1⟧    = 0
⟦n+1,k+1⟧  = ⟦n,k⟧ + q^{k+1} · ⟦n,k+1⟧.
```

## 1. Small-case table (coefficient lists, lowest degree first)

Computed in Lean with `#eval`:

| n\k | 0 | 1            | 2                | 3                    |
|-----|---|--------------|------------------|----------------------|
| 0   | 1 |              |                  |                      |
| 1   | 1 | 1            |                  |                      |
| 2   | 1 | 1+q          | 1                |                      |
| 3   | 1 | 1+q+q²       | 1+q+q²           | 1                    |
| 4   | 1 | 1+q+q²+q³    | 1+q+2q²+q³+q⁴    | 1+q+q²+q³            |

For example `⟦4,2⟧_q` has coefficient list `[1,1,2,1,1]` — a **palindrome**, as
predicted by the symmetry theorem `qBinom_symm` (`⟦4,2⟧ = ⟦4,2⟧`).

## 2. Specialization at q = 1

Evaluating at `q = 1` collapses each Gaussian binomial to the ordinary binomial:

```
⟦4,2⟧_1 = 1+1+2+1+1 = 6 = C(4,2)
⟦5,2⟧_1 = 10        = C(5,2)
⟦3,3⟧_1 = 1         = C(3,3)
```

matching `qBinom_eval_one : (qBinom n k).eval 1 = Nat.choose n k`.  This was
checked with `#eval (qBinom n k).eval 1` for all `n ≤ 6`, `k ≤ n`.

## 3. q-integers

`[n]_q = 1 + q + ⋯ + q^{n-1}` satisfies `[n]_1 = n` and `⟦n,1⟧_q = [n]_q`, both
confirmed numerically for `n ≤ 8` and both proved (`qNat_eval_one`,
`qBinom_one_right`).

## 4. Recurrence-compatibility check

The two forms of the q-Pascal rule (the defining one and its dual
`qBinom_pascal'`) were cross-checked: for every `k ≤ n ≤ 6`,

```
⟦n,k⟧ + q^{k+1}·⟦n,k+1⟧  =  q^{n-k}·⟦n,k⟧ + ⟦n,k+1⟧
```

holds as polynomials (this is `qPascal_compat`).

## 5. Sequences

The evaluations `⟦n,k⟧_1` reproduce Pascal's triangle (OEIS A007318).  The
coefficient polynomials of `⟦n,k⟧_q` are the Gaussian binomial coefficients; the
triangle of their coefficients is catalogued as OEIS A008967 / A050156.

No counterexamples to symmetry, to the q=1 specialization, or to the dual Pascal
recurrence were found in the exhaustive range `n ≤ 6`.  All of these facts are
now proved in full generality in `GarsiaQBinomial.lean`.
