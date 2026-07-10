# Computational Evidence — Hilbert's Hotel for Primes

Room `n` holds the `n`-th prime `p n = Nat.nth Nat.Prime n` (0-indexed: `p 0 = 2`,
`p 1 = 3`, …). A rearrangement is a permutation `σ` of `ℕ`; we track the **displacement
ratio** `primeRatio σ n = p (σ n) / p n` and ask whether it converges to `1`.

All numbers below were computed in Lean with a computable prime list
(`(List.range N).filter Nat.Prime`).

## 1. The primes (first twelve rooms)

```
p 0..11 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
```

## 2. Adjacent-swap permutation `n ↦ n ⊕ 1` (swap even/odd indices)

Ratios `p(swap n) / p n` for `n = 0 … 11`:

```
1.500, 0.667, 1.400, 0.714, 1.182, 0.846, 1.118, 0.895, 1.261, 0.793, 1.194, 0.838
```

Individually these oscillate, but the underlying quantity `p_{n+1}/p_n` steadily approaches
`1`, so this permutation *is* well behaved. Convergence is slow (a consequence of the prime
number theorem, `p_n ~ n log n`):

```
n=10 : p_{n-1}/p_n = 0.935
n=20 : 0.973
n=50 : 0.983
n=100: 0.989
n=150: 0.984
n=199: 0.995
```

This is exactly the "swap even/odd rooms converges to 1" example from the mission statement.
It is *true* but requires PNT-level input, so it is not what we formalize; see below.

## 3. Finitely supported permutation (reverse rooms `{0,…,9}`, fix the rest)

Ratios `p(σ n)/p n` for `n = 0 … 14`:

```
14.50, 7.67, 3.80, 2.43, 1.18, 0.85, 0.41, 0.26, 0.13, 0.069, 1.000, 1.000, 1.000, 1.000, 1.000
```

The ratios are wild inside the reversed block but become **exactly `1` for every `n ≥ 10`**.
This is the phenomenon we prove in general: any finitely supported rearrangement has a
displacement ratio that is *eventually equal to `1`*, hence converges to `1`
(`wellBehaved_of_finite_support`). Because finitely supported permutations can match any
target permutation on any finite initial segment, they are dense in `Sym(ℕ)`, giving the
density theorem `wellBehaved_dense` with a completely elementary, PNT-free proof.

## 4. A rearrangement that is NOT well behaved (long-range swaps)

A single long-range swap `0 ↔ 30` already produces ratios far from `1`:

```
at room 0 : p_30/p_0  = 63.50
at room 30: p_0/p_30  = 0.0157
```

By stacking infinitely many such swaps, each doubling the prime value
(`p(jumpSeq (2j+1)) ≥ 2 · p(jumpSeq (2j))`), we obtain a genuine permutation whose ratio is
`≥ 2` infinitely often, so it does not converge to `1`. This is `exists_not_wellBehaved`.
Crucially the construction only uses that primes are unbounded, so the negative result is also
PNT-free.

## Counterexample hunt / OEIS

No universal claim is being tested numerically to destruction here; instead the data confirm
the two qualitative regimes we prove (finite support ⇒ eventually ratio `1`; sparse growing
swaps ⇒ ratio `≥ 2` infinitely often). The prime sequence `p n` is OEIS A000040.
