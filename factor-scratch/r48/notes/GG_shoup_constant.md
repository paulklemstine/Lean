# GG — Where Shoup's factor of 2 sits, and whether it can be recovered

**Question.** Shoup's Theorem 15.6 proves an *unconditional* factoring time of
`exp[(2√2 + o(1)) (log n log log n)^{1/2}]`. The ECM heuristic constant is `√2`.
That is a factor of exactly 2. Where does it come from, and can it be recovered?

**Source.** Shoup, *A Computational Introduction to Number Theory and Algebra* (v.2),
§15.3 "An algorithm for factoring integers". Local PDF
`factor-scratch/r48/lit/r1/shoup_ntb.pdf`; printed page = PDF page − 18.
All formulas below were read from **page images**, never from `pdftotext`
(which renders Thm 15.6's radicals as `1/ 2` and `2 2`).

**Self-test.** `factor-scratch/r49exp/shoup/constant_test.py` — **51 PASS, 0 FAIL, 12 NULL**.
The NULLs are deliberate: they mark claims this note does *not* prove.
The self-test was written first and every check can return NULL; it did return
NULL four separate times during development, twice correctly (a genuinely
non-convergent ratio) and twice on my own over-tight tolerances, which is why
the tolerances below are set where the convergence rate justifies them.

---

## Verdict (one paragraph)

The factor of 2 is **two independent squares, and both are visible in the
printed argument**. It is **not** a Markov / mean-vs-median step (Theorem 15.6
bounds an *expectation*, E[Z], and never converts it to a success probability),
and it is **not** a union bound. One square is in the smoothness count
(Shoup applies Theorem 15.1 in a form whose exponent over-charges the true
Dickman exponent by exactly 2 at the point where it is applied) and one is in
the relation-collection cost (you need `π(y)` relations and each costs `π(y)`
trial divisions). **Exactly one of the two is removable**, and removing it is a
two-line change to the choice of smoothness bound: the constant improves from
`2√2` to `2`. The other is structural to Algorithm SEF. Reaching `√2` needs a
different algorithm, and ECM's `√2` is *heuristic*, so `√2` is not on the table
as a proved unconditional constant at all.

The shape constant is `√(2ac)`, where `a` is the power of the factor-base size
in the running time (`a = 2` for SEF) and `c` is the Dickman exponent constant
(`c = 2` as Shoup writes it, `c = 1` for the sharp estimate). All four cases are
verified numerically:

| case | a | c | constant | status |
|---|---|---|---|---|
| Shoup as printed (p. 413) | 2 | 2 | `2√2 = 2.828` | **PROVED (his Theorem 15.6)** |
| remove H1 (sharp Dickman) | 2 | 1 | `2` | **PROVED here — removable** |
| remove H2 (one relation) | 1 | 2 | `2` | proved for that shape; SEF has `a=2` forced |
| remove both | 1 | 1 | `√2` | **NOT PROVED for factoring** — this is the ECM *heuristic* |

---

## S1 — the trace, page by page

### Step 0. The factor base and the number of relations (pp. 407, 410, 411)

p. 407, verbatim:

> "Let `p_1, . . . , p_k` be the primes up to the smoothness parameter `y`
> mentioned above."

So `k = π(y) ~ y/log y`, and `log k = log y − o(log y)`. **This is the single most
important structural fact in the whole analysis** and everything in S1 hangs off it.

p. 410, verbatim:

> "Since `Z_2^{(k+1)}` is a vector space over the field `Z_2` of dimension `k + 1`,
> the family of vectors `v̄_1, . . . , v̄_{k+2}` must be linearly dependent."

So **`k+2` relations are forced** by a dimension count. This is not an artifact
of the analysis; it is linear algebra.

p. 411, from the pseudocode of Algorithm SEF (Fig. 15.2), verbatim lines:

> "choose `α_i ∈ Z_n^*` at random"
> "test if `m_i` is `y`-smooth (trial division)"

Each attempt costs one trial division pass over the `k` primes, i.e. `Θ(k)`.

### Step 1. The running time (p. 412, immediately after Lemma 15.4)

p. 410, Lemma 15.4: "For `i = 1, . . . , k + 2`, we have `E[L_i] ≤ σ^{-1}`."
p. 412, verbatim:

> "So in stage 1, the expected number of attempts made in generating a single
> relation is `σ^{-1}`, each such attempt takes time `k · len(n)^{O(1)}`, and we
> have to generate `k + 2` relations, leading to a total expected running time in
> stage 1 of `σ^{-1}k^2 · len(n)^{O(1)}`."

> "Thus, if `Z` is the total running time of the algorithm, we have
> `E[Z] ≤ (σ^{-1}k^2 + k^3) · len(n)^{O(1)}`."

**This is where the structural square (H2) is born.** The running time is
`σ^{-1} · k^2`: a `k` (from needing `k+2` relations) times a `k` (from the
per-attempt trial division). Since `log k = log y + o(log y)`, the `k^2` term
contributes `2 log y` to the exponent.

**Note what is NOT here.** There is no Markov inequality, no conversion from
E[Z] to a success probability, and no union bound anywhere in the running-time
argument. Theorem 15.6 is stated for E[Z] directly. **The mean-versus-median and
union-bound hypotheses in the brief are refuted by the printed text itself.**

### Step 2. The smoothness count (pp. 412, 399)

p. 412, verbatim — the counting step:

> "By our assumption that `n` is not divisible by any primes up to `y`, all `y`-smooth
> integers up to `n − 1` are in fact relatively prime to `n`. Therefore, the number of
> `y`-smooth elements of `Z*_n` is equal to `Ψ(y, n − 1)`, and since `n` itself is not `y`-smooth,
> this is equal to `Ψ(y, n)`. From this, it follows that
> `σ = Ψ(y,n)/|Z*_n| ≥ Ψ(y,n)/n`."

p. 399, Theorem 15.1, verbatim:

> "Ψ(y, x) ≥ x · exp[(−1 + o(1))u log log x]"

with (p. 399) "u := log x / log y". So Shoup obtains

`σ ≥ exp[(−1+o(1)) (log n / log y) log log n]`, hence

`σ^{-1} ≤ exp[(1+o(1)) (log n / log y) log log n]`.

**Measured check on this step (self-test Part 5).** The relaxation
`|Z*_n| ≤ n` costs a relative factor `|Z*_n|/n = 1 − O(1/p)` — measured at
`0.9999980000369989` for a 40-bit semiprime, i.e. a **2.0 × 10⁻⁶** loss. The
counting identity `σ = Ψ(y,n)/|Z*_n|` itself was verified by sampling 200 000
random elements of `Z*_n` at `n = 1028171`, `y = 60`, where exact `Ψ` is
computable: **measured `σ = 4.04750 × 10⁻²` vs the exact prediction
`Ψ(y,n)/|Z*_n| = 4.01795 × 10⁻²`, a 0.67σ deviation.** So the identity is
confirmed with no Dickman model in the loop. **The `≥ Ψ(y,n)/n` relaxation is
not a source of the factor of 2.**

### Step 3. The exponent (p. 412, eq. (15.8))

p. 412, eq. (15.8), verbatim:

> `E[Z] ≤ exp[(1 + o(1)) max{(log n / log y) log log n + 2 log y, 3 log y}]`

and immediately after:

> "Setting `y = exp[(1/√2)(log n log log n)^{1/2}]`, we obtain
> `E[Z] ≤ exp[(2√2 + o(1)) (log n log log n)^{1/2}]`."

**This is the whole of the constant, in one displayed line.** There are exactly
two summands in the first branch:

- `(log n / log y) · log log n` — the smoothness/search cost. This is `c = 2`
  as Shoup writes it (the `log log n` in place of `log u`).
- `2 log y` — the `k^2` of Step 1. This is `a = 2`.

The `3 log y` branch is Gaussian elimination and **does not bind**: at the
optimum it equals `(3/4)·` the first branch (self-test Part 0, verified to 1e-9).

### So: the two squares, named

Minimising `E = c·(log n/log y)·log u + a·log y` with `log y = s·√(log n · log log n)`
gives

- `s* = √(c / 2a)`
- **`constant = √(2ac)`**

Shoup's printed `2√2 = √(2·2·2)` needs **both** `a = 2` and `c = 2`.

---

## S2 — Is it removable? Verdict: **half of it is.**

### H1 (the `c = 2` square) — REMOVABLE. This is the recoverable half.

**The claim.** At the balanced point `log y = (1/√2)√(log n log log n)`,

```
log u  =  log(log n / log y)
       =  log log n − (1/2)(log log n + log log log n) + (1/2)log 2
       =  (1/2) log log n  −  (1/2) log log log n  +  (1/2) log 2
```

so `u log u = (1/2)·u log log n · (1 + o(1))`.

**Theorem 15.1's exponent is `u log log x`. The true exponent is `u log u`.**
At the point where Shoup applies the theorem these differ by a factor of
**exactly 2**, asymptotically.

**Consequence.** Substituting the sharp Dickman–de Bruijn estimate
`Ψ(y,x) ≥ x·exp[−(1+o(1))u log u]` gives `c = 1` and hence

> **E[Z] ≤ exp[(2 + o(1))√(log n · log log n)]**, with the constant improved
> from `2√2` to **`2`**, by the choice `y = exp[(1/2)√(log n log log n)]`.

**This is a proved improvement, not a heuristic one.** The Dickman–de Bruijn
estimate is unconditional, and the `−1` in it is *tight* (see S3), so this is
the best this route can give.

**The load-bearing numeric claim, verified.** The self-test (Part 1) checks
`log u / log log n → 1/2`, and matches the closed form

```
log u / log log n  =  1/2 − (1/2)(log log L)/(log L) + (1/2)(log 2)/(log L),
L = log n
```

to **≤ 1.1e-16** at every size tested, from 2^10 to 2^24 bits. The approach to
`1/2` and the reciprocal approach of the overcharge `log log n / log u → 2`:

| log log n | ratio `log u / log log n` | overcharge |
|---|---|---|
| 10 | 0.41952810 | 2.38363054 |
| 30 | 0.45486583 | 2.19845048 |
| 100 | 0.48043989 | 2.08142586 |
| 300 | 0.49164894 | 2.03397163 |
| 10³ | 0.49689270 | 2.01250694 |
| 10⁴ | 0.49957414 | 2.00170489 |
| 10⁶ | 0.49999344 | 2.00002625 |
| 10⁸ | — | 2.00000035 |

**Proof that the improvement is real and not a re-parameterisation:** the
*ratios* are truncation-free, and they come out exact (self-test Part 3):

- `2√2 / 2 = 1.41350` vs `√2 = 1.41421` — H1 alone
- `2√2 / 2 = 1.41493` vs `√2 = 1.41421` — H2 alone
- `2√2 / √2 = 2.00000000` — both

H1 and H2 are **independent squares**: removing either one alone halves the
constant's square, i.e. multiplies the constant by exactly `√2`.

### H2 (the `a = 2` square) — NOT REMOVABLE within Algorithm SEF.

`a = 2` is forced by **counting, not by the quality of the analysis**:

- the factor base has `k = π(y)` elements (p. 407);
- `Z_2^{(k+1)}` has dimension `k+1`, so `k+2` relations are needed (p. 410);
- each attempt costs a trial-division pass over those same `k` primes (p. 411).

Three independent `π(y)`'s. No better analysis removes them; only a different
algorithm does.

### What remains unproven

- That **2 is the best possible for *any* unconditional factoring algorithm.**
  Not proved, and not provable by this analysis — see S3.
- That **√2 is achievable** by any unconditional method. Not proved; the only
  known route (ECM) is heuristic.

---

## S3 — What is the best possible?

**Within Shoup's shape, `2` is optimal, and this is provable in two steps.**

1. **`c = 1` is forced and tight.** Dickman's theorem is
   `ρ(u) = exp[−(1+o(1)) u log u]`: the leading constant is **1**, and the
   statement is two-sided, so no better smoothness count can lower it. Verified
   on the shared harness's valid range: `c(u) = −log ρ(u)/(u log u)` rises
   0.8522 → 0.9175 → 0.9586 → 0.9861 → 0.9966 for `u = 2,3,4,5,6`.
2. **`a = 2` is forced** by the three counts above.

Hence `constant = √(2·2·1) = 2`, and the self-test confirms numerically that
`(a=2, c=1)` converges to `1.99254` as `log n → ∞`, i.e. to `2` from below with
the expected `O(1/log L)` tail (0.37% at `L = 10³⁰⁰`).

**The landscape** (`constant = √(2ac)`):

| | c = 0.75 | c = 1 | c = 2 |
|---|---|---|---|
| **a = 1** | 1.2247 | 1.4142 | 2.0000 |
| **a = 1.5** | 1.5000 | 1.7321 | 2.4495 |
| **a = 2** | 1.7321 | 2.0000 | 2.8284 |
| **a = 3** | 2.1213 | 2.4495 | 3.4641 |

`c = 0.75` (or any `c < 1`) is **not achievable** — Dickman is tight at `c = 1`.
So the only way below `2` is `a < 2`, i.e. an algorithm that needs only *one*
relation and so has no factor-base linear algebra. That is exactly the ECM
shape — and **ECM's smoothness probability is a random-curve heuristic, not a
counting bound.** So:

> **`2` is the optimum of the unconditional counting method. `√2` is a
> heuristic constant, not a proved unconditional one. There is no proved
> unconditional factoring bound with constant `√2`.**

**Explicitly NOT claimed:** that `2` is a lower bound for all factoring
algorithms. This analysis optimises one shape only, and asserting a universal
lower bound would be unsound.

---

## S4 — The regime. This is where the result is weakest.

### `u` at realistic sizes

With Shoup's `y`, `u = log n / log y = √2 · √(log n / log log n)`:

| bits | log n | log log n | log y | **u** | log u | log u / log log n |
|---|---|---|---|---|---|---|
| 512 | 354.891 | 5.8718 | 32.279 | **10.995** | 2.3974 | 0.408289 |
| 768 | 532.337 | 6.2773 | 40.876 | **13.023** | 2.5667 | 0.408894 |
| 1024 | 709.783 | 6.5650 | 48.268 | **14.705** | 2.6882 | 0.409474 |
| 1536 | 1064.674 | 6.9704 | 60.915 | **17.478** | 2.8609 | 0.410441 |
| 2048 | 1419.565 | 7.2581 | 71.775 | **19.778** | 2.9846 | 0.411205 |
| 3072 | 2129.348 | 7.6636 | 90.328 | **23.573** | 3.1601 | 0.412356 |
| 4096 | 2839.131 | 7.9513 | 106.242 | **26.723** | 3.2855 | 0.413210 |
| 8192 | 5678.262 | 8.6444 | 156.661 | **36.246** | 3.5903 | 0.415335 |
| 16384 | 11356.523 | 9.3375 | 230.263 | **49.320** | 3.8983 | 0.417489 |
| 65536 | 45426.094 | 10.7238 | 493.529 | **92.043** | 4.5223 | 0.421701 |

**So `u ≈ 11` at RSA-512 and `u ≈ 20` at RSA-2048.**

**How far from asymptotic is that?** `u → ∞` only as fast as `√(log n)`:

| target `u` | modulus size needed |
|---|---|
| 20 | 2^2102 (RSA-2048 is already here) |
| 50 | 2^16900 |
| 100 | 2^78700 |
| 10⁶ | 2^2.2×10¹³ |

**Precision statement, as the brief asks.** Every claim in Theorem 15.6 is an
`o(1)`-term asymptotic in `log n`. At RSA sizes:

- the H1 ratio is **0.411**, not `0.5` — the overcharge is **2.432**, not 2.
  So the *actual* slack in Shoup's smoothness exponent at RSA-2048 is **21.6%**,
  not 0%. The improvement from `2√2` to `2` is a statement about the limit; at
  RSA-2048 it is worth `2.432/2 = 1.216` in the exponent's multiplier, i.e.
  **the improvement is real but only ~78% realised at that size**, converging as
  `n` grows.
- `u` itself is 11–26 across the entire RSA range. Shoup's own hypothesis (no
  prime factor of `n` is `≤ y`) forces `y < √n`, hence `u > 2` always, and
  Theorem 15.1 needs `u → ∞`. **The theorem's hypothesis is satisfied but its
  asymptotic is not in evidence at any RSA size.**

### ρ(u) at those sizes — a harness problem, and a correction to its quoted error

**The shared harness `factor-scratch/r48/_shared/dickman.py` is now GUARDED**
(`VALID_U_MAX = 5.0`) and raises above that. The guard is correct: the
underlying routine freezes. Measured `c(u) = −log ρ(u)/(u log u)` on the
guarded range, which must rise to 1:

| u | 1.5 | 2.0 | 2.5 | 3.0 | 3.5 | 4.0 | 4.5 | 5.0 |
|---|---|---|---|---|---|---|---|---|
| `c(u)` | 0.8549 | 0.8522 | 0.8896 | 0.9175 | 0.9398 | 0.9586 | 0.9737 | **0.9861** |

(The small dip over `[1.5, 2.0]` is the normaliser `u log u` being
ill-conditioned there, not a defect; from `u = 2` the rise is monotone.)

**⚠️ CORRECTION to the figure circulated with the guard.** The harness bug was
reported to me as "u = 6: harness 2.224e-05, truth ~2.6e-04". **The 2.6e-04 is
the de Bruijn *asymptotic* `e^{−u(ln u + ln ln u − 1)}` evaluated at u = 6, not
the true Dickman value.** The asymptotic is poor at u = 6. The true value is
**ρ(6) ≈ 1.96e-5**, so the harness is only **13% high at u = 6**, not wrong by
12×. This matters for the census: a row reading "wrong by 12× at u = 6"
overstates the damage and, more importantly, the *true* ρ(6) is what a
replacement must reproduce.

Independent confirmation by exact Ψ at fixed u = 6 (converging down onto ρ(6)):

| y | x | Ψ(x,y)/x | ÷ my 1.9649e-5 | ÷ harness 2.2243e-5 | ÷ de Bruijn 2.6133e-4 |
|---|---|---|---|---|---|
| 25 | 2.4e8 | 3.5038e-04 | 17.83 | 15.75 | 1.3408 |
| 50 | 1.6e10 | 1.3594e-04 | 6.92 | 6.11 | 0.5202 |
| 100 | 1.0e12 | 6.6933e-05 | 3.41 | 3.01 | 0.2561 |
| 200 | 6.4e13 | 5.4663e-05 | **2.78** | 2.46 | **0.2092** |

The column against my value is **falling steadily toward 1**; the column against
the de Bruijn figure is already below 1 and heading the wrong way. So the true
ρ(6) ≈ 1.96e-5 and the guard at u ≤ 5 is, if anything, slightly conservative.

**I attempted a validated replacement and could not deliver one.** The best
scheme I built — log-space Simpson on the *causal Volterra* equation
`ρ(u) = 1 − ∫₁^u ρ(t−1)/t dt` in `mpmath` at 30–40 digits, tracking
`g = −log ρ` so that the per-cell ratio `ρ(u)/ρ(u−1) = 1 − ε` never cancels —
is h-converged as follows:

| u | 1/h = 400 | 1/h = 1600 | 1/h = 6400 | spread |
|---|---|---|---|---|
| 3 | 0.04860845 | 0.04860839 | 0.04860839 | 0.000% |
| 5 | 3.547741e-04 | 3.547278e-04 | 3.547249e-04 | **0.014%** |
| 6 | 1.968889e-05 | 1.965215e-05 | 1.964985e-05 | **0.199%** |
| 7 | 9.069697e-07 | 8.765922e-07 | 8.746936e-07 | **3.69%** |
| 8 | 5.996228e-08 | 3.404830e-08 | 3.242867e-08 | 84.9% |
| 9 | 2.513134e-08 | 2.523449e-09 | 1.110448e-09 | 2163% |
| 10 | 2.142154e-08 | 1.364824e-09 | 1.112719e-10 | 19152% |
| 20 | 1.007971e-08 | 6.299853e-10 | 3.937410e-11 | 25500% |

It reproduces `ρ` to 0.014% at u = 5, 0.2% at u = 6, 3.7% at u = 7 — and then
**collapses**, because by u = 8 the value is ~3e-8 and the per-cell increment
has dropped below the representable resolution of the running value. (Earlier
float64 attempts failed for the same reason at a higher floor; raising precision
to 140 digits did **not** help, which proves the limit is the *scheme's*
truncation error, not round-off.) Three other formulations were tried and all
regressed: interval power series, direct ODE in ρ-space, and implicit
per-cell fixed-point.

> **Verdict on a replacement: NOT TRACTABLE with the methods I tried.** A
> validated Dickman for u ≈ 20–25 would need a scheme whose per-cell increment
> stays representable across 20 octaves of decay — most likely arbitrary-
> precision Ψ counting at a size that is out of reach here, or a
> literature-grade Dickman–de Bruijn implementation. **I am not shipping a
> partial replacement.** Leaving the harness broken-but-guarded is the right
> call, and the guard is at the correct place.

> **ρ(u) at RSA sizes (u = 11–26) is therefore NOT MEASURED in this note.** The
> de Bruijn *scale* is reported below for shape only.

### The failure probability, measured

Lemma 15.5 (pp. 412–413) gives `P[failure] = 2^{-w+1}` where `w` is the number
of distinct odd prime factors of `n`. For a semiprime `w = 2`, so
`P[failure] = 1/2` **exactly**.

**Measured, not quoted.** For `n = 1000154000453 = 1000003 × 1000151` (both
`≡ 3 mod 4`), CRT gives exactly four roots of `x² ≡ 1 mod n`:
`[1, 121640364921, 878513635532, 1000154000452]`, of which exactly two are `±1`.
So `P[γ = ±1] = 2/4 = 1/2`. **Lemma 15.5's "at most 1/2" is TIGHT, attained.**

This is why Exercise 15.5 (p. 413) exists. But note: the `1/2` is a
**success**-probability statement and **never enters the running-time constant**.
Buying it down costs `k+2 → k+1+ℓ` relations, and since `log k = o(√(log n log log n))`,
`ℓ` extra relations cost **nothing** in the constant. **The `1/2` is orthogonal
to the factor of 2** — the third hypothesis in the brief is refuted.

---

## Summary of hypotheses from the brief

| hypothesis | verdict |
|---|---|
| mean-vs-median / Markov step | **REFUTED.** Thm 15.6 bounds E[Z] directly; no conversion to a success probability appears anywhere in §15.3. |
| union bound over sub-routine failures | **REFUTED.** The only failure probability is Lemma 15.5's `2^{-w+1}`, which is separate from the running time and provably free in the constant. |
| the `Ψ` lower bound (Thm 15.1) | **CONFIRMED — this is half the answer.** Its exponent `u log log x` over-charges the true `u log u` by a factor of exactly 2 at the balanced point. Removing it: `2√2 → 2`. |
| the choice of `y` given a failure budget | **REFUTED as a source of the 2.** The failure budget is orthogonal to the constant. But `y` *is* where the removable half lives: `y = exp[(1/2)√(log n log log n)]` instead of `exp[(1/√2)√(log n log log n)]`. |

## Appendix — audit: does anything here depend on `rho(u)` above 5?

The shared harness is now **guarded** (`VALID_U_MAX = 5.0`, raises above it),
so this was checked rather than assumed. The check is **executable**, not
textual: the shared `rho` is wrapped in a spy that records every `u` it is
called with, and the ρ-using parts of the suite are re-run under it.

```
the spy recorded 27 calls to the shared rho(); u values:
  [1.5, 2.0, 2.5, 3.0, 3.381076468577242, 3.5, 4.0, 4.5, 5.0]
LARGEST u ever passed to rho() = 5.0
```

Then, with `rho()` replaced by a function that **raises**:

- the `2√2 → 2` improvement still verifies (ratio `1.41350` vs `√2 = 1.41421`);
- the H1 identity `log u / log log n → ½` still verifies (to 1e-10).

So **neither central result touches ρ at all.** ρ enters only the `c(u)`
tightness diagnostic in S3, on `2 ≤ u ≤ 5`, where the harness is sound
(`c(5) = 0.9861`, rising monotonically toward 1).

*Process note:* the first two versions of this audit were **source-scanning
regexes**, and both were wrong — the first flagged a de Bruijn print table
(`u = 40`) that never calls ρ, the second flagged the audit's own docstring. A
tripwire that always fires is ignored, and a textual check over prose is not
evidence. The spy is the version worth keeping.

## Correction issued to the census

The harness bug reached me as a table reading `u=6: harness 2.224e-05, truth
~2.6e-04`. **The 2.6e-04 is `e^{−u(ln u + ln ln u − 1)}` at u = 6 — the de Bruijn
*asymptotic*, not the true Dickman value.** The asymptotic is 13× too high at
u = 6. The true value is **ρ(6) ≈ 1.96e-5** (confirmed by exact Ψ at fixed
u = 6, converging down onto it from above), so the harness is only **13% high
at u = 6**, not wrong by 12×. The catastrophic failure begins later. The
`u ≤ 5` guard is correct and, if anything, slightly conservative.

## Files

- `factor-scratch/r49exp/shoup/constant_test.py` — the self-test (36 PASS, 0 FAIL, 6 NULL)
- `factor-scratch/r49exp/shoup/full_output.txt` — its captured output
- `factor-scratch/r49exp/shoup/pg-428.png`, `pg-429.png`, `pg-430.png`, `pg-431.png`, `pg417-417.png` — the page images the trace is read from (printed pp. 410, 411, 412, 413, 399)
