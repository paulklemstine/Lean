# Round 112 — adversarial verification of GIFP r110/r111 claims

Verifier: independent harness, written from `gifp_ref/gifp.sage` only. **No prior
harness file was imported.** Sage 10.7 (`/tmp/mamba`) and Sage 10.9 (`~/sage_mamba`).

## Verdict summary

| Claim | Verdict |
|---|---|
| 1. γ=0.70, α=0.1 recovers p2,q2, 20/20 | **CONFIRMED** (40/40 over 2 seed blocks, both Sage versions) |
| 2. Below threshold 0/10 at γ=0.20, 0.30 | **CONFIRMED** (0/40 over 4 sweeps, 2 Sage versions) |
| 3. Bound's SHAPE is wrong (ratio drifts with α) | **PARTIALLY REFUTED** — ratio drift is real but small (~1.4 vs ~1.6); the α≥0.15 row is an *instance-infeasibility* artifact, not a shape failure |
| 4. α≥0.15 wall is genuine, not a rounding artifact | **CONFIRMED in the tested regime** (0/32 at m=4; t=ceil rescues nothing) — but it is a wall of the *implementation at n=200*, not shown to be a mathematical ceiling |
| 5. m-resonance is caused by t=round undershoot | **CONFIRMED but INCOMPLETE** — flips reproduce; but `t=ceil` **also breaks working m** (m=4, m=7), contradicting "never makes anything worse" |

Plus one claim they did not make, which is the headline caveat:

> **At n=200 every tested instance is trivially factorable.** `N2 = p2·q2` with
> `|q2| = α·n = 20` bits at α=0.1. `factor(N2)` returns the true p2,q2 in **0.006 s**
> with zero GIFP knowledge. So "recovers p2,q2" at n=200 is **not by itself evidence
> the attack works** — the instance is not a hard RSA modulus.

This is NOT a refutation of the mechanism: at **n=800** (|q2| = 80 bits, N2 genuinely
hard — PARI `factor(N2)` ran >4 min without success) the attack still recovered p2
**3/3**. The mechanism is real; only the n=200 *framing* is misleading.

## Claim 1 — CONFIRMED

α=0.10, γ=0.70, β₁=0.1, β₂=0.15, m=4, n=200.
- Run 1 (seeds 5000000+15485863k): **20/20**
- Run 2, fresh seed block (11000000+15485863k): **20/20**
- Sage 10.9, both seed blocks: **20/20**
- Authors' own seed 1791165034802635: recovers p2 = 1049051663491949916718543835817164082636546493960542391, q2 = 792731 — exact match to ground truth.

Mechanism confirmed as documented: at this point 8 of 9 reconstructed polynomials
evaluate to exactly 0 over ℤ at the true root; the GB reaches length 4 = ngens; the
factor appears at `gcd(G[1],G[2])` in a factor with vars {y,w}, whose y-coefficient
is exactly p2. This is the README's extraction. Note the authors' script itself
returns 0 here (`find_roots_groebner` reads only univariate GB elements) — r110's
diagnosis of that is correct.

## Claim 2 — CONFIRMED

γ=0.20 and γ=0.30 (threshold 0.27351), 10 seeds each:
- Run 1: 0/10, 0/10 · Run 2: 0/10, 0/10 · Sage 10.9: 0/10, 0/10. **0/40 total, 0 successes.**
Below threshold the GB never reaches length ngens (status `no_gb`) in 27/40 cases, and
when it does reach length 4 the factor is not present.

## Claim 3 — PARTIALLY REFUTED

Ratio γ/[4α(1−√α)], n=200, m=4, 8 seeds/point, run twice (run1/run2):

| α | thr | 1.0× | 1.2× | 1.4× | 1.6× | 1.8× | 2.0× |
|---|---|---|---|---|---|---|---|
| 0.05 | 0.15528 | 0/8, 0/8 | 0/8, 0/8 | **2/8, 3/8** | 8/8, 8/8 | 7/8, 8/8 | 8/8, 8/8 |
| 0.10 | 0.27351 | 0/8, 0/8 | 0/8, 0/8 | 0/8, 0/8 | **3/8, 5/8** | 8/8, 7/8 | skip_gen |
| 0.15 | 0.36762 | 0/8, 0/8 | 0/8, 0/8 | 0/8, 0/8 | 0/8, 0/8 | 0/8, 0/8 | infeasible |
| 0.20 | 0.44223 | 0/8, 0/8 | 0/8, 0/8 | 0/8, 0/8 | infeasible | infeasible | infeasible |

**Confirmed:** the transition ratio does drift upward with α (0.05 → ~1.4–1.6×;
0.10 → ~1.6–1.8×), and it never occurs at α≥0.15. The bound is not merely
constant-slack-loose. This part of r111 holds.

**Refuted / overclaimed:** r111 presents "α = 0.15 and 0.20 rows all 0/8" as part of
the same *shape* table. It is not the same phenomenon. The feasibility constraint is
α+γ+β₂ < 1, so at α=0.20 the largest feasible ratio is only 1.4×, and at α=0.15 it is
1.8×. r111's own table marks these "infeasible" — so the α=0.20 row **never tested the
α≥0.20 regime above its own threshold**. A shape claim needs ratios above threshold at
every α; at α=0.20 those do not exist at n=200 with β₂=0.15. The α=0.20 "0/8" entries
are mostly measuring the generator crashing, not the attack failing. To test shape at
α=0.20 you must shrink β₁,β₂ or raise n.

Also note run-to-run drift at the boundary points (1.6× at α=0.10: 3/8 then 5/8;
1.8× at α=0.10: 8/8 then 7/8; 1.4× at α=0.05: 2/8 then 3/8). Counts at the transition
are not reproducible at 8 seeds/point — consistent with the brief's `unseeded-counts-are-uncitable`.

## Claim 4 — CONFIRMED IN THE TESTED REGIME (scope caveat)

α≥0.15, n=200, m=4, 8 seeds, γ from 0.50 to 0.68: **0/32** (`no_gb` at every point).
Confirmed that the failure is not the pop-loop and not a missed index: see the deep
scan below. Confirmed `t=ceil` rescues nothing at α=0.15 (0/4 at m=3…8).

**Caveat:** "genuine wall of this construction" is stronger than the data. What is
shown is that *this lattice at n=200 with these β* fails. Since the whole α≥0.15
region at n=200 sits in a badly-conditioned corner of the bit budget, the data does
not distinguish "the construction has a ceiling" from "the parameters are infeasible
here". A shape claim at α≥0.15 needs a feasible (α,γ,β) family, which n=200 does not
provide.

## Claim 5 — CONFIRMED BUT INCOMPLETE (and one sub-claim REFUTED)

α=0.10, γ=0.50, 4 seeds, t=round vs t=ceil:

| m | ideal t | round | ceil |
|---|---|---|---|
| 3 | 2.0513 | 0/4 | **4/4** |
| 4 | 2.7351 | **4/4** | **0/4** ← regression |
| 5 | 3.4189 | 0/4 | 0/4 |
| 6 | 4.1026 | 0/4 | **4/4** |
| 7 | 4.7864 | **4/4** | **0/4** ← regression |
| 8 | 5.4702 | 0/4 | **4/4** |

**Confirmed:** the m=3, 6, 8 flips (0/4 → 4/4) reproduce exactly. The undershoot is
causal, not correlational.

**REFUTED sub-claim:** r111 states "`t=ceil` never makes anything worse" and concludes
"do not tune m by trial and error — compute `t = ⌈(1−√α)m⌉` directly." Both are false.
`t=ceil` **breaks** m=4 (4/4 → 0/4) and m=7 (4/4 → 0/4). The correct statement is that
m and t are *coupled* — the working pairs are (m=4,t=3), (m=7,t=5), (m=3,t=3),
(m=6,t=5), (m=8,t=6) — and neither "always round" nor "always ceil" gets them all.
The mechanism is not a one-sided rounding bug; the ideal balance is two-sided. Any
recommendation to replace `round` with `ceil` unconditionally will break currently
working configurations, and would change the meaning of every published m-sweep.

The r111 observation that m=5 fails at both t=3 and t=4 is also confirmed (0/4, 0/4).

## Harness-integrity checks (the requested leak investigation)

**1. Is p2 trivially recoverable from N2 at these sizes? YES at n=200.**
`|q2| = α·n`. Sage `factor(N2)`, no GIFP knowledge, n=200:

| α | 0.05 | 0.10 | 0.15 | 0.20 | 0.25 |
|---|---|---|---|---|---|
| \|q2\| bits | 10 | 20 | 30 | 40 | 50 |
| factor(N2) time | 0.095 s | 0.006 s | 0.039 s | 0.51 s | 6.74 s |

All exact (p2,q2 recovered). **Every n=200 instance in both r110 and r111 is
trivially factorable.** "The attack recovers p2 and q2" is therefore a statement with
no discriminating content *at n=200* — the threshold, the α-wall and the m-resonance
are all measured in a regime where a 0.006-second routine already wins.

This is the single most important finding, and it is a framing error rather than a
math error. It does not refute the mechanism, per check 5.

**2. Degenerate path (a = N2 or a = 1)? NO.** Across all verified successes the
recovered divisor is never 1 or N2, always has ~|p2| bits, always divides N2 exactly,
and always equals the true p2 or q2 bit-for-bit. My scan enumerates **every**
coefficient of **every** monomial of **every** irreducible factor of **every** pairwise
gcd (not just the [0,1,0,0] monomial the original harness reads), so a smaller or
degenerate factor could not have been silently substituted.

**3. Negative control A — unrelated factors must fail. PASSES.** Build the lattice
from instance A, then ask for a divisor of an unrelated instance B's N2:
6/6 recover p2 of the true instance, **0/6** recover anything for the unrelated one.
The pipeline does not leak the answer and is not reading ground truth.

**4. Negative control B — random polynomials must fail. PASSES.** Replacing the
lattice output with random small polynomials: **0/10** recover p2, and 7/10 still reach
GB length 4. A harness that never fires is not what we have.

**5. Does the attack work when the instance is actually hard? YES.** n=800, α=0.10,
γ=0.70, m=4 → **3/3** recovered p2 (build 23–36 s each), while PARI `factor(N2)` on the
same instance ran **>4 minutes without success** (n=600 factorises in 3.9 s, n=800 does
not). The GIFP lattice genuinely beats generic factoring at n=800. This is the
strongest positive evidence for the campaign in this whole area.

**6. Is `no_gb` a math failure or a harness artifact? GENUINE FAILURE.** For every
below-threshold failure I ran a deep scan that (a) tries every prefix of the
polynomial list instead of only the pop-loop's choice, (b) computes a Gröbner basis
for each, (c) forms **all** pairwise gcds (not just G[1],G[2]), and (d) factors each
gcd and tests **every** monomial coefficient. Rescues: **0/4** at γ=0.30. So the
pop-loop and the single-index lookup are not hiding a recovery.

## Numbers that should be corrected in r111 regardless

1. The "α×ratio" table mixes a shape measurement (α=0.05, 0.10) with a feasibility
   boundary (α=0.15, 0.20). Split them or mark the α≥0.20 rows infeasible.
2. "`t=ceil` never makes anything worse" is false (m=4, m=7 regress).
3. "Do not tune m by trial and error — compute t=⌈(1−√α)m⌉" is unsafe advice; see above.
4. Every n=200 number should carry the caveat that N2 is trivially factorable there.
   The r111 m-scan's 47.5 s/point at m=10 is also slower than `factor(N2)` at 0.006 s
   — the honest comparison is against trivial factoring, which nobody reported.
5. Transition-point counts (3/8 vs 5/8 on identical seeds) need more seeds before they
   support a claim about where the transition sits.

## Files

- `vcore.sage` — independent pipeline + exhaustive factor scan (`scan_gb`, `deep_scan`)
- `run_sweep.sage` / `drv.sage` — claim sweeps (c12, shape, alpha, mround)
- `negctl2.sage`, `negB.sage` — negative controls A and B
- `nogb.sage` — deep scan proving `no_gb` is genuine
- `bigN.sage` — attack at n=400/600/800 where N2 is hard
- `hardN2.sage` — PARI `factor(N2)` difficulty at the same sizes
- `leak2.sage` — trivial-factorability table
- `mround_fast.sage` — the t=round vs t=ceil causal table

Reproduce: `sage drv.sage <c12|shape|alpha|mround> out.log`