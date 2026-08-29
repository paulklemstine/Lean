# The Fermi Paradox as a Pigeonhole Principle: First Moments, Second Moments, and the Geometry of Cosmic Silence

**Aristotle**

*2026-08-29*

---

## Abstract

We construct an explicit finite product probability space modelling a universe of
$N$ habitable sites observed over $T$ discrete epochs, in which each site
independently produces a technological civilization with probability $p$, born in
a uniformly random epoch. Within this model we prove that the Drake equation is
*exactly* a first moment: the expected number of technological civilizations is
$Np$, with no dependence on $T$. We show that the probability of a completely
lifeless cosmos is exactly $(1-p)^N$, that Bernoulli's inequality bounds this
below by $1 - Np$, and that a matching second-order Bonferroni estimate
$(1-p)^N \le 1 - Np + \tfrac12 N^2p^2$ pins the probability that anyone exists to
the interval $[Np - \tfrac12 (Np)^2,\; Np]$. Consequently the Drake number, when
small, is not a population count but a probability. We then prove that *contact* —
the existence of two contemporaneous civilizations — is second order in the small
parameter: $\mathbb{P}(\text{contact}) \le (N^2-N)p^2/T \le (Np)^2/T$, and,
granting each civilization a detectability lifetime of $L$ epochs,
$\mathbb{P}(\text{contact}) \le (N^2-N)(2L-1)p^2/T$. Lifetime therefore enters
linearly while abundance enters quadratically. On the combinatorial side we
establish the correct orientation of the pigeonhole principle for this problem:
contact is forced only when the number of civilizations exceeds $T$ (a sharp
threshold, since contact-free schedules exist below it), whereas the *dual*
pigeonhole guarantees at least $T - c$ empty epochs, yielding
$\mathbb{E}[\#\text{empty epochs}] \ge T - Np$. Combining these gives the **Fermi
dichotomy**: whenever $Np < 1$, a lifeless cosmos has probability at least
$1 - Np > 0$, contact has probability at most $1/T$, and more than $T-1$ epochs
are expected to be empty. Instantiating with $N = 10^{10}$,
$T = 4.5 \times 10^{9}$, $p = 10^{-11}$ yields $\mathbb{E} = 0.1$, a lifeless
cosmos with probability $\ge 0.9$, contact probability $\le 10^{-11}$ (and
$\le 10^{-7}$ even with $L = 10^4$), and at least $4.5\times 10^9 - 0.1$ empty
epochs in expectation. The Fermi paradox is thereby dissolved: observed silence is
the model's prediction, not an anomaly requiring exotic resolution.

**Keywords:** Drake equation, Fermi paradox, pigeonhole principle, first moment
method, union bound, Bernoulli inequality, Bonferroni inequalities, occupancy
problems, rare events.

---

## 1. Introduction

### 1.1 The question and its logical status

Fermi's question — *where is everybody?* — acquires the status of a paradox only
when paired with a quantitative claim that many civilizations *should* be visible.
That quantitative claim is invariably some version of the Drake equation

$$
\mathcal{N} = R_* \cdot f_p \cdot n_e \cdot f_\ell \cdot f_i \cdot f_c \cdot L,
$$

a product of astrophysical and biological rate factors. Sixty years of literature
have debated the factors. Comparatively little attention has been paid to a prior
question: *what kind of quantity is $\mathcal{N}$?*

We argue that $\mathcal{N}$ is, and can only be, an expectation — a first moment of
a counting random variable. This is not a philosophical remark but a theorem in a
precisely specified model, and it has sharp consequences. A first moment below one
is not evidence of a suppression mechanism; it is a direct statement that the
typical realization of the underlying random experiment contains *nothing at all*.

### 1.2 Pigeonhole, in the correct direction

The pigeonhole principle is frequently invoked informally in this setting to force
coincidences: "with so many planets and so much time, somebody must have
overlapped with us." The invocation has the orientation backwards. Pigeonhole
forces a collision only when pigeons outnumber holes. Here the pigeons are
civilizations (expected count possibly below $1$) and the holes are epochs of
cosmic history (count $\sim 4.5 \times 10^9$). The applicable statement is the
*dual*:

> $c$ objects placed into $T$ boxes leave at least $T - c$ boxes empty.

Under Fermi-regime numbers this predicts a cosmos in which essentially every epoch
is vacant. The silence is the prediction.

### 1.3 Contributions

1. **A self-contained finite model** (§2) with an exact cylinder factorization
   theorem, from which every subsequent estimate is derived — no measure theory,
   no asymptotics, no unproved independence assumptions.
2. **The Drake equation as a first moment** (§3): $\mathbb{E}[X] = Np$ exactly,
   independent of $T$.
3. **Two-sided emptiness estimates** (§3): $\mathbb{P}(\text{lifeless}) = (1-p)^N$,
   bracketed by Bernoulli below and second-order Bonferroni above, so that
   $\mathbb{P}(\text{somebody}) \in [Np - \tfrac12(Np)^2, Np]$.
4. **Second-order contact bounds** (§4): contact is quadratic in $p$ and inversely
   proportional to $T$; with a lifetime window $L$, linear in $L$.
5. **Sharp pigeonhole combinatorics** (§5): forced contact exactly above the
   threshold $c = T$, contact-free schedules below it, and
   $\mathbb{E}[\#\text{empty epochs}] \ge T - Np$.
6. **The Fermi dichotomy and its cosmological instantiation** (§6–§7).
7. **Exact computational corroboration** on small parameter values (§8), and a
   discussion of what the result does and does not license (§9–§10).

---

## 2. The model

### 2.1 Sample space and weights

**Definition 2.1 (Cosmos).** Fix integers $N \ge 0$ (habitable sites) and
$T \ge 1$ (epochs). The *sample space* is the finite set

$$
\Omega_{N,T} \;=\; \bigl\{\, f : \{1,\dots,N\} \to \{\ast\} \cup \{1,\dots,T\} \,\bigr\},
$$

where $f(i) = \ast$ means site $i$ never produced a technological civilization,
and $f(i) = e$ means site $i$ produced exactly one civilization, born in epoch
$e$. Thus $|\Omega_{N,T}| = (T+1)^N$.

**Definition 2.2 (Local weight).** For a parameter $p \in [0,1]$ define
$w : \{\ast\} \cup \{1,\dots,T\} \to \mathbb{R}$ by

$$
w(\ast) = 1 - p, \qquad w(e) = \frac{p}{T} \quad (1 \le e \le T).
$$

**Definition 2.3 (Outcome weight and probability).** The weight of an outcome is
the product of its local weights,
$$
W(f) \;=\; \prod_{i=1}^{N} w\bigl(f(i)\bigr),
$$
and the probability of an event $A \subseteq \Omega_{N,T}$ is
$$
\mathbb{P}(A) \;=\; \sum_{f \in A} W(f).
$$

The interpretation: sites are independent; each is barren with probability $1-p$
and otherwise produces a civilization whose birth epoch is uniform on
$\{1,\dots,T\}$.

**Lemma 2.4 (Local normalization).** For $T \ge 1$,
$\sum_{x} w(x) = (1-p) + T \cdot \tfrac{p}{T} = 1$, and $w(x) \ge 0$ whenever
$0 \le p \le 1$.

### 2.2 The engine: cylinder factorization

Everything below is a corollary of one identity.

**Theorem 2.5 (Cylinder factorization).** For any choice of subsets
$B_i \subseteq \{\ast\} \cup \{1,\dots,T\}$, $1 \le i \le N$,

$$
\mathbb{P}\bigl(\{ f : f(i) \in B_i \ \text{for all } i \}\bigr)
\;=\; \prod_{i=1}^{N} \ \sum_{x \in B_i} w(x).
$$

*Proof sketch.* The event is exactly the product set $B_1 \times \cdots \times B_N$.
Its total weight is $\sum_{f \in \prod_i B_i} \prod_i w(f(i))$, and the
distributive law for finite products of finite sums ($\prod_i \sum_{x \in B_i}$
expands into a sum over choice functions) identifies this with
$\prod_i \sum_{x \in B_i} w(x)$. Outcomes outside the product set contribute zero
to the indicator sum. $\square$

**Corollary 2.6 (Normalization).** Taking every $B_i$ to be the full state set,
$\mathbb{P}(\Omega_{N,T}) = 1$. Hence $\mathbb{P}$ is a genuine probability
measure, and $\mathbb{P}(A) + \mathbb{P}(A^{c}) = 1$ for all $A$.

**Lemma 2.7 (Monotonicity, nonnegativity, union bound).** For $0 \le p \le 1$:
$\mathbb{P}(A) \ge 0$; $A \subseteq B$ implies $\mathbb{P}(A) \le \mathbb{P}(B)$;
and for any finite family $\{A_x\}_{x \in S}$,

$$
\mathbb{P}\Bigl(\bigcup_{x \in S} A_x\Bigr) \;\le\; \sum_{x \in S} \mathbb{P}(A_x).
$$

*Proof sketch.* Nonnegativity and monotonicity are pointwise statements about
indicator functions against a nonnegative weight. For the union bound, the
indicator of a union is dominated pointwise by the sum of indicators; summing over
$\Omega_{N,T}$ and exchanging the order of summation gives the claim. $\square$

---

## 3. The Drake equation is a first moment

**Definition 3.1 (Civilization count).** For $f \in \Omega_{N,T}$ let
$$
X(f) = \#\{\, i : f(i) \ne \ast \,\}
$$
be the number of sites hosting a civilization.

**Lemma 3.2 (Marginal law of a site).** For each $i$ and any $T \ge 1$,
$$
\mathbb{P}\bigl(f(i) \ne \ast\bigr) = p.
$$

*Proof sketch.* Apply Theorem 2.5 with $B_i$ the set of all epochs (excluding
$\ast$) and $B_j$ the full state set for $j \ne i$. The $i$-th factor is
$T \cdot (p/T) = p$; every other factor is $1$ by Lemma 2.4. The epoch degree of
freedom integrates out precisely because a civilization must be born in *some*
epoch. $\square$

**Theorem 3.3 (Drake as a first moment).** For $T \ge 1$,
$$
\boxed{\ \mathbb{E}[X] \;=\; N p.\ }
$$

*Proof sketch.* Write $X = \sum_{i=1}^{N} \mathbf{1}[f(i) \ne \ast]$. Exchange the
(finite) sums defining the expectation and the counting decomposition; each term
becomes $\mathbb{P}(f(i) \ne \ast) = p$ by Lemma 3.2. Summing over $i$ gives $Np$.
$\square$

**Remark 3.4.** The number of epochs $T$ does not appear. Lengthening cosmic
history does not change how many civilizations one expects — only how thinly they
are distributed in time. This is precisely why the $T$-dependence will reappear,
in the *denominator*, for contact events (§4).

**Theorem 3.5 (Probability of a lifeless cosmos).**
$$
\mathbb{P}\bigl(f(i) = \ast \text{ for all } i\bigr) = (1-p)^N.
$$

*Proof sketch.* Theorem 2.5 with every $B_i = \{\ast\}$. $\square$

**Theorem 3.6 (Bernoulli / emptiness bound).** For $p \le 1$,
$$
\mathbb{P}(\text{lifeless}) \;=\; (1-p)^N \;\ge\; 1 - Np.
$$

*Proof sketch.* Bernoulli's inequality $(1+x)^n \ge 1 + nx$ for $x \ge -2$, with
$x = -p$. $\square$

**Theorem 3.7 (Second-order Bonferroni bound).** For $0 \le p \le 1$ and all
$n \ge 0$,
$$
(1-p)^n \;\le\; 1 - np + \tfrac{1}{2} n^2 p^2 .
$$

*Proof sketch.* Induction on $n$. The base case is an identity. For the step,
multiply the inductive hypothesis by $(1-p) \ge 0$ and compare with the target at
$n+1$; the difference is a polynomial in $p$ and $n$ with nonnegative coefficients
in $p^2$ and $p^3$, controlled by $p \ge 0$, $n \ge 0$, and $p \le 1$. $\square$

**Corollary 3.8 (Two-sided first-moment estimate).** For $0 \le p \le 1$,
$$
Np - \tfrac{1}{2}(Np)^2 \;\le\; \mathbb{P}(\text{somebody exists}) \;\le\; Np .
$$

*Proof sketch.* The upper bound is the union bound (Lemma 2.7) applied to the $N$
single-site events, each of probability $p$ (Lemma 3.2). The lower bound is
complementation of Theorem 3.7 via Corollary 2.6. $\square$

**Interpretation 3.9.** When $Np \ll 1$, the Drake number is *the probability that
we have any neighbours at all*, correct to relative error $O(Np)$. It is not a
population count. Reading a small $\mathcal{N}$ as "we expect a fraction of a
civilization" is a category error; the correct reading is "with probability
$1 - \mathcal{N} + O(\mathcal{N}^2)$ there is nobody."

**Theorem 3.10 (Emptiness is typical).** If $p \le 1$ and $Np < 1$ then
$$
\mathbb{P}(\text{lifeless}) \;\ge\; 1 - Np \;>\; 0 .
$$
In particular a completely lifeless cosmos is not merely possible but, once
$Np < \tfrac12$, the *majority* outcome.

---

## 4. Contact is a second-order event

### 4.1 Instantaneous contact

**Definition 4.1 (Contemporaneity and contact).** Sites $i \ne j$ are
*contemporaneous* in outcome $f$ if $f(i) = f(j) \ne \ast$. The event
$$
\mathrm{Contact} = \{\, f : \exists\, i \ne j,\ f(i) = f(j) \ne \ast \,\}
$$
is the event that the cosmos ever contains two civilizations born in the same
epoch.

**Lemma 4.2 (Exact two-site law).** For $i \ne j$ and any epochs $e, e'$,
$$
\mathbb{P}\bigl(f(i) = e \ \wedge\ f(j) = e'\bigr) = \left(\frac{p}{T}\right)^{2}.
$$

*Proof sketch.* Theorem 2.5 with $B_i = \{e\}$, $B_j = \{e'\}$, and $B_k$ full for
$k \notin \{i,j\}$; the two singled-out factors contribute $p/T$ each and all
others contribute $1$. $\square$

**Lemma 4.3 (Pairwise contact bound).** For $0 \le p \le 1$, $T \ge 1$, $i \ne j$,
$$
\mathbb{P}\bigl(f(i) = f(j) \ne \ast\bigr) \;\le\; \frac{p^2}{T}.
$$

*Proof sketch.* The event is contained in the union over epochs $e$ of the events
$\{f(i) = f(j) = e\}$. Each has probability $(p/T)^2$ by Lemma 4.2; the union
bound over $T$ epochs gives $T \cdot (p/T)^2 = p^2/T$. $\square$

**Theorem 4.4 (Contact is quadratically rare).** For $0 \le p \le 1$ and
$T \ge 1$,
$$
\boxed{\ \mathbb{P}(\mathrm{Contact}) \;\le\; \frac{(N^2 - N)\,p^2}{T}\ }
$$

*Proof sketch.* $\mathrm{Contact}$ is the union of the pairwise events over the
$N^2 - N$ ordered pairs of distinct sites. Apply the union bound and Lemma 4.3.
$\square$

**Corollary 4.5 (Contact controlled by the squared Drake expectation).**
$$
\mathbb{P}(\mathrm{Contact}) \;\le\; \frac{(Np)^2}{T} \;=\; \frac{\mathbb{E}[X]^2}{T}.
$$

**Remark 4.6 (Two structural readings).**
- **Quadratic in abundance.** Contact is a *pairwise* event, so its probability
  scales as the square of the first moment. Halving $p$ quarters the chance of a
  meeting. Optimism about contact is therefore far more fragile than optimism
  about existence.
- **Inversely proportional to time.** More epochs means *less* contact. In the
  pigeonhole picture, additional time supplies additional holes into which the
  same small number of pigeons is scattered. The vast age of the universe, usually
  cited as an argument for contact, appears in the denominator.

### 4.2 Contact through a lifetime window

Real civilizations persist. We model this with Drake's lifetime factor.

**Definition 4.7 (Temporal window).** For $L \ge 1$, epochs $a, b$ are *within a
window of width $L$* if $a + L > b$ and $b + L > a$, i.e. $|a - b| < L$. The event
$$
\mathrm{Contact}_L = \{\, f : \exists\, i \ne j,\ f(i), f(j) \ne \ast,\ |f(i) - f(j)| < L \,\}
$$
is the event that two civilizations are ever mutually detectable.

**Lemma 4.8 (Window fibre count).** For a fixed epoch $a$, the number of epochs
$b$ with $|a - b| < L$ is at most $2L - 1$.

*Proof sketch.* Such $b$ lie in the integer interval $(a - L, a + L)$, which
contains at most $2L - 1$ integers; the map $b \mapsto b + L - 1 - a$ injects them
into $\{0, 1, \dots, 2L-2\}$. $\square$

**Lemma 4.9 (Window pair count).** Among the $T^2$ ordered pairs of epochs, at
most $T(2L-1)$ lie within a window of width $L$.

*Proof sketch.* Partition the pairs by their first coordinate and apply Lemma 4.8
to each of the $T$ fibres. $\square$

**Theorem 4.10 (Windowed contact bound).** For $0 \le p \le 1$, $T \ge 1$,
$L \ge 1$,
$$
\boxed{\ \mathbb{P}(\mathrm{Contact}_L) \;\le\; (N^2 - N)\,\frac{(2L-1)\,p^2}{T}.\ }
$$

*Proof sketch.* For a fixed pair $i \ne j$, the windowed pair event is the union
over the window-compatible epoch pairs $(e,e')$ of the events
$\{f(i) = e,\ f(j) = e'\}$, each of probability $(p/T)^2$ by Lemma 4.2. By Lemma
4.9 there are at most $T(2L-1)$ such pairs, giving
$T(2L-1)(p/T)^2 = (2L-1)p^2/T$ per site pair. A second union bound over the
$N^2 - N$ ordered site pairs completes the proof. $\square$

**Remark 4.11 (Lifetime is a weak lever).** Setting $L = 1$ recovers Theorem 4.4.
Note the asymmetry of the exponents: $L$ appears **linearly**, $p$
**quadratically**. Doubling civilization lifetimes roughly doubles contact
probability; doubling the abundance quadruples it. In the Drake literature $L$ is
customarily treated as the dominant unknown; in the mathematics of *contact* it is
the weakest of the available levers.

---

## 5. Pigeonhole combinatorics, correctly oriented

This section is purely deterministic: no probability appears. Let $C$ be a finite
set of civilizations with a birth-epoch assignment
$\mathrm{ep} : C \to \{1,\dots,T\}$, and write $c = |C|$.

**Theorem 5.1 (Quantitative pigeonhole).** If $T \cdot n < c$, then some epoch $e$
satisfies $\#\{\,\gamma \in C : \mathrm{ep}(\gamma) = e\,\} > n$.

*Proof sketch.* If every fibre had at most $n$ elements, then
$c = \sum_e |\mathrm{fibre}(e)| \le T n < c$, a contradiction. $\square$

**Corollary 5.2 (Forced contact).** If $c > T$, there exist distinct
$\gamma \ne \delta$ in $C$ with $\mathrm{ep}(\gamma) = \mathrm{ep}(\delta)$:
contact is combinatorially forced.

*Proof sketch.* Theorem 5.1 with $n = 1$ produces an epoch carrying at least two
civilizations. $\square$

**Theorem 5.3 (Sharpness of the threshold).** If $c \le T$, there exists an
assignment $\mathrm{ep} : C \to \{1,\dots,T\}$ that is injective, hence in which no
two civilizations are contemporaries.

*Proof sketch.* An injection $C \hookrightarrow \{1,\dots,T\}$ exists precisely
when $c \le T$. $\square$

Thus $c = T$ is the exact pigeonhole threshold: above it, contact is forced; at or
below it, pigeonhole forces nothing at all. In the Fermi setting $c$ is at most a
handful and $T \approx 4.5 \times 10^9$; the forcing hypothesis fails by nine
orders of magnitude.

**Theorem 5.4 (Dual pigeonhole: empty holes).**
$$
\#\{\, e : \text{no } \gamma \in C \text{ has } \mathrm{ep}(\gamma) = e \,\} \;\ge\; T - c .
$$

*Proof sketch.* The occupied epochs are exactly the image
$\mathrm{ep}(C)$, of cardinality at most $c$. Complement within the $T$ epochs.
$\square$

**Corollary 5.5 (Pigeonhole predicts emptiness).** If $c < T$, at least one epoch
is completely empty; and the number of empty epochs is at least $T - c$, which is
overwhelmingly large in the Fermi regime.

### 5.1 Coupling to the probabilistic model

**Definition 5.6 (Empty epochs of an outcome).** For $f \in \Omega_{N,T}$ let
$$
E(f) = \#\{\, e : f(i) \ne e \text{ for all } i \,\}
$$
be the number of epochs in which no site hosts a newborn civilization.

**Lemma 5.7 (Pointwise dual pigeonhole).** For every outcome $f$,
$$
E(f) \;\ge\; T - X(f).
$$

*Proof sketch.* Apply Theorem 5.4 with $C$ the set of civilized sites, of
cardinality $X(f)$, and $\mathrm{ep}$ the induced birth-epoch map. (If no site is
civilized, all $T$ epochs are empty and the inequality is immediate.) $\square$

**Theorem 5.8 (Expected emptiness).** For $0 \le p \le 1$ and $T \ge 1$,
$$
\boxed{\ \mathbb{E}[E] \;\ge\; T - Np .\ }
$$

*Proof sketch.* Take expectations in Lemma 5.7, using linearity, normalization
($\mathbb{E}[T] = T$), and Theorem 3.3 ($\mathbb{E}[X] = Np$). Pointwise
nonnegativity of the weights makes the inequality survive the averaging. $\square$

**Remark 5.9.** When $Np < 1$, Theorem 5.8 says that **all but at most one of the
$T$ epochs of cosmic history are expected to be completely empty**. This is the
precise sense in which the pigeonhole principle, applied with honest counts,
predicts an empty universe rather than a crowded one.

---

## 6. The Fermi dichotomy

**Theorem 6.1 (Fermi dichotomy).** Let $0 \le p \le 1$, $T \ge 1$, and write
$\mathcal{E} = Np$ for the Drake expectation. If $\mathcal{E} < 1$ then
simultaneously:

1. $\mathbb{P}(\text{lifeless}) \ge 1 - \mathcal{E} > 0$;
2. $\mathbb{P}(\mathrm{Contact}) \le 1/T$;
3. $\mathbb{E}[E] > T - 1$.

*Proof sketch.* (1) is Theorem 3.6 together with $\mathcal{E} < 1$. (2) follows
from Corollary 4.5 and $\mathcal{E}^2 \le 1$. (3) is Theorem 5.8 with
$Np < 1$. $\square$

Three qualitatively distinct predictions — emptiness, non-contact, temporal
vacancy — follow from the single hypothesis that the first moment is below one. No
Great Filter, zoo hypothesis, or self-destruction mechanism is invoked or needed.

---

## 7. Cosmological instantiation

Fix conservative but defensible parameters:

$$
N = 10^{10}, \qquad T = 4.5 \times 10^{9}, \qquad p = 10^{-11}.
$$

Here $N$ is an order-of-magnitude estimate of habitable-zone worlds accessible to
the argument, $T$ counts one-year epochs over $4.5$ Gyr, and $p$ is the
probability that a habitable world ever produces a technological civilization. The
value of $p$ is a product of several contingent evolutionary transitions
(abiogenesis, eukaryogenesis, multicellularity, encephalization, technology); if
each has probability of order $10^{-2}$ to $10^{-3}$, their product falls in this
range.

**Theorem 7.1 (Expected count).** With these parameters,
$\mathbb{E}[X] = Np = 1/10$.

**Theorem 7.2 (Lifeless with high probability).**
$\mathbb{P}(\text{lifeless}) \ge 9/10$.

**Theorem 7.3 (Existence sandwich).**
$$
0.095 \;=\; \tfrac{19}{200} \;\le\; \mathbb{P}(\text{somebody exists}) \;\le\; \tfrac{1}{10} \;=\; 0.1 .
$$
In particular the model is not vacuous: someone exists with probability roughly
one in ten, and the first-moment answer is correct to within $5 \times 10^{-3}$.

**Theorem 7.4 (Contact).**
$\mathbb{P}(\mathrm{Contact}) \le 10^{-11}$.

**Theorem 7.5 (Contact with generous lifetimes).** Granting every civilization a
detectability lifetime of $L = 10^{4}$ epochs (ten thousand years),
$$
\mathbb{P}(\mathrm{Contact}_{10^4}) \;\le\; 10^{-7}.
$$

**Theorem 7.6 (Empty epochs).**
$$
\mathbb{E}[E] \;\ge\; 4\,500\,000\,000 - \tfrac{1}{10} .
$$

All six follow by substituting the parameter values into Theorems 3.3, 3.6,
Corollary 3.8, Theorem 4.4, Theorem 4.10, and Theorem 5.8 respectively, and
performing exact rational arithmetic.

**Summary of the instantiation.**

| Quantity | Value |
|---|---|
| Expected number of civilizations $\mathbb{E}[X]$ | $0.1$ exactly |
| $\mathbb{P}(\text{lifeless})$ | $\ge 0.9$ |
| $\mathbb{P}(\text{somebody exists})$ | $\in [0.095,\ 0.1]$ |
| $\mathbb{P}(\text{contact}, L=1)$ | $\le 10^{-11}$ |
| $\mathbb{P}(\text{contact}, L=10^4)$ | $\le 10^{-7}$ |
| Expected empty epochs (out of $4.5\times 10^9$) | $\ge 4\,499\,999\,999.9$ |

We observe silence. The model predicts silence with probability $0.9$ and predicts
that, even conditionally on someone existing, contact is essentially impossible.
Observation and prediction agree.

---

## 8. Exact computational corroboration

The estimates above are inequalities. To confirm they are neither vacuous nor
grossly lossy, the model can be enumerated *exactly* in rational arithmetic for
small $(N,T,p)$, since $|\Omega_{N,T}| = (T+1)^N$ is small. Representative exact
values:

| Parameters | Quantity | Exact value | Proved bound |
|---|---|---|---|
| $N{=}3, T{=}2, p{=}\tfrac15$ | total mass | $1$ | $=1$ (normalization) |
| $N{=}3, T{=}2, p{=}\tfrac15$ | $\mathbb{P}(\mathrm{Contact})$ | $\tfrac{7}{125} = 0.0560$ | $\le \tfrac{3}{25} = 0.12$ |
| $N{=}4, T{=}3, p{=}\tfrac1{10}$ | $\mathbb{P}(\mathrm{Contact})$ | $\tfrac{191}{10000} = 0.0191$ | $\le \tfrac{1}{25} = 0.04$ |
| $N{=}3, T{=}2, p{=}\tfrac15$ | $\mathbb{P}(\text{lifeless})$ | $\tfrac{64}{125} = 0.512$ | $= (1-p)^3$; $\ge \tfrac25$ |
| $N{=}4, T{=}3, p{=}\tfrac1{10}$ | $\mathbb{P}(\text{somebody})$ | $\tfrac{3439}{10000} = 0.3439$ | $\in [0.32,\ 0.40]$ |
| $N{=}3, T{=}2, p{=}\tfrac15$ | $\mathbb{E}[E]$ | $\tfrac{729}{500} = 1.458$ | $\ge \tfrac75 = 1.4$ |
| $N{=}4, T{=}3, p{=}\tfrac1{10}$ | $\mathbb{E}[E]$ | $\tfrac{707281}{270000} \approx 2.6196$ | $\ge \tfrac{13}{5} = 2.6$ |

Two structural facts are visible in the numbers.

**Contact decays like $1/T$.** With $N = 3$, $p = 1/5$ fixed, the exact contact
probabilities for $T = 2, 3, 4$ are $\tfrac{7}{125} = 0.0560$,
$\tfrac{43}{1125} = 0.0382$, $\tfrac{29}{1000} = 0.0290$ — tracking the predicted
inverse-linear decay in the number of epochs.

**The union bound loses exactly a factor $2$ in the two-site case.** For $N = 2$,
$T = 5$, $p = 1/2$, the exact contact probability is $\tfrac{1}{20}$ while the
bound gives $\tfrac{1}{10}$: precisely the slack from counting *ordered* rather
than unordered pairs. This confirms the estimates are tight up to this explicit
constant.

---

## 9. Discussion

### 9.1 What is proved, and what is assumed

The theorems are unconditional statements about the model. The *cosmological
conclusions* are conditional on the parameter values, and above all on $p$. The
mathematics does not determine $p$; nothing currently known does.

What the mathematics does establish is that **no additional explanatory mechanism
is required**. The Fermi paradox literature is largely a catalogue of proposed
suppression mechanisms — Great Filters past or future, the zoo hypothesis, the
dark forest, self-destruction, transcension — each designed to reconcile a "large
predicted population" with an empty sky. But the Drake calculation never predicted
a large population; it computed a mean. Theorem 3.6 and Corollary 3.8 show that
when that mean is below one, emptiness is the *modal* outcome, and Theorem 6.1
shows that non-contact and temporal vacancy come along for free.

### 9.2 The inference runs backwards

Because Corollary 3.8 is two-sided, silence is *informative about $p$* rather than
about mechanisms. If $\mathbb{P}(\text{somebody}) \in [Np - \tfrac12(Np)^2, Np]$,
then observing no neighbours is a likelihood-ratio statement about $Np$ directly.
A century of null results is a Bayesian update on a single scalar. This reframes
SETI: it is not a search for an anomaly's explanation but an estimator for $p$.

### 9.3 Structural lessons independent of the parameters

Four conclusions survive whatever $p$ turns out to be.

1. **The Drake number is a first moment.** When small, it should be read as the
   probability that anyone exists, not as a headcount (Interpretation 3.9).
2. **Contact scales as the square of abundance.** Existence is first order;
   meeting is second order (Theorem 4.4).
3. **Time is in the denominator.** Cosmic longevity spreads a fixed expected
   population over more epochs, *reducing* contact probability (Remark 4.6).
4. **Lifetime is a linear lever; abundance is quadratic.** Arguments for a
   populated, communicative galaxy should target $p$, not $L$ (Remark 4.11).

### 9.4 Limitations of the model

The model deliberately omits several features.

- **Spatial structure.** Sites are exchangeable; there is no notion of distance,
  light travel time, or causal reachability. Adding a metric can only *reduce*
  contact probability, so the bounds remain valid as upper bounds on any
  spatially-embedded refinement.
- **Colonization and propagation.** A civilization that seeds daughter
  civilizations violates site independence. This is the most substantive
  omission: percolation-type models with expansion can produce contact
  probabilities far above the independent-site bounds once the branching factor
  exceeds one. The present analysis is a statement about the *non-expanding*
  regime.
- **Uniform birth epochs.** Real habitability is time-inhomogeneous (metallicity
  ramps, gamma-ray-burst sterilization). Non-uniform epoch distributions
  concentrate births and *increase* contact probability by a factor equal to the
  effective inverse participation ratio $T \sum_e q_e^2$ of the epoch
  distribution $q$.
- **One civilization per site.** Repeated independent origins on a single world
  would multiply $p$; the model absorbs this into $p$ by definition.
- **Upper bounds only for contact.** Theorems 4.4 and 4.10 bound contact from
  above. A matching lower bound requires a second-moment (variance) computation;
  see §10.

### 9.5 Relation to occupancy theory

Readers will recognize the classical *occupancy problem*: $c$ balls into $T$ boxes,
with the number of empty boxes concentrating around $T e^{-c/T}$. Our Theorem 5.8
is the deterministic, distribution-free shadow of that asymptotic, and it holds
with no independence assumption on the epoch assignment whatsoever — which is what
lets it be coupled to the probabilistic first moment without any additional
hypotheses. The Fermi regime $c \ll T$ is the extreme sparse corner of occupancy
theory, where essentially every box is empty and the interesting statistic is not
the number of empty boxes but the number of *collisions* — which is exactly the
birthday-problem quantity governed by $c^2/T$, matching Corollary 4.5 on the nose.

---

## 10. Future directions

### 10.1 A sharp second-moment threshold for contact

**Conjecture.** Contact undergoes a sharp threshold at $N^2p^2L/T = 1$: if
$N^2p^2L/T \to 0$ then $\mathbb{P}(\mathrm{Contact}_L) \to 0$, while if
$N^2p^2L/T \to \infty$ *and* $Np \to \infty$ then
$\mathbb{P}(\mathrm{Contact}_L) \to 1$.

The contact indicator is a sum of pair indicators whose pairwise correlations are
$O(p^3)$; the second-moment (Paley–Zygmund) method should convert the proved
first-moment upper bound into a matching lower bound. The missing ingredient is
the variance estimate $\mathrm{Var}[Y] \le \mathbb{E}[Y] + O(N^3p^3L^2/T)$ for the
pair-count $Y$. If confirmed, the Fermi question acquires a **phase diagram**
rather than a single verdict, with $N^2p^2L/T$ as the order parameter. If refuted,
the correlation structure of birth epochs matters at leading order — itself a
substantive finding.

### 10.2 Pigeonhole rigidity for contact-free schedules

**Conjecture.** For $c \le T$, the number of contact-free schedules of $c$
civilizations into $T$ epochs with lifetime window $L$ is exactly
$$
T\bigl(T - (2L-1)\bigr)\bigl(T - 2(2L-1)\bigr)\cdots\bigl(T - (c-1)(2L-1)\bigr)
$$
whenever $(c-1)(2L-1) < T$, and zero otherwise; consequently a contact-free
schedule exists **if and only if** $(c-1)(2L-1) < T$.

The insight is that a window of width $L$ converts the pigeonhole count from "one
hole per pigeon" to "one *interval* of $2L-1$ holes per pigeon", a
circular-interval packing problem with an exact product formula. The interval count
is already available (Lemma 4.9), and the $L = 1$ case is Theorem 5.3.

### 10.3 Further programme

- **Spatially embedded models.** Place sites in a metric space and require causal
  contact within light-travel time; derive the corresponding percolation
  threshold.
- **Colonization dynamics.** Replace independent sites with a branching process
  and identify the critical branching factor at which the contact bound fails.
- **Non-uniform epochs.** Quantify the exact inflation factor $T\sum_e q_e^2$ for
  realistic habitability histories.
- **Inverse problem.** Given $k$ centuries of null observations, produce a rigorous
  confidence upper bound on $p$ using the two-sided estimate of Corollary 3.8.

---

## 11. Conclusion

The Fermi paradox is not a paradox. Written down carefully, the Drake calculation
is a first moment, and a first moment below one predicts — with quantitative,
two-sided precision — an empty cosmos, a vanishing probability of contact, and a
history almost every epoch of which contains nobody at all. The pigeonhole
principle, applied with the correct counts, does not force encounters; in its dual
form it *guarantees empty holes*, at least $T - Np$ of them in expectation.

Under conservative parameters the expected number of technological civilizations
in the observable universe is $0.1$; the cosmos is lifeless with probability at
least $0.9$; contact ever occurring has probability below $10^{-11}$, and below
$10^{-7}$ even granting every civilization ten thousand years of detectability.

We observe silence. The mathematics predicts silence. The correct response is not
to seek a hidden mechanism, but to recognize a small number multiplied by a large
one, and to update our estimate of that small number accordingly.
