# Counterfactual Number Theory: Which Arithmetic Laws Survive a Deformation of the Primes?

## Abstract

We investigate a counterfactual arithmetic in which the notion of *which numbers are prime* is deformed while the ambient multiplicative structure of the natural numbers is left untouched. Concretely, we replace the ordinary primes by the irreducible elements of the **Hilbert monoid** $H = \{\,n \in \mathbb{N} : n \equiv 1 \pmod 4\,\}$, a classical multiplicatively closed subset of the naturals whose "primes" are those members admitting no nontrivial factorization *within* $H$. Using this toy model we establish a sharp dividing line between arithmetic laws that are robust under such a deformation and those that are fragile. We prove three results: (1) $H$ is a submonoid of $(\mathbb{N}, \cdot)$, so the multiplicative skeleton survives; (2) there are infinitely many $H$-irreducibles, obtained from the rational primes $p \equiv 1 \pmod 4$ via Dirichlet's theorem, so infinitude of primes survives; and (3) unique factorization collapses, witnessed by the explicit minimal identity $441 = 9 \cdot 49 = 21 \cdot 21$ with $9, 21, 49$ all $H$-irreducible and the multisets $\{9,49\} \neq \{21,21\}$. We argue that the collapse is a structural consequence of admitting a proper subgroup of residues rather than an artifact of small numbers, and we outline conjectures extending the closure/collapse dichotomy to general congruence monoids and to randomized prime systems.

**Keywords:** Hilbert monoid, congruence monoid, irreducible elements, unique factorization, Dirichlet's theorem, arithmetic progressions, non-unique factorization, half-factorial monoids.

---

## 1. Introduction

The primes and the Fundamental Theorem of Arithmetic are so intertwined in elementary number theory that it is easy to conflate them. Yet many classical theorems about the primes — Euclid's infinitude, Dirichlet's theorem on arithmetic progressions, the Prime Number Theorem — are *distributional* statements that concern how primes are spread through the integers, while the Fundamental Theorem of Arithmetic is a *structural* statement about how integers decompose. This paper asks a deliberately naive question in order to separate these two flavors:

> If we keep the natural numbers and their multiplication, but change which numbers count as prime, which classical theorems survive and which collapse?

We make the question precise by choosing a specific deformation. Instead of the full set of naturals with the ordinary primes, we work inside the **Hilbert monoid**
$$H = \{\,n \in \mathbb{N} : n \equiv 1 \pmod 4\,\} = \{1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, \dots\},$$
a set introduced by Hilbert precisely to demonstrate that unique factorization can fail. The "primes" of this world are its irreducible elements — numbers in $H$ that cannot be written as a product of two smaller elements *of $H$*. Because a factor is only legal if it itself lies in $H$, numbers like $9 = 3\cdot 3$ become irreducible: their only rational factor $3$ is exiled from $H$.

This is a faithful, fully computable model of a counterfactual number theory. The ambient arithmetic is unchanged; only the notion of primality is deformed, by remembering just the residue class modulo $4$. Our main contribution is to isolate a clean dichotomy inside this model:

- **Coarse laws survive.** Multiplicative closure (Theorem 3.1) and infinitude of primes (Theorem 5.2) carry over intact. Neither depends on the fine identity of the primes.
- **Fine laws collapse.** Unique factorization fails (Theorem 6.1), already at the minimal witness $441$.

We further explain *why* the collapse is forced: it is governed by a single group-theoretic invariant, the index of the admitted residues inside the unit group $(\mathbb{Z}/4\mathbb{Z})^{\times}$.

### 1.1 Related notions

The Hilbert monoid is the simplest nontrivial *congruence monoid*: for a modulus $m$ and a submonoid $G$ of $(\mathbb{Z}/m\mathbb{Z})^{\times}$ (here $m = 4$, $G = \{1\}$), one forms $M(G) = \{n : n \bmod m \in G\}$. Congruence monoids are a well-studied source of non-unique factorization phenomena and of *half-factorial* and *elasticity* invariants. Our aim is not to survey that theory but to use its smallest instance as a laboratory that cleanly separates robust from fragile arithmetic laws, and to record explicit, minimal, verifiable witnesses.

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and all factorizations are of positive integers.

**Definition 2.1 (Hilbert monoid).** The *Hilbert monoid* is the predicate
$$\mathrm{inH}(n) \iff n \bmod 4 = 1,$$
and $H = \{n \in \mathbb{N} : \mathrm{inH}(n)\}$ is the set of natural numbers congruent to $1$ modulo $4$.

**Definition 2.2 ($H$-irreducible).** A natural number $n$ is *$H$-irreducible* (a *counterfactual prime*) if
$$n \geq 2, \qquad \mathrm{inH}(n), \qquad \text{and} \qquad \forall a, b \in \mathbb{N}\ \big(\mathrm{inH}(a) \wedge \mathrm{inH}(b) \wedge ab = n \implies a = 1 \vee b = 1\big).$$

The essential feature of Definition 2.2 is that the quantifier ranges over factorizations *inside* $H$. Quantifying over all of $\mathbb{N}$ would make almost every composite reducible and render the model vacuous; restricting to $H$ is what deforms primality in a nontrivial way.

**Remark 2.3.** Since $1 \bmod 4 = 1$, we have $\mathrm{inH}(1)$: the unit lies in the monoid. The element $1$ is treated as a unit and is excluded from irreducibility by the condition $n \geq 2$.

---

## 3. The multiplicative skeleton survives

**Theorem 3.1 (Closure).** *The Hilbert monoid is a submonoid of $(\mathbb{N}, \cdot)$: it contains $1$, and it is closed under multiplication. That is, $\mathrm{inH}(1)$, and if $\mathrm{inH}(a)$ and $\mathrm{inH}(b)$ then $\mathrm{inH}(ab)$.*

*Proof.* First, $1 \bmod 4 = 1$, so $\mathrm{inH}(1)$. For closure, suppose $a \equiv 1$ and $b \equiv 1 \pmod 4$. Modular multiplication gives
$$ab \bmod 4 = \big((a \bmod 4)(b \bmod 4)\big) \bmod 4 = (1 \cdot 1) \bmod 4 = 1,$$
so $\mathrm{inH}(ab)$. $\qquad\blacksquare$

This is the bedrock: multiplication never escapes $H$, so it is meaningful to speak of factorization *within* the counterfactual world at all. The multiplicative structure is completely robust under the deformation.

---

## 4. Counterfactual primes: explicit irreducibles

We record the three small irreducibles that drive the failure of unique factorization, and then the general mechanism producing infinitely many.

**Lemma 4.1.** *Each of $9$, $21$, and $49$ is $H$-irreducible.*

*Proof.* Each of $9 = 4\cdot 2 + 1$, $21 = 4 \cdot 5 + 1$, $49 = 4\cdot 12 + 1$ lies in $H$ and is $\geq 2$. It remains to rule out nontrivial factorizations inside $H$. Suppose $ab = n$ with $\mathrm{inH}(a), \mathrm{inH}(b)$ and $n \in \{9, 21, 49\}$. Any such $a$ divides $n$ and satisfies $a \leq n$, so it ranges over a finite list of divisors. Checking these divisors:
- For $9$: the divisors are $1, 3, 9$. Of these only $1$ and $9$ lie in $H$ ($3 \equiv 3 \pmod 4$). Hence $a = 1$ or $a = 9$ (forcing $b = 1$).
- For $21$: the divisors are $1, 3, 7, 21$. Only $1$ and $21$ lie in $H$ ($3, 7 \equiv 3 \pmod 4$). Hence $a = 1$ or $b = 1$.
- For $49$: the divisors are $1, 7, 49$. Only $1$ and $49$ lie in $H$. Hence $a = 1$ or $b = 1$.

In every case one factor is $1$, so $n$ is $H$-irreducible. $\qquad\blacksquare$

The phenomenon is transparent: the ordinary prime factors $3$ and $7$ both lie in the residue class $3 \pmod 4$, which is *outside* $H$. With those factors forbidden, the numbers $9$, $21$, $49$ have no legal nontrivial decomposition and are promoted to primes of the counterfactual world.

**Lemma 4.2 (Rational primes $\equiv 1$ import as counterfactual primes).** *If $p$ is a rational prime with $p \equiv 1 \pmod 4$, then $p$ is $H$-irreducible.*

*Proof.* Since $p \equiv 1 \pmod 4$ we have $\mathrm{inH}(p)$, and $p \geq 2$. Suppose $ab = p$ with $\mathrm{inH}(a), \mathrm{inH}(b)$. Then $a \mid p$, and since $p$ is prime, $a = 1$ or $a = p$. If $a = p$ then $b = 1$. Either way one factor is $1$. $\qquad\blacksquare$

The point of Lemma 4.2 is that an ordinary prime has *no* nontrivial factorization even in $\mathbb{N}$, hence a fortiori none inside the smaller world $H$; and the congruence condition places it in $H$.

---

## 5. Infinitude of primes survives

**Theorem 5.1 (Dirichlet, progression $1 \bmod 4$).** *There are infinitely many rational primes $p$ with $p \equiv 1 \pmod 4$.*

This is the special case of Dirichlet's theorem on primes in arithmetic progressions for modulus $4$ and residue $1$; it can also be proved directly by a Euclid-style argument using the fact that odd prime divisors of $N^2 + 1$ are $\equiv 1 \pmod 4$.

**Theorem 5.2 (Infinitude of counterfactual primes).** *The set $\{n \in \mathbb{N} : n \text{ is } H\text{-irreducible}\}$ is infinite.*

*Proof.* By Theorem 5.1 there are infinitely many rational primes $p \equiv 1 \pmod 4$. By Lemma 4.2 each of them is $H$-irreducible. An injective image of an infinite set is infinite, so the set of $H$-irreducibles contains an infinite subset and is itself infinite. $\qquad\blacksquare$

Thus Euclid's infinitude of primes is robust: it survives the deformation because it is fed directly by Dirichlet's distributional theorem, which knows nothing about the fine structure of factorization. Infinitude of primes is a *coarse* law.

---

## 6. Unique factorization collapses

**Theorem 6.1 (Failure of unique factorization).** *In the counterfactual world $H$, unique factorization into $H$-irreducibles fails. Explicitly, $9$, $21$, and $49$ are $H$-irreducible, and*
$$441 = 9 \cdot 49 = 21 \cdot 21,$$
*with the two factorizations genuinely distinct: the multiset $\{9, 49\}$ is not equal to the multiset $\{21, 21\}$.*

*Proof.* Irreducibility of $9, 21, 49$ is Lemma 4.1. The arithmetic identities $9 \cdot 49 = 441$ and $21 \cdot 21 = 441$ are immediate, and $441 = 4\cdot 110 + 1 \in H$. Finally, the two factorizations are certified distinct by comparing multisets: $\{9, 49\} \neq \{21, 21\}$, since $21 \notin \{9, 49\}$. This is not a reordering of a single factorization but two structurally different products of counterfactual primes. $\qquad\blacksquare$

**Remark 6.2 (Minimality).** The witness $441 = 21^2$ is the smallest number in $H$ with two distinct factorizations into $H$-irreducibles. Any such witness must be built from the exiled residue-$3$ primes bundled in pairs, and $3$ and $7$ are the two smallest such primes; the smallest number using them with two pairings is $(3 \cdot 3)(7 \cdot 7) = (3\cdot 7)(3\cdot 7) = 441$.

**Remark 6.3 (Why the collapse is structural).** Write $U = (\mathbb{Z}/4\mathbb{Z})^{\times} = \{1, 3\}$ for the unit group modulo $4$. The Hilbert monoid admits only the residue subgroup $G = \{1\}$, of index $2$ in $U$. The exiled residue $3$ is a coset representative that cannot appear alone in $H$ but reappears in pairs: $3 \cdot 3 \equiv 1$ and $3 \cdot 7 \equiv 1 \pmod 4$. Because a product of *two* exiled factors returns to $H$, exiled primes can be re-bundled into $H$-irreducibles in more than one way, and uniqueness fails. Had $G$ been all of $U$ (index $1$), no residue would be exiled and factorization would remain unique. This identifies the index $[U : G]$ as the true controlling invariant, and shows the failure is not an accident of small numbers.

---

## 7. Discussion: coarse versus fine arithmetic laws

The three theorems above draw a sharp line:

| Classical law | Status in $H$ | Character |
|---|---|---|
| Multiplicative closure / monoid structure | **Survives** (Thm 3.1) | Coarse |
| Infinitude of primes (Euclid/Dirichlet) | **Survives** (Thm 5.2) | Coarse |
| Unique factorization (FTA) | **Collapses** (Thm 6.1) | Fine |

The interpretation is that *which numbers are prime* is a fragile datum. Statements that depend only on multiplicative closure and on the abundance of primes are portable across a whole family of deformed arithmetics. Unique factorization, by contrast, depends essentially on the precise identity of the primes and is the first casualty of disturbing them.

This perspective reframes the Fundamental Theorem of Arithmetic not as an inevitability but as a special gift of the full integers — one that is easily lost. It also suggests a program: quantify *how badly* uniqueness fails as a function of the deformation. The natural measure is **elasticity**, the supremum over reducible elements of the ratio of the longest to the shortest factorization length. In $H$ the collision $441 = 9\cdot 49 = 21 \cdot 21$ has both factorizations of length $2$ (so it does not by itself force elasticity above $1$), but longer forbidden "detours" at larger moduli are expected to stretch factorization lengths and drive elasticity upward with the index $[U : G]$.

---

## 8. Algorithms

We summarize the constructive content in algorithmic form (full implementations appear in the accompanying demonstration code).

**Algorithm A (Membership and closure test).** Given $n$, return whether $n \equiv 1 \pmod 4$; given $a, b \in H$, verify $ab \in H$. Complexity $O(1)$ per test (after the divisions).

**Algorithm B ($H$-irreducibility test).** Given $n \in H$ with $n \geq 2$, enumerate divisors $a \mid n$ with $2 \leq a < n$; return "irreducible" iff no such $a$ has both $a \in H$ and $n/a \in H$. Complexity $O(\sqrt{n})$ divisor scan.

**Algorithm C (Search for non-unique factorizations).** For each $n \in H$ up to a bound $N$, compute all factorizations of $n$ into $H$-irreducibles by recursive descent, collect them as multisets, and report any $n$ with two or more distinct multisets. This rediscovers $441$ as the least witness. Complexity is output-sensitive; pruning by the irreducibility test keeps it practical for moderate $N$.

---

## 9. Applications and connections

1. **Teaching the role of the Fundamental Theorem.** The Hilbert monoid gives a minimal, fully explicit demonstration that infinitude of primes and unique factorization are logically independent — a valuable pedagogical separation.
2. **Non-unique factorization theory.** The example is the base case of the theory of congruence monoids, where invariants such as elasticity, the set of lengths, and half-factoriality quantify the failure of uniqueness. The index-based mechanism of Remark 6.3 is the seed of a general classification.
3. **Generalized (Beurling) prime systems.** Treating the $H$-irreducibles as a system of "generalized primes" connects to analytic questions about Dirichlet series $\sum_{n \in H} n^{-s}$ and whether an Euler product over the irreducibles exists — an analytic fingerprint of unique factorization whose breakdown detects the collapse.

---

## 10. Future work

We highlight four directions, elaborated in the accompanying future-directions notes.

- **A closure/collapse dichotomy for congruence monoids.** For every modulus $m$ and subgroup $G \leq (\mathbb{Z}/m\mathbb{Z})^{\times}$, the monoid $M(G) = \{n : n \bmod m \in G\}$ should be multiplicatively closed with infinitely many irreducibles, yet fail unique factorization exactly when $G$ is a proper subgroup — with the index $[(\mathbb{Z}/m\mathbb{Z})^{\times} : G]$ as the controlling invariant.
- **Elasticity grows with the index.** The elasticity of $M(G)$ should be finite and increase monotonically with the index, diverging along suitable sequences of moduli.
- **A zeta-function criterion.** The Dirichlet series restricted to $M(G)$ should admit an Euler product of classical geometric shape precisely when unique factorization holds, making the collapse a spectral signature.
- **Randomized primes.** For a random set $S \subseteq \mathbb{N}$ including each $n$ independently with probability $\sim 1/\log n$, Dirichlet-type distributional statements are expected to survive almost surely while unique factorization has no reason to hold — the random analogue of the coarse/fine dichotomy.

---

## 11. Conclusion

By deforming primality to the irreducibles of the Hilbert monoid $H = \{n \equiv 1 \pmod 4\}$, we exhibited a clean separation of arithmetic laws: the multiplicative skeleton and the infinitude of primes survive intact, while unique factorization collapses at the explicit minimal witness $441 = 9 \cdot 49 = 21 \cdot 21$. The collapse is controlled by a single group-theoretic invariant, the index of the admitted residues in the unit group. Counterfactual number theory, in this reading, is a tool for measuring which of arithmetic's laws are load-bearing and which are luxuries of the integers we happen to inhabit.
