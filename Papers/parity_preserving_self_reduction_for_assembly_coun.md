# Computational Evidence — Parsimonious complementation for jigsaw assembly counting

All numbers below are kernel-checked by `decide +kernel` in
`Catalog/Algebra/JigsawParsimony/Experiments.lean` unless marked *(exploratory)*;
exploratory figures come from `#eval` runs on the same definitions and are **not** formally verified.

## Instance family

`puzzlesN n` = all framed puzzles on `n` sockets with exactly two clause pieces, each
clause piece a sublist of the `2n` literal inputs.  `|puzzlesN 2| = 256`,
`|puzzlesN 3| = 4096`.

## 1. Complementation preserves the exact count (counterexample hunt)

| n | puzzles | `count (compPuzzle P) = count P` for all | status |
|---|---------|-------------------------------------------|--------|
| 2 | 256     | yes                                       | kernel-checked (`puzzlesN_two_comp_count`) |
| 3 | 4096    | yes                                       | kernel-checked (`puzzlesN_three_comp_count`) |

No counterexample found — consistent with the general theorem `count_compPuzzle`.

## 2. Count histograms

n = 2 (kernel-checked, `puzzlesN_two_histogram`):

| count | 0 | 1 | 2 | 3 | 4 |
|-------|---|---|---|---|---|
| #puzzles | 35 | 24 | 88 | 60 | 49 |

Odd count: 84 / 256.

n = 3 *(exploratory)*:

| count | 0 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|-------|---|---|---|---|---|---|---|---|
| #puzzles | 133 | 72 | 96 | 630 | 192 | 1004 | 600 | 1369 |

Odd count: 888 / 4096.  Note: no two-clause puzzle on 3 sockets has count 1.

## 3. Self-duality and parity

n = 2: 88 puzzles have `assemblies (compPuzzle P) = assemblies P`; all 88 have even
count (kernel-checked, `puzzlesN_two_selfDual`).  n = 3 *(exploratory)*: 1522 self-dual puzzles.

## 4. Mask-symmetry orders (exploratory)

`|maskSymm P|` distribution (and `|maskSymm P|` divides `count P` in every case, as
`card_maskSymm_dvd_count` proves in general):

| n | order 1 | 2 | 4 | 8 |
|---|---------|---|---|---|
| 2 | 84 | 88 | 84 | – |
| 3 | 936 | 1076 | 582 | 1502 |

For n = 2 the 84 puzzles with trivial symmetry group are exactly as many as the 84
odd-count puzzles; for n = 3 they differ (936 vs 888), so "odd ⇔ no symmetry" fails;
only "odd ⇒ no symmetry" holds (`maskSymm_eq_bot_of_odd`).

## 5. Labelled (physical) counts

`xorPuzzle = (x₀ ∨ x₁) ∧ (¬x₀ ∨ ¬x₁)` on 3 sockets: `count = 4`, labelled count
`4 · 4! · 3! · 3! = 3456` (kernel-checked).  Mod-2 inclusion–exclusion terms:
`8 + 2 + 2 + 0 = 12 ≡ 4 (mod 2)` (kernel-checked).

## OEIS

The count sequences above are histograms of an ad hoc instance family; no OEIS search was performed
and none is claimed.
