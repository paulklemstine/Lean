# Uniform Extremality for Siblings of the Coupon Collector

## Abstract

We introduce and analyze a family of *sibling* statistics attached to the
classical coupon collector's problem. Coupons come in $N \ge 2$ types drawn
independently and identically from a probability vector $p = (p_1, \dots, p_N)$
in the open simplex. A *main collector* stops at the random time $T$ at which
every type has appeared at least once. For an integer threshold $j \ge 2$, the
*$j$-th sibling* regards a type as filled once it has been drawn at least $j$
times, and the random variable $U_j^N$ counts the types still empty at time $T$,
namely $U_j^N = \#\{\, i : N_i(T) < j \,\}$, where $N_i(T)$ is the number of
copies of type $i$ observed by time $T$. Our main contributions are: (i) an exact
inclusion–exclusion closed form for the expectation $E_p[U_j^N]$, valid for all
$N$, all $j \ge 2$, and all $p$; (ii) a proof that this expectation is a
symmetric function of $p$, invariant under coordinate permutations; (iii) the
exact value at the balanced distribution; (iv) a complete solution of the
two-type case, where $E_p[U_j] = 2 - p_1^{\,j} - p_2^{\,j}$ and the balanced
distribution is the strict maximizer for every $j \ge 2$; and (v) a rigorous
bridge showing the closed form agrees with the fully probabilistic (infinite
series) expectation in the two-type case. Together these results establish the
skeleton of a general **uniform extremality** principle: the balanced
distribution maximizes the expected number of empty sibling slots, and the
expectation is (conjecturally, and provably for $N = 2$) Schur-concave in $p$.

## 1. Introduction

### 1.1 Motivation

The coupon collector's problem asks for the number of independent uniform draws
needed to observe all $N$ types of a coupon at least once. Its expectation,
$N H_N \sim N \ln N$, and its concentration are classical. Many applications,
however, care not only about *first* coverage but about *depth* of coverage:
caches want every block loaded, but also replicated; test suites want every
component exercised, but also stressed; gossip protocols want every node
informed, but also redundantly informed.

We formalize this "coverage versus depth" tension with a two-tier model. A main
collector runs until first coverage is complete. A sibling, watching the same
draw stream, uses a stricter fill rule: a type is filled only after $j$
appearances. At the main collector's completion time $T$, we ask how many types
are still short of the sibling's threshold. The number of such empty slots,
$U_j^N$, measures how far behind depth lags coverage.

The natural optimization question is: **over all drawing distributions $p$, which
one leaves the sibling with the most empty slots on average?** Our answer, in the
cases we resolve completely, is the *balanced* (uniform) distribution — a mild
surprise, since unbalance also lengthens the collector's run. The paper develops
the exact tools that make this precise.

### 1.2 Summary of results

- **Closed form (Section 3).** For all $N$, $j \ge 2$, and $p$ in the open
  simplex,
  $$ E_p[U_j^N] = \sum_{i=1}^{N} \sum_{S \subseteq [N]\setminus\{i\}}
  (-1)^{|S|}\left(\frac{p_i}{p_i + \sum_{s \in S} p_s}\right)^{\!j}. $$
- **Symmetry (Theorem 4.1).** $E_p[U_j^N]$ is invariant under permuting the
  coordinates of $p$.
- **Balanced value (Theorem 4.2).**
  $E_{\text{uniform}}[U_j^N] = N \sum_{s=0}^{N-1} (-1)^s \binom{N-1}{s}(1+s)^{-j}$.
- **Two-type collapse (Theorem 4.3) and probabilistic bridge (Theorem 4.4).**
  For $N = 2$ the closed form equals $2 - p_1^{\,j} - p_2^{\,j}$, and this agrees
  with the series-defined expectation.
- **Two-type extremality (Theorem 5.1).** For $N = 2$ and every $j \ge 2$, the
  map $a \mapsto 2 - a^{\,j} - (1-a)^{\,j}$ on $(0,1)$ is strictly maximized at
  $a = 1/2$ and strictly Schur-concave.
- **General conjecture (Section 6).** For all $N \ge 2$ and $j \ge 2$,
  $E_p[U_j^N]$ is strictly Schur-concave, hence uniquely maximized by the
  balanced distribution.

## 2. Model and definitions

Fix $N \ge 2$ and a probability vector $p = (p_1, \dots, p_N)$ with $p_i > 0$ and
$\sum_{i=1}^N p_i = 1$. Let $X_1, X_2, \dots$ be i.i.d. draws with
$\Pr(X_t = i) = p_i$. For each type $i$ and time $t$, let
$N_i(t) = \#\{\, r \le t : X_r = i \,\}$ be the running count of type $i$.

**Definition 2.1 (Main completion time).** The *main completion time* is
$$ T = \min\{\, t : N_i(t) \ge 1 \text{ for all } i \,\}, $$
the first time every type has appeared at least once. (Almost surely finite since
all $p_i > 0$.)

**Definition 2.2 (Sibling empty count).** For an integer threshold $j \ge 2$, the
*$j$-th sibling empty count* is
$$ U_j^N = \#\{\, i \in [N] : N_i(T) < j \,\}, $$
the number of types observed fewer than $j$ times by the main completion time.

We study the expectation $E_p[U_j^N]$ as a function of the distribution $p$. By
linearity,
$$ E_p[U_j^N] = \sum_{i=1}^N \Pr\big(N_i(T) < j\big), $$
so the whole analysis reduces to computing, for each type $i$, the probability
that type $i$ is still below threshold at the main completion time.

## 3. The closed form via inclusion–exclusion

**Key event.** For a fixed type $i$, the event $\{N_i(T) < j\}$ says that the
$j$-th copy of type $i$ has not appeared by time $T$. Since $T$ is the first time
all types are present, this is equivalent to: **every other type appears before
the $j$-th copy of type $i$.** Indeed, if some type $s \ne i$ had not yet
appeared when the $j$-th $i$ arrived, then at the moment of that $j$-th $i$ the
set was still incomplete, so $T$ occurs later and $N_i(T) \ge j$; conversely if
all other types beat the $j$-th $i$, then completion happens no later than the
$(j-1)$-th $i$, so $N_i(T) < j$.

**A race lemma.** For a subset $S \subseteq [N] \setminus \{i\}$, consider only
the draws whose type lies in $\{i\} \cup S$; these form an i.i.d. sub-sequence in
which type $i$ has conditional probability $p_i / (p_i + q_S)$, where
$q_S = \sum_{s \in S} p_s$. The probability that the first $j$ such draws are all
type $i$ — equivalently, that no type in $S$ appears before the $j$-th copy of
$i$ — is
$$ \left(\frac{p_i}{p_i + q_S}\right)^{\!j}. $$

**Inclusion–exclusion.** Let $A_s$ be the event "type $s$ appears before the
$j$-th copy of type $i$." Then $\{N_i(T) < j\} = \bigcap_{s \ne i} A_s$, and by
inclusion–exclusion over the complements,
$$ \Pr\Big(\bigcap_{s \ne i} A_s\Big)
= \sum_{S \subseteq [N]\setminus\{i\}} (-1)^{|S|}\,
\Pr\Big(\bigcap_{s \in S} A_s^{c}\Big), $$
and $\bigcap_{s \in S} A_s^c$ is exactly the event that none of the types in $S$
appears before the $j$-th copy of $i$, whose probability is
$(p_i/(p_i + q_S))^j$ by the race lemma. Summing over $i$ yields the closed form.

**Definition 3.1 (Closed form).**
$$ \boxed{\; E_p[U_j^N] = \sum_{i=1}^{N} \sum_{S \subseteq [N]\setminus\{i\}}
(-1)^{|S|}\left(\frac{p_i}{p_i + \sum_{s \in S} p_s}\right)^{\!j}. \;} $$

This is an exact, finite expression. The outer sum has $N$ terms; the inner sum
ranges over the $2^{N-1}$ subsets of the competitors of $i$.

## 4. Structural properties

### Theorem 4.1 (Permutation symmetry)

For every permutation $\sigma$ of $[N]$, $E_{p \circ \sigma}[U_j^N] = E_p[U_j^N]$.
Equivalently, $E_p[U_j^N]$ depends on $p$ only through its multiset of values.

**Proof sketch.** Reindex the outer sum by $i \mapsto \sigma(i)$ and, within each
term, reindex the inner power-set sum by $S \mapsto \sigma(S)$. The map
$S \mapsto \sigma(S)$ is a bijection from subsets of $[N]\setminus\{i\}$ to
subsets of $[N]\setminus\{\sigma(i)\}$ preserving cardinality (so the sign
$(-1)^{|S|}$ is unchanged), and it carries the denominator
$p_{\sigma(i)} + \sum_{s \in S} p_{\sigma(s)}$ of the permuted vector to the
denominator $p_{\sigma(i)} + \sum_{t \in \sigma(S)} p_t$ of the original vector.
Each summand is thereby matched exactly, so the total is unchanged. Notably this
argument uses no positivity of $p$: if a denominator vanishes the corresponding
term is taken to be $0$ and the bijection permutes such terms among themselves.
$\qquad\blacksquare$

Symmetry is the indispensable structural prerequisite for any extremality claim
phrased in terms of Schur-concavity: a Schur-concave function is by definition
symmetric and monotone under majorization.

### Theorem 4.2 (Value at the balanced distribution)

For $N \ge 1$ and $j \ge 0$,
$$ E_{\text{uniform}}[U_j^N] = N \sum_{s=0}^{N-1} (-1)^s
\binom{N-1}{s} \frac{1}{(1+s)^{\,j}}. $$

**Proof sketch.** At $p_i = 1/N$ for all $i$, the ratio for a subset $S$ with
$|S| = s$ equals $\big((1/N)/((s+1)/N)\big)^j = (1+s)^{-j}$, depending on $S$
only through its size. Grouping the inner power-set sum by cardinality replaces
$\sum_{S \subseteq [N]\setminus\{i\}}$ with
$\sum_{s=0}^{N-1} \binom{N-1}{s}$, giving the same inner value
$\sum_{s} (-1)^s \binom{N-1}{s}(1+s)^{-j}$ for each of the $N$ outer indices $i$.
Multiplying by $N$ yields the stated formula. $\qquad\blacksquare$

**Example.** For $N = 3$, $j = 3$:
$E_{\text{uniform}}[U_3^3] = 3\big(1 - \tfrac{2}{2^3} + \tfrac{1}{3^3}\big)
= 3 \cdot \tfrac{85}{108} = \tfrac{85}{36} \approx 2.3611$.

### Theorem 4.3 (Two-type collapse)

For $N = 2$ and $p = (p_1, p_2)$ with $p_1, p_2 > 0$ and $p_1 + p_2 = 1$,
$$ E_p[U_j^2] = 2 - p_1^{\,j} - p_2^{\,j}. $$

**Proof sketch.** For $i = 1$ the competitors are $\{2\}$; the subsets are
$\emptyset$ (contributing $+ (p_1/p_1)^j = 1$) and $\{2\}$ (contributing
$-(p_1/(p_1+p_2))^j = -p_1^{\,j}$ since $p_1 + p_2 = 1$). Hence
$\Pr(N_1(T)<j) = 1 - p_1^{\,j}$, and symmetrically
$\Pr(N_2(T)<j) = 1 - p_2^{\,j}$. Adding gives $2 - p_1^{\,j} - p_2^{\,j}$.
$\qquad\blacksquare$

### Theorem 4.4 (Probabilistic bridge)

For $a \in (0,1)$ and $j \ge 2$, the closed form evaluated at $(a, 1-a)$ equals
the expectation $E[U_j]$ of the two-type sibling empty count defined directly as
an infinite series over the (random, a.s. finite) completion time. In symbols,
the algebraic quantity $2 - a^{\,j} - (1-a)^{\,j}$ coincides with the genuine
probabilistic expectation of $U_j^2$.

**Proof sketch.** The direct expectation is
$E[U_j] = \Pr(N_1(T)<j) + \Pr(N_2(T)<j)$, and an independent computation of these
two tail probabilities from the draw dynamics (conditioning on which type
completes the set) yields $1 - a^{\,j}$ and $1 - (1-a)^{\,j}$ respectively,
matching Theorem 4.3 term by term. This validates the inclusion–exclusion
derivation against a first-principles probabilistic definition. $\qquad\blacksquare$

## 5. Extremality in the two-type case

### Theorem 5.1 (Uniform extremality, $N = 2$)

Let $j \ge 2$ and define $f(a) = 2 - a^{\,j} - (1-a)^{\,j}$ for $a \in (0,1)$.
Then $f$ is symmetric about $a = 1/2$, strictly concave, and attains its unique
maximum at $a = 1/2$, with $f(1/2) = 2 - 2^{\,1-j}$. Consequently, among all
two-type distributions, the balanced distribution $(1/2, 1/2)$ uniquely maximizes
$E_p[U_j^2]$, and $E_p[U_j^2]$ strictly decreases as $|a - 1/2|$ increases;
equivalently, $E_p[U_j^2]$ is strictly Schur-concave.

**Proof sketch.** Differentiate: $f'(a) = -j a^{\,j-1} + j (1-a)^{\,j-1}$, which
is zero iff $a^{\,j-1} = (1-a)^{\,j-1}$, i.e. $a = 1/2$ (as $t \mapsto t^{j-1}$ is
strictly increasing on $(0,1)$ for $j \ge 2$). The second derivative
$f''(a) = -j(j-1)\big(a^{\,j-2} + (1-a)^{\,j-2}\big) < 0$ throughout $(0,1)$, so
$f$ is strictly concave and the critical point is the global maximum.
Symmetry $f(a) = f(1-a)$ is immediate. Strict concavity of a symmetric univariate
function is exactly strict Schur-concavity in the two-variable simplex.
$\qquad\blacksquare$

**Interpretation.** The balanced two-type album is the *emptiest* on average
because balance minimizes the main collector's completion time, giving the
sibling the fewest draws to build depth. Every step toward unbalance lengthens
the collector's run and lets the sibling fill more slots.

## 6. The general conjecture

The exact closed form (Definition 3.1), its symmetry (Theorem 4.1), the balanced
value (Theorem 4.2), and the fully proven two-type case (Theorem 5.1) assemble
into the following headline conjecture.

**Conjecture 6.1 (Global uniform extremality / Schur-concavity).** For every
$N \ge 2$ and every $j \ge 2$, the expectation $E_p[U_j^N]$ is a strictly
Schur-concave function of $p$ on the open simplex. Consequently it is uniquely
maximized by the balanced distribution $p = (1/N, \dots, 1/N)$, and it strictly
decreases under every transfer of probability mass from a lighter to a heavier
coordinate (a Robin-Hood-in-reverse move).

Because $E_p[U_j^N]$ is symmetric, a standard reduction shows that strict
Schur-concavity is equivalent to a single **two-coordinate transfer
inequality**: fixing all but two probabilities and moving those two closer to
their common average strictly increases the expectation. The closed form isolates
this transfer step cleanly; its alternating structure is the only obstacle to a
short proof, and it is the concrete target the conjecture reduces to. Numerical
evidence is unambiguous — e.g. at $N = 3$, $j = 3$ the balanced value $85/36$
strictly exceeds the values at $(1/2, 1/4, 1/4)$, $(3/5, 1/5, 1/5)$, and
$(4/5, 1/10, 1/10)$.

## 7. Algorithms

**Exact evaluation.** Definition 3.1 is directly computable. For each type $i$,
enumerate the $2^{N-1}$ subsets $S$ of its competitors, accumulate
$(-1)^{|S|}(p_i/(p_i + q_S))^j$, and sum over $i$. The cost is
$O(N \cdot 2^{N} \cdot N) = O(N^2 2^N)$ arithmetic operations in exact rational
arithmetic, giving the expectation with no sampling error. This is the reference
oracle against which everything else is checked.

**Balanced value.** Theorem 4.2 collapses the exponential enumeration to a single
alternating binomial sum of $N$ terms, computable in $O(N)$ arithmetic
operations.

**Monte Carlo cross-check.** Simulate the draw stream until first coverage, count
the sibling's empty slots, and average over many trials. This unbiased estimator
converges to $E_p[U_j^N]$ and confirms the closed form on distributions where
exact enumeration is expensive.

## 8. Applications

- **Cache warming.** A system loads blocks until every block is present at least
  once (main coverage) while tracking how many blocks are already replicated to a
  depth $j$ (sibling fill). The model predicts that skewed access frequencies
  leave *fewer* under-replicated blocks at first-coverage time than uniform
  access — uniform access is the worst case for depth.
- **Test coverage.** Random test generators run until every code path is hit
  once; the sibling count measures how many paths still lack $j$-fold stress
  testing at that moment. Balanced path-selection maximizes the residual
  under-tested count.
- **Gossip / epidemic protocols.** Full dissemination (everyone informed once)
  versus robust dissemination (everyone informed $j$ times): the extremal
  principle identifies the message-popularity profile that leaves the most nodes
  under-informed at first full coverage.

## 9. Discussion and future work

This cycle settles the two-type extremality story for every sibling index and,
for arbitrary $N$, establishes the exact closed form, its permutation symmetry,
and its balanced value. The following directions are open.

1. **Global uniform extremality and Schur-concavity for every $N$** (Conjecture
   6.1). Reduce to and prove the two-coordinate transfer inequality made explicit
   by the closed form.
2. **Monotonicity in the sibling index $j$.** Conjecturally $E_p[U_j^N]$ is
   strictly increasing and concave in $j$, with
   $E[U_{j+1}^N] - E[U_j^N]$ equal to the expected number of types seen exactly
   $j$ times at completion. The two-type increment
   $a^{\,j}(1-a) + (1-a)^{\,j} a$ is a manifest probability, giving a template
   for the general increment identity.
3. **Balanced-case asymptotics.** The alternating binomial sum of Theorem 4.2 is
   an iterated finite difference of $s \mapsto (1+s)^{-j}$, linking it to Beta
   integrals and Stirling-number expansions; conjecturally
   $E_{\text{uniform}}[U_j^N] \sim N - c_j \ln N$ as $N \to \infty$ with $j$
   fixed, awaiting saddle-point analysis.

## 10. Conclusion

The sibling coupon collector cleanly separates *coverage* from *depth* and asks
which drawing distribution leaves depth lagging the most at the moment coverage
completes. An exact inclusion–exclusion formula answers the question in
principle for all parameters; symmetry, the balanced value, and a complete
two-type solution answer it in full where it is fully tractable. The uniform
distribution — the fairest of all — is, perhaps counterintuitively, the worst for
the depth-hungry sibling, and the exact formula turns the general statement into a
single sharp inequality that we conjecture and expect to hold universally.
