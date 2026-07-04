# Computational Evidence — Escher Staircases

An *Escher staircase* is an infinite strictly ascending chain of ideals
`I 0 < I 1 < I 2 < ⋯`.  We collect small-case evidence for the three claims we
formalize.

## 1. The concrete staircase in `ℕ → ℤ`

Rungs: `S n = { f : ℕ → ℤ | ∀ k ≥ n, f k = 0 }`.

| n | typical element of `S n \ S (n-1)` | `S n` contains |
|---|-----------------------------------|----------------|
| 0 | (none — `S 0 = {0}`)              | only `0`       |
| 1 | `(1,0,0,0,…)`                     | seqs supported on `{0}` |
| 2 | `(0,1,0,0,…)`                     | seqs supported on `{0,1}` |
| 3 | `(0,0,1,0,…)`                     | seqs supported on `{0,1,2}` |

* Strictness: the indicator `δ_n = Pi.single n 1` lies in `S (n+1)` (it vanishes
  from index `n+1` on) but not in `S n` (since `δ_n n = 1 ≠ 0`).  Hence
  `S n ⊊ S (n+1)` for every `n`.
* Loop-back: `⨅_n S n = S 0 = {0}`.  Membership in `S 0` already forces `f k = 0`
  for all `k ≥ 0`, i.e. `f = 0`.  So the meet of the whole ascending chain is its
  bottom rung — the "impossible staircase" picture.

Conclusion: `ℕ → ℤ` carries an explicit Escher staircase, so it is **not**
Noetherian.

## 2. Sanity check on the informal description's chain

The mission's informal chain `I_n = { f ∈ Int(ℤ) | f(ℤ) ⊆ 2ⁿℤ }` is claimed to be
*ascending*.  But `2^{n+1}ℤ ⊆ 2ⁿℤ`, so `I_{n+1} ⊆ I_n`: the chain is in fact
**descending**.  The write-up has the inclusion reversed.  Our `ℕ → ℤ` construction
repairs this: it is genuinely ascending and still exhibits the `{0}`-intersection
"loop back".

## 3. The negative instance `ℤ_[p]`

`ℤ_[p]` is a discrete valuation ring: every nonzero ideal is `pⁿ ℤ_[p]` for some
`n`, and the ideals are totally ordered by reverse inclusion
`ℤ_[p] ⊋ pℤ_[p] ⊋ p²ℤ_[p] ⊋ ⋯ ⊋ (0)`.  There is no room for an *infinite ascending*
chain: any ascending chain of the `pⁿ` stabilises.  Hence `ℤ_[p]` has **no** Escher
staircase.  This matches the general principle (verified formally): a ring has an
Escher staircase iff it is not Noetherian, and `ℤ_[p]` (a PID) is Noetherian.

## OEIS
No integer sequence is central to these order-theoretic claims, so no OEIS lookup
applies.
