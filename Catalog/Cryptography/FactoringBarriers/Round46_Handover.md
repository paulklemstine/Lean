# Round 46 — Handover

**Status: 46 rounds, ZERO methods. This is a closure document, not a result document.**

The frontier past the 1/5 deterministic factoring exponent is empty in print, and the one
conditional route to beating it improves a quantity that is already dominated. Everything below
is negative-result accounting, plus one live direction for anyone picking this up.

Scratch artifacts (NOT in git — 1.8 GB, 56k files): `~/factor-scratch/r45/axis6/hyp/`.
Nine reports there: `multivariate.md`, `lowdeg_extract.md`, `divisor_lit.md`, `lit_sweep.md`,
`d2_shift.md`, `dol_gap.md`, `boneh_finding.md`, `round46_record.md`, plus `umw/` and `dol/`.

---

## 1. What is now closed, and with what evidence

### 1.1 The 3/2 exponent for univariate polynomial factoring is STRUCTURAL, not conjectural

Kedlaya–Umans, *SIAM J. Comput.* **40**(6):1767–1802 (2011), DOI `10.1137/08073408x`, §8.1:

> "The second stage, distinct-degree factorization, has a deterministic algorithm due to Kaltofen &
> Shoup that takes `n^{0.5+o(1)} C(n,q) + M(n) log^{2+o(1)} q` bit operations"

where `C(n,q)` is the cost of **modular composition**. KU achieve `C = n^{1+o(1)}`, giving
`n^{0.5} · n^1 = n^{1.5}`. **So beating 3/2 on this route requires modular composition with exponent
< 1, which is implausible since it must read an n-coefficient input.**

Corollaries, all verified: small characteristic does not help (KU Thm 8.6 still `n^{1.5}`, and §9
states beating it "will require a new idea"); *faster* modular composition actively **hurts**,
because it is multiplied by `n^{0.5}` and KU's `n^1` is already best. Neiger–Salvy–Schost–Villard
(`n^{1.343}`, arXiv:2601.17422) would push DDF to `n^{1.843}` — and that paper makes no factoring
claim. **The KS route must be escaped, not improved.**

### 1.2 Doliskani's quantum 4/3 is an optimal balance point, derived two independent ways

Doliskani, arXiv:1807.09675, *Quantum Inf. Comput.* **19**(1&2):1–13 (2019), DOI
`10.26421/QIC19.1-2-1` — `O(n^{1+o(1)})` average, **`O(n^{4/3+o(1)})` worst case**, in bit
operations, with coherent access to a *reversible modular-composition circuit*. **OpenAlex records
0 citations**; no successor in seven years.

The 4/3 is **entirely a classical preprocessing term**, quoted as a citation in Doliskani, not
derived. With threshold `D = n^γ` the worst-case cost is `max(1+γ/2, 2−γ)`:
extraction is `√D` batched compositions at `Õ(n)`; order-finding on the residual uses
`log d ≤ (n/D)·log D`. Balancing gives **γ = 2/3, total 4/3**. Cross-check: at `D = n^{2/3}`,
`(n/D)log D = n^{1/3}·⅔ln n`, reproducing the paper's Lemma 5 verbatim. Independently, a separate
agent derived the extraction term as `n^{1+o(1)}·D^{1/2}` — the same `1+γ/2`.

**Implication:** Doliskani's `[14,§8]` is just KS-DDF with the binary search capped at `[1,D]`.
Beating 4/3 needs both terms improved at once.

### 1.3 The deterministic 1/5 exponent improves a dominated quantity

Harvey, *Math. Comp.* **90**(332):2937–2950 (2021), DOI `10.1090/mcom/3658`, Thm 1.1:
`F(N) = O(N^{1/5} log^{16/5} N)`. (**HARVEY, not Harley** — no "Harley" exists in this literature.)

A **complete OpenAlex citation closure of Harvey 2021 — 13 papers, all read — contains ZERO claims
below 1/5.** The method is `?filter=cites:<ID>`, which returns a provably complete list in one
request; that is what makes this a trustworthy negative rather than a sample.

But the exponent being improved is the **deterministic** one, and the GNFS is **subexponential**
(`N^{o(1)}`), so it beats every `O(N^γ)` bound asymptotically and in practice from ~200 bits:

| bits | det 1/5 | det 1/6 (Umans–Wang) | GNFS | behind by |
|---|---|---|---|---|
| 1024 | 2^204.8 | 2^170.7 | 2^86.8 | 83.9 dex |
| **2048** | 2^409.6 | 2^341.3 | 2^116.9 | **224.4 dex** |
| 4096 | 2^819.2 | 2^682.7 | 2^156.5 | 526.2 dex |

**Even a true 1/6 never closes the gap; it widens.** Umans–Wang is a legitimate open problem about
*rigorous* bounds and is not a route to factoring anything.

### 1.4 Umans–Wang arXiv:2511.10851 — mapped, and the flagship is exactly at zero slack

Conj 3.2/3.3, §5 Conj 5.1 (adds a "prefactored" clause — a **second** hard assumption, hedged in
the paper's own text). For a b-bit modulus the conjecture is instantiated at `n = ⌊√N⌋`.
Polynomial-factoring exponent is `1 + max(α,β) + o(1)`; integer-factoring exponent is
`max(α,β)/2`, so 1/6 needs exactly `(1/3,1/3)` and merely beating 1/5 needs only
`max(α,β) < 2/5`. The feasible region is `{α ≥ 1−2β} ∩ {max(α,β) < 1/2}`, **requiring β > 1/4**
(this observation is not in the paper).

The product bound `|A| ≥ ψ(n)/n^α` vs capacity `⌊n^β⌋²` is **exactly tight** at α=β=1/3 —
`ψ(n) < n` there, and MILP-exact work shows capacity is provably infeasible at n=64,125,216,343,512
(α=0.40), with `K*/cap` falling 1.50→1.03 as n grows. **α=β=1/3 is the hardest point on the curve,
not the easiest.** The AP route (the paper's own Prop 3.4) is exhaustively dead: brute force
confirms it needs `|A| ≥ n/2−1` exactly.

### 1.5 Divisor Conjecture construction: verified, then retracted

A verified instance at (α,β)=(0.45,0.45), n=1000 — |S|=|T|=22, all 1000 targets covered by
nonzero differences, beating the trivial `T={0}` construction. **It does not generalize.** Against
the correct first-moment random baseline, the search's lift is +23.7 / +19.9 / +15.5 / **+6.5** at
n = 1000/2000/5000/10000 — decaying, not vanishing. Meanwhile the solution count
`E[#] = exp(2mn^α − μ)` is astronomically large at every parameter tested, so **the large-n failure
is a search limitation, not evidence against existence.**

New threshold (derived here, not in the paper): for GAP-structured S,T with c and c' progressions,
coverage of `[n]` needs **`c + c' ≥ ⌈1/β⌉`** (3 at β=0.45). The best GAP object found, two APs
covering 973/1000, has c+c'=2 and is therefore **below threshold** — it can only ever work at finite
n. Rests on: because S is a Minkowski sum, the offsets collapse to the single constant `ΣA−ΣB`, so
c buys *shape* freedom, not offset freedom.

**The Divisor Conjecture is not a rediscovery.** The nearest classical field (restricted difference
bases — Rédei–Rényi, Erdős–Gál, Leech, Wichmann; Schoen 2007) asks the mirror question: every small
**value** is a difference, not every small **modulus** divides one. The divisibility form appears in
nothing opened. *Unenumerated gap: the Acta Arith./JLMS bibliography (Kløve, Rédei–Rényi, Leece,
Nathanson) — needs a working general web search.*

---

## 2. THE LIVE DIRECTION: multivariate factoring

This is the one place where methods are actually being made, and it is a different problem from
everything above.

**There is no multivariate analogue of the 3/2 barrier, and the reason is structural:** the
multivariate exponent is **ω-inherited** (linear algebra over `F_q[x₁..x_m]/(f)`), not
motif-inherited. No BSGS motif means no 1.5 to defend. The real constraints live in the **number of
variables** (Kopparty–Saraf–Shpilka: PIT ⟺ deterministic multivariate factoring; Grenet
arXiv:1210.1451: the Macaulay determinant-zero test is PSPACE-complete).

**Modular composition is even more closed here than univariate:** Poteaux–Schost 2013 (*Comput.
Complexity* 22(3), DOI `10.1007/s00037-013-0063-y`) made multivariate modcomp almost-linear with
no overhead exponential in the variable count, so composition is not the term left to optimize.
⚠️ NSSV's "broke the 3/2 barrier" (JACM 71(2) 2024; arXiv:2601.17422) is about **modular composition
as a primitive — not factoring.** Do not misread it.

**The live axis is sparse multivariate with growing `n`, contested on factor-sparsity bounds**, where
**`n` costs only `log n` and high individual degree `d` is what kills you**:

- Bhargava–Saraf–Volkovich, JACM 67(2) 2020: `s^{d⁷ log n}`
- Chuyoon–Shpilka arXiv:2603.07589: `s^{d² log n}`
- Bhattacharjee–Kothary–Rai–Saraf arXiv:2606.27293: `poly(n, s^d)`
- Huang–Cao–Qiu–Gao arXiv:2607.02364: **polynomial time when total degree is bounded**
- Demin–van der Hoeven, *J. Complexity* 88 (2025): `Õ(n(s̄ + d²s))`, or `Õ(d³s̄ + d^{10})` with
  no `n` factor (Newton-polytope route)

**Applications: a verified negative.** Robert's *Breaking SIDH in polynomial time* (ePrint
2022/1038) routes through torsion sampling, *univariate* division-polynomial factoring, and
*evaluating* (not factoring) the bivariate modular polynomial. No factoring in the critical path —
isogenies are not where this pays. The real application of multivariate modcomp is elliptic-curve
point counting.

**Narrow alternative:** Lecerf, *Factorisation des polynômes à plusieurs variables* (CCIRM 2013,
Numdam 10.5802/ccirm.18), **Problème ouvert 5.1**, verbatim:
« Est-il possible d'améliorer les exposants 1,5 dans l'énoncé du théorème précédent ? »
— against the `O((d_x d_y)^{1.5})` bivariate Newton–Hensel recombination. His §5.10 notes
extending the field does not improve it. Untouched for 13 years.

**Paywall holes that would complete the picture:** von zur Gathen–Kaltofen 1985 (*Math. Comp.*)
and Lecerf 2007 (*J. Symbolic Comput.*) hold the dense multivariate exponents and were unreachable.
**Kaltofen 2000, "Challenges of symbolic computation: my favorite open problems"**
(DOI `10.1006/jsco.2000.0370`) is the most likely place a multivariate barrier would be articulated
if one exists.

---

## 3. RETRACTIONS — the most useful thing in this document

This round produced **ten false results of my own**, all the same shape: a clean number standing in
for a step nobody verified. Every one was caught by an agent dispatched specifically to attack my
own claim, or by a control. List them so none is re-derived:

1. **OCR inverted a fraction** — read `T = 2^500` as `2500`, and built a "the paper's example is
   false by 150 orders of magnitude" result on it. The example is correct.
2. **OCR dropped a `/d`** — read the interval exponent `−2.5/d` as `−2.5`, and concluded the method
   was vacuous. It is not.
3. **Over-generalized a true local fact** — "closes the DQI family, not one method." **Shor is a
   counterexample**: it never enumerates cosets. The closure is about one map (`a·x² mod n`).
4. **Float cube-root floor** — `int(n**(1/3))` returns `m−1` at every perfect cube in floating
   point, so I computed capacity 256 where it is 289, and announced a *rigorous refutation* of
   Umans–Wang's flagship. The paper is correct; the necessary condition is the paper's
   `α + 2β ≥ 1`, non-strict.
5. **Contradicted the paragraph above me** — wrote "the paper never states the `max(α,β) < 2/5`
   window" after quoting that exact line myself two paragraphs earlier.
6. **OCR misread a radical** — read Doliskani's `∛n` as `n^{1/2}` and "found" a gap in his proof.
   No gap; the paper is self-consistent.
7. **Wrong baseline reversed a conclusion** — used `K` instead of `K(1−E₁(1))` for expected random
   coverage, understating the lift, and reported that a construction had stopped generalizing when
   the corrected figure still shows a +6.5 lift at n=10⁴.
8. **Buggy searcher** — tracked S-rows and T-rows independently, but changing one S element changes
   every pair in that row. Produced a 72.6% plateau that I read as a barrier.
9. **Over-claimed from my own printout** — said a covered count "stays O(1)"; the count grows, the
   *fraction* decays.
10. **Nearly chased an 11th phantom venue** — "CNVF proceedings" was recommended as the one
    unexamined literature gap. OpenAlex returns `count 0` for that venue and the domain is parked.

Twelve fabricated or misattributed sources have now been found across this campaign, the newest
being **"Berthomieu, Jouanolou, Spaenlehauer, Vercauteren, *On the Complexity of Solving Quadratic
Isomorphism Systems*, ISSAC 2016" — it does not exist** (absent from Crossref; absent from
Berthomieu's complete 35-record HAL listing; likely conflated with Berthomieu–Faugère–Perret 2015).

---

## 4. Methodological warnings (each cost real time)

- **`pdftotext` silently corrupts formulas.** On PostScript sources it flattens superscripts
  (`2^500`→`2500`), inverts fractions, and drops letters. **Render the page
  (`pdftoppm -png -r 400`) and read the image** whenever a formula drives a conclusion.
- **The arXiv plain search UI silently drops every pre-2010 paper.** It rate-limits, returns ~10
  recency-ranked results, and omits exactly the Bostan–Gaudry–Schost / Grenet era — making existing
  literature look nonexistent. Use `arxiv.org/search/advanced` with `terms-0-field=title`, and
  citation-chase via OpenAlex `?filter=cites:<ID>`.
- **A control that FAILS when it should pass is as informative as one that PASSES when it should
  fail.** My first baseline test failed, and that is what stopped me concluding "vacuous" for the
  wrong reason. Test the tester.
- **When a computation is about to be called *rigorous*, test it at the tightest case** — perfect
  cubes, poles, boundaries — not at "representative" points. Every one of errors 4 and 6 lived in
  a test-point choice.
- **`scipy.optimize.milp` defaults to `integrality=0` (continuous).** Passing only `Bounds(0,1)`
  returns the LP relaxation, so every "integer program" number is an LP bound.
- **Complete citation closures, not samples,** are what make a negative result trustworthy.

---

## 5. If you pick this up

1. **Multivariate sparse factoring** (§2) is the only live axis. Attack factor-sparsity bounds;
   the operative cost is individual degree `d`, not the variable count `n`.
2. **Lecerf's Problème ouvert 5.1** is narrow but genuinely untouched for 13 years.
3. **Do not re-attempt** the NFS internals, the deterministic 1/5 exponent, the Divisor Conjecture
   at (1/3,1/3), or CRT-list-decoding for factoring. All closed above, with citations.
4. **The Divisor Conjecture construction problem is still open** — the `c+c' ≥ ⌈1/β⌉` threshold is
   a count, not a construction, and the counting theory says solutions exist in abundance. That is
   a well-posed search problem with a clear target.

---

# Addendum, 2026-09-29 — everything after the first handover

Sections 1–5 above stand as written on the morning of 2026-09-28. This addendum records the
rest of the round. Working files: `~/factor-scratch/r45/axis6/hyp/` and `~/factor-scratch/r45/axis7/`.

## 6. Corrections to section 1 (I had these wrong)

**The deterministic 1/5 line is not where the frontier is.** I had treated
"no route past 1/5" as the load-bearing negative. Two corrections:

- **A proven subexponential factoring algorithm has existed since Dixon (1981)**, and the fastest
  known proven form is **Lenstra–Pomerance 1992**, `L_N[1/2,1] = exp((1+o(1))√(lg N · lg lg N))`,
  unconditional. I asserted the opposite of this without opening anything.
- The citation closure of Harvey 2021 was **re-checked independently of the citation graph**
  (Crossref topic search, 2015+). The active line is Hiary / Harvey / Hittmeir and the rest is
  `1/5` with log-factor, time-space, or BSGS improvements. **The claim survives** — but the
  original evidence was structurally weaker than the conclusion, since a closure of *citters* cannot
  find a paper that does not cite Harvey.

**The real four-way picture** (all verified, primary sources read as page images):

| Class | Bound | Status |
|---|---|---|
| Deterministic, worst case | `N^{1/5+o(1)}` | **proven, unconditional** (Harvey 2021) |
| Randomised, expected | `L_N[1/2,1]` | **proven, unconditional** (Lenstra–Pomerance 1992) |
| Randomised, expected | `L_N[1/3,(64/9)^{1/3}]` | **heuristic** (GNFS) |
| Quantum | `(lg N)^{2+o(1)}` | **proven** (Shor 1994) |

## 7. The GNFS obstruction, named

It is **not** the global smoothness count `Ψ(x,y)`. It is the **uniformity of the value
distribution** — a character-decorrelation statement. The open problem is
**Lee–Venkatesan Conjecture 7.1**. Harper (arXiv:1208.5992)'s Bombieri–Vinogradov range does
cover the factoring regime `y = L_n[1/2,c}`, but those are average-over-moduli, which is exactly
why randomising `f` is the technical core.

**RH does not close it, and the authors say so.** Soundararajan, "Smooth numbers in short
intervals", arXiv:1009.1591, **body text, p.1** (not the abstract — see the correction below):

> *"We improve upon Xuan's work by establishing the following theorem, which unfortunately is still
> not strong enough to be applicable to the analysis of Lenstra's algorithm."*

⚠️ **CORRECTION — I retracted this quote once, wrongly, and the retraction was also pushed.**
The first version of this file attributed the sentence to the **abstract**. It is **not in the
abstract**, which reads only: *"Assuming the Riemann hypothesis we demonstrate the existence of
smooth numbers in certain short intervals."* I checked only the abstract, concluded the sentence
was fabricated, and pushed a withdrawal (commit `c39a6b900`) accusing a subagent of inventing a
verbatim quotation. **That accusation was false.** The sentence IS in the paper body, verified
against the full PDF: it occurs once, at p.1, in the passage introducing the main theorem
(lines 64-66 of the extracted text). A second agent, independently, made the same abstract-only
check, reached the same wrong conclusion, and caught it on re-reading the body.

**The real error is mine and it is worse than the one it corrects.** "Verify against the primary
source" was applied to the *attribution* while the *quotation* went unchecked, and the partial
check was then used to accuse a source of fabrication. A retraction is as much a factual claim as
the statement it withdraws, and it needed the same standard.

abc / Bateman–Horn: nothing, confirmed by exhaustive search.

## 7a. What is actually proved: Lee–Venkatesan 2018

**Lee & Venkatesan, "Rigorous analysis of a randomised number field sieve", J. Number Theory 187
(2018) 92–159, DOI `10.1016/j.jnt.2017.10.019`; preprint arXiv:1805.08873.** A rigorous NFS
analysis is NOT an open task — it exists.

- **Theorem 2.1**: the randomised NFS runs in expected time `L_n[1/3, (64/9)^{1/3} + o(1)]` —
  L-shaped, exponent **1/3**, matching the GNFS heuristic constant.
- **Theorem 2.3** (the non-trivial factor) is the **only** result conditional on their
  **Conjecture 7.1**.
- **Theorems 2.5, 2.6** (smooth relations; relations ⟹ congruence of squares) are **unconditional**;
  the smoothness side is proved via Bombieri–Vinogradov-type results for smooth numbers in
  progressions.

**⟹ the single remaining obstruction to a fully rigorous 1/3-exponent GNFS is Conjecture 7.1, a
character-decorrelation statement — and nothing else.** That is the sharpest statement of the
open problem this campaign produced, and it replaces the earlier, vaguer "uniformity" framing.

## 7b. Conjecture 7.1, reduced — and the two routes into it, both closed

**The reduction.** For every `h` in `P` (hence in `P_S`), *all three* character families on the
right of Conjecture 7.1 are **identically 1**: `(-1)^{ord_p(h(m))} = 1` because `h(m)` is a perfect
square; `(-1)^{ord_p(h(α))} = 1` because `h(α) = g²` gives even ideal orders; and
`chi_p(h) = chi_p(g)² = 1` because `chi_p` is quadratic. (Checked over 18,596 forms across 683
instances with `p ≡ q ≡ 3 (mod 4)`.)

So the conjecture collapses to a one-line existential:

> **(C7.1′)  there exists `h` in `P_S` with `chi_P(h) = −1`** — a product of smooth relations
> giving a **non-trivial congruence of squares**.

*Consequence worth more than the conjecture:* a **successful NFS run does not merely support it, it
verifies it** for those parameters — since `chi_P(h) = −1` exactly when the two square-root signs
disagree mod `p` and mod `q`.

**Route A — density counting: insufficient.** Remark 7.2 proves *almost every* character works:
with the paper's Theorem 5.4 plus stochastic deepening, `M ≥ L_n(1/3,(max(β,β′)+2σ)/2+o(1))` against
`W ≤ L_n(1/3,max(β,β′)+o(1))` by PNT, so `dim P_S = M − rank Ψ ≥ M − W > W` with margin
`L_n(1/3, 0.48+o(1))`, giving failure probability `≤ 2^{−(M−W)}`. But the conjecture is about the
**distinguished** character, and no sharpening of `M` or `W` reaches a prescribed element.

**Route B — is `chi_P` generic as `f` varies? Refuted, with a proof.** The paper's randomisation
supplies only `O((log n)^{2/3})` nats of entropy — the seed is the integer vector
`c_0..c_{d−1}` uniform in a box of side `L_n(2/3, κ−δ^{-1})` (Def. 4.1, p.14). But
`Hom(P_S,{±1})` has `2^{L_n(1/3,0.48)}` elements; the ratio of logarithms already exceeds 1 at
`n = 10^20` and reaches `2.9·10^272` at `n = 10^(4·10^6)`. **So "bad measure ≤ 2^{−dim P_S}" is not
merely unproved, it is unattainable by any counting argument.** (Note also `f(m,1) = n` exactly, so
`m` is determined by the `c_i` together with `fhat`, not a free parameter of `f`.)

**The weak form survives and is sufficient.** Conjecture 7.1 needs **one bit**, not `dim P_S` bits.
The entropy bound caps what any randomness argument can give at a bad measure of
`exp(−Θ((log n)^{2/3})) = L_n(2/3, −Θ(1))` — still `o(1)`, still enough to make **Theorem 2.1
unconditional**. So the statable target is: *prove the measure of `f` for which `chi_P` is trivial on
`P_S` is at most `exp(−Θ((log n)^{2/3}))`.*

**And the paper already names the wall.** Remark 7.3, p.39 (image verified): *"there is no single
character which can be used to consistently define which branch of the square root has been taken
modulo p and q."* Both routes converge on it.

**Status: open, and un-attacked since 2018.** Both source papers verified real: Lee–Venkatesan,
*J. Number Theory* **187** (2018) 92–159; Lenstra–Pomerance, *J. Amer. Math. Soc.* **5**(3) (1992)
483–516 — the latter also settles an earlier "STOC 1988 not located" error; the paper is JAMS, and
the STOC citation was simply wrong. A 2019+ sweep surfaced only implementation and encyclopedia
entries, no successor rigorous analysis.

## 8. Deterministic 1/6: a theorem, not a search failure

Harvey (arXiv:2010.05450) Alg. 4.3 has free parameters `r, m`; cost
`(N/r)^{1/4} lg^3 N` and `√(N/r) + r lg N + m lg N`. For a `1/6` total one needs
`r ≥ N^{1/3}` **and** `r ≤ N^{1/6}/lg N` — incompatible. **1/6 is impossible inside Harvey's
framework**, for any r.

Separately, `1/5` is the exact minimax of Harvey's own cost function:
`τ(ρ) = max(1/4 − ρ/4, ρ)`, minimised at `ρ = μ = 1/5` (confirmed independently by Hales–Hiary,
arXiv:2209.15586). **So 1/5 is optimal for that function, and beating it needs a different
function.**

**The positive target.** The winning pairs are `G = {(a,b) : ab ≤ r, |aq − bp| < √(N/r)}`. Since
`|aq − bp|` is linear, `G` is a short union of **rays** — convergents of `p/q` — lying in a
1-dimensional subset of a 2-dimensional search space, **whose direction is the unknown**. Measured
over 45 samples, `|G|` does not grow with `r` (0.1% of it is *not* proved; `O(log r)` is). So the
1/6 door is: **square-root the enumeration of `ab ≤ r`.** Harvey names it himself and has not
attempted it; no paper since 2021 improves the *exponent* (only constants).

## 9. Bivariate recombination (Lecerf CCIRM 2013, Problème ouvert 5.1)

The `1.5` is `D·min(d_x,d_y)` from forming `s` full-size quotients `F̂_i = F/F_i` (Alg. 5.1 step 1),
is ω-independent, and `γ = 2/3` is the balance point. **Condition (C) is `|K| ≥ d_x(2d_y−1)+1 ≈ 2D`.**

Four claims I made were wrong and are retracted: the `Õ(D)` resolution (certification by
specialization fails on `A = x^a − y^b`, irreducible yet reducible under *every* `y = c`);
agreement-based repair (stable wrong coarsening); intersection repair (`Õ(D^1.5)`, no gain); and
"the second bottleneck is untouched" (Lecerf says the opposite in the next sentence — Prop 2.26's
`Õ(d_t d_x²)` is already superseded by his own 2008 paper, arXiv refs [87]).

**What survives, verified and new:** the per-pair resultant degree bound
`deg_y Res_x(B_i,B_j) ≤ a_j b_i + a_i b_j`, correct and **exactly attained** (ratio 1.000 over
29,836 pairs, 0 violations); the fusion-incidence sum `≤ D`; and the fact that the `x = c`
direction is the correct one (`y = c` is *undefined* on a positive-measure set of `c`). These
sharpen the problem but do not improve the exponent.

## 10. Fourteen further phantom sources

Beyond the thirteen in section 3: **"Harvey & Hittmeir, *A deterministic algorithm for
factorisation with better than quadratic complexity*" does not exist**; `arXiv:2010.01250` is
"Implicit Adversarial Nets", not Hittmeir's BSGS paper (that is arXiv:1608.08766, *Math. Comp.*
**87** (2018)); "Bürgisser–Clausen–Shoup" is **Bürgisser–Clausen–Shokrollahi**, *Algebraic
Complexity Theory* (1997) — and in that whole bibliography Clausen–Shoup does not exist; "CNVF
proceedings" is not a venue (OpenAlex `count 0`). **Four of these were in briefs I wrote myself**,
including the Lenstra/Pomerance/Adleman group now in the subexponential report.

## 11. The transferable lesson (section 3, extended)

Five false results came from reasoning about a method **I had not read**: UMW §5.10, Doliskani
Lemma 5, Boneh eq. (4), Lecerf Prop 2.26, and **Lehman's method** — which does *not* use
`a² ≡ N (mod k²)`, but `x² − y² = 4kN` with `x` in a real interval. In the last two I had
*explicitly named the error I was about to make* and made it anyway. **Naming the pattern is not a
mitigation.** Every claim about a published mechanism, cost, or hypothesis now carries a page cite
and a verbatim quote — including numbers from my own subagents, who are right far more often than
I am and who still need the check applied.
