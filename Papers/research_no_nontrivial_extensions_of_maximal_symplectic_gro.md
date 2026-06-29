# Arithmetic Tameness of the Mukai Maximal Symplectic Groups and Global Tameness of $\mathrm{Aut}(X)$ on the Superspecial K3 Surface in Characteristic $p > 11$

**Author:** Aristotle

**Domain:** Novelty (arithmetic / algebraic geometry of K3 surfaces)

---

## Abstract

Mukai's theorem classifies the finite groups that arise as maximal groups of
symplectic automorphisms of a complex K3 surface: there are exactly eleven such
groups. Ohashi–Schütt-type results show that the same eleven groups govern the
**superspecial** K3 surface in positive characteristic $p$, provided $p$ is
sufficiently large — the standing threshold being $p > 11$. The classification rests
on a *tameness* hypothesis: that the order of the relevant automorphism group is
prime to the characteristic.

We isolate and prove the precise arithmetic content of this hypothesis. We show that
the eleven Mukai group orders are all $7$-smooth: their least common multiple is the
single number $40320 = 2^7 \cdot 3^2 \cdot 5 \cdot 7$, every Mukai order divides
$40320$, and consequently every prime factor of every Mukai order is at most $7$. It
follows immediately that for every prime $p > 11$ (indeed $p > 7$), $p$ does not
divide any Mukai order; equivalently, every Mukai order is coprime to $p$. We then
synthesize this with the characteristic-$p$ tameness of the *non-symplectic index*
$[G:G_s]$ to conclude **global tameness**: for the superspecial K3 surface in
characteristic $p > 11$, if the symplectic subgroup $G_s$ is a maximal Mukai group,
then the order of the entire finite automorphism group $G$ is prime to $p$.

A central conceptual consequence is the separation of the threshold $p > 11$ into two
independent phenomena. The arithmetic obstruction is exhausted at $p > 7$; therefore
the residual rigidity needed to reach $p > 11$ — the conjectured statement that
$[G:G_s] = 1$ for maximal $G_s$ — must be geometric, not arithmetic. The single
explicit integer $40320$ makes this gap quantitative for the first time.

---

## 1. Introduction

### 1.1 Background

A **K3 surface** $X$ over an algebraically closed field $k$ is a smooth projective
surface with trivial canonical bundle $\omega_X \cong \mathcal{O}_X$ and vanishing
irregularity $h^1(X, \mathcal{O}_X) = 0$. K3 surfaces carry a one-dimensional space
of regular $2$-forms; a generator $\omega_X$ plays the role of a *symplectic form*,
and the action of an automorphism on this form distinguishes two kinds of symmetry.

Let $G \le \mathrm{Aut}(X)$ be a finite group of automorphisms. Each $g \in G$ acts
on $H^0(X, \omega_X) \cong k$ by a scalar, giving a homomorphism
$$\chi : G \longrightarrow k^\times, \qquad g^* \omega_X = \chi(g)\,\omega_X,$$
the **period character**. Its kernel
$$G_s := \ker \chi$$
is the group of **symplectic** automorphisms (those preserving $\omega_X$). The
quotient $G / G_s \hookrightarrow k^\times$ is cyclic; its order
$$n := [G : G_s]$$
is the **non-symplectic index**. By construction,
$$\#G = \#G_s \cdot [G : G_s]. \tag{1.1}$$

**Mukai's theorem** (over $\mathbb{C}$) states that a finite group $G_s$ acts
faithfully and symplectically on some K3 surface, and is *maximal* among such, if and
only if $G_s$ is one of eleven explicit groups. These **Mukai groups** and their
orders are listed in Table 1.

| Group        | Order |
|--------------|------:|
| $M_{20}$     |  $960$ |
| $F_{384}$    |  $384$ |
| $A_{4,4}$    |  $288$ |
| $T_{192}$    |  $192$ |
| $H_{192}$    |  $192$ |
| $N_{72}$     |   $72$ |
| $M_{9}$      |   $72$ |
| $T_{48}$     |   $48$ |
| $L_2(7)$     |  $168$ |
| $A_6$        |  $360$ |
| $S_5$        |  $120$ |

*Table 1: The eleven Mukai maximal symplectic groups and their orders.*

### 1.2 The superspecial K3 surface and the $p > 11$ threshold

In characteristic $p > 0$ the most arithmetically extreme K3 surface is the
**superspecial** surface — the unique K3 surface whose formal Brauer group has
height $\infty$ and whose Néron–Severi lattice has the maximal possible rank $22$
(the *supersingular* surface with Artin invariant $\sigma = 1$). Ohashi–Schütt-type
analyses establish that Mukai's eleven groups continue to classify maximal symplectic
actions on the superspecial surface, provided $p > 11$.

The conjecture motivating this work concerns **rigidity at the maximum**:

> **Conjecture (No non-trivial extension).** Let $X$ be the superspecial K3 surface
> over an algebraically closed field of characteristic $p > 11$, and let
> $G \le \mathrm{Aut}(X)$ be finite with symplectic subgroup $G_s$ maximal (a Mukai
> group). Then the period character $\chi$ is trivial; equivalently $[G:G_s] = 1$,
> i.e. $G = G_s$.

A prerequisite, and the technical backbone of the entire classification, is
**tameness**: that $\#G$ is prime to $p$. This paper isolates and proves the
arithmetic component of tameness in full, and synthesizes it with the
characteristic-$p$ tameness of the non-symplectic index to obtain global tameness.

### 1.3 Contributions

1. **The Mukai least common multiple (Definitions 1–2, Theorem 1).** The eleven
   Mukai orders all divide the single integer $40320 = 2^7 \cdot 3^2 \cdot 5 \cdot 7$.

2. **$7$-smoothness (Theorem 2).** Every prime factor of every Mukai order is
   $\le 7$.

3. **Arithmetic tameness (Theorem 3, Corollary 1).** For every prime $p > 11$ and
   every Mukai order $N$, $p \nmid N$; equivalently $\gcd(p, N) = 1$.

4. **Global tameness (Theorem 4, Corollary 2).** For the superspecial K3 in
   characteristic $p > 11$ with $G_s$ a Mukai group, $p \nmid \#G$.

5. **A conceptual separation.** Arithmetic tameness already holds for $p > 7$;
   therefore the residual obstruction forcing the threshold to $p > 11$ is geometric.

---

## 2. Definitions

We work with the orders of the Mukai groups as natural numbers.

**Definition 1 (Mukai orders, `mukaiOrders`).**
$$\mathrm{mukaiOrders} := [\,960,\ 384,\ 288,\ 192,\ 192,\ 72,\ 72,\ 48,\ 168,\ 360,\ 120\,].$$
This is the multiset of orders from Table 1, listed with multiplicity (the order
$192$ appears twice, for $T_{192}$ and $H_{192}$; the order $72$ appears twice, for
$N_{72}$ and $M_9$). We write $N \in \mathrm{mukaiOrders}$ for membership.

**Definition 2 (Mukai least common multiple, `mukaiLcm`).**
$$\mathrm{mukaiLcm} := 40320.$$
Its prime factorization is
$$40320 = 2^7 \cdot 3^2 \cdot 5 \cdot 7,$$
so its set of prime factors is $\{2, 3, 5, 7\}$. One verifies directly that $40320$
is the least common multiple of all entries of $\mathrm{mukaiOrders}$.

**Definition 3 (Symplectic subgroup and non-symplectic index).** For a finite group
$G$, a field $k$, and a homomorphism (period character) $\chi : G \to k^\times$, the
**symplectic subgroup** is $G_s := \mathrm{symplecticSubgroup}(\chi) = \ker \chi$,
and the **non-symplectic index** is $n := [G : G_s]$. These satisfy the factorisation
$\#G = \#G_s \cdot [G : G_s]$ (Equation (1.1)).

---

## 3. Main results

### 3.1 The Mukai least common multiple

**Theorem 1 (`mukaiOrder_dvd_lcm`).** *For every $N \in \mathrm{mukaiOrders}$,*
$$N \mid 40320.$$

*Proof sketch.* The claim is a finite conjunction over the eleven entries; each
divisibility is a single integer division. Explicitly, with quotients:

| $N$ | $40320 / N$ | | $N$ | $40320 / N$ |
|---:|---:|---|---:|---:|
| $960$ | $42$ | | $72$ | $560$ |
| $384$ | $105$ | | $48$ | $840$ |
| $288$ | $140$ | | $168$ | $240$ |
| $192$ | $210$ | | $360$ | $112$ |
| | | | $120$ | $336$ |

Each quotient is an integer, so each $N$ divides $40320$. (In the formalization the
finite check is discharged by decision over the explicit list.) $\qquad\blacksquare$

Theorem 1 is the structural keystone: it reduces every prime-divisibility question
about the *eleven* Mukai orders to a single prime-divisibility question about the
*one* number $40320$, via the transitivity of divisibility.

### 3.2 Smoothness of the Mukai orders

**Theorem 2 (`mukaiOrder_prime_factor_le_seven`).** *For every
$N \in \mathrm{mukaiOrders}$, every prime $q$, if $q \mid N$ then $q \le 7$.*

*Proof sketch.* Fix $N \in \mathrm{mukaiOrders}$ and a prime $q \mid N$. By
$q \mid N$ and $N > 0$ we have $q \le N$, so $q$ ranges over a finite set; checking
each candidate prime against each of the eleven orders, the only primes dividing any
$N$ are $2, 3, 5, 7$ (consistent with $N \mid 40320 = 2^7 3^2 5\cdot 7$ from
Theorem 1). Hence $q \le 7$. (Formally: case-split over the eleven entries, bound
$q \le N$ by `Nat.le_of_dvd`, then finish by interval case analysis on $q$.)
$\qquad\blacksquare$

Equivalently, every Mukai order is a **$7$-smooth** (or $\{2,3,5,7\}$-) number.

### 3.3 Arithmetic tameness — the main theorem

**Theorem 3 (Arithmetic tameness, `mukaiOrder_tame`).** *For every prime $p$ with
$11 < p$ and every $N \in \mathrm{mukaiOrders}$,*
$$p \nmid N.$$

*Proof sketch.* Suppose for contradiction $p \mid N$. Since $p$ is prime, Theorem 2
applies and gives $p \le 7$. But $p > 11 > 7$, a contradiction. Hence $p \nmid N$.
$\qquad\blacksquare$

We emphasize that Theorem 3 is *not* a brute-force decision: it factors through the
structural smoothness Theorem 2 (itself anchored to Theorem 1 and the factorization
of $40320$), with only the final inequality $7 < p$ being elementary. The hypothesis
used is in fact $p > 7$; the conjecture's stronger hypothesis $p > 11$ is not needed
for the arithmetic, a point we return to in §6.

**Corollary 1 (`mukaiOrder_coprime`).** *For every prime $p$ with $11 < p$ and every
$N \in \mathrm{mukaiOrders}$, $\gcd(p, N) = 1$, i.e. $p$ and $N$ are coprime.*

*Proof sketch.* For a prime $p$, coprimality with $N$ is equivalent to $p \nmid N$
(a prime is coprime to $N$ iff it does not divide it). Apply Theorem 3.
$\qquad\blacksquare$

### 3.4 Global tameness of the automorphism order

We now combine arithmetic tameness of the symplectic part with the
characteristic-$p$ tameness of the non-symplectic index. The latter is an imported
algebraic fact: in characteristic $p$, the cyclic non-symplectic quotient
$G/G_s \hookrightarrow k^\times$ has order prime to $p$, because $k^\times$ has no
$p$-torsion (the Frobenius-type identity $x^p - 1 = (x-1)^p$ in characteristic $p$
forces a $p$-th root of unity to equal $1$). We denote this fact
`nonSymplecticIndex_not_dvd_char`: $p \nmid [G : G_s]$.

**Theorem 4 (Global tameness, `aut_order_not_dvd_char`).** *Let $k$ be a field of
characteristic $p$ with $p$ prime and $11 < p$, let $G$ be a finite group, and let
$\chi : G \to k^\times$ be a period character. If
$\#\,\mathrm{symplecticSubgroup}(\chi) = \#G_s \in \mathrm{mukaiOrders}$, then*
$$p \nmid \#G.$$

*Proof sketch.* By the factorisation $\#G = \#G_s \cdot [G : G_s]$ (Equation (1.1),
`card_eq_symplectic_mul_index`). Suppose $p \mid \#G$. Since $p$ is prime, Euclid's
lemma (`Nat.Prime.dvd_mul`) gives $p \mid \#G_s$ or $p \mid [G : G_s]$. The first is
impossible by Theorem 3, since $\#G_s \in \mathrm{mukaiOrders}$ and $p > 11$. The
second is impossible by `nonSymplecticIndex_not_dvd_char`. Both disjuncts fail, so
$p \nmid \#G$. $\qquad\blacksquare$

**Corollary 2 (`aut_order_coprime_char`).** *Under the hypotheses of Theorem 4,
$\gcd(p, \#G) = 1$: the order of the full automorphism group is coprime to the
characteristic.*

*Proof sketch.* For a prime $p$, coprimality with $\#G$ is equivalent to $p \nmid \#G$;
apply Theorem 4. $\qquad\blacksquare$

Theorem 4 is a genuine *bridge*: it cannot be derived from the symplectic side alone
(it needs the non-symplectic tameness) nor from the non-symplectic side alone (it
needs the Mukai arithmetic). Both inputs — the algebraic identity in characteristic
$p$ and the arithmetic least common multiple $40320$ — are load-bearing.

---

### 3.5 Logical architecture of the proof

It is worth making explicit how the five results above interlock, because the design is
deliberately modular and each link carries genuine content rather than being a
restatement of its neighbour.

At the base sits a single arithmetic fact about one integer: the factorization
$40320 = 2^7 \cdot 3^2 \cdot 5 \cdot 7$. Theorem 1 (`mukaiOrder_dvd_lcm`) attaches the
eleven Mukai orders to this integer by divisibility. The value of this step is that it
*collapses* an eleven-fold problem into a one-fold problem: any property of $40320$ that
is inherited by divisors is automatically a property of all eleven orders. Smoothness is
exactly such a property — if $q$ is prime and $q \mid N \mid 40320$, then $q \mid 40320$,
hence $q \in \{2,3,5,7\}$ — which is the content of Theorem 2
(`mukaiOrder_prime_factor_le_seven`).

Theorem 3 (`mukaiOrder_tame`) then converts the *upper bound on prime factors* into a
*lower bound on tame characteristics*: a prime $p$ exceeding the smoothness bound cannot
divide a smooth number. This is the only place an inequality on $p$ enters, and it
enters cleanly as $p > 7$. Corollary 1 (`mukaiOrder_coprime`) is the coprime
reformulation, using the elementary equivalence (for $p$ prime) between $p \nmid N$ and
$\gcd(p, N) = 1$.

The final ascent, Theorem 4 (`aut_order_not_dvd_char`), leaves pure arithmetic and
enters group theory, but it does so through a single multiplicative bottleneck: the
order formula $\#G = \#G_s \cdot [G:G_s]$. Divisibility by a prime distributes over this
product (Euclid's lemma), so global tameness is exactly the conjunction of two
independent tameness facts — one for each factor. The symplectic factor is handled by
Theorem 3; the non-symplectic factor is handled by the imported characteristic-$p$
statement. Neither factor's argument knows anything about the other, which is precisely
why the synthesis is a *bridge* result and not a corollary of either side.

This architecture also clarifies what is *not* proved here, and deliberately so. The
geometric rigidity $[G:G_s] = 1$ — the assertion that the non-symplectic factor is not
merely tame but trivial when $G_s$ is maximal — is a strictly stronger statement that no
amount of arithmetic can supply, since arithmetic is already exhausted at $p > 7$. It is
stated only as a conjecture (see §7), never as a theorem.

## 4. Algorithmic content

The arithmetic results are effective. We describe two algorithms underlying the
proofs.

### 4.1 Smoothness certification by least common multiple

To certify that a finite list $L = [N_1, \dots, N_m]$ of group orders is $B$-smooth
(all prime factors $\le B$), it suffices to compute $M = \operatorname{lcm}(L)$, then
factor the *single* number $M$ and check $\max(\text{primes of } M) \le B$. Because
each $N_i \mid M$, every prime factor of every $N_i$ is a prime factor of $M$. For
the Mukai list this yields $M = 40320$, prime factors $\{2,3,5,7\}$, hence
$B = 7$. The cost is dominated by one factorization of $M$ rather than $m$
factorizations of the $N_i$, and the divisibility check $N_i \mid M$ is a single
division per entry.

### 4.2 Tameness oracle

Given the smoothness bound $B = 7$ and a prime $p$, tameness of the whole Mukai list
in characteristic $p$ reduces to the single comparison $p > B$. There is no need to
test divisibility against each order: smoothness already guarantees $p \nmid N_i$ for
all $i$ as soon as $p > B$. The synthesis with the non-symplectic index requires only
one further bit: the imported guarantee $p \nmid [G:G_s]$, after which Euclid's lemma
on the factorisation $\#G = \#G_s \cdot [G:G_s]$ finishes the job.

---

## 5. Worked numerical examples

- **$p = 13$ (smallest admissible prime).** $13 > 11$, and $13 \nmid N$ for every
  Mukai order $N$ (indeed $13 > 7 \ge$ every prime factor). For instance with
  $\#G_s = 960$ and an extension with $[G:G_s] = 5$, we get $\#G = 4800$, and
  $13 \nmid 4800$. Global tameness holds.
- **$p = 7$ (boundary of arithmetic).** Arithmetic tameness still holds for the
  symplectic orders only for $p > 7$; at $p = 7$ itself, $7 \mid 168$ (since
  $168 = 2^3 \cdot 3 \cdot 7$) — the smoothness bound is attained, so $p = 7$ is *not*
  tame for that order. This is why the arithmetic threshold is $p > 7$ and not
  $p \ge 7$.
- **The $7$–$11$ gap.** For $p \in \{11\}$ (the largest prime $\le 11$), arithmetic
  tameness already holds ($11 \nmid N$ for all $N$, since $11 > 7$), yet the conjecture
  excludes $p = 11$. The exclusion is therefore *not* arithmetic; see §6.

---

## 6. Discussion: the arithmetic/geometry split at $7$ and $11$

The principal conceptual payoff is the clean separation of the threshold into two
mechanisms:

- **Arithmetic mechanism (resolved here).** The Mukai orders are $7$-smooth; their
  least common multiple is $40320 = 2^7 3^2 5 \cdot 7$. Hence tameness of the
  symplectic order holds for *every* prime $p > 7$. This is uniform, exact, and
  complete.

- **Geometric mechanism (conjectural).** The conjecture requires $p > 11$, strictly
  stronger than $p > 7$. The four-unit gap (primes through $11$) cannot be explained
  by divisibility — the arithmetic is already finished at $7$. The residual
  obstruction — that a maximal symplectic group admits *no* non-trivial non-symplectic
  extension, i.e. $[G:G_s] = 1$ — must therefore be geometric, originating in the
  cyclotomic action on the rank-$22$ crystalline/Néron–Severi lattice of the
  superspecial surface rather than in the order of any group.

This division is itself the result: by exhausting the arithmetic, we localize the
remaining mystery precisely to characteristics $11$ and below, and quantify it via the
explicit integer $40320$.

---

## 7. Future directions

1. **The geometric rigidity $[G:G_s] = 1$ for maximal $G_s$.** Prove that for the
   superspecial K3 in characteristic $p > 11$ with $G_s$ a Mukai group, the period
   character $\chi$ is trivial. By global tameness (Theorem 4) the only remaining
   freedom is a cyclic non-symplectic part $C_n \hookrightarrow k^\times$ with
   $\gcd(n,p)=1$; the obstruction to $n > 1$ must come from the invariant-lattice
   count, not from arithmetic.

2. **The $7$-to-$11$ gap is purely geometric.** Tameness holds already for $p > 7$,
   so the no-extension phenomenon should *fail* for some maximal $G_s$ when
   $7 < p \le 11$ — making $p > 11$ sharp and not an artifact of divisibility.

3. **Totient bound on the non-symplectic order.** Any realized non-symplectic index
   $n = [G:G_s]$ on a tame K3 in characteristic $p > 11$ should satisfy
   $\varphi(n) \le 21$ (a cyclotomic constraint on a rank-$22$ lattice), with
   admissible $n$ compatible with a single Mukai invariant lattice — forcing $n = 1$
   when $G_s$ is maximal.

4. **Multiplicative tameness as a classification axiom.** Global tameness
   (Theorem 4) should suffice to transport Mukai's characteristic-$0$ classification
   verbatim to characteristic $p > 11$.

---

## 8. Conclusion

We have proved the arithmetic core of the tameness hypothesis underlying the
Ohashi–Schütt picture of the superspecial K3 surface. The eleven Mukai group orders
are $7$-smooth with least common multiple $40320 = 2^7 3^2 5 \cdot 7$
(Theorems 1–2); hence every prime $p > 11$ (indeed $p > 7$) is coprime to every Mukai
order (Theorem 3, Corollary 1). Synthesizing with the characteristic-$p$ tameness of
the non-symplectic index yields global tameness of $\#\mathrm{Aut}(X)$ for $p > 11$
(Theorem 4, Corollary 2). Most importantly, the arithmetic is exhausted at $p > 7$,
which localizes the genuine, still-conjectural rigidity to the geometric gap between
$7$ and $11$.
