# Computational evidence — kernel patterns

All numbers below were produced by `#eval` inside the Lean development itself
(`Catalog/Algebra/KernelPatterns/*`), so the code that produced them is the same code the
theorems are stated about.  Every claim that appears as a *theorem* in the project is
proved; the tables here are the exploratory data that guided the formalisation.

## 1. Counting equality patterns

`Pattern n` is the type of idempotent contracting retractions `p : Fin n → Fin n`
(`p i ≤ i`, `p (p i) = p i`), i.e. the canonical forms `canon x` of the equality patterns
of tuples `x : Fin n → α`.

```
#eval (List.range 7).map (fun n => Fintype.card (Pattern n))
-- [1, 1, 2, 5, 15, 52, 203]
#eval (List.range 7).map Nat.bell
-- [1, 1, 2, 5, 15, 52, 203]
```

**OEIS**: `1, 1, 2, 5, 15, 52, 203` is A000110 (Bell numbers).  Values `n ≤ 5` are proved
in Lean by `decide` (`card_pattern_zero … card_pattern_five`, `bell_values`), and the
general identity `Fintype.card (Pattern n) = Nat.bell n` is proved for all `n`
(`card_pattern`), via `numSetoid_eq_bell` — the statement Mathlib records as a TODO for
`Nat.bell`.

## 2. Refinement by the number of blocks

`numBlocks p` is the size of the image of `p`.

```
#eval (List.range 6).map (fun n => (List.range 6).map (stirling2 n))
-- [[1, 0, 0, 0, 0, 0],
--  [0, 1, 0, 0, 0, 0],
--  [0, 1, 1, 0, 0, 0],
--  [0, 1, 3, 1, 0, 0],
--  [0, 1, 7, 6, 1, 0],
--  [0, 1, 15, 25, 10, 1]]
#eval (List.range 6).map (fun n =>
  (List.range 6).map (fun k => (univ.filter (fun p : Pattern n => numBlocks p = k)).card))
-- identical table
#eval (List.range 6).map (fun n => ((List.range (n+1)).map (stirling2 n)).sum)
-- [1, 1, 2, 5, 15, 52]     (row sums = Bell numbers)
```

**OEIS**: the triangle is A008277 (Stirling numbers of the second kind); the row sums are
again A000110.  Both observations are theorems here: `numPat_eq_stirling2` and
`sum_stirling2_eq_bell`.

## 3. Orbit counts over small alphabets (counterexample hunt)

The naive guess "the number of `Equiv.Perm α`-orbits on `n`-tuples is `Nat.bell n`" fails
as soon as the alphabet is too small; the table below lists the orbit counts (equivalently
the number of patterns with at most `|α|` blocks) for `|α| = 0, 1, 2, 3, 4` and
`n = 0, …, 5`.

```
#eval (List.range 5).map (fun a => (List.range 6).map (fun n =>
  (univ.filter (fun p : Pattern n => numBlocks p ≤ a)).card))
-- |α| = 0 : [1, 0, 0, 0, 0,  0]
-- |α| = 1 : [1, 1, 1, 1, 1,  1]
-- |α| = 2 : [1, 1, 2, 4, 8, 16]
-- |α| = 3 : [1, 1, 2, 5, 14, 41]
-- |α| = 4 : [1, 1, 2, 5, 15, 51]
```

Read off:

* the first counterexample to the naive guess is `|α| = 2, n = 3`: `4 < 5 = Nat.bell 3`
  (theorem `orbits_binary_three` and `orbits_binary_three_lt_bell`);
* the `|α| = 2` row is `1, 1, 2, 4, 8, 16`, i.e. `2 ^ (n-1)`; this suggested — and is now
  proved as — `card_orbits_binary`, and `card_orbits_binary_lt_bell` shows the gap to the
  Bell number persists for every `n ≥ 3`;
* the general shape of the table (truncated Stirling rows) is the theorem
  `card_orbits_eq_sum_stirling2`, and the entries agree with `∑_{k ≤ |α|} S(n,k)`.

## 4. Kernel-completeness spot checks

For `n ≤ |α|` every pattern is realised, so the orbit count equals `Nat.bell n`
(`card_orbits_eq_bell`, e.g. `orbits_fin_five : … = 52`).  Over the infinite alphabet `ℕ`
the completeness statement is also exercised concretely:
`exists_perm_nat_example` produces a permutation of `ℕ` carrying `(0,0,1)` to `(5,5,7)`.

## 5. Status of the evidence

Every table above is reproducible by re-running the quoted `#eval` commands against the
project files.  The finite checks that back a mathematical claim have been redone as Lean
theorems using `decide` (kernel reduction, no `native_decide` anywhere in the project),
and the general statements are proved for all `n`.
