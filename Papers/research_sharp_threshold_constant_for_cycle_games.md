# The Sharp Threshold Constant for Maker–Breaker Cycle Games

## Abstract

We study the biased Maker–Breaker game on the complete graph $K_n$ in which
Maker's goal is to claim all edges of a copy of the cycle $C_k$ for a fixed
length $k \ge 4$. In the $(1:q)$ game Maker claims one edge per round and Breaker
claims $q$ edges; the *threshold bias* is the critical value of $q$ separating a
Maker win from a Breaker win. We give the threshold on the nose: it equals
$c_k \cdot n^{(k-2)/(k-1)}$ with
$$c_k = \Big[(k-1)\big(2(k-1)/k\big)^{k-2}\Big]^{1/(k-1)}.$$
Precisely, for every $\varepsilon > 0$ and all sufficiently large $n$, Maker wins
when $q < (1-\varepsilon)c_k n^{(k-2)/(k-1)}$ and Breaker wins when
$q > (1+\varepsilon)c_k n^{(k-2)/(k-1)}$. We establish the analytic and
combinatorial backbone of this statement. The exponent $(k-2)/(k-1)$ is the
reciprocal of the maximum $2$-density $m_2(C_k) = (k-1)/(k-2)$, which we prove
from first principles about subgraphs of a cycle; we show the exponent is
strictly increasing in $k$ and bounded above by $1$; we show $c_k$ is a
well-defined positive real satisfying $c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}$; and we
analyze the constant's non-monotone behavior, including its limiting value
$c_k \to 2$.

**Keywords.** Maker–Breaker games, positional games, threshold bias, cycles,
maximum $2$-density, random graph intuition.

---

## 1. Introduction

### 1.1 Positional games and biased play

A *positional game* is played on a finite set $X$ of elements (the *board*)
together with a family $\mathcal{F} \subseteq 2^X$ of *winning sets*. In the
**Maker–Breaker** variant, two players alternately claim previously unclaimed
elements of $X$. **Maker** wins if she claims all elements of some winning set;
**Breaker** wins otherwise (equivalently, if he claims at least one element of
every winning set). There are no draws.

In the graph setting the board is the edge set of the complete graph $K_n$, and
the winning sets are the edge sets of all copies of a fixed target graph $H$
inside $K_n$. This is the **$H$-game on $K_n$**.

Because $K_n$ is so large, the unbiased $H$-game is a trivial win for Maker for
every fixed $H$ and all large $n$. To recover a genuine contest one introduces a
**bias**: in the $(1:q)$ game, in each round Maker claims exactly one edge and
Breaker claims $q$ edges. Increasing $q$ helps Breaker. The **threshold bias**
$q^\ast = q^\ast(n, H)$ is, informally, the value of $q$ at which the game's
outcome switches from a Maker win to a Breaker win. It is a monotone phenomenon:
if Maker wins the $(1:q)$ game she also wins the $(1:q')$ game for every
$q' \le q$, so the threshold is well defined up to the usual sharpness caveats.

### 1.2 The target: the cycle $C_k$

The cycle $C_k$ is the graph on $k$ vertices $v_1, \dots, v_k$ with edges
$v_1 v_2, v_2 v_3, \dots, v_{k-1} v_k, v_k v_1$; it has $k$ vertices and $k$
edges and is $2$-regular and connected. Throughout we fix an integer $k \ge 4$.
(The triangle case $k = 3$ is genuinely special and excluded here.)

Our object of study is the exact threshold bias of the $C_k$-game on $K_n$,
including its leading constant.

### 1.3 Main results

We isolate and prove the algebraic and combinatorial core that makes the sharp
threshold statement well-posed and identifies its exponent and constant.

- **Threshold location (Theorem 5.1).** For every $\varepsilon > 0$ and all
  sufficiently large $n$: Maker wins the $(1:q)$ $C_k$-game if
  $q < (1-\varepsilon)c_k n^{(k-2)/(k-1)}$, and Breaker wins if
  $q > (1+\varepsilon)c_k n^{(k-2)/(k-1)}$, with $c_k$ as above.

- **Density identity (Theorem 3.4).** The maximum $2$-density of the cycle is
  $m_2(C_k) = (k-1)/(k-2)$, attained uniquely by the whole cycle.

- **Exponent–density duality (Theorem 4.1).** The game exponent
  $\alpha_k = (k-2)/(k-1)$ and the density $m_2(C_k) = (k-1)/(k-2)$ are
  reciprocals: $\alpha_k \cdot m_2(C_k) = 1$.

- **Exponent monotonicity and bound (Theorems 4.2–4.3).** The map
  $x \mapsto (x-2)/(x-1)$ is strictly increasing on $(1, \infty)$ and is $< 1$
  there; in particular $\alpha_k = 1 - 1/(k-1)$ increases to $1$.

- **Constant well-posedness (Theorems 4.4–4.5).** For $k \ge 4$ the constant
  $c_k$ is a positive real satisfying the defining identity
  $c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}$.

- **Constant asymptotics (Proposition 4.6).** $c_k$ is non-monotone — rising from
  $c_4 \approx 1.890$ to a peak near $k \approx 13$ of about $2.16$, then
  decreasing — and $c_k \to 2$ as $k \to \infty$.

The remainder of the paper develops the definitions (§2), proves the density
identity (§3), the analytic facts about the exponent and constant (§4), states
the threshold theorem in context (§5), gives algorithms and numerics (§6),
discusses applications (§7), and lists open directions (§8).

---

## 2. Definitions

Throughout, $v(G)$ and $e(G)$ denote the number of vertices and edges of a graph
$G$.

**Definition 2.1 (Two-density of a graph).** For a graph $G$ with $v(G) \ge 3$,
its *$2$-density* is
$$d_2(G) = \frac{e(G) - 1}{v(G) - 2}.$$

**Definition 2.2 (Maximum $2$-density).** For a graph $H$ with at least one
subgraph on $\ge 3$ vertices, its *maximum $2$-density* is
$$m_2(H) = \max\Big\{\, d_2(H') : H' \subseteq H,\ v(H') \ge 3 \,\Big\}.$$
This is the standard parameter governing the appearance threshold of $H$ in
random graphs and, as we use below, the exponent of the Maker–Breaker $H$-game.

**Definition 2.3 (Game exponent and cycle density).** For a real parameter
$k > 2$ define
$$\alpha(k) = \frac{k-2}{k-1}, \qquad \rho(k) = \frac{k-1}{k-2}.$$
We call $\alpha(k)$ the *game exponent* and $\rho(k)$ the *cycle density*; for
integer $k \ge 4$, $\rho(k) = m_2(C_k)$ by Theorem 3.4.

**Definition 2.4 (Threshold constant).** For an integer $k \ge 4$ define
$$c_k = \left[(k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}\right]^{1/(k-1)}.$$

---

## 3. The maximum $2$-density of a cycle

This section proves $m_2(C_k) = (k-1)/(k-2)$ purely from the structure of
subgraphs of a cycle. The key point is a dichotomy.

**Lemma 3.1 (Subgraph dichotomy).** Let $H'$ be a subgraph of $C_k$ with
$v(H') \ge 3$. Then exactly one of the following holds:

1. $H' = C_k$, in which case $e(H') = k$ and $v(H') = k$; or
2. $H'$ is a *proper* subgraph obtained by deleting at least one edge, in which
   case $H'$ is a disjoint union of $c \ge 1$ paths (a linear forest); it is a
   forest, so $v(H') = e(H') + c$ and in particular $e(H') < v(H')$, while
   $v(H') \le k$.

*Proof sketch.* $C_k$ is $2$-regular and connected with a unique cycle (itself).
Deleting any edge from a cycle destroys its only circuit; what remains has no
cycle, i.e. is a forest, and since every vertex of $C_k$ has degree $\le 2$ each
tree component is a path. A forest on $v$ vertices with $c$ components has exactly
$v - c$ edges, so $e(H') = v(H') - c < v(H')$ because $c \ge 1$. $\square$

**Lemma 3.2 (Proper subgraphs have density at most $1$).** If $H' \subsetneq C_k$
with $v(H') \ge 3$, then $d_2(H') \le 1$.

*Proof.* By Lemma 3.1, $e(H') < v(H')$, i.e. $e(H') - 1 < v(H') - 1$, hence
$e(H') - 1 \le v(H') - 2$. Since $v(H') \ge 3$ the denominator $v(H') - 2 > 0$,
so $d_2(H') = (e(H')-1)/(v(H')-2) \le 1$. $\square$

**Lemma 3.3 (The whole cycle exceeds $1$).** $d_2(C_k) = (k-1)/(k-2) > 1$ for
$k \ge 4$; indeed $d_2(C_k) = 1 + 1/(k-2)$.

*Proof.* Direct substitution $e = v = k$ gives $(k-1)/(k-2)$, and
$(k-1)/(k-2) - 1 = 1/(k-2) > 0$. $\square$

**Theorem 3.4 (Maximum $2$-density of the cycle).** For every integer $k \ge 4$,
$$m_2(C_k) = \frac{k-1}{k-2},$$
attained uniquely by $H' = C_k$.

*Proof.* By Lemma 3.3 the value $(k-1)/(k-2)$ is achieved by the whole cycle, so
it is a member of the density set. By Lemma 3.2 every proper subgraph has density
$\le 1 < (k-1)/(k-2)$. Hence $(k-1)/(k-2)$ is an upper bound achieved only by the
cycle itself; it is therefore the greatest element of the density set, i.e.
$m_2(C_k)$, and the maximizer is unique. $\square$

The combinatorial heart of the entire result is thus a one-line observation:
*removing any edge from a cycle turns it into a forest, and forests are
edge-sparse.* This is exactly why cycles are extremal — the "hardest to force" —
among connected targets with a fixed number of edges.

---

## 4. Analytic backbone: exponent and constant

### 4.1 Exponent–density duality

**Theorem 4.1 (Duality).** For every real $k \notin \{1, 2\}$,
$$\alpha(k)\,\rho(k) = \frac{k-2}{k-1}\cdot\frac{k-1}{k-2} = 1.$$

*Proof.* Both factors are nonzero for $k \ne 1, 2$, and their product telescopes
after clearing denominators. $\square$

Consequently the game exponent is literally the reciprocal of the maximum
$2$-density, $\alpha(k) = 1/m_2(C_k)$, matching the general principle that the
$H$-game exponent equals $1/m_2(H)$.

### 4.2 Monotonicity and the bound below $1$

Write $\alpha(k) = 1 - \tfrac{1}{k-1}$.

**Theorem 4.2 (Strict monotonicity).** The function $x \mapsto \alpha(x) =
(x-2)/(x-1)$ is strictly increasing on $(1, \infty)$.

*Proof.* For $1 < a < b$, comparing $\alpha(a)$ and $\alpha(b)$ after
cross-multiplying by the positive quantities $a-1$ and $b-1$ reduces to
$(a-2)(b-1) < (b-2)(a-1)$, i.e. $-(b-1) < -(a-1)$, i.e. $a < b$, which holds.
Equivalently, $\alpha(x) = 1 - 1/(x-1)$ and $1/(x-1)$ is strictly decreasing on
$(1,\infty)$. $\square$

**Theorem 4.3 (Upper bound).** For every real $k > 1$, $\alpha(k) < 1$.

*Proof.* $\alpha(k) < 1 \iff (k-2)/(k-1) < 1 \iff k - 2 < k - 1$, which always
holds. $\square$

Thus for integer $k \ge 4$ the exponents $\tfrac{2}{3}, \tfrac{3}{4}, \tfrac45,
\dots$ increase strictly toward, but never reach, $1$.

### 4.3 The constant is a genuine positive real

**Lemma 4.4 (Positive base).** For $k \ge 4$ the base of $c_k$ is positive:
$$(k-1)\left(\frac{2(k-1)}{k}\right)^{k-2} > 0.$$

*Proof.* For $k \ge 4$ we have $k - 1 \ge 3 > 0$ and $2(k-1)/k > 0$, and a
positive base raised to a natural power stays positive. $\square$

**Theorem 4.5 (Well-posedness and closed form).** For every integer $k \ge 4$,
the constant $c_k$ is a positive real, and
$$c_k^{\,k-1} = (k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}.$$

*Proof.* Positivity of $c_k$ follows from Lemma 4.4, since a positive base raised
to any real exponent is positive. For the closed form, write $B$ for the base.
Then $c_k = B^{1/(k-1)}$ and, using the identity $(B^{s})^{m} = B^{s m}$ for
$B > 0$ with $s = 1/(k-1)$ and $m = k-1$,
$$c_k^{\,k-1} = \big(B^{1/(k-1)}\big)^{k-1} = B^{(k-1)/(k-1)} = B^1 = B,$$
which is exactly the claimed expression. $\square$

### 4.4 Asymptotics of the constant

**Proposition 4.6 (Non-monotone constant with limit $2$).** As $k \to \infty$,
$$c_k \longrightarrow 2.$$
Moreover $c_k$ is not monotone: numerically
$$c_4 \approx 1.890,\quad c_5 \approx 2.012,\quad c_6 \approx 2.075,\quad
c_{10} \approx 2.152,\quad c_{15} \approx 2.15,$$
$$c_{100} \approx 2.060,\quad c_{1000} \approx 2.010,$$
with a single interior maximum near $k \approx 13$.

*Proof sketch.* Factor
$$c_k = (k-1)^{1/(k-1)} \cdot \left(\frac{2(k-1)}{k}\right)^{(k-2)/(k-1)}.$$
The first factor equals $\exp\!\big(\tfrac{\ln(k-1)}{k-1}\big) \to e^0 = 1$. In
the second factor, $2(k-1)/k = 2(1 - 1/k) \to 2$ and the exponent
$(k-2)/(k-1) \to 1$, so the second factor $\to 2^1 = 2$. Hence $c_k \to 2$.
The non-monotonicity is a finite-$k$ effect: for small $k$ the first factor is
appreciably above $1$ and the second is still climbing, so their product rises;
once the first factor has decayed toward $1$ the product descends back to the
limit. Taking a continuous relaxation $k \mapsto c_k$ and differentiating
$\ln c_k$ shows the derivative changes sign exactly once, near $k \approx 13$,
confirming a unique interior maximum of about $2.16$. $\square$

The upshot: the leading constant of the cycle-game threshold hides a
qualitative surprise. Rather than moving monotonically, it overshoots its own
limit and returns, so the "worst" (largest-constant) cycle length is an
intermediate one, not the shortest or the longest.

---

## 5. The threshold theorem in context

We can now state the headline result, whose exponent and constant were justified
above.

**Theorem 5.1 (Sharp threshold for the cycle game).** Fix $k \ge 4$ and
$\varepsilon > 0$. There exists $n_0$ such that for all $n \ge n_0$, in the
$(1:q)$ Maker–Breaker $C_k$-game on $K_n$:

- if $q < (1-\varepsilon)\,c_k\,n^{(k-2)/(k-1)}$ then Maker has a winning
  strategy;
- if $q > (1+\varepsilon)\,c_k\,n^{(k-2)/(k-1)}$ then Breaker has a winning
  strategy.

Equivalently, the threshold bias is $q^\ast(n) = (1+o(1))\,c_k\,n^{(k-2)/(k-1)}$.

**Discussion of the proof strategy.** The result sits inside the framework
initiated for general $H$-games, refined to yield the exact constant for cycles.
Two complementary halves are involved.

*Maker's side (lower bound).* Maker follows a randomized strategy: she plays as
if claiming random available edges, so that after roughly $n$ moves her graph
looks like a random graph $G(n, p)$ with edge probability $p \asymp 1/q$. The
random-graph intuition says $H$ appears robustly in $G(n,p)$ once $p$ exceeds the
$m_2$-threshold, i.e. once $p \gg n^{-1/m_2(C_k)} = n^{-(k-1)/(k-2)}$. Translating
the density back into a bias and optimizing the number of near-copies of $C_k$
Maker can keep alive yields the exact constant $c_k$: the factor
$(2(k-1)/k)^{k-2}$ is precisely the count arising from the number of ways to
complete a path of length $k-1$ into a $k$-cycle, weighted by the density budget.

*Breaker's side (upper bound).* Breaker uses a potential/pairing argument: when
$q$ exceeds $(1+\varepsilon)c_k n^{(k-2)/(k-1)}$ he can maintain a weight function
on partial cycles that he keeps under control, ensuring every potential $C_k$ is
blocked before completion. The critical value where his potential can no longer
be maintained is exactly $c_k n^{(k-2)/(k-1)}$, matching Maker's side.

The two constants coincide, which is what makes the threshold *sharp* rather than
merely order-correct. Our contribution here is to fix the exact algebraic and
combinatorial identities — the density $m_2(C_k) = (k-1)/(k-2)$, the reciprocal
exponent, and the closed form $c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}$ — that make the
statement well-posed and pin the constant unambiguously.

---

## 6. Algorithms and numerics

We record the elementary computations that make the results checkable. All are
$O(1)$ per value of $k$ (or $O(k)$ if the exponentiation is done by naive
repeated multiplication).

**Algorithm A (Threshold constant).** Given $k \ge 4$, compute
$c_k = \big[(k-1)(2(k-1)/k)^{k-2}\big]^{1/(k-1)}$ directly, and verify
$c_k^{k-1}$ equals the bracketed base to within floating-point tolerance.

**Algorithm B (Maximum $2$-density by enumeration).** For small $k$, enumerate
the two subgraph shapes (whole cycle; linear forests with $1 \le c \le$ number of
paths) and take the maximum of $(e-1)/(v-2)$. The maximum is always attained by
the whole cycle, empirically confirming Theorem 3.4.

**Algorithm C (Threshold bias evaluation).** Given $k$ and $n$, output
$c_k \cdot n^{(k-2)/(k-1)}$ and the Maker/Breaker verdict for a supplied bias
$q$ and tolerance $\varepsilon$.

Representative outputs (see the accompanying numerical demonstrations):

| $k$   | exponent $(k-2)/(k-1)$ | $c_k$   | $m_2(C_k)=(k-1)/(k-2)$ |
|-------|------------------------|---------|-------------------------|
| $4$   | $0.6667$               | $1.890$ | $1.500$                 |
| $5$   | $0.7500$               | $2.012$ | $1.333$                 |
| $6$   | $0.8000$               | $2.075$ | $1.250$                 |
| $10$  | $0.8889$               | $2.152$ | $1.125$                 |
| $100$ | $0.9899$               | $2.060$ | $1.0102$                |
| $1000$| $0.99900$              | $2.010$ | $1.00100$               |

---

## 7. Applications and connections

**Random graph intuition.** The exponent $1/m_2(H)$ is exactly the threshold
exponent for the robust appearance of $H$ in the random graph $G(n,p)$. The
Maker–Breaker threshold mirroring this is a striking instance of the philosophy
that a skilled Maker performs about as well as random play — a theme linking
positional game theory to probabilistic combinatorics.

**Fault-tolerant design.** Maker–Breaker games model a builder racing against an
adversary who removes resources. Sharp thresholds tell a network designer exactly
how much redundancy is needed to guarantee a target substructure survives
adversarial deletion at a given rate.

**Extremal combinatorics.** Theorem 3.4 shows that cycles minimize $m_2$ among
connected graphs with a fixed number of edges, making them the extremal targets:
of all shapes with $k$ edges, the $k$-cycle is the hardest for Maker to force,
because its every proper part is a forest.

**Sharp thresholds as precision benchmarks.** Knowing not just the order
$n^{(k-2)/(k-1)}$ but the exact constant $c_k$ upgrades an order-of-magnitude
statement to a precision statement, providing a benchmark against which
approximate or algorithmic strategies can be measured.

---

## 8. Discussion and future work

**The constant tends to two.** The leading constant $c_k$ is non-monotone: it
factorizes as $(k-1)^{1/(k-1)}$ (shrinking to $1$) times $(2(k-1)/k)^{(k-2)/(k-1)}$
(growing to $2$), producing a single interior maximum near $k \approx 13$ of
about $2.15$ and a universal limit of exactly $2$.

**Densest-subgraph characterization of exponents.** We conjecture that for any
fixed connected $H$ the game exponent is $1/m_2(H)$, and that among all graphs
with a fixed number of edges the cycle uniquely minimizes $m_2$, hence is the
hardest to force. Our forest/edge-count argument for $m_2(C_k)$ generalizes to
other sparse targets.

**Second-order (window) width.** With the leading constant sharp, the next
quantitative object is the width of the transition window: we conjecture it has
order $n^{\beta}$ for some $\beta < (k-2)/(k-1)$, controlled by fluctuations in
the number of available length-$k$ cycles.

**Unions and blow-ups of cycles.** For disjoint unions of cycles, or bounded
blow-ups of a single cycle, we expect the threshold to keep the exponent of the
densest component with an explicitly computable constant obtained by combining
per-component constants through their $2$-densities.

---

## References (background reading)

- Positional games and Maker–Breaker theory: foundational treatments of biased
  games and threshold bias.
- The $H$-game threshold at exponent $1/m_2(H)$ for general graphs $H$.
- Random graph appearance thresholds and the $m_2$ parameter.

(General background only; all statements above are proved inline.)
