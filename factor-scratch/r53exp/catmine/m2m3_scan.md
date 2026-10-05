# M2/M3 scan — Aristotle corpus, FactoringBarriers

**Scan date:** 2026-10-04. **Mode:** READ-ONLY on the corpus.
**Corpus actually mined:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/` (100 `.md`, rounds 42–60 and 96–109 — **rounds 61–95 have no files present**), `RESEARCH.md` (10408 lines), and, found by subagent and *outside* the stated root, `/home/raver1975/lean/Papers/*.md` (rounds 48–49 papers).
`Cryptography/Factoring/` and `Cryptography/AsymmetricExponent/` contain **no relevant material** — the entire evidence base for these closures is `FactoringBarriers/*.md` + `Papers/*.md`.

---

# PART M2 — how well is each PRO-closure actually supported?

Label used throughout: **PROOF** = an argument whose steps are written out and can be checked; **EXPERIMENT** = a measurement, sound only if controls are stated; **HAND-WAVE** = a conclusion with the load-bearing step unstated; **RESTATEMENT** = a cited theorem re-announced.

| # | Claimed closure | Best support in corpus | Type | Could the corpus have got there alone? | Verdict |
|---|---|---|---|---|---|
| 1 | Coppersmith `N^{1/4}` optimal (univariate) | `Round107_ResidueFirmFrontier.md:19-29` (R107); `Round97_FrontierAndOpenGap.md:57-63` (R97) | **RESTATEMENT, and internally contradicted** | No — CHHS ePrint 2016/869 is external | **OVERSTATED. See §M2.1** |
| 2 | Multivariate Coppersmith independence is a heuristic; arXiv:2111.14180 gives counterexample family + decidable test | `Round48_SUMMARY.md:285-291` (R48) | **EXPERIMENT on top of a citation** | No — the decidable test is 2111.14180's | **SOUND but NARROW. See §M2.2** |
| 3 | Class groups excluded (`h` B-smooth ∧ `p∣h` ⟹ `p ≤ B`) | `Papers/the_smoothness_wall_is_a_subgroup_wall.md:225-234` (R48, #522) | **PROOF (one line) — but imported** | **Yes** | **SOUND. See §M2.3** |
| 4 | LLL provably optimal on NFS lattices | `Round48_SUMMARY.md:314` and the PROVENANCE WARNING at `:406` (R48) | **WITHDRAWN BY THE CORPUS ITSELF** | — | **DO NOT RELY. See §M2.4** |
| 5 | GNFS constant `1.9229994 = (64/9)^{1/3}` immovable | `Round47_ConstantPinned.md:9-16, 44-56` (R47) | **PROOF (re-derivation), self-tested to 13 digits** | **Yes — and it did** | **STRONGEST OF THE EIGHT. See §M2.5** |
| 6 | Smoothness divisibility excess fully captured by sieve, zero headroom | `Round48_SUMMARY.md:242` and `:486` (R48) | **HAND-WAVE — and REFUTED by the corpus's own experiment** | No | **FALSIFIED IN-HOUSE. See §M2.6** |
| 7 | Stange Q-kernel success exactly `20/27`; `→8/9` Jacobi-conditioned | `Round48_SUMMARY.md:613-646` (R48) | **PROOF in exact rational arithmetic + multi-arm experiment** | **Yes — and it did** | **SOUND. See §M2.7** |
| 8 | Sieveability vs 2-adic coupling is a PHASE SEPARATION | `Round48_SUMMARY.md:67, 71` (R48 census, incorporating R51–R52) | **PROOF (identity) + EXPERIMENT** | **Yes — and it did** | **SOUND but NARROW IN SCOPE. See §M2.8** |

**Scoreboard: 5 sound (3 of them genuinely independently derived), 1 overstated, 1 withdrawn by the corpus, 1 falsified by the corpus's own experiment.**

---

## §M2.1 — "Coppersmith `N^{1/4}` optimal" is RESTATED and the corpus CONTRADICTS ITSELF on scope

The anchor is external in both statements:

`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round97_FrontierAndOpenGap.md:57-63` (R97):
```
57	**What is closed.** Chinburg–Hemenway–Heninger–Scherr (ASIACRYPT 2016,
58	ePrint 2016/869) proved Coppersmith's univariate `N^{β²/d}` bound optimal **within
59	the univariate auxiliary-polynomial class** `h = Σ a_{ij} x^i (f/N)^j`, degree-free
60	and lattice-free, so no auxiliary polynomial of *any* degree reaches
61	`N^{1/d+ε}`.
```

`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round107_ResidueFirmFrontier.md:24-29` (R107) says the *opposite* about the same paper:
```
24	**The gap they leave (still open):** their theorem covers the **mod-`N`
25	univariate** case. There is **no capacity-theory optimality theorem for the
26	`N^{β²/d}` bound for a root modulo an *unknown divisor*** (our setting), and
27	they list the bivariate-integer / divisor cases as open future work. So the
28	*frontier we sit on* (`β=1/2`, `d=1` → `N^{1/4}`) is conjecturally optimal but
29	**not yet proven optimal** — the open bit is narrow and precise.
```

And `Round48_SUMMARY.md:280-284` (R48) is bluntest of all:
```
280	**And R1 explicitly EXCLUDES our row.** p. 6 §2.3.1, verbatim: it covers *"univariate
281	polynomials modulo integers"*, and *"Adapting these results to the other settings"* — having
282	just listed *"factoring RSA moduli `N = pq` **when half of the most or least significant bits of
283	one of the factors `p` is known**"* — *"is a direction for future research."*
284	
285	**So our measured `X = N^{1/4}` is a CONSTRUCTURE for this problem, not a theorem.**
```
(line 285 verbatim reads *"is a CONJECTURE for this problem, not a theorem"*).

**Independent reachability:** no. CHHS is a capacity-theory paper from 2016; the corpus read it and re-announced it. **Agreement between R97 and CHHS is not confirmation — R97 *is* CHHS.**

**What the corpus did contribute:** its own measurement of the threshold, at `Round48_SUMMARY.md:503-530` (R48) — 31 unknown bits WORKS / 32 FAILS, a six-part self-test, and a control that the failure is a wall not a resource limit (*"At 32 unknown bits **no vanishing vector appears at all** as the lattice is enlarged from dim 40 to dim 104"*). That is a genuine EXPERIMENT, and it locates the boundary; it does **not** prove the boundary is optimal.

**⚠️ INTERNAL CONTRADICTION TO CARRY FORWARD:** R97 and R107/R48 give *incompatible* accounts of whether CHHS covers the `N^{β²/d}` (unknown-divisor) bound. **Not determinable here** which is right without fetching ePrint 2016/869 §2.3.1. Two round files assert one thing, one asserts the other.

## §M2.2 — Multivariate independence: a real decidable test, but the corpus over-reached once

`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md:285-291` (R48):
```
287	**What R2 settles.** Chinburg et al., arXiv:2111.14180, supplies a **decidable test** for
288	algebraic independence, now implemented. On realistic 2-sample HNP instances it returns WORKS
289	(γ ≈ 0.005–0.09, an independent function provably exists) and crosses to FAIL at larger `X`
290	(WORKS at `X = 180`, **FAIL at `X = 321`**, where the method is *provably impossible*). And the
291	fire rate is **not rare**: for `X ≥ ⅓√p`, **100% of instances provably fail independence**
292	(4980/4980 already at `c = 1/4`).
```

The corpus's own scope note, `Round48_SUMMARY.md:293-299`, is the important part:
```
296	- **Multivariate independence is still a heuristic**, stated as "Assumption 1" (CRYPTO 2025,
297	  2024/1330 p. 11) and "Heuristic 1" (EUROCRYPT 2025, 2024/1577 p. 6), with **no post-2021
298	  follow-up by any of the four authors**.
```
and `:290-292` limits the result to *"**only in the two-variable linear subcase**, which is not the
same as closing the multivariate axis."*

**Type: EXPERIMENT wrapping a citation.** The implementation and the 4980/4980 count are the corpus's; the decidability is 2111.14180's. **Could the corpus have got there alone? No** — the test is the cited contribution. Note the measurement is at `X = 180/321` and `c = 1/4`, i.e. tiny moduli; it is a mechanism probe, not a result at RSA scale.

**Corroboration note (this is the honest bit):** the closure does **not** rest on a single unvalidated experiment, because it is consistent with three independent strands — the citation, the implemented test, and R107:50-54 independently reproducing the *same* redundancy from the literature side (*"Coppersmith's rigorous bound … is `X = Y = N^{1/6}` — **worse** than `N^{1/4}`"*). Two of those three are still citation-adjacent, so treat the strength as "well-supported in the weak sense that three strands agree", **not** as three independent confirmations.

## §M2.3 — Class groups excluded: a genuine, tiny, imported proof

`/home/raver1975/lean/Papers/the_smoothness_wall_is_a_subgroup_wall.md:225-234` (R48, paper #522):
```
225	> **If `h(−kN)` is `B`-smooth and `p | h(−kN)`, then `p ≤ B`.**
226	> At the bound that matters, `B = L[1/2] ≈ exp(√(2 ln p · ln ln p))`, and `p ≤ exp(√(2 ln p ln ln p))`
227	> is **false** for all sufficiently large `p`, since the right-hand side exceeds `p`
228	> super-polynomically.
229	
230	**So the conjunction required by the walk — `p | h` AND `h` `B`-smooth — is INCONSISTENT at the
231	relevant bound, not merely improbable.** No amount of `k` helps: increasing `k` enlarges `h`
232	(and so the smoothness bound needed), while `p ≤ B` only gets harder to satisfy.
233	
234	Combined with the structural result of §3.4 — **`Cl(O_D) mod p` is trivial in both cases**, so
235	the walk degenerates to SQUFOF regardless of smoothness — the exclusion is **unconditional**.
```

**Honesty flag in the corpus's own favour:** line 223 says *"it was pointed out by the adversarial audit"*. This is an **import from the corpus's own auditor**, not a derivation.

**Independent reachability: YES.** `p | h` and `h` B-smooth ⟹ `p ≤ B < p` is one line of elementary reasoning requiring no citation. That the corpus treats it as *"a categorically different status from every other closure in this program's census"* (`Round48_SUMMARY.md:100-102`) is a comment on its own earlier failures, not on the mathematics.

**There is also a SECOND, fully independent route** — `the_smoothness_wall_is_a_subgroup_wall.md:250-257` records a separate agent, *"dispatched on a different axis with no access to the argument above"*, reducing the walk to SQUFOF and measuring *"**19 of 19 factors found had `a_k` exactly `p`**"*. That leg is genuinely independent and empirical.

**Third, independent of both:** `RESEARCH.md:3052-3092` (running notebook, dated 2026-09-24; **exact round not determinable here**) gives an information-theoretic counting proof that *no* fixed-`K` map `H : N = pq ↦ Cl(K)` can carry `p`, since `|Cl(K)| = h(K) = O(1)` bits against `n − log₂ n + O(1)` needed. **This one has an in-corpus correction** at `RESEARCH.md:3073-3092` — the original counting set was degenerate (`{N}`, a singleton) making injectivity vacuous, and was repaired to `S_n`. Note the corpus's own standing rule at `RESEARCH.md:3078-3079`: *"If a row here contradicts its note, the note wins."*

**Supporting measurement:** `p | h(−kN)` observed **0/890** (`the_smoothness_wall_is_a_subgroup_wall.md:170`), replicated 0/500 by the audit at `:239`.

**Verdict: the best-supported closure in the set that is actually about factoring mathematics.** It rests on elementary reasoning plus two independent routes, none of which needs an external theorem.

## §M2.4 — "LLL provably optimal on NFS lattices" is **WITHDRAWN BY THE CORPUS**

`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md:314` (R48 census):
```
314	| GNFS constant via BKZ past LLL | **no gain found; "provably nothing" WITHDRAWN** | 40/40 give LLL/SVP = 1.0000000000 on the *certified* lattices. ⚠️ But the census's **mechanism sentence is not measured and the note's own control contradicts it**: `I_constant.md:26` records LLL/SVP ∈ [1.000, **1.149**] and S4b finds LLL **strictly suboptimal 1/60**. Also **Montgomery normalisation is absent — 0/40 rows m-divisible** ... Honest status: **no constant improvement demonstrated on the lattices tested** |
```

and the PROVENANCE WARNING, `Round48_SUMMARY.md:406` (R48):
```
406	| BKZ / LLL | "CLOSED — provably nothing" | **withdrawn**; no gain demonstrated on the lattices tested; note's own control gives LLL/SVP up to **1.149** and finds LLL suboptimal 1/60; Montgomery normalisation absent (0/40 rows m-divisible) |
```

**This is the one closure on the list that fails the user's own test — it rests on a single unvalidated experiment, and the corpus's own adversarial audit killed it.** Specifically: the headline 40/40 = 1.0000000000 is from **certified exact-SVP on 40 of 119 configurations**; the other 79 were discarded (`Round48_SUMMARY.md:330-331`); Montgomery normalisation was never applied; and a control inside the same note finds LLL up to 1.149 off optimal and strictly suboptimal in 1/60 cases. The prose at `:326-328` ("LLL is already at its optimum, and better reduction cannot help") is a **HAND-WAVE that the same file retracts sixteen lines later.**

**Do not carry this closure forward.** If a constant improvement is needed, the honest statement is *"no gain demonstrated on 40 certified NFS-shaped lattices"*, which is much weaker.

## §M2.5 — GNFS constant: the strongest genuine derivation in the corpus

`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round47_ConstantPinned.md` (R47), self-tested to 13 digits:

`:9-13`:
```
T1  min 2·max(a,b) = 1.922999427076593   (target …544);  a/b = 1.000000000289
    gamma = 1.44225 = 3^{1/3};  kappa = 3.0000                                    PASS
```
`:44-48`:
```
It has a **unique minimum at `κ = 3`**, giving `64/9`. Numeric vs closed form: `rel. err
1e−16` at `κ = 1.5, 2, 2.5, 3, 4, 6, 10`.
```
`:50-56`:
```
Solving `C(κ) = 1.9018836` gives
> `8κ² − 45.914778κ + 69.914778 = 0`,  **discriminant `−129.106`**
> **NO REAL `κ` PRODUCES `1.9018836`.** The minimum of the entire LGST model class is
> `1.922999427077`, a **+1.098%** gap above it.
```

**Why this one is different from the rest:** it is a **PROOF of a model-internal statement** (the constant is pinned at `κ=3` within the Lee–Montgomery model class; the smoothness half of the constraint is inert — `:28-42`, with a sensitivity table showing an artificial `L = ±100` moves the objective only to `1.3e−1 / 3.5e−5`). It could and **did** reach the result independently — the target `1.922999427076544` was treated as a *control*, not an input, and the derivation reproduced it to 12 digits.

**Honest limit, stated by the corpus itself** — `Round48_SUMMARY.md:242`:
```
| **The NFS constant `1.9229994`** | **CANNOT BE MOVED — and cannot be TESTED here** | At the NFS-optimal factor base, `π(B*) ≈ 8.6 × 10¹⁵` at 768 bits and **`≈ 3.1 × 10³³`** at 2048 bits: **at every size anyone factors, the optimal factor base contains more primes than the host has RAM.** A measured constant would have to be extracted from an uninstantiable regime. The one testable component WAS measured: exact `Ψ` **exceeds** Dickman `ρ` by **9.2–21.9%**, which biases the true constant **downward**, and the bias **vanishes as `B → ∞`**. **`1.9229994` stands in the limit** |
```

So: **the constant is pinned *within the model class*, and the model class has never been tested at a real size.** That is the correct scope and it is the strongest of the eight.

## §M2.6 — "Zero headroom" is **FALSIFIED INSIDE THE CORPUS**

The closure as propagated:
`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md:242` (R48):
```
242	| **The `2 − 1/p` excess (paper #523's open item)** | **FULLY CAPTURED — provably. ZERO headroom** | The excess is carried **entirely** by the `p ∣ b` stratum; on `p ∤ b` the rate is **exactly uniform** `1/p^k`. The NFS sieve marks a cell iff `p ∣ F(x,y)`, so **its mark rate is `r_p/p` exactly**. The divisibility is real and **the sieve already divides it out.** This retires #523's stated open item, and is the answer to whether round 48's one positive finding has any cash value: **none** |
```
repeated at `Round48_SUMMARY.md:486`.

**The same corpus, same file, contradicts it** — `Round48_SUMMARY.md:258`:
```
| NFS smoothness uniformity | **DEVIATION FOUND (positive)** | `P(p^k | a²−b³)/p^k = 2−1/p` for odd `p`, **2 ≤ k ≤ 5** (departs at k=6) — the heuristic is **pessimistic**. **The 25–38% figure is WITHDRAWN by audit; the measured replacement is 14.1% [13.3,15.0] at u≈3. AND THE GAIN IS LOCALISABLE** — the best mod-4 sub-box beats the global rate at EVERY operating point (5.65× at u=6, 2.04× at u=3), so a sieve *could* be aimed at it. That is a STRONGER result than the withdrawn claim, not a weaker one |
```

**And the primary source, `/home/raver1975/lean/Papers/a_square_minus_a_cube_divides_twice.md` (R48, paper #523), says so in its own words** — `:311-314`:
```
311	**The gain SURVIVES sieving — the audit's "every net gain < 1" is false.** Among pre-sieve
312	survivors the ratio is unchanged (1.706 vs 1.687 over all candidates at `u = 4`), and 12–16 of
313	16 mod-4 and 7–9 of 9 mod-3 sub-boxes have ratio > 1. A `k = 1`-only sieve is strictly **worse**
314	(0.63–0.65) — a sharp prediction from `r_p(1) = (p−α)/(p−1) < 1` that held.
```
and `:334-337`:
```
335	| 6.00 | 28.40 | 5.02 | **5.65×** |
336	| 3.00 | 2.60 | 1.27 | **2.04×** |
337	The maximum sub-box beats the global rate at **every** operating point, 12–16 of 16 mod-4 and
338	7–9 of 9 mod-3 cells exceeding 1. **So the excess is LOCALISABLE and a sieve could be aimed
339	at it.** The earlier "not an implementable speedup" was wrong, and it understated the result.
```

**Type: HAND-WAVE, and the load-bearing step is not even written down.** The claim equates `r_p/p` (a sieved-residue-grid rate) with the `2 − 1/p` law (a statement about `a² − b³` as an integer). Nothing in the corpus bridges those. And the programme **ran the experiment that answers the question and then propagated the opposite row.**

**The corpus states the mechanism of its own failure** — `Round48_SUMMARY.md:244`:
> *"(table rows propagate, prose caveats do not)"*

…which is precisely the rule that guarantees rows `:242`/`:486` survive and row `:258` does not. This is the **worst-supported** item on the list and it should be treated as **open, with measured localisable headroom of 14.1% [13.3, 15.0] at `u ≈ 3`** — a live lead, not a closure.

## §M2.7 — Stange Q-kernel `20/27` and the Jacobi lift to `8/9`: sound

`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md:635-640` (R48):
```
635	> **`20/27` exactly** — deficit **−1.7 × 10⁻¹⁸** in exact rational arithmetic, monotone from
636	> below, with **no renormalisation**.
637	>
638	> My first derivation was wrong **twice**: the law `P(s=j) = 2^{-(j+1)}` has total mass **0.5, not
639	> 1.0**, so with it the sum is **`5/27`** — and it reached `20/27` only via an **undeclared
640	> renormalisation** that cancelled the factor-2 exactly. The correct law is `P(s=j) = 2^{-j}`
641	> (measured over 216,815 primes), which has mass 1 and needs no normalisation.
```

**PROOF** (exact rational arithmetic, deficit `−1.7×10⁻¹⁸`) plus an **EXPERIMENT** (216,815 primes), plus the corpus volunteering its own two failed derivations and naming the generalisable lesson (`:643-645`: *"A renormalisation is an assertion that your quantity does not sum to its natural value. If you need one, the quantity is usually wrong"*).

The `8/9` lift, `Round48_SUMMARY.md:244`:
> *"uniform `20/27 = 0.740740… → conditioned `8/9 = 0.888889…`, ratio exactly 1.200000×` … **Verified: exhaustive 210/210 cells zero error; MC z = −0.56, +0.07; an independent reimplementation (own MR/Legendre/Jacobi, no sympy) z = +0.06, +0.54, 0/7197 violations**"*

**Independently reachable: yes, and reached** — the corpus re-derived `20/27` from mechanism rather than re-running the 240 trials (`:617`: *"I verified it from the mechanism rather than by re-running 240 slow trials"*), then had to throw that derivation away and get it right twice. That is the profile of a real derivation.

**Scope caveats the corpus flags itself and that must travel with the number:**
- `Round48_SUMMARY.md:244`: *"⚠️ **SCOPE: this is 1.2× on the 5%. Relation-finding is 95% and IS the NFS. NOT a factoring advance**"*.
- Optimality is claimed only over `g` computable without factoring, *"because separating the Legendre symbols **is** factoring"* (`Round48_SUMMARY.md:66`).

## §M2.8 — Phase separation: sound, but the scope is narrower than "no construction gets both"

`/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md:71` (R48 census, incorporating R51–R52):
```
71	| **⛔ Can any construction be BOTH sieveable and > 20/27?** | **NO — and it is a PHASE SEPARATION, not a tradeoff** | **Sieveability is a property of the SEARCH; `20/27` is a property of the BASE** (`v₂(ord_p g) ≠ v₂(ord_q g)`). **No construction gets both.** Measured on the candidate: a polynomial condition carries **NO 2-adic coupling** — CRT makes independence exact, ratio **0.93–1.10, |z| ≤ 1.50** across 5 sizes, each with >=170 expected hits. **A sieveable construction destroys exactly the material the 20/27 barrier is made of.** And the round-51 `GAIN` cap **provably cannot bind on a sieve**, since a sieve MARKS residue classes and GENERATES survivors, so **`q = 1` by construction** — proved by identity (sieve vs brute force returned **identical sets, 135=135 and 379=379 on 6/6 cells**). So the barrier is not the `q`-term; it is that **periodicity in the search and 2-adic coupling in the base live in different phases.** |
```

The supporting half, `Round48_SUMMARY.md:67`:
> *"⚠️ **CORRECTED BY ROUND 52: this census previously said Stange's hit set is APERIODIC. It is PERIODIC** — with period `ord_n(g)`, measured at `ord_n(g)/n = 1.000`, i.e. **798× / 1813× / 5334× the sieve limit**… **Sharper still (round 52): a relation condition admits a sieve IFF the sieved quantity is a POLYNOMIAL in the sieve index** — GNFS, SNFS, Dixon-interval and ECM stage-2 all qualify; Stange and Dixon-direct do not. Dixon is the clean proof of the mechanism: **the same method is periodic when you sieve the interval (`ℓ ∣ y`) and aperiodic when you sieve `x² mod n`, 6/6 primes — only the expression changed.**"*

**Type: PROOF (by identity, `q = 1` for a sieve) + EXPERIMENT (Dixon's 6/6, the 5-size CRT-independence scan).** Independently reachable: **yes, and reached** — the Dixon control is a genuinely elegant falsification test that isolates one variable.

**Scope limit to carry:** the argument is about *Stange's specific base condition* `v₂(ord_p g) ≠ v₂(ord_q g)`. `|z| ≤ 1.50` is **under 1.5σ** — that is "consistent with independence", not "proved independent". The `q = 1` identity is rigorous; the "no construction gets both" is generalised from one base.

---

## §M2.9 — one more M2 item the corpus supplies that was not on the list

**Rigorous `L[1/2]` already exists, and the constant is not 1 but 2** — `Papers/sharper_proved_l_half.md` (R49, paper #527) `:22-31`:
```
22	> **`2√2 → 2`, proved and unconditional.**
...
24-27	"The removable square comes from Theorem 15.1's exponent `u log log x` where the sharp Dickman–de Bruijn exponent is `u log u`; at the balanced application point `log u = ½ log log n − ½ log log log n + O(1)`, so Shoup's exponent over-charges by exactly 2."
30-31	"**`√2` would require `a < 2`, i.e. ECM — whose `√2` is a *heuristic*, so **there is no proved unconditional `√2`**."
```
This is a real constant-factor improvement to a proved bound, with an optimality statement attached. Nobody will use it (constant factor), but it is the only place in the corpus where a *proved* bound is genuinely moved rather than recorded.

**Shoup Thm 15.6 itself is a pure RESTATEMENT** (`Papers/the_smoothness_wall_is_a_subgroup_wall.md:70, 104-106`, R48). The corpus adds one thing of its own — discharging the residual hypothesis by costing `π(y)` (`:88-90`: *"The one residual assumption … is **discharged**, not assumed away"*). **Could the corpus have reached Shoup independently? No** — and it does not pretend to; it treats it as background.

---

# PART M3 — three axes nobody on either side has touched

Scored on (a) genuinely open, (b) tractable-ish, (c) not closed by a later round. **Each was checked against every later round file in the corpus.**

---

## M3-1 ★★★ — The total-weight question `Σw > 3/2`: a single decidable number, formalised in Lean, no scheme exhibited

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/RESEARCH.md:9611-9619`
**Round:** running notebook §8 item 6, **dated 2026-09-24** (`RESEARCH.md:9612` — *"new 2026-09-24; §7 'the balance dilemma'"*). **Exact round number not determinable here** — no `RoundNN_*.md` file exists for it, and round files 61–95 are absent. The formalisation is in `HarveyFloor.lean` (`RESEARCH.md:3649`: *"`HarveyFloor.lean`: `required_weight`, `one_fifth_needs_weight`"*).

VERBATIM, `RESEARCH.md:9617-9619`:
```
9617	> **OPEN.** Is there a deterministic search-floor scheme whose total
9618	> denominator weight satisfies **`Σwᵢ > 3/2`**?
```

And why it is well-posed, `RESEARCH.md:9628-9632`:
```
9628	  * **The required value is a specific number, not a direction.**
9629	    `required_weight` gives `Σw ≥ γ/e − 1`. At `γ = 1/2`: `1/6` needs `Σw ≥ 2`,
9630	    `1/8` needs `Σw ≥ 3`. Harvey and GFHP both sit at `3/2`.
9631	  * **It reclassifies the recent literature.** Every advance in the record —
9632	    Harvey–Hittmeir, Oznovich–Volk, the order-threshold relaxations, GFHP's
9633	    `lg^{13/5}` — moves the **constant** (a log factor, a hypothesis threshold)
9634	    and leaves `Σw = 3/2` untouched.
```

The corpus's own honesty limit, `RESEARCH.md:9661-9664`:
```
9661	> **The honest limit, restated because it is the whole risk here.** I have
9662	> **not** established what the weights `wᵢ` are mechanically, and I have not
9663	> exhibited a scheme with `Σw > 3/2`. This entry is a **question**, precisely
9664	> stated, with the requirement quantified — nothing more.
```

**Why promising, one line:** it is the only item in the corpus where the target is a *specific number* (`Σw > 3/2`, then `≥ 2`, then `≥ 3`), the question is decidable by inspection of any proposed scheme, and **both answers are results** — `RESEARCH.md:9653-9657`: *"A *lower* bound … would show `Σw = 2` is unreachable in this shape and kill the weight route outright, which is as valuable as finding a scheme that beats `3/2`. Either answer is progress."*

**Later rounds: partially advanced, NOT closed.** `Round52_IntrinsicBarrier.md:30-46` (R52) ablates Harvey's four cost terms one at a time and finds three *independent* constraints pinning `r = m = N^{1/5}` exactly:
```
33	**(b) But deleting any of the three survivors collapses it to `N^{0.0025}`.**
34	They are three *independent* constraints, not one constraint counted three
35	times. **So `N^{1/5}` is not over-determined in the sense of "redundant"; it is
36	exactly tight on three separate axes.** Any genuine improvement must defeat at
37	least one of them.
```
That is a partial lower-bound structure for the weight route — but it produces **no scheme above `3/2` and no proof that `2` is unreachable**. `Round52_IntrinsicBarrier.md:140-141` states the residue: *"**Everything else on the deterministic frontier is now closed to me at this level of analysis.**"*

**Grep evidence for non-closure:** no file in `Round96*`–`Round109*` contains the strings `Σw`, `required_weight`, or `beating_one_fifth_requires`.

**Caveat to weigh:** `RESEARCH.md:9661-9662` says the weights `wᵢ` are **not mechanically defined**. That is a serious gap — you cannot compute `Σw` for a scheme you cannot formalise. This is the honest cost of attacking it, and the corpus states it up front.

---

## M3-2 ★★ — Bound `t` for rank-2 UMW gaps: one integer decides whether a whole conditional route lives

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round60_HeSahaiProof.md:169-175`
**Round: 60.**

VERBATIM:
```
169	**Open, in order of expected value:**
170	
171	1. **Bound `t`**: the maximal number of primes of the band
172	   `(n^{1/2−ε}, n^{1/2}]` dividing a difference `a₁Δi + a₂Δj` of a rank-two gap
173	   with `ab ≤ n^{2/3}`. If `t = O(1)` the Umans–Wang route is dead outright; if
174	   `t` can grow like `n^{1/6}`, `(1/3,1/3)` survives. **This is the single
175	   question that decides whether an entire conditional route is alive.**
```
and the corpus's own disclaimer at `:165-167`:
```
165	  band — then rank-2 escapes after all and Round 58's "rank-2 is the live residue"
166	  is correct. **The decisive quantity is the largest number of band primes
167	  dividing a nonzero rank-2 gap difference. Nothing here bounds it.**
```

**Supporting statement of the same quantity as a named conjecture**, `Round60_HeSahaiProof.md:98-106` (R60):
```
 98	> **If `t = polylog(n)` for the blocks arising from a rank-two gap, He–Sahai's
 99	> `n^{3/4}/√(log n)` bound survives for rank 2** — and since `n^{3/4} ≫ n^{2/3}`,
100	> the `(1/3,1/3)` point stays excluded for rank 2 as well.
...
103	question, and it is a reduction, not a resolution. Whether `t = polylog(n)` holds is a genuine smoothness question
105	about the differences `a₁Δi + a₂Δj` of a rank-two gap — not something a
106	line-of-reasoning settles. I state it as a conjecture (C′) and do not claim it.
```

**Why promising, one line:** it is a *single measurable integer* — the largest number of band primes dividing one difference — so it can be **measured directly** by enumerating rank-two gaps with `ab ≤ n^{2/3}`, and the measurement either confirms or refutes the whole conditional route in one shot.

**Non-closure check (I ran it):** `grep -ln "band prime\|largest number of band\|rank-2 gap\|rank-two gap"` across `Round96*.md Round97*.md Round98*.md Round99*.md Round10*.md RESEARCH.md` returns **no files**. Nothing after round 60 touches it. Rounds 96–109 are entirely residue/Coppersmith/IFP/batch territory.

**Adjacent, still live from R59** — `Round59_Rank2Escape.md:142-148` (R59):
```
142	 1. **The correlation question**, now precisely posed: does the rank-1
143	    single-integer-bottleneck (which He–Sahai converts into an incidence
144	    structure) have a rank-2 analogue? Two coefficients might genuinely relieve
145	    it — the AP's bottleneck is that one `b` must satisfy all moduli at once, and
146	    rank-2 gives two degrees of freedom. **This is the single highest-value
147	    question in the project**, and it is now a sharp yes/no rather than a vague
148	    "additive separability".
```
Round 59 tested and **eliminated** the first-moment and count angles (`Round59_Rank2Escape.md:131-135`), leaving correlation only — which is exactly what makes it tractable.

---

## M3-3 ★★ — The shape-aware sieve: the corpus's own "best-motivated untried idea", untouched for 58 rounds

**File:** `/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round51_ShapeGap.md:162-166`
**Round: 51.**

VERBATIM:
```
162	- **(A) The shape-aware sieve.** Now the best-motivated untried idea in this
163	  project: the gap is `N^{1/12}` on `a^k b`, and the shape is *free* to read
164	  (`a` is visible in `v_a(n)`). The missing piece is a sieving primitive that
165	  exploits a known valuation structure. I do not have one; this is a research
166	  problem, not a calculation.
```
The underlying observation, `Round51_ShapeGap.md:113-114`:
```
113	obvious question: **is there a shape-aware sieve?** One that picks the
114	polynomial/number field using `minFac N`, and so wins back the `N^{1/12}` the
115	sieves lose on `a²b`.
```
and `Round51_ShapeGap.md:130-133`:
```
130	sieves lose on `a²b`, and a shape-aware sieve would have to recover
131	all of it while doing strictly harder arithmetic than rho.
132	
133	So the honest reading is: **on the `a²b` shape the right answer is "use rho", and
```
⚠️ **Read `:129-133` carefully — the corpus then partly walks it back** ("the right answer is 'use rho'"). It names the idea as best-motivated *and* says the `a²b` case is probably not the venue. **Both are in the file.**

**Why promising, one line:** sieves are *provably* shape-blind (`Round51_ShapeGap.md:65-67`: *"`ShapeGap.sieve_cost_shape_blind`"*, formalised in `ShapeGap.lean`, 0 `sorry`) while the shape parameter is **free to read off `n`** — the corpus notes a sieve that needs to *discover* the shape is doing no work, which removes the usual discovery bottleneck and leaves only a genuinely new sieving primitive.

**Non-closure check (I ran it):** `grep -n "shape-aware\|shape aware" *.md` returns **only** `Round51_ShapeGap.md` — lines 113, 122, 126, 132, 162. **No round 52–109 file mentions it.**

**Caveat:** `Round51_ShapeGap.md:66` says *"and I have not seen it tabulated"* about the crossover — the corpus's own citation discipline means Mulder's `arXiv:2308.06130` and the crossover number both deserve an independent check before building on them.

---

## M3 — runners-up, recorded so they are not re-litigated

These are live but weaker, or partially superseded. Included because each is a plausible attack and the corpus's own status marker is worth having:

- **The coupled bivariate lattice** (R97) — `Round97e_LatticeRootCause.md:67-70`: *"does a **coupled multivariate auxiliary-polynomial system** — jointly chosen shift polynomials in the two coupled unknowns, exploiting `p·q=N` — admit a short-enough combination to reach `|x| < N^{1/4}` on **fewer than `n/4` known bits**?"* With an unblocked instrument at `Round97f_ValidatedCoppersmith.md:74-79` (*"**Either outcome advances the one open question**"*). **Both outcomes are results.** Note R107:78-81 says this route is *"blocked in round 97g on a reference Jochemsz–May implementation"* — implementation-blocked, not idea-blocked.
- **Harvey's own published `N^{1/6}` question** (R50) — `Round50_HarveyHittmeir.md:85-89`, quoting `arXiv:2010.05450` p. 8: *"An interesting question is whether it is possible to obtain a fully square-root speedup for Lehman's original choice `r ≍ N^{1/3}`."* And `:44`: *"as far as I can tell **nobody has picked it up**"*. Author-posed, external, citable — the safest possible provenance. ⚠️ `Round52_IntrinsicBarrier.md:136-139` reframes it: *"**Still open, and now precisely stated:** defeat the **pair count** `r = N^{1/5}`"* — and Round 50 measured that the good pair is a convergent of the hidden `p/q` (23/24) and *"cannot be predicted below the cost of finding it"*. So this is live but has a known blocker.
- **A `poly(log N)` convergent of `p/q`** — `RESEARCH.md:9686-9687`, and `RESEARCH.md:9707-9708`: *"(i) An unconditional way to get **any** convergent of `p/q` from `N` in `o(N^{1/2})` — this alone would beat Fermat and is not known."* **Round not determinable here.** `RESEARCH.md:9716-9718` records that the negative answer is worth as much as the positive.
- **Greg Martin's conjecture for structured sequences** — `RESEARCH.md:7296-7298`: *"**The exact open lemma:** prove an unconditional `Ψ_F(x,x^{1/u}) ≤ C·x·∏ρ(d_i u)` (or `≤ x^{1−δ}`) for `F=t²−N` and the NFS linear form."* A single formally-statable analytic lemma, named as such. **Round not determinable here** (`RESEARCH.md:7292` refers to round 38).
- **An explicit aligned GAP cover in `γ < 0.4`** — `Round96b_BirthdayObstruction.md:111-112` (R96b): *"What remains open is exactly the one hard thing: an **explicit, deliberately aligned** GAP cover in `γ < 0.4`. Neither this note nor round 96 produces it."* The counting has slack in `[1/3, 2/5)` (`:108-110`), so the target is a construction, not an impossibility. ⚠️ `Round103c_RoughSemiprimeWall.md:78-80` (R103c) reports two independent necessary conditions both forcing `γ ≥ 1/2`, so the viable window may now be empty — check before investing.

---

# CITATION INTEGRITY — flags

The corpus audits itself here and the audit is good. `Round48_SUMMARY.md:189-191` (R48):
```
189	**41 references fetched and confirmed · 8 defective (right paper, wrong venue/volume/authors)
190	· 3 outright fabricated.** Roughly an 8% defect rate, with a **100% catch rate** once an agent
191	was told to verify rather than accept.
```
and `:199-203` records that the defect **propagates agent → sub-agent**, and that *"the repair apparatus introduced fresh defects of exactly the kind it was built to catch"*.

### ⚠️ Flag 1 — a known-fabricated arXiv ID is STILL LIVE in the corpus, un-flagged at point of use

`Round48_SUMMARY.md:207` (R48) states the correction:
```
207	corrected NSSV ID is **arXiv:2110.08354**, not `2601.17422`; BLP is **LNM 1554 (1993)**.
```
But the **wrong ID is still used twice, in `Round46_Handover.md`**, with no correction marker:
- `Round46_Handover.md:31` — *"`(n^{1.343}`, arXiv:2601.17422) would push DDF to `n^{1.843}` — and that paper makes no factoring [claim]"*
- `Round46_Handover.md:124` — *"⚠️ NSSV's 'broke the 3/2 barrier' (JACM 71(2) 2024; **arXiv:2601.17422**) is about **modular composition**"*

**`arXiv:2601.17422` should be treated as a phantom identifier.** The correction was never propagated to the file where it is used.

### ⚠️ Flag 2 — arXiv IDs I could NOT verify from this host

The corpus cites many 2025–2026 IDs. I attempted `export.arxiv.org` and it returned empty for `2111.14180`; per this machine's known route history (publishers 403, arXiv via urllib hangs) **external verification was not possible from here.** The following are **unverified, not known-bad**, and each deserves a fetch-before-cite:
`arXiv:2601.11131` (Harvey–Hittmeir, 16 citations — the most-cited ID in the directory), `arXiv:2512.19076`, `arXiv:2511.18198`, `arXiv:2608.06681`, `arXiv:2606.24717`, `arXiv:2512.01588`, `arXiv:2609.24316`, `arXiv:2610.02101`.

`arXiv:2601.11131` deserves specific attention: it is cited 16 times, is attributed to Harvey & Hittmeir, and is described as a *different, later* item from their well-known `arXiv:2105.11105` (Math. Comp. 91 (2022), which the corpus itself cites 6× at `Round97_FrontierAndOpenGap.md:19`). The corpus shows it being misused before: `Round47_Barrier1Retracted.md:37-40`: *"Reading a theorem's slack as an obstruction is precisely the error that produced the `arXiv:2601.11131` claim in the handover."*

### ✅ Not flagged — the corpus does the right thing in several places, and this is worth knowing

- `Round48_SUMMARY.md:531-534` explicitly downgrades a scout-supplied citation rather than promoting it: *"**On Urroz arXiv:2606.24717:** … Recorded as scout-supplied, **not independently fetched, not used as ground truth.**"*
- `Round48_SUMMARY.md:301-306` records an agent **refusing to attribute a threshold it could not read**, and calls that *"the correct call and it is the one I would have been tempted to make."*
- The corpus's own rule at `Round48_SUMMARY.md:400-403` is the right one and should be adopted on our side too: *"**A table row propagates; prose caveats do not. If the status word in the table is stronger than the status word in the note, the table is wrong.**"* — **§M2.6 above is exactly that failure, and the corpus caught it in its own BKZ/LLL row but not in its own zero-headroom rows.**

---

# BOTTOM LINE FOR THE CALLER

**M2.** Five of the eight closures are sound; three are not.

1. **Do not use "LLL provably optimal on NFS lattices."** The corpus withdrew it (`Round48_SUMMARY.md:314`, `:406`).
2. **Do not use "smoothness excess has zero headroom."** The corpus's own NULL-controlled experiment refutes it (`Papers/a_square_minus_a_cube_divides_twice.md:311`, `:335-339`; contradicting row at `Round48_SUMMARY.md:258`). This is the one item that is both unsupported **and** actively misleading.
3. **"Coppersmith `N^{1/4}` optimal" is overstated** even by the corpus's own lights — `Round48_SUMMARY.md:285` says *"is a CONJECTURE for this problem, not a theorem"*, and `Round107:24-29` says CHHS does not cover the unknown-divisor setting. **R97 and R107/R48 give incompatible accounts of CHHS's scope**; not determinable here which is right.
4. **The GNFS constant (§M2.5) and the class-group exclusion (§M2.3) are the only two closures here with a genuine, self-contained derivation.** Both rest on model-internal arguments the corpus reached on its own, with controls, and both are honest about their limits.
5. **The multivariate-independence result is citation-anchored, not independently reached**, and its own scope note restricts it to *"the two-variable linear subcase."*

**M3.** The three best untouched axes are **the `Σw > 3/2` weight question** (`RESEARCH.md:9617-9619`, formalised in `HarveyFloor.lean`, Round ~40 — **not determinable here** — partially advanced but not closed by Round 52), **bounding `t` for rank-2 UMW gaps** (`Round60_HeSahaiProof.md:169-175`, Round 60, untouched by any of rounds 61–109), and **the shape-aware sieve** (`Round51_ShapeGap.md:162-166`, Round 51, mentioned by no later round).

**Cross-cutting caution for our own programme:** the corpus demonstrates both failure modes we worry about — a *single unvalidated experiment* promoted to a closure (§M2.4), and *one row in a table* surviving while the caveat that refutes it sits unread two rows above (§M2.6). Its own rule *"a table row propagates; prose caveats do not"* is correct and should be applied to our own summaries, not just to theirs.

> ### ⚠️ ROUND 55 — **THE `2601.11131` SUSPICION IS WITHDRAWN. IT IS NOT A PHANTOM.**
> **Verified against the arXiv API (`totalResults=1`, full metadata) and OpenAlex, independently:
> David Harvey and Markus Hittmeir, *Deterministic methods for finding elements of large
> multiplicative order*, `arXiv:2601.11131v2` [math.NT], v1 16 Jan 2026, v2 5 Jun 2026, 13 pp.
> The attribution recorded above (Harvey & Hittmeir) was **correct all along**.
> **ROOT CAUSE OF THE FALSE FLAG:** the round-54 fetch requested `2601.11131` and returned
> **HTTP 200 with a real abstract for a DIFFERENT paper** — `arXiv:2010.05450`, Harvey's
> `N^{1/5}` paper — which contains **zero** mentions of `2601.11131`. *A response that
> succeeds for the wrong document is indistinguishable from one that succeeds for the right
> one, unless you verify the returned identifier matches the requested one.*
> See `Papers/no_bottleneck_and_no_regime_boundary.md` (#539).
