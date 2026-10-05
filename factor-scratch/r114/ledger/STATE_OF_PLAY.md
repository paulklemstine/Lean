# r114 LEDGER — state of play across 55 rounds

Lens: the ledger. Read every `factor-scratch/r4*/r5*/` note, the 91 memory files,
and `Catalog/Cryptography/FactoringBarriers/` (147 files, rounds 42–109).
Nothing committed.

---

## 0. HEADLINE: the frontier

> **The largest instance at which ANY of our own methods beats a trivial generic
> baseline is `n = 800` (GIFP), and that number is now DOUBTED by the campaign's
> own committed log. See §5 contradiction C1.**

Everything else is far smaller. The rest of the corpus tops out at
**20–40-bit moduli** (Stange) or is structural (Lean theorems, no factoring).

---

## 1. CLOSED AXES — with round and reason

| Axis | Round | One-line reason |
|---|---|---|
| NFS relation geometry (LV square-relation framework) | **r47 FINAL** | `h(α)=g²` costs `d−2` dims → curve for every `d`, genus 1/5/17/49. The analysability constraint is the thinness constraint. |
| Classical-deterministic factoring axis | **r45** | abandoned as out-of-scope |
| LLL "provably optimal on NFS lattices" | **r48**, **WITHDRAWN r48 census** | ⚠️ the memory note survives as a live closure but the corpus withdrew it — see §5 C2 |
| Coppersmith univariate threshold | **r48** | 31 unknown bits WORKS / 32 FAILS at N=2^128, `X=N^{1/4}` to the bit. **But "optimal" is overstated** — see §5 C3 |
| Rigorous `L[1/2]` | **r48** | Shoup Thm 15.6 unconditional since ~2009. The wall is a SUBGROUP wall. |
| GNFS constant `1.92299` | **r47** | derived + self-tested to 13 digits; LV Thm 2.3. Does not move. |
| Class groups "unconditionally excluded" | **r48**, **r55 hnfdesc** | conclusion sound, **stated REASONING refuted** (r55 recovered a factor 24/24 by explicit reduced-form descent) |
| Class-group smoothness lottery (E-6b/6c/7) | **r48** | RETRACTED: E-6b's "EC baseline" 0.925 = Dickman ρ for its own arm (0.9273); E-7 is a coin flip (p=0.769); no `.py` ever committed |
| Bivariate recombination vs Lecerf 1.5 | **r49** | certify-and-split deletes `s·D`; recursion DEPTH is the remaining wall |
| Stange Q-kernel "75% is the kernel's doing" | **r48 → r112** | rate is real (108/135) but is exactly classical `20/27`; kernel index `h` irrelevant — see §3 |
| Unbalanced RSA is easier | **r112** | threshold tracks `N^{β²}`, not `(β/2)log N`; imbalance buys nothing |
| Legendre decision oracle | **r112** | 1.10×√p vs rho 0.72×√p; cyclic-of-known-order buys nothing |
| `p+q` / Fermat lattice | **r112** | `~N^{1/4}`-class, dominated by rho (rho factored seed 3, Fermat did not) |
| Special-form (non-generic) moduli | **r112** | 0/300 at 256 bits; density ≤ 2^-64 |
| `v2`-mismatch as a *trigger* | **r112** | it IS the final step already: 1 modular exponentiation. Needs the orders = needs factoring |
| Multiplier `N→uN` amplifier | **r112/r113** | 0/12 where plain lattice gets 4/9; predicted sub-bit loss, `(n/4)·n/(n+w)` |
| Recombination via nullspace structure | **r112** | **INCONCLUSIVE — pigeonholed harness, NOT closed.** Left-nullspace vectors even by construction |
| UMW rank-2 GAP window `[1/3,2/5)` | **r96–96e** | five independent walls; birthday obstruction γ<1/2; rank-c gives no improvement (Kneser) |
| `2`-adic coupling × sieve phase separation | **r48/r53** | `GAIN ∈ {0,1}` identically for every (k, rule); coupling attached to a variable the search never reads |
| 2-adic digit reading `GAIN>1` | **r55 kernel** | CLOSURE — digit `e` pays exactly the root multiplicity `2^e`; `GAIN=1` for every `e`, by identity |
| Shape-aware sieve | **r55 shapesieve** | sieve IS shape-sensitive (7–14%) but the effect shrinks (1.42→1.23→1.14) and only opens when `minFac N ≤ B`, i.e. `N ≤ 2^25`; strictly dominated by rho |
| Adaptive rule below `n/4` | **r55 adaptive** | loses by ~23× in cost efficiency; and 2/3 of the premise was a too-small lattice |
| Harvey `N^{1/5}` deterministic floor | **r52** | three independent constraints pin `r=m=N^{1/5}`; deleting any collapses to `N^{0.0025}` |
| Round-99 residue partial-info method | **r101/r107** | two-residue frontier CLOSED by redundancy theorem; anchored to CHHS |
| Rough-semiprime wall γ≥1/2 | **r103c, corrected r105** | conclusion right, premise false; correct argument is a pair-covering design |
| Batch models / unknown pool | **r108/r108b** | batch GCD factors an unknown-pool batch at O(B) per instance — a REAL win, but per-instance model change not a balanced-semiprime break |

---

## 2. LIVE POSITIVES (survived scrutiny)

| # | Result | Exact instance | Exact measured number | Baseline reported beside it? |
|---|---|---|---|---|
| P1 | **GIFP recovers p₂ at n=800** | n=800, α=0.10, γ=0.70, \|q₂\|=80 bits, \|p₂\|=720 bits | **3/3**, build 22.6–36.2 s | **CLAIMED ">4 min without success" — CONTRADICTED by own log. See C1** |
| P2 | **Stange Q-kernel factors RSA moduli** | 20–40-bit balanced moduli | **108/135 = 80.0%** (2×run identical); 200/200 v2-law; 50/50 lead-confirmed | YES — but baseline is the point: the rate IS the classical 20/27, not a kernel property |
| P3 | **Coppersmith `X = N^{1/4}` to the bit** | N=2^128 balanced | 31 works / 32 fails | control stated first (3/3 known-good, 3/3 known-bad, 2/2 boundary) |
| P4 | **unbalanced threshold = `N^{β²}`** | pb=64/51/42/32, N=2^128 | 31/32, 19/20, 13/14, 7/8; 2 seeds | control reproduces closed axis cell-for-cell (unk=29–31 ✓, 32 ✗) |
| P5 | **rigorous `L[1/2]` at constant 2** | theoretical | `2√2 → 2` proved, unconditional | n/a — a proved bound improvement |
| P6 | **batch GCD, unknown pool** | batch of semiprimes | O(B) per instance, provably below L[1/3] per instance | n/a — different model |
| P7 | **LLL = exact SVP on NFS lattices** | 40 certified 7-dim lattices | 40/40 ratio 1.0000000000 | ⚠️ **WITHDRAWN by the corpus. See C2** |

**P1 is the only non-vacuous factoring positive in the campaign, and it is now in doubt.**

---

## 3. RETRACTED / CORRECTED — what killed each

| Result | Round | What killed it |
|---|---|---|
| GIFP "20/20 verified" as evidence | r112 | **n=200 → \|q₂\|=αn=20 bits; PARI does it in 0.006 s.** Attack was ~8000× SLOWER than nothing. Framing error, not math error |
| Stange "75% is the Q-kernel's achievement" | r112 | re-measured 108/135=80.0%, z=+1.57 vs 20/27=0.7407, CI [0.726,0.874] CONTAINS 20/27. Success is EXACTLY `v2(ord_p g)≠v2(ord_q g)`, 200/200. `h` flat 109/145 at h=1 through 1/1 at h=40 |
| r111 "`t=ceil` never makes anything worse" | r112 | **FALSE** — breaks m=4 and m=7 (4/4 → 0/4). t and s have OPPOSITE optima |
| r111 "the bound's SHAPE is wrong" | r112 | PARTIALLY REFUTED — drift real but small (1.4× vs 1.6×); α≥0.15 rows were *instance-infeasible*, not a shape failure |
| r111 "α ≥ 0.15 is a genuine wall" | r112 | **MY OWN t-collapse.** `t=round((1−√α)m)` steps 3→2 at α=0.15, a 200-bit modulus collapse at n=200. With t=3,s=0 it factors at ~85–100% (12 seeds: 11/12, 8/12, 11/12, 12/12) |
| `unknown_modular` modulus overstated | r112 | sweeps used `M^m·N1^t`, reference uses `M^m·p1^t`. They differ by `q1^t` = 28 bits at α=0.05, **99 bits at α=0.25**. 10/15 shifts violated the swept modulus; 0/15 the true one |
| E-6b "EC baseline 0.925", milestone "1.000 vs 0.925" | r48 | 0.925 = ρ(log2(1684)/log2(1000)) = 0.9273. A PREDICTION, not a measurement. Re-run: E-6c's 0.720 → **0.0624**, 11.5× too high |
| r47 "12/12 factors recovered" (Mordell–Weil) | r47 | **VOID** — `ellrank`'s 2-descent factors the discriminant, and `disc = −27c²(m³−c)²` with `N \| (m³−c)`, so it factors N to do it. Matched-twin control 0.02 s vs timeout >300 s |
| r47 "relations are too few" | r47 | **REVERSED** — LV p.39: running RNFS for `L_n(1/3,2σ+o(1))` "guarantees to find **every possible factor** `a−bX`". The constraint is that the 1/2 can be 0 |
| r47 "Chebotarev must be required" | r47 | **WRONG ATTRIBUTION** — BLP p.27 is about `χ_Q` SPANNING (square detection); LV Lemma 6.6 p.30 closes it unconditionally, and says so |
| r47 "Handover §2 THE LIVE DIRECTION" | r47 | **PHANTOM for 46 rounds** — Kaltofen–Kurban–Lenstra IPL 80 (2001) 57–64 does not exist (Crossref: pp. 57–64 already occupied by two process-algebra papers) |
| r47 "the standard GNFS resolves the sign rigorously" | r47 | **REFUTED** — it is an explicit retry loop; BLP p.44 call termination "reasonable to conjecture"; LLMP p.326: "hardly anything has been rigorously proved about practical factoring algorithms" |
| class-group exclusion `N<5400` | r48 adversarial audit | **FACTOR-2 ERROR worth 3.3e25.** `ln k = 4√(L ln L) − L`, not `2√(L ln L) − L`. Correct boundary `N* = 1.797e29` |
| r48 paper #523 "measured end-to-end 25–38% reduction" | r48 audit | **NEVER MEASURED** — an interpolation. Source said "the naive reading"; I upgraded the adjective |
| `_shared/dickman.py` as "the validated instrument" | r49 | **valid only u ≤ 5**, saturates above (returns ~6.7e-07 at u=20, truth ~1e-27). Self-test probed only u ≤ 4.2 — the one region where it works |
| `M·v == 0` kernel assertion | r49 | **VACUOUS** — the undivided reconstruction is identically ZERO and passes it. Need a NON-TRIVIALITY + dimension assertion |
| round-54 "phantom" flag on arXiv:2601.11131 | r55 gsmooth | **FALSE POSITIVE** — the paper EXISTS (Harvey–Hittmeir, v2 5 Jun 2026). The fetch that made the flag returned a DIFFERENT paper (2010.05450) |
| 16 fabricated citations | across | incl. **#15 authored by me while briefing an agent on citation discipline** (Lenstra Compositio 56 (1988) — vol 56 is 1985; real paper BAMS 26 (1992) 211–244) |
| r54/r53 recommendation to transfer the capacity test to r97g/r99 | r54 indep | **Could not apply** — the corpus never says whether r97g is bivariate over ℤ or mod p, and the mod-p version is DEGENERATE (for fixed x, all p values of y satisfy it) |

---

## 4. CONTRADICTIONS between rounds

**C1 — THE FRONTIEST CLAIM IS CONTRADICTED BY THE CAMPAIGN'S OWN LOG.** ⚠️ HIGHEST IMPACT

- `r112/verify_gifp/RESULT.md` (Check 5) and `r112/LEAD_FINAL_SYNTHESIS.md:29-31`:
  *"at **n=800** … while PARI `factor` on the same instance ran **>4 minutes without success**"*
- `r112/verify_gifp/hardN2.log:4-6`, **committed in the same directory**:
  ```
  n=800 |q2|=80 bits |p2|=720 bits  N2=800 bits
     factor(N2) in 310.72s -> [934029894621535196592551, 1; 449322809346235...]
  ```
- **I verified that logged factor is genuine**: reproducing
  `generate_gifp_instance(800, 0.1, 0.7, 0.1, 0.15, 31337)` gives \|q2\|=80, \|p2\|=720,
  `p2*q2 == N2` TRUE, and `934029894621535196592551` **equals the true q2 exactly**,
  divides N2 exactly, and `N2/cand == p2` TRUE.
- So PARI **did** factor the n=800 instance, in 310.72 s. The "one live positive in
  the campaign" rests on a baseline failure that the same round's log refutes.
- **What survives**: GIFP recovers the factor in **22.6–36.2 s** vs PARI's **310.72 s** —
  a genuine ~10× speedup at an 80-bit small factor, where generic factoring is not
  instant. That is a real and interesting result. It is **NOT** "PARI cannot do it".
- **What dies**: any claim that n=800 is beyond generic factoring.

**C2 — "LLL is provably optimal" is a live memory note but withdrawn by the corpus.**

- Memory `lll-is-optimal-on-nfs-lattices.md` + `FANOUT_BRIEF.md` §4 both state it as a
  closed axis: *"40/40 lattices give LLL/exact-SVP = 1.0000000000 … no BKZ can help."*
- `Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md:351` **withdraws it**:
  `| GNFS constant via BKZ past LLL | no gain found; "provably nothing" WITHDRAWN |
  40/40 give LLL/SVP = 1.0000000000 on the *certified* lattices. ⚠️ But the census's
  **mechanism sentence is not measured and the note's own control contradicts it**:
  I_constant.md:26 records LLL/SVP ∈ [1.000, **1.149**] and S4b finds LLL **strictly
  suboptimal 1/60**. Also **Montgomery normalisation is absent — 0/40 rows
  m-divisible**`
- And `:443`: `| BKZ / LLL | "CLOSED — provably nothing" | **withdrawn**; no gain
  demonstrated on the lattices tested … |`
- **Consequence: the FANOUT_BRIEF hands every r114 agent a closure the corpus withdrew.**
  Any agent citing "LLL is closed" is citing a withdrawn claim.

**C3 — "Coppersmith `N^{1/4}` optimal" is stated three incompatible ways in the corpus.**

- `Round97_FrontierAndOpenGap.md:57-61`: CHHS *"proved Coppersmith's univariate `N^{β²/d}`
  bound optimal **within the univariate auxiliary-polynomial class**"*
- `Round107_ResidueFirmFrontier.md:24-29` says the **opposite about the same paper**:
  *"their theorem covers the **mod-`N` univariate** case. There is **no capacity-theory
  optimality theorem** for the `N^{β²/d}` bound for a root modulo an *unknown divisor*
  (our setting)"*
- `Round48_SUMMARY.md:280-285` is bluntest: R1 §2.3.1 covers *"univariate polynomials
  modulo integers"* and lists *"factoring RSA moduli … when half of the most or least
  significant bits of one of the factors `p` is known"* as *"future research"* —
  **so the measured `X=N^{1/4}` is a CONSTRUCTURE for this problem, not a theorem.**
- The corpus also self-documents the failure mode: `Round48_SUMMARY.md:244`
  *"(table rows propagate, prose caveats do not)"* — which is exactly why the
  over-asserted rows survive and the caveat does not.
- `r53exp/catmine/m2m3_scan.md` rates it **OVERSTATED**, with live localisable headroom
  **14.1% [13.3, 15.0] at `u ≈ 3`**. **So this is a live lead, not a closure.**

**C4 — the Stange regime guarantee is quoted from a paper that does not contain it.**

- r48 notes say the regime `n >= 8b^(b/2)` is **Stange's**; `MM_regime.md` corrects it:
  it is **Fontein–Wocjan arXiv:1211.6246 Thm 1.1**, verified from a page image.
- Same file: the guarantee is **`α_b ≈ 0.17`, not 0.999**; Stange drops `64b²(b+1)`, so
  `b_max(10^20)` is **21, not 26** — **her regime is optimistic, not conservative.**

**C5 — the class-group closure is right for the wrong reason (self-contradictory).**

- Corpus closure: class groups **unconditionally** excluded.
- `r55exp/hnfdesc/NOTES.md`: *"the explicit reduced-form descent recovers a genuine
  factor of `N = pq` on **24/24 instances**"* — i.e. the thing said to be closed works.
  The closure's *argument* is refuted; the *conclusion* survives for another reason.
- `r48` paper #522 §2.2 itself refutes §2.2's stated premise (found by A2 adversarial audit).

**C6 — class numbers ARE enriched in small primes, and it is NOT a smoothness signal.**
This one is *resolved*, recorded because it looks like a live lead and is not:
`P(3|h)=0.438` vs 1/3 (z=+15.4), `P(5|h)=0.246` (z=+7.9), uniform for ℓ≥13 — a real
Cohen–Lenstra signal. But `ω=2.85` vs 3.16 uniform and **median LPF 90,599 vs 61,861 —
LESS smooth than uniform.** The skew sits in the primes contributing the least mass.

---

## 5. OPEN AXES nobody has attacked

Ranked by promise.

1. **★ The GIFP bound gap `4α(1−√α) → 2α−2α²`, named by the authors themselves.**
   `Round109d_IFPBoundsAndOpenGap.md`. `4α(1−√α)` is best for the *generalized* setting;
   the sharpest known **LSB** bound is the smaller `γ > 2α − 2α²` (Lu et al. 2016).
   Closing it would strictly dominate every known IFP variant. This is the single most
   concrete open problem in the corpus.
2. **★ GIFP SCALING past n=800.** `Round109e` never verified the threshold end-to-end
   (blocked on Sage, its own diagnosis: "my lattice is degenerate… every reduced row is
   zero"). r112/r113 verified at n=800 but **never measured the scaling**. r113
   `gifp-n800-scale/` exists with no RESULT.md — **r113 was cut off mid-flight.**
3. **★ The sub-`N^{1/4}` multivariate gap.** CHHS proved optimality only in the univariate
   class; the unknown-divisor setting is open. r97b gave a structural reduction (the most
   obvious multivariate attack is provably worthless), r97d/97e hit a lattice blocker,
   r97f RESOLVED the blocker and measured the `n/4` wall, r97g found the bits-of-`p`
   model ill-posed and bits-of-both genuinely bivariate — **with an honest negative from
   a from-scratch bivariate lattice.** Instrument now exists (`coppersmith_lattice.py`,
   validated). Both outcomes advance it.
4. **★ `Σw > 3/2`** — Harvey's total-weight question, `RESEARCH.md:9617`. A *specific
   number*, decidable by inspection of any proposed scheme, and **both answers are
   results.** r52 gave partial structure (three independent constraints) but no scheme
   above 3/2 and no proof that 2 is unreachable. Caveat the corpus states: the weights
   `wᵢ` are not mechanically defined. Nobody after r52 touches it.
5. **★ Rank-2 UMW `t`** — the decisive integer. **r54e already attacked it** and found
   the "single question" framing is wrong: `t` is 2–3 on random rank-2 gaps but can be
   made exactly `Θ(n^{1/3}/log n)` by construction; the He–Sahai-relevant reading
   (`n`-divisor gaps) is **NOT DETERMINED**. Half-open.
6. **Harvey's own published `N^{1/6}` question** (arXiv:2010.05450 p.8, verbatim:
   *"An interesting question is whether it is possible to obtain a fully square-root
   speedup for Lehman's original choice `r ≍ N^{1/3}`"*) — author-posed, and
   *"as far as I can tell **nobody has picked it up**"*. Blocked on the pair count `r=N^{1/5}`.
7. **A `poly(log N)` convergent of `p/q` from `N` in `o(N^{1/2})`** — alone beats Fermat,
   not known. The corpus notes the negative answer is worth as much as the positive.
8. **Greg Martin's conjecture**: prove `Ψ_F(x, x^{1/u}) ≤ C·x·∏ρ(d_i u)` for `F=t²−N`.
   One formally-statable analytic lemma.
9. **Explicitly aligned GAP cover in `γ < 0.4`** — counting has slack in `[1/3,2/5)`.
   ⚠️ r103c/r105 report two independent necessary conditions forcing `γ ≥ 1/2`, so the
   window may be **empty** — check before investing.

---

## 6. THE TRAPS, ranked by how much they have cost

1. **Vacuous evidence** — n=200 GIFP: 3 documents and every sweep built on it.
2. **An instrument reporting absence when it was reporting scope** — every serious error
   in this campaign. Not one came from arithmetic.
3. **A self-test that probes only the regime where the code works.**
4. **A probe that says "absent" everywhere including a positive control** (3+ instances).
5. **An assertion a trivial object satisfies** (`M·v == 0` on the zero vector).
6. **`pari(N).factor(1)` — NEW, r114.** Returns `N` itself in 0.1 ms. See
   `PARI_FACTOR_FLAG_BUG.md`. In four in-flight r113 scripts.
