# Computational Evidence

The Lean development in `Logic/ProofSearchInformation.lean` rests on three
finite-combinatorial facts. Below are the small-case computations that motivate
them; each is subsumed by a fully proved general theorem in the file.

## 1. Counting short descriptions: `2^n - 1`

`ShortCode n = Σ k : Fin n, (Fin k → Bool)` is the set of binary strings of
length `< n`. Its cardinality is `∑_{k<n} 2^k = 2^n - 1`.

| n | strings of length `< n`                 | count | `2^n - 1` |
|---|-----------------------------------------|-------|-----------|
| 0 | (none)                                  | 0     | 0         |
| 1 | `""`                                    | 1     | 1         |
| 2 | `"", 0, 1`                              | 3     | 3         |
| 3 | `"", 0, 1, 00, 01, 10, 11`             | 7     | 7         |
| 4 | above + 8 length-3 strings              | 15    | 15        |

Sequence `0, 1, 3, 7, 15, 31, …` is **OEIS A000225** (`2^n - 1`, Mersenne
numbers). Proved as `card_ShortCode`.

## 2. Incompressibility gap: `2^n > 2^n - 1`

There are `2^n` messages of length `n` (`Bits n`, proved as `card_Bits`) but only
`2^n - 1` strictly shorter strings. Since `2^n > 2^n - 1` for every `n` (including
`n = 0`, where `1 > 0`), no injection `Bits n → ShortCode n` exists: at least one
message resists compression below its own length. Proved as
`no_universal_compression` / `exists_incompressible`.

## 3. Search space is exponential: `2^L ≤ 2^{L+1} - 1`

The number of candidate descriptions of length `≤ L` is `2^{L+1} - 1 ≥ 2^L`.

| L | candidates of length `≤ L` (`2^{L+1}-1`) | `2^L` |
|---|------------------------------------------|-------|
| 0 | 1                                        | 1     |
| 1 | 3                                        | 2     |
| 2 | 7                                        | 4     |
| 3 | 15                                       | 8     |

Exhaustive proof search over length-`≤ L` candidates therefore inspects
exponentially many objects. Proved as `search_space_exponential`.

## Counterexample hunt

The strengthened statements were checked before formalizing:
- `no_universal_compression` was tested for `n = 0` (a potential edge case): the
  1-element type `Bits 0` cannot inject into the empty type `ShortCode 0`, so the
  hypothesis `n ≥ 1` is unnecessary and was dropped from the final theorem.
- `compressible_le`'s bound `2^t - 1` is tight: the identity code on strings of
  length `< t` attains it, so it cannot be improved to `2^t - 2` or lower.

No counterexamples were found; all statements are proved with only the standard
axioms `propext, Classical.choice, Quot.sound`.
