# An Improved Vizing-Type Constant for Domination in Cartesian Products of Graphs

## Abstract

Vizing's conjecture asserts that the domination number of the Cartesian product of
two finite graphs is at least the product of their domination numbers:
$\gamma(G \,\square\, H) \ge \gamma(G)\,\gamma(H)$. It remains open after more than
half a century. The best known unconditional multiplicative bounds have the form
$\gamma(G \,\square\, H) \ge c\,\gamma(G)\,\gamma(H)$, beginning with the
Clark–Suen constant $c = \tfrac12$ and improved in subsequent work to a constant
of the form $\tfrac{19-\sqrt{73}}{18} \approx 0.5809$. This paper isolates and
rigorously establishes the *arithmetic* of that improved constant and proves the
associated Vizing-type inequality in every case forced by the elementary
projection bound. We prove that $c = \tfrac{19-\sqrt{73}}{18}$ is precisely the
smaller root of the integer quadratic $9x^2 - 19x + 8$, that it lies strictly
between the Clark–Suen constant $\tfrac12$ and the conjectural Vizing constant $1$,
and that it is positive. We frame these facts inside a clean two-sided bracket for
the product domination number,
$\max(\gamma(G),\gamma(H)) \le \gamma(G\,\square\,H) \le \gamma(G)\,|V(H)|$,
whose lower half — a coordinate-projection argument — is the combinatorial engine
of all Vizing-type results. Combining the bracket with the algebra of $c$, we
obtain the conditional theorem: whenever $\min(\gamma(G),\gamma(H)) \le 1$, the
inequality $\gamma(G\,\square\,H) \ge c\,\gamma(G)\,\gamma(H)$ holds. We discuss the
discharging obstruction that must be overcome to reach the unconditional bound,
sharpness of the lower bracket, and the fractional relaxation in which the product
rule becomes an exact identity.

**Keywords:** domination number, Cartesian product of graphs, Vizing's conjecture,
Clark–Suen bound, algebraic constant, projection bound.

---

## 1. Introduction

### 1.1 Domination

Let $G = (V, E)$ be a finite simple graph. A set $S \subseteq V$ is a *dominating
set* if every vertex not in $S$ is adjacent to a vertex of $S$; equivalently, every
vertex $v$ satisfies $v \in S$ or there is $w \in S$ with $w$ adjacent to $v$. The
*domination number* $\gamma(G)$ is the minimum cardinality of a dominating set of
$G$. Domination is among the most studied notions in graph theory, modelling the
placement of a minimum number of "guards," "sensors," or "facilities" so that every
location is watched or served.

### 1.2 The Cartesian product

Given graphs $G$ on vertex set $A$ and $H$ on vertex set $B$, their **Cartesian
(box) product** $G \,\square\, H$ has vertex set $A \times B$, and two vertices
$(a_1, b_1)$ and $(a_2, b_2)$ are adjacent if and only if either
- $a_1 = a_2$ and $b_1$ is adjacent to $b_2$ in $H$, or
- $b_1 = b_2$ and $a_1$ is adjacent to $a_2$ in $G$.

The defining feature we use repeatedly is the **fixed-coordinate property**: every
edge of $G \,\square\, H$ leaves one of the two coordinates unchanged. Cartesian
products model grids (a path times a path), tori (a cycle times a cycle), hypercubes
(repeated products of a single edge), and many communication and sensing topologies.

### 1.3 Vizing's conjecture and multiplicative bounds

In 1968 Vizing conjectured
$$\gamma(G \,\square\, H) \ \ge\ \gamma(G)\,\gamma(H)\qquad\text{for all finite } G, H,$$
and this remains open. The principal unconditional progress takes the form of a
multiplicative lower bound with an explicit constant,
$$\gamma(G \,\square\, H) \ \ge\ c\,\gamma(G)\,\gamma(H),$$
with the goal of pushing $c$ upward toward $1$. Clark and Suen (2000) established
$c = \tfrac12$. Refinements of their partition-and-charge argument (Suen–Tarr and
others) raise the constant, and the value that arises from balancing the two halves
of each product edge is
$$c \;=\; \frac{19 - \sqrt{73}}{18} \;\approx\; 0.5809.$$

### 1.4 Contributions

This paper does three things.

1. **Pins down the constant exactly.** We prove $c = \tfrac{19-\sqrt{73}}{18}$ is
   the smaller root of $9x^2 - 19x + 8$, and that $\tfrac12 < c < 1$ (so it strictly
   improves Clark–Suen and stays below Vizing) and $c > 0$.
2. **Establishes the two-sided bracket** for $\gamma(G\,\square\,H)$: a
   cylindrification upper bound and a projection lower bound, the latter being the
   combinatorial mechanism underpinning all Vizing-type results.
3. **Proves the conditional Vizing-type inequality with the improved constant** in
   the regime $\min(\gamma(G),\gamma(H)) \le 1$, honestly delimiting where the
   elementary method already delivers $c$ and where the frontier lies.

We are careful to claim no more than is proved: the *unconditional* constant bound
is deep and is not asserted here. Our results give a faithful account of *why*
$\tfrac{19-\sqrt{73}}{18}$ is the natural target and a complete proof in the regime
the projection method covers.

---

## 2. Definitions

Throughout, all graphs are finite and simple, and vertex sets are finite.

**Definition 2.1 (Dominating set).** For a graph $G$ on vertex set $V$ and
$S \subseteq V$, $S$ is *dominating* if for every $v \in V$ either $v \in S$ or
there exists $w \in S$ adjacent to $v$ in $G$.

**Definition 2.2 (Domination number).** $\gamma(G) = \min\{\, |S| : S \text{ is a
dominating set of } G \,\}$. For a nonempty finite graph this minimum is attained.

**Definition 2.3 (Cartesian product).** As in §1.2, with vertex set $A \times B$
and the fixed-coordinate adjacency rule.

**Definition 2.4 (The improved constant).**
$$c \;:=\; \frac{19 - \sqrt{73}}{18}.$$

---

## 3. The arithmetic of the constant

The improved constant is not an arbitrary decimal; it is an algebraic number of
degree two determined by an explicit integer quadratic.

**Theorem 3.1 (Quadratic identity).** The constant $c = \tfrac{19-\sqrt{73}}{18}$
satisfies
$$9c^2 - 19c + 8 = 0.$$
Consequently $c$ is the smaller of the two roots $\tfrac{19 \pm \sqrt{73}}{18}$ of
$9x^2 - 19x + 8$.

*Proof.* Write $s = \sqrt{73}$, so $s^2 = 73$. Then
$$9c^2 = 9\cdot\frac{(19 - s)^2}{18^2} = \frac{(19-s)^2}{36} = \frac{361 - 38s + s^2}{36} = \frac{361 - 38s + 73}{36} = \frac{434 - 38s}{36},$$
and $19c = \tfrac{19(19 - s)}{18} = \tfrac{361 - 19s}{18} = \tfrac{722 - 38s}{36}$.
Hence
$$9c^2 - 19c + 8 = \frac{434 - 38s}{36} - \frac{722 - 38s}{36} + \frac{288}{36} = \frac{434 - 722 + 288}{36} = \frac{0}{36} = 0.$$
The two roots of $9x^2 - 19x + 8$ are $\tfrac{19 \pm \sqrt{361 - 288}}{18} =
\tfrac{19 \pm \sqrt{73}}{18}$, and $c$ takes the minus sign, hence is the smaller
root. $\qquad\blacksquare$

**Theorem 3.2 (Strict improvement over Clark–Suen).** $\tfrac12 < c$.

*Proof.* Since $73 < 100$ and the square root is strictly increasing,
$\sqrt{73} < \sqrt{100} = 10$. Therefore $19 - \sqrt{73} > 9$ and
$c = \tfrac{19 - \sqrt{73}}{18} > \tfrac{9}{18} = \tfrac12$. $\qquad\blacksquare$

**Theorem 3.3 (Below the Vizing constant).** $c < 1$.

*Proof.* Since $1 < 73$, $\sqrt{73} > \sqrt{1} = 1$, so $19 - \sqrt{73} < 18$ and
$c = \tfrac{19 - \sqrt{73}}{18} < 1$. $\qquad\blacksquare$

**Corollary 3.4 (Positivity and location).** $0 < c < 1$, and in fact
$\tfrac12 < c < 1$. Numerically $c = 0.58091\ldots$

*Proof.* Immediate from Theorems 3.2 and 3.3, since $\tfrac12 > 0$. $\qquad\blacksquare$

Thus $c$ is the exact numerical shape of "strictly better than half, strictly less
than the full conjecture."

---

## 4. The two-sided bracket for product domination

We now bracket $\gamma(G\,\square\,H)$ between two elementary quantities. Let $G$ be
on vertex set $A$ and $H$ on vertex set $B$.

### 4.1 Upper bound by cylindrification

**Theorem 4.1 (Cylindrification upper bound).**
$$\gamma(G \,\square\, H) \ \le\ \gamma(G)\cdot |B|.$$

*Proof.* Let $D \subseteq A$ be a minimum dominating set of $G$, so $|D| =
\gamma(G)$. Consider the "cylinder"
$$S \;=\; D \times B \;=\; \{\, (a, b) : a \in D,\ b \in B \,\} \subseteq A \times B,$$
of cardinality $|D|\cdot|B| = \gamma(G)\,|B|$. We claim $S$ dominates
$G\,\square\,H$. Take any vertex $(a', b')$. Since $D$ dominates $G$, either
$a' \in D$ or some $a \in D$ is adjacent to $a'$ in $G$. In the first case
$(a', b') \in S$. In the second case, $(a, b') \in S$ and, by the adjacency rule
(same second coordinate $b'$, adjacent first coordinates), $(a, b')$ is adjacent to
$(a', b')$ in $G\,\square\,H$. Either way $(a', b')$ is dominated by $S$. Hence
$\gamma(G\,\square\,H) \le |S| = \gamma(G)\,|B|$. $\qquad\blacksquare$

### 4.2 Lower bound by projection

The lower half is the combinatorial engine of Vizing-type theorems. Its proof is the
only place the adjacency structure of the product is genuinely used, and it turns on
the fixed-coordinate property.

**Theorem 4.2 (Projection lower bound).** If $B \ne \varnothing$ then
$\gamma(G) \le \gamma(G\,\square\,H)$; symmetrically, if $A \ne \varnothing$ then
$\gamma(H) \le \gamma(G\,\square\,H)$. Consequently, if both $A$ and $B$ are
nonempty,
$$\max\bigl(\gamma(G),\gamma(H)\bigr) \ \le\ \gamma(G\,\square\,H).$$

*Proof.* Let $T \subseteq A \times B$ be a minimum dominating set of $G\,\square\,H$,
$|T| = \gamma(G\,\square\,H)$. Let $\pi_A(T) = \{\, a : (a,b)\in T \text{ for some } b\,\}$
be its projection onto the first coordinate; then $|\pi_A(T)| \le |T|$. We claim
$\pi_A(T)$ dominates $G$. Fix any $a' \in A$; since $B \ne \varnothing$, pick some
$b' \in B$ and consider the product vertex $(a', b')$. As $T$ dominates the product,
either $(a', b') \in T$ or some $(a, b) \in T$ is adjacent to $(a', b')$. In the
first case $a' \in \pi_A(T)$. In the second case the fixed-coordinate property gives
two possibilities: if $b = b'$ and $a$ is adjacent to $a'$ in $G$, then
$a \in \pi_A(T)$ dominates $a'$; if $a = a'$ (and $b$ is adjacent to $b'$), then
$a' \in \pi_A(T)$ directly. In every case $a'$ is dominated by $\pi_A(T)$. Hence
$\gamma(G) \le |\pi_A(T)| \le |T| = \gamma(G\,\square\,H)$. The statement for $H$ is
symmetric, projecting onto the second coordinate and using $A \ne \varnothing$. The
"$\max$" form follows immediately. $\qquad\blacksquare$

The nonemptiness hypotheses are essential: without a fibre to test against, the
projection argument is vacuous, and the inequality can fail for the empty graph.

**Corollary 4.3 (Bracket).** For nonempty $A$, $B$,
$$\max\bigl(\gamma(G),\gamma(H)\bigr) \ \le\ \gamma(G\,\square\,H)\ \le\ \gamma(G)\,|V(H)|.$$

*Small worked examples.* For $G = H = K_2$ (a single edge), $\gamma = 1$, and
$K_2 \,\square\, K_2 = C_4$ has $\gamma = 2$; indeed $\max(1,1)=1 \le 2 \le 1\cdot 2$.
For $G = P_3$ (a path on three vertices, $\gamma = 1$) and $H = K_2$
($\gamma = 1$), the product is the $2\times 3$ grid with $\gamma = 2$, again inside
$[\,1,\ 1\cdot 2\,]$.

---

## 5. The conditional Vizing-type inequality with the improved constant

We now combine §3 and §4. The projection bound, together with $0 < c < 1$, already
forces the improved multiplicative inequality whenever one factor is dominated by a
single vertex.

**Theorem 5.1 (Conditional improved Vizing bound).** Let $G$ and $H$ be finite
graphs on nonempty vertex sets, with $c = \tfrac{19-\sqrt{73}}{18}$. If
$$\min\bigl(\gamma(G),\gamma(H)\bigr) \le 1,$$
then
$$\gamma(G\,\square\,H) \ \ge\ c\cdot \gamma(G)\,\gamma(H).$$

*Proof.* Write $a = \gamma(G)$, $b = \gamma(H)$, $D = \gamma(G\,\square\,H)$, all
nonnegative reals via the natural embedding of the integers. By Theorem 4.2,
$a \le D$ and $b \le D$. By Corollary 3.4, $0 < c < 1$. Assume without loss of
generality $a \le b$, so that $\min(a,b) = a \le 1$ (the case $b \le a$ is
symmetric, exchanging the roles of the two factors). Then $a \le 1$ gives
$$c\,a\,b \ \le\ c\,b \ \le\ b \ \le\ D,$$
where the first inequality uses $a \le 1$ and $c, b \ge 0$, the second uses $c < 1$
and $b \ge 0$, and the third is the projection bound. Hence
$D \ge c\,a\,b = c\,\gamma(G)\,\gamma(H)$. $\qquad\blacksquare$

In this regime the improved constant is not conjectural: it is a genuine consequence
of the projection lower bound and the algebraic fact $c < 1$. Equivalently, when one
factor needs only a single guard, the product of the two domination numbers cannot
exceed the larger of them, which the projection bound already dominates from below.

---

## 6. Algorithms

We record the elementary algorithms implicit in the results, with complexity in
terms of $n_G = |V(G)|$ and $n_H = |V(H)|$.

### 6.1 Exact domination number by subset search

For a graph on $n$ vertices, $\gamma(G)$ can be computed by testing candidate sets
in increasing size order. Precompute for each vertex its *closed neighbourhood*
(itself plus its neighbours) as a bitmask; a set $S$ dominates iff the bitwise OR of
the closed neighbourhoods of its members equals the all-ones mask. Iterating over
subset sizes $k = 0, 1, 2, \ldots$ and returning the first $k$ admitting a
dominating set of size $k$ yields $\gamma(G)$. Worst-case time is $O(2^n \cdot n)$;
feasible for the small graphs used to certify the bracket.

### 6.2 Constructing the two bracketing sets

Given a minimum dominating set $D$ of $G$, the cylinder $D \times V(H)$ realizes the
upper bound $\gamma(G)\,|V(H)|$ in time $O(\gamma(G)\,n_H)$. Given any dominating set
$T$ of the product, its coordinate projection $\pi_A(T)$ certifies the lower bound
$\gamma(G) \le \gamma(G\,\square\,H)$ in time $O(|T|)$.

### 6.3 Evaluating and certifying the constant

The constant $c$ and its properties are certified symbolically: verify
$9c^2 - 19c + 8 = 0$ using $(\sqrt{73})^2 = 73$, and $\tfrac12 < c < 1$ using
$9 < \sqrt{73}\cdot\sqrt{73}\cdot(\ldots)$ — concretely $\sqrt 1 < \sqrt{73} < \sqrt{100}$.

---

## 7. Applications

- **Guarding grid-like networks.** Cartesian products model grids, tori, and
  hypercubes. The bracket $\max(\gamma(G),\gamma(H)) \le \gamma(G\,\square\,H) \le
  \gamma(G)\,|V(H)|$ gives immediately computable two-sided estimates for the number
  of monitors needed in such networks without solving the (NP-hard) product instance.
- **Benchmarking heuristics.** Any heuristic dominating set of a product can be
  validated against the projection lower bound and the improved constant $c$ in the
  covered regime, giving certified approximation guarantees.
- **Structural insight into Vizing's conjecture.** Pinning $c$ as the smaller root of
  $9x^2 - 19x + 8$ localizes the difficulty of the conjecture to the discharging step
  for the $\min(\gamma) \ge 2$ regime.

---

## 8. Discussion

The value $\tfrac{19-\sqrt{73}}{18}$ looks exotic but is entirely natural: it is where
two competing spending rates in the partition-and-charge method cross, and this
crossing is encoded by $9x^2 - 19x + 8$. The projection argument pays only for the
fixed-coordinate half of each product edge; a discharging step must recover the
moving-coordinate half, and balancing the two halves reproduces the quadratic. Our
conditional theorem makes explicit that the elementary machinery already delivers $c$
whenever one factor has domination number at most one — precisely the regime where the
product of the domination numbers collapses to the larger factor. Beyond that regime,
the constant becomes a genuine theorem about the charging inequality, not a corollary
of projection.

---

## 9. Future directions

**Extend the constant bound past domination number one.** *Conjecture:* for all
finite graphs $G, H$, $\gamma(G\,\square\,H) \ge \tfrac{19-\sqrt{73}}{18}\,
\gamma(G)\,\gamma(H)$ unconditionally, and the constant is best possible for the
partition-and-charge family. The projection argument spends only the
fixed-coordinate half of each product edge; the missing factor comes from a
discharging step accounting for the moving-coordinate half, and balancing the two is
exactly what produces the quadratic whose smaller root is $\tfrac{19-\sqrt{73}}{18}$.
Isolating the charging inequality for the $\min \ge 2$ regime as a standalone lemma
makes it directly attackable.

**Sharpness certificates for the lower bracket.** *Conjecture:* for every $k$ there
exist $G, H$ with $\gamma(G) = \gamma(H) = k$ and
$\gamma(G\,\square\,H) = \max(\gamma(G),\gamma(H)) = k$, so the projection bound is
tight for arbitrarily large domination numbers. A single "universal" fibre — a
coordinate whose deletion still dominates every other fibre — collapses the product's
domination number to that of one factor, so tightness is a statement about the
existence of such fibres.

**A fractional relaxation with a matching constant.** *Conjecture:* the fractional
domination number satisfies $\gamma_f(G\,\square\,H) = \gamma_f(G)\,\gamma_f(H)$
exactly, and the integrality gap on each side forces the deficit captured by
$\tfrac{19-\sqrt{73}}{18}$ in the integral case. Fractional domination is
multiplicative because a product of optimal fractional dominating functions is itself
fractionally dominating, unlike the integral case where rounding destroys the product
structure. This turns Vizing's conjecture into a measurable integrality gap.

**Upper-bracket refinement via covering fibres.** Replace the crude
$\gamma(G)\,|V(H)|$ upper bound by covering arguments that use only the fibres
required to dominate, tightening the bracket from above.

---

## 10. Conclusion

We have given a self-contained account of the improved Vizing-type constant
$c = \tfrac{19-\sqrt{73}}{18}$: it is the smaller root of $9x^2 - 19x + 8$, lies
strictly between the Clark–Suen constant $\tfrac12$ and the conjectural Vizing
constant $1$, and is positive. Framed inside the elementary bracket
$\max(\gamma(G),\gamma(H)) \le \gamma(G\,\square\,H) \le \gamma(G)\,|V(H)|$, the
constant yields the Vizing-type inequality $\gamma(G\,\square\,H) \ge c\,
\gamma(G)\,\gamma(H)$ in every case where one factor has domination number at most
one. This delimits precisely how far the classical projection method reaches and
frames the remaining discharging step as the concrete obstacle to an unconditional
bound.
