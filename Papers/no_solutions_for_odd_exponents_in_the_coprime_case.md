# Computational Evidence: `(aⁿ+1)(bⁿ+1) = x²` for odd `n`

## 1. Counterexample hunt (target conjecture)

Brute-force search for positive-integer solutions of `(aⁿ+1)(bⁿ+1) = x²` with
`gcd(a,b)=1`, `1 < a < b`:

| exponent range (odd) | `a` range | `b` range | solutions found |
|----------------------|-----------|-----------|-----------------|
| `3 ≤ n ≤ 15`         | `2..200`  | `a+1..300`| **0**           |

No solutions were found anywhere in the search box, consistent with the conjecture.

## 2. The key structural identity (drives the proof)

For odd `a` and odd `n`, the 2-adic valuation `v₂(aⁿ+1)` is *independent of `n`*:

```
v₂(aⁿ+1) = v₂(a+1)     for all odd n
```

Checked exhaustively for all odd `a < 200` and odd `n < 20`: **0 counterexamples**.

Equivalently, the cofactor `S := (aⁿ+1)/(a+1)` is always an **odd** integer
(checked on the same range: **0** cases where `S` was even). This is exactly the
statement `natFactor_odd_pow`, and it holds for *every* base `a` (even bases too),
because the recurrence `S_{k+1} = a²·S_k − (a−1)` preserves oddness regardless of the
parity of `a`.

## 3. The 2-adic parity sieve (the obstruction)

Because a perfect square has even 2-adic valuation, and

```
v₂((aⁿ+1)(bⁿ+1)) = v₂(a+1) + v₂(b+1)     (odd n),
```

the product can be a square only if `v₂(a+1)+v₂(b+1)` is **even**. Sample of pairs where
the sum is odd (hence provably no solution, any odd `n`):

| `a` | `b` | `v₂(a+1)` | `v₂(b+1)` | sum | parity | square possible? |
|-----|-----|-----------|-----------|-----|--------|------------------|
| 5   | 11  | 1         | 2         | 3   | odd    | never            |
| 5   | 19  | 1         | 2         | 3   | odd    | never            |
| 2   | 5   | 0         | 1         | 1   | odd    | never (mixed)    |
| 9   | 11  | 1         | 2         | 3   | odd    | never            |

These are the residue families formalised as `conjecture_holds_odd_odd_family`
(`a ≡ 1 mod 4`, `b ≡ 3 mod 8`) and `conjecture_holds_mixed_family` (`a` even,
`b ≡ 1 mod 4`).

## 4. k-fold generalisation

The additivity `v₂(∏ (aᵢⁿ+1)) = Σ v₂(aᵢ+1)` was confirmed on random lists, e.g.
`[3,5,7]` gives `2+1+3 = 6` (even; obstruction silent) and `[5,11]` gives `3` (odd; the
product is never a square). Formalised as `not_isSquare_prod_two_adic`.

## 5. Scope note

The 2-adic sieve resolves infinitely many coprime instances but is silent when
`v₂(a+1)+v₂(b+1)` is even; those cases require different (odd-prime or descent) methods,
mirroring the fixed-base results of the referenced literature. No counterexample to the
full conjecture was found.
