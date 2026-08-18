# Computational Evidence

All numbers below were produced by evaluating the *same* Lean definitions that the proofs
use (`ListCode.ball`, `ListCode.words`, `ListCode.parityCode`, `ListCode.hammingCode`),
so the tables are consistency checks on the formal statements, not independent scripts.
Every claim they support is separately proved in the `.lean` files (no `sorry`,
no `native_decide`).

## 1. Hamming ball volumes over `List Bool`

`(ball n r (zeroWord n)).card` for `n = 0..5`, `r = 0..3`:

| n \ r | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| 0 | 1 | 1 | 1 | 1 |
| 1 | 1 | 2 | 2 | 2 |
| 2 | 1 | 3 | 4 | 4 |
| 3 | 1 | 4 | 7 | 8 |
| 4 | 1 | 5 | 11 | 15 |
| 5 | 1 | 6 | 16 | 26 |

These are exactly the partial binomial sums `∑_{i ≤ r} C(n,i)` (row `n = 5`:
`1, 6, 16, 26`), which is the content of `ball_card`.  Note the saturation
`r ≥ n ⇒ |B_r| = 2^n` visible in rows 1–3, the degenerate regime the theorem must also
cover.

The partial-sum triangle read column-wise is the classical "cumulative Pascal" array;
row `r = 1` is `n + 1`, which is the divisor appearing in the perfect-code condition.

## 2. Cube sizes and the parity code

`(words n).card` for `n = 0..5`: `1, 2, 4, 8, 16, 32` — i.e. `2 ^ n` (`card_words`).

`(parityCode n).card` for `n = 0..4`: `1, 2, 4, 8, 16` — i.e. `2 ^ n`, matching
`parityCode_card` and the optimality statement `parityCode_optimal` (no length-`(n+1)`
code with minimum distance 2 exceeds `2 ^ n`).

## 3. Hamming codes

`(hammingCode k).card` for `k = 0,1,2,3`: `1, 1, 2, 16`.

* `k = 2` gives the length-3 repetition code `{000, 111}` — verified formally as
  `hammingCode_two_eq_repetitionCode3`.
* `k = 3` gives the classical `[7,4,3]` code, size `16 = 2 ^ 4`, and
  `16 · 8 = 128 = 2 ^ 7` (the perfect-code identity).
* Sphere check: `((words 7).filter (fun x => hdist x (zeroWord 7) ≤ 1)).card = 8`, so the
  16 balls contain `16 · 8 = 128` words in total — exactly the size of the cube, which is
  why packing forces tiling (`balls_tile_of_card_eq`).

## 4. Counterexample hunt

* **Triangle inequality without equal lengths.**  Taking `k = []` makes
  `hdist l k + hdist k m = 0` while `hdist l m` can be positive; hence every metric lemma
  in the development carries an explicit length hypothesis.  (This was found while the
  first version of `hdist_triangle` failed to elaborate.)
* **Minimum distance of the parity code.**  Searched for a pair of parity-extended words at
  distance exactly 2: `withParity (0 0…0)` and `withParity (1 0…0)` realise it
  (`withParity_dist_two_exists`), so the bound `2` of `withParity_min_dist` is sharp and the
  code provably cannot correct one error
  (`withParity_not_single_error_correcting`).
* **Perfect codes at non-Hamming lengths.**  For `n = 4` the identity `|C| · 5 = 16` has no
  solution in ℕ; formalised as `no_perfect_code_length_four`.  More generally the search for
  perfect single-error-correcting lengths returns exactly `n ∈ {0, 1, 3, 7, 15, …}`, i.e.
  `n + 1 ∈ {1, 2, 4, 8, 16, …}` — proved in both directions by
  `perfect_code_exists_iff_length_succ_pow_two`.

## 5. Sequences

The row `r = 1` of table 1 is `n + 1`; the row `r = 2` is `1 + n + C(n,2)`
(`1, 2, 4, 7, 11, 16`), the "lazy caterer" numbers (OEIS A000124), as expected from the
partial-binomial-sum formula.  The Hamming code sizes `2 ^ (2^k - 1 - k)`
(`1, 1, 2, 16, 2048, …`) grow doubly exponentially; only the first four were evaluated,
the general formula being a consequence of `hammingCode_card`.

## 6. Cycle 7 data: the extremal function `A(n,d)`

Every value in the table below is **formally proved** in
`Catalog/Computation/ExtensionPuncturing.lean`; the naming lemma is given in each cell, and
no unverified literature value is listed.

| entry | value | lemma |
|---|---|---|
| `A n 1` | `2 ^ n` | `A_one` |
| `A (n+1) 2` | `2 ^ n` | `A_two` |
| `A 7 3` | `16` | `A_seven_three` |
| `A 8 4` | `16` | `A_eight_four` |
| `A (2^k - 1) 3` | `\|hammingCode k\|` | `A_hamming` |
| `A (2^k) 4` | `\|hammingCode k\|` | `A_extended_hamming` |
| `A 4 3` | `≤ 3` | `A_four_three_le` |

The diagonal pattern `A(n,d) = A(n+1,d+1)` suggested by the first four rows
(`(n,1) → (n+1,2)` and `(7,3) → (8,4)`) only ever held at *odd* `d`.  The first failure is
the pair `A 3 2 = 4` (from `A_two`) against `A 4 3 ≤ 3` (from sphere packing, since
`∑_{i ≤ 1} C(4,i) = 5` and `4 · 5 = 20 > 16`); this is the counterexample that pinned the
hypothesis `Odd d` in `A_succ_succ_of_odd`, and it is itself formalised as
`A_four_three_lt_A_three_two`.  Puncturing, by contrast, needs no parity hypothesis
(`A_succ_le_A`), and iterating it gives `A_shift_le : A (n+j) (d+j) ≤ A n d`.
