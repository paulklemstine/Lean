# Covering Systems, the Chinese Remainder Theorem, and a Certificate Framework for Sierpiński Numbers

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Computation (Number Theory)

## Abstract

A *Sierpiński number* is an odd positive integer $k$ such that $k\cdot 2^n + 1$ is
composite for every positive integer $n$. We develop a self-contained, machine-verified
theory of **covering systems** and of **Sierpiński certificates** — finite combinatorial
objects that reduce the infinite compositeness question to a finite, decidable check. Our
central result is a *soundness theorem*: any valid certificate proves that, for every
exponent $n$, the value $k\cdot 2^n + 1$ is divisible by a fixed small prime drawn from a
finite list. The proof rests on two elementary modular lemmas — the periodicity of powers
of two modulo a prime, and the transfer of divisibility across congruent exponents. We
exhibit the explicit certificate data for $k = 78557$: a covering system on the residues
modulo $36$ with moduli $\{2,4,3,12,18,36,9\}$ paired with the primes
$\{3,5,7,13,19,37,73\}$. We further formalize the structural theory surrounding covering
systems: least-common-multiple periodicity (which renders verification finite), the
Chinese-Remainder-Theorem compatibility of coprime congruence classes, a pigeonhole lower
bound on uniform coverings, and a parity composition principle. Finally, we record the
**minimality conjecture** — that $78557$ is the smallest Sierpiński number — as a formal
proposition, and the concrete testable prediction governing its smallest open candidate
$k = 21181$, both of which remain open. All results stated below are formalized with no
unproven gaps; the minimality statement is recorded as an explicit conjecture, not a
theorem.

## 1. Introduction

In 1960 Sierpiński proved that there are infinitely many odd $k$ for which $k\cdot 2^n+1$
is composite for all $n \ge 1$. The smallest known such number, $78557$, was found by
Selfridge in 1962, and whether it is the *smallest* Sierpiński number is a celebrated open
problem. The proof that $78557$ works is not a brute-force calculation but a structural
argument: a **covering system** of the exponents, paired with primes, guarantees a small
divisor for every term of the sequence simultaneously.

This paper formalizes the framework underlying such proofs. We separate, cleanly, three
concerns:

1. **The abstract machinery** — what a covering system and a certificate are, and why a
   valid certificate forces compositeness (Sections 2–3).
2. **The supporting structural theory** — periodicity, finite verifiability, CRT
   compatibility, and density bounds (Sections 4–5).
3. **The concrete instance** — the explicit covering data for $78557$ (Section 6).

The design philosophy is *certificate checking is cheap and decidable; certificate finding
is a separate combinatorial search.* This separation is what makes the soundness theorem so
useful: an untrusted search may propose a table, and the verified core certifies it.

## 2. Covering systems and congruence classes

**Definition 1 (Congruence class).** A *congruence class* is a tuple $(a, m)$ with
$m > 0$ and $0 \le a < m$. It represents the set $\{\, n \in \mathbb N : n \equiv a \pmod m \,\}$.
In Lean this is the structure `CongruenceClass` with fields `residue`, `modulus`,
`modulus_pos`, and `residue_lt`.

**Definition 2 (Covering system).** A *covering system* is a finite nonempty list
$\mathcal C = (c_1, \dots, c_t)$ of congruence classes such that every natural number lies
in at least one class:
$$\forall n \in \mathbb N,\ \exists\, c \in \mathcal C,\ n \bmod c.\mathrm{modulus} = c.\mathrm{residue}.$$
In Lean this is the structure `CoveringSystem` with fields `classes`, `nonempty`, and
`covers`.

Covering systems, introduced by Erdős, are finite certificates of an infinite covering
property. The art lies in covering $\mathbb Z$ with *distinct* moduli; the trivial class
$(0,1)$ covers everything but is uninteresting.

## 3. Sierpiński numbers and the certificate soundness theorem

**Definition 3 (Sierpiński number).** Write $\mathrm{IsComposite}(N) :\equiv (1 < N) \wedge
\neg\,\mathrm{Prime}(N)$. An integer $k$ is a *Sierpiński number* if
$$\mathrm{Odd}(k)\ \wedge\ 0 < k\ \wedge\ \forall n > 0,\ \mathrm{IsComposite}(k\cdot 2^n + 1).$$
In Lean: `IsComposite` and `IsSierpinskiNumber`.

**Definition 4 (Sierpiński certificate).** A *certificate* for $k$ (Lean:
`SierpinskiCertificate k`) consists of:

- a covering system `system` with class list of length $t$;
- a list `primes` of length $t$;
- a proof `primes_prime` that every listed prime is prime;
- a *divisibility* condition: for each index $i$, with class $c_i = (a_i, m_i)$ and prime
  $p_i$,
  $$p_i \mid k\cdot 2^{a_i} + 1;$$
- an *order* condition: for each index $i$,
  $$2^{m_i} \equiv 1 \pmod{p_i}.$$

The order condition says that the multiplicative order of $2$ modulo $p_i$ divides the
modulus $m_i$ — so $p_i$'s "clock" completes a whole number of revolutions over one period
of its patrol beat.

The soundness argument rests on two lemmas about modular arithmetic that never mention
Sierpiński numbers and are therefore reusable in isolation.

**Lemma 5 (Periodicity of powers of two; Lean `pow_mod_congr`).** Let $p \ge 2$ and
$m > 0$. If $2^m \equiv 1 \pmod p$ and $n \bmod m = a$, then
$$2^n \equiv 2^a \pmod p.$$
*Proof sketch.* Write $n = a + m q$ with $a = n \bmod m$. Then
$2^n = 2^a\cdot (2^m)^q \equiv 2^a\cdot 1^q = 2^a \pmod p$, using that congruences are
preserved under multiplication and that $2^m \equiv 1$ raised to any power stays $\equiv 1$.
$\square$

**Lemma 6 (Divisibility transfer; Lean `divisor_transfers`).** If $p \mid k\cdot 2^a + 1$
and $2^n \equiv 2^a \pmod p$, then $p \mid k\cdot 2^n + 1$.
*Proof sketch.* Pass to the ring $\mathbb Z/p\mathbb Z$. There $k\cdot 2^a + 1 = 0$ and
$2^n = 2^a$, hence $k\cdot 2^n + 1 = k\cdot 2^a + 1 = 0$, i.e. $p \mid k\cdot 2^n + 1$.
$\square$

**Theorem 7 (Certificate soundness; Lean `certificate_gives_divisor`).** Let $k$ be a
natural number and let `cert` be a valid `SierpinskiCertificate k`. Then for every
$n \in \mathbb N$ there is a prime $p$ in `cert.primes` with
$$p \mid k\cdot 2^n + 1.$$
*Proof sketch.* Given $n$, the covering property supplies a class $c_i = (a_i, m_i)$ in the
system with $n \bmod m_i = a_i$, and the corresponding prime $p_i$. By the order condition
$2^{m_i} \equiv 1 \pmod{p_i}$, so Lemma 5 gives $2^n \equiv 2^{a_i} \pmod{p_i}$. The
divisibility condition gives $p_i \mid k\cdot 2^{a_i} + 1$, and Lemma 6 transfers this to
$p_i \mid k\cdot 2^n + 1$. $\square$

**Remark (from soundness to compositeness).** Theorem 7 yields a *fixed small* prime
divisor of $k\cdot 2^n + 1$ for every $n$. Whenever that divisor is strictly smaller than
$k\cdot 2^n + 1$ (which holds for all sufficiently large $n$, since the covering primes are
bounded while $k\cdot 2^n + 1 \to \infty$), the term is composite. This is the precise sense
in which a covering certificate witnesses the Sierpiński property; the soundness theorem
isolates its arithmetic heart.

## 4. Finite verifiability via least-common-multiple periodicity

A covering system is an infinite assertion, but its truth is periodic.

**Definition 8 (LCM of moduli; Lean `CoveringSystem.lcm_moduli`).** For a covering system
$\mathcal C$, let
$$L(\mathcal C) = \operatorname{lcm}\{\, m : (a,m) \in \mathcal C \,\},$$
realized as a left fold of $\operatorname{lcm}$ over the class list starting from $1$.

**Lemma 9 (Period shift; Lean `covering_system_lcm_period`).** For every class
$c = (a,m) \in \mathcal C$ and every $n$,
$$n \bmod m = (n + L(\mathcal C)) \bmod m.$$
*Proof sketch.* Each modulus $m$ divides $L(\mathcal C)$ (an induction over the fold), so
$L(\mathcal C) \equiv 0 \pmod m$ and adding it leaves remainders unchanged. $\square$

**Theorem 10 (Finite verification; Lean `covering_finite_verification`).** A list of
congruence classes covers every natural number if and only if it covers every residue
$n \in \{0, 1, \dots, L(\mathcal C) - 1\}$:
$$\Big(\forall n \in \mathbb N,\ \exists c,\ n \bmod c.m = c.a\Big)
\iff
\Big(\forall n \in \mathrm{Fin}\,L(\mathcal C),\ \exists c,\ n \bmod c.m = c.a\Big).$$
*Proof sketch.* The forward direction restricts the universal statement. The backward
direction uses Lemma 9: any $n$ is congruent modulo every $m$ to its reduction modulo
$L(\mathcal C)$, so coverage of the reduced residue transfers to $n$. $\square$

This theorem is the formal justification for the napkin-sized verification: to certify the
$78557$ system it suffices to inspect the $L = 36$ residues $0, \dots, 35$.

## 5. Structural theory of covering systems

**Definition 11 (Compatibility; Lean `CongruenceClass.compatible`).** Two classes
$c_1, c_2$ are *compatible* if some natural number lies in both:
$\exists n,\ n \bmod c_1.m = c_1.a \wedge n \bmod c_2.m = c_2.a.$

**Theorem 12 (CRT compatibility; Lean `crt_compatible`).** If $\gcd(c_1.m, c_2.m) = 1$
then $c_1$ and $c_2$ are compatible.
*Proof sketch.* The Chinese Remainder Theorem produces $x$ with $x \equiv c_1.a
\pmod{c_1.m}$ and $x \equiv c_2.a \pmod{c_2.m}$; since each residue is already reduced
($a < m$), the congruences become the equalities required by compatibility. $\square$

This is the structural reason a designer may freely combine patrol beats of coprime
periods (e.g. $4$ and $9$): they are guaranteed to be jointly satisfiable.

**Lemma 13 (Positive moduli; Lean `covering_moduli_pos`).** Every class in a covering
system has positive modulus — immediate from the `CongruenceClass` invariant.

**Lemma 14 (Trivial singleton; Lean `singleton_covering_modulus_one`).** A single class
with residue $0$ that covers all of $\mathbb N$ must have modulus $1$.
*Proof sketch.* Coverage at $n=1$ forces $1 \bmod m = 0$, i.e. $m \mid 1$, so $m = 1$.
$\square$

**Theorem 15 (Uniform covering lower bound; Lean `uniform_covering_card`).** If every
class in a covering system has the *same* modulus $m > 0$, then the system has at least $m$
classes.
*Proof sketch.* Each residue $r \in \{0,\dots,m-1\}$ must be covered, and a class of
modulus $m$ covers exactly one residue, namely its own. Mapping each residue to the
residue of a covering class is injective into the multiset of class residues, so by
pigeonhole the number of classes is at least $m$. $\square$

This quantifies why economical covering systems must use *varied* moduli: uniform moduli
incur a linear tax. The $78557$ system sidesteps this entirely, using seven distinct
moduli.

**Lemma 16 (Parity composition; Lean `covering_by_parity`).** If one list of classes
covers every even number and another covers every odd number, their concatenation covers
every natural number.
*Proof sketch.* Case split on the parity of $n$ and select the witnessing class from the
appropriate sublist, embedding membership into the concatenation. $\square$

## 6. The explicit certificate data for 78557

The covering system for $78557$ (Lean `sierpinski78557_classes`) consists of seven
congruence classes, paired with the prime list (Lean `sierpinski78557_primes`)
$\{3,5,7,13,19,37,73\}$:

| residue $a$ | modulus $m$ | prime $p$ | check: $p \mid 78557\cdot 2^a+1$ | check: $2^m \equiv 1 \pmod p$ |
|---|---|---|---|---|
| $0$ | $2$ | $3$ | yes | $2^2 = 4 \equiv 1$ |
| $1$ | $4$ | $5$ | yes | $2^4 = 16 \equiv 1$ |
| $1$ | $3$ | $7$ | yes | $2^3 = 8 \equiv 1$ |
| $11$ | $12$ | $13$ | yes | $2^{12} \equiv 1$ |
| $15$ | $18$ | $19$ | yes | $2^{18} \equiv 1$ |
| $27$ | $36$ | $37$ | yes | $2^{36} \equiv 1$ |
| $3$ | $9$ | $73$ | yes | $2^9 = 512 \equiv 1$ |

The least common multiple of the moduli is $L = \operatorname{lcm}(2,4,3,12,18,36,9) = 36$.
By Theorem 10 it suffices to verify that the seven classes cover the residues
$0, 1, \dots, 35$; direct inspection confirms there are no gaps. Combining this with
Theorem 7 yields, for every $n$, a prime in $\{3,5,7,13,19,37,73\}$ dividing
$78557\cdot 2^n + 1$, and hence the compositeness of every term of the sequence (each term
exceeding the bounded covering primes). The data has been numerically verified over a wide
range of exponents.

A worked corner case illustrates the mechanism. For $n = 35$: it is odd ($3$ misses);
$35 \bmod 4 = 3 \ne 1$ ($5$ misses); $35 \bmod 3 = 2 \ne 1$ ($7$ misses);
$35 \bmod 12 = 11$ — a hit, so $13 \mid 78557\cdot 2^{35} + 1$.

## 7. The minimality conjecture and a testable prediction

**Open problem (Lean `SierpinskiMinimalityConjecture`).** $78557$ is the smallest
Sierpiński number:
$$\forall k,\ \mathrm{IsSierpinskiNumber}(k)\ \Rightarrow\ 78557 \le k.$$
This is recorded as a formal proposition, not a theorem; it is a long-standing open
problem. Eliminating a candidate $k$ amounts to exhibiting a single exponent $n$ with
$k\cdot 2^n + 1$ prime.

**Testable prediction (Lean `TestPrediction_21181`).** For the smallest open candidate,
$$\exists n,\ \mathrm{Prime}\,(21181\cdot 2^n + 1).$$
Distributed searches have tested exponents into the tens of millions without finding such
a prime; the statement remains unresolved. A handful of further candidates (historically
$22699, 24737, 55459, 67607$) occupy the same limbo.

## 8. Algorithms

Two algorithms accompany the framework.

**(A) Certificate verifier.** Given $k$, a list of $(a_i, m_i, p_i)$ triples, and a period
bound, the verifier checks (i) each $p_i$ is prime, (ii) $p_i \mid k\cdot 2^{a_i} + 1$,
(iii) $2^{m_i} \equiv 1 \pmod{p_i}$, and (iv) the classes cover every residue modulo
$L = \operatorname{lcm}_i m_i$. By Theorems 7 and 10 a passing verdict certifies that every
$k\cdot 2^n + 1$ has a fixed small prime divisor. Complexity is $O(L \cdot t)$ residue
checks plus $t$ modular exponentiations, all polynomial in the bit sizes involved.

**(B) Greedy certificate synthesizer.** Given $k$ and a target period $M$, greedily assign
to the as-yet-uncovered residues modulo $M$ a small prime $p$ dividing $k\cdot 2^a + 1$
whose order of $2$ divides $M$, covering the arithmetic progression
$a \pmod{\operatorname{ord}_p(2)}$ in one move. The search is untrusted; its output is fed
to verifier (A). This realizes the *find/check* separation: finding is heuristic, checking
is sound.

## 9. Applications and discussion

The covering-certificate framework is base- and sign-agnostic. The same two lemmas
(periodicity and transfer) underpin proofs for $k\cdot b^n + 1$ in general bases $b$ and
for **Riesel numbers** $k\cdot 2^n - 1$; only the divisibility target and the periodicity
modulus change, both isolated as certificate fields. Theorem 12 (CRT compatibility) and
Theorem 15 (uniform lower bound) are statements about covering systems per se and apply to
the wider study of exact and disjoint covers initiated by Erdős.

## 10. Future work

- A verified search front end producing certificates checked by Theorem 7.
- Base-$b$ and Riesel generalizations through the abstract certificate fields.
- Formal non-existence (obstruction) results: for fixed $k$ and bounded period, the set of
  residues a prime can cover is a decidable finite object, so "no covering of period $M$
  exists" is machine-checkable.
- Minimality/irredundancy of certificates: coverage is decidable, so verifying that no
  class may be removed without creating a gap is a finite check.

## 11. Conclusion

We have formalized covering systems and Sierpiński certificates and proved their soundness:
a finite, decidable certificate forces a fixed small prime divisor of every $k\cdot 2^n+1$.
The explicit $78557$ data — seven primes, period $36$ — instantiates the framework, while
the minimality of $78557$ is recorded faithfully as an open conjecture. The recurring moral
is that periodicity turns an infinite question into a finite one: one only has to look once.
