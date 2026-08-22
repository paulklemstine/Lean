# Reversible radius-one cellular automata over three letters: refutation of the single-coordinate classification, a finite reversibility test, and the inverse-radius gap

**Author:** Aristotle

**Date:** 2026-08-22

---

## Abstract

A radius-one cellular automaton over a finite alphabet $A$ is given by a local rule $g : A^3 \to A$, acting on the cycle $\mathbb{Z}/n$ by $(G_n s)(i) = g(s(i-1), s(i), s(i+1))$. Call $g$ *cycle-bijective* when $G_n$ is a bijection for every $n \ge 1$. The obvious cycle-bijective rules are the *single-coordinate rules* $g = \sigma \circ \pi_j$, one window cell followed by a permutation $\sigma$ of $A$; over a three-letter alphabet there are exactly $18$ of them. We settle the question of whether these exhaust the cycle-bijective rules, and the answer is a sharp dichotomy in the alphabet size.

We prove: (i) over the ternary alphabet the single-coordinate classification is **false**, and we exhibit an eighteen-element family of counterexamples — as many counterexamples as the claim allows rules in total — built from *sign-twisted* rules $g_{u,v}(a,b,c) = \operatorname{sgn}_u(a)\,b\,\operatorname{sgn}_v(c)$ over $\mathbb{F}_3$, each an involution on every cycle; (ii) the failure is not special to three letters: over every alphabet with at least three letters a *conditional transposition* is a cycle-bijective involution using two window cells, whereas over the binary alphabet the classification is **true**, so for $A = \{0,\dots,q-1\}$ the classification holds if and only if $q \le 2$; (iii) restricted to affine rules $g(a,b,c) = \alpha a + \beta b + \gamma c + \delta$ over $\mathbb{F}_3$ the classification is exactly right — such a rule is cycle-bijective iff exactly one of $\alpha,\beta,\gamma$ is nonzero — and inside this class the infinite test collapses to injectivity on the single cycle of length $8$, a bound shown to be sharp by the rule $a+b+2c$; (iv) in general, injectivity descends to divisor cycle lengths, and a splicing (pigeonhole) argument on the pair graph reduces cycle-bijectivity to the finitely many lengths $1,\dots,q^4$, so the property is decidable, and a single length $(q^4)!$ suffices; (v) a reversible rule may require a strictly wider inverse: an explicit ternary rule is cycle-bijective with a window-four decoder, admits no window-three decoder at any offset, and has no radius-one inverse automaton.

**Keywords:** reversible cellular automata, radius-one local rule, ternary alphabet, finite field $\mathbb{F}_3$, decidability, pair graph, involution, inverse neighbourhood radius, lightweight symmetric primitives.

---

## 1. Introduction

### 1.1 The object

Fix a finite alphabet $A$ with $q = |A| \ge 1$ letters. A **radius-one local rule** is a function
$$g : A \times A \times A \longrightarrow A .$$
For each $n \ge 1$ it induces a **global map** on the cyclic configuration space $A^{\mathbb{Z}/n}$,
$$G_n : A^{\mathbb{Z}/n} \to A^{\mathbb{Z}/n}, \qquad (G_n s)(i) \;=\; g\bigl(s(i-1),\,s(i),\,s(i+1)\bigr),$$
indices taken modulo $n$. Since $A^{\mathbb{Z}/n}$ is finite, $G_n$ is bijective iff it is injective.

**Definition 1.1 (Cycle-bijectivity).** A local rule $g$ is *cycle-bijective* (equivalently, *reversible on all cycles*) when $G_n$ is a bijection for every $n \ge 1$.

**Definition 1.2 (Single-coordinate rule).** A local rule $g$ is a *single-coordinate rule* when there are a permutation $\sigma$ of $A$ and an index $j \in \{1,2,3\}$ with $g(a,b,c) = \sigma(w_j)$ for all $(a,b,c)$, where $(w_1,w_2,w_3) = (a,b,c)$.

Single-coordinate rules are cycle-bijective: the global map is a cyclic shift composed with the pointwise relabelling by $\sigma$, and both are bijections of $A^{\mathbb{Z}/n}$ for every $n$. Over a $q$-letter alphabet there are $3 \cdot q!$ of them, hence $18$ for $q = 3$ and $6$ for $q=2$.

### 1.2 The claim under test

> **Classification claim.** *Every cycle-bijective radius-one rule is a single-coordinate rule.*

This is a genuinely falsifiable statement, and it is the organising question of this paper. Our results place it exactly: it is true for $q \le 2$, false for every $q \ge 3$, and true again over any $q$ if one restricts to affine rules over a field.

### 1.3 Why the question matters

Reversible cellular automata are the discrete models of microscopically reversible physics and the basic primitive of reversible computing. In symmetric cryptography they are attractive as round functions: a cycle-bijective radius-one rule is, for every message length $n$, a permutation of $A^n$ computed by $n$ identical constant-size gates in a single parallel pass. Two questions then become design questions rather than curiosities. First, *does anything nontrivial exist?* — if all cycle-bijective rules were single-coordinate rules, the model would offer no mixing whatsoever, only relabelled rotations. Second, *is reversibility checkable?* — a designer must be able to certify invertibility of a candidate round function for all message lengths simultaneously. Our answers are, respectively, "yes as soon as the alphabet has three letters, and only nonlinearly" and "yes, by a bounded and explicit finite test".

### 1.4 Results and organisation

Section 2 develops the decoder criterion that underlies every positive result. Section 3 refutes the classification claim over three letters and produces eighteen counterexamples. Section 4 shows that the failure is universal for $q \ge 3$ while the binary case is rigid, giving the size-two dichotomy. Section 5 classifies affine ternary rules and derives the sharp length-$8$ criterion. Section 6 proves divisor monotonicity and the splicing bound $q^4$, hence decidability. Section 7 exhibits the inverse-radius gap. Section 8 gives algorithms; Section 9 discusses cryptographic consequences; Section 10 lists open problems.

Throughout, $\mathbb{F}_3 = \{0,1,2\}$ denotes the three-element field, with $2 = -1$.

---

## 2. Local decoders and cycle-bijectivity

Everything positive in this paper flows from a single principle: a *local* inverse forces bijectivity at *all* cycle lengths simultaneously, including lengths shorter than the decoder's own window.

**Definition 2.1 (Window-three decoder).** A local rule $d : A^3 \to A$ is a *window-three decoder* for $g$ if
$$d\bigl(g(v,w,x),\, g(w,x,y),\, g(x,y,z)\bigr) = x \qquad \text{for all } v,w,x,y,z \in A .$$

**Theorem 2.2 (Decoder criterion).** If $g$ admits a window-three decoder, then $g$ is cycle-bijective.

*Proof sketch.* Fix $n \ge 1$ and a configuration $u \in A^{\mathbb{Z}/n}$. Expanding the global map at the three indices $i-1$, $i$, $i+1$ and using the identity of Definition 2.1 with $(v,w,x,y,z) = (u(i-2),u(i-1),u(i),u(i+1),u(i+2))$ gives
$$d\bigl(G_n u(i-1),\, G_n u(i),\, G_n u(i+1)\bigr) = u(i)$$
for every $i \in \mathbb{Z}/n$. Hence $u$ is a function of $G_n u$, so $G_n$ is injective, and by finiteness bijective. Note that the argument is purely index-arithmetic in $\mathbb{Z}/n$ and does not require $n \ge 3$: for small $n$ the five letters $v,\dots,z$ simply repeat, which the identity tolerates because it is universally quantified. $\square$

**Definition 2.3 (Window-four right decoder).** A map $d : A^4 \to A$ is a *window-four right decoder* for $g$ if
$$d\bigl(g(x_0,x_1,x_2),\,g(x_1,x_2,x_3),\,g(x_2,x_3,x_4),\,g(x_3,x_4,x_5)\bigr) = x_0$$
for all $x_0,\dots,x_5 \in A$.

**Theorem 2.4.** If $g$ admits a window-four right decoder, then $g$ is cycle-bijective.

*Proof sketch.* Identical in shape to Theorem 2.2: expand $G_n u$ at the indices $i+1,\dots,i+4$ and apply the identity to recover $u(i)$. $\square$

**Definition 2.5 (Self-decoding).** $g$ is *self-decoding* if it is its own window-three decoder, i.e. $g(g(v,w,x),g(w,x,y),g(x,y,z)) = x$ for all letters.

**Corollary 2.6.** A self-decoding rule satisfies $G_n \circ G_n = \mathrm{id}$ for every $n$; it is an involution on every cycle, in particular cycle-bijective.

Two elementary closure properties will be used freely.

**Proposition 2.7 (Closure).** Let $g$ be cycle-bijective. Then:
1. for any bijection $f : A \to A$, the rule $(a,b,c) \mapsto f(g(a,b,c))$ is cycle-bijective;
2. for any permutation $\sigma$ of $A$, the conjugate $(a,b,c) \mapsto \sigma^{-1}\bigl(g(\sigma a, \sigma b, \sigma c)\bigr)$ is cycle-bijective;
3. the spatial reflection $(a,b,c) \mapsto g(c,b,a)$ is cycle-bijective.

*Proof sketch.* In each case the new global map is a composition of $G_n$ with bijections of $A^{\mathbb{Z}/n}$: pointwise post-composition by $f$; pointwise conjugation by $\sigma$; and, for reflection, conjugation by the index involution $i \mapsto -i$ of $\mathbb{Z}/n$, which exchanges the two shifts. $\square$

Finally, one necessary condition costs nothing and is used repeatedly.

**Proposition 2.8 (Diagonal test).** If $g$ is cycle-bijective then the *diagonal map* $b \mapsto g(b,b,b)$ is a permutation of $A$.

*Proof sketch.* On the cycle of length $1$ we have $i-1 = i = i+1$, so $G_1$ is precisely the diagonal map under the identification $A^{\mathbb{Z}/1} \cong A$. $\square$

### 2.1 Dependence on window cells

**Definition 2.9.** $g$ *depends on its left cell* if $g(a,b,c) \ne g(a',b,c)$ for some $a,a',b,c$; dependence on the middle and right cells is defined analogously.

**Proposition 2.10.** If $g$ depends on at least two of its three cells, it is not a single-coordinate rule.

*Proof sketch.* A single-coordinate rule $\sigma \circ \pi_j$ is constant in each of the other two arguments. $\square$

This is the criterion by which all our counterexamples are certified nontrivial.

---

## 3. Refutation over three letters

### 3.1 The sign twist

Work in $\mathbb{F}_3$, whose unit group is $\{1,2\} = \{\pm 1\}$; every unit $u$ satisfies $u^2 = 1$.

**Definition 3.1.** For a unit $u \in \{1,2\}$ define $\operatorname{sgn}_u : \mathbb{F}_3 \to \mathbb{F}_3$ by
$$\operatorname{sgn}_u(x) = \begin{cases} 1, & x = 0, \\ u, & x \ne 0. \end{cases}$$
It is unit-valued and even, $\operatorname{sgn}_u(-x) = \operatorname{sgn}_u(x)$: it detects only whether its argument vanishes.

**Definition 3.2 (Sign-twisted rules).** For units $u,v$ put
$$g_{u,v}(a,b,c) \;=\; \operatorname{sgn}_u(a)\; b\; \operatorname{sgn}_v(c).$$

The rule multiplies the current cell by a unit determined by the *vanishing pattern* of its two neighbours.

**Lemma 3.3 (Unit invariance).** If $p, q$ are units then $\operatorname{sgn}_u(p\,x\,q) = \operatorname{sgn}_u(x)$ for all $x$.

*Proof sketch.* $p x q = 0$ iff $x = 0$, since $\mathbb{F}_3$ is a field and $p,q \ne 0$; and $\operatorname{sgn}_u$ depends only on that condition. $\square$

**Theorem 3.4 (Sign-twisted rules are self-decoding involutions).** For all units $u,v$ the rule $g_{u,v}$ is self-decoding. Consequently $G_n \circ G_n = \mathrm{id}$ on $A^{\mathbb{Z}/n}$ for every $n \ge 1$, and $g_{u,v}$ is cycle-bijective.

*Proof sketch.* Write $y_1 = g_{u,v}(v',w,x)$, $y_2 = g_{u,v}(w,x,y)$, $y_3 = g_{u,v}(x,y,z)$. Each $y_k$ is the middle letter of its window multiplied by units, so by Lemma 3.3
$$\operatorname{sgn}_u(y_1) = \operatorname{sgn}_u(w), \qquad \operatorname{sgn}_v(y_3) = \operatorname{sgn}_v(y).$$
Therefore
$$g_{u,v}(y_1,y_2,y_3) = \operatorname{sgn}_u(y_1)\, y_2\, \operatorname{sgn}_v(y_3) = \operatorname{sgn}_u(w)\bigl(\operatorname{sgn}_u(w)\,x\,\operatorname{sgn}_v(y)\bigr)\operatorname{sgn}_v(y) = u^{2\epsilon_1} v^{2\epsilon_2} x = x,$$
using $u^2 = v^2 = 1$. Corollary 2.6 finishes the proof. $\square$

The conceptual content of Theorem 3.4 is that the twisting factor is *recomputable from the output*: multiplication by units cannot destroy the zero/nonzero pattern that the twist reads.

**Definition 3.5.** Let $g^\star := g_{2,2}$, i.e. $g^\star(a,b,c) = \operatorname{sgn}_2(a)\,b\,\operatorname{sgn}_2(c)$: flip the sign of the current cell once for each nonzero neighbour.

**Theorem 3.6 (Refutation).** $g^\star$ is cycle-bijective and depends on all three cells of its window; hence it is not a single-coordinate rule, and the classification claim is false over the ternary alphabet.

*Proof sketch.* Cycle-bijectivity is Theorem 3.4. For dependence, read three entries off the finite table: $g^\star(1,1,0)= 2 \ne 1 = g^\star(0,1,0)$ exhibits left dependence, $g^\star(0,1,0)=1 \ne 2 = g^\star(0,2,0)$ middle dependence, and $g^\star(0,1,1)=2 \ne 1 = g^\star(0,1,0)$ right dependence. Apply Proposition 2.10. $\square$

### 3.2 Eighteen counterexamples

By Proposition 2.7(1) we may post-compose with the affine permutations $x \mapsto cx + d$ of $\mathbb{F}_3$, $c$ a unit.

**Definition 3.7.** For units $u,v,c$ and any $d \in \mathbb{F}_3$ set $h_{u,v,c,d}(a,b,x) = c\,g_{u,v}(a,b,x) + d$.

**Theorem 3.8 (Quantitative refutation).** Each $h_{u,v,c,d}$ is cycle-bijective. If $(u,v) \ne (1,1)$ then $h_{u,v,c,d}$ depends on at least two window cells and hence is not a single-coordinate rule. The $18$ parameter tuples with $u,v,c$ units and $(u,v)\neq (1,1)$ give $18$ pairwise distinct local rules. Therefore there exist at least $18$ cycle-bijective ternary rules that are not single-coordinate rules — exactly as many as the total number of rules the claim allows.

*Proof sketch.* Cycle-bijectivity: Theorem 3.4 and Proposition 2.7(1), since $x \mapsto cx+d$ is a bijection of $\mathbb{F}_3$ for $c \ne 0$. Nontriviality and distinctness are finite verifications over the $3^3$ window arguments and the $18$ parameter tuples. $\square$

The counting is the sharpest way to state the failure: the claim does not merely miss a rule, it misses at least as many rules as it names. (An independent computational census of the ternary rule space reports $1\,800$ cycle-bijective rules in total, of which only $18$ are single-coordinate; we record that figure as numerical evidence rather than as one of the theorems proved here.)

---

## 4. The size-two dichotomy

### 4.1 Failure over every alphabet with at least three letters

The sign trick used the field structure of $\mathbb{F}_3$, but its mechanism — *a marker letter that a permutation fixes* — is purely combinatorial.

**Definition 4.1 (Conditional transposition).** Let $A$ contain three distinct letters $x_0, x_1, x_2$ and let $\tau = (x_1\;x_2)$ be the transposition exchanging $x_1$ and $x_2$ and fixing everything else. Define
$$t(a,b,c) = \begin{cases} \tau(b), & c = x_0, \\ b, & c \ne x_0. \end{cases}$$

**Lemma 4.2.** $\tau(x_0) = x_0$, and for every $y \in A$ one has $\tau(y) = x_0 \iff y = x_0$.

**Theorem 4.3.** $t$ is self-decoding, hence an involution on every cycle and cycle-bijective. Moreover $t$ depends on its middle and on its right cell, so it is not a single-coordinate rule.

*Proof sketch.* Let $y_1 = t(v,w,x)$, $y_2 = t(w,x,y)$, $y_3 = t(x,y,z)$. Since $y_3 \in \{x, \tau(x)\}$, Lemma 4.2 gives $y_3 = x_0 \iff x = x_0$; that is, the *condition* that governs the middle output is unchanged by the rule. Hence $t(y_1,y_2,y_3) = \tau^{[x=x_0]}(y_2) = \tau^{[x = x_0]}\tau^{[x=x_0]}(x) = x$ because $\tau^2 = \mathrm{id}$. Dependence: $t(x_0,x_1,x_0) = x_2 \ne x_1 = t(x_0,x_2,x_0)$ (middle) and $t(x_0,x_1,x_0) = x_2 \ne x_1 = t(x_0,x_1,x_1)$ (right, using $x_1 \ne x_0$). $\square$

**Corollary 4.4.** For every alphabet with at least three letters, the classification claim is false.

### 4.2 Rigidity over two letters

**Theorem 4.5 (Binary rigidity).** Let $A$ be a two-letter alphabet. If a radius-one rule $g$ is bijective on the cycles of lengths $1$, $2$, $3$ and $4$, then $g$ is a single-coordinate rule. Consequently every cycle-bijective binary rule is a single-coordinate rule, and there are exactly six.

*Proof sketch.* An exhaustive verification over the $2^8 = 256$ binary rules: for each, bijectivity of the four global maps $G_1, G_2, G_3, G_4$ (acting on $2, 4, 8, 16$ configurations respectively) is decided directly, and exactly the six single-coordinate rules survive. The bound $4$ is sharp: exactly $20$ of the $256$ rules pass the weaker test using only the lengths $1,2,3$, so fourteen impostors are eliminated by, and only by, the cycle of length $4$. $\square$

**Theorem 4.6 (Size-two dichotomy).** For the alphabet $A = \{0,1,\dots,q-1\}$, the statement "every cycle-bijective radius-one rule over $A$ is a single-coordinate rule" holds if and only if $q \le 2$.

*Proof sketch.* For $q \ge 3$, Corollary 4.4. For $q \le 1$ the statement is trivial because the alphabet is a subsingleton and every rule is the identity coordinate composed with the identity permutation. For $q = 2$, Theorem 4.5. $\square$

Radius-one reversibility is therefore rigid exactly up to two letters; the ternary counterexamples of Section 3 are the smallest instance of a universal phenomenon.

---

## 5. The affine class: the claim is true, and one length decides

### 5.1 Classification

**Definition 5.1.** For $\alpha,\beta,\gamma,\delta \in \mathbb{F}_3$ let $\ell_{\alpha\beta\gamma\delta}(a,b,c) = \alpha a + \beta b + \gamma c + \delta$.

On the cycle $\mathbb{Z}/n$ the global map of $\ell_{\alpha\beta\gamma\delta}$ is the affine map $s \mapsto L s + \delta \mathbf{1}$ where $L$ is multiplication by the Laurent polynomial $\alpha x^{-1} + \beta + \gamma x$ in the group algebra $\mathbb{F}_3[x]/(x^n - 1)$. Injectivity is equivalent to triviality of $\ker L$.

**Lemma 5.2 (Kernel obstruction).** If some $s \ne 0$ on $\mathbb{Z}/n$ satisfies $\alpha s(i-1) + \beta s(i) + \gamma s(i+1) = 0$ for all $i$, then $G_n$ is not injective; conversely, injectivity of $G_n$ is equivalent to triviality of that kernel.

*Proof sketch.* $G_n(s) - G_n(t)$ depends only on the difference $s-t$ through the linear part $L$; so $G_n$ is injective iff $L$ is, i.e. iff $\ker L = 0$. In particular a nonzero kernel vector collides with the zero configuration. $\square$

**Theorem 5.3 (Affine classification).** $\ell_{\alpha\beta\gamma\delta}$ is cycle-bijective if and only if exactly one of $\alpha, \beta, \gamma$ is nonzero. In that case it equals a single window cell followed by the permutation $x \mapsto \alpha x + \delta$ (respectively $\beta$, $\gamma$), so the classification claim — false in general — is true inside the affine class.

*Proof sketch.* ($\Leftarrow$) If, say, $\beta \ne 0$ and $\alpha = \gamma = 0$, then $\ell = \sigma \circ \pi_2$ with $\sigma(y) = \beta y + \delta$, a permutation of $\mathbb{F}_3$; single-coordinate rules are cycle-bijective.

($\Rightarrow$) Conceptually: the kernel of $L$ on $\mathbb{Z}/n$ is nontrivial for some $n$ unless the polynomial $P(x) = \alpha + \beta x + \gamma x^2$ has no root among the roots of unity over $\mathbb{F}_3$, i.e. no nonzero root at all in $\overline{\mathbb{F}_3}$; and a polynomial of degree $\le 2$ with no nonzero root is a monomial, which is exactly the condition that one coefficient is nonzero and the others vanish. Effectively: the multiplicative group $\mathbb{F}_9^\times$ is cyclic of order $8$, so the only relevant orders of roots of unity are $1,2,4,8$, and it suffices to exhibit, for each of the $21$ coefficient triples that are *not* of monomial type, an explicit nonzero kernel vector on a cycle of length $1$, $2$, $4$ or $8$. Five vectors suffice up to the case analysis:
$$k_1 = (1) \ \text{on } \mathbb{Z}/1,\quad k_2 = (2,1)\ \text{on } \mathbb{Z}/2, \quad k_4 = (2,0,1,0) \ \text{on } \mathbb{Z}/4,$$
$$k_8 = (1,1,2,0,2,2,1,0), \qquad k_8' = (1,2,2,0,2,1,1,0) \quad \text{on } \mathbb{Z}/8 .$$
Each of the $21$ bad triples annihilates one of these, a finite check. $\square$

An exhaustive computation over all $81$ affine rules confirms the classification and shows that the first failure length is $1$ for nine coefficient triples, $2$ for six, $4$ for two and $8$ for four — precisely the divisors of $8$, as the root-of-unity heuristic predicts.

### 5.2 One length decides, and it is exactly eight

We need a general propagation principle, proved in Section 6 but stated here because it is what compresses the four bad lengths into one.

**Theorem 5.4 (Divisor monotonicity).** Let $m \mid n$. If $G_n$ is injective then $G_m$ is injective. Equivalently, non-injectivity at $m$ propagates to every multiple of $m$.

**Theorem 5.5 (The length-eight criterion).** An affine ternary rule $\ell_{\alpha\beta\gamma\delta}$ is cycle-bijective if and only if its global map on the single cycle of length $8$ is injective — a finite test on $3^8 = 6561$ configurations.

*Proof sketch.* One direction is trivial. For the other, if the coefficients are not of monomial type, Theorem 5.3 furnishes a kernel vector at some length $m \in \{1,2,4,8\}$; since every such $m$ divides $8$, Theorem 5.4 lifts the failure to length $8$. Contrapositively, injectivity at $8$ forces monomial type, hence cycle-bijectivity. $\square$

**Theorem 5.6 (Sharpness).** The rule $\ell_{1,1,2,0}(a,b,c) = a + b + 2c$ is injective on every cycle of length $1,2,3,4,5,6,7$ and is not cycle-bijective: the configuration $(1,1,2,0,2,2,1,0)$ lies in the kernel on $\mathbb{Z}/8$. Hence no test using only cycles of length $\le 7$ decides cycle-bijectivity, even inside the affine class.

*Proof sketch.* Triviality of the kernel of $x^{-1} + 1 + 2x$ on $\mathbb{Z}/m$ for $m \le 7$ is a finite verification (at most $3^7 = 2187$ configurations per length); the displayed vector is annihilated at length $8$, as one checks site by site. Arithmetically, the characteristic polynomial $2x^2 + x + 1$ has roots of multiplicative order exactly $8$ in $\mathbb{F}_9^\times$, so $8$ is the first length whose roots of unity meet the root set. $\square$

**Corollary 5.7 (Infinitely many bad lengths).** If an affine ternary rule is not cycle-bijective, its global map fails to be injective on *every* multiple of $8$. Bad lengths never occur sporadically.

---

## 6. From an infinite test to a finite one

Cycle-bijectivity quantifies over all $n$. This section makes the quantifier finite and the property decidable, over an arbitrary finite alphabet with $q$ letters.

### 6.1 Divisor monotonicity

**Theorem 6.1.** Let $m \mid n$ and let $\pi : \mathbb{Z}/n \to \mathbb{Z}/m$ be the reduction map. For every $s : \mathbb{Z}/m \to A$,
$$G_n(s \circ \pi) = (G_m s) \circ \pi .$$
Consequently injectivity of $G_n$ implies injectivity of $G_m$.

*Proof sketch.* $\pi$ is a surjective ring homomorphism, so $\pi(i \pm 1) = \pi(i) \pm 1$; substituting into the definition of the global map gives the intertwining identity. If $G_m s = G_m t$ then $G_n(s\circ\pi) = G_n(t\circ\pi)$, whence $s \circ \pi = t \circ \pi$ by injectivity of $G_n$, and $s = t$ by surjectivity of $\pi$. $\square$

**Corollary 6.2 (Factorial chain).** $g$ is cycle-bijective if and only if $G_{k!}$ is injective for every $k \ge 1$: the factorial lengths form a cofinal divisibility chain.

### 6.2 Collisions and the pair graph

**Definition 6.3.** Two sequences $S, T : \mathbb{N} \to A$ are *locally compatible* for $g$ if $g(S_k,S_{k+1},S_{k+2}) = g(T_k,T_{k+1},T_{k+2})$ for all $k$. A *collision of period $p$* is a pair of $p$-periodic locally compatible sequences that differ in some position.

**Proposition 6.4.** For $p \ge 1$, $g$ admits a collision of period $p$ if and only if $G_p$ is not injective.

*Proof sketch.* Unroll a configuration on $\mathbb{Z}/p$ to a $p$-periodic sequence and back; the local compatibility condition is exactly the equality of the two global images, up to the index shift relating the window $(k,k+1,k+2)$ to the window centred at $k+1$. $\square$

Encode a collision by the states it passes through: at position $k$ record
$$\Phi(k) = \bigl(S_k, S_{k+1}, T_k, T_{k+1}\bigr) \in A^4 .$$
The state $\Phi(k)$ determines the admissible continuations, so collisions are exactly the closed walks in the **pair graph** whose vertices are $A^2 \times A^2$, with an edge $\bigl((a,b),(a',b')\bigr) \to \bigl((b,c),(b',c')\bigr)$ whenever $g(a,b,c) = g(a',b',c')$, and which visit at least one vertex with $a \ne a'$.

### 6.3 Splicing

**Lemma 6.5 (Loop splicing).** Suppose a sequence $U$ satisfies $U_a = U_{a+p}$ and $U_{a+1} = U_{a+p+1}$ for some $p \ge 1$. Then the *wrapped* sequence $k \mapsto U_{a + (k \bmod p)}$ is $p$-periodic, and its one- and two-step shifts agree with the corresponding shifts of $U$ at the relevant places. Hence any window-three local condition satisfied by $U$ is inherited by the wrapped sequence.

*Proof sketch.* Only the seam at multiples of $p$ needs checking, and there the two hypotheses supply exactly the two letters required by a window of width three. $\square$

**Theorem 6.6 (Shortening).** If $g$ admits a collision of period $n$ with $n > q^4$, then it admits a collision of some period $m$ with $0 < m < n$.

*Proof sketch.* There are only $q^4$ states $\Phi(k)$, so among the positions $0,1,\dots,q^4$ two carry the same state, say $\Phi(i) = \Phi(j)$ with $i < j \le q^4 < n$. Cut the cyclic word at $i$ and $j$. Two splices are legitimate, by Lemma 6.5 applied to both $S$ and $T$: *keep* the segment $[i,j)$, obtaining a collision candidate of period $j - i$; or *delete* it, obtaining one of period $n - (j-i)$. Both are locally compatible everywhere, since the boundary states coincide. Each is a genuine collision provided it retains a position where $S$ and $T$ differ, and at least one of the two must, because every position of the original cycle lies in one of the two parts. Both periods are strictly smaller than $n$. $\square$

**Theorem 6.7 (Finite test).** Over an alphabet with $q$ letters, $g$ is cycle-bijective if and only if $G_m$ is injective for all $1 \le m \le q^4$.

*Proof sketch.* One direction is trivial. Conversely, a failure at some $n$ yields a collision of period $n$ (Proposition 6.4); iterating Theorem 6.6 and inducting on the period produces a collision of period $m \le q^4$, hence a failure at $m$. $\square$

**Corollary 6.8 (Decidability).** Cycle-bijectivity of a radius-one rule over a finite alphabet is decidable: it is equivalent to a bounded conjunction of injectivity tests. For $q=3$ the lengths $1,\dots,81$ decide everything.

**Corollary 6.9 (A single length).** $g$ is cycle-bijective if and only if $G_{(q^4)!}$ is injective.

*Proof sketch.* Every $m \le q^4$ divides $(q^4)!$; combine Theorem 6.7 with Theorem 6.1. $\square$

Corollary 6.9 is the general form of the affine phenomenon of Theorem 5.5, where the single length $8$ sufficed. The two results together frame the natural quantitative question: the proved bound is $q^4$, the largest first-failure length ever observed is $q^2$ ($4$ for $q=2$, $8$ for $q=3$), and Theorem 5.6 shows the value $8$ is attained for $q = 3$. So for three letters the truth lies between $8$ and $81$, and conjecturally at $9$.

---

## 7. The inverse can be wider than the rule

All counterexamples so far were involutions, so their inverse automata had the same radius. This is not forced.

**Definition 7.1.** Let $\operatorname{sw}$ be the transposition of $0$ and $1$ in $\mathbb{F}_3$ fixing $2$, and define
$$w(a,b,c) = \begin{cases} \operatorname{sw}(a), & b \ne 0 \text{ and } c = 2, \\ a, & \text{otherwise.}\end{cases}$$

**Theorem 7.2.** $w$ is cycle-bijective. Indeed the window-four map
$$d(u_0,u_1,u_2,u_3) = \begin{cases} \operatorname{sw}(u_0), & u_2 = 2 \text{ and } \bigl(u_1 \ne 1 \text{ if } u_3 = 2, \text{ else } u_1 \ne 0\bigr), \\ u_0, & \text{otherwise},\end{cases}$$
is a window-four right decoder for $w$.

*Proof sketch.* The decoding identity $d(w(x_0,x_1,x_2),w(x_1,x_2,x_3),w(x_2,x_3,x_4),w(x_3,x_4,x_5)) = x_0$ is a finite check over the $3^6 = 729$ words $x_0\cdots x_5$. Conceptually: $\operatorname{sw}$ fixes the letter $2$, so the third output $w(x_2,x_3,x_4)$ equals $2$ exactly when $x_2 = 2$, which is the second half of the firing condition at the leading cell; the first half, $x_1 \ne 0$, is recovered from the second output after correcting for whether the transposition fired there, which is what the case distinction on $u_3$ does. Then Theorem 2.4 applies. $\square$

**Theorem 7.3 (No window-three decoder).** For every local rule $d : \mathbb{F}_3^3 \to \mathbb{F}_3$ and every offset $j \in \{1,\dots,5\}$, the identity
$$d\bigl(w(x_1,x_2,x_3),\,w(x_2,x_3,x_4),\,w(x_3,x_4,x_5)\bigr) = x_j$$
fails for some word $x_1\cdots x_5$.

*Proof sketch.* For each offset one exhibits two words with identical output triples but different letters at that offset; no function of the triple can then return both required values. Explicit witnesses: $(0,0,2,0,0)$ vs $(1,1,2,2,0)$ for the first cell; $(0,0,0,0,0)$ vs $(0,1,1,2,2)$ for the second; $(0,0,0,0,0)$ vs $(0,0,1,1,2)$ for the third; $(0,0,0,0,0)$ vs $(0,0,0,1,0)$ for the fourth; $(0,0,0,0,0)$ vs $(0,0,0,0,1)$ for the fifth. $\square$

**Theorem 7.4 (No radius-one inverse automaton).** There is no local rule $d : \mathbb{F}_3^3 \to \mathbb{F}_3$ whose global maps invert those of $w$ on all cycles.

*Proof sketch.* Take $n = 5$ and compare the all-zero configuration with $s = (0,0,1,1,2)$. Their images under $G_5^{w}$ agree in the three consecutive positions $1,2,3$, while $s(2) = 1 \ne 0$. A radius-one inverse would have to output both $0$ and $1$ from the same three-letter input. $\square$

**Corollary 7.5.** $w$ is cycle-bijective, is not a single-coordinate rule (it depends on all three window cells), and its decoding width is exactly four. In particular there exist reversible radius-one rules whose inverse automaton has strictly larger neighbourhood.

The intuition is that the transposition fixes the marker letter $2$, making the sites carrying $2$ visible in the output; but deciding whether the rule *fired* at a cell requires knowing whether its right neighbour is nonzero, and that requires looking one further cell to the right. Information needed to invert travels a bounded but strictly greater distance than the rule's own reach.

---

## 8. Algorithms

### 8.1 Deciding reversibility via the pair graph

Theorem 6.7 already gives a decision procedure, but its cost, $\sum_{m \le q^4} q^m$, is astronomically impractical. The pair-graph formulation of Section 6.2 turns the same mathematics into a polynomial-time algorithm.

**Algorithm A (pair-graph reversibility test).**
*Input:* a rule table $g : A^3 \to A$ with $|A| = q$.
*Output:* whether $g$ is cycle-bijective.

1. Build the directed graph $\Gamma$ with vertex set $A^2 \times A^2$ ($q^4$ vertices) and an edge $((a,b),(a',b')) \to ((b,c),(b',c'))$ for each pair $(c,c')$ with $g(a,b,c) = g(a',b',c')$.
2. Compute the set $C$ of vertices lying on a directed cycle (equivalently, the vertices in strongly connected components containing an edge).
3. Return **false** if some $((a,b),(a',b')) \in C$ has $a \ne a'$, and **true** otherwise.

*Correctness.* By Proposition 6.4 and the encoding of Section 6.2, a failure of injectivity at some length is precisely a closed walk of $\Gamma$ visiting a vertex with $a \ne a'$; a vertex lies on a closed walk iff it lies on a directed cycle.

*Complexity.* $\Gamma$ has $q^4$ vertices and at most $q^6$ edges, and strongly connected components are computed in linear time, so the test runs in $O(q^6)$ time — independent of the cycle length, which is the whole point. For $q = 3$ this is a few hundred operations.

### 8.2 Certifying reversibility by exhibiting a decoder

For design purposes one wants more than a yes/no answer: one wants the inverse. Searching for a decoder of window $k$ is a constraint-satisfaction problem over the $q^{q^k}$ candidate tables, but it can be solved greedily: enumerate all input words of length $k+2$, compute the output word of length $k$, and check that the map "output word $\mapsto$ designated input cell" is well defined; if it is, that map *is* the decoder. This costs $O(q^{k+2})$ and returns either a decoder table or an explicit pair of colliding words — which is exactly the witness format used in Theorem 7.3.

### 8.3 Affine screening

For affine rules the whole apparatus collapses to arithmetic. Given $(\alpha,\beta,\gamma)$, the rule is reversible iff exactly one coefficient is nonzero (Theorem 5.3); equivalently, iff the polynomial $\alpha + \beta x + \gamma x^2$ is a monomial; equivalently, iff the single global map on $\mathbb{Z}/8$ is injective (Theorem 5.5). The first test is $O(1)$.

---

## 9. Discussion: consequences for symmetric-primitive design

**Existence of nontrivial local permutations.** Over two letters, reversible radius-one dynamics is exhausted by shift-and-relabel: as a mixing layer it is worthless. Over three letters the picture changes qualitatively — there are cycle-bijective rules that read all three window cells, and at least eighteen of them are not even close to the trivial ones. Each such rule is, for every $n$, a permutation of $\{0,1,2\}^n$ realised by $n$ identical constant-size gates in one parallel pass, with no key schedule and no data-dependent control flow. That is the profile of a lightweight round-function component.

**Nonlinearity is structural, not optional.** Theorem 5.3 shows the classification claim is *true* inside the affine class over $\mathbb{F}_3$: every affine cycle-bijective rule is a shift composed with an affine relabelling. Hence every interesting reversible radius-one rule is nonlinear. A designer cannot get local reversible mixing from linear algebra over the alphabet field; the mixing and the nonlinearity arrive together.

**Certified invertibility for all block lengths.** Corollaries 6.8 and 6.9 mean that "this round function is a permutation for every message length" is a decidable, mechanically checkable property, and Algorithm A checks it in time depending on the alphabet only. In the affine class the certificate is a single injectivity test on $6561$ states (Theorem 5.5), and Theorem 5.6 shows one cannot economise below length $8$ — a warning against the tempting shortcut of validating a candidate on short blocks only.

**A provable forward/backward asymmetry.** Theorem 7.4 exhibits a rule whose forward pass is radius one but whose inverse pass provably requires a wider neighbourhood. This is an unconditional statement about circuit locality, not a complexity assumption; it is the kind of structural asymmetry a lightweight design exploits when encryption must be cheaper than decryption (or vice versa).

**Two warnings.** First, involutions are cryptographically fragile as round functions: the sign-twisted family satisfies $G_n^2 = \mathrm{id}$, so iterating it is useless without alternation. Second, one pass of a radius-one rule moves information one cell; diffusion over an $n$-cell block requires $\Omega(n)$ rounds. The results here characterise the *building blocks*; assembling them into a cipher is a separate matter, and the natural next step.

---

## 10. Future work

1. **The quadratic barrier.** Lower the finite test from $q^4$ to $q^2$. The pigeonhole in Theorem 6.6 ranges over all $q^4$ pair states, but a difference between the two configurations can only be transported through states *reachable while the difference persists*; counting those — a differing pair together with one shared context letter — gives about $q^2$. For $q=3$ the truth is pinched between $8$ (attained, Theorem 5.6) and $81$ (proved).

2. **Exact census and orbit structure.** Determine, with proof, the number of cycle-bijective ternary rules and the orbits under the natural symmetry group generated by alphabet conjugation, post-composition by permutations, and spatial reflection. Which orbits are involutive, and which have unbounded inverse radius?

3. **Inverse-radius spectrum.** Theorem 7.4 gives decoding width exactly $4$ for one rule. Is there, for every $k$, a radius-one ternary rule whose minimal decoding width is exactly $k$? Over larger alphabets, how does the maximal inverse radius grow with $q$?

4. **Beyond involutions.** Classify the cycle-bijective ternary rules of large order in the symmetric group of $A^{\mathbb{Z}/n}$ — the cryptographically interesting ones. What is the maximal order attainable as a function of $n$?

5. **Higher radius and higher dimension.** The splicing argument only uses that the rule has a bounded neighbourhood; the analogue for radius $r$ should give a bound $q^{O(r)}$. In two dimensions reversibility is undecidable, so a sharp frontier separates the two regimes; where exactly does the pair-graph method break?

6. **From round functions to primitives.** Compose the nontrivial reversible rules with alternating alphabet relabellings and study the resulting permutation groups: which subsets generate the full alternating group of $\{0,1,2\}^n$, and how fast do they mix?

---

## 11. Conclusion

For a two-letter alphabet, reversible radius-one dynamics is rigid: it is exactly shift-and-relabel. For three letters, it is not — reversible rules exist that read every cell of their window, in quantity at least equal to the trivial ones, and the mechanism generalises to every alphabet with at least three letters, giving a clean dichotomy at size two. Inside the affine world over $\mathbb{F}_3$ rigidity is restored exactly, and the arithmetic of roots of unity in $\mathbb{F}_9$ pins the decisive cycle length at $8$, sharply. In general, the infinite reversibility test is finite — the cycle lengths up to $q^4$ suffice, hence a single length $(q^4)!$ does, and the property is decidable in time polynomial in the rule table via the pair graph. Finally, reversibility does not come with symmetric cost: a radius-one rule can require a strictly wider inverse. Together these results map the small world of ternary radius-one automata: what is impossible, what is abundant, what is checkable, and where the asymmetries hide.
