# Computational Evidence — Anti-Mathematics

## The Ackermann coding

We read a natural number `b` as a finite set: `a ∈ b` iff bit `a` of `b` is `1`
(`Nat.testBit b a`). Decoding the first few numbers:

| n | binary | members (as sets) |
|---|--------|-------------------|
| 0 | 000    | ∅                 |
| 1 | 001    | {0} = {∅}         |
| 2 | 010    | {1} = {{∅}}       |
| 3 | 011    | {0,1} = {∅,{∅}}   |
| 4 | 100    | {2}               |
| 5 | 101    | {0,2}             |
| 6 | 110    | {1,2}             |
| 7 | 111    | {0,1,2}           |

Computed in Lean via `(List.range b).filter (fun a => b.testBit a)`:
```
[(0, []), (1, [0]), (2, [1]), (3, [0,1]), (4, [2]), (5, [0,2]), (6, [1,2]), (7, [0,1,2])]
```
This is a bijection between `ℕ` and the hereditarily finite sets `HF`.

## Successor and the von Neumann numerals

`succ a = a ∪ {a} = a + 2^a` (bit `a` of `a` is always off, by `not_mem_self`).

```
succ 0 = 1,  succ 1 = 3,  succ 3 = 11
```

The numerals `∅, {∅}, {∅,{∅}}, …` have codes
```
numeral 0..4 = 0, 1, 3, 11, 2059,  2059 + 2^2059, …
```
governed by the recurrence `numeral (n+1) = numeral n + 2 ^ (numeral n)`. The
sequence grows super-exponentially; even `numeral 6` is astronomically large
(computation times out), which is exactly the intuition behind **anti-Infinity**:
the numerals are unbounded, so no single finite code `I` can contain them all.

## Counterexample hunt (Extensionality vs. Anti-Extensionality)

- In the *pure* Ackermann model, `Nat.eq_of_testBit_eq` guarantees no two distinct
  numbers have the same members: **Extensionality holds** — no counterexample.
- In the enriched universe `V = Option ℕ` of `NonExtensional.lean`, `some 0` and
  `none` both have empty member-set yet differ: a deliberate **counterexample to
  Extensionality**. The congruence test then fails: `some 0 ≈ none` but
  `some 0 ∈ some 1` while `none ∉ some 1` (since `1 = {0}`), witnessing that
  membership is not a congruence.

## Note on OEIS

No OEIS lookup was performed; the numeral code sequence `0,1,3,11,2059,…` is simply
the Ackermann coding of the finite von Neumann ordinals and is not needed for any
proof. The evidence here is purely a sanity check on the definitions that are then
proved in full generality in the Lean files.
