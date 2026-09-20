# Computational evidence — BATTERY-SCALING (round-27 #4, paper 94)

All numbers below are **exploratory** floating-point computations (Python, exact uniform
populations, entropies in bits).  They are *not* verified artifacts; the verified statements
are the Lean theorems in `Catalog/Bridges/BatterySubmodularity.lean`,
`Catalog/Bridges/BatteryCapacityLaw.lean` and `Catalog/Bridges/BatteryFactorBlindness.lean`,
each of which builds without `sorry`.

The role of this stage was to decide **which** conjectures were worth formalising, and in
particular to find out whether the reported hypothesis H1 ("the deficit grows monotonically")
is a law or only a law under a hypothesis.

## 1. Exact nested CRT battery, entangled label

Population: the full product `Z/31 × Z/23 × Z/9 × Z/8` (51336 individuals, uniform), dial `i`
reads the `i`-th residue, label `L = ((r₀+r₁) mod 2, (r₁+r₂) mod 3, (r₂+r₃) mod 4)`
(a label block that no single dial can see).

| dials k | I(joint;L) | Σ marginals | deficit | % of ceiling H(L)=4.5850 |
|---|---|---|---|---|
| 1 | 0.0014 | 0.0014 | +0.0000 | 0.0% |
| 2 | 1.0000 | 0.0021 | +0.9979 | 21.8% |
| 3 | 2.5850 | 0.0049 | +2.5801 | 56.4% |
| 4 | 4.5850 | 0.0304 | +4.5546 | 100.0% |

This reproduces the qualitative shape of the reported six-row table: monotone curve,
compounding deficit, saturation at the label-entropy ceiling — and it saturates *exactly* at
`H(L)` once the battery determines the label, which is the formalised statement
`TraceBattery.MI_eq_entropy_iff_determines`.

## 2. Product label: zero deficit at every k

Same population, label `L = (r₀ mod 2, r₁ mod 3, r₂ mod 3, r₃ mod 4)` (one block per dial):

| dials k | I(joint;L) | Σ marginals | deficit |
|---|---|---|---|
| 1 | 0.9992 | 0.9992 | +0.0000 |
| 2 | 2.5814 | 2.5814 | +0.0000 |
| 3 | 4.1664 | 4.1664 | −0.0000 |
| 4 | 6.1664 | 6.1664 | +0.0000 |

So the deficit is *not* forced to grow: with independent dials it is non-decreasing (this is
the formalised `TraceBattery.deficit_mono_of_independent`) but can stay flat at 0.

## 3. Counterexample hunt: is the deficit always non-negative?

No.  Duplicating a dial makes it strictly negative.  On the two-element population with the
identity label and two copies of the same one-bit dial:

```
I(joint;L) = 1.0000 bit,  Σ marginals = 2.0000 bits,  deficit = −1.0000 bit
```

and on `{0,1,2,3}²` with label `= first coordinate` and two copies of the "first coordinate"
dial, `D({1}) = 0.0000`, `D({1,2}) = −2.0000`.  This killed the unguarded form of H1 and is
the reason the Lean development carries both a guarded monotonicity theorem
(`deficit_mono_of_independent`) and a formal counterexample
(`deficit_neg_of_duplicate`, `exists_negative_deficit`).

## 4. Finite-sample bias of the deficit (why a measured deficit can mislead)

Sampling 20000 individuals uniformly from `Z/31 × Z/23 × Z/9 × Z/8` instead of enumerating it
produced

```
k=1 D=+0.0000   k=2 D=+0.0411   k=3 D=−0.0136   k=4 D=−0.0181
```

for a label whose exact deficit is identically 0 at every k: plug-in mutual information is
positively biased at small cell counts, exactly the "sparse-bias-dominated" regime the report
describes for the which-factor wall.  This motivated formalising factor-blindness as an
*identity* (`labelInfo_eq_zero_of_flip_symmetry`) rather than as a small measured number.

## 5. Which-factor wall, exactly zero

Population: the 20 ordered pairs of distinct residues mod 5; dial reads `(p+q) mod 5`;
label is the bit `p < q`.

```
H(dial) = 2.3219 bits,  H(which-factor) = 1.0000 bit,  I(dial ; which-factor) = 0.000000
```

The exact zero (not a small number) is what the Lean theorem
`TraceBattery.swap_which_factor_wall` certifies, together with the general statement that any
involution preserving all dials and flipping the label forces `I = 0`, at **every** battery
size.

## 6. Script used

```python
import itertools, math
from collections import Counter
def H(v):
    n = len(v); c = Counter(v)
    return -sum((k/n)*math.log2(k/n) for k in c.values())
def MI(a, b): return H(a) + H(b) - H(list(zip(a, b)))

mods = [31, 23, 9, 8]
pop  = list(itertools.product(*[range(m) for m in mods]))
lab  = [((x[0]+x[1]) % 2, (x[1]+x[2]) % 3, (x[2]+x[3]) % 4) for x in pop]
for k in range(1, 5):
    joint = [x[:k] for x in pop]
    I = MI(joint, lab)
    S = sum(MI([x[i] for x in pop], lab) for i in range(k))
    print(k, round(I, 4), round(S, 4), round(I - S, 4))
```

## 7. OEIS

No integer sequence is attached to this experiment (the objects are entropies of empirical
distributions), so no OEIS search was applicable.
