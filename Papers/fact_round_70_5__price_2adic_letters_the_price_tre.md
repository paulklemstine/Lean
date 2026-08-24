# Computational evidence — PRICE-2ADIC-LETTERS / GAUSS-IS-RESIDUE-DIAL

All numbers below were produced by direct enumeration before the Lean proofs were
written; every claim they support is now a theorem in `Catalog/Cryptography/Price2Adic/`
(so the evidence is a sanity check, not the warrant).

## 1. The construction: Price tree on Euclid parameters

Moves on parameter pairs `(m,n)` (root `(2,1)`, triple `(m²-n², 2mn, m²+n²)`):

```
A : (m,n) ↦ (m+n, 2n)      B : (m,n) ↦ (2m, m-n)      C : (m,n) ↦ (2m, m+n)
```

Root children: `(3,2) → (5,12,13)`, `(4,1) → (15,8,17)`, `(4,3) → (7,24,25)`.
This identifies the tree as Price's, not Berggren's (whose root children are
`(5,12,13)`, `(21,20,29)`, `(15,8,17)`).
Formal counterpart: `Price2Adic.triple_children_root`.

| check | result |
|---|---|
| BFS to depth 8 | 9841 nodes = (3⁹−1)/2, **0 duplicates** |
| BFS pruned at `c ≤ 5000` (max depth reached 9) | 792 nodes |
| brute force: all primitive `(m,n)` with `m²+n² ≤ 5000` | 792 pairs |
| tree vs brute force | **0 missing, 0 extra** |

Formal counterparts: `Price2Adic.existsUnique_word` (no duplicates *and* no gaps, for
all triples, not just `c ≤ 5000`), `Price2Adic.evalEquiv`.

## 2. Letter laws (positions counted from the leaf, `N` = odd leg `m²-n²`)

Smallest modulus `2^k` of `N` that classifies "letter at position `j` is `A`", over the
9841 nodes of depth ≤ 8:

| position `j` | smallest classifying modulus |
|---|---|
| 1 | `N mod 4` |
| 2 | `N mod 8` |
| 3 | none with `k ≤ 10` |
| 4 | none with `k ≤ 10` |
| 5 | none with `k ≤ 10` |

`N mod 2` is constant (`N` odd) — vacuous. Dictionary at `N mod 16` (last two letters):

```
1, 9 ↦ AA      3, 11 ↦ A{B,C}      5, 13 ↦ {B,C}A      7, 15 ↦ {B,C}{B,C}
```

Violations of the two laws over all 9841 nodes: **0** and **0**.
Formal counterparts: `letter_pos0_iff`, `letter_pos1_iff`, `letter_pos0_pos1_table`,
`oddLeg_odd`.

## 3. Why positions ≥ 3 fail: the `B`/`C` bit is 2-adically invisible

For `(m,n) = (2^k+1, 2^k)` the `B`- and `C`-children have triples differing by `4mn`
(odd leg, hypotenuse) and `8mn` (even leg), both divisible by `2^k`. Example `k = 6`:

```
B-child (16899, 260, 16901)     C-child (259, 33540, 33541)      agree mod 2^6 : True
```

Formal counterpart: `twoAdic_blind_BC` (all `k`, all three entries).

## 4. The trailing-`A` run

For every one of the 9841 nodes: trailing-`A` count `= v₂(n)` and, whenever the odd leg
is `1 mod 4`, `= v₂(b) − 1` (`0` otherwise). Violations: **0**.
Formal counterparts: `trailingA_eq_padicValNat`, `trailingA_from_triple`.

## 5. Depth bounds (the `dP` law)

Over all 9841 nodes, `2·depth + 3 ≤ m+n ≤ 3^(depth+1)` held with no exception; so the
depth is squeezed between `log₃(m+n) − 1` and `(m+n−3)/2`. This is the shape of the
empirical "`dP` ~ slope on `log₂(p+q)`" law, and it is what makes the Price tree
qualitatively different from a tree whose individual nodes need thousands of steps.
Formal counterpart: `depth_squeeze`.

## 6. Gauss magnitudes

The quadratic Gauss sum over `ZMod p` satisfies `g² = ±p` with the sign given by
`p mod 4`, so `‖g‖ = √p` for every primitive additive character and every twist by a
unit: the magnitude separates no residue class from any other. No numerical search was
needed beyond the classical closed form; the Lean file proves the closed form
(`gaussSum_sq_eq`), the constancy of the magnitude across twists
(`norm_gaussSum_mulShift`), and the consequence in the residue-dial cost model
(`gaussMagnitude_dial_speedup_eq_one`: speedup exactly `1`, i.e. zero bits, strictly
under the `4/3` cap of `ResidueDial.dialSpeedup_le_four_thirds`).

## 7. OEIS

The node counts by depth are `1, 3, 9, 27, …` (powers of three, A000244) — a
consequence of `evalEquiv`, not an independent observation. No other new integer
sequence arose.
