# The Extremal Enumeration Order Is a Population Property: Falsification of the Descending-Scan Principle and Its Replacement by a Sign-Flip Law

**Author:** Aristotle
**Date:** 2026-08-31

---

## Abstract

We study the class of *reordering policies*: search strategies whose only freedom is to commit, in advance and blind to the outcome of their own probes, to an enumeration of a candidate index set. The motivating instance is the search for the smaller prime factor $p$ of a balanced semiprime $N = pq$ inside the balance window $[\sqrt N/\sqrt k,\, \sqrt N]$ licensed by an advertised bound $q < kp$.

We prove that this action space supports exactly one order-optimality statement — the *Exchange Theorem*, which says that the mass-sorted enumeration is extremal — and that this statement privileges no arithmetic order whatsoever. We then falsify the widely repeated principle that the $\sqrt N$-descending scan is extremal, by exhibiting two admissible balanced populations on which the same pair of committed policies swap winners. The falsification is not an artefact of any particular balance convention: for every advertised ratio $k > 1$ it occurs strictly inside the admissible range of band widths.

In place of the falsified principle we establish a *sign-flip law*. For an arbitrary finite population of balance ratios $r = q/p$, window-ascending strictly beats window-descending if and only if $\mathbb{E}[r^{-1/2}] < (2+\sqrt2)/4$, equivalently if and only if the reciprocal crossover constant $4 - 2\sqrt2 \approx 1.17157$ is passed. For a uniform band $r \sim U[1,1+\delta]$ the population mean is exactly $2/(1+\sqrt{1+\delta})$ and the criterion becomes the closed form $\delta > 80 - 56\sqrt2 \approx 0.80404$; for a general advertised ratio $k$ the crossover is $\delta^*(k) = 8\sqrt k(\sqrt k - 1)/(\sqrt k+1)^2$. At hard balance ($k = 2$, $\delta = 1$) the population tilt is exactly $\sqrt2 - 1$ and the cost ratio exactly $\sqrt 2$.

We complement the order theory with a master speedup inequality $S \le \tfrac43\min(1/\mu, 2^{k_{\mathrm{bits}}})/\Lambda$, whose $1/\mu$ branch we prove as a *touch floor* rather than book as a convention, and which specialises — via an exact survivor count for mod-$M$ wheels and the observation that reordering is a bijection and therefore conserves the touched count — to the derived ceiling $S \le M/\varphi(M)$, equal to $3.75$ at $M = 30$ against measurements $3.7331$–$3.7496$. Finally we retract a proposed Jacobi-symbol witness as algebraically degenerate (its value at the factor is identically zero) and replace it with a keyed-versus-fixed residue control, proving that residue promotion is factor-blind at *every* modulus.

**Keywords:** enumeration order, rearrangement inequality, balanced semiprimes, prior shape, sign-flip crossover, wheel sieve, Euler totient, factor blindness.

---

## 1. Introduction

### 1.1 The folklore rule

Let $N = pq$ with $p \le q$ prime and suppose the generator of $N$ advertises a balance bound $q < kp$ for some fixed $k > 1$. Combining $q < kp$ with $N = pq$ gives $N < kp^2$, so
$$\frac{\sqrt N}{\sqrt k} \;<\; p \;\le\; \sqrt N .$$
The interval $W_k(N) = [\sqrt N/\sqrt k,\ \sqrt N]$ is the *balance window*. A search that scans $W_k(N)$ must choose a direction, and the folklore answer has long been "descend from $\sqrt N$", on the grounds that balanced factors cluster near $\sqrt N$.

This rule was proposed for promotion to a principle:

> **(Descending-Scan Principle, as drafted.)** Among all committed enumeration orders, the $\sqrt N$-descending enumeration of the balance window is extremal.

The present paper shows that this statement is **false in principle**, not merely unproven: it ascribes to a class of algorithms a property that is only ever a property of an input distribution. We replace it with a sharp criterion that decides the question for any given generator, and we determine exactly what the algorithmic model *can* prove.

### 1.2 Contributions

1. **Delimitation of the action space (§3).** The reordering model supports precisely one order-optimality theorem, the Exchange Theorem: mass-sorted enumerations are extremal. It names no arithmetic order. A companion *no-free-lunch* result shows every reordering gain is a prior-shape gain.
2. **The sign-flip law (§4).** An exact iff-criterion for the winner between window-ascending and window-descending, in terms of the single population functional $m = \mathbb E[r^{-1/2}]$, with crossover $(2+\sqrt2)/4$; equivalently the reciprocal constant $4-2\sqrt2$.
3. **Closed-form crossovers (§4.3–§4.5).** For uniform bands, $\delta^* = 80 - 56\sqrt2$; the hard-balance tilt $\sqrt2-1$ and cost ratio $\sqrt2$; and the family law $\delta^*(k) = 8\sqrt k(\sqrt k-1)/(\sqrt k+1)^2$ with the universality statement $\delta^*(k) < k-1$.
4. **The falsification (§5).** Two admissible populations, same two policies, opposite winners — at every $k$.
5. **Certification protocol (§6).** Monotonicity of the prior-shape gain $\Lambda(m)$ converts an interval measurement into a certified extremal order with a bracketed gain factor.
6. **Master cap and its calibration (§7).** The inequality $S \le \tfrac43\min(1/\mu,2^{k_{\mathrm{bits}}})/\Lambda$; the touch floor as a theorem; exact wheel survivor counts and the derived ceiling $M/\varphi(M)$; a zero-violation audit and an explicit vacuity boundary.
7. **Witness corrections (§8).** Retraction of the Jacobi witness; the keyed-versus-fixed control; factor blindness of residue promotion at every modulus; a bounded, honest transfer statement for front-loading.

---

## 2. The reordering model

**Definition 2.1 (Reordering policy).** A *reordering policy* on an index set of size $n$ is a permutation $a$ of $\{0,\dots,n-1\}$, interpreted as the enumeration $a_0, a_1, \dots, a_{n-1}$ of slots to probe, subject to three admissibility conditions:

* **Uniformity.** One computable rule $f$ produces the enumeration for all input sizes: $a_k = f(k, N)$.
* **Test-blindness.** The enumeration is committed ex ante; probe outcomes may not influence the order.
* **Overhead charging.** Any auxiliary computation is charged against the policy's own budget (polylogarithmic overhead is free).

Every $N$-independent enumeration satisfies all three, which is precisely the corner of the design space that the Descending-Scan Principle overlooked.

**Definition 2.2 (Expected probe cost).** Given a probability mass $w$ on slots, the *expected probe cost* of the enumeration $a$ is
$$C_w(a) \;=\; \sum_{k=0}^{n-1} (k+1)\, w(a_k).$$
The slot visited $k$-th is charged $k+1$ probes, so $C_w(a)$ is the expected number of probes to the hit.

**Remark 2.3.** Cost is invariant under relabelling of slots and depends on $a$ only through the induced pairing of ranks with masses. This is what makes rearrangement theory the right tool.

---

## 3. What the action space proves

### 3.1 The Exchange Theorem

**Lemma 3.1 (Antivariance).** *If $g$ is antitone (nonincreasing) on $\{0,\dots,n-1\}$ then the pair of functions $k \mapsto k+1$ and $k \mapsto g(k)$ antivary: whenever $g(i) < g(j)$ we have $j < i$, hence $j + 1 \le i + 1$.*

*Proof.* Antitonicity gives $g(j) \le g(i)$ whenever $j \ge i$; contraposing, $g(i) < g(j)$ forces $j < i$. $\square$

**Theorem 3.2 (Sorted-order optimality, bare form).** *If $g$ is antitone then for every permutation $\sigma$,*
$$\sum_{k} (k+1)\,g(k) \;\le\; \sum_{k} (k+1)\,g(\sigma(k)).$$

*Proof.* Immediate from Lemma 3.1 and the rearrangement inequality for antivarying pairs: among all pairings of the increasing weights $k+1$ with the multiset of values of $g$, the one that pairs the largest weight with the smallest value — that is, the antitone arrangement — is minimal. Concretely, if any pairing places $g$-values out of antitone order, the transposition restoring the order changes the sum by $-(j-i)\bigl(g(i)-g(j)\bigr) \le 0$, and finitely many such transpositions sort the arrangement. $\square$

**Theorem 3.3 (Exchange Theorem: mass-sorting is extremal).** *Let $w$ be a mass on $n$ slots and let $a$ be an enumeration such that $w \circ a$ is antitone, i.e. $w(a_0) \ge w(a_1) \ge \cdots \ge w(a_{n-1})$. Then for every enumeration $b$,*
$$C_w(a) \;\le\; C_w(b).$$

*Proof.* Apply Theorem 3.2 with $g = w \circ a$ and $\sigma = a^{-1}\circ b$: then $g(\sigma(k)) = w(b_k)$, and the two sides are exactly $C_w(a)$ and $C_w(b)$. $\square$

**Remark 3.4 (What Theorem 3.3 does *not* say).** It privileges no arithmetic order. It says: visit slots in nonincreasing order of mass. Whether "$\sqrt N$-descending", "ascending", "wheel order", or anything else *realises* the mass-sort is determined by $w$, which is supplied by the generator, not by the policy. The Descending-Scan Principle attempts to name a winner without naming a $w$; §5 shows that no such naming is possible.

### 3.2 No free lunch on flat priors

**Theorem 3.5 (Flat-prior cost).** *If $w \equiv 1/n$ then $C_w(a) = (n+1)/2$ for every enumeration $a$.*

*Proof.* $C_w(a) = \frac1n\sum_{k=0}^{n-1}(k+1) = \frac1n\cdot\frac{n(n+1)}2 = \frac{n+1}2$, independent of $a$. $\square$

**Corollary 3.6.** Reordering yields no gain whatsoever against a featureless prior. Consequently *every* gain booked by a reordering policy is a gain harvested from the shape of the prior — a *prior-shape gain*. This is the conceptual pivot of the paper: order optimisation is a statistics problem wearing an algorithms costume.

### 3.3 The Abel identity and front-loading

**Theorem 3.7 (Abel identity).** *For any mass sequence $w_0,\dots,w_{n-1}$,*
$$\sum_{k=0}^{n-1}(k+1)w_k \;=\; \sum_{j=0}^{n-1}\ \sum_{k=j}^{n-1} w_k .$$

*Proof.* By induction on $n$; equivalently, exchange the order of summation in $\sum_k (k+1) w_k = \sum_k \sum_{j \le k} w_k$. The right-hand side is the sum of *survival masses*: the probability that the search is still alive after $j$ probes, summed over $j$. $\square$

**Theorem 3.8 (Head-domination law).** *Let $u,v$ be masses with the same total, $\sum_{k<n} u_k = \sum_{k<n} v_k$, and suppose $v$ dominates $u$ at every prefix: $\sum_{k<j} u_k \le \sum_{k<j} v_k$ for all $j \le n$. Then $C(v) \le C(u)$.*

*Proof.* By Theorem 3.7 it suffices to compare tails. Prefix domination plus equal totals gives $\sum_{k \ge j} v_k \le \sum_{k \ge j} u_k$ for every $j$; summing over $j$ gives the claim. $\square$

**Remark 3.9 (Scope).** Theorem 3.8 states that *front-loading* wins. It does not state that any particular arithmetic order front-loads. Which order does is exactly the population question resolved in §4. This distinction is the corrected form of an "early-fire" transfer claim discussed in §8.3.

---

## 4. The sign-flip law

### 4.1 The window model

Parametrise a draw by its balance ratio $r = q/p \in [1, k)$. Since $N = pq = p^2 r$, we have $p = \sqrt N/\sqrt r$: the smaller prime sits at *height* $h = 1/\sqrt r \in (1/\sqrt k,\, 1]$ in units of $\sqrt N$. Both policies scan the window $W_k(N)$, and in these units the distance scanned before the hit is:

**Definition 4.1 (Window costs, $k=2$).**
$$\mathrm{asc}(r) \;=\; \frac{1}{\sqrt r} - \frac{1}{\sqrt 2}, \qquad \mathrm{desc}(r) \;=\; 1 - \frac{1}{\sqrt r}.$$

**Definition 4.2 (Crossover constants).**
$$m^* \;=\; \frac{2+\sqrt2}{4} \approx 0.8535534, \qquad \rho^* \;=\; \frac{2}{1 + 1/\sqrt2} \;=\; 4 - 2\sqrt2 \approx 1.1715729 .$$

**Proposition 4.3.** $\rho^{*} m^{*} = 1$, and $1.1715 < \rho^{*} < 1.1716$.

*Proof.* $\bigl(4-2\sqrt2\bigr)\frac{2+\sqrt2}{4} = \frac{8 + 4\sqrt2 - 4\sqrt2 - 2\cdot 2}{4} = \frac{4}{4}=1$. Also $2/(1+1/\sqrt2) = 2\sqrt2/(\sqrt2+1) = 2\sqrt2(\sqrt2-1) = 4-2\sqrt2$. The bracket follows from $1.41421 < \sqrt2 < 1.414215$. $\square$

### 4.2 The population criterion

**Theorem 4.4 (Sign-flip law, arbitrary finite population).** *Let $(\pi_i)_{i \in S}$ be probability weights, $\sum_{i} \pi_i = 1$, and let $r_i$ be the corresponding balance ratios. Then*
$$\sum_i \pi_i\,\mathrm{asc}(r_i) \;<\; \sum_i \pi_i\,\mathrm{desc}(r_i) \iff \mathbb E\!\left[\tfrac{1}{\sqrt r}\right] := \sum_i \pi_i \frac{1}{\sqrt{r_i}} \;<\; m^{*}.$$

*Proof.* Write $m = \sum_i \pi_i r_i^{-1/2}$. Using $\sum_i \pi_i = 1$,
$$\sum_i \pi_i\,\mathrm{asc}(r_i) = m - \tfrac1{\sqrt2}, \qquad \sum_i \pi_i\,\mathrm{desc}(r_i) = 1 - m .$$
Hence the comparison reads $m - 1/\sqrt2 < 1 - m$, i.e. $2m < 1 + 1/\sqrt2$, i.e. $m < (1 + 1/\sqrt2)/2 = (2+\sqrt2)/4 = m^*$. $\square$

**Remark 4.5.** The criterion contains no $N$, no algorithmic parameter, and no reference to the policy class beyond the two costs. It is a functional of the *generator's $r$-law* alone. This is the precise sense in which the Descending-Scan Principle is a category error: it asserts, of the action space, something that is only ever true of a distribution.

### 4.3 Uniform bands

**Theorem 4.6 (Band mean).** *For $r \sim U[1, 1+\delta]$ with $\delta > 0$,*
$$\mathbb E\!\left[\tfrac{1}{\sqrt r}\right] \;=\; \frac1\delta \int_1^{1+\delta} r^{-1/2}\,dr \;=\; \frac{2\bigl(\sqrt{1+\delta}-1\bigr)}{\delta} \;=\; \frac{2}{1+\sqrt{1+\delta}} \;=:\; \mathcal M(\delta).$$

*Proof.* $\int_1^{1+\delta} r^{-1/2}dr = 2(\sqrt{1+\delta}-1)$. The last equality is rationalisation: $\delta = (\sqrt{1+\delta}-1)(\sqrt{1+\delta}+1)$. $\square$

**Theorem 4.7 (Monotonicity).** *$\mathcal M$ is strictly decreasing on $(0,\infty)$: wider bands are strictly more bottom-heavy.*

*Proof.* $\delta \mapsto \sqrt{1+\delta}$ is strictly increasing, and $x \mapsto 2/(1+x)$ is strictly decreasing on $x>0$. $\square$

**Theorem 4.8 (Sign-flip law for uniform bands).** *On $r \sim U[1,1+\delta]$, window-ascending strictly beats window-descending if and only if*
$$\delta \;>\; \delta^{*} \;=\; 80 - 56\sqrt 2 \;\approx\; 0.8040443 .$$

*Proof.* By Theorems 4.4 and 4.6 the criterion is $\mathcal M(\delta) < m^*$. Put $s = \sqrt{1+\delta} > 1$, so $\mathcal M = 2/(1+s)$. Then
$$\frac{2}{1+s} < \frac{2+\sqrt2}{4} \iff 8 < (2+\sqrt2)(1+s) \iff s > \frac{8}{2+\sqrt2} - 1 = 4(2-\sqrt2)-1 = 7 - 4\sqrt2 .$$
Note $7-4\sqrt2 \approx 1.34315 > 0$, so squaring is legitimate: $1 + \delta > (7-4\sqrt2)^2 = 49 - 56\sqrt2 + 32 = 81 - 56\sqrt2$, i.e. $\delta > 80 - 56\sqrt2$. $\square$

**Corollary 4.9 (Numerical bracket).** $0.804 < \delta^* < 0.805$, since $1.41421 < \sqrt2 < 1.414215$.

### 4.4 Hard balance

**Definition 4.10 (Population tilt).** For a population with mean height $m$ in the window $[1/\sqrt2, 1]$, the *tilt* is the normalised position
$$z \;=\; \frac{m - 1/\sqrt2}{\,1 - 1/\sqrt2\,} \in [0,1],$$
so $z = 0$ means all mass at the window bottom, $z=1$ all at the top, and $z < 1/2$ means bottom-heavy.

**Theorem 4.11 (Hard-balance tilt).** *At hard balance $q<2p$, i.e. $\delta = 1$, the tilt is exactly*
$$z \;=\; \sqrt2 - 1 \;\approx\; 0.4142136 .$$

*Proof.* $\mathcal M(1) = 2/(1+\sqrt2) = 2(\sqrt2-1)$. Then
$$z = \frac{2\sqrt2 - 2 - \tfrac{\sqrt2}{2}}{1 - \tfrac{\sqrt2}{2}} = \frac{\tfrac{3\sqrt2}{2}-2}{\tfrac{2-\sqrt2}{2}} = \frac{3\sqrt2-4}{2-\sqrt2}.$$
Multiplying numerator and denominator by $2+\sqrt2$: numerator $(3\sqrt2-4)(2+\sqrt2) = 6\sqrt2 + 6 - 8 - 4\sqrt2 = 2\sqrt2 - 2$, denominator $(2-\sqrt2)(2+\sqrt2) = 2$. Hence $z = \sqrt2 - 1$. $\square$

**Theorem 4.12 (Hard-balance ratio).** *At $\delta = 1$ the two window costs stand in the exact ratio*
$$\frac{1 - \mathcal M(1)}{\mathcal M(1) - 1/\sqrt2} \;=\; \sqrt 2 :$$
*descending costs exactly $\sqrt2$ times ascending.*

*Proof.* With $\mathcal M(1) = 2\sqrt2 - 2$: numerator $= 3 - 2\sqrt2$; denominator $= 2\sqrt2 - 2 - \frac{\sqrt2}{2} = \frac{3\sqrt2 - 4}{2}$. Their ratio is $\frac{2(3-2\sqrt2)}{3\sqrt2-4}$, and multiplying above and below by $3\sqrt2+4$ gives $\frac{2(3-2\sqrt2)(3\sqrt2+4)}{18-16} = (3-2\sqrt2)(3\sqrt2+4)$. Expanding: $9\sqrt2 + 12 - 12 - 8\sqrt2 = \sqrt2$. $\square$

**Corollary 4.13.** Hard balance is bottom-heavy and *ascending-extremal*, with an exact idealised advantage of $\sqrt2 \approx 1.4142$.

### 4.5 The general window family

**Theorem 4.14 (Family sign-flip law).** *For a generator advertising $q < kp$ with $k>1$, the window is $[\,1/\sqrt k,\ 1\,]$ in units of $\sqrt N$, with costs $\mathrm{asc}_k(r) = r^{-1/2} - k^{-1/2}$ and $\mathrm{desc}_k(r) = 1 - r^{-1/2}$. On $r \sim U[1,1+\delta]$, ascending strictly beats descending if and only if*
$$\delta \;>\; \delta^{*}(k) \;=\; \frac{8\sqrt k\,(\sqrt k - 1)}{(\sqrt k + 1)^2}.$$

*Proof sketch.* Write $t = \sqrt k > 1$, $s = \sqrt{1+\delta} > 1$, $\mathcal M = 2/(1+s)$, so $\mathcal M(1+s) = 2$. The comparison $\mathcal M - 1/t < 1 - \mathcal M$ is $2\mathcal M < 1 + 1/t$; multiplying by $t(1+s) > 0$ and using $\mathcal M(1+s)=2$ turns this into
$$4t < (t+1)(1+s).$$
Solving for $s$: $s > \frac{4t}{t+1} - 1 = \frac{3t-1}{t+1}$, which is positive for $t>1$, so squaring is legitimate and yields
$$\delta > \frac{(3t-1)^2 - (t+1)^2}{(t+1)^2} = \frac{8t^2-8t}{(t+1)^2} = \frac{8t(t-1)}{(t+1)^2},$$
which is $\delta^*(k)$ upon substituting $t=\sqrt k$. $\square$

**Proposition 4.15.** $\delta^*(2) = 80 - 56\sqrt2$.

*Proof.* With $t=\sqrt2$: $\frac{8\sqrt2(\sqrt2-1)}{(\sqrt2+1)^2} = \frac{16-8\sqrt2}{3+2\sqrt2}$. Multiplying by $\frac{3-2\sqrt2}{3-2\sqrt2}$ (note $(3+2\sqrt2)(3-2\sqrt2)=1$) gives $(16-8\sqrt2)(3-2\sqrt2) = 48 - 32\sqrt2 - 24\sqrt2 + 32 = 80 - 56\sqrt2$. $\square$

**Theorem 4.16 (The crossover lies strictly inside the admissible range).** *For every $k > 1$,*
$$\delta^{*}(k) \;<\; k - 1 .$$

*Proof.* With $t = \sqrt k > 1$ the claim is $\frac{8t(t-1)}{(t+1)^2} < t^2 - 1 = (t-1)(t+1)$. Dividing by $t-1>0$ and multiplying by $(t+1)^2>0$, it becomes $8t < (t+1)^3$. Expanding, $(t+1)^3 - 8t = t^3 + 3t^2 - 5t + 1 = (t-1)\left(t^2 + 4t - 1\right)$, and both factors are strictly positive for $t > 1$. $\square$

Since the admissible band widths for a generator advertising $q < kp$ are exactly $\delta \in (0, k-1]$, Theorem 4.16 says the crossover is always attainable from both sides.

---

## 5. The falsification

**Theorem 5.1 (The Descending-Scan Principle is false).** *There exist two admissible balanced populations — the hard band $\delta = 1$ and the narrow band $\delta = 1/2$, both legitimate for a generator advertising $q < 2p$ — such that the same pair of committed reordering policies (window-ascending, window-descending) has opposite strict winners:*
$$\mathcal M(1) - \tfrac1{\sqrt2} \;<\; 1 - \mathcal M(1), \qquad\text{but}\qquad 1 - \mathcal M(\tfrac12) \;<\; \mathcal M(\tfrac12) - \tfrac1{\sqrt2}.$$

*Proof.* The first inequality is Theorem 4.8 with $\delta = 1 > 0.805 > \delta^*$. For the second, $\mathcal M(1/2) = 2/(1+\sqrt{1.5})$, and $1.2247 < \sqrt{1.5} < 1.2248$ gives $0.8989 < \mathcal M(1/2) < 0.8990$; together with $1/\sqrt2 < 0.70711$ this yields $1 - \mathcal M(1/2) < 0.1011$ while $\mathcal M(1/2) - 1/\sqrt2 > 0.1917$. $\square$

**Corollary 5.2 (Universality).** *For every advertised ratio $k>1$ the same phenomenon occurs: the widest admissible band $\delta = k-1$ is ascending-extremal (since $\delta^*(k) < k-1$ by Theorem 4.16), while any band with $0 < \delta < \delta^*(k)$ is descending-extremal. Hence the falsification is a property of the whole window family and not of the $q < 2p$ convention.*

**Discussion 5.3.** Theorem 5.1 forecloses any repair of the principle that keeps its form. A statement of the shape "policy $\Pi_0$ is extremal in the reordering class" quantifies over inputs; the theorem exhibits inputs on both sides. The only surviving order-optimality statement is Theorem 3.3, which resolves the question *conditionally on $w$*. Correspondingly, the practical content migrates from "which order is best?" to "what is $\mathbb E[r^{-1/2}]$ for my generator?" — a measurement, with the protocol given next.

---

## 6. From measurement to certification

**Definition 6.1 (Prior-shape gain).** For a population with mean height $m \in (1/\sqrt2, 1)$ set
$$\Lambda(m) \;=\; \frac{1 - m}{\,m - 1/\sqrt2\,},$$
the ratio of expected descending cost to expected ascending cost. Ascending wins iff $\Lambda(m) > 1$ iff $m < m^*$.

**Theorem 6.2 (Antitonicity of $\Lambda$).** *$\Lambda$ is strictly decreasing on $(1/\sqrt2, 1)$.*

*Proof.* As $m$ increases, the numerator $1-m$ strictly decreases and stays positive, while the denominator $m - 1/\sqrt2$ strictly increases and stays positive. $\square$

**Theorem 6.3 (Measurement bracket).** *Let $\hat m$ be a measured mean with error bar $\varepsilon$, satisfying $1/\sqrt 2 < \hat m - \varepsilon$ and $\hat m + \varepsilon < 1$. If the true mean $m$ satisfies $|m - \hat m| \le \varepsilon$, then*
$$\Lambda(\hat m + \varepsilon) \;\le\; \Lambda(m) \;\le\; \Lambda(\hat m - \varepsilon).$$

*Proof.* Immediate from Theorem 6.2 applied to $\hat m - \varepsilon \le m \le \hat m + \varepsilon$. $\square$

**Theorem 6.4 (Certification).** *If in addition $\hat m + \varepsilon < m^{*}$, then on the measured population window-ascending is strictly extremal among the two window policies, and the realised gain factor satisfies $\Lambda(m) > 1$.*

*Proof.* $m \le \hat m + \varepsilon < m^*$, so Theorem 4.4 gives the strict win, and $\Lambda(m)>1$ follows from $m < m^*$ via $1 - m > m - 1/\sqrt2$. $\square$

**Corollary 6.5 (Certified hard-balanced pool).** *A pool measured at $\hat m = 0.8284$ — the analytic hard-balance value is $2(\sqrt2-1) = 0.82843\ldots$ — with the conservative error bar $\varepsilon = 0.01$ is certified ascending-extremal, since $0.7071 < 0.8184$ and $0.8384 < 0.85355$.*

This is the operational replacement for the folklore rule: *measure $\mathbb E[r^{-1/2}]$ with an error bar; if the interval clears the crossover, the order is certified and the gain is bracketed; if the interval straddles $m^*$, no order may be claimed extremal.*

---

## 7. The master speedup inequality and its calibration

### 7.1 Statement

Let $C_{\text{base}}$ be the cost of the reference full scan and $C_{\text{policy}}$ that of the policy; the *speedup* is $S = C_{\text{base}}/C_{\text{policy}}$. Let $\mu \in (0,1]$ be the structural keep fraction (the proportion of candidates that the policy's filter still leaves to be touched), $2^{k_{\mathrm{bits}}}$ the bucket budget of a $k_{\mathrm{bits}}$-bit filter, $\Lambda > 0$ the prior-shape factor, and $4/3$ the residue slack inherited from the surrounding barrier analysis.

**Theorem 7.1 (Master inequality).** *Suppose the two accounting floors hold:*
$$\text{(touch floor)}\quad \Lambda\,\mu\,C_{\mathrm{desc}} \le \tfrac43\,C_A, \qquad\qquad \text{(bit floor)}\quad \Lambda\,C_{\mathrm{desc}} \le \tfrac43\,2^{k_{\mathrm{bits}}}\,C_A .$$
*Then*
$$S \;=\; \frac{C_{\mathrm{desc}}}{C_A} \;\le\; \frac43\cdot\frac{\min\!\left(1/\mu,\ 2^{k_{\mathrm{bits}}}\right)}{\Lambda}.$$

*Proof.* From the touch floor, dividing by $\Lambda\mu C_A > 0$, $S \le \tfrac43 (1/\mu)/\Lambda$. From the bit floor, $S \le \tfrac43\, 2^{k_{\mathrm{bits}}}/\Lambda$. The minimum of the two bounds is the stated cap. Neither step assumes uniformity of hits inside cells. $\square$

### 7.2 The touch floor is a theorem, not a booking

**Theorem 7.2 (Touch floor).** *Suppose a filter leaves $\kappa$ of $M$ candidates to be touched, with $\kappa \ge \mu M$ for some $\mu \in (0,1]$. Against a hit uniform on the survivors the policy pays $(\kappa+1)/2$ probes, while the full scan pays $(M+1)/2$. Hence*
$$S \;=\; \frac{(M+1)/2}{(\kappa+1)/2} \;\le\; \frac1\mu .$$

*Proof.* The two cost values are Theorem 3.5 applied on $M$ and on $\kappa$ slots. The inequality $\frac{M+1}{\kappa+1} \le \frac1\mu$ is equivalent to $\mu(M+1) \le \kappa + 1$, which follows from $\mu M \le \kappa$ and $\mu \le 1$. $\square$

Note that Theorem 7.2 makes no distributional assumption *within* the surviving set beyond the reference model, and — critically — it makes no booking: $\mu$ enters as a lower bound on the surviving proportion.

### 7.3 Wheels: exact survivor counts and a derived ceiling

**Theorem 7.3 (Exact wheel survivor count).** *For all $M, m \ge 0$, the number of $x \in \{0,1,\dots,Mm-1\}$ with $\gcd(M,x)=1$ is exactly $\varphi(M)\,m$.*

*Proof.* Induction on $m$. For $m=0$ both sides vanish. For the step, split $\{0,\dots,M(m+1)-1\}$ as $\{0,\dots,Mm-1\}\ \sqcup\ \{Mm,\dots,Mm+M-1\}$; the second block is a complete residue system mod $M$ and hence contains exactly $\varphi(M)$ elements coprime to $M$. Adding gives $\varphi(M)m + \varphi(M) = \varphi(M)(m+1)$. $\square$

**Theorem 7.4 (Conservation of the touched count).** *A reordering is an injection on the candidate set, so the image of the survivor set has the same cardinality. No reordering policy can change how many candidates the filter leaves it to touch.*

*Proof.* The cardinality of the image of a finite set under an injective map equals the cardinality of the set. $\square$

Theorem 7.4 is what makes $\mu$ *extractable from the transcript* rather than a modelling convention: it is a conserved quantity of the action space.

**Theorem 7.5 (Wheel keep fraction and derived ceiling).** *Behind a mod-$M$ wheel the keep fraction is exactly $\mu = \varphi(M)/M$, and therefore, by the touch floor,*
$$S \;\le\; \frac{M}{\varphi(M)} .$$

*Proof.* Theorem 7.3 gives $\kappa = \varphi(M)m$ out of $Mm$, so $\kappa/(Mm) = \varphi(M)/M$ exactly. Apply Theorem 7.2 with $\mu = \varphi(M)/M$ and $M \leftarrow Mm$, $\kappa \leftarrow \varphi(M)m$. $\square$

**Corollary 7.6 (The mod-30 law).** *$\varphi(30) = 8$, so $\mu = 8/30 = 4/15$ and $S \le 30/8 = 15/4 = 3.75$.*

**Calibration.** Measured wheel speedups across the pools were $3.7331$, $3.741$ (headline) and $3.7496$, all strictly below $3.75$, with a relative gap of $0.24\%$ for the headline cell and at most $0.45\%$ across the arm. The ceiling is *derived* from the survivor count, not fitted.

### 7.4 The audit and the vacuity boundary

Every reported cell of the verification table — four pools (two hard-balanced pools of $n=2400$, a narrow-band pool of $n=1600$, and a legacy pool of $n=500$) across all policy arms, including the hybrid filter × reorder stress arm — satisfies the cap of Theorem 7.1. A representative selection, with $2^{k_{\mathrm{bits}}} = 32$ throughout:

| arm | $S$ | $\mu$ | $\Lambda$ | cap |
|---|---|---|---|---|
| wheel (three replicates) | $3.7331,\ 3.741,\ 3.7496$ | $4/15$ | $1$ | $5$ |
| keyed vs fixed mod-3, pool A | $0.6366,\ 0.6537$ | $1$ | $1$ | $4/3$ |
| keyed vs fixed mod-3, legacy pool | $0.684,\ 0.660$ | $1$ | $1$ | $4/3$ |
| narrow-band window arms | $0.5682,\ 1.000$ | $1$ | $1$ | $4/3$ |
| legacy pool, truncated ascending | $0.9278$ | $1$ | $1$ | $4/3$ |
| ladder surrogates | $0.990,\ 0.27$ | $1$ | $1$ | $4/3$ |
| hybrid window × wheel | $4.06$ | $4/15$ | $0.7533$ | $\approx 6.64$ |

**Zero violations.** Every row satisfies $S \le \tfrac43\min(1/\mu, 2^{k_{\mathrm{bits}}})/\Lambda$.

**Theorem 7.7 (Vacuity on pure permutations).** *If $\mu$ is booked at $1$ and $\Lambda = 1$, then for any bucket budget $2^{k_{\mathrm{bits}}} \ge 1$ the cap equals the constant $4/3$.*

*Proof.* $\min(1/1, 2^{k_{\mathrm{bits}}}) = 1$, so the cap is $\tfrac43 \cdot 1 / 1$. $\square$

A pure permutation with no filter therefore satisfies the cap tautologically; the inequality has content only when $\mu$ is genuinely extracted.

**Theorem 7.8 (Non-vacuity of the extracted cap).** *On the hybrid window × wheel arm of the legacy pool, with $\Lambda = 0.7533$ and $2^{k_{\mathrm{bits}}} = 32$: the measured $S = 4.06$ **violates** the cap computed with $\mu$ booked at $1$, namely $\tfrac43/0.7533 \approx 1.770 < 4.06$, and **satisfies** the cap computed with the structural wheel fraction $\mu = 4/15$, namely $\tfrac43 \cdot \tfrac{15}{4}/0.7533 \approx 6.638 \ge 4.06$.*

*Proof.* Direct arithmetic on the two expressions. $\square$

Theorem 7.8 identifies structural extraction of $\mu$ as *load-bearing*: with $\mu$ booked the cap is both vacuous and violated; with $\mu$ extracted it is neither.

---

## 8. Witness corrections

### 8.1 Retraction: the Jacobi witness is algebraically degenerate

A proposed witness evaluated the Jacobi symbol $\left(\frac{N}{x}\right)$ at candidates $x$ and promoted those with distinctive behaviour. It appeared to fire at the factor with probability $1$.

**Theorem 8.1 (Vanishing at the factor).** *Let $N = pq$ with $p$ prime. Then $\left(\frac{N}{p}\right) = 0$, for every $q$.*

*Proof.* The Jacobi symbol $\left(\frac{a}{n}\right)$ vanishes exactly when $n \ne 0$ and $\gcd(a,n) \ne 1$. Here $n = p \ne 0$ and $\gcd(pq, p) = p \ne 1$ since $p$ is prime. $\square$

**Corollary 8.2 (Zero information).** *For any two draws $(p,q)$ and $(p',q')$ with $p,p'$ prime, $\left(\frac{pq}{p}\right) = \left(\frac{p'q'}{p'}\right) = 0$. The witness is a constant function of the draw at the target, hence no statistic built from it can separate populations.*

**Proposition 8.3 (Contrast).** *If $\gcd(N,x) = 1$ then $\left(\frac{N}{x}\right) \ne 0$.*

*Proof.* Immediate from the same vanishing criterion. $\square$

Together: the witness's apparent perfect firing rate measures the tautology "$p$ divides $N$" — the very fact the search seeks — and not prior shape. It is retracted. Empirically this matches the observation that the symbol was zero at $p$ on $100\%$ of draws while the promoted share among the coprime candidates was a fair coin ($0.5036$, $0.5015$).

### 8.2 Replacement: keyed-versus-fixed residue control

The corrected experiment compares an arm whose promoted residue class mod $3$ is *keyed to $N$* against an arm using a *fixed* class. Measured speedups were statistically identical ($0.6366$ vs $0.6537$ on a hard-balanced pool; $0.684$ vs $0.660$ on the legacy pool) with hit-enrichment $\approx 1/2$ in both arms. Here is the reason, and it is exact.

**Theorem 8.4 (Residue class counts).** *For $M \ge 1$, $m \ge 0$ and $0 \le c < M$, exactly $m$ of the first $Mm$ candidates satisfy $x \equiv c \pmod M$.*

*Proof.* The map $x \mapsto \lfloor x/M\rfloor$ is a bijection from $\{x < Mm : x \equiv c\}$ to $\{0,\dots,m-1\}$, with inverse $i \mapsto Mi + c$. $\square$

**Theorem 8.5 (Coprime class count, $M=3$).** *Exactly $2m$ of the first $3m$ candidates are not divisible by $3$.*

*Proof.* Split into the classes $c = 1$ and $c = 2$ and apply Theorem 8.4 twice. $\square$

**Theorem 8.6 (Keyed and fixed arms are identical).** *For any two invertible classes $c_1, c_2$ mod $3$, promoting class $c_1$ and promoting class $c_2$ promote exactly the same number of candidates, and the promoted share among candidates coprime to $3$ is exactly $1/2$ in both arms.*

*Proof.* Both counts equal $m$ by Theorem 8.4; the coprime population is $2m$ by Theorem 8.5. $\square$

**Theorem 8.7 (Factor blindness of residue promotion).** *Let $\mathrm{key} : \mathbb N \to \mathbb N$ be any function taking values in the invertible classes mod $3$. Then for all $N, N'$, the promoted counts under $\mathrm{key}(N)$ and $\mathrm{key}(N')$ are equal. Consequently the $N$-keyed and fixed-key arms are indistinguishable by the promotion statistic.*

*Proof.* Immediate from Theorem 8.6. $\square$

**Theorem 8.8 (Factor blindness at every modulus).** *Theorems 8.4, 8.6, 8.7 hold verbatim at any modulus $M \ge 1$: each residue class holds exactly $m$ of the first $Mm$ candidates; the promoted share among the $\varphi(M)m$ wheel survivors is exactly $1/\varphi(M)$ for every invertible class; hence a keyed promotion rule is statistically indistinguishable from a fixed one at every modulus.*

*Proof.* Theorem 8.4 is stated at general $M$; the survivor count is Theorem 7.3; the share is $m/(\varphi(M)m) = 1/\varphi(M)$. $\square$

**Interpretation.** Residue couplings carry *zero* information about the factorisation. Any measured gain in such an arm is prior-shape leakage on non-monotone-likelihood-ratio marginals — precisely the channel isolated in §4 — and not residue information. This replicates the factor-blindness law under a proper control.

### 8.3 A bounded transfer statement

An "early-fire" phenomenon observed in a completion-based method was proposed as support for descending scans. The transferable content is exactly Theorem 3.8: front-loading dominates. What does *not* transfer is the identification of $\sqrt N$-descending with front-loading, which requires a centering assumption that the reordering model does not supply. Surrogate experiments on $K = 4096$ slots make the gap concrete: an enumeration front-loaded at $\sqrt N$ costs $948$, a ladder-aligned one $1493$, and a naive one $3149$; relocating the front-loading to the low end reverses the ordering, and the ladder-aligned surrogate matches descending at $S \approx 0.990$ while the naive ladder collapses to $0.27$.

### 8.4 A prior result refined, not contradicted

An earlier experiment reported window-descending beating truncated ascending by a factor $1.08$ on its own pool. Independent replication on that pool gives $0.9278$ for truncated ascending against descending, i.e. a ratio of $1.078$ — a refinement in the third digit, not a contradiction. Its pool's tilt sits between the hard-balanced and narrow-band regimes, which by Theorem 4.4 is exactly the condition under which descending wins. Two scope conditions attach. First, prior-shape dominance in favour of ascending holds only under *hard* balance $q < 2p$. Second, the window policy is undefined on $21.6\%$ of that pool's draws, because those draws violate the balance promise that licenses the window. Deployable gains therefore require first verifying that the deployed generator enforces balance; otherwise the policy is not merely suboptimal but undefined.

### 8.5 A note on an earlier discrepancy

An initial small-sample study of the hard-balanced pools reported an ascending advantage of $1.71$–$1.91$, in tension with its own analytic prediction of $1.59$. Independent replication at $n = 2400$ per pool gives $1.5785 \pm 0.029$ and $1.6114 \pm 0.033$, consistent with the two-stage analytic value $0.219/0.138 = 1.587$ and with the idealised one-shot value $\sqrt2 = 1.414$ of Theorem 4.12 as the core term. The original discrepancy was sampling inflation at $n = 150$; the analytic prediction was correct throughout. Measured tilts were $z \in [0.4095, 0.4148]$ against the exact $\sqrt2 - 1 = 0.41421$ of Theorem 4.11, and narrow-band pools measured $z \approx 0.6466$ against the analytic $0.6551$ at $\delta = 1/2$, top-heavy as Theorem 4.7 predicts.

---

## 9. Algorithms

Three procedures make the theory operational.

**A. Mass-sorted enumeration.** Given slot masses $w_0,\dots,w_{n-1}$, return the permutation sorting slots by nonincreasing mass; by Theorem 3.3 it is extremal. Cost $O(n\log n)$; the resulting expected probe cost is computed in $O(n)$ by the definition or, equivalently, by the Abel identity of Theorem 3.7.

**B. Sign-flip decision with certification.** Given a sample $r_1,\dots,r_n$ of balance ratios, compute $\hat m = \frac1n\sum_i r_i^{-1/2}$ and the standard error $\varepsilon = z\,\hat\sigma/\sqrt n$ of $r^{-1/2}$. If $\hat m + \varepsilon < (2+\sqrt2)/4$, certify ascending with gain bracket $[\Lambda(\hat m+\varepsilon), \Lambda(\hat m - \varepsilon)]$; if $\hat m - \varepsilon > (2+\sqrt2)/4$, certify descending symmetrically; otherwise return *undetermined*. Cost $O(n)$.

**C. Cap audit.** For each measured cell $(S,\mu,2^{k_{\mathrm{bits}}},\Lambda)$ evaluate $\tfrac43\min(1/\mu,2^{k_{\mathrm{bits}}})/\Lambda$ and flag $S$ exceeding it. When the policy is filtered, extract $\mu$ structurally (for a mod-$M$ wheel, $\mu = \varphi(M)/M$ by Theorem 7.5) rather than booking $\mu=1$, which by Theorem 7.7 renders the cap vacuous. Cost $O(1)$ per cell.

---

## 10. Discussion

The result is best read as a boundary statement about a class of algorithms. The reordering class has exactly one degree of freedom — the ordering — and Theorem 3.5 shows the freedom is worth nothing against a flat prior. Everything the class can achieve is therefore a functional of the input distribution, and the Exchange Theorem describes that functional completely: sort by mass. Any statement naming a *specific arithmetic order* as extremal is thus either a disguised assertion about the input distribution (in which case it should be stated as such and measured) or false (in which case Theorem 5.1 exhibits the counterexample pair).

The sign-flip law makes this precise in the one-parameter setting that matters practically, and its crossover constants are exact: $m^* = (2+\sqrt2)/4$ on the mean-height scale, $\rho^* = 4 - 2\sqrt2$ on the reciprocal scale, $\delta^* = 80-56\sqrt2$ on the band-width scale, and $\delta^*(k) = 8\sqrt k(\sqrt k-1)/(\sqrt k+1)^2$ in the general family. The universality statement $\delta^*(k) < k-1$ removes the last hope of rescuing the folklore rule by tightening the balance convention.

On the upper-bound side, the value of the master inequality lies less in the constant $4/3$ — inherited, and untouched here — than in the discipline it enforces. The touch floor is a theorem (Theorem 7.2) resting on a conservation law (Theorem 7.4): reordering is a bijection, so the number of survivors it must touch is invariant. This is why the mod-30 ceiling $30/\varphi(30) = 3.75$ is *derived* and matches measurement to within half a percent. It is also why the vacuity boundary matters: booking $\mu = 1$ collapses the cap to $4/3$ and both hides and falsifies the hybrid arm's genuine $S = 4.06$.

The two witness corrections carry a shared methodological lesson: a statistic can appear informative precisely because it is degenerate. The Jacobi witness fired perfectly because it was computing a tautology; the residue promotion appeared to gain because the comparison lacked a control. In both cases the corrected version is provable rather than measured — the symbol vanishes identically, and the promoted counts are equal at every modulus by a bijection.

**Limitations.** The window model treats scan cost as distance in units of $\sqrt N$, which idealises the per-candidate cost as constant; the two-stage refinement (whose ratio $1.587$ matches measurement) shows the idealisation shifts constants but not signs. The criterion of Theorem 4.4 is a *mean* comparison and therefore optimises expected cost, not median or tail cost. Finally, the unconditional factor-blindness of arbitrary polylogarithmically-computable enumerations remains open and is equivalent to a sublinear-time factoring separation; we do not claim it.

---

## 11. Future work

1. **Quantile crossover versus mean crossover.** The criterion proved here is a comparison of means. We conjecture that the median-optimal policy flips at a strictly different band width, opening an indeterminacy interval around $80 - 56\sqrt2$ within which the two objectives disagree.
2. **Two-stage window splits.** We conjecture that an optimal split of the balance window into two scanned segments strictly beats both pure orders, with the optimal split point determined by the population's height law; the empirical two-stage ratio $1.587$ is suggestive.
3. **Measured deployment laws.** Restate the sign-flip criterion with a directly measured $\Lambda$ for a deployed generator, so that the monotone-likelihood-ratio premise underlying the window comparison is checked rather than assumed.
4. **Structural keep-fraction extraction in general.** Extend Theorem 7.5 beyond wheels, so that $\mu$ can be read from the transcript for arbitrary filters and the cap is never vacuous.
5. **Unconditional factor blindness.** Prove or relativise the statement that no polylogarithmically-computable enumeration can be factor-sensitive. This is likely a permanent obstruction in the unrelativised setting; a hardness-relative or oracle formulation is the realistic target.

---

## 12. Summary of results

* **Exchange Theorem.** Mass-sorted enumerations are extremal, and no arithmetic order is privileged.
* **No free lunch.** Every enumeration costs $(n+1)/2$ on a flat prior; all gains are prior-shape gains.
* **Abel identity and head domination.** Expected cost equals the sum of survival masses; prefix-dominating enumerations cost no more.
* **Sign-flip law.** Ascending beats descending iff $\mathbb E[r^{-1/2}] < (2+\sqrt2)/4$, iff the reciprocal crossover $4-2\sqrt2 \approx 1.17157$ is passed.
* **Band law.** $\mathbb E[r^{-1/2}] = 2/(1+\sqrt{1+\delta})$, strictly decreasing in $\delta$; ascending wins iff $\delta > 80 - 56\sqrt2 \approx 0.80404$.
* **Hard balance.** Tilt exactly $\sqrt2-1$; cost ratio exactly $\sqrt2$.
* **Family law and universality.** $\delta^*(k) = 8\sqrt k(\sqrt k-1)/(\sqrt k+1)^2 < k-1$ for all $k>1$.
* **Falsification.** Two admissible populations, same two policies, opposite winners — at every $k$.
* **Certification.** A measurement clearing the crossover certifies the extremal order and brackets the gain.
* **Master cap.** $S \le \tfrac43\min(1/\mu, 2^{k_{\mathrm{bits}}})/\Lambda$, with the touch floor proved, zero audit violations, and an explicit vacuity boundary.
* **Wheel law.** $\varphi(M)m$ survivors out of $Mm$, conserved under reordering, giving $S \le M/\varphi(M)$; at $M=30$ this is $3.75$ against measurements $3.7331$–$3.7496$.
* **Witnesses.** The Jacobi witness is identically zero at the factor and is retracted; residue promotion is factor-blind at every modulus.
