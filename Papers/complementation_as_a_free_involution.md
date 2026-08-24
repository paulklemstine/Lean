# Computational evidence — complementation as a free involution

All numbers below were produced by `#eval` inside the Lean files listed, and
every one of them is additionally *proved* by a `decide`-based theorem in the
same file (finite enumeration checked by the kernel), so nothing here rests on
an unchecked script.

## 1. Small-case assembly counts (Boolean tab–blank case)

Framed puzzles on `n` variables; `S(P)` is the assembly space, `P^c` the global
tab–blank complement, `U(P) = S(P) ∪ S(P^c)` the *untagged* combined space.

| puzzle | `n` | `|S(P)|` | `|S(P^c)|` | `|U(P)|` | gauge (#orbits) | self-dual? |
|---|---|---|---|---|---|---|
| `P₁ = (x₀) ∧ (x₁)` | 2 | 1 | 1 | 2 | 1 | no |
| `P₂ = (x₀ ∨ ¬x₀)` | 2 | 4 | 4 | 4 | 2 | yes (as spaces) |
| `puzzleOfList [(⊤,⊤)]` | 2 | 3 | 3 | 4 | 2 | no |
| empty puzzle | 0 | 1 | 1 | **1** | – | yes (vacuously) |

Source: `Catalog/Novelty/JigsawComplementFreeAction.lean` (Part 9),
`Catalog/Novelty/JigsawComplementOrbitStructure.lean` (Part 4),
`Catalog/Novelty/JigsawAssemblySpectrum.lean` (Part 4).

Observations:

* `|S(P)|` is frequently **odd** (rows 1 and 3), so no parity statement about a
  single assembly space can hold.
* `|U(P)|` is even in every row with `n ≥ 1`, including the *self-dual* row 2.
  Self-duality therefore does not obstruct evenness — contradicting the
  hypothesis of the original conjecture.
* The single odd combined count occurs at `n = 0`, where complementation of
  assemblies is the identity.  This located the true boundary.

## 2. Counterexample hunt against the conjectured hypothesis

The conjecture states that *non-self-duality* is what forces freeness.  Row 2
above is a counterexample to the necessity of that hypothesis: `P₂` has
`S(P₂^c) = S(P₂)` yet complementation is still fixed-point free, and
`|S(P₂)| = 4` is even.  The formal statement is
`JigsawFreeComplement.selfDual_card_even`, with the concrete instance
`P₂_selfDual`, `P₂_card`.

Conversely, the search for a genuine fixed configuration terminated with exactly
one: the empty assembly on `n = 0` variables
(`zeroVar_compAssign_fixed`, `zeroVar_union_card_odd`).

## 3. Ternary interlock depths

Replacing tab/blank by `d` mill depths (`ZMod d`), with `Q = (x₀ = 1) ∧ (x₁ = 2)`
over `d = 3`, `n = 2`:

| quantity | value |
|---|---|
| `|S(Q)|` | 1 |
| `|S(shift 1 Q)|` | 1 |
| combined over all 3 shifts | 3 |
| depth gauge (#orbits) | 1 |

The combined count is divisible by `3`, not merely even — evidence for the
divisibility generalisation proved as
`JigsawCyclicSymmetry.combined_card_dvd`.  Source:
`Catalog/Novelty/JigsawCyclicSymmetry.lean` (Part 6), theorem `Q_counts`.

## 4. Spectra

For `n` variables the enumerated data are consistent with, and are now proved
to satisfy:

* single-puzzle counts range over all of `0 … 2^n` (`assembly_spectrum`);
* combined counts range over exactly the even numbers `0, 2, 4, …, 2^n`
  (`combined_spectrum_iff`).

For `n = 2` this predicts combined counts `{0, 2, 4}`; the table in §1 realises
`2` and `4`, and `0` is realised by any unsatisfiable puzzle.

## 5. Counting self-dual assembly spaces

| `n` | complement-stable subsets | all subsets |
|---|---|---|
| 1 | 2 | 4 |
| 2 | 4 | 16 |

Both rows match the closed form `2^(2^(n-1))` proved as
`JigsawFreeComplement.card_stableSpaces`, and exhibit the square-root law
`card_stableSpaces_sq` (`2² = 4`, `4² = 16`).  Source:
`Catalog/Novelty/JigsawSelfDualDensity.lean` (Part 3), theorem
`small_stable_counts`.

## 6. OEIS

The counting sequences appearing here are the elementary `2^n` (cube size,
A000079) and `2^(n-1)` (number of free complementation orbits of the whole cube,
A011782/A000079 shifted).  No further sequence search was warranted: the
quantities studied are cardinalities of arbitrary subsets of the cube, which by
`assemblySet_puzzleOfSet` are unconstrained apart from the parity law proved
here.
