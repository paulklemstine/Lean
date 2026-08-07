# An Exactly Solvable Isolated-Horizon Microstate Model: The Bekenstein–Hawking Area Law, Its Subleading Constant, and Its Hagedorn Thermodynamics

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

We give a complete and exact analysis of a combinatorial microstate model of a
quantum isolated horizon in which a puncture carrying spin label $k = 2j \ge 1$
contributes $k$ elementary quanta of horizon area and possesses $k+1$ internal
(magnetic) states. Writing $W(A)$ for the number of ordered puncture
configurations of total area $A$, we prove that the infinite-order renewal
recursion $W(A+1) = \sum_{i=0}^{A}(i+2)W(A-i)$ collapses to the two-term linear
recursion $W(A+2) = 4W(A+1) - 2W(A)$ valid for $A \ge 1$, and hence that
$4W(A) = (1+\sqrt2)(2+\sqrt2)^A + (1-\sqrt2)(2-\sqrt2)^A$. From this exact closed
form we deduce: the two-sided bound $(2+\sqrt2)^A/2 \le W(A) \le (2+\sqrt2)^A$; an
area law $|\log W(A) - A\log(2+\sqrt2)| \le \log 2$ with *uniformly bounded*
defect; the exact subleading behaviour $\log W(A) - A\log(2+\sqrt2) \to
\log\frac{1+\sqrt2}{4}$, approached at the exponential rate $\theta^A$ with
$\theta = 3-2\sqrt2$, so that the unconstrained ensemble carries no logarithmic
correction; and the uniqueness of the area quantum $\gamma = 4\log(2+\sqrt2)$
compatible with the Bekenstein–Hawking coefficient $S = A/4$.

We then show that the area law is structural rather than model-specific. For an
arbitrary degeneracy function $\deg : \mathbb{N}_{\ge1} \to \mathbb{N}$ with
$\deg(1) \ge 1$ and $\deg(k) \le B^k$, supermultiplicativity of the microstate
count and Fekete's lemma give a finite entropy density $L$ with
$\log \deg(1) \le L \le \log(2B)$; and any positive root $r$ of the characteristic
equation $\sum_{k\ge1}\deg(k)r^k = 1$ satisfies $L = -\log r$, with no
finite-support hypothesis. The density is strictly monotone in the degeneracies
(a rigidity statement for the Barbero–Immirzi parameter), is positive except in a
single degenerate model, and is computable: truncation at puncture area $K$
under-estimates $L$ by at most $\frac{B}{1-Br}(Br)^K$.

Imposing the physical Gauss (projection) constraint $\sum_i m_i = 0$ costs at most
a logarithm: $W(A)^2 \le (2A+1)Z(2A)$ where $Z$ is the constrained count, whence
the constrained entropy defect is at most $\log 4 + \log(2A+1)$ and the
constrained entropy obeys the same area law with the same density. A parity
superselection rule $Z(\text{odd}) = 0$ holds and refutes global unimodality of
the projection profile.

Finally we develop the canonical thermodynamics. With fugacity $x = e^{-\beta}$
per area quantum, $Z(x) = \sum_A W(A)x^A$ converges exactly for $x < x_c :=
1/(2+\sqrt2)$ and equals $(1-x)^2/(2x^2-4x+1)$, so the model has a Hagedorn
temperature $T_H = 1/\log(2+\sqrt2)$. The first three cumulants of the area are
rational functions with poles at $x_c$ of orders exactly $1$, $2$, $3$ and
residues exactly $x_c$, $x_c^2$, $2x_c^3$, exhibiting the pattern $\kappa_m \sim
(m-1)!\,x_c^m/(x_c-x)^m$. The variance, hence the specific heat, is strictly
positive subcritically and diverges at $x_c$; the mean area diverges as well,
establishing ensemble inequivalence.

**Keywords:** Bekenstein–Hawking entropy, isolated horizon, microstate counting,
renewal recursion, characteristic equation, Barbero–Immirzi parameter, Hagedorn
transition, ensemble inequivalence.

---

## 1. Introduction

### 1.1 The problem

The Bekenstein–Hawking formula $S = A/4$ assigns to a black hole horizon an
entropy proportional to its area. Boltzmann's identification $S = \log \Omega$
then demands a count: roughly $e^{A/4}$ microstates associated with a horizon of
area $A$. Any candidate quantum theory of gravity is expected to supply that
count, and to reproduce both the linear dependence on $A$ and the coefficient
$1/4$.

The isolated-horizon programme provides a concrete combinatorial answer. The
horizon is modelled as a two-sphere punctured by a finite family of spin-network
edges; each puncture carries an $SU(2)$ spin $j$, contributes a quantum of area
determined by $j$, and carries $2j+1$ internal magnetic states. The horizon
degrees of freedom form a Chern–Simons theory whose states, subject to a
projection (Gauss) constraint, are counted by an explicit combinatorial problem.

The model considered here uses the *equidistant* (large-spin, or $k$-linear) area
spectrum, in which a puncture of label $k = 2j$ contributes exactly $k$ elementary
quanta of area. This is the regime in which the counting problem becomes exactly
solvable, and it is the regime in which the Barbero–Immirzi parameter is normally
fixed.

### 1.2 What we prove

Our contributions are (i) an *exact* solution of the counting problem, (ii) a
*structural* theory showing which features of the answer are model-independent,
(iii) a *quantitative* treatment of the physical constraint, and (iv) a complete
*thermodynamic* analysis including the exact pole structure at the Hagedorn point.

Everything below is stated as an identity, an inequality with explicit constants,
or an exact limit; no asymptotic estimate with unspecified constants appears.

### 1.3 Organisation

Section 2 sets up the model. Section 3 proves the recursion collapse and the
closed form. Section 4 derives the area law, the exact subleading constant and the
normalisation of the area quantum. Section 5 develops the universal theory:
Fekete existence, the characteristic-root theorem, rigidity, the positivity
dichotomy and the truncation rate. Section 6 treats the projection constraint.
Section 7 develops the canonical thermodynamics. Section 8 collects algorithms.
Section 9 discusses physical interpretation, and Section 10 lists open problems.

---

## 2. The microstate model

### 2.1 Punctures

**Definition 2.1 (Puncture labels).** For $k \in \mathbb{N}$ set
$$\mathcal{L}(k) := \{\,k - 2i : 0 \le i \le k\,\} = \{k,\, k-2,\, \dots,\, -k\} \subset \mathbb{Z}.$$
These are the doubled magnetic numbers $M = 2m$ of a spin-$j$ puncture with
$k = 2j$: integers of the same parity as $k$ with $|M| \le k$. Since $i \mapsto
k-2i$ is injective, $|\mathcal{L}(k)| = k+1$, the expected degeneracy $2j+1$.

**Definition 2.2 (Horizon configuration).** A *horizon configuration* is a finite
ordered list $\ell = ((k_1, M_1), \dots, (k_N, M_N))$ of pairs with $k_i \ge 1$ and
$M_i \in \mathcal{L}(k_i)$. Its *area* is $\mathrm{ar}(\ell) := \sum_i k_i$ and its
*projection* is $\mathrm{pr}(\ell) := \sum_i M_i$.

Ordering the punctures is the standard convention in this counting: punctures are
attached to distinguishable spin-network edges.

**Definition 2.3 (Microstate count).** Let $\mathcal{H}(A)$ be the (finite) set of
horizon configurations of area $A$, and set $W(A) := |\mathcal{H}(A)|$.

Equivalently, $\mathcal{H}(0) = \{()\}$ and
$$\mathcal{H}(A+1) = \bigsqcup_{i=0}^{A} \ \bigsqcup_{M \in \mathcal{L}(i+1)}
\bigl\{\, (i+1, M) :: \ell \ :\ \ell \in \mathcal{H}(A-i)\,\bigr\},$$
the disjointness being clear because the head of the list determines $(i,M)$. This
recursive description enumerates precisely the configurations of Definition 2.2.

Small values: $W(0)=1$, $W(1)=2$, $W(2)=7$, $W(3)=24$, $W(4)=82$, $W(5)=280$,
$W(6)=956$, $W(7)=3264$, $W(8)=11144$, $W(9)=38048$.

### 2.2 Entropy

**Definition 2.4.** The microcanonical (Boltzmann) entropy of the horizon at area
$A$ is $S(A) := \log W(A)$, and the *entropy density* is
$\lambda := \log(2+\sqrt2)$ (whose meaning is justified by Theorem 4.2).

---

## 3. Exact solution of the counting problem

### 3.1 The renewal recursion

**Proposition 3.1 (Renewal recursion).** For every $A \ge 0$,
$$W(A+1) = \sum_{i=0}^{A} (i+2)\, W(A-i) \;=\; \sum_{j=0}^{A} (A-j+2)\,W(j).$$

*Proof sketch.* Split $\mathcal{H}(A+1)$ by the label $i+1$ and magnetic number $M$
of the first puncture. The fibre over $(i, M)$ is the image of $\mathcal{H}(A-i)$
under $\ell \mapsto (i+1,M) :: \ell$, which is injective, so the fibre has
cardinality $W(A-i)$. There are $|\mathcal{L}(i+1)| = i+2$ choices of $M$. Summing
the disjoint union gives the first form; reindexing $j = A-i$ gives the second. $\square$

### 3.2 Collapse to a finite recursion

The key structural observation is that the coefficient $A-j+2$ in
Proposition 3.1 is *affine* in $A$, so a single difference removes the convolution.

**Lemma 3.2 (Three-term form).** For every $A \ge 1$,
$$W(A+1) = 3W(A) + \sum_{j=0}^{A-1} W(j).$$

*Proof sketch.* Write $A = m+1$. In $W(A+1) = \sum_{j \le A}(A-j+2)W(j)$, isolate
the top term $j=A$, which contributes $2W(A)$. For $j \le A-1$ use
$(m+1-j+2) = (m-j+2) + 1$, so the remaining sum splits as
$\sum_{j\le m}(m-j+2)W(j) + \sum_{j \le m} W(j) = W(m+1) + \sum_{j\le m}W(j)$ by
Proposition 3.1 applied at $m$. Recombining, and noting $W(m+1) = W(A)$, gives
$W(A+1) = 2W(A) + W(A) + \sum_{j \le A-1}W(j)$. $\square$

**Theorem 3.3 (Finite linear recursion).** For every $A \ge 1$,
$$W(A+2) + 2\,W(A) = 4\,W(A+1).$$

*Proof.* Apply Lemma 3.2 at $A$ and at $A+1$:
$W(A+1) = 3W(A) + \Sigma_{A-1}$ and $W(A+2) = 3W(A+1) + \Sigma_A$, where
$\Sigma_n := \sum_{j\le n}W(j)$. Since $\Sigma_A = \Sigma_{A-1} + W(A)$,
subtracting yields $W(A+2) = 3W(A+1) + (W(A+1) - 3W(A)) + W(A) = 4W(A+1) - 2W(A)$. $\square$

This is a genuinely nontrivial collapse: the renewal recursion has infinite order,
yet the sequence satisfies a linear recursion of order two. The mechanism is that
the generating function of the degeneracies, $\sum_{k\ge1}(k+1)x^k =
(1-x)^{-2} - 1$, is *rational*; the renewal equation $\hat W(x) =
1/(1 - \sum_k \deg(k)x^k)$ therefore has a rational solution with denominator of
degree two. Theorem 3.3 is that fact proved combinatorially.

### 3.3 The closed form

Let $s := 2+\sqrt2$ and $s' := 2-\sqrt2$ be the roots of $x^2 - 4x + 2$, so
$s + s' = 4$, $ss' = 2$, $s^2 = 4s-2$, $s'^2 = 4s'-2$, and $0 < s' < 1 < s$.

**Theorem 3.4 (Exact closed form).** For every $A \ge 1$,
$$4\,W(A) = (1+\sqrt2)\,s^A + (1-\sqrt2)\,s'^A.$$

*Proof sketch.* Both sides satisfy the same order-two recursion for $A \ge 1$
(the right-hand side because $s, s'$ are roots of the characteristic polynomial),
so it suffices to verify $A=1$ and $A=2$. At $A=1$: $(1+\sqrt2)(2+\sqrt2) +
(1-\sqrt2)(2-\sqrt2) = (4+3\sqrt2) + (4-3\sqrt2) = 8 = 4W(1)$. At $A=2$:
$(1+\sqrt2)(6+4\sqrt2) + (1-\sqrt2)(6-4\sqrt2) = (14+10\sqrt2)+(14-10\sqrt2) = 28
= 4W(2)$. A two-step induction (carrying the pair of consecutive values) then
closes. $\square$

Note $A \ge 1$ is necessary: the right-hand side at $A=0$ equals $2$, whereas
$4W(0) = 4$. The renewal recursion links $W(1)$ to $W(0)$ but the linear recursion
only takes over from $A = 1$.

**Corollary 3.5 (Two-sided bound).** For $A \ge 1$,
$$\frac{s^A}{2} \;\le\; W(A) \;\le\; s^A.$$

*Proof sketch.* $4W(A) = (1+\sqrt2)s^A + (1-\sqrt2)s'^A$ with $1 < \sqrt2 < 2$ and
$0 < s'^A \le s^A$. The upper bound follows from
$(1+\sqrt2)s^A + (1-\sqrt2)s'^A \le (1+\sqrt2)s^A \le 4s^A$ (using $1-\sqrt2<0$
and $1+\sqrt2 < 4$ — more precisely $2.415 < 4$). The lower bound follows from
$(1+\sqrt2)s^A + (1-\sqrt2)s'^A \ge (1+\sqrt2)s^A - (\sqrt2-1)s^A = 2s^A$. $\square$

---

## 4. The area law and the area quantum

### 4.1 Bounded defect

**Theorem 4.1 (Area law with bounded defect).** For every $A \ge 1$,
$$\bigl|\,S(A) - A\lambda\,\bigr| \le \log 2, \qquad \lambda = \log(2+\sqrt2).$$

*Proof.* Take logarithms in Corollary 3.5: $A\lambda - \log 2 \le S(A) \le A\lambda$. $\square$

**Theorem 4.2 (Bekenstein–Hawking area law).**
$$\lim_{A\to\infty} \frac{S(A)}{A} = \lambda = \log(2+\sqrt2) \approx 1.227947.$$

*Proof.* $|S(A)/A - \lambda| \le (\log 2)/A \to 0$. $\square$

The entropy is proportional to the *area*, not to any notion of enclosed volume,
and the constant of proportionality is explicit.

### 4.2 The exact subleading constant

Theorem 4.1 leaves the correction unspecified within a band of width $\log 2$. The
closed form determines it completely. Put
$$\theta := \frac{s'}{s} = \frac{2-\sqrt2}{2+\sqrt2} = 3 - 2\sqrt2 \approx 0.171573.$$

**Proposition 4.3.** For $A \ge 1$,
$$\frac{W(A)}{s^A} = \frac{1+\sqrt2}{4} + \frac{1-\sqrt2}{4}\,\theta^A,
\qquad\text{hence}\qquad
\left| \frac{W(A)}{s^A} - \frac{1+\sqrt2}{4} \right| \le \frac{\sqrt2-1}{4}\,\theta^A.$$

*Proof.* Divide Theorem 3.4 by $4s^A$. $\square$

**Theorem 4.4 (No logarithmic correction).**
$$S(A) - A\lambda \;\longrightarrow\; \log\frac{1+\sqrt2}{4} \approx -0.504921,$$
and the convergence is exponentially fast with ratio $\theta$.

*Proof.* $S(A) - A\lambda = \log(W(A)/s^A)$; apply Proposition 4.3 and continuity
of $\log$ at $(1+\sqrt2)/4 > 0$. $\square$

This is the precise sense in which the *unconstrained* horizon ensemble has no
logarithmic correction: the subleading term is an explicit constant. Any
$-\tfrac12\log A$ term in the physical entropy must therefore originate in the
projection constraint (Section 6), not in the counting itself.

### 4.3 Fixing the area quantum

Suppose the physical horizon area is $A_{\text{phys}} = \gamma A$ for a constant
$\gamma > 0$ (the analogue of the Barbero–Immirzi parameter, which sets the size
of an elementary area quantum).

**Theorem 4.5 (Uniqueness of the Bekenstein–Hawking normalisation).** For
$\gamma > 0$,
$$\lim_{A\to\infty}\frac{S(A)}{\gamma A} = \frac14
\qquad\Longleftrightarrow\qquad
\gamma = 4\lambda = 4\log(2+\sqrt2) \approx 4.911788.$$

*Proof.* By Theorem 4.2, $S(A)/(\gamma A) \to \lambda/\gamma$. Uniqueness of
limits gives $\lambda/\gamma = 1/4$ iff $\gamma = 4\lambda$. $\square$

### 4.4 The intrinsic characterisation

**Theorem 4.6 (Isolated-horizon characteristic equation).** With
$x_c := 1/(2+\sqrt2) = 1 - \tfrac{\sqrt2}{2} \approx 0.292893$,
$$\sum_{k \ge 1} (k+1)\, x_c^{\,k} = 1.$$

*Proof sketch.* For $0<x<1$, $\sum_{k\ge0}(k+1)x^k = (1-x)^{-2}$, so
$\sum_{k\ge1}(k+1)x^k = (1-x)^{-2} - 1$. Setting this equal to $1$ gives
$(1-x)^2 = \tfrac12$, i.e. $x = 1-\tfrac{\sqrt2}{2}$. Rationalising,
$1/(2+\sqrt2) = (2-\sqrt2)/2 = 1 - \sqrt2/2$. (A fully rigorous derivation splits
$(k+2)x^{k+1} = x\cdot k x^k + 2x\cdot x^k$ and uses the two standard geometric
sums $\sum kx^k = x/(1-x)^2$ and $\sum x^k = (1-x)^{-1}$.) $\square$

This is the equation that appears in the Ashtekar–Baez–Corichi–Krasnov state
counting: the entropy density is $-\log x_0$ for the unique root $x_0 \in (0,1)$.
Section 5 proves that this is a general theorem, not a coincidence of this model.

---

## 5. Universality: an arbitrary puncture model

### 5.1 Setup

**Definition 5.1.** Let $\deg : \mathbb{N} \to \mathbb{N}$ be a *degeneracy
function*, assigning to each area $k \ge 1$ the number $\deg(k)$ of internal
states of a puncture of area $k$. A *generalised configuration* is a finite list
$((k_1,a_1),\dots,(k_N,a_N))$ with $k_i \ge 1$ and $0 \le a_i < \deg(k_i)$; its
area is $\sum_i k_i$. Let $W_{\deg}(A)$ be the number of such lists of area $A$.

The concrete model of Section 2 is the case $\deg(k) = k+1$: indeed the two
counting problems are in bijection, so $W_{\deg}(A) = W(A)$ for $\deg(k)=k+1$.

Standing hypotheses: $\deg(1) \ge 1$ (minimal punctures exist) and $\deg(k) \le
B^k$ for some $B \in \mathbb{N}$ (at most exponential degeneracies).

### 5.2 Existence of the density

**Lemma 5.2 (Supermultiplicativity).** $W_{\deg}(n)\,W_{\deg}(m) \le W_{\deg}(n+m)$.

*Proof sketch.* Concatenation $(\ell, \ell') \mapsto \ell \,\|\, \ell'$ maps
configurations of areas $n$ and $m$ to configurations of area $n+m$, and is
injective because $n$ determines where to cut. $\square$

**Lemma 5.3 (Elementary bounds).** $\deg(1)^A \le W_{\deg}(A) \le (2B)^A$.

*Proof sketch.* Lower: the $\deg(1)^A$ lists of $A$ minimal punctures all have area
$A$. Upper: a configuration of area $A$ is determined by a composition of $A$
(there are $2^{A-1}$ of them) together with internal labels, of which there are at
most $\prod_i B^{k_i} = B^A$. $\square$

**Theorem 5.4 (Universal area law).** The limit
$$L := \lim_{A\to\infty} \frac{\log W_{\deg}(A)}{A}$$
exists, is finite, and satisfies $\log \deg(1) \le L \le \log(2B)$.

*Proof sketch.* $-\log W_{\deg}$ is subadditive by Lemma 5.2 and is bounded below
linearly by Lemma 5.3, so Fekete's subadditive lemma applies and gives convergence
to the supremum $\sup_A \log W_{\deg}(A)/A$. The bracket is Lemma 5.3. $\square$

For $\deg(k) = k+1$ this recovers $L = \lambda = \log(2+\sqrt2)$, and the bracket
with $B = 2$ reads $\log 2 \le \log(2+\sqrt2) \le \log 4$, which is correct.

### 5.3 The characteristic root determines the density

**Definition 5.5.** The *characteristic function* of a model is
$f(x) := \sum_{k\ge1} \deg(k)\, x^k$, and a *characteristic root* is a positive
$r$ with $f(r) = 1$.

For finitely supported models $f$ is a polynomial with nonnegative coefficients,
$f(0)=0$, $f$ strictly increasing on $[0,\infty)$ where nontrivial, and $f(1) \ge
\deg(1) \ge 1$; hence a characteristic root exists, lies in $(0,1]$, and is unique.

**Theorem 5.6 (Characteristic-root theorem).** If $r > 0$ satisfies
$\sum_{k\ge1}\deg(k)r^k = 1$, then $L = -\log r$. No finite-support hypothesis is
needed.

*Proof sketch, finite support.* Two halves.

*Upper bound* $W_{\deg}(A) \le r^{-A}$: strong induction. Assuming
$W_{\deg}(A-k) \le r^{-(A-k)}$ for all $k$, the renewal recursion gives
$$W_{\deg}(A) = \sum_{k\ge1}\deg(k)W_{\deg}(A-k)
\le \sum_{k\ge1}\deg(k)\,r^{-(A-k)} = r^{-A}\sum_{k\ge1}\deg(k)r^k = r^{-A}.$$
The characteristic equation is *exactly* what makes the induction close.

*Lower bound.* Put $m(A) := W_{\deg}(A)\,r^A$, so $m(0)=1$, $m(A) \le 1$, and the
renewal recursion becomes $m(A) = \sum_{k\ge1} p_k\, m(A-k)$ with weights
$p_k := \deg(k)r^k \ge 0$ satisfying $\sum_k p_k = 1$. Thus each $m(A)$ is a convex
combination (an average) of earlier values, so $\min_{j \le A} m(j)$ is
nonincreasing in $A$; with $p_1 = \deg(1)r \ge r > 0$ one gets a uniform positive
lower bound $m(A) \ge c > 0$ over any window of length equal to the support size,
and this propagates. Hence $\log m(A)/A$ is squeezed between $\log c / A \to 0$
and $0$, giving $\log W_{\deg}(A)/A \to -\log r$.

*Infinite support.* Truncate: let $\deg_K(k) := \deg(k)$ for $k \le K$ and $0$
otherwise, with root $r_K$ and density $L_K$. The upper bound $W_{\deg}(A) \le
r^{-A}$ survives verbatim because only *partial* sums of the characteristic series
are used and they are bounded by the total, $1$. For the matching lower bound one
shows that for any $x > r$ the truncated characteristic polynomials eventually
exceed $1$ — either the series converges at $x$, in which case strict termwise
comparison gives $f(x) > f(r) = 1$, or it diverges and its partial sums tend to
$\infty$. Hence $r_K \downarrow r$, and $L_K = -\log r_K \uparrow -\log r$ while
$L_K \le L \le -\log r$; squeezing gives $L = -\log r$. $\square$

**Corollary 5.7.** For the concrete model, any positive solution $y$ of
$\sum_{k\ge1}(k+1)y^k = 1$ satisfies $\lambda = -\log y$. Combined with
Theorem 4.6 this identifies $\lambda = \log(2+\sqrt2)$ intrinsically.

### 5.4 Rigidity of the density

**Theorem 5.8 (Strict monotonicity / Barbero–Immirzi rigidity).** If
$\deg \le \deg'$ pointwise with strict inequality somewhere (and both satisfy the
standing hypotheses), then $L(\deg) < L(\deg')$.

*Proof sketch.* Pointwise increase makes $f$ pointwise larger and strictly larger
at the relevant point, so the root strictly decreases: $r' < r$. Hence
$L' = -\log r' > -\log r = L$. For infinite support one applies the same argument
to sufficiently large truncations. $\square$

Physically: the area quantum $\gamma = 4L$ that reproduces $S = A_{\text{phys}}/4$
is *not* universal — it moves strictly whenever the microscopic spectrum of
puncture degeneracies changes. Fixing $\gamma$ therefore requires committing to a
specific microscopic model.

### 5.5 The positivity dichotomy

**Lemma 5.9 (Finite certificate).** If some area $m \ge 1$ supports at least two
microstates, $W_{\deg}(m) \ge 2$, then $L \ge (\log 2)/m > 0$.

*Proof sketch.* Iterating Lemma 5.2 gives $W_{\deg}(m)^n \le W_{\deg}(nm)$, so
$2^n \le W_{\deg}(nm)$ and $\log W_{\deg}(nm)/(nm) \ge (\log 2)/m$; pass to the
limit along the subsequence $nm$. $\square$

**Lemma 5.10 (The degenerate model).** If $\deg(1) = 1$ and $\deg(k) = 0$ for all
$k \ge 2$, then the unique configuration of area $A$ is the list of $A$ minimal
punctures, so $W_{\deg}(A) = 1$ for all $A$ and $L = 0$.

**Theorem 5.11 (Rigidity of the area law).** Under the standing hypotheses,
$$L > 0 \iff \bigl(\deg(1) \ge 2 \ \text{ or } \ \exists k \ge 2 : \deg(k) \ge 1\bigr),$$
i.e. $L > 0$ unless the model is the single degenerate one of Lemma 5.10.
Consequently every non-degenerate model obeys a genuine two-sided extensive law
$cA \le \log W_{\deg}(A) \le CA$ with $0 < c \le C < \infty$: no model in this
class has sub-extensive entropy, and none has a volume law.

*Proof sketch.* ($\Leftarrow$) A non-degenerate model has an area with two
distinct microstates: if $\deg(1) \ge 2$ take $m=1$; if $\deg(k)\ge1$ for some
$k\ge2$ take $m = k$ and compare the single puncture of area $k$ with the list of
$k$ minimal punctures — these are distinct, having different lengths. Apply
Lemma 5.9. ($\Rightarrow$) Contrapositive is Lemma 5.10. $\square$

### 5.6 Effective computability of the density

**Theorem 5.12 (Truncation rate).** Assume $\deg(k) \le B^k$ and $Br < 1$, where
$r$ is the characteristic root. Then $r \le r_K$ and
$$0 \le L - L_K \le \frac{B}{1-Br}\,(Br)^K.$$

*Proof sketch.* The characteristic tail is geometric:
$1 - \sum_{k\le K}\deg(k)r^k = \sum_{k>K}\deg(k)r^k \le \sum_{k>K}(Br)^k =
(Br)^{K+1}/(1-Br)$. Since $f_K(r_K) = 1$ and $f_K$ has derivative at least
$\deg(1) \ge 1$ near $r$, the linear term of $f_K$ converts the tail bound into
$r_K - r \le (Br)^{K+1}/(1-Br)$. Finally $L - L_K = \log(r_K/r) \le (r_K-r)/r$. $\square$

**Corollary 5.13 (A concrete certificate).** For the concrete model
($\deg(k)=k+1 \le 2^k$, so $B=2$, $r = x_c$, $Br = 2-\sqrt2 \approx 0.5858 < 1$),
$$0 \le \lambda - L_K \le \frac{2}{1-2x_c}\,(2x_c)^K \approx 4.83 \times (0.5858)^K.$$

So the entropy density — hence the Bekenstein–Hawking area quantum
$\gamma = 4\lambda$ — is certified to accuracy $\varepsilon$ by the finite model
with $K = O(\log(1/\varepsilon))$ puncture types. Together with strict
monotonicity of the truncated densities (Theorem 5.8), $L$ is a genuinely
computable real number with two-sided effective bounds.

---

## 6. The projection (Gauss) constraint

### 6.1 Constrained counting

Physically an admissible horizon state must be a gauge singlet: the magnetic
numbers must cancel, $\sum_i m_i = 0$, i.e. $\mathrm{pr}(\ell) = 0$.

**Definition 6.1.** Let $D(A,M) := |\{\ell \in \mathcal{H}(A) : \mathrm{pr}(\ell) =
M\}|$ be the *projection profile*, and $Z(A) := D(A,0)$ the *constrained count*.

Since $|\mathrm{pr}(\ell)| \le \mathrm{ar}(\ell)$, the profile is supported on
$|M| \le A$, and
$$W(A) = \sum_{M=-A}^{A} D(A,M).$$

**Proposition 6.2 (Symmetry).** $D(A,-M) = D(A,M)$.

*Proof sketch.* The puncturewise flip $(k,M) \mapsto (k,-M)$ is an involution of
$\mathcal{H}(A)$ (each $\mathcal{L}(k)$ is symmetric) negating the projection. $\square$

**Proposition 6.3 (Parity superselection).** $Z(A) = 0$ for odd $A$.

*Proof sketch.* $M_i \equiv k_i \pmod 2$, so $\mathrm{pr}(\ell) \equiv
\mathrm{ar}(\ell) \pmod 2$; for odd $A$ the projection is odd and cannot be $0$. $\square$

### 6.2 The concatenation injection and the sharp bound

**Proposition 6.4 (Summed concatenation injection).**
$$\sum_{M=-A}^{A} D(A,M)^2 \;\le\; Z(2A).$$

*Proof sketch.* For each $M$, gluing a configuration of area $A$ and projection $M$
to one of area $A$ and projection $-M$ produces a configuration of area $2A$ and
projection $0$. The map is injective simultaneously over all $M$: the concatenated
list determines the cut point (after $A$ quanta of area) and hence both factors,
and $M$ is recovered as the projection of the first factor. Counting the domain
gives $\sum_M D(A,M)D(A,-M) = \sum_M D(A,M)^2$ by Proposition 6.2. $\square$

**Theorem 6.5 (Sharp constraint bound).**
$$W(A)^2 \;\le\; (2A+1)\, Z(2A).$$

*Proof.* Cauchy–Schwarz on $W(A) = \sum_{|M|\le A} D(A,M)$, a sum of $2A+1$ terms:
$W(A)^2 \le (2A+1)\sum_M D(A,M)^2 \le (2A+1)Z(2A)$ by Proposition 6.4. $\square$

This improves by one power of $(2A+1)$ on the elementary pigeonhole bound
$W(A) \le (2A+1)\max_M D(A,M)$, which only yields $W(A)^2 \le (2A+1)^2 Z(2A)$.

**Corollary 6.6 (Two-sided bounds and logarithmic defect).** For $A \ge 1$,
$$\frac{(2+\sqrt2)^{2A}}{4\,(2A+1)} \;\le\; Z(2A) \;\le\; (2+\sqrt2)^{2A},$$
so the entropy defect caused by the constraint satisfies
$$0 \le 2A\lambda - \log Z(2A) \le \log 4 + \log(2A+1).$$

*Proof sketch.* Lower: combine Theorem 6.5 with $W(A) \ge s^A/2$. Upper: $Z(2A)
\le W(2A) \le s^{2A}$. Take logarithms. $\square$

**Theorem 6.7 (Constrained area law).** The constrained entropy obeys the same
area law with the same density:
$$\lim_{n\to\infty} \frac{\log Z(2n)}{2n} = \lambda = \log(2+\sqrt2).$$

*Proof.* Divide Corollary 6.6 by $2n$; the defect is $O(\log n)$. $\square$

Hence the Gauss constraint is invisible at leading order: it can shift the entropy
by at most a logarithm and it never touches the area quantum.

### 6.3 A refuted conjecture

A natural strengthening would be *unimodality of the projection profile*,
$D(A,M) \le D(A,0)$ for all $M$, which would immediately halve the defect. It is
false as stated.

**Proposition 6.8 (Counterexample).** At $A=1$ one has $D(1,\pm1) = 1$ but
$D(1,0) = Z(1) = 0$ by Proposition 6.3. Hence $D(A,M) \le D(A,0)$ fails.

The obstruction is exactly the parity superselection rule: unimodality can hold at
best within a parity class, i.e. for even $A$. Notably, Theorem 6.5 achieves the
$\log A$ defect that unimodality was intended to deliver, by a different and much
cheaper route.

---

## 7. Canonical thermodynamics

### 7.1 The differential first law

**Theorem 7.1 (Ratio convergence).** $\displaystyle \lim_{A\to\infty}
\frac{W(A+1)}{W(A)} = 2+\sqrt2$.

*Proof sketch.* Write $q := s'/s = \theta \in (0,1)$, $a := 1+\sqrt2$,
$b := 1-\sqrt2$. By Theorem 3.4, $W(A+1)/W(A) = (as + bs'\,q^A)/(a + b\,q^A) \to
as/a = s$. $\square$

**Theorem 7.2 (Differential area law).** $S(A+1) - S(A) \to \log(2+\sqrt2)$.

This is strictly stronger than the Cesàro statement $S(A)/A \to \lambda$ of
Theorem 4.2.

**Corollary 7.3 (Differential first law).** With the Bekenstein–Hawking
normalisation $\gamma = 4\log(2+\sqrt2)$, the entropy response to a unit increase
in physical area tends to $1/4$: $dS/dA_{\text{phys}} = 1/4$.

### 7.2 The partition function and the Hagedorn temperature

**Definition 7.4.** With fugacity $x = e^{-\beta}$ per area quantum, the canonical
partition function is $\mathcal{Z}(x) := \sum_{A \ge 0} W(A)\,x^A$.

**Theorem 7.5 (Convergence and closed form).** $\mathcal{Z}(x)$ converges if and
only if $x < x_c := 1/(2+\sqrt2)$, and for $0 \le x < x_c$,
$$\mathcal{Z}(x) = \frac{(1-x)^2}{2x^2 - 4x + 1}.$$

*Proof sketch.* Convergence: $W(A) \asymp s^A$ up to a factor $2$, so the radius of
convergence is $1/s = x_c$; at and beyond $x_c$ the terms do not tend to $0$
(indeed $W(A)x_c^A \ge 1/2$ for $A \ge 1$). Closed form: sum
$4W(A) = a s^A + b s'^A$ against $x^A$ using two geometric series and correct for
the $A=0$ term, or equivalently invoke the renewal identity
$\mathcal{Z}(x) = 1/(1 - \sum_{k\ge1}(k+1)x^k) = 1/(2 - (1-x)^{-2})$, which
simplifies to $(1-x)^2/(2x^2-4x+1)$. $\square$

The denominator $2x^2 - 4x + 1$ has roots $1 \pm \tfrac{\sqrt2}{2}$; the relevant
one is $x_c = 1 - \tfrac{\sqrt2}{2}$. So $\mathcal{Z}$ has a **simple pole** at the
critical fugacity: a Hagedorn transition with limiting temperature
$$T_H = \frac{1}{\log(2+\sqrt2)} \approx 0.814367$$
per area quantum. Above $T_H$ the exponential growth of the density of states
outruns the Boltzmann suppression and no equilibrium exists.

**Proposition 7.6 (Microcanonical origin of the divergence).** For $A \ge 1$,
$W(A)\,x_c^A \ge 1/2$. Hence the partial sums at $x_c$ grow at least linearly and
$\mathcal{Z}(x) \to \infty$ as $x \uparrow x_c$.

*Proof.* $W(A) \ge s^A/2$ and $x_c^A = s^{-A}$. $\square$

### 7.3 Exact moment hierarchy and pole structure

Define the canonical moments $\langle A^p\rangle(x) := \mathcal{Z}(x)^{-1}
\sum_A A^p W(A) x^A$, and the cumulants $\kappa_1 = \langle A\rangle$,
$\kappa_2 = \operatorname{Var}(A)$, $\kappa_3 = \langle (A - \langle A\rangle)^3\rangle$.

**Theorem 7.7 (Weighted sums in closed form).** For $0 \le x < x_c$,
$$\sum_A A\,W(A)\,x^A = \frac{2x(1-x)}{(2x^2-4x+1)^2},$$
$$\sum_A A^2\,W(A)\,x^A = \frac{2x\,(4x^3-6x^2+2x+1)}{(2x^2-4x+1)^3},$$
$$\sum_A A^3\,W(A)\,x^A = \frac{2x\,(1+12x-20x^2+20x^4-16x^5)}{(2x^2-4x+1)^4}.$$

*Proof sketch.* Insert the closed form $4W(A) = a s^A + b s'^A$ and use the
standard identities $\sum_n n\,\rho^n = \rho/(1-\rho)^2$,
$\sum_n n^2\rho^n = \rho(1+\rho)/(1-\rho)^3$ and
$\sum_n n^3\rho^n = \rho(1+4\rho+\rho^2)/(1-\rho)^4$ at $\rho = sx$ and
$\rho = s'x$, both of modulus $<1$. The third identity is obtained from the
binomial transform $\sum_n \binom{n+3}{3}\rho^n = (1-\rho)^{-4}$ together with the
polynomial identity $n^3 = 6\binom{n+3}{3} - 12\binom{n+2}{2} + 7n + 6$. Combining
the two geometric branches and using $(1-sx)(1-s'x) = 1 - 4x + 2x^2$ produces the
stated rational functions. $\square$

**Theorem 7.8 (Cumulants in closed form).** For $0 < x < x_c$,
$$\kappa_1(x) = \frac{2x}{(2x^2-4x+1)(1-x)},$$
$$\kappa_2(x) = \frac{2x\,(4x^3-6x^2+1)}{(2x^2-4x+1)^2(1-x)^2},$$
$$\kappa_3(x) = \frac{2x\,(1+5x-36x^2+56x^3-4x^4-36x^5+16x^6)}{(2x^2-4x+1)^3(1-x)^3}.$$

**Theorem 7.9 (Exact pole orders and residues).** As $x \uparrow x_c$,
$$(x_c-x)\,\kappa_1(x) \to x_c, \qquad
(x_c-x)^2\,\kappa_2(x) \to x_c^2, \qquad
(x_c-x)^3\,\kappa_3(x) \to 2\,x_c^3 = 2!\,x_c^3.$$
Hence the poles have orders exactly $1$, $2$, $3$.

*Proof sketch.* Factor $2x^2 - 4x + 1 = 2(x-x_c)(x-x_+)$ with $x_+ = 1 +
\tfrac{\sqrt2}{2}$, so near $x_c$ one has $2x^2-4x+1 = 2\sqrt2\,(x_c-x)\,(1+o(1))$,
and $1 - x_c = \tfrac{\sqrt2}{2}$. For $\kappa_1$: the denominator behaves like
$2\sqrt2(x_c-x)\cdot\tfrac{\sqrt2}{2} = 2(x_c-x)$ and the numerator tends to
$2x_c$, giving residue $x_c$. For $\kappa_2$ the denominator behaves like
$8(x_c-x)^2\cdot\tfrac12 = 4(x_c-x)^2$ and the numerator tends to
$2x_c(4x_c^3-6x_c^2+1)$; the algebraic identity $4x_c^3-6x_c^2-2x_c+1=0$ (verified
from $x_c^2 = \tfrac32-\sqrt2$, $x_c^3 = \tfrac52 - \tfrac74\sqrt2$) turns this
into $4x_c^2\cdot(x_c-x)^{-2}\cdot\tfrac14\cdot 4$, i.e. residue $x_c^2$. The
third cumulant is analogous with the sextic numerator. $\square$

**Theorem 7.10 (Stability and skewness).** For all $0 < x < x_c$, $\kappa_2(x) > 0$
and $\kappa_3(x) > 0$. Hence the horizon specific heat $C = \beta^2 \kappa_2$ is
strictly positive — the canonical horizon is thermodynamically stable below the
Hagedorn temperature — and the area distribution is strictly right-skewed at every
subcritical temperature.

**Theorem 7.11 (Ensemble inequivalence).** $\kappa_1(x) \to \infty$ and
$\kappa_2(x) \to \infty$ as $x \uparrow x_c$.

*Proof sketch.* Either from Theorem 7.9, or microcanonically: for any $M$,
$\kappa_1(x) \ge M\bigl(1 - \Sigma_M(x)/\mathcal{Z}(x)\bigr)$ where
$\Sigma_M(x) = \sum_{A<M}W(A)x^A \le \Sigma_M(x_c)$ is bounded; since
$\mathcal{Z}(x)\to\infty$ (Proposition 7.6), the bracket tends to $1$ and
$\liminf \kappa_1 \ge M$ for every $M$. $\square$

Consequently no finite horizon area can be prepared canonically at temperatures
approaching $T_H$, while the microcanonical description remains perfectly well
defined at every area: the two ensembles are inequivalent, as is typical for
self-gravitating and long-range-interacting systems.

The pattern $\kappa_m \sim (m-1)!\,x_c^m/(x_c-x)^m$ for $m = 1,2,3$ is exactly the
cumulant hierarchy of a geometric/exponential distribution with mean
$x_c/(x_c-x)$: near criticality the canonical area distribution becomes
asymptotically exponential.

---

## 8. Algorithms

Three computational primitives suffice to reproduce every numerical statement
above.

**(A) Exact microstate count.** Iterate $W(A+2) = 4W(A+1) - 2W(A)$ from
$W(0)=1$, $W(1)=2$ (note $W(2) = 7$ is consistent with the recursion started at
$A=0$ in this case, since $4\cdot2-2\cdot1 = 6 \ne 7$ — the recursion is valid only
from $A \ge 1$, so one seeds with $W(1)=2$, $W(2)=7$). Cost: $O(A)$ exact integer
operations; the numbers have $\Theta(A)$ digits, so $O(A^2)$ bit operations. This
is exponentially faster than evaluating the renewal convolution, which costs
$O(A^2)$ big-integer additions and multiplications.

**(B) Characteristic-root solver.** Given a degeneracy function and a truncation
level $K$, bisect on $[\epsilon, 1]$ for the unique root of
$f_K(x) = \sum_{k\le K}\deg(k)x^k = 1$; $f_K$ is strictly increasing with
$f_K(0)=0$, so bisection converges linearly ($O(\log(1/\varepsilon))$ evaluations,
each $O(K)$). Return $L_K = -\log r_K$. Theorem 5.12 converts $K$ into a rigorous
error bar on $L$.

**(C) Cumulant evaluator.** Evaluate the rational closed forms of Theorem 7.8
directly, or cross-check by truncating $\sum_A A^p W(A) x^A$ using (A). Both are
$O(N)$ for $N$ terms; agreement to machine precision certifies the closed forms
numerically.

---

## 9. Discussion

### 9.1 What the exact solution buys

The model is small enough to be solved completely, and the completeness has
consequences that asymptotic methods do not provide.

* The area law comes with a **uniform** error bound $\log 2$, valid at every area,
  not merely in a limit.
* The subleading term is *identified*, not merely bounded: it is the constant
  $\log\frac{1+\sqrt2}{4}$, approached at rate $\theta^A = (3-2\sqrt2)^A$. This
  cleanly separates the two candidate sources of a $-\tfrac12\log A$ correction and
  shows the counting itself contributes none.
* The Hagedorn structure is exact: pole orders and residues, not scaling exponents
  fitted to numerics.

### 9.2 Which features are universal

The universality results identify what survives beyond the specific degeneracy
$k+1$:

* *An area law always holds* (Theorem 5.4) — this is pure supermultiplicativity,
  i.e. the extensivity of horizons under concatenation, plus an exponential
  ceiling.
* *The density is always the characteristic root* (Theorem 5.6) — this is the
  general form of the Ashtekar–Baez–Corichi–Krasnov criticality condition.
* *The density is strictly spectrum-sensitive* (Theorem 5.8) — so the
  Barbero–Immirzi parameter is a genuinely microscopic quantity.
* *Extensivity is generic* (Theorem 5.11) — a single degenerate model separates the
  positive-density regime from triviality; there is no intermediate sub-extensive
  behaviour and no volume law.

What is *not* universal is the collapse to a finite-order recursion. That requires
the degeneracy generating function to be rational, which for $\deg(k)=k+1$ it is.
A model with, say, $\deg(k) = \lfloor e^{\sqrt k}\rfloor$ would still obey an area
law with density $-\log r$, but $W$ would satisfy no finite linear recursion and no
closed form of the above type would exist.

### 9.3 The Gauss constraint

The physically required singlet condition is often the technically hardest part of
horizon state counting. Here it is completely controlled at the level of the
leading term: the concatenation injection plus Cauchy–Schwarz gives
$W(A)^2 \le (2A+1)Z(2A)$, i.e. a logarithmic defect. The parity superselection
rule $Z(\text{odd}) = 0$ is a genuine structural feature of the constrained
ensemble and, incidentally, kills the naive unimodality conjecture for the
projection profile. Determining the *exact* constrained subleading term — whether
it is $-\tfrac12\log A$ + constant, as local-central-limit heuristics for the
projection profile suggest — remains open.

### 9.4 Physical reading

Interpreting $x = e^{-\beta}$ per area quantum, the results assemble into a
coherent thermodynamic picture. The horizon gas has a strictly positive specific
heat below $T_H = 1/\log(2+\sqrt2)$ and is therefore locally stable, but the
specific heat diverges at $T_H$ with a double pole and the mean area diverges with
a simple pole. This is the microscopic origin, within this model, of the familiar
statement that a black hole in a heat bath cannot be brought to arbitrary
temperature: past the Hagedorn point the horizon "runs away" to infinite area. The
inequivalence of the microcanonical and canonical ensembles is not a pathology of
the model but a feature it shares with realistic gravitating systems.

---

## 10. Future directions

1. **Exact constrained asymptotics.** Prove or refute
   $\log Z(2A) = 2A\lambda - \tfrac12\log A + c + o(1)$ for an explicit constant
   $c$. The natural route is a local central limit theorem for the projection
   profile $D(A,\cdot)$, whose variance should be linear in $A$.
2. **Parity-restricted unimodality.** Prove $D(2A,M) \le D(2A,0)$ for even areas,
   the corrected form of the refuted conjecture.
3. **Higher cumulants.** Establish $\kappa_m(x) \sim (m-1)!\,x_c^m/(x_c-x)^m$ for
   all $m$, i.e. that the canonical area distribution becomes asymptotically
   exponential at criticality. The cases $m = 1,2,3$ are settled with exact
   residues $x_c$, $x_c^2$, $2x_c^3$.
4. **Non-equidistant area spectra.** Replace the $k$-linear area by the exact
   $SU(2)$ spectrum $\propto \sqrt{j(j+1)}$. The area values are then irrational
   and incommensurable, so the microstate count is no longer supported on a
   lattice; the characteristic-equation formulation survives as a
   Laplace-transform criticality condition, but the recursion collapse does not.
5. **Rate of the truncation certificate under weaker growth.** Theorem 5.12
   assumes $Br < 1$. Determine the optimal truncation rate when $\deg$ saturates
   the exponential ceiling.
6. **Two-sided rigidity.** Quantify Theorem 5.8: give an explicit modulus
   $L(\deg') - L(\deg) \ge \phi(\deg' - \deg)$, converting the strict monotonicity
   into a stability estimate for the Barbero–Immirzi parameter.
7. **Finite-size corrections to the Hagedorn point.** Study the model on a horizon
   with a maximum spin, and determine how the pole at $x_c$ is smoothed into a
   finite-width crossover.

---

## 11. Summary of principal results

| Result | Statement |
|---|---|
| Renewal recursion | $W(A+1) = \sum_{i\le A}(i+2)W(A-i)$ |
| Finite linear recursion | $W(A+2) = 4W(A+1) - 2W(A)$, $A \ge 1$ |
| Closed form | $4W(A) = (1+\sqrt2)(2+\sqrt2)^A + (1-\sqrt2)(2-\sqrt2)^A$ |
| Two-sided bound | $(2+\sqrt2)^A/2 \le W(A) \le (2+\sqrt2)^A$ |
| Area law | $\|\log W(A) - A\log(2+\sqrt2)\| \le \log 2$; $S(A)/A \to \log(2+\sqrt2)$ |
| Subleading constant | $S(A) - A\log(2+\sqrt2) \to \log\frac{1+\sqrt2}{4}$, rate $(3-2\sqrt2)^A$ |
| Area quantum | $S/(\gamma A) \to 1/4 \iff \gamma = 4\log(2+\sqrt2)$ |
| Characteristic equation | $\sum_{k\ge1}(k+1)x^k = 1$ at $x = 1/(2+\sqrt2)$ |
| Universal area law | $L = \lim \log W_{\deg}(A)/A$ exists, $\log\deg(1) \le L \le \log 2B$ |
| Characteristic root | $\sum_k \deg(k)r^k = 1 \Rightarrow L = -\log r$ |
| Rigidity | $\deg \lneq \deg' \Rightarrow L(\deg) < L(\deg')$ |
| Positivity dichotomy | $L > 0$ unless $\deg(1)=1$, $\deg(k\ge2)=0$ |
| Truncation rate | $0 \le L - L_K \le \frac{B}{1-Br}(Br)^K$ |
| Constraint bound | $W(A)^2 \le (2A+1)Z(2A)$; defect $\le \log 4 + \log(2A+1)$ |
| Parity rule | $Z(A) = 0$ for odd $A$; unimodality of $D(A,\cdot)$ is false |
| Differential law | $S(A+1)-S(A) \to \log(2+\sqrt2)$; $dS/dA_{\text{phys}} = 1/4$ |
| Partition function | converges iff $x < x_c$; $\mathcal{Z}(x) = (1-x)^2/(2x^2-4x+1)$ |
| Hagedorn temperature | $T_H = 1/\log(2+\sqrt2) \approx 0.8144$ |
| Cumulant poles | orders $1,2,3$ with residues $x_c$, $x_c^2$, $2x_c^3$ |
| Stability | $\kappa_2 > 0$ and $\kappa_3 > 0$ subcritically; both diverge at $x_c$ |
| Ensemble inequivalence | $\langle A\rangle \to \infty$ as $x \uparrow x_c$ |
