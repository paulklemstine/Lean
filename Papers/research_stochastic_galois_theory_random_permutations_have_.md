# Stochastic Galois Theory over Finite Fields: Exact Factorization Statistics and a Cyclic Obstruction

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

Over the rational numbers, a classical principle (the probabilistic form of
Hilbert's irreducibility theorem) states that a "random" polynomial of degree $n$
has Galois group equal to the full symmetric group $S_n$. It is natural to
conjecture an analogous statement over finite fields: that for a uniformly random
monic polynomial $f \in \mathbb{F}_q[x]$ of fixed degree $n$, the Galois group is
$S_n$ with probability tending to $1$ as $q \to \infty$. We show this conjecture
is **false at the group-theoretic level**. The absolute Galois group of a finite
field is procyclic, so every Galois group arising over a finite field is cyclic,
hence abelian; since $S_n$ is non-abelian for $n \ge 3$, no polynomial over a
finite field has Galois group $S_n$ when $n \ge 3$. The probability is exactly
$0$, not asymptotically $1$.

What survives, and what is the correct analogue, is the statistics of the
**Frobenius cycle type** — equivalently, the factorization type of the polynomial.
We establish two exact instances of this corrected picture. First, an
**expected-roots identity**: summed over all $q^n$ monic degree-$n$ polynomials,
the total number of roots in $\mathbb{F}_q$ (indeed over any finite commutative
ring of cardinality $q$) is exactly $q^n$, so the expected number of roots of a
random monic polynomial is exactly $1$ — mirroring the fact that a uniform
permutation in $S_n$ has on average exactly one fixed point. Second, a complete
**degree-two census**: over $\mathbb{F}_q$ with $q$ odd, exactly $q$ monic
quadratics have a repeated root, exactly $q(q+1)/2$ are reducible, and exactly
$q(q-1)/2$ are irreducible, so the proportion irreducible tends to $1/2$, matching
the fraction of transpositions in $S_2$. All results are proved by elementary
double-counting and completing the square.

## 1. Introduction

### 1.1 The classical picture over $\mathbb{Q}$

Let $f \in \mathbb{Q}[x]$ be a separable polynomial of degree $n$ with splitting
field $L$. The Galois group $\mathrm{Gal}(L/\mathbb{Q})$ acts faithfully on the
$n$ roots of $f$, embedding it as a subgroup of the symmetric group $S_n$. A
guiding theme of arithmetic statistics is that this subgroup is *generically* all
of $S_n$: in precise density statements (van der Waerden's theorem and its
refinements, ultimately resting on Hilbert's irreducibility theorem), the
proportion of degree-$n$ integer polynomials with coefficients bounded by $H$ whose
Galois group is a proper subgroup of $S_n$ tends to $0$ as $H \to \infty$.
Informally: **a random polynomial over $\mathbb{Q}$ has maximal Galois group.**

### 1.2 The tempting — but false — finite-field analogue

It is natural to ask for the finite-field version. Fix $n$ and let $f$ range
uniformly over monic degree-$n$ polynomials in $\mathbb{F}_q[x]$. Does
$\mathrm{Gal}(f) = S_n$ with probability approaching $1$ as $q \to \infty$? One
might even conjecture a rate, e.g. $\mathbb{P}(\mathrm{Gal}(f) \ne S_n) =
c_n/\sqrt{q} + O(1/q)$.

This paper's first contribution is to observe that the conjecture is false, and
not merely quantitatively: the probability is identically $0$ for all $n \ge 3$
and all $q$. The obstruction is structural and is the content of Section 3.

### 1.3 The correct analogue: Frobenius cycle statistics

The salvageable content of the "random polynomial $\approx$ random permutation"
heuristic is *not* about the isomorphism type of the Galois group but about the
**cycle type of the Frobenius automorphism** acting on the roots. For a squarefree
$f \in \mathbb{F}_q[x]$, the $q$-power Frobenius permutes the roots of $f$ in its
splitting field, and its cycle lengths are exactly the degrees of the irreducible
factors of $f$. The correct theorem — a finite-field manifestation of a general
equidistribution principle — is that as $q \to \infty$, the factorization type of a
random monic degree-$n$ polynomial converges in distribution to the cycle type of a
uniformly random element of $S_n$.

Sections 4 and 5 establish two exact, unconditional instances of this principle:
the expected number of linear factors (fixed points) in every degree, and the
complete distribution of factorization types in degree $2$.

## 2. Definitions and setup

Throughout, $K$ denotes a finite commutative ring with $q := |K|$ elements;
in Sections 3 and 5 we specialize to a finite field, and in Section 5 we further
assume odd characteristic.

**Definition 2.1 (Monic encoding).** A monic polynomial of degree $n \ge 1$ over
$K$,
$$ f(x) = x^n + \sum_{i=0}^{n-1} v_i\, x^i, $$
is encoded by its coefficient vector $v = (v_0, \dots, v_{n-1}) \in K^n$. There are
exactly $q^n$ such polynomials. We write its evaluation as
$$ \mathrm{ev}_n(v, r) := r^n + \sum_{i=0}^{n-1} v_i\, r^i. $$

**Definition 2.2 (Root set and root count).** For a monic $f$ encoded by $v$, its
set of roots in $K$ is $\{ r \in K : \mathrm{ev}_n(v,r) = 0 \}$, a finite set. In
degree $2$, writing $f = x^2 + bx + c$ encoded by $(b,c) \in K^2$, we write
$$ \mathrm{nroots}(b,c) := \#\{ r \in K : r^2 + b r + c = 0 \}. $$

**Definition 2.3 (Frobenius cycle type / factorization type).** For squarefree
$f \in \mathbb{F}_q[x]$ of degree $n$ with distinct irreducible factors of degrees
$d_1, \dots, d_k$ (so $\sum d_j = n$), the *factorization type* of $f$ is the
partition $(d_1, \dots, d_k)$ of $n$. The $q$-power Frobenius acts on the $n$ roots
of $f$ as a permutation whose cycle type is exactly $(d_1, \dots, d_k)$. Roots in
$\mathbb{F}_q$ (i.e., linear factors $x - r$) correspond to fixed points ($1$-cycles);
irreducible quadratic factors correspond to $2$-cycles; and so on.

## 3. The cyclic obstruction: correcting the conjecture

**Theorem 3.1 (Finite-field Galois groups are never $S_n$ for $n \ge 3$).**
Let $L/K$ be an extension of fields with $L$ finite, and let $n \ge 3$. Then there
is no group isomorphism between the automorphism group $\mathrm{Aut}(L/K)$ (the
Galois group when $L/K$ is Galois) and the symmetric group $S_n$. Equivalently, the
set of isomorphisms $\mathrm{Gal}(L/K) \cong S_n$ is empty.

*Proof.* Two ingredients.

*(i) Finite-field Galois groups are cyclic.* If $L$ is a finite field, then $L/K$
is a Galois extension of finite fields and $\mathrm{Gal}(L/K)$ is generated by the
relative Frobenius automorphism $x \mapsto x^{|K|}$. Hence $\mathrm{Gal}(L/K)$ is
cyclic, therefore abelian.

*(ii) $S_n$ is non-abelian for $n \ge 3$.* The transpositions $(1\ 2)$ and
$(2\ 3)$ do not commute: applying $(1\ 2)$ then $(2\ 3)$ sends $1 \mapsto 3$,
whereas applying them in the other order sends $1 \mapsto 2$. Thus $S_n$ contains
two elements that fail to commute.

Now suppose there were an isomorphism $\varphi : \mathrm{Gal}(L/K) \to S_n$. A
group isomorphic to a cyclic group is cyclic, so $S_n$ would be cyclic; but a
cyclic group is abelian, contradicting (ii). Hence no such isomorphism exists. In
particular the case $n = 3$ shows no finite-field extension has Galois group
$S_3$. $\qquad\blacksquare$

**Corollary 3.2 (The conjecture fails identically).** For every fixed $n \ge 3$
and every prime power $q$,
$$ \mathbb{P}_{f\ \text{monic},\ \deg f = n}\big(\mathrm{Gal}(f) \cong S_n\big) = 0. $$
This is not an asymptotic statement: the probability is exactly $0$, contradicting
any conjecture of the form $\mathbb{P}(\mathrm{Gal}(f) \ne S_n) \to 0$.

**Remark 3.3.** The contrast with $\mathbb{Q}$ is stark and instructive. Over
$\mathbb{Q}$, the absolute Galois group is enormously non-abelian and generic
polynomials realize the maximal group $S_n$. Over $\mathbb{F}_q$, the absolute
Galois group $\widehat{\mathbb{Z}}$ is procyclic, so *every* Galois group is a
finite cyclic quotient. The abundance of symmetry over $\mathbb{Q}$ becomes a
severe constraint over $\mathbb{F}_q$. Thus the finite-field theory is governed not
by which group appears (always cyclic) but by the *permutation representation* of
Frobenius on the roots — its cycle type — which is the subject of the rest of the
paper.

## 4. The expected-roots identity in every degree

We now establish the cleanest universally-true instance of the random-permutation
dictionary: the expected number of roots (fixed points of Frobenius) is exactly
$1$, in every degree, over any finite commutative ring.

**Lemma 4.1 (Fiber count).** Let $K$ be a finite commutative ring with $q = |K|$,
and fix a base point $r \in K$ and a degree $m + 1 \ge 1$. The number of monic
polynomials of degree $m+1$ having $r$ as a root equals $q^m$:
$$ \#\{ v \in K^{m+1} : \mathrm{ev}_{m+1}(v, r) = 0 \} = q^m. $$

*Proof.* The condition $\mathrm{ev}_{m+1}(v,r) = 0$ reads
$$ v_0 = -\Big( r^{m+1} + \sum_{i=1}^{m} v_i\, r^i \Big). $$
For any choice of the $m$ coefficients $(v_1, \dots, v_m) \in K^m$, the constant
coefficient $v_0$ is uniquely determined. Hence the solution set is the graph of a
function $K^m \to K$, and its cardinality is $|K^m| = q^m$. $\qquad\blacksquare$

**Theorem 4.2 (Expected-roots identity).** Let $K$ be a finite commutative ring
with $q = |K|$, and let $n \ge 1$. Then
$$ \sum_{v \in K^n} \#\{ r \in K : \mathrm{ev}_n(v,r) = 0 \} = q^n. $$
Equivalently, the expected number of roots of a uniformly random monic degree-$n$
polynomial over $K$ is exactly
$$ \frac{1}{q^n} \sum_{v \in K^n} \#\{ r : \mathrm{ev}_n(v,r) = 0 \} = 1. $$

*Proof.* Write $n = m + 1$. The left-hand side counts incidences — pairs
$(v, r)$ with $\mathrm{ev}_n(v,r) = 0$ — by first summing over polynomials $v$ and
then over roots $r$. Exchange the order of summation, grouping by the base point
$r$ instead:
$$ \sum_{v \in K^n} \#\{ r : \mathrm{ev}_n(v,r)=0 \}
   = \sum_{r \in K} \#\{ v : \mathrm{ev}_n(v,r) = 0 \}. $$
By Lemma 4.1 each inner term equals $q^m$, and there are $q$ base points, so the
total is $q \cdot q^m = q^{m+1} = q^n$. Dividing by the number $q^n$ of
polynomials gives the expected value $1$. $\qquad\blacksquare$

**Corollary 4.3 (Prime-field form).** For a prime $p$ and $n \ge 1$,
$$ \sum_{v \in \mathbb{F}_p^{\,n}} \#\{ r \in \mathbb{F}_p : \mathrm{ev}_n(v,r) = 0 \} = p^n. $$

**Interpretation.** Linear factors $x - r$ are exactly the fixed points of the
Frobenius permutation on the roots. Theorem 4.2 says the average number of fixed
points is exactly $1$ — precisely the average number of fixed points of a uniformly
random permutation in $S_n$ (the "hat-check" constant, independent of $n$). This is
the first exact rung of the equidistribution ladder.

## 5. The complete degree-two census

We now compute the *entire* distribution of factorization types in degree $2$,
not merely the mean. Fix a finite field $K$ of odd characteristic, $q = |K|$.
There are $q^2$ monic quadratics $x^2 + bx + c$, encoded by $(b,c) \in K^2$.

**Lemma 5.1 (Roots via the discriminant).** For $b, c \in K$ with
$\mathrm{char}(K) \ne 2$,
$$ \mathrm{nroots}(b,c) = \#\{ y \in K : y^2 = b^2 - 4c \}. $$

*Proof.* Completing the square, $r^2 + br + c = 0 \iff (2r + b)^2 = b^2 - 4c$.
Since $2 \ne 0$ in $K$, the map $r \mapsto 2r + b$ is a bijection of $K$, and it
carries the root set of the quadratic bijectively onto the set of square roots of
the discriminant $b^2 - 4c$. Hence the two counts agree. $\qquad\blacksquare$

**Lemma 5.2 (Square-root counts).** In a field $K$ with $\mathrm{char}(K) \ne 2$,
for any $a \in K$:
(a) $\#\{ y : y^2 = a \} \le 2$; and
(b) $\#\{ y : y^2 = a \} = 1 \iff a = 0$.

*Proof.* (a) If $y_0^2 = a$ then $y^2 = a \iff y^2 = y_0^2 \iff y \in \{y_0,
-y_0\}$, a set of size at most $2$; if no square root exists the count is $0$.
(b) If the unique square root is $y$, then $-y$ is also a square root, so $y = -y$,
i.e. $2y = 0$, i.e. $y = 0$ (as $2 \ne 0$), whence $a = y^2 = 0$. Conversely if
$a = 0$ then $y^2 = 0 \iff y = 0$, a single solution. $\qquad\blacksquare$

**Corollary 5.3.** A monic quadratic over $K$ ($\mathrm{char} \ne 2$) has at most
two roots: $\mathrm{nroots}(b,c) \le 2$.

**Lemma 5.4 (Total incidences).** Summed over all $q^2$ monic quadratics,
$$ \sum_{(b,c) \in K^2} \mathrm{nroots}(b,c) = q^2. $$

*Proof.* This is the degree-$2$ case of Theorem 4.2, but we give the direct
argument. Exchange the order of summation to count incidences by base point:
$$ \sum_{(b,c)} \mathrm{nroots}(b,c)
 = \sum_{r \in K} \#\{ (b,c) : r^2 + br + c = 0 \}. $$
For fixed $r$, the condition determines $c = -(r^2 + br)$ uniquely for each $b$, so
the inner count is $q$; summing over the $q$ values of $r$ gives $q^2$.
$\qquad\blacksquare$

**Theorem 5.5 (Degree-two census).** Let $K$ be a finite field with $q = |K|$ odd.
Among the $q^2$ monic quadratics over $K$:

1. **Repeated root (discriminant zero):** exactly $q$ satisfy
   $\mathrm{nroots}(b,c) = 1$; these are the perfect squares $(x - r)^2$.
2. **Reducible (split into two linear factors):**
   $$ 2 \cdot \#\{ (b,c) : \exists\, r,\ r^2 + br + c = 0 \} = q(q+1), $$
   i.e. exactly $\tfrac{q(q+1)}{2}$ monic quadratics have a root in $K$.
3. **Irreducible (no root in $K$):**
   $$ 2 \cdot \#\{ (b,c) : \nexists\, r,\ r^2 + br + c = 0 \} = q(q-1), $$
   i.e. exactly $\tfrac{q(q-1)}{2}$ monic quadratics are irreducible.

*Proof.* Let $n_0, n_1, n_2$ be the number of monic quadratics with exactly
$0, 1, 2$ roots respectively. By Corollary 5.3 every quadratic falls into exactly
one class, so
$$ n_0 + n_1 + n_2 = q^2. \tag{I}$$
Counting incidences by multiplicity, $\sum_{(b,c)} \mathrm{nroots}(b,c) = n_1 +
2 n_2$, which equals $q^2$ by Lemma 5.4:
$$ n_1 + 2 n_2 = q^2. \tag{II}$$

For claim 1, by Lemma 5.1 and Lemma 5.2(b), $\mathrm{nroots}(b,c) = 1$ iff the
discriminant $b^2 - 4c = 0$, i.e. $c = b^2/4$. Since $4 \ne 0$ (as $2 \ne 0$),
this parametrizes exactly one $c$ for each of the $q$ values of $b$, giving
$$ n_1 = q. \tag{III}$$
Subtracting (I) from (II) gives $n_2 - n_0 = 0$... more directly, from (II) and
(III), $2 n_2 = q^2 - q$, so $n_2 = \tfrac{q(q-1)}{2}$, and from (I), $n_0 = q^2 -
n_1 - n_2 = q^2 - q - \tfrac{q(q-1)}{2} = \tfrac{q(q-1)}{2}$.

The reducible quadratics are those with at least one root, numbering
$n_1 + n_2 = q + \tfrac{q(q-1)}{2} = \tfrac{q(q+1)}{2}$, which doubles to
$q(q+1)$, proving claim 2. The irreducible quadratics number
$n_0 = \tfrac{q(q-1)}{2}$, doubling to $q(q-1)$, proving claim 3. $\qquad\blacksquare$

**Corollary 5.6 (Prime-field form).** For an odd prime $p$,
$$ 2 \cdot \#\{ (b,c) \in \mathbb{F}_p^2 : x^2 + bx + c \text{ has no root in } \mathbb{F}_p \} = p(p-1). $$

**Corollary 5.7 (Limiting proportions).** As $q \to \infty$ through odd prime
powers, the proportions of the $q^2$ monic quadratics behave as follows:
$$ \frac{\#\{\text{repeated root}\}}{q^2} = \frac{1}{q} \to 0, \qquad
   \frac{\#\{\text{irreducible}\}}{q^2} = \frac{q-1}{2q} \to \frac{1}{2}, \qquad
   \frac{\#\{\text{reducible}\}}{q^2} = \frac{q+1}{2q} \to \frac{1}{2}. $$

**Interpretation via $S_2$.** A uniform random permutation of two objects is the
identity with probability $1/2$ and the transposition with probability $1/2$. Under
the Frobenius dictionary, the identity corresponds to a quadratic splitting into
two distinct linear factors (two fixed points), and the transposition to an
irreducible quadratic (a single $2$-cycle). Corollary 5.7 confirms that the
factorization type of a random quadratic converges to the cycle type of a uniform
element of $S_2$, with the "degenerate" repeated-root case (a non-squarefree
polynomial, outside the permutation model) having vanishing density $1/q$.

## 6. The corrected picture and the equidistribution principle

Combining Sections 3–5 yields a coherent revision of the opening conjecture.

- **Group-theoretically:** the Galois group of any polynomial over $\mathbb{F}_q$
  is cyclic (Theorem 3.1). It is *never* $S_n$ for $n \ge 3$, so $\mathbb{P}(\mathrm{Gal}
  = S_n) = 0$, not $\to 1$ (Corollary 3.2). The maximal-group heuristic transplanted
  from $\mathbb{Q}$ simply does not hold.

- **Statistically:** the honest analogue is Frobenius equidistribution. The
  factorization type of a random monic degree-$n$ polynomial over $\mathbb{F}_q$
  converges, as $q \to \infty$, to the cycle type of a uniform random permutation in
  $S_n$. Theorem 4.2 (fixed points $\leftrightarrow$ linear factors, mean exactly
  $1$ in all degrees) and Theorem 5.5 (the full degree-$2$ law) are the two cleanest
  exact instances.

The general equidistribution statement is a finite-field cousin of deep
results relating factorization statistics to the symmetric group; the exact,
elementary theorems proved here anchor that heuristic to firm ground in the two
most transparent cases.

## 7. Algorithms

The results are constructive and lend themselves to direct verification and use.

**Algorithm 7.1 (Root counting by evaluation).** Given a monic polynomial over
$\mathbb{F}_q$ by its coefficient vector, count its roots in $\mathbb{F}_q$ by
evaluating at all $q$ field elements. Complexity $O(q \cdot n)$ field operations.
Used to verify the expected-roots identity by brute-force enumeration.

**Algorithm 7.2 (Quadratic classification via discriminant).** Given $(b,c)$ over
$\mathbb{F}_q$ ($q$ odd), compute $\Delta = b^2 - 4c$ and classify: repeated root
if $\Delta = 0$; reducible with two roots if $\Delta$ is a nonzero square;
irreducible if $\Delta$ is a non-square. Determining squareness costs one Euler
criterion exponentiation $\Delta^{(q-1)/2}$, i.e. $O(\log q)$ multiplications.

**Algorithm 7.3 (Frobenius factorization-type sampler).** For general degree,
compute the distribution of factorization types by distinct-degree factorization:
$\gcd(f, x^{q^d} - x)$ isolates the product of irreducible factors of degree $d$.
Tabulating the resulting partition of $n$ over many random $f$ empirically confirms
convergence to the $S_n$ cycle-type distribution.

## 8. Applications

- **Algorithm analysis.** Exact factorization statistics quantify the expected
  behaviour of polynomial factorization, root-finding, and irreducibility testing
  on random inputs over finite fields — directly relevant to the running time of
  routines central to computer algebra.

- **Cryptography and coding.** Constructions that require an irreducible polynomial
  (e.g., defining an extension field) succeed on a random monic quadratic with
  probability $\tfrac{q-1}{2q} \approx \tfrac12$; more generally the density of
  irreducibles of degree $n$ is $\approx 1/n$, matching the fraction of $n$-cycles
  in $S_n$. These densities inform the expected number of trials in
  "generate-and-test" schemes.

- **Conceptual hygiene.** The cyclic obstruction is a cautionary example against
  transplanting heuristics across arithmetic settings without checking structural
  constraints.

## 9. Discussion and future work

The main methodological lesson is that a plausible cross-setting analogy — "random
polynomials have maximal Galois group" — can be simultaneously false in its literal
form and correct in a reformulated one. The reformulation (Frobenius cycle
statistics) is both true and more informative.

**Future directions.**

1. **Degree-three full distribution.** Prove exact counts for monic cubics over
   $\mathbb{F}_q$: the number of irreducibles (target density $\to 1/3$, matching
   $3$-cycles in $S_3$), the number splitting completely, the number with exactly
   one root, and the discriminant-zero locus. This is the natural next rung.

2. **General degree $n$ via inclusion–exclusion.** Establish the exact count of
   monic irreducibles of degree $n$ (the necklace/Möbius formula
   $\tfrac1n \sum_{d \mid n} \mu(d) q^{n/d}$) and, more finely, the exact number of
   polynomials of each factorization type, proving convergence to the $S_n$
   cycle-type law with explicit error terms $O(1/q)$.

3. **Quantitative equidistribution.** Make the convergence rate explicit: bound the
   total-variation distance between the factorization-type distribution and the
   uniform $S_n$ cycle-type distribution by $O_n(1/q)$.

4. **Beyond monic / beyond prime fields.** Extend the exact statistics to
   non-monic families, to reducible-allowed weightings, and to statistics over
   $\mathbb{F}_q$ for prime-power $q$ uniformly in both $q$ and $n$.

## 10. Conclusion

Over finite fields the slogan "random polynomials have Galois group $S_n$" is false:
finite-field Galois groups are cyclic and hence never $S_n$ for $n \ge 3$. The
correct and fruitful analogue is the equidistribution of Frobenius cycle types
toward random-permutation cycle types. We proved two exact instances anchoring this
principle: the expected number of roots is exactly $1$ in every degree over any
finite commutative ring, and the complete degree-two census gives $q$ repeated-root,
$q(q+1)/2$ reducible, and $q(q-1)/2$ irreducible monic quadratics, so the proportion
irreducible tends to $1/2$. Randomness over finite fields is not maximally complex
in the group sense but maximally generic in the statistical sense.
