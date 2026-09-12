# Separated Principal Filtrations: Heights, Chain Conditions, and the Archimedean Boundary

**Author:** Aristotle
**Date:** 2026-09-12

---

## Abstract

The elementary fact that $\bigcap_{n\ge 0}(2^n) = 0$ in $\mathbb{Z}$ is the shadow of a general theory. For a commutative domain $R$ and an element $a \in R$ we study the *principal $a$-adic filtration* $n \mapsto (a^n)$ and call it **separated** when $\bigcap_n (a^n) = 0$. We prove two *a priori* independent sufficient conditions for separation: a chain condition (well-founded divisibility, which covers all Noetherian domains and all unique factorization domains) applied to a non-unit $a$, and a *height condition* asserting merely the existence of some function $v : R \to \mathbb{N}$ with $v(x) < v(ax)$ for all $x \ne 0$. Our main structural theorem is that over a domain the height condition is not only sufficient but **necessary**: separation holds if and only if such a height function exists, and the $a$-adic order $\mathrm{ord}_a$ is the pointwise minimal height function. Consequently the Krull-type intersection theorem is fundamentally a statement about the existence of an $\mathbb{N}$-valued height, with chain conditions serving only as a device for producing one. We complement this with three further characterisations — the intersection $J = \bigcap_n(a^n)$ is the greatest fixed point of $I \mapsto (a)\cdot I$ on the ideal lattice; separation is equivalent to Hausdorffness of the $a$-adic topology; separation is equivalent to injectivity of the map into the $a$-adic completion — and with the construction, for prime $a$, of a genuine non-archimedean absolute value $\|x\|_a = 2^{-\mathrm{ord}_a(x)}$. Finally we delimit the theory sharply: in the classical $D + M$ domain $S = \mathbb{Z} + X\,\mathbb{Q}[X]$ the element $2$ is a nonzero non-unit with $\bigcap_n(2^n) = X\mathbb{Q}[X] \neq 0$, so that no height function for $2$ exists on $S$ and $S$ is neither Noetherian nor a UFD; and the polynomial ring $\mathbb{Q}[X_0, X_1, \dots]$ shows that the chain-condition hypothesis is strictly more general than the Noetherian one.

**Keywords:** Krull intersection theorem, principal filtration, adic topology, height function, multiplicity, non-archimedean absolute value, Nakayama's lemma, $D+M$ construction.

---

## 1. Introduction

### 1.1 The motivating fact

Every student of arithmetic knows that no nonzero integer is divisible by all powers of $2$: if $2^n \mid m$ and $m \ne 0$ then $2^n \le |m|$, which fails once $n$ exceeds $\log_2|m|$. In ideal-theoretic language,
$$\bigcap_{n \ge 0} (2^n) = 0 \qquad \text{in } \mathbb{Z}.$$
The statement is so elementary that it is easy to miss how much it encodes. It is the assertion that the $2$-adic valuation on $\mathbb{Z}$ is finite on nonzero elements; equivalently, that the $2$-adic absolute value is nondegenerate; equivalently, that the $2$-adic topology on $\mathbb{Z}$ is Hausdorff; equivalently, that $\mathbb{Z}$ embeds in $\mathbb{Z}_2$.

### 1.2 The generalisation and the question

Replace $\mathbb{Z}$ by a commutative domain $R$ and $2$ by an arbitrary $a \in R$. The filtration $n \mapsto (a^n)$ still descends; when does it descend to zero? The two obvious obstructions — $a$ a unit (filtration constant, $=R$), and the trivial ring — are easily excluded. The nontrivial question is whether the remaining hypothesis "$a$ is a nonzero non-unit" suffices. It does not, and the whole content of the theory lies in identifying what does.

Two answers are classical in spirit. The first is Krull-flavoured and imposes finiteness on $R$. The second is valuation-flavoured and imposes nothing on $R$ beyond the existence of a measuring device. Our main contribution is that over a domain the second is *equivalent* to separation, so it subsumes the first conceptually: chain conditions are merely one mechanism for producing heights.

### 1.3 Summary of results

Throughout, $R$ is a commutative ring, usually a domain, and $a \in R$.

- **§2** sets up the filtration and the separation predicate and disposes of degenerate elements.
- **§3** proves the **Height Criterion** (Theorem 3.2): the existence of any $v : R \to \mathbb{N}$ with $v(x) < v(ax)$ for $x \ne 0$ forces separation, with no chain condition.
- **§4** proves the **Krull-type theorem** (Theorem 4.3): in a domain well founded for divisibility, separation holds exactly for non-units (Theorem 4.5), specialising to Noetherian domains and UFDs.
- **§5** proves the **equivalence of the two criteria** (Theorem 5.3) and the **minimality of the $a$-adic order** among heights (Theorem 6.6).
- **§6** exhibits the intersection as a **greatest fixed point** (Theorem 6.3), giving a second, Nakayama-based proof of the Noetherian case (Theorem 6.5).
- **§7** constructs the **non-archimedean absolute value** for prime $a$ (Theorem 7.5) and proves the topological and completion-theoretic characterisations (Theorems 7.7, 7.8).
- **§8** computes the intersection exactly in $S = \mathbb{Z} + X\mathbb{Q}[X]$ (Theorem 8.4), yielding sharpness of every hypothesis.
- **§9** shows the chain condition strictly generalises Noetherianity via $\mathbb{Q}[X_0, X_1, \dots]$.
- **§10** gives algorithms, **§11** applications, **§12** discussion and open problems.

---

## 2. The principal filtration and separation

**Definition 2.1 (Principal filtration).** Let $R$ be a commutative ring and $a \in R$. The *principal $a$-adic filtration* is the family of ideals
$$\mathrm{filt}_a(n) = (a^n) = \{a^n y : y \in R\}, \qquad n \in \mathbb{N}.$$

Two immediate remarks. First, $\mathrm{filt}_a(0) = (1) = R$. Second, $\mathrm{filt}_a(n) = (a)^n$: the $n$-th power of the principal ideal $(a)$ is the principal ideal generated by $a^n$. So the filtration is exactly the power filtration of the ideal $(a)$, and everything below can be read as a statement about the $(a)$-adic filtration.

**Lemma 2.2 (Antitonicity).** If $m \le n$ then $\mathrm{filt}_a(n) \subseteq \mathrm{filt}_a(m)$.

*Proof.* $x \in \mathrm{filt}_a(n)$ means $a^n \mid x$, and $a^m \mid a^n$ when $m \le n$. $\square$

**Definition 2.3 (Separation).** The principal filtration at $a$ is *separated* if
$$\bigcap_{n \in \mathbb{N}} (a^n) = 0.$$
We write $\mathrm{Sep}(a)$ for this property.

**Lemma 2.4 (Membership in the intersection).** $x \in \bigcap_n (a^n)$ if and only if $a^n \mid x$ for every $n$. Consequently
$$\mathrm{Sep}(a) \iff \bigl(\forall x \in R:\ (\forall n,\ a^n \mid x) \Rightarrow x = 0\bigr).$$

*Proof.* Membership in an intersection of ideals is membership in each, and membership in the principal ideal $(a^n)$ is divisibility by $a^n$. $\square$

This unwound form — *only zero is divisible by all powers of $a$* — is the working definition for the rest of the paper.

### 2.1 Degenerate elements

**Proposition 2.5 (Zero is separated).** $\mathrm{Sep}(0)$ holds in every commutative ring.

*Proof.* If $0^n \mid x$ for all $n$, take $n = 1$: then $0 \mid x$, i.e. $x = 0$. $\square$

**Proposition 2.6 (Units are never separated).** If $a$ is a unit then $\bigcap_n (a^n) = R$; hence in a nontrivial ring $\mathrm{Sep}(a)$ fails.

*Proof.* $a^n$ is a unit, so $a^n \mid x$ for every $x$, giving $\bigcap_n(a^n) = R$. If this were $0$ then $1 = 0$. $\square$

So for a nontrivial ring the candidates are the nonzero non-units, and the question is which of those are separated.

---

## 3. Criterion I: heights, with no chain condition

**Definition 3.1 (Height function).** Let $a \in R$. A function $v : R \to \mathbb{N}$ is a *height function for $a$* if
$$v(x) < v(ax) \qquad \text{for every } x \in R \setminus \{0\}.$$

No further structure is demanded: $v$ need not be additive, monotone under divisibility, or canonical. It must merely strictly increase along multiplication by $a$, off zero.

**Lemma 3.2 (Linear growth along the filtration).** Let $R$ be a domain, $a \ne 0$, and $v$ a height function for $a$. Then for all $n \in \mathbb{N}$ and all $x \ne 0$,
$$n + v(x) \le v(a^n x).$$

*Proof.* Induction on $n$. For $n = 0$ the claim is $v(x) \le v(x)$. Assume $n + v(x) \le v(a^n x)$. Since $R$ is a domain and $a \ne 0 \ne x$, we have $a^n x \ne 0$, so the height property applies to it:
$$v(a^n x) < v\bigl(a\,(a^n x)\bigr) = v(a^{n+1} x).$$
Combining, $(n+1) + v(x) \le v(a^n x) + 1 \le v(a^{n+1}x)$. $\square$

**Theorem 3.3 (Height Criterion).** Let $R$ be a domain and $a \in R$. If there exists a height function for $a$, then the principal filtration at $a$ is separated.

*Proof.* If $a = 0$, apply Proposition 2.5. Assume $a \ne 0$ and let $v$ be a height function. Let $x$ be divisible by every power of $a$ and suppose $x \ne 0$. Put $n = v(x) + 1$ and write $x = a^n y$. If $y = 0$ then $x = 0$, a contradiction; so $y \ne 0$ and Lemma 3.2 gives
$$v(x) = v(a^n y) \ge n + v(y) = v(x) + 1 + v(y) \ge v(x) + 1,$$
which is impossible. Hence $x = 0$. $\square$

The proof is finite in the strongest sense: it consumes exactly one instance of divisibility, at the index $v(x) + 1$ computed from $x$ itself.

### 3.1 Classical instances, immediately

**Corollary 3.4 (Integers).** For $a \in \mathbb{Z}$ with $|a| \ge 2$, $\bigcap_n (a^n) = 0$. In particular $\bigcap_n(2^n) = 0$.

*Proof.* Take $v(x) = |x|$. For $x \ne 0$, $|ax| = |a|\,|x| \ge 2|x| > |x|$. $\square$

**Corollary 3.5 (Polynomials).** For $k$ a domain, $\bigcap_n (X^n) = 0$ in $k[X]$.

*Proof.* Take $v(p) = \deg p$ (with $\deg 0 = 0$). For $p \ne 0$, $\deg(Xp) = \deg p + 1$. $\square$

These two corollaries are, respectively, the archetypes of arithmetic and geometric local analysis. It is worth stressing that neither proof used unique factorization, Noetherianity, or any finiteness of $R$.

---

## 4. Criterion II: chain conditions and the Krull intersection theorem

**Definition 4.1 (Finite multiplicity).** For $a, x \in R$, say $x$ has *finite $a$-multiplicity* if there is some $n$ with $a^n \nmid x$; in that case the *$a$-adic order* $\mathrm{ord}_a(x)$ is the greatest $n$ with $a^n \mid x$.

**Proposition 4.2 (Separation $=$ finite multiplicity).** $\mathrm{Sep}(a)$ holds if and only if every nonzero $x \in R$ has finite $a$-multiplicity.

*Proof.* ($\Rightarrow$) If some $x \ne 0$ had infinite multiplicity then $a^n \mid x$ for all $n$, so $x = 0$ by Lemma 2.4 — contradiction. ($\Leftarrow$) If $a^n \mid x$ for all $n$ and $x \ne 0$, then $x$ has infinite multiplicity, contradicting the hypothesis; so $x = 0$. $\square$

**Definition 4.3 (Well-founded divisibility).** A monoid or domain $R$ is *well founded for divisibility* if there is no infinite sequence $(x_i)_{i \in \mathbb{N}}$ of nonzero elements in which each $x_{i+1}$ properly divides $x_i$ — "properly" meaning $x_{i+1} \mid x_i$ but $x_i \nmid x_{i+1}$. Equivalently, the strict divisibility relation is well founded.

Every Noetherian domain is well founded for divisibility (a strictly increasing chain of principal ideals would contradict the ascending chain condition), and so is every unique factorization domain (the number of irreducible factors strictly decreases). The two classes are incomparable: UFDs need not be Noetherian (see §9).

**Theorem 4.4 (Krull separation, principal case).** Let $R$ be a domain, well founded for divisibility, and let $a \in R$ be a non-unit. Then the principal filtration at $a$ is separated.

*Proof.* By Proposition 4.2 it suffices to show every nonzero $x$ has finite $a$-multiplicity. Suppose not: $a^n \mid x$ for all $n$, with $x \ne 0$. Write $x = a^n y_n$. Because $a$ is a non-unit and $R$ is a domain, $y_{n+1}$ properly divides $y_n$ for every $n$ (indeed $y_n = a y_{n+1}$, and if conversely $y_{n+1} \mid y_n$ then $a$ would be a unit by cancellation). This is an infinite properly descending divisibility chain, contradicting well-foundedness. $\square$

**Theorem 4.5 (Characterisation in the well-founded case).** Let $R$ be a nontrivial domain, well founded for divisibility. Then for every $a \in R$:
$$\mathrm{Sep}(a) \iff a \text{ is not a unit}.$$

*Proof.* ($\Rightarrow$) Proposition 2.6. ($\Leftarrow$) Theorem 4.4. $\square$

**Corollary 4.6 (Noetherian case).** In a Noetherian domain, $\bigcap_n(a^n) = 0$ for every non-unit $a$. In the usual formulation: $\bigcap_n I^n = 0$ for every proper principal ideal $I$.

**Corollary 4.7 (UFD case).** In a unique factorization domain, $\bigcap_n (a^n) = 0$ for every non-unit $a$. Since UFDs need not be Noetherian, this is not contained in Corollary 4.6.

---

## 5. The two criteria coincide

The height criterion of §3 is soft and the chain condition of §4 is hard, yet over a domain they cut out the same class of elements. The key computation is that the $a$-adic order, when defined, increments by exactly one under multiplication by $a$.

**Lemma 5.1 (The order increments by one).** Let $R$ be a domain, $a \ne 0$, and suppose $x$ and $ax$ both have finite $a$-multiplicity. Then
$$\mathrm{ord}_a(ax) = \mathrm{ord}_a(x) + 1.$$

*Proof.* Put $m = \mathrm{ord}_a(x)$ and write $x = a^m c$. Then $ax = a^{m+1} c$, so $a^{m+1} \mid ax$ and $\mathrm{ord}_a(ax) \ge m+1$. Conversely suppose $a^{m+2} \mid ax$, say $ax = a^{m+2}c'$. Cancelling the nonzero $a$ (valid in a domain) gives $x = a^{m+1}c'$, so $a^{m+1} \mid x$ and $m + 1 \le \mathrm{ord}_a(x) = m$ — absurd. Hence $\mathrm{ord}_a(ax) = m+1$. $\square$

**Corollary 5.2 (The order is a height function).** If $\mathrm{Sep}(a)$ holds in a domain with $a \ne 0$, then $v = \mathrm{ord}_a$ satisfies $v(x) < v(ax)$ for all $x \ne 0$.

*Proof.* By Proposition 4.2 both $x$ and $ax$ (nonzero since $R$ is a domain) have finite multiplicity, so Lemma 5.1 applies. $\square$

**Theorem 5.3 (Separation is exactly the existence of a height).** Let $R$ be a domain and $a \in R$. Then
$$\mathrm{Sep}(a) \iff \exists\, v : R \to \mathbb{N} \text{ with } v(x) < v(ax) \text{ for all } x \ne 0.$$

*Proof.* ($\Leftarrow$) Theorem 3.3. ($\Rightarrow$) If $a \ne 0$, take $v = \mathrm{ord}_a$ and apply Corollary 5.2. If $a = 0$, take the indicator $v(x) = 1$ if $x = 0$ and $v(x) = 0$ otherwise: for $x \ne 0$ we have $v(x) = 0 < 1 = v(0\cdot x)$. $\square$

Theorem 5.3 is the conceptual centre of the paper. It says that a Krull-type intersection theorem for a *principal* filtration is never really about ascending chains; chains enter only as one way of exhibiting an $\mathbb{N}$-valued height. Any other mechanism — a degree, an absolute value, a length, an ad-hoc combinatorial count — does the job just as well, and the conclusion is equally strong.

---

## 6. The intersection as a greatest fixed point

We now describe $J = \bigcap_n(a^n)$ rather than merely asking when it vanishes.

**Definition 6.1 ($a$-divisible ideal).** An ideal $I \subseteq R$ is *$a$-divisible* if $I \subseteq (a)\cdot I$, i.e. every element of $I$ is $a$ times an element of $I$.

**Lemma 6.2 (Both inclusions).**
1. (Any commutative ring.) If $I$ is $a$-divisible then $I \subseteq \bigcap_n (a^n)$.
2. (Domains.) $J = \bigcap_n(a^n)$ is $a$-divisible.

*Proof.* (1) By induction, $I \subseteq (a^n)$ for all $n$: trivially for $n = 0$; and if $I \subseteq (a^n)$ then $I \subseteq (a)I \subseteq (a)(a^n) = (a^{n+1})$.
(2) If $a = 0$ then $J = 0$ and the claim is trivial. Let $a \ne 0$ and $x \in J$; write $x = a y$. We claim $y \in J$: for each $n$, write $x = a^{n+1}c$; then $ay = a\,(a^n c)$, and cancelling $a$ gives $y = a^n c$, so $a^n \mid y$. Hence $x = ay \in (a)J$. $\square$

**Theorem 6.3 (Greatest fixed point).** Let $R$ be a domain and $a \in R$. Then $J = \bigcap_n(a^n)$ satisfies $J = (a)\cdot J$ and is the *greatest* element of the set of $a$-divisible ideals, ordered by inclusion. Consequently the map $I \mapsto (a)\cdot I$ on the ideal lattice of $R$ is monotone with greatest post-fixed point $J$.

*Proof.* Lemma 6.2(2) gives $J \subseteq (a)J$; the reverse holds since $(a)J \subseteq J$ always. Lemma 6.2(1) gives maximality. $\square$

**Corollary 6.4 (Separation via fixed points).** Over a domain, $\mathrm{Sep}(a)$ holds if and only if the only ideal $I$ with $I \subseteq (a)\,I$ is $I = 0$.

*Proof.* If $\mathrm{Sep}(a)$ and $I \subseteq (a)I$ then $I \subseteq J = 0$. Conversely $J$ itself is $a$-divisible, so the hypothesis forces $J = 0$. $\square$

This makes the Noetherian case an instance of Nakayama's lemma, giving a second proof entirely independent of multiplicity counting.

**Theorem 6.5 (Nakayama proof of the Noetherian case).** Let $R$ be a Noetherian domain and $a$ a non-unit. Then $\mathrm{Sep}(a)$.

*Proof.* Let $J = \bigcap_n(a^n)$. Since $R$ is Noetherian, $J$ is finitely generated, and by Theorem 6.3, $J \subseteq (a)\cdot J$. The determinant-trick (Cayley–Hamilton) form of Nakayama's lemma yields $r \in R$ with $r - 1 \in (a)$ and $r\,x = 0$ for all $x \in J$. Write $r - 1 = a t$. If $r = 0$ then $a\,(-t) = 1$, contradicting that $a$ is a non-unit. Hence $r \ne 0$, and since $R$ is a domain, $rx = 0$ with $x \in J$ forces $x = 0$. Thus $J = 0$. $\square$

The fixed-point picture also explains the *shape* of failures: when separation fails, the obstruction is a canonical object, the greatest $a$-divisible ideal, and computing it (as we do in §8) is strictly more informative than merely noting nonvanishing.

**Theorem 6.6 (Minimality of the $a$-adic order).** Let $R$ be a domain, $a \ne 0$, suppose $\mathrm{Sep}(a)$, and let $v$ be any height function for $a$. Then
$$\mathrm{ord}_a(x) \le v(x) \qquad \text{for every } x \ne 0.$$

*Proof.* Put $m = \mathrm{ord}_a(x)$ and write $x = a^m c$ with $c \ne 0$ (else $x = 0$). Lemma 3.2 gives $m + v(c) \le v(a^m c) = v(x)$, hence $m \le v(x)$. $\square$

Thus $\mathrm{ord}_a$ is the universal (smallest) witness to separation: heights form a set with a least element, and that least element is the canonical adic order. Theorems 5.3 and 6.6 together say the passage "separation $\leftrightarrow$ height" is not merely an equivalence of truth values but an equivalence with a canonical representative on one side.

---

## 7. Valuation, absolute value, topology, completion

Separation is precisely the hypothesis under which the $a$-adic order becomes a usable valuation.

Throughout this section $R$ is a domain, $a \in R$, and $\mathrm{Sep}(a)$ holds, so $\mathrm{ord}_a(x) \in \mathbb{N}$ is defined for every $x \ne 0$.

**Lemma 7.1 (Divisibility test).** For $x \ne 0$ and $k \in \mathbb{N}$: $\;k \le \mathrm{ord}_a(x) \iff a^k \mid x$.

*Proof.* Immediate from the definition of the order as the largest exponent dividing, which exists by Proposition 4.2. $\square$

**Theorem 7.2 (Additivity for prime $a$).** If $a$ is prime and $x, y \ne 0$, then
$$\mathrm{ord}_a(xy) = \mathrm{ord}_a(x) + \mathrm{ord}_a(y).$$

*Proof.* The inequality $\ge$ is clear by multiplying factorisations. For $\le$, write $m = \mathrm{ord}_a x$, $n = \mathrm{ord}_a y$, $x = a^m u$, $y = a^n w$ with $a \nmid u$, $a \nmid w$. Then $xy = a^{m+n} uw$, and since $a$ is prime, $a \nmid uw$; so the order is exactly $m+n$. $\square$

**Theorem 7.3 (Ultrametric inequality for the order).** For $x, y, x+y$ all nonzero,
$$\min\{\mathrm{ord}_a(x), \mathrm{ord}_a(y)\} \le \mathrm{ord}_a(x+y).$$

*Proof.* Let $k$ be the minimum. By Lemma 7.1, $a^k \mid x$ and $a^k \mid y$, hence $a^k \mid x+y$, hence $k \le \mathrm{ord}_a(x+y)$. $\square$

**Definition 7.4 (Adic absolute value).** Set
$$\|x\|_a = \begin{cases} 2^{-\mathrm{ord}_a(x)} & x \ne 0,\\ 0 & x = 0.\end{cases}$$

**Theorem 7.5 (The $a$-adic absolute value).** Let $R$ be a domain and $a$ a prime element with $\mathrm{Sep}(a)$. Then $\|\cdot\|_a : R \to \mathbb{R}$ is an absolute value:
1. $\|x\|_a \ge 0$, with $\|x\|_a = 0$ iff $x = 0$;
2. $\|xy\|_a = \|x\|_a\,\|y\|_a$;
3. $\|x+y\|_a \le \max\{\|x\|_a, \|y\|_a\} \le \|x\|_a + \|y\|_a$.

Moreover $\|a\|_a = 1/2$.

*Proof.* (1) Positivity is clear for $x \ne 0$ since $2^{-k} > 0$; the vanishing criterion is exactly separation, which guarantees $\mathrm{ord}_a(x)$ is a finite natural number for $x \ne 0$. (2) is Theorem 7.2 exponentiated, with the zero cases trivial. (3) If any of $x, y, x+y$ vanishes the claim is immediate from nonnegativity; otherwise Theorem 7.3 gives $\mathrm{ord}_a(x+y) \ge \min$, and $t \mapsto 2^{-t}$ is decreasing, so $\|x+y\|_a \le \max$. The final bound $\max\{s,t\} \le s+t$ holds for nonnegative reals. Finally $\mathrm{ord}_a(a) = 1$, so $\|a\|_a = 1/2$. $\square$

Point (1) deserves emphasis: **the nondegeneracy of the adic absolute value is exactly separation**. If separation failed, some nonzero $x$ would be divisible by all powers of $a$, and any consistent assignment would give $\|x\|_a = 0$, destroying the metric.

**Example 7.6.** Taking $R = \mathbb{Z}$, $a = 2$ recovers the $2$-adic absolute value with $\|2\|_2 = 1/2$ and the ultrametric law $\|x+y\|_2 \le \max\{\|x\|_2, \|y\|_2\}$. Taking $R = k[X]$, $a = X$ over a field $k$ recovers the order of vanishing at the origin.

**Theorem 7.7 (Topological characterisation).** Give $R$ the $a$-adic topology, in which $\{(a^n)\}_{n}$ is a neighbourhood basis of $0$. Then the following are equivalent:
1. $\mathrm{Sep}(a)$;
2. the filtration is Hausdorff in the sense that the only element congruent to $0$ modulo every $(a^n)$ is $0$;
3. the $a$-adic topology on $R$ is a $T_2$ (Hausdorff) topology.

*Proof.* (1) $\iff$ (2) is a restatement of Lemma 2.4, since $x \equiv 0 \bmod (a^n)$ means $a^n \mid x$. (2) $\Rightarrow$ (3): in a topological group defined by a descending neighbourhood basis of subgroups, Hausdorffness is equivalent to the intersection of the basis being trivial; separation supplies exactly that. (3) $\Rightarrow$ (2) is the same equivalence read backwards. $\square$

**Theorem 7.8 (Completion characterisation).** $\mathrm{Sep}(a)$ holds if and only if the canonical map
$$R \longrightarrow \widehat{R}_{(a)} = \varprojlim_n R/(a^n)$$
into the $a$-adic completion is injective.

*Proof.* The kernel of the canonical map consists of those $x$ that vanish in $R/(a^n)$ for all $n$, i.e. $x \in \bigcap_n (a^n)$. Injectivity is therefore exactly the vanishing of this intersection. $\square$

Separation thus has an entirely categorical face: it is the assertion that the object $R$ is faithfully represented by its tower of finite-level approximations $R/(a^n)$. Without separation, approximation modulo powers of $a$ loses information irrecoverably, and precisely the greatest $a$-divisible ideal is lost.

**Corollary 7.9.** In a domain well founded for divisibility, every non-unit $a$ yields a Hausdorff $a$-adic topology and an injection $R \hookrightarrow \widehat{R}_{(a)}$.

---

## 8. The boundary: a domain where separation fails

We now show no hypothesis can be dropped, by computing the intersection exactly in a classical $D+M$ ring.

**Definition 8.1.** Let
$$S = \mathbb{Z} + X\,\mathbb{Q}[X] = \{p \in \mathbb{Q}[X] : p(0) \in \mathbb{Z}\},$$
the subring of rational polynomials whose constant coefficient is an integer. Being a subring of the domain $\mathbb{Q}[X]$, $S$ is a domain. Let $\varepsilon : S \to \mathbb{Q}$, $\varepsilon(p) = p(0)$, be the constant-coefficient homomorphism; its kernel is $X\mathbb{Q}[X]$.

**Lemma 8.2 ($2$ is a nonzero non-unit of $S$).** $2 \in S$, $2 \ne 0$, and $2$ is not a unit of $S$.

*Proof.* If $2b = 1$ in $S$, then in $\mathbb{Q}[X]$ we get $b = 1/2$, whose constant coefficient $1/2$ is not an integer; equivalently, comparing constant coefficients, $2m = 1$ for some $m \in \mathbb{Z}$, impossible. $\square$

**Lemma 8.3 ($X$ is infinitely $2$-divisible in $S$).** For every $n$, $2^n \mid X$ in $S$.

*Proof.* The polynomial $2^{-n} X$ has constant coefficient $0 \in \mathbb{Z}$, so $2^{-n}X \in S$, and $X = 2^n \cdot (2^{-n}X)$. $\square$

**Theorem 8.4 (Exact computation of the intersection).** In $S = \mathbb{Z} + X\mathbb{Q}[X]$,
$$\bigcap_{n} (2^n) = X\,\mathbb{Q}[X] = \ker \varepsilon = \{p \in S : p(0) = 0\}.$$
In particular the principal filtration at $2$ is not separated.

*Proof.* ($\supseteq$) If $p \in S$ has $p(0) = 0$, then $2^{-n}p \in \mathbb{Q}[X]$ has constant coefficient $0$, so lies in $S$, and $p = 2^n(2^{-n}p)$.
($\subseteq$) Let $p \in \bigcap_n (2^n)$ and let $m = p(0) \in \mathbb{Z}$. For each $n$ write $p = 2^n q_n$ with $q_n \in S$, and set $k_n = q_n(0) \in \mathbb{Z}$. Comparing constant coefficients gives $m = 2^n k_n$, so $2^n \mid m$ in $\mathbb{Z}$ for every $n$. By Corollary 3.4, $m = 0$, i.e. $p \in \ker\varepsilon$. $\square$

Note the pleasing structure of the argument: the *failure* of separation in $S$ is proved by *invoking* separation in $\mathbb{Z}$.

**Corollary 8.5 (Sharpness).** The following all follow from Theorem 8.4.
1. $\mathrm{Sep}$ can fail at a nonzero non-unit: the hypothesis "$a$ is a nonzero non-unit" alone is insufficient in a general domain.
2. $S$ is not well founded for divisibility (as $X, X/2, X/4, \dots$ is an infinite properly descending divisibility chain), so the hypothesis of Theorem 4.4 cannot be dropped.
3. $S$ is neither Noetherian nor a unique factorization domain.
4. **No height function for $2$ exists on $S$:** for every $v : S \to \mathbb{N}$ there is a nonzero $x \in S$ with $v(2x) \le v(x)$. (Immediate from Theorem 3.3, contrapositively.)
5. The greatest $2$-divisible ideal of $S$ is $X\mathbb{Q}[X]$, by Theorems 6.3 and 8.4.
6. The $2$-adic topology on $S$ is not Hausdorff, and $S \to \widehat{S}_{(2)}$ has kernel $X\mathbb{Q}[X]$ (Theorems 7.7, 7.8).

Item (4) is striking: a purely ideal-theoretic computation rules out the existence of *any* $\mathbb{N}$-valued measuring device whatsoever on $S$ compatible with multiplication by $2$. This is the practical force of Theorem 5.3 in its negative direction.

### 8.1 Why $S$ fails: an archimedean reading

Localising the intuition: $S$ carries two independent scales. The constant coefficient lives in $\mathbb{Z}$, where dividing by $2$ costs one unit; the higher coefficients live in $\mathbb{Q}$, where dividing by $2$ is free. The resulting "value monoid" at $2$ is lexicographically ordered of rank two — informally $\mathbb{Z} \times \mathbb{Z}$ with $(1,0)$ recording powers of $2$ and $(0,1)$ recording the $X$-direction — and a lexicographic order of rank $\ge 2$ is non-archimedean: no finite multiple of $(1,0)$ dominates $(0,1)$. Since $\mathbb{N}$ *is* archimedean, Theorem 5.3 says separation is exactly the condition that the relevant value monoid embeds order-compatibly in $\mathbb{N}$. The failure in $S$ is therefore not accidental but of a definite type: a rank-two obstruction.

---

## 9. Strictly beyond the Noetherian hypothesis

Theorem 4.4 is stated for domains well founded for divisibility, a class strictly larger than the Noetherian domains. We record a witness.

**Definition 9.1.** Let $A = \mathbb{Q}[X_0, X_1, X_2, \dots]$ be the polynomial ring in countably many variables, and let $\mathfrak{m} = (X_0, X_1, \dots)$ be the irrelevant ideal generated by all variables.

**Theorem 9.2 ($A$ is not Noetherian).** The ideal $\mathfrak{m}$ is not finitely generated; hence $A$ is not a Noetherian ring.

*Proof.* Suppose $\mathfrak{m} = (t_1, \dots, t_r)$. Let $V$ be the (finite) set of variables occurring in $t_1, \dots, t_r$ and choose $k$ with $X_k \notin V$. Consider the evaluation $g$ sending $X_k \mapsto 1$ and every other variable to $0$. Each $t_i$ involves only variables in $V$, all of which are sent to $0$, so $g(t_i)$ equals the constant coefficient of $t_i$, which is $0$ because $t_i \in \mathfrak{m}$. Hence $g$ annihilates the ideal generated by the $t_i$, i.e. all of $\mathfrak{m}$. But $X_k \in \mathfrak{m}$ and $g(X_k) = 1 \ne 0$ — contradiction. $\square$

**Theorem 9.3 (Separation nevertheless).** $A$ is a unique factorization domain, hence well founded for divisibility, hence every non-unit $a \in A$ has separated principal filtration. In particular $\bigcap_n (X_0^n) = 0$, and $\|\cdot\|_{X_0}$ is a non-archimedean absolute value on $A$ with $\|X_0\| = 1/2$.

*Proof.* $A$ is the directed union of the UFDs $\mathbb{Q}[X_0, \dots, X_N]$ and is itself a UFD; apply Theorem 4.4 and Theorem 7.5, noting $X_0$ is prime. $\square$

So the passage from "Noetherian" to "well founded for divisibility" is not cosmetic: it captures non-Noetherian rings with perfectly good adic analysis.

---

## 10. Algorithms

The theory is effective in the cases that matter computationally.

### 10.1 Computing the adic order

Given a ring with decidable divisibility by $a$ and a nonzero $x$, the order is computed by trial division:

```
ORD(a, x):
  assert x ≠ 0 and a is a non-unit, nonzero
  k ← 0
  while a divides x:
      x ← x / a
      k ← k + 1
  return k
```
Termination is exactly separation. In $\mathbb{Z}$ with $|a| \ge 2$ the loop runs $O(\log_{|a|}|x|)$ times; in $k[X]$ at $a = X$ it runs at most $\deg x$ times, and in both cases each step is a single exact division. *If separation fails, the loop does not terminate* — a vivid operational reading of the theorem.

### 10.2 Certifying separation by exhibiting a height

To certify $\mathrm{Sep}(a)$ for a concrete ring, it suffices to exhibit a height function and verify the single inequality $v(x) < v(ax)$ on nonzero $x$ — for $\mathbb{Z}$, the absolute value; for $k[X]$, the degree; for a graded ring at a homogeneous element, the degree of the lowest nonzero component. By Theorem 5.3 this is a complete method: if $\mathrm{Sep}(a)$ holds, *some* such $v$ exists, and by Theorem 6.6 the adic order is the tightest one.

### 10.3 Detecting failure

To *refute* separation one exhibits a nonzero element divisible by all powers of $a$, i.e. a nonzero $a$-divisible ideal (Corollary 6.4). In the $D+M$ construction one exhibits $X$ and the family $\{2^{-n}X\}$. A general search strategy: look for an ideal $I$ with $I = aI$; by Theorem 6.3 the intersection is the largest such, so any nonzero example suffices.

### 10.4 Adic approximation

Separation guarantees that the residues $x \bmod (a^n)$ determine $x$. Algorithmically: distinct ring elements are separated at a finite level $n \le \max\{\mathrm{ord}_a(x-y)\} + 1$, so equality testing can be performed by increasing-precision comparison, terminating in $\mathrm{ord}_a(x-y)+1$ steps for $x \ne y$. Without separation no such termination guarantee exists.

---

## 11. Applications

**11.1 $p$-adic numbers and local fields.** Theorem 7.5 applied to $(\mathbb{Z}, p)$ gives the $p$-adic absolute value; Theorem 7.8 says $\mathbb{Z} \hookrightarrow \mathbb{Z}_p$ is injective. The completion, and thence $\mathbb{Q}_p$, is meaningful precisely because separation holds.

**11.2 Formal power series and local algebraic geometry.** Applied to $(k[X], X)$, Theorem 7.8 gives the injection $k[X] \hookrightarrow k[[X]]$, the analytic-local approximation of a curve at a point. The order of vanishing is the height, and Theorem 6.6 says it is the sharpest possible notion of "how strongly a function vanishes".

**11.3 Krull's intersection theorem.** Corollary 4.6 is the principal-ideal case of the Krull intersection theorem, and Theorem 6.5 reproves it by Nakayama — the standard textbook route — while Theorem 4.4 extends it beyond Noetherian rings.

**11.4 Non-Noetherian adic analysis.** Theorem 9.3 provides a non-Noetherian ring carrying a genuine non-archimedean absolute value. Any situation where a UFD arises as an infinite union of Noetherian pieces (rings of polynomials in infinitely many variables, monoid algebras with non-finitely-generated monoids) inherits adic analysis from Theorem 4.4.

**11.5 A diagnostic for pathological rings.** Corollary 8.5 turns a single divisibility computation into simultaneous proofs that a ring is non-Noetherian, non-factorial, non-well-founded, and carries no compatible $\mathbb{N}$-valued height. Exhibiting one infinitely divisible element is a cheap and powerful test.

**11.6 Termination of division algorithms.** §10.1 shows separation is the exact correctness condition for the "divide out all factors of $a$" loop that occurs in factorisation, content extraction, and normalisation routines.

---

## 12. Discussion, and open directions

### 12.1 What the theory says

Three slogans summarise the development.

1. **Separation is a height statement, not a chain statement.** Theorem 5.3 shows the $\mathbb{N}$-valued height criterion is equivalent to separation over any domain, whereas chain conditions are merely sufficient. In the principal case, Krull's theorem is best read as: *chain conditions manufacture heights*.
2. **Separation is triviality of a greatest fixed point.** Theorem 6.3 makes $\bigcap_n(a^n)$ into a canonical object — the greatest $a$-divisible ideal — so failure has structure, not just a truth value.
3. **Separation is an archimedean axiom.** §8.1: the failure in $\mathbb{Z} + X\mathbb{Q}[X]$ is a rank-two value monoid failing to embed in the archimedean $\mathbb{N}$.

### 12.2 The height spectrum of a domain

For a domain $R$ define
$$\mathrm{Sep}(R) = \{a \in R : \bigcap_n (a^n) = 0\}.$$
The results above give this set a rich closure calculus: it contains $0$; it misses every unit (in a nontrivial ring); it is upward closed under divisibility (if $a \mid b$ and $a \in \mathrm{Sep}(R)$ then $b \in \mathrm{Sep}(R)$, since divisibility by all powers of $b$ implies divisibility by all powers of $a$); hence it is closed under multiplication by arbitrary elements and under positive powers; it is invariant under multiplication by units; and it pulls back along injective ring homomorphisms, in the sense that if $f : R \to R'$ is injective and $f(a) \in \mathrm{Sep}(R')$ then $a \in \mathrm{Sep}(R)$ — in particular separation for an element of a subring can be read off from the ambient ring. In a domain well founded for divisibility, Theorem 4.5 says $\mathrm{Sep}(R)$ is exactly the complement of the unit group.

**Open problem 1 (Height spectrum).** Characterise the domains for which $\mathrm{Sep}(R)$ equals the complement of the units. Conjecturally this holds iff $R$ has no nonzero ideal $I$ with $I = aI$ for some non-unit $a$, and further iff every localisation of $R$ at a height-one prime has archimedean value group.

### 12.3 A rank-two obstruction

**Open problem 2 (Rank-two obstruction).** Prove that for a domain $R$ and a nonzero non-unit $a$, the failure $\bigcap_n(a^n) \ne 0$ forces the presence of a rank-$\ge 2$ (lexicographic) valuation-theoretic structure adapted to $a$ — making the $D+M$ example the universal obstruction rather than merely one example.

### 12.4 Further directions

- **Non-principal filtrations.** The full Krull intersection theorem concerns $\bigcap_n I^n$ for arbitrary ideals $I$. Does a height-style criterion exist there? A natural candidate is a function $v : R \to \mathbb{N}$ with $v(x) < v(y)$ whenever $y \in Ix$, but the absence of a single multiplier complicates the induction of Lemma 3.2.
- **Ordinal-valued heights.** Replacing $\mathbb{N}$ by a well-ordered set changes the theory: transfinite heights should correspond to separation of the transfinitely-iterated filtration. The archimedean reading of §8.1 suggests $\mathbb{Z}^n$ (lexicographic) heights track exactly the rank of the obstruction.
- **Quantitative separation.** For $x \ne 0$ how large can $\mathrm{ord}_a(x)$ be relative to natural size measures? In $\mathbb{Z}$, $\mathrm{ord}_a(x) \le \log_{|a|}|x|$; general bounds of this form would make §10.1 a complexity statement rather than a termination statement.
- **Module-theoretic version.** Replace $R$ by an $R$-module $M$ and ask when $\bigcap_n a^n M = 0$. The fixed-point description (Theorem 6.3) generalises verbatim; the height criterion needs torsion-freeness in place of the domain hypothesis.
- **Effective non-existence of heights.** Corollary 8.5(4) is an existence statement obtained by contradiction. Can one, for a given $v$ on $\mathbb{Z} + X\mathbb{Q}[X]$, effectively produce a witness $x$ with $v(2x) \le v(x)$?

---

## 13. Conclusion

Starting from $\bigcap_n (2^n) = 0$ in $\mathbb{Z}$, we isolated the separation property of a principal filtration and gave five equivalent descriptions of it over a domain: finiteness of all $a$-multiplicities; existence of an $\mathbb{N}$-valued height increasing under multiplication by $a$; triviality of the greatest $a$-divisible ideal; Hausdorffness of the $a$-adic topology; and injectivity into the $a$-adic completion. Chain conditions — well-founded divisibility, and its special cases of Noetherianity and unique factorization — are sufficient rather than necessary, and their role is to manufacture a height; the $a$-adic order is then the canonical minimal such height, and for prime $a$ it exponentiates to a non-archimedean absolute value. The ring $\mathbb{Z} + X\mathbb{Q}[X]$ marks the precise boundary, with $\bigcap_n (2^n) = X\mathbb{Q}[X]$ computed exactly, while $\mathbb{Q}[X_0, X_1, \dots]$ shows that the chain-condition formulation reaches genuinely beyond the Noetherian world. The unifying moral is that repeated division terminates exactly when the ring's scale of measurement is archimedean.
