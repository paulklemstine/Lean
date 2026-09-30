# Round 47 part 46 — a candidate mechanism for the "unidentified" prefactor, and an honest test that lacked power

**2026-09-30. The theory angle derived `rate = C(H,c)/(δ√M)` and flagged that
`observed / 2^{−b/6}` grows **2.09 → 2.66 → 11.72** across 26/40/64 bits, mechanism
unidentified. Here is the best candidate, and an honest report of testing it.**

---

## The candidate

`rate = C(H,c) / (δ · √M)`, and **both** `C(H,c)` and `δ` *fall* with size:

| | falls because | effect on `rate` |
|---|---|---|
| `C(H,c)` | small `c` is a degenerate case with a tiny `L = 8u³v + cv⁴` and hence a large `rho/√L` — measured **29.1 at `c=1` against 4.6 at `c=201`** | smaller `C` for larger `c` |
| `δ` (semiprime density `~loglog N/log N`) | falls with `N`: **0.160 at 26 bits → 0.085 at 64** | smaller `δ` **raises** the rate |

Since `rate ∝ 1/(δ√M)`, the second effect **pushes the curve flatter than `N^{−1/6}`**, which is
exactly the observed shape. **The candidate is that the two effects compound.**

## The test I ran, and why it does not settle it

I measured the count of `(u,v)` with `l(m) = w²` directly, for fixed `m` in `[200, 400]`,
`H = 30`, across 18 values of `c`, and asked whether it tracks `C(H,c)`.

```
Pearson correlation between C(H,c) and the measured count:  0.640   (n = 18)
measured counts:  0.00 .. 3.40   (most cells are 0 or 1)
C(H,c):           4.6  .. 29.1
```

> **This test is UNDERPOWERED and I am not claiming the mechanism.** At `M = 400` the expected
> count per `f` is `C/√M ≈ 0.65`, so the cells are Poisson noise around 0–1. A correlation
> computed on eighteen cells that are mostly zero is not evidence in either direction.

**Reporting it as "the mechanism is `C` and `δ` compounding" would be exactly the error this
round has made nine times** — a suggestive correlation read as a result, on a sample that
cannot carry it.

## What would settle it

The rate as a function of `c` **at 64-bit scale**, with enough `f` per `c` that each cell has
`≥ 30` events. At the measured 64-bit rate of `0.0072`, that is `~4000 f` per `c` value — and
the 64-bit pool is `~2.6·10^17`, so the sample is available; the constraint is the number of
distinct `c` values the construction admits with enough multiplicity. **This is the experiment,
and the workflow's data angle is independently running the 96/128-bit counterpart of it.**

## The honest position

- **Established and verified:** the exact count `#{m} = rho·(√(LM+K) − √(Lm₀+K))/L`, the
  selector barrier `Θ(N^{1/6}·N/c_max)`, the perfect gate at `28,084/28,084`.
- **Unresolved:** *why the measured curve is flatter than the exact count predicts.* Two
  candidate causes, identified, neither confirmed at adequate power.
- **Not at stake:** the round's close. The barrier is the selector, and that follows from the
  exact count **independently of how the prefactor behaves** — a larger prefactor buys a
  constant number of extra `f` and does not change a `Θ(N/c_max)` selector cost.
