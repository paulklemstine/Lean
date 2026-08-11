# Computational evidence (Cycle 2, thread th_3b515382)

All numbers below were produced by `#eval` inside Lean 4 (kernel-independent
evaluation) and were used only to *choose* the statements to prove.  Everything that
is claimed as established is proved separately in the three `.lean` files under
`Catalog/Computation/CellularAutomata/`; nothing in this note is itself a verified
result.

Conventions throughout: cyclic (periodic) boundary conditions, lattice `ZMod n`,
alphabet `GF(2)`, local rule applied as `s i ↦ g (s (i-1)) (s i) (s (i+1))`, Wolfram
rule-number convention "output on neighbourhood `(a,b,c)` is bit `4a+2b+c`".

## 1. Fixed-point counts, all 256 rules, `n = 1..7`

Distribution of `#V(g, 6)` over the 256 rules (count of rules, by value):

| `#V(g,6)` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 10 | 11 | 16 | 18 | 19 | 20 | 29 | 39 | 64 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| rules | 40 | 78 | 48 | 26 | 15 | 6 | 6 | 2 | 8 | 6 | 2 | 6 | 6 | 2 | 2 | 2 | 1 |

* `78` rules have `#V(g,n) = 1` for every `n ≤ 7`;
* `39` rules have `#V(g,n) = 0` for every `n ≤ 7`.

The proved criterion (`SingletonCriterion`) is *sufficient but not necessary*: it
isolates the `16` rules

```
34, 38, 42, 46, 50, 54, 58, 62, 98, 102, 106, 110, 114, 118, 122, 126
```

for which the count is provably `1` for **all** `n`, whereas `78` rules realise the
value `1` on the tested range.  Closing the two symmetries (mirror, complement) over
this set enlarges it to `48` certified rules

```
34, 38, 42, 46, 48, 50, 52, 54, 56, 58, 60, 62, 98, 102, 106, 110, 112, 114, 116,
118, 120, 122, 124, 126, 129, 131, 137, 139, 145, 147, 153, 155, 161, 163, 169,
171, 177, 179, 185, 187, 193, 195, 209, 211, 225, 227, 241, 243
```

(proved in `RuleSymmetries.lean`), leaving `30` rules with count `1` on the tested
range but no proof for all `n`.  Closing that remaining gap is Conjecture C1 in
`FUTURE_DIRECTIONS.md`.

A second, disjoint family is certified in `ConstantPairRules.lean`: the four rules
`176, 178, 184, 186` have fixed-point count exactly `2` for every `n`, their fixed
configurations being the two constant ones.

## 2. Counts of the landmark rules, `n = 1..8`

| rule | `n=1` | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| 90  | 1 | 1 | 4 | 1 | 1 | 4 | 1 | 1 |
| 110 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 150 | 2 | 4 | 2 | 4 | 2 | 4 | 2 | 4 |
| 30  | 1 | 3 | 1 | 3 | 1 | 3 | 1 | 3 |
| 184 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |

Rows 90 and 150 are exactly the closed forms proved in `FixedPointCounts.lean`
(`4^{[3∣n]}` and `2·2^{[2∣n]}`); row 110 is the constant `1` proved in
`ShiftsPolynomialsOrbits.lean`; row 184 is the constant `2` proved in
`ConstantPairRules.lean`; row 30 is the closed form `3` for even `n` and `1` for odd
`n`, also proved in `FixedPointCounts.lean`.  What remains open is a *uniform*
mechanism producing all such closed forms — see Conjecture C2.

## 3. Periodic points of Rule 110

Number of configurations with `f^[k] s = s`, for `n` (rows) and `k = 1..8` (columns):

| `n\k` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 2 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 3 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 4 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | 5 |
| 5 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 6 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 7 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 8 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | 13 |

The two 2-cycles found on `n = 4` are

```
1110 ↔ 1011      and      1101 ↔ 0111
```

(they are shifts of one another, consistently with `minimalPeriod_shiftLeft`).  The
first of them is the configuration `t110` used in
`CASimulationEmbeddings.rule110_t110_minimalPeriod`, and the descent embedding
transports it to every lattice with `4 ∣ n`.  The table also motivates Conjecture C3
(`4 ∣ n` is necessary for a non-fixed periodic point of rule 110).

## 4. Counterexample hunt

* "Fixed-point dimension tracks the Wolfram class" — already refuted in cycle 0; the
  present cycle strengthens the refutation: rules `46` and `110` sit in different
  Wolfram classes yet share all four bits controlling the fixed-point count, so
  `#V(46,n) = #V(110,n) = 1` for every `n` (proved).
* "A universal rule must have rich fixed-point structure" — false: `#V(110,n) = 1`
  for all `n`, while rule `150` (additive, Class 3) has `#V = 4` on even lattices.
* "A rule with no fixed point has no periodic orbit" — false: rule `51` has
  `#V(51,n) = 0` and yet *every* configuration lies on an exact 2-cycle (both proved).

## 5. OEIS

The two proved count sequences are periodic and too short/degenerate to warrant an
OEIS identification: `#V(150,n) = 2,4,2,4,…` and `#V(90,n) = 1,1,4,1,1,4,…`.  No OEIS
claim is made.
