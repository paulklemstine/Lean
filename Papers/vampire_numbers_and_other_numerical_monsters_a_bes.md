# Computational Evidence — Vampire Numbers and Digit-Permutation Factorizations

## 1. Small-case calculations

The classical vampire numbers begin (OEIS **A014575**):

```
1260, 1395, 1435, 1530, 1827, 2187, 6880,
102510, 104260, 105210, 105264, 105750, 108135, ...
```

Smallest example and its fang factorization:

```
1260 = 21 · 60      digits(1260) = {0,1,2,6},  digits(21)∪digits(60) = {1,2}∪{0,6} = {0,1,2,6}  ✓
```

Casting-out-nines check (Hypothesis H2):

| v      | x·y      | v mod 9 | (x+y) mod 9 |
|--------|----------|---------|-------------|
| 1260   | 21·60    | 0       | 81 mod 9 = 0|
| 1395   | 15·93    | 0       | 108 mod 9 =0|
| 1435   | 35·41    | 4       | 76 mod 9 = 4|
| 1530   | 30·51    | 0       | 81 mod 9 = 0|
| 6880   | 80·86    | 4       | 166 mod9 = 4|

In every row `v ≡ x + y (mod 9)`, matching the proved theorem `castingOutNines`.

Mod-3 unit obstruction (Hypothesis H3): no fang is `≡ 1 (mod 3)`:

```
21≡0, 60≡0 | 15≡0, 93≡0 | 35≡2, 41≡2 | 30≡0, 51≡0 | 80≡2, 86≡2
```

None equals `1 (mod 3)`, matching `fang_not_one_mod_three`.

Length additivity (Hypothesis H4): for all listed pairs
`len(v) = len(x) + len(y)` (2 = 1+1 in fang length; 4 = 2+2 total).

## 2. OEIS

- Vampire numbers: **A014575**.
- Fangs / true vampire numbers with genuine fang factorizations: **A048936**.
- Binary digit sum `s₂(n)` (used in the bridge file): **A000120**.

## 3. Counterexample hunt

- The stated density conjecture "density of vampire numbers in
  `[10^{2n}, 10^{2n+1}]` approaches `1/√n`" is **ill-posed / false as written**:
  `1/√n → 0`, which would say vampire numbers *vanish*, contradicting the
  intended "approaches 1" reading. Empirically the count of vampire numbers up
  to `10^{2n}` grows but their density decreases; no clean `1/√n` law holds.
  We therefore do **not** formalize it and instead prove the exact, unconditional
  arithmetic obstructions.
- The three obstruction theorems (`castingOutNines`, `fang_not_one_mod_three`,
  `digit_length_additive`) were tested against all tabulated vampire pairs above
  and against random non-vampire products; no counterexample exists (they are
  now proved theorems).

## 4. Binary bridge sanity check

`s₂(1260) = s₂(0b10011101100) = 6`. Bounds from `vampire_binary_bound`:
`min(60·s₂(21), 21·s₂(60)) = min(60·3, 21·4) = min(180, 84) = 84 ≥ 6`. ✓
The bound is loose, as expected for a product (carries destroy 1-bits).
