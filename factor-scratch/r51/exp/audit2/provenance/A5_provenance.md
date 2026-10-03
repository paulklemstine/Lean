# A5 — Provenance audit of the round-48 census

**Auditor:** adversarial provenance pass (assignment A5).
**Target:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`, 664 lines.
**Date:** 2026-10-03. Local files only; no WebSearch.

## Method

Every row of "■ THE CENSUS — what round 48 added" (SUMMARY lines 193–208) was extracted
verbatim, then searched against `factor-scratch/r48/{notes,exp,lit,_shared}/`, the r49
scratch tree, `~/factor47/`, and the `Catalog/.../Round4*.md` corpus. Verdicts:

- **TRACABLE-TO-MEASUREMENT** — an experiment file exists and carries the number.
- **TRACABLE-TO-ARGUMENT** — a written algebraic/proof argument exists.
- **TRACABLE-TO-CITATION** — a fetched source with page + verbatim quote exists.
- **UNTRACEABLE** — no artifact of any kind supports the row.

Absence of a file is reported as a finding, not smoothed over.

---

## 1. The census table, row by row

### R1. Stange ℚ-kernel method — **✓ WORKS — the program's first method**
> **181/240 = 75%** at `n ≈ 2^20`–`2^40`; H3.1 refuted to **1269σ** *inside its own proved regime*; printed probability inverted vs the paper's text; regime gap **4.3 orders** at `n=10^20`

**TRACABLE-TO-MEASUREMENT + CITATION.**

- `notes/K_stange.md:233-235` — the per-size table (`46/60`, `50/60`, `42/60`, `28/40`, `15/20`), summing to **181/240 = 0.754**.
- `notes/K_stange.md:287` — H3.1 deficit 0.08–0.24, up to 1269σ; regime gap at line 288.
- Paper fetched: `exp/stange/stange.pdf` (161.6 K), `exp/stange/stange_layout.txt` (36.0 K).
- Experiment scripts present: `exp/stange/exp_kill.py`, `exp_h31.py`, `exp_control.py`, `exp_control2.py`, `exp_gap.py`, `verify_independent.py`; raw JSON `kill_{0..4}.json`, `h31_{0..4}.json`, `controlB_{0..5}.json`; logs `kill.log`, `h31.log`, `h31b.log`.

⚠️ **Internal inconsistency (minor, but the census inherits it).** `notes/K_stange.md:8`
says "**181/280** total" while line 235 and the census say **181/240**. The census picked
the correct denominator; the note's own summary line is wrong. Anyone citing `K_stange.md:8`
gets 280.

⚠️ **`20/27` correction is verified but its mechanism is explicitly unexplained.**
`notes/X_verify_20_over_27.md` is admirably honest — it withdraws the orchestrator's own
`2/3` derivation ("Clean, exact, and **not 20/27**") and states "The provenance of
`20/27` remains **not fully explained**". This does *not* damage the census row, but the
summary's "the printed success probability is **inverted relative to the paper's own text**"
(SUMMARY:11) is a claim about Stange's paper whose support is `notes/K_stange.md` +
the issue, not a page-quote in the summary itself.

---

### R2. Class-group smoothness lottery — **CLOSED ×3**
> self-referential baseline; half-bit artifact; parity mismatch

**TRACABLE-TO-MEASUREMENT.**

- Self-referential baseline: `notes/M_forensics.md` (0.925 = `ρ(log₂(1684)/log₂(1000))` = 0.9273, Dickman).
- Half-bit artifact: `notes/A_classgroup.md:72` — matched gaps **−0.050** (SUMMARY cites the range `−0.050 to +0.015`).
- Parity mismatch: `notes/G_adversary.md`; independently reproduced at `notes/O_e6c_recheck.md:209` (EC 66.3% even, n=28,000; class 100.0% odd, n=9,000).

⚠️ The parity defect's *statistical* backing in the summary (Fisher p = 0.0000 / 0.0028,
ratio 0.78 / 0.58) lives in `notes/G_adversary.md`; the raw log is `exp/G/G_parity_L29.log`
(636 B) and `exp/parity_L29_final.log` (636 B). Note `exp/ratio_L29.log` is **0 bytes** —
a claimed control artifact that is empty. The surviving numbers come from
`exp/e6c_recheck/e6c_recheck_results.json` (799.6 K), which does carry them.

---

### R3. Class-group walk as `L[1/2]` — **CLOSED (structural)**
> `Cl(O_D) mod p` trivial; walk is SQUOF at `N^{1/4}`

**TRACABLE-TO-ARGUMENT + MEASUREMENT.**

- Triviality argument written out: SUMMARY:110-113 gives the two cases (`p∤D` → `O_D/p` semilocal, all ideals principal; `p|D` → ideal of `[a,b,c]` ≡ `a·O_p`).
- Persistence test 6/6: asserted in SUMMARY:111; backing in `notes/A_classgroup.md`.
- SQUOF identification: `notes/A_classgroup.md:147` — "19 of 19 factors had `a_k = p` exactly"; complexity at line 154.

⚠️ `notes/A_classgroup.md:176` records: **"No citation is offered for the SQUOF O(N^{1/4})
complexity beyond the Wikipedia page"** and line 180 that a direct transcription of that
page's SQUOF **fails**. So the "strictly weaker than ECM's `L[1/2,√2]`" comparison in
SUMMARY:120 rests on a Wikipedia-derived complexity bound the note itself distrusts.
The *identification* (walk = SQUOF) is measured and solid; the *complexity comparison* is weakly sourced.

---

### R4. Rigorous `L[1/2]` — **ALREADY KNOWN**
> Shoup Thm 15.6, unconditional since ~2009

**TRACABLE-TO-CITATION. The strongest row in the census.**

- `notes/F_rigorous.md:319-327` — Theorem 15.6, **printed p. 413** (PDF p. 431), verbatim quote.
- `notes/F_rigorous.md:344-350` — the counting argument, **printed p. 412**, verbatim quote.
- `notes/F_rigorous.md:353-358` — Theorem 15.1, **printed p. 399**, verbatim.
- Source in hand: `lit/r1/shoup_ntb.pdf`, `lit/r1/shoup_ntb.txt`.
- The "26.5 vs 123.7 at 256 bits" residual-assumption discharge: `notes/F_rigorous.md:356`
  with the full 5-row table (256/512/1024/2048/4096).

This is the model the other rows should be measured against.

---

### R5. "Structure with order computable without `p`" — **CLOSED (structural)**
> `L < 8.6 ⟺ N < 5400`; 0/890 divisibility

**TRACABLE-TO-MEASUREMENT + ARGUMENT.**

- `notes/F_rigorous.md:427` — "`p | h(−kN)` was never observed (**0/890 total trials**)", with the `k` grid at line 417.
- `notes/F_rigorous.md:444` — the algebra: `2√(L ln L) < L ⟺ 4 ln L < L ⟺ L < 8.6`, i.e. `N < 5400`.
- Independently restated at `notes/B_groups.md:140`.
- Structural-mechanism probe: `exp/r3_why_zero.py` (referenced `notes/F_rigorous.md:516`).

⚠️ `notes/F_rigorous.md:516` flags that this R3 structural explanation is **"partly
refuted"**. The *numerical* 0/890 and the *cost* inequality stand; the *mechanism* offered
for why it is zero does not fully survive its own data. The census row does not carry this
caveat — but the row as stated ("`L < 8.6`; 0/890") does not depend on it.

---

### R6. Function fields / tori / Jacobians — **CLOSED (exactly)**
> `reach_p = L[1/2]`: the useful bit `(D/p)` is the factorization bit; `(D/n)` carries **zero** bits about it (102 vs 105 of 207)

**TRACABLE-TO-MEASUREMENT. But the census misstates the scope.**

- The number: `notes/E_funcfield.md:158-160` — "among D with Jacobi symbol +1, we find 102 with `(D/p) = +1` and 105 with `(D/p) = −1`". 102 + 105 = **207**. ✔
- The reach_p conclusion: `notes/E_funcfield.md:163`, `353-355`.
- Scripts: `exp/06_h2_chooseable.py`, `exp/07_h2_refined.py` both exist; `exp/03_reach_p.py`, `exp/01_cost_to_reach_p.py` exist.

⚠️ **"CLOSED (exactly)" overclaims what the note supports.** `notes/E_funcfield.md:344-351`
gives a family table in which the **norm-one torus with `D = u²−1` reaches `p` at cost 0**
— i.e. it *is* a working factoring method — and line 358-361 states it as a **positive
result**: "a norm-one torus with `D = u²−1` is a **genuine factoring method** requiring
neither a square root mod n nor any knowledge of `p` (12/12 splits measured) … It is
1.5× cheaper than GMP-ECM's ladder." The closure is of the *asymptotic-improvement* question,
not of the axis. The census's word "exactly" invites a reader to believe nothing in the
family works.

⚠️ **The `reach_p = L[1/2]` figure carries an admitted unproven step.**
`notes/E_funcfield.md:209-217` — "**Caveat that must travel with this table.** The L[1/2]
does **not** follow from the order bound alone; it needs the separate *heuristic* that the
group order behaves like a random integer near p" (Brent's Lenstra hypothesis). The census
prints `reach_p = L[1/2]` with no marker that this is heuristic-loaded.

⚠️ **The number-field half of the asymmetry is not sourced.**
`notes/E_funcfield.md:~237` — "The **number-field half** rests on Lenstra–Pomerance 1992,
**which I have not read** (AMS PDF 404s). **The synthesis is mine.**"

---

### R7. Towers (level-raising) — **CLOSED**
> a loss, not a knob: 3.18×/5.74×/8.54× at k=2/3/4

**TRACABLE-TO-MEASUREMENT.**

- `notes/E_funcfield.md:170-176` — the table: k=1 `1.00×`, k=2 `3.18×`, k=3 `5.74×`, k=4 `8.54×` with `u_k` 7.35/14.70/22.06/29.41.
- Script `exp/09_tower.py` exists (confirmed).

Clean row. The second clause — "the degree depends on the unknown `p`" — is an argument,
stated in `notes/E_funcfield.md:177`; it is a correct reading of the table (a degree
parameterized by `p` cannot be selected). ✔

---

### R8. NFS smoothness uniformity — **DEVIATION FOUND (positive)**
> `P(p^k | a²−b³) = (2p−1)/p^k` for odd `p`, `k ≥ 2` — the heuristic is **pessimistic**. 25–38% of collection cost; no exponent change

**TRACABLE-TO-MEASUREMENT.**

- Exhaustive count, **exact, no sampling**: `notes/C_smoothness.md:78-89` — the 6×4 table of `P(p^k ∣ a²−b³)/p^{-k}` for p ∈ {2,3,5,7,11,13}, k=1..4. Every k=1 row is exactly 1.00000; k≥2 rows match `1+1/p` for all odd p.
- Hand-check at p=2, k=2 written out at `notes/C_smoothness.md:~96`.
- Script `exp/e3_mechanism.py` exists.
- Independent implementation: `_shared/nfs_2adic_anomaly.py:6` states the law.

⚠️ **p=3 is a stated exception the census omits.** `notes/C_smoothness.md:88` — "**p=3 is
the sole exception** (1.667 vs 1+1/3): cubes mod 9 lie only in {0, ±1}". The census says
"for odd `p`, `k ≥ 2`", which is false at p=3. One token (`p ≠ 3`) would fix it. This is a
real defect in a row that is otherwise the best-evidenced positive in the census.

---

### R9. Unconditional superpolynomial lower bound — **NONE in any model**
> classical *and* quantum; all such bounds are oracle bounds

**TRACABLE-TO-CITATION.** Two notes, both explicitly method-disciplined.

- `notes/R1_lower_algebraic.md:1-13` — "**Every quoted item below was read out of a PDF I
  downloaded, with the page number read off the PDF itself.** Anything not so obtained is
  marked UNVERIFIED." Bottom line at line 7-9.
- `notes/R1_lower_quantum.md:1-14` — "WebSearch was NOT used at any point … Every claim
  below is marked VERIFIED (PDF in hand, page confirmed, page image read) or UNVERIFIED /
  NOT-FOUND (documented negative)." Headline verdict line 8.
- Source corpora in hand: `lit/r1/` (`detfac_raw.pdf`, `integerFact.pdf`, `jb*.txt`, …).

The "classical *and* quantum" pairing is the strongest form of this row because it is
two independent literature passes reaching the same negative. ✔

---

### R10. Jacobi-symbol graph spectral invariant — **CLOSED (restatement)**
> `p+q = N+1−2·deg` is exact, but `deg = φ(N)/2` and φ is polylog-equivalent to factoring

**TRACABLE-TO-ARGUMENT.** All three links are written out.

- `notes/H_crossdiscipline.md:24` — the identity `p+q = N+1−2·deg`, marked "YES, exactly".
- `notes/H_crossdiscipline.md:151` — "Its **degree** is `|S| = φ(N)/2 = (N + 1 − p − q)/2`".
- `notes/H_crossdiscipline.md:161-166` — "And `deg = φ(N)/2`, and **φ(N) is polylog-equivalent
  to factoring** — so the invariant is a restatement, not a shortcut."
- `notes/H_crossdiscipline.md:148` — the factorization-free Jacobi computation is *verified*
  (`H1b`).
- Scripts `exp/H_f1_ktopo.py` (9.8 K), `exp/H_selftest.py` (7.9 K, "13/13 pass" at `H_crossdiscipline.md:~330`).

⚠️ **"φ is polylog-equivalent to factoring" is asserted, not shown.** It is repeated at
`notes/H_crossdiscipline.md:229` ("`φ` is polylog-equivalent to factoring") without a proof
or a page cite in the note. This is the load-bearing step of the row's closure, and it is
the one link in R10 that is neither measured nor proved. It is, however, a standard
reduction (φ(N) → a factorization) and the note's *direction* (φ is not polylog-computable)
is uncontroversial.

⚠️ The note's own §9 (`H_crossdiscipline.md:317-319`) calls field 6 "**the round's only
genuinely live lead**" and "I would bet against one" — i.e. the *note* treats it as open,
while the census marks it CLOSED. The census's word "(restatement)" is the honest qualifier
and largely reconciles this, but the status word and the note's assessment disagree.

---

### R11. Projective point count over `Z/NZ` — **EQUIVALENT to factoring**
> both directions, no slack (arXiv:1911.11004 p.3); affine twists sum to `4N`, a tautology

**TRACABLE-TO-CITATION + ARGUMENT.** Second-strongest row.

- Source in hand: `lit/1911.11004.pdf` (116.1 K) **and** `lit/1911.11004.txt` (18.6 K).
- Page-verified quote at `lit/EC_FACTORING.md:92`: "**p. 3** … `Theorem 1 Given the number of
  points, affine or projective, of any elliptic curve and one of its twists modulo N we can
  factor N in deterministic polynomial time.`" marked **VERIFIED**.
- `lit/EC_FACTORING.md:111` — the `4PQ` twist identity, "**PDF p. 4**", exact text.
- The two directions proved in `notes/H_crossdiscipline.md:~57-62` (THEOREM H, field 3, with
  the ⇒/⇐ proof and 12-semiprime brute-force verification including the tightest `N = 21`).
- Affine tautology: `notes/H_crossdiscipline.md:~300` ("The affine half is *provably* a tautology").
- Independent re-derivation: `exp/H_f3c_pari_trust.py:5` quotes Thm 1 verbatim in its header.
- ⚠️ `notes/H_crossdiscipline.md:116` cites **p. 3** while `lit/EC_FACTORING.md:111` places
  the `4PQ` identity on **p. 4**. Both are quoted in the corpus; the census's "p.3" is
  correct for Theorem 1, which is what the row actually claims.

---

### R12. Cross-discipline sweep (7 fields) — **CLOSED**
> K-theory, Tate modules, theta, Brauer, information-theoretic — all fail one of the three requirements

**TRACABLE-TO-MEASUREMENT + ARGUMENT, with a scope caveat.**

- `notes/H_crossdiscipline.md:5` — the framing question, one per field.
- `notes/H_crossdiscipline.md:20-27` — the ranked 7-field table with a per-field verdict and an
  explicit "which requirement fails" column. Every field gets a named failure mode.
- Field 5 (K-theory): `notes/H_crossdiscipline.md:229` — `K_1(Z/NZ) = (Z/NZ)*`, order φ(N),
  "F1.1, 0 mismatches"; `Br(Z/NZ) = 0` on every RSA instance.
- Information-theoretic: `notes/H_crossdiscipline.md:300-305` — three numbered negatives
  (AKS 2002 for the decision version; totality of the search problem).
- Scripts: `exp/H_f1_ktopo.py`, `H_f2_classgroup.py`, `H_f2_ray.py`, `H_f3_blocker.py`,
  `H_f3c_pari_trust.py`, `H_f4_theta.py`, `H_f4b_local.py`, `H_f4567.py` — all present.

⚠️ **The census names five fields for a seven-field sweep** (K-theory, Tate modules, theta,
Brauer, information-theoretic) — omitting **field 3** (point count) and **field 6** (Jacobi
graph), which are precisely the two with the strongest results. They have their own census
rows, so this is a presentation choice, not an error; but "CLOSED" over the sweep covers two
fields the note itself calls an *equivalence* and a *genuinely live lead*.

⚠️ Two hypotheses in this sweep were refuted by its own tests (`notes/H_crossdiscipline.md:339-343`):
the theta claim withdrawn (measured index 2–8, not `≥ √N`), and the F4b local-data claim
withdrawn (0/8 agreement). The census's "all fail" is compatible with this — the negatives
are the survivors — but the census does not record that two named quantities were withdrawn
mid-axis.

---

### R13. Partial-information factoring below ½ the bits of `p` — **CLOSED — measured to the bit**
> **31 unknown bits WORKS, 32 FAILS** at N=2¹²⁸: `X = N^{1/4}` exactly.

**TRACABLE-TO-MEASUREMENT. Yes, the script exists.**

- The number: `notes/D_partialinfo.md:73-90` — the six-row table (28→33+ unknown bits) with
  `m=t=20, dim 40` … `dim 52` and "none up to dim 104".
- The 3/3 control: `notes/D_partialinfo.md:36-38` — 31 unk **3/3 recovered `p`**, 32 unk
  **2/2 no vanishing vector**, 48 unk **3/3 no root**.
- Scripts, all present: `exp/exp_boundary.py` (the lattice builder named at
  `D_partialinfo.md:71`), `exp/control_final.py` (named at line 44), `exp/coppersmith.py`
  (12.3 K), `exp/exp_t1.py`, `exp/exp_t2.py`, `exp/exp_t3.py`, `exp/selftest.py`.
- Six-part self-test described at `notes/D_partialinfo.md:60-66` (determinant vs permutation
  on 200 matrices; det-preservation + Lovász on 20 lattices; 7 polynomial root tests;
  mod-`p^m` vanishing; end-to-end recovery).
- Two harness defects caught by the control, both written up at
  `notes/D_partialinfo.md:47-58` — misaligned leak (`X` inflated 64 bits) and the
  Howgrave-Graham `√dim` vs `dim` error. These match the census's "Two defects the control
  caught" verbatim.

⚠️ **The census's "Nothing tested beat ½" is weaker than its own note.** The note's §7
("`notes/D_partialinfo.md:196-224`, WHAT REMAINS UNMEASURED) lists **five** gaps: LSB not
swept to the bit; **no multivariate / Herrmann–May construction built**; multiplier-`u` not
implemented; BDF / Coron–Maynard not implemented; one `N`, 3 seeds. The census's summary
section does carry an "Honest limits" paragraph (SUMMARY:361-363) covering three of these —
good — but the census **table row** itself says "CLOSED — measured to the bit" with no
qualifier, and the row's own second clause "Nothing tested beat ½" is a claim about a space
the note says is largely untested. The censustable is the part a future round reads.

---

### R14. GNFS constant via BKZ past LLL — **CLOSED — provably nothing**
> **40/40 relation lattices give LLL/SVP = 1.0000000000 exactly.** The rows have near-disjoint small-prime supports, so they are nearly orthogonal *before* reduction — LLL is already optimal, so **no block size can buy anything**

**TRACABLE-TO-MEASUREMENT. The certified exact-SVP enumerator exists.** But two numbers in
this row are wrong.

✅ **Present and load-bearing:**
- `exp/exactsvp.py` (2.1 K) — the certified enumerator. `svp_box_radius()` derives a *sound*
  radius from the pseudo-inverse; `enumerate_svp()` **returns `None` rather than truncating**
  when the box exceeds `cap` (`exactsvp.py:37-41`). This is the property that makes "certified"
  true.
- `exp/run_c1_stats.py` — the headline driver. Line 30-33 calls `enumerate_svp(rows, cap=20_000_000)`,
  returns `None` → skipped; line 76-77 counts `# exactly 1.0` vs `# above 1.0`; line 66 prints
  "configurations attempted … with certified exact SVP".
- `notes/I_constant.md:92-103` — the printed result block (min/max/mean 1.0000000000, 40/40).
- Self-test `exp/lll_self_test.py` (17.8 K) with 10 certified properties at
  `notes/I_constant.md:22-37`, **including S4b, the anti-vacuity control**: "LLL is genuinely
  *not* always optimal, so S1 is not vacuous — strictly suboptimal in 1/60 cases, max LLL/SVP 1.0251".

🔴 **ERROR 1 — the mechanism sentence is contradicted by the note's own control.**
The census says "The rows have near-disjoint small-prime supports, so they are nearly
orthogonal *before* reduction — LLL is already optimal." But `notes/I_constant.md:26`
records that on the **self-test's** lattices "LLL/SVP ∈ [1.00000000, **1.14946164**]" and
S4b finds LLL strictly suboptimal in 1/60. Near-orthogonality is not a law; the note's own
controls show LLL *is* suboptimal on comparable lattices. The census states a mechanism as
though it were a theorem. (The C1 result itself — 40/40 on *NFS relation* lattices — is
measured and unaffected; the *explanation* is what overreaches.)

🔴 **ERROR 2 — the mechanism sentence is unsupported by any code, and there is a known
alternative explanation the note never excludes.** No script computes "near-disjoint small-prime
supports". `exp/nfs_lattice.py` builds the rows; nothing measures orthogonality or support
disjointness. Meanwhile `notes/I_constant.md:139-143` records a *bigger* structural fact the
census omits entirely:

> "Rows are the `h_i` coefficient vectors, i.e. the relation lattice **before** the Montgomery
> `N·F(x)^k` subtraction. I could not get that subtraction to produce m-divisible rows (measured
> **0 of 40** rows divisible by m), so the Montgomery normalisation is **not** included.
> **This is a real gap** and I flag it rather than claim the lattice is the fully normalised
> Montgomery lattice."

So the "provably nothing" applies to the **un-normalised** relation lattice. The census's
"**CLOSED — provably nothing**" does not carry that gap. SUMMARY:208 and SUMMARY:217-221
both present the result without it. `notes/I_constant.md:135-138` adds a second caveat the
census also drops: 7-dimensional, N of 32–55 bits, "the full 1024-bit relation lattice is not
constructible on this host".

---

## 2. The supply-audit section (SUMMARY 255-315)

Every one of Findings 1–4 traces. But the **provenance path is misattributed in the census**.

| Census claim | Evidence | Verdict |
|---|---|---|
| Control: `CEIL3b.log` → `1021/1753/2761/3566`, nulls `102/50/272/25`, `χ_P = −1 = 23.40%`, passes at **0.92σ** | `notes/S_supply.md:63-76`; script `r49/exp/supply/02_control_chip.py` | ✅ MEASUREMENT |
| Finding 1: `α = +0.794 ± 0.095` (OLS); inverse-variance `+0.991 ± 0.047`; true exponent `−0.96`/`−1.16` | `notes/S_supply.md:230-231`, `276`; `r49/exp/supply/05_fit_manyN.py`, `05_fit.json`, `05b_fit.log` | ✅ MEASUREMENT |
| Finding 2: pool composition **flat** `1.235/1.237/1.342` at 24/28/32 bits; all growth is `\|c\|` | `notes/S_supply.md:164-166`; `03_decomp.json` | ✅ MEASUREMENT |
| Finding 3: 28/32 semiprimes give ZERO relations; corrected **126× (24 bits), ~4400× (32 bits)** | `notes/S_supply.md:118`, `299`, `320`; `04_perN.py`/`04_perN.log` | ✅ MEASUREMENT |
| Finding 4: box `χ_P = −1 ≈ 79%` refuted; measured **0.001–0.02**; file's own counts give **14%** | `notes/S_supply.md:300`, `326` | ✅ MEASUREMENT |
| Published `cost ∝ N^0.534` UNAFFECTED (324 runs, 323 real factors) | asserted at `notes/S_supply.md:~291-305`; the underlying 0.534 is from `~/factor47/V4/` | ⚠️ INHERITED, not re-measured here |
| Three self-corrections (QR `t[0]=False`; 2-adic at `v₂=4`; `chiP` transcription slip caught at 0/9101) | `notes/S_supply.md:~20-30`, `88` | ✅ MEASUREMENT |

🔴 **PROVENANCE MISATTRIBUTION (structural, not a number).** The census presents the supply
audit as **round-48 work** — it is under "■ THE SUPPLY AUDIT — RESOLVED (this was the round's
biggest open worry)" and SUMMARY:255. But `notes/S_supply.md:3` says, verbatim:

> "**Round 49, supply axis.** Working files: `factor-scratch/r49/exp/supply/`."

All 8 scripts and 5 result files live in `factor-scratch/r49/exp/supply/`, **not** in
`factor-scratch/r48/exp/`. A reader auditing round 48 from `r48/` will find the note and
**none of its evidence**. The census's own FILES section (SUMMARY:537-541) lists
`factor-scratch/r48/notes/` — including `S_supply`? Let me be precise: the FILES list at
SUMMARY:537-541 does **not** name `S_supply` at all. So the note is doubly orphaned.

This matters beyond bookkeeping: it is the **exact failure mode the audit itself documents** —
a claim whose provenance is not discoverable from where it is filed. The census commits it
about itself.

---

## 3. The partial-information "31 WORKS / 32 FAILS" — does a script exist?

**Yes.** `exp/exp_boundary.py` is the lattice builder named at `notes/D_partialinfo.md:71`,
and `exp/control_final.py` produces the 3/3 · 2/2 · 3/3 control row at
`notes/D_partialinfo.md:36-38`. `exp/coppersmith.py` (12.3 K) is the underlying reduction.
`exp/exp_t1.py` / `exp_t2.py` / `exp_t3.py` produce the three "nothing below ½" sub-claims.
`exp/selftest.py` is the six-section self-test.

One caveat: **no run log exists for this axis.** Unlike the supply audit (`*.log` files) or
the E6c re-run (`e6c_recheck_results.json`, 799.6 K), `exp/` contains **no `.log` and no
`.json` for any partial-information result** — the only logs in `exp/` are for the G-axis
parity work, the E7 work, and the cost/H harnesses. The numbers live in the note prose. The
scripts are re-runnable (Coppersmith at dim 40–104 with fpylll is minutes), so this is a
**log-retention gap**, not an evidence gap. Worth closing because the census's own earned
rule #2 ("A self-test that only shows your code running is not a self-test") argues for
artefacts.

---

## 4. The LLL/SVP 40/40 claim — does the exact-SVP enumerator script exist?

**Yes, and it is the best-engineered artifact in the round.**

- `exp/exactsvp.py` (2.1 K) — certified, with the soundness argument for the box radius
  written out in the docstring (`exactsvp.py:7-16`), and a **refuse-rather-than-truncate**
  contract (`exactsvp.py:29-31`, `37-41`).
- `exp/lll_self_test.py` (17.8 K) — 10 certified properties including the anti-vacuity control.
- `exp/run_c1_stats.py` (3.3 K) — the headline driver, with `None`-skipping at line 31-32 and
  the honest "attempted vs certified" print at line 66.

The census's "119 configurations were attempted; the 40 that admitted a certified exact SVP
were used, and **the other 79 were discarded rather than silently approximated**"
(SUMMARY:225-226) is a direct match to `run_c1_stats.py:60-66`. That is honest reporting of
the discarded fraction and deserves credit.

**But** the census drops all three limitations the note attaches to the same result:
Montgomery normalisation absent (0/40 rows m-divisible); 7-dim and N of 32–55 bits, not
1024; and the fact that the "near-orthogonal rows" mechanism is *asserted*, not measured, and
is contradicted in general by the note's own S1/S4b controls. See §5, item 1.

---

## 5. Ranked list of the weakest rows — UNTRACEABLE or over-claimed

No census row is **fully** UNTRACEABLE: every one has *some* artifact behind it. The failure
mode here is subtler and arguably worse — **the reason column is stronger than the evidence
under it**. Ranked by how far the claim outruns its support:

### 1. 🔴 "GNFS constant via BKZ past LLL — CLOSED — provably nothing" — **OVER-CLAIMED, mechanism unmeasured, gap dropped**

The measurement is real and the script is real. But the census asserts a **mechanism** ("the
rows have near-disjoint small-prime supports, so they are nearly orthogonal *before*
reduction") that **no script measures** and that the note's own control contradicts in
general (`notes/I_constant.md:26`, LLL/SVP up to 1.149; S4b: suboptimal 1/60). It also drops
the note's own flagged **real gap** — the Montgomery normalisation is absent (0/40 rows
m-divisible, `notes/I_constant.md:139-143`) — and the size limit (7-dim, 32–55 bits,
`notes/I_constant.md:135-138`). "Provably nothing" is the strongest possible status word and
it is attached to a result whose own author wrote "This is a real gap and I flag it".

**Verdict: TRACABLE-TO-MEASUREMENT (result) / UNTRACEABLE (mechanism) / gap dropped.**

### 2. 🔴 "Function fields / tori / Jacobians — CLOSED (exactly)" — **OVER-CLAIMED on scope; heuristic step unmarked; one half of the asymmetry unread**

`notes/E_funcfield.md:358-361` calls the `D = u²−1` torus a **genuine factoring method**
(12/12 splits, 1.5× cheaper than ECM's ladder). "CLOSED (exactly)" says the opposite. The
`reach_p = L[1/2]` figure needs Lenstra's heuristic, which the note flags at lines 209-217
and the census does not. The number-field half of the field-vs-number-field asymmetry rests
on a paper the note's author **explicitly did not read** (Lenstra–Pomerance 1992, AMS 404),
and the note says "**The synthesis is mine.**" That sentence is precisely the provenance
warning the census exists to enforce, and the census did not carry it.

**Verdict: TRACABLE-TO-MEASUREMENT / scope OVER-CLAIMED / one load-bearing citation UNREAD.**

### 3. 🔴 Supply audit filed under round 48 but evidenced only in round 49 — **PROVENANCE ORPHANED**

Every number traces. But `notes/S_supply.md:3` says "Round 49", the evidence is 100% in
`factor-scratch/r49/exp/supply/`, and `S_supply` is **not listed** in the census's own FILES
section. A reader auditing round 48 from `r48/` finds the claim and none of its backing. The
audit that exists to catch unbacked claims is filed unbacked.

**Verdict: TRACABLE-TO-MEASUREMENT (all 4 findings + control) / PROVENANCE MISROUTED.**

### 4. 🟠 "Partial-information factoring — CLOSED — measured to the bit" — **table row omits the note's five unmeasured dimensions**

The measurement is genuine, the scripts exist, the control is real, and the two harness
defects are documented. But the census table says "CLOSED" with no qualifier, while
`notes/D_partialinfo.md:196-224` lists five unmeasured dimensions — including **no
multivariate / Herrmann–May construction built at all** and the multiplier-`u` case not
implemented. The prose section (SUMMARY:361-363) carries three of the caveats; the table,
which is what propagates, carries none. **Also: no run log or JSON for this axis at all.**

**Verdict: TRACABLE-TO-MEASUREMENT / census row drops the note's own §7 limitations.**

### 5. 🟠 "Cross-discipline sweep (7 fields) — CLOSED" — **sweep-level CLOSED over a field the note calls the round's only live lead**

`notes/H_crossdiscipline.md:317-319` calls field 6 (Jacobi graph) "**the round's only
genuinely live lead**" and says "I would bet against one" — i.e. **open**. Field 3 is an
*equivalence*. Marking the sweep "CLOSED" while the note marks its best field live is a
status inflation. The census does name the two fields separately (R10, R11), which
mitigates it, but "all fail one of the three requirements" is also not quite what the note's
table says: field 6 fails only the **computability** requirement and is described as "a
genuinely factor-revealing invariant that cannot be computed" (`H_crossdiscipline.md:10`).

**Verdict: TRACABLE-TO-MEASUREMENT + ARGUMENT per field / sweep-level CLOSED overstated.**

### 6. 🟠 "NFS smoothness uniformity — for odd `p`, `k ≥ 2`" — **ONE FALSE TOKEN: p=3**

`notes/C_smoothness.md:88` — "**p=3 is the sole exception** (1.667 vs 1+1/3): cubes mod 9 lie
only in {0, ±1}". The census says "odd `p`" without excluding 3. Everything else in this row
is exact, exhaustive, and hand-checked — which makes the omission more conspicuous, not less.
This is the row most likely to be quoted.

**Verdict: TRACABLE-TO-MEASUREMENT (exhaustive count) / one false quantifier.**

### 7. 🟡 "Rigorous `L[1/2]`" — 🟡 nothing wrong here; listed for contrast

Shoup Thm 15.6 at printed p. 413 (PDF p. 431), verbatim; p. 412 counting argument, verbatim;
Thm 15.1 at p. 399, verbatim; the `π(y)` discharge tabulated at 256–4096 bits; the PDF in
hand at `lit/r1/shoup_ntb.pdf`. **This is the standard every other row should meet, and four
rows do not.**

### 8. 🟡 "Class-group walk as `L[1/2]` — SQUOF at `N^{1/4}`, strictly weaker than ECM" — **the complexity comparison is Wikipedia-sourced and the note distrusts it**

`notes/A_classgroup.md:176` — "**No citation is offered for the SQUOF O(N^{1/4}) complexity
beyond the Wikipedia page**"; line 180 — a direct transcription of that page's SQUOF
**fails**. The identification (walk = SQUOF, 19/19 `a_k = p`) is measured and solid; the
*comparative claim* the census headlines is not.

---

## 6. INHERITED rows — "Unchanged from round 47. Nothing here disturbs them."

> **Unchanged from round 47:** NFS relation geometry, Harvey `N^{1/5}`, Umans–Wang, Lecerf
> bivariate, auxiliary information, classical-deterministic. Nothing here disturbs them.
> (SUMMARY:310-311)

**Finding: `Round47_SUMMARY.md` contains no census table.** It has seven sections
(§1 what round 47 established, §2 machine-checked, §3 retractions, §4 corrections, §5 the
auxiliary-information axis, §6 the frontier, §7 rules) and **no row-per-axis closure table
corresponding to the round-48 census**. Its only status table is §6 "the frontier", four rows,
which mentions none of these six axes except *auxiliary-information factoring* (row 3:
"open; the barrier is the lattice, not the threshold").

So the round-48 sentence "extends the round-47 census (`Round47_SUMMARY.md`)" (SUMMARY:4)
points at a document that does not contain a census. What *does* exist is
**`Round47_HandoverAddendum.md`**, which carries a 12-row status table over
`Round46_Handover.md`'s sections. Per-axis, for the six inherited items:

| Inherited axis | Where r47 actually records it | Stated reason? | Evidence? |
|---|---|---|---|
| **Harvey `N^{1/5}`** | `Round47_HandoverAddendum.md:14` — "§1.3 Deterministic 1/5 improves a dominated quantity — **STANDS.** Not re-litigated." | **NONE.** The row is a verdict with no reason. | `Round46_Handover.md:51-63` has the derivation (`F(N) = O(N^{1/5} log^{16/5}N)`, the dex table) and `Round47_PriceOfRigour.md:47` has "224.4 dex behind GNFS at 2048 bits". So the *reason exists one file back*. |
| **Umans–Wang** | `Round47_HandoverAddendum.md:15` — "§1.4 Umans–Wang mapped — **STANDS.**" | **NONE.** | `Round46_Handover.md:63-77` — the `det 1/5 vs det 1/6 (Umans–Wang) vs GNFS` table, and `τ(ρ) = max(1/4 − ρ/4, ρ)` minimised at `ρ = 1/5`. Reason exists at r46. |
| **Lecerf bivariate** | `Round47_HandoverAddendum.md:23` — "§8–9 Deterministic 1/6; Lecerf 5.1 — **STAND.**" | **NONE.** | Only in `Round46_Handover.md`. **The string "bivariate" appears in NO `Round4*.md` file** (grep over `Catalog/Cryptography/FactoringBarriers/`) — it is a paraphrase introduced by the round-48 census. |
| **auxiliary information** | `Round47_SUMMARY.md:162` — §6 frontier row 3: "**open**; the barrier is the lattice, not the threshold" | **YES, and it is a reason** | `Round47_SUMMARY.md:142-153` — Herrmann–May ASIACRYPT 2008 p. 3, "the `1/4` is not a quarter of the bits", "no matter how the size of the unknowns are distributed", lattice dimension "grows exponentially in `n`", Assumption 1 "did not hold in general". → `Round47_AuxiliaryInformation.md`. **The one inherited row with a real reason and citation.** |
| **classical-deterministic** | **Nowhere.** The string does not occur in any `Round4*.md` file. | **NONE.** | **UNTRACEABLE.** This is a phrase that exists in the round-48 census and in no round-47 document at all. |
| **NFS relation geometry** | `Round47_DimensionalClosure.md` (§1.2 of `Round47_SUMMARY.md:30`) — genus 1 at d=3, 5 at d=4, 17, 49 | **YES** | `Round47_SUMMARY.md:34-39` table; machine-checked in `DimensionalClosure.lean` (`Round47_SUMMARY.md:82`). **Strong.** |

**Verdict on the inherited block: the assertion "Nothing here disturbs them" is itself
unbacked, and 2 of the 6 named items are not traceable to round 47 at all.**

Specifically:
- **`classical-deterministic` — UNTRACEABLE.** The phrase appears in no `Round4*.md` file in
  the Catalog. It cannot be checked, disturbed, or inherited, because there is nothing to
  inherit.
- **`Lecerf bivariate` — the word "bivariate" is a round-48 invention.** The r47 record says
  "Lecerf 5.1". Whether the paraphrase is faithful is unverifiable from the corpus.
- **The other four point at `Round47_HandoverAddendum.md`, not at `Round47_SUMMARY.md`** — so
  the census's own header citation (SUMMARY:4) is wrong about where the inherited state lives.
- **"Nothing here disturbs them" is an assertion, not a check.** Round 48's supply audit is
  the one piece of work that could have disturbed the NFS relation-geometry claim (it audits
  the *supply* of relations) and its conclusion was that the *rate* exponent was mis-stated.
  Whether that touches geometry was evidently not examined. One line of argument, or the
  admission that it was not checked, was required. Neither appears.

---

## 7. Non-census CLOSED claims elsewhere in SUMMARY

| Location | Claim | Verdict |
|---|---|---|
| SUMMARY:198 / :39-52 | Rigorous `L[1/2]` already known (Shoup Thm 15.6) | ✅ CITATION — `notes/F_rigorous.md:319-358`, `lit/r1/shoup_ntb.pdf` |
| SUMMARY:199 / :54-62 | "Structure with order computable without `p`" CLOSED (structural) — 0/890, `L<8.6` | ✅ MEASUREMENT + ARGUMENT — `notes/F_rigorous.md:427,444` |
| SUMMARY:196-199 census + §THE RETRACTION | Class-group lottery closed ×3 | ✅ MEASUREMENT — see R2 |
| SUMMARY:110-122 | `Cl(O_D) mod p` trivial; walk = SQUOF | ✅ ARGUMENT, ⚠️ complexity citation weak (see §5.8) |
| SUMMARY:103-105 | "**no `.py` was ever committed** for E-6b/6c/7" | ✅ FORENSIC — corroborated by the absence of any `exp/e6b*.py` / `exp/e6c*.py` / `exp/e7*.py` at the `r48/exp/` root. Honest negative, correctly reported. |
| SUMMARY:186-188, :298-302 | The 47×/326× correction; 0.534 unaffected; supply dead at 128 bits **SURVIVES** | ✅ MEASUREMENT (`r49/exp/supply/`), ⚠️ **misrouted from r48** (see §5.3) |
| SUMMARY:366-413 | E-6c re-run: 0.0624 vs 0.720, 112 cells, parity | ✅ MEASUREMENT — `notes/O_e6c_recheck.md:16-19,152-158,209`; raw `exp/e6c_recheck/e6c_recheck_results.json` (799.6 K) |
| SUMMARY:438-495 | Non-EC group survey: +0.0499 (+3.4σ), parity removes half of +0.0966 | ✅ MEASUREMENT — `notes/B_groups.md:68,181-184,202` |
| SUMMARY:499-515 | PARI `ellcard` wrong on composite, 0/6 | ✅ MEASUREMENT — `notes/T_pari_ellcard_hazard.md`; `exp/H_f3c_pari_trust.py` |
| SUMMARY:146-171 | 16 phantoms / 8 defective citations | ✅ CITATION-INTENSIVE — `notes/A3_phantoms.md` (33.8 K), `notes/P_citation_propagation.md`, cross-checked against `lit/EC_FACTORING.md` |

---

## 8. Bottom line

**No row of the census is wholly UNTRACEABLE.** Every axis has a note, and almost every
number has a script. That is a better record than most programs of this kind manage, and the
self-audit sections (`A_classgroup.md:176`, `E_funcfield.md:209-237`, `I_constant.md:133-143`,
`D_partialinfo.md:196-224`, `X_verify_20_over_27.md`) are unusually candid.

The failure is **not** absence. It is that **the census is a lossy summary of notes that
disagreed with it, and the losses are all in the direction of more certainty.**

The four concrete defects, ranked:

1. **R14 (LLL/BKZ)** — an unmeasured mechanism stated as fact, contradicted by the note's own
   control, with the note's own flagged "real gap" (Montgomery normalisation absent) dropped,
   under the strongest status word in the table ("provably nothing").
2. **R6 (function fields)** — "CLOSED (exactly)" over a note that reports a working method in
   the same family; `reach_p = L[1/2]` unmarked as heuristic-loaded; one half of the
   asymmetry resting on a paper the author did not read, with the note's own "the synthesis
   is mine" dropped.
3. **Supply audit** — the round's biggest open worry, resolved, and filed where none of its
   evidence is. The audit that exists to catch unbacked claims is itself unbacked at its
   stated location.
4. **Inherited block** — "Nothing here disturbs them" is asserted; `classical-deterministic`
   exists in no round-47 document; `Lecerf bivariate` is a round-48 paraphrase of
   "Lecerf 5.1"; and the census cites `Round47_SUMMARY.md` for a census that is not there
   (it is in `Round47_HandoverAddendum.md`).

Plus one plain factual error, cheap to fix and expensive to propagate:
**`P(p^k | a²−b³) = (2p−1)/p^k` holds for odd `p ≠ 3`, not odd `p`** — p=3 is a measured
exception (cubes mod 9 lie in {0, ±1}) at `notes/C_smoothness.md:88`.

**Recommendation.** The notes are the stronger artifact and should be treated as the record;
the census table is a derived view and currently over-states four rows. In particular,
R14's status should read **"CLOSED at the sizes measured, on the un-normalised relation
lattice"**, not "provably nothing".

---

*Absence of a file is reported as a finding. Four delivered papers
(`Papers/the_baseline_that_was_not.md` #521, `Papers/the_smoothness_wall_is_a_subgroup_wall.md`
#522, `Papers/a_square_minus_a_cube_divides_twice.md` #523,
`Papers/stange_works_and_its_analysis_does_not.md` #524) are cited by SUMMARY:30-35 but
**do not exist** anywhere in the repository — no file, no git history, and
`Catalog/Cryptography/FactoringBarriers/Papers/` does not exist. The issues #521–524 do
exist and are OPEN (verified via `gh issue list`). The census cites four artifacts that
cannot be read.*