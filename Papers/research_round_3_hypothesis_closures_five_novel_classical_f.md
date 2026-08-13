# Two Structural Barriers to Classical Integer Factoring: Free Witnesses and Congruence Blindness

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

We study five structurally distinct proposals for a classical polynomial-time integer factoring algorithm — an evaluation ("Reed–Solomon") code over $\mathbb{Z}/N$, a divisor-count-parity oracle, the reduced Burau representation of the three-strand braid group over $\mathbb{Z}/N$, the average-case existence of a cheaply recognizable fast subfamily of semiprimes, and a divisor congestion game — and show that each of them fails, unconditionally, for one of exactly two reasons.

The first reason is the **free-witness phenomenon**. For a semiprime $N = pq$ the Chinese Remainder isomorphism $\mathbb{Z}/N \cong \mathbb{Z}/p \times \mathbb{Z}/q$ turns every algebraic invariant of a structure over $\mathbb{Z}/N$ into a function of the two prime-level invariants. We make this precise in the coding-theoretic setting: we prove that for distinct primes $p < q$ and every $k \le p$, the minimum Hamming distance of the code of evaluations of polynomials of degree at most $k$ over $\mathbb{Z}/N$ is exactly $N - k\max(p,q)$, so that the minimum distance of the degree-$\le 1$ code determines the complete factorization. We prove the analogous statement for the braid setting: the image of $\sigma_1\sigma_2$ under the reduced Burau representation specialized at a unit $a$ has multiplicative order exactly $\operatorname{lcm}(3, \operatorname{ord}(a))$, so that the braid-group invariants are order-finding invariants, and the order splits as $\operatorname{ord}_{pq}(a) = \operatorname{lcm}(\operatorname{ord}_p(a), \operatorname{ord}_q(a))$.

The second reason is **congruence blindness**. We prove a meta-theorem: for every modulus $m > 1$ and every bound $B$, no invariant $I : \mathbb{N} \to \mathbb{N}$ that is determined by $N \bmod m$ can output a nontrivial divisor of every semiprime $N > B$. The proof exhibits, via Dirichlet's theorem on primes in arithmetic progressions, two *coprime* semiprimes above $B$ in the same residue class. We strengthen this to bounded candidate *lists*: no map $S : \mathbb{Z}/m \to$ finite sets with $|S(a)| \le k$ can always contain a nontrivial divisor, the obstruction being a family of $k+1$ pairwise-coprime semiprimes in a single class.

Both barriers are then applied to close the remaining proposals: the divisor-parity oracle is closed by an adversary argument (two semiprimes yield identical query transcripts off a set of density $6/m$, forcing $\Omega(m)$ queries), the average-case proposal is closed by congruence blindness, and the game-theoretic proposal is closed by exhibiting that its unique Nash equilibrium bid is the least prime factor — with a payoff query that is itself a divisibility test and a payoff landscape that is exactly constant off the divisors.

---

## 1. Introduction

### 1.1 Motivation

Integer factoring is the paradigmatic problem whose presumed hardness underwrites deployed cryptography, and whose actual complexity remains unresolved. The best classical algorithms — the quadratic sieve, the elliptic-curve method, the general number field sieve — run in subexponential but superpolynomial time. Shor's quantum algorithm runs in polynomial time, and the classical picture has not moved comparably in decades.

In the absence of an unconditional lower bound, a productive research posture is systematic *negative* work: propose a structurally novel attack, make it mathematically precise, and determine exactly where and why it fails. Repeated across many proposals, this produces something more valuable than a list of defeats — it produces a taxonomy of the obstructions.

This paper reports on five such proposals, chosen deliberately from mathematical territory that has not previously been mined for factoring attacks:

| Proposal | Object | Outcome |
|---|---|---|
| Evaluation codes | Reed–Solomon-type code over $\mathbb{Z}/N$ | closed: minimum distance is a free witness |
| Divisor parity | parity of divisor counts in residue classes | closed: decision-tree lower bound + circularity |
| Braid groups | reduced Burau image of $B_3$ over $\mathbb{Z}/N$ | closed: reduces exactly to order-finding |
| Average case | cheaply recognizable fast subfamily | closed: no congruence-detectable class |
| Game theory | divisor congestion game | closed: the equilibrium *is* the factorization |

Our central finding is that all five closures factor through **two** structural facts, and only two.

### 1.2 The two facts

**(F1) CRT splitting.** For $N = pq$ with $p \ne q$ prime, $\mathbb{Z}/N \cong \mathbb{Z}/p \times \mathbb{Z}/q$ as rings. Consequently, any algebraic structure constructed functorially over $\mathbb{Z}/N$ decomposes as a product of the corresponding structures over $\mathbb{Z}/p$ and $\mathbb{Z}/q$, and every numerical invariant of it is a function of the pair of prime-level invariants. If that function is injective enough to be inverted — and in the cases we study it is — then computing the invariant is at least as hard as separating $p$ from $q$.

**(F2) Richness of residue classes.** By Dirichlet's theorem on primes in arithmetic progressions, every residue class $a \bmod m$ with $\gcd(a, m) = 1$ contains infinitely many primes. It follows that every such class contains semiprimes with arbitrarily prescribed small factor, arbitrarily large factor gap, and — crucially — pairs of semiprimes that are coprime to one another.

Fact (F1) is what makes a proposed invariant *equivalent* to factoring rather than a route to it. Fact (F2) is what kills any attempt to bypass the invariant by reading a cheap statistic off $N$. Together they cover all five proposals.

### 1.3 Terminology: barriers

We refer informally to the following recurring obstruction types.

- **Circularity (barrier 6):** the proposed primitive can only be evaluated by first solving the problem it is supposed to solve.
- **Cost (barrier 4):** the proposed quantity is well-defined and factor-revealing, but the only known evaluation route costs $\Omega(N)$ or worse.
- **Known-method equivalence (barrier 8):** the proposal reduces to a known algorithm (Pollard $p-1$, Fermat, order-finding) with no improvement.
- **Statistical blindness (barrier 5):** the proposed $N$-only statistic is provably uncorrelated with the location of the factorization.

A **free witness** is a scalar invariant $t = t(N)$ such that $(N, t)$ determines the factorization of $N$, but such that every known evaluation of $t$ costs $\Omega(N)$ or requires the factorization. Free witnesses combine barriers 4 and 6.

### 1.4 Contributions

1. **Exact minimum distance of evaluation codes over $\mathbb{Z}/N$** (Theorem 3.6), including tightness via an explicit extremal codeword, and its consequence that the minimum distance is a free witness (Theorem 3.7).
2. **Exact order of the Burau image of $\sigma_1\sigma_2$** (Theorem 5.4), the full-twist scalar identity (Theorem 5.2), the two-way reduction to multiplicative order-finding (Corollary 5.5), the CRT splitting of the order invariant (Theorem 5.7), and divisibility of the Burau subgroup order by $\operatorname{lcm}(3,\operatorname{ord}(a))$ (Theorem 5.9).
3. **Complete analysis of the divisor-parity primitive**: support characterization (Theorem 4.3), factor-residue recovery (Corollary 4.4), the exact three-element support density (Corollary 4.5), the adversary indistinguishability theorem forcing $\Omega(m)$ queries (Theorem 4.6), and an exact characterization of the failure cases (Theorem 4.7).
4. **The congruence-blindness meta-theorem** (Theorem 6.5) and its non-vacuity (Proposition 6.3), plus the class-population theorem driving it (Theorem 6.1) and the no-detector corollaries (Corollaries 6.2, 6.6, 6.7).
5. **The bounded-candidate-list theorem** (Theorem 7.2), extending the meta-theorem from single outputs to lists of bounded size, via a pairwise-coprime semiprime family in one class (Theorem 7.1).
6. **Complete solution of the divisor congestion game** (Theorems 8.3–8.6), establishing uniqueness of the equilibrium, its identity with the factorization, and the flatness of the payoff landscape.

Throughout, $N = pq$ denotes a semiprime with $p, q$ distinct primes, and $\operatorname{minFac}(N)$ denotes the least prime factor.

---

## 2. Preliminaries: the divisor lattice of a semiprime

Every closure below rests on the elementary but load-bearing fact that a semiprime has an extremely thin divisor lattice.

**Lemma 2.1 (Divisor dichotomy).** *Let $p, q$ be primes and let $d \mid pq$. Then $d \in \{1, p, q, pq\}$.*

*Proof.* The divisor set of a product is the product of the divisor sets: $\operatorname{Div}(pq) = \operatorname{Div}(p)\cdot\operatorname{Div}(q) = \{1,p\}\cdot\{1,q\}$, whose elements are $1, q, p, pq$. $\square$

**Lemma 2.2 (Proper divisors).** *For primes $p, q$, the set of proper divisors of $pq$ (divisors strictly less than $pq$) is exactly $\{1, p, q\}$ — a two-element set when $p = q$.*

*Proof.* Immediate from Lemma 2.1 together with $1 < p, q < pq$, which holds since $p, q \ge 2$. $\square$

These two facts alone drive the parity closure (Section 4), the game-theoretic closure (Section 8), and the divisor-uniqueness step in the congruence-blindness arguments (Sections 6–7).

---

## 3. Evaluation codes over $\mathbb{Z}/N$: the minimum distance is a free witness

### 3.1 Setup

**Definition 3.1.** Let $N = pq$ with $p, q$ distinct primes. For $k \ge 1$ define the **evaluation code**
$$C_k(N) \;=\; \bigl\{\, \bigl(f(x)\bigr)_{x \in \mathbb{Z}/N} \;:\; f \in (\mathbb{Z}/N)[X],\ \deg f < k \,\bigr\} \;\subseteq\; (\mathbb{Z}/N)^N.$$
For a polynomial $f$, write
$$Z(f) = \{x \in \mathbb{Z}/N : f(x) = 0\}, \qquad \operatorname{wt}(f) = \#\{x \in \mathbb{Z}/N : f(x) \ne 0\}.$$
Thus $\operatorname{wt}(f) + |Z(f)| = N$.

Over a finite field $\mathbb{F}_n$ this is the classical Reed–Solomon code, with minimum distance $n - (k-1)$ by the fundamental theorem of algebra over a field. Over $\mathbb{Z}/N$, which has zero divisors, the naive bound fails and the true answer is genuinely different.

We write $\pi_p : \mathbb{Z}/N \to \mathbb{Z}/p$ and $\pi_q : \mathbb{Z}/N \to \mathbb{Z}/q$ for the two reduction homomorphisms.

### 3.2 The upper bound on zeros

**Lemma 3.2 (CRT injectivity).** *If $\gcd(p,q) = 1$, the map $x \mapsto (\pi_p(x), \pi_q(x))$ is injective on $\mathbb{Z}/pq$.*

*Proof.* This is the Chinese Remainder Theorem: the map is precisely the CRT ring isomorphism $\mathbb{Z}/pq \to \mathbb{Z}/p \times \mathbb{Z}/q$, which is bijective. $\square$

**Lemma 3.3 (Zero set splits).** *For any $f \in (\mathbb{Z}/N)[X]$,*
$$|Z(f)| \;\le\; \bigl|Z(\pi_p f)\bigr| \cdot \bigl|Z(\pi_q f)\bigr|,$$
*where $\pi_p f \in (\mathbb{Z}/p)[X]$ is the coefficientwise reduction and $Z(\pi_p f) \subseteq \mathbb{Z}/p$ its root set.*

*Proof.* If $f(x) = 0$ in $\mathbb{Z}/N$ then applying $\pi_p$ gives $(\pi_p f)(\pi_p x) = 0$, and similarly for $q$. So $x \mapsto (\pi_p x, \pi_q x)$ maps $Z(f)$ into $Z(\pi_p f) \times Z(\pi_q f)$, and it is injective by Lemma 3.2. $\square$

**Lemma 3.4 (Nondegeneracy).** *If $\pi_p f = 0$ and $\pi_q f = 0$ then $f = 0$.*

*Proof.* Each coefficient of $f$ reduces to $0$ mod $p$ and mod $q$; by Lemma 3.2 applied to that coefficient and to $0$, it is $0$. $\square$

**Theorem 3.5 (Zero-count bound).** *Let $p, q$ be distinct primes and let $f \in (\mathbb{Z}/pq)[X]$ be nonzero. Then*
$$|Z(f)| \;\le\; \deg(f) \cdot \max(p,q),$$
*and equivalently $\operatorname{wt}(f) \ge pq - \deg(f)\max(p,q)$.*

*Proof.* By Lemma 3.4 at least one of $\pi_p f$, $\pi_q f$ is nonzero; say $\pi_p f \ne 0$ (the other case is symmetric). Over the field $\mathbb{Z}/p$ a nonzero polynomial has at most $\deg(\pi_p f) \le \deg f$ roots, so $|Z(\pi_p f)| \le \deg f$. Trivially $|Z(\pi_q f)| \le q$. Lemma 3.3 then gives $|Z(f)| \le \deg(f)\cdot q \le \deg(f)\max(p,q)$. The weight statement follows from $\operatorname{wt}(f) = N - |Z(f)|$. $\square$

Note the asymmetry that makes the result interesting: the bound is *not* $\deg f$ (as over a field) and *not* $N$ (as one might fear over a ring with zero divisors), but the product $\deg f \cdot \max(p,q)$ — a quantity that visibly contains a prime factor of $N$.

### 3.3 Tightness

**Proposition 3.6 (Extremal codeword).** *Let $p < q$ be distinct primes and $k \le p$. Set*
$$f_k(X) \;=\; q \cdot \prod_{i=0}^{k-1}(X - i) \;\in\; (\mathbb{Z}/pq)[X].$$
*Then $f_k \ne 0$, $\deg f_k \le k$, and $|Z(f_k)| = kq = k\max(p,q)$.*

*Proof.* Nonvanishing: the coefficient of $X^k$ in $f_k$ is $q \bmod pq$, which is nonzero because $pq \nmid q$ (as $p \ge 2$). Degree: clear.

Zero count, lower bound. Under the CRT identification $x \leftrightarrow (x_p, x_q)$ we have $q \leftrightarrow (q \bmod p,\, 0)$. Hence for any $x$,
$$f_k(x) \;\longleftrightarrow\; \Bigl( (q \bmod p)\textstyle\prod_{i<k}(x_p - i),\; 0 \Bigr).$$
The second coordinate always vanishes. The first vanishes whenever $x_p \in \{0, 1, \dots, k-1\}$; these are $k$ distinct elements of $\mathbb{Z}/p$ because $k \le p$. Each such residue class mod $p$ contains exactly $q$ elements of $\mathbb{Z}/pq$ (one for each choice of $x_q$). Hence $|Z(f_k)| \ge kq$.

Zero count, upper bound. Theorem 3.5 gives $|Z(f_k)| \le \deg(f_k)\max(p,q) \le kq$. $\square$

The construction is the geometric heart of the matter: the extremal codeword vanishes on *complete residue classes modulo $p$*, and the number of lifts of each class is exactly $q$. The zero-set *spacing* is what reveals the factorization; the count merely records it.

**Theorem 3.7 (Exact minimum distance).** *Let $p < q$ be distinct primes, $N = pq$, and $1 \le k \le p$. Then:*

1. *every nonzero $f$ with $\deg f \le k$ satisfies $\operatorname{wt}(f) \ge N - k\max(p,q)$;*
2. *some nonzero $f$ with $\deg f \le k$ satisfies $\operatorname{wt}(f) = N - k\max(p,q)$.*

*Hence the minimum distance of the code of evaluations of polynomials of degree $\le k$ is exactly $d = N - k\max(p,q) = N - kq$.*

*Proof.* (1) is Theorem 3.5 combined with $\deg f \le k$. (2) is Proposition 3.6 together with $\operatorname{wt} = N - |Z|$. $\square$

### 3.4 The free witness

**Theorem 3.8 (Minimum distance reveals the factorization).** *Let $p < q$ with $N = pq$, and suppose $t \in \mathbb{N}$ satisfies both:*

- *(upper bound) $|Z(f)| \le t$ for every nonzero $f$ of degree $\le 1$;*
- *(attainment) $|Z(g)| \ge t$ for some nonzero $g$ of degree $\le 1$.*

*Then $t = q$ and $N/t = p$.*

*Proof.* By Theorem 3.5, $t \le |Z(g)| \le 1 \cdot \max(p,q) = q$. By Proposition 3.6 with $k=1$ there is a nonzero $f_1$ of degree $\le 1$ with $|Z(f_1)| = q$, whence $q \le t$ by the upper-bound hypothesis. So $t = q$, and $N/t = p$. $\square$

**Corollary 3.9.** *The minimum distance $d = d(C_2(N))$ of the degree-$\le 1$ evaluation code satisfies $N - d = \max(p,q)$ and $N/(N-d) = \min(p,q)$. In particular, an algorithm computing $d$ in time $T$ yields a factoring algorithm in time $T + O(\operatorname{polylog} N)$.*

This is the free-witness situation in its purest form. The two available evaluation routes are: (i) apply the formula $d = N - \max(p,q)$, which presupposes the factorization; or (ii) enumerate the codeword space, of size $\ge N^k$, and compute weights. Both are barriers — circularity and cost respectively — and no third route is known.

**Remark 3.10 (Why this is a genuinely new instance).** The same phenomenon has previously been observed for norm counts in quadratic orders, group-order counts, class counts of binary quadratic forms, counts of subgroups of Heisenberg-type groups, and modular indices attached to cusps. The coding-theoretic setting is structurally distinct from all of these — the invariant is metric (a Hamming distance) rather than a cardinality of an algebraic set — yet the mechanism is identical: the CRT product structure of the ambient object turns the invariant into a prime-level datum.

---

## 4. The divisor-count-parity primitive

### 4.1 Definition and factor recovery

**Definition 4.1.** For integers $N, m, a$ with $m \ge 1$, define
$$P(N, m, a) \;=\; \#\{\, d : d \text{ a proper divisor of } N,\ d \equiv a \pmod m \,\} \bmod 2 \;\in\; \{0,1\}.$$

The primitive is deliberately minimal: it returns one bit per query.

**Definition 4.2 (Non-collision).** A semiprime $N = pq$ is *non-degenerate at $m$* if the three residues $1 \bmod m$, $p \bmod m$, $q \bmod m$ are pairwise distinct.

**Theorem 4.3 (Support characterization).** *Let $N = pq$ be a semiprime, non-degenerate at $m \ge 1$. Then for every $a$,*
$$P(N,m,a) = 1 \iff a \equiv 1, \ p, \text{ or } q \pmod m,$$
*and consequently the support of the pattern over one period is*
$$\{a \in \{0,\dots,m-1\} : P(N,m,a) = 1\} \;=\; \{\,1 \bmod m,\ p \bmod m,\ q \bmod m\,\}.$$

*Proof.* By Lemma 2.2 the proper divisors of $N$ are exactly $\{1, p, q\}$, three distinct integers. By non-degeneracy they lie in three distinct classes mod $m$. Hence the filtered set $\{d \in \{1,p,q\} : d \equiv a\}$ has cardinality $1$ if $a$ matches one of the three classes and $0$ otherwise; the parity is then $1$ or $0$ correspondingly. $\square$

**Corollary 4.4 (Factor-residue recovery).** *Under the hypotheses of Theorem 4.3, deleting the a priori known class $1 \bmod m$ from the support yields exactly $\{p \bmod m,\ q \bmod m\}$.*

*Proof.* Immediate; the deletion is legitimate because $1 \bmod m$ is distinct from both $p \bmod m$ and $q \bmod m$. $\square$

Thus the primitive is a genuine *factorization certificate modulo $m$*: knowing the full pattern for a set of moduli whose product exceeds $q$ determines $p$ and $q$ by CRT reassembly. In this sense the primitive is powerful — which is what makes its cost analysis the interesting question.

**Corollary 4.5 (Support density).** *Under the hypotheses of Theorem 4.3, the support has exactly $3$ elements. The density of informative residue classes is therefore $3/m$.*

### 4.2 The decision-tree closure

**Theorem 4.6 (Adversary indistinguishability).** *Let $N = pq$ and $N' = p'q'$ be semiprimes, both non-degenerate at $m$. Let $Q$ be any set of queries such that for every $a \in Q$,*
$$a \bmod m \;\notin\; \{1, p, q\} \bmod m \quad\text{and}\quad a \bmod m \;\notin\; \{1, p', q'\} \bmod m.$$
*Then $P(N, m, a) = P(N', m, a)$ for all $a \in Q$: the two inputs produce identical transcripts.*

*Proof.* By Theorem 4.3, each side is $0$ at every $a \in Q$. $\square$

**Corollary (Query lower bound).** The union of the marked classes of two semiprimes has at most $6$ elements out of $m$. Hence any deterministic decision tree that distinguishes $N$ from $N'$ using only the primitive $P(N, m, \cdot)$ must query one of at most $6$ special classes; an adversary answering $0$ until forced can compel $m - 6$ queries. Thus $\Omega(m)$ queries are necessary in the worst case. Since useful factor recovery requires $m$ comparable to $q \approx \sqrt N$, this is an $\Omega(\sqrt N)$ query lower bound — barrier 4. Independently, evaluating a single query requires the list of divisors of $N$, i.e. factoring — barrier 6.

This is the analogue, for the divisor-parity primitive, of the classical decision-tree closure of the "is $x$ a multiple of $p$" primitive.

### 4.3 Exact characterization of failures

**Theorem 4.7 (Collision case).** *Let $p \ne q$ be primes with $p \equiv q \pmod m$ and $1 \not\equiv p \pmod m$, $m \ge 1$. Then*
$$\{a \in \{0,\dots,m-1\} : P(pq, m, a) = 1\} \;=\; \{1 \bmod m\}.$$

*Proof.* The proper divisors are $\{1, p, q\}$ with $p \equiv q$. At $a \equiv p$ the filtered set is $\{p, q\}$, of even cardinality, so the parity vanishes. At $a \equiv 1$ the filtered set is $\{1\}$, parity $1$. Elsewhere the set is empty. $\square$

So the failures of the primitive are exactly the merged-class cases: they are structural, not accidental, and they are genuinely unresolvable, since the two factors are then indistinguishable at the level of the modulus $m$. Small instances illustrate both regimes: for $N = 15$, $m = 7$ the support is $\{1,3,5\}$ and the factor residues $\{3,5\}$ are recovered; for $N = 15$, $m = 2$, where $3 \equiv 5 \equiv 1 \pmod 2$, the support degenerates to $\{1\}$.

---

## 5. Braid groups: the Burau image is order-finding

### 5.1 The representation

The three-strand braid group is $B_3 = \langle \sigma_1, \sigma_2 \mid \sigma_1\sigma_2\sigma_1 = \sigma_2\sigma_1\sigma_2\rangle$. Its reduced Burau representation, specialized at a ring element $a$, is given by

**Definition 5.1.** Over a commutative ring $R$ and for $a \in R$, set
$$r(\sigma_1) = \begin{pmatrix} -a & 1 \\ 0 & 1 \end{pmatrix}, \qquad r(\sigma_2) = \begin{pmatrix} 1 & 0 \\ a & -a \end{pmatrix}, \qquad B_a := r(\sigma_1)r(\sigma_2) = \begin{pmatrix} 0 & -a \\ a & -a\end{pmatrix}.$$

**Proposition 5.1 (Braid relation).** *$r(\sigma_1)r(\sigma_2)r(\sigma_1) = r(\sigma_2)r(\sigma_1)r(\sigma_2)$ over any commutative ring.*

*Proof.* Direct $2\times 2$ matrix computation; both sides equal $\begin{pmatrix} a^2 & -a \\ -a^2 & 0 \end{pmatrix}$ up to the sign convention fixed above. $\square$

So this is an honest, non-abelian, two-generator picture — precisely the kind of structure one hopes might evade the commutative barriers.

### 5.2 The full twist and the order

**Theorem 5.2 (Full-twist scalar).** *$B_a^3 = a^3 \cdot I$.*

*Proof.* Direct computation from the explicit form of $B_a$. Conceptually: $(\sigma_1\sigma_2)^3 = \Delta^2$ is the full twist, which generates the centre of $B_3$; central elements act by scalars in an irreducible representation, and the scalar here is $a^3$. $\square$

**Lemma 5.3.** *For all $s \ge 0$, $B_a^{3s} = a^{3s} \cdot I$.*

*Proof.* Induction on $s$ using Theorem 5.2 and the fact that scalar matrices are central. $\square$

**Theorem 5.4 (Order equation).** *Let $R$ be a nontrivial commutative ring and $a \in R$ a unit. Then for all $n \ge 0$,*
$$B_a^{\,n} = I \iff \bigl(3 \mid n \ \text{ and }\ a^n = 1\bigr),$$
*and consequently*
$$\operatorname{ord}(B_a) \;=\; \operatorname{lcm}\bigl(3,\ \operatorname{ord}(a)\bigr).$$

*Proof.* ($\Leftarrow$) If $n = 3s$ and $a^n = 1$ then $B_a^n = a^n I = I$ by Lemma 5.3.

($\Rightarrow$) Write $n = 3s + t$ with $t \in \{0,1,2\}$. By Lemma 5.3, $B_a^n = a^{3s} B_a^{t}$. Comparing the $(0,1)$ entries of $B_a^n = I$ gives $a^{3s}\cdot (B_a^t)_{01} = 0$; since $a^{3s}$ is a unit, $(B_a^t)_{01} = 0$. But $(B_a^1)_{01} = -a \ne 0$ and $(B_a^2)_{01} = a^2 \ne 0$, both because $a$ is a unit in a nontrivial ring. Hence $t = 0$ and $3 \mid n$. Then $a^n I = B_a^n = I$, and comparing $(0,0)$ entries gives $a^n = 1$.

The order formula follows: $\operatorname{lcm}(3,\operatorname{ord}(a))$ satisfies both conditions, so $\operatorname{ord}(B_a) \mid \operatorname{lcm}(3,\operatorname{ord}(a))$; conversely applying the equivalence to $n = \operatorname{ord}(B_a)$ shows $3 \mid n$ and $\operatorname{ord}(a) \mid n$, so $\operatorname{lcm}(3,\operatorname{ord}(a)) \mid \operatorname{ord}(B_a)$. $\square$

**Corollary 5.5 (Two-way reduction).** *For a unit $a$: $\operatorname{ord}(a) \mid \operatorname{ord}(B_a)$ and $\operatorname{ord}(B_a) \mid 3\operatorname{ord}(a)$. Computing braid orders and computing multiplicative orders are therefore the same computational problem, up to a factor of $3$.*

### 5.3 The invariant is factor-secret

**Theorem 5.7 (CRT splitting of order).** *Let $p, q$ be coprime and $a \in \mathbb{Z}/pq$. Then*
$$\operatorname{ord}_{pq}(a) \;=\; \operatorname{lcm}\bigl(\operatorname{ord}_p(\pi_p a),\ \operatorname{ord}_q(\pi_q a)\bigr).$$

*Proof.* The CRT map is a ring isomorphism $\mathbb{Z}/pq \to \mathbb{Z}/p \times \mathbb{Z}/q$, hence a multiplicative-monoid isomorphism, hence order-preserving. In a direct product the order of a pair is the lcm of the orders of the components. $\square$

**Corollary 5.8.** *For a unit $a$ modulo $N = pq$,*
$$\operatorname{ord}(B_a) \;=\; \operatorname{lcm}\bigl(3,\ \operatorname{ord}_p(a),\ \operatorname{ord}_q(a)\bigr).$$

This exhibits the braid-order invariant as an aggregate of the two prime-level orders — exactly the datum that Pollard's $p-1$ method exploits when it happens to be smooth, and exactly the datum that Shor's algorithm computes to factor. Computing it is not a new capability; it is the known dead end.

### 5.4 The group-order invariant

**Definition.** For a unit $a$ modulo $N$, the matrices $r(\sigma_1), r(\sigma_2)$ have determinants $-a$ and $-a$ respectively, hence are invertible; write $H_a = \langle r(\sigma_1), r(\sigma_2)\rangle \le \mathrm{GL}_2(\mathbb{Z}/N)$ for the Burau image.

**Theorem 5.9 (Lagrange for the Burau image).** *For a unit $a$ modulo $N$ with $N > 1$,*
$$\operatorname{lcm}\bigl(3, \operatorname{ord}_N(a)\bigr) \;\Big|\; |H_a|, \qquad\text{and in particular}\qquad \operatorname{ord}_N(a) \;\big|\; |H_a|.$$

*Proof.* The element $r(\sigma_1)r(\sigma_2) = B_a$ lies in $H_a$, and its order is $\operatorname{lcm}(3,\operatorname{ord}(a))$ by Theorem 5.4. By Lagrange's theorem the order of an element divides the order of the group. $\square$

So even the coarsest invariant of the braid image — its cardinality — is an order-finding measurement, and is therefore factor-secret by Corollary 5.8.

**Remark 5.10 (What the numerics see, and why it does not help).** Experimentally, $|H_a|$ carries *more* information than $\operatorname{ord}_N(a)$ alone: modulo $N = 21$, both $a = 2$ and $a = 5$ give $\operatorname{lcm}(\operatorname{ord}_3(a), \operatorname{ord}_7(a)) = 6$, yet the two Burau images have different cardinalities ($336$ versus $24$). The group order is sensitive to the *individual* pair $(\operatorname{ord}_p(a), \operatorname{ord}_q(a))$, not merely their lcm. This is a genuine refinement — and it is a refinement in exactly the direction that is unavailable: knowing the pair separately, rather than the lcm, is strictly closer to knowing $p$ and $q$. The extra sensitivity makes the invariant harder to compute, not easier.

**Remark 5.11 (The non-abelian hook).** The one genuinely non-commutative feature of the setting is that the swap $p \leftrightarrow q$ is not realized by any braid, so the representation does not automatically symmetrize the two prime-level data. This is what allows $|H_a|$ to separate the individual orders. But separation is not extraction: the separated data remain factor-secret, and the only route to them runs through order-finding.

---

## 6. Congruence blindness

### 6.1 Populating residue classes

We now turn to the second structural fact. Throughout, $m > 1$ is a modulus.

**Theorem 6.1 (Class population).** *Let $m \ge 1$, let $a \in \mathbb{Z}/m$ be a unit, let $p$ be a prime with $p$ invertible mod $m$, and let $B \in \mathbb{N}$. Then there exists a prime $r$ with $r > \max(B, p)$ such that*
$$pr \equiv a \pmod m \qquad\text{and}\qquad \operatorname{minFac}(pr) = p.$$

*Proof.* Since $p$ is a unit mod $m$, so is $p^{-1}a$. By Dirichlet's theorem on primes in arithmetic progressions there are infinitely many primes $r$ with $r \equiv p^{-1}a \pmod m$; pick one exceeding $\max(B, p)$. Then $pr \equiv p\cdot p^{-1}a = a \pmod m$. Since $p < r$ are both prime, the least prime factor of $pr$ is $p$: any prime divisor of $pr$ is $p$ or $r$, and $p$ is the smaller. $\square$

**Corollary 6.2 (Unboundedness inside a class).** *Fix $m$, a unit class $a$, and a bound $B$. Then within the class $a \bmod m$:*

1. *(gap) there are semiprimes $N = pr$ with $r - p > B$;*
2. *(least factor) there are semiprimes with least prime factor $p$, for every prime $p$ invertible mod $m$ — in particular the least prime factor is unbounded within the class.*

*Proof.* (1) apply Theorem 6.1 with threshold $B + p$; (2) is the statement of Theorem 6.1 read for varying $p$. $\square$

Corollary 6.2(1) closes the most plausible average-case loophole: the Fermat-easy family (small $|p-q|$) is not congruence-detectable, since every unit class contains semiprimes with arbitrarily *large* gap and, symmetrically, semiprimes with small gap.

### 6.2 The meta-theorem

**Definition 6.3.** An invariant $I : \mathbb{N} \to \mathbb{N}$ is *congruence-determined modulo $m$* if $N \equiv N' \pmod m$ implies $I(N) = I(N')$. It is *factor-revealing beyond $B$* if for all primes $p < r$ with $pr > B$, the value $I(pr)$ is a nontrivial divisor of $pr$, i.e. $I(pr) \mid pr$ and $1 < I(pr) < pr$.

Any statistic computed from finitely many congruence conditions on $N$ (parities, $N \bmod 8$, Jacobi symbols with fixed numerator, last-digit patterns) is congruence-determined modulo the lcm of the moduli involved.

**Proposition 6.3 (Non-vacuity).** *The least-prime-factor map $N \mapsto \operatorname{minFac}(N)$ is factor-revealing beyond $0$.*

*Proof.* For primes $p < r$, $\operatorname{minFac}(pr) = p$, which divides $pr$ and satisfies $1 < p < pr$. $\square$

This matters: it shows the meta-theorem below is an obstruction on the *congruence* side, not a triviality arising from an unsatisfiable factor-revealing condition.

**Theorem 6.4 (Coprime semiprimes in one class).** *For every $m > 1$ and every $B$ there exist primes $p_1 < r_1$ and $p_2 < r_2$, all four distinct, with $p_1r_1 > B$, $p_2r_2 > B$, and*
$$p_1 r_1 \equiv p_2 r_2 \pmod m.$$
*In particular $\gcd(p_1r_1, p_2r_2) = 1$.*

*Proof.* By Dirichlet choose primes $p_1 < p_2$ with $p_1 \equiv p_2 \equiv 1 \pmod m$. Apply Theorem 6.1 with $a = 1$ to $p_1$ (threshold $\max(B, p_2)$), obtaining $r_1$; then to $p_2$ (threshold $\max(B, r_1)$), obtaining $r_2$. This forces $p_1 < p_2 < r_1 < r_2$, so all four primes are distinct, and both products are $\equiv 1 \pmod m$ and exceed $B$. $\square$

**Theorem 6.5 (Free-witness meta-theorem).** *Let $m > 1$ and $B \in \mathbb{N}$. No invariant $I$ that is congruence-determined modulo $m$ is factor-revealing beyond $B$.*

*Proof.* Suppose $I$ were both. Take $N_1 = p_1r_1$, $N_2 = p_2r_2$ from Theorem 6.4. Since $N_1 \equiv N_2 \pmod m$, congruence-determination gives $d := I(N_1) = I(N_2)$. Factor-revealing gives $d \mid N_1$ with $1 < d < N_1$, so by Lemma 2.1, $d \in \{p_1, r_1\}$; similarly $d \in \{p_2, r_2\}$. But the four primes are distinct — contradiction. $\square$

**Corollary 6.6 (No congruence detector for the least prime factor).** *For every $m > 1$ and every $B$, there is no function $D : \mathbb{Z}/m \to \mathbb{N}$ with $D(N \bmod m) = \operatorname{minFac}(N)$ for all semiprimes $N > B$.*

**Corollary 6.7 (Applications to the free witnesses).** *For every $m > 1$ and every $B$, no congruence-determined invariant $I$ satisfies either*

1. *$I(pr) = \max(p,r)$ for all semiprimes $pr > B$ — so the quantity $N - d(C_2(N)) = \max(p,q)$ from Theorem 3.8 is not congruence-determined; or*
2. *$I(pr) = \operatorname{minFac}(pr)$ for all semiprimes $pr > B$ — so the equilibrium bid of the divisor congestion game (Section 8) is not congruence-determined.*

*Proof.* Each of $\max(p,r)$ and $\operatorname{minFac}(pr)$ is a nontrivial divisor of $pr$, so such an $I$ would be factor-revealing beyond $B$; apply Theorem 6.5. $\square$

### 6.3 Interpretation: the average-case question

The average-case proposal asks whether there is a density-one family of semiprimes, recognizable from $N$ alone in polynomial time, that factors below the $\sqrt N$ floor by a non-smoothness mechanism.

Corollaries 6.2, 6.6 and 6.7 close the congruence-recognizable case unconditionally: no residue-level statistic correlates with the position of the factorization at all. This matches the experimental record precisely — across large samples of semiprimes, Pollard-$\rho$ step counts are statistically indistinguishable across the classes $N \bmod 4$, $N \bmod 8$, and the value of the Jacobi symbol $(2/N)$; whereas the genuinely fast subfamily, small $|p - q|$, exhibits a dramatic effect (near-zero step counts in the smallest-gap decile against a typical count an order of magnitude larger) and is provably invisible from $N$ by Corollary 6.2(1). The remaining known fast families — smooth $p-1$, small gap — are measure-zero and are known methods in disguise.

---

## 7. Bounded candidate lists

A natural relaxation: instead of naming one divisor, let the congruence-determined function output a short *list* of candidates, one of which is promised to work. A list of length $L$ would give a factoring algorithm at the price of $L$ trial divisions, so the barrier framework predicts $L$ must be unbounded. We prove exactly this.

**Theorem 7.1 (Pairwise-coprime family in one class).** *For every $m > 1$, every $k$, and every $B$, there exist primes*
$$p_0 < r_0 < p_1 < r_1 < \cdots < p_{k-1} < r_{k-1},$$
*all exceeding $B$ and all congruent to $1 \bmod m$. The $k$ semiprimes $N_i = p_ir_i$ are then pairwise coprime and all satisfy $N_i \equiv 1 \pmod m$ and $N_i > B$.*

*Proof.* Induction on $k$, drawing each prime by Dirichlet's theorem from the class $1 \bmod m$ above the previous one. Strict increase makes the $2k$ primes distinct, hence the products pairwise coprime; $N_i \equiv 1\cdot 1 = 1 \pmod m$. $\square$

**Theorem 7.2 (No bounded congruence-determined candidate list).** *Fix $m > 1$, $k \in \mathbb{N}$ and $B \in \mathbb{N}$. Let $S : \mathbb{Z}/m \to \{\text{finite subsets of } \mathbb{N}\}$ satisfy $|S(a)| \le k$ for all $a$. Then there is a semiprime $N > B$ such that $S(N \bmod m)$ contains no nontrivial divisor of $N$.*

*Proof.* Suppose otherwise. Apply Theorem 7.1 with parameters $k+1$ and $B$, producing pairwise-coprime semiprimes $N_0, \dots, N_k > B$ all in the class $1 \bmod m$. For each $i$ the hypothesis yields $f(i) \in S(1)$ with $f(i) \mid N_i$, $1 < f(i) < N_i$, hence $f(i) \in \{p_i, r_i\}$ by Lemma 2.1. Since the blocks are strictly increasing, $i < j$ implies $f(i) \le r_i < p_j \le f(j)$, so $f$ is strictly increasing and in particular injective. Therefore $|S(1)| \ge k+1 > k$, contradicting the cardinality hypothesis. $\square$

So the "short list" relaxation is closed as well: a congruence-determined candidate list containing a factor of every large semiprime must have unbounded length, and is therefore not an algorithm.

---

## 8. The divisor congestion game

### 8.1 The game

**Definition 8.1.** For $N \ge 1$, the *divisor congestion game* on $N$ has admissible bids $d \in \{2, \dots, N-1\}$ and payoff
$$w_N(d) \;=\; \begin{cases} N/d, & d \mid N,\\ -N, & d \nmid N.\end{cases}$$
A bid $d$ is a *best response* if $w_N(e) \le w_N(d)$ for every admissible $e$.

The game is symmetric across players and the payoff has no interaction term, so equilibrium analysis reduces to the single-agent best-response problem; a profile is a Nash equilibrium exactly when every player plays a best response.

### 8.2 Solution

**Theorem 8.2 (A payoff query is a divisibility test).** *For $N > 0$: $w_N(d) \ge 0 \iff d \mid N$.*

*Proof.* If $d \mid N$ then $w_N(d) = N/d \ge 0$. Otherwise $w_N(d) = -N < 0$. $\square$

**Theorem 8.3 (Flat landscape).** *If $d \nmid N$ and $e \nmid N$, then $w_N(d) = w_N(e) = -N$.*

*Proof.* Immediate from the definition. $\square$

Thus the payoff surface is exactly constant off the divisor set: there is no gradient, and no local-search or hill-climbing procedure can be guided toward a divisor. The landscape is a plateau of size $\approx N$ punctuated by a handful of isolated pits.

**Theorem 8.4 (The least prime factor is a best response).** *Let $N$ be composite with $\operatorname{minFac}(N) < N$. Then for every admissible bid $d$, $w_N(d) \le w_N(\operatorname{minFac}(N))$.*

*Proof.* If $d \nmid N$ then $w_N(d) = -N \le 0 \le N/\operatorname{minFac}(N)$. If $d \mid N$ with $d \ge 2$, then $\operatorname{minFac}(N) \le d$ and hence $N/d \le N/\operatorname{minFac}(N)$. $\square$

**Theorem 8.5 (Uniqueness).** *Let $N$ be composite with $\operatorname{minFac}(N) < N$, and let $d$ be an admissible best response. Then $d = \operatorname{minFac}(N)$.*

*Proof.* Since $d$ is a best response, $w_N(\operatorname{minFac}(N)) \le w_N(d)$. As the left side is $N/\operatorname{minFac}(N) \ge 0$, Theorem 8.2 forces $d \mid N$, so $w_N(d) = N/d$ and hence $N/\operatorname{minFac}(N) \le N/d$. Combined with $\operatorname{minFac}(N) \le d$, which gives the reverse inequality, we get $N/d = N/\operatorname{minFac}(N)$. Multiplying by the respective divisors, $d \cdot (N/d) = N = \operatorname{minFac}(N)\cdot(N/\operatorname{minFac}(N))$ with equal cofactors, and the cofactor is positive; cancelling gives $d = \operatorname{minFac}(N)$. $\square$

**Theorem 8.6 (The equilibrium is the factorization).** *Let $N = pq$ with $p < q$ prime and let $d$ be an admissible best response. Then $d = p$, $w_N(d) = q$, and*
$$N \;=\; d \cdot w_N(d),$$
*with $d$ prime and $1 < d < N$. Reading off the equilibrium therefore yields the complete factorization of $N$.*

*Proof.* Specialize Theorem 8.5 to $N = pq$, where $\operatorname{minFac}(N) = p$; then $w_N(p) = N/p = q$. $\square$

### 8.3 The closure

The game therefore admits a unique Nash equilibrium, computable in polynomial time *given* the factorization, and the equilibrium encodes the factorization exactly. This is not an algorithm but a restatement:

1. **Circularity.** Evaluating any single payoff is a divisibility test (Theorem 8.2). An agent computing a best response by scanning the $N-2$ admissible bids is running trial division; the per-move cost is $\Theta(N)$.
2. **No shortcut via local structure.** The landscape is exactly flat off the divisors (Theorem 8.3), so no gradient, smoothness or continuity assumption can be exploited; standard equilibrium-computation heuristics based on iterated better-response dynamics have no signal to follow.
3. **No shortcut via residues.** The equilibrium bid is $\operatorname{minFac}(N)$, which by Corollary 6.7(2) is not congruence-determined, so it cannot be read off cheaply from residue data.

Verifying a claimed equilibrium is polynomial-time (one divisibility test plus one comparison); finding it is the original problem. The divisor congestion game is a poly-time-checkable restatement of factoring.

Concretely, for $N = 91 = 7\cdot 13$ the bid $7$ has payoff $13$ and dominates every other admissible bid; $91 = 7\cdot 13$ is read directly off the equilibrium.

---

## 9. Algorithms

For completeness we record the algorithmic content of the results as procedures. All are *reductions* or *verifications*; none is a factoring speedup, which is precisely the point.

**Algorithm A (Factor from minimum distance).** Input $N$ and the minimum distance $d$ of the degree-$\le 1$ evaluation code over $\mathbb{Z}/N$. Output $(p, q)$. Set $q \leftarrow N - d$, $p \leftarrow N/q$. Correctness: Theorem 3.8. Cost: $O(\operatorname{polylog} N)$ *given* $d$; obtaining $d$ costs $\Omega(N)$ by exhaustive weight search.

**Algorithm B (Factor-residue recovery from the parity oracle).** Input $N$, modulus $m$, oracle access to $P(N, m, \cdot)$. Query all $a \in \{0,\dots,m-1\}$; collect the support $S$; return $S \setminus \{1 \bmod m\}$. Correctness: Corollary 4.4 under non-degeneracy; Theorem 4.7 characterizes the degenerate outputs. Cost: $m$ oracle queries, and $\Omega(m)$ queries are necessary by Theorem 4.6; each query is itself a factorization.

**Algorithm C (Braid order).** Input $N$, a unit $a$. Return $\operatorname{lcm}(3, \operatorname{ord}_N(a))$. Correctness: Theorem 5.4. Conversely, given the braid order $L$, one recovers $\operatorname{ord}_N(a)$ as $L$ or $L/3$ by testing $a^{L/3} = 1$. Cost: identical to multiplicative order-finding, up to a constant.

**Algorithm D (Congruence-blindness witness).** Input $m > 1$, $B$. Search primes $\equiv 1 \bmod m$ in increasing order to produce $p_1 < p_2 < r_1 < r_2$ as in Theorem 6.4. Output the pair $(p_1r_1, p_2r_2)$: two coprime semiprimes above $B$ in the same class, defeating any congruence-determined divisor predictor. Extending to $k+1$ blocks (Theorem 7.1) defeats any candidate list of length $\le k$.

**Algorithm E (Game equilibrium).** Input composite $N$. For each $d \in \{2,\dots,N-1\}$ evaluate $w_N(d)$ and return the maximizer. Correctness: Theorem 8.5. Cost: $\Theta(N)$ divisibility tests — i.e. trial division.

---

## 10. Discussion

### 10.1 Six settings, one phenomenon

The free-witness phenomenon has now been exhibited in six structurally distinct settings: counts of elements of given norm in quadratic orders; group-order counts; class counts of binary quadratic forms; counts of subgroups in Heisenberg-type groups; modular indices attached to cusps; and — new here — minimum distances of evaluation codes. The invariants are of different mathematical types (cardinalities, class numbers, indices, metric distances) and the constructions are unrelated, yet the outcome is identical in each case: a scalar $t$ such that $(N,t)$ determines the factorization, reachable only at cost $\Omega(N)$ or via the factorization itself.

The unifying explanation is CRT splitting, and its scope is broad. Any invariant defined functorially from the ring $\mathbb{Z}/N$ inherits the product decomposition, hence is a function of the prime-level pair. To be useful the invariant must be *computable without* the splitting — and no known mechanism produces such computability for invariants that are sensitive to the splitting. Sensitivity and computability appear to be in direct tension.

### 10.2 What the two facts do *not* prove

Neither (F1) nor (F2) implies that factoring is hard, and we make no such claim. Theorem 6.5 rules out congruence-determined predictors, not arbitrary polynomial-time predictors: a polynomial-time algorithm may compute a function of $N$ that is *not* determined by any fixed residue class. Similarly, the free-witness results show that particular invariants are equivalent to factoring, not that no invariant is easier. The value of the framework is diagnostic: it tells you, given a new proposal, which of two well-understood walls it is about to hit, and it forces new proposals to explain how they evade both.

### 10.3 Sharpness of the individual results

Several of the results are sharp in a strong sense.

- Theorem 3.7 is an *equality*, valid for all $k \le p$, not an asymptotic bound; the extremal codeword is explicit.
- Theorem 5.4 is an *exact order formula* with a clean proof from the full-twist identity; the factor $3$ is unavoidable and reflects the centre of $B_3$.
- Theorem 4.7 shows that the failures of the parity primitive are exactly the merged-class cases, so nothing is lost by the non-degeneracy hypothesis of Theorem 4.3.
- Theorem 7.2 is tight in the parameter $k$: the witnessing family has exactly $k+1$ members.

### 10.4 The honest frontier

Taken together with the earlier rounds of this program, nineteen structurally distinct hypotheses have now been proposed, implemented, and closed, across three hundred-plus experiments. Every one of them has fallen to (F1), (F2), or a combination. No classical polynomial-time factoring algorithm has emerged, and the only known polynomial-time route remains the quantum one. The framework is intact — which is a statement about the state of our knowledge, not a theorem about the complexity of factoring.

---

## 11. Future directions

A careful analysis of these five closures exposes something the numerics alone did not: all of them factor through exactly the two structural facts (F1) and (F2). The following are the sharpest testable statements that this observation suggests.

**C1. The CRT-splitting dichotomy for evaluation codes.** For every $k \le \min(p,q)$ and every $N = pq$, we conjecture that the full *weight enumerator* of $C_k(N)$ — not merely its minimum distance — is the Hadamard product of the two prime-level Reed–Solomon weight enumerators, and that every "gap" in the spectrum (a weight not attained) determines $\max(p,q)$. Consequently a polynomial-time algorithm for *any single nonzero coefficient* of the weight enumerator would yield a factoring algorithm.

The key insight is that Theorem 3.5 is really a statement about the product structure of the zero set (Lemma 3.3): the whole weight spectrum, not just its minimum, is a product of prime-level spectra, so every spectral feature is a free witness. The minimum-distance case is fully settled (Theorem 3.7, exact for all $k \le p$); the general spectrum requires only a counting refinement of the same CRT injection, with no new machinery.

**C2. Beyond congruences: polynomial-time-determined invariants.** We conjecture that Theorem 6.5 generalizes from "determined by $N \bmod m$" to "determined by the value of a fixed polynomial-size arithmetic circuit evaluated on the digits of $N$": no such invariant names a nontrivial factor of every large semiprime, unless factoring is in polynomial time.

The key insight is that the Dirichlet argument used only one property of the class $\{N : N \equiv a \bmod m\}$ — that it contains two *coprime* semiprimes. Any invariant whose level sets contain two coprime semiprimes is blind in exactly the same way, and the level sets of small circuits are large. The meta-theorem is already stated for an arbitrary invariant $I : \mathbb{N} \to \mathbb{N}$; only the "level sets are rich" input has to be replaced, turning a number-theoretic lemma into a combinatorial one.

*Progress.* The *list* version of C2 is now settled: Theorem 7.2 shows that a congruence-determined function returning a whole set of candidate divisors, of size bounded by any fixed $k$, still fails on some large semiprime — the witness being the family of $k+1$ pairwise-coprime semiprimes in one residue class of Theorem 7.1. What remains open in C2 is replacing "congruence-determined" by "circuit-determined".

**C3. Braid invariants beyond the centre.** Theorem 5.4 concerns the specific element $\sigma_1\sigma_2$, whose cube is central. A natural next question is whether the *full* invariant theory of $H_a$ — conjugacy class sizes, the derived series, the trace spectrum — carries information beyond $(\operatorname{ord}_p(a), \operatorname{ord}_q(a))$, and whether any of it is computable without order-finding. Remark 5.10 shows that $|H_a|$ genuinely separates the individual prime-level orders, so the invariant theory is *richer* than the lcm; the conjecture is that this richness is uniformly factor-secret, i.e. that every isomorphism invariant of $H_a$ is determined by the pair $(\operatorname{ord}_p(a), \operatorname{ord}_q(a))$ together with $p$ and $q$, and that computing any of them is order-finding-hard.

**C4. Query complexity of divisor-statistic oracles.** Theorem 4.6 gives an $\Omega(m)$ deterministic query lower bound for the divisor-parity primitive. The randomized and quantum query complexities of the same primitive are open, as is the question for the natural generalizations $P_j(N,m,a) = \#\{d \mid N : d \equiv a\} \bmod j$ for $j > 2$, and for weighted variants such as $\sum_{d \equiv a} d$.

**C5. Game-theoretic restatements with nontrivial dynamics.** The divisor congestion game is closed because its landscape is exactly flat off the divisors (Theorem 8.3). A payoff function that interpolates — e.g. $w(d) = -\min_{e \mid N}|d - e|$, or $w(d) = -(N \bmod d)$ — would create genuine gradients. The question is whether any such interpolation is (i) computable in polynomial time from $N$ alone and (ii) has better-response dynamics converging in polynomial time. The two requirements appear to conflict, and formulating that conflict as a theorem is the natural next step.

---

## 12. Conclusion

Five proposals, drawn from coding theory, divisor combinatorics, braid groups, average-case analysis, and game theory, have been analyzed to completion. Each fails, and each fails for one of two reasons: either the Chinese Remainder splitting converts the proposed invariant into a free witness — a quantity that *is* the factorization, reachable only at cost $\Omega(N)$ — or Dirichlet's theorem renders the proposed cheap statistic blind to the factorization entirely.

The results are unconditional and exact where exactness is available: the minimum distance of the evaluation code over $\mathbb{Z}/pq$ is precisely $N - k\max(p,q)$; the braid element $\sigma_1\sigma_2$ has order precisely $\operatorname{lcm}(3, \operatorname{ord}(a))$; the divisor-parity support is precisely three residue classes; the game's unique equilibrium bid is precisely the least prime factor; and no congruence-determined function, or bounded-length list of functions, names a nontrivial divisor of every large semiprime.

What emerges is not a hardness proof but a map. Any future proposal that constructs an algebraic invariant over $\mathbb{Z}/N$ should expect the splitting to convert it into a free witness; any proposal that reads a statistic off $N$ should expect Dirichlet to blind it. An idea that escapes must escape both — and articulating *how* is now a precise and answerable demand.
