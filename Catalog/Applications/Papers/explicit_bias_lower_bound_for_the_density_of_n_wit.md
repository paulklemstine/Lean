# Computational Evidence: Cusick density `c_t = dens { n : s₂(n) ≤ s₂(n+t) }`

All values below were computed with the binary digit sum
`s₂(n) = (Nat.digits 2 n).sum` and the predicate `P_t(n) := s₂(n) ≤ s₂(n+t)`.
The Cusick predicate `P_t` is purely periodic with period `P = 2^{L + s₂(t)}`,
`L = (Nat.digits 2 t).length` (proved in general in `CusickPeriodicity.lean`), so
`c_t = (#good residues in [0,P)) / P`.  Periodicity was re-confirmed empirically by
checking `good t n == good t (n + P)` for `n < P·50` in every row.

## Exact densities (verified periods and good-residue counts)

| t  | binary | s₂(t) | L | period P | #good | c_t      | decimal |
|----|--------|-------|---|----------|-------|----------|---------|
| 1  | 1      | 1     | 1 | 4        | 3     | 3/4      | 0.7500  |
| 3  | 11     | 2     | 2 | 16       | 11    | 11/16    | 0.6875  |
| 5  | 101    | 2     | 3 | 32       | 20    | 5/8      | 0.6250  |
| 7  | 111    | 3     | 3 | 64       | 43    | 43/64    | 0.6719  |
| 9  | 1001   | 2     | 4 | 64       | 44    | 11/16    | 0.6875  |
| 11 | 1011   | 3     | 4 | 128      | 76    | 19/32    | 0.5938  |
| 13 | 1101   | 3     | 4 | 128      | 76    | 19/32    | 0.5938  |
| 17 | 10001  | 2     | 5 | 128      | 88    | 11/16    | 0.6875  |
| 19 | 10011  | 3     | 5 | 256      | 164   | 41/64    | 0.6406  |
| 21 | 10101  | 3     | 5 | 256      | 160   | 5/8      | 0.6250  |
| 25 | 11001  | 3     | 5 | 256      | 164   | 41/64    | 0.6406  |

Good residues for `t = 7` (period 64), 43 of them:
`{0,1,2,3,4,5,6,7,8,10,12,14,16,17,18,19,20,21,22,23,24,28,32,33,34,35,36,37,38,
39,40,42,44,46,48,49,50,51,52,53,54,55,56}`.

## Key observations driving the formalized results

1. **Density is not a function of `s₂(t)`.**  `s₂(3) = s₂(5) = 2` but
   `c_3 = 11/16 ≠ 5/8 = c_5`.  Formalized as
   `CusickShiftFive.cusick_density_not_s2_function`.

2. **First `s₂(t) = 3` exact value.**  `c_7 = 43/64`, extending the catalog from
   the `s₂ = 1,2` regimes.  Formalized as `CusickShiftSeven.cusickCount_seven`.

3. **Bit-reversal symmetry (conjectural).**  `c_11 = c_13 = 19/32` (`1011`↔`1101`)
   and `c_19 = c_25 = 41/64` (`10011`↔`11001`).  See `FUTURE_DIRECTIONS.md`.

4. **Gap-separation limit (conjectural).**  For `t = 2^k + 1`: `c_5 = 5/8` (k=2)
   but `c_9 = c_17 = 11/16` (k≥3) — well-separated 1-bits decouple.

5. **Extremality of all-ones (conjectural).**  Among `s₂(t) = 3` shifts sampled,
   `c_7 = 43/64` is the largest, suggesting `t = 2^s − 1` maximizes `c_t` at fixed
   `s₂(t) = s`.

6. **Every value clears the DKS bound `1/2 + 2^{-(2 s₂(t)+1)}`** with room to
   spare (smallest margin in the table is `c_11 = 19/32` vs `17/32`, margin `2/32`).

## Reproduction

```lean
import Mathlib
open Finset
def s2 (n : Nat) : Nat := (Nat.digits 2 n).sum
def good (t n : Nat) : Bool := decide (s2 n ≤ s2 (n+t))
#eval ((List.range 64).filter (fun r => good 7 r)).length          -- 43
#eval (List.range 3200).all (fun n => good 7 n == good 7 (n+64))   -- true
```
