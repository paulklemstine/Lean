# Computational Evidence — Burnside Moment Hierarchy

All numbers below were produced by exhaustive enumeration in a scratch Python script
(`itertools.permutations` / `product`) **before** the Lean formalisation. They are
*evidence*, not verification: the machine-checked statements live in
`Catalog/Logic/MomentHierarchy.lean` and `Catalog/Logic/MomentHierarchyBell.lean`.
Several entries of the tables are additionally reproduced as machine-checked Lean
theorems: `orbitCount_regular_perm_fin_two`, `orbitCount_perm_fin_two_two`, the measured
moments `∑_{σ ∈ S_3} |fix σ|^3 = 30` and `∑_{σ ∈ S_4} |fix σ|^4 = 360`
(`sum_fixedPoints_perm_three_cube`, `sum_fixedPoints_perm_four_pow_four`, both closed by
`decide`), and the resulting partition counts `P(3) = 5`, `P(4) = 15`
(`partitionCount_three`, `partitionCount_four`), obtained from those moments through the
Poisson moment theorem.

Notation: `a_g := |X^g|`, `S_k := ∑_{g∈G} a_g^k`, `o_k := #((X^k)/G)`.

## 1. Small-case calculations of the moment identity `S_k = o_k · |G|`

| action                  | `|G|` | `S_0 … S_5`                      | `o_0 … o_5`            | `S_k = o_k·|G|` |
|-------------------------|-------|----------------------------------|------------------------|-----------------|
| `S_3` on 3 points       | 6     | 6, 6, 12, 30, 84, 246            | 1, 1, 2, 5, 14, 41     | ✔ all `k`       |
| `S_4` on 4 points       | 24    | 24, 24, 48, 120, 360, 1224       | 1, 1, 2, 5, 15, 51     | ✔ all `k`       |
| `A_4` on 4 points       | 12    | 12, 12, 24, 72, 264, 1032        | 1, 1, 2, 6, 22, 86     | ✔ all `k`       |
| `D_4` on 4 points       | 8     | 8, 8, 24, 80, 288, 1088          | 1, 1, 3, 10, 36, 136   | ✔ all `k`       |
| `C_4` regular           | 4     | 4, 4, 16, 64, 256, 1024          | 1, 1, 4, 16, 64, 256   | ✔ all `k`       |
| trivial group, 3 points | 1     | 1, 3, 9, 27, 81, 243             | 1, 3, 9, 27, 81, 243   | ✔ all `k`       |

Every row satisfies the identity exactly, at every level — the empirical basis for
`sum_fixedPoints_pow_eq_orbits_mul_card`.

## 2. Sequence identification

* `S_4` row `1, 1, 2, 5, 15, 51`: Bell numbers **A000110** `1,1,2,5,15,52,…`, truncated
  at `k = 5` (`51 = 52 − 1`) because a partition into 5 blocks cannot be realised on 4
  points. `S_3` row `1, 1, 2, 5, 14, 41` is the same phenomenon one step earlier
  (`14 = 15 − 1`, `41 = 52 − 10 − 1`). This is exactly the boundary `k ≤ |X|` appearing
  in the hypothesis of `orbitCount_perm_eq_partitionCount`.
* `C_4` regular row `1, 1, 4, 16, 64, 256` is `|G|^{k−1}` for `k ≥ 1`
  (`orbitCount_regular_eq`).
* `A_4` row `1, 1, 2, 6, 22, 86` and `D_4` row `1, 1, 3, 10, 36, 136` are the orbit
  hierarchies of the corresponding permutation groups; the `D_4` entry `o_2 = 3` is the
  rank of the dihedral action on 4 points.

## 3. Counterexample hunt

The following universal claims were tested on all six actions above and levels
`k ≤ 5`:

| claim                                          | outcome                                        |
|------------------------------------------------|------------------------------------------------|
| `S_k = o_k · |G|`                                | no counterexample (now proved)                 |
| `o_{k+1}^2 ≤ o_k · o_{k+2}` (log-convexity)      | no counterexample (now proved)                 |
| `o_k ≤ o_{k+1}` for `k ≥ 1`                      | no counterexample (now proved)                 |
| `o_k ≤ o_{k+1}` for `k = 0`                      | **fails** for the trivial group only if `X = ∅`; holds whenever `X ≠ ∅`. The Lean statement therefore assumes `1 ≤ k`. |
| `|X|^k ≤ |G| · o_k ≤ |G| · |X|^k`                | no counterexample (now proved)                 |
| `o_1^k ≤ o_k`                                    | no counterexample (now proved; needs `X ≠ ∅`)  |
| `o_2 = 2` for transitive actions                 | **false**: `D_4` on 4 points is transitive with `o_2 = 3`. Rank 2 needs genuine 2-transitivity — the guarded version is `second_moment_eq_two_iff`. |

## 4. Boundary cases probed

* `X = ∅`, `k = 0`: `o_0 = 1` but `o_1 = 0`; hence the monotonicity theorem is stated for
  `k ≥ 1` and the growth theorem assumes `Nonempty X`.
* `G` trivial: the hierarchy degenerates to `o_k = |X|^k`, saturating the upper sandwich
  bound `orbitCount_le_card_pow`.
* `G` regular: saturates neither bound but gives `o_k = |G|^{k−1}` exactly.
