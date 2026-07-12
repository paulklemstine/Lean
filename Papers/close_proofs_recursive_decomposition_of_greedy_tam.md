# Computational Evidence

Object: the Fuss–Catalan numbers `fc m n = C((m+1)·n, n) / (m·n + 1)`, which count
`(m+1)`-ary plane trees with `n` internal nodes / `m`-Dyck paths of length
`(m+1)·n`, and specialize (at `m = 1`) to the Catalan numbers underlying the
recursive decomposition of greedy Tamari intervals.

## 1. Small-case calculations (computed with `#eval`)

```
#eval (List.range 6).map (fun n => Nat.choose (2*n) n / (n+1))   -- fc 1 (= catalan)
-- [1, 1, 2, 5, 14, 42]
#eval (List.range 6).map catalan
-- [1, 1, 2, 5, 14, 42]                     (agree, confirming fc 1 = catalan)
#eval (List.range 6).map (fun n => Nat.choose (3*n) n / (2*n+1)) -- fc 2
-- [1, 1, 3, 12, 55, 273]
#eval (List.range 6).map (fun n => Nat.choose (4*n) n / (3*n+1)) -- fc 3
-- [1, 1, 4, 22, 140, 969]
```

## 2. OEIS matches

- `fc 1`: 1, 1, 2, 5, 14, 42, … — Catalan numbers, **A000108**.
- `fc 2`: 1, 1, 3, 12, 55, 273, … — Fuss–Catalan / ternary trees, **A001764**.
- `fc 3`: 1, 1, 4, 22, 140, 969, … — Fuss–Catalan, **A002293**.

## 3. Checks used to fix the formalization

- Exactness of the division: `(n+1) * (C(2n,n)/(n+1)) = C(2n,n)` verified for
  `n ≤ 20` before proving `fc_one_mul` via `Nat.succ_dvd_centralBinom`.
- Recursive decomposition (Catalan convolution) `fc 1 (n+1) = Σ_{i≤n} fc 1 i · fc 1 (n-i)`
  checked numerically for `n ≤ 8`, matching `catalan_succ`.
- Monotonicity `fc 1 n ≤ fc 1 (n+1)` holds on all sampled `n`; the diagonal term
  `fc 1 n · fc 1 0 = fc 1 n` of the convolution already witnesses the bound, which
  is exactly how `fc_one_mono` is proved.

## 4. Counterexample hunt

No counterexamples were found for any proved statement. The one claim deliberately
**not** promoted to a general-`m` theorem is integrality of `fc m n` for `m ≥ 2`
(the division is exact in all sampled cases, but the general proof needs the cycle
lemma); this is left open in `FUTURE_DIRECTIONS.md` rather than asserted.
