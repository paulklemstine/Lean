# Computational Evidence — Petrie Divisibility Criterion

We study the **Petrie block** `𝔭_k(x) = 1 + x + ⋯ + x^{k-1}`, the principal
building block of the Petrie symmetric function `G(k,n) = ∑_{λ⊢n, λ₁<k} m_λ`, and
the conjecture that governs its arithmetic:

> `𝔭_k(x)` divides `xⁿ − 1` **iff** `k ∣ n`.

## 1. Small-case calculations

Roots of `𝔭_k` are the `k`-th roots of unity other than `1`, since
`(x−1)·𝔭_k = x^k − 1`. Testing divisibility of `xⁿ − 1`:

| k | n | k ∣ n ? | 𝔭_k ∣ xⁿ−1 ? |
|---|---|---------|---------------|
| 2 | 2 | yes     | yes           |
| 2 | 3 | no      | no            |
| 2 | 4 | yes     | yes           |
| 3 | 3 | yes     | yes           |
| 3 | 4 | no      | no            |
| 3 | 6 | yes     | yes           |
| 4 | 6 | no      | no  (only 2∣6, but 4∤6) |
| 4 | 8 | yes     | yes           |

The two columns agree in every case — no counterexample found.

## 2. Principal specialization word count

Setting `x = 1` gives `P(k,N;1) = 𝔭_k(1)^N = k^N`, the number of length-`N`
words over a `k`-letter alphabet. For `(k,N) = (2,3), (3,2), (5,1)` this is
`8, 9, 5`, matching direct enumeration of bounded compositions.

## 3. Cyclotomic explanation

`𝔭_k = ∏_{d ∣ k, d > 1} Φ_d` (product of cyclotomic polynomials over proper
divisors `> 1`). Since `k` is itself such a divisor, `Φ_k ∣ 𝔭_k`, and `Φ_k ∣ xⁿ−1`
forces `k ∣ n`. This is why `k ∣ n` (and not merely "some divisor of `k` divides
`n`") is the exact dividing line: the top divisor `d = k` is present in `𝔭_k`.

## 4. Counterexample hunt

We searched all `(k,n)` with `2 ≤ k ≤ 8`, `1 ≤ n ≤ 24` comparing `k ∣ n` against
the root-of-unity divisibility test. The two conditions coincide throughout;
no counterexample exists in this range, consistent with the proven biconditional.

## Conclusion

The evidence is fully consistent with the theorem
`petrieBlock_dvd_X_pow_sub_one_iff`, which establishes the biconditional for **all**
`k ≥ 2`, `n ≥ 1`.
