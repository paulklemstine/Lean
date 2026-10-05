# The Coupling Is Real and Orthogonal

## A clean negative: the free 1.2× base conditioning transplants to the number-field side and is worth exactly nothing — because the search never reads it

**Round 53 · 2026-10-04 · Aether factoring programme**

---

## Abstract

Round 50 found a **free 1.2× improvement** to the only factoring construction that works:
condition the base `g` on `Jacobi(g/n) = −1`, computable **without factoring**, and the success
rate moves `20/27 → 8/9`. Round 52 showed *why* that cannot be combined with a sieveable search:
sieveability is a property of the **search**, the `20/27` rate is a property of the **base**, and
they live in different phases.

**Nobody had run the synthesis those two results point at.** This round does. It moves Result A's
conditioning verbatim from the base `g` to the **number-field base `b`**, where the search *is*
polynomial and therefore sieveable.

> **The transplant works exactly.** `20/27 → 8/9`, ratio **1.2000**, at **`q = 1`** and zero cost.
> The 2-adic coupling is **real, large, and free on the number-field side** — which is what makes
> the negative interesting rather than expected.
>
> **And it is worth nothing.** `GAIN ∈ {0, 1}` for every `(k, rule)`, never `> 1`.
>
> **The mechanism, in one line.** `b^k` is a quadratic residue mod `p` **iff `NOT(lam_p = 0 AND k
> odd)`** — exhaustive on **23 004/23 004** triples. The NFS search reads the base's 2-adic
> structure through **exactly one bit**, the quadratic character, and **every higher 2-adic digit
> is invisible to it.**
>
> **So the phase separation is not an artefact of where the coupling was looked for.** The
> coupling is *present* on the number-field side (**0.7625 → 0.8850**), *controllable for free*,
> and *orthogonal to the search variable*. **The barrier Result A removes is not present there to
> begin with** — there is no per-attempt Bernoulli to lift, so there is no rate for a free
> condition to raise. `s_C/s₀ = 1` is the absence of a target, not a failure of the trick.

Also delivered: **a retraction** of a round-52 measurement (an inherited instrument returned its
input on **496/496** pairs), **two new fabricated citations** — one *proven* nonexistent against a
complete volume table of contents — and the standard name for a mechanism this programme had been
using without attribution.

**Classical factoring of RSA-scale integers. Not a cryptographic break.** No factoring was
performed on any modulus of cryptographic interest; the largest is `n ≈ 2²⁸`, generated locally.

---

## 1. The `q`-term first, before any measurement

The ordering is the point of Result A, so it comes first.

```
GAIN = (s_C/s₀) · q / (1 + q·c_cond/c_gen)
```

| arm | rejects? | `q` | best `GAIN` (`s_C/s₀ = 2`, `c_cond = 0`) | verdict |
|---|---|---|---|---|
| **`Jacobi(b/n) = −1` on the base** | **no** | **1.0** | **2.00** | **LEGAL — the only unknown is `s_C/s₀`** |
| `Jacobi(b/n) = +1` on the base | no | 1.0 | 2.00 | legal |
| uniform `b` (baseline) | no | 1.0 | 2.00 | legal |
| filter `b` on `(b/p)₃ = +1` | yes | 1/3 | 0.50 | **KILLED algebraically** |
| filter `b` on `(b/p)₂ = +1` | yes | 1/2 | 0.67 | **KILLED algebraically** |
| filter `a` on a Jacobi sign | yes | 1/2 | 0.67 | **KILLED algebraically** |

**The Jacobi-on-`b` arm is legal by construction, not by measurement.** `Jacobi(b/n)` is a
property of the *base*, chosen once per attempt; it rejects no candidate from any search stream,
because the sieve **generates** survivors and never discards them. So `q = 1`, `c_cond = 0` (one
`O(log n)` Euclidean algorithm, `60–7000×` cheaper than a modular exponentiation), and
**`GAIN = s_C/s₀` exactly**. Everything below measures the single remaining unknown.

## 2. Three candidate conditions, and why only one survives

**(i) computable from `n` alone? (ii) free (`q = 1`)? (iii) actually coupled to 2-adic structure?**

| # | candidate | (i) no-factor | (ii) `q=1` | (iii) 2-adic coupled | verdict |
|---|---|---|---|---|---|
| **1** | **`Jacobi(b/n) = −1`** | **YES** — Euclid | **YES** | **YES**; the coupling is exactly `lam_p = 0` vs `lam_q = 0` | **SURVIVES. Dies in §3.** |
| 2 | `k`-th power residue symbol `(b/p)_k`, `k ≥ 3` | **NO** — §2.1 | — | in principle | **REFUTED** |
| 3 | choice of the degree-`k` polynomial `f` | YES | YES | **NO** — coupled to the factorisation pattern | **REJECTED** |

**Candidate 2 is refuted by an explicit collision, not by assertion.** A character of `(ℤ/nℤ)*`
computable from `n` alone must be **symmetric** under `p ↔ q`. For the quadratic character that
is harmless — the two local signs carry only their *sum*, and one sign *is* the sum. For `k = 3`
the local characters live in `μ₃`, and the product is not injective. **Measured**: over 26 moduli
with `3 | p−1` and `3 | q−1`, **935 pairs of bases** share the same symmetric product but differ
individually. Example, `n = 2479 = 37·67`: `b = 2 → (1,1)` and `b = 3 → (2,0)`, products both
`≡ 2 (mod 3)`. **So Jacobi is the *unique* free character** — not by a theorem asserted here, but
by the mechanism that makes it work at all.

## 3. The measurement

### 3.1 The transplant reproduces exactly

150 fresh 26-bit semiprimes × 40 base-trials, **N = 5400 per rule**, **per-cell 2-adic reporting,
never a pooled average alone**:

| cell `(a,b)` | uniform obs | uniform pred | `jac_neg` obs | `jac_neg` pred |
|---|---|---|---|---|
| **(1,1)** | 655/1320 = 0.4962 | 0.5000 | **1320/1320 = 1.0000** | **1.0000** |
| (1,2) | 493/640 = 0.7703 | 0.7500 | 480/640 = 0.7500 | 0.7500 |
| (1,3) | 604/680 = 0.8882 | 0.8750 | 605/680 = 0.8897 | 0.8750 |
| (1,4) | 107/120 = 0.8917 | 0.9375 | 112/120 = 0.9333 | 0.9375 |
| (1,6) | 159/160 = 0.9938 | 0.9844 | 157/160 = 0.9812 | 0.9844 |
| (2,1) | 811/1080 = 0.7509 | 0.7500 | 818/1080 = 0.7574 | 0.7500 |
| **(2,2)** | 279/440 = 0.6341 | 0.6250 | **440/440 = 1.0000** | **1.0000** |
| (2,3) | 182/240 = 0.7583 | 0.8125 | 181/240 = 0.7542 | 0.7500 |
| (3,1) | 325/360 = 0.9028 | 0.8750 | 318/360 = 0.8833 | 0.8750 |
| **(3,3)** | 107/160 = 0.6687 | 0.6562 | **160/160 = 1.0000** | **1.0000** |
| (4,1) | 190/200 = 0.9500 | 0.9375 | 192/200 = 0.9600 | 0.9375 |

Pooled: uniform **0.7244**, `jac_neg` **0.8857**. **Ratio 1.2226** against the theoretical
**1.2000**; the excess is sampling error. The diagonal came back **1320/1320, 440/440, 160/160 —
literally every trial**.

**The gain is on the diagonal and it LOSES off it.** Quoting only the pooled 1.22× would hide a
regression on ⅔ of the weight.

**Instrument calibration, before any cell above is quoted:** identical input, fixed seeds, run
twice → **13 cells, max swing 0.0000%**.

### 3.2 ★ The mechanism: solvability sees `lam_p = 0` and nothing else

The number-field relation condition is `a² ≡ b^k (mod p)`. Write
`lam_p = v₂(p−1) − v₂(ord_p b)`. Then, **exhaustively verified on 23 004 (base, `k`, prime)
triples**:

| `lam_p` | `k` odd | N | `P(b^k is QR mod p)` | predicted | agree |
|---|---|---|---|---|---|
| **0** | no | 5871 | 1.0000 | 1.0000 | 5871/5871 |
| **0** | **yes** | 5871 | **0.0000** | **0.0000** | 5871/5871 |
| 1 | no | 4203 | 1.0000 | 1.0000 | 4203/4203 |
| 1 | yes | 4203 | 1.0000 | 1.0000 | 4203/4203 |
| 2 | no | 1356 | 1.0000 | 1.0000 | 1356/1356 |
| 2 | yes | 1356 | 1.0000 | 1.0000 | 1356/1356 |

> **This is the whole negative in one line.** The NFS search's dependence on the 2-adic structure
> of `b` passes through the **single bit `lam_p = 0`** — the quadratic character — and **every
> higher 2-adic digit is invisible to it.**

### 3.3 The two arms of `GAIN`

**`k` EVEN — legal, free, and worth nothing.** Root count of `a² = b^k (mod n)` is **4 for every
base**, in every cell, at 16/18/20/24 bits. So `s_C/s₀ = 1`, **`GAIN = 1.000`**. The search sees
the same set; the base class is invisible to the quantity the search enumerates.

**`k` ODD — annihilating, not merely harmful.** `Jacobi(b/n) = −1` puts a non-residue on one
side; for odd `k`, `b^k` is a non-residue there, so **that prime admits no `a` at all**.
`P(p) = P(q) = P(n) = 0` **exactly, at every size, in 40/40 moduli**. `s_C = 0`, **`GAIN = 0`**.

### 3.4 The apparent 1.32× win is noise, and a permutation test says so

The usable-relation rate per root produced, for `k = 2`, a **1.318×** row at 18 bits — which would
exceed Result A's entire 1.2×. **Every such row is `power = NO`** (`E[hits] < 20`), and §3.2 says
the effect must be **exactly zero** for even `k`.

**Tested as a null rather than believed.** The two arms share moduli *and* roots; only the
**label** of which bases count as conditioned moves, so the permutation test is exact:

```
replicates   : 40        permutations : 240
REAL   ratio : median 1.231   [0.583, 2.000]   (5-95%)
PERMUT ratio : median 1.062   [0.391, 2.167]   (5-95%)
median real ratio inside permutation band?   True
permutation p-value  P[perm >= real] = 0.354
```

**The real labelling is indistinguishable from relabelling.** `s_C/s₀ = 1` stands.

**Positive control — the instrument can fire.** The same statistic on `k = 3` gives **0 roots in
120/120** moduli where `k = 2` gives 480 roots. So the null in §3.4 is a real null.

## 4. Result C applies here — as a *bijection*

Round 52 measured CRT-independence at ratio 0.93–1.10 and called it clean independence. **On this
side it is exact**, because `(a,b) ↦ (a mod p, b mod p, a mod q, b mod q)` is a **bijection** of
`(ℤ/nℤ)²`. Verified by **exhaustion** — every `(a,b)` pair, no sampling: **24 (n,k) cells, 0
departures from 1.000**.

**Does conditioning the base move the coupling? No.** CRT ratio, computed **per base** then
averaged, pooled over 8 moduli × 3 bases: for even `k`, uniform and `jac_neg` sit on the same
null, `|z| ≤ 2.23`, with per-base scatter (sd 0.11–0.69) that is finite sampling. For odd `k`,
`jac_neg` annihilates every base — that is §3.3, not a coupling gain.

**★ But the coupling is NOT absent — it is large, real, and free:**

| rule | `P(v₂(ord_p b) ≠ v₂(ord_q b))`, N = 400, 24-bit |
|---|---|
| uniform | 0.7625 |
| **`jac_neg`** | **0.8850** |

> **The phase separation is not an artefact of where the coupling was looked for.** The coupling
> is present on the number-field side, controllable for free at `q = 1`, and **orthogonal to the
> search variable**.

**The barrier Result A removes is not present on the number-field side to begin with.** There is
no `20/27`-type per-attempt Bernoulli to lift: the NFS relation rate is governed by
**smoothness**, not by a 2-adic order statistic. So there is no rate for a free condition to
raise, and `s_C/s₀ = 1` is the absence of a target.

## 5. ★ The open construction problem, precisely

> **A construction with both properties must make its success event depend on a local
> order-statistic of the base that (i) is a quadratic character, so it is controllable from `n`
> alone at `q = 1`, AND (ii) enters the relation condition through a quantity that is NOT already
> determined by `b mod p`** — because every function of `b mod p` alone is CRT-separated from
> `b mod q`, and a search that is polynomial in its index is exactly a function that can only ever
> see the joint residue.
>
> Concretely: **the 2-adic advantage must live in the KERNEL of what the sieve index can see, not
> in the base it is sieved against** — a periodic sub-structure in the exponent. **No choice of
> `b`, and no choice of `f`, can do it.**

## 6. ⚠️ RETRACTION: round 52's `ord_n(g)/n = 1.000`

Found while building this round's instrument. Verified independently by **three implementations**
(λ-strip, baby-step/giant-step, `sympy.n_order`), cross-validated at **0 mismatches on 496 random
`(n,g)` pairs**.

**The bug.** The round-52 `order_mod` starts from `order = m` and strips prime factors of `m`. But
`ord_m(a) | λ(m)` for `m = pq`, so `m` is not a multiple of the order, **the strip test never
fires, and the function returns `m` unchanged.** Measured: **`order_mod(g,n) == n` on 496/496
pairs.** At the call site it is invoked on the **primes**, so it returns `p` and `q`, and
`lcm(p,q) = pq = n` **exactly**.

**Every reported value was exactly `n`** — arithmetically impossible for an order, since
`λ(n) < n` always:

| bits | reported `ord_n(g)` | `= p·q`? | `λ(n)` | true `ord_n(5)` | true ratio |
|---|---|---|---|---|---|
| 16 | 40 301 | 191·211 ✓ | 3 990 | **665** | **0.0165** |
| 20 | 761 029 | 787·967 ✓ | 126 546 | 126 546 | 0.1663 |
| 24 | 11 865 251 | 3257·3643 ✓ | 5 929 176 | 539 016 | 0.0454 |

The header's **"798×, 1813×, 5334× the sieve limit"** traces to the same artefact.
**Sharpest single correction: at 16 bits the true period is 665 — 10× the sieve limit, not 630×.
Overstated ~63×.**

**A second, independent defect: the "verified 3/3" periodicity was vacuous.** The check asserts
`all(hits[i]==hits[i+T] for i in range(0, W-T))` with `W = min(2T, 20000)`; at 16/18/20 bits
`T ≫ W`, so **`range(0, W−T)` is empty and `all([])` is vacuously `True`.** All three published
`periodic_at_ord_n: true` entries never tested anything — and the results file itself records
`"spans_two_periods": false` beside them.

**The periodicity claim is nonetheless true**, when properly tested: **15/15 periodic at the TRUE
`ord_n(g)`**, and **0/15 had any period ≤ 64**. The mechanism is real; the verification of it was
empty.

**What survives.** "Period ≫ sieve limit, worsening with `n`" — at 28 bits the median true period
is ~3.4·10⁷ (≈530 000× the limit). **But not verbatim at 2¹⁶**, where the true period can be
665–3230, only **10–50×** the limit.

**Blast radius: narrow.** The function is used in exactly one place. **Unaffected:** the `20/27`
barrier, sieveability, the `q = 1` identity, CRT exactness, and this paper's every conclusion.
**Poisoned:** `ord_p_g`, `ord_q_g`, `ord_n_g`, `ord_n_over_n`, and the printed sieve-limit multiple.

## 7. Citations — two further phantoms, one proven false

`WebSearch` **fabricates citations on this host** (16 recorded instances) and was **not used at
any point**. The tally on this host is therefore **18**, and the failure mode is now
**bidirectional**: not only does the retriever invent — **the asker invents and the verifier
launders the guess into a checked-looking verdict.** A verification brief must carry only
citations some source already asserts. **Both phantoms below were supplied by me, as candidate
leads.**

**★ "Schnorr–Seysen–Bauer" is a PHANTOM — do not cite it.** zbMATH returns 2 hits for "Schnorr
Seysen", both **single-author Martin Seysen**. arXiv: **0 results**. OpenAlex's full author list for
Seysen (20 works) contains **zero** coauthored with Schnorr or Bauer. What *is* real: M.
**Seysen**, *A probabilistic factorization algorithm with quadratic forms of negative
discriminant*, Math. Comp. **48** (1987) 757–780 — the **binary quadratic-form / class-group**
method, *not* a QS lattice paper. **"Bauer" is unexplained and the claimed `√(m/2)` gain constant
was not found anywhere.**

**★★ "Coppersmith, *Two-dimensional lattice based cryptanalysis*, ANTS-I, LNCS 877, pp. 41–55"
does not exist — proven, not merely unverifiable.** The **complete ANTS-I table of contents**
(Crossref by ISBN, 36 records = 35 chapters + book record) has **zero** Coppersmith chapters, and
**pp. 41–55 are occupied by Dodson & Haines (41), Paulus (42), Couveignes & Morain (43–58)**.
*There is no room.* Corroborated against Coppersmith's complete zbMATH bibliography (**137
records**, none in ANTS/LNCS 877). **`LNCS 877` IS ANTS-I (1994)** — confirmed twice via zbMATH.

> **Provenance flag, recorded because it nearly propagated.** A verification sub-agent asserted
> **"LNCS 877 is ANTS-II (1996)."** That is **wrong** — ANTS-II is ed. Henri Cohen, and it is the
> volume containing Elkenbracht-Huizing (**LNCS 1172**). The sub-agent's *conclusion* was right and
> the volume claim was wrong, which is this programme's signature failure: **a correct conclusion
> laundered through a fabricated detail.**

**Scope trap.** **"Coppersmith–Odlyzko–Schroeppel" is real but is a DISCRETE-LOGARITHM
algorithm**, *Discrete logarithms in GF(p)*, Algorithmica **1** (1986) 1–15 — confirmed as a
*factoring* citation by two zbMATH reviews, **both explicitly about discrete logarithms**. **Do not
cite COS for factoring.**

### 7.1 The real mechanism has a standard name, and this programme had not been using it

The quadratic-character rows in NFS linear algebra are **real**, and rest on **five downloaded and
read full texts** (not one): Elkenbracht-Huizing (ANTS-II 1996 + her historical paper), Cavallar
(ANTS-IV 2000), Cavallar et al. (*RSA-512*, EUROCRYPT 2000), Kleinjung 2016, Briggs 1998.

> **The standard name is "quadratic character base", and it is Briggs's.** M. Briggs, *An
> Introduction to the General Number Field Sieve*, MSc thesis, Virginia Tech 1998, §4.3:
> "Each binary vector e(a,b) is also augmented with information relating a particular `a + bθ` to
> **the quadratic character base** …"
> "For a fixed `(s, q)` pair the corresponding bit in e(a,b) is set to 0 if the **Legendre symbol**
> `((a + bs)/q)` has value 1 and is set to 1 otherwise."

Provenance chain, all links verified: **Briggs (1998)** → **Buhler–Lenstra–Pomerance**, §8 and
§12.7, in *The Development of the Number Field Sieve*, **LNM 1554**, Springer 1993 → **Adleman,
STOC 1991, 64–71**.

Elkenbracht-Huizing's own statement of the mechanism:

> "Finding a vector in the nullspace of this matrix over **1F2** guarantees that, for the subset T
> of the relations …, every exponent in (1) is even. **BY ADDING SOME EXTRA ROWS COMING FROM
> QUADRATIC CHARACTERS**, ONE IS **PRACTICALLY CERTAIN** THAT THE SUBSET T IS THE WANTED SET S."

**Four cautions, each load-bearing — and the second is stronger than it first looks.**

1. **"Practically certain" is a heuristic, not a theorem.** Any statement that this is *proved* to
   be an index `2^r`, and hence a rigorous constant, **strengthens the source beyond what it
   says.** The exact statement in Buhler–Lenstra–Pomerance is **NOT DETERMINABLE** (closed access).
2. **★ The character rows are NOT structurally necessary, and a record-setting implementation
   omitted them entirely.** Briggs treats `m` as a **confidence/cost knob**, and Cavallar et al.,
   *Factorization of a 512-Bit RSA Modulus*, §3.3 footnote, verbatim:
   > "**In particular, all quadratic character rows are omitted.** The pseudo-dependencies being
   > found for this reduced matrix must be combined to real dependencies afterwards."
   So the apparatus is a **heuristic filter, not a structural requirement** — and the 512-bit
   record factored **without it**.
3. **★ "index `2^r`" and "2-adic" are NOT in this literature at all.** Searched **exhaustively
   across all eight full texts**: counts for **Jacobi, Legendre, "2-adic", torsion, and "index
   `2^r"` are ZERO in every one.** **Do not attribute an index-`2^r` or 2-adic formulation to
   these papers.**
4. **★ SCOPE CORRECTION.** **In the quadratic sieve there is no such parity/character
   constraint** — a QS relation already forces `x² = y` exactly, so the square condition is built
   in. **The apparatus belongs to the NFS**, where `F_i(a,b)` is only *almost* a square. **Do not
   carry a QS/NFS claim across that boundary** — the error class that already cost this programme
   a fatal once.

**The failure mode IS documented — and it has no name.** Cavallar et al., *RSA-512* §3.4:

> "One job found the factorization after 39.4 CPU-hours, **the other three jobs found the trivial
> factorization** after 38.3, 41.9, and 61.6 CPU-hours…"

So the trivial-gcd event is **real and routinely observed** — three of four dependencies in the
512-bit record factorization — but the literature's **only** name for it is **"the trivial
factorization"**. **There is no named 2-adic or index-`2^r` phenomenon**, and whether a name exists
is **NOT DETERMINABLE**.

## 8. Controls, and the ten bugs they caught

| control | status |
|---|---|
| **Self-test written FIRST**, negative controls fire, injection used | ✅ **29/29 PASS, exit 0**; the blindness guard fires on a planted cheater *and* accepts the honest conditions (else it is vacuous) |
| **Instrument calibration before any cell quoted** | ✅ identical input, fixed seeds, twice: **13 cells, max swing 0.0000%** |
| **Per-modulus 2-adic profile, never pooled alone** | ✅ 11-cell table with predictions; between-cell sd reported |
| **Non-vacuity by assertion** | ✅ `all([])` trap reproduced and shown empty |
| **A test that can fire must fire** | ✅ positive control: 0 roots/120 moduli at `k=3` vs 480 at `k=2` |
| **Power reported; under-powered rows excluded** | ✅ the 1.32× row excluded **on this basis**, then confirmed null by permutation |
| **Permutation null, not eyeballing** | ✅ 240 permutations, p = 0.354 |
| **Factorisation-blindness enforced structurally** | ✅ conditions see only `(b, n)`; Jacobi is hand-written so it *cannot* see `p` |
| **Regime honesty** | ✅ see §9 |

**Ten bugs in my own code, each of which would have produced a clean, confident, wrong number.**

1. **Inherited `order_mod` returns its input** — built the round's instrument on it before
   noticing. → §6.
2. **`lam` vs `k` again** — wrote the solvability condition as `k_p = 0` instead of `lam_p = 0`;
   **0/3978** in the offending cell. Same bug as round 50's #1, caught here by the per-cell control
   rather than by a pooled rate.
3. **A roll-up compared the wrong columns**, so a table with **23004/23004** agreement printed
   `[FAIL]`. Would have shipped as "the mechanism is refuted".
4. **Truncation mistaken for law** — an assertion at `1e-9` fired where the truncation error is
   `2.5e-7`. Fixed by **bounding the error**, not loosening the test.
5. **Per-modulus dead-flagging** conflated "structurally annihilated" with "one unlucky sample",
   printing `ratio = 0.000` for the **uniform** arm — i.e. reporting that the prior result *fails*.
6. **A vacuous exhaustive test that printed `[PASS]`** — filtered out composites when it needed
   semiprimes: **0 cells tested**, 0 departures, confident verdict. **A vacuous row that reports
   success is worse than no row, because it is believed.**
7. **A biased pooled estimator** producing a spurious **`z = +5.94`**. CRT-exactness is a
   *per-base* statement, so the estimator must be per-base, with annihilated bases **counted and
   reported** rather than dropped.
8. **Sampling a congruence** instead of enumerating it — `NO TRIALS` on 8/8 rows, which would have
   been a fabricated negative about the pipeline.
9. **A conditional rate presented as a rate of what** — `1e-5` printed as "40%".
10. **A degenerate test polynomial** — `(a+b)³ − b³` has root `a = 0` identically, so
    `P(irreducible) = 0` everywhere and the table could not distinguish "no 2-adic content" from
    "never irreducible".

Plus one in my own fix: the corrected `order_mod`'s assertion was initially **symmetric**
(`order % lam == 0 or lam % order == 0`), which would have **passed the un-stripped value** —
certifying the bug it was written to catch. **Only the divisor direction carries information.**

## 9. What is claimed, and what is not

**Claimed.**

1. **The transplant is exact.** `20/27 → 8/9`, ratio **1.2000** in exact rational arithmetic,
   measured pooled **1.2226** over 11 per-modulus cells at **`q = 1` and zero cost**. Diagonal
   cells **1320/1320, 440/440, 160/160**.
2. **★ The NFS search reads the base's 2-adic structure through exactly one bit** — exhaustive on
   **23 004/23 004** triples. Higher 2-adic digits are invisible to the search.
3. **★ `GAIN ∈ {0, 1}`, never `> 1`.** Even `k`: root count **4.000 in 8/8 rows**. Odd `k`:
   **`P(n) = 0` exactly in 40/40 moduli**.
4. **The apparent 1.32× win is noise**: permutation **p = 0.354**, with a positive control proving
   the instrument fires.
5. **The phase separation is not an artefact** — the coupling is **present** on the number-field
   side (**0.7625 → 0.8850**) and free; it is **orthogonal** to the search variable.
6. **The `k`-th power residue symbol (`k ≥ 3`) is not computable from `n`** — **935 explicit
   collisions**.
7. **Round 52's `ord_n(g)/n = 1.000` is retracted**, verified by three independent implementations
   at **0/496 mismatches**.
8. **Two fabricated citations closed**, one **proven** nonexistent against a complete volume TOC.

**NOT claimed.**

- **Nothing about the true NFS regime.** `π(B*) ≈ 10¹⁵–10³³` is uninstantiable here, and the
  relation-yield rows are at 16–20 bits with **`power = NO`**, used **only** to generate the noise
  hypothesis that §3.4 then refutes independently. **No extrapolation into the real regime.**
- **No factoring was performed** on any modulus of interest. Largest `n ≈ 2²⁸`; all generated
  locally. **This is classical factoring of RSA-scale integers. It is not a cryptographic break.**
- **The dichotomy is not a theorem over all conceivable constructions** — it is a mechanism, with
  the escape route in §5 named explicitly.
- **The Buhler–Lenstra–Pomerance statement itself is NOT DETERMINABLE** (§7.1). Only
  Elkenbracht-Huizing's *pointer* to §8/§12.7 was verified, plus her verbatim sentence.

## 10. Reproduce

```
cd factor-scratch/r53exp/synth
python3 selftest.py        # 29/29 PASS, exit 0                          (  1 s)
python3 exp_s1.py          # q-term, exact law, calibration, order step  (  9 s)
python3 exp_s2.py          # mechanism, annihilation, relation yield       (  7 s)
python3 exp_s2b.py         # permutation null + positive control          (  7 s)
python3 exp_s3.py          # Result C: exhaustive + per-base estimator    ( 11 s)
python3 exp_s4.py          # candidates 2 and 3 falsified                ( <1 s)
cd verify_order && python3 verify.py    # independent order_mod verdict   ( <1 s)
```

All timings **measured**, not estimated — a first draft guessed 25/12/6/14/4/9 minutes and was
wrong by up to 100×. All scripts exit 0; total runtime **~35 s**, stated plainly because a reader
who budgets an hour on the strength of a first version would be misled about how cheap the
negative was to obtain.

**Dependencies:** Python 3.12, `sympy`. `math.jacobi` **does not exist** in CPython 3.12, so
`core.jacobi` is hand-written — which is also why its factor-blindness is auditable rather than
assumed. Validated against `sympy.jacobi_symbol` on **3000** random `(a,n)`.