# JJ — Closing the partial-information axis

Round 48 census row: *"Partial-information factoring below ½ the bits of p — MEASURED **and PROVED
OPTIMAL** ... 31 unknown bits WORKS, 32 FAILS at `N = 2¹²⁸` — `X = N^{1/4}` exactly. Upgraded by a
literature sweep: this is now also a THEOREM (arXiv:1605.08065)."*

**Verdict up front: the axis is NOT closed. R1 does not cover the program's row, and R2 does not
cover the program's row.** Two of the five listed gaps are settled; the three that carry the
substance are not. Details and the corrected census row follow.

Everything below was verified from the PDFs (page images, not `pdftotext`, for every formula).
No WebSearch was used. Working files: `factor-scratch/r49exp/pkinfo/`.

---

## 1. R1 verified — and what it does *not* say

**arXiv:1605.08065**, Ted Chinburg, Brett Hemenway, Nadia Heninger, Zachary Scherr,
*Cryptographic applications of capacity theory: On the optimality of Coppersmith's method for
univariate polynomials*, 25 May 2016, 22 pp. Metadata confirmed via
`https://export.arxiv.org/api/query?id_list=1605.08065`.

The sweep's p.1 quote is **verbatim and correct** (p.1 abstract, read from the page image):

> "Using capacity theory, we prove that Coppersmith's bound for univariate polynomials is optimal in
> the sense that there are no auxiliary polynomials of the type he used that would allow finding roots
> of size $N^{1/d+\epsilon}$ for monic degree-$d$ polynomials modulo $N$. Our results rule out the
> existence of polynomials of any degree and do not rely on lattice algorithms, thus eliminating the
> possibility of even superpolynomial-time improvements to Coppersmith's bound."

### 1.1 What exactly is proved optimal

**p.2, Theorem 2** (verbatim from the p.2 image):

> "**Theorem 2** (Optimality of Coppersmith's Theorem). *Suppose* $\epsilon > 0$. *There does not exist a
> non-zero polynomial* $h(x) \in \mathbb{Q}[x]$ *of the form*
> $$h(x) = \sum_{i,j\geq 0} a_{i,j}\, x^i (f(x)/N)^j \qquad (2)$$
> *with* $a_{i,j} \in \mathbb{Z}$ *such that* $|h(z)| < 1$ *for all* $z$ *in the complex disk*
> $\{z \in \mathbb{C} : |z| \leq N^{(1/d)+\epsilon}\}$. Furthermore, if $\epsilon > \ln(2)/\ln(N)$ there
> is no such $h(x)$ such that $|h(z)| < 1$ for all $z$ in the real interval
> $[-N^{1/d+\epsilon}, N^{1/d+\epsilon}]$."

So the precise content is: **no auxiliary polynomial of Coppersmith's shape** — i.e. of form
$\sum a_{i,j}x^i(f(x)/N)^j$ — can be small enough on the larger disk. This is **stronger than "the
lattice construction is optimal"**: it kills the auxiliary polynomial itself, so no improvement is
possible *even by an entirely different method* that still produces an auxiliary polynomial of this
form, and *even with superpolynomial time* (any degree is excluded, not just poly(log N)). It is
**weaker than "the method is optimal"**: it says nothing about methods that do not build such an h.

The sweep's summary line — *"we prove that Coppersmith's bound for univariate polynomials is optimal
... Our results rule out the existence of polynomials of any degree"* — is accurate but elides the
middle clause "of the type he used". That elision is exactly what makes the census row wrong
(§3, K2).

### 1.2 Univariate only — and the paper says the excluded cases by name

**p.6, §2.3.1** (verbatim from the p.6 image) is the decisive sentence:

> "Coppersmith's original work also considered the problem of finding small solutions to polynomial
> equations in two variables over the integers and applied his results to the problem of factoring RSA
> moduli $N = pq$ **when half of the most or least significant bits of one of the factors $p$ is
> known.** [Cop97] Howgrave-Graham gave an alternate formulation of this problem by finding approximate
> common divisors of integers using similar lattice-based techniques, and obtained the same bounds for
> **factoring with partial information.** [HG01] May [May10] gives a unified formulation of Coppersmith
> and Howgrave-Graham's results to find small solutions to polynomial equations modulo **unknown
> divisors** of integers. Later work by Jutla [Jut98] and Jochemsz and May [JM06] has generalized
> Coppersmith's method to multivariate equations, and Herrmann and May [HM08] obtained results for
> multivariate equations modulo divisors.
>
> As we will show in the next section, existing results in capacity theory can be used to directly
> address the case of auxiliary polynomials for Coppersmith's method for univariate polynomials modulo
> integers. **Adapting these results to the other settings of Coppersmith's method listed above is a
> direction for future research.**"

And **p.19, §6**:

> "Interestingly, Howgrave-Graham's extension of Coppersmith's method to find small roots of modular
> equations modulo unknown moduli [HG01, May10] appears to pertain to joint capacities of many adelic
> sets, **a topic which has not been developed** to our knowledge in the capacity theory literature."

**R1's own §2.3.1 names "factoring RSA moduli $N=pq$ when half of the most or least significant bits
of one of the factors $p$ is known" as a case it does NOT cover.** That is verbatim the census row's
subject. The axis's headline finding is therefore not "the bound is proved optimal" but the
opposite: **R1 explicitly excludes this row's setting.**

### 1.3 A bonus the sweep did not report

The abstract contains a **third** result the sweep omitted, which is directly relevant to K3:

> "We extend this result to constructions of auxiliary polynomials using binomial polynomials, and
> rule out the existence of any auxiliary polynomial of this form that would find solutions of size
> $N^{1/d+\epsilon}$ **unless $N$ has a very small prime factor**."

**p.2, Theorem 4**: if $1.48774 N^\epsilon \geq M \geq 319$ and a binomial-form auxiliary polynomial
is small on the disk of radius $N^{1/d+\epsilon}$, then *$N$ must have a prime factor $\le M$*. For an
RSA modulus with two large primes this cannot happen, so the binomial variant buys nothing either.
(§6 summarises: *"Does considering lattices based on binomial polynomials improve the situation? No,
these lattices have the desired auxiliary polynomials, but for RSA moduli, their degree is too large
to be useful."*)

---

## 2. R2 verified — and its scope is narrower than the program assumed

**arXiv:2111.14180**, same four authors, *Two variable polynomial congruences and capacity theory*,
28 Nov 2021, 15 pp. Metadata confirmed via the arXiv API.

The sweep's p.1 quote is **verbatim and correct**, but the sweep quoted only its *conclusion* and not
its *scope*. The very same page says (p.1, §1):

> "In this paper, we apply adelic capacity theory to **two-variable linear polynomial congruences.**
> This is the simplest case involving multivariate polynomials, and it includes the hidden number
> problem and ring learning with errors as special cases."

and, on the heuristic status:

> "Unlike the univariate case, which is a fully rigorous method, the method used in the existing
> cryptanalytic literature to address the multivariate case is heuristic."

and, on what is proved:

> "The existing constructions are unable to guarantee the algebraic independence of multiple auxiliary
> polynomials, and thus the applications of this method all rely on a heuristic assumption of algebraic
> independence."

The sweep's quoted sentences are all present and correct:

> "we give an infinite family of examples for which there can be no pair of algebraically independent
> functions of any degree in Coppersmith's method. However, we have a method for determining rigorously
> whether such a pair exists in a given case."

**The load-bearing omission:** the negative family and the decidable test are both confined to
**two-variable LINEAR** congruences — a 2-sample Hidden Number Problem and ring-LWE. They say
**nothing** about the n-variable nonlinear Herrmann–May constructions the census wanted to build.

### 2.1 The decidable test, precisely enough to implement

The algorithm is stated verbatim on **p.12**:

> "Using lattice basis reduction, find a polynomial $b_1 x + b_2 y + b_3 \in J^{-1}\mathcal{O}_F[x,y]$
> with the properties in Theorem 2.1 for $Y = X$, $t = -c_1c_0'$ and $a = 0$. Calculate the capacity
> $\gamma(\mathcal{E})$ of the adelic set $\mathcal{E}$ associated to this adelic set in Definition 3.1,
> using Lemma 3.2 and Theorem 3.5. If $\gamma(\mathcal{E}) < 1$, then parts (2) and (3) of Theorem 4.1
> show $N(t,a,J,X/2,X/2) \leq 1$."

Decision rule, **Theorem 3.4** (p.6 image):
* $\gamma(\mathcal{E}) > 1$ ⇒ infinitely many solutions; **every** Problem-1.3 polynomial is divisible
  by $g_1$; the common zero locus is infinite ⇒ **Coppersmith's method cannot work**.
* $\gamma(\mathcal{E}) < 1$ ⇒ finitely many solutions; common zero locus finite ⇒ **the method works**.
* $\gamma(\mathcal{E}) = 1$ ⇒ knife edge.

Implementation (for $F=\mathbb{Q}$, $J=p\mathbb{Z}$, which is the case the paper analyses in closed
form and the case relevant to HNP): write $g_1 = p^{-1}(d_1x + d_2y + d_3)$ with $d_1>0$. Then

$$\gamma(\mathcal{E}) \;=\; \frac{\gamma_\infty(E_\infty)}{d_1},\qquad
E_\infty \;=\; D(0,Y)\cap D\!\left(-b_3/b_2,\;|b_1|X/|b_2|\right),$$

the $d_1^{-1}$ being the finite-place product $\prod_{v\ \text{fin}} |d_1|_v$ by the product formula
(Lemma 3.11 proof). $\gamma_\infty$ of a lens is given by **Theorem 3.5**, eqs (3.9)–(3.10),
transcribed here from the p.7 page image:

$$\zeta=\Big(\tfrac{\bar u - r}{u - r}\Big)^{\pi/(2\pi-\alpha)}\ \text{(log branch with } \operatorname{Im}\log\in[0,2\pi)\text{)},\qquad
\gamma_\infty(V)=\frac{1}{2\,\operatorname{Im}\zeta}\cdot\frac{\pi}{2\pi-\alpha}\cdot|\bar u-u| .$$

The lattice for $g_1$ is $L = J^{-1}(x+ty+a)+\mathcal{O}_F y+\mathcal{O}_F$ (eq. 2.4), with the
Thm 2.1(i) bounds $|d_1|<p/(3X),\ |d_2|<p/(3Y),\ |d_3|<p/3$ (eq. 3.13). Implemented in
`lens.py` + `capacity.py`; the small box is enumerable exactly, so **no LLL is required and no
dependence on a reducer's behaviour**.

---

## 3. K2 — reconciling `X = N^{1/4}` with R1

**The program's measurement and R1 are about different problems, and R1 does not upgrade it.**

Our row measures: given MSBs (or LSBs) of $p$ for $N=pq$, i.e. $p = 2^{n}\! \cdot\! u + x$ with $|x|
= X$ the unknown tail. The relevant univariate polynomial is degree **1** in the unknown tail and the
unknown tail is a root **modulo the divisor $p$, not modulo $N$**. Writing $f(x) = 2^n u + x$ and
applying Coppersmith with $d = 1$ gives the bound $X < N^{1/d}=N$ *modulo N* — which is not the
$2^{32}$ boundary we measured. The $2^{32}$ boundary is the **partial-information / approximate-gcd**
bound: with $p$ of 64 bits and $\approx$half known, $X\approx p^{1/2}=2^{32}=N^{1/4}$. That is the
Coppersmith **two-variable** / Howgrave-Graham **modulo unknown divisor** problem [Cop97 §4, HG01,
May10] — which R1 §2.3.1 explicitly places outside its scope (quoted verbatim in §1.2 above).

**So:**
* Our 31-works/32-fails measurement is **not** a re-derivation of R1's Theorem 2, and R1 does not
  make it optimal.
* The census's upgrade sentence — *"Upgraded by a literature sweep: this is now also a THEOREM"* —
  **is wrong and must be struck.** It conflates "roots of a *given monic degree-$d$ f$ modulo $N$"
  (R1, settled) with "small roots modulo an *unknown divisor* $p$ of $N$" (not settled by R1).
* **What genuinely can no longer be improved, and by whom:** for a monic degree-$d$ $f\in\mathbb{Z}[x]$,
  no auxiliary polynomial $\sum a_{i,j}x^i(f(x)/N)^j$ of any degree can find roots with $|z| \le
  N^{1/d+\epsilon}$ — **Chinburg, Hemenway, Heninger, Scherr 2016 (arXiv:1605.08065, Thm 2)**. This
  covers e.g. low-public-exponent stereotyped-message RSA, OAEP security, QR/Okamoto-Uchiyama/Paillier
  small roots, and the $(1/d,d)$-SSRSA problem (the paper's own §2.3 list). It does **not** cover
  partial-information factoring.
* **Also settled by R1, and relevant to the constant-axis bookkeeping:** the binomial-polynomial
  variant (Coppersmith's own suggested improvement) cannot beat $N^{1/d}$ for RSA moduli (Thm 4).

**Corrected census row:**

> **Partial-information factoring below ½ the bits of p — MEASURED ONLY. NOT closed.**
> 31 unknown bits WORKS / 32 FAILS at $N=2^{128}$, $X=N^{1/4}$. arXiv:1605.08065 **does not apply**:
> its §2.3.1 lists "factoring RSA moduli $N=pq$ when half of the most or least significant bits of
> one of the factors $p$ is known" as a setting its results do **not** cover. The $N^{1/4}$ boundary is
> the Coppersmith/Howgrave-Graham **modulo-unknown-divisor** bound and remains a *conjecture*, not a
> theorem. What R1 *does* settle is the auxiliary-polynomial form $\sum a_{i,j}x^i(f/N)^j$ for a
> **given monic $f$ modulo $N$** (Thm 2), plus the binomial variant (Thm 4).

---

## 4. K1 — does R2's test fire on a realistic instance?

**Yes, and it is implemented and validated.** Code: `k1_instances.py`, `lens.py`, `capacity.py`;
validation `selftest.py` (all pass) and `validate_lens.py` (all pass).

### 4.1 Scope first (a negative result about R2's reach)

| instance | in R2's scope? | decided? |
|---|---|---|
| 2-sample HNP / partial nonce leak (bits of a secret, linear) | **YES** — R2's Problem 1.1 | **tested below** |
| `p+q` leak ⇒ $x^2-sx+N=0$ | no — univariate quadratic, not R2's form | not decided by R2 |
| partial bits of $d$ (Ernst-style, `u = d mod (p−1)`) | no — multivariate/Herrmann–May | not decided by R2 |
| Herrmann–May n-variable factoring given any bits | no | **not decided by R2** |

### 4.2 The test fires, with a sharp threshold

Realistic 2-sample HNP instances (secret $s$ mod $q$, two partial nonce observations, small errors
$x_i$), 8 random instances at 24-bit $q$: **all 8 return WORKS** ($\gamma \approx 0.005$–$0.09$) —
i.e. a second algebraically independent function provably exists, so the method provably works.

Sweeping $X$ upward on one instance ($q=1035659$, $t=127182$, $a=672079$), $\gamma(\mathcal{E})$ rises
monotonically (Theorem 3.4(3), which I test) and **crosses 1**:

```
            X       gamma(E)  verdict
       10.058567       0.042086  WORKS
       17.913076       0.074950  WORKS
       31.900993       0.133477  WORKS
       56.811758       0.237706  WORKS
      101.174778       0.423325  WORKS
      180.179880       0.753891  WORKS
      320.878284       1.258977  FAIL   <-- fires
```

**Above the crossing, Coppersmith's method provably cannot solve the instance**: every auxiliary
polynomial with the required properties is divisible by $g_1$, so the zero locus is infinite. This is
a *rigorous negative*, not a measurement.

Census over the paper's own regime ($F=\mathbb{Q}$, $J=p\mathbb{Z}$, $X=Y=c\sqrt{p}$, $2/3>c>0$;
$p=1000003$, 5000 $(t,a)$ pairs per row) — **the fire rate is not a rare pathology**:

| $c$ | $X$ | WORKS | FAIL | fire rate |
|---|---|---|---|---|
| 1/8 | 125.0 | 2500 | 2480 | 0.496 |
| 1/6 | 166.7 | 1680 | 3320 | 0.664 |
| 1/5 | 200.0 | 1000 | 3980 | 0.796 |
| 1/4 | 250.0 | 0 | 4980 | **0.996** |
| ≥ 1/3 | ≥333.3 | 0 | 5000 | **1.000** |

So for $X \ge \tfrac13\sqrt p$ the independence assumption **provably fails on every instance tested** —
the multivariate construction is *unavailable*, not merely *unmeasured*.

### 4.3 The self-test returns the null answer where null is correct

The load-bearing check is a direction whose correct answer is "nothing exists". Theorem 4.1(2): with
$a=0$ and $\gamma(\mathcal{E})<1$, there are **no** solutions at all. Brute-forcing every integer
$(x,y)$ in the box on 15095 instances:

* **0 spurious solutions** in any $\gamma<1$ instance (10394 such);
* **861/861** $\gamma<1$ instances have an exactly empty solution set;
* the test is **not vacuous**: 10394 WORKS / 2585 FAIL / 140 knife-edge across the sweep.

This self-test earned its keep. Its **first run failed loudly**, catching a real bug: I had used
Lemma 3.11's **lower bound** (3.16) as an equality, which produced 1712 false "no solutions" verdicts
out of 11372. A second bug — computing the lens crossing points in the unscaled frame while using the
normalised radius, and taking $\alpha$ as the outward-*normal* angle instead of the angle *between the
arcs* (which is what Theorem 3.5's conformal cross-ratio proof implies) — was caught by a scaling-law
test and by the Fekete-stability test in `validate_lens.py` T5. Both are recorded in the code comments
rather than quietly deleted, since each would otherwise be re-introduced.

---

## 5. K3 — the multiplier-`u` case: R1 does not cover it, and it stays open

`D_partialinfo.md:221` describes the gap as: *"`u = d mod (p−1)` with `p` partly known is the
Ernst-style construction; **it is bivariate and needs its own lattice**. Not done here."*

**R1 covers it? No — and this is exactly the case R1 disclaims.** R1's Theorem 2 excludes auxiliary
polynomials of the *given-modulus univariate* form. A partial key exposure attack needs a lattice over
an **unknown divisor** (§1.2, verbatim: "modulo **unknown divisors** of integers ... Adapting these
results to the other settings ... is a direction for future research"). So **K3 is not settled by R1.**

**Is the known-multiplier bound optimal, and at what threshold?** Not established here, and I am not
going to guess a number. What the literature sweep verified (details and URLs in
`factor-scratch/r49exp/pkinfo/lit/SWEEP.md`):

* **Ernst, Jochemsz, May, de Weger, EUROCRYPT 2005**, *Partial Key Exposure Attacks on RSA up to Full
  Size Exponents*, LNCS pp. 371–386, DOI `10.1007/11426639_22` — confirmed via Crossref. **Not on IACR
  eprint** (4 searches), and the Springer PDF is behind a client-challenge interstitial, so **I could
  not read the primary text.**
* Its attack condition is verified **only as a verbatim restatement** in eprint 2018/516
  (Takayasu–Kunihiro) p. 16: $\delta < \tfrac56 - \tfrac13\sqrt{1+6\beta}$, which they independently
  re-prove in their §4.3. Numerically consistent with their Table 1.
* **The exact "multiplier $u$ known exactly" threshold was NOT FOUND** in any accessible primary
  source on this host. I decline to attribute a formula to Ernst et al. on this evidence.

**K3 verdict: OPEN.** It is the one listed gap that survives, and it is a genuine gap rather than an
unimplemented convenience — the bound that governs it is not the one R1 optimises.

---

## 6. Literature status of the independence heuristic (as of 2026)

Sweep finding, all from PDFs actually downloaded: **the algebraic-independence heuristic is still
unproven**, and is stated as a live assumption in current work.

* **eprint 2024/1330 (CRYPTO 2025)**, Feng–Luo–Chen–Nitaj–Pan, *Computing Asymptotic Bounds for Small
  Roots in Coppersmith's Method via Sumset Theory*, **p. 11**:
  > "**Assumption 1.** The polynomials obtained from the LLL-reduced basis in Coppersmith's method
  > generate an ideal corresponding to a zero-dimensional variety."
* **eprint 2024/1577 (EUROCRYPT 2025)**, Keegan–Ryan, *Solving Multivariate Coppersmith Problems with
  Known Moduli*, **p. 6**, labels it "**Heuristic 1**".

No follow-up to 2111.14180 by any of the four authors (complete arXiv listings enumerated). arXiv
`all:"Coppersmith" AND all:"capacity"` returns **totalResults = 2** — exactly the two papers above.

⚠️ **A citation trap recorded so it is not repeated:** eprint **2007/374** (Herrmann–May, *On Factoring
Arbitrary Integers with Known Bits*) is a **different paper** from the ASIACRYPT 2008 *Solving Linear
Equations Modulo Divisors*. 2007/374 is **rigorous** — its own PDF says it *"does not depend on a
heuristic assumption"* — and its $(1-\tfrac1r H_r)\log N$ bound must **not** be cited as the
ASIACRYPT'08 heuristic threshold.

---

## 7. K4 — closure verdict

> ### The partial-information axis is **NOT CLOSED.**
>
> The program believed two lit-sweep sentences settled it. Both are real quotations; both are
> about **narrower** problems than the census row, and R1 says so on p.6 in as many words.

**Settled by this round:**

| item | status |
|---|---|
| Coppersmith univariate bound for a **given monic degree-$d$ $f$ mod $N$ is optimal | **CLOSED** — Chinburg et al. 2016, Thm 2 (arXiv:1605.08065 p.2). No auxiliary polynomial $\sum a_{i,j}x^i(f/N)^j$ of any degree, any running time. |
| Binomial-polynomial variant cannot beat $N^{1/d}$ for RSA moduli | **CLOSED** — Thm 4 (p.2). |
| Two-variable **linear** Coppersmith independence is **decidable** | **CLOSED, and implemented + validated here.** Test fires: γ>1 ⇒ method provably impossible; fire rate 1.000 for $X\ge\tfrac13\sqrt p$. |
| Multivariate algebraic independence | **OPEN.** Still "Assumption 1"/"Heuristic 1" in CRYPTO 2025 and EUROCRYPT 2025. |
| Partial-information factoring at $X=N^{1/4}$ | **OPEN — a conjecture, not a theorem.** R1 §2.3.1 explicitly excludes it. |
| Multiplier-`u` / known-multiplier partial key exposure | **OPEN.** Outside R1's scope; exact threshold not located in accessible primary sources. |

**The census row must be struck back to "MEASURED, NOT OPTIMAL."** The upgrade sentence in
`Round48_SUMMARY.md:209` ("this is now also a THEOREM") and the one at line 393 are **not supported by
the cited source** and should be corrected. R1 is a strong and genuinely useful result; it just is
not about this row.

**Residue, stated precisely.** What remains is *one* question, not three:

> **Is $X = N^{1/4}$ optimal for partial-information factoring of $N=pq$, and does the known-multiplier
> variant have an optimal bound of its own?**

Both are cases of Coppersmith/Howgrave-Graham **modulo an unknown divisor** — the capacity problem R1
calls, in its own conclusion, *"joint capacities of many adelic sets, a topic which has not been
developed to our knowledge."*

**What would settle it.** A capacity-theory theorem in the style of R1, but for the adelic set
attached to a small root modulo an **unknown divisor** $p \mid N$ — i.e. R1 §2.3.1's "direction for
future research". Concretely: show that for the appropriate adelic set $\mathcal{E}_{\text{div}}$ no
auxiliary polynomial exists once $X > N^{1/4}$, and separately that the known-multiplier lattice admits
no better bound. Nothing in the present literature does this, and R2's method does not transfer to it —
R2's decisive simplification was that the first auxiliary function is **linear** and its zero locus
is an affine line, so the problem reduces to **one-variable** capacity theory on $\mathbb{P}^1$; in the
divisor setting the zero locus is a higher-dimensional variety and the machinery (capacities of finite
morphisms to $\mathbb{P}^n$, [Chi91, RLV00, CMBPT15]) is exactly what R2 calls undeveloped.

---

### Provenance / honesty notes
- Both PDFs downloaded from `arxiv.org/pdf/`, SHA-consistent page counts (22 and 15 pp.), metadata
  re-confirmed through the arXiv API. Every formula quoted above was read from a **rendered page
  image**; `pdftotext` was used only to navigate.
- No WebSearch, no search-engine WebFetch. The sub-sweep used only eprint HTML search, direct eprint
  URLs, the arXiv API, and Crossref.
- Two of my own implementation bugs were found by self-tests that returned the null answer, and are
  documented in place rather than removed. The first (treating a lower bound as an equality) produced
  1712 false negatives; the second (frame mismatch + wrong angle) was caught by a scaling-law
  invariant and by Fekete stability.
- Negative control for the Fekete routine: it reproduces the unit circle's exact $d_n = n^{1/(n-1)}$
  to 6 digits, which is what licenses using $d_n$ as an upper bound on capacity.
- Not established: the exact known-multiplier threshold (source inaccessible); any claim about
  multivariate independence beyond the two-variable linear case; any improvement or optimality claim
  for partial-information factoring.
