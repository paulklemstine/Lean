# Computational Evidence — Supersingular Matsuno degrees at a general prime `p`

Research thread `th_1e5d06de`, cycle 1. Building on `MatsunoMuExtension.lean`
(cycle 0), we pursue **Future Direction #4**: generalise the Jacobsthal identities
governing the `p = 2` sharp/flat degree sequences to an arbitrary supersingular
prime `p`, replacing the base-`4` sums by base-`p²` sums and the Jacobsthal
recurrence `Jₙ₊₂ = Jₙ₊₁ + 2Jₙ` by the two-parameter recurrence
`qₙ₊₂ = (p−1)qₙ₊₁ + p·qₙ`.

## 1. Small-case calculations

Generalised Jacobsthal `q_n(p)` with `q₀ = 0, q₁ = 1, qₙ₊₂ = (p−1)qₙ₊₁ + p·qₙ`.

Claim: `(p+1)·qₙ = pⁿ − (−1)ⁿ`.

| n | (p+1)·qₙ  (p=2) | 2ⁿ−(−1)ⁿ | (p+1)·qₙ (p=3) | 3ⁿ−(−1)ⁿ |
|---|-----------------|----------|----------------|----------|
| 0 | 0               | 0        | 0              | 0        |
| 1 | 3               | 3        | 4              | 4        |
| 2 | 3               | 3        | 8              | 8        |
| 3 | 9               | 9        | 28             | 28       |
| 4 | 15              | 15       | 80             | 80       |
| 5 | 33              | 33       | 244            | 244      |

All match (verified by evaluation).

## 2. Base-`p²` flat degree

`flatDegP p n = ∑_{i<n} p^{2i}`.

Claim (subtraction-free): `p²·flatDegP p n + 1 = flatDegP p n + p^{2n}`,
equivalently `(p²−1)·flatDegP p n + 1 = p^{2n}`.

For `p = 3`: `8·flatDegP 3 n + 1 = 3^{2n}`: gives `1, 9, 81, 729, 6561, …` = `9ⁿ`. ✓

## 3. The bridge identity

Claim: `q_{2n}(p) = (p−1)·flatDegP p n`.

For `p = 3`: `q_{2n} = 0, 2, 20, 182, 1640, …` and `2·flatDegP 3 n =
0, 2, 20, 182, 1640, …`. ✓

## 4. Consecutive-sum identity

Claim: `qₙ + qₙ₊₁ = pⁿ`. For `p = 3`: `1, 3, 9, 27, 81, 243, …` = `3ⁿ`. ✓

## 5. Specialisation recovers cycle-0 catalog results

At `p = 2` the closed form becomes `3·q_n = 2ⁿ − (−1)ⁿ` (the catalog
`three_jac`), and `flatDegP 2 n` satisfies `3·flatDegP 2 n + 1 = 4ⁿ`
(the catalog `three_flatDeg_add_one`). The bridge `q_{2n} = (p−1)·flatDegP`
collapses to `q_{2n} = flatDegP` since `p − 1 = 1` — exactly the catalog
`jac_two_mul`.

## OEIS

- `q_n(2)`: Jacobsthal numbers **A001045** (`0,1,1,3,5,11,21,…`).
- `q_n(3)`: **A015518** (`0,1,2,7,20,61,…`).
- `flatDegP 2 n = (4ⁿ−1)/3`: **A002450** (`0,1,5,21,85,…`).
- `flatDegP 3 n = (9ⁿ−1)/8`: **A002452** (`0,1,10,91,…`).

No counterexamples found across `p ∈ {2,3,5,7}`, `n ≤ 8`.
