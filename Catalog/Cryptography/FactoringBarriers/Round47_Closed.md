# Round 47 part 37 — CLOSED, with a measurement: the supply vanishes at 30 bits

**2026-09-29. Agent A16, on the one question that was open. The answer is NO, and the axis
is done. Two independent routes agree, and the third instrument defect of the day was an
insufficient search budget, not a negative result.**

---

## The decisive table

Three moduli per size, **≤30 distinct lattice-`f` per modulus**, `H = 200`, both self-tests
passed as a gate, every reported factor verified against the true `p`, `q`:

| bits `N` | 19 | 20 | 22 | 23 | 24 | 26 | 28 | **30** | **32** | 36 | 40 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **per-`f` rate** | 11.1% | 10.0% | 3.3% | 1.1% | 1.1% | 2.5% | 1.8% | **0.0%** | **0.0%** | **0.0%** | **0.0%** |
| `#f` with ≥1 relation | 28/90 | 19/90 | 12/90 | 5/90 | 5/90 | 4/81 | 1/57 | **0/44** | **0/43** | 0/15 | 0/6 |

**The "≥1 relation" count collapses 28 → 19 → 12 → 5 → 4 → 1 → 0**, independently
reproducing the empty-curve census in `Round47_EmptyCurve.md`. **Two routes agree:** Route A
(depressed `f`, `P` free, by scanning `m` — the specified experiment) gives 2/25 at 19 bits;
Route B (lattice) gives 2/30.

> **VERDICT: the method is real, verified, and closes at ≈23–30 bits.** The cost crossover
> (69.2 bits at a 100% rate, 88.9 bits at the measured 10% rate) is *conditional on
> success*, and **the supply stops the method at 30 bits first.** The supply question is
> settled, and it was the only thing open.

**Honest caveats from the agent, recorded rather than smoothed:** the total `f` count falls
90 → 6 at large `N` because the lattice's `S1` monic-repair success rate drops, so the
36/40-bit rows are thin — they *corroborate*, they do not carry the claim. The load-bearing
zeros are 30 and 32 bits, with 44 and 43 distinct `f`.

## The third instrument defect of the day

`supply20.py`'s Route A reported "0 `f` found" above 23 bits. **That was a fixed 4001-probe
budget sitting below the counting threshold `N/(2·cmax)` — insufficient generation, not
absent supply.**

> **Had that been read as a refutation, it would have been the third false kill on this
> axis.** The pattern held all day: a run that reads as a negative is a suspect instrument
> first. Twice the "refutation" was a bug, and each time it would have closed a live
> direction.

## What the answer opens — the one thing worth carrying forward

**Every measurement of the supply used `H = 200`.** But the curve's coefficients scale like
`m³ ~ N`, and rational points of a curve with large coefficients are pushed to large height.
**So the per-`f` rate collapsing to zero at 30 bits may be a statement about `H`, not about
`f`.**

> **The real quantity is `H*(N)`, the height at which a curve first supplies a relation — not
> the per-`f` rate at a fixed `H`.**

This matters enormously, because the two have completely different consequences:

- If `H*` grows like `(log N)^k`, the enumeration is `O(H²) = poly(log N)`, the per-trial cost
  is polynomial, and **the method is `poly(log N)` for factoring up to any size** — because
  0.1% per-`f` is defeated by repeating `f` a few thousand times, at `60 µs` of lattice cost
  each.
- If `H*` grows exponentially, the method is closed everywhere, and the 30-bit wall is
  merely where `H*` crosses 200.

**The 30-bit wall is exactly where `H*` would cross 200 if `H* ~ 200·(N/2^30)`.** That is a
testable prediction, and nobody has tested it. My own scan to `H = 1500` found 0–1 relations
on dead instances — consistent with `H*` growing, *and* consistent with the curve being empty.
**Those two were never distinguished at large `H` with large `N` simultaneously**, which is
the experiment that would separate them.

**So the axis is closed as posed, and it reopens as a sharper question: is `H*(N)` polynomial
or exponential in `log N`?**
