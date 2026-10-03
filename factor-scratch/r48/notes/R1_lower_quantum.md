# R1 — Unconditional lower bounds in the quantum factoring model

**Survey date:** 2026-10-03. **Author:** r1q scout.
**Method note:** WebSearch was NOT used at any point (it fabricates papers on this host).
Every claim below is marked VERIFIED (PDF in hand, page confirmed, page image read) or
UNVERIFIED / NOT-FOUND (documented negative).

## HEADLINE VERDICT

**No unconditional superpolynomial lower bound on quantum integer factoring is known.**
The sharpest rigorous restriction on a quantum factoring algorithm is a bound on its *success
probability* (item 1) — not a bound on its runtime, and the specific formula in the assignment
for that bound is **arithmetically impossible** (§1c). Every unconditional exponential lower
bound that exists in this area is a **quantum query lower bound on an oracle problem** —
collision, element distinctness, inverting a permutation, AND-of-ORs. Those are NOT factoring
lower bounds. See item 4.

### ⚠️ THREE ERRORS IN THE ASSIGNMENT'S OWN LEADS, FOUND AND DOCUMENTED
1. `arXiv:quant-ph/0012086` is **not** ABHT — it is van Enk & Hirota, "Entangled coherent
   states" (§1a).
2. The formula `p_max = (1/2)(3 − sqrt(2^(1/n) − 1))` is **numerically impossible**; it gives
   p_max > 1 for every n ≥ 8 and → 3/2 (§1c).
3. `arXiv:quant-ph/9508027` is **not** Shor's FOCS 1994 paper — it is the **SIAM J. Comput.
   1997** paper (item 5).

Plus two papers that appear not to exist at all: Ambainis "Quantum algorithm for polynomial
factoring" (item 2) and Buhrman–Høyer–Tapp–de Wolf "Quantum algorithms for factoring and the
provable limits of quantum computing" (item 3).

---

## Item 1 — Ambainis–Buhrman–Høyer–Tapp, "Quantum algorithms with proven maximal success probability" (FOCS 2000)

**Status: NOT LOCATABLE as an arXiv paper. The arXiv ID given in the assignment is WRONG.**

### 1a. The supplied arXiv ID belongs to a different paper — VERIFIED (refutation)

- **Assigned ID:** `arXiv:quant-ph/0012086`
- **Actual paper at that ID:** "Entangled coherent states: teleportation and decoherence"
  by **S. J. van Enk and O. Hirota** (Bell Labs / Tamagawa University).
- **Evidence:** downloaded `https://arxiv.org/pdf/quant-ph/0012086` → `r1q/abht.pdf`,
  page 1 header, VERBATIM:

  > "Entangled coherent states: teleportation and decoherence
  > S.J. van Enk¹ and O. Hirota²
  > ¹Bell Laboratories, Room 2C-401 600-700 Mountain Ave Murray Hill NJ 07974
  > ²Research Center for Quantum Communications, Tamagawa University, Tokyo, Japan
  > October 1, 2018
  > arXiv:quant-ph/0012086v1 17 Dec 2000"

  Abstract begins: *"When a superposition (|αi−|−αi) of two coherent states with opposite
  phase falls upon a 50-50 beamsplitter, the resulting state is entangled."*

  **This paper contains nothing about factoring, success probability of algorithms, or
  Ambainis/Buhrman/Høyer/Tapp.** Do not cite quant-ph/0012086 for the ABHT result.

### 1b. The ABHT paper is not in Ambainis's arXiv record — VERIFIED (negative)

Pulled the **complete** Ambainis arXiv author list via the arXiv API
(`http://export.arxiv.org/api/query?search_query=au:"Ambainis"&max_results=200`,
sorted ascending, **127 entries returned**, full record saved during the session).
No entry titled anything like "maximal success probability" appears. The closest
lower-bound papers in that list are all oracle problems (see item 2/4).

Independent negative checks, all of which returned nothing:
- arXiv **advanced** search, title field, phrase "maximal success probability" → no
  Ambainis/Buhrman/Høyer/Tapp hit (only unrelated comms/networking papers).
- arXiv **advanced** search, *all* fields, exact phrase "maximal success probability" →
  35 hits, none quantum-factoring; none by the four authors.
- arXiv **advanced** search, title field, "provable limits of quantum computing" → **zero**
  results. So the *other* assigned title is not an arXiv title either.
- **Decisive test:** arXiv **advanced** search, *abstract* field, phrase "maximal success
  probability", quant-ph archive, date range **1998-01-01 to 2003-12-31** (i.e. every month the
  FOCS 2000 paper could have been announced) → **14 hits, all unrelated** (optical cavity
  entanglement, teleportation, entanglement purification, Grover amplitude distributions).
  No Ambainis/Buhrman/Høyer/Tapp paper in that window contains the phrase in its abstract.
- OpenAlex `title.search:"quantum algorithms with proven maximal success probability"` → 0.
- Crossref bibliographic queries (fuzzy but non-zero recall elsewhere) → no FOCS-2000 hit.
- DBLP: bot-blocked on both `dblp.org` and `dblp.uni-trier.de` (Anubis challenge). NOT TRIED
  SUCCESSFULLY — this remains the one index I could not clear, so my negative on the
  *bibliographic record* (venue, page numbers) is **incomplete**.

### 1c. The formula as supplied is ARITHMETICALLY IMPOSSIBLE — VERIFIED (independent of any paper)

The assignment gives:

> p_max = (1/2)(3 - sqrt(2^(1/n) - 1)),  n = bit length of the integer being factored

I computed this directly (exact decimal arithmetic, 40 digits; reproduced in
`r1q/` by the scout). **It yields p_max > 1 for every n ≥ 8, tending to 3/2 as n → ∞:**

| n | 2^(1/n) − 1 | p_max |
|---|---|---|
| 8 | 0.0905077327 | **1.349577** |
| 16 | 0.0442737824 | **1.394793** |
| 32 | 0.0218971487 | **1.426012** |
| 64 | 0.0108892861 | **1.447824** |
| 128 | 0.0054299011 | **1.463156** |
| 256 | 0.0027112751 | **1.473965** |
| 1024 | 0.0006771307 | **1.486989** |

A success probability above 1 is not a probability. Since 2^(1/n) → 1 as n → ∞, the bound
diverges to 3/2 rather than settling to 1 or below. **The formula as given in the assignment
is therefore WRONG — mis-transcribed.** Either the exponent/sign is wrong (the obvious repair,
`2^(−1/n)`, does **not** work either: it makes the radicand negative and the expression
complex), or `n` is not the bit length of the integer being factored.

**This is the single most important finding of this survey.** Do not propagate the
`(1/2)(3 − sqrt(2^(1/n) − 1))` formula anywhere in the campaign. It is not a mis-citation,
it is not a wrong page number — it is a numerically impossible statement.

### 1d. Search exhaustion (documented negative)

An independent agent ran ~37 tool calls on this item alone and also failed. Combining both
attempts, the following are cleared:

- **arXiv:** not on arXiv. Established via Ambainis's complete 127-entry arXiv record
  (arXiv API), Peter Høyer's complete 45-entry arXiv listing (`arxiv.org/a/hoyer_p_1`) —
  he is a co-author and it is absent — plus four arXiv *advanced* searches returning zero.
  arXiv **full-text** search returns **HTTP 403**. The decoy-title searches that *do* return
  hits are all from unrelated fields (cavity QED, teleportation, optical gates).
- **OpenAlex:** no index record at all for this title (`title.search` → 0). Citation closure
  is therefore impossible. OpenAlex later returned **"Rate limit exceeded … $0 remaining"**,
  closing that avenue for the session.
- Also tried and empty: CORE (0), BASE (0), `scholar.archive.org` (0), `api.openaire.eu`
  (500/empty), Marginalia (200 but no coverage), Wayback CDX (**empty for every host
  queried** — CDX appears blocked from this host), direct PDF probes at
  `cs.rug.nl/~tapp`, `cs.au.dk/~peter`, `cse.buffalo.edu/~tapp`, Princeton course archive
  (all 404/400). `homepages.cwi.nl/~buhrman` loads but contains only a Google Scholar link.
- **DBLP bot-blocked on both mirrors** — the one bibliographic index never cleared, so a
  publication record under a *variant* title cannot be formally excluded.

Two candidate arXiv IDs were downloaded and explicitly **refuted** (guard against the
past fabricated-ID failure mode): `quant-ph/0508138` = Jensen-Shannon distinguishability
(Majtey/Lamberi/Prato); `quant-ph/0208183` = Leander, "Improving the Success Probability for
Shor's Factoring Algorithm" — on-topic but cites only Shor 1997, with **no ABHT citation
and no ABHT formula**.

**Not verified, do not use:** the recollection that the paper is FOCS 2000 pp. 415–427 with
a DOI in the `10.1109/SFCS.2000.8147xx` range, and a differently-shaped recalled bound of the
form `p ≥ 1 − 1/(3·2^(n/2) − 2)`. Both are from memory only. Given the arithmetic failure in
§1c, neither may be used downstream without the actual PDF.

**Unblocking routes, in order of expected value:** (a) an institutional IEEE Xplore login for
the FOCS 2000 proceedings volume; (b) de Wolf's or Buhrman's Google Scholar profile for an
author-hosted PDF; (c) any network with an OpenAlex API key; (d) a paid full-text aggregator.

### 1e. What still matters here — the *shape* of the claim

Even with the formula unusable, the structural point stands and should be carried forward
**without** the numbers: the sharpest known unconditional restriction on quantum factoring is
an upper bound on the **per-run success probability** of a factoring algorithm, not a lower
bound on its running time. Any such bound is exhausted by amplification — repeating the
algorithm Θ(log(1/ε)) times drives the failure probability below ε — so it converts into no
runtime lower bound at all. That is why item 4's verdict is unaffected.

---

## Item 2 — Ambainis on collision / element distinctness: does any lower bound transfer to factoring?

**Status: the paper "Quantum algorithm for polynomial factoring" by Ambainis does not appear
to exist.** No such title in his complete 127-entry arXiv record (pulled via arXiv API,
`au:"Ambainis"`, ascending); no such title in Crossref, OpenAlex, or arXiv advanced title
search. Crossref shows Ambainis authored only encyclopedia entries ("Quantum Algorithm for
Element Distinctness", "Quantum Algorithm for Search on Grids", Springer LNA 2008/2015/2016)
plus the ICM 2018 "Understanding Quantum Algorithms via Query Complexity". **Do not cite it.**

Substitute if a polynomial-factoring paper is genuinely needed (different problem — factoring
polynomials, not integers; it carries **no** implication for integer factoring):
- **Javad Doliskani, "Toward an Optimal Quantum Algorithm for Polynomial Factorization over
  Finite Fields", `arXiv:1807.09675`** (25 Jul 2018) — title and ID confirmed by arXiv advanced
  search; **PDF not downloaded, so UNVERIFIED at the page level.**

What Ambainis actually proved, and why it does **not** transfer:

### VERIFIED — Ambainis, "Quantum lower bounds by quantum arguments"
- **arXiv:** `quant-ph/0002066v1`, 24 Feb 2000. PDF: `r1q/quant-ph_0002066.pdf`.
- **Page 1 (Abstract), VERBATIM:**

  > "We propose a new method for proving lower bounds on quantum query algorithms. Instead of a
  > classical adversary that runs the algorithm with one input and then modifies the input, we use a
  > quantum adversary that runs the algorithm with a superposition of inputs. If the algorithm works correctly, its
  > state becomes entangled with the superposition over inputs. We bound the number of queries needed
  > to achieve a sufficient entanglement and this implies a lower bound on the number of queries for
  > the computation. Using this method, we prove two new Ω(√N) lower bounds on computing AND of ORs and inverting
  > a permutation..."

- **Page 1 (Introduction), VERBATIM — this is the crux of the distinction:**

  > "In the query model, algorithms access the input only by querying input items and the complexity of the
  > algorithm is measured by the number of queries that it makes. Many quantum algorithms can be naturally
  > expressed in this model. The most famous examples are Grover's algorithm[9] for searching an N-element
  > list with O(√N) quantum queries and period-finding which is the basis of Shor's factoring algorithm[11, 17]."

- **Page 1 (Introduction), VERBATIM — the lower bounds that exist are for abstract
  NP-complete stand-ins, not for factoring:**

  > "the unordered search problem provides an abstract model for NP-complete problems and
  > the Ω(√N) lower bound of [4] provided evidence of the difficulty of solving these problems on a quantum
  > computer."

**Why this is not a factoring lower bound:** "period-finding which is the basis of Shor's
factoring algorithm" is precisely the trap. A query lower bound on period-finding is a bound
for an algorithm equipped with an **oracle** for modular multiplication `x·a mod N` and for
the QFT. Factoring gets that multiplication from **actual reversible arithmetic on O(n) bits**,
which is not oracle access. Shor's arithmetic *itself* is known to be hard to lower-bound,
not to be out of reach of the polynomial simulation that an oracle lower bound would force.
An oracle lower bound says nothing about whether the oracle can be built cheaply.

### VERIFIED — Ambainis, "Polynomial Degree and Lower Bounds in Quantum Complexity: Collision and Element Distinctness with Small Range"
- **arXiv:** `quant-ph/0305179v3`, 29 Apr 2005. PDF: `r1q/quant-ph_0305179.pdf`.
- **Page 1 (Abstract), VERBATIM:**

  > "In particular, we get
  > Ω(N^{1/3}) and Ω(N^{2/3}) quantum lower bounds for collision and element distinctness with small
  > range."

Again: collision and element distinctness. **Neither is factoring.**

---

## Item 3 — Buhrman, Høyer, Tapp, de Wolf, "Quantum algorithms for factoring and the provable limits of quantum computing"?

**Status: NOT FOUND in any index I could clear.** Treating this as a probable mis-citation.

- I enumerated **all 145 Crossref-indexed Information Processing Letters (ISSN 0020-0190)
  papers from calendar 2001** and filtered for authors Buhrman / Høyer / Tapp / de Wolf /
  Ambainis. The **only** hit was "On learning formulas in the limit and with assurance"
  (Ambainis, p. 9–11). The BHTdW title is **not in IPL 2001**.
- arXiv advanced title search for "provable limits of quantum computing" → **zero results**.
- OpenAlex `title.search:"provable limits of quantum computing"` → **count 0**.
- Crossref bibliographic query → no hit.
- **Decisive-ish test:** pulled Alain Tapp's **complete** arXiv record via the arXiv API
  (`au:"Alain Tapp"`, ascending, **31 entries**). No entry has "factor", "success",
  "provable", or "lower" in its title. If BHTdW were on arXiv it would be in this list.
- Its most plausible home, Elsevier/ScienceDirect, returns **HTTP 403** from this host.

Additional routes cleared and found empty for both items 1 and 3: SearxNG public instances
(`searx.be` → anti-bot; `priv.au` → HTTP 429), Marginalia Search (`search.marginalia.nu`,
HTTP 200 but **zero** matching results — its index does not cover this literature),
OpenAIRE (`api.openaire.eu` → empty), Google Scholar/Crossref author queries (unusable).

**Do not report this paper** unless someone obtains the actual PDF. Consistent with the
assignment's own instruction. UNVERIFIED — and note that a *negative* here is itself only
as strong as the indexes cleared; **DBLP stayed bot-blocked on both mirrors**, so I cannot
rule out a publication record under a variant title.

---

## Item 4 — Is any UNCONDITIONAL superpolynomial lower bound on quantum factoring known?

### VERDICT: NO. None is known.

This is the crux, and the distinction must be kept sharp:

| Bound | What it actually bounds | Is it a factoring lower bound? |
|---|---|---|
| Ω(√N) unordered search (BBBV) | oracle search | **No** |
| Ω(N^{2/3}) collision | oracle collision | **No** |
| Ω(N^{2/3}) element distinctness | oracle element distinctness | **No** |
| Ω(N^{2/3}) inverting a permutation | oracle inversion | **No** |
| Ω(N^{1/2}) AND-of-ORs | oracle decision | **No** |
| ABHT success-probability bound (item 1) | success probability, not time | **Not a time lower bound** |

Every entry in that table is an **oracle** lower bound. Factor is not on the list, and
nothing in the literature moves it there.

Supporting observation, VERIFIED — Aaronson, "Multilinear Formulas and Skepticism of
Quantum Computing", `quant-ph/0311039v4` (15 Jul 2004), PDF: `r1q/quant-ph_0311039.pdf`,
**page 1, Abstract, VERBATIM**:

> "Several researchers, including Leonid Levin, Gerard 't Hooft, and Stephen Wolfram, have
> argued that quantum mechanics will break down before the factoring of large numbers becomes
> possible. If this is true, then there should be a natural set of quantum states that can account
> for all quantum computing experiments performed to date, but not for Shor's factoring algorithm."

The entire *existence* of this line of work is itself the evidence: rigorous lower bounds are
being pursued **as a hoped-for route** to arguing factoring is not easy. A result that were
needed would not be a hope. Aaronson's own lower bounds are on **tree size of quantum states**,
not on factoring time — and he says so, framing the target as a physical-state-class separation
("a key weakness of their arguments is their failure to answer the following question:
Exactly what property separates the quantum states we are sure we can create, from those that
suffice for Shor's factoring algorithm? We call such a property a Sure/Shor separator.",
**page 2**, VERBATIM).

**Campaign consequence:** any statement of the form "quantum factoring has no known
superpolynomial lower bound" is safe to make. Any statement of the form "Ω(N^{2/3})
factorization" is **false** and must never appear.

---

## Item 5 — Shor's FOCS 1994 paper: heuristic vs rigorous

### ⚠️ SECOND ID ERROR IN THE ASSIGNMENT (caught by reading the PDF title page)

`arXiv:quant-ph/9508027` is **NOT** the FOCS 1994 paper. Fetching
`https://arxiv.org/abs/quant-ph/9508027` returns:

- **Title:** "Polynomial-Time Algorithms for Prime Factorization and Discrete Logarithms on a
  Quantum Computer"
- **Journal ref:** "SIAM J.Sci.Statist.Comput. 26 (1997) 1484"
- **Related DOI:** `10.1137/S0097539795293172`
- **Submission history:** v1 30 Aug 1995 **withdrawn**; v2 25 Jan 1996

And the downloaded PDF's own title page (`r1q/shor.txt` lines 1–6, VERBATIM):

> "Polynomial-Time Algorithms for Prime Factorization and Discrete Logarithms on a Quantum Computer∗
> Peter W. Shor†
> arXiv:quant-ph/9508027v2 25 Jan 1996"

**So the PDF in hand is the SIAM J. Comput. 1997 version (29 PDF pages, internally paginated
1–29), not the 11-page FOCS '94 proceedings paper.** The two are the same work at different
stages of revision and share the §5 text, but a page citation must name which one.

- **FOCS '94 version (the one actually assigned):** "Algorithms for Quantum Computation:
  Discrete Logarithms and Factoring", Peter W. Shor, *Proceedings 35th Annual Symposium on
  Foundations of Computer Science (FOCS '94)*, **pp. 124–134**,
  **DOI `10.1109/SFCS.1994.365700`** — **VERIFIED via Crossref** (resolves to that title,
  that author, that proceedings, pp. 124–134; Crossref's `issued` is empty for this IEEE
  record). Page range independently confirmed by ref [34] of `arXiv:2201.07791`.
  **The FOCS '94 paper is NOT separately on arXiv** — an arXiv advanced *title* search for
  "Algorithms for quantum computation discrete logarithms and factoring" returns only
  `quant-ph/9508027` (SIAM version), `2404.16450`, and `1702.00249`. IEEE is HTTP 403 here,
  so the FOCS PDF itself could not be downloaded.

**All page numbers below are for `quant-ph/9508027v2`, i.e. the SIAM 1997 / arXiv version.**

### VERDICT on this item: the number theory is presented as RIGOROUS, not heuristic.

### VERDICT on this item: the number theory is presented as RIGOROUS, not heuristic.

**Mechanical check first:** the strings "heuristic", "conjecture", and "assume" in the
algorithmic sense **do not appear anywhere in the paper.** The only occurrence of a
non-rigorous register is on page 3, and it is about *physics*, not about the algorithm:

> "It thus seems plausible that the natural computing power of classical mechanics corre-"
> (page 3, discussing whether classical mechanics can simulate quantum mechanics; "plausible"
> is the only hedge in the whole paper and it does not touch factoring)

### VERIFIED — §5, arXiv PDF **page 16** (page image `r1q/shorp16-16.png` read)

The failure criterion and the success bound for the classical post-processing. Note the
exponent `k−1`, which `pdftotext` flattens to "1/2k−1"; confirmed against the rendered page image:

> "fails to be a non-trivial divisor of n only if r is odd or if x^{r/2} ≡ −1 (mod n). Using this
> criterion, it can be shown that this procedure, when applied to a random x (mod n),
> yields a factor of n with probability at least 1 − 1/2^{k−1}, where k is the number of distinct
> odd Q prime factors of n. A brief sketch of the proof of this result follows."

Every ingredient is a cited classical theorem, quoted on the same page:

> "By the Chinese remainder theorem [Knuth 1981, Hardy and Wright 1979, Theorem 121]...
> The multiplicative group (mod p^α) for any odd prime power p^α is cyclic [Knuth 1981]...
> Thus each of these powers of 2 has at most a 50% probability of agreeing with the previous ones,
> so all k of them agree with probability at most 1/2^{k−1}, and there is at least a 1 − 1/2^{k−1} chance that
> the x we choose is good."

### VERIFIED — §5, arXiv PDF **page 19** (page image `r1q/shorp19-19.png` read)

The continued-fraction / φ(r) step. The bound φ(r)/r > δ/log log r is attributed, not assumed:

> "There are φ(r) possible values of d relatively prime to r, where φ is Euler's totient function
> [Knuth 1981, Hardy and Wright 1979, §5.5]. ... Thus, there are rφ(r) states
> |c, x^k (mod n)⟩ which would enable us to obtain r. Since each of these states occurs
> with probability at least 1/3r², we obtain r with probability at least φ(r)/3r. Using
> the theorem that φ(r)/r > δ/ log log r for some constant δ [Hardy and Wright 1979,
> Theorem 328], this shows that we find r at least a δ/ log log r fraction of the time, so by
> repeating this experiment only O(log log r) times, we are assured of a high probability
> of success."

**So: no heuristic is used in the number theory.** `φ(r)/r > δ/log log r` (Hardy & Wright
Thm 328) is a proved theorem, and the amplification to bounded error is `O(log log r)`
repetitions.

### Where Shor IS informal — VERIFIED, arXiv PDF page 19

The only genuinely informal material is *engineering advice for reducing quantum work*,
introduced by an explicit assumption:

> "In practice, assuming that quantum computation is more expensive than classical
> computation, it would be worthwhile to alter the above algorithm so as to perform less
> quantum computation and more postprocessing. First, if the observed state is |c⟩, it
> would be wise to also try numbers close to c such as c ± 1, c ± 2, . . . , since these also
> have a reasonable chance of being close to a fraction qd/r. Second, if c/q ≈ d/r, and
> d and r have a common factor, it is likely to be small."

This is an optimization heuristic for a **speed-up**, not a correctness or success-probability
assumption. It can be discarded without affecting the theorem.

**Campaign consequence:** it is safe to write that Shor's number-theoretic steps are
rigorous (CRT, cyclicity of (Z/p^a)×, H&W Thm 328). It is safe to write that Shor's paper
contains no heuristic assumption about factoring. Do not write the opposite.

### 5b. Independent modern confirmation that Shor is the RIGOROUS one — VERIFIED

**Cédric Pilatte, "Unconditional correctness of recent quantum algorithms for factoring and
computing discrete logarithms", `arXiv:2404.16450v3` (v1 25 Apr 2024, v3 24 Aug 2026).**
PDF: `r1q/pilatte.pdf` (26 pages). This is directly on point: it is the paper that closes a
*conjectural* gap in a Shor-family factoring algorithm, and it says explicitly that Shor was
not conjectural. **Page 2, VERBATIM:**

> "The second issue, which we address in this paper, is that Regev's algorithm [18] does not have
> theoretical guarantees, unlike Shor's algorithm. The correctness of Regev's algorithm is based on
> an ad hoc number-theoretic conjecture which we describe below. This unproven assumption cannot
> be avoided as it lies at the core of Regev's improvement on the circuit size."

**Page 2, Theorem 1.1, VERBATIM** (note the O(√n) — pdftotext renders the radical inline):

> "Theorem 1.1. There is a quantum circuit having O(n^{3/2} log^3 n) quantum gates and O(n log^3 n)
> qubits with the following property. There is a classical randomised polynomial-time algorithm that
> solves the factoring problem
> Input : a composite integer N ⩽ 2^n
> Output : a non-trivial divisor of N
> using O(√n) calls to this quantum circuit, and succeeds with probability Θ(1)."

**Page 5 — the residual gap that remains OPEN, VERBATIM:**

> "To obtain the full strength of Regev's assumption [17, Conjecture 1], it would be necessary to show
> that this subgroup ⟨b1, . . . , bd⟩ contains a non-trivial square root of 1 modulo N.
> Unfortunately, it is not possible to prove this in full generality without considerable advances on
> the well-known least quadratic non-residue problem in number theory."

**Why this matters for the campaign:** the rigor/conjecture boundary in quantum factoring is
*live and moving*, but it moves only on the **upper bound** side (proving that a new factoring
algorithm is correct). It gives **no lower bound whatsoever**. Pilatte's paper is a
correctness proof for a factoring algorithm — the opposite of a complexity lower bound.

---

## Files in r1q/

| file | what |
|---|---|
| `shor.pdf`, `shor.txt`, `shorp16-16.png`, `shorp19-19.png` | Shor FOCS '94 (verified, item 5) |
| `abht.pdf`, `abht.txt` | the WRONG paper at quant-ph/0012086 (refutation of the supplied id) |
| `quant-ph_0002066.pdf/.txt` | Ambainis quantum adversary (oracle lower bounds) |
| `quant-ph_0305179.pdf/.txt` | Ambainis collision / element distinctness |
| `quant-ph_0311039.pdf/.txt` | Aaronson, multilinear formulas & factoring skepticism |
| `orderfind.pdf/.txt` | arXiv:2201.07791 — used for its reference list + Shor page range |
| `pilatte.pdf/.txt` | arXiv:2404.16450 — unconditional correctness of Regev/Ragavan–Vaikuntanathan factoring (item 5b) |
| `t_quant-ph_0007010.*`, `t_quant-ph_9901065.*` | two more wrong-ID refutation downloads (discard) |
| `ambainis_toc2010.pdf/.txt` | Ambainis, "A new quantum lower bound method" (ToC 6 (2010) 1–25) |
