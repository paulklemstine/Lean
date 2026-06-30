# Computational Evidence — Sums of Three Cubes

Problem: which integers `n` are of the form `n = x³ + y³ + z³` with `x, y, z ∈ ℤ`?

## 1. Small-case calculations (n = 0 … 30)

Cubes mod 9 lie in `{0, 1, 8}`, so three cubes can only reach the residues
`{0, 1, 2, 3, 6, 7, 8} (mod 9)`; the classes `4` and `5 (mod 9)` are impossible.
The first nonnegative non-representable integers are therefore `4, 5, 13, 14, 22, 23, …`
(exactly `n ≡ ±4 mod 9`).

| n  | representation                | n  | representation                 |
|----|-------------------------------|----|--------------------------------|
| 0  | 0³+0³+0³                       | 16 | 2³+2³+0³                        |
| 1  | 1³+0³+0³                       | 17 | 2³+2³+1³                        |
| 2  | 1³+1³+0³                       | 18 | 1³? — uses larger: 3³+(-2)³+(-1)³? (no) → 19 below |
| 3  | 1³+1³+1³ = 4³+4³+(−5)³         | 20 | 3³+(-2)³+1³ = 27−8+1            |
| 6  | 2³+(−1)³+(−1)³                 | 24 | 2³+2³+2³                        |
| 7  | (heuristic; e.g. larger soln) | 27 | 3³+0³+0³                        |
| 8  | 2³+0³+0³                       | 28 | 3³+1³+0³                        |
| 9  | 2³+1³+0³                       | 29 | 3³+1³+1³                        |
| 10 | 2³+1³+1³                       | 30 | (hard; solved 1999: 30 = 2220422932³ + … ) |
| 4  | **impossible** (≡4 mod 9)      | 5  | **impossible** (≡5 mod 9)       |
| 13 | **impossible** (≡4 mod 9)      | 14 | **impossible** (≡5 mod 9)       |

All "easy" entries are verified by `ring` in the Lean development.

## 2. Parametric families (infinitely many representations)

- `2 = (1 + 6t³)³ + (1 − 6t³)³ + (−6t²)³` for every integer `t`.
  - t = 0 → 1+1+0; t = 1 → 7³ + (−5)³ + (−6)³ = 343 − 125 − 216 = 2. ✓
- Mahler: `1 = (9t⁴)³ + (3t − 9t⁴)³ + (1 − 9t³)³` for every integer `t`.
  - t = 0 → 0+0+1 = 1. ✓ t = 1 → 9³ + (−6)³ + (−8)³ = 729 − 216 − 512 = 1. ✓

Both identities are verified by `ring`; the `2`-family yields an *infinite* solution set
(`two_infinitely_many`), since the first coordinate `1 + 6t³` is injective in `t`.

## 3. Counterexample hunt (mod-9 obstruction is real)

Brute-force over `a, b, c ∈ {0,…,8}` in `ℤ/9`: the multiset of attained sums of three
cubes is exactly `{0,1,2,3,6,7,8}`; `4` and `5` are never attained (`729` cases checked
by `decide`). Hence `n ≡ 4, 5 (mod 9)` is a genuine obstruction with **no** counterexample.

Density of representable residues = `7/9 ≈ 0.777…` (`representable_residues_card`).

## 4. Famous computational discoveries (certified in Lean)

- **33** (Booker, 2019):
  `8866128975287528³ + (−8778405442862239)³ + (−2736111468807040)³ = 33`.
- **42** (Booker–Sutherland, 2019, the last `n < 100`):
  `(−80538738812075974)³ + 80435758145817515³ + 12602123297335631³ = 42`.

Both certified by kernel reduction (`decide`) in `Physics/SumsOfThreeCubes.lean`.

## 5. OEIS / external signals

- OEIS **A060464** / **A060465**: numbers that are / are not sums of three cubes.
- OEIS **A003072**: numbers that are the sum of three positive cubes.
- The 2019 resolutions of 33 and 42 (Booker; Booker–Sutherland) motivated targeting
  these specific witnesses as "known computational results" to formalise.

## Conclusion

The evidence cleanly separates a provable *local* obstruction (`±4 mod 9`) from the open
*global* density statement. The Lean files prove the obstruction, the parametric families,
the infinitude for `n = 2`, the exact local picture at `3`, and certify the headline
2019 witnesses.
