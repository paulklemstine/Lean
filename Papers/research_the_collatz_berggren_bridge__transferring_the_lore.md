# The Collatz–Berggren Bridge: Why the Lorentz Invariant Does Not Transfer, and What Does

**Author:** Aristotle
**Date:** 2026-09-14

---

## Abstract

The Berggren tree of primitive Pythagorean triples and the inverse Syracuse
(odd-to-odd Collatz) tree are both commonly described as *ternary* trees. The
Berggren tree is completely understood: its three generating matrices are
isometries of the Minkowski–Lorentz form $Q(a,b,c) = a^2+b^2-c^2$, every node of
the tree is a null vector of $Q$, and its Pell spine grows by the silver ratio
squared $(1+\sqrt{2})^2 = 3+2\sqrt 2$. The inverse Collatz tree carries no known
invariant. This suggests a research hypothesis of considerable ambition: that the
two trees are two realizations of a single ternary dynamics, so that the Lorentz
invariant and the silver growth exponent could be transported onto the Collatz
tree, supplying the $3n+1$ problem with the conserved quantity it lacks.

We prove that this hypothesis is **false**, and we prove it four independent
times. (1) *Cardinality*: the inverse Collatz tree is not ternary at any node —
a node divisible by $3$ has no predecessors, and every other odd node has
infinitely many; consequently no branching bijection onto the Berggren children
can exist. (2) *Loops*: the Collatz predecessor graph has a self-loop at $1$
while every Berggren step strictly increases the hypotenuse, so no
edge-preserving embedding exists in the reverse direction either. (3)
*Invariants*: every polynomial over $\mathbb{Q}$ conserved along Collatz
predecessor edges is constant, while the Lorentz form is conserved and
nonconstant on the Berggren side. (4) *Rank*: every live Collatz fibre is exactly
the forward orbit of the *single* affine map $L(x) = 4x+1$, a rank-one comb,
versus the Berggren rank-three alphabet.

We then isolate precisely what does survive. First, a **word identity**
$2^{S}n = 3^{L}m + w(\mathbf{k})$ for Syracuse paths, which exhibits the exact
point of failure: the Berggren letters act linearly, the Syracuse letters act
affinely, and the affine cocycle $w$ is the defect. Two-sided bounds
$3^L \le 3w(\mathbf{k})$ and $2^L w(\mathbf{k}) \le 3^L 2^S$ combine with the
cycle equation $m(2^S-3^L) = w(\mathbf{k})$ to force any cycle satisfying
$2\cdot 3^L\le 2^S$ to obey $m \le 2(3/2)^L$, pinning hypothetical cycles to the
critical line $S = L\log_2 3$. Second, a **positive transfer**: the free ternary
tree on three letters embeds into the inverse Collatz tree as an explicit
subtree of live, strictly increasing nodes. Shape transfers; invariant does not.
Finally, we show that invariant-failure is a statement about branching *rank*
rather than about the arithmetic of $3n+1$: for every affine map $x\mapsto ax+b$
with $a\ge 2$, a polynomial constant on one orbit is constant.

**Keywords:** Collatz conjecture, Syracuse map, Berggren tree, Pythagorean
triples, Lorentz form, silver ratio, affine cocycle, branching rank, polynomial
rigidity.

---

## 1. Introduction

### 1.1 Two trees

Let $\mathcal{P}$ denote the set of primitive Pythagorean triples: triples
$(a,b,c)$ of positive integers with $a^2+b^2=c^2$ and $\gcd(a,b,c)=1$. It is a
classical fact (Berggren 1934; rediscovered by Barning and by Hall) that
$\mathcal{P}$ is the node set of an infinite ternary tree rooted at $(3,4,5)$,
whose three edges are given by left multiplication by the matrices

$$A = \begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},
\qquad
B = \begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},
\qquad
C = \begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}.$$

Explicitly, writing a triple as $(a,b,c)$,

$$A\cdot(a,b,c) = (a-2b+2c,\; 2a-b+2c,\; 2a-2b+3c),$$
$$B\cdot(a,b,c) = (a+2b+2c,\; 2a+b+2c,\; 2a+2b+3c),$$
$$C\cdot(a,b,c) = (-a+2b+2c,\; -2a+b+2c,\; -2a+2b+3c).$$

The structural engine of this tree is the **Lorentz form**
$Q(a,b,c) = a^2+b^2-c^2$: each of $A$, $B$, $C$ lies in the integral orthogonal
group $O(2,1;\mathbb{Z})$ of $Q$, so the condition "$(a,b,c)$ is Pythagorean" —
i.e. $Q = 0$ — propagates automatically down the tree.

Now let $\mathrm{Odd}$ denote the odd positive integers and let
$T : \mathrm{Odd}\to\mathrm{Odd}$ be the **Syracuse map**: $T(n)$ is the odd part
of $3n+1$. The Collatz conjecture is the assertion that every $n\in\mathrm{Odd}$
has $T^{(j)}(n) = 1$ for some $j$. Reversing $T$ gives the *inverse Collatz
tree*, and folklore describes it as ternary: on average a node has "about three"
preimages.

The superficial resemblance is striking, and it motivates the following
hypothesis.

> **Transfer Hypothesis.** The Berggren tree and the inverse Collatz tree are two
> realizations of the same ternary dynamics. Consequently the Lorentz invariant
> and the silver growth exponent of the Berggren tree can be transported to the
> inverse Collatz tree, endowing the $3n+1$ problem with a conserved quantity and
> an exact growth bound.

This paper refutes the Transfer Hypothesis and replaces it with an exact
description of the relationship between the two structures.

### 1.2 Summary of results

The main negative results are Theorems 3.4 (no branching bijection), 3.6 (no
reverse embedding), 4.1 (polynomial rigidity) and 5.5 (rank one versus rank
three). The main positive results are Theorem 5.2 (exact fibre structure),
Theorem 6.1 (word identity) with its cycle corollaries 6.4–6.7, and Theorem 7.5
(ternary subtree embedding). Theorem 8.2 abstracts the rigidity phenomenon away
from $3n+1$ entirely.

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0,1,2,\dots\}$ and "odd" means odd positive integer.

**Definition 2.1 (Syracuse predecessor).** For $m,n \in \mathbb{N}$ we say $m$ is
a *Syracuse predecessor* of $n$, written $m \to n$, if $n$ is odd and there
exists $k \ge 1$ with
$$3m+1 = 2^{k} n.$$
Because $n$ is odd, such a $k$ is unique — it is the $2$-adic valuation of
$3m+1$ — so the relation $m\to n$ says exactly that one Syracuse step carries $m$
to $n$. We write $\mathrm{Pred}(n) = \{m : m\to n\}$ for the *fibre* over $n$.

**Lemma 2.2.** If $m\to n$ then $m$ is odd.

*Proof.* Write $3m+1 = 2^{k}n$ with $k\ge 1$; then $2 \mid 3m+1$. If $m$ were
even, $3m+1$ would be odd. $\square$

So the inverse tree lives entirely on odd numbers, as it should.

**Definition 2.3 (live and dead nodes).** An odd $n$ is *live* if $3\nmid n$ and
*dead* if $3\mid n$.

**Definition 2.4 (Berggren step, children, cone).** Let
$\mathcal{S} = \{A,B,C\}$ be the Berggren alphabet acting on $\mathbb{Z}^3$ as
above. For $t\in\mathbb{Z}^3$ the *Berggren children* of $t$ are
$$\mathrm{Ch}(t) = \{A\cdot t,\; B\cdot t,\; C\cdot t\}.$$
The *positive cone* is
$$\mathcal{C} = \{(a,b,c) : 0 < a,\; 0 < b,\; a < c,\; b < c\},$$
which contains $(3,4,5)$.

**Definition 2.5 (Lorentz form).** $Q(a,b,c) = a^2+b^2-c^2$.

**Definition 2.6 (Syracuse word and weight).** A *Syracuse chain* from $m$ to $n$
with word $\mathbf{k} = (k_1,\dots,k_L)$, $k_i \ge 1$, is a sequence
$m = x_0, x_1, \dots, x_L = n$ with $3x_{i-1} + 1 = 2^{k_i} x_i$ for each $i$. We
write $L = |\mathbf{k}|$ for its length and $S = \sum_i k_i$ for its *halving
budget*. The *weight cocycle* is defined recursively by
$$w(\,) = 0, \qquad w(k \,\|\, \mathbf{k}') = 3^{|\mathbf{k}'|} + 2^{k}\,w(\mathbf{k}'),$$
where $k\,\|\,\mathbf{k}'$ denotes prepending the letter $k$.

For example $w(2) = 1$, $w(1,1) = 3 + 2 = 5$, $w(1,2,1) = 9 + 2(3 + 4) = 23$.

---

## 3. The branching obstruction

### 3.1 Dead nodes have no predecessors

**Theorem 3.1 (Dead nodes).** If $3 \mid n$ then $\mathrm{Pred}(n) = \varnothing$.

*Proof.* Suppose $3m+1 = 2^{k}n$ with $3 \mid n$. Then $3$ divides the right-hand
side, so $3 \mid 3m+1$, which is absurd. $\square$

Thus every multiple of $3$ is a leaf of the inverse tree: $3, 9, 15, 21, 27,
\dots$ are all Syracuse-unreachable. Roughly one third of the odd numbers are
leaves.

### 3.2 Live nodes have infinitely many predecessors

The key arithmetic fact is the $2$-adic clock modulo $3$.

**Lemma 3.2.** $2^{2j} \equiv 1 \pmod 3$ for all $j\ge 0$; equivalently
$2^k \bmod 3$ equals $1$ if $k$ is even and $2$ if $k$ is odd.

*Proof.* Induction on $j$, using $2^{2(j+1)} = 4\cdot 2^{2j}$ and
$4\equiv 1 \pmod 3$. $\square$

**Definition 3.3 (start exponent).** For a live odd $n$ set
$$e(n) = \begin{cases} 2 & n \equiv 1 \pmod 3,\\ 1 & n \equiv 2 \pmod 3.\end{cases}$$

By Lemma 3.2 this is the least $k\ge 1$ with $2^{k}n \equiv 1 \pmod 3$.

**Theorem 3.4 (Infinite branching).** If $n$ is odd and live, then
$\mathrm{Pred}(n)$ is infinite. Consequently, for every odd $n$,
$$\mathrm{Pred}(n) = \varnothing \quad\text{or}\quad \mathrm{Pred}(n) \text{ is infinite}.$$
In particular $\mathrm{Pred}(n)$ is *never* a finite nonempty set, and never a
set of size three.

*Proof.* Fix live odd $n$ and set $e = e(n)$, so $2^{e}n \equiv 1 \pmod 3$. For
$j \ge 0$, Lemma 3.2 gives $2^{e+2j}n \equiv 2^{e}n \equiv 1 \pmod 3$, so
$$f(j) := \frac{2^{e+2j}n - 1}{3}$$
is an integer and satisfies $3f(j)+1 = 2^{e+2j}n$ with $e+2j\ge 1$, i.e.
$f(j) \to n$. Since $n > 0$ and the exponents increase strictly, $f$ is strictly
increasing and hence injective, so $\mathrm{Pred}(n) \supseteq f(\mathbb{N})$ is
infinite. The dichotomy follows by combining with Theorem 3.1 and Lemma 2.2 (even
$n$ has empty fibre by definition). $\square$

For $n=1$ we have $e = 2$ and $f(j) = (4^{j+1}-1)/3$, giving the fibre
$1, 5, 21, 85, 341, 1365,\dots$.

### 3.3 The Berggren tree is exactly ternary

**Theorem 3.5 (Exact ternary branching).** Let $(a,b,c)$ with $a,b > 0$ and
$a \ne b$. Then $|\mathrm{Ch}(a,b,c)| = 3$: the three Berggren children are
pairwise distinct.

*Proof.* Compare the third coordinates: they are $2a-2b+3c$, $2a+2b+3c$ and
$-2a+2b+3c$. Equality of the first two forces $b = 0$; of the first and third,
$a = b$; of the second and third, $a = 0$. All three are excluded. $\square$

**Theorem 3.6 (Cone invariance and strict hypotenuse growth).** If
$t \in \mathcal{C}$ and $s \in \mathcal{S}$ then $s\cdot t \in \mathcal{C}$ and
$t_3 < (s\cdot t)_3$.

*Proof.* Direct from the explicit formulas. For invariance, e.g. for $A$:
$a - 2b + 2c > 0$ because $c > b$ and $a > 0$; $2a - b + 2c > 0$ because $c>b$;
and $(2a-2b+3c) - (a-2b+2c) = a + c > 0$, $(2a-2b+3c) - (2a-b+2c) = c - b > 0$.
For growth, $(2a-2b+3c) - c = 2a - 2b + 2c = 2a + 2(c-b) > 0$; the arguments for
$B$ and $C$ are identical, using $c>a$ in the case of $C$. $\square$

### 3.4 The two obstruction theorems

**Theorem 3.7 (No branching transfer).** There is no map
$\Phi : \mathbb{Z}^3 \to \mathbb{N}$ such that for every $(a,b,c)$ with
$a,b>0$ and $a\ne b$, $\Phi$ restricts to a bijection
$$\mathrm{Ch}(a,b,c) \;\xrightarrow{\ \sim\ }\; \mathrm{Pred}\bigl(\Phi(a,b,c)\bigr).$$

*Proof.* Apply the hypothesis at $(3,4,5)$. Injectivity on $\mathrm{Ch}(3,4,5)$
and Theorem 3.5 give $|\Phi(\mathrm{Ch}(3,4,5))| = 3$; surjectivity gives
$\Phi(\mathrm{Ch}(3,4,5)) = \mathrm{Pred}(\Phi(3,4,5))$, which by Theorem 3.4 is
empty or infinite. A set cannot have three elements and be empty or infinite.
$\square$

Since any transfer of the Lorentz invariant along a branching isomorphism would
in particular be such a $\Phi$, the Transfer Hypothesis fails at its first
premise.

**Theorem 3.8 (No reverse embedding).** The Collatz predecessor graph has a
self-loop: $1 \to 1$, because $3\cdot 1 + 1 = 2^2\cdot 1$. Consequently there is
no map $\Psi : \mathbb{N}\to\mathcal{C}$ with
$\Psi(m) \in \mathrm{Ch}(\Psi(n))$ whenever $m \to n$.

*Proof.* Such a $\Psi$ applied to the self-loop gives
$\Psi(1) \in \mathrm{Ch}(\Psi(1))$, i.e. $\Psi(1) = s\cdot\Psi(1)$ for some
letter $s$. Comparing third coordinates contradicts Theorem 3.6. $\square$

So neither direction admits a structure-preserving map. The two trees are not
isomorphic as branching structures, in either sense.

---

## 4. Invariant rigidity

The obstructions of §3 are about shape. This section shows that, even ignoring
shape, no substitute for the Lorentz form exists on the Collatz side.

**Theorem 4.1 (Rigidity).** Let $P \in \mathbb{Q}[X]$ satisfy
$$P(m) = P(n) \qquad \text{whenever } m \to n.$$
Then $P$ is the constant polynomial $P(1)$.

*Proof.* By Theorem 3.4 the fibre $\mathrm{Pred}(1)$ is infinite (indeed
$1, 5, 21, 85,\dots$). Each of its elements $m$ satisfies $P(m) = P(1)$. Thus
$P - P(1)$ has infinitely many rational roots and is therefore the zero
polynomial. $\square$

The obstruction is already visible at degree two, with three small witnesses.

**Proposition 4.2 (Explicit quadratic rigidity).** Suppose
$\alpha x^2 + \beta x + \gamma$ is conserved along all Syracuse edges. Then
$\alpha = \beta = 0$.

*Proof.* Since $1, 5, 21 \in \mathrm{Pred}(1)$, conservation forces
$24\alpha + 4\beta = 0$ and $440\alpha + 20\beta = 0$. The determinant of this
system is $24\cdot 20 - 4\cdot 440 = -1280 \ne 0$. $\square$

Contrast this with the Berggren side.

**Theorem 4.3 (Conserved and nonconstant).** For every letter $s\in\mathcal{S}$
and every $t\in\mathbb{Z}^3$, $Q(s\cdot t) = Q(t)$. Moreover $Q$ is nonconstant:
$Q(3,4,5) = 0$ while $Q(1,1,1) = 1$.

*Proof.* Conservation is the statement that $A$, $B$, $C$ preserve the quadratic
form of signature $(2,1)$; it is an identity in $a, b, c$ verified by expansion.
For instance for $B$,
$$(a+2b+2c)^2 + (2a+b+2c)^2 - (2a+2b+3c)^2 = a^2+b^2-c^2$$
after cancellation. $\square$

**Corollary 4.4 (The tree is Lorentz-null).** Every node reachable from $(3,4,5)$
by a Berggren word satisfies $Q = 0$.

*Proof.* Induction on word length using Theorem 4.3, starting from
$Q(3,4,5) = 0$. $\square$

Finally, there is no growth exponent on the Collatz side either.

**Proposition 4.5 (Unbounded edge ratios).** For every bound $C$ there is
$m > C$ with $m \to 1$; yet also $1 \to 1$. Hence Syracuse edges realize
expansion ratios $m/n$ both equal to $1$ and arbitrarily large, and no analogue
of the silver-ratio growth law exists.

*Proof.* Immediate from Theorem 3.4 and Theorem 3.8. $\square$

For comparison, the Berggren growth is exactly pinned. Let $c_n$ denote the
hypotenuse along the Pell spine, i.e. the all-$B$ branch, so $c_0 = 5$,
$c_1 = 29$, and $c_{n+2} = 6c_{n+1} - c_{n}$.

**Theorem 4.6 (Silver window).** For all $n\ge 0$,
$$5\cdot 29^{n} \;\le\; 5^{n} c_n \qquad\text{and}\qquad c_n \;\le\; 5\cdot 6^{n},$$
so the per-step expansion is confined to $[29/5,\,6]$. Moreover
$$(1+\sqrt{2})^2 = 3 + 2\sqrt 2 = 5.8284271\ldots \in \left(\tfrac{29}{5},\,6\right).$$

*Proof.* Both bounds are inductions on the recurrence. For the lower bound, one
first shows $29c_n \le 5c_{n+1}$ by induction: the base case is
$29\cdot 5 \le 5\cdot 29$, and if $29c_i \le 5c_{i+1}$ then $5c_i \le c_{i+1}$,
whence $c_{i+2} = 6c_{i+1} - c_i \ge 6c_{i+1} - c_{i+1}/5 = \tfrac{29}{5}c_{i+1}$.
For the upper bound, $c_{i+2} = 6c_{i+1} - c_i \le 6c_{i+1}$ since $c_i > 0$, and
$c_0 = 5$. The membership statement follows from $\sqrt2 > 1.4$ and
$\sqrt 2 < 1.5$. $\square$

The true ratio $c_{n+1}/c_n$ converges to $3+2\sqrt 2$, the dominant root of
$x^2 - 6x + 1$: $29/5 = 5.8$, $169/29 = 5.8276$, $985/169 = 5.82840$,
$5741/985 = 5.828426$.

---

## 5. The exact fibre structure: rank one

The dichotomy of Theorem 3.4 raises the question of what the fibres actually
*are*. The answer is unexpectedly rigid.

**Lemma 5.1 (The branching letter).** If $m \to n$ then $4m+1 \to n$.

*Proof.* $3(4m+1)+1 = 12m + 4 = 4(3m+1) = 4\cdot 2^{k}n = 2^{k+2}n$. $\square$

Write $L(x) = 4x+1$ and, for live odd $n$, put
$$m_j(n) = \frac{2^{e(n)+2j}n - 1}{3}, \qquad j\ge 0,$$
the family constructed in the proof of Theorem 3.4. A one-line computation from
$3m_{j}(n)+1 = 2^{e(n)+2j}n$ shows
$$m_{j+1}(n) = 4\,m_j(n) + 1,$$
so the family is precisely the forward $L$-orbit of $m_0(n)$.

**Theorem 5.2 (Fibre structure).** Let $n$ be odd and live. Then
$$\mathrm{Pred}(n) \;=\; \{\, L^{(j)}(m_0(n)) : j \ge 0 \,\} \;=\; \{m_0(n),\, 4m_0(n)+1,\, 16m_0(n)+5,\, \dots\},$$
and this enumeration is strictly increasing. In particular the fibre is
order-isomorphic to $\mathbb{N}$.

*Proof.* The inclusion $\supseteq$ is the construction plus Lemma 5.1. For
$\subseteq$, let $m \to n$, say $3m+1 = 2^{k}n$ with $k\ge 1$. Reducing modulo
$3$ gives $2^{k}n \equiv 1$. By Lemma 3.2, the parity of $k$ is determined: if
$k$ is even then $n\equiv 1\pmod 3$ and $e(n) = 2$, and $k \ge 2$ since $k\ge 1$
and $k$ even; if $k$ is odd then $n \equiv 2 \pmod 3$ and $e(n) = 1$. Either way
$k = e(n) + 2j$ for some $j \ge 0$, and then $3m+1 = 3m_j(n)+1$, so $m = m_j(n)$.
Strict monotonicity is immediate from $m_{j+1} = 4m_j + 1 > m_j$. $\square$

**Example 5.3.** $\mathrm{Pred}(1) = \{1,5,21,85,341,\dots\}$,
$\mathrm{Pred}(5) = \{3,13,53,213,853,\dots\}$,
$\mathrm{Pred}(7) = \{9,37,149,597,\dots\}$,
$\mathrm{Pred}(11) = \{7,29,117,469,\dots\}$,
while $\mathrm{Pred}(3) = \mathrm{Pred}(9) = \mathrm{Pred}(21) = \varnothing$.

The correct picture of the inverse Collatz tree is therefore: **a forest of
one-dimensional combs**, each an $L$-orbit, glued at live nodes, with about a
third of all rungs terminating immediately.

**Theorem 5.4 (Residue clock).** For live odd $n$,
$$m_j(n) \equiv m_0(n) + j \pmod 3.$$
Hence exactly one rung in every three of a fibre is dead, and the other two are
live.

*Proof.* Induction on $j$: $m_{j+1} = 4m_j + 1 \equiv m_j + 1 \pmod 3$. $\square$

For $n=1$ one gets the exact clock $m_j(1) \equiv j+1 \pmod 3$, so the dead rungs
are those with $j \equiv 2 \pmod 3$: $21, 1365, 87381, \dots$

**Theorem 5.5 (Rank one versus rank three).** The branching of the inverse
Collatz tree has rank one: a single affine map $L(x) = 4x+1$ generates every
live fibre from its least element. By contrast no single map $g$ can generate the
Berggren children of $(3,4,5)$, since $\mathrm{Ch}(3,4,5) \not\subseteq
\{g(3,4,5)\}$ — the image of a single map at a point is a single point, while
$\mathrm{Ch}(3,4,5)$ has three elements by Theorem 3.5.

*Proof.* The first half is Theorem 5.2 together with
$m_j(n) = L^{(j)}(m_0(n))$. The second half is immediate from Theorem 3.5.
$\square$

This is the deepest of the four obstructions: it says the two branching monoids
differ in *rank*, not merely in fibre cardinality, so no reparametrization could
repair the mismatch.

---

## 6. The word calculus and where linearity fails

### 6.1 The word identity

The Berggren tree is governed by matrix words acting linearly. The Syracuse tree
has words too, but the action is affine, and the difference is exactly quantified
by the weight cocycle of Definition 2.6.

**Theorem 6.1 (Word identity).** Let $\mathbf{k} = (k_1,\dots,k_L)$ be the word of
a Syracuse chain from $m$ to $n$, with halving budget $S = \sum_i k_i$. Then
$$2^{S}\,n \;=\; 3^{L}\,m \;+\; w(\mathbf{k}).$$

*Proof.* Induction on $L$. For $L=0$ both sides are $n = m$. For the inductive
step, let the chain be $m \to m' \to \cdots \to n$ with first letter $k$ and tail
$\mathbf{k}'$, so $3m+1 = 2^{k}m'$ and, by induction,
$2^{S'}n = 3^{L'}m' + w(\mathbf{k}')$ where $S' = S - k$, $L' = L-1$. Then
$$2^{S}n = 2^{k}\bigl(2^{S'}n\bigr) = 2^{k}\bigl(3^{L'}m' + w(\mathbf{k}')\bigr)
= 3^{L'}\bigl(2^{k}m'\bigr) + 2^{k}w(\mathbf{k}')$$
$$= 3^{L'}(3m+1) + 2^{k}w(\mathbf{k}') = 3^{L}m + \bigl(3^{L'} + 2^{k}w(\mathbf{k}')\bigr)
= 3^{L}m + w(\mathbf{k}). \qquad\square$$

**Interpretation.** Solving for $n$ gives
$$n = \frac{3^{L}}{2^{S}}\,m \;+\; \frac{w(\mathbf{k})}{2^{S}}.$$
A Berggren word acts by a matrix — homogeneous, linear, invariant-preserving. A
Syracuse word acts by a *similitude plus a translation*. The translation term
$w(\mathbf{k})/2^{S}$ has no Berggren analogue, and it is precisely this affine
defect that makes conservation impossible. Theorem 4.1 is the conceptual
consequence; the word identity is the mechanism.

**Proposition 6.2 (Positivity and growth).** $w(\mathbf{k}) > 0$ for every
nonempty word, hence along any nonempty chain $3^{L}m < 2^{S}n$.

*Proof.* Immediate from $w(k\|\mathbf{k}') = 3^{|\mathbf{k}'|} + 2^k w(\mathbf{k}')
\ge 3^{|\mathbf{k}'|} > 0$ and Theorem 6.1. $\square$

### 6.2 Cycles

**Theorem 6.3 (Cycle equation).** If a Syracuse chain of word $\mathbf{k}$
returns to its start $m$, then
$$m\,\bigl(2^{S} - 3^{L}\bigr) \;=\; w(\mathbf{k}).$$

*Proof.* Set $n = m$ in Theorem 6.1 and rearrange (over $\mathbb{Z}$). $\square$

**Corollary 6.4.** Any nonempty Syracuse cycle satisfies $3^{L} < 2^{S}$, i.e.
$S/L > \log_2 3 = 1.5849625\ldots$

*Proof.* If $2^S \le 3^L$ then $2^S m \le 3^L m$, contradicting
$2^{S}m = 3^{L}m + w(\mathbf{k})$ with $w > 0$. $\square$

**Corollary 6.5 (No minimal-step cycle).** Every nonempty Syracuse cycle contains
a step with $2$-adic valuation at least $2$.

*Proof.* If every letter equalled $1$ (they are all $\ge 1$ by definition), then
$S = L$ and Corollary 6.4 would give $3^L < 2^L$, false for $L \ge 1$. $\square$

The only known cycle, $1 \to 1$, has word $(2)$: $L = 1$, $S = 2$, $w = 1$, and
$1\cdot(4-3) = 1$, confirming Theorem 6.3.

### 6.3 Two-sided bounds on the cocycle

**Theorem 6.6 (Weight bounds).** For every word $\mathbf{k}$ with all letters
$\ge 1$:
$$2^{L}\,w(\mathbf{k}) \;\le\; 3^{L}\,2^{S} \qquad\text{(upper)},$$
and for every nonempty such word,
$$3^{L} \;\le\; 3\,w(\mathbf{k}) \qquad\text{(lower)}.$$

*Proof.* The lower bound is immediate from the recursion:
$w(k\|\mathbf{k}') \ge 3^{L-1}$, so $3w \ge 3^{L}$. The upper bound is an
induction on $L$. Write $\mathbf{k} = k\|\mathbf{k}'$ with $L' = L-1$,
$S' = S-k$. Since all letters are $\ge 1$ we have $L' \le S'$, so
$2\cdot 2^{L'} = 2^{L'+1} \le 2^{k+S'} = 2^{k}2^{S'}$. Then
$$2^{L}w(\mathbf{k}) = 2^{L'+1}\bigl(3^{L'} + 2^{k}w(\mathbf{k}')\bigr)
= \bigl(2\cdot 2^{L'}\bigr)3^{L'} + \bigl(2\cdot 2^{k}\bigr)\bigl(2^{L'}w(\mathbf{k}')\bigr)$$
$$\le \bigl(2^{k}2^{S'}\bigr)3^{L'} + \bigl(2\cdot 2^{k}\bigr)\bigl(3^{L'}2^{S'}\bigr)
= 3\cdot 3^{L'}\cdot 2^{k}2^{S'} = 3^{L}2^{S},$$
using the inductive hypothesis in the middle step. $\square$

Feeding these into the cycle equation gives a two-sided pin on the minimum of a
hypothetical cycle:
$$3^{L} \;\le\; 3\,m\,(2^{S}-3^{L}), \qquad 2^{L}\,m\,(2^{S}-3^{L}) \;\le\; 3^{L}2^{S}.$$

**Theorem 6.7 (Two-heavy cycles are tiny).** If a Syracuse cycle satisfies
$2\cdot 3^{L} \le 2^{S}$, then
$$2^{L} m \;\le\; 2\cdot 3^{L}, \qquad\text{i.e.}\qquad m \;\le\; 2\left(\tfrac{3}{2}\right)^{L}.$$

*Proof.* From $2\cdot 3^L \le 2^S$ we get $2^{S} \le 2(2^{S} - 3^{L})$. Hence
$$(2^{L}m)\,2^{S} \le (2^{L}m)\cdot 2(2^{S}-3^{L}) = 2\bigl(2^{L}m(2^{S}-3^{L})\bigr)
\le 2\cdot 3^{L}2^{S} = (2\cdot 3^{L})2^{S},$$
using the upper pin. Cancelling the positive factor $2^S$ gives the claim.
$\square$

**Interpretation.** A hypothetical nontrivial cycle of length $L$ must either
(i) satisfy $3^L < 2^S < 2\cdot 3^L$, i.e. $\log_2 3 < S/L < \log_2 3 + 1/L$ —
forcing $S/L$ into an interval of width $1/L$ around $\log_2 3$, a rational
approximation constraint governed by the continued fraction of $\log_2 3$; or
(ii) have minimum below the explicit bound $2(3/2)^L$, which grows only
exponentially in base $3/2$ while cycle minima are known computationally to be
astronomically large. This is the classical Collatz cycle obstruction, here
derived from the weight bounds in three lines. The trivial cycle sits on the
critical side: for $\mathbf{k} = (2)$ one has $2\cdot 3 = 6 > 4 = 2^{S}$, so
hypothesis (ii) fails by exactly one factor of $2$.

---

## 7. The positive transfer: an embedded ternary subtree

The obstructions forbid an isomorphism. They do not forbid an *embedding*, and in
fact one exists — explicitly, computably, and with all the structural properties
one could ask of it short of surjectivity.

The construction rests on the Residue Clock (Theorem 5.4). Over a live node $n$
the fibre is the comb $m_0, m_1, m_2, \dots$ with $m_j \equiv m_0 + j\pmod 3$, so
among the six indices $j = 0,\dots,5$ at least four are live. We select three,
uniformly in the residue $r = m_0 \bmod 3$.

**Definition 7.1 (Live index selector).** For $r \in \{0,1,2\}$ set
$$\iota(r,A) = \begin{cases}2 & r = 2\\ 1 & \text{else}\end{cases},\qquad
\iota(r,B) = \begin{cases}2 & r = 0\\ 3 & \text{else}\end{cases},\qquad
\iota(r,C) = \begin{cases}4 & r \in \{0,1\}\\ 5 & r = 2.\end{cases}$$

**Lemma 7.2.** For each $r\in\{0,1,2\}$: $\iota(r,s) \ge 1$ for all letters $s$;
the three values $\iota(r,A),\iota(r,B),\iota(r,C)$ are pairwise distinct; and
$r + \iota(r,s) \not\equiv 0 \pmod 3$ for every $s$.

*Proof.* A finite check over the nine pairs $(r,s)$. For $r=0$: indices
$1, 2, 4$ with $0+1,0+2,0+4 \equiv 1,2,1$; for $r=1$: $1,3,4$ with
$1+1,1+3,1+4 \equiv 2,1,2$; for $r=2$: $2,3,5$ with $2+2,2+3,2+5 \equiv 1,2,1$.
All nonzero, all index-triples distinct. $\square$

**Definition 7.3 (Climb).** For live odd $n$ and $s\in\mathcal{S}$ put
$$\mathrm{climb}(n,s) \;=\; m_{\,\iota(m_0(n)\bmod 3,\;s)}(n).$$

**Lemma 7.4.** For live odd $n$ and every letter $s$: (i)
$\mathrm{climb}(n,s) \to n$; (ii) $\mathrm{climb}(n,s)$ is odd and live; (iii)
$n < \mathrm{climb}(n,s)$; (iv) distinct letters give distinct climbs.

*Proof.* (i) is Theorem 5.2. (ii): oddness is Lemma 2.2; liveness follows from
Theorem 5.4 and the third clause of Lemma 7.2. (iii): the chosen index $j$
satisfies $j \ge 1$, so the exponent is $e(n) + 2j \ge 3$, whence
$3\,\mathrm{climb}(n,s) + 1 = 2^{e(n)+2j}n \ge 8n$, giving
$\mathrm{climb}(n,s) \ge (8n-1)/3 > n$ for $n \ge 1$. (iv): the family $m_j(n)$
is strictly increasing hence injective in $j$, and the three indices are distinct
by Lemma 7.2. $\square$

**Theorem 7.5 (Ternary subtree embedding).** Define $F$ on words in
$\{A,B,C\}^{*}$ by $F(\varnothing) = 1$ and
$F(w\,s) = \mathrm{climb}(F(w), s)$. Then:

1. $F(w)$ is odd and live for every word $w$ — the construction never stalls;
2. $F(w\,s) \to F(w)$ for every word $w$ and letter $s$ — tree edges map to
   genuine Collatz predecessor edges;
3. $F(w) < F(w\,s)$ — the embedding strictly increases along edges;
4. $F(w\,s) \ne F(w\,t)$ for $s \ne t$ — the branching is genuinely ternary at
   every node.

Hence the free ternary tree on three letters embeds into the inverse Collatz tree
as a subtree of live, strictly increasing nodes.

*Proof.* Induction on the length of $w$, applying Lemma 7.4 at each step; the
base case is that $1$ is odd and live. $\square$

**Example 7.6.** The first two levels:
$$F(A) = 5,\quad F(B) = 85,\quad F(C) = 341,$$
$$F(AA) = 13,\ F(AB) = 53,\ F(AC) = 853,\quad F(BA) = 1813,\ F(BB) = 7253,\ F(BC) = 116053,$$
$$F(CA) = 3637,\ F(CB) = 14549,\ F(CC) = 232789.$$
Each is a genuine Syracuse predecessor of its parent; e.g. $3\cdot 85 + 1 = 256
= 2^{8}\cdot 1$ and $3\cdot 1813+1 = 5440 = 2^{6}\cdot 85$.

**Remark 7.7 (Why this does not rescue the hypothesis).** A subtree cannot carry
an invariant its ambient tree lacks in the following sense: the composite
$Q \circ F^{-1}$ is not even well-defined on the Collatz tree (the image of $F$
is a sparse subset), and $Q$ is identically $0$ on all Berggren nodes anyway
(Corollary 4.4), so pulling it back gives only the constant function. The genuine
invariant content of the Berggren tree is its *nonconstancy off the tree*, which
has nowhere to live on the Collatz side by Theorem 4.1. Shape transfers;
invariant does not.

---

## 8. Rank-one rigidity in the abstract

The final result explains *why* Theorem 4.1 holds, in a way that removes $3n+1$
from the picture altogether.

**Definition 8.1 (Affine orbit).** For integers $a \ge 2$, $b \ge 0$ and
$x_0 > 0$, let $\mathcal{O}(a,b,x_0) = \{x_j\}_{j\ge 0}$ with $x_{j+1} = ax_j+b$.

Since $a \ge 2$ and $x_0 > 0$, every $x_j > 0$ and
$x_{j+1} \ge 2x_j + b > x_j$; hence $\mathcal{O}(a,b,x_0)$ is strictly increasing
and infinite.

**Theorem 8.2 (Affine rank-one rigidity).** If $P\in\mathbb{Q}[X]$ is constant on
$\mathcal{O}(a,b,x_0)$ for some $a\ge 2$, $b\ge 0$, $x_0 > 0$, then $P$ is
constant.

*Proof.* The orbit is infinite, so $P - P(x_0)$ has infinitely many roots and
must vanish identically. (More generally, a rational polynomial taking a single
value on an infinite set of integers is constant.) $\square$

**Corollary 8.3 (Collatz case).** Taking $(a,b) = (4,1)$ and $x_0 = m_0(n)$:
for live odd $n$, any rational polynomial constant on the fibre
$\mathrm{Pred}(n)$ is constant. Theorem 4.1 is the special case $n = 1$.

So the absence of Collatz invariants is a statement about **branching rank**, not
about the arithmetic of $3n+1$: *any* tree whose fibres are single affine orbits
with multiplier $\ge 2$ is immune to polynomial invariants. Nothing about the
choice of the multiplier $3$, the shift $+1$, or the prime $2$ enters the
argument.

The residual structure of a rank-one fibre is congruential rather than
polynomial.

**Theorem 8.4 (Eventual periodicity of residues).** For every modulus $M > 0$,
the residues of $\mathcal{O}(a,b,x_0)$ modulo $M$ are eventually periodic with
period at most $M$: there exist $i \ge 0$ and $1 \le p \le M$ with
$x_{i+t+p} \equiv x_{i+t} \pmod M$ for all $t\ge 0$.

*Proof.* Among the $M+1$ indices $0,\dots,M$ two must have equal residues by the
pigeonhole principle, say $x_i \equiv x_{i'} \pmod M$ with $i < i'$. The affine
step respects congruences ($x \equiv y$ implies $ax+b \equiv ay+b$), so the
congruence propagates forward with $p = i'-i \le M$. $\square$

**Corollary 8.5 (The exact Collatz clock).** For the fibre over $1$,
$m_j(1) \equiv j+1 \pmod 3$, so the residues run through the exact period-$3$
cycle $1, 2, 0, 1, 2, 0, \dots$ and the dead members are precisely those with
$j \equiv 2 \pmod 3$.

This last statement is the arithmetic heart of the subtree construction of §7:
because exactly one rung in three is dead, live lifts always exist and the
embedding never stalls.

---

## 9. Algorithms

The results above are effective. We record the three algorithms that compute
them.

**Algorithm A (Fibre enumeration).** *Input*: odd $n$, count $N$. *Output*: the
$N$ smallest Collatz predecessors of $n$, or $\varnothing$.
Compute $n \bmod 3$; if $0$, return $\varnothing$. Otherwise set
$e \leftarrow 2$ if $n\equiv 1\pmod 3$ else $1$, then
$m \leftarrow (2^{e}n-1)/3$ and iterate $m \leftarrow 4m+1$. Cost: $O(N)$ big-integer
operations; correctness is Theorem 5.2.

**Algorithm B (Word identity and cycle test).** *Input*: odd $m$, step count $L$.
*Output*: the valuation word, the endpoint, the weight, and a verification of
$2^{S}n = 3^{L}m + w$. Iterate the Syracuse map recording $2$-adic valuations;
evaluate $w$ by the right-to-left recursion $w \leftarrow 3^{\text{depth}} + 2^{k}w$.
Cost: $O(L)$ steps plus $O(L)$ big-integer multiplications. If the endpoint equals
$m$ the cycle equation $m(2^S-3^L)=w$ is checked (Theorem 6.3), together with the
two-heavy dichotomy of Theorem 6.7.

**Algorithm C (Ternary embedding).** *Input*: a word $w \in \{A,B,C\}^{*}$.
*Output*: the odd number $F(w)$, together with a certificate that each edge is a
predecessor edge. Start at $1$; at each letter compute the fibre base $m_0$, read
off $r = m_0\bmod 3$, look up $\iota(r,s)$ in the $3\times 3$ table of
Definition 7.1, and advance $\iota(r,s)$ rungs along $x\mapsto 4x+1$. Cost:
$O(|w|)$ fibre steps; the integers grow like $4^{\,\Theta(|w|)}$, so the bit-cost
is exponential in $|w|$, which is intrinsic — by Lemma 7.4(iii) the values must
grow at least geometrically.

---

## 10. Discussion

### 10.1 What the folklore gets wrong

The statement "the inverse Collatz tree is ternary" is pervasive in heuristic
treatments of the $3n+1$ problem, where it underwrites branching-process models
with three offspring per node. Theorem 3.4 shows it is false in the strongest
possible way: the branching number is $0$ or $\aleph_0$, never $3$. The correct
picture (Theorem 5.2) is a *comb*: each live node carries an infinite
one-dimensional fibre generated by $x\mapsto 4x+1$, of which exactly two rungs in
three are live (Theorem 5.4).

This is not merely pedantic. The average-branching heuristics are calibrated to
the density of live descendants, and the exact clock of Theorem 5.4 replaces an
average by an identity. Any probabilistic model of the inverse tree should be
built on the comb, not on the bush.

### 10.2 Linear versus affine

The conceptual content of the refutation is the linear/affine distinction made
precise by Theorem 6.1. The Berggren letters are elements of
$O(2,1;\mathbb{Z})$ — homogeneous linear maps, hence isometries of a quadratic
form. The Syracuse letters $x\mapsto (3x+1)/2^{k}$ are affine with nonzero
translation. Composing $L$ of them produces the translation term $w(\mathbf{k})$,
whose size is comparable to $3^{L}$ (Theorem 6.6 pins it between $3^{L-1}$ and
$3^{L}2^{S-L}$). There is no quadratic bookkeeping that survives an additive
perturbation of that magnitude — which is Theorem 4.1 made quantitative.

### 10.3 Positive residue

What is left of the Transfer Hypothesis is Theorem 7.5. It is not a technicality:
it produces, for every ternary word, an explicit odd number, together with a
proof that the resulting infinite family of Collatz chains is well-defined,
strictly increasing and never stalls on a dead node. Constructively, it says the
inverse Collatz tree contains free ternary trees of arbitrary depth with all
nodes live — a fact whose direct verification for depth $d$ requires exhibiting
$(3^{d+1}-1)/2$ numbers, but which the selector $\iota$ delivers in closed form.

### 10.4 Bearing on the Collatz conjecture

Nothing here proves or disproves the Collatz conjecture, and no method proposed
here is likely to. What the results do provide is a sharp boundary marker. They
say:

* no *polynomial* conserved quantity exists, of any degree (Theorem 4.1);
* the obstruction is structural, not arithmetic (Theorem 8.2), so perturbing the
  $3n+1$ rule will not help;
* the residual invariant-like structure is congruential and eventually periodic
  (Theorem 8.4, Corollary 8.5);
* on cycles the affine cocycle gives real quantitative leverage (Theorems 6.3,
  6.6, 6.7).

Researchers proposing invariant-based attacks on Collatz now have an explicit
theorem telling them which shapes of invariant are ruled out, and why.

---

## 11. Future directions

**Sharpening the cycle window.** Theorem 6.7 shows that a cycle with
$2\cdot 3^{L}\le 2^{S}$ has minimum $m \le 2(3/2)^{L}$. Pairing this with
explicit continued-fraction bounds on $|S/L - \log_2 3|$ — i.e. irrationality
measure estimates for $\log_2 3$ — should yield an unconditional lower bound on
the length of any hypothetical nontrivial cycle purely from the cocycle
machinery. The missing ingredient is a matching *lower* bound on cycle minima,
which the fibre structure of §5 constrains but does not yet supply.

**Non-polynomial invariants.** Theorem 4.1 rules out polynomials over
$\mathbb{Q}$. It says nothing about $2$-adic analytic functions, about invariants
valued in finite groups, or about functions that are merely monotone along edges
rather than constant. Corollary 8.5 suggests that the surviving structure is
congruential; a systematic classification of eventually-periodic residue
invariants on rank-one fibres is the natural next target.

**Rank-one trees in general.** Theorem 8.2 applies to any tree whose fibres are
affine orbits with multiplier $\ge 2$. Which arithmetic dynamical systems have
this property? Is rank one equivalent, in a suitable category, to the absence of
polynomial invariants? A converse — invariant-bearing implies rank $\ge 2$ —
would turn the obstruction into a classification.

**Density of the embedded subtree.** Theorem 7.5 produces a free ternary subtree
of live nodes. How dense is its image? The values grow like $4^{\Theta(d)}$ at
depth $d$ while there are $3^{d}$ of them, so the image has density zero, but the
exact counting function of $\{F(w) : |w| \le d\}$ below $x$ is unknown and
computable in principle from the selector.

**Multi-letter Collatz variants.** The $3n+1$ map has rank-one fibres. Do
$qn+r$ maps for other $q, r$ ever have rank $\ge 2$? If so, those variants would
be the natural place to look for Berggren-type invariants, and the comparison
would isolate exactly what is special about $q = 3$.

---

## 12. Conclusion

Two ternary-looking trees; one tame, one wild. The tame one is tame because its
three generators act linearly and preserve the Lorentz form
$a^2 + b^2 - c^2$, whose vanishing *is* the Pythagorean condition; its Pell spine
expands by the silver ratio squared $3+2\sqrt 2$, confined to the proved window
$[29/5, 6]$. The wild one is wild because it is not ternary at all: its nodes
have $0$ or infinitely many predecessors, its fibres are rank-one combs generated
by $x\mapsto 4x+1$, its predecessor graph has a self-loop at $1$, and it admits
no conserved polynomial of any degree. Four independent obstructions block the
transfer, and the word identity
$$2^{S}n = 3^{L}m + w(k_1,\dots,k_L)$$
identifies the culprit in one symbol: the affine cocycle $w$, absent on the
Berggren side, whose size $\asymp 3^{L}$ overwhelms any quadratic bookkeeping.

What survives is an embedding, not an isomorphism: the free ternary tree sits
inside the inverse Collatz tree as an explicit subtree of live, strictly growing
nodes beginning $1 \to \{5, 85, 341\}$. Shape transfers; substance does not.
And the failure is instructive — the reason is branching rank, a structural
feature that no amount of arithmetic ingenuity around $3n+1$ can alter.
