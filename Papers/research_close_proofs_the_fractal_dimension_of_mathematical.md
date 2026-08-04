# Close Proofs: A Metric and Fractal Dimension for Spaces of Truth, with a Spectral Companion on the Boolean Cube

**Author:** Aristotle
**Date:** 2026-08-03

---

## Abstract

We develop a metric geometry for spaces of truth assignments and compute an
exact fractal dimension for a natural model of mathematical truth. Fixing an
enumeration $\varphi_0,\varphi_1,\dots$ of the statements of a formal
language, a complete truth assignment is an element of the Cantor space
$\mathcal{C} = \{0,1\}^{\mathbb{N}}$, and we equip $\mathcal{C}$ with the
*first-disagreement metric* $d(x,y) = 2^{-\min\{k\,:\,x_k \neq y_k\}}$
(with $d(x,x)=0$). We prove two structural facts: (i) closed balls coincide
exactly with prefix-agreement classes, $d(x,y) \le 2^{-n}$ if and only if
$x$ and $y$ agree on all coordinates below $n$; and (ii) $d$ is an
ultrametric, $d(x,z) \le \max(d(x,y), d(y,z))$. Fact (i) reduces
covering-number geometry to prefix counting and yields the identity
$\dim_B = \lim_n \log_2 N(n)/n$, where $N(n)$ counts admissible length-$n$
prefixes of a theory. For the *paired-dependency theory* — in which every
second statement is logically equivalent to its predecessor, so that
$N(n) = 2^{\lceil n/2\rceil}$ — we obtain the exact value
$$\dim_B = \tfrac12, \qquad 0 < \dim_B < 1,$$
so that the truth set is null in the fair-coin measure yet uncountable: it
is sparse but not negligible.

The second half of the paper measures subsets of Boolean cubes by a
different instrument. On the finite cube $Q_n = \{0,1\}^n$ we study the
signed adjacency operator defined by $A_0 = 0$ and the block recursion
$A_{n+1} = \left(\begin{smallmatrix} A_n & I \\ I & -A_n\end{smallmatrix}\right)$.
We establish additivity and real homogeneity of $A_n$, recall the identity
$A_n^2 = n I$, and construct the two spectral projections explicitly: for
any $r \neq 0$ with $r^2 = n$, the operators
$P_\pm v = \tfrac12(v \pm r^{-1}A_n v)$ satisfy $P_+ + P_- = \mathrm{id}$,
$A_n P_\pm v = \pm r\, P_\pm v$, $P_\pm^2 = P_\pm$, and $P_+P_- = P_-P_+ =
0$. This gives a constructive, coordinate-free eigendecomposition of every
function on the cube, the algebraic engine behind the $\sqrt n$ degree
bound for majorities of cube vertices. We close by exhibiting the bridge
between the two halves: for theories defined by finite-state local
constraints, the fractal dimension of the truth set equals
$\log_2$ of the spectral radius of a transfer matrix, so that the
dimension of truth is itself an eigenvalue.

**Keywords:** first-disagreement metric, ultrametric, Cantor space,
box-counting dimension, entropy rate, prefix counting, Boolean hypercube,
signed adjacency operator, spectral projection, sensitivity conjecture.

---

## 1. Introduction

### 1.1 Motivation

Mathematical practice is full of quantitative intuitions that resist
formalization. We say a conjecture is "close to" a known theorem; that a
theory is "almost" complete; that a family of statements is "essentially
independent". Each of these is a metric or measure-theoretic statement in
disguise. This paper asks what happens if one takes them literally: fix a
distance between mathematical worldviews, and then measure the resulting
geometry.

The distance we adopt is forced on us by the way mathematics is actually
navigated. Two accounts of the mathematical universe are indistinguishable
until they disagree about something, and the effort required to
distinguish them grows with how deep in the enumeration that first
disagreement lies. This yields the *first-disagreement metric*, an old and
well-behaved object in symbolic dynamics and $p$-adic analysis, here
reinterpreted as a metric on theories.

The geometry it produces is *ultrametric*: the strong triangle inequality
holds. Ultrametric spaces are exactly the spaces of hierarchical
classification — taxonomies, phylogenies, $p$-adic numbers, and, as we
argue, families of theories. Once the geometry is in place, dimension is
the natural first invariant, and here it becomes strikingly concrete:
covering the space at resolution $2^{-n}$ is the same as listing admissible
prefixes of length $n$, so dimension equals asymptotic entropy rate.

The second half of the paper is about the *same combinatorial substrate*
— finite Boolean cubes — measured spectrally rather than metrically.
Prefixes of length $n$ are vertices of $Q_n$. The signed adjacency operator
on $Q_n$, with its miraculous identity $A_n^2 = nI$, is the sharpest known
tool for constraining subsets of $Q_n$; it is the engine of the 2019
resolution of the sensitivity conjecture. We give a fully algebraic
construction of its two spectral projections, requiring no inner-product
structure or diagonalization theory: only additivity, homogeneity, and the
square law.

### 1.2 Contributions

1. **A metric characterisation of prefix cylinders.** Closed balls of radius
   $2^{-n}$ in the first-disagreement metric are exactly the classes of
   streams agreeing on the first $n$ coordinates (Theorem 3.1).
2. **The ultrametric inequality** for the first-disagreement metric, derived
   from the transitivity of prefix agreement (Theorem 3.3), with its
   standard consequences: isosceles triangles, centre-free balls, nested-or-
   disjoint balls, clopen balls, total disconnectedness.
3. **An exact fractal dimension for a truth model.** The paired-dependency
   truth set has box-counting dimension exactly $\tfrac12$, hence strictly
   between $0$ and $1$ (Theorem 4.4), with corollaries: measure zero
   (Corollary 4.6) and cardinality continuum (Corollary 4.7).
4. **Linearity of the signed cube operator** — additivity and real
   homogeneity — by induction on the block recursion (Theorem 5.3).
5. **Explicit spectral projections.** For any $r \neq 0$ with $r^2 = n$,
   $P_\pm = \tfrac12(\mathrm{id} \pm r^{-1}A_n)$ are complementary
   idempotents whose images are the $\pm r$ eigenspaces (Theorems 5.6–5.8),
   with the orthogonality relations $P_+P_- = P_-P_+ = 0$ (Corollary 5.9).
6. **The counting/spectral bridge.** For finite-state constrained theories,
   the fractal dimension equals $\log_2$ of the transfer-matrix spectral
   radius (Proposition 6.2), unifying the two halves.

### 1.3 Related context

The first-disagreement metric is the standard metric on shift spaces in
symbolic dynamics, and the identity "topological entropy $=$ box dimension"
for subshifts under this metric is classical folklore; our contribution is
its reinterpretation as a statement about theories, together with an exact,
fully explicit computation for a natural truth model. The signed cube
operator originates in Huang's 2019 proof of the sensitivity conjecture; our
contribution is a self-contained, projection-based development that avoids
appeal to the spectral theorem.

---

## 2. The space of truth assignments

Throughout, $\mathbb{N} = \{0,1,2,\dots\}$ and $\mathbb{B} = \{0,1\}$,
whose elements we also read as $\mathsf{false}$ and $\mathsf{true}$.

**Definition 2.1 (Enumeration).** Fix a formal language with a computable
enumeration $\varphi_0, \varphi_1, \varphi_2, \dots$ of its sentences, each
sentence appearing exactly once.

**Definition 2.2 (Truth stream).** A *truth stream* is a function
$x : \mathbb{N} \to \mathbb{B}$; we write $x_k$ for $x(k)$ and interpret
$x_k = 1$ as "$\varphi_k$ is true". The set of all truth streams is the
Cantor space $\mathcal{C} = \mathbb{B}^{\mathbb{N}}$.

**Definition 2.3 (Theory).** A *theory* is a subset $T \subseteq
\mathcal{C}$: the set of truth streams compatible with some body of
commitments. A theory is *prefix-presented* by the family
$$L_n(T) = \{ (x_0,\dots,x_{n-1}) : x \in T\} \subseteq \mathbb{B}^n$$
of its admissible finite prefixes; we write $N_T(n) = |L_n(T)|$. Note
$L_n(T)$ is automatically *prefix-closed*: every prefix of an admissible
word is admissible.

**Definition 2.4 (Agreement to depth $n$).** For $x,y \in \mathcal{C}$ and
$n \in \mathbb{N}$, write
$$x \equiv_n y \quad :\Longleftrightarrow \quad \forall k < n,\; x_k = y_k .$$

Agreement to depth $n$ is an equivalence relation with exactly $2^n$
classes, each class the *cylinder* determined by a word $w \in
\mathbb{B}^n$:
$$[w] = \{x \in \mathcal{C} : (x_0,\dots,x_{n-1}) = w\}.$$
Agreement is monotone: $x \equiv_{n+1} y$ implies $x \equiv_n y$, and
$x \equiv_0 y$ always holds.

---

## 3. The first-disagreement metric

**Definition 3.0 (First-disagreement metric).** For $x,y \in \mathcal{C}$
set
$$d(x,y) = \begin{cases} 0 & \text{if } x = y,\\ 2^{-m} & \text{where } m = \min\{k \in \mathbb{N} : x_k \neq y_k\} \text{ otherwise.}\end{cases}$$

The minimum exists whenever $x \neq y$ because the set of disagreement
indices is a nonempty subset of $\mathbb{N}$. The range of $d$ is
$\{0\} \cup \{2^{-m} : m \in \mathbb{N}\}$ — a discrete set of values
accumulating only at $0$. That $d$ is a metric (symmetry, positivity,
identity of indiscernibles) is immediate; the triangle inequality follows
from Theorem 3.3 below, which is much stronger.

### 3.1 Balls are prefix classes

**Theorem 3.1 (Metric balls are cylinders).** *For all $x, y \in
\mathcal{C}$ and all $n \in \mathbb{N}$,*
$$d(x,y) \le 2^{-n} \quad\Longleftrightarrow\quad x \equiv_n y .$$

*Proof sketch.* ($\Leftarrow$) Suppose $x \equiv_n y$. If $x = y$ then
$d(x,y) = 0 \le 2^{-n}$. Otherwise let $m$ be the least disagreement index.
Since $x_k = y_k$ for all $k < n$, we have $m \ge n$, and since $t \mapsto
2^{-t}$ is decreasing, $d(x,y) = 2^{-m} \le 2^{-n}$.

($\Rightarrow$) Contrapositive. Suppose $x \not\equiv_n y$, so $x_k \neq
y_k$ for some $k < n$. Then $x \neq y$ and the least disagreement index
satisfies $m \le k \le n-1$, whence $d(x,y) = 2^{-m} \ge 2^{-(n-1)} >
2^{-n}$. $\square$

**Corollary 3.2 (Geometry $=$ combinatorics).** *The closed ball
$\bar B(x, 2^{-n})$ equals the cylinder $[x_0\cdots x_{n-1}]$. Consequently
the collection of closed balls of radius $2^{-n}$ is a partition of
$\mathcal{C}$ into $2^n$ pieces, and a theory $T$ meets exactly $N_T(n)$ of
them.*

This corollary is the hinge of the paper: any covering question at scale
$2^{-n}$ is answered by counting admissible words of length $n$.

### 3.2 The strong triangle inequality

**Theorem 3.3 (Ultrametric inequality).** *For all $x,y,z \in \mathcal{C}$,*
$$d(x,z) \;\le\; \max\bigl(d(x,y),\, d(y,z)\bigr).$$

*Proof sketch.* If $x = z$ the left side is $0$. Otherwise let
$\mu = \max(d(x,y), d(y,z))$. If $\mu = 0$ then $x = y = z$, contradiction;
so $\mu = 2^{-n}$ for some $n \in \mathbb{N}$, since the range of $d$
consists of $0$ and the powers $2^{-n}$. By Theorem 3.1, $d(x,y) \le
2^{-n}$ gives $x \equiv_n y$ and $d(y,z) \le 2^{-n}$ gives $y \equiv_n z$.
Agreement to depth $n$ is transitive, so $x \equiv_n z$, and Theorem 3.1
applied in the reverse direction gives $d(x,z) \le 2^{-n} = \mu$.
$\square$

Note the shape of the argument: the ultrametric inequality is *exactly* the
transitivity of prefix agreement, transported across the equivalence of
Theorem 3.1. Nothing analytic is involved.

**Corollary 3.4 (Ultrametric phenomenology).** *In $(\mathcal{C}, d)$:*

1. *(Isosceles principle)* If $d(x,y) \neq d(y,z)$ then $d(x,z) =
   \max(d(x,y), d(y,z))$. Every triangle has two equal longest sides.
2. *(No centres)* If $y \in \bar B(x,\varepsilon)$ then
   $\bar B(y,\varepsilon) = \bar B(x,\varepsilon)$: every point of a ball
   is a centre of it.
3. *(Nested or disjoint)* Any two closed balls are either disjoint or one
   contains the other; they never partially overlap.
4. *(Clopen balls)* Every closed ball is also open, and $\mathcal{C}$ is
   compact, perfect, and totally disconnected — a Cantor set.

*Proof sketch.* (1) If, say, $d(x,y) < d(y,z)$, then $d(x,z) \le d(y,z)$ by
Theorem 3.3, and $d(y,z) \le \max(d(y,x), d(x,z))$ likewise; since
$d(y,x) < d(y,z)$ the maximum must be $d(x,z)$, so $d(y,z) \le d(x,z)$.
(2)–(3) are immediate from Corollary 3.2, since balls of a fixed radius
partition the space and balls of different radii are cylinders of different
depths, which are nested or disjoint. (4) Compactness is Tychonoff's
theorem for $\mathbb{B}^{\mathbb{N}}$ (or König's lemma on the binary
tree); each cylinder is a finite union of complements of cylinders, hence
clopen; distinct points are separated by some cylinder, giving total
disconnectedness. $\square$

**Interpretation.** Statement (3) is the mathematical content of the
intuition that research programmes *branch*. Two theories that have
diverged at $\varphi_m$ can never again be brought closer than $2^{-m}$,
regardless of how much they subsequently agree; and the family of theories
organizes itself as an infinite binary tree of nested clusters. There is no
"partial overlap" of worldviews at a fixed resolution, only refinement.

---

## 4. Box-counting dimension and the dimension of truth

### 4.1 Dimension via prefix counts

**Definition 4.1 (Box-counting dimension).** For a bounded nonempty
$S \subseteq \mathcal{C}$ let $N_S(\varepsilon)$ be the minimal number of
closed balls of radius $\varepsilon$ needed to cover $S$. The upper and
lower box dimensions are
$$\overline{\dim}_B S = \limsup_{\varepsilon\to 0^+} \frac{\log N_S(\varepsilon)}{\log(1/\varepsilon)}, \qquad \underline{\dim}_B S = \liminf_{\varepsilon\to 0^+}\frac{\log N_S(\varepsilon)}{\log(1/\varepsilon)},$$
and when they coincide the common value is $\dim_B S$.

**Proposition 4.2 (Prefix formula).** *For any theory $T \subseteq
\mathcal{C}$, taking $\varepsilon = 2^{-n}$ suffices (the radii $2^{-n}$
are cofinal in the range of $d$), and the minimal cover at that scale is by
the cylinders $T$ meets. Hence*
$$\overline{\dim}_B T = \limsup_{n\to\infty} \frac{\log_2 N_T(n)}{n}, \qquad \underline{\dim}_B T = \liminf_{n\to\infty} \frac{\log_2 N_T(n)}{n}.$$

*Proof sketch.* By Corollary 3.2, the closed balls of radius $2^{-n}$
partition $\mathcal{C}$ into cylinders; a cover of $T$ by such balls must
include every cylinder $T$ meets, and those cylinders do cover $T$, so
$N_T(2^{-n}) = N_T(n)$ exactly. Since $\log(1/2^{-n}) = n\log 2$, the
displayed quotients are $\log_2 N_T(n)/n$. For intermediate radii
$2^{-(n+1)} < \varepsilon \le 2^{-n}$ the covering number is unchanged, so
no additional limit points arise. $\square$

**Remark 4.3 (Dimension is entropy rate).** Proposition 4.2 identifies
$\dim_B T$ with the base-$2$ entropy rate of the prefix language of $T$: the
average number of independent binary decisions per statement. Dimension $1$
means every statement is free of the others; dimension $0$ means the
information content is sub-exponential (for instance, a categorical theory
with $N_T(n) = 1$). Since $N_T(n) \le 2^n$ always, one has $0 \le \dim_B T
\le 1$ for every theory. Subadditivity of $n \mapsto \log_2 N_T(n)$ for
prefix languages closed under concatenation of admissible blocks makes the
limit exist by Fekete's lemma in the standard cases; for the theories
treated below the limit is computed directly.

### 4.2 The paired-dependency truth model

We now specify the model whose dimension we compute. It formalizes the
simplest nontrivial mixture of independence and entailment.

**Definition 4.4 (Paired-dependency theory).** Suppose the enumeration
interleaves *primitive* statements and their *restatements*: for every
$k$, the sentence $\varphi_{2k+1}$ is logically equivalent to $\varphi_{2k}$
(a corollary, a reformulation, a definitional unfolding), while the
statements $\varphi_0, \varphi_2, \varphi_4, \dots$ are mutually logically
independent. The associated theory is
$$T_{1/2} = \{x \in \mathcal{C} : x_{2k+1} = x_{2k} \text{ for all } k\}.$$

**Lemma 4.5 (Prefix count).** $N_{T_{1/2}}(n) = 2^{\lceil n/2\rceil}$.

*Proof sketch.* A word $w \in \mathbb{B}^n$ is admissible iff
$w_{2k+1} = w_{2k}$ for every $k$ with $2k+1 < n$. Thus the free
coordinates are precisely the even ones below $n$, of which there are
$\lceil n/2 \rceil$, and every assignment of the free coordinates extends
uniquely. Both $2 \mid n$ and $2 \nmid n$ are covered by the ceiling.
$\square$

**Theorem 4.6 (Truth has a nontrivial fractal dimension).** *The
paired-dependency truth set satisfies*
$$\dim_B T_{1/2} = \tfrac12, \qquad\text{and in particular}\qquad 0 < \dim_B T_{1/2} < 1 .$$

*Proof sketch.* By Lemma 4.5 and Proposition 4.2,
$$\frac{\log_2 N_{T_{1/2}}(n)}{n} = \frac{\lceil n/2\rceil}{n} \in \left[\frac12, \frac12 + \frac{1}{2n}\right],$$
and the squeeze gives the limit $\tfrac12$. The strict inequalities
$0 < \tfrac12 < 1$ are numerical. $\square$

### 4.3 Consequences: sparse but not negligible

**Corollary 4.7 (Sparsity).** *$T_{1/2}$ is a null set for the fair-coin
(uniform Bernoulli) measure $\mu$ on $\mathcal{C}$; a truth assignment
generated by independent fair coin flips fails to be admissible with
probability $1$.*

*Proof sketch.* $\mu([w]) = 2^{-n}$ for every $w \in \mathbb{B}^n$, so
$\mu(T_{1/2}) \le N_{T_{1/2}}(n)\, 2^{-n} = 2^{\lceil n/2\rceil - n} \to 0$.
More generally, any theory with $\overline{\dim}_B T < 1$ is $\mu$-null by
the same covering estimate, since $N_T(n) 2^{-n} = 2^{n(\log_2 N_T(n)/n -
1)} \to 0$ exponentially. $\square$

**Corollary 4.8 (Abundance).** *$T_{1/2}$ has cardinality $2^{\aleph_0}$
and is homeomorphic to $\mathcal{C}$ itself; in particular it is
uncountable, compact, and perfect.*

*Proof sketch.* The map $\mathcal{C}\to T_{1/2}$ doubling every coordinate,
$(a_0,a_1,a_2,\dots) \mapsto (a_0,a_0,a_1,a_1,a_2,a_2,\dots)$, is a
bijection onto $T_{1/2}$, and it is a metric similarity of ratio $2^{-1}$
in the sense that $d(\Phi a, \Phi b) \in \{2^{-2m}, 2^{-2m-1}\}$ whenever
$d(a,b) = 2^{-m}$; in particular it is a homeomorphism onto its image.
Positive box dimension alone already forces uncountability, since countable
compact sets have box dimension $0$. $\square$

**Remark 4.9 (Reading the two inequalities).** $\dim_B < 1$ says that truth
is *rare*: the admissible streams occupy an exponentially shrinking
fraction of all streams, and no amount of random guessing produces a
consistent theory. $\dim_B > 0$ says truth is *not negligible*: there are
continuum-many complete admissible extensions, and no finite or countable
list captures them. The interplay is a geometric shadow of incompleteness
phenomena: positivity of dimension is precisely the statement that
independent decisions keep arriving, forever, at a positive asymptotic
rate.

**Remark 4.10 (Robustness).** Nothing depends on the residue pattern
"evens free, odds forced". If $R \subseteq \{0,1,\dots,m-1\}$ is a set of
residues and $T_R$ is the theory in which coordinates in residue classes
$R$ modulo $m$ are free while all others are determined by earlier
coordinates, the same argument gives $N_{T_R}(n) = 2^{|R|\,n/m + O(1)}$ and
$$\dim_B T_R = \frac{|R|}{m},$$
so every rational value in $[0,1]$ is realised. Dimension $\tfrac12$ is the
case $m = 2$, $R = \{0\}$: exactly half of mathematics is discovery, half
is bookkeeping.

---

## 5. The signed Boolean cube and its spectral projections

We now change instruments. Prefixes of length $n$ are the vertices of the
$n$-cube $Q_n = \mathbb{B}^n$; instead of counting them asymptotically, we
measure subsets of a *fixed* cube spectrally.

**Definition 5.1 (Cube and cube functions).** $Q_0$ is the one-point set
containing the empty word; $Q_{n+1} = \{b x : b \in \mathbb{B},\, x \in
Q_n\}$. A *cube function* is a map $v : Q_n \to \mathbb{R}$. For
$v : Q_{n+1}\to\mathbb{R}$ and $b\in\mathbb{B}$ write $v_b : Q_n \to
\mathbb{R}$, $v_b(x) = v(bx)$, for the restriction to a facet.

**Definition 5.2 (Signed adjacency operator).** Define $A_n$ on cube
functions recursively by $A_0 v = 0$ and
$$(A_{n+1}v)(0x) = (A_n v_0)(x) + v_1(x), \qquad (A_{n+1}v)(1x) = v_0(x) - (A_n v_1)(x).$$
Equivalently, in block-matrix form with the facets ordered $0\ast$ then
$1\ast$,
$$A_{n+1} = \begin{pmatrix} A_n & I_{2^n} \\ I_{2^n} & -A_n\end{pmatrix}, \qquad A_1 = \begin{pmatrix}0&1\\1&0\end{pmatrix}.$$

Replacing the entry $-A_n$ by $+A_n$ recovers the ordinary adjacency
operator of the hypercube graph, whose spectrum is
$\{n-2i : 0 \le i \le n\}$, spread across $n+1$ values. The single sign
change collapses the spectrum to two values, as we now show.

### 5.1 Linearity

**Theorem 5.3 (Additivity and homogeneity).** *For all $n$, all cube
functions $v,w : Q_n \to \mathbb{R}$, and all $c \in \mathbb{R}$,*
$$A_n(v + w) = A_n v + A_n w, \qquad A_n(c\,v) = c\,A_n v .$$

*Proof sketch.* Induction on $n$. For $n = 0$ both sides vanish. For the
step, evaluate at a vertex $bx$ and split on $b$. For $b = 0$:
$$(A_{n+1}(v+w))(0x) = \bigl(A_n (v+w)_0\bigr)(x) + (v+w)_1(x) = \bigl(A_n(v_0+w_0)\bigr)(x) + v_1(x)+w_1(x),$$
using $(v+w)_b = v_b + w_b$ (restriction is pointwise), and the inductive
hypothesis rewrites the first term as $(A_nv_0)(x) + (A_nw_0)(x)$;
regrouping gives $(A_{n+1}v)(0x) + (A_{n+1}w)(0x)$. The case $b=1$ is
identical up to the sign on the $A_n$ term. Homogeneity is the same
induction with $(c v)_b = c\,v_b$ and the distributive laws $c(a+b) = ca+cb$
and $c(a-b) = ca - cb$. $\square$

**Corollary 5.4 (Negation and zero).** $A_n 0 = 0$ and $A_n(-v) = -A_n v$.

*Proof sketch.* $A_n 0 = A_n(0\cdot 0) = 0$; and from
$A_n(v) + A_n(-v) = A_n(v + (-v)) = A_n 0 = 0$ we get $A_n(-v) = -A_nv$.
$\square$

### 5.2 The square law

**Theorem 5.5 (Square of the signed operator).** *For every $n$,
$A_n^2 = n\,\mathrm{id}$, i.e. $A_n(A_n v) = n\,v$ pointwise.*

*Proof sketch.* Induction on $n$, in block form. $A_0^2 = 0 = 0\cdot I$.
Assuming $A_n^2 = nI$,
$$A_{n+1}^2 = \begin{pmatrix} A_n & I \\ I & -A_n\end{pmatrix}^2 = \begin{pmatrix} A_n^2 + I & A_n - A_n \\ A_n - A_n & I + A_n^2\end{pmatrix} = \begin{pmatrix} (n+1)I & 0 \\ 0 & (n+1)I\end{pmatrix},$$
using that the off-diagonal blocks cancel identically. $\square$

Two consequences are immediate: the only possible eigenvalues of $A_n$ are
$\pm\sqrt n$, and $A_n$ is invertible for $n \ge 1$ with $A_n^{-1} =
n^{-1}A_n$. What Theorem 5.5 does not yet supply is the decomposition
itself; that is the content of the next results, which are constructive.

### 5.3 Explicit spectral projections

**Definition 5.6 (Spectral parts).** Let $n \ge 1$ and let $r \in
\mathbb{R}$ satisfy $r \neq 0$ and $r^2 = n$ (so $r = \pm\sqrt n$). For a
cube function $v : Q_n \to \mathbb{R}$ define the *positive* and *negative
spectral parts*
$$P_+^{(r)} v = \tfrac12\bigl(v + r^{-1}A_n v\bigr), \qquad P_-^{(r)} v = \tfrac12\bigl(v - r^{-1}A_n v\bigr),$$
pointwise: $(P_\pm^{(r)}v)(x) = \bigl(v(x) \pm r^{-1}(A_nv)(x)\bigr)/2$.

**Theorem 5.7 (Reconstruction).** *For every cube function $v$,*
$$P_+^{(r)} v + P_-^{(r)} v = v .$$

*Proof sketch.* Pointwise, $\tfrac12(a + t) + \tfrac12(a - t) = a$ with
$a = v(x)$ and $t = r^{-1}(A_nv)(x)$. $\square$

**Theorem 5.8 (Eigenfunction property).** *Let $r \neq 0$, $r^2 = n$. Then
for every cube function $v$,*
$$A_n\bigl(P_+^{(r)}v\bigr) = r\,P_+^{(r)}v, \qquad A_n\bigl(P_-^{(r)}v\bigr) = -r\,P_-^{(r)}v .$$

*Proof sketch.* Write $P_\pm^{(r)}v = \tfrac12\bigl(v \pm r^{-1}A_nv\bigr)$
and apply $A_n$, using additivity and homogeneity (Theorem 5.3) and
Corollary 5.4 for the negative case:
$$A_n\bigl(P_\pm^{(r)}v\bigr) = \tfrac12\bigl(A_n v \pm r^{-1}A_n(A_nv)\bigr) = \tfrac12\bigl(A_nv \pm r^{-1}\,n\,v\bigr)$$
by the square law. Since $r^2 = n$ and $r \neq 0$ we have $r^{-1}n = r^{-1}r^2 = r$, so the right-hand side equals
$$\tfrac12\bigl(A_n v \pm r\,v\bigr) = \pm r\cdot\tfrac12\bigl(v \pm r^{-1}A_nv\bigr) = \pm r\,P_\pm^{(r)}v ,$$
where the middle equality is checked by expanding the right-hand side:
$\pm r\cdot\tfrac12\bigl(v \pm r^{-1}A_nv\bigr) = \tfrac12\bigl(\pm r\,v + r\,r^{-1}A_nv\bigr) = \tfrac12\bigl(A_nv \pm r\,v\bigr)$.
$\square$

**Corollary 5.9 (Complementary idempotents).** *For $n \ge 1$ and $r\neq0$
with $r^2=n$, the operators $P_\pm^{(r)}$ are linear, satisfy*
$$\bigl(P_\pm^{(r)}\bigr)^2 = P_\pm^{(r)}, \qquad P_+^{(r)}P_-^{(r)} = P_-^{(r)}P_+^{(r)} = 0, \qquad P_+^{(r)} + P_-^{(r)} = \mathrm{id},$$
*so the space of cube functions is the internal direct sum of the
eigenspaces $E_{+r} = \operatorname{im} P_+^{(r)}$ and $E_{-r} =
\operatorname{im}P_-^{(r)}$.*

*Proof sketch.* Linearity of $P_\pm^{(r)}$ is inherited from $A_n$
(Theorem 5.3). For idempotence, apply $P_+^{(r)}$ to $u = P_+^{(r)}v$: by
Theorem 5.8, $A_n u = r u$, so
$P_+^{(r)}u = \tfrac12(u + r^{-1}\cdot r u) = u$. Similarly
$P_-^{(r)}u = \tfrac12(u - r^{-1}\cdot ru) = 0$, which is the vanishing of
the mixed composite; the symmetric computation handles the other order.
Directness of the sum follows: if $u \in E_{+r}\cap E_{-r}$ then
$ru = A_nu = -ru$, so $2ru = 0$ and $u = 0$ as $r \neq 0$. $\square$

**Proposition 5.10 (Equal multiplicities).** *For $n \ge 1$,
$\dim E_{+r} = \dim E_{-r} = 2^{n-1}$.*

*Proof sketch.* The diagonal entries of $A_n$ are all zero — the recursion
never places a value at the vertex it is evaluated at — so
$\operatorname{tr} A_n = 0$. On the other hand $A_n$ acts as $r$ on
$E_{+r}$ and $-r$ on $E_{-r}$, and by Corollary 5.9 these exhaust the
$2^n$-dimensional space, so $0 = r\dim E_{+r} - r \dim E_{-r}$; with
$r \neq 0$ and $\dim E_{+r} + \dim E_{-r} = 2^n$ the claim follows.
$\square$

### 5.4 Why the halving matters

**Theorem 5.11 (Degree bound for majorities; Huang).** *Let
$S \subseteq Q_n$ with $|S| \ge 2^{n-1}+1$. Then the induced subgraph of the
hypercube on $S$ has maximum degree at least $\sqrt n$.*

*Proof sketch (context).* By Proposition 5.10, $E_{+\sqrt n}$ has dimension
$2^{n-1}$; the space of functions supported on $S$ has dimension $|S| \ge
2^{n-1}+1$; two subspaces of $\mathbb{R}^{Q_n}$ of dimensions summing to
more than $2^n$ intersect nontrivially, so there is a nonzero
$+\sqrt n$-eigenfunction of $A_n$ supported on $S$. Cauchy interlacing (or
a direct Rayleigh-quotient estimate) then gives that the principal
submatrix $A_n[S]$ has largest eigenvalue at least $\sqrt n$, and the
largest eigenvalue of a symmetric $\pm1$-signed adjacency matrix is at most
the maximum degree of the underlying graph. Hence some vertex of $S$ has at
least $\sqrt n$ neighbours in $S$. $\square$

Theorem 5.11, combined with the Gotsman–Linial equivalence, resolves the
sensitivity conjecture: the sensitivity of a Boolean function is at least
the square root of its degree, hence polynomially related to block
sensitivity, certificate complexity, decision-tree depth, and the other
standard measures. The explicit projections of Definition 5.6 make the
witnessing eigenfunction *computable*: to produce a $+\sqrt n$
eigenfunction one need only apply $P_+^{(\sqrt n)}$ to any function not
annihilated by it, at a cost of one application of $A_n$.

---

## 6. The bridge: counting is spectral

The two halves of this paper measure Boolean cubes in apparently unrelated
ways. They are, in fact, two views of the same computation.

**Definition 6.1 (Finite-state theory).** A theory $T$ is *finite-state* if
its admissible prefixes are the label sequences of walks in a finite
directed graph $G$ with edges labelled by bits, in such a way that each
admissible word corresponds to at least one walk from a distinguished start
state. Write $M$ for the (nonnegative integer) adjacency matrix of $G$ and
$\rho(M)$ for its spectral radius.

**Proposition 6.2 (Dimension is a spectral radius).** *For a nonempty
finite-state theory $T$ presented by a primitive matrix $M$,*
$$\dim_B T = \frac{\log \rho(M)}{\log 2} = \log_2 \rho(M).$$

*Proof sketch.* The number of walks of length $n$ from the start state is
the corresponding row sum of $M^n$; by Perron–Frobenius, for primitive $M$
this grows like $c\,\rho(M)^n$ with $c > 0$. Hence $N_T(n) =
\Theta(\rho(M)^n)$ and $\log_2 N_T(n)/n \to \log_2\rho(M)$ by Proposition
4.2. $\square$

**Example 6.3 (The golden-mean theory).** Let $T_\varphi$ be the theory in
which no two consecutive statements are simultaneously true — the crudest
possible consistency taboo, forbidding a sentence and its immediate
successor from both holding. Its transfer matrix is
$M = \left(\begin{smallmatrix}1&1\\1&0\end{smallmatrix}\right)$, whose
spectral radius is the golden ratio $\varphi = (1+\sqrt5)/2$. Prefix counts
obey the Fibonacci recurrence $N(n) = N(n-1)+N(n-2)$ with $N(0)=1$,
$N(1) = 2$, and Proposition 6.2 gives
$$\dim_B T_\varphi = \log_2 \frac{1+\sqrt 5}{2} \approx 0.694242,$$
again strictly between $0$ and $1$.

**Example 6.4 (Paired dependency, revisited).** $T_{1/2}$ is presented by an
alternating pair of transfer steps — a *free* step, which doubles the number
of admissible words, followed by a *forced* step, which preserves it. The
product of the two step matrices has spectral radius $2$, so the per-step
growth rate is $\sqrt2$ and the dimension is $\log_2\sqrt 2 = \tfrac12$, in
agreement with Theorem 4.6. (This is the periodic, rather than stationary,
version of Proposition 6.2: for a period-$m$ presentation the dimension is
$\log_2\rho(M_{m-1}\cdots M_0)/m$.)

Thus the fractal dimension of a locally constrained truth set *is* the
logarithm of an eigenvalue, and in particular is always the base-$2$
logarithm of an algebraic number. The metric side of the paper measures
subsets of $Q_n$ by asymptotic counting; the spectral side measures them by
eigenvalues of a structured operator; Proposition 6.2 shows the first is a
limit of the second.

---

## 7. Algorithms

Three computational primitives suffice to make everything above
executable.

**Algorithm A (Metric evaluation and ball membership).** Given two truth
streams presented as oracles and a depth budget $D$, scan $k = 0,1,\dots,D$
until $x_k \neq y_k$; return $2^{-k}$ at the first disagreement and
"$\le 2^{-D}$" otherwise. By Theorem 3.1 the same scan decides ball
membership: $y \in \bar B(x,2^{-n})$ iff no disagreement occurs below $n$.
Cost: $O(\min(m, D))$ oracle calls where $m$ is the first disagreement
index. Testing the ultrametric inequality on a triple costs three such
scans.

**Algorithm B (Prefix counting and dimension estimation).** Given a
decidable admissibility predicate on finite words, enumerate the
prefix-closed language level by level: maintain the list $L_n$ of
admissible words of length $n$, and form $L_{n+1}$ by appending each bit to
each element of $L_n$ and filtering. Then $N(n) = |L_n|$ and the dimension
estimate is $\log_2 N(n)/n$. Cost: $O(\sum_{k\le n} N(k))$ predicate calls;
for a finite-state theory this is replaced by matrix powering,
$N(n) = \mathbf{e}_{\mathrm{start}}^{\!\top} M^n \mathbf{1}$, computable in
$O(s^3\log n)$ operations for $s$ states — and asymptotically by the single
number $\log_2\rho(M)$.

**Algorithm C (Signed operator and spectral splitting).** Represent a cube
function as an array of $2^n$ reals indexed by vertex bitmask. Compute
$A_nv$ by the recursion of Definition 5.2, splitting the array into halves,
recursing on each, and combining as $(\text{low}', \text{high}) \mapsto
\text{low}' + \text{high}$ and $(\text{low}, \text{high}') \mapsto
\text{low} - \text{high}'$. Cost: $T(2^n) = 2T(2^{n-1}) + O(2^n)$, i.e.
$O(n2^n)$ — a butterfly, exactly the shape of a fast Walsh–Hadamard
transform. Then $P_\pm v = (v \pm r^{-1}A_nv)/2$ with $r = \sqrt n$, and the
verifications $P_+v + P_-v = v$, $A_nP_\pm v = \pm rP_\pm v$, and
$A_n(A_nv) = nv$ all cost $O(n2^n)$.

---

## 8. Discussion

### 8.1 What "dimension of truth" does and does not say

The theorems here are about a *model*: an enumeration together with a
specification of which prefix patterns are admissible. The number $\tfrac12$
is not an absolute constant of mathematics; it is the entropy rate of a
particular, deliberately simple dependency structure — one restatement per
primitive assertion. What is model-independent is the *framework*: every
prefix-presented theory has a well-defined upper and lower dimension in
$[0,1]$; dimension $1$ characterises asymptotic logical independence;
dimension $0$ characterises subexponential prefix growth; and everything
strictly in between is the fractal regime, where truth is null yet
uncountable.

The philosophical reading should therefore be cautious but is genuinely
suggestive. Sparsity ($\dim < 1$) formalizes "most conceivable worlds are
inconsistent". Positivity ($\dim > 0$) formalizes "no finite description
exhausts truth" — the existence of a positive asymptotic rate of genuinely
new decisions. Where a real formal system sits between these poles is an
empirical question about its dependency structure, and Proposition 6.2 says
that for any finitely presentable dependency structure the answer is
computable.

### 8.2 Why ultrametricity is the right ambient geometry

An objection to metrizing theory space is that any metric seems arbitrary.
The reply is that the first-disagreement metric is not chosen but *derived*:
it is the unique (up to bi-Lipschitz equivalence and reparametrization of
the radius scale) metric whose balls are the prefix classes, and the prefix
classes are precisely the sets distinguishable by a finite amount of
inspection. Ultrametricity is then not an extra assumption but a theorem
(Theorem 3.3), and its consequences — hierarchical clustering, isosceles
triangles, nested-or-disjoint balls — match the phenomenology of
theory-branching.

### 8.3 The two rulers compared

It is worth stating plainly what the spectral half adds. Box dimension is
an *asymptotic, cardinality-based* invariant: it sees only how many
vertices of $Q_n$ survive, in the exponential limit. The signed operator
gives *finite-$n$, structural* information: it constrains not how many
vertices a set has but how they are arranged, forcing local density
$\sqrt n$ on any majority. A set of $2^{n-1}+1$ vertices has counting
dimension $1$ in the limit, so the metric ruler is blind to Theorem 5.11
entirely. Conversely, the spectral ruler says nothing about a set of
$2^{n/2}$ vertices, which is invisible to the interlacing argument. The two
are complementary, and Proposition 6.2 shows the point at which they touch:
finite-state constraints, where the counting invariant is the logarithm of
a spectral one.

### 8.4 Sharpness

The value $\tfrac12$ in Theorem 4.6 is exact, not an estimate; the bounds
in the proof pinch to within $1/(2n)$ at every finite $n$, so the
convergence is $O(1/n)$ and the finite-$n$ estimates $\log_2N(n)/n$ overshoot
by at most one part in $2n$. The exponent $\sqrt n$ in Theorem 5.11 is
sharp: there are subsets of $Q_n$ of size $2^{n-1}+1$ whose induced maximum
degree is exactly $\lceil \sqrt n\rceil$. And the eigenvalue structure of
$A_n$ is as rigid as possible — two eigenvalues, equal multiplicities,
explicit projections.

---

## 9. Future directions

The formal bridge between the metric and counting descriptions suggests
several concrete conjectures.

1. **Periodic-coordinate dimension formula.** For every $m > 0$ and every
   set of residues $R \subseteq \{0,1,\dots,m-1\}$, the subset of Cantor
   streams whose coordinates outside $R$ (modulo $m$) are fixed has
   Hausdorff dimension $|R|/m$ in the first-disagreement metric.
2. **Hausdorff/box agreement for periodic truth sets.** For every
   periodic-coordinate theory, its Hausdorff dimension in the
   first-disagreement metric equals the box dimension of its finite-prefix
   family.
3. **Bi-Lipschitz invariance under bounded coordinate permutations.** If a
   permutation $\sigma$ of $\mathbb{N}$ has bounded displacement — there is
   a constant $C$ with $|\sigma(n) - n| \le C$ for all $n$ — then
   precomposition by $\sigma$ preserves the box dimension of every
   prefix-closed theory. (Equivalently: reordering the enumeration of
   statements by a bounded amount does not change the dimension of truth.)
4. **Finite-state truth dimensions are algebraic.** For every nonempty
   binary subshift presented by a finite directed graph with adjacency
   matrix $A$, the prefix box dimension equals
   $\log(\rho(A))/\log 2$, and is therefore the base-two logarithm of an
   algebraic number.
5. **Golden-mean truth set.** The set of Boolean streams with no two
   consecutive true values has Hausdorff and box dimension
   $\log_2\bigl((1+\sqrt5)/2\bigr)$, strictly between $0$ and $1$.

On the spectral side, natural next steps are: an explicit description of a
basis of $E_{+\sqrt n}$ obtained by applying $P_+$ to the standard vertex
indicators; quantitative refinements of Theorem 5.11 for sets of size
$(1-\delta)2^{n-1}$; and signed operators on products of larger alphabets,
where one asks for the analogue of $A^2 = nI$ and its consequences for
sensitivity-type measures of non-Boolean functions.

---

## 10. Conclusion

Fix an enumeration of statements, declare two theories close when they
agree deep into that enumeration, and a rigid geometry appears
unbidden: closed balls are prefix classes, the strong triangle inequality
holds, and the space is a compact ultrametric Cantor set in which theories
cluster hierarchically and never partially overlap. In that geometry the
box dimension of a theory is precisely the entropy rate of its prefix
language, and for a truth model with one restatement per primitive
assertion the dimension is exactly $\tfrac12$ — strictly between the
zero-dimensional extreme of a categorical theory and the full-dimensional
extreme of total logical anarchy. Truth so modelled is a fractal dust:
measure zero under fair coin flips, yet of cardinality continuum.

The vertices being counted are the vertices of Boolean cubes, and those
cubes admit a second, sharper instrument. Placing minus signs on half the
edges according to the recursion
$A_{n+1} = \left(\begin{smallmatrix}A_n & I\\ I& -A_n\end{smallmatrix}\right)$
produces an operator with $A_n^2 = nI$ and, as constructed here, explicit
complementary projections $P_\pm = \tfrac12(\mathrm{id} \pm r^{-1}A_n)$ onto
its two eigenspaces, each of dimension exactly $2^{n-1}$. That exact
halving is what forbids any majority of cube vertices from being locally
sparse, and it is the algebraic core of the resolution of the sensitivity
conjecture.

Counting and spectra converge: for locally constrained theories the
dimension of truth is the logarithm of a spectral radius. Whether one is
weighing coastlines, theories, or Boolean functions, the lesson is the
same — the right ruler turns a qualitative feeling of abundance into a
number.
