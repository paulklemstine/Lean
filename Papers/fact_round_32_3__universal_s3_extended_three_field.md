# Computational evidence — UNIVERSAL-S3-EXTENDED (three fields, one answer)

All numbers below were produced by `#eval` inside Lean 4 (exact integer arithmetic;
the mutual-information figures use `Float` logarithms).  They are *exploration*, not
proof: the corresponding formal statements, proved with 0 `sorry`, are in
`Catalog/Physics/S3TypeChannel*.lean`.

## 1. The three cubics and their discriminants

| cubic         | `(a,b)` in `x³+ax+b` | `disc = -4a³-27b²` | squarefree kernel | resolvent    | character |
|---------------|----------------------|--------------------|-------------------|--------------|-----------|
| `x³ - 3`      | `(0,-3)`             | `-243`             | `-3` (`-243=-3·9²`) | `ℚ(√-3)`  | `p mod 3` |
| `x³ - 2`      | `(0,-2)`             | `-108`             | `-3` (`-108=-3·6²`) | `ℚ(√-3)`  | `p mod 3` |
| `x³ - x - 1`  | `(-1,-1)`            | `-23`              | `-23` (squarefree)  | `ℚ(√-23)` | `(p|23)`  |

Formalised: `S3Algebra.disc_x3_sub_3`, `disc_x3_sub_2`, `disc_x3_sub_x_sub_1`,
`squarefree_kernels`.

## 2. Counterexample hunt for the sign law

For every prime `p < 400` (excluding the ramified prime) we computed the number of roots
of the cubic mod `p` — `3` roots = totally split, `1` root = `1+2`, `0` roots = inert —
and compared the resulting Frobenius *sign* bit (`+1` iff the number of roots is `≠ 1`)
with the predicted quadratic character:

```
x³-3      vs  [p ≡ 1 mod 3]        : all 77 primes agree   → true
x³-2      vs  [p ≡ 1 mod 3]        : all 76 primes agree   → true
x³-x-1    vs  [p^11 ≡ 1 mod 23]    : all 77 primes agree   → true
```

No counterexample.  (Formal version, valid for *all* primes:
`S3Algebra.isSquare_neg243_iff`, `S3Algebra.isSquare_neg108_iff`,
`S3Algebra.isSquare_neg_three_iff`.)

## 3. Chebotarev profile of `x³ - 3`

Primes `p < 5000`, `p ≠ 3` (668 primes):

| type            | observed | predicted `1:3:2` |
|-----------------|----------|-------------------|
| totally split   | 103      | 111.3             |
| `1+2`           | 338      | 334.0             |
| inert           | 227      | 222.7             |

Formalised as an exact count over `S₃`: `S3Universal.typeMult_values` (`1 : 3 : 2`).

## 4. Empirical channel value

Primes `p < 20000`, `p ≠ 3` (2261 primes), joint occupation numbers of
`(p mod 3, splitting type of x³-3)`:

|            | split | `1+2` | inert |
|------------|-------|-------|-------|
| `p ≡ 1`    | 364   | 0     | 760   |
| `p ≡ 2`    | 0     | 1137  | 0     |

* empirical `I(p mod 3 ; T) = 0.999976` bits  (theory: **exactly 1**)
* empirical `H(T) = 1.45162` bits  (theory: `2/3 + (log₂3)/2 = 1.45915`)

The two structural zeros are *exact* at every sample size — they are the content of
`S3Universal.residueTable_eq_chebotarev_count` — and they are what forces the value `1`.

## 5. Semiprime pair channel

Counting over the 36 Frobenius pairs of `S₃ × S₃`, the unordered type-pair profile is

```
{split,split} 1   {split,1+2} 6   {split,inert} 4
{1+2,1+2}     9   {1+2,inert} 12  {inert,inert} 4      (total 36)
```

with sign-product `+1` on `{1,4,9,4}` (mass 18) and `-1` on `{6,12}` (mass 18) — exactly
balanced, hence again a one-bit channel.  Formalised: `S3Universal.pairMult_values`,
`pairSignBit_mass_balance`, `Imut_semiprime_pair_eq_one`.

## 6. Contrast: what is *not* one bit

| channel (same Chebotarev machine)                     | exact value        | numeric |
|-------------------------------------------------------|--------------------|---------|
| `S₃`: residue vs splitting type (sign readout)         | `1`                | 1.00000 |
| `S₃`: residue vs "has a root mod p?" (root readout)    | `(log₂3)/2 - 1/3`  | 0.45915 |
| `S₃`: entropy of the splitting type itself             | `2/3 + (log₂3)/2`  | 1.45915 |
| cyclic cubic `C₃`: residue vs Frobenius                | `log₂ 3`           | 1.58496 |
| cyclic cubic `C₃`: residue vs splitting type           | `log₂ 3 - 2/3`     | 0.91830 |

Formalised: `S3Lossy.Imut_rootTable_eq`, `S3Lossy.HT_eq`, `S3General.Imut_c3Frob_eq`,
`S3General.Imut_c3Type_eq`, `S3General.galois_group_is_detected`.

## 7. OEIS

No new integer sequence is produced; the profiles `1,3,2` and `1,6,4,9,12,4` are the
conjugacy-class sizes of `S₃` and the induced multiset multiplicities on `S₃ × S₃`.
