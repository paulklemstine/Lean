# Computational Evidence — `5 ∣ a^5 - a` and Pythagorean residues mod 5

## 1. Small-case check of `a^5 - a` divisible by 5

| a  | a^5    | a^5 - a | (a^5 - a)/5 |
|----|--------|---------|-------------|
| -3 | -243   | -240    | -48         |
| -2 | -32    | -30     | -6          |
| -1 | -1     |  0      |  0          |
|  0 |  0     |  0      |  0          |
|  1 |  1     |  0      |  0          |
|  2 |  32    |  30     |  6          |
|  3 |  243   |  240    |  48         |
|  4 |  1024  |  1020   |  204        |
|  5 |  3125  |  3120   |  624        |
|  6 |  7776  |  7770   |  1554       |

Every value of `a^5 - a` is an exact multiple of 5. No counterexample was found
over `-100 ≤ a ≤ 100`.

## 2. Fifth powers mod 5 (Frobenius / Fermat)

For `x` in `{0,1,2,3,4}`: `x^5 mod 5 = x`.

- 0^5 = 0 ≡ 0
- 1^5 = 1 ≡ 1
- 2^5 = 32 ≡ 2
- 3^5 = 243 ≡ 3
- 4^5 = 1024 ≡ 4

So the map `x ↦ x^5` is the identity on `ℤ/5ℤ`; this is exactly `5 ∣ a^5 - a`.

## 3. Squares mod 5 (used for the Pythagorean bridge)

For `x` in `{0,1,2,3,4}`: `x^2 mod 5 ∈ {0,1,4}`.

- 0^2 ≡ 0, 1^2 ≡ 1, 2^2 ≡ 4, 3^2 ≡ 4, 4^2 ≡ 1.

The nonzero quadratic residues mod 5 are `{1,4}`; `{2,3}` are non-residues.

## 4. Pythagorean triples: 5 divides a leg or the hypotenuse

Testing primitive and non-primitive triples `a^2 + b^2 = c^2`:

| (a,b,c)     | a%5 | b%5 | c%5 | which is divisible by 5 |
|-------------|-----|-----|-----|-------------------------|
| (3,4,5)     | 3   | 4   | 0   | c                       |
| (5,12,13)   | 0   | 2   | 3   | a                       |
| (8,15,17)   | 3   | 0   | 2   | b                       |
| (7,24,25)   | 2   | 4   | 0   | c                       |
| (20,21,29)  | 0   | 1   | 4   | a                       |
| (9,40,41)   | 4   | 0   | 1   | b                       |
| (6,8,10)    | 1   | 3   | 0   | c                       |

In every Pythagorean triple, exactly the argument from residues shows at least one
of `a, b, c` is divisible by 5. Reason: if `5 ∤ a` and `5 ∤ b` then
`a^2, b^2 ∈ {1,4} (mod 5)`, so `a^2 + b^2 ∈ {2, 0, 3} (mod 5)`; the only value that
is itself a square mod 5 is `0`, forcing `5 ∣ c`. Hence `5 ∣ a·b·c` always.

No counterexample found over all triples with `c ≤ 200`.

## 5. OEIS

`a^5 - a` for `a = 0,1,2,...` gives `0, 0, 30, 240, 1020, 3120, 7770, ...`
(all divisible by 5), matching `5 · A??` scaled forms; the divisibility itself is
the classical Fermat statement, not a standalone OEIS entry.
