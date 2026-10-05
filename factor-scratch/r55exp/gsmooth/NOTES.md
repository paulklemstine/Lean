# Round 55 — GSmooth: verifying arXiv:2601.11131 and mapping its regime

**2026-10-04. Work in `/home/raver1975/lean/factor-scratch/r55exp/gsmooth/` only.
No exponent beaten, no modulus of cryptographic interest factored (all N < 3000 < 2^12).**

---

## 0. VERDICT UP FRONT

1. **The paper EXISTS. It is NOT a phantom.** Round 54's flag was a **false
   positive**, and I can say exactly why (see §1.3). It is the **16-times-cited**
   ID of the directory, correctly attributed.

   > **David Harvey and Markus Hittmeir, "Deterministic methods for finding
   > elements of large multiplicative order", arXiv:2601.11131v2 [math.NT],
   > v1 16 Jan 2026, v2 5 Jun 2026, 13 pp.**

2. **The brief's author list was WRONG and must not be propagated.** The task
   prompt attributes it to "Mihir Bellare, Surya Devadasvuni, David Heath" and
   to "Daniel J. Bernstein". **Neither appears anywhere.** `grep -i bellare`
   over the entire `Catalog/` returns **zero files**; `grep -i bernstein` over
   the paper's reference list returns **zero**. Harvey & Hittmeir are the real
   authors. This is a *second* instance in this programme of a brief
   laundering a guessed attribution into a checked-looking verdict — and it
   ran the other way, so it is worth recording as such.

3. **THE THEOREM (Theorem 1.1, p.3, quoted verbatim from the rendered page):**

   > **Theorem 1.1.** *There exists an algorithm with the following properties.
   > It takes as input integers `N ≥ 3` and `D ≥ 1` with `D < N − 1`. It outputs
   > either some `α ∈ Z*_N` with `ord_N(α) > D` or a nontrivial divisor of `N`.
   > Its time complexity is*
   > `O( D^{1/2} log D / (log log D)^{1/2} · log N )`  — (1.2)

   * **Assumed about N's factorization: NOTHING.** No smoothness of `p−1`, no
     prime forms, no promise, no ERH. This is the headline.
   * **Cost:** polynomial in `log D` and `log N`; **exponential in `log N`**
     (`D^{1/2}` with `D` up to `N`). It is a *deterministic* result, not a
     polynomial-time-in-`log N` one.
   * **"Large order" means:** `ord_N(α) > D`, for a target `D` the caller picks.
     `D` is a free input, not a quantity derived from `N`. **That is the whole
     point** — predecessors needed `D ≥ N^{2/5}`, then `N^{1/4+o(1)}`, then
     `N^{1/6}`; this needs nothing.
   * **Preconditions checkable without factoring:** yes, trivially — the only
     input requirements are `N ≥ 3` and `1 ≤ D < N−1`. There is no hypothesis
     to test. (Contrast the `D ≥ N^{1/6}` regime, where a *promise* was needed.)

4. **REGIME: TOTAL. There is no smoothness threshold, because there is no
   structural family.** This is the direct answer to Part 3 and it is the
   opposite of what the brief anticipated. The method does not degrade outside
   a family — it was never inside one. §3 develops this.

---

## 1. CITATION VERIFICATION

### 1.1 arXiv API — exists, with full metadata

`curl "http://export.arxiv.org/api/query?id_list=2601.11131"` → HTTP 200,
`opensearch:totalResults = 1`. Raw response saved as `arxiv_2601.11131.xml`:

```
<entry>
  <id>http://arxiv.org/abs/2601.11131v2</id>
  <title>Deterministic methods for finding elements of large multiplicative order</title>
  <updated>2026-06-05T05:04:50Z</updated>
  <published>2026-01-16T09:45:56Z</published>
  <arxiv:comment>13 pages; slightly improved main complexity bound</arxiv:comment>
  <category term="math.NT" scheme="http://arxiv.org/schemas/atom"/>
  <author><name>David Harvey</name></author>
  <author><name>Markus Hittmeir</name></author>
</entry>
```

This **independently confirms the date pair the corpus asserts** (v1 16 Jan 2026,
v2 5 Jun 2026) in `RESEARCH.md:4573`.

### 1.2 OpenAlex — independent second source, agrees

`https://api.openalex.org/works?filter=doi:10.48550/arXiv.2601.11131` → HTTP 200,
`count = 1`:

```
id        = https://openalex.org/W7124762060
title     = Deterministic methods for finding elements of large multiplicative order
authors   = ['David Harvey', 'Markus Hittmeir']
date      = 2026-01-16     type = preprint     cited_by_count = 0
host      = arXiv (Cornell University)
```

`cited_by_count = 0` is OpenAlex's live count; the Catalog's 16 citations are
internal to this corpus and are not indexed there. Two independent registries,
zero disagreement.

### 1.3 WHY ROUND 54 PRODUCED A FALSE PHANTOM FLAG — root cause found

This is the useful part of the negative result. Round 54's cached fetch is
`factor-scratch/r54exp/weights/harvey_abs.html`, and its first line reads:

```
[2010.05450] An exponent one-fifth algorithm for deterministic integer factorisation
```

**That is a different paper** — Harvey's `N^{1/5}` paper (arXiv:2010.05450),
which *is* real and *is* in the reference list as `[Har21]`. Round 54 evidently
ran a sweep, and the artifact it kept is a fetch of the **wrong arXiv ID**. The
sweep then reported `2601.11131` as unverifiable. **The ID was never actually
tested.** This is the "a harness that works is not a harness that measures"
failure in its purest form: the harness returned HTTP 200 and a real abstract,
so it reported success, while the *target* was never contacted.

Corroboration that the ID was already known-good inside the corpus:
`Round53_CatalogMine.md:109` — *"**All 82 arXiv IDs checked: no off-discipline
IDs**; ... `2601.11131` ✓."* Round 53 verified it; Round 54's sweep
un-verified it. **The corpus's own §1 claim about this citation is correct and
should be restored to trusted status.**

### 1.4 zbMATH — no record (expected, and NOT evidence against)

`api.zbmath.org/v1/document/_structured_search` returned HTTP 400 on both a
title query and an ID query (the endpoint wants different parameters than I
supplied). I did not get a clean zbMATH negative. **Listed under UNVERIFIED
below.** It is also *expected* to be empty: the paper is an unpublished arXiv
preprint with no MR number, so absence there carries no weight either way. The
verification rests on the arXiv API + OpenAlex + the full PDF, which is
sufficient.

### 1.5 Concurrent work — the citation chain checks out

The paper's Remark 1.2 cites concurrent work by Itamar Nir requiring
`D > exp(√(2 log N log log N))`. Fetched `2605.09592` directly:

> **Itamar Nir**, *"Deterministically finding an element of large order in
> `Z*_N`"*, arXiv:2605.09592, published 2026-05-10.

Its abstract states the same `D > exp(√(2 log N log log N))` hypothesis, running
time `O(D^{1/2+o(1)})`, and independently credits Harvey–Hittmeir. **Real, and
strictly weaker** — exactly as Remark 1.2 says.

Also verified as real: `[GFHP25]` = ePrint **2025/1004**, "On Factoring and Power
Divisor Problems via Rank-3 Lattices and the Second Vector", Yiming Gao, Yansong
Feng, Honggang Hu, Yanbin Pan — fetched from eprint.iacr.org, matches the
reference-list entry. The `N^{1/4+o(1)} → N^{1/6}` chain (Hittmeir 2018 →
GFHP 2025 → Oznovich–Volk SODA 2026 → **dropped**) is as the paper describes.

---

## 2. THE THEOREM, from the source

Read from the **full 13-page PDF**, `hh2601.pdf` (412 KB, `pdfinfo` confirms
13 pp., "arXiv GenPDF (tex2pdf:a6404ea)"), text at `hh2601.txt`. **Every formula
below was checked against a rendered page image**, because `pdftotext` silently
drops superscripts — see §5, my most serious error.

### 2.1 Theorem 1.1 (p.3) — verbatim

Quoted in full in §0.3 above. Bounds (1.1) (p.3, the 2018 predecessor) and
(1.2) (p.3, Theorem 1.1) differ by one `log N → log D`; the paper explains this
was a referee's observation tightening the Turing-model analysis of Sutherland's
order-finding (Lemma 2.1, p.6).

### 2.2 Three consequences the authors state (p.4)

- **Never returns "N is prime."** If `N` is prime it always returns `α` with
  `ord_N(α) > D` — so it solves the large-order problem as originally posed,
  even for small `D`. (For `D ≥ N^{1/2+ε}` this was already known via
  primitive roots in `O(N^{1/4+ε})`, Shparlinski.) For very small `D` the
  runtime can be **below AKS primality testing**.
- **"In the context of any deterministic factoring algorithm that runs in
  exponential time, finding elements of large order should no longer be
  considered a bottleneck, regardless of the exponent."** ← this is the sentence
  the Catalog leans on, and it is exact.
- **Beats the heuristic route** whenever `D ≪ L_N[1/3, 2(64/9)^{1/3}]`.

### 2.3 The mechanism, and where smoothness actually enters

The proof never assumes `p−1` is smooth. It **manufactures** a counting
constraint:

- Loop over `β = 2,3,…,B`, `B = ⌈D^{1/3}⌉` (line 4), maintaining `M = lcm` of
  the orders found, with `M ≤ D` (line 16).
- If no factor and no large order turns up, then for **every** `β ≤ B`,
  `β^M ≡ 1 (mod p)` for every prime `p | N`. By multiplicativity this holds for
  **every `B`-smooth integer `n ≤ p`**, not just the `β`'s.
- Since `n^M ≡ 1 (mod p)` has at most `M` solutions and `p` is prime:
  **(3.2) `Ψ(p,B) ≤ M`**, where `Ψ(x,y)` counts `y`-smooth integers `≤ x`.
- Konyagin–Pomerance (Lemma 2.4, p.7): `Ψ(x,y) ≥ x/(log x)^{log x/log y}`
  ⇒ `p ≤ Z` for `Z` from line 17. Then trial division along `kM+1` finishes.

**So smoothness is a *tool*, not an *assumption*.** The paper uses a lower bound
on the density of smooth integers to bound `p` from above. This is the single
most important structural observation for Part 3.

### 2.4 Algorithm 3.1 (p.8) — transcribed and tested

Full transcription in `final.py::alg`. Line 3 is `if 2^D < N then return α := 2`
(**not** `2D < N` — see §5.1). A faithful end-to-end run over **all 40 377
pairs** `N ∈ [3,3000) × D ∈ {1,2,3,5,8,13,21,34,55,89,144,233,377,610}`:

- **40 352 valid outputs**, verified independently (`ord_N(α) > D`, or
  `1 < d < N` and `d | N`) — sample count printed beside the verdict.
- **19 "invalid"**, all at **prime `N < 1201`**, and in **every** case the
  returned `d` **equals `N` itself**. That is line 19 firing, which the paper
  says *"is never reached"* (p.8 margin note).
- **Composite `N`: 0 failures.**

**Interpretation — and I am careful here.** This is *not* a counterexample. The
paper's line 1 removes `N < N_0` via a lookup table, and every one of my 19
failures is a small `N`. So the observation is consistent with the theorem, and
what it actually establishes is a **lower bound on the paper's own unspecified
constant: `N_0 > 479`** (and in fact `> 1201`, the largest failing `N`).
I flag it because `N_0` is never given a value, so the theorem as printed is
not checkable at small `N` without it.

**Negative controls (must fire, and do):** deleting the line-3 guard → 20
invalid; returning a bogus divisor → 33 654 invalid. The detector discriminates.

### 2.5 The crux, (3.5), tested — and it *is* asymptotic

The proof's load-bearing step is **`M < Z̃/((log Z̃)^{log Z̃/log B}) < 4M`** with
`Z̃ = 2M·(log 2M)^{(log 2M)/(−1+log B)}` (p.8 line 17, p.9 (3.5)/(3.6)).
`M` is constrained by `M ≥ Ψ(p,B) ≥ B ≥ 4` (p.9). Testing `log M < log KP < log 4M`
over `M ∈ [B,D]`:

| `D = 10^e` | `B = ⌈D^{1/3}⌉` | (3.5) holds for all `M ∈ [B,D]`? |
|---|---|---|
| 10² … 10²⁰⁰ | 0.67 … 66.7 | no |
| **10⁸⁰⁰** | 266.7 | **yes** |
| 10³²⁰⁰ | 1066.7 | yes |
| 10¹²⁸⁰⁰ | 4266.7 | yes |

This **confirms rather than contradicts** the paper: it says *"for sufficiently
large D"* and introduces absolute constants `N_0, D_0` (p.7) precisely because
the estimate is asymptotic. My first two scripts reported this as "FAILS" — that
was **my error** (§5.2), not a paper defect.

---

## 3. PART 3 — HOW WIDE IS THE REGIME? (the scientific question)

### 3.1 The brief's premise is false, and that is the finding

The brief asks: *"is there a smoothness threshold on `p−1` and `q−1`, and if so
what is it?"*

**There is none. There is no smoothness threshold on `p−1`, because
Theorem 1.1 imposes no hypothesis on `p−1` at all.** Not a weak one, not a
`B`-smooth one, not a promise. The `B`-smoothness in the proof is over the
*integers we choose to enumerate* (`2,3,…,B`), used as a counting device; it
says nothing about the factors of `N`.

The predecessor chain is the *whole* history of this question being asked and
answered, and it is quoted accurately on p.3:

| result | hypothesis on `D` |
|---|---|
| Hittmeir 2018 `[Hit18, Alg. 6.2]` | `D ≥ N^{2/5}` |
| Gao–Feng–Hu–Pan 2025 `[GFHP25, Lem. 3.5]` | `D ≥ N^{1/4+o(1)}` |
| Oznovich–Volk 2026 `[OV26, Thm. 1.1]` | `D ≥ N^{1/6}` |
| Nir 2026 `[Nir26]` | `D > exp(√(2 log N log log N))` |
| **Harvey–Hittmeir 2026 (Thm 1.1)** | **none** |

Each row is a *relaxation*, driven by better control of how many consecutive
`β` share an order `m` (`O(√m)` instead of `m`). The final step is different in
kind: it removes the hypothesis by **counting smooth integers** instead of
counting consecutive elements. So the answer to "how far does it extend as
structure is relaxed" is: **it was never restricted, and the trick that achieves
this is switching which object you count.**

### 3.2 Does it beat NFS in its own regime? — subsumed, and here is the arithmetic

**This is the decisive question and the answer is NO, with a clean reason.**

The brief worries that smoothness of `p−1` is what NFS already exploits. It is
worse than that: **NFS subsumes the entire application.** Compare costs
(`log₂` units; corrected — see §5.3):

| `N` | `log₂ L_N[1/3,c]` (heuristic NFS) | `N^{1/10}` | `N^{1/5}` | `N^{1/4}` | `log₂ D` at crossover |
|---|---|---|---|---|---|
| 2²⁵⁶ | 46.7 | 25.6 | 51.2 | 64.0 | 68.8 |
| 2¹⁰²⁴ | 86.8 | 102.4 | 204.8 | 256.0 | 143.1 |
| 2⁰⁴⁸ | 116.9 | 204.8 | 409.6 | 512.0 | 200.5 |
| 2⁴⁰⁹⁶ | 156.5 | 409.6 | 819.2 | 1024.0 | 276.8 |
| 2⁸¹⁹² | 208.5 | 819.2 | 1638.4 | 2048.0 | 378.0 |

`c = (64/9)^{1/3} = 1.922999`.

Two readings:

1. **For the large-order subproblem alone**, the deterministic routine is
   cheaper than the heuristic route for all `D` below the crossover — this is
   exactly the paper's p.4 claim, and it checks out: `L_N[1/3,2c] = L_N[1/3,c]²`,
   so *"D ≪ L_N[1/3,2c]"* is *identical* to *"D^{1/2} ≪ L_N[1/3,c]"*.
2. **For factoring**, NFS at `L_N[1/3]` is subexponential and beats every
   deterministic method by a mile. At `N=2²⁰⁴⁸`: NFS heuristic `2^116.9`
   versus Harvey's deterministic `N^{1/5} = 2^409.6`.

**And within the deterministic family the order-finding cost is never the
binding constraint.** At the `D = N^{1/5}` that Harvey's `1/5` algorithm needs,
order-finding costs `D^{1/2} = N^{1/10}` — a *square root* of the `1/5` cost. At a
hypothetical `1/6` it would be `N^{1/12}`, again a square root. So the paper's
"no longer a bottleneck, regardless of the exponent" is quantitatively right,
and the bottleneck is entirely in Lehman's `(r,m)` balance.

### 3.3 The regime boundary — there isn't one, and that is the boundary

So the honest answer to Part 3 is the *shape* of the result, not a threshold:

- **Provable guarantee: total.** Every `N ≥ 3`, every `D ∈ [1, N−2)`. No
  structural promise, no degradation, no cliff. It is *wider* than every
  predecessor by an unbounded margin (they needed `D` exponentially large in
  `log N`; this needs nothing).
- **Usefulness: bounded by the deterministic-factoring wall, not by this
  paper.** `1/5` stands — nobody has beaten it. Removing the order hypothesis
  removes a *precondition*; it does not move the exponent. This confirms the
  Catalog's `RESEARCH.md` verdict (`1/6` is "UNBLOCKED BUT UNACHIEVED, not
  RULED OUT") and I verified that verdict against the source rather than
  taking it on faith.
- **Where it is genuinely subsumed: by NFS, for the factoring application.**
  A negative result, expected, and the reason is structural — order-finding was
  only ever a *subroutine*, and the subroutine's cost was never the bottleneck.

### 3.4 Bernstein / classical order-finding — checked, nothing found

The brief asks about Bernstein on enumerating smooth integers, and whether
large-order finding is equivalent to BSGS/Phragmén–Strassen/Pollard-ρ.

- **Bernstein is not cited in this paper** (`grep -i bernstein` over the
  reference list: **0 hits**). OpenAlex author search for smooth-number
  enumeration under D. J. Bernstein returned **no relevant hits** (the matches
  are cardiac-blood-flow papers from a name-collision author, which I discard).
  **I did not locate a Bernstein result on the cost of enumerating smooth
  orders, and I am not going to assert one.** Listed UNVERIFIED.
- **Relation to classical order-finding — this one I *can* answer from the
  source.** The paper's own framing (p.3, and the abstract) is that the 2018
  algorithm's cost is *"asymptotically the same as the cost of computing the
  order of a single element using Sutherland's optimisation of the classical
  babystep-giantstep method"*, and Lemma 2.1 gives exactly that,
  `O(r^{1/2}/(log log r)^{1/2} · log N)` for `r = min(m,D)`. **So
  large-order *finding* is not weaker than classical order-*computation* — it
  costs the same as computing one element's order.** That is the honest
  statement, and it is stronger than "equivalent to BSGS": finding a
  large-order element costs about one BSGS order computation, which is why the
  subroutine stopped being a bottleneck.

---

## 4. WHAT IS NOT DETERMINABLE FROM HERE

- **zbMATH**: no clean query succeeded (HTTP 400 both attempts). No MR record
  expected for an unpublished preprint; carries no weight either way.
- **`N_0`, `D_0`**: the paper's absolute constants are **never given a value**.
  They are the escape hatch for everything asymptotic, and without them the
  theorem cannot be checked at small `N` or `D`. My sweep gives `N_0 > 479`
  (empirically `> 1201`) and suggests `D_0` is astronomically large (§2.5) —
  but these are *my* lower bounds, not the authors'.
- **Whether `D_0 ≥ 10^800`** — my (3.5) threshold is where the *bound* starts
  working in exact arithmetic; it is not a claim about the authors' constant,
  and small-`D` behaviour may be fine via line 1/line 3.
- **SODA 2026 proceedings** (`[OV26]`, pp. 6379–6391): not independently
  fetched; the paper's citation of it is plausible and the `N^{1/6}` claim is
  consistent with the p.3 narrative, but I did not read that paper.
- **Bernstein's smooth-integer enumeration work**: not located (§3.4).
- **Referee reports**: the v1→v2 improvement is attributed to "an anonymous
  referee"; not checkable.
- **Any RSA-scale instance.** Out of scope by instruction, and nothing here
  needed one.

## 4b. UNVERIFIED (listed separately, as required)

| item | status |
|---|---|
| zbMATH record for 2601.11131 | API query failed (HTTP 400); no record expected |
| Oznovich–Volk, SODA 2026, pp. 6379–6391 | cited by HH26; not independently fetched |
| Konyagin–Pomerance `[KP97]` §2 Thm 1 (the `Ψ` bound) | **verified empirically instead** — 50/50 admissible points, exact counts (`final.py[A]`); the tightest true/bound ratio is 2.303, so the bound is valid but loose |
| Burgess `[Bur62]` `g(p) ≪ p^{1/4+ε}` (Lemma 2.5) | not independently checked; used only for the `D > N^{9/10}` corner |
| Bernstein on enumerating smooth integers | searched, not found; no claim made |
| `N_0`, `D_0` values | never stated in the paper |

---

## 5. MY OWN ERRORS — recorded prominently

I made **five** substantive errors. Three were caught only because I insisted on
controls or on reading the rendered page. None of them are defects in the paper.

### 5.1 I nearly reported a nonexistent error in Algorithm 3.1 line 3 — `pdftotext` dropped a superscript

`pdftotext` rendered line 3 as `if 2D < N then return α := 2`. I tested it,
found counterexamples (Mersenne primes `N=2^k−1` give `ord_N(2)=k`, and with
`2D<N` the claimed `ord>D` fails), and had a "paper error" 11 instances deep and
including `N=2¹²⁷−1`. **It was my extraction that was wrong.** The rendered page
image (`pg-08.png`, read directly) shows the line is

```
3: if 2^D < N then return α := 2.
```

and `2^D < N` ⟺ `D < log₂N`, which makes the line correct (and matches the p.7
note *"after line 3 we have `D ≥ log₂ N`"*). Two independent `pdftotext`
invocations agreed with each other and both were wrong — **agreement between
extraction tools is not evidence.** This is the same lesson as the OCR note in
memory, in a new costume: **superscripts vanish silently.**

### 5.2 I "refuted" the crux (3.5) by testing outside its domain

My first two scripts reported `(3.5) never holds`. Cause: I sampled `M` values
with `M < B`, which the paper explicitly excludes (p.9: `M ≥ Ψ(p,B) ≥ B ≥ 4`),
and I read an asymptotic claim as universal. Restricted to `M ∈ [B,D]` and
scanning for the threshold, (3.5) holds for `D ≥ 10^800` — **consistent with the
paper's "sufficiently large D"**, and the threshold is a real, reportable number.

### 5.3 I scored a one-way implication as a biconditional

Experiment [C] reported "6 violations" of (3.2). (3.2) is
`antecedent ⇒ consequent`; I tested `antecedent == consequent`. Rescored
correctly: **8/8** where the antecedent holds. The 6 "violations" were all cases
where the antecedent was *false* and the consequent happened to be false too —
no information.

### 5.4 Two malformed crossovers, one of them silently constant

My first bisection never expanded its bracket and returned `D_cross = 2^{1.0}`
for every size. My "fix" added a `hi > 2^60` cap that made it return
`2^{61.0}` for every size — **a plausible-looking constant across all columns,
which is exactly the shape a real answer has and exactly how a bug hides.** The
`log₂ D_cross` column only became monotone in `bits` after bisecting in
**log-space** with a bracket that cannot truncate. *A perfectly smooth table is
not a verified table.*

### 5.5 A Dickman-ρ solver I never calibrated until after printing results

I wrote a recursive ρ, hit `RecursionError`, then wrote an Euler solver and
**printed its output before calibrating it**. Calibrated, it was wrong by
**2.0 × 10⁴ relative error at `u=6`** — and my first "calibrated" version was
wrong by 130% at `u=2`, where `ρ(2)=1−log 2` is checkable in my head. Both were
caught only because I ran known-value checks. I then **deleted the solver
entirely**: the decisive question (does the *true* `Ψ(Z̃,B)` exceed `M`?) is
answered exactly by brute-force counting at small scale, which is what `final.py`
does. *Never ship an uncalibrated numeric kernel.*

---

## 6. PROVENANCE — every source fetched

**Fetched and read (primary):**

| source | what I took from it |
|---|---|
| `export.arxiv.org/api/query?id_list=2601.11131` | existence, authors, title, dates, 13pp, abstract → `arxiv_2601.11131.xml` |
| `https://arxiv.org/pdf/2601.11131v2` | **full 13-pp PDF**, 412 KB → `hh2601.pdf`; text → `hh2601.txt` |
| rendered page images p.3, p.4, p.7(implicit), p.8, p.9 (`pdftoppm -r 200`) | **verbatim Theorem 1.1, Algorithm 3.1, eq (3.2)(3.4)(3.5)(3.6), the `2·(64/9)^{1/3}` constant** — superscripts verified against pixels |
| `api.openalex.org/works?filter=doi:10.48550/arXiv.2601.11131` | independent confirmation of authors/date → `oa.json` |
| `export.arxiv.org/api/query?id_list=2605.09592` | Nir's concurrent paper, real, strictly weaker → `nir.xml` |
| `eprint.iacr.org/2025/1004` | GFHP25 real, matches reference list |
| `factor-scratch/r54exp/weights/harvey_abs.html` | **root cause of the false phantom flag** (§1.3) |
| `Catalog/…/RESEARCH.md`, `Round50`, `Round53`, `Round98`, `Round47` | the corpus's claims about this citation, checked against source |

**Computed here (all local, N < 3000 < 2¹², no cryptographic instance):**

| file | what it does |
|---|---|
| `final.py` | **the deliverable experiment.** [A] Lemma 2.4 vs exact `Ψ`; [B] crux (3.5) with the `M≥B` domain; [C] (3.2) one-way; [D] costs; [E] end-to-end Algorithm 3.1 over 40 377 pairs + 2 negative controls. Seeded, run twice, `diff` **identical**, content hash `3bfb84c1cca51e77…` |
| `cross.py` | log-space crossover bisection (the corrected [D]) |
| `exp_hh26.py`, `exp_hh26_v2.py` | **superseded, kept as the record of my §5.2–5.4 errors** |

**Discipline notes.** WebSearch was not used at any point. Every arXiv ID in
this file was obtained by *fetching* an API response, never from memory — which
is how the brief's Bellare/Devadasvuni/Heath attribution was caught: I fetched
first and the names simply were not there. No sub-agent was dispatched, so no
brief could launder a guess. All moduli are locally generated and small, and the
analytic content of Part 3 is, as the brief anticipated, mostly analytic.

---

## 7. BOTTOM LINE

- **arXiv:2601.11131 is REAL.** Harvey & Hittmeir, Jan–Jun 2026. Round 54's
  phantom flag is **withdrawn**; it arose from fetching the wrong ID
  (`2010.05450`), and Round 53 had already verified `2601.11131` correctly.
- **The theorem:** given any `N ≥ 3` and any `1 ≤ D < N−1`, deterministically
  return `α` with `ord_N(α) > D` **or** a nontrivial factor, in
  `O(D^{1/2} log D/(log log D)^{1/2} · log N)` bit operations. **No hypothesis
  on `N`'s factors whatsoever.** Checkable without factoring, because there is
  nothing to check.
- **The regime is TOTAL** — no smoothness threshold on `p−1` exists, so the
  question as posed has a negative answer. Smoothness is the paper's *proof
  tool* (`Ψ(p,B) ≤ M`), not an assumption.
- **But it does not beat NFS, and it does not beat `1/5`.** It is subsumed for
  the factoring application, and within deterministic factoring it was never
  the bottleneck (`N^{1/10}` against a `N^{1/5}` target). Its real content is
  that it converts a *precondition* into a *non-issue*: `1/6` remains
  **unblocked but unachieved**, exactly as `RESEARCH.md` already concluded —
  a conclusion I have now checked against the source rather than inherited.
- **Five errors of my own, recorded above.** The instructive one: `pdftotext`
  silently dropped the `^` in `2^D < N`, and I built an eleven-instance
  "refutation" on it before reading the page image.
