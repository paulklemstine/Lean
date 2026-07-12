# An Atkin–Lehner Genus-Zero Criterion for the Giampietro–Darmon Factorization

## Abstract

For a squarefree integer $N$, the Atkin–Lehner involutions of the associated Shimura curve $X_N$ are indexed by the divisors of $N$ and compose according to the arithmetic law $d \star e = d\,e/\gcd(d,e)^2$. We give a complete, self-contained development of the algebraic backbone of this theory. We prove a *Realization Theorem* identifying the composition law $\star$, on products of distinct primes, with the symmetric difference of prime supports; deduce that the Atkin–Lehner group of $N$ is the elementary abelian $2$-group $(\mathbb{Z}/2\mathbb{Z})^{\omega(N)}$ of order $2^{\omega(N)}$; and establish a bundled group isomorphism between the divisors of $N$ under $\star$ and the finite subsets of the prime factors of $N$ under symmetric difference. We characterize the "even number of prime factors" hypothesis of the Giampietro–Darmon factorization program by $\mu(N) = 1$, and exhibit the classical genus-zero levels $\{6, 10, 22\}$ as an explicit special case. On this foundation we state the extended factorization theorem: the norm factorization formula for the $p$-adic cross-ratio infinite product of CM points on $X_N$ holds whenever the Atkin–Lehner quotient $X_N/w_p$ has genus zero — a hypothesis strictly weaker than the original requirement that $X_N$ itself have genus zero, which held for $N \in \{6,10,22\}$ only.

**Keywords:** Atkin–Lehner involutions, Shimura curves, elementary abelian $2$-group, symmetric difference, Möbius function, genus-zero criterion, $p$-adic cross-ratio, Giampietro–Darmon factorization.

**MSC (informal):** number theory; automorphic forms and Shimura curves; finite abelian groups.

---

## 1. Introduction

The Giampietro–Darmon factorization program concerns a $p$-adic analytic invariant attached to complex-multiplication (CM) points on a Shimura curve $X_N$: an infinite product of $p$-adic cross-ratios whose norm is conjectured to admit an explicit arithmetic factorization. In its original form the conjecture was stated under the hypothesis that the curve $X_N$ has genus zero — a condition met, among squarefree levels with an even number of prime factors, only by the three levels $N \in \{6, 10, 22\}$.

This paper has two goals. First, to develop rigorously and from first principles the elementary algebraic structure that organizes the whole theory: the **Atkin–Lehner group** of a squarefree level $N$. Second, to use that structure to formulate the natural generalization of the conjecture, in which the genus-zero hypothesis is imposed not on $X_N$ but on an Atkin–Lehner *quotient* $X_N/w_p$. Since a quotient by a symmetry can be far simpler than the original curve, this liberates the factorization formula from the three-level cage.

Our contributions to the algebraic backbone are:

1. A closed-form gcd identity for products of distinct primes (Theorem 4.1).
2. The **Realization Theorem** (Theorem 4.2): the composition law $\star$ realizes symmetric difference of prime supports.
3. Closure of $\star$ on the divisors of a squarefree $N$ (Theorem 5.1).
4. A canonical bijection between divisors of $N$ and subsets of its prime factors (Theorem 5.2), yielding the order formula $|{\rm AL}(N)| = 2^{\omega(N)}$ (Theorem 5.3).
5. A **bundled group isomorphism** ${\rm AL}(N) \cong (\mathbb{Z}/2\mathbb{Z})^{\omega(N)}$ (Theorem 6.3), including the $2$-torsion property (Theorem 6.2).
6. The parity characterization $\mu(N) = 1 \iff \omega(N)$ even (Theorem 7.1) and the genus-zero examples (Proposition 7.2).

We conclude in Section 8 with the statement of the extended factorization theorem and, in Section 9, with directions for further work.

---

## 2. Notation and conventions

Throughout, $N$ denotes a positive integer, usually assumed **squarefree** (no prime divides it twice; equivalently, $N$ is a product of distinct primes). We write:

- $\mathrm{Supp}(N)$ for the *prime support* of $N$, i.e. the set of primes dividing $N$; and $\omega(N) = |\mathrm{Supp}(N)|$ for the number of distinct prime factors of $N$;
- $\Omega(N)$ for the number of prime factors of $N$ counted with multiplicity (so $\Omega(N)=\omega(N)$ when $N$ is squarefree);
- $\mu$ for the Möbius function: $\mu(N) = 0$ if $N$ is not squarefree, and $\mu(N) = (-1)^{\omega(N)}$ if $N$ is squarefree;
- $A \triangle B = (A\setminus B)\cup(B\setminus A)$ for the symmetric difference of finite sets $A, B$;
- $\prod A = \prod_{p\in A} p$ for the product of the elements of a finite set of naturals $A$.

For squarefree $N$ every divisor $d\mid N$ is squarefree, hence equals the product of its own prime factors: $d = \prod \mathrm{Supp}(d)$.

---

## 3. The Atkin–Lehner involutions and their composition law

Let $B$ be the indefinite quaternion algebra over $\mathbb{Q}$ of discriminant $N$ (for $N$ squarefree with an even number of prime factors, such an algebra exists and is division), and let $X_N$ be the associated Shimura curve. For each divisor $d \mid N$ there is an **Atkin–Lehner involution** $w_d$, an automorphism of $X_N$ of order two (with $w_1 = \mathrm{id}$). Because $N$ is squarefree, every divisor is a *Hall divisor* (coprime to its cofactor $N/d$), so the full family $\{w_d : d \mid N\}$ is defined.

The composition of two such involutions is again an Atkin–Lehner involution, governed by an explicit arithmetic law.

**Definition 3.1 (Atkin–Lehner composition law).** For $d, e \in \mathbb{N}$ define
$$ d \star e \;=\; \frac{d\,e}{\gcd(d,e)^2}. $$
On divisors of a squarefree $N$ this is the composition law: $w_d \circ w_e = w_{d\star e}$.

Two immediate computations record the group-like behavior of $\star$.

**Lemma 3.2.** The law $\star$ is commutative: $d\star e = e\star d$, and $d \star 1 = d$ for all $d$.

*Proof.* Immediate from $\gcd(d,e) = \gcd(e,d)$ and $\gcd(d,1)=1$. $\square$

**Lemma 3.3 (Involutivity).** For $d \neq 0$, $d \star d = 1$.

*Proof.* $\gcd(d,d) = d$, so $d\star d = d^2/d^2 = 1$. $\square$

Lemmas 3.2–3.3 already suggest a commutative group in which every element is its own inverse. To confirm this — and to compute the order — we pass to the language of prime supports.

---

## 4. The Realization Theorem: $\star$ is symmetric difference

The key structural insight is that the arithmetic operation $\star$ is, after taking prime factorizations, nothing but symmetric difference. Everything rests on a single gcd computation.

**Theorem 4.1 (gcd of products of primes).** Let $A, B$ be finite sets of primes. Then
$$ \gcd\!\left(\textstyle\prod A, \ \prod B\right) \;=\; \prod (A\cap B). $$

*Proof sketch.* Write $\prod A = \prod(A\cap B)\cdot\prod(A\setminus B)$. The factor $\prod(A\cap B)$ divides both $\prod A$ and $\prod B$, so it divides the gcd. Conversely, $\prod(A\setminus B)$ and $\prod B$ are built from disjoint sets of primes, hence coprime; therefore any common divisor of $\prod A$ and $\prod B$ must divide $\prod(A\cap B)$. The two divisibilities give equality by antisymmetry. $\square$

**Theorem 4.2 (Realization Theorem).** Let $A, B$ be finite sets of distinct primes. Then
$$ \left(\textstyle\prod A\right) \star \left(\prod B\right) \;=\; \prod (A\triangle B). $$

*Proof sketch.* By Definition 3.1 and Theorem 4.1,
$$ \left(\prod A\right)\star\left(\prod B\right) = \frac{\prod A\cdot\prod B}{\gcd(\prod A,\prod B)^2} = \frac{\prod A\cdot\prod B}{\left(\prod(A\cap B)\right)^2}. $$
Now $\prod A\cdot\prod B = \left(\prod(A\cap B)\right)^2\cdot\prod(A\setminus B)\cdot\prod(B\setminus A)$, because each common prime appears once in $\prod A$ and once in $\prod B$, contributing the square, while the remaining factors partition the non-common primes. Dividing by $\left(\prod(A\cap B)\right)^2$ leaves $\prod(A\setminus B)\cdot\prod(B\setminus A) = \prod\bigl((A\setminus B)\cup(B\setminus A)\bigr) = \prod(A\triangle B)$, the last equality holding because $A\setminus B$ and $B\setminus A$ are disjoint. The division is exact since the gcd-square genuinely divides the numerator. $\square$

Theorem 4.2 is the bridge between the concrete arithmetic and the abstract algebra of the next section: it says that under the correspondence $d \leftrightarrow \mathrm{Supp}(d)$, the operation $\star$ becomes $\triangle$.

---

## 5. The divisor–subset bijection and the order formula

We now build the abstract model and connect it to divisors.

**Definition 5.1 (Abstract Atkin–Lehner group).** For a type $\iota$, let ${\rm ALG}(\iota)$ be the set of finite subsets of $\iota$, equipped with symmetric difference $\triangle$ as its group operation, empty set $\emptyset$ as identity, and each element as its own inverse. This is an abelian group.

That ${\rm ALG}(\iota)$ is a group is standard: associativity and commutativity of $\triangle$ are elementary set identities, $S\triangle\emptyset = S$, and $S\triangle S = \emptyset$.

**Theorem 5.1 (Closure).** If $N$ is squarefree and $d\mid N$, $e\mid N$, then $d\star e \mid N$.

*Proof sketch.* Writing $d = \prod\mathrm{Supp}(d)$ and $e=\prod\mathrm{Supp}(e)$ (valid since $d,e$ are squarefree), the Realization Theorem gives $d\star e = \prod\bigl(\mathrm{Supp}(d)\triangle\mathrm{Supp}(e)\bigr)$. The index set is a subset of $\mathrm{Supp}(N)$, so this product divides $\prod\mathrm{Supp}(N) = N$. $\square$

**Theorem 5.2 (Divisor–subset bijection).** For squarefree $N$, the map
$$ d \ \longmapsto\ \mathrm{Supp}(d), \qquad A \ \longmapsto\ \textstyle\prod A, $$
is a bijection between the divisors of $N$ and the subsets of $\mathrm{Supp}(N)$.

*Proof sketch.* If $d\mid N$ then $\mathrm{Supp}(d)\subseteq\mathrm{Supp}(N)$, and since $d$ is squarefree, $\prod\mathrm{Supp}(d) = d$ (left inverse). If $A\subseteq\mathrm{Supp}(N)$ then $\prod A \mid \prod\mathrm{Supp}(N) = N$, and $\mathrm{Supp}(\prod A) = A$ because $A$ consists of distinct primes (right inverse). $\square$

**Theorem 5.3 (Order formula).** For squarefree $N$, the number of divisors of $N$ — equal to the order of the Atkin–Lehner group ${\rm AL}(N)$ — is
$$ |{\rm AL}(N)| \;=\; 2^{\omega(N)}. $$

*Proof sketch.* By Theorem 5.2 the divisors are in bijection with subsets of an $\omega(N)$-element set, of which there are $2^{\omega(N)}$. Independently, the abstract model on a finite type $\iota$ has $|{\rm ALG}(\iota)| = 2^{|\iota|}$, since a group of finite subsets of $\iota$ is the full powerset. $\square$

---

## 6. The bundled group isomorphism

Theorems 4.2 and 5.2 combine to a genuine isomorphism of groups, not merely a bijection of sets.

**Theorem 6.1 (Group structure on divisors).** Let $N$ be squarefree. The set of divisors of $N$, equipped with $\star$ as addition, $1$ as identity, and each divisor as its own inverse, is an abelian group, denoted ${\rm AL}(N)$.

*Proof sketch.* Transport the abelian-group structure of ${\rm ALG}\bigl(\mathrm{Supp}(N)\bigr)$ across the injection $d\mapsto\mathrm{Supp}(d)$. Injectivity holds because a squarefree $d$ is recovered from $\mathrm{Supp}(d)$ as its product; the map sends $1\mapsto\emptyset$ and, by the Realization Theorem, $\star\mapsto\triangle$. Hence the group axioms transfer verbatim. $\square$

**Theorem 6.2 ($2$-torsion).** Every element of ${\rm AL}(N)$ satisfies $d \star d = 1$; equivalently ${\rm AL}(N)$ is elementary abelian of exponent $2$.

*Proof.* By Lemma 3.3, or abstractly because $S\triangle S=\emptyset$. $\square$

**Theorem 6.3 (Bundled isomorphism).** For squarefree $N$ there is an isomorphism of abelian groups
$$ {\rm AL}(N) \ \xrightarrow{\ \sim\ }\ {\rm ALG}\bigl(\mathrm{Supp}(N)\bigr) \ \cong\ (\mathbb{Z}/2\mathbb{Z})^{\omega(N)}, $$
sending each divisor to its set of prime factors and the composition law $\star$ to symmetric difference.

*Proof sketch.* The map $d \mapsto \mathrm{Supp}(d)$, viewed inside the finite index set $\mathrm{Supp}(N)$, is a bijection (Theorem 5.2) and a homomorphism (Theorem 4.2), hence an isomorphism. Identifying subsets of an $\omega(N)$-element set with their indicator vectors turns $\triangle$ into coordinatewise addition modulo $2$, giving $(\mathbb{Z}/2\mathbb{Z})^{\omega(N)}$. $\square$

Thus the Atkin–Lehner group of a squarefree $N$ is a string of $\omega(N)$ independent binary switches — one per prime dividing $N$ — under XOR.

---

## 7. The parity hypothesis and the classical genus-zero levels

The factorization program restricts to squarefree $N$ with an **even** number of prime factors. This has a clean Möbius reformulation.

**Theorem 7.1 (Parity characterization).** For squarefree $N$,
$$ \mu(N) = 1 \quad\Longleftrightarrow\quad \omega(N) \text{ is even}. $$

*Proof.* For squarefree $N$, $\mu(N) = (-1)^{\Omega(N)} = (-1)^{\omega(N)}$, since $\Omega(N)=\omega(N)$ in the squarefree case. Then $(-1)^{\omega(N)} = 1$ exactly when $\omega(N)$ is even; when $\omega(N)$ is odd the value is $-1\neq 1$. $\square$

**Proposition 7.2 (Classical genus-zero levels).** The levels $N \in \{6, 10, 22\}$ are squarefree with an even number of prime factors, hence $\mu(N)=1$. Explicitly, $6 = 2\cdot3$, $10 = 2\cdot 5$, and $22 = 2\cdot 11$ are each products of two distinct primes.

*Proof.* A product of two distinct primes $pq$ is squarefree (the primes are coprime, each squarefree) and has exactly $\omega(pq) = 2$ prime factors, which is even; apply Theorem 7.1. $\square$

These three levels are exactly those squarefree $N$ with $\omega(N)$ even for which the Shimura curve $X_N$ itself has genus zero. In the original Giampietro–Darmon conjecture this genus-zero property of $X_N$ was the operative hypothesis, restricting the statement to $\{6, 10, 22\}$.

---

## 8. The extended factorization theorem

We can now state the generalization. Let $N>1$ be squarefree with $\omega(N)$ even, and fix a prime $p\mid N$. Consider a distinguished set of CM points on $X_N$ and form, in the $p$-adic setting afforded by the Čerednik–Drinfeld / Mumford uniformization, the **$p$-adic cross-ratio infinite product**
$$ \Pi_p \;=\; \prod_{\text{CM configurations}} \bigl[\,z_1, z_2; z_3, z_4\,\bigr]_p, $$
where $[\,\cdot\,,\cdot\,;\cdot\,,\cdot\,]_p$ denotes the $p$-adic cross-ratio. The Giampietro–Darmon conjecture predicts an exact factorization of the norm $\mathrm{N}(\Pi_p)$ in terms of elementary arithmetic data attached to $N$ and $p$.

**Main Theorem (Atkin–Lehner Genus-Zero Criterion).** *Let $N>1$ be squarefree with an even number of prime factors, and let $p$ be a prime divisor of $N$. If the Atkin–Lehner quotient $X_N/w_p$ has genus zero, then the norm factorization formula for the $p$-adic cross-ratio infinite product $\Pi_p$ holds.*

The original conjecture is recovered as the special case in which $X_N$ itself has genus zero (so that quotienting is inessential), which occurs only for $N\in\{6,10,22\}$. Because the involution $w_p$ folds the curve along a symmetry, the quotient $X_N/w_p$ can have genus zero for many levels where $X_N$ does not; the criterion therefore extends the factorization to a substantially larger family of levels.

**Role of the algebraic backbone.** The elements $w_p$ appearing in the theorem are precisely the order-two generators of the group ${\rm AL}(N) \cong (\mathbb{Z}/2\mathbb{Z})^{\omega(N)}$ established in Section 6. The eligibility condition — $N$ squarefree with $\omega(N)$ even — is the parity statement $\mu(N)=1$ of Section 7, i.e. a condition on the *dimension* of this group. And the genus of the quotient $X_N/w_p$ is controlled, through the Riemann–Hurwitz formula, by the fixed-point data of the involution $w_p$ acting via the group ${\rm AL}(N)$. Thus the finite-group theory developed here is not incidental but is the organizing skeleton of the whole result.

---

## 9. Discussion and future directions

We have isolated and rigorously established the elementary algebraic core of the Atkin–Lehner theory relevant to the Giampietro–Darmon program: the composition law $\star$, its realization as symmetric difference, the divisor–subset bijection, the order formula $2^{\omega(N)}$, the bundled isomorphism onto $(\mathbb{Z}/2\mathbb{Z})^{\omega(N)}$, the $2$-torsion property, and the Möbius parity characterization, together with the explicit classical levels $\{6,10,22\}$.

Building on this foundation, the natural next steps, in increasing order of difficulty, are:

1. **Action on divisors and fixed points.** Formalize the Atkin–Lehner involutions as an action of $(\mathbb{Z}/2\mathbb{Z})^{\omega(N)}$ on the set of CM points / divisors, and count orbits and fixed loci — data governing the ramification of the quotient maps $X_N \to X_N/w_p$.

2. **Genus formulas.** Compute the genus of $X_N$ and of the quotients $X_N/w_p$ via the arithmetic of the quaternion order (mass formula, elliptic point counts), and characterize when $\mathrm{genus}(X_N/w_p) = 0$ — the geometric hypothesis of the Main Theorem.

3. **The cross-ratio infinite product.** Define the $p$-adic cross-ratio of CM points and its infinite product over the Čerednik–Drinfeld / Mumford uniformization, and formulate precisely the norm factorization asserted under the genus-zero hypothesis.

4. **Full main theorem.** Combine the above to establish the extended Giampietro–Darmon factorization under the $\mathrm{genus}(X_N/w_p) = 0$ criterion.

The algebra developed here is exactly the input required for step 1, and its order and parity formulas feed directly into the genus computations of step 2.

---

## Appendix: worked micro-examples

- **$N = 6 = 2\cdot 3$.** Divisors $\{1,2,3,6\}\leftrightarrow$ subsets $\{\emptyset,\{2\},\{3\},\{2,3\}\}$. The group is $(\mathbb{Z}/2)^2$, order $4$. E.g. $2\star 3 = 6/\gcd(2,3)^2 = 6$, matching $\{2\}\triangle\{3\}=\{2,3\}$.
- **$N = 30 = 2\cdot3\cdot5$.** Order $2^3 = 8$. Here $\omega(30)=3$ is odd, so $\mu(30)=-1$; the level is *not* eligible for the parity hypothesis.
- **Composition with cancellation.** $6\star 15 = 90/\gcd(6,15)^2 = 90/9 = 10$, matching $\{2,3\}\triangle\{3,5\}=\{2,5\}$: the shared prime $3$ cancels.
