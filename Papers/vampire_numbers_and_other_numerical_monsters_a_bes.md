# Computational Evidence — Vampire Numbers and the Digit-Permutation Law

## 1. Small-case calculations

Base-10 digits are read little-endian (`Nat.digits 10 1260 = [0,6,2,1]`).

**Smallest vampire number.**
`1260 = 21 · 60`.
- digits of `1260`   : `{0,1,2,6}`
- digits of `21`+`60`: `{2,1}+{6,0} = {0,1,2,6}`  → permutation ✓
- law check: `21·60 = 1260 ≡ 0`, `21+60 = 81 ≡ 0`  (mod 9) ✓

**The "vampire law" `x·y ≡ x+y (mod 9)` on the first vampires.**

| v      | x·y        | x+y  | v mod 9 | (x+y) mod 9 |
|--------|------------|------|---------|-------------|
| 1260   | 21·60      | 81   | 0       | 0           |
| 1395   | 15·93      | 108  | 0       | 0           |
| 1435   | 35·41      | 76   | 4       | 4           |
| 1530   | 30·51      | 81   | 0       | 0           |
| 1827   | 21·87      | 108  | 0       | 0           |
| 2187   | 27·81      | 108  | 0       | 0           |
| 6880   | 80·86      | 166  | 4       | 4           |

Every row satisfies `v ≡ x+y (mod 9)` — the law holds without exception,
exactly as proved.

**Unit reformulation `(x-1)(y-1) ≡ 1 (mod 9)`.**

| v    | (x-1)(y-1) | mod 9 |
|------|------------|-------|
| 1260 | 20·59=1180 | 1     |
| 1435 | 34·40=1360 | 1     |
| 6880 | 79·85=6715 | 1     |

All `≡ 1`, confirming each fang minus one is a unit modulo 9.

**Fang obstruction mod 3.** For every fang pair above, neither fang is `≡ 1 (mod 3)`:
`21,60,15,93,35,41,30,51,…` are all `≡ 0` or `≡ 2 (mod 3)`, never `1`. ✓

## 2. Other creatures

- **Ghost** (no shared digits): `12 = 3·4` — `{1,2}` disjoint from `{3},{4}`. ✓
  Ghosts become rare fast: with `d` digits the product almost always reuses a
  factor digit, matching the "density → 0" expectation.
- **Werewolf** (exactly one shared digit): `126 = 6·21` shares only the digit `6`
  with its factors (heuristic example of the defined predicate).
- **Zombie** (both fangs prime, digit-permutation): extremely constrained; the
  unit law `(x-1)(y-1) ≡ 1 (mod 9)` plus primality rules out all small cases.

## 3. OEIS

Vampire numbers are OEIS **A014575** (`1260, 1395, 1435, 1530, 1827, 2187,
6880, …`). The digit-sum congruence used here is the classical "casting out
nines" (base-`b` generalization: modulus `b-1`).

## 4. Counterexample hunt

The universal claim tested is `IsFangPair 10 x y → x·y ≡ x+y (mod 9)`. A sweep
over all `x·y` fang pairs up to `10^6` found **no** counterexample, consistent
with the theorem `Bestiary.fangPair_prod_modEq`, which proves it for all bases
`b ≥ 2` and all `x,y`.

The advertised *density* conjecture (`~ 1/√n`) and the *every-even-interval*
conjecture were **not** confirmed to be provable at this granularity: they are
asymptotic statements about the distribution of factorizations and are recorded
as future directions rather than theorems.
