# Computational evidence: the cyclic splitting-type channel

All numbers below were first produced by exact rational/symbolic enumeration over
the unit group (Python, `fractions.Fraction`, logarithms kept symbolic as integer
combinations of `log₂ 2, log₂ 3, log₂ 5`), and *every one of them has since been
re-derived and machine-checked inside Lean* in
`Catalog/Shared/CyclicTypeChannelValues.lean` (the fibre-cardinality enumerations
are discharged by kernel evaluation, the logarithmic algebra by `norm_num`/`ring`).

## 1. Model

For a cyclic Galois group `C n` (for `Q(ζ_f)` with `f = n + 1` prime) fix a
generator `g` and write an unramified prime as `g ^ a`, `0 ≤ a < n`.  The
splitting type is

    T(a) = ord(g^a) = n / gcd(a, n).

A semiprime `N = p q` corresponds to the pair `(a, b)` and its own residue is
`a + b mod n`.  Both facts are proved in Lean
(`orderOf_pow_eq_ordType`, `exists_generator_ordType`).

## 2. Small-case type distributions

| n | states `T` | counts | `H(T)` exact | numeric |
|---|---|---|---|---|
| 2 | 1,2 | 1,1 | `1` | 1.0000 |
| 4 | 1,2,4 | 1,1,2 | `3/2` | 1.5000 |
| 6 | 1,2,3,6 | 1,1,2,2 | `1/3 + log₂3` | 1.9183 |
| 10 | 1,2,5,10 | 1,1,4,4 | `-3/5 + log₂5` | 1.7219 |
| 12 | 1,2,3,4,6,12 | 1,1,2,2,2,4 | `5/6 + log₂3` | 2.4183 |
| 16 | 1,2,4,8,16 | 1,1,2,4,8 | `15/8` | 1.8750 |

The counts are exactly `φ(d)` for `d ∣ n` — this is now a theorem for all `n`
(`card_ordType_eq_totient`), together with the closed form
`H(T) = ∑_{d ∣ n} (φ(d)/n) log₂(n/φ(d))` (`typeEntropy_formula`).

## 3. The semiprime type-pair channel

| n | `H(Π)` | `H(Π ∣ N)` | `I_pair` exact | numeric | > 1 bit? |
|---|---|---|---|---|---|
| 2 | `3/2` | `1/2` | `1` | 1.000000 | at cap |
| 4 | `19/8` | `9/8` | `5/4` | 1.250000 | **yes** |
| 6 | `-1/18 + 2log₂3` | `1/18 + log₂3` | `log₂3 - 1/9` | 1.473851 | **yes** |
| 10 | `-93/50 + 2log₂5` | `1/50 - (12/25)log₂3 + log₂5` | `-47/25 + (12/25)log₂3 + log₂5` | 1.202710 | **yes** |
| 12 | `7/8 + 2log₂3` | `53/72 + log₂3` | `5/36 + log₂3` | 1.723851 | **yes** |
| 16 | `395/128` | `225/128` | `85/64` | 1.328125 | **yes** |

These agree to four decimals with the Monte-Carlo values reported for 30k
semiprimes (1.2452 for `C₄`, 1.4711 for `C₆`).  The exact values are Lean
theorems `Ipair_val_2, …, Ipair_val_16`; the strict inequalities are
`above_binary_cap`.

## 4. Lossy read-outs (counterexample hunt for "the root count is enough")

| n | root-count channel `H(nr)` | full `H(T)` |
|---|---|---|
| 4 | `2 - (3/4)log₂3 ≈ 0.8113` | `1.5` |
| 6 | `1 + log₂3 - (5/6)log₂5 ≈ 0.6501` | `1.9183` |

| n | `Is` (split-count pair channel) | `I_pair` |
|---|---|---|
| 4 | `19/8 - (21/16)log₂3 ≈ 0.2947` | `1.25` |
| 6 | `19/9 + log₂3 - (55/36)log₂5 ≈ 0.1487` | `1.4739` |

Both read-outs are *deterministic coarsenings* of the type, so the general
data-processing inequality `uEnt_comp_le` already forces `≤`; the exact values
show the inequalities are strict (`rootCount_lossy_4/6`, `Isplit_lt_Ipair_4/6`).

## 5. Counterexample hunt

* *"Every symmetric semiprime fork is capped at 1 bit."*  **False**: `n = 4`
  already gives `5/4` (`one_lt_Ipair_four`).
* *"`I_pair` grows with `n`."*  **False**: `I_pair(10) = 1.2027 < I_pair(6) =
  1.4739` and `I_pair(16) = 1.3281 < I_pair(12) = 1.7239`.  The governing
  parameter is the divisor structure, not the size: among the computed orders
  the maximum is at `n = 12`, which has six divisors
  (`Ipair_twelve_max`).
* *"The channel could be negative / could exceed the pair entropy."*  Ruled out
  in general by `Ipair_mem_Icc` (Gibbs).
* *"Thickening `p mod f` to `p mod f²` adds information."*  **False** in general:
  `thickening_zero` shows any injective refinement of the residue leaves the
  type channel at `H(T)`.

## 6. Reproduction script

```python
from math import gcd
from fractions import Fraction as F
from collections import Counter

def ordT(a, n): return n // gcd(a, n)
def pt(a, b, n): return tuple(sorted((ordT(a, n), ordT(b, n))))

def ent(counts):                      # returns log2-coefficient vector
    N = sum(counts)
    ...                               # log2 N - (1/N) Σ c log2 c, kept symbolic

for n in [2, 4, 6, 10, 12, 16]:
    pc = Counter(pt(a, b, n) for a in range(n) for b in range(n))
    HP = ent(list(pc.values()))
    HC = sum(F(1, n) * ent(list(Counter(pt(a, (c - a) % n, n)
             for a in range(n)).values())) for c in range(n))
    print(n, HP - HC)
```

No OEIS sequence was matched: the pair `(n, I_pair(n))` is a real-valued,
divisor-structure dependent quantity rather than an integer sequence.  The
integer data it is built from (`φ(d)` counts) is of course A000010.

---

## 7. Second cycle: prime orders, prime powers, and the odd witness

### 7.1 The prime-order channel (closed form now formal)

`Ipair_prime` proves, for every prime `p`,

`I_pair(p) = log₂p − (p−1)(2p−1)/p² · log₂(p−1) + (p−1)(p−2)/p² · log₂(p−2)`.

Evaluating it (and cross-checking against the independent enumerations
`Ipair_val_3`, `Ipair_val_5`):

| p | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 59 |
|---|---|---|---|----|----|----|----|----|----|----|----|
| `I_pair(p)` | 0.47385 | 0.20271 | 0.11411 | 0.05190 | 0.03864 | 0.02398 | 0.01965 | 0.01395 | 0.00918 | 0.00813 | 0.00252 |

All are `< 1`, in agreement with the theorem `Ipair_prime_lt_one`, and
`p²·I_pair(p) − log₂p` = 2.879, 2.885, 2.885, 2.886, 2.886, … → `2/ln 2 = 2.8854`.

### 7.2 Prime powers: an exact geometric law (conjectural)

Direct enumeration of the `n²`-box for `n = p^k`:

| n | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 3 | 9 | 27 | 5 | 25 | 125 | 7 | 49 | 343 |
|---|---|---|---|----|----|----|-----|---|---|----|---|----|-----|---|----|-----|
| `I_pair` | 1 | 1.25 | 1.3125 | 1.328125 | 1.33203 | 1.333008 | 1.3332520 | 0.473851 | 0.526502 | 0.532352 | 0.202710 | 0.210818 | 0.211143 | 0.114105 | 0.116434 | 0.116481 |

Every entry matches `I_pair(p^k) = (1 − p^(−2k))·p²/(p²−1)·I_pair(p)` to `10⁻⁹`
(for `p = 2` this is `(4^k−1)/(3·4^(k−1))`, reproducing the Lean values
`5/4, 21/16, 85/64`).  This is conjecture **C1** of `FUTURE_DIRECTIONS.md`.

### 7.3 Counterexample hunt: does an *odd* order break the one-bit cap?

The catalog's small odd orders `3, 5, 9, 15` are all below the cap, suggesting
"evenness is necessary".  Summing the certified prime bounds under CRT additivity
gives the counterexample:

| accumulated order | certified lower bound for `I_pair` |
|---|---|
| 9 | 0.52650 |
| 9·5 | 0.72906 |
| 9·5·7 | 0.84246 |
| 9·5·7·11·13 | 0.93204 |
| 9·5·…·23 | 0.98842 |
| 9·5·…·29 | 0.99748 |
| **9·5·…·31 = 300840735195** | **1.00528 > 1** |

Each row uses rational bounds `a/4096 ≤ log₂x ≤ c/4096` certified by integer
inequalities `2^a ≤ x^4096 ≤ 2^c`; this is exactly the Lean proof of
`one_lt_Ipair_odd_order`.

### 7.4 How far can it go?

Summing `p²/(p²−1)·I_pair(p)` over all odd primes below `2·10⁶`:

* supremum over **odd** orders ≈ `1.08405`;
* supremum over **all** orders ≈ `4/3 + 1.08405 = 2.41738`.

A knapsack search over prime-power multisets gives the conjectured *smallest* odd
above-cap order `3³·5²·7·11·13·17·19·23 = 5019589575` (value ≈ `1.00540`), about
60× smaller than the order proved in Lean.

No OEIS match was found for any of the new sequences (all are real-valued).

## 8. The prime-power ladders (this cycle)

Exact enumeration over the full exponent box `Z/n × Z/n` (all `n²` pairs, exact
rational entropies in the basis `{1, log₂3}`) for the two new prime-power orders:

| n | fibre profile of `Π` | H(Π) | H(Π \| N) | I_pair |
|---|---|---|---|---|
| 27 = 3³ | `[1,4,4,12,24,36,36,72,216,324]` | `(26/9)log₂3 − 1768/729` | `(143/81)log₂3 − 286/243` | `(91/81)log₂3 − 910/729 ≈ 0.53235` |
| 32 = 2⁵ | `[1,1,2,4,4,4,8,8,16,16,16,16,32,32,32,64,64,64,128,256,256]` | `1643/512` | `961/512` | `341/256 = 1.33203` |

Both agree with the conjectured closed form
`I_pair(p^k) = (1 − p^(−2k))·p²/(p²−1)·I_pair(p)`:
`(4/3)(1 − 4⁻⁵) = 341/256` and `(1 − 3⁻⁶)(9/8)(log₂3 − 10/9) = (91/81)log₂3 − 910/729`.
Both values are now Lean theorems (`Ipair_val_32`, `Ipair_val_27` in
`Catalog/Shared/CyclicTypeChannelPrimePower.lean`), so the increments

* `I_pair(4) − I_pair(2) = 1/4`, `I_pair(8) − I_pair(4) = 1/16`,
  `I_pair(16) − I_pair(8) = 1/64`, `I_pair(32) − I_pair(16) = 1/256`;
* `I_pair(9) − I_pair(3) = (1/9)·I_pair(3)`, `I_pair(27) − I_pair(9) = (1/81)·I_pair(3)`

are verified, not merely measured.  A structural regularity visible in the
enumeration and used in the formalisation: for `n = 2^k` every **nonzero**
residue class `c` has the same conditional fibre profile `[2,2,4,…,2^(k−1)]`
(hence the same conditional entropy), while the class `c = 0` has profile
`[1,1,2,…,2^(k−1)]`; for `n = 3^k` the classes split by the 3-adic valuation of `c`.
