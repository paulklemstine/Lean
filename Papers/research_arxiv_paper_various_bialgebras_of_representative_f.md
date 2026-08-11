# Various Bialgebras of Representative Functions on Free Monoids: Duality, Characters, and the Failure of Rationality for Group-Like Series

**Author:** Aristotle

**Date:** 2026-08-11

---

## Abstract

Let $X$ be an alphabet, $X^{*}$ the free monoid it generates, and $K$ a field of characteristic zero. The vector space $K\langle X\rangle$ of noncommutative polynomials, and its completion $K\langle\langle X\rangle\rangle$ of noncommutative series, carries two mutually dual bialgebra structures: the graded, noncommutative, cocommutative bialgebra $(K\langle X\rangle,\ \mathrm{conc},\ \Delta_{\sqcup\!\sqcup})$ built from concatenation and the unshuffle coproduct, and the graded, commutative, co-noncommutative bialgebra $(K\langle X\rangle,\ \sqcup\!\sqcup,\ \Delta_{\mathrm{conc}})$ built from the shuffle product and the deconcatenation coproduct. We develop both structures from first principles in the multiset (multiplicity-preserving) formulation, prove the duality that ties them together, prove both bialgebra axioms, and determine the characters and infinitesimal characters of each.

Our main results are the following. (i) *Shuffle/unshuffle duality*: the multiplicity of a word $w$ in $u \sqcup\!\sqcup v$ equals the multiplicity of the pair $(u,v)$ in $\Delta_{\sqcup\!\sqcup}(w)$. (ii) *The bialgebra axiom for the shuffle structure*: $\Delta_{\mathrm{conc}}(u \sqcup\!\sqcup v) = \Delta_{\mathrm{conc}}(u)\,\sqcup\!\sqcup_2\,\Delta_{\mathrm{conc}}(v)$, proved by transporting the whole computation through duality onto the unshuffle side, where it reduces to a fourfold transposition of counting sums. (iii) *Character theorems*: the characters of the concatenation bialgebra are exactly the Kleene stars $\ell^{*}$ of planes $\ell = \sum_x c_x x$, its infinitesimal characters are exactly the planes, exponentials $\exp(\ell)$ of planes are characters of the shuffle algebra, and every shuffle character satisfies the divided-power identity $f(a^{n}) = f(a)^{n}/n!$ — the one-letter case of a Ree-type theorem. (iv) *Kleene–Schützenberger*: for $f : X^{*}\to K$, being representative, having a finite-dimensional space of left translates, and admitting a linear representation $f(w) = \lambda\mu(w)\gamma$ are equivalent; and the representative functions form a subalgebra of $K^{X^{*}}$ for the Hadamard product *and* for the shuffle product of series. (v) *A separation theorem*: over $\mathbb{R}$, for a plane $\ell$ with $c_a \neq 0$, the series $\exp(\ell)$ is a shuffle character which is **not** representative, its Hankel matrix along a single letter being the factorial matrix $[1/(m+n)!]$, which has infinite rank; conversely $\ell^{*}$ is representative of rank one but is a shuffle character only if $\ell = 0$. The two character groups therefore meet exactly in the counit.

**Keywords:** shuffle product, unshuffle coproduct, deconcatenation, bialgebra duality, representative functions, rational noncommutative series, Kleene–Schützenberger theorem, Hankel rank, group-like series, divided powers.

---

## 1. Introduction

### 1.1 Two products on one space

Words over an alphabet $X$ admit two structurally different multiplications. The first is **concatenation**, $(u,v)\mapsto uv$: associative, unital with the empty word $1$, and free. The second is the **shuffle**, $(u,v)\mapsto u \sqcup\!\sqcup v$, the formal sum of all interleavings of $u$ and $v$ which preserve the internal order of each factor. The shuffle is associative *and commutative*, which is remarkable on a set of objects whose defining feature is that order matters.

Both products live on the same vector space $K\langle X\rangle = \bigoplus_{w \in X^{*}} K\,w$, and each pairs with a coproduct to form a bialgebra. Concatenation pairs with the **unshuffle** coproduct $\Delta_{\sqcup\!\sqcup}$, giving a graded noncommutative cocommutative bialgebra; the shuffle pairs with the **deconcatenation** coproduct $\Delta_{\mathrm{conc}}$, giving a graded commutative co-noncommutative bialgebra. The two are graded duals of each other: in the natural inner product on $K\langle X\rangle$ for which distinct words are orthonormal, the shuffle is the transpose of the unshuffle and concatenation is the transpose of deconcatenation.

### 1.2 Representative functions and rationality

Independently of this algebra, there is a computational notion. A function $f : X^{*} \to K$ is **representative** when the two-variable function $(u,v)\mapsto f(uv)$ splits as a finite sum $\sum_{i<n} g_i(u)h_i(v)$. This is precisely the condition that $f$ can be evaluated by a finite weighted automaton, and, by the Kleene–Schützenberger theorem, precisely the condition that the *graph* of $f$, the noncommutative series $\sum_w f(w)\,w$, is **rational**, i.e. admits a linear representation $f(w) = \lambda\mu(w)\gamma$ for a monoid morphism $\mu : X^{*}\to M_n(K)$.

The theme of this paper is the interaction between these two circles of ideas. Rational series are stable under the algebraic operations coming from *both* bialgebra structures. But the *characters* — the group-like elements, the "points" of the algebras — behave in radically different ways: the concatenation characters are rational of the smallest possible rank, while the shuffle characters are, apart from the trivial one, never rational at all.

### 1.3 Summary of contributions

We give a complete, self-contained development of:

- the multiset shuffle calculus (Section 2): commutativity, associativity, grading, cardinality;
- the unshuffle coproduct and the duality theorem (Section 3), together with coassociativity, cocommutativity, and the bialgebra axiom for concatenation;
- the deconcatenation coproduct and the *dual* bialgebra axiom (Section 4), by a duality-transport argument whose combinatorial core is a fourfold sum transposition;
- the character theory of both structures (Section 5): Kleene stars, planes, exponentials, divided powers;
- representative functions and the Kleene–Schützenberger equivalence (Section 6), with closure properties;
- the shuffle product of series and the stability of rationality under it (Section 7);
- the separation theorem and the infinite rank of the factorial Hankel matrix (Section 8);
- algorithms and numerical illustrations (Section 9), discussion and future directions (Sections 10–11).

Throughout, $K$ is a field, assumed of characteristic zero wherever factorials are inverted; $X$ is an arbitrary alphabet; $X^{*}$ is the set of finite words; $|w|$ is the length of $w$; and $1$ denotes the empty word.

---

## 2. The shuffle product of words

### 2.1 Definition

We work with multisets rather than with formal linear combinations, because multiplicities are the substance of the theory and because every identity below is an identity of multisets, hence valid over any base ring.

> **Definition 2.1 (Shuffle).** The shuffle $u \sqcup\!\sqcup v$ of two words is the multiset of words defined by the recursion
> $$1 \sqcup\!\sqcup v = \{v\},\qquad u \sqcup\!\sqcup 1 = \{u\},\qquad (au)\sqcup\!\sqcup (bv) = a\cdot\bigl(u \sqcup\!\sqcup (bv)\bigr) \;+\; b\cdot\bigl((au)\sqcup\!\sqcup v\bigr),$$
> where $a\cdot S$ denotes the multiset obtained by prefixing the letter $a$ to every element of $S$, and $+$ is the sum (disjoint union) of multisets. The recursion terminates because $|u|+|v|$ strictly decreases.

Equivalently and more conceptually, $u \sqcup\!\sqcup v$ enumerates the pairs $(S, S^{c})$ of complementary subsets of the positions $\{1,\dots,|u|+|v|\}$ with $|S| = |u|$, the resulting word being the one whose $S$-positions spell $u$ and whose $S^{c}$-positions spell $v$. Distinct position sets contribute distinct terms even when the resulting words coincide: thus $a \sqcup\!\sqcup a = \{aa, aa\}$, of cardinality $2$.

### 2.2 Basic structure

> **Theorem 2.2 (Commutativity).** $u \sqcup\!\sqcup v = v \sqcup\!\sqcup u$ for all $u,v \in X^{*}$.

*Proof sketch.* Double induction on $|u|$ and $|v|$. The base cases are the two unit rules. In the inductive step both sides expand to the same sum of two terms, since the defining recursion is visibly symmetric in the two arguments once one commutes the two summands. $\square$

> **Theorem 2.3 (Grading).** If $z \in u \sqcup\!\sqcup v$ then $|z| = |u| + |v|$.

*Proof sketch.* Strong induction on $|u|+|v|$; each recursive branch prefixes exactly one letter and reduces the total length by one. $\square$

> **Theorem 2.4 (Cardinality).** $\;|u \sqcup\!\sqcup v| = \dbinom{|u|+|v|}{|u|}$, counted with multiplicity.

*Proof sketch.* Induction using the recursion of Definition 2.1: the two branches contribute $\binom{m-1+n}{m-1}$ and $\binom{m+n-1}{m}$ where $m = |u|$, $n = |v|$, and Pascal's rule assembles them into $\binom{m+n}{m}$. $\square$

Associativity requires the bilinear extension.

> **Definition 2.5.** For a multiset $S$ of words and a word $w$, put $S \sqcup\!\sqcup w := \sum_{z \in S} (z \sqcup\!\sqcup w)$, the multiset sum over the elements of $S$ with multiplicity.

> **Theorem 2.6 (Associativity).** $(u \sqcup\!\sqcup v)\sqcup\!\sqcup w = u \sqcup\!\sqcup (v \sqcup\!\sqcup w)$ for all words $u, v, w$.

*Proof sketch.* Strong induction on $|u|+|v|+|w|$. If any argument is empty, both sides collapse by the unit rules and commutativity. For $u = au'$, $v = bv'$, $w = cw'$, expand both sides using the recursion; each becomes a sum of three terms indexed by which of $a, b, c$ is emitted first. Matching them requires the induction hypothesis at three smaller triples, plus the compatibility of the bilinear extension with prefixing:
$$\bigl(a\cdot T\bigr)\sqcup\!\sqcup (cw') = a\cdot\bigl(T \sqcup\!\sqcup (cw')\bigr) + c\cdot\bigl((a\cdot T)\sqcup\!\sqcup w'\bigr).$$
Rearranging the six resulting summands (an application of commutativity of multiset addition) closes the induction. $\square$

Thus $(K\langle X\rangle, \sqcup\!\sqcup, 1)$ is a commutative, associative, unital, graded $K$-algebra.

---

## 3. The unshuffle coproduct and duality

### 3.1 Definition and grading

> **Definition 3.1 (Unshuffle coproduct).** $\Delta_{\sqcup\!\sqcup} : X^{*}\to$ multisets of pairs of words is defined by
> $$\Delta_{\sqcup\!\sqcup}(1) = \{(1,1)\},\qquad \Delta_{\sqcup\!\sqcup}(a w) = a\cdot_{L}\Delta_{\sqcup\!\sqcup}(w) \;+\; a\cdot_{R}\Delta_{\sqcup\!\sqcup}(w),$$
> where $a\cdot_L$ prefixes $a$ to the left component of each pair and $a\cdot_R$ to the right component. In linear notation this is $\Delta_{\sqcup\!\sqcup}(aw) = (a\otimes 1 + 1\otimes a)\,\Delta_{\sqcup\!\sqcup}(w)$: the unique concatenation-algebra morphism making every letter primitive.

Combinatorially, $\Delta_{\sqcup\!\sqcup}(w)$ enumerates the $2^{|w|}$ ways of two-colouring the positions of $w$, recording the subword of each colour. Two immediate consequences: $|\Delta_{\sqcup\!\sqcup}(w)| = 2^{|w|}$, and every pair $(u,v) \in \Delta_{\sqcup\!\sqcup}(w)$ satisfies $|u|+|v| = |w|$.

### 3.2 Duality

The following theorem is the hinge of the whole paper.

> **Theorem 3.2 (Shuffle/unshuffle duality).** For all $u,v,w \in X^{*}$,
> $$\operatorname{mult}\bigl(w,\; u \sqcup\!\sqcup v\bigr) \;=\; \operatorname{mult}\bigl((u,v),\; \Delta_{\sqcup\!\sqcup}(w)\bigr).$$
> Equivalently, in the inner product on $K\langle X\rangle$ in which distinct words are orthonormal, $\langle u \sqcup\!\sqcup v,\ w\rangle = \langle u \otimes v,\ \Delta_{\sqcup\!\sqcup}(w)\rangle$: the shuffle product and the unshuffle coproduct are transposes.

*Proof sketch.* Induction on $w$, with $u$ and $v$ universally quantified. For $w = 1$ both sides are $1$ if $u = v = 1$ and $0$ otherwise. For $w = cw'$ there are four cases according to whether $u$ and $v$ are empty. In the generic case $u = au'$, $v = bv'$, expanding both sides gives
$$\operatorname{mult}(cw', au' \sqcup\!\sqcup bv') = [a = c]\operatorname{mult}(w', u'\sqcup\!\sqcup bv') + [b=c]\operatorname{mult}(w', au'\sqcup\!\sqcup v'),$$
$$\operatorname{mult}((au',bv'), \Delta_{\sqcup\!\sqcup}(cw')) = [a=c]\operatorname{mult}((u',bv'),\Delta_{\sqcup\!\sqcup}(w')) + [b=c]\operatorname{mult}((au',v'),\Delta_{\sqcup\!\sqcup}(w')),$$
and the two right-hand sides agree by the induction hypothesis. The degenerate cases are similar and shorter. $\square$

Conceptually, both quantities count the same objects: colourings of the positions of $w$ by two colours such that colour one spells $u$ and colour two spells $v$.

### 3.3 Coalgebra and bialgebra properties

> **Theorem 3.3 (Cocommutativity).** Swapping the two components of every pair leaves $\Delta_{\sqcup\!\sqcup}(w)$ unchanged.

*Proof sketch.* Immediate induction: the recursion is symmetric under exchanging $\cdot_L$ and $\cdot_R$. Combinatorially, complementation $S \mapsto S^{c}$ is an involution on colourings. $\square$

> **Theorem 3.4 (Coassociativity).** $(\Delta_{\sqcup\!\sqcup}\otimes \mathrm{id})\circ\Delta_{\sqcup\!\sqcup} = (\mathrm{id}\otimes\Delta_{\sqcup\!\sqcup})\circ\Delta_{\sqcup\!\sqcup}$, as multisets of triples of words.

*Proof sketch.* Both iterates satisfy the same recursion $\Delta^{(2)}(aw) = (a\otimes 1\otimes 1 + 1 \otimes a \otimes 1 + 1\otimes 1\otimes a)\Delta^{(2)}(w)$, since prefixing distributes over the three components in the same way on both sides; a one-step induction concludes. Combinatorially, both count three-colourings of the positions of $w$. $\square$

> **Theorem 3.5 (Bialgebra axiom for concatenation).** For all $u,v$,
> $$\Delta_{\sqcup\!\sqcup}(uv) \;=\; \Delta_{\sqcup\!\sqcup}(u)\cdot\Delta_{\sqcup\!\sqcup}(v),$$
> the product on the right being the componentwise concatenation of tensors, $(p_1\otimes p_2)(q_1\otimes q_2) = p_1q_1 \otimes p_2q_2$, extended bilinearly to multisets.

*Proof sketch.* Induction on $u$. For $u = 1$ both sides equal $\Delta_{\sqcup\!\sqcup}(v)$, since $(1\otimes 1)$ is the unit of the componentwise product. For $u = au'$, apply the recursion of Definition 3.1 on the left, the induction hypothesis, and the distributivity of the componentwise product over multiset sums; the two branches match term for term. Combinatorially: a two-colouring of the positions of $uv$ is precisely a two-colouring of those of $u$ together with one of those of $v$. $\square$

With the counit $\varepsilon(w) = [\,w = 1\,]$, this establishes:

> **Corollary 3.6.** $(K\langle X\rangle,\ \mathrm{conc},\ \Delta_{\sqcup\!\sqcup},\ \varepsilon)$ is a graded, noncommutative, cocommutative bialgebra, connected in degree $0$.

---

## 4. The deconcatenation coproduct and the dual bialgebra

### 4.1 Definition

> **Definition 4.1 (Deconcatenation).** $\Delta_{\mathrm{conc}}(w) = \sum_{w = z_1 z_2} z_1\otimes z_2$, i.e. the multiset $\{(w_{<k},\, w_{\ge k}) : 0 \le k \le |w|\}$. Recursively, $\Delta_{\mathrm{conc}}(1) = \{(1,1)\}$ and $\Delta_{\mathrm{conc}}(aw) = (1 \otimes aw) + a\cdot_{L}\Delta_{\mathrm{conc}}(w)$.

> **Lemma 4.2 (Coefficients).** $|\Delta_{\mathrm{conc}}(w)| = |w|+1$, and the multiplicity of $(z_1,z_2)$ in $\Delta_{\mathrm{conc}}(z)$ is $1$ if $z_1z_2 = z$ and $0$ otherwise.

*Proof sketch.* Induction on $z$, splitting on whether $z_1$ is empty; the cancellation law in the free monoid gives uniqueness of the cut point. $\square$

Deconcatenation is coassociative (both iterates enumerate the two-cut decompositions $w = z_1z_2z_3$) and is *not* cocommutative; it is dual to concatenation exactly as unshuffle is dual to shuffle.

### 4.2 The dual bialgebra axiom

> **Definition 4.3 (Shuffle on the tensor square).** For elementary tensors, $(p_1\otimes p_2)\,\sqcup\!\sqcup_2\,(q_1\otimes q_2) := (p_1 \sqcup\!\sqcup q_1)\otimes(p_2 \sqcup\!\sqcup q_2)$, extended bilinearly.

> **Theorem 4.4 (Bialgebra axiom for the shuffle structure).** For all words $u,v$,
> $$\Delta_{\mathrm{conc}}\bigl(u \sqcup\!\sqcup v\bigr) \;=\; \Delta_{\mathrm{conc}}(u)\ \sqcup\!\sqcup_2\ \Delta_{\mathrm{conc}}(v),$$
> where the left side means: apply $\Delta_{\mathrm{conc}}$ to each element of the multiset $u \sqcup\!\sqcup v$ and take the multiset sum.

The direct combinatorial proof is unpleasant, because both sides are sums over index sets of different shapes. We prove it *by duality*, which converts the statement into a transposition of summation order. The engine is the following purely combinatorial identity, of independent interest.

> **Lemma 4.5 (Fourfold transposition).** Let $P$ be a multiset of pairs in $A\times B$, $Q$ of pairs in $C\times D$, $R$ of pairs in $A\times C$, $S$ of pairs in $B \times D$. Then
> $$\sum_{p\in P}\sum_{q\in Q}\ \operatorname{mult}\bigl((p_1,q_1), R\bigr)\cdot \operatorname{mult}\bigl((p_2,q_2), S\bigr) \;=\; \sum_{r\in R}\sum_{s\in S}\ \operatorname{mult}\bigl((r_1,s_1), P\bigr)\cdot \operatorname{mult}\bigl((r_2,s_2), Q\bigr).$$

*Proof sketch.* Replace each multiplicity by the sum of its indicator function over the corresponding multiset: $\operatorname{mult}(x, R) = \sum_{r\in R}[x = r]$. Both sides then become the same quadruple sum
$$\sum_{p\in P}\sum_{q \in Q}\sum_{r \in R}\sum_{s \in S} [\,p_1 = r_1\,][\,q_1 = r_2\,][\,p_2 = s_1\,][\,q_2 = s_2\,],$$
after noting that the product of indicators $[(p_1,q_1)=r]\,[(p_2,q_2)=s]$ equals $[(r_1,s_1)=p]\,[(r_2,s_2)=q]$ — both are $1$ exactly when the four coordinate equalities hold. Interchanging the order of the four finite summations completes the proof. $\square$

*Proof sketch of Theorem 4.4.* Fix a target tensor $z_1\otimes z_2$ and compute its multiplicity on both sides.

**Left side.** Applying Lemma 4.2 to each shuffle summand,
$$\operatorname{mult}\bigl((z_1,z_2),\ \Delta_{\mathrm{conc}}(u \sqcup\!\sqcup v)\bigr) = \sum_{z \in u \sqcup\!\sqcup v} [\, z_1z_2 = z\,] = \operatorname{mult}\bigl(z_1z_2,\ u \sqcup\!\sqcup v\bigr).$$
By duality (Theorem 3.2) this equals $\operatorname{mult}\bigl((u,v),\ \Delta_{\sqcup\!\sqcup}(z_1z_2)\bigr)$, and by the bialgebra axiom of Theorem 3.5 that is $\operatorname{mult}\bigl((u,v),\ \Delta_{\sqcup\!\sqcup}(z_1)\cdot\Delta_{\sqcup\!\sqcup}(z_2)\bigr)$; expanding the componentwise product,
$$= \sum_{\alpha \in \Delta_{\sqcup\!\sqcup}(z_1)}\ \sum_{\beta\in\Delta_{\sqcup\!\sqcup}(z_2)} [\,\alpha_1\beta_1 = u\,]\,[\,\alpha_2\beta_2 = v\,].$$

**Right side.** By definition, the multiplicity of $(z_1,z_2)$ in $\Delta_{\mathrm{conc}}(u)\sqcup\!\sqcup_2\Delta_{\mathrm{conc}}(v)$ is
$$\sum_{p \in \Delta_{\mathrm{conc}}(u)}\sum_{q\in\Delta_{\mathrm{conc}}(v)} \operatorname{mult}\bigl(z_1,\ p_1 \sqcup\!\sqcup q_1\bigr)\cdot\operatorname{mult}\bigl(z_2,\ p_2\sqcup\!\sqcup q_2\bigr),$$
and applying duality to each factor turns this into
$$\sum_{p}\sum_{q} \operatorname{mult}\bigl((p_1,q_1),\Delta_{\sqcup\!\sqcup}(z_1)\bigr)\cdot \operatorname{mult}\bigl((p_2,q_2),\Delta_{\sqcup\!\sqcup}(z_2)\bigr).$$
Lemma 4.5, applied with $P = \Delta_{\mathrm{conc}}(u)$, $Q = \Delta_{\mathrm{conc}}(v)$, $R = \Delta_{\sqcup\!\sqcup}(z_1)$, $S = \Delta_{\sqcup\!\sqcup}(z_2)$, rewrites it as
$$\sum_{\alpha\in\Delta_{\sqcup\!\sqcup}(z_1)}\sum_{\beta\in\Delta_{\sqcup\!\sqcup}(z_2)} \operatorname{mult}\bigl((\alpha_1,\beta_1),\Delta_{\mathrm{conc}}(u)\bigr)\cdot \operatorname{mult}\bigl((\alpha_2,\beta_2),\Delta_{\mathrm{conc}}(v)\bigr),$$
which by Lemma 4.2 is exactly the left-side expression $\sum_\alpha\sum_\beta[\alpha_1\beta_1 = u][\alpha_2\beta_2 = v]$. $\square$

> **Corollary 4.6.** $(K\langle X\rangle,\ \sqcup\!\sqcup,\ \Delta_{\mathrm{conc}},\ \varepsilon)$ is a graded, commutative, co-noncommutative bialgebra, and it is the graded dual of the bialgebra of Corollary 3.6.

Note the methodological point: the hard axiom on one side of the mirror becomes a triviality — a change in the order of summation — once transported to the other side. This is the practical payoff of Theorem 3.2.

---

## 5. Characters and infinitesimal characters

Throughout this section $K$ is a commutative ring (a field of characteristic zero where factorials appear), $\varepsilon(w) = [\,w = 1\,]$ is the counit, and a *linear form* on $K\langle X\rangle$ is identified with a function $f : X^{*}\to K$.

### 5.1 The concatenation side

> **Definition 5.1.** $f : X^{*}\to K$ is a **character of the concatenation bialgebra** if $f(1)=1$ and $f(uv) = f(u)f(v)$ for all $u,v$.

> **Definition 5.2 (Planes and their Kleene stars).** A **plane** is a linear form $\ell$ supported in degree one, i.e. a family $(c_x)_{x\in X}$, thought of as $\ell = \sum_{x} c_x\,x$. Its **Kleene star** is the series $\ell^{*} = \sum_{n\ge 0}\ell^{n}$, whose coefficient function is
> $$\ell^{*}(x_1x_2\cdots x_n) = c_{x_1}c_{x_2}\cdots c_{x_n}, \qquad \ell^{*}(1) = 1.$$

> **Theorem 5.3 (Characters are Kleene stars of planes).** A function $f : X^{*}\to K$ is a character of the concatenation bialgebra if and only if $f = \ell^{*}$ for a (necessarily unique) plane $\ell$, namely $c_x = f(x)$.

*Proof sketch.* ($\Leftarrow$) Immediate: the product of the letter-values telescopes over a concatenation. ($\Rightarrow$) Induction on the word: $f(1) = 1$ by hypothesis, and $f(aw) = f(a)f(w) = c_a\cdot \ell^{*}(w)$ by the inductive hypothesis. $\square$

Thus the character group of the concatenation bialgebra is canonically the multiplicative group $(K^{\times})^{X}$ — a "torus" of Kleene stars.

> **Definition 5.4.** $g : X^{*}\to K$ is an **infinitesimal character** of the concatenation bialgebra when
> $$g(uv) = g(u)\,\varepsilon(v) + \varepsilon(u)\,g(v)\qquad\text{for all } u,v.$$

> **Theorem 5.5 (Infinitesimal characters are exactly the planes).** $g$ is an infinitesimal character if and only if $g(w)=0$ for every word $w$ with $|w|\neq 1$.

*Proof sketch.* ($\Rightarrow$) Taking $u=v=1$ gives $g(1)=2g(1)$, so $g(1)=0$. If $|w|\ge 2$, write $w = uv$ with $u,v$ both nonempty; then $\varepsilon(u)=\varepsilon(v)=0$ and the defining identity yields $g(w) = 0$. ($\Leftarrow$) Given a plane $g$, check the identity by cases: if $u=1$ or $v=1$ both sides agree trivially (using $g(1)=0$, which holds since $|1|\ne 1$); if both are nonempty then $|uv|\ge 2$, so all three terms vanish. $\square$

Theorems 5.3 and 5.5 are the promised statement that, for the concatenation product, "only the Kleene stars of planes are characters, or equivalently only the planes are infinitesimal characters". They form a Ree-type pair: exponentiating a degree-one datum produces the whole character, and conversely.

### 5.2 The shuffle side

> **Definition 5.6.** $f : X^{*}\to K$ is a **character of the shuffle algebra** if $f(1)=1$ and
> $$f(u)\,f(v) \;=\; \sum_{z\in u \sqcup\!\sqcup v} f(z)\qquad\text{(sum with multiplicity)}.$$
> By Theorem 3.2 this says exactly that the series $\sum_w f(w)w$ is **group-like** for $\Delta_{\sqcup\!\sqcup}$.

> **Lemma 5.7 (Shuffles preserve letter weights).** For any family $(c_x)$ and any $z \in u \sqcup\!\sqcup v$, the product of the $c$-values along $z$ equals the product along $u$ times the product along $v$.

*Proof sketch.* Induction on the shuffle recursion; each step prefixes one letter drawn from one of the two factors, multiplying the running product by its $c$-value. $\square$

> **Theorem 5.8 (Exponentials of planes are shuffle characters).** Let $K$ have characteristic zero and let $\ell = \sum_x c_x x$ be a plane. Then the function
> $$\exp(\ell)(x_1\cdots x_n) \;=\; \frac{c_{x_1}\cdots c_{x_n}}{n!}$$
> is a character of the shuffle algebra.

*Proof sketch.* Fix $u,v$ with $|u| = m$, $|v| = n$. By Theorem 2.3 every $z \in u \sqcup\!\sqcup v$ has length $m+n$, and by Lemma 5.7 every such $z$ has the same weight $C_uC_v$, where $C_u$ denotes the product of the $c$-values along $u$. Hence
$$\sum_{z\in u \sqcup\!\sqcup v}\exp(\ell)(z) = |u \sqcup\!\sqcup v|\cdot\frac{C_uC_v}{(m+n)!} = \binom{m+n}{m}\frac{C_uC_v}{(m+n)!} = \frac{C_u}{m!}\cdot\frac{C_v}{n!},$$
using Theorem 2.4 and $\binom{m+n}{m}\,m!\,n! = (m+n)!$. $\square$

The factorials are not optional. The following is the one-letter case of Ree's theorem.

> **Lemma 5.9.** $a^{n} \sqcup\!\sqcup a = (n+1)\cdot a^{n+1}$ as multisets, where $a^{n}$ denotes the word $a$ repeated $n$ times.

*Proof sketch.* Induction using the recursion: $a^{n+1}\sqcup\!\sqcup a = a\cdot(a^{n}\sqcup\!\sqcup a) + a\cdot(a^{n+1}\sqcup\!\sqcup 1)$, which by hypothesis is $(n+1)$ copies plus one copy of $a^{n+2}$. $\square$

> **Theorem 5.10 (Divided powers).** Let $K$ have characteristic zero and let $f$ be any character of the shuffle algebra. Then for every letter $a$ and every $n\ge 0$,
> $$f(a^{n}) \;=\; \frac{f(a)^{n}}{n!}.$$

*Proof sketch.* Induction on $n$. The case $n=0$ is $f(1)=1$. For the step, apply the character identity to $u = a^{n}$, $v = a$ and use Lemma 5.9:
$$f(a^{n})f(a) = \sum_{z\in a^{n}\sqcup\!\sqcup a} f(z) = (n+1)\,f(a^{n+1}),$$
so $f(a^{n+1}) = f(a^{n})f(a)/(n+1) = f(a)^{n+1}/(n+1)!$. $\square$

So a shuffle character is completely rigid along each single letter: it must agree there with the exponential of the plane determined by its values on letters. This is the germ of the separation theorem of Section 8.

---

## 6. Representative functions and the Kleene–Schützenberger theorem

Let $K$ be a field.

> **Definition 6.1 (Translates).** For $w\in X^{*}$, the **left translate** of $f$ is $w^{-1}f : u\mapsto f(wu)$. The **translate space** $T(f)\subseteq K^{X^{*}}$ is the linear span of $\{w^{-1}f : w \in X^{*}\}$. (In automata language, $\dim T(f)$ is the *Hankel rank* of $f$.)

> **Definition 6.2 (Representative).** $f$ is **representative** if there exist $n\in\mathbb{N}$ and functions $g_1,\dots,g_n, h_1,\dots,h_n : X^{*}\to K$ with
> $$f(uv) \;=\; \sum_{i=1}^{n} g_i(u)\,h_i(v)\qquad \text{for all } u,v \in X^{*}.$$

> **Definition 6.3 (Linear representation).** $f$ **admits a linear representation** of dimension $n$ if there are $\lambda \in K^{1\times n}$, $\gamma\in K^{n\times 1}$ and a map $\mu : X \to M_n(K)$, extended to a monoid morphism $\mu : X^{*}\to M_n(K)$ by $\mu(1)=I$, $\mu(aw)=\mu(a)\mu(w)$, such that $f(w) = \lambda\,\mu(w)\,\gamma$ for all $w$.

> **Theorem 6.4 (Kleene–Schützenberger for representative functions).** For $f : X^{*}\to K$ the following are equivalent:
> 1. $f$ is representative;
> 2. $T(f)$ is finite dimensional;
> 3. $f$ admits a linear representation.

*Proof sketch.*

**(1) $\Rightarrow$ (2).** Given $f(uv) = \sum_i g_i(u)h_i(v)$, we have $w^{-1}f = \sum_i g_i(w)\,h_i$ as functions, so $T(f)$ lies in the span of the $n$ functions $h_1,\dots,h_n$ and hence has dimension at most $n$.

**(2) $\Rightarrow$ (3).** This is the Myhill–Nerode construction. Let $V = T(f)$, of finite dimension $n$, with basis $(e_1,\dots,e_n)$. Note $f = 1^{-1}f \in V$, and $V$ is stable under each shift operator $\sigma_a : g \mapsto a^{-1}g$, since the shift of a generator is again a generator, $\sigma_a(w^{-1}f) = (wa)^{-1}f$, and shifts are linear. Define $\mu(a)$ to be the matrix of $\sigma_a$ in the chosen basis; then $\mu$ extends to a monoid morphism and the coordinate vector of $w^{-1}f$ is $\lambda\mu(w)$, where $\lambda$ is the coordinate vector of $f$. Taking $\gamma_i = e_i(1)$, evaluation at the empty word gives
$$\lambda\,\mu(w)\,\gamma = \bigl(w^{-1}f\bigr)(1) = f(w).$$

**(3) $\Rightarrow$ (1).** Since $\mu$ is multiplicative,
$$f(uv) = \lambda\mu(u)\mu(v)\gamma = \sum_{i=1}^{n}\ \bigl(\lambda\mu(u)\bigr)_i\ \bigl(\mu(v)\gamma\bigr)_i,$$
a factorization of the required shape with $g_i(u) = (\lambda\mu(u))_i$ and $h_i(v) = (\mu(v)\gamma)_i$. $\square$

Under the identification of $f$ with its **graph**, the noncommutative series $\sum_w f(w)\,w$, condition (3) is precisely rationality in the sense of Kleene–Schützenberger; so representative functions are exactly the rational series.

> **Proposition 6.5 (Closure properties).** The representative functions form a unital subalgebra of $K^{X^{*}}$ for the pointwise operations:
> - if $f, g$ are representative then so is $f+g$, with a factorization of size $n+m$;
> - if $f$ is representative and $c\in K$ then $c f$ is representative;
> - if $f,g$ are representative then the Hadamard product $fg$ ($w\mapsto f(w)g(w)$) is representative, of size $nm$;
> - every constant is representative, of size $1$;
> - every monoid morphism $f : X^{*}\to(K,\cdot)$ — in particular every Kleene star of a plane — is representative, of size $1$, via $f(uv) = f(u)\cdot f(v)$.

*Proof sketch.* Sums: concatenate the two families of factors. Scalars: scale one family. Hadamard: take the tensor product of the two factorizations, $f(uv)g(uv) = \sum_{i,j}\bigl(g_i(u)c_j(u)\bigr)\bigl(h_i(v)d_j(v)\bigr)$ — on representations this is the Kronecker product $\mu \otimes \nu$. $\square$

---

## 7. The shuffle product of series and stability of rationality

The unshuffle coproduct dualizes to a product on series.

> **Definition 7.1.** For $f,g : X^{*}\to K$ define
> $$(f \sqcup\!\sqcup g)(w) \;=\; \sum_{(u,v)\ \in\ \Delta_{\sqcup\!\sqcup}(w)} f(u)\,g(v),$$
> the sum being over the multiset $\Delta_{\sqcup\!\sqcup}(w)$ of $2^{|w|}$ pairs.

> **Theorem 7.2 (Consistency with the shuffle of words).** Let $\delta_u$ denote the indicator function of the word $u$. Then $(\delta_u \sqcup\!\sqcup \delta_v)(w) = \operatorname{mult}(w,\ u \sqcup\!\sqcup v)$.

*Proof sketch.* Only the term $(u,v)$ of $\Delta_{\sqcup\!\sqcup}(w)$ contributes, with coefficient its multiplicity; by Theorem 3.2 that multiplicity is $\operatorname{mult}(w, u\sqcup\!\sqcup v)$. $\square$

> **Theorem 7.3.** $(K^{X^{*}},\ \sqcup\!\sqcup,\ \varepsilon)$ is a commutative associative unital $K$-algebra:
> - $f \sqcup\!\sqcup g = g\sqcup\!\sqcup f$, by cocommutativity of $\Delta_{\sqcup\!\sqcup}$ (Theorem 3.3);
> - $\varepsilon \sqcup\!\sqcup f = f$, since the only pair of $\Delta_{\sqcup\!\sqcup}(w)$ with empty first component is $(1,w)$, occurring once;
> - $(f\sqcup\!\sqcup g)\sqcup\!\sqcup h = f\sqcup\!\sqcup(g\sqcup\!\sqcup h)$, by coassociativity (Theorem 3.4), both sides being $\sum_{(p,q,r)} f(p)g(q)h(r)$ over the multiset of triples produced by the iterated coproduct.

The main result of this section is that the rational world is closed under this product.

> **Theorem 7.4 (Rationality is preserved by the shuffle).** If $f$ and $g$ are representative, then so is $f \sqcup\!\sqcup g$. If $f$ has a factorization of size $n$ and $g$ one of size $m$, then $f \sqcup\!\sqcup g$ has one of size $nm$.

*Proof sketch.* Write $f(uv) = \sum_{i<n} a_i(u)\,b_i(v)$ and $g(uv) = \sum_{j<m} c_j(u)\,d_j(v)$. By the bialgebra axiom (Theorem 3.5), $\Delta_{\sqcup\!\sqcup}(uv) = \Delta_{\sqcup\!\sqcup}(u)\cdot\Delta_{\sqcup\!\sqcup}(v)$, so every pair splitting $uv$ is uniquely $(\alpha_1\beta_1,\ \alpha_2\beta_2)$ for $\alpha \in \Delta_{\sqcup\!\sqcup}(u)$, $\beta\in\Delta_{\sqcup\!\sqcup}(v)$, with multiplicities multiplying. Hence
$$(f\sqcup\!\sqcup g)(uv) = \sum_{\alpha}\sum_{\beta} f(\alpha_1\beta_1)\,g(\alpha_2\beta_2) = \sum_{\alpha}\sum_{\beta}\ \sum_{i,j} a_i(\alpha_1)c_j(\alpha_2)\ \cdot\ b_i(\beta_1)d_j(\beta_2).$$
Exchanging the finite sum over $(i,j)$ with the two multiset sums and recognizing the inner sums as shuffle products of series gives
$$(f \sqcup\!\sqcup g)(uv) \;=\; \sum_{i<n}\sum_{j<m}\ \bigl(a_i \sqcup\!\sqcup c_j\bigr)(u)\ \cdot\ \bigl(b_i \sqcup\!\sqcup d_j\bigr)(v),$$
which is a factorization of size $nm$. $\square$

Together with Proposition 6.5, this says: the representative functions form a subalgebra of $K^{X^{*}}$ for the Hadamard product *and* for the shuffle product — the rational locus is a sub-bialgebra-friendly object with respect to both structures.

---

## 8. The separation theorem

We now compare the two character families of Section 5 against the rationality criterion of Section 6. Work over $K=\mathbb{R}$ (any Archimedean ordered field, or indeed any field of characteristic zero after specializing, would do for the statement; the proof below uses the Archimedean property of $\mathbb{R}$).

### 8.1 Infinite rank of the factorial Hankel matrix

> **Lemma 8.1 (Factorial ratio bound).** For all $n,k,i$ with $i \ge k+1$,
> $$\frac{(n+k)!}{(n+i)!} \;\le\; \frac{1}{\,n+k+1\,}.$$

*Proof sketch.* $(n+i)! \ge (n+k+1)! = (n+k+1)\,(n+k)!$, since $i \ge k+1$ and factorials are monotone. $\square$

> **Theorem 8.2 (Independence of the factorial Hankel rows).** Let $N \in \mathbb{N}$ and $g_0,\dots,g_N \in \mathbb{R}$ satisfy
> $$\sum_{i=0}^{N} g_i \cdot \frac{n!}{(n+i)!} \;=\; 0 \qquad\text{for every } n \ge 0 .$$
> Then $g_i = 0$ for all $i$. Equivalently, the infinite Hankel matrix $\bigl[\,1/(m+n)!\,\bigr]_{m,n\ge 0}$ has infinite rank.

*Proof sketch.* Strong induction on $k$: assume $g_i = 0$ for all $i<k$ and prove $g_k = 0$. Rescale the hypothesis by $(n+k)!/n!$, giving, for every $n$,
$$\sum_{i=0}^{N} g_i \cdot \frac{(n+k)!}{(n+i)!} \;=\; 0 .$$
The terms with $i<k$ vanish by the inductive hypothesis; the term $i = k$ equals $g_k$; and each term with $i>k$ is bounded in absolute value by $|g_i|/(n+k+1)$ by Lemma 8.1. Setting $M = \sum_i |g_i|$ we get
$$|g_k| \;\le\; \frac{M}{\,n+k+1\,}\qquad\text{for every } n\ge 0 .$$
Since $M$ is a fixed constant and $n$ is arbitrary, the Archimedean property forces $g_k = 0$. $\square$

The determinants of the leading blocks provide a concrete confirmation: for $n = 1,\dots,7$ the determinant of $[1/(i+j)!]_{0\le i,j<n}$ equals
$$1,\quad -\tfrac{1}{2},\quad -\tfrac{1}{144},\quad \tfrac{1}{1036800},\quad \tfrac{1}{1463132160000},\quad -\tfrac{1}{668986161758208000000},\quad -\tfrac{1}{148045794139338685651353600000000},$$
all nonzero.

### 8.2 Group-like series are not rational

> **Theorem 8.3 (Separation).** Let $X$ be an alphabet, $a \in X$ a letter, and $\ell = \sum_x c_x x$ a plane over $\mathbb{R}$ with $c_a \neq 0$. Then:
> 1. $\exp(\ell)$ is a character of the shuffle algebra;
> 2. $\exp(\ell)$ is **not** a representative function; equivalently, its graph is not a rational noncommutative series;
> 3. $\ell^{*}$ **is** a representative function, of rank one.

*Proof sketch.* (1) is Theorem 5.8 and (3) is Proposition 6.5. For (2), suppose $f := \exp(\ell)$ were representative. By Theorem 6.4 the translate space $T(f)$ is finite dimensional; call its dimension $N$. Then the $N+1$ vectors $\bigl(a^{i}\bigr)^{-1}f$, $i = 0,\dots,N$, are linearly dependent: there are scalars $g_0,\dots,g_N$, not all zero, with $\sum_i g_i\,(a^{i})^{-1}f = 0$. Evaluating at $a^{n}$ and using $f(a^{k}) = c_a^{k}/k!$ gives, for every $n\ge 0$,
$$\sum_{i=0}^{N} g_i \cdot \frac{c_a^{\,i+n}}{(i+n)!} \;=\; 0 .$$
Multiplying by $n!/c_a^{\,n}$ (legitimate since $c_a\neq 0$) and setting $G_i := g_i\,c_a^{\,i}$ we obtain exactly the hypothesis of Theorem 8.2, whence every $G_i = 0$, whence every $g_i = 0$ — contradicting the nontriviality of the dependency. $\square$

The converse comparison completes the picture.

> **Theorem 8.4 (Kleene stars are almost never shuffle characters).** Let $K$ be a field and $\ell = \sum_x c_x x$ a plane. If $\ell^{*}$ is a character of the shuffle algebra, then $c_x = 0$ for every letter $x$, i.e. $\ell = 0$ and $\ell^{*} = \varepsilon$.

*Proof sketch.* Apply the shuffle character identity to $u = v = x$. Since $x \sqcup\!\sqcup x = 2\cdot xx$ and $\ell^{*}(xx) = c_x^{2}$, we get $c_x^{2} = 2c_x^{2}$, so $c_x^{2}=0$ and $c_x = 0$. $\square$

> **Corollary 8.5.** The character group of the concatenation bialgebra and the character group of the shuffle algebra, both viewed inside $K^{X^{*}}$, intersect exactly in the counit $\varepsilon$. Moreover, over $\mathbb{R}$, no nontrivial shuffle character is rational, while every concatenation character is rational of rank one.

This is the sharpest form of the dichotomy: the two dual bialgebra structures on the same space have character groups that are, apart from the trivial point, disjoint — and they sit on opposite sides of the rationality divide.

---

## 9. Algorithms and computational illustration

All the objects above are effectively computable, and the identities we proved are exactly the ones that make the computations efficient.

### 9.1 Shuffle enumeration

The recursion of Definition 2.1 computes $u \sqcup\!\sqcup v$ as a multiset. Naively the cost is $\Theta\!\left(\binom{m+n}{m}\cdot(m+n)\right)$ — output-size dominated — but with memoization on suffix pairs the number of distinct recursive calls is $(m+1)(n+1)$, so the coefficient vector of $u \sqcup\!\sqcup v$ can be produced in time proportional to the number of *distinct* resulting words times $(m+1)(n+1)$.

### 9.2 Coproducts

$\Delta_{\sqcup\!\sqcup}(w)$ is computed by the linear-in-length recursion of Definition 3.1; the output has $2^{|w|}$ terms with multiplicity, or at most $2^{|w|}$ distinct terms after collection. $\Delta_{\mathrm{conc}}(w)$ is trivially computed in $O(|w|^{2})$ time, or $O(|w|)$ with shared suffixes.

### 9.3 Hankel rank

Given an oracle for $f$, form the matrix $H_d = \bigl[f(uv)\bigr]$ indexed by all words $u,v$ of length $\le d$, and compute its rank by exact Gaussian elimination over $\mathbb{Q}$. By Theorem 6.4, $f$ is representative if and only if $\operatorname{rank} H_d$ is bounded as $d\to\infty$, and the bound is then the minimal dimension of a linear representation. With $|X| = q$, the matrix has $\frac{q^{d+1}-1}{q-1}$ rows and columns; the elimination costs $O(\text{size}^{3})$ field operations. This algorithm is the computational face of the separation theorem: for $f = \exp(\ell)$ over a one-letter alphabet, the ranks are $2,3,4,5,6,\dots$, growing without bound, whereas for $f = \ell^{*}$ they are constantly $1$.

### 9.4 Verified numerical checks

Direct computation over the rationals confirms, on all words up to the indicated lengths:

- $|u \sqcup\!\sqcup v| = \binom{|u|+|v|}{|u|}$, and commutativity and associativity of the shuffle, for $|u|,|v|,|w| \le 3$ over a two-letter alphabet;
- duality $\operatorname{mult}(z, u\sqcup\!\sqcup v) = \operatorname{mult}((u,v), \Delta_{\sqcup\!\sqcup}(z))$, and cocommutativity, coassociativity and the bialgebra axiom $\Delta_{\sqcup\!\sqcup}(uv) = \Delta_{\sqcup\!\sqcup}(u)\Delta_{\sqcup\!\sqcup}(v)$;
- the dual bialgebra axiom $\Delta_{\mathrm{conc}}(u\sqcup\!\sqcup v) = \Delta_{\mathrm{conc}}(u)\sqcup\!\sqcup_2\Delta_{\mathrm{conc}}(v)$;
- $\ell^{*}$ is a concatenation character but not a shuffle character; $\exp(\ell)$ is a shuffle character; divided powers $f(a^{n})=f(a)^{n}/n!$ for $n\le 5$;
- the function $f(w) = |w|_a$ (number of occurrences of $a$) has the two-dimensional representation $\lambda = (1,0)$, $\mu(a) = \begin{pmatrix}1&1\\0&1\end{pmatrix}$, $\mu(b) = I$, $\gamma = (0,1)^{\top}$, with Hankel ranks $2,2,2$ at depths $1,2,3$; its shuffle product with $g(w) = 2^{|w|}$ again has Hankel ranks $2,2,2$, illustrating Theorem 7.4;
- $\exp(a)$ has Hankel ranks $2,3,4,5,6$ at depths $1,\dots,5$ over a one-letter alphabet, and the leading minors of $[1/(i+j)!]$ listed in Section 8.1 are all nonzero.

---

## 10. Discussion

### 10.1 Why duality is the efficient route

The two bialgebra axioms have very different direct proofs. On the concatenation side, $\Delta_{\sqcup\!\sqcup}(uv) = \Delta_{\sqcup\!\sqcup}(u)\Delta_{\sqcup\!\sqcup}(v)$ falls out of a one-line induction because both sides are recursively generated in the same variable. On the shuffle side, $\Delta_{\mathrm{conc}}(u \sqcup\!\sqcup v) = \Delta_{\mathrm{conc}}(u)\sqcup\!\sqcup_2\Delta_{\mathrm{conc}}(v)$ has no such recursive symmetry: the left-hand side recurses on the shuffle, the right-hand side on the cut points, and the two recursions do not align.

The duality theorem repairs this. Reading each side coefficientwise and applying Theorem 3.2 converts every shuffle multiplicity into an unshuffle multiplicity, at which point both sides are quadruple sums of products of indicator functions over the *same* four index multisets, differing only in summation order (Lemma 4.5). We regard this as the structurally correct proof — it explains *why* the axiom holds (it is the transpose of an axiom that is nearly definitional) rather than merely verifying it.

### 10.2 The shape of the dichotomy

It is worth emphasizing how tight the separation is. The rational functions are stable under everything algebraic in sight: sums, scalars, Hadamard product, shuffle product. The two character families are each rigidly determined by their degree-one data. Yet the two families are transverse: the Kleene stars are rational of rank one, the exponentials are irrational of infinite rank, and they overlap only at $\varepsilon$.

The mechanism is a single arithmetic fact: shuffle characters are forced to have divided powers, and $[1/(m+n)!]$ has infinite Hankel rank while $[c^{m+n}]$ has rank one. The rank-one matrix $[c^{m+n}] = (c^{m})(c^{n})$ is the archetype of finite memory; the factorial matrix is the archetype of its failure. That the divided-power structure is *forced* on shuffle characters (Theorem 5.10) is what turns an example into a theorem.

### 10.3 Relation to iterated integrals and signatures

The shuffle algebra is the algebra of iterated integrals: if $S(\gamma)$ denotes the signature of a smooth path, its coefficients multiply by the shuffle rule, and $S(\gamma)$ is group-like for $\Delta_{\sqcup\!\sqcup}$. The separation theorem then says that a nondegenerate signature is never a rational series: its coefficient function cannot be produced by any finite weighted automaton. The factorial decay of signature coefficients — the very property that makes truncated signatures such effective features in data analysis — is precisely the obstruction to finite-state computability. This is a statement about the boundary between algebraic and analytic descriptions of paths, and the divided-power theorem is the exact place where the boundary is crossed.

### 10.4 Scope and limitations

Two limitations are worth naming. First, our character theorem on the shuffle side is complete only in the one-letter direction: Theorem 5.10 pins down every shuffle character along the powers of a single letter, but does not by itself classify all shuffle characters over a multi-letter alphabet (the full statement is the exponential–Lie correspondence, requiring the Lie-element machinery). Second, the separation argument as given is Archimedean and is stated over $\mathbb{R}$; extending it verbatim to an arbitrary field of characteristic zero requires replacing the estimate of Theorem 8.2 by an algebraic nonvanishing argument for the minors of $[1/(m+n)!]$ (which do have closed product forms).

---

## 11. Future directions

The following conjectures are stated so that each is falsifiable by an explicit finite computation or by a single counterexample.

**C1. The antipode of the shuffle Hopf algebra is the signed reversal.** For every nonempty word $w$ and every field $K\supseteq\mathbb{Q}$,
$$\sum_{(u,v)\in\Delta_{\mathrm{conc}}(w)} (-1)^{|u|}\ \operatorname{mult}\bigl(z,\ \widetilde{u} \sqcup\!\sqcup v\bigr) \;=\; 0\qquad\text{for every } z,$$
where $\widetilde{u}$ is the reversal of $u$; that is, $S(w) = (-1)^{|w|}\widetilde{w}$ is the antipode of the graded Hopf algebra $(K\langle X\rangle, \sqcup\!\sqcup, \Delta_{\mathrm{conc}})$. The key insight is that the bialgebra axiom of Theorem 4.4 upgrades to a Hopf structure precisely because the deconcatenation coproduct is connected and graded, so the antipode is forced by Takeuchi's recursion — and the closed form must then be a signed multiset identity between shuffles of reversals, a purely combinatorial claim accessible to the counting machinery developed here. This is timely because the counting apparatus for shuffle, unshuffle and deconcatenation is now in place, the antipode is the last missing structure map, and it is exactly the input needed to state Sweedler duality intrinsically.

**C2. Rational series form a shuffle-subalgebra that is not closed under shuffle inversion.** Theorem 7.4 shows rationality is preserved by $\sqcup\!\sqcup$. We conjecture that the shuffle-invertible rational series (those with $f(1)\neq 0$) do **not** form a group inside the rational series: there is a rational $f$ with $f(1)=1$ whose shuffle inverse $g$ — which exists uniquely as a series — has infinite Hankel rank. The key insight is that the separation of Theorem 8.3, where $\exp(\ell)$ is a shuffle character of infinite Hankel rank because the factorial Hankel determinants are nonzero, should be reachable from a *rational* input by shuffle inversion, since the shuffle inverse of a series of the form $1 - x$ is exponential-like with factorial denominators. This is timely because Theorem 8.2 provides a working Archimedean method for proving infinite Hankel rank, and the same method should apply verbatim to the coefficients of a shuffle inverse.

**C3. $q$-deformations interpolate between concatenation and shuffle without changing the rational locus.** For a parameter $q \in K$, define the $q$-shuffle by the recursion
$$au \sqcup\!\sqcup_q bv \;=\; a\,(u \sqcup\!\sqcup_q bv) \;+\; b\,(au \sqcup\!\sqcup_q v) \;+\; q\,[\,a = b\,]\ ab\,(u \sqcup\!\sqcup_q v).$$
We conjecture that for every $q$ the rational series form a subalgebra for $\sqcup\!\sqcup_q$ — that is, the rational locus is a deformation invariant — and that the associated character group varies with $q$ while remaining disjoint from the rational locus except at the counit. The specializations $q=0$ (shuffle) and the degenerate limits recovering concatenation-like behaviour are the two ends of the interpolation, and the conjecture asserts that rationality is stable all along the family.

Beyond these, three further directions suggest themselves. (a) *Sweedler duality intrinsically*: identify the commutative co-noncommutative bialgebra of series with the Sweedler dual of the graded concatenation bialgebra, and read the character theorem of Section 5 as the statement that the only characters of the concatenation structure are the Kleene stars of planes. (b) *Effective rank bounds*: make Theorem 7.4 sharp — is the bound $nm$ on the Hankel rank of $f \sqcup\!\sqcup g$ attained, and what is the minimal rank? (c) *Positive characteristic*: everything up to Section 5 is characteristic free; the exponential and divided-power theorems are not. Divided-power algebras replace exponentials in characteristic $p$, and the separation theorem should have an analogue there with a different arithmetic mechanism.

---

## 12. Conclusion

We have developed, in a self-contained way, the two mutually dual bialgebra structures carried by noncommutative polynomials over a free monoid, established the duality between the shuffle product and the unshuffle coproduct, and used that duality to give an economical proof of the bialgebra axiom for the shuffle/deconcatenation structure. We determined the characters and infinitesimal characters of the concatenation structure — Kleene stars of planes and planes respectively — and showed that shuffle characters are exponential-like, obeying forced divided powers. Placing these families against the Kleene–Schützenberger criterion for rationality, we proved that although rational series are stable under both the Hadamard and the shuffle products, the two character families are transverse: over $\mathbb{R}$, the exponential of a nonzero plane is a shuffle character of infinite Hankel rank and hence not rational, and a Kleene star is a shuffle character only when it is the counit. The single arithmetic fact underlying the dichotomy is the infinite rank of the factorial Hankel matrix $[1/(m+n)!]$, itself a consequence of nothing more than the Archimedean growth of factorials.
