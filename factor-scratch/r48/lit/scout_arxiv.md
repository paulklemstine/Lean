# Round 48 literature scout — arXiv, 2023-2026

**Scout:** one agent, 2026-10-03. **Scope:** factoring-relevant mathematics the 47-round program
has not seen. **Sources used:** arXiv API (`https://export.arxiv.org/api/query`, https only —
`http://` returns 301 and an empty body, which silently looks like "no results").
`WebSearch` was **not** used (it fabricates citations on this host).

**Every arXiv ID below was checked against the whole repo** (`grep -rl <id>` over `*.md`,
`*.lean`, `*.py`, `*.txt` at `/home/raver1975/lean`, excluding this directory): **all 13
reported IDs return 0 files.** Every ID was also confirmed to exist by an HTTP 200 on
`https://arxiv.org/abs/<id>`. PDFs were downloaded and the quotes below were extracted with
`pdftotext -layout`, with page numbers taken from the `\f` page separators.

The already-seen ID census used for the novelty check is
`/home/raver1975/lean/factor-scratch/r48/lit/_seen_arxiv_ids.txt` (57 IDs, extracted from
`Catalog/Cryptography/FactoringBarriers/`).

---

## TABLE

| arXiv ID | Year | One-line claim | Verbatim quote (page) | Verdict |
|---|---|---|---|---|
| **2211.06821** Stange | 2022 (v2) | Index calculus *modulo n* factors n in `L_n(1/2)` heuristically, `exp(O((log n)^{1/3}(log log n)^{2/3}))` with NFS relation-finding; new **rational** linear-algebra phase (kernel of a `b×(b+c)` matrix + gcd) | p.1: *"any method of finding an overdetermined system of multiplicative relations between elements of a factor base modulo n will lead to a method of factorization"*; p.2: *"Its runtime is `exp(O((log n)^{1/2} (log log n)^{1/2}))`. … The methods of [6, Section 3.1] can be adapated to find relations modulo n, which, when combined with Theorem 3.2, leads to a version of the present algorithm which runs in time `exp(O((log n)^{1/3} (log log n)^{2/3}))`."*; p.2: *"the author has been unable to find this particular variation in the literature"* | **NEW-CLOSES-SOMETHING** (negative) |
| **2402.11269** Hhan | 2024 | A lower bound for the basic index-calculus DL method in a new **smooth generic group model**: `T = exp Ω(√(log N log log N))`; author explicitly declines to claim it settles the IC wall | p.5: *"We prove that the DL algorithm must make `exp C √(log |G| log log |G|)` group operations for some constant C > 0 in the SGGM (Theorem 7.1), giving some evidence that going beyond this bound requires a new idea, as the ones in the number field sieves. **We do not claim this lower bound provides new insights or strong evidence for the index calculus.**"*; p.24 Thm 7.1: *"Let G be a cyclic group of prime order N. Let B be an integer such that B = N^{1/u} … Then, the number of group operations T of A_DL must satisfy T = exp Ω(√(log N log log N))."* | **NEW-BUT-WEAK** (self-disclaimed; still the only IC lower bound found) |
| **2301.10529** Hittmeir | 2023 | **Smooth Subsum Search**: represent QS smoothness candidates as *sums* pre-divisible by several factor-base primes, so the candidates are smaller and smoother. 1.5–10× faster than SIQS in Python, 30–70 digits | p.13: *"For inputs with 30 − 40 digits, SSS is about 5 to 10 times faster than the SIQS approaches. For inputs with 45 − 55 digits, SSS is about 2.2 to 3 times faster than sSIQS."*; p.10: *"While SSS and SIQS appear to have the same asymptotic runtime complexity, there are differences in the hidden constants"* | **NEW-BUT-WEAK** (constant-factor only, same `L` exponent) |
| **2606.24717** Urroz | 2026 | **Unconditional** Wiener improvement: a δ-fraction of the MSBs of `p+q` factors n whenever `d < n^{1/2 + δ/2}`. Continued fractions only — **no Coppersmith, no lattice** | p.1: *"allows us to factor n whenever `1/δ d < n^{1/2 + δ/2}` if we know a δ-fraction of the most significant bits of n. **The algorithm is unconditional, which is not the case in previous improvements that use Coppersmith method.**"*; p.4: *"We will only use continued fractions and hence all the results are unconditional."* | **NEW-CLOSES-SOMETHING** (partial-info axis, unconditional; see caveat below) |
| **2503.00950** Pomykała–Jurkiewicz | 2025 | Even-order EC family `E₂` over `Z_N`: separating `ν₂(ord Q_p) ≠ ν₂(ord Q_q)`, then write N in base `d` to factor in `t^{1+o(1)}`; conjecturally `L(√2+o(1), min(p,q))` | p.1: *"we … propose a factoring algorithm that ﬁnds (conjec-turally) the prime decomposition N = pq in subexponential time `L(√2 + o(1), min(p, q))`"*; p.1: *"if we know the pair (E, Q) such that `P⁺(ord Q_r) ≤ t < l_min(E, Q)` and d = max … is large in comparison to min … then we can decompose N in deterministic time `t^{1+o(1)}` by representing N in base d."* | **NEW-BUT-WEAK** (parameterised on `min(p,q)`, conjectural smoothness) |
| **2511.18198** (Regev/SORA) | 2025 | Space-optimised Regev quantum factoring: `O(n^{3/2}) → O(n^{5/4}) → O(n log n)` qubits by intermediate uncomputation, with a matching space lower bound in that model | p.2: *"A simple version of our approach reduces the space complexity from `O(n^{3/2})` to `O(n^{5/4})`, and more refined strategies—drawing inspiration from the reversible pebble game in classical reversible computing—achieve a further reduction to `O(n log n)`. **We prove that `O(n log n)` is a space lower bound within this framework and show that it is attainable, thereby establishing space optimality for our approach.**"* | **NEW-BUT-WEAK** (quantum; Shor line already closed for the program) |
| **2502.11402** Mamah | 2025 | Solving `x² + dy² = m` (Cornacchia's problem, the class-group sub-step of DLPs) reduced to **group subset sum**, beating Cornacchia for `d = polylog(m)` | p.2: *"outperform Cornacchia's algorithm for all orders of d and m. The approach to that is leveraging a new reduction of solving the Diophantine quadratic equation `x² + dy² = m` to an instance of a **group subset sum** problem."* | **NEW-BUT-WEAK** (a subroutine, not a factoring exponent) |
| **2507.07094** Chan | 2025 | Optimal `L¹`-distance lower bounds for lattice points near the centre `(√N,√N)` of the hyperbola `xy = N` — i.e. how *close* a near-factorisation sits to balanced | p.1: *"we … correct a mistake of a previous result. This turns out to be related to lattice points close to the center point `(√N, √N)` of the hyperbola `xy = N`. We establish **optimal lower bounds** for `L¹`-distance between these lattice points and the center."* | **NEW-BUT-WEAK** (structure theorem, no algorithm) |
| **2508.02818** Chan–Holmes–Liu–Villarreal | 2025 | Four close factorisations ⇒ optimal `A ≤ 0.04742…·C³ + O(C)`, via generalised Pell equations `ax²−by²=c` | p.1: *"We obtain the optimal upper bound `A ≤ 0.04742 . . . · C³ + O(C)`. The key idea is to transform the original question into generalized Pell equations `ax² − by² = c` and study their solutions."* | **NEW-BUT-WEAK** (promise structure only) |
| **2406.09360** Haddad–Koukoulopoulos | 2024 | Proves a 2002 **Arratia** conjecture: a coupling of a uniform random integer's factorisation with Poisson–Dirichlet such that `E Σ |log P_i − V_i log x| ≍ 1` (Arratia got `≪ log log x`) | p.1: *"We prove that there exists a coupling of these two random objects such that `E Σ_{i≥1} |log P_i − V_i log x| ≍ 1` … This establishes a 2002 conjecture of Arratia"* | **NEW-BUT-WEAK** (distributional, not algorithmic) |
| **2507.07055** Bansimba–Babindamana | 2025 | Survey-style reformulations: matrix decomposition with `det N = n`; bivariate small roots; Lebesgue-integral perimeter | p.1: *"we take the problem from the ring (Z, +, ·) to the ring of matrices (M₂(Z), +·) and show that this problem is equivalent to matrix decomposition … Finally, we address the problem depending on algebraic forms of factors and show that this problem is equivalent to finding small roots of a bivariate polynomial through coppersmith's method."* | **REDUNDANT** (p.7 admits the `XY < W^{1/3}` Coppersmith condition is unachievable) |
| **2504.21168** Friedlander | 2025 | Base-2 sum + base-10 representation, `O(√n)` | p.1: *"an algorithm on the order of `√n` time complexity can convert that sum to a product of two integers"* | **REDUNDANT** (`√n` ≫ `N^{1/5}`; no `√n` wall crossing) |
| **2109.09599** Mudgal | 2021 | "Δ-sieving": hypothesised `O(1)` factoring from a steady-state value of `Δ = |p−q|` | p.1: *"then, it is **hypothesized** that factorizing this composite n will take O(1) time once the steady state value is reached for any ∆ in zone 0 of some observation deck (od) with specific dial settings."* | **REDUNDANT** (every step is labelled a hypothesis; author writes *"maybe ... we may find that factorization was always in O(1), Uff!"* p.25) |

---

## WHAT EACH VERDICT MEANS HERE

**2211.06821 (Stange) — the one genuinely new structural route.** It is the only paper found
that treats the L[1/3] wall as *"the linear algebra is done over ℚ instead of ℤ/ord"*. The
mechanism is precisely: relations `∏ a_i^{e_i} = 1 (mod n)` over a factor base of `b` residues,
an overdetermined `b×(b+c)` matrix, kernel `K` of dimension `≥ c`, then `gcd` of the resulting
exponents. If the gcd is exactly `ord(a_1)` (Hypothesis 3.1, `P = 1 − 1/ζ(c+1)`), you have the
order, and the order factors n. The author's own novelty claim — *"the author has been unable to
find this particular variation in the literature"* — is on p.2. It is explicitly **slower than
GNFS**, so this is a *structural* finding, not a speedup. **But note the shape**: the paper is a
reduction, and the reduction is real; the runtime is dominated by the ℚ linear algebra, `O(b⁴ log b) poly(log n)` (p.5).

**2402.11269 (Hhan) — a lower bound, and the author disowns it.** This is the only rigorous
lower bound on index calculus found in 2023-2026, and it is worth having *as a marker*, not as a
result. The `exp Ω(√(log N log log N))` is exactly the shape of a generic-group-model bound; the
author says the proof ideas were probably already used to optimise the real algorithms.

**2606.24717 (Urroz) — the partial-info axis moved, unconditionally.** This is the most
surprising entry. Note carefully what it is and is not:
- It is a **`d`-leak attack**, not a `p`-leak attack. It needs a δ-fraction of the MSBs of
  `p+q` **plus a small `d`** (`d < n^{1/2+δ/2}`). It does **not** cross Coppersmith's `n/4`
  `p`-leak wall and should not be filed as if it did.
- What it *does* establish is that this corner is **unconditional**, whereas the literature it
  compares against (De Weger; Blomer–May; Ernst et al.) is not. p.4: *"On the other hand,
  results based on continued fractions are unconditional. … We will only use continued fractions
  and hence all the results are unconditional."*
- Self-reported worst-case behaviour is weak: p.8 Remark 3.2 concedes that with **no** side
  information the enumeration is `O(√(n^{1/2}/ℓ) · log(en))`, i.e. the leak only pays once ℓ is
  already large. The headline `512-bit, d < n^{0.3}` example requires ℓ = 200 (56 bits of `p+q`).

---

## TOP 3 THINGS WORTH AN EXPERIMENT

Ranked by (a) novelty to the program, (b) whether a code experiment can actually falsify it.

### 1. Hittmeir's Smooth Subsum Search (arXiv:2301.10529) — run it, and port the search step

This is the only *practical* new method found, and the program's 47 rounds have been entirely
asymptotic/deterministic — no QS-side implementation appears in the census. The measurement is
already published and reproducible: 1.5–2.2× at 60–70 digits, 2.2–3× at 45–55, 5–10× at 30–40,
against `sSIQS`. The bottleneck is named by the author: *"the smooth-batch procedure appears is
the bottleneck of SSS"* (p.10), and §5 lists concrete unimplemented ideas — lattice reduction,
a genetic algorithm, polynomial changes `f_α(x) = (x + d_α√N)² − αN`, and *"removing a few of the
smallest primes from S leads to a small, but consistent speedup"* (p.18).

What is testable here in an afternoon: take the existing `factor-scratch` PQ-modulus harness,
implement the subsum search, and check the rate law the program already trusts — the ratio of
smooth-finding rate to SIQS at fixed factor-base size. If SSS's advantage is a *hidden-constant*
effect, the rate ratio should be constant across digit sizes; if it grows, that is a genuine
`L`-exponent signal and would be the first one in this census. **The publishable negative is
nearly as valuable: a constant ratio kills it cleanly, and that closes a direction in one run.**

### 2. Stange's ℚ-kernel index calculus (arXiv:2211.06821) — test Hypothesis 3.1 directly

Hypothesis 3.1 says `b + c` random relations in the exponent lattice `Λ_B` generate
`Λ_B|_Si` with probability `1 − 1/ζ(c+1)`. This is a **distributional claim about a real lattice,
and it is directly measurable** — no factoring required. Build the relation lattice for small `n`
and factor bases of size `b`, sample random relation subsets, and measure the empirical index
`[Λ_B|_Si : Λ'_B|_Si]`. If the empirical rate tracks `1 − 1/ζ(c+1)` at subexponential `b`, the
hypothesis survives at the regime where the paper says it is untested (it is only *known* when
`n ≥ 8^{b/2}`, which is exponential in `b` — far from the subexponential regime the algorithm
needs). **A measured failure here is a rigorous kill of a published route, obtained by
experiment rather than by re-derivation.** The author's own toy SageMath implementation is at
`https://github.com/katestange/index-factor` (p.2), which gives a reference point.

### 3. Urroz's unconditional `p+q`-MSB Wiener (arXiv:2606.24717) — check the unconditionality claim against a real lattice attack

The claim to stress-test is *"The algorithm is unconditional, which is not the case in previous
improvements that use Coppersmith method"* (p.1) — because the same author says of the competing
Coppersmith-based attacks that their correctness *"has never been proved. Concretely, the
algebraic independence of the solutions given by the reduction algorithm in the lattice"* (p.4).
So both families rest on unproved steps and the paper's contribution is the *smaller* assumption.
An experiment can decide which is more robust: implement the continued-fraction attack on
`p+q`-MSB leaks at fixed `d` and sweep `d` against `n^{1/2+δ/2}`, with `δ ∈ {1/8, 1/4, 1/2}`,
counting base-case failures. If the continued-fraction version fails no earlier than the Coppersmith
version, the "unconditional" advantage is real and cheap; if it fails earlier, the advantage is
rhetorical. Note the program already has a rule that applies here — #497's — *"any claimed
factoring advance with `log₂(q−p) < 3n/8` is a structured-promise ARTEFACT"* — so the `δ`-sweep
must be run at realistic `Δ`, not at tuned values.

---

## UNVERIFIED — DO NOT CITE

- **`arxiv.org` HTTP (not HTTPS) API queries.** `http://export.arxiv.org/api/query` returns
  HTTP 301 with an **empty body**. Piping that to a parser produces a *parse error*, not an
  empty result. Any query script that swallows the exception will report "0 results" for every
  query. Use `https://export.arxiv.org/api/query`. I lost two query batches to this.
- **Rate limiting.** After ~20 API calls in a few minutes the API begins returning empty bodies
  with no status indication. A 60–90 s backoff restores it. Concurrent query loops will silently
  produce empty results.
- **arXiv's plain search UI drops every pre-2010 paper** (per the task brief) — not re-tested
  here, but the API route was used throughout and has no such defect, since it returned
  `math/0208038`, `cs/0703032`, `quant-ph/9503007` and `cs/0606607` without special handling.
- **No search was run against non-arXiv sources.** ACM/IEEE/Springer were not attempted (known
  403 from this host). In particular the following are **NOT** cleared and could hide relevant
  work: Math. Comp. / ANTS / ASIACRYPT-EUROCRYPT proceedings 2023-2026; OpenAlex citation
  closure forward from Stange, Hittmeir-SSS, and Urroz. **A forward citation closure on
  arXiv:2301.10529 and arXiv:2606.24717 is the highest-value unrun route.**
- **`2506.06024` (Recent Progress around Cohen-Lenstra Heuristics)** and
  **`2608.06681` (Refuting a Conjecture of Umans and Wang on Arithmetic-Progression Divisor
  Covers)** were both found by the searches and are the closest hits to priority items 1 and 3
  — the second one is a **refutation of a UMW conjecture**, which is exactly the negative-result
  category requested. **Both are already in the program's census** (`_seen_arxiv_ids.txt`
  contains both IDs), so they are not reported as new; I did not re-verify their contents.

## NEGATIVE SEARCH RESULTS (stated so they are not re-run)

These directions were queried against the arXiv API and returned **nothing** relevant to
factoring in 2023-2026:

- **Sieving on algebraic tori / theta-lattice reduction beyond LLL for factoring.** Queries
  `all:"algebraic torus" AND all:sieving`, `all:"torus" AND all:"factorization" AND all:"smooth"`,
  `all:"theta" AND all:"factoring"`, `all:"BKZ" AND cat:cs.CR` → the torus queries return 0;
  the theta query returns 352 hits, **all** representation-theory of arithmetic groups with no
  factoring content; the BKZ query returns 11 hits, all module-LWE/NTRU parameter studies with no
  NFS connection. **No 2023-2026 work on deep-BKZ applied to the NFS relation lattice was found.**
- **Function-field factoring with a better exponent.** `all:"function field sieve"` returns 7
  total hits, **the newest from 2018**; `all:"factorization" AND all:"index calculus"` returns 5
  total hits, newest 2025 and the best of them is Stange (already listed). **This subfield appears
  dormant.** Priority item 2 of the brief has no live literature on arXiv.
- **Lattice points on hyperbolas / close factorisations.** Only the two Chan papers above, both
  promise-structure theorems, no algorithms.
- **Non-standard-input factoring with threshold below `n/4` bits of `p`.** `all:"partial key
  exposure"` returns **1 total hit** (an unrelated 2026 lattice signature scheme);
  `all:"hidden number"` returns 6, all unrelated. **The `p`-leak axis is not merely unmoved — it
  appears to have no arXiv literature at all in this window**, so the "still no crossing in 30
  years" claim in `RESEARCH.md` §8.1 survives, and now also survives on an arXiv-coverage
  argument rather than only on the Boneh–Durfee-citation argument.
