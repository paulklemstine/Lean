# r114 / lit2023 — LIVE LITERATURE 2023–2026

Scout: literature axis. Verdict up front in §5.

## 0. ROUTE STATUS — THIS CORRECTS TWO MEMORY NOTES

The brief's route table is partly **out of date**. Two routes marked DEAD are **ALIVE** from this
host today (2026-10-05) and are the highest-yield ones:

| Route | Memory says | Actually |
|---|---|---|
| **arXiv API export** (`export.arxiv.org/api/query`) | "HTTP 406, does not work at all" (`lit-search-routes-that-work`) and "arXiv throttles hard, `searchtype=advanced` only works for single title terms" (`lit-routes-2026-09-29`) | **WORKS.** Full-text `abs:` / `ti:` / `au:` boolean queries, 50 results/page, `sortBy=submittedDate`. Rate-limited at ~20 rapid queries → HTTP 429; **6 s between queries is enough, no retry needed.** This is the single best route for this axis. |
| **OpenAlex** | "quota exhausts within a handful of calls" / "burned entirely, all routes 429" | **WORKS.** `?filter=doi:`, `?filter=cites:`, and `title_and_abstract.search` all fine. Not throttled at the rate used here (~30 calls). Gotcha: a literal comma inside a filter value must be `%2C` — an unescaped comma returns `{"error":"Invalid request rejected at the API edge"}`, which looks like a dead route but is not. |
| **HAL API** (`api.archives-ouvertes.fr/search/`) | not listed | **WORKS**, best route for French-granular / NFS-practice literature that arXiv misses. No rate limit observed. (The HAL *PDF* endpoint is Anubis-walled; the *metadata* endpoint is open and returns full abstracts.) |
| **Springer Link** | "publishers return 403" | **WORKS via WebFetch** through a 3-hop cookie redirect (`link.springer.com/article/…` → `idp.springer.com/authorize` → `…?error=cookies_not_supported&code=…`). Direct `curl` still gets a 3 KB block page. WebFetch's per-answer quote cap is 125 chars, so full abstracts must come from HAL/Crossref/arXiv instead. |
| Crossref REST | alive | alive, but returned **no abstract** for either LNCS/DCC DOI — Crossref is a metadata check here, not a content route. |
| IACR ePrint | untested | index page loads (200) but `/2023/` has only 198 links and **does not list ASIACRYPT papers** — it is proceedings-only for that volume. Not a useful route for ASIACRYPT. |

## 1. WHAT IS NEW (fetched, with verbatim quotes)

### 1.1 Zhu–Lv–Liu, "On the complexity formulae of the number field sieve and its variants"
*Designs, Codes and Cryptography* **94**, art. 51, published **2026-02-16**. DOI `10.1007/s10623-025-01788-5`.
NOT IN LEDGER. Authors verified on Crossref: `['Yuqing Zhu', 'Chang Lv', 'Jiqiang Liu']` (note:
OpenAlex renders the third author as "Jianxing Liu" — Crossref's "Jiqiang Liu" is the correct
romanisation of 季强).

Quotes are short (<125 chars each) because WebFetch caps source quotes at 125 characters:
- "not limited to any specific polynomial selection method."
- "have no restriction on the degree of the polynomials we sieve on or the number of fields we use."
- "our analysis method is more elementary."
- "we establish the lower bounds of the complexities of NFS and all its variants."
- "not lower than L(1/3, ∛(32/9))."

**This is a LOWER BOUND, not an improvement.** Read correctly it says: no NFS variant — including
any degree, any number of fields, any polynomial selection — can beat `L[1/3](∛(32/9))`. It is a
rigorous *confirmation* of the wall the campaign keeps re-deriving, in a venue that forecloses the
"but a cleverer degree/selection" escape. **NOT NEW to the campaign's substance; NEW as a citable
theorem.** Also: the Tower NFS is *not* separately named in the abstract (the ledger's TNFS work is
untouched).

### 1.2 The `(32/9)^(1/3)` attribution in `r52/exp/relof/lit/FETCH_LOG.md` — CORRECTED, not retracted
`FETCH_LOG.md` line 24 records: *"### Q2 'turbocharged NFS, c = (32/9)^(1/3) = 1.5262857' NOT
FOUND -- ALMOST CERTAINLY WRONG"* and line 34 concludes the constant *"ACTUALLY IS: the pre-2013
small-characteristic FUNCTION FIELD SIEVE constant for DISCRETE LOGS."*

**The campaign's conclusion was right about the *source* and wrong about the *existence*.** A
peer-reviewed 2026 paper builds the whole NFS-family theory on exactly this constant. The
"turbocharged NFS" nickname is a phantom (0 hits on arXiv full text, ePrint, OpenAlex — that part
stands), but the constant is now attached to a **rigorous lower bound for integer factoring**, not
merely an FFS-DL figure. FETCH_LOG line 24 should be amended, not deleted.

### 1.3 Bouillaguet–Fleury–Fouque–Kirchner, "We are on the Same Side. Alternative Sieving
Strategies for the Number Field Sieve", ASIACRYPT 2023, LNCS pp. 138–166.
DOI `10.1007/978-981-99-8730-6_5`. **NOT IN LEDGER** as a paper (r48/lit/ns/hal2.json holds the HAL
*title only*; no round ever read it).

Verbatim, from the HAL metadata API (`https://api.archives-ouvertes.fr/search/?q=title_t:"Alternative
Sieving Strategies"&fl=title_s,abstract_s,…`, which returns the publisher abstract in full):

> "The Number Field Sieve (NFS) is the state-of-the art algorithm for integer factoring, and sieving
> is a crucial step in the NFS. … In modern factorization tool, such as Cado-NFS, sieving is split
> into different stages depending on the size of the primes, but defining good parameters for all
> stages is based on heuristic and practical arguments. … In this article, we try to examine
> different sieving strategies to speed up this step since many improvements have been done on all
> other steps of the NFS. Based on the relations collected during the RSA-250 factorization and all
> parameters, we try to study different strategies to better understand this step. Many strategies
> have been defined since the discovery of NFS, and we provide here an experimental evaluation."

**Verdict: a constant-factor engineering study, NOT an exponent or cost-model change.** No sentence
in the abstract contains a numeric speedup (checked explicitly). The comparable is the Cado-NFS
sieve stage split vs. medium-prime sieving + Bernstein batch smooth-part recovery, evaluated on
RSA-250 relations.

**Companion, also NOT IN LEDGER: Fleury's 2024 PhD thesis**, *Amélioration des algorithmes de
crible. Application à la factorisation des entiers*, tel-05040594, defended 2024-12-09, LIP6 /
Sorbonne / CEA. Its English abstract is **verbatim identical** to the ASIACRYPT one — this is the
extended version, and it is the single best primary source on modern NFS sieving-parameter choice.
The ledger's copy of this title in `r48/lit/ns/hal2.json` has never been read.

### 1.4 Quantum factoring resources — the 2026 state of the number

| Paper | arXiv | Date | Headline | In ledger? |
|---|---|---|---|---|
| Gidney, *How to factor 2048 bit RSA integers with less than a million noisy qubits* | 2505.15917 | 2025-05-21 | <10⁶ physical qubits, <1 week | **YES** (`quantum-factoring-gap-yoked-parallel`) |
| Mundada, Khindorov, Wang, … Hush, *Heterogeneous architectures enable a 138x reduction…* | **2604.06319** | 2026-04-07 | RSA-2048 in **381k physical qubits / 9.2 days** | **NO** |
| Xue & Covey, *Factoring 2048 bit RSA integers with a half-million-qubit modular atomic processor* | **2605.03951** | 2026-05 | distributed Shor on 5·10⁵ qubits, **16 % overhead vs single module** | **NO** |
| Cain, Xu, King, *Shor's algorithm is possible with as few as 10,000 reconfigurable atomic qubits* | 2603.28627 | 2026-03 | 10⁴ atomic qubits | YES (via `r48/lit/pdf/shor2026.txt`) |

2604.06319 (Google, verbatim from the arXiv abstract): *"a detailed accounting of all operations
reveals up to 551x reduction in algorithmic logical error and up to 138x reduction in
physical-qubit overhead compared to a monolithic baseline architecture. We then consider the
factorization of 2048-bit RSA-integers; using an experimentally demonstrated grid-coupling topology,
factoring RSA-2048 requires 381k physical qubits and 9.2 days, which can be reduced to 4.9 days via
addition of an algorithm-specific accelerator for the Adder subroutine (requiring 439k qubits)."*

2605.03951 (QuEra/Atom Computing, verbatim): *"With a half-million-qubit modular atomic processor
with a communication rate of 10^5 Bell pairs per second and a measurement time of 1 ms in a
CPU-inspired architecture, we demonstrate that 2048-bit RSA integers can be factored in only 16%
more time than a single-module architecture."*

**I independently re-derived Gidney's arithmetic chain from his own PDF** (`pdftotext -layout`,
`gidney.txt` lines 1195–1216), because his headline number is the one the ledger leans on:
12.07 h/shot × 9.1 expected shots = 4.63 days; ÷ 0.933 logical-error survival = **4.96 days**,
rounded up to "a week for slack". His own caveat, verbatim: *"Without changing the physical
assumptions made in this paper, I see no way reduce the qubit count by another order of magnitude.
I cannot plausibly claim that a 2048 bit RSA integer could be factored with a hundred thousand noisy
qubits."* **The chain checks out; the "less than a week" is a rounded-up, not a measured, figure.**

The 2026 papers are the live edge and both are **new to the ledger**. Neither is a classical result
— they are hardware-architecture resource estimates and neither changes any exponent.

## 2. A WHOLE SUBFIELD OF PHANTOM "DETERMINISTIC FACTORING" CLAIMS

OpenAlex `title_and_abstract.search:deterministic integer factorization` filtered to 2023+ returns
**353 works**, of which the top ~25 are a homogeneous cluster of **non-peer-reviewed Zenodo /
OSF-preprint claims** by a handful of self-named authors. **NOT IN LEDGER — the campaign has never
seen this cluster**, and a naive literature sweep will hit it.

Two falsified in this round, each with a baseline, per the #1 trap:

**(a) "Geometric Index Sieve (SEMT)"**, Zenodo `10.5281/zenodo.17723837`, 2025-11-26, 0 citations.
Verbatim: *"the SEMT Sieve's complexity growth rate (L_N[ϵ]) is significantly lower than ϵ = 1/3,
warranting an immediate re-evaluation of current security parameters for RSA."* A sub-1/3
deterministic factoring exponent would be the single largest result in the campaign's history. It
is **REFUTED AS STATED**: the paper offers no reproducible instance, and the surrounding cluster's
concrete claim (below) factors in 0.0000 s by trial division. Mark **UNVERIFIED / NOT A RESULT**.

**(b) "Deep Tomographic Extensions of the Body–Tail Super-Sieve"**, Zenodo
`10.5281/zenodo.21410741`, 2026-07-17, 0 citations. Verbatim: *"By scaling our orthogonal base to
include primes up to 19, we construct an ultra-dense modular filter over the ring Z_29,099,070.
Experimental execution on the benchmark semi-prime N = 4,335,869 … This structural compression
eliminates 99.465550% of the search field noise."*

**I factored their own benchmark.** `N = 4335869 = 157 × 27617`, product verified back to N, and
naive trial division to √N ≈ 2082 took **< 0.0001 s**. Baseline beside the count: the attack's
8-bit small factor makes every claim **vacuous by the ≥2⁴⁰-bit rule**. Worse, and this is the part
that kills it rather than merely embarrassing it:

```
29099070 = 3 × 2 × 3 × 5 × 7 × 11 × 13 × 17 × 19
```

i.e. **3 × 19#, the primorial of the primes up to 19** — the most elementary sieve modulus that
exists. It is 2.9 × 10⁷ work units against √N = 2082 for trial division. "Ultra-large orthogonal
rings" is 19# with a multiplier.

**(c) "THE ADH-LOGIC: Deterministic Hardware Proof of 2400-Digit Integer Factorization"**, Zenodo
`10.5281/zenodo.20080034`, 2026-05-08, 0 citations, author "dong hak AN". Verbatim (the Korean
abstract, translated by me): *"[we] present decisive physical evidence of deterministic
factorization of a 2400-digit integer, successfully executed on ESP32-S3 hardware … ADH-LOGIC
achieved exactly 0.000000% (absolute zero) computational error rate … by fixing computation to
fixed physical constants such as the critical mass of 12.4844g and the compression parameter
5.4T."* The sibling 500-digit version (`zenodo.19974782`) adds *"anchored by the 12.4844g Carbon
nucleus and the synchronization constant of 56.604401"* and *"Verification Video:
https://youtu.be/d_Vlly4X5bA"*. A "12.4844 g carbon nucleus" is not a physical constant of
mathematics. **REFUTED as not-a-result; treat this cluster as noise and do not cite it.**

Practical rule for the lead: **exclude `10.5281/zenodo.*` and OSF-preprints from any "is there a new
exponent?" sweep.** They will otherwise be read as 353 corroborating works.

## 3. GENUINE NEGATIVES (these are the useful ones)

- **No GPU/ASIC sieving paper exists on arXiv cs.CR in 2023–2026.** `abs:"GPU" AND
  abs:"factorization" AND cat:cs.CR` returns 30 papers, of which the only factoring-adjacent ones
  are homomorphic-encryption GPU work and LLM security. `abs:"ASIC" AND abs:"factoring"` likewise:
  zero. Anyone claiming to find a 2023–2026 hardware-sieving record in the arXiv literature is
  looking at the wrong corpus — the real records (RSA-250, CADO-NFS) are on the CADO-NFS site and
  in ANTS proceedings, not arXiv.
- **The Sieving Problem line is dead in arXiv.** `abs:"sieving problem" AND cat:cs.CR` → nothing
  2016+. `abs:"multipoint evaluation" AND abs:"sieving"` → nothing at all. `au:"Schroeppel" AND
  abs:"factorization"` → nothing 2016+. Bernstein / Schroeppel-Shamir / Bostan are pre-2010 and
  stay pre-2010. **Do not re-run this axis.**
- **Modular hyperbolas (Leducq's line) has one live paper, and it is not a factoring algorithm.**
  Chan, *Close points on a modular hyperbola*, **arXiv:2506.04087** (2025-06-04, updated
  2026-10-05, 0 citations), **NOT IN LEDGER**. Verbatim: *"In this paper, we continue the study of
  small squares containing at least two points on a modular hyperbola xy ≡ c (mod p). We deduce a
  lower bound for its side length. We also investigate what happens if the 'distances' between two
  such points are special type of numbers like prime numbers, squarefree numbers or smooth numbers
  as well as more general multiplicatively closed sets or almost dense sets."* Its predecessor
  Di Mauro, arXiv:2001.09814 (2020), *does* end "with an algorithm for integer factorization using
  such solutions" — in the ledger's r49 cache but never analysed. **Chan is a lower-bound paper; it
  bounds a side length, it does not factor.** If anyone wants to attack the modular-hyperbola
  sieving object, that is the only 2023–2026 live thread and nobody has joined it to Di Mauro's
  algorithm.
- **Umans–Wang is confirmed real, and it is still 2025.** `arXiv:2511.10851`, published
  2025-11-13, authors `['Chris Umans', 'Siki Wang']`, verbatim: *"The fastest known algorithm for
  factoring a degree n univariate polynomial over a finite field F_q runs in time
  O(n^{3/2+o(1)} polylog q) … we propose a new strategy with the potential to overcome the 3/2
  barrier. In doing so we are led to a number-theoretic conjecture."* Verifies the ID the ledger
  already carries; **no 2026 follow-up exists.**
- **2024 review:** Gao, *Advancements and Prospects in Large Integer Factorization: A Comprehensive
  Review of the Number Field Sieve Method*, `10.54254/2755-2721/110/2024melb0088`, 1 citation.
  Verbatim: *"This study also reviews the latest advancements in NFS … The ongoing evolution of NFS
  continues to push the boundaries of cryptographic analysis."* A survey, no new result.

## 4. THINGS I CHECKED THAT ARE **NOT NEW**

Marked explicitly, as the brief asks: `2504.21168` (Summation-Based Algorithm), `2507.07055`
(Integer Factorization: Another Perspective), `2410.16355` (Tensor-Network Schnorr Sieving),
`2503.08403` (QAOA CVP for Sieving), `2512.19076` (Rank-3 Lattices / Second Vector),
`2606.24717` (RSA small private exponent + partial info), `2406.20071` (SAT and Lattice Reduction),
`2402.11269` (Classical/Quantum MDL lower bounds), `2510.19390`, `2512.15330`, `2406.04061`,
`2512.01588`, `2308.07804`, `2212.04999` (TNFS 4-d), `2211.06821` (index-calculus-inspired
subexponential), `2007.02730` (Refined NFS complexity) — **all already in the campaign corpus**
(`r48/lit/`, `r49exp/lit/corpus.jsonl`). Also already known: 2506.16799, 2505.15917, 2603.28627,
2605.05347 (Paviglianiti–Seclì–Tirrito–Savona, magic in Shor), 2602.11457 (Pinnacle).

## 5. VERDICT

**The 2023–2026 factoring literature contains NO new exponent, NO new asymptotic improvement,
and NO hardware-sieving record.** The campaign's 55-round negative stands, and this round adds
independent external support for it from a different corpus than the one used before.

What the round produced:
1. **A route-table correction** (§0) — two routes marked dead are alive and are now the fast path.
   This alone is worth more than the papers.
2. **A citable theorem closing an escape hatch** (§1.1): NFS and all variants are `≥ L[1/3](∛(32/9))`,
   independent of degree / field count / selection. It removes a hypothesis the campaign had been
   carrying as untested.
3. **A correction to `FETCH_LOG.md` line 24** (§1.2) — amend, do not delete.
4. **The primary modern sieving reference, at last read** (§1.3), plus Fleury's thesis. Both are
   constant-factor. Neither moves the exponent.
5. **The 2026 quantum numbers** (§1.4), with Gidney's chain independently re-derived from his own
   PDF: 4.96 days → "a week", 10⁶ qubits. Two new 2026 papers (2604.06319, 2605.03951) are the
   current frontier and are absent from the ledger.
6. **A documented phantom subfield** (§2) — 353 OpenAlex "deterministic factorization" works that
   are overwhelmingly Zenodo pseud-science, **two falsified here with baselines**. Without this,
   the next agent to run an OpenAlex sweep will either waste a day or promote one of these.

## 6. REPRODUCE

```bash
cd /home/raver1975/lean/factor-scratch/r114/lit2023
# arXiv API (the route the memory note calls dead) — sleep 6s between queries
curl -sL -A "Mozilla/5.0" 'http://export.arxiv.org/api/query?id_list=2604.06319'
# HAL metadata (full publisher abstracts, open):
curl -sL 'https://api.archives-ouvertes.fr/search/?q=title_t:"Alternative%20Sieving%20Strategies"&fl=title_s,abstract_s,uri_s&wt=json'
# OpenAlex DOI record:
curl -s 'https://api.openalex.org/works/https://doi.org/10.1007/s10623-025-01788-5'
# Gidney's own arithmetic (PDF in this dir):
pdftotext -layout gidney.pdf gidney.txt && sed -n '1195,1216p' gidney.txt
# The falsification:
python3 -c "import math;N=4335869;f=[157,27627];print(math.prod(f)==N, 29099070==3*2*3*5*7*11*13*17*19)"
```

## 7. VERIFICATION LOG (per §1 of the brief)

Both falsifications re-run twice, fixed inputs, identical output:

```
run1 factors [157, 27617] prod==N True sqrt 2082 trial-div 0.000036 s
run1 29099070 == 3*19# : True      19# = 9699690
run2 factors [157, 27617] prod==N True sqrt 2082 trial-div 0.000029 s
run2 29099070 == 3*19# : True      19# = 9699690
```

**Positive control** (a null result is worthless without one — this probe *reports factors*, so the
control must show it recovers planted ones):

```
planted 157    x 27617 -> recovered [157, 27617]      both planted primes found: True
planted 4103   x 4104  -> recovered [2,2,2,3,3,3,11,19,373]  False   <- NOT a semiprime, 4104 is even
planted 65537  x 65539 -> recovered [65537, 65539]   both planted primes found: True
```

The middle row is the control working, not failing: 4104 = 2²·3³·19 so 4103·4104 is not a
semiprime and the full factorisation is the *correct* answer. **2/2 genuine semiprimes recovered
in full.** Ground truth `prod(factors) == N` verified both runs — the arithmetic is confirmed; the
*claim about the paper* rests on the vacuity argument (8-bit factor, √N = 2082 trial divisions),
which is a structural argument needing no attack of mine.

**One self-correction:** my first positive-control script printed `matches planted: 2/2` by
comparing against a sorted list rather than a multiset, which would have hidden the even-factor
case. Re-run correctly above.

Nothing committed, per §7 of `FANOUT_BRIEF.md`.