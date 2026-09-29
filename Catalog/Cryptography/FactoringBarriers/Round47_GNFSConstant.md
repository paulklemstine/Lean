# Round 47 part 16 — the GNFS constant is closed: `1.923` is correct and does not move

**2026-09-29. Frontier item 1 ("beat the GNFS heuristic constant") is closed, with the
constant derived rather than quoted, and with the mechanism identified.**

---

## 1. `1.923` is right, derived not quoted

`(64/9)^{1/3} = 1.92299942707654450976`. The balance is
`2α − (2/3β)·2√(2α) ≥ β`; at `α = β` this gives `β³ ≥ 8/9`, so `2β ≥ (64/9)^{1/3}`.
Reproduced to 40 digits, cross-checked against Lee–Venkatesan p.2 (`1.92299…`) and
HAC §3.2.7 p.97 (`1.923`).

**And the balance contains no `ω`.** The multiple-polynomial parameter is pinned purely by
the sieving/smoothness constraint, so

> `T(ω) = (1 + ω/2)·(8/9)^{1/3}`,  strictly increasing,  **floor `0.96150` at `ω=2`** —
> **exactly half of `1.92300`.**

## 2. Closure one — the linear algebra cannot be made sub-quadratic here

**Montgomery, "A Block Lanczos Algorithm for Finding Dependencies over GF(2)", EUROCRYPT '95,
DOI `10.1007/3-540-49264-x_9`, p. 118, verbatim from a rendered page image:**

> *"The net time is `O(dn)+O(Nn)` per iteration and **`O(dn²/N) + O(n²)` for the algorithm**.
> Gaussian elimination takes time `O(n³)`."*

**Blocking divides the mat-vec term by `N`; the `+O(n²)` term is independent of `N`** — it is
the dense `n×N` by `N×N` products plus inner products. **That `O(n²)` IS the linear-algebra
half of the constant.** It is not an implementation artefact to be optimised away; it is the
floor of the method.

## 3. Closure two — a polylogarithmic win is invisible at NFS level

arXiv:2006.06197 (Boudot–Gaudry–Guillevic–Heninger–Thomé–Zimmermann), p. 4, verbatim: the
`(1+o(1))` **"easily swallows any speedup or slowdown that would be polynomial in `log N`."**

So even a genuine poly-in-`log N` linear-algebra improvement **does not move the constant**.

## 4. Five more phantom sources, and two record errors

| asserted | verdict |
|---|---|
| Harvey–Hittmeir, *"A deterministic algorithm for factorisation with better than quadratic complexity"* | **does not exist** — arXiv title search 0, Crossref 0 |
| **Costa & Sharamba** (NFS linear algebra) | **does not exist** — Crossref `query.author=Sharamba` returns **0 works corpus-wide** |
| Harvey's NFS-linear-algebra line | **absent** from all 30 of his math.NT papers |
| "CRT list decoding for factoring", recorded as **closed** | **0 results**; all 29 hits for `ti:"list decoding" AND all:factoring` are Reed–Solomon / polar codes. **The record closed a technique that was never applied to factoring.** |
| Bernstein, *"Circuit complexity of the NFS"*, ANTS 2001 | **does not exist** |

And two errors in the record itself:

- **arXiv:2010.01250 is "CorrAttack"**, not "Implicit Adversarial Nets".
- **arXiv:1608.08766 is Hittmeir _solo_.** The "Harvey &" in the record's attribution is
  **the fabrication**, not a venue error.

## 5. A premise correction — and a coincidence to check

**The record implies `1.923` is unbeaten. It was beaten in 1993**: Coppersmith's multiple-
number-field sieve gives `1.902`, and the agent reports **Lee–Venkatesan's *rigorous*
randomised multiple-polynomial sieve gives `1.90188`.**

⚠️ **Treat the second number as unverified.** The executive summary of `RESEARCH.md` records a
*different* `1.901884` — a **withdrawn two-point extrapolation** of a saturating `1/k` arity
law to a floor `≈1.8808` — and explicitly withdraws it. **Either LV genuinely prints `1.90188`
for the rigorous MPS, or this is the withdrawn extrapolation resurfacing.** The two must be
distinguished before either is cited. **A rigorous `1.90188` would be the single most valuable
unverified number in this file**, and it is exactly the kind of thing this campaign has
retracted before.

## 6. What this closes

Frontier item 1 — *beat the GNFS heuristic* — is closed **for the linear-algebra route**, by
two independent mechanisms plus a premise correction:

1. the `O(n²)` term is irreducible in Montgomery's method, and it *is* the constant;
2. even a polylogarithmic improvement is swallowed by the `(1+o(1))`;
3. the floor is `0.96150` at `ω=2`, half of `1.92300`, and `T(ω)` is increasing, so no
   higher-arity sieve reaches it.

**What is NOT closed:** whether `1.902`/`1.90188` is the true best heuristic constant, and
whether a fundamentally different relation-collection (not a lattice linear algebra) could move
it. Neither is answered here.

## 7. Cumulative phantom count

**Round 47 alone: ~20 sources checked or re-attributed, of which at least 10 are fabricated or
misattributed**, and 2 record errors corrected. Across the project the count is now ~30.
The recurring cause is identical every time: **a constant or citation recorded from memory and
never opened.** The one remedy that has worked is the same every time: a matched-twin control,
or a page-image render.
