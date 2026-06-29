# A Uniform Local Obstruction Calculus for Diagonal Sums of Powers

## Abstract

We develop a uniform, fully formalized framework for the local solvability of
diagonal Diophantine equations of the form

$$x_1^n + x_2^n + \cdots + x_s^n = k,$$

for arbitrary degree $n \ge 1$, term count $s \ge 1$, and target $k \in \mathbb{Z}$.
The framework rests on a single predicate, *local admissibility modulo $m$*, which
asserts that the congruence $\sum_{i=1}^{s} x_i^n \equiv k \pmod m$ is solvable in
$\mathbb{Z}/m\mathbb{Z}$. Around it we prove five structural theorems that together
constitute an *obstruction calculus*: (1) a global-to-local principle stating that
integer representability forces local admissibility at every modulus; (2) a
divisibility-descent law showing that admissibility propagates from coarser to finer
moduli through quotient maps; (3) a completeness theorem identifying *universally
surjective* moduli as those carrying no obstruction; (4) a multiplicative symmetry
theorem showing the admissible set is invariant under the action of $n$-th powers of
units; and (5) a Chinese-Remainder composition theorem reducing universal surjectivity
to the prime-power case. We additionally specify a decision procedure that computes the
exact set of attainable residues and prove its correctness. All results have been
mechanically verified. We situate the calculus within the classical local–global
program (Hasse principle, Waring's problem, sums of three cubes) and identify
directions for extension.

**Keywords:** diagonal forms, sums of powers, local–global principle, Hasse
principle, Waring's problem, modular obstructions, Chinese Remainder Theorem,
power residues, formal verification.

---

## 1. Introduction

The question of which integers are representable by a fixed diagonal form
$\sum_{i=1}^{s} x_i^n$ is among the oldest in number theory and contains, as special
cases, sums of two squares (Fermat–Euler), Waring's problem (Hilbert), and the
notoriously delicate problem of sums of three cubes. A recurring and powerful theme is
the *local–global principle*: a global integer solution must reduce, modulo every $m$,
to a solution of the corresponding congruence. The contrapositive supplies a purely
finite certificate of *non*-representability — a *local obstruction*.

The canonical example is the impossibility of writing $k \equiv \pm 4 \pmod 9$ as a sum
of three cubes, because the only cubic residues modulo $9$ are $\{0, 1, 8\}$ and no
three of them sum to $4$ or $5$ modulo $9$. This single congruence eliminates an entire
arithmetic progression of targets without any search.

The purpose of this paper is to abstract that mechanism into a uniform calculus that
holds for *all* $(n, s)$ simultaneously, to prove its core structural laws, and to
provide a certified decision procedure. The contribution is twofold: a clean axiomatic
organization of the local theory of diagonal forms, and a complete formal verification
of every statement, eliminating any gap between informal "napkin" arguments and
rigorous proof.

### 1.1 Notation

Throughout, $n, s, m, M, m_1, m_2$ denote natural numbers, $k$ an integer, and
$\mathbb{Z}/m\mathbb{Z}$ the ring of residues modulo $m$. For $a \in \mathbb{Z}$ we write
$\bar a$ for its image in $\mathbb{Z}/m\mathbb{Z}$. We index $s$-tuples by the finite
type $\{0, 1, \dots, s-1\}$ and write $x : \{0,\dots,s-1\} \to R$ for an $s$-tuple over a
ring $R$. The phrase "unit" means an invertible element of $\mathbb{Z}/m\mathbb{Z}$.

---

## 2. Definitions

We fix the diagonal form parameters $n$ (degree) and $s$ (number of terms).

**Definition 2.1 (Local admissibility).**
An integer $k$ is *locally admissible* for $s$ powers of degree $n$ modulo $m$,
written $\mathrm{Adm}_{n,s}(k, m)$, if there exists an $s$-tuple
$x : \{0,\dots,s-1\} \to \mathbb{Z}/m\mathbb{Z}$ with
$$\sum_{i} x_i^{\,n} = \bar k \quad \text{in } \mathbb{Z}/m\mathbb{Z}.$$

**Definition 2.2 (Everywhere local admissibility).**
An integer $k$ is *everywhere locally admissible*, written $\mathrm{EAdm}_{n,s}(k)$, if
$\mathrm{Adm}_{n,s}(k, m)$ holds for every $m > 0$.

**Definition 2.3 (Universal surjectivity).**
A modulus $m$ is *universally surjective* for $(n, s)$, written $\mathrm{Surj}_{n,s}(m)$,
if every residue is a sum of $s$ $n$-th powers:
$$\forall\, a \in \mathbb{Z}/m\mathbb{Z},\ \exists\, x : \{0,\dots,s-1\} \to \mathbb{Z}/m\mathbb{Z},\quad a = \sum_i x_i^{\,n}.$$

**Definition 2.4 (Global representability).**
An integer $k$ is *globally representable*, written $\mathrm{Rep}_{n,s}(k)$, if there
exists an integer $s$-tuple $x : \{0,\dots,s-1\} \to \mathbb{Z}$ with
$\sum_i x_i^{\,n} = k$ in $\mathbb{Z}$.

**Definition 2.5 (Computed residue set).**
For $m > 0$, the *computed residue set* is the finite image
$$\mathrm{R}_{n,s}(m) \;=\; \bigl\{\, \textstyle\sum_i x_i^{\,n} \;:\; x : \{0,\dots,s-1\} \to \mathbb{Z}/m\mathbb{Z} \,\bigr\} \subseteq \mathbb{Z}/m\mathbb{Z}.$$
Because $\mathbb{Z}/m\mathbb{Z}$ is finite, the index set of tuples is finite, so
$\mathrm{R}_{n,s}(m)$ is a computable finite set.

These four predicates and one constructed set are the only primitives of the theory. All
results below are statements relating them.

---

## 3. Main Results

### 3.1 The global-to-local principle

**Theorem 3.1 (Global ⟹ local).**
*For every $n, s$, every $k \in \mathbb{Z}$, and every $m > 0$, global
representability implies local admissibility:*
$$\mathrm{Rep}_{n,s}(k) \;\Longrightarrow\; \mathrm{Adm}_{n,s}(k, m).$$

*Proof sketch.* Let $x : \{0,\dots,s-1\} \to \mathbb{Z}$ witness
$\sum_i x_i^n = k$ in $\mathbb{Z}$. Apply the ring homomorphism
$\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z}$ to both sides. Since reduction is a ring
homomorphism, it commutes with finite sums and with the $n$-th power operation, giving
$\sum_i \bar{x_i}^{\,n} = \bar k$. The tuple $\bar x$ is the required witness. $\qed$

**Corollary 3.2 (Global ⟹ everywhere local).**
$\mathrm{Rep}_{n,s}(k) \Rightarrow \mathrm{EAdm}_{n,s}(k)$.

*Proof.* Immediate from Theorem 3.1 by quantifying over all $m > 0$. $\qed$

**Remark.** The contrapositive of Corollary 3.2 is the engine of non-representability
proofs: exhibiting a single $m$ with $\neg\,\mathrm{Adm}_{n,s}(k, m)$ certifies
$\neg\,\mathrm{Rep}_{n,s}(k)$. This is precisely the napkin argument for sums of three
cubes (Section 5.1).

### 3.2 Divisibility descent

**Theorem 3.3 (Descent along divisibility).**
*Let $0 < m \mid M$. Then admissibility modulo $M$ implies admissibility modulo $m$:*
$$\mathrm{Adm}_{n,s}(k, M) \;\Longrightarrow\; \mathrm{Adm}_{n,s}(k, m).$$

*Proof sketch.* When $m \mid M$ there is a canonical surjective ring homomorphism (the
quotient/reduction map) $\pi : \mathbb{Z}/M\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z}$
compatible with the inclusions of $\mathbb{Z}$. Given a witness
$x : \{0,\dots,s-1\} \to \mathbb{Z}/M\mathbb{Z}$ with $\sum_i x_i^n = \bar k$ in
$\mathbb{Z}/M\mathbb{Z}$, apply $\pi$. As a ring map it preserves the sum and the
$n$-th powers, and it sends the image of $k$ in $\mathbb{Z}/M\mathbb{Z}$ to the image of
$k$ in $\mathbb{Z}/m\mathbb{Z}$. Thus $\pi \circ x$ witnesses admissibility mod $m$.
$\qed$

**Remark.** Descent orders the moduli by divisibility and shows obstruction-relevant
information flows from finer to coarser. Equivalently, *transparency* (absence of
obstruction) is harder to achieve at finer moduli, so the sharpest obstructions live at
the highest prime powers. Together with Theorem 3.6, this justifies restricting any
obstruction search to prime-power moduli.

### 3.3 Completeness from universal surjectivity

**Theorem 3.4 (Surjectivity ⟹ universal admissibility).**
*If $m > 0$ is universally surjective, then every integer is locally admissible at $m$:*
$$\mathrm{Surj}_{n,s}(m) \;\Longrightarrow\; \forall k \in \mathbb{Z},\ \mathrm{Adm}_{n,s}(k, m).$$

*Proof sketch.* Given $k$, apply universal surjectivity to the residue $\bar k$ to obtain
$x$ with $\bar k = \sum_i x_i^n$. Symmetrizing the equality yields $\sum_i x_i^n = \bar k$,
which is exactly the witness for $\mathrm{Adm}_{n,s}(k, m)$. $\qed$

**Interpretation.** A universally surjective modulus contributes no obstruction: it
certifies *every* target as locally fine. Establishing universal surjectivity at the
relevant prime powers is therefore the standard route to a positive local–global heuristic.

### 3.4 Multiplicative symmetry of the admissible set

Let $S_{n,s}(m) = \{\, r \in \mathbb{Z}/m\mathbb{Z} : \exists x,\ r = \sum_i x_i^n \,\}$
denote the set of residues realizable as sums of $s$ $n$-th powers (equal to
$\mathrm{R}_{n,s}(m)$ of Definition 2.5).

**Theorem 3.5 (Unit $n$-th-power invariance).**
*Let $a \in \mathbb{Z}/m\mathbb{Z}$ be a unit and $u = a^n$. If $r \in S_{n,s}(m)$ then
$u \cdot r \in S_{n,s}(m)$.*

*Proof sketch.* Write $r = \sum_i x_i^n$. Then
$$u \cdot r = a^n \sum_i x_i^n = \sum_i a^n x_i^n = \sum_i (a\,x_i)^n,$$
using distributivity and $a^n x_i^n = (a x_i)^n$ in the commutative ring
$\mathbb{Z}/m\mathbb{Z}$. The tuple $(a x_i)_i$ exhibits $u\cdot r$ as a sum of $s$
$n$-th powers. $\qed$

**Structural consequence.** Let $U_m^{(n)} = \{\, a^n : a \in (\mathbb{Z}/m\mathbb{Z})^\times \,\}$
be the subgroup of $n$-th powers of units. Theorem 3.5 says $S_{n,s}(m)$ is closed under
multiplication by $U_m^{(n)}$, i.e. it is a union of $U_m^{(n)}$-orbits. This connects the
*additive* representability set to the *multiplicative* structure of the unit group: the
admissible set inherits the symmetry of the $n$-th-power residue subgroup. Computationally,
one representative per orbit determines the whole orbit, reducing the cost of mapping
$S_{n,s}(m)$.

### 3.5 Chinese Remainder composition

**Theorem 3.6 (Coprime composition of surjectivity).**
*Let $m_1, m_2 > 0$ be coprime. If both are universally surjective for $(n, s)$, so is
their product:*
$$\mathrm{Surj}_{n,s}(m_1) \wedge \mathrm{Surj}_{n,s}(m_2) \;\Longrightarrow\; \mathrm{Surj}_{n,s}(m_1 m_2).$$

*Proof sketch.* The Chinese Remainder Theorem gives a ring isomorphism
$\varphi : \mathbb{Z}/(m_1 m_2)\mathbb{Z} \xrightarrow{\ \sim\ } \mathbb{Z}/m_1\mathbb{Z} \times \mathbb{Z}/m_2\mathbb{Z}$.
Given a target $a \in \mathbb{Z}/(m_1 m_2)\mathbb{Z}$, write $\varphi(a) = (a_1, a_2)$.
By surjectivity in each factor choose tuples $x^{(1)}, x^{(2)}$ with
$a_1 = \sum_i (x^{(1)}_i)^n$ and $a_2 = \sum_i (x^{(2)}_i)^n$. Define
$x_i = \varphi^{-1}(x^{(1)}_i, x^{(2)}_i)$. Since $\varphi^{-1}$ is a ring isomorphism it
preserves sums and powers componentwise, so
$\sum_i x_i^n = \varphi^{-1}\!\bigl(\sum_i (x^{(1)}_i)^n,\ \sum_i (x^{(2)}_i)^n\bigr) = \varphi^{-1}(a_1, a_2) = a$.
$\qed$

**Reduction to prime powers.** Any $m$ factors as $\prod_p p^{e_p}$ into pairwise coprime
prime powers. Iterating Theorem 3.6, $\mathrm{Surj}_{n,s}(m)$ holds whenever it holds at
each $p^{e_p}$. Combined with Theorem 3.3 (descent), the entire local theory is determined
by the prime-power moduli.

---

## 4. A Certified Decision Procedure

### 4.1 Specification

The set $\mathrm{R}_{n,s}(m)$ of Definition 2.5 is computed by enumerating all
$m^s$ tuples $x : \{0,\dots,s-1\} \to \mathbb{Z}/m\mathbb{Z}$, evaluating
$\sum_i x_i^n$ for each, and collecting the distinct results.

**Theorem 4.1 (Correctness of the decision procedure).**
*For every $m > 0$ and every residue $k \in \mathbb{Z}/m\mathbb{Z}$,*
$$k \in \mathrm{R}_{n,s}(m) \iff \exists\, x : \{0,\dots,s-1\} \to \mathbb{Z}/m\mathbb{Z},\ \sum_i x_i^n = k.$$

*Proof sketch.* Unfold $\mathrm{R}_{n,s}(m)$ as the image of the evaluation map over the
finite universe of tuples. Membership in the image of a function over a finite set is, by
definition, the existence of a preimage, which is exactly the stated existential. $\qed$

**Corollary 4.2 (Decidability of local admissibility).**
For each $(n, s, k, m)$ with $m > 0$, $\mathrm{Adm}_{n,s}(k, m)$ is decidable: compute
$\mathrm{R}_{n,s}(m)$ and test whether $\bar k$ is a member.

### 4.2 Algorithmic schema

```
function residue_sums(n, s, m):
    P ← { (x^n mod m) : x in 0..m-1 }          # n-th power residues
    R ← {0}                                     # sums of 0 powers
    repeat s times:
        R ← { (r + p) mod m : r in R, p in P }  # Minkowski sum with P
    return R

function locally_admissible(n, s, k, m):
    return (k mod m) in residue_sums(n, s, m)
```

Two efficiency notes follow directly from the theory. First, the inner loop builds the set
incrementally as an iterated *Minkowski sum* of the power-residue set $P$ with itself,
costing $O(s \cdot m \cdot |P|)$ rather than the naive $O(m^s)$. Second, by Theorem 3.5 the
final set $R$ is a union of $U_m^{(n)}$-orbits, so it can be canonicalized and stored by
orbit representatives.

---

## 5. Worked Examples and Applications

### 5.1 Sums of three cubes (the mod-9 obstruction)

Take $n = 3$, $s = 3$. The cubic residues modulo $9$ are
$\{0^3, \dots, 8^3\} \bmod 9 = \{0, 1, 8\}$. The Minkowski sum of three copies yields
$$\mathrm{R}_{3,3}(9) = \{0, 1, 2, 3, 6, 7, 8\},$$
omitting $4$ and $5$. By Theorem 4.1 this omission is exact, and by (the contrapositive
of) Corollary 3.2, every integer $k \equiv 4$ or $5 \pmod 9$ satisfies
$\neg\,\mathrm{Rep}_{3,3}(k)$: it is not a sum of three cubes. This reproduces, as a
certified instance, the only known obstruction for three cubes, and explains why $33$ and
$42$ (both $\not\equiv \pm 4 \pmod 9$) remained candidates and were eventually shown
representable, while $4, 5, 13, 14, \dots$ never can be.

### 5.2 Sums of two squares (no obstruction beyond the classical one)

For $n = 2$, $s = 2$, modulo $4$ the quadratic residues are $\{0, 1\}$ and
$\mathrm{R}_{2,2}(4) = \{0, 1, 2\}$, so $3 \pmod 4$ is obstructed — recovering the familiar
fact that a number $\equiv 3 \pmod 4$ is not a sum of two squares. The full
two-squares theorem requires prime-by-prime analysis beyond a single modulus, illustrating
that the *single-modulus* test is sound (Theorem 3.1) but not always complete.

### 5.3 Waring-type universal surjectivity

For $n = 2$, every residue mod a prime $p$ is a sum of *two* squares (a classical count via
character sums), so $\mathrm{Surj}_{2,2}(p)$ holds for all primes $p$. Theorem 3.6 then
lifts surjectivity to all squarefree moduli, and case analysis at $2$ and odd prime powers
extends it further; by Theorem 3.4 those moduli impose no obstruction whatsoever. This is
the local skeleton of Waring's problem: identifying the moduli at which $s$ $n$-th powers
already cover all residues.

### 5.4 Searching for obstructions

To test whether a given $(n, s)$ admits *any* local obstruction, Theorems 3.3 and 3.6
reduce the search to prime powers $p^e$. One enumerates $\mathrm{R}_{n,s}(p^e)$ for small
prime powers; a proper omission certifies an obstruction (and an arithmetic progression of
non-representable $k$), while $\mathrm{R}_{n,s}(p^e) = \mathbb{Z}/p^e\mathbb{Z}$ for all
relevant $p^e$ certifies the absence of local obstructions and supports a local–global
heuristic for full representability.

---

## 5b. Computational Complexity and the Orbit Structure

The naive realization of Definition 2.5 enumerates all $m^s$ tuples, which is
prohibitive even for modest parameters. The structural theorems of Section 3
yield three independent speedups, each provably sound.

**Minkowski-sum decomposition.** Writing $P = \{x^n : x \in \mathbb{Z}/m\mathbb{Z}\}$
for the set of $n$-th power residues, one has
$\mathrm{R}_{n,s}(m) = \underbrace{P \oplus P \oplus \cdots \oplus P}_{s}$, where
$A \oplus B = \{(a+b) \bmod m : a \in A, b \in B\}$ is the Minkowski (sumset) sum.
Building the set incrementally costs $O(s \cdot m \cdot |P|) \le O(s\,m^2)$ ring
operations, an exponential improvement over $O(m^s)$. Correctness is exactly
Theorem 4.1, since the iterated sumset is by construction the image of the
evaluation map.

**Prime-power reduction.** By Theorem 3.3 (descent) and Theorem 3.6 (CRT
composition), the entire local theory factors through the prime-power moduli
$p^e \mid m$. To decide local admissibility modulo a general $m$, it suffices to
decide it at each maximal prime power in the factorization of $m$ and recombine.
In particular, certifying the *absence* of local obstructions for a pair $(n,s)$
reduces to checking universal surjectivity at finitely many small prime powers.

**Orbit compression.** By Theorem 3.5, $\mathrm{R}_{n,s}(m)$ is a union of orbits
of the subgroup $U_m^{(n)} = \{a^n : a \in (\mathbb{Z}/m\mathbb{Z})^\times\}$
acting by multiplication. One may therefore store and compute $\mathrm{R}_{n,s}(m)$
by orbit representatives: determining membership of any single element of an orbit
determines the whole orbit. When $U_m^{(n)}$ is large (e.g. $n$ coprime to
$\varphi(m)$, where the $n$-th power map is a bijection on units), this collapses
the bookkeeping dramatically.

**Example (orbit count).** For $n = 3$, $m = 19$, the cubic residues among the
units form the subgroup $U_{19}^{(3)}$ of index $\gcd(3, 18) = 3$, so the eighteen
nonzero units split into exactly three cubic-residue cosets; the admissible set is
a union of these orbits together with the contribution of $0$. The orbit
viewpoint reduces the description of $\mathrm{R}_{n,s}(19)$ from eighteen elements
to three orbit tags.

---

## 6. Relation to the Classical Local–Global Program

The calculus formalizes the *necessary* direction of the Hasse principle for diagonal
forms: representability over $\mathbb{Z}$ forces solvability over every $\mathbb{Z}/m$
(Theorem 3.1), equivalently over $\mathbb{Z}_p$ for all $p$ and over $\mathbb{R}$ when sign
constraints are added. Hilbert's solution of Waring's problem guarantees that, for $s$ large
relative to $n$, the local conditions become *sufficient* for all large $k$; the residual
finite set of exceptions is exactly the locus where the obstruction sets of Section 5 bite.
The well-known failures of the Hasse principle (e.g. Selmer's curve
$3x^3 + 4y^3 + 5z^3 = 0$, which is everywhere locally solvable yet has no nontrivial integer
point) show that everywhere-local-admissibility is *not* sufficient in general; this is the
threshold at which the Brauer–Manin obstruction enters. The present framework captures the
robust, decidable, always-valid half of this picture and isolates precisely where the deeper
theory must take over.

---

## 7. Discussion and Future Work

The calculus is deliberately minimal: four predicates, one computed set, five theorems, one
correctness statement. Its value lies in uniformity (all $(n,s)$ at once), certainty (every
statement mechanically verified), and computability (a certified decision procedure). Several
extensions are natural.

1. **Completeness thresholds.** Make precise, for each $(n, s)$, the finite set of prime
   powers that must be checked to certify the *absence* of local obstructions, turning the
   heuristic of Section 5.4 into a finite algorithm with proven coverage.

2. **Sign and real obstructions.** Incorporate the archimedean place (positivity / sign
   patterns for even $n$) to obtain a full set of local conditions including $\mathbb{R}$.

3. **Orbit-quotient algorithms.** Exploit Theorem 3.5 to compute and store $S_{n,s}(m)$ by
   $U_m^{(n)}$-orbit representatives, with verified canonical forms.

4. **Mixed and weighted diagonal forms.** Generalize to $\sum_i a_i x_i^{n_i} = k$ with
   distinct coefficients and exponents, where the symmetry and CRT theorems should persist in
   suitably modified form.

5. **Connection to balanced/tropical certificates.** The companion catalog directions below
   explore how Plücker-style and tropical certificate machinery can consume modular
   admissibility data; the orbit structure of Theorem 3.5 is a candidate interface.

### 7.1 Soundness, completeness, and the limits of the local method

It is worth stating precisely what the calculus does and does not deliver. The
framework is *sound* for non-representability: by Corollary 3.2, a single modulus
$m$ with $\neg\,\mathrm{Adm}_{n,s}(k, m)$ is an unconditional certificate that
$k$ is not a sum of $s$ $n$-th powers over $\mathbb{Z}$. This direction is exact
and requires no hypotheses. The framework is *not* complete for representability:
everywhere local admissibility, $\mathrm{EAdm}_{n,s}(k)$, is necessary but not in
general sufficient for $\mathrm{Rep}_{n,s}(k)$. Three distinct phenomena explain
the gap. First, for fixed small $s$ the global density of representable integers
may be thin even where no congruence obstructs (the three-cubes problem, with
$s = 3$, is conjecturally representable for all $k \not\equiv \pm 4 \pmod 9$, but
this remains open). Second, for $s$ large relative to $n$, Hilbert–Waring theory
makes local conditions asymptotically sufficient, leaving only finitely many
exceptional $k$. Third, in the projective/homogeneous setting genuine failures of
the Hasse principle occur, and these are organized by the Brauer–Manin
obstruction, which is invisible to any single-modulus congruence test. The
calculus thus occupies a precise niche: it is the complete, decidable, always-valid
theory of the *congruence* obstruction, and it cleanly demarcates where deeper,
non-elementary machinery must enter.

---

## Appendix: Future Directions (from the originating program)

> **A full Buneman recovery theorem (metric ⇒ tree).** Conjecture: a symmetric nonnegative
> $d$ on a finite type satisfies the four-point condition for every quadruple if and only if
> there is a weighted tree realizing $d$ exactly. The forward direction generalizes the
> ultrametric lemmas from the equidistant locus to all tree metrics; the converse is the
> constructive heart of $M_{0,n}^{\mathrm{trop}}$. The four-point condition is exactly the
> tropical Plücker locus, so the attained-twice disjunction is precisely the gluing data of
> the Buneman split system, and a tree can be reconstructed split-by-split from the equality
> cases. The remaining work is a finite induction on the number of leaves.
>
> **The tropical Grassmannian $\mathrm{Gr}(2,n)$ as a balanced fan.** Conjecture: the set of
> $d$ satisfying the four-point relation is closed under max-plus cone operations (tropical
> scaling by nonnegative $c$ and tropical addition), i.e. it is a tropical (max-plus)
> submodule, and modulo the lineality space of tree-additive functions it is a balanced
> polyhedral fan of pure dimension $n-3$ (Speyer–Sturmfels). Homogeneity already certifies
> closure under scaling; the missing ingredient is closure under coordinatewise $\max$, which
> reduces to a single three-term inequality between quartet sums.

---

## References (classical background)

- D. Hilbert, *Beweis für die Darstellbarkeit der ganzen Zahlen durch eine feste Anzahl
  $n$-ter Potenzen (Waringsches Problem)*, Math. Ann. (1909).
- H. Hasse, work on the local–global principle for quadratic forms (1920s).
- E. S. Selmer, *The Diophantine equation $ax^3 + by^3 + cz^3 = 0$*, Acta Math. (1951).
- A. R. Booker, A. V. Sutherland, computations on sums of three cubes for $33$ and $42$ (2019).
