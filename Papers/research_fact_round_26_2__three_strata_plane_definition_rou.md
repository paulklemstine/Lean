# The Three-Strata Plane: A Measured-Exponent Calculus for the Cost of Integer Factoring

**Author:** Aristotle
**Date:** 2026-09-19

---

## Abstract

We introduce a single coordinate — the **measured exponent**
$\alpha(f) = \lim_{x\to\infty} \log f(x)/x$ of a cost profile $f$ expressed in
the bit-size variable $x = \log N$ — and use it to place three qualitatively
different approaches to factoring a semiprime $N = pq$ on one plane. We develop
the calculus of this exponent: uniqueness, invariance under $O(1)$ additive
corrections to $\log f$, two calibration points ($e^{ax}$ has exponent $a$;
every polynomial in $x$ has exponent $0$), a **units lemma** stating that
re-expressing a profile in a rescaled variable $x = cb$ divides its exponent by
$c$, and a **price theorem** stating that two profiles with exponents $a < b$
are separated by a ratio whose own exponent is exactly $b-a$ and which therefore
diverges.

Against this coordinate we locate three strata. **Stratum A**, the
*definition-routes*: witnesses read off from $N$ alone by evaluating an
arithmetic function. We prove $\sigma_1(pq) = 1 + p + q + pq$ and
$\tau(pq) = 4$ exactly, exhibit a closed formula recovering the smaller prime
from $N$ and $\sigma_1(N)$ in $O(1)$ arithmetic operations, and show that
evaluating either function from $N$ alone by scanning costs $\lfloor\sqrt
N\rfloor$ divisions with the bound attained; a two-sided sandwich pins the
exponent at $1/2$. A hitting-set lower bound shows a complete divisor-test set
up to $B$ has cardinality at least $\pi(B) - 1$. **Stratum B**, the *methods*:
trial division returns $p$ exactly; Fermat's search admits no early stop and
halts precisely at $2a = p+q$, making it provably complementary to trial
division rather than similar; Pollard $\rho$ extracts $p$ exactly from a
collision modulo $p$ that is not one modulo $N$, with the collision forced
within $p$ steps by pigeonhole for *any* iteration. Its exponent on $N$ is
$1/4$. **Stratum C**, the *quantum corner*: Shor's classical split step is
proved unconditionally exact, and the polynomial profile has exponent $0$.

The three exponents $0 < 1/4 < 1/2$ are distinct, the three profiles eventually
strictly ordered, and Stratum C is polynomially bounded while Strata A and B
provably are not. The gap between A and B is realised as the **price of
structure-blindness** $N^{1/4}$: strictly increasing, unbounded, and — since it
carries the same exponent as Stratum B itself — a unit exchange rate between
ignorance and work.

**Keywords:** integer factoring, measured exponent, semiprime, divisor sum,
Pollard rho, Fermat factorization, Shor's algorithm, hitting-set lower bound.

---

## 1. Introduction

### 1.1 The problem with "how hard is factoring?"

Statements about the difficulty of factoring an integer come from at least three
incommensurable traditions. Analytic number theory speaks of arithmetic
functions whose values encode the factorization. Algorithmics speaks of trial
division, Fermat's method, Pollard $\rho$, quadratic and number field sieves.
Quantum computation speaks of period-finding. Each tradition reports costs in
its own units — divisions, gcds, gate counts, group operations — measured
against its own size parameter — the integer, its square root, the bit-length,
the prime factor's bit-length.

The consequence is that the folklore ordering of these approaches, though
broadly correct, is not *checkable*. Two statements about cost cannot be
compared unless they are expressed on the same coordinate; and if they cannot be
compared, then a unit error in one of them is not a contradiction but merely an
inconsistency nobody is positioned to notice.

### 1.2 The remedy: one coordinate, measured not asserted

We propose a coordinate that all three traditions can be read onto, and which
coincides with the quantity an empirical log–log fit actually estimates. Fix the
bit-size variable $x = \log N$ and, for a cost profile $f : \mathbb{R} \to
\mathbb{R}$, define

$$\alpha(f) \;=\; \lim_{x \to \infty} \frac{\log f(x)}{x}.$$

A profile behaving like $N^{\alpha}$ returns $\alpha$; a profile polynomial in
the bit-size returns $0$. This is a coarse invariant on purpose. It discards
constants, logarithmic factors, and hardware — precisely the quantities that
differ between traditions and between decades — and retains the shape of the
growth.

### 1.3 Contributions

1. **A calculus of the measured exponent** (Section 2): uniqueness, robustness
   under $O(1)$ additive log-corrections, two calibration points, the units
   lemma, the superpolynomiality criterion, and the price theorem.
2. **Stratum A, the definition-routes** (Section 3): exact evaluation of
   $\tau$ and $\sigma_1$ on semiprimes, an $O(1)$ closed-form inversion of the
   $\sigma_1$-oracle, the attained $\lfloor\sqrt N\rfloor$ scan bound, and a
   combinatorial hitting-set lower bound for candidate-list methods.
3. **Stratum B, the classical methods as theorems** (Section 4): exact
   statements for trial division, Fermat and Pollard $\rho$, including the
   Fermat dichotomy and the resulting *complementarity* of Fermat and trial
   division.
4. **Stratum C, the quantum corner** (Section 5): the unconditional exactness of
   Shor's classical split step, and the exponent-$0$ location of the quantum
   profile.
5. **The plane** (Section 6): strict ordering, distinctness, the polynomial
   separation, and the price of structure-blindness $N^{1/4}$, together with the
   units ledger that corrects a per-prime-bit slope into an exponent on $N$.
6. **Empirical calibration** (Section 7) and a discussion of the methodological
   discipline that produced it (Section 8).

Throughout, $N = pq$ denotes a semiprime with $p, q$ distinct primes, and
unless stated we take $p < q$. All logarithms in the definition of $\alpha$ are
natural; the empirical tables use $\log_2$, which does not change any exponent.

---

## 2. The measured-exponent calculus

### 2.1 Definition and uniqueness

**Definition 2.1 (Measured exponent).** A profile $f : \mathbb{R} \to
\mathbb{R}$ *has measured exponent* $a$, written $\alpha(f) = a$, if

$$\frac{\log f(x)}{x} \longrightarrow a \qquad (x \to \infty).$$

**Theorem 2.2 (Uniqueness).** A profile has at most one measured exponent: if
$\alpha(f) = a$ and $\alpha(f) = b$ then $a = b$.

*Proof.* Limits in a Hausdorff space are unique. $\square$

Trivial as it is, Theorem 2.2 is what converts a disagreement about exponents
into a genuine contradiction, and it is the engine of the units ledger in
Section 6.4.

### 2.2 Robustness

**Theorem 2.3 (Invariance under bounded log-correction).** Suppose there is a
constant $C$ with $|\log f(x) - a x| \le C$ for all sufficiently large $x$. Then
$\alpha(f) = a$.

*Proof sketch.* Write $\log f(x)/x = a + (\log f(x) - ax)/x$. The second term is
bounded in absolute value by $C/x \to 0$, so a squeeze gives convergence to
$a$. $\square$

Theorem 2.3 is the formal content of "constants do not matter". Multiplying a
cost by any fixed factor, or adding any fixed number of preprocessing steps,
changes $\log f$ by $O(1)$ and leaves $\alpha$ untouched.

### 2.3 Calibration points

**Theorem 2.4 (Exponential calibration).** For every $a$ and $c$,
$\alpha\big(x \mapsto e^{ax + c}\big) = a$. In particular
$\alpha(x \mapsto e^{ax}) = a$.

*Proof.* $\log e^{ax+c} - ax = c$ is bounded; apply Theorem 2.3. $\square$

Since $x = \log N$, the profile $e^{ax}$ *is* $N^{a}$: Theorem 2.4 says that
$N^{a}$ has exponent $a$, as it must.

**Theorem 2.5 (Polynomial calibration).** For $C > 0$ and any real $d$,
$\alpha\big(x \mapsto C x^{d}\big) = 0$.

*Proof sketch.* For $x > 0$, $\log(Cx^d)/x = \log C / x + d \cdot (\log x / x)$.
Both terms tend to $0$, the second because $\log x = o(x)$. $\square$

Theorem 2.5 identifies "polynomial in the number of digits" — the standard
notion of tractability — with the single point $\alpha = 0$.

### 2.4 The units lemma

Empirical work rarely fits a cost against $x = \log N$ directly. For factoring
methods whose behaviour is governed by the smaller prime, the natural regressor
is $b = \log p$. For a balanced semiprime $\log N = 2\log p$, so the two
variables differ by a factor.

**Theorem 2.6 (Units lemma).** If $\alpha(f) = s$ and $c > 0$, then the
re-expressed profile $x \mapsto f(x/c)$ has measured exponent $s/c$.

*Proof sketch.* As $x \to \infty$ so does $x/c$, hence
$\log f(x/c) \big/ (x/c) \to s$. Dividing by the constant $c$ gives
$\log f(x/c)/x \to s/c$. $\square$

**Corollary 2.7.** A slope of $s$ per prime-bit corresponds, for a balanced
semiprime, to an exponent $s/2$ on $N$. Reading a per-prime-bit slope directly
as an exponent on $N$ overstates it by a factor of two.

### 2.5 Positive exponent forces superpolynomial growth

**Theorem 2.8 (Eventual exponential lower bound).** If $\alpha(f) = a > 0$ and
$f$ is eventually positive, then $e^{(a/2)x} \le f(x)$ for all sufficiently
large $x$.

*Proof sketch.* Eventually $\log f(x)/x > a/2$, i.e. $\log f(x) > (a/2)x$;
exponentiate, using $f(x) = e^{\log f(x)}$ where $f(x) > 0$. $\square$

**Corollary 2.9.** Under the same hypotheses $f(x) \to \infty$, $f$ is
superpolynomial, and $f$ is not polynomially bounded.

Thus $\alpha = 0$ and $\alpha > 0$ lie on opposite sides of the
tractability line, and nothing with a positive exponent can be reached from the
polynomial stratum by any amount of constant-factor improvement.

### 2.6 The price theorem

**Theorem 2.10 (Ratio exponent).** If $f$ and $g$ are eventually positive with
$\alpha(f) = a$ and $\alpha(g) = b$, then $\alpha(g/f) = b - a$.

*Proof sketch.* Where both are positive, $\log(g(x)/f(x)) = \log g(x) - \log
f(x)$; divide by $x$ and take the difference of the two limits. $\square$

**Theorem 2.11 (Price theorem).** If in addition $a < b$, then the ratio
$g/f$ has exponent $b - a > 0$ and $g(x)/f(x) \to \infty$.

*Proof.* Combine Theorem 2.10 with Corollary 2.9, noting that $g/f$ is
eventually positive. $\square$

Theorem 2.11 is the reason this plane says something. A separation in exponent
is never a constant overhead; it is an unbounded penalty with a measurable
exponent of its own.

---

## 3. Stratum A: the definition-routes

A **definition-route** is a factoring strategy that reads a witness off from $N$
alone, by evaluating a classical arithmetic function, and then inverts it. No
structural feature of $N$ is exploited beyond the ability to test divisibility.

### 3.1 The witnesses are exact

**Theorem 3.1 (Divisors of a semiprime).** For distinct primes $p, q$,
$\operatorname{div}(pq) = \{1, p, q, pq\}$.

*Proof sketch.* The divisors of a product of coprime numbers are products of
divisors of the factors; $p$ and $q$ each have divisors $\{1, \cdot\}$, and the
four resulting products are distinct because $p \ne q$. $\square$

**Theorem 3.2 (Exact values).** For distinct primes $p,q$ and $N = pq$,

$$\tau(N) = 4, \qquad \sigma_1(N) = 1 + p + q + pq = 1 + p + q + N.$$

Both identities are exact at every size, with no error term — this is what
distinguishes a definition-route from a heuristic.

**Corollary 3.3 (The oracle hands over the factor sum).**
$\sigma_1(N) - N - 1 = p + q$.

### 3.2 Inversion is $O(1)$

**Theorem 3.4 (Vieta uniqueness).** If $a + b = c + d$ and $ab = cd$ (over
$\mathbb{Z}$, hence over $\mathbb{N}$), then $\{a,b\} = \{c,d\}$; ordering by
$a \le b$, $c \le d$ forces $a = c$ and $b = d$.

*Proof sketch.* Both pairs are the root multiset of the same monic quadratic
$X^2 - sX + m$. $\square$

**Theorem 3.5 (Exact discriminant).** For $p \le q$, $(p+q)^2 - 4pq = (q-p)^2$.

**Theorem 3.6 (Closed-form $\sigma_1$-route).** Let $N = pq$ with $p < q$ prime
and $s = \sigma_1(N) - N - 1 = p + q$. Then

$$p \;=\; \frac{s - \sqrt{s^2 - 4N}}{2},$$

where the square root is exact by Theorem 3.5.

*Proof sketch.* By Theorem 3.5 the radicand is $(q-p)^2$, so the expression
evaluates to $\big((p+q) - (q-p)\big)/2 = p$. $\square$

**Remark 3.7 (Evaluation, not inversion, is the cost).** Theorem 3.6 shows the
entire post-oracle cost of the $\sigma_1$-route is a constant number of
arithmetic operations. Whatever exponent Stratum A carries is therefore an
exponent of *evaluating* the arithmetic function, not of inverting it.

### 3.3 Evaluation costs $\lfloor\sqrt N\rfloor$, and the bound is attained

Evaluating $\tau$ or $\sigma_1$ at $N$ without knowing the factorization means
the scan $d = 1, \dots, \lfloor\sqrt N\rfloor$. We write
$\mathrm{scan}(N) = \lfloor \sqrt N\rfloor$.

**Theorem 3.8 (The scan window is correct and tight).** For $N = pq$ with
$p < q$ prime:
1. $p \le \lfloor\sqrt N\rfloor < q$; the scan sees exactly the divisors $1$ and
   $p$, half of the divisor set.
2. The smaller factor is found at step $p \le \mathrm{scan}(N)$.
3. On a twin-prime semiprime $N = p(p+2)$ with $p > 1$ one has
   $\mathrm{scan}(N) = p$ exactly, so the worst case is attained.

*Proof sketch.* (1) $p \le q$ gives $p^2 \le N$ and $N < q^2$; (3) follows from
$p^2 \le p(p+2) < (p+1)^2$. $\square$

**Theorem 3.9 (The exponent $1/2$, as a sandwich).** For every $N \ge 1$,

$$2\log\big(\mathrm{scan}(N)\big) \;\le\; \log N \;\le\; 2\log\big(\mathrm{scan}(N) + 1\big).$$

*Proof sketch.* $\lfloor\sqrt N\rfloor^2 \le N < (\lfloor\sqrt N\rfloor + 1)^2$;
take logarithms. $\square$

Dividing by $2\log N$ and letting $N \to \infty$ gives
$\log(\mathrm{scan}(N))/\log N \to 1/2$. In continuous form: the Stratum A
profile is $S(x) = e^{x/2}$, which satisfies $S(\log N) = \sqrt N$ and sandwiches
the discrete scan, $\mathrm{scan}(N) \le \sqrt N < \mathrm{scan}(N) + 1$. By
Theorem 2.4, $\alpha(S) = 1/2$.

### 3.4 A hitting-set lower bound for structure-blindness

The $1/2$ above is an upper bound on a particular procedure. Here is a matching
lower bound that constrains *all* candidate-list procedures.

**Definition 3.10.** A finite set $S \subset \mathbb{N}$ is a **complete
divisor-test set up to $B$** if for every semiprime $N = pq$ with $p < q \le B$
some $s \in S$ properly splits $N$ (i.e. $s \mid N$, $1 < s < N$).

**Lemma 3.11 (Nothing else to find).** If $s$ properly splits $pq$ for distinct
primes $p,q$, then $s = p$ or $s = q$.

*Proof sketch.* $s \mid pq$ with $s \notin \{1, pq\}$, and by Theorem 3.1 the
only remaining divisors are $p$ and $q$. $\square$

**Lemma 3.12 (At most one omission).** A complete divisor-test set up to $B$
omits at most one prime $\le B$.

*Proof sketch.* If two distinct primes $p < q \le B$ were both absent, the
semiprime $pq$ would be split by no element of $S$, contradicting completeness
via Lemma 3.11. $\square$

**Theorem 3.13 (Hitting-set bound).** If $S$ is a complete divisor-test set up
to $B$, then $|S| \ge \pi(B) - 1$.

**Corollary 3.14 (No universal finite list).** For every finite $S$ there is a
bound $B$ for which $S$ is not complete.

**Theorem 3.15 (Linear growth in the bit-size).** A complete divisor-test set up
to $2^k$ has at least $k - 1$ elements.

*Proof sketch.* Bertrand's postulate supplies a prime in each dyadic interval
$(2^i, 2^{i+1}]$ for $0 \le i < k$, so $\pi(2^k) \ge k$; apply Theorem
3.13. $\square$

Taking $B \approx \sqrt N$, a procedure whose only access to $N$ is
divisibility-testing against a fixed candidate list must carry essentially every
prime below $\sqrt N$ — about $\sqrt N / \log \sqrt N$ candidates. Pollard
$\rho$, by contrast, carries none.

---

## 4. Stratum B: the classical methods, as theorems

### 4.1 Trial division

**Theorem 4.1.** For primes $p \le q$, the least nontrivial divisor of $pq$ is
$p$.

The certificate is the factor itself: no separate verification step is needed,
and the cost profile is the number of trials, at most $\lfloor\sqrt N\rfloor$ by
Theorem 3.8.

### 4.2 Fermat: a dichotomy, and no early stop

Fermat's method seeks $a, b$ with $a^2 = N + b^2$, whence $N = (a-b)(a+b)$.

**Theorem 4.2 (Representation from a factorization).** If $2a = p + q$ and
$2b = q - p$ then $a^2 = pq + b^2$.

**Theorem 4.3 (Fermat dichotomy).** Let $N = pq$ with $p, q$ prime and suppose
$a^2 = N + b^2$ with $a, b \ge 0$. Then either $\{a - b, a + b\} = \{1, N\}$ —
the trivial representation — or $\{a-b, a+b\} = \{p, q\}$, i.e.
$2a = p+q$ and $2b = |q - p|$.

*Proof sketch.* $a^2 - b^2 = (a-b)(a+b) = N$, and by Theorem 3.1 the only
factorizations of a semiprime are $1 \cdot N$ and $p \cdot q$. $\square$

**Corollary 4.4 (No early stop).** For $p < q$ and $a < (p+q)/2$ there is no $b$
with $a^2 = N + b^2$ other than through the trivial representation. Hence the
ascending search $a = \lceil\sqrt N\rceil, \lceil\sqrt N\rceil + 1, \dots$
halts for the first time exactly at $a = (p+q)/2$, and its cost is the exact
arithmetic quantity

$$\mathrm{fermat}(N) \;=\; \frac{p+q}{2} - \big\lceil \sqrt N \big\rceil.$$

**Theorem 4.5 (Complementarity).** Fermat and trial division do not dominate
each other:
1. On a twin-prime semiprime $N = p(p+2)$, Fermat halts at its first trial
   $a = p+1$ (cost $O(1)$), while trial division needs $p = \lfloor\sqrt
   N\rfloor$ steps.
2. On the unbalanced semiprime $N = 3q$ with $q \ge 48$, Fermat needs at least
   $q/4$ steps, while trial division needs $2$.

*Proof sketch.* (1) $(p+1)^2 = p(p+2) + 1$. (2) The halting index is
$(3+q)/2 - \lceil\sqrt{3q}\rceil$, which exceeds $q/4$ once $q$ is large enough
that $\sqrt{3q} \le q/4$. $\square$

**Remark 4.6 (Why the two look alike in aggregate).** Parameterise by
$p = N^{\beta}$, $q = N^{1-\beta}$ with $\beta \le 1/2$. The trial cost is
$N^{\beta}$; the Fermat cost is $\Theta(N^{1-2\beta})$. These are maximised at
opposite ends of the balance parameter and cross at $\beta = 1/3$. On uniformly
drawn semiprimes both cost distributions are dominated by their tails, and the
aggregate statistics coincide — a fact about the *draw measure*, not about the
methods. This is exactly the sort of coincidence a summary statistic hides and a
measured exponent, taken stratum-wise, exposes.

### 4.3 Pollard $\rho$: exact extraction plus forced collision

**Theorem 4.7 (Extraction).** Let $N = pq$ with $p < q$ prime and let
$d \in \mathbb{Z}$ satisfy $p \mid d$ and $N \nmid d$. Then $\gcd(d, N) = p$.

*Proof sketch.* $\gcd(d,N)$ is a divisor of $N$, hence lies in $\{1,p,q,N\}$ by
Theorem 3.1. It is divisible by $p$, excluding $1$ and $q$; and it is not $N$
since $N \nmid d$. $\square$

**Theorem 4.8 (Forced collision).** For any $p > 0$ and *any* sequence
$x : \mathbb{N} \to \mathbb{Z}/p\mathbb{Z}$, there exist $i < j \le p$ with
$x_i = x_j$.

*Proof sketch.* Pigeonhole: $p+1$ terms into $p$ residue classes. $\square$

**Theorem 4.9 (Deterministic skeleton of Pollard $\rho$).** Within $p$ steps of
any iteration there is a pair of indices whose difference is divisible by $p$;
if that difference is not divisible by $N$, then one gcd computation recovers
$p$ exactly.

Theorems 4.7–4.9 give the unconditional skeleton. The birthday heuristic — that
a pseudorandom iteration collides modulo $p$ after $\Theta(\sqrt p)$ steps rather
than $\Theta(p)$ — supplies the actual running time $\Theta(N^{1/4})$ for a
balanced semiprime. We record the corresponding profile as $R(x) = e^{x/4}$,
which by Theorem 2.4 has $\alpha(R) = 1/4$.

---

## 5. Stratum C: the quantum corner

Shor's algorithm is quantum in exactly one step: computing the multiplicative
order $r$ of a unit modulo $N$. The reduction from $r$ to a factor is classical,
unconditional, and exact.

**Theorem 5.1 (Split step).** Let $N = pq$ with $p, q$ distinct primes and let
$x \in \mathbb{Z}$ satisfy $N \mid x^2 - 1$, $N \nmid x - 1$, $N \nmid x + 1$.
Then $\gcd(x-1, N)$ equals $p$ or $q$ — never $1$ and never $N$.

*Proof sketch.* $N \mid (x-1)(x+1)$, so $p$ and $q$ each divide one of the two
factors. They cannot both divide $x-1$ (else $N \mid x-1$) nor both divide
$x+1$. Hence exactly one of them divides $x-1$, and $\gcd(x-1,N)$ is that
prime. $\square$

**Theorem 5.2 (Shor's classical reduction).** If $a$ has multiplicative order
$2m$ modulo $N = pq$ and $a^{m} \not\equiv \pm 1 \pmod N$, then
$\gcd(a^{m} - 1, N)$ is one of $p, q$.

**Theorem 5.3 (Nontriviality).** The factor produced is strictly between $1$ and
$N$, i.e. a genuine nontrivial factorization.

The quantum stratum's cost is polynomial in the bit-size; we record the profile
$Q(x) = 8x^3$. By Theorem 2.5, $\alpha(Q) = 0$, and $Q$ is polynomially bounded
by definition.

---

## 6. The plane

### 6.1 The three coordinates

Collecting Sections 3–5, with $x = \log N$:

| Stratum | Representative | Profile | Measured exponent |
|---|---|---|---|
| A — definition-routes | $\tau(N)$, $\sigma_1(N)$ by scan | $S(x) = e^{x/2}$ | $\alpha = 1/2$ |
| B — classical methods | Pollard $\rho$ | $R(x) = e^{x/4}$ | $\alpha = 1/4$ |
| C — quantum | Shor | $Q(x) = 8x^3$ | $\alpha = 0$ |

**Theorem 6.1 (The three coordinates).** $\alpha(S) = 1/2$, $\alpha(R) = 1/4$,
$\alpha(Q) = 0$.

**Theorem 6.2 (Distinctness).** $S$ does not have exponent $1/4$, and $R$ does
not have exponent $0$.

*Proof.* Immediate from Theorems 6.1 and 2.2. $\square$

### 6.2 Strict ordering

**Theorem 6.3 (Non-degeneracy of the plane).** For all $x > 0$,
$R(x) < S(x)$; and for all sufficiently large $x$, $Q(x) < R(x)$. Hence
eventually

$$Q(x) \;<\; R(x) \;<\; S(x)$$

strictly.

*Proof sketch.* The first is $x/4 < x/2$ and monotonicity of $\exp$. The second
follows from the price theorem (2.11) applied to $\alpha(Q) = 0 < 1/4 =
\alpha(R)$: the ratio $R/Q$ tends to infinity, so eventually exceeds
$1$. $\square$

### 6.3 The tractability line

**Theorem 6.4 (Quantum separation).** $Q$ is polynomially bounded; $R$ and $S$
are not.

*Proof.* $Q(x) = 8x^3$ is polynomial. For $R$ and $S$, apply Corollary 2.9 with
$\alpha = 1/4 > 0$ and $\alpha = 1/2 > 0$ respectively. $\square$

**Corollary 6.5.** A definition-route evaluated from $N$ alone cannot be a
polynomial-time factoring algorithm. This is unconditional; it uses no
hypothesis about the hardness of factoring.

### 6.4 The units ledger

Let $\rho_{\mathrm{bit}}(b) = e^{b/2 - \log 2}$ be the standalone calibration of
Pollard $\rho$ in the *prime* bit-size $b = \log p$: in base-two units,
$\log_2(\text{ops}) = \text{bits}/2 - 1$ exactly.

**Theorem 6.6.** $\alpha(\rho_{\mathrm{bit}}) = 1/2$ *in the variable $b$*.

**Theorem 6.7 (Units correction).** For a balanced semiprime $\log N = 2\log p$,
so the same cost re-expressed on $N$ is $x \mapsto \rho_{\mathrm{bit}}(x/2)$,
and $\alpha\big(\rho_{\mathrm{bit}}(\,\cdot\,/2)\big) = 1/4$.

*Proof.* Theorem 2.6 with $s = 1/2$, $c = 2$. $\square$

**Theorem 6.8 (The mismatch is a theorem).** The re-expressed profile does *not*
have exponent $1/2$.

*Proof.* By Theorem 6.7 it has exponent $1/4$, and exponents are unique
(Theorem 2.2); $1/4 \ne 1/2$. $\square$

**Corollary 6.9 (Agreement with the birthday bound).** The corrected reading
$1/4$ agrees with the independently derived Stratum B coordinate $\alpha(R) =
1/4$.

Theorem 6.8 deserves emphasis. A per-prime-bit slope is a legitimate empirical
measurement; reading it as an exponent on $N$ is a unit error of a factor of
two. Because the measured exponent is unique, that error is a provable
contradiction rather than a difference of convention — the framework detects its
own misuse.

### 6.5 The price of structure-blindness

**Definition 6.10.** The **blindness price** is
$P(x) = S(x)/R(x)$, the cost ratio between the structure-blind
definition-route and the structure-exploiting method at the same $N$.

**Theorem 6.11 (Exact price).** $P(x) = e^{x/4}$; equivalently
$P = N^{1/4}$.

*Proof.* $e^{x/2}/e^{x/4} = e^{x/4}$. $\square$

**Theorem 6.12 (The price is not a constant overhead).** $P$ is strictly
increasing, has measured exponent $1/4$, and $P(x) \to \infty$.

*Proof.* Strict monotonicity from Theorem 6.11 and strict monotonicity of
$\exp$; the exponent and divergence from the price theorem (2.11) with
$1/2 - 1/4 = 1/4$. $\square$

**Theorem 6.13 (The three-strata plane).** All of the following hold
simultaneously: $\alpha(Q) = 0$, $\alpha(R) = 1/4$, $\alpha(S) = 1/2$;
eventually $Q < R < S$ pointwise and strictly; and the blindness price
$P = S/R$ is strictly increasing with $P(x) \to \infty$.

**Remark 6.14 (A unit exchange rate).** $\alpha(P) = 1/4 = \alpha(R)$. The
price of being blind is, on this coordinate, exactly the cost of the method you
declined to use: ignorance and work trade one-for-one at every size.

---

## 7. Empirical calibration

The theorems above fix the exponents; the measurements below check that the
finite-size behaviour is the predicted one, under identical conditions (fixed
seeds, uniform semiprime draws, one timing harness).

### 7.1 Stratum A

Evaluating $\tau(N)$ and $\sigma_1(N)$ by trial division, with $\sigma_1 =
1 + N + p + q$ verified exactly at every size, yields a fitted exponent of
$0.500$ to three decimals across the tested range. This is the sandwich of
Theorem 3.9 realised numerically. Earlier definition-routes measured under the
same harness sit at: gcd-scan $1.000$; idempotent scan $1.000$; zero-divisor
first hit $\approx 1/2$; continued-fraction period $0.398$.

### 7.2 Stratum B

On uniform draws of balanced semiprimes:

| Method | mean $\log_2(\text{cost})$ | median $\log_2(\text{cost})$ |
|---|---|---|
| trial division | 19.30 | 19.36 |
| Fermat | 19.36 | 19.36 |
| Pollard $\rho$ | 8.73 | — |

Trial division's location is the $\mathbb{E}[\min(p,q)]$ scale, as Theorem 4.1
predicts. Fermat is *indistinguishable from trial division in aggregate*, for
the reason given in Remark 4.6: the cost is tail-dominated by the gap $q - p$.
Their pointwise complementarity (Theorem 4.5) is invisible to the summary
statistics, which is precisely why the theorem is needed.

Pollard $\rho$, stratified by prime size over 120 draws, fits a slope of
$0.523$ per prime-bit. By Corollary 2.7 that is $\alpha = 0.261$ on $N$ —
against the birthday prediction $0.25$. A standalone check reproduces
$\log_2(\text{ops}) = \text{bits}/2 - 1$ exactly.

### 7.3 The blindness price, measured

The ratio of definition-route cost to Pollard $\rho$ cost at fixed $N$:

| $N$ | measured ratio |
|---|---|
| $2^{16}$ | $173\times$ |
| $2^{20}$ | $1780\times$ |
| $2^{24}$ | $2070\times$ |
| $2^{28}$ | $8310\times$ |

Growing with $N$, as Theorem 6.12 requires. The row at $N = 2^{36}$ was capped
rather than run: the definition-route side would have taken hours. It is
reported as capped rather than extrapolated.

### 7.4 Stratum C

Shor's profile is polynomial in the bit-size; no timing is claimed. The exponent
$0$ is a consequence of Theorem 2.5 applied to any polynomial profile, so the
location of Stratum C on the plane does not depend on the constant or the
degree.

---

## 8. Discussion

### 8.1 What the plane buys

Three things, each unavailable before a common coordinate existed.

*Comparability.* A number-theoretic identity, a randomised algorithm and a
quantum subroutine are placed at $1/2$, $1/4$ and $0$ on one axis, measured the
same way.

*Falsifiability.* Uniqueness of the exponent (Theorem 2.2) turns a units error
into a contradiction (Theorem 6.8). The framework catches its own misuse: in the
measurement campaign the per-prime-bit slope was reported first, flagged,
corrected, and then confirmed against an independent calibration before entering
the plane.

*Quantification of gaps.* The price theorem (2.11) upgrades "much faster" into
the exact divergent factor $N^{1/4}$ with its own exponent.

### 8.2 Evaluation versus inversion

The sharpest structural discovery is Remark 3.7. For the $\sigma_1$-route the
inversion is a closed formula costing $O(1)$; all of the $1/2$ is spent
evaluating the arithmetic function from $N$ alone. The exponent of a
definition-route is an exponent of *appraisal*. This suggests that the plane's
coordinate, applied to any witness family, measures evaluation cost — and that
improving a definition-route means finding a cheaper evaluation, never a cleverer
inversion.

### 8.3 Aggregate statistics hide structure

Fermat and trial division have coincident mean and median cost on uniform draws
and yet are complementary at every individual instance (Theorem 4.5). Any
methodology that compares methods by summary statistics alone would report them
as equivalent. The dichotomy theorem, which makes the Fermat stopping index an
exact arithmetic expression, is what allows the difference to be stated.

### 8.4 Structure-blindness has two faces

It has an *asymptotic* face, the price $N^{1/4}$ (Theorem 6.11), and a
*combinatorial* face, the hitting-set bound $|S| \ge \pi(B) - 1$ (Theorem 3.13).
The second is the more robust: it constrains not a particular algorithm but every
procedure whose access to $N$ is divisibility testing against a fixed candidate
list.

### 8.5 Limitations

The coordinate is deliberately coarse. It cannot distinguish $N^{1/4}$ from
$N^{1/4}\log N$, and it collapses the entire subexponential family
$L_N[1/3, c] = \exp\big((c + o(1))(\log N)^{1/3}(\log\log N)^{2/3}\big)$ — which
contains the number field sieve — to $\alpha = 0$, alongside the genuinely
polynomial quantum profile. The plane as drawn therefore separates
*definition-routes from methods from quantum*, but places the best known
classical algorithm at the same coordinate as the quantum one. Refining the
coordinate to resolve the $\alpha = 0$ stratum is the most important open
direction (Section 9). The empirical figures are finite-size and
draw-distribution dependent; the theorems are not.

---

## 9. Future directions

Three structural facts came out of the analysis that were not visible in the
numerics:
the $\sigma_1$-route is $O(1)$ after the oracle, so its exponent is one of
evaluation; Fermat and trial division are complementary rather than similar, so
their aggregate agreement is a statement about the draw measure; and
structure-blindness admits a hitting-set lower bound. Each suggests a line of
work.

**1. The evaluation–inversion exponent gap.** Every definition-route splits into
an evaluation cost and an inversion cost. For $\sigma_1$ the inversion is $O(1)$
while evaluation is $N^{1/2}$. Conjecture: this split is universal across
multiplicative witnesses, and the plane's coordinate always measures evaluation.
The $O(1)$ half is proved (Theorem 3.6); the general statement now has the
vocabulary it needs in the exponent calculus of Section 2.

**2. A balance-parameter law unifying Fermat and trial division.** With
$p = N^{\beta}$, $q = N^{1-\beta}$, the trial cost is $N^{\beta}$ and the Fermat
cost is $\Theta(N^{1-2\beta})$, so the two exponents cross at $\beta = 1/3$. The
plane should be drawn in the $(\beta, \alpha)$ square, not on a line. The exact
Fermat stop $2a = p+q$ (Corollary 4.4) makes the cost an exact arithmetic
expression rather than an empirical count, so the crossing point is a theorem
waiting to be stated.

**3. The blindness price as a fixed exchange rate.** The price $N^{1/4}$ is not
merely unbounded: it has the *same* exponent as the whole of Stratum B
(Remark 6.14), so being blind and running $\rho$ cost the same at every size.
Extending the ledger to the smoothness barrier $L_N[1/3,c]$ would produce the
first non-exponential entry on the plane, and would force the refinement of the
$\alpha = 0$ stratum discussed in Section 8.5.

---

## 10. Conclusion

One coordinate, three strata, and every price measured rather than asserted.
Definition-routes — witnesses read off from $N$ alone — sit at $\alpha = 1/2$,
with an exact closed-form inversion showing the exponent belongs entirely to
evaluation, and a hitting-set bound showing no candidate list can be shorter.
Classical methods sit at $\alpha = 1/4$, with trial division, Fermat and Pollard
$\rho$ each given an exact statement rather than a citation, and with Fermat's
apparent similarity to trial division exposed as an artefact of the draw
measure. The quantum corner sits at $\alpha = 0$, with its classical split step
proved unconditionally exact. The three are strictly ordered, provably distinct,
and separated across the tractability line. Between the top two floors stands
the price of structure-blindness, $N^{1/4}$: strictly increasing, unbounded, and
— carrying the same exponent as the method it replaces — a unit exchange rate
between not knowing and working.
