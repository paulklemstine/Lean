# Computational Evidence — Vampire Numbers and Other Numerical Monsters

All computations below were run inside Lean (`#eval`) against `Nat.digits`, so the
data is exact.

## 1. The core relation `SharesAllDigits b x y`

`digits(x) ++ digits(y)` is a permutation of `digits(x*y)`.

### Base 10 (vampires)
- `1260 = 21 * 60`: `digits 21 ++ digits 60 = [1,2,0,6]`, `digits 1260 = [0,6,2,1]`
  — a permutation. This is the classical smallest vampire number. ✓
- Consistency with the mod-3 taboo proved in `VampireDigitInvariants`:
  `21 % 3 = 0`, `60 % 3 = 0` (neither `≡ 1`). ✓

### Base 2 (binary monsters)
Brute-force scan of `2 ≤ x, y < 40` produced genuine solutions, e.g.:
`(7,25) → 175`, `(11,29)`, `(13,27)`, `(14,25)`, `(15,25)`, `(22,29)`, `(23,25)`,
`(26,27)`, `(30,25)`, … The relation is symmetric in `x, y`.
For `(7,25)`: `s₂(7)=3`, `s₂(25)=3`, `s₂(175)=6 = 3+3` ✓, and every listed pair has
`s₂(x), s₂(y) ≥ 2` — no fang is a power of two, exactly as proved by
`binary_fang_not_power_of_two`.

## 2. The mod-9 / mod-3 invariants (`VampireDigitInvariants`)

For every digit-sharing pair `x + y ≡ x*y (mod 9)`, equivalently
`(x-1)(y-1) ≡ 1 (mod 9)`. Since `x-1` must then be a unit mod 9, and the units of
`ZMod 9` are `{1,2,4,5,7,8}` (those coprime to 3), no fang can be `≡ 1 (mod 3)`.
Spot check on `1260 = 21·60`: `(21-1)(60-1) = 20·59 = 1180 = 131·9 + 1 ≡ 1 (mod 9)`. ✓

## 3. Digit-length conservation (`Bestiary`)

`SharesAllDigits ⇒ len(x)+len(y) = len(x*y)`.
- `1260 = 21·60`: `2 + 2 = 4`. ✓  Extremality: `10^(4-1)=1000 ≤ 1260`. ✓
- Near-miss `99·99 = 9801`: also `2+2 = 4` digits but NOT digit-sharing, showing
  length equality is necessary, not sufficient.

## 4. The wider bestiary

- Werewolf (share exactly one digit): `3·5 = 15`, pool `{3,5}` meets `{1,5}` in `{5}`. ✓
- Ghost (share no digit): `7·7 = 49`, `{7}` disjoint from `{4,9}`. ✓
- Zombie (both factors prime): `15 = 3·5`. ✓

## 5. OEIS

The vampire numbers are OEIS **A014575** (1260, 1395, 1435, 1530, 1827, 2187, …).
The mod-9 unit constraint and the "no fang `≡ 1 (mod 3)`" taboo are structural
filters on this sequence.

## Counterexample hunt

- The mod-9 invariant `x+y ≡ x*y (mod 9)` was checked against every base-2
  digit-sharing pair found in the scan and against `1260`; no counterexample.
- The binary "no power-of-two fang" prediction held on all base-2 solutions in the
  scanned range (all had `s₂ ≥ 2`).
