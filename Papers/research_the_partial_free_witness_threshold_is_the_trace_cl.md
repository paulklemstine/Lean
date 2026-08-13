# The Partial Free-Witness Threshold for Semiprimes: A Sharp Divisibility Criterion

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

For an integer $N$ and an exponent $k \ge 1$, the *free witness of order $k$*
is the divisor power sum $\sigma_k(N) = \sum_{d \mid N} d^{\,k}$, which for a
semiprime $N = pq$ with distinct primes $p, q$ equals $(1+p^k)(1+q^k)$. It is
classical that the full value of $\sigma_2(N)$ determines the factorization of
$N$: the trace $t = p + q$ satisfies $t^2 = \sigma_2(N) + 2N - N^2 - 1$, after
which $p$ and $q$ are the roots of $X^2 - tX + N$. We study the *partial*
problem: given only the residue $\sigma_k(N) \bmod m$, for which moduli $m$ is
the factorization still uniquely determined?

Our main result is a **sharp threshold theorem** with no size condition
whatsoever: for a semiprime $N = pq$, the residue $\sigma_k(N) \bmod m$
determines the factorization if and only if $m$ does not divide the *witness
gap*
$$G_k(p,q) = (p^k - 1)(q^k - 1).$$
The criterion is an instance of a general **separation principle**: two
factorizations $N = ab = cd$ have congruent witnesses modulo $m$ exactly when
$m$ divides the difference $(a^k + b^k) - (c^k + d^k)$ of their power-sum
(trace) coordinates.

The threshold theorem refutes a conjectured law of the form $m^\star =
\Theta(p+q)$ (numerically $m^\star = 5(p+q)$, observed on semiprimes of bit
length $14$–$26$). We prove instead that the fixed modulus $m = 7$ suffices for
infinitely many semiprimes with both factors arbitrarily large, via Dirichlet's
theorem applied to the progression $2 \bmod 7$. We complement this with the
matching universal lower bound $m^\star \ge 5$ for $p,q > 3$ (a consequence of
$24 \mid p^2 - 1$), and the exact characterization $m^\star = 5$ if and only if
$p, q \not\equiv \pm 1 \pmod 5$. At order $k = 1$ the gap is Euler's totient,
$G_1 = \varphi(N)$, so the obstruction to partial-information factoring is
precisely the RSA trapdoor. Counting bounds show that only $O(\log N)$ prime
moduli ever need to be tried, since $\omega(G_k) \le \log_2 G_k$.

All of these are *information-theoretic* statements. We conclude with the
negative content: computing $\sigma_k(N) \bmod m$ still requires the full
divisor-sum aggregation, so the collapse of the informational requirement to a
constant does not yield a factoring shortcut. It does, however, sharpen the
target of any aggregation-hardness proof: such a proof must establish
irreducibility even for arbitrarily partial values.

**Keywords:** divisor power sum, semiprime, integer factorization, trace,
Euler totient, Dirichlet's theorem, sharp threshold, RSA.

---

## 1. Introduction

### 1.1 Setting

Let $N = pq$ be a semiprime, the product of two distinct primes. The
factorization problem for such $N$ underpins the RSA cryptosystem. It is a
classical observation that certain *global* arithmetic functionals of $N$ are
equivalent to the factorization: knowing $\varphi(N)$, or $\sigma_1(N)$, or
$\lambda(N)$ suffices to recover $p$ and $q$ in polynomial time. Each of these
functionals is "free" in the sense of being canonically attached to $N$ — no
auxiliary hint or oracle choice is involved — and each is nonetheless believed
to be as hard to compute as factoring itself.

We call $\sigma_k(N) = \sum_{d \mid N} d^{\,k}$ the **free witness of order
$k$**. This paper quantifies exactly *how much* of a free witness is needed to
determine a factorization. Concretely: fix a modulus $m$ and reveal only
$\sigma_k(N) \bmod m$. When does this residue admit a unique consistent
factorization of $N$?

### 1.2 The conjecture under test

The trace $t = p+q$ has size $\Theta(\sqrt N)$, whereas $\sigma_2(N) =
\Theta(N^2)$. Since the recovery algorithm reads $t$ off from $\sigma_2(N)$, a
natural guess is that the modulus must be large enough to represent a trace,
i.e. $m^\star = \Theta(p+q)$. Numerical experiments over semiprimes of bit
length $14$ to $26$ reported an apparently exact constant, $m^\star/(p+q) =
5.00$, together with a heuristic: for candidate traces $t' = (p+q) + jm$ the
discriminant
$$t'^2 - 4N = (p-q)^2 + 2jm(p+q) + j^2m^2$$
is generically a non-square, so the true trace is isolated once $m$ is large
enough to make the alternatives fall outside a plausible window.

We show that this heuristic, though locally accurate, does not describe the
truth. The correct criterion is a divisibility condition with no metric content
at all, and under it $m^\star$ is bounded by an absolute constant infinitely
often.

### 1.3 Summary of results

* **Theorem A (Witness formula and rigidity).** $\sigma_k(pq) =
  (1+p^k)(1+q^k)$; and for any $k \ge 1$ the pair (product, order-$k$ witness)
  is a complete invariant of an unordered pair of non-negative integers.
* **Theorem B (Exact recovery).** For $N = pq$ with $p<q$ prime,
  $t = \sqrt{\sigma_2(N) + 2N - N^2 - 1} = p + q$, $d = \sqrt{t^2 - 4N} = q-p$,
  and $p = (t-d)/2$, $q = (t+d)/2$; equivalently $X^2 - tX + N = (X-p)(X-q)$.
* **Theorem C (Separation principle).** For $ab = cd$, the order-$k$ witnesses
  of $\{a,b\}$ and $\{c,d\}$ are congruent mod $m$ iff $m \mid (a^k+b^k) -
  (c^k+d^k)$.
* **Theorem D (Sharp threshold).** For $N = pq$ a semiprime, $\sigma_k(N) \bmod
  m$ determines the factorization iff $m \nmid (p^k-1)(q^k-1)$.
* **Theorem E (Refutation of the trace law).** For every $B$ there are primes
  $B < p < q$ with $m = 7$ determining the factorization of $pq$; already
  $N = 187 = 11 \cdot 17$ is determined mod $7 \ll p+q = 28$.
* **Theorem F (Lower bound and exact-five locus).** For $p, q > 3$ no $m \le 4$
  determines; and $m^\star = 5$ iff $p, q \not\equiv \pm 1 \pmod 5$.
* **Theorem G (Totient at order one).** $\sigma_1(N) \bmod m$ determines the
  factorization iff $m \nmid \varphi(N)$.
* **Theorem H (Counting bounds).** $\omega(G_k) \le \log_2 G_k$; any family of
  more than $\omega(G_k)$ distinct primes contains a determining modulus.

Section 8 discusses the computational reading: the results are informational
and do not yield an algorithmic shortcut, because the aggregation barrier is
untouched.

---

## 2. Definitions and basic structure

**Definition 2.1 (Divisor power sum).** For $N \ge 1$ and $k \ge 0$,
$$\sigma_k(N) = \sum_{d \mid N} d^{\,k}.$$
It is multiplicative: $\sigma_k(MN) = \sigma_k(M)\sigma_k(N)$ whenever
$\gcd(M,N) = 1$.

**Definition 2.2 (Candidate witness).** For $k, a, b \ge 0$ define
$$W_k(a,b) = (1 + a^k)(1 + b^k).$$
This is the value $\sigma_k$ *would* take on $N = ab$ if $a$ and $b$ were
distinct primes; we call it the **witness of the candidate factorization**
$N = ab$. Note $W_k(a,b) = 1 + (a^k + b^k) + (ab)^k$.

**Definition 2.3 (Witness gap).** For a semiprime $N = pq$ set
$$G_k(p,q) = W_k(1, pq) - W_k(p,q) = (p^k - 1)(q^k - 1).$$
The identity is immediate from Definition 2.2:
$W_k(1,pq) = 2(1 + (pq)^k)$ and $W_k(p,q) = 1 + p^k + q^k + (pq)^k$, whose
difference is $1 - p^k - q^k + (pq)^k = (p^k-1)(q^k-1)$.

**Definition 2.4 (Determination).** Fix $k, m$ and a semiprime $N = pq$. We say
that *$\sigma_k \bmod m$ determines the factorization of $N$*, written
$\mathrm{Det}(k,m;p,q)$, if for all non-negative integers $a, b$ with $ab = pq$
and $W_k(a,b) \equiv W_k(p,q) \pmod m$ we have $\{a,b\} = \{p,q\}$.

**Definition 2.5 (Least determining modulus).**
$$m^\star_k(p,q) = \min\{m \ge 1 : \mathrm{Det}(k,m;p,q)\},$$
with $m^\star = m^\star_2$ when the order is omitted.

**Proposition 2.6 (Witness of a semiprime).** If $p \ne q$ are prime, then
$\sigma_k(pq) = W_k(p,q)$.

*Proof.* $p$ and $q$ are coprime, so $\sigma_k(pq) =
\sigma_k(p)\sigma_k(q)$ by multiplicativity, and the divisors of a prime $p$
are $1$ and $p$, whence $\sigma_k(p) = 1 + p^k$. $\square$

**Proposition 2.7 (Factor pairs of a semiprime).** If $p, q$ are prime and
$ab = pq$ with $a,b \ge 0$, then
$$(a,b) \in \{(1, pq),\ (p,q),\ (q,p),\ (pq, 1)\}.$$

*Proof.* Neither $a$ nor $b$ is $0$ since $pq > 0$. If $p \mid a$, write
$a = pc$; cancelling $p$ gives $cb = q$, so by primality of $q$ either $c = 1$
(giving $(a,b) = (p,q)$) or $c = q$ and $b = 1$ (giving $(a,b) = (pq,1)$). If
$p \nmid a$ then $\gcd(p,a) = 1$, so $a \mid q$ by Euclid's lemma, forcing
$a = 1$ (whence $b = pq$) or $a = q$ (whence $b = p$). $\square$

Proposition 2.7 is what makes the semiprime case so rigid: there is exactly one
competing factorization, the trivial one, so exactly one gap to consider.

---

## 3. Rigidity of the full witness

**Lemma 3.1 (Sum–product lemma).** If $ab = cd$ and $a + b = c + d$ for
non-negative integers, then $(a,b) = (c,d)$ or $(a,b) = (d,c)$.

*Proof.* Work in $\mathbb{Z}$. Then
$$(a - c)(a - d) = a^2 - (c+d)a + cd = a^2 - (a+b)a + ab = 0,$$
so $a = c$ or $a = d$; the sum condition determines $b$ in each case.
$\square$

Equivalently: $a$ and $b$ are the two roots of the monic quadratic
$X^2 - (a+b)X + ab$, which is determined by the data.

**Theorem 3.2 (Witness rigidity, all orders).** Let $k \ge 1$ and let
$a,b,c,d$ be non-negative integers with $ab = cd$ and
$W_k(a,b) = W_k(c,d)$. Then $\{a,b\} = \{c,d\}$ as unordered pairs.

*Proof.* From $ab = cd$ we get $a^k b^k = (ab)^k = (cd)^k = c^k d^k$. Expanding
$W_k(a,b) = 1 + a^k + b^k + (ab)^k$ and likewise for $(c,d)$, the constant and
product terms cancel, leaving $a^k + b^k = c^k + d^k$. Lemma 3.1 applied to the
pairs $(a^k, b^k)$ and $(c^k, d^k)$ gives $\{a^k,b^k\} = \{c^k,d^k\}$, and
$x \mapsto x^k$ is injective on $\mathbb{N}$ for $k \ge 1$. $\square$

Thus $(N, \sigma_k(N))$ is a complete invariant of the factor pair — the free
witness carries the entire factorization, at every order. The content of the
rest of the paper is that it carries it *very redundantly*.

---

## 4. Exact recovery at order two

**Theorem 4.1 (Trace identity).** For distinct primes $p,q$ and $N = pq$,
$$\sigma_2(N) + 2N = (p+q)^2 + N^2 + 1.$$

*Proof.* By Proposition 2.6, $\sigma_2(N) = (1+p^2)(1+q^2) = 1 + p^2 + q^2 +
N^2$. Add $2N = 2pq$ and use $p^2 + 2pq + q^2 = (p+q)^2$. $\square$

**Definition 4.2 (Extracted trace).** For $N$ and a witness value $w$, set
$$T(N, w) = \big\lfloor \sqrt{\,w + 2N - N^2 - 1\,} \big\rfloor .$$

**Corollary 4.3.** For distinct primes $p, q$ and $N = pq$, $T(N,
\sigma_2(N)) = p + q$ exactly, the radicand being the perfect square
$(p+q)^2$.

**Theorem 4.4 (Recovery).** Let $p < q$ be primes, $N = pq$, $t = T(N,
\sigma_2(N))$ and $d = \lfloor\sqrt{t^2 - 4N}\rfloor$. Then
$$p = \frac{t-d}{2}, \qquad q = \frac{t+d}{2}.$$

*Proof.* By Corollary 4.3, $t = p+q$. The algebraic identity
$(p+q)^2 = (q-p)^2 + 4pq$ shows $t^2 - 4N = (q-p)^2$, a perfect square, so
$d = q - p$. Then $(t-d)/2 = p$ and $(t+d)/2 = q$. $\square$

**Theorem 4.5 (Recovered characteristic polynomial).** With $t = T(N,
\sigma_2(N))$ as above,
$$X^2 - tX + N = (X - p)(X - q) \quad \text{in } \mathbb{Z}[X].$$

*Proof.* Substitute $t = p+q$ and $N = pq$ and expand. $\square$

**Worked example.** $N = 187 = 11 \cdot 17$. Divisors $1,11,17,187$;
$\sigma_2(187) = 1 + 121 + 289 + 34969 = 35380$. Then $35380 + 374 - 34969 - 1
= 784 = 28^2$, so $t = 28$; $t^2 - 4N = 784 - 748 = 36 = 6^2$, so $d = 6$; and
$(28 \mp 6)/2 = (11, 17)$.

The recovery is $O(\log^2 N)$ bit operations given $\sigma_2(N)$ — integer
square roots and a division. The entire difficulty is in obtaining
$\sigma_2(N)$.

---

## 5. The separation principle and the sharp threshold

### 5.1 Separation

**Theorem 5.1 (Separation principle).** Let $a,b,c,d$ be non-negative integers
with $ab = cd$, and let $k, m \ge 0$. Then
$$W_k(a,b) \equiv W_k(c,d) \pmod m
\iff m \mid \big((a^k + b^k) - (c^k + d^k)\big) \text{ in } \mathbb{Z}.$$

*Proof.* $W_k(a,b) - W_k(c,d) = (a^k + b^k) - (c^k+d^k) + \big((ab)^k -
(cd)^k\big)$, and the last bracket vanishes because $ab = cd$. $\square$

Interpretation: the order-$k$ witness of a factorization of a *fixed* $N$
depends only on the power-sum coordinate $a^k + b^k$. At $k = 1$ this
coordinate is literally the trace $a+b$; at general $k$ it is the trace of the
$k$-th power of the companion matrix $\begin{pmatrix} 0 & -N \\ 1 &
a+b\end{pmatrix}$ up to the elementary-symmetric correction. The free witness
therefore has a *one-dimensional* view of the factorization, and all
threshold phenomena are shadows of that one-dimensionality.

### 5.2 The sharp threshold

**Theorem 5.2 (Sharp threshold theorem).** Let $p,q$ be primes, $N = pq$, and
$k, m \ge 0$. Then
$$\mathrm{Det}(k,m;p,q) \iff m \nmid (p^k - 1)(q^k - 1) = G_k(p,q).$$

*Proof.* ($\Leftarrow$) Suppose $m \nmid G_k$, and let $ab = N$ with $W_k(a,b)
\equiv W_k(p,q) \pmod m$. By Proposition 2.7 the pair $(a,b)$ is one of
$(1,N), (p,q), (q,p), (N,1)$. In the two nontrivial-order cases we are done. In
the cases $(1,N)$ and $(N,1)$ — the witness is symmetric, $W_k(a,b) =
W_k(b,a)$ — the congruence reads $W_k(1,N) \equiv W_k(p,q) \pmod m$, so by
Definition 2.3, $m \mid G_k$, contradicting the hypothesis.

($\Rightarrow$) Suppose $m \mid G_k$. Then $W_k(1,N) \equiv W_k(p,q) \pmod m$,
so the trivial factorization $(a,b) = (1,N)$ satisfies the congruence. Since $p
> 1$ and $q > 1$, $(1,N) \notin \{(p,q),(q,p)\}$, so determination fails.
$\square$

Two features deserve emphasis.

1. **No size condition.** The criterion involves no inequality between $m$ and
   any function of $p, q$. Whether a modulus works is a purely arithmetic
   property of its interaction with a single integer $G_k$.
2. **Downward closure of failure.** The failure set $\{m : m \mid G_k\}$ is
   closed under divisors. So $m^\star_k(p,q)$ is precisely the least
   non-divisor of $G_k(p,q)$; in particular $m^\star_k$ is at most the smallest
   prime not dividing $G_k$.

**Corollary 5.3 (Reformulation of the least modulus).**
$$m^\star_k(p,q) = \min\{m \ge 1 : m \nmid (p^k-1)(q^k-1)\}.$$

Since $1 \mid G$ always, $m^\star \ge 2$; and since $G_k$ is even for odd $p$,
$m^\star \ge 3$; the refinements of Section 7 push this to $5$.

---

## 6. Refutation of the $\Theta(p+q)$ law

### 6.1 An explicit counterexample

**Proposition 6.1.** Let $p = 11$, $q = 17$, $N = 187$. Then
$\mathrm{Det}(2, 7; 11, 17)$ holds, although $7 < p + q = 28$ and the
conjectured threshold $5(p+q) = 140$.

*Proof.* $G_2 = (11^2-1)(17^2-1) = 120 \cdot 288 = 34560$. Modulo $7$: $121
\equiv 2$, so $p^2 - 1 \equiv 1$; $289 \equiv 2$, so $q^2 - 1 \equiv 1$; hence
$G_2 \equiv 1 \not\equiv 0 \pmod 7$. Apply Theorem 5.2. $\square$

Concretely: $\sigma_2(187) = 35380 \equiv 2 \pmod 7$, while the trivial
factorization's witness is $W_2(1,187) = 2 \cdot 34970 = 69940 \equiv 3 \pmod
7$. Three bits of $\sigma_2$ separate them.

### 6.2 A constant modulus, infinitely often

**Theorem 6.2 (Constant-modulus theorem).** For every bound $B$ there exist
primes $p, q$ with $B < p < q$ such that $\mathrm{Det}(2, 7; p, q)$.
Consequently $m^\star(p,q) \le 7$ for infinitely many semiprimes with both
prime factors arbitrarily large, and no lower bound of the form $m^\star \ge
c\,(p+q)$ with $c > 0$ can hold.

*Proof.* By Dirichlet's theorem on primes in arithmetic progressions, the
class $2 \bmod 7$ contains infinitely many primes (indeed $\gcd(2,7)=1$).
Choose a prime $p > B$ with $p \equiv 2 \pmod 7$, then a prime $q > p$ with
$q \equiv 2 \pmod 7$. Working in $\mathbb{Z}/7$,
$$G_2 = (p^2-1)(q^2-1) \equiv (2^2-1)(2^2-1) = 9 \equiv 2 \pmod 7,$$
so $7 \nmid G_2$ and Theorem 5.2 applies. $\square$

**Remark 6.3 (What the experiment measured).** The empirical ratio
$m^\star/(p+q) = 5.00$ over bit lengths $14$–$26$ is not a law of arithmetic.
By Corollary 5.3, $m^\star$ is the least non-divisor of $G_2$, a quantity that
is typically a very small number: heuristically, a "random" integer $G$ fails
to be divisible by $5$ with probability $4/5$, so the least non-divisor is
almost always below $10$. Any measurement producing a value proportional to
$p+q$ must therefore have been measuring a different quantity — for instance,
the least modulus that isolates the trace among the *lifted candidates*
$t' = t + jm$ in a bounded window, which is a genuinely metric question, but a
question about a search procedure rather than about information content. The
discriminant heuristic $t'^2 - 4N = (p-q)^2 + 2jm(p+q) + j^2m^2$ describes
exactly this lifting procedure, and its conclusion (that only $t$ yields a
square discriminant) is correct; what fails is the inference that the modulus
must be trace-sized. Under Theorem 5.2, one does not have to enumerate lifted
traces at all: uniqueness is already decided by a divisibility.

---

## 7. Locating the threshold exactly

### 7.1 A universal lower bound

**Lemma 7.1.** If $p$ is odd and $3 \nmid p$, then $p^2 \equiv 1 \pmod{24}$.

*Proof.* $p^2 - 1 = (p-1)(p+1)$ is a product of two consecutive even integers,
one of which is divisible by $4$, giving $8 \mid p^2-1$. Also $p \equiv \pm 1
\pmod 3$, so $3 \mid p^2-1$. As $\gcd(8,3)=1$, $24 \mid p^2-1$. (Equivalently,
check the $8$ admissible residues of $p$ modulo $24$.) $\square$

**Corollary 7.2.** For every prime $p > 3$, $24 \mid p^2 - 1$; hence for any
$q$, $24 \mid G_2(p,q)$.

**Theorem 7.3 (Universal lower bound).** Let $p, q$ be primes with $p > 3$.
Then no modulus $m$ with $1 \le m \le 4$ determines the factorization of $pq$
from $\sigma_2 \bmod m$. That is, $m^\star(p,q) \ge 5$.

*Proof.* Every $m \in \{1,2,3,4\}$ divides $24$, and $24 \mid G_2$ by Corollary
7.2, so $m \mid G_2$; apply Theorem 5.2. $\square$

Note the contrast with Theorem 6.2: the least determining modulus is pinned
between the absolute constants $5$ and (infinitely often) $7$. The constant $5$
in the empirical law was real; the factor $(p+q)$ was not.

### 7.2 The exact-five locus

**Lemma 7.4.** For $p \ge 1$, $5 \mid p^2 - 1 \iff p \equiv \pm 1 \pmod 5$.

*Proof.* $p^2 \bmod 5$ depends only on $p \bmod 5$, and the squares are
$0,1,4,4,1$ for $p \equiv 0,1,2,3,4$. Thus $p^2 \equiv 1$ iff $p \equiv 1, 4$.
$\square$

**Theorem 7.5 (Exact-five theorem).** For primes $p, q$,
$$\mathrm{Det}(2,5;p,q) \iff p \not\equiv \pm1 \pmod 5 \text{ and } q
\not\equiv \pm1 \pmod 5 .$$
If in addition $p > 3$, then under those congruence conditions $m^\star(p,q) =
5$ exactly, uniformly in the size of $p$ and $q$.

*Proof.* By Theorem 5.2, $\mathrm{Det}(2,5;p,q)$ iff $5 \nmid (p^2-1)(q^2-1)$.
Since $5$ is prime, $5 \mid (p^2-1)(q^2-1)$ iff $5 \mid p^2-1$ or $5 \mid
q^2-1$; apply Lemma 7.4. The final claim combines this with Theorem 7.3.
$\square$

Thus the true law is $m^\star = 5$ — a constant — on the set of semiprimes
whose factors lie in the residue classes $\{2,3\} \bmod 5$. Under the
heuristic that $p$ and $q$ equidistribute independently over the four
invertible classes mod $5$, this set has density $(1/2)^2 = 1/4$ among
semiprimes with $p,q>5$.

### 7.3 Counting bounds: few moduli can fail

**Lemma 7.6.** For $k \ge 1$ and primes $p,q$, $G_k(p,q) \ge 1 > 0$.

*Proof.* $p^k \ge p \ge 2$ and likewise for $q$, so both factors are at least
$1$. $\square$

**Theorem 7.7 (Pigeonhole form).** Let $k \ge 1$, let $S$ be a finite set of
distinct primes with $|S| > \omega(G_k(p,q))$, where $\omega$ counts distinct
prime divisors. Then some $r \in S$ satisfies $\mathrm{Det}(k,r;p,q)$.

*Proof.* If not, then by Theorem 5.2 every $r \in S$ divides $G_k$, so $S
\subseteq \{\text{prime divisors of } G_k\}$ and $|S| \le \omega(G_k)$, a
contradiction. $\square$

**Theorem 7.8 (Product form).** Let $k \ge 1$ and let $S$ be a finite set of
distinct primes with $G_k(p,q) < 2^{|S|}$. Then some $r \in S$ determines.

*Proof.* Otherwise all $r \in S$ divide $G_k$, hence so does $\prod_{r\in S} r
\ge 2^{|S|} > G_k$, contradicting $G_k > 0$. $\square$

**Corollary 7.9 (Small prime modulus).** If $G_k(p,q) < 2^{\pi(x)}$, then some
prime $r < x$ determines the factorization.

**Theorem 7.10 (Logarithmic bound on failures).** For $k \ge 1$,
$$\omega\big(G_k(p,q)\big) \le \log_2 G_k(p,q).$$

*Proof.* The product of the distinct prime divisors divides $G_k$ and is at
least $2^{\omega(G_k)}$; since $G_k > 0$, $2^{\omega(G_k)} \le G_k$. $\square$

For $k=2$ we have $G_2 < N^2$, so $\omega(G_2) < 2\log_2 N$: at most
$2\log_2 N$ prime moduli can fail, and any $2\log_2 N + 1$ distinct primes
contain a working one. Combined with Corollary 5.3, the factor-determining
content of $\sigma_2$ is concentrated in $O(\log\log N)$ bits of residue
information located at $O(\log N)$-sized moduli — far below the $\Theta(\log
N)$ bits of the trace, let alone the $\Theta(\log N^2)$ bits of $\sigma_2$
itself.

---

## 8. Order one: the totient and the RSA trapdoor

**Proposition 8.1.** For distinct primes $p,q$ and $N = pq$,
$$G_1(p,q) = (p-1)(q-1) = \varphi(N).$$

*Proof.* Multiplicativity of $\varphi$ on coprime arguments and
$\varphi(p) = p-1$. $\square$

**Theorem 8.2 (Totient threshold).** For distinct primes $p, q$ and $N = pq$,
$$\mathrm{Det}(1,m;p,q) \iff m \nmid \varphi(N).$$

*Proof.* Theorem 5.2 at $k=1$, with Proposition 8.1. $\square$

This is a modular refinement of the classical equivalence "knowing $\varphi(N)$
is equivalent to factoring $N$". The classical statement uses the full value of
$\varphi(N)$; Theorem 8.2 says that the *obstruction set* for partial
information at order $1$ is exactly the divisor lattice of $\varphi(N)$. Any
residue of $\sigma_1(N) = 1 + p + q + N$ modulo a non-divisor of $\varphi(N)$
already pins the factorization down. Since $\sigma_1(N) = N + 1 + t$ with $t =
p+q$, and $\varphi(N) = N + 1 - t$, the two are two faces of the same trace
coordinate — exactly as the separation principle predicts.

**Remark 8.3 (The totient tower).** At order $k$, $p^k - 1 =
|\mathbb{F}_{p^k}^\times|$, so
$$G_k(p,q) = \big|\mathbb{F}_{p^k}^\times\big| \cdot
\big|\mathbb{F}_{q^k}^\times\big|,$$
the product of the orders of the unit groups of the degree-$k$ extensions of
$\mathbb{F}_p$ and $\mathbb{F}_q$. The failure set for the order-$k$ witness is
therefore the divisor lattice of that product. Since $p^{k} - 1 \mid p^{kk'} -
1$, the failure sets are nested along divisibility of orders: a modulus that
fails at order $k$ also fails at every multiple order.

---

## 9. Algorithms

We record the procedures implicit in the theorems, with complexities in bit
operations on $n = \log_2 N$-bit inputs.

**Algorithm 1 (Trace recovery from the full witness).** *Input:* $N$, $w =
\sigma_2(N)$. *Output:* $\{p,q\}$.
1. $r \leftarrow w + 2N - N^2 - 1$.
2. $t \leftarrow \lfloor\sqrt r\rfloor$; abort unless $t^2 = r$.
3. $s \leftarrow t^2 - 4N$; $d \leftarrow \lfloor\sqrt s\rfloor$; abort unless
   $d^2 = s$.
4. Return $\big((t-d)/2, (t+d)/2\big)$.

Correctness is Theorem 4.4; cost is $O(M(n)\log n)$ with $M$ the
multiplication cost — dominated by two integer square roots of $O(n)$-bit
numbers.

**Algorithm 2 (Least determining modulus).** *Input:* $p, q, k$. *Output:*
$m^\star_k(p,q)$.
1. $G \leftarrow (p^k-1)(q^k-1)$.
2. For $m = 1, 2, 3, \dots$: if $G \bmod m \ne 0$, return $m$.

Correctness is Corollary 5.3. Termination is immediate ($m = G+1$ works), and
in practice the loop exits after $O(1)$ iterations: by Theorem 7.3 the answer
is at least $5$ when $p,q>3$, and heuristically it is at most a small constant
with overwhelming probability, since $G$ must be divisible by *all* of
$1,\dots,m-1$ for the answer to exceed $m$ — requiring $\mathrm{lcm}(1,\dots,
m-1) \mid G$, a condition of density $1/\mathrm{lcm}(1,\dots,m-1)$.

**Algorithm 3 (Separation test).** *Input:* $N$, $k$, $m$, a residue $w_0
\equiv \sigma_k(N) \bmod m$, and the list of factor pairs of $N$. *Output:* the
set of factorizations consistent with the residue.
1. For each divisor pair $(a,b)$ with $ab = N$: compute $W_k(a,b) \bmod m$ by
   modular exponentiation.
2. Keep those with $W_k(a,b) \equiv w_0$.

Cost $O(\tau(N)\log k \cdot M(\log m))$ where $\tau$ is the divisor count. This
is a *verification* procedure, not a factoring procedure: it presumes the
divisor pairs are already known.

**Algorithm 4 (Certified small-modulus search).** *Input:* $p,q,k$, a bound
$x$. *Output:* a prime $r < x$ with $\mathrm{Det}(k,r;p,q)$, or failure.
1. $G \leftarrow (p^k-1)(q^k-1)$.
2. For each prime $r < x$ in increasing order: if $r \nmid G$ return $r$.
3. Return failure.

By Theorem 7.7 the search succeeds whenever $\pi(x) > \omega(G)$, and by
Theorem 7.10 it suffices that $\pi(x) > \log_2 G$; for $k = 2$, $\pi(x) >
2\log_2 N$ always suffices.

---

## 10. The computational reading: why this is not a factoring attack

Every determination statement above is **information-theoretic**: it asserts
that the residue class $\sigma_k(N) \bmod m$ is compatible with exactly one
factorization of $N$. It does not assert that the residue is computable without
knowing that factorization, and indeed no such assertion is available.

The obstruction is the **aggregation barrier**. The functional $\sigma_k(N) =
\sum_{d\mid N} d^k$ is a sum over the divisor set of $N$. All known evaluations
proceed by first obtaining the prime factorization and then applying
multiplicativity; the sum has no known short representation that bypasses the
divisor structure. Crucially, this cost does not decrease when only a residue
is required:

* Reduction modulo $m$ is a homomorphism *after* the sum has been formed, and
  there is no known way to compute $\sum_{d \mid N} d^k \bmod m$ that avoids
  enumerating divisors of $N$ or factoring $N$.
* The reduction does not shrink the index set of the aggregation, only the
  range of the summands.

The result of this cycle is therefore a **refutation as a shortcut** but a
**positive contribution to barrier analysis**. Prior to the sharp threshold
theorem, one might reasonably have hoped that partial values are cheap in
proportion to how partial they are, so that a $\Theta(p+q)$ informational
requirement would translate into a $\Theta(\sqrt N)$ computational task,
already an interesting non-trivial regime. Theorem 6.2 destroys the premise in
the strongest possible direction: the informational requirement collapses to a
*constant number of bits*. Consequently:

> **Sharpened barrier statement.** Any proof that divisor-sum aggregation is
> computationally irreducible must show irreducibility for arbitrarily
> *partial* values — down to $\sigma_2(N) \bmod 7$ — and not merely for the
> full value $\sigma_2(N)$.

This is a strictly stronger requirement than the naive one, and it is now
precisely formulated. It also explains why "hint-free uniform" approaches to
factoring via free witnesses are exhausted at the classical level: information
is not the bottleneck; aggregation is.

---

## 11. Discussion and future directions

The organizing fact of this paper is the separation principle: two
factorizations $N = ab = cd$ are indistinguishable modulo $m$ exactly when $m
\mid (a^k + b^k) - (c^k + d^k)$. For semiprimes it collapses to the single
witness gap $G_k(p,q) = (p^k-1)(q^k-1)$, and the whole "threshold" question
becomes a divisibility question, not a size question.

Three directions follow directly.

**Conjecture 11.1 (Logarithmic threshold, unconditional).** For every semiprime
$N = pq$ with $p, q > 3$, the least determining modulus satisfies
$$m^\star(p,q) = O\!\left(\frac{\log N}{\log\log N}\right),$$
and this order is attained infinitely often.

*Why plausible.* The failure set is $\{m : m \mid G_2\}$, so $m^\star$ is the
least non-divisor of a number below $N^2$; it is bounded by the first prime
that does not divide $G_2$, and $G_2$ has at most $\log_2 G_2$ distinct prime
divisors. Theorems 7.7, 7.8 and 7.10 already supply the counting half — any
family of more than $\omega(G_2)$ primes contains a working modulus, and
$\omega(G_2) \le \log_2 G_2$. What remains is an effective lower bound on
$\pi(x)$ of Chebyshev type, converting the counting statement into an explicit
$x = O(\log N \log\log N)$, and then a sharpening to remove the $\log\log$
factor.

**Conjecture 11.2 (Exact density of the $m^\star = 5$ locus).** Under
independent equidistribution of $p$ and $q$ over the invertible residues mod
$5$, the set of semiprimes with $m^\star = 5$ has natural density $1/4$; more
generally, $\Pr[m^\star = r]$ for a prime $r$ is computed by a product over
smaller primes of the corresponding local failure probabilities.

*Why plausible.* Theorem 7.5 converts $m^\star = 5$ into the purely local
condition $p, q \not\equiv \pm1 \pmod 5$, so the density question becomes a
Dirichlet equidistribution question, one prime at a time. Empirical histograms
of the least determining modulus over random semiprimes (with mass
concentrated on $5$, $7$, $11$) should match the resulting product formula, and
the derivation requires only Dirichlet densities together with the local
conditions already isolated in Lemma 7.4.

**Conjecture 11.3 (Order-$k$ collapse to the totient tower).** For each $k \ge
1$, $G_k(p,q) = |\mathbb{F}_{p^k}^\times|\cdot|\mathbb{F}_{q^k}^\times|$, so
the modular threshold at order $k$ is governed by the orders of the unit groups
of the degree-$k$ extensions. Since $p^k - 1 \mid p^{kk'}-1$, the failure sets
are nested and the least determining modulus is monotone along the divisibility
lattice of orders: $m^\star_k \le m^\star_{kk'}$.

*Why plausible.* Remark 8.3 gives the group-theoretic identification; the
nesting of failure sets is immediate from divisibility of $x^k-1$ into
$x^{kk'}-1$, and the monotonicity statement then follows from Corollary 5.3.
Note that $m^\star_k$ is *not* monotone in $k$ itself: odd orders typically
leave many small moduli available (numerically, $m^\star_k$ for $p=11$, $q=17$
alternates $3, 7, 3, 7, 3, 11, \dots$ as $k = 1,2,3,\dots$). The interesting
question is the behaviour along highly divisible chains such as $k =
\mathrm{lcm}(1,\dots,n)$: there $p^k - 1$ absorbs every prime $r$ with
$\mathrm{ord}_r(p) \mid k$, so $m^\star_k$ should grow like the least prime
$r$ with $\mathrm{ord}_r(p) \nmid k$ and $\mathrm{ord}_r(q) \nmid k$, tending
to infinity along the chain.

Two further directions seem worthwhile. First, the analogue for $N$ with more
than two prime factors: the separation principle is stated for arbitrary $N$,
but the failure analysis must then range over all $\tau(N)/2$ factor pairs, and
the least determining modulus becomes the least non-divisor of a *set* of gaps
— a covering-system question. Second, the multi-modulus version: given
$\sigma_k(N)$ modulo several coprime $m_1,\dots,m_r$, determination holds iff
$\mathrm{lcm}(m_i) \nmid G_k$, so the natural object is the lcm lattice and one
may ask for the shortest chain of tiny moduli whose lcm escapes $G_k$.

---

## 12. Conclusion

The free witness $\sigma_k(N)$ of a semiprime carries its factorization
completely and redundantly. Completeness is Theorem 3.2: the pair (product,
witness) is a complete invariant at every order. Redundancy is Theorem 5.2: the
residue modulo $m$ already suffices whenever $m$ fails to divide the witness
gap $(p^k-1)(q^k-1)$ — a condition of pure divisibility, with no size
constraint. Consequently the conjectured trace-order threshold $m^\star \approx
5(p+q)$ is false; the fixed modulus $7$ suffices for infinitely many semiprimes
with arbitrarily large factors, while $m^\star \ge 5$ always, with equality
exactly when neither factor is $\pm 1$ modulo $5$. At order one, the
obstruction is Euler's totient, making the RSA trapdoor visible as the
divisor lattice of $\varphi(N)$.

The practical consequence is negative and clarifying. Since a constant number
of bits of $\sigma_2(N)$ suffices informationally, and since no shortcut is
known for computing even that constant number of bits, the entire hardness of
this route to factoring resides in the aggregation step. Any hardness proof
must be aimed there — and must cover arbitrarily partial values.
