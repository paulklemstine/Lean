# M1 — corpus scan for claims contradicting the eight known closures

**Date:** 2026-10-04
**Corpus:** `/home/raver1975/lean/Catalog/` (read-only)
**Primary:** `Cryptography/FactoringBarriers/` (100 .md, rounds 42–109) + `RESEARCH.md`
**Also:** `Cryptography/Factoring/`, `Cryptography/AsymmetricExponent/`, `Combinatorics/`, `NumberTheory/`, and `.lean` files in `Cryptography/FactoringBarriers/`.

Every quote below was re-verified by hand with `grep -n` at the line numbers given.
ROUND is taken from the filename/title.

---

## VERDICT UP FRONT

**No corpus file claims an ACHIEVED improvement that beats any of the eight closures.**
What the scan *did* find, and what is genuinely useful, is a different and better thing:

> **The corpus contains SEVEN live places where it asserts a closure STRONGER than its own
> verified evidence — and in three of them the overstatement is on the side of the closure
> (i.e. it claims optimality that was never proved). Those are the real hazards.**

The single strongest item is an **un-retracted stale sentence inside the file that contains the
retraction** (Round48_SUMMARY.md:546 vs :264). Anyone citing Round 48 for the `N^{1/4}`
optimality will import a claim the same file explicitly withdrew.

Severity ranking below: **[S1] strongest → [S7] weakest.**

---

## [S1] — CLOSURE 1 threatened, and it is a self-contradiction inside ONE file

### Round 48 (`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`)

**(a) The RETRACTION — line 264 (and the prose block 266–285):**

> `Round48_SUMMARY.md:264`:
> `| Partial-information factoring below ½ the bits of p | **MEASURED; optimality UNPROVED for this problem** | Our measurement: **31 unknown bits WORKS, 32 FAILS** at N=2¹²⁸ — `X = N^{1/4}` exactly. ⚠️ **An earlier "now also a THEOREM" upgrade is STRUCK — it was my error.** arXiv:1605.08065 proves optimality for **univariate polynomials modulo N**, and its p.6 §2.3.1 lists *"factoring RSA moduli N=pq when half of the most or least significant bits of one of the factors `p` is known"* as **"a direction for future research"**. **Our `X = N^{1/4}` is a CONJECTURE here — it is the *modulo-unknown-divisor* bound, not R1's *modulo-N* one.** Nothing tested beat ½ |`

> `Round48_SUMMARY.md:282`:
> `**So our measured `X = N^{1/4}` is a CONJECTURE for this problem, not a theorem.** It is the *modulo-unknown-divisor* bound (Coppersmith/Howgrave–Graham/May), which is a different result from R1's *modulo-N* bound. **Our 31-works/32-fails measurement remains exactly as valid; its status was overstated.**`

**(b) The UN-RETRACTED RESIDUE — line 546, which asserts the opposite:**

> `Round48_SUMMARY.md:545-546`:
> `What survives from that axis is the **boundary measurement itself**: the univariate threshold is`
> `` `X = N^{1/4}`, now **proved optimal** (arXiv:1605.08065), and no tested leakage family beats it. ``

**METHOD AUDIT.** (a) is a **verified retraction**: the author states he fetched the primary
source, checked authors and date, and read p.6 §2.3.1. It is *exactly* the CHHS-scope point in
Closure 1, independently rediscovered. (b) is a **bare citation-restatement with no computation
attached** — it is prose, not a result. 282 lines apart in the same file, and line 266 says of
the earlier version of that same row: `**That is withdrawn.**`

**Why it matters.** This is precisely the corpus's own recorded failure mode, quoted at
`Round48_SUMMARY.md:394-396`:

> `No census row is wholly untraceable. The failure mode is that the reason column is STRONGER`
> `than the evidence beneath it, and the census systematically DROPS the caveats its own notes`
> `attach.`

Line 546 IS that failure, inside the file that documents it.

**ACTION.** Do not cite `Round48_SUMMARY.md:546`. Use `Round48_SUMMARY.md:264` or, better,
`Round107_ResidueFirmFrontier.md:24-29` (below).

---

## [S2] — CLOSURE 1 threatened: `RESEARCH.md` #497 asserts optimality in the case CHHS excludes

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/RESEARCH.md`

> `RESEARCH.md:543-546`:
> `- **#497 — Coppersmith's `N^{β²/d}` exponent is PROVEN OPTIMAL** (Chinburg–Heninger–`
> `  Hennenway–Scherr, ASIACRYPT 2016): capacity theory rules out even *superpolynomial*`
> `  improvement, quantum included. ⇒ **the `n/4` partial-key wall is not a gap in the`
> `  technique; it is the technique's ceiling.**`

**Three distinct overreaches:**

1. **SCOPE.** CHHS is univariate-mod-`N`. Partial-information factoring on bits of `p` is
   mod-**unknown-divisor**. Round48 verified from the paper's own p.6 §2.3.1 that CHHS lists the
   unknown-divisor case as *future work*. #497 applies the theorem to the excluded case.
2. **"even superpolynomial improvement, quantum included"** — not in the CHHS abstract, not
   supported anywhere in the file, and in tension with `RESEARCH.md:491-497` where Shor/Regev
   are catalogued as alive.
3. **TYPO: "Hennenway" for "Hemenway."** Given the corpus's own meta-rule (`RESEARCH.md:587-588`:
   memory-sourced citations are unreliable, *"Every one looked perfectly plausible"*), a
   memory-sourced author list is exactly the failure mode under audit.

**THE CORRECT VERSION IS IN THE SAME CORPUS, LATER AND BETTER-SOURCED** —
`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round107_ResidueFirmFrontier.md:24-29`:

> `**The gap they leave (still open):** their theorem covers the **mod-`N` univariate** case.`
> `There is **no capacity-theory optimality theorem for the `N^{β²/d}` bound for a root modulo`
> `an *unknown divisor*** (our setting), and they list the bivariate-integer / divisor cases as`
> `open future work. So the *frontier we sit on* (`β=1/2`, `d=1` → `N^{1/4}`) is conjecturally`
> `optimal but **not yet proven optimal** — the open bit is narrow and precise.`

**Also inherits the over-claim:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round98_SweepRedundant.md:21`
(`known-bits of p | n/4 (Coppersmith; CHHS optimality) | unbeaten | closed`).

**METHOD AUDIT.** `RESEARCH.md:543` is a **bare assertion with a citation** — no experiment, no
distinction drawn between mod-`N` and mod-unknown-divisor. Round107 is **sourced to the
paper's own section number** and is the correct form. Round 98 is a one-line table row.

---

## [S3] — CLOSURE 4 (LLL/BKZ) is **already withdrawn by the corpus itself**

This is the finding most directly on-point for "any claim of BKZ / sparse / deeper-pipeline
improvement?" — and the answer is that the corpus **retracts its own strong form of the closure**
and never re-establishes it.

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`

> `Round48_SUMMARY.md:314` (status table row "GNFS constant via BKZ past LLL"):
> `| GNFS constant via BKZ past LLL | **no gain found; "provably nothing" WITHDRAWN** | 40/40 give LLL/SVP = 1.0000000000 on the *certified* lattices. ⚠️ But the census's **mechanism sentence is not measured and the note's own control contradicts it**: `I_constant.md:26` records LLL/SVP ∈ [1.000, **1.149**] and S4b finds LLL **strictly suboptimal 1/60**. Also **Montgomery normalisation is absent — 0/40 rows m-divisible** (`I_constant.md:139-143`, "a real gap I flag rather than claim"). Honest status: **no constant improvement demonstrated on the lattices tested** |`

> `Round48_SUMMARY.md:406` (the corrections table):
> `| BKZ / LLL | "CLOSED — provably nothing" | **withdrawn**; no gain demonstrated on the lattices tested; note's own control gives LLL/SVP up to **1.149** and finds LLL suboptimal 1/60; Montgomery normalisation absent (0/40 rows m-divisible) |`

**But the strong prose form is STILL PRESENT, un-withdrawn, 8 lines below the correction:**

> `Round48_SUMMARY.md:323`:
> `> **40/40 lattices: ratio = 1.0000000000.** Best β over β = 2…7: **1.0000000000×**.`
> `Round48_SUMMARY.md:326-327`:
> `Mechanism: the lattice basis vectors have near-disjoint small-prime supports, so the rows are`
> `nearly orthogonal *before* reduction. **LLL is already at its optimum, and better reduction`
> `cannot help.**`
> `Round48_SUMMARY.md:329-330`:
> `This is the correct way to run a negative in this program: not "BKZ did not beat LLL" but`
> `"the exact optimum equals LLL's output, so no β exists that could."`

**Same pattern as [S1]: the caveat row was corrected, the prose was not.**

**METHOD AUDIT — this is the important part, and it goes against the strong form.**
Primary source: `/home/raver1975/lean/factor-scratch/r48/notes/I_constant.md` (round 48, Axis I).

* What was computed: a **certified exact-SVP enumerator** (`exp/exactsvp.py`, "refuses, returning
  `None`, rather than silently truncating") run on **7-dimensional** GNFS relation lattices
  built from `N` of **32–55 bits**. 119 configurations attempted, **40 admitted a certified
  exact SVP**; the other 79 **discarded, not silently approximated**. The headline ratio
  `LLL(b₁)²/exact_SVP(b₁)² = 1.0000000000` on 40/40 is real (`I_constant.md:92-103`).
* **Scale: 7-dimensional, 32–55 bits.** `I_constant.md:135-138`: *"The full 1024-bit relation
  lattice is not constructible on this host… I have not measured it at 1024 bits."*
* **The normalisation is absent.** `I_constant.md:139-143`: *"the Montgomery normalisation is
  **not** included. This is a real gap and I flag it rather than claim the lattice is the fully
  normalised Montgomery lattice."* — measured **0 of 40** rows divisible by `m`.
* **The control contradicts the mechanism sentence.** `I_constant.md:26`: S1 records
  `LLL/SVP ∈ [1.00000000, 1.14946164]` over 40 lattices, and `I_constant.md:30`: S4b, *"LLL is
  genuinely not always optimal"*, strictly suboptimal in **1/60** cases, max ratio **1.0251**.
  So the "rows are nearly orthogonal" mechanism is *asserted*, not measured
  (`Round48_SUMMARY.md:314` says so explicitly).
* **BKZ tooling caveat.** `I_constant.md:59-70`: fpylll's BKZ was a **silent no-op** on this
  host; all BKZ numbers are from the author's own implementation, which is **conservative** by
  construction and *"provably cannot insert an SVP whose `c₀ = ±g, g > 1`."*
* **And a positive control that BKZ DOES improve when LLL is suboptimal** —
  `I_constant.md:34`: `| S6 | **control:** on lattices where LLL is *provably* suboptimal, BKZ
  strictly improves | 2/6 improved, 1/6 exactly optimal |`

**CORRECT READING.** The honest status is Round48's own: **no constant improvement demonstrated
on the lattices tested** — a negative *at the sizes measured*, on *non-normalised* 7-dimensional
lattices at 32–55 bits, with a control showing LLL is not universally optimal. It is **not**
"LLL is provably optimal on NFS lattices", and it is **not** "no BKZ can help".

**The memory note's `LLL Is Optimal On NFS Lattices` framing should be re-scoped.** Note also
`I_constant.md:128-131`: the lattice step is **0.09% of the pipeline** at the sizes measured, so
even a hypothetical free lattice step buys 0.09%.

---

## [S4] — CLOSURE 6 threatened TWICE, by rows in the SAME census table

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`

**The CLOSURE row — line 242:**
> `| **The `2 − 1/p` excess (paper #523's open item)** | **FULLY CAPTURED — provably. ZERO headroom** | The excess is carried **entirely** by the `p ∣ b` stratum; on `p ∤ b` the rate is **exactly uniform** `1/p^k`. The NFS sieve marks a cell iff `p ∣ F(x,y)`, so **its mark rate is `r_p/p` exactly**. The divisibility is real and **the sieve already divides it out.** This retires #523's stated open item, and is the answer to whether round 48's one positive finding has any cash value: **none** |`

**The CONTRADICTING row — line 258, sixteen rows below it:**
> `| NFS smoothness uniformity | **DEVIATION FOUND (positive)** | `P(p^k | a²−b³)/p^k = 2−1/p` for odd `p`, **2 ≤ k ≤ 5** (departs at k=6) — the heuristic is **pessimistic**. **The 25–38% figure is WITHDRAWN by audit; the measured replacement is 14.1% [13.3,15.0] at u≈3. AND THE GAIN IS LOCALISABLE** — the best mod-4 sub-box beats the global rate at EVERY operating point (5.65× at u=6, 2.04× at u=3), so a sieve *could* be aimed at it. That is a STRONGER result than the withdrawn claim, not a weaker one |`

**Line 258 is NEVER corrected by any later round.** And the census's own restatement at
`Round48_SUMMARY.md:486` repeats the closure without mentioning :258.

**A THIRD position, at line 70 of the same file — a quantitative partial concession:**
> `Round48_SUMMARY.md:70`: `…**R2 closes `2 − 1/p`:** the `p∣a,p∣b` corner really IS smoother
> (1.35–2.00×) but costs `q = 1/p²` — gain **0.017–0.148**, i.e. **losses of 7–58×**.`

So the corpus holds **three mutually inconsistent positions on one fact**:
zero headroom (:242, :486) / positive + localisable + sieve-aimable (:258) / real-but-net-loss (:70).

**METHOD AUDIT.**
* :242 is backed by a **real argument** at
  `/home/raver1975/lean/factor-scratch/r48/notes/QQ_relfind.md:165-240` — exhaustive enumeration of
  all `(a,b) ∈ [0,p^k)²` for `p ∈ {3,5,7,11,13,23}`, `k ≤ 4`, giving the `p∤b` uniformity
  *exactly* (integers, not approximately) at `QQ_relfind.md:199-200`; and a measured NFS-cubic mark
  rate over 810,000 values matching `r_p/p` at `z = ±0.03` (`QQ_relfind.md:215-222`). It also
  has a **non-vacuity control** that is worth noting — `QQ_relfind.md:224-228`: the first attempt
  used primes with `r_p = 1` where the wrong model `1/p` *coincides* with `r_p/p`, so it
  "passed while testing nothing"; restricted to `r_p = 3` primes the `1/p` model is rejected at
  `z = +120` to `+425`. **This is the best-executed measurement in the corpus.**
  ⚠️ Scope caveat the census omits (`QQ_relfind.md:237-240`): `2−1/p` belongs to the
  *quadratic/special* form `a²−b^k`; for a cubic NFS polynomial the analogue is the root count
  `r_p ∈ {0,1,3}`. *"the two must not be conflated."*
* :258 is an **experiment** with a Wilson-95% CI of [13.3, 15.0] on a 14.1% figure (implies
  n ≈ 10³–10⁴ per cell; **sample size not stated in the row**). Its primary file
  (`Papers/a_square_minus_a_cube_divides_twice.md`, #523) is **NOT in this corpus** — only the
  summary row survives. **Its own predecessor number is marked "WITHDRAWN by audit."**
* The adversarial audit at
  `/home/raver1975/lean/factor-scratch/r48/notes/KK_audit_amendments.md:144-162` is the arbiter
  and it **sides with :258 against :242's source**:
  > `MAT-2 — #523 §6.2 qualification 1 is FALSE by the data the section cites`
  > `Line 308–310: *"There is no decision to take: **no sub-box beats the free global rate**."*`
  > `… the honest reading of the data is **localisable**. (Either the qualification is`
  > `wrong, or the bolded claim overstates — the two are not jointly satisfiable.)`

**ACTION.** Closure 6 is safe **as the QQ_relfind argument stands on its own** (that argument is
excellent). It is NOT safe as a *census* claim, because Round 48's own table asserts the
opposite sixteen lines away and the adversarial audit backs the opposite reading.

---

## [S5] — CLOSURE 5: the corpus records `1.90188` as beating `1.9229994`, then refutes reachability

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round47_LVConstants.md`
(round 47, part 17, 2026-09-29 — *supersedes* Round47_GNFSConstant.md)

> `Round47_LVConstants.md:36-38`:
> `**So the premise correction survives, with its scope fixed:** `1.923` **was** beaten, to`
> `` `1.90188`, and the beating is recorded **by Lee–Venkatesan themselves**, in the same
> section as their theorem. But it is a remark asserting an extension, not a theorem they prove. ``

> `Round47_LVConstants.md:34` (the status row):
> `| **the extension remark** | `∛((92+26√13)/27) = 1.90188` | "results **can be shown to extend to**" Coppersmith's MPS, *a randomised variant* of which | **asserted, not proven in the paper; and for a randomised variant** |`

**METHOD AUDIT.** **Page-image read of a primary source** (arXiv:1805.08873 p.2, 400 dpi render)
— the corpus's stated remedy for `pdftotext` mangling. `Round47_LVConstants.md:26` independently
verifies `∛((92+26√13)/27) = 1.901898…` matching the printed `1.90188` to 5 dp, so the *number's
provenance* is solid. Its *status* is explicitly "asserted, not proven."

**The corpus then REFUTES reachability, later in the same round.**
`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round47_ConstantPinned.md`
(round 47, **part 28** — the latest word on this axis):

> `Round47_ConstantPinned.md:53-56`:
> ``> `8κ² − 45.914778κ + 69.914778 = 0`,  **discriminant `−129.106`**``
> ``> **NO REAL `κ` PRODUCES `1.9018836`.** The minimum of the entire LGST model class is
> `1.922999427077`, a **+1.098%** gap above it.``

**METHOD AUDIT.** **Algebraic/numeric proof**, 13-digit, machine-computed, four arguments,
passes its own control. ⚠️ Scope-limited: it proves `1.902` is outside **the LGST model class**,
not that no method reaches it.

**⚠️ RESIDUAL INCONSISTENCY.** `RESEARCH.md` uses bare **`1.9018836`** as the operative cost in
five separate arguments — `RESEARCH.md:2361, 2481, 2942, 3112, 8201` — and states it as the
best-known constant at `RESEARCH.md:714-717`, **despite `Round47_LVConstants.md:42-49`
explicitly warning that a *withdrawn, unrelated* `1.901884` agrees to four digits and calling it
"the single most confusable object in this file."** `RESEARCH.md` also carries a documented
**four-way conflated phantom citation** for this number (`RESEARCH.md:721-740`) and an
**explicitly withdrawn** `1/k` extrapolation toward a floor of `≈1.8808` (`RESEARCH.md:3362-3368`).

**ACTION.** Closure 5 stands **within the LGST model class**. Do not cite `RESEARCH.md`'s bare
`1.9018836` as an achieved frontier without the heuristic label and the model-class caveat.

---

## [S6] — CLOSURE 3 threatened: Round 51 proposes the class-group route as OPEN and highest-ceiling

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round51_ShapeGap.md`
(round 51, 2026-10-03)

> `Round51_ShapeGap.md:167-169`:
> `- **(B) `L_n[1/2,c]` for `c<1`.** The 34-year-old gap. Mulder's class-group`
> `  machinery is the modern tool and nobody has applied it to the constant. This is`
> `  the highest-ceiling item on the list and the least explored.`

> `Round51_ShapeGap.md:23-24`:
> `` `L_n[1/2,1] = exp(√(log N · log log N))`. **Under GRH, Seysen's class-group method gives
> `L_n[1/2, √(5/4)]`**; unconditional, LP's multiplier trick gives the `1`. ``

**METHOD AUDIT.** **Bare assertion + one uncited figure.** The `√(5/4)` is attributed to Seysen
*under GRH* with no page or derivation. No class-group computation was performed; `L[1/2,c<1]`
is proposed as *work to do*. **Not a retraction file.**

**WHY IT MATTERS.** The Round-48 class-group exclusion (`Round48_SUMMARY.md:62`:
`Class group **excluded unconditionally** (§2.3: `h` `B`-smooth ∧ `p|h` ⟹ `p ≤ B`, inconsistent
at the relevant bound)`) is **never re-invoked** anywhere in rounds 51–54. Round 53 closes the
same target on *different* grounds (a tabulation, `Round53_LnHalfFraming.md:26-33`), and Round
53's own attempted derivation **failed** (`Round53_LnHalfFraming.md:60-70`: implied constants
6.53 and 0.435, `"I am not claiming a derivation of the constant"`). So the structural exclusion
argument is **silently dropped** from the L[1/2] thread.

**ADJACENT, from the subagent sweep — `RESEARCH.md:7303-7306` asserts the OPPOSITE of Closure 3:**

> `RESEARCH.md:7303-7306`:
> `* **Random auxiliary values (Dixon, class-group):** smoothness is **PROVEN**`
> `  (Dickman; de Bruijn; Tenenbaum — `ψ(x,y;a,q) ~ ψ(x,y)/φ(q)$) and **Pomerance`
> `  proves the sieve is OPTIMAL** (the `X^{1/u}u^u` bound is tight). **This case is`
> `  closed by a theorem, not a conjecture.**`

**METHOD AUDIT.** Literature citation (Dickman/de Bruijn/Tenenbaum/Pomerance), **no primary
page read, no experiment. Not corrected by any later round.** Note the meaning is narrower than
it looks — "closed by a theorem" refers to the *smoothness side*, not to factoring working — but
it is the most direct textual statement in the corpus that contradicts Closure 3's spirit.

**Closure 3 is otherwise the BEST-SUPPORTED of the eight.** Supporting: `Round48_SUMMARY.md:62`
(the exclusion itself), `:253` (`Class-group smoothness lottery | CLOSED ×3`), `:568-600` (E-6c
re-run, 0/112 cells above Dickman), `:675-677` (`Cl(O_D) mod p` is trivial, walk degenerates to
SQUFOF), `NegativeResults.lean:59` (item 21, machine-checked), and
`Cryptography/SingularModuli/Sharpness.lean` `total_work_ge` (*"Raising the class number buys
nothing"*).

⚠️ **Scope gap the corpus itself admits** — `RESEARCH.md:3137-3139`:
`What is established is *one-directional* hardness… **The reverse implication (computing `h`
yields a factorization) is `not` claimed here.**`

---

## [S7] — CLOSURE 2 and CLOSURE 8 are CLEAN

* **Closure 2 (multivariate independence is a heuristic).** No corpus file asserts it is proven.
  It is stated correctly at `Round48_SUMMARY.md:303-305` (*"Multivariate independence is still a
  heuristic"*), and the arXiv:2111.14180 result is correctly scoped at `:287-294` (including
  `**only in the two-variable linear subcase**`). Also `Round47_AuxiliaryInformation.md:43-47`.
  ⚠️ Two "**Rigorous**" labels with no independence caveat, flagged for audit but *not*
  verifiable from the corpus: `Round108_BatchModels.md:43` and
  `Round97_FrontierAndOpenGap.md:40-43` (GFHP rank-3 Coppersmith). If rank-3 Coppersmith means a
  multivariate auxiliary-polynomial system, those labels assert exactly what Closure 2 denies.
  **Flag, do not accept.**

* **Closure 7 (`20/27` → `8/9`) and Closure 8 (phase separation).** Present and intact at
  `Round48_SUMMARY.md:71` and `:244`, with unusually thorough controls (exhaustive 210/210 cells,
  MC z-scores, an independent reimplementation). **No contradiction found.**
  ⚠️ `Round48_SUMMARY.md:628` records that the *mechanism* for `20/27` was long
  "measured and confirmed, not derived" — but `:632-641` SUPERSEDES that with the derivation
  (deficit `−1.7 × 10⁻¹⁸`), so the caveat is stale, not a live gap.

---

## FABRICATED-CITATION AUDIT

The corpus has an explicit, dated self-audit: **~30 phantom sources project-wide, ≥10 in round 47
alone** (`Round47_GNFSConstant.md:85-88`). Findings from this scan:

**IDs I checked and found CLEAN (correct subject/era):**
`1605.08065` (CHHS, 2016) · `2111.14180` (Chinburg et al., 2021) · `2010.05450` (Harvey) ·
`2007.02730` (Le Gluher–Spaenlehauer–Thomé) · `1805.08873` (Lee–Venkatesan) · `2205.10074`
(Hittmeir) · `2211.06821` (Stange) · `2503.00950` (Pomykała–Jurkiewicz) · `2512.19076`
(GFHP) · `1211.6246` (Fontein–Wocjan) · `1209.5520` (Jeljeli) · `1502.07953` (Mosunov–Jacobson).
All 82 distinct arXiv IDs in the tree have plausible `YYMM` prefixes; **no astronomy or
off-discipline ID found.**

**⚠️ FLAGGED — contradictions or unverified status, none of them obviously fabricated:**

1. **`arXiv:2601.11131` (Harvey–Hittmeir, 17 citations — the most-cited ID in the corpus).**
   Internally *contradicted* by `RESEARCH.md:4726`:
   `` `arXiv:1608.08766` is RETRACTED; the original citation was right. `` `` This is a retraction
   of a retraction, and the file calls it *"the SIXTH retraction in the file"* (`:4730-4731`).
   The `2601.11131` attribution itself is consistently "Harvey & Hittmeir, Jan–Jun 2026" — the
   arithmetic-exponent drop recorded at `Round96d_FourAxisSweep.md:60` is consistent. **Low
   suspicion, high citation weight — worth one verification given it anchors the `N^{1/5}` line.**

2. **2026 quantum-axiom IDs, all cited exactly once, all in one paragraph**
   (`Round96d_FourAxisSweep.md:19-30`): `2511.18198` (Regev/SORA), `2609.36480` (Luo–Li–Le Gall),
   `2603.12917` (Vandaele), `2609.24316` (Cai–Young), `2610.02101` (Dong–Lombardi), `2405.14381`
   (Ekerå–Gärtner), `2505.15917` (Gidney). Plausible for the era and the same file also records
   Ekerå–Gärtner's *negative* verdict on Regev's space savings — the sign of careful reading.
   **Not suspicious, but six uncorroborated IDs in one paragraph is the profile of a
   subagent-swept list.**

3. **`Round97g_BivariateProbe.md:78` — `"literature has working multivariate Coppersmith"`**
   with **no citation, no page, no run**. Used to excuse a failed experiment. This is the one
   bare uncited literature claim in the partial-info thread.

4. **`RESEARCH.md:544` — "Hennenway"** for Hemenway (see [S2]). Memory-sourced author list.

---

## THINGS THAT ARE *NOT* CONTRADICTIONS (recorded so nobody re-flags them)

* **Round99's "NEW deterministic factoring algorithm"** — the most aggressive headline in the
  corpus, but its threshold is `M ≳ N^{1/4}` (`Round99_ThreeAxesAndNewAlgorithm.md:52-56`),
  i.e. **exactly** the frontier, not below it. Self-limited at `:61-62`:
  `"It does **not** move any exponent on the open problem."` Validated (7/7 + 13/13, certified
  by division). **Not a contradiction of Closure 1.**
* **Round97g's "sub-n/4" false positive** — `Round97g_BivariateProbe.md:44-48`:
  `"A first version "recovered" factors at `kx=ky=6` (below `n/4=8`). But it found roots by
  **scanning all `X` values** — at `X=1024` that is trivial brute force. Discarded."`
  **Self-caught, correctly discarded.** Evidence the validation discipline is real.
* **The one genuine "fewer than n/4 bits suffice" result** — machine-checked, and it is about
  the **unbalanced** case, not a Coppersmith crossing:
  `NegativeResults.lean:144-158` (theorem `known_leak_maximized_at_balanced`): the required
  leakage is `(β − β²)n`, maximised at `n/4` exactly at `β = 1/2`.
  **⇒ CLOSURE 1 MUST KEEP ITS BALANCED-`pq` QUALIFIER**, or be restated in this form.
* **Round47's own HM barrier** — `Round47_HMBarrier.md:69-76` derives (from Herrmann–May's own
  displayed equations) that the multivariate method **contains Coppersmith as its extremal
  limit** and that cost `exp(Θ(m²))` dominates gain `exp(−Θ(m))` for every `m`. This is
  *stronger* evidence **for** Closure 1 than anything in rounds 97–99, and rounds 97/98/99 never
  cite it while calling the multivariate question "the one live door."

---

## RECOMMENDED CORRECTIONS TO THE CLOSURE SET

1. **Closure 4 must be re-scoped** from "LLL is provably optimal on NFS lattices" to: *no
   constant improvement demonstrated on the lattices tested — 7-dimensional, 32–55 bits, without
   Montgomery normalisation, with a control showing LLL is strictly suboptimal in 1/60.*
   Round 48 withdrew "provably nothing" itself.
2. **Closure 5 must carry the model-class scope** ("within the LGST model class") and must not
   inherit `RESEARCH.md`'s bare `1.9018836`.
3. **Closure 6 is safe as an argument but not as a census row** — Round48_SUMMARY.md:258 asserts
   the opposite in the same table, and the adversarial audit backs :258.
4. **Closure 1 needs the balanced-`pq` qualifier**, and `Round48_SUMMARY.md:546` /
   `RESEARCH.md:543-550` / `Round98_SweepRedundant.md:21` should not be cited as sources for it.
   Use `Round107_ResidueFirmFrontier.md:24-29`.
5. **Closure 3 should note** that Round 51 proposes the class-group route as open/highest-ceiling
   and that `RESEARCH.md:7303-7306` asserts class-group smoothness is *proven* with an optimal
   sieve — neither corrected.

> ### ⚠️ ROUND 55 — **THE `2601.11131` SUSPICION IS WITHDRAWN. IT IS NOT A PHANTOM.**
> **Verified against the arXiv API (`totalResults=1`, full metadata) and OpenAlex, independently:
> David Harvey and Markus Hittmeir, *Deterministic methods for finding elements of large
> multiplicative order*, `arXiv:2601.11131v2` [math.NT], v1 16 Jan 2026, v2 5 Jun 2026, 13 pp.
> The attribution recorded above (Harvey & Hittmeir) was **correct all along**.
> **ROOT CAUSE OF THE FALSE FLAG:** the round-54 fetch requested `2601.11131` and returned
> **HTTP 200 with a real abstract for a DIFFERENT paper** — `arXiv:2010.05450`, Harvey's
> `N^{1/5}` paper — which contains **zero** mentions of `2601.11131`. *A response that
> succeeds for the wrong document is indistinguishable from one that succeeds for the right
> one, unless you verify the returned identifier matches the requested one.*
> See `Papers/no_bottleneck_and_no_regime_boundary.md` (#539).
