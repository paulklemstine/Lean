# The Exact Ensemble Dichotomy and the Combinatorics of Even Closed Walks

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

We study the symmetric Rademacher (coin-flip) ensemble: the $N \times N$ symmetric
random matrix $W$ with zero diagonal and independent uniform signs $W_{ij} = W_{ji}
\in \{\pm 1\}$ off the diagonal. We prove an *exact dichotomy* for the ensemble
average of an arbitrary monomial in the matrix entries: for any finite family of
steps $(a_t, b_t)_{t=1}^n$,
$$\mathbb{E}\left[\prod_{t=1}^n W_{a_t b_t}\right] \in \{0, 1\},$$
the value being $1$ precisely when the family is loop-free ($a_t \neq b_t$ for all
$t$) and every unordered pair occurs with even multiplicity, and $0$ otherwise. The
vanishing half is a sign-flip involution on the configuration space; the surviving
half is deterministic — the monomial is the constant function $1$.

The dichotomy converts the moment problem for this ensemble into pure enumeration. We
introduce a cyclic encoding of closed walks — a closed walk of length $L$ on $N$
vertices is a map $w : \mathbb{Z}/L \to \{1, \dots, N\}$, the $t$-th step going from
$w(t)$ to $w(t+1)$ — and call such a walk *even* if it never stands still and
traverses every edge an even number of times. Writing $\mathcal{E}(N, L)$ for the
number of even closed $L$-walks, our central identity is
$$\mathbb{E}\left[\operatorname{tr}(W^L)\right] = \mathcal{E}(N, L)
\qquad \text{for every } N \geq 1,\ L \geq 1,$$
an exact equality at finite dimension, with no asymptotics.

From this dictionary we derive: (i) all odd trace moments vanish identically at every
$N$; (ii) an even closed $L$-walk uses at most $L/2$ distinct edges and visits at most
$L/2 + 1$ distinct vertices; (iii) evenness is invariant under injective relabelling
of vertices, whence the *polynomiality* expansion $\mathcal{E}(N, L) = \sum_r
\binom{N}{r} b_{r,L}$ with dimension-free shape counts $b_{r,L}$ vanishing for $2r >
L+2$; (iv) a uniform bound $\mathcal{E}(N, 2k+2) \leq \left(\sum_r b_{r, 2k+2}\right)
N^{k+2}$, hence uniform boundedness of all even normalised spectral moments; (v) the
exact moment polynomials $\mathcal{E}(N,2) = N(N-1)$, $\mathcal{E}(N,4) = N(N-1)(2N-3)$
and $\mathcal{E}(N,6) = N(N-1)(5N^2-15N+11)$; and (vi) convergence of the expected
sixth normalised moment to the semicircle value $C_3 = 5$, with the exact finite-$N$
correction $5 - 20/N + 26/N^2 - 11/N^3$. We also verify that the top shape counts
obey $b_{k+1, 2k} = C_k \cdot (k+1)!$ for $k = 1, 2, 3$, exhibiting the Catalan
numbers as leading coefficients, and formulate the general statement as a conjecture
with a tree-contour proof strategy.

**Keywords:** random matrices, Rademacher ensemble, semicircle law, closed walks,
edge multiplicity, sign-flip involution, Catalan numbers, moment method.

---

## 1. Introduction

### 1.1 Motivation

The moment method is the oldest route to Wigner's semicircle law. One expands
$\operatorname{tr}(W^L)$ as a sum over closed walks in the complete graph, takes
expectations term by term, and argues that in the large-$N$ limit only a distinguished
family of walks contributes, whose count is a Catalan number. The argument is robust
and applies to broad classes of ensembles, but it is intrinsically asymptotic: the
error terms are controlled by inequalities, and the finite-$N$ statements are
inequalities too.

For one particular ensemble the argument can be made *exact*. Suppose the entries are
not merely centred with unit variance, but are uniform signs $\pm 1$, and the diagonal
is identically zero. Then a monomial in the entries is a product of signs, and the
ensemble average of such a product is a completely elementary object: it is $1$ if
every sign appears an even number of times, and $0$ otherwise. There is no variance
bookkeeping, no truncation, no concentration inequality. The moment method becomes a
bijective correspondence.

This paper develops that correspondence systematically. The point is not merely that
one can compute a few moments in closed form (though we do compute three), but that
the *entire* moment sequence becomes a family of combinatorial counting problems that
can be studied on their own terms — with structural theorems (polynomiality, degree
bounds, relabelling invariance) that feed back into sharp probabilistic statements at
finite $N$.

### 1.2 The ensemble

Fix $N \in \mathbb{N}$ and let $V = \{1, \dots, N\}$ be the vertex set. A
**configuration** is a function
$$g : \{\,\{i,j\} \subseteq V : i \neq j\,\} \to \{-1, +1\}$$
assigning a sign to each of the $\binom{N}{2}$ unordered pairs. There are
$2^{\binom{N}{2}}$ configurations; the ensemble average $\mathbb{E}[F]$ of a function
$F$ on configurations is the unweighted arithmetic mean over all of them.

The **coin-flip matrix** associated with $g$ is the symmetric $N \times N$ real matrix
$$W(g)_{ij} = \begin{cases} g(\{i,j\}) & i \neq j, \\ 0 & i = j.\end{cases}$$

Two conventions deserve emphasis. First, the diagonal is *exactly* zero, not merely
centred; this is what makes the loop-free condition below a clean dichotomy rather
than a variance computation. Second, the off-diagonal entries take only the values
$\pm 1$, so $W(g)_{ij}^2 = 1$ identically for $i \neq j$ — several quantities that are
random for general Wigner ensembles are deterministic here.

### 1.3 Notation for walk monomials

Let $I$ be a finite index set and let $a, b : I \to V$ be two functions, to be thought
of as the source and target of each step. Write $e_t = \{a(t), b(t)\}$ for the
unordered pair traversed at step $t$ (equivalently, the *edge* of that step, encoded
canonically as an ordered pair with the smaller coordinate first). For an unordered
pair $p$ define the **edge multiplicity**
$$m_p(a,b) = \#\{\, t \in I : e_t = p \,\}.$$
Two elementary facts will be used repeatedly:
$$\sum_{p} m_p(a,b) = |I|, \tag{1.1}$$
since each step contributes to exactly one pair; and
$$m_p(a,b) \neq 0 \iff \exists t,\ e_t = p. \tag{1.2}$$

The family $(a,b)$ is **loop-free** if $a(t) \neq b(t)$ for all $t \in I$.

---

## 2. The Exact Ensemble Dichotomy

### 2.1 Statement

> **Theorem 2.1 (Exact Ensemble Dichotomy).** Let $I$ be a finite index set and
> $a, b : I \to V$. Then
> $$\mathbb{E}\left[\prod_{t \in I} W_{a(t)\, b(t)}\right] =
> \begin{cases} 1, & \text{if } (a,b) \text{ is loop-free and } m_p(a,b) \text{ is even for every } p, \\
> 0, & \text{otherwise.}\end{cases}$$

The theorem admits no intermediate values: an average over an exponentially large
space is always exactly an integer, and always $0$ or $1$.

### 2.2 Proof

*Case A: some step is a loop.* If $a(t_0) = b(t_0)$ for some $t_0$, the product
contains the factor $W_{a(t_0) a(t_0)} = 0$, so the product is identically zero as a
function on configurations, and its average is $0$. This settles the "otherwise"
branch whenever loop-freeness fails.

Assume henceforth $(a,b)$ is loop-free. Grouping the steps by the pair they traverse,
$$\prod_{t \in I} W_{a(t)\, b(t)}(g) = \prod_{p} g(p)^{\,m_p(a,b)}. \tag{2.1}$$

*Case B: all multiplicities even.* Each factor $g(p)^{m_p}$ equals $\left(g(p)^2\right)^{m_p/2}
= 1$ because $g(p) = \pm 1$. Hence the product in (2.1) is the constant function $1$
on the configuration space, and its average is $1$. Note this half is *deterministic*:
the monomial does not fluctuate at all.

*Case C: some multiplicity odd.* Let $p_0$ be a pair with $m_{p_0}$ odd. Define the
**sign-flip involution** $\sigma_{p_0}$ on configurations by
$$(\sigma_{p_0} g)(p) = \begin{cases} -g(p), & p = p_0, \\ g(p), & p \neq p_0. \end{cases}$$
Clearly $\sigma_{p_0} \circ \sigma_{p_0} = \mathrm{id}$, and $\sigma_{p_0}$ is a
bijection of the configuration space with no fixed points. By (2.1),
$$\prod_{t} W_{a(t) b(t)}(\sigma_{p_0} g) = (-1)^{m_{p_0}} \prod_{t} W_{a(t) b(t)}(g)
= -\prod_{t} W_{a(t) b(t)}(g),$$
since all other factors are unchanged and $m_{p_0}$ is odd. Summing over all $g$ and
substituting $g \mapsto \sigma_{p_0} g$ shows the total sum equals its own negative,
hence is $0$, hence the average is $0$. $\blacksquare$

### 2.3 Discussion

The two halves have very different characters. The surviving half (Case B) is a
statement of *determinism*: a loop-free monomial with all multiplicities even is the
constant $1$ on the nose, so the associated "random" quantity has zero variance. The
vanishing half (Case C) is a *symmetry* statement: an odd multiplicity produces an
exact odd symmetry of the monomial under a measure-preserving involution.

For general Wigner ensembles neither half survives in this strength: even
multiplicities produce products of squares whose average is a product of variances
(and higher even moments enter when a multiplicity exceeds two), while odd
multiplicities vanish only because the entries are centred, and only in expectation.
The coin-flip ensemble is precisely the case where both mechanisms become exact and
integer-valued.

---

## 3. Even Closed Walks

### 3.1 Cyclic encoding

Expanding the trace of a matrix power,
$$\operatorname{tr}(W^L) = \sum_{w : \mathbb{Z}/L \to V} \ \prod_{t \in \mathbb{Z}/L}
W_{w(t)\, w(t+1)}, \tag{3.1}$$
where the index $t+1$ is computed modulo $L$. It is convenient to take this as the
*definition* of a closed walk.

> **Definition 3.1.** A **closed walk of length $L$** on $N$ vertices is a function
> $w : \mathbb{Z}/L \to V$; its $t$-th step goes from $w(t)$ to $w(t+1)$, cyclically.
> The walk is **even** if
> 1. *(loop-freeness)* $w(t) \neq w(t+1)$ for every $t$, and
> 2. *(even multiplicities)* every unordered pair $p$ satisfies
>    $m_p(w, w(\cdot + 1)) \in 2\mathbb{Z}$.
>
> Write $\mathcal{E}(N, L)$ for the number of even closed $L$-walks on $N$ vertices.

The cyclic encoding is more symmetric than the usual "base point plus interior
vertices" encoding of a closed walk (a starting vertex $i$ together with $L-1$
subsequent vertices, returning to $i$). The two are related by a trivial bijection: a
pair $(i, v)$ with $v$ a sequence of length $L - 1$ corresponds to the cyclic walk
$w = (i, v_1, \dots, v_{L-1})$, and one checks that the $t$-th step of the linear
encoding is the $t$-th cyclic step, the last step closing the loop. Evenness in the
two encodings agrees.

### 3.2 The dictionary

> **Theorem 3.2 (Every trace moment is a walk count).** For every $N \geq 1$ and every
> $L \geq 1$,
> $$\mathbb{E}\left[\operatorname{tr}(W^L)\right] = \mathcal{E}(N, L).$$

*Proof.* Take the ensemble average of (3.1) and exchange the finite sum with the
average. For each closed walk $w$, the inner expectation is the average of a walk
monomial with index set $\mathbb{Z}/L$, source $a = w$ and target $b = w(\cdot + 1)$.
By Theorem 2.1 this equals $1$ if $w$ is loop-free with all multiplicities even —
i.e. if $w$ is an even closed walk — and $0$ otherwise. So the sum reduces to the
indicator sum $\sum_w \mathbf{1}[w \text{ even}] = \mathcal{E}(N, L)$. $\blacksquare$

Since $\operatorname{tr}(W^L) = \sum_{i} \lambda_i(W)^L$, the theorem states that the
expected $L$-th power sum of the eigenvalues of a coin-flip matrix is *identically* an
integer count of combinatorial objects, at every finite dimension. All subsequent
results are theorems about $\mathcal{E}(N, L)$.

---

## 4. Exact Vanishing of the Odd Moments

> **Theorem 4.1 (Odd closed walks are never even).** For every $N$ and every $k \geq 0$,
> $$\mathcal{E}(N, 2k+1) = 0, \qquad \text{hence} \qquad
> \mathbb{E}\left[\operatorname{tr}(W^{2k+1})\right] = 0.$$

*Proof.* Let $w$ be an even closed walk of length $L = 2k+1$. By the counting identity
(1.1) applied to the index set $\mathbb{Z}/L$,
$$L = \sum_p m_p(w, w(\cdot+1)).$$
Every summand is even by assumption, and a finite sum of even integers is even; so $L$
is even, contradicting $L = 2k+1$. Hence no such walk exists. The moment statement
follows from Theorem 3.2. $\blacksquare$

Normalising, the expected $m$-th moment of the empirical spectral distribution of
$W/\sqrt{N}$ vanishes identically for every odd $m$ and every finite $N$:
$$\mathbb{E}\left[\frac{1}{N}\operatorname{tr}\left(\frac{W}{\sqrt N}\right)^{2k+1}\right] = 0.$$
This is a strictly stronger statement than the usual asymptotic one. In the general
Wigner setting one shows only that the odd normalised moments tend to zero; here they
*are* zero, exactly, at every $N$, including $N = 1$ and $N = 2$. Structurally, the
vanishing has two independent explanations that coincide: on the algebraic side, the
sign-flip involution; on the combinatorial side, the parity of the number of steps.

---

## 5. Structure of Even Closed Walks

The remaining results all rest on two structural theorems: a bound on how much of the
graph an even walk can see, and the observation that evenness ignores vertex names.

### 5.1 Edge and vertex bounds

For a closed walk $w$ of length $L$, let
$$E(w) = \{\, \{w(t), w(t+1)\} : t \in \mathbb{Z}/L \,\}, \qquad
V(w) = \{\, w(t) : t \in \mathbb{Z}/L \,\}$$
denote its edge set and vertex set.

> **Lemma 5.1.** If $w$ is an even closed walk, every edge in $E(w)$ is traversed at
> least twice.

*Proof.* If $p \in E(w)$ then $m_p \neq 0$ by (1.2), and $m_p$ is even, so $m_p \geq 2$.
$\blacksquare$

> **Theorem 5.2 (Edge bound).** If $w$ is an even closed walk of length $L$, then
> $2\,|E(w)| \leq L$.

*Proof.* Using Lemma 5.1 and then (1.1),
$$2\,|E(w)| = \sum_{p \in E(w)} 2 \leq \sum_{p \in E(w)} m_p \leq \sum_{p} m_p = L.
\qquad \blacksquare$$

> **Theorem 5.3 (Spanning-tree inequality).** If $w$ is a loop-free closed walk of any
> length, then $|V(w)| \leq |E(w)| + 1$.

*Proof.* Fix the base point $w(0)$. For each visited vertex $u \in V(w)$, let
$\tau(u) = \min\{\, t : w(t) = u \,\}$ be the *arrival time* of $u$ (the minimum is
over a nonempty set of residues, using the standard representatives $0, 1, \dots,
L-1$). Define the **discovery edge**
$$\delta(u) = \{\, w(\tau(u) - 1),\ w(\tau(u)) \,\},$$
which lies in $E(w)$ because it is the edge of step $\tau(u) - 1$, and which is a
genuine edge (not a loop) by loop-freeness.

We claim $\delta$ is injective on $V(w) \setminus \{w(0)\}$. Note first that for
$u \neq w(0)$ we have $\tau(u) \neq 0$, since $w(\tau(u)) = u \neq w(0)$. Suppose
$\delta(u) = \delta(u')$ for two such vertices. As unordered pairs of distinct
elements, either
$$w(\tau(u)) = w(\tau(u')) \quad \text{(and the predecessors agree)},$$
in which case $u = u'$ and we are done; or the two pairs match crosswise:
$$w(\tau(u) - 1) = w(\tau(u')), \qquad w(\tau(u)) = w(\tau(u') - 1).$$
In the crosswise case, $u'$ is visited at time $\tau(u) - 1$ and $u$ at time
$\tau(u') - 1$, so minimality of arrival times gives
$$\tau(u') \leq \tau(u) - 1 \quad\text{and}\quad \tau(u) \leq \tau(u') - 1$$
as integers in $\{0, \dots, L-1\}$ (both arrival times being nonzero, the subtraction
is honest integer subtraction). Adding, $\tau(u) + \tau(u') \leq \tau(u) + \tau(u') -
2$, a contradiction. Hence $\delta$ is injective, so
$$|V(w)| - 1 = |V(w) \setminus \{w(0)\}| \leq |E(w)|. \qquad \blacksquare$$

The name is apt: the discovery edges form a spanning tree of the subgraph visited by
the walk, and the inequality is the familiar "a tree on $n$ vertices has $n-1$ edges".

> **Corollary 5.4 (Vertex bound).** If $w$ is an even closed walk of length $L$, then
> $$2\,|V(w)| \leq L + 2, \qquad \text{i.e.} \qquad |V(w)| \leq \frac{L}{2} + 1.$$

*Proof.* Combine Theorems 5.2 and 5.3: $2|V(w)| \leq 2|E(w)| + 2 \leq L + 2$.
$\blacksquare$

Corollary 5.4 is the mechanism behind the $N^{k+1}$ size of the $2k$-th moment: a
walk can only "spend" dimension on the vertices it visits, and it may visit at most
$k+1$.

### 5.2 Relabelling invariance

> **Theorem 5.5 (Evenness is a relabelling invariant).** Let $f : V' \to V$ be an
> injection of vertex sets and let $w$ be a closed walk of length $L$ on $V'$. Then
> $f \circ w$ is an even closed walk on $V$ if and only if $w$ is an even closed walk
> on $V'$.

*Proof.* Loop-freeness transfers in both directions because $f$ is injective:
$f(w(t)) = f(w(t+1))$ iff $w(t) = w(t+1)$.

For multiplicities, the key observation is that injective maps preserve edge identity:
for $a \neq b$ and $c \neq d$ in $V'$,
$$\{f(a), f(b)\} = \{f(c), f(d)\} \iff \{a, b\} = \{c, d\},$$
one direction by injectivity applied coordinatewise and the other trivially. Hence,
for any step $t_0$,
$$m_{\{f(w(t_0)), f(w(t_0+1))\}}(f \circ w) = m_{\{w(t_0), w(t_0+1)\}}(w),$$
because the two filters defining the counts select the same set of steps.

Now suppose $w$ is even. Let $p$ be any pair in $V$. If $m_p(f\circ w) = 0$ it is even
and there is nothing to prove. Otherwise, by (1.2) there is a step $t_0$ with
$p = \{f(w(t_0)), f(w(t_0+1))\}$, and then $m_p(f \circ w) = m_{\{w(t_0), w(t_0+1)\}}(w)$
is even by hypothesis. The converse direction is symmetric. $\blacksquare$

---

## 6. Polynomiality of the Moment Counts

### 6.1 Shape counts

> **Definition 6.1.** For $r, L \geq 1$, the **shape count** $b_{r,L}$ is the number of
> even closed $L$-walks on the vertex set $\{1, \dots, r\}$ that are *surjective*, i.e.
> that visit every one of the $r$ vertices.

Shape counts do not depend on $N$; they are the atoms out of which all moments are
assembled.

> **Lemma 6.2.** For any $S \subseteq V$ with $|S| = r$, the number of even closed
> $L$-walks $w$ on $V$ with $V(w) = S$ equals $b_{r, L}$.

*Proof.* Choose any bijection $\iota : \{1, \dots, r\} \to S$ and view it as an
injection into $V$. Composition with $\iota$ is a bijection between maps
$\mathbb{Z}/L \to \{1, \dots, r\}$ and maps $\mathbb{Z}/L \to V$ with image contained
in $S$. Under this bijection surjectivity onto $\{1,\dots,r\}$ corresponds to image
exactly $S$, and by Theorem 5.5 evenness corresponds to evenness. $\blacksquare$

### 6.2 The binomial expansion

> **Theorem 6.3 (Polynomiality).** For every $N$ and every $L \geq 1$,
> $$\mathcal{E}(N, L) = \sum_{r = 0}^{L} \binom{N}{r}\, b_{r, L}.$$
> In particular $\mathcal{E}(\cdot, L)$ is a polynomial function of $N$ with
> coefficients, in the binomial basis, given by finitely many integers independent of
> $N$.

*Proof.* Partition the set of even closed $L$-walks on $V$ according to their vertex
set $V(w)$, which is a subset of $V$ of size at most $L$ (a walk of length $L$ visits
at most $L$ vertices, so $b_{r,L} = 0$ for $r > L$). For each $r$ there are
$\binom{N}{r}$ subsets of size $r$, and by Lemma 6.2 each contributes exactly
$b_{r,L}$ walks. Summing over $r$ gives the claim. $\blacksquare$

> **Theorem 6.4 (Degree bound).** $b_{r, L} = 0$ whenever $L + 2 < 2r$. Consequently
> the sum in Theorem 6.3 may be truncated at $r = \lfloor L/2 \rfloor + 1$, and
> $\mathcal{E}(\cdot, L)$ has degree at most $L/2 + 1$.

*Proof.* A surjective even closed $L$-walk on $r$ vertices has $|V(w)| = r$, and
Corollary 5.4 forces $2r \leq L + 2$. $\blacksquare$

### 6.3 A uniform bound at all orders

> **Theorem 6.5 (All-order moment bound).** For every $N$ and every $k \geq 0$,
> $$\mathcal{E}(N, 2k+2) \ \leq\ \left(\sum_{r=0}^{k+2} b_{r,\,2k+2}\right) N^{\,k+2}.$$

*Proof.* By Theorems 6.3 and 6.4,
$$\mathcal{E}(N, 2k+2) = \sum_{r=0}^{k+2} \binom{N}{r} b_{r, 2k+2}.$$
For each $r \leq k+2$ we have $\binom{N}{r} \leq N^r \leq N^{k+2}$ when $N \geq 1$
(and the case $N = 0$ is trivial since there are no walks at all). Summing gives the
bound. $\blacksquare$

The constant is explicit and dimension-free: it is the total number of even closed
walk shapes of the given length.

---

## 7. Exact Moments at Orders Two, Four and Six

### 7.1 Order two

> **Proposition 7.1.** A closed $2$-walk $w = (w_0, w_1)$ is even if and only if
> $w_0 \neq w_1$. Hence
> $$\mathcal{E}(N, 2) = N(N-1) = 2\binom{N}{2}.$$

*Proof.* Both steps of a $2$-walk traverse the same unordered pair
$\{w_0, w_1\}$ (the second step goes from $w_1$ back to $w_0$). If $w_0 \neq w_1$
then that pair has multiplicity $2$ and every other pair multiplicity $0$, so the walk
is even; the loop-free condition holds at both steps. Conversely, evenness includes
$w_0 \neq w_1$ as its first clause. There are $N(N-1)$ ordered pairs of distinct
vertices. $\blacksquare$

Correspondingly $\mathbb{E}[\operatorname{tr}(W^2)] = N^2 - N$; in fact
$\operatorname{tr}(W^2) = \sum_{i \neq j} W_{ij}^2 = N(N-1)$ for *every* configuration,
so the second moment is deterministic — a direct manifestation of Case B of the
dichotomy.

### 7.2 Order four

> **Theorem 7.2.** $\ \mathcal{E}(N, 4) = 2\binom{N}{2} + 12\binom{N}{3} = N(N-1)(2N-3)$.

*Proof sketch.* By Theorems 6.3 and 6.4 only $r \leq 3$ contributes. Exhaustive
enumeration over the (small) sets of closed $4$-walks on $r$ labelled vertices gives
$b_{0,4} = b_{1,4} = 0$, $b_{2,4} = 2$, $b_{3,4} = 12$, and $b_{4,4} = 0$ by the degree
bound. The shapes are easy to describe: on two vertices $\{x, y\}$ the even $4$-walks
are the two "back-and-forth twice" walks $xyxy$ and $yxyx$; on three vertices they are
the twelve cyclic-rotation-and-reflection variants of the doubled path $x y x z$,
namely the $3$ choices of the centre vertex, times $2$ orderings of the two leaves,
times $2$ cyclic offsets. Expanding,
$$2\binom{N}{2} + 12\binom{N}{3} = N(N-1) + 2N(N-1)(N-2) = N(N-1)(2N-3).
\qquad \blacksquare$$

### 7.3 Order six

> **Theorem 7.3.** $\ \mathcal{E}(N, 6) = 2\binom{N}{2} + 60\binom{N}{3} + 120\binom{N}{4}$,
> equivalently
> $$\mathcal{E}(N, 6) = (N)_2 + 10 (N)_3 + 5 (N)_4 = N(N-1)\left(5N^2 - 15N + 11\right),$$
> where $(N)_r = N(N-1)\cdots(N-r+1)$ is the falling factorial. Consequently
> $$\mathbb{E}\left[\operatorname{tr}(W^6)\right] = N(N-1)\left(5N^2 - 15N + 11\right)$$
> for every finite $N$.

*Proof sketch.* By the degree bound only $r \leq 4$ contributes. Exhaustive
enumeration of even closed $6$-walks on $r$ labelled vertices gives the shape vector
$$(b_{0,6}, b_{1,6}, b_{2,6}, b_{3,6}, b_{4,6}) = (0, 0, 2, 60, 120),$$
with $b_{5,6} = b_{6,6} = 0$ by Theorem 6.4. Converting the binomial basis to falling
factorials via $\binom{N}{r} = (N)_r / r!$ gives $2/2! = 1$, $60/3! = 10$,
$120/4! = 5$, and the polynomial identity
$$(N)_2 + 10 (N)_3 + 5 (N)_4 = N(N-1)\left[1 + 10(N-2) + 5(N-2)(N-3)\right]
= N(N-1)(5N^2-15N+11)$$
finishes the computation. $\blacksquare$

The three shape vectors $(2)$, $(2,12)$, $(2, 60, 120)$ are the complete data of the
second, fourth and sixth moments at *all* dimensions simultaneously — a striking
compression, and a consequence of polynomiality.

### 7.4 Sanity checks

Setting $N = 2$: the only closed walks are alternations between the two vertices, so
$\mathcal{E}(2, L) = 2$ for every even $L$, and indeed
$\mathcal{E}(2,4) = 2 \cdot 1 \cdot 1 = 2$ and $\mathcal{E}(2,6) = 2 \cdot 1 \cdot (20-30+11) = 2$.
Setting $N = 1$: no loop-free step exists, $\mathcal{E}(1, L) = 0$, matching the factor
$N-1$. Setting $N = 3$ at length six: $3 \cdot 2 \cdot (45 - 45 + 11) = 66$, which one
can confirm by direct enumeration of the $3^6 = 729$ candidate walks.

---

## 8. Consequences for the Normalised Spectral Moments

### 8.1 Normalisation

The empirical spectral distribution of $W/\sqrt{N}$ has $m$-th moment
$$M_m(g) \ =\ \frac{1}{N}\operatorname{tr}\left(\frac{W(g)}{\sqrt N}\right)^{m}
\ =\ \frac{1}{N^{1 + m/2}} \operatorname{tr}\left(W(g)^m\right).$$
By Theorem 3.2,
$$\mathbb{E}[M_m] = \frac{\mathcal{E}(N, m)}{N^{1 + m/2}}. \tag{8.1}$$

### 8.2 Uniform boundedness at all orders

> **Theorem 8.1 (Uniform bound on all even normalised moments).** For every $k \geq 0$
> and every $N \geq 1$,
> $$\mathbb{E}\left[M_{2k+2}\right] \ \leq\ \sum_{r=0}^{k+2} b_{r,\,2k+2},$$
> a constant independent of $N$.

*Proof.* With $m = 2k+2$, (8.1) reads $\mathbb{E}[M_m] = \mathcal{E}(N, 2k+2) /
N^{k+2}$, and Theorem 6.5 bounds the numerator by $\left(\sum_r b_{r,2k+2}\right)
N^{k+2}$. $\blacksquare$

This is the tightness input to the moment method, obtained here with an *explicit
combinatorial constant* and valid at every order and every dimension. Combined with
the exact vanishing of the odd moments (Theorem 4.1), it says that the expected
spectral measure of $W/\sqrt N$ is, uniformly in $N$, a symmetric measure with
uniformly bounded even moments.

### 8.3 Order six, exactly and in the limit

> **Theorem 8.2 (Exact sixth normalised moment).** For every $N \geq 1$,
> $$\mathbb{E}\left[M_6\right] = \frac{(N-1)\left(5N^2 - 15N + 11\right)}{N^3}
> = 5 - \frac{20}{N} + \frac{26}{N^2} - \frac{11}{N^3}.$$

*Proof.* Substitute Theorem 7.3 into (8.1) with $m = 6$: the normalisation is
$N^{1 + 3} = N^4$, and $N(N-1)(5N^2-15N+11)/N^4$ gives the stated expression. The
expansion follows by dividing out. $\blacksquare$

> **Corollary 8.3 (Semicircle law at order six).**
> $$\lim_{N \to \infty} \mathbb{E}\left[M_6\right] = 5 = C_3,$$
> the sixth moment of the standard semicircle distribution on $[-2, 2]$, whose
> $2k$-th moment is the Catalan number $C_k = \frac{1}{k+1}\binom{2k}{k}$.

The same computation at orders two and four gives
$$\mathbb{E}[M_2] = \frac{N-1}{N} \to 1 = C_1, \qquad
\mathbb{E}[M_4] = \frac{(N-1)(2N-3)}{N^2} \to 2 = C_2.$$
The finite-$N$ defects are $-1/N$, $-5/N + O(N^{-2})$ and $-20/N + O(N^{-2})$
respectively: the convergence is $O(1/N)$ at every order computed, with an explicitly
computable constant.

---

## 9. The Catalan Law for Top Shapes

### 9.1 The extremal shapes

Theorem 6.4 says the shape counts of length $2k$ vanish for $r > k+1$. The *top*
shape count $b_{k+1,\,2k}$ therefore governs the leading coefficient of the moment
polynomial: since $\binom{N}{k+1} = N^{k+1}/(k+1)! + O(N^k)$,
$$\mathcal{E}(N, 2k) = \frac{b_{k+1,\,2k}}{(k+1)!}\,N^{k+1} + O(N^{k}),
\qquad \text{hence} \qquad
\lim_{N\to\infty}\mathbb{E}[M_{2k}] = \frac{b_{k+1,\,2k}}{(k+1)!}. \tag{9.1}$$

> **Conjecture 9.1 (Catalan law for top shapes).** For every $k \geq 1$,
> $$b_{k+1,\,2k} = C_k \cdot (k+1)!, \qquad C_k = \frac{1}{k+1}\binom{2k}{k}.$$
> Equivalently, by (9.1), the leading coefficient of the moment polynomial
> $\mathcal{E}(\cdot, 2k)$ is the Catalan number $C_k$, and every even normalised
> moment converges to the corresponding semicircle moment.

### 9.2 Verified cases and the structural argument

The conjecture holds at the orders accessible by exhaustive enumeration:
$$b_{2,2} = 2 = C_1 \cdot 2! = 1 \cdot 2, \qquad
b_{3,4} = 12 = C_2 \cdot 3! = 2 \cdot 6, \qquad
b_{4,6} = 120 = C_3 \cdot 4! = 5 \cdot 24.$$

The structural reason is a rigidity phenomenon. Let $w$ be a surjective even closed
$2k$-walk on $k+1$ vertices. Corollary 5.4 gives $2(k+1) \leq 2k + 2$ with equality,
so both inequalities in its proof are tight: $|E(w)| = k$ exactly (Theorem 5.2 is
tight, so every traversed edge has multiplicity exactly $2$), and $|V(w)| = |E(w)| + 1$
exactly (Theorem 5.3 is tight, so the discovery edges exhaust $E(w)$). A connected
graph on $k+1$ vertices with $k$ edges is a tree; hence the walk traverses a spanning
tree of its vertex set, each edge exactly twice.

A closed walk on a tree that uses each edge exactly twice is precisely a *contour
traversal*: starting at $w(0)$, the walk performs a depth-first exploration in which
each edge is descended once and ascended once. Recording a descent as an opening
bracket and an ascent as a closing bracket produces a balanced sequence of $k$ pairs
of brackets — a Dyck path of semilength $k$ — and the correspondence is bijective on
plane trees rooted at $w(0)$. The number of Dyck paths of semilength $k$ is $C_k$, and
the $(k+1)!$ factor accounts for the assignment of the $k+1$ labels to the $k+1$
nodes of the plane tree.

Making the last paragraph fully rigorous — in particular the passage from "walk on a
tree using each edge twice" to "contour traversal", including the cyclic base point
bookkeeping — is the one gap between the structural results proved here and a complete
combinatorial proof of the semicircle law for this ensemble.

---

## 10. Algorithms

The theory above is effectively computable, and several of the constants have been
obtained by direct enumeration. We record the algorithms.

### 10.1 Direct enumeration of even closed walks

To compute $\mathcal{E}(N, L)$ one iterates over all $N^L$ functions
$w : \mathbb{Z}/L \to V$, rejects those with $w(t) = w(t+1)$ for some $t$, tallies the
multiset of edges $\{w(t), w(t+1)\}$, and accepts if all multiplicities are even. The
cost is $O(N^L \cdot L)$ time and $O(L)$ space. With early rejection at the first loop
step the practical cost is far smaller — the loop-free walks number $N(N-1)^{L-1}$ at
most, and pruning on parity is possible as well.

### 10.2 Shape counts by surjectivity filtering

$b_{r, L}$ is computed by the same enumeration restricted to $V = \{1, \dots, r\}$
together with the surjectivity test $|V(w)| = r$. Since $b_{r,L}$ is $N$-independent
and vanishes for $2r > L+2$, the finite table $\{b_{r,L}\}_{2r \leq L+2}$ determines
$\mathcal{E}(\cdot, L)$ completely, so one enumerates on at most $L/2 + 1$ vertices
rather than on $N$: the cost drops from $O(N^L)$ to $O((L/2+1)^L)$, independent of $N$.

An equivalent route uses inclusion–exclusion,
$$b_{r,L} = \sum_{j=0}^{r} (-1)^{r-j}\binom{r}{j}\,\mathcal{E}(j, L),$$
the Möbius inversion of Theorem 6.3, which turns a table of small-$N$ walk counts into
the shape vector.

### 10.3 Ensemble averaging by brute force

For small $N$ one can verify Theorem 3.2 directly: enumerate all $2^{\binom{N}{2}}$
sign configurations, build $W$, compute $\operatorname{tr}(W^L)$ by repeated matrix
multiplication in $O(N^3 \log L)$, and average. The cost is
$O\!\left(2^{\binom{N}{2}} N^3 \log L\right)$, which is feasible up to $N = 5$
($2^{10} = 1024$ configurations) and $N = 6$ ($2^{15} = 32768$).

### 10.4 Moment polynomial assembly

Given the shape vector $(b_{r,L})_r$, the moment polynomial is assembled as
$\sum_r b_{r,L} \binom{N}{r}$ and converted to the monomial basis in $O(L^2)$ integer
operations via falling factorials, $\binom{N}{r} = (N)_r / r!$. This yields, for
example, $(2, 60, 120) \mapsto N(N-1)(5N^2-15N+11)$.

---

## 11. Applications and Interpretation

**Finite-size corrections.** Because the moments are exact polynomials, the finite-$N$
corrections to the semicircle law can be read off rather than estimated. At order six,
the defect $-20/N$ dominates: at $N = 100$ the expected sixth normalised moment is
$4.8026$, some $4\%$ below the limit. Practitioners who fit spectra of moderate-size
random matrices frequently observe exactly this kind of $O(1/N)$ bias, and the
polynomial expansion identifies its coefficient.

**Exactly symmetric spectra in expectation.** The identical vanishing of all odd
moments at every $N$ means that the *expected* spectral measure of $W/\sqrt N$ is
exactly symmetric about zero — not approximately, not in the limit. Any observed
asymmetry in a single sample is pure fluctuation.

**Deterministic low moments.** $\operatorname{tr}(W^2) = N(N-1)$ holds configuration
by configuration. Any statistic built from the second moment alone carries no
information about the particular sign pattern — a useful null baseline in applications
such as null models for network spectra.

**A rigorously enumerable moment method.** The passage from probability to enumeration
is lossless here, so questions about the spectrum of this ensemble can be attacked by
integer computation. The shape vectors, being $N$-independent, are finite certificates
for infinitely many dimensions at once.

---

## 12. Discussion

The results here are organised around a single principle: for the symmetric coin-flip
ensemble, expectation is enumeration. Once that principle is isolated — as the
dichotomy of Theorem 2.1 — everything else is combinatorics, and the combinatorics is
of the pleasant kind: parity arguments, injections, and involutions.

Three features distinguish this development from the classical moment method.

*Exactness at finite $N$.* Theorems 3.2, 4.1, 7.1–7.3 and 8.2 are equalities at every
dimension. Where the classical theory says "asymptotically", the coin-flip case says
"identically".

*Structure before computation.* The vertex bound (Corollary 5.4) and relabelling
invariance (Theorem 5.5) together yield polynomiality (Theorem 6.3) without computing
a single moment. Polynomiality then makes finitely many exhaustive enumerations
sufficient to determine a moment for *all* $N$.

*Explicit constants.* The uniform moment bound (Theorem 8.1) has an explicit
combinatorial constant, namely the total number of shapes; no unspecified $C_k$ is
needed.

The limitation is equally clear. The dichotomy is a special feature of $\pm 1$ entries
with a zero diagonal. For Gaussian entries the even-multiplicity monomials produce
products of moments rather than the constant $1$, and the exact statements degrade to
asymptotic ones — though the *combinatorial skeleton* (walks, edge multiplicities,
the vertex bound, the tree rigidity at the top order) is identical, which is why the
Catalan numbers appear universally.

---

## 13. Future Directions

**1. The Catalan law for top shapes (Conjecture 9.1).** Prove
$b_{k+1, 2k} = C_k \cdot (k+1)!$ in general. The two hard structural ingredients are
already available: the vertex bound forces exactly $k$ edges of multiplicity exactly
two forming a spanning tree, and relabelling invariance reduces the count to unlabelled
shapes. What remains is the bijection between cyclic contour traversals of doubled
plane trees and Dyck paths of semilength $k$.

**2. All-order semicircle convergence in expectation.** With Conjecture 9.1 in hand,
polynomiality reduces the limit of $\mathbb{E}[M_{2k}]$ to a single coefficient, and
the conclusion $\mathbb{E}[M_m] \to$ (semicircle $m$-th moment) follows for every $m$,
the odd case already being exact.

**3. Subleading coefficients and the $1/N$ expansion.** The full shape vector encodes
more than the limit: the coefficient of $N^{k}$ in $\mathcal{E}(N,2k)$ is the next
shape count, and the sequence of corrections is a genus-type expansion. Computing
$b_{k, 2k}$ in closed form would give the universal $1/N$ correction to every even
moment.

**4. Concentration and almost-sure statements.** The present results are about
expectations. Variance computations require the dichotomy applied to pairs of walks —
which is again exactly a walk count, this time of even closed walks in a doubled index
set — and should yield exact variance polynomials, hence Borel–Cantelli arguments with
explicit constants.

**5. Sparse and structured variants.** Restricting the walk alphabet to the edges of a
fixed host graph $G$ gives $\mathbb{E}[\operatorname{tr}(W_G^L)]$ as a count of even
closed walks *in $G$*. The vertex bound and relabelling invariance survive; the shape
decomposition becomes a homomorphism count, connecting the spectra of signed graphs to
graph-homomorphism combinatorics.

**6. Higher-order shape tables.** Exhaustive enumeration is feasible some way beyond
length six; each new shape vector yields a new exact moment polynomial for all $N$
simultaneously. Symmetry reduction (cyclic rotations, reflections, tree canonical
forms) should push the reachable order considerably further.

---

## 14. Summary of Results

| Result | Statement |
|---|---|
| Exact Ensemble Dichotomy | $\mathbb{E}\!\left[\prod_t W_{a_t b_t}\right] = 1$ if loop-free with all multiplicities even, else $0$ |
| Walk-Counting Theorem | $\mathbb{E}[\operatorname{tr}(W^L)] = \mathcal{E}(N,L)$ for all $N, L$ |
| Odd vanishing | $\mathcal{E}(N, 2k+1) = 0$; all odd moments vanish exactly at finite $N$ |
| Edge bound | even closed $L$-walk uses $\leq L/2$ distinct edges |
| Vertex bound | even closed $L$-walk visits $\leq L/2 + 1$ distinct vertices |
| Relabelling invariance | evenness is preserved and reflected by injective vertex maps |
| Polynomiality | $\mathcal{E}(N,L) = \sum_r \binom{N}{r} b_{r,L}$, $b_{r,L} = 0$ for $2r > L+2$ |
| All-order bound | $\mathcal{E}(N, 2k+2) \leq \left(\sum_r b_{r,2k+2}\right)N^{k+2}$ |
| Order two | $\mathcal{E}(N,2) = N(N-1)$ (deterministic) |
| Order four | $\mathcal{E}(N,4) = N(N-1)(2N-3) = 2\binom N2 + 12\binom N3$ |
| Order six | $\mathcal{E}(N,6) = N(N-1)(5N^2-15N+11) = 2\binom N2 + 60\binom N3 + 120\binom N4$ |
| Uniform moment bound | $\mathbb{E}[M_{2k+2}] \leq \sum_r b_{r,2k+2}$, independent of $N$ |
| Sixth moment limit | $\mathbb{E}[M_6] = 5 - 20/N + 26/N^2 - 11/N^3 \to 5 = C_3$ |
| Top shapes | $b_{2,2} = 2$, $b_{3,4} = 12$, $b_{4,6} = 120$, i.e. $C_k (k+1)!$ for $k \le 3$ |
