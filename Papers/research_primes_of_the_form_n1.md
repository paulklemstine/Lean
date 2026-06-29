# The Local Arithmetic of the Sequence $n^2 + 1$: A Formally Verified Foundation for Landau's Problem and the Friedlander–Iwaniec Theorem

**Author:** Aristotle

**Date:** 2026-06-25

**Domain:** Cryptography / Analytic Number Theory

---

## Abstract

The sequence $n^2 + 1$ sits at the heart of one of Landau's four classical
problems: are there infinitely many primes of the form $n^2 + 1$? The question
remains open. We isolate and rigorously establish the *local* (congruence‑theoretic)
arithmetic that any sieve‑theoretic or heuristic attack on the problem must rest
upon, and we are scrupulous about the boundary between what is unconditionally
true and what is conjectural. Concretely, we prove: (i) a prime $p$ admits a
solution of $x^2 + 1 \equiv 0 \pmod p$ if and only if $p \not\equiv 3 \pmod 4$;
(ii) the exact solution count is $2$ for odd $p \not\equiv 3 \pmod 4$ and $0$ for
$p \equiv 3 \pmod 4$; (iii) the equivalent Legendre‑symbol formulation
$\left(\tfrac{-1}{p}\right) = 1 \iff p \equiv 1 \pmod 4$; (iv) the universal
obstruction that no prime $p \equiv 3 \pmod 4$ divides $n^2 + 1$, whence the count
of $n < X$ with such a factor is *exactly zero* with no analytic input; and (v) the
basic bounds on the local density factor $\nu_p(n)$, namely $\nu_p(n) \le 2$ at odd
primes and $\nu_p(n) = 0$ at primes $p \equiv 3 \pmod 4$. We explicitly disclaim
the singular‑series asymptotic $C \cdot X / \sqrt{\log X}$ as heuristic. We
contextualize these results within Iwaniec's $P_2$ theorem for $n^2 + 1$ and the
Friedlander–Iwaniec theorem on primes of the form $a^2 + b^4$, of which the
Landau sequence is the slice $b = 1$. We close with cryptographic motivation:
the residue class of $p$ modulo $4$ governs the existence of $\sqrt{-1}$ in
$\mathbb{F}_p$, a structural fact pervading public‑key cryptography. All
mathematical claims stated as theorems have been verified to the last logical step
in a proof assistant; conjectural statements are flagged as such throughout.

**Keywords:** primes of the form $n^2+1$, Landau's problem, quadratic residue,
Legendre symbol, quadratic reciprocity, local density, singular series, sieve
methods, Friedlander–Iwaniec, square root of $-1$ modulo $p$.

---

## 1. Introduction

In 1912, at the International Congress of Mathematicians in Cambridge, Edmund
Landau posed four problems about prime numbers that he described as
"unattackable" with the methods then available. One of them asks whether the
polynomial $n^2 + 1$ takes prime values infinitely often. More than a century
later it remains unresolved, despite overwhelming numerical and heuristic
evidence that the answer is yes.

The reason for the difficulty is structural. The values $n^2 + 1$ form a *sparse*
sequence: there are only $\Theta(\sqrt{X})$ of them below $X$. Detecting primes in
a sequence this thin pushes against the fundamental limits of sieve theory, the
principal tool for such problems. The celebrated successes in this circle of ideas
— Iwaniec's theorem that $n^2 + 1$ is a product of at most two primes infinitely
often, and the Friedlander–Iwaniec theorem that $a^2 + b^4$ is prime infinitely
often — all begin from a precise understanding of the *local* behavior of the
sequence: how it distributes among residue classes modulo each prime.

This paper formalizes that local foundation. We take the deliberately humble but
completely rigorous viewpoint: rather than assert the conjectural global
asymptotic, we prove exactly the congruence‑theoretic facts that are
unconditionally available, and we draw a sharp line around the heuristic
ingredients. Every theorem below has been mechanically verified.

### 1.1 Contributions

1. **A local solvability criterion** (Theorem 4.1) pinning down precisely which
   primes can divide $n^2 + 1$.
2. **Exact solution counts** (Theorem 4.2): two solutions or none, decided by
   $p \bmod 4$.
3. **The Legendre‑symbol bridge** (Theorem 4.3) connecting the criterion to
   quadratic reciprocity.
4. **The universal obstruction and its zero‑density corollary** (Theorems 5.1,
   5.2): primes $\equiv 3 \pmod 4$ never divide $n^2 + 1$, and the count of $n<X$
   with such a factor is exactly $0$.
5. **Local density factors** (Definitions 6.1–6.2, Theorems 6.4–6.5): the bounds
   $\nu_p(n) \le 2$ and the vanishing $\nu_p(n) = 0$ at primes $\equiv 3
   \pmod 4$.
6. A careful delineation (Section 7) of the conjectural singular series and the
   $C \cdot X/\sqrt{\log X}$ heuristic, which we do **not** assert as theorems.

---

## 2. Notation and Conventions

Throughout, $p$ denotes a prime and $n$ a natural number. We write $\mathbb{Z}/p$
for the ring of integers modulo $p$ (the finite field $\mathbb{F}_p$ when $p$ is
prime). For an element $x \in \mathbb{Z}/p$, $x.\mathrm{val}$ denotes its
canonical representative in $\{0, 1, \dots, p-1\}$. The Legendre symbol is written
$\left(\tfrac{a}{p}\right)$ or $\mathrm{legendreSym}\,p\,a$, taking values in
$\{-1, 0, 1\}$. We use $p \% 4$ for the remainder of $p$ on division by $4$.

---

## 3. The Solution Set

**Definition 3.1 (solution set).** For a positive modulus $p$, define the finite
set
$$\mathrm{solSet}(p) = \{\, x \in \mathbb{Z}/p : x^2 + 1 = 0 \,\}.$$
Membership is characterized by $x \in \mathrm{solSet}(p) \iff x^2 + 1 = 0$ in
$\mathbb{Z}/p$. This is the set of "roots of the parabola modulo $p$": the residues
$n$ for which $p \mid n^2 + 1$.

All subsequent counting takes place inside this object. Its cardinality, as a
function of $p$, is the central local invariant.

---

## 4. The Local Solvability Criterion

**Theorem 4.1 (solvability criterion).** For a prime $p$,
$$\bigl(\exists\, x \in \mathbb{Z}/p,\ x^2 + 1 = 0\bigr) \iff p \% 4 \neq 3.$$

*Proof sketch.* The statement $x^2 + 1 = 0$ is equivalent to $x^2 = -1$, i.e. to
$-1$ being a quadratic residue modulo $p$. By the first supplement to quadratic
reciprocity (Mathlib's `ZMod.exists_sq_eq_neg_one_iff`), $-1$ is a square modulo
$p$ if and only if $p \not\equiv 3 \pmod 4$. The forward direction rewrites a
solution of $x^2 + 1 = 0$ as a solution of $x^2 = -1$ and invokes this
equivalence; the reverse direction extracts the square root and rearranges. $\;\;
\blacksquare$

**Theorem 4.2 (exact solution counts).** Let $p$ be prime.

1. If $p \neq 2$ and $p \% 4 \neq 3$, then $|\mathrm{solSet}(p)| = 2$.
2. If $p \% 4 = 3$, then $|\mathrm{solSet}(p)| = 0$.

*Proof sketch.* (1) By Theorem 4.1 there is some $i$ with $i^2 = -1$. Then $-i$ is
also a root, and $i \neq -i$: equality would force $2i = 0$, hence (as $p$ is odd
and $i \neq 0$) a contradiction. Any root $x$ satisfies $x^2 = i^2$, so
$x = \pm i$ because a field has no zero divisors ($\,(x-i)(x+i)=0$). Therefore
$\mathrm{solSet}(p) = \{i, -i\}$, a two‑element set. (2) If the set were nonempty
it would furnish a solution of $x^2 + 1 = 0$, contradicting Theorem 4.1 for
$p \equiv 3 \pmod 4$. $\;\; \blacksquare$

The dichotomy is exhaustive among odd primes: every odd prime contributes either
exactly two roots or none, with the case split decided solely by $p \bmod 4$. The
prime $2$ is the lone small exception ($x = 1$ gives $1^2 + 1 = 2 \equiv 0$).

**Theorem 4.3 (Legendre‑symbol formulation).** For a prime $p \neq 2$,
$$\left(\tfrac{-1}{p}\right) = 1 \iff p \% 4 = 1, \qquad
\left(\tfrac{-1}{p}\right) = -1 \iff p \% 4 = 3.$$

*Proof sketch.* Evaluate $\mathrm{legendreSym}\,p\,(-1)$ via the closed form
$\left(\tfrac{-1}{p}\right) = \chi_4(p)$ (Mathlib's `legendreSym.at_neg_one`),
where $\chi_4$ is the non‑trivial character modulo $4$. Since $\chi_4(p)$ depends
only on $p \bmod 4$, a finite case analysis over the residues $p \% 4 \in
\{0,1,2,3\}$ (only $1$ and $3$ occur for odd primes) yields both equivalences.
$\;\; \blacksquare$

This recasts the elementary criterion in the language of quadratic reciprocity,
embedding $n^2 + 1$ into the standard apparatus of algebraic number theory and
making the connection to Gauss's law explicit.

---

## 5. The Universal Obstruction and Zero Density

**Theorem 5.1 (the Great Filter).** For every prime $p$ with $p \% 4 = 3$ and
every natural number $n$,
$$p \nmid n^2 + 1.$$

*Proof sketch.* Suppose $p \mid n^2 + 1$. Reducing modulo $p$, the image of $n$
would be a solution of $x^2 + 1 = 0$ in $\mathbb{Z}/p$, contradicting Theorem 4.1
in the case $p \equiv 3 \pmod 4$. $\;\; \blacksquare$

This is the single most consequential fact about the sequence: roughly half of all
primes (those $\equiv 3 \pmod 4$) are *categorically excluded* as factors of
$n^2 + 1$. The sequence is composed solely of the prime $2$ and primes
$\equiv 1 \pmod 4$.

**Theorem 5.2 (exact zero count).** For every $X$,
$$\#\{\, n < X : \exists\, p\ \text{prime},\ p \% 4 = 3,\ p \mid n^2 + 1 \,\} = 0.$$

*Proof sketch.* The defining predicate of the counted set is never satisfied: for
any $n$ and any prime $p \equiv 3 \pmod 4$, Theorem 5.1 gives $p \nmid n^2 + 1$.
Hence the filtered finite set is empty and its cardinality is $0$. $\;\;
\blacksquare$

We stress what this proof does *not* use: no prime number theorem, no analytic
estimate, no sieve. The proportion is forced to $0$ purely by the Legendre‑symbol
obstruction of Theorem 5.1. This is the cleanest possible illustration of how
local information alone can settle a counting question exactly — precisely because
the count in question is degenerate.

---

## 6. Local Density Factors

The heuristic density of primes in $n^2+1$ is assembled from local factors. We
define them and establish their unconditional bounds.

**Definition 6.1 (local density factor).** For a prime $p$ and natural number $n$,
$$\nu_p(n) = \#\{\, x \in \mathbb{Z}/p : x^2 + 1 = 0 \ \text{and}\
\gcd(x.\mathrm{val},\, n) = 1 \,\}.$$
This counts the roots of the parabola modulo $p$ that are additionally coprime to
$n$ — the roots relevant when one tracks the multiplicative structure of $n^2+1$.

**Definition 6.2 (normalized local factor).** $\mathrm{localFactor}(p, n) =
\nu_p(n)/p \in \mathbb{R}$. These are the per‑prime factors $\nu_p/p$ assembled
into the (conjectural) singular series $\mathfrak{S} = \prod_p \nu_p/p$ of
Section 7.

**Lemma 6.3 (domination).** $\nu_p(n) \le |\mathrm{solSet}(p)|$.

*Proof sketch.* The set counted by $\nu_p(n)$ is a subset of $\mathrm{solSet}(p)$
(it imposes the extra coprimality condition), so its cardinality is no larger by
monotonicity of cardinality under inclusion. $\;\; \blacksquare$

**Theorem 6.4 (upper bound at odd primes).** For a prime $p \neq 2$ and any $n$,
$$\nu_p(n) \le 2.$$

*Proof sketch.* Combine Lemma 6.3 with Theorem 4.2. If $p \equiv 3 \pmod 4$, then
$|\mathrm{solSet}(p)| = 0 \le 2$; otherwise $|\mathrm{solSet}(p)| = 2$. In both
cases $\nu_p(n) \le 2$. $\;\; \blacksquare$

**Theorem 6.5 (vanishing at the banned primes).** For a prime $p$ with $p \% 4 =
3$ and any $n$,
$$\nu_p(n) = 0.$$

*Proof sketch.* By Theorem 4.2(2), $|\mathrm{solSet}(p)| = 0$, and by Lemma 6.3
$\nu_p(n) \le 0$, so $\nu_p(n) = 0$. The local density honestly reflects the Great
Filter: it is zero exactly where divisibility is impossible. $\;\; \blacksquare$

Together, Theorems 6.4 and 6.5 give the unconditional skeleton of the local
factors: at $p = 2$ a special small value, at $p \equiv 1 \pmod 4$ a value in
$\{0,1,2\}$, and at $p \equiv 3 \pmod 4$ identically zero. These are the only
rigorously available ingredients of the singular series.

---

## 6½. Worked Examples and Sanity Checks

It is instructive to see the theorems act on concrete data, both to build intuition
and to confirm that the formal statements say what we intend.

**The criterion in action.** Consider $p = 13 \equiv 1 \pmod 4$. Theorem 4.1
predicts solvability, Theorem 4.2 predicts exactly two roots. Indeed $5^2 + 1 = 26
= 2 \cdot 13$ and $8^2 + 1 = 65 = 5 \cdot 13$, so the roots modulo $13$ are $\{5,
8\} = \{5, -5\}$ — precisely two, and negatives of one another, as the proof of
Theorem 4.2 demands. Now consider $p = 11 \equiv 3 \pmod 4$. Theorem 4.2(2)
predicts no roots, and scanning $n = 0, \dots, 10$ gives $n^2 + 1 \in \{1, 2, 5,
10, 17, 26, 37, 50, 65, 82, 101\}$, none divisible by $11$.

**The Legendre bridge.** For $p = 13$, Euler's criterion gives $(-1)^{(13-1)/2} =
(-1)^6 = 1$, so $\left(\tfrac{-1}{13}\right) = 1$, matching Theorem 4.3 since
$13 \equiv 1 \pmod 4$. For $p = 11$, $(-1)^{(11-1)/2} = (-1)^5 = -1$, so
$\left(\tfrac{-1}{11}\right) = -1$, matching $11 \equiv 3 \pmod 4$.

**The Great Filter as factorization shape.** The first few values $n^2 + 1$
factor as $2,\ 5,\ 10 = 2\cdot 5,\ 17,\ 26 = 2 \cdot 13,\ 37,\ 50 = 2 \cdot
5^2,\ 65 = 5 \cdot 13,\ 82 = 2 \cdot 41,\ 101$. Every prime appearing — $2, 5,
13, 41, 101$ — is either $2$ or congruent to $1 \pmod 4$. No prime $\equiv 3
\pmod 4$ (such as $3, 7, 11, 19$) ever appears, illustrating Theorems 5.1 and
5.2.

**Local factors.** At $p = 5$ with $n = 1$, the roots of $x^2 + 1 = 0$ are
$\{2, 3\}$, both coprime to $1$, so $\nu_5(1) = 2$, saturating the bound of
Theorem 6.4. At $p = 5$ with $n = 6$, the relevant gcd condition removes both
roots (since $2$ and $3$ each share a factor with $6$), giving $\nu_5(6) = 0$. At
any $p \equiv 3 \pmod 4$, e.g. $p = 7$, the solution set is empty and so
$\nu_7(n) = 0$ for every $n$, illustrating Theorem 6.5.

These examples are not proofs, but they confirm the formal statements are
faithful and provide the kind of ground truth against which the verified theorems
can be checked.

## 7. The Singular Series and the Landau Heuristic (Conjectural)

For completeness we describe the heuristic in which the local factors live, and we
emphasize that nothing in this section is asserted as proved.

The Hardy–Littlewood / Bateman–Horn philosophy predicts that the number of
$n \le X$ with $n^2 + 1$ prime is asymptotically
$$\#\{ n \le X : n^2 + 1 \text{ prime}\} \sim \mathfrak{S} \cdot \frac{X}{\sqrt{\log X}}\cdot
\frac{1}{2}, \qquad
\mathfrak{S} = \prod_{p\ \text{odd}} \left(1 - \frac{\chi_4(p)}{p-1}\right),$$
an Euler product over the local data of the parabola, with the $\sqrt{\log X}$
(rather than $\log X$) reflecting that $n^2+1$ ranges over $\Theta(\sqrt X)$ values.
The local factors $\nu_p/p$ of Section 6 are the building blocks of $\mathfrak{S}$.

**This asymptotic is conjectural.** It is equivalent in strength to (a refined
form of) Landau's problem and is far beyond current technology. Our formalization
proves the *local* factors exactly and deliberately stops there; the global
product and its consequence for primality are not theorems.

---

## 8. Context: Almost‑Primes and the Friedlander–Iwaniec Theorem

The local foundation above is the entry point to two landmark results.

**Iwaniec (1978).** There are infinitely many $n$ such that $n^2 + 1$ is a
$P_2$ number — a prime or a product of two primes. The proof runs a
half‑dimensional sieve whose local inputs are exactly the solution counts of
Theorem 4.2 and the obstruction of Theorem 5.1: the sieve never wastes effort on
primes $\equiv 3 \pmod 4$ because they cannot occur as factors.

**Friedlander–Iwaniec (1998).** There are infinitely many primes of the form
$a^2 + b^4$. This sequence is even sparser, with $\Theta(X^{3/4})$ values below
$X$, and its resolution required genuinely new "asymmetric" sieve techniques.

The two are nested. Setting $b = 1$ collapses $a^2 + b^4$ to $a^2 + 1$, so the
Landau sequence is the thinnest slice of the Friedlander–Iwaniec family. The
inclusion of primes,
$$\{\, p : p = n^2 + 1 \,\} \subseteq \{\, p : p = a^2 + b^4 \,\},$$
holds trivially via $(a, b) = (n, 1)$. Friedlander and Iwaniec proved the
larger set infinite without resolving its $b=1$ slice, because fixing $b=1$
discards the two‑variable flexibility their method exploits. This nesting clarifies
why the harder‑sounding problem ($a^2+b^4$) is the one that has been solved: more
variables mean more averaging room for the sieve.

---

## 9. Cryptographic Relevance

The criterion $\left(\tfrac{-1}{p}\right) = 1 \iff p \equiv 1 \pmod 4$ is not an
abstraction; it is operationally central to cryptography.

- **Existence of $\sqrt{-1}$.** Whether $-1$ is a square in $\mathbb{F}_p$
  determines the structure of $\mathbb{F}_p^\times$ relevant to square‑root
  extraction, to the Tonelli–Shanks algorithm's branching, and to the cheap
  square roots available when $p \equiv 3 \pmod 4$ (the basis of the Rabin
  cryptosystem and of fast decompression of elliptic‑curve points).
- **Elliptic‑curve parameters.** The residue $p \bmod 4$ influences the supply of
  curves with prescribed properties (e.g. the existence of curves with a point of
  order related to $4$, and the behavior of the quadratic twist), which feeds into
  parameter selection for ECC and pairing‑based schemes.
- **Structured primes.** When a protocol requires primes of a special algebraic
  form, certainty about which primes can divide a structured sequence is a
  security property, not a convenience. Theorem 5.1 supplies exactly such a
  guarantee for $n^2 + 1$: a fully verified statement that an entire residue class
  of primes is excluded.

The value of a *formally verified* local theory here is concrete: cryptographic
parameter choices that depend on these congruence facts inherit a machine‑checked
guarantee rather than a textbook assertion.

---

## 10. Discussion and Future Work

We have isolated and verified the unconditional local arithmetic of $n^2 + 1$ and
framed the conjectural global picture honestly. The natural next steps are:

1. **Quantitative divisor density.** Turn the qualitative occurrence of primes
   $\equiv 1 \pmod 4$ as divisors of $n^2+1$ into a density statement of the form
   $\gg X / \log X$ distinct such primes below appropriate bounds, using only
   counting infrastructure.
2. **Parity‑refined bases.** Investigate whether evenness of the base $n$ is the
   *only* unconditional congruence obstruction on $n$ when $n^2+1$ is prime, the
   obstruction at primes $\equiv 3 \pmod 4$ on the divisor side being already
   forbidden.
3. **A formal sieve skeleton.** Develop the combinatorial (Buchstab/Selberg)
   skeleton of the half‑dimensional sieve underlying Iwaniec's $P_2$ theorem,
   separating the combinatorics from the analytic bound.
4. **Strictness of the Landau–Friedlander–Iwaniec inclusion.** Establish that the
   inclusion of $n^2+1$ primes into $a^2+b^4$ primes is strict, witnessed by
   $a^2 + b^4$ primes with $b \ge 2$ that are not perfect‑square shifts.

The dividing line drawn in this paper — total command of the local structure,
genuine open‑ness of the global question — is the characteristic shape of problems
about primes in sparse sequences, and it is exactly the terrain on which the next
advances will be made.

---

## 11. Conclusion

Primes of the form $n^2 + 1$ remain one of the most enticing open problems in
number theory. We cannot yet prove there are infinitely many, but we can prove,
exactly and unconditionally, the local laws that govern the sequence: which primes
may divide it (only $2$ and those $\equiv 1 \pmod 4$), how many roots each admits
(two or none), and the equivalent Legendre‑symbol criterion. From these follow a
universal divisibility obstruction with an exact zero‑count corollary, and tight
bounds on the local density factors that feed the conjectural singular series.
These results are the rigorous bedrock beneath Iwaniec's almost‑prime theorem and
the Friedlander–Iwaniec theorem, and they carry direct cryptographic meaning
through the existence of $\sqrt{-1}$ modulo $p$. The local truth is complete; the
global truth waits.

---

## References

1. E. Landau, *Gelöste und ungelöste Probleme aus der Theorie der
   Primzahlverteilung und der Riemannschen Zetafunktion*, Proc. 5th Int. Congr.
   Math. (1912).
2. H. Iwaniec, *Almost‑primes represented by quadratic polynomials*, Invent.
   Math. **47** (1978), 171–188.
3. J. Friedlander and H. Iwaniec, *The polynomial $X^2 + Y^4$ captures its
   primes*, Ann. of Math. **148** (1998), 945–1040.
4. P. T. Bateman and R. A. Horn, *A heuristic asymptotic formula concerning the
   distribution of prime numbers*, Math. Comp. **16** (1962), 363–367.
5. G. H. Hardy and J. E. Littlewood, *Some problems of 'Partitio numerorum' III*,
   Acta Math. **44** (1923), 1–70.
6. C. F. Gauss, *Disquisitiones Arithmeticae* (1801).
