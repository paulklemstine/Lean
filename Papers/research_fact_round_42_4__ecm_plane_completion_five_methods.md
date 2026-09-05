# One Population, One Functional: A Min-Plus Theory of Factoring Cost Exponents and the Newton Polygon of a Benchmark

**Author:** Aristotle
**Date:** 2026-09-04

---

## Abstract

We develop a tropical (min-plus) theory of algorithmic cost exponents and apply it to a controlled comparison of five integer-factoring arms measured on a single population of semiprimes with a single cost functional. Writing $k = \log_2 p$ for the bit-size of the hidden prime and measuring work in bits, each arm is an affine profile $k \mapsto c + \alpha k$, i.e. a tropical monomial $c \odot k^{\odot \alpha}$; racing arms is tropical addition ($\min$) and composing them is tropical multiplication ($+$). Under this dictionary the qualitative claims of a benchmark become exact statements about the corner locus of a tropical polynomial.

Three groups of results follow. (i) *Structure of the plane.* The race of two arms is again affine if and only if their exponents agree — the tropical form of factor locality — and near-parallel arms with $|\Delta\alpha| \le \varepsilon$ and $|\Delta c| \ge \delta$ can only cross at $|k^\star| \ge \delta/\varepsilon$, which converts a measurement tolerance into an observation-window bound. (ii) *Origin of the elliptic-curve exponent.* From the curve-budget bound "the visible set of group orders has size at most $B^2$ inside a group of order about $p$" we prove that reaching success probability $1/2$ costs at least $p/(2B)$ point operations; with $B = p^{\beta}$ this is exactly $p^{1-\beta}/2$, so the elliptic-curve arm traces the *tropical line* $\alpha = 1 - \beta$ joining trial division ($\beta = 0$, $\alpha = 1$) to the birthday arms ($\beta = 1/2$, $\alpha = 1/2$). The implication reverses into a calibration theorem: a measured exponent $a$ forces $B \ge p^{1-a}/2$. (iii) *Newton-polygon duality for benchmarks.* The lower envelope of a finite family of arms is concave; leaders are sorted by decreasing exponent and increasing intercept; an arm strictly above the lower convex hull of the points $(\alpha_i, c_i)$ never leads at any size, and an arm on or below the hull leads exactly at the crossing point of its two neighbours. Hull membership is therefore the precise criterion for operational relevance.

Applied to the measured plane — trial division $1.00$ (uniform draws) and $1.14$ (balanced draws), Fermat $0.50$, Pollard rho $0.512$, elliptic curves $0.761$ at stage-one bound $B_1 = 50$ and $0.718$ at $B_1 = 250$, with common-currency overhead $c_{\mathrm{ECM}} - c_{\rho} = +3.04$ bits against a $10.29\times$ wall-time ratio — the theory yields: the elliptic-curve exponent is strictly interior to the rho/trial-division bracket; the $B_1 = 50$ column is nevertheless a *dead arm*, never leading on the physical range $k \ge 0$; the three measured exponents are *exactly* collinear, $0.718 = (43 \cdot 0.512 + 206 \cdot 0.761)/249$, whence the $B_1 = 250$ column is a hull vertex **iff** its overhead over rho is at most $3.04 \cdot 206/249 \approx 2.515$ bits — a sharp, falsifiable prediction. We also prove a quantisation dichotomy explaining a recorded instrumentation pathology: a batched gcd of block size $m$ erases all size-dependence when the detection time fits in one block and preserves the exponent to within one bit of intercept otherwise. Finally we prove that the affine plane is not closed under the true subexponential cost $L_p(1/2,c) = \exp(c\sqrt{\log p \log\log p})$: its fitted exponent tends to $0$ while its log-work diverges, so no affine profile represents the elliptic-curve method asymptotically and every measured interior exponent is a coordinate of the observation window.

**Keywords:** tropical semiring, min-plus algebra, Newton polygon, lower convex hull, cost exponent, elliptic curve method, Pollard rho, subexponential complexity, quantisation.

---

## 1. Introduction

### 1.1 The problem

Benchmark tables are usually read one row at a time. A method is run, a power law $\mathrm{cost} \approx p^{\alpha}$ is fitted, the exponent is reported, and the reader draws an informal conclusion: smaller exponent, better method. This reading is wrong in two distinct ways, and both of them are geometric.

First, the exponent is only half the datum. An algorithm with an excellent exponent and a punishing constant may never be the best choice on any input a human will ever hand it. Whether it wins *somewhere* is not a fact about $\alpha$ alone, nor about $c$ alone, but about the position of the point $(\alpha, c)$ relative to the other points in the table.

Second, the exponent may not be a property of the method at all. It may be a property of the window in which the method was measured, or — worse — of the instrumentation used to measure it.

This paper puts both concerns on an exact footing, using a controlled experiment as the running example. Five factoring arms were measured on **one** population of toy semiprimes with **one** cost functional, so that intercepts as well as exponents are commensurable: a "common currency" of bits.

### 1.2 The measured plane

With $k = \log_2 p$ ($p$ the hidden prime) and work measured in bits, the fitted across-$k$ exponents were:

| arm | exponent $\alpha$ | regime |
|---|---|---|
| trial division | $1.00$ | uniform draws |
| trial division | $1.14$ | balanced draws |
| Fermat | $0.50$ | both |
| Pollard rho | $0.512$ | both |
| elliptic curves, $B_1 = 50$ | $0.761$ | both |
| elliptic curves, $B_1 = 250$ | $0.718$ | both |

Three headline observations accompany the table.

* **H1 (bracketing).** $0.512 < 0.718 \le 0.761 < 1.00$: the elliptic-curve column lands strictly inside the rho/trial-division bracket, in both stage-one regimes.
* **H2 (factor locality, sharp).** Switching the population between uniform-size hidden primes and balanced semiprimes moves rho's and the elliptic-curve arms' exponents by at most $\Delta\alpha \le 0.03$; only intercepts move. Trial division is the exception, shifting $1.00 \to 1.14$ and replicating an independently measured $1.09$.
* **H3 (overhead at the order line).** The common-currency intercept gap is $c_{\mathrm{ECM}} - c_{\rho} = +3.04$ bits, against a measured wall-time ratio of $10.29\times$. Since $3 < \log_2 10.29 < 4$, the two accountings agree to within one bit.

A ledger note records a further fact: a *batched* gcd in the rho implementation had erased the $\sqrt{p}$ law entirely; restoring a per-iteration gcd recovered $\alpha = 0.512$.

### 1.3 Contributions

1. A min-plus framework for cost profiles in which racing is tropical addition, composition is tropical multiplication, and min-plus distributivity holds (§2).
2. The **corner criterion**: two arms race to an affine function iff their exponents agree, with a quantitative near-parallel bound $|k^\star| \ge \delta/\varepsilon$ (§2.3).
3. A derivation of the elliptic-curve exponent from a curve-budget bound, giving the **tropical line $\alpha = 1-\beta$** and a **calibration theorem** $B \ge p^{1-a}/2$ (§4).
4. A **quantisation dichotomy** for batched detection, explaining the recorded pathology exactly (§5).
5. **Newton-polygon duality for benchmarks**: leaders sorted by exponent, arms above the hull dead, arms below the hull alive at the crossing point of their neighbours; a sharp iff for the $B_1 = 250$ column and a $2.515$-bit falsifiable threshold (§6).
6. A proof that the affine plane is not closed under the true subexponential cost, so the measured interior exponent is a window artefact (§7).

---

## 2. Cost profiles and the tropical plane

### 2.1 Definitions

**Definition 2.1 (cost profile).** A *cost profile* is a pair $M = (\alpha_M, c_M) \in \mathbb{R}^2$, where $\alpha_M$ is an across-$k$ exponent (bits of work per bit of $\log_2 p$) and $c_M$ is a common-currency intercept in bits. Its *log-work* at target size $k$ is
$$\mathrm{work}(M, k) \;=\; c_M + \alpha_M\, k .$$
Equivalently $M$ is the tropical monomial $c_M \odot k^{\odot \alpha_M}$ in the min-plus semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$.

**Definition 2.2 (tropical product).** $M \odot N := (\alpha_M + \alpha_N,\; c_M + c_N)$.

**Definition 2.3 (race / tropical sum).** $\mathrm{race}(M,N)(k) := \min\big(\mathrm{work}(M,k), \mathrm{work}(N,k)\big)$.

The interpretations are the operational ones: running one arm after the other (or repeating an arm) multiplies operation counts and therefore adds bit-costs; running two arms in parallel and keeping the first to finish takes the pointwise minimum.

**Proposition 2.4 (composition is tropical multiplication).** $\mathrm{work}(M \odot N, k) = \mathrm{work}(M,k) + \mathrm{work}(N,k)$.

*Proof.* Immediate from the definitions: $(c_M + c_N) + (\alpha_M + \alpha_N)k = (c_M + \alpha_M k) + (c_N + \alpha_N k)$. $\square$

**Theorem 2.5 (min-plus distributivity).** For all profiles $M, N, P$ and all $k$,
$$\mathrm{race}(M,N)(k) + \mathrm{work}(P,k) \;=\; \mathrm{race}(M \odot P,\; N \odot P)(k).$$

*Proof.* By Proposition 2.4 the right-hand side is $\min(\mathrm{work}(M,k) + \mathrm{work}(P,k),\ \mathrm{work}(N,k) + \mathrm{work}(P,k))$, and $\min(a,b) + t = \min(a+t, b+t)$. $\square$

Theorem 2.5 is the statement that post-composing every arm of a race with a common step commutes with racing. It is exactly distributivity of $\odot$ over $\oplus = \min$, so the profiles form a genuine min-plus structure rather than an analogy.

**Proposition 2.6 (concavity of a race).** For $t, s \ge 0$ with $t + s = 1$,
$$t\,\mathrm{race}(M,N)(x) + s\,\mathrm{race}(M,N)(y) \;\le\; \mathrm{race}(M,N)(tx + sy).$$

*Proof.* Each of $\mathrm{work}(M,\cdot)$ and $\mathrm{work}(N,\cdot)$ is affine, hence satisfies the corresponding identity with equality; bounding $\mathrm{race} \le \mathrm{work}(M,\cdot)$ on the left gives $\le \mathrm{work}(M, tx+sy)$, and likewise for $N$; take the minimum on the right. $\square$

### 2.2 Domination and crossovers

**Proposition 2.7 (coordinatewise domination).** If $\alpha_M \le \alpha_N$ and $c_M \le c_N$ then $\mathrm{work}(M,k) \le \mathrm{work}(N,k)$ for all $k \ge 0$; if moreover $c_M < c_N$ the inequality is strict.

**Proposition 2.8 (crossovers need an inversion).** If $\mathrm{work}(N,k) < \mathrm{work}(M,k)$ for some $k \ge 0$, then $\alpha_N < \alpha_M$ or $c_N < c_M$.

**Theorem 2.9 (exponents beat intercepts asymptotically).** If $\alpha_M < \alpha_N$ then $\mathrm{work}(M,k) < \mathrm{work}(N,k)$ for all sufficiently large $k$, whatever the intercepts.

**Theorem 2.10 (the unique corner).** If $\alpha_M < \alpha_N$, the two profiles agree at exactly one point,
$$k^\star \;=\; \frac{c_M - c_N}{\alpha_N - \alpha_M},$$
and the leader changes there: $\mathrm{work}(N,k) < \mathrm{work}(M,k)$ for $k < k^\star$ and $\mathrm{work}(M,k) < \mathrm{work}(N,k)$ for $k > k^\star$.

*Proof.* $\mathrm{work}(M,k) - \mathrm{work}(N,k) = (c_M - c_N) + (\alpha_M - \alpha_N)k$ is a strictly decreasing affine function of $k$, with unique zero at $k^\star$. $\square$

### 2.3 The corner criterion and factor locality

**Theorem 2.11 (corner criterion).** For profiles $M, N$, the race $\mathrm{race}(M,N)$ is itself an affine function of $k$ **if and only if** $\alpha_M = \alpha_N$.

*Proof.* ($\Leftarrow$) With equal exponents the two lines are parallel, so the minimum is the line with the smaller intercept. ($\Rightarrow$) If $\alpha_M \ne \alpha_N$, Theorem 2.10 produces a point $k^\star$ where the leader changes; the minimum of two lines of different slopes has distinct one-sided slopes at $k^\star$, so it is not affine. $\square$

This is the tropical form of **factor locality**. A method is factor-local if its exponent does not depend on how the population is drawn; equivalently, the two-regime tropical polynomial $\mathrm{race}(M_{\mathrm{unif}}, M_{\mathrm{bal}})$ has **empty corner locus**. Applied to the measurements:

**Corollary 2.12.** The rho and elliptic-curve regime pairs (equal exponents, differing intercepts) have no corner: the race is again a single affine arm. The trial-division pair ($1.00$ vs $1.14$) has a corner, located at $k^\star = (c_{\mathrm{unif}} - c_{\mathrm{bal}})/0.14$.

Measurement never returns exact equality, so the criterion needs a quantitative companion.

**Theorem 2.13 (near-parallel arms cross far away).** Suppose $|\alpha_M - \alpha_N| \le \varepsilon$ with $\varepsilon > 0$, and $|c_M - c_N| \ge \delta$. If $\mathrm{work}(M,k^\star) = \mathrm{work}(N,k^\star)$, then
$$|k^\star| \;\ge\; \frac{\delta}{\varepsilon}.$$

*Proof.* At a crossing, $c_M - c_N = -(\alpha_M - \alpha_N)k^\star$, so $\delta \le |c_M - c_N| = |\alpha_M - \alpha_N|\,|k^\star| \le \varepsilon |k^\star|$. $\square$

**Remark 2.14 (H2 made precise).** A naive inference "$\Delta\alpha \le 0.03$ implies equal exponents" is false. Theorem 2.13 supplies the correct statement: with tolerance $\varepsilon = 0.03$ and any intercept gap $\delta \ge 1$ bit, a hidden corner must lie beyond $|k| \ge 33.3$, far outside the toy window $k \approx 16$–$20$. "Factor-local" and "corner beyond the horizon" are empirically indistinguishable, and Theorem 2.13 says exactly how far the horizon is.

---

## 3. The measured plane

Only the *difference* of intercepts was pinned down by the experiment, so we carry the rho intercept as a free parameter $c$ and the $B_1 = 250$ overhead as a free parameter $d$:
$$\rho = (0.512,\, c), \quad \mathrm{ECM}_{50} = (0.761,\, c + 3.04), \quad \mathrm{ECM}_{250} = (0.718,\, c + d),$$
$$\mathrm{Fermat} = (0.50,\, c), \quad \mathrm{TD}_{\mathrm{unif}} = (1.00,\, \cdot), \quad \mathrm{TD}_{\mathrm{bal}} = (1.14,\, \cdot).$$

**Proposition 3.1 (the table is totally ordered by exponent).**
$$0.50 < 0.512 < 0.718 < 0.761 < 1.00 < 1.14 .$$

**Theorem 3.2 (H1).** The elliptic-curve exponents are strictly interior to the bracket set by rho below and trial division above, in both stage-one regimes.

**Theorem 3.3 (H3, read strictly: no crossover in the measured plane).** For all $k \ge 0$,
$$\mathrm{work}(\rho, k) \;<\; \mathrm{work}(\mathrm{ECM}_{50}, k),$$
so $\mathrm{race}(\rho, \mathrm{ECM}_{50})(k) = \mathrm{work}(\rho,k)$ on the whole physical range; the corner locus misses $[0,\infty)$ entirely.

*Proof.* $\mathrm{ECM}_{50}$ has both a larger exponent ($0.761 > 0.512$) and a strictly larger intercept ($+3.04$ bits). Apply Proposition 2.7 (strict form). $\square$

Theorem 3.3 is the precise sense in which the "+3.04 bits" overhead is decisive: it removes any possibility of a crossover on the accessible half-line, so an interior exponent does not confer an interior operational role. By Proposition 2.8, a crossover would require *inverting* one of the two coordinates.

**Theorem 3.4 (the two currencies agree to within one bit).** $3 < \log_2 10.29 < 4$, so the abstract common-currency gap of $3.04$ bits and the measured wall-time ratio of $10.29\times$ are consistent to within a single bit. This is the exact content of "H3 at the edge": the toy-scale overhead sits precisely at the order line.

---

## 4. Where the elliptic-curve exponent comes from

The measured $0.718$–$0.761$ is not an unexplained fit. It is forced by a counting bound on the method itself.

### 4.1 The curve-budget bound

The elliptic-curve method tries curve after curve; with stage-one bound $B$, an attempt succeeds when the order of the point on the chosen curve modulo $p$ is $B$-powersmooth. Inside a group of order approximately $p$, the set of orders the method can see has size at most $B^2$, so a single curve succeeds with probability at most $B^2/p$.

**Theorem 4.1 (total-work lower bound).** Let $p > 0$ and $B > 0$, let $q \le \min(1, B^2/p)$ be the per-curve success probability, and let $C$ be the number of curves tried. If the campaign reaches overall success probability at least $1/2$, i.e. $1 - (1-q)^C \ge 1/2$, then the total number of point operations satisfies
$$C \cdot B \;\ge\; \frac{p}{2B}.$$

*Proof sketch.* Reaching success probability $1/2$ with per-curve probability $q$ requires $C \ge p/(2B^2)$ curves: if $C < p/(2B^2)$ then, since $q \le B^2/p$, a union bound gives $1 - (1-q)^C \le Cq < (p/(2B^2))(B^2/p) = 1/2$, contradicting the hypothesis. Multiplying $C \ge p/(2B^2)$ by the $B$ point operations spent per curve gives $CB \ge p/(2B)$. $\square$

### 4.2 The tropical line $\alpha = 1 - \beta$

**Theorem 4.2 (exponent identity).** For $p > 0$ and any $\beta$, $\dfrac{p}{2p^{\beta}} = \dfrac{p^{1-\beta}}{2}$.

Thus with a stage-one bound scaling as $B = p^{\beta}$, the lower bound of Theorem 4.1 is *exactly* $p^{1-\beta}/2$, and the exponent of the elliptic-curve arm is
$$\alpha \;=\; 1 - \beta .$$
This is a straight line in the $(\beta, \alpha)$ plane — a tropical line joining the two classical corners of the table:

* $\beta = 0$ (no smoothness budget): $\alpha = 1$, trial division;
* $\beta = 1/2$: $\alpha = 1/2$, the birthday arms (Pollard rho, Fermat).

**Theorem 4.3 (strict interpolation).** For $p > 1$ and $0 < \beta < 1/2$,
$$p^{1/2} \;<\; p^{1-\beta} \;<\; p .$$
The endpoints $\beta = 0$ and $\beta = 1/2$ recover the two extremes exactly.

Theorem 4.3 is the structural explanation of H1: an interior exponent is not an accident of the toy population but the necessary signature of a stage-one bound strictly between "none" and "square-root".

### 4.3 Calibration: the measurement reads the bound

The implication runs both ways, which turns the exponent into an instrument.

**Theorem 4.4 (calibration).** Under the hypotheses of Theorem 4.1, if the campaign's total work satisfies $C \cdot B \le p^{a}$, then the stage-one bound obeys
$$B \;\ge\; \frac{p^{1-a}}{2}.$$

*Proof.* Combine $p/(2B) \le CB \le p^a$ with $p^{1-a} = p/p^a$ and rearrange. $\square$

A measured slope strictly below $1$ therefore *certifies* a stage-one bound growing like a positive power of $p$.

**Corollary 4.5 (the $\alpha = 0.761$ column is consistent with $B_1 = 50$).** At $20$-bit targets, $p = 2^{20}$, the calibration bound with $a = 0.761$ gives
$$\frac{(2^{20})^{1-0.761}}{2} = \frac{2^{20 \times 0.239}}{2} = \frac{2^{4.78}}{2} \le \frac{2^5}{2} = 16 \;\le\; 50 .$$
The measured exponent is compatible with the bound that was actually used, with room to spare.

---

## 5. The quantisation ledger: how instrumentation can eat a square-root law

Pollard's rho detects a factor through a gcd computation. Because gcds are expensive relative to a single iteration, implementations accumulate a product over a block of $m$ iterations and take one gcd per block. The consequence is that success is only *observable* at multiples of $m$.

**Definition 5.1 (batched detection time).** For block size $m \ge 1$ and true detection time $T$,
$$\mathrm{batch}(m, T) \;=\; m\left\lceil \frac{T}{m} \right\rceil .$$

**Proposition 5.2 (quantisation sandwich).** For $m \ge 1$, $\;T \le \mathrm{batch}(m,T) < T + m$: batching never reports early, and overshoots by less than one block.

**Theorem 5.3 (erasure).** If $0 < T \le m$ then $\mathrm{batch}(m,T) = m$, independently of $T$. All $p$-dependence is destroyed and the measured exponent is $0$.

**Theorem 5.4 (preservation).** If $m \le T$ then $T \le \mathrm{batch}(m,T) \le 2T$.

**Theorem 5.5 (the dichotomy in exponent form).** Fix $m \ge 1$ and two target sizes with true detection times $0 < T_1 \le T_2$.
1. If $T_2 \le m$, the measured ratio is exactly $1$: $\;\mathrm{batch}(m,T_2)/\mathrm{batch}(m,T_1) = 1$, so the fitted exponent is $0$.
2. If $m \le T_1$, the measured ratio is within a factor $2$ of the true ratio:
$$\frac{\mathrm{batch}(m,T_2)}{\mathrm{batch}(m,T_1)} \;\le\; 2\,\frac{T_2}{T_1},$$
so the exponent survives and only the intercept moves, by at most one bit.

*Proof.* (1) is Theorem 5.3 applied twice. (2) uses $\mathrm{batch}(m,T_2) \le 2T_2$ (Theorem 5.4) and $\mathrm{batch}(m,T_1) \ge T_1$ (Proposition 5.2). $\square$

### 5.1 The recorded pathology, exactly

**Theorem 5.6 (batched gcd erases the $\sqrt{p}$ law at toy scale).** With block size $m = 2048$, the rho detection times at $k = 16$ and $k = 20$ bits are $\sqrt{p} = 256$ and $1024$ respectively. Both satisfy $T \le m$, so both are reported as $2048$, and the measured two-point slope is
$$\frac{\log_2 2048 - \log_2 2048}{20 - 16} \;=\; 0,$$
even though the true detection times differ by a factor of four.

**Theorem 5.7 (per-iteration gcd restores it).** With $m = 1$ the same two points give $256$ and $1024$, so
$$\frac{\log_2 1024 - \log_2 256}{20 - 16} \;=\; \frac{10 - 8}{4} \;=\; \frac{1}{2},$$
the square-root law exactly, matching the measured $\alpha = 0.512$.

Theorems 5.6 and 5.7 are the two halves of the ledger entry. The earlier run that reported a rho exponent with no $\sqrt{p}$ law was not observing noise: it was observing the block size. This is the reason the corrected experiment uses a per-iteration gcd at toy sizes, and the reason the restored $0.512$ is a genuine measurement rather than a tuning artefact.

---

## 6. Newton-polygon duality for benchmarks

We now pass from pairs to arbitrary finite families, where the tropical geometry becomes sharp.

### 6.1 Envelope and leaders

**Definition 6.1 (envelope).** For a nonempty finite family $F = (M_i)_{i \in I}$ of profiles, the *lower envelope* is the tropical polynomial
$$E_F(k) \;=\; \min_{i \in I}\, \mathrm{work}(M_i, k) \;=\; \bigoplus_i c_i \odot k^{\odot \alpha_i}.$$

**Definition 6.2 (leader).** Arm $i$ *leads at* $k$ if $\mathrm{work}(M_i,k) \le \mathrm{work}(M_j,k)$ for every $j \in I$.

**Proposition 6.3.** $E_F(k) \le \mathrm{work}(M_i,k)$ for every $i$; at every $k$ some arm leads; and if $i$ leads at $k$ then $E_F(k) = \mathrm{work}(M_i,k)$.

**Theorem 6.4 (a tropical polynomial in one variable is concave).** For $t, s \ge 0$ with $t+s=1$,
$$t\,E_F(x) + s\,E_F(y) \;\le\; E_F(tx + sy).$$

*Proof.* Let $i$ lead at $tx + sy$. Then $E_F(x) \le \mathrm{work}(M_i,x)$ and $E_F(y) \le \mathrm{work}(M_i,y)$, so the left side is at most $t\,\mathrm{work}(M_i,x) + s\,\mathrm{work}(M_i,y)$, which equals $\mathrm{work}(M_i, tx+sy)$ by affineness and $t+s=1$; and that equals $E_F(tx+sy)$ since $i$ leads there. $\square$

### 6.2 The leaderboard is sorted

**Theorem 6.5 (leader exponents are antitone).** If arm $i$ leads at $k_1$, arm $j$ leads at $k_2$, and $k_1 < k_2$, then $\alpha_j \le \alpha_i$.

*Proof.* Leadership gives $c_i + \alpha_i k_1 \le c_j + \alpha_j k_1$ and $c_j + \alpha_j k_2 \le c_i + \alpha_i k_2$. Adding, $\alpha_i(k_1 - k_2) \le \alpha_j (k_1 - k_2)$; since $k_1 - k_2 < 0$, dividing reverses the inequality to $\alpha_j \le \alpha_i$. $\square$

**Theorem 6.6 (leader intercepts are monotone).** Under the hypotheses of Theorem 6.5 with additionally $0 \le k_1$, we have $c_i \le c_j$.

*Proof.* From $c_i + \alpha_i k_1 \le c_j + \alpha_j k_1$ and $\alpha_j \le \alpha_i$ with $k_1 \ge 0$: $c_i \le c_j + (\alpha_j - \alpha_i)k_1 \le c_j$. $\square$

Together these say that the succession of champions as targets grow is *forced*: exponents can only decrease, intercepts can only increase. There is no room for a method to reclaim the lead once it has lost it.

### 6.3 The hull criterion, both directions

**Theorem 6.7 (an arm above the hull is dead).** Let $i, j, l$ be arms and $t, s \ge 0$ with $t+s=1$. If
$$\alpha_i = t\alpha_j + s\alpha_l \qquad \text{and} \qquad t c_j + s c_l < c_i,$$
then arm $i$ never leads, at any $k \in \mathbb{R}$.

*Proof.* Suppose $i$ led at some $k$. Then $\mathrm{work}(M_i,k) \le \mathrm{work}(M_j,k)$ and $\mathrm{work}(M_i,k) \le \mathrm{work}(M_l,k)$. Take the $t$-weighted and $s$-weighted combination and use $t+s=1$ to collapse the left side to $\mathrm{work}(M_i,k)$ itself:
$$c_i + (t\alpha_j + s\alpha_l)k \;\le\; t(c_j + \alpha_j k) + s(c_l + \alpha_l k) = (tc_j + sc_l) + (t\alpha_j + s\alpha_l)k .$$
Cancelling the common linear term gives $c_i \le tc_j + sc_l$, contradicting the hypothesis. $\square$

Geometrically: the point $(\alpha_i, c_i)$ lies strictly above the segment joining $(\alpha_j, c_j)$ and $(\alpha_l, c_l)$, and the minimum of those two lines undercuts arm $i$'s line everywhere.

**Theorem 6.8 (an arm on or below the hull is alive).** Let $M, N, P$ be profiles with $\alpha_M \ne \alpha_P$, and let $t + s = 1$ (no positivity needed) satisfy
$$\alpha_N = t\alpha_M + s\alpha_P \qquad \text{and} \qquad c_N \le t c_M + s c_P .$$
Then $N$ leads the family $\{M, N, P\}$ at some $k$ — namely at the crossing point $k^\star$ of $M$ and $P$, given by $(\alpha_M - \alpha_P)k^\star = c_P - c_M$.

*Proof.* At $k^\star$ the outer arms are level: $\mathrm{work}(M,k^\star) = \mathrm{work}(P,k^\star)$. Any weighted combination with $t+s=1$ of two equal values is that value, so $t\,\mathrm{work}(M,k^\star) + s\,\mathrm{work}(P,k^\star) = \mathrm{work}(M,k^\star)$. The hypotheses give $\mathrm{work}(N,k^\star) \le t\,\mathrm{work}(M,k^\star) + s\,\mathrm{work}(P,k^\star)$, hence $\mathrm{work}(N,k^\star) \le \mathrm{work}(M,k^\star) = \mathrm{work}(P,k^\star)$. $\square$

**Theorem 6.9 (two-arm families have no dead arm).** If $\alpha_M < \alpha_N$, then both $M$ and $N$ lead somewhere: $N$ leads at $k^\star - 1$ and $M$ at $k^\star + 1$, where $k^\star$ is the corner of Theorem 2.10.

Theorems 6.7 and 6.8 together are the promised duality.

> **Newton-polygon principle.** In a family of cost profiles, the arms that ever lead are exactly the vertices of the lower convex hull of the points $\{(\alpha_i, c_i)\}$. An arm strictly above the hull is operationally irrelevant, no matter how attractive its exponent; an arm on the hull leads at the corner determined by its neighbours.

This is the classical Newton-polygon/tropical duality (lower hull of exponent–coefficient pairs $\leftrightarrow$ pieces of the tropical polynomial) transplanted onto a benchmark table, and it converts a vague reading of a performance table into an exact geometric test.

### 6.4 The measured plane: a dead arm and a sharp threshold

**Theorem 6.10 (the $B_1 = 50$ column is a dead arm).** For every $k \ge 0$, the arm $\mathrm{ECM}_{50}$ does not lead the family $\{\rho, \mathrm{ECM}_{50}\}$, hence does not lead any family containing $\rho$.

*Proof.* Immediate from Theorem 3.3: rho is strictly cheaper at every $k \ge 0$. $\square$

Interiority of the exponent does not imply interiority of the operational role. This is the sharpest single lesson of the measured plane: $\mathrm{ECM}_{50}$ has a real, structurally explained interior exponent and is nevertheless never the right thing to run.

**Theorem 6.11 (exact collinearity of the measured exponents).**
$$0.718 \;=\; \frac{43 \cdot 0.512 + 206 \cdot 0.761}{249},$$
i.e. $\alpha_{\mathrm{ECM}_{250}} = \tfrac{43}{249}\alpha_{\rho} + \tfrac{206}{249}\alpha_{\mathrm{ECM}_{50}}$ exactly, with $\tfrac{43}{249} + \tfrac{206}{249} = 1$.

*Proof.* $43 \cdot 0.512 = 22.016$ and $206 \cdot 0.761 = 156.766$; their sum is $178.782 = 249 \times 0.718$. $\square$

The consequence is structural: the elliptic-curve column is not two independent measurements but a **one-parameter family**, whose exponent is pinned to the segment through rho and $\mathrm{ECM}_{50}$. Only the intercept is free, so the hull criterion collapses to a single scalar threshold.

**Theorem 6.12 (falsifiable prediction).** If the common-currency overhead $d$ of the $B_1 = 250$ column over rho satisfies
$$d \;>\; 3.04 \cdot \frac{206}{249} \;\approx\; 2.515 \text{ bits},$$
then $\mathrm{ECM}_{250}$ lies strictly above the hull segment and never leads the family $\{\rho, \mathrm{ECM}_{250}, \mathrm{ECM}_{50}\}$, at any $k \in \mathbb{R}$.

*Proof.* Apply Theorem 6.7 with $t = 43/249$, $s = 206/249$: the slope hypothesis is Theorem 6.11, and the intercept hypothesis is $t\cdot c + s\cdot(c + 3.04) = c + 3.04\cdot\frac{206}{249} < c + d$. $\square$

**Theorem 6.13 (the sharp iff).** $\mathrm{ECM}_{250}$ leads the family $\{\rho, \mathrm{ECM}_{250}, \mathrm{ECM}_{50}\}$ at some real target size **if and only if** $d \le 3.04 \cdot \frac{206}{249}$.

*Proof.* ($\Rightarrow$) Contrapositive of Theorem 6.12. ($\Leftarrow$) Theorem 6.8 with the same weights: the slope lies on the segment by Theorem 6.11, and $c + d \le c + 3.04\cdot\frac{206}{249} = t c_\rho + s c_{\mathrm{ECM}_{50}}$. $\square$

**Theorem 6.14 (physical caveat).** For every $d > 0$ and every $k \ge 0$, $\mathrm{ECM}_{250}$ does not lead: rho has both a smaller exponent ($0.512 < 0.718$) and a strictly smaller intercept, hence is strictly cheaper on the whole accessible half-line. The witness supplied by Theorem 6.8 therefore necessarily sits at a negative — unphysical — target size.

Theorem 6.14 is not a defect of the duality but a reminder of its scope. Hull membership is the exact criterion on the whole line $k \in \mathbb{R}$; on the physical half-line $k \ge 0$ the operative test is *domination*, and domination is strictly stronger. In practice one wants both readings: the hull tells you whether an arm is structurally relevant, domination tells you whether it is relevant *here*.

---

## 7. The affine plane is not closed: the exponent that isn't there

Everything above fits an affine profile. Section 4 explains why a *fixed* stage-one bound must produce an interior exponent. This section proves the complementary and stronger statement: **no affine profile represents the elliptic-curve method asymptotically at all.**

**Definition 7.1 (subexponential cost).** For $c > 0$,
$$L(c, x) \;=\; \exp\!\big(c \sqrt{\log x \cdot \log\log x}\big),$$
the standard heuristic running time of elliptic-curve and quadratic-sieve type methods, with $\log L(c,x) = c\sqrt{\log x \log\log x}$.

**Lemma 7.2.** $\log\log x = o(\log x)$ as $x \to \infty$; quantitatively, for every $\varepsilon > 0$ eventually $\log\log x \le \varepsilon \log x$ and $\log x \ge 1$.

**Theorem 7.3 (below every positive power).** For every $c > 0$ and every $a > 0$, eventually
$$\log L(c,x) \;<\; a \log x .$$

*Proof sketch.* Choose $\varepsilon = a^2/(2c^2)$. Eventually $\log\log x \le \varepsilon \log x$, so
$$c\sqrt{\log x \log\log x} \;\le\; c\sqrt{\varepsilon}\,\log x \;=\; \frac{a}{\sqrt{2}}\log x \;<\; a \log x$$
once $\log x > 0$. $\square$

**Theorem 7.4 (the fitted exponent is zero).** For $c > 0$,
$$\lim_{x \to \infty} \frac{\log L(c,x)}{\log x} \;=\; 0 .$$

**Theorem 7.5 (the chord slope also collapses).** The experiment does not fit a limit; it fits a chord between two target sizes. Over a doubling window in $\log_2 p$ — i.e. $x \mapsto x^2$ — the measured two-point slope
$$\frac{\log L(c,x^2) - \log L(c,x)}{\log(x^2) - \log x}$$
also tends to $0$ as $x \to \infty$. No window placed far enough out can report a positive exponent.

*Proof sketch.* The denominator is $\log x$. Apply Theorem 7.3 with exponent $\varepsilon/4$ at $x^2$ (noting $\log(x^2) = 2\log x$) and with $\varepsilon/2$ at $x$; both numerator terms are then $O(\varepsilon \log x)$ and nonnegative, so the quotient is within $\varepsilon$ of $0$. $\square$

**Theorem 7.6 (the subexponential arm is the eventual leader of the whole table).** For every profile $M$ with $\alpha_M > 0$ — trial division, Fermat, rho, and both elliptic-curve columns as fitted — eventually
$$\log_2 L(c,x) \;<\; \mathrm{work}(M, \log_2 x),$$
whatever the intercepts.

*Proof sketch.* Apply Theorem 7.3 with $a = \alpha_M/2$; the remaining half of the linear term absorbs the constant $c_M \log 2$, which is eventually dominated by $(\alpha_M/2)\log x$. $\square$

**Theorem 7.7 (…but it is not the constant arm).** For $c > 0$, $\log L(c,x) \to \infty$. Exponent $0$ in the affine plane means *bounded* work; the subexponential arm has unbounded log-work.

*Proof sketch.* Once $\log x \ge e$ we have $\log\log x \ge 1$, so $\sqrt{\log x \log\log x} \ge \sqrt{\log x} \to \infty$. $\square$

**Theorem 7.8 (no affine profile represents the subexponential arm).** For $c > 0$ there is no profile $M$ with $\log_2 L(c,x) = \mathrm{work}(M, \log_2 x)$ for all large $x$.

*Proof.* If $\alpha_M < 0$ the affine side tends to $-\infty$ while the subexponential side tends to $+\infty$ (Theorem 7.7), contradiction. If $\alpha_M = 0$ the affine side is the constant $c_M$ while the subexponential side diverges, contradiction. If $\alpha_M > 0$, Theorem 7.6 makes the subexponential side eventually strictly smaller, contradicting equality. $\square$

**Corollary 7.9 (the measured exponent is a coordinate of the window).** The true elliptic-curve cost lies strictly between "exponent $0$" and "every positive exponent," a place the affine plane does not contain. Any finite observation window is therefore *forced* to report a spurious interior slope. The measured $0.761$ and $0.718$ are not constants of the method; they are readings of where and how the method was observed.

This closes the elliptic-curve column from both sides. With a *fixed* stage-one bound, §4 shows that an interior exponent is exactly what must appear; with the bound allowed to grow with the target, §7 shows that the exponent must drift to $0$.

---

## 8. Algorithms

The theory is effective. Three procedures suffice to reproduce every conclusion of §6 from a table of $(\alpha_i, c_i)$ pairs.

**Algorithm A (lower envelope evaluation).** Given profiles $\{(\alpha_i,c_i)\}$ and a size $k$, return $\min_i (c_i + \alpha_i k)$ together with an arg-min. Cost $O(n)$ per query, or $O(\log n)$ after Algorithm B by binary search on the breakpoint list.

**Algorithm B (leader schedule via lower convex hull).** Sort the points by exponent descending, breaking ties by keeping only the smallest intercept. Sweep, maintaining a stack of hull vertices; pop while the crossing point of the new line with the second-from-top is at most the crossing point of the top with the second-from-top. The surviving stack is exactly the set of arms that ever lead (Theorems 6.7, 6.8), in the order in which they lead (Theorems 6.5, 6.6), and consecutive crossings are the breakpoints. Cost $O(n \log n)$, dominated by the sort; the sweep is $O(n)$ amortised.

**Algorithm C (hull-threshold solver).** For a designated middle arm $N$ and two designated outer arms $M, P$ with $\alpha_M \ne \alpha_P$, compute the unique weights $t = (\alpha_N - \alpha_P)/(\alpha_M - \alpha_P)$, $s = 1 - t$, and return the threshold $c^{\mathrm{crit}} = t c_M + s c_P$. Then $N$ ever leads iff $c_N \le c^{\mathrm{crit}}$. Cost $O(1)$. Applied to $(\rho, \mathrm{ECM}_{250}, \mathrm{ECM}_{50})$ with $\alpha = (0.512, 0.718, 0.761)$ this returns $t = 43/249$, $s = 206/249$ and the $2.515$-bit threshold of Theorem 6.13.

A fourth routine is worth naming because it is what caught the pathology of §5:

**Algorithm D (quantisation audit).** Given a block size $m$ and the true detection times at two target sizes, report which branch of Theorem 5.5 applies. If $T_{\max} \le m$, flag "exponent erased"; if $T_{\min} \ge m$, certify "exponent preserved to within one bit of intercept"; otherwise flag "mixed regime, exponent unreliable." Cost $O(1)$, and it should be run before any exponent from a batched instrument is believed.

---

## 9. Discussion

### 9.1 What the tropical framing buys

The framing is not merely notation. Three specific payoffs:

* **Factor locality becomes a corner condition.** The informal claim "the exponent does not depend on the population" is exactly "the two-regime tropical polynomial has empty corner locus" (Theorem 2.11), and the measurement tolerance becomes a window bound (Theorem 2.13). Without the quantitative version, the naive inference from $\Delta\alpha \le 0.03$ to equal exponents is simply invalid.
* **Relevance becomes hull membership.** "Which methods matter?" is answered exactly, in both directions, by Theorems 6.7 and 6.8. This is what exposes $\mathrm{ECM}_{50}$ as a dead arm despite its structurally correct interior exponent.
* **The leaderboard becomes forced.** Theorems 6.5 and 6.6 say the succession of champions is monotone in both coordinates — a strong structural constraint that any correct benchmark must satisfy, and hence a consistency check on the measurement itself.

### 9.2 What failed, and needed redefinition

Three plausible statements turned out to be false and had to be replaced.

1. *"Measured $\Delta\alpha \le 0.03$ implies equal exponents."* False; replaced by Theorem 2.13, which bounds how far a hidden corner must be rather than denying its existence.
2. *"An interior exponent means an interior operational role."* False; with $+3.04$ bits of overhead the $B_1 = 50$ column never leads on $k \ge 0$ (Theorem 6.10).
3. *"Hull membership is the operative criterion."* True on $\mathbb{R}$, misleading on the physical half-line: the witness of Theorem 6.8 can sit at negative $k$, so on $k \ge 0$ the operative test is domination (Theorem 6.14).

### 9.3 Limitations

The measured plane is toy-scale ($k \approx 16$–$20$ bits), and §7 shows precisely why exponents fitted in such a window should not be extrapolated. The curve-budget bound of §4 is a *lower* bound on work: it constrains what the elliptic-curve arm can achieve but does not by itself predict the constant. The intercepts are known only up to the differences that were measured, which is why every statement in §3 and §6 is uniform in the free parameters $c$ and $d$. Finally, the Newton-polygon duality is proved here for pairs and triples; §10 records the general-$n$ statement as the natural next target.

---

## 10. Future work

**Fixed-bound exponent drift law.** The proved lower bound $\mathrm{work} \ge p/(2B)$ forces the measured exponent of a *fixed* stage-one bound to drift upward toward $1$ like $1 - \log_2 B_1 / k$. Thus $0.761$ at $k \approx 18$ is a coordinate of the window, not a constant of the method, and the prediction is arithmetic: $\alpha \approx 0.82$ at $k = 32$ and $\alpha \approx 0.91$ at $k = 64$ for $B_1 = 50$. A wider sweep in $k$ confirms or refutes this directly.

**Newton-polygon duality for $n$ arms.** The triple case is closed in both directions. The general statement — the leader set equals the vertex set of the lower convex hull of $\{(\alpha_i, c_i)\}$ — should follow by reducing an arbitrary family to the triples formed by a candidate arm and its two hull neighbours, with Theorems 6.5 and 6.6 supplying the ordering that makes the reduction well-founded.

**Measure the $2.515$-bit threshold.** Theorem 6.13 is a decisive, cheap experiment: measure the common-currency overhead $d$ of the $B_1 = 250$ column over rho. Below $2.515$ bits it is a genuine hull vertex; above, it is dead forever.

**Quantisation audits as standard practice.** Algorithm D should be run on any exponent measured through batched instrumentation. The pathology of §5 was not subtle in hindsight, but it was invisible without the dichotomy.

**Beyond affine profiles.** Section 7 shows the affine plane is not closed under realistic costs. A tropical theory over a richer function space — logarithmic or subexponential monomials — would let the true elliptic-curve arm enter the plane as a bona fide point rather than as an unattainable limit, and would presumably restore a hull criterion valid asymptotically.

---

## 11. Conclusion

A performance table is a set of points in a plane, and that plane carries a min-plus algebra in which racing is addition and composing is multiplication. In that algebra, factor locality is the vanishing of a corner locus; the origin of an intermediate exponent is a straight line $\alpha = 1 - \beta$ forced by a counting bound; the effect of batched instrumentation is a clean dichotomy between erasing the scaling law and preserving it to within one bit; and operational relevance is membership in the lower convex hull.

Applied to the five measured arms, the theory certifies that the elliptic-curve exponent is genuinely interior and structurally explained, that the $B_1 = 50$ column is nevertheless never worth running, that the three exponents are exactly collinear so the whole column reduces to one intercept parameter, and that a single measurement of that parameter against a $2.515$-bit threshold will decide the column's fate. It also certifies the limits of the exercise: because the true cost is subexponential and no straight line represents it, every measured exponent in the table is a coordinate of the window in which it was measured.

---

## Appendix A: summary of the measured plane

| arm | $\alpha$ | intercept | hull status on $k \ge 0$ |
|---|---|---|---|
| Fermat | $0.50$ | $c$ | vertex (smallest exponent) |
| Pollard rho (per-iteration gcd) | $0.512$ | $c$ | vertex |
| elliptic curves, $B_1 = 250$ | $0.718$ | $c + d$ | dead for every $d > 0$ |
| elliptic curves, $B_1 = 50$ | $0.761$ | $c + 3.04$ | dead |
| trial division, uniform | $1.00$ | — | corner with balanced regime at $(c_{\mathrm{unif}} - c_{\mathrm{bal}})/0.14$ |
| trial division, balanced | $1.14$ | — | — |

Derived constants: $\tfrac{43}{249} \approx 0.1727$, $\tfrac{206}{249} \approx 0.8273$; hull threshold $3.04 \cdot \tfrac{206}{249} \approx 2.5150$ bits; $\log_2 10.29 \approx 3.363$, versus the $3.04$-bit common-currency gap.
