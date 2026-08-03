# Tropical Convexity, Box Helly Theorems, and Canonical Feasibility Certificates

**Aristotle**  
**August 3, 2026**

## Abstract

We study normalized max-plus tropical convexity in finite-dimensional real space and isolate a class for which intersection and optimization admit exact, elementary certificates: products of closed coordinate intervals. A normalized tropical combination of $x,y\in\mathbb R^d$ is the vector with coordinates $\max\{x_i,t+y_i\}$ for $t\le 0$. We define tropical segments, tropical convex sets, and finitely generated tropical convex hulls. Arbitrary intersections of tropically convex sets remain tropically convex; every coordinate box is tropically convex; and the tropical convex hull of a nonempty finite point family is tropically convex by an explicit max-distributivity identity.

The central result is a Helly theorem with Helly number $2$ for finite families of tropical boxes: the total intersection is nonempty if and only if every pair intersects. The argument reduces pairwise box intersection to cross-bound inequalities and applies the one-dimensional interval theorem coordinatewise. For a nonempty family, feasibility is characterized exactly by $\ell_{p,i}\le u_{q,i}$ for all boxes $p,q$ and coordinates $i$. When this condition holds, the vector $x_i^*=\max_k\ell_{k,i}$ is a canonical common point and is coordinatewise least among all points satisfying the lower bounds. When feasibility fails, two boxes and one coordinate provide an infeasibility certificate. These facts yield an $O(nd)$ feasibility-and-certificate algorithm for $n$ boxes in $d$ dimensions and clarify applications to scheduling, resource bounds, and monotone optimization.

## 1. Introduction

Tropical mathematics replaces ordinary addition by an extremum while retaining ordinary addition as scalar multiplication. Under the max-plus convention,

$$
a\oplus b=\max(a,b),\qquad a\odot b=a+b.
$$

This algebra appears naturally whenever parallel alternatives compete through a maximum and serial effects accumulate through addition. Synchronization times, precedence-constrained schedules, discrete-event systems, and bottleneck objectives all exhibit this pattern.

Convexity in max-plus geometry differs visibly from Euclidean convexity. Tropical segments are piecewise-linear paths determined by coordinatewise maxima, and tropical polytopes are upper envelopes of shifted generators. Nevertheless, many familiar questions remain meaningful: Which constructions preserve convexity? How can one recognize whether a family of convex regions has a common point? Can infeasibility be certified by a small subfamily? Can a feasible point be selected canonically and used for optimization?

This paper answers these questions for finitely generated tropical hulls and, more completely, for coordinate boxes. The box class is elementary but substantial. It models independent lower and upper restrictions on a finite collection of variables. Its product structure permits a sharp Helly theorem: pairwise consistency implies global consistency in every dimension. Thus its Helly number is $2$, rather than a dimension-dependent quantity.

There are four main contributions.

1. We give a self-contained account of normalized max-plus combinations, tropical segments, tropical convexity, and finite tropical hulls.
2. We establish structural closure: arbitrary intersections, coordinate boxes, and finitely generated tropical convex hulls are tropically convex.
3. We prove equivalent criteria for the nonempty intersection of a finite box family: global feasibility, pairwise feasibility, and all coordinatewise cross-bound inequalities.
4. We identify the coordinatewise maximum of the lower bounds as the least feasible candidate and derive a linear-time-in-the-input-size feasibility algorithm with a two-box infeasibility certificate.

The essential distinction is between tropical convexity and separability. Tropical convexity explains why boxes belong naturally to the max-plus setting. Separability explains why their Helly number is only $2$: each coordinate is governed by a one-dimensional interval problem.

## 2. Max-plus preliminaries

Throughout, $d$ is a nonnegative integer and points of $\mathbb R^d$ are written $x=(x_1,\ldots,x_d)$. Inequalities between vectors are coordinatewise unless otherwise stated.

### Definition 2.1 (Normalized tropical combination)

For $x,y\in\mathbb R^d$ and $t\in\mathbb R$ with $t\le 0$, the normalized max-plus tropical combination of $x$ with $y$ at parameter $t$ is

$$
C_t(x,y)=x\oplus(t\odot y),
$$

or explicitly,

$$
C_t(x,y)_i=\max\{x_i,t+y_i\},\qquad i=1,\ldots,d.
$$

The normalization fixes the coefficient of $x$ at $0$ and requires the coefficient of $y$ not to exceed it. Swapping the roles of $x$ and $y$ covers the complementary normalization.

### Definition 2.2 (Tropical segment)

The tropical segment between $x,y\in\mathbb R^d$ is

$$
[x,y]_{\mathrm{trop}}
=
\{C_t(x,y):t\le 0\}\cup\{C_s(y,x):s\le 0\}.
$$

It contains $x$ and $y$: for sufficiently negative parameters the shifted second point loses every coordinatewise maximum. At parameter $0$, both halves contain $x\oplus y$, the coordinatewise maximum.

### Definition 2.3 (Tropical convexity)

A set $S\subseteq\mathbb R^d$ is tropically convex if for all $x,y\in S$ and all $t\le 0$,

$$
C_t(x,y)\in S.
$$

Because the condition also applies after interchanging $x$ and $y$, every tropical segment between points of $S$ lies in $S$.

### Definition 2.4 (Finite tropical convex hull)

Let $p^{(1)},\ldots,p^{(m)}\in\mathbb R^d$, where $m\ge 1$. Their max-plus tropical convex hull is

$$
\operatorname{tconv}\{p^{(1)},\ldots,p^{(m)}\}
=
\left\{z\in\mathbb R^d:
\begin{array}{l}
\text{there exist }w_1,\ldots,w_m\in\mathbb R\text{ such that}\\
\displaystyle z_i=\max_{1\le k\le m}(w_k+p^{(k)}_i)\text{ for every }i
\end{array}
\right\}.
$$

Thus a hull point is the coordinatewise upper envelope of finitely many translated generators. No additional normalization on the weights is needed for the closure theorem below.

### Proposition 2.5 (Intersection closure)

The intersection of any family of tropically convex subsets of $\mathbb R^d$ is tropically convex. In particular, the intersection of two tropically convex sets is tropically convex.

**Proof sketch.** Let $S=\bigcap_{\alpha}S_\alpha$, where every $S_\alpha$ is tropically convex. If $x,y\in S$, then $x,y\in S_\alpha$ for every $\alpha$. Hence $C_t(x,y)\in S_\alpha$ for every $t\le 0$ and every $\alpha$. Therefore $C_t(x,y)\in S$. The empty indexing family causes no difficulty: its intersection is the whole ambient space. $\square$

## 3. Tropical convex hulls

The closure of a tropical hull under tropical combinations follows from the distributive behavior of finite maxima.

### Lemma 3.1 (Envelope combination identity)

Let $a_k,b_k,c_k\in\mathbb R$ for $1\le k\le m$, and let $t\in\mathbb R$. Then

$$
\max\left\{\max_k(a_k+c_k),\ t+\max_k(b_k+c_k)\right\}
=
\max_k\left(\max\{a_k,t+b_k\}+c_k\right).
$$

**Proof sketch.** Since addition by $t$ commutes with a finite maximum,

$$
t+\max_k(b_k+c_k)=\max_k(t+b_k+c_k).
$$

The maximum of two finite maxima over the same finite index set equals the maximum, over that index set, of the pairwise maxima. Finally,

$$
\max\{a_k+c_k,t+b_k+c_k\}=\max\{a_k,t+b_k\}+c_k.
$$

Combining these identities proves the claim. $\square$

### Theorem 3.2 (Tropical convexity of finite tropical hulls)

The tropical convex hull of every nonempty finite family of points in $\mathbb R^d$ is tropically convex.

**Proof sketch.** Let $z^{(1)}$ and $z^{(2)}$ lie in the hull, represented by weights $u_k$ and $v_k$:

$$
z^{(1)}_i=\max_k(u_k+p^{(k)}_i),
\qquad
z^{(2)}_i=\max_k(v_k+p^{(k)}_i).
$$

For $t\le 0$, define new weights

$$
r_k=\max\{u_k,t+v_k\}.
$$

Lemma 3.1, with $c_k=p^{(k)}_i$, gives

$$
C_t(z^{(1)},z^{(2)})_i
=
\max_k(r_k+p^{(k)}_i)
$$

for every coordinate $i$. The combination therefore has a valid hull representation and belongs to the same tropical convex hull. $\square$

This theorem expresses an important stability principle: taking upper envelopes of shifted generators is closed under taking normalized upper envelopes again.

## 4. Tropical boxes

### Definition 4.1 (Coordinate box)

For vectors $\ell,u\in\mathbb R^d$, define

$$
B(\ell,u)=\prod_{i=1}^d[\ell_i,u_i]
=
\{x\in\mathbb R^d:\ell_i\le x_i\le u_i\text{ for all }i\}.
$$

We allow $B(\ell,u)$ to be empty, which occurs exactly when $\ell_i>u_i$ for at least one coordinate.

### Theorem 4.2 (Tropical convexity of boxes)

Every coordinate box is tropically convex.

**Proof.** Let $x,y\in B(\ell,u)$ and $t\le 0$. Put $z=C_t(x,y)$. For each coordinate $i$,

$$
z_i=\max\{x_i,t+y_i\}\ge x_i\ge\ell_i.
$$

Moreover, $x_i\le u_i$, while $t+y_i\le y_i\le u_i$. Therefore the maximum of these two quantities is also at most $u_i$. Thus $\ell_i\le z_i\le u_i$ for every $i$, so $z\in B(\ell,u)$. $\square$

Combining Theorem 4.2 with Proposition 2.5 shows that every intersection of tropical boxes is tropically convex. For finite intersections, more can be said: the intersection, when nonempty, is itself a box whose lower vector is the coordinatewise maximum of the lower vectors and whose upper vector is the coordinatewise minimum of the upper vectors.

## 5. The interval Helly principle

The proof of the box theorem is driven by the following exact one-dimensional statement.

### Theorem 5.1 (Helly theorem for closed intervals)

Let $I_k=[a_k,b_k]$ be a finite family of closed intervals indexed by $k=1,\ldots,n$. If

$$
a_i\le b_j\qquad\text{for all }i,j,
$$

then the intervals have a common point. If $n\ge 1$, the value

$$
x^*=\max_{1\le k\le n}a_k
$$

belongs to every $I_k$. Consequently, a finite family of closed intervals has nonempty total intersection whenever every pair has nonempty intersection.

**Proof.** For every $k$, $a_k\le x^*$ by the definition of maximum. Fix $j$. The cross-bound hypothesis gives $a_k\le b_j$ for every $k$, so taking the maximum over $k$ yields $x^*\le b_j$. Hence $x^*\in[a_j,b_j]$ for every $j$.

Now suppose every pair intersects. For each $i,j$, choose $y\in I_i\cap I_j$. Then $a_i\le y\le b_j$, giving $a_i\le b_j$. The first part applies. The converse is immediate because a common point belongs to every pair. $\square$

For an empty family, the universal intersection is conventionally the whole line, so existence is automatic. The explicit maximum requires the nonempty hypothesis.

## 6. Pairwise and global intersection of boxes

Let

$$
B_k=\prod_{i=1}^d[\ell_{k,i},u_{k,i}],
\qquad k=1,\ldots,n.
$$

### Lemma 6.1 (Pairwise intersection implies cross bounds)

If $B_p\cap B_q\ne\varnothing$, then

$$
\ell_{p,i}\le u_{q,i}
$$

for every coordinate $i$.

**Proof.** Choose $x\in B_p\cap B_q$. Membership in $B_p$ gives $\ell_{p,i}\le x_i$, and membership in $B_q$ gives $x_i\le u_{q,i}$. Transitivity yields the result. $\square$

Notice that applying the lemma to both ordered pairs $(p,q)$ and $(q,p)$ supplies both directions of cross compatibility.

### Theorem 6.2 (Tropical Box Helly Theorem)

For a finite family $B_1,\ldots,B_n$ of coordinate boxes in $\mathbb R^d$, the following are equivalent:

1. The total intersection $\bigcap_{k=1}^nB_k$ is nonempty.
2. Every pairwise intersection $B_p\cap B_q$ is nonempty.

Thus the class of tropical boxes has Helly number at most $2$.

**Proof.** If a point lies in every box, it lies in every pair, so the first condition implies the second.

Conversely, assume every pair intersects. By Lemma 6.1,

$$
\ell_{p,i}\le u_{q,i}
$$

for all $p,q,i$. Fix a coordinate $i$. The intervals

$$
[\ell_{1,i},u_{1,i}],\ldots,[\ell_{n,i},u_{n,i}]
$$

satisfy all cross-bound inequalities, so Theorem 5.1 provides a value $x_i$ lying in every one of them. Perform this construction independently for each coordinate. The resulting vector $x=(x_1,\ldots,x_d)$ satisfies

$$
\ell_{k,i}\le x_i\le u_{k,i}
$$

for every $k$ and $i$, and hence belongs to every $B_k$. $\square$

The theorem is a tropical Helly statement because each box is tropically convex. The number $2$ is stronger than the familiar dimension-dependent behavior of unrestricted convex sets. It comes from the Cartesian product structure, not from a claim that all tropically convex sets share this bound.

### Remark 6.3 (Sharpness)

The bound cannot generally be reduced to $1$. In every positive dimension, two nonempty boxes can be disjoint; for example, in the first coordinate take intervals $[0,1]$ and $[2,3]$ and use any common nonempty intervals in the remaining coordinates. Each singleton subfamily intersects, while the pair does not.

## 7. Exact feasibility and the canonical lower point

Assume henceforth that $n\ge 1$. Define the **canonical lower point** $x^*\in\mathbb R^d$ by

$$
x_i^*=\max_{1\le k\le n}\ell_{k,i}.
$$

This point aggregates the strongest lower requirement in each coordinate.

### Lemma 7.1 (Dominance of lower bounds)

For every box $k$ and coordinate $i$,

$$
\ell_{k,i}\le x_i^*.
$$

**Proof.** Each $\ell_{k,i}$ is one of the finitely many terms whose maximum defines $x_i^*$. $\square$

### Lemma 7.2 (Least point satisfying all lower bounds)

If $x\in\mathbb R^d$ satisfies $\ell_{k,i}\le x_i$ for every $k,i$, then

$$
x_i^*\le x_i
$$

for every coordinate $i$.

**Proof.** Fix $i$. Every term $\ell_{k,i}$ is at most $x_i$, so their maximum is at most $x_i$. $\square$

### Theorem 7.3 (Exact cross-bound characterization)

For a nonempty finite family of boxes $B_k=B(\ell_k,u_k)$, the following are equivalent:

1. $\bigcap_kB_k\ne\varnothing$.
2. For all boxes $p,q$ and coordinates $i$,

$$
\ell_{p,i}\le u_{q,i}.
$$

When these conditions hold, the canonical lower point $x^*$ belongs to every box.

**Proof.** Suppose $x$ belongs to every box. Then

$$
\ell_{p,i}\le x_i\le u_{q,i}
$$

for every $p,q,i$, proving the cross bounds.

Conversely, assume all cross bounds. Lemma 7.1 gives $\ell_{q,i}\le x_i^*$ for every $q,i$. For a fixed $q,i$, each $\ell_{p,i}\le u_{q,i}$; taking the maximum over $p$ gives $x_i^*\le u_{q,i}$. Thus

$$
\ell_{q,i}\le x_i^*\le u_{q,i}
$$

for all $q,i$, so $x^*$ lies in every box. $\square$

### Corollary 7.4 (Equivalent feasibility criteria)

For a nonempty finite family of boxes, the following are equivalent:

1. The family has a common point.
2. Every pair of boxes intersects.
3. Every cross-bound inequality $\ell_{p,i}\le u_{q,i}$ holds.
4. For every coordinate $i$,

$$
\max_k\ell_{k,i}\le\min_k u_{k,i}.
$$

**Proof sketch.** The equivalence of the first three conditions follows from Theorems 6.2 and 7.3. The fourth condition is simply the simultaneous compression of all cross bounds in each coordinate: all lower endpoints lie below all upper endpoints exactly when the largest lower endpoint lies below the smallest upper endpoint. $\square$

## 8. Monotone optimization

The least-point property turns feasibility into an optimization statement.

### Definition 8.1 (Coordinatewise monotone objective)

A function $F:\mathbb R^d\to\mathbb R$ is coordinatewise nondecreasing if

$$
x_i\le y_i\text{ for all }i
\quad\Longrightarrow\quad
F(x)\le F(y).
$$

It is coordinatewise strictly increasing if the same hypotheses together with $x\ne y$ imply $F(x)<F(y)$.

### Theorem 8.2 (Canonical monotone optimality)

If a nonempty finite box family is feasible, then its canonical lower point $x^*$ minimizes every coordinatewise nondecreasing objective over the common feasible region. If the objective is coordinatewise strictly increasing, then $x^*$ is the unique minimizer.

**Proof.** Every feasible point satisfies every lower bound, so Lemma 7.2 gives $x^*\le x$ coordinatewise. Monotonicity yields $F(x^*)\le F(x)$. Under strict monotonicity, equality can hold only when $x=x^*$. $\square$

Examples include positive weighted sums

$$
F(x)=\sum_{i=1}^dc_ix_i,
\qquad c_i>0,
$$

and other objectives that strictly penalize every coordinate increase. The coordinatewise maximum $F(x)=\max_i x_i$ is nondecreasing but not strictly increasing in the stated sense, so it need not have a unique minimizer.

## 9. Infeasibility certificates

A Helly theorem is equivalently a theorem about small obstructions.

### Theorem 9.1 (Two-box infeasibility certificate)

If a finite family of boxes has empty total intersection, then there exist two boxes whose intersection is empty.

**Proof.** This is the contrapositive of Theorem 6.2. For a constructive proof, Corollary 7.4 implies that some coordinate $i$ satisfies

$$
\max_k\ell_{k,i}>\min_k u_{k,i}.
$$

Choose $p$ attaining the maximum lower endpoint and $q$ attaining the minimum upper endpoint. Then

$$
\ell_{p,i}>u_{q,i}.
$$

No real number can be simultaneously at least $\ell_{p,i}$ and at most $u_{q,i}$, so no point lies in both $B_p$ and $B_q$. $\square$

The certificate consists of $(p,q,i)$ and the strict inequality $\ell_{p,i}>u_{q,i}$. It is locally checkable and independent of the number of remaining boxes.

## 10. Algorithms

### Algorithm 10.1 (Canonical feasibility and certificate scan)

**Input:** lower and upper arrays $\ell_{k,i}$ and $u_{k,i}$ for $n\ge 1$ boxes in $d$ dimensions.

**Output:** either a common feasible point $x^*$ or a certificate $(p,q,i)$ identifying two incompatible boxes.

For each coordinate $i$:

1. Find an index $p_i$ maximizing $\ell_{k,i}$ and set $L_i=\ell_{p_i,i}$.
2. Find an index $q_i$ minimizing $u_{k,i}$ and set $U_i=u_{q_i,i}$.
3. If $L_i>U_i$, return the certificate $(p_i,q_i,i)$.

If no coordinate fails, return $x^*=(L_1,\ldots,L_d)$.

### Theorem 10.2 (Algorithm correctness)

Algorithm 10.1 returns a common point exactly when the box family is feasible. If it returns $(p,q,i)$, then $B_p\cap B_q=\varnothing$.

**Proof sketch.** If every $L_i\le U_i$, then for every box $k$,

$$
\ell_{k,i}\le L_i\le U_i\le u_{k,i},
$$

where the last inequality follows because $U_i$ is the minimum upper endpoint. Thus $L=(L_i)$ belongs to every box. Conversely, any common point $x$ would satisfy $L_i\le x_i\le U_i$, so feasibility prohibits $L_i>U_i$. When such a strict inequality occurs, the maximizing lower box and minimizing upper box are incompatible in coordinate $i$. $\square$

### Complexity

The algorithm scans $n$ lower endpoints and $n$ upper endpoints in each of $d$ coordinates. Its running time is $O(nd)$ and its auxiliary space is $O(d)$ if all extrema are retained, or $O(1)$ beyond the output if coordinates are streamed. Since the input itself contains $2nd$ scalar bounds, the running time is asymptotically optimal in the standard explicit-input model.

A direct pairwise checker would examine $O(n^2)$ pairs and up to $d$ coordinates per pair, requiring $O(n^2d)$ time. The extremal characterization avoids this unnecessary quadratic factor while still recovering an explicit offending pair.

## 11. Applications

### 11.1 Scheduling windows

Let $x_i$ be the start time of task $i$. A policy, scenario, or stakeholder may impose a box of admissible windows

$$
\ell_{k,i}\le x_i\le u_{k,i}.
$$

If all policies are to hold simultaneously, the canonical schedule starts every task at the latest lower deadline imposed by any policy. Global consistency is equivalent to that latest lower deadline not exceeding the earliest upper deadline in each coordinate. If the system is inconsistent, two policies and one task explain the conflict.

This model does not encode precedence differences such as $x_i-x_j\le c$; those constraints couple coordinates and require additional graph-theoretic machinery. The box theorem is the separable baseline against which such extensions can be measured.

### 11.2 Resource allocation

Suppose $x_i$ denotes the allocated amount of resource $i$. Different operating regimes impose lower service requirements and upper capacity limits. The canonical point uses exactly the strongest lower requirement for every resource. It minimizes every coordinatewise increasing cost and provides a transparent explanation of infeasibility when a requirement exceeds some regime’s capacity.

### 11.3 Robust parameter selection

In robust design, each scenario may permit a box of parameter values. Pairwise overlap of all scenario boxes is enough for a single parameter vector to satisfy every scenario. This is stronger than one generally expects from arbitrary uncertainty regions and follows specifically from coordinate separability.

### 11.4 Discrete-event and max-plus systems

Max-plus combinations model synchronization: one state competes with a shifted second state, and the later event wins in each coordinate. Tropical convexity of boxes says that coordinate windows remain valid under this normalized synchronization operation. Intersections of such windows therefore form stable tropical feasible regions.

## 12. Discussion and limitations

The results separate three mathematical layers.

First, there is an algebraic layer. Tropical hulls are finite upper envelopes of shifted points, and their convexity follows from the fact that a maximum of maxima can be reorganized into one maximum. This statement is genuinely tropical and does not rely on boxes.

Second, there is an order-theoretic layer. Boxes are preserved by tropical combinations because lower bounds are inherited from the unshifted operand and upper bounds survive nonpositive shifts. Arbitrary intersections preserve tropical convexity as they do for ordinary convexity.

Third, there is a product layer. The Helly number $2$, exact cross-bound criterion, canonical point, and two-box certificate all rely on coordinate independence. These conclusions should not be extrapolated without proof to arbitrary tropically convex sets. General tropical sets can couple coordinates through piecewise-linear relations, and their Helly behavior may depend on dimension and normalization.

The treatment uses finite real coordinates rather than adjoining a tropical zero such as $-\infty$. This keeps boxes and maxima within ordinary Euclidean space. Extensions to the completed max-plus semiring would require careful conventions for endpoints and scalar shifts.

The empty-family and zero-dimensional cases are mathematically benign but algorithmically special. An empty constraint family is feasible by convention, while the explicit canonical maximum of lower bounds requires at least one box. In zero dimensions there is a unique point, so every family of boxes intersects unless an alternative representation permits intrinsically empty zero-dimensional boxes.

## 13. Future research

Several directions emerge naturally. One explicit conjectural property in the present framework is that testing every subfamily of size at most $2d$ suffices for arbitrary normalized max-plus tropically convex subsets of $\mathbb R^d$. This is a proposed target rather than a result of the box theory above.

1. **General tropical Helly bounds.** Resolve the $2d$ conjectural bound and determine whether the sharper threshold $d+1$ is valid for normalized max-plus tropically convex sets when $d>0$.
2. **Sharpness for boxes.** The elementary two-disjoint-box construction confirms that the proven box Helly number cannot be lowered from $2$ to $1$ in positive dimension.
3. **Monotone-objective optimality.** The least-point theorem already yields uniqueness for coordinatewise strictly increasing objectives. Further work can classify broader objective classes and stability under perturbations of the bounds.
4. **Difference constraints.** Add inequalities $x_i-x_j\le c$. A finite-dimensional bound on the size of infeasibility certificates would connect tropical Helly theory with negative-cycle certificates and shortest-path consistency.
5. **Carathéodory–Helly duality.** Support bounds for tropical hull representations may lead to small separation certificates for points outside finitely generated tropical convex sets, and those certificates may in turn imply general Helly bounds.

## 14. Conclusion

Normalized max-plus convexity admits a concise structural theory. Tropical convexity survives arbitrary intersections. Coordinate boxes are tropically convex. Finite tropical convex hulls are tropically convex because two weighted upper envelopes combine into a third through coordinatewise maxima of their weights.

For boxes, the theory becomes exact. Pairwise intersection, global intersection, coordinatewise cross bounds, and comparison of the largest lower endpoint with the smallest upper endpoint are equivalent. The coordinatewise largest lower endpoint is a canonical feasible point and the least point satisfying all lower constraints. It therefore minimizes every coordinatewise nondecreasing objective. If feasibility fails, one coordinate and two boxes witness the contradiction.

The resulting picture is both geometric and algorithmic: a tropical feasible region is stable under max-plus mixing, while its existence is decided by extremal interval data. A system containing many constraints either possesses a canonical common point or fails for a reason that can be displayed in a single coordinate by a pair of constraints.
