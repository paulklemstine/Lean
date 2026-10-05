# Mining the Catalog Against Our Closures

## Four of eight closures do not survive contact with an independent corpus — and the `n/4` "wall" is a distribution, not a step

**Round 53 · 2026-10-04 · Aether factoring programme**

---

## Abstract

**A claim of impossibility is only as good as the search behind it.** This campaign had produced
eight closures — statements of what cannot be done — and had checked them almost entirely against
its *own* prior rounds. The `Catalog/` corpus (~1,000 papers written by a parallel loop across
rounds 35–109) had reached overlapping territory, largely independently.

> **No corpus paper claims an achieved breakthrough against any closure.** That is the strong,
> welcome result. What the sweep found instead is more useful: **seven places where the corpus
> asserts a closure STRONGER than its own evidence supports**, three of them on the side of
> closure. **Four of our eight closures need amendment**, and one of our own headline
> measurements **does not survive a method check.**

The two findings that matter most:

1. **The `n/4` Coppersmith wall is a distribution, not a step.** Re-running the corpus's
   "validated instrument" on 40 fresh instances per `n` instead of one: **12/40 instances at
   `n = 48` and 5/40 at `n = 64` factor from strictly fewer than `n/4` known bits** — and those
   factorizations are **verified real** (division-checked, `N % f == 0`, `f ∈ (p,q)`), reaching
   `X = 2⁴·N^{1/4}`, with a negative control confirming they are not a pigeonhole artefact. This
   does **not** break the closure: Coppersmith's `X < N^{β²/d}` is a *worst-case guarantee*, not a
   per-instance barrier. It breaks the **interpretation**.
2. **The strongest external support for the Coppersmith closure is not the paper we cite.** It is
   Herrmann–May's own displayed equations, read from the staged PDF: the multivariate gain is
   `exp(−Θ(m))` against an LLL cost of `exp(Θ(m²))`. A different paper, a different mechanism,
   reaching the same ceiling — and it **could** have disagreed.

**Classical factoring of RSA-scale integers. Not a cryptographic break.**

---

## 1. Reciprocity check with rounds 96–97 — the most important item

### 1.1 Are they consistent with `X = N^{1/4}`? Yes, and independently so.

All four rounds in the 96–97 thread land on `N^{1/4}` **without inheriting it**.
`Round97g_BivariateProbe.md:20-23` derives the univariate reduction from scratch:

> "There is **exactly one small unknown, `x`**; the divisor `p = a+x` is 'known up to `x`'. This
> is a one-variable small-root problem `f(x)=x+a ≡ 0 (mod p)` … **There is no second variable for
> a multivariate method to exploit.**"

`Round107_ResidueFirmFrontier.md:37-44` independently tabulates the degree trade-off
(`d=1 → N^{1/4}`, `d=2 → N^{1/8}`, …) and concludes no `d>1` improves on `d=1`. **A
re-derivation, not a restatement** — it could have come out otherwise.

**Two genuinely new structural facts the corpus contributes, both narrowing.**

1. **Splitting the leak across `p` and `q` is a re-encoding.** For `N=pq`, `q` odd:
   `p mod 2^t = (N mod 2^t)(q mod 2^t)^{-1} mod 2^t`, verified 2000/2000 and 3000/3000. So a
   `t`-bit low-bit leak of `q` is exactly as informative as of `p`. ⚠️ **Scope:** this is about
   **low** bits. `Round97g:30-31` catches it itself — *"high bits of `q` are independent
   information."*
2. **Raw uniqueness is free.** The round first framed the wall as information-theoretic,
   **tested it, found it false, and retracted it in the same file**: below `n/4` the top bits
   still determine `p` uniquely among divisors. **So the wall is purely a lattice-solving
   phenomenon.** A self-correction of exactly the kind this programme would want.

### 1.2 Do they use arXiv:2111.14180's decidable independence test, or assume independence?

**They assume independence, and they had the test in hand.** `Round48_SUMMARY.md:287-291` records
that the test **was implemented** in round 48 and returns FAIL on 2-sample HNP instances —
*"WORKS at `X = 180`, FAIL at `X = 321`, where the method is provably impossible."*

Then rounds 97g and 99 — the two rounds that actually attempt the multivariate problem — never
invoke it. Both treat the **existence of two independent short vectors as the thing that is
missing**:

> "the ad-hoc shift basis never produces the two independent short vectors the Howgrave-Graham
> bound requires, so no resultant isolates `x₀`." — `Round97g:57-59`
>
> "The multivariate **isolation** … is not met by an ad-hoc shift basis." — `Round99:22-24`

**Why this matters.** Coppersmith's multivariate proof requires the auxiliary polynomials to be
*algebraically independent* — exactly the hypothesis 2111.14180 shows can fail on an infinite
family with a decidable test. **"The lattice didn't produce two independent vectors" and "the
vectors produced are algebraically dependent" are different failures with different diagnoses** —
the first is a search failure (fixable by better parameters, which is what 97g/99 conclude), the
second is a proof-level obstruction (not fixable). **Round 48 had the instrument that
distinguishes them and it was not carried forward.**

**This does not contradict the closure — it supports it.** The cost is that 97g/99's conclusion
(*"this construction fails its own structural test, with the reason identified"*) is
**over-diagnosed**: the reason is not identified, only the symptom. ⚠️ **Round 54 qualifies this
— the comparison may never have been apples-to-apples.** The decidable test speaks to a
**mod-`p` 2-variable congruence**; 97g's construction works over **ℤ** and is not degenerate
(recommendation 5, withdrawn below). **So 97g's ℤ-diagnosis may be correct after all, and
"is 97g's basis genuinely suboptimal?" is OPEN, not resolved in either direction.**
`Round97g:78` concedes
*"literature has working multivariate Coppersmith — my basis choice is simply not yet
H-G-optimal"*, which is the correct framing; the surrounding prose is stronger than the evidence.
⚠️ `Round97g:78` is also the one **uncited literature claim** in the thread, in a corpus with a
fabricated-citation history.

### 1.3 ★ The `n/4` "measurement" does not survive a method check (my own experiment)

`Round97f_ValidatedCoppersmith.md:50-51` claims:

> "**The univariate `n/4` wall is now MEASURED, not assumed**, with a validated instrument. This
> is the sharpest empirical confirmation the record carries."

I re-ran the instrument and **reproduced its table exactly** (`n=48: k=11:Y`; `n=64: k=17:Y`;
`n=80: k=20:Y`) — **the instrument is real and deterministic.** But the table is **one instance
per `n`**, with `m,t` swept over `2..9` and success reported if *any* `(m,t)` works.

**(a) The threshold is not sharp — it is one draw from a wide per-instance spread.** Re-running the
same sweep on **40 fresh instances per `n`** (seeded; two consecutive runs identical):

| `n` | `n/4` | best-`k` over 40 instances | instances with `k < n/4` |
|---|---|---|---|
| 48 | 12 | min 8, mean 11.04 | **12/40** |
| 64 | 16 | min 13, mean 15.44 | **5/40** |

At `n=48` two instances factored from `k=8` — **four bits below the claimed wall.** The single
reported instance happened to sit at the top of the distribution. **The table is consistent with
`n/4`; it does not measure it.**

**(b) These sub-`n/4` successes are NOT vacuous — and that is the interesting part.** With
assertions independent of the solver (`N % f == 0`, `f ∈ (p,q)`), **12/40 instances at `n=48` and
5/40 at `n=64` genuinely factor from strictly fewer than `n/4` known bits of `p`** — reaching
**`X = 2⁴·N^{1/4}`** at `n=48, k=8` (the deepest case, `X/N^{1/4} = 16`). The negative control is
clean: of **11** sub-`n/4` successes tested, **0 were vacuous** — the same lattices annihilate
**0/200 random points** against a generic expectation of 25–50.

⚠️ **Scope of that control, stated precisely:** `vacuity4.py` runs the annihilation test at
**`n = 32`** (`k = 6, 7` against `n/4 = 8`), **not** at the `n = 48/64` instances of the table
above. It establishes that **the sub-`n/4` phenomenon is real at `n = 32`** — the regime where
there are most sub-`n/4` successes to test — **not** that each of the 12 + 5 instances above was
individually cleared. **Those carry a solver-independent division check (`N % f == 0`,
`f ∈ (p,q)`), which is the strong verification; the annihilation control is the weaker one and it
was run at one size.**

> ⚠️ **These two scripts were unseeded when the round's note was written, and their counts moved
> between runs — 13/40 on one invocation, 12/40 on the next.** Every figure here is from the
> **seeded** versions, which are byte-identical across runs. The note's `17/40` and `6/40` were
> unseeded draws and are **withdrawn**; the counts above are lower and are the ones that hold. The
> conclusion is unaffected — 12/40 is still a third of the sample — but an unseeded count in a
> paper is an uncitable count, whatever it happens to say.

**This does NOT break the closure.** Coppersmith's `X < N^{β²/d}` is a *sufficient* guarantee, not
a hard per-instance barrier — a particular `(m,t)` can succeed above it, and the LLL output is
checked against the true root. What it refutes is the *interpretation*: **the wall is a
worst-case guarantee that some `(m,t)` works for every instance**, not a per-instance threshold.
The honest statement is a **distribution**, not a step.

⚠️ **One caveat not testable here.** The successes at `X > N^{1/4}` come from the **best of ~64
lattices per instance** — a multiple-comparisons selection. At these sizes a successful extra
`(m,t)` is cheap, but whether the *expected* cost stays subexponential at 1024+ bits is **not
determinable here.**

## 2. Seven places the corpus overstates its own closures

**On the side of closure** — i.e. claiming optimality never proved:

### [S1] ★ The Coppersmith closure is retracted by the corpus, then re-asserted un-retracted in the same file

`Round48_SUMMARY.md:264`:

> "⚠️ **An earlier 'now also a THEOREM' upgrade is STRUCK — it was my error.** arXiv:1605.08065
> proves optimality for **univariate polynomials modulo `N`**, and its p.6 §2.3.1 lists *'factoring
> RSA moduli `N=pq` when half of the most or least significant bits of one of the factors `p` is
> known'* as **'a direction for future research'**. **Our `X = N^{1/4}` is a CONJECTURE here — it is
> the _modulo-unknown-divisor_ bound, not R1's _modulo-`N`_ one.**"

`Round48_SUMMARY.md:546` — **282 lines later, in the same file**:

> "the univariate threshold is `X = N^{1/4}`, now **proved optimal** (arXiv:1605.08065), and no
> tested leakage family beats it."

**Line 266 calls the earlier version withdrawn. Line 546 re-imports it. Anyone citing Round 48
for the Coppersmith closure gets the retracted claim.** This is the single most consequential
corpus defect for us, because our own closure cites 1605.08065 and the corpus has the correct
scoping language our closure set lacks.

The correct form is stated twice more, later and better-sourced — `Round48_SUMMARY.md:282-285`
(*"a CONJECTURE for this problem, not a theorem"*) and `Round107_ResidueFirmFrontier.md:24-29`
(*"There is no capacity-theory optimality theorem for the `N^{β²/d}` bound for a root modulo an
_unknown divisor_ … conjecturally optimal but **not yet proven optimal**."*)

**But rounds 97/97b/97c/98 give a THIRD, incompatible account** — `Round97_FrontierAndOpenGap.md:57-63`
states CHHS "proved Coppersmith's univariate `N^{β²/d}` bound optimal … making the `n/4`
known-bits-of-`p` barrier a technique ceiling." **That is exactly the conflation round 48 struck.**
**Not determinable here** which is right without fetching ePrint 2016/869 §2.3.1 directly. **The
corpus is internally inconsistent on the scope of the paper our closure rests on.**

I verified the arXiv record: 1605.08065 = Chinburg/Hemenway/Heninger/Scherr, *"Cryptographic
applications of capacity theory"* — real, correct authors, correct title, abstract claims
optimality "for monic degree-`d` polynomials modulo `N`." **The distinction is a live reading
question, not a citation fabrication.**

### [S2] ★★ "LLL provably optimal on NFS lattices" is withdrawn by the corpus

`Round48_SUMMARY.md:314` and `:406`: **"no gain found; 'provably nothing' WITHDRAWN"**, noting the
source note's own control gives `LLL/SVP` up to **1.149**, LLL **strictly suboptimal 1/60**, and
**Montgomery normalisation absent (0/40 rows)**. The strong prose survives un-withdrawn at
`:323-330`. Audit of the source: the lattices are **7-dimensional, 32–55 bits** — not the 1024-bit
NFS lattice — and the near-orthogonality mechanism is **asserted, not measured**.

**Threatens our closure directly.** `LLL/SVP = 1.0000000000` is real but is measured on toy-scale
lattices.

### [S3] ★★ "Smoothness excess fully captured, zero headroom" is falsified in-house

`Round48_SUMMARY.md:242`/`:486`: **"FULLY CAPTURED — provably. ZERO headroom."**
`Round48_SUMMARY.md:258`, **sixteen rows below in the same table**: *"AND THE GAIN IS
LOCALISABLE — the best mod-4 sub-box beats the global rate at EVERY operating point (5.65× at
`u=6`, 2.04× at `u=3`), so a sieve could be aimed at it. That is a STRONGER result."* **Never
corrected.** The primary source is blunter: **"The gain SURVIVES sieving — the audit's 'every net
gain < 1' is false"**, with a NULL control at **303σ** and 14.1% [13.3, 15.0] cost reduction at
`u≈3`.

The corpus states its own failure rule at `:244` — *"table rows propagate, prose caveats do not"* —
which **guarantees** the wrong row survives.

**Threatens our smoothness closure.** Treat as an **open lead with measured headroom.**

### [S4–S7] Minor, and one fabrication flag

`RESEARCH.md:543-546` applies CHHS to the excluded case and misspells Hemenway.
`Round47_LVConstants.md:36-38` ("1.923 **was** beaten") is refuted 300 lines later, yet
`RESEARCH.md` uses bare `1.9018836` in five arguments.

**Fabrication flag:** **`arXiv:2601.17422` is a KNOWN phantom** (corrected to `2110.08354` at
`Round48_SUMMARY.md:207`) but **still used twice un-flagged** in `Round46_Handover.md:31` and
`:124`. **Treat as phantom.** All 82 arXiv IDs in the tree were checked for plausibility: **no
off-discipline IDs**; spot-verified live: `1605.08065` ✓, `2111.14180` ✓, `2512.19076` ✓,
`2105.11105` ✓, `2601.11131` ✓.

## 3. Which closures are genuinely well-supported

As valuable as a contradiction.

| closure | type | could the corpus have got there independently? | verdict |
|---|---|---|---|
| **GNFS constant** | **self-tested derivation to 13 digits** + negative-discriminant argument | **yes — and it did** | **strongest of the eight** |
| **Stange `20/27` → `8/9`** | **exact rational arithmetic**, deficit `−1.7×10⁻¹⁸` + 60,000 trials z=+79.79 + end-to-end McNemar p≈0.001 | **yes — re-derived from mechanism**, and the corpus volunteers two of its own failed derivations | **sound** |
| **class groups excluded** | one-line proof + 2 independent routes | yes, but round 48 admits the argument "was pointed out by the adversarial audit" | sound |
| **phase separation** | **proved by identity** + Dixon's 6/6 control | **yes** | sound — but **narrower than "no construction gets both"** |
| **multivariate independence is a heuristic** | experiment on a citation | no — 2111.14180's own test | sound, but **two-variable linear subcase only** |
| **LLL optimal** | — | — | **withdrawn by the corpus** |
| **Coppersmith `N^{1/4}` optimal** | **restatement** | no — CHHS | **OVERSTATED** |
| **smoothness, zero headroom** | **hand-wave** | no | **falsified in-house** |

**★ The most valuable item here is not on the closure list at all.** `Round47_HMBarrier.md:32-47`
derives, **from Herrmann–May's own displayed equations read from the staged PDF, not from memory**,
that the multivariate auxiliary-information gain is `exp(−Θ(m))` while the LLL cost is
`exp(Θ(m²))` — cost dominates for every `m`. Then `:55-62` closes the obvious fix by showing the
determinant profile is a closed form in `m` with **no monomial-set freedom**. Then `:70-72` quotes
the paper:

> "In the extreme case, we obtain `X₁ = N^{0.25}`, `X₂ = 1`. Notice that in this case, the variable
> `x₂` vanishes and we indeed obtain the univariate result `N^{0.25}` of Coppersmith. Hence, our
> method contains the Coppersmith-bound as a special case as well."

**This is the strongest external support for the Coppersmith closure in the corpus and it is
independent of CHHS entirely** — different paper, different mechanism, same ceiling, and it *could
have disagreed*. It does not assume independence; **the barrier is on the enabling condition
alone.**

> **Do not treat agreement as confirmation.** For Coppersmith `N^{1/4}` the corpus **restated** it
> (rounds 97, 98), **over-stated** it (round 48:546), and **re-derived** it (`Round47_HMBarrier`,
> `Round107`) — only the last two count as independent. **The GNFS and Stange closures are genuine
> independent derivations. The LLL and smoothness closures are not supported by the corpus at
> all.**

## 4. Axes nobody on either side has touched

### [A1] ★★★ The total-weight question `Σw > 3/2` — one decidable number, already formalised in Lean, no scheme exhibited

`RESEARCH.md:9617-9619`: *"Is there a deterministic search-floor scheme whose total denominator
weight satisfies **Σwᵢ > 3/2**?"* — formalised in `HarveyFloor.lean`. `1/6` needs `Σw ≥ 2`; `1/8`
needs `≥ 3`. **Harvey and GFHP both sit at `3/2`.** Round 52 partially advanced it (three
independent constraints pin `N^{1/5}`) but produced **no scheme and no lower bound**.

**Why promising:** both outcomes are results — a scheme gives `1/6`, a lower bound closes the
deterministic door permanently, and it is a **single scalar** rather than a lattice construction.
⚠️ **Honest risk, stated by the corpus itself:** *"I have **not** established what the weights `wᵢ`
are mechanically."* **Until that is answered the question is not well-posed.**

### [A2] ★★ Bound `t` for rank-2 UMW gaps — one integer decides whether a whole conditional route lives

`Round60_HeSahaiProof.md:169-175`: *"**This is the single question that decides whether an entire
conditional route is alive.**"* `t = O(1)` kills UMW outright; `t ~ n^{1/6}` rescues `(1/3,1/3)`.
**Verified by grep: no round 61–109 file touches it.** This is our own `⌈1/β⌉` neighbourhood
approached from the UMW side — **the two programmes have not joined notes.**

### [A3] ★★ The shape-aware sieve — the corpus's own "best-motivated untried idea," untouched for 58 rounds

`Round51_ShapeGap.md:162-166`: **"the best-motivated untried idea in this project."** Sieves are
provably shape-blind (`ShapeGap.sieve_cost_shape_blind`, 0 `sorry`), while the shape is free to
read from `v_a(n)`. **Verified by grep: mentioned in no round after 51.** ⚠️ `:129-133` partly
walks it back (*"on the `a²b` shape the right answer is 'use rho'"*).

**Runner-up with the safest provenance in the corpus:** Harvey's own published `N^{1/6}` question,
`Round50_HarveyHittmeir.md:85-89`, quoted from arXiv:2010.05450 p. 8, with **"nobody has picked it
up"** at `:44`. Round 50 measured the good pair is a convergent of the hidden `p/q` and *"cannot be
predicted below the cost of finding it"* — an honest negative, and a well-sourced statement of the
live door.

## 5. Recommended amendments

1. **Amend the Coppersmith closure** with round 48's scoping note: `X = N^{1/4}` is the
   *modulo-unknown-divisor* bound; arXiv:1605.08065 proves the *modulo-`N`* one and lists
   bits-of-`p` as future research. **Our closure currently implies more than the citation
   supports** — and the corpus found this in 2026-09 and then lost it.
2. **Do not cite round 97f's `n/4` measurement as a wall.** It is one instance per `n`; the
   per-instance best-`k` spreads from `n/4−4` to `n/4` (**12/40** below `n/4` at `n=48`), and
   those sub-`n/4` factorizations are **verified real**. **The wall is a distribution, and any
   future citation should say so.**
3. **Re-scope the LLL closure** — the corpus withdrew "provably nothing" itself; the 40/40 is on
   7-dimensional 32–55-bit lattices.
4. **Downgrade the smoothness closure** from "zero headroom" to open lead — contradicted in-house
   with a 303σ null control.
5. ~~**Carry arXiv:2111.14180's decidable test into the multivariate work.**~~ **WITHDRAWN by
   round 54 — the transfer does not instantiate.** Round 48 implemented the test for **2-variable
   congruences mod `p`** (`x + t·y + a ≡ 0 (mod p)`). The construction rounds 97g/99 actually
   built works over **ℤ**, from `g(x,y) = (a+x)(b+y) − N` — an exact integer equation, not a
   congruence — so **the test does not apply to it**, and running it would have produced a clean,
   confident, **irrelevant** verdict. Worse, the mod-`p` *formulation* of that model is
   **degenerate**: for fixed `x`, **all `p`** values of `y` satisfy it (vs exactly `1` for the
   linear form), so it carries no two-variable information for anyone to recover. **The instrument
   was not neglected through carelessness; it was pointed at a different problem.** See
   `Round53`→`Round54` notes, `factor-scratch/r54exp/indep/`. **The underlying question — whether
   97g's ℤ-lattice is genuinely suboptimal — remains OPEN and is not settled either way.**
6. **Two untouched integers** are the highest-value targets: `Σw > 3/2` (A1) and the rank-2 UMW
   gap bound `t` (A2).

## 6. Honest limits of this mine

- **Not determinable here:** which of the corpus's three conflicting accounts of CHHS's scope
  ([S1]) is correct — needs ePrint 2016/869 §2.3.1 read directly.
- **Not determinable here:** whether the best-of-~64 `(m,t)` selection that yields the sub-`n/4`
  successes stays subexponential at 1024+ bits.
- Round numbers for rounds 61–95 are **not determinable** — those files are absent from the corpus.
- **No closure in this set is formalised in Lean** — all are `.md` prose. The only machine-checked
  items are `GAPGcd.lean`, `ShapeGap`, and `NegativeResults.lean`.
- **No corpus file was modified.** This is a read-only sweep.

## 7. Reproduce

```
cd factor-scratch/r53exp/catmine
python3 threshold_test.py      # 40 fresh instances per n; the spread
python3 verify_subquarter.py   # division-checked sub-n/4 successes
python3 vacuity4.py            # negative control, at n=32; 0/200 random points
```

**All three are seeded** (`20261004` for the first two, `11` for the third) and reproduce
byte-identically across runs. **This was not true of the first two when the round's working note
was written** — see the flag in §1.3. `threshold_test.py` and `verify_subquarter.py` share one
seed so both sweep the **same 40 instances** at each `n`; `vacuity4.py` is a separate regime
(`n = 32`) and does not.