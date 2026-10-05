# Round 53 — mining the Catalog against our closures

**2026-10-04. NO new factoring algorithm. Four of eight closures do not survive contact with an
independent corpus, and one of our own headline measurements does not survive a method check.**

**A claim of impossibility is only as good as the search behind it.** The eight closures had been
checked almost entirely against this campaign's *own* prior rounds. `Catalog/` (~1,000 papers from
a parallel loop, rounds 35–109) had reached overlapping territory, largely independently.

Paper: **`Papers/mining_the_catalog_against_our_closures.md`**.
Experiments: `factor-scratch/r53exp/catmine/`. **No corpus file was modified** — read-only sweep.

---

## 1. Headline

**No corpus paper claims an achieved breakthrough against any closure.** That is the strong,
welcome result. What the sweep found is more useful:

> **Seven places where the corpus asserts a closure STRONGER than its own evidence supports** —
> **three of them on the side of closure**, i.e. claiming optimality that was never proved.

**Scoreboard across the eight: 4 sound · 1 overstated · 1 withdrawn by the corpus itself · 1
falsified in-house · 1 sound but narrower in scope than stated.**

## 2. ★ Finding 1 — the `n/4` "wall" is a distribution, not a step

`Round97f_ValidatedCoppersmith.md:50-51`: *"**The univariate `n/4` wall is now MEASURED, not
assumed** … the sharpest empirical confirmation the record carries."*

The instrument is **real and deterministic** — its published table reproduces exactly
(`n=48: k=11:Y`; `n=64: k=17:Y`; `n=80: k=20:Y`). **But it is ONE instance per `n`**, with
`(m,t)` swept over `2..9` and success reported if *any* works.

Re-run on **40 fresh instances per `n`** (seeded, identical across runs):

| `n` | `n/4` | best-`k` over 40 instances | instances with `k < n/4` |
|---|---|---|---|
| 48 | 12 | min 8, mean 11.04 | **12/40** |
| 64 | 16 | min 13, mean 15.44 | **5/40** |

Two instances at `n=48` factored from **`k=8` — four bits below the claimed wall.** The single
reported instance happened to sit at the top of the distribution.

**And the sub-`n/4` successes are real, not vacuous.** Verified with solver-independent assertions
(`N % f == 0`, `f ∈ (p,q)`): **12/40 at `n=48`, 5/40 at `n=64`**, the deepest reaching
**`X = 2⁴·N^{1/4}`**. The annihilation control is clean — **0 of 11 tested were vacuous**, the same
lattices annihilate **0/200 random points** against a generic expectation of 25–50.

> **This does NOT break the closure.** Coppersmith's `X < N^{β²/d}` is a **sufficient guarantee**,
> not a hard per-instance barrier — a particular `(m,t)` can succeed above it, and the output is
> checked against the true root. **What it refutes is the interpretation:** the wall is a
> **worst-case guarantee that some `(m,t)` works for every instance**, not a per-instance
> threshold. **The honest statement is a distribution, not a step.**

⚠️ **Caveat not testable here:** the successes come from the **best of ~64 lattices per instance**
— a multiple-comparisons selection. Whether the *expected* cost stays subexponential at 1024+ bits
is **not determinable here.**

⚠️ **Seeding correction.** `threshold_test.py` and `verify_subquarter.py` were **unseeded** when
this round's working note was written and their counts **moved between runs** (13/40, then
12/40). The note's `17/40` and `6/40` are **withdrawn**; both scripts are now seeded with a
**shared** seed (`20261004`) so they sweep an identical instance set and reproduce exactly.

## 3. ★ Finding 2 — the strongest external support for our Coppersmith closure is NOT the paper we cite

`Round47_HMBarrier.md:32-47` derives, **from Herrmann–May's own displayed equations read from the
staged PDF, not from memory**, that the multivariate gain is `exp(−Θ(m))` while LLL cost is
`exp(Θ(m²))` — cost dominates for every `m`. Then `:55-62` closes the obvious fix (the determinant
profile is a closed form in `m` with **no monomial-set freedom**). Then `:70-72` quotes the paper:

> "In the extreme case, we obtain `X₁ = N^{0.25}`, `X₂ = 1` … we indeed obtain the univariate
> result `N^{0.25}` of Coppersmith. Hence, **our method contains the Coppersmith-bound as a
> special case as well.**"

**A different paper, a different mechanism, the same ceiling — and it could have disagreed.** It
does not assume independence; **the barrier is on the enabling condition alone.** This is stronger
evidence than the CHHS citation we have been resting on.

> **Do not treat agreement as confirmation.** For Coppersmith `N^{1/4}` the corpus **restated** it
> (rounds 97, 98), **over-stated** it (round 48:546), and **re-derived** it (`Round47_HMBarrier`,
> `Round107`) — **only the last two count as independent.**

## 4. The seven overstatements

**[S1] ★ The Coppersmith closure is retracted by the corpus, then re-asserted 282 lines later, in
the same file.** `Round48_SUMMARY.md:264` strikes it — *"arXiv:1605.08065 proves optimality for
univariate polynomials modulo `N` … **Our `X = N^{1/4}` is a CONJECTURE here — it is the
modulo-unknown-divisor bound, not R1's modulo-`N` one.**"* `:546` — **282 lines later** — reads
*"now **proved optimal** (arXiv:1605.08065)."* **Line 266 calls it withdrawn; line 546 re-imports
it.** Rounds 97/98 give a **third, incompatible account.** The arXiv record is verified real
(CHHS); the modulo-`N` vs modulo-unknown-divisor distinction is a **live reading question**.

**[S2] ★★ "LLL provably optimal on NFS lattices" is withdrawn by the corpus** (`:314`, `:406`) —
its own control gives `LLL/SVP` up to **1.149**, LLL **strictly suboptimal 1/60**, Montgomery
normalisation **absent 0/40**. The strong prose survives un-withdrawn at `:323-330`. Audit: the
lattices are **7-dimensional, 32–55 bits** — not the 1024-bit NFS lattice.

**[S3] ★★ "Smoothness excess fully captured, ZERO headroom" is falsified in-house.** `:242`/`:486`
say "provably, ZERO"; `:258` — **sixteen rows below in the same table** — says the gain is
**localisable** (5.65× at `u=6`). Never corrected. The primary source is blunter, with a **303σ**
null control. **Treat as an open lead with measured headroom.**

**[S4–S7]** Minor. `RESEARCH.md` applies CHHS to the excluded case and misspells Hemenway; the
`1.923 → 1.90188` claim is refuted 300 lines later yet used bare in five arguments.

**Fabrication flag:** **`arXiv:2601.17422` is a KNOWN phantom** (corrected to `2110.08354` at
`:207`) but **still used twice un-flagged**. **All 82 arXiv IDs checked: no off-discipline IDs**;
`1605.08065` ✓, `2111.14180` ✓, `2512.19076` ✓, `2105.11105` ✓, `2601.11131` ✓.

## 5. Which closures are genuinely well-supported

| closure | verdict |
|---|---|
| **GNFS constant** — self-tested to 13 digits + negative discriminant | **strongest; independently re-derived** |
| **Stange `20/27` → `8/9`** — exact rational arithmetic, 60,000 trials z=+79.79, McNemar p≈0.001 | **sound; independently re-derived, and the corpus volunteers two of its own failed derivations** |
| **class groups excluded** | sound (round 48 admits the audit pointed it out) |
| **phase separation** — proved by identity | sound, but **narrower than "no construction gets both"** |
| **multivariate independence is a heuristic** | sound, but **two-variable linear subcase only** |
| **LLL optimal** | **withdrawn by the corpus** |
| **Coppersmith `N^{1/4}` optimal** | **OVERSTATED** |
| **smoothness, zero headroom** | **falsified in-house** |

## 6. A methodological transfer worth making

**The corpus had the right instrument and did not use it.** `Round48_SUMMARY.md:287-291` records
that Chinburg et al. (arXiv:2111.14180) supplies a **decidable algebraic-independence test**, and
that **it was implemented** — FAILing at `X = 321` where the method is *provably impossible*.

Rounds 97g and 99, the two that actually attempt the multivariate problem, **never invoke it.**
Both treat *"the lattice didn't produce two independent short vectors"* as the diagnosis.

**Those are different failures with different fixes.** The first is a search failure (fixable by
better parameters — which is what 97g/99 conclude). The second is a **proof-level obstruction**,
not fixable. **Round 48 had the instrument that distinguishes them and it was not carried
forward.** This does not contradict the closure — it *supports* the "independence is a heuristic"
framing. The cost is that 97g/99's conclusion (*"fails its own structural test, with the reason
identified"*) is **over-diagnosed**: the reason is not identified, only the symptom.

## 7. Axes nobody on either side has touched

**[A1] ★★★ `Σw > 3/2`** (`RESEARCH.md:9617-9619`, formalised in `HarveyFloor.lean`). **One
decidable scalar**; `1/6` needs `Σw ≥ 2`. Harvey and GFHP both sit at `3/2`. Round 52 pinned three
constraints but produced **no scheme and no lower bound**. **Both outcomes are results.** ⚠️ *"I
have **not** established what the weights `wᵢ` are mechanically"* — **until that is answered the
question is not well-posed.**

**[A2] ★★ Bound `t` for rank-2 UMW gaps** — *"the single question that decides whether an entire
conditional route is alive."* `t = O(1)` kills UMW; `t ~ n^{1/6}` rescues `(1/3,1/3)`. **Verified
by grep: untouched by any round 61–109.** This is our own `⌈1/β⌉` neighbourhood from the UMW side
— **the two programmes have not joined notes.**

**[A3] ★★ The shape-aware sieve** — the corpus's own *"best-motivated untried idea"*, **untouched
for 58 rounds.** Sieves are provably shape-blind (`ShapeGap.sieve_cost_shape_blind`, 0 `sorry`),
the shape is free to read from `v_a(n)`. ⚠️ partly walked back at `:129-133`.

## 8. Recommended amendments

1. **Amend the Coppersmith closure** with round 48's scoping note — `X = N^{1/4}` is the
   *modulo-unknown-divisor* bound; 1605.08065 proves the *modulo-`N`* one. **Our closure implies
   more than the citation supports.**
2. **Do not cite round 97f's `n/4` measurement as a wall** — it is a distribution.
3. **Re-scope the LLL closure** — 7-dimensional, 32–55-bit lattices.
4. **Downgrade the smoothness closure** to an open lead — contradicted at 303σ.
5. **Carry arXiv:2111.14180's decidable test into the multivariate work.**
6. **Two untouched integers** are the highest-value targets: `Σw > 3/2` and the UMW gap bound `t`.

## 9. Honest limits

**Not determinable here:** which of three conflicting accounts of CHHS's scope is correct (needs
ePrint 2016/869 §2.3.1 read directly); whether the best-of-~64 selection stays subexponential at
1024+ bits; round numbers for rounds 61–95 (**those files are absent from the corpus**).
**No closure in this set is formalised in Lean** — all are `.md` prose; only `GAPGcd.lean`,
`ShapeGap`, and `NegativeResults.lean` are machine-checked.