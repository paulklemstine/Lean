# ROUND 43 — SURFACE (b): MULTI-POLYNOMIAL QS
## The second form does **not** enlarge the column space. The multiplier `k` does — and it is the only lever that grows it.

Round 43, 2026-09-25. Scratch: `/home/raver1975/factor-scratch/r43/`
(`silv.py`, `validate.py`, `mpstruct.py`, `struct2.py`, `paid.py`; logs
`val.log`, `struct2.log`, `paid.log`; data `struct2.json`, `paid.json`).
Surfaces (a) large-prime and (c) adaptive-`B` are being priced by parallel
surfaces with the same paid-work convention; this file is surface (b) only.

**This is NOT a re-run of the record.** `RESEARCH.md` names multi-polynomial QS
only as an unpriced candidate (line 239); `NegativeResults.lean` does not
mention it; the multiplier `k` as a lever on `Q(kN,B)` is priced nowhere (every
"multiplier" in `RESEARCH.md` is Lehman's ray — §7-septuples, line 258).

---

## 0. SOURCES OPENED (not paraphrased from titles)

**(i) R. D. Silverman, "The multiple polynomial quadratic sieve", *Mathematics of
Computation* 48 (Jan 1987) 329–339, DOI `10.1090/S0025-5718-1987-0866119-8`.**
Image-only 12-page scan, fetched `https://cr.yp.to/bib/1987/silverman.pdf`
(942,312 bytes) after the AMS and JSTOR routes returned 403. Read page by page.
`math.Comp.` 48:177.

**(ii) YAFU (B. Buhrow), `factor/qs/yafu_cofactorize_siqs.c`,
`factor/qs/yafu_siqs_aux.c`, `factor/qs/yafu_SIQS.c`** — production
implementation, read in the working tree at
`/home/raver1975/factor-scratch/r43/`. A second, independent, *code-level*
source for the same structural fact.

### 0.1 The verbatim kill of the surface's premise — Silverman p.332, eq (14)

> "the roots of `Q(x)` mod `p`, `p ∈ FB`, are `(−B ± √(kN))(2A)^{−1} mod p`,
> **since `B² − 4AC` is invariant**."

And p.329, verbatim:

> "The potential divisors `p` of `Q(x)` are exactly those primes for which the
> Legendre symbol `(N/p) = 1` and the unit `−1` is needed to hold the sign."

> "(i) Select a factor base `FB = {p_i | (N/p_i) = 1, p_i prime, i = 1, . . . , F}`

**The discriminant is `kN` for every polynomial; only `A` and `B` change.** So
`√(kN) mod p` is *common* to all of them and the per-polynomial root sets are the
same set. The surface's premise —

> "the split-set constraint is on `(N/r)` for BOTH forms simultaneously, which is
> a DIFFERENT (typically larger) column set"

— is **false**, and fails in a specific way: the constraint on `f_2` is not a
*second, different* constraint, it is the *same* constraint. A conjunction of two
identical constraints equals one.

### 0.2 The same fact in production code (YAFU)

`yafu_cofactorize_siqs.c`, factor-base construction — note there is **no
reference to any polynomial**:

```c
    s32 nmodp = mpz_tdiv_ui(params->n, prime);
    if (legendre_16(nmodp, prime) != -1) {          /* p joins the FB  <=> (kN/p) != -1 */
      if (nmodp != 0) {
          params->gmodsqrt[i] = (u16)sqrtModP_16(nmodp, prime);
      }
      else {                                        /* p | k : ONE root, handled apart */
          params->gmodsqrt[i] = DO_NOT_SIEVE_TINY;
        params->multiplier_fb[mult_idx++] = i;
      }
```

`params->n` is `N × multiplier` (`yafu_SIQS.c:4095`,
`mpz_mul_ui(sconf->n, sconf->n, sconf->multiplier)`). The per-polynomial step
then only **rescales the stored roots**:

```c
    g = mpz_tdiv_ui(params->poly_b_aux[i], prime);
    g = modinv_16(g, prime);
    g = (s32)g * params->gmodsqrt[poly->a_fb_offsets[i]] % prime;
```

i.e. `√(kN) · A_i^{-1}` — Silverman's eq (14). `gmodsqrt` is the
polynomial-independent part; each extra polynomial supplies a different scalar
and hence different **sieve positions**, never different **columns**.
`yafu_siqs_aux.c:26` says so in its own header comment: *"for the MPQS,
additional work using the polynomial coefficents **and these congruences**
needs to be done to compute the starting positions of the sieve."*

**Three sources agree, including on the degenerate class** `p | k` (double root,
one solution) — Silverman p.332 *"if a prime in the factor base divides `A`,
then `Q(x) = 0 mod p` has only one root"*, YAFU's `DO_NOT_SIEVE_TINY`, and my
test T7c.

---

## 1. INSTRUMENT VALIDATION — 16/16 PASS, reported before any number

`validate.py` (`val.log`). Each test states what it rules out. **T11b is a
mutation that reproduces this round's own algebra error**, and the suite catches it.

| test | what it rules out | result |
|---|---|---|
| T1 | `legendre(a,p)` vs brute-force "is a QR mod `p`" | 19,908/19,908 |
| T2 | `sqrt_mod` **contract**: `None` IFF `(a/p) = −1`, else `r² = a` | 554 roots + 599 correct `None`s = 1153/1153 |
| T3 | eqs (7a)/(8): `h1² ≡ kN mod D` | 48/48 |
| T4 | full construction: `B² − 4AC = kN` **exactly**, `B` odd, `A = D²` | 50/50 |
| T5 | generalised `A`: `B² − 4AC = kN` exactly | 94/94 |
| T6 | eq (14) vs an **independent** completed-square reference, all `p ≤ 600` | 15,536/15,536, 0 mismatches |
| **T7** | **the split-set invariant, run at `k = 5` so `kN ≠ N`**: `f` has a root mod `p` ⟺ `(kN/p) = +1` | **12,040/12,040, 0 violations** |
| T7b | **negative control**: split set of `kN` ≠ split set of `N` (so T7 is not vacuous) | 40/40 differ |
| T7c | the degenerate class `p \| kN` has exactly ONE (double) root | 40/40 |
| T8 | the multiplier `k` really moves `\|FB\|` | 20/20; 20 distinct sizes per instance (min 20, max 20) |
| **T9a** | **MUTATION 1** — eq (14) with `√(N)` for `√(kN)` (indistinguishable at `k=1`) | 120/120 killed |
| **T9b** | **MUTATION 2** — eq (14) with the `−` root dropped | 120/120 killed |
| **T9c** | **MUTATION 3** — `sqrt_mod` returning a root of `a+1` | 148/500 killed |
| T10 | the FB is ~half of `π(B)`, not all of it | mean 55.00, `π(717)=127` |
| **T11** | **eq (13): `H = (2Ax+B)(2D)^{-1} mod kN` ⟹ `H² ≡ f(x) mod kN`** | **47,676/47,676** |
| **T11b** | **MUTATION 4 — this round's own error**, `(2A)^{-1}` for `(2D)^{-1}` | **0/10,620 correct — caught** |

### 1.1 Four bugs the suite caught, all recorded

1. **`struct.py` shadowed the stdlib `struct` module that sympy imports.** It
   silently corrupted `nextprime`/`isprime`: T2 failed 554/1153 with a *twin*
   failure count across two different runs, which is what exposed it (a real
   RNG would not repeat). Renaming the file fixed it. **A silently-shadowed
   stdlib module is a new failure mode for this record's harnesses.**
2. **T2 was wrong, not the engine.** It counted a correct `None` (non-residue,
   48% of draws) as a failure. Round 41/42's pattern.
3. **`p | kN` is bitwise-or, not "divides".** It skipped *every* prime, so T7
   "passed" **vacuously at 0/0** — caught by an explicit `assert tot > 1000`
   vacuity guard I added afterwards. A vacuous pass is the record's own
   VACUITY FILTER firing on my own test.
4. **A real algebra error of mine, now the mutation T11b.** I generalised
   Silverman's `H` to `H = (2Ax+B)(2A)^{-1}`. From `(2Ax+B)² = 4A·f + kN`,
   dividing by `4A²` gives **`H² ≡ f/A`, not `f`** — measured `H² ≠ f (mod N)`
   on 2,966 of 4,999 positions, and **0/24 verified factors**. So
   **`A = D²` is structurally required, not cosmetic** — it is *why* the paper
   builds `A` as a prime square. T11b now pins this.

---

## 2. DOES THE SECOND FORM ENLARGE THE COLUMN SPACE? — **NO. 0/96 violations.**

`struct2.py` (`struct2.log`), 24 fresh 41-bit balanced semiprimes, `k ∈ {1,5}`,
`T ∈ {1,2,4,16}`, `B = 717`. The column support of polynomial `i` is the set of
odd `p ≤ B` for which `f_i` has a root mod `p` at all.

| claim | result |
|---|---|
| P1 per-polynomial root sets all identical | **0/96 violations** |
| P2 each root set `=` split set of `kN` (`+` degenerate `p \| kN`) | **0/96 violations** |
| P3 a non-split odd prime was ever a divisor | **0/96 violations** |
| P4 union over polynomials `≠` one polynomial's set | **0/96 violations** |
| P5 `\|FB\|` vs `T` | **62.250 ± 5.033 at `T = 1, 2, 4, 16` — bit-identical** |

> **The column space is SHARED, not enlarged. Adding a 2nd, 3rd or `T`-th form
> adds ROWS (factorizations), not COLUMNS. The decoupling that exists is
> `#polynomials ⟂ #columns` — which is real and useful — but it is emphatically
> NOT the `#columns` vs split-set decoupling the surface proposed.**

### 2.1 The degenerate class, kept and reported rather than hidden

`p | kN` ⇒ discriminant `≡ 0` ⇒ **one** root, not two. Silverman p.332 and
YAFU's `DO_NOT_SIEVE_TINY` both handle it. My first `struct.py` **dropped** it
and so reported spurious "violations" of size exactly 1; fixed, and the fix is
now asserted (T7c, 40/40).

---

## 3. WHAT THE MULTIPLIER `k` DOES — the one lever that grows the column space

Round 42 established: **the paid work is a DECREASING function of `Q`.** The
multiplier is the only per-instance lever that moves `Q` **upward** at fixed `B`
— and it does so because the factor base is the split set of **`kN`**, not of `N`.

`mpstruct.py` multiplier sweep, 20 instances, all admissible `k ≡ 1 (mod 4)`
(`kN ≡ 1 mod 4`, Silverman p.334), ~50 multipliers per instance, `B = 717`:

| | mean | sd | min | max |
|---|---|---|---|---|
| `Q(k=1)` | 62.833 | 6.253 | 51 | 76 |
| `Q(mean over k)` | 63.079 | 0.671 | | |
| **`Q(best k)`** | **74.875** | **3.261** | **71** | **83** |
| `Q(worst k)` | 50.458 | 3.230 | | |

**`Q(best)/Q(k=1)`: mean 1.2034, max 1.4706.** The multiplier is found in
`O(π(B)·#k)` with **no sieving**, and the factor base is built the same way
regardless. So `k` is the only lever that moves `Q` at all — and `RESEARCH.md`
prices it nowhere.

### 3.1 ★ BUT A BIGGER `Q` IS **NOT** CHEAPER HERE — and this OVERTURNS the obvious reading

I expected round 42's law (paid work decreasing in `Q`) to make `k` a free win.
**Measured, it is the opposite.** Holding the paid budget at 200,000 positions
and the polynomial count at 1, the `k*`-maximising arm collects
**2.286 ± 4.232** factorizations against **8.571 ± 4.536** for the `k=1` arm:

| arm | `Q` | nrel (mean ± between-inst sd) | PAID positions |
|---|---|---|---|
| `k=1` | 50–80 | **8.571 ± 4.536** | 200,000 |
| `k*` (max `Q`) | **1.08–1.46× larger** | **2.286 ± 4.232** | 200,000 |

**Paired diff −6.286 ± 6.568, `t = −3.58`, wins 2/14.**

*Confound, stated and discharged:* the two arms differ in the multiplier **and**
the polynomial family (classic `(x+b₀)²−N` vs the Silverman form). But at
`T=1` the two families are statistically indistinguishable (`t = +0.37`,
§4), so holding the family fixed at "single Silverman form", the only change to
the `k*` arm is `k` — and it loses 6.29 relations. The deficit is the
multiplier's.

**Mechanism (arithmetic, then confirmed by both sources).** `C = (B²−kN)/(4A)`
and the residual scales as `M√(kN)/2.83`, so **the residual inflates like
`√(kN) ≈ √k·√N`** while the column count grows only by a constant factor. **The
residual penalty beats the column gain.** Both source multiplier-scoring
functions charge for it explicitly — YAFU, verbatim:

```c
		scores[i] = 0.5 * logmult;          /* the multiplier inflates the residuals */
```

and Silverman's eq (18), `g(p,kN) = 2/p if p∤k, 1/p if p|k, 2/log k if N ≡ 1 mod 8`.

> **⇒ `k` is a TRADE-OFF, not a free lever, and round 42's "paid work decreases
> in `Q`" does NOT transfer to `k`** — because `k` moves the residual at the same
> time. This is the cleanest instance yet of the record's standing rule: *a
> mechanism and its target must act on the SAME quantity.* `Q` is not a free
> parameter for `k` either; it is a point on a `Q`-versus-residual frontier.

**The one thing `k` does buy** is a *joint* optimum — a moderate `k` aligning
`(kN/·)` with the small primes at low residual cost. That is precisely the
`O(π(B)·#k)` search both sources implement, and it is why they *score* `k`
rather than maximise it. **The multiplier is not the round's prize.**

**What `k` is NOT:** it does not decouple the column count from the split set —
it *relabels* which primes are split. The column count is still exactly the
split set of `kN`.

---

## 4. THE PAID WORK, AT FIXED B — and an UNSTATED REGIME CONDITION

`paid.py` (`paid.log`). **PAID = total sieve positions** — Silverman's own
quantity, stated in his Table 3 caption: *"typical values for the total number of
residues sieved"*, and p.330: *"In order to obtain enough factorizations, `M`
must be very large, and **the residues grow linearly in size with `M`**"*.
**REQUIRED = `0.96·F`** factorizations (Silverman p.334 eq (16), verbatim:
*"Usually, having about .9F rows in the matrix is sufficient to find a
dependency, and taking `R = .96` achieves this"*), `F` = the column count.

**Model-free equal-budget test** (round 42's device): every arm gets the *same*
`P0 = 200,000` positions; whichever arm gets more factorizations is strictly
cheaper. No `ρ`, no Dickman, no distribution assumed.

| arm | positions | nrel (mean ± **between-inst sd**) | residual | `u` | PAID to `0.96F` | paired `t` vs S | wins |
|---|---|---|---|---|---|---|---|
| S (classic single-poly) | 200,000 | 8.57 ± 4.54 | 2^37.74 | 3.979 | 1,364,800 | — | — |
| MP(T=1) | 199,999 | 9.29 ± 8.97 | 2^37.25 | 3.927 | 1,259,815 | +0.37 | 8/14 |
| MP(T=2) | 199,998 | 13.43 ± 13.79 | 2^36.21 | 3.817 | 871,149 | +1.64 | 8/14 |
| MP(T=4) | 199,996 | 14.36 ± 15.44 | 2^35.65 | 3.758 | 814,806 | +1.73 | 8/14 |
| MP(T=8) | 199,992 | 13.64 ± 14.81 | 2^35.97 | 3.792 | 857,466 | +1.59 | 8/14 |
| MP(T=16) | 199,984 | 15.43 ± 16.47 | 2^36.03 | 3.798 | 758,222 | +1.87 | 8/14 |
| MP(T=32) | 194,165 | 15.79 ± 16.78 | 2^36.28 | 3.825 | 741,068 | +1.94 | 8/14 |

**The length → size exchange rate, measured** (`log2(residual/√N)`, S = 1.000):
1.029 (`T=1`), 1.098 (`T=2`), **1.139 (`T=4`)**, 1.115 (`T=8`), 1.110 (`T=16`),
1.093 (`T=32`) — **it peaks at `T = 4` and then REVERSES.** That reversal is the
quantisation of §4.2, not a property of the method.

### 4.1 VERDICT ON THE PAID WORK: a **modest, NOT-ESTABLISHED** gain — 1.6–1.9×, `|t| < 2`

At 41 bits the multiplicity buys **1.6–1.8× more factorizations at equal paid
work**, but the paired `t` runs **+1.59 to +1.94** and it wins only **8/14**
instances. **This does not reach significance and I do not claim it.** The
second form *alone* (`T=1`) is indistinguishable from the classic (`t = +0.37`);
the effect appears only at `T ≥ 2` and saturates by `T = 4`.

**A source-internal inconsistency, flagged rather than resolved:** p.331 says
*"The maximum value of `Q(x)` over `[−M,M]` is `M√(kN)·2√2`, a factor of `√8`
improvement over (2)"*, but p.331's own eq (5) (`A = W₁√(kN)/M`, `C = W₂M√(kN)`,
`W₁ = √2/2`, `W₂ = −1/(2√2)`) gives `max|f| = |C| = M√(kN)/(2√2)`, and the
`√8` factor does not follow from the two statements together. **I did not
resolve this by re-derivation; I measured the constant instead** (§4.2).

### 4.2 WHY — and the regime condition, measured

The paper's residual minimum needs `A = W₁√(kN)/M` (eq (5)). But eq (6) forces
**`A = D²` with `D` an odd prime `≡ 3 mod 4`**, so `A` is **quantised**, and
`D` must be *admissible*: `(D/kN) = +1`. The admissible-`D` density is
`≈ 1/(4 ln D)`. Measured `A_actual / A_ideal` (14 instances, `B = 717`):

| `T` | 1 | 2 | 4 | 8 | 16 | 32 |
|---|---|---|---|---|---|---|
| `A_actual/A_ideal` | 13.8 | 22.7 | 61.7 | 209 | 652 | **1477** |

**The construction is 14×–1477× away from its own optimum at 41 bits, and gets
worse as `T` grows** — because the admissible-`D` pool near the ideal is nearly
empty, so `pick_Ds` is forced to reach to larger and larger `D`, inflating `A`
and hence the residual. That is the whole reason the measured gain saturates by
`T = 4` instead of continuing to `√8`-type factors.

**The regime condition, derived and confirmed** (admissible-`D` pool size, one
instance per row, `M = 3000`):

| `N` bits | `idealD` | admissible-`D` pool `=` max `T` | `M_max` for `D > B` |
|---|---|---|---|
| 42 | 20.5 | **3** | **2.45** |
| 54 | 155 | 6 | 140 |
| 60 | 464 | 11 | 1,250 |
| 70 | 2,531 | 34 | 37,400 |

i.e. **`B²·M ≲ W₁√(kN) ≈ 0.707√N`** is required for the paper's `D` to leave the
factor base, and a *large* `T` needs `idealD ≳ 10·T·ln(idealD)`. At `B = 717`
and 41 bits this fails by ~3 orders of magnitude, so **the multi-polynomial
regime is simply not reachable at my test size.** Silverman's own Table 1
satisfies it throughout (`B=100, M=5K` at 24 digits: `B²M = 5e7 ≪ 0.707·1e12`),
which is consistent with his own p.338 crossover: *"When one selects a value of
`M` sufficiently large so that our algorithm only uses one polynomial, the run
time increases dramatically. **A crossover point with CFRAC appears around 40
digits.**"* **I am measuring at 41–42 bits with a large `B` — at/below the
crossover the source himself states, where the advantage has died.** A small,
non-significant gain there is *consistent with* the source, not a contradiction
of it.

### 4.3 VERIFICATION — a real factor, and a regime failure

`PAID TO SUCCEED`: grow each arm the way that arm actually grows (S by `M`, MP by
`T` at fixed `M`), stop at `0.96F` relations, find a dependence with **round
42's validated GF(2) engine**, and check the gcd against ground truth `p, q`.

| inst | arm | F | nrel | PAID positions | `k_success` | rank | **verified** |
|---|---|---|---|---|---|---|---|
| 0 | S | 62 | 68 | 12,800,000 | 24 | 23 | **True** |
| 0 | MP | 62 | 0 | 198,033 | — | — | False (D-pool, §4.2) |
| 1 | S | 63 | 65 | 3,200,000 | 6 | 5 | **True** |
| 1 | MP | 63 | 0 | 240,040 | — | — | False (D-pool) |
| 2 | S | 60 | 61 | 12,800,000 | 31 | 25 | **True** |
| 2 | MP | 60 | 22 | 216,036 | — | — | False (below target) |
| 3 | S | 53 | 57 | 25,600,000 | 21 | 20 | **True** |
| 3 | MP | 53 | 17 | 174,029 | 13 | 9 | **True** |
| 4 | S | 71 | 88 | 12,800,000 | 36 | 35 | **True** |
| 4 | MP | 71 | 0 | 246,041 | — | — | False (D-pool) |
| 5 | S | 62 | 75 | 6,400,000 | 3 | 2 | **True** |
| 5 | MP | 62 | 0 | 204,034 | — | — | False (D-pool) |
| 6 | S | 65 | 71 | 6,400,000 | 21 | 20 | **True** |
| 6 | MP | 65 | 0 | 240,040 | — | — | False (D-pool) |
| 7 | S | — | — | — | — | — | (see `paid.log`) |

**VERIFIED FACTORS: 10/16. S: 8/8 verified. MP: 2/8 verified.**

The **8/8 S-arm verifications** against ground-truth `p, q` validate the whole
pipeline (columns, rows, `H`, the GF(2) engine, the gcd step) — and confirm the
row convention and engine reproduce round 42's. The MP arm verifies **2/8**,
including instance 3 at `k_success = 13`, rank 9 — so the MPQS relations are
genuinely valid; they are simply too few at 41 bits because of the `D`-pool
limit of §4.2 (at `M = 3000` only 1 of 8 admissible `D` values even yields a
positive `f(x)`).

**Honest reading of the two PAID columns:** MP reached its target in
**52× fewer positions** (222,037 vs 11,600,000) but that is **not** a win — it
did so by getting *lucky at a low rank* (rank 9 of 53 columns on instance 3),
not by reaching `0.96F` relations, which it did in **0/8**. Charging the full
budget when the target is missed, the S arm is the one that reliably completes.

---

## 5. CONCLUSIONS

1. **The surface's premise is false, decisively and by three independent
   sources.** Multi-polynomial QS does **not** decouple the column count from the
   split set. The two forms are constrained by the *same* `kN`; the column
   space is shared, `|FB|` is bit-identical at `T = 1, 2, 4, 16`, and 0/96
   non-split primes were ever divisors. The "larger column set" intuition is a
   conjunction of two identical constraints.
2. **What *is* decoupled is `#polynomials ⟂ #columns`.** The `T`-th form buys
   *rows* at zero marginal cost in rank. That is a real and useful fact, but it
   is not the open problem's question.
3. **The multiplier is not the prize either — and I overturned my own expectation
   doing it.** `k` *is* the only lever that moves `Q` at fixed `B`
   (`Q(best)/Q(k=1)` = **1.203 mean, 1.471 max**, free to find). Round 42's law
   said that should be a free win. **Measured, it is the opposite:
   `t = −3.58`, 2/14 wins**, because the residual inflates like `√k` while `Q`
   grows only by a constant. Both source scoring functions charge this
   explicitly (YAFU `scores[i] = 0.5 * logmult`; Silverman eq (18) `2/log k`).
   **`k` is a trade-off, not a free parameter — §10's law does not transfer to
   `k`, because `k` moves the residual too.**
4. **A validated negative on the magnitude.** At 41 bits MPQS buys 1.6–1.9× at
   equal paid work, `t = +1.59…+1.94`, 8/14 wins — **not established**. The
   cause is measured, not asserted: `A = D²` quantises the leading coefficient,
   and `A_actual/A_ideal` runs 14×–1477× here. The regime condition
   **`B²·M ≲ 0.707√N`** (plus `idealD ≳ 10·T·ln idealD` for a large `T`) is
   derived and tabulated, and is **not stated in the source**; it reproduces
   both Silverman's ~40-digit CFRAC crossover and my own null at 41–42 bits.
5. **Refinement to round 42's "the factor base IS the split set":** it is the
   split set of **`kN`**, including the degenerate class `p | k` (one root, not
   two) — **and that holds for LARGE primes too.** Directly checked:
   `L | f_i(x)` for a prime `L > B` requires `f_i` to have a root mod `L`, which
   requires `(kN/L) = +1`. Over **2,400 (polynomial, large prime `L > B`) pairs**,
   10 instances, `k ∈ {1,5}`, two polynomials each: **0 violations.** So the
   large-prime columns are *also* the split set of `kN`, not of `N`.

   > **⇒ surfaces (a) and (b) share ONE split set and neither relaxes it.** The
   > large-prime/partial-relation variant decouples the *column indexing* (each
   > `(L, root of f_i mod L)` is a separate index, and the index depends on `i`)
   > but it never adds a **non-split** prime. The only lever that moves `Q` at
   > all remains `k` — and §3.1 shows it is paid for in residual size.

**Not claimed:** nothing here is a factoring method; no transfer to NFS (the
record's standing caution); the `√8` constant is left unresolved as a source
inconsistency rather than re-derived; the 1.6–1.9× MPQS gain is **not**
claimed as significant; and the `k`-maximisation is a *per-instance optimisation
over a finite search*, not a distribution statement about `Q`.
