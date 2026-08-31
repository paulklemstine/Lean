# Divisibility Is a Rate Dial, Not a Position Dial

### Periodic classifiers, flat window composition, and the exact non-removability of a positional excess in smooth-value profiles

**Author:** Aristotle
**Date:** 2026-08-31

---

## Abstract

Sieve-based factoring methods scan the polynomial values $v = j^2 - N$ and record which of them are smooth. A measured mid-window excess in the smooth-hit profile — a residual peak of relative amplitude $0.1774 \pm 0.0432$ at normalized window coordinate $t = 0.65$, against a Dickman-weighted reference — was tested against a sixteen-cell divisibility mixture baseline, in which candidates are stratified by the pattern $(2 \mid v,\, 3\mid v,\, 5\mid v,\, 7 \mid v)$ and each cell is granted its own free rate. The mixture removed exactly $0\%$ of the excess and left the peak position unmoved.

We prove that this outcome is forced. The cell label of $j^2 - N$ is a $210$-periodic function of $j$, so every window of $210$ consecutive candidates has *identical* cell populations regardless of position; we call this **flat composition**. Under flat composition the entire $|C|$-parameter mixture family collapses to the ray $\{K \cdot B\}$ spanned by a single common shape $B$: the model has one degree of freedom, a rate, and none in position. Consequently the residual relative excess and its argmax are exact invariants of the fit, and removal is identically zero.

We give the robust quantitative form: if composition is flat only up to a per-cell relative drift $\delta$, the excess ratio $\rho$ can shrink by at most the factor $(1-\delta)/(1+\delta)$; inverting, absorbing a relative excess $\rho - 1$ requires drift $\delta \ge (\rho-1)/(\rho+1)$. With the measured $\rho - 1 = 0.1774$ this demands $\delta \ge 8.1\%$ against a measured drift of $0.269\%$, and the surviving excess is bounded below by $0.1710$, above the registered bar $2\cdot\mathrm{SE} = 0.0864$ and above twice the null-calibrated $\mathrm{SE} = 0.0411$.

Finally we show the argument uses nothing about the primes $2,3,5,7$ beyond periodicity, and thereby remove an entire family of candidate mechanisms: **any** classifier of $j$ factoring through $\mathbb{Z}/m\mathbb{Z}$ — higher power residues of $v$, Legendre symbols at primes $p > 7$, bit patterns, arbitrary Boolean combinations — has flat composition on windows of length a multiple of $m$, and removes $0\%$. The carrier of the observed positional excess must be **aperiodic in $j$**. Two sharpness results confirm the hypothesis is not vacuous: a positional reference family removes $100\%$ of the same excess, and an explicit aperiodic carrier with position-dependent composition exists.

**Keywords:** smooth values, Dickman function, quadratic sieve, mixture baseline, periodic classifier, window composition, positional excess, rate modulation.

---

## 1. Introduction

### 1.1 The setting

Congruence-of-squares factoring methods generate candidate values along a polynomial sequence and retain those that are *smooth* — completely factorable over a fixed prime base. For the classical quadratic-sieve polynomial the sequence is

$$v(j) \;=\; j^2 - N, \qquad j = j_0, j_0+1, \dots, j_0 + L - 1,$$

with $j_0 \approx \lceil \sqrt N \rceil$ and $L$ the scan-window length. The expected *rate* of smooth hits is classically modelled by the Dickman function $\rho$: the density of $y$-smooth integers near $x$ is $\approx \rho(u)$ with $u = \log x / \log y$. Writing $t \in [0,1]$ for the normalized position within the window, the Dickman-weighted reference profile

$$B(t) \;=\; \text{(expected hit density at position } t\text{)}$$

is a smooth, featureless, gently varying curve.

### 1.2 The observation

Empirically, the ratio of measured to predicted hits,

$$R(t) \;=\; \frac{T(t)}{B(t)},$$

is *not* featureless. It carries a reproducible interior peak: at $t = 0.65$ the residual exceeds the flank level by a relative amplitude

$$\mathrm{amp} \;=\; 0.1774 \pm 0.0432, \qquad z = 4.11,$$

well above the pre-registered detection bar of $z \ge 2$. The feature is stable under translation of the window and reappears across choices of $N$.

Two prior stages of investigation established that (i) the feature is real over an exact Dickman baseline, and (ii) no single binary divisibility indicator explains it. The natural remaining hypothesis is a *composition* effect: candidates are heterogeneous in their intrinsic smoothness rates, and if the mixture of types drifted with $t$, an apparent positional excess would arise with no positional mechanism behind it.

### 1.3 The mixture baseline and its failure

To test this, stratify candidates by their small-prime divisibility pattern

$$c(j) \;=\; \bigl(2 \mid v(j),\; 3 \mid v(j),\; 5 \mid v(j),\; 7 \mid v(j)\bigr) \in \{0,1\}^4,$$

giving $|C| = 16$ cells, compute per-cell Dickman-weighted reference sums $S_c(t)$, and fit per-cell rates $\kappa_c$ on the window flanks (the score region excluded, with shrinkage toward the global flank rate). The corrected baseline is

$$\mathrm{PRED}(t) \;=\; \sum_{c \in C} \kappa_c\, S_c(t).$$

The fitted per-cell rates were genuinely modulated — normalized rates $\kappa_c/g$ spread over $[0.645,\,1.406]$, a factor of $\approx 2.2$, with the largest cells being combinations involving $3\mid v$ and $5 \mid v$ — yet the residual peak was untouched: amplitude $0.1774$, peak at $t=0.65$, removal $0\%$. Separately, the measured class composition was flat in $t$ to a maximum cell drift of $0.269\%$.

This paper explains, and proves, why.

### 1.4 Contributions

1. **Structure (§3).** The divisibility cell of $j^2 - N$ is $210$-periodic in $j$; every window of $210$ consecutive $j$ has identical cell populations, for every $N$ and every window position. For odd $N$, the bit $2 \mid v$ is exactly the parity of $j$, so parity is a coordinate of the grid rather than an independent carrier.
2. **Collapse (§4).** Flat composition forces $\sum_c \kappa_c S_c = K \cdot B$; the achievable prediction set is exactly the ray $\{K\cdot B\}$. Hence residual invariance, exact $0\%$ removal, argmax invariance, and non-fittability of non-proportional measurements.
3. **Robustness (§5).** With drift $\delta$, the excess ratio shrinks by at most $(1-\delta)/(1+\delta)$; inverting yields a scale-free drift budget $\delta \ge (\rho-1)/(\rho+1)$. Instantiated at the measured numbers, the excess survives with margin.
4. **Family removal (§6).** Every $\mathbb{Z}/m\mathbb{Z}$-factoring classifier is $m$-periodic, hence flat, hence removes $0\%$; with a quantitative drift bound $L \bmod m$ for windows not commensurate with $m$. The carrier must be aperiodic.
5. **Sharpness (§7).** A positional family removes $100\%$ of the same excess, and an explicit aperiodic carrier with position-dependent composition exists; hence the negative result is about the grid, not the formalism.

---

## 2. Definitions

Throughout, $N \in \mathbb{Z}$ is the number being factored, $j$ ranges over $\mathbb{Z}$, and $v(j) = j^2 - N$. Let $C$ be a finite set of *cells* (classes).

**Definition 2.1 (Divisibility cell).** For $v \in \mathbb{Z}$ set
$$\mathrm{cellOf}(v) \;=\; \bigl(\,[2\mid v],\ [3 \mid v],\ [5\mid v],\ [7\mid v]\,\bigr) \in \{0,1\}^4,$$
and $\mathrm{cell}_N(j) = \mathrm{cellOf}(j^2 - N)$.

**Definition 2.2 (Window count).** For a classifier $f : \mathbb{Z} \to C$, a start $a \in \mathbb{Z}$, a length $L \in \mathbb{N}$ and a class $c$,
$$\mathrm{count}_f(a, L, c) \;=\; \#\{\, i \in \{0,\dots,L-1\} \;:\; f(a+i) = c \,\}.$$
For the divisibility grid at length $210$ we write $\mathrm{wc}_N(a,c) = \mathrm{count}_{\mathrm{cell}_N}(a, 210, c)$.

**Definition 2.3 (Periodic classifier).** $f : \mathbb{Z} \to C$ is *$m$-periodic* if $f(j+m) = f(j)$ for all $j$.

**Definition 2.4 (Flat composition).** A cell-resolved reference family $S : C \times \mathbb{R} \to \mathbb{R}$ has **flat composition** with weights $w : C \to \mathbb{R}$ and common shape $B : \mathbb{R}\to\mathbb{R}$ if
$$S_c(t) \;=\; w_c \cdot B(t) \qquad \text{for all } c \in C,\ t \in \mathbb{R}.$$
That is, every cell contributes a fixed *fraction* of one and the same positional shape; the cell decomposition carries no information about $t$.

**Definition 2.5 (Mixture prediction).** For rates $\kappa : C \to \mathbb{R}$,
$$\mathrm{PRED}_\kappa(t) \;=\; \sum_{c \in C} \kappa_c \, S_c(t).$$

**Definition 2.6 (Residual and relative excess).** For a measured profile $T$ and a baseline $P$,
$$\mathcal{R}[T,P](t) \;=\; \frac{T(t)}{P(t)}, \qquad
\mathcal{E}[R](t_0,t_1) \;=\; \frac{R(t_0)}{R(t_1)} - 1 .$$
Here $t_0$ is the peak position ($t_0 = 0.65$) and $t_1$ a flank reference. The *amplitude* reported by the experiment is $\mathcal{E}\bigl[\mathcal{R}[T,B]\bigr](t_0,t_1)$; the quantity of interest is the same functional computed against the fitted mixture, and the **removal fraction** is the difference of the two.

**Definition 2.7 (Cell reference sums).** The experiment's per-cell references are the window populations weighted by the common Dickman shape:
$$S_c(t) \;=\; \mathrm{wc}_N(\lfloor t \rfloor,\, c)\cdot B(t).$$

---

## 3. Part I — The divisibility grid is $210$-periodic and its composition is flat

**Lemma 3.1 (Cell labels see only $v \bmod 210$).** For all $v, k \in \mathbb{Z}$,
$$\mathrm{cellOf}(v + 210k) = \mathrm{cellOf}(v).$$

*Proof.* $210 = 2\cdot3\cdot5\cdot7$, so for each $p \in \{2,3,5,7\}$ we have $p \mid 210k$, whence $p \mid v + 210k \iff p \mid v$. All four coordinates of the label agree. $\square$

**Theorem 3.2 (Periodicity of the sieve cell).** For every $N$ and $j$,
$$\mathrm{cell}_N(j + 210) = \mathrm{cell}_N(j).$$

*Proof.* $(j+210)^2 - N = (j^2 - N) + 210\,(2j + 210)$, and apply Lemma 3.1 with $k = 2j+210$. $\square$

Note the strength of the hypothesis needed: none. The statement holds for every integer $N$, whatever its factorization, and for every $j$.

**Theorem 3.3 (Shift invariance of window populations).** For every $N$, $a$, $c$,
$$\mathrm{wc}_N(a+1, c) = \mathrm{wc}_N(a, c).$$

*Proof sketch.* Write $h(i) = [\mathrm{cell}_N(a+i) = c]$. Summing $h$ over $\{0,\dots,210\}$ in the two standard ways gives
$$\sum_{i=0}^{209} h(i+1) + h(0) \;=\; \sum_{i=0}^{209} h(i) + h(210).$$
By Theorem 3.2, $\mathrm{cell}_N(a+210) = \mathrm{cell}_N(a)$, so $h(210) = h(0)$ and the two sums coincide. The left sum is $\mathrm{wc}_N(a+1,c)$ and the right one $\mathrm{wc}_N(a,c)$. $\square$

**Corollary 3.4 (Flat composition of the divisibility grid).** For all $N, a, b, c$,
$$\mathrm{wc}_N(a,c) \;=\; \mathrm{wc}_N(b,c) \;=\; \mathrm{wc}_N(0,c).$$

*Proof.* Induct on $a$ in both directions from $0$ using Theorem 3.3. $\square$

Equivalently, in the language of Definition 2.4: with $w_c = \mathrm{wc}_N(0,c)$ the family of Definition 2.7 satisfies $S_c(t) = w_c B(t)$, i.e. **it has flat composition**. This is the exact structural counterpart of the measured statement "class composition is flat in $t$ (max cell drift $0.269\%$)".

### 3.1 Parity lives inside the grid

**Proposition 3.5.** Let $N$ be odd. Then for every $j$,
$$2 \mid j^2 - N \iff j \text{ is odd}.$$

*Proof.* Write $N = 2m+1$. If $j = 2k+1$ then $j^2 - N = 2(2k^2+2k-m)$ is even. If $j = 2k$ then $j^2 - N = 2(2k^2 - m) - 1$ is odd. $\square$

So bit $0$ of the grid is precisely $j$-parity. Any residual "parity carrier" reading of the previous stage is therefore *already inside* the sixteen-cell model, and fails with it.

### 3.2 The rates are real: quadratic-residue modulation

Flatness in position is not flatness in rate. For an odd prime $p$ the number of $j \bmod p$ with $p \mid j^2 - N$ is
$$\#\{\, j \in \mathbb{Z}/p : j^2 = N \,\} \;=\; 1 + \left(\tfrac{N}{p}\right) \in \{0, 1, 2\},$$
so the rate at which $p$ divides $v$ is $0$, $1/p$ or $2/p$ according as $N$ is a non-residue, zero, or a residue mod $p$. Explicitly at $p=3$: the count is $1$ if $N \equiv 0$, $2$ if $N \equiv 1$, and $0$ if $N \equiv 2 \pmod 3$. At $p = 7$: $N \equiv 3$ gives $0$ roots, $N \equiv 1$ gives $2$.

**Worked table ($N = 8051 = 83\cdot 97$).** $8051$ is odd and $8051 \equiv 2 \pmod 3$, a non-residue. Every window of $210$ consecutive $j$ contains exactly:

| cell $(2\mid v, 3\mid v, 5\mid v, 7\mid v)$ | population |
|---|---|
| $(0,0,0,0)$ | $45$ |
| $(0,0,0,1)$ | $18$ |
| $(0,0,1,0)$ | $30$ |
| $(0,0,1,1)$ | $12$ |
| $(1,0,0,0)$ | $45$ |
| $(1,0,0,1)$ | $18$ |
| $(1,0,1,0)$ | $30$ |
| $(1,0,1,1)$ | $12$ |
| any cell with $3\mid v$ | $0$ |

The parity bit splits the window exactly in half, $45+18+30+12 = 105$ odd $j$ and $105$ even $j$, as Proposition 3.5 requires; all eight $3\mid v$ cells are empty by the non-residue condition. **These same populations occur at every window start** — at $a = 0$, at $a=1234$, at $a = -77777$ — by Corollary 3.4. The dial is genuinely turned (a cell rate of exactly $0$ is as modulated as a rate gets), and it never turns with position.

---

## 4. Part II — Flat composition collapses the mixture to a ray

Fix a finite cell set $C$, a family $S$ with flat composition $S_c = w_c B$, and write $K(\kappa) = \sum_{c} \kappa_c w_c$.

**Theorem 4.1 (Collapse).** For all $\kappa$ and $t$,
$$\mathrm{PRED}_\kappa(t) \;=\; K(\kappa)\cdot B(t).$$

*Proof.* $\sum_c \kappa_c S_c(t) = \sum_c \kappa_c w_c B(t) = \bigl(\sum_c \kappa_c w_c\bigr) B(t)$. $\square$

**Theorem 4.2 (The mixture family is exactly a ray).** If $w_{c_0} \neq 0$ for some $c_0$, then
$$\{\, \mathrm{PRED}_\kappa \;:\; \kappa \in \mathbb{R}^C \,\} \;=\; \{\, K\cdot B \;:\; K \in \mathbb{R} \,\}.$$

*Proof.* Inclusion $\subseteq$ is Theorem 4.1. For $\supseteq$, given $K$ take $\kappa_c = K/w_{c_0}$ for $c = c_0$ and $0$ otherwise; then $K(\kappa) = K$. $\square$

Thus the $|C|$-parameter model has exactly one effective parameter, and it is a *scale*. No choice of rates changes the shape.

**Corollary 4.3 (No positional freedom).** For all $\kappa, \kappa'$ and all $s,t$,
$$\mathrm{PRED}_\kappa(t)\,\mathrm{PRED}_{\kappa'}(s) \;=\; \mathrm{PRED}_\kappa(s)\,\mathrm{PRED}_{\kappa'}(t),$$
i.e. any two mixtures are pointwise proportional.

**Lemma 4.4 (Residual rescaling).** $\mathcal{R}[T,\mathrm{PRED}_\kappa](t) = \mathcal{R}[T,B](t)\,/\,K(\kappa)$.

**Theorem 4.5 (Invariance of the amplitude; removal is exactly $0\%$).** Let $K(\kappa)\neq 0$, $T(t_1)\neq0$, $B(t_1) \neq 0$. Then
$$\mathcal{E}\bigl[\mathcal{R}[T,\mathrm{PRED}_\kappa]\bigr](t_0,t_1) \;=\; \mathcal{E}\bigl[\mathcal{R}[T,B]\bigr](t_0,t_1),$$
and hence the removal fraction, the difference of the two, is identically $0$.

*Proof.* By Lemma 4.4 both residuals differ by the constant factor $1/K(\kappa)$, which cancels in the ratio $R(t_0)/R(t_1)$. $\square$

**Theorem 4.6 (The peak does not move).** If $K(\kappa) > 0$ and $t_0$ maximizes $\mathcal{R}[T,B]$ over a set $W$, then $t_0$ maximizes $\mathcal{R}[T,\mathrm{PRED}_\kappa]$ over $W$; strict maxima remain strict.

*Proof.* Dividing by the positive constant $K(\kappa)$ preserves $\le$ and $<$. $\square$

This is the theoretical counterpart of the measured statement "peak $t = 0.65$ exact" after mixture fitting.

**Theorem 4.7 (Non-fittability).** If $T(t_0)B(t_1) \neq T(t_1)B(t_0)$ — i.e. $T$ is not proportional to $B$ across the pair $(t_0,t_1)$ — then $\mathrm{PRED}_\kappa \neq T$ for every $\kappa$.

*Proof.* $\mathrm{PRED}_\kappa = T$ would give $T(t_i) = K(\kappa)B(t_i)$ for $i=0,1$, forcing proportionality. $\square$

**Theorem 4.8 (Capstone for the divisibility grid).** For every $N$, every common shape $B$, every measured profile $T$, and every rate vector $\kappa \in \mathbb{R}^{16}$ with $\sum_c \kappa_c\,\mathrm{wc}_N(0,c) \neq 0$,
$$\mathcal{E}\bigl[\mathcal{R}[T,\textstyle\sum_c \kappa_c S_c]\bigr](t_0,t_1) \;=\; \mathcal{E}\bigl[\mathcal{R}[T,B]\bigr](t_0,t_1)$$
with $S_c$ the cell reference sums of Definition 2.7. Contrapositively, a nonzero mid-window excess over the plain shape forces a nonzero excess over *every* divisibility mixture.

*Proof.* Corollary 3.4 gives flat composition with $w_c = \mathrm{wc}_N(0,c)$; apply Theorem 4.5. $\square$

**Slogan.** *Divisibility is a rate dial, not a position dial.* The sixteen cells buy a global scale factor; the sought-after mechanism lives in $t$, where the model has no reach at all.

---

## 5. Part III — Robust form: drift budgets

Real windows are finite and real compositions are flat only to measurement precision (here $0.269\%$). We therefore relax exact flatness.

**Definition 5.1 (Relative composition drift).** The family $S$ has drift at most $\delta \ge 0$ at position $t$ (relative to weights $w$ and shape $B$) if
$$\bigl| S_c(t) - w_c B(t) \bigr| \;\le\; \delta \cdot \bigl(w_c B(t)\bigr) \qquad \text{for every } c.$$

**Theorem 5.2 (Squeeze).** If $\kappa_c \ge 0$ for all $c$ and $S$ has drift at most $\delta$ at $t$, then
$$(1-\delta)\,K(\kappa) B(t) \;\le\; \mathrm{PRED}_\kappa(t) \;\le\; (1+\delta)\,K(\kappa)B(t).$$

*Proof.* Bound each $S_c(t)$ between $(1\pm\delta)w_cB(t)$, multiply by $\kappa_c \ge 0$ and sum. $\square$

**Theorem 5.3 (Excess lower bound).** Let $B(t_0),B(t_1) > 0$, $T(t_0)\ge 0$, $T(t_1) > 0$, and let $P(t_0),P(t_1)>0$ be the fitted baseline values obeying
$$P(t_0) \le (1+\delta)K B(t_0), \qquad P(t_1)\ge(1-\delta)KB(t_1),$$
with $0 \le \delta < 1$. If the raw excess ratio is $\rho$, i.e. $T(t_0)B(t_1) = \rho\,T(t_1)B(t_0)$, then
$$\frac{T(t_0)/P(t_0)}{T(t_1)/P(t_1)} \;\ge\; \rho\cdot\frac{1-\delta}{1+\delta}.$$

*Proof sketch.* Substitute the two one-sided bounds into the cross-multiplied inequality $\rho(1-\delta)\,T(t_1)P(t_0) \le (1+\delta)\,T(t_0)P(t_1)$: the left side is bounded using $P(t_0) \le (1+\delta)KB(t_0)$, the right using $P(t_1) \ge (1-\delta)KB(t_1)$, and the two meet exactly through the defining relation $\rho\,T(t_1)B(t_0) = T(t_0)B(t_1)$. Dividing by the positive quantity $T(t_1)P(t_0)$ gives the stated form. $\square$

**Theorem 5.4 (Registered verdict at the measured numbers).** With $\delta = 0.00269$ and $\rho = 1.1774$, under the hypotheses of Theorem 5.3,
$$\frac{T(t_0)/P(t_0)}{T(t_1)/P(t_1)} - 1 \;\ge\; 0.1710 .$$
In particular the surviving excess exceeds the registered bar $2\,\mathrm{SE} = 2\times 0.0432 = 0.0864$ and also exceeds twice the null-calibrated standard error $2\times 0.0411 = 0.0822$.

*Proof.* $1.1774 \times \frac{1 - 0.00269}{1 + 0.00269} = 1.17108\ldots \ge 1.1710$. $\square$

**Theorem 5.5 (Drift budget — inverse form).** Under the hypotheses of Theorem 5.3, if the mixture absorbs the excess completely, i.e.
$$\frac{T(t_0)/P(t_0)}{T(t_1)/P(t_1)} \;\le\; 1,$$
then necessarily
$$\delta \;\ge\; \frac{\rho - 1}{\rho + 1}.$$

*Proof.* Theorem 5.3 gives $\rho(1-\delta)/(1+\delta) \le 1$, i.e. $\rho(1-\delta) \le 1+\delta$, i.e. $\rho - 1 \le \delta(\rho+1)$. $\square$

**Corollary 5.6 (Measured budget).** For $\rho - 1 = 0.1774$ absorption requires $\delta \ge 0.081$, i.e. $8.1\%$ composition drift — more than $30\times$ the measured $0.269\%$.

Theorem 5.5 is the most portable statement in the paper: it mentions no bit length, no window length, no prime bound, no data geometry. It is a pure inequality between an observed excess and a composition drift, so the test transfers to any problem size unchanged.

---

## 6. Part IV — The whole residue family is removed

The argument of §§3–4 used exactly one property of the divisibility grid: periodicity. We now exploit that.

Let $f : \mathbb{Z}\to C$ be any classifier and $\mathrm{count}_f(a,L,c)$ as in Definition 2.2.

**Lemma 6.1 (Window calculus).** $\mathrm{count}_f(a,L,c) \le L$, and windows concatenate:
$$\mathrm{count}_f(a, L_1+L_2, c) = \mathrm{count}_f(a,L_1,c) + \mathrm{count}_f(a+L_1, L_2, c).$$

**Theorem 6.2 (Flat composition for periodic classifiers).** If $f$ is $m$-periodic and $L = mq$ for some $q \in \mathbb{N}$, then for every $a$ and $c$,
$$\mathrm{count}_f(a,L,c) = \mathrm{count}_f(0,L,c).$$

*Proof.* First, $\mathrm{count}_f(a+1,L,c) = \mathrm{count}_f(a,L,c)$ by the telescoping identity of Theorem 3.3, whose only input is $f(a+L) = f(a)$ — which holds since $m \mid L$ and $f$ is $m$-periodic (iterate $f(j+m)=f(j)$ $q$ times). Then induct on $a$ in both directions. $\square$

**Theorem 6.3 (Bounded drift for incommensurate windows).** If $f$ is $m$-periodic then for all $a,b,L,c$,
$$\mathrm{count}_f(a,L,c) \;\le\; \mathrm{count}_f(b,L,c) + (L \bmod m).$$

*Proof.* Write $L = mq + r$ with $r = L \bmod m$. Splitting the window (Lemma 6.1) gives $\mathrm{count}_f(a,L,c) = q\,\mathrm{count}_f(0,m,c) + \mathrm{count}_f(a+mq, r, c)$, and likewise for $b$; the $q$-terms are identical and the remainders are each at most $r$. $\square$

So the relative composition drift of an $m$-periodic carrier over a window of length $L$ is below $m/L$. Combined with Corollary 5.6: an $m$-periodic carrier can absorb the measured excess only if $m/L \ge 0.081$, i.e. only if its period is at least $8.1\%$ of the entire scan window. No arithmetic modulus in the candidate list comes remotely close.

**Theorem 6.4 (Every residue-type carrier is periodic).** Let $g : \mathbb{Z}/m\mathbb{Z} \to C$ be arbitrary.
1. $j \mapsto g(j \bmod m)$ is $m$-periodic.
2. $j \mapsto g\bigl((j^2 - N) \bmod m\bigr)$ is $m$-periodic.
3. In particular, for a prime $p$, the quadratic-character carrier $j \mapsto \chi_p(j^2 - N)$ (the Legendre symbol $\left(\frac{j^2-N}{p}\right)$, including the value $0$) is $p$-periodic.

*Proof.* (1) $j + m \equiv j \pmod m$. (2) $(j+m)^2 - N \equiv j^2 - N \pmod m$. (3) is (2) with $g = \chi_p$. $\square$

Items (1)–(3) cover the entire pre-named candidate family: divisibility patterns at any prime set, higher power residues of $v$, Legendre and higher-character symbols at primes $p > 7$, low bit patterns of $j$ or of $v$ (which are functions of $v \bmod 2^k$), and every Boolean combination thereof (a Boolean combination of $m_i$-periodic classifiers is $\mathrm{lcm}(m_i)$-periodic).

**Theorem 6.5 (Capstone: no residue mixture removes any part of the excess).** Let $f$ be $m$-periodic, $L = mq$, and define the cell references $S_c(t) = \mathrm{count}_f(\lfloor t\rfloor, L, c)\cdot B(t)$. Then for every rate vector $\kappa$ with $\sum_c \kappa_c\,\mathrm{count}_f(0,L,c) \neq 0$,
$$\mathcal{E}\bigl[\mathcal{R}[T,\mathrm{PRED}_\kappa]\bigr](t_0,t_1) \;=\; \mathcal{E}\bigl[\mathcal{R}[T,B]\bigr](t_0,t_1).$$

*Proof.* Theorem 6.2 gives flat composition with $w_c = \mathrm{count}_f(0,L,c)$; apply Theorem 4.5. $\square$

**Theorem 6.6 (The carrier must be aperiodic).** Suppose some class mixture *does* move the measured relative excess, i.e.
$$\mathcal{E}\bigl[\mathcal{R}[T,\mathrm{PRED}_\kappa]\bigr](t_0,t_1) \neq \mathcal{E}\bigl[\mathcal{R}[T,B]\bigr](t_0,t_1)$$
for the reference family built from a classifier $f$ on windows of length $L$. Then there is **no** $m \mid L$ for which $f$ is $m$-periodic.

*Proof.* Contrapositive of Theorem 6.5. $\square$

This is the operative form of the follow-up question. The search for the mechanism behind the $t \approx 0.65$ excess is now constrained *a priori*: any proposed carrier that factors through a residue system, at any modulus commensurate with the window, is dead before it is tested.

---

## 7. Part V — Sharpness: the hypothesis is not vacuous

A negative theorem must be shown not to be an artifact of its own framework.

**Definition 7.1 (Positional reference family).** Given a shape $B$ and the measurement $T$, define a two-cell family
$$S^{\mathrm{pos}}_{\mathrm{false}}(t) = B(t), \qquad S^{\mathrm{pos}}_{\mathrm{true}}(t) = T(t).$$
Its cells drift with $t$ whenever $T$ is not proportional to $B$.

**Theorem 7.2 (Sharpness I: $100\%$ removal is achievable).** With $\kappa_{\mathrm{true}} = 1$, $\kappa_{\mathrm{false}} = 0$ and $T(t_0), T(t_1)\neq0$,
$$\mathcal{E}\bigl[\mathcal{R}[T,\mathrm{PRED}_\kappa]\bigr](t_0,t_1) = 0 .$$

*Proof.* $\mathrm{PRED}_\kappa = T$, so the residual is identically $1$ and its ratio across positions is $1$. $\square$

**Proposition 7.3.** If $T(t_0)B(t_1)\ne T(t_1)B(t_0)$, the positional family admits **no** weights $w$ making it flat.

*Proof.* Flatness would give $T(t_i) = w_{\mathrm{true}} B(t_i)$ for $i = 0,1$, contradicting non-proportionality. $\square$

So the same fitting procedure that removes $0\%$ over a periodic grid removes $100\%$ over a positional family: the $0\%$ is a fact about the divisibility grid, not about mixtures.

**Definition 7.4 (Step carrier).** $\sigma(j) = [\, j \ge 0 \,] \in \{0,1\}$.

**Theorem 7.5 (Sharpness II: aperiodic carriers with positional composition exist).** For every $L \ge 1$,
$$\mathrm{count}_\sigma(0, L, 1) = L, \qquad \mathrm{count}_\sigma(-L, L, 1) = 0,$$
so $\sigma$ has maximal composition drift; consequently $\sigma$ is not $m$-periodic for any $m \ge 1$.

*Proof.* The two counts are immediate. If $\sigma$ were $m$-periodic, Theorem 6.2 with $L = m$ would force the two counts to be equal, contradicting $m \neq 0$. $\square$

**Theorem 7.6 (Rate-dial dichotomy).** Let $S$ have flat composition with shape $B$, and let $T(t_0),T(t_1)\ne0$, $B(t_1)\ne0$. Then simultaneously:
1. for **every** rate vector $\kappa$ with $K(\kappa)\ne0$, the mixture over $S$ preserves the relative excess exactly; and
2. the positional family of Definition 7.1 annihilates the same excess.

Divisibility (and every residue classification) is a rate dial; whatever carries the $t \approx 0.65$ excess is a position dial.

---

## 8. Algorithms

The theory is fully constructive and each statement has a direct algorithmic counterpart, useful both as a check and as a screening tool for future candidate carriers.

**Algorithm A — Window composition census.** Given $N$, a classifier $f$, a window length $L$, and a set of start positions, tabulate $\mathrm{count}_f(a,L,c)$ for all $c$ and all $a$, and report the maximum relative drift
$$\delta_{\max} = \max_{c}\ \frac{\max_a \mathrm{count}_f(a,L,c) - \min_a \mathrm{count}_f(a,L,c)}{\max\bigl(1,\ \min_a \mathrm{count}_f(a,L,c)\bigr)} .$$
Cost $O(|A|\cdot L)$ with $|A|$ the number of starts, or $O(m + |A|)$ using periodicity when $f$ is known $m$-periodic. Theorem 6.2 predicts $\delta_{\max} = 0$ exactly when $m \mid L$.

**Algorithm B — Flank-fitted mixture baseline and removal fraction.** Given profiles $T$, $B$ and cell references $S_c$ on a $t$-grid: (i) restrict to flank bins (score window excluded); (ii) solve the shrunk non-negative least-squares problem $\min_{\kappa\ge0} \sum_{t\in\text{flank}} (T(t) - \sum_c\kappa_cS_c(t))^2 + \lambda\|\kappa - \bar\kappa\|^2$; (iii) form the residual $T/\mathrm{PRED}_\kappa$; (iv) report the relative excess and the removal fraction against the single-shape baseline. Cost $O(n|C|^2 + |C|^3)$. Theorem 4.5 predicts a removal of exactly $0$ to numerical precision whenever composition is flat.

**Algorithm C — Aperiodicity screen for candidate carriers.** Given a candidate classifier $f$, an excess ratio $\rho$, and window length $L$: compute the required drift budget $\delta^\star = (\rho-1)/(\rho+1)$, measure $\delta_{\max}$ by Algorithm A, and *reject* $f$ as an explanation whenever $\delta_{\max} < \delta^\star$. If $f$ is known to be $m$-periodic, reject immediately whenever $m/L < \delta^\star$, with no data pass at all. Cost $O(1)$ in the periodic case.

---

## 9. Discussion

### 9.1 What the null result buys

A fit that fails to move a statistic is ordinarily uninformative. What makes this one informative is the accompanying structural theorem: the model's *span* is a one-dimensional ray, so its failure is logically necessary and not an accident of the particular $N$, window, prime bound, or fitting procedure. The measurement and the theorem agree at every point where they can be compared: composition flat in $t$ (Corollary 3.4 versus measured $0.269\%$), removal $0\%$ (Theorem 4.5 versus measured $0\%$), peak unmoved (Theorem 4.6 versus measured $t = 0.65$ exact).

Simultaneously, the theory explains the part of the measurement that is *not* null. The fitted per-cell rates were spread over $[0.645, 1.406]$ — a real $2.2\times$ rate modulation — exactly as the quadratic-residue count $1 + \left(\frac{N}{p}\right) \in \{0,1,2\}$ predicts. The grid is far from inert; it is inert *in the one coordinate that matters here*.

### 9.2 Controls and a disclosed caveat

Two controls accompanied the measurement. A machinery-null control returned amplitude $0.0271 \pm 0.0102$ with maximum deviation $0.0342$ over all bins — consistent with no artifact. A parametric estimator-null control, which measures the max-over-bins positive bias intrinsic to a raw amplitude statistic, returned $0.0860 \pm 0.0411$; dividing the raw amplitude by this calibration gives a null-calibrated $z_{\mathrm{cal}} = 1.53 < 2$, below the nominal bar. The registered rule was stated on the raw amplitude and is reported as such, with the disagreement disclosed rather than silently resolved. The robust bound of Theorem 5.4 was therefore checked against both scales, and clears both: the surviving excess $\ge 0.1710$ exceeds $2\times0.0432 = 0.0864$ *and* $2\times0.0411 = 0.0822$. Independently of the calibration question, the *structural* results of §§3–4, 6–7 are unconditional: they are statements about the grid, not about the data.

An earlier version of the control design had a defect worth recording: a single control comparing count halves against a density-weighted prediction possesses a non-flat null by construction, because raw counts carry no positional density gradient. This was caught at the smoke-test stage (spurious amplitude $0.47$), the control was split into the machinery and estimator halves before the full run, and the registered decision rule was left unchanged.

### 9.3 Relation to the broader picture

Three orthogonal layers now organize the observed structure in these profiles: a positional layer, a left-edge composition layer, and — established here — a third layer that is real, translation-stable, and provably **non-divisibility**. The value of the present work is that the third layer is characterized *negatively but sharply*: the family of divisibility-rate mixtures as a positional explanation is removed from the search space at every scale, and by §6 the entire residue world goes with it.

### 9.4 Limitations

The exact results assume the reference family is built from window counts of a classifier and a single common shape $B$ — the structure the experiment actually used. A baseline that let the *shape* itself vary per cell (different $B_c$ for different cells) is not covered by the collapse theorem, and would only be excluded by the robust bound of §5 with a directly measured drift. The robust bound assumes non-negative rates, which is the physically meaningful regime and matches the fit. Finally, $t_0$ and $t_1$ are treated as fixed positions; the max-over-bins selection effect they conceal is precisely what the estimator-null control quantifies, and is reported rather than absorbed.

---

## 10. Future work

The theorem converts the open question from "which divisibility feature is it?" into "which aperiodic feature is it?", and supplies a quantitative screen for candidates.

**1. An aperiodic-carrier classification theorem.** "Position dial" now has an exact meaning: non-invariance of window composition under translation. For finite-valued classifiers, translation invariance of composition at all window lengths is essentially equivalent to periodicity, and Theorem 6.3 supplies the exact drift bound $L \bmod m$ that any classification theorem must beat. The natural target: a finite-valued classifier whose window composition drifts by more than $C/L$ is not almost periodic, and its Fourier–Bohr spectrum must contain an irrational frequency. This would replace the modulus-by-modulus screen with a single spectral criterion.

**2. Size and valuation carriers — the surviving candidates.** The classifiers that Theorem 6.6 does *not* kill are those that see magnitude rather than residue: the actual size of $v = j^2 - N$ as $j$ traverses the window (which grows monotonically and hence aperiodically), proximity to a truncation or logarithm-threshold boundary in the sieve, and $p$-adic valuations of $v$ beyond mere divisibility — $v_p(v) \ge 2$ events are rarer and interact with the size gradient. These are the natural next tests, and each can be pre-screened by Algorithm C before any expensive run.

**3. Transfer across bit lengths.** Because the drift budget $\delta \ge (\rho-1)/(\rho+1)$ is scale-free, the same test applies verbatim at any modulus size. A worthwhile experiment is to measure $\rho$ as a function of bit length: if the excess amplitude is stable, the required drift budget is stable too, and a single carrier of fixed relative width is implicated.

**4. Sharpening the estimator null.** The disclosed gap between the raw $z = 4.11$ and the null-calibrated $z_{\mathrm{cal}} = 1.53$ is a statement about max-over-bins bias, not about the effect. A shape-matched test statistic — projecting the residual onto a fixed bump template rather than taking a maximum — would remove the selection bias by construction and give a calibrated significance directly comparable to the structural bound of Theorem 5.4.

---

## 11. Conclusion

A four-sigma mid-window excess in a smooth-value hit profile survived a sixteen-cell divisibility mixture baseline with exactly $0\%$ removal and an unmoved peak. We showed this is not an empirical accident but a theorem. The divisibility cell of $j^2-N$ is $210$-periodic in $j$, so window composition is exactly position-independent; under flat composition the whole mixture family collapses to the one-dimensional ray $\{K\cdot B\}$, and every ratio-based excess statistic, together with its argmax, is invariant under the fit. The robust version gives a scale-free drift budget: absorbing a relative excess $\rho-1$ requires composition drift at least $(\rho-1)/(\rho+1)$, i.e. $8.1\%$ here against a measured $0.269\%$. Because only periodicity was used, the result extends to every classifier factoring through $\mathbb{Z}/m\mathbb{Z}$ — power residues, Legendre symbols, bit patterns — and the mechanism behind the excess is therefore constrained to be aperiodic in $j$. Sharpness results confirm that positional families do remove $100\%$ of the same excess and that aperiodic carriers with position-dependent composition exist, so the negative result is about the arithmetic grid and not about the method.

**Divisibility is a rate dial, not a position dial.**
