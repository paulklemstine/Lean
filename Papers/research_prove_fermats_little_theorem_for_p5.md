# Fermat's Little Theorem at $p = 5$: A Unified Mechanism and a Sharp Divisibility Strengthening

## Abstract

We study the elementary but instructive fact that $a^5 - a$ is divisible by $5$ for every integer $a$. Rather than treating the modulus $5$ as a special constant to be dispatched by residue-class case analysis, we derive the result from the general integer form of **Fermat's Little Theorem**: for every prime $p$ and every integer $a$, $p \mid a^p - a$. The engine is the field identity $x^p = x$ valid on the ring of integers modulo a prime $p$, transported back to $\mathbb{Z}$ through the standard bridge between "divisibility by $p$" and "vanishing modulo $p$." Specializing to $p = 5$ recovers the headline claim as a one-line corollary. We then prove a genuine strengthening: $30 \mid a^5 - a$ for all integers $a$, obtained by combining divisibility by the pairwise-coprime primes $2$, $3$, and $5$. We record the elementary factorisation $a^5 - a = a(a-1)(a+1)(a^2+1)$ as a complementary window on the same phenomenon, and we develop two consequences: the congruence $a^5 \equiv a \pmod 5$ and the summed divisibility $5 \mid \sum_{k<n}(k^5 - k)$. We close by conjecturing the general shape of the universal divisor $M(n)$ of $a^n - a$ and relating it to Korselt's criterion and Carmichael numbers.

**Keywords:** Fermat's Little Theorem, modular arithmetic, divisibility, coprime factorisation, congruences, Carmichael numbers.

## 1. Introduction

Among the first nontrivial divisibility facts a student of number theory meets is the claim that $a^5 - a$ is always a multiple of $5$. It is easy to verify on examples:
$$2^5 - 2 = 30, \qquad 3^5 - 3 = 240, \qquad 7^5 - 7 = 16800,$$
and each of these is divisible by $5$. Two natural pedagogical routes exist. The first is a direct case analysis on the residue of $a$ modulo $5$: check $a \equiv 0, 1, 2, 3, 4 \pmod 5$ and confirm $a^5 \equiv a$ in each case. The second, which we adopt, is to recognize the statement as the instance $p = 5$ of a single general mechanism — **Fermat's Little Theorem** — and to derive it uniformly.

The advantages of the general route are twofold. First, it is conceptually economical: one proves a theorem about *all* primes and reads off $p = 5$ for free. Second, and more interestingly, the same machinery reveals that the true answer to "by what is $a^5 - a$ always divisible?" is not $5$ but $30$. This threefold sharpening — a phenomenon of the problem *giving more than was asked* — is the mathematical heart of this note.

The paper is organized as follows. Section 2 fixes notation and states the bridge principle relating integer divisibility to modular vanishing. Section 3 states and proves the general integer Fermat theorem and specializes it to $p = 5$. Section 4 proves the elementary factorisation. Section 5 establishes the $30$-divisibility strengthening. Section 6 develops the congruence and summed consequences. Section 7 discusses applications and Section 8 lays out conjectural future directions.

### 1.1 Historical remarks

Pierre de Fermat announced the theorem now bearing his name in a 1640 letter to Bernard Frénicle de Bessy, stating that $p$ divides $a^{p-1} - 1$ whenever $p$ is prime and does not divide $a$. Fermat, as was his habit, omitted the proof. The first published demonstration is due to Leonhard Euler in 1736, and Euler later generalized the statement to arbitrary moduli through the totient function, yielding what is now called the Euler–Fermat theorem. The multiplicative form $a^{p-1} \equiv 1 \pmod p$ (valid when $\gcd(a,p)=1$) and the additive form $a^p \equiv a \pmod p$ (valid for all $a$) are equivalent up to multiplication by $a$; we work throughout with the additive form because it holds without any coprimality hypothesis and therefore states a clean divisibility fact about the single polynomial $a^p - a$.

The specialization to $p = 5$ is a favourite exercise precisely because it sits at the boundary where naive case analysis (five residues) is still feasible but already tedious, and where the structural proof begins to show its advantage. Our aim is to present the structural proof as the primary object and to extract from it the two enrichments — the sharpening to $30$ and the consequence layer — that a purely computational treatment tends to miss.

## 2. Preliminaries and notation

Throughout, $a \in \mathbb{Z}$ denotes an arbitrary integer and $p$ a prime. We write $m \mid n$ for "$m$ divides $n$" and $a \equiv b \pmod m$ for "$m \mid a - b$."

For a positive integer $m$, the **ring of integers modulo $m$**, denoted $\mathbb{Z}/m\mathbb{Z}$, consists of the residue classes $\{0, 1, \dots, m-1\}$ under addition and multiplication carried out and then reduced modulo $m$. A foundational structural fact is:

**Fact 2.1 (Prime moduli give fields).** *If $p$ is prime, then $\mathbb{Z}/p\mathbb{Z}$ is a field: every nonzero residue class has a multiplicative inverse.*

We rely on the following elementary but crucial translation device.

**Lemma 2.2 (Bridge principle).** *For every integer $m$ and every prime $p$, we have $p \mid m$ if and only if the residue class of $m$ in $\mathbb{Z}/p\mathbb{Z}$ is zero.*

*Proof.* By definition the residue class of $m$ is the remainder of $m$ upon division by $p$, and this remainder is $0$ exactly when $p \mid m$. $\qquad\blacksquare$

Lemma 2.2 is the load-bearing device of the whole development: it lets us prove a divisibility statement in $\mathbb{Z}$ by instead proving that an expression vanishes in $\mathbb{Z}/p\mathbb{Z}$, where the field structure of Fact 2.1 is available.

## 3. The general mechanism and the case $p = 5$

The abstract core is the following identity, valid in any finite field of prime order.

**Theorem 3.1 (Power identity on a prime clock).** *Let $p$ be prime. Then in $\mathbb{Z}/p\mathbb{Z}$ we have $x^p = x$ for every element $x$.*

*Proof sketch.* If $x = 0$ the identity is trivial. If $x \neq 0$, then $x$ lies in the multiplicative group $(\mathbb{Z}/p\mathbb{Z})^\times$, which has order $p - 1$. By Lagrange's theorem the order of $x$ divides $p - 1$, so $x^{p-1} = 1$. Multiplying by $x$ gives $x^p = x$. (Equivalently, one may argue by the binomial theorem and the fact that the binomial coefficients $\binom{p}{k}$ for $0 < k < p$ are divisible by $p$, giving the "freshman's dream" $ (x+1)^p = x^p + 1$ and an induction on $x$.) $\qquad\blacksquare$

Combining Theorem 3.1 with the bridge principle yields the integer form of Fermat's Little Theorem.

**Theorem 3.2 (Integer form of Fermat's Little Theorem).** *For every prime $p$ and every integer $a$,*
$$p \mid a^p - a.$$

*Proof.* Reduce modulo $p$. In $\mathbb{Z}/p\mathbb{Z}$, the residue class of $a^p - a$ equals $x^p - x$ where $x$ is the class of $a$. By Theorem 3.1, $x^p = x$, so $x^p - x = 0$; that is, the class of $a^p - a$ is zero. By Lemma 2.2, $p \mid a^p - a$. $\qquad\blacksquare$

The requested result is now immediate.

**Corollary 3.3 (Fermat's Little Theorem for $p = 5$).** *For every integer $a$,*
$$5 \mid a^5 - a.$$

*Proof.* Apply Theorem 3.2 with the prime $p = 5$. $\qquad\blacksquare$

This is the sense in which Corollary 3.3 is *supported by*, rather than *identical to*, the general engine: the specialization is a genuine one-line consequence of a theorem quantifying over all primes and all integers, not a repackaging of a residue computation.

For completeness we record the direct verification that the identity $x^5 = x$ holds on the five-element clock, since it makes the abstract Theorem 3.1 concrete at $p = 5$. Working modulo $5$: $0^5 = 0$; $1^5 = 1$; $2^5 = 32 = 6\cdot 5 + 2 \equiv 2$; $3^5 = 243 = 48\cdot 5 + 3 \equiv 3$; and $4^5 = 1024 = 204\cdot 5 + 4 \equiv 4$. Every residue is a fixed point of the fifth-power map, which is exactly the assertion $5 \mid a^5 - a$ read across the five residue classes. The structural proof of Corollary 3.3 packages this five-line check into the single invocation of Lagrange's theorem inside Theorem 3.1, and thereby avoids repeating it for every new prime.

## 4. An elementary factorisation

A second, self-contained window on the $p = 5$ case is provided by an explicit factorisation over $\mathbb{Z}$.

**Theorem 4.1 (Factorisation of $a^5 - a$).** *For every integer $a$,*
$$a^5 - a = a\,(a-1)\,(a+1)\,(a^2 + 1).$$

*Proof.* Expand the right-hand side. First $a(a-1)(a+1) = a(a^2 - 1) = a^3 - a$. Then
$$(a^3 - a)(a^2 + 1) = a^5 + a^3 - a^3 - a = a^5 - a,$$
as claimed. $\qquad\blacksquare$

This factorisation exhibits $a^5 - a$ as $a$ times its two neighbours $a - 1$ and $a + 1$ (three consecutive integers) times the quadratic $a^2 + 1$. Among any three consecutive integers, one is divisible by $3$ and at least one is even, so $6 \mid a(a-1)(a+1)$ with no further work; this makes the divisibility of $a^5 - a$ by $2$ and $3$ nearly transparent. Divisibility by $5$ requires a residue check on the four factors, and is subsumed by Corollary 3.3.

The factor $a^2 + 1$ deserves comment, because it is what raises the divisibility from $5$ to $30$ rather than to a larger number. Modulo $5$, the linear factors $a$, $a-1$, $a+1$ cover the residues $0, 1, 4$; the residues $2$ and $3$ are exactly the ones for which $a^2 + 1 \equiv 0 \pmod 5$, since $2^2 + 1 = 5$ and $3^2 + 1 = 10$. Thus for every residue of $a$ modulo $5$, one of the four factors vanishes, which is a hands-on proof of Corollary 3.3 through the factorisation alone. This dovetailing — the quadratic factor precisely catching the residues the linear factors miss — is the shadow, at $n = 5$, of the general cyclotomic decomposition discussed in Section 8.4.

## 5. The sharp strengthening: divisibility by $30$

We now show that the true universal divisor of $a^5 - a$ is $30$, not merely $5$.

**Lemma 5.1 (Small-prime divisibility).** *For every integer $a$, each of $2$, $3$, and $5$ divides $a^5 - a$.*

*Proof.* For $p = 5$, this is Corollary 3.3. For $p = 2$ and $p = 3$, observe from Theorem 4.1 that $a(a-1)(a+1)$ divides $a^5 - a$; among three consecutive integers one is even and one is a multiple of $3$, so $2$ and $3$ both divide the product and hence $a^5 - a$. (Alternatively, both are instances of Theorem 3.2 combined with $a^5 = a^2 \cdot a^3$ and the identities $a^2 \equiv a$, $a^3 \equiv a$ modulo $2$ and $3$ respectively.) $\qquad\blacksquare$

**Lemma 5.2 (Coprime divisors multiply).** *If $d_1, d_2, \dots, d_k$ are pairwise coprime positive integers each dividing an integer $N$, then their product $d_1 d_2 \cdots d_k$ divides $N$.*

*Proof.* Induct on $k$. The case $k = 1$ is trivial. For the inductive step, suppose $D = d_1 \cdots d_{k-1} \mid N$ and $d_k \mid N$ with $\gcd(D, d_k) = 1$ (which holds because $d_k$ is coprime to each factor of $D$). Write $N = D q$. Since $d_k \mid Dq$ and $\gcd(d_k, D) = 1$, Euclid's lemma gives $d_k \mid q$, whence $D d_k \mid Dq = N$. $\qquad\blacksquare$

**Theorem 5.3 (Sharp divisibility).** *For every integer $a$,*
$$30 \mid a^5 - a.$$

*Proof.* By Lemma 5.1 the pairwise-coprime numbers $2$, $3$, $5$ each divide $a^5 - a$. By Lemma 5.2 their product $2 \cdot 3 \cdot 5 = 30$ divides $a^5 - a$. $\qquad\blacksquare$

That $30$ is *optimal* — i.e. the largest such universal divisor — is witnessed at $a = 2$: $2^5 - 2 = 30$, so no integer larger than $30$ can divide $a^5 - a$ for all $a$. Thus
$$\gcd_{a \in \mathbb{Z}}(a^5 - a) = 30.$$

## 6. Consequences

The pointwise divisibility of Corollary 3.3 upgrades cleanly, with no further residue analysis, into two further statements.

**Theorem 6.1 (Congruence form).** *For every integer $a$,*
$$a^5 \equiv a \pmod 5, \qquad \text{equivalently} \qquad a^5 \bmod 5 = a \bmod 5.$$

*Proof.* By Corollary 3.3, $5 \mid a^5 - a$, which is precisely the definition of $a^5 \equiv a \pmod 5$. Equality of remainders follows since two integers are congruent modulo $5$ iff they have equal remainders upon division by $5$. $\qquad\blacksquare$

This congruence is the computationally useful phrasing: to evaluate any fifth power modulo $5$ one simply reads off the base, never forming the power.

**Theorem 6.2 (Summed form).** *For every natural number $n$,*
$$5 \;\Big|\; \sum_{k=0}^{n-1} \bigl(k^5 - k\bigr).$$

*Proof.* By Corollary 3.3, each summand $k^5 - k$ is divisible by $5$. A finite sum of multiples of $5$ is again a multiple of $5$ (divisibility is closed under addition), so the total is divisible by $5$. $\qquad\blacksquare$

Both consequences consume Corollary 3.3 nontrivially — the first as a congruence rewrite, the second through closure of divisibility under summation — and neither is a definitional restatement.

### 6.1 Worked numerical illustration

It is worth seeing the theorems act on concrete numbers. Take $a = 7$. Then $a^5 - a = 16807 - 7 = 16800$. We have $16800 = 5 \cdot 3360$ (Corollary 3.3) and $16800 = 30 \cdot 560$ (Theorem 5.3). The factorisation gives $7 \cdot 6 \cdot 8 \cdot 50 = 16800$, and among $6, 7, 8$ we see the even numbers $6, 8$ and the multiple of $3$, namely $6$; the factor $50 = 7^2 + 1$ carries the divisibility by $5$ and even an extra factor of $2$. For the congruence, $7^5 = 16807 \equiv 2 \pmod 5$ and $7 \equiv 2 \pmod 5$, in agreement with Theorem 6.1. For the summed form with $n = 4$, we compute $(0 + 0 + 30 + 240) = 270 = 5 \cdot 54$, illustrating Theorem 6.2.

The optimality claim is visible too: the greatest common divisor of $2^5 - 2 = 30$, $3^5 - 3 = 240$, and $4^5 - 4 = 1020$ is already $30$, since $\gcd(30, 240) = 30$ and $\gcd(30, 1020) = 30$. No larger integer can be a universal divisor, because the smallest nonzero value $30$ caps it.

## 7. Applications

**Fast modular exponentiation.** Theorem 6.1 lets one collapse fifth powers modulo $5$ instantly. More generally, Theorem 3.2 underlies the reduction $a^p \equiv a \pmod p$ that powers efficient modular arithmetic and, through its extension $a^{p-1} \equiv 1 \pmod p$ for $\gcd(a,p) = 1$, the computation of modular inverses.

**Primality testing.** Fermat's Little Theorem is the basis of the **Fermat primality test**: if $a^{n} \not\equiv a \pmod n$ for some $a$, then $n$ is composite. Theorem 5.3 and its generalizations describe precisely the composite moduli that fool this test — the pseudoprimes and Carmichael numbers discussed below.

**Digit and checksum schemes.** Congruences of the form $a^k \equiv a$ underlie error-detecting checksum constructions in which raising to a power must not disturb a residue.

**Simplifying large power residues.** Theorem 6.1 turns an otherwise expensive computation into a triviality: to find $123456789^5 \bmod 5$ one need not form the enormous power; since $123456789 \equiv 4 \pmod 5$, the answer is simply $4$. The same principle, iterated through Theorem 3.2, is the backbone of the repeated-squaring reductions that make public-key cryptography computationally feasible.

## 8. Discussion and future directions

The $p = 5$ case is a faithful miniature of a much broader landscape. We record several conjectural directions, each anchored by the concrete results above.

**8.1 The universal divisor is a squarefree product of primes.** For each exponent $n \geq 2$, let $M(n)$ be the largest integer dividing $a^n - a$ for every integer $a$. We conjecture that
$$M(n) = \prod_{\substack{p \text{ prime} \\ (p-1)\,\mid\,(n-1)}} p.$$
Divisibility of $a^n - a$ by a prime $p$ for *all* $a$ is equivalent, via Fermat's Little Theorem, to the arithmetic condition $(p-1) \mid (n-1)$; the modulus therefore decouples into independent single-prime tests, and $M(n)$ is always squarefree because the multiplicative group modulo $p^2$ is too large to force $x^n = x$ universally. For $n = 5$ the condition $(p-1) \mid 4$ selects $p \in \{2, 3, 5\}$, giving $M(5) = 30$, in agreement with Theorem 5.3.

**8.2 Sharpness at the smallest nontrivial input.** We conjecture that for every $n \geq 2$ the extremal witness realizing $M(n)$ can be taken as $a = 2$; that is, the coprime single-prime obstructions are simultaneously active at the smallest composite input, and the extremal witness never needs to grow with $n$. For $n = 5$, indeed $2^5 - 2 = 30 = M(5)$.

**8.3 A Carmichael-type converse for full exponents.** A composite modulus $m$ satisfies $a^n \equiv a \pmod m$ for all $a$ if and only if $m$ is squarefree and every prime factor $p$ of $m$ satisfies $(p-1) \mid (n-1)$. Korselt's criterion for Carmichael numbers is the special case $n - 1 = m - 1$; relaxing the exponent turns the rigid Carmichael condition into a flexible family parameterized by $n$. The result $30 \mid a^5 - a$ is exactly the $n = 5$ instance of this criterion.

**8.4 Factorisation depth and elementary proof length.** The factorisation $a^5 - a = a(a-1)(a+1)(a^2+1)$ is not accidental: $a^n - a$ factors over $\mathbb{Z}$ as $a$ times a product of cyclotomic polynomials evaluated at $a$, and the number of distinct linear/quadratic factors vanishing modulo each relevant prime governs the length of an elementary residue-based proof. We conjecture this count is $p$ for each contributing prime $p$.

## 9. Conclusion

Starting from the request to show $5 \mid a^5 - a$, we derived it as a one-line corollary of the general integer form of Fermat's Little Theorem, itself a transport of the field identity $x^p = x$ across the divisibility–vanishing bridge. The same toolkit sharpened the answer to the optimal $30 \mid a^5 - a$, and yielded a congruence and a summed-divisibility consequence at no extra cost. The elementary factorisation $a^5 - a = a(a-1)(a+1)(a^2+1)$ offered an independent confirmation. Finally, the case $p = 5$ pointed directly at a conjectural theory of universal divisors $M(n)$ and its connection to Carmichael numbers — a reminder that a well-posed elementary question, answered honestly, tends to deliver more than it promised.
