# Computational evidence — Conjecture A (trace distributions of finite group actions)

The multiset data below was produced by `#eval` inside the project's Lean environment
(Lean 4.28.0 / mathlib4), using the definitions in `Catalog/Logic/TraceDistribution/`.
The group-action tables were computed from the *proved* graded Burnside identity
`orbitCount_mul_card_group` (orbit counts of a `G`-set are noncomputable in Lean, so
they are derived from the fixed-point data rather than evaluated).  Where a statement is
*proved* rather than merely computed, the corresponding Lean theorem is named.  Nothing in this file is used as a substitute for a proof: every claim that
appears in the `.lean` files is proved there without `sorry`, `axiom` or `native_decide`.

---

## 1. Small-case calculations: the orbit spectrum of a `G`-set

For a finite group `G` acting on a finite set `X`, graded Burnside
(`orbitCount_mul_card_group`, proved) gives

```
|orbits of G on X^k| · |G| = ∑_{g ∈ G} |X^g|^k .
```

`G = ℤ/2`:

| `G`-set `X`             | trace distribution `{|X^g|}` | `k=0` | `k=1` | `k=2` | `k=3` | `k=4` |
|-------------------------|------------------------------|-------|-------|-------|-------|-------|
| regular `G`             | `{2, 0}`                     | 1     | 1     | 2     | 4     | 8     |
| one point `Unit`        | `{1, 1}`                     | 1     | 1     | 1     | 1     | 1     |
| `G ⊕ G`                 | `{4, 0}`                     | 1     | 2     | 8     | 32    | 128   |
| `G ⊕ Unit`              | `{3, 1}`                     | 1     | 2     | 5     | 14    | 41    |
| trivial on 4 points     | `{4, 4}`                     | 1     | 4     | 16    | 64    | 256   |

Observations that drove the formalisation:

* `regular G` and `Unit` agree at `k = 0` and `k = 1` and first separate at `k = 2`.
  This is **proved in general** for every finite group of order `≥ 2` as
  `TraceDistribution.regular_vs_point_separation`, and turned into the impossibility
  statement `TraceDistribution.main_theorem_fails_for_range_one`.
* `G ⊕ G` and `G ⊕ Unit` also agree at `k = 0, 1` and separate at `k = 2`.
* For `|G| = 2` the main theorem's range is `k ≤ max(|X|,|Y|) = 2`, and the pair
  (`regular G`, `Unit`) shows that `k ≤ 1` is *not* enough.  So the bound is attained.

`G = ℤ/3`: regular `{3,0,0}` gives orbit counts `1, 1, 3, 9, 27, …`; the one-point set
gives `1, 1, 1, 1, …`.  In general the regular `G`-set has `|G|^{k-1}` orbits on
`k`-tuples (`TraceDistribution.orbitCount_regular_succ`, proved).

---

## 2. Counterexample hunt: how many power sums are really needed?

The combinatorial engine (`multiset_eq_of_powerSum_eq`) says: a multiset of naturals
with all values `< n` is determined by `p_0, …, p_{n-1}`.  We searched for pairs that
survive as long as possible.

Hand-checked separations:

| `A`             | `B`             | `p_0` | `p_1` | `p_2` | first separation |
|-----------------|-----------------|-------|-------|-------|------------------|
| `{1,4}`         | `{2,3}`         | 2 = 2 | 5 = 5 | 17 ≠ 13 | `k = 2`        |
| `{0,1,2}`       | `{0,0,3}`       | 3 = 3 | 3 = 3 | 5 ≠ 9   | `k = 2`        |
| `{4,4,0,0}`     | `{4,2,2,0}`     | 4 = 4 | 8 = 8 | 32 ≠ 24 | `k = 2`        |

The extremal families are the *even/odd parts of the alternating binomial measure*,
`binomEven n` and `binomOdd n`.  Evaluated in Lean:

```
#eval (binomEven 2, binomOdd 2)   -- ({0, 2}, {1, 1})
#eval (binomEven 3, binomOdd 3)   -- ({1, 1, 1, 3}, {0, 2, 2, 2})
#eval (binomEven 4, binomOdd 4)   -- ({0,2,2,2,2,2,2,4}, {1,1,1,1,3,3,3,3})
```

Power sums `(p_j(binomEven n), p_j(binomOdd n))`:

```
n = 2, j = 0..2 : [(2, 2), (2, 2), (4, 2)]
n = 3, j = 0..3 : [(4, 4), (6, 6), (12, 12), (30, 24)]
n = 4, j = 0..4 : [(8, 8), (16, 16), (40, 40), (112, 112), (352, 328)]
n = 5, j = 0..5 : [(16,16), (40,40), (120,120), (400,400), (1440,1440), (5560, 5440)]
```

So for each `n` the two multisets agree on `p_0, …, p_{n-1}` and differ at `p_n`.  All
their values lie in `{0, …, n}`, and their joint support is exactly `{0, …, n}`.  Hence
the threshold `n + 1` in `multiset_eq_of_powerSum_eq` is **exactly optimal**.  Proved as
`TraceDistribution.powerSum_rigidity_fails_below_threshold` and
`TraceDistribution.exists_powerSum_agreeing_ne`.

---

## 3. An OEIS-visible pattern

The *gaps* at the first degree of disagreement are

```
n :        2    3    4     5
gap:       2    6   24   120
```

i.e. `n !` — **OEIS A000142** (factorials, `1, 1, 2, 6, 24, 120, 720, …`).  This is not
a coincidence: it is the classical value of the `n`-th forward difference of `x ↦ x^n`.
Proved in general as `TraceDistribution.binom_powerSum_top_gap`:

```
p_n(binomEven n) − p_n(binomOdd n) = n !   (in ℤ)
```

The orbit-count sequence of the regular `ℤ/2`-set is `1, 1, 2, 4, 8, 16, …`, i.e.
`2^{k-1}` for `k ≥ 1`, and the `G ⊕ Unit` sequence is `1, 2, 5, 14, 41, … = (3^k + 1)/2`.
These are recorded as observations; the general formulas that the project *proves* are
`orbitCount_regular_succ` (`|G|^{k}` orbits on `(k+1)`-tuples of the regular set) and
`orbitCount_unit` (always `1`).

---

## 4. Scope of the evidence

The evidence stage was used to (i) fix the correct threshold (`max(|X|,|Y|)` rather than
`|X|`, and the group-order variant `2·|G|`), (ii) confirm that `k ≤ 1` is insufficient
before investing in the general separation theorem, and (iii) discover the factorial
gap.  Every one of these observations was subsequently converted into a fully proved
Lean theorem; none of them is reported here as a substitute for proof.
