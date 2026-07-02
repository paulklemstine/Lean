# Computational Evidence — Pythagorean divisibility & realizability

## 1. Triple divisibility (small cases)

For triples `a² + b² = c²`, entrywise products `a·b` and `a·b·c`:

| triple        | a·b  | a·b / 12 | a·b·c | a·b·c / 60 |
|---------------|------|----------|-------|------------|
| (3, 4, 5)     | 12   | 1        | 60    | 1          |
| (5, 12, 13)   | 60   | 5        | 780   | 13         |
| (8, 15, 17)   | 120  | 10       | 2040  | 34         |
| (20, 21, 29)  | 420  | 35       | 12180 | 203        |
| (6, 8, 10)    | 48   | 4        | 480   | 8          |
| (9, 12, 15)   | 108  | 9        | 1620  | 27         |

Every row is an exact integer: empirically `12 ∣ a·b` and `60 ∣ a·b·c` for all
triples tested (primitive and non-primitive alike).

### Why `4` needs residues mod `8`, not mod `4`
Over `ZMod 4` the system `x² + y² = z²` admits `x = 1, y = 2, z = 1`
(`1 + 4 = 5 ≡ 1`), yet `x·y = 2 ≠ 0`. So `4 ∣ a·b` is **not** a mod-`4`
phenomenon. Over `ZMod 8` the check `x² + y² = z² ⇒ 4 ∣ x·y` passes for all
`8³` residue triples — this is the correct modulus and matches the classical
"difference of two odd squares is divisible by 8".

## 2. Quadruple parity (small cases)

For quadruples `a² + b² + c² = d²`, count of odd entries among `a, b, c`:

| quadruple       | odd(a,b,c) | ≥ two even? | 4 ∣ a·b·c |
|-----------------|-----------|-------------|-----------|
| (1, 2, 2, 3)    | 1         | yes         | 4 ∣ 4     |
| (2, 3, 6, 7)    | 1         | yes         | 4 ∣ 36    |
| (1, 4, 8, 9)    | 1         | yes         | 4 ∣ 32    |
| (2, 6, 9, 11)   | 1         | yes         | 4 ∣ 108   |
| (4, 4, 7, 9)    | 1         | yes         | 4 ∣ 112   |

The count of odd entries among `a, b, c` is always `0` or `1`; the configuration
"two odd legs" (which triples permit) never appears — consistent with
`a² + b² + c² ≡ #odd (mod 4)` and `d² ∈ {0,1} (mod 4)`.

## 3. Leg realizability (counterexample hunt for small n)

For each `n`, does there exist `0 < b < c` with `n² + b² = c²`?

| n | leg? | witness (b, c)          |
|---|------|-------------------------|
| 1 | no   | —                       |
| 2 | no   | —                       |
| 3 | yes  | (4, 5)   [odd rule]     |
| 4 | yes  | (3, 5)   [even rule]    |
| 5 | yes  | (12, 13) [odd rule]     |
| 6 | yes  | (8, 10)  [even rule]    |
| 7 | yes  | (24, 25) [odd rule]     |

The construction `odd n=2k+1 ↦ ((n²−1)/2,(n²+1)/2)` and `even n=2k ↦ (k²−1,k²+1)`
reproduces the witnesses; `n = 1, 2` genuinely fail (would force `b = 0`), so the
threshold `n ≥ 3` is sharp.

## OEIS pointers
- Areas of primitive Pythagorean triangles are all divisible by 6 (A009112-type
  data); the "one leg divisible by 3, one by 4, one entry by 5" fact is folklore
  and underlies the `60 ∣ a·b·c` observation.

All finite residue checks above are discharged inside the Lean files by `decide`
over the relevant `ZMod m`, and the integer statements by casting back through
`ZMod.intCast_zmod_eq_zero_iff_dvd`.
