# The Order × Jacobi Joint Law for Semiprime Moduli: An Exact Coupling, a 2-Adic Dichotomy, and an Unconditional Barrier

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

Let $N = pq$ be a semiprime with $p \neq q$ odd primes. For each unit $b$
modulo $N$ we consider the pair $(\operatorname{ord}_N(b), J(b\mid N))$
consisting of the multiplicative order of $b$ and its Jacobi symbol, and we
study the multiset of all such pairs — the **order × Jacobi joint law** of $N$.

We establish three layers of results. First, at a single odd prime $p$ the
coupling between the two statistics is an exact equivalence: a unit is a
quadratic residue if and only if its order divides $H_p := (p-1)/2$; this is
Euler's criterion recast as a statement about element orders, with no error
term. Second, the lift of this equivalence to a semiprime is *not* exact in
general, and we determine precisely when it is: writing
$L = \operatorname{lcm}(H_p, H_q)$, the test $\operatorname{ord}_N(b) \mid L$
characterises the both-residue class for every unit **if and only if**
$v_2(H_p) = v_2(H_q)$, where $v_2$ is the $2$-adic valuation. The bottom rung
of this dial is the Blum condition $p \equiv q \equiv 3 \pmod 4$, on which the
four residue quadrants are exactly equinumerous, each of cardinality
$\varphi(N)/4$, and on which the Jacobi symbol is provably blind to the order
class (the units $1$ and $-1$ share the symbol $+1$ but lie in different order
classes). Third, and decisively, we exhibit a *collision*: the complete joint
laws of $35 = 5 \cdot 7$ and $39 = 3 \cdot 13$ coincide as multisets, while
$\gcd(35,39) = 1$. It follows unconditionally that no function of the joint law
alone can return a nontrivial divisor of its modulus. We give the structural
mechanism behind such collisions — any Jacobi-preserving isomorphism of unit
groups transports the entire joint law, so the law is an invariant of the pair
(unit group, quadratic character), a strictly coarser object than the
factorisation.

Numerically, the conditional bias
$\mathbb{E}[\operatorname{ord} \mid J{=}{+}1]/\mathbb{E}[\operatorname{ord} \mid J{=}{-}1]$
is genuinely below $1$, but its observed correlations with $p$, $q$, $p+q$ and
$|p-q|$ all lie inside a permutation null. The only surviving structure is a
residue dial determined by $N \bmod 4$. Combined with the circularity of
computing element orders modulo a composite, this closes the order × residue
quadrant of the statistical attack surface on semiprime factorisation.

**Keywords.** multiplicative order; Jacobi symbol; quadratic residues; Euler's
criterion; 2-adic valuation; Blum integers; semiprime; factorisation barrier;
joint law; law collision.

---

## 1. Introduction

### 1.1 Motivation

The security of a great deal of deployed public-key cryptography rests on the
presumed hardness of factoring a semiprime $N = pq$. Among the many families of
proposed attacks, the *statistical* family has a persistent appeal: one
computes a cheap, factor-oblivious statistic of $N$, observes that it exhibits
a bias, and asks whether the bias depends on $p$ and $q$ separately in a way
that could be inverted.

Two of the most classical statistics attached to a modulus are the
**multiplicative order** and the **Jacobi symbol**. They are complementary in a
suggestive way:

- the Jacobi symbol $J(b \mid N)$ is computable in $O(\log^2 N)$ time by
  quadratic reciprocity, *without knowing $p$ and $q$*;
- the multiplicative order $\operatorname{ord}_N(b)$ is, for general composite
  $N$, believed to be as hard as factoring — order-finding is the core of
  Shor's algorithm.

If the joint distribution of the cheap statistic and the expensive one carried
information about $p$ and $q$ individually, that would be a genuine leak. This
paper determines the joint distribution exactly and shows that it does not.

### 1.2 The object of study

**Definition (joint law).** For an odd integer $N > 1$, the *order × Jacobi
joint law* of $N$ is the multiset
$$\mathcal{L}(N) \;=\; \big\{\!\!\big\{\,\big(\operatorname{ord}_N(b),\; J(b\mid N)\big) \;:\; b \in (\mathbb{Z}/N\mathbb{Z})^\times \,\big\}\!\!\big\}.$$

This is the *maximal* statistic in its class. Every conditional law
$\operatorname{ord} \mid J = \pm 1$, every conditional moment, every quantile,
every entropy of the pair is a function of $\mathcal{L}(N)$. A barrier stated
at the level of $\mathcal{L}$ therefore rules out an entire family of attacks
at once, not merely the particular statistics that have been tried.

### 1.3 Summary of results

Throughout, $p \neq q$ are odd primes, $N = pq$,
$$H_p := \frac{p-1}{2}, \qquad H_q := \frac{q-1}{2}, \qquad L := \operatorname{lcm}(H_p, H_q),$$
and $v_2(m)$ denotes the exponent of $2$ in $m$.

1. **Exact coupling (Theorem 3.1).** For an odd prime $p$ and a unit $u$ modulo
   $p$: $u$ is a square $\iff \operatorname{ord}_p(u) \mid H_p$.
2. **Forward lift (Theorem 4.3).** If $b$ is a square modulo $p$ and modulo $q$
   then $\operatorname{ord}_N(b) \mid L$.
3. **Failure of the converse (Theorem 5.2).** If $p \equiv 3$ and
   $q \equiv 1 \pmod 4$, the unit $b = -1$ satisfies
   $\operatorname{ord}_N(b) \mid L$ but is a non-residue modulo $p$.
4. **The dichotomy (Theorem 5.5).** The converse holds for every unit **iff**
   $v_2(H_p) = v_2(H_q)$.
5. **Equidistribution (Theorem 6.4).** For $p \equiv q \equiv 3 \pmod 4$,
   $\#\{b : \operatorname{ord}_N(b) \mid L\} = H_p H_q = \varphi(N)/4$.
6. **Blindness (Theorem 6.5).** For $p \equiv q \equiv 3 \pmod 4$, the units
   $1$ and $-1$ both have Jacobi symbol $+1$, yet $\operatorname{ord}(1) \mid L$
   and $\operatorname{ord}(-1) \nmid L$.
7. **Collision (Theorem 7.2).** $\mathcal{L}(35) = \mathcal{L}(39)$.
8. **Barrier (Theorem 7.4).** No function $F$ of the joint law satisfies
   "$F(\mathcal{L}(N))$ is a nontrivial divisor of $N$" for both $N = 35$ and
   $N = 39$.
9. **Transport (Theorem 7.6).** A Jacobi-preserving isomorphism
   $(\mathbb{Z}/N_1)^\times \cong (\mathbb{Z}/N_2)^\times$ forces
   $\mathcal{L}(N_1) = \mathcal{L}(N_2)$.

### 1.4 Relation to the empirical picture

The results above were reached in dialogue with a substantial computational
survey: $14$ primes exhaustively, and $30$ near-equal-size semiprimes of
magnitude about $5 \times 10^6$ with $1500$ sampled units each. Three empirical
findings emerged, and each is now explained:

- the QR–order coupling verified perfectly on every one of $7000$ tested
  instances — explained by Theorem 3.1, which makes it an exact equivalence;
- the conditional bias
  $\mathbb{E}[\operatorname{ord} \mid J{=}{+}1]/\mathbb{E}[\operatorname{ord} \mid J{=}{-}1]
  \in [0.68, 1.01]$ is genuinely non-unit — explained by Theorems 4.3 and 6.4,
  since the $J = +1$ class contains the entire both-residue quadrant, whose
  members all have short order;
- observed correlations of the conditional means and their ratio with $p$, $q$,
  $p+q$ and $|p-q|$ never exceeded $0.31$, against permutation-null $95$th
  percentiles of $0.34$–$0.41$ — explained by Theorems 5.5, 7.2 and 7.6: the
  only structure the law carries is the $2$-adic dial, a function of
  $N \bmod 4$, and beyond that the law is many-to-one on moduli.

---

## 2. Notation and preliminaries

For an odd prime $p$, the group $(\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic of
order $p-1$. We write $H_p = (p-1)/2$ for the exponent of its unique index-$2$
subgroup, which we call the **half group** of $p$:
$$\mathcal{H}_p \;=\; \{\, u : \operatorname{ord}_p(u) \mid H_p \,\}.$$

Two elementary facts about $H_p$ recur:

**Lemma 2.1.** $2H_p = p-1$ for odd $p$; $H_p$ is odd iff $p \equiv 3 \pmod 4$;
and $2 \mid H_p$ iff $p \equiv 1 \pmod 4$.

*Proof.* Immediate from $H_p = (p-1)/2$: writing $p = 2k+1$ gives $H_p = k$, and
$k$ is odd exactly when $p = 2k+1 \equiv 3 \pmod 4$. $\square$

Consequently
$$v_2(H_p) = 0 \iff p \equiv 3 \pmod 4, \qquad v_2(H_p) \geq 1 \iff p \equiv 1 \pmod 4. \tag{2.1}$$

For $N = pq$ with $p \ne q$ odd primes, the Chinese Remainder Theorem gives a
group isomorphism
$$\pi : (\mathbb{Z}/N\mathbb{Z})^\times \;\xrightarrow{\ \sim\ }\; (\mathbb{Z}/p\mathbb{Z})^\times \times (\mathbb{Z}/q\mathbb{Z})^\times, \qquad \pi(b) = (b \bmod p,\; b \bmod q). \tag{2.2}$$

**Lemma 2.2 (order via components).** For $\gcd(p,q) = 1$ and any unit $b$
modulo $N = pq$,
$$\operatorname{ord}_N(b) \;=\; \operatorname{lcm}\!\big(\operatorname{ord}_p(b),\, \operatorname{ord}_q(b)\big).$$

*Proof.* $\pi$ is an injective homomorphism (indeed an isomorphism, since both
sides have $\varphi(N) = (p-1)(q-1)$ elements), and the order of an element of a
product group is the lcm of the orders of its components. $\square$

The **Legendre symbol** $\left(\frac{b}{p}\right)$ is $+1$ if $b$ is a nonzero
square modulo $p$ and $-1$ otherwise; the **Jacobi symbol** for $N = pq$ is
$J(b \mid N) = \left(\frac{b}{p}\right)\left(\frac{b}{q}\right)$.

---

## 3. Layer 1: the coupling is exact at a prime

**Theorem 3.1 (Exact QR–order coupling).** Let $p$ be an odd prime and let $u$
be a unit modulo $p$. Then
$$u \text{ is a quadratic residue} \quad\Longleftrightarrow\quad \operatorname{ord}_p(u) \mid H_p.$$

*Proof sketch.* Both sides are characterisations of the unique index-$2$
subgroup. Concretely, $\operatorname{ord}_p(u) \mid H_p$ is equivalent to
$u^{H_p} = 1$, i.e. to $u^{(p-1)/2} = 1$, which by Euler's criterion holds
exactly when $u$ is a square. Alternatively and more structurally: writing $g$
for a generator, $u = g^k$ is a square iff $k$ is even, and $g^k$ satisfies
$(g^k)^{(p-1)/2} = g^{k(p-1)/2} = 1$ iff $(p-1) \mid k(p-1)/2$ iff $k$ is even.
$\square$

**Corollary 3.2 (Legendre form).** For an odd prime $p$ and a unit $u$,
$\left(\frac{u}{p}\right) = 1 \iff \operatorname{ord}_p(u) \mid H_p$.

Theorem 3.1 deserves emphasis because it explains the empirical observation
that the coupling verified on $7000$ out of $7000$ tested instances. There is
no statistical content: the "$7000/7000$" is not a strong bias but a theorem
with no exceptions. Residues *are* the short-order elements.

**Remark 3.3 (asymmetry of cost).** Theorem 3.1 does not make order-finding
easy. It says the single bit "is $\operatorname{ord}_p(u) \mid H_p$?" is
computable in polynomial time at a *known* prime. It says nothing about the
value of $\operatorname{ord}_p(u)$, and nothing at all about a composite
modulus.

---

## 4. Layer 2, forward direction: residues have short order

Fix $N = pq$ with $p \ne q$ odd primes and set
$L = \operatorname{lcm}(H_p, H_q)$.

**Definition 4.1 (order class and residue quadrants).**
$$\mathcal{O}_N \;=\; \{\, b \in (\mathbb{Z}/N)^\times : \operatorname{ord}_N(b) \mid L \,\}, \qquad
\mathcal{Q}^{\varepsilon\delta}_N \;=\; \Big\{\, b : \left(\tfrac{b}{p}\right) = \varepsilon,\; \left(\tfrac{b}{q}\right) = \delta \,\Big\}$$
for $\varepsilon, \delta \in \{\pm 1\}$. We call $\mathcal{Q}^{++}_N$ the
*both-residue quadrant*.

**Theorem 4.3 (Forward half of the joint law).**
$\mathcal{Q}^{++}_N \subseteq \mathcal{O}_N$. That is, if $b$ is a quadratic
residue modulo $p$ and modulo $q$, then $\operatorname{ord}_N(b) \mid L$.

*Proof.* By Theorem 3.1 applied at each prime,
$\operatorname{ord}_p(b) \mid H_p \mid L$ and
$\operatorname{ord}_q(b) \mid H_q \mid L$. By Lemma 2.2,
$\operatorname{ord}_N(b) = \operatorname{lcm}(\operatorname{ord}_p(b), \operatorname{ord}_q(b))$
divides $L$. $\square$

This inclusion is the entire source of the observed conditional bias: the
$J = +1$ class is $\mathcal{Q}^{++}_N \sqcup \mathcal{Q}^{--}_N$, and the first
of these summands consists exclusively of elements of order dividing $L$. Since
$L \le \varphi(N)/4$ in general, the $+1$ class is diluted with short orders,
depressing its conditional mean.

---

## 5. Layer 2, converse: the 2-adic dichotomy

The reverse inclusion $\mathcal{O}_N \subseteq \mathcal{Q}^{++}_N$ is false in
general. This section determines exactly when it holds.

### 5.1 The arithmetic core

**Lemma 5.1 (lcm–gcd lattice lemma).** Let $a, x, y$ be positive integers with
$a \mid 2x$, $a \mid \operatorname{lcm}(x, y)$ and $v_2(y) \le v_2(x)$. Then
$a \mid x$.

*Proof sketch.* It suffices to show
$\gcd(2x, \operatorname{lcm}(x,y)) \mid x$, since $a$ divides the left-hand
side. Compare $\ell$-adic valuations for each prime $\ell$. For $\ell$ odd,
$$\min\big(v_\ell(2x),\, \max(v_\ell(x), v_\ell(y))\big) = \min\big(v_\ell(x), \max(v_\ell(x), v_\ell(y))\big) = v_\ell(x).$$
For $\ell = 2$, using $v_2(y) \le v_2(x)$,
$$\min\big(1 + v_2(x),\, \max(v_2(x), v_2(y))\big) = \min\big(1 + v_2(x),\, v_2(x)\big) = v_2(x).$$
Hence every valuation of the gcd is at most the corresponding valuation of $x$.
$\square$

Lemma 5.1 is the pivot of the whole paper. It isolates the *only* way the lift
can fail: through a surplus power of $2$.

### 5.2 A counterexample when the dial is unbalanced

**Theorem 5.2 (Failure of the converse).** Suppose $p \equiv 3 \pmod 4$ and
$q \equiv 1 \pmod 4$. Then $b = -1$ satisfies $\operatorname{ord}_N(b) \mid L$
while $\left(\frac{-1}{p}\right) = -1$. In particular
$\mathcal{O}_N \not\subseteq \mathcal{Q}^{++}_N$.

*Proof.* $\operatorname{ord}_N(-1) = 2$. Since $q \equiv 1 \pmod 4$, Lemma 2.1
gives $2 \mid H_q$, hence $2 \mid L$ and $-1 \in \mathcal{O}_N$. Since
$p \equiv 3 \pmod 4$, $-1$ is a quadratic non-residue modulo $p$ by the first
supplement to quadratic reciprocity. $\square$

**Example 5.3.** $N = 39 = 3 \cdot 13$: $H_3 = 1$, $H_{13} = 6$, $L = 6$. The
unit $38 \equiv -1$ has order $2 \mid 6$, but $38 \equiv 2 \pmod 3$ is a
non-residue modulo $3$.

### 5.3 Sufficiency of balance

**Theorem 5.4 (Sharp converse under 2-adic balance).** If
$v_2(H_p) = v_2(H_q)$, then for every unit $b$ modulo $N$,
$$\operatorname{ord}_N(b) \mid L \quad\Longrightarrow\quad \left(\tfrac{b}{p}\right) = \left(\tfrac{b}{q}\right) = 1.$$

*Proof sketch.* Let $a = \operatorname{ord}_p(b)$. Since
$(\mathbb{Z}/p)^\times$ has order $p-1 = 2H_p$ we have $a \mid 2H_p$. By
Lemma 2.2, $a \mid \operatorname{ord}_N(b) \mid L = \operatorname{lcm}(H_p, H_q)$.
The hypothesis gives $v_2(H_q) \le v_2(H_p)$, so Lemma 5.1 (with $x = H_p$,
$y = H_q$) yields $a \mid H_p$, and Theorem 3.1 makes $b$ a residue modulo $p$.
The argument at $q$ is symmetric, using $v_2(H_p) \le v_2(H_q)$ and
$\operatorname{lcm}(H_q, H_p) = L$. $\square$

### 5.4 Necessity, and the dichotomy

**Lemma 5.4a (existence of a low-order non-residue).** Let $p$ be an odd prime
and $m$ a positive integer with $v_2(H_p) < v_2(m)$. Then there is a unit $x$
modulo $p$ with $\operatorname{ord}_p(x) \mid m$ and $x$ a non-residue.

*Proof sketch.* Write $s = v_2(H_p)$, so $2^{s+1} \mid p-1$ and
$2^{s+1} \mid m$ (as $v_2(m) \ge s+1$). The cyclic group
$(\mathbb{Z}/p)^\times$ contains an element $x$ of order exactly $2^{s+1}$.
Then $\operatorname{ord}_p(x) = 2^{s+1} \mid m$. But $2^{s+1} \nmid H_p$
because $v_2(H_p) = s$, so $\operatorname{ord}_p(x) \nmid H_p$, and by
Theorem 3.1 $x$ is a non-residue. $\square$

**Theorem 5.5 (The exact dichotomy).** Let $N = pq$ with $p \ne q$ odd primes.
Then
$$\Big(\forall b \in (\mathbb{Z}/N)^\times:\; \operatorname{ord}_N(b) \mid L \iff \left(\tfrac{b}{p}\right) = \left(\tfrac{b}{q}\right) = 1\Big)
\quad\Longleftrightarrow\quad v_2(H_p) = v_2(H_q).$$

*Proof.* ($\Leftarrow$) Theorem 4.3 gives one implication for every $b$;
Theorem 5.4 gives the other under balance.

($\Rightarrow$) Suppose $v_2(H_p) \ne v_2(H_q)$; without loss of generality
$v_2(H_p) < v_2(H_q)$. By Lemma 5.4a with $m = H_q$ there is a non-residue $x$
modulo $p$ with $\operatorname{ord}_p(x) \mid H_q$. Using the CRT isomorphism
(2.2), let $b$ correspond to the pair $(x, 1)$. Then
$\operatorname{ord}_N(b) = \operatorname{lcm}(\operatorname{ord}_p(x), 1)
\mid H_q \mid L$, while $b$ is a non-residue modulo $p$. So the equivalence
fails at $b$. $\square$

**Corollary 5.6 (The dial and its bottom rung).** By (2.1), $v_2(H_p) = 0$ iff
$p \equiv 3 \pmod 4$. Hence the balance condition holds automatically when
$p \equiv q \equiv 3 \pmod 4$ — the *Blum* case — and in that case the
equivalence
$$\operatorname{ord}_N(b) \mid L \iff b \in \mathcal{Q}^{++}_N$$
holds for every unit. More generally, balance is a comparison of two integers,
$v_2(H_p)$ and $v_2(H_q)$: a single **dial**, whose lowest setting is a
condition on $p$ and $q$ modulo $4$ and hence visible in $N \bmod 4$ together
with the (public) knowledge that $N$ is a semiprime.

---

## 6. Layer 2, quantitative: equal quadrants and a blind symbol

Throughout this section $p \equiv q \equiv 3 \pmod 4$.

**Lemma 6.1 (counting squares at a prime).** For an odd prime $p$, the squaring
endomorphism of $(\mathbb{Z}/p)^\times$ has kernel of size $2$ (namely
$\{\pm 1\}$), hence image of size $H_p$. So there are exactly $H_p$ quadratic
residues.

**Lemma 6.2 (size of the unit group).** For $N = pq$ with $p \ne q$ odd primes,
$$\#(\mathbb{Z}/N)^\times = \varphi(N) = (p-1)(q-1) = 4 H_p H_q.$$

**Theorem 6.3 (Equinumerous residue quadrants).** For each choice of signs
$\varepsilon, \delta \in \{\pm 1\}$,
$$\#\mathcal{Q}^{\varepsilon\delta}_N = H_p H_q = \tfrac{1}{4}\varphi(N).$$

*Proof.* Under the CRT isomorphism (2.2), $\mathcal{Q}^{\varepsilon\delta}_N$
corresponds to a product of a fibre of the Legendre symbol at $p$ with a fibre
at $q$. Each fibre has $H_p$ (resp. $H_q$) elements by Lemma 6.1, so the
product has $H_p H_q$; by Lemma 6.2 this is $\varphi(N)/4$. $\square$

**Theorem 6.4 (Quantitative joint law on the Blum dial).** For
$p \equiv q \equiv 3 \pmod 4$,
$$\#\mathcal{O}_N \;=\; H_p H_q \;=\; \tfrac{1}{4}\varphi(N), \qquad\text{equivalently}\qquad 4 \cdot \#\mathcal{O}_N = \#(\mathbb{Z}/N)^\times.$$

*Proof.* By Corollary 5.6, $\mathcal{O}_N = \mathcal{Q}^{++}_N$; apply
Theorem 6.3. $\square$

**Theorem 6.5 (The Jacobi symbol is blind to the order class).** For
$p \equiv q \equiv 3 \pmod 4$,
$$J(1 \mid N) = J(-1 \mid N) = +1, \qquad \operatorname{ord}_N(1) \mid L, \qquad \operatorname{ord}_N(-1) \nmid L.$$

*Proof.* $N = pq \equiv 3 \cdot 3 \equiv 1 \pmod 4$, so by the first supplement
for Jacobi symbols $J(-1\mid N) = (-1)^{(N-1)/2} = +1$; trivially
$J(1 \mid N) = +1$. Now $\operatorname{ord}_N(1) = 1$ divides everything, while
$\operatorname{ord}_N(-1) = 2$; and $L = \operatorname{lcm}(H_p, H_q)$ is odd
because both $H_p$ and $H_q$ are odd by Lemma 2.1. Hence $2 \nmid L$. $\square$

**Interpretation.** The Jacobi symbol is the *product* of the two Legendre
symbols, so it merges $\mathcal{Q}^{++}_N$ with $\mathcal{Q}^{--}_N$. The order
class $\mathcal{O}_N$ is exactly $\mathcal{Q}^{++}_N$, i.e. half of the $J = +1$
class. Theorem 6.5 exhibits an explicit witnessing pair: $1 \in \mathcal{Q}^{++}$
and $-1 \in \mathcal{Q}^{--}$ (since $-1$ is a non-residue at both primes when
both are $3 \bmod 4$) are indistinguishable to the symbol and distinguishable
by the order. The order statistic is strictly finer than the symbol, and the
extra information is exactly the information that would require knowing $p$ and
$q$.

**Corollary 6.6 (source of the conditional bias).** Conditioning on $J = +1$
selects a class of size $\varphi(N)/2$, exactly half of which
($\varphi(N)/4$ elements, namely $\mathcal{Q}^{++}_N$) has order dividing the
odd number $L \le H_p H_q$. Conditioning on $J = -1$ selects
$\mathcal{Q}^{+-} \sqcup \mathcal{Q}^{-+}$, none of which lies in
$\mathcal{O}_N$. Hence
$$\mathbb{E}[\operatorname{ord}_N \mid J = +1] \;<\; \mathbb{E}[\operatorname{ord}_N \mid J = -1]$$
is structurally forced, which is precisely the observed bias.

**Numerical observation 6.7.** For every tested $N = pq$ with
$p \equiv q \equiv 3 \pmod 4$ — including $21, 33, 77, 133, 209, 437, 713$ —
the ratio in Corollary 6.6 equals exactly $3/4$. This is an empirical
observation, not a theorem of this paper, and it is a natural target for future
work (see §10).

---

## 7. Layer 3: the joint law does not determine the factorisation

We now turn to the decisive obstruction. Everything above describes the *shape*
of the joint law; this section shows the shape is not injective in $N$.

### 7.1 Computable presentation

To make the joint law an object one can evaluate and compare exactly, we use a
manifestly computable presentation. For $b$ coprime to $N$, let
$$\operatorname{ord}^{\mathrm{c}}(N, b) = \min\{\, k \in [1, N] : b^k \equiv 1 \bmod N \,\},$$
which agrees with $\operatorname{ord}_N(b)$ because the order of a unit is at
most $\varphi(N) < N$. For an odd prime $p$ and $p \nmid b$, Euler's criterion
gives the computable symbol
$$\operatorname{qr}(p, b) = \begin{cases} +1 & \text{if } b^{(p-1)/2} \equiv 1 \bmod p, \\ -1 & \text{otherwise,}\end{cases}$$
and $\operatorname{qr}(p,b) = \left(\frac{b}{p}\right)$. Consequently, for
$N = pq$,
$$\mathcal{L}(N) = \big\{\!\!\big\{\, \big(\operatorname{ord}^{\mathrm{c}}(N,b),\; \operatorname{qr}(p,b)\cdot\operatorname{qr}(q,b)\big) : 0 \le b < N,\ \gcd(b,N) = 1 \,\big\}\!\!\big\}. \tag{7.1}$$

Presentation (7.1) reduces the equality of two joint laws to a finite,
exhaustive computation.

### 7.2 The collision

**Theorem 7.2 (Two coprime semiprimes with the same joint law).**
$$\mathcal{L}(35) \;=\; \mathcal{L}(39).$$

*Proof.* Both moduli have $\varphi(35) = \varphi(39) = 24$ units. Evaluating
(7.1) at $35 = 5 \cdot 7$ and at $39 = 3 \cdot 13$ gives the same multiset:

| $(\operatorname{ord},\,J)$ | $(1,+1)$ | $(2,+1)$ | $(2,-1)$ | $(3,+1)$ | $(4,+1)$ | $(4,-1)$ | $(6,+1)$ | $(6,-1)$ | $(12,+1)$ | $(12,-1)$ |
|---|---|---|---|---|---|---|---|---|---|---|
| in $\mathcal{L}(35)$ | 1 | 1 | 2 | 2 | 2 | 2 | 2 | 4 | 4 | 4 |
| in $\mathcal{L}(39)$ | 1 | 1 | 2 | 2 | 2 | 2 | 2 | 4 | 4 | 4 |

Both rows sum to $24$. $\square$

**Corollary 7.3 (all conditional laws collide).** For each
$\varepsilon \in \{\pm 1\}$, the conditional laws
$\mathcal{L}(35)\!\restriction_{J = \varepsilon}$ and
$\mathcal{L}(39)\!\restriction_{J = \varepsilon}$ coincide; in particular the
conditional order sums agree ($77$ at $J = +1$ and $84$ at $J = -1$ for both
moduli), hence so do the conditional means, variances and all higher moments.

### 7.3 The barrier

**Theorem 7.4 (Abstract barrier).** Let $N_1, N_2$ be coprime with
$\mathcal{L}(N_1) = \mathcal{L}(N_2)$, and let $F$ be any function from
multisets of pairs to natural numbers. Then it is impossible that
$$F(\mathcal{L}(N_i)) > 1 \quad\text{and}\quad F(\mathcal{L}(N_i)) \mid N_i \quad \text{for } i = 1, 2.$$

*Proof.* Write $d = F(\mathcal{L}(N_1)) = F(\mathcal{L}(N_2))$, well defined
because the arguments are equal. Then $d \mid N_1$ and $d \mid N_2$, so
$d \mid \gcd(N_1, N_2) = 1$, whence $d = 1$, contradicting $d > 1$. $\square$

**Theorem 7.5 (Concrete barrier).** There is no function $F$ from joint laws to
natural numbers such that for every $N \in \{35, 39\}$, $F(\mathcal{L}(N))$ is a
nontrivial divisor of $N$.

*Proof.* Combine Theorem 7.2, $\gcd(35,39) = 1$, and Theorem 7.4. $\square$

Two features of Theorem 7.5 deserve emphasis. It is **unconditional**: no
unproved hypothesis, no asymptotic regime, no restriction on the computational
power of $F$ — $F$ may be arbitrary, even non-computable. And it is
**maximal**: since every conditional statistic of the pair (order, Jacobi) is a
function of $\mathcal{L}$, the theorem simultaneously refutes every attack in
this family, including ones not yet proposed.

### 7.4 Why collisions are structural

**Theorem 7.6 (Transport of the joint law).** Let $N_1, N_2$ be odd moduli and
let
$$e : (\mathbb{Z}/N_1)^\times \xrightarrow{\ \sim\ } (\mathbb{Z}/N_2)^\times$$
be a group isomorphism satisfying $J(e(u) \mid N_2) = J(u \mid N_1)$ for all
$u$. Then $\mathcal{L}(N_1) = \mathcal{L}(N_2)$.

*Proof.* A group isomorphism preserves element orders:
$\operatorname{ord}(e(u)) = \operatorname{ord}(u)$. Combined with the
hypothesis on symbols, the map $u \mapsto e(u)$ carries each pair
$(\operatorname{ord}(u), J(u \mid N_1))$ to the identical pair
$(\operatorname{ord}(e(u)), J(e(u) \mid N_2))$. Since $e$ is a bijection, it
induces an equality of the two multisets. $\square$

**Interpretation (the coarse invariant).** Theorem 7.6 says that
$\mathcal{L}$ is not really a function of $N$; it is a function of the
isomorphism class of the pair
$$\big( (\mathbb{Z}/N)^\times, \; J(\,\cdot\mid N) \big)$$
— an abelian group of order $\varphi(N)$ together with a quadratic character on
it. For $N = pq$ the group is
$\mathbb{Z}_{p-1} \times \mathbb{Z}_{q-1}$. The number of isomorphism classes
of such pairs with $\varphi(N) \le Y$ grows far more slowly than the number of
semiprimes with $\varphi(N) \le Y$, so collisions are forced by pigeonhole in
the quotient category rather than being numerical accidents.

**Example 7.7.** Our collision is exactly of this type:
$(\mathbb{Z}/35)^\times \cong \mathbb{Z}_4 \times \mathbb{Z}_6$ and
$(\mathbb{Z}/39)^\times \cong \mathbb{Z}_2 \times \mathbb{Z}_{12}$, and both
are isomorphic to $\mathbb{Z}_2 \times \mathbb{Z}_4 \times \mathbb{Z}_3$; the
quadratic character corresponds under this identification, so Theorem 7.6
applies.

**Numerical observation 7.8 (collisions are common already at small scale).** An
exhaustive search over the $73$ semiprimes $N = pq < 400$ with $p < q$ odd
primes finds only $62$ distinct joint laws. Ten of those laws are shared by two
or more *pairwise coprime* moduli, each such sharing yielding an independent
instance of Theorem 7.4. Examples include
$\{35, 39\}$, $\{77, 93\}$, $\{95, 111\}$, $\{143, 155, 183\}$,
$\{161, 201\}$, $\{203, 215\}$, $\{247, 259\}$, $\{299, 335\}$ and
$\{319, 355\}$. The triple $\{143, 155, 183\}$ is instructive: the three unit
groups $\mathbb{Z}_{10}\times\mathbb{Z}_{12}$,
$\mathbb{Z}_4 \times \mathbb{Z}_{30}$ and
$\mathbb{Z}_2 \times \mathbb{Z}_{60}$ are all the same abelian group of order
$120$. This is exactly the pigeonhole behaviour predicted by Theorem 7.6, and it
is the empirical basis for Conjecture C1 below.

---

## 8. Algorithms

We record the procedures underlying the computational content, with
complexities in terms of $N$ and the cost $M(N)$ of a modular multiplication.

### 8.1 Order-class test at a known prime

Given an odd prime $p$ and a unit $b$, decide whether
$\operatorname{ord}_p(b) \mid H_p$.

```
Input : odd prime p, integer b with p ∤ b
Output: true iff b is a quadratic residue mod p
1. H ← (p − 1) / 2
2. r ← b^H mod p            // fast modular exponentiation
3. return (r = 1)
```

Cost: $O(\log p)$ modular multiplications. Correctness is Theorem 3.1. Note the
output is simultaneously the answer to "is $b$ a square?" and to "does the
order divide the half order?" — this is the coupling in algorithmic form.

### 8.2 Two-adic balance test

Given $p, q$, decide whether the lift of the coupling to $N = pq$ is exact.

```
Input : odd primes p ≠ q
Output: true iff the order test ord_N(b) | lcm(H_p, H_q) exactly
        characterises the both-residue quadrant
1. Hp ← (p − 1)/2 ;  Hq ← (q − 1)/2
2. a ← v2(Hp)  // number of times 2 divides Hp
3. c ← v2(Hq)
4. return (a = c)
```

Cost: $O(\log N)$ bit operations. Correctness is Theorem 5.5. In particular the
test returns true whenever $p \equiv q \equiv 3 \pmod 4$ (both valuations $0$).
Crucially, this algorithm requires $p$ and $q$: it is *not* available to an
adversary holding only $N$.

### 8.3 Exhaustive joint-law computation and collision search

```
Input : odd modulus N with known factorisation N = p·q
Output: the multiset L(N) of pairs (order, Jacobi symbol)
1. L ← empty multiset
2. for b = 0 .. N−1:
3.     if gcd(b, N) ≠ 1: continue
4.     d ← ord_p(b) computed by factoring p−1 and peeling prime powers
5.     e ← ord_q(b) computed likewise from q−1
6.     o ← lcm(d, e)                             // Lemma 2.2
7.     j ← qr(p, b) · qr(q, b)                   // Euler's criterion twice
8.     insert (o, j) into L
9. return L
```

Cost: $O(\varphi(N) \log^2 N)$ modular operations with the component method of
lines 4–6 (the naive definition-chasing search would be $O(N^2)$). Collision
search then compares the resulting multisets over a list of candidate moduli;
sorting the pairs canonically makes each comparison $O(\varphi(N)\log\varphi(N))$.

Line 4 is where the circularity bites: computing $\operatorname{ord}_p(b)$
efficiently requires knowing $p$ and the factorisation of $p-1$. An adversary
who could run this algorithm on a large $N$ has already won.

### 8.4 Permutation test for factor dependence

```
Input : list of triples (p_i, q_i, r_i), where r_i is the bias ratio for N_i
        covariate function f (e.g. f(p,q) = |p − q|), trial count T
Output: observed correlation and the null 95th percentile
1. x_i ← f(p_i, q_i) for each i
2. obs ← |Pearson(x, r)|
3. for t = 1 .. T:
4.     r' ← uniformly random permutation of r
5.     null_t ← |Pearson(x, r')|
6. sort null;  p95 ← null at index ⌈0.95 T⌉
7. return (obs, p95)
```

Cost: $O(Tn)$ after $O(n)$ preprocessing. This is the procedure that produced
the reported observed correlations $\le 0.31$ against null $95$th percentiles
of $0.34$–$0.41$.

---

## 9. Discussion

### 9.1 Three independent obstructions

The order × Jacobi statistic fails as a factoring route for three logically
independent reasons, each sufficient on its own.

**(i) It is a residue dial.** By Theorem 5.5 the entire structure of the joint
law is controlled by the comparison $v_2(H_p) \overset{?}{=} v_2(H_q)$. Its
bottom rung, $p \equiv q \equiv 3 \pmod 4$, is a condition on $N \bmod 4$. On
that rung the quadrants are exactly equal (Theorem 6.4) — no excess to exploit.

**(ii) It is circular.** Evaluating the law requires component orders
(algorithm 8.3, line 4), and computing multiplicative order modulo a composite
is, so far as is known, no easier than factoring. The statistic that is
supposed to reveal $p$ and $q$ presupposes them.

**(iii) It collides.** Theorem 7.5 removes the last hope: even granting an
oracle for the law, no function of it can factor, because two coprime moduli
already share the law. Theorem 7.6 shows this is generic, not lucky.

### 9.2 What the empirical bias actually was

It is instructive that the empirically observed conditional bias — real,
reproducible, with ratio strictly below $1$ — is now fully explained by
Corollary 6.6 as an artefact of the coset structure, with no residual
factor-dependence. This is the characteristic signature of a *closed* attack
surface: the signal exists, the mechanism is understood, and the mechanism is
factor-oblivious. Reported correlations with $p$, $q$, $p+q$, $|p-q|$ never
exceeded $0.31$ against a permutation null whose $95$th percentile ranged over
$0.34$–$0.41$; the theory now says why they must not exceed it.

### 9.3 Positive content

Independently of any cryptographic reading, the results are of intrinsic
interest.

- Euler's criterion is a statement about **cycle lengths**: the quadratic
  residues are precisely the elements of short order (Theorem 3.1).
- The failure of this to lift to composites is measured by a **single 2-adic
  invariant** (Theorem 5.5), a clean example of a local–global obstruction
  concentrated at one prime.
- The **Blum integers** $p \equiv q \equiv 3 \pmod 4$ acquire a new
  characterisation: they are exactly the semiprimes on the lowest rung of the
  dial, where the order test is an exact test for double residuosity.
- The joint law is a functor-like invariant of the pair (unit group, quadratic
  character) (Theorem 7.6), and the study of its fibres is a well-posed
  question in multiplicative number theory.

### 9.4 Scope and limitations

The barrier is about *the joint law of the pair (order, Jacobi symbol) over all
units*. It says nothing about:

- statistics of order alone against auxiliary structure not derivable from the
  law (though the law is quite comprehensive);
- attacks that use partial information about $p$ or $q$ (Coppersmith-type
  methods), which fall outside the "hint-free classical" regime;
- quantum order-finding, which uses the order of a single element in a
  fundamentally different way.

The collision is exhibited at $N = 35, 39$. That is enough for the barrier as
stated, because the barrier is a universal statement over functions $F$; but it
leaves open the *density* of collisions at cryptographic sizes, which is
Conjecture C1 below.

---

## 10. Future directions

The verified results are: (1) the QR–order coupling is an exact equivalence at
each prime; (2) its lift to a semiprime is exact **iff**
$v_2\!\big(\tfrac{p-1}{2}\big) = v_2\!\big(\tfrac{q-1}{2}\big)$ — a single
2-adic dial, whose bottom rung is $p \equiv q \equiv 3 \pmod 4$; (3) on that
dial the four order/Jacobi quadrants are equinumerous, each of size
$\varphi(N)/4$; (4) the complete joint laws of $35 = 5\cdot 7$ and
$39 = 3 \cdot 13$ coincide, so no function of the joint law can output a
factor; (5) joint-law collisions are transported by any Jacobi-preserving
isomorphism of unit groups.

Three bold, testable conjectures follow.

### C1 (Collision density). Almost every semiprime has a joint-law twin.

**Statement.** The number of $N \le X$ that are products of two distinct odd
primes and admit a coprime semiprime $N' \le X^{1+o(1)}$ with
$\mathcal{L}(N) = \mathcal{L}(N')$ is $(1 - o(1))$ times the number of
semiprimes up to $X$.

**Key insight.** The joint law only remembers the pair (abelian group
$\mathbb{Z}_{p-1} \times \mathbb{Z}_{q-1}$, quadratic character), and the
number of such isomorphism classes with $\varphi(N) \le Y$ grows far more
slowly than the number of semiprimes — a pigeonhole in a quotient category, not
in the integers.

**Why now.** Theorem 7.6 makes the transport mechanism a theorem, so the
conjecture reduces to counting isomorphism classes of pairs (group, character),
a tractable multiplicative-number-theory problem of Erdős–Pomerance type
(counting fibres of $\varphi$). Numerical observation 7.8 already shows the
deficiency of distinct laws setting in at $N < 400$.

### C2 (Universality of the dial). Every "order ⊗ character" statistic collapses to a valuation.

**Statement.** Let $\chi$ be any real (more generally, order-$\ell$) Dirichlet
character mod $N = pq$ and consider the statistic
$u \mapsto (\operatorname{ord}(u), \chi(u))$. Then the analogue of the
dichotomy holds with $v_2$ replaced by $v_\ell$: the divisibility test
$\operatorname{ord}(u) \mid \operatorname{lcm}\!\big(\tfrac{p-1}{\ell}, \tfrac{q-1}{\ell}\big)$
is equivalent to "$\chi$ trivial at both components" **iff**
$v_\ell\!\big(\tfrac{p-1}{\ell}\big) = v_\ell\!\big(\tfrac{q-1}{\ell}\big)$.

**Key insight.** The proof of the dichotomy used nothing about quadraticity
beyond the lattice identity
$\gcd(2x, \operatorname{lcm}(x,y)) = x \iff v_2(y) \le v_2(x)$; the same
identity holds prime-by-prime for any $\ell$.

**Why now.** The arithmetic core is already isolated as Lemma 5.1; generalising
it to $\ell$ is a self-contained factorisation-lattice exercise.

### C3 (Hardness of the inverse problem). Reconstructing $N$ from its joint law is as hard as factoring.

**Statement.** There is a polynomial-time reduction from factoring semiprimes
to the problem: given the multiset $\mathcal{L}(N)$ (as an explicit list) and
$N$, output a nontrivial factor of $N$. Conversely, given the factorisation the
law is computable in polynomial time.

**Key insight.** The law's $+1$-fibre determines the multiset of lcm values of
pairs of divisors of $(p-1)/2$ and $(q-1)/2$, a "divisor-lattice tomography"
problem whose difficulty can be pinned to the hardness of recovering $p-1$ from
$\varphi(N)$-type data.

### Further targets

- **The exact-$3/4$ phenomenon.** Numerical observation 6.7 asserts that for
  $p \equiv q \equiv 3 \pmod 4$ the conditional bias ratio is exactly $3/4$ in
  every tested case. Proving (or refuting) this would upgrade the
  qualitative Corollary 6.6 to an exact identity, and would itself be a further
  demonstration that the bias is a coset artefact rather than a leak.
- **The remaining grid cell.** The combination grid pairing order with residue
  data and order with spectral data is now walked. The remaining cell —
  residue paired with spectral data — is predicted to collapse in the same way,
  for the same three reasons (residue dial, circularity, coarse invariant); a
  proof of a corresponding collision theorem there would close the grid.

---

## 11. Conclusion

The order × Jacobi joint law of a semiprime is a genuinely beautiful object.
The coupling that generates it is exact at every odd prime — quadratic residues
are precisely the elements of order dividing $(p-1)/2$ — and its lift to a
semiprime fails or succeeds according to a single, crisply identified 2-adic
comparison. On the Blum rung $p \equiv q \equiv 3 \pmod 4$ the lift is exact,
the residue quadrants are exactly equal quarters, and the Jacobi symbol is
provably blind to which order class a unit occupies.

It is also, as a route to factorisation, definitively closed. The conditional
bias is real but structural. The law is invariant under Jacobi-preserving
isomorphism of unit groups, hence a function of an object far coarser than the
factorisation, and two explicit coprime moduli — $35$ and $39$ — already share
it. From that single collision follows an unconditional impossibility: no
function whatsoever of the order × Jacobi joint law can return a nontrivial
divisor of its modulus. Together with the circularity of computing orders modulo
a composite, this closes the order × residue quadrant of the classical
hint-free attack surface, and leaves behind a small, sharp piece of theory that
stands on its own.
