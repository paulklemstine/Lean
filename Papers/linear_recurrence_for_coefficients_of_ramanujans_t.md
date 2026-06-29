# Computational Evidence — Recurrence for coefficients of Ramanujan's f(q)

## The function

`f(q) = ∑_{n≥0} q^{n²} / ∏_{k=1}^n (1+q^k)²`  (Ramanujan's third order mock theta function).

## 1. Small-case calculation (genuine coefficients)

Computed by formal power-series division over ℤ (script: list-based series, exact integer
arithmetic) to order 60. First 25 coefficients `a_n`:

```
1, 1, -2, 3, -3, 3, -5, 7, -6, 6, -10, 12, -11, 13, -17, 20, -21, 21, -27, 34, -33, 36, -46, 51, -53
```

So `(a_0, a_1, a_2) = (1, 1, -2)`.

## 2. OEIS

This is **OEIS A000025** — "Expansion of Ramanujan's mock theta function f(q)" —
matching `1, 1, -2, 3, -3, 3, -5, 7, -6, 6, ...` exactly.

## 3. Counterexample hunt against the claimed statement

**Claim:** `(a_0,a_1,a_2)=(1,0,1)` and `(n+3)a_{n+3} = (3n+4)a_{n+2} - (3n+1)a_{n+1} + n a_n`.

* **Initial data wrong.** The true triple is `(1, 1, -2)`, not `(1, 0, 1)`.

* **Recurrence has no integer solution with the stated initials.** Running it forward
  over ℚ from `(1,0,1)`:

  | n | forced value |
  |---|--------------|
  | a_3 | 4/3 |
  | a_4 | 4/3 |
  | a_5 | 6/5 |

  The `n=0` instance reads `3 a_3 = 4·a_2 − a_1 = 4`, so `a_3 = 4/3 ∉ ℤ`. Since `f(q)`
  has integer coefficients, the claim is internally inconsistent.

* **Recurrence also fails on the true coefficients.** With `(a_1,a_2,a_3)=(1,-2,3)` the
  `n=0` instance gives LHS `3·3 = 9` but RHS `4·(−2) − 1 = −9`.

## 4. Does ANY low-order polynomial recurrence fit A000025?

Exact rational Gaussian elimination over the first 60 coefficients, searching for a
nonzero relation `∑_{i=0}^{r} p_i(n) a_{n+i} = 0` with `deg p_i ≤ d`:

| order r \ degree d | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| 3 | 0 | 0 | 0 | 0 | 0 | 0 |
| 4 | 0 | 0 | 0 | 0 | 0 | 0 |
| 5 | 0 | 0 | 0 | 0 | 0 | 0 |

"0" = the only solution is the trivial zero relation; **no** P-recurrence of order ≤ 5,
degree ≤ 5 exists. This is consistent with the known fact that mock theta functions are
**non-holonomic** (their coefficient sequences satisfy no linear recurrence with
polynomial coefficients).

## 5. What was formalized in Lean (0 sorries)

* `Bridges/MockThetaFRecurrence.lean`
  * `claimSeq` — the unique ℚ-sequence forced by the claimed data;
  * `claimSeq_satisfies_recurrence` (induction) — well-definedness;
  * `claimSeq_three = 4/3`, `claimSeq_three_not_integer`;
  * `no_integer_sequence_satisfies_claim` (omega) — **no integer sequence obeys the
    claimed recurrence with the claimed initials**.
* `Bridges/MockThetaFUniqueness.lean`
  * `recurrence_unique` (strong induction) — the order-3 recurrence determines the
    sequence from its first three values;
  * `eq_claimSeq`, `claim_solution_not_integer` — every solution of the claim is
    non-integral at index 3.
