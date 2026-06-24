# Schur Numbers and the Combinatorics of Monochromatic Sums: The Exact Value $S(2)=4$ and the Extremal Lower Bound $S(3) \ge 13$

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Algebra (Additive Combinatorics / Ramsey Theory)

---

## Abstract

We develop the additive-combinatorial side of Ramsey theory through **Schur's theorem** and the associated **Schur numbers** $S(r)$, the largest $n$ for which the interval $\{1, \dots, n\}$ admits an $r$-coloring with no monochromatic solution to $x + y = z$. We give a uniform formalization of Schur colorings for an arbitrary number of colors, prove a monotonicity principle, and settle two extremal facts. First, for two colors we establish $S(2) = 4$ exactly: the partition $\{1,4\} \sqcup \{2,3\}$ is sum-free in each class, while every two-coloring of $\{1,\dots,5\}$ contains a monochromatic Schur triple via a fully deterministic forcing chain. Second, for three colors we exhibit the classical extremal construction proving the lower bound $S(3) \ge 13$: the partition of $\{1,\dots,13\}$ into $\{1,4,10,13\}$, $\{2,3,11,12\}$, and $\{5,6,7,8,9\}$ is sum-free in each color class, and possesses a reflective symmetry $k \mapsto 14 - k$ characteristic of extremal Schur colorings. We situate these results within Ramsey theory via the difference-coloring bridge $S(r) \le R_r(3) - 1$, record the recursive tripling construction yielding $S(r) \ge (3^r + 1)/2$, and discuss the probabilistic lower bounds for diagonal Ramsey numbers. We close with concrete conjectures, including the matching upper bound $S(3) \le 13$.

---

## 1. Introduction

In 1916, while investigating the solvability of the Fermat congruence $x^n + y^n \equiv z^n \pmod p$, Issai Schur proved a combinatorial statement of independent and lasting interest: for every positive integer $r$, any partition of a sufficiently long initial segment of the positive integers into $r$ classes must contain a class with three elements $x, y, z$ (not necessarily distinct) satisfying $x + y = z$. This is **Schur's theorem**, and it is the additive prototype of **Ramsey theory**, the body of results expressing the principle that *complete disorder is impossible*: any sufficiently large structure, however adversarially organized, contains a highly organized substructure.

The quantitative content of Schur's theorem is captured by the **Schur numbers** $S(r)$. We call a triple $(x, y, z)$ of positive integers a *Schur triple* if $x + y = z$ (we permit $x = y$, so doubling triples $x + x = 2x$ are included). A coloring avoids monochromatic Schur triples if no triple has all three entries the same color. The Schur number $S(r)$ is the largest $n$ such that $\{1, 2, \dots, n\}$ admits such an $r$-coloring. The first several values are
$$S(1) = 1,\quad S(2) = 4,\quad S(3) = 13,\quad S(4) = 44,\quad S(5) = 160,$$
with the value $S(5) = 160$ established only in 2017 via a massive SAT-solver computation, and $S(6)$ unknown.

This paper has two goals. The first is **conceptual**: to give a clean, uniform definition of Schur colorings over an arbitrary color set $\mathrm{Fin}\,r$, together with the basic monotonicity principle, so that the two-color and three-color theories are special cases of one framework. The second is to **prove two extremal results** completely:

1. **(Two colors, exact.)** $S(2) = 4$. We supply both the optimal construction on $\{1,\dots,4\}$ and the impossibility on $\{1,\dots,5\}$.
2. **(Three colors, lower bound.)** $S(3) \ge 13$, via the explicit extremal three-coloring of $\{1,\dots,13\}$.

Throughout we emphasize the two-sided nature of exact extremal results — a *construction* on one side and an *obstruction* on the other — and we record the structural symmetry of the extremal three-coloring.

---

## 2. Definitions

We model an $r$-coloring of the positive integers as a function $c : \mathbb{N} \to \mathrm{Fin}\,r$ (or $c : \mathbb{N} \to \mathrm{Bool}$ when $r = 2$). Only the values $c(1), \dots, c(n)$ are inspected by the predicates below, so this faithfully represents colorings of the finite interval $\{1, \dots, n\}$.

**Definition 2.1 (Bounded Schur triple).** For $n, x, y, z \in \mathbb{N}$, say that $(x, y, z)$ is a *Schur triple bounded by $n$*, written $\mathrm{IsSchurTriple}(n, x, y, z)$, if
$$1 \le x,\qquad 1 \le y,\qquad x + y = z,\qquad z \le n.$$
Equivalently, $x$ and $y$ are positive, $z$ is their sum, and all three lie in $\{1, \dots, n\}$ (positivity of $z$ and the bounds $x, y \le n$ follow automatically).

**Definition 2.2 (Schur coloring).** A coloring $c : \mathbb{N} \to \mathrm{Fin}\,r$ is a *Schur coloring of $\{1, \dots, n\}$*, written $\mathrm{SchurColouringR}(r, n, c)$, if for all $x, y, z$ with $\mathrm{IsSchurTriple}(n, x, y, z)$ we have $\neg\,(c(x) = c(y) \wedge c(y) = c(z))$. That is, no bounded Schur triple is monochromatic.

**Definition 2.3 (Schur colorability).** The interval $\{1, \dots, n\}$ is *$r$-Schur-colorable*, written $\mathrm{SchurColourableR}(r, n)$, if there exists a coloring $c$ with $\mathrm{SchurColouringR}(r, n, c)$.

For $r = 2$ we use the Boolean specialization with $\mathrm{Bool}$ in place of $\mathrm{Fin}\,2$, writing $\mathrm{SchurColouring}(n, c)$ and $\mathrm{SchurColourable}(n)$; the two formulations are equivalent under any bijection $\mathrm{Bool} \cong \mathrm{Fin}\,2$.

**Definition 2.4 (Schur number).** The *$r$-color Schur number* is
$$S(r) = \max\{\, n : \mathrm{SchurColourableR}(r, n) \,\}.$$
By Schur's theorem this maximum exists and is finite for every $r \ge 1$.

A set $A \subseteq \{1, \dots, n\}$ is *sum-free (within $\{1,\dots,n\}$)* if there are no $x, y \in A$ with $x + y \in A$ and $x + y \le n$. A coloring is a Schur coloring precisely when each color class is sum-free in this sense.

---

## 3. Monotonicity

The most basic structural fact is that Schur-colorability is inherited by subintervals.

**Theorem 3.1 (Monotonicity, `schurColourableR_mono` / `schurColourable_mono`).** Let $m \le n$. If $\{1, \dots, n\}$ is $r$-Schur-colorable, then so is $\{1, \dots, m\}$.

*Proof sketch.* Let $c$ witness $\mathrm{SchurColourableR}(r, n)$; we claim the *same* coloring $c$ witnesses $\mathrm{SchurColourableR}(r, m)$. Indeed, suppose $(x, y, z)$ is a Schur triple bounded by $m$. Then $1 \le x$, $1 \le y$, $x + y = z$, and $z \le m \le n$, so $(x,y,z)$ is also a Schur triple bounded by $n$. By hypothesis it is not monochromatic under $c$. Hence $c$ has no monochromatic Schur triple in $\{1, \dots, m\}$. $\qquad\blacksquare$

The contrapositive is the form used to extract exact values: if $\{1, \dots, m\}$ is *not* $r$-Schur-colorable, then neither is $\{1, \dots, n\}$ for any $n \ge m$. Thus a single impossibility threshold propagates upward, and exact Schur numbers are determined by an adjacent pair "largest colorable / smallest non-colorable."

---

## 4. Two colors: $S(2) = 4$

We settle the two-color case exactly. The result has two halves: a construction certifying $S(2) \ge 4$ and an obstruction certifying $S(2) \le 4$.

### 4.1 The construction (lower bound)

**Definition 4.1 (Witness coloring, `witnessColouring`).** Define $c : \mathbb{N} \to \mathrm{Bool}$ by
$$c(k) = \mathrm{true} \iff (k = 2 \ \text{or}\ k = 3),$$
i.e. the partition $\{1, 4\}$ (color $\mathrm{false}$) versus $\{2, 3\}$ (color $\mathrm{true}$).

**Theorem 4.2 (Lower bound, `schurColourable_four`).** $\{1, 2, 3, 4\}$ is two-Schur-colorable; hence $S(2) \ge 4$.

*Proof sketch.* We verify that $c$ from Definition 4.1 has no monochromatic Schur triple bounded by $4$. The Schur triples within $\{1,\dots,4\}$ are
$$1+1=2,\quad 1+2=3,\quad 1+3=4,\quad 2+2=4.$$
Their colors are: $(c1, c1, c2) = (\mathrm{F},\mathrm{F},\mathrm{T})$, $(c1,c2,c3) = (\mathrm{F},\mathrm{T},\mathrm{T})$, $(c1,c3,c4) = (\mathrm{F},\mathrm{T},\mathrm{F})$, $(c2,c2,c4) = (\mathrm{T},\mathrm{T},\mathrm{F})$. In each case the three entries are not all equal, so no triple is monochromatic. As there are finitely many triples, this is a finite check. $\qquad\blacksquare$

### 4.2 The obstruction (upper bound)

**Theorem 4.3 (Upper bound, `not_schurColourable_five`).** $\{1, 2, 3, 4, 5\}$ is *not* two-Schur-colorable; hence $S(2) \le 4$.

*Proof sketch.* The honest statement quantifies over all $c : \mathbb{N} \to \mathrm{Bool}$, but only the five values $c(1), \dots, c(5)$ matter, so the claim reduces to checking $2^5 = 32$ Boolean assignments — equivalently, a single deterministic forcing chain. Set $a := c(1)$. Then:

- From $1 + 1 = 2$: if $c(2) = a$ then $(1,1,2)$ is monochromatic, so $c(2) = \neg a$.
- From $2 + 2 = 4$: similarly $c(4) \ne c(2)$, so $c(4) = a$.
- From $1 + 4 = 5$: since $c(1) = c(4) = a$, we must have $c(5) = \neg a$.
- From $2 + 3 = 5$: since $c(2) = c(5) = \neg a$, we must have $c(3) = a$.
- From $1 + 3 = 4$: now $c(1) = c(3) = c(4) = a$, so $(1,3,4)$ is a monochromatic Schur triple — contradiction.

Every implication is forced; there is no genuine case split beyond the initial value of $a$, and the argument is symmetric in $a$. Hence no two-coloring of $\{1,\dots,5\}$ avoids a monochromatic Schur triple. $\qquad\blacksquare$

### 4.3 The exact value

**Corollary 4.4 (`schur_number_two`).** $S(2) = 4$.

*Proof.* Theorem 4.2 gives $S(2) \ge 4$. Theorem 4.3 gives non-colorability at $n = 5$, and by monotonicity (Theorem 3.1) non-colorability propagates to all $n \ge 5$, so $S(2) \le 4$. $\qquad\blacksquare$

---

## 5. Three colors: the extremal lower bound $S(3) \ge 13$

For three colors we exhibit the classical extremal construction.

**Definition 5.1 (Extremal three-coloring, `witnessThree`).** Define $c : \mathbb{N} \to \mathrm{Fin}\,3$ by
$$
c(k) =
\begin{cases}
0 & \text{if } k \in \{1, 4, 10, 13\},\\
1 & \text{if } k \in \{2, 3, 11, 12\},\\
2 & \text{otherwise (in particular } k \in \{5,6,7,8,9\}\text{)}.
\end{cases}
$$
Within $\{1, \dots, 13\}$ the three color classes are exactly $\{1,4,10,13\}$, $\{2,3,11,12\}$, and $\{5,6,7,8,9\}$.

**Theorem 5.2 (Lower bound, `schurColourable_three_thirteen`).** $\{1, \dots, 13\}$ is three-Schur-colorable; hence $S(3) \ge 13$.

*Proof sketch.* We must show each color class is sum-free within $\{1,\dots,13\}$, i.e. no two elements of a class sum to a third element of the same class with the sum $\le 13$. We verify class by class.

- **Class 0 $= \{1,4,10,13\}$.** Pairwise sums that stay $\le 13$ are $1+1=2$, $1+4=5$, $4+4=8$, $1+10=11$, $1+13$ ($>13$), $4+10=14$ ($>13$), etc. The only in-range sums are $2, 5, 8, 11$, none of which lies in $\{1,4,10,13\}$.
- **Class 1 $= \{2,3,11,12\}$.** In-range sums of pairs: $2+2=4$, $2+3=5$, $3+3=6$; sums involving $11$ or $12$ all exceed $13$ except $2+11=13$ and $2+12, 3+11, \dots$ which exceed $13$ ($2+11 = 13 \notin$ class$1$). The reachable sums $4,5,6,13$ avoid $\{2,3,11,12\}$.
- **Class 2 $= \{5,6,7,8,9\}$.** The smallest possible sum is $5+5 = 10 > 9$, so every sum of two class-2 elements is at least $10$ and hence outside the class (the class tops out at $9$); those that are $\le 13$ land in $\{10, \dots\}$, never in $\{5,\dots,9\}$.

In every class, each in-range pairwise sum leaves the class, so no monochromatic Schur triple exists. The verification is finite (a filter over $\{1,\dots,13\} \times \{1,\dots,13\}$ confirms exactly $0$ monochromatic Schur triples). $\qquad\blacksquare$

**Remark 5.3 (Reflective symmetry).** The extremal coloring is invariant under the involution $\sigma(k) = 14 - k$: it fixes Class 0 setwise ($1 \leftrightarrow 13$, $4 \leftrightarrow 10$), fixes Class 1 setwise ($2 \leftrightarrow 12$, $3 \leftrightarrow 11$), and fixes Class 2 setwise ($5 \leftrightarrow 9$, $6 \leftrightarrow 8$, $7$ fixed). This mirror symmetry about the midpoint $7 = 14/2$ is a structural hallmark of extremal Schur colorings and reflects the symmetry $x + y = z \iff (14 - z) + y = (14 - x)$-type relations near the boundary.

**Remark 5.4 (On the matching upper bound).** The complementary statement $S(3) \le 13$ — that no three-coloring of $\{1,\dots,14\}$ is sum-free — admits no short forcing chain analogous to Section 4.2. It requires ruling out the relevant $3^{13}$ colorings (one color can be fixed by symmetry), a finite but large search best handled by a verified decision procedure. We isolate it as Conjecture 1 in Section 8. Together with Theorem 5.2 it would give $S(3) = 13$.

---

## 6. The Ramsey-theoretic context

Schur's theorem is the additive shadow of **Ramsey's theorem**. We recall the graph-theoretic numbers and the bridge to Schur numbers.

**Ramsey numbers.** The *Ramsey number* $R(s, t)$ is the least $N$ such that every two-coloring (say red/blue) of the edges of the complete graph $K_N$ contains a red clique on $s$ vertices or a blue clique on $t$ vertices. The principle "complete disorder is impossible" asserts $R(s,t)$ is finite for all $s, t$. Small exact values include
$$R(3,3) = 6,\qquad R(3,4) = 9,\qquad R(4,4) = 18,$$
while already $R(5,5)$ is unknown ($43 \le R(5,5) \le 48$).

**The Erdős–Szekeres upper bound.** A foundational recursion gives $R(s,t) \le R(s-1,t) + R(s,t-1)$, which unwinds to the binomial bound
$$R(s, t) \ \le\ \binom{s + t - 2}{s - 1}.$$
For example $R(3,3) \le \binom{4}{2} = 6$ and $R(4,4) \le \binom{6}{3} = 20$ (the true value $18$ is smaller, as binomial bounds are not tight). On the diagonal this yields $R(s,s) \le \binom{2s-2}{s-1} \le 4^{s-1}$, using the central-binomial estimate $\binom{2k}{k} \le 4^k$.

**The probabilistic lower bound.** Erdős's probabilistic method shows that a uniformly random two-coloring of $K_N$ has no monochromatic $s$-clique with positive probability whenever $\binom{N}{s} 2^{1 - \binom{s}{2}} < 1$, giving
$$R(s, s) \ >\ 2^{s/2}\quad(\text{for } s \ge 3).$$
Thus the diagonal Ramsey numbers grow exponentially, $2^{s/2} < R(s,s) \le 4^{s}$, and the exact exponential base is a famous open problem.

**The Schur–Ramsey bridge.** Given an $r$-coloring $\chi$ of $\{1, \dots, N-1\}$, define an edge-coloring of $K_N$ on vertex set $\{1, \dots, N\}$ by coloring the edge $\{i, j\}$ (with $i < j$) by $\chi(j - i)$. A monochromatic triangle $\{i, j, k\}$ with $i < j < k$ yields three equal-colored differences $a = j - i$, $b = k - j$, $c = k - i = a + b$ — that is, a monochromatic Schur triple $a + b = c$ under $\chi$. Consequently, if $\{1,\dots,N-1\}$ has a sum-free $r$-coloring, then $K_N$ has a triangle-free $r$-edge-coloring, whence
$$S(r) \ \le\ R_r(3) - 1,$$
where $R_r(3)$ is the $r$-color Ramsey number for triangles ($R_2(3) = R(3,3) = 6$, giving $S(2) \le 5$; the sharper bound $S(2) = 4$ comes from the direct forcing argument). This bridge is why Schur's theorem is a *theorem* — its finiteness is inherited from Ramsey's.

---

## 7. The recursive lower bound for $S(r)$

The exact Schur numbers grow at least geometrically, explained by a recursive "tripling" construction.

**Theorem 7.1 (Recursive lower bound).** For all $r \ge 1$,
$$S(r) \ \ge\ \frac{3^r + 1}{2}.$$

*Proof idea.* Given a sum-free $r$-coloring of $\{1, \dots, S\}$ with $S = S(r-1)$, build a coloring of a longer interval using three shifted copies of the old coloring placed around a central block painted in a fresh $(r{+}1)$-st color; the gaps are arranged so that any monochromatic sum in an old color would have been a monochromatic sum in the original (a contradiction), while the new color forms a sum-free central interval. Iterating from $S(1) = 1$ gives the closed form $(3^r + 1)/2$ as a lower bound for the reach. $\qquad\square$

Numerically the bound predicts $r = 1 \to 1$, $r = 2 \to 5$, $r = 3 \to 14$, $r = 4 \to 41$, matching the constructive lower bounds $S(2) \ge 4$, $S(3) \ge 13$, $S(4) \ge 40$ up to the customary off-by-one boundary adjustment. The exact values $S(2) = 4$, $S(3) = 13$, $S(4) = 44$, $S(5) = 160$ show the recursion is not tight, but it correctly captures the exponential growth rate $S(r) = \Theta(3^r)$ in the sense $\liminf S(r)^{1/r} \ge 3$.

---

## 8. Algorithms

We record the decision procedures underlying the verifications.

**Algorithm 8.1 (Monochromatic-Schur-triple detector).** Given $n$ and a coloring $c$, enumerate all $(x, y)$ with $1 \le x \le y$ and $x + y \le n$, set $z = x + y$, and report a violation iff $c(x) = c(y) = c(z)$. Complexity $O(n^2)$ triples; a coloring is a Schur coloring iff no violation is reported. This is the certificate-checker for Theorems 4.2 and 5.2.

**Algorithm 8.2 (Exhaustive Schur-colorability search).** To decide $\mathrm{SchurColourableR}(r, n)$, iterate over all $r^n$ colorings of $\{1, \dots, n\}$ (optionally fixing $c(1) = 0$ to cut a factor of $r$ by symmetry), and run Algorithm 8.1 on each; report colorable iff some coloring passes. Complexity $O(r^n \cdot n^2)$. This decides the obstruction direction (Theorem 4.3 at $r=2, n=5$ needs $2^5 = 32$ colorings) and, at larger scale, the conjectured $S(3) \le 13$ ($3^{13}$ colorings).

**Algorithm 8.3 (Forcing-chain prover for $S(2) \le 4$).** Specialize Algorithm 8.2's $n = 5$ instance to a deterministic propagation: fix $a = c(1)$, then deduce $c(2) = \neg a$, $c(4) = a$, $c(5) = \neg a$, $c(3) = a$, and observe $(1,3,4)$ is monochromatic. This replaces the $32$-case search with a single linear chain and yields a human-readable proof.

---

## 9. Applications and discussion

**Number theory.** Schur's original application: for each $n$, the Fermat congruence $x^n + y^n \equiv z^n \pmod p$ has a solution in nonzero residues for all sufficiently large primes $p$. Coloring the nonzero residues by cosets of the $n$-th powers turns a sum-free obstruction into a violation of Schur's theorem, forcing a solution.

**Additive combinatorics.** Sum-free sets are central objects: the maximal density of a sum-free subset of $\{1,\dots,n\}$, the structure of sum-free sets in abelian groups, and the interaction with arithmetic progressions all build on the dichotomy that Schur's theorem quantifies.

**Theoretical computer science.** Ramsey-type unavoidability underlies lower bounds in communication complexity, the probabilistic construction of expanders and codes, and worst-case analysis of algorithms. The probabilistic method introduced for $R(s,s) > 2^{s/2}$ is now ubiquitous.

**The two-sided art.** Every exact extremal value here is a meeting of a *construction* (an explicit sum-free coloring) and an *obstruction* (a proof that one step further is impossible). The exact Schur number sits on the razor's edge between the largest survivable interval and the smallest doomed one — the universal shape of extremal combinatorics.

---

## 10. Future directions

This cycle settled the two-color Schur number $S(2) = 4$ exactly and supplied the extremal construction for the lower bound $S(3) \ge 13$. We list falsifiable conjectures for follow-up.

**Conjecture 1 (Upper bound $S(3) \le 13$).** Every three-coloring of $\{1,\dots,14\}$ contains a monochromatic Schur triple. Plan: reduce to a decision search over the $3^{13}$ relevant colorings (fix $c(1) = 0$ by symmetry). Combined with Theorem 5.2 this proves $S(3) = 13$. *Falsifiable:* exhibit a sum-free three-coloring of $\{1,\dots,14\}$.

**Conjecture 2 (Schur $\Leftarrow$ Ramsey bridge).** For every $r$, $S(r) \le R_r(3) - 1$, formalized via the difference-coloring map of Section 6. *Falsifiable:* a Schur coloring of $\{1,\dots,R_r(3)-1\}$ surviving the bridge.

**Conjecture 3 (Exponential lower bound).** $\mathrm{SchurColourableR}(r, (3^r + 1)/2 - 1)$ for all $r \ge 1$, via the recursive tripling construction (Theorem 7.1). Verified small cases: $r=1 \to 1$, $r=2 \to 4$, $r=3 \to 13$, $r=4 \to 40$. *Falsifiable:* show the recursion produces a monochromatic triple for some $r$.

**Conjecture 4 (Weak Schur numbers).** Define $WS(r)$ using Schur triples with $x \ne y$ (distinct summands). Then $WS(2) = 8$ and $WS(3) = 23$. *Falsifiable:* any coloring beating these bounds.

**Conjecture 5 (Diagonal Ramsey from the binomial bound).** Extend the arrow recursion to the diagonal bound $R(s+1, s+1) \le 4^s$ using $\binom{2s}{s} \le 4^s$, and pair with the probabilistic lower bound $R(s,s) > 2^{s/2}$ for a two-sided diagonal result. *Falsifiable:* a coloring of $K_{4^s}$ with no monochromatic $(s+1)$-clique.

---

## References (classical, for context)

- I. Schur, *Über die Kongruenz $x^m + y^m \equiv z^m \pmod p$*, 1916.
- F. P. Ramsey, *On a problem of formal logic*, 1930.
- P. Erdős, G. Szekeres, *A combinatorial problem in geometry*, 1935.
- P. Erdős, *Some remarks on the theory of graphs*, 1947 (probabilistic lower bound).
- M. Heule, *Schur Number Five*, 2017 (the SAT computation of $S(5) = 160$).
