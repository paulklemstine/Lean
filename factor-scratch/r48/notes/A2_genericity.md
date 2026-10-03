# A2 — THE "GENERICITY" PATTERN CHECK (audit assignment V2)

Scope: `Catalog/Cryptography/FactoringBarriers/` (RESEARCH.md exec-summary + §8 only, `Round47_*.md`,
`Round48_CostExponent.md`), `Experiments/` (E-6b/6c/7), and
`~/.claude/projects/-home-raver1975-lean/memory/*.md`.

**The pattern under test.** A construction requires a condition (irreducibility, a character taking
value −1, smoothness, a large automorphism/coverage set, a hit probability of 1) that GENERIC
objects fail a constant fraction of the time — so the construction silently works only on a
low-density subfamily, and the experiment reports the subfamily's rate as if it were the generic rate.

---

# (A) INVENTORY — 18 distinct recorded instances

Notation: **CAUGHT** = the program itself diagnosed it as genericity-limited (and, where noted,
whether the route was then closed). **NOT CAUGHT / LIVE** = the program over-read it or still
carries it as a positive route.

---

## A1. `f` irreducible mod p and mod q — *structurally impossible*, not merely rare
- **Condition:** `f = X³ + …` irreducible over `F_p` and `F_q`.
- **Fraction failing:** **100%, and the search space is EMPTY.** Memory
  `f-genericity-anomaly.md:10-13`: *"I constrained the polynomial by `f(m) = 0 (mod n)`. But that
  forces `m` to be a root of `f` modulo `p` AND modulo `q`, so a cubic `f` is **automatically
  reducible over both fields** … Consequence: the search space is EMPTY, and the run reported
  'irreducible f tested: 0'."* Corroborated in
  `phi-map-forces-f-reducible.md:12-17`: *"`Z[alpha]/p …` is **NOT a field** … **The Euler-criterion
  square test is invalid there.**"*
- **Verdict: CAUGHT**, and the strongest form of the pattern — the required condition fails
  *identically*, so the subfamily is empty rather than merely small. Route abandoned; the two
  experiments are declared void (*"Both the 0/125 and the 20,000-rejected runs are void, and should
  never be quoted."*, `f-genericity-anomaly.md:21`).

## A2. Same condition re-derived in the *positive* direction — `C` must be constructed, not filtered
- **Condition:** a `C` making `f(m) = 0 (mod n)` with `(X−m)` a factor and `Q` irreducible quadratic.
- **Fraction failing:** a 1-in-`n` hit rate that *"silently empties the search space — it was the
  cause of the eighth void run"* (`f-genericity-resolved.md:22-24`).
- **Verdict: CAUGHT.** Note this is the *fix* for A1 and is the same pattern seen from the other
  side: a hand-drawn filter replaces a structural condition and empties the population.

## A3. The branch `chi_P = ±1` — multiplicativity closes the `+1` locus
- **Condition:** some reachable relation has `chi_P = −1`.
- **Fraction failing:** `chi_P` is multiplicative on `P_S` (**69/69 tests**), so
  *"If every relation you can reach has `chi_P = +1`, then every PRODUCT of them does too, and no
  amount of additional relation-finding within the same `f` can ever produce a `−1`."*
  (`Round47_Multiplicativity.md:10,22-24`). For `n = pq` the non-trivial fraction is
  **exactly 1/2 or 0** — *"420/420"* (`Round47_Multiplicativity.md:40`).
- **Verdict: CAUGHT — and then PARTIALLY UNDONE, then re-killed by measurement.**
  `Round47_MultiplicativityCorrection.md:24-26`: *"CORRECTED: two relations that are each
  `chi_P = +1` can ADD, on the curve, to a relation with `chi_P = −1`. **My 'no combination can
  escape a `+1` locus' was too strong and is struck.**"* The suggested escape was then tested and
  died: *"**192 base points with `chi_P = +1`. The group law reached `chi_P = −1` at some `nP` in
  0 of them (n ≤ 14). 0 factors recovered.**"* (`Round47_EscapeTest.md:18-19`).
- **The measured failure rates themselves:** `chi_P = −1` found for **73% (70/96)** of `(N,f)` at
  `H = 60` (`Round47_HonestVerdict.md:34`); **60.5% (309/511)** with zero `ellrank` errors
  (`Round47_Audit.md:84-85`); **28% → 44%** over `H = 20 → 320` on 102 instances
  (`Round47_QuantitativeBarrier.md:18-23`). Later: per-`f` rate **14 bits 0.27–0.34 · 21 bits 0.28 ·
  25 bits 0.15 · 33 bits 0.05 · 37 bits 0.03** (`Round47_AuditOfMethod.md:50`) — i.e. **the generic
  rate decays toward 0 with size.**

## A4. `chi_P` non-trivial on `Q(E)` does NOT imply non-trivial on `E(Q)` — 11 of 24 fail
- **Condition:** `C(t)A(t)` square in `Q(t)` ⇒ `chi_P` constant.
- **Fraction failing:** *"Non-trivial on the *function field* does not imply non-trivial on `E(Q)`:
  the Mordell–Weil group is a thin"* subset — **`chi_P` is nonetheless `+1` on all of `E(Q)` in
  11 of 24 instances** (`Round47_MordellWeil.md:5.1, quoted in the retraction header at
  `Round47_MordellWeil.md` §5.1; also `Round47_SUMMARY.md:107`: **"refuted, 13/24"**).
- **Verdict: CAUGHT** (`Round47_HonestVerdict.md:105` lists it as REFUTED).

## A5. Rank > 0 ⇒ a `chi_P = −1` point exists — rank 0 in 10%
- **Condition:** Mordell–Weil rank > 0.
- **Fraction failing:** **rank 0 in 10%**; *"`chi⁻¹(−1)` is not Zariski-open"*
  (`Round47_HonestVerdict.md:106`, `Round47_SUMMARY.md:108`). Measured rank distribution
  `{0:2, 1:119, 2:247, 3:110, 4:30, 5:3}` — **rank 1 is 23%, not "a handful", and rank 0 occurs
  twice** (`Round47_Audit.md:74-76`).
- **Verdict: CAUGHT** (CLAIM 47 REFUTED).

## A6. GAP difference-set coverage: 516/1000 targets have hit probability < 1
- **Condition:** a GAP with `c+c'` APs covers all of `[n]` at `(α,β) = (0.45,0.45)`, `n = 1000`.
- **Fraction failing:** **516 of the 1000 targets have hit probability < 1** (those with `i > K = 484`);
  *"P(an uncorrelated configuration covers all of [n]) ≈ **e^{−210} ≈ 6×10⁻⁹²**"*
  (`gap-coverage-freedom-deficit.md:20-21`). Free parameters fall from **44** (unconstrained) to
  `(c+c')+1`, *"a **~10–40× reduction in freedom against 516 targets that each need a ~48% hit**"*;
  measured `c=1` reaches 977/1000 and *"nothing has reached 1000"* (`gap-coverage-freedom-deficit.md:23-28`).
- **Verdict: CAUGHT, and escalated to a structural kill:** *"GAP coverage at the parameters that buy
  the exponent is **not generic-plausible** — it would need structure far beyond a few-parameter
  difference set."* (`gap-coverage-freedom-deficit.md:32-34`).

## A7. Genus `g(Ŷ_d) = 1 + (d−3)2^{d−2}` — GENERIC VALUE with an exception locus
- **Condition:** transversality of `φ|_C_d`.
- **Fraction failing:** **34 `reduced=False` out of 136+34 = 170 rows**, of which **16 have `p | c`**
  (bad reduction) and **18 sit at primes NOT dividing `c`**. `Round47_FunctionField.md:139-143`: *"With
  the certificate now running over `d = 3..6 × 7 (c,m) × 7` fields: **136 rows `reduced=True`, 34
  `reduced=False`.** Of the 34, **16 have `p | c`** … and **18 sit at primes NOT dividing `c`**,
  e.g. `(d,c,m,p) = (3,1,3,13), (4,2,5,7), (4,1,3,5), (4,5,2,11), (5,3,5,7), (5,7,11,13)`."*
  (= **10.6% of all rows, 18/136 = 13.2% of the certified-generic rows.**)
- **Verdict: CAUGHT** — *"**So `Round47_DegreeBarrier.md` must record the genus as the GENERIC VALUE WITH
  AN EXCEPTION LOCUS, not as an identity for all `(c,m)`.**"* (`Round47_FunctionField.md:148-150`).
  **BUT** with an explicitly non-binding strength caveat: *"the certificate fails as 'no `D ≤ 30`
  found', so a resource limit is not excluded, and the criterion has **not** been shown exact at
  `d ≥ 4`"* (`Round47_FunctionField.md:157-160`), and the integer side of the same fact
  (`22/38` at `d=3`, `1/38` at `d=4`) is stated as *"a strong signal to be confirmed, not as
  established."* Note the direction of the correction is **toward the closure** (*"an exception locus
  makes the supply *worse*, not better"*), so it does not rescue the route.

## A8. Integer relation curves are EMPTY, not tall — 54% of moduli, ~half of all `f`
- **Condition:** the relation curve supplies at least one `chi_P = −1` relation at height `H`.
- **Fraction failing:** *"Zero to one relations at height 1500. **These curves are EMPTY.**"*
  (`Round47_EmptyCurve.md:22`) for 21/25/33/37-bit moduli; and *"**roughly half of them are empty**"*
  — *"A different `f` gives a different curve, and roughly half of them are empty"*
  (`Round47_EmptyCurve.md:31,50`). Per-`f` rate then falls **0.27–0.34 (14 bits) → 0.03 (37 bits)**
  (`Round47_AuditOfMethod.md:50`).
- **Verdict: CAUGHT, then the "which population" half was NOT caught for two rounds.** See A9.

## A9. ★ "Roughly half the moduli are dead" — a frozen selector read as a structural property of the moduli
- **Condition (claimed):** some moduli admit no successful `f`.
- **Fraction failing (claimed):** the 21/25/33/37-bit rows read **0.00, 0.00, 0.00, 0.00**
  (`Round47_Method.md:46-52`); *"**roughly half the moduli are dead**"* (`Round47_Method.md:42`).
- **Truth:** *"`find_m_c` restarts at `m0 = icbrt(N)+1` on **every call**, so **50 calls yield ONE
  distinct `f`**. Therefore `706/706` is *one relation counted 706 times*, and `772 trials / 0 hits` is
  *one frozen `f` counted 772 times*. … **'Roughly half the moduli are dead' is REFUTED.** Varying
  `f`: **21 bits 17/60 = 28% · 25 bits 9/60 = 15% · 33 bits 3/60 = 3%** … **Over 30 moduli × 120
  distinct `f`: 0/30 dead.**"* (`Round47_AuditOfMethod.md:34-42`). **0/30 moduli dead.**
- **Verdict: CAUGHT — but only after the claim had been *"written into three documents, and posted
  as an issue headline"*** (`Round47_AuditOfMethod.md:69-70`). This is the **purest** instance of the
  pattern in the whole program: a per-instance property read off a frozen (measure-zero) sample.

## A10. ★★ The box is not the algorithm's population — Rounds 45–47's supply numbers are all box numbers
- **Condition:** a supply rate (`C·N^{−1/6}`, the `N^{−1/4}` fit, the 191.5/336-bit crossovers).
- **Fraction failing:** *"**The box is not the algorithm's population.** Supply in the box (`m ~ N^(1/3)`,
  `c` in a **16-value hand-picked pool**) is exactly `C·N^(−1/6)`, but the box overstates a scanned
  instance's relation rate by **47× (24 bits) to 326× (32 bits)**, and its `χ_P = −1` fraction is
  **~79% against the scan's ~23%**. **Every supply number in Rounds 45–47 is a box number; none is a
  rate for the algorithm.**"* (`Round48_CostExponent.md:90-94`).
- **Verdict: CAUGHT, three rounds late**, and this is the single most damaging instance — it
  invalidates the *quantitative spine* of rounds 45–47, not one side experiment. The program states
  the general rule it earns from it at `Round48_CostExponent.md:174`: *"**Print what population
  produced the number, next to the number.** A rate is always a rate *of something*."*

## A11. ★ Vacuous instances and a verified null-relation family
- **Condition:** `m³ − c ≡ 0 (mod N)` with `c` reduced.
- **Fraction failing:** *"For `m < N^(1/3)`, `c = m³` unreduced and `m³ − c = 0` — a root over ℤ, not
  ℤ/Nℤ. One run produced **78,320 relations of which zero had `χ_P = −1`.**"*
  (`Round48_CostExponent.md:105-107`); and *"vacuous instances inflating totals **15×**"*
  (`Round48_CostExponent.md:181`). A separate null family: *"`u = −t`, `c = (2t/v)³ ⟹ l = 36t⁴ =
  (6t²)²`, constant in `m`, `χ_P = +1`, never a factor. 54 triples, 0 failures"*
  (`Round48_CostExponent.md:108-111`).
- **Verdict: CAUGHT** (round 48). Note `c ∈ {1,8,27,64,125,216}` — i.e. **the small-`c` "pool" is
  literally the degenerate corner** (consistent with `Round47_MechCandidate.md:15`: *"small `c` is a
  degenerate case … measured **29.1 at `c=1` against 4.6 at `c=201`**"*).

## A12. CM escape is dead on arithmetic — `j` integral in 0/275
- **Condition:** the Jacobian be CM, i.e. `j = −6912 m³c/(c−m³)²` a singular modulus (hence an
  **integer**).
- **Fraction failing:** *"**Over 275 sampled `(m,c)` across 12 moduli, `j` is an integer in 0 cases
  (0.0%), and a known singular modulus in 0 cases.**"* (`Round47_CMTest.md:33-34`).
- **Verdict: CAUGHT, and the sharpest available instance** — it is a *generic-value* argument given
  a *machine-checked* identity, so no sampling error can rescue it:
  *"a rational `j` that is not an integer cannot be a CM invariant, full stop"*
  (`Round47_CMTest.md:44-46`); *"The relation curves are **generically non-CM**, non-special curves"*
  (`Round47_CMTest.md:49-50`).

## A13. The `+1` branch is not escapable by the group law — 0/192
Covered in A3. Quoted separately because the **sample-size structure** is the point:
*"192 base points with `chi_P = +1`. The group law reached `chi_P = −1` at some `nP` in 0 of them"*
(`Round47_EscapeTest.md:18-19`), tabulated as *"`chi_P = −1` in 73% of `(m,c)` … Group law from a `+1`
base point, `n ≤ 14` | **0/192** — inert"* (`Round47_EscapeTest.md:56-57`).
- **Verdict: CAUGHT.**

## A14. `p = 2` / even `d` — a genuine exception locus in characteristic 2
- **Fraction failing:** for even `d` over `F_2`, the predicted degree/genus is wrong in **6/6 cases**
  (`p=2: d=3 deg=2 p_a=0 (pred 2,0) · d=4 deg=21 p_a=90 (pred 4,1) · d=5 deg=8 p_a=5 (pred 8,5) ·
  d=6 deg=221 p_a=1320 (pred 16,17)`) — `Round47_FunctionField.md:21-24`; *"**Two independent
  reasons to exclude `q = 2`.**"*
- Also **3/280 mismatches of the Hilbert-function computation, all at `d = 6`**
  (`Round47_FunctionField.md:13-14`) → *"**treat `d = 6` over `F_p` as unverified**"*.
- **Verdict: CAUGHT**, with the honest *"cause undetermined"* label.

## A15. ★★ E-6b — the class-number smoothness lottery at a 49-bit scale mismatch
- **Condition:** `|Cl(Q(√−d))|` is `B`-smooth, for random `d`.
- **Fraction failing / measurement:** *"`n=200` random imaginary quadratic fields (`|Δ|~10⁶`),
  `|h(Δ)|` via cypari2. **P(|Cl| B₁₀₀₀-smooth) = 1.000 vs EC-order baseline 0.925.**"*
  (`Experiments/E6B_RESULTS.md:3-4`; json `{"class_smooth": 1.0, "ec_smooth": 0.925, "n": 200}`).
- **The genericity defect, self-declared:** *"**PILOT CAVEAT: sizes not matched (h ≤ 1684 ≪ typical EC
  order); next pass scales |Δ| so median h matches EC group orders (~2⁶⁰), where the comparison
  becomes decisive.**"* (`E6B_RESULTS.md:7-9`).
- **Arithmetic sharpening (mine, reproducible).** With `h ≤ 1684` and `B = 1000`, an `h` can fail
  `B`-smoothness **only if it has a prime factor in (1000, 1684]**. Since `2·1000 > 1684`, that
  requires `h` *itself* to be an odd prime > 1000 — and by genus theory `h` is even whenever `d` is
  not a prime power. There are **95** primes in `(1000, 1684]`; the observed failure rate is **0/200**.
  So `1.000` is a size artefact, not a Cohen–Lenstra effect.
  On the EC side, `P` that a *single* random `2⁶⁰`-scale integer is `B = 1000`-smooth is
  `ρ(u)` at `u = log₂(2⁶⁰)/log₂(1000) = 6.0206`, i.e. **`ρ ≈ 2.0×10⁻⁵`** (computed by the Dickman
  recursion `ρ(u) = 1 − ∫₁^u ρ(t−1)/t dt`, converging to ρ(2)=0.30685, ρ(3)=0.048609, ρ(6)≈1.96×10⁻⁵,
  the standard values). **0.925 therefore cannot be "the probability that one EC curve's order is
  `B₁₀₀₀`-smooth"** — it must be a per-stage or multi-curve quantity, and the program never defines it.
- **Verdict: CAUGHT — and honoured.** E-6b was explicitly a pilot and the caveat is explicit.

## A16. ★★ E-6c — the same comparison at 29 bits, but with the EC baseline silently re-matched
- **Measurement:** `{"n": 25, "class_smooth": 0.72, "ec_smooth": 0.44}` (`e6c_results.json`).
  *"**Bounded pass at larger `|Δ|` (~10¹⁷-10¹⁸)** … **Full decisive comparison (h ~ 2⁶⁰, n=200)
  requires batch runtime beyond this pass — deferred with design unchanged.**"*
  (`Experiments/E6C_RESULTS.md:2-4`).
- **The bit-length:** the only place a class-number bit-length is ever recorded for this thread is
  `Experiments/E6D_IDEA_ECM.md:3`: *"|Cl(Q(√-Δ))| is B-smooth **~72% at 29 bits** vs EC 44% — the
  lottery odds favor class groups ~1.6×."* `FACTORING_PROGRAM_SUMMARY.md:25-26` repeats it:
  *"**E-6c**: at ~29-bit class numbers, 0.720 vs 0.440 — ~1.6x smoothness advantage over elliptic
  curves **at matched scale**."*
- **Verdict: CAUGHT and HONEST — but the honesty is in the scale, not the statistics.** `n = 25`
  gives **Fisher exact two-sided `p = 0.0845`** for 18/25 vs 11/25 (computed). At n = 25 the 95% CI
  on 0.72 is roughly ±0.18. *"Matched scale"* is asserted; it is not established by any recorded
  measurement (no median/mean order for the EC arm is ever recorded).

## A17. ★★ E-7 — see section (C) below. **NOT CAUGHT.**
- **Measurement:** `{"n": 25, "p_linked_smooth": 0.4, "ec_smooth": 0.32}` (`e7_results.json`);
  *"**Measured h(-q) smoothness for q random primes ≡ 3 mod 4 (the ideal-ECM discriminant family) vs
  matched EC baseline**"* (`E7_RESULTS.md:2-3`); promoted as *"**E-7**: the p-linked family (D=-q,
  q≡3 mod 4) also beats EC: 0.400 vs 0.320 → **milestone PASSED**"*
  (`FACTORING_PROGRAM_SUMMARY.md:28-29`).
- **Verdict: NOT CAUGHT.** Fisher exact two-sided `p = 0.769` — this is a coin flip. No `B`, no
  bit-length, no harness.

## A18. ★ Three earlier branch/agreement numbers that were themselves genericity artifacts
- **0.18%** (`branch-agreement-rate.md:25-26`: *"Restricted to `l` NOT a square in `Z[X]`: 9,460
  negative vs 5,179,918 positive - a fraction of 0.0018"*) — **RETRACTED as an artifact of an
  over-strong ansatz** (*"the earlier measurement enumerated forms with `l(alpha) = g^2` over the
  INTEGERS — a much stronger condition than the paper's"*; `branch-agreement-rate.md:44-48`), replaced
  by **83/166 = 50.0%** under the paper's actual condition (`branch-agreement-rate.md:58`).
- **Function-field branch obstruction: "0 failures"** — *"branch FREE at the linear component (both
  signs available): **108 (all of them)**"* (`function-field-has-no-branch-obstruction.md:16-21`) —
  **RETRACTED at `d = 4`**: *"branch FREE at the linear root: 136 / branch BLOCKED: 4 → **2.9%**"*
  (same file, Scope Correction, lines 40-54). *"'0/108 with no exceptions'" was the answer at `d=3`;
  it needed ≥3 components before it bit.*
- **Ring-level squareness 1/4 vs 25.4%** (`f-genericity-resolved.md:56-68`: 500/1968 = 25.4%,
  *"0.42 binomial sigma from the theoretical 1/4"*) — this one is **CAUGHT AND CONFIRMED**, and is
  the counterexample that keeps the verdict honest: here the generic prediction was *verified*, not
  assumed.
- **Verdict: 2 of 3 CAUGHT + RETRACTED; the third stands as a validated generic rate.**

---

## Cross-domain check (the discriminator for (B))

| domain | required condition | fails on a constant fraction? | caught? |
|---|---|---|---|
| NFS `f`-genericity | `f` irreducible mod p,q | **100%** (empty space) | yes, A1 |
| NFS branch | some relation with `chi_P = −1` | 27% at H=60; →97% at 37 bits | yes, A3 |
| NFS function field | branch consistency across components | 2.9% at d=4 (0% at d=3) | yes, A18 |
| GAP / divisor cover | target `i` hit with prob ≈ 1 | **516/1000**; `e^{−210}` | yes, A6 |
| NFS relation curve | non-empty curve of `Q`-points | ~half of `f` empty; 1/38 at d=4 | yes, A8 |
| NFS supply rate | a *representative* `f` | box overstates **47×–326×** | yes, **3 rounds late**, A10 |
| NFS Jacobian | CM | **275/275** | yes, A12 |
| ECM / class numbers (E-6b) | `h` B-smooth at matched scale | 0/200 at `h ≤ 1684`, unmatched by 49 bits | yes (caveated) |
| ECM / class numbers (E-7) | `h(-q)` B-smooth at matched scale | **unknown** — no `B`, no scale, no code | **NO** |
| univariate polynomial factoring | DDF linear system not saturated | `Θ(√n)` distinct degrees achievable | yes (structural) |

---

# (B) THE VERDICT

**Both, and the ratio is the finding.**

**Count CAUGHT: 16. Count NOT CAUGHT / left live: 2** — E-7 (A17) and, in its structural form, the
**box-vs-population** error (A10) which was carried for three rounds (45→48) as the quantitative
spine of the method and only then stated as *"**Every supply number in Rounds 45–47 is a box number;
none is a rate for the algorithm.**"* The two *live-route* errors that survived to the end are both
in the **smoothness-lottery thread** (`Experiments/`), the one domain the adversarial audits never
touched — the Catalog audits are dense on round 47 and **zero** on `Experiments/`.

**Evidence FOR a mathematical law (the structural reading).**
1. **Same shape, unrelated domains, same direction.** irreducibility forced to zero (A1, NFS),
   branch consistency 0/108 then 4/500 at d=4 (A18, function fields), hit probability < 1 for
   516/1000 GAP targets (A6, additive combinatorics), CM integrality 0/275 (A12, elliptic
   curves), class-number smoothness at 0/200 but unmatched scale (A15, quadratic forms). Five
   unrelated problem domains, one structure: *the required condition holds on a codimension or
   measure-zero locus, and the generic rate is a different number.*
2. **Where the program was careful, it measured the generic rate and it was worse, every time.**
   73% → per-`f` 0.03 at 37 bits (A3/A8); box 79% → scan 23% and 47–326× on rate (A10); `0/275` CM
   (A12); `e^{−210}` coverage (A6). The corrections never moved a rate *up*.
3. **The one place the program actually validated against genericity, the prediction held** —
   25.4% vs the theoretical 1/4 at n ≈ 6×10⁸ over 1968 polynomials (`f-genericity-resolved.md:62-68`).
   That is the control that makes the pattern a law rather than a wish: the *method* of measuring
   genericity works, and it works.

**Evidence FOR a methodological error (the competing reading).**
1. **The same class of claim is sometimes caught and sometimes not, in the same rounds.**
   `chi_P = −1` rate: measured and re-measured five times with the sample size printed every time
   (A3). Box-vs-scan: never printed, for three rounds (A10). E-6b: caveat printed (A15). E-7:
   `n = 25`, no `B`, no scale, no code (A17). **The discriminator is whether the population was
   named in the output, not whether the mathematics is hard.**
2. **The program's own closing diagnosis is methodological, twice.** *"Before believing a negative,
   check that the thing you varied actually varied."* (`Round47_AuditOfMethod.md:71-73` — and this is
   literally the A9 error). *"**Print what population produced the number, next to the number.** A
   rate is always a rate *of something*."* (`Round48_CostExponent.md:174-175`, earned from A10).
3. **The errors are defects of *instrumentation*, not of structure**: a frozen `m` restart (A9), a
   `grep -c` counting a header row, a `0/0 instances agree. PASS` control, `sum(TRIALS)/sum(chi)` on
   quantised chunks (`Round48_CostExponent.md:159-161`). These would each vanish with one print
   statement; a codimension argument would not.
4. **Asymmetry of audit coverage.** The Catalog audits were extremely thorough on round 47 (nine
   defective controls enumerated in `Round47_EighthDefect.md:68-77`; nine more in
   `Round47_SelectorDerived.md:126-130`) and **did not touch `Experiments/` at all** — `grep` for
   `E-6|E-7|class-group lottery|Cohen-Lenstra` over `Catalog/`, `factor-scratch/`, and `.claude/`
   returns **zero hits**. The surviving errors are exactly the ones outside the audited region.

**Best single sentence.**
> The genericity conditions themselves are a real structural law — irreducibility, branch
> consistency, hit-probability-1 and B-smoothness are each satisfied only on a codimension or
> measure-zero locus, verified independently in five unrelated domains — but *this program's
> residual errors are methodological, and the split is exactly the split in audit coverage: 16 of 18
> instances were caught because somebody printed the population the number came from, and the two
> that survived (the box supply rates, and E-7) survived only because nobody ever printed it.*

---

# (C) THE ADVERSARIAL POINT ON E-7

**What E-7 was designed to be.** `Experiments/E6D_IDEA_ECM.md:24-28`:

> "## Testable milestone (E-7, next)
> For **200 random primes `p ~ 2²⁰`** and random `q ≡ 3 mod 4`: compute `h(D_p)` where
> `D = -q·p⁰-form discriminant proxy`; measure `P(smooth)` vs **matched EC baseline**.
> If ≥ EC rate: implement form-composition walk mod `N` and attempt first class-group factoring demo."

### (i) What was `B`?
**Never recorded.** `e7_results.json` is the entire result: `{"n": 25, "p_linked_smooth": 0.4,
"ec_smooth": 0.32}` — three keys, no `B`, no `B_ec`, no `h`, no `|Δ|`, no scale. The **only** `B`
anywhere in this thread is E-6b's `B₁₀₀₀` (`E6B_RESULTS.md:4`). Nothing establishes that E-7 used
`B = 1000`, nor that E-6b, E-6c and E-7 used the *same* `B` — yet the three are chained into one
claim across `FACTORING_PROGRAM_SUMMARY.md:24-29`. Without `B`, "0.400 vs 0.320" is not
interpretable, and the three-way chain has no common parameter.

### (ii) What was the bit-length of `h(-q)` in E-7?
**Never recorded.** The only class-number bit-lengths in the entire thread are **E-6c's 29 bits**
(`E6D_IDEA_ECM.md:3`; `FACTORING_PROGRAM_SUMMARY.md:25`). E-7 states none, and E-7's report sentence
names only the size of `q`, not of `h`: *"Measured `h(-q)` smoothness for `q` random primes ≡ 3 mod 4"*
(`E7_RESULTS.md:2`). This is directly load-bearing: **the class-number rates across the thread move
1.000 (E-6b) → 0.720 (E-6c) → 0.400 (E-7) as the objects get larger**, which is the expected
direction and is exactly the trend a smoothness lottery must show. Reporting the 0.400 as
"the p-linked family *also beats* EC" without the bit-length hides that E-7 is the **smallest
advantage and the lowest absolute rate in the series** — a decline, presented as a confirmation.

### (iii) What bit-length were the EC baseline orders?
**Never recorded, and the one recorded figure is incompatible with the rest.** The thread's only
statement about EC order size is E-6b's *"typical EC order … (~2⁶⁰)"* (`E6B_RESULTS.md:8-9`), against
which E-6b's class numbers were `h ≤ 1684` — a **49-bit mismatch between the two arms.** E-6c and
E-7 record no EC order size at all. Worse, the EC baseline takes **three mutually inconsistent
values with no stated definition**: **0.925** at `n = 200` (E-6b), **0.440** at `n = 25` (E-6c),
**0.320** at `n = 25` (E-7). The program never states what `ec_smooth` *is* — the probability that one
curve's order is `B`-smooth? A rate over `B₁` curves? A per-stage rate? As computed above, if it is
the first, then at `|Δ| ~ 10⁶` (`h` ~ 11 bits, `u = log₂(1684)/log₂(1000) = 1.08`, ρ(1.08) ≈ 0.93)
**0.925 is exactly the Dickman value for an 11-bit object at B = 1000** — i.e. E-6b's "EC baseline"
appears to be a *~2⁶⁰-scale* number compared against an *11-bit* arm, which is precisely the
caveat the file itself prints. No single (B, size, definition) makes 0.925, 0.440 and 0.320 the same
quantity.

### (iv) Was "matched" ever established?
**No.** The word appears three times, always as an assertion, never as a measurement:
- `E7_RESULTS.md:3` — *"vs **matched EC baseline**"*
- `E6D_IDEA_ECM.md:26` — *"measure `P(smooth)` vs **matched EC baseline**"* (this is the *design*
  statement, written before the run)
- `FACTORING_PROGRAM_SUMMARY.md:26` — *"~1.6x smoothness advantage over elliptic curves **at matched
  scale**"* (this is E-**6c**, not E-7)

There is **no recorded median, mean, or range** for either arm in E-6c or E-7. The only scale number
in the thread is 29 bits, for the class-number arm only. "Matched" is a word in a sentence, never a
measurement. **And note the asymmetry: E-6b's file prints the caveat `"PILOT CAVEAT: sizes not
matched"` in the same breath as the claim; E-6c's and E-7's files drop the caveat and keep the word
"matched".** The honesty was present once, in the first pilot, and was not carried forward.

### The additional structural defects in E-7

**(α) E-7 does not measure what it is named for.** The design requires `h(D_p)` with
`D = -q·p⁰-form discriminant proxy` — a **`p`-linked** discriminant (`E6D_IDEA_ECM.md:25-26`), and
`E6D_IDEA_ECM.md:17` states the reason plainly: *"the mod-p quotient perturbs by `(p − (D/p))` factors
— **needs E-7 verification**."* The executed report measures **plain `h(-q)`** — *"Measured `h(-q)`
smoothness for `q` random primes ≡ 3 mod 4"* (`E7_RESULTS.md:2`) — with **`p` absent from the
experiment entirely.** The json key `p_linked_smooth` is therefore a **mislabelled column**: the
quantity measured is not the p-linked one the milestone was designed to verify, and the specific
perturbation the milestone existed to check was never checked.

**(β) The run size dropped 8× from its own design.** Designed at `n = 200` (`E6D_IDEA_ECM.md:25`),
executed at **`n = 25`** (`e7_results.json`) — the same `n = 25` as E-6c. Fisher exact two-sided
**p = 0.769** for 10/25 vs 8/25: this is a coin flip, and it is being reported as
*"→ milestone PASSED"* (`FACTORING_PROGRAM_SUMMARY.md:29`). For comparison, E-6c's 18/25 vs 11/25
gives p = 0.085 and E-6b's 200/200 vs 185/200 gives p = 4.6×10⁻⁵ — **E-7 is the least significant
result in the series and is the only one stated as a pass.**

**(γ) No harness exists.** `git log --all --diff-filter=A` shows E-6b (`5bdf85b35`), E-6c
(`f74b21f42`) and E-7 (`b6c7386dd`) each committed **only** a `.md` and a `.json` — **no `.py`
file, ever** — while `FACTORING_PROGRAM_SUMMARY.md:4` claims: *"All experiments reproducible,
committed, pushed."* The identical defect the program already names nine times in round 47
("a control that reports success over zero instances is worse than no control, because it is
**green**", `Round47_Final.md:62-64`) applies here at the level of the whole experiment: **a result
with no code cannot be checked by anyone, ever.**

**(δ) The thread was never audited or killed.** `grep` for `E-6|E-7|class-group lottery|Cohen-Lenstra`
over `Catalog/`, `factor-scratch/` and `.claude/projects/.../memory/` returns **zero hits**. The E-8
prototype that depended on it (*"NEXT CYCLE: sample `q ~ N`-scale primes"*, `E8_DEMO.md:18`) stalled
and was never restarted (`E8_DEMO.md:7`: *"STATUS: design locked; implementation deferred one cycle"*).
So the frontier now carries one live lead — *"a live, evidence-backed lead on class-group lotteries
that could yield an ECM-independent `L[1/2]` method"* (`FACTORING_PROGRAM_SUMMARY.md:39-41`) — whose
supporting measurement has **no code, no `B`, no scale, and p = 0.77**.

### Verdict on E-7
E-7 is a **3-line file reporting one coin-flip number (p = 0.77, n = 25) with no stated smoothness
bound, no class-number bit-length, no EC order size, and no executable code — for a quantity
(`p_linked`) that the report does not actually measure.** The phrase *"vs matched EC baseline"*
(`E7_RESULTS.md:3`) is unsupported in E-7; the only place in the thread where matching was ever
*checked* is E-6b, where it was **explicitly failed** (`"PILOT CAVEAT: sizes not matched (h ≤ 1684 ≪
typical EC order)"`, `E6B_RESULTS.md:8-9`) and never repaired — E-6c and E-7 quietly dropped the
caveat and kept the word.

---

## Quick cross-reference: the one place the program DID get the genericity right

The counterexample that keeps (B) honest — `f-genericity-resolved.md:56-68`, at `n = 603901889 =
12119 × 49831`:

> "f with `f mod p,q = (X-m)*Q`, Q irreducible quadratic : **1968**
> l(alpha) a square in BOTH Q-components : **500**
> rate : **25.4%**
> **The observed 25.4% is 0.42 binomial sigma from the theoretical 1/4** … `n ~ 6e8`, the ring-level
> obstruction behaves exactly as independent squareness predicts, with **no `f` showing systematic
> alignment**."

Here the program wrote the generic prediction down first, measured at scale, and got agreement to
0.4σ — **and then stated exactly what it does not establish**: *"This is the *ring* condition only …
It is not the full non-triviality of the congruence of squares"* (`f-genericity-resolved.md:76-80`).
**That is the standard E-7 failed to meet.**