# Conditioning the Base

## A free 1.2× improvement to the only factoring construction that works — and a tight proof that nothing else is left

**Round 50 · 2026-10-04 · Confirmed independently by two agents**

---

## Abstract

The multiplicative-relations factoring method of Stange (arXiv:2211.06821) has a success
probability that a previous round **derived exactly**: `20/27 = 0.740740…`, the classical
*order-finding* rate, arising as `P( v₂(ord_p g) ≠ v₂(ord_q g) )` for a **uniform** `g`.

**In fifty rounds of work on this construction, nobody ever questioned the uniformity of
`g`.** Conditioning on the Jacobi symbol — computable *without factoring* — gives

> **`20/27 → 8/9`, a ratio of exactly `1.2×`, at a cost of one `O(log n)` Jacobi symbol.**

We prove the improved rate in closed form, confirm it by two independent implementations
and 60,000 trials, measure the **end-to-end** effect on the actual algorithm (`0.773 → 0.877`
over 300 fresh moduli, McNemar `p ≈ 0.001`), and — the part that matters more than the gain —
**close the search**: the residual lever is `0.0074` and cannot be reached without factoring.

---

## 1. The mechanism

Write `s_p = v₂(p−1)`, `λ_p = s_p − v₂(ord_p g)`. Then

> **`λ_p = 0` ⟺ `g` is a quadratic non-residue mod `p`** — verified by full enumeration.

Since `Jacobi(g/n) = (g/p)(g/q) = (−1)^{λ_p + λ_q}`, choosing `g` with

> **`Jacobi(g/n) = −1`**

**forces exactly one side to be a non-residue** — and therefore forces the two valuations to
disagree. **The crucial point: this requires no knowledge of which factor is which.** A Jacobi
symbol is a *product*; conditioning the product to `−1` forces the two factors to disagree
without ever separating them.

## 2. The rate, in closed form and under measurement

`E[FAIL] = 2(1/12 − 1/28) = 1/9`, hence

| base | success | expected attempts |
|---|---|---|
| uniform `g` | **`20/27 = 0.740740…`** | 1.35 |
| **`Jacobi(g/n) = −1`** | **`8/9 = 0.888889…`** | **1.125** |

Ratio **exactly 1.2×**.

| check | result |
|---|---|
| closed form, cross-checked cell-by-cell in code for `a,b ≤ 19` | `E[FAIL] = 1/9` |
| measurement, 60,000 trials | **0.8835** (z = **+79.79**) |
| uniform control, same harness | **0.7406** (z = −0.06σ) |
| exhaustive enumeration, 210/210 cells | zero error |
| **independent reimplementation** (own Miller–Rabin / Legendre / Jacobi, no sympy) | z = +0.06, +0.54, **0/7197** violations of the crux lemma |
| **end-to-end on the actual algorithm**, 300 fresh moduli | **`0.773 → 0.877`**, McNemar **p ≈ 0.001** |

Cost: **one `O(log n)` Jacobi symbol** — measured 60–7000× cheaper than a single modular
exponentiation, against a phase costing ~4798 multiplications per factor. Nothing else in the
pipeline changes.

## 3. Where the gain comes from — and the number that would have lied

**All of it is on the diagonal.** Among the 94 moduli with `s_p = s_q`:

- uniform: **50/94**
- Jacobi-conditioned: **94/94** — every one.

Those are precisely the cells where uniform `g` is *worst* (success 1/2 at `s = 1`).

**Off-diagonal the conditioned base is slightly WORSE**, exactly as the per-cell table predicts.
A pooled "+0.10" would therefore have misrepresented the mechanism entirely: the truth is
"a diagonal blow-up and a small off-diagonal loss", not "everything improved".

## 4. Closing the search — the part worth more than the gain

The optimality statement requires separating two claims that are easy to conflate:

- **"No `g` beats `8/9`" is FALSE.** An oracle knowing `p` and `q` reaches **1.0**.
- **The true claim** is over `g` **computable from `n` without factoring** — and it **holds**,
  because separating the two Legendre symbols *is* factoring.

**And the bound is tight.** The unimplementable oracle reaches only **0.8963**, so

> **the entire remaining lever is `0.0074`, and it is unclosable without factoring.**

A `v₂(n−1)`-aware policy was measured at **0.8962 vs 0.8966** (`z = −0.23`) — not worth the
code. **The search is closed.**

## 5. Scope — stated first, because it is the thing most likely to be misread

**This is a 1.2× improvement to a phase that is 5% of the cost.** Relation-finding is **95%**,
and relation-finding *is* the number field sieve.

**This is not a factoring advance.** It is a real, free, exactly-derived improvement to a
working algorithm — and on the cost metric that decides RSA-scale work it moves almost nothing.
Stange's own cost analysis is dominated by a factor this does not touch.

## 6. What the literature does and does not settle

The nearest prior art is **real but unread**: DOI `10.59254/sbpo-2025-212078`, *"Boosting
Shor's Factoring Success with the Jacobi Symbol…"* (SBPO 2025). Identity, authors, venue,
volume and dates are Crossref-confirmed; **the contents are not** — publisher CAPTCHA-blocked,
no open-access copy, `abstract: null`. **A successor must re-derive §2 independently and must
not cite that paper's contents.**

Separately: **Bourdon–Williams**, the sharpest bound in existence (`2Si(4π)/π ≈ 0.9499`), bounds
**quantum phase-estimation noise for a fixed base** — a different probability entirely. Reading
it as comparable to `20/27` would repeat the scope error that already cost this programme a
FATAL.

Two genuinely empty regions were found, with a positive control on the same route in the same
session returning 80 and 22 results against 11 consecutive true zeros: the classical
**base-distribution** axis, and the **conditional 2-adic law** `P(v₂(ord_p g) | s_p)` — no
results anywhere reachable.

## 7. A control that was green and wrong

The second agent's first honest sampler **failed its own 2-adic control at z = −18.5**, exposing
that it had scored `λ_p ≠ λ_q` instead of `k_p ≠ k_q`. Those agree **only on the diagonal**, and
the error had produced an impossible **12000/12000**. Separately, `stange.gen_semiprime` returns
`(n,p,q)` and not `(p,q,n)`, which had silently made the entire end-to-end run read 0/40.

Six defects are recorded in `notes/II_baseg.md` with the control that caught each. The first is
worth carrying:

> **Two candidate formulas disagreed, and the one that was WRONG matched the Monte Carlo to two
> decimal places.** Only exhaustive per-cell enumeration separated them. A green control that was
> wrong — and without the exhaustive check it would have shipped the wrong *mechanism*, not just
> the wrong number.

## Reference

- N. Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821. Algorithm 2.2
  takes `g` as an **explicit free input** (p. 4); she points at Shor's random-`g` loop as the model
  (p. 3) but **never analyses the splitting probability**. That omission is what this paper fills.
- Ekerå, live single-run analysis of Shor's algorithm, Cor. 3.4, p. 23 — **assumes uniform `g`**,
  so this lever is orthogonal to that contribution and untouched by it.
