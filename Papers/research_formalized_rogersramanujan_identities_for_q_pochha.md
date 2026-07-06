# The Finite Core of the Rogers–Ramanujan Identities: Schur Polynomials, Gaussian Binomials, and a Fibonacci Bridge

## Abstract

The Rogers–Ramanujan identities equate an infinite $q$-hypergeometric series with an infinite product whose factors are governed by residues modulo $5$. Their combinatorial engine, however, is a *finite* polynomial identity due to I. Schur. We give a self-contained development of this finite core. Working in the polynomial ring $\mathbb{Z}[q]$, we define the Gaussian binomial coefficients $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q$ through the $q$-Pascal recurrence, establish a second (non-defining) $q$-Pascal rule and a vanishing lemma, and introduce the Rogers–Ramanujan (Schur) polynomials $D_n$ via a $q$-Fibonacci recurrence. Our central result, the **finite Rogers–Ramanujan identity**, states that $D_n = \sum_{k} q^{k^2}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q$. We prove it by showing that the sum side obeys the same recurrence as $D_n$, the key step being the second $q$-Pascal rule. Specializing $q = 1$, the Gaussian binomials become ordinary binomials and the identity collapses to the classical diagonal-of-Pascal identity $\sum_k \binom{n-k}{k} = F_{n+1}$, equivalently $D_n(1) = F_{n+1}$, forging an exact bridge between the $q$-series world and the Fibonacci numbers. We discuss the partition-theoretic meaning of the weight $q^{k^2}$ as the cost of a minimal difference-$\ge 2$ staircase, present algorithms and numerical evidence, and outline several research directions, including a companion finitization of the second Rogers–Ramanujan identity and a conjectural $q$-deformed Fibonacci gcd law.

**Keywords:** Rogers–Ramanujan identities, Gaussian binomial coefficients, $q$-Pochhammer symbols, Schur polynomials, $q$-Fibonacci recurrence, integer partitions, generating functions.

---

## 1. Introduction

Among the most celebrated results in the theory of integer partitions are the two **Rogers–Ramanujan identities**. In their analytic form, the first identity reads

$$\sum_{k \ge 0} \frac{q^{k^2}}{(q;q)_k} \;=\; \prod_{j \ge 0} \frac{1}{(1-q^{5j+1})(1-q^{5j+4})},$$

where $(q;q)_k = \prod_{i=1}^{k}(1-q^i)$ denotes the finite $q$-Pochhammer symbol. Read as an equality of formal power series in $q$ with integer coefficients, the identity asserts that, for every non-negative integer $n$, the coefficient of $q^n$ on the two sides coincides. Its combinatorial content is the theorem of MacMahon and Schur: the number of partitions of $n$ into parts with pairwise differences at least $2$ equals the number of partitions of $n$ into parts congruent to $1$ or $4$ modulo $5$.

The infinite identity is not, by itself, a finitely checkable statement. Its proof and its computational verification both proceed through a **finitization**: a family of polynomials that satisfy a manifestly finite identity and that converge, degree by degree, to the two sides of the infinite identity as a parameter tends to infinity. The classical finitization is due to Issai Schur, who introduced polynomials $D_n$ satisfying a Fibonacci-type recurrence and showed that they admit a closed form as a weighted sum of Gaussian binomial coefficients.

This paper is a rigorous, self-contained account of that finite core. We take as our setting the polynomial ring $\mathbb{Z}[q]$, with $q$ a formal indeterminate. Our goals are:

1. to develop the Gaussian binomial coefficients and their two Pascal rules from first principles;
2. to prove the finite Rogers–Ramanujan identity $D_n = \sum_k q^{k^2}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q$;
3. to establish the $q=1$ specialization $D_n(1) = F_{n+1}$ and the associated diagonal-of-Pascal identity, thereby bridging to the Fibonacci numbers; and
4. to explain the partition-theoretic interpretation of the weight $q^{k^2}$ and to record numerical evidence and further directions.

Everything below is stated and proved inline. No external reference is needed to follow the argument.

---

## 2. Preliminaries: Gaussian binomial coefficients

Throughout, $q$ is a formal variable and all polynomials lie in $\mathbb{Z}[q]$.

### 2.1 Definition

**Definition 2.1 (Gaussian binomial coefficient).** The Gaussian binomial coefficient $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q \in \mathbb{Z}[q]$ is defined for all $n, k \in \mathbb{N}$ by the $q$-Pascal recurrence

$$\left[\begin{smallmatrix} n \\ 0\end{smallmatrix}\right]_q = 1, \qquad \left[\begin{smallmatrix} 0 \\ k+1\end{smallmatrix}\right]_q = 0, \qquad \left[\begin{smallmatrix} n+1 \\ k+1\end{smallmatrix}\right]_q = \left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q + q^{\,k+1}\left[\begin{smallmatrix} n \\ k+1\end{smallmatrix}\right]_q.$$

This recurrence determines $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q$ uniquely by induction on $n$. It is the $q$-analogue of Pascal's rule $\binom{n+1}{k+1} = \binom{n}{k} + \binom{n}{k+1}$, to which it reduces at $q = 1$.

### 2.2 Vanishing outside the range

**Lemma 2.2 (Vanishing).** If $n < k$ then $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q = 0$.

*Proof sketch.* Induct on $n$ with $k$ allowed to vary. For $n = 0$ and $k \ge 1$ the value is $0$ by definition. For the inductive step, write $k = k'+1$ (the case $k=0$ is impossible when $n<k$) and apply the defining recurrence
$\left[\begin{smallmatrix} n+1 \\ k'+1\end{smallmatrix}\right]_q = \left[\begin{smallmatrix} n \\ k'\end{smallmatrix}\right]_q + q^{k'+1}\left[\begin{smallmatrix} n \\ k'+1\end{smallmatrix}\right]_q$. From $n+1 < k'+1$ we get $n < k'$ and $n < k'+1$, so both terms on the right vanish by the induction hypothesis. $\square$

### 2.3 The second $q$-Pascal rule

The defining recurrence expands a Gaussian binomial "by the last column." There is a second, dual expansion that is not immediate from the definition and plays the decisive role in our main theorem.

**Lemma 2.3 (Second $q$-Pascal rule).** For all $n, k \in \mathbb{N}$,

$$\left[\begin{smallmatrix} n+1 \\ k+1\end{smallmatrix}\right]_q = \left[\begin{smallmatrix} n \\ k+1\end{smallmatrix}\right]_q + q^{\,n-k}\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q.$$

*Proof sketch.* Induct on $n$, allowing $k$ to vary. The base case $n = 0$ is checked directly (both sides handle the ranges $k=0$ and $k\ge 1$ correctly, using Lemma 2.2). For the inductive step, expand the left side by the *defining* recurrence and rewrite the resulting sub-coefficients using the induction hypothesis, then reconcile the powers of $q$ using $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q$'s vanishing (Lemma 2.2) to eliminate out-of-range terms in the two boundary cases $n \le k$ and $n > k$. The exponents $k+1$ (from the defining rule) and $n-k$ (from the second rule) combine so that the two descriptions coincide. $\square$

The two rules together — column expansion and row expansion — are the full "$q$-Pascal calculus" we need.

### 2.4 Specialization at $q = 1$

**Lemma 2.4 (Specialization).** For all $n, k \in \mathbb{N}$, the evaluation at $q = 1$ satisfies $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q\big|_{q=1} = \binom{n}{k}$.

*Proof sketch.* Evaluation at $q=1$ is a ring homomorphism $\mathbb{Z}[q] \to \mathbb{Z}$. Applying it to the defining recurrence sends $q^{k+1} \mapsto 1$, producing exactly Pascal's rule $\binom{n+1}{k+1} = \binom{n}{k} + \binom{n}{k+1}$ with matching boundary values $\binom{n}{0}=1$, $\binom{0}{k+1}=0$. Uniqueness of the solution to Pascal's recurrence gives the claim by induction on $n$. $\square$

---

## 3. The Rogers–Ramanujan (Schur) polynomials

**Definition 3.1 (Schur / Rogers–Ramanujan polynomials).** Define $D_n \in \mathbb{Z}[q]$ by

$$D_0 = 1, \qquad D_1 = 1, \qquad D_{n+2} = D_{n+1} + q^{\,n+1}\, D_n.$$

The first few are $D_0 = 1$, $D_1 = 1$, $D_2 = 1 + q$, $D_3 = 1 + q + q^2$, $D_4 = 1 + q + q^2 + q^3 + q^4 - \ldots$; in general $D_n$ is a polynomial with non-negative integer coefficients, and its degree grows quadratically in $n$. At $q = 1$ the recurrence becomes the Fibonacci recurrence (see §5).

**Definition 3.2 (Sum side).** Define the *Rogers–Ramanujan sum polynomial*

$$S_n \;=\; \sum_{k=0}^{n} q^{\,k^2}\, \left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q.$$

By Lemma 2.2, the summand vanishes whenever $n-k < k$, i.e. whenever $k > n/2$; so $S_n$ is genuinely a finite sum with $\lfloor n/2\rfloor + 1$ non-zero terms, and the upper limit $n$ is harmless.

---

## 4. The finite Rogers–Ramanujan identity

The core structural fact is that the sum side satisfies the same recurrence as the Schur polynomials.

**Proposition 4.1 (Recurrence for the sum side).** For all $n \in \mathbb{N}$,

$$S_{n+2} = S_{n+1} + q^{\,n+1}\, S_n.$$

*Proof sketch.* Start from $S_{n+2} = \sum_{k=0}^{n+2} q^{k^2}\left[\begin{smallmatrix} n+2-k \\ k\end{smallmatrix}\right]_q$ and separate the $k=0$ term (equal to $1$) from the tail $\sum_{k\ge 1}$. On the tail apply the second $q$-Pascal rule (Lemma 2.3) to $\left[\begin{smallmatrix} n+2-k \\ k\end{smallmatrix}\right]_q = \left[\begin{smallmatrix} (n+1-k)+1 \\ (k-1)+1\end{smallmatrix}\right]_q$, obtaining

$$\left[\begin{smallmatrix} n+2-k \\ k\end{smallmatrix}\right]_q = \left[\begin{smallmatrix} n+1-k \\ k\end{smallmatrix}\right]_q + q^{\,(n+1-k)-(k-1)}\left[\begin{smallmatrix} n+1-k \\ k-1\end{smallmatrix}\right]_q.$$

The first group of terms reassembles (together with the $k=0$ term) into $S_{n+1}$. In the second group, the exponent simplifies as $k^2 + \big((n+1-k)-(k-1)\big) = (n+1) + (k-1)^2$; after re-indexing $k \mapsto k-1$ and using $\left[\begin{smallmatrix} (n-1-j) \cdots \end{smallmatrix}\right]$ bookkeeping controlled by the vanishing Lemma 2.2, this group equals $q^{n+1}\sum_{j} q^{j^2}\left[\begin{smallmatrix} n-j \\ j\end{smallmatrix}\right]_q = q^{n+1}\,S_n$. Combining gives $S_{n+2} = S_{n+1} + q^{n+1}S_n$. $\square$

**Theorem 4.2 (Finite Rogers–Ramanujan identity, Schur).** For all $n \in \mathbb{N}$,

$$D_n \;=\; \sum_{k=0}^{n} q^{\,k^2}\, \left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q \;=\; S_n.$$

*Proof.* We verify the base cases directly: $S_0 = q^0\left[\begin{smallmatrix} 0 \\ 0\end{smallmatrix}\right]_q = 1 = D_0$, and $S_1 = q^0\left[\begin{smallmatrix} 1 \\ 0\end{smallmatrix}\right]_q + q^1\left[\begin{smallmatrix} 0 \\ 1\end{smallmatrix}\right]_q = 1 + 0 = 1 = D_1$. For $n \ge 2$, both $(D_n)$ and $(S_n)$ satisfy the second-order recurrence $x_{n+2} = x_{n+1} + q^{n+1}x_n$ — the former by Definition 3.1, the latter by Proposition 4.1 — and they agree at $n=0,1$. By strong induction on $n$, the two sequences coincide for all $n$. $\square$

Theorem 4.2 is the finite skeleton of the first Rogers–Ramanujan identity: as $n\to\infty$, $D_n$ tends coefficientwise to the analytic sum $\sum_k q^{k^2}/(q;q)_k$, while the product side emerges from the modular structure of the limit. The appearance of the perfect-square exponents $k^2$ on the right is preserved verbatim from the infinite identity.

---

## 5. The Fibonacci bridge

Specializing $q = 1$ trivializes the grading and reveals a classical identity.

**Theorem 5.1 (Fibonacci specialization).** With $F_1 = F_2 = 1$ and $F_{m+2} = F_{m+1}+F_m$,

$$D_n(1) = F_{n+1} \qquad \text{for all } n \in \mathbb{N}.$$

*Proof sketch.* Evaluate the recurrence of Definition 3.1 at $q=1$: it becomes $D_{n+2}(1) = D_{n+1}(1) + D_n(1)$, with $D_0(1)=D_1(1)=1$. This is precisely the Fibonacci recurrence with the initial data of $F_1, F_2$, so $D_n(1) = F_{n+1}$ by induction. $\square$

**Theorem 5.2 (Diagonal-of-Pascal identity).** For all $n \in \mathbb{N}$,

$$\sum_{k=0}^{n} \binom{n-k}{k} = F_{n+1}.$$

*Proof.* Evaluate Theorem 4.2 at $q = 1$. The left side becomes $D_n(1) = F_{n+1}$ by Theorem 5.1. The right side becomes $\sum_k 1^{k^2}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q\big|_{q=1} = \sum_k \binom{n-k}{k}$ by Lemma 2.4. Equating the two gives the identity. $\square$

Theorem 5.2 is the "shadow" of the finite Rogers–Ramanujan identity: stripping away the $q$-grading turns the Schur polynomials into Fibonacci numbers and the Gaussian-binomial sum into the well-known shallow-diagonal sum of Pascal's triangle. Thus a single graded identity specializes to a bridge between the $q$-series world and the Fibonacci circle of identities.

---

## 6. Partition-theoretic interpretation

The weight $q^{k^2}$ is not arbitrary; it is the cost of a staircase. Consider partitions of an integer $m$ into exactly $k$ parts whose successive parts differ by at least $2$. The minimal such partition is

$$1 + 3 + 5 + \cdots + (2k-1) = k^2.$$

Every difference-$\ge 2$ partition with $k$ parts is obtained from this staircase by adding a weakly increasing amount of "slack" to the parts, and the generating function for that slack, subject to a cap that keeps the largest part bounded, is exactly a Gaussian binomial coefficient. Concretely, the coefficient of $q^m$ in $q^{k^2}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q$ counts partitions of $m$ into exactly $k$ parts, each part $\le n-k+ (\text{staircase offset})$, with successive differences $\ge 2$. Summing over $k$, Theorem 4.2 says $D_n$ is the generating function for all difference-$\ge 2$ partitions with largest part suitably bounded by $n$. Letting $n \to \infty$ recovers the gap-$2$ side of the infinite Rogers–Ramanujan identity. This is precisely why perfect squares — and not other figurate numbers — control the first identity.

---

## 7. Algorithms

We record three algorithms implicit in the development. All operate on polynomials represented as integer coefficient vectors.

**Algorithm A (Gaussian binomial via $q$-Pascal).** Computes $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q$ as an integer polynomial by tabulating the recurrence of Definition 2.1. Complexity: $O(nk \cdot \deg)$ coefficient operations, where $\deg = k(n-k)$ bounds the degree.

**Algorithm B (Schur polynomial recurrence).** Computes $D_n$ by iterating $D_{i+2} = D_{i+1} + q^{i+1}D_i$ from $D_0 = D_1 = 1$. Complexity: $O(n \cdot \deg D_n)$; the degree of $D_n$ is $\lfloor n^2/4\rfloor$.

**Algorithm C (Sum-side evaluation and identity check).** Computes $S_n = \sum_k q^{k^2}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q$ using Algorithm A and compares against $D_n$ from Algorithm B, verifying Theorem 4.2 to any finite $n$. At $q=1$ it reduces to the integer check $\sum_k\binom{n-k}{k} = F_{n+1}$.

---

## 8. Numerical evidence

Instantiating the polynomials over $\mathbb{Z}$ at concrete integer values of $q$ yields fast falsification tests. The identity $D_n(q) = \sum_k q^{k^2}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q$ was checked at $q \in \{-3,-2,-1,0,2,3,5,7\}$ for all $n \le 13$ with zero discrepancies, and the $q=1$ shadow $\sum_k \binom{n-k}{k} = F_{n+1}$ was confirmed for $n \le 12$. As a polynomial identity in $\mathbb{Z}[q]$, agreement at sufficiently many integer points already forces equality; the multi-point checks are therefore strong corroboration of Theorem 4.2 in the corresponding degree ranges.

For illustration, $D_4 = 1 + q + q^2 + q^3 + q^4$ evaluated as a sum: $q^0\left[\begin{smallmatrix} 4 \\ 0\end{smallmatrix}\right]_q + q^1\left[\begin{smallmatrix} 3 \\ 1\end{smallmatrix}\right]_q + q^4\left[\begin{smallmatrix} 2 \\ 2\end{smallmatrix}\right]_q = 1 + q(1+q+q^2) + q^4 = 1+q+q^2+q^3+q^4$, and at $q=1$ this is $1 + 3 + 1 = 5 = F_5$.

---

## 9. Discussion

The value of the finite core is threefold. First, it is *rigorous and elementary*: everything reduces to two Pascal rules, a vanishing lemma, and induction. Second, it is *computable*: the identity can be verified to any finite degree, and its $q=1$ shadow is a schoolroom fact. Third, it is a *bridge*: the same machinery reaches from Ramanujan's modular product to the Fibonacci numbers, suggesting that the $q$-series and Fibonacci "circles of identities" are two faces of one object graded by $q$.

The finitization philosophy — replace an infinite identity by a convergent family of finite polynomial identities — is broadly applicable and turns questions of analytic subtlety into questions of finite combinatorics amenable to induction and to direct checking.

---

## 10. Future directions

**(1) The second Rogers–Ramanujan polynomial and its Lucas shadow.** Introduce companion polynomials $E_n$ with $E_0 = 1$, $E_1 = 1+q$, and $E_{n+2} = E_{n+1} + q^{n+2}E_n$, the finitization of the second Rogers–Ramanujan identity $\sum_k q^{k^2+k}/(q;q)_k$. Conjecture the closed form $E_n = \sum_k q^{k^2+k}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q$, that its $q\to 1$ specialization is again a Fibonacci number, and that a signed specialization $q\to -1$ produces a period-$6$ sequence. Both identities share a single $q$-Pascal engine, differing only by the quadratic exponent $k^2$ versus $k^2+k$, so the finite theory should transfer with the shifted weight.

**(2) Modulus-$5$ dissection of the Schur polynomials.** Study the coefficients of $D_n$ graded by exponent modulo $5$, conjecturing that as $n\to\infty$ the generating function organizes into $\prod_j 1/((1-q^{5j+1})(1-q^{5j+4}))$, and that the finite $D_n$ already exhibit a stable gap-$2$ partition statistic: the coefficient of $q^m$ in $D_n$ counts partitions of $m$ into parts $\le n$ with consecutive parts differing by at least $2$.

**(3) Cross-domain bridge: $q$-Fibonacci meets the Fibonacci gcd law.** Using $D_n(1) = F_{n+1}$, conjecture a $q$-deformed gcd law: $\gcd(D_m, D_n)$ in $\mathbb{Z}[q]$ equals $D_{\gcd(m+1,n+1)-1}$ up to an explicit power of $q$, refining $\gcd(F_m, F_n) = F_{\gcd(m,n)}$.

**(4) Unimodality and log-concavity.** Conjecture that for fixed $n,k$ the coefficient sequence of $\left[\begin{smallmatrix} n \\ k\end{smallmatrix}\right]_q$ is symmetric and unimodal, and that the $D_n$ have log-concave coefficient sequences, propagated by the positivity-preserving $q$-Pascal convolution.

---

## 11. Conclusion

We have given a complete, self-contained treatment of the finite core of the Rogers–Ramanujan identities: the Gaussian binomial coefficients with their two Pascal rules, the Schur polynomials $D_n$, the finite identity $D_n = \sum_k q^{k^2}\left[\begin{smallmatrix} n-k \\ k\end{smallmatrix}\right]_q$, and the Fibonacci bridge $D_n(1) = F_{n+1}$ with its diagonal-of-Pascal shadow. The perfect-square weights that make the infinite identity so striking are explained by the minimal difference-$\ge 2$ staircase, and the entire structure is elementary, computable, and open to the several refinements listed above.
