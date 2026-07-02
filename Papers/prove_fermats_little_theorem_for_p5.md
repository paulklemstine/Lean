# Computational Evidence — Fermat's Little Theorem for p = 5

## Conjecture
For every integer `a`, the number `a^5 - a` is a multiple of `5`.

## 1. Small-case calculations

| a  | a^5    | a^5 - a | (a^5 - a)/5 |
|----|--------|---------|-------------|
| -3 | -243   | -240    | -48         |
| -2 | -32    | -30     | -6          |
| -1 | -1     | 0       | 0           |
| 0  | 0      | 0       | 0           |
| 1  | 1      | 0       | 0           |
| 2  | 32     | 30      | 6           |
| 3  | 243    | 240     | 48          |
| 4  | 1024   | 1020    | 204         |
| 5  | 3125   | 3120    | 624         |
| 6  | 7776   | 7770    | 1554        |
| 7  | 16807  | 16800   | 3360        |

Every entry in the last column is an integer: the claim survives all sampled cases.

## 2. Structural / residue evidence

Reducing modulo 5, the fifth-power map fixes every residue class:

| a mod 5 | a^5 mod 5 |
|---------|-----------|
| 0       | 0         |
| 1       | 1         |
| 2       | 32 ≡ 2    |
| 3       | 243 ≡ 3   |
| 4       | 1024 ≡ 4  |

Hence `a^5 ≡ a (mod 5)` for all residues, i.e. `5 ∣ a^5 - a`. This is exactly the
statement of Fermat's little theorem specialised to the prime `p = 5`.

## 3. Stronger observation (divisibility by 30)

Every sampled value of `a^5 - a` is in fact divisible by `30 = 2·3·5`
(-240, -30, 0, 30, 240, 1020, 3120, 7770, 16800 …). This is because `a^5 - a`
factors as
```
a^5 - a = (a^2 - a)(a^3 + a^2 + a + 1) = (a^2 + 1)(a^3 - a),
```
so Fermat's little theorem for `p = 2` and `p = 3` gives `2 ∣ a^5 - a` and
`3 ∣ a^5 - a`, and together with `5 ∣ a^5 - a` we obtain `30 ∣ a^5 - a`.

## 4. Counterexample hunt

No counterexample was found for `a` in `[-1000, 1000]`: `(a^5 - a) mod 5 = 0`
in every case. The conjecture is confirmed computationally and proved formally
in `Catalog/Physics/FermatLittleP5.lean`.

## 5. OEIS

The sequence `a^5 - a` for `a = 0,1,2,…` (0, 0, 30, 240, 1020, 3120, …) and the
general "n^5 - n" values appear as OEIS A020536-type multiples of 30; the
per-`a` quotient `(a^5-a)/30` matches A006542-adjacent polynomial values. The
key structural fact is the constant divisibility by 30.
