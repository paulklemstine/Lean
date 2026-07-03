# Computational Evidence — Fan-structure in Selmer group distributions

All computations below were run in Lean over exact `ℕ`/`ℤ` arithmetic (no
floating point), so every reported value is exact.

## 1. Gaussian binomial layers `[n,k]_q` (the fan)

`gaussBinom q n k` counts rank-`k` subspaces of `𝔽_q^n`. Small cases:

| n | q | `[n,·]_q` (k = 0..n) |
|---|---|----------------------|
| 4 | 2 | 1, 15, 35, 15, 1 |
| 3 | 3 | 1, 13, 13, 1 |
| 5 | 2 | 1, 31, 155, 155, 31, 1 |

The rows are palindromic — the visual signature of the **fan self-duality**
`[n,k]_q = [n,n-k]_q`, and match the known subspace counts of finite vector
spaces (e.g. `[4,2]_2 = 35`).

## 2. Recurrences verified

* Forward `q`-Pascal `[n+1,k+1] = [n,k] + q^{k+1}[n,k+1]` — definitional.
* Dual `q`-Pascal `[n+1,k+1] = q^{n-k}[n,k] + [n,k+1]` — checked by `decide`
  for all `n ≤ 6`, `k ≤ 7`, `q = 2` (holds for all `k`, including `k > n`,
  because the fan has finite support).

## 3. Self-duality / classical limit / rank-one layer

* `[n,k]_2 = [n,4-k]_2` verified for `n = 4`, all `k`.
* `[n,k]_1 = C(n,k)` verified for all `n, k ≤ 7` — the fan degenerates to
  Pascal's triangle at `q = 1`.
* `[n,1]_3 = ∑_{i<n} 3^i` (the `q`-integer) verified for `n ≤ 6`:
  `0, 1, 4, 13, 40, 121`.

## 4. Disparity walk (parity rigidity)

A "Selmer walk" is an integer sequence with `±1` steps (each ramified prime /
tower layer changes the Selmer rank by one). Enumerating the four length-2
walks from `0`:

```
0 → 1 → 0    end 0  (even)
0 → 1 → 2    end 2  (even)
0 → -1 → 0   end 0  (even)
0 → -1 → -2  end -2 (even)
```

Every length-2 walk ends at an even value, illustrating
`w n ≡ w 0 + n (mod 2)` and the corollary that a closed walk has even length.

## 5. OEIS cross-checks

* Row sums `∑_k [n,k]_2 = 2, 5, 16, 67, 374, …` are the Galois numbers,
  **OEIS A006116**.
* `[n,2]_2 = 1, 7, 35, 155, …` matches **OEIS A006095**-type subspace counts.

## Conclusion

The computational evidence supports all four formalized claims exactly; no
counterexample was found in any tested range. These checks motivated the Lean
proofs in `Catalog/Algebra/SelmerFanGaussian.lean` and
`Catalog/Algebra/SelmerFanDisparity.lean`.
