# Computational Evidence — Lucas-sequence identities

Target file: `Catalog/Applications/LucasSequenceIdentities.lean`.

Lucas numbers `L : ℕ → ℕ`, `L 0 = 2`, `L 1 = 1`, `L (n+2) = L n + L (n+1)`.
Fibonacci `F = Nat.fib`.

## 1. Small-case table

| n | F n | L n |
|---|-----|-----|
| 0 | 0   | 2   |
| 1 | 1   | 1   |
| 2 | 1   | 3   |
| 3 | 2   | 4   |
| 4 | 3   | 7   |
| 5 | 5   | 11  |
| 6 | 8   | 18  |
| 7 | 13  | 29  |

`L` is OEIS A000032 (Lucas numbers): 2, 1, 3, 4, 7, 11, 18, 29, 47, …

## 2. Conjectures checked by `#eval` before formalisation

Each was verified exhaustively over the indicated finite range (all returned `true`),
using `decide`-style boolean sweeps in Lean (`List.range ... |>.all ...`).

| Identity | Range checked | Result |
|----------|---------------|--------|
| `∑_{i≤n} L i = L (n+2) − 1`            | n < 8           | ✓ true |
| `∑_{i≤n} (L i)² = L n · L (n+1) + 2`   | n < 8           | ✓ true |
| `2 F (m+n) = F m · L n + L m · F n`    | m, n < 6        | ✓ true |
| `2 L (m+n) = L m · L n + 5 F m · F n`  | m, n < 6        | ✓ true |
| `L (2n) = (L n)² − 2(−1)ⁿ`  (over ℤ)   | n < 8           | ✓ true |
| `L (2n+1) = L n · L (n+1) − (−1)ⁿ` (ℤ) | n < 8           | ✓ true |
| `L n · L (n+2) − (L (n+1))² = 5(−1)ⁿ` (ℤ) | n < 8        | ✓ true |

## 3. Counterexample hunt / failure analysis

- The first hand-guessed Lucas–Cassini sign, `L n · L (n+2) − (L (n+1))² = −5(−1)ⁿ`,
  was **falsified immediately**: at `n = 0`, `L0·L2 − L1² = 2·3 − 1 = 5`, whereas
  `−5(−1)⁰ = −5`. Corrected to `+5(−1)ⁿ`, which then passed the full sweep.
- No counterexamples were found for any of the seven retained identities within the tested ranges.

## 4. From evidence to proof

All seven conjectures were subsequently proved in Lean 4 with `0` sorries
(`#print axioms` shows only `propext`, `Classical.choice`, `Quot.sound`). The numeric
sweeps were therefore promoted to fully verified theorems; the table above records the
exploratory stage only.
