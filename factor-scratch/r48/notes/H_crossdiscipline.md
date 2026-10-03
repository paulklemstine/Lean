# H — Cross-Discipline Probing of Integer Factoring

**Round 48 · axis H · 2026-10-03 · work in `factor-scratch/r48/exp/H_*.py`, literature in `factor-scratch/r48/lit/`**

Factoring has been attacked for 50 years by number theory, lattices and group theory. This axis asks each
untouched field one sharp question: **does this field have a quantity computable in poly(log N) from N
that reveals a factor?**

**Headline: no. Seven fields, seven negatives, zero live leads.** But the negatives are not all the same
negative, and two of them are much sharper than expected — one of them (field 3) is an *equivalence*, and
one of them (field 6) is a *genuinely factor-revealing invariant that cannot be computed*. Two of my own
hypotheses were refuted by my own tests and are withdrawn below rather than buried.

---

## 1. Ranked table

Ranked by **(a)** plausibility that a factor-revealing polylog invariant exists at all, then by **(b)**
what the round actually established.

| rank | field | named quantity | (a) poly(log N)? | (b) reveals a factor? | verdict / which requirement fails |
|---|---|---|---|---|---|
| **1** | **3. Alg. geometry — Frobenius traces, étale cohomology, Tate module mod N** | projective point count `#E(Z/NZ)`; twist counts `Ê, Ẽ, Ē` | **NO** (CRT blocks Schoof) | **YES, exactly** | **ESTABLISHED AS AN EQUIVALENCE: computing `#E(Z/NZ)` ≡ factoring.** The live part is *known in print* (Dieulefait–Urroz Thm 1). Effort spent here. |
| **2** | **6. Topology / dynamical systems — Ihara zeta of the Jacobi-symbol graph on Z/NZ** | graph **degree** = φ(N)/2, the zero-frequency eigenvalue | **NO** (needs φ(N)) | **YES, exactly**: `p+q = N+1−2·deg` | **The closest thing to a live lead in the round: a genuinely factor-revealing spectral invariant, blocked only by computability.** Fails (b). |
| **3** | **2. Number fields — class group at discriminant −4N; ray class group of modulus N** | `h(−4N)`, ray class group `Cl_N(Q(i))` | **NO** (2^(n/2) enumeration; subexponential at best) | **ONE BIT only** — a Legendre symbol `(−p/q)` that itself needs `q` | Fails **(b)** and **(c)**. |
| 4 | 4. Representation theory / theta | theta series of discriminant −4N; cusp forms at level 4N | **NO** (reduces to a class number) | **NO** | Fails **(b)**. *Two of my hypotheses refuted en route; the surviving negative is a cost argument.* |
| 5 | 1. Category / K-theory | `K_1(Z/NZ)`, `K_2(Z/NZ)`, `Br(Z/NZ)`, tame kernel | **NO** (all indexed by factors) | **NO** — and `Br(Z/NZ)=0` on every RSA instance | Fails **(b)**; for the Brauer group, fails **(b)** and **(c)** vacuously. |
| 6 | 7. Probability / simulation | GNFS constant `(64/9)^{1/3}` | n/a (asymptotic) | n/a | Fails **(c) beats-the-cost**, by an average-vs-minimum argument. |
| 7 | 5. Information theory / complexity | — | — | — | **Fails all three; the question is malformed.** Precise negative below. |

---

## 2. Field 3 — worked out in full. The point count is *equivalent* to factoring

### 2.1 The identity (already in print — credited, not claimed)

For `E : y² = x³ − x` and `N = pq` with `p, q ≡ 3 (mod 4)`, the CM fact gives `#E(F_p) = p+1`,
`#E(F_q) = q+1`, hence by CRT

> **(★)** `#E(Z/NZ) = (p+1)(q+1) = N + (p+q) + 1`,  so  `p + q = #E(Z/NZ) − N − 1`.

Verified by brute force at 12 semiprimes including the tightest `N = 21` (`H_f3_blocker.py`, `H8/H8b`).

**This identity is not new and I am not claiming it.** Dieulefait–Urroz write all four twist expansions
explicitly (`arXiv:1911.11004`, **p. 4**, fetched, verbatim):

> `"Let N = pq be an RSA modulus, and d an integer such that dp = −1 or dq = −1. ... E = (P − ap )(Q − aq ) = P Q − P aq − Qap + ap aq , where P = p + 1, Q = q + 1 in the projective case and P = p, Q = q in the affine case. ... Then, E + Ê + Ẽ + Ē = 4P Q ,"`

My `t + t' = 2(N+a+b+1) + 2·a_p·a_q` and `t − t' = −2[(a+1)a_q + (b+1)a_p]` are exactly the sum and
difference of their `E` and `Ê` expansions. My independent brute-force check over 106 `(p,q,curve)`
triples agrees to the digit (`H4`, 0 failures).

### 2.2 The theorem this round actually establishes

> **THEOREM (H, field 3).** For `E : y² = x³ − x` and `N = pq` with `p, q ≡ 3 (mod 4)`,
> **computing `#E(Z/NZ)` as a group order is equivalent to factoring `N`** — in both directions, with no slack.

*Proof.* (⇒) By (★), `p+q = #E(Z/NZ) − N − 1`; then `p,q` are the roots of `X² − (p+q)X + N`. Verified
in code: the discriminant is a perfect square and the roots are exactly `p,q`, at 8 semiprimes.
(⇐) Given `p,q`, `#E(F_p) = p+1` is immediate. ∎

### 2.3 The blocker, measured: what PARI actually computes

PARI/GP's `ellcard(E, N)` for **composite** `N` runs in **0.00 s at 27 bits**. If that were a point count,
Dieulefait–Urroz Theorem 1 would already give deterministic polynomial-time factoring. It is not, and the
round pins down why:

| what | value at `N = 100160063 = 10007·10009`, `E : y²=x³−x` |
|---|---|
| PARI `ellcard(E, N)` | `100160064` (= `N+1`) |
| true **projective** group order `#E(Z/NZ)` | `100240128` |
| true **affine** locus | `100220105` |

Across **24 (N, curve) pairs** at the tightest cases, PARI's composite output matched the projective order
**0/24** times and the affine locus **0/24** times (`H_f3c_pari_trust.py`, T1a). **PARI's composite
`ellcard` is not a point count and must not be used as one.**

The reason is structural, not a bug: over a ring, `E(Z/NZ)` is *not* the affine locus plus one point. An
element like `(O, [T])` of `E(F_p) × E(F_q)` has **no affine representative**, because there is no `(x,y)`
mod `N` whose image is `(O mod p, affine mod q)`. So the affine locus and the group order differ. My first
harness counted the affine locus, "refuted" (★), and was wrong — the identity was right and the harness was
broken. Recorded as a correction, not hidden (`E3.1b`: `affine+1 ≠ group order` in 12/12 cases).

### 2.4 The sharp asymmetry between affine and projective — the round's cleanest finding

The four twist counts sum to `4PQ` (Dieulefait–Urroz, p. 4). Which quantity that is decides everything:

| case | `P, Q` | sum of the four twist counts | recovers? |
|---|---|---|---|
| **affine** | `P = p`, `Q = q` | `4pq = 4N` — **a tautology, known a priori** | **nothing** |
| **projective** | `P = p+1`, `Q = q+1` | `4(p+1)(q+1) = 4N + 4p + 4q + 4` | **`p+q = (S − 4N − 4)/4`** |

Measured on 12 (N, curve) pairs: the affine sum is `4N` in every case (T2a, 0 violations), and the
projective sum is `4(p+1)(q+1)` in every case, with `p+q` recovered correctly in **all** of them (T3a).

So Dieulefait–Urroz's theorem lives entirely in the projective case, and it needs **four projective twist
counts**. And the affine count cannot be promoted to the projective one for free:
`proj − aff = p + q + 1 − (a_p + a_q)` (T4a, 0 violations) — the step needs `p+q` and `a_p+a_q`, i.e. the
factorization itself.

### 2.5 Can the modulus be enlarged usefully? No.

Hensel: the affine locus of `E(Z/p^k Z)` is `p^{k−1}(#E(F_p) − 1)` (verified at the tightest case `p=3`,
`k = 1..4`). Lifting multiplies by a power of `p` that is known **only once `p` is known** — enlarging the
modulus adds exactly zero information about the split.

Frobenius traces mod small `ℓ` (task item 3's "which Frobenius congruences reveal factors"): measured at
`ℓ = 3,4,5,8,9,16`, the traces `a_p mod ℓ` take up to `ℓ` distinct values across primes — at most
`log₂ℓ` bits each, and the constraints are functions of `p mod ℓ`, already computable from `N`.

### 2.6 The literature corrections this axis received (and one of my own errors)

The literature subagent checked, with page cites, and **corrected three of my working assumptions**:

- **The direction is count ⇒ factoring, and it is deterministic in print.** Dieulefait–Urroz
  `arXiv:1911.11004` **p. 3**, verbatim: *"Given the number of points, affine or projective, of any elliptic
  curve and one of its twists modulo N we can factor N in deterministic polynomial time."*
- **But a single count is not enough**, same paper **p. 3**, verbatim: *"It is worth remarking that it is
  not known how to factor N only with the number EN as input."* This is the single sentence that keeps
  field 3 honest, and it is why §2.4's asymmetry matters.
- **Under GRH, a single count does suffice** — Urroz–Pomykała `arXiv:2210.04835` **p. 2**, verbatim:
  *"Let n be a squarefree integer. Then, assuming GRH, counting the number of points on elliptic curves
  modulo n allows to find the complete factorization of n with probability bigger than 1 − ε for any ε > 0."*
  Squarefree only, probabilistic, GRH assumed.
- **My "Nguyen–Stehlé" attribution was wrong** and is retracted below (§2.7).
- **The prior literature assumed a distribution hypothesis that is false.** `2210.04835` **p. 1** on
  Kunihiro–Koyama: *"their results are based in an assumption on the distribution of the number of points
  on elliptic curves over finite fields which is not accurate."*
- **"twist-separable" does not exist in the literature** — 0 hits in Brave, OpenAlex, and Sutherland's
  211-page thesis. The term is dropped.
- My counterexample to "`a_p ≡ (p/3) mod 3`" was **confirmed correct**: `E: y²=x³+1` has `#E(F_7)=12`,
  so `a_7 = −4 ≡ 2 (mod 3)`, while `(7/3) = +1`. The statement as I posed it is false.

### 2.7 Field 3 verdict

**Fails requirement (b), computable-in-poly(log N) — and it fails by an *equivalence*, not a gap.** The
factor-revealing quantity exists, is exactly the quantity that factors `N`, and no poly(log N) route to it
is known or expected, because Schoof needs a prime characteristic and CRT turns the count into a product
over the very primes we are looking for. **This is not a lead; it is a well-characterised dead end that
was already in print.** The round's contribution is the *sharpening*: the affine channel is provably a
tautology, PARI's fast composite output is not a count, and the equivalence has no slack in it.

---

## 3. Field 6 — the closest thing to a live lead

The task asked about the Ihara zeta of a graph built from `N`. The graph whose adjacency matrix is
genuinely **polylog-computable** (each entry is one Jacobi symbol, `H1b` verified factorization-free) is the
**Jacobi-symbol (Paley-type) Cayley graph of `Z/NZ`** with connection set `S = {x : (x/N) = +1}`.

> **(★★)** Its **degree** is `|S| = φ(N)/2 = (N + 1 − p − q)/2`, so
> **`p + q = N + 1 − 2·deg`** — a **spectral invariant that reveals a factor exactly**, verified in every
> tested case (F6.1b).

The degree is not a computational accident: for a circulant adjacency matrix the eigenvalues are the DFT of
the connection indicator, and the degree **is the zero-frequency eigenvalue**. So the factor-revealing datum
is genuinely spectral, and it should in principle be reachable through the Ihara zeta via the Bass formula
`ζ⁻¹(u) = (1−u²)^{m−n} det(I − uA + u²D)`.

**Why it still fails (b).** Extracting it is a sum of `N` Jacobi symbols: `Θ(N) = 2^n`, measured to grow
linearly (F6.2a). And `deg = φ(N)/2`, and **φ(N) is polylog-equivalent to factoring** — so the invariant is
factor-revealing and its computation is factoring. The Ihara zeta needs the full spectrum, which needs the
same enumeration.

**This is the closest thing to a live lead in the round**, and the honest reason it is not one: it is a
restatement, not a shortcut. Any polylog method that read the degree off the adjacency matrix without
summing over `N` vertices would be a factoring algorithm, and no such method exists.

---

## 4. Field 2 — class groups at discriminants that depend on N

The task's hypothesis was that discriminants *depending on* `N` behave differently from the fixed-`D`
families this program has already exhausted. **They do not, and the reason is sharp.**

**The cost kills it (b).** Reduced-form enumeration at discriminant `−4N` runs `a = 1..sqrt(|D|/3)`,
measured growth exponent in `N` of **0.437–0.528** across successive cases (F2.2b) — i.e. `Θ(sqrt N) =
2^(n/2)`, `1.3×10^154` iterations at `N = 2^1024`. The analytic route needs `L(1, χ_{−4N})` to
`1/sqrt(N)` precision; the best general algorithm is subexponential (Hafner–McCurley), still not poly.

**The content is one bit (c).** The only cross-factor information in `h(−4N)` is a Legendre symbol
`(−p/q)` — **one bit**, and evaluating it requires knowing `q` (F2.4a). The classical class-number relation
at these discriminants is **not** invertible on the Legendre symbol: measured over 55 semiprimes,
`h(−4pq)/(h(−4p)h(−4q))` is **not** a function of `(−p/q)` alone — the ratio sets for `legendre = ±1`
**overlap** (F2.1a, 13 distinct ratios across 2 Legendre values). My first draft asserted a Kuroda prefactor
in `{1, 1/2}` from memory; the measurement refuted it and the assertion was withdrawn.

*Control:* PARI's `qfbclassno` agrees with an independent brute-force reduced-form enumerator on all 36
small discriminants tested (F2.0, 0 mismatches) — so the class numbers above are trustworthy.

**Ray class groups of modulus `N`** are indexed by the prime-power factors, hence determined *by* the
factorization. **Unresolved harness issue, recorded not hidden (F2R.b):** I could not establish the correct
closed form — my two candidates each match on a subset of the tightest cases and fail on the complement
(`prod(r²−1)^a/4` matches `N = 3,7,21,77`, all primes `≡ 3 mod 4`; it fails at `N = 5,9,13`, primes
`≡ 1 mod 4`). The brute-force enumeration is trusted; the closed form is not. **The field-2 negative does
not depend on it** — it rests on the cost measurement and the one-bit argument, both independent.

**Verdict: fails (b) and (c).**

---

## 5. Field 4 — theta series (with two of my own hypotheses refuted)

**Hypothesis 1 — WITHDRAWN.** *"Every non-principal form of discriminant −4N first represents an integer at
index `≥ sqrt(N)`, so any poly(log N) prefix of the theta series is identically zero."* **Refuted by
measurement**: the smallest index a non-principal form represents is **2, 3, 4, 8** — not `sqrt(N)`. My
first harness had grabbed only the *first* reduced form, which is always the principal form `(1,0,N)`,
which represents 1 trivially. Withdrawn.

**Hypothesis 2 — ALSO WITHDRAWN.** *"The small-index theta support is entirely local — it is exactly the set
of `m` with `x² ≡ −N (mod m)` solvable, hence polylog-computable from `N`."* **Refuted in 8/8 cases**: the
represented set differs substantially from the local prediction. So the genus theta data at small index is
genuinely **non-local**.

**The negative that survives both refutations is the cost one.** The theta data is non-local, but recovering
*which* form represents `m` is the **class group of discriminant −4N** — a class number, cost `2^(n/2)`
(F2.2b). The mass formula and Kronecker limit formula at `−4N` are rescaled analytic class numbers and
inherit the same cost (F4.3). **Theta at an `N`-dependent discriminant is not an independent channel; it is
field 2 wearing a different hat.**

**Verdict: fails (b), on cost — not on content.**

---

## 6. Field 1 — K-theory / Brauer / tame kernel

| quantity | finding |
|---|---|
| `K_1(Z/NZ)` | `= (Z/NZ)*`, order `φ(N)`, a product over prime factors (F1.1, 0 mismatches). `φ` is polylog-equivalent to factoring. |
| `K_2(Z/NZ)` | CRT-indexed by prime powers: measured `v₂|K₂(15)| = 6` vs `v₂|K₂(21)| = 8` (F1.2). |
| `Br(Z/NZ)` | **`= 0` for squarefree `N`** — `Z/NZ` is a product of finite fields and `Br(F_q) = 0`. On every RSA semiprime the Brauer group is **trivial**: nothing to compute, nothing to reveal. It is nonzero only for non-squarefree `N`, i.e. once you already know a repeated factor (F1.3a/b). |
| tame kernel / Birch–Tate | `\|K_2(O_K)\|` is given by `ζ_K(−1)`, the regulator and `w_2` — all class-number-scale. For `K = Q(√N)` it inherits the class-number cost (F1.4). |

**Verdict: fails (b); for the Brauer group, vacuously — it is empty exactly where we need it.**

---

## 7. Field 7 — GNFS constant

**A correction to my own premise, and to the orchestrator's.** I was told to expect a
Nguyen–Stehlé improvement to `1.90188`. **That attribution is wrong and is retracted.** The literature
subagent verified, and I re-checked the arithmetic myself:

- `1.90188` is **`(92 + 26√13)/27)^(1/3) = 1.9018836118…`** — the constant of **Coppersmith's multiple
  polynomial sieve**, *not* a GNFS result and *not* by Nguyen–Stehlé. Verbatim, Lee–Venkatesan
  `arXiv:1805.08873` **p. 2**: *"These results can be shown to extend to Coppersmith's multiple polynomial
  sieve of [9], a randomised variant of which finds congruences of squares modulo n in expected time:
  L_n(1/3, cbrt((92+26*sqrt(13))/27) + o(1)) = L_n(1/3, 1.90188...+o(1))."*
- **Exhaustive negative search: no source claims a general-`N` factoring constant below `1.9229994`.** Every
  sub-1.923 constant found is either Coppersmith's multiple polynomial sieve, or a finite-field **DLP**
  constant (`1.88`, `~1.90`, `1.71`) — never general-`N` factoring.
- The best current peer-reviewed NFS analysis (Le Gluher–Spaenlehauer–Thomé, eprint 2020/829, **p. 1**)
  **keeps the same leading constant** and only improves the `o(1)` term: *"We prove that it is equivalent to
  4 log log log N / (3 log log N)."*
- GNFS constant `(64/9)^{1/3} = 1.9229994270` verified independently in code. Best page-verified primary
  source: *Handbook of Applied Cryptography* §3.2.7, **p. 98**, verbatim: *"has an expected running time of
  L_n[1/3,c], where c = (64/9)^{1/3} ≈ 1.923. This is, asymptotically, the fastest algorithm known for
  integer factorization."* Lenstra 1987 (*Des. Codes Crypt.* 19:101–128) is paywalled from this host; the
  formula is in fact cited to Lenstra–Verheul, *J. Cryptology* **14** (2001) 255–293 (per Aoki et al. 2007,
  p. 11).
- **Three commonly-quoted comparison constants are contradicted or unsourced and are deliberately NOT
  quoted here**: MPQS `√(8/9) = 0.9428` is *contradicted* — HAC gives MPQS `L_n[1/2,1]` (*"the method of
  choice in practice"*); SIQS `(1/2)√2` is unsourced; Dixon `√(2/3) = 0.8165` is unsourced (accessible
  sources give `2√2` for Dixon, `√2` for CFRAC). SNFS `(32/9)^{1/3} = 1.526` and ECM `√2` **are** verified
  (HAC §3.2.4, p. 94).
- **The quantum framing is a category error and is not used**: Shor is `Õ(n²)` gates — polynomial, so there
  is no `L[1/3,c]` constant to compare. The one claim that *would* move an exponent is Regev
  `arXiv:2308.06572`, `Õ(n^{3/2})` gates, explicitly conditional on *"a number-theoretic heuristic
  assumption."*

**The precise negative (F7.2).** A randomized polynomial-selection strategy samples the space of
polynomial shapes; its expected constant is the **average** of the size function over that space, which is
`≥ its minimum`, with equality only for a degenerate distribution on the optimum. **Randomization can match
`(64/9)^{1/3}` but never beat it**, unless it restricts to a shape class the classical analysis did not
consider — and that is a number-theoretic input, not a probabilistic one.

**For calibration**, the constant → speedup map `exp((c_old − c_new)(ln N)^{1/3}(ln ln N)^{2/3})` gives:

| from 1.922999 → | 256 bits | 1024 bits | 2048 bits | 4096 bits |
|---|---|---|---|---|
| `1.90188` (Coppersmith MPS) | 1.43× | **1.94×** | 2.43× | 3.29× |
| `1.90` | — | 2.05× | 2.64× | 3.66× |
| `1.85` | — | 9.81× | 21.7× | 61.4× |
| `1.80` | — | 46.8× | 178× | 1031× |

(Note the map is `t_old/t_new = exp((c_old − c_new)(ln N)^{1/3}(ln ln N)^{2/3})`, **not** `(X/1.92299)^{1/3}`
— the latter is off by orders of magnitude and would say a drop to 1.80 buys only 0.98×.)

So a constant improvement is a real win and grows with `n` — but the available one is (i) not a GNFS result,
(ii) not available for general `N` in practice, and (iii) worth ~2× at 1024 bits, not the order-of-magnitude
the framing suggested. **Fails (c).**

---

## 8. Field 5 — information theory: the precise negative

Stated properly, since a vague "dead" is not a deliverable:

1. **Information-theoretically factoring is trivial.** A factor carries `~n/2` bits and `N` has `n` bits
   (measured: `n = 33`, factor `~30` bits). "Information theory says factoring is hard" is **false**;
   "information theory says factoring is easy" is **vacuous**.
2. **The decision version is in `P`** by primality testing (AKS 2002). So the obstacle is not the decision
   problem.
3. **The search problem is TOTAL** — every composite `N` has a factor — so it is not the kind of problem
   P-vs-NP decides, and no search-vs-decision separation for total functions is known either way.

**Verdict: fails all three requirements, and the correct negative is that the question is malformed** —
factoring is neither an information-theoretic nor a decision-complexity question, and the factor-revealing
quantities of fields 2, 3 and 6 are all *total functions* whose obstruction is computational, not
informational.

---

## 9. What would change the verdict

Ordered by how much they would matter.

1. **Field 6 — read the degree off the Jacobi-symbol adjacency matrix without summing over `N` vertices.**
   This is the round's only genuinely live lead. It needs a polylog algorithm for the zero-frequency DFT
   coefficient of a Jacobi-symbol indicator. **No such algorithm is known; I would bet against one.** But it
   is the only target here where success is not immediately an equivalence to something already known.
2. **Field 3 — a polylog projective point count over `Z/NZ`.** Would be deterministic polynomial-time
   factoring outright (Dieulefait–Urroz Thm 1). The affine half is *provably* a tautology (§2.4), so only
   the projective half is live, and it needs four of them.
3. **Field 2 — a polylog class number at discriminant `−4N`.** Would give the Legendre symbol — one bit,
   which does not split `N`. **Low value even if achieved**, and §4.1's non-invertibility suggests it would
   not even reliably give that bit.

---

## 10. Self-audit

**Self-test written first** (`H_selftest.py`, 13/13 pass), covering the Jacobi symbol (incl. the
factorization-free reciprocity algorithm), Hasse, the twist trace, the twist identity (106 brute-force
cases), the CM fact (every prime `≡ 3 mod 4` below 2000), Carmichael λ, the GNFS/SNFS constants and the
`c → time` map, and the affine-vs-group-order gap at the tightest case `N = 21`.

**Self-corrections made this round (none hidden):**

| # | what went wrong | how it was caught |
|---|---|---|
| 1 | first `E3.1` "refuted" the identity (★) | brute force counted the *affine locus*; over a ring that is not the group order. Harness fixed; identity confirmed. |
| 2 | `F33` demanded one trace pair satisfy all curves at once | impossible by construction — different curves have different traces. Rewritten to measure the solution set's size. |
| 3 | `F4` theta claim withdrawn | measured first-represented index is 2–8, not `≥ sqrt(N)`. |
| 4 | `F4b` "local data" claim withdrawn | 0/8 agreement with the local prediction. |
| 5 | Kuroda prefactor `{1, 1/2}` asserted from memory | measurement refuted it; replaced by the measured overlap result. |
| 6 | ray class number formula wrong | control FAILED (96 vs 21 at `N = 21`); left as an explicitly unresolved issue rather than patched over. |
| 7 | "Nguyen–Stehlé 1.90188" | literature check: it is Coppersmith's multiple polynomial sieve. Retracted. |
| 8 | three PARI API errors, two `selftest.py` overwrites by the parallel axis | files renamed with an `H_` prefix. |

**Unverified claims, flagged as such:** the Irani/Venkatesan/Sutherland premises in the literature check
were themselves corrected (Sutherland's thesis is MIT on *multiplicative* orders, not elliptic curves;
Silverman's Xedni paper is *Designs Codes Crypt.* 20 (2001), not Duke Math. J. 1998). No distribution claim
about `a_p mod ℓ` is asserted — none was verifiable from this host.

**Not done:** no commit, no GitHub issue, no paper, as instructed.