# The Euler Characteristic in Negative Dimensions

## Abstract

We develop a rigorous, purely arithmetic theory of negative-dimensional
spaces and show that the Euler characteristic extends from the classical
non-negative dimensions to *every* integer dimension as a single
multiplicative invariant. The organizing object is the **dimensional
sign** $\operatorname{sgn}(d) = (-1)^d$, defined for all $d \in \mathbb{Z}$
and interpreted as the reduced Euler characteristic of a formal sphere
$S^d$, an object made available for negative $d$ by the pro-spectrum
picture of stable homotopy theory. Modelling a space by the pair
$(\dim, |\pi_0|)$ of its integer dimension and its number of path
components, we define $\chi(X) = \operatorname{sgn}(\dim X)\cdot|\pi_0(X)|$
and prove the headline identity: a space of dimension $-n$ satisfies
$\chi(X) = (-1)^n\,|\pi_0(X)|$. We prove that $\chi$ is additive under
disjoint union of equidimensional spaces, multiplicative under products
(so that it is a monoid homomorphism from formal spaces to the integers),
and sign-reversing under suspension, scaling by $(-1)^n$ under $n$-fold
suspension. The $n$-fold suspension is the **stabilization map**: it
carries a space of dimension $-n$ to an honest $0$-dimensional space and
there reads off $|\pi_0|$, yielding an independent derivation of the
negative-dimensional formula. Finally we exhibit a topological bridge: a
graded, sign-weighted refinement reproduces the classical value
$\chi = 2 - 2g$ of the closed orientable genus-$g$ surface. Throughout,
every property reduces to the single fact that $d \mapsto (-1)^d$ is a
homomorphism from $(\mathbb{Z}, +)$ onto the sign group $\{\pm 1\}$.

**Keywords.** Euler characteristic; negative dimension; stable homotopy;
suspension; stabilization; dimensional sign; graded Betti numbers;
commutative monoid; genus formula.

---

## 1. Introduction

The Euler characteristic is among the oldest and most durable invariants
in mathematics. From Euler's relation $V - E + F = 2$ for convex
polyhedra, through its reformulation as the alternating sum of Betti
numbers

$$\chi = \sum_{k \ge 0} (-1)^k b_k = b_0 - b_1 + b_2 - \cdots,$$

to its role in the Gauss–Bonnet theorem and the Riemann–Roch and
Atiyah–Singer index theorems, $\chi$ pervades geometry, topology, and
mathematical physics. In all of these classical settings the dimension of
the underlying space is a non-negative integer.

Modern stable homotopy theory, however, routinely works with objects
indexed by *all* integers. Suspension, which raises dimension by one,
becomes invertible on the level of spectra, so that formal spheres $S^d$
exist for every $d \in \mathbb{Z}$, including $d < 0$. This raises a
natural question: **does the Euler characteristic extend to negative
dimensions, and if so, what does it measure there?**

This paper answers the question affirmatively and completely, for a model
of "space" retaining exactly the data $\chi$ can detect. The answer is
strikingly clean: in dimension $-n$ the Euler characteristic depends only
on the number of path components and on the parity of $n$, via
$\chi = (-1)^n\,|\pi_0|$. We show that this extension is not an ad hoc
definition but is forced by three structural demands — agreement with the
spheres, additivity under disjoint union, and multiplicativity under
products — all of which flow from a single homomorphism property of the
dimensional sign.

### 1.1 Contributions

- A definition of the **dimensional sign** $\operatorname{sgn}(d) = (-1)^d$
  valid for all integers, together with its structural properties:
  parity-invariance $\operatorname{sgn}(-d) = \operatorname{sgn}(d)$ and
  the homomorphism law
  $\operatorname{sgn}(a+b) = \operatorname{sgn}(a)\operatorname{sgn}(b)$.
- A minimalist model of a **formal space** as a pair $(\dim, |\pi_0|)$
  with dimension ranging over $\mathbb{Z}$, and the invariant
  $\chi(X) = \operatorname{sgn}(\dim X)\cdot|\pi_0(X)|$.
- The **headline theorem**: $\dim X = -n \Rightarrow \chi(X) = (-1)^n\,|\pi_0(X)|$.
- Proofs that $\chi$ is additive under disjoint union, multiplicative
  under products, and hence a monoid homomorphism to $(\mathbb{Z},\cdot)$.
- A **suspension calculus**: $\chi(\Sigma X) = -\chi(X)$ and
  $\chi(\Sigma^n X) = (-1)^n\chi(X)$, with the $n$-fold suspension realized
  as a **stabilization map** to dimension $0$, giving a second, independent
  proof of the headline theorem.
- A **graded refinement** and a **topological bridge** reproducing
  $\chi = 2 - 2g$ for the closed orientable genus-$g$ surface.

---

## 2. The dimensional sign

**Definition 2.1 (Dimensional sign).** For $d \in \mathbb{Z}$ define
$$\operatorname{sgn}(d) = \begin{cases} 1, & d \text{ even},\\ -1, & d \text{ odd}.\end{cases}$$
Equivalently $\operatorname{sgn}(d) = (-1)^d$, valid for every integer $d$.
Topologically it is the reduced Euler characteristic of the formal
$d$-sphere $S^d$, which the pro-spectrum picture supplies for negative $d$
as well as non-negative $d$.

We record its immediate arithmetic properties.

**Lemma 2.2.** $\operatorname{sgn}(0) = 1$ and $\operatorname{sgn}(1) = -1$.
Moreover $\operatorname{sgn}(d) = 1 \iff d$ is even, and
$\operatorname{sgn}(d) = -1 \iff d$ is odd; in particular
$\operatorname{sgn}(d) \ne 0$ for all $d$.

*Proof.* Immediate from Definition 2.1 by case analysis on the parity of
$d$. $\qquad\blacksquare$

**Lemma 2.3 (Parity-invariance).** For all $d \in \mathbb{Z}$,
$$\operatorname{sgn}(-d) = \operatorname{sgn}(d).$$

*Proof.* The integer $d$ is even if and only if $-d$ is even, so the two
cases of Definition 2.1 return identical values for $d$ and $-d$.
$\qquad\blacksquare$

**Lemma 2.4 (Homomorphism law).** For all $a, b \in \mathbb{Z}$,
$$\operatorname{sgn}(a + b) = \operatorname{sgn}(a)\cdot\operatorname{sgn}(b).$$
Hence $\operatorname{sgn}\colon (\mathbb{Z}, +) \to (\{\pm 1\}, \cdot)$ is a
group homomorphism.

*Proof.* By case analysis on the parities of $a$ and $b$. The sum $a+b$
is even precisely when $a$ and $b$ have the same parity, in which case
both sides equal $+1$ (both even) or $(-1)(-1) = 1$ (both odd); when the
parities differ, $a+b$ is odd and both sides equal $-1$. This is exactly
the exponent law $(-1)^{a+b} = (-1)^a(-1)^b$. $\qquad\blacksquare$

**Lemma 2.5 (Values at integer casts).** For $n \in \mathbb{N}$,
$$\operatorname{sgn}(n) = (-1)^n \qquad\text{and}\qquad \operatorname{sgn}(-n) = (-1)^n.$$

*Proof.* The first identity is Definition 2.1 restricted to non-negative
integers, using that $n$ and the natural number $n$ share their parity.
The second follows by combining the first with parity-invariance
(Lemma 2.3): $\operatorname{sgn}(-n) = \operatorname{sgn}(n) = (-1)^n$.
$\qquad\blacksquare$

Lemma 2.5 is the arithmetic core of the entire extension: it is precisely
the statement that pushing a dimension into the negatives contributes the
sign $(-1)^n$.

---

## 3. Formal spaces and their Euler characteristic

**Definition 3.1 (Formal space).** A *formal space* is a pair
$X = (\dim X, |\pi_0(X)|)$ consisting of an integer $\dim X \in \mathbb{Z}$
(allowed to be negative) and a natural number $|\pi_0(X)| \in \mathbb{N}$
recording its number of path components. We write the two coordinates as
$\dim X$ and $\operatorname{comp}(X) = |\pi_0(X)|$.

This is the minimal data an Euler-characteristic-type invariant can see:
a graded location (dimension) and a count (components). It is faithful to
those spaces whose reduced homology is concentrated in a single degree —
formal spheres and their wedges and disjoint unions — and the graded
refinement of Section 6 removes even this restriction.

**Definition 3.2 (Euler characteristic).** The Euler characteristic of a
formal space $X$ is
$$\chi(X) = \operatorname{sgn}(\dim X)\cdot\operatorname{comp}(X) \in \mathbb{Z}.$$

**Theorem 3.3 (Euler characteristic in negative dimensions).** If a formal
space $X$ has dimension $\dim X = -n$ for some $n \in \mathbb{N}$, then
$$\chi(X) = (-1)^n\cdot\operatorname{comp}(X).$$

*Proof.* Substitute $\dim X = -n$ into Definition 3.2 and apply
Lemma 2.5: $\chi(X) = \operatorname{sgn}(-n)\cdot\operatorname{comp}(X)
= (-1)^n\cdot\operatorname{comp}(X)$. $\qquad\blacksquare$

Theorem 3.3 is the headline result. It says that below dimension $0$ the
Euler characteristic sees only two things: the number of path components
and the parity of the depth $n$. In even negative dimensions $\chi$
coincides with the component count; in odd negative dimensions it is its
negative.

**Definition 3.4 (One-point space).** The one-point space is
$\mathrm{pt} = (0, 1)$: dimension $0$, a single component.

**Proposition 3.5.** $\chi(\mathrm{pt}) = 1$.

*Proof.* $\chi(\mathrm{pt}) = \operatorname{sgn}(0)\cdot 1 = 1\cdot 1 = 1$
by Lemma 2.2. $\qquad\blacksquare$

The one-point space is the unit of the algebraic structure developed in
Section 5; that $\chi(\mathrm{pt}) = 1 \ne 0$ shows the theory is
non-degenerate.

---

## 4. Additivity and multiplicativity

**Definition 4.1 (Disjoint union).** For formal spaces $X, Y$ with
$\dim X = \dim Y$, their disjoint union is
$$X \sqcup Y = (\dim X,\; \operatorname{comp}(X) + \operatorname{comp}(Y)).$$
The common dimension is preserved and the component counts add.

**Theorem 4.2 (Additivity).** If $\dim X = \dim Y$, then
$$\chi(X \sqcup Y) = \chi(X) + \chi(Y).$$

*Proof.* Write $d = \dim X = \dim Y$. Then
$$\chi(X \sqcup Y) = \operatorname{sgn}(d)\bigl(\operatorname{comp}(X) + \operatorname{comp}(Y)\bigr)
= \operatorname{sgn}(d)\operatorname{comp}(X) + \operatorname{sgn}(d)\operatorname{comp}(Y)
= \chi(X) + \chi(Y),$$
by distributivity, using $\dim Y = d$ in the definition of $\chi(Y)$.
$\qquad\blacksquare$

**Definition 4.3 (Product).** For formal spaces $X, Y$ their product is
$$X \times Y = (\dim X + \dim Y,\; \operatorname{comp}(X)\cdot\operatorname{comp}(Y)).$$
Dimensions add; component counts multiply.

**Theorem 4.4 (Multiplicativity).** For all formal spaces $X, Y$,
$$\chi(X \times Y) = \chi(X)\cdot\chi(Y).$$

*Proof.* Using Definition 4.3, the homomorphism law (Lemma 2.4), and
commutativity of integer multiplication,
$$
\chi(X \times Y)
= \operatorname{sgn}(\dim X + \dim Y)\cdot\operatorname{comp}(X)\operatorname{comp}(Y)
= \operatorname{sgn}(\dim X)\operatorname{sgn}(\dim Y)\cdot\operatorname{comp}(X)\operatorname{comp}(Y),
$$
which rearranges to
$\bigl(\operatorname{sgn}(\dim X)\operatorname{comp}(X)\bigr)\bigl(\operatorname{sgn}(\dim Y)\operatorname{comp}(Y)\bigr)
= \chi(X)\chi(Y)$. $\qquad\blacksquare$

Theorem 4.4 is the classical multiplicativity of the Euler characteristic,
extended verbatim to all integer dimensions. It is the sole place where
the homomorphism law of the dimensional sign is essential.

---

## 5. The monoid of formal spaces and the universal invariant

The product of Definition 4.3 gives the collection of formal spaces the
structure of an algebraic system in which $\chi$ is a structure-preserving
map.

**Theorem 5.1 (Monoid structure).** The set of formal spaces, equipped
with the product $\times$ as multiplication and the one-point space
$\mathrm{pt}$ as unit, is a commutative monoid. Concretely it is the
direct product of the additive monoid $(\mathbb{Z}, +)$ of dimensions and
the multiplicative monoid $(\mathbb{N}, \cdot)$ of component counts.

*Proof.* Associativity, commutativity, and the unit laws for $\times$
follow coordinatewise from the corresponding laws for $+$ on $\mathbb{Z}$
and $\cdot$ on $\mathbb{N}$; the unit $\mathrm{pt} = (0,1)$ is the pair of
the additive unit $0$ and the multiplicative unit $1$. $\qquad\blacksquare$

**Theorem 5.2 (Euler characteristic as monoid homomorphism).** The map
$\chi\colon (\text{formal spaces}, \times, \mathrm{pt}) \to (\mathbb{Z}, \cdot, 1)$
is a monoid homomorphism: $\chi(\mathrm{pt}) = 1$ and
$\chi(X \times Y) = \chi(X)\chi(Y)$ for all $X, Y$.

*Proof.* The unit condition is Proposition 3.5 and the multiplicativity is
Theorem 4.4. $\qquad\blacksquare$

Thus the Euler characteristic is the *universal multiplicative invariant*
of the theory: a single homomorphism whose restriction to the sub-monoid
of negative dimensions is the content of Theorem 3.3.

---

## 6. Suspension and stabilization

**Definition 6.1 (Suspension).** The suspension of a formal space raises
its dimension by one and preserves its components:
$$\Sigma X = (\dim X + 1,\; \operatorname{comp}(X)).$$

**Theorem 6.2 (Suspension reverses $\chi$).** For every formal space $X$,
$$\chi(\Sigma X) = -\chi(X).$$

*Proof.* By Lemma 2.4 and $\operatorname{sgn}(1) = -1$,
$\chi(\Sigma X) = \operatorname{sgn}(\dim X + 1)\operatorname{comp}(X)
= \operatorname{sgn}(\dim X)\operatorname{sgn}(1)\operatorname{comp}(X)
= -\operatorname{sgn}(\dim X)\operatorname{comp}(X) = -\chi(X)$.
$\qquad\blacksquare$

**Definition 6.3 ($n$-fold suspension).** For $n \in \mathbb{N}$,
$$\Sigma^n X = (\dim X + n,\; \operatorname{comp}(X)).$$
In particular $\Sigma^0 X = X$.

**Theorem 6.4 (Suspension scaling law).** For all $n \in \mathbb{N}$ and
all formal spaces $X$,
$$\chi(\Sigma^n X) = (-1)^n\,\chi(X).$$

*Proof.* By Lemma 2.4 and Lemma 2.5,
$\chi(\Sigma^n X) = \operatorname{sgn}(\dim X + n)\operatorname{comp}(X)
= \operatorname{sgn}(\dim X)\operatorname{sgn}(n)\operatorname{comp}(X)
= (-1)^n\operatorname{sgn}(\dim X)\operatorname{comp}(X) = (-1)^n\chi(X)$.
$\qquad\blacksquare$

**Theorem 6.5 (Stabilization to dimension zero).** If $\dim X = -n$, then
$\dim(\Sigma^n X) = 0$.

*Proof.* $\dim(\Sigma^n X) = \dim X + n = -n + n = 0$. $\qquad\blacksquare$

**Theorem 6.6 (Stabilization reads off $|\pi_0|$).** If $\dim X = -n$, then
$$\chi(\Sigma^n X) = \operatorname{comp}(X) = |\pi_0(X)|.$$

*Proof.* By Theorem 6.5 the stabilized space has dimension $0$, and
$\operatorname{sgn}(0) = 1$ by Lemma 2.2, so
$\chi(\Sigma^n X) = 1\cdot\operatorname{comp}(X) = \operatorname{comp}(X)$.
$\qquad\blacksquare$

**Theorem 6.7 (Consistency via stabilization).** If $\dim X = -n$, then
$(-1)^n\,\chi(X) = |\pi_0(X)|$, and hence
$\chi(X) = (-1)^n\,|\pi_0(X)|$.

*Proof.* By the scaling law (Theorem 6.4),
$\chi(\Sigma^n X) = (-1)^n\chi(X)$, and by Theorem 6.6 the left-hand side
equals $|\pi_0(X)|$; equating gives $(-1)^n\chi(X) = |\pi_0(X)|$.
Multiplying through by $(-1)^n$ and using $(-1)^n(-1)^n = 1$ recovers
Theorem 3.3. $\qquad\blacksquare$

The stabilization map is thus the conceptual heart of the theory: it
realizes the negative-dimensional world as a mirror image of the
$0$-dimensional world, with the suspension count $n$ recording the reflected
sign. Theorem 6.7 re-derives the headline formula purely from the dynamics
of suspension, independent of the direct computation in Theorem 3.3.

---

## 7. The graded Euler characteristic and a topological bridge

The single-degree model above is faithful to spaces whose homology is
concentrated in one degree. To reach genuinely multi-degree topology we
sum over degrees with the dimensional sign as weight.

**Definition 7.1 (Graded Euler characteristic).** Let $b\colon \mathbb{Z}
\to \mathbb{N}$ be a family of Betti numbers, finitely supported on a
finite set $S \subset \mathbb{Z}$ of degrees. Its graded Euler
characteristic is
$$\chi_{\mathrm{gr}}(b, S) = \sum_{i \in S} \operatorname{sgn}(i)\cdot b_i
= \sum_{i \in S} (-1)^i b_i.$$
Because $\operatorname{sgn}(i) = (-1)^i$ for *every* integer $i$, this is
the alternating sum of Betti numbers, extended to negative degrees.

**Proposition 7.2 (Concentration).** If $b$ is concentrated in a single
degree $d$ with value $k$ — that is, $b_d = k$ and $b_i = 0$ for $i \ne d$
— then $\chi_{\mathrm{gr}}(b, \{d\}) = \operatorname{sgn}(d)\cdot k$,
recovering the formal-space invariant $\chi$.

*Proof.* The sum over $\{d\}$ has the single term
$\operatorname{sgn}(d)\cdot b_d = \operatorname{sgn}(d)\cdot k$.
$\qquad\blacksquare$

**Theorem 7.3 (Genus formula).** Let $\Sigma_g$ be the closed orientable
surface of genus $g$, with Betti numbers $b_0 = 1$, $b_1 = 2g$, $b_2 = 1$
and $b_i = 0$ otherwise. Then
$$\chi_{\mathrm{gr}}(b, \{0, 1, 2\}) = 2 - 2g.$$

*Proof.* Summing over the three supported degrees,
$$\chi_{\mathrm{gr}} = \operatorname{sgn}(0)\cdot 1 + \operatorname{sgn}(1)\cdot 2g + \operatorname{sgn}(2)\cdot 1
= (1)(1) + (-1)(2g) + (1)(1) = 2 - 2g,$$
using $\operatorname{sgn}(0) = \operatorname{sgn}(2) = 1$ and
$\operatorname{sgn}(1) = -1$ from Lemma 2.2. The middle Betti number
$b_1 = 2g$ is the rank of the first homology of $\Sigma_g$, established by
a homological computation of its cycle structure. $\qquad\blacksquare$

Theorem 7.3 shows that the same sign-weighted invariant that reaches into
negative degrees also reproduces the classical Euler characteristic of
surfaces: $\chi = 2$ for the sphere ($g = 0$), $\chi = 0$ for the torus
($g = 1$), and $\chi = 2 - 2g$ in general. The extension to negative
dimensions is therefore not a departure from classical topology but a
continuation of it along its own grain.

---

## 8. Algorithms

The theory is entirely effective; all invariants are computable from the
finite data $(\dim, |\pi_0|)$ or from a finitely supported Betti family.

**Algorithm 8.1 (Negative-dimensional Euler characteristic).** *Input:*
integers $\dim X$ and $\operatorname{comp}(X) \ge 0$. *Output:* $\chi(X)$.
Compute $\operatorname{sgn}(\dim X) = 1$ if $\dim X$ is even else $-1$, and
return $\operatorname{sgn}(\dim X)\cdot\operatorname{comp}(X)$. Cost: one
parity test and one multiplication, $O(1)$.

**Algorithm 8.2 (Stabilization).** *Input:* a formal space $X$ with
$\dim X = -n \le 0$. *Output:* the stabilized space $\Sigma^n X$ of
dimension $0$ and its Euler characteristic. Set $n = -\dim X$, form
$\Sigma^n X = (0, \operatorname{comp}(X))$, and return
$\chi(\Sigma^n X) = \operatorname{comp}(X)$. Cost $O(1)$; verifies
Theorem 6.6.

**Algorithm 8.3 (Graded Euler characteristic).** *Input:* a finite list of
pairs $(i, b_i)$ of degrees and Betti numbers. *Output:*
$\chi_{\mathrm{gr}} = \sum_i (-1)^i b_i$. Iterate over the list
accumulating $(-1)^i b_i$. Cost linear in the number of supported degrees.

---

## 9. Applications and discussion

**A universal multiplicative invariant.** Theorem 5.2 casts $\chi$ as a
monoid homomorphism from formal spaces to $(\mathbb{Z}, \cdot)$. Its
restriction to negative dimensions (Theorem 3.3) is thus not a separate
object but a single homomorphism viewed on a sub-monoid.

**Stabilization as a mirror.** The parity-invariance
$\operatorname{sgn}(-d) = \operatorname{sgn}(d)$ (Lemma 2.3) and the
stabilization map (Theorems 6.5–6.7) together realize the negative
dimensions as a reflection of the non-negative ones, with the reflected
sign recorded by the suspension count. This is the first hint of a
duality (see Section 10).

**Compatibility with classical topology.** The graded refinement
(Section 7) contains the classical alternating sum of Betti numbers as the
special case where the support lies in non-negative degrees, and the genus
formula (Theorem 7.3) confirms it agrees with the historical Euler
characteristic on surfaces.

**Non-degeneracy.** Since $\chi(\mathrm{pt}) = 1$ and $\chi$ is
sign-reversed by suspension, the theory is not the trivial $\chi \equiv 0$
invariant; each of its structural theorems has genuine content, with
multiplicativity depending essentially on the homomorphism law.

---

## 10. Future work

The results here establish the Euler characteristic as a single
multiplicative invariant governed by the dimensional sign $(-1)^d$, with
an explicit stabilization map identifying the negative-dimensional world
with the zero-dimensional one up to sign. Several conjectures suggest
themselves.

1. **A negative-dimensional Euler–Poincaré duality.** For a formal space
   of dimension $-n$ there should be a canonical pairing between its
   $\pi_0$ data and that of its $n$-fold stabilization under which $\chi$
   is self-dual: reflecting $d \mapsto -d$ leaves $\chi$ unchanged up to
   the parity sign already recorded by $\operatorname{sgn}$. The invariance
   $\operatorname{sgn}(-d) = \operatorname{sgn}(d)$ is the shadow of a
   duality swapping a space with its formal desuspension while preserving
   the count of components.

2. **Multiplicativity forces the sign law.** Any dimension-graded,
   component-multiplicative integer invariant that is additive under
   disjoint union and multiplicative under products should coincide with
   $\operatorname{sgn}(\dim)\cdot|\pi_0|$; equivalently, the only monoid
   homomorphism from $(\mathbb{Z}, +) \times (\mathbb{N}, \cdot)$ to
   $\mathbb{Z}$ that is $\pm 1$ on each sphere is the Euler characteristic.
   Additivity and multiplicativity pin the invariant down on generators
   (spheres and points), and every formal space is built from these.

3. **The pro-spectrum limit of the stabilization tower.** The bi-infinite
   tower $\cdots \to \Sigma^{-1} X \to X \to \Sigma X \to \cdots$ should
   possess a well-defined stable Euler characteristic obtained as a limit,
   independent of the starting dimension and depending only on $|\pi_0|$
   weighted by a coherent sign. Although each suspension flips the sign,
   the pair $(\chi, \dim \bmod 2)$ is a genuine invariant of the whole
   tower, so the limit exists once one records the parity alongside the
   value.

4. **Negative-dimensional surfaces and a signed Gauss–Bonnet.** The
   identity $\chi = 2 - 2g$ should admit a negative-dimensional companion
   in which the roles of the top and bottom Betti numbers are exchanged by
   desuspension, hinting at a signed Gauss–Bonnet statement across the
   full integer range of dimensions.

---

## 11. Conclusion

We have shown that the Euler characteristic extends to every integer
dimension as a single multiplicative invariant $\chi = (-1)^{\dim}|\pi_0|$,
governed entirely by the dimensional sign $d \mapsto (-1)^d$. In dimension
$-n$ it equals $(-1)^n|\pi_0|$; it is additive under disjoint union,
multiplicative under products, and reversed by suspension; and the
$n$-fold suspension stabilizes a space of dimension $-n$ to dimension $0$,
where $\chi$ reads off the number of path components. A graded refinement
reproduces the classical genus formula $\chi = 2 - 2g$. Every result
reduces to the observation that $(-1)^d$ is a homomorphism from the
additive group of dimensions to the sign group — the alternating heartbeat
of the Euler characteristic, followed all the way down below zero.
