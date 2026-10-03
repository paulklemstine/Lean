# Round 48 — Summary and Census

**Date:** 2026-10-03 · **Working dir:** `factor-scratch/r48/` · **Supersedes nothing**;
extends the round-47 census (`Round47_SUMMARY.md`).

**Read this page, not the logs.** Round 48 produced **no factoring method** — the 48-round
tally is unchanged at zero. What it produced instead is a set of closures with *stated
reasons*, **two corrections of false premises the program had carried for years**, and one
corrected retraction of the program's last live positive lead.

---

## ■ DELIVERED

### Two papers, two issues

| # | Paper | Issue | What it settles |
|---|---|---|---|
| 1 | `Papers/the_baseline_that_was_not.md` | **#521** | Retracts the class-group smoothness lottery, statistically **and** structurally |
| 2 | `Papers/the_smoothness_wall_is_a_subgroup_wall.md` | **#522** | A rigorous `L[1/2]` already exists; the class group is *structurally* excluded; the smoothness wall is a **subgroup** wall |

### Two false premises corrected

1. **A rigorous `L[1/2]` has existed since ~2009.** Shoup, *A Computational Introduction to
   Number Theory and Algebra*, §15.3, **Theorem 15.6** (printed p. 413), verbatim:

   > With `y := exp[(1/√2)(log n log log n)^{1/2}]`, the expected running time of Algorithm
   > SEF is at most `exp[(2√2 + o(1))(log n log log n)^{1/2}]`. The probability that Algorithm
   > SEF outputs "failure" is at most 1/2.

   **Unconditional.** The counting argument on p. 412 makes the smoothness probability an
   exact count over the *whole* group. The one residual assumption ("`n` not divisible by
   primes ≤ `y`") is **discharged**, not assumed away: verifying it costs `π(y)`, dominated
   by the algorithm's own cost at every size (26.5 vs 123.7 log₂ at 256 bits; gap widens).

   **Consequence: the ECM smoothness heuristic was resolved decades ago. The live heuristic
   is NFS at `L[1/3]`, not ECM at `L[1/2]`.** The program had this backwards for years.

2. **"Some structure has order computable without `p`" — no, and the reason is located.**
   The class group is the only standard candidate and fails twice:
   - `p | h(−kN)` observed **0/890** across `k ≤ 4096`;
   - and BSGS costs `(kN)^{1/4}`, where `(kN)^{1/4} > L[1/2]` for **every `k ≥ 1`** once
     `N > 5400`. The inequality reduces to `2√(L ln L) < L ⟺ 4 ln L < L ⟺ L < 8.6`.
     Increasing `k` only enlarges `D`, hence `h`, hence the cost.

   **Structurally excluded, not merely unlikely** — a categorically different status from
   every other closure in this census.

### The reframe (the round's most transferable mathematical content)

> **The smoothness heuristic is not a wall in factoring. It is a wall in restricting the walk
> to a subgroup.**

Shoup states it himself, p. 405, verbatim:

> "the candidate element would be uniformly distributed over the subgroup G, and Theorem 15.1
> simply would not apply."

So the operative question for any proposed factoring method is **not** "is the smoothness
assumption true?" but **"does the construction keep the counting over the whole group, or does
it buy control by restricting?"** Every failed construction in this program's corpus is an
attempt to obtain that counting argument by working somewhere smaller. If a construction
restricts, the restriction's cost must be priced against the savings — and in every case we
examined, the accounting was negative.

---

## ■ THE RETRACTION (paper 1)

The program's last live positive lead — *"class-group lotteries could yield an ECM-independent
`L[1/2]` method"* — is void. **Three independent defects, each found by a different method,
each sufficient on its own:**

1. **The baseline was a prediction.** E-6b's reported "EC baseline" 0.925 equals
   `ρ(log₂(1684)/log₂(1000)) = 0.9273` — the Dickman probability for *its own class-number
   arm's* bit-length at its own B. Not an ECM measurement. (`notes/M_forensics.md`)
2. **A half-bit scale artifact.** `h(−q) ≈ √|D|/π`, so matching on *discriminant* size gives a
   half-bit-smaller order; that offset alone manufactures **+0.42 to +0.72** gaps,
   reproducing E-6c's headline 0.720-vs-0.440. Matched on **order** bit-length, gaps are
   **−0.050 to +0.015**, four of eight cells **negative**. (`notes/A_classgroup.md` §3)
3. **A parity mismatch.** `h(−q)` is *always odd* for `q ≡ 3 (mod 4)` prime (267/267);
   ECM orders are 67–72% even. E-7 compared odd integers against all integers. Matched: the
   ratio **reverses**, 0.78 and 0.58, Fisher p = 0.0000 / 0.0028; against an odd-uniform arm
   Fisher **p = 0.4951**. (`notes/G_adversary.md`)

Plus: E-7's own 10/25 vs 8/25 is **Fisher p = 0.769** (weakest in the series, and the only
one labelled PASSED); **no `.py` was ever committed** for E-6b/6c/7 despite the summary
claiming "All experiments reproducible, committed, pushed"; and `p_linked_smooth` measures
plain `h(−q)` with `p` absent, so the `(p − (D/p))` perturbation the milestone existed to
check was never checked.

### The structural kill, and what the walk actually is

Even granting a real advantage the mechanism fails: `Cl(O_D) mod p` is **trivial in both
cases** (`p∤D` → `O_D/p` semilocal, all ideals principal; `p|D` → the ideal of `[a,b,c]` is
`(a,(b+√D)/2) ≡ a·O_p`, principal). The decisive test is **persistence**: 6/6 primes return to
principal at step `k` and are **not** principal at `k+1`, so the residue map is not a
homomorphism and there is no order to be smooth.

*Our preregistered H1 predicted `(F_p,+)` of order `p`. It was wrong, and being wrong is what
makes it usable — reality is "no group at all."*

What the walk is: the reduced-form bound `a ≤ √(|D|/3)` makes `a = p` unreachable for `D=−N`
and reachable for `D=−4N`, so it must hit **one named integer** — and **19 of 19 factors had
`a_k` exactly `p`**. **The walk is Shanks' SQUOF, at `N^{1/4}`, strictly weaker than ECM's
`L[1/2,√2]`.** Independently corroborated by the rigorous axis, which reached `N^{1/4}` by an
algebraic argument with no access to the measurement.

---

## ■ NEW ARTIFACTS (reusable)

- **`factor-scratch/r48/_shared/dickman.py`** — the round's measurement instrument. Dickman
  `ρ` verified against the standard table; **null harness reproduces `ρ` to within 1.43σ**
  across three settings; exact integer smoothness with **no float comparison anywhere**.
  Distributed to every axis so candidates and baselines use the *same* smoothness function —
  the precondition for a matched-twin control meaning anything.
- **The half-bit diagnostic** — *match on the order, not the discriminant*. Reusable on any
  `h(D)`-versus-order comparison.
- **The parity diagnostic** — EC orders are 67–72% even, class numbers always odd. Any
  comparison against "uniform integers" must match parity first.
- **THEOREM_ordercert.md** — given `(g, complete factorization of ord_N(g))`, factoring `N` is
  deterministic `O(log^5 N)`; it either outputs a factor or certifies `ord_r(g)` is constant
  over `r | N`. Verified on 30 fresh instances (0 wrong), on non-squarefree `N = p^k·q`
  (p-adic blowup exactly `v_p = k−1`), and 9 CRT-forced degenerate instances to 137 bits
  (9/9 correctly certified, 0 wrongly split). **The heuristic is needed only to produce
  `(g, factored order)`; the descent uses nothing.**

---

## ■ CITATION INTEGRITY — 16 phantoms, and the pattern went autonomous

**41 references fetched and confirmed · 8 defective (right paper, wrong venue/volume/authors)
· 3 outright fabricated.** Roughly an 8% defect rate, with a **100% catch rate** once an agent
was told to verify rather than accept.

Confirmed by me directly: `Bernstein–Blekherman–Jenkings–Shor–Trop (ASIACRYPT 2013)` does not
exist — the real paper is **Bernstein alone**, *J. Algorithms* **54** (2005) 1–30; and
`arXiv:quant-ph/0012086` is van Enk & Hirota, *not* ABHT.

**The transferable finding.** Fourteen phantoms were authored by the orchestrator; one was
invented *while briefing an agent to follow citation discipline*. The standing rule "the
orchestrator's briefs are untrusted" was **too optimistic** — the pattern now propagates
**agent → sub-agent**. In round 48 a sub-survey returned three errors in the brief it
inherited, and a second returned **4 of 5 fabricated linear-circuit leads in its inherited
brief**, two with real arXiv IDs resolving to unrelated papers. The chain carrying them is
automated.

**Six of the eight defective citations sit inside the program's own correction tables** — the
repair apparatus introduced fresh defects of exactly the kind it was built to catch (e.g. the
corrected NSSV ID is **arXiv:2110.08354**, not `2601.17422`; BLP is **LNM 1554 (1993)**).

> **The rule this forces: a brief must not contain a citation its author has not itself
> fetched in that session.** Name a paper by *title and author*; let the agent resolve the
> identifier. A wrong identifier is worse than none — it looks verifiable and gets copied
> forward. The upgrade is not *cite* but **fetch, then cite**.

---

## ■ GENERICITY: both, and the split is measurable

- **It is a mathematical law.** 18 instances across five unrelated domains share one shape
  (irreducibility forced by a congruence; `chi_P` multiplicative on `P_S`; rank 0 in 10%;
  CM values integral in 0/275; `j`-loci empty). Every careful correction moved a rate *down*.
- **The residual is methodological.** **16 of 18 were caught precisely because somebody
  printed the population the number came from.** The two that were not are exactly the two
  where nobody did — the box supply rates, and E-7.

`Experiments/` was never audited; round 47 audited `Catalog/` and missed it entirely. **The
highest-value instance: `Round48_CostExponent.md:90-94` claims every supply number in rounds
45–47 is a *box* number overstating the relation rate by 47×–326× — which, if load-bearing,
reaches the current 0.53 exponent.** *Unresolved. This is the open item from round 48.*

---

## ■ THE CENSUS — what round 48 added

| axis | status | reason |
|---|---|---|
| Class-group smoothness lottery | **CLOSED ×3** | self-referential baseline; half-bit artifact; parity mismatch |
| Class-group walk as `L[1/2]` | **CLOSED (structural)** | `Cl(O_D) mod p` trivial; walk is SQUOF at `N^{1/4}` |
| Rigorous `L[1/2]` | **ALREADY KNOWN** | Shoup Thm 15.6, unconditional since ~2009 |
| "Structure with order computable without `p`" | **CLOSED (structural)** | `L < 8.6 ⟺ N < 5400`; 0/890 divisibility |
| Function fields / tori / Jacobians | **CLOSED (exactly)** | `reach_p = L[1/2]`: the useful bit `(D/p)` is the factorization bit; `(D/n)` carries **zero** bits about it (102 vs 105 of 207) |
| Towers (level-raising to hit smooth orders) | **CLOSED** | a loss, not a knob: 3.18×/5.74×/8.54× at k=2/3/4, and the degree depends on the unknown `p` |
| NFS smoothness uniformity | **DEVIATION FOUND (positive)** | `P(p^k | a²−b³) = (2p−1)/p^k` for odd `p`, `k ≥ 2` — the heuristic is **pessimistic**. 25–38% of collection cost; no exponent change |
| Unconditional superpolynomial lower bound | **NONE in any model** | classical *and* quantum; all such bounds are oracle bounds |
| Jacobi-symbol graph spectral invariant | **CLOSED (restatement)** | `p+q = N+1−2·deg` is exact, but `deg = φ(N)/2` and φ is polylog-equivalent to factoring |
| Projective point count over `Z/NZ` | **EQUIVALENT to factoring** | both directions, no slack (arXiv:1911.11004 p.3); affine twists sum to `4N`, a tautology |
| Cross-discipline sweep (7 fields) | **CLOSED** | K-theory, Tate modules, theta, Brauer, information-theoretic — all fail one of the three requirements |

**Unchanged from round 47:** NFS relation geometry, Harvey `N^{1/5}`, Umans–Wang, Lecerf
bivariate, auxiliary information, classical-deterministic. Nothing here disturbs them.

**Still open:** NFS at `L[1/3]` — where the heuristic actually lives. Nothing in round 48
touches it.

---

## ■ ⚠️ TOOL HAZARD — PARI `ellcard` is wrong on composite moduli

**Verified by me.** For `E : y² = x³ − x`, PARI/GP's `ellcard(E, N)` with `N` **composite**
returns a plausible integer in ~0.00 s and **raises no error**. **0 of 6 composites matched
truth**; for the three larger ones it returned exactly **`N+1`** — the naive "one point at
infinity plus `N` affine points" count, which contains **no information about `p` and `q`**.
On primes the same call is correct.

This is the program's recurring "**green** control" failure: fast, integer-valued, silent,
right order of magnitude. Trusting it would have produced a **fake polynomial-time factoring
result**.

> **Any library call used as ground truth must be validated in the exact regime where it will
> be used** — not merely in a regime where it happens to work. `ellcard` was validated on primes
> and used on composites.

Full table and the CRT ground-truth recipe: `notes/T_pari_ellcard_hazard.md`.

## ■ EARNED RULES (additions)

1. **Fetch, then cite.** A brief carries no citation its author did not fetch this session.
2. **A self-test that only shows your code running is not a self-test.** The test is whether
   the harness returns the *null* answer where null is correct. My `m_i ≡ m_j (mod p)`
   "measurement" was **100% pigeonhole** — it agreed with a preregistered hypothesis to
   within 26% for reasons unrelated to it (`notes/Q_vacuous_measurement.md`).
3. **A smoothness predicate must be shown to return `False`.** Two independent harnesses this
   round had predicates that called everything smooth (mine compared exponents to B; the
   class-group agent's did likewise). It inflates every rate toward 1 and never errors.
4. **Match on the order, not the discriminant. Match parity.** Both cost a round to discover.
5. **Validate library ground truth in the regime of use.** PARI `ellcard` is correct on primes
   and silently returns `N+1` on composites.
6. **Profile the hot loop before theorising why it timed out.** I misdiagnosed a timeout twice,
   and shipped a "fix" for the wrong function without measuring.
7. **A correction is a new measurement**, subject to every error the original was. The
   correction tables manufacture phantoms of the kind they exist to catch.

## ■ FILES

`factor-scratch/r48/notes/` — `00_HYPOTHESIS` (preregistered), `A_classgroup`, `A2_genericity`,
`A3_phantoms`, `F_rigorous`, `G_adversary`, `H_crossdiscipline`, `M_forensics`,
`P_citation_propagation`, `Q_vacuous_measurement`, `R1_lower_algebraic`, `R1_lower_quantum`,
`THEOREM_ordercert`, `ZERO_shared_harness`.
`_shared/` — `dickman.py` (the instrument).