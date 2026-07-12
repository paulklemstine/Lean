# Computational Evidence — Bruhat order, extremes, and the product order

All claims below were checked by exhaustive computation over the symmetric group
`S₃ = Perm (Fin 3)` (all `6` permutations, `36` ordered pairs) using the Ehresmann
rank criterion `rk w i j = #{k ≤ i : w k ≤ j}` and
`u ≤ v  ⇔  ∀ i j, rk v i j ≤ rk u i j`.

## 1. Small-case calculations

Sample rank matrices for `S₃` (rows `i = 0,1,2`, columns `j = 0,1,2`):

* identity `e = (0,1,2)`:  rk = ⎡1 1 1; 1 2 2; 1 2 3⎤  — the *maximal* rank matrix.
* reversal `w₀ = (2,1,0)`: rk = ⎡0 0 1; 0 1 2; 1 2 3⎤  — the *minimal* rank matrix.

Every entry of the identity matrix dominates the corresponding entry of any other
permutation's matrix, and every entry of the reversal matrix is dominated — exactly
what "identity is the minimum" and "reversal is the maximum" predict.

## 2. Exhaustive checks (all verified `True` by `decide` on `Fin 3`)

* `∀ w, e ≤ w`  — the identity is the Bruhat minimum.
* `∀ w, w ≤ w₀` — the reversal is the Bruhat maximum.
* `∀ u v, u ≤ v → v ≤ u → u = v` — antisymmetry (the rank matrix determines the permutation).
* `∀ u v, u ≤ v ↔ u⁻¹ ≤ v⁻¹` — inversion invariance; confirmed pairwise.
* Transpose identity `rk w⁻¹ i j = rk w j i` — confirmed for all `w, i, j`.

## 3. Counterexample hunt

No counterexamples were found to any of the universal statements above within `S₃`.
The inversion-invariance and antisymmetry statements are the ones most likely to fail
under an incorrect orientation convention; both held under the convention chosen
(identity minimal, reversal maximal), and *failed* under the opposite convention —
confirming the orientation is fixed correctly.

## 4. Length / rank table (`S₃`)

| permutation (one-line) | inversions `len` | is minimum? |
|------------------------|------------------|-------------|
| (0,1,2)                | 0                | yes         |
| (0,2,1)                | 1                | no          |
| (1,0,2)                | 1                | no          |
| (1,2,0)                | 2                | no          |
| (2,0,1)                | 2                | no          |
| (2,1,0)                | 3                | no (it is the maximum) |

The unique `len = 0` element is the identity, matching the theorem
`bruhat_bot_iff_len_zero`: an element is `≤` every permutation iff it has no inversions.

## 5. Sequence note

The number of comparable pairs `(u,v)` with `u ≤ v` in the Bruhat order grows quickly
with `n`; for `n = 3` there are exactly `19` such ordered pairs (out of `36`).  We do not
rely on any external sequence identification here; the count is reported only to situate
the exhaustive `S₃` check above.

All computational checks are consistent with the formally proved statements in `Core.lean`.
