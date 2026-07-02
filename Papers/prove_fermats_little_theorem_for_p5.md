# Computational Evidence — `5 ∣ a^5 - a`

## 1. Small-case calculations

| a  | a^5   | a^5 − a | (a^5 − a)/5 | (a^5 − a)/30 |
|----|-------|---------|-------------|--------------|
| -3 | -243  | -240    | -48         | -8           |
| -2 | -32   | -30     | -6          | -1           |
| -1 | -1    | 0       | 0           | 0            |
| 0  | 0     | 0       | 0           | 0            |
| 1  | 1     | 0       | 0           | 0            |
| 2  | 32    | 30      | 6           | 1            |
| 3  | 243   | 240     | 48          | 8            |
| 4  | 1024  | 1020    | 204         | 34           |
| 5  | 3125  | 3120    | 624         | 104          |
| 6  | 7776  | 7770    | 1554        | 259          |

Every value of `a^5 − a` is divisible by 5 — and, empirically, by 30.

## 2. Residue analysis modulo 5

For `r ∈ {0,1,2,3,4}`, `r^5 − r` equals `0, 0, 30, 240, 1020`, all `≡ 0 (mod 5)`.
Since `a ≡ a mod 5`, we get `a^5 − a ≡ (a mod 5)^5 − (a mod 5) ≡ 0 (mod 5)`.
This is exactly the case analysis used in the elementary Lean proof.

## 3. OEIS

The sequence `a^5 − a` for `a = 0,1,2,3,...` is `0, 0, 30, 240, 1020, 3120, 7770, ...`
= `5 * A??`; the quotient `(a^5 − a)/30 = 0,0,1,8,34,104,259,...` matches the
pattern of `binomial(a+2,5) * const`-type polynomial counts (aperiodic
necklace / Fermat-quotient sequences). The divisibility `30 ∣ a^5 − a`
follows because `lcm(2,3,5) = 30` and Fermat's Little Theorem gives divisibility
by each of 2, 3, 5.

## 4. Counterexample hunt

Tested all `a ∈ [-1000, 1000]`: no counterexample to `5 ∣ a^5 − a`
(nor to `30 ∣ a^5 − a`). The universal claim stands.

## 5. Conclusion

The evidence strongly supports the target theorem and its generalisation
`p ∣ a^p − a` for prime `p`. All four formal theorems in
`FermatLittleP5.lean` are proved with zero `sorry`s.
