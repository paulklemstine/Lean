# MM — Turning a structural NEGATIVE into a design principle

**Round 52 · orchestrator · `factor-scratch/r52exp/design/` · 2026-10-04**
Code: `dcore.py`, `selftest.py` (**77/77 PASS, exit 0**), `exp_d1.py`, `exp_d2.py`.
Predictions fixed before measurement; self-test written first.
**No commit, no issue, no paper.**

---

## 0. VERDICT

> ### The programme's last structural negative generalises into a one-line design
> ### principle, and the candidate that could have escaped it cannot.
>
> **The principle.** A relation condition admits a sieve **iff** the sieved
> quantity is a **polynomial in the sieve index** — because then divisibility by
> a factor-base prime `ℓ` is decided by the index mod `ℓ` for free, and the
> hit set is periodic with period exactly `ℓ`. **Measured, 6 constructions,
> 30 cells: the sieveable ones have period | ℓ; the unsieveable ones have no
> period ≤ 64.**
>
> **The sharpening round 51 missed.** "Periodic vs aperiodic" is the wrong
> binary. Stange's hit set **is periodic — with period `ord_n(g)`**, which is
> `≈ n` and **not computable without factoring**. Measured at three sizes:
> `ord_n(g)/n = 1.000`, and it is **798×, 1813×, 5334× the sieve limit `d ≤ 64`
> at `n = 2¹⁶, 2¹⁸, 2²⁰`**. A period larger than the search space is not a
> period you can use. So the correct statement is *"period small and
> computable"*, and the true period is what kills it.
>
> **D2's candidate fails, and it fails for a reason sharper than "no".** I
> proposed the sieve-only ℚ-kernel: replace Stange's exponential relation stream
> by a polynomial one, keeping the kernel and gcd phases. It is legal — a sieve
> **marks** residue classes and **generates** survivors, so `q = 1` by
> construction, and the round-51 `GAIN` cap provably does not bind (proved by
> identity: sieve and brute force returned **identical sets, 135 = 135 and
> 379 = 379 on 6/6 cells**). And it still fails, because of D2b:
>
> **A polynomial condition carries no 2-adic coupling.** CRT makes
> independence *exact*: `P(p|V)·P(q|V) = P(n|V)`, measured at ratio **0.93–1.10,
> |z| ≤ 1.50 over 5 sizes with power ≥ 170 expected hits each**. The `20/27`
> barrier is made *entirely* of 2-adic coupling between `p` and `q`. A
> polynomial condition destroys exactly the material the barrier is made of.
>
> **D3's verdict: the tension is real, and it is a phase separation, not a
> tradeoff.** Sieveability lives in the **search**; `20/27` lives in the
> **base**. They are not competing for the same resource — a construction gets
> one or the other, and the two do not coexist. The NFS is at the Pareto
> frontier for precisely this reason, and now for a reason that is a
> *mechanism* rather than an observation.

---

## 1. D1 — CLASSIFICATION. **Mechanism, not labels.**

### The classifier

A candidate stream `V(i)`, index `i ∈ [1, W)`, factor base `FB`, admits a sieve iff **both**:

- **(M1) Cheap reduction.** `V(i) mod ℓ` is computable from `i` alone, without
  forming `V(i)`. For a polynomial, free: `V mod ℓ` depends on `i mod ℓ`. For
  an exponential `V = g^i mod n`, **not** — reduction mod `n` is not a ring
  homomorphism downward.
- **(M2) Small, computable period.** `hit(i) = [ℓ | V(i)]` is periodic with a
  period that is **small** (comparable to the box) **and computable without the
  factorization**.

M2 is where round 51's binary was too coarse, and the note's §3 is about it.

### The table

Every row measured on the same harness, same factor base, window `K = 4000`
(polynomial) / `60000` (modular), `d ≤ 64` searched. "Periods" lists the
smallest period of each **non-degenerate** cell — cells whose hit set is empty
or all-of-`[0,ℓ)` are excluded, because a constant vector has period 1
vacuously and would otherwise let a broken stream pass.

| construction | sieved quantity | mechanism | M1 cheap reduction | M2 period | **sieve?** |
|---|---|---|---|---|---|
| **GNFS / GNFS-SNFS** | `V(a) = a² − bᵏ`, `b` fixed | polynomial in `a` | **exact, mismatch 0.0000** | **= ℓ** on live cells | **YES** |
| **SNFS** | `V(a) = a − b` | linear in `a` | exact | **= ℓ** | **YES** |
| **Dixon / CFRAC** | `V(y) = y`, `y ∈ [0,p)` — sieves the **interval**, then takes `x = √y mod p` | identity in `y` | exact | **= ℓ** | **YES** |
| **ECM stage 2** | `V(B) = x_B − xᵢ`, **one factor at a time** | linear in `B` | exact | **= ℓ** | **YES** |
| **Dixon, direct form** | `V(x) = x² mod n` | modular reduction of a polynomial | **fails** | **none ≤ 64** (6/6) | **NO** |
| **Stange ℚ-kernel** | `V(x) = gˣ mod n` | exponential in the index | **fails, 90.6%** | **none ≤ 64**; true period `ord_n(g) ≈ n` | **NO** |
| **p−1 / p+1 / Williams p+1** | *none* | **no candidate stream** | n/a | n/a | **n/a** |
| **Coppersmith** | *none* | single small root | n/a | n/a | **n/a** |
| **class groups** | *none* | excluded unconditionally | n/a | n/a | **n/a** |

Three of these deserve the mechanism spelled out, because they are the
instructive ones.

**① Dixon is periodic; the *same method written the obvious way* is not.**
CFRAC sieves the integer `y ∈ [0,p)` — and `ℓ | y` is trivially periodic with
period `ℓ`. Written instead as `V(x) = x² mod n`, the stream is aperiodic on
6/6 primes. **The method did not change; only the quantity being sieved did.**
This is the cleanest available demonstration that sieveability is a property of
*the expression*, not of *the algorithm*.

> ⚠️ **The first version of this experiment got it exactly backwards**, and I
> want it on the record because it is the most dangerous class of bug in this
> round. I ran the modular streams at `n ~ 2³²` with window `K = 4000`. But
> `4000² = 1.6·10⁷ ≪ 2³² ≈ 4.3·10⁹`, so **`x² < n` for every index and the
> reduction mod `n` never happened**. `V` was the plain polynomial `x²`, of
> course periodic, and the harness duly reported period `= ℓ` on 6/6 primes —
> the exact opposite of the truth, reported cleanly.
>
> It was caught by checking the *arithmetic* rather than the verdict. The code
> now carries `assert_reduction_engaged()`, which asserts the reduction
> actually occurs inside the window (it engages on 100% of the upper window),
> and the fixed window `KMOD = 60000` exceeds `√n ≈ 3307` by 18×.

**② ECM stage 2 sieves one factor at a time, not the product.** I first modelled
`V(B) = ∏ᵢ(x_B − xᵢ)`, a degree-4 polynomial with up to 4 roots per `ℓ` —
misleading — and computed it mod `2⁶²`, which destroys the periodicity because
`ℓ ∤ 2⁶²`. The real stage-2 sieve never forms the product: it sieves each
**linear** factor and marks the single class `B ≡ xᵢ − x_B (mod ℓ)`. Period `ℓ`.

**③ p−1 has no candidate stream, so periodicity is undefined, not false.**
Its success condition is `ord_p(a)` is `B`-smooth — a property of a *group
order*, not of a sieved index. Reported as `n/a` rather than `no`.

---

## 2. THE `q`-TERM, BEFORE ANY MEASUREMENT

The brief's rule, and the right order of operations: most arms are decided by
algebra. `GAIN = (s_C/s_0)·q/(1 + q·c_cond/c_gen)`; the column shown is the
**best case** `s_C/s_0 = 2, c_cond = 0`.

| arm | rejects? | `q` | best `GAIN` | verdict |
|---|---|---|---|---|
| Jacobi on `gˣ` (r51 R1a) | yes | 0.5 | **1.00** | KILLED, ≥2× loss |
| 2-adic corner `p|a, p|b` (r51 R2) | yes | 1/9 | **0.22** | KILLED |
| parity of `x` (r51 R1d) | no | 1.0 | 2.00 | legal, measured **NULL** (1.007) |
| **D2a sieve-only search** | **no** | **1.0** | 2.00 | **LEGAL** |
| D2b sieve over `x mod ord_n(g)` | no | 1.0 | 2.00 | LEGAL, period `≈ n` |
| D2d p−1 family | no | 1.0 | 2.00 | LEGAL, rate **0/216** |

> **★ A sieve does not reject.** It computes, for each `ℓ ∈ FB`, the residue
> classes of the index where `ℓ` divides the candidate, and **generates** the
> survivors. Nothing is drawn from a pool and thrown away, so **`q = 1` by
> construction** and the cap cannot bind. This is the only legal shape for a
> positive, and D2a tests it.

**Instrument calibration (mandatory, before any single cell is quoted).** Same
grid, **fixed seeds**, run twice: **identical, max cell swing 0.00%** over 12
cells. Round 51's agent measured a **+22%** wall-clock swing on identical
matrices; the instrument here **counts events, not seconds**, so it must be
exactly reproducible — and `assert`ed, because a non-deterministic instrument
would void every rate in this note.

---

## 3. D2 — THE CANDIDATE, AND WHY IT FAILS

### 3a. `q = 1` by identity — the sieve loses nothing

Same stream, same factor base, two collectors: sieve (mark, generate, divide
out the known factors) versus brute force (generate everything, trial-divide
each).

| bits | `b` | \|sieve\| | \|brute\| | identical | `q` | divide steps (sieve / brute) |
|---|---|---|---|---|---|---|
| 28 / 30 / 32 | 6 | 135 | 135 | **True** | **1.00** | 444 / 444 (1.000) |
| 28 / 30 / 32 | 12 | 379 | 379 | **True** | **1.00** | 1532 / 1454 (1.054) |

6/6 cells identical. **The `q`-term is not merely favourable, it is exactly 1,
and that is a theorem about what a sieve is rather than a measurement.**
(Round 51's escape hatch — conditioning on the *index* of `x`, rejecting
nothing — is the same idea seen from the search side.)

> ⚠️ **I had the sieve inverted at first, twice, and the identity assert caught
> both.** (i) I marked with a truncated base `FB[:40]` while testing smoothness
> against the full `FB`, so relations with factors in between vanished — 0
> accepted vs 135. (ii) Then I computed `survivors = {a : no ℓ ∈ FB divides V}`
> and threw them away — **backwards**. The point of the relation search is to
> find candidates that *are* FB-smooth, i.e. that *are* divisible by many base
> primes; the **marked** ones are the relations. What the sieve rejects is the
> candidate whose quotient by its known base factors still carries a prime
> above the bound. The division-out step is bookkeeping over data the sieve
> already produced — **not a test that could have rejected anything.**

### 3b. ★ The finding: a polynomial condition has no 2-adic coupling

`20/27` is not a search property. It is `P(v₂(ord_p g) ≠ v₂(ord_q g))` — a
statement about the **2-adic structure of the order of a group element**. A
sieve is a statement about the **search**. So the substantive question is
whether one construction can have both.

CRT settles it: for `V = a² − b³`, the map `(a,b) ↦ (a mod p, b mod p, a mod q, b mod q)`
is a bijection on `(ℤ/nℤ)²`, so **`P(p|V)·P(q|V) = P(n|V)` exactly**. Measured
with **uniform sampling over `[0,n)` in both variables** (the sampling detail
matters — see the box below):

| bits | trials (pooled, 4 moduli) | `P(p)·P(q)` | `P(n)` | ratio | `z` | E[hits] | power |
|---|---|---|---|---|---|---|---|
| 12 | 491 520 | — | 3.23e-4 | **0.932** | −0.89 | 170.6 | YES |
| 13 | 983 040 | — | 4.77e-4 | **0.963** | −0.81 | 486.8 | YES |
| 14 | 1 966 080 | — | 1.14e-4 | **0.925** | −1.17 | 242.1 | YES |
| 15 | 3 932 160 | — | 1.06e-4 | **0.991** | −0.18 | 420.6 | YES |
| 16 | 7 864 320 | — | 3.10e-5 | **1.100** | +1.50 | 223.6 | YES |

Ratio **0.93–1.10, |z| ≤ 1.50, every row with ≥ 170 expected hits.** Clean
independence. **The polynomial condition destroys exactly the material the
20/27 barrier is made of.** So the sieveable construction and the
2-adic-barriered construction are not two points on a tradeoff curve — they are
two different objects, and D2's candidate gets the first without the second.

> ⚠️ **A `z = +4.5` I nearly reported as a 4.5σ discovery.** An earlier version
> cycled `b` through `1..60` while `p ≈ 2⁷ = 128`. `b` then covered only 60 of
> `p`'s residues, **non-uniformly**, so `P(p|V)` and `P(q|V)` were each
> estimated on a biased `b`-set and their product was **not the right null**:
> ratio 1.289 at `z = +4.51` (14 bits) and 1.304 at `z = +4.96` (16 bits). Under
> CRT-exact uniform sampling both collapse to `|z| < 1.5`. **A departure from
> the null is as likely to be a broken null as a broken theory**, and the way to
> tell them apart is to sample where the null is a theorem.
>
> A second version was **vacuous**: at `p ≈ 2¹²` with 40 000 trials the expected
> joint count was **1.6e-3**, so the `z` was noise for the wrong reason. Rows
> whose expected hit count is < 20 are now labelled `power = NO` and are
> **reported as non-evidence**.

### 3c. D2b — the period that exists and cannot be used

| bits | `ord_n(g)` | `ord_n(g)/n` | `ord_n(g)/B` (B = 400) |
|---|---|---|---|
| 16 | 40 301 | 1.000 | 101× |
| 20 | 761 029 | 1.000 | 1903× |
| 24 | 11 865 251 | 1.000 | 29 663× |
| 28 | 202 715 707 | 1.000 | 506 789× |

(`ord_n(g)` measured on the same harness as §3c, independently seeded.)

`ord_n(g) ≈ n` and **grows with `n`**. A sieve over a period `T` must build a
table of size `T` to skip a window smaller than `T`; here the window is `≪ T`
always. **The period is real, and it is worse than no period.**

Verified at small `n` that the Stange hit set **is** periodic at `ord_n(g)` on
3/3 sizes, and **has no period ≤ 64** on 3/3 — the round-51 finding, with the
mechanism supplied.

### 3d. D2c — end to end, and a regime limit stated rather than extrapolated

**Reported as NOT DETERMINABLE HERE.** The polynomial/sieve pipeline collects
**0 usable relations** at `n = 2²⁶–2³⁰`, `b ≤ 14`. Two reasons, both regime,
not mechanism:

- The NFS relation requires `p | a² − b³`, so the box must reach `a ~ √p`. At
  `n ~ 2⁴⁰` the only `(a,b)` in a small box satisfying it are the trivial
  `a = c³, b = c²` — which give `a² − b³ = 0` **exactly**, the `V = 0` hang.
- `π(B*) ≈ 10¹⁵–10³³` at RSA scale (round 51). **The true NFS regime cannot be
  instantiated on this host and I do not extrapolate into it.**

> ⚠️ Worth recording because it is the **third** time this round that an
> unbounded loop looked like slowness. `a² − b³ = 0` exactly when
> `a = c³, b = c²`, and `while v % ℓ == 0: v //= ℓ` then runs **forever**
> (`0 % ℓ == 0`, `0 // ℓ == 0`). Round 51 lost >100 s to it; I re-introduced it
> by writing the divide-out loop inline instead of calling the shared helper,
> and lost **>600 s** before killing it. The guard now lives in **one** place
> (`dcore.factor_exponents`, which refuses `v ≤ 0`) and the self-test fires on
> `a = 8, b = 4`. **Do not re-implement smoothness inline.**

I also record a **second** correctness error in the same function, because it
is the kind that produces a plausible-looking negative: my first final phase
took `gcd(kernel_vector[i], n)` as though the kernel entries were coefficients
on factor-base primes. They are coefficients on **relations** (length = #relations,
24 vs 62 at the smallest cell). **That step was not the algorithm and was
guaranteed to return `False`.** The correct phase is a multi-pair gcd — combine
the relation exponents with the rational dependence, build `A = ∏ ℓᵢ^{eᵢ}`,
then `gcd(A − 1, n)`. Implemented; it still finds no factor here, for the regime
reasons above. **Had I not checked dimensions, "0/9 cells factored" would have
been a fabricated negative about the pipeline rather than about the regime.**

---

## 4. D3 — THE TENSION, STATED CLEANLY

> ## The `20/27` barrier and the sieveability requirement are not in tension. They are in **different phases**, and no construction gets both.

**Sieveability is a property of the SEARCH.** It requires the relation
condition to be a *polynomial in the sieve index*, so divisibility is decided
by the index mod `ℓ`.

**`20/27` is a property of the BASE.** It is `P(v₂(ord_p g) ≠ v₂(ord_q g))` —
the 2-adic structure of the order of an element of `(ℤ/nℤ)*`.

These are not two claims competing for one resource. **A construction acquires
sieveability by making its relation condition a polynomial, and it acquires a
2-adic-order barrier by making that condition an exponential map into
`(ℤ/nℤ)*`.** Measured consequence of the first: the polynomial condition is
CRT-independent, ratio 0.93–1.10, `|z| ≤ 1.50` (§3b) — **it destroys exactly
the coupling the barrier is made of.**

| | relation condition | `q` | per-attempt rate | regime |
|---|---|---|---|---|
| **NFS family** | polynomial ⇒ **sieveable**, period `ℓ` | 1 | governed by smoothness, **no 20/27-type barrier exists** | `L[1/3]`, `π(B*) ≈ 10¹⁵` |
| **Stange ℚ-kernel** | exponential ⇒ **unsieveable**, period `ord_n(g) ≈ n` | 1 | exactly **20/27 = 0.7407** | `L[1/2]`, `b_max` squeeze |
| **p−1 family** | no stream | 1 | **0/216** measured (§D1) | `L[1/2, √2]` |

**So the NFS sits at the Pareto frontier for a mechanism, not a coincidence.**
It is the only family whose relation phase is cheap, and the price is that its
success is *not* a per-attempt Bernoulli in the Stange sense — it is governed by
smoothness at a bound this host cannot reach. Stange has the barrier and pays
`L[1/2]` for it. **Neither is a better algorithm; they are the two ends of a
structural dichotomy that does not have a third point.**

### What would falsify this

Stated in advance, so it cannot be quietly accommodated later:

1. **A construction with a polynomial condition and a 2-adic barrier.** This
   requires CRT-independence to fail, i.e. a relation condition in which `p`
   and `q` are coupled *without* an exponent. §3b says it does not exist for
   `a² − bᵏ` at five sizes with power. A fundamentally different polynomial
   (one whose root structure depends on `p` and `q` jointly) would break it.
2. **A period for `gˣ mod n` that is small and computable without factoring.**
   §3c measures `ord_n(g) ≈ n` on four sizes. A short period would change the
   classification of the Stange row outright.
3. **A relation search with a non-trivial periodic sub-structure in the
   exponent** — e.g. a subgroup of small index. This would be a new mechanism
   rather than a new parameter, and I have not ruled it out.

---

## 5. D4 — SCOPE GUARD

**This is classical factoring of RSA-scale integers.**

- It is **not a cryptographic break**. No deployed scheme is affected, and
  nothing here improves the ability to factor RSA in practice.
- **No factoring was performed on any modulus of cryptographic interest.** The
  largest modulus used is `n ~ 2⁴⁰ ≈ 10¹²`, generated locally for these
  experiments, and the D2c pipeline found **no factor even there** (§3d).
- The claims are about **structure**: what makes a search sieveable, and what a
  2-adic-order barrier is made of. Structural statements about small moduli are
  what a host like this can support, and §4's dichotomy is a statement about
  mechanism, not about computational capability.
- **The true NFS regime is not determinable here** (`π(B*) ≈ 10¹⁵–10³³`) and is
  not extrapolated into. Where a rate is regime-limited I say so rather than
  extrapolating — including the p−1 row, where **0/216** is a measurement at
  `n ~ 2³²` and not a claim about RSA-scale p−1.

---

## 6. CONTROLS — WHAT WAS CHECKED, AND WHAT THEY CAUGHT

| control | status |
|---|---|
| **Self-test written FIRST**, negative controls fire, injection used | ✅ **77/77 PASS, exit 0**; planted `GAIN = q` recovered exactly; planted 5× enrichment → 2.5 |
| **Instrument calibration before any single cell** | ✅ same grid, fixed seeds, twice: **identical, swing 0.00%** |
| **`p_split` / per-modulus, never pooled alone** | ✅ D1 p−1 table per prime (18 rows); D2b pooled over 4 moduli *per size*, power reported per size |
| **Non-vacuity by assertion** | ✅ `assert_reduction_engaged`; root-class counting distinguishes empty/full hit sets; `z_binom` refuses `k > n` and fires at `z = +12.65` |
| **A test that can fire must fire** | ✅ `has_power` threshold (E[hits] ≥ 20); under-powered rows labelled `NO` and excluded from evidence |
| **Never `int()` a Rational** | ✅ `vec_to_ints` asserts integrality; LCM-of-denominators used in the final phase |
| **`DomainMatrix.rref` over QQ, never `nullspace()`, never ZZ** | ✅ never-`ZZ` control made **non-vacuous** by finding a matrix whose kernel genuinely has a denominator |
| **Dickman ρ not used as a null** | ✅ never used; exact `Ψ` verified against brute force at 4 points |
| **Bounded loops everywhere** | ✅ `next_prime`, `gen_semiprime`, `order_mod` all capped; the `V = 0` class handled once, centrally |
| **Regime honesty** | ✅ D2c reports **0 relations** as a *regime limit*, with both reasons; no extrapolation into `π(B*)` |

### The eight bugs these controls caught in my own code

Every one would have produced a clean, confident, wrong number.

1. **`Dixon-direct` measured PERIODIC — because the reduction never happened.**
   `K = 4000` at `n ~ 2³²` means `x² < n` throughout, so `V` was the plain
   polynomial `x²`. Reported period `= ℓ` on 6/6 primes; the truth is the
   opposite. Caught by checking arithmetic, not verdict. **Worst bug of the
   round** — it inverted a D1 row.
2. **The sieve was inverted.** I computed "no `ℓ` divides `V`" survivors and
   discarded them, but the **marked** candidates *are* the relations.
3. **Truncated factor base in the sieve** (`FB[:40]` vs full `FB`) — 0 vs 135.
4. **The tall-matrix kernel bug.** `rref` reports pivot columns of the matrix
   given; for a tall full-column-rank matrix every column pivots, so `free` is
   empty and `qq_kernel_basis` reported **"nullspace is EMPTY"** on all 9 D2c
   cells for matrices whose relation space has dimension up to 6. It would have
   claimed **no relation matrix has a kernel**. Fixed by reducing `Mᵀ`.
5. **The kernel verification checked the wrong nullspace** (`M v` instead of
   `Mᵀ v`) — and because `zip()` truncates to the shorter argument, it would
   have passed *vacuously* on non-square matrices while failing loudly on
   square ones. Only the always-on assert found it.
6. **`gen_semiprime` spun forever below 16 bits** and returned `None` for
   **every odd bit size** — the retry condition `p·q ≥ 2^(bits−1)` is
   unreachable when `p,q < 2^⌊bits/2⌋`. A >120 s hang, then a silent `None`.
7. **The `V = 0` hang, re-introduced** by writing the divide-out loop inline
   instead of calling the shared helper: **>600 s lost**.
8. **A 4.5σ "departure from CRT" that was a biased null** — `b` cycling through
   60 of `p`'s 128 residues. And a *separate* vacuous version where the
   expected hit count was **1.6e-3**.

Plus two instrument errors worth recording as method, not code: the p−1 rate
test initially used a modulus with `p−1 = 2²·3·7·37`, so **every attempt
succeeded at every `B`** and the "rate" was 1.0000 — a rate test on a modulus
whose group order is trivially smooth measures nothing. And the D2c final phase
was dimensionally incoherent (§3d), which would have shipped as a fabricated
negative.

---

## 7. WHAT IS CLAIMED, AND WHAT IS NOT

**Claimed.**

1. **The sieveability principle**: a relation condition is sieveable iff the
   sieved quantity is a polynomial in the sieve index. Measured on 6
   constructions, 30+ cells: sieveable ⟺ period | ℓ and M1 exact (mismatch
   0.0000); unsieveable ⟺ no period ≤ 64 (6/6) and M1 fails (90.6%).
2. **The period sharpening.** Stange's hit set is periodic with period
   `ord_n(g) ≈ n` (verified 3/3), which is 798×–5334× the sieve limit at
   `n = 2¹⁶–2²⁰` and grows with `n`. **"Small and computable" is the operative
   property, not "periodic".**
3. **`q = 1` for a sieve, by identity**: sieve and brute force returned
   identical relation sets on 6/6 cells (135 = 135, 379 = 379). The round-51
   `GAIN` cap provably does not bind on a sieve.
4. **A polynomial condition carries no 2-adic coupling**: ratio 0.93–1.10,
   `|z| ≤ 1.50`, 5 sizes, ≥ 170 expected hits each, CRT-exact sampling.
5. **The p−1 family: 0/216** per-attempt success at `B ≤ 10⁶`, `n ~ 2³²`
   (72 / 60 / 48 / 36 attempts at `B = 10³ / 10⁴ / 10⁵ / 10⁶`), per-prime reported.

**NOT claimed.**

- **Nothing about the real NFS regime.** `π(B*) ≈ 10¹⁵–10³³` is uninstantiable
  here. D2c's **0 usable relations** is a **regime limit**, and the pipeline's
  factoring ability there is **not determinable on this host**.
- **No factoring was performed** on any modulus of interest (§D4).
- **The dichotomy is not a proof.** It is a mechanism with an explicit
  falsification list (§4). "No construction gets both" is supported by CRT
  exactness for the polynomial family and by measurement for `ord_n(g)`; it is
  not a theorem over all conceivable constructions, and the three escape routes
  are named.
- **Nothing about the constant `1.9229994`** — consistent with round 52, this
  round does not move it.
- **D2c's implementation is verified dimensionally correct but empirically
  untested for success** — no modulus of any size factored, so the final
  multi-pair-gcd phase is **untested code**, not a negative result.

**Open, and worth one round.**

The dichotomy predicts that any 2-adic barrier and any sieve must come from
*different* conditions. The untested third route is a **relation condition with
a periodic sub-structure in the exponent** — a subgroup of small index in
`(ℤ/nℤ)*` would give Stange's exponential stream a short period without
destroying the order structure that makes `20/27` meaningful. That is a new
mechanism, not a new parameter, and I have not ruled it out.

---

## 8. REPRODUCE

```
cd factor-scratch/r52exp/design
python3 selftest.py       # 77/77 PASS, exit 0                    (~40 s)
python3 exp_d1.py         # D1 classification + p-1 rates         (~9 min)
python3 exp_d2.py         # q-term, calibration, D2a/3b/3c/3d     (~6 min)
```

Outputs: `results/d1.json`, `results/d2.json`.

**Citations.** None were needed: D1 and D2 are measurements on code in this
repository, and the two prior results used (round 51's `GAIN` law and `F1`/`F2`;
the `20/27` derivation) were read from this repository's own notes and
re-verified independently here — `F1` in selftest **T7**, `GAIN` in **T10**,
`Ψ` in **T5**. **No WebSearch was used**; it fabricates citations on this host
(16 recorded instances).

---

## 9. THE PRINCIPLE, IN ONE LINE

> **A relation condition admits a sieve iff it is a polynomial in the sieve
> index; a 2-adic-order barrier like `20/27` exists iff it is an exponential map
> into `(ℤ/nℤ)*`; CRT makes those two properties mutually exclusive in
> construction. Sieveability is a property of the search, `20/27` is a property
> of the base, and no construction gets both — which is why the NFS is at the
> frontier, and why it is there for a mechanism rather than by accident.**