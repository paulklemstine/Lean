# Computational Evidence — HH₀ of a group algebra

We claim `HH₀(R[G]) ≃ R[Conj(G)]`. Over a field, this forces
`dim HH₀(R[G]) = (number of conjugacy classes of G)`.

## Small-case calculations

| G            | \|G\| | # conjugacy classes | predicted dim HH₀ |
|--------------|------:|--------------------:|------------------:|
| trivial `1`  | 1     | 1                   | 1                 |
| `C_n` (abelian) | n  | n                   | n                 |
| `S_3`        | 6     | 3                   | 3                 |
| `D_4`        | 8     | 5                   | 5                 |
| `Q_8`        | 8     | 5                   | 5                 |
| `S_4`        | 24    | 5                   | 5                 |
| `A_5`        | 60    | 5                   | 5                 |

For abelian `G`, the algebra `R[G]` is commutative, so every commutator `xy-yx`
vanishes and `HH₀(R[G]) = R[G]`, of rank `|G|`; and indeed every element is its
own conjugacy class, so `#Conj(G) = |G|`. This matches the table and is a clean
sanity check of the equivalence.

## Sequence appearance

The sequence of conjugacy-class counts of the symmetric groups `S_n`
(1, 2, 3, 5, 7, 11, 15, ...) is the partition-number sequence **OEIS A000041**,
since conjugacy classes of `S_n` correspond to integer partitions of `n`.
Thus `dim HH₀(K[S_n]) = p(n)`.

## Counterexample hunt

The universal claim is that the commutator submodule equals the kernel of the
"send `g` to its class" map. Potential failure mode: a kernel element not
expressible via commutators. The proof rules this out by the explicit
"representative collapse": modulo commutators every `single g r` equals
`single g₀ r` for the class representative `g₀`, and the kernel condition makes
the per-class totals vanish. No counterexample exists; the equivalence is proved
in `HochschildH0GroupAlgebra.lean` for *every* group `G` and commutative ring `R`
(finiteness is not required).

## Conclusion

All finite samples are consistent with `rank HH₀ = #Conj(G)`. The formal Lean
proof upgrades this evidence to a theorem valid for arbitrary `G` and `R`.
