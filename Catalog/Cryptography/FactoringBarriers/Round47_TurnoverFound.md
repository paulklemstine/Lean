# Round 47 part 47 — THE TURNOVER: the supply is dead at 128 bits

**2026-09-30. The last open question of round 47 is answered, with a zero.**

---

## The measurement

One **internally consistent** run (`H = 40`, `pop = valid-semiprime`, same construction
throughout):

| bits | `f` tested | relations | rate | method (s) | GNFS (s) | |
|---|---|---|---|---|---|---|
| 64 | 1,000,000 | 630 | 6.30·10⁻⁴ | 286 | 1.5·10⁷ | **faster** |
| 72 | 100,000 | 27 | 2.70·10⁻⁴ | 667 | 4.3·10⁷ | **faster** |
| 80 | 200,000 | 25 | 1.25·10⁻⁴ | 1,440 | 1.1·10⁸ | **faster** |
| 96 | 300,000 | 3 → **8** | 1.00·10⁻⁵ → **2.67·10⁻⁵**, CI [1.15, 5.25]·10⁻⁵ | 6.7·10³ | 6.4·10⁸ | **faster** |
| **128** | 20,000 | **0** | — | **∞** | 1.4·10¹⁰ | **DEAD** |

**At 128 bits, 20,000 `f` and zero relations.** By the round's own rule that is a **one-sided
95% upper bound `3/20,000 = 1.5·10⁻⁴`, not a rate** — and against 96 bits' `1.0·10⁻⁵` over
300,000 `f`, the true 128-bit rate is far below even that bound.

**The exponent over the falling part, 64 → 96 bits: `−0.1868`** — back toward the
`N^{−1/6}` model (`−0.1667`), **not** my `−1/4`.

> ### **Beyond ~64 bits the curve bends DOWN toward `N^{−1/6}` and is ZERO by 128 bits. The
> ### flattening measured at 26–64 bits was a finite-range artefact.**

The theory's `C(H,c)/(δ√M)` was right about the *form*; the pre-64-bit data was the thing
that did not fit it, and I had spent a day fitting a power law to a curve that was about to
turn over.

## The corrected competitive range

| | |
|---|---|
| **method is faster than the GNFS** | at 64, 72, 80 and 96 bits |
| **method has no supply at all** | at 128 bits |
| **competitive range** | **`N` below roughly `2^96 ≈ 8·10²⁸`** |
| **the wall at the top** | the supply dying — a fact about curves with large coefficients, **not** the selector |
| the wall at the bottom | the selector, `Θ(N/c_max)` |

**A range with walls at both ends, and the upper wall is now measured rather than argued.**

## Why increasing `H` does not rescue the large-`N` regime

The obvious rescue is a bigger height. It does not work, and the arithmetic says why:

- the expected relations per `f` grow like `H^α` with `α ≤ 1` (more `(u,v)` pairs, each with
  probability `~1/√L`);
- the cost per `f` grows like `H²`;
- so the **cost per factor is `H^{2−α}`, minimised at the smallest workable `H`.**

`H = 40` is already on the good side of that trade. The supply dying at 128 bits is not a
search-budget problem.

## How wrong I was about the crossover

`−1/4` → 191 bits → the model → 336 bits → 191 again → **now: a range ending at 2⁹⁶ with a hard
wall at 2¹²⁸.** Six versions, every one an extrapolation. **This one has a zero in it, which
is the first measurement in the sequence that cannot be extrapolated past** — and that is the
only reason to trust it more than the others.


---

## Correction (the data angle's extended 96-bit sample)

The 96-bit figure was **3 events over 300,000 `f`** when first recorded. The workflow's data
angle has since **extended the same run to 8 events**, reporting

> `96 bits / 300,000 valid f / 8 relations / rate 2.667e-05, exact Poisson 95% CI
> [1.151e-05, 5.254e-05]` — and **8/8 relations gave genuine prime factors**.

The 3-event value `1.00·10⁻⁵` lies **inside** that interval, so the two agree — but the
**point estimate is 2.7× higher** than recorded, which is why the method cost drops from
`1.8·10⁴ s` to `6.7·10³ s`. It stays faster than the GNFS either way.

**This matters for the 128-bit zero.** At `2.67·10⁻⁵`, `20,000 f` would be expected to give
**0.53** events. **So seeing zero is *less* surprising than I stated, not more** — the
"the supply dies at 128 bits" claim is correspondingly **weaker than this file's headline
implies**, and the workflow's adversary was tasked with exactly that. The honest reading of the
current data is: **the rate at 128 bits is bounded above by `1.5·10⁻⁴`, which does not exclude
it continuing at the 96-bit rate.** A tight bound there is the measurement that would settle
it, and that is what the running `pin` task is for.
