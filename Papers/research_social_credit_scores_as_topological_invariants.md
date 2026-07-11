# Social Credit Scores as Topological Invariants: Fixed-Point Attractors, a Cantor-Set Reputation Space, and the Inevitability of Phase Transitions

## Abstract

We develop a rigorous mathematical model of *social credit systems* — rules that
assign to each member of a population a score in a totally ordered value space —
and analyze the topological and dynamical structure that such systems necessarily
possess. Three phenomena emerge and are proved in full. First, on a compact
population any continuous scoring map attains a maximal and a minimal member, and
the natural affine credit-update dynamics $x \mapsto c + kx$ has, for damping
$0 \le k < 1$, a globally attracting equilibrium $c/(1-k)$; moreover any monotone
self-map of the score interval $[0,1]$ possesses an equilibrium by a
Knaster–Tarski argument. Second, when scores accumulate from an infinite stream
of weighted binary verdicts with base-three weights, the set of attainable scores
is exactly the middle-thirds Cantor set: it satisfies the iterated-function-system
self-similarity equation $C = \tfrac13 C \cup (\tfrac13 C + \tfrac23)$, the
verdict-to-score encoding is injective, and the attractor is therefore
uncountable, totally disconnected, and of Hausdorff dimension $\log 2/\log 3$.
Third, we show that the disjoint gaps of this attractor force *phase transitions*:
the threshold tier classifier is discontinuous exactly at its cutoff and
maximally sensitive there, and — because the real line is connected — every
continuous binary classifier is constant, so any classifier that separates two
members must be discontinuous. Together these results recast qualitative worries
about reputation systems ("small changes, big effects") as precise theorems about
attractors, fractals, and connectivity.

**Keywords.** Social credit, fixed-point attractor, contraction mapping, Cantor
set, iterated function system, self-similarity, phase transition, connectedness,
Knaster–Tarski.

---

## 1. Introduction

A *social credit system* assigns to every member of a population a numerical
score summarizing their standing, and updates that score over time in response to
behavior. Public debate about such systems is largely qualitative: critics warn
that they are unstable, that small differences in record produce large
differences in outcome, and that they harden into rigid tiers. This paper asks
what is *provably* true about such systems once they are modeled honestly, and
finds that the qualitative worries are shadows of exact mathematical structure.

We model a scoring rule as a map from a population $X$ into a totally ordered,
complete value space, for which the real line $\mathbb{R}$ is the prototype. Three
layers of structure are analyzed:

1. **Statics and dynamics (Section 3).** Extremal members exist on compact
   populations; affine updates contract to a unique equilibrium; monotone updates
   have order-theoretic fixed points.
2. **The reputation space (Section 4).** When scores are built from an infinite
   sequence of weighted binary verdicts, the attainable-score set is the Cantor
   set, characterized by self-similarity and injectivity.
3. **Discreteness and phase transitions (Section 5).** Thresholding a continuous
   score into discrete tiers necessarily introduces discontinuities; connectivity
   makes phase transitions inevitable.

All statements below are theorems with proof sketches; the arguments are
elementary but the conclusions are structural and, we believe, illuminating.

## 2. The model

**Definition 2.1 (Scoring map).** A *population* is a topological space $X$. A
*scoring map* is a function $f : X \to \mathbb{R}$ assigning to each member a
real-valued score. Continuity of $f$ formalizes the assumption that similar
members receive similar scores.

**Definition 2.2 (Affine update).** Given a *reward* $c \in \mathbb{R}$ and a
*damping factor* $k \in \mathbb{R}$, one round of credit revision is the map
$$ S_{c,k}(x) = c + kx. $$
The score after $n$ rounds starting from $x_0$ is $x_n = S_{c,k}^{\,n}(x_0)$
(the $n$-fold composition).

**Definition 2.3 (Verdict history and encoding).** A *verdict history* is an
infinite sequence $a : \mathbb{N} \to \{\text{commended}, \text{flagged}\}$,
which we identify with $a : \mathbb{N} \to \{\text{true},\text{false}\}$. The
*ternary credit encoding* of $a$ is
$$ \Phi(a) = \sum_{n=0}^{\infty} w_n(a), \qquad
   w_n(a) = \frac{2 \cdot [\,a_n = \text{true}\,]}{3^{\,n+1}}, $$
where $[\,a_n = \text{true}\,]$ equals $1$ if the $n$-th verdict is a commendation
and $0$ otherwise. We write $C = \operatorname{range}\Phi \subseteq \mathbb{R}$
for the set of all attainable scores.

**Definition 2.4 (Prepending a verdict).** For a verdict $b$ and a history $a$,
the history $b \cdot a$ ("$b$ prepended to $a$") is defined by $(b\cdot a)_0 = b$
and $(b\cdot a)_{k+1} = a_k$. Every history equals its head prepended to its
tail: $a = a_0 \cdot (n \mapsto a_{n+1})$.

**Definition 2.5 (Tier classifier).** For a threshold $t \in \mathbb{R}$, the
*tier* of a score $x$ is
$$ \tau_t(x) = \begin{cases} \text{true} & t \le x, \\ \text{false} & x < t,
\end{cases} $$
a map $\mathbb{R} \to \{\text{true},\text{false}\}$ into the *discrete* two-point
value space.

## 3. Statics and dynamics of scores

### 3.1 Extremal members

**Theorem 3.1 (Extremal members).** *Let $X$ be a nonempty compact topological
space and $f : X \to \mathbb{R}$ continuous. Then there exist $a, b \in X$ with
$f(x) \le f(a)$ and $f(b) \le f(x)$ for all $x \in X$.*

*Proof sketch.* The continuous image $f(X) = \operatorname{range} f$ of a compact
space is compact, hence closed and bounded in $\mathbb{R}$, and nonempty. A
nonempty compact subset of $\mathbb{R}$ has a greatest and a least element; their
preimages are the desired maximal and minimal members. $\qquad\blacksquare$

This is the Extreme Value Theorem: a compact population under a continuous
scoring rule always has an identifiable best- and worst-ranked individual.

### 3.2 The affine attractor

**Lemma 3.2 (Closed form).** *If $k \ne 1$, then for all $n$,*
$$ S_{c,k}^{\,n}(x_0) = k^n x_0 + c\,\frac{1 - k^n}{1 - k}. $$

*Proof sketch.* Induction on $n$. The base case is $x_0$. For the step, apply
$S_{c,k}$ to the inductive expression and simplify using
$k\cdot k^n = k^{n+1}$ and a common denominator. $\qquad\blacksquare$

**Theorem 3.3 (Global attractor).** *If $0 \le k < 1$, then for every $x_0$,*
$$ S_{c,k}^{\,n}(x_0) \longrightarrow \frac{c}{1-k} \quad (n \to \infty). $$
*Moreover $x^\star = c/(1-k)$ is the unique fixed point of $S_{c,k}$ when
$k \ne 1$.*

*Proof sketch.* Since $0 \le k < 1$, $k^n \to 0$. In the closed form of
Lemma 3.2 the term $k^n x_0 \to 0$ and $c(1-k^n)/(1-k) \to c/(1-k)$, so the
sequence converges to $c/(1-k)$ irrespective of $x_0$. For the fixed point,
$S_{c,k}(x)=x$ reads $c + kx = x$, i.e. $c = (1-k)x$, which since $1 - k \ne 0$
has the unique solution $x = c/(1-k)$; a direct substitution shows $x^\star$
indeed satisfies it. $\qquad\blacksquare$

Interpretively: with fading memory, a member's long-run standing is determined
entirely by the ratio of reward to persistence, not by initial conditions. The
equilibrium is a genuine attractor because $S_{c,k}$ is a contraction with
Lipschitz constant $k < 1$.

### 3.3 Order-theoretic equilibria

**Theorem 3.4 (Knaster–Tarski for scores).** *Let $f : \mathbb{R} \to
\mathbb{R}$ be monotone (order-preserving) and suppose $f$ maps $[0,1]$ into
$[0,1]$. Then $f$ has a fixed point in $[0,1]$.*

*Proof sketch.* Let $S = \{ x \in [0,1] : x \le f(x)\}$. Then $0 \in S$ because
$f(0) \in [0,1]$ gives $0 \le f(0)$, so $S$ is nonempty and bounded above by $1$;
let $s = \sup S$. For each $x \in S$, $x \le s$ implies $f(x) \le f(s)$ by
monotonicity, and $x \le f(x) \le f(s)$; hence $f(s)$ is an upper bound of $S$,
giving $s \le f(s)$. Applying $f$ (monotone) yields $f(s) \le f(f(s))$, so
$f(s) \in S$ and therefore $f(s) \le s$. Thus $f(s) = s$. $\qquad\blacksquare$

No continuity or contraction is needed: monotone feedback alone forces an
equilibrium score.

## 4. The reputation space is a Cantor set

We now analyze the encoding $\Phi$ of Definition 2.3 and prove that its range is
the middle-thirds Cantor set.

### 4.1 Summability and bounds

**Lemma 4.1 (Summability).** *For every history $a$, the weight series
$\sum_n w_n(a)$ converges.*

*Proof sketch.* Each term satisfies $0 \le w_n(a) \le 2/3^{n+1}$, and the
dominating series $\sum_n 2/3^{n+1} = 2\sum_n (1/3)^{n}/3$ is a convergent
geometric series. Comparison gives summability (and absolute convergence, as all
terms are nonnegative). $\qquad\blacksquare$

**Theorem 4.2 (Scores lie in $[0,1]$).** *For every history $a$, $0 \le \Phi(a)
\le 1$.*

*Proof sketch.* Nonnegativity is termwise. For the upper bound, term-by-term
$w_n(a) \le 2/3^{n+1}$, and
$$ \sum_{n=0}^\infty \frac{2}{3^{n+1}}
   = \frac{2}{3}\cdot \frac{1}{1 - 1/3} = 1, $$
so $\Phi(a) \le 1$, with equality when every verdict is a commendation.
$\qquad\blacksquare$

### 4.2 Self-similarity: the iterated function system

The structural heart of the model is how the encoding transforms under
prepending a verdict.

**Lemma 4.3 (Prepend identities).** *For every history $a$,*
$$ \Phi(\text{false}\cdot a) = \frac{\Phi(a)}{3},
   \qquad
   \Phi(\text{true}\cdot a) = \frac{\Phi(a)}{3} + \frac{2}{3}. $$

*Proof sketch.* Split off the $n=0$ term of $\Phi(b\cdot a)$ using summability
(Lemma 4.1). The zeroth weight is $0$ if $b=\text{false}$ and $2/3$ if
$b=\text{true}$. Each remaining term reindexes as
$w_{n+1}(b\cdot a) = w_n(a)/3$, because prepending shifts the exponent of $3$ up
by one; summing the shifted tail gives $\Phi(a)/3$. Adding the zeroth term yields
the two identities. $\qquad\blacksquare$

**Theorem 4.4 (Self-similarity).** *The attainable-score set
$C = \operatorname{range}\Phi$ satisfies*
$$ C = \left(\tfrac13\, C\right) \cup \left(\tfrac13\, C + \tfrac23\right)
     = f_0(C) \cup f_1(C), $$
*where $f_0(x) = x/3$ and $f_1(x) = x/3 + 2/3$. Consequently $C$ is the unique
nonempty compact invariant set of the iterated function system $\{f_0, f_1\}$,
i.e. the middle-thirds Cantor set.*

*Proof sketch.* ($\subseteq$) Given $y = \Phi(a)$, split on the head $a_0$. If
$a_0=\text{false}$, then $y = \Phi(a)= \Phi(\text{false}\cdot a') = \Phi(a')/3
\in f_0(C)$ where $a'$ is the tail; if $a_0=\text{true}$, similarly
$y \in f_1(C)$. ($\supseteq$) Conversely, any $f_0(\Phi(a)) = \Phi(a)/3 =
\Phi(\text{false}\cdot a) \in C$ and $f_1(\Phi(a)) = \Phi(\text{true}\cdot a)\in
C$. The two identities are Lemma 4.3. Uniqueness of the invariant set follows
from Hutchinson's theorem: $f_0, f_1$ are contractions with ratio $1/3$, so the
Hutchinson operator on nonempty compact subsets of $[0,1]$ (with the Hausdorff
metric) is a contraction and has a unique fixed point, which is the classical
Cantor set. $\qquad\blacksquare$

Because $f_0(C) \subseteq [0,\tfrac13]$ and $f_1(C) \subseteq [\tfrac23, 1]$ are
disjoint, the union is a *disjoint* self-similar decomposition — the source of
the gaps.

### 4.3 Injectivity: no information is lost

**Lemma 4.5 (The head is legible).** *If $\Phi(a) = \Phi(b)$ then $a_0 = b_0$.*

*Proof sketch.* Write $\Phi(a)$ via Lemma 4.3 as $\Phi(a')/3$ if $a_0 =
\text{false}$ and $\Phi(a')/3 + 2/3$ if $a_0 = \text{true}$, where $a'$ is the
tail; likewise for $b$. Since every tail score lies in $[0,1]$ (Theorem 4.2), a
false head gives a value in $[0,\tfrac13]$ and a true head a value in
$[\tfrac23, 1]$. These intervals are disjoint, so equal scores force equal heads.
$\qquad\blacksquare$

**Theorem 4.6 (Injectivity).** *The encoding $\Phi$ is injective: distinct
verdict histories have distinct scores.*

*Proof sketch.* Suppose $\Phi(a) = \Phi(b)$. By Lemma 4.5, $a_0 = b_0$.
Subtracting the common zeroth term and multiplying by $3$ (using Lemma 4.3) gives
$\Phi(a') = \Phi(b')$ for the tails $a', b'$. Iterating shows $a_n = b_n$ for
every $n$, so $a = b$. $\qquad\blacksquare$

**Corollary 4.7 (Cardinality and topology).** *The attractor $C$ is uncountable.
Endowing $\{\text{true},\text{false}\}^{\mathbb{N}}$ with the product (Cantor
space) topology, $\Phi$ is a continuous injection from a compact space into the
Hausdorff line, hence a homeomorphism onto $C$; therefore $C$ is compact,
perfect, and totally disconnected, with Hausdorff dimension $\log 2/\log 3$ and
Lebesgue measure zero.*

*Proof sketch.* Injectivity (Theorem 4.6) plus the uncountability of
$\{\text{true},\text{false}\}^{\mathbb{N}}$ gives uncountability of $C$.
Continuity of $\Phi$ follows since the partial sums converge uniformly (each term
is bounded by $2/3^{n+1}$), and a continuous bijection from a compact space to a
Hausdorff space is a homeomorphism onto its image. The dimension and measure are
the standard invariants of the middle-thirds Cantor set: with two maps of ratio
$1/3$ satisfying the open set condition, the similarity dimension is
$\log 2/\log 3$, and a set of dimension $< 1$ has one-dimensional Lebesgue
measure zero. $\qquad\blacksquare$

## 5. Discreteness forces phase transitions

The disjoint gaps of $C$ are not merely aesthetic; they are the mechanism by
which small perturbations cause large, discontinuous changes. We make this
precise via the tier classifier of Definition 2.5.

**Theorem 5.1 (Critical point at the cutoff).** *The tier classifier $\tau_t$ is
discontinuous at $t$ and continuous at every $x \ne t$.*

*Proof sketch.* For $x < t$, $\tau_t$ equals $\text{false}$ on a neighborhood of
$x$; for $x > t$, it equals $\text{true}$ on a neighborhood — locally constant,
hence continuous, into the discrete codomain. At $x = t$, however, $\tau_t(t) =
\text{true}$ while $\tau_t$ takes the value $\text{false}$ on every left
neighborhood $(t-\varepsilon, t)$, so no limit exists and $\tau_t$ is
discontinuous. $\qquad\blacksquare$

**Theorem 5.2 (Sensitivity).** *For every $\delta > 0$ there exists $x$ with
$|x - t| < \delta$ and $\tau_t(x) \ne \tau_t(t)$.*

*Proof sketch.* Take $x = t - \delta/2$. Then $|x - t| = \delta/2 < \delta$ and
$x < t$, so $\tau_t(x) = \text{false} \ne \text{true} = \tau_t(t)$.
$\qquad\blacksquare$

A member exactly on the cutoff is maximally unstable: an arbitrarily small
perturbation flips their tier. This is a phase transition in the literal sense —
a discontinuity of the order parameter (the tier) as a control parameter (the
score) crosses a critical value.

**Theorem 5.3 (Inevitability).** *Any continuous map $c : \mathbb{R} \to
\{\text{true},\text{false}\}$ is constant. Consequently, any classifier that
distinguishes two members (i.e. $c(x) \ne c(y)$ for some $x, y$) is
discontinuous.*

*Proof sketch.* The real line is connected, so its continuous image is connected;
but the only connected subsets of the discrete two-point space are singletons, so
$c$ takes a single value. Contrapositively, a classifier that ever outputs two
different labels cannot be continuous — it must contain a discontinuity, i.e. a
phase transition. $\qquad\blacksquare$

Thus discreteness of the reported label, together with connectivity of the score
line, makes phase transitions unavoidable: *every* system that draws a genuine
distinction between two people has a critical score at which fates diverge
discontinuously.

## 6. Algorithms

The theory yields concrete algorithms; we highlight three.

**Algorithm A (Verdict-to-score encoding).** Given a finite prefix of a verdict
history, compute a truncated score $\sum_{n<N} w_n(a)$ and a rigorous error bound
$3^{-N}$ (the tail is dominated by $\sum_{n\ge N} 2/3^{n+1} = 3^{-N}$). Complexity
$O(N)$ arithmetic operations for accuracy $3^{-N}$.

**Algorithm B (Score-to-verdict decoding).** Given a score $x \in C$, recover its
history by the IFS inverse: while reading digits, if $x < 1/3$ emit `false` and
set $x \mapsto 3x$; if $x \ge 2/3$ emit `true` and set $x \mapsto 3x - 2$. Values
falling in the open middle third $(1/3, 2/3)$ are *not* in $C$; their presence
certifies non-membership. This is the constructive inverse guaranteed by
Theorem 4.6.

**Algorithm C (Affine equilibrium tracker).** Iterate $x \mapsto c + kx$ from any
seed; by Theorem 3.3 the iterates converge geometrically to $c/(1-k)$ at rate
$k$, so $\lceil \log(\varepsilon (1-k)/|x_0(1-k)-c|)/\log k\rceil$ steps suffice
for accuracy $\varepsilon$.

## 7. Applications

- **Reputation-system audit.** Theorem 5.3 gives a formal impossibility result:
  no continuous, distinction-drawing binary reputation label exists. Designers
  who want smoothness must either report the raw score (giving up discrete tiers)
  or accept a critical score where the label is unstable.
- **Sensitivity analysis.** The Cantor structure (Theorem 4.4, Corollary 4.7)
  quantifies "small change, big effect": flipping the $n$-th verdict moves the
  score by exactly $2/3^{n+1}$, and flipping an early verdict jumps the score
  across a macroscopic gap.
- **Dynamical calibration.** Theorem 3.3 tells operators that the long-run score
  depends only on $c/(1-k)$; tuning the reward $c$ and persistence $k$ sets the
  equilibrium, and the convergence rate $k$ sets how quickly the past is
  forgotten.

## 8. Discussion and future work

The results reframe qualitative anxieties about reputation systems as theorems.
Fixed-point attractors explain why long-run standing is determined by system
parameters rather than history; the Cantor-set structure explains extreme
sensitivity and the ubiquity of gaps; connectivity explains why discrete tiers
must have unstable boundaries. Several directions extend the theory:

1. **Topological embedding.** Give $\mathbb{N} \to \{\text{true},\text{false}\}$
   the product topology and prove $\Phi$ is a topological embedding, upgrading
   "self-similar injective image" to "homeomorphic to the Cantor space," and
   deduce compactness, perfectness, and total disconnectedness intrinsically.
2. **Contraction / IFS via the Hausdorff metric.** Reprove self-similarity as the
   *unique* fixed point of the Hutchinson operator on nonempty compact subsets of
   $[0,1]$ via the Banach fixed-point theorem, making the attractor genuinely the
   attractor of a contraction.
3. **General damping.** Extend the affine attractor to complex or vector scores,
   to $|k| < 1$ with $k$ possibly negative, and to nonautonomous updates
   $x_{n+1} = c_n + k_n x_n$ with $\prod k_n \to 0$.
4. **Multi-tier phase diagram.** Generalize the classifier from two labels to
   $m$ labels: any continuous classifier $\mathbb{R} \to \{1,\dots,m\}$ is
   constant, and a monotone $m$-tier classifier has exactly (number of occupied
   tiers)$-1$ phase transitions, quantifying the number of critical scores.
5. **Measure and dimension.** Establish the Hausdorff dimension
   $\log 2/\log 3$ and Lebesgue measure zero of the attractor, tying the
   "small perturbations, big effects" theme to a rigorous dimension statement.

## 9. Conclusion

Modeling a social credit system as a map into a totally ordered value space
exposes a rigid hidden geometry. Static populations have extremal members;
affine dynamics contract to a unique attractor; monotone dynamics have
order-theoretic equilibria; verdict-based scores condense onto a Cantor-set
attractor that is self-similar, injective, uncountable, and full of gaps; and any
attempt to report discrete tiers over a connected score line forces phase
transitions. The geometry of the numbers we choose becomes the destiny of the
people we measure.
