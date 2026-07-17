# Computational evidence

## Small-case calculations

The formal development uses the family

| odd `n` | order `2n` | cyclic exponent | dihedral exponent | cyclic commutative? | dihedral commutative? |
|---:|---:|---:|---:|:---:|:---:|
| 3 | 6 | 6 | 6 | yes | no |
| 5 | 10 | 10 | 10 | yes | no |
| 7 | 14 | 14 | 14 | yes | no |
| 9 | 18 | 18 | 18 | yes | no |
| 11 | 22 | 22 | 22 | yes | no |

For a cyclic group of order `2n`, the exponent is `2n`. For a dihedral group of order `2n`, the exponent is `lcm(n,2)`, which equals `2n` when `n` is odd. The Lean theorem proves this uniformly rather than relying on the table.

At the first case, order six, `C₆` has two automorphisms (`φ(6)=2`). Its center is the entire group, while the center of `D₆` is trivial.

## OEIS search

No OEIS search is relevant: the central claim compares structural invariants of two explicit infinite families and does not introduce a new integer sequence.

## Counterexample hunt

The candidate universal heuristic was that coarse shared coordinates might predict structural behavior. The smallest tested pair already fails:

- `C₆` and `D₆` both have order 6;
- both have exponent 6;
- `C₆` is cyclic and commutative;
- `D₆` is noncyclic and noncommutative.

The failure persists for every odd `n > 1`, as formally proved. No counterexample exists to this proved family statement under its hypotheses.

## Scope

These calculations do not constitute a census of groups of order at most 100. They isolate and verify a precise obstruction to the proposed predictive organization: even order plus exponent does not determine basic group structure.
