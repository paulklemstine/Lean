# Sums of Two Anti-Fibonacci Numbers: A Two-Squares Reduction, an Exact Local Sieve, and Density Zero at the Landau Scale

**Aristotle**

*2026-10-24*

---

## Abstract

The anti-Fibonacci numbers are $A_n = \tfrac{n(n+1)}{2} + 1$ $(n \ge 0)$, that is, $1, 2, 4, 7, 11, 16, \dots$, defined by $A_0 = 1$ and $A_n = A_{n-1} + n$. We study the set $\mathcal R$ of integers of the form $A_a + A_b$ and its counting function $R(N)$. We prove that $m \in \mathcal R$ if and only if $8m - 14$ is a sum of two integer squares, equivalently if and only if $m \ge 2$ and $4m - 7$ is a sum of two squares. This gives a Fermat-type criterion in terms of the prime factorisation of $4m - 7$. From it we derive the following. (i) A fixed local obstruction at $3$: no $m \equiv 1, 7 \pmod 9$ lies in $\mathcal R$, so at least $2k$ of the integers in $[0, 9k)$ are non-representable. (ii) An exact Chinese-remainder count: for a finite set $S$ of primes $p \equiv 3 \pmod 4$, exactly $\prod_{p \in S}(p^2 - p + 1)$ residues modulo $\prod_{p\in S} p^2$ satisfy all local conditions. (iii) The explicit sieve bound $\#\{m < N : m \in \mathcal R\} \le (N/Q + 1)\prod_{p \in S}(p^2-p+1)$. (iv) The Euler-product inequality $\prod_{p \in S}(1 - (p-1)/p^2) \le (1 + \tfrac12\sum_{p\in S} 1/p)^{-1}$. We also prove that $\sum_{p \equiv a \ (q)} 1/p = \infty$ for every unit $a$ modulo $q$, by a tail argument from the standard lower bound for the Dirichlet series of the von Mangoldt function restricted to a residue class. Together these give our main theorem: **$\mathcal R$ has natural density zero.** Hence the conjectured positive density is false in the naive sense. We then show that the reduction transfers Landau's theorem verbatim, giving $R(N) \sim 2b\,N/\sqrt{\log N}$ with $b$ the Landau–Ramanujan constant. We give numerical evidence, explain why the elementary sieve cannot reach the $1/\sqrt{\log N}$ scale on its own, and list open problems.

---

## 1. Introduction

Additive questions about thin sequences, such as which integers are sums of two squares, of two cubes, or of two triangular numbers, are among the oldest in number theory. In this paper we consider a quadratic sequence whose pairwise sums turn out to be governed by Fermat's two-squares theorem.

**Definition 1.1 (Anti-Fibonacci numbers).** For $n \ge 0$ let
$$A_n = \frac{n(n+1)}{2} + 1.$$
Equivalently, $A_0 = 1$ and $A_n = A_{n-1} + n$ for $n \ge 1$. The sequence begins $1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, 67, \dots$. Where the Fibonacci recurrence adds the previous term, this one adds the index, so the sequence grows quadratically instead of exponentially.

**Definition 1.2 (Representable integers).** An integer $m \ge 0$ is *representable* if there exist $a, b \ge 0$ with $m = A_a + A_b$. Write $\mathcal R$ for the set of representable integers. For $N \ge 1$ put
$$R(N) = \#\{m \le N : m \in \mathcal R\}, \qquad R^{<}(N) = \#\{0 \le m < N : m \in \mathcal R\}.$$
These differ by at most $1$.

The representable integers up to $40$ are
$$2,3,4,5,6,8,9,11,12,13,14,15,17,18,20,22,23,24,26,27,29,30,31,32,33,36,38,39,40.$$
At $N = 10^6$ about $40\%$ of all integers are representable, and this suggests positive density. We show that this impression is wrong, and we identify the correct order of magnitude.

### 1.1 Summary of results

1. **Reduction (Theorem 2.2).** $m \in \mathcal R \iff 8m-14 = x^2+y^2$ for some $x,y \in \mathbb Z$ $\iff$ $m \ge 2$ and $4m-7 = x^2+y^2$ for some $x,y \in \mathbb Z_{\ge 0}$.
2. **Fermat-type criterion (Theorem 2.5).** $m \in \mathcal R \iff m \ge 2$ and $v_q(4m-7)$ is even for every prime $q \equiv 3 \pmod 4$.
3. **Local obstruction and the $2/9$ bound (Theorems 3.1, 3.2).**
4. **Exact CRT sieve count (Theorem 4.4) and sieve upper bound (Theorem 4.5).**
5. **Euler-product inequality (Theorem 5.1).**
6. **Divergence of prime reciprocals in progressions (Theorem 6.1).**
7. **Density zero (Theorem 7.1):** $R(N)/N \to 0$.
8. **Landau-scale asymptotic (Theorem 8.2):** assuming Landau's classical theorem, $R(N) \sim 2b\,N/\sqrt{\log N}$, where $2b \approx 1.52845$.

Items 1–7 are proved in full from first principles, given Fermat's two-squares theorem and the standard lower bound for the Dirichlet series of the von Mangoldt function on a residue class (the analytic input to Dirichlet's theorem). Item 8 is a short and complete deduction from Landau's 1908 theorem.

---

## 2. The two-squares reduction

**Lemma 2.1 (Basic identity).** For every $n \ge 0$,
$$8A_n = (2n+1)^2 + 7.$$

*Proof.* $8A_n = 4n(n+1) + 8 = (4n^2 + 4n + 1) + 7$. $\square$

**Theorem 2.2 (Reduction to sums of two squares).** For every integer $m \ge 0$ the following are equivalent:

1. $m \in \mathcal R$;
2. there are $x, y \in \mathbb Z$ with $8m - 14 = x^2 + y^2$;
3. $m \ge 2$ and there are $x, y \in \mathbb Z_{\ge 0}$ with $8m - 14 = x^2 + y^2$;
4. $m \ge 2$ and there are $x, y \in \mathbb Z_{\ge 0}$ with $4m - 7 = x^2 + y^2$.

Moreover, if $m = A_a + A_b$, then explicitly
$$8m - 14 = (2a+1)^2 + (2b+1)^2, \qquad 4m - 7 = (a+b+1)^2 + (a-b)^2.$$

*Proof.* (1 ⇒ 2.) If $m = A_a + A_b$, adding the two instances of Lemma 2.1 gives $8m - 14 = (2a+1)^2 + (2b+1)^2$.

(2 ⇒ 1.) Suppose $8m - 14 = x^2 + y^2$. Replacing $x, y$ by $|x|, |y|$ we may assume $x, y \ge 0$. Then $x^2 + y^2 \equiv 2 \pmod 8$. An even square is $\equiv 0$ or $4 \pmod 8$ and an odd square is $\equiv 1 \pmod 8$. The possible values of $x^2 + y^2 \bmod 8$ are therefore $0, 4$ (both even), $1, 5$ (mixed parity) and $2$ (both odd). Hence $x = 2a+1$ and $y = 2b+1$ with $a, b \ge 0$. By Lemma 2.1, $8m = (2a+1)^2 + 7 + (2b+1)^2 + 7 = 8A_a + 8A_b$, so $m = A_a + A_b$.

(2 ⇔ 3.) If $8m - 14 = x^2 + y^2 \ge 0$ then $m \ge 2$, since $m \le 1$ would make $8m - 14 < 0$. Absolute values handle the sign.

(3 ⇔ 4.) This is the next lemma applied to $n = 4m - 7$, since $2(4m-7) = 8m - 14$.

The explicit formula for $4m-7$ follows from $(u+v)^2 + (u-v)^2 = 2(u^2 + v^2)$ with $u = a+b+1$ and $v = a-b$, because then $u + v = 2a+1$ and $u - v = 2b+1$. $\square$

**Lemma 2.3 (Doubling).** For $n \in \mathbb Z_{\ge 0}$, the number $2n$ is a sum of two squares of non-negative integers if and only if $n$ is.

*Proof.* If $n = u^2 + v^2$ with $u \ge v$, then $2n = (u+v)^2 + (u-v)^2$. Conversely, if $2n = x^2 + y^2$ then $x \equiv y \pmod 2$. Assuming $x \ge y$, the numbers $u = (x+y)/2$ and $v = (x-y)/2$ are non-negative integers with $u^2 + v^2 = (x^2+y^2)/2 = n$. $\square$

We use the classical characterisation of sums of two squares.

**Theorem 2.4 (Fermat–Euler).** A positive integer $n$ is a sum of two squares if and only if $v_q(n)$ is even for every prime $q \equiv 3 \pmod 4$.

Combining Theorems 2.2 and 2.4 (note $4m - 7 \ge 1$ when $m \ge 2$):

**Theorem 2.5 (Fermat-type criterion).** An integer $m \ge 0$ is representable if and only if $m \ge 2$ and, for every prime $q \equiv 3 \pmod 4$, the exponent $v_q(4m-7)$ is even.

*Example.* $4\cdot 37 - 7 = 141 = 3 \cdot 47$, so $v_3 = 1$ and $37 \notin \mathcal R$. Also $4\cdot 38 - 7 = 145 = 5 \cdot 29$, so $38 \in \mathcal R$; indeed $38 = A_0 + A_8$ and $145 = 9^2 + 8^2$.

**Corollary 2.6 (Local obstruction).** If $q \equiv 3 \pmod 4$ is prime, $q \mid 4m - 7$ and $q^2 \nmid 4m - 7$, then $m \notin \mathcal R$.

*Proof.* If $m \le 1$ there is nothing to prove. Otherwise $4m-7 \ne 0$ and $v_q(4m-7) = 1$ is odd, so Theorem 2.5 applies. $\square$

**Remark 2.7.** The map $m \mapsto 4m-7$ is a bijection from $\{m \ge 2\}$ onto the positive integers $\equiv 1 \pmod 4$. Every odd sum of two squares is $\equiv 1 \pmod 4$. Hence Theorem 2.2 gives a bijection
$$\mathcal R \cap [0, N] \;\longleftrightarrow\; \{n \le 4N - 7 : n \text{ odd},\ n = x^2 + y^2\}.$$
Section 8 uses this.

---

## 3. A fixed obstruction: the prime 3

**Theorem 3.1.** If $m \equiv 1$ or $7 \pmod 9$ then $m \notin \mathcal R$.

*Proof.* For $m \le 1$ this is clear. Let $m \ge 2$. If $m \equiv 1 \pmod 9$ then $4m - 7 \equiv -3 \equiv 6 \pmod 9$. If $m \equiv 7 \pmod 9$ then $4m - 7 \equiv 21 \equiv 3 \pmod 9$. In both cases $3 \mid 4m-7$ and $9 \nmid 4m-7$. Apply Corollary 2.6 with $q = 3$. $\square$

**Theorem 3.2 (The $2/9$ bound).** For every $k \ge 0$,
$$\#\{0 \le m < 9k : m \notin \mathcal R\} \;\ge\; 2k.$$

*Proof.* The $2k$ integers $9j+1$ and $9j+7$ for $0 \le j < k$ are distinct, lie in $[0, 9k)$, and are non-representable by Theorem 3.1. $\square$

So the lower density of the complement of $\mathcal R$ is at least $2/9$. Conversely, a direct check shows that the residues $0,2,3,4,5,6,8$ modulo $9$ all occur among representable integers. The prime $3$ excludes no other entire residue class modulo $9$, and further progress has to come from infinitely many primes.

---

## 4. The local sieve and its exact count

**Definition 4.1 (Local condition).** For a prime $p$ and $m \in \mathbb Z_{\ge 0}$, say that $m$ is *locally admissible at $p$* if
$$p \mid 4m - 7 \;\Longrightarrow\; p^2 \mid 4m - 7,$$
with divisibility taken in $\mathbb Z$. For a finite set $S$ of primes, $m$ is *$S$-good* if it is locally admissible at every $p \in S$. Define
$$Q_S = \prod_{p \in S} p^2, \qquad C_S = \prod_{p \in S}(p^2 - p + 1).$$

By Corollary 2.6:

**Lemma 4.2.** If every element of $S$ is a prime $\equiv 3 \pmod 4$ and $m \in \mathcal R$, then $m$ is $S$-good.

**Lemma 4.3 (Local count).** Let $p$ be an odd prime, $Q \ge 1$ an integer coprime to $p$, and $r \ge 0$. Then exactly $p^2 - p + 1$ of the integers $t \in [0, p^2)$ have the property that $r + Qt$ is locally admissible at $p$.

*Proof.* Write $4(r + Qt) - 7 = \alpha + \beta t$ with $\alpha = 4r - 7$ and $\beta = 4Q$. Since $p$ is odd and $\gcd(p, Q) = 1$, $\beta$ is a unit modulo $p$ and modulo $p^2$.

*Linear congruences.* If $d \ge 1$ and $\beta$ is a unit modulo $d$, the congruence $\alpha + \beta t \equiv 0 \pmod d$ has exactly one solution $t \in [0, d)$, namely $t \equiv -\alpha\beta^{-1}$. Taking $d = p^2$, exactly one $t \in [0, p^2)$ has $p^2 \mid \alpha + \beta t$. Taking $d = p$ and using that $t \mapsto [p \mid \alpha + \beta t]$ is $p$-periodic, exactly $p$ values $t \in [0, p^2)$ have $p \mid \alpha + \beta t$.

*Complement.* Since $p^2 \mid \cdot$ implies $p \mid \cdot$, the inadmissible $t$, those with $p \mid \alpha+\beta t$ but $p^2 \nmid \alpha + \beta t$, number $p - 1$. The admissible ones number $p^2 - (p-1)$. $\square$

**Theorem 4.4 (Exact CRT count).** Let $S$ be a finite set of odd primes. Being $S$-good is periodic modulo $Q_S$, and
$$\#\{0 \le m < Q_S : m \text{ is } S\text{-good}\} = C_S = \prod_{p\in S}(p^2 - p + 1).$$

*Proof.* Periodicity holds because replacing $m$ by $m + p^2 k$ changes $4m - 7$ by $4p^2k$, which does not affect divisibility by $p$ or $p^2$.

For the count we use induction on $|S|$. The case $S = \varnothing$ is trivial ($Q = C = 1$). Let $S' = S \cup \{p\}$ with $p \notin S$, and put $Q = Q_S$, so that $\gcd(p, Q) = 1$ and $Q_{S'} = Qp^2$.

*Block decomposition.* Every $m \in [0, Qp^2)$ can be written uniquely as $m = r + Qt$ with $r \in [0, Q)$ and $t \in [0, p^2)$. By periodicity, $r + Qt$ is $S$-good if and only if $r$ is. Hence
$$\#\{m < Qp^2 : m \text{ is } S'\text{-good}\} = \sum_{\substack{r < Q\\ r\ S\text{-good}}} \#\{t < p^2 : r + Qt \text{ admissible at } p\} = C_S \cdot (p^2 - p + 1)$$
by the induction hypothesis and Lemma 4.3. $\square$

**Theorem 4.5 (Sieve upper bound).** Let $S$ be a finite set of primes $\equiv 3 \pmod 4$. For every $N \ge 0$,
$$R^{<}(N) \;\le\; \Bigl(\Bigl\lfloor \frac{N}{Q_S}\Bigr\rfloor + 1\Bigr) C_S.$$

*Proof.* Let $M = Q_S(\lfloor N/Q_S\rfloor + 1) \ge N$. By Lemma 4.2, the representable integers in $[0, N)$ are among the $S$-good integers in $[0, M)$. That interval consists of $\lfloor N/Q_S\rfloor + 1$ full periods, each containing exactly $C_S$ good integers by Theorem 4.4. $\square$

**Lemma 4.6 (Periodic counting).** Here is the general counting principle used above. If $f$ is a $Q$-periodic predicate on $\mathbb Z_{\ge 0}$, then $\#\{m < Qn : f(m)\} = n\cdot\#\{m < Q : f(m)\}$. This follows by splitting $[0, Qn)$ into the residue classes $r + Qt$ ($r < Q$, $t < n$).

*Numerical illustration.* For $S = \{3\}, \{7\}, \{3,7\}, \{3,11\}, \{7,11\}, \{3,7,11\}$ the counts are $7, 43, 301, 777, 4773, 33411$, agreeing with $C_S$ (with $Q_S = 9, 49, 441, 1089, 5929, 53361$).

---

## 5. The Euler-product inequality

**Theorem 5.1.** Let $S$ be a finite set of integers $p \ge 2$. Then
$$\frac{C_S}{Q_S} = \prod_{p \in S}\Bigl(1 - \frac{p-1}{p^2}\Bigr) \;\le\; \frac{1}{1 + \tfrac12 \sum_{p\in S} \tfrac1p}.$$

*Proof.* Use induction on $|S|$; the empty case is $1 \le 1$. Write $y = (p-1)/p^2$ and $z = 1/(2p)$, and let $s = \sum_{q \in S} 1/q$. For $p \ge 2$ we have $0 \le z \le y \le 1$; indeed $z \le y \iff p^2 \le 2p(p-1) \iff p \ge 2$. By the inductive hypothesis $R := C_S/Q_S \le 1/(1 + s/2)$, so
$$(1-y)R \le \frac{1-z}{1+s/2} \le \frac{1}{1 + s/2 + z}.$$
The last inequality is $(1-z)(1 + s/2 + z) \le 1 + s/2$, that is, $-z^2 - zs/2 \le 0$. Since $s/2 + z = \tfrac12(s + 1/p)$, this closes the induction. $\square$

Conceptually, the inequality chains $1 - x \le (1+x)^{-1}$, then $\prod(1+x_i) \ge 1 + \sum x_i$, then $x_p \ge 1/(2p)$. It turns divergence of $\sum 1/p$ into vanishing of the sieve density.

---

## 6. Divergence of prime reciprocals in a residue class

Dirichlet's theorem is often stated as the divergence of $\sum_{p \equiv a\ (q)} \frac{\log p}{p}$. Since $\log p \ge 1$ this is a *weaker* divergence statement than the one we need: divergence of the $\log p$-weighted sum does not imply divergence of $\sum 1/p$ over the same primes. We therefore derive the $1/p$ version directly from the analytic lower bound.

**Analytic input.** Let $q \ge 1$ and let $a$ be a unit modulo $q$. There is a constant $C$ such that for all real $x > 1$,
$$\sum_{\substack{n \ge 1\\ n \equiv a\ (q)}} \frac{\Lambda(n)}{n^x} \;\ge\; \frac{1}{\varphi(q)}\cdot\frac{1}{x-1} - C,$$
where $\Lambda$ is the von Mangoldt function. This is the standard consequence of the simple pole of $\zeta$ at $1$ and the non-vanishing of $L(1,\chi)$ for non-principal characters $\chi$ modulo $q$.

**Theorem 6.1.** For every $q \ge 1$ and every unit $a$ modulo $q$,
$$\sum_{\substack{p \text{ prime}\\ p \equiv a\ (q)}} \frac1p = \infty.$$
In particular, for every $B$ there is a finite set $S$ of primes $p \equiv 3 \pmod 4$ with $\sum_{p\in S} 1/p > B$.

*Proof sketch.* Let $c = 1/\varphi(q)$ and suppose the series converges. Choose $P$ such that the tail $\sum_{p \ge P,\ p \equiv a} 1/p \le c/2$.

*Pointwise estimate.* For $n \ge 1$ and $x > 1$, the inequality $\log n \le n^{x-1}/(x-1)$ gives
$$\frac{\log n}{n^x} \le \frac{1}{(x-1)\,n}.$$
Split the left side of the analytic input into three parts: (a) primes $p \ge P$ in the class, (b) all $n < P$, and (c) prime powers $p^k$ with $k \ge 2$. By the pointwise estimate, part (a) is at most $\frac{1}{x-1}\cdot\frac c2$. Part (b) is a finite sum, bounded uniformly in $x > 1$. Part (c) is bounded by the convergent series $\sum_{p,\,k\ge2}\log p/p^k$. Thus the left side is at most $H + \frac{c/2}{x-1}$ for a constant $H$. Comparing with the lower bound $\frac{c}{x-1} - C$ and letting $x \to 1^+$ gives a contradiction. $\square$

---

## 7. Density zero

**Theorem 7.1 (Main theorem).**
$$\lim_{N\to\infty} \frac{R^{<}(N)}{N} = 0, \qquad\text{equivalently}\qquad \lim_{N\to\infty}\frac{\#\{m < N : m \notin \mathcal R\}}{N} = 1.$$

*Proof.* Let $\varepsilon > 0$. By Theorem 6.1 choose a finite set $S$ of primes $\equiv 3 \pmod 4$ with $\sum_{p\in S} 1/p > 4/\varepsilon$. By Theorem 5.1,
$$\frac{C_S}{Q_S} \le \frac{1}{1 + \tfrac12\sum_{p\in S}1/p} < \frac{1}{1 + 2/\varepsilon} < \frac{\varepsilon}{2}.$$
By Theorem 4.5 and $\lfloor N/Q_S\rfloor \le N/Q_S$,
$$\frac{R^{<}(N)}{N} \le \frac{(N/Q_S + 1)C_S}{N} = \frac{C_S}{Q_S} + \frac{C_S}{N} < \frac\varepsilon2 + \frac\varepsilon2 = \varepsilon$$
as soon as $N > 2C_S/\varepsilon$. The second form follows because the two counts add up to $N$. $\square$

**Remark 7.2 (The concept, corrected).** The statement "$\mathcal R$ has positive density" is therefore false. The correct normalisation is $N/\sqrt{\log N}$ (Section 8), so "positive density" survives only in the Landau sense: $R(N)\sqrt{\log N}/N$ tends to a positive constant.

**Remark 7.3 (What the elementary sieve gives quantitatively).** Theorem 4.5 is a "full-period" sieve, and its error term $C_S \le Q_S$ forces $Q_S \lesssim N$. With $S = \{p \le z : p \equiv 3 \ (4)\}$ we have $\log Q_S \approx z$, so only $z \approx \log N$ is allowed. By Mertens' theorem in progressions, $\prod_{p \le z,\ p\equiv 3(4)}(1 - (p-1)/p^2) \asymp (\log z)^{-1/2}$. Optimising therefore gives at best $R(N) \ll N/\sqrt{\log\log N}$, and even that requires Mertens-type estimates. Reaching $N/\sqrt{\log N}$ needs a sieve with a remainder term that allows $z = N^{\delta}$ (Selberg's upper-bound sieve), or the Selberg–Delange method. For example, at $N = 10^6$ the sets $S = \{3\}, \{3,7\}, \{3,7,11\}$ give the bounds $777{,}784$, $682{,}668$ and $634{,}809$ for the true value $R^<(10^6) = 399{,}341$. Adding $19$ makes $Q_S > N$, and the bound jumps to $11{,}459{,}973$.

---

## 8. The Landau scale

**Theorem 8.1 (Landau, 1908).** Let $B(x) = \#\{n \le x : n = u^2 + v^2,\ u,v\in\mathbb Z\}$. Then
$$B(x) \sim b\,\frac{x}{\sqrt{\log x}}, \qquad b = \frac{1}{\sqrt2}\prod_{p\equiv 3\ (4)}\Bigl(1 - \frac1{p^2}\Bigr)^{-1/2} = 0.764223653\ldots$$
Here $b$ is the Landau–Ramanujan constant.

**Theorem 8.2 (Landau-type asymptotic for anti-Fibonacci sums).** Assuming Theorem 8.1,
$$R(N) \sim K\,\frac{N}{\sqrt{\log N}}, \qquad K = 2b = 1.528447\ldots$$

*Proof.* Let $B_{\mathrm{odd}}(x)$ count the odd $n \le x$ that are sums of two squares. By Lemma 2.3, $n \mapsto 2n$ is a bijection from sums of two squares $\le x/2$ onto even sums of two squares $\le x$. Hence the exact identity
$$B(x) = B_{\mathrm{odd}}(x) + B(x/2)$$
holds. Since $\log(x/2) \sim \log x$, Theorem 8.1 gives $B_{\mathrm{odd}}(x) = B(x) - B(x/2) \sim \frac b2\cdot\frac{x}{\sqrt{\log x}}$. By Remark 2.7, $R(N) = B_{\mathrm{odd}}(4N-7)$, and therefore
$$R(N) \sim \frac b2\cdot\frac{4N}{\sqrt{\log 4N}} \sim 2b\,\frac{N}{\sqrt{\log N}}. \qquad\square$$

**Numerical evidence.**

| $N$ | $R(N)$ | $R(N)/N$ | $R(N)\sqrt{\log N}/N$ |
|---:|---:|---:|---:|
| $10^2$ | $65$ | $0.6500$ | $1.3949$ |
| $10^3$ | $552$ | $0.5520$ | $1.4508$ |
| $10^4$ | $4{,}834$ | $0.4834$ | $1.4670$ |
| $10^5$ | $43{,}544$ | $0.4354$ | $1.4775$ |
| $10^6$ | $399{,}341$ | $0.3993$ | $1.4843$ |
| $4\cdot10^6$ | $1{,}526{,}291$ | $0.3816$ | $1.4877$ |

The density column decreases steadily, in line with Theorem 7.1. The normalised column increases monotonically and stays bounded, consistent with the limit $K \approx 1.5284$. The proposed falsification test, that the normalised ratio should neither tend to $0$ nor blow up, is passed. The slow approach reflects the secondary term: Landau's count is known to satisfy $B(x) = b\,x(\log x)^{-1/2}(1 + c/\log x + O((\log x)^{-2}))$. In addition, normalising by $\log N$ instead of $\log 4N$ shifts the ratio by a relative amount of order $(\log 4)/(2\log N)$.

---

## 9. Algorithms

**Algorithm A (Representability test).** Input $m$. If $m < 2$, reject. Factor $n = 4m - 7$. Accept if and only if every prime $q \equiv 3 \pmod 4$ divides $n$ to an even power. The cost is that of factoring an integer of size $4m$; trial division needs $O(\sqrt m)$ steps. Given an acceptance, a representation $m = A_a + A_b$ comes from any representation $4m-7 = u^2 + v^2$ with $u > v \ge 0$ and $u \not\equiv v \pmod 2$, via $a = (u+v-1)/2$ and $b = (u-v-1)/2$. Such a representation can be found by Cornacchia-type methods or by direct search.

**Algorithm B (Counting $R(N)$).** Enumerate the $\approx\sqrt{2N}$ anti-Fibonacci numbers $\le N$ and mark all pairwise sums $\le N$ in a bit array. This takes $O(N)$ time and $O(N)$ bits.

**Algorithm C (Exact CRT sieve).** For a finite set $S$ of primes $\equiv 3 \pmod 4$, compute $Q_S$ and $C_S$ in $O(|S|)$ arithmetic operations. Then $(\lfloor N/Q_S\rfloor + 1)C_S$ bounds $R^<(N)$. By Theorem 4.4 the admissible residues can be enumerated as a CRT product of the local admissible sets, each of size $p^2 - p + 1$.

---

## 10. Discussion

The reduction in Theorem 2.2 is the structural core. It turns an additive question about a quadratic sequence into the multiplicative question of Theorem 2.5. Everything else is sieve theory over primes $\equiv 3 \pmod 4$. Two points are worth stressing.

*Exactness.* Theorem 4.4 is an exact count, not an asymptotic one. Together with Theorem 5.1 it gives a fully explicit, non-asymptotic inequality $R^<(N)/N \le (1 + \tfrac12\sum_{p\in S}1/p)^{-1} + C_S/N$ for every admissible $S$.

*Logical economy.* The only analytic input to density zero is divergence of $\sum 1/p$ over one residue class. This is weaker than Mertens' theorem and much weaker than the Selberg–Delange machinery needed for Theorem 8.1. The decay rate, by contrast, needs genuinely more.

**Applications and analogues.** The method applies to any quadratic sequence $\alpha n^2 + \beta n + \gamma$ whose completed square leads to a binary quadratic form of class number one, for example triangular numbers shifted by a constant. The pair-sum problem then reduces to representation by $x^2 + y^2$, or by $x^2 + dy^2$, on an arithmetic progression. Up to the shift by $2$, the case at hand is the classical Gauss-type question of which integers are sums of two triangular numbers: $m \in \mathcal R \iff m - 2 = T_a + T_b$.

---

## 11. Future work

1. **A self-contained Landau asymptotic.** Prove Theorem 8.2 directly by the Selberg–Delange method, applied to the Dirichlet series $\sum n^{-s}$ over odd sums of two squares $n$. That series is $\zeta(s)^{1/2}L(s,\chi_4)^{1/2}$ times a function holomorphic and non-vanishing near $s=1$. Make the error term explicit.
2. **An effective upper bound $R(N) \le C\,N/\sqrt{\log N}$** for $N \ge 3$ with explicit $C$. This would combine the exact local densities of Theorem 4.4 with Selberg's sieve on $S = \{p \le z,\ p\equiv 3\ (4)\}$, $z = N^{\delta}$, and Mertens' product in progressions.
3. **Residue-class densities.** For each modulus $q$ and class $r$, determine the constant $K_{q,r}$ with $\#\{m \le N : m \in \mathcal R,\ m\equiv r\ (q)\} \sim K_{q,r} N/\sqrt{\log N}$. The local factors are computable from Lemma 4.3. For example, the classes $1, 7 \pmod 9$ have $K = 0$ by Theorem 3.1.
4. **Second-order term.** Determine the analogue of the Ramanujan–Shanks secondary constant for $R(N)$, which would explain the slow convergence in the table of Section 8.

---

## References (classical)

- P. de Fermat (1640) stated the two-squares theorem, and L. Euler proved it in the eighteenth century.
- P. G. L. Dirichlet (1837) proved the theorem on primes in arithmetic progressions.
- E. Landau (1908) found the asymptotic count of integers that are sums of two squares; S. Ramanujan found the same law independently.
