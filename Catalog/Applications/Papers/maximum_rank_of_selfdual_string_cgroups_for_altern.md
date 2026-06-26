# Computational Evidence: self-dual string C-groups of `A_{4m+3}`

This note records the small-case evidence that motivated the formalized results in
`Basic.lean`, `Palindrome.lean`, and `RankBound.lean`.

## 1. The rank table for `n = 4m+3`

Let `n = 4m+3`. The established overall maximum rank of a string C-group
representation of `A_n` is `⌊(n-1)/2⌋`. The mission claims the maximum rank of a
**self-dual** string C-group is `2m`, one below the overall maximum `2m+1`.

| m | n = 4m+3 | overall max ⌊(n-1)/2⌋ | claimed self-dual max 2m | gap |
|---|----------|------------------------|---------------------------|-----|
| 3 | 15       | 7                      | 6                         | 1   |
| 4 | 19       | 9                      | 8                         | 1   |
| 5 | 23       | 11                     | 10                        | 1   |
| 6 | 27       | 13                     | 12                        | 1   |
| 7 | 31       | 15                     | 14                        | 1   |

The columns "overall max = 2m+1" and "self-dual max = 2m" are exactly the content
formalized (and machine-checked) in `selfDual_rank_one_below_overall_max`.

OEIS: the overall-maximum sequence `⌊(n-1)/2⌋` is the standard "integers repeated"
sequence A004526 (offset). No new sequence is introduced; the interest is the
*gap of exactly 1* between the self-dual and overall ceilings, restricted to the
residue class `n ≡ 3 (mod 4)`.

## 2. Schläfli palindrome check (small ranks)

For the simplex `{3, 3, …, 3}` of rank `r` (adjacent transpositions in `S_{r+1}`),
the Schläfli symbol is the constant sequence `(3, …, 3)`, which is trivially
palindromic, consistent with `schlafli_palindrome`. Self-duality is realized by
conjugation by the longest element (the reversal permutation `Fin.revPerm`), checked
in `simplex_selfDual` for all `r`.

Sanity checks (rank, generators, self-dual witness):
- r = 1: `S_2 = ⟨(0 1)⟩`, palindrome `()`, self-dual (trivially).
- r = 2: `S_3`, Schläfli `(3)`, self-dual; the dual reverses the single edge.
- r = 3: `S_4`, Schläfli `(3,3)`, palindrome; reversal swaps the two edges.

## 3. Counterexample hunt

We searched for the *converse* of `schlafli_palindrome` (palindromic Schläfli ⇒
self-dual). It fails in general: a palindromic diagram does **not** force the
existence of a group automorphism intertwining `ρ i` with `ρ (rev i)` inside a
fixed group, because such an automorphism is extra data. This is why the formalized
result proves only the (correct) forward direction.

No counterexample was found to the forward palindrome implication or to the
arithmetic gap identity; both are now machine-checked.

## 4. Scope note

The deep statement — that `A_{4m+3}` admits **no** self-dual string C-group of rank
`2m+1` — depends on CPR-graph / permutation-parity arguments not yet available in
Mathlib, and is left as the delimited open core (see `FUTURE_DIRECTIONS.md`). The
realizability lower bound over symmetric groups (`symmetricGroup_selfDual_rank`) and
the exact numeric gap are fully formalized.
