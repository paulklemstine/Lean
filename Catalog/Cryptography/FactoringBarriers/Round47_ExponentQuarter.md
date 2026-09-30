# Round 47 part 40 — the supply exponent is −1/4, NOT −1/6, and the crossover halves

**2026-09-29. Measured in the live `m ~ N^{1/3}` region, 400 `f` per size, H = 40, by
direct construction so the `m`-window is controlled and nothing has to be factored.**

---

## The measurement

| bits | `f` tested | relations | **rate** | ± Poisson σ | model `N^{−1/6}` predicts |
|---|---|---|---|---|---|
| 24 | 400 | 163 | **0.4075** | 0.078 | 0.082 |
| 28 | 400 | 77 | **0.1925** | 0.114 | 0.052 |
| 32 | 400 | 35 | **0.0875** | 0.169 | 0.032 |
| 36 | 400 | 20 | **0.0500** | 0.224 | 0.021 |
| 40 | 400 | 10 | **0.0250** | 0.316 | 0.013 |

**Least-squares fit of `log(rate)` on `log N`:**

> **`rate = exp(3.2111) · N^{−0.2500}`,   R² = 0.9969**

**The observed decay is a factor ~2 per 4 bits — the exponent is `−1/4`, not the `−1/6` the
density model predicts.** The model is wrong by a factor `N^{−1/12}`. The density argument
(`l(m) ~ m H⁴`, square-probability `~1/(2√X)`, `H²` pairs) gives `1/(2N^{1/6})`; the data
says something slightly worse. **I am recording the measurement and flagging the model as
failed, not repairing the model to fit.**

**Uncertainty, stated:** with `T = 10` at 40 bits the relative error there is 32%, and a
weighted refit would move the slope. The honest range on the exponent is roughly
`[−0.20, −0.31]`, which is enough to distinguish it from `−1/6 = −0.167` but not to quote
three digits.

## THE CROSSOVER HALVES

| bits | method (s) | GNFS (s) | ratio | |
|---|---|---|---|---|
| 64 | 4.8·10² | 1.6·10⁷ | 3.1·10⁻⁵ | **faster** |
| 96 | 1.2·10⁵ | 6.4·10⁸ | 1.9·10⁻⁴ | **faster** |
| 128 | 3.1·10⁷ | 1.4·10¹⁰ | 2.3·10⁻³ | **faster** |
| 160 | 7.9·10⁹ | 1.9·10¹¹ | 0.042 | **faster** |
| **191.5** | — | — | **1** | **CROSSOVER — `N ≈ 2^192 ≈ 10^58`** |
| 200 | 8.1·10¹² | 3.3·10¹² | 2.4 | slower |
| 256 | 1.3·10¹⁷ | 1.1·10¹⁴ | 1.2·10³ | slower |
| 2048 | 9.2·10¹⁵¹ | 1.5·10³⁵ | 6·10¹¹⁶ | slower |

> ### **The competitive range is `N` up to ≈10^58, not ≈10^101.**
> **`Round47_Crossover336.md` is superseded on this point and its 336-bit figure used the
> *model* exponent, which the data rejects.**

## Why the region matters, and what the 191.5 bits does and does not mean

The measurement is in the **`m ~ N^{1/3}` window** — the live branch, per
`Round47_TheMSelection.md`. **But the method as a whole still has to get an `f` into that
window, and the two available routes fail on opposite sides of one trade:**

- the **scan** reaches the window, at `N/(2·c_max)` probes — 2.8·10⁷ at 32 bits, measured;
- the **lattice** costs 60 µs but returns `m ~ N`, the dead cell.

**So the 191.5-bit crossover is the crossover *conditional on reaching the good window*, and
it is NOT yet the crossover of a usable algorithm.** A usable algorithm needs a cheap
selector for small `m` — the open problem A16's analysis leaves sharp, and the one remaining
thing standing between this result and a method.

## What is now settled about the supply

| | |
|---|---|
| the curve is **not** empty — a subagent's "EMPTY, decisively" was a 4–5 `f` sample | refuted, 11,638 `f` at 26 bits |
| the exponent is **`−1/4`** (R² = 0.997), **not** `−1/6` | measured, 5 sizes |
| the live region is **`m ~ N^{1/3}`**; the lattice's `m ~ N` is the dead cell | 2×2 at two sizes |
| the crossover **conditional on the window** is **191.5 bits** | fitted, not modelled |
| reaching the window cheaply | **OPEN — the one thing left** |
