# Round 98 — a fresh sweep re-derives the closed frontier (a result in itself)

**2026-10-04. NO new factoring algorithm and NO exponent improvement.** Two
independent literature sweeps (broad factoring frontier; targeted sub-problems)
were run against the record. The finding is not a new algorithm but a
**meta-result**: an independent, from-scratch sweep of the 2024–2026 literature
re-derives the frontier the record already holds, and the three most-cited
"leads" it surfaces are **already in the catalog**. This is evidence the frontier
is genuinely closed and the ledger is current.

---

## 1. The frontier, independently re-derived

| setting | bound | source | status |
|---|---|---|---|
| quantum | `poly(log N)` (Shor) | unbeaten; 2024–26 = depth/space/engineering | closed |
| classical, heuristic | `L[1/3,(64/9)^{1/3}] = L[1/3,1.9230]` (GNFS) | unbeaten | closed |
| classical, deterministic | `N^{1/5}` (Harvey–Hittmeir) | unbeaten; log-factor work only | closed |
| ECM | `L[1/2]` | unbeaten (EH-conditional only) | closed |
| known-bits of `p` | `n/4` (Coppersmith; CHHS optimality) | unbeaten | closed |
| deterministic, conditional | `N^{1/6}` (Umans–Wang) | AP version **refuted**; higher-rank open | the one live door |

## 2. The three "leads" a fresh sweep surfaces are already in the record

1. **Harvey–Hittmeir, arXiv:2601.11131** (drops the order-finding hypothesis
   `D≥N^{2/5}` entirely; for prime `N` returns an element of order `>D`). **Already
   recorded** in `RESEARCH.md` (§ lines 4573, 5565–5642, 8658), including the
   `n ≈ s·m/D = O(1)` leverage reading and the honest caveat that it rests on an
   unverified equidistribution assumption. The repo is *ahead* of the sweep here,
   having already extracted the leverage and flagged the uncertainty.
2. **Naccache–Buzățoiu et al., ePrint 2026/2256** — `L[1/3,∛(32/9)] = L[1/3,1.526]`
   in a weakened (canonical/affinely-padded) Rabin-oracle setting. **Constant
   factor only** (verified: `c_GNFS/c_special = 1.9230/1.5263 = 1.26`); the `1/3`
   exponent is untouched. The repo already tabulates `1.5263` (special) and
   `1.9230` (general) in `Round53_LnHalfFraming.md`.
3. **Joux, arXiv:2511.16151** (indefinite lattice reduction easier; factor depends
   on signature not dimension) and **Gao–Feng–Hu–Pan, arXiv:2512.19076** (rank-3
   Coppersmith, second LLL vector; `a^n±b^n` `N^{1/4}→N^{1/5}`). **Already
   recorded** (`RESEARCH.md`, `Round97_*`).

Other sweep items (Pilatte's unconditional Regev, de Boer–Pellet-Mary–Wesolowski
under ERH, Stănică–Hittmeir sieve analysis, Klurman–Shparlinski–Teräväinen,
Ragavan, Kahanamoku-Meyer) are **exponent-preserving, conditional, or quantum
engineering** — none moves a classical exponent.

## 3. The one genuinely new-but-conditional item

**de Boer–Pellet-Mary–Wesolowski, arXiv:2512.01588** — first *provable* subexponential
class/unit-group computation for **arbitrary** number fields **assuming ERH**, via
a new smooth-ideal sampling lemma that removes the heuristic obstacle in
index-calculus sampling. This is the cleanest GRH-connection found, and it targets
the machinery behind class-group-based factoring — but it does not by itself move
the factoring exponent, and it is ERH-conditional.

## 4. What this round establishes (the honest result)

* **No new factoring algorithm. No exponent beaten.**
* The valuable output is **negative and meta**: an independent, current, from-scratch
  literature sweep **does not find any classical exponent improvement**, and its
  three headline items are already in the catalog. Combined with rounds 96–97
  (five walls on the deterministic window; the multivariate gap reduced to a
  lattice-isolation problem; the `n/4` wall measured with a validated solver), the
  evidence that the classical factoring frontier is **closed** is now very strong
  and multiply-sourced.
* **A caution this round supplies:** the catalog's ledger is *more current* than a
  fresh web sweep. Rounds 7–8 and 97 already mined arXiv:2601.11131 to a depth
  (including an unverified-assumption caveat) that a new sweep does not. Any future
  round should **read the record before sweeping**, or it will re-derive rounds 7,
  8, and 97 — exactly the anchoring failure the record's own rules warn about.

**Where a new method would have to come from** (unchanged, now triply sourced):
the multivariate sub-`N^{1/4}` lattice-isolation problem (blocked on a reference
Jochemsz–May implementation); Schnorr-style lattice factoring combined with Joux's
indefinite reduction (the only major route with no known barrier theorem); or a
genuinely new covering idea the five round-96 walls did not exclude.