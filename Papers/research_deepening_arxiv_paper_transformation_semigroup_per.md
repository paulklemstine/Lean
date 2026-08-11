# A Transformation-Semigroup Theory of the Magma Monoid

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Let $X$ be a set and let $\mathrm{Bin}(X)$ denote the set of all binary operations $f : X \times X \to X$, equipped with the associative product
$$(f * g)(a,b) = g\bigl(f(a,b),\, f(b,a)\bigr),$$
introduced by H. S. Kim and J. Neggers. We develop a complete transformation-semigroup theory of this monoid. The central device is the *unfolding* $f \mapsto \widehat f$, $\widehat f(a,b) = (f(a,b), f(b,a))$, which converts $*$ into composition and identifies $\mathrm{Bin}(X)$, anti-isomorphically, with the centralizer of the reversal involution $\sigma(a,b) = (b,a)$ in the full transformation monoid of $X \times X$.

From this identification we obtain: (i) a complete characterization of von Neumann regular elements — $f$ is regular if and only if every *commutative value* $f(x,y) = f(y,x)$ is attained on the diagonal as some $f(z,z)$ — and hence the failure of $\mathrm{Bin}(X)$ to be a regular monoid for $|X| \ge 2$, in contrast with the ambient transformation monoid; (ii) complete criteria for left and right divisibility and for Green's relations $\mathcal{L}$, $\mathcal{R}$, $\mathcal{H}$, $\mathcal{D}$, together with the fact that regularity is a $\mathcal{D}$-class invariant; (iii) the computation of the centre, $Z(\mathrm{Bin}(X)) = \{\ell, r\} \cong \mathbb{Z}/2$ for $|X| \ge 2$, where $\ell$ and $r$ are the two projections; (iv) the identification of the unit group with the centralizer of reversal in $\mathrm{Sym}(X \times X)$ and the exact order $n!\,2^{m}\,m!$ with $m = \binom n 2$ for $|X| = n$; (v) a generalization of the regularity criterion to an arbitrary group action — a $G$-equivariant transformation is regular in the monoid of $G$-equivariant transformations if and only if every image point admits a preimage whose stabilizer contains its own; and (vi) tropical applications: the commutative idempotent operations (in particular $\min$ and $\max$) form a left-zero band contained in a single $\mathcal{L}$-class, while tropical multiplication is regular exactly when the value monoid is $2$-divisible, so that it is regular over $\mathbb{Q}$ and $\mathbb{R}$ but not over $\mathbb{Z}$.

**Keywords:** magma monoid, binary operations, transformation semigroup, Green's relations, von Neumann regularity, equivariant maps, tropical semiring, centralizer of an involution.

---

## 1. Introduction

A *magma* is a set with a binary operation and no axioms. The collection of all magma structures on a fixed carrier set $X$ is enormous — $n^{n^2}$ of them when $|X| = n$ — and structureless until one notices, as Kim and Neggers did, that it carries a natural monoid product. Given two operations $f$ and $g$, define

$$(f*g)(a,b) = g\bigl(f(a,b), f(b,a)\bigr).$$

To evaluate the product at $(a,b)$ one applies $f$ in both argument orders and feeds the pair of results to $g$. The resulting structure $\mathrm{Bin}(X) = (X^{X \times X}, *)$ is the **magma monoid**.

Two facts are immediate and set the stage.

*Associativity.* For all $f,g,h$ and all $a,b$,
$$((f*g)*h)(a,b) = h\bigl(g(f(a,b),f(b,a)),\, g(f(b,a),f(a,b))\bigr) = (f*(g*h))(a,b).$$

*Identity.* The **left projection** $\ell(a,b) = a$ satisfies $\ell * g = g$ and $f * \ell = f$.

The **right projection** $r(a,b) = b$ satisfies $r * g = g * r$ for all $g$ and $r * r = \ell$; it is a central involution.

The aim of this paper is to determine the structure of $\mathrm{Bin}(X)$ completely, using a single organizing principle: $\mathrm{Bin}(X)$ *is* a transformation monoid, namely the monoid of self-maps of $X \times X$ commuting with reversal. Every structural question then becomes a question about images, kernels, and the diagonal, and the diagonal is where all the interesting obstructions live.

### Notation

Throughout, $X$ is an arbitrary set, and:

- $\mathcal{O}(X) = X^{X\times X}$ denotes the set of binary operations, and $\mathrm{Bin}(X)$ the same set with the product $*$;
- $\sigma : X \times X \to X \times X$, $\sigma(a,b) = (b,a)$, is **reversal**;
- $\Delta = \{(x,x) : x \in X\} \subseteq X \times X$ is the **diagonal**, i.e. the fixed-point set of $\sigma$;
- $T(Y)$ is the monoid of all self-maps of $Y$ under composition;
- $\widehat f(a,b) = (f(a,b), f(b,a))$ is the **unfolding** of $f$;
- $\mathrm{Im}(f) = \widehat f(X \times X)$ is the **pair image**;
- $\mathrm{Diag}(f) = \{(f(z,z), f(z,z)) : z \in X\}$ is the **diagonal image**;
- $\mathrm{Com}(f) = \mathrm{Im}(f) \cap \Delta$ is the **commutative image**, the set of image points fixed by $\sigma$.

Note $\mathrm{Diag}(f) \subseteq \mathrm{Com}(f)$ always: $\widehat f(z,z) = (f(z,z), f(z,z))$ is a diagonal point of the image. The reverse inclusion is the crux of the whole theory.

---

## 2. The representation theorem

**Definition 2.1 (Pairmorph).** A map $T : X \times X \to X \times X$ is a **pairmorph**, or *reversal-equivariant*, if $T \circ \sigma = \sigma \circ T$, i.e. $T(b,a) = \sigma(T(a,b))$ for all $a,b$.

**Lemma 2.2.** For every $f \in \mathcal{O}(X)$ the unfolding $\widehat f$ is a pairmorph, and
$$\widehat{f * g} = \widehat g \circ \widehat f .$$

*Proof.* $\widehat f(\sigma(a,b)) = \widehat f(b,a) = (f(b,a), f(a,b)) = \sigma(\widehat f(a,b))$. For the product,
$$\widehat{f*g}(a,b) = \bigl(g(f(a,b),f(b,a)),\, g(f(b,a),f(a,b))\bigr) = \widehat g\bigl(f(a,b), f(b,a)\bigr) = \widehat g (\widehat f(a,b)). \qquad\square$$

**Lemma 2.3 (Faithfulness and surjectivity).** The assignment $f \mapsto \widehat f$ is injective, and its image is exactly the set of pairmorphs. Explicitly, if $T$ is a pairmorph then $T = \widehat f$ for $f(a,b) = \pi_1(T(a,b))$, where $\pi_1$ is the first projection.

*Proof.* Injectivity: $f(a,b) = \pi_1(\widehat f(a,b))$. Surjectivity: with $f$ as stated, $\widehat f(a,b) = (\pi_1 T(a,b), \pi_1 T(b,a))$; since $T(b,a) = \sigma(T(a,b))$, the second coordinate equals $\pi_2(T(a,b))$, so $\widehat f = T$. $\square$

Write $C_{T(X\times X)}(\sigma)$ for the centralizer of $\sigma$ in the full transformation monoid of $X \times X$; by Lemma 2.2 it is precisely the set of pairmorphs, and it is a submonoid.

**Theorem 2.4 (Representation theorem).** The unfolding map is an anti-isomorphism of monoids
$$\mathrm{Bin}(X) \;\xrightarrow{\;\sim\;}\; C_{T(X \times X)}(\sigma)^{\mathrm{op}}, \qquad f \longmapsto \widehat f .$$
In particular $\mathrm{Bin}(X)$ is isomorphic to the opposite of the monoid of reversal-equivariant transformations of $X \times X$.

*Proof.* Combine Lemmas 2.2 and 2.3; $\widehat \ell = \mathrm{id}$. $\square$

This is the source of all subsequent results. Two immediate consequences:

**Corollary 2.5 (Units).** An operation $f$ is invertible in $\mathrm{Bin}(X)$ if and only if $\widehat f$ is a bijection of $X \times X$.

*Proof.* If $f$ is a unit with inverse $g$, then $\widehat g \circ \widehat f = \widehat f \circ \widehat g = \mathrm{id}$. Conversely if $\widehat f$ is bijective, its set-theoretic inverse $T$ is again a pairmorph — apply $\widehat f$ to both sides of the desired identity $T\sigma = \sigma T$ and use injectivity — so $T = \widehat g$ for a unique $g$, and $g$ inverts $f$. $\square$

**Corollary 2.6.** $|\mathrm{Bin}(X)| = n^{n^2}$ for $|X| = n$.

---

## 3. Regularity: the diagonal obstruction

**Definition 3.1.** An element $f$ of a semigroup is **(von Neumann) regular** if $f * g * f = f$ for some $g$; such a $g$ is a *pseudo-inverse*.

In the full transformation monoid $T(Y)$ every element is regular: given $T$, choose for each $y \in T(Y)$ some $s(y)$ with $T(s(y)) = y$, extend $s$ arbitrarily, and then $T s T = T$. Passing to the sub-monoid of pairmorphs, the same construction is available only if the section $s$ can be chosen *equivariantly*, and this is where the diagonal intervenes: a pairmorph maps $\Delta$ into $\Delta$, so a diagonal point in the image must be reached from a diagonal point.

The precise engine is the following selection lemma, which does the work for both regularity and left divisibility.

**Lemma 3.2 (Equivariant selection).** Let $F, G$ be pairmorphs of $X \times X$ and let $S \subseteq X \times X$ be $\sigma$-invariant. Assume:

1. for every $p \in S$ there exists $r$ with $F(r) = G(p)$;
2. for every $a$ with $(a,a) \in S$ there exists $z \in X$ with $F(z,z) = G(a,a)$.

Then there exists a pairmorph $U$ with $F(U(p)) = G(p)$ for all $p \in S$.

*Proof sketch.* Well-order $X$. The orbits of $\sigma$ on $X\times X$ are the singletons $\{(a,a)\}$ and the two-element sets $\{(a,b),(b,a)\}$ with $a \ne b$. Define $U$ orbit by orbit: on a diagonal point $(a,a)$, set $U(a,a) = (z,z)$ with $z$ furnished by (2); on a two-element orbit, choose the representative $(a,b)$ with $a < b$, set $U(a,b) = r$ from (1), and define $U(b,a) = \sigma(r)$. Equivariance is then immediate from the construction, and correctness at $(b,a)$ follows from $F(\sigma r) = \sigma F(r) = \sigma G(a,b) = G(b,a)$. Hypothesis (2) is exactly what makes the diagonal case consistent, since equivariance forces $U(a,a)$ to be a fixed point of $\sigma$. $\square$

**Theorem 3.3 (Regularity criterion).** For $f \in \mathcal{O}(X)$ the following are equivalent:

1. $f$ is regular in $\mathrm{Bin}(X)$;
2. $\mathrm{Com}(f) = \mathrm{Diag}(f)$, i.e. every $\sigma$-fixed point of the pair image is the image of a diagonal point;
3. for all $x,y \in X$: if $f(x,y) = f(y,x)$ then $f(z,z) = f(x,y)$ for some $z \in X$.

*Proof.* (1) $\Rightarrow$ (2): if $\widehat f \widehat g \widehat f = \widehat f$ and $q = \widehat f(p) \in \Delta$, then $\widehat g(q) \in \Delta$ because pairmorphs preserve $\Delta$; write $\widehat g(q) = (z,z)$, and $\widehat f(z,z) = q$, so $q \in \mathrm{Diag}(f)$. The inclusion $\mathrm{Diag}(f) \subseteq \mathrm{Com}(f)$ is automatic.

(2) $\Leftrightarrow$ (3): unwinding definitions, a point of $\mathrm{Com}(f)$ is a pair $(u,u)$ with $u = f(x,y) = f(y,x)$ for some $x,y$, and membership in $\mathrm{Diag}(f)$ says $u = f(z,z)$ for some $z$.

(2) $\Rightarrow$ (1): apply Lemma 3.2 with $F = \widehat f$, $G = \mathrm{id}$, and $S = \mathrm{Im}(f)$, which is $\sigma$-invariant since $\sigma\widehat f(p) = \widehat f(\sigma p)$. Hypothesis (1) of the lemma holds by definition of the image; hypothesis (2) is precisely $\mathrm{Com}(f) \subseteq \mathrm{Diag}(f)$. The resulting pairmorph $U$ satisfies $\widehat f U \widehat f = \widehat f$, and unfolding back (Lemma 2.3) gives a pseudo-inverse $g$ with $U = \widehat g$. $\square$

Criterion (3) is decidable in $O(n^3)$ table lookups for $|X| = n$, replacing an existential quantifier over $n^{n^2}$ candidates.

### 3.1 Consequences and examples

**Corollary 3.4.** Each of the following is regular: every idempotent ($f*f = f$); every diagonally idempotent operation ($f(z,z) = z$ for all $z$), in particular every semilattice, every lattice meet or join, $\min$, $\max$; every operation whose diagonal map $z \mapsto f(z,z)$ is surjective.

**Theorem 3.5 (Non-regularity of the magma monoid).** If $|X| \ge 2$ then $\mathrm{Bin}(X)$ is not a regular monoid. Concretely, choose $a \ne b$ in $X$ and let
$$d_{a,b}(x,y) = \begin{cases} a & x = y\\ b & x \ne y.\end{cases}$$
Then $d_{a,b}$ is not regular: $d_{a,b}(a,b) = d_{a,b}(b,a) = b$ is a commutative value, whereas the only diagonal value is $a \ne b$.

Thus the passage from $T(X\times X)$ (always regular) to its reversal-centralizer destroys regularity. The smallest example: on $X = \{0,1\}$, the operation $\mathrm{XOR}(x,y) = x + y \bmod 2$ is commutative with diagonal identically $0$, so the commutative value $1$ is unattainable on the diagonal.

**Proposition 3.6 (Census for $|X| = 2$).** Among the $16$ binary operations on a two-element set exactly $14$ are regular; the two exceptions are $\mathrm{XOR}$ and $\mathrm{XNOR}$. Exactly $7$ of the $16$ are idempotent for $*$.

**Proposition 3.7 (Regular elements are not closed under multiplication).** There exist regular $f, g \in \mathrm{Bin}(\{0,1\})$ with $f * g$ non-regular. For instance, with tables written as $\begin{pmatrix} f(0,0) & f(0,1) \\ f(1,0) & f(1,1)\end{pmatrix}$, the operations
$$f = \begin{pmatrix} 0 & 0 \\ 1 & 0\end{pmatrix}, \qquad g = \begin{pmatrix} 0 & 1 \\ 1 & 1\end{pmatrix}$$
are both regular, while $f * g = \mathrm{XOR}$ is not. Hence the regular elements do not form a submonoid — again in contrast with $T(Y)$.

**Proposition 3.8 (Regularity via idempotents).** $f$ is regular if and only if $f$ is $\mathcal{L}$-equivalent to an idempotent, if and only if $f$ is $\mathcal{R}$-equivalent to an idempotent. (If $f*g*f = f$ then $e = f * g$ is idempotent and $\mathcal{R}$-equivalent to $f$, while $e' = g*f$ is idempotent and $\mathcal{L}$-equivalent to $f$; conversely $\mathcal{R}$- or $\mathcal{L}$-equivalence to an idempotent forces $ef = f$, resp. $fe = f$, whence a pseudo-inverse.)

---

## 4. Divisibility and Green's relations

Recall the classical definitions in a monoid $M$: $f \mathrel{\mathcal{L}} g$ iff $Mf = Mg$; $f \mathrel{\mathcal{R}} g$ iff $fM = gM$; $\mathcal{H} = \mathcal{L}\cap\mathcal{R}$; $\mathcal{D} = \mathcal{L}\circ\mathcal{R}$. In $\mathrm{Bin}(X)$, note that $u * f$ unfolds to $\widehat f \circ \widehat u$, so *left* multiplication in $\mathrm{Bin}(X)$ corresponds to *pre*composition of $\widehat f$ — hence to shrinking images — while right multiplication corresponds to postcomposition, hence to coarsening kernels. This is the usual dictionary, with the sides swapped by the anti-isomorphism.

**Theorem 4.1 (Left divisibility).** For $f, g \in \mathcal{O}(X)$,
$$\exists u: u * f = g \iff \mathrm{Im}(g) \subseteq \mathrm{Im}(f) \ \text{ and }\ \mathrm{Diag}(g) \subseteq \mathrm{Diag}(f).$$

*Proof.* ($\Rightarrow$) $\widehat g = \widehat f \circ \widehat u$ makes both inclusions evident, the second because $\widehat g(z,z) = \widehat f(u(z,z), u(z,z))$. ($\Leftarrow$) Apply Lemma 3.2 with $F = \widehat f$, $G = \widehat g$, $S = X\times X$: the first inclusion gives hypothesis (1), the second gives hypothesis (2). The resulting pairmorph $U$ satisfies $\widehat f \circ U = \widehat g$, so $U = \widehat u$ and $u * f = g$. $\square$

The second condition is *invisible* in $T(X\times X)$, where left divisibility means only image containment. It is precisely the price of equivariance.

**Theorem 4.2 (Green's $\mathcal{L}$).** $f \mathrel{\mathcal{L}} g$ if and only if $\mathrm{Im}(f) = \mathrm{Im}(g)$ and $\mathrm{Diag}(f) = \mathrm{Diag}(g)$.

For the right-hand side we need a transport lemma, which — remarkably — needs no diagonal hypothesis.

**Lemma 4.3 (Equivariant kernel transport).** Let $F, H$ be pairmorphs with $\ker F \subseteq \ker H$ (i.e. $F(p) = F(q) \Rightarrow H(p) = H(q)$). Then there is a pairmorph $U$ with $U \circ F = H$.

*Proof.* Define $U(s) = H(p)$ for any $p$ with $F(p) = s$ (well defined by hypothesis), and $U(s) = s$ for $s \notin \mathrm{Im}(F)$. On the image, equivariance follows from $\sigma F(p) = F(\sigma p)$ and $\sigma H(p) = H(\sigma p)$; off the image, $U$ is the identity, which is equivariant, and the complement of $\mathrm{Im}(F)$ is $\sigma$-invariant. $\square$

**Theorem 4.4 (Right divisibility and Green's $\mathcal{R}$).**
$$\exists u : f * u = g \iff \ker \widehat f \subseteq \ker \widehat g,$$
and consequently $f \mathrel{\mathcal{R}} g$ if and only if $\ker\widehat f = \ker \widehat g$, i.e. $\widehat f(p) = \widehat f(q) \iff \widehat g(p) = \widehat g(q)$.

*Proof.* ($\Rightarrow$) $\widehat g = \widehat u \circ \widehat f$. ($\Leftarrow$) Lemma 4.3 with $F = \widehat f$, $H = \widehat g$. $\square$

**Theorem 4.5 (Green's $\mathcal{H}$).** $f \mathrel{\mathcal{H}} g$ if and only if $\mathrm{Im}(f) = \mathrm{Im}(g)$, $\mathrm{Diag}(f) = \mathrm{Diag}(g)$, and $\ker \widehat f = \ker \widehat g$.

**Theorem 4.6 (Green's $\mathcal{D}$).** $f \mathrel{\mathcal{D}} g$ if and only if there exists a pairmorph $\beta$ of $X \times X$ that is injective on $\mathrm{Im}(g)$ and satisfies
$$\beta(\mathrm{Im}(g)) = \mathrm{Im}(f), \qquad \beta(\mathrm{Diag}(g)) = \mathrm{Diag}(f).$$

*Proof sketch.* ($\Rightarrow$) If $f \mathrel{\mathcal{L}} h \mathrel{\mathcal{R}} g$, then $\ker \widehat g = \ker \widehat h$, so Lemma 4.3 produces a pairmorph $\beta$ with $\beta \circ \widehat g = \widehat h$; equality of kernels makes $\beta$ injective on $\mathrm{Im}(g)$, and $\mathcal{L}$-equivalence of $h$ and $f$ transfers images and diagonal images. ($\Leftarrow$) Given $\beta$, put $h = $ the operation unfolding to $\beta \circ \widehat g$ (a composite of pairmorphs, hence a pairmorph). Then $\mathrm{Im}(h) = \beta(\mathrm{Im}(g)) = \mathrm{Im}(f)$ and $\mathrm{Diag}(h) = \beta(\mathrm{Diag}(g)) = \mathrm{Diag}(f)$, so $h \mathrel{\mathcal{L}} f$ by Theorem 4.2, while injectivity of $\beta$ on $\mathrm{Im}(g)$ gives $\ker \widehat h = \ker\widehat g$, so $h \mathrel{\mathcal{R}} g$ by Theorem 4.4. $\square$

Thus the $\mathcal{D}$-class of $f$ is precisely the isomorphism type of its image *as a reversal-set with a marked diagonal part*: the classical "same rank" invariant of transformation semigroups, refined by the symmetry.

**Theorem 4.7 (Regularity is a $\mathcal{D}$-class invariant).** If $f \mathrel{\mathcal{D}} g$ then $f$ is regular if and only if $g$ is. In particular regularity is constant on $\mathcal{L}$- and on $\mathcal{R}$-classes.

*Proof.* Let $\beta$ be as in Theorem 4.6, and suppose $\mathrm{Com}(f) = \mathrm{Diag}(f)$. Let $q \in \mathrm{Com}(g)$, so $q \in \mathrm{Im}(g)$ and $\sigma q = q$. Since $\beta$ is a pairmorph, $\sigma \beta(q) = \beta(\sigma q) = \beta(q)$, so $\beta(q) \in \mathrm{Com}(f) = \mathrm{Diag}(f) = \beta(\mathrm{Diag}(g))$. Write $\beta(q) = \beta(d)$ with $d \in \mathrm{Diag}(g) \subseteq \mathrm{Im}(g)$; injectivity of $\beta$ on $\mathrm{Im}(g)$ gives $q = d \in \mathrm{Diag}(g)$. Hence $\mathrm{Com}(g) \subseteq \mathrm{Diag}(g)$, and the reverse inclusion is automatic. $\square$

Consequently the two non-regular operations on a two-element set constitute a union of $\mathcal{D}$-classes.

**Example 4.8 (The Green structure for $|X| = 2$).** Exhaustive computation over the $16$ operations gives $8$ $\mathcal{L}$-classes (sizes $4,4,2,2,1,1,1,1$), $6$ $\mathcal{R}$-classes (sizes $4,4,2,2,2,2$), $9$ $\mathcal{H}$-classes and $5$ $\mathcal{D}$-classes (sizes $4,4,4,2,2$). The $\mathcal{D}$-class $\{\mathrm{XOR}, \mathrm{XNOR}\}$ is exactly the set of non-regular elements, illustrating Theorem 4.7.

---

## 5. The centre

**Definition 5.1.** $f$ is *central* if $f * g = g * f$ for all $g \in \mathcal{O}(X)$.

Both projections are central. Indeed $\ell$ is the identity, while for the right projection $r$ one computes $(r*g)(a,b) = g(r(a,b), r(b,a)) = g(b,a)$ and $(g*r)(a,b) = r(g(a,b), g(b,a)) = g(b,a)$, so $r * g = g * r$ for every $g$; moreover $(r*r)(a,b) = r(b,a) = a$, so $r * r = \ell$. (Equivalently: $\widehat r = \sigma$, which is central in the centralizer of $\sigma$.)

**Lemma 5.2 (Diagonal idempotency).** If $f$ is central then $f(c,c) = c$ for every $c \in X$.

*Proof.* Test against the constant operation $k_c(a,b) = c$. Then $(f * k_c)(a,b) = c$ and $(k_c * f)(a,b) = f(c,c)$; equality forces $f(c,c) = c$. $\square$

**Lemma 5.3 (Universal endomorphy).** If $f$ is central then for every self-map $h : X \to X$ and all $a,b \in X$,
$$h(f(a,b)) = f(h(a), h(b)).$$

*Proof.* Test against $g_h(a,b) = h(a)$. Then $(f * g_h)(a,b) = h(f(a,b))$ and $(g_h * f)(a,b) = f(h(a), h(b))$. $\square$

So a central operation is one for which *every* self-map of $X$ is an endomorphism of the magma $(X, f)$ — an extremely rigid condition, which we now exploit.

**Lemma 5.4.** If $f$ is central and $a, b \in X$ then $f(a,b) \in \{a,b\}$.

*Proof.* Let $h$ be the self-map sending $b \mapsto a$ and fixing every other point (if $a = b$ use Lemma 5.2). Then $h(a) = a$, $h(b) = a$, so Lemma 5.3 and Lemma 5.2 give $h(f(a,b)) = f(a,a) = a$. Since $h^{-1}(a) = \{a,b\}$, we get $f(a,b) \in \{a,b\}$. $\square$

**Theorem 5.5 (The centre of the magma monoid).** Suppose $X$ has two distinct elements. Then
$$Z(\mathrm{Bin}(X)) = \{\ell, r\} \cong \mathbb{Z}/2,$$
the group of order two generated by the right projection.

*Proof.* Fix $a \ne b$. By Lemma 5.4, $f(a,b) \in \{a,b\}$; suppose first $f(a,b) = a$. For arbitrary $c,d \in X$ we show $f(c,d) = c$. If $c = d$ this is Lemma 5.2. If $c \ne d$, let $h$ send $a \mapsto c$ and every other point to $d$; then $h(a) = c$, $h(b) = d$, and Lemma 5.3 gives $f(c,d) = f(h(a),h(b)) = h(f(a,b)) = h(a) = c$. Hence $f = \ell$. Symmetrically, $f(a,b) = b$ forces $f = r$. Finally $\ell \ne r$ because $\ell(a,b) = a \ne b = r(a,b)$, and $r * r = \ell$, so the centre is a two-element group. $\square$

For $|X| = 1$ the monoid is trivial and the statement degenerates. For $|X| = n \ge 2$, exactly $2$ of the $n^{n^2}$ operations are central.

---

## 6. The unit group

By Corollary 2.5 and Theorem 2.4, the group of units of $\mathrm{Bin}(X)$ is anti-isomorphic to the centralizer of the reversal permutation inside $\mathrm{Sym}(X\times X)$:
$$\mathrm{Bin}(X)^\times \;\cong\; C_{\mathrm{Sym}(X\times X)}(\sigma)^{\mathrm{op}}.$$

For finite $X$ this is a completely explicit group, because centralizers of permutations depend only on cycle type.

**Lemma 6.1.** For $|X| = n$, the permutation $\sigma$ of $X \times X$ is an involution with exactly $n$ fixed points (the diagonal) and $m = n(n-1)/2$ two-cycles (the unordered off-diagonal mirror pairs). Its cycle type is $2^m 1^n$.

**Theorem 6.2 (Order of the unit group).** For $|X| = n$,
$$\bigl|\mathrm{Bin}(X)^\times\bigr| = n!\cdot 2^{m}\cdot m!, \qquad m = \frac{n(n-1)}{2}.$$

*Proof.* The centralizer of a permutation with $c_k$ cycles of length $k$ has order $\prod_k k^{c_k} c_k!$. Here $c_1 = n$, $c_2 = m$, giving $1^n n! \cdot 2^m m!$. $\square$

Structurally, this order is the shadow of a direct product: a reversal-commuting permutation must preserve the fixed-point set and the set of two-cycles, so it consists of an arbitrary permutation of the diagonal together with a signed permutation of the $m$ mirror pairs, i.e. an element of $\mathrm{Sym}(n) \times (\mathbb{Z}/2 \wr \mathrm{Sym}(m))$.

**Examples.**

| $n$ | $\lvert\mathrm{Bin}\rvert = n^{n^2}$ | $m$ | $\lvert\mathrm{Bin}^\times\rvert = n!\,2^m m!$ |
|---|---|---|---|
| 1 | 1 | 0 | 1 |
| 2 | 16 | 1 | 4 |
| 3 | 19683 | 3 | 288 |
| 4 | 4294967296 | 6 | 1105920 |

The invertible fraction collapses with dizzying speed: $25\%$ at $n=2$, $1.46\%$ at $n = 3$, $2.6 \times 10^{-4}$ at $n=4$.

---

## 7. The general equivariant theorem

The diagonal obstruction is a special case of a general principle about symmetry-constrained transformation monoids. Let a group $G$ act on a set $Y$, and let $\mathrm{End}_G(Y)$ denote the monoid of $G$-equivariant self-maps of $Y$ (maps $T$ with $T(g\cdot y) = g\cdot T(y)$) under composition. Write $G_y = \{g : g\cdot y = y\}$ for the stabilizer.

**Theorem 7.1 (Stabilizer-controlled equivariant section).** Let $T \in \mathrm{End}_G(Y)$ and suppose that every $y \in \mathrm{Im}(T)$ has a preimage $z$ with $G_y \subseteq G_z$. Then there exists $U \in \mathrm{End}_G(Y)$ with $T(U(y)) = y$ for all $y \in \mathrm{Im}(T)$.

*Proof sketch.* The image of an equivariant map is $G$-invariant. Choose a representative $\rho(y)$ in each $G$-orbit, so that $\rho(g\cdot y) = \rho(y)$ and $\rho(y) = g_y^{-1}\cdot y$ for some chosen $g_y \in G$. For each representative $p \in \mathrm{Im}(T)$ pick $z_p$ with $T(z_p) = p$ and $G_p \subseteq G_{z_p}$, and define
$$U(y) = \begin{cases} g_y \cdot z_{\rho(y)} & \rho(y) \in \mathrm{Im}(T)\\ y & \text{otherwise.}\end{cases}$$
Correctness is $T(U(y)) = g_y \cdot T(z_{\rho(y)}) = g_y\cdot \rho(y) = y$. Equivariance requires checking that replacing $y$ by $h\cdot y$ multiplies the chosen group element correctly: $g_{h\cdot y}$ and $h g_y$ both carry $\rho(y)$ to $h \cdot y$, so their "difference" $(hg_y)^{-1} g_{h\cdot y}$ stabilizes $\rho(y)$, hence — by the stabilizer hypothesis — also stabilizes $z_{\rho(y)}$. Therefore $g_{h\cdot y}\cdot z_{\rho(y)} = h\cdot(g_y \cdot z_{\rho(y)})$, which is exactly equivariance. The stabilizer hypothesis is thus not a technical convenience but the precise well-definedness condition for equivariant transport. $\square$

**Theorem 7.2 (Regularity in an equivariant transformation monoid).** For $T \in \mathrm{End}_G(Y)$ the following are equivalent:

1. $T$ is regular in $\mathrm{End}_G(Y)$: there is $U \in \mathrm{End}_G(Y)$ with $TUT = T$;
2. every $y \in \mathrm{Im}(T)$ has a preimage $z$ with $G_y \subseteq G_z$.

*Proof.* (2) $\Rightarrow$ (1) is Theorem 7.1. (1) $\Rightarrow$ (2): given $y = T(x)$, set $z = U(T(x))$; then $T(z) = y$, and if $g\cdot y = y$ then $g\cdot z = g\cdot U(y) = U(g\cdot y) = U(y) = z$. $\square$

**Corollary 7.3 (Trivial group).** $T(Y)$ is a regular monoid: all stabilizers are trivial.

**Corollary 7.4 (Free actions).** If $G$ acts freely on $\mathrm{Im}(T)$ then $T$ is regular in $\mathrm{End}_G(Y)$. All obstruction to regularity is concentrated at points with non-trivial stabilizer.

**Specialization.** Take $G = \mathbb{Z}/2$ acting on $Y = X \times X$ by reversal. Equivariance is the pairmorph condition, the points with non-trivial stabilizer are exactly the diagonal points, and Theorem 7.2 reads: $f$ is regular iff every point $y$ of $\mathrm{Im}(f)$ has a preimage $z$ with $\sigma y = y \Rightarrow \sigma z = z$. For $y$ off the diagonal the condition is vacuous; for $y$ on the diagonal it demands a diagonal preimage. This is exactly Theorem 3.3, now seen as an instance of a general symmetry principle.

---

## 8. Tropical operations inside the magma monoid

We now let $X$ carry structure and read off arithmetic consequences. The tropical (min-plus) semiring has "addition" $\min$ and "multiplication" ordinary addition. As elements of $\mathrm{Bin}(X)$ the two behave in diametrically opposite ways.

### 8.1 Tropical addition: a left-zero band

**Proposition 8.1.** If $f$ is commutative ($f(a,b) = f(b,a)$) and $g$ is diagonally idempotent ($g(x,x) = x$), then $f * g = f$.

*Proof.* $(f*g)(a,b) = g(f(a,b), f(b,a)) = g(f(a,b), f(a,b)) = f(a,b)$. $\square$

**Corollary 8.2.** The set $B(X)$ of commutative, diagonally idempotent operations — all semilattice operations, in particular $\min$ and $\max$ on a linearly ordered $X$ — is a **left-zero band**: $f * g = f$ for all $f, g \in B(X)$. Every element of $B(X)$ is idempotent and regular, and any two elements of $B(X)$ are $\mathcal{L}$-equivalent.

*Proof.* Left-zero by Proposition 8.1; idempotency and regularity by Corollary 3.4. For $\mathcal{L}$-equivalence of $f, g \in B(X)$: the identities $g * f = g$ and $f * g = f$ exhibit $g$ as a left multiple of $f$ and $f$ as a left multiple of $g$. $\square$

**Proposition 8.3.** For $f \in B(X)$ one has $\mathrm{Im}(f) = \Delta$ and $\mathrm{Diag}(f) = \Delta$; this recovers the $\mathcal{L}$-equivalence via Theorem 4.2.

**Theorem 8.4 (The tropical band).** For a linearly ordered $X$, the submonoid of $\mathrm{Bin}(X)$ generated by $\min$ and $\max$ is exactly the three-element set
$$\langle \min, \max\rangle = \{\ell, \min, \max\},$$
with multiplication table $\min * \min = \min * \max = \min$ and $\max * \min = \max * \max = \max$: every non-empty word in $\min$ and $\max$ collapses to its first letter.

### 8.2 Tropical multiplication: regularity detects $2$-divisibility

Let $R$ be a commutative additive monoid (the *value monoid*: typically $\mathbb{Z}$, $\mathbb{Q}$, or $\mathbb{R}$), and consider tropical multiplication
$$\mu(a,b) = a + b$$
as an element of $\mathrm{Bin}(R)$. It is commutative, so $\mathrm{Com}(\mu)$ consists of all values $(a+b, a+b)$; its diagonal values are $\mu(z,z) = 2z$.

**Theorem 8.5.** Tropical multiplication over $R$ is regular in the magma monoid if and only if $R$ is $2$-divisible, i.e. every $r \in R$ can be written $r = s + s$.

*Proof.* By Theorem 3.3(3), regularity says: for all $a, b$ there is $z$ with $2z = a+b$. Taking $b = 0$ gives $2$-divisibility; conversely $2$-divisibility applied to $r = a+b$ gives the required $z$. $\square$

**Corollary 8.6.** Tropical multiplication is regular over $\mathbb{Q}$ and over $\mathbb{R}$ (halve), and **not** regular over $\mathbb{Z}$: the value $1$ is a commutative value never attained on the diagonal, since $1$ is odd.

This is a striking transfer: a purely semigroup-theoretic invariant of the monoid of all binary operations detects an arithmetic property of the coefficient semiring. The min-plus semiring over $\mathbb{Z}$ and over $\mathbb{Q}$ are indistinguishable at the level of tropical addition, yet the magma monoid separates them at the level of tropical multiplication.

---

## 9. Algorithms

All criteria in this paper are effective for finite $X$; we record their cost for $|X| = n$, with an operation given as an $n \times n$ table.

**(A) Regularity test.** Compute the set $D = \{f(z,z) : z\}$ ($O(n)$). For each pair $(x,y)$ with $f(x,y) = f(y,x)$, check $f(x,y) \in D$. Total: $O(n^2)$ table lookups after $O(n)$ preprocessing — versus $n^{n^2}$ for naive search over pseudo-inverses.

**(B) Green's $\mathcal{L}$, $\mathcal{R}$, $\mathcal{H}$ test.** Compute $\mathrm{Im}(f) = \{(f(x,y), f(y,x))\}$ and $\mathrm{Diag}(f)$ in $O(n^2)$; compare as sets. For $\mathcal{R}$, compute the kernel partition of $X \times X$ induced by $\widehat f$, i.e. group pairs by their value under $\widehat f$, in $O(n^2)$; compare partitions.

**(C) Pseudo-inverse construction.** When the regularity test passes, a pseudo-inverse is built explicitly by the selection lemma: fix a total order on $X$; for each diagonal point $(u,u) \in \mathrm{Im}(f)$ choose $z$ with $f(z,z) = u$ and set $U(u,u) = (z,z)$; for each off-diagonal image point $(u,v)$ with $u < v$ choose any preimage $(x,y)$ and set $U(u,v) = (x,y)$, $U(v,u) = (y,x)$; extend $U$ by the identity off $\mathrm{Im}(f)$; return $g(a,b) = \pi_1(U(a,b))$. Cost $O(n^2)$.

**(D) Unit test and enumeration.** $f$ is a unit iff $\widehat f$ is injective on $X \times X$, testable in $O(n^2)$; the units can be enumerated directly as pairs (permutation of the diagonal, signed permutation of the $m$ mirror pairs), in time proportional to the output size $n!\,2^m m!$.

---

## 10. Discussion

Three themes emerge.

**Symmetry costs exactly one condition.** Passing from $T(X\times X)$ to the reversal-equivariant submonoid changes the theory in precisely one place: statements about *images* acquire a diagonal decoration, while statements about *kernels* do not. The asymmetry is structural — factoring a map *through* another can be repaired off the image by the identity, which is automatically equivariant; factoring *into* another cannot, because the fixed-point set must map to the fixed-point set. This is why $\mathcal{R}$ is classical and $\mathcal{L}$ is not, and why the monoid fails to be regular.

**Obstructions live at fixed points.** Theorem 7.2 identifies the general mechanism: regularity in an equivariant transformation monoid is governed by stabilizers, and only points with non-trivial stabilizer can obstruct. The magma monoid is the smallest interesting instance ($G = \mathbb{Z}/2$), and one expects the corresponding theory for other symmetry groups — for instance $n$-ary operations under the action of $\mathrm{Sym}(n)$ on argument tuples, where the "diagonal" is replaced by a whole lattice of partial-fixed-point strata indexed by subgroups.

**Semigroup invariants see arithmetic.** The tropical section shows the criterion is not merely combinatorial bookkeeping. Applied to $a + b$ over a value monoid it becomes a divisibility question, so the monoid-theoretic classification of an operation encodes structure of the underlying coefficient system. One can view the regular/non-regular dichotomy for $\mu$ as the statement that "the tropical square root" exists.

**A numerical observation.** Uniform random sampling of tables (20 000 samples per $n$) suggests that the proportion of regular operations *decreases* with $n$: approximately $0.875$ (exactly $14/16$) at $n=2$, $0.74$ at $n=3$, $0.62$ at $n=4$, $0.53$ at $n=5$, $0.16$ at $n=12$. The heuristic is clear — a random table offers only $n$ diagonal values but generates a growing number of accidental coincidences $f(x,y) = f(y,x)$ to be covered — but the asymptotics are open. (This is a sampling estimate, not a theorem.)

**Sizes.** For orientation: $|\mathrm{Bin}(X)| = n^{n^2}$, of which $2$ are central, $n!\,2^m m!$ are invertible, and, for $n = 2$, exactly $14$ of $16$ are regular and $7$ are idempotent. The monoid is thus extremely large, with a tiny group of units and a tiny centre, but its ideal structure is completely transparent through the image/kernel/diagonal invariants.

---

## 11. Future directions

All questions below concern $\mathrm{Bin}(X)$, the monoid of all binary operations on $X$ under $(f*g)(a,b) = g(f(a,b), f(b,a))$, and are direct descendants of the results proved above.

**Conjecture 1 (Structure of the unit group).** For $|X| = n$,
$$\mathrm{Bin}(X)^\times \cong \bigl(\mathrm{Sym}(n) \times (\mathbb{Z}/2 \wr \mathrm{Sym}(m))\bigr)^{\mathrm{op}}, \qquad m = \tfrac{n(n-1)}{2},$$
the isomorphism induced by restricting a reversal-equivariant permutation of $X\times X$ to the diagonal and to the set of reversal-orbits of off-diagonal pairs. The key insight is that a unit of the magma monoid is nothing but a permutation of $X \times X$ commuting with reversal, and reversal is an involution with exactly two kinds of orbits, so the unit group must split as the direct product of "what happens on the diagonal" and "what happens on the pairs"; the order formula $n!\,2^m m!$ already established is precisely the shadow of this splitting.

**Conjecture 2 (Classification of $\mathcal{L}$-classes over a finite set).** For $|X| = n$, the $\mathcal{L}$-classes of $\mathrm{Bin}(X)$ are in bijection with the pairs $(P, D)$ where $P \subseteq X\times X$ is reversal-invariant and non-empty, $D \subseteq P \cap \Delta$ with $|D| \le n$, and $|(P\cap\Delta)\setminus D| + k(P) \le n(n-1)/2$, where $k(P)$ is the number of two-element reversal-orbits contained in $P$. In particular the number of $\mathcal{L}$-classes of $\mathrm{Bin}(X)$ for $|X| = 2$ is computable in closed form. The key insight is that the $\mathcal{L}$-criterion reduces an $\mathcal{L}$-class to the pair (pair image, diagonal image), so classification becomes the purely combinatorial question of which such pairs are realizable by an equivariant surjection $X \times X \twoheadrightarrow P$ sending the diagonal onto $D$.

**Conjecture 3 ($\mathcal{D} = \mathcal{J}$ and the ideal lattice).** For finite $X$ the relations $\mathcal{D}$ and $\mathcal{J}$ coincide on $\mathrm{Bin}(X)$, and the principal-ideal order is the order induced by the pair (rank of the image, rank of the diagonal image), so that the poset of $\mathcal{J}$-classes is a two-dimensional grid truncated by the realizability constraints of Conjecture 2.

**Further directions.** (i) Extend the whole theory to $n$-ary operations with $\mathrm{Sym}(n)$ acting on argument tuples: the diagonal is then replaced by the stratification of $X^n$ by partition type, and Theorem 7.2 predicts one obstruction per stratum. (ii) Determine which magmas of classical interest (groups, quasigroups, semilattices, racks) are regular, and describe their $\mathcal{D}$-classes; quasigroup operations, for instance, unfold to injective maps and are therefore units precisely when the reversal-equivariance is compatible with the Latin-square structure. (iii) Study the *idempotent-generated* submonoid of $\mathrm{Bin}(X)$ and locate the two non-regular operations of the two-element case inside the general theory. (iv) Investigate the tropical dichotomy over general value monoids: the assignment "value monoid $\mapsto$ regularity of tropical multiplication" is a functor-like invariant, and it would be interesting to characterize which semigroup-theoretic properties of $\mathrm{Bin}(R)$ correspond to divisibility properties of $R$ by other integers.
