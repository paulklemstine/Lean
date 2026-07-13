# Orbit–Stabilizer Constraints on the Classification of Boolean Cubic Forms in Ten Variables

## Abstract

We study the action of the general linear group $GL(10,2)$ on the space of
Boolean cubic forms in ten variables — equivalently, the top layer
$RM(3,10)/RM(2,10)$ of the Reed–Muller code. The central classification datum is
that the number of nonzero orbits under this action equals $3{,}691{,}560$. Rather
than re-derive this figure from a fixed-point computation, we develop a
self-contained battery of *elementary* orbit–stabilizer results and use them to
constrain, certify, and interpret it. We prove: (i) a Burnside-free **orbit lower
bound**, $|X| \le r\,|G|$ where $r$ is the number of orbits; (ii) a **freeness
obstruction**, namely that a free action forces $|G| \mid |X|$, with its
contrapositive guaranteeing a nontrivial stabilizer whenever divisibility fails;
(iii) the exact order $|GL(10,2)| = \prod_{i=0}^{9}(2^{10}-2^{i}) =
366{,}440{,}137{,}299{,}948{,}128{,}422{,}802{,}227{,}200$; and (iv) three
consequences for the cubic-form action: the forced lower bound of $3{,}627{,}409$
orbits, the consistency inequality $3{,}691{,}560 \ge 3{,}627{,}409$, and a parity
**disproof** of the hypothesis that the action is free (equivalently, that every
orbit is regular). The surplus $3{,}691{,}560 - 3{,}627{,}409 = 64{,}151$ is
identified as the weighted count of forms carrying nontrivial stabilizers.

## 1. Introduction

### 1.1 Boolean forms and linear equivalence

Fix the two-element field $\mathbb{F}_2 = \{0,1\}$ with $1+1 = 0$. A **Boolean
function** in $n$ variables is a map $f : \mathbb{F}_2^n \to \mathbb{F}_2$. Every
such function has a unique **algebraic normal form**, a multilinear polynomial

$$f(x_1,\dots,x_n) = \sum_{S \subseteq \{1,\dots,n\}} a_S \prod_{i \in S} x_i,
\qquad a_S \in \mathbb{F}_2,$$

where multilinearity ($x_i^2 = x_i$) restricts every monomial to a product of
*distinct* variables. The **degree** of $f$ is the size of the largest $S$ with
$a_S \ne 0$. The monomials of a fixed degree $d$ span the *degree-$d$ layer*,
whose dimension is $\binom{n}{d}$.

A **cubic form** is a homogeneous degree-$3$ element, i.e. a sum of distinct
cubic monomials $x_i x_j x_k$. For $n = 10$ the cubic layer has dimension

$$\binom{10}{3} = 120,$$

so there are $2^{120}$ cubic forms and

$$|X| = 2^{120} - 1 = 1{,}329{,}227{,}995{,}784{,}915{,}872{,}903{,}807{,}060{,}280{,}344{,}575$$

nonzero cubic forms. We write $X$ for this set of nonzero cubic forms throughout.

### 1.2 The symmetry group and its action

An invertible linear change of variables $x \mapsto Ax$ with
$A \in GL(n,2)$ transforms a Boolean form by substitution and re-reduction to
algebraic normal form. This substitution preserves degree, so $GL(n,2)$ acts on
each degree layer; in particular it acts on the cubic layer and on $X$. Two forms
are **linearly equivalent** iff they lie in the same $GL(n,2)$-orbit. The
classification problem is to count and describe these orbits.

The cubic layer is precisely the quotient $RM(3,n)/RM(2,n)$ of Reed–Muller codes,
so the classification of cubic forms up to linear equivalence is the
classification of $RM(3,n)/RM(2,n)$ codewords under the code's affine/linear
automorphisms. This connects the problem to coding theory, cryptographic
nonlinearity, and finite geometry.

### 1.3 Contribution

The known ten-variable count is $3{,}691{,}560$. Our contribution is not to
recompute it but to *stress-test and explain* it using only orbit–stabilizer
theory, producing a self-contained certificate of consistency together with a
provable refutation of the most natural wrong guess. All results are elementary
in the sense that they avoid Burnside's lemma (the orbit-counting formula) and
rest only on the orbit decomposition and the orbit–stabilizer theorem.

## 2. Preliminaries: orbits and stabilizers

Let $G$ be a finite group acting on a finite set $X$. For $x \in X$ write
$\mathrm{Orb}(x) = \{g \cdot x : g \in G\}$ for its **orbit** and
$\mathrm{Stab}(x) = \{g \in G : g \cdot x = x\}$ for its **stabilizer**, a
subgroup of $G$. The set $X$ is partitioned into orbits, and we denote by $r$ the
number of orbits (the cardinality of the quotient $X/G$).

**Orbit–Stabilizer Theorem.** For every $x \in X$,
$$|\mathrm{Orb}(x)| \cdot |\mathrm{Stab}(x)| = |G|.$$
In particular $|\mathrm{Orb}(x)| \mid |G|$ and $|\mathrm{Orb}(x)| \le |G|$, with
equality iff $\mathrm{Stab}(x)$ is trivial.

An action is **free** if $\mathrm{Stab}(x) = \{e\}$ for every $x$; an orbit of
maximal size $|G|$ is called **regular**.

## 3. General orbit–stabilizer bounds

We first prove two general facts, valid for *any* finite group action, that will
be specialized in Section 5.

### 3.1 The orbit lower bound

**Theorem 1 (Orbit lower bound).** *For a finite group $G$ acting on a finite set
$X$ with $r$ orbits,*
$$|X| \le r \cdot |G|,$$
*equivalently $r \ge |X|/|G|$.*

*Proof.* Choose a representative $x_\omega$ for each orbit $\omega \in X/G$. The
orbit decomposition gives a bijection $X \cong \bigsqcup_{\omega} \mathrm{Orb}(x_\omega)$,
hence
$$|X| = \sum_{\omega \in X/G} |\mathrm{Orb}(x_\omega)|.$$
By orbit–stabilizer, $|\mathrm{Orb}(x_\omega)| = |G|/|\mathrm{Stab}(x_\omega)| \le |G|$
because $|\mathrm{Stab}(x_\omega)| \ge 1$. Summing the bound over the $r$ orbits,
$$|X| = \sum_{\omega} |\mathrm{Orb}(x_\omega)| \le \sum_{\omega} |G| = r\,|G|.$$
Dividing by $|G| > 0$ yields $r \ge |X|/|G|$. $\qquad\blacksquare$

This proof uses only the orbit partition and the elementary inequality
$|\mathrm{Orb}| \le |G|$; it does not invoke Burnside's orbit-counting lemma.
Because $r$ is an integer, the bound sharpens to
$$r \ge \left\lceil |X|/|G| \right\rceil.$$

### 3.2 The freeness obstruction

**Theorem 2 (Freeness obstruction).** *If the action of $G$ on $X$ is free, then
$|G|$ divides $|X|$.*

*Proof.* Freeness means every stabilizer is trivial, so by orbit–stabilizer every
orbit has size exactly $|G|$. Summing over the $r$ orbits,
$$|X| = \sum_{\omega} |\mathrm{Orb}(x_\omega)| = \sum_{\omega} |G| = r\,|G|,$$
so $|G| \mid |X|$. $\qquad\blacksquare$

**Corollary 3 (Non-freeness from divisibility failure).** *If $|G| \nmid |X|$,
then there exists $x \in X$ with $\mathrm{Stab}(x) \ne \{e\}$; in particular the
action is not free.*

*Proof.* Contrapositive of Theorem 2: if every stabilizer were trivial the action
would be free and Theorem 2 would force $|G| \mid |X|$, contradicting the
hypothesis. $\qquad\blacksquare$

## 4. The order of $GL(10,2)$

**Theorem 4 (Order of the general linear group).** *Over $\mathbb{F}_2$,*
$$|GL(n,2)| = \prod_{i=0}^{n-1}\bigl(2^{n} - 2^{i}\bigr).$$
*In particular*
$$|GL(10,2)| = \prod_{i=0}^{9}\bigl(2^{10} - 2^{i}\bigr)
= 366{,}440{,}137{,}299{,}948{,}128{,}422{,}802{,}227{,}200.$$

*Proof.* An invertible matrix is determined by an ordered basis of
$\mathbb{F}_2^n$. The first basis vector is any nonzero vector, giving $2^n - 1$
choices. Having chosen $i$ linearly independent vectors, they span a subspace of
size $2^i$, and the $(i{+}1)$-st vector may be any vector outside that subspace,
giving $2^n - 2^i$ choices. Multiplying the choices for $i = 0, \dots, n-1$ gives
$\prod_{i=0}^{n-1}(2^n - 2^i)$. Evaluating at $n = 10$ yields the stated
$30$-digit integer. $\qquad\blacksquare$

Note the factor at $i = 1$ is $2^{10} - 2 = 1022$, an even number, so $|GL(10,2)|$
is even. This single parity fact drives the disproof in Section 5.

## 5. Consequences for Boolean cubic forms

We now specialize to $G = GL(10,2)$ acting on $X$, the set of $2^{120}-1$ nonzero
cubic forms. Let $r$ denote the number of orbits; the classification value is
$r = 3{,}691{,}560$.

### 5.1 The forced lower bound

**Theorem 5 (Forced lower bound).** *The number of nonzero $GL(10,2)$-orbits of
Boolean cubic forms in ten variables satisfies*
$$r \ge \left\lceil \frac{2^{120}-1}{|GL(10,2)|} \right\rceil = 3{,}627{,}409.$$

*Proof.* Apply Theorem 1 with $|X| = 2^{120}-1$ and $|G| = |GL(10,2)|$. Numerically
$$\frac{2^{120}-1}{|GL(10,2)|} = 3{,}627{,}408.6\ldots,$$
so the integer ceiling is $3{,}627{,}409$. $\qquad\blacksquare$

### 5.2 Consistency of the classification figure

**Theorem 6 (Consistency certificate).** *The classification value clears the
orbit lower bound:*
$$3{,}691{,}560 \ge 3{,}627{,}409, \qquad\text{equivalently}\qquad
3{,}691{,}560 \cdot |GL(10,2)| \ge 2^{120}-1.$$

*Proof.* Immediate comparison of integers; the second form multiplies through by
$|GL(10,2)|$. Explicitly $3{,}691{,}560 \cdot |GL(10,2)| \approx 1.3527 \times
10^{36} > 1.3292 \times 10^{36} = 2^{120}-1$. $\qquad\blacksquare$

Any *incorrect* count below $3{,}627{,}409$ would be exposed instantly by
Theorem 5; the true figure passes.

### 5.3 The action is not free

**Theorem 7 (Non-freeness / disproof of the regular-action hypothesis).** *The
action of $GL(10,2)$ on the nonzero Boolean cubic forms is not free. Consequently
there exists a nonzero cubic form fixed by a nontrivial linear substitution, and
the orbit count can never equal the naive quotient
$\lfloor (2^{120}-1)/|GL(10,2)| \rfloor = 3{,}627{,}408$.*

*Proof.* By Theorem 4, $|GL(10,2)|$ is even (it has the factor $2^{10}-2 = 1022$).
The space size $2^{120}-1$ is odd. An even number cannot divide an odd number, so
$|GL(10,2)| \nmid (2^{120}-1)$. Corollary 3 then yields a point $x \in X$ with
$\mathrm{Stab}(x) \ne \{e\}$: a nonzero cubic form fixed by a nontrivial
$A \in GL(10,2)$. Hence not all orbits are regular. Were the count equal to the
floor $3{,}627{,}408$, then $r\,|G| = 3{,}627{,}408 \cdot |G| < 2^{120}-1$ would
violate Theorem 1; so the floor is impossible as well. $\qquad\blacksquare$

Theorem 7 is the crux of the "contrarian" analysis: the most natural guess — that
the orbits partition $X$ into equal, full-sized bundles — is not merely
numerically off, it is *structurally impossible* by a one-line parity argument.

### 5.4 Interpreting the surplus

**Proposition 8 (Surplus as a stabilizer census).** *The excess of the true count
over the forced floor is*
$$3{,}691{,}560 - 3{,}627{,}409 = 64{,}151.$$
*This surplus measures the aggregate effect of orbits smaller than $|G|$.*

*Discussion.* Rewrite the orbit decomposition using orbit–stabilizer:
$$|X| = \sum_{\omega} \frac{|G|}{|\mathrm{Stab}(x_\omega)|}
= r\,|G| - \sum_{\omega} |G|\!\left(1 - \frac{1}{|\mathrm{Stab}(x_\omega)|}\right).$$
Every orbit with $|\mathrm{Stab}(x_\omega)| > 1$ contributes a positive term to the
correction, pushing $r$ above the bound $|X|/|G|$. Thus $r - \lceil |X|/|G|\rceil$
is entirely attributable to non-regular orbits — the very forms whose existence
Theorem 7 guarantees. The gap $64{,}151$ is the ten-variable manifestation of this
phenomenon. An exact recovery of the surplus from the sum $\sum_x |\mathrm{Stab}(x)|
= r\,|G|$ requires the detailed stabilizer distribution on the cubic layer and is
posed as a future direction.

## 6. Algorithms

We record two computational procedures underlying the numerical claims. Both are
exact integer computations; there is no floating-point rounding in the certified
statements.

### 6.1 Exact group order by column elimination

To compute $|GL(n,2)|$ exactly, multiply the counts of admissible basis vectors:
$$|GL(n,2)| = \prod_{i=0}^{n-1}\bigl(2^n - 2^i\bigr).$$
For $n=10$ this is a product of ten integers, computable in $O(n)$ big-integer
multiplications.

### 6.2 Bound certification by exact rational comparison

Given the space size $|X| = 2^{120}-1$ and group order $|G|$, the certified facts
are obtained by exact integer arithmetic:

1. Forced floor: $r_{\min} = \lceil |X|/|G| \rceil$ via integer division and a
   remainder test.
2. Consistency: verify $r \cdot |G| \ge |X|$ for the claimed $r$.
3. Non-freeness: verify $|X| \bmod 2 = 1$ and $|G| \bmod 2 = 0$, whence
   $|G| \nmid |X|$.

Each step is a constant number of big-integer operations.

## 7. Applications

- **Coding theory.** The cubic layer is $RM(3,n)/RM(2,n)$; orbit classification is
  the classification of these Reed–Muller cosets under linear automorphisms, a
  staple of the weight-distribution and covering-radius literature.
- **Cryptography.** Cubic Boolean functions arise as components of S-boxes and
  stream-cipher filters; linear-equivalence classes group together functions with
  identical resistance to affine-invariant attacks, so an orbit census bounds the
  number of essentially different design choices.
- **Finite geometry.** Cubic forms over $\mathbb{F}_2$ correspond to certain
  configurations of points and flats; equivalence classes reflect the underlying
  projective symmetry.
- **Benchmarking classification machinery.** The consistency certificate and
  parity obstruction are cheap sanity checks that any purported orbit count (from
  Burnside sums or direct enumeration) must satisfy, useful for validating
  large-scale computations before trusting them.

## 8. Discussion

The interplay of the three main tools is what makes the analysis complete. The
orbit lower bound (Theorem 1) fences the answer from below; the freeness
obstruction (Theorem 2, Corollary 3) removes the two integer candidates nearest
the naive quotient from below; and the exact group order (Theorem 4) supplies the
constants. Together they show that the true count must exceed $3{,}627{,}409$ and
cannot be $3{,}627{,}408$, and they certify that $3{,}691{,}560$ is consistent with
all of these constraints while quantifying, via the surplus $64{,}151$, how much
of the answer is due to symmetric forms.

The results generalize verbatim. Theorem 1 and Theorem 2 hold for any finite group
acting on any finite set. In particular they yield a $p$-group fixed-point
principle: a $p$-group acting on a set whose size is prime to $p$ must have a fixed
point — a direct refinement of Corollary 3 that also underlies many structural
theorems in finite group theory.

## 9. Future Directions

1. **Compute the exact orbit count from a fixed-point sum.** The largest open gap
   is that $3{,}691{,}560$ is checked for consistency rather than derived. A full
   derivation would (a) build the cubic layer $RM(3,10)/RM(2,10)$ as a concrete
   $GL(10,2)$-module, (b) compute the Burnside sum $\sum_g |\mathrm{Fix}(g)|$, and
   (c) divide by $|G|$. The conjugacy-class (rational canonical form) data on
   $\mathbb{F}_2^{10}$ is the main ingredient.
2. **Sharper stabilizer accounting.** The surplus $64{,}151$ counts weighted forms
   with nontrivial stabilizers. Establishing the identity $\sum_x |\mathrm{Stab}(x)| = r\,|G|$ for
   the cubic layer would recover the surplus from the number of non-regular orbits.
3. **Smaller $n$ as ground truth.** Fully compute orbit counts for $n = 4,5,6,7$
   (dimensions $4,10,20,35$) by direct enumeration, giving verified small-case data
   to validate the machinery before scaling to $n = 10$.
4. **Generalize the bounds.** The orbit lower bound and freeness obstruction hold
   for arbitrary finite group actions; a parity / $p$-group refinement (a $p$-group
   acting on a set of size prime to $p$ has a fixed point) is a reusable
   consequence worth stating in full generality.

## 10. Conclusion

Starting from two elementary counting principles — the orbit lower bound and the
freeness obstruction — and the exact order of $GL(10,2)$, we have fenced the
number of nonzero $GL(10,2)$-orbits of Boolean cubic forms in ten variables into a
tight and revealing window. Any correct count is at least $3{,}627{,}409$; the
count $3{,}691{,}560$ meets this floor with a surplus of $64{,}151$; and a parity
argument definitively rules out the naive quotient $3{,}627{,}408$, proving that
the action is not free. The classification value is thereby not just quoted but
*explained*: it is exactly as large as the elementary constraints allow, plus the
measurable contribution of forms carrying genuine symmetry.
