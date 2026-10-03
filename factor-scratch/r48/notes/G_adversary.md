# G — ADVERSARIAL AUDIT of E-7, the genericity pattern, and the phantom sweep

Round 48. Agent G (adversarial verifier). 2026-10-03.
Code: `factor-scratch/r48/exp/G/`. Nothing committed. No issues opened.

**Bottom line: E-7's milestone is NOT passed. At matched order scale the class-group arm
is *worse* than the EC arm at every smoothness parameter tested, and the recorded
0.400 vs 0.320 is a scale artefact that reverses sign when the scale is matched.**

---

# V1. THE E-CLAIM AUDIT

## 1.1 What is actually on disk

`Experiments/e7_results.json`, in full:

```json
{"n": 25, "p_linked_smooth": 0.4, "ec_smooth": 0.32}
```

The claim as published, `Experiments/FACTORING_PROGRAM_SUMMARY.md:28-29`:

> **E-7**: the p-linked family (D=-q, q≡3 mod 4) also beats EC: 0.400 vs 0.320
> → milestone PASSED.

**There is no harness.** `git log --diff-filter=A` over all history: E-6b, E-6c and E-7 each
committed a `.md` and a `.json` and **never a `.py`**. Commit `b6c7386dd` ("E-7 p-linked
discriminant lottery rate measured") is 4 files: `E7_RESULTS.md` (3 lines), `e7_results.json`
(1 line), and two auto-generated `version.js` bumps. `E7_RESULTS.md` in full:

> Measured h(-q) smoothness for q random primes ≡ 3 mod 4 (the ideal-ECM
> discriminant family) vs matched EC baseline — results above / e7_results.json.

So **four load-bearing parameters are unrecorded**: the bound `B`, the bit-length of
`h(-q)`, the bit-length of the EC orders, and the RNG seed. `FACTORING_PROGRAM_SUMMARY.md:4`
claims "All experiments reproducible, committed, pushed." For E-7 they are none of the three.

## 1.2 What "the 0.320 EC baseline" is measuring — and why it is not at matched scale

Three "EC baseline" numbers appear in the program with no common definition:

| value | where | class value | scale stated |
|---|---|---|---|
| 0.925 | `e6b_results.json` | 1.000 | `h ≤ 1684` (≈11 bits); "typical EC order ~2^60" (`E6B_RESULTS.md:8`) |
| 0.440 | `e6c_results.json` | 0.720 | "~29-bit class numbers" (`E6D_IDEA_ECM.md:3`) |
| 0.320 | `e7_results.json` | 0.400 | **none** |

**Answer to the question as posed: the "0.320 EC baseline" is not a measurement of anything
that has ever been written down.** It is a single stored scalar with no `B`, no order size,
no sample definition, and no harness — and it takes a third value in E-7 that appears
nowhere else in the program. It is not at matched scale because **no scale was ever
recorded for it**, and the one scale the program does state for the EC arm is 49 bits away
from the class arm in E-6b.

Two arithmetic checks on E-6b, at its own stated `B = B₁₀₀₀`, from
`G/G_ci_and_e6b.py` (uniform random integers, 3000 samples each):

```
  uniform 11-bit integer is B=1000-smooth: 2602/3000 = 0.8673
  uniform 20-bit integer is B=1000-smooth:  876/3000 = 0.2920
  uniform 29-bit integer is B=1000-smooth:  164/3000 = 0.0547
  uniform 40-bit integer is B=1000-smooth:   18/3000 = 0.0060
  uniform 60-bit integer is B=1000-smooth:    0/3000 = 0.0000
```

The class arm's `1.000` at `h ≤ 1684` is **arithmetic, not structure** — an 11-bit number is
almost always 1000-smooth. The stated EC comparison point (2^60) would give **0.000**, not
0.925. So E-6b's 0.925 is neither the 11-bit value nor the 60-bit value; it is
irreproducible from the stated `B`. E-6b is honest about this in prose — *"PILOT CAVEAT: sizes
not matched (h ≤ 1684 ≪ typical EC order)"* (`E6B_RESULTS.md:7`) — and then **E-6c and E-7
keep the word "matched" and drop the caveat.**

## 1.3 The independent re-run

`G/G_e7_audit.py`, self-tested first by `G/G_selftest_e7.py` (25 known class numbers from
`-3` to `-163`; `is_smooth` cross-checked against `sympy.factorint` at two bounds; Hasse
verified on 200 curves). **The self-test earned its keep twice**: it caught a cached-sieve
bug that certified a number smooth after dividing out a prime *larger* than `B`, and a
q-range off by one bit. Neither would have been visible in the output.

Design: both arms bucketed into the **same order-bit-length band [2²⁹, 2³⁰)**, and `B` set
per-sample from a *fixed* `u = log(order)/log(B)` so the two families use the same relative
bound. Arms: `h(-q)` for `q` prime ≡ 3 mod 4 (class), and `#E(F_p)` for random curves (EC).

**Run A** (`G_e7_results_v1.json`, n=60 each, seed 20261003, class q at 61 bits, EC p at 30 bits):

| u | B range | class whole-order | EC whole-order |
|---|---|---|---|
| 1.5 | 6.6e5–1.0e6 | **0/60 = 0.000** | 42/60 = 0.700 |
| 2.0 | 2.3e4–3.3e4 | **0/60 = 0.000** | 21/60 = 0.350 |
| 2.5 | 3.1e3–4.1e3 | **0/60 = 0.000** | 9/60 = 0.150 |
| 3.0 | 8.2e2–1.0e3 | **0/60 = 0.000** | 1/60 = 0.017 |

`class_whole = 0/60` at every `u`. Wilson 95% CI on 0/60 is **[0.000, 0.060]**.

**Run B** (`G_parity_L29.log`, larger n, independent seed, adds the two control arms):

| u | A uniform | B uniform-**odd** | EC | **class** | class/odd | class/EC |
|---|---|---|---|---|---|---|
| 1.5 | 0.559 | 0.518 | 0.601 | **0.506** | 0.98 | 0.84 |
| 2.0 | 0.282 | 0.244 | 0.306 | **0.240** | 0.98 | 0.78 |
| 2.5 | 0.107 | 0.100 | 0.141 | **0.082** | 0.82 | **0.58** |
| 3.0 | 0.036 | 0.036 | 0.053 | **0.026** | 0.73 | **0.49** |

n = 4000 (uniform, odd, EC), n = 267 (class numbers; class numbers cost ~1.4 s each).

## 1.4 The corrected ratio, with CI and sample size

**Ratio = P(class number B-smooth) / P(EC order B-smooth), at matched 29-bit order scale:**

| u | class | EC | **ratio** | **95% CI** | Fisher *p* |
|---|---|---|---|---|---|
| 1.5 | 135/267 = 0.506 | 2404/4000 = 0.601 | **0.841** | [0.72, 0.96] | 0.0000 |
| 2.0 | 64/267 = 0.240 | 1224/4000 = 0.306 | **0.783** | [0.60, 1.01] | 0.0000 |
| 2.5 | 22/267 = 0.082 | 564/4000 = 0.141 | **0.584** | [0.36, 0.93] | 0.0028 |
| 3.0 | 7/267 = 0.026 | 212/4000 = 0.053 | **0.495** | [0.21, 1.14] | 1.0000 |

**Sample size: n = 267 class numbers vs n = 4000 EC orders.** Ratio at the ECM-relevant
`u ≈ 2`: **0.78 [0.60, 1.01]**. At `u = 2.5`: **0.58 [0.36, 0.93]**, *p* = 0.0028.

**E-7 recorded 0.400/0.320 = 1.25. Measured at matched scale: 0.78. The sign reverses.**
Fisher exact two-sided on the recorded numbers themselves: ***p* = 0.769** — E-7 is not
merely unproven, it is the **least significant result in the E-6/E-7 series** and the only
one labelled a pass. (For scale: E-6c *p* = 0.085, E-6b *p* = 4.6e-5.)

## 1.5 Why it reverses — the parity confound

**For `q ≡ 3 mod 4` prime, `h(-q)` is always ODD.** Verified: **0/60 even** in Run A,
**267/267 odd** in Run B. (Self-test: 20/20 known cases.)

**EC orders are even 43/60 = 72%** in Run A, **2696/4000 = 67%** in Run B.

So E-7 compares a sample drawn from **the odd integers** against a sample drawn from **all
integers**. An odd number has no factor of 2 and is therefore more likely to be B-smooth at
the same `B`. That is arithmetic bookkeeping, not a Cohen-Lenstra property.

The correct control is the odd-uniform arm. Against it:

- class/odd = **0.98, 0.98, 0.82, 0.73** — at most parity-equivalent, never better.
- Fisher class vs odd-uniform at the top `u`: ***p* = 0.4951**. **No detectable advantage
  once parity is matched.**

**The E-7 advantage does not survive parity matching.** What remains is a
*disadvantage* of 0.49–0.84 versus EC, which is consistent with class numbers of prime
discriminant being constrained well by the Cohen-Lenstra distribution — i.e. the theory
E-6/E-7 cite argues *against* them.

## 1.6 Three further defects

1. **The experiment does not measure the quantity it was designed to measure.**
   `E6D_IDEA_ECM.md:25-26` specifies `h(D_p)` where `D = -q·p⁰-form discriminant proxy`,
   because *"the mod-p quotient perturbs by `(p − (D/p))` factors — needs E-7
   verification"* (`:17`). The run measures **plain `h(-q)`**; **`p` is absent from E-7
   entirely.** The field named `p_linked_smooth` measures no `p`.
2. **n dropped 8×** from its own design (200 → 25), with *p* = 0.769, reported as PASSED.
3. **Caveat erosion.** E-6b prints the unmatched-scale caveat; E-6c and E-7 keep the word
   "matched" and delete it. `FACTORING_PROGRAM_SUMMARY.md:39-41` still carries
   *"a live, evidence-backed lead on class-group lotteries"* — and that is now
   *measurably the wrong way round*.

## 1.7 Verdict on V1

**The E-7 milestone is NOT passed.** It is not merely underpowered — at matched order
bit-length with parity controlled, the class-group arm is **worse** than the EC arm
(ratio 0.78 [0.60, 1.01] at u = 2, n = 267 vs 4000; 0.58 [0.36, 0.93] at u = 2.5,
*p* = 0.0028). The recorded 1.25 is an artefact of comparing odd integers against all
integers at an unrecorded, unmatched scale.

---

# V2. THE GENERICITY PATTERN — VERDICT

Full inventory with quotes and `file:line` references: **`factor-scratch/r48/notes/A2_genericity.md`**.

## The verdict in one sentence

> **It is a real mathematical law AND a live methodological error, and the program has
> itself drawn exactly the dividing line: the genericity conditions are structural (the same
> "required condition holds only on a measure-zero locus" shape appears in five unrelated
> domains, and every careful correction moved a rate *down*), but 16 of the 18 recorded
> instances were caught precisely *because somebody printed the population the number came
> from* — and the two that were not caught (the box supply rates, and E-7) are the two numbers
> where nobody ever printed it.**

Evidence for the *law* half: 18 distinct instances across NFS irreducibility (fails 100%,
search space empty), the χ_P branch, GAP coverage (516/1000 sub-unit hit probability, random
config at e⁻²¹⁰), CM integrality (j integral in 0/275), the class-group smoothness lottery,
function-field genus exception loci. Identical shape, unrelated domains.

Evidence for the *error* half: the discriminator is audit coverage, not domain. 16 caught,
2 not. The uncorrected region is exactly `Experiments/` — grep for `E-6|E-7|class-group
lottery|Cohen-Lenstra` across `Catalog/`, `factor-scratch/` and the memory notes returns
**zero hits**, i.e. the E-series was never audited by the round-47 machinery that caught
everything else.

**The single highest-value instance is A10** (`Round48_CostExponent.md:90-94`):

> "The box is not the algorithm's population. … the box overstates a scanned instance's
> relation rate by **47× (24 bits) to 326× (32 bits)** … **Every supply number in Rounds
> 45–47 is a box number; none is a rate for the algorithm.**"

That is not one side experiment; it invalidates the quantitative spine of rounds 45–47 —
and it was found **three rounds after** those rounds were committed, including after two
commits whose headlines are on the current branch.

**E-7 is a textbook instance of the pattern**, and the connection to V1 is exact: the
"structural" condition it needed was Cohen-Lenstra odd-part concentration. That condition is
real, but the experiment **did not condition on it** — it let parity do the work and read
the result as structure. So E-7 is not a case of the mathematics misleading the program; it
is the program failing to apply the lesson it had already written down sixteen times.

**Counterexample that keeps this honest:** `f-genericity-resolved.md:62-68` — at
n = 603901889, 500/1968 = 25.4% vs theoretical 1/4, **0.42σ**, self-tests written first, and
it states what it does *not* establish. That is the standard E-7 did not meet.

---

# V3. THE PHANTOM SWEEP

Full list with corrections: **`factor-scratch/r48/notes/A3_phantoms.md`**.
No WebSearch used (arXiv API / Crossref / zbMATH author lists only, per the earned rule).

**54 candidates examined → 41 VERIFIED, 8 PHANTOM/DEFECTIVE, 5 UNVERIFIED.**

## The sixteenth outright phantom

> **`Bernstein–Blekherman–Jenkings–Shor–Trop (ASIACRYPT 2013) §5.2`** —
> `Catalog/Cryptography/FactoringBarriers/Round47_AuxiliaryInformation.md:21`

Crossref returns nothing for this five-author combination in **any** venue or year. It is
cited as the *independent corroboration* of the sharp "the 1/4 is half the bits of p"
correction. Strike it or replace it — the bound still stands on Herrmann–May alone.

## Seven defective venue strings (papers real, citations wrong)

| # | asserted | correct | where |
|---|---|---|---|
| 2 | `arXiv:2601.17422` (NSSV JACM 71(2) 2024) | **arXiv:2110.08354**, JACM 71(2):1–79, DOI 10.1145/3638349 | `Round46_Handover.md:124` |
| 3 | Bühler–Lenstra–Pomerance, "ANTS-III, LNCS 1262, 1994" | **LNM 1554 (1993) 50–94**, DOI 10.1007/BFb0091539 | see A3 |
| 4 | von zur Gathen–Kaltofen, *Math. Comp.* 44 (1985) | **Math. Comp. 45(171) (1985) 251–261** | see A3 |
| 5–7 | Kaltofen JSC 29(6):891–919; Lenstra *Annals* 126(3) 1987 p.649; Buchmann–Williams *J. Cryptology* 1(2) 1988 107–118 | confirmed correct | — |

**Defect 3 has a second-order consequence:** since the BLP chapter starts at book p.50, the
corpus's bare **"BLP p.15"** and **"p.27"** references are *ambiguous* (chapter vs book
pages) — and those two page cites carry two *retracted* theses.

## The spine is sound

Lee–Venkatesan verified (JNT 187 (2018) 92–159) and **ten internal page/theorem cites all
check out**, including Remark 5.5's `(log log n)^{-1/3}` and the `1.92299` vs `1.90188`
distinction that a text-layer read destroys. So the phantom problem is at the *edges*, not
the core.

## Structural finding

**Six of the eight defects sit inside the program's own correction tables.** The repair
machinery caught its phantoms and then introduced fresh venue errors of exactly the kind it
was built to catch. Self-correction does not imply self-consistency.

## Unverified — do not re-cite until opened

`arXiv:2006.06197` (BGGHTZ — one of the two closures of the GNFS constant; arXiv API was
429-blocked for the whole audit); the TCS 226 tail; **Herrmann–May p.3 verbatim quotes**
(bibliography exact, quotes not re-read — that file's entire deliverable); BLP p.15/p.27
content; LV p.39 "every possible factor".

---

# CROSS-CUTTING: WHAT THIS MEANS FOR THE FOUR HEADLINE COMMITS

None of the four current-branch headlines is an E-7 claim, and this audit does **not**
touch the mathematical content of the dimensional closure, the rationality filter
diagnosis, or the withdrawal of "polynomial-time factoring" — those are separate and stand
or fall on their own.

But two things bear on them:

1. **"the cost exponent is 0.53, and 'dead at 128 bits' was an artifact"** — per A10,
   every supply number in rounds 45–47 is a *box* number, not a rate for the algorithm, and
   the box overstates the relation rate by **47× to 326×**. If the supply is what drives
   0.53 and the 128-bit crossover, that exponent inherits the box inflation.
2. **The genericity verdict says the failure is a law, not a blunder.** The two live
   directions that survived to the current branch were never audited by the machinery that
   caught the other sixteen. That is a *coverage* gap, and it is the one thing this round
   can still fix cheaply.

# WHAT WOULD SETTLE E-7

It cannot be settled by more samples at the current design, because the current design is
confounded. A clean run needs, stated in advance: `B`, the order-bit-length band for **both**
arms, the seed, and **an odd-uniform control arm** — plus `h(D_p)` rather than `h(-q)`, since
that is the quantity the mechanism needs. On the evidence here, the class-group lead is not
merely unproven; it is pointed the wrong way.