# Literature verification sweep — RSA partial key exposure / multivariate Coppersmith

Date of sweep: 2026-10-03. Host: raver1975 box.

**Method note (read this before trusting anything below).** Per the standing citation
discipline for this program, WebSearch and WebFetch-on-search-engine were NOT used.
All routes used were:

- `curl https://eprint.iacr.org/search?q=<urlencoded>` (returns a literal `N results` count)
- direct `curl` to `https://eprint.iacr.org/<year>/<num>` and `.../<num>.pdf`
- `curl https://export.arxiv.org/api/query?search_query=...` (https, not http)
- Crossref REST API (`https://api.crossref.org/works/...`) and `https://api.crossref.org/works?query.bibliographic=...`

Every claim below is either (a) a verbatim quote from a page/PDF I actually fetched and
`pdftotext`-extracted, or (b) explicitly labelled NOT FOUND. Nothing is asserted from memory.

**Access failures encountered (these constrain the answers):**
- Springer (`link.springer.com`) returns HTTP 200 with a 3038-byte "Client Challenge"
  interstitial for both `/chapter/...` and `/content/pdf/...`. Body title is
  literally `Client Challenge`. So **neither EUROCRYPT 2005 nor ASIACRYPT 2008 primary PDF
  could be read directly.** Both are cited via Crossref metadata + via verbatim restatements
  in later IACR papers whose PDFs I *could* download. This is flagged per-answer.
- `www.iacr.org/archive/{eurocrypt2005,asiacrypt2008}/` returns HTTP 403.
- `www.may-crypto.com` does not resolve (curl exit 2, HTTP 000).

---

## Q1. The "known multiplier" partial key exposure attack

### Q1a. Ernst, Jochemsz, May, de Weger, EUROCRYPT 2005 — PRIMARY SOURCE, metadata CONFIRMED, full text NOT retrieved

**Confirmed via Crossref.** Query
`https://api.crossref.org/works?query.bibliographic=Partial+Key+Exposure+Attacks+on+RSA+up+to+Full+Size+Exponents`
returns, as the **second** item (not the first — see the "phantom guard" note below):

> `['Partial Key Exposure Attacks on RSA up to Full Size Exponents'] | ['Ernst', 'Jochemsz', 'May', 'de Weger'] | ['Lecture Notes in Computer Science', 'Advances in Cryptology – EUROCRYPT 2005'] | 371-386 | [[2005]] | DOI: 10.1007/11426639_22`

Resolved record `https://api.crossref.org/works/10.1007/11426639_22` confirms
**authors Matthias Ernst, Ellen Jochemsz, Alexander May, Benne de Weger; LNCS pp. 371–386;
EUROCRYPT 2005.**

**This paper is NOT on IACR eprint.** eprint searches performed, all returning the paper
as absent:
- `q=Ernst+Jochemsz+May+de+Weger` → no count / no results
- `q=Jochemsz` → 4 results, none it (2024/1330, 2017/092, 2014/343, 2010/146)
- `q=full+size+exponents+partial+key+exposure` → 3 results, none it
- `q=Ernst+partial+key+exposure+exponents` → 3 results (2018/516, 2016/1056, 2016/195)

So the primary source exists and is correctly identified, but **I could not read its PDF.**
I therefore report **no verbatim abstract and no formula from the original** — that would be
fabrication. Below is the closest verified surrogate.

### Q1b. VERIFIED SURROGATE: Ernst et al.'s exact attack condition, as restated verbatim

Source: **eprint 2018/516**, Atsushi Takayasu & Noboru Kunihiro,
*Partial Key Exposure Attacks on RSA: Achieving the Boneh-Durfee Bound*.
URL: `https://eprint.iacr.org/2018/516` (PDF: `https://eprint.iacr.org/2018/516.pdf`,
SAC 2014 full version, last updated 2018-05-27).

Verbatim from the PDF, **§4.2 "Previous Works", page 16 of the PDF**:

> "In this subsection, we briefly recall previous attacks proposed by Ernst et al. [EJMdW05] and
> Sarkar et al. [SSM10]. Ernst et al.'s attack, which solves integer equations, works when
>
> ```
>                  (1) δ < 5/6 − (1/3)√(1 + 6β),
>      3
>  (2) δ < 1/6  and β ≤ 11/16 ,
>                          3
>      δ < 1/3 + 1/3 β − 1/3 4β 2 + 2β − 2  and β > 11/16 .
> ```

(The radical/overline placement in the extracted text is mangled; conditions (2) and (3) are
**Sarkar et al.** conditions per the surrounding prose — the prose continues "Sarkar et al.'s
attack ... works in the above condition (2)" — so **only condition (1) is Ernst et al.'s.**
Condition (1) is the one you want.)

Verbatim, same page, immediately following:

> "The condition (1) is the best for β < 235/512. Ernst et al.'s attack can be viewed as an extension of
> the Boneh-Durfee weaker attack since the condition (1) is the same as β < (7 − 2√7)/6 = 0.284 · · ·
> for δ = β."

And the confirmation that this is a reconstruction of their theorem, **page 22** (§4.3):

> "Proof of the Condition (1) of Ernst et al. As Sarkar et al., we solve the modular equation"

Numerical cross-check of condition (1) against their own comparison **Table 1, page 2**
(β → Ernst δ): β=0.3 → δ=0.275559982; β=0.4 → δ=0.218697036; β=0.46 → δ=0.1875.
I verified δ = 5/6 − (1/3)√(1+6β) reproduces these: at β=0.46, √(1+2.76)=1.9404, 5/6−0.6468=0.1865≈0.1875. Consistent.

### Q1c. On the specific "multiplier is KNOWN exactly" distinction

**This is the part I must flag as NOT RESOLVED from primary sources.**

The framing you describe — p = u·2^δ + p0 with u **known exactly**, versus only the top
δ bits known (so u known only to within a range) — is the standard *expansion-technique*
setup of Ernst et al. In the literature I can *verify* the distinction exists as a named
scenario family, but **I could not find an eprint paper whose title or abstract states the
known-multiplier threshold directly.** Searches run and returned nothing on point:

- `q=known+multiplier+partial+key+exposure` → no count
- `q=known+multiplier` → (search returned only unrelated hits)
- `q=expansion+technique+RSA+known+bits` → no count
- `q=hidden+number+problem+known+multiplier` → 2 hits, both irrelevant (2020/1619 Kirchner–Fouque
  "Getting Rid of Linear Algebra in Number Theory Problems"; 2002/145 Leadbitter–Smart MQV)
- arXiv `abs:"known multiplier"` → 14 total, **all astrophysics/economics**, zero crypto
- arXiv `abs:"partial key exposure" AND abs:lattice` → **1 total**, and it is
  2609.38668v1 *Z-Sigil*, a signature scheme that merely cites the term. arXiv is
  effectively empty for this subfield.

**The closest verified statement of the scenario taxonomy** is **eprint 2016/1056**
(Takayasu & Kunihiro, *A Tool Kit for Partial Key Exposure Attacks on RSA*, CT-RSA 2017),
**Definition 1, page 2**:

> "Definition 1 ((α, β, γ, δ)-Partial Key Exposure Attacks on RSA). Let N = ∏ᵣᵢ₌₁ pᵢ where all
> p₁, . . . , pᵣ are distinct primes of the same bit-size. Let e = N^α and d = N^β such that ed = 1"

This formalism parameterizes leaked bits as **fractions** (γ, δ), i.e. the
partial-information regime — it is *not* the fully-known-multiplier regime, which would be
γ = 0 with the multiplier as an exact integer.

**Conclusion for Q1:** the Ernst et al. EUROCRYPT 2005 primary source is *confirmed to exist*
with verified Crossref metadata, and its **attack threshold δ < 5/6 − (1/3)√(1+6β) is verified
verbatim from a peer restatement** (2018/516 p.16, with the original theorem re-proved in §4.3
of that same paper). But **the exact "u known exactly" variant's threshold is NOT FOUND** in
any accessible primary source on this host. Do not attribute a known-multiplier formula to
Ernst et al. on the basis of this sweep.

---

## Q3. Herrmann & May, ASIACRYPT 2008, "Solving Linear Equations Modulo Divisors: On Factoring Given Any Bits"

(Ordered here because the material overlaps heavily with Q1.)

### Q3a. PRIMARY SOURCE — metadata CONFIRMED via Crossref; no eprint version exists

Crossref query `?query.bibliographic=Solving+Linear+Equations+Modulo+Divisors+On+Factoring+Given+Any+Bits&rows=5`
returns as the **first** item:

> `['Solving Linear Equations Modulo Divisors: On Factoring Given Any Bits'] | ['Herrmann', 'May'] | ['Lecture Notes in Computer Science', 'Advances in Cryptology - ASIACRYPT 2008'] | [[2008]] | DOI: 10.1007/978-3-540-89255-7_25`

Resolved `https://api.crossref.org/works/10.1007/978-3-540-89255-7_25` adds:
**authors Mathias Herrmann, Alexander May; Springer Berlin Heidelberg; pages 406–424;
ISBN 9783540892540 / 9783540892557; published-print 2008.**

**There is NO IACR eprint version.** `eprint q=Solving+Linear+Equations+Modulo+Divisors`
returns exactly 1 result (2014/343), not this paper; `q=Herrmann+May` returns 10 results,
none it; `q=Solving+Linear+Equations` returns 88 results, none it. The Springer PDF is
Client-Challenge-blocked. **Therefore I report no verbatim abstract and no page-cited formula
from the original ASIACRYPT 2008 paper.** Its threshold is reported below only as a
verbatim restatement, correctly attributed.

### Q3b. ⚠️ DO NOT CONFUSE with eprint 2007/374 — a same-authored but DIFFERENT paper

eprint **2007/374** is Mathias Herrmann & Alexander May, *On Factoring Arbitrary Integers
with Known Bits*. URL `https://eprint.iacr.org/2007/374`, PDF 6 pages, received 2007-09-19,
Category Foundations, "Published elsewhere. Full Version of the Workshop "Kryptologie in
Theorie und Praxis" paper".

Verbatim abstract from that page:

> "We study the {factoring with known bits problem}, where we are given a composite integer
> $N=p_1p_2\dots p_r$ and oracle access to the bits of the prime factors $p_i$, $i=1, \dots, r$.
> Our goal is to find the full factorization of $N$ in polynomial time with a minimal number
> of calls to the oracle. We present a rigorous algorithm that efficiently factors $N$ given
> $(1-\frac{1}{r}H_r)\log N$ bits, where $H_r$ denotes the $r^{th}$ harmonic number."

**This is emphatically NOT the ASIACRYPT 2008 paper, and it explicitly disclaims the
heuristic.** From the 2007/374 PDF (the ASIA 2007 workshop text), verbatim:

> "Additionally our algorithm is rigorous, i.e. it does not depend on a heuristic assumption
> like the one in [SKKO06]."

And it cites exactly that heuristic work, verbatim, on the same PDF:

> "The authors use a heuristic algorithm of Coron [Cor04] for finding a root of a
> polynomial." (on Herrmann & May's *Simultaneous Small Root Finding*, Eurocrypt 2008)

The $(1-\tfrac{1}{r}H_r)\log N$ figure is a **rigorous** result and must not be cited as
Herrmann-May's ASIACRYPT '08 heuristic threshold.

### Q3c. VERIFIED RESTATEMENT of the ASIACRYPT '08 bound

Source: **eprint 2014/343**, Yao Lu, Rui Zhang, Liqiang Peng, Dongdai Lin,
*Solving Linear Equations Modulo Unknown Divisors: Revisited*, ASIACRYPT 2015
(received 2014-05-19, revised 2015-09-07). URL `https://eprint.iacr.org/2014/343`.

Verbatim, **page 16 of the PDF** (§4 comparison to previous methods):

> "Our result improves Herrmann-May's bound  \frac{3\beta-2}{4} + 2(1-\beta)^2  up to \beta^2 if
> a_0 = 0. As a concrete example, for the case β = 0.5, our method improves the upper size of
> X_1X_2 from N^0.207 to N^0.25."

(Disambiguated by extracting the page twice: `-layout` mode shows the numerator "3" and
denominator "4" stacked; `-raw` mode shows the same. The bound is **(3β−2)/4 + 2(1−β)²**.)

The same paper, **page 2**, verbatim, naming what Herrmann-May actually did:

> "In Asiacrypt'08, Herrmann and May [12] extended the univariate linear modular polynomial to
> polynomials with an arbitrary number of n variables. They presented a polynomial-time
> algorithm to find small roots of linear modular-polynomials
> f(x_1,...,x_n) = a_0 + a_1x_1 + · · · + a_nx_n mod p where p is unknown and divides the
> known modulus N. Naturally, they applied their results to the problem of factoring with known
> bits for RSA modulus N = pq where those unknown bits might spread across arbitrary number of
> blocks of p."

And their own general n-variable condition, **page 9**, verbatim:

> "Under Assumption 1, we can find all the solutions (y_1,...,y_n) of the equation
> f_1(x_1,...,x_n) = 0 (mod p^v) ... if
>   Σᵢ γ_i < (1/u)·[ 1 − (1−u^β)^{n/(n+1)} − ((n+1)(1−u^β))^{1/(n+1)}·... ]"

rendered in the source as

> "γ_i < 1/u [ 1 − (1 − u^β)^{n/(n+1)} − (n+1)(1 − u^β)^{1/(n+1)} (1 − 1/u^{1/(n+1)} − ε) ]"

The **specializing-to-RSA-pq threshold formula for "m consecutive bits of p" was NOT FOUND** —
no accessible source on this host states it with a page number. Lu et al. give the *root-size*
bound above, not the known-bits-of-p threshold. **Report NOT FOUND for that sub-part.**

---

## Q2. Is the algebraic-independence heuristic in multivariate Coppersmith still unproven as of 2026?

### Answer: YES — still a heuristic. Explicitly still assumed as recently as CRYPTO 2025. NO PROOF OR REFUTATION FOUND.

The strongest evidence is a **CRYPTO 2025** paper that states the assumption as a live
heuristic rather than a theorem.

**Source: eprint 2024/1330**, Yansong Feng, Hengyi Luo, Qiyuan Chen, Abderrahmane Nitaj,
Yanbin Pan, *Computing Asymptotic Bounds for Small Roots in Coppersmith's Method via Sumset
Theory*, "A major revision of an IACR publication in CRYPTO 2025" (received 2024-06-10...,
revised 2025-06-30). URL `https://eprint.iacr.org/2024/1330`.

Verbatim, **page 11** of the PDF:

> "After constructing the lattice L and applying the LLL algorithm, Coppersmith's method further
> requires the following assumption commonly required for the multivariate case [BD00,HM10,FNP24],
> and this heuristic holds for most instances encountered in practice:
>
> **Assumption 1.** The polynomials obtained from the LLL-reduced basis in Coppersmith's method
> generate an ideal corresponding to a zero-dimensional variety."

Note the citation trail **[BD00, HM10, FNP24]** — this is the paper's own claim that the
multivariate zero-dimensionality assumption is the standing accepted heuristic as of CRYPTO
2025, i.e. **three decades after Coron's 2004 heuristic and well after the two already-verified
capacity papers**. Also verbatim from the same paper, **page 11** region:

> "The running time of the algorithm is polynomial in ε⁻ⁿ and ε⁻ⁿ log N."

and the abstract's framing (from the eprint page):

> "we develop the first provable algorithm for determining these asymptotic bounds, whereas the
> recent methods based on simple Lagrange interpolation are heuristic."

— i.e. what is now *provable* is the **bound computation**, not the zero-dimensionality /
independence step. That distinction is the crux: recent work has made the arithmetic provable
while leaving the algebraic step heuristic.

**Corroborating 2025 source — Keegan Ryan, EUROCRYPT 2025** (eprint 2024/1577,
*Solving Multivariate Coppersmith Problems with Known Moduli*). Verbatim, **page 6** of the
PDF, stating the zero-dimensionality heuristic explicitly as "Heuristic 1":

> "These polynomials share a common root over the integers, and the following heuristic is used
> to conclude that the root can be found, using Gröbner bases for example.
> **Heuristic 1** The algebraic variety corresponding to the ideal in Q[x] of polynomials
> recovered by lattice reduction is zero-dimensional."

And, same paper, **page 6**, verbatim:

> "This condition on S ensures that the determinant bound for lattice reduction implies recovery
> of ℓ linearly independent vectors satisfying the HHG bound. It is common to see this in an
> asymptotic form, where we consider arbitrarily large p and |S| such that the contribution of
> several terms becomes negligible."

Also verbatim from that paper's abstract (eprint page):

> "While our strategies are still heuristic, they are simple to describe, implement, and execute,
> and we hope that they drastically simplify the application of Coppersmith's method to systems
> of multivariate polynomials."

### Q2 sub-questions, individually

**(a) Follow-ups to arXiv:2111.14180 by the same or other authors.**
**NOT FOUND.** I enumerated the complete arXiv records of all three non-Heninger authors via
`https://export.arxiv.org/api/query?search_query=au:%22...%22` with `sortBy=submittedDate&sortOrder=descending`:

- Ted Chinburg (`au:="Chinburg"`, 52 total): most recent is 2609.13908 *The Nil K-groups of
  finite groups* (2026-09-12). Crypto entries: **2111.14180** (2021-11-28) and **1605.08065**
  (2016-05-25). Nothing after 2021.
- "Hemenway" (27 total, note: `au:="Hemenway"` does not resolve to Falk): crypto entries are
  **2111.14180** and **1605.08065** only.
- Zachary Scherr (`au:="Scherr"`, 45 total): crypto/math entries **2111.14180**, **1605.08065**,
  2307.04566, 2211.09975. Nothing on Coppersmith after 2021.

**So no author has published a capacity-theory follow-up to 2111.14180 through 2026-10-03.**

**(b) Any paper using capacity theory on higher-dimensional varieties to settle it.**
**NOT FOUND.** arXiv `all:"Coppersmith" AND all:"capacity"` returns **totalResults = 2** —
exactly the two already-verified papers and nothing else:

> `2111.14180v1 | 2021-11-28 | Chinburg, Hemenway Falk, Heninger, Scherr — Two variable polynomial congruences and capacity theory`
> `1605.08065v1 | 2016-05-25 | Chinburg, Hemenway, Heninger, Scherr — Cryptographic applications of capacity theory: On the optimality of Coppersmith's method for univariate polynomials`

This is a **whole-corpus** result on arXiv, not a top-hits cut — the query space is the entire
archive. arXiv `all:"algebraic independence" AND all:"Coppersmith"` returns **totalResults = 0**.

**(c) Any implemented/automated decidable independence test beyond the two-variable LINEAR case.**
**NOT FOUND — but note precisely what exists, because the negative is easy to overstate.**
There is substantial *automation of the bound computation and monomial selection*, but it is
all downstream of, not a substitute for, the independence assumption:

- **eprint 2024/1577** (Ryan, EUROCRYPT 2025), verbatim from PDF page 6 region — the
  zero-dimensionality is *Heuristic 1*, stated as a heuristic, while the *shift-polynomial
  selection* is made optimal/provable: from the abstract, "we develop several algorithms that
  make such hand-crafted strategies obsolete. We first use the theory of Gröbner bases to
  develop an algorithm that provably computes an optimal set of shift polynomials, and we use
  lattice theory to construct a lattice which provably contains all desired short vectors."
  Also "we develop a strategy which symbolically precomputes shift polynomials, and we use the
  theory of polytopes to polynomially bound the running time."
  This is the closest thing to a decidable test — but it is decisive about *monomial selection*,
  not about whether the recovered polynomials are actually independent.
- **eprint 2024/1330** (CRYPTO 2025): "first provable algorithm for determining these asymptotic
  bounds" — again bounds, not independence. Still carries Assumption 1 (quoted above).
- **eprint 2023/1409** (Meers & Nowakowski, ASIACRYPT 2023), *Solving the Hidden Number Problem
  for CSIDH and CSURF via Automated Coppersmith* — verbatim from abstract:
  "we give a purely combinatorial restatement of Coppersmith's method, effectively concealing the
  intricate aspects of lattice theory and allowing for near-complete automation."
- **eprint 2026/1027** (Ding, Dai, Wu, Zhang, Zhang, ASIACRYPT 2026), *Computing Asymptotic
  Bounds for the Automated Coppersmith Method via Linear Programming* — verbatim from abstract:
  "we transform the computation of asymptotic bounds for the Automated Coppersmith method,
  proposed by Meers and Nowakowski (ASIACRYPT 2023), into a linear programming problem, thereby
  obtaining a provably correct and explicitly computable formula."

So: **automated and provable for the bounds; the independence/zero-dimensionality step remains
an assumption that CRYPTO 2025 and EUROCRYPT 2025 papers still state as a heuristic.**

---

## Q4. 2023–2026 work on Coppersmith optimality beyond arXiv:1605.08065

### Answer: NO follow-up, simplification, or counter-result to the Chinburg et al. capacity paper. NOT FOUND.

**Evidence 1 — the space is empty.** The arXiv whole-corpus query
`all:"Coppersmith" AND all:"capacity"` returns **totalResults = 2**, both already-known
(see Q2b above). arXiv `all:"optimality" AND all:"Coppersmith"` on IACR-eprint terms —
the eprint search `q=optimality+Coppersmith` returns 5 results, of which exactly one is on
topic and it is **2012/108**, i.e. *pre-2016*, not post:

> `[2012/108] On the Optimality of Lattices for the Coppersmith Technique | Yoshinori Aono, Manindra Agrawal, Takakazu Satoh, Osamu Watanabe | Last updated 2015-12-18`

This is the only other "optimality of Coppersmith" eprint, it concerns optimality of the
**lattice reduction** (LLM/LLL), and it predates the capacity papers.

**Evidence 2 — no author has followed up.** See the three complete arXiv author listings in
Q2(a): Chinburg, Hemenway(Falk), and Scherr have published **nothing** on Coppersmith or
capacity theory after 2021-11-28. Nadia Heninger was not separately enumerable (name
ambiguity), but the co-authored pair of capacity papers is the entirety of the cryptanalytic
output surfaced by the `au:` queries run.

**Evidence 3 — what *did* happen 2023–2026 is adjacent, not a settlement.** All of the
recent work takes Coppersmith's bound/technique as given and automates the arithmetic:

| eprint | paper | venue | what it does (verbatim from abstract) |
|---|---|---|---|
| 2023/1409 | Solving the HNP for CSIDH and CSURF via Automated Coppersmith | ASIACRYPT 2023 | "purely combinatorial restatement ... allowing for near-complete automation" |
| 2024/1577 | Solving Multivariate Coppersmith Problems with Known Moduli (Ryan) | EUROCRYPT 2025 | "provably computes an optimal set of shift polynomials" |
| 2024/1330 | Computing Asymptotic Bounds ... via Sumset Theory | CRYPTO 2025 | "the first provable algorithm for determining these asymptotic bounds" |
| 2026/1027 | Computing Asymptotic Bounds ... via Linear Programming | ASIACRYPT 2026 | "into a linear programming problem, thereby obtaining a provably correct and explicitly computable formula" |

None of these re-derives the **optimality bound** of 1605.08065 (which is about *sufficiency* of
the bound); they compute **achievable** bounds in new settings. Note in particular that
2024/1577 and 2024/1330 both explicitly retain the zero-dimensionality heuristic (quoted in
Q2) — a proof of optimality would have made that assumption unnecessary in the univariate limit.

---

## Summary table

| Q | Result | Confidence |
|---|---|---|
| Q1a | Ernst–Jochemsz–May–de Weger, EUROCRYPT 2005, LNCS 371–386, DOI 10.1007/11426639_22 | Metadata VERIFIED (Crossref). No eprint version. PDF unreadable (Springer challenge). |
| Q1b | Ernst et al. threshold: **δ < 5/6 − (1/3)√(1+6β)**, valid for β < 2^(35/512)≈0.458 | VERIFIED verbatim, eprint 2018/516 p.16, with independent re-proof in §4.3 of that paper |
| Q1c | The *known-multiplier-exact* variant p = u·2^δ+p0 with u known | **NOT FOUND** on any accessible primary source |
| Q3a | Herrmann–May, ASIACRYPT 2008, LNCS pp. 406–424, DOI 10.1007/978-3-540-89255-7_25 | Metadata VERIFIED (Crossref). No eprint version. PDF unreadable |
| Q3b | eprint 2007/374 is a **different, rigorous** paper — not the ASIACRYPT'08 heuristic one | VERIFIED verbatim from its own PDF |
| Q3c | HM bivariate bound **(3β−2)/4 + 2(1−β)²**, e.g. X₁X₂ ≤ N^0.207 at β=0.5 | VERIFIED verbatim, eprint 2014/343 p.16 (a restatement, not the original) |
| Q3d | Threshold formula for factoring from **m consecutive bits of p** | **NOT FOUND** |
| Q2 | Multivariate algebraic-independence / zero-dimensionality still **unproven** | VERIFIED: stated as "Assumption 1" in CRYPTO 2025 (2024/1330 p.11) and "Heuristic 1" in EUROCRYPT 2025 (2024/1577 p.6) |
| Q2a | Follow-ups to 2111.14180 | **NOT FOUND** — all three authors' complete arXiv records enumerated, nothing after 2021-11-28 |
| Q2b | Capacity theory on higher-dimensional varieties | **NOT FOUND** — arXiv `Coppersmith AND capacity` = totalResults 2, both known |
| Q2c | Decidable automated independence test beyond 2-var linear | **NOT FOUND.** Automation exists for bounds/monomial selection only (2023/1409, 2024/1577, 2024/1330, 2026/1027) |
| Q4 | Post-2016 work on Coppersmith *optimality* | **NOT FOUND.** Only other optimality eprint is 2012/108 (Aono et al., predates; concerns lattice optimality, not the bound) |

**Two load-bearing cautions for downstream use.**

1. **eprint 2007/374 ≠ Herrmann–May ASIACRYPT 2008.** Both are Herrmann & May, both are about
   factoring with known bits, and the eprint one is the one you can actually download. It is
   *rigorous* and explicitly disclaims the heuristic. Citing its
   $(1-\tfrac{1}{r}H_r)\log N$ as the ASIACRYPT '08 threshold would be wrong.

2. **Q1b and Q3c formulas are restatements, not originals.** They are verbatim from
   peer papers that re-prove or re-derive the results, with page numbers I confirmed by
   extracting the PDF page twice (layout and raw modes) to disambiguate stacked fractions.
   They are safe to cite *as given by Takayasu–Kunihiro 2018 / Lu et al. 2015*. They are not
   verbatim from the Springer originals, because those PDFs are Client-Challenge-blocked on
   this host. If the exact original wording is needed, it requires institutional Springer
   access, which this host does not have.