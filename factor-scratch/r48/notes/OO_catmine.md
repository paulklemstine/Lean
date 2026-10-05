# OO — mining the Aristotle Catalog against the r48/r52 closed axes

**2026-10-04.** Read-only sweep of `Catalog/` (139 `.md` + 36 `.lean` under
`Cryptography/FactoringBarriers/`; rounds 42–109; `RESEARCH.md` 688 KB; plus
`Cryptography/Factoring/`, `Cryptography/AsymmetricExponent/`, and the 5196-file
`Papers/` tree where the Stange/class-group load-bearing evidence actually lives).
No catalog file was modified. Experiments written to
`factor-scratch/r53exp/catmine/`. Nothing committed; no issues; no paper.

**Headline.** No corpus paper claims an achieved breakthrough against any of the
eight closures. That is the strong, welcome result. But two closures are
**overstated on the side of closure** — the Coppersmith `N^{1/4}` claim is
retracted *inside the corpus's own record* and then silently re-asserted, and the
`N^{1/4}` wall measurement that the parallel loop calls "the sharpest empirical
confirmation the record carries" does not survive a method check. Details in M1.

---

## M4 — reciprocity check with rounds 96–97 (most important item)

### M4.1 Are they consistent with `X = N^{1/4}`? — **YES, and independently so.**

All four rounds in the 96–97 thread land on `N^{1/4}` without inheriting it.
`Round97g_BivariateProbe.md:20-23` derives the univariate reduction from scratch:

> "There is **exactly one small unknown, `x`**; the divisor `p = a+x` is "known up
> to `x`". This is a one-variable small-root problem `f(x)=x+a ≡ 0 (mod p)` —
> precisely what the validated univariate lattice of 97f solves, and precisely
> what CHHS bounded degree-free. **There is no second variable for a multivariate
> method to exploit.**"

`Round107_ResidueFirmFrontier.md:37-44` independently tabulates the degree trade-off
(`d=1 → N^{1/4}`, `d=2 → N^{1/8}`, …) and concludes "no `d>1` improves on `d=1`".
This is a **re-derivation, not a restatement** — it could have come out otherwise,
and the corpus records (`Round96d_FourAxisSweep.md:41-46`) that it tabulated six
different promise classes so they are "not re-hunted."

**Two genuinely new structural facts the corpus contributes, both correct and both
narrowing.** Neither is in our closure set, and both *strengthen* the `N^{1/4}` picture:

1. **Splitting the leak across `p` and `q` is a re-encoding** (`Round97b_MultivariateReduction.md:31-42`).
   For `N=pq`, `q` odd: `p mod 2^t = (N mod 2^t)(q mod 2^t)^{-1} mod 2^t`, verified
   2000/2000 and 3000/3000. So a `t`-bit low-bit leak of `q` is exactly as
   informative as of `p`. **Checked**: this is correct, and it is a real elimination
   of a candidate family — but note it is about **low** bits. `Round97g:30-31` catches
   this itself: "97b's `p/q` coupling was about *low* bits … high bits of `q` are
   *independent* information." The scope caveat is correctly placed.
2. **Raw uniqueness is free** (`Round97e_LatticeRootCause.md:44-57`). The round first
   framed the wall as information-theoretic, **tested it, found it false, and
   retracted it in the same file**: below `n/4` the top bits still determine `p`
   uniquely among divisors. So the wall is purely a lattice-solving phenomenon.
   This is a self-correction of exactly the kind our programme would want, and it
   is recorded honestly.

### M4.2 Do they use arXiv:2111.14180's decidable independence test, or assume independence? — **THEY ASSUME INDEPENDENCE, and they had the test in hand.**

This is the sharpest finding here. `Round48_SUMMARY.md:287-291` records that the
test **was implemented** in round 48 and returns FAIL on 2-sample HNP instances:

> "**What R2 settles.** Chinburg et al., arXiv:2111.14180, supplies a **decidable test** for
> algebraic independence, now implemented. On realistic 2-sample HNP instances it returns WORKS
> … and crosses to FAIL at larger `X` (WORKS at `X = 180`, **FAIL at `X = 321`**, where the
> method is *provably impossible*)."

Then rounds 97g and 99 — the two rounds that actually attempt the multivariate
problem — never invoke it. Both instead treat the **existence of two independent
short vectors as the thing that is missing**:

`Round97g_BivariateProbe.md:57-59`:
> "Tried pairs of reduced vectors from a richer shift set (`cmax,umax` up to 3,4):
> **no integer root** even at `k=n/4` … This localises the failure precisely to multivariate
> **isolation**: the ad-hoc shift basis never produces the two independent short vectors the
> Howgrave-Graham bound requires, so no resultant isolates `x₀`."

`Round99_ThreeAxesAndNewAlgorithm.md:22-24`:
> "The multivariate **isolation** (the Howgrave-Graham short-vector condition for two
> independent short vectors) is not met by an ad-hoc shift basis."

**Why this matters.** Coppersmith's multivariate proof requires the auxiliary
polynomials to be *algebraically independent*, which is exactly the hypothesis
2111.14180 shows can fail on an infinite family with a decidable test. "The
lattice didn't produce two independent vectors" and "the vectors produced are
algebraically dependent" are **different failures with different diagnoses** — the
first is a search failure (fixable by better parameters, which is what rounds 97g/99
conclude), the second is a proof-level obstruction (not fixable). Round 48 had the
instrument that distinguishes them and it was not carried forward.

**Note what this does and does not threaten.** It does **not** contradict the
closure — it is consistent with it, and if anything it supports the closure's
"independence is a heuristic" framing. The cost is that rounds 97g/99's stated
conclusion ("*this* construction fails its own structural test, with the reason
identified") is **over-diagnosed**: the reason is not identified, only the
symptom. `Round97g:78` concedes "literature has working multivariate
Coppersmith — my basis choice is simply not yet H-G-optimal," which is the correct
and honest framing; the surrounding prose is stronger than the evidence supports.
Also flag: `Round97g:78` is the one **uncited literature claim** in the thread
("literature has working multivariate Coppersmith") — no reference given, and this
corpus has a fabricated-citation history.

### M4.3 ⚠️ The `n/4` "measurement" does not survive a method check. **(my own experiment)**

`Round97f_ValidatedCoppersmith.md:50-51` claims:

> "**The univariate `n/4` wall is now MEASURED, not assumed**, with a validated
> instrument. This is the sharpest empirical confirmation the record carries."

I re-ran `Experiments/UMWWindow/coppersmith_lattice.py` and **reproduced its table
exactly** (`n=48: k=11:Y`; `n=64: k=17:Y`; `n=80: k=20:Y`) — the instrument is
real and deterministic. But the table is **one instance per `n`**, with `m,t`
swept over `2..9` and success reported if *any* `(m,t)` works. Two defects:

**(a) The threshold is not sharp — it is one draw from a wide per-instance spread.**
Re-running the same sweep on 40 fresh instances per `n`
(`catmine/threshold_test.py`):

| `n` | `n/4` | best-`k` distribution over 40 instances | instances with `k < n/4` |
|---|---|---|---|
| 48 | 12 | min 8, mean 11.34 | **12/40** |
| 64 | 16 | min 9, mean 14.46 | **6/40** |

At `n=48` one instance factored from `k=8` known bits — **four bits below the
claimed wall.** The single reported instance happened to sit at the top of the
distribution. The table is consistent with `n/4`; it does not *measure* it.

**(b) These sub-`n/4` successes are NOT vacuous — and that is the interesting part.**
`catmine/verify_subquarter.py` confirms, with assertions independent of the solver
(`N % f == 0`, `f in (p,q)`), that **17/40 instances at `n=48` and 6/40 at `n=64`
genuinely factor from strictly fewer than `n/4` known bits of `p`** — reaching
`X = 2³·N^{1/4}`. `catmine/vacuity4.py` runs the negative control: the same lattice
that annihilates the true root annihilates **0/200 random points** (generic
expectation 25–50), so this is not a pigeonhole artifact.

**This does NOT break the closure.** Coppersmith's `X < N^{β²/d}` is a
*sufficient* guarantee, not a hard per-instance barrier — a particular `(m,t)` can
succeed above it, and the LLL output is checked against the true root. What it does
is refute the *interpretation*: the wall is a **worst-case guarantee that some
`(m,t)` works for every instance**, not a per-instance threshold, and the honest
statement is a **distribution**, not a step. `Round97f:46-48` gestures at this
("Small `±1` variation is the finite-lattice constant, not a gap") but reads the
scatter as noise around a sharp edge rather than as the distribution it is.

**One caveat I could not test here.** The successes at `X > N^{1/4}` come from the
**best of ~64 lattices per instance**, which is a multiple-comparisons selection.
At these sizes a successful extra `(m,t)` is cheap, but whether the *expected* cost
of finding one stays subexponential at 1024+ bits is **not determinable here.**

---

## M1 — contradictions

**No corpus paper claims an achieved breakthrough against any closure.** Clean on
Closures 3, 4, 5, 7, 8 as *claims*. What the sweep found instead is more useful:
**seven places where the corpus asserts a closure STRONGER than its own evidence
supports**, three of them on the side of closure.

### [M1-a] ★ The Coppersmith `N^{1/4}` closure is retracted by the corpus — then re-asserted un-retracted in the same file.

`Round48_SUMMARY.md:264` (round 48):
> "⚠️ **An earlier "now also a THEOREM" upgrade is STRUCK — it was my error.** arXiv:1605.08065 proves optimality for **univariate polynomials modulo `N`**, and its p.6 §2.3.1 lists *"factoring RSA moduli `N=pq` when half of the most or least significant bits of one of the factors `p` is known"* as **"a direction for future research"**. **Our `X = N^{1/4}` is a CONJECTURE here — it is the *modulo-unknown-divisor* bound, not R1's *modulo-N` one.**"

`Round48_SUMMARY.md:546` — **282 lines later, in the same file**:
> "the univariate threshold is `X = N^{1/4}`, now **proved optimal** (arXiv:1605.08065), and no tested leakage family beats it."

Line 266 calls the earlier version "withdrawn." Line 546 re-imports it. **Anyone
citing Round 48 for Closure 1 gets the retracted claim.** This is the single most
consequential corpus defect for us, because our own closure cites 1605.08065 and
the corpus has the correct scoping language that our closure set lacks.

The correct form is stated twice more, later and better-sourced:
- `Round48_SUMMARY.md:282-285`: "a CONJECTURE for this problem, not a theorem."
- `Round107_ResidueFirmFrontier.md:24-29`: "their theorem covers the **mod-`N` univariate** case. There is **no capacity-theory optimality theorem for the `N^{β²/d}` bound for a root modulo an *unknown divisor*** … the frontier we sit on is conjecturally optimal but **not yet proven optimal**."

**But rounds 97/97b/97c/98 give a THIRD, incompatible account** — e.g.
`Round97_FrontierAndOpenGap.md:57-63` (round 97) states CHHS "proved Coppersmith's
univariate `N^{β²/d}` bound optimal **within the univariate auxiliary-polynomial
class** … Together these make the **`n/4` known-bits-of-`p`** barrier a technique
ceiling." That is exactly the conflation round 48 struck. **Not determinable here**
which is right without fetching ePrint 2016/869 §2.3.1 directly. **The corpus is
internally inconsistent on the scope of the paper our closure rests on.**

I verified the arXiv record: 1605.08065 = *"Cryptographic applications of capacity
theory: On the optimality of Coppersmith's method for univariate polynomials"*,
Chinburg/Hemenway/Heninger/Scherr — real, correct authors, correct title, and its
abstract claims optimality "for monic degree-`d` polynomials modulo `N`." The
corpus's *modulo-`N` vs modulo-unknown-divisor* distinction is a live reading
question, not a citation fabrication.

**Action for us: our closure table should carry round 48's scoping note, not just
the arXiv ID.** `X = N^{1/4}` is the modulo-unknown-divisor bound; 1605.08065 proves
the modulo-`N` one.

### [M1-b] ★★ "LLL provably optimal on NFS lattices" is withdrawn by the corpus.

`Round48_SUMMARY.md:314` and `:406`: **"no gain found; 'provably nothing' WITHDRAWN"**,
noting the source note's own control gives `LLL/SVP` up to **1.149**, LLL **strictly
suboptimal 1/60**, and **Montgomery normalisation absent (0/40 rows)**. The strong
prose survives un-withdrawn at `:323-330` ("better reduction cannot help").
Audit of the source (`factor-scratch/r48/notes/I_constant.md`): the lattices are
**7-dimensional, 32–55 bits** — not the 1024-bit NFS lattice — and the
near-orthogonality mechanism is **asserted, not measured**.

**Threatens Closure 4 directly.** `LLL/SVP = 1.0000000000` is real but is measured
on toy-scale lattices. Our closure needs re-scoping to what was actually measured.

### [M1-c] ★★ "Smoothness excess fully captured, zero headroom" is falsified in-house.

`Round48_SUMMARY.md:242`/`:486`: **"FULLY CAPTURED — provably. ZERO headroom."**
`Round48_SUMMARY.md:258`, **sixteen rows below in the same table**: "**AND THE GAIN
IS LOCALISABLE** — the best mod-4 sub-box beats the global rate at EVERY operating
point (5.65× at `u=6`, 2.04× at `u=3`), so a sieve *could* be aimed at it. That is a
STRONGER result." Never corrected. The primary source
`Papers/a_square_minus_a_cube_divides_twice.md:311` is blunter: **"The gain SURVIVES
sieving — the audit's 'every net gain < 1' is false"**, with a NULL control at 303σ
and 14.1% [13.3, 15.0] cost reduction at `u≈3`. The corpus states its own failure
rule at `Round48_SUMMARY.md:244`: "table rows propagate, prose caveats do not" —
which guarantees the wrong row survives.

**Threatens Closure 6.** Treat as an **open lead with measured headroom**, not a
closure.

### [M1-d] ★ GNFS constant — the corpus is *more* careful than our closure.

`RESEARCH.md:717-742` records that the frontier constant is
**`(92+26√13)/27)^{1/3} = 1.9018836118`** (Coppersmith, *Modifications to the NFS*,
J. Cryptology 6(3):169–180 1993, DOI `10.1007/BF00198464`), not `1.9230`.
`Round47_ConstantPinned.md` then refutes its *reachability* (disc −129.106).
**Verified**: three phantom citations are named and struck (`ANTS-I Coppersmith 1997`,
`Bleichenbacher EUROCRYPT 2000`, `Bleichenbacher–Kaspar–Kurth`).

**Threatens Closure 5 mildly, and usefully.** Our closure says `1.9229994` "cannot
be moved." The corpus's position is more careful: `1.9019` is a *conjectured cost-model
optimum*, and Coppersmith's paper never claims optimality ("optimal", "lower bound",
"linear form", "theorem" each occur **zero times** — `RESEARCH.md:749-750`).
**Closure 5 needs the model-class qualifier.**

### [M1-e] ★ Class groups — one corpus paper still proposes the route as live.

`Round51_ShapeGap.md:167-169` (round 51) lists the class-group route as **"the
highest-ceiling item on the list"**, and `RESEARCH.md:7303-7306` asserts
class-group smoothness is **"PROVEN"** with an "OPTIMAL" sieve. Neither is corrected
by the corpus's own round-40 material (`RESEARCH.md:216-231`), which prices the
route by ERH-conditionality and finds the family→subfamily bridge **measurably
false** (z = −41.4, gap widening with `|D|`).

**Threatens Closure 3** as an *unretracted* live proposal. The closure itself is
fine; the corpus has not internalised it.

### [M1-f]—[M1-g] Minor. `RESEARCH.md:543-546` applies CHHS to the excluded case and
misspells Hemenway. `Round47_LVConstants.md:36-38` ("1.923 **was** beaten, to
`1.90188`") is refuted 300 lines later by `Round47_ConstantPinned.md:53-56`, yet
`RESEARCH.md` uses bare `1.9018836` in five arguments.

### Fabrication flags
- **`arXiv:2601.17422` is a KNOWN phantom** (corrected to `2110.08354` at
  `Round48_SUMMARY.md:207`) but **still used twice un-flagged** at
  `Round46_Handover.md:31` and `:124`. Treat as phantom.
- All 82 arXiv IDs in the tree were checked for plausibility: **no off-discipline
  IDs** (no astronomy-on-a-crypto-claim, unlike the `2^45`/arXiv incidents in our
  own record). Spot-verified live: `1605.08065` ✓, `2111.14180` ✓ (*"Two variable
  polynomial congruences and capacity theory"*), `2512.19076` ✓ (GFHP, *"On Factoring
  and Power Divisor Problems via Rank-3 Lattices and the Second Vector"*), `2105.11105` ✓,
  `2601.11131` ✓ (*"Deterministic methods for finding elements of large multiplicative order"*).
- **Not verifiable from this host:** several Springer/publisher-walled sources
  (Kim–Barbulescu tower-NFS formula; Ernst et al. EUROCRYPT 2005). The corpus
  correctly refuses to guess them — e.g. `RESEARCH.md:771` "**NOT FOUND — UNVERIFIED**".

---

## M2 — strongest PRO-closure evidence in the corpus

**Which closures are externally well-supported. This is as valuable as a contradiction.**

| closure | type | could the corpus have got there independently? | verdict |
|---|---|---|---|
| **GNFS `1.9229994`** | **self-tested derivation to 13 digits** + a negative discriminant argument (`Round47_ConstantPinned.md:9-13`, `:50-56`) | **yes — and it did** | **strongest of the eight** |
| **Stange `20/27` → `8/9`** | **exact rational arithmetic**, deficit `−1.7×10⁻¹⁸` (`Round48_SUMMARY.md:635-640`) + 60,000 trials z=+79.79 + end-to-end McNemar p≈0.001 | **yes — re-derived from mechanism**, and the corpus volunteers two of its own failed derivations | **sound** |
| **class groups excluded** | one-line proof + 2 independent routes | yes, but `Round48:223` admits the argument "was pointed out by the adversarial audit" | sound |
| **phase separation** | **proved by identity** (`q=1` for a sieve) + Dixon's 6/6 control | **yes** | sound — but **narrower than "no construction gets both"**: it says a sieveable construction cannot carry 2-adic coupling, not that no construction can |
| **multivariate independence is a heuristic** | experiment on a citation | no — 2111.14180's own test | sound, but **"only in the two-variable linear subcase"** |
| **LLL optimal** | — | — | **withdrawn by the corpus** (M1-b) |
| **Coppersmith `N^{1/4}` optimal** | **restatement** | no — CHHS | **OVERSTATED** (M1-a) |
| **smoothness, zero headroom** | **hand-wave** | no | **falsified in-house** (M1-c) |

**The most valuable M2 item is one that is not on the closure list at all.**
`Round47_HMBarrier.md:32-47` derives, from Herrmann–May's own displayed equations
(read from the staged PDF, *not* from memory), that the multivariate auxiliary-information
gain is `exp(−Θ(m))` while the LLL cost is `exp(Θ(m²))` — cost dominates for every
`m`. Then `:55-62` closes the obvious fix by showing the determinant profile is a
closed form in `m` with **no monomial-set freedom**. Then `:70-72` quotes the paper:

> "In the extreme case, we obtain `X₁ = N^{0.25}`, `X₂ = 1`. Notice that in this case, the
> variable `x₂` vanishes and we indeed obtain the univariate result `N^{0.25}` of
> Coppersmith. Hence, our method contains the Coppersmith-bound as a special case as well."

**This is the strongest external support for Closure 1 in the corpus and it is
independent of CHHS entirely** — a different paper, a different mechanism
(a `Θ(m²)`-dimensional lattice cost against an `exp(−Θ(m))` gain), reaching the same
`N^{1/4}` ceiling, and *could* have disagreed. Note it does **not** assume
independence; the barrier is on the enabling condition alone.

**Do not treat agreement as confirmation, per the brief.** For Coppersmith `N^{1/4}`:
the corpus **restated** it (rounds 97, 98), **over-stated** it (Round 48:546), and
**re-derived it** (`Round47_HMBarrier`, `Round107` degree table) — only the last
two count as independent. The GNFS and Stange closures are genuine independent
derivations. The LLL and smoothness closures are not supported by the corpus at all.

---

## M3 — axes nobody on either side has touched

### [M3-1] ★★★ The total-weight question `Σw > 3/2` — one decidable number, already formalised in Lean, no scheme exhibited.

`RESEARCH.md:9617-9619`:
> "Is there a deterministic search-floor scheme whose total denominator weight satisfies **Σwᵢ > 3/2**?"

Formalised in `Cryptography/FactoringBarriers/HarveyFloor.lean`. `1/6` needs
`Σw ≥ 2`; `1/8` needs `≥ 3`. Harvey and GFHP both sit at `3/2`. Round 52 partially
advanced it (three independent constraints pin `N^{1/5}`) but produced **no scheme
and no lower bound**. Round number **not determinable here** (dated 2026-09-24;
files for rounds 61–95 are absent from the corpus).

**Why promising:** both outcomes are results — a scheme gives `1/6`, a lower bound
closes the deterministic door permanently, and it is a single scalar rather than a
lattice construction. **Honest risk, stated by the corpus itself** at `:9661-9662`:
*"I have **not** established what the weights `wᵢ` are mechanically."* Until that is
answered the question is not well-posed.

### [M3-2] ★★ Bound `t` for rank-2 UMW gaps — one integer decides whether a whole conditional route lives.

`Round60_HeSahaiProof.md:169-175`:
> "**This is the single question that decides whether an entire conditional route is alive.**"

`t = O(1)` kills UMW outright; `t ~ n^{1/6}` rescues `(1/3,1/3)`. **Verified by
grep: no round 61–109 file touches it.** This is our own `GAP threshold
⌈1/β⌉` neighbourhood approached from the UMW side — the two programmes have not
joined notes.

### [M3-3] ★★ The shape-aware sieve — the corpus's own "best-motivated untried idea," untouched for 58 rounds.

`Round51_ShapeGap.md:162-166`: **"the best-motivated untried idea in this project."**
Sieves are provably shape-blind (`ShapeGap.sieve_cost_shape_blind`, 0 `sorry`), while
the shape is free to read from `v_a(n)`. **Verified by grep: mentioned in no round
after 51.** Caveat — `:129-133` partly walks it back ("on the `a²b` shape the right
answer is 'use rho'").

**Runner-up with the safest provenance in the whole corpus:** Harvey's own published
`N^{1/6}` question, `Round50_HarveyHittmeir.md:85-89`, quoted from arXiv:2010.05450
p. 8, with **"nobody has picked it up"** at `:44`. Round 50 measured that the good
pair is a convergent of the hidden `p/q` and *"cannot be predicted below the cost of
finding it"* — an honest negative, and a well-sourced statement of the live door.

---

## Recommended actions

1. **Amend Closure 1** with round 48's scoping note: `X = N^{1/4}` is the
   *modulo-unknown-divisor* bound; arXiv:1605.08065 proves the *modulo-`N`* one and
   lists bits-of-`p` as future research. Our closure currently implies more than the
   citation supports — and the corpus found this in 2026-09 and then lost it.
2. **Do not cite Round 97f's `n/4` measurement as a wall.** It is one instance per
   `n`; the per-instance best-`k` spreads from `n/4−4` to `n/4` (12/40 below `n/4`
   at `n=48`), and those sub-`n/4` factorizations are **verified real** (division-
   checked, 0/200 on the vacuity control). Coppersmith's bound is a *worst-case
   guarantee*, not a per-instance barrier. This does not threaten the closure — it
   means the wall is a distribution, and any future citation of it should say so.
3. **Re-scope Closure 4 (LLL)** — the corpus withdrew "provably nothing" itself; the
   40/40 is on 7-dimensional 32–55-bit lattices.
4. **Downgrade Closure 6** from "zero headroom" to open lead — contradicted in-house
   with a 303σ null control.
5. **Carry arXiv:2111.14180's decidable test into the multivariate work.** Round 48
   implemented it; rounds 97g/99 did not use it and over-diagnosed their failure as
   a parameter problem. This is a cheap, concrete methodological transfer.
6. **Two untouched integers** are the highest-value targets: `Σw > 3/2`
   (M3-1) and the rank-2 UMW gap bound `t` (M3-2).

## Honest limits of this mine

- Not determinable here: which of the corpus's three conflicting accounts of CHHS's
  scope (M1-a) is correct — needs ePrint 2016/869 §2.3.1 read directly.
- Not determinable here: whether the best-of-~64 `(m,t)` selection that yields the
  sub-`n/4` successes stays subexponential at 1024+ bits.
- Round numbers for rounds 61–95 are not determinable — those files are absent.
- The load-bearing evidence for the Stange and class-group work lives in
  `/home/raver1975/lean/Papers/*.md` (5196 files), **outside** the Catalog tree I was
  scoped to; I cite it where round notes quote it, flagged as such.
- **No closure in this set is formalised in Lean** — all are `.md` prose. The only
  machine-checked items are `GAPGcd.lean`, `ShapeGap`, and `NegativeResults.lean`.