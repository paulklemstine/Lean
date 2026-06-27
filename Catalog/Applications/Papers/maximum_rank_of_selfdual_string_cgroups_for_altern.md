# Computational Evidence — Self-dual string C-groups for `A_{4m+3}`

This note records the small-case evidence motivating the formalized theorems in
`Foundations.lean` and `RankArithmetic.lean`.

## 1. The numeric rank gap `⌊(n-1)/2⌋` vs. the self-dual maximum `2m`

For `n = 4m+3` the general maximal rank of a string C-group of `A_n` is
`⌊(n-1)/2⌋`. The self-dual maximum (conjectured) is `2m`.

| m | n = 4m+3 | ⌊(n-1)/2⌋ = 2m+1 | self-dual max 2m | gap |
|---|----------|------------------|------------------|-----|
| 3 | 15       | 7                | 6                | 1   |
| 4 | 19       | 9                | 8                | 1   |
| 5 | 23       | 11               | 10               | 1   |
| 6 | 27       | 13               | 12               | 1   |
| 7 | 31       | 15               | 14               | 1   |

The gap is *constantly 1*. Formalized as `general_max_rank` and
`selfDual_rank_gap` (both discharged by `omega`).

## 2. Schläfli length parity at the excluded rank

A rank-`r` representation has a Schläfli symbol of length `r - 1`.

| candidate rank r | Schläfli length r-1 | parity |
|------------------|---------------------|--------|
| 2m   (achieved)  | 2m-1                | odd    |
| 2m+1 (excluded)  | 2m                  | even   |

The achieved self-dual rank `2m` has **odd** Schläfli length (a reversal-fixed
centre exists); the excluded rank `2m+1` has **even** Schläfli length (no
reversal-fixed centre). This is the parity obstruction, formalized as
`rev_no_fixed_of_even`, `rev_unique_fixed_of_odd`, and `palindrome_even_paired`.

## 3. Reversal fixed points of `Fin L` (counterexample hunt)

We searched for fixed points `Fin.rev i = i` over `Fin L`:

| L | fixed points of rev | matches parity claim? |
|---|---------------------|-----------------------|
| 2 | none                | ✔ (even ⇒ none)       |
| 3 | {1}                 | ✔ (odd ⇒ unique)      |
| 4 | none                | ✔                     |
| 5 | {2}                 | ✔                     |
| 6 | none                | ✔                     |
| 7 | {3}                 | ✔                     |

No counterexample to "even length ⇒ no fixed point" was found; this is exactly
`rev_no_fixed_of_even`. (The identity `rev i = L-1-i` makes a fixed point require
`2i = L-1`, solvable iff `L` is odd.)

## 4. The doubling construction (achievability)

The vertex-gluing / doubling map `σ ↦ σ ⊕ σ ⊕ 1` sends `Sym(2m+1)` into
`Sym(4m+3)`. Its image is always **even** because the sign of `σ ⊕ σ ⊕ 1` is
`sign σ · sign σ · 1 = (sign σ)² = +1`. Hence it lands in `A_{4m+3}`, and pushing
the self-dual rank-`2m` simplex through it yields a self-dual rank-`2m`
representation of `A_{4m+3}` for every `m`. Formalized **unconditionally** as
`A4m3_selfDual_rank2m` (with `dblPerm_sign`).

## OEIS

The self-dual maximal rank sequence `2m` for `n = 4m+3` (n = 15, 19, 23, …) is
`6, 8, 10, 12, …` (A005843 even numbers ≥ 6); the general maximum `2m+1` is
`7, 9, 11, 13, …` (odd numbers ≥ 7). No specialized OEIS entry is needed; these
are linear in `m`, consistent with the `omega`-provable identities above.
