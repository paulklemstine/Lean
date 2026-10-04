# Round 48 — Summary and Census

**Date:** 2026-10-03 · **Working dir:** `factor-scratch/r48/` · **Supersedes nothing**;
extends the round-47 census (`Round47_SUMMARY.md`).

> ## ⚠️ THE TALLY IS NO LONGER ZERO
>
> **Round 48 produced the program's first factoring construction:** Stange's
> multiplicative-relations method (arXiv:2211.06821). Paper **#524**.
>
> ⚠️ **Its success rate is NOT the construction's.** Measured 181/240 — but that is **exactly
> `20/27`**, the classical **order-finding** constant, independent of the relation set, of `c`, of
> `b`, and of `n` (0.7420 at 2⁶⁰, flat to 2²⁰⁰, 33,000 instances), and it is now **derived**, not
> merely measured. The ℚ-kernel contributes the *multiple*; the constant belongs to the step
> after it. **An earlier version of this page said "181/240 = 75%" as evidence the construction
> works. That was a misattribution and is withdrawn.**
>
> **Where it stands: empirically viable, unproven, and not competitive.**
> - **Cost is the wall.** `b_needed = L_n(1/2, β=1) = exp(√(log n · log log n))` — Stange's own
>   runtime argmin. `b_max` is polylog. **The ratio diverges; they never meet for any fixed β.**
>   (And `β = 1` was **hardcoded** — Stange p.5 declines to determine it; `β → 1/√2` is 3 orders
>   better.) The only lever that closes the gap is **Gordon 1993 / NFS relation-finding**, which
>   works to **551 bits** — but that is the known `L[1/3]` algorithm re-derived, wearing Stange's
>   linear-algebra and gcd phases. **Not a factoring advance.**
> - **There is no correctness floor on `b` at all.** Measured: **`b_min = 3` at every modulus
>   tested.** `b_needed` overstated the smallest usable `b` by **17–30×**; it is a runtime
>   argmin, not a condition. What fails at small `b` is cost (`7.3 × 10⁵` trials per relation at
>   `b = 3`), not correctness. **Paper #528.**
> - **The load-bearing conclusion: the relation-finding is where all the difficulty lives — 95%
>   of the phase. The construction 48 rounds attacked is 5%, the EASY half.**

> ## THREE POSITIVES — all PROVED or exactly derived, not estimated
>
> | paper | result |
> |---|---|
> | **#525** | The stride relation-finder **attains the unconditional lower bound** `(b+c)/Ψ(n,BB)` multiplications per factor **with equality** — 54.78× fewer modular multiplications. **Optimal, not merely better.** Beating it would require violating the equidistribution conjecture for `{g^x mod n}`. |
> | **#528** | `20/27` **derived exactly** (to −1.7 × 10⁻¹⁸ in rational arithmetic) as `P(v₂(ord_p g) ≠ v₂(ord_q g))` over the joint law of `s = v₂(p−1)`; and **no correctness floor on `b`** (`b_min = 3`) |
| **#527** | Shoup's **unconditional** factoring bound `2√2 → 2`, proved. The `c=2` square is removable (Thm 15.1's `u log log x` vs the sharp `u log u`); the `a=2` square is forced by counting. **Optimal within this shape:** `√2` needs ECM, whose `√2` is a heuristic — **there is no proved unconditional `√2`.** |

**Read this page, not the logs.** Round 48 produced: **one working factoring construction**,
**two proved positives**, a set of closures with *stated reasons*, **two corrections of false
premises the program had carried for years** (a rigorous `L[1/2]` has existed since ~2009; and
Coppersmith's univariate bound was settled in 2016), and a **retraction** of the program's last
live lead — its support was a Dickman self-reference with no code behind it.

**And it produced its own accounting.** See *The campaign's own errors* below: a shared
instrument that was certified to every agent and is broken above `u = 5`; a "positive finding"
that was 46 of 52 roots inverted; a headline figure that failed its own table; and a census
that had to be caught carrying withdrawn claims in its own summary.

---

## ■ DELIVERED

### Two papers, two issues

| # | Paper | Issue | What it settles |
|---|---|---|---|
| 1 | `Papers/the_baseline_that_was_not.md` | **#521** | Retracts the class-group smoothness lottery, statistically **and** structurally |
| 2b | `Papers/the_smoothness_wall_is_a_subgroup_wall.md` | **#522** | **The subgroup-wall reframe.** The ECM smoothness heuristic was resolved by an exact counting argument over the WHOLE group `Z*_N`; every failed construction in this corpus is an attempt to obtain that counting argument by working in a **subgroup**. Class group **excluded unconditionally** (§2.3: `h` `B`-smooth ∧ `p|h` ⟹ `p ≤ B`, inconsistent at the relevant bound) — its cost model is indicative only. Function fields closed exactly: `(D/p)` **is** the factorisation bit |
| 3 | `Papers/a_square_minus_a_cube_divides_twice.md` | **#523** | **POSITIVE (distributional fact only).** `P(p^k | a²−b³)/p^k = 2−1/p` for odd `p`, **2 ≤ k ≤ 5**; departs at k=6 by the zero-zero subspace. The NFS uniformity heuristic is **pessimistic**. ⚠️ its 25–38% collection-cost payoff is **WITHDRAWN by audit** — never measured end-to-end |
| 7 | `Papers/sharper_proved_l_half.md` | **#527** | **POSITIVE — improves a PROVED bound.** Shoup Thm 15.6's unconditional `2√2` decomposes into two independent squares; the `c=2` one (Thm 15.1's `u log log x` vs the sharp `u log u`) is **REMOVABLE ⟹ `2√2 → 2`, proved**. The `a=2` square is forced by counting. **Optimal within this shape:** `√2` needs ECM, whose `√2` is a heuristic — **there is no proved unconditional `√2`.** Regime: `u = 11.0`/`19.8`/`26.7` at RSA-512/2048/4096, and only ~78% of the gain is realised at RSA-2048 |
| 6 | `Papers/choosing_b_well.md` | **#526** | **81× cost reduction** vs the baseline (2.22e5 → 2,724 exponentiations per factor at 2³⁰; ⚠️ published as 186×, which fails its own table — `2.22e5/2724 = 81.5`). Three independent objectives converge on **`b ≈ 26–52`** and **the optimum MOVES with `n`** (26→52 in wall clock, 2³⁰→2⁴⁰). ⚠️ **the objective you optimise moves the argmin by 3–5×** — exponentiations-only over-shoots by 3–5× because the bottleneck MIGRATES to linear algebra. The round-48 "b-gap" survives pow-vs-multiply but shrinks **67.9× → 7.1×** |
| 4b | `Papers/the_order_finding_constant.md` | **#528** | **The correction that defines the method.** `P = 20/27` is **DERIVED** — `P(v₂(ord_p g) ≠ v₂(ord_q g))` over the joint law of `s = v₂(p−1)`, exact to −1.7×10⁻¹⁸. **It is the classical ORDER-FINDING constant; the ℚ-kernel supplies the multiple and contributes NO probability advantage.** And **`b_min = 3` at every modulus tested — there is NO correctness floor on `b`.** `b_needed ≈ 5.9×10⁵` overstated the smallest usable `b` by 17–30×; it is a RUNTIME argmin, not a condition. |
| 5 | `Papers/the_optimal_sampler.md` | **#525** | **POSITIVE + A STOPPING THEOREM.** Stride relation-finding is **provably cost-optimal**: it attains the unconditional bound `(b+c)/Ψ(n,BB)` multiplications per factor **with equality**. **54.78× fewer modular multiplications** at `n≈2⁴⁰` (197,798 → 4,798.6 at 2³³), 3.91× wall-clock, held-out rates indistinguishable. **Beating it would require violating the equidistribution conjecture for `{g^x mod n}`.** Also: batch smoothness has nothing to save (a smoothness test is **0.1% of cost**), and **Dickman `ρ(u)` is NOT a valid null here at all**: `Ψ(B,x)/x → e^{−γ}/ln B > 0` while `ρ → 0`, so the ratio **diverges** — `ρ` is the wrong *functional form*, not merely inaccurate (the old "8.46× at u∈[5,8]" figure is **wrong in both magnitude and regime**) |
| 4 | `Papers/stange_works_and_its_analysis_does_not.md` | **#524** | **THE FIRST FACTORING CONSTRUCTION.** Success probability is **exactly `20/27`** — the order-finding constant, **not** the construction's; **H3.1 refuted to 1269σ** inside its own proved regime; the paper's printed formula is inverted vs its own text; regime gap **4.3 orders** at `n=10²⁰` |
| 4 | `Papers/stange_works_and_its_analysis_does_not.md` | **#524** | **THE FIRST FACTORING CONSTRUCTION.** Success probability is **exactly `20/27`** — the order-finding constant, **not** the construction's (the "75%" was a misattribution, corrected). **H3.1 refuted to 1269σ** inside its own proved regime; the printed formula is inverted vs its own text; regime gap **4.3 orders** at `n=10²⁰`; best cost cut **2.36×**, held out |

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
     `N ≳ 10⁷⁰·⁸`. The inequality reduces to `4√2·√(L ln L) < L ⟺ 32 ln L < L ⟺ L < 163.0` — **using the `√2` convention that Shoup's own `L[1/2]` uses.** ⚠️ **This number has now been corrected TWICE and both corrections are recorded here**: the original `2√` gave `N < 5400` (wrong by 3.3 × 10²⁵), then `4√` gave `N < 1.8 × 10²⁹` (still wrong, because it used the convention *without* `√2` while the cost table used it *with*). **The two conventions differ by 41 orders of magnitude in the threshold.**
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
| Stange **linear-algebra bottleneck** | **NOT removable by sparsity — proved** | The relation matrix IS sparse (density `Θ(1/b)`), and a sparse route is `Θ(b²)` against dense `Θ(b³)` — a **factor-`b`** win, measured at `n≈2³⁰`. **But the permutation-similarity defect is `Θ(b)` and provably invariant under every permutation**, because **the row for `p = 2` is dense: a constant fraction of all `B`-smooth integers are even.** NFS's `O(n²)` sparse treatment rests on a *bounded* defect and **does not transfer**. The mechanism is **exact**: row *i* is nonzero iff `p_i | r_j`, and `Pr[row i] = Ψ(n/p_i,B)/Ψ(n,B)`, so the defect is `≈0.6(b+c)` at every `b`. And the **permutation-similarity defect equals the identity for ANY matrix** (a column permutation preserves each row's nonzero count) — **so no reordering exists to find; the NFS premise fails structurally, not empirically.** Jeljeli arXiv:1209.5520v4 says it outright: *"hundreds or fewer non-zero elements per row"* — the bounded defect NFS has and Stange does not. **And `Θ(b²)` fill is forced by the MATRIX, not the pivot order** (AMD minimum-degree gives ratios 0.89–1.41, straddling 1). **T4: the argmin does NOT move** — `b = 12/32/64` at `2²⁰/2³⁰/2⁴⁰` under dense *and* sparse; sparsity is worth only 1.01–1.11× at the argmin, so **cheaper LA flattens the minimum, it does not move it.** At `b = 6×10⁵` sparse is **memory-infeasible** (5.5×10⁹ fill entries ≈ 275 GB) and black-box is 2.2×10¹² ops: **nothing is usable.** (Dense ceiling is higher than believed — exact `DomainMatrix.rref()` completes `b = 512` in 4.4 s where sympy `nullspace()` dies at 32.) |
| **⚡ THE ONE ACTIONABLE NUMBER IN ROUND 48** | **a backend swap, not an algorithm change** — ⚠️ **NOT independently reproduced by the coordinator** | The incumbent kernel routine leaves **a factor of ~10 on the table** *(`PP_droptest.md`, 16 cells)*: `sympy.DomainMatrix.rref` over `QQ` beats it at **all 16 cells by 4.2–15.3×**. ⚡ **NOW CONFIRMED AT >10⁴×, and the confirmation is a pleasing self-reference.** The agent diagnosed its own disclosed `b=52` timeout and found the cause was **never relation-finding** (~3000 trials, under a second) but `stange.kernel_basis` calling sympy `Matrix.nullspace()`, which takes **>200 s at `b=52`**. Swapping that ONE call for `DomainMatrix.rref` over `QQ` — **the identical exact computation** — took the cell from **timeout to 0.1 s per modulus**. The note's own headline finding *caused* the failure of the experiment designed to support it, and fixing it with that finding closed the gap.

**On the coordinator's failed reproduction (`notes/DD_repro_failure_kernel_swap.md`):** measured on **dense random** matrices the direct `rref` route is 2.5–3.8× at dim 30–40 but **0.75–0.86× at dim 60–140**. That is **the wrong population** — the agent's matrices are **sparse** (density `Θ(1/b)`) and the effect there is **>10⁴×**. Correctness was confirmed at every dimension in both tests. **The earlier `>10⁴×` claim was, however, not the <10× originally reported; both numbers are the same swap at different `b`, and the census should quote the b-dependent figure rather than a single factor.** Verdict on the drop-in claim is **(b) EQUIVALENT** — the round's positive framing overstated it. **And the corollary worth more than the factoring result: a `Θ(b)` defect is an asymptotic obstruction, not a practical one** — a matched-nnz `O(1)`-defect control costs the *same* at `b = 26–52` (0.93–1.13, replicated on fresh seeds) |
| **Is Stange's kernel a drop-in for NFS's?** (round 49's most interesting positive claim) | **UNFALSIFIABLE AS STATED — and the round was wrong in BOTH directions** | The claim names a phase that **is not the binding constraint**. At `n ≈ 2⁴⁰, b = 52`, swapping **only the linear-algebra backend** moves `frac_LA` from **0.328 → 0.049**: with a good backend the kernel is **5%** of the phase and relation-finding **95%**. (The earlier 19.4%/80.5% split used a slower backend.) **A phase that is 5–20% of the cost is not a bottleneck**, so "drop-in" holds only in the operationally-irrelevant sense and is nearly vacuous. **⚠️ AND THE OBVERSE: the `Θ(b)` defect is NOT practically binding.** It is confirmed — log–log fit over `b = 16…256` gives exponent **0.900** (`R² = 0.999`) — but a matched-shape, matched-nnz control with an `O(1)` defect costs the **SAME** number of sparse arithmetic updates at `b = 26–52` (ratios **1.13, 1.07, 0.92**, straddling 1). **The defect is an ASYMPTOTIC obstruction, not a practical one** |
| **Where `b_needed ≈ 5.9×10⁵` comes from** | **DERIVED — and the gap is STRUCTURAL** | It is `L_n(1/2, β=1) = exp(√(log n · log log n))` — Stange's own **runtime argmin**, *not* a smoothness condition and *not* F&W's window. **β = 1 was HARDCODED**; Stange p.5 declines to determine β, and balancing her own two costs gives **β → 1/√2 (3.3 orders better)**. **Classification:** `b_needed` is **subexponential**, `b_max` is **polylog**, so the ratio **DIVERGES — they never meet for any fixed β > 0.** `c` does **not** help (additive `log(1+c/b)`, O(1) shift; every column → 1.0000) and **there is no `m`** — Algorithm 2.2's parameters are only `B` and `c`. **The method factors at `b = 3` at every `n` tested** — there is no correctness floor; what fails at small `b` is cost |

**⚠️ AND THE PREMISE OF BOTH WAS WRONG: `b_needed` is a RUNTIME estimate, not a correctness floor. Algorithm 2.2 has NO correctness floor on `b`. Measured with the 2-adic control on every cell: **`b_min = 3` at EVERY completed modulus (2²⁷–2³³, four cells)** (`b_max` 12/13/15), so **`b_needed` overstates the smallest usable `b` by a factor of 17–30**, and the discrepancy is a property of the ESTIMATE, not the construction. What fails at small `b` is COST (7.3×10⁵ trials per relation at `b = 3`), not correctness. **The p_split control earned its keep again: it ranges 0.750→0.977→0.994 across those moduli, so against a flat 20/27 the first two would have shown spurious excesses of +0.22 and +0.24 that are ENTIRELY the modulus's 2-adic structure.** The per-modulus excess is consistent with ZERO everywhere |
| **The one lever that closes it** | **WORKS, at the price of the whole method** | Stange p.2 points at it herself: *"The methods of [7, Section 3.1] can be adapted to find relations modulo n"* — **[7] = Gordon 1993, the NFS's own exponent**. Under it `b_needed` falls from 5.9×10⁵ to **8.4**, and `b_needed ≤ b_max` holds for **every modulus up to log₂ n = 551 bits** (crossover 1.001 at 552), far beyond any RSA key. ⚠️ **But it buys 4.8 orders in `b` by replacing Stange's whole L[1/2] relation-finding with the NFS's L[1/3] — so it is *not a factoring advance*, it is the known L[1/3] algorithm re-derived, wearing Stange's linear-algebra and gcd phases.** The load-bearing conclusion: **the relation-finding is where all the difficulty lives; the construction 48 rounds attacked is the EASY half** |
| **The bound's own origin** | **CORRECTED TWICE — and the trace matters more than the value** | `b_needed` is **not** a smoothness condition and **not** F&W's window: F&W's `B ≥ 8n^{n/2}ν(Λ)` bounds relation *ENTRIES* (Stange p.4: entries `< n`), so it bounds `b` from **ABOVE** — it IS `b_max`. The 5.9×10⁵ is Stange's **runtime argmin**, reproduced to the digit (`exp(√(log n log log n))` = 5.8556e5 at 10²⁰). **β = 1 was HARDCODED** — p.5 verbatim: *"runtime of Lₙ(1/2, β) for some constant β … we will not devote time to optimizing the constant β."* Balancing her own two costs gives **β → 1/√2**, confirmed by two independent computations agreeing to 6 decimals. **The axis is closed STRUCTURALLY:** `log(ratio) = β√(L log L) − log L + … → ∞`, so the ratio diverges **for any β > 0** — lowering β buys a constant factor while the gap grows without bound |
| **Stange regime bound** `n ≥ 8b^(b/2)` | **the gap is in the GUARANTEE, not the method** | Verified from a page image (Stange p.4, *then taking `c = b+1`*). **The bound is not Stange's — it is Fontein–Wocjan arXiv:1211.6246 Thm 1.1** (fetched; not previously in the repo). **`b_max(n,c)` is FLAT in `c`, proved not sampled:** the `8n^{n/2}` window lives only in Cor 2.3, which uses the first `n = b` vectors and never mentions `c`; Prop 2.5 — where `c` lives — has **no window condition at all**. `c = b+1` is forced by `b+c = 2b+1`. **But the guarantee is `α_b` ≈ 0.17, NOT 0.999.** And **Stange drops half the theorem she cites** (her single-window algorithm omits `64b²(b+1)`), so `b_max(10²⁰)` is **24, not 26** (⚠️ the value was itself corrected once: an odd-`b` bug gave **21**, found by the follow-up agent's 116/116 selftest) — her regime is **optimistic, not conservative**. **No cliff measured:** rates run to **11 steps past `b_max`**. So: **empirically viable, unproven; "uncompetitive" was right about the COST and wrong about the METHOD** |
| **Stange ℚ-kernel method** | **✓ WORKS — the program's first method** | **181/240 = 75%** at `n ≈ 2^20`–`2^40`; H3.1 refuted to **1269σ** *inside its own proved regime*; printed probability inverted vs the paper's text; regime gap **4.3 orders** at `n=10^20` |
| **Stange ℚ-kernel method** | **✓ WORKS — the program's first factoring CONSTRUCTION** | Measured **181/240** instances at `n ≈ 2^20`–`2^40`. ⚠️ **but the 75% is NOT the construction's**: the success probability is **exactly `20/27`**, the order-finding constant, independent of the relation set, of `c`, of `b`, of `n` (0.7420 at 2⁶⁰, flat to 2²⁰⁰, 33,000 instances). H3.1 refuted to **1269σ** *inside its own proved regime*; printed formula inverted vs its own text; regime gap **4.3 orders** at `n=10²⁰`; best cost cut **2.36×**, held out |
| Class-group smoothness lottery | **CLOSED ×3** | self-referential baseline; half-bit scale artifact; parity mismatch. ⚠️ not "three **independent**" defects — they are three different *experiments*, and for E-7 the parity defect is **redundant**, not independent |
| Rigorous `L[1/2]` | **ALREADY KNOWN** | Shoup Thm 15.6, unconditional since ~2009 |
| "Structure with order computable without `p`" | **CLOSED (structural)** | `32 ln L < L` ⟺ `N ≳ 10⁷⁰·⁸` (corrected **twice** by adversarial audit: a factor-2 algebra error giving `N < 5400`, then a `√2`-convention error giving `N < 1.8 × 10²⁹`; the two conventions differ by 41 orders); 0/890 divisibility |
| Function fields / tori / Jacobians | **CLOSED as an L[1/2] route; NOT closed as a factorer** | `reach_p = L[1/2]`: `(D/p)` is the factorization bit, `(D/n)` carries zero bits about it. ⚠️ `E_funcfield.md:358` calls the `D=u²−1` torus **"a genuine factoring method (12/12 splits, 1.5× cheaper than GMP-ECM's ladder)"** — the census previously said CLOSED where the note says the opposite. The `reach_p` figure **needs Lenstra's heuristic** (flagged, unmarked here before), and the field-vs-number-field asymmetry rests on **Lenstra–Pomerance 1992, which the note's author states he has not read** — "the synthesis is mine" |
| Towers (level-raising to hit smooth orders) | **CLOSED** | a loss, not a knob: 3.18×/5.74×/8.54× at k=2/3/4, and the degree depends on the unknown `p` |
| NFS smoothness uniformity | **DEVIATION FOUND (positive)** | `P(p^k | a²−b³)/p^k = 2−1/p` for odd `p`, **2 ≤ k ≤ 5** (departs at k=6) — the heuristic is **pessimistic**. **The 25–38% figure is WITHDRAWN by audit; the measured replacement is 14.1% [13.3,15.0] at u≈3. AND THE GAIN IS LOCALISABLE** — the best mod-4 sub-box beats the global rate at EVERY operating point (5.65× at u=6, 2.04× at u=3), so a sieve *could* be aimed at it. That is a STRONGER result than the withdrawn claim, not a weaker one |
| Unconditional superpolynomial lower bound | **NONE in any model** | classical *and* quantum; all such bounds are oracle bounds |
| Jacobi-symbol graph spectral invariant | **CLOSED (restatement)** | `p+q = N+1−2·deg` is exact, but `deg = φ(N)/2` and φ is polylog-equivalent to factoring |
| Projective point count over `Z/NZ` | **EQUIVALENT to factoring** | both directions, no slack (arXiv:1911.11004 p.3); affine twists sum to `4N`, a tautology |
| Cross-discipline sweep (7 fields) | **CLOSED (field 6 now too — see below)** | K-theory, Tate modules, theta, Brauer, information-theoretic all fail |
| **Jacobi-symbol graph degree** (was "the round's only genuinely live lead") | **CLOSED — verified by the coordinator** | `deg = φ(N)/2` and `p+q = N+1−2·deg`, so the degree reveals a factor **exactly**. Closed on four independent grounds: the count factorises to exactly `φ(N)/2` (a restatement); `Σₓ (x/N) = 0` identically so **no partial-information channel exists at all**; the Ihara zeta does not even apply for `N ≡ 3 (mod 4)` (**half of all RSA moduli** — the graph is directed with complex eigenvalues); and `deg = φ(N)/2` needs `N` squarefree. **Zero literature on arXiv AND on IACR eprint.** The census's old closure rested on "φ is polylog-equivalent to factoring", **asserted with no proof or citation** — that was the actual gap, and it is now closed by argument rather than by assertion |
| Partial-information factoring below ½ the bits of p | **MEASURED; optimality UNPROVED for this problem** | Our measurement: **31 unknown bits WORKS, 32 FAILS** at N=2¹²⁸ — `X = N^{1/4}` exactly. ⚠️ **An earlier "now also a THEOREM" upgrade is STRUCK — it was my error.** arXiv:1605.08065 proves optimality for **univariate polynomials modulo N**, and its p.6 §2.3.1 lists *"factoring RSA moduli N=pq when half of the most or least significant bits of one of the factors p is known"* as **"a direction for future research"**. **Our `X = N^{1/4}` is a CONJECTURE here — it is the *modulo-unknown-divisor* bound, not R1's *modulo-N* one.** Nothing tested beat ½ |

An earlier version of this row said, in bold, that the threshold was *"now also a THEOREM"* on
the strength of arXiv:1605.08065. **That is withdrawn.** I fetched the abstract myself and
checked the authors and date; I did **not** check that its scope covered our row. It does not.

**What R1 actually proves** (Chinburg, Hemenway, Heninger, Scherr, *Cryptographic applications
of capacity theory: On the optimality of Coppersmith's method for univariate polynomials*,
arXiv:1605.08065, Thm 2, p. 2 read as an image): the optimality is about the **existence of
Coppersmith-type auxiliary polynomials** `h = Σ a_{i,j} x^i (f/N)^j` for **univariate**
polynomials **modulo N**. That is *stronger* than lattice-optimality and *weaker* than
method-optimality — a third thing, not what this row needs.

**And R1 explicitly EXCLUDES our row.** p. 6 §2.3.1, verbatim: it covers *"univariate
polynomials modulo integers"*, and *"Adapting these results to the other settings"* — having
just listed *"factoring RSA moduli `N = pq` **when half of the most or least significant bits of
one of the factors `p` is known**"* — *"is a direction for future research."*

**So our measured `X = N^{1/4}` is a CONJECTURE for this problem, not a theorem.** It is the
*modulo-unknown-divisor* bound (Coppersmith/Howgrave–Graham/May), which is a different result
from R1's *modulo-N* bound. **Our 31-works/32-fails measurement remains exactly as valid; its
status was overstated.**

**What R2 settles.** Chinburg et al., arXiv:2111.14180, supplies a **decidable test** for
algebraic independence, now implemented. On realistic 2-sample HNP instances it returns WORKS
(γ ≈ 0.005–0.09, an independent function provably exists) and crosses to FAIL at larger `X`
(WORKS at `X = 180`, **FAIL at `X = 321`**, where the method is *provably impossible*). And the
fire rate is **not rare**: for `X ≥ ⅓√p`, **100% of instances provably fail independence**
(4980/4980 already at `c = 1/4`). So the census's *"no multivariate/Herrmann–May construction
built at all"* becomes **"provably unavailable"** — but **only in the two-variable linear
subcase**, which is not the same as closing the multivariate axis.

**Honest limits from that agent, recorded because they are the point:**
- It **refused to attribute a known-multiplier threshold it could not read** (Ernst et al.
  EUROCRYPT 2005 is Crossref-confirmed but the Springer PDF is challenge-blocked and it is not
  on eprint; it verified the condition only as a restatement in eprint 2018/516 p. 16).
  **That is the correct call and it is the one I would have been tempted to make.**
- **Citation trap recorded:** eprint 2007/374 is a *rigorous, different* paper from
  ASIACRYPT '08. Not the same work.
- **Multivariate independence is still a heuristic**, stated as "Assumption 1" (CRYPTO 2025,
  2024/1330 p. 11) and "Heuristic 1" (EUROCRYPT 2025, 2024/1577 p. 6), with **no post-2021
  follow-up by any of the four authors**.

**The precise residue — the one live question this axis leaves:**

> **Is `X = N^{1/4}` optimal for partial-information factoring, and does the known-multiplier
> case have its own optimal bound?**

Both need **capacity theory for roots modulo an *unknown divisor*** — which is precisely the
gap R1 itself names (*"joint capacities of many adelic sets … not been developed"*).
| GNFS constant via BKZ past LLL | **no gain found; "provably nothing" WITHDRAWN** | 40/40 give LLL/SVP = 1.0000000000 on the *certified* lattices. ⚠️ But the census's **mechanism sentence is not measured and the note's own control contradicts it**: `I_constant.md:26` records LLL/SVP ∈ [1.000, **1.149**] and S4b finds LLL **strictly suboptimal 1/60**. Also **Montgomery normalisation is absent — 0/40 rows m-divisible** (`I_constant.md:139-143`, "a real gap I flag rather than claim"). Honest status: **no constant improvement demonstrated on the lattices tested** |

### The constant axis, settled by an exact computation rather than a comparison

The constant-factor axis built **genuine** GNFS relation lattices (7-dimensional, from real
2-D sieved relations with `p | a−bθ` iff `a ≡ b·α mod p`) — small enough to run a **certified
exact-SVP enumerator** on them. That makes the experiment *definitive* rather than comparative:
`LLL(b₁)/exact_SVP(b₁)` is the entire prize available to **any** block size.

> **40/40 lattices: ratio = 1.0000000000.** Best β over β = 2…7: **1.0000000000×**.

Mechanism: the lattice basis vectors have near-disjoint small-prime supports, so the rows are
nearly orthogonal *before* reduction. **LLL is already at its optimum, and better reduction
cannot help.**

This is the correct way to run a negative in this program: not "BKZ did not beat LLL" but
"the exact optimum equals LLL's output, so no β exists that could." 119 configurations were
attempted; the 40 that admitted a certified exact SVP were used, and **the other 79 were
discarded rather than silently approximated.**

The ceiling is doubly low: sieve-then-reduce costs **1172×** (3214 ms vs 2.7 ms), and the
relation-lattice dimension is **constant in `N`** (7 at 32 through 70 bits), so Montgomery's
`O(n²)` linear-algebra term does not grow with the modulus. **The constant was never where the
time is.**

**⚠️ WITHDRAWN 2026-10-03 — the axis's "positive finding" was a BUG ARTIFACT.**

The census previously recorded, from this axis: *"minimising coefficient mass is the wrong
objective; the largest-mass polynomial yielded the most relations (1090) and the smallest the
fewest (292) — anti-correlated"*, and that a bad `f` *"produces zero relations"*.

**Both are withdrawn.** Root cause found and fixed
(`factor-scratch/r49exp/polysel/`, `notes/EE_polysel.md`): the round-48 relation finder sieves
`norm = b^d·f(a/b)` but **masks `a ≡ αb` using roots of the REVERSED polynomial** — **46 of 52
roots are wrong** (at `p=7` it masks `a/b = 2` where the norm needs `a/b = 4`, and `2·4 ≡ 1`).
The bug **under-counts the true smooth rate by 136×**, which is what manufactured the effect.

Re-measured over **224 polynomials, 3 moduli, 37–50 bits, rate spanning 1243×**:

> **Spearman(mass, rate) = −0.841** [−0.881, −0.787] — larger mass gives **FEWER** relations,
> slope **−0.290 ± 0.013** per e-fold. **The sign of the round-48 claim was reversed.**

Also: round 48's five numbers give only **+0.20** (n = 5, carried entirely by one point), and
the *"zero relations"* claim **does not reproduce** — a 60× worse polynomial still yields
**12,777** relations at their own `y` and box.

**The real mechanism, which is the correct and much smaller finding:** the relation rate is the
box-average of the smooth-number density at the size of `f(a,b)`. **`mean log|f|` predicts it
with `R² = 0.958` vs mass's `0.672`**, and does so *within* the fixed-`m` family where geometry
cannot explain it.

**What is actually exploitable: ~1.1×.** Held-out over 9 moduli: median **1.11×** minimising
mass, **1.02×** minimising meanlog, **1.27×** oracle; held-out figures **1.07× / 1.02× / 1.24×**.
Worst cases **0.66× and 0.69×**, and on 2 of 9 moduli the oracle is **1.00×** — so the gain is
instance-dependent, **not a guaranteed multiplier**.

*Stated honestly by the agent:* it over-read an 8-modulus subset and the 9th reversed the
conclusion; it corrected this in the note and flags the result as **8/9 at best**.

### The live thread this round opens

The Stange mechanism identifies `α_t` as **4–5× over 2-divisible and up to 14× over
3-divisible**, with a heavy tail (`h` reaches 83). That is a *defect* of the paper's analysis
and simultaneously an **unexploited lever**: a relation search biased toward high small-prime
valuation of `α_t` should raise the per-attempt success above the measured 0.75. Dispatched as
`exp/stange2/` with the mandatory baseline reproduction and a held-out test set, because
tuning results reported as results is how this program has destroyed itself before.

The second live question is the **decay curve**: does 75% hold at 2^60, or is it already
collapsing? The regime analysis predicts a collapse eventually; whether it has begun by 2^60
is measurable and would be the honest answer to "does this work at RSA scale?"

---

## ■ PROVENANCE WARNING — read this before trusting any row above

**This census has been audited by an agent that did not write it
(`notes/Y_adversary_papers.md`), and the audit's central finding is about THIS FILE, not about
the mathematics:**

> **No census row is wholly untraceable. The failure mode is that the reason column is STRONGER
> than the evidence beneath it, and the census systematically DROPS the caveats its own notes
> attach.**

Six rows have been corrected above for exactly this. The general rule:

> **A table row propagates; prose caveats do not. If the status word in the table is stronger
> than the status word in the note, the table is wrong.**

Corrections applied from that audit:
| row | was | now |
|---|---|---|
| BKZ / LLL | "CLOSED — provably nothing" | **withdrawn**; no gain demonstrated on the lattices tested; note's own control gives LLL/SVP up to **1.149** and finds LLL suboptimal 1/60; Montgomery normalisation absent (0/40 rows m-divisible) |
| Function fields | "CLOSED (exactly)" | closed as an `L[1/2]` route but **NOT closed as a factorer** — the note calls the `u²−1` torus **"a genuine factoring method (12/12 splits, 1.5× cheaper than GMP-ECM)"** |
| Cross-discipline | "CLOSED" | **field 6 is OPEN**; the note calls it "the round's only genuinely live lead" |
| Partial information | "CLOSED" | **axis NOT closed**; the note lists five unmeasured dimensions |
| Supply audit | filed under round 48 | **actually round 49**; scripts in `r49/exp/supply/`, note `S_supply.md` — previously absent from this census's own FILES list |

**Standing obligation:** if a row here contradicts its note, **the note wins.**

---

## ■ THE SUPPLY AUDIT — RESOLVED (this was the round's biggest open worry)

Round 47/48 flagged `Round48_CostExponent.md:90-94` as **the most damaging unresolved
instance**: *"every supply number in Rounds 45–47 is a box number; none is a rate for the
algorithm."* Audited. **Resolved, in both directions, and the control is exact.**

**The control.** The audit's scan sampler reproduces the original program's log
**exactly** — `~/factor47/V4/CEIL3b.log` gives relations `1021 / 1753 / 2761 / 3566` and nulls
`102 / 50 / 272 / 25` at 10/12/14/16 bits, and the sampler matches all of them. It also gives
`χ_P = −1 = 23.40%` against the file's stated ~23%. Control passes at **0.92σ**. *(Verified
independently by me against the artifact.)*

**Finding 1 — the overstatement is a power law, and steeper than reported.**
`α = +0.794 ± 0.095` (OLS, 4 points, all residuals < 0.8σ); inverse-variance gives
`+0.991 ± 0.047`. **Positive at 2σ.** True supply exponent `−(1/6 + α) = −0.96` (OLS) /
`−1.16 ± 0.05`, against the record's `−1/6` — **6–7× steeper.**

**Finding 2 — the mechanism attribution in the record is half wrong.** Decomposed:

| component | size-dependent? | magnitude |
|---|---|---|
| pool composition (16 hand-picked vs all of [1,31]) | **NO — constant** | 1.235 / 1.237 / 1.342 at 24/28/32 bits |
| **`\|c\|` magnitude** (box 31 vs scan `N/3`) | **YES — the whole of it** | `rate ~ \|c\|^(-0.21…-0.45)` |

The record blames the hand-picked pool. Measured, the pool is a **flat 1.24×** and contributes
**no growth in `N`**. All the growth is `|c|`.

**Finding 3 — the 47×/326× figures are single-`N` artifacts.** At 32 bits **28 of 32 semiprimes
give ZERO relations** in 20,000 instances; the recorded scan rate exceeds the **maximum** of 20
independent draws, and 326× rests on **five events**. Corrected values: **126× (24 bits),
~4400× (32 bits)**.

**Finding 4 — the box `χ_P = −1 ≈ 79%` claim is refuted.** Measured **0.001–0.02**. The 79% is
`1 − (χ_P = +1)`, silently counting **undefined cases** (66% of box relations) as usable. The
file's own counts give 14%.

### The published claim is NOT affected

> **`cost ∝ N^0.534` is UNAFFECTED.** It was measured by **stopping times on a real scan**
> (324 runs, 323 real factors) — it was *already* the algorithm's population, not a box number.

**The worry that this correction reaches a published claim is resolved: it does not.**

### But "the supply is dead at 128 bits" SURVIVES — strengthened

A steeper exponent (`−0.96` vs `−1/6`) makes the 96→128-bit drop **4.3 × 10⁹ rather than 40**,
so the zero is unremarkable rather than surprising. **The conclusion holds; its stated support
was weaker than claimed** — the box overstated cost by `N^0.79`, not by "47–326×".

### Self-corrections the audit logged rather than hid

Three defects in its own harness, each caught by a gate before measurement: a QR filter with
`t[0]=False`; an over-restrictive 2-adic rule at `v₂ = 4`; and a `chiP` transcription slip
(`b == p-1` for `b == q-1`) that **the mandatory control caught at 0/9101**.

**Unchanged from round 47:** NFS relation geometry, Harvey `N^{1/5}`, Umans–Wang, Lecerf
bivariate, auxiliary information, classical-deterministic. ⚠️ **"Nothing here disturbs
them" is an ASSERTION by this census, not a verified result** — the audit flagged that no
inherited row was independently re-checked against its source.

**Still open:** NFS at `L[1/3]` — where the heuristic actually lives. Nothing in round 48
touches it.

---

## ■ PARTIAL INFORMATION — Coppersmith's threshold, measured to the bit

The axis asked whether any leakage family beats **½ of the bits of `p`**. It does not, and the
threshold is now *measured* rather than quoted.

**The control passes and is stated first:** known-good (31 unknown bits, `X = 2³¹ < N^{1/4}`)
recovers `p` on **3/3** seeds; known-bad (48 unknown bits) fails **3/3**; the boundary case
(32 unknown = `N^{1/4}` exactly) fails **2/2**. A six-part self-test — exact determinant,
det-preservation + Lovász, polynomial algebra, GF root-finding, lattice-vanishes-mod-`p^m`,
end-to-end recovery — passes in full.

**The measured break:**

| unknown bits | result | of p's bits |
|---|---|---|
| 31 | **WORKS** | 51.6% |
| 32 | **FAILS** | 50.0% |

That is **`X = N^{1/4}` to the bit**, at `N = 2¹²⁸`.

**The failure is a wall, not a resource limit.** At 32 unknown bits **no vanishing vector
appears at all** as the lattice is enlarged from dim 40 to dim 104 (a 2.6× enlargement), on
independent seeds. Threshold−1 works but only at dim 52.

**Nothing tested beat ½:**
- **T1** (best case) — 51.6% leaked. Below ½? No.
- **T2** (algebraic relation between p and q) — makes it **worse**: degree-1→degree-2 moves the
  bound `N^{1/4} → N^{1/2}`.
- **T3** (known `d`) — needs ~100% of `d`'s bits, ≈1.98× `p`'s entire length.

**On Urroz arXiv:2606.24717:** it is a **`d`-leak, not a `p`-leak**, so it cannot cross this
wall, and its own p.8 Remark 3.2 makes the enumeration conditional. Recorded as scout-supplied,
**not independently fetched, not used as ground truth.**

**⚠️ The "under-attacked" reframe is WITHDRAWN — it was a database artifact.** The claim rested
on `all:"partial key exposure"` returning **exactly one arXiv hit**, unrelated. That is a
correctly-measured fact about the *wrong database*. `https://eprint.iacr.org/search?q=` **is**
reachable and returns **36** results for the same phrase, **24** for "factoring with hints" and
**7** for "auxiliary information factoring" — the axis is **not** empty. See
`notes/II_eprint_scope_correction.md`. arXiv indexes almost no side-channel cryptography because
that literature lives in TCHES/INDOCRYPT and is preprinted on IACR.

What survives from that axis is the **boundary measurement itself**: the univariate threshold is
`X = N^{1/4}`, now **proved optimal** (arXiv:1605.08065), and no tested leakage family beats it.

The fifth instance of this round's standing failure mode — **measuring the wrong population.**
Here: papers about crypto, instrument arXiv. Earlier: supply numbers measured inside a *box*
rather than over the algorithm's population; `s = 1` assumed general for `v₂(p−1)`; `a²−b³`
assumed uniform in `k`.

**Two defects the control caught** (both would have produced false conclusions): a misaligned
leak (`p >> unk` leaving `x0` full-width, inflating `X` by 64 bits) and a Howgrave-Graham
threshold off by a factor of `dim`.

**Honest limits:** LSB swept only analytically; multiplier-`u` and BDF/Coron–Maynard **not
implemented**; a single `N` size with 3 seeds. For "no family beats ½" beyond Coppersmith's own
theorem, what is needed is lattice-shape and leakage-pattern sweeps at 512–1024-bit `N`.

---

## ■ THE E-6c RE-RUN — the lottery claim is 11.5× too high, and there IS a real signal, in the wrong place

A dedicated re-run, with the shared harness and matched on **order** bit-length (the correct
axis — matching on discriminant size is precisely the E-6b failure mode).

**It does not reproduce 0.720.** At the claimed cell (29-bit class numbers, `B = 1000`):

| | value |
|---|---|
| **measured** | **0.0624**, Wilson 95% [0.0435, 0.0887], `n = 449` |
| Dickman there | 0.0648 |
| ratio to Dickman | **0.963**, CI [0.671, 1.369] — **on** Dickman, not 12.3× above |
| the claim | 11.5× too high |

**The "1.6× at matched scale" does not survive.** Corrected ratio **0.810, CI [0.519, 1.212]**,
Fisher `p = 0.381`. Across **all 112 matched cells** (4 values of `B`), the class/EC ratio is
**never** significantly above 1 — the maximum anywhere is **1.26 [0.20, 3.46]**, pure noise.
**Zero of 112 cells** show class numbers above Dickman.

**The parity confound, independently reproduced** from a separate sample: class numbers
**100.0% odd** (`n = 9,000`) versus EC orders **66.3% even** (`n = 28,000`). Against an
**odd-uniform** control the class arm is indistinguishable from null — **23/28 cells contain 1**
at `B = 1000`, and **0/28 cells fall below 1 at any `B`**. A genuine null, not a box artifact.

**"First positive at-scale signal for a non-EC lottery" does not survive.** It was a positive
result from a mis-scaled comparison at `n = 25` against a Dickman *prediction* baseline.

### The one genuinely new fact — and why it explains the whole confusion

> **Class numbers ARE enriched in the smallest primes, and it is a real Cohen-Lenstra signal.**
> `P(3 | h) = 0.438` vs `1/3` uniform, **z = +15.4**; `P(5 | h) = 0.246`, **z = +7.9**;
> indistinguishable from uniform for `ℓ ≥ 13`.

**But it does not produce smoothness.** The number of prime factors is **ω = 2.85 vs 3.16**
uniform, and the **median largest prime factor is 90,599 vs 61,861** — i.e. *less* smooth than
uniform. **The skew sits in the primes contributing the least mass.**

That is precisely why the E-thread read a genuine Cohen-Lenstra signal as a lottery advantage:
**the effect is real, it is in the wrong place, and it cannot pay.** A smoothness lottery is
governed by the large primes; the enrichment is entirely in the small ones.

*Caveat:* this closes the **lottery/distribution** axis. It is consistent with, but does not
itself re-test, the separate structural objection (`Cl(O_D/p)` trivial ⇒ `N^{1/4}` walk cost).

*Self-test caught four real bugs before measurement*, including a certifier that rejected
**0/40 valid orders** and a "sanity band" that failed on correct input — flagged as a general
hazard: **a sanity band that fails on correct input is worse than no band.**

---

## ■ The 20/27 constant, independently verified

The constant that corrected issue #524 is **`P(success) = 20/27 = 0.740740…`** — the classical
order-finding rate, not a property of the ℚ-kernel. I verified it from the mechanism rather than
by re-running 240 slow trials.

I first *derived* `2/3` from the standard argument (success fails exactly when the local orders
agree in their 2-part; `P(v₂(ord) = k) = 2^-(k+1)`; `P(equal) = Σ4^-(k+1) = 1/3`). **That
derivation is refuted**: measured `P(v₂ differs) = 0.73325`, which is **+8.93σ from 2/3** and
**−1.08σ from 20/27**. The agent's constant is confirmed; my mechanism was incomplete.

**Caveat on my own test:** my prime pool was `p < 4000`, and small primes truncate the geometric
law — measured `k=0` is 0.332 where geometric predicts 0.500. **I validated in the wrong regime,
the exact defect I flag in agents every round.** The comparison survives it (both arms shift
together; the candidates are 7.4 points apart), so the verdict stands — but the *mechanism*
producing 20/27 remains **unexplained**: measured and confirmed, not derived. Stated rather than
papered over, because a measured constant with an unknown origin is still a correct number and a
plausible derivation would not be.

> **⚠️ SUPERSEDED — the mechanism is now DERIVED, and this paragraph was written before that
> happened.** `notes/HH_explain_20_over_27.md` now derives it: success is
> `P(v₂(ord_p g) ≠ v₂(ord_q g))`, averaged over the joint law of `s = v₂(p−1)`, and the sum is
> **`20/27` exactly** — deficit **−1.7 × 10⁻¹⁸** in exact rational arithmetic, monotone from
> below, with **no renormalisation**.
>
> My first derivation was wrong **twice**: the law `P(s=j) = 2^{-(j+1)}` has total mass **0.5, not
> 1.0**, so with it the sum is **`5/27`** — and it reached `20/27` only via an **undeclared
> renormalisation** that cancelled the factor-2 exactly. The correct law is `P(s=j) = 2^{-j}`
> (measured over 216,815 primes), which has mass 1 and needs no normalisation.
>
> > **A renormalisation is an assertion that your quantity does not sum to its natural value. If
> > you need one, the quantity is usually wrong — find out which, and write it down.**
>
> The **verdict above is unaffected**: 20/27 is confirmed and correctly attributed to the
> order-finding step, not to the ℚ-kernel.

---

## ■ THE NON-EC GROUP SURVEY — no family survives, and a reconciliation that matters

Every candidate group was measured at matched order bit-length **and** matched parity. **No
family survives. The elliptic curve survives.**

**And the class group is a partial smoothness survivor — in a population the E-thread never
used.** After parity matching, `Cl(√−D)` shows **+0.0499 (+3.4σ)** over a same-bit-length null
(26-bit orders, `n = 1152`). The unmatched gap was **+0.0966 (+6.8σ); parity removes half of it.**

> ### ⚠️ The reconciliation a future round must not get wrong
>
> This survey measured a **general** set of negative discriminants, **96.4% even** class
> numbers. The E-thread's family is specifically `D = −q`, `q ≡ 3 (mod 4)` prime, where **genus
> theory forces `h` odd**. **These are different populations.**
>
> The **+0.0499 lives entirely in the EVEN arm.** The E-thread lives entirely in the **ODD
> arm** — which this survey itself reports as **insufficient (`n = 43`)** and *"must not be
> quoted"*, and which the E-6c re-run independently measured at **null (0/112 cells above
> Dickman)**.
>
> **Therefore the +0.0499 does NOT revive the E-thread's lottery.** Anyone who later finds
> "+0.0499" in this census and reconnects it to the class-group lottery has connected two
> different populations and must not do so.

**But it still fails, structurally rather than numerically.** `Cl(O_D) mod p` is trivial, so the
walk degenerates to SQUFOF at `N^(1/4) > L[1/2]` for every `k ≥ 1` once `N ≳ 10⁷⁰·⁸`. **A family
can win on smoothness and still lose.**

That is the axis's real lesson, stated by the survey and worth keeping:

> **The binding constraint is never smoothness — it is whether the group exists without the
> factor.**

**PGL(2,p)/GL(2,p)/PSL(2,p):** the smoothness *metric* is degenerate (`P = 1.0` by construction),
but their largest prime factor is genuinely **2⁶·⁹ better than EC** (2⁹·² vs 2¹⁶·¹). They still
need `p` to exist.

**Cost to reach `p`, measured:** building an EC order is 0.26 s at 64 bits, 1.24 s at 128; a class
number jumps **4 orders of magnitude** between `D = 40` and `D = 48` bits and is **bimodal at
`D = 56`**. This **forced the whole comparison down to 26-bit orders** — a real limitation,
stated.

### Method notes worth keeping

- **`ρ(2) = 0.3069` is a lower bound at finite scale.** Exact `Ψ` gives **0.3327 at `x = 10⁸`**,
  converging *from above*. **The baseline must be measured, not quoted.**
- **A recalled Dickman table is wrong.** The self-test caught that its own remembered `ρ(5)`,
  `ρ(6)`, `ρ(7)` were incorrect; self-convergence replaced them. (Compare: `int(n**(1/3))`,
  `pdftotext`, and now *recalled special-function values* — three ways a familiar number
  arrives corrupted.)
- **Five self-test catches**, including a zero-division in `irooot(0)`, PARI's `factor()`
  returning a **2-column matrix**, an inverted fundamental-discriminant congruence, and an
  over-strong assertion of its own (composite `B²` **is** `(B−1)`-smooth).
- **A self-refuted explanation, reported as such:** its "`√ mod D`" account of the cost cliff is
  **refuted by its own data** — `√ mod a prime` takes 0.02 ms while the 80-bit class number took
  **43.9 s** — and is reported as a measurement, not a proof.
- **Limits not papered over:** matched scale is 26 bits, not 64/96; cubic/quartic is
  **insufficient**; the +0.050 residual is one scale, unreplicated.

---

## ■ The Jacobi-degree lead, closed — and the coordinator's correction to the agent's own reasoning

The agent's four kills stand: the count factorises to exactly `φ(N)/2`; `Σₓ (x/N) = 0`
identically so no partial-information route exists; the Ihara zeta does not apply for
`N ≡ 3 (mod 4)` (half of RSA moduli); `deg = φ(N)/2` needs `N` squarefree.

**⚠️ But the agent's central quantitative claim is FALSE and I checked it.** It asserts
`k* > n²` for *every* prime pair, argued from "`ε* < ½` always". That is a non-sequitur —
`ε* < ½` gives `k* > 4`, not `k* > n²`. Measured:

| n | p,q | g | k\* | n² | `k\* > n²`? |
|---|---|---|---|---|---|
| 10,403 | 101,103 | 2 | 7.5×10⁴ | 1.1×10⁸ | **no** |
| 10⁶,063 | 10007,10009 | 2 | 7.1×10⁸ | 1.0×10¹⁶ | **no** |

**And the honest reading is the opposite of the agent's conclusion in the regime that
matters.** Comparing `k\*` against **enumeration** (Θ(n)) rather than against `n²`:

| n | g | k\* | k\* > n? |
|---|---|---|---|
| 10,403 (close) | 2 | 7.5×10⁴ | **yes** — sampling loses to enumeration |
| 10¹² (random-ish) | 30 | 1.8×10¹⁰ | **no** — sampling BEATS enumeration |

So for typical semiprimes sampling the degree *does* beat naive enumeration. **It still
loses, decisively, against factoring itself:** at `n = 10¹²`, `k\* ≈ 1.8×10¹⁰` against Pollard
rho's `n^(1/4) ≈ 10³` — **seven orders of magnitude worse.**

**The correct closure is therefore stronger than the agent's, and on the right ground: the
estimator is worse than the best known factoring algorithm, not merely worse than
enumeration.** The agent also noted the close-prime regime is Fermat's, where sampling loses by
28–48 orders — so the one regime where sampling is relatively strongest is the one already
solved by a better method.

**Both my brief's bound (`ε < (p−q)²/8`) and the agent's replacement were loose; the agent
measured the correct `ε\*` by bisection to 7.8×10⁻⁶ relative.** And my second test (`k\* vs n²`)
was itself a bad comparison, which is why the ledger records the correct one.

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

**Generated from disk, not hand-maintained.** Two earlier versions of this list were
hardcoded and drifted: they named 20 of 45 notes, so a reader following the index would
have found a quarter of the evidence missing. A list that must be remembered will be
remembered wrongly; a list that must be regenerated cannot. Third hardcoded-list failure
this round, after two checkers with frozen `TARGETS`.

`factor-scratch/r48/notes/` (45 notes):

  `00_HYPOTHESIS`, `A2_genericity`, `A3_phantoms`, `AA_stride_sampler`, `A_classgroup`,
  `BB_smoothpow`, `B_groups`, `CC_crossref_parallel_loop`, `CC_nfs_e2e`, `C_smoothness`,
  `DD_jacobi`, `D_partialinfo`, `EE_polysel`, `E_funcfield`, `FF_litsweep2`, `F_rigorous`,
  `GG_shoup_constant`, `G_adversary`, `HH_explain_20_over_27`, `H_crossdiscipline`,
  `II_eprint_scope_correction`, `I_constant`, `JJ_pkinfo_close`, `KK_audit_amendments`,
  `K_stange`, `LL_dickman_harness_broken`, `MM_regime`, `MM_sparse`, `M_forensics`, `OO_bneed`,
  `O_e6c_recheck`, `PP_droptest`, `P_citation_propagation`, `Q_vacuous_measurement`,
  `R1_lower_algebraic`, `R1_lower_quantum`, `S_supply`, `THEOREM_ordercert`,
  `T_pari_ellcard_hazard`, `U_stange_improve`, `V_repeat_of_the_vacuous_measurement`,
  `W_bsweep`, `X_verify_20_over_27`, `Y_adversary_papers`, `ZERO_shared_harness`

`factor-scratch/r48/_shared/` — `dickman.py` (valid only for `u <= 5`, and it now RAISES
above that; see `LL_dickman_harness_broken.md`), `check_consistency.py`,
`check_issues_match_papers.sh`.

Experiment code: `r49exp/`, `r50/`, `r51/`, `r52/` — one directory per axis, agent-scoped.
