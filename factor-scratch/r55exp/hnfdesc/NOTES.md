# r55exp/hnfdesc — the class-group / BQF descent route to factoring

## VERDICT UP FRONT

**The closure's CONCLUSION is sound but its stated REASONING is wrong — and
wrong in a way that is itself worth recording. There is a real crack: the
closure is "unconditional" via a premise that never actually holds.**

The corpus closure (`Papers/fifty_two_rounds.md:173`, duplicated at
`Papers/fifty_rounds_assembled.md:91`) reads:

> Class groups — **unconditionally** (`h` B-smooth ∧ `p ∣ h` ⟹ `p ≤ B`,
> inconsistent at the relevant bound).

I gave that closure its strongest hearing first, then built the thing it says
is closed. Four findings:

1. **The smoothness hypothesis is NOT necessary — the closure's argument is
   refuted as an argument.** The explicit reduced-form descent recovers a
   genuine factor of `N = pq` on **24/24 instances, 8/8 of them in the
   adversarial `rough-both` cell where Pollard p−1 succeeds 0/8.** No
   smoothness of `h` is assumed anywhere. The closure's stated reason ("h must
   be B-smooth for the sieve, which is inconsistent") is simply not what
   happens.

2. **⚠️ The closure's other conjunct, `p ∣ h`, is FALSE — never once observed.**
   Measured over **250 balanced instances at 17–25 bits: `p ∣ h(−4N)` in
   0/250**, and `q ∣ h(−4N)` in 0/250. Over a further **300 unbalanced
   instances (13–21 bits, both discriminant conventions): 0/300.** And
   `LPF(h) > p` in **250/250** balanced cases (median `LPF(h)/√p ≈ 1.9`).
   So the closure is a conditional whose antecedent is essentially never
   satisfied. It is labelled "unconditionally", but it is *vacuously* true:
   the conjunct `p ∣ h` does not occur, so `h B-smooth ∧ p ∣ h ⟹ p ≤ B` is
   never actually exercised. **The closure is right for the wrong reason, and
   its reason is not even a coherent premise.**

3. **The route is genuinely NOT Pollard rho in disguise** (the central control,
   §4). Descent work tracks the class number (`ρₛ = +0.977`) and is weakly
   correlated with `√p`, the rho-predictor (`ρₛ = +0.230`). And it is
   **46×–819× more work than rho**, not less. A rho-disguise would have to be
   ~10³× cheaper.

4. **What actually kills the route is a COST statement, not a smoothness
   statement:** the descent is a traversal of the class group, so its cost is
   `Θ(h(D)) = Θ(√N)` — asymptotically **worse than rho's `N^{1/4}`** by a factor
   `N^{1/4}`, and catastrophically worse than GNFS. See §5.

So: **crack in the REASONING (wrong and vacuous premise), no crack in the
CONCLUSION (route is dead).** Per the brief, a refutation-gate kill is a
success, and here the kill is clean: the route is closed for a reason strictly
stronger than the one on record, and the reason on record should be corrected.

**Strongest single piece of evidence:** the descent works 8/8 on `rough-both`
instances where p−1 works 0/8, *and* correlates with `h(−4N)` at `+0.977` while
correlating with `√p` at only `+0.230`. The route is real, structural, and 46–819×
too slow — and it never needed `h` to be smooth, which is what the closure
claimed was impossible.

---

## 1. TOOLING — PARI availability and the ellcard hazard

- `gp` binary: **NOT installed.** PARI is available **only via `cypari2`**
  (Python bindings). All PARI access in this round is `cypari2.Pari()`.
- `sympy 1.13.1`, `fpylll` present.
- ⚠️ The recorded hazard (PARI `ellcard` silently returning `N+1` on composite
  `N`, 0/6 matching ground truth) makes it mandatory to validate `qfbclassno`
  **in this regime** before trusting a number. **Validated 18/18** against an
  independent brute-force enumeration of reduced forms at `|D| ∈ [10⁴, 10⁶]`,
  and the descender validated **8/8 against `qfbclassno` at 33–35 bits** (the
  regime of use). `qfbclassno` returned `|D|+1` on **0** cases.
  See `out_validate_A.txt` / `_B.txt` (byte-identical across runs).

## 1b. THE CLOSURE'S PREMISE, TESTED DIRECTLY — IT NEVER HOLDS

The closure is stated as **unconditional** via `h B-smooth ∧ p ∣ h ⟹ p ≤ B`.
The `p ∣ h` conjunct is a *fact about the class number*, so it is directly
measurable. It is false:

| test | n | result |
|---|---|---|
| `p ∣ h(−4N)`, balanced, 17–25 bits | 250 | **0** |
| `q ∣ h(−4N)`, balanced, 17–25 bits | 250 | **0** |
| `p ∣ h(D)`, unbalanced, 13–21 bits, both `D` conventions | 300 | **0** |
| `h(−4N)` B-smooth with `B = √p` | 60 | **0** |
| `LPF(h) > p` | 250 | **250** |

Median `LPF(h)/√p ≈ 1.9`. So the large prime factor of `h` comfortably *exceeds*
`√p` — meaning `h` is **not** `√p`-smooth, which is the operational content of
the closure's claim — but the specific inference the closure writes down
(`p ∣ h`) is not a thing that happens. The conclusion ("don't sieve `h`")
survives; the argument offered for it does not.

## 2. MY OWN ERRORS (recorded prominently)

Four, all caught by controls rather than by inspection:

- **E1 — derived the Gauss chain successor from memory; it was wrong.** My
  `_succ()` returned `None` immediately (chain length 1 vs true h=240). I was
  reasoning from a remembered algorithm — exactly the recorded error class. I
  discarded it and **derived** the enumeration from the discriminant
  (below) instead of recalling a successor rule.
- **E2 — the detector fired vacuously on `a = 2`.** `2 | 4N` *always*, and
  `gcd(2,N)=1` for odd `N`. Unguarded, the descent "succeeded" on every
  instance in 2 forms with `gcd = 1` — a false PASS that would have been the
  whole result. Fixed with an explicit trivial-divisor guard `{1,2,4}` **plus**
  requiring `1 < gcd(a,N) < N`.
- **E3 — my 2-adic root solver silently dropped roots** (returned `[3,11]`
  where the truth is `[3,5,11,13]`), causing 3/11 validation failures. My
  analytic Hensel lift was wrong; replaced by brute-force seeding + *verified*
  one-level-at-a-time lifting. After the fix: **15/15 exact** against brute
  force, including ordering.
- **E4 — a silent `a_cap` manufactured a fake structural result.** The descent
  had `a_cap = min(..., 200000)`. The ambiguous form sits at `a ≈ min(p,q)`,
  which exceeds 200 000 above ~38 bits, so the descent reported
  `hit_a = None` — "no factor found" — for *truncation reasons*, not
  structural ones. Worse, this produced an apparently beautiful and completely
  **false** trend: `forms/h(−4N)` collapsing 1.85 → 0.030 with size, which
  looked exactly like the "small-step reachability" crack the round was hunting
  for. **It was my own ceiling.** Removed (now a safety valve only, and callers
  check the `capped` flag). §6 records the corrected numbers.

  E4 is the most dangerous error in this round because it *looked like a
  positive result*. Any claim of the form "cost drops with N" from an
  instrument with a ceiling is suspect by construction.

- **E5 — the enumerator counted IMPRIMITIVE forms, inflating `h(D)` by exactly
  2×.** Caught only because I ran the descender against `qfbclassno` at scale
  and got ratios of exactly `2.0` and `4/3` instead of `1.0`. Only *primitive*
  forms are classes of the order of discriminant `D`. Diagnosed empirically
  (not from memory): primitive-only counts matched `qfbclassno` **exactly** on
  7/7 discriminants (`154=154, 54=54, 174=174, 210=210`). After the fix,
  descender vs `qfbclassno` is **8/8 exact** at 33–35 bits, and the control's
  correlation with `h` *sharpened* from `+0.915` to `+0.977`. **A 2× error
  that a correlation test would have hidden** — only the absolute-count check
  caught it. Every descent count in this document is post-fix.

  **⚠️ Scope of E5, verified rather than assumed.** E5 only bites when
  `N ≡ 3 (mod 4)`. An imprimitive form of disc `−4N` needs `gcd(a,b,c) = 2`,
  which requires a form of discriminant `−N` to exist — and `−N` is a
  discriminant only when `N ≡ 1, 2 (mod 4)`. Checked directly on **both** §6
  instances (both `N ≡ 1 mod 4`): imprimitive forms encountered = **0** in each,
  and the descent counts are identical with and without the filter. So E5 is a
  **no-op on the §6 table and those numbers are unaffected**. The control
  instances that E5 changed are the `N ≡ 3` ones. Worth recording because a
  reader who assumed "2× everywhere" would wrongly distrust §6.

Two further instrument bugs worth recording: `sympy.primefactors(10000)` returns
the prime factors **of** 10000 (`[2,5]`), not the primes below it — this made
smooth-prime construction impossible (0 primes in 200 000 tries); and building
a smooth prime by multiplying random small primes overshoots the target bit
length by many bits at once, with no convergent way to step back.

## 3. THE DESCENT ROUTE — construction

`D = −4N`, `N = pq`. For `D ≡ 0 (mod 4)`, reduction forces `b = 2y`, and

```
b² − D = 4ac   ⟺   4y² + 4N = 4ac   ⟺   y² + N = a·c
```

So reduced forms of `D = −4N` are in bijection with pairs `(a, y)` such that
`a | (y²+N)`, `c = (y²+N)/a`, and `−a < 2y ≤ a ≤ c` (with `2y ≥ 0` when `a = c`).
This turns "enumerate reduced forms" into "for each `a`, solve `y² ≡ −N (mod a)`"
— a per-`a` modular square root by CRT over prime powers. `O(a_max · polylog)`,
not `O(|D|)`.

**Validation chain (no single point of failure):**
- `L1` brute-force enumeration `(a,b)` loop — ground truth, small `D`.
- `L2` the CRT descender above — fast, any `D`.
- `L3` PARI `qfbclassno` — count only, validated 18/18 against `L1`.

`L2 == L1` **exactly** (forms *and* ordering) on **15/15** random instances.

**The factor-bearing form.** With `D = −4pq` and `p < q`, the form
`(p, 0, q)` is reduced (`0 ≤ p ≤ q`, `b = 0 ≥ 0`), its leading coefficient
`p` divides `D`, and `gcd(p, N) = p`. So the descent **does** reach a factor —
this is mechanism (a) in the literature (Schnorr–Lenstra / Sayles: *"we find a
reduced ambiguous class representative with discriminant Δ … we compute
d = gcd(a, N)"*). The round question is therefore **not** whether it works.

## 4. THE POLLARD-RHO-DISGUISE CONTROL — the most important section

**The threat, stated.** A method that "factors `N` via the class group" in
small time is often rho in disguise: it is finding `p` by a random search and
the class-group attribution is spurious. Controls executed:

**(A) MAGNITUDE — per cell, `n = 24` (≥20, powered).** All counts post-E5 fix.

| cell | `h(−4N)` | descent forms | rho median steps | ratio |
|---|---|---|---|---|
| smooth-both | 44456 | 36305 | 127 | 286× |
| smooth-one | 113484 | 88724 | 511 | 174× |
| rough-both | 60714 | 49976 | 519 | 96× |
| … (21 more rows in `results_part2.json`) | | | | |

Over all 24: **ratio min 46×, median 166×, max 819×.** The descent is *more*
expensive than rho by two to three orders of magnitude. A rho-disguise would
have to be ~1000× **cheaper**. It is not.

**(B) DISCRIMINATION — the decisive test.** If the descent were rho in disguise,
its work would track `√p`. If it is genuinely class-group, it tracks `h`.

```
Spearman(descent_forms, h(−4N))   = +0.977     <- tracks the CLASS NUMBER
Spearman(descent_forms, sqrt(p))  = +0.230     <- barely tracks rho's predictor
Spearman(h(−4N)/rho_steps, forms) = +0.710
```

The predictor that explains the descent's work is the **class number**. `√p` is
nearly constant across these instances (all 33–34 bits) while `h` varies ~4×,
so this is a genuine discrimination, not two collinear variables. The `+0.230`
is not zero, which is expected and worth stating: the descent does have a
size-dependent component (its cost is `Θ(√N)`), but the *class-number*
explanatory power is 4× stronger on the same instances.

**(C) ADVERSARIAL CELLS — deliberate structural asymmetry.** Instances were
built with tags that are adversarial *to the smoothness story specifically*:
- `smooth-both` — both `p−1`, `q−1` are `y`-smooth (y = 10 000)
- `smooth-one` — `p−1` smooth, `q−1` deliberately not
- `rough-both` — **neither** is smooth

| cell | n | descent recovered factor | Pollard p−1 works |
|---|---|---|---|
| smooth-both | 8 | 8/8 | 8/8 |
| smooth-one | 8 | 8/8 | 8/8 |
| **rough-both** | **8** | **8/8** | **0/8** |

The descent works on exactly the instances where the smoothness-based methods
fail. **Its success is not a smoothness artifact.** *(Each cell n=8 is below
20 — labelled indicative; the pooled 24/24 is powered.)*

Smooth-p−1 primes are **constructed** (`p = m+1`, `m` a product of primes ≤ y),
not rejection-sampled: measured random `p−1` smoothness is ~0.05 % at 17 bits,
so sampling does not terminate.

**(D) DETECTOR CONTROLS.**
- POSITIVE: descent recovered a genuine factor on **4/4**.
- NEGATIVE: on `D = −4r` with `r` prime, non-trivial `a | D` hits = **0** for
  both `r = 65537` and `r = 131101`. **Stays quiet, 2/2.**

**Conclusion of the control: the descent route is real, structural, and not
rho in disguise.**

## 5. COST OR STRUCTURE? — the actual round question

The brief asks: if the group is not smooth, is the failure a **cost** problem or
a **structural** one?

**Answer: neither failure occurs — the information IS there and IS extracted.
What fails is the COST MODEL.** And the cost failure is unambiguous:

| bits | descent `N^1/2` | rho `N^1/4` | descent/rho | GNFS | descent/GNFS |
|---|---|---|---|---|---|
| 128 | 10^19.3 | 10^9.6 | 10^9.6 | 10^10.1 | 10^9.1 |
| 256 | 10^38.5 | 10^19.3 | 10^19.3 | 10^14.0 | 10^24.5 |
| 1024 | 10^154.1 | 10^77.1 | 10^77.1 | 10^26.1 | 10^128.0 |
| 2048 | 10^308.3 | 10^154.1 | 10^154.1 | 10^35.2 | 10^273.1 |

The descent traverses a **constant fraction of the class group** (§6), so its
cost is `Θ(h(D)) = Θ(√N)`. That is asymptotically **worse than rho by
`N^{1/4}`** and beats-or-loses-to nothing. This is the closure — restated as a
cost statement, which is *strictly stronger* than the smoothness statement,
because it needs no smoothness assumption at all.

The "descent in small steps" hope is dead for a concrete reason: there is no
short path to the ambiguous class. The ambiguous form sits at leading
coefficient `a ≈ min(p,q) ≈ √N`, i.e. at `√N` scale, and you must enumerate the
forms up to there.

## 6. THE `forms/h` QUESTION — corrected after error E4, and it MATTERS

`scaling.py` first reported `forms/h(−4N)` falling **1.85 → 0.030** from 30 to 46
bits, which looked *exactly* like "small-step reachability" — the crack the round
was hunting: cost dropping as a shrinking fraction of the class group. **It was
an artefact of my own `a_cap` (error E4).** With the ceiling removed and
primitivity enforced, the uncapped measurement is:

| `N` bits | `min(p,q)` | hit `a` | descent forms | `h(−4N)` | **`forms/h`** |
|---|---|---|---|---|---|
| 34 | 92399 | 92399 | 111969 | 123608 | **0.906** |
| 38 | 309371 | 309371 | 117401 | 152852 | **0.768** |

(Both rows verified unaffected by error E5 — both instances have `N ≡ 1 (mod 4)`,
so imprimitive forms do not exist and the counts are identical with and without
the primitivity filter; checked directly on both, 0 imprimitive forms each.)

**Provenance of these two rows, re-verified end-to-end.** Both instances were
regenerated and every number recomputed:

| row | `p` | `q` | `N` bits | `N mod 4` | `h(−4N)` recomputed | forms recomputed | match |
|---|---|---|---|---|---|---|---|
| 1 | 92399 | 102559 | 34 | 1 | **123608** ✓ | **111969** ✓ | yes |
| 2 | 477011 | 309371 | 38 | 1 | **152852** ✓ | **117401** ✓ | yes |

Both `p` and `q` confirmed prime in each row. `min(p,q)` matches the `hit a`
column in both rows. For row 2 the descent count was recomputed **with and
without** the primitivity filter and both give 117401, with **0 imprimitive
forms encountered** — so row 2 is confirmed unaffected by E5, exactly like row 1.

The reduced range for row 1 is `a_max = 112408`, so the descent stopping at
`a = 92399` is 82.2 % of the way through the range — i.e. it genuinely traverses
most of the class group rather than cutting a corner.

Note both instances have `N ≡ 1 (mod 4)`, so `−4N` is **not** the fundamental
discriminant of `ℚ(√−N)` (that is `−N` there, and `−N` is not itself a
discriminant). This does not affect any claim: `qfbclassno(−4N)` and my
enumeration both describe the order of discriminant `−4N`, and they agree
exactly. It does mean "the class group" here is that of the *order*, which is
the object the ambiguous-form mechanism actually uses. The `N ≡ 3 (mod 4)`
instances — where `−4N` *is* fundamental and E5 *does* bite — are the ones in
the §4 control table.

`forms/h` is **Θ(1)** — a constant fraction of the class group, not a shrinking
one. So:

- **There is no small-step reachability.** The descent traverses essentially the
  whole class group before it reaches an ambiguous form. Cost `Θ(h(D)) = Θ(√N)`.
- **The hit is at `a = min(p,q)` exactly** (34-bit and 38-bit rows both), i.e.
  the first *divisor-revealing* leading coefficient, at `≈ √N` scale. That is a
  size fact, and it is why the cost is `√N` and not sub-`√N`.
- The early exit is *not* a shortcut: it stops at the **first** factor-bearing
  form, which is simply the first time `a` reaches `min(p,q)`.

This closes the last crack I had. The route recovers the information (structural,
not random) at a cost of `Θ(√N)` — worse than Pollard rho.

## 7. WHAT IS NOT DETERMINABLE FROM HERE

- **Asymptotics beyond ~2×10⁵ forms.** The uncapped descent was measured to
  38-bit moduli (`N ≈ 2.7×10¹¹`, `h = 152852`); the pure-Python descender runs at
  ~8 µs per `a`-value, so 41+ bits exceeds the time budget. The `Θ(√N)` claim
  rests on `forms/h` being `Θ(1)` (0.906 at 34 bits, 0.768 at 38 bits), which is
  consistent at both measured sizes but is **not proved** for all `N`. Two data
  points do not establish an asymptote; I label it strong evidence, not a theorem.
- **The full index-calculus version.** Hafner–McCurley / Buchmann /
  Lenstra–Pomerance do **not** do this descent; they build a factor base of
  small-`a` forms, sieve for relations, and do linear algebra — that is what
  actually achieves `L[1/2,·]`. **I did not implement it.** It is the one
  genuine open axis, and its known exponent (`L[1/2,1]`, verified from the
  Lenstra–Pomerance abstract, §8) already loses to GNFS `L[1/3,1.9019]`, so I do
  not expect it to reopen the route — but I have not measured it and do not
  claim to have. **This is the honest limit of this round.**
- **Whether the index-calculus route's smoothness bottleneck is cost or
  structural.** Not addressed here.
- **`h` vs `2h`, and the narrow class number.** I used the ordinary class number
  via `qfbclassno` throughout and did not test narrow-class variants.
- **PARI's ERH-conditionality question** (see §8) is unresolved and is a
  literature question, not something measurable here.

## 7b. WHAT WOULD CHANGE THE VERDICT

If someone wants to reopen this, the only axis with headroom is the
**index-calculus** version: reach an ambiguous class without traversing the whole
group. That requires relations among small-`a` forms — i.e. the class group
being *generated cheaply*, not *smooth*. Its proven exponent `L[1/2,1]` already
loses to GNFS, so it would need a qualitative improvement, not tuning. My
measurement of `forms/h = Θ(1)` says the naive descent has **no** headroom at
all: it is not merely un-optimised, it is `√N` by construction.

## 8. PROVENANCE

All work in `/home/raver1975/lean/factor-scratch/r55exp/hnfdesc/`. Nothing
modified outside it; no commits; no GitHub issues; nothing written to
`Papers/` or `Catalog/`.

**Code (all mine, this round):** `bqflib.py` (brute force + rho), `desc.py`
(CRT descender, Tonelli–Shanks, verified 2-adic lift, `SegSPF`), `gen.py`
(structural tags), `run.py`, `control.py`, `scaling.py`, `collapse.py`,
`validate_pari.py`. Outputs: `fv_val1.txt`, `fv_ctrl1.txt`, `out_formsH.txt`, `results_part1/2/4.json`.

**Scope guard honoured:** every modulus was generated locally with
`N < 2⁴⁶`; no modulus of cryptographic interest was factored. Classical integer
factoring of self-generated integers — no cryptographic break, and none claimed.

**Seed discipline:** `SEED = 20251004` at the top of `gen.py`, `run.py`,
`control.py`, `scaling.py`, `collapse.py`. The deterministic scripts were run
twice and their outputs diffed.

- `validate_pari.py`: **byte-identical across two runs** (`fv_val1.txt` vs
  `fv_val2.txt`).
- `control.py`: run twice; a plain `diff` **reports a difference**. Diagnosed
  rather than waved away: the difference is **entirely in the wall-clock `secs`
  column**. Diffing with that column excluded gives **bit-identical** output —
  every instance, every `h`, every descent count, every ratio, and all three
  Spearman correlations are exactly reproduced. So the scientific content is
  deterministic; only timings move. *(An unseeded moving count is uncitable;
  a moving clock reading is not.)* The reproducible artifact is
  `results_part2.json`, which carries no timing.

**No WebSearch was used.** Literature was fetched via zbMATH Open API, Crossref,
and Wayback; `dblp`, Springer and ams.org behaved as recorded (hang / 403 /
cookie HTML) and were avoided.

### Literature — verified records, and 4 new phantoms killed

Verified by direct API fetch this round:

- **Seysen, M.** "A probabilistic factorization algorithm with quadratic forms
  of negative discriminant", **Math. Comp. 48 (1987) 757–780**. zbMATH 4004252.
  (Also his 1984 Frankfurt dissertation, zbMATH 3879003.)
- **Lenstra–Pomerance**, "A rigorous time bound for factoring integers",
  **JAMS 5(3) 483–516 (1992)**, zbMATH 93757, DOI 10.1090/s0894-0347-1992-1137100-0.
  Abstract (verbatim, Crossref publisher deposit): *"a probabilistic algorithm
  is exhibited that factors any positive integer n into prime factors in
  expected time at most L_n[1/2, 1+o(1)] … The algorithm analyzed in this paper
  is a variant of the class group relations method, which makes use of class
  groups of binary quadratic forms of negative discriminant."*
- **Hafner–McCurley**, "A rigorous subexponential algorithm for computation of
  class groups", **JAMS 2(4) 837–850 (1989)**, zbMATH 4150335. Abstract claims
  `L(d)^{√2+o(1)}` **unconditionally**; a secondary source (Vollmer's thesis
  §1.3) asserts the analysis relies on a Riemann hypothesis and restates the
  bound as `L(1/2, 2+o(1))`. **Unresolved** — I could not obtain the primary
  text (ams.org serves cookie HTML). Flagged, not settled.
- **Schnorr–Lenstra**, "A Monte Carlo factoring algorithm with linear storage",
  **Math. Comp. 43(167) 289–311 (1984)** — the ambiguous-form mechanism.
- **Buchmann–Williams**, "A key-exchange system based on imaginary quadratic
  fields", **J. Cryptology 1(2) 107–118 (1988)**, DOI 10.1007/BF02351719.
- **Buchmann**, "A subexponential algorithm for the determination of class groups
  and regulators of algebraic number fields", Séminaire de Théorie des Nombres de
  Paris 1988–89, **Progress in Math. 91**, 27–41 (1990), zbMATH 4200333
  (the corpus has volume 96).

⚠️ **Four phantoms in the surrounding corpus, all found by verification:**

1. The corpus line *"Hafner–McCurley, A rigorous time bound for factoring
   integers"* steals its title from Lenstra–Pomerance 1992. HM's real title is
   *"…for computation of class groups"*.
2. The corpus citation *"Lenstra–Pomerance, Math. Comp. 62(206):865–874 (1994),
   the divisor class group of curves"* is a **3-way fusion**. That volume/issue/
   page range is a **Frey–Rück** paper. The real LP paper is JAMS 1992.
3. *"Buchmann–Williams, J. Cryptology 1(4):233–242 (1988)"* — the real record
   is **1(2):107–118**, DOI 10.1007/BF02351719.
4. *"Buchmann, Computing class groups … in subexponential time, ANTS, LNCS
   877"* — **no such chapter.** Buchmann's only LNCS 877 paper is on lattice
   bases (pp. 160–168).

**This is the 19th–22nd fabricated identifier in the programme's record, and it
is in the very corpus line this round was asked to audit.**
