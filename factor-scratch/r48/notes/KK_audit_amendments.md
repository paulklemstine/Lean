# KK — adversarial audit of the AMENDMENTS to the six round-48/49 factoring papers

**Auditor:** KK. **Date:** 2026-10-03.
**Scope:** the *amendment pass* — edits made AFTER the previous audit, never themselves audited.
**Scratch + all verification code:** `factor-scratch/r49exp/audit3/`.

> **6 FATAL · 18 MATERIAL · 11 MINOR.** Two parallel audits (same sandbox, reported in)
> independently confirmed four of mine and added more. **Every shared claim was re-derived by me
> before inclusion**, and where the two audits reached the same figure by different routes
> (the `Ψ/ρ` magnitude, FATAL-4; the inverted inequality, MAT-11) they agree. **One sub-agent
> finding was refuted on re-derivation** — see the RECONCILIATION section below; it would have
> become a spurious FATAL. That check is why the numbers here can be acted on.

The prior audit's brief was that this pass had already produced one half-applied fix (a
coefficient changed `2 → 4` while three derived values stayed stale). **It repeated that class
of error at least five more times.** The dominant failure mode is not arithmetic — it is that
a correction was written into the *body* of a document while the *abstract*, the *title*, the
*bolded claim*, the *concluding summary*, or the *sibling paper* kept the withdrawn wording.

---

## THE TWO HEADLINE QUESTIONS

**(a) Are `14.1% [13.3, 15.0]` and the `0.859 [0.851, 0.867]` ratio consistent?**
**YES — they are the same fact.** `1 − 0.8586 = 0.1414`, and the CI maps element-wise:
`1 − 0.8667 = 13.3%`, `1 − 0.8505 = 15.0%`. No contradiction. §6.2's headline survives.

**(b) Is the `20/27` derivation real, or a truncation coincidence?**
**The conclusion is real. The derivation as written is WRONG, and reaches the right answer only
through an undeclared renormalisation that hides a factor-2 error in its own stated law.**
The stated law `P(s=j) = 2^{−(j+1)}` is false (empirically `2^{−j}`, off by exactly 2×, mass
0.5 not 1.0). Taken *literally* the note's derivation yields **`5/27 = 0.185185`, not `20/27`**
— a 4× error. It lands on `20/27` only because the code divides by the truncated probability
mass (≈ 1/4), which cancels the factor-2 exactly. The truncation is *not* the culprit: the
truncated sum converges monotonically and would have been harmless. See **FATAL-2**.

---

# FATAL

## FATAL-1 — #523's ABSTRACT still asserts, in bold, the exact claim §4.3 withdraws

`Papers/a_square_minus_a_cube_divides_twice.md`

§4.3 (line 148) states verbatim:

> **Withdrawn:** *"for every `k ≥ 2`"*, and *"independent of `k`"*.

The **abstract** (lines 15–19) still carries, as the paper's headline theorem and in bold:

> We determine the exact local law: for **every odd prime `p` and every `k ≥ 2`**,
> **`P( p^k ∣ a² − b³ ) = (2p − 1) / p^k`**
> — that is, `2 − 1/p` times the uniform rate `1/p^k`, **independent of `k`**.

Both withdrawn phrases appear **verbatim and unretracted**. The correction banner at line 6
mentions only the `k ≥ 2` part, and an abstract is what a reader, an indexer, and the issue
body carry. §2 line 69 additionally still heads a bullet **"The excess is `k`-independent."**

The claim is false at `k = 6` and beyond — I enumerated it (below), and §4.1/§4.4 say so
themselves.

## FATAL-2 — the `20/27` note's stated law is false, and its own arithmetic gives `5/27`

`factor-scratch/r48/notes/HH_explain_20_over_27.md`, line 23.

The note states: *"For random primes, `s` itself is geometric: `P(s = j) = 2^{-(j+1)}`, `j ≥ 1`."*

**This is false.** For odd primes `s = v₂(p−1) ≥ 1`, and `P(s=j) = 2^{−j}`. Measured over the
216,815 primes below 3·10⁶ (`audit3/A3_empirical.py`):

| s | measured `P(s)` | `2^{−j}` | `2^{−(j+1)}` (note) |
|---|---|---|---|
| 1 | 0.500574 | 0.500000 | 0.250000 |
| 2 | 0.250038 | 0.250000 | 0.125000 |
| 3 | 0.124604 | 0.125000 | 0.062500 |

The note's law has **total mass 0.5, not 1.0** — it is not a probability law.

**Consequence, computed in exact rational arithmetic** (`audit3/A3_exact.py`): with the note's
stated law, the weighted sum converges to

> `0.18518518518518517` = **`5/27` exactly** — and `20/27 = 4 × 5/27`.

With the **correct** law `2^{−j}`, the sum converges to **`20/27` exactly** (exact-fraction
deficit `1.6 × 10⁻²⁷` at `S = 90`, monotone from below). So:

* the **constant `20/27` is correct and now genuinely derived** — this is real progress, and the
  MC agrees: 400,000 random `(p,q,g)` trials give `0.741668`, **+1.34σ from `20/27`** and
  **+803σ from `5/27`** (`audit3/A3_mc.py`);
* but **the derivation as published does not produce `20/27`**. It produces `5/27`. The
  printed table value `0.74061428` is *exactly* the renormalised truncated sum, i.e. the raw
  `0.18506317` divided by the truncated mass — a step the note **never declares**.

An undeclared renormalisation is precisely what let a factor-2 error in the law pass as a
confirmation of a prettier constant. The note's own self-test caught a *different* error
(`s=1` truncation, correctly) and thereby earned confidence in a step it never tested.

**Fix:** state `P(s=j) = 2^{−j}`, delete the renormalisation, and the closed form is `20/27`
with no residual and no truncation caveat at all.

## FATAL-3 — #522 withdraws "structurally excluded / impossible" and then uses it 6 more times,
## including in the title

`Papers/the_smoothness_wall_is_a_subgroup_wall.md`

Line 44 concedes the point:

> It is a cost-model statement, **not a theorem**, and the audit is right that
> **"structurally excluded / impossible" overstated it.**

Yet the withdrawn wording survives, unretreated, in:

| line | text |
|---|---|
| 3 | **title**: "…the class group is **structurally excluded**…" |
| 66 | "…is **structurally excluded**, by an algebraic argument…" |
| 69 | "This is not 'unlikely'; it is **impossible**" |
| 146 | **section heading**: "## 2. The class group is structurally excluded — **a proof, not a measurement**" |
| 232 | "The class group is ***structurally excluded***, not merely unlikely" |
| 358 | "**Closed by this paper.** … structurally excluded by `16 ln L < L`" |

A cost-model inequality cannot be "a proof" (146) or "impossible" (69) while the paper's own
§0.1 says it is "not a theorem" (44). This is the single largest instance of the half-applied
fix: the retraction is present and the retracted claim is unchanged everywhere it counts.

---

# MATERIAL

## MAT-1 — #523 §6.2's own two percentages do not give its stated enrichment

Line 312–313:

> 58.6% of *those* relations satisfy the zero-zero configuration … against 3.6% expected —
> **18.8× enriched**.

`58.6 / 3.6 = 16.28`, not 18.8. Neither is 18.8 reproducible from the source
(`nfs_e2e/out/k_attrib.txt`): `1694/2889 = 58.64%` observed; expected `103.09` hits
(`p = 2,3,5`) → `16.43×`, or `115.42` across all attributed primes → `14.68×`.
**18.8× is unreachable from the data *or* from the paper's own printed numbers**
(`audit3/A2_enrich.py`). The observed fraction and the expected fraction are each right; the
multiple is simply wrong.

## MAT-2 — #523 §6.2 qualification 1 is FALSE by the data the section cites, and contradicts
## the bolded claim 12 lines above it

Line 308–310: *"There is no decision to take: **no sub-box beats the free global rate**."*
Line 296 (bold): *"**The gain SURVIVES sieving** — the audit's 'every net gain < 1' is false."*

The source defines the test (`nfs_e2e/out/results.txt`, line 283):
*"If some sub-box beats the global ratio, the gain **IS** localisable and a sieve could be aimed
at it."* By that criterion the max mod-4 sub-box beats the global rate at **every** operating
point:

| u | max sub-box | global | beats by |
|---|---|---|---|
| 6.00 | 28.4000 | 5.0225 | 5.65× |
| 3.00 | 2.5950 | 1.2709 | 2.04× |

So §6.2 asserts localisability and non-localisability in the same breath. Only one can be
carried, and the honest reading of the data is **localisable**. (Either the qualification is
wrong, or the bolded claim overstates — the two are not jointly satisfiable.)

## MAT-3 — #523 §6.2 omits `u = 4.50`, the largest reduction in its own table, and reports
## ranges that silently exclude the extreme operating points

The paper's cost-ratio table lists `u = 3.00, 3.60, 4.00, 5.14, 6.00`. The source has **six**;
`u = 4.50` (`B=256`, cost ratio `0.5085`, a **49.2%** reduction) is dropped. The claim *"The
25–38% band corresponds to `u ≈ 3.5–4.0`"* is built on the five retained rows.

The same selective-range pattern recurs twice more in §6.2:

* *"About **37–40%** sits at `k ≥ 6`"* — the full range is **37.0%–53.4%**; `u = 6.00` (53.4%)
  and `u = 5.14` (43.3%) are excluded.
* *"`k = 2` carries **23–53%**"* — the full range is **10.2%–53.2%**; `u = 6.00` (10.2%) and
  `u = 5.14` (17.3%) are excluded.
* *"`k = 1` is a loss"* — at `u = 6.00` it is exactly **1.0000**, a tie, not a loss.
* *"`k = 5` is a small reproducible loss"* — at `u = 6.00` it is **1.5833**, a clear gain.

In every case the quoted range is the mid-`B` cluster and the two endpoints are dropped.

## MAT-4 — #526 §6 still uses the Dickman figure #523 declares wrong in both magnitude and
## regime (cross-paper contradiction)

* `Papers/choosing_b_well.md` §6: *"at `u ∈ [5,8]` the exact `Ψ` is **8.46× `ρ`**, so every
  `meas/ρ` ratio at `u ∈ [5,8]` here was scoring against a known-invalid reference."*
* `Papers/a_square_minus_a_cube_divides_twice.md` §6.2: *"Dickman `ρ` is worse at NFS operating
  points than previously recorded: exact `Ψ/ρ` is **13.9× at `u = 3` rising to 1244× at `u = 5`**
  — the earlier **'8.46× at `u ∈ [5,8]`' was both too small and in the wrong regime**."*

One paper retracts a figure the other still relies on **in its own load-bearing argument** —
#526 uses `8.46×` to *retire* its `PREREG-1b` falsification as an artefact. That conclusion
was reached against a null the other paper now says is wrong.

## MAT-5 — #523's closing "Open item" still records the framing §4.4 explicitly withdrew

§4.4 (line 185) corrects the record: *"The earlier version of this paper recorded the open
item as a '`p = 2` contribution'; it is a general `k ≥ 7` phenomenon."*
The document's **last line** (348) nevertheless reads:

> **Open item:** the 2-adic anomaly at `p = 2, k = 6` (§4).

The paper ends by re-opening the exact item it declared a mis-framing.

---

## MAT-6 — the census carries the retracted Dickman figure as a live claim

`Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`, row **#525** (line 35):

> …and **Dickman `ρ(u)` is NOT a valid null in this regime** (`u≈5–8`; exact `Ψ` is **8.46× ρ**)

#523 §6.2 retracts exactly this: *"'8.46× at `u ∈ [5,8]`' was **both too small and in the wrong
regime**"*, giving 13.9× at `u=3` and 1244× at `u=5`. So the stale figure now lives in **three**
places — #526 §6 (MAT-4), the census row, and the one place that corrects it. The census row is
the version an indexer or triage reader sees.

## MAT-7 — the census asserts the `20/27` mechanism is UNEXPLAINED, contradicting the note
## that closed it

Census line 487:

> …but the *mechanism* producing 20/27 remains **unexplained**: measured and confirmed, not
> derived.

`notes/HH_explain_20_over_27.md` opens with *"The open item … **That is now closed**."* The
census was not updated when the note landed. Stale in the conservative direction, but it is
exactly the row a reader would consult.

*(Amended in place: this defect is **subsumed by FATAL-2** in severity — until the note's law is
corrected, "not derived" is arguably still the safer census entry. Fixing FATAL-2 first makes
this row correct again.)*

## MAT-8 — the census papers-table contains a DUPLICATED row for #524

Lines 36 and 37 are **two rows for the same paper, same issue, same rank `4`**, describing the
same result. Line 37 is line 36 plus *"best cost cut 2.36×, held out"* and a parenthetical on
the 75% misattribution — i.e. the correction was made by **appending a new row instead of
editing the old one**. The old row survives in full. This is the half-applied-fix failure mode at
the table level, and it will double-count in any tally over the papers table.

## MAT-9 — the census omits paper #522 entirely, under a heading that says "Two papers"

The DELIVERED section (line 28) is headed **"### Two papers, two issues"**. The table beneath it
holds **six data rows covering five distinct issues** (#521, #523, #524 ×2, #525, #526).

**`Papers/the_smoothness_wall_is_a_subgroup_wall.md` (#522) has no row at all** — it appears
nowhere in the papers table, and nowhere in the census by filename. Its *substance* leaks into
prose (lines 41, 71, 200: Shoup Thm 15.6, the class-group exclusion), so it was clearly known
to the author, but no row cites it. The heading is a fossil from before #522–#526 existed: a
stale heading the amendment pass never touched.

## MAT-10 — the census HEADLINE propagates the exact claim the paper retracted

Census lines 6–9, the first thing on the page:

> Round 48 produced the program's first factoring method. Stange's multiplicative-relations
> construction (arXiv:2211.06821) factors **181/240 = 75%** of instances…

Paper #524's entire §0 correction is that this attribution is **wrong**: *"That was a
misattribution, and it was withdrawn… The 75% was therefore **never evidence about the ℚ-kernel
construction at all**."* The census carries that caveat only at line 198 — **189 lines below
its own headline**, which asserts the 75% as a property of "Stange's construction".

This is the census violating **its own PROVENANCE WARNING** (line 269), which states:

> **A table row propagates; prose caveats do not. If the status word in the table is stronger
> than the status word in the note, the table is wrong.**

Here it is worse than a table: it is the *headline* that propagates. I checked the warning
against its own rows (A4) and found the failure mode it names **still live in three of the six
papers rows** (MAT-6, MAT-7, MAT-8) plus this headline.

---

- **MIN-6** — the census papers-table row order is `1, 3, 6, 5, 4, 4` — non-monotonic, and the
  `#` column reads as an index. Cosmetic, but it is why the duplicated `4` (MAT-8) survived
  eight edit passes unremarked.
- **MIN-4** — the census's #523 row states the law for `2 ≤ k ≤ 5` (correct) but predates §6.2:
  it still carries only *"its 25–38% collection-cost payoff is **WITHDRAWN**"* and never
  mentions the replacement 14.1% measurement. Stale in the *other* direction from its siblings.
- **MIN-5** — census line 478–480 repeats the **same false law** I disproved in FATAL-2
  (`P(v₂(ord)=k) = 2^{−(k+1)}`) in order to derive `2/3`. Its *refutation* of `2/3` is
  nevertheless correct, so no conclusion changes — but the census propagates the bad law that
  FATAL-2 identifies, which is the propagation path the round has been bitten by before.
- **MIN-1** — #523 §6.2: *"`k=1`-only sieve is strictly **worse** (0.63–0.65)"*. Source
  (`results.txt` §2c) gives `1.0000, 0.6897, 0.6252, 0.6266, 0.6374, 0.6453`. At `u = 6.00` it
  is exactly **1.0000** — a tie, not "strictly worse" — and the stated range excludes `0.6897`.
- **MIN-2** — #521 §10.5: the `u = 1.5` and `u = 3.0` rows print ratios, CIs and Fisher `p`
  (`0.00244`, `1.0000`) but their class/EC counts are `—`, so the rows are not checkable from
  the table, though the prose leans on `u = 1.5` being significant.
- **MIN-3** — #523 §2.1 says the count grows like *"a factor `2p−1` against the `p` a generic
  congruence of that height would have"* — the same `2p−1` used for the ratio, but the text
  slips between a *count* and a *ratio*, which is where the `1+1/p` → `2−1/p` error came from.

## FATAL-4 — the Dickman "correction" is itself overstated ~10×, and the whole corpus inherits it

This was my FLAG-1, then **independently reproduced and pinned to a cause** by a parallel audit.
Both agree the retracted `8.46×` is stale (FATAL-3/MAT-4/MAT-6); this goes further: **the
number meant to replace it is also wrong.**

`notes/CC_nfs_e2e.md:369-372` claims at stated `X = 2²⁴`: exact `Ψ/X = 6.77e-1` at `u=3`
(`Ψ/ρ = 13.9×`) and `1244×` at `u=5`. Exact `Ψ` computed three independent ways (non-smooth
sieve, set generation, ugly-numbers DP), each validated against brute force at tight cases:

| u | B | exact `Ψ/X` | note's `Ψ/X` | exact `Ψ/ρ` | note's `Ψ/ρ` |
|---|---|---|---|---|---|
| 3.0 | 256 | **6.515e-2** | 6.77e-1 | **1.34×** | 13.9× |
| 5.0 | 28 | **2.046e-3** | 4.45e-1 | **5.78×** | 1244× |

**Sanity bound that kills it without any code:** primes `> 256` alone are `1/ln(2²⁴) = 6.01%` of
integers, so **67.7% cannot be 256-smooth.** The note's `Ψ` column is **10.4× too high at `u=3`.**
Its `ρ` column is correct (matches the Dickman table to 0.02%), so the error is isolated to `Ψ`.
Solving for which `Y` yields `6.77e-1` at `X = 2²⁴` gives **`Y ≈ 122867`, i.e. `u = 1.42`** — the
column appears filed under the wrong `u`.

My own independent check agrees on direction and on the implausibility, and adds why
(`audit3/dick_final.py`, self-test-gated): `Ψ(y^u,y)/(y^uρ(u)) > 1` always and **grows with `u`**
— so the *direction* of the correction is right — but it **falls toward 1 as `y` grows**
(at `u=3`: 2.46 → 2.14 → 1.67 for `y = 16, 32, 64`), which is precisely the Dickman asymptotic.
That is why 13.9× at NFS-scale `y` is unreachable, and 1244× more so still.

**Consequence:** the earned rule *"exact `Ψ/ρ` is 13.9× at `u=3` rising to 1244× at `u=5`"* is
**not reproducible as stated**, and it is now load-bearing in three places — #523 §6.2, the
census row for #525, and #526 §6 (which uses the *stale* 8.46× to retire its own falsified
prediction). Two of the three live numbers are wrong in the same direction. The correct NFS-scale
figures are ~**1.34× at `u=3`** and ~**5.8× at `u=5`** at `B=256/28`.

*Scope note:* the reproducing agent's `ρ` ODE degrades past `u≈7`, so only `u=3`–`5` — the NFS
regime and the only regime any of these papers operate at — is trustworthy here.

---

## FATAL-5 — #526's headline `186×` does not follow from its own table (and is in the title)

`Papers/choosing_b_well.md` §4, verified by direct arithmetic:

| row | cost | claimed | computed from the printed baseline `2.22 × 10⁵` |
|---|---|---|---|
| baseline (`b=6, c=10`) | 2.22 × 10⁵ | — | — |
| best `b` under OBJ-1 | 3,269 | **68×** | **67.9× ✓ consistent** |
| best `b` + `c=1` + Jacobi | 2,724 | **186×** | **81.5× ✗ inconsistent** |

Within a single table, row 2 checks out against the printed baseline and **row 3 does not**.
Reaching `186×` needs a baseline of **506,664**, not the 222,000 printed. The `c=1` step actually
buys `3269 → 2724 = 1.20×`, but the table's own `68× → 186×` implies `2.74×` — off by **2.28×**.

So the `68 → 186` jump is a **baseline switch** (`c=10` → `c=1`), not a cost gain, and it is
presented as a cost gain. The figure is in the paper's **title** ("a 186× cost reduction"), in
its abstract, and in the census row. The census reproduces the identical defect with the same
denominator: `2.22e5 → 2,724 = 81.5×`, not 186×.

---

## MAT-11 — census: the inequality direction is inverted (verified independently by me too)

Census `:60`: ``16 ln L < L ⟺ L < 67.36``. **Backwards.** `16 ln L = L` has **two** roots,
`1.069102` and `67.361078` (I bisected both; `audit3/` run output). `16 ln L < L` therefore holds
for `L < 1.069` **or** `L > 67.361` — confirmed by direct evaluation at `L = 0.5, 1.0, 1.05`
(TRUE) and `L = 2, 10, 67.0, 67.361` (FALSE). The numeric anchor is right (`L* = 67.3611 →
N* = 1.797e29` ✓); the direction attached to it is not. Inherited verbatim from
`the_smoothness_wall…md:26,203`.

---

## MAT-12 — census: `1269σ inside its own proved regime` binds two different numbers

`1269σ` appears **only in note prose** (`K_stange.md:10,287`) and in **no measurement table**.
*Inside the proved regime* the maximum is **247σ** (`K_stange.md:176-181`). The note separates
them; the census binds them into one claim. Repeated at `:10, :36, :37, :197, :198`.

## MAT-13 — census: a second duplicated pair, in the axes table

Beyond the duplicated #524 row (MAT-8), the census table at `:195-209` lists the Stange axis
**twice** — `:197` "✓ WORKS — the program's first method" vs `:198` "✓ WORKS — the program's
first factoring CONSTRUCTION". Both duplicate pairs were produced by **adding a corrected row
without deleting the stale one** (commits `0273b981b`, `e4861ad3b`). This is the same defect
twice, which is what makes it a pattern rather than an accident.

## MAT-14 — census: the `181/240 = 75%` headline is also a mis-transcription

Compounding MAT-10, `181/240` is the wrong denominator: the paper's own artifacts say
**200/260 = 0.769** (`stange_works…md:104-105`; `U_stange_improve.md:50-53`). The headline
therefore carries a wrong fraction, a retracted attribution, and a superseded rate.

## MAT-15 — census: `"0.1% of cost"` is contradicted by the log the paper cites

Census `:35` and `the_optimal_sampler.md:28` say a smoothness test is **0.1% of cost**. The
verified log they cite (`C_fixed.txt:23`) reads `mults/attempt=480184 smops/attempt=10807557`
— smoothness is **95.7%** of stride's cost, 22.5× the multiplications. The 0.1% is pow-priced
against `pow(g,x,n)`, exactly the cost stride eliminates. The paper's own `exp_s2s3.py:258-261`
says *"at b=100 it becomes the cost"*, and its objective `(b+c)(1+b)/Ψ` treats smoothness as
first-order.

## MAT-16 — census: "The live thread this round opens" is dead

`:254-265` presents two items as live. `U_stange_improve.md:16-20` proves the `α_t` bias
*"false, and not for want of a large enough sample"*, and `:274-276` already answers the decay
question. Both open items are closed.

## MAT-17 — census: `"Three independent defects"` survives at `:88` though retracted at `:199`

The census retracts the word "independent" at `:199`; the paper had already deleted it. `:88`
still carries it.

---

## MINOR (census, additional)

- `:97` "four of eight cells negative" — `A_classgroup.md`'s own table has **three** negatives
  plus one exactly `+0.000`.
- `:58, :201` attribute `0/890` to `notes/M_forensics.md`; it lives in `notes/F_rigorous.md:427`.
- `:433/:434` 12.3× and 11.5× are **both correct** (different denominators) but the census never
  says so — a reader sees two numbers for one comparison.
- `:456` "median largest prime 90,599 vs 61,861" exists only in `mechanism_probe.json`; the cited
  note reports **geometric means 136,151 vs 106,391**. Against that note's designated correct
  null (odd-uniform) the "less smooth" claim **inverts**.
- The p.405 Shoup quote is from **SEDL (DLP mod prime)**, not SEF/factoring; no SEF analogue
  exists in the extract. (`the_smoothness_wall…md:71` cites it as factoring context.)

## FATAL-6 — #522 carries TWO conventions for `L[1/2]`, differing by √2; the headline
## threshold is wrong by 41 orders of magnitude under the paper's own table

`Papers/the_smoothness_wall_is_a_subgroup_wall.md`. This is the *same* half-applied-fix species as
the `2 → 4` fix the previous audit caught: the table was corrected, the derivation was not.

| site | convention | at 256 bits |
|---|---|---|
| §2.2 table caption + corrected column (`:186-192`) | `log₂ L[1/2] = √(2 ln N ln ln N)/ln 2` — **with √2** | **61.85** ✓ |
| derivation `ln k = 4√(L ln L) − L` (`:21-23, :199, :203`) | `(kN)^{1/4} = exp(√(L ln L))` — **no √2** | **43.73** |

The two differ by exactly `√2 = 1.4142` (verified at 256 and 1024 bits). The §2.2 table is
internally self-consistent with the √2 caption — the amendment fixed it correctly. The
**derivation** was left on the old convention, and §2.3's new text inherits the √2 version.

**Consequence.** Setting `ln k = 0`:

* no-√2 derivation → `L² < 16 L ln L` → **`16 ln L < L`** → `L* = 67.3611`, `N* = 1.797 × 10²⁹`
  ← **this is what the paper prints, at `#522:8, 29, 68, 203, 358` and `Census:60, 201, 518`**
* the paper's own table convention → `L² < 32 L ln L` → **`32 ln L < L`** → `L* = 163.0000`,
  `N* = **6.166 × 10⁷⁰**`

Both roots are verified by bisection (`audit3/sqrt2.py`). So under the paper's **own corrected
table**, the headline exclusion threshold should be ~`10⁷⁰`, not `1.8 × 10²⁹` — **41 orders of
magnitude** apart.

The qualitative conclusion survives and is in fact *strengthened* under the consistent
convention (a larger threshold excludes more, not less). But the headline number of the paper's
headline correction is wrong, and it is printed at **eight** sites.

> Note this is precisely the defect class the previous audit flagged ("a coefficient changed
> from 2 to 4 while derived values stayed stale"). Here the coefficient *is* the √2, the table
> was fixed, and the derived threshold stayed stale. **The lesson did not transfer.**

## MAT-18 — #521 §10.5 `u = 3.0`: `Fisher p = 1.0000` is false (half-applied fix, third row left)

The amendment recomputed the `u = 1.5 / 2.0 / 2.5` rows and **left `u = 3.0` at its inherited
value**. Against the upstream counts in `notes/G_adversary.md:117` (`7/267` vs `212/4000`):

| | value |
|---|---|
| `7/267 = 0.026217`, `212/4000 = 0.053000`, ratio `0.494665` | — |
| true two-sided Fisher `p` (`scipy.stats.fisher_exact`) | **0.061001** |
| paper `:395` prints | **1.0000** |
| `notes/G_adversary.md:117` prints | 1.0000 (inherited, uncorrected) |

A two-sided Fisher `p` equals 1 only when the observed cell is the unique mode. **Negative
control run to prove the checker separates the cases:** `Fisher(0/267, 0/4000) = 1.000000` — a
genuine `p = 1`, both arms empty; `Fisher(7/267, 212/4000) = 0.061001` — arms non-empty. The
paper's row is the second case.

This also falsifies the paper's claim of *"recomputation validated against
`scipy.stats.fisher_exact` to 1e-12 on **9/9** cases"* — one of the four printed rows was not
recomputed.

*Caveat, stated honestly:* the paper prints `—` for the `u = 3.0` counts, so the inputs are
inherited, not stated. **Test at the tightest case:** the row is simultaneously the least
checkable *and* the one left stale.

---

# WHAT I CHECKED AND FOUND CLEAN

Listed because a clean bill of health is only meaningful with the attempts enumerated.

1. **#523's valuation tables — ALL VERIFIED EXACT** by exhaustive enumeration over all
   `(a,b) mod p^k` (`audit3/A2_kenum.py`): §2 reproduces `1.000 / 2−1/p` for `p = 3,5,7,11,13`
   at `k = 1,2,3,4` to 4 dp; §4.1 reproduces the `k=6` departure as exactly `+(p−1)` for
   `p=3` (+2.0000) and `p=5` (+4.0000).
2. **#523's `k ≥ 7` generality claim — VERIFIED CORRECT** (A2, second assignment). This is the
   claim I most expected to be overreach. Enumeration (`audit3/A2_k7fast.py`):

   | p | k | measured | formula bracket | verdict |
   |---|---|---|---|---|
   | 2 | 6 | 2.5000 | 1 | match |
   | 2 | 7 | 2.5000 | 0 | departure |
   | 2 | 8 | 3.5000 | 1 | departure |
   | 3 | 6 | 3.6667 | 2 | match |
   | 3 | 7 | 3.6667 | 0 | departure |
   | 3 | 8 | 5.6667 | 2 | departure |

   The departure at `k = 7` is indeed general, not `p = 2`-specific — **the amendment is
   right**, and it is right for a reason the paper does not give (the bracket at `k=8` is
   `4` for `p=3`, double `p=2`'s `2`; the paper does not report the `k=8` case).
3. **#522's `ln k` derivation — VERIFIED CORRECT** (A1). `ln k = 4√(L ln L) − L`; boundary
   `16 ln L = L`; large root `L* = 67.361078` (paper: 67.361 ✓); `N* = 1.7970 × 10²⁹`
   (paper: 1.797 × 10²⁹ ✓); `ln k = −436.73` at `n = 2¹⁰²⁴` (paper: −436.7 ✓).
   Self-test: the *withdrawn* law's own root is `L* = 8.6132` (paper said `L < 8.6` ✓).
4. **#522's `L`-table — VERIFIED, all 8 cells** (`L = 354.9/709.8/1419.6/2839.1` and
   `16 ln L = 93.9/105.0/116.1/127.2`), every cell recomputed and matching.
5. **#521 §10.5 Fisher/CI table — VERIFIED CORRECT.** The amendment fixed it properly. Katz
   log-method risk-ratio CIs recomputed from scratch: `u=2.0 → [0.6295, 0.9748]` (paper
   `[0.63, 0.97]` ✓), `u=2.5 → [0.3888, 0.8784]` (paper `[0.39, 0.88]` ✓). Risk ratios
   `0.7833 / 0.5844` ✓. Two-sided Fisher `p = 0.02298 / 0.00572` vs paper `0.0230 / 0.00572` ✓.
6. **My own verifier was self-tested in both directions** (`audit3/selftest_A2.py`). It returns
   the **null exactly** where null is correct (`k=1 → 1.000000` for `p = 3,5,7`), and its two
   negative controls fire as they must: the paper's *own* documented `drop_zero_zero` bug
   reproduces (`p=3,k=2 → 0.6667` instead of `1.6667`), and a wrong normalisation is caught
   (`15.0000`). The same file demonstrates the float cube-root trap still bites
   (`int(k**(1/3))` understates at `k = 125` and `k = 216`).
7. **§6.2's headline 14.1% is arithmetically sound** and maps element-wise onto the source
   cost ratio and CI (§ headline (a) above).
8. **`20/27` is confirmed by independent Monte Carlo** — 803σ from `5/27`, 1.34σ from `20/27`.
9. **GNFS constants are consistent across all six papers** — `1.92299` / `1.9229994`
   everywhere; the `1.90188` misattribution is stated once, in #523 §7, and is not repeated
   as a live claim anywhere.

---

# RECONCILIATION — a sub-agent finding I REFUTED, and why it matters that I checked

A parallel audit reported the #521 §10.5 Katz intervals as **wrong in all four rows**
(claiming widths 1.28×–4.1× too wide, and that at `u = 3.0` the paper's CI contains 1 while the
"true" one excludes it — i.e. the very defect the amendment claims to have fixed).

**That finding is wrong, and I would have reported a spurious FATAL had I relayed it.** Both
numbers are the same statistic computed two ways (`audit3/reconcile.py`, `u = 2.0`):

| method | standard error | CI | paper prints |
|---|---|---|---|
| **Katz log method on the RISK RATIO**, `se = √((1/a−1/n₁)+(1/c−1/n₂))` | 0.111565 | **[0.6295, 0.9748]** | **[0.63, 0.97]** ✓ |
| Wald on the risk **DIFFERENCE**, `se = √(p₁q₁/n₁+p₂q₂/n₂)` | 0.027123 | [0.7428, 0.8261] | — |

Katz (1974) takes the **log of a ratio** and is the method the column header names; the
`√(p(1−p)/n)` variance belongs to the **difference**, not the ratio. The paper's intervals are
the correct Katz intervals — confirmed independently by me *before* the sub-agent reported and
again after. **It is worth stating that the paper was right here and both audits initially
looked like they might say otherwise**: this is the round's own recurring trap, pointed at its
own auditor.

Two sub-agent findings I did **not** re-derive (reported as received, not my verification):
#521 §9 `√(π/8) = 0.354` (correct value `0.6267`; `0.354 = √(1/8)`, π dropped), and #522 §2.1
`0/890` vs an arithmetically consistent `0/790` (`640 + 150`). Both are simple arithmetic and
both look right on inspection.

---

# RECOMMENDED FIX ORDER

1. **FATAL-1** — rewrite the #523 abstract and the §2 `k`-independence bullet. Highest
   visibility; currently the paper's headline is a withdrawn claim.
2. **FATAL-2** — correct `P(s=j) = 2^{−j}`, delete the undeclared renormalisation. This
   *strengthens* the note: `20/27` becomes an exact closed form with no residual.
3. **FATAL-3** — propagate #522's retraction to the title, §2 heading, lines 66/69/232/358.
4. **MAT-1** — `18.8×` → `16.4×`.
5. **MAT-2** — delete qualification 1 or the bolded claim; they cannot both stand.
6. **MAT-3** — restore `u = 4.50`; widen all four ranges to their true support.
7. **MAT-4 / MAT-5** — sync #526's Dickman figure and #523's closing open item.
8. **FATAL-6** — pick ONE convention for `L[1/2]` in #522 and propagate it. If the table's √2
   convention is canonical, the threshold becomes `32 ln L < L`, `N > 6.2 × 10⁷⁰`, and **eight
   printed sites** change. Do this before the corrected table is cited anywhere else.
9. **FATAL-5** — restate #526's `186×` against a printed baseline that yields it, or report
   `81.5×`. The title and abstract change either way.
10. **MAT-18** — recompute the `u = 3.0` Fisher row, and either print its counts or drop the row
    so it cannot be inherited silently.