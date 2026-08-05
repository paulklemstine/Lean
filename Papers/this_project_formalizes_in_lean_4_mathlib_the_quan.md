# Computational Evidence

All claims formalized this cycle concern families of mutually orthogonal Latin squares
(MOLS) over the coordinate/incidence framework of
`Catalog/Computation/PosetTheory/ReticulationMOLS.lean`.  Before formalizing, the
statements were tested on small orders.  Two kinds of evidence are reported: an ad-hoc
exploratory script (clearly marked as *not* machine-verified), and one kernel-checked Lean
computation.

## 1. Kernel-checked (Lean, `decide`)

`Catalog/Physics/OrthogonalNets/Order4Witness.lean` contains an explicit family of three
order-four squares (the `GF(4)` multiplication tables) and proves, by kernel evaluation
(`decide`) of the finite predicates,

* each of the three squares is Latin,
* the three are pairwise orthogonal,

hence `mols4 : MOLS 4 3`.  Combined with the ceiling `main_MOLS_bound` this yields the
verified statement `mols4_isGreatest : IsGreatest {k | Nonempty (MOLS 4 k)} 3`, i.e. the
maximum number of MOLS of order four is exactly three.  This is the smallest order where
the field construction is genuinely needed: over `ZMod 4` the table `a * i + j` is Latin
only for `a ∈ {1, 3}` (see §2), so the cyclic group does not supply three squares.

Order four also verifies, through `mols4_affinePlane` / `mols4_card_lines`, the affine
plane parameters `16` points, `20 = 4² + 4` lines, `4` points per line.

## 2. Exploratory script (NOT machine-verified)

A short Python script computed, for prime orders `n`, the affine family
`L_a(i, j) = a·i + j` with `a ∈ {1, …, n−1}` and checked directly:

| `n` | family size | all Latin | pairwise orthogonal | every pair of distinct cells on exactly one line | number of lines | `n² + n` |
|-----|-------------|-----------|---------------------|--------------------------------------------------|-----------------|----------|
| 2   | 1           | yes       | yes                 | yes                                              | 6               | 6        |
| 3   | 2           | yes       | yes                 | yes                                              | 12              | 12       |
| 5   | 4           | yes       | yes                 | yes                                              | 30              | 30       |
| 7   | 6           | yes       | yes                 | yes                                              | 56              | 56       |
| 11  | 10          | yes       | yes                 | yes                                              | 132             | 132      |

This is exactly the content later proved in general as `fieldSquare_isLatin`,
`fieldSquare_orthogonal`, `existsUnique_line_join` and `card_Line_saturated`.

**Displacement-permutation (pivot window) test.**  For `n = 5` and *every* pair of distinct
rows `i₁ ≠ i₂` and every column `j`, the displacements
`δ_s(j) = (row i₂ of s)⁻¹ (s(i₁, j))` were computed for all four family members.  In all
`5 · 4 · 5 = 100` windows the four values were pairwise distinct, none equalled `j`, and
together they exhausted the four columns different from `j` — zero failures.  This is the
computational shadow of `shift_ne_self`, `shift_ne_of_ne`, `pivot_window_bound` and
`shift_surjective_of_saturated`.

**Cyclic obstruction at `n = 4`.**  Over `ZMod 4` only the multipliers `a = 1, 3` give
Latin squares (`a = 2` is not injective on rows), so the cyclic recipe yields at most two
squares at order four, one short of the ceiling — motivating the field-theoretic
construction used in `FieldMOLS.lean`.

## 3. Sequence data

The sequence of maximal MOLS numbers `N(n)` is catalogued in OEIS as **A001438**.  Its
small known values are `N(2) = 1`, `N(3) = 2`, `N(4) = 3`, `N(5) = 4`, `N(6) = 1`,
`N(7) = 6`, `N(8) = 7`, `N(9) = 8`, while `N(10)` is only known to satisfy `2 ≤ N(10) ≤ 6`.
The results formalized here pin down the terms
at prime-power orders: `N(q) = q − 1` for every prime power `q` (`MOLS_sharp_of_field`,
`MOLS_sharp_prime`, `MOLS_sharp_prime_pow`), and the checked value `N(4) = 3`.  The
non-prime-power entries (`N(6) = 1`, the open value `N(10)`) are outside the reach of the present
argument and are left as conjectures in `FUTURE_DIRECTIONS.md`.
