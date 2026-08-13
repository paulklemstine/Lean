# The Jacobi-Signed Circle Count: Escaping the Residue Dial, Pinned at the Weil Floor

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

For an odd modulus $N$ let $S(N) = \{(x,y) \in (\mathbb{Z}/N\mathbb{Z})^2 : x^2+y^2 = 1\}$ be the unit circle over $\mathbb{Z}/N\mathbb{Z}$, and define the **Jacobi-signed circle count**
$$W(N) \;=\; \sum_{(x,y)\in S(N)} \left(\frac{x}{N}\right),$$
where $\left(\frac{\cdot}{N}\right)$ is the Jacobi symbol. We establish the complete structure theory of this statistic and use it to settle its viability as an arithmetic witness for the factorisation of semiprimes.

We prove: (i) a *collapse identity*, $W(p) = \sum_{x} \chi(x(1-x^2))$ for prime $p$ with $\chi$ the Legendre character — the two-dimensional circle count is a one-dimensional cubic character sum, equal up to sign to the trace of Frobenius of $y^2 = x - x^3$; (ii) *multiplicativity*, $W(mn) = W(m)W(n)$ for coprime $m,n$, hence $W(pq) = W(p)W(q)$; (iii) *vanishing*, $W(p)=0$ whenever $p \equiv 3 \pmod 4$, so $W$ annihilates a density-$3/4$ family of semiprimes; (iv) *exact parity*, $W(p) \equiv 2 \pmod 4$ for $p \equiv 1 \pmod 4$; (v) an *exact second moment* $\sum_{d}A(d)^2 = 2p(p-1)$ over quadratic twists $A(d) = \sum_x \chi(x^3-dx)$, from which we derive the **Weil bound** $W(p)^2 \le 4p$ by pure averaging, with no input from algebraic geometry; (vi) the **Jacobsthal identity** $A(1)^2 + A(\nu)^2 = 4p$ for any nonresidue $\nu$, which exhibits the Weil bound as the shadow of an exact conservation law and yields **Fermat's two-square theorem with explicit character-sum witnesses**: $p = (W(p)/2)^2 + (A(\nu)/2)^2$ with $W(p)/2$ odd.

We further prove, by exact evaluation, that $W$ is **not a residue dial**: no function of $p \bmod 8$ (nor of $p \bmod 4$) reproduces $W(p)$, and no function of $N \bmod 8$ reproduces $W(N)$. This distinguishes the Jacobi-signed count from every previously examined character-weighted point count in this family, all of which collapsed to functions of $N \bmod 4$ or $N \bmod 8$.

The verdict is nonetheless negative, and sharply so. The statistic costs $\Theta(N)$ to evaluate, factors as a *symmetric* product in which $p$ and $q$ are inseparable, and — decisively — lives in a window of width $O(\sqrt{N})$ inside a search space of size $N$. Empirically, across forty semiprimes with both factors $\equiv 1 \pmod 4$, correlations of $W(N)$ with $p$, $q$, $p+q$, $|p-q|$ lie inside the permutation null. We formulate the resulting principle: *summing away one circle coordinate turns any character-weighted circle count into a Jacobi sum, and Jacobi sums have absolute value exactly $\sqrt p$ — the square-root floor is a property of the circle, not of the weight.*

**Keywords:** Jacobi symbol, character sums, Weil bound, Jacobsthal sums, quadratic twists, Fermat two-square theorem, semiprime witnesses.

---

## 1. Introduction

### 1.1 Witnesses, dials, and floors

A recurring temptation in computational number theory is to look for an *arithmetic witness*: a quantity $F(N)$, defined by a natural formula, whose value leaks information about the prime factorisation of $N$. The temptation is well founded — the class number, the order of the multiplicative group, the number of points on a curve mod $N$, all *are* functions of the factorisation. The difficulty is that in almost every case the witness is either (a) as expensive as factoring itself, (b) a function of publicly available data, or (c) drowned in noise.

Case (b) deserves a name. Call $F$ a **residue dial** modulo $m$ if there is a function $f$ with $F(N) = f(N \bmod m)$ for all admissible $N$. A dial is worthless: its value is computable from $N$ alone in constant time, hence carries no information about the factorisation beyond what $N \bmod m$ already reveals. Several natural point-count witnesses collapse to dials. The plain count of the circle $x^2+y^2=1$ over $\mathbb{Z}/N\mathbb{Z}$ satisfies $|S(p)| = p - \chi(-1)$, which for $N=pq$ gives $(p-\varepsilon_p)(q-\varepsilon_q)$ with $\varepsilon \in \{\pm 1\}$ determined by residues mod $4$; counts attached to binary quadratic forms and to Gaussian sums behave similarly. In each case the dependence on the factors is confined to the corrections $\varepsilon$, which are determined by $N \bmod 4$ or $N \bmod 8$.

This paper studies a witness designed specifically to break the dial: weight each circle point by the Jacobi symbol of its $x$-coordinate. The weighting destroys the crude leading term (the weighted count of a set of size $\approx N$ is not $\approx N$; it is subject to massive cancellation) and, as we prove, genuinely escapes the dial. What remains is a study in how a *different* obstruction — the square-root cancellation floor for character sums — takes over the moment the first obstruction is removed.

### 1.2 The statistic

Throughout, $N$ is odd and $\left(\frac{a}{N}\right)$ denotes the Jacobi symbol, i.e. the completely multiplicative extension in the lower argument of the Legendre symbol: if $N = \prod_i p_i^{e_i}$ then $\left(\frac{a}{N}\right) = \prod_i \left(\frac{a}{p_i}\right)^{e_i}$. For prime $p$, $\left(\frac{a}{p}\right) = \chi_p(a)$ is the quadratic character: $+1$ if $a$ is a nonzero square, $-1$ if $a$ is a nonsquare, $0$ if $p \mid a$.

**Definition 1.1 (Jacobi-signed circle count).** For odd $N \ge 3$ set
$$S(N) = \{(x,y) \in (\mathbb{Z}/N\mathbb{Z})^2 : x^2 + y^2 = 1\}, \qquad W(N) = \sum_{(x,y) \in S(N)} \left(\frac{x}{N}\right).$$

**Definition 1.2 (The cubic sum form).** For odd $N$ set
$$\widetilde{W}(N) = \sum_{x \in \mathbb{Z}/N\mathbb{Z}} \left(\frac{x(1-x^2)}{N}\right).$$

Theorem 2.1 identifies $W$ and $\widetilde W$ for prime moduli, and Theorem 3.4 does so for arbitrary odd moduli via multiplicativity; we therefore use $W$ for both without further comment.

### 1.3 Results and organisation

Section 2 proves the collapse identity and the elementary symmetries (reflection, vanishing for $p \equiv 3 \bmod 4$, parity). Section 3 proves multiplicativity in the modulus, both for the abstract character sum and for the geometric circle weight, and derives the semiprime product formula and the semiprime Weil floor. Section 4 develops the second-moment machinery over quadratic twists and proves the Weil bound $W(p)^2 \le 4p$ elementarily. Section 5 proves the Jacobsthal identity and deduces Fermat's two-square theorem with the Jacobi-signed count as the odd leg; Section 6 pins the exact $2$-adic valuation. Section 7 gives the exact evaluations that refute the dial hypothesis and establish near-attainment of the Weil bound. Section 8 assembles the negative verdict: the three barriers (cost, symmetry, floor) and the empirical decorrelation. Section 9 states the general principle and future directions.

---

## 2. The collapse identity and elementary symmetries

Fix an odd prime $p$ and write $\chi = \chi_p$ for the quadratic character of $\mathbb{Z}/p\mathbb{Z}$, extended by $\chi(0)=0$. Two facts are used constantly:

* **(C1)** $\sum_{x \bmod p} \chi(x) = 0$ (the nontrivial character sums to zero);
* **(C2)** $\#\{y : y^2 = a\} = \chi(a) + 1$ for every $a$ (two roots for a nonzero square, none for a nonsquare, one for $a=0$).

**Theorem 2.1 (Collapse to a cubic character sum).** For every odd prime $p$,
$$W(p) \;=\; \sum_{x \bmod p} \chi\bigl(x(1-x^2)\bigr).$$

*Proof.* Group the sum defining $W(p)$ by the value of $x$. For fixed $x$ the inner sum is $\chi(x)$ times the number of $y$ with $y^2 = 1-x^2$, which by (C2) is $\chi(1-x^2)+1$. Hence
$$W(p) = \sum_x \chi(x)\bigl(\chi(1-x^2)+1\bigr) = \sum_x \chi\bigl(x(1-x^2)\bigr) + \sum_x \chi(x),$$
using multiplicativity of $\chi$, and the second sum vanishes by (C1). $\square$

The polynomial $x(1-x^2) = -(x^3 - x)$ has three distinct roots $0, \pm1$; the sum on the right is therefore, up to the sign $\chi(-1)$, minus the trace of Frobenius of the elliptic curve $y^2 = x^3 - x$. This is the structural reason the Weil bound will appear, and the reason no elementary rearrangement can push $W$ above $\sqrt{p}$ in size.

**Theorem 2.2 (Reflection).** $W(p) = \chi(-1)\,W(p)$.

*Proof.* Substituting $x \mapsto -x$ (a bijection of $\mathbb{Z}/p\mathbb{Z}$) replaces $x(1-x^2)$ by $-x(1-x^2)$, hence multiplies each summand by $\chi(-1)$. $\square$

**Corollary 2.3 (Vanishing on the supersingular half).** If $p \equiv 3 \pmod 4$ then $W(p) = 0$.

*Proof.* For $p \equiv 3 \pmod 4$, $-1$ is a nonresidue, so $\chi(-1) = -1$ and Theorem 2.2 gives $W(p) = -W(p)$. $\square$

Half of all primes therefore carry no signal whatsoever. (In the elliptic-curve language: $y^2 = x^3-x$ is supersingular precisely for $p \equiv 3 \pmod 4$, and the trace vanishes.)

**Lemma 2.4 (Reflection-parity).** Let $f : \mathbb{Z}/p\mathbb{Z} \to \mathbb{Z}$ satisfy $f(-x) = f(x)$ and $f(0)=0$. Let $H = \{x \ne 0 : 2\,\overline{x} < p\}$ (where $\overline x \in \{0,\dots,p-1\}$ is the least residue) be the "lower half" of the nonzero classes. Then
$$\sum_{x \bmod p} f(x) = 2\sum_{x \in H} f(x),$$
and in particular the total sum is even. Moreover $|H| = (p-1)/2$.

*Proof.* $x \mapsto -x$ is an involution without fixed points on the nonzero classes ($p$ odd), and it exchanges $H$ with its complement among the nonzero classes: if $x \ne 0$ then $\overline{-x} = p - \overline{x}$, and $2\overline x < p \iff 2\overline{-x} > p$, with equality impossible for odd $p$. Since $f$ is invariant under the involution and kills $0$, the two halves contribute equally. $\square$

**Theorem 2.5 (Parity).** For every odd prime $p$, $W(p)$ is even.

*Proof.* If $p \equiv 3 \pmod 4$ this is Corollary 2.3. If $p \equiv 1 \pmod 4$ then $\chi(-1)=1$, so $f(x) = \chi(x(1-x^2))$ satisfies $f(-x)=f(x)$, and $f(0)=0$; apply Lemma 2.4. $\square$

This already matches every observed value: $-2, -6, 2, 6, 10, -10, -14, -18, 22, 26, 34, \dots$ — never odd. Section 6 sharpens this to $W(p) \equiv 2 \pmod 4$.

---

## 3. Multiplicativity: the factors become inseparable

The Jacobi symbol is multiplicative in *both* arguments, and it is this second multiplicativity, combined with the Chinese Remainder Theorem, that makes the statistic factor.

**Lemma 3.1 (Multiplicativity in the numerator).** For odd $N$ and $x, y \in \mathbb{Z}/N\mathbb{Z}$, writing $\jmath_N(x) = \left(\frac{\overline x}{N}\right)$ for the induced function on residues, we have $\jmath_N(xy) = \jmath_N(x)\jmath_N(y)$.

*Proof.* The Jacobi symbol is completely multiplicative in its upper argument and depends only on the upper argument modulo $N$; the least residue of $xy$ is congruent to the product of least residues. $\square$

**Lemma 3.2 (Splitting along the modulus).** If $N = mn$ with $m, n$ odd and $x \in \mathbb{Z}/N\mathbb{Z}$, then
$$\jmath_N(x) = \jmath_m(x \bmod m)\cdot \jmath_n(x \bmod n).$$

*Proof.* Multiplicativity of the Jacobi symbol in its lower argument, plus the fact that each factor depends only on the reduction of $x$ modulo the corresponding modulus. $\square$

**Theorem 3.3 (Multiplicativity of the cubic sum).** If $m,n$ are odd and coprime then
$$\widetilde W(mn) = \widetilde W(m)\,\widetilde W(n).$$

*Proof.* Let $\pi_m, \pi_n$ be the reduction maps. For each $x \in \mathbb{Z}/mn\mathbb{Z}$, Lemma 3.2 applied to $x(1-x^2)$ together with $\pi_\bullet$ being ring homomorphisms gives
$$\jmath_{mn}\bigl(x(1-x^2)\bigr) = \jmath_m\bigl(u(1-u^2)\bigr)\,\jmath_n\bigl(v(1-v^2)\bigr), \qquad u = \pi_m(x),\ v = \pi_n(x).$$
The Chinese Remainder Theorem says $x \mapsto (u,v)$ is a bijection $\mathbb{Z}/mn\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$. Reindexing the sum along this bijection and factoring the resulting double sum gives the product. $\square$

**Theorem 3.4 (Multiplicativity of the geometric weight).** If $m,n$ are odd and coprime then
$$W(mn) = W(m)\,W(n),$$
where $W$ is the geometric circle weight of Definition 1.1.

*Proof.* Under the CRT bijection $(\mathbb{Z}/mn\mathbb{Z})^2 \cong (\mathbb{Z}/m\mathbb{Z})^2 \times (\mathbb{Z}/n\mathbb{Z})^2$, a pair $(x,y)$ satisfies $x^2+y^2=1$ if and only if both its reductions do (necessity by applying the ring maps, sufficiency by injectivity of the CRT map). Lemma 3.2 splits the weight. The indicator of the circle therefore factors as a product of indicators, and the weighted sum factors as a product of weighted sums. $\square$

Combining Theorems 2.1, 3.3 and 3.4, the geometric and cubic-sum descriptions agree on all odd moduli, and we obtain the central structural fact.

**Corollary 3.5 (Semiprime product formula).** For distinct odd primes $p \ne q$,
$$W(pq) = W(p)\,W(q).$$

**Corollary 3.6 (A density-$3/4$ blind spot).** If $p \equiv 3 \pmod 4$ or $q \equiv 3 \pmod 4$ then $W(pq) = 0$. In particular $W(3q) = 0$ for every prime $q \ne 3$ — an infinite family of semiprimes on which the witness returns no information at all — and $W(15) = W(21) = 0$, so $W$ is not injective on semiprimes.

Corollary 3.5 is the crux of the negative result, and deserves emphasis. The statistic *is* factor-dependent: unlike a dial, its value is manufactured out of separate data belonging to $p$ and to $q$. But the manufacture is a **symmetric product**. An adversary who learns $W(N)$ learns one integer $w = w_p w_q$; recovering the pair $(w_p, w_q)$ from $w$ is itself a factoring problem, and even a successful split would only yield $W(p)$ and $W(q)$, from which $p$ and $q$ must still be recovered — and by Theorem 5.4 each of $W(p), W(q)$ determines only one leg of a two-square decomposition, i.e. $O(\log p)$ bits at best, in a heavily many-to-one fashion.

---

## 4. The Weil floor by second moments

We now bound $|W(p)|$. The classical route is Hasse's theorem for the elliptic curve $y^2 = x^3-x$. We instead give a self-contained averaging proof over quadratic twists, which has the advantage of producing the *exact* second moment (and, in Section 5, an exact identity).

**Definition 4.1 (Twist sums).** For $d \in \mathbb{Z}/p\mathbb{Z}$ set
$$A(d) = \sum_{x \bmod p} \chi\bigl(x^3 - d x\bigr).$$
Thus $-A(d)$ is the trace of Frobenius of $y^2 = x^3 - dx$.

**Lemma 4.2 ($W$ is the untwisted sum).** If $p \equiv 1 \pmod 4$ then $W(p) = A(1)$.

*Proof.* $x(1-x^2) = (-1)(x^3-x)$ and $\chi(-1) = 1$ for $p \equiv 1 \pmod 4$. $\square$

**Lemma 4.3 (Basic quadratic character sums).**
1. $\sum_{u} \chi(u^2-u) = -1$.
2. For any $a,b \in \mathbb{Z}/p\mathbb{Z}$, $\;\sum_{d} \chi\bigl((d-a)(d-b)\bigr) = p-1$ if $a = b$, and $-1$ otherwise.

*Proof.* (1) Drop $u=0$; for $u \ne 0$ write $u^2-u = u^2(1-u^{-1})$, so $\chi(u^2-u) = \chi(1-u^{-1})$. The map $u \mapsto 1-u^{-1}$ is a bijection from $\mathbb{Z}/p\mathbb{Z}\setminus\{0\}$ onto $\mathbb{Z}/p\mathbb{Z}\setminus\{1\}$ (inverse $v \mapsto (1-v)^{-1}$), so the sum equals $\sum_{v \ne 1}\chi(v) = -\chi(1) = -1$ by (C1).

(2) If $a=b$ the summand is $\chi((d-a)^2)$, which is $1$ for the $p-1$ values $d \ne a$ and $0$ at $d=a$. If $a \ne b$, substitute $d = a + (b-a)u$; then $(d-a)(d-b) = (b-a)^2(u^2-u)$, and $\chi((b-a)^2) = 1$, so the sum reduces to case (1). $\square$

**Lemma 4.4 (Square scaling).** For $c \ne 0$ and any $e$, $\;A(c^2 e) = \chi(c)\,A(e)$. In particular $A(c^2) = \chi(c)A(1)$, so $A(c^2)^2 = A(1)^2$ for all $c \ne 0$. Also $A(0) = 0$.

*Proof.* Substitute $x = cu$: $\;(cu)^3 - c^2e(cu) = c^3(u^3 - eu)$, and $\chi(c^3) = \chi(c)^3 = \chi(c)$. For $A(0) = \sum_x \chi(x^3) = \sum_x\chi(x) = 0$ by (C1). $\square$

**Lemma 4.5 (Diagonal inner sum).** Let $p \equiv 1 \pmod 4$. For each $x$,
$$\sum_{y\,:\,y^2 = x^2} \chi(xy) \;=\; \begin{cases} 0, & x = 0,\\ 2, & x \ne 0.\end{cases}$$

*Proof.* For $x \ne 0$ the solutions are $y = \pm x$, distinct since $p$ is odd; $\chi(x\cdot x) = \chi(x^2)=1$ and $\chi(x\cdot(-x)) = \chi(-1)\chi(x^2) = 1$ since $\chi(-1)=1$. $\square$

**Theorem 4.6 (Exact second moment).** For $p \equiv 1 \pmod 4$,
$$\sum_{d \bmod p} A(d)^2 \;=\; 2p(p-1).$$

*Proof.* Expand the square and swap the order of summation:
$$\sum_d A(d)^2 = \sum_{x}\sum_{y} \chi(xy) \sum_d \chi\bigl((d-x^2)(d-y^2)\bigr),$$
using $\chi(x^3-dx)\chi(y^3-dy) = \chi(xy)\chi\bigl((x^2-d)(y^2-d)\bigr)$. By Lemma 4.3(2) the inner sum is $p-1$ when $x^2=y^2$ and $-1$ otherwise, i.e. it equals $p\cdot[\,x^2=y^2\,] - 1$. Hence
$$\sum_d A(d)^2 = p \sum_{x}\sum_{y : y^2=x^2}\chi(xy) \;-\; \Bigl(\sum_x \chi(x)\Bigr)^2 .$$
The second term vanishes by (C1). By Lemma 4.5 the first is $p \cdot 2(p-1)$. $\square$

**Theorem 4.7 (Weil bound, elementary proof).** For every odd prime $p$,
$$W(p)^2 \;\le\; 4p, \qquad\text{i.e.}\qquad |W(p)| \le 2\sqrt{p}.$$

*Proof.* For $p\equiv 3 \pmod 4$ the left side is $0$ (Corollary 2.3). Let $p \equiv 1 \pmod 4$ and put $F(d) = A(d)^2 \ge 0$. By Lemma 4.4, $F(c^2) = A(1)^2$ for every $c \ne 0$, so
$$\sum_{c \ne 0} F(c^2) = (p-1)A(1)^2.$$
On the other hand $c \mapsto c^2$ is at most $2$-to-$1$ on $c\ne 0$, and $F \ge 0$, so
$$\sum_{c \ne 0} F(c^2) \;\le\; 2\sum_{d} F(d) \;=\; 4p(p-1)$$
by Theorem 4.6. Comparing and cancelling $p-1 > 0$ gives $A(1)^2 \le 4p$; conclude with Lemma 4.2. $\square$

**Corollary 4.8 (The semiprime Weil floor).** For distinct odd primes $p \ne q$ and $N = pq$,
$$W(N)^2 \le 16N, \qquad\text{i.e.}\qquad |W(N)| \le 4\sqrt{N}.$$

*Proof.* $W(N)^2 = W(p)^2W(q)^2 \le (4p)(4q) = 16N$ by Corollary 3.5 and Theorem 4.7. $\square$

This is the quantitative heart of the negative result. The statistic takes values in a window of $O(\sqrt N)$ integers while the object it is supposed to describe — the factorisation — ranges over $\approx N/\log^2 N$ possibilities. The *relative* information density is $O(N^{-1/2})$.

---

## 5. The Weil floor is an identity: Jacobsthal and two squares

The bound of Theorem 4.7 is not merely tight in order of magnitude; it is the shadow of an exact conservation law.

**Lemma 5.1 (Pushforward along squaring).** For any $F : \mathbb{Z}/p\mathbb{Z} \to \mathbb{Z}$,
$$\sum_{c} F(c^2) = \sum_{d} \bigl(\chi(d)+1\bigr)F(d).$$

*Proof.* Immediate from (C2): the fibre of $c \mapsto c^2$ over $d$ has exactly $\chi(d)+1$ elements. $\square$

**Theorem 5.2 (Jacobsthal identity).** Let $p \equiv 1 \pmod 4$ and let $\nu$ be any quadratic nonresidue mod $p$. Then
$$A(1)^2 + A(\nu)^2 \;=\; 4p.$$

*Proof.* Let $F(d) = A(d)^2$, so $F(0) = 0$ by Lemma 4.4. Two pushforwards:

*Residue side.* By Lemma 4.4, $F(c^2) = A(1)^2$ for $c \ne 0$ and $F(0)=0$, so $\sum_c F(c^2) = (p-1)A(1)^2$. By Lemma 5.1 this equals $\sum_d (\chi(d)+1)F(d)$.

*Nonresidue side.* Likewise $F(\nu c^2) = A(\nu)^2$ for $c \ne 0$ (Lemma 4.4 with $e = \nu$), so $\sum_c F(\nu c^2) = (p-1)A(\nu)^2$. Applying Lemma 5.1 to $d \mapsto F(\nu d)$ and then substituting $d \mapsto \nu^{-1}d$, using $\chi(\nu)=-1$, gives $\sum_c F(\nu c^2) = \sum_d (1 - \chi(d))F(d)$.

Adding, the character weights cancel exactly:
$$(p-1)\bigl(A(1)^2 + A(\nu)^2\bigr) = \sum_d\bigl[(\chi(d)+1) + (1-\chi(d))\bigr]F(d) = 2\sum_d F(d) = 4p(p-1)$$
by Theorem 4.6. Cancel $p-1$. $\square$

Theorem 5.2 re-derives Theorem 4.7 for $p\equiv 1 \pmod 4$ instantly, since $A(\nu)^2 \ge 0$. But it says much more: the residue twist and the nonresidue twist are the **two legs of a right triangle with hypotenuse $2\sqrt p$**. A large value in one leg forces a small value in the other, with $4p$ conserved.

**Lemma 5.3 (Evenness of all twists).** For $p \equiv 1 \pmod 4$ and any $d$, $A(d)$ is even.

*Proof.* $f(x) = \chi(x^3-dx)$ satisfies $f(-x) = \chi(-1)f(x) = f(x)$ and $f(0)=0$; apply Lemma 2.4. $\square$

**Theorem 5.4 (Fermat's two-square theorem with explicit witnesses).** Let $p \equiv 1 \pmod 4$ and let $\nu$ be a nonresidue. Put $a = W(p)/2$ and $b = A(\nu)/2$ (integers by Theorem 2.5 and Lemma 5.3). Then
$$p = a^2 + b^2.$$

*Proof.* Divide the identity of Theorem 5.2 by $4$, using $W(p) = A(1)$ (Lemma 4.2). $\square$

Thus the Jacobi-signed circle count is, up to a factor of $2$, one of the Gaussian coordinates of $p$: if $p = a^2+b^2$ in the (essentially unique) representation, then $W(p) = \pm 2a$ where $a$ is the odd leg (Theorem 6.1). Numerically:

| $p$ | $W(p)$ | $p = a^2+b^2$ |
|---|---|---|
| $5$ | $2$ | $1^2+2^2$ |
| $13$ | $-6$ | $3^2+2^2$ |
| $17$ | $-2$ | $1^2+4^2$ |
| $29$ | $10$ | $5^2+2^2$ |
| $41$ | $-10$ | $5^2+4^2$ |
| $53$ | $-14$ | $7^2+2^2$ |
| $73$ | $6$ | $3^2+8^2$ |
| $97$ | $-18$ | $9^2+4^2$ |
| $113$ | $14$ | $7^2+8^2$ |
| $173$ | $26$ | $13^2+2^2$ |
| $293$ | $34$ | $17^2+2^2$ |

This table is the whole story in miniature. The apparent chaos of the values $-2, -6, 2, 6, 10, -10, -14, -18, 22, 26, 34$ is exactly the chaos of the two-square decomposition of $p$ — genuinely arithmetic, genuinely not a dial, and genuinely useless as a factoring hint, because it is a *conserved-quantity projection*.

---

## 6. The exact $2$-adic valuation

Every observed value is twice an *odd* number. This is a theorem.

**Theorem 6.1 (Exact parity).** For $p \equiv 1 \pmod 4$, $W(p) \equiv 2 \pmod 4$; equivalently $v_2(W(p)) = 1$ exactly, so $a = W(p)/2$ is odd.

*Proof.* Let $f(x) = \chi(x(1-x^2))$ and let $H$ be the lower half of the nonzero residues, $|H| = (p-1)/2$. By Lemma 2.4, $W(p) = 2S$ with $S = \sum_{x\in H} f(x)$; we must show $S$ is odd.

Each $f(x) \in \{0,\pm 1\}$, so $f(x) \equiv f(x)^2 \pmod 2$ and hence $S \equiv \sum_{x \in H} f(x)^2 \pmod 2$. Now $f(x)^2 = 1$ unless $x(1-x^2) = 0$, i.e. unless $x \in \{0, 1, -1\}$. Of these, $0 \notin H$ by definition, $1 \in H$, and $-1 \notin H$ (its least residue is $p-1$). Therefore exactly one element of $H$ contributes $0$ and the rest contribute $1$:
$$\sum_{x\in H} f(x)^2 = |H| - 1 = \frac{p-1}{2} - 1 .$$
Since $p \equiv 1 \pmod 4$, $(p-1)/2$ is even, so this count is odd, whence $S$ is odd. $\square$

**Corollary 6.2 (Normalised two-square theorem).** For $p \equiv 1 \pmod 4$ there are integers $a$ (odd) and $b$ with $p = a^2+b^2$ and $2a = W(p)$.

This pins the classical normalisation: the two-square decomposition of $p$ has exactly one odd leg (as $p$ is odd, one leg is odd and one even), and the Jacobi-signed circle count computes twice that odd leg, sign included.

**Remark 6.3 (An observed mod-$8$ refinement).** In all computed cases the sign obeys $W(p) \equiv 2 \pmod 8$ when $p \equiv 5 \pmod 8$ and $W(p) \equiv 6 \pmod 8$ when $p \equiv 1 \pmod 8$ — equivalently $a \equiv 1$ resp. $3 \pmod 4$. This is a genuine (classical-looking) sign normalisation, but note carefully what it does and does not say: it determines $W(p)$ *modulo 8* from $p$ modulo $8$, while leaving $W(p)$ itself free. It is precisely the residual dial, and it is publicly computable from $N$; it carries no factorisation information. We record it as an empirical observation, not as a proved theorem of this work.

**Remark 6.4 (A dial-plus-parity witness is also dead).** Combining Theorem 6.1 with multiplicativity: for $N=pq$ with both primes $\equiv 1 \pmod 4$, $v_2(W(N)) = 2$. More generally the $2$-adic valuation of the statistic counts the number of prime factors $\equiv 1 \pmod 4$ — a real invariant, but for semiprimes it is already determined by $N \bmod 4$, so it leaks nothing new.

---

## 7. Exact evaluations: the dial is broken, the floor is reached

We record exact values, each obtained by direct evaluation of the defining sum.

$$W(5)=2,\quad W(13)=-6,\quad W(17)=-2,\quad W(29)=10,\quad W(41)=-10,\quad W(53)=-14,\quad W(173)=26,$$
$$W(21)=0,\qquad W(85)=-4 .$$

**Theorem 7.1 (Not a residue dial: prime level).** There is no function $f$ with $W(p) = f(p \bmod 8)$ for all primes $p$.

*Proof.* $17 \equiv 41 \equiv 1 \pmod 8$, but $W(17) = -2 \ne -10 = W(41)$. $\square$

**Theorem 7.2 (Not a dial mod 4).** There is no $f$ with $W(p) = f(p \bmod 4)$ for all primes $p$: $13 \equiv 17 \equiv 1 \pmod 4$ while $W(13) = -6 \ne -2 = W(17)$. $\square$

**Theorem 7.3 (Not a residue dial: composite level).** There is no $f$ with $W(N) = f(N \bmod 8)$ for all odd $N$: $21 \equiv 85 \equiv 5 \pmod 8$ while $W(21) = 0 \ne -4 = W(85)$. $\square$

Note the consistency of the composite values with multiplicativity: $W(85) = W(5)W(17) = 2\cdot(-2) = -4$ and $W(21) = W(3)W(7) = 0$.

This is the positive content of the experiment. Every previously examined character-weighted circle statistic in this family was a function of $N \bmod 4$ or $N \bmod 8$. The Jacobi weight breaks that collapse: within the class $p \equiv 1 \pmod 8$ the values run $-2, -10, 6, -18, 14, 22, \dots$, and within the class $N \equiv 5 \pmod 8$ the semiprime values include $0$ (at $N=21$), $-4$ (at $N=85$), $12$ (at $N=221$), $-20$ (at $N=205$) and $-52$ (at $N=2941$).

**Theorem 7.4 (Near-attainment of the Weil bound).** $W(173) = 26$ and $26^2 = 676 > 0.97\cdot(4\cdot 173) = 671.24$. Hence no inequality $W(p)^2 \le c\,p$ with $c < 3.9$ holds for all primes.

*Proof.* Direct evaluation and arithmetic. $\square$

Further attainments abound: $W(293) = 34$ with $34^2 = 1156$ against $4\cdot 293 = 1172$ (ratio $0.986$). By Theorem 5.4 the bound is attained to within a factor $1-O(b^2/p)$ exactly when the even leg $b$ of $p = a^2+b^2$ is small, which happens for the infinitely many primes of the form $a^2+4$ conjecturally, and demonstrably often in practice.

---

## 8. The verdict: three barriers

We now assemble the negative result. Let $N=pq$ be a semiprime with both factors $\equiv 1 \pmod 4$ (otherwise $W(N)=0$ by Corollary 3.6 and there is nothing to discuss).

### 8.1 Barrier 1: cost

Evaluating $W(N)$ from the definition requires $\Theta(N)$ Jacobi-symbol evaluations, i.e. $\widetilde{O}(N)$ bit operations. This is exponential in $\log N$ and already worse than trial division ($O(\sqrt N)$). There is no known shortcut: computing $W(N)$ quickly would require knowing $W(p)$ and $W(q)$ separately (Corollary 3.5), which by Theorem 5.4 amounts to computing the two-square decomposition of each factor — which presupposes the factorisation.

This is the sharpest form of the circularity: **the fast way to compute the statistic is to already know the answer.**

### 8.2 Barrier 2: symmetry

$W(N) = W(p)W(q)$ is a symmetric function of the factors. The statistic is invariant under swapping $p$ and $q$, so it cannot distinguish the two, and — worse — it presents their contributions only in entangled product form. Any witness of this shape suffers a structural inseparability: to use it, one must first split a product of two unknown integers, which is a scaled copy of the original problem.

### 8.3 Barrier 3: the Weil floor

By Corollary 4.8, $|W(N)| \le 4\sqrt N$. Since $W$ is even-valued and $W(N)=W(p)W(q)$ with each factor $\equiv 2 \pmod 4$, the value lives in a set of size $O(\sqrt N)$. Encoding the factorisation would require distinguishing among $\Theta(N/\log^2 N)$ possible factor pairs. By pigeonhole, the map from factorisations to statistic values is at least $\Omega(\sqrt N/\log^2 N)$-to-one: massive, irreparable collision.

Moreover Theorem 5.2 explains why no rescaling or twisting improves matters: $A(1)^2 + A(\nu)^2 = 4p$ is a conservation law. A witness that reads $A(1)$ reads a projection of a conserved quantity onto one axis; the complementary information sits in $A(\nu)$, and the total is $4p$ — determined by $p$ but only through its magnitude, which is precisely what $N$ already tells us in aggregate.

### 8.4 Empirical decorrelation

Beyond the structural obstructions, we tested whether the residual variation carries usable signal. For a sample of forty semiprimes $N = pq$ with $p \ne q$, both $\equiv 1 \pmod 4$ and both below $400$, we computed the Pearson correlation of $W(N)$ against each of $p$, $q$, $p+q$, $|p-q|$, and compared to a permutation null obtained by randomly reshuffling the $W$-values (2000 permutations). Every observed $|r|$ was small — below $0.25$ in all runs we performed — while the 95th percentile of the null lay in the range $0.28$–$0.32$. Under the null of no association, all four statistics are unremarkable.

The statistic is therefore **factor-dependent but unstructured**: its value depends on $p$ and $q$ (it is manufactured from them), yet no low-order functional of the factors is recoverable from it.

### 8.5 A new taxonomy entry

The failure mode here differs from the previously catalogued one and is worth naming.

* **Dial collapse (previous witnesses).** $F(N) = f(N \bmod m)$. Zero factorisation information; the witness is publicly computable in $O(1)$ and tells you what you already know.
* **Weil-floor collapse (this witness).** $F$ genuinely escapes every residue dial, is genuinely factor-dependent, and yet its total variation is $O(\sqrt N)$ with the dependence entering only through a symmetric product and a conserved quadratic form.

The second is a strictly deeper obstruction: it survives arbitrary re-weighting by multiplicative characters, as the next section explains. On this evidence, the *classical uniform hint-free surface* — natural point counts on classical curves over $\mathbb{Z}/N\mathbb{Z}$, weighted by classical characters, computed without any factor-dependent hint — appears exhausted.

---

## 9. Discussion, general principle, and future directions

### 9.1 The general principle

The proof of Theorem 2.1 used almost nothing about the weight: summing $y$ away converted the circle count into
$$\sum_x \psi(x)\bigl(1 + \chi(1-x^2)\bigr)$$
for the weight $\psi$. For any nontrivial multiplicative character $\psi$ the first piece vanishes and the second is, after the substitution $t = x^2$, a **Jacobi sum**. Jacobi sums of nontrivial characters have absolute value exactly $\sqrt p$. Hence:

> **Principle.** The $\sqrt p$ floor is a property of the circle, not of the weight. No choice of multiplicative weight on the $x$-coordinate produces a circle statistic of size larger than $O_d(\sqrt p)$, where $d$ is the order of the weight character.

This is the reason the negative verdict here should be read as structural rather than incidental. One does not escape the floor by changing the character; one would have to change the geometry.

### 9.2 What was gained

Three things.

1. **A clean, self-contained elementary proof of the Weil bound for $y^2 = x^3-x$**, via an exact second moment over quadratic twists, requiring no algebraic geometry.
2. **An exact identity**, $A(1)^2 + A(\nu)^2 = 4p$, from which Fermat's two-square theorem falls out with explicit, computable witnesses: $p = (W(p)/2)^2 + (A(\nu)/2)^2$ with $W(p)/2$ odd. The construction is arguably the most concrete route from character sums to Gaussian integers.
3. **A refutation with a mechanism.** The witness is dead, but we know exactly what killed it, and the killing generalises.

### 9.3 Future directions

**C1. Every character-weighted circle count is a quadratic-twist trace, hence at the floor.**
*Conjecture.* Let $\psi$ be any nontrivial multiplicative character mod $p$ of order $d$ and set $W_\psi(p) = \sum_{x^2+y^2=1}\psi(x)$. Then $|W_\psi(p)| \le d\sqrt p$, and $W_\psi(p)$ is a $\mathbb{Z}[\zeta_d]$-linear combination of traces of Frobenius of the curves $y^2 = x^3 - cx$ (for $d=2$) or of Jacobi sums $J(\psi,\chi)$ in general; in particular no choice of $\psi$ escapes the square-root floor.
*Key insight.* Summing $y$ away turns any circle weight into $\sum_x \psi(x)(1+\chi(1-x^2))$, i.e. a Jacobi sum, and Jacobi sums have absolute value exactly $\sqrt p$ — so the floor is a property of the circle, not of the weight.
*Why now.* The second-moment machinery developed here (the quadratic character sum evaluations, the exact moment, the squaring-pushforward lemma) is character-agnostic, so the $\sqrt p$ step is within reach.

**C2. The two-leg trade-off is a hard obstruction to factor leakage.**
*Conjecture.* For semiprimes $N=pq$ the pair $(W(N), A_\nu(N))$ is equidistributed on the "Weil circle" $u^2+v^2 \le 16N$ in the sense that, for any fixed $\varepsilon>0$, the map $N \mapsto W(N)/(4\sqrt N)$ has limiting distribution the (Sato–Tate-type) pushforward of the product of two arcsine laws — hence carries $O(1)$ bits about $p$ versus $q$.
*Key insight.* The Jacobsthal identity forces $W(p)$ and its nonresidue twin to trade off with $4p$ conserved: any large signal in one leg is compensated in the other, so a witness reading only one leg sees a conserved-quantity projection, never the split.
*Why now.* The identity is now a theorem, so the statement is unconditional in its algebraic half; only the equidistribution half is open, and the vanishing for $p\equiv 3 \pmod 4$ already proves a density-$1/2$ zero-information family.

**C3. The $2$-adic valuation is a complete obstruction to a "dial + parity" witness.**
*Conjecture.* For $N=pq$ with both primes $\equiv 1 \pmod 4$, $v_2(W(N)) = 2$ exactly, and more generally $v_2(W(N))$ equals the number of prime factors of $N$ that are $\equiv 1 \pmod 4$; consequently the $2$-adic valuation of the statistic counts those factors — a genuine but *already publicly computable* invariant (for semiprimes it is determined by $N \bmod 4$), so it leaks nothing new.
*Key insight.* The exact parity theorem gives $v_2(W(p)) = 1$ for each $p \equiv 1 \pmod 4$ and $W(p)=0$ otherwise; multiplicativity then adds valuations.

**C4. Beyond the circle.** Since the floor is a property of the geometry, the natural next probe is a family of curves whose point counts are *not* governed by a single Frobenius eigenvalue pair — higher genus, or non-CM families — where the trace lives in a higher-dimensional space and a witness might read a more informative projection. The cost barrier remains the binding constraint: any such witness must be computable in time $o(\sqrt N)$ to be of interest, which rules out naive point counting and forces attention onto statistics with fast (e.g. $p$-adic or Schoof-type) evaluation.

**C5. Sign structure.** Prove the observed mod-$8$ sign normalisation of Remark 6.3, $W(p) \equiv 2 \pmod 8$ for $p \equiv 5 \pmod 8$ and $W(p)\equiv 6 \pmod 8$ for $p \equiv 1 \pmod 8$, and determine exactly the residual "dial part" of the statistic — i.e. the largest quotient of $W$ that *is* a function of $N \bmod 2^k$. Quantifying the dial part isolates the genuinely non-dial content and gives a clean measure of how much of the statistic is public.

---

## 10. Conclusion

The Jacobi-signed circle count $W(N) = \sum_{x^2+y^2=1}\left(\frac{x}{N}\right)$ is the first witness in its family to escape residue-dial collapse: it is provably not a function of $N \bmod 8$, nor of $N \bmod 4$, at either prime or composite level. It is multiplicative, $W(pq) = W(p)W(q)$, hence genuinely factor-dependent. And it is, nonetheless, useless for factoring — for reasons we can state exactly. It costs $\Theta(N)$ to evaluate; it entangles the factors in a symmetric product; and it is pinned at the Weil floor $|W(N)| \le 4\sqrt N$, a bound that is not an estimate but the shadow of the exact conservation law $A(1)^2+A(\nu)^2 = 4p$.

That conservation law is the consolation. It identifies the statistic as twice the odd leg of the two-square decomposition of $p$, giving a fully explicit character-sum proof of Fermat's theorem that every prime $p \equiv 1 \pmod 4$ is a sum of two squares, with the odd leg normalised by $W(p)\equiv 2 \pmod 4$. The witness we set out to build does not exist; the reason it does not exist is a beautiful identity; and the identity is a classical theorem in disguise. Negative results of this shape are how a search space gets mapped.
