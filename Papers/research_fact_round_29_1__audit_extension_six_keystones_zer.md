# Structural Reproducibility: An Arithmetic Theory of Audited Pipeline Statistics

**Author:** Aristotle
**Date:** 2026-09-23

---

## Abstract

Computational research increasingly relies on *reproducibility audits*: a seeded,
deterministic pipeline is re-executed from stored seeds and the freshly produced
table of statistics is compared, digit for digit, with the recorded one. Agreement
is reported as "zero drift." We argue that this practice conflates two very
different notions — *executional* reproducibility, a property of two runs, and
*structural* reproducibility, a property of the model — and we develop an
arithmetic theory that separates them.

Working with a concrete model of a seeded pipeline (the linear congruential map
$x \mapsto (ax+c) \bmod m$ and, more generally, an arbitrary endofunction with a
finite state window), we prove that four families of routinely audited statistics
are theorems rather than measurements, and therefore cannot drift under any
re-execution. These are: (i) *rebatching invariance* of the terminal state; (ii)
*capacity saturation* with a nondecreasing, divergent deficit column; (iii) the
*synergy decomposition* of two periodic channels, with nonnegative synergy and
overlap coefficient in $[0,1]$; and (iv) the exactness of the clipped *ramp law*
for lexicographic grid enumeration.

We then strengthen each into a quantitative statement. We prove an **exact
orbit-count law**: for *any* deterministic pipeline whose orbit lies in a window of
size $m$ there is a single integer $N \le m$ with $|S_k| = \min(k+1, N)$ for every
$k$ — no periodicity hypothesis is needed, finiteness alone forces the shape. This
yields a **deficit slope detector**: consecutive deficits differ by exactly one bit
if and only if the orbit is already exhausted, so the orbit size is recoverable
from the published deficit column alone. We prove a **rebatching
characterisation**: on an arbitrary state type, a schedule-executing process is
batch invariant if and only if it is the iterate of its unit step; hence batch
sensitivity is a complete certificate of hidden state. We derive the **closed form
for synergy**, $S(p,q) = \log_2\bigl(\min(p,q)/\gcd(p,q)\bigr)$, and deduce a
**one-bit quantisation gap**: non-nested integer channels have $S \ge 1$, with
equality exactly when $\min(p,q) = 2\gcd(p,q)$.

The quantisation gap has an adversarial consequence. Audited synergy values
reported at $+0.1290$ and $+0.0049$ bits lie in a region that the model provably
cannot reach. Perfect executional reproducibility is therefore compatible with a
statistic that cannot bear its stated interpretation — a failure mode that
re-execution is structurally unable to detect, and that the theory detects
immediately.

**Keywords:** reproducibility, deterministic pipelines, linear congruential maps,
orbit counting, capacity saturation, synergy decomposition, lcm–gcd inclusion–exclusion,
quantisation gap.

---

## 1. Introduction

### 1.1 Two meanings of "reproducible"

When a computational programme reports that its keystone results "reproduce
exactly under stored seeds," it is asserting something specific: that a second
execution of a deterministic pipeline, initialised identically, produced an
identical table. Call this **executional reproducibility**. It is falsifiable, it
is cheap to test, and it catches real problems — unseeded randomness, dependence
on thread scheduling, accumulated floating-point drift, environment leakage.

It is also, by construction, an existential statement about a finite sample of
runs. It cannot distinguish between a number that is stable *because the
underlying mathematics admits no alternative* and a number that is stable *because
the same computation was performed twice.* Call the former **structural
reproducibility**. A structurally reproducible statistic is a theorem about the
model; it is invariant not merely across executions but across implementations,
languages, hardware, and reasonable perturbations of the code.

The distinction is practically consequential in both directions:

* A statistic that is structurally reproducible does not need auditing, and
  auditing it wastes the audit's credibility on a foregone conclusion. If the
  deficit column *must* be nondecreasing, observing that it is nondecreasing
  twice is not evidence of anything.
* A statistic that is executionally reproducible may nonetheless be *impossible*
  under the model it is said to instantiate. Determinism guarantees that a
  misinterpretation reproduces perfectly. Only the model can catch this.

### 1.2 The audited statistics

The audit motivating this work reports four kinds of quantity:

1. **Zero drift.** A terminal state, or a table of states, produced by a seeded
   pipeline, claimed to be independent of how the run was chopped into batches.
2. **A capacity curve and deficit column.** The number of distinct states visited
   by time $k$, reported in bits as $I(k) = \log_2|S_k|$, together with the
   deficits $d(k) = k - I(k)$ recorded as running from $+0.000$ to $+6.372$ and
   $I(6) = 11.5307$.
3. **A synergy decomposition.** For two channels, the excess capacity of the joint
   channel over the better marginal, reported as $+0.1290$ for one pair and
   $+0.0049$ for another, with an overlap coefficient of $0.9919$.
4. **A ramp law.** A success fraction $P_1$ reported as approximately
   $\operatorname{ramp}(q/r^2)$.

We give each a precise arithmetic model, prove the qualitative claim, and then
push to the exact quantitative statement.

### 1.3 Contributions and organisation

Section 2 fixes the pipeline model. Section 3 proves rebatching invariance and its
converse characterisation. Section 4 develops capacity and the deficit column and
proves saturation. Section 5 proves the exact orbit-count law and the deficit slope
detector, and specialises to the full-period rotation, obtaining the extremal
envelope. Section 6 develops the synergy calculus and proves the closed form and
the one-bit gap. Section 7 proves the exactness of the ramp law. Section 8
assembles the audit bundle. Section 9 discusses the adversarial finding and the
methodological consequences. Section 10 lists open directions.

---

## 2. The pipeline model

### 2.1 States, steps, runs

**Definition 2.1 (Congruential step).** Fix natural numbers $a, c, m$. The *step
map* is
$$\sigma_{a,c,m}(x) \;=\; (a x + c) \bmod m .$$

**Definition 2.2 (Run).** The *run* of $n$ steps from seed $s$ is defined by
$R_0(s) = s$ and $R_{n+1}(s) = R_n(\sigma(s))$, where we suppress the parameters
$a,c,m$ when they are clear. Equivalently, $R_n = \sigma^{\,n}$, the $n$-fold
composite.

**Lemma 2.3 (Window confinement).** If $m > 0$ and $s < m$, then $R_n(s) < m$ for
every $n$.

*Proof.* Induction on $n$: the base case is the hypothesis, and the step case uses
that $\sigma(x) = (ax+c) \bmod m < m$ whenever $m > 0$. $\square$

**Definition 2.4 (Batched execution).** For a schedule $L = [n_1, \dots, n_r]$ of
batch sizes, the *batched execution* is
$$E(L, s) \;=\; R_{n_r}\bigl(\cdots R_{n_2}(R_{n_1}(s))\cdots\bigr),$$
i.e. the left fold of the run operation over $L$, with $E([\,], s) = s$.

### 2.2 The visited set

**Definition 2.5 (Visited set).** $S_k = S_k(a,c,m,s) = \{\,R_i(s) : 0 \le i \le k\,\}$,
a finite set of naturals.

Immediately: $S_0 = \{s\}$, so $|S_k| \ge 1$; $S_k \subseteq S_{k+1}$; and
$S_{k+1} = S_k \cup \{R_{k+1}(s)\}$, so $|S_{k+1}| \le |S_k| + 1$. If $m > 0$ and
$s < m$ then $S_k \subseteq \{0,\dots,m-1\}$ by Lemma 2.3, so $|S_k| \le m$.

---

## 3. Keystone R: rebatching invariance and its converse

### 3.1 The forward direction

**Theorem 3.1 (Additivity of runs).** For all $p, q, s$,
$$R_{p+q}(s) \;=\; R_q\bigl(R_p(s)\bigr).$$

*Proof.* Induct on $p$, generalising the seed $s$. For $p = 0$ both sides are
$R_q(s)$. For the step, $R_{(p+1)+q}(s) = R_{p+q}(\sigma(s)) = R_q(R_p(\sigma(s)))
= R_q(R_{p+1}(s))$, using the definition of $R$ on the left and the inductive
hypothesis at seed $\sigma(s)$ in the middle. $\square$

**Theorem 3.2 (Batched execution collapses).** For every schedule $L$ and seed $s$,
$$E(L, s) \;=\; R_{\lVert L\rVert}(s), \qquad \lVert L\rVert := n_1 + \cdots + n_r .$$

*Proof.* Induct on $L$. For $L = [\,]$ both sides are $s$. For $L = n :: L'$,
$E(n::L', s) = E(L', R_n(s)) = R_{\lVert L'\rVert}(R_n(s)) = R_{n + \lVert L'\rVert}(s)$
by the inductive hypothesis and Theorem 3.1. $\square$

**Corollary 3.3 (Zero drift).** If $\lVert L \rVert = \lVert L' \rVert$ then
$E(L,s) = E(L',s)$ for every seed $s$ and all parameters $a,c,m$.

The terminal state is therefore a function of the seed and the total step count
alone. It cannot be perturbed by checkpointing, restarting, distributing, or
re-chunking the run. This is *structural* reproducibility in the purest form: no
execution could produce a counterexample, so no audit can supply evidence for it.

### 3.2 The converse: batch sensitivity certifies hidden state

The forward direction is a property of one particular pipeline. The interesting
question is whether batch invariance, observed of a black box, *implies* anything.
It does, on an arbitrary state type and with no arithmetic assumptions at all.

**Definition 3.4 (Schedule-executing process).** Let $S$ be any type. A map
$F : \mathrm{List}\,\mathbb{N} \to S \to S$ is a *schedule-executing process* if

* (empty) $F([\,], s) = s$ for all $s \in S$;
* (cons) $F(n :: L, s) = F(L,\, F([n], s))$ for all $n, L, s$.

Batched execution $E$ satisfies both by definition. Write $\phi := F([1], \cdot)$
for the *unit step* of $F$.

**Lemma 3.5 (Unit schedules iterate).** For every $n$ and $s$,
$F(\underbrace{[1,1,\dots,1]}_{n}, s) = \phi^{\,n}(s)$.

*Proof.* Induct on $n$, generalising $s$; the base case is (empty) and the step
case is (cons) followed by the inductive hypothesis. $\square$

**Theorem 3.6 (Rebatching Characterisation).** A schedule-executing process $F$
satisfies
$$\lVert L\rVert = \lVert L'\rVert \implies F(L,s) = F(L',s) \quad \text{for all } L, L', s$$
**if and only if**
$$F(L, s) = \phi^{\,\lVert L\rVert}(s) \quad \text{for all } L, s .$$

*Proof.* ($\Leftarrow$) Immediate: both sides depend on $L$ only through
$\lVert L\rVert$.

($\Rightarrow$) The schedule $[1,1,\dots,1]$ of length $\lVert L\rVert$ has total
$\lVert L\rVert$, so batch invariance gives
$F(L,s) = F([1,\dots,1], s)$, which is $\phi^{\lVert L\rVert}(s)$ by Lemma 3.5. $\square$

**Corollary 3.7 (Batch sensitivity certifies hidden state).** If there exist
schedules $L, L'$ with $\lVert L\rVert = \lVert L'\rVert$ and a seed $s$ with
$F(L,s) \ne F(L',s)$, then $F$ is not the iterate of any unit step; in particular
no visible step map on $S$ explains the process.

This upgrades a familiar engineering heuristic into a theorem, and — importantly —
into a *complete* one. The absence of hidden state is not merely suggested by batch
invariance; it is equivalent to it. A chunking experiment is a decision procedure.

**Proposition 3.8 (The congruential pipeline satisfies the criterion).**
$E(L,s) = \sigma^{\lVert L\rVert}(s)$, and Corollary 3.3 is an instance of
Theorem 3.6.

*Proof.* $E(L,s) = R_{\lVert L\rVert}(s)$ by Theorem 3.2, and $R_n = \sigma^n$ by
induction; the unit step of $E$ is $E([1],\cdot) = \sigma$. $\square$

---

## 4. Keystone C: capacity and the saturating deficit

**Definition 4.1 (Capacity, deficit).**
$$I(k) \;=\; \log_2 |S_k| \ \text{ bits}, \qquad d(k) \;=\; k - I(k).$$

**Proposition 4.2 (Nonnegativity and monotonicity).** $I(k) \ge 0$, and $I$ is
nondecreasing in $k$.

*Proof.* $|S_k| \ge 1$ gives $I(k) \ge 0$; $S_k \subseteq S_l$ for $k \le l$ gives
$|S_k| \le |S_l|$, and $\log_2$ is monotone on the positive reals. $\square$

**Theorem 4.3 (Saturation ceiling).** If $m > 0$ and $s < m$ then
$I(k) \le \log_2 m$ for every $k$.

*Proof.* $|S_k| \le m$ by Lemma 2.3 and monotonicity of $\log_2$. $\square$

**Theorem 4.4 (One bit per step).** $I(k+1) \le I(k) + 1$.

*Proof.* Write $A = |S_k| \ge 1$. Since $S_{k+1} = S_k \cup \{R_{k+1}(s)\}$ we have
$|S_{k+1}| \le A + 1 \le 2A$ (using $A \ge 1$). Taking $\log_2$ and using
$\log_2(2A) = 1 + \log_2 A$ gives the claim. $\square$

**Theorem 4.5 (The deficit column).** Under $m > 0$, $s < m$:
1. $d(0) = 0$;
2. $d$ is nondecreasing;
3. $d(k) \to +\infty$ as $k \to \infty$.

*Proof.* (1) $|S_0| = 1$, so $I(0) = 0$ and $d(0) = 0 - 0 = 0$. (2) By Theorem 4.4,
$d(k+1) - d(k) = 1 - (I(k+1) - I(k)) \ge 0$; chain along $k \le l$. (3) By Theorem
4.3, $d(k) \ge k - \log_2 m$, whose right-hand side diverges. $\square$

Thus the reported profile — a deficit column beginning at exactly $+0.000$, never
decreasing, and climbing without bound as the capacity flattens — is forced by the
model. It carries no information about the particular execution.

---

## 5. The exact orbit-count law and the deficit slope detector

Section 4 constrains the *shape* of the capacity curve. An audit records *numbers*.
We now show the numbers are forced too, and by a single integer.

### 5.1 The general law

Let $f : \mathbb{N} \to \mathbb{N}$ be any function and $s$ any seed. Write
$\mathcal{O}_k = \{\, f^{\,i}(s) : 0 \le i \le k \,\}$ for the orbit prefix.

**Lemma 5.1 (Stalling is permanent).** If $\mathcal{O}_{k+1} = \mathcal{O}_k$, then
$\mathcal{O}_{k+2} = \mathcal{O}_{k+1}$.

*Proof.* From $\mathcal{O}_{k+1} = \mathcal{O}_k$ we get $f^{k+1}(s) \in \mathcal{O}_k$,
say $f^{k+1}(s) = f^{\,i}(s)$ with $i \le k$. Applying $f$ once,
$f^{k+2}(s) = f^{\,i+1}(s)$ with $i+1 \le k+1$, so $f^{k+2}(s) \in \mathcal{O}_{k+1}$
and adjoining it changes nothing. $\square$

**Corollary 5.2.** If $\mathcal{O}_{K+1} = \mathcal{O}_K$ then $\mathcal{O}_k = \mathcal{O}_K$
for all $k \ge K$.

*Proof.* Induction on $k - K$ using Lemma 5.1. $\square$

**Lemma 5.3 (Strict growth is by one).** If $\mathcal{O}_{k+1} \ne \mathcal{O}_k$, then
$|\mathcal{O}_{k+1}| = |\mathcal{O}_k| + 1$.

*Proof.* $\mathcal{O}_{k+1} = \mathcal{O}_k \cup \{f^{k+1}(s)\}$; the new element is not
already present, else the sets would coincide. $\square$

**Lemma 5.4 (Finiteness forces a stall).** If $f^{\,i}(s) < m$ for every $i$, then
there is some $k$ with $\mathcal{O}_{k+1} = \mathcal{O}_k$.

*Proof.* Otherwise Lemma 5.3 gives $|\mathcal{O}_k| = k+1$ for every $k$, by induction;
taking $k = m$ contradicts $\mathcal{O}_m \subseteq \{0,\dots,m-1\}$, which forces
$|\mathcal{O}_m| \le m$. $\square$

**Theorem 5.5 (Exact Orbit-Count Law).** Let $f : \mathbb{N} \to \mathbb{N}$ and $s$
satisfy $f^{\,i}(s) < m$ for all $i$. Then there is an integer $N$ with
$1 \le N \le m$ such that
$$|\mathcal{O}_k| \;=\; \min(k+1,\, N) \qquad \text{for every } k \ge 0 .$$

*Proof.* Let $K$ be least with $\mathcal{O}_{K+1} = \mathcal{O}_K$, which exists by Lemma
5.4. By minimality and Lemma 5.3, $|\mathcal{O}_k| = k+1$ for all $k \le K$. Set
$N = K+1$; then $N \ge 1$, and $N = |\mathcal{O}_K| \le m$ since
$\mathcal{O}_K \subseteq \{0,\dots,m-1\}$. For $k \le K$, $\min(k+1,N) = k+1 =
|\mathcal{O}_k|$. For $k \ge K$, Corollary 5.2 gives $|\mathcal{O}_k| = |\mathcal{O}_K| = N
= \min(k+1, N)$. $\square$

No periodicity, linearity, or algebraic structure is assumed. Finiteness alone
determines the entire count sequence up to one integer. Since $R_n = \sigma^n$, the
congruential pipeline is a special case:

**Corollary 5.6.** For any $a, c, m > 0$ and $s < m$ there is $N$ with $1 \le N \le m$
and $|S_k| = \min(k+1, N)$ for all $k$.

### 5.2 The detector

**Theorem 5.7 (Deficit Slope Detector).** Suppose $|S_k| = \min(k+1, N)$ for all $k$.
Then for every $k$:
$$d(k+1) - d(k) = 1 \iff N \le k+1 .$$
Moreover, when $k + 2 \le N$, $d(k+1) - d(k) < 1$ strictly.

*Proof.* If $N \le k+1$ then also $N \le k+2$, so $|S_k| = |S_{k+1}| = N$, whence
$I(k+1) = I(k)$ and $d(k+1) - d(k) = 1$. If $k+2 \le N$ then $|S_k| = k+1$ and
$|S_{k+1}| = k+2$, so
$$d(k+1) - d(k) = 1 - \log_2\frac{k+2}{k+1} < 1$$
because $\log_2\frac{k+2}{k+1} > 0$. The two cases are exhaustive and exclusive,
giving the biconditional. $\square$

**Corollary 5.8 (Orbit size is observable).** The orbit size $N$ equals the least
$k+1$ for which $d(k+1) - d(k) = 1$. It is therefore recoverable from the published
deficit column alone, with no access to the pipeline's internals.

This is a genuine audit tool. It also constrains what a *valid* deficit column can
look like: unit jumps must form a terminal segment. A published column exhibiting a
unit jump followed later by a sub-unit jump is inconsistent with any deterministic
finite-state pipeline.

### 5.3 The full-period rotation and the extremal envelope

**Theorem 5.9 (Rotation dynamics).** For $a = c = 1$ and $m > 0$, $s < m$:
$R_n(s) = (s + n) \bmod m$.

*Proof.* Induction on $n$: the base case is $s \bmod m = s$, and the step uses
$\sigma(s) = (s+1) \bmod m$ together with $((s+1) \bmod m + n) \bmod m = (s+1+n) \bmod m$. $\square$

**Theorem 5.10 (Exact rotation orbit count).** Under the same hypotheses,
$|S_k| = \min(k+1, m)$.

*Proof.* $S_k$ is the image of $\{0,\dots,k\}$ under $i \mapsto (s+i) \bmod m$. If
$k+1 \le m$ the map is injective on that range (equal residues force $i \equiv j
\pmod m$, and both lie below $m$), so the image has $k+1$ elements. If $m \le k+1$
the image is all of $\{0,\dots,m-1\}$: it is contained there, and conversely any
$x < m$ is hit by $i = (x + m - s) \bmod m \le k$. $\square$

**Corollary 5.11 (The exact curve).** For the rotation pipeline,
$$I(k) = \log_2 \min(k+1, m), \qquad d(k) = k - \log_2\min(k+1,m).$$
The entire capacity column is a function of the single parameter $m$.

**Corollary 5.12 (Unit slope after saturation).** If $m \le k+1$ then
$d(k+1) - d(k) = 1$ exactly.

**Corollary 5.13 (Strict ramping before saturation).** If $1 \le k$ and $k + 2 \le m$
then $d(k) < d(k+1)$ strictly.

*Proof.* $d(k+1) - d(k) = 1 - \log_2\frac{k+2}{k+1}$, and $\frac{k+2}{k+1} < 2$ for
$k \ge 1$, so the logarithm is $< 1$. $\square$

**Theorem 5.14 (Capacity envelope).** For *every* congruential pipeline on modulus
$m$ with $s < m$ and every $k$,
$$I_{a,c}(k) \;\le\; \log_2\min(k+1,\, m),$$
with equality for $a = c = 1$.

*Proof.* $|S_k| \le k+1$ (it is the image of a $(k+1)$-element set) and $|S_k| \le m$
(Lemma 2.3), so $|S_k| \le \min(k+1,m)$; apply $\log_2$. Equality is Theorem 5.10. $\square$

**Corollary 5.15 (Deficit envelope).** Dually, $d_{1,1}(k) \le d_{a,c}(k)$ for every
$a, c$: the full-period rotation has the smallest possible deficit at every time.

---

## 6. Keystone S: the synergy calculus of two periodic channels

### 6.1 The joint channel

**Definition 6.1.** For periods $p, q \ge 1$, observing both channels for $k$ ticks
produces the configuration set
$$J_k(p,q) \;=\; \{\,(i \bmod p,\; i \bmod q)\;:\; 0 \le i < k\,\}.$$

**Theorem 6.2 (Joint orbit size).** $|J_{\operatorname{lcm}(p,q)}(p,q)| = \operatorname{lcm}(p,q)$.

*Proof.* It suffices that $i \mapsto (i \bmod p, i \bmod q)$ is injective on
$\{0,\dots,\operatorname{lcm}(p,q)-1\}$. If two indices $i \le j$ in that range have
the same image, then $p \mid j-i$ and $q \mid j-i$, so $\operatorname{lcm}(p,q) \mid j-i$;
but $0 \le j - i < \operatorname{lcm}(p,q)$, forcing $j = i$. $\square$

**Definition 6.3 (Channel capacity).** $I(n) = \log_2 n$ for $n \ge 1$.

**Theorem 6.4 (Inclusion–exclusion for capacity).** For $p, q \ge 1$,
$$I(\operatorname{lcm}(p,q)) + I(\gcd(p,q)) \;=\; I(p) + I(q).$$

*Proof.* Take $\log_2$ of $\gcd(p,q)\cdot\operatorname{lcm}(p,q) = pq$ and split the
logarithm of each product; all four arguments are positive. $\square$

The joint channel behaves exactly like a union of information sources under
inclusion–exclusion, with $\operatorname{lcm}$ playing the role of join and $\gcd$ the
role of meet.

### 6.2 Synergy and overlap

**Definition 6.5.** For $p, q \ge 1$,
$$S(p,q) \;=\; I(\operatorname{lcm}(p,q)) - \max\bigl(I(p), I(q)\bigr), \qquad
\Omega(p,q) \;=\; \frac{I(\gcd(p,q))}{\min\bigl(I(p), I(q)\bigr)} .$$

**Theorem 6.6 (Synergy is nonnegative).** $S(p,q) \ge 0$.

*Proof.* Both $p$ and $q$ divide $\operatorname{lcm}(p,q)$, hence are $\le$ it; $\log_2$
is monotone, so $\max(I(p),I(q)) \le I(\operatorname{lcm}(p,q))$. $\square$

**Theorem 6.7 (Vanishing synergy is nesting).** $S(p,q) = 0$ iff $p \mid q$ or $q \mid p$.

*Proof.* Since $\log_2$ is strictly monotone on positives, $\max(I(p),I(q)) = I(\max(p,q))$,
and $S(p,q) = 0$ iff $\operatorname{lcm}(p,q) = \max(p,q)$. The lcm always dominates the
max; equality holds iff the max is a common multiple, i.e. iff the min divides the
max. $\square$

**Theorem 6.8 (Overlap lies in $[0,1]$).** For $p,q \ge 2$, $0 \le \Omega(p,q) \le 1$.

*Proof.* $\gcd(p,q) \ge 1$ gives $I(\gcd) \ge 0$; $p,q \ge 2$ give $I(p), I(q) > 0$, so
the denominator is positive, whence $\Omega \ge 0$. And $\gcd(p,q)$ divides — hence is
at most — both $p$ and $q$, so $I(\gcd) \le \min(I(p),I(q))$, giving $\Omega \le 1$. $\square$

### 6.3 Closed form and the one-bit gap

**Lemma 6.9 (Order-theoretic twin).** $I(\max(p,q)) + I(\min(p,q)) = I(p) + I(q)$.

*Proof.* $\max(p,q)\cdot\min(p,q) = pq$; take logarithms. $\square$

**Theorem 6.10 (Closed form for synergy).** For $p, q \ge 1$,
$$S(p,q) \;=\; I(\min(p,q)) - I(\gcd(p,q)) \;=\; \log_2\frac{\min(p,q)}{\gcd(p,q)} .$$

*Proof.* Using $\max(I(p),I(q)) = I(\max(p,q))$,
$$S = I(\operatorname{lcm}) - I(\max) = \bigl(I(p)+I(q)-I(\gcd)\bigr) - \bigl(I(p)+I(q)-I(\min)\bigr)
= I(\min) - I(\gcd),$$
by Theorem 6.4 and Lemma 6.9. $\square$

This makes the entire synergy calculus transparent: synergy measures exactly the
number of bits by which the weaker period exceeds the shared period. It also
immediately yields the key structural fact.

**Theorem 6.11 (One-bit quantisation gap).** If $p, q \ge 1$ and neither divides the
other, then
$$S(p,q) \;\ge\; 1 .$$
Hence $S(p,q) \in \{0\} \cup [1,\infty)$ always: no synergy strictly between zero and
one bit is attainable.

*Proof.* Let $g = \gcd(p,q)$ and $\mu = \min(p,q)$. Then $g \mid \mu$, say $\mu = tg$.
If $t = 1$ then $g = \mu$, so $\mu$ divides both $p$ and $q$, i.e. the min divides the
max — the nested case, excluded. If $t = 0$ then $\mu = 0$, excluded. Hence $t \ge 2$,
so $\mu \ge 2g$ and
$$S(p,q) = \log_2\frac{\mu}{g} \ge \log_2 2 = 1 . \qquad \square$$

**Theorem 6.12 (When the gap is attained).** $S(p,q) = 1$ if and only if
$\min(p,q) = 2\gcd(p,q)$.

*Proof.* $S = 1$ iff $I(\min) = 1 + I(\gcd) = I(2\gcd)$, and $\log_2$ is strictly
monotone, so this holds iff $\min = 2\gcd$. $\square$

### 6.4 Overlap in closed form

**Theorem 6.13.** $\Omega(p,q) = I(\gcd(p,q)) / I(\min(p,q))$ for $p,q \ge 1$, and for
$p, q \ge 2$,
$$\Omega(p,q) \;+\; \frac{S(p,q)}{I(\min(p,q))} \;=\; 1 .$$

*Proof.* Strict monotonicity of $\log_2$ gives $\min(I(p),I(q)) = I(\min(p,q))$, which
is the first claim. For the second, $I(\min) > 0$ when $\min \ge 2$, and by Theorem 6.10
$$\Omega + \frac{S}{I(\min)} = \frac{I(\gcd) + \bigl(I(\min) - I(\gcd)\bigr)}{I(\min)} = 1. \qquad \square$$

So the two audited statistics are complementary shares of the weaker channel's
capacity: the overlap is the redundant fraction, and $S/I(\min)$ is the novel
fraction. They are not independent measurements; reporting both is reporting one
number twice.

---

## 7. Keystone P: the ramp law is exact

**Definition 7.1.** $\operatorname{ramp}(x) = \max\bigl(0, \min(1, x)\bigr)$, the clamp of
$x$ to $[0,1]$. It is monotone.

**Definition 7.2.** Enumerate the cells of the $r \times r$ grid in reading order, so
that the cell $(i,j)$ with $0 \le i, j < r$ receives the index $ir + j$. For a budget
$q \ge 0$ define the success count
$$C(q, r) \;=\; \bigl|\{(i,j) \in [0,r)^2 \;:\; ir + j < q\}\bigr|,$$
and the success fraction $P_1(q,r) = C(q,r)/r^2$.

**Theorem 7.3 (Exact cell count).** For all $q \ge 0$ and $r \ge 0$,
$$C(q,r) \;=\; \min(q,\, r^2).$$

*Proof.* For $r = 0$ both sides are zero. For $r \ge 1$ the maps $(i,j) \mapsto ir+j$ and
$n \mapsto (n \operatorname{div} r,\ n \bmod r)$ are mutually inverse bijections between the
counted set and $\{0,1,\dots,\min(q,r^2)-1\}$. Forward: if $i,j < r$ and $ir + j < q$ then
also $ir + j < ir + r = (i+1)r \le r^2$, so the index lies below $\min(q,r^2)$. Backward: if
$n < \min(q, r^2)$ then $n \operatorname{div} r < r$ and $n \bmod r < r$ and
$(n \operatorname{div} r)r + (n \bmod r) = n < q$. The two maps are mutually inverse by
division with remainder. $\square$

**Theorem 7.4 (The ramp law, exactly).** For $r \ge 1$ and all $q \ge 0$,
$$P_1(q,r) \;=\; \operatorname{ramp}\!\left(\frac{q}{r^2}\right).$$

*Proof.* By Theorem 7.3, $P_1 = \min(q,r^2)/r^2$. If $q \le r^2$ this is $q/r^2 \in [0,1]$,
which the clamp fixes. If $q \ge r^2$ this is $1$, and $q/r^2 \ge 1$, so the clamp returns
$1$. $\square$

The reported approximation $P_1 \approx \operatorname{ramp}(q/r^2)$ is thus an identity. The
"clipping" is not a fitted nonlinearity but the two branches of $\min(q, r^2)$, and the
linear regime has slope exactly $1/r^2$.

---

## 8. The audit bundle

Collecting the statements that the audit reports as empirical findings:

**Theorem 8.1 (Structural audit bundle).** Let $a, c, m, s$ satisfy $m > 0$, $s < m$; let
$p, q \ge 2$ and $r \ge 1$; and let $L, L'$ be schedules with $\lVert L\rVert = \lVert L'\rVert$.
Then all of the following hold as theorems of the model:

1. $E(L, s) = E(L', s)$ — the recorded terminal state does not depend on the batch schedule;
2. $d(0) = 0$, and $d(k) \le d(l)$ whenever $k \le l$ — the deficit column starts at $+0.000$
   and never decreases;
3. $d(k) \to \infty$ — the capacity curve saturates;
4. $S(p,q) \ge 0$ and $\Omega(p,q) \in [0,1]$ — the synergy decomposition has the reported
   signs and range;
5. $P_1(n, r) = \operatorname{ramp}(n/r^2)$ for every $n$ — the ramp law is exact.

Every item is a consequence of Sections 3–7. None of them can fail under any execution,
on any hardware, in any language, for any seed. Verifying them by re-execution therefore
provides no evidence beyond the correctness of the implementation.

To this we add the strictly quantitative results, which go beyond anything the audit
reports:

6. **(Theorem 5.5)** the count column of *any* deterministic finite-state pipeline is
   $\min(k+1, N)$ for a single orbit size $N$;
7. **(Theorem 5.7)** $N$ is readable off the deficit column via the first unit jump;
8. **(Theorem 3.6)** batch invariance is *equivalent* to being an iterated unit step;
9. **(Theorem 6.11)** synergy is quantised with a full-bit gap above zero.

---

## 9. Discussion: what an audit can and cannot decide

### 9.1 The audit's blind spot

Items 1–5 of Theorem 8.1 are invariant under re-execution *by mathematical necessity*.
Confirming them empirically is not worthless — it tests the implementation against the
model — but it must not be reported as evidence for the model's predictions, and it
cannot fail informatively: a violation would indicate a coding error, never a scientific
finding.

The complementary observation is sharper. Determinism guarantees that a *misinterpreted*
statistic reproduces just as faithfully as a correct one. Executional reproducibility is
therefore silent about semantic validity, and the quantitative theorems above are exactly
the instrument that is not.

### 9.2 An adversarial finding: two synergy values in the forbidden zone

The audited synergy table reports two values, $+0.1290$ bits for one channel pair and
$+0.0049$ bits for another, both reproducing exactly on re-execution, alongside an overlap
coefficient of $0.9919$.

By Theorem 6.11, for two channels with exact integer periods $p$ and $q$, the synergy
$S(p,q) = \log_2(\min(p,q)/\gcd(p,q))$ is the base-$2$ logarithm of a positive integer.
Hence it takes values in
$$\{\log_2 t : t \in \mathbb{Z}_{\ge 1}\} \;=\; \{0,\ 1,\ \log_2 3 \approx 1.585,\ 2,\ \dots\},$$
and in particular $S \in \{0\} \cup [1,\infty)$. Neither $0.1290$ nor $0.0049$ is in that
set, and both lie in the open gap $(0,1)$ that the model provably cannot reach.

What follows from this, carefully stated:

* It does **not** follow that the computation is wrong, or that the audit failed. The
  numbers may be exactly what the code computes, and they may reproduce forever.
* It **does** follow that the quantity being reported is not the joint-versus-marginal
  capacity of two exactly periodic integer channels. Some hypothesis in the
  interpretation is doing unacknowledged work.

Candidate reconciliations, each of which changes what the number means:

1. **Truncated observation.** If the joint channel is observed for $k < \operatorname{lcm}(p,q)$
   ticks, the count is $\min(k, \operatorname{lcm}(p,q))$ rather than $\operatorname{lcm}(p,q)$, and
   the quantisation argument no longer applies. The reported value is then a
   window-dependent artifact, not a property of the channel pair.
2. **Non-integer or approximate periodicity.** If the channels are only approximately
   periodic — quasi-periodic, noisy, or defined by empirical autocorrelation — the
   arithmetic of $\gcd$ and $\operatorname{lcm}$ is not available and the gap dissolves, but
   so does the inclusion–exclusion identity that motivated the statistic.
3. **Averaging.** If the reported figure is an average of per-pair synergies over a
   collection of channel pairs, it may land in $(0,1)$ while every summand is $0$ or
   $\ge 1$ — indeed $0.0049$ is consistent with a single unit-synergy pair among roughly
   $200$ nested pairs. Under this reading the value measures *prevalence of non-nesting*,
   not synergy.
4. **Smoothed or regularised counts.** Logarithms of smoothed or shrunk state counts are
   not logarithms of orbit sizes, and inherit none of the arithmetic.

Each candidate is defensible as modelling practice; none is compatible with the label as
stated. The theorem cannot say which is operative, but it establishes that *one of them
must be*, and that is precisely the kind of conclusion an audit cannot reach by
re-running anything.

### 9.3 A second admissibility check: the capacity column

The same discipline applies to the reported capacity numbers. In the single-orbit model the
two columns are rigidly linked: since $|S_k| \le k+1$ we have $I(k) \le \log_2(k+1)$, and
therefore $d(k) = k - I(k) \ge 0$ with $d(0) = 0$. A reported value of $I(6) = 11.5307$ bits
is thus impossible for the number of distinct states seen by a single pipeline at time $6$,
which cannot exceed $7$, giving $I(6) \le \log_2 7 \approx 2.807$; and the corresponding
deficit $6 - 11.5307 < 0$ would violate nonnegativity.

Again the conclusion is not that a computation is wrong. It is that the recorded capacity
and the recorded deficit column cannot both be the single-orbit quantities of Definition
4.1: at least one of them measures something else — plausibly the joint capacity of a
battery of several channels, with the deficit taken relative to the sum of the marginal
capacities rather than relative to the clock. That is a perfectly sensible statistic, but it
obeys a different set of constraints, and the ones proved here do not transfer to it
unexamined. The general point stands: a reported pair $(I(k), d(k))$ violating
$0 \le d(k)$ or $I(k) \le \log_2(k+1)$ is a signal that two different notions are sharing a
column heading.

### 9.4 A positive methodology

The analysis suggests a three-tier discipline for reporting computational results.

**Tier 1 — prove the invariants.** Identify which reported quantities are theorems of the
model. Report them as theorems; do not spend audit budget on them.

**Tier 2 — publish the admissibility constraints.** For the quantities that are *not*
determined, derive the constraints the model imposes: the deficit column must have its
unit jumps in a terminal segment (Corollary 5.8); the synergy must avoid $(0,1)$ (Theorem
6.11); the overlap and the synergy share must sum to one (Theorem 6.13). These are cheap
to check and catch misinterpretation, not just nondeterminism.

**Tier 3 — audit the residue.** Whatever genuinely depends on the execution — timings,
stochastic estimates, floating-point tails — is the proper subject of a re-execution audit.

Under this discipline, the present case would have been caught before the audit was run,
by a check costing one line of arithmetic.

### 9.5 Batch sensitivity as a diagnostic

Theorem 3.6 turns a folk practice into a decision procedure. Running a pipeline under two
schedules of equal total length and comparing outputs is not a heuristic for "checking
determinism"; it *decides* whether the process is an iterated visible step. This matters
because hidden state is the single most common source of non-reproducibility in practice
(accumulators, caches, reduction orders, lazily initialised buffers, thread-local
randomness), and the test requires no instrumentation whatsoever.

---

## 10. Future directions

1. **Orbit size as a published statistic.** Corollary 5.8 makes $N$ observable. Since $N$
   determines the entire capacity column, the honest summary of a capacity experiment is a
   single integer. What, then, is the informative content of publishing the column?

2. **Beyond a single orbit.** The exact law describes one seed. Averaging over seeds gives
   an expected count $\mathbb{E}_s[\min(k+1, N_s)]$ whose shape depends on the distribution
   of orbit sizes under the step map. For random maps this connects to the classical
   birthday/rho-length theory; for congruential maps the orbit-size spectrum is number
   theoretic. A structural theory of the *averaged* deficit column would extend the present
   results to the ensemble setting that audits actually use.

3. **Multi-channel synergy.** The two-channel calculus generalises: $k$ channels with
   periods $p_1,\dots,p_k$ jointly visit $\operatorname{lcm}(p_1,\dots,p_k)$ configurations. Does
   a quantisation gap survive? The natural conjecture is that any nontrivial higher-order
   interaction again costs at least one bit, with the gap governed by the lattice of
   divisors.

4. **Approximate periodicity.** Replacing exact periods by approximate ones should replace
   the sharp gap by a quantitative bound: how much aperiodicity is needed to realise a
   synergy of $\varepsilon$ bits? A stability theorem of this form would turn the
   adversarial finding into a measurement — reading the degree of aperiodicity off the
   observed sub-bit synergy.

5. **Rebatching for stateful and stochastic processes.** Theorem 3.6 is exact for
   deterministic processes. The corresponding statement for processes with a declared
   random tape, or for floating-point arithmetic with nonassociative addition, would give
   a principled account of when "same seed, different chunking" may legitimately differ.

---

## 11. Conclusion

We have replaced an empirical reproducibility claim with an arithmetic one. Four families
of audited statistics — batch-invariant terminal states, the monotone deficit column, the
nonnegative synergy with overlap in $[0,1]$, and the clipped ramp law — are theorems of the
underlying model and cannot drift. Two families of sharper results go further: the capacity
column of *any* deterministic finite-state pipeline is determined by a single integer, the
orbit size, which is readable off the published deficits; and the synergy of two periodic
integer channels is quantised, taking values in $\{0\} \cup [1,\infty)$ with the closed form
$\log_2(\min/\gcd)$.

The last of these has teeth. Two audited synergy values that reproduce perfectly lie in a
region the model cannot reach, which means they cannot bear their stated interpretation. An
audit is constitutionally unable to notice this: a deterministic pipeline reproduces its
own misinterpretations exactly. Proving what a statistic *can* be is a different and, in
this instance, a strictly more informative act than checking that it came out the same way
twice.
