# Tropical Convexity: Sharp Helly and Carathéodory Numbers, Cramer Dependence, and Max-Plus Residuation

**Author:** Aristotle
**Date:** 2026-08-10

---

## Abstract

We develop the combinatorial convexity of the max-plus semiring
$(\mathbb{R}, \oplus, \odot) = (\mathbb{R}, \max, +)$ and determine exactly the
two fundamental invariants of tropical convexity in $\mathbb{R}^d$. We prove a
**tropical Cramer dependence theorem**: any $d+1$ vectors of $\mathbb{R}^d$ are
tropically dependent, with explicit witnessing weights given by the tropical
determinants of the row-deleted minors. From it we deduce a **tropical Helly
theorem with Helly number exactly $d$** for tropical cones (max-plus submodules)
in $\mathbb{R}^d$ — one better than the classical bound $d+1$ — together with a
matching extremal family. For the weaker notion of tropically convex sets (no
scaling invariance) we prove the Helly number is exactly $d+1$, again with a
matching extremal family; this settles in the affirmative, with a strictly
better constant, a previously conjectured bound of $2d$, and shows that the
conjecture as stated fails in the degenerate case $d = 0$. We show that the
implication is reversible: the Helly property, taken as a hypothesis, forces
tropical dependence, so the Helly theorem and the Cramer dependence theorem are
equivalent. On the Carathéodory side we prove that the **Carathéodory number of
tropical cone hulls in $\mathbb{R}^d$ is exactly $d$**, and establish a
constructive **colourful Carathéodory theorem**. Finally we connect the geometry
to max-plus optimisation: we prove the **residuation (Galois) correspondence**
$A \otimes x \le b \iff x \le A \sharp b$ and the **principal-solution
solvability criterion**, giving an $O(mn)$ decision procedure for
$A \otimes x = b$; and we derive from Helly that tropical linear feasibility is
$(d+1)$-local and that difference-constraint feasibility is $d$-local — the
Helly-theoretic shadow of the Bellman–Ford negative-cycle criterion. We also
show the finiteness hypothesis is essential: Helly fails for infinite families
of tropical cones.

**Keywords:** tropical convexity, max-plus algebra, Helly number, Carathéodory
number, tropical Cramer rule, residuation, difference constraints.

---

## 1. Introduction

### 1.1 The max-plus semiring

Let $\mathbb{R}_{\max} = (\mathbb{R} \cup \{-\infty\}, \oplus, \odot)$ with
$a \oplus b = \max(a,b)$ and $a \odot b = a + b$. Throughout this paper we work
over the *finite* part $\mathbb{R}$: all our statements are about vectors in
$\mathbb{R}^d$ with real (finite) entries and real weights, which is the setting
in which the tropical projective torus $\mathbb{R}^d/\mathbb{R}\mathbf{1}$ is a
genuine manifold and where the sharp constants below are attained.

The semiring $\mathbb{R}_{\max}$ is the arithmetic of a large family of discrete
optimisation problems. Shortest paths, critical-path scheduling, dynamic
programming recursions, Viterbi decoding, and the tropicalisation of algebraic
varieties are all instances of max-plus (or the isomorphic min-plus) linear
algebra. It is therefore natural to ask which structural theorems of classical
convex geometry survive the change of arithmetic, and with which constants.

### 1.2 Tropical convexity

Replacing the classical convex combination $\lambda x + (1-\lambda) y$ by its
max-plus analogue leads to two closely related notions.

**Definition 1.1 (Tropical cone).** A set $S \subseteq \mathbb{R}^d$ is a
*tropical cone* (equivalently a max-plus submodule) if for all $x, y \in S$ and
all $s, t \in \mathbb{R}$,
$$\bigl(i \mapsto \max(s + x_i,\; t + y_i)\bigr) \in S .$$

**Definition 1.2 (Tropically convex set).** A set $S \subseteq \mathbb{R}^d$ is
*tropically convex* if for all $x, y \in S$ and all $t \le 0$,
$$\bigl(i \mapsto \max(x_i,\; t + y_i)\bigr) \in S .$$

Definition 1.2 is the normalised version: the weights $0$ and $t \le 0$ are the
max-plus analogue of coefficients $\lambda,\mu \ge 0$ with $\lambda \oplus \mu =
\lambda \vee \mu = 0$, i.e. summing to the tropical unit. Every tropical cone is
tropically convex; conversely a tropically convex set need not be closed under
tropical scaling $x \mapsto s \odot x = (s+x_1,\dots,s+x_d)$. Taking $x = y$ and
$s = t$ in Definition 1.1 shows that tropical cones *are* scaling invariant, so
they descend to subsets of the tropical projective torus. This single fact is the
source of the one-unit gap between the two Helly numbers proved below.

**Definition 1.3 (Tropical cone hull).** For a family $(p_k)_{k \in \iota}$ of
points of $\mathbb{R}^d$ and a nonempty finite index set $F$, the *tropical cone
hull* is
$$\operatorname{tcone}(p; F) \;=\; \Bigl\{ z \in \mathbb{R}^d \;:\; \exists\,
\lambda \in \mathbb{R}^{\iota},\ \forall i,\ z_i = \max_{k \in F}\bigl(\lambda_k
+ p_{k i}\bigr) \Bigr\}.$$

It is the smallest tropical cone containing the $p_k$, $k \in F$.

### 1.3 Summary of results

| Invariant | Classical value in $\mathbb{R}^d$ | Tropical value proved here |
|---|---|---|
| Helly number, cones | $d+1$ | $\mathbf{d}$ (sharp) |
| Helly number, convex sets | $d+1$ | $\mathbf{d+1}$ (sharp) |
| Carathéodory number, cones | $d$ | $\mathbf{d}$ (sharp) |
| Dependence of $d+1$ vectors | linear dependence | Cramer dependence (Thm. 2.4) |

together with: the equivalence of the Helly theorem with the dependence theorem
(Thm. 6.1); the colourful Carathéodory theorem (Thm. 5.4); the residuation
Galois connection and principal-solution criterion (Thms. 7.2, 7.4); locality of
tropical linear feasibility and of difference-constraint feasibility
(Thms. 8.1, 8.3); and the failure of Helly for infinite families (Thm. 8.4).

---

## 2. Tropical Cramer dependence

### 2.1 Tropical determinants

**Definition 2.1 (Tropical determinant).** For a square matrix
$M \in \mathbb{R}^{m \times m}$ set
$$\operatorname{tropdet} M \;=\; \max_{\pi \in \mathfrak{S}_m} \ \sum_{r=1}^{m}
M_{r,\pi(r)} .$$
This is the value of the *optimal assignment problem* with cost matrix $M$; it is
the max-plus permanent, and in the max-plus semiring permanent and determinant
coincide because there are no signs.

Note the crucial structural feature: $\operatorname{tropdet}$ is a maximum over
$m!$ terms, so it is attained by at least one optimal permutation, and *ties*
between optimal permutations are the tropical replacement for vanishing
determinants.

**Definition 2.2 (Tropical dependence).** Vectors
$A_0, \dots, A_d \in \mathbb{R}^d$ (rows of a matrix
$A \in \mathbb{R}^{(d+1)\times d}$) are *tropically dependent* if there exist
weights $\lambda \in \mathbb{R}^{d+1}$ such that for every coordinate
$i \in \{1,\dots,d\}$ the maximum
$$\max_{0 \le k \le d} \bigl(\lambda_k + A_{k i}\bigr)$$
is attained by at least two distinct indices $k$.

Equivalently (and this is the form we use in the applications): for every
coordinate $i$ and every index $k$ there is $j \ne k$ with
$\lambda_k + A_{ki} \le \lambda_j + A_{ji}$. Indeed, if the maximum is attained
twice, then for any $k$ at least one of the two maximisers differs from $k$ and
dominates $k$'s value; conversely the "for every $k$" condition applied to a
maximiser $k$ produces a second one.

### 2.2 The Cramer weights

**Definition 2.3 (Cramer weight).** For $A \in \mathbb{R}^{(d+1)\times d}$ and
$k \in \{0,\dots,d\}$ let $A^{(\hat k)} \in \mathbb{R}^{d \times d}$ be $A$ with
row $k$ deleted, and set
$$\lambda_k \;=\; \operatorname{tropdet} A^{(\hat k)} .$$

This is exactly Cramer's rule transplanted: the coefficient of the $k$-th vector
in the dependence is the (tropical) determinant of the complementary minor.

**Theorem 2.4 (Tropical Cramer dependence).** *For every
$A \in \mathbb{R}^{(d+1)\times d}$ and every coordinate $i$, the maximum
$\max_k (\lambda_k + A_{ki})$ over the Cramer weights of Definition 2.3 is
attained at (at least) two distinct rows. Consequently any $d+1$ vectors of
$\mathbb{R}^d$ are tropically dependent, with explicitly computable witnessing
weights.*

*Proof sketch.* Fix a coordinate $i$. Form the augmented square matrix
$\widetilde A^{(i)} \in \mathbb{R}^{(d+1)\times(d+1)}$ obtained from $A$ by
prepending a copy of its own $i$-th column; thus $\widetilde A^{(i)}$ has two
equal columns (column $0$ and column $i+1$).

*Step 1 (Laplace expansion along the prepended column).* For a permutation $\pi$
of $\{0,\dots,d\}$ let $W(\pi) = \sum_r \widetilde A^{(i)}_{r,\pi(r)}$ and let
$k = \pi^{-1}(0)$ be the row that receives the prepended column. Deleting row
$k$ and column $0$ turns $\pi$ into a permutation of the remaining $d$ rows onto
the $d$ original columns, so
$$W(\pi) \;=\; A_{k i} + \sum_{r \ne k} A_{r,\pi(r)-1} \;\le\; A_{ki} +
\operatorname{tropdet} A^{(\hat k)} \;=\; \lambda_k + A_{ki},$$
with equality achieved for a suitable $\pi$ (extend an optimal permutation of
$A^{(\hat k)}$ by $k \mapsto 0$). Hence
$$\operatorname{tropdet} \widetilde A^{(i)} \;=\; \max_k \bigl(\lambda_k +
A_{ki}\bigr) .$$

*Step 2 (Two equal columns).* Let $\pi$ be an optimal permutation for
$\widetilde A^{(i)}$, and set $a = \pi^{-1}(0)$ and $b = \pi^{-1}(i+1)$, the two
rows carrying the two identical columns. Since $0 \ne i+1$ we have $a \ne b$. Let
$\pi' = \pi \circ (a\,b)$ be $\pi$ with the two assignments swapped. Because
columns $0$ and $i+1$ are equal, $\widetilde A^{(i)}_{a,i+1} = \widetilde
A^{(i)}_{a,0}$ and $\widetilde A^{(i)}_{b,0} = \widetilde A^{(i)}_{b,i+1}$, so
$W(\pi') = W(\pi)$: the swap is weight-preserving. Therefore $\pi'$ is also
optimal.

*Step 3 (Conclusion).* By Step 1 applied to $\pi$, the optimum equals
$\lambda_a + A_{ai}$; applied to $\pi'$ (whose row receiving column $0$ is now
$b$), the same optimum equals $\lambda_b + A_{bi}$. Since $a \ne b$, the maximum
$\max_k(\lambda_k + A_{ki})$ is attained at two distinct rows. $\square$

**Remark 2.5.** The proof is the exact max-plus incarnation of the classical
argument "a matrix with two equal columns is singular": classically one swaps the
two columns to see that the determinant equals its own negative; tropically,
where there are no signs, one swaps the two *rows carrying* the equal columns to
see that the optimal assignment is not unique. Non-uniqueness of the optimum is
the tropical form of vanishing.

**Remark 2.6 (Complexity).** The Cramer weights are $d+1$ optimal assignment
values on $d \times d$ matrices, computable in $O(d^4)$ total time by the
Hungarian algorithm; for small $d$ brute force over $d!$ permutations is
adequate. Sharpness in the number of vectors: $d$ vectors of $\mathbb{R}^d$ need
not be tropically dependent. For $A = \begin{pmatrix} 0 & 0 \\ 1 & 3\end{pmatrix}$
a dependence would require $\lambda_0 + 0 = \lambda_1 + 1$ (column $1$) and
$\lambda_0 + 0 = \lambda_1 + 3$ (column $2$), which are inconsistent; with the
best available weights $\lambda = (1,0)$ the column data
$(\text{max}, \#\text{argmax})$ is $[(1,2),(3,1)]$, the second maximum being
attained uniquely.

---

## 3. The tropical Helly theorem for cones

### 3.1 Closure properties

**Lemma 3.1 (Scaling invariance).** *If $S$ is a tropical cone and $x \in S$,
then $(s + x_i)_i \in S$ for every $s \in \mathbb{R}$.*

*Proof.* Apply Definition 1.1 with $y = x$ and $t = s$; the resulting point is
$i \mapsto \max(s + x_i, s + x_i) = s + x_i$. $\square$

**Lemma 3.2 (Finite combinations).** *If $S$ is a tropical cone, $F$ is a
nonempty finite index set, $p_k \in S$ for all $k \in F$, and
$\lambda \in \mathbb{R}^{F}$, then*
$$\Bigl(i \mapsto \max_{k \in F}\bigl(\lambda_k + p_{ki}\bigr)\Bigr) \in S .$$

*Proof.* Induction on $|F|$. For $|F| = 1$ this is Lemma 3.1. For the inductive
step, split off one index and use Definition 1.1 with $s$ the new weight, $t = 0$
and $y$ the combination of the rest, noting that
$\max_{k \in F \cup \{k_0\}} = \max\bigl(\lambda_{k_0}+p_{k_0 i},\,
\max_{k \in F}\bigr)$. $\square$

In particular tropical cone hulls are tropical cones.

### 3.2 The theorem

**Theorem 3.3 (Tropical Helly theorem, Helly number $d$).** *Let $d \ge 1$, let
$(C_k)_{k \in \iota}$ be a family of tropical cones in $\mathbb{R}^d$, and let
$F$ be a finite index set. If every $I \subseteq F$ with $|I| \le d$ satisfies
$\bigcap_{k \in I} C_k \ne \varnothing$, then $\bigcap_{k \in F} C_k \ne
\varnothing$.*

*Proof sketch.* We prove by induction on $m$ the statement: for every finite
$F$ with $|F| \le m$, $d$-wise intersection implies total intersection.

The base cases $|F| \le d$ are the hypothesis itself. So assume $|F| = m > d$ and
that the claim holds for all smaller index sets. For each $k \in F$, the
subfamily indexed by $F \setminus \{k\}$ satisfies the same $d$-wise hypothesis,
so by induction there is a point
$$y_k \in \bigcap_{j \in F \setminus \{k\}} C_j .$$
Choose $d+1$ distinct indices $k_0,\dots,k_d \in F$ (possible since $m > d$) and
let $A \in \mathbb{R}^{(d+1)\times d}$ be the matrix whose $r$-th row is
$y_{k_r}$. Let $\lambda$ be the Cramer weights of Definition 2.3 and set
$$z_i \;=\; \max_{0 \le r \le d} \bigl(\lambda_r + A_{ri}\bigr).$$

We claim $z \in C_j$ for every $j \in F$.

*Case 1: $j \notin \{k_0,\dots,k_d\}$.* Then every $y_{k_r}$ lies in $C_j$, and
$z$ is a max-plus combination of them, so $z \in C_j$ by Lemma 3.2.

*Case 2: $j = k_{r_0}$ for some $r_0$.* Then all $y_{k_r}$ with $r \ne r_0$ lie
in $C_j$, but $y_{k_{r_0}}$ may not. By Theorem 2.4, in every coordinate $i$ the
maximum defining $z_i$ is attained at two distinct rows, hence at some row
$r \ne r_0$; so
$$z_i \;=\; \max_{r \ne r_0} \bigl(\lambda_r + A_{ri}\bigr)$$
for every $i$ — the offending row is redundant. This exhibits $z$ as a max-plus
combination of points of $C_j$ only, so $z \in C_j$ by Lemma 3.2.

Since $j$ was arbitrary, $z \in \bigcap_{k \in F} C_k$. $\square$

**Corollary 3.4 (Characterisation of nonempty intersection).** *Under the
hypotheses of Theorem 3.3,*
$$\bigcap_{k \in F} C_k \ne \varnothing \iff \forall I \subseteq F,\ |I| \le d:
\ \bigcap_{k \in I} C_k \ne \varnothing .$$
*Equivalently: an empty intersection is always certified by at most $d$ members
of the family.*

The forward implication is trivial; the converse is Theorem 3.3.

### 3.3 Sharpness

**Definition 3.5 (Extremal family).** For $k \in \{1,\dots,d\}$ put
$$T_k \;=\; \{x \in \mathbb{R}^d : \exists\, j \ne k,\ x_k + 1 \le x_j\},$$
the set of points whose $k$-th coordinate is beaten, by at least $1$, by some
other coordinate.

**Lemma 3.6.** *Each $T_k$ is a tropical cone.*

*Proof.* Let $x, y \in T_k$ with witnesses $j_x, j_y$, and let $s,t \in
\mathbb{R}$; write $z_i = \max(s+x_i, t+y_i)$. If $s + x_k \ge t + y_k$ then
$z_k = s + x_k$ and $z_{j_x} \ge s + x_{j_x} \ge s + x_k + 1 = z_k + 1$, so
$j_x$ witnesses $z \in T_k$. Otherwise $z_k = t+y_k$ and $j_y$ works
symmetrically. $\square$

**Lemma 3.7.** *$\bigcap_{k=1}^{d} T_k = \varnothing$ for $d \ge 1$.*

*Proof.* Let $x$ lie in the intersection and let $k$ be a coordinate maximising
$x_k$. The witness $j$ for $T_k$ gives $x_k + 1 \le x_j \le x_k$, absurd.
$\square$

**Lemma 3.8.** *For every $I \subsetneq \{1,\dots,d\}$ we have
$\bigcap_{k \in I} T_k \ne \varnothing$.*

*Proof.* Pick $k_0 \notin I$ and take $x_j = 0$ if $j = k_0$ and $x_j = -1$
otherwise. For $k \in I$ we have $k \ne k_0$, so $x_k + 1 = 0 \le 0 = x_{k_0}$,
and $k_0$ is a witness. $\square$

**Theorem 3.9 (Sharpness).** *For every $d \ge 1$ there are $d$ tropical cones in
$\mathbb{R}^d$ such that every $d-1$ of them have a common point but the total
intersection is empty. Hence, with Theorem 3.3, the tropical Helly number of
$\mathbb{R}^d$ is exactly $d$.*

*Proof.* Take $T_1,\dots,T_d$ and combine Lemmas 3.6–3.8. $\square$

**Remark 3.10.** The gain of one unit over the classical bound $d+1$ is precisely
scaling invariance: a tropical cone is determined by its image in the
$(d-1)$-dimensional torus $\mathbb{R}^d/\mathbb{R}\mathbf{1}$, so morally the
classical count "$\dim + 1$" is applied in dimension $d-1$. The proof above makes
this precise without ever quotienting, via the Cramer weights.

---

## 4. Helly number $d+1$ for tropically convex sets

Without scaling invariance the bound rises by one, and the transfer is by
homogenisation.

**Definition 4.1 (Chart and homogenisation).** Define
$\pi : \mathbb{R}^{d+1} \to \mathbb{R}^d$ by
$\pi(u)_i = u_i - u_{d+1}$ (the standard affine chart of the tropical projective
torus), and for $S \subseteq \mathbb{R}^d$ set
$\widehat S = \pi^{-1}(S) \subseteq \mathbb{R}^{d+1}$.

Note $\pi\bigl((x,0)\bigr) = x$, so $x \in S \iff (x,0) \in \widehat S$, and
$\widehat S$ is scaling invariant by construction since $\pi(s + u) = \pi(u)$.

**Theorem 4.2 (Homogenisation).** *If $S \subseteq \mathbb{R}^d$ is tropically
convex, then $\widehat S \subseteq \mathbb{R}^{d+1}$ is a tropical cone.*

*Proof sketch.* Let $u,v \in \widehat S$, i.e. $\pi(u), \pi(v) \in S$, and let
$s,t \in \mathbb{R}$; put $w_i = \max(s+u_i, t+v_i)$. Using scaling invariance of
$\pi$ we may normalise $u_{d+1} = v_{d+1} = 0$ and absorb $s$ into $t$, reducing
to $s = 0$ and $w = \max(u, t+v)$ with $t \le 0$ or $t \ge 0$; in the first case
$\pi(w)_i = \max(\pi(u)_i, t + \pi(v)_i)$ with $t \le 0$, which lies in $S$ by
tropical convexity, and in the second case one exchanges the roles of $u$ and
$v$. Hence $\pi(w) \in S$, i.e. $w \in \widehat S$. $\square$

**Theorem 4.3 (Helly for tropically convex sets).** *Let $(S_k)_{k \in \iota}$ be
tropically convex subsets of $\mathbb{R}^d$ and $F$ a finite index set. If every
$I \subseteq F$ with $|I| \le d+1$ has $\bigcap_{k\in I} S_k \ne \varnothing$,
then $\bigcap_{k \in F} S_k \ne \varnothing$.*

*Proof.* By Theorem 4.2 the sets $\widehat{S_k}$ are tropical cones in
$\mathbb{R}^{d+1}$; the hypothesis lifts because $x \in \bigcap_{k \in I} S_k$
gives $(x,0) \in \bigcap_{k \in I}\widehat{S_k}$. Theorem 3.3 in dimension $d+1$
(Helly number $d+1$) produces $u \in \bigcap_{k \in F} \widehat{S_k}$, and then
$\pi(u) \in \bigcap_{k \in F} S_k$. $\square$

**Theorem 4.4 (Sharpness).** *There exist $d+1$ tropically convex subsets of
$\mathbb{R}^d$, any $d$ of which have a common point, with empty total
intersection. Hence the Helly number of tropical convexity in $\mathbb{R}^d$ is
exactly $d+1$.*

*Proof sketch.* Dehomogenise the extremal family of Definition 3.5 one dimension
up: for $k \in \{1,\dots,d+1\}$ put
$$U_k \;=\; \{x \in \mathbb{R}^d : (x,0) \in T_k\} \subseteq \mathbb{R}^d,$$
where $T_k \subseteq \mathbb{R}^{d+1}$. Tropical convexity of $U_k$ follows from
Lemma 3.6 together with the identity
$$\bigl(\max(x_i, t+y_i)\bigr)_i \text{ appended with } 0 \;=\;
\Bigl(j \mapsto \max\bigl(0 + (x,0)_j,\ t + (y,0)_j\bigr)\Bigr) \quad (t \le 0),$$
which holds because $\max(0, t) = 0$ in the last coordinate. Emptiness of
$\bigcap_k U_k$ is Lemma 3.7 in dimension $d+1$. For $|I| \le d$, Lemma 3.8 gives
$u \in \bigcap_{k \in I} T_k \subseteq \mathbb{R}^{d+1}$; the point $\pi(u)$ works
because $(\pi(u), 0)$ is a tropical scaling of $u$ by $-u_{d+1}$, and tropical
cones are scaling invariant (Lemma 3.1). $\square$

**Corollary 4.5 (Resolution of the $2d$ conjecture).** *For every $d \ge 1$, any
finite family of tropically convex subsets of $\mathbb{R}^d$ whose subfamilies of
size at most $2d$ intersect has a nonempty total intersection. For $d = 0$ the
statement is false.*

*Proof.* For $d \ge 1$ we have $d + 1 \le 2d$, so the hypothesis with $2d$ is
stronger than the hypothesis with $d+1$ and Theorem 4.3 applies. For $d = 0$ the
condition "$|I| \le 0$" imposes nothing beyond $I = \varnothing$, which is
satisfied vacuously; taking the single set $S_1 = \varnothing \subseteq
\mathbb{R}^0$ (which is tropically convex) gives a counterexample. $\square$

Thus the conjectured constant $2d$ is correct for $d \ge 1$ but far from sharp
for $d \ge 2$, and the degenerate case $d = 0$ must be excluded.

---

## 5. Tropical Carathéodory numbers

### 5.1 The cone Carathéodory number is $d$

**Theorem 5.1 (Tropical Carathéodory for cones).** *Let $d \ge 1$,
$(p_k)_{k \in \iota}$ a family in $\mathbb{R}^d$, $F$ a finite index set, and
$z \in \operatorname{tcone}(p;F)$. Then there is $G \subseteq F$ with
$|G| \le d$ and $z \in \operatorname{tcone}(p;G)$.*

*Proof.* Write $z_i = \max_{k \in F}(\lambda_k + p_{ki})$. For each coordinate
$i$ choose $\kappa(i) \in F$ attaining the maximum, and set
$G = \kappa(\{1,\dots,d\})$, so $G \subseteq F$ and $|G| \le d$. With the same
weights $\lambda$: for each $i$,
$$\max_{k \in G}(\lambda_k + p_{ki}) \;\ge\; \lambda_{\kappa(i)} +
p_{\kappa(i) i} \;=\; z_i,$$
while $\max_{k \in G} \le \max_{k \in F} = z_i$ since $G \subseteq F$. Hence
equality, and $z \in \operatorname{tcone}(p;G)$. $\square$

The proof is a *selection*: one generator per coordinate. The whole content of
the tropical Carathéodory number is that a max-plus combination is determined
coordinatewise, and each coordinate needs only one witness.

**Theorem 5.2 (Sharpness of the Carathéodory number).** *For every $d \ge 1$
there are $d$ points $p_1,\dots,p_d \in \mathbb{R}^d$ and a point $z$ of their
tropical cone hull lying in the hull of no proper subfamily. Explicitly, take the
tropical unit vectors*
$$p_{k i} = \begin{cases} 0, & i = k,\\ -1, & i \ne k,\end{cases} \qquad z =
\mathbf{0} .$$

*Proof.* With all weights $\lambda_k = 0$ we get
$\max_k p_{ki} = p_{ii} = 0 = z_i$, so $z \in \operatorname{tcone}(p;
\{1,\dots,d\})$. Now suppose $|G| < d$ and $z \in \operatorname{tcone}(p;G)$ with
weights $\lambda$. Choose $i_0 \notin G$ (possible since $|G|<d$). In coordinate
$i_0$ every generator $k \in G$ satisfies $p_{k i_0} = -1$, so
$0 = z_{i_0} = \max_{k \in G}(\lambda_k - 1)$; let $k^\ast$ attain this maximum,
whence $\lambda_{k^\ast} = 1$. But then in coordinate $k^\ast$,
$$0 = z_{k^\ast} = \max_{k \in G}\bigl(\lambda_k + p_{k k^\ast}\bigr) \;\ge\;
\lambda_{k^\ast} + p_{k^\ast k^\ast} = 1 + 0 = 1,$$
a contradiction. $\square$

**Corollary 5.3.** *The Carathéodory number of tropical cones in $\mathbb{R}^d$
is exactly $d$.*

### 5.2 Colourful Carathéodory

**Theorem 5.4 (Colourful tropical Carathéodory).** *Let $d \ge 1$ and let
$p^{(1)},\dots,p^{(d)}$ be $d$ families ("colour classes") of points of
$\mathbb{R}^d$, with finite nonempty index sets $F_1,\dots,F_d$. Suppose a point
$z \in \mathbb{R}^d$ lies in $\operatorname{tcone}(p^{(c)}; F_c)$ for every
colour $c$. Then there is a rainbow selection $\sigma(c) \in F_c$ and weights
$w \in \mathbb{R}^d$ with*
$$z_i \;=\; \max_{1 \le c \le d} \bigl(w_c + p^{(c)}_{\sigma(c),\,i}\bigr)
\qquad (1 \le i \le d).$$
*Explicitly: from class $c$ take a generator attaining the maximum in coordinate
$c$, with $w_c$ the corresponding weight.*

*Proof.* For each colour $c$ let $\lambda^{(c)}$ realise
$z_i = \max_{k \in F_c}(\lambda^{(c)}_k + p^{(c)}_{ki})$ for all $i$, and choose
$\sigma(c) \in F_c$ attaining the maximum in coordinate $i = c$; set
$w_c = \lambda^{(c)}_{\sigma(c)}$.

*Lower bound.* For each coordinate $i$, the colour $c = i$ contributes
$w_i + p^{(i)}_{\sigma(i), i} = z_i$ by the choice of $\sigma(i)$, so
$\max_c (w_c + p^{(c)}_{\sigma(c),i}) \ge z_i$.

*Upper bound.* For each colour $c$ and each coordinate $i$,
$w_c + p^{(c)}_{\sigma(c),i} \le \max_{k \in F_c}(\lambda^{(c)}_k +
p^{(c)}_{ki}) = z_i$. Taking the maximum over $c$ gives $\le z_i$. $\square$

The rainbow selection is thus fully explicit and computable in $O(d \sum_c
|F_c|)$ time, unlike the classical colourful Carathéodory theorem, whose
constructive versions require an iterative pivoting scheme.

---

## 6. Helly and Cramer are equivalent

Theorem 3.3 derived Helly from Cramer dependence. We now close the loop.

**Theorem 6.1 (Dependence from Helly).** *Let $d \ge 1$ and assume the Helly
property in dimension $d$: every family $C_0,\dots,C_d$ of $d+1$ tropical cones
in $\mathbb{R}^d$ whose subfamilies of size $\le d$ intersect has a common point.
Then any $d+1$ points $p_0,\dots,p_d \in \mathbb{R}^d$ are tropically dependent:
there is $\lambda \in \mathbb{R}^{d+1}$ such that for every coordinate $i$ and
every $k$ there is $j \ne k$ with $\lambda_k + p_{ki} \le \lambda_j + p_{ji}$.*

*Proof sketch.* Consider the $d+1$ "leave-one-out" hulls
$$H_k \;=\; \operatorname{tcone}\bigl(p; \{0,\dots,d\}\setminus\{k\}\bigr),
\qquad k = 0,\dots,d,$$
each of which is a tropical cone by Lemma 3.2. Any $d$ of them intersect: if
$|I| \le d$, some index $k_0 \notin I$ exists, and $p_{k_0} \in H_k$ for every
$k \in I$ (since $k \ne k_0$ means $k_0$ is among the generators of $H_k$).
By hypothesis there is $z \in \bigcap_{k} H_k$.

Now *residuate*: define
$$\lambda_j \;=\; \min_{1 \le i \le d} \bigl(z_i - p_{ji}\bigr),$$
the greatest weight with $\lambda_j + p_j \le z$ coordinatewise. Two facts:

1. $\lambda_j + p_{ji} \le z_i$ for all $j,i$, immediately from the definition.
2. For every $k$ and every $i$,
   $z_i = \max_{j \ne k}(\lambda_j + p_{ji})$. Indeed "$\ge$" is (1); for
   "$\le$", membership $z \in H_k$ gives weights $\mu$ with
   $z_i = \max_{j \ne k}(\mu_j + p_{ji})$, and each such $\mu_j$ satisfies
   $\mu_j + p_{ji'} \le z_{i'}$ for all $i'$, hence $\mu_j \le \lambda_j$ by
   maximality of the residuation; substituting gives the bound.

Fix $i$ and $k$. By (2), the maximum $\max_{j \ne k}(\lambda_j + p_{ji})$ equals
$z_i$, and it is attained by some $j \ne k$; by (1), $\lambda_k + p_{ki} \le z_i
= \lambda_j + p_{ji}$. This is exactly tropical dependence. $\square$

**Corollary 6.2.** *In each dimension $d \ge 1$, the tropical Helly theorem
(Theorem 3.3) and the tropical Cramer dependence theorem (Theorem 2.4) are
equivalent.*

The residuation step used in the proof is the same Galois connection developed
independently in §7; the two halves of the theory are literally the same
computation used twice.

---

## 7. Max-plus optimisation: residuation and the principal solution

### 7.1 Setup

**Definition 7.1.** For $A \in \mathbb{R}^{m \times n}$ and $x \in \mathbb{R}^n$
define the max-plus matrix–vector product
$$(A \otimes x)_i \;=\; \max_{1 \le j \le n} \bigl(A_{ij} + x_j\bigr),$$
and for $b \in \mathbb{R}^m$ the *residuated vector*
$$(A \,\sharp\, b)_j \;=\; \min_{1 \le i \le m} \bigl(b_i - A_{ij}\bigr).$$

Interpretation: $A_{ij}$ is the delay from event $j$ to event $i$, $x_j$ the
occurrence time of $j$, $b_i$ the deadline for $i$; then $(A\sharp b)_j$ is the
latest time $j$ may occur without violating any deadline.

### 7.2 The Galois connection

**Theorem 7.2 (Residuation).** *For all $x \in \mathbb{R}^n$,*
$$A \otimes x \le b \iff x \le A \,\sharp\, b$$
*(both inequalities coordinatewise). In particular $A \sharp b$ is the greatest
subsolution of $A \otimes x \le b$, and it is always a subsolution.*

*Proof.* ($\Rightarrow$) Fix $j$. For every $i$, $A_{ij} + x_j \le (A\otimes x)_i
\le b_i$, so $x_j \le b_i - A_{ij}$; taking the minimum over $i$ gives
$x_j \le (A\sharp b)_j$.

($\Leftarrow$) Fix $i$. For every $j$, $x_j \le (A\sharp b)_j \le b_i - A_{ij}$,
so $A_{ij} + x_j \le b_i$; taking the maximum over $j$ gives $(A \otimes x)_i \le
b_i$. Applying this with $x = A\sharp b$ shows $A \sharp b$ is a subsolution.
$\square$

**Lemma 7.3 (Monotonicity).** *If $x \le y$ coordinatewise then
$A \otimes x \le A \otimes y$.* Immediate from monotonicity of $\max$ and $+$.

### 7.3 The principal solution

**Theorem 7.4 (Cuninghame-Green principal solution criterion).** *The system
$A \otimes x = b$ has a solution if and only if $A \otimes (A \sharp b) = b$.*

*Proof.* ($\Leftarrow$) Trivial: $A \sharp b$ is then a solution.

($\Rightarrow$) Let $x$ satisfy $A \otimes x = b$. Then $A \otimes x \le b$, so
$x \le A \sharp b$ by Theorem 7.2. By Lemma 7.3,
$$b \;=\; A \otimes x \;\le\; A \otimes (A \sharp b) \;\le\; b,$$
the last inequality because $A\sharp b$ is a subsolution. Hence equality.
$\square$

**Corollary 7.5 (Decision procedure).** *Solvability of a max-plus linear system
$A \otimes x = b$ with $A \in \mathbb{R}^{m\times n}$ is decidable in $O(mn)$
arithmetic operations: compute $A \sharp b$ ($mn$ subtractions and comparisons),
compute $A \otimes (A \sharp b)$ ($mn$ additions and comparisons), and test
equality with $b$ ($m$ comparisons). When solvable, $A \sharp b$ is the greatest
solution.*

This is the max-plus analogue of Gaussian elimination — with the pleasant
difference that there is nothing to eliminate: the candidate solution is a closed
formula, and the only question is whether it works.

**Proposition 7.6 (Monotone defect).** *If $b \le c$ coordinatewise then
$A \otimes (A \sharp b) \le A \otimes (A \sharp c)$; i.e. the best max-plus
approximation of a target from below is monotone in the target.*

*Proof.* $b \le c$ gives $(A\sharp b)_j = \min_i (b_i - A_{ij}) \le \min_i (c_i -
A_{ij}) = (A\sharp c)_j$; apply Lemma 7.3. $\square$

---

## 8. Consequences for feasibility, and the boundary of the theory

### 8.1 Locality of tropical linear feasibility

**Definition.** For $a,b \in \mathbb{R}^{n}$, the *two-sided tropical halfspace*
in $\mathbb{R}^{n}$ is
$$H(a,b) \;=\; \Bigl\{x : \max_j (a_j + x_j) \le \max_j (b_j + x_j)\Bigr\}.$$

Each $H(a,b)$ is a tropical cone: if $x, y \in H(a,b)$ and
$z_i = \max(s+x_i,t+y_i)$, then
$\max_j (c_j + z_j) = \max\bigl(s + \max_j(c_j+x_j),\, t + \max_j(c_j+y_j)\bigr)$
for any vector $c$, since $\max$ distributes over $\max$ and $+$; applying this
identity to $c = a$ and $c = b$ and using $\max(\alpha,\beta) \le
\max(\alpha',\beta')$ whenever $\alpha \le \alpha'$, $\beta \le \beta'$ gives
$z \in H(a,b)$.

**Theorem 8.1 (Tropical linear feasibility is $(d+1)$-local).** *A finite system
of two-sided tropical linear inequalities in $d+1$ unknowns,*
$$\max_j \bigl(a_{kj}+x_j\bigr) \;\le\; \max_j \bigl(b_{kj}+x_j\bigr), \qquad
k = 1,\dots,n,$$
*is solvable if and only if every subsystem of at most $d+1$ of the inequalities
is solvable.*

*Proof.* Apply Theorem 3.3 in dimension $d+1$ to the cones $H(a_k, b_k)$.
$\square$

Consequently, infeasibility of a tropical linear system in $N$ unknowns always
has a certificate of size $N$: a subsystem of $N$ inequalities that is already
infeasible. This is the max-plus analogue of the Helly-type locality principle
for linear programming.

### 8.2 Difference constraints and Bellman–Ford

**Definition.** For $i,j \in \{1,\dots,d\}$ and $w \in \mathbb{R}$ let
$D(i,j,w) = \{x \in \mathbb{R}^d : x_j \le w + x_i\}$. This is a tropical cone
(check: if $x_j \le w + x_i$ and $y_j \le w + y_i$, then
$\max(s+x_j, t+y_j) \le w + \max(s+x_i, t+y_i)$).

**Theorem 8.3 (Helly criterion for difference constraints).** *Let $d \ge 1$. A
finite system of difference constraints $x_{t_k} - x_{s_k} \le w_k$
($k=1,\dots,n$) in $d$ variables is feasible if and only if every $d$ of the
constraints are simultaneously feasible.*

*Proof.* Apply Theorem 3.3 to the cones $D(s_k,t_k,w_k)$. $\square$

**Remark 8.4 (Agreement with the negative-cycle criterion).** Difference
constraint systems are exactly single-source shortest-path problems: feasibility
holds iff the digraph on $\{1,\dots,d\}$ with an arc $s_k \to t_k$ of weight
$w_k$ has no negative cycle. A negative cycle can be taken simple, hence uses at
most $d$ arcs, i.e. at most $d$ constraints. Theorem 8.3 reproves this bound
without any graph theory: the Helly number of tropical cones and the length of a
simple cycle are the same $d$, and this is not a coincidence — both express that
max-plus dependence in $\mathbb{R}^d$ occurs already among $d$ objects. The
Bellman–Ford algorithm, which detects a negative cycle in $O(dn)$ time, is thus
an efficient realisation of the Helly certificate in this special case.

### 8.3 Finiteness is essential

**Theorem 8.5 (Failure for infinite families).** *There is a countable family of
tropical cones in $\mathbb{R}^2$ such that every finite subfamily has a common
point but the whole family does not.*

*Proof.* Let $C_k = \{x \in \mathbb{R}^2 : x_1 + k \le x_2\}$ for $k \in
\mathbb{N}$; each is a tropical cone (it is $D(1,2,\cdot)$ up to renaming, or
check directly as in §8.2). Given a finite $F \subseteq \mathbb{N}$, the point
$x = (0, \max F)$ lies in $\bigcap_{k \in F} C_k$. But a point in all $C_k$ would
satisfy $x_2 - x_1 \ge k$ for every $k \in \mathbb{N}$, impossible. $\square$

Classically one restores Helly for infinite families by assuming compactness.
Tropical cones are never compact — they are invariant under the unbounded scaling
action of Lemma 3.1 — so no such repair is available in this setting. Any
infinite-family version of tropical Helly must be phrased on the projective torus
with an additional closedness/boundedness assumption there.

---

## 9. Algorithms

We record the three algorithms implicit in the proofs.

**Algorithm A (Cramer weights and dependence certificate).**
Input $A \in \mathbb{R}^{(d+1)\times d}$. For each $k$, compute
$\lambda_k = \operatorname{tropdet} A^{(\hat k)}$ by solving a $d\times d$
optimal assignment problem. Output $\lambda$ together with, for each coordinate
$i$, the (at least two) maximisers of $\lambda_k + A_{ki}$. Complexity: $O(d^4)$
with the Hungarian algorithm, $O(d \cdot d! \cdot d)$ by brute force.
Correctness: Theorem 2.4.

**Algorithm B (Helly witness / tropical intersection point).** Input: an oracle
producing, for each index $k$, a point $y_k$ in all cones but possibly $C_k$.
Select $d+1$ indices, compute Cramer weights $\lambda$ of the matrix of the
$y_k$, and output $z_i = \max_r (\lambda_r + y_{k_r,i})$. Correctness: the proof
of Theorem 3.3. Recursively unfolding the induction gives a witness for a family
of $n$ cones from $d$-wise witnesses.

**Algorithm C (Principal solution / solvability test).** Input
$A \in \mathbb{R}^{m\times n}$, $b \in \mathbb{R}^m$. Compute
$\hat x_j = \min_i (b_i - A_{ij})$, then $r_i = \max_j (A_{ij} + \hat x_j)$;
report "solvable with greatest solution $\hat x$" if $r = b$, else "unsolvable".
Complexity $O(mn)$. Correctness: Theorem 7.4.

**Algorithm D (Carathéodory reduction).** Input generators $p_k$, $k \in F$, and
weights $\lambda$. For each coordinate $i$ record an argmax $\kappa(i)$; output
$G = \{\kappa(1),\dots,\kappa(d)\}$ and the restricted weights. Complexity
$O(d|F|)$. Correctness: Theorem 5.1.

---

## 10. Applications

**Scheduling and timetables.** Max-plus linear systems $A \otimes x = b$ model
synchronisation: task $i$ starts when all its predecessors $j$ have finished,
$A_{ij}$ being the transfer delay. Corollary 7.5 gives a linear-time answer to
"can the timetable be met exactly?", together with the latest feasible schedule
$A\sharp b$ when the answer is yes, and the best achievable schedule from below
when it is not (Proposition 7.6).

**Infeasibility certificates.** Theorems 8.1 and 8.3 say that infeasible
max-plus systems fail *locally*: there is always a subsystem of size at most the
number of variables that is itself infeasible. This is the structural reason
tropical feasibility admits short refutations, and matches the negative-cycle
certificates familiar from shortest-path algorithms.

**Generator reduction.** Theorem 5.1 shows any point of a tropical cone hull is a
combination of at most $d$ generators, so a redundant generating set can be
pruned pointwise to $d$ elements in $O(d|F|)$ time — useful whenever tropical
polytopes are computed and stored (tropical polytope algorithms, min-plus matrix
factorisation, and piecewise-linear function representation).

**Piecewise-linear function theory.** A max-plus combination
$z_i = \max_k (\lambda_k + p_{ki})$ is precisely a convex piecewise-linear
function of the weights; the Carathéodory bound says the "effective support" of
such a representation in $d$ coordinates is at most $d$, a statement of interest
in the study of ReLU networks, where max-plus hull dimension controls
expressivity.

---

## 11. Discussion

Two themes run through the results.

**Coordinates, not dimensions.** Classical convexity numbers count dimensions:
Carathéodory $d+1$, Helly $d+1$, Radon $d+2$, all inherited from the $d+1$
vertices of a $d$-simplex. Tropical convexity counts *coordinates*: Carathéodory
$d$, Helly $d$, because a max-plus combination is decided coordinatewise, one
witness per coordinate. Theorem 5.1 makes this explicit — its proof is literally
"choose one generator per coordinate". Theorem 3.3 is the same idea run through
Cramer dependence; and Theorem 4.3, where scaling invariance is absent, pays back
exactly the one unit that the homogenisation coordinate costs.

**Ties replace cancellation.** In the absence of additive inverses, the algebraic
notion of "$\sum c_k v_k = 0$" is replaced by "the maximum is attained twice".
Theorem 2.4 shows the classical determinantal machinery survives this
replacement essentially verbatim: the identity "two equal columns $\Rightarrow$
singular" becomes "two equal columns $\Rightarrow$ two optimal assignments", and
the swap of columns becomes the swap of the rows carrying them. Everything else
in the paper — the Helly theorem, its converse, the residuation argument — is
downstream of this single tie.

**Sharpness everywhere.** All three constants ($d$ for cone Helly, $d+1$ for
convex Helly, $d$ for cone Carathéodory) come with explicit extremal families,
and they are strikingly simple: "some other coordinate beats coordinate $k$ by
$1$" for Helly, the tropical unit vectors for Carathéodory. That the extremal
objects are this rigid suggests that the constants are structural rather than
accidental.

---

## 12. Future Directions

**Conjecture 12.1 (Tropical Radon number is $d+1$).** *Any $d+1$ points of
$\mathbb{R}^d$ can be split into two nonempty groups whose tropical cone hulls
intersect.*

The key insight is that a Radon partition is exactly a proper 2-colouring of the
*argmax hypergraph* $\{M_i\}$ of a dependence witness $\lambda$ (edge $M_i$ = set
of rows attaining the maximum in coordinate $i$): the partition works iff every
$M_i$ is bichromatic. The Cramer witness of Theorem 2.4 already forces
$|M_i| \ge 2$, but a hypergraph with $d$ edges of size $\ge 2$ on $d+1$ vertices
can fail property B (a triangle plus isolated vertices), so the conjecture needs
an *optimisation over the whole dependence polytope*
$$\Lambda = \{\lambda : \text{every column maximum is attained twice}\}$$
rather than one point of it. Why now? $\Lambda$ is a nonempty polyhedral complex
by Theorem 2.4, so the question is a concrete finite optimisation over an
explicitly constructed object, and Levi's inequality (Helly $\le$ Radon $-1$) is
already tight at $d$ on the extremal family of Definition 3.5, which is exactly
what a Radon number $d+1$ predicts.

**Conjecture 12.2 (Colourful tropical Helly).** Let $F_1,\dots,F_d$ be finite
families ("colours") of tropical cones in $\mathbb{R}^d$. If every rainbow
selection (one cone from each colour) has a common point, then some single colour
class has a common point. The colourful Carathéodory theorem (Theorem 5.4)
supplies exactly the kind of rainbow selection mechanism such a proof needs.

**Further directions.**

- *Fractional and $(p,q)$ versions.* Fractional Helly theorems and Alon–Kleitman
  $(p,q)$-theorems for tropical cones, with the constant $d$ in place of $d+1$.
- *Infinite families on the torus.* Identify the correct compactness hypothesis
  on $\mathbb{R}^d/\mathbb{R}\mathbf{1}$ under which Theorem 3.3 extends to
  infinite families, repairing Theorem 8.5.
- *Signed and symmetrised tropical settings.* Extend the Cramer dependence
  theorem to the symmetrised max-plus semiring, where a genuine notion of
  "balanced" replaces "attained twice", and ask whether the Helly number changes.
- *Algorithmic Helly.* Turn Algorithm B into a practical algorithm computing a
  point in the intersection of $n$ tropical cones given only $d$-wise oracles,
  and analyse its complexity as a function of $n$ and $d$.
- *Boundary cases with $-\infty$.* All results here are stated over the finite
  part $\mathbb{R}$; allowing $-\infty$ entries (genuinely partial max-plus
  vectors) changes the geometry of the extremal families and the constants
  deserve to be re-examined.

---

## Appendix: worked numerical data

*Cramer dependence.* For $A = \begin{pmatrix} 0&0\\1&3\\4&1\end{pmatrix}$
($3$ points in $\mathbb{R}^2$), the row-deleted tropical determinants are
$\lambda = (7,4,3)$ and the column data $(\text{max}, \#\text{argmax})$ is
$[(7,2),(7,2)]$ — both column maxima attained twice, as Theorem 2.4 predicts.
For $A = \begin{pmatrix}0&0&0\\3&1&4\\1&5&9\\2&6&5\end{pmatrix}$ one gets
$\lambda = (18,15,10,12)$ and $[(18,2),(18,2),(19,2)]$. With only $d$ vectors the
property fails: for $A = \begin{pmatrix}0&0\\1&3\end{pmatrix}$ no weights work at
all, the best attempt $\lambda=(1,0)$ giving $[(1,2),(3,1)]$ — a unique maximiser
in the second column, matching the sharpness statements.

*Helly extremality.* In $\mathbb{R}^3$ the three cones $T_1,T_2,T_3$ of
Definition 3.5 have empty intersection, while any two of them contain, e.g.,
$(0,-1,-1)$ or $(-1,0,-1)$ as appropriate.

*Principal solution.* For
$A = \begin{pmatrix}0&2\\3&1\end{pmatrix}$ and $b = (5,4)$ one gets
$A \sharp b = (1,3)$ and $A \otimes (A\sharp b) = (5,4) = b$: solvable, with
greatest solution $(1,3)$. For $b = (5,10)$ one gets $A\sharp b = (5,3)$ and
$A \otimes (A \sharp b) = (5,8) \ne b$: unsolvable, and $(5,8)$ is the best
achievable target below $b$.
