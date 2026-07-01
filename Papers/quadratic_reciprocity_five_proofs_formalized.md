# Computational Evidence — Quadratic Reciprocity package

This note records the small-case checks performed before the formal proofs of the
two supplementary laws and of Zolotarev's permutation-sign identity.

## 1. Second supplementary law: `(2/p) = (-1)^((p²-1)/8)`

| p  | (2/p) | (-1)^((p²-1)/8) |
|----|-------|-----------------|
| 3  | -1    | -1              |
| 5  | -1    | -1              |
| 7  | +1    | +1              |
| 11 | -1    | -1              |
| 13 | -1    | -1              |
| 17 | +1    | +1              |
| 19 | -1    | -1              |
| 23 | +1    | +1              |

The sign flips exactly with the residue of `p` modulo 8 (`+1` for `p ≡ ±1`, `-1`
for `p ≡ ±3`), matching the exponent parity of `(p²-1)/8`. No discrepancy found.

## 2. First supplementary law: `(-1/p) = (-1)^((p-1)/2)`

| p  | (-1/p) | (-1)^((p-1)/2) |
|----|--------|----------------|
| 3  | -1     | -1             |
| 5  | +1     | +1             |
| 7  | -1     | -1             |
| 11 | -1     | -1             |
| 13 | +1     | +1             |
| 17 | +1     | +1             |
| 19 | -1     | -1             |
| 23 | -1     | -1             |

Sign is `+1` exactly when `p ≡ 1 (mod 4)`. No discrepancy found.

## 3. Zolotarev's lemma: `(a/p) = sign( x ↦ a·x )`

For `p = 7`, comparing the Legendre symbol against the sign of the permutation of
`ℤ/7ℤ` given by multiplication by `a`:

| a | (a/7) | sign(x ↦ a·x) |
|---|-------|----------------|
| 1 | +1    | +1             |
| 2 | +1    | +1             |
| 3 | -1    | -1             |
| 4 | +1    | +1             |
| 5 | -1    | -1             |
| 6 | -1    | -1             |

Perfect agreement: the quadratic residues `{1,2,4}` give even permutations and the
non-residues `{3,5,6}` give odd permutations. This is the empirical content of the
permutation-theoretic proof engine.

## Counterexample hunt

No counterexample was found for any of the three identities across the sampled
primes / residues. All three statements are subsequently proved unconditionally.

## OEIS note

The sign sequence of `(2/p)` over odd primes (`-1,-1,+1,-1,-1,+1,-1,+1,...`) tracks
`p mod 8 ∈ {1,7}` vs `{3,5}`, i.e. the classical `χ₈` character; the `(-1/p)`
sequence tracks the non-principal character mod 4 (`χ₄`).
