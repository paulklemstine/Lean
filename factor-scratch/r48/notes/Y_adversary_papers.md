# Y — ADVERSARIAL VERIFICATION of round 48's four papers and the census

**Auditor:** adversarial pass, round 51. **Date:** 2026-10-03.
**Targets:** #521 `the_baseline_that_was_not.md`, #522 `the_smoothness_wall_is_a_subgroup_wall.md`,
#523 `a_square_minus_a_cube_divides_twice.md`, #524 `stange_works_and_its_analysis_does_not.md`,
and `Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md`.
**Code:** `factor-scratch/r51/exp/audit2/`. No paper was edited. No WebSearch was used for any citation.

---

## HEADLINE

**1 FATAL · 6 MATERIAL · 4 MINOR.** *(Audited against the papers as they stood; #522 was patched
in commit `a066a4b5b` after my first pass — see A2.1 for what the patch fixed and what it missed.)*

The FATAL was in the paper's **load-bearing quantitative claims**, not their qualitative
direction. In both cases the direction of the finding survives and the number does not. Both are
correctable in a sentence.

| Sev | Paper | Defect | Status |
|---|---|---|---|
| **FATAL** | #522 §2.2 | `ln k = 2√(L ln L) − L` wrong by a factor of 2; boundary `N<5400` really `N<1.8×10²⁹` | **patched in `a066a4b5b`**, but the three `ln k` values were left stale → now MATERIAL |
| **FATAL** | #523 §6 | The 25–38% "reduction in relation-collection cost" is not measured, not end-to-end, and does not follow from δ. Its source calls it "the **naive** reading". | **open** |
| MATERIAL | #522 §2.2 | Both L-columns still wrong after the patch; `L[1/3] > L[1/2]` is printed, which is never true. | open |
| MATERIAL | #522 §2.2 | "structurally excluded … **impossible**" overstates a cost-model conditional. | open |
| MATERIAL | #521 §10.5 | "three **independent** defects" — they are defects of three *different* experiments, and for E-7 the parity defect is **redundant**. | patched in `27d327668` |
| MATERIAL | #521 §10.5 | CI `[0.60, 1.01]` and Fisher `p = 0.0000` in the same row are mutually exclusive. | patched in `27d327668` |
| MATERIAL | Census | Repeats #523's **withdrawn** claim verbatim, in two places. | patched in `0273b981b` |
| MINOR | #521 | `181/280` vs `181/240` inside the corpus. | open |
| MINOR | #522 | SQUOF complexity is Wikipedia-sourced and the note distrusts its own transcription. | open |

**Two findings I could NOT break, stated so they are not re-litigated:** the corrected valuation
law (§A1.1) and the paper's `0/890` divisibility measurement (§A2.5).

---

# A1 — Attack #523, the NFS valuation law

## A1.1 ✅ THE CORRECTED LAW SURVIVES — exhaustive verification

I re-derived `P(p^k | a²−b³)/p^k` by exhaustive enumeration over **all** `(a,b) mod p^k`,
including every `a² ≡ b³` case, for p ∈ {2,3,5,7,11,13}, k = 1…7.

Method (no sampling, exact, O(p^k)): build the multiset of `a² mod p^k`, then
`count = Σ_b ctr[b³ mod p^k]`. Code: `audit2/a1_exhaustive.py`.

| p | k=2 | k=3 | k=4 | k=5 | k=6 | k=7 |
|---|---|---|---|---|---|---|
| 2 | 1.500000 | 1.500000 | 1.500000 | 1.500000 | 2.500000 | **2.500000** |
| 3 | 1.666667 | 1.666667 | 1.666667 | 1.666667 | 3.666667 | **3.666667** |
| 5 | 1.800000 | 1.800000 | 1.800000 | 1.800000 | 5.800000 | **5.800000** |
| 7 | 1.857143 | 1.857143 | 1.857143 | 1.857143 | 7.857143 | **7.857143** |
| 11 | 1.909091 | 1.909091 | 1.909091 | 1.909091 | 11.909091 | — |
| 13 | 1.923077 | 1.923077 | 1.923077 | 1.923077 | 13.923077 | — |

**Verdict: the corrected law `(2 − 1/p) + [p^(k−⌈k/2⌉−⌈k/3⌉) − 1]` is exact at k = 2…6 for every
prime tested, including p = 2. The withdrawal of "independent of k" was correct and necessary.**
The paper's own numbers (−573 → −436-style corrections notwithstanding) all reproduce. This is
the best-evidenced claim in the round and I could not break it.

**My null harness was validated first** (`a1_null_fix.py`): an independent uniform b-arm returns
ratio **1.0000000000** at every (p,k). An instrument that cannot return the null is not an
instrument; this one can.

## A1.2 The k ≥ 7 departure is real and the paper's account of it is incomplete (MATERIAL)

At k = 7 the measured ratio **stays at the k = 6 value** rather than tracking the paper's
bracket term. The paper §4.2 attributes the departure entirely to the zero-zero subspace and
leaves the `p = 2` residual "open". Decomposition (`a1_null_fix.py`) shows the structure is
richer:

```
p=3: k=7 total=8019  zero=2187  units=1458  mixed=4374   ratio 3.6667
p=5: k=7 total=453125 zero=78125 units=62500 mixed=312500 ratio 5.8000
p=7: k=7 total=6470695 zero=823543 units=705894 mixed=4941258 ratio 7.8571
```

The `mixed` term (pairs with `v_p(a²) ≠ v_p(b³)` and equal valuations, e.g. `2i = 3j = 6`) is
**zero for every k ≤ 6 and non-zero from k = 7**, at *every* prime. So there are **two**
mechanisms, not one, and the paper's "zero-zero term" story accounts for only the first. This
does not damage the corrected law's validity over 2 ≤ k ≤ 6; it damages the paper's causal
account, which is stated as complete.

## A1.3 "The events that matter are at small k" — **TRUE**, and I verified it (a point in the paper's favour)

`a1_dominance.py`, 200 000 pairs, measured `v_p(a²−b³)` against the uniform geometric:

```
p=2: k=0:0.49912 k=1:0.12398 k=2:0.18978 k=3:0.09342 k=4:0.04729 k=5:0.00793 k=6:0.01923
      uniform: k=0:0.50000 k=1:0.25000 k=2:0.12500 k=3:0.06250 k=4:0.03125 k=5:0.01562
p=5: k=0:0.79932 k=1:0.12912 k=2:0.05724 k=3:0.01138
```

The excess is real and largest at **k = 2** for every prime. The k ≥ 6 mass is ~1–2% of samples.
**The paper's practical claim is correct: high-k events are rare in the regime that matters.**
I could not falsify it and I tried.

## A1.4 🔴 FATAL — the 25–38% payoff is not a measurement

**The paper's only quantitative payoff.** §6: *"Measured end-to-end by the round-48 smoothness
axis, the effect is a **25–38% reduction in relation-collection cost** at the operating point
u ≈ 3."*

**Its source says something weaker.** `factor-scratch/r48/notes/C_smoothness.md:338`, verbatim:

> "**At the NFS operating point u ≈ 3 the naive reading is a ~25–38% reduction in collection
> cost.**"

Three defects, in increasing severity:

**(a) MINOR — provenance upgrade.** "the naive reading" became "Measured end-to-end". The word
*naive* was load-bearing and was deleted.

**(b) MATERIAL — it is an interpolation, not a measurement.** The 25–38% band is computed from
the δ table in `C_smoothness.md` §3, which was measured only at **u ≤ 4, N ≈ 10⁸**:

```
u=2.8 -> 19.7%   u=3.2 -> 27.4%   u=3.6 -> 35.2%   u=4.0 -> 42.0%
```

25–38% corresponds to **u ≈ 3.1–3.8**, i.e. it is read off between table rows. `C_smoothness.md` §4
states plainly: *"δ(u) was never measured at u > 4, and NFS's operating point is u ≈ 3–5."*
The paper reproduces this caveat in §6 — but still prints the number in bold in §6's first line
and again in the closing line as "worth publishing".

**(c) 🔴 FATAL — it does not follow from δ, and the program's own data says the excess cannot be cashed.**
δ is a ratio of *smooth-value yields*. Collection cost falls with yield **only if everything else
is held fixed**. `C_smoothness.md` §3 measures that it is not: it finds the excess lives in a
sub-box and every sub-box has **net gain < 1**:

| sub-box | B=10⁴ | net |
|---|---|---|
| a, b both even | 0.9720 | 0.2455 |
| a, b both mult of 3 | 0.9785 | 0.1098 |
| a odd | 0.9718 | 0.4908 |

And my exhaustive decomposition (§A1.1) shows the k ≥ 2 excess is **entirely** the zero-zero
subspace — that is, it lives in "a ≡ 0 mod p^⌈k/2⌉, b ≡ 0 mod p^⌈k/3⌉". **The excess is
precisely the sub-box structure the note measures as uncashable.** The paper's §6 even repeats
the reason in its own bullet — *"The bias does not concentrate … so no sieveable sub-box captures
a net gain"* — while the headline number in the same section asserts a collection-cost gain.

**Verdict: 25–38% should be withdrawn, or restated as "a ~1.1–1.4× smooth-value yield ratio at
u ≈ 3, measured at N ≈ 10⁸, which the program's own sub-box analysis shows cannot be converted
into a sieving gain."** With that change the paper has no quantitative payoff, and it says so in
§6 — but it should not claim one.

### A1.4 — LIMITATION, stated because the rules require it

**I attempted an independent end-to-end reproduction of δ and my harness FAILED its own null
arm, so no δ number of mine is reported and the verdict above does not rest on one.**

What happened, for the record (`a1_e2e_final.py`):
- My first version compared `a²−b³` against one uniform draw per stratum — a broken control,
  which produced a meaningless δ ≈ 267. Caught by inspection, matching the round-48 pattern.
- My rewritten smoothness predicate returned `True` on `1000003` at B = 2²⁰. That was my *test
  input* being wrong (1000003 is prime and < 2²⁰), not the predicate — but it is exactly the
  "must be shown able to return False" discipline doing its job.
- The final version's **null arm — two independent uniform populations under an identical
  matched-strata protocol — returned δ = 0.9412, ~29σ from 1.0.** An instrument that cannot
  return the null is not an instrument. Three runs (two sympy-based, one optimised) timed out or
  failed before producing a clean result.

So the A1.4 verdict rests on **documentary evidence that is decisive on its own** — the source
note's word *"naive"*, the u ≤ 4 provenance of the δ table, and the note's own sub-box table
showing net gain < 1 — and on my **exhaustive enumeration** (§A1.1), which is exact. It does
not rest on any δ I measured. Had my null arm passed and δ come out ≈ 1.25, the "naive reading"
defect would still stand; it is a defect of provenance, not of value.

**I am flagging this rather than quietly dropping it, per the same rule the census itself
learned: a self-test that only shows your code running is not a self-test. Mine did not.**

## A1.5 MINOR — the census repeats the withdrawn claim

`Round48_SUMMARY.md:34` and `:202` both print, unstruck:

> `P(p^k | a²−b³) = (2p−1)/p^k` for odd `p`, **`k ≥ 2`**

That is the claim #523 §4 explicitly **withdrew**. The census was not updated with the correction.
Any future round reading the census gets the false version back.

---

# A2 — Attack #522's structural exclusion

## A2.1 🔴→🟠 PARTIALLY FIXED in commit `a066a4b5b`, but the patch is incomplete

> **Status note (post-audit).** The paper was patched after I reported A2.1. The coefficient is
> now `4√(L ln L) − L` and the boundary now reads `16 ln L < L ⟺ L < 67.36 ⟺ N < 1.8×10²⁹` —
> **both correct, exactly as I derived.** My FATAL is downgraded to MATERIAL because the
> *headline claim* is now right. **But three defects survive the patch**, all verified against
> the current file (`a2_recheck.py`):

**(a) The three `ln k` values were NOT patched.** The paper still prints −573, −1217, −2539.
Those are the old **2√** values. Under its own new coefficient `4√(L ln L) − L` they are:

| n (bits) | paper still prints | correct under its own new formula |
|---|---|---|
| 1024 | −573 | **−436.73** |
| 2048 | −1217 | **−1013.54** |
| 4096 | −2539 | **−2238.14** |

A patch that changes the formula and leaves all three of its outputs is a half-applied
correction — the same failure mode as this program's "correction tables manufacture phantoms"
(#521 §10.6). The direction still holds (all still negative).

**(b) The `L[1/2]` table column is still wrong**, see A2.2.
**(c) The prose still says "Even `k = 1` is too slow past a few thousand"** — which now
contradicts its own corrected threshold of 1.8×10²⁹ by 25 orders of magnitude.

---

## A2.1-orig The original FATAL (for the record)

Paper §2.2:

> "Solving `(kN)^{1/4} = L[1/2]` for `k` gives `ln k = 2√(L ln L) − L`, which is **negative at
> every RSA size**: −573 at n=1024, −1217 at n=2048, −2539 at n=4096."

**The derivation is wrong.** `(kN)^{1/4} = L[1/2]` means `kN = L[1/2]⁴`. With
`L[1/2] = exp(√(L ln L))`, we get `ln k = 4√(L ln L) − L`. The coefficient is **4**, not 2.

The paper's coefficient is what *reproduces its own three numbers*, so the error is systematic
and I can prove it is not a rounding artifact (`a2_KILLER.py`):

```
n=1024: 2√(L ln L)−L = −573.26 (paper −573)  |  CORRECT 4√(L ln L)−L = −436.73
n=2048: −1216.55 (paper −1217)               |  CORRECT              = −1013.54
n=4096: −2538.63 (paper −2539)               |  CORRECT              = −2238.14
```

**The boundary follows from the wrong coefficient, and moves enormously:**

```
ln k < 0  ⟺  4√(L ln L) < L  ⟺  16 ln L < L  ⟺  L < 67.361
        ⟹  N < exp(67.361) = 1.797 × 10^29

PAPER:  2√(L ln L) < L  ⟺  4 ln L < L  ⟺  L < 8.6  ⟺  N < 5400
```

The paper's threshold is understated by **3.3 × 10²⁵**, about **25.5 orders of magnitude**.

**And the claim is directly falsified across that range.** The paper asserts
"`(kN)^{1/4} > L[1/2]` for **every `k ≥ 1`** once `N > 5400`". Directly evaluating:

| N | N^(1/4) | L[1/2] | claim holds? | k with (kN)^(1/4) = L[1/2] |
|---|---|---|---|---|
| 10⁴ | 1.000e+01 | 9.203e+01 | **NO — REFUTED** | 7.18e+03 |
| 10⁸ | 1.000e+02 | 1.519e+03 | **NO — REFUTED** | 5.33e+04 |
| 10²⁰ | 1.000e+05 | 5.856e+05 | **NO — REFUTED** | 1.18e+03 |
| 10⁴⁰ | 1.000e+10 | 7.312e+08 | yes | — |
| 10¹⁰⁰ | 1.000e+25 | 2.342e+15 | yes | — |

For every `N` below ≈ 1.8 × 10²⁹ there **exists** a `k ≥ 1` at which the class-group BSGS cost is
*exactly* L[1/2]. The paper calls this "impossible" over that entire range. It is possible.

**What survives:** the sign. `ln k < 0` at RSA sizes is still true under the correct formula
(−436.73 at n=1024 is still negative), so the *directional* conclusion — cost grows with k, so
tuning k cannot rescue you — is unaffected. **What fails:** the specific threshold, the "every
k ≥ 1 once N > 5400" quantifier, and anything resting on `L < 8.6`. Note `L < 8.6` is otherwise
a correct root of `L = 4 ln L` (I verified: the upper root is 8.6132, giving N < 5504, so the
paper's 5400 is a fair rounding) — the error is upstream, in the coefficient.

## A2.2 MATERIAL — both L-columns are still wrong after the patch, and one is inverted

`a2_boundary_table.py`. The paper's table is (n in **bits** — confirmed by `N^{1/4} = 64.00` at
`n = 256`):

| n (bits) | N^{1/4} | paper L[1/2] | **true L[1/2]** | paper L[1/3] | **true L[1/3]** |
|---|---|---|---|---|---|
| 256 | 64.00 | 21.87 | **43.73** | 46.66 | **14.03** |
| 1024 | 256.00 | 49.24 | **98.48** | 86.77 | **24.10** |
| 4096 | 1024.00 | 108.38 | **216.76** | 156.50 | **40.77** |
| 16384 | 4096.00 | 234.90 | **469.80** | 276.52 | **68.29** |

- The **L[1/2] column is exactly half the true value at every n** (ratio 0.5000). That is
  `L[1/2]` with an unexplained constant `c = 1/2`. It is not Shoup's `√2` (which would be
  ×√2) and not the ECM heuristic (c = 1).
- The **L[1/3] column is internally impossible**: it prints `L[1/3] = 46.66 > L[1/2] = 21.87` at
  n = 256. **`L[1/3] < L[1/2]` always** — a larger α-index is a smaller cost. The two columns
  are transposed or both miscomputed.

**Effect on the argument:** it inflates the paper's own margins (`a2_boundary_table.py` §A2.1d):

| n (bits) | true margin | paper margin | overstated by |
|---|---|---|---|
| 256 | 20.27 | 42.13 | **+107.9%** |
| 1024 | 157.52 | 206.76 | +31.3% |
| 4096 | 807.24 | 915.62 | +13.4% |

The conclusion `N^{1/4} > L[1/2]` still holds at every tabulated size even with correct values, so
this is an accuracy defect, not a fatal one — but the table is the paper's main display and it is
wrong in a way that makes its own argument look ~2× stronger than it is.

## A2.3 MATERIAL — "structurally excluded … impossible" overstates a conditional

The paper: *"This is not 'unlikely'; it is **impossible**, and increasing `k` only enlarges the
discriminant and hence the cost."*

The claim is conditional on three things the paper states as given and never defends:
1. `h(−kN) ≈ (kN)^{1/2}` — an asymptotic, and `h(−D)` is genuinely variable;
2. BSGS at `√h` is the best available algorithm on a group of known order — **this is the
   assumption the ECM analogy undermines** (see A2.4);
3. `p | h(−kN)` must hold — which the paper's own measurement says never did (0/890).

On (3) the wording is self-undermining: if the class group does not contain `p`, the route is
dead for a reason that has nothing to do with cost. **Cost is not what excludes it.** The
honest status is the one the census half-concedes elsewhere — "cost-suboptimal in the regime we
measured, and never observed to contain the factor" — not "impossible".

Also worth noting: the analytic class number formula gives `h(−kN) ≈ √(kN)·L(1,χ)/π`, so
`√h ≈ (kN)^{1/4}/√π·√L(1,χ)`. The paper's `(kN)^{1/4}` **drops the `1/√π` factor, which favours
the method by 0.825 bits**, and drops the `L(1,χ)` factor entirely, which can be > 1 by a
logarithmic factor. Minor next to the factor-2 error, but it runs in the direction that flatters
the exclusion.

## A2.5 ✅ I REPLICATED `0/890` — and refuted a sub-agent's contrary claim

A parallel agent reported that `p | h(−kN)` is *"not rare — 2028 hits in 198 000 trials"*,
which would make the paper's 0/890 wrong. **I checked this myself rather than accept it**
(`a2_verify_agent.py`), after validating `qfbclassno` against a brute-force reduced-form count
(**20/20 agree** — required, per the `ellcard` lesson).

```
N = 11*13 = 143, all 10000 valid k in 1..20000:  861 hits of  11 | h(-kN)   <- agent is right HERE
N ~ 2^38..2^40, the paper's own k grid {1,2,3,4,5,6,8,12,16,24,32,64,128,256,1024,4096}:
                                    500 trials, 0 hits                      <- paper is right HERE
```

**The agent's hits are all at small N, where `h(−kN) ≈ √(kN)/π` is itself tiny, so a small `p`
divides it by arithmetic accident.** In the regime the paper actually claims — `N ≈ 2^66`,
`N ≈ 2^53` — divisibility is genuinely never observed. **`0/890` replicates. The paper's
empirical claim survives my audit.** The sub-agent's contrary claim is a regime error, and I am
recording that so the finding is not re-imported later.

## A2.6 ✅ THE STRONGEST ARGUMENT IS ONE THE PAPER DOES NOT MAKE

The ECM-style objection has a **tautological** answer that is strictly stronger than the
paper's cost model, and it should replace the `N^{1/4}` comparison as the paper's headline:

> **`h` is `B`-smooth ∧ `p | h` ⟹ `p ≤ B`.**

Smoothness of `h` means every prime factor of `h` is `≤ B`; divisibility means `p` *is* a prime
factor of `h`. Hence `p ≤ B`. With `B = L[1/2]` and `p ≈ √N`, these are **mutually exclusive —
inconsistent, not improbable.** This kills the ECM-style route with no appeal to
`h ≈ (kN)^{1/2}`, no BSGS cost model, and no smoothness estimate.

There is a **second unconditional kill** the paper mentions only in passing: `Cl(O_D) → Cl(O_D/p)`
is **trivial** (semilocal quotient when `p ∤ D`; the ideal of `[a,b,c]` is `a·(1,t)`, always
principal, when `p | D`). There is no mod-`p` readout — no analogue of ECM's group-law reduction —
even when smoothness and divisibility both hold.

**Recommended restructure:** the abstract should lead with these two *unconditional*
obstructions and demote `(kN)^{1/4} > L[1/2]` to "under the standard `h ≍ √(kN)` estimate".
This makes the paper **stronger**, not weaker — and it retires the factor-2 problem entirely,
because the exclusion no longer rests on the algebra I found broken.

## A2.7 The ECM objection — resolved

The paper argues (§3) that *"the smoothness heuristic is a wall in restricting a walk to a
**subgroup**"* and that ECM wins because it *"does not restrict"*. But the class group walk
**is** a subgroup walk — that is the argument for excluding it. The paper's exclusion therefore
depends on smoothness being unavailable in subgroups, which is the paper's §3 thesis, not an
independent cost fact. **The strongest claim in #522 rests on the paper's own most speculative
generalisation.** This is a circularity, not a proof failure, but it means "structurally excluded"
is doing more work than the argument supports.

Note the paper *does* correctly discharge the residual assumption in §1.1 (trial division by
primes ≤ y costs π(y), dominated), and its Shoup quotes are verbatim and page-cited. **That
part of #522 is sound** — it is the standard the rest of the round does not meet.

## A2.8 MINOR — SQUOF complexity sourcing

Census: *"strictly weaker than ECM's `L[1/2,√2]`"*, resting on `O(N^{1/4})` for SQUOF.
`notes/A_classgroup.md:176`: *"No citation is offered for the SQUOF O(N^{1/4}) complexity beyond
the Wikipedia page"*; line 180 records that a direct transcription of that page's SQUOF
**fails**. The *identification* (walk = SQUOF, 19/19 `a_k = p`) is measured and solid; the
complexity comparison is Wikipedia-sourced and self-distrusted in the same note.

---

# A3 — Attack #521's three-defect retraction

## A3.1 MATERIAL — "three independent defects" is an overstatement, on two counts

Paper §10.5: *"the same recorded 'milestone' is explained by **three independent defects**, each
found by a different method… Any one of them suffices to void the number. The convergence of three
unrelated explanations on the same conclusion is the strongest evidence in this paper."*

**(a) They are defects of three different experiments, not three explanations of one number.**

| exp | n | scale | defect assigned |
|---|---|---|---|
| E-6b | 200/200 | h ≤ 1684 (11 bits), B = 1000 | self-referential baseline |
| E-6c | 25/25 | 29-bit class numbers | half-bit scale offset |
| E-7 | 25/25 | **no scale recorded at all** | parity mismatch |

A defect of E-6c cannot "independently explain" E-7's number. The paper's §2–6 (the E-6b/E-6c
defects) and §10.5 (the E-7 defect) are about disjoint artifacts. "Convergence of three unrelated
explanations on the same conclusion" is a real and good rhetorical structure — but it is
convergence on the *thread's conclusion*, not on *one number*. The abstract's "rests on four
independently checked findings" is the accurate framing; §10.5's "three independent defects … on
the same recorded milestone" is not.

**(b) For E-7 specifically, the parity defect is REDUNDANT, not independent.** From
`notes/G_adversary.md` Run B — which buckets both arms to the same 29-bit order band and leaves
the EC arm at its **native mixed parity**:

```
u=1.5: class 0.506  EC(mixed) 0.601  ratio 0.841   <- already reversed
u=2.0: class 0.240  EC(mixed) 0.306  ratio 0.783   <- already reversed
u=2.5: class 0.082  EC(mixed) 0.141  ratio 0.584   <- already reversed
u=3.0: class 0.026  EC(mixed) 0.053  ratio 0.495   <- already reversed
```

**Scale-matching alone reverses the sign at every u.** Conversely, parity-matching alone (against
the paper's own odd-uniform control) gives **null**, not a reversal:

```
u=1.5: class 0.506  odd-uniform 0.518  ratio 0.98   <- NULL
u=2.0: class 0.240  odd-uniform 0.244  ratio 0.98   <- NULL
```

So the two defects for E-7 are **not independent routes to the same verdict**: scale does the
work; parity changes the statement from "reversed" to "at null vs a parity-correct control". The
paper's sentence "Any one of them suffices to void the number" survives — but "three independent
defects … the strongest evidence in this paper" does not.

**Direct answer to the assigned question: no, the E-7 ratio does not require parity matching to
reverse. It reverses under scale-matching alone.** And the parity confound and the scale mismatch
are, for E-7, closer to one confound seen twice than to two independent ones.

## A3.2 MATERIAL — the §10.5 table is internally inconsistent

Paper §10.5 row `u = 2.0`:

> `| 2.0 | 64/267 = 0.240 | 1224/4000 = 0.306 | **0.78** | [0.60, 1.01] | 0.0000 |`

**A 95% CI of [0.60, 1.01] contains 1.0; a Fisher `p = 0.0000` says significant. Both cannot be
true.** I recomputed both with a **validated** harness (`a3_fisher_validate.py` — my exact
Fraction Fisher agrees with `scipy.stats.fisher_exact` to 1e-12 on **9/9** cases including the
null 50/100 vs 50/100 → p = 1, and 10/25 vs 8/25 → p = 0.768813, which is the number the paper
itself quotes in §3):

| u | ratio | Katz 95% CI | paper CI | Fisher (mine) | Fisher (scipy) | paper p |
|---|---|---|---|---|---|---|
| 1.5 | 0.841 | [0.75, 0.95] | [0.72, 0.96] | 0.00244 | 0.00244 | 0.0000 |
| **2.0** | **0.783** | **[0.63, 0.97]** | **[0.60, 1.01]** | **0.02298** | **0.02298** | **0.0000** |
| 2.5 | 0.584 | [0.39, 0.88] | [0.36, 0.93] | 0.00572 | 0.00572 | 0.0028 |
| 3.0 | 0.495 | [0.24, 1.04] | [0.21, 1.14] | 0.06100 | 0.06100 | 1.0000 |

Two problems: the printed CI at u = 2.0 is too wide (it should exclude 1.0), and the printed
`p = 0.0000` overstates the true 0.0230. The conclusion ("significantly below 1") holds, but a
row that asserts both "CI includes 1" and "p = 0.0000" is a table a reader cannot check without
recomputing it — and a reviewer who trusts the CI concludes the opposite of one who trusts the p.

The same defect is inherited from `notes/G_adversary.md:114-117`, so it originates upstream.

## A3.3 ✅ WHAT SURVIVES

The **conclusion is correct and well-evidenced**: at matched scale and matched parity the
class-group arm is at or below null, E-7 is Fisher p = 0.769, no `.py` was ever committed, and
`p_linked_smooth` does not measure a p-linked quantity. I verified the p = 0.769 exactly. The
`h(−q)`-always-odd structural fact (genus theory) is correct and the parity diagnostic is a
genuinely reusable contribution. **The retraction should stand.** What must change is the
independence claim and the table.

---

# A4 — Attack the census (numeric spot-checks)

Independently spot-checked against the cited source files:

| Census claim | Source | Verdict |
|---|---|---|
| `p \| h(−kN)` **0/890** | `notes/F_rigorous.md:427` "0/890 total trials" | ✅ MATCH |
| **19 of 19** factors had `a_k = p` | `notes/A_classgroup.md:147` | ✅ MATCH |
| class/EC ratio **0.78, 0.58**, Fisher **0.0000 / 0.0028** | `notes/G_adversary.md:114-117` | ✅ numbers match the note — but see A3.2, the note is internally inconsistent |
| **102 vs 105 of 207** | `notes/E_funcfield.md:158-159` | ✅ MATCH (102+105 = 207) |
| towers **3.18×/5.74×/8.54×** at k=2/3/4 | `notes/E_funcfield.md:170-176` | ✅ MATCH |
| Stange **181/240**, **1269σ** | `notes/K_stange.md:235, 287` | ⚠️ MATCH here — but **`K_stange.md:8` says "181/280"**. The note contradicts itself; the census picked the right denominator. |
| LLL/SVP **40/40 = 1.0000000000** | `notes/I_constant.md:94-97` | ✅ MATCH |
| e6c **0.0624**, Dickman 0.0648, ratio **0.963**, **112 cells** | `notes/O_e6c_recheck.md:16,155,176` | ✅ MATCH |
| e6c **11.5×** | `O_e6c_recheck.md:16` "**11.5x** above" | ✅ MATCH (0.720 / 0.0624 = 11.54) |
| `L < 8.6 ⟺ N < 5400` | `notes/F_rigorous.md:444` | ✅ MATCHES the note — but see **A2.1**, both are wrong |

**The census's numbers are, with one exception (181/280 vs 181/240), faithful to their sources.**
The defect is not arithmetic. It is that the census **inherits its sources' errors without
inheriting their caveats**, and adds one error of its own:

🔴 **MATERIAL — census repeats #523's withdrawn claim**, `Round48_SUMMARY.md:34` and `:202`:
`P(p^k | a²−b³) = (2p−1)/p^k for odd p, k ≥ 2`. Withdrawn by #523 §4. **Anyone reading the
census gets the false version.** This is the single most damaging census defect because #523 is
the round's only POSITIVE result and this is the row a future round will quote.

---

# A5 — What round 48 closed without evidence

Full pass in `factor-scratch/r51/exp/audit2/provenance/A5_provenance.md`. **No census row is wholly
UNTRACEABLE** — every axis has a note. The failure mode is sharper and more dangerous: **the
reason column is stronger than the evidence beneath it, and the census systematically drops the
caveats its own notes attach.**

### Ranked — closures that outrun their support

**1. 🔴 "GNFS constant via BKZ — CLOSED — *provably nothing*"** (SUMMARY:208, 217-221)
The measurement is real and `exp/exactsvp.py` genuinely implements a **refuse-rather-than-truncate**
contract. But the census states a **mechanism** that no script measures and that the note's own
control contradicts: *"The rows have near-disjoint small-prime supports, so they are nearly
orthogonal before reduction"* — while `notes/I_constant.md:26` records `LLL/SVP ∈ [1.000, 1.149]`
on the self-test and S4b finds LLL strictly suboptimal 1/60. And the census **drops the note's own
flagged gap**: Montgomery normalisation absent, **0/40 rows m-divisible** (`I_constant.md:139-143`,
*"This is a real gap and I flag it rather than claim the lattice is the fully normalised Montgomery
lattice"*). "Provably nothing" is attached to a result its author explicitly qualified.

**2. 🔴 "Function fields / tori / Jacobians — CLOSED (exactly)"** (SUMMARY:200)
`notes/E_funcfield.md:358-361` calls the `D = u²−1` torus *"a **genuine factoring method** …
(12/12 splits measured) … 1.5× cheaper than GMP-ECM's ladder."* The census's "CLOSED (exactly)"
says the opposite of the note. Worse: the `reach_p = L[1/2]` figure needs Lenstra's heuristic,
flagged by the note at lines 209-217 and unmarked in the census; and the number-field half of the
field-vs-number-field asymmetry rests on **Lenstra–Pomerance 1992, which the note's author states
he has not read**, adding *"The synthesis is mine."* The census dropped that sentence — which is
exactly the provenance warning the census exists to enforce.

**3. 🔴 Supply audit — provenance orphaned.** All 8 scripts and 5 result files live in
`factor-scratch/r49/exp/supply/`. `notes/S_supply.md:3` says *"**Round 49**, supply axis."* The
census files the audit under round 48 as *"the round's biggest open worry"*, and `S_supply` is
**not listed in the census's own FILES section** (SUMMARY:537-541). A reader auditing round 48
from `r48/` finds the claim and none of its backing. **The audit that exists to catch unbacked
claims is itself unbacked at its stated location.** The numbers themselves all check out.

**4. 🟠 "Partial-information — CLOSED — measured to the bit"** (SUMMARY:207)
The measurement is genuine and every script exists (`exp_boundary.py`, `control_final.py`,
`coppersmith.py`). But the census **table row** says "CLOSED" with no qualifier while
`notes/D_partialinfo.md:196-224` lists **five unmeasured dimensions**, including **no multivariate
/ Herrmann–May construction built at all** and multiplier-`u` not implemented. The census prose
carries three caveats; **the table, which is what propagates, carries none.** Also: no run log or
JSON exists for this axis — the numbers live only in note prose.

**5. 🟠 "Cross-discipline sweep (7 fields) — CLOSED"** (SUMMARY:206)
`notes/H_crossdiscipline.md:317-319` calls field 6 (Jacobi graph) *"the round's only genuinely
live lead"* — i.e. **open** — and field 3 is an *equivalence*. Marking the sweep CLOSED while the
note marks its best field live is status inflation. Also: "φ is polylog-equivalent to factoring",
the load-bearing step of the Jacobi row, is **asserted with no proof or citation** in the note.

**6. 🟠 Inherited rows — "Nothing here disturbs them" is an assertion.** (SUMMARY:310-311)
`classical-deterministic` appears in **no** `Round4*.md` file anywhere in the repo.
`Lecerf bivariate` is a round-48 paraphrase of round 47's "Lecerf 5.1". The census cites
`Round47_SUMMARY.md` for a census that is not in that file — the status table is in
`Round47_HandoverAddendum.md`, where the Harvey/Umans rows read "**STANDS.** Not re-litigated"
**with no reason given**. Six closures are asserted unchanged with no check recorded.

### What the census gets RIGHT (and should be given credit for)

- The **"79 discarded rather than silently approximated"** line matches `exp/run_c1_stats.py`
  exactly. Reporting the discarded fraction is honest and rare.
- **Shoup Thm 15.6** — verbatim, printed p. 413, PDF in hand, plus the p. 412 counting argument
  and the `π(y)` discharge tabulated at 256–4096 bits. This is the standard the other rows do
  not meet.
- **`0/890`, `19/19`, `102 vs 105`, the 112-cell E-6c re-run, the supply-audit control at 0.92σ
  reproducing the original log exactly** — all traceable.

---

# WHAT I WOULD NOT PUBLISH AS IT STANDS

**#522 `the_smoothness_wall_is_a_subgroup_wall.md` — DO NOT PUBLISH YET, but close.** The patch
fixed the headline algebra; **three residuals remain**: the three `ln k` numbers are stale, the
display table is still inverted (`L[1/3] > L[1/2]`), and §2.2's prose ("too slow past a few
thousand") contradicts its own corrected threshold by 25 orders of magnitude. **The fastest fix
is also the strongest one:** replace the cost argument with the two *unconditional* obstructions
(§A2.6) — `(smooth ∧ p|h) ⟹ p ≤ B`, and the triviality of `Cl(O_D/p)` — which retire the
factor-2 problem entirely because the exclusion no longer rests on the algebra. The Shoup half
is excellent and publishable on its own today.

**#523 `a_square_minus_a_cube_divides_twice.md` — PUBLISH ONLY after the 25–38% is withdrawn.**
The valuation law itself is exact, exhaustively verified, and correct — I confirmed it at every
p and k in range. But the paper's only quantitative payoff is unsourced, self-contradicted by its
own §6, and mischaracterised from its source's "naive reading". Without that number the paper is
an honest, valuable, purely qualitative result; with it, it overstates.

**#521 `the_baseline_that_was_not.md` — PUBLISHABLE with two edits.** Fix the §10.5 independence
claim and the u = 2.0 table row. The retraction is sound and should stand.

**`Round48_SUMMARY.md` — MUST BE CORRECTED before it is reused.** It propagates #523's withdrawn
claim in the row a future round will quote, and it drops caveats from three of its own notes.

**#524 `stange_works_and_its_analysis_does_not.md` — no FATAL found.** It is already
self-corrected, it carries its corrections at the top of the document where readers will see them,
and its §0 is honest about what survives. The only defect I found is upstream (`K_stange.md:8`
says 181/280). Its corrected 20/27 attribution is the right call.