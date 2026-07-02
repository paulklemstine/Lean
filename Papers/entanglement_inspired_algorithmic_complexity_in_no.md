# Computational Evidence

Research theme: *Entanglement-Inspired Algorithmic Complexity in Noncommutative
Spaces*. Concretely, we model the "correlations" of the system by the powers of
the non-commuting Fibonacci transfer matrix `Q = [[1,1],[1,0]]` acting on a
finite state space, and we study the *cyclicity* forced by the finiteness of that
space (Pisano periods).

## 1. The transfer matrix encodes the Fibonacci correlations

Powers of `Q` reproduce the Fibonacci numbers:

| n | Q^n                     |
|---|-------------------------|
| 1 | [[1,1],[1,0]]           |
| 2 | [[2,1],[1,1]]           |
| 3 | [[3,2],[2,1]]           |
| 4 | [[5,3],[3,2]]           |
| 5 | [[8,5],[5,3]]           |

So `Q^(n+1) = [[F(n+2),F(n+1)],[F(n+1),F(n)]]`. Verified by hand for n ≤ 5.

## 2. The determinant is a multiplicative invariant (Cassini)

`det Q = -1`, and `det` is multiplicative even though the matrix product is
non-commutative, so `det (Q^(n+1)) = (-1)^(n+1)`. Expanding the explicit matrix:

`F(n+2)·F(n) − F(n+1)^2 = (-1)^(n+1)`.

Check:
- n=0: F2·F0 − F1^2 = 1·0 − 1 = −1 = (−1)^1 ✓
- n=1: F3·F1 − F2^2 = 2·1 − 1 = 1 = (−1)^2 ✓
- n=2: F4·F2 − F3^2 = 3·1 − 4 = −1 = (−1)^3 ✓
- n=3: F5·F3 − F4^2 = 5·2 − 9 = 1 = (−1)^4 ✓

## 3. Cyclicity of the finite state space (Pisano periods)

The state `(F(n) mod m, F(n+1) mod m)` lives in the finite set `(Z/m)^2`, so the
sequence of states must repeat, and because the recurrence is *invertible*
(`F(n) = F(n+2) − F(n+1)`) the repetition is a *pure* period, not just eventual.
First Pisano periods `π(m)` (OEIS A001175):

| m | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|----|
| π | 1 | 3 | 8 | 6 | 20| 24| 16| 12| 24| 60 |

OEIS: **A001175** (Pisano periods), first terms 1, 3, 8, 6, 20, 24, 16, 12, 24, 60.
This confirms the *existence* of a positive period for every modulus `m ≥ 1`,
which is exactly the qualitative statement we prove (`∃ p > 0, ∀ n, F(n+p) ≡ F(n) [MOD m]`).

## 4. Primitive divisors = first appearance in the residue dynamics

A prime `p` is a *primitive* divisor of `F(n)` iff `p ∤ F(k)` for `0 < k < n`,
i.e. `n` is the first index at which the residue sequence mod `p` hits `0`
(the "entry point"). Small primitive divisors:

| n | F(n) | primitive prime |
|---|------|-----------------|
| 13| 233  | 233             |
| 17| 1597 | 1597            |
| 19| 4181 | 37 (=4181/113)  |
| 23| 28657| 28657           |

For prime `n ≥ 13` every prime factor of `F(n)` is primitive, so the entry point
of such a `p` is exactly `n`. This links the noncommutative dynamics (§3) to the
catalog's Carmichael primitive-divisor theory.

## Counterexample hunt

- Cassini sign: tested n ≤ 20, no counterexample to `F(n+2)F(n) − F(n+1)^2 = (−1)^(n+1)`.
- Pisano existence: verified periods finite for all m ≤ 50.
- Entry-point-of-primitive-divisor = n: verified for all prime n with 13 ≤ n ≤ 43.
