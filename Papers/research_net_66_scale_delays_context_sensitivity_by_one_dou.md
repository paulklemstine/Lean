# The One-Octave Exchange Law for Knee Tables: Rigidity, Rate Identification, Stability, and the Grid Razor

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We study *knee tables*: two-parameter integer arrays $F(s,j)$ recording, for a family of
resource-limited predictors indexed by a scale ladder $s$ and a context ladder $j$, the
least resource budget at which retained quality clears a fixed gate. Motivated by a
budget sweep across two model scales and three context lengths, we isolate two purely
local axioms — an **exchange law** $F(s+1,j+1) = F(s,j)$ and a **boundary law**
$F(s+1,0)=F(s,0)$ — and prove that they are *rigid*: they force the entire table to be a
single chain translated by one octave per scale step, $F(s,j) = F(0,(j-s)^+)$. Rigidity
has two immediate corollaries which convert empirical hypotheses into structural
impossibilities: under context-monotonicity, scale can never increase the knee
(antitonicity in scale), and scale can never render a chain bounded or constant if the
base chain is unbounded or non-constant (no flattening). Consequently the only genuinely
empirical content of such a table is a single integer, the **exchange rate**.

We develop the full spectrum of rate-$p$ laws, $F(s+1,j+p)=F(s,j)$, prove rigidity, the
two impossibilities and a budget-table staircase at every rate, show every positive rate
is consistent, and prove the rate identifiable from one predicted chain. We then prove
that a $\varepsilon$-approximate table satisfies
$|F(s,j)-F(0,(j-s)^+)| \le \varepsilon s$ — linear, not exponential, error accumulation —
and that the rate remains uniquely identifiable whenever the base chain rises by at least
$\delta$ per octave and $\varepsilon < \delta$.

Finally we analyse what a *finite* budget sweep can honestly claim. For a measured row on
the grid $\{8,12,16,20,24,32\}$ at gate $0.98$ with readings
$(0.9597, 0.9715, 0.9785, 0.9817, 0.9846, 0.9867)$, we prove that the set of knees
consistent with the measurement across **all** monotone curves reproducing it is exactly
the half-open bracket $(16,20]$, and that a perturbation of size $0.0015$ (one standard
error) at every grid point admits a monotone curve with knee $16$ — so the left endpoint
of the bracket is not closed by the data. We exhibit an explicit population of $10{,}000$
demand-labelled prediction windows realising the row exactly, so the analysis rests on a
genuine demand profile rather than on six isolated numbers.

**Keywords:** knee chain, octave shift, exchange law, rigidity, budget table, staircase,
rate spectrum, grid bracket, monotone curve, stability under noise.

---

## 1. Introduction

### 1.1 The setting

A *sparsified predictor* replaces exhaustive access to a memory of past items with access
to a bounded number of them. Let $k \in \mathbb{N}$ denote the **budget** — the number of
memory items available at each prediction step. Let

$$A : \mathbb{N} \to [0,1], \qquad A(k) = \text{fraction of predictions retained at budget } k,$$

where "retained" means: the budget-$k$ predictor makes the same decision as the
unrestricted one. Two structural facts hold by construction:

* $A$ is **monotone**: $k \le k' \Rightarrow A(k) \le A(k')$;
* $A(k) = 1$ once $k$ exceeds the memory size.

Fix a **gate** $g \in (0,1]$, a quality bar. The central invariant is:

> **Definition 1 (Knee).** For a monotone $A$ and gate $g$ with $A(k)\ge g$ for some $k$,
> the **knee** is
> $$k^*(A,g) \;=\; \min\{ k \in \mathbb{N} : A(k) \ge g\}.$$

Two elementary properties are used throughout and follow at once from the definition of a
least element: $A(k^*) \ge g$ (attainment), and if $g \le A(k)$ then $k^* \le k$
(minimality). We also use the characterisation: if $g \le A(t)$ and $A(j) < g$ for all
$j < t$, then $k^*(A,g) = t$.

### 1.2 Two ladders

Contexts and model sizes both come in geometric ladders, so we index them
logarithmically.

> **Definition 2 (Octave).** Context length $\mathrm{ctx} = 512\cdot 2^{\,j}$; the integer
> $j\ge 0$ is the **octave**. Thus $j=0,1,2,3$ are contexts $512, 1024, 2048, 4096$.

> **Definition 3 (Knee chain).** A **chain** is a map $K:\mathbb{N}\to\mathbb{N}$; $K(j)$
> is the knee at octave $j$ for a fixed model and gate.

> **Definition 4 (Knee table).** For a scale ladder indexed by $s \ge 0$ (the model at
> index $s$ being $2^s$ times the base model in the relevant sense), a **knee table** is
> $F : \mathbb{N}\times\mathbb{N} \to \mathbb{N}$ with $F(s,\cdot)$ the chain at scale $s$.

### 1.3 The measurement and three hypotheses

The data motivating this work is a two-row table at gate $g = 0.98$:

| scale $s$ | octave $0$ (512) | octave $1$ (1024) | octave $2$ (2048) |
|---|---|---|---|
| $0$ (small) | $16$ | $20$ | $24$ |
| $1$ (large) | $16$ | $16$ | $20$ |

Three pre-registered hypotheses:

* **P1 (sensitivity).** The large model's flat run breaks upward at some context.
* **P2 (flattening).** Scale removes context sensitivity: the large chain is eventually
  constant.
* **P3 (amplification).** Scale increases sensitivity: at a common context the larger
  model needs a larger budget.

The data confirms P1 ($16 \to 20$ between octaves $1$ and $2$), refutes P2 (the flat run
ends), and refutes P3 ($20 < 24$ at octave $2$). The residual pattern is exact:

$$K_1(j+1) = K_0(j) \ \ \text{for all } j, \qquad K_1(0)=K_0(0).$$

The large-model chain is the small-model chain translated right by **one octave**. The
remainder of the paper takes this pattern as an axiom and asks what it forces.

---

## 2. The octave shift and the rigidity theorem

> **Definition 5 (Octave shift).** For a chain $K$ and $s\in\mathbb{N}$,
> $$(\sigma^s K)(j) \;=\; K\big((j-s)^+\big),$$
> where $(j-s)^+ = \max(j-s,0)$ is truncated subtraction.

Truncation is not a technicality: it encodes the modelling assumption that scale buys
*headroom*. A shifted chain is clamped at its boundary value below the base context
rather than extrapolated to contexts shorter than any measured.

> **Proposition 6 (Monoid action).** $\sigma^0 = \mathrm{id}$ and
> $\sigma^b(\sigma^a K) = \sigma^{a+b} K$. Scale acts on chains as the additive monoid
> $(\mathbb{N},+)$.

*Proof.* $((j-a)-b)^+ = (j-(a+b))^+$ for truncated subtraction. $\square$

> **Proposition 7 (Local laws of a shift).** For every chain $K$:
> $$\sigma^{s+1}K(j+1) = \sigma^{s}K(j), \qquad \sigma^{s+1}K(0) = \sigma^{s}K(0).$$
> Moreover $\sigma^s K$ is monotone whenever $K$ is.

*Proof.* $(j+1)-(s+1) = j-s$ as truncated subtraction on successors; and both boundary
terms equal $K(0)$. Monotonicity: $(a-s)^+ \le (b-s)^+$ when $a\le b$. $\square$

> **Proposition 8 (Rate identifiability, exact).** If $K$ is strictly increasing and
> $\sigma^a K = \sigma^b K$, then $a=b$.

*Proof.* Suppose $a<b$. Evaluating the hypothesis at $j=b$ gives $K(b-a) = K(0)$ with
$b-a>0$, contradicting strict monotonicity. Symmetrically for $b<a$. $\square$

Proposition 8 is what makes "one octave" a *measured constant* rather than a fitted
parameter: on a strictly increasing base chain, distinct shifts are distinguishable
everywhere.

> **Definition 9 (Scale family).** A **scale family** is a knee table $F$ such that
> 1. $F(0,\cdot)$ is monotone (context-monotonicity of the base chain);
> 2. **exchange law:** $F(s+1,j+1) = F(s,j)$ for all $s,j$;
> 3. **boundary law:** $F(s+1,0) = F(s,0)$ for all $s$.

> **Theorem 10 (Rigidity).** For every scale family $F$ and every $s$,
> $$F(s,\cdot) \;=\; \sigma^s\big(F(0,\cdot)\big), \qquad\text{i.e.}\qquad F(s,j) = F\big(0,(j-s)^+\big).$$

*Proof.* Induct on $s$. For $s=0$ the shift is the identity. Assume
$F(s,\cdot)=\sigma^s F(0,\cdot)$. At $j=0$ the boundary law gives
$F(s+1,0)=F(s,0)=F(0,0)=\sigma^{s+1}F(0,\cdot)(0)$. At $j = i+1$ the exchange law gives
$F(s+1,i+1)=F(s,i)=F(0,(i-s)^+)=F(0,((i+1)-(s+1))^+)$. $\square$

Rigidity says the table has exactly one functional degree of freedom. Measuring a second
scale is therefore not the estimation of a new function but a test of a prediction, and
the only number left free is the exchange rate (Section 4).

An immediate consequence: every chain in a scale family is monotone in context, since
each is a shift of the monotone base chain.

---

## 3. Two structural impossibilities

> **Theorem 11 (Antitonicity in scale; P3 is impossible).** In any scale family,
> $$F(s+1,j)\le F(s,j) \quad \text{for all } s,j,$$
> and more generally $F(t,j) \le F(s,j)$ whenever $s\le t$.

*Proof.* By rigidity, $F(t,j)=F(0,(j-t)^+)$ and $F(s,j)=F(0,(j-s)^+)$. Since $s\le t$
gives $(j-t)^+\le(j-s)^+$, monotonicity of the base chain concludes. $\square$

Thus "scale amplifies context sensitivity" is not merely false in the data; given the
exchange law and context-monotonicity, it is *unsatisfiable*.

> **Theorem 12 (No flattening; P2 is impossible).** Let $F$ be a scale family.
> 1. *(Unbounded form.)* If the base chain is unbounded — for every $b$ there is $j$ with
>    $F(0,j)>b$ — then for every scale $s$ and every $b$ there is $j$ with $F(s,j)>b$.
> 2. *(Non-constant form.)* If $F(0,j_0) > F(0,0)$ for some $j_0$, then for every $s$
>    there is $j$ with $F(s,j) > F(s,0)$.

*Proof.* Both by translation. If $j$ witnesses the base statement, then $j+s$ witnesses it
at scale $s$, because $((j+s)-s)^+ = j$ while $F(s,0)=F(0,0)$. $\square$

So the three-horn framing was, in hindsight, over-generous: **two of the three horns are
excluded by the shape of the law**. What the measurement genuinely had to do was not
adjudicate among three qualitatively different worlds but measure one integer.

---

## 4. The exchange-rate spectrum

Nothing in Definition 9 forces one octave per doubling.

> **Definition 13 (Rate-$p$ family).** For $p \ge 1$, a **rate-$p$ family** is a table $F$
> with $F(0,\cdot)$ monotone and
> $$F(s+1, j+p) = F(s,j) \quad \text{for all } s,j, \qquad F(s+1,i) = F(s,0) \quad \text{for } i<p.$$

Write $\sigma_p^s K (j) = K\big((j - ps)^+\big)$.

> **Theorem 14 (Rigidity at every rate).** For a rate-$p$ family,
> $F(s,j) = F\big(0,(j-ps)^+\big)$ for all $s,j$.

*Proof.* Induct on $s$. Fix $j$. If $j < p$, the boundary law gives
$F(s+1,j) = F(s,0) = F(0,0)$ by the inductive hypothesis, and
$(j - p(s+1))^+ = 0$ because $p \le p(s+1)$. If $j \ge p$, write $j = i+p$; the exchange
law gives $F(s+1,i+p) = F(s,i) = F(0,(i-ps)^+)$, and
$(i+p) - p(s+1) = i - ps$ as truncated subtraction since $p(s+1) = ps + p$. $\square$

> **Theorem 15 (The impossibilities persist).** In a rate-$p$ family: every chain is
> monotone; $F(s+1,j)\le F(s,j)$; and if the base chain is unbounded then so is every
> scaled chain.

*Proof.* Identical to Theorems 11 and 12 with $ps$ in place of $s$, using
$ps \le p(s+1)$ and the witness $j + ps$. $\square$

Hence the qualitative content — rigidity, no amplification, no flattening — is uniform
across the spectrum; the rate is the only discriminating quantity.

> **Theorem 16 (Consistency of every rate).** For every $p\ge 1$ and every monotone chain
> $K$, the assignment $F(s,\cdot) = \sigma_p^s K$ is a rate-$p$ family.

*Proof.* Monotonicity is inherited through truncated subtraction. Exchange:
$(j+p) - p(s+1) = j - ps$. Boundary: for $i<p$ both sides evaluate $K$ at $0$. $\square$

Theorem 16 matters methodologically: the refutations below are statements about *data*,
not about the internal coherence of rival laws.

> **Theorem 17 (Rate identification).** Let $K$ be strictly increasing. If two rate laws
> built on $K$ predict the same scale-$1$ chain, $\sigma_p^1 K = \sigma_q^1 K$, then
> $p=q$.

*Proof.* $\sigma_p^1 = \sigma^p$ and $\sigma_q^1 = \sigma^q$; apply Proposition 8. $\square$

### 4.1 The measured rate is one

Let $K_0(j) = 16 + 4j$, the measured base chain $\{16,20,24,\dots\}$, which is strictly
increasing with increment $\delta = 4$.

> **Theorem 18 (One cell forces $p=1$).** Let $F$ be a rate-$p$ family with base chain
> $K_0$. If $F(1,2) = 20$ then $p = 1$.

*Proof.* By Theorem 14, $F(s,j) = 16 + 4\,(j-ps)^+$; hence $F(1,2) = 16 + 4(2-p)^+$.
Setting this to $20$ gives $(2-p)^+ = 1$, i.e. $p=1$ (using $p \ge 1$). $\square$

> **Corollary 19 (Rate two, refuted).** A rate-$2$ family with base chain $K_0$ predicts
> $F(1,2) = 16 \ne 20$.

*Proof.* $16 + 4(2-2)^+ = 16$. $\square$

A single measured cell — the large model at $2048$ — therefore separates the two smallest
integer rates. The rate-$1$ family on $K_0$ does realise the measured value, so the
identification of Theorem 18 is not vacuous.

---

## 5. The budget table: reach, staircases and triangular area

The knee answers "what budget does this cell need?". The dual question — "how far does a
fixed budget reach?" — has an exact adjoint answer.

> **Definition 20 (First failing octave).** For a chain $K$ and budget $b$,
> $$\varphi_K(b) \;=\; \min\{\, j : K(j) > b\,\},$$
> defined when the set is nonempty.

> **Proposition 21 (Adjunction).** For a monotone chain $K$ with $\varphi_K(b)$ defined,
> $$j < \varphi_K(b) \iff K(j) \le b.$$

*Proof.* ($\Rightarrow$) $j$ below the least element of $\{j: K(j)>b\}$ is not in that
set. ($\Leftarrow$) If $j \ge \varphi_K(b)$ then $b < K(\varphi_K(b)) \le K(j)$ by
monotonicity, contradiction. $\square$

> **Theorem 22 (One-octave budget law).** Let $K$ be a chain with $\varphi_K(b)$ defined
> and $\varphi_K(b) > 0$ (the budget covers the base context). Then for every $s$,
> $$\varphi_{\sigma^s K}(b) \;=\; \varphi_K(b) + s.$$

*Proof.* ($\le$) $\sigma^sK(\varphi_K(b)+s) = K(\varphi_K(b)) > b$, so the minimum is at
most $\varphi_K(b)+s$. ($\ge$) If $t = \varphi_{\sigma^sK}(b) < \varphi_K(b)+s$ then
$b < \sigma^sK(t) = K((t-s)^+)$ while $(t-s)^+ < \varphi_K(b)$, so
$K((t-s)^+)\le b$ by Proposition 21 — contradiction. $\square$

> **Corollary 23 (Budget table of a scale family).** In a scale family with base chain
> reach $f=\varphi_{F(0,\cdot)}(b) > 0$, we have $\varphi_{F(s,\cdot)}(b) = f + s$; and
> cell $(s,j)$ is served by budget $b$ iff $j < f+s$. At rate $p$ the same statement reads
> $\varphi_{F(s,\cdot)}(b) = f + ps$.

For the measured data at $b = 16$: $f = 1$ at the small scale (the $16$-key budget serves
octave $0$ only, i.e. context $512$) and $\varphi = 2$ at the large scale (octaves $0$ and
$1$: contexts $512$ and $1024$). This is the verdict in engineering form: **a $16$-key
budget covers the small model to $512$ and the large model to $1024$.**

> **Theorem 24 (Staircase area).** Fix a budget $b$ with base reach $f > 0$, and consider
> the served region
> $$\mathrm{Served}(b,S,J) = \{(s,j) \in [0,S)\times[0,J) : F(s,j)\le b\}.$$
> If the context window contains the whole staircase, $f + S \le J+1$, then
> $$2\,\big|\mathrm{Served}(b,S,J)\big| \;=\; 2Sf + S(S-1).$$

*Proof.* By Corollary 23 the row at scale $s$ contributes exactly $\min(f+s, J) = f+s$
served cells. Summing, $\sum_{s<S}(f+s) = Sf + \binom{S}{2}$; doubling clears the
division. $\square$

The served region is thus a right triangle of unit slope stacked on a rectangle: each
scale doubling appends exactly one cell to the served row, so the *marginal* value of
scale, measured in served cells, is constant, while its *cumulative* value is triangular.

> **Theorem 25 (Log-linear form).** If the base chain is arithmetic, $F(0,j) = k_0 +
> \delta j$, then in a scale family
> $$F(s,j) = k_0 + \delta\,(j-s)^+ ,$$
> so the knee depends on scale and context only through the ratio $\mathrm{ctx}/2^{s}$
> (clamped at the base context).

*Proof.* Immediate from Theorem 10. $\square$

For the measured data, $k_0 = 16$, $\delta = 4$: four extra keys per context doubling, one
free doubling per scale doubling.

---

## 6. Stability under measurement noise

Measured tables satisfy no identity exactly. We therefore deform the axioms.

> **Definition 26 ($\varepsilon$-approximate family).** For $\varepsilon \ge 0$, an
> integer-valued table $F$ is $\varepsilon$-approximate if
> $$|F(s+1,j+1) - F(s,j)| \le \varepsilon \quad \text{and} \quad |F(s+1,0)-F(s,0)| \le \varepsilon$$
> for all $s,j$.

> **Theorem 27 (Linear error accumulation).** For an $\varepsilon$-approximate family,
> $$\big| F(s,j) - F\big(0,(j-s)^+\big)\big| \;\le\; \varepsilon\, s \qquad \text{for all } s,j.$$

*Proof.* Induct on $s$. For $s=0$ the difference vanishes. For the step, use the triangle
inequality through the intermediate cell: at $j = 0$,
$$|F(s{+}1,0)-F(0,0)| \le |F(s{+}1,0)-F(s,0)| + |F(s,0)-F(0,0)| \le \varepsilon + \varepsilon s;$$
at $j=i+1$, with $(i+1)-(s+1) = i-s$,
$$|F(s{+}1,i{+}1)-F(0,(i-s)^+)| \le |F(s{+}1,i{+}1)-F(s,i)| + |F(s,i)-F(0,(i-s)^+)| \le \varepsilon + \varepsilon s. \ \square$$

> **Corollary 28 (Deformation of rigidity).** A $0$-approximate family satisfies
> $F(s,j) = F(0,(j-s)^+)$ exactly; Theorem 27 is a genuine deformation of Theorem 10.

For a two-scale ladder ($s \le 1$) the bound is simply $\varepsilon$: the measured table
is within one noise unit of exactly shifted, whatever the noise unit is.

> **Lemma 29 (Accumulated rise).** If $K(j) + \delta \le K(j+1)$ for all $j$, then
> $K(0) + \delta m \le K(m)$ for all $m$.

*Proof.* Induction on $m$. $\square$

> **Theorem 30 (Noise-robust rate identification).** Let $K$ rise by at least $\delta$ per
> octave, and let $\varepsilon < \delta$. If
> $$\big|\sigma^a K(j) - \sigma^b K(j)\big| \le \varepsilon \quad\text{for all } j,$$
> then $a = b$.

*Proof.* Suppose $a<b$ (the other case by symmetry of the hypothesis). Evaluate at $j=b$:
$\sigma^aK(b) = K(b-a)$ and $\sigma^bK(b) = K(0)$, so
$|K(b-a) - K(0)| \le \varepsilon$. But $b-a \ge 1$, so Lemma 29 gives
$K(b-a) - K(0) \ge \delta > \varepsilon$ — contradiction. $\square$

> **Corollary 31 (The measured rate survives realistic noise).** For the measured base
> chain, $\delta = 4$; hence any knee error up to $3$ keys at every octave still identifies
> the shift between the two measured chains as exactly one octave.

---

## 7. The grid razor: what a finite sweep determines

The scale-$1$, octave-$2$ cell was not observed as a knee but inferred from a sweep of the
budget over a finite grid.

**The measured row** (gate $g = 0.98$, grid $G = \{8,12,16,20,24,32\}$):

| $k$ | $8$ | $12$ | $16$ | $20$ | $24$ | $32$ |
|---|---|---|---|---|---|---|
| retained | $0.9597$ | $0.9715$ | $0.9785$ | $0.9817$ | $0.9846$ | $0.9867$ |

The cell at $k=16$ fails the gate by $0.0015$ — approximately one standard error. Two
distinct questions must be separated: *what does the grid determine?* and *what does one
standard error do to that determination?*

### 7.1 Grid brackets in general

> **Definition 32 (Observed grid knee).** For a finite grid $G$, a curve $A$ and a gate
> $g$, $\;k^*_G(A,g) = \min\{k\in G : A(k)\ge g\}$.

> **Theorem 33 (Bracket lemma).** Let $A$ be monotone, $p,k$ with $A(p) < g \le A(k)$.
> Then $p < k^*(A,g) \le k$.

*Proof.* $k^*\le k$ by minimality. If $k^* \le p$ then $g \le A(k^*)\le A(p) < g$ by
monotonicity — contradiction. $\square$

> **Theorem 34 (Grid exactness).** $k^*(A,g) \le k^*_G(A,g)$ always; and
> $k^*_G(A,g) = k^*(A,g)$ if and only if $k^*(A,g)\in G$ (given the grid contains some
> passing point).

*Proof.* The observed grid knee passes the gate, so it dominates the true knee. If the
true knee lies in $G$, it is a passing grid point and hence at least the grid minimum,
giving equality; if not, the two cannot be equal. $\square$

So a sweep reports the true knee exactly when the truth lands on the grid, and otherwise a
strict overestimate. The honest output of a sweep is the interval between the last failing
and the first passing grid point.

### 7.2 The exact bracket for the measured row

Model the measured row as the four-decimal curve $M$ with $M(k) = m(k)/10^4$, where $m$ is
the monotone integer step function

$$m(k) = 9597\cdot[k\ge 8] + 118\cdot[k\ge 12] + 70\cdot[k\ge 16] + 32\cdot[k\ge 20] + 29\cdot[k\ge 24] + 21\cdot[k\ge 32],$$

so that $m$ takes the values $9597, 9715, 9785, 9817, 9846, 9867$ at the six grid budgets
and is constant between them. Since $m(j) \le m(19) = 9785 < 9800$ for every $j<20$ and
$m(20)=9817 \ge 9800$, we get $k^*(M, 0.98) = 20$: the reported knee.

> **Theorem 35 (The razor is exactly the bracket $(16,20]$).** For $m^\star \in \mathbb{N}$,
> the following are equivalent:
> 1. there exists a monotone curve $A$ with $A(k) = M(k)$ for every $k \in G$ and
>    $k^*(A, 0.98) = m^\star$;
> 2. $16 < m^\star \le 20$.

*Proof.* (1)$\Rightarrow$(2): $A(16)=M(16)=0.9785 < 0.98 \le 0.9817 = M(20)=A(20)$, so the
bracket lemma (Theorem 33) gives $16 < k^*(A,0.98) \le 20$.

(2)$\Rightarrow$(1): construct the *bumped* curve. For a location $t$ and height $v$ put
$$b_{t,v}(k) = \max\big(m(k),\; v\cdot[k\ge t]\big),$$
a monotone integer function, and let $A = b_{t,v}/10^4$. Two facts: (i) if $v \ge 9800$
and $t \le 20$ then $k^*(A,0.98) = t$, because $b_{t,v}(t)\ge v \ge 9800$ while for $j<t\le
20$ we have $b_{t,v}(j) = m(j) \le 9785$; (ii) if moreover $16 < t \le 20$ and $v = 9817$,
then $b_{t,v}$ agrees with $m$ at every grid point, since below $t$ the bump is absent and
at $20,24,32$ the measured values $9817, 9846, 9867$ already dominate $9817$. Taking
$t=m^\star$, $v=9817$ finishes. $\square$

Consequently each of $17,18,19,20$ is attained by an honest monotone curve reproducing the
measurement exactly. The sweep determines the bracket $(16,20]$ **and nothing finer**; the
reported $20$ is its conservative right endpoint, not an identified value.

> **Theorem 36 (One standard error reopens the left endpoint).** There is a monotone curve
> $A$ with $|A(k) - M(k)| \le 0.0015$ for every $k\in G$ and $k^*(A,0.98) = 16$.

*Proof.* Take $A = b_{16,\,9800}/10^4$. Monotone by construction. Its knee is $16$ by
fact (i) above ($v = 9800 \ge 9800$, $t=16\le 20$). At grid points below $16$ it equals
$M$; at $16$ it reads $0.9800$ against the measured $0.9785$, a deviation of exactly
$0.0015$; at $20,24,32$ the measured values exceed $9800$ so again it equals $M$. $\square$

The failing razor cell is thus inside the noise: the data does not close the bracket at
its left end. Both Theorem 35 and Theorem 36 are part of the honest report — the bracket
$(16,20]$ is what the six numbers pin down, and its left endpoint is one standard error
from being reopened.

### 7.3 The row is a genuine demand profile

To ensure the analysis is not an artifact of six invented numbers, we exhibit an explicit
realising population.

> **Definition 37 (Workload).** A workload of size $n$ is a family of $n$ prediction
> windows, window $i$ carrying a **key demand** $d(i)\in\mathbb{N}$: the least budget at
> which that window's decision is retained. Its **agreement curve** is
> $$A_W(k) = \frac{\#\{ i : d(i) \le k\}}{n}.$$
> Agreement curves are monotone by construction.

> **Theorem 38 (Realisation of the measured row).** There is a workload of $n = 10^4$
> windows whose agreement curve takes exactly the values
> $0.9597, 0.9715, 0.9785, 0.9817, 0.9846, 0.9867$ at $k = 8,12,16,20,24,32$ and whose knee
> at gate $0.98$ is $20$.

*Proof.* Sort the windows by demand and assign
$$d(i) = \begin{cases} 8 & i < 9597\\ 12 & 9597 \le i < 9715\\ 16 & 9715 \le i < 9785\\ 20 & 9785 \le i < 9817\\ 24 & 9817 \le i < 9846\\ 32 & 9846 \le i < 9867\\ 40 & 9867 \le i < 10000.\end{cases}$$
Then $\#\{i : d(i)\le k\}$ is the cumulative step function $c(k)$ with
$c(8)=9597$, $c(12)=9715$, $c(16)=9785$, $c(20)=9817$, $c(24)=9846$, $c(32)=9867$,
$c(k)=10^4$ for $k\ge 40$; dividing by $10^4$ gives the tabulated values. Since
$c(j) \le 9785$ for $j < 20$ and $c(20) = 9817$, the knee at $0.98$ is $20$. $\square$

The measured row is therefore a genuine sparsity structure — a population of windows with
stated demands — not merely a table of numbers. The same construction realises *any*
monotone step curve, and in particular every entry of a scale family is the knee of an
honest workload at every admissible gate, so knee chains are invariants of demand
profiles rather than free parameters.

---

## 8. Algorithms

Three algorithms follow directly and are of practical use.

**A. Knee extraction from a sweep with an honest bracket.** Given grid readings
$(k_i, A_i)$ sorted by $k_i$ and a gate $g$, return the pair $(p, q)$ where $p$ is the
largest grid point with $A_p < g$ (or $-\infty$) and $q$ the smallest with $A_q \ge g$.
Report the knee as the bracket $(p, q]$ and the point estimate $q$ with the explicit
caveat that only the bracket is determined. Cost $O(|G|)$ after sorting. By Theorems 33–35
this is the *complete* information content of the sweep.

**B. Table completion from a base chain and a rate.** Given a base chain $K$ and an
integer rate $p$, emit $F(s,j) = K((j-ps)^+)$. Cost $O(SJ)$ for an $S\times J$ table, or
$O(1)$ per query. By Theorem 14 this is the unique rate-$p$ completion.

**C. Budget planning by reach.** Given the base chain and a budget $b$, compute
$f=\varphi_K(b)$ by linear scan, then the reach at scale $s$ is $f + ps$ (Corollary 23),
and the number of served cells in an $S\times J$ corner is $Sf + \binom{S}{2}$ when the
staircase fits (Theorem 24). Cost $O(J)$ once, then $O(1)$ per query.

A fourth, diagnostic, algorithm: **rate estimation with a noise budget.** Given two
measured chains and a per-cell error bound $\varepsilon$, return the set of shifts $a$
with $\sup_j |\sigma^a K_0(j) - K_1(j)| \le \varepsilon$. Theorem 30 guarantees this set is
a singleton whenever the base chain rises by $\delta > \varepsilon$ per octave.

---

## 9. Applications and interpretation

**Budget tables gain a scale-shift form.** The practical artifact of this work is a
one-line planning rule. Measure one chain, at the smallest model you can afford. Then the
budget for any (scale, context) cell is $K((j-ps)^+)$, and the reach of any fixed budget
is $f + ps$ octaves. With the measured numbers: a $16$-key budget is adequate for the
small model to context $512$ and the large model to context $1024$; the arithmetic form
$k^*(s,j) = 16 + 4\,(j-s)^+$ covers the entire measured table.

**Scale is a translation, not a solvent.** The dominant intuition — that larger models are
qualitatively less dependent on long-context machinery — is refuted here in its strong
form and replaced by a precise weak form: larger models are dependent on exactly the same
machinery, one octave later. Since context lengths in deployment grow faster than model
sizes, a translation-only benefit is asymptotically no benefit at all: fixing $j - s$
fixes the budget, and a regime where $j$ grows faster than $s$ walks up the base chain
regardless.

**Reporting discipline.** Theorems 33–36 formalise a reporting rule that generalises far
beyond this domain: a threshold read off a finite sweep should be reported as a bracket,
together with the perturbation size that would reopen its endpoints. Here the bracket is
$(16,20]$ and the reopening perturbation is $0.0015$, about one standard error. The point
estimate $20$ is a right endpoint, and it is *correct* to use it for conservative
planning, but incorrect to treat it as identified.

---

## 10. Discussion: what the measurement actually accomplished

It is worth stating what Theorems 10–12 imply about the epistemics of the round. Three
hypotheses were pre-registered; two of them (amplification and flattening) are
*structurally* excluded once one grants the exchange law and context-monotonicity. So the
measurement did not adjudicate between three qualitatively distinct worlds. It measured
one integer: the exchange rate. Theorems 17–19 show that a single cell suffices to
separate rate $1$ from rate $2$, and Theorem 30 shows that the separation is robust to a
noise level of up to $3$ keys given the measured increment of $4$ keys per octave.

The countervailing caution is Section 7. The cell that does the separating is exactly the
cell whose knee is only bracketed. If the true knee at that cell were $16$ rather than a
value in $(16,20]$ — which one standard error at one grid point permits — then the rate-$2$
prediction would be reproduced and the identification would flip. The verdict as stated is
therefore: *rate $1$, with the discriminating cell resting on a bracket whose left endpoint
is one standard error from reopening.* A sub-$20$ addendum on the finer grid at that
context is the cheapest decisive follow-up.

**Limitations.** (i) Two scale points determine an integer rate only under the assumption
that the rate is integral; Section 11 explains why fractional rates are not excluded by
two scales. (ii) The base chain was measured at three octaves; the arithmetic form
$16+4j$ is an interpolation across three points, and Theorem 25 is only as good as that
form. (iii) The gate $0.98$ is a choice; the knee is a gate-indexed invariant and nothing
here claims gate-independence, though the shift structure applies verbatim at any gate for
which the chains are measured.

---

## 11. Future directions

**Fractional exchange rates.** The integer part of the spectrum is closed: rate $p$ is
rigid (Theorem 14), consistent (Theorem 16), preserves both impossibilities (Theorem 15),
and the data forces $p=1$ (Theorem 18). The open half is $q>1$: a rate-$p/q$ law reads
$F(s+q, j+p) = F(s,j)$, that is, invariance of the table under the sublattice of
$\mathbb{Z}^2$ generated by $(q,p)$. Rate $1/2$ — two scale doublings buying one context
doubling — is *not* excluded by two measured scales: it agrees with rate $1$ on
$s\in\{0,1\}$ and first differs at $s=2$. The structural observation is that a knee table
with rational exchange rate is exactly a function on the quotient monoid
$\mathbb{N}^2/\langle (q,p)\rangle$, so admissible rates are classified by which quotients
admit a monotone non-constant representative — a purely order-theoretic question,
independent of any model.

**The next rung.** The $s=2$ cell is the first measurement that can distinguish rate $1$
from rate $1/2$. Rate $1$ predicts the chain $\{16,16,16,20\}$ at contexts
$512,1024,2048,4096$, with the first upward break at $4096$ and a $16$-key budget covering
the model to $2048$; rate $1/2$ predicts the break stays at $2048$.

**Closing the razor.** A sub-$20$ addendum at the discriminating context — grid points at
$17,18,19$ — would collapse the bracket $(16,20]$ to a point, or reopen it at $16$.

**Extending the base chain.** Does the small model's chain continue rising at $4096$? The
arithmetic form predicts $28$; a plateau there would falsify the arithmetic form without
touching the shift law.

**Domain robustness.** All of the above is stated for one corpus family. Domain-jump
corpora test whether the base chain, and hence the whole table, is a property of the
predictor or of the text.

---

## 12. Conclusion

Two local rules — one scale doubling buys one context doubling, and at the base context
scale is inert — determine an entire two-dimensional budget table from one measured chain.
Under those rules, the hypothesis that scale amplifies context sensitivity and the
hypothesis that scale eliminates it are both *impossible*, leaving a single integer to be
measured. The measurement returns $1$: one octave per scale doubling. The law is stable —
$\varepsilon$-approximate tables are within $\varepsilon s$ of exactly shifted, and the
rate stays identifiable while noise is below the per-octave rise. Its budget-table form is
a staircase of triangular area, and its arithmetic form is
$k^*(s,j) = k_0 + \delta\,(j-s)^+$. Finally, the discriminating measurement itself is
reported honestly: a finite sweep pins the knee to the bracket $(16,20]$, no finer, and
one standard error at a single grid point would reopen its left endpoint.

Scale, in this arena, postpones context sensitivity by exactly one doubling. It neither
removes it nor makes it worse.
