# Computational Evidence — DIAL-OVERLAP-LAW (exp 462 / paper 133)

## 1. Small-case calculations (machine-checked in Lean)

All of the following are proved in `Catalog/Logic/DialOverlapLaw.lean` by kernel `decide`
or derived from the general law. None of them relies on `native_decide`.

| Compositum group | order | `I(T₁;T₂)` | type agreement | off-diagonal |
|---|---|---|---|---|
| `S₃ × S₃` (coprime) | 36 | 0 | 14/36 = 7/18 | 22/36 |
| `S₃ ×_{C₂} S₃` (shared quadratic subfield) | 18 | **1** | 14/18 = 7/9 | 4/18 = 2/9 |
| diagonal `S₃ ×_{S₃} S₃` (same field) | 6 | `2/3 + log₂3/2 ≈ 1.4591` | 6/6 | 0 |
| `C₄ ×_{C₂} C₄` (cyclic quartics, shared quadratic) | 8 | **1** = 3/2 − 1/2 | — | — |
| `S₃ ×_{C₂} S₃ ×_{C₂} S₃` (three dials) | 54 | each pair 1, TC = 2, co-info = +1 | — | — |

Joint table on `S₃ ×_{C₂} S₃` (out of 18): `111/111 : 1`, `111/3 : 2`, `3/111 : 2`, `3/3 : 4`, `12/12 : 9`.
The four cells that pair `12` with `111` or `3` are empty.
Split by the sign fibre: on `χ = −1` the types agree 9/9, and on `χ = +1` (which is `A₃ × A₃`) they agree 5/9 = (1/3)² + (2/3)².

## 2. Independent simulation (Python, ad hoc; not formally verified)

Primes 7 < p < 60000 that are unramified for both cubics. The splitting type of each prime comes from counting roots mod p, and the mutual information is the plug-in estimate.

| pair | n | MI (bits) | agreement | law |
|---|---|---|---|---|
| `x³−5x−5` & `x³−3x−5` (d = −7) | 6053 | 1.0000 | 0.7816 | 1, 7/9 = 0.7778 |
| `x³−6x−6` & `x³−3` (d = −3) | 6053 | 1.0000 | 0.7785 | 1, 0.7778 |
| `x³+x+1` & `x³−x−1` (coprime) | 6051 | 0.0001 | 0.3889 | 0, 7/18 = 0.3889 |
| `x³−5x−5` twice (same field) | 6053 | 1.4559 | 1.0000 | 1.4591, 1 |

Joint counts for d = −7: `329 : 664 : 658 : 1369 : 3033`. The 1:2:2:4:9 law predicts `336 : 673 : 673 : 1345 : 3027`.
Every cell that mixes `12` with another type has count 0.

## 3. OEIS
No integer sequence is involved: the law is an exact identity for each fibre product, so an OEIS search does not apply.

## 4. Counterexample hunt
- **Upper bound.** The ceiling `I ≤ log₂|C|` holds for *all* readouts (`mutInfo_fibreProd_le_logb_card`), so no pair over a shared quadratic field can exceed 1 bit.
- **Where equality fails.** If a readout does *not* determine the character, the value can fall below 1 bit. Example: the coarse readout "splits completely?" (see `S3.mutInfo_splitsCompletely_sign_lt_one` in `CharacterOneBit`). So the determination hypothesis cannot be dropped.
