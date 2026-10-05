# Round 109d — the IFP/GIFP bounds, and the open gap the authors name themselves

**2026-10-04. NO new factoring algorithm.** This round completes the IFP thread
by reading the **primary sources** (Feng–Nitaj–Pan arXiv:2304.08718v3, and the
May–Ritzenhofen → Wang progression) and tabulating the sharpest known bounds.
The substantive outcome is a precisely-quantified **open problem stated by the
authors themselves**, plus corrections to my own round-109c framing.

Empirical companions: `ifp_bounds.py` (`out_bounds.txt`), `ifp_fnp.py`
(`out_fnp.txt`) — both deterministic.

---

## 1. Two corrections to my round-109c note

1. **Round 109c's framing.** I wrote that the Feng–Nitaj–Pan construction
   "degenerates to May–Ritzenhofen at `β₁=β₂=0`" and reported the bound
   `γ > 4α(1−√α)`. The primary source confirms the bound, but it is worth being
   precise: **GIFP is a strictly more general problem** (shared bits at
   *arbitrary, differing positions* in `p₁` and `p₂`), and `4α(1−√α)` is the
   GIFP bound — for the plain LSB case the sharp bound is the *smaller*
   `2α − 2α²` (Lu et al. 2016), **not** `4α(1−√α)`. My round-109c note implied
   the GIFP bound was the best-known; it is the best for the *generalized*
   (middle-bits/GIFP) setting only.
2. The oracle reveals only the **relation** `p₁ ≡ p₂ (mod 2^t)` (the shared value
   is never given) — the correction already recorded in 109c, now confirmed
   against the source ("an oracle that outputs a different `N₂` such that `p₁`
   and `p₂` share the `t` least significant bits").

## 2. The bound progression (verified, `ifp_bounds.py`)

`γ` = shared-bit fraction, `α` = cofactor bit-fraction. To factor a pair of
`n`-bit RSA moduli in polynomial time, `p₁, p₂` must share `γ·n` bits.

| variant | bound | source |
|---|---|---|
| LSBs / MSBs / both (same position) | `γ > 2α` | May–Ritzenhofen, PKC'09 |
| ″ | `γ > 2α − α²` | Sarkar–Maitra, ePrint 2009/108 |
| **LSBs / MSBs / both — BEST** | **`γ > 2α − 2α²`** | Lu et al., 2016 |
| middle bits | `γ > 4α` | Faugère et al., PKC'10 |
| middle bits | `γ > 4α − 3α²` | Peng et al., 2015 |
| middle bits | `γ > 4α − 4α^{3/2}` | Wang et al., 2018 |
| **GIFP (arbitrary positions) — THIS WORK** | **`γ > 4α(1−√α)`** | Feng–Nitaj–Pan, 2023 |

Concrete (`α = 0.25`, `n = 2048`, balanced `q`=512, `p`=1536):
best-LSB needs the two `p`s to share **768 bits**; GIFP needs **1024 bits**;
middle-bits needs **1024–1664**. Each is **polynomial time** — far below `L[1/3]`
— but each demands substantial shared-bit structure.

## 3. The open problem (the authors' own words)

> *"The most important [open problem] is: can we improve our bound `4α(1−√α)` for
> GIFP to `2α − 2α²` or even better? A positive answer seems not easy since the
> bound for GIFP directly yields a bound for any known variant of IFP."*
> — Feng–Nitaj–Pan, arXiv:2304.08718v3, §1

Quantified at `α = 0.25`: GIFP needs `γ > 0.500`, best-LSB needs `γ > 0.375` — a
gap of `+0.125` in `γ`. Closing it would **strictly dominate every known IFP
variant** (a genuine research target), and their code is public
(`github.com/fffmath/gifp`).

## 4. Honest scope

* **No new factoring algorithm.** The round-109 **polynomial-time IFP corollary**
  (exact shared part, `w ≥ α`, verified 8/8) remains the program's verified
  result; everything here is the *subtle, heuristic* lattice line.
* The construction in `ifp_fnp.py` is faithful and the lattice builds/reduces;
  **end-to-end recovery via Gröbner is still not claimed** (no Gröbner engine
  here; see the round-109b lesson).
* **The contribution is precision**: the verified bound table, the two framing
  corrections, and the authors' own open gap, quantified.

**The well-posed next target** is now unambiguous and external: *close the
`4α(1−√α) → 2α−2α²` GIFP gap* (the authors' stated open problem), which would
strictly improve every IFP variant. It needs a Gröbner step plus real lattice
engineering — a substantial effort, but a genuine, sourced, open research target
rather than a re-derivation.