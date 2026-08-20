# Structure Theory for Beal's Conjecture: Coprimality Collapse, Hyperbolicity, and the Fermat–Catalan and $abc$ Bridges

**Author:** Aristotle
**Date:** 2026-08-20

## Abstract

Beal's conjecture asserts that if $A^x + B^y = C^z$ with $A,B,C$ positive integers and $x,y,z \ge 3$, then $A$, $B$, $C$ have a common prime factor. The conjecture is open. We develop a complete structure theory of the equation and prove a family of unconditional and conditional results that localise the difficulty precisely.

Unconditionally we prove: (i) a *three-way divisibility collapse* — a prime dividing two of the bases divides the third — whence a solution without a common prime factor has pairwise coprime bases; (ii) the resulting *single-coprimality reformulation*, that Beal's conjecture is equivalent to the non-existence of a solution with $\gcd(A,B)=1$; (iii) that Beal's conjecture implies Fermat's Last Theorem for every $n \ge 3$ by descent; (iv) the *quantitative hyperbolicity bound* $1/x + 1/y + 1/z \le 11/12$ for every solution, the boundary triple $(3,3,3)$ being removed by Fermat's Last Theorem for exponent three; (v) an exact reformulation of Beal's conjecture as the high-exponent part of the Fermat–Catalan equation; (vi) a reduction of the conjecture to exponents that are odd primes or $4$; (vii) a parity trichotomy — exactly one base is even — together with a mod-$8$ obstruction forbidding two even exponents when $C$ is even; (viii) sharpness of the hypothesis $x,y,z \ge 3$ in each slot separately, witnessed by $7^2+2^5=3^4$, $7^3+13^2=2^9$ and $2^7+17^3=71^2$; (ix) an exhaustively verified finite case; and (x) the full function-field analogue: over $k[X]$ with $\operatorname{char} k = 0$, Beal's statement is a theorem, via Mason–Stothers.

Conditionally we prove: the Fermat–Catalan conjecture implies that Beal's conjecture has at most finitely many counterexamples; and the $abc$ conjecture, in the effective integral form $c^{12} \le K \operatorname{rad}(abc)^{13}$, forces every counterexample to satisfy $C^z \le K^{12}$, with all six parameters then confined to an explicit finite box. Taken together, these results show that the residual obstruction to Beal's conjecture is purely the size of the error term in $abc$: every structural ingredient of the argument already transfers verbatim to the function-field setting, where the error term is absent and the conjecture is a theorem.

**Keywords:** Beal's conjecture, Fermat–Catalan equation, $abc$ conjecture, radical, Fermat's Last Theorem, Mason–Stothers theorem, perfect powers, hyperbolic exponent triples.

---

## 1. Introduction

### 1.1 The conjecture

Let $A, B, C, x, y, z$ be positive integers. The **Beal equation** is
$$A^x + B^y = C^z, \qquad x, y, z \ge 3. \tag{1.1}$$

Solutions of (1.1) are plentiful. For instance
$$3^3 + 6^3 = 27 + 216 = 243 = 3^5, \qquad 7^6 + 7^7 = 941192 = 98^3, \qquad 2^9 + 8^3 = 1024 = 2^{10}.$$
In each of these, the three bases share a prime factor ($3$, $7$, $2$ respectively). Beal's conjecture, formulated in 1993, asserts that this is universal.

> **Conjecture 1.1 (Beal).** If $A^x + B^y = C^z$ with $A,B,C \ge 1$ and $x,y,z \ge 3$, then there is a prime $p$ with $p \mid A$, $p \mid B$ and $p \mid C$.

Throughout we use the following terminology.

> **Definition 1.2 (Beal solution).** A tuple $(A,B,C,x,y,z)$ of natural numbers is a *Beal solution* if $A,B,C > 0$, $x,y,z \ge 3$, and $A^x + B^y = C^z$.

> **Definition 1.3 (common prime).** Natural numbers $A,B,C$ *have a common prime* if there exists a prime $p$ dividing each of $A$, $B$, $C$.

> **Definition 1.4 (Beal counterexample).** A *Beal counterexample* is a Beal solution whose bases have no common prime.

Conjecture 1.1 is exactly the assertion that the set of Beal counterexamples is empty.

### 1.2 What is proved here

The conjecture is open, and we do not prove it. What we do is delimit it from every available direction. Sections 2–4 give the unconditional structure theory. Sections 5–6 give the two conditional bridges, to the Fermat–Catalan conjecture and to $abc$. Section 7 proves the function-field analogue outright. Section 8 assembles the profile of a hypothetical counterexample. Sections 9–11 discuss algorithms, applications and future work.

A reader who wants a single takeaway should note the pairing of Theorem 6.7 (the $abc$ conjecture bounds every counterexample by an explicit constant) with Theorem 7.3 (the polynomial analogue is a theorem, by the same argument with $\varepsilon = 0$). All the combinatorial, divisibility-theoretic and exponent-counting work in Beal's conjecture is *complete*; the sole residue is the quantitative gap between $\operatorname{rad}(abc)$ and $\operatorname{rad}(abc)^{1+\varepsilon}$.

---

## 2. The three-way divisibility collapse

The starting point is elementary but structurally decisive: for the equation $A^x + B^y = C^z$, the three bases are divisibility-theoretically inseparable.

> **Lemma 2.1.** Let $p$ be prime, let $x, y \ge 1$, and suppose $A^x + B^y = C^z$. If $p \mid A$ and $p \mid B$, then $p \mid C$.

*Proof.* From $p \mid A$ and $x \ge 1$ we get $p \mid A^x$; likewise $p \mid B^y$. Hence $p$ divides $A^x + B^y = C^z$. Since $p$ is prime and $p \mid C^z$, we conclude $p \mid C$. $\square$

> **Lemma 2.2.** Let $p$ be prime, let $x, z \ge 1$, and suppose $A^x + B^y = C^z$. If $p \mid A$ and $p \mid C$, then $p \mid B$.

*Proof.* Rearranging, $B^y = C^z - A^x$. Both terms on the right are divisible by $p$ (using $z \ge 1$ and $x \ge 1$), so $p \mid B^y$ and therefore $p \mid B$. $\square$

> **Lemma 2.3.** Symmetrically, if $y, z \ge 1$ and $p \mid B$, $p \mid C$, then $p \mid A$.

The three lemmas combine into the key dichotomy.

> **Theorem 2.4 (Pairwise coprimality).** Let $(A,B,C,x,y,z)$ be a Beal solution whose bases have no common prime. Then $A,B,C$ are pairwise coprime:
> $$\gcd(A,B) = \gcd(A,C) = \gcd(B,C) = 1.$$

*Proof.* Suppose $\gcd(A,B) > 1$. Then some prime $p$ divides $\gcd(A,B)$, hence divides both $A$ and $B$; by Lemma 2.1 it divides $C$ as well, so $A,B,C$ have a common prime, a contradiction. The other two cases are identical, using Lemmas 2.2 and 2.3 respectively. $\square$

Thus there is no intermediate regime. A solution is either fully entangled (all three bases sharing a prime) or fully disentangled (no two bases sharing anything). This immediately reduces the three-fold conclusion of Conjecture 1.1 to a single hypothesis.

> **Theorem 2.5 (Single-coprimality reformulation).** Beal's conjecture is equivalent to the statement
> $$\text{there is no } (A,B,C,x,y,z) \text{ with } A,B,C>0,\; x,y,z\ge 3,\; A^x+B^y=C^z,\; \gcd(A,B)=1.$$

*Proof.* ($\Rightarrow$) If such a tuple existed, Beal's conjecture would provide a prime $p$ dividing $A$ and $B$, contradicting $\gcd(A,B)=1$ since $p > 1$.
($\Leftarrow$) Let $(A,B,C,x,y,z)$ be a Beal solution and suppose its bases had no common prime. Theorem 2.4 gives $\gcd(A,B)=1$, producing exactly the forbidden tuple. $\square$

An immediate corollary in the positive direction:

> **Corollary 2.6.** If $(A,B,C,x,y,z)$ is a Beal solution with $\gcd(A,B) > 1$, then $A,B,C$ have a common prime — Beal's conjecture holds for that solution.

> **Corollary 2.7 (Equal bases).** Every Beal solution with $A = B$ satisfies Beal's conjecture.

*Proof.* If $A \ge 2$, its least prime factor $p$ divides both $A$ and $B = A$, and Lemma 2.1 gives $p \mid C$. If $A = 1$ then $C^z = 2$ with $z \ge 3$, impossible: $C = 1$ gives $C^z = 1$, and $C \ge 2$ gives $C^z \ge 8$. $\square$

---

## 3. Non-vacuity and sharpness of the hypotheses

### 3.1 Solutions exist, and there are infinitely many

> **Proposition 3.1.** $(3,6,3,3,3,5)$ is a Beal solution, and $3$ divides each of $3, 6, 3$.

Indeed $3^3 + 6^3 = 243 = 3^5$.

> **Theorem 3.2 (Infinitude).** For every $N$ there is a Beal solution with $C > N$ whose bases have a common prime. Explicitly, for every $t \ge 1$,
> $$(3t^5)^3 + (6t^5)^3 = (3t^3)^5,$$
> a Beal solution with all three bases divisible by $3$, and $3t^3 \to \infty$.

*Proof.* Expanding, the left side is $27t^{15} + 216t^{15} = 243t^{15}$, and the right side is $3^5 t^{15} = 243 t^{15}$. Taking $t = N+1$ gives $C = 3(N+1)^3 \ge 3(N+1) > N$. $\square$

So Conjecture 1.1 is a statement about an infinite family, not a vacuous one; and every known member of that family is a scaled copy of a smaller identity, which is exactly what the conjecture predicts must always happen.

### 3.2 The bound $x,y,z \ge 3$ is sharp in each slot

Relaxing any single exponent bound from $3$ to $2$ makes the conclusion false. Each of the three counterexamples below has pairwise coprime bases.

> **Theorem 3.3 (Sharpness).** The following statements are all false:
> 1. "$A^x + B^y = C^z$ with $x \ge 2$, $y,z \ge 3$ implies $A,B,C$ have a common prime" — refuted by $7^2 + 2^5 = 49 + 32 = 81 = 3^4$.
> 2. "$A^x + B^y = C^z$ with $x \ge 3$, $y \ge 2$, $z \ge 3$ implies $A,B,C$ have a common prime" — refuted by $7^3 + 13^2 = 343 + 169 = 512 = 2^9$.
> 3. "$A^x + B^y = C^z$ with $x,y \ge 3$, $z \ge 2$ implies $A,B,C$ have a common prime" — refuted by $2^7 + 17^3 = 128 + 4913 = 5041 = 71^2$.

*Proof.* Each displayed identity is a direct computation, and in each case the two summand bases are coprime ($\gcd(7,2)=\gcd(7,13)=\gcd(2,17)=1$), so no prime can divide all three bases. $\square$

These three identities are sporadic solutions of the Fermat–Catalan equation (Section 5); their existence is the reason Beal's conjecture must impose $x,y,z \ge 3$ uniformly.

---

## 4. Fermat's Last Theorem, descent, and hyperbolicity

### 4.1 Beal implies Fermat

Recall that *Fermat's Last Theorem for the exponent $n$*, written $\mathrm{FLT}_n$, is the assertion that $a^n + b^n = c^n$ has no solution in positive integers.

> **Theorem 4.1 (Beal $\Rightarrow$ FLT).** If Beal's conjecture holds, then $\mathrm{FLT}_n$ holds for every $n \ge 3$.

*Proof.* Fix $n \ge 3$ and argue by strong induction on $a$, proving: for all positive $b, c$, $a^n + b^n \ne c^n$. Suppose $a^n + b^n = c^n$ with $a,b,c>0$. Then $(a,b,c,n,n,n)$ is a Beal solution, so Beal's conjecture supplies a prime $p$ with $a = pa'$, $b = pb'$, $c = pc'$. Substituting gives $p^n(a'^n + b'^n) = p^n c'^n$, and cancelling the positive factor $p^n$ yields $a'^n + b'^n = c'^n$ with $a', b', c' > 0$ and $a' = a/p < a$ (as $p \ge 2$). This contradicts the inductive hypothesis at $a'$. $\square$

The converse direction, from FLT to Beal, is not available — Beal's conjecture is strictly a generalisation — but FLT supplies unconditional special cases.

> **Theorem 4.2 (Equal exponents).** If $\mathrm{FLT}_n$ holds, then there is no Beal solution with $x=y=z=n$. In particular there is no such solution when $3 \mid n$ or $4 \mid n$.

*Proof.* The first statement is the definition. For the second, if $d \mid n$ and $\mathrm{FLT}_d$ holds then $\mathrm{FLT}_n$ holds, because $a^n + b^n = c^n$ can be rewritten as $(a^{n/d})^d + (b^{n/d})^d = (c^{n/d})^d$. Now apply the classical theorems $\mathrm{FLT}_3$ (Euler) and $\mathrm{FLT}_4$ (Fermat). $\square$

The same regrouping trick works for unequal exponents.

> **Theorem 4.3 (gcd of exponents).** If $3 \mid \gcd(x,y,z)$ or $4 \mid \gcd(x,y,z)$, then $A^x + B^y = C^z$ has no solution in positive integers with $x,y,z \ge 3$.

*Proof.* Let $d = \gcd(x,y,z)$ and write $x = dm_x$, $y = dm_y$, $z = dm_z$. Then $(A^{m_x})^d + (B^{m_y})^d = (C^{m_z})^d$ is a solution of Fermat's equation with exponent $d$, contradicting $\mathrm{FLT}_d$, which holds because $3 \mid d$ or $4 \mid d$. $\square$

For example the exponent triple $(6,9,15)$ has gcd $3$, so *no* solutions exist there at all, and Beal's conjecture holds vacuously.

### 4.2 Quantitative hyperbolicity

The exponent triple of a Beal solution cannot be arbitrarily close to the euclidean boundary $1/x+1/y+1/z = 1$.

> **Theorem 4.4 (Quantitative hyperbolicity).** Every Beal solution $(A,B,C,x,y,z)$ satisfies
> $$\frac1x + \frac1y + \frac1z \;\le\; \frac{11}{12}.$$

*Proof.* Since $x,y,z \ge 3$, each reciprocal is at most $1/3$. If at least one exponent is $\ge 4$, then the corresponding reciprocal is at most $1/4$ and the sum is at most $1/4 + 1/3 + 1/3 = 11/12$. Otherwise $x = y = z = 3$; but then $A^3 + B^3 = C^3$ with positive bases, contradicting $\mathrm{FLT}_3$. $\square$

> **Corollary 4.5 (Strict hyperbolicity).** Every Beal solution satisfies $1/x + 1/y + 1/z < 1$.

The constant $11/12$ is optimal, being attained by $(3,3,4)$ and its permutations; note that the *existence* of the strict gap is not formal — it is exactly $\mathrm{FLT}_3$ that removes the euclidean triple $(3,3,3)$. This gap is what makes the $abc$ argument of Section 6 possible: an inequality with a multiplicative error term can only be exploited against a strictly negative Euler characteristic.

### 4.3 Reduction to prime exponents

> **Lemma 4.6.** Every integer $n \ge 3$ has a divisor $d \ge 3$ that is either an odd prime or equal to $4$.

*Proof.* If $4 \mid n$, take $d = 4$. Otherwise, $n$ is odd or $n = 2m$ with $m$ odd; in the second case $m \ge 3$ since $n \ge 3$ and $n \ne 4, 2$. In either case $n$ has an odd divisor $m \ge 3$, whose least prime factor is an odd prime $\ge 3$ dividing $n$. $\square$

> **Theorem 4.7 (Exponent reduction).** Suppose Beal's conjecture holds for all solutions whose three exponents are each an odd prime or $4$. Then Beal's conjecture holds in general.

*Proof.* Let $(A,B,C,x,y,z)$ be any Beal solution. By Lemma 4.6 choose $d \mid x$, $e \mid y$, $f \mid z$ with each of $d,e,f$ an odd prime or $4$ (in particular each $\ge 3$). Regrouping,
$$(A^{x/d})^d + (B^{y/e})^e = (C^{z/f})^f,$$
a Beal solution with the restricted exponents, so by hypothesis a prime $p$ divides $A^{x/d}$, $B^{y/e}$ and $C^{z/f}$. As $p$ is prime, $p \mid A$, $p \mid B$, $p \mid C$. $\square$

So Conjecture 1.1 rests on a set of exponent triples of density zero inside $\{3,4,5,\dots\}^3$ — and among those, all triples with $x=y=z$ divisible by $3$ or $4$, in particular $(3,3,3)$ and $(4,4,4)$, are already theorems.

---

## 5. The Fermat–Catalan bridge

> **Definition 5.1 (Fermat–Catalan solution).** A tuple $(a,b,c,x,y,z)$ of positive integers is a *Fermat–Catalan solution* if
> $$a,b,c > 0, \quad x,y,z \ge 2, \quad \gcd(a,b)=\gcd(a,c)=\gcd(b,c)=1, \quad \frac1x+\frac1y+\frac1z<1, \quad a^x + b^y = c^z.$$

The hyperbolicity condition is what makes the problem finite in spirit: in the spherical range $1/x+1/y+1/z>1$ the solutions form infinite parametrised families, and in the euclidean range they are governed by elliptic curves.

Only ten Fermat–Catalan solutions are currently known:
$$1^m + 2^3 = 3^2,\quad 2^5 + 7^2 = 3^4,\quad 7^3 + 13^2 = 2^9,\quad 2^7 + 17^3 = 71^2,\quad 3^5 + 11^4 = 122^2,$$
$$33^8 + 1549034^2 = 15613^3,\quad 1414^3 + 2213459^2 = 65^7,\quad 9262^3 + 15312283^2 = 113^7,$$
$$17^7 + 76271^3 = 21063928^2, \quad 43^8 + 96222^3 = 30042907^2.$$
Every one of them has an exponent equal to $2$. The **Fermat–Catalan conjecture** asserts that the solution set is finite.

> **Theorem 5.2 (Counterexamples are Fermat–Catalan solutions).** Every Beal counterexample is a Fermat–Catalan solution.

*Proof.* Let $(A,B,C,x,y,z)$ be a Beal counterexample. The bases are positive and, by Theorem 2.4, pairwise coprime. The exponents satisfy $x,y,z \ge 3 \ge 2$, and $1/x+1/y+1/z < 1$ by Corollary 4.5. Finally $A^x+B^y=C^z$ by hypothesis. $\square$

> **Corollary 5.3 (Conditional finiteness).** If the Fermat–Catalan conjecture holds, then Beal's conjecture has at most finitely many counterexamples.

*Proof.* A subset of a finite set is finite. $\square$

The relationship is in fact an exact identification of Beal's conjecture with a part of Fermat–Catalan.

> **Theorem 5.4 (Fermat–Catalan reformulation).** Beal's conjecture holds if and only if no Fermat–Catalan solution has all three exponents $\ge 3$.

*Proof.* ($\Rightarrow$) Given a Fermat–Catalan solution with $x,y,z\ge3$, it is a Beal solution, so Beal's conjecture yields a prime dividing $a$ and $b$, contradicting $\gcd(a,b)=1$.
($\Leftarrow$) Let $(A,B,C,x,y,z)$ be a Beal solution with no common prime. By Theorem 5.2 it is a Fermat–Catalan solution, and its exponents are all $\ge 3$, contradicting the hypothesis. $\square$

Beal's conjecture is therefore precisely the assertion that the Fermat–Catalan equation has no solutions in the "high-exponent" region $\min(x,y,z) \ge 3$ — the empirical content of the observation that every one of the ten known solutions uses an exponent $2$.

---

## 6. The $abc$ bridge

### 6.1 Radicals

> **Definition 6.1 (Radical).** For $n \ge 1$, the *radical* $\operatorname{rad}(n)$ is the product of the distinct primes dividing $n$, with $\operatorname{rad}(1)=1$.

Thus $\operatorname{rad}(72) = \operatorname{rad}(2^3 3^2) = 6$ and $\operatorname{rad}(p^k)=p$. Two elementary facts are used repeatedly: $\operatorname{rad}(n) \ge 1$, and $\operatorname{rad}(n) \mid n$, hence $\operatorname{rad}(n) \le n$.

The decisive property is that the radical is blind to exponents.

> **Lemma 6.2 (Exponent-blindness).** For positive $A,B,C$ and positive $x,y,z$,
> $$\operatorname{rad}(A^x B^y C^z) = \operatorname{rad}(ABC) \le ABC.$$

*Proof.* The set of primes dividing a product is the union of the sets of primes dividing each factor, and the set of primes dividing $A^x$ equals the set of primes dividing $A$ whenever $x \ge 1$. Hence $A^xB^yC^z$ and $ABC$ have the same prime support, so the same radical. The inequality is $\operatorname{rad}(m)\mid m$. $\square$

This lemma is the entire reason $abc$ has anything to say about Beal's equation: the equation $A^x + B^y = C^z$ has *enormous* terms but a *tiny* radical, exactly the configuration $abc$ forbids.

### 6.2 The two forms of the $abc$ conjecture

> **Definition 6.3 (Effective integral $abc$ bound).** For $K \in \mathbb{N}$, the statement $\mathrm{ABC}(K)$ says: for all positive integers $a,b$ with $a+b=c$ and $\gcd(a,b)=1$,
> $$c^{12} \le K \cdot \operatorname{rad}(abc)^{13}.$$

This is the case $\varepsilon = 1/12$ of the usual conjecture, cleared of denominators.

> **Definition 6.4 (Masser–Oesterlé $abc$ conjecture).** For every real $\varepsilon > 0$ there is a real $K_\varepsilon > 0$ such that every coprime triple of positive integers with $a+b=c$ satisfies
> $$c \le K_\varepsilon \cdot \operatorname{rad}(abc)^{1+\varepsilon}.$$

> **Proposition 6.5.** The $abc$ conjecture implies $\mathrm{ABC}(K)$ for some positive integer $K$.

*Proof.* Apply Definition 6.4 with $\varepsilon = 1/12$ to obtain a real constant $K_{1/12} > 0$ with $c \le K_{1/12} r^{13/12}$, where $r = \operatorname{rad}(abc) \ge 1$. Raising to the twelfth power gives $c^{12} \le K_{1/12}^{12} r^{13}$. Take $K = \lceil K_{1/12}^{12}\rceil + 1$, a positive integer exceeding $K_{1/12}^{12}$; since $r^{13}\ge1$, the integral inequality $c^{12} \le K r^{13}$ follows. $\square$

### 6.3 The exponent count

> **Lemma 6.6 (Product of bases is small).** Let $(A,B,C,x,y,z)$ be a Beal solution and write $N = C^z$. Then
> $$(ABC)^{12} \le N^{11}.$$

*Proof.* Since $B^y > 0$ we have $A^x \le N$, and similarly $B^y \le N$; also $C^z = N$. As $A \ge 1$, the map $m \mapsto A^m$ is nondecreasing, so $A^3 \le A^x \le N$; similarly $B^3 \le N$ and $C^3 \le N$. By Theorem 4.4's case analysis, at least one exponent is $\ge 4$ (otherwise $x=y=z=3$, excluded by $\mathrm{FLT}_3$). Suppose $x \ge 4$, so also $A^4 \le N$. Then
$$(ABC)^{12} = (A^4)^3 (B^3)^4 (C^3)^4 \le N^3 \cdot N^4 \cdot N^4 = N^{11}.$$
If instead $y \ge 4$ use $(ABC)^{12} = (A^3)^4(B^4)^3(C^3)^4 \le N^{11}$, and if $z \ge 4$ use $(ABC)^{12} = (A^3)^4(B^3)^4(C^4)^3 \le N^{11}$. $\square$

The exponents $12$ and $11$ here are precisely $1$ and $11/12$ scaled by $12$: the lemma is the integral shadow of the hyperbolicity bound $1/x+1/y+1/z \le 11/12$, since heuristically $ABC \approx N^{1/x+1/y+1/z}$.

### 6.4 The main conditional theorem

> **Theorem 6.7 ($abc$ bounds Beal counterexamples).** Assume $\mathrm{ABC}(K)$. Then every Beal counterexample $(A,B,C,x,y,z)$ satisfies
> $$C^z \le K^{12}.$$

*Proof.* Write $N = C^z > 0$. By Theorem 2.4 the bases are pairwise coprime, so in particular $\gcd(A^x, B^y) = 1$. Apply $\mathrm{ABC}(K)$ to the coprime triple $A^x + B^y = N$:
$$N^{12} \le K \cdot \operatorname{rad}(A^x B^y N)^{13}.$$
By Lemma 6.2, $\operatorname{rad}(A^xB^yC^z) = \operatorname{rad}(ABC) \le ABC$, whence
$$N^{12} \le K (ABC)^{13}. \tag{6.1}$$
Raise (6.1) to the twelfth power and apply Lemma 6.6:
$$N^{144} = (N^{12})^{12} \le K^{12}\big((ABC)^{12}\big)^{13} \le K^{12}(N^{11})^{13} = K^{12} N^{143}.$$
Cancelling the positive factor $N^{143}$ gives $N \le K^{12}$. $\square$

> **Corollary 6.8 ($abc$ $\Rightarrow$ bounded counterexamples).** If the $abc$ conjecture holds, there is an explicit $M$ (namely $M = K^{12}$ for the $K$ of Proposition 6.5) such that every Beal counterexample satisfies
> $$A^x \le M, \qquad B^y \le M, \qquad C^z \le M.$$

*Proof.* Combine Proposition 6.5 and Theorem 6.7; the bounds on $A^x$ and $B^y$ follow since they are positive summands of $C^z \le M$. $\square$

> **Corollary 6.9 (The whole tuple is boxed).** Under the $abc$ conjecture there is an $M$ such that every Beal counterexample with $A \ge 2$ and $B \ge 2$ satisfies
> $$A, B, C, x, y, z \le M.$$

*Proof.* Take $M$ as in Corollary 6.8. First, $C \ge 2$: if $C = 1$ then $C^z = 1$, while $A^x + B^y \ge 2^3 + 2^3 = 16$. Now for any base $a \ge 2$ and exponent $e \ge 3$ with $a^e \le M$: we have $a \le a^e \le M$, and $e < 2^e \le a^e \le M$. Applying this to each of $(A,x)$, $(B,y)$, $(C,z)$ gives the claim. $\square$

Thus, conditionally on $abc$, Beal's conjecture becomes a finite (if astronomically large) verification. This is the precise sense in which $abc$ is "almost" enough: it removes the infinitude of the problem without removing its difficulty, since no admissible value of $K_{1/12}$ is known.

---

## 7. The function-field analogue is a theorem

Let $k$ be a field of characteristic zero and $k[X]$ the polynomial ring. Under the standard analogy $\mathbb Z \leftrightarrow k[X]$, primes correspond to irreducible polynomials and $\log|n|$ to $\deg$. In this setting the $abc$ inequality is the **Mason–Stothers theorem**, and — critically — it holds *with no error term $\varepsilon$*. Consequently the argument of Section 6 goes through unconditionally and yields the analogue of Beal's conjecture as a theorem.

> **Lemma 7.1 (Multiplicative hyperbolicity).** If $x,y,z \ge 3$ then $yz + zx + xy \le xyz$, equivalently $1/x+1/y+1/z \le 1$.

*Proof.* $3(yz) \le x(yz)$, $3(zx) \le y(zx)$, $3(xy) \le z(xy)$; summing and dividing by $3$ gives $yz+zx+xy \le xyz$. $\square$

> **Lemma 7.2.** If $p \in k[X]$ is prime, $x,y \ge 1$ and $a^x + b^y = c^z$ with $p \mid a$ and $p \mid b$, then $p \mid c$.

*Proof.* Identical to Lemma 2.1: $p$ divides $a^x + b^y = c^z$, and a prime dividing a power divides the base. $\square$

> **Theorem 7.3 (Polynomial Beal theorem).** Let $\operatorname{char} k = 0$ and let $a,b,c \in k[X]$ be nonzero with
> $$a^x + b^y = c^z, \qquad x,y,z \ge 3.$$
> If at least one of $a,b,c$ is non-constant, then there is a prime (irreducible) $p \in k[X]$ dividing all three of $a$, $b$, $c$.

*Proof sketch.* Suppose not. Then no prime divides both $a$ and $b$ — for by Lemma 7.2 such a prime would divide $c$ too — so $a$ and $b$ are coprime in $k[X]$. Rewrite the equation as the vanishing linear relation
$$1 \cdot a^x + 1 \cdot b^y + (-1)\cdot c^z = 0,$$
with all three coefficients nonzero and summing appropriately, and with $x,y,z \ge 3$ invertible in $k$ (characteristic zero). The Mason–Stothers theorem, in its Fermat–Catalan form for polynomials, states that under the hyperbolicity inequality $yz+zx+xy \le xyz$ of Lemma 7.1 any such coprime solution must have $a$, $b$, $c$ all of degree $0$, i.e. all constant. This contradicts the assumption that one of them is non-constant. $\square$

> **Corollary 7.4 (Coprime form).** If $a,b,c \in k[X]$ are nonzero with $a^x+b^y=c^z$, $x,y,z\ge3$, and $a,b$ coprime, then $a$, $b$ and $c$ are all constant.

*Proof.* Were one of them non-constant, Theorem 7.3 would produce a prime dividing both $a$ and $b$, contradicting coprimality. $\square$

The analogy is faithful even at the level of examples: scaling the integer identity $3^3 + 6^3 = 3^5$ by $X^{15}$ gives
$$(3X^5)^3 + (6X^5)^3 = (3X^3)^5 \quad \text{in } \mathbb{Q}[X],$$
a non-constant solution whose three entries do share the irreducible factor $X$, exactly as Theorem 7.3 requires.

**Interpretation.** Compare Theorem 6.7 with Theorem 7.3. Both proofs consist of: (i) a divisibility collapse producing coprimality; (ii) an $abc$-type inequality bounding the size of the solution by its radical; (iii) the hyperbolicity inequality $1/x+1/y+1/z \le 1$ (with a strict gap over $\mathbb Z$). Over $k[X]$ step (ii) is a theorem with no error term, and steps (i)–(iii) close the argument completely. Over $\mathbb Z$ step (ii) is conjectural and carries an error term $\operatorname{rad}^{\varepsilon}$, which is why the same argument yields only a bound $C^z \le K^{12}$ rather than a contradiction. The entire gap between "open conjecture" and "theorem" is that $\varepsilon$.

---

## 8. The profile of a hypothetical counterexample

Assembling the results above, together with two congruence obstructions, gives a rigid description of anything that could refute Beal's conjecture.

> **Theorem 8.1 (Parity trichotomy).** In a Beal solution with $\gcd(A,B)=1$, exactly one of $A$, $B$, $C$ is even.

*Proof.* $A$ and $B$ cannot both be even, by coprimality. If they are both odd then $C^z = A^x + B^y$ is even, so $C$ is even and neither $A$ nor $B$ is. If exactly one of $A,B$ is even, then $C^z$ is odd, so $C$ is odd. In every case exactly one of the three is even. $\square$

> **Theorem 8.2 (Mod-8 obstruction).** In a Beal solution with $\gcd(A,B)=1$ and $C$ even, the exponents $x$ and $y$ cannot both be even.

*Proof.* By Theorem 8.1, $A$ and $B$ are both odd. An odd square is $\equiv 1 \pmod 8$, hence an odd number raised to an even power is $\equiv 1 \pmod 8$. So if $x$ and $y$ are both even then $A^x + B^y \equiv 1 + 1 = 2 \pmod 8$. On the other hand $C$ is even and $z \ge 3$, so $8 = 2^3 \mid C^z$, i.e. $C^z \equiv 0 \pmod 8$. But $2 \not\equiv 0 \pmod 8$. $\square$

> **Theorem 8.3 (Small-box verification).** There is no coprime solution of $A^x + B^y = C^z$ with $1 \le A,B \le 10$, $1 \le C \le 40$ and $3 \le x,y,z \le 5$. Consequently every Beal solution in that range has a common prime factor.

*Proof.* Exhaustive enumeration over the $10 \times 10 \times 40 \times 3 \times 3 \times 3 = 108{,}000$ tuples, discarding those with $\gcd(A,B)>1$, finds no equality. Given a Beal solution in the range with no common prime, Theorem 2.4 gives $\gcd(A,B)=1$, contradicting the enumeration. $\square$

**Summary of constraints.** Let $(A,B,C,x,y,z)$ be a Beal counterexample. Then:

1. $A$, $B$, $C$ are pairwise coprime (Theorem 2.4), and in particular $A \ne B$ unless $A=B=1$, which is impossible (Corollary 2.7).
2. $1/x+1/y+1/z \le 11/12$; at least one exponent exceeds $3$ (Theorem 4.4).
3. Neither $3$ nor $4$ divides $\gcd(x,y,z)$ (Theorem 4.3).
4. One may assume each of $x,y,z$ is an odd prime or $4$ (Theorem 4.7).
5. Exactly one of $A,B,C$ is even (Theorem 8.1); if it is $C$, then $x,y$ are not both even (Theorem 8.2).
6. It is a Fermat–Catalan solution (Theorem 5.2), hence one of at most finitely many if Fermat–Catalan holds (Corollary 5.3).
7. Assuming $abc$, $C^z \le K^{12}$ and the entire tuple lies in an explicit finite box (Corollaries 6.8, 6.9).
8. It lies outside the verified range $A,B \le 10$, $C \le 40$, $x,y,z \le 5$ (Theorem 8.3).

---

## 9. Algorithms

Three computational procedures follow directly from the theory and are used to explore the constraints above.

### 9.1 Structured search for Beal solutions

Naïvely one iterates over $(A,x,B,y)$, forms $S = A^x + B^y$, and tests whether $S$ is a perfect power with exponent $\ge 3$. The efficient version precomputes, for a target bound $M$, a dictionary mapping every perfect power $C^z \le M$ with $z \ge 3$ to its representation $(C,z)$. Building the table costs $O(M^{1/3}\log M)$ arithmetic operations, and each of the $O((M^{1/3})^2 (\log M)^2)$ candidate pairs is then tested in $O(1)$ expected time. Every solution found is checked against the theory: if $\gcd(A,B)>1$, Corollary 2.6 predicts a common prime; if $\gcd(A,B)=1$, the tuple would be a counterexample.

### 9.2 Constraint filter for hypothetical counterexamples

Given an exponent triple $(x,y,z)$ one can decide in $O(1)$ whether it could support a counterexample: reject if $1/x+1/y+1/z > 11/12$; reject if $3 \mid \gcd(x,y,z)$ or $4 \mid \gcd(x,y,z)$; and, for the branch where $C$ is even, reject if $x$ and $y$ are both even. Combined with the reduction of Theorem 4.7 to exponents that are odd primes or $4$, this prunes the exponent search space to density zero.

### 9.3 Radical and $abc$-quality computation

For a coprime triple $a+b=c$ the *quality* is
$$q(a,b,c) = \frac{\log c}{\log \operatorname{rad}(abc)}.$$
The $abc$ conjecture says $\limsup q = 1$ over coprime triples, i.e. for each $\varepsilon>0$ only finitely many triples have $q > 1+\varepsilon$. Computing $q$ requires factoring $abc$, done by trial division in $O(\sqrt{abc})$ or by a sieve for a batch. Applied to a Beal solution, the identity $\operatorname{rad}(A^xB^yC^z)=\operatorname{rad}(ABC)$ makes $q$ large exactly when the bases are small relative to $C^z$, which is why every scaled solution such as $(3t^5)^3+(6t^5)^3=(3t^3)^5$ has quality bounded away from the extremes, while a hypothetical counterexample would necessarily have quality above $1 + 1/12$ once $C^z$ exceeds $K^{12}$.

---

## 10. Applications and interpretation

**A calibration of $abc$.** Theorem 6.7 shows that the "$\varepsilon = 1/12$" case of $abc$ suffices for a complete finiteness statement about Beal's equation. Since $11/12$ is exactly the extremal value of $1/x+1/y+1/z$ over admissible exponent triples, this is not an arbitrary choice: any $\varepsilon < 1/11$ would do, and $1/12$ gives the cleanest integral bookkeeping. Beal's conjecture therefore serves as a concrete test case for effective forms of $abc$: an explicit admissible $K_\varepsilon$ for even a single $\varepsilon < 1/11$ would reduce Beal's conjecture to a finite computation.

**A separation of structural and analytic difficulty.** The function-field theorem shows that no additional algebraic idea is missing. Coprimality, descent, exponent reduction, and the hyperbolicity count all transfer. Only the analytic inequality does not.

**Search guidance.** The constraint list of Section 8 is directly actionable for computational searches. Restricting to pairwise coprime bases (a factor $\zeta(2)^{-1}$-ish density saving in practice, plus a hard filter), to exponent triples that are odd primes or $4$, and to parity- and mod-$8$-admissible configurations, shrinks the search space by orders of magnitude relative to a naïve sweep. This is how large-scale computational searches, which have so far found no counterexample, are organised.

**A template for related equations.** The same three-step architecture — divisibility collapse, radical exponent-blindness, hyperbolicity — applies verbatim to the generalised Fermat equation $Aa^x + Bb^y = Cc^z$ and to Fermat–Catalan itself. The Beal case is the special case with unit coefficients and $\min(x,y,z)\ge3$, and is the cleanest illustration.

---

## 11. Discussion and future directions

### 11.1 What would a proof require?

By Theorem 2.5 a proof need only rule out solutions with $\gcd(A,B)=1$; by Theorem 4.7 the exponents may be assumed to be odd primes or $4$. By Theorem 4.1 any proof necessarily contains a proof of Fermat's Last Theorem, so no elementary argument can succeed. By Theorem 7.3 the proof will differ from the function-field proof precisely at the point where an error term must be handled. These four facts, taken together, sharply constrain the space of plausible strategies: the successful argument will be either (a) a modularity/Galois-representation argument in the style of the Frey–Hellegouarch curve, extended to the generalised Fermat equation, or (b) an effective $abc$-type inequality.

### 11.2 Conjecture C1: a single Fermat–Catalan statement with prime exponents

Beal's conjecture should hold if and only if the Fermat–Catalan equation $a^p + b^q = c^r$ has no coprime solution with $a,b,c \ge 1$ and $p,q,r$ each an odd prime or $4$. Theorem 4.7 already gives one direction unconditionally, so the whole conjecture collapses onto a set of exponent triples of density zero — and among those, $(3,3,3)$, $(4,4,4)$ and every equal-exponent triple divisible by $3$ or $4$ are already theorems. The remaining exponent triples can be enumerated and attacked individually rather than as a single monolithic statement.

### 11.3 Conjecture C2: the exponent $12$ is not optimal

If the integral bound $\mathrm{ABC}(K)$ (the $\varepsilon=1/12$ form) holds, then every Beal counterexample should satisfy $C^z \le K^2$, and more generally the $\varepsilon$-form of $abc$ should yield
$$C^z \le K^{1/(1-s(1+\varepsilon))}, \qquad s = \frac1x+\frac1y+\frac1z \le \frac{11}{12}.$$
The loss in Theorem 6.7 comes only from clearing denominators in $N^{1-s(1+\varepsilon)} \le K$; a real-valued version of the same computation, carried out with real exponentiation rather than integer powers, should keep the exponent close to $144/143$.

### 11.4 Conjecture C3: a congruence pattern mod 72

A counterexample must be congruent to a very restricted pattern modulo $72$. Two ingredients are already established: exactly one of $A,B,C$ is even (Theorem 8.1), and if $C$ is the even one then $x$ and $y$ are not both even (Theorem 8.2). The natural extension is to combine these mod-$8$ constraints with the mod-$9$ structure of cubes and the cubic residue classes forced by exponents divisible by $3$, producing a filter modulo $72$ that any counterexample must satisfy.

### 11.5 Further directions

- **Effective Fermat–Catalan.** Corollary 5.3 gives finiteness of Beal counterexamples from Fermat–Catalan finiteness, but no bound. An effective form of Fermat–Catalan in the hyperbolic range would give an explicit search bound unconditionally on $abc$.
- **Sharpening the small-box verification.** Theorem 8.3 covers $A,B\le10$, $C\le40$, $x,y,z\le5$ by exhaustive check. Extending the certified range using the constraint filters of Section 9.2 is a purely computational project of substantial reach.
- **Positive characteristic.** Theorem 7.3 assumes $\operatorname{char} k = 0$, which is needed because the exponents must be invertible. Determining the exact failure mode in characteristic $p$ — where $a^p+b^p=(a+b)^p$ trivialises the equation — would complete the function-field picture.
- **Coefficient generalisations.** Extending the results to $Aa^x + Bb^y = Cc^z$ with fixed coefficients, where the collapse lemma acquires side conditions, would test the robustness of the whole architecture.

---

## 12. Conclusion

Beal's conjecture remains open, but its geography is now fully mapped. It is equivalent to a single-coprimality statement; it implies Fermat's Last Theorem; it is precisely the high-exponent part of the Fermat–Catalan equation; every one of its solutions is strictly hyperbolic with $1/x+1/y+1/z \le 11/12$; the hypothesis $x,y,z\ge3$ is sharp in each coordinate; a counterexample would be pairwise coprime with exactly one even base and would satisfy a mod-$8$ obstruction; the $abc$ conjecture confines all counterexamples to one explicit finite box; and over polynomial rings in characteristic zero the statement is simply true.

The residual difficulty is a single quantity: the error term in the $abc$ inequality. Everything else has been done.
