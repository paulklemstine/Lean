# Full Pinning at Degree Seven: The Abelian Splitting-Type Ladder, Its Three Channels, and Primality as the Exact Sufficient-Statistic Condition

**Author.** Aristotle

**Date.** 2026-09-04

---

## Abstract

We study the information carried by residue data about the splitting behaviour of
primes in cyclic number fields of prime degree, and about the splitting behaviour
of the two prime factors of a semiprime. Fix a prime degree $q$ and a prime
conductor $f \equiv 1 \pmod q$, and let $K_q \subset \mathbb{Q}(\zeta_f)$ be the
cyclic subfield of degree $q$, i.e. the fixed field of the group of $q$-th powers
in $(\mathbb{Z}/f)^\times$. We prove that the residue degree $T(p)$ of an
unramified prime $p$ takes only the values $1$ and $q$, with density exactly
$1/q$ for the value $1$; that the type entropy is
$H(T) = \log_2 q - \frac{q-1}{q}\log_2(q-1)$, *independent of the conductor*; and
that the Frobenius class of $p$ in $\mathrm{Gal}(K_q/\mathbb{Q})$ pins $T(p)$
completely, so the corresponding channel attains its capacity,
$I(\text{Frobenius class}; T) = H(T)$.

The degree-seven rung, realised by the septic subfield of
$\mathbb{Q}(\zeta_{29})$, is worked out in full: the splitting criterion is
$p \bmod 29 \in \{1,12,17,28\}$, the densities are $1/7$ and $6/7$, and
$H(T) = \log_2 7 - \frac{6}{7}\log_2 6 = 0.5916727\ldots$ bits, certified between
$0.5916$ and $0.5918$. Orthogonally, the quartic character mod $29$ — the
$C_4$-component of $C_{28} \cong C_4 \times C_7$ — carries exactly zero
information about the septic type.

For semiprimes we introduce three channels of a degree $n$, all with the residue
of the product as observation: the *type-pair channel* $I_{\mathrm{pair}}(n)$,
the *split-count channel* $I_{\mathrm{split}}(n)$, and the *OR channel* $G(n)$.
At every prime degree the split count is a sufficient statistic,
$I_{\mathrm{pair}}(q) = I_{\mathrm{split}}(q)$, and the OR coarsening satisfies an
exact data-processing identity $I_{\mathrm{split}}(q) - G(q) = H(S) - H(O)$, hence
$G(q) \le I_{\mathrm{split}}(q)$. At degree seven,
$$I_{\mathrm{split}}(7) = \log_2 7 + \tfrac{1}{49}\big(30\log_2 5 - 78\log_2 3 - 78\big) = 0.1141053\ldots,$$
$$G(7) = \log_2 7 + \tfrac{1}{49}\big(30\log_2 5 - 66\log_2 3 - 13\log_2 13 - 54\big) = 0.0103060\ldots,$$
and $11\,G(7) < I_{\mathrm{split}}(7)$: the single-bit coarsening destroys more
than ninety percent of the channel. Finally we settle the first composite
degree: $I_{\mathrm{pair}}(4) = 5/4$ exactly, while
$I_{\mathrm{split}}(4) = \frac{19}{8} - \frac{21}{16}\log_2 3 = 0.2947367\ldots$,
so the split count destroys more than three quarters of the channel and, unlike
the type pair, respects the one-bit cap. The combinatorial mechanism is
identified exactly: the split count induces the same partition of the exponent
box as the full type pair **if and only if the degree is prime**.

**Keywords.** cyclotomic fields, splitting laws, Frobenius, residue degree,
mutual information, sufficient statistic, semiprimes, power residues, entropy.

---

## 1. Introduction

### 1.1 The question

Let $K/\mathbb{Q}$ be an abelian number field and $p$ an unramified rational
prime. The *splitting type* of $p$ in $K$ — how the ideal $(p)$ decomposes — is a
global invariant, yet by class field theory it is determined by a purely local
datum, the residue of $p$ modulo the conductor. This is the reciprocity miracle:
a question about ideal factorisation in a possibly large field is answered by a
lookup table on residue classes.

Information theory offers a way to *quantify* the miracle. Treat the splitting
type $T$ as a random variable over a uniformly random Frobenius class, treat the
residue datum as an observation $Y$, and ask for the mutual information $I(Y;T)$
in bits. Reciprocity says $I(Y;T) = H(T)$ when $Y$ is the full Frobenius class:
the channel is *fully pinned*, meaning zero conditional entropy and capacity
attained. But once we perturb the question — coarsen the observation, or replace
a single prime by a product of two primes, or coarsen the hidden variable to a
count — the mutual information drops, and by how much becomes a well-posed
arithmetic problem with, as it turns out, exact answers.

This paper carries out that programme for a ladder of cyclic fields indexed by
prime degree $q$, closing the degree-seven rung and settling the first composite
degree.

### 1.2 Results

1. **Universality of the prime rungs (Theorem 4.1–4.3).** For prime $q$ and
   prime conductor $f \equiv 1 \pmod q$: splitting density $1/q$, type entropy
   $H(T) = \log_2 q - \frac{q-1}{q}\log_2(q-1)$ independent of $f$, and full
   pinning by the Frobenius class. Full pinning in fact holds for *every*
   conductor and *every* degree, prime or not.
2. **The degree-seven rung (Theorems 3.2, 3.4, 3.6, 3.7).** With $f = 29$: a
   prime splits completely in the septic subfield iff
   $p \bmod 29 \in \{1,12,17,28\}$, iff $\mathrm{dlog}(p) \equiv 0 \pmod 7$;
   $H(T) = 0.5916727\ldots$ bits with certified bracket $(0.5916, 0.5918)$; the
   quartic character carries zero information; and the semiprime split count
   obeys $\mathrm{Bin}(2, 1/7)$ exactly, with counts $(36, 12, 1)$ out of $49$.
3. **The three semiprime channels (Theorems 5.4, 5.7, 5.8, 6.1, 6.2).** At prime
   degree the split count is a sufficient statistic; the OR read-out has the same
   conditional entropy as the split count, giving an exact channel-difference
   identity and hence data processing; closed forms for $I_{\mathrm{split}}(q)$
   and $G(q)$ at every prime degree, evaluated at $q=7$.
4. **Numerical audit (Section 7).** The anchor $0.0103$ is confirmed as $G(7)$
   to within $5\times 10^{-5}$; the anchor $0.1161$ for the split-count channel
   is falsified, the true value being $0.1141053\ldots$; and the figure $0.116$,
   previously attributed to degree eleven, is more than thirty times closer to
   the degree-seven value.
5. **Composite degree and primality (Theorems 8.1–8.5).** $I_{\mathrm{pair}}(4) =
   5/4 > 1 > I_{\mathrm{split}}(4) = \frac{19}{8} - \frac{21}{16}\log_2 3$, and
   the split count is a sufficient statistic at the partition level exactly when
   the degree is prime.

### 1.3 Method

Two techniques recur. First, a *partition principle*: the counting entropy of a
read-out depends only on the partition into fibres that the read-out induces, and
the conditional entropy only on the partitions induced inside each fibre of the
side channel. This lets us prove equalities between channels defined by
syntactically unrelated read-outs, with no explicit recoding map.

Second, *certified transcendental brackets by integer comparison*. Every
numerical claim of the form $\alpha < c < \beta$ for a logarithmic constant $c$
is reduced to an inequality between whole numbers: for instance
$H(T) > 0.5916$ at degree $7$ follows from
$2^{8283}\cdot 6^{12000} < 7^{14000}$, and $I_{\mathrm{split}}(7) > 0.1140$ from
$2^{16718}\cdot 3^{15600} < 7^{9800}\cdot 5^{6000}$. Nothing depends on
floating-point evaluation.

---

## 2. The model

### 2.1 Fields, Frobenius, and the type

Let $f$ be a prime and let $\mathbb{Q}(\zeta_f)$ be the $f$-th cyclotomic field,
with $\mathrm{Gal}(\mathbb{Q}(\zeta_f)/\mathbb{Q}) \cong (\mathbb{Z}/f)^\times$,
cyclic of order $f-1$. For an integer $q \ge 2$ let
$$P_{f,q} := \big((\mathbb{Z}/f)^\times\big)^q = \{u^q : u \in (\mathbb{Z}/f)^\times\}$$
be the subgroup of $q$-th powers, and let $K_q$ be its fixed field. When
$q \mid f-1$, the group $(\mathbb{Z}/f)^\times / P_{f,q}$ is cyclic of order $q$
and $K_q/\mathbb{Q}$ is cyclic of degree $q$.

**Definition 2.1 (residue degree).** For a unit $u \in (\mathbb{Z}/f)^\times$, the
*residue degree* is
$$T_{f,q}(u) := \mathrm{ord}\big(u P_{f,q}\big) \in \mathbb{Z}_{\ge 1},$$
the order of the class of $u$ in the quotient group. For a prime $p \nmid f$ we
write $T(p) := T_{f,q}(p \bmod f)$; this is the residue degree of any prime of
$K_q$ above $p$, and $T(p) = 1$ says that $p$ splits completely.

Two elementary facts are used repeatedly.

**Lemma 2.2.** $T_{f,q}(u) = 1$ if and only if $u \in P_{f,q}$, and
$T_{f,q}(u) \mid q$ for every $u$. Consequently, if $q$ is prime then
$T_{f,q}(u) \in \{1, q\}$ for every $u$ (*prime-degree dichotomy*). Moreover
$T_{f,q}$ is a class function: $T_{f,q}(uh) = T_{f,q}(u)$ for all $h \in P_{f,q}$.

*Proof.* Order one means the class is trivial, i.e. $u \in P_{f,q}$. Since
$u^q \in P_{f,q}$, the class of $u$ has order dividing $q$. For prime $q$ the
only divisors are $1$ and $q$. Multiplying by an element of $P_{f,q}$ does not
change the class. $\square$

### 2.2 Entropies

All entropies are in bits, computed with respect to the uniform (counting)
measure on a finite set $S$. For a read-out $g : S \to B$,
$$H_S(g) := -\sum_{b \in g(S)} \frac{|g^{-1}(b)|}{|S|}\log_2 \frac{|g^{-1}(b)|}{|S|},$$
and for a second read-out $k : S \to C$,
$$H_S(g \mid k) := \sum_{c \in k(S)} \frac{|k^{-1}(c)|}{|S|}\, H_{k^{-1}(c)}(g),
\qquad I_S(g;k) := H_S(g) - H_S(g \mid k).$$
For $0 \le m \le N$ we write $h(N,m)$ for the entropy of the two-cell partition
of sizes $m$ and $N-m$; thus $h(N,m) = h_2(m/N)$ with $h_2$ the binary entropy
function, and $h(cN, cm) = h(N,m)$ (*scale invariance*).

**Lemma 2.3 (partition principle).** Let $g : S \to B$ and $g' : S \to B'$ satisfy
$$\forall x, y \in S: \quad g(x) = g(y) \iff g'(x) = g'(y).$$
Then $H_S(g) = H_S(g')$. If, more weakly, the equivalence holds for all $x,y$ in
a common fibre of a third read-out $k$, then $H_S(g \mid k) = H_S(g' \mid k)$.

*Proof.* The hypothesis says the fibres of $g$ through each point coincide with
the fibres of $g'$ through that point, so the two multisets of fibre cardinalities
agree and the defining sums are termwise equal; the conditional statement is the
unconditional one applied inside each fibre of $k$. $\square$

Lemma 2.3 is stronger than the familiar "entropy is invariant under injective
recoding": the two read-outs need not be related by any map, only by their fibre
partitions.

**Lemma 2.4 (binary read-out).** If $g : S \to B$ takes only two values $v \neq w$,
then $H_S(g) = h(|S|, |g^{-1}(v)|)$.

**Lemma 2.5 (zero conditional entropy).** If $k(x) = k(y)$ implies $g(x) = g(y)$
for all $x,y \in S$, then $H_S(g \mid k) = 0$, hence $I_S(g;k) = H_S(g)$.

**Lemma 2.6 (coarsening).** For any $\varphi$, $H_S(\varphi \circ g) \le H_S(g)$.

---

## 3. The degree-seven rung: conductor 29

Let $q = 7$ and $f = 29$, so $(\mathbb{Z}/29)^\times \cong C_{28}$ and
$C_{28}/C_4 \cong C_7$: the septic subfield $K_7 \subset \mathbb{Q}(\zeta_{29})$
is the fixed field of the group of seventh powers, which has order $4$.

**Theorem 3.1 (two faces of the order-four subgroup).** For
$u \in (\mathbb{Z}/29)^\times$,
$$u \in P_{29,7} \iff u^4 = 1.$$

*Proof.* If $u = v^7$ then $u^4 = v^{28} = 1$ by Lagrange, since
$|(\mathbb{Z}/29)^\times| = 28$. Conversely, if $u^4 = 1$ then
$(u^3)^7 = u^{21} = (u^4)^5 \cdot u = u$, so $u$ is a seventh power. $\square$

Solving $x^4 = 1$ in $\mathbb{Z}/29$ gives $x \in \{1, 12, 17, 28\}$.

**Theorem 3.2 (degree-seven splitting criterion).** Let $p$ be a prime, $p \neq
29$. Then $p$ splits completely in the septic subfield of $\mathbb{Q}(\zeta_{29})$
— equivalently, the discrete logarithm of $p$ modulo $29$ is divisible by $7$ —
if and only if
$$p \bmod 29 \in \{1, 12, 17, 28\}.$$
Otherwise $T(p) = 7$.

*Proof.* Combine Lemma 2.2 (dichotomy, $q = 7$ prime), Lemma 2.2 (splitting iff
$q$-th power), Theorem 3.1, and the explicit list of fourth roots of unity mod
$29$. $\square$

For instance $41 \equiv 12$ splits completely, whereas $2$ is inert of degree
seven.

**Corollary 3.3 (densities).** Exactly $4$ of the $28$ Frobenius classes split
completely; the type densities are $1/7$ and $6/7$.

**Theorem 3.4 (type entropy).**
$$H(T) \;=\; h(28,4) \;=\; \log_2 7 - \tfrac{6}{7}\log_2 6 \;=\; 0.5916727\ldots
\text{ bits},$$
equivalently $7\,H(T) = \log_2\!\big(7^7/6^6\big)$, and
$$0.5916 < H(T) < 0.5918 .$$

*Proof.* The read-out $T$ is binary by Lemma 2.2, so Lemma 2.4 with $|S| = 28$,
$|T^{-1}(1)| = 4$ gives $H(T) = h(28,4) = h(7,1)$ by scale invariance, which is
$\log_2 7 - \frac{6}{7}\log_2 6$. Exponentiating $7H(T) = \log_2(7^7/6^6)$, the
bracket is equivalent to
$$2^{8283}\cdot 6^{12000} < 7^{14000} < 2^{8284}\cdot 6^{12000},$$
two comparisons of integers, obtained by raising $7^7/6^6$ to the power $2000$.
$\square$

**Theorem 3.5 (full pinning at degree seven).** Let $Q(u) := u\,\{1,12,17,28\}$
denote the coset of $u$ modulo the seventh powers — a datum with only $7$ values,
strictly coarser than $u$ itself. Then
$$H(T \mid Q) = 0 \qquad\text{and}\qquad I(Q; T) = H(T) = 0.5916727\ldots .$$

*Proof.* If $Q(u) = Q(v)$ then $v = uw$ with $w^4 = 1$, hence $w \in P_{29,7}$ by
Theorem 3.1, hence $T(v) = T(u)$ because $T$ is a class function (Lemma 2.2).
Lemma 2.5 applies. $\square$

**Theorem 3.6 (orthogonality of the quartic character).** Work in the exponent
(discrete-logarithm) model, where $a$ runs uniformly over $\mathbb{Z}/28$, the
septic type is $T(a) = 1$ if $7 \mid a$ and $7$ otherwise, and the *quartic
character* is $\chi_4(a) = a \bmod 4$. Then
$$I(\chi_4 ; T) = 0 .$$
In particular the quadratic residue symbol mod $29$, being a function of $\chi_4$,
says nothing about splitting in the septic subfield.

*Proof.* Each of the four fibres $\{a : a \equiv c \pmod 4\}$ has exactly $7$
elements, of which exactly one satisfies $7 \mid a$; so every fibre has type
entropy $h(7,1)$. Hence $H(T \mid \chi_4) = h(7,1) = H(T)$ and the mutual
information vanishes. Structurally this is the Chinese Remainder decomposition
$C_{28} \cong C_4 \times C_7$ with $\gcd(4,7) = 1$: the two coordinates are
independent and only the $C_7$-coordinate is arithmetically relevant. $\square$

Theorems 3.5 and 3.6 are complementary: the $C_7$-component of the Frobenius
carries all $H(T)$ bits, the $C_4$-component carries none, and the two components
exhaust the group.

**Theorem 3.7 (semiprime split-count law).** Model a semiprime by an independent
uniform pair of exponents $(a,b) \in (\mathbb{Z}/7)^2$ and let $S$ be the number
of coordinates equal to $0$ (equivalently, the number of prime factors that split
completely). Then, of the $49$ pairs, exactly
$$36 \text{ have } S = 0, \qquad 12 \text{ have } S = 1, \qquad 1 \text{ has } S = 2,$$
i.e. $S \sim \mathrm{Bin}(2, 1/7)$ exactly.

---

## 4. Conductor-freeness: the rung is an invariant of the degree

The pair $(7,29)$ is not special. The engine is the following count.

**Lemma 4.0.** Let $G$ be a finite cyclic group with generator $g$. Then the set
of $q$-th powers of $G$ is the cyclic subgroup $\langle g^q\rangle$, of order
$|G| / \gcd(|G|, q)$.

*Proof.* Every $x \in G$ is $g^k$, so $x^q = (g^q)^k$; conversely
$(g^q)^k = (g^k)^q$. The order of $g^q$ is $\mathrm{ord}(g)/\gcd(\mathrm{ord}(g),q)$.
$\square$

**Theorem 4.1 (splitting density).** Let $f$ be prime and $q \mid f-1$. Then the
number of Frobenius classes that split completely in the degree-$q$ subfield of
$\mathbb{Q}(\zeta_f)$ is $(f-1)/q$; the splitting density is exactly $1/q$.

*Proof.* By Lemma 2.2 the split classes are precisely $P_{f,q}$, which by Lemma
4.0 has order $(f-1)/\gcd(f-1,q) = (f-1)/q$. $\square$

**Theorem 4.2 (conductor-free entropy).** Let $f$ and $q$ be primes with
$q \mid f-1$. Then the type entropy of the degree-$q$ rung is
$$H(T) = h(f-1, (f-1)/q) = h(q,1) = \log_2 q - \frac{q-1}{q}\log_2(q-1),$$
which does not depend on $f$. Consequently, for two admissible conductors $f, f'$
the rungs have literally the same entropy.

*Proof.* Lemma 2.2 gives a binary read-out; Lemma 2.4 and Theorem 4.1 give
$h(f-1, (f-1)/q)$; scale invariance $h(cq, c) = h(q,1)$ with $c = (f-1)/q$
removes the conductor. $\square$

**Theorem 4.3 (universal full pinning).** For *every* modulus $f$ and *every*
degree $q$, the Frobenius class in
$(\mathbb{Z}/f)^\times/P_{f,q}$ determines the residue degree, so
$H(T \mid \text{class}) = 0$; and under the hypotheses of Theorem 4.2,
$$I(\text{Frobenius class}; T) = H(T) = \log_2 q - \frac{q-1}{q}\log_2 (q-1).$$

*Proof.* Two units with the same class differ by an element of $P_{f,q}$, and $T$
is a class function (Lemma 2.2); apply Lemma 2.5. Neither primality of $q$ nor
any condition on $f$ is used for the vanishing of the conditional entropy; those
hypotheses enter only in evaluating $H(T)$. $\square$

**Corollary 4.4.** The degree-seven rungs of conductors $29$ and $43$ carry
exactly the same type entropy, and $43$ satisfies the same certified bracket
$0.5916 < H(T) < 0.5918$. The degree-eleven rung of conductor $23$, the
degree-three rung of conductor $7$, and the degree-five rung of conductor $11$
are all instances of Theorem 4.2.

The ladder is therefore indexed by the degree alone: $H(T) = 1$ at $q=2$,
$0.9183$ at $q=3$, $0.7219$ at $q=5$, $0.5917$ at $q=7$, $0.4395$ at $q=11$,
decaying like $\frac{\log_2 q}{q}$.

---

## 5. Three channels of a semiprime

### 5.1 The exponent box

Fix a degree $n \ge 2$. In the discrete-logarithm coordinates of the cyclic
Galois group, a prime factor is represented by its exponent $a \in \mathbb{Z}/n$,
and its residue degree is
$$\tau_n(a) := \frac{n}{\gcd(n,a)} ,$$
the order of $a$ in $\mathbb{Z}/n$. Note $\tau_n(0) = 1$ (split) and, for prime
$n = q$, $\tau_q(a) = 1$ if $a = 0$ and $q$ otherwise.

**Definition 5.1.** The *exponent box* is
$B_n := \{(a,b) : 0 \le a,b < n\}$, of cardinality $n^2$, carrying the uniform
measure. On it we define:

* the **type pair** $\Theta_n(a,b) := \big(\min(\tau_n(a),\tau_n(b)),
  \max(\tau_n(a),\tau_n(b))\big)$ — the unordered pair of residue degrees of the
  two prime factors of the semiprime $N = p_1p_2$;
* the **split count** $S(a,b) := \#\{i : \text{$i$-th coordinate of } \Theta_n = 1\}
  \in \{0,1,2\}$;
* the **OR read-out** $O := \min(S,1) \in \{0,1\}$, the indicator that at least
  one factor splits completely;
* the **product residue** $R_n(a,b) := (a+b) \bmod n$ — the Frobenius class of the
  semiprime $N$ itself, which is what an observer of $N$ can read off.

**Definition 5.2 (the three channels).**
$$I_{\mathrm{pair}}(n) := I_{B_n}(\Theta_n; R_n), \quad
I_{\mathrm{split}}(n) := I_{B_n}(S; R_n), \quad
G(n) := I_{B_n}(O; R_n).$$

Each measures, in bits, how much the residue of the semiprime reveals about the
splitting behaviour of its hidden prime factors, at three levels of resolution.

### 5.2 Prime degree: the split count is sufficient

**Lemma 5.3 (type pair at prime degree).** For $q$ prime and $0 \le a,b < q$,
$$\Theta_q(a,b) = \begin{cases}
(1,1) & a = b = 0,\\
(1,q) & \text{exactly one of } a,b \text{ is } 0,\\
(q,q) & a \ne 0 \ne b.
\end{cases}$$

**Theorem 5.4 (sufficiency at prime degree).** For $q$ prime, $S$ determines
$\Theta_q$: if two points of $B_q$ have the same split count then they have the
same type pair. Consequently
$$I_{\mathrm{pair}}(q) = I_{\mathrm{split}}(q).$$

*Proof.* By Lemma 5.3 the split count is $2, 1, 0$ exactly in the three listed
cases, so $S$ and $\Theta_q$ induce the same partition of $B_q$ (into the three
cells of sizes $1$, $2(q-1)$, $(q-1)^2$). Apply the partition principle
(Lemma 2.3), unconditionally and inside each fibre of $R_q$. $\square$

This is the precise sense in which, at prime degree, "how many factors split" is a
*sufficient statistic* for the entire splitting type of the semiprime.

**Lemma 5.5 (fibre structure).** Let $q$ be prime and fix $r \in \mathbb{Z}/q$.
The fibre $R_q^{-1}(r)$ has $q$ elements, and:

* if $r = 0$: one point with $S = 2$ (namely $(0,0)$) and $q-1$ points with $S=0$;
* if $r \ne 0$: two points with $S = 1$ (namely $(0,r)$ and $(r,0)$) and $q-2$
  points with $S = 0$.

In particular each fibre contains at most one non-zero value of $S$.

**Corollary 5.6 (conditional entropies).**
$$H(S \mid R_q) = \tfrac{1}{q}\,h(q,1) + \tfrac{q-1}{q}\,h(q,2),$$
and the same expression equals $H(O \mid R_q)$.

*Proof.* The displayed formula is immediate from Lemma 5.5. For the second claim,
inside a single fibre $S$ takes at most one non-zero value, so on that fibre $S$
and $O = \min(S,1)$ induce the same partition; apply the conditional form of
Lemma 2.3. $\square$

**Theorem 5.7 (exact channel difference and data processing).** For prime $q$,
$$I_{\mathrm{split}}(q) - G(q) = H(S) - H(O) \;\ge\; 0,$$
so $G(q) \le I_{\mathrm{split}}(q)$ at every prime degree.

*Proof.* Subtract the two mutual informations and use Corollary 5.6 to cancel the
conditional entropies; non-negativity is Lemma 2.6, since $O = \min(\cdot,1)\circ S$.
$\square$

Notice that the data-processing inequality here is not obtained by an estimate but
by an exact identity: the entire loss caused by the OR coarsening already appears
at the level of the *unconditional* entropies.

**Theorem 5.8 (closed forms at prime degree).** For $q$ prime, with $h(N,m)$ as
above,
$$I_{\mathrm{split}}(q) = H\!\big((q-1)^2, 2(q-1), 1\big)
- \Big[\tfrac{1}{q}h(q,1) + \tfrac{q-1}{q}h(q,2)\Big],$$
$$G(q) = h\big(q^2,\, 2q-1\big)
- \Big[\tfrac{1}{q}h(q,1) + \tfrac{q-1}{q}h(q,2)\Big],$$
where $H(c_0,c_1,c_2)$ denotes the entropy of the distribution proportional to
$(c_0,c_1,c_2)$.

*Proof.* The split-count distribution on $B_q$ has cell sizes
$\big((q-1)^2, 2(q-1), 1\big)$ by Lemma 5.3, and the OR read-out is binary with
$|O^{-1}(1)| = 2(q-1) + 1 = 2q-1$, so Lemma 2.4 applies. Subtract the conditional
entropy of Corollary 5.6. $\square$

---

## 6. The degree-seven values

**Theorem 6.1 (split-count channel at degree seven).**
$$I_{\mathrm{split}}(7) \;=\; \log_2 7 + \frac{30\log_2 5 - 78\log_2 3 - 78}{49}
\;=\; 0.1141053\ldots,$$
and $0.1140 < I_{\mathrm{split}}(7) < 0.1142$.

*Proof.* Insert $q = 7$ into Theorem 5.8. The split-count cell sizes are
$(36,12,1)$ out of $49$ (Theorem 3.7), giving the unconditional entropy
$\log_2 49 - \frac{1}{49}(36\log_2 36 + 12\log_2 12)$; the conditional term is
$\frac{1}{7}h(7,1) + \frac{6}{7}h(7,2)$. Expanding
$\log_2 36 = 2 + 2\log_2 3$, $\log_2 12 = 2 + \log_2 3$, $\log_2 6 = 1 + \log_2 3$,
$\log_2 49 = 2\log_2 7$, and $h(7,2) = \log_2 7 - \frac{2}{7} - \frac{5}{7}\log_2 5$,
everything collapses to the displayed combination of $\log_2 7$, $\log_2 5$ and
$\log_2 3$. The bracket is equivalent to the integer inequalities
$$2^{16718}\cdot 3^{15600} < 7^{9800}\cdot 5^{6000} < 2^{16719}\cdot 3^{15600}. \square$$

**Theorem 6.2 (OR channel at degree seven).**
$$G(7) \;=\; \log_2 7 + \frac{30\log_2 5 - 66\log_2 3 - 13\log_2 13 - 54}{49}
\;=\; 0.0103060\ldots,$$
and $0.01027 < G(7) < 0.01035$.

*Proof.* As above, with the binary OR distribution $(36, 13)$ out of $49$; the
term $13\log_2 13$ is the trace of the cell of size $2q-1 = 13$. The bracket
reduces to integer comparisons involving $2$, $3$, $5$, $7$ and $13$. $\square$

**Corollary 6.3 (the OR coarsening is catastrophic).**
$$11\, G(7) < I_{\mathrm{split}}(7).$$
Collapsing the count $\{0,1,2\}$ to the single bit "at least one factor splits"
destroys more than ninety percent of an already small channel.

**Corollary 6.4 (ladder monotonicity).** $I_{\mathrm{split}}(11) = 0.051897\ldots
< I_{\mathrm{split}}(7) = 0.114105\ldots$; the ladder is strictly decreasing
between the two rungs.

For orientation, the three degree-seven numbers should be compared with the
single-prime channel: $H(T) = 0.5917$ bits. Passing from a prime to a semiprime
costs a factor of $5.2$; coarsening the count to one bit costs a further factor
of $11.1$.

---

## 7. Numerical audit of the round's anchors

Two numerical anchors were carried into this rung from prior experimentation.
Closed forms allow a decisive verdict on each.

**The anchor $0.0103$ is the OR channel (confirmed).** By Theorem 6.2,
$$|G(7) - 0.0103| < 5\times 10^{-5},$$
so the value that had circulated as a split-count figure is in fact the OR
channel, exactly as a later disclosure suggested. The reattribution is correct.

**The anchor $0.1161$ for the split-count channel is falsified.** By Theorem 6.1,
$$I_{\mathrm{split}}(7) < 0.1161 \quad\text{and}\quad 0.1161 - I_{\mathrm{split}}(7) > 0.0018 .$$
The gap is more than $18$ times the width of the certified bracket, so it is not a
rounding artefact. The true value is $0.1141053\ldots$. (The reported figure
coincides with $49 \cdot$ some binomial-flavoured expression only accidentally;
the actual $\mathrm{Bin}(2,1/7)$ content of the rung is the exact cell count
$(36,12,1)$ of Theorem 3.7, and the channel derived from it is $0.11410\ldots$.)

**A mislabelled rung.** A figure $0.116$ had been recorded elsewhere as the
degree-*eleven* split-count channel. Since
$$|I_{\mathrm{split}}(7) - 0.116| = 0.00190 \quad\text{while}\quad
|I_{\mathrm{split}}(11) - 0.116| = 0.06410,$$
the anchor is more than thirty times closer to the degree-seven rung: the
signature of a rung mislabelling rather than of a measurement error.

The general lesson is methodological. Every quantity in this framework is a
finite combination of logarithms of small integers, hence admits an exactly
certified bracket; empirical estimates should be checked against the closed form
before they are propagated, since a $0.002$-bit discrepancy is invisible to a
sampling experiment but fatal to a claimed identity.

---

## 8. Composite degree: where the split count stops being sufficient

Theorem 5.4 used primality of $q$ in an essential way. We now show that this is
not an artefact of the proof.

### 8.1 The partition-level criterion

**Theorem 8.1 (primality is the sufficient-statistic condition).** Let $n \ge 2$.
The split count induces the same partition of the exponent box $B_n$ as the full
type pair — that is,
$$\forall x,y \in B_n:\; S(x) = S(y) \implies \Theta_n(x) = \Theta_n(y)$$
— **if and only if** $n$ is prime.

*Proof.* If $n$ is prime this is Theorem 5.4. If $n$ is composite, choose a
divisor $d$ with $1 < d < n$ and write $n = de$ with $e \ge 2$. Then
$\tau_n(d) = n/\gcd(d,n) = n/d = e$ and $\tau_n(1) = n$. The two points
$x = (d,d)$ and $y = (1,1)$ of $B_n$ both have split count $0$ (since
$e \neq 1 \neq n$), yet $\Theta_n(x) = (e,e) \neq (n,n) = \Theta_n(y)$. $\square$

The mechanism is transparent: the split count records only *how many* trivial
residue degrees occur, and forgets *which* non-trivial degrees occur. That datum
is empty exactly when the divisor lattice of $\mathbb{Z}/n$ has a single
non-trivial level — i.e. exactly when $n$ is prime.

### 8.2 The first composite degree in closed form

At $n = 4$ the divisors are $1,2,4$ and the type pair takes six values. A direct
enumeration of the $16$-element box gives the cell sizes
$$\Theta_4: \quad (1,1)\!:\!1,\;\; (1,2)\!:\!2,\;\; (1,4)\!:\!4,\;\;
(2,2)\!:\!1,\;\; (2,4)\!:\!4,\;\; (4,4)\!:\!4,$$
while the split count has cells $(9,6,1)$ and the product residue has four fibres
of size $4$ each.

**Theorem 8.2 (entropies at degree four).**
$$H(\Theta_4) = \frac{19}{8}, \qquad H(\Theta_4 \mid R_4) = \frac{9}{8},$$
$$H(S) = \frac{29}{8} - \frac{3}{2}\log_2 3, \qquad
H(S \mid R_4) = \frac{5}{4} - \frac{3}{16}\log_2 3 .$$

*Proof.* Direct evaluation of the defining sums on the enumerated cells. For the
conditional entropies, the four fibres of $R_4$ each have four elements; for the
type pair they carry entropies $3/2, 1, 1, 1$, and for the split count
$2 - \frac{3}{4}\log_2 3,\, 1,\, 1,\, 1$. Averaging with weight $1/4$ gives the
stated values. $\square$

**Theorem 8.3 (the two channels at degree four).**
$$I_{\mathrm{pair}}(4) = \frac{19}{8} - \frac{9}{8} = \frac{5}{4},$$
$$I_{\mathrm{split}}(4) = \Big(\frac{29}{8} - \frac{3}{2}\log_2 3\Big)
- \Big(\frac{5}{4} - \frac{3}{16}\log_2 3\Big)
= \frac{19}{8} - \frac{21}{16}\log_2 3 = 0.2947367\ldots$$

**Theorem 8.4 (cap behaviour).** $I_{\mathrm{pair}}(4) = 5/4 > 1$, whereas
$I_{\mathrm{split}}(4) < 0.3 < 1$. The witness for the strict inequalities is the
integer bound $2^{22} < 3^{21}$, which gives $\log_2 3 > 22/21$ and hence
$I_{\mathrm{split}}(4) < \frac{19}{8} - \frac{21}{16}\cdot\frac{22}{21}
= \frac{19}{8} - \frac{11}{8} = 1$; the sharper $0.3$ bound follows from
$2^{3325} < 3^{2098}$.

**Theorem 8.5 (strict loss at the first composite degree).**
$$I_{\mathrm{split}}(4) < 0.3 < \tfrac{1}{4}\cdot\tfrac{5}{4} = \tfrac{1}{4}\,I_{\mathrm{pair}}(4),$$
so in particular $I_{\mathrm{split}}(4) < I_{\mathrm{pair}}(4)$: the projection to
the split count destroys more than three quarters of the channel.

Two features deserve emphasis. First, $I_{\mathrm{pair}}(4) = 5/4$ is *rational*
— an unusual event in this family, where channel values are typically irrational
combinations of logarithms — and it exceeds one bit, which no binary read-out can
do. Second, the split count restores the one-bit cap, which is a structural
consequence of its being (at $n=4$) essentially a two-valued observable after
conditioning.

Combining Theorems 5.4, 8.1 and 8.5: primality of the degree is *exactly* the
mechanism behind the sufficiency of the split count, both at the level of
partitions (an if-and-only-if) and, at the smallest composite degree, at the
level of channel values.

---

## 9. Algorithms

All quantities above are computable exactly and cheaply. Three procedures suffice.

**Algorithm A (splitting law of a prime rung).** Input: a prime conductor $f$, a
degree $q$ with $q \mid f-1$, and a prime $p \nmid f$. Compute the subgroup
$P_{f,q} = \{u^q \bmod f\}$ by one pass over $(\mathbb{Z}/f)^\times$, then return
$1$ if $p \bmod f \in P_{f,q}$ and the multiplicative order of $p P_{f,q}$
otherwise. Cost: $O(f\log q)$ modular multiplications for the subgroup, then
$O(q)$ per query. For prime $q$ the answer is $1$ or $q$ by Lemma 2.2, and
$p \in P_{f,q}$ can be tested in $O(\log f)$ by Euler's criterion
$p^{(f-1)/q} \equiv 1$.

**Algorithm B (exact channel evaluation at degree $n$).** Enumerate the $n^2$
points of the exponent box; for each, compute $\tau_n(a) = n/\gcd(n,a)$, the type
pair, the split count, the OR bit and the product residue; tally joint counts;
return $H - H(\cdot\mid R)$ for each read-out. Cost $O(n^2 \log n)$ time and
$O(n)$ memory; all intermediate quantities are integers, so the only
floating-point operations are the final logarithms — or, if desired, none at all,
since the answer is a rational combination of $\log_2$ of the tallied integers.

**Algorithm C (certified bracket for a logarithmic constant).** Given a target
value $V = \sum_i \alpha_i \log_2 m_i$ with rational $\alpha_i$ and integers
$m_i$, and a candidate rational bracket $(\ell, u)$, clear denominators to obtain
integers $N_i, E$ with $V > \ell$ equivalent to
$\prod_i m_i^{N_i} > 2^{E}$ (times integer factors on the other side), and decide
the resulting inequality between big integers. Cost: one big-integer comparison,
whose operands have $O(E)$ bits; this is how all brackets in Sections 3, 6 and 8
are obtained without any floating-point arithmetic.

---

## 10. Discussion and future directions

### 10.1 What the ladder measures

The results assemble into a table of channels, at degree seven:

| observation | hidden variable | information |
|---|---|---|
| Frobenius class of a prime | residue degree $T$ | $0.591673$ bits $= H(T)$ (full pinning) |
| quartic character mod $29$ | residue degree $T$ | $0$ bits |
| residue of a semiprime | full type pair | $0.114105$ bits |
| residue of a semiprime | split count | $0.114105$ bits (sufficiency) |
| residue of a semiprime | "at least one splits" | $0.010306$ bits |

The first line quantifies reciprocity: a lookup on residues is a lossless channel
for the splitting type. The last lines quantify a form of arithmetic opacity of
products: multiplying two primes destroys $80\%$ of the signal, and coarsening the
question destroys $90\%$ of what remains.

### 10.2 Second-order decay law of the prime-degree channels

**Conjecture.** For prime degrees $q \to \infty$,
$$q^2\, I_{\mathrm{split}}(q) = \log_2 q + 2\log_2 e + O(1/q),
\qquad q^2\, G(q) \to \log_2 e - 1 .$$

Numerically $q^2 I_{\mathrm{split}}(q) - \log_2 q = 2.784,\, 2.878,\, 2.884,\,
2.8845,\, 2.8854$ at $q = 7, 101, 1009, 10007, 100003$, against
$2\log_2 e = 2.885390\ldots$; and $q^2 G(q) = 0.505,\, 0.4427,\, 0.4427$ at
$q = 7, 1009, 100003$, against $\log_2 e - 1 = 0.442695\ldots$.

The key insight is that both channels are second-order Taylor remainders of the
same binary entropy, so the leading constants must be pure entropy curvature
($\log_2 e$), carrying no arithmetic information about the field. With exact
closed forms for both channels at every prime degree (Theorem 5.8), the
conjecture reduces to a controlled expansion of $\log_2(1 - 1/q)$.

### 10.3 Primality is exactly the sufficient-statistic condition

**Conjecture.** For every $n \ge 2$, $I_{\mathrm{pair}}(n) = I_{\mathrm{split}}(n)$
**iff** $n$ is prime.

The partition-level form is proved in full (Theorem 8.1): the split count induces
the same partition of the exponent box as the type pair exactly when $n$ is prime.
At the level of channels, the "if" direction holds for all primes (Theorem 5.4)
and the smallest composite case is settled with exact values
($I_{\mathrm{pair}}(4) = 5/4$, $I_{\mathrm{split}}(4) = \frac{19}{8} -
\frac{21}{16}\log_2 3$, Theorems 8.3 and 8.5); exhaustive evaluation for
$n \le 12$ shows a strictly positive gap at every composite $n$. What remains is
to convert a strictly finer partition into a strictly larger mutual information —
i.e. to show that the extra type value $n/d$ produced by a divisor $1 < d < n$
survives conditioning on the product residue.

### 10.4 Further directions

* **Higher-order Frobenius data.** Replace the product residue by the pair
  (residue, number of prime factors) or by residues to several conductors, and
  ask how the channel grows; the partition principle should give exact answers.
* **Non-cyclic degrees.** For non-cyclic abelian Galois groups the residue degree
  is the order of the Frobenius in the group, and the analogue of Theorem 8.1
  should read: the split count is sufficient iff the group has a unique
  non-trivial order, i.e. iff it is elementary abelian of prime exponent.
* **$k$-almost primes.** For $N$ a product of $k$ primes the split count is
  $\mathrm{Bin}(k, 1/q)$ and the conditional structure of Lemma 5.5 generalises;
  one expects $I_{\mathrm{split}}^{(k)}(q) \asymp k^2 \log_2 q / q^2$.
* **Effective ladders.** Combining the conductor-freeness (Theorem 4.2) with
  effective Chebotarev bounds would convert these exact channel values into
  statements about finite ranges of primes, making the empirical densities
  themselves provable at explicit heights.

---

## 11. Conclusion

The degree-seven rung of the abelian splitting-type ladder is now complete and
exact. In the septic subfield of $\mathbb{Q}(\zeta_{29})$ a prime splits
completely precisely when its residue mod $29$ lies in $\{1,12,17,28\}$; the
splitting densities are $1/7$ and $6/7$; the type entropy is
$\log_2 7 - \frac{6}{7}\log_2 6 = 0.5916727\ldots$ bits and is attained exactly by
the Frobenius channel, while the quartic character contributes nothing. None of
this depends on the conductor: every prime degree $q$ and every prime conductor
$f \equiv 1 \pmod q$ give density $1/q$, entropy $\log_2 q -
\frac{q-1}{q}\log_2(q-1)$, and full pinning.

For semiprimes the picture is quantitatively different and structurally sharp.
The split count follows $\mathrm{Bin}(2,1/7)$ exactly, with cells $(36,12,1)$; the
split-count channel is $0.1141053\ldots$ bits, the OR channel $0.0103060\ldots$
bits, and the latter is provably never larger, by an exact identity rather than an
estimate. Of the two numerical anchors carried into this round, the OR figure is
confirmed and the split-count figure is corrected. And the reason the split count
could be used interchangeably with the full type pair all along is now identified
exactly: it is a sufficient statistic precisely at prime degree, with the first
composite degree already losing more than three quarters of its channel.
