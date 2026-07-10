# Vanishing Cyclically Covering Codimension is Equivalent to the Full-Weight Property of Cyclic Codes

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

Let $q$ be a prime power and $n$ a positive integer, and consider the space
$V = \mathbb{F}_q^n$ of $q$-ary words of length $n$, indexed by the cyclic group
$\mathbb{Z}/n\mathbb{Z}$. A subspace $U \subseteq V$ is *cyclically covering* if
every word of $V$ can be rotated into $U$; the invariant $h_q(n)$ is the maximum
codimension attained by such a subspace. Separately, a *cyclic code* is a
rotation-invariant subspace of $V$, and a codeword has *full Hamming weight* if
all of its coordinates are nonzero. We prove that these two notions meet in a
single exact equivalence:
$$h_q(n) = 0 \quad\Longleftrightarrow\quad \text{every nonzero cyclic code in } \mathbb{F}_q^n \text{ contains a full-weight codeword}.$$
The proof proceeds through a correlation (Fourier-type) transform $\Phi_a$ whose
image is always a cyclic code and whose associated orthogonal hyperplane is
cyclically covering precisely when that image omits every full-weight word. A
coordinate-reversal device converts an arbitrary prescribed cyclic code into the
image of such a transform, closing the equivalence. The argument requires only
that the scalar ring be a field; finiteness of $\mathbb{F}_q$ is not used, so the
theorem holds verbatim over any field $K$.

## 1. Introduction

Two extremal questions, drawn from combinatorial geometry and from algebraic
coding theory, turn out to be one and the same.

**Covering side.** Fix the linear cyclic shift on $V = \mathbb{F}_q^n$. A
subspace $U$ is *cyclically covering* when the shifts of $U$ exhaust $V$: every
$x \in V$ has some shift landing in $U$. The whole space is covering; the
substantive question is how *thin* a covering subspace can be. Writing the
thinness of a subspace as its codimension $\operatorname{codim} U = n - \dim U$,
one sets
$$h_q(n) = \max\{\operatorname{codim} U : U \subseteq V \text{ cyclically covering}\}.$$
This quantity has been studied in combinatorics in connection with covering
radii and normalized covering codimension. The extreme case $h_q(n) = 0$ says the
only cyclically covering subspace is $V$ itself: covering is maximally rigid.

**Coding side.** A *cyclic code* $C \subseteq V$ is a subspace invariant under
the shift — equivalently, an ideal of the quotient ring
$\mathbb{F}_q[x]/(x^n-1)$. A codeword $c$ has *full Hamming weight* when
$c_i \neq 0$ for all $i$. We say $\mathbb{F}_q^n$ has the **full-weight property**
if every nonzero cyclic code contains at least one full-weight codeword.

The purpose of this paper is to establish, with a self-contained proof, the
following bridge.

> **Main Theorem.** $h_q(n) = 0$ if and only if $\mathbb{F}_q^n$ has the
> full-weight property.

The mechanism is a correlation transform reminiscent of the discrete Fourier
transform, and the proof is elementary linear algebra once the transform's two
key properties are isolated. We work throughout over an arbitrary field $K$ in
place of $\mathbb{F}_q$; the classical statement is the case $K = \mathbb{F}_q$.

## 2. Setup and definitions

Throughout, $n \geq 1$, $K$ is a field, and
$$V = K^{\,\mathbb{Z}/n\mathbb{Z}}$$
is the space of functions $x : \mathbb{Z}/n\mathbb{Z} \to K$, i.e. words of
length $n$ indexed cyclically. We write $x_i$ for $x(i)$.

**Definition 2.1 (Cyclic shift).** For $k \in \mathbb{Z}/n\mathbb{Z}$, the shift
$\mathrm{rot}_k : V \to V$ is the linear map
$$(\mathrm{rot}_k\, x)_i = x_{i+k}.$$
It satisfies $\mathrm{rot}_k \circ \mathrm{rot}_\ell = \mathrm{rot}_{k+\ell}$ and
$\mathrm{rot}_0 = \mathrm{id}$, so $k \mapsto \mathrm{rot}_k$ is a linear action
of $\mathbb{Z}/n\mathbb{Z}$ on $V$.

**Definition 2.2 (Reversal).** The reversal $\mathrm{rev} : V \to V$ is the
linear map $(\mathrm{rev}\, x)_i = x_{-i}$. It is an involution and is nonzero on
nonzero inputs.

**Definition 2.3 (Pairing and functionals).** The standard bilinear pairing is
$$\langle a, x\rangle = \sum_{i \in \mathbb{Z}/n\mathbb{Z}} a_i\, x_i.$$
For fixed $a$ this defines a linear functional $\mathrm{pair}(a) : V \to K$,
$x \mapsto \langle a, x\rangle$. Conversely, to any functional $f : V \to K$ we
associate its *coefficient vector* $\mathrm{coeff}(f) \in V$ by
$\mathrm{coeff}(f)_i = f(e_i)$, where $e_i$ is the standard basis word with a
single $1$ in position $i$.

**Definition 2.4 (Full weight).** A word $c \in V$ has *full Hamming weight* if
$c_i \neq 0$ for every $i$. We abbreviate this predicate $\mathrm{FullWeight}(c)$.

**Definition 2.5 (Cyclic code).** A subspace $C \subseteq V$ is a *cyclic code*
if $\mathrm{rot}_1(C) \subseteq C$; equivalently (Lemma 3.1) $\mathrm{rot}_k(C)
\subseteq C$ for all $k$.

**Definition 2.6 (Cyclically covering subspace).** A subspace $U \subseteq V$ is
*cyclically covering* if for every $x \in V$ there exists $k \in
\mathbb{Z}/n\mathbb{Z}$ with $\mathrm{rot}_k(x) \in U$.

**Definition 2.7 (The invariants).** We say $h_q(n) = 0$ holds (predicate
$\mathrm{hZero}$) if the only cyclically covering subspace of $V$ is $V$ itself.
We say $\mathbb{F}_q^n$ has the *full-weight property* if every cyclic code $C$
with $C \neq \{0\}$ contains a full-weight codeword.

The identification of "$\mathrm{hZero}$" with "$h_q(n) = 0$" is justified because
$h_q(n)$ is the maximum codimension of a covering subspace, and this maximum is
$0$ exactly when no proper (positive-codimension) covering subspace exists, i.e.
when every covering subspace is all of $V$.

## 3. Preliminaries on the shift

**Lemma 3.1 (Shift-invariance of cyclic codes).** If $C$ is a cyclic code and
$x \in C$, then $\mathrm{rot}_k(x) \in C$ for every $k \in \mathbb{Z}/n\mathbb{Z}$.

*Proof.* By induction on $m \in \mathbb{N}$ one shows
$\mathrm{rot}_{m}(x) \in C$, using $\mathrm{rot}_0 = \mathrm{id}$ and
$\mathrm{rot}_{m+1}(x) = \mathrm{rot}_1(\mathrm{rot}_m(x)) \in C$ from the
defining closure under $\mathrm{rot}_1$. Since every $k \in
\mathbb{Z}/n\mathbb{Z}$ is the image of its natural-number representative,
$\mathrm{rot}_k(x) \in C$. $\qquad\blacksquare$

**Lemma 3.2 (Monotonicity of covering).** If $U \subseteq W$ and $U$ is
cyclically covering, then $W$ is cyclically covering.

*Proof.* Immediate: a shift of $x$ landing in $U$ also lands in the larger
$W$. $\qquad\blacksquare$

**Lemma 3.3 (Recovering functionals).** For any functional $f : V \to K$ we have
$\mathrm{pair}(\mathrm{coeff}(f)) = f$. Consequently $\mathrm{coeff}(f) \neq 0$
whenever $f \neq 0$, and $\mathrm{pair}(a) \neq 0$ whenever $a \neq 0$.

*Proof.* Write $x = \sum_i x_i\, e_i$. Linearity gives
$f(x) = \sum_i x_i f(e_i) = \sum_i x_i\,\mathrm{coeff}(f)_i =
\langle \mathrm{coeff}(f), x\rangle = \mathrm{pair}(\mathrm{coeff}(f))(x)$.
The non-vanishing statements follow: if $\mathrm{coeff}(f) = 0$ then
$f = \mathrm{pair}(0) = 0$; and $\mathrm{pair}(a)(e_j) = a_j$, so
$\mathrm{pair}(a) = 0$ forces every $a_j = 0$. $\qquad\blacksquare$

**Lemma 3.4 (Separation by a functional).** If $U \subsetneq V$ is a proper
subspace, then there is a nonzero functional $f : V \to K$ vanishing on $U$.

*Proof.* Since $U \neq V$, the quotient $V/U$ is nontrivial, so it carries a
nonzero functional $g : V/U \to K$. The composite $f = g \circ \pi$ with the
canonical projection $\pi : V \to V/U$ is a nonzero functional vanishing on
$U$. $\qquad\blacksquare$

## 4. The correlation transform and the core bridge

**Definition 4.1 (Correlation transform).** For $a \in V$ define the linear map
$\Phi_a : V \to V$ by
$$\Phi_a(x)_k = \langle a,\; \mathrm{rot}_k(x)\rangle = \sum_i a_i\, x_{i+k}.$$
This is the sliding correlation of $x$ against $a$: coordinate $k$ of the output
records the inner product of $a$ with the $k$-shift of $x$.

**Lemma 4.2 (Equivariance).** $\Phi_a$ intertwines the shift:
$\Phi_a(\mathrm{rot}_1 x) = \mathrm{rot}_1(\Phi_a(x))$.

*Proof.* For each $k$,
$\Phi_a(\mathrm{rot}_1 x)_k = \langle a, \mathrm{rot}_k \mathrm{rot}_1 x\rangle
= \langle a, \mathrm{rot}_{k+1} x\rangle = \Phi_a(x)_{k+1}
= (\mathrm{rot}_1 \Phi_a(x))_k$. $\qquad\blacksquare$

**Proposition 4.3 (Image is a cyclic code).** For every $a \in V$, the image
$\Phi_a(V)$ is a cyclic code.

*Proof.* The image of any linear map is a subspace. Closure under $\mathrm{rot}_1$
follows from Lemma 4.2: if $w = \Phi_a(y)$ then
$\mathrm{rot}_1 w = \mathrm{rot}_1 \Phi_a(y) = \Phi_a(\mathrm{rot}_1 y) \in
\Phi_a(V)$. $\qquad\blacksquare$

**Proposition 4.4 (Nontriviality).** If $a \neq 0$ then $\Phi_a(V) \neq \{0\}$.

*Proof.* If $\Phi_a \equiv 0$ then in particular
$0 = \Phi_a(y)_0 = \langle a, \mathrm{rot}_0 y\rangle = \langle a, y\rangle$ for
all $y$, so $\mathrm{pair}(a) = 0$, whence $a = 0$ by Lemma 3.3. Contrapositively,
$a \neq 0$ gives $\Phi_a \not\equiv 0$, i.e. $\Phi_a(V) \neq \{0\}$.
$\qquad\blacksquare$

The following proposition is the technical heart of the paper. It converts a
covering statement about the orthogonal hyperplane of $a$ into a full-weight
statement about the code $\Phi_a(V)$.

**Proposition 4.5 (Core bridge).** For every $a \in V$,
$$\ker \langle a, \cdot\rangle \text{ is cyclically covering}
\quad\Longleftrightarrow\quad
\Phi_a(V) \text{ contains no full-weight word}.$$

*Proof.* Unfold both sides.

($\Rightarrow$) Suppose the hyperplane $H = \ker \langle a,\cdot\rangle$ is
covering, and let $w = \Phi_a(x) \in \Phi_a(V)$ be arbitrary. Covering supplies
$k$ with $\mathrm{rot}_k(x) \in H$, i.e. $\langle a, \mathrm{rot}_k(x)\rangle = 0$.
But $\langle a, \mathrm{rot}_k(x)\rangle = \Phi_a(x)_k = w_k$, so $w_k = 0$ and
$w$ is not full-weight.

($\Leftarrow$) Suppose $\Phi_a(V)$ has no full-weight word, and let $x \in V$. The
word $\Phi_a(x)$ lies in $\Phi_a(V)$, hence is not full-weight, so some
coordinate vanishes: $\Phi_a(x)_k = 0$ for some $k$. That is
$\langle a, \mathrm{rot}_k(x)\rangle = 0$, i.e. $\mathrm{rot}_k(x) \in H$. As $x$
was arbitrary, $H$ is covering. $\qquad\blacksquare$

To exploit the core bridge in the direction "codes control covering," we must be
able to realize an *arbitrary prescribed* cyclic code as (a subcode of) the image
of some $\Phi_a$. This is what the reversal accomplishes.

**Proposition 4.6 (Reversal lands in the code).** Let $C$ be a cyclic code and
$c \in C$. Then for every $x \in V$,
$$\Phi_{\mathrm{rev}(c)}(x) = \sum_{j \in \mathbb{Z}/n\mathbb{Z}} x_j\,
\mathrm{rot}_{-j}(c) \;\in\; C.$$

*Proof.* Compute coordinate $k$ of the left side:
$$\Phi_{\mathrm{rev}(c)}(x)_k
= \sum_i (\mathrm{rev}\,c)_i\,(\mathrm{rot}_k x)_i
= \sum_i c_{-i}\, x_{i+k}.$$
Reindexing the sum by $i \mapsto i + k$ (a bijection of
$\mathbb{Z}/n\mathbb{Z}$) turns this into
$\sum_j x_j\, c_{k - j} = \sum_j x_j\,(\mathrm{rot}_{-j} c)_k$, which is precisely
coordinate $k$ of $\sum_j x_j\,\mathrm{rot}_{-j}(c)$. Thus the identity holds
coordinatewise. Each $\mathrm{rot}_{-j}(c) \in C$ by Lemma 3.1, and $C$ is closed
under $K$-linear combinations, so the sum lies in $C$. $\qquad\blacksquare$

In particular $\Phi_{\mathrm{rev}(c)}(V) \subseteq C$: the image of the
correlation transform against the reversed generator is contained in the code
generated by $c$.

## 5. The main theorem

**Theorem 5.1 (Bridge Theorem).** $h_q(n) = 0$ if and only if $\mathbb{F}_q^n$
has the full-weight property. More generally, for any field $K$, the only
cyclically covering subspace of $V = K^{\mathbb{Z}/n\mathbb{Z}}$ is $V$ itself if
and only if every nonzero cyclic code in $V$ contains a full-weight codeword.

*Proof.*

**($\Rightarrow$) Rigidity of covering implies full-weight richness.** Assume the
only cyclically covering subspace is $V$. Let $C$ be a nonzero cyclic code, and
suppose toward a contradiction that $C$ contains no full-weight word. Choose a
nonzero $c \in C$ and set $a = \mathrm{rev}(c)$, which is nonzero because
reversal is injective on nonzero words. By Proposition 4.6 every element of
$\Phi_a(V)$ lies in $C$, and since $C$ has no full-weight word, neither does
$\Phi_a(V)$. The core bridge (Proposition 4.5) then makes
$\ker \langle a, \cdot\rangle$ cyclically covering. By hypothesis this forces
$\ker \langle a, \cdot\rangle = V$, i.e. $\mathrm{pair}(a) = 0$, contradicting
$a \neq 0$ via Lemma 3.3. Hence $C$ must contain a full-weight word.

**($\Leftarrow$) Full-weight richness implies rigidity of covering.** Assume
every nonzero cyclic code has a full-weight word. Let $U$ be a cyclically
covering subspace and suppose toward a contradiction that $U \neq V$. By Lemma
3.4 there is a nonzero functional $f$ vanishing on $U$; write $a = \mathrm{coeff}(f)$,
so $\mathrm{pair}(a) = f$ (Lemma 3.3) and $a \neq 0$. Since $f$ vanishes on $U$,
we have $U \subseteq \ker \langle a, \cdot\rangle$, and by monotonicity (Lemma
3.2) the hyperplane $\ker \langle a, \cdot\rangle$ is covering. The core bridge
gives that $\Phi_a(V)$ has no full-weight word. But $\Phi_a(V)$ is a nonzero
cyclic code (Propositions 4.3 and 4.4), so by hypothesis it *does* contain a
full-weight word — a contradiction. Hence $U = V$, and no proper covering
subspace exists, i.e. $h_q(n) = 0$. $\qquad\blacksquare$

**Remark 5.2 (Role of the field hypothesis).** The proof uses only field
structure: Lemma 3.4 relies on the existence of a nonzero functional on any
nontrivial quotient (a vector-space fact), and Lemma 3.3 on expressing a word in
the standard basis. Finiteness of $\mathbb{F}_q$ is never invoked, so Theorem 5.1
holds over every field $K$.

**Remark 5.3 (What the transform computes).** Combining Proposition 4.6 with
Proposition 4.4, the image $\Phi_{\mathrm{rev}(c)}(V)$ is exactly the cyclic code
generated by $c$, i.e. the span of the rotations of $c$. Thus $\Phi$ furnishes an
explicit surjection from words onto single-generator cyclic codes, and the
covering behavior of the orthogonal hyperplane of $\mathrm{rev}(c)$ reads off the
full-weight status of $\langle c\rangle$.

## 6. Worked example: binary length three

Take $K = \mathbb{F}_2$ and $n = 3$. The *even-weight code*
$$C_{\mathrm{ev}} = \{x \in \mathbb{F}_2^3 : x_0 + x_1 + x_2 = 0\}
= \{000, 110, 101, 011\}$$
is cyclic (rotation preserves the coordinate sum) and nonzero. Its four words
have Hamming weights $0, 2, 2, 2$; the unique full-weight candidate $111$ has
coordinate sum $1 \neq 0$ and is absent. Hence $C_{\mathrm{ev}}$ is a nonzero
cyclic code with no full-weight codeword, so the full-weight property *fails*.

By Theorem 5.1, $h_2(3) \neq 0$: there must exist a proper cyclically covering
subspace. Note that the even-weight code $C_{\mathrm{ev}} = \ker\langle (1,1,1),
\cdot\rangle$ is *not* itself covering: rotation preserves the coordinate sum, so
the odd-sum word $111$ cannot be rotated into $C_{\mathrm{ev}}$. The covering
witness is produced by the reversal construction of Theorem 5.1. Take the nonzero
word $c = (1,1,0) \in C_{\mathrm{ev}}$; its reversal is $a = \mathrm{rev}(c) =
(1,0,1)$. Since $\Phi_a(V) = \langle c\rangle \subseteq C_{\mathrm{ev}}$ (Remark
5.3) has no full-weight word, Proposition 4.5 makes the hyperplane
$\ker\langle (1,0,1),\cdot\rangle = \{x_0 + x_2 = 0\}$ cyclically covering:
explicitly, for every $x$ there is a rotation $k$ with $x_k = x_{k+2}$. This
hyperplane has codimension $1$, giving $h_2(3) \geq 1$; a dimension count shows
$h_2(3) = 1$. The failure of code-richness and the existence of a thin covering
subspace are two readings of the same fact.

The example generalizes: whenever $x^n - 1$ acquires a repeated factor over
$\mathbb{F}_q$ (equivalently, when $\gcd(n, q) > 1$), degenerate cyclic codes
such as the even-weight code appear, code-richness fails, and $h_q(n) \geq 1$.

## 7. Algorithms

The equivalence is effective and yields three complementary decision procedures
over small parameters.

**(A) Testing whether a hyperplane is covering.** Given $a \neq 0$, iterate over
all words $x \in V$; for each, search the $n$ rotations for one with
$\langle a, \mathrm{rot}_k x\rangle = 0$. The hyperplane is covering iff every $x$
succeeds. Complexity $O(q^n \cdot n^2)$.

**(B) Deciding $h_q(n) = 0$ via hyperplanes.** Because every proper subspace lies
in a hyperplane and covering is monotone (Lemma 3.2), $h_q(n) = 0$ holds iff no
hyperplane $\ker\langle a,\cdot\rangle$ (with $a \neq 0$) is covering. Enumerate
$a$ over projective directions and apply (A). Complexity $O(q^n \cdot q^n \cdot n^2)$.

**(C) Deciding the full-weight property via cyclic codes.** Cyclic codes
correspond to divisors of $x^n - 1$ over $\mathbb{F}_q$; enumerate them and, for
each nonzero code, test whether any codeword is full-weight. The property holds
iff all pass. Comparing the outputs of (B) and (C) confirms Theorem 5.1
numerically.

## 8. Applications and discussion

Cyclic codes underlie Reed–Solomon, BCH, and CRC constructions in storage and
communication; full-weight codewords are the maximally dispersed members of such
codes and are relevant to constant-weight and covering-radius questions. The
covering invariant $h_q(n)$ arises in combinatorial geometry as a measure of how
constrained a subspace may be while still covering the ambient space under a
group action. Theorem 5.1 shows these two literatures are computing a single
boundary phenomenon from opposite sides, and each concrete instance on one side
manufactures one on the other (Section 6). The correlation transform $\Phi_a$ is
a matched-filter / sliding-correlation operator, tying the result to signal
processing intuition.

## 9. Future directions

1. **Quantitative version.** Formalize $h_q(n)$ as an explicit natural number
   (maximum codimension) and prove the sharper identity
   $h_q(n) = n - \max\{\dim C : C \text{ cyclic with no full-weight codeword}\}$,
   refining the present $=0$ boundary case into an exact formula.

2. **Positivity criteria.** Prove $h_q(n) \geq 1$ whenever $n$ is not coprime to
   $q$ — more generally, whenever $x^n - 1$ has a nontrivial repeated factor —
   using the even-weight code as an explicit witness, as in the $n = 3$ example.

3. **Known values.** Establish small exact values such as $h_2(3) = 1$ and the
   coprime cases $h_q(n) = 0$ in which every nonzero cyclic code is full-weight.

4. **Reversal-free bridge.** Package the correspondence $a \mapsto \langle a\rangle$
   (single-generator cyclic code) as an explicit bijection between covering
   hyperplanes and nonzero cyclic codes without full-weight words, via the ring
   $\mathbb{F}_q[x]/(x^n - 1)$, avoiding the coordinate reversal.

5. **Ring-theoretic refactor.** Recast cyclic codes as ideals of
   $\mathbb{F}_q[x]/(x^n - 1)$ and the shift as multiplication by $x$, connecting
   to BCH/Reed–Solomon theory and to the standard polynomial machinery.

6. **Covering-code connections.** Relate $h_q(n)$ to covering radii and to the
   normalized-covering-codimension lower bounds studied by Cameron–Ellis–Raynaud,
   opening a path toward asymptotic estimates.
