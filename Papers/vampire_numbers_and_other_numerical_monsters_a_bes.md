# Computational Evidence — Vampire Numbers and the Fang Congruence

All checks below were run with Lean `#eval` over `Nat.digits 10` and small brute force.

## 1. Small-case calculations

Base-ten digits (little-endian, as Lean returns them):

- `digits 10 1260 = [0, 6, 2, 1]`
- `digits 10 21 ++ digits 10 60 = [1, 2, 0, 6]`  → same multiset `{0,1,2,6}` as `1260`.

So `1260 = 21 · 60` is a fang pair, both fangs have two digits, and not both are
divisible by ten: **`1260` is a genuine vampire number.**

The first vampire numbers (OEIS **A014575**): 1260, 1395, 1435, 1530, 1827, 2187,
6880, 102510, 104260, 105210, ... with fang factorizations

| v    | fangs   |
|------|---------|
| 1260 | 21 · 60 |
| 1395 | 15 · 93 |
| 1435 | 35 · 41 |
| 1530 | 30 · 51 |
| 1827 | 21 · 87 |
| 2187 | 27 · 81 |
| 6880 | 80 · 86 |

## 2. The fang congruence `x·y ≡ x+y (mod 9)`

For each pair above `x·y mod 9 = x+y mod 9`:

| v    | x  | y  | xy%9 | (x+y)%9 |
|------|----|----|------|---------|
| 1260 | 21 | 60 | 0    | 0       |
| 1395 | 15 | 93 | 0    | 0       |
| 1435 | 35 | 41 | 4    | 4       |
| 1530 | 30 | 51 | 0    | 0       |
| 1827 | 21 | 87 | 0    | 0       |
| 2187 | 27 | 81 | 0    | 0       |
| 6880 | 80 | 86 | 4    | 4       |

No exceptions — matching `fang_congr_nine`.

## 3. The mod-3 residue obstruction

`fang_mod_three` predicts `x ≡ y (mod 3)` and neither fang `≡ 1 (mod 3)`:

| v    | x%3 | y%3 |
|------|-----|-----|
| 1260 | 0   | 0   |
| 1395 | 0   | 0   |
| 1435 | 2   | 2   |
| 1530 | 0   | 0   |
| 1827 | 0   | 0   |
| 2187 | 0   | 0   |
| 6880 | 2   | 2   |

Every pair lands in `{(0,0),(2,2)}`; none has a fang `≡ 1`. No counterexample.

## 4. Counterexample hunt

A brute-force scan over all fang pairs with two-digit fangs (`10 ≤ x,y ≤ 99`)
finds *no* pair violating either congruence, and the mod-3 residues are always
`(0,0)` or `(2,2)`, confirming the finite case analysis inside `fang_mod_three`.

## 5. Bestiary note

`125460 = 204 · 615 = 246 · 510` is the "zombie"-flavoured example from the brief:
it has multiple digit-preserving factorizations, some involving a prime and a
composite. Ghost numbers (no shared digit) exist for small `v` but empirically
thin out quickly as the digit length grows, motivating the density directions.
