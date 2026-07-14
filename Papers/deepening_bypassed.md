# Computational Evidence — Strong Divisibility & Fibonacci–Pythagorean Bridge

## 1. Fibonacci–Pythagorean triples (small cases)

For consecutive Fibonacci numbers we set
`A = F n · F (n+3)`, `B = 2 · F (n+1) · F (n+2)`, `C = F (n+1)² + F (n+2)²`.

| n | (A, B, C)       | A²+B²=C²? | C = F(2n+3)? |
|---|-----------------|-----------|--------------|
| 0 | (0, 2, 2)       | yes       | yes (F3=2)   |
| 1 | (3, 4, 5)       | yes       | yes (F5=5)   |
| 2 | (5, 12, 13)     | yes       | yes (F7=13)  |
| 3 | (16, 30, 34)    | yes       | yes (F9=34)  |
| 4 | (39, 80, 89)    | yes       | yes (F11=89) |
| 5 | (105, 208, 233) | yes       | yes (F13=233)|

Observations: the identity holds for every tested `n`; the hypotenuse is always the
Fibonacci number `F(2n+3)`. Note that `n = 3` gives `(16,30,34) = 2·(8,15,17)`, so the
triples are **not** always primitive — no primitivity claim is made.

## 2. Fibonacci strong divisibility  `F m ∣ F n ↔ m ∣ n`  (m ≥ 3)

Spot checks (F: 1,1,2,3,5,8,13,21,34,55,89,144,...):
- `F 3 = 2 ∣ F 6 = 8` and `3 ∣ 6`. ✓
- `F 4 = 3 ∣ F 8 = 21` and `4 ∣ 8`. ✓
- `F 5 = 5 ∣ F 10 = 55` and `5 ∣ 10`. ✓
- `F 4 = 3 ∤ F 7 = 13` and `4 ∤ 7`. ✓
The exceptional low indices (`F 1 = F 2 = 1`) are exactly why the law is stated for
`m ≥ 3`.

## 3. Mersenne divisibility  `a^m − 1 ∣ a^n − 1 ↔ m ∣ n`  (a ≥ 2)

- `2^3 − 1 = 7 ∣ 2^6 − 1 = 63` and `3 ∣ 6`. ✓
- `2^2 − 1 = 3 ∣ 2^4 − 1 = 15` and `2 ∣ 4`. ✓
- `3^2 − 1 = 8 ∣ 3^6 − 1 = 728` and `2 ∣ 6`. ✓
- `2^2 − 1 = 3 ∤ 2^3 − 1 = 7` and `2 ∤ 3`. ✓

## 4. Fibonacci prime index test  `F n prime → n = 4 ∨ n prime`

Primes among `F n` for small `n`: `F 3 = 2`, `F 4 = 3`, `F 5 = 5`, `F 7 = 13`,
`F 11 = 89`, `F 13 = 233`, `F 17 = 1597`. The corresponding indices are
`3, 4, 5, 7, 11, 13, 17` — all prime **except** `n = 4`. This confirms both the theorem
and that the `n = 4` escape clause is genuinely necessary (`F 4 = 3` is prime while `4`
is composite). No counterexample to the index test was found in `n ≤ 40`.

## Method

All values above were computed directly from the definitions and cross-checked against
the proved statements. The evidence stage is kept intentionally short: each claim is a
finite, exactly computable statement, and the formal proofs cover all `n`.
