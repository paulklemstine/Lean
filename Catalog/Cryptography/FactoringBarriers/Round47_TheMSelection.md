# Round 47 part 39 — the barrier is the choice of `m`, and it is a two-sided trade

**2026-09-29. Agent A16, after being pushed to re-examine its own close. It withdrew that
close. This is the sharpest statement the round produced about where the method dies.**

---

## The self-correction

A16 had closed the axis at ~30 bits. **It withdrew that.** The reason is the sharpest thing
in this file:

> **The lattice selects `m ~ N`, which is the DEAD regime. The record's scan selects
> `m ~ N^{1/3}`, and there the method still works at 32 bits.**

A 2×2 at fixed `N`, two sizes:

| bits | depressed, `m ~ N^{1/3}` | depressed, `m ~ N/2` | non-depressed, `m ~ N` |
|---|---|---|---|
| 28 | **16.7%** | 0.0% | 0.0% |
| 32 | **5.6%** | 0.0% | 0.0% |

> **Depression is irrelevant; `m` is everything.**

## The two-sided trade, which is the real finding

The two ways to choose `f` fail **on opposite sides of one trade**:

| route | cost | what it buys |
|---|---|---|
| **scan `m`** for small `c` | `N/(2·c_max)` probes — **2.8·10⁷ at 32 bits, measured** | **good `m ~ N^{1/3}`** |
| **lattice** | **60 µs, flat, `poly(log N)`** | **`m ~ N` — the dead cell** |

> **Neither is salvageable by tuning the other.** Making the lattice return small `m` costs
> exactly the arithmetic the scan does badly; making the scan cheap is the lattice's job and
> the lattice does it at the wrong `m`.

**This is why the 336-bit crossover is the right number and not an accident of my
sampling.** The rate `0.082` at 26 bits was measured by the *scan* — i.e. in the good regime —
so the crossover in `Round47_Crossover336.md` is computed on the live branch.

## What is NOT the killer (all measured, all settled)

- **not** the polynomial step — 60 µs, flat to 127 bits, `poly(log N)`
- **not** the height — relations that exist sit at `h = 9–10`, the **bottom** of the range;
  `H` 200→800→4000 changes little
- **not** depression (`P`) — the 2×2 above
- **not** the descent — there isn't one

## The open problem, now stated in one sentence

> **Find a cheap selector that returns a good `m ~ N^{1/3}`.**

That is a clean, well-posed problem, and it is *not* the problem the NFS already solves —
because the NFS does not need small `m`; it needs smooth *norms*, and it gets them by
sieving. This method needs a good `m` for a different reason: it needs the **relation curve**
to have a rational point at height `~10`, and that happens only in a narrow `m` window.

## The corrections A16 recorded rather than smoothed

| its own claim | status |
|---|---|
| S15.1 "a large `m` is **not** the obstacle" (one modulus, 11 bits) | **withdrawn** |
| S27/S29 "supply hits zero at 30 bits" | **withdrawn** as a claim about the method — it was about the wrong `m` |
| S33 "empty, not tall" | **still true, but of the large-`m` curves only** |

**Fifth defective control of the day:** the `H*` cross-check printed *"0/0 instances agree.
PASS"* — **it ran zero instances.** Recast onto lattice `f` it now fires 16/16. That is a
control that passed *vacuously*, which is the most dangerous kind: it is green and it tested
nothing.

## The number that decides the rest

The per-`f` rate of the **`m ~ N^{1/3}` window at 36 and 40 bits**, with a budget-sized sample.

- If it decays to zero, the method is closed everywhere and the barrier is a **scaling law**.
- If it holds, the open problem is the sharp one above: **a cheap selector for small `m`**.

This is exactly the quantity the supply-decay workflow is measuring, at 40 and 64 bits, in the
`m ~ N^{1/3}` regime.
