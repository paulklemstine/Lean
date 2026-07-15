# Computational evidence: Boolean-cube increments in simplicial k-trees

For a recursive simplicial `k`-tree, begin with the full simplex on `k+1`
vertices and repeatedly attach a fresh vertex over a `k`-vertex face.  The tested
formula (including the empty face) is

\[
F(k,s)=2^{k+1}+s2^k=2^k(s+2),
\]

where `s` is the number of attached vertices.

## Small cases

| width `k` | attachment increment | `s=0` | `s=1` | `s=2` | `s=3` | `s=4` |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | 1 | 2 | 3 | 4 | 5 | 6 |
| 1 | 2 | 4 | 6 | 8 | 10 | 12 |
| 2 | 4 | 8 | 12 | 16 | 20 | 24 |
| 3 | 8 | 16 | 24 | 32 | 40 | 48 |
| 4 | 16 | 32 | 48 | 64 | 80 | 96 |

The increment is the cardinality of the powerset of the attaching face.  The
Lean theorem `card_coneFaces` verifies this bijectively, rather than by numerical
sampling, and `card_attach_cone` verifies that these faces are genuinely new.

## OEIS search

The increment sequence in `k`, `1, 2, 4, 8, 16, ...`, is OEIS A000079 (powers
of two).  For each fixed `k`, the face counts form an arithmetic progression, so
the two-parameter table is a scaled family rather than a new one-dimensional
sequence.

## Counterexample hunt

For `0 ≤ k ≤ 4` and `0 ≤ s ≤ 4`, every exact count above satisfies the proposed
bound

\[
F(k,s) \le 2^k(s+1)+(2^{k+1}-1).
\]

No counterexample occurs.  Symbolic subtraction gives constant slack `2^k-1`,
formally proved for all natural `k,s` by `proposed_bound_sub_exact`.  Thus the
search also suggests that the proposed bound is not sharp for the standard
recursive definition when the empty face is counted: the exact formula is
smaller by `2^k-1`.
