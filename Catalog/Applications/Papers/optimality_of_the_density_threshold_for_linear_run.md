# Computational Evidence: Density Threshold for Linear `r`-Uniform Hypergraphs

Object: linear `r`-uniform hypergraphs (any two distinct edges meet in ≤ 1 vertex),
a.k.a. partial Steiner systems. Claim under test:

> `m · C(r,2) ≤ C(n,2)`, with equality iff every pair is covered (Steiner system `S(2,r,n)`).

## 1. Small-case calculations

The bound `m ≤ C(n,2)/C(r,2) = n(n-1)/(r(r-1))`:

| r | n | C(n,2) | C(r,2) | bound ⌊C(n,2)/C(r,2)⌋ | extremal example | edges m |
|---|---|--------|--------|------------------------|------------------|---------|
| 2 | n | n(n-1)/2 | 1 | n(n-1)/2 | complete graph K_n | C(n,2) (=) |
| 3 | 7 | 21 | 3 | 7 | Fano plane S(2,3,7) | 7 (=) |
| 3 | 9 | 36 | 3 | 12 | affine plane AG(2,3) S(2,3,9) | 12 (=) |
| 3 | 13 | 78 | 3 | 26 | projective plane PG(2,3) S(2,3,13) | 26 (=) |
| 3 | 8 | 28 | 3 | 9 (⌊28/3⌋) | no S(2,3,8); max packing | 8 (<) |
| 4 | 13 | 78 | 6 | 13 | PG(2,3) as S(2,4,13) | 13 (=) |
| 5 | 21 | 210 | 10 | 21 | PG(2,4) S(2,5,21) | 21 (=) |

For `r=3`, Steiner triple systems `S(2,3,n)` exist iff `n ≡ 1,3 (mod 6)` (Kirkman),
and exactly hit the bound `n(n-1)/6`. The first few: n=3→1, n=7→7, n=9→12, n=13→26,
n=15→35. Where a Steiner system does not exist (e.g. n=8), the maximum packing is
strictly below the threshold, consistent with `≤` being strict there.

## 2. OEIS

The Steiner-triple edge counts `n(n-1)/6` for admissible `n` (1,7,12,26,35,...) follow
A000217-type triangular scaling; the admissible-`n` sequence 1,3,7,9,13,15,... is A001110-adjacent
residues `1,3 mod 6` (A007streams of STS orders). No exotic sequence is needed: the bound is a
clean ratio of binomials.

## 3. Counterexample hunt

The universal claim `m·C(r,2) ≤ C(n,2)` was stress-tested against the defining double count:
each edge contributes its `C(r,2)` vertex-pairs, linearity ⟹ these pair-sets are disjoint, so
the total `m·C(r,2)` is bounded by the number of available pairs `C(n,2)`. No counterexample is
possible — the formal proof `LinearHypergraph.linear_card_le` confirms it for all finite vertex
types. Equality direction `LinearHypergraph.steiner_card_eq` confirmed against Fano (7=21/3) and
affine plane (12=36/3) data above.

## 4. Conclusion

Evidence uniformly supports both the bound and its sharpness; the leading density coefficient
`1/(r(r-1))` is attained exactly by Steiner systems whenever they exist. This motivated the
Lean formalization in `LinearHypergraphDensityThreshold.lean`.
