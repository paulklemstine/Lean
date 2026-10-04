# Round 102 — two new primitives tested: Fourier-kernel cover construction (negative) and the UMW relaxation frontier

**2026-10-04. No exponent beaten. But two genuinely new axes are tested with clean
results, and one — a Fourier/Chebotarev-based cover construction, a primitive none
of rounds 96–101 used — yields a reproducible NEGATIVE that closes it. The UMW
subagent also identifies the genuinely under-explored lever (short addition
sequences) for the conditional `1/6`.**

Companions: `Experiments/UMWWindow/fourier_cover.py` (this round, deterministic).

---

## 1. Axis A — a Fourier/Chebotarev cover construction: NEGATIVE (new)

**The primitive.** `ChebotarevMinors.lean` (catalog, never used by the factoring
program) proves every square submatrix of the DFT matrix `(ζ^{jk})` is
nonsingular. Consequence: an `s×a` DFT system (`s<a`) has a kernel vector with
**all coordinates nonzero** — a *certified* set with a hole-free Fourier
structure. This is a construction primitive unlike anything tried in rounds
96–101 (random, hill-climbed rank-2 GAP, design/difference sets, higher-rank GAP,
divisor reuse, bivariate).

**Test.** Build full-support Chebotarev kernel sets `A ⊂ Z_p`, measure the residue
coverage of their difference set `{a−b mod p}` (the cover-relevant quantity)
against random sets of equal size.

**Result (negative, robust).** The Fourier-kernel set is **worse** than random:

| n | Fourier-kernel diff-cov | random diff-cov |
|---|---|---|
| 12 | 15.0 | 20.1 |
| 16 | 21.0 | 27.8 |
| 20 | 28.0 | 36.3 |

> **Why (mechanism).** The all-nonzero-kernel condition forces the set into a rigid
> algebraic (Fourier) structure, which *concentrates* differences — the opposite of
> what a divisor cover needs (spread differences). So the Chebotarev/Fourier
> primitive, while elegant, is actively wrong-signed for cover construction. This
> **closes** the Fourier-kernel cover axis and is a reusable negative: it explains
> *why* design-theoretic "structure" (round 96d) and Fourier "structure" (this
> round) both fail — **any constraint that forces structure concentrates the
> difference set and defeats the cover.**

This complements round 96d (design/difference-sets ≈ random) and round 96b
(birthday obstruction) into a single principle: **cover construction needs
*spread* differences; every algebraic/design/Fourier structure that is strong
enough to be certified is also strong enough to concentrate differences.**

## 2. Axis B — the UMW polynomial side and its real frontier

A subagent survey of Umans–Wang (arXiv:2511.10851) confirms (matching the repo):

* **No reduction** from integer factoring to finite-field polynomial factoring.
  The `4/3` and `1/6` results are *two applications of one combinatorial
  conjecture*, structurally (not computationally) linked. The polynomial side is
  `Õ(n^{4/3})` — superlinear, useless for integer factoring.
* DDF frontier: `3/2` unconditional (Kedlaya–Umans); `4/3` **conditional**
  (UMW); the only unconditional sub-`3/2` is Doliskani's **quantum** `4/3`.
  No unconditional classical improvement 2024–2026; `4/3` is the framework's
  ceiling (the authors say so).

**The genuinely under-explored lever the authors flag:** replace "generalized
arithmetic progression" with **short addition sequences** (Knuth 1997; Downey–
Leong–Sethi 1981) as the structure hypothesis. The key lemma holds for any
short addition sequence, making this a strictly more plausible conjecture route
than the AP version (which He–Sahai refuted). This is the sharpest open lever
for the conditional `1/6`.

*(The repo has read UMW deeply — rounds 7, 8, 44, 49, 97 — so this is recorded as
a frontier pointer, not a new claim.)*

## 3. Honest scope

* **No exponent beaten.** The Fourier-kernel axis is CLOSED (negative, with
  mechanism). The UMW polynomial side has no integer connection (confirmed).
* **New:** a reusable, mechanistically-explained negative — *structured sets
  (design or Fourier) concentrate differences and cannot build a good divisor
  cover*, complementing the birthday obstruction and design-set measurements.
* **Frontier pointer:** the short-addition-sequence relaxation is the least-
  explored route to the conditional `1/6`.
* **Not claimed:** that no structured cover exists; only that the tested
  structured primitives (design, Fourier) concentrate differences and fail.

**Next attack.** The Fourier axis is closed. The two remaining live levers are
(a) short addition sequences for the UMW conjecture (a *conjectural* target, needs
a construction no one has), and (b) the reference Jochemsz–May bivariate
implementation for the multivariate sub-`n/4` gap (blocked on implementation
trust). Both are now precisely scoped.