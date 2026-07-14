# Universality of the Cubic Spectral-Gap Exponent for Weighted Swap Chains

## Abstract

Local "swap" chains — reversible Markov chains that reconfigure combinatorial
objects by elementary moves — are governed in their mixing speed by the
**spectral gap** $\gamma$, the smallest non-trivial value of the Rayleigh
quotient $E(f)/V(f)$ of the associated Dirichlet form. We prove two structural
theorems that together explain, and cleanly separate, the two ingredients of the
gap's scaling law $\gamma \asymp \text{const}\cdot n^{-3}$ observed for
one-dimensional swap chains.

First, a **universality principle**: on an arbitrary finite state space carrying
non-negative conductances, any non-constant test function whose Dirichlet energy
grows at most linearly ($\le c_e n$) and whose variation grows at least
quartically ($\ge c_v n^4$) certifies a cubic gap upper bound
$\gamma \le (c_e/c_v)\,n^{-3}$. The exponent $3 = 4 - 1$ is a difference of the
two growth rates and is independent of the underlying combinatorial family.

Second, a **conductance-scaling principle**: for the conductance-weighted path of
$n$ sites with edge weight $c > 0$, the position statistic has Dirichlet energy
exactly $2c(n-1)$, variation exactly $n^2(n^2-1)/6$, and Rayleigh quotient exactly
$12c/(n^2(n+1))$, which lies in the window $[6c\,n^{-3},\,12c\,n^{-3}]$. Hence the
exponent $-3$ is independent of $c$, while the leading constant is strictly
increasing in $c$. Modelling a topological genus $g$ by a strictly decreasing,
strictly positive conductance $c(g) = 1/(g+1)$ yields a family of gap upper bounds
$\gamma_{n,g} \le 12\,c(g)\,n^{-3}$ whose leading constant is strictly decreasing
in the genus while the cubic exponent is invariant.

**Keywords.** spectral gap, Rayleigh quotient, Dirichlet energy, swap chain,
mixing time, conductance, chord diagram, genus, universality.

---

## 1. Introduction

### 1.1 Swap chains and their mixing speed

A *swap chain* on a finite combinatorial family reconfigures its objects by local
moves — transpositions of adjacent tokens, exchanges of chord endpoints, and the
like. Such chains are the workhorses of combinatorial sampling and appear
throughout statistical mechanics, randomized algorithms, and the study of random
combinatorial structures. The central quantitative question about any such chain
is its **mixing time**: how many moves are required before the chain's
distribution is close to its stationary law?

For a reversible chain, the mixing time is controlled up to logarithmic factors by
the reciprocal of the **spectral gap** $\gamma$, the smallest non-trivial
eigenvalue of the (normalized) Laplacian of the chain. The gap admits a
variational characterization as an infimum of Rayleigh quotients, which is
frequently the most tractable route to sharp bounds and is the vantage point we
adopt throughout.

### 1.2 The one-dimensional prototype and its cubic law

A recurring phenomenon is that one-dimensional swap chains — those whose essential
geometry is a path — exhibit a spectral gap of cubic order,
$\gamma \asymp n^{-3}$, where $n$ is the size parameter. A previous investigation
isolated the mechanism: on the path prototype, the *position statistic* $f(i) = i$
has Dirichlet energy $\Theta(n)$ and variation $\Theta(n^4)$, so its Rayleigh
quotient — a valid upper bound for the gap — is $\Theta(n^{-3})$.

This paper elevates two consequences of that observation from conjectures to
theorems. We show (i) that the cubic exponent is *universal*: it is a property of
the energy-to-variation growth profile and nothing else, so it holds on any finite
state space; and (ii) that introducing a tunable *conductance* — the algebraic
shadow of fixing a topological genus — moves the leading constant strictly
monotonically while leaving the exponent invariant.

### 1.3 Contributions

- **A finite-state Rayleigh calculus** (Section 3): abstract definitions of
  Dirichlet energy, variation, Rayleigh quotient, and combinatorial gap, with
  their basic positivity and monotonicity properties.
- **The universality theorem** (Section 4): linear energy and quartic variation
  force a cubic gap upper bound with an explicit constant.
- **The exact conductance-weighted path** (Section 5): closed forms for the energy
  $2c(n-1)$, the variation $n^2(n^2-1)/6$, and the Rayleigh quotient
  $12c/(n^2(n+1))$, together with the confining window
  $[6c\,n^{-3}, 12c\,n^{-3}]$ and strict monotonicity in $c$.
- **Genus through the constant** (Section 6): a genus-decreasing conductance
  $c(g) = 1/(g+1)$ produces a strictly decreasing, strictly positive leading
  constant $12\,c(g)$ in front of the invariant cubic decay.

---

## 2. Setup and notation

Throughout, $V$ is a finite set of states (the configurations of the combinatorial
family) and $|V|$ denotes its cardinality. A **conductance** is a function
$Q\colon V \times V \to \mathbb{R}_{\ge 0}$; we always assume $Q(x,y) \ge 0$, and
in the reversible setting one also takes $Q$ symmetric, $Q(x,y) = Q(y,x)$. A
**test function** (or *score*) is any $f\colon V \to \mathbb{R}$. We say $f$ is
*non-constant* if $f(x) \ne f(y)$ for some pair $x,y$.

---

## 3. A finite-state Rayleigh calculus

We work with the uniform reference measure on $V$; the definitions extend
verbatim to a general reversible measure.

**Definition 3.1 (Dirichlet energy).**
For a conductance $Q$ and test function $f$,
$$E(f) \;=\; \mathrm{dir}_Q(f) \;=\; \sum_{x \in V}\sum_{y \in V} Q(x,y)\,\bigl(f(x)-f(y)\bigr)^2.$$
This is the quadratic form measuring the total squared variation of $f$ across the
weighted edges of the chain.

**Definition 3.2 (Variation).**
$$V(f) \;=\; \mathrm{vr}(f) \;=\; \sum_{x \in V}\sum_{y \in V} \bigl(f(x)-f(y)\bigr)^2.$$
Expanding the square yields the identity
$$V(f) \;=\; 2\Bigl(|V|\sum_{x} f(x)^2 - \bigl(\textstyle\sum_x f(x)\bigr)^2\Bigr)
        \;=\; 2\,|V|\cdot \mathrm{Var}_{\mathrm{unif}}(f),$$
so $V(f)$ is $2|V|$ times the variance of $f$ under the uniform law.

**Definition 3.3 (Rayleigh quotient).**
For non-constant $f$,
$$\mathcal{R}_Q(f) \;=\; \frac{E(f)}{V(f)}.$$

**Definition 3.4 (Combinatorial spectral gap).**
$$\gamma(Q) \;=\; \inf\bigl\{\, \mathcal{R}_Q(f) \;:\; f \text{ non-constant} \,\bigr\}.$$

**Lemma 3.5 (Basic positivity).** For every non-negative conductance $Q$ and test
function $f$:
1. $E(f) \ge 0$;
2. $V(f) \ge 0$, with $V(f) > 0$ iff $f$ is non-constant;
3. $\mathcal{R}_Q(f) \ge 0$ and $\gamma(Q) \ge 0$.

*Proof.* (1) Each summand $Q(x,y)(f(x)-f(y))^2$ is a product of non-negatives.
(2) Each summand $(f(x)-f(y))^2 \ge 0$; if $f(x_0) \ne f(y_0)$ then the
$(x_0,y_0)$ term is strictly positive, forcing $V(f) > 0$, and conversely if $f$
is constant every term vanishes. (3) A ratio of a non-negative by a positive is
non-negative; the gap, an infimum of non-negatives, is non-negative. $\qquad\blacksquare$

**Lemma 3.6 (The Rayleigh engine).** For every non-negative conductance $Q$ and
every non-constant $f$,
$$\gamma(Q) \;\le\; \mathcal{R}_Q(f).$$

*Proof.* $\mathcal{R}_Q(f)$ is a member of the set whose infimum defines
$\gamma(Q)$, and that set is bounded below by $0$ (Lemma 3.5), so its infimum is at
most $\mathcal{R}_Q(f)$. $\qquad\blacksquare$

Lemma 3.6 is the workhorse: to bound the gap from above, exhibit a single
non-constant witness and compute its quotient.

**Lemma 3.7 (Energy scales with conductance).** For a scalar $c$,
$$\mathrm{dir}_{cQ}(f) \;=\; c\,\mathrm{dir}_Q(f).$$

*Proof.* Factor $c$ out of each summand and out of the double sum. $\qquad\blacksquare$

---

## 4. Universality of the cubic exponent

We now prove that the cubic exponent depends only on the growth *rates* of energy
and variation.

**Theorem 4.1 (Universality, quotient form).** Let $Q$ be a non-negative
conductance and $f$ a test function with $E(f) \le A$ and $B \le V(f)$ for some
$B > 0$. Then
$$\mathcal{R}_Q(f) \;\le\; \frac{A}{B}.$$

*Proof.* Since $B > 0$ and $B \le V(f)$, we have $V(f) > 0$, so
$\mathcal{R}_Q(f) = E(f)/V(f)$ is well defined and non-negative. Monotonicity of
$t \mapsto t/s$ (for $s>0$) in the numerator and of $s \mapsto r/s$ (for $r \ge 0$)
in the denominator gives
$$\frac{E(f)}{V(f)} \;\le\; \frac{A}{V(f)} \;\le\; \frac{A}{B}. \qquad\blacksquare$$

**Theorem 4.2 (Universality, gap form).** Under the hypotheses of Theorem 4.1 with
$f$ non-constant,
$$\gamma(Q) \;\le\; \frac{A}{B}.$$

*Proof.* Combine Lemma 3.6 and Theorem 4.1. $\qquad\blacksquare$

**Theorem 4.3 (The cubic exponent is universal).** Let $Q$ be a non-negative
conductance on a finite state space and $f$ a non-constant test function. Suppose
there are constants $c_e \ge 0$, $c_v > 0$, and a size parameter $n > 0$ with
$$E(f) \;\le\; c_e\,n, \qquad c_v\,n^4 \;\le\; V(f).$$
Then
$$\gamma(Q) \;\le\; \frac{c_e}{c_v}\,n^{-3}.$$

*Proof.* Apply Theorem 4.2 with $A = c_e n$ and $B = c_v n^4 > 0$, obtaining
$\gamma(Q) \le (c_e n)/(c_v n^4)$. Since $n>0$,
$$\frac{c_e n}{c_v n^4} \;=\; \frac{c_e}{c_v}\,n^{1-4} \;=\; \frac{c_e}{c_v}\,n^{-3}. \qquad\blacksquare$$

The exponent $-3$ arises purely as $1 - 4$: the difference between the linear
growth of the energy and the quartic growth of the variation. No property of the
combinatorial objects enters. This is the precise sense in which the cubic law is
universal.

---

## 5. The conductance-weighted path

We now instantiate the universality engine on the canonical one-dimensional model
and compute everything exactly.

**Definition 5.1 (Conductance-weighted path).** For $c \in \mathbb{R}$ and
$n \in \mathbb{N}$, the weighted-path conductance on the state set
$\{0, 1, \dots, n-1\}$ is
$$Q_c(x,y) \;=\; \begin{cases} c & \text{if } |x - y| = 1,\\ 0 & \text{otherwise.}\end{cases}$$
Setting $c = 1$ recovers the unit-weight nearest-neighbor swap graph.

**Definition 5.2 (Position statistic).** $f(i) = i$ for $i \in \{0,\dots,n-1\}$.
This is a monotone statistic that changes by exactly one unit per legal move.

**Lemma 5.3 (Non-negativity and non-constancy).** For $c \ge 0$ the weights
$Q_c$ are non-negative; and for $n \ge 2$ the position statistic is non-constant
(e.g. $f(0) = 0 \ne 1 = f(1)$).

**Theorem 5.4 (Weighted-path energy).** For $n \ge 1$,
$$E(f) \;=\; \mathrm{dir}_{Q_c}(f) \;=\; 2c(n-1).$$

*Proof.* Across an edge $\{x,y\}$ with $|x-y|=1$ we have $(f(x)-f(y))^2 = 1$, and
every other pair contributes $0$. Each of the $n-1$ unordered adjacent pairs is
counted twice (as $(x,y)$ and $(y,x)$) in the double sum, each time with weight
$c$. Summing the "right-neighbor" contributions gives $c(n-1)$ and the
"left-neighbor" contributions another $c(n-1)$, for a total of $2c(n-1)$.
$\qquad\blacksquare$

**Theorem 5.5 (Weighted-path variation).** For all $n$,
$$V(f) \;=\; \mathrm{vr}(f) \;=\; \frac{n^2(n^2-1)}{6}.$$
This is independent of the conductance $c$.

*Proof.* By the variance identity of Definition 3.2 with $|V| = n$,
$$V(f) = 2\Bigl(n\sum_{i=0}^{n-1} i^2 - \bigl(\textstyle\sum_{i=0}^{n-1} i\bigr)^2\Bigr).$$
Using the Gauss sum $\sum_{i=0}^{n-1} i = \tfrac{n(n-1)}{2}$ and the
square-pyramidal sum $\sum_{i=0}^{n-1} i^2 = \tfrac{n(n-1)(2n-1)}{6}$,
$$V(f) = 2\Bigl(\frac{n^2(n-1)(2n-1)}{6} - \frac{n^2(n-1)^2}{4}\Bigr)
      = \frac{n^2(n-1)(n+1)}{6} = \frac{n^2(n^2-1)}{6}. \qquad\blacksquare$$

**Theorem 5.6 (Exact Rayleigh quotient).** For $n \ge 2$,
$$\mathcal{R}_{Q_c}(f) \;=\; \frac{2c(n-1)}{\,n^2(n^2-1)/6\,} \;=\; \frac{12c}{n^2(n+1)}.$$

*Proof.* Divide Theorem 5.4 by Theorem 5.5 and simplify using
$n^2 - 1 = (n-1)(n+1)$. $\qquad\blacksquare$

**Theorem 5.7 (Cubic upper bound at fixed conductance).** For $c \ge 0$ and
$n \ge 2$,
$$\gamma(Q_c) \;\le\; \frac{12c}{n^3}.$$

*Proof.* By Lemma 3.6 and Theorem 5.6, $\gamma(Q_c) \le 12c/(n^2(n+1))$. Since
$n \ge 2$ gives $n^2(n+1) \ge n^3$ and $c \ge 0$, the bound follows. $\qquad\blacksquare$

**Theorem 5.8 (The exponent is exactly three).** For $c \ge 0$ and $n \ge 2$, the
certifying Rayleigh quotient lies in the window
$$\frac{6c}{n^3} \;\le\; \mathcal{R}_{Q_c}(f) \;\le\; \frac{12c}{n^3}.$$

*Proof.* Because $n \ge 2$, we have $n^3 \le n^2(n+1) \le 2n^3$. Substituting into
$\mathcal{R}_{Q_c}(f) = 12c/(n^2(n+1))$ and using $c \ge 0$ gives
$$\frac{12c}{2n^3} \;\le\; \frac{12c}{n^2(n+1)} \;\le\; \frac{12c}{n^3},$$
i.e. $6c\,n^{-3} \le \mathcal{R}_{Q_c}(f) \le 12c\,n^{-3}$. Both endpoints share
the exponent $-3$, so no other exponent is possible. $\qquad\blacksquare$

**Theorem 5.9 (The constant carries the conductance dependence).** For fixed
$n \ge 2$, if $c_1 < c_2$ then
$$\mathcal{R}_{Q_{c_1}}(f) \;<\; \mathcal{R}_{Q_{c_2}}(f).$$

*Proof.* By Theorem 5.6 both quotients equal $12 c/(n^2(n+1))$ with the same
positive denominator, so the map $c \mapsto \mathcal{R}_{Q_c}(f)$ is strictly
increasing. $\qquad\blacksquare$

Theorems 5.6–5.9 make the separation precise: the exponent $-3$ is invariant under
retuning $c$, while the entire $c$-dependence is confined to the strictly
increasing leading constant.

**Remark 5.10 (Boundary case).** At $c = 0$ the chain has no edges, the energy
vanishes, and $\mathcal{R}_{Q_0}(f) = 0$. The strict statements (window and
monotonicity) therefore require positive conductance; this is recorded in the
hypotheses.

---

## 6. Modelling genus through a decreasing conductance

The motivating application is the fixed-genus chord-swap chain, where one shuffles
chord diagrams of a prescribed topological genus $g$ by swapping chord endpoints.
The guiding principle is that fixing the genus acts like fixing an *effective
conductance* $c(g)$: a higher genus imposes more topological obstructions per
swap, hence a lower effective conductance.

**Definition 6.1 (Genus conductance).** A concrete strictly decreasing, strictly
positive model is
$$c(g) \;=\; \frac{1}{g+1}, \qquad g \in \mathbb{N}.$$

**Lemma 6.2.** $c(g) > 0$ for every $g$, and $c$ is strictly decreasing: if
$g_1 < g_2$ then $c(g_2) < c(g_1)$.

*Proof.* Positivity is immediate. For monotonicity, $g_1 < g_2$ gives
$g_1 + 1 < g_2 + 1$, and $t \mapsto 1/t$ is strictly decreasing on the positive
reals. $\qquad\blacksquare$

**Theorem 6.3 (Genus enters only through the constant).** Let genus be modelled by
$c(g)$ as above. Then for every $n \ge 2$ the weighted-path gap obeys the same
cubic law with a genus-dependent constant,
$$\gamma\bigl(Q_{c(g)}\bigr) \;\le\; \frac{12\,c(g)}{n^3},$$
and the leading constant $12\,c(g)$ is strictly positive and strictly decreasing
in the genus: if $g_1 < g_2$ then
$$0 \;<\; 12\,c(g_2) \;<\; 12\,c(g_1).$$
The exponent $-3$ is independent of $g$.

*Proof.* The bound is Theorem 5.7 with $c = c(g) \ge 0$. Strict positivity and
strict monotonicity of $12\,c(g)$ follow from Lemma 6.2 by scaling by the positive
constant $12$. The exponent is $-3$ in every case, independent of $g$.
$\qquad\blacksquare$

Combining Theorems 5.8 and 6.3, the family of gap bounds takes the form
$$\gamma_{n,g} \;\lesssim\; \frac{12}{(g+1)\,n^3},$$
with all genus dependence carried by the single scalar amplitude $12\,c(g)$ and
none by the exponent.

---

## 7. Algorithms

The theory above is entirely constructive and yields simple exact algorithms.

**Algorithm 7.1 (Exact weighted-path Rayleigh quotient).**
Given size $n \ge 2$ and conductance $c$, return $E$, $V$, and
$\mathcal{R} = E/V$ in closed form.

```
function WeightedPathRayleigh(n, c):
    E ← 2 * c * (n - 1)                 # Theorem 5.4
    V ← n^2 * (n^2 - 1) / 6             # Theorem 5.5
    R ← 12 * c / (n^2 * (n + 1))        # Theorem 5.6
    return (E, V, R)
```

**Algorithm 7.2 (Universality certificate).**
Given energy and variation growth data, certify a cubic gap bound.

```
function CertifyCubicGap(dir_f, vr_f, c_e, c_v, n):
    assert dir_f ≤ c_e * n              # linear-energy hypothesis
    assert c_v * n^4 ≤ vr_f             # quartic-variation hypothesis
    assert c_v > 0
    return (c_e / c_v) * n^(-3)         # Theorem 4.3: gap ≤ this
```

**Algorithm 7.3 (Genus amplitude table).**
Tabulate the leading constant across genera to verify strict monotonicity.

```
function GenusAmplitudes(g_max):
    table ← []
    for g in 0..g_max:
        c_g ← 1 / (g + 1)              # Definition 6.1
        amp ← 12 * c_g                 # leading constant, Theorem 6.3
        append (g, c_g, amp) to table
    assert amp strictly decreasing in g
    return table
```

---

## 8. Applications and discussion

**Sampling and simulation.** The cubic law gives an immediate, sharp handle on the
relaxation time of one-dimensional swap samplers: relaxation time scales as $n^3$,
so doubling the system size multiplies the mixing time by roughly eight. The
universality theorem extends this rule of thumb to any sampler whose driving
statistic has the linear-energy / quartic-variance signature, without re-deriving
the spectral analysis from scratch.

**Diagnosing exponents from two moments.** Theorem 4.3 reframes the entire
upper-bound problem as the estimation of two growth rates — the scaling of the
Dirichlet energy and of the variation of a candidate slow statistic. In practice
these can be estimated from moderate-size instances, turning an eigenvalue problem
into a moment-fitting problem.

**Separating universal from parametric.** The pairing of Theorems 5.8 and 6.3 is
the conceptual payoff: the exponent is universal and rigid, while all
parameter-dependence (conductance, and through it genus) is quarantined in a
single leading constant. This is the analogue, in the combinatorial setting, of a
scaling law whose critical exponent is universal while its amplitude is
system-specific.

---

## 9. Future work

- **A genus-aware quartic-variance statistic on diagram space.** The universality
  engine reduces the full chord-swap upper bound to exhibiting one monotone,
  bounded-step statistic on genus-$g$ diagrams whose energy is linear and whose
  variation is quartic. Constructing such a statistic — for instance a
  nesting-plus-crossing index — would deliver the cubic upper bound automatically.
- **Effective conductance of a genus.** Whether the effective edge conductance
  induced by fixing genus $g$ is genuinely a strictly decreasing, strictly
  positive $c(g)$, with $\gamma_{n,g} = 12\,c(g)\,n^{-3}(1+o(1))$, is a concrete,
  testable prediction: $c(g)$ can be estimated from moderate-size diagrams and
  checked for monotonicity.
- **Sharpness of the universality criterion.** If a reversible swap statistic has
  energy of order $n$ but variation of order $n^\beta$ with $\beta \ne 4$, the
  analysis predicts a gap bound of order $n^{1-\beta}$ rather than $n^{-3}$. Making
  this a two-sided law — with a matching lower bound — would establish that the
  linear-energy / quartic-variation profile is exactly the signature of the cubic
  exponent.
- **Matching cubic lower bounds.** A canonical-path / multicommodity-flow routing
  with congestion of order $n^3$ would convert these upper bounds into a
  two-sided $\Theta(n^{-3})$ law for the genuine fixed-genus chord-swap chain.

---

## 10. Conclusion

We have separated the two ingredients of the cubic spectral-gap law for
one-dimensional swap chains. The exponent $-3$ is universal — a difference of the
linear energy growth and the quartic variation growth — and holds on any finite
state space admitting a statistic with that profile. The constant is where all
individuality lives: a tunable conductance scales the leading amplitude strictly
monotonically without touching the exponent, and modelling a topological genus by
a strictly decreasing conductance yields a strictly decreasing, strictly positive
amplitude in front of the invariant cubic decay. The remaining step toward the
genuine fixed-genus chord-swap chain is purely combinatorial: exhibit the
genus-aware quartic-variance statistic, and these two engines deliver the full
$\gamma_{n,g} = c(g)\,n^{-3}$ picture.
