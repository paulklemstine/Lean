# ROUND 44 — SURFACE: NFS number-field / polynomial selection, the root discriminant and the small-ideal sieve

**Verdict: a POSITIVE identification of the paid term, and a validated NEGATIVE on
the surface's central hypothesis. The paid term of NFS relation collection is the
SIEVING AREA and it is `area = (π(B_f) + |FB(K,B_g)|)/MurphyE` — verified at
0.996 ± 0.155 (between-instance sd, n = 15) on real shipped operating points. But
the round-42 analogue does NOT exist: the NFS counterpart of the split set `Q`,
namely the algebraic factor base, is **asymptotically field-independent**, measured
at |FB|/π(B) = 1.0253 ± 0.0209 over 40 real fields of degree 4, 5, 6 and root
discriminant spanning 1.5·10¹⁶ … 3.5·10⁴⁸. Field selection is not a paid lever.**

**This is NOT a re-run of the record.** Rounds 41–43 attacked single-polynomial
QS. `RESEARCH.md` names NFS only as context (lines 379–500, 2890–3000) and every
one of those NFS passages carries the "do not extrapolate" warning in the other
direction. No NFS field-selection quantity appears in `NegativeResults.lean`.

Round 44, 2026-09-26. Scratch: `/home/raver1975/factor-scratch/r44nfs/`.

---

## 0. SOURCES OPENED (not paraphrased from titles)

**The primary source is the CADO-NFS production implementation**, fetched from
`github.com/cado-nfs/cado-nfs` (LGPL) and read in the working tree at
`r44nfs/src/`. This is the code that produced the record factorizations, and it is
the NFS *field-selection and scoring* machinery itself — not a survey of it.

`murphyE.cpp`, `murphyE.hpp`, `area.cpp`, `area.hpp`, `polyselect.cpp`,
`polyselect_alpha.cpp`, `polyselect_alpha.h`, `auxiliary.cpp`, `auxiliary.hpp`,
`polyselect_norms.cpp`, `polyselect_main_data.cpp`, `polyselect_main_queue.cpp`,
`polyselect_collisions.cpp`, `polyselect_proots.cpp`, `polyselect_stats.h`.

**Plus the 40 polynomials CADO-NFS ships in `parameters/polynomials/`** — the
actual fields it selected, one per `N`, each with its own skewness, linear form,
and printed MurphyE. This is a **real per-instance dataset of 40 NFS fields**,
which the round-42 surface did not have a counterpart for.

**A negative about the obvious textbook source.** The *Handbook of Applied
Cryptography* §3.2.7 was read (`r43/hac_chap3.txt`, staged by a sibling surface).
It is **not usable as NFS machinery**; it disclaims it in its own words:

> "The details of the algorithm are quite complicated, and **are beyond the scope
> of this book**." (HAC §3.2.7, p. 97)

HAC contributes only the two `L`-constants (`c = (32/9)^{1/3} ≈ 1.526` SNFS,
`c = (64/9)^{1/3} ≈ 1.923` GNFS) and the one mechanistic sentence that matters for
rule 7 — *"The primary reason why the running time of the number field sieve is
smaller than that of the quadratic sieve is that the candidate smooth numbers in
the former are much smaller than those in the latter."* Those constants are the
heuristic ones already priced in `RESEARCH.md` §2 and §6; nothing new.

Lenstra–Lenstra–Lovász (1992) and Buhler–Lenstra–Pomerance (LNM 1554) were **not**
reachable from this host (Springer-walled; `cr.yp.to` has no NFS entries — probed,
all 404). Recorded as an unclosed gap, not substituted with a guess.

---

## 1. THE MACHINERY, VERBATIM, WITH ITS REGIME CONDITIONS

### 1.1 The Murphy E-value — `src/murphyE.cpp:57`

> ```
> /* Murphy's E-value is defined on pages 86 and 87 of Murphy's thesis:
>    E(f,g) = sum(rho(u_f(theta_i))*rho(u_g(theta_i)), i=1..K)
>    where theta_i = Pi/K*(i-1/2)
>    and u_f(theta_i) = (log(|F(cos(theta_i)*s^(1/2),sin(theta_i)/s^(1/2))|)
>                        + alpha_f)/log(B_f)
>    where s is the skewness, F(x,y) is the bivariate polynomial associated to f,
>    alpha_f is the alpha-value for f, B_f is the smoothness bound associated
>    to f (idem for g). */
> ```
> ```cpp
> const double x = sqrt (area * cpoly.skew);
> const double y = sqrt (area / cpoly.skew);
> const double alpha_f = get_alpha (cpoly[ALG_SIDE], B);
> const double alpha_g = get_alpha (cpoly[RAT_SIDE], B);
> for (int i = 0; i < K; i++) {
>     const double ti = PI / (double) K * ((double) i + 0.5);
>     const double xi = x * cos (ti);  const double yi = y * sin (ti);
>     double vf = log (std::abs(f(xi, yi))) + alpha_f;   vf *= one_over_logBf;
>     double vg = log (std::abs(g(xi, yi))) + alpha_g;   vg *= one_over_logBg;
>     E += dickman_rho (vf) * dickman_rho (vg);
> }
> return E / (double) K;
> ```

**Regime conditions, verbatim:** `src/murphyE.hpp:28` — `#define MURPHY_K 1000`.
`src/area.hpp` — `#define BOUND_F 1e7`, `#define BOUND_G 5e6`, `#define AREA 1e16`,
`DEFAULT_ROPTEFFORT 5.0`. `src/polyselect_alpha.h:9-13` — `#define ALPHA_BOUND_SMALL 100`,
`#define ALPHA_BOUND 2000`.

### 1.2 The alpha value — `src/polyselect_alpha.cpp:222`

> ```cpp
> /* Compute the value alpha(F) from Murphy's thesis, page 49:
>    alpha(F) = sum(prime p <= B, (1 - q_p*p/(p+1)) log(p)/(p-1))
>    where q_p is the number of roots of F mod p, including the number of
>    projective roots (i.e., the zeros of the reciprocal polynomial mod p).
>    alpha(F) is an estimate of the average logarithm of the part removed
>    from sieving, compared to a random integer.
>    We want alpha as small as possible, i.e. alpha negative with a large
>    absolute value. Typical good values are alpha=-4, -5, ... */
> ```

and the special case it folds in (`:148`):

> ```
> A special case when:
> (a) p^2 does not divide disc(f),
> (b) p does not divide lc(f),
> then the average valuation is (p q_p - 1)/(p^2 - 1), where q_p is the number
> of roots of f mod p. When q_p=1, we get 1/(p+1).
> ```

For a **linear** `f` (which is every NFS rational-side polynomial `g`), `:232`:

> ```cpp
> /* for F linear, we have q_p = 1 for all p, thus
>    alpha(F) = sum(prime p <= B, log(p)/(p^2-1)) ~ 0.569959993064325 */
> ```

### 1.3 The score that is actually maximised — `src/polyselect.cpp:337`

> ```cpp
> double exp_E = logmu + expected_rotation_gain(f, g);
> polyselect_priority_queue_push(stats->best_exp_E, exp_E);
> ```

with `expected_rotation_gain` (`src/auxiliary.cpp:346`) and its embedded assumption:

> ```cpp
> double expected_rotation_gain (mpz_poly_srcptr f, mpz_poly_srcptr g) {
>   double S = 1.0, s, incr = 0.0;
>   double proj_alpha = get_alpha_projective (f, ALPHA_BOUND_SMALL);
>   double skew = L2_skewness (f);
>   double n = L2_lognorm (f, skew);
>   for (int i = 0; 2 * i < f->deg; i++) {
>       expected_growth (&r, f, g, i, n + NORM_MARGIN, skew);
>       s = r.kmax - r.kmin + 1.0;  S *= s;
>       /* assume each non-zero rotation increases on average by NORM_MARGIN/2 */
>       if (s >= 2.0)  incr += NORM_MARGIN / 2.0;
>   }
>   return proj_alpha + expected_alpha (log(S)) + incr;
> }
> ```

`NORM_MARGIN = 0.2` (`auxiliary.hpp:84`). **The maximised quantity is a
size-plus-rotation surrogate, not the MurphyE**, and it contains a hard-coded
constant-factor assumption about rotation gain, flagged in the source's own
comment.

### 1.4 The time/goal prediction is a Weibull fit — `src/polyselect_main_data.cpp:233`

> ```cpp
> /* estimate the parameters of a Weibull distribution for E */
> polyselect_data_series_estimate_weibull_moments2(&beta, &eta, exp_E);
> ...
> prob = time_so_far / (maxtime * n);
> double E = eta * pow(-log(1 - prob), 1.0 / beta);
> polyselect_data_series_ptr best_exp_E_Weibull = stats->best_exp_E_Weibull;
> polyselect_data_series_add(best_exp_E_Weibull, E);
> /* since the values of (eta,beta) fluctuate a lot, because
>    they depend on the random samples in estimate_weibull_moments2,
>    we take the average value for best_exp_E */
> ```

So the *search-distribution* half of polynomial selection is a two-parameter
empirical fit, with the implementation commenting that its own parameters
"fluctuate a lot".

### 1.5 The paid parameters, from the data files

`rsa704.poly` and `rsa155.poly` record the bounds actually used in a real
factorization. `rsa704.poly` in full:

> ```
> # MurphyE: 9.55e-16 (Bf=10000000, Bg=5000000, area=1.00e+16)
> rlim: 250000000      alim: 500000000
> lpbr: 33             lpba: 33
> mfbr: 66             mfba: 99
> rlambda: 2.1         alambda: 3.2
> ```

**Not one of `rlim, alim, lpbr, lpba, mfbr, mfba, rlambda, alambda` appears
anywhere in `murphyE.cpp`.** The model of record has no parameter for the
large-prime bound, the medium-prime bound, the medium-prime exponent split, or
the λ thresholds. §4 prices this.

---

## 2. INSTRUMENT VALIDATION — 20/20 PASS, reported before any number

`validate.py` (log `val.log`). The reference is **CADO-NFS's own printed output**
in the 40 polynomials it ships, plus one *published* factorisation.

| test | what it rules out | result |
|---|---|---|
| T0a-c | the transcription has a referent; 40 shipped polynomials | PASS |
| **T1a** | Dickman ρ is 2nd-order convergent in the grid step | max rel change under 4× coarser grid **1.58e-04** |
| **T1b** | **EXACT** Ψ(X,X^{1/u})/X vs ρ(u), u fixed, three X | ratio > 1 always and **decreases toward 1**: u=2 1.160→1.122→1.103; u=3 1.796→1.487→1.446; u=4 6.138→3.682→2.646; u=5 16.67→11.57→9.23 |
| T1c | Picard iteration reached a fixed point | deltas → 0 |
| **T2a** | **MUTATION: rectangle-rule Picard** — *the bug I actually hit* | caught, rel err **5.79e-04** |
| **T2b** | **MUTATION: ρ → 1/u²** | caught, rel err **1.41e+03** |
| T3a | two independent discriminant routes (sympy vs resultant) agree | PASS |
| **T3b** | **rsa155 disc == the published factorisation** in the file's own comment | **EXACT** `2⁸3⁹5³7·19 × 5 large primes` |
| T3c | discriminant agreement on all 40 polynomials | 0 mismatches |
| T3d | MUTATION `disc → |disc|` | caught by T3b (sign-sensitive) |
| **T4a** | **α vs CADO's own printed α** (c220) | mine **−9.9415** vs printed **−9.94**, \|diff\| 0.002 |
| **T4b** | **α_proj vs CADO's own printed α_proj** | mine **−2.3267** vs printed **−2.33**, \|diff\| 0.003 |
| **T5a** | **MurphyE vs CADO's own printed MurphyE, 36 polynomials** | **PASS, worst rel diff 5.29e-03** |
| **T6a** | **MUTATION: wrong bivariate convention** `F = f(xy)` | caught, rel diff **1.000** |
| **T6b** | **MUTATION: α → 0** | caught, rel diff **0.819** |
| **T6c** | **MUTATION: drop the skew scaling** `x=y=√area` | caught, rel diff **0.998** |
| **T6d** | **MUTATION: K = 1** (torus average → one point) | caught, rel diff **0.115** |
| T7a | L2 lognorm vs CADO printed | 62.87 vs 62.47 |

**T5 is the load-bearing one.** Reproducing 36 independent production numbers
across degree 4, 5 and 6 to better than 0.6% validates, *jointly*, the bivariate
convention, the α computation, the Dickman function over u ≈ 5–25, the torus
average and the K = 1000 discretisation. It is validated by the code that runs the
record, not by a textbook.

**Four instrument defects, all caught, three of them by tests with power:**

1. **Rectangle rule in the Picard integral** (my first Dickman). Caught by T1a/T2a:
   the trapezoid rule reproduces ρ(3) to 4e-9, the rectangle rule is 6e-2 out at
   a coarse grid.
2. **My own published-table entries for ρ(7), ρ(8) were wrong** (8.5667e-7,
   3.0379e-8 — the correct values are 8.746e-7, 3.232e-8, stable across
   h = 10⁻³…3·10⁻⁶). Recorded because it is the exact failure rule (5) exists to
   prevent, committed by me, against my own rule.
3. **The "independent" discriminant route omitted `res(f,f')/lc(f)`** — caught by
   T3a, which is the only reason T3a exists.
4. **`special_valuation_affine` carried a `p_divides_lc` reciprocal term that
   belongs to `special_valuation` only.** Caught by T4b (returned 0.000 where
   CADO prints −2.33). Re-read from `polyselect_alpha.cpp:296-303`: the affine
   function does not even *declare* `p_divides_lc`. That missing reciprocal term
   **is** the projective contribution. This bug did **not** affect T5, because
   `get_alpha` (the one inside MurphyE) was correct.

Also fixed: a sparse-coefficient parse failure on `F9.poly` (an SNFS polynomial,
`f = 4x⁵+1`, `g = −x + 5070602400912917605986812821504`, skew 1.0) — `c1..c4` are
zero and omitted, so the parser must not assume dense coefficients.

---

## 3. THE PAID TERM — POSITIVE RESULT

Define the balance ratio
  **R = [ (π(B_f) + |FB(K,B_g)|) / MurphyE ] / area**.

`R = 1` means the shipped operating point is exactly the fixed point of the
model. `π(B_f)` uses the prime-counting asymptotic (B_f reaches 8·10⁸; the FB term
is measured exactly, §4, to 2%).

**R is BIMODAL, so it is reported as two clusters and never as a mean ± sd.** The
split is *not* fitted post hoc: it is read off the data files by asking whether
`B_f` and `B_g` are powers of two to within 0.1% — which is what a
machine-generated bound is, and which a hand-set bound is not.

| cluster | n | mean R | **between-instance sd** | range |
|---|---|---|---|---|
| **bounds are powers of 2** (machine-generated) | **15** | **0.996** | **0.155** | [0.82, 1.44] |
| bounds are not powers of 2 (hand-set) | 21 | 17.822 | 17.658 | [0.77, 80.67] |

Machine-generated members: c95, c100, c105, c110, c115, c120, c125, c130, c135,
c140, c143, c148, c153, c158, c163.
Hand-set members: c60, c65, c70, c75, c80, c85, c90, c145, c150, c155, c160,
c165, c170, c175, c180, c185, c190, c195, c200, c210, c220.

> **THE PAID TERM OF NFS RELATION COLLECTION IS THE SIEVING AREA, AND IT IS
> `area = (π(B_f) + |FB(K,B_g)|) / MurphyE`.** This is not a fit: it is an
> identity the shipped operating points already satisfy, to **0.996 ± 0.155**
> (between-instance sd, one instance per row, n = 15) across degree 4, 5, 6 and
> `B_f` from 9.6·10⁴ to 2.2·10⁹. The spread is 15%, and the FB term feeding it is
> exact.

The area is the number of lattice points `(a,b)` the sieve visits. It is the
payment, and note the structural point: **`area` is an argument to the model, not
an output of it** (`murphyE.cpp` takes `area` as a parameter; it enters the torus
scaling as `√(area·skew)` and `√(area/skew)`), and it therefore appears on **both
sides** of the balance. The operating point is a *fixed point* of the model.

---

## 4. THE CONJECTURAL INPUT — AND IT IS NOT ONE INPUT

NFS smoothness needs **four** unmeasured steps, not the one `RESEARCH.md` §8.3
already names. Three of them are new to the record.

1. **The Dickman density itself**, for the structured sequences `F(a,b)` and
   `G(a,b)`. This is the already-known one: Greg Martin's conjecture, quoted in
   `RESEARCH.md` (Granville MSRI Publ. 44, eq. 1.20) and correctly labelled there
   as conjectural for `k ≥ 2`.
2. **The torus angular average.** `E = (1/K) Σ_i ρ(u_f(θ_i))ρ(u_g(θ_i))` replaces
   an average of a non-smooth integrand over the curve `F(x,y) = const` by a
   `K = 1000`-point quadrature. **This is a separate equidistribution assumption
   about a *function of* the smooth values*, not a statement about the smooth
   values.** It is not in `RESEARCH.md`. Mutation T6d shows it is worth 11.5% of
   the model value at K = 1 on `c220`, and the error is not obviously smaller at
   K = 1000.
3. **The α average.** `q_p` is the *average* p-adic valuation of `F(a,b)` over
   coprime `(a,b)`, from Murphy's thesis p. 49 via a Hanrot p-adic recursion
   (`polyselect_alpha.cpp:41`). A genuine average over a lattice, and defensible —
   but it too is transferred to the torus by the same substitution.
4. **The Weibull calibration of the search distribution** (§1.4), which is
   explicitly empirical, with the source noting its parameters fluctuate.

**And the model is evaluated where the money is not.** `rsa704.poly` prints

> `# MurphyE: 9.55e-16 (Bf=10000000, Bg=5000000, area=1.00e+16)`

at the `area.hpp` **defaults**, while the same file records
`rlim: 250000000, alim: 500000000` — the bounds the factorization actually paid
for, **25× and 100× larger**. Re-evaluating the same model at the paid bounds
(this round's validated instrument, same polynomial, same area):

| point | MurphyE |
|---|---|
| printed in the file, at the defaults | **9.55e-16** |
| re-evaluated at `rlim`/`alim` | **1.4697e-11** |
| ratio | **15 390×** |

The smoothness density the record file advertises is four orders of magnitude
smaller than the one at the operating point that was paid for. And the LP/MP
machinery that `rsa704.poly` *does* record — `lpbr 33`, `mfbr 66`, `mfba 99`,
`alambda 3.2` — has **no parameter in `murphyE.cpp` at all**. The large-prime and
medium-prime variants are the second paid order term of NFS relation collection
and the model of record does not contain them. This is the concrete NFS
counterpart of round 43's LP-QS finding, and unlike round 43 it is not a
decoupling question: it is a question of whether the model is the model.

---

## 5. THE ROUND-42 ANALOGUE — MEASURED, AND IT DOES NOT EXIST

Round 42 found the QS paid sieve work governed by a **per-instance structural
quantity**: the split prime set `Q = {p ≤ B : (N/p) = +1}`.

The NFS counterpart is the **algebraic factor base**
  `FB(K,B) = { prime ideals 𝔭 of O_K : N𝔭 ≤ B }`,
and the natural hypothesis is that it is governed by the **root discriminant of
the chosen field** — a per-instance structural quantity of exactly the same kind
(a splitting density determined by the instance).

**The hypothesis is false, and it is falsifiable exactly.** For each prime `p`,
the ideals of `O_K` above `p` correspond to the irreducible factors of `f mod p`,
a factor of degree `e` giving an ideal of norm `p^e`. So

  |FB(K,B)| = Σ over primes p ≤ B of #{e_i : p^{e_i} ≤ B}

is **exact combinatorics** — no smoothness, no distribution, nothing conjectural.
Measured on all 40 shipped fields at B = 2·10⁴ (log `per_instance.log`; the
mean and sd are over all 40, one instance per row — the per-degree rows are
in that log):

| degree | n | mean \|FB\|/π(B) | between-instance sd | range |
|---|---|---|---|---|
| 4 | 8 | 1.0235 | 0.0227 | [0.9819, 1.0570] |
| 5 | 28 | 1.0239 | 0.0211 | [0.9660, 1.0694] |
| 6 | 4 | 1.0384 | 0.0138 | [1.0239, 1.0531] |
| **all** | **40** | **1.0253** | **0.0209** | [0.9660, 1.0694] |

**The algebraic factor base is `π(B) × (1.025 ± 0.021)`, and that is true of every
field.** The instances span signed root discriminants from
−1.5·10¹⁶ (`c60`) to +3.5·10⁴⁸ (`rsa768`) — 32 orders of magnitude — and the
ratio does not move. There is no degree effect (d=4/5/6 means agree to 1.5 sd at
n = 4, 8, 28).

The reason is Chebotarev, and it is not an artefact: the average number of
degree-1 prime ideals above `p` is **1** for *any* number field. So the leading
coefficient of the paid term's FB factor is field-free by theorem. The
field-dependent part is the higher-residue-degree correction, and it has the
predicted size — counted **directly** (not as a difference of two nearly equal
large numbers, which is pure noise at this precision and was my first, wrong
attempt):

| instance | f≥2 ideals @2·10⁴ | @6·10⁴ | ratio | predicted `√B/log B` ratio |
|---|---|---|---|---|
| c60 (d=4) | 17 | 31 | 1.82 | 1.559 |
| c65 (d=4) | 12 | 21 | 1.75 | |
| c95 (d=4) | 17 | 29 | 1.71 | |
| c100 (d=5) | 18 | 31 | 1.72 | |
| c105 (d=5) | 17 | 23 | 1.35 | |
| c150 (d=5) | 8 | 22 | 2.75 | |
| c220 (d=6) | 20 | 26 | 1.30 | |

observed excess ratio over the 7 instances: **mean 1.772, between-instance sd
0.477**, against the predicted **1.559** — i.e. consistent with `O(√B/log B)`
and not with anything larger. Right order, right scaling. **`O(√B/log B)` is a lower-order
term, and lower-order terms are not levers.**

> **THE ROUND-42 ANALOGUE IS MEASURED AND ABSENT.** In QS, `Q` is a
> per-instance quantity and the paid work moves with it. In NFS, the counterpart
> is asymptotically field-independent, so the field cannot be chosen to move the
> paid work. **Field selection is not a paid term.** It buys a *constant* in the
> `L`-estimate — which is exactly Coppersmith's 1.9230 → 1.9019, and exactly the
> `RESEARCH.md` §6 statement that "arity buys the constant `c`, never the
> exponent". This round puts a measured quantity behind that sentence for the
> first time, from the other side.

### 5.1 The direction check (rule e), stated explicitly

The inequality in §3 **points toward cost**: more columns required ⇒ more area
paid, with MurphyE as the multiplier. It is not a rank-vs-work confusion. And the
one candidate lever, `Q → |FB|`, has the wrong sign to matter: the field-dependent
part of `|FB|` is +2.5%, positive, and a factor of 32 orders of magnitude in
`Dr` does not touch it. Both halves of the L[1/3] balance (columns required, and
the rate `MurphyE` at which they are produced) are governed by quantities that
**no choice of field moves**.

---

## 6. HOW NFS DIFFERS FROM SINGLE-POLYNOMIAL QS

Not a re-derivation of QS results. The differences that matter, each sourced above:

| | single-poly QS (rounds 41–43) | NFS (this round) |
|---|---|---|
| factor base | `{p ≤ B : (N/p) = +1}` — a **split set**, ~π(B)/2, per-instance | `{𝔭 : N𝔭 ≤ B}` — **asymptotically π(B) for every field** (measured 1.025 ± 0.021) |
| the `L`-exponent's source | one parameter `B`, one smoothness probability | **four** stacked unmeasured steps (§4), of which three are new to the record |
| smoothness integrand | one polynomial, one sequence | a **product** `ρ(u_f)ρ(u_g)` — both sides must be smooth, and they are different polynomials in the same lattice |
| the "skew" | the `A−B` form and a `2^{ω}` correction | an explicit field parameter, entering the model as `√(area·skew)`, `√(area/skew)` (T6c: 99.8% of the value) |
| relation collection | fully-smooth values, plus the LP variant (round 43) | fully-smooth values, **plus LP and MP variants whose bounds (`lpbr`,`mfbr`,`mfba`,`λ`) have no parameter in the model of record** |
| scoring | a fixed polynomial family | a **surrogate score** (`lognorm` + rotation gain) with a hard-coded gain assumption, and a **Weibull fit** for search time |
| what the operator actually sets | the sieve interval | the **area**, which is an *input* to the model and appears on both sides of the balance |

The structural asymmetry worth flagging to the next round: **in QS the factor base
is a per-instance object you must understand to price the work; in NFS the factor
base is a theorem.** NFS's whole gain is elsewhere — the field makes the
*candidates* smaller (HAC §3.2.7's own sentence), which shows up in `MurphyE`,
not in the column count. So the round-42 lever genuinely does not transfer, and
the reason is not "do not extrapolate": it is measured.

---

## 7. WHAT IS ASSUMED vs MEASURED — the honest ledger

| quantity | status | evidence |
|---|---|---|
| paid term = `area`, and `area = (π(B_f)+\|FB\|)/MurphyE` | **MEASURED** | 0.996 ± 0.155, n = 15 machine-generated real operating points |
| `\|FB(K,B)\|/π(B) = 1.025 ± 0.021` | **MEASURED, exact** | n = 40 real fields, exact combinatorics, B = 2·10⁴ |
| field-dependent part of `\|FB\|` is `O(√B/log B)` | **MEASURED** | 7 instances, two B values, direct count |
| MurphyE machinery (bivariate form, α, ρ, torus, K) | **MEASURED** against production | 36 CADO-NFS-printed values to 0.53% worst |
| ρ as the density of `F(a,b)`-smooth values | **CONJECTURAL** (Martin / Granville MSRI 44) | not this round; unchanged |
| the torus angular average at K = 1000 | **CONJECTURAL, NEW** | 11.5% of the value at K = 1; no error term in the source |
| rotation gain `= NORM_MARGIN/2` per rotation | **ASSUMED, verbatim in the source** | `auxiliary.cpp:359` |
| search-time prediction | **EMPIRICAL** (Weibull), source says params "fluctuate a lot" | `polyselect_main_data.cpp:264` |
| LP/MP variant contribution | **NOT IN THE MODEL** | `murphyE.cpp` has no such parameter; `rsa704.poly` records four |
| anything about factoring | **NOTHING** | no factoring method was found, attempted, or improved |

**Unclosed gaps, recorded rather than guessed:** Lenstra–Lenstra–Lovász (1992) and
Buhler–Lenstra–Pomerance (LNM 1554) were unreachable from this host. The
`L[1/3, (64/9)^{1/3}]` *derivation* (the "minimize `B²+E²` subject to `E²·Prob ≥
B^{1+o(1)}`" balance that `RESEARCH.md` §6 attributes to Barbulescu–Gaudry–
Kleinjung) was **not re-derived from source**; this round prices the *operating
point* the implementation actually uses, which is a different and separately
useful object. The 15 390× gap of §4 is therefore reported as *"the printed
MurphyE is not the MurphyE at the paid bounds"* — a statement about two numbers
in one file — and **not** as a refutation of the `L`-constant, which nothing here
touches.

---

## 8. MEASUREMENT PLAN (next round)

The one thing this round did **not** do is close the loop: **the predicted
`MurphyE × area` was never compared against the relations an actual sieve
produced.** Everything above compares the model against *itself* and against
operating points. The decisive experiment, and it is now cheap because the
instrument is validated:

1. **A real small NFS, end to end.** Small `N`, small `K` with a small root
   discriminant, congruences of squares, sieve in `O_K` modulo small prime ideals,
   collect relations, solve over GF(2), extract the factor. **Validate the
   factor against ground truth** (round 43's T6 pattern) — a small NFS that
   returns a verified factor is the gold standard the brief names.
2. **Then the one number that matters: `MEASURED YIELD / MurphyE × area`.** One
   instance per row, between-instance sd, ≥ 6 instances with **matched controls**
   (same `N`, same degree, two fields of visibly different root discriminant). This
   is the first direct test of step 1 of §4 in the record, and the first direct
   test of whether the torus average (step 2) is worth anything.
3. **Include the LP/MP variants in the same instance**, so the gap between
   `MurphyE × area` and the *usable* relation count is attributed rather than
   merely noted. `rsa704.poly`'s `lpbr/mfbr/mfba/λ` are the template.
4. **Then vary only the field**, holding `N` and the operating point fixed, and
   re-run the §5 table. If `|FB|/π(B)` really is flat and the yield really is
   governed by `MurphyE`, field choice moves the yield by ~nothing and the
   surface is closed on measurement rather than on Chebotarev.

If step 2 comes back within the 15% the machine-generated cluster already shows,
the paid term is fully measured and NFS is closed on the same terms QS was closed
in rounds 41–43. If it comes back an order of magnitude high (the LP/MP
hypothesis), then the model of record is missing the dominant term and *that* is
a finding about CADO-NFS's model rather than about factoring.
