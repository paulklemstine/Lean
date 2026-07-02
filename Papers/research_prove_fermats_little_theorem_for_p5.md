# Divisibility of $a^5 - a$: An Elementary Proof, Its Sharpenings, and Its Place in Fermat's Little Theorem

## Abstract

We give a fully elementary, self-contained treatment of the classical fact that $a^5 - a$ is divisible by $5$ for every integer $a$, together with several genuine strengthenings and a placement of the result inside the general theory. Our primary proof avoids any appeal to finite-field theory or exhaustive residue checking: it rests on a single polynomial identity, $(n+1)^5 - (n+1) = (n^5 - n) + 5(n^4 + 2n^3 + 2n^2 + n)$, propagated across the integers by induction. We then record a complementary factorization $a^5 - a = (a-1)a(a+1)(a^2+1)$, which exposes divisibility by $2$ and $3$; combining these with divisibility by $5$ through coprimality yields the sharper statement $30 \mid a^5 - a$. A further consequence, $a^5 \equiv a \pmod{10}$, establishes that the last decimal digit of any integer is fixed by the fifth-power map. Finally we prove the general Fermat's Little Theorem, $p \mid a^p - a$ for every prime $p$, and recover the $p = 5$ case as a corollary, exhibiting the target as one instance of a universal law. We discuss algorithms for computing the "universal denominator" $D(n)$ of $a^n - a$, present numerical demonstrations, and outline directions for further research.

## 1. Introduction

Among the first surprises a student of number theory encounters is that certain polynomial expressions in an integer variable are *always* divisible by a fixed number, regardless of the input. The prototype is

$$5 \mid a^5 - a \qquad \text{for all } a \in \mathbb{Z}.$$

This paper studies this statement from several complementary vantage points, with three goals: to give a proof that is genuinely elementary (using only integer induction and a polynomial identity), to sharpen the modulus from $5$ to its true maximal value $30$, and to situate the result within the general framework of Fermat's Little Theorem. Along the way we obtain a concrete corollary about decimal last digits and describe the computational structure underlying the family of results $\{\,p \mid a^p - a\,\}$.

Throughout, $\mathbb{Z}$ denotes the ring of integers, and for integers $m, x$ we write $m \mid x$ to mean $m$ divides $x$. For $m \in \mathbb{Z}_{>0}$ we write $x \equiv y \pmod{m}$ to mean $m \mid (x - y)$.

## 2. Definitions and preliminaries

**Definition 2.1 (Defect function).** For an integer $a$, define the *fifth-power defect* by $\Delta(a) := a^5 - a$. More generally, for a positive integer $n$, write $\Delta_n(a) := a^n - a$.

**Definition 2.2 (Universal denominator).** For a positive integer $n$, define
$$D(n) := \gcd\{\, a^n - a : a \in \mathbb{Z} \,\},$$
the largest positive integer dividing $a^n - a$ for every integer $a$.

**Lemma 2.3 (Coprime gluing).** If $m_1, m_2$ are coprime integers and both $m_1 \mid x$ and $m_2 \mid x$, then $m_1 m_2 \mid x$.

*Proof sketch.* Coprimality provides integers $u, v$ with $u m_1 + v m_2 = 1$ (Bézout). Writing $x = x \cdot 1 = x(u m_1 + v m_2) = u m_1 x + v m_2 x$ and substituting $x = m_2 y_2 = m_1 y_1$ from the two divisibilities shows $m_1 m_2$ divides each term, hence divides $x$. This is the ring-theoretic content of the Chinese Remainder Theorem in the special case of a single congruence class. $\square$

## 3. The primary result: an inductive proof

The centerpiece of our elementary approach is the following algebraic identity, which measures exactly how the defect changes when the argument increases by one.

**Lemma 3.1 (Step identity).** For every integer $n$,
$$(n+1)^5 - (n+1) = (n^5 - n) + 5\,(n^4 + 2n^3 + 2n^2 + n).$$

*Proof.* Expand $(n+1)^5 = n^5 + 5n^4 + 10n^3 + 10n^2 + 5n + 1$ by the binomial theorem. Then
$$(n+1)^5 - (n+1) = n^5 + 5n^4 + 10n^3 + 10n^2 + 5n + 1 - n - 1 = (n^5 - n) + (5n^4 + 10n^3 + 10n^2 + 5n),$$
and the parenthesized tail equals $5(n^4 + 2n^3 + 2n^2 + n)$. This is a polynomial identity, verified by direct expansion. $\square$

**Theorem 3.2 (Divisibility by five).** For every integer $a$, $\;5 \mid a^5 - a$.

*Proof.* We use integer induction, treating nonnegative and negative arguments separately from a common base.

*Base case.* For $a = 0$ we have $0^5 - 0 = 0 = 5 \cdot 0$.

*Forward step.* Suppose $5 \mid n^5 - n$ for some integer $n \ge 0$; write $n^5 - n = 5k$. By Lemma 3.1,
$$(n+1)^5 - (n+1) = 5k + 5(n^4 + 2n^3 + 2n^2 + n) = 5\big(k + n^4 + 2n^3 + 2n^2 + n\big),$$
which is a multiple of $5$. Hence the property propagates to $n+1$.

*Backward step.* Applying Lemma 3.1 with $n$ replaced by $n-1$ gives $n^5 - n = \big((n-1)^5 - (n-1)\big) + 5\,g(n-1)$ for the integer polynomial $g(m) = m^4 + 2m^3 + 2m^2 + m$. Thus $(n-1)^5 - (n-1) = (n^5 - n) - 5\,g(n-1)$, so divisibility by $5$ descends from $n$ to $n-1$. This carries the property to all negative integers.

By induction in both directions from the base case, $5 \mid a^5 - a$ for every $a \in \mathbb{Z}$. $\square$

The proof is genuinely inductive: it never enumerates the residue classes modulo $5$. Its load-bearing content is precisely the identity of Lemma 3.1, which expresses that the defect is *periodic with period one up to multiples of five* — the additive-preservation phenomenon.

## 4. A structural factorization

**Theorem 4.1 (Factorization).** For every integer $a$,
$$a^5 - a = (a-1)\,a\,(a+1)\,(a^2 + 1).$$

*Proof.* Factor $a^5 - a = a(a^4 - 1) = a(a^2 - 1)(a^2 + 1) = a(a-1)(a+1)(a^2+1)$, using the difference-of-squares factorization $a^4 - 1 = (a^2-1)(a^2+1)$ and $a^2 - 1 = (a-1)(a+1)$. $\square$

**Corollary 4.2.** For every integer $a$, both $2 \mid a^5 - a$ and $3 \mid a^5 - a$.

*Proof.* The factorization exhibits the three consecutive integers $a-1, a, a+1$ as factors of $a^5 - a$. Among any two consecutive integers one is even, so $2 \mid a^5 - a$. Among any three consecutive integers one is a multiple of $3$, so $3 \mid a^5 - a$. $\square$

An alternative, uniform route to Corollary 4.2 is to observe that for each modulus $m \in \{2, 3\}$ the map $x \mapsto x^5$ fixes every residue class modulo $m$; equivalently $x^5 - x \equiv 0 \pmod m$ for all residues $x$, a finite check over the $m$ classes. Either way, the conclusion feeds into the next section.

## 5. Sharpening the modulus to thirty

**Theorem 5.1 (Divisibility by thirty).** For every integer $a$, $\;30 \mid a^5 - a$.

*Proof.* By Theorem 3.2 and Corollary 4.2 we have $2 \mid \Delta(a)$, $3 \mid \Delta(a)$, and $5 \mid \Delta(a)$. Since $2$ and $3$ are coprime, Lemma 2.3 gives $6 \mid \Delta(a)$. Since $6$ and $5$ are coprime, Lemma 2.3 again gives $30 \mid \Delta(a)$. $\square$

**Theorem 5.2 (Maximality).** The universal denominator satisfies $D(5) = 30$; that is, $30$ is the *largest* integer dividing $a^5 - a$ for all integers $a$.

*Proof sketch.* Theorem 5.1 shows $30 \mid D(5)$. For the reverse, evaluate at $a = 2$: $\Delta(2) = 30$. Any universal divisor must divide $\Delta(2) = 30$, so $D(5) \mid 30$. Combining, $D(5) = 30$. $\square$

This maximality is reflected numerically. The table of defects for $a = 0, 1, \ldots, 8$ reads
$$0,\; 0,\; 30,\; 240,\; 1020,\; 3120,\; 7770,\; 16800,\; 32760,$$
and the greatest common divisor of the nonzero entries is exactly $30$.

## 6. A consequence for last digits

**Theorem 6.1 (Last-digit stability).** For every integer $a$, $\;a^5 \equiv a \pmod{10}$; equivalently, $a^5$ ends in the same decimal digit as $a$.

*Proof.* By Theorem 3.2 and Corollary 4.2 we have $5 \mid \Delta(a)$ and $2 \mid \Delta(a)$. As $2$ and $5$ are coprime, Lemma 2.3 gives $10 \mid \Delta(a) = a^5 - a$, which is the claim. $\square$

**Corollary 6.2 (Digit fixed points).** Iterating the fifth-power map never changes the last decimal digit: for every $a$ and every $k \ge 0$, $\;a^{5^k} \equiv a \pmod{10}$.

*Proof sketch.* Induction on $k$. The case $k = 0$ is trivial. If $a^{5^k} \equiv a \pmod{10}$, then raising both sides to the fifth power and applying Theorem 6.1 to the integer $a^{5^k}$ gives $a^{5^{k+1}} = (a^{5^k})^5 \equiv a^{5^k} \equiv a \pmod{10}$. Thus the last digit is a fixed point of the fifth-power operation on the ten residue classes modulo $10$. $\square$

## 7. Placement within Fermat's Little Theorem

The exponent $5$ is distinguished not by its size but by being *prime*. The general phenomenon is the following.

**Theorem 7.1 (Fermat's Little Theorem, additive form).** For every prime $p$ and every integer $a$,
$$p \mid a^p - a.$$

*Proof sketch.* Work in the ring of residues modulo $p$, which is a field because $p$ is prime. In this field the identity $x^p = x$ holds for every element $x$: the $p-1$ nonzero elements form a cyclic multiplicative group of order $p-1$, so $x^{p-1} = 1$ for each nonzero $x$ (whence $x^p = x$), and the identity is trivial for $x = 0$. Consequently $a^p - a$ reduces to $0$ modulo $p$, i.e. $p \mid a^p - a$. $\square$

**Corollary 7.2 (Target as an instance).** Taking $p = 5$ in Theorem 7.1 recovers Theorem 3.2: $\;5 \mid a^5 - a$.

Theorem 7.1 is the "right home" for the entire family of results. The elementary inductive proof of Theorem 3.2 and the field-theoretic proof of Theorem 7.1 are two faces of a single fact — the periodicity of $x \mapsto x^p - x$ modulo $p$ — and each has its own virtues: the former yields an explicit witness polynomial $g$ with $\Delta_p(a+1) - \Delta_p(a) = p\,g(a)$, while the latter reveals the structural reason (the multiplicative group of a finite field) and instantly generalizes across all primes.

## 8. The universal denominator $D(n)$

The maximality result $D(5) = 30$ invites a general question: for arbitrary exponent $n$, what is $D(n)$?

**Proposition 8.1 (Structure of $D(n)$).** For each $n \ge 1$, $D(n)$ is squarefree, and a prime $p$ divides $D(n)$ if and only if $p - 1$ divides $n - 1$.

*Proof sketch.* A prime $p$ divides $a^n - a$ for all $a$ iff $x^n = x$ for all $x$ in the field of residues modulo $p$. For $x = 0$ this is automatic; for the cyclic multiplicative group of order $p-1$, the condition $x^{n-1} = 1$ for all nonzero $x$ holds iff the group exponent $p - 1$ divides $n - 1$. Higher powers $p^2$ never divide $D(n)$ because, choosing $a = p$, the term $a^n - a = p^n - p$ is divisible by $p$ but not $p^2$ once $n \ge 2$; hence $D(n)$ is squarefree. Thus $D(n) = \prod_{\,p : (p-1) \mid (n-1)} p$. $\square$

For example, $D(3) = 2 \cdot 3 = 6$ (primes with $p - 1 \mid 2$: namely $2, 3$), $D(5) = 2 \cdot 3 \cdot 5 = 30$ (primes with $p-1 \mid 4$: namely $2, 3, 5$), and $D(7) = 2 \cdot 3 \cdot 7 = 42$ (primes with $p - 1 \mid 6$: namely $2, 3, 7$). The absence of $5$ from $D(7)$ — because $5 - 1 = 4$ does not divide $6$ — is a small but instructive surprise.

## 9. Algorithms

We summarize the computational content in two procedures.

**Algorithm A (Universal denominator by residue enumeration).** To compute $D(n)$: for each prime $p$ up to a bound, test whether $x^n \equiv x \pmod p$ for all residues $x \in \{0, 1, \ldots, p-1\}$; equivalently, by Proposition 8.1, test whether $(p-1) \mid (n-1)$. Multiply together all primes passing the test. The correctness follows from Proposition 8.1; using the divisibility criterion, the cost is one modular test per prime.

**Algorithm B (Coprime gluing certificate).** Given that $m_1, \ldots, m_r$ are pairwise coprime and each divides $f(a)$ for all $a$, certify $m_1 \cdots m_r \mid f(a)$ by folding Lemma 2.3 across the factors: maintain a running product $M$, and at each step combine the accumulated divisibility by $M$ with divisibility by the next coprime factor $m_i$ to obtain divisibility by $M \cdot m_i$. This is exactly the mechanism used to pass from $\{2, 3, 5\}$ to $30$.

## 10. Numerical demonstrations

The claims of this paper are directly checkable. The defects $a^5 - a$ for small $a$ are all multiples of $30$; the fifth power of any integer reproduces its last decimal digit; and iterating the fifth-power map modulo $10$ leaves every residue fixed. For the general theorem, exhaustive verification over the residues of any prime $p$ confirms $x^p \equiv x \pmod p$. Concrete implementations of all of these appear in the accompanying computational material.

## 11. Applications and discussion

The additive form of Fermat's Little Theorem underpins primality testing (the Fermat test and its refinements) and public-key cryptography, where exponentiation modulo a prime or a product of primes is the fundamental operation. The last-digit stability result, though modest, is a clean example of how divisibility by coprime moduli combines: $2 \mid \Delta$ and $5 \mid \Delta$ jointly give $10 \mid \Delta$. The universal-denominator viewpoint reframes many scattered "always divisible" curiosities as a single classification governed by the arithmetic condition $(p-1) \mid (n-1)$.

## 12. Future directions

Several natural questions extend this work. First, one may seek a full classification of the universal denominator $D(n)$ for all $n$, building on Proposition 8.1 and the coprime-gluing mechanism that fixed $D(5) = 30$. Second, the last-digit stability of iterated fifth powers suggests studying the eventual periodicity of last digits under general power maps. Third, the equivalence between residue-check proofs and inductive proofs — each inductive proof supplying an explicit witness polynomial $g$ with $f(a+1) - f(a) = m\,g(a)$ — deserves a general treatment as a bridge principle. These directions are elaborated in the accompanying future-directions material.

## 13. Conclusion

Starting from the humble observation that $a^5 - a$ is a multiple of $5$, we have given an elementary inductive proof, a structural factorization, a sharpening to divisibility by $30$ with a matching maximality statement, a corollary on decimal last digits, and a placement of the whole story inside Fermat's Little Theorem. The result that looked like an isolated curiosity turns out to be one visible instance of a universal law governed entirely by the primes $p$ for which $p - 1$ divides $n - 1$.
