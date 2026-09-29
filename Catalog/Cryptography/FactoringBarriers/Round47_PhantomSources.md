# Round 47 part 3 — two record corrections: a phantom "live axis" and a heuristic mislabelled rigorous

**2026-09-29. Both are negative results, and both remove a source of support the record was
leaning on. Neither retracts anything in `Round47_MordellWeil.md`.**

---

## 1. THE HANDOVER'S "ONLY LIVE AXIS" RESTS ON A CITATION THAT DOES NOT EXIST

`Round46_Handover.md` §2 is headed **"THE LIVE DIRECTION: multivariate factoring"** and opens:

> "This is the one place where methods are actually being made, and it is a different problem
> from everything above."

Its load-bearing citation is:

> **Kaltofen–Kurban–Lenstra, "On the randomized deterministic complexity of factoring
> polynomials over finite fields", Inf. Process. Lett. 80 (2001) 57–64** — polynomial time
> for SPARSE polynomials over `F_q`.

**That paper does not appear to exist, and there is positive evidence against it, not merely a
failure to find it.**

- **Crossref title search**: no record of any paper of that title by those authors.
- **Decisive**: the *complete* Crossref deposit for *Information Processing Letters* 2001 was
  pulled (`total-results 145`, fetched **145/145**) and every article in volume 80 listed.
  Pagination is contiguous, and **pp. 57–64 are already occupied**:
  - pp. 51–58 — "Impossible futures and determinism", Voorhoeve & Mauw, DOI
    `10.1016/S0020-0190(01)00217-4`
  - pp. 59–65 — "Equivalence of recursive specifications in process algebra", Ponse & Usenko,
    DOI `10.1016/S0020-0190(01)00218-6`

  A paper at 57–64 would **overlap both**, and both neighbours are process-algebra papers, not
  algebra.
- **No Kaltofen–Lenstra coauthored paper and no Kaltofen–Kurban coauthored paper appears
  anywhere in Crossref at all.**

**Likely true source, NOT verified:** Kaltofen & Shoup, "Subquadratic-time factoring of
polynomials over finite fields", *Mathematics of Computation* **67** (1998) 1179–1197, DOI
`10.1090/S0025-5718-98-00944-2` (Crossref-confirmed to exist). The opening was not read; this
is a hypothesis, not a substitute citation.

**Consequence for the record.** §2's claim that there is "no multivariate analogue of the
`3/2` barrier" rests on the *existence of a polynomial-time sparse factorisation* being
attested. With that citation gone, §2 is **unmoored** — not refuted, but no longer evidenced.
`Round46_Handover.md` §5 item 1 ("Attack factor-sparsity bounds; the operative cost is
individual degree `d`") inherits the same defect.

**This is the fifteenth fabricated or misattributed source in this campaign.** The prior
fourteen are listed in `Round46_Handover.md` §3 and §10.

### 1.1 A separate, verified negative: Shoup 1990 does not rescue it

**Shoup, "On the deterministic complexity of factoring polynomials over finite fields",
Inf. Process. Lett. 33 (1990) 261–267** — read from the author's own copy
(`https://shoup.net/papers/detfac.pdf`), all quotations from 200 dpi page renders because the
PDF's text layer is corrupt.

- Abstract, p. 1: *"We show that the worst-case running time of our algorithm is
  `O(p^(1/2)(log p)^2 n^(2+ε))`, which is faster than the running times of previous
  deterministic algorithms with respect to both n and p."*
- The only problem-setting sentence, p. 2 §1: *"Consider the problem of factoring a polynomial
  of degree n in `Z_p[X]` where p is prime."*

**`F_{p^k}` is excluded**, and the factorisation of `p−1` is never mentioned and is not
needed. The bound is exponential in `log p`, and **there is no sparsity parameter anywhere** —
the bound is in degree `n` alone. So the specific hypothesis this axis needed — *polynomial
time in the sparsity* — is **not** in this paper either.

## 2. ADLEMAN–DEMARRAIS IS HEURISTIC: no rigorous `L[1/3]` in print by that route

**The strongest available evidence against my own round-47 line is below** — the question was
whether a rigorous `L[1/3]` GNFS already exists via Adleman's character approach. It does
not.

**Adleman & DeMarrais, "A subexponential algorithm for discrete logarithms over all finite
fields", Mathematics of Computation 61 (1993) 1–15**, DOI
`10.1090/s0025-5718-1993-1225541-3`. (⚠️ The commonly-guessed DOI
`10.1090/S0025-5718-1993-1217493-9` is wrong; Crossref returns the one above.)

- **p. 1, abstract, verbatim:** *"There are numerous subexponential algorithms for computing
  discrete logarithms over certain classes of finite fields. However, there appears to be no
  published subexponential algorithm for computing discrete logarithms over all finite
  fields. We present such an algorithm and a **heuristic argument** that there exists a
  `c ∈ R_{>0}` such that for all sufficiently large prime powers `p^n`, the algorithm computes
  discrete logarithms over `GF(p^n)` within expected time: `c^{(log(p^n) loglog(p^n))^{1/2}}`"*
- **p. 14, verbatim:** *"Hence, overall **it appears** discrete logarithms over `GF(p^n)` can
  be computed in `L_{p^n}[1/2, 2]` expected time."* Note the hedge and the constant **2**,
  not `√2`.
- **p. 14, the open problems, verbatim** — and the first bullet is decisive:

  > *"Do there exist a `c ∈ Z_{>0}` and an algorithm for discrete logarithms over `GF(p^n)`
  > with **provable** expected running time in `L_x[1/2, c]`?"*

  **Adleman–DeMarrais list, in 1993, as an OPEN PROBLEM the very statement that would be a
  rigorous subexponential result for all finite fields.** They label their own `√2`-level
  improvements *"we believe that a running time in `L_{p^n}[1/2, 2]` is achievable for
  Algorithm I"* (p. 14) — heuristic, in their own words.

- What **is** unconditional in the paper is narrower, e.g. **p. 7**: *"For all `p, n, m ∈
  Z_{>0}` with `p` prime and `n > m`, we have `P_p(n, m) > 1/(p m n^{n/m})`."*

### 2.1 The `L[1/2,√2]` is Lovorn's, and is scoped

**p. 14, verbatim:** *"Several alternatives exist for our handling of the case `n > p`.
Lovorn's algorithm [21], which has a running time in `L_{p^n}[1/2, √2]`, covers this case."*

So `L_{p^n}[1/2,√2]` is attributed to **Lovorn**, **only for `n > p`**, and the p. 2
characterisation is *"the previously most general subexponential algorithm ... of Lovorn
[21], which computes discrete logarithms in `GF(p^n)` for `log(p) ≤ n^0.98`"* — a **restricted
regime**, not all finite fields.

**Reference [21] is not locatable.** `R. Lovorn, Rigorous, subexponential algorithms for
discrete logarithms over finite fields, Ph.D. Thesis, University of Georgia, May 1992.`
- **No Math Genealogy Project record exists for any Lovorn.**
- The UGA repository yields no record; theses of that era are typically ProQuest-only.
- **No published Lovorn paper on discrete logarithms or finite-field factoring exists** in
  Crossref, arXiv, or IACR ePrint.
- OpenAlex, Semantic Scholar, DBLP, and the general web were all blocked at the time of the
  search (rate limits / bot walls), so "not locatable" is a statement about what was
  reachable, not proof of absence.

**⚠️ The initial is `R.`, not `M.`** — verified twice, by text extraction and by reading the
rendered page at 200 dpi (`/home/raver1975/factor47/A2/suspectC/ref21_zoom2.png`). Both the
in-text citations and the bibliography print `R.`. If a downstream source says "M. Lovorn",
**that source introduced the error** — this is a sixteenth phantom, and it is worth recording
because the *name* has now propagated.

**Treat "Rigorous" in the thesis title as a title, not as an established fact.**

## 3. What this leaves standing

- **Nothing in `Round47_MordellWeil.md` is affected.** Its content is a self-contained
  derivation plus computation, not a citation.
- **A rigorous `L[1/3]` GNFS is still open**, and the two routes that might have dissolved it
  are now closed: Adleman's is heuristic in its own authors' words, and the multivariate
  alternative was resting on a phantom citation.
- **The record's own §1.3 comparison stands and is reinforced**: the deterministic `1/5` line
  and Umans–Wang's conditional `1/6` are both far behind the GNFS heuristic anyway, so the
  only way a new *method* helps is by making the GNFS rigorous, or by beating its exponent —
  and beating its exponent is believed impossible.
