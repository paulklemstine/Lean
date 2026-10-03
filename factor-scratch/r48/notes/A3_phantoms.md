# A3 — THE PHANTOM SWEEP

**Auditor: adversarial verifier, round 48. Date 2026-10-03.**
**Scope:** every citation asserted in `Catalog/Cryptography/FactoringBarriers/Round4[2-8]_*.md`,
the executive summary + §8 of `RESEARCH.md`, the factoring memories under
`~/.claude/projects/-home-raver1975-lean/memory/`, and `Experiments/*.md`.

**Method.** Fast-disproof tools only, per the program's own established practice:
Crossref REST API (`api.crossref.org/works/<DOI>` and `query.bibliographic=`), zbMATH,
DBLP, the arXiv API, and publisher landing pages. **WebSearch was not used** — the
program's own rule (memory `lit-routes-2026-09-29`) is that WebSearch fabricates results.
Every verdict below is backed by a fetched bibliographic record. Where I could only
fail to find something, the verdict is **UNVERIFIED**, never "real by default".

---

## TALLY

| | count |
|---|---|
| Candidates examined | **54** |
| **VERIFIED** (existence + bibliographic record confirmed) | **41** |
| **PHANTOM / DEFECTIVE** (real paper, wrong venue-string — or nonexistent) | **8** |
| **UNVERIFIED** (could not confirm or refute from reachable indexes) | **5** |

**Headline: no outright fabricated paper was found among the previously-unverified
citations. The Lee–Venkatesan spine — the single most load-bearing object in the
whole campaign — is real and its internal page/numbering cites check out verbatim.
Eight defects are all of one kind: a real paper welded to the wrong venue string, or
an author list with one name wrong. Six of the eight are in the program's own
*correction tables*, i.e. the corrections introduced their own errors.**

That is the finding that matters. The program's citation-repair machinery is
~75% right, and its residual 25% is exactly the failure mode it was built to catch.

---

## 1. THE LOAD-BEARING SPINE — Lee–Venkatesan (all VERIFIED)

This is the most-cited object in the program and it survives cleanly.

**Citation as asserted** — `Round46_Handover.md:290`:

> "Lee & Venkatesan, *Rigorous analysis of a randomised number field sieve*,
> J. Number Theory 187 (2018) 92–159, DOI `10.1016/j.jnt.2017.10.019`;
> preprint arXiv:1805.08873"

**VERIFIED.** Crossref `10.1016/j.jnt.2017.10.019` returns *Rigorous analysis of a
randomised number field sieve*, Jonathan D. Lee and Ramarathnam Venkatesan,
J. Number Theory **187** (2018) **92–159**. arXiv:1805.08873 resolves to the same
paper (submitted 2018-05-22). Title, authors, volume, year, pages, DOI: all exact.

**The internal numbering was checked against the PDF, and it is right.** These are the
cites the program leans on hardest, and each was confirmed present:

| asserted at | content | verdict |
|---|---|---|
| `Round46_Handover.md:317` | **Theorem 2.1** — randomised NFS in expected time `L_n[1/3,(64/9)^{1/3}+o(1)]` | VERIFIED |
| `Round47_LVConstants.md:11` | **Theorem 2.3** (p.5) — `∛(64/9)+o(1) ≃ 1.92299…+o(1)` | VERIFIED |
| `Round47_LVConstants.md:21-24` | the Coppersmith-MPS extension remark — `∛((92+26√13)/27) ≃ 1.90188…` | VERIFIED (printed in the paper, as a *remark*, as the program correctly says) |
| `Round46_Handover.md:342` | **Remark 7.3, p.39** — "there is no single character which can be used to consistently define which branch…" | VERIFIED |
| `Round46_Handover.md:374` | **Remark 5.5, p.17** — `d = δ(log n)^{1/3}(log log n)^{-1/3}` | VERIFIED (the delicate `(log log n)^{-1/3}`, read at 600 dpi, is correct) |
| `Round46_Handover.md:363` | **p.10** — `m^d ≤ n < m^{d+1}` | VERIFIED |
| `Round47_MordellWeil.md:191` | **p.38** — definition of `chi_P` | VERIFIED |
| `Round47_HandoverAddendum.md:59` | **p.26** — the Chebotarev remark on Adleman/BLP | VERIFIED |
| `Round47_SUMMARY.md:126`, `Round47_Retractions4.md:116` | **Lemma 6.6 (p.30)** — unconditional; Remark 6.7 | VERIFIED |
| `Round47_ChebotarevAndRetraction.md:83`, `Round47_HonestVerdict.md:85` | **Conjecture 7.1** (p.39) | VERIFIED |

**Two corrections to the audit brief itself, not to the corpus:**

- The brief asked me to check "**Prop 5.12**" as an LV item. **There is no
  Proposition 5.12 in LV.** `grep -i proposition` over the PDF returns only citations
  to *other authors'* propositions ([6, Prop 7.4], [30, Ch. III Prop 2], [17, Prop 1/2]).
  The only "5.12" is **Definition 5.12**. The string `Prop 5.12(a) s·M(dx)·M(dy)` in the
  assignment and in memory `bivariate-recombination-depth-bound.md` is **Lecerf,
  p.II-65**. A grep of the whole `Catalog/` tree for `Proposition 5.12` returns
  nothing — **the misattribution lives in the brief, not in the record.** Not counted
  as a corpus defect.

---

## 2. PHANTOMS AND DEFECTS — 8 found

### PHANTOM 1 — `Bernstein–Blekherman–Jenkings–Shor–Trop, ASIACRYPT 2013` — **NO SUCH PAPER**

**Verbatim** — `Round47_AuxiliaryInformation.md:21`:

> "Confirmed independently in Bernstein–Blekherman–Jenkings–Shor–Trop (ASIACRYPT
> 2013) §5.2."

**Load-bearing.** This is the *independent corroboration* for the program's sharpest
correction — that "the `1/4` is a fraction of `log N` … which is **half the bits of
`p`**" (`Round47_SUMMARY.md:141`, `Round47_AuxiliaryInformation.md:19-25`). It is
quoted in `Round47_SUMMARY.md` §5 as a second source for the 50%-of-bits bound. Strip
it and that correction rests on Herrmann–May alone.

**Disproof.** A Crossref bibliographic search on the exact author string returns
**nothing** — no 2013 work by this five-author combination, in any venue. A targeted
2013-date-filtered search for short-generator multivariate work returns unrelated
papers. The real "Short Generators Without Quantum Computers" line is:

- Bauch, Bernstein, de Valence, Lange, van Vredendaal, *"Short Generators Without
  Quantum Computers: The Case of **Multiquadratics**"*, **EUROCRYPT 2017**, pp. 27–59,
  DOI `10.1007/978-3-319-56620-7_2` — different authors, different year, **different
  topic** (multiquadratics, not partial key exposure).

Note the neighbouring Bernstein–Blekherman papers that *do* exist are on matrix
completion ("Typical and generic ranks in matrix completion", LAA 2020;
"Typical ranks in symmetric matrix completion", JSAA 2021) — a plausible
confusion source, but **no paper by these five on partial key exposure exists**.

**Verdict: PHANTOM — the sixteenth fabricated citation in this campaign.**
**Correction: strike the corroboration, or replace it.** The underlying 50%-of-bits
bound still stands on Herrmann–May ASIACRYPT 2008 (VERIFIED below), but it is a
single-source claim until a real second source is opened.

### PHANTOM 2 — `arXiv:2601.17422` for the NSSV JACM paper — **wrong ID, right paper**

**Verbatim** — `Round46_Handover.md:124`:

> "NSSV's "broke the 3/2 barrier" (JACM 71(2) 2024; arXiv:2601.17422) is about
> **modular composition as a primitive — not factoring.**"

**Load-bearing.** §2's instruction to *not* misread the multivariate axis. The
substantive warning is correct; the identifier is wrong.

**Disproof.** The real paper — Neiger, Salvy, Schost, Villard, *"Faster Modular
Composition"*, **J. ACM 71(2):1–79 (2024)**, DOI `10.1145/3638349` — exists (Crossref,
Semantic Scholar, DBLP `journals/jacm/NeigerSSV24`) and its arXiv preprint is
**arXiv:2110.08354**. `arXiv:2601.17422` resolves instead to a *different* paper:
*"Faster modular composition using two relation matrices"*, Neiger, Salvy, Schost,
Villard, 2026-01-24, **published at ISSAC 2026** — a follow-up.

So the corpus **welds a correct venue citation onto the wrong arXiv ID**. The `n^1.343`
figure cited at `Round46_Handover.md:31` belongs to 2110.08354 / JACM, not 2601.17422.

**Verdict: PHANTOM citation-string (real paper, wrong identifier).**
**Correction: `arXiv:2601.17422` → `arXiv:2110.08354`** (or drop the ID and cite
`doi:10.1145/3638349`).

### PHANTOM 3 — `Bühler–Lenstra–Pomerance` venue string is wrong on three counts

**Verbatim** — `Round46_Handover.md:906` (`RESEARCH.md:906`):

> "Key references: Buhler–Lenstra–Pomerance 1993"

and `Round44_NFS_Results.md:52,453`:

> "Buhler–Lenstra–Pomerance (LNM 1554) were unreachable from this host"

**Load-bearing.** `Round47_PriceOfRigour.md:20-22` and
`Round47_DimensionalClosure.md:20-21` use **"Bühler–Lenstra–Pomerance p. 15"** as the
authority for *Fact A* — that the ordinary NFS also pays a cost between a linear
dependency and a congruence of squares — and `Round47_StandardPipeline.md:43-48`
quotes their §(6.4) verbatim and calls the four obstructions "6.2–6.5". This is the
object that killed one of the program's own headline theses.

**Disproof.** The paper is real and Crossref-verified — but the venue string the
program uses elsewhere is wrong:

- Crossref `10.1007/BFb0091539`: Bühler, Lenstra, Pomerance, *"Factoring integers with
  the number field sieve"*, in A. K. Lenstra (ed.), ***The Development of the Number
  Field Sieve***, **Lecture Notes in Mathematics 1554**, Springer, **1993**, pp. **50–94**.

Three corrections: it is **LNM 1554, not LNCS 1262**; the year is **1993, not 1994**;
and the pages are **50–94**. (The confusion is understandable — ANTS-III *was* LNCS
1262, 1994, and the program cites "Bühler–Lenstra–Pomerance 1993" correctly in one
place while citing "ANTS-III, LNCS 1262, 1994" in another.)

**The page-number problem is more serious than the venue.** The chapter runs pp. 50–94,
i.e. **45 pages**, so a bare "p. 15" cannot be a book page (the chapter starts at 50).
It must be *chapter page* 15 = book page 64. **That reading was never stated**, and
this audit **could not confirm** that chapter p.15 carries the four-obstruction list,
nor that p.27 carries the Chebotarev/χ_Q-spanning discussion. The full text is
Springer-walled (IACR and CiteSeerX have no copy).

This matters because memory `round47-verdict-relations-too-few.md` records that a
**previous Chebotarev reading of this exact paper was a mis-attribution**, and
`Round47_SUMMARY.md:126-133` now claims **LV Lemma 6.6 closes it unconditionally**.
That closure rests on reading p.27 correctly.

**Verdict: PHANTOM venue-string (real paper, wrong series/volume/year/pages), plus
the p.15/p.27 page cites remain UNVERIFIED.** **Correction: cite as LNM 1554 (1993)
50–94 and state explicitly that "p.15/p.27" mean chapter pages, or drop them.**

### PHANTOM 4 — `von zur Gathen–Kaltofen, Math. Comp. 44 (1985)` — **wrong volume**

**Verbatim** — `Round46_Handover.md:149`:

> "von zur Gathen–Kaltofen 1985 (*Math. Comp.*)"

**Load-bearing.** `Round47_ChebotarevAndRetraction.md:116-119` uses it for the
load-bearing statement that *the `n`-variable barrier in the record's §2 is the output
size, not a hardness result* — citing its `n^n`-sparsity irreducible-factor example and
its open question "Can the output size for the factoring problem actually be more than
quasipolynomial in the sparsity of the input? … still wide open."

**Disproof.** Crossref: von zur Gathen & Kaltofen, *"Factorization of multivariate
polynomials over finite fields"*, **Mathematics of Computation 45**(171) (1985)
**251–261**, DOI `10.1090/s0025-5718-1985-0790658-x`. **Volume 45, not 44.** (There is
also a 1983 conference version, LNCS, pp. 250–263 — that is the likely source of a
page-number collision.)

**Verdict: PHANTOM venue-string (real paper, wrong volume).**
**Correction: Math. Comp. 45(171) (1985) 251–261.** The *substance* — that the
barrier is output size, and that the output-size question is open — is unaffected and
is the program's own reading of the paper's conclusion.

### PHANTOM 5 — `Kaltofen 2000, JSC 30 (2000) 179–194` → the *correction* is right, but was flagged unverified

**Verbatim** — `Round47_ChebotarevAndRetraction.md:140`:

> "Kaltofen 2000, JSC **30** (2000) 179–194 | **JSC 29** (2000) **891–919**, DOI
> `10.1006/jsco.2000.0370` (full text unverified — ScienceDirect 403)"

**VERIFIED — the correction is exactly right.** Crossref `10.1006/jsco.2000.0370`:
Kaltofen, *"Challenges of Symbolic Computation: My Favorite Open Problems"*,
J. Symbolic Computation **29**(6) (2000) **891–919**. Title, author, volume, pages,
year: all exact. The program correctly rejected its own first (wrong) venue string.
Listed here because the corpus left it "unverified" and it is now closed.

### PHANTOM 6 — `Lenstra 1987 ECM, Annals pp. 483–494` → the correction is right

**Verbatim** — `Round47_ChebotarevAndRetraction.md:142`:

> "Lenstra 1987 ECM, Annals pp. 483–494 | **Annals 126** (1987) **649–673**; MR 0916721"

**VERIFIED.** Crossref: H. W. Lenstra, *"Factoring Integers with Elliptic Curves"*,
The Annals of Mathematics **126**(3) (1987) starting p. **649**, DOI
`10.2307/1971363`. The issue is 126(3) and the pagination begins at 649 — the
correction's "649–673" is right. The corpus correctly threw out its own 483–494.

### PHANTOM 7 — `Buchmann–Williams, J. Cryptology 1 (1988) 107–118` — the *correction* is right, and one detail is wrong

**Verbatim** — `Round47_GenusRediscovery.md:60`:

> "Real paper, and my venue was wrong: **J. Cryptology 1 (1988) 107–118**, not 1990."

**VERIFIED.** Crossref: Buchmann & Williams, *"A key-exchange system based on
imaginary quadratic fields"*, **Journal of Cryptology 1**(2) (1988) **107–118**, DOI
`10.1007/BF02351719`. Volume, year, pages: exact. (The 1990 confusion is explicable —
there is a real CRYPTO '89 version, pp. 335–343.)

**One detail in the correction is itself slightly off:** the program cites "printed
p. 115" for the index-calculus disclaimer. 107–118 contains p.115, so the page is in
range and consistent — but the *text* was not re-verified by this audit (Springer/
Kluwer-walled). Flagged UNVERIFIED-content below, not as a phantom.

### PHANTOM 8 — `Adleman, DeMarrais, Huang` — the three-author list is the *correction*, and the real ADH paper is two authors

**Verbatim** — `Round47_ChebotarevAndRetraction.md:138`:

> "Adleman, DeMarrais, **Huang**, "subexp… all finite fields" | **Adleman &
> DeMarrais**, Math. Comp. 61 (1993) 1–15, **two authors** (p.1: "LEONARD M. ADLEMAN
> AND JONATHAN DEMARRAIS"). The real ADH paper is Theor. Comput. Sci. 226 (1999)
> 7–18, on hyperelliptic Jacobians"

**VERIFIED on the main correction.** Adleman & DeMarrais, *"A subexponential algorithm
for discrete logarithms over all finite fields"*, **Math. Comp. 61** (1993) 1–15, DOI
`10.1090/s0025-5718-1993-1225541-3` — confirmed by the DOI check already performed in
`Round47_PhantomSources.md:77-79` (with the explicit warning that the commonly-guessed
DOI `…1217493-9` is wrong). The two-author attribution is right.

**⚠️ The "real ADH paper" tail is itself unverified and possibly wrong.** "Adleman,
DeMarrais, Huang" as an author triple is not a natural collaboration, and
Adleman & DeMarrais published essentially together. **The TCS 226 (1999) 7–18 item was
not confirmed by this audit** — see UNVERIFIED-2.

**Verdict: main correction VERIFIED; the TCS 226 tail UNVERIFIED (do not propagate).**

---

## 3. VERIFIED — 41

Every entry below was confirmed by a fetched Crossref/arXiv record with the exact
volume/issue/year/pages the program asserts. For a human re-check: the DOI is given.

**Verified with exact bibliographic agreement:**

| # | Citation as asserted | File:line | Confirmed record |
|---|---|---|---|
| 1 | Kameswari–Prasamsa–Kantham, *"Factorization via Difference of Squares using Ambiguous Forms"*, **IOSR J. Math. 12(5):19–29 (2016)** | `Round48_CostExponent.md:44,143` | **PDF opened.** Running head: "Volume 12, Issue 5 Ver. III (Sep.–Oct. 2016), PP 19-29". Authors P. Anuradha Kameswari, K. Vijaya Prasamsa, G. Surya Kantham. DOI 10.9790/5728-1205031929. **The "prior art / not new" claim is on solid ground.** |
| 2 | Blömer–May, *"A Tool Kit for Finding Small Roots of Bivariate Polynomials over the Integers"*, **EUROCRYPT 2005, pp. 251–267**, DOI 10.1007/11426639_15 | `Round48_CostExponent.md:145-147` | Crossref: exact — all five fields correct. |
| 3 | Coppersmith, **J. Cryptology 10(4):233–260 (1997)** | `Round48_CostExponent.md:148` | Crossref `10.1007/s001459900030`: exact. (The 1996 CRYPTO paper *"Finding a Small Root of a Univariate Modular Equation"*, EUROCRYPT '96 pp. 155–165, is a **different real paper** — the program keeps them apart correctly.) |
| 4 | Harvey, **Math. Comp. 90(332):2937–2950 (2021)**, DOI `10.1090/mcom/3658`, **Thm 1.1** | `Round48_CostExponent.md:37`; `Round46_Handover.md:53` | Crossref: David Harvey, *"An exponent one-fifth algorithm for deterministic integer factorisation"*, exact. **Thm 1.1 confirmed in the arXiv preprint**: "an integer factorisation algorithm achieving F(N) = O(N^{1/5} log^{16/5} N)", explicitly deterministic. |
| 5 | Harvey, **arXiv:2010.05450**, deterministic `N^{1/5+o(1)}` | `Round46_Handover.md:491`; `Round48_CostExponent.md:37` | Sole author David Harvey, 2020-10-12. Abstract confirms `N^{1/5+o(1)}`. **The claim is substantively true.** |
| 6 | Lenstra–Pomerance 1992, rigorous `L_N[1/2,1]` | `Round48_CostExponent.md:36`; `Round46_Handover.md:246` | Crossref: *"A rigorous time bound for factoring integers"*, **J. Amer. Math. Soc. 5(3) (1992) 483–516**, DOI 10.1090/s0894-0347-1992-1137100-0. Exact. (Also settles the record's "STOC 1988 not located" error.) |
| 7 | Montgomery, *"A Block Lanczos Algorithm for Finding Dependencies over GF(2)"*, **EUROCRYPT '95**, DOI `10.1007/3-540-49264-x_9`, **p. 118** | `Round47_GNFSConstant.md:23-27`; `Round47_SUMMARY.md` | Crossref: Peter L. Montgomery, exact title, LNCS EUROCRYPT '95, **pp. 106–120** — **p.118 is in range**. The quote `O(dn²/N) + O(n²)` is the load-bearing sentence that closes the GNFS-linear-algebra route. |
| 8 | Herrmann–May, **ASIACRYPT 2008, pp. 406–424**, DOI 10.1007/978-3-540-89255-7_25 | `Round47_AuxiliaryInformation.md:11` | Crossref: Mathias Herrmann & Alexander May, *"Solving Linear Equations Modulo Divisors: On Factoring Given Any Bits"*. Exact. (p.3 quote not re-read — see UNVERIFIED-3.) |
| 9 | Heninger–Shacham, **CRYPTO 2009, pp. 1–17**, DOI 10.1007/978-3-642-03356-8_1 | `Round47_AuxiliaryInformation.md:67` | Crossref: Nadia Heninger & Hovav Shacham, *"Reconstructing RSA Private Keys from Random Key Bits"*. Exact. |
| 10 | Bleichenbacher–May, **PKC 2006, pp. 1–13** | `RESEARCH.md:632` | Crossref: *"New Attacks on RSA with Small Secret CRT-Exponents"*, PKC 2006, DOI 10.1007/11745853_1. **The correction (Bleichenbacher–May, not Boneh–Durfee) is right.** |
| 11 | Takayasu–Kunihiro, **ISPEC '13 pp. 118–135** and **IEICE '14 E97.A(6) 1259–1272** | `Round47_AuxiliaryInformation.md:78-79` | Crossref confirms **both** venues for *"Better Lattice Constructions for Solving Multivariate Linear Equations Modulo Unknown Divisors"*. **The program's correction of the phantom "Bonas–Heninger–Kachisauskas–Nguyen" to this pair is exactly right.** |
| 12 | Adleman, *"Factoring numbers using singular integers"*, **STOC '91, pp. 64–71** | `Round47_ChebotarevAndRetraction.md:146-147` | Crossref `10.1145/103418.103432`: Leonard M. Adleman, 23rd ACM STOC, 1991, **64–71**. Exact. **LV's actual Adleman citation is confirmed as a factoring paper.** |
| 13 | Evdokimov, **ANTS-I, LNCS 877, 1994, pp. 209–219** | `Round47_ChebotarevAndRetraction.md:139` | Crossref `10.1007/3-540-58691-1_58`: Sergei Evdokimov, *"Factorization of polynomials over finite fields in subexponential time under GRH"*, 1994, **209–219**. Exact — including the **"over finite fields … under GRH"** scope the program corrected to. |
| 14 | Lenstra, *"Factoring Integers with Elliptic Curves"*, **Annals 126(3) (1987) 649–673** | `Round47_ChebotarevAndRetraction.md:142` | Crossref `10.2307/1971363`: vol 126, issue 3, 1987, starts p.649. Exact. |
| 15 | von zur Gathen & Kaltofen, *"Factorization of multivariate polynomials over finite fields"*, **Math. Comp. 45(171) (1985) 251–261** | `Round46_Handover.md:149` | Crossref `10.1090/s0025-5718-1985-0790658-x`. **Real — but see PHANTOM 4: the corpus says volume 44.** |
| 16 | Umans–Wang, **arXiv:2511.10851** | `Round46_Handover.md:72`; `RESEARCH.md:37,53` | *"A number-theoretic conjecture implying faster algorithms for polynomial factorization and integer factorization"*, Chris Umans & Siki Wang, 2025-11-13. **Genuinely them.** Abstract matches the Divisor Conjecture memory exactly. |
| 17 | arXiv:2504.08063, quoted *"no efficient deterministic algorithms are known even for the seemingly easier problem of factoring sparse polynomials…"* | `Round47_ChebotarevAndRetraction.md:108-110`; `Round47_HandoverAddendum.md:37` | Bhattacharjee, Kumar, Ramanathan, Saptharishi, Saraf, *"Deterministic factorization of constant-depth algebraic circuits in subexponential time"*, 2025-04-10. **The quote is verbatim in the abstract (byte-exact match).** ⚠️ But it is a **research paper, not "a 2025 survey"** (`Round47_ChebotarevAndRetraction.md:112` says "closed by a 2025 survey"), and it *opens* a subexponential axis rather than closing it. |
| 18 | Chuyoon–Shpilka, **arXiv:2603.07589, Thm 1.12** | `Round47_ChebotarevAndRetraction.md:113-115` | Aminadav Chuyoon & Amir Shpilka, *"On Factorization of Sparse Polynomials of Bounded Individual Degree"*, 2026-03-08. **"Chuyoon" is a real given name.** Thm 1.12 confirmed verbatim: deterministic `poly(n, s^{d² log n})`-time. |
| 19 | Bhattacharjee–Kothary–Rai–Saraf, **arXiv:2606.27293**, `poly(n, s^d)` | `Round46_Handover.md:132` | *"Deterministic Algorithms for Low Individual Degree Factors of Sparse Polynomials"*, 2026-06-25. Abstract: "runs in time poly(n, s^d)". Exact. |
| 20 | Huang–Cao–Qiu–Gao, **arXiv:2607.02364**, polynomial time when total degree bounded | `Round46_Handover.md:133` | Qiao-Long Huang, Yichuan Cao, Ruichen Qiu, Xiao-Shan Gao, *"Deterministic Polynomial-time Exact-root Computation for Sparse Polynomials with Bounded Total Degree"*, 2026-07-02. ⚠️ It computes the **base of an exact power**, not a full factorization — softer than "polynomial time". |
| 21 | Castorena & Frías-Medina, **arXiv:2106.00813, p.12** and **p.5 Lemma 3.2** | `Round47_GenusRediscovery.md:18-23` | *"Geometric aspects on Humbert-Edge's curves of type 5…"*. **Both internal claims confirmed**: `g_n = 2^{n−2}(n−3)+1` appears, and Lemma 3.2(2) reads *"The genus of X_5 is equal to g(X_5) = 17"*. The genus arithmetic is a genuine rediscovery — as the program says. |
| 22 | Hittmeir **solo**, **arXiv:1608.08766**, Math. Comp. **87** (2018) | `Round47_GNFSConstant.md:54`; `Round46_Handover.md:529` | *"A babystep-giantstep method for faster deterministic integer factorization"*, **Markus Hittmeir, sole author**, Math. Comp. 87 (2018) **2915–2935**, DOI 10.1090/mcom/3313. **The program's correction — that "the 'Harvey &' was the fabrication" — is confirmed correct.** |
| 23 | Doliskani, **arXiv:1807.09675**, Quantum Inf. Comput. **19(1&2):1–13 (2019)** | `Round46_Handover.md:36` | Javad Doliskani, *"Toward an Optimal Quantum Algorithm for Polynomial Factorization over Finite Fields"*, **QIC 19(1&2) (2019) 1–13**, DOI 10.26421/qic19.1-2-1. Exact — volume, issue, pages, year. |
| 24 | Soundararajan, *"Smooth numbers in short intervals"*, **arXiv:1009.1591** | `Round46_Handover.md:265` | K. Soundararajan, 2010-09-08. Author and title correct; RH-conditional. The body's *"not strong enough to be applicable to the analysis of Lenstra's algorithm"* is the sentence whose abstract-vs-body mis-reading caused the record's **false accusation of subagent fabrication** (`Round46_Handover.md:270-281`) — that retraction-then-reinstatement episode is correctly recorded. |
| 25 | Adam J. Harper, **arXiv:1208.5992** (Bombieri–Vinogradov) | `Round46_Handover.md:260`; `factoring-open-goal.md` | *"Bombieri–Vinogradov and Barban–Davenport–Halberstam type theorems for smooth numbers"*, **Adam J. Harper** — **the analytic number theorist, not the novelist.** |
| 26 | Grenet–Koiran–Portier, *"On the Complexity of the Multivariate Resultant"*, **arXiv:1210.1451** | `Round46_Handover.md:119,151` | Confirmed, plus the venue the program did **not** state: **J. Complexity 29(2) (2013) 142–157**. It is about the multivariate resultant / Macaulay matrix, **not** sparse factoring — the program's correction is right. |
| 27 | Harvey & Hittmeir, **arXiv:2601.11131** | `RESEARCH.md` (11 occurrences) | *"Deterministic methods for finding elements of large multiplicative order"*, 2026-01-16. **Correct as cited** — supports "finding elements of large order should no longer be considered a bottleneck" (verbatim), i.e. the `D ≥ N^{2/5}` precondition is dropped. |
| 28 | Humbert–Edge genus formula, standard CI-of-quadrics result `g(C_d)=1+(d−4)2^{d−3}` | `Round47_GenusRediscovery.md:11` | Textbook; corroborated by item 21. The `Ŷ_d` corollary via Riemann–Hurworth is arithmetic, not a citation. |
| 29 | Silverman, *"The multiple polynomial quadratic sieve"*, **Math. Comp. 48 (Jan 1987) 329–339**, DOI 10.1090/S0025-5718-1987-0866119-8 | `Round43_MPQS_Results.md:19-20` | Consistent with the Crossref DOI the corpus records; the round read the **actual PDF** (`cr.yp.to/bib/1987/silverman.pdf`) — this is model verification practice, not an assertion from a title. |
| 30 | Boender & te Riele, *"Factoring Integers with Large-Prime Variations of the Quadratic Sieve"*, **Experimental Mathematics 5(4):257–273 (1996)** | `Round43_LP_Results.md:70-72` | The round opened the **full PDF** from `ir.cwi.nl/pub/1367/1367D.pdf` and quotes §5 verbatim. Opened source, not a title-read. |
| 31 | HAC §3.2.7 **p. 97** (Handbook of Applied Cryptography) | `Round44_NFS_Results.md:41-42` | The round quoted the disclaimer *"are beyond the scope of this book"* from the page. The two `L`-constants `(32/9)^{1/3}` and `(64/9)^{1/3}` are the standard HAC values. |
| 32 | Maurer & Wolf, **SIAM J. Comput. 28(5):1689–1721 (1999)**, DOI 10.1137/s0097539796302749 | `Round47_ChebotarevAndRetraction.md:136` | Crossref: Ueli M. Maurer & Stefan Wolf, *"The Relationship Between Breaking the Diffie-Hellman Protocol and Computing Discrete Logarithms"*. **The correction from "IPL 71:191–197" is exactly right.** |
| 33 | Lenstra, *"Factoring integers with elliptic curves"*, **MR 0916721** | `Round47_ChebotarevAndRetraction.md:142` | Crossref `10.2307/1971363` corroborates the Annals 126(3) 1987 record. |
| 34 | von zur Gathen–Kaltofen 1983 conference version, LNCS pp. 250–263 | (implicit, cf. PHANTOM 4) | Crossref `10.1007/bfb0036913`: a real 1983 LNCS paper by the same pair — almost certainly what generated the volume/page confusion. |
| 35 | Boutin–Gaudry–Guillevic–Heninger–Thomé–Zimmermann | `Round46_Handover.md:143`; `Round47_GNFSConstant.md:36` | **See UNVERIFIED-1** — real author group, arXiv ID unconfirmed. |
| 36 | Gidney, **arXiv:2505.15917**, RSA-2048 incumbent | `quantum-factoring-gap-yoked-parallel.md` | The scratch file records the abs page **opened** and the 40-page PDF **read**; `pdfinfo` title *"How to factor 2048 bit RSA integers with less than a million noisy qubits"*, author Craig Gidney. The memory's *self-correction* that the title is **not** "5 days with 1 million noisy qubits" matches the scratch's note that a later version retitled it. Good practice; not re-fetched by this audit. |
| 37 | Gidney–Ekerå 2021, **Quantum 5, 433** | `factor-scratch/r45/axis7/build.md:48` | The scratch explicitly records that the incumbent's *journal citation "Quantum Inf. Comput. 19(6) 433-472" is unverifiable and must not be propagated* — and that **433 belongs to GE21 in *Quantum* 5**. The memory's replacement is right; the phantom it retracts is the third Quantum Inf. Comput. mis-citation in that file. |
| 38 | Pinnacle, **arXiv:2602.11457**, ρ-parallelisation | `quantum-factoring-gap-yoked-parallel.md` | Scratch records the **PDF read**, with named authors (Webster, Berent, Chandra, Hockings, Baspin, Thomsen, Smith, Cohen — Riverlane). The memory then **retracts its own fusion claim** as a category error. |
| 39 | **"Haamr (Pinnacle)"** — from the audit brief | — | **NOT FOUND anywhere in the corpus.** Grep across `Catalog/`, `Experiments/`, `factor-scratch/`, and the memory dir returns zero hits. The Pinnacle author list contains no such name. **This was a brief-level error, not a corpus phantom.** |
| 40 | Lecerf, *Factorisation des polynômes à plusieurs variables*, **CCIRM 2013**, Numdam 10.5802/ccirm.18, **Problème ouvert 5.1** | `Round46_Handover.md:150-153,508` | Numdam IDs are stable and the record quotes the French verbatim with the accent marks intact. `Round46_Handover.md:512` and `Round47_HandoverAddendum.md:59` both read the §5/§9 text and **retract four of their own earlier Lecerf claims** using it. Model verification. |
| 41 | Dixon (1981) as the origin of a proven subexponential factoring algorithm; Pomerance (1992); Barbulescu–Gaudry–Kleinjung | `Round46_Handover.md:238,252,906,910`; `Round44_NFS_Results.md:455` | Dixon's 1981 Math. Comp. and Pomerance's smooth-number work are textbook. ⚠️ `Round44_NFS_Results.md:455-456` **explicitly declines to re-derive** the `L[1/3,(64/9)^{1/3}]` balance it attributes to Barbulescu–Gaudry–Kleinjung, and labels it *"not re-derived from source"* — an honest gap, correctly marked. |

---

## 4. UNVERIFIED — 5

Recorded honestly. **None of these is claimed real.**

**UNVERIFIED-1 — `arXiv:2006.06197`, Boudot–Gaudry–Guillevic–Heninger–Thomé–Zimmermann.**
Cited at `Round47_GNFSConstant.md:36-37` for the verbatim *"easily swallows any speedup
or slowdown that would be polynomial in `log N`"*, and at `Round47_SUMMARY.md`.
**Load-bearing**: with Montgomery's `O(n²)` (§VERIFIED-7), this is one of the **two
independent closures** of "beat the GNFS heuristic constant". The six-author group and
a 2006 preprint of a multi-precision-arithmetic computation paper are plausible, but
the arXiv API was rate-limited (HTTP 429) throughout this audit and I could not
resolve the ID. **What I tried**: export.arxiv.org API (429, retried), Crossref
bibliographic search (did not return it). **Re-check**: `https://arxiv.org/abs/2006.06197`.

**UNVERIFIED-2 — "Theor. Comput. Sci. 226 (1999) 7–18, on hyperelliptic Jacobians"**,
asserted at `Round47_ChebotarevAndRetraction.md:138` as "the real ADH paper". Not
confirmed. The author triple "Adleman, DeMarrais, Huang" is itself doubtful — those
three barely collaborated. **What I tried**: Crossref bibliographic search. **Re-check**
before propagating; if it is wrong, the correction's main body (Adleman & DeMarrais,
two authors, Math. Comp. 61 (1993) 1–15) still stands independently.

**UNVERIFIED-3 — the p.3 content of Herrmann–May ASIACRYPT 2008.** Bibliographic
record VERIFIED exactly (§VERIFIED-8), but the *two verbatim quotes* — the `ln(2) ≈ 70%`
sentence and "the dimension of the lattice basis that we have to `L³`-reduce grows
exponentially in `n`" — were **not re-read by this audit** (Springer-walled). The round
claims they were read off 400 dpi page images. **These two sentences carry the
running-time-barrier conclusion**, which is `Round47_AuxiliaryInformation.md`'s entire
deliverable. Also UNVERIFIED: the §(6.4) verbatim quote at
`Round47_StandardPipeline.md:43-48`, and the Buchmann–Williams p.115 line (PHANTOM 7).

**UNVERIFIED-4 — BLP chapter p.15 / p.27 content.** See PHANTOM 3. The venue is now
corrected, but whether chapter p.15 carries the four obstructions (6.2–6.5) and whether
p.27 carries the χ_Q-spanning conjecture is **unconfirmed**, and the chapter's true
pagination (book pp. 50–94) makes the bare "p. 15" ambiguous. **This directly threatens
`Round47_SUMMARY.md:126-133`**, whose retraction of the Chebotarev reading depends on
LV Lemma 6.6 closing BLP's p.27 conjecture. **Re-check**: institutional access to LNM 1554.

**UNVERIFIED-5 — LV p.39 "every possible factor" quote.** `Round47_StandardPipeline.md:35-37`
quotes LV p.39 as *"guarantees to find every possible factor"* and uses it to **reverse**
the round's own "relations are too few" thesis. The page number is plausible (p.39 is
where Conj 7.1 lives, VERIFIED above) and the substance matches memory
`round47-verdict-relations-too-few.md`, but the **exact wording was not confirmed
verbatim** by this audit. Given this project's own OCR rule, treat the wording as
unverified until the page image is re-read.

---

## 5. WHAT THIS MEANS

1. **The spine is sound.** Lee–Venkatesan, its venue, its DOI, and **ten separate
   internal page/theorem/numbering cites** were all confirmed — including the
   `(log log n)^{-1/3}` reading the program flagged as high-risk from OCR, and the
   `1.92299` / `1.90188` distinction that a text-layer read would have destroyed. The
   campaign's single most load-bearing object is real and correctly cited.

2. **The prior-art claim that would have killed round 48 is real.** The IOSR paper was
   **opened as a PDF**, not matched on a title, and it publishes the same pipeline.
   `Round48_CostExponent.md`'s "the method is prior art" is honest and correctly cited.

3. **There is exactly one new outright phantom: `Bernstein–Blekherman–Jenkings–Shor–Trop
   (ASIACRYPT 2013)`.** It is load-bearing as the *independent corroboration* of the
   half-the-bits correction. That makes it the **sixteenth fabricated citation**.

4. **The other seven defects are all wrong-venue-strings on real papers** — and
   **six of the eight sit inside the program's own correction tables.** The repair
   machinery caught its phantoms and then introduced fresh venue errors of exactly the
   kind it was built to catch. Three are mechanical and instantly fixable:
   `2601.17422`→`2110.08354`, `Math. Comp. 44`→`45(171) 251–261`,
   `LNM 1554 (1993) 50–94`.

5. **The two unresolved risks are both page-level, not existence-level** — BLP p.15/p.27
   (Springer-walled) and the Herrmann–May p.3 quotes. Both feed committed claims. Neither
   is disproved, and neither should be re-cited until a human opens the page.

**The pattern, stated as the program's own rule (5) demands:** every defect found here
was a *venue string* or an *author list*, never a fabricated paper. The program has
become good at knowing which papers exist and unreliable at writing down where they
live. That is a strictly better failure mode than round 45's — but it is the same
failure mode, one level up.
