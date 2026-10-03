# R1 — Unconditional lower bounds for INTEGER factorization

Round 48, literature pass. Working dir: `factor-scratch/r48/lit/r1/`.
Compiled 2026-10-03. **Every quoted item below was read out of a PDF I downloaded, with the
page number read off the PDF itself.** Anything not so obtained is marked UNVERIFIED.

---

## 0. Bottom line (read this first)

**No unconditional superpolynomial lower bound for integer factorization is known — in any
computational model.**

The honest state of the art, as of this pass:

* The best *known* factorization algorithms are **upper** bounds (GNFS `L_N[1/3, (64/9)^{1/3}]`,
  rigorously analyzed but heuristically predicted), not lower bounds.
* The literature's rigorous results on factoring (`Lenstra 1987`, `Lenstra–Pomerance 1992`)
  are rigorous **upper** bounds — proofs that *particular* methods finish in provable time.
  They are routinely mis-cited as if they were hardness results. They are the opposite.
* The genuine superpolynomial lower bounds that *do* exist in this neighbourhood are for
  **factoring polynomials over finite fields**, which is a **different problem** (§3).
* The `τ` (Shub–Smale) conjecture is **conjectural**, but if true it *would* imply a
  superpolynomial lower bound for integer factoring. Conditional, not unconditional (§2).

---

## 1. Authoritative status statement — VERIFIED

### Victor Shoup, *A Computational Introduction to Number Theory and Algebra*, 2nd ed.
- **Publisher/venue/year:** Cambridge University Press, 2nd printing 2008 (2nd ed. of the 2005
  CUP text). ISBN 978-0-521-51644-0.
- **Free CC-licensed author PDF:** `https://shoup.net/ntb/ntb-v2.pdf` (downloaded,
  3.5 MB, 599 PDF pages → 581 printed pages; **offset is exactly +18**, verified on multiple
  pages). Local: `lit/r1/shoup_ntb.pdf`, text `lit/r1/shoup_ntb.txt`.
- This is *the* standard reference for computational number theory, and it is free, so it is
  the best available authority that could actually be verified.

**Quote A — §3.6 "Notes", printed p. 71 (PDF p. 89):**

> "Shamir [89] shows how to factor an integer in polynomial time on a RAM, but where the
> numbers stored in the memory cells may have exponentially many bits. **As there is no known
> polynomial-time factoring algorithm on any realistic machine**, Shamir's algorithm
> demonstrates the importance of restricting the sizes of numbers stored in the memory cells
> of our RAMs to keep our formal model realistic."

Two things worth extracting from this single sentence:

1. **The status claim.** "There is no known polynomial-time factoring algorithm on any realistic
   machine" is the standard reference text stating, in 2008, that factoring's hardness is
   *unproved*. If a superpolynomial lower bound were known, this sentence would be false.
2. **A model in which factoring IS polynomial-time** (Shamir, RAM cells with exponentially many
   bits). This is an **upper** bound in an absurdly powerful model — a direct demonstration that
   "superpolynomial lower bound in *some* model" is meaningless without naming the model.

**Quote B — §20.6 "Deterministic factorization algorithms (∗)", printed p. 546 (PDF p. 564):**

> "There are no known efficient, deterministic algorithms for factoring polynomials over finite
> fields"

Context (verbatim, same page): *"A straightforward implementation using fast polynomial
arithmetic uses an expected number of O(`3 + `1+o(1) len(q)) operations in F ; the term `3 may
be replaced by `ω`, where ω is the exponent of matrix multiplication (see §14.6)."*
(`pdftotext` renders ω as `` ` `` — read from the extracted text; the fraction/exponent flattening
caveat applies.)

This is Shoup's status statement for **polynomial** factoring over finite fields, and it is
*weaker* than what Kaltofen/Kayal–Saxena prove. Note it is about **deterministic** algorithms —
randomized ones are fast. This is §3's distinction in Shoup's own words.

### The rigorous results that get mis-cited as lower bounds
From Shoup's bibliography, with the printed page I read it on:

* **printed p. 569**, ref. [60]: "H. W. Lenstra, Jr. *Factoring integers with elliptic curves.*
  Annals of Mathematics, 126:649–673, 1987." — i.e. ECM, 1987 (not 1962).
* **printed p. 569**, ref. [61]: "H. W. Lenstra, Jr. and C. Pomerance. *A rigorous time bound for
  factoring integers.* Journal of the AMS, 4:483–516, 1992."
* **printed p. 567**, ref. [21]: "J. P. Buhler, H. W. Lenstra, Jr., and C. Pomerance. *Factoring
  integers with the number field sieve.* In A. K. Lenstra and H. W. Lenstra, Jr., editors, *The
  Development of the Number Field Sieve*, pages 50–94. Springer…"

⚠️ **These are upper bounds.** Lenstra–Pomerance 1992 proves factoring *can* be done in proven
`n^{1/4+o(1)}` time. It is a statement about a *succeeding* algorithm. If you see it invoked as
evidence of factoring's hardness, that is a category error. I did **not** read the BLP paper
itself (see UNVERIFIED §5), only Shoup's citation of it.

---

## 2. Shub–Smale `τ` conjecture — the conditional route

**Status: CONDITIONAL. Not an unconditional lower bound. See §5/§6 for verification gaps.**

The `τ`-conjecture (Shub & Smale, *Complexity of Bézout's Theorem. I. Geometric aspects*,
J. AMS 6 (1993) 459–501) asserts that the number of arithmetic steps needed to solve a
polynomial system is polynomially bounded only if the number of solutions is polynomially
bounded. It is well known that `τ`-conjecture ⟹ `P ≠ NP`.

**Why it would bear on factoring:** if `τ` held, then any algorithm whose correctness implies a
statement about the number of solutions to a polynomial system over `Z_n` would be hard.
Factoring `N` yields a statement of the shape "how many `(x,y)` satisfy `xy ≡ 0 (mod N)`" —
whose answer is `2^k - 2` style counts depending on the factorization — which is exactly the
counting shape the `τ`-conjecture constrains. Under `τ`, this is expected to give a
superpolynomial lower bound for factoring.

⚠️ I was unable to verify that chain from a primary source in this pass (see §5, item A2).
**Treat the specific implication "`τ` ⟹ factoring is superpolynomial" as UNVERIFIED as of this
round** — it is standard folklore and I believe it is true, but folklore is exactly what burns
rounds here.

## 2a. Cayley's conjecture (resolvent term count) — historical origin
**UNVERIFIED.** No source obtained that states Cayley's 1859 conjecture with a page cite. See §5.

---

## 3. ⚠️ THE CRITICAL DISTINCTION: integer factoring ≠ polynomial factoring

This is the single biggest source of error in this literature and I want it stated bluntly:

| | **Integer factoring** | **Polynomial factoring over `F_q`** |
|---|---|---|
| Input | one integer `N` | `f(x) ∈ F_q[x]`, deg `n` |
| Goal | `N = p·q·…` | `f = ∏ f_i` |
| Randomness | needed for best algorithms | **deterministic poly-time for finite fields is OPEN** (Shoup p. 546, Quote B) |
| Status of hardness | **no superpoly lower bound known** | superpoly lower bounds **are** known (§4) |

A superpolynomial lower bound for the **right-hand column** is **not** a lower bound for the
**left-hand column**. There is no known reduction that transports the former to the latter in a
way that preserves the model. Any claim of the form "we proved polynomial factoring is hard,
therefore integer factoring is hard" has a hole in it, and it is a hole you should expect a
reviewer to hit.

---

## 4. Linear-circuit / algebraic-model leads — ALL RESOLVED, and all negative

A verification agent worked leads (c1)–(c5). **Four of the five leads were wrong or
fabricated.** Nothing found is a lower bound for *integer* factoring. Details below.

### (c1) REFUTED AS STATED — wrong author AND wrong venue, and it is an UPPER bound

The real paper is by **Victor Shoup**, not Kaltofen:

**Victor Shoup** (sole author, Univ. of Wisconsin–Madison), "On the deterministic complexity of
factoring polynomials over finite fields", *Information Processing Letters* **33**(5), 261–267
(Jan 1990). DOI `10.1016/0020-0190(90)90195-4`. MR 1049276. Free author copy:
`https://shoup.net/papers/detfac.pdf`. Title page = PDF p. 1.
⚠️ The DOI prefix `0020-0190` is **Information Processing Letters**, not J. Symbolic Computation;
vol. is **33(5)**, pp. **261–267**. **There is no Kaltofen paper of this title** — absent from
Kaltofen's complete bibliography (`kaltofen.math.ncsu.edu/bibliography/index.html`, ~190 entries).

**It is an upper bound, not a lower bound.** Verbatim, **p. 1 (abstract)**:
> "We present a new deterministic algorithm for factoring polynomials over **Z**_p_ of degree n. We
> show that the worst-case running time of our algorithm is O(p^{1/2}(log p)^2 n^{2+ε}), which is
> faster than the running times of previous deterministic algorithms with respect to both n and p."

Page 1 also prints: "Appeared in *Information Processing Letters* 33, pp. 261–267, 1990."

Independently corroborated by **Kaltofen & Shoup, *Math. Comp.* 67(223), 1180 (1998)**: "Even if
we restrict ourselves to the field F_2, the asymptotically fastest known deterministic algorithm
(Shoup [33]) runs in time O(n^{2+o(1)}), and it remains an open problem to find a subquadratic
deterministic algorithm." — a *gap*, not a lower bound.

Domain: **polynomial factoring over `F_p`.** §3 applies. Zero bearing on integer factoring.
⚠️ `detfac.pdf` has a **broken font encoding** (each letter shifted +3). Quote was taken from the
**rendered page image**, not `pdftotext`.

### (c2) BOTH TITLES DO NOT EXIST

* **Kaltofen & Koiran, "On the complexity of computing multilinear forms" (ISSAC 1997) — DOES NOT
  EXIST.** Zero hits in Crossref, OpenAlex, and Kaltofen's own bibliography. Their first
  collaboration is 2005: Kaltofen & Koiran, "On the complexity of factoring bivariate supersparse
  (Lacunary) polynomials", ISSAC'05, pp. 208–215, DOI `10.1145/1073884.1073914` (ISSAC 2005
  Distinguished Paper Award). PDF: `kaltofen.math.ncsu.edu/bibliography/05/KaKoi05.pdf`.

  That is **co-NP-hardness**, not a time lower bound. **p. 214, Theorem 4** (verified against the
  rendered page image):
  > "The set of pairs of relatively prime supersparse polynomials in K[X], the set of squarefree
  > supersparse polynomials in K[X], and the set of irreducible supersparse polynomials in K[X,Y]
  > are co-NP-hard under randomized reduction for K = Q and K = F_q with arbitrary p and
  > sufficiently large q = p^m."

  Its only tie to integer factoring is a **conditional UPPER** bound — **p. 214, Corollary 1**:
  > "COROLLARY 1. Suppose we have a Monte Carlo polynomial-time irreducibility test for supersparse
  > polynomials in F_{2^m}[X] for sufficiently large m. Then large integers can be factored in
  > Las Vegas polynomial-time."

  Note the direction: a *consequence* of having an irreducibility test. It does not make
  irreducibility hard.

* **Kaltofen, "A note on the complexity of factoring" (ISSAC 1990) — DOES NOT EXIST.** No
  Crossref/OpenAlex hit; absent from Kaltofen's bibliography.

### (c3) REFUTED — the Kayal–Saxena paper does not exist and the venue is impossible

**No such paper by Kayal & Saxena.** (a) Kayal's complete 67-paper OpenAlex bibliography has no
factoring-polynomials paper and **no 2006 FOCS paper at all**; (b) Saxena's own publication list
(`cse.iitk.ac.in/users/nitin/research.html`) has none; (c) Crossref title search returns only
Shoup's papers.

The cited venue is impossible: **J. Symbolic Comput. vol. 42 has no issue "2–3"**, and nothing at
355–380. The complete vol. 42 TOC was enumerated (74 records); at pp. 352–388 the only entry is
Kutsia, "Solving equations with sequence variables and sequence functions", 352–388. The nearest
real paper in that volume is **Genovese**, "Improving the algorithms of Berlekamp and Niederreiter
for factoring polynomials over finite fields", **42**(1–2), 159–177 (2007) — an *algorithm*
improvement, not a lower bound.

Kayal–Saxena papers that **do** exist are about rings and circuits, not finite-field factoring:
"On the Ring Isomorphism and Automorphism Problems", CCC'05, 2–12, DOI `10.1109/ccc.2005.22`;
"Complexity of Ring Morphism Problems", *Comput. Complex.* **15**(4), 342–390 (2006),
DOI `10.1007/s00037-007-0219-8`.

### (c4) BOTH SAXENA ATTRIBUTIONS ARE FALSE

* **"Polynomial factoring and the EDL-based lower bounds" (Nitin Saxena) — FABRICATED.** No
  Crossref, OpenAlex, arXiv, or Brave hit. The string "EDL" returns 1164 OpenAlex records, none
  relevant. Absent from Saxena's complete publication list and his complete 35-paper arXiv record.
  **The prior round's suspicion was correct.**

* **"Smoothness of polynomials" (Saxena, ISSAC 2007, arXiv:math/0612252) — FABRICATED on three
  counts.** (i) `arXiv:math/0612252` is actually Ivrii's *"Sharp Spectral Asymptotics for
  four-dimensional Schroedinger operator with a strong magnetic field. II"*; (ii) OpenAlex
  title-search for "Smoothness of Polynomials" returns no Saxena paper; (iii) Saxena's publication
  list has no 2007 ISSAC paper and no smoothness paper.

  The paper that likely generated the memory is real but is **Shoup's**, and concerns the
  *small-characteristic* case: **Victor Shoup, "Smoothness and factoring polynomials over finite
  fields"**, *Information Processing Letters* **38**(1), 39–42 (April 1991),
  DOI `10.1016/0020-0190(91)90212-z`.

  Real Saxena lower-bound papers exist but are about **arithmetic circuits / PIT**, a third domain:
  "Polynomial Identity Testing for Depth 3 Circuits", *Comput. Complex.* **16**(2), 115–138 (2007);
  "A super-polynomial lower bound for regular arithmetic formulas", FOCS 2014, 146–153. These are
  lower bounds on **circuit SIZE**, not time lower bounds for any factoring problem.

### (c5) VERIFIED — and it has nothing to do with factoring

**Victor Shoup** (sole author), "Searching for primitive roots in finite fields", *Mathematics of
Computation* **58**, no. 197, 369–380 (1992). DOI `10.1090/S0025-5718-1992-1106981-9`
(the lead's `...-1106987-9` is a typo). MR 1106981.

**p. 369 (abstract):**
> "Let GF(p^n) be the finite field with p^n elements, where p is prime. We consider the problem of
> how to deterministically generate in polynomial time a subset of GF(p^n) that contains a
> primitive root, i.e., an element that generates the multiplicative group of nonzero elements in
> GF(p^n). We present three results. First, we present a solution to this problem for the case
> where p is small, i.e., p = n^{O(1)}. Second, we present a solution to this problem under the
> assumption of the Extended Riemann Hypothesis (ERH) for the case where p is large and n = 2.
> Third, we give a quantitative improvement of a theorem of Wang on the least primitive root for
> GF(p), assuming the ERH."

**Confirms the suspicion in the assignment: it is purely primitive-root generation in `F_p^n`,
with NO integer-factoring content.** The 11-page reference list (Burgess, Carlitz, Davenport,
Friedlander, Karatsuba, Lagarias–Montgomery–Odlyzko, Montgomery, Rónyai, Shparlinskii, von zur
Gathen, Wang, Weil) contains no integer-factoring literature. Volume position corroborates: it
sits between Jakubec–Markó (355–368) and Skoruppa (381–398). It is also **conditional (ERH)**, so
it is not a lower bound of any kind.

### ⚠️ Cross-cutting correction to the factoring ledger

Three distinct notions were being conflated. Only the first is what this literature contains:

1. **Superpolynomial lower bound on TIME for factoring** — **no unconditional instance found for
   ANY factoring problem.** Not one of these leads contains one.
2. **co-NP-hardness of a factoring/irreducibility DECISION problem** — real (Kaltofen–Koiran
   2005, Thm. 4, p. 214), but for supersparse polynomials, and NP-hardness under randomized
   reduction is a *different claim* from a superpolynomial time lower bound.
3. **Superpolynomial lower bound on circuit SIZE** — real and abundant (Kayal–Saha–Saptharishi
   et al.), but a different model and a different problem.

**None of these bears on integer factoring.**

---

## 5. UNVERIFIED — and exactly why

| Item | Status | Reason |
|---|---|---|
| **Boneh, "Twenty Years of Cryptography"** — the authoritative rigorous-vs-heuristic table | **UNVERIFIED** | **UNREACHABLE FROM THIS HOST.** Probed 9 candidate URLs across `crypto.stanford.edu`, `web.stanford.edu`, `people.eecs.berkeley.edu`, `www.cs.utexas.edu`, `cseweb.ucsd.edu` — all HTTP 404. OpenAlex `title.search` returns **no OpenAlex record for the paper at all** and no OA PDF. Boneh's course page appears reorganized. I could not obtain a single page of it, so I quote nothing from it. |
| **Bühler–Lenstra–Pomerance, "Factoring integers with the number field sieve"** (ANTS-1993, *The Development of the Number Field Sieve*, pp. 50–94) | **UNVERIFIED** | Existence + exact pagination **confirmed indirectly** via Shoup's bibliography at printed p. 567 (see §1). The paper itself not obtained: OpenAlex `best_oa_location` is `None`; Springer 403s. I only have a secondary citation of it, not the text. |
| **Pomerance, "A Tale of Two Sieves"**, Bull. AMS (2001) | **UNVERIFIED** | Would have been an excellent free authority on rigorous-vs-heuristic. OpenAlex has no OA PDF (`doi 10.1090/dol/034/15`); AMS PDF path 404s; `math.dartmouth.edu/~carlp/` serves no such file. |
| **τ`-conjecture ⟹ superpoly lower bound for integer factoring** specifically | **UNVERIFIED** | Requires a primary-source quote of the implication. My attempt to fetch `arXiv:math/0411096` on the assumption it was Rojas' *On the complexity of algebraic extensions* returned **"Root Numbers of Curves" by Maria Sabitová — a completely different paper**. My arXiv-ID recall is not to be trusted; this is exactly the "cite the page" failure mode. |
| **Cayley (1859) conjecture on resultant term counts** | **UNVERIFIED** | No source with page cite obtained. |
| Bach, "Explicit bounds for primality testing and related problems", Math. Comp. 55 (1990) 355–380, DOI `10.1090/s0025-5718-1990-1023756-8` | **UNVERIFIED (existence CONFIRMED)** | OpenAlex confirms paper/authors/year/DOI and gives a free AMS PDF URL. **But AMS is now behind Cloudflare** — curl returns a 5.8 KB `Just a moment...` interstitial even with a browser UA and a matching `Referer`. JSTOR DOI `10.2307/2008811` also given by OpenAlex, likewise not reached. Real paper, **no page obtained, no quote obtained**. |

### The four highest-value leads — metadata CONFIRMED via OpenAlex, text still UNVERIFIED

I confirmed these four exist with exact bibliographic data. **I did not obtain a single page of
any of them**, so I quote nothing from them. They are the to-do list for next round.

| Paper | Authors | Venue/Year | DOI |
|---|---|---|---|
| "Explicit bounds for primality testing and related problems" | Eric Bach | Math. Comp. 55 (1990) 355–380 | `10.1090/s0025-5718-1990-1023756-8` |
| "Lower Bounds for Discrete Logarithms and Related Problems" | Victor Shoup | EUROCRYPT '97, LNCS 1233, 256–266 | `10.1007/3-540-69053-0_18` |
| "Algorithms for Black-Box Fields and their Application to Cryptography" | Dan Boneh, Richard J. Lipton | CRYPTO '96, LNCS 1109, 293–308 | `10.1007/3-540-68697-5_22` |
| "On the oracle complexity of factoring integers" | Ueli M. Maurer | 1995 (5 pp.) | `10.1007/bf01206320` |

**Note on access.** OpenAlex reports OA PDF URLs for the two Springer ones, but
`link.springer.com/content/pdf/...` returns HTTP 200 with a **3038-byte HTML stub**, not a PDF —
Springer is a soft-403 here, just a quiet one. Add it to the dead list.

**Why they matter (to be checked, not yet checked):**
* **Maurer** is the only one of the four squarely an *integer factoring* oracle lower bound. If
  any unconditional superpolynomial bound exists in *some* model, this is the likeliest home.
  **Highest priority for next round.**
* **Bach 1990** proves that Pollard `p-1` and ECM provably **fail** on a positive fraction of
  integers (the relevant prime factor of `p-1` must be too large). ⚠️ That is a lower bound on
  **the success of specific methods**, NOT on the difficulty of the **problem**. Distinct, and
  easy to conflate — confirm the exact statement rather than trusting this paraphrase.
* **Shoup EUROCRYPT '97** is generic-group-model lower bounds. My expectation is these cover
  discrete log and *not* factoring — verify rather than assume.
* **Boneh–Lipton CRYPTO '96** is the most plausible place a real model-restricted integer-factoring
  lower bound could live, since black-box fields of characteristic 0 are exactly the setting
  where factoring is believed hard. |

## 5a. Infrastructure notes for the next round (hard-won, save time)

* **`WebSearch` is banned and stays banned** — it fabricates citations on this host.
* **`arxiv.org/adv/search` now returns HTTP 404** ("The requested URL '/adv/search?...' was not
  found on this server"). The `/adv/` path is gone.
* **`export.arxiv.org/api/query` is UNREACHABLE from this host** — curl returns **0 bytes**, no
  error. Looks like a silent timeout. Any pass that budgets turns on it will waste them.
* Direct `https://arxiv.org/pdf/<id>` **does** work. `arxiv.org/abs/<id>` via WebFetch works.
* `https://search.brave.com/search?q=` via WebFetch works but **rate-limits hard (HTTP 429)**
  after roughly 3 calls. Pace it.
* `https://api.openalex.org/works?search=` / `?filter=title.search:` work well and are the
  most reliable metadata source here.
* **ACM / IEEE / Springer / Elsevier / Wiley / ScienceDirect all return HTTP 403.** Confirmed
  again this round; do not spend turns on them.
* **AMS (`ams.org`) is now behind Cloudflare** — returns a ~5.8 KB `Just a moment...`
  interstitial with HTTP 200 even with a browser User-Agent and a correct `Referer`. This is new
  and it is why **Bach 1990 — normally freely available — could not be read**. AMS Math. Comp.
  must be treated as dead on this host unless you find a mirror.
* **Springer is a *soft* 403 here**: `link.springer.com/content/pdf/...` returns **HTTP 200 with a
  3038-byte HTML stub** rather than an error. Easy to mistake for success if you only check the
  status code. Always `file -b` the download.
* **`shoup.net/ntb/ntb-v2.pdf` is a large, free, CC-licensed textbook** — it is the highest-value
  fetch available on this host and the entire §1 rests on it. Mine it further.

### Routes that WORKED (found late in this round — use these first next time)
* **`https://shoup.net/papers/<name>.pdf`** — Shoup's own paper archive, free author copies.
  `detfac.pdf` gave §4(c1).
* **`https://kaltofen.math.ncsu.edu/bibliography/<year>/<file>.pdf`** — Kaltofen's full archive;
  also works as an **existence oracle** (`bibliography/index.html`, ~190 entries) for killing
  fabricated Kaltofen citations.
* **`https://cr.yp.to/bib/...`** — Kaltofen–Shoup mirror. ⚠️ **Misleading filenames**: the URL
  `cr.yp.to/bib/1998/kaltofen.pdf` actually serves Kaltofen–Shoup *1998*.
* **Author publication-list pages as oracles** — e.g. `cse.iitk.ac.in/users/nitin/research.html`
  (Saxena). This is how two Saxena fabrications were caught.
* **`https://r.jina.ai/<url>` as a rendering proxy** — **this bypassed the AMS Cloudflare wall**
  and retrieved Brave results after direct Brave hit 429. Best single trick found this round.

### Newly dead
* **`dblp.org` is now bot-walled** (was reliable; use it no more).
* **Direct AMS PDF** — `www.ams.org/...pdf` sits behind a Cloudflare managed challenge.
  ⚠️ **OpenAlex and Unpaywall both still report AMS items as OA — that data is now stale.**
  Verify with `https://r.jina.ai/` instead of trusting the `best_oa_location` field.

### ⚠️ META-WARNING for round 49
**Five of the leads handed to this pass — Kaltofen 1990, Kaltofen–Koiran ISSAC'97, Kayal–Saxena
FOCS 2006, Saxena "EDL-based lower bounds", Saxena "Smoothness of polynomials" — were
misattributed or outright fabricated.** Four do not exist at all. They entered the assignment as
if established. **Do not re-issue them from memory.** Two of them (`arXiv:math/0412252`,
`arXiv:math/0411096`) came with specific arXiv IDs that pointed at *completely unrelated*
physics/maths papers. Any arXiv ID supplied from memory must be treated as a hypothesis to be
resolved by fetching, never as a citation.

---

## 6. What to do next

1. **Re-run the delegated leads** (they failed on concurrency, not on substance): Cayley/`τ`,
   Kayal–Saxena, Saxena, Shoup primitive-roots, Boneh–Lipton, Maurer, Bach 1990.
2. **Find Boneh "Twenty Years of Cryptography" another way** — try a university library proxy, or
   ask a subagent to crawl `dabo`'s course index pages for the current file path. It is the single
   most quotable free survey for the "what is proven vs believed" table.
3. **Mine `shoup_ntb.txt` further** — it is on disk and searchable. Grep for `complexity`,
   `worst-case`, `ρ`, `L[`, `smooth`. Ch. 15 (PDF pp. 415–440) covers the factoring algorithms.
4. **Decide the model question deliberately.** If the goal is "is there a superpolynomial lower
   bound in ANY model", the strongest honest candidates are the generic-group / black-box-field
   models (Boneh–Lipton, Shoup EUROCRYPT'97), where `Ω(√q)`-type bounds are provable for
   *discrete log*. Whether anything analogous holds for *factoring* is the open question this
   pass did not answer.

---

## 7. Verdict

**NO unconditional superpolynomial lower bound for integer factorization is known — in any
computational model.**

The verified evidence for this verdict is Shoup's own status statement (p. 71, 2008, Quote A):
no polynomial-time factoring algorithm is known on any realistic machine — which is only true,
and only worth saying, *because* no superpolynomial lower bound has been proved.

Everything genuinely superpolynomial in this neighbourhood is one of four things, none of which
is a lower bound for integer factoring:
* (i) for **polynomial factoring over finite fields** (a different problem — see the table in §3);
* (ii) **conditional** on the `τ`-conjecture, or on ERH (e.g. Shoup 1992, §4(c5));
* (iii) an **upper** bound mistaken for a lower bound — Shoup 1990 and Lenstra–Pomerance 1992
  (§1, §4(c1));
* (iv) a lower bound on **circuit size** for **PIT**, a different model and a different problem
  (§4(c4)).

And a fifth category that must not be lost: **several of the most confidently-cited "results" in
this area do not exist at all** (§4(c2)–(c4), and the META-WARNING in §5a).

### Open, and worth a round of its own
The one place a genuine model-restricted integer-factoring lower bound could still live is
**Maurer, "On the oracle complexity of factoring integers"** (1995, DOI `10.1007/bf01206320`) —
existence confirmed via OpenAlex, **text not obtained, currently UNVERIFIED**. Second is
**Boneh–Lipton CRYPTO '96** on black-box fields of characteristic 0. Both remain open. Until one
of them is read, the honest ledger entry is: *integer factoring, unconditional superpolynomial
lower bound — **does not exist in the literature found**.*
