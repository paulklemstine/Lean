# Sharper Normalization: The Attained Factor-$\tfrac{1}{2}$ Theory of Total Variation

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

The total variation distance between two probability distributions $p, q$ on a finite set is conventionally normalized as $d_{TV}(p,q) = \tfrac12\sum_x|p(x)-q(x)|$. The factor $\tfrac12$ is usually presented as a convention. We develop the theory in which it is a theorem: $d_{TV}$ is the *attained* supremum of the distinguishing gap $p(A) - q(A)$ over events $A$, and simultaneously the *attained* infimum of the disagreement probability $\mathbb{P}[X \ne Y]$ over couplings of $p$ and $q$. Both optima are exhibited by explicit witnesses — the likelihood-ratio event $\{q \le p\}$ and the maximal coupling — yielding a minimax identity
$$\max_{A \subseteq \mathcal{X}} \bigl(p(A) - q(A)\bigr) \;=\; d_{TV}(p,q) \;=\; \min_{c \in \Pi(p,q)} \mathbb{P}_c[X \ne Y]$$
with matching primal and dual certificates. We then show that attainment, rather than mere validity, is what allows the constant to survive composition. Five consequences are developed: (i) the exact two-point testing optimum $(1-d_{TV})/2$, together with the fact that randomized tests do not improve on deterministic ones; (ii) the exact $\ell^1$/$\ell^\infty$ dichotomy that localizes the factor of two as an affine change of coordinates on the test polytope; (iii) the data-processing inequality for arbitrary stochastic channels; (iv) a geometric $n$-sample amplification law $d_{TV}(p^{\otimes n}, q^{\otimes n}) \le 1 - (1-d_{TV})^n$, proved by tensorizing the maximal coupling and strictly stronger than the classical hybrid bound $n\,d_{TV}$ for all $n \ge 2$; and (v) an event-wise Pinsker bridge converting Kullback–Leibler control into per-test guarantees, with a converse certificate. Finally, we identify the Shtarkov sum of universal coding with the multi-hypothesis testing optimum: the least uniform-prior error of an $m$-ary decision rule is exactly $1 - C_S/m$, which for $m=2$ reproduces the two-point bound. Throughout we quantify what the lossy $\ell^1$ normalization costs: it is strictly lossy whenever $p \ne q$, and it renders several of the derived bounds vacuous exactly in the regimes of practical interest.

**Keywords:** total variation, distinguishing advantage, maximal coupling, Strassen's theorem, hypothesis testing, Le Cam method, data processing inequality, tensorization, Pinsker's inequality, Shtarkov sum.

---

## 1. Introduction

### 1.1 The question the normalization answers

Let $\mathcal{X}$ be a finite set and let $p, q$ be probability distributions on it. Two normalizations of the same underlying object compete in the literature:

$$\|p - q\|_1 = \sum_{x} |p(x)-q(x)|, \qquad d_{TV}(p,q) = \frac{1}{2}\sum_x |p(x)-q(x)|.$$

Both are metrics on the simplex; they differ by a constant; and it is common to treat the choice as immaterial. It is not immaterial, and this paper is an account of why.

The reason is *operational*. There is a question of genuine interest — how well can a single observation distinguish $p$ from $q$? — and exactly one of the two normalizations answers it. Specifically, an observer who sees a sample and must decide whether it came from $p$ or from $q$ has an optimal advantage over guessing equal to $d_{TV}(p,q)$, and the optimum is achieved by an explicit test. The $\ell^1$ quantity is not the optimum of anything probabilistic; it is the optimum of a *signed* variational problem over a larger, non-probabilistic class of tests. When one uses $\ell^1$ where $d_{TV}$ belongs, one is not making a harmless constant-factor concession: one is answering a coarser question and then inheriting the slack.

### 1.2 The two faces of $d_{TV}$

The technical core of the paper is that $d_{TV}$ has two exact descriptions, one as a maximum and one as a minimum:

* a **primal / testing** description as $\max_A (p(A)-q(A))$, witnessed by the likelihood-ratio event $A^\star = \{x : q(x) \le p(x)\}$;
* a **dual / transport** description as $\min_c \mathbb{P}_c[X \ne Y]$ over couplings, witnessed by the maximal coupling.

Each is proved by exhibiting its optimum, and the two proofs are linked: the coupling lower bound is obtained by pushing the optimal *event* through an arbitrary coupling. The pair constitutes a minimax identity with matching certificates. We emphasize that our proof of the identity is constructive rather than by linear-programming duality; the LP-duality reading is discussed in §8.

### 1.3 Why attainment, not validity, is the point

A bound that is valid can be chained; a bound that is *attained* can be chained without loss and audited at each step. The results of §§4–7 are all obtained by composing the two characterizations with a further structure — a channel, a product, a divergence, a family of hypotheses — and in each case the sharp constant is the difference between a usable statement and a vacuous one:

| Statement | with $d_{TV}$ | with $\|\cdot\|_1$ |
|---|---|---|
| Two-point testing optimum | $(1 - d_{TV})/2 \in [0, \tfrac12]$ | $(1 - \|p-q\|_1)/2$, negative once $\|p-q\|_1 > 1$ |
| Pinsker-derived error bound | $(1 - \sqrt{\mathrm{KL}/2})/2$ | $(1 - \sqrt{2\mathrm{KL}})/2$, vacuous for $\mathrm{KL} \in [\tfrac18, \tfrac12]$ |
| Coupling identity | $\min_c \mathbb{P}[X\ne Y] = d_{TV} \in [0,1]$ | right-hand side may exceed $1$ |

### 1.4 Contributions and organization

§2 fixes notation and states the event-supremum theorem with its corollaries: two-sidedness, optimality of deterministic tests, the sharp oscillation (Lipschitz) bound, strict lossiness of the $\ell^1$ estimate, and the two rigid endpoints. §3 localizes the factor of two via $\ell^1$–$\ell^\infty$ duality of the test polytope. §4 develops couplings, proves the maximal-coupling theorem, and assembles the minimax identity. §5 treats hypothesis testing: the two-point bound and the data-processing inequality. §6 proves the geometric amplification law and its sample-complexity consequence. §7 builds the Pinsker bridge in both directions. §8 identifies the Shtarkov sum with the multi-hypothesis optimum. §9 gives algorithmic content, §10 applications, §11 discussion and future directions.

---

## 2. The event-supremum characterization

### 2.1 Definitions

Throughout, $\mathcal{X}$ is a finite set. A **law** on $\mathcal{X}$ is a function $p : \mathcal{X} \to \mathbb{R}$ with $p \ge 0$ and $\sum_x p(x) = 1$. (Several statements below need only the normalization $\sum_x p(x)=1$; we flag where non-negativity is genuinely used.)

**Definition 2.1 (Total variation distance).** $\displaystyle d_{TV}(p,q) = \frac{1}{2}\sum_{x \in \mathcal{X}} |p(x)-q(x)|.$

**Definition 2.2 (Event probability and distinguishing gap).** For $A \subseteq \mathcal{X}$, put $p(A) = \sum_{x \in A} p(x)$ and
$$\Delta_{p,q}(A) \;=\; p(A) - q(A) \;=\; \sum_{x\in A}\bigl(p(x)-q(x)\bigr).$$

**Definition 2.3 (Likelihood-ratio event).** $A^\star = A^\star(p,q) = \{x \in \mathcal{X} : q(x) \le p(x)\}$.

$A^\star$ is the Neyman–Pearson test at threshold $1$: accept the hypothesis "$p$" exactly when the likelihood ratio $p(x)/q(x)$ is at least one.

**Definition 2.4 (Boolean and randomized advantage).** For $f : \mathcal{X} \to \{0,1\}$, the *Boolean advantage* is $\Delta_{p,q}(f^{-1}(1))$. For $g : \mathcal{X} \to [0,1]$ (a randomized test that accepts $x$ with probability $g(x)$), the *soft advantage* is $\sum_x (p(x)-q(x))g(x)$.

### 2.2 The theorem

**Theorem 2.5 (Event-supremum characterization).** Let $p, q$ be laws on $\mathcal{X}$. Then
$$\Delta_{p,q}(A) \;\le\; d_{TV}(p,q) \qquad \text{for every } A \subseteq \mathcal{X},$$
with equality for $A = A^\star$. Consequently $d_{TV}(p,q)$ is the greatest element of the range of $\Delta_{p,q}$:
$$d_{TV}(p,q) \;=\; \max_{A \subseteq \mathcal{X}} \bigl(p(A) - q(A)\bigr) \;=\; \sup_{A} \bigl(p(A)-q(A)\bigr).$$

*Proof sketch.* Write $u_+ = \max(u,0)$. Two observations. First, the **surplus identity**
$$\sum_x \bigl(p(x)-q(x)\bigr)_+ \;=\; d_{TV}(p,q),$$
which follows because $\sum_x(p(x)-q(x)) = 0$ forces the total positive part to equal the total negative part, while their sum is $\sum_x|p(x)-q(x)| = 2d_{TV}$. Second, for any $A$,
$$\sum_{x \in A}(p(x)-q(x)) \;\le\; \sum_{x\in A}(p(x)-q(x))_+ \;\le\; \sum_{x \in \mathcal{X}}(p(x)-q(x))_+,$$
using $u \le u_+$ termwise and then non-negativity of the omitted terms. Combining gives the bound. For attainment, note $x \in A^\star \iff p(x)-q(x) \ge 0$, so $\sum_{x \in A^\star}(p(x)-q(x)) = \sum_x (p(x)-q(x))_+ = d_{TV}(p,q)$. $\square$

An equivalent formulation used repeatedly below: the **shared-mass identity**
$$\sum_x \min(p(x), q(x)) \;=\; 1 - d_{TV}(p,q). \tag{2.1}$$
Indeed $\min(a,b) = \tfrac12(a+b-|a-b|)$, and summing over $x$ gives $1 - d_{TV}$.

### 2.3 Immediate corollaries

**Corollary 2.6 (Two-sided form).** $|\Delta_{p,q}(A)| \le d_{TV}(p,q)$ for all $A$. *(Apply Theorem 2.5 to the pair $(q,p)$ and use $d_{TV}(p,q) = d_{TV}(q,p)$.)*

**Corollary 2.7 (Boolean distinguishers).** $d_{TV}(p,q)$ is the greatest advantage achievable by a Boolean test $f : \mathcal{X}\to\{0,1\}$, namely $\sup_f\bigl(\mathbb{P}_p[f = 1] - \mathbb{P}_q[f=1]\bigr) = d_{TV}(p,q)$, attained by $f = \mathbf{1}_{A^\star}$.

**Theorem 2.8 (Randomization does not help).** For every $g : \mathcal{X} \to [0,1]$,
$$\Bigl| \sum_x p(x)g(x) - \sum_x q(x)g(x) \Bigr| \;\le\; d_{TV}(p,q),$$
and the bound is attained at $g = \mathbf{1}_{A^\star}$.

*Proof sketch.* The soft advantage is a linear functional of $g$ on the cube $[0,1]^{\mathcal{X}}$, whose extreme points are the Boolean tests; alternatively, bound directly by $\sum_x (p(x)-q(x))_+ g(x) \le \sum_x (p(x)-q(x))_+$ after discarding the non-positive contributions. Either route lands on Theorem 2.5. $\square$

**Theorem 2.9 (Sharp oscillation bound).** Let $g : \mathcal{X}\to\mathbb{R}$ satisfy $m \le g(x) \le M$ for all $x$. Then
$$\bigl|\mathbb{E}_p[g] - \mathbb{E}_q[g]\bigr| \;\le\; (M-m)\, d_{TV}(p,q),$$
and the constant $M - m$ cannot be improved: with $m=0$, $M=1$ and $g = \mathbf{1}_{A^\star}$ one has $\mathbb{E}_p[g] - \mathbb{E}_q[g] = (1-0)\,d_{TV}(p,q)$ exactly.

*Proof sketch.* Since $\sum_x (p(x)-q(x)) = 0$, we may recentre: $\mathbb{E}_p[g]-\mathbb{E}_q[g] = \sum_x (p(x)-q(x))(g(x)-m)$. The recentred observable takes values in $[0, M-m]$, so writing $g - m = (M-m)h$ with $h : \mathcal{X}\to[0,1]$ and applying Theorem 2.8 to $h$ gives the bound. $\square$

Theorem 2.9 is the workhorse in applications: it says that total variation is exactly the modulus of continuity of bounded statistics. Two distributions at TV distance $\varepsilon$ agree, to within $\varepsilon$, on every $[0,1]$-valued figure of merit.

**Proposition 2.10 (Strict lossiness of the $\ell^1$ estimate).** If $p \ne q$ then
$$d_{TV}(p,q) \;<\; \sum_x |p(x)-q(x)| \;=\; 2\,d_{TV}(p,q).$$
Hence any argument that uses $\|p-q\|_1$ as a bound on a distinguishing gap loses a strictly positive amount, quantitatively a factor of two.

**Proposition 2.11 (Range and rigid endpoints).** For laws $p, q$: (i) $0 \le d_{TV}(p,q) \le 1$; (ii) $d_{TV}(p,q) = 0$ iff $p = q$, i.e. iff no event distinguishes them at all; (iii) $d_{TV}(p,q) = 1$ iff $p$ and $q$ are mutually singular, i.e. $p(x) = 0$ or $q(x)=0$ for every $x$, in which case some event separates them perfectly.

*Proof sketch.* All three follow from (2.1): $\sum_x \min(p,q) = 1 - d_{TV}$ is a sum of non-negative terms bounded above by $1$, so $d_{TV}\in[0,1]$; it equals $1$ iff every $\min(p(x),q(x))$ vanishes, which is mutual singularity; it equals $0$ iff $\sum|p-q| = 0$, i.e. $p=q$. $\square$

Together with symmetry and the triangle inequality (Proposition 3.5 below), (ii) makes $d_{TV}$ a genuine metric on the simplex, whose diameter is exactly $1$ — the sharp normalization is precisely the one under which the diameter is a probability.

---

## 3. Where the factor of two lives: duality of the test polytope

Theorem 2.5 optimizes over the polytope $\mathcal{G}_{[0,1]} = \{g : \mathcal{X}\to[0,1]\}$. The $\ell^1$ norm is the optimum over the larger, symmetric polytope $\mathcal{G}_{[-1,1]}$.

**Definition 3.1 (Signed advantage).** For $g:\mathcal{X}\to\mathbb{R}$, $\ \mathrm{adv}^{\pm}_{p,q}(g) = \sum_x (p(x)-q(x))\,g(x)$.

**Theorem 3.2 ($\ell^\infty$-dual description of the $\ell^1$ norm).** For all laws (indeed all real vectors) $p, q$,
$$\max_{\|g\|_\infty \le 1} \ \mathrm{adv}^{\pm}_{p,q}(g) \;=\; \sum_x |p(x)-q(x)| \;=\; 2\,d_{TV}(p,q),$$
attained at the sign pattern $g = \operatorname{sgn}(p-q)$.

*Proof sketch.* Upper bound termwise: $(p(x)-q(x))g(x) \le |p(x)-q(x)|\,|g(x)| \le |p(x)-q(x)|$. Attainment: with $g(x) = \operatorname{sgn}(p(x)-q(x)) \in \{-1,0,1\}$ each term equals $|p(x)-q(x)|$. $\square$

**Theorem 3.3 (Factor-two dichotomy).** For laws $p, q$, both of the following hold:
$$\max_{g : \mathcal{X}\to[0,1]} \ \mathrm{adv}^{\pm}_{p,q}(g) \;=\; d_{TV}(p,q), \qquad \max_{g : \mathcal{X}\to[-1,1]} \ \mathrm{adv}^{\pm}_{p,q}(g) \;=\; 2\,d_{TV}(p,q),$$
each attained ($\mathbf{1}_{A^\star}$ and $\operatorname{sgn}(p-q)$ respectively).

**Lemma 3.4 (The invisible affine shift).** For laws $p, q$ and any $g : \mathcal{X}\to\mathbb{R}$,
$$\sum_x (p(x)-q(x))\cdot \frac{1+g(x)}{2} \;=\; \frac{1}{2}\,\mathrm{adv}^{\pm}_{p,q}(g).$$

*Proof.* Expand; the constant term contributes $\tfrac12\sum_x(p(x)-q(x)) = 0$ by normalization. $\square$

Lemma 3.4 is the precise content of the "factor of two". The affine bijection $g \mapsto (1+g)/2$ carries $\mathcal{G}_{[-1,1]}$ onto $\mathcal{G}_{[0,1]}$; mass conservation annihilates the shift; the scaling by $\tfrac12$ survives. Hence the two suprema in Theorem 3.3 differ by exactly $2$, always, and neither is "the right one" in the abstract: $\mathcal{G}_{[0,1]}$ is the class of *probabilistic* tests, so its optimum is a probability, while $\mathcal{G}_{[-1,1]}$ is the unit ball of $\ell^\infty$, so its optimum is the dual norm. The $\ell^1$ bound is not sloppy; it is the correct answer to a coarser question.

**Proposition 3.5 (Metric properties).** $d_{TV}$ is symmetric, vanishes exactly on the diagonal, and satisfies the triangle inequality $d_{TV}(p,r) \le d_{TV}(p,q)+d_{TV}(q,r)$. *(Termwise from $|a-c| \le |a-b|+|b-c|$.)*

---

## 4. The coupling characterization

### 4.1 Couplings

**Definition 4.1 (Coupling).** A function $c : \mathcal{X}\times\mathcal{X}\to\mathbb{R}$ is a **coupling** of $p$ and $q$ if $c \ge 0$, $\sum_y c(x,y) = p(x)$ for all $x$, and $\sum_x c(x,y) = q(y)$ for all $y$. We write $c \in \Pi(p,q)$; the set is nonempty (it contains the product $p\otimes q$) and is the *transport polytope*.

**Definition 4.2 (Disagreement probability).** $\displaystyle \mathbb{P}_c[X\ne Y] = \sum_{x}\sum_{y \ne x} c(x,y).$

**Lemma 4.3 (Diagonal form).** If $c \in \Pi(p,q)$ then $\mathbb{P}_c[X\ne Y] = 1 - \sum_x c(x,x)$.

*Proof.* For fixed $x$, $\sum_{y\ne x} c(x,y) = p(x) - c(x,x)$ by the first marginal condition; sum over $x$ and use $\sum_x p(x)=1$. $\square$

### 4.2 Every coupling dominates $d_{TV}$

**Theorem 4.4 (Coupling bound on distinguishing gaps).** Let $c \in \Pi(p,q)$ and $A \subseteq \mathcal{X}$. Then
$$p(A) - q(A) \;\le\; \mathbb{P}_c[X \ne Y].$$

*Proof sketch.* Using the marginal conditions, $p(A) = \sum_{x,y} c(x,y)\mathbf{1}_A(x)$ and $q(A) = \sum_{x,y}c(x,y)\mathbf{1}_A(y)$, so
$$p(A)-q(A) = \sum_{x,y} c(x,y)\bigl(\mathbf{1}_A(x) - \mathbf{1}_A(y)\bigr).$$
The bracket vanishes when $x = y$ and is at most $1$ always; since $c \ge 0$, each term is bounded by the corresponding off-diagonal term of $\mathbb{P}_c[X\ne Y]$. $\square$

**Corollary 4.5 (Coupling lower bound).** For every $c \in \Pi(p,q)$, $\ d_{TV}(p,q) \le \mathbb{P}_c[X\ne Y]$.

*Proof.* Take $A = A^\star$ in Theorem 4.4 and apply the attainment half of Theorem 2.5. $\square$

Corollary 4.5 makes the duality explicit: the certificate that no coupling beats $d_{TV}$ is the *optimal event*. Sharpness on the primal side is exactly what supplies the bound on the dual side.

### 4.3 The maximal coupling

Let $t = d_{TV}(p,q)$ and $m(x) = \min(p(x),q(x))$, so $\sum_x m(x) = 1-t$ by (2.1). Define the **leftovers** $p^\sharp(x) = p(x)-m(x)$ and $q^\sharp(y) = q(y)-m(y)$; both are non-negative, both sum to $t$, and crucially
$$p^\sharp(x)\, q^\sharp(x) = 0 \quad\text{for every } x, \tag{4.1}$$
since at each point the minimum is attained by one of the two, killing the corresponding leftover.

**Definition 4.6 (Maximal coupling).**
$$c^\star(x,y) \;=\; m(x)\,\mathbf{1}[x=y] \;+\; \begin{cases}\dfrac{p^\sharp(x)\,q^\sharp(y)}{t}, & t > 0,\\[4pt] 0, & t = 0.\end{cases}$$

**Theorem 4.7 (Maximal coupling is a coupling).** For laws $p, q$, $c^\star \in \Pi(p,q)$.

*Proof sketch.* Non-negativity is clear from $m \ge 0$, $p^\sharp, q^\sharp \ge 0$ and $t>0$ in the nontrivial branch. For the first marginal, when $t>0$,
$$\sum_y c^\star(x,y) = m(x) + \frac{p^\sharp(x)}{t}\sum_y q^\sharp(y) = m(x) + \frac{p^\sharp(x)}{t}\cdot t = m(x)+p^\sharp(x) = p(x),$$
using $\sum_y q^\sharp(y) = t$; the second marginal is symmetric. When $t=0$ Proposition 2.11(ii) gives $p=q$, $m = p$, and $c^\star$ is the diagonal coupling. $\square$

**Theorem 4.8 (The maximal coupling attains $d_{TV}$).** $\ \mathbb{P}_{c^\star}[X\ne Y] = d_{TV}(p,q)$.

*Proof sketch.* By Lemma 4.3 it suffices to compute the diagonal mass. When $t>0$,
$$\sum_x c^\star(x,x) = \sum_x m(x) + \frac{1}{t}\sum_x p^\sharp(x)q^\sharp(x) = (1-t) + 0 = 1-t,$$
the cross term vanishing by the disjoint-support identity (4.1). Hence $\mathbb{P}_{c^\star}[X\ne Y] = 1-(1-t) = t$. When $t = 0$, $p=q$ and the diagonal coupling never disagrees. $\square$

Identity (4.1) is the heart of the construction: it is what makes the "independent pairing of leftovers" contribute nothing to agreement, so that the diagonal mass is exactly the shared mass $1 - t$ and not more.

**Theorem 4.9 (Coupling characterization / Strassen for finite laws).**
$$d_{TV}(p,q) \;=\; \min_{c \in \Pi(p,q)} \mathbb{P}_c[X\ne Y],$$
the minimum being attained at $c^\star$. *(Corollary 4.5 gives the lower bound; Theorems 4.7–4.8 give attainment.)*

**Theorem 4.10 (Minimax identity with explicit witnesses).** For laws $p, q$,
$$\max_{A\subseteq\mathcal{X}}\bigl(p(A)-q(A)\bigr) \;=\; d_{TV}(p,q) \;=\; \min_{c\in\Pi(p,q)} \mathbb{P}_c[X\ne Y],$$
with the maximum attained at $A^\star = \{q \le p\}$ and the minimum at $c^\star$.

Under the $\ell^1$ normalization this identity is not merely uglier but type-incorrect: the middle term would be $\|p-q\|_1$, which can reach $2$, while the right-hand side is a probability.

---

## 5. Hypothesis testing and data processing

### 5.1 The two-point bound

Consider the uniform-prior binary testing problem: nature picks $H \in \{p, q\}$ with probability $\tfrac12$ each, draws $x \sim H$, and the statistician applies a test $f : \mathcal{X}\to\{0,1\}$, declaring "$q$" when $f(x)=1$.

**Definition 5.1 (Average error).** $\displaystyle \mathrm{err}_{p,q}(f) = \tfrac12\Bigl(\,p\bigl(f^{-1}(1)\bigr) + q\bigl(f^{-1}(0)\bigr)\Bigr).$

**Lemma 5.2 (Error is affine in the gap).** With $A = f^{-1}(1)$,
$$\mathrm{err}_{p,q}(f) = \frac{1 + \bigl(p(A)-q(A)\bigr)}{2}.$$
*(Substitute $q(f^{-1}(0)) = 1 - q(A)$.)*

**Theorem 5.3 (Le Cam two-point bound; exact form).** The least average error over all Boolean tests is
$$\min_f \ \mathrm{err}_{p,q}(f) \;=\; \frac{1 - d_{TV}(p,q)}{2},$$
attained by the likelihood-ratio test $f = \mathbf{1}_{\{p \le q\}}$.

*Proof sketch.* By Lemma 5.2 minimizing the error is minimizing $p(A) - q(A) = -\bigl(q(A)-p(A)\bigr)$, i.e. maximizing $q(A)-p(A)$, whose maximum is $d_{TV}(q,p) = d_{TV}(p,q)$ by Theorem 2.5 applied to the swapped pair. $\square$

Corollary: every test satisfies $\mathrm{err}_{p,q}(f) \ge \tfrac12(1 - d_{TV}(p,q))$, a bound in $[0,\tfrac12]$ for all laws. The $\ell^1$-normalized surrogate $\tfrac12(1 - \|p-q\|_1)$ is negative — hence vacuous — as soon as the two laws are more than half apart, which is precisely the regime in which one wants a nontrivial statement.

### 5.2 Data processing

**Definition 5.4 (Stochastic channel and pushforward).** A channel from $\mathcal{X}$ to $\mathcal{Y}$ is $K : \mathcal{X}\times\mathcal{Y}\to\mathbb{R}_{\ge0}$ with $\sum_y K(x,y) = 1$ for all $x$. Its action on a law is $(pK)(y) = \sum_x p(x)K(x,y)$.

**Theorem 5.5 (Data-processing inequality).** For every channel $K$, $\ d_{TV}(pK, qK) \le d_{TV}(p,q)$. In particular, for a deterministic map $T : \mathcal{X}\to\mathcal{Y}$, $\ d_{TV}(T_*p, T_*q) \le d_{TV}(p,q)$.

*Proof sketch.* $\sum_y |(pK)(y)-(qK)(y)| = \sum_y\bigl|\sum_x (p(x)-q(x))K(x,y)\bigr| \le \sum_x |p(x)-q(x)| \sum_y K(x,y) = \sum_x|p(x)-q(x)|$, by the triangle inequality and Fubini; halve. $\square$

Read operationally through Theorem 2.5: no feature map, quantizer, noise injection, or downstream model can create distinguishing advantage that the raw data did not already contain. Read through Theorem 4.9: any coupling of the inputs pushes forward to a coupling of the outputs with no larger disagreement probability.

### 5.3 The naive multi-sample bound

**Definition 5.6 (Product law).** $p^{\otimes n}(v) = \prod_{i=1}^n p(v_i)$ for $v \in \mathcal{X}^n$.

**Theorem 5.7 (Hybrid/subadditivity bound).** $\ d_{TV}(p^{\otimes n}, q^{\otimes n}) \le n\, d_{TV}(p,q)$.

*Proof sketch.* By induction, using the two-factor estimate $d_{TV}(p_1\otimes p_2,\ q_1 \otimes q_2) \le d_{TV}(p_1,q_1)+d_{TV}(p_2,q_2)$, itself proved by inserting the hybrid $p_1 \otimes q_2$ and applying the triangle inequality with the two one-sided computations. $\square$

Combining with Theorem 5.3: after $n$ samples, every test errs with probability at least $\tfrac12(1 - n\,d_{TV}(p,q))$ — nontrivial only for $n < 1/d_{TV}$, and vacuous beyond. §6 fixes this.

---

## 6. Sharp $n$-sample amplification

**Definition 6.1 (Product coupling).** For $c \in \Pi(p,q)$, define $c^{\otimes n}(v,w) = \prod_{i=1}^n c(v_i, w_i)$ on $\mathcal{X}^n\times\mathcal{X}^n$.

**Lemma 6.2.** If $c \in \Pi(p,q)$ then $c^{\otimes n} \in \Pi(p^{\otimes n}, q^{\otimes n})$.

*Proof sketch.* Non-negativity is clear; the marginal computation is the interchange $\sum_{w}\prod_i c(v_i,w_i) = \prod_i \sum_{w_i} c(v_i,w_i) = \prod_i p(v_i)$, i.e. the distributivity of a product of sums over the product index set. $\square$

**Lemma 6.3 (Agreement tensorizes exactly).** $\displaystyle \sum_{v} c^{\otimes n}(v,v) = \Bigl(\sum_x c(x,x)\Bigr)^{\!n}$, by the same interchange.

**Theorem 6.4 (Geometric amplification law).** For laws $p, q$ and every $n \in \mathbb{N}$,
$$d_{TV}\bigl(p^{\otimes n}, q^{\otimes n}\bigr) \;\le\; 1 - \bigl(1 - d_{TV}(p,q)\bigr)^{n}.$$

*Proof sketch.* Apply Lemma 6.2 to the maximal coupling $c^\star$: it is a coupling of the product laws. Its diagonal mass is $\bigl(\sum_x c^\star(x,x)\bigr)^n = (1 - d_{TV}(p,q))^n$ by Lemma 6.3 and the computation in Theorem 4.8. By Lemma 4.3 its disagreement probability is $1 - (1-d_{TV})^n$, and Corollary 4.5 (applied to the product laws) yields the bound. $\square$

**Proposition 6.5 (The geometric law dominates the linear one).** For $t\in[0,1]$ and all $n$, $\ 1-(1-t)^n \le n t$; and for $0 < t < 1$ and $n \ge 2$ the inequality is strict.

*Proof sketch.* Induction on $n$: $1-(1-t)^{n+1} = t + (1-t)\bigl(1-(1-t)^n\bigr) \le t + (1-t)nt \le t + nt$, with strictness entering at the second step as soon as $t(1-t) > 0$ and $n \ge 1$. $\square$

**Corollary 6.6 (Non-vacuity).** $d_{TV}(p^{\otimes n},q^{\otimes n}) \le 1$ for all $n$ — the amplification bound never leaves the range of the quantity it bounds, unlike the linear bound.

**Corollary 6.7 (Sharp sample-complexity floor).** For every test $f : \mathcal{X}^n \to\{0,1\}$,
$$\mathrm{err}_{p^{\otimes n}, q^{\otimes n}}(f) \;\ge\; \frac{\bigl(1 - d_{TV}(p,q)\bigr)^n}{2}.$$

*Proof.* Theorem 5.3 for the product laws plus Theorem 6.4: $\tfrac12(1 - d_{TV}(p^{\otimes n},q^{\otimes n})) \ge \tfrac12 (1-d_{TV})^n$. $\square$

Corollary 6.7 is the statement one actually wants in learning theory. It is never vacuous, it degrades exponentially rather than falling off a cliff, and it exhibits the correct scaling: to drive the error below a constant one needs $n = \Theta(1/d_{TV}(p,q))$ samples, since $(1-t)^n \approx e^{-nt}$.

We stress that Theorem 6.4 is *not* attained in general: the exact $n$-sample distance lies strictly below $1 - (1-d_{TV})^n$ whenever $0 < d_{TV} < 1$ and $n \ge 2$, because the product of maximal couplings is not itself maximal. Closing that gap is discussed in §11.

---

## 7. From divergence control to event control: the Pinsker bridge

Let $\mathrm{KL}(Q\Vert P) = \sum_x Q(x)\log\frac{Q(x)}{P(x)}$ (with the usual conventions, assuming $P(x)=0 \Rightarrow Q(x)=0$). Pinsker's inequality in the sharp normalization reads
$$d_{TV}(Q,P)^2 \;\le\; \tfrac12\,\mathrm{KL}(Q\Vert P), \qquad\text{i.e.}\qquad d_{TV}(Q,P) \le \sqrt{\mathrm{KL}(Q\Vert P)/2}. \tag{7.1}$$

Composed with the characterizations above, (7.1) converts an analytic quantity into operational guarantees.

**Theorem 7.1 (Event-wise and test-wise Pinsker).** Assume $P(x)=0\Rightarrow Q(x)=0$. Then for every event $A$, every Boolean test $f$, and every randomized test $g:\mathcal{X}\to[0,1]$:
$$\bigl|Q(A)-P(A)\bigr| \le \sqrt{\tfrac{1}{2}\mathrm{KL}(Q\Vert P)},\qquad \bigl|\mathbb{E}_Q[g] - \mathbb{E}_P[g]\bigr| \le \sqrt{\tfrac12 \mathrm{KL}(Q\Vert P)}.$$
*(Chain Corollary 2.6 / Theorem 2.8 with (7.1).)*

**Theorem 7.2 (Converse certificate).** For every event $A$, $\ \mathrm{KL}(Q\Vert P) \ge 2\bigl(Q(A)-P(A)\bigr)^2$.

*Proof sketch.* Square Corollary 2.6 and insert into (7.1): $2(Q(A)-P(A))^2 \le 2 d_{TV}^2 \le \mathrm{KL}$. $\square$

Theorem 7.2 is the practically useful direction: a *single* observed separating event certifies a divergence lower bound, with no need to estimate a likelihood ratio.

**Theorem 7.3 (KL-driven testing bounds).** Under the same hypothesis, every Boolean test satisfies
$$\mathrm{err}_{Q,P}(f) \;\ge\; \frac{1 - \sqrt{\mathrm{KL}(Q\Vert P)/2}}{2},$$
and after $n$ i.i.d. samples every test $f : \mathcal{X}^n\to\{0,1\}$ satisfies
$$\mathrm{err}_{Q^{\otimes n},P^{\otimes n}}(f) \;\ge\; \frac{1 - n\sqrt{\mathrm{KL}(Q\Vert P)/2}}{2}.$$

**Theorem 7.4 (KL-driven coupling).** Under the same hypothesis, there exists a coupling $c$ of $Q$ and $P$ with
$$\mathbb{P}_c[X\ne Y] \;\le\; \sqrt{\mathrm{KL}(Q\Vert P)/2}.$$
*(Take $c = c^\star$; Theorem 4.8 plus (7.1).)*

**Remark 7.5 (The factor decides non-vacuity).** Under the $\ell^1$ convention Pinsker reads $\|Q-P\|_1 \le \sqrt{2\,\mathrm{KL}}$, and substituting into Theorem 5.3's surrogate yields the error bound $(1-\sqrt{2\mathrm{KL}})/2$, which is non-positive as soon as $\mathrm{KL}\ge \tfrac12$; the sharp version stays informative until $\mathrm{KL} = 2$. On the interval $\mathrm{KL}\in[\tfrac18,\tfrac12]$ the lossy version is vacuous while the sharp one certifies a strictly positive error floor.

---

## 8. The Shtarkov sum is the multi-hypothesis testing optimum

Let $\{p_\theta\}_{\theta\in\Theta}$ be a family of $m = |\Theta|$ laws on $\mathcal{X}$.

**Definition 8.1 (Shtarkov sum).** $\displaystyle C_S = \sum_{x\in\mathcal{X}} \max_{\theta\in\Theta} p_\theta(x).$

In universal coding, $\log_2 C_S$ is the minimax regret: the number of extra bits an optimal universal code must spend relative to the best source in hindsight.

**Definition 8.2 (Uniform-prior $m$-ary error).** For a decision rule $T : \mathcal{X}\to\Theta$,
$$\mathrm{err}(T) = \frac{1}{m}\sum_{\theta\in\Theta}\ \sum_{x : T(x)\ne\theta} p_\theta(x).$$

**Definition 8.3 (Maximum-likelihood rule).** $T_{\mathrm{ML}}(x) \in \arg\max_\theta p_\theta(x)$ (any fixed tie-breaking).

**Theorem 8.4 (Multi-hypothesis optimum).** The least uniform-prior error over all decision rules is
$$\min_{T} \ \mathrm{err}(T) \;=\; 1 - \frac{C_S}{m},$$
attained by $T_{\mathrm{ML}}$.

*Proof sketch.* Split each inner sum into the whole space minus the fibre where $T(x)=\theta$: since $\sum_x p_\theta(x)=1$,
$$\mathrm{err}(T) = \frac{1}{m}\sum_\theta \Bigl(1 - \sum_{x : T(x)=\theta} p_\theta(x)\Bigr) = 1 - \frac{1}{m}\sum_{x} p_{T(x)}(x).$$
The sum $\sum_x p_{T(x)}(x)$ is maximized pointwise by taking $T(x)$ to be a maximizer of $\theta \mapsto p_\theta(x)$, giving $\sum_x \max_\theta p_\theta(x) = C_S$. $\square$

**Corollary 8.5 (Binary consistency).** For $m=2$ with sources $p, q$: $\max(a,b) = \min(a,b)+|a-b|$ gives $C_S = (1-d_{TV}) + 2d_{TV} = 1 + d_{TV}(p,q)$, hence
$$\min_T \mathrm{err}(T) = 1 - \frac{1+d_{TV}(p,q)}{2} = \frac{1-d_{TV}(p,q)}{2},$$
recovering Theorem 5.3 exactly. The universal-coding price and the statistical testing optimum are the same sum read twice.

**Corollary 8.6 (Rigid endpoints).** $\min_T\mathrm{err}(T) = 0$ iff $C_S = m$ iff the sources are mutually singular (for each $x$, at most one $\theta$ has $p_\theta(x)>0$): perfect identification. If all sources coincide, $C_S = 1$ and the optimum is $1 - 1/m$: pure guessing.

**Theorem 8.7 (Multi-hypothesis Le Cam bound).** Fix a reference index $\theta_0$ and $\varepsilon \ge 0$. If $d_{TV}(p_\theta, p_{\theta_0}) \le \varepsilon/m$ for all $\theta$, then every decision rule satisfies
$$\mathrm{err}(T) \;\ge\; 1 - \frac{1}{m} - \frac{\varepsilon}{m}.$$

*Proof sketch.* Replace each $p_\theta$ by $p_{\theta_0}$ inside the fibre sum of the proof of Theorem 8.4, paying $d_{TV}(p_\theta,p_{\theta_0})$ per hypothesis by the event bound (Corollary 2.6 applied to the fibre $T^{-1}(\theta)$). The reference terms sum to $\frac1m\sum_\theta p_{\theta_0}(T^{-1}(\theta)) = \frac1m$, and the errors accumulate to at most $\frac1m \cdot m\cdot \frac{\varepsilon}{m}$. $\square$

This is the standard "if the hypotheses are indistinguishable, no rule beats guessing" template — and note that it needs the *sharp* event bound: with the lossy constant one would need $d_{TV}(p_\theta,p_{\theta_0}) \le \varepsilon/(2m)$ to draw the same conclusion.

---

## 9. Algorithmic content

Every optimum in this paper is computable in near-linear time in $|\mathcal{X}|$, which is unusual for a minimax value and is a direct consequence of having explicit witnesses.

**Algorithm A (Distance and optimal event).** Given $p, q$ as arrays of length $N = |\mathcal{X}|$: compute $t \leftarrow \tfrac12\sum_x|p(x)-q(x)|$ and $A^\star \leftarrow \{x : q(x)\le p(x)\}$ in a single pass. Cost $\Theta(N)$ time, $\Theta(1)$ extra space. Correctness: Theorem 2.5. The optimal Boolean test and the optimal two-point decision rule are read off immediately, as is the optimal error $(1-t)/2$ from Theorem 5.3.

**Algorithm B (Maximal coupling).** Compute $m(x) = \min(p(x),q(x))$, $p^\sharp = p - m$, $q^\sharp = q - m$, $t = \sum_x p^\sharp(x)$. Return the sparse representation: diagonal weights $m(x)$; plus, if $t>0$, the rank-one block $p^\sharp \otimes q^\sharp / t$ supported on $\mathrm{supp}(p^\sharp)\times\mathrm{supp}(q^\sharp)$. Cost $\Theta(N)$ to build the representation, $\Theta(|\mathrm{supp}(p^\sharp)|\cdot|\mathrm{supp}(q^\sharp)|)$ only if the dense matrix is materialized. Sampling from $c^\star$ costs $\Theta(\log N)$ after $\Theta(N)$ preprocessing: with probability $1-t$ draw $x$ from $m/(1-t)$ and output $(x,x)$; otherwise draw $X\sim p^\sharp/t$ and $Y \sim q^\sharp/t$ independently. Correctness: Theorems 4.7–4.8. This is precisely the sampler used in perfect-simulation and Markov-chain coupling arguments.

**Algorithm C (Exact $n$-sample distance versus the two bounds).** For small $N$ and $n$, enumerate $\mathcal{X}^n$, form $p^{\otimes n}$ and $q^{\otimes n}$, and compute the exact distance by Algorithm A; compare with $1-(1-t)^n$ and $nt$. Cost $\Theta(N^n)$; used to certify the strictness in Proposition 6.5 and to observe the residual slack in Theorem 6.4. A polynomial-time alternative for exchangeable computations aggregates over the multinomial type classes of $\mathcal{X}^n$, reducing the cost to $\Theta\bigl(\binom{n+N-1}{N-1}\bigr)$.

**Algorithm D (Multi-hypothesis optimum).** Given a matrix $(p_\theta(x))$, compute $C_S = \sum_x \max_\theta p_\theta(x)$ and the ML rule in $\Theta(mN)$ time; the optimum is $1 - C_S/m$ by Theorem 8.4.

---

## 10. Applications

**Learning-theoretic lower bounds.** The standard two-point method — to prove that no estimator achieves accuracy $\alpha$ with $n$ samples, exhibit hypotheses $p, q$ that are $\alpha$-separated in the parameter yet close in distribution — requires an *exact* relation between distance and error. Theorem 5.3 supplies it, and Corollary 6.7 supplies the $n$-sample version with the correct exponential (rather than linear, then vacuous) decay.

**Distribution shift.** Theorem 2.9 says that if deployment data sits within $\varepsilon$ of training data in total variation, then every $[0,1]$-valued metric — accuracy, AUC computed against a fixed scorer, calibration error, any bounded loss — shifts by at most $\varepsilon$. The constant is attained, so this is the exact worst case, not a conservative estimate.

**Differential privacy and indistinguishability.** Cryptographic and privacy definitions are stated as: no adversary distinguishes the two worlds with advantage more than $\varepsilon$. Theorem 2.5 says that this is *equivalent* to $d_{TV} \le \varepsilon$ — quantifying over all adversaries, computational or not, deterministic or randomized (Theorem 2.8). The data-processing inequality (Theorem 5.5) then gives post-processing invariance for free, and the amplification law (Theorem 6.4) gives the exact degradation under $n$ repeated releases: advantage at most $1-(1-\varepsilon)^n \approx n\varepsilon$ for small $n\varepsilon$, but never exceeding $1$.

**Simulation and Markov chains.** The maximal coupling is the standard tool for mixing-time upper bounds: build a coupling of a chain with its stationary law, and the coupling time bounds the distance to stationarity. Theorem 4.9 is the reason the method is not lossy in principle — a *best* coupling always exists and achieves the true distance.

**Generative model evaluation.** Theorem 7.1 converts a divergence estimate — the quantity that variational training actually optimizes — into a statement about the best possible discriminator: if the KL is at most $\kappa$, no test, however trained, separates the model from the truth with advantage exceeding $\sqrt{\kappa/2}$. Theorem 7.2 provides the converse audit: a discriminator observed to achieve gap $\gamma$ certifies $\mathrm{KL}\ge 2\gamma^2$.

**Universal compression.** Corollary 8.5 gives an interpretation of minimax regret that is not about bits at all: the compression price $C_S$ over $m$ candidate sources is $m$ times the identifiability of the family, $\ C_S/m = 1 - \min_T\mathrm{err}(T)$.

---

## 11. Discussion and future directions

### 11.1 What the sharp normalization bought

Three observations summarize the development. First, the factor $\tfrac12$ is the unique normalization under which total variation *is* a probability — of distinguishing (Theorem 2.5) and of disagreement (Theorem 4.9) — and the two readings are dual, with the optimal event serving as the certificate for the coupling bound. Second, every downstream constant inherits the sharpness: the two-point optimum, the oscillation modulus, the Pinsker bridge, the multi-hypothesis Le Cam bound. Third, the $\ell^1$ normalization is not wrong but *coarser*: it is the exact answer for signed tests (Theorem 3.3), and the gap between the two questions is an affine change of coordinates that mass conservation renders invisible (Lemma 3.4).

### 11.2 Residual gaps

Three gaps remain open in the development above, and they organize the future work.

1. **The minimax identity was proved constructively, not by duality.** Theorems 2.5 and 4.9 are, respectively, a primal witness and a dual witness for one linear program over the transport polytope. The equality of the two optima was established by exhibiting both, not by invoking duality — so the underlying finite-dimensional minimax theorem is not yet part of the development.
2. **Geometric amplification is not tight.** The exact $d_{TV}(p^{\otimes n},q^{\otimes n})$ lies strictly below $1-(1-d_{TV})^n$ whenever $0 < d_{TV} < 1$: the coupling bound loses information because the product of maximal couplings need not be maximal.
3. **Pinsker is the only divergence bridge present.** The bound $\sqrt{\mathrm{KL}/2}$ is lossy near $\mathrm{KL}\approx 1$ and becomes vacuous for $\mathrm{KL} > 2$, whereas the Bretagnolle–Huber bound $d_{TV}\le\sqrt{1-e^{-\mathrm{KL}}}$ stays informative for all $\mathrm{KL}$.

### 11.3 Conjecture 1 — exact Hellinger amplification law

Let the **Hellinger affinity** be $\rho(p,q) = \sum_x\sqrt{p(x)q(x)}$.

**Conjecture.** For finite laws $p,q$,
$$1 - \rho(p,q)^n \;\le\; d_{TV}\bigl(p^{\otimes n},q^{\otimes n}\bigr) \;\le\; \sqrt{1 - \rho(p,q)^{2n}},$$
and both bounds are strictly sharper than $1-(1-d_{TV}(p,q))^n$ whenever $0 < d_{TV}(p,q) < 1$.

The key insight is that the affinity, unlike total variation, is *exactly* multiplicative over products, $\rho(p^{\otimes n},q^{\otimes n}) = \rho(p,q)^n$, so it is the natural carrier of tensorization, while $d_{TV}$ is the natural carrier of testing; the two are linked by the Le Cam sandwich $1-\rho \le d_{TV}\le\sqrt{1-\rho^2}$. Structurally the ingredients are already present: the shared-mass functional $\sum_x\min(p(x),q(x)) = 1-d_{TV}$ becomes the affinity when $\min$ is replaced by the geometric mean, and the multiplicativity proof reuses the same product-of-sums interchange that carried Lemma 6.3.

### 11.4 Conjecture 2 — linear-programming proof of the minimax identity

**Conjecture.** The identity $\max_A(p(A)-q(A)) = \min_{c\in\Pi(p,q)}\mathbb{P}_c[X\ne Y]$ is an instance of finite linear-programming duality, and the equality can be established *without* constructing the maximal coupling: the vertices of the transport polytope are the extreme couplings, and complementary slackness identifies the likelihood-ratio event as the active constraint.

The key insight is that the maximal coupling is not a lucky formula but the unique dual optimum whose support is forced by complementary slackness against the indicator of $\{q\le p\}$: the diagonal is where the primal constraint is tight, and the rank-one leftover block is exactly the residual flow that the slack constraints permit.

### 11.5 Further directions

* **Bretagnolle–Huber bridge.** Add $d_{TV}\le\sqrt{1-e^{-\mathrm{KL}}}$ alongside Pinsker; it dominates $\sqrt{\mathrm{KL}/2}$ for large divergence and never goes vacuous, which matters for multi-sample arguments where the divergence scales with $n$.
* **Exact product distance.** Characterize $d_{TV}(p^{\otimes n},q^{\otimes n})$ via type classes: for a fixed alphabet the exact distance is a sum over multinomial types, and its asymptotics are governed by a Chernoff exponent — quantifying exactly how much Theorem 6.4 loses.
* **Beyond uniform priors.** Theorems 5.3 and 8.4 assume a uniform prior; for general priors $\pi$ the optimum becomes $1 - \sum_x\max_\theta \pi(\theta)p_\theta(x)$, a weighted Shtarkov sum whose coding interpretation deserves the same treatment.
* **Continuous state spaces.** All arguments here are finite and combinatorial. The event supremum and the coupling infimum are both classical in the general measurable setting (the latter being Strassen's theorem), but the *constructive* route taken here — explicit optimal event, explicit maximal coupling built from the Lebesgue decomposition — carries over verbatim and would make the general statement equally witness-bearing.
* **Approximate couplings and privacy.** Relaxing the marginal constraints to $\varepsilon$-approximate marginals yields a family of interpolating distances whose testing interpretation is the natural quantitative version of $(\varepsilon,\delta)$-indistinguishability.

---

## 12. Summary of results

| # | Statement | Content |
|---|---|---|
| 2.5 | Event supremum | $d_{TV} = \max_A (p(A)-q(A))$, attained at $\{q\le p\}$ |
| 2.8 | Randomization useless | soft advantage $\le d_{TV}$, attained at an indicator |
| 2.9 | Sharp oscillation bound | $|\mathbb{E}_p g - \mathbb{E}_q g| \le (M-m)d_{TV}$, sharp |
| 2.10 | Strict lossiness | $d_{TV} < \|p-q\|_1$ whenever $p\ne q$ |
| 2.11 | Rigid endpoints | $d_{TV}\in[0,1]$; $=0$ iff equal; $=1$ iff singular |
| 3.3 | Factor-two dichotomy | $[0,1]$-tests give $d_{TV}$, $[-1,1]$-tests give $2d_{TV}$ |
| 4.4–4.5 | Coupling bound | every coupling disagrees with probability $\ge d_{TV}$ |
| 4.7–4.8 | Maximal coupling | explicit optimal coupling, disagreement $=d_{TV}$ |
| 4.10 | Minimax identity | $\max_A \Delta = d_{TV} = \min_c \mathbb{P}[X\ne Y]$ |
| 5.3 | Two-point optimum | least average error $=(1-d_{TV})/2$ |
| 5.5 | Data processing | channels cannot increase $d_{TV}$ |
| 6.4 | Geometric amplification | $d_{TV}(p^{\otimes n},q^{\otimes n})\le 1-(1-d_{TV})^n$ |
| 6.7 | Sample-complexity floor | error $\ge \tfrac12(1-d_{TV})^n$ after $n$ samples |
| 7.1–7.4 | Pinsker bridge | event/test/coupling forms and the converse certificate |
| 8.4 | Multi-hypothesis optimum | least $m$-ary error $=1-C_S/m$, via maximum likelihood |
| 8.7 | Multi-hypothesis Le Cam | error $\ge 1 - 1/m - \varepsilon/m$ for $\varepsilon/m$-close sources |
