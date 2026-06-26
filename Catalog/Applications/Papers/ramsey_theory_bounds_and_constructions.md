# Computational Evidence — `R(4,4) = 18` and the diagonal bound

This note records the small-case computations that guided the formal proofs in
`RamseyFourFour.lean` and `RamseyDiagonalBound.lean`.

## 1. Known small two-colour Ramsey numbers (OEIS A212954 diagonal / classical table)

| s\t | 1 | 2 | 3 | 4  | 5  |
|-----|---|---|---|----|----|
| 1   | 1 | 1 | 1 | 1  | 1  |
| 2   | 1 | 2 | 3 | 4  | 5  |
| 3   | 1 | 3 | 6 | 9  | 14 |
| 4   | 1 | 4 | 9 | 18 | 25 |

Diagonal values `R(k,k)`: 1, 2, 6, 18, 48–49 (R(5,5) unknown). The values
`R(3,3)=6`, `R(3,4)=9`, `R(4,4)=18` are exactly the targets formalised in this
catalog.

## 2. Upper bound `R(4,4) ≤ 18` — recursion check

Erdős–Szekeres: `R(s,t) ≤ R(s-1,t) + R(s,t-1)`.
- `R(4,4) ≤ R(3,4) + R(4,3) = 9 + 9 = 18`. ✔ (tight)
- Binomial bound `R(4,4) ≤ C(6,3) = 20` is looser, confirming the recursion (not
  the binomial estimate) is what is sharp here.

## 3. Lower bound `R(4,4) > 17` — Paley graph on 𝔽₁₇

Nonzero quadratic residues mod 17: `{1,2,4,8,9,13,15,16}` (8 of them, since
`(17-1)/2 = 8`). Because `17 ≡ 1 (mod 4)`, `-1 ≡ 16` is a residue, so the set is
closed under negation and defines an undirected graph.

Exhaustive search (reproduced in Lean by `native_decide`):
- Number of 4-subsets of 17 vertices: `C(17,4) = 2380`.
- Red `K₄`'s found: **0**.
- Blue `K₄`'s found: **0** (the Paley graph is self-complementary).

Hence the Paley colouring of `K₁₇` has no monochromatic `K₄`, giving `R(4,4) > 17`.

`#eval decide (¬ ∃ S : Finset (Fin 17), paley17.IsNClique 4 S)  -- true`

## 4. Diagonal exponential bound `R(k+1,k+1) ≤ 4^k`

Central binomial estimate `C(2k,k) ≤ 4^k`:

| k | C(2k,k) | 4^k |
|---|---------|-----|
| 0 | 1       | 1   |
| 1 | 2       | 4   |
| 2 | 6       | 16  |
| 3 | 20      | 64  |
| 4 | 70      | 256 |

So `R(3,3) ≤ 16`, `R(4,4) ≤ 64` from the generic bound — both far from the exact
values `6` and `18`, confirming that the exact results genuinely beat the generic
exponential estimate.

## 5. Conclusion

All four numerical facts above are reproduced as machine-checked Lean theorems:
the upper bound by the recursion `arrows_step` + colour symmetry, the lower bound
by an exhaustive `native_decide` certificate on the Paley graph, and the diagonal
bound by the central binomial estimate `central_choose_le_four_pow`.
