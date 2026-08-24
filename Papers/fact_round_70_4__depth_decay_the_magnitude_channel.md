# Computational evidence — depth decay of the magnitude channel on the Berggren tree

All numbers below were produced by `#eval` inside Lean 4 (mathlib v4.28.0) against the
definitions in `Catalog/Cryptography/DepthDecay/`, so they run against exactly the objects
the theorems talk about (`Adm`, `parent`, `letterOf`, `letterAt`, `probe`, `build`,
`sPlus`, `sMinus`).

## 0. Model check: `parent` really inverts the Berggren tree

For all pairs `(m,n)` with `2 ≤ m ≤ 31`, `1 ≤ n ≤ 30` that are admissible
(`0 < n < m`, `gcd = 1`, `m+n` odd):

* `parent (child x s) = s` for `x ∈ {A,B,C}` — **all true**;
* `letterOf (child x s) = x` for `x ∈ {A,B,C}` — **all true**.

So the letter read by `letterOf` is exactly "which Berggren child was I", and the ratio
cut points `2` and `3` are the whole decision rule.  (Both facts are also proved:
`parent_child`, `letterOf_child`.)

## 1. The `C`-run formula `L = (m−n)/(2n)`

Over all **2966** admissible states with `m ≤ 201`, `n ≤ 40`:

```
∀ s. (∀ j < L(s), letterAt j s = C)  ∧  letterAt L(s) s ≠ C      where L(s) = (m−n)/(2n)
```

evaluates to `true` on every one of them.  Formalized as `cRun_letters_C` and
`cRun_letterAt_ne_C`.

## 2. Where does a shared one-bit probe first fail?

Take all admissible states with `m ≤ 301`, `n ≤ 30`, and all **196 876** ordered pairs of
distinct states with the *same* one-bit probe `⌊2m/n⌋`.  For each pair record the first
depth at which their descent letters differ (searching depths `0 … 11`):

| first disagreement depth | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| count | **0** | 7810 | 21970 | 27658 | 30368 | 31272 | 26948 | 19322 |

Depth `0` never disagrees — matching the theorem `letterOf_eq_letterFromProbe` (depth 1 in
1-based counting is a deterministic function of the probe).  Disagreements start at the very
next depth, and the mass sits at small depths: the channel is real at the first step and
dies immediately after the first inversion.  This is the qualitative shape reported for the
`b₂ … b₅` conditional z-scores.

## 3. The straddling pairs used in the null theorem

`sPlus W k = ((7+6k)q + 1, 3q)`, `sMinus W k = ((7+6k)q − 1, 3q)`, `q = 6·2^W`:

```
W=0 k=0  s+=(43,18)   s-=(41,18)   probe=2    path+ = BBA    path- = BCA
W=0 k=1  s+=(79,18)   s-=(77,18)   probe=4    path+ = CBBA   path- = CBCA
W=1 k=0  s+=(85,36)   s-=(83,36)   probe=4    path+ = BBA    path- = BCA
W=1 k=2  s+=(229,36)  s-=(227,36)  probe=12   path+ = CCBBA  path- = CCBCA
W=2 k=1  s+=(313,72)  s-=(311,72)  probe=17   path+ = CBBA   path- = CBCA
W=3 k=2  s+=(913,144) s-=(911,144) probe=50   path+ = CCBBA  path- = CCBCA
W=4 k=3  s+=(2401,288) s-=(2399,288) probe=133 path+ = CCCBBA path- = CCCBCA
```

In every row the probes coincide, the prefixes `C^k B` coincide, and the letter at depth
`k+1` differs (`B` vs `C`).  Formalized as `depth_null_beyond_first_inversion`.

## 4. Capacity collapse on the `{A,B}` stratum

Number of distinct values of `probe 2` on the `2^k` states built from `{A,B}`-words of
length `k`:

| k | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|
| words `2^k` | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512 |
| distinct probe values | 2 | 4 | 5 | 6 | 6 | 6 | 6 | 6 | 6 |

The probe saturates at `6 ≤ 2·2^2 = 8` values while the number of behaviours doubles every
level: from `k = 3` on the sensor provably confuses states with different paths.
Formalized as `probe_collision_of_depth` (hypothesis `2·2^W < 2^k`).

## 5. Arbitrary rational-scale sensors also collide

The sensor `gprobe a b (m,n) = ⌊(a/b)·(m/n)⌋` (with `gprobe (2^W) 1 = probe W`) is defeated by
the *attained* boundary state `(4k+5, 2)` and its right neighbour `((4k+5)u+1, 2u)`,
`u = 2a+2`:

```
a=1  b=1  k=0   s=(5,2)    s'=(21,8)     reading 2   = 2     path BB  vs BA
a=3  b=1  k=1   s=(9,2)    s'=(73,16)    reading 13  = 13    path CBB vs CBA
a=9  b=2  k=2   s=(13,2)   s'=(261,40)   reading 29  = 29    path CCBB vs CCBA
a=64 b=5  k=3   s=(17,2)   s'=(2211,260) reading 108 = 108   path CCCBB vs CCCBA
a=7  b=3  k=0   s=(5,2)    s'=(81,32)    reading 5   = 5     path BB  vs BA
```

Same reading, same prefix `C^k B`, different letter at depth `k+1` — for binary, ternary and
arbitrary rational scales alike.  Formalized as `universal_depth_null`.

## 6. What was *not* found

A counterexample hunt for the positive results — `letterOf_eq_letterFromProbe`,
`cRun_letters_C`, `cRun_letterAt_ne_C`, `readable_prefix_length` — over the sample of
§1–§2 produced no counterexample; all four are now theorems, so the search is only a
sanity check on the statements.

No OEIS sequence is involved: the objects here are the two integer functionals
`⌊2m/n⌋` and `(m−n)/(2n)` and the ternary path alphabet.
