# Round 47 part 42 — the eighth defective control, and what it did and did not touch

**2026-09-29. The control my closure rested on had never been run. Running it surfaced two
further defects — and, checked properly, neither reaches a committed claim.**

---

## 1. The control I owed and did not run

`Round47_SelectorClosed.md` concludes *"the lattice's polynomials give **zero** relations in
3000 attempts"*, and reasons from that to *"the lattice cannot help"*. **That inference
assumes the general-cubic (`P ≠ 0`) trial is working and correctly reporting none. It was
never tested.**

**Deterministic control** (not statistical — see §2), on the record's own instance
`N = 1333`, `f = X³ − 2`, `m = 20`, which is hand-verified in `Round46_Handover.md` §7d and
machine-checked in `RelationWitness.lean`:

| `(u,v)` | on cone | `l(m)` | `w` | `w² ≡ g(m)² (mod N)` | `chi_P` | `gcd` |
|---|---|---|---|---|---|---|
| (1,1) | yes | 784 | 28 | **YES** | +1 | 43 |
| (5,1) | yes | 90000 | 300 | **YES** | −1 | **1333** |
| (1,2) | yes | 3600 | 60 | **YES** | +1 | 31 |
| (−3,5) | yes | 26896 | 164 | **YES** | −1 | **1** |
| (1,6) | yes | 204304 | 452 | **YES** | +1 | 43 |

> **The trial is sound: it recovers the record's verified relations exactly.**

## 2. Defect the seventh: my first two controls were *underpowered*, not broken

Both sampled **3 instances** at a known rate of 0.082 per `f`. `P(0 in 3) = 0.92³ = 0.77` — so
**77% of the time a perfect control shows zero.** The first version was worse still: its filter
forced `Q = −m³−Pm`, always large, so it ran **zero trials** and reported `0 trials` as if it
were a measurement — the same "green control that tested nothing" defect already listed.

**Same defect, sampling flavour instead of instrument flavour.** A control that cannot
discriminate is not a control, however carefully it was written.

## 3. Defect the eighth: the factor-2 in `y`, and why it reaches nothing

The control's output shows `chi_P = −1` at `(5,1)` with `gcd = N` — the useless output. That
is the **factor-2 bug A16 flagged**, and it is real here:

```
gpar(u,v,P) = (P v^2 − 4u^2,  −4uv,  2v^2)      =  2 × the P=0 chart
=> l(m) = 4 v^4 A_P(t)   (verified: l(m)/4 == Ap(t) exactly)
=> y = w/(2 v^2),  NOT  w/v^2
```

Using `y = w/v²` **flips `chi_P` by `Jacobi(2, N)`** — which is `−1` at `N = 1333, 5461` and
`+1` at `N = 2537`.

**What it does and does not touch — checked, not assumed:**

| | status |
|---|---|
| `Round47_general_cubic.py` (committed) | **CORRECT.** It verifies `l(m) = 4v⁴A_P(t)` and never computes `y`. Confirmed numerically just now: `l(m)/4 == Ap(t)`. |
| the **Lean** (`RelationAlgebra.lean`, `RelationWitness.lean`, `DimensionalClosure.lean`, `DegreeFour.lean`) | **UNAFFECTED.** They use the **chart** `g = (−2u²,−2uv,v²)`, where `l(m) = v⁴A(t)` and `y = w/v²`. |
| every **measured** result (the `N^{−1/4}` exponent, the 73%/16.5% rates, the 191.5-bit crossover) | **UNAFFECTED** — all from the `P = 0` chart. |
| `Round47_SelectorClosed.md`'s *"zero relations in 3000"* | **UNAFFECTED** — the relation test (`w² ≡ g(m)² (mod N)`) happens **before** `y` is used. |

**So the closure stands.** And the reason it does is not luck: the `P = 0` chart, which every
measurement uses, never had the factor 2 — the bug lives only in the general-cubic
convention, which no measurement touched.

## The rule, now eight for eight

| # | the "negative" | what it was |
|---|---|---|
| 1 | "8/8 escapes to `chi_P = −1`" | a sign error — the curve for a different field |
| 2 | "`∞` sec/factor at 32+ bits" | a `continue` that never advanced `m` |
| 3 | "0 `f` found above 23 bits" | a probe budget below `N/(2·c_max)` |
| 4 | "EMPTY, decisively" | 4–5 `f` at a rate of 8% |
| 5 | "0/0 instances agree. PASS" | it ran **zero** instances |
| 6 | a monitor on a `grep -c` of a header row | it counted a header, not data |
| 7 | two controls reporting 0 in 3 instances | **underpowered**: 77% likely to show zero even when perfect |
| 8 | `chi_P = −1` with `gcd = N` | the factor-2 in `y` for the general-cubic convention |

> **Every one of these would have closed a live direction, and not one of them was found by
> reading the code.** Each was caught by a control that could fail — or, in cases 7 and 8, by
> insisting the control have a *known answer* before trusting its output.
