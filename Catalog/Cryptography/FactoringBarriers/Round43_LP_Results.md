# ROUND 43 — SURFACE (a): LARGE-PRIME / PARTIAL-RELATION VARIANTS

**Verdict: the channel is CLOSED as a decoupling, and it is a validated negative
on the paid quantity. The premise of the surface is false: the large-prime
columns are split primes, so LP-QS does not decouple the column count from the
split set — it consumes the next tier of it.**

Round 43, 2026-09-25. Scratch: `/home/raver1975/factor-scratch/r43lp/`
(`lpcore.py`, `validate_lp.py`, `exp_lp.py`, `analyze_lp.py`, `addendum.py`,
`per_instance.py`, `val.log`, `an.log`, `add.log`, `lp_rows.json`,
`per_instance.txt`, `bt.txt` = Boender–te Riele full text, `yafu_*.c` = YAFU
sources). Sources opened: `boender_teRiele.pdf`, `yafu_tdiv.c`,
`yafu_large_sieve.c`, `Readme.qs`, `hac_chap3.pdf`, `wiki_qs.txt`.

---

## 0. INSTRUMENT VALIDATION — 14/14 PASS, reported before any number

`validate_lp.py`. T0 re-runs round 42's own 11-test GF(2) suite unchanged.

| test | what it rules out | result |
|---|---|---|
| T0 | the inherited GF(2) engine is unmodified | r42 suite PASS |
| T1 | factor base = `{primes ≤ B : (N/r)=+1}` | 0 bad |
| **T2** | **a non-split large prime can be a column** | **1071 LP columns, 0 non-split** |
| **T2b** | **any prime divisor of `f(x)` is non-split** | **5497 prime divisors of `f(x)`, 0 non-split** |
| T2c | **MUTATION: a non-split injected LP column is rejected** | caught (`r=719`, legendre1 False) |
| T9 | the split test is not vacuous | 149 off / 140 on primes exist in the LP band |
| T3 | the partial-relation identity | 164 pairs: `A² = C·r`, `(A₁A₂)² = C₁C₂r²` |
| T4 | residual identity vs `sympy.factorint` | 0 violations over 599 x |
| T5 | the per-relation identity `A² = ∏p^e (mod N)` | 281 relations, 0 violations |
| T6 | every reported factor is ground-truth `p` or `q` | ALL VERIFIED (845 successes) |
| **T7** | **the LP collector ≠ r42's collector** | **0/3 mismatches, digit for digit, `L=None`** |
| T8a/b | **MUTATION: two broken routines must be caught** | **both caught** |
| T10 | **REGRESSION for the `id()`-recycling cache bug** | 16 records, 0 defects |

**T7 is the tie to the record:** with `L=None` the LP collector returns round
42's full relations, in the same order, with the same exponents, the same `A`s
and the same `x`s. The LP arm is a strict superset of the round-42 arm.

### Two real instrument bugs, both caught by tests with power

1. **`id()`-recycling cache.** The column→prime map was cached in a
   module-level dict keyed on `id(rec)`. CPython recycles ids, so a freed
   record's id could be handed to a *different* record and the cache then
   returned the wrong large primes for the columns. Found by running the
   experiment (`IndexError`), fixed by building the map locally, regression-
   tested as T10. A sibling round directory also shadowed `lpcore` (same module
   name, older version) — the collector ran for ~20 minutes against the wrong
   file; `validate_lp.py` now carries a hard origin assertion.
2. **The square side.** A partial relation is `A² ≡ C·r` where `C` is the
   factor-base part and is **not** squared. A pair therefore gives
   `(A₁A₂)² ≡ C₁C₂r²`, and `r²` is a perfect square that belongs on the **V**
   side. `run()` was computing `gcd(A−c, N)` with `c` missing the `r` factor.
   Caught by T3. `run()` now asserts `A² ≡ c² (mod N)` on every dependence, so
   this error class cannot pass silently again.

Two **test** bugs of mine, recorded because they are the same failure mode as
rounds 41/42: T5 originally asserted "all exponents even" *per relation* — that
is a property of a *dependence*, not a relation — and failed 1375 times; and the
first `Q/π(B)` computation used the already-filtered factor-base list, making
`Q/m` identically 1.000 and destroying the arm split silently.

---

## 1. THE MECHANISM, OPENED AND QUOTED

### 1a. The primary source — the paper that defines the method

**H. Boender and H. J. J. te Riele, "Factoring Integers with Large-Prime
Variations of the Quadratic Sieve", *Experimental Mathematics* 5(4):257–273
(1996).** Opened in full: <https://ir.cwi.nl/pub/1367/1367D.pdf>
(local: `r43lp/boender_teRiele.pdf`, text `bt.txt`).

§5, *The Large-Prime Variation of MPQS* — the mechanism and its regime, verbatim:

> "W(x) is allowed to have a factor R > B₁ that is not composed of primes from
> the factor base. If the cofactor R (after dividing out all factor base primes
> in W(x)) is less than or equal to B₂, it must be a prime. In order to restrict
> the amount of disk space needed for storage of the relations (3.1), we only
> accept factors R ≤ B₂, where B₂ is a parameter we choose beforehand. **In
> practice we choose B₂ in such a way that B₂/B₁ is a number between 10 and
> 100.** We have to lower the report threshold by log(B₂) in order to find these
> W(x)-values after sieving."

> "A relation of the form (3.1), where W(x) only consists of primes q ∈ ℱ, is
> called a **complete relation**. If W(x) has one prime factor R ≤ B₂ (and the
> others are in ℱ), then the relation is called a **partial relation**."

> "**Q = {primes q : B₁ < q ≤ B₂, (n/q) = 1}.** The elements of Q are called
> **large primes**."

> "If we have found two W(x)-values with the same R, multiplication of the
> corresponding relations (3.1) yields a relation of the form (3.1), where
> W(x) only consists of prime powers q ∈ ℱ (**and R is moved to V(x)**)."

The last clause is the whole structural story: **the large prime never enters
the linear algebra.** Its square goes to the V side.

§7, the two-large-prime acceptance, verbatim:

> "The large prime R occurring in the partial relations was accepted if
> B₁ < R < B₂ and rejected if B₂ ≤ R < B³."

And the split-set statement the whole channel turns on, §3, verbatim:

> "if a prime p divides W(x), then p | a²W(x) and thus p | (a²x+b)² − n, which
> means that **n is a quadratic residue modulo p**. … However, **only roughly
> half of the primes below B₁ can occur as a prime divisor of W(x)**."

The paper's own **paid quantity** is the sieve time `T_B`, and it is measured as
a function of `B₂/B₁` for an 80-digit number with `B₁ = 10⁵`, `M = 3·10⁶`,
`Q_T = 50` (Table 4, verbatim):

| `B₂/B₁` | **T_B (paid)** | n_c | n₁ | n_{c,1} | n₂ | n_{c,2} | total |
|---|---|---|---|---|---|---|---|
| 30 | 8.64 h | 1036 | 129318 | 1661 | 29143 | 2121 | 4818 |
| 100 | 6.49 h | 775 | 109506 | 1025 | 76324 | 3070 | 4870 |
| 400 | **5.67 h** | 618 | 91332 | 634 | 193278 | 3598 | 4850 |
| 1000 | 5.75 h | 546 | 83082 | 501 | 333726 | 3796 | 4843 |
| 1600 | 6.19 h | 521 | 79960 | 464 | 445526 | 3860 | 4845 |

> "For 30 ≲ B₂/B₁ ≲ 400, the gain in complete relations (n_{c,2}) generated by
> the pp-relations (n₂) more than sufficiently compensates for the loss … As a
> result, **the total sieve time T_B goes down**. For B₂/B₁ > 1000, however, …
> the total sieve time increases. … **the optimal choice of B₂/B₁ is about
> 400**."  And: "the Gaussian elimination step (including finding basic
> cycles) accounts for **less than 0.6% of the total work**."

So the paper *does* report a real, large, measured reduction in its own paid
quantity — at 80 digits, with the optimum at an **interior** `c`, and with a
2-LP not 1-LP variant.

### 1b. The implementation

**YAFU** (B. Buhrow, public domain), `factor/qs/tdiv.c`, `trial_divide_Q_siqs` —
opened verbatim (`r43lp/yafu_tdiv.c`). The one-large-prime acceptance:

```c
	// check if it completely factored by looking at the unfactored portion in tmp
	if ((mpz_size(dconf->Qvals[report_num]) == 1) &&
		(mpz_cmp_ui(dconf->Qvals[report_num], sconf->large_prime_max) < 0))
	{
        // save this slp (single large prime)
        ...
		if (large_prime[0] == 1)  dconf->num_full++;
		else                      dconf->num_slp++;
```

and the double-large-prime test `if ((q64 > sconf->max_fb2) && (q64 < sconf->large_prime_max2))`.
**msieve**'s `Readme.qs` (opened) describes the same code base as "the
self-initializing multiple polynomial quadratic sieve (MPQS) with **double
large primes**". (msieve's `mpqs_lp.c` no longer exists — its QS module is now
GNFS-only, so YAFU is the live source for the mechanism.)

**Cost structure, read off the code:** the sieve is run over the factor base
only. The large primes are *not* sieved; they are found by trial division (or
ECM — YAFU uses `getfactor_uecm`) on the residual of a reported candidate.
That is why the paper lowers the report threshold by `log B₂` and why the LP arm
pays `π(B₂)−π(B)` divisions per candidate.

---

## 2. DOES IT DECOULE THE COLUMN COUNT FROM THE SPLIT SET? **NO.**

### 2a. Analytically — a theorem, not a heuristic

For the single polynomial `f(x) = (b+x)² − N`: **every** prime `r | f(x)`,
whether or not `r | N`, satisfies `(N/r) = +1`, because
`r | (b+x)² − N ⟹ (b+x)² ≡ N (mod r) ⟹ N` is a square mod `r`.

> **The surface's premise — "the extra columns are large primes r, which need
> NOT satisfy (N/r) = +1" — is false.** The large-prime column set is a
> **subset of the split set**.

Measured, not assumed: **1071** LP columns in the validation suite and every LP
column in the 68-instance experiment are split; **0** non-split, out of a band
where 149 non-split primes are available (T9).

### 2b. By the paper's own definition

`Q := {primes q : B₁ < q ≤ B₂, (n/q) = 1}`. The method's authors *define* the
large primes to be split primes.

### 2c. By the standard mechanism — the column space is literally untouched

Pairing/cycles never put the large prime into the linear algebra ("R is moved to
V(x)"). Measured on 68 instances:

| c = B₂/B | factor base `m` | **lppair columns** | `Q(N,B)+1` ceiling |
|---|---|---|---|
| 2, 4, 8, 16, 32, 64 | 63.8 | **63.8 (identical at every c)** | 64.8 — **0/68 violations** |

The pairing arm's column count equals `m` *exactly*, for every `c`
(`lppair columns == m exactly: True`). Round 42's ceiling
`rank_{F₂}(M) ≤ Q(N,B)+1` is untouched by the large-prime variation.

### 2d. The one arm that *does* grow the column count grows it INSIDE the split set

| c | `Q(N,B)` | `Q(N,B₂)` | lpcol columns | ÷ `Q(N,B₂)` | kept LP cols as a fraction of the split primes available in (B,B₂] | ceiling `Q(N,B₂)+1` |
|---|---|---|---|---|---|---|
| 2 | 63.8 | 114.1 | 111.5 | 0.975 | **0.948** | 0/68 viol. |
| 4 | 63.8 | 208.6 | 192.7 | 0.922 | **0.890** | 0/68 viol. |
| 8 | 63.8 | 378.1 | 311.8 | 0.822 | 0.789 | 0/68 viol. |
| 16 | 63.8 | 693.1 | 460.8 | 0.663 | 0.631 | 0/68 viol. |
| 32 | 63.8 | 1280.2 | 612.1 | 0.477 | 0.451 | 0/68 viol. |
| 64 | 63.8 | 2370.9 | 724.5 | 0.305 | 0.286 | 0/68 viol. |

The LP columns exhaust 95% → 29% of the split primes newly available in the
band `(B, B₂]`, and the column count never exceeds `Q(N,B₂)+1`. **The LP arm
does not escape the split set; it consumes the next tier of it** — which is
precisely what raising `B` also does. The decoupling is between the column
count and the **sieve bound**, not between the column count and the **split
set**.

---

## 3. THE PAID QUANTITY, AND WHAT IT DOES

`x_success` = sieve positions examined to reach the first dependence whose gcd
splits `N` (identical definition to round 42; model-free).
`OP` = operation-count **model**, stated as a model:
`OP_NOLP = π(B)x + n_rep(x)`, `OP_LP = π(B)x + n_rep(x) + (π(B₂)−π(B))·n_rep(x)`,
where `n_rep(x)` is the candidate count from a **real log-sieve** with the
standard threshold `log(max FB prime)` — added because the naive divide-by-everything
collector reports ~99% of positions and would have made the LP cost
unrepresentative. The model is deliberately **conservative against LP**: it
charges a full trial division to `B₂` on every candidate, where real
implementations use ECM.

68 instances, 42-bit balanced semiprimes, seeds 930000+ (disjoint from round 42's
900000+), arms split on **measured** `Q/π(B)`: LOW 0.4370, HIGH 0.5683, pool
range 0.4016–0.6142 (round 42's pool spanned 0.378–0.646). All 845 successes
verified against ground-truth `p, q`.

### 3a. The no-LP arm reproduces round 42 on fresh instances

| quantity | LOW (n=34) | HIGH (n=34) | H/L | t |
|---|---|---|---|---|
| `x_full` (paid, model-free) | 5993 ± 5810 | 2123 ± 1930 | **0.354** | **−3.59** |
| `OP_full` | 7.63e5 ± 7.39e5 | 2.70e5 ± 2.45e5 | 0.355 | −3.59 |
| full relations found | 217.3 ± 143.2 | 613.2 ± 267.8 | 2.821 | +7.60 |

`corr(Q/π(B), x_noLP) = −0.454` (round 42: −0.657; H/L 0.141 vs 0.354). Same
sign, same law, fresh instances.

### 3b. The paper's mechanism — PAIRING — is a validated NEGATIVE here

| c | median `x_LP/x_noLP` | mean ± sd | **LP better in** |
|---|---|---|---|
| 2 | 1.022 | 1.88 ± 1.67 | **0/51** |
| 4 | 1.598 | 4.05 ± 4.86 | **0/44** |
| 8 | 1.906 | 4.30 ± 4.83 | **0/37** |
| 16 | 1.806 | 4.16 ± 4.91 | **0/35** |
| 32 | 1.804 | 3.93 ± 4.78 | **0/34** |
| 64 | 1.804 | 4.17 ± 4.90 | **0/34** |

Failures (no splitting dependence anywhere in the scan): **13–23 of 34** LOW,
**4–11 of 34** HIGH.

**Mechanism (measured).** Pairing is bottlenecked by how often a large prime
repeats. At c = 32 there are 2332.6 SLP relations over 907.6 distinct large
primes — multiplicity 2.57 — so only ~45% of large primes can pair even once and
greedy pairing discards the rest. The paper at 80 digits converts far worse
(129318 partial → 1661 complete = 1.3%; mine converts ~43%) and **still loses**,
because the pairs are *late* in the position-ordered stream while the unpaired
full relations are early.

### 3c. LP-as-COLUMN is cheaper on the model-free quantity — consistently

| c | median `x_LP/x_noLP` | mean ± sd | LP better in |
|---|---|---|---|
| 2 | 0.788 | 0.783 ± 0.167 | 54/66 |
| 4 | 0.723 | 0.715 ± 0.184 | 58/66 |
| 8 | 0.707 | 0.681 ± 0.193 | 59/66 |
| 16 | 0.691 | 0.662 ± 0.177 | 64/66 |
| 32 | 0.690 | 0.651 ± 0.181 | 64/66 |
| 64 | 0.681 | 0.649 ± 0.181 | 64/66 |

Model-free budget test (round 42's device) — at a fixed sieve budget the cheaper
arm must fail *less*:

| budget `M` | no-LP | lppair c=32 | **lpcol c=32** | fb c=32 |
|---|---|---|---|---|
| 10755 | 5/68 | 39/68 | **2/68** | 0/68 |
| 21510 | 3/68 | 37/68 | **0/68** | 0/68 |
| 43020 | 2/68 | 34/68 | **0/68** | 0/68 |

### 3d. …but the operation-count model says the LP arm is MORE expensive

`OP_lpcol / OP_noLP` = 1.07 (c=2), 1.08 (c=4), 1.31 (c=8), 1.91 (c=16),
3.05 (c=32), **5.24 (c=64)**.

**The two paid quantities disagree and I am reporting that, not hiding it.** At
13 digits the candidate rate is 27–49% (an 80-digit run sees far less), so the
trial-division term dominates the operation count. Positions fall ~32%; the
operation count does not. Which is right at scale is **not determined by this
round**, and I am not going to pick the flattering one.

### 3e. The "did it just move the cost?" control

Putting the same primes into the **sieve** instead (`fb` arm, factor base
extended to B₂) buys the same relations *better on positions* —
`x_fb c=4`: 3218 ± 2810 / 1346 ± 754; `x_fb c=32`: 2492 ± 1630 / 1207 ± 646,
versus no-LP 5993 / 2123 and lpcol c=32 3547 / 1327 — **but it pays by growing
the column space** to |FB(B₂)| = 208.6 (c=4) and 1280.2 (c=32), from 63.8.

> The two routes are **substitutes, not a decoupling**: LP buys relations with
> trial division and leaves the column space alone; extending `B` buys the same
> relations with sieve time and multiplies the column space. Both draw the new
> columns from the split set.

---

## 4. DOES IT EVADE ROUND 42's COLLAPSE? **NO — IT AMPLIFIES IT.**

`corr(Q/π(B), x_LP/x_noLP)`, across instances:

| c | 2 | 4 | 8 | 16 | 32 | 64 |
|---|---|---|---|---|---|---|
| lpcol, `x` | +0.306 | +0.422 | +0.390 | +0.404 | +0.411 | +0.408 |
| lpcol, `OP` | +0.419 | +0.553 | +0.548 | +0.577 | +0.588 | +0.590 |
| lppair, `x` | +0.179 | +0.045 | −0.011 | −0.037 | −0.055 | +0.000 |

**The correlation is POSITIVE: the LP gain is LARGER at high `Q` and smaller at
low `Q`.** So LP helps most exactly where the factor base is dense, and least in
the low-`Q` regime where round 42 showed the paid work is already several times
higher. The channel does not touch the direction of the paid-work law; it
re-weights it.

**Mechanism (measured, section 5 of `an.log`).** The LP supply is *less*
`Q`-sensitive than the full-relation supply, but not `Q`-insensitive:

| | LOW | HIGH | H/L |
|---|---|---|---|
| full relations (no LP) | 217.3 ± 143.2 | 613.2 ± 267.8 | **2.821** |
| SLP relations, c=4 | 552.4 ± 248.7 | 1030.8 ± 314.7 | **1.866** |
| SLP relations, c=32 | 1676.1 ± 726.9 | 2989.2 ± 846.0 | **1.783** |

LP reduces the `Q`-sensitivity of the relation supply (2.82× → 1.78×) and
nothing more. `corr(u, ratio) = −0.20 … −0.26`: the residual `Q`-effect is
re-expressed through the Dickman variable, not removed. The smoothness gap and
the `Q` collapse remain **orthogonal in the same way round 38 recorded**.

---

## 5. IS THIS A RE-RUN OF THE RECORD?

**Partly, and I say which part.** The no-LP arm reproduces round 42's §3b sign
on **68 fresh instances** (seeds 930000+, disjoint from r42's 900000+):
H/L 0.354 vs 0.141, t = −3.59 vs −6.35, `corr(Q/π(B), x_PAID)` −0.454 vs
−0.657. Round 43 did not rediscover it; it re-measured it. **Nothing in the
record prices the large-prime channel** — the LP arms, the budget ladder, the
`fb` control and the `Q`-dependence of the LP gain are all new.

---

## 6. WHAT IS **NOT** CLAIMED

* **Scale.** 13-digit `N`, `B = 717`, single-polynomial. The paper's regime is
  `B₂/B₁ ∈ [10, 100]` at 70–100 **digits**; my ladder is `{2, …, 64}` at 13
  digits and the operation-model optimum sits at the *smallest* `c` tried.
  **The paper's "optimal c ≈ 400" does not transfer, and this round does not
  locate an optimum at this scale.**
* **Two large primes.** Only the 1-LP variant is implemented. The paper's Table
  4 numbers are for the 2-LP variant, where pp-relations and SQUFOF dominate;
  §3b's negative is about 1-LP pairing.
* **Distributions.** No unmeasured distribution is used anywhere. `ρ` appears
  only through the measured Dickman variable `u`, which is reported as a
  correlation, not as a model.
* **NFS.** Nothing transfers. **No factoring method is claimed** — the
  instrument factors 42-bit semiprimes it was handed, and every success is
  verified against ground truth.
* The `OP` column is a **model**, labelled as one, with its bias against LP
  stated.

## 7. VERDICT

* **Does the large-prime sieve DECOUPLE the column count from the split set?**
  **NO** — three independent ways: it is a theorem for `f(x)=(b+x)²−N`
  (0/1071 and 0/5497 counterexamples); it is the paper's own definition
  (`Q = {primes B₁ < q ≤ B₂, (n/q)=1}`); and the standard pairing mechanism
  leaves the column count *exactly* `m` with the round-42 ceiling
  `rank ≤ Q(N,B)+1` intact (0/68 violations). The one arm that grows the column
  count grows it **inside** the split set, exhausting 95%→29% of the newly
  available split primes and never exceeding `Q(N,B₂)+1`.
* **Is the paid work lower at fixed `B`?** **Mixed and honestly reported.** The
  paper's own mechanism (pairing) is a **validated negative**: worse in
  34/34–51/51 instances. LP-as-column cuts positions ~32% and passes the
  model-free budget test (0/68 vs 2/68 at `M = 21510`), but the
  operation-count model charges it 1.07–5.24× the no-LP arm. The
  FB-extension control beats both on positions and pays in column space.
* **Does it evade the round-42 collapse? NO — it amplifies it.**
  `corr(Q/π(B), x_LP/x_noLP) = +0.31 … +0.42`; the LP gain is largest at high
  `Q`. It reduces the `Q`-sensitivity of the relation supply (2.82× → 1.78×)
  and leaves the paid-work law's sign intact.
* **A validated negative is a success.** Surface (a) is closed: not because LP
  is useless (it measurably is not, for positions) but because the channel's
  one structural promise — leave the split set behind — is false, and because
  the gain it does deliver is a re-weighting of the same `Q`-set law rather
  than an escape from it.
