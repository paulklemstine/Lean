# Computational Evidence — Formal Verification of Algorithms

This cycle proves three results about classic algorithms. Evidence below was used
to fix the statements *before* formalization (notably the ceil-log complexity bound).

## 1. Binary search complexity: floor-log vs ceil-log

`bsearchSteps p lo hi` counts loop iterations. We tabulate the worst case against
`Nat.log 2 (hi-lo)` (floor) and `Nat.clog 2 (hi-lo)` (ceil):

| gap g = hi - lo | worst-case steps | Nat.log 2 g | Nat.log 2 g + 1 | Nat.clog 2 g |
|-----------------|------------------|-------------|-----------------|--------------|
| 1               | 0                | 0           | 1               | 0            |
| 2               | 1                | 1           | 2               | 1            |
| 3               | 2                | 1           | 2               | 2            |
| 4               | 2                | 2           | 3               | 2            |
| 5               | 3                | 2           | 3               | 3            |
| 8               | 3                | 3           | 4               | 3            |
| 9               | 4                | 3           | 4               | 4            |

**Finding.** Steps equal `Nat.clog 2 g` exactly (tight). The candidate bound
`Nat.log 2 g + 1` is also valid but *not* tight, and — crucially — its induction
breaks at `g = 3` (the ceil branch produces gap `2` with `Nat.log 2 2 = 1 > 0 =
Nat.log 2 1`, consuming the `+1` slack). This is why `bsearch_steps_le` is stated
with `Nat.clog`. The `g = 3` equality `bsearchSteps = 2 = Nat.clog 2 3` is checked
in Lean by `native_decide`.

OEIS: the worst-case-steps sequence `0,1,2,2,3,3,3,3,4,...` (steps to binary-search
`n` items) is the ceil-log-2, related to OEIS A004233 (`⌈log₂ n⌉`).

## 2. DFT/NTT character orthogonality

For a primitive `n`-th root `ω`, `∑_{j<n} ω^{a j} (ω⁻¹)^{b j} = n·[a=b]`.
Concrete check over `ℂ` with `n = 4`, `ω = i`:
- `a=b=1`: `∑_j i^{j} (i⁻¹)^{j} = ∑_j 1 = 4`. ✔ (diagonal = n)
- `a=1, b=0`: `∑_j i^{j} = 1 + i - 1 - i = 0`. ✔ (off-diagonal = 0)
- `a=2, b=0`: `∑_j (i²)^j = ∑_j (-1)^j = 1-1+1-1 = 0`. ✔

Over `ZMod 5` with `ω = 2` (order 4): `2,4,3,1` are the powers; the same
orthogonality holds, giving the Number Theoretic Transform. This confirms the
single proof covers both `ℂ` (DFT) and `ZMod p` (NTT).

## 3. Factoradic index space

`value (digit n) k = n` for `n < k!` was checked for `k = 4` (`4! = 24`): e.g.
`n = 17 = 2·3! + 2·2! + 1·1! + 0·0!` → digits `(0,0,1,2,...)` recover `17`. The
search-space size is exactly `k!`, so binary search costs `⌈log₂ k!⌉` comparisons.

## Counterexample hunt

- Tried `bsearchSteps ≤ Nat.log 2 (hi-lo)` (no `+1`): **counterexample** at
  `(0,3)` (steps `2 > 1`). Rejected.
- Tried `idft_dft` without `(n:F) ≠ 0`: fails when `char F ∣ n` (e.g. `n = p` in
  `ZMod p`), where `(n:F) = 0` and the `1/n` normalisation is undefined. Hypothesis
  kept as essential.
- No counterexample found to the three theorems as finally stated; all three are
  machine-checked with `#print axioms` showing only `propext`, `Classical.choice`,
  `Quot.sound`.
