# The Cyclotomic Bridge for Torus-Knot Orbital-Angular-Momentum Spectra

## Abstract

A *knotted-light* beam is an optical field whose locus of vanishing intensity — a
phase singularity — traces a closed knot $K$ in space. A conjecture on such fields
predicts that the discrete orbital-angular-momentum (OAM) values the beam can
carry are governed by the roots of the Alexander polynomial $\Delta_K$ of the
knot. For the family of $T(2,n)$ torus knots (the trefoil $3_1 = T(2,3)$, the
cinquefoil $5_1 = T(2,5)$, and their odd-$n$ successors), the Alexander
polynomial is the alternating geometric sum
$A_n(X) = 1 - X + X^2 - \cdots + X^{n-1}$. We complete the number-theoretic
picture of this family. Our central result is that, for every odd prime $p$, the
$T(2,p)$ Alexander polynomial is *literally* the $2p$-th cyclotomic polynomial,
$A_p = \Phi_{2p}$. From this identification we deduce sharp consequences: the
complex roots are **exactly** the primitive $2p$-th roots of unity, with no
spurious roots (a converse to the familiar "roots are roots of unity"
statement); the degree — hence the number of OAM channels — is
$\varphi(2p) = \varphi(p) = p-1$; the polynomial is irreducible over the
rationals, so the spectrum is a single Galois-conjugate orbit; the knot
determinant $|\Delta(-1)|$ equals $p$; and the knot is $3$-colorable if and only
if $3 \mid p$, i.e. if and only if it is the trefoil. We recover the classical
determinants $3$ and $5$ uniformly, and we contrast the crystalline torus family
against the smallest non-torus knot, the figure-eight, whose Alexander roots
$\varphi^{\pm 2}$ (with $\varphi$ the golden ratio) lie off the unit circle.

**Keywords.** Alexander polynomial, cyclotomic polynomial, torus knot, knotted
light, orbital angular momentum, roots of unity, knot determinant,
tricolorability, Euler totient, irreducibility.

---

## 1. Introduction

### 1.1 Physical background

Structured light beams can carry orbital angular momentum (OAM) through a helical
phase front. The axis of such a beam contains a *phase singularity*: a curve
along which the field amplitude vanishes and the phase is undefined. Ordinarily
this singular curve is a straight line, but tailored superpositions of paraxial
modes can bend it into a closed loop and, more dramatically, tie it into a
nontrivial knot. Experimentally realized *knotted-light* fields have produced
optical vortex lines shaped as trefoils and other simple knots.

A guiding conjecture in this area posits a bridge between the *topology* of the
singular knot and the *spectrum* of measurable OAM values: the admissible
quantized OAM channels correspond to the roots of the knot's Alexander
polynomial. This paper does not argue the physics of that bridge; it takes the
bridge as motivation and settles the *algebra and number theory* on the far side
of it for the most natural infinite family of knots, the $T(2,n)$ torus knots.

### 1.2 Contributions

We work throughout with the alternating geometric sum

$$A_n(X) = \sum_{i=0}^{n-1} (-X)^i = 1 - X + X^2 - \cdots + X^{n-1} \in \mathbb{Z}[X],$$

which is the Alexander polynomial of the torus knot $T(2,n)$ for odd $n$. Our
results are:

1. **Cyclotomic identification (Theorem 4.1).** For every odd prime $p$,
   $A_p = \Phi_{2p}$ in $\mathbb{Z}[X]$. In particular
   $A_3 = X^2 - X + 1 = \Phi_6$ and $A_5 = X^4 - X^3 + X^2 - X + 1 = \Phi_{10}$.
2. **Exact root set (Theorem 5.1).** For odd prime $p$, the complex roots of
   $A_p$ are *exactly* the primitive $2p$-th roots of unity; there are no
   spurious roots.
3. **Channel count (Theorem 6.1).** $\deg A_p = \varphi(2p) = \varphi(p) = p-1$,
   which equals the number of distinct primitive $2p$-th roots of unity.
4. **Irreducibility (Theorem 7.1).** $A_p$ is irreducible over $\mathbb{Q}$; the
   OAM spectrum is a single Galois-conjugate orbit.
5. **Determinant and colorability (Theorems 8.1–8.3).** $A_n(-1) = n$; hence the
   determinant of $T(2,n)$ is $n$, and $T(2,p)$ is $3$-colorable iff $3 \mid p$
   iff $p=3$. The classical determinants $3$ (trefoil) and $5$ (cinquefoil)
   follow uniformly.
6. **The crystalline/metallic contrast (Section 9).** The torus family has all
   roots on the unit circle; the figure-eight, with Alexander polynomial
   $X^2 - 3X + 1$ and roots $\varphi^{\pm 2}$, is the smallest knot for which
   this fails.

---

## 2. Definitions

**Definition 2.1 (Alexander polynomial of the $T(2,n)$ torus knot).**
For an odd positive integer $n$, define
$$A_n(X) = \sum_{i=0}^{n-1} (-X)^i \in \mathbb{Z}[X].$$
Equivalently $A_n(X) = 1 - X + X^2 - \cdots + X^{n-1}$, an alternating sum of $n$
monomials with all coefficients $\pm 1$.

**Definition 2.2 (Cyclotomic polynomial).**
For a positive integer $m$, the $m$-th cyclotomic polynomial $\Phi_m \in
\mathbb{Z}[X]$ is the unique monic integer polynomial whose complex roots are
exactly the *primitive* $m$-th roots of unity, i.e. the numbers $e^{2\pi i k/m}$
with $\gcd(k,m)=1$. It satisfies the defining factorization
$$X^m - 1 = \prod_{d \mid m} \Phi_d(X),$$
has degree $\varphi(m)$ (Euler's totient), and is irreducible over $\mathbb{Q}$.

**Definition 2.3 (Primitive roots of unity, as a set).**
For $m \geq 1$, write $\mu_m^{\ast} \subseteq \mathbb{C}$ for the set of primitive
$m$-th roots of unity. Then $|\mu_m^{\ast}| = \varphi(m)$ and $\Phi_m(X) =
\prod_{\zeta \in \mu_m^{\ast}} (X - \zeta)$.

**Definition 2.4 (Knot determinant).**
The determinant of a knot $K$ is $\det(K) = |\Delta_K(-1)|$, the absolute value of
its Alexander polynomial evaluated at $-1$.

**Definition 2.5 ($3$-colorability).**
A knot diagram is $3$-colorable if its arcs can be assigned three colors, using
more than one color, so that at every crossing the three incident arcs are either
all the same color or all different. A knot is $3$-colorable iff $3$ divides its
determinant.

---

## 3. The master identity

Everything rests on a single telescoping identity.

**Lemma 3.1 (Telescoping identity).** For every positive integer $n$,
$$(X+1)\,A_n(X) = X^n + 1.$$

*Proof.* $A_n(X) = \sum_{i=0}^{n-1}(-X)^i$ is a finite geometric series with ratio
$-X$, so $(1-(-X))\,A_n(X) = 1 - (-X)^n$. Since $(1-(-X)) = 1+X$ and, for odd $n$,
$(-X)^n = -X^n$, we obtain $(X+1)A_n(X) = 1 - (-X)^n = 1 + X^n$. $\square$

The identity has an immediate corollary that fixes the location of every root.

**Corollary 3.2 (Roots lie on the unit circle).** Every complex root $\zeta$ of
$A_n$ satisfies $\zeta^n = -1$ and $\zeta \neq -1$; in particular $|\zeta| = 1$.

*Proof.* If $A_n(\zeta)=0$ then $(\zeta+1)A_n(\zeta) = \zeta^n + 1 = 0$, so
$\zeta^n = -1$, whence $|\zeta|^n = 1$ and $|\zeta| = 1$. Moreover $A_n(-1) = n
\neq 0$ (Lemma 8.1 below), so $\zeta \neq -1$. $\square$

---

## 4. Cyclotomic identification

**Theorem 4.1 (Cyclotomic bridge).** For every odd prime $p$,
$$A_p(X) = \Phi_{2p}(X) \quad \text{in } \mathbb{Z}[X].$$

*Proof sketch.* By Lemma 3.1, $(X+1)A_p = X^p + 1 = X^{2p} - 1$ divided by
$X^p - 1$; concretely,
$$A_p(X) = \frac{X^p + 1}{X + 1} = \frac{X^{2p}-1}{(X^p-1)(X+1)}.$$
Using the cyclotomic factorization $X^m - 1 = \prod_{d \mid m}\Phi_d$ for
$m = 2p, p, 2$ and the fact that the positive divisors of $2p$ (for odd prime $p$)
are exactly $1, 2, p, 2p$, we cancel the factors indexed by the divisors of $p$
(namely $1, p$) and by the divisor $2$ (the factor $\Phi_2 = X+1$). What remains
is the single factor $\Phi_{2p}$. Both sides are monic of degree $p-1$ with the
same complex roots, hence equal. The small cases $A_3 = \Phi_6 = X^2 - X + 1$ and
$A_5 = \Phi_{10} = X^4 - X^3 + X^2 - X + 1$ verify the statement directly. $\square$

**Corollary 4.2 (Named small cases).**
$$X^2 - X + 1 = \Phi_6(X), \qquad X^4 - X^3 + X^2 - X + 1 = \Phi_{10}(X).$$

---

## 5. Exact root set: no spurious roots

**Theorem 5.1 (Exact roots).** For every odd prime $p$, the multiset of complex
roots of $A_p$ (equivalently, of the image of $A_p$ under the coefficient
embedding $\mathbb{Z} \hookrightarrow \mathbb{C}$) equals the set $\mu_{2p}^{\ast}$
of primitive $2p$-th roots of unity, each with multiplicity one.

*Proof.* By Theorem 4.1, over $\mathbb{C}$ we have $A_p = \Phi_{2p}$, whose roots
are by definition exactly $\mu_{2p}^{\ast}$, each simple (cyclotomic polynomials
are squarefree). $\square$

The content beyond Corollary 3.2 is the **converse**: Corollary 3.2 shows every
root is a $2p$-th root of unity of a restricted kind, but Theorem 5.1 certifies
that *no other complex number* is a root and that precisely the *primitive* ones
occur. Specializing:

**Corollary 5.2.** The roots of $A_3$ are exactly the primitive sixth roots of
unity $\{e^{\pm i\pi/3}\}$, and the roots of $A_5$ are exactly the primitive tenth
roots of unity $\{e^{\pm i\pi/5}, e^{\pm 3i\pi/5}\}$.

---

## 6. OAM channel count

**Theorem 6.1 (Channel count).** For every odd prime $p$,
$$\deg A_p = \varphi(2p) = \varphi(p) = p - 1,$$
and this is also the cardinality $|\mu_{2p}^{\ast}|$ of the set of OAM channels.

*Proof.* $\deg A_p = \deg \Phi_{2p} = \varphi(2p)$ by Theorem 4.1 and the degree
formula for cyclotomic polynomials. For odd $p$, $\gcd(2,p)=1$, so multiplicativity
of $\varphi$ gives $\varphi(2p) = \varphi(2)\varphi(p) = \varphi(p)$, and
$\varphi(p) = p-1$ since $p$ is prime. Finally $|\mu_{2p}^{\ast}| =
\varphi(2p) = p-1$. $\square$

Thus a trefoil beam ($p=3$) supports $2$ channels, a cinquefoil beam ($p=5$)
supports $4$, and $T(2,p)$ supports $p-1$ in general.

---

## 7. Irreducibility: one Galois orbit

**Theorem 7.1 (Irreducibility over $\mathbb{Q}$).** For every odd prime $p$, the
polynomial $A_p$ is irreducible over $\mathbb{Q}$.

*Proof.* By Theorem 4.1, $A_p = \Phi_{2p}$, and cyclotomic polynomials are
irreducible over $\mathbb{Q}$. $\square$

**Interpretation.** Because $A_p$ is irreducible, its roots — the OAM channels —
form a single orbit under the absolute Galois group of $\mathbb{Q}$: every channel
is an algebraic conjugate of every other. No proper nonempty subset of the
channels is the root set of a polynomial with rational coefficients, so the
spectrum is algebraically indivisible.

---

## 8. Determinant and $3$-colorability

**Lemma 8.1 (Evaluation at $-1$).** For every odd $n$, $A_n(-1) = n$.

*Proof.* $A_n(-1) = \sum_{i=0}^{n-1}(-(-1))^i = \sum_{i=0}^{n-1} 1^i =
\sum_{i=0}^{n-1} 1 = n$. (Here $(-X)^i$ at $X=-1$ is $1^i=1$.) $\square$

**Theorem 8.2 (Torus determinant).** The determinant of $T(2,n)$ is
$\det = |A_n(-1)| = n$. In particular the trefoil has determinant $3$ and the
cinquefoil has determinant $5$.

*Proof.* Immediate from Lemma 8.1. $\square$

**Theorem 8.3 ($3$-colorability criterion).** For an odd prime $p$, the torus knot
$T(2,p)$ is $3$-colorable — equivalently $3 \mid A_p(-1)$ — if and only if
$3 \mid p$, i.e. if and only if $p = 3$.

*Proof.* By Lemma 8.1, $3 \mid A_p(-1) \iff 3 \mid p$. Since $p$ is prime,
$3 \mid p \iff p = 3$. $\square$

More generally, for any prime $q$ the knot $T(2,p)$ is $q$-colorable iff
$q \mid p$ iff $q = p$: each torus knot in the family is $q$-colorable for exactly
one prime, namely $q = p$.

---

## 9. The crystalline/metallic frontier

The torus knots are *crystalline*: all their Alexander roots lie on the unit
circle, being genuine roots of unity. It is natural to ask which knots share this
property, since only such knots exhibit clean root-of-unity OAM quantization.

**Proposition 9.1 (Kronecker dichotomy for reciprocal quadratics).** For a monic
reciprocal integer polynomial $X^2 - bX + 1$, both roots lie on the unit circle
iff $b^2 < 4$ (equivalently $b \in \{-1,0,1\}$), and both are real and off the
circle iff $b^2 > 4$.

*Proof.* The roots are $\tfrac{b \pm \sqrt{b^2-4}}{2}$ with product $1$. If
$b^2 < 4$ they are complex conjugates of modulus $\sqrt{1} = 1$; if $b^2 > 4$ they
are real, distinct, reciprocal, hence one has modulus $>1$. $\square$

**Example 9.2 (The figure-eight knot).** The figure-eight knot $4_1$, the
smallest non-torus (and smallest amphichiral) knot, has Alexander polynomial
$$\Delta_{4_1}(X) = X^2 - 3X + 1.$$
Here $b = 3$, so $b^2 - 4 = 5 > 0$: the roots are real,
$$\varphi^{2} = \frac{3+\sqrt5}{2}, \qquad \varphi^{-2} = \frac{3-\sqrt5}{2},$$
where $\varphi = \tfrac{1+\sqrt5}{2}$ is the golden ratio. These lie *off* the
unit circle, so the figure-eight is the smallest knot whose spectrum is
*metallic* rather than crystalline. Its determinant is
$|\Delta_{4_1}(-1)| = |1 + 3 + 1| = 5$.

A theorem of Kronecker underlies the general picture: a monic integer polynomial
with all roots on (or in) the closed unit disc, none zero, is a product of
cyclotomic polynomials. Thus "all Alexander roots on the unit circle" is,
for reciprocal integer polynomials, equivalent to being a product of
cyclotomics — the crystalline case — and the figure-eight is the minimal witness
that not all knots qualify.

---

## 10. Algorithms

We summarize the computational content in three algorithms; full type-hinted
implementations accompany this paper.

**Algorithm A (Alexander polynomial of $T(2,n)$).** Build the coefficient vector
$[1, -1, 1, \dots, (-1)^{n-1}]$ directly, or verify it via the master identity by
checking that multiplying by $(X+1)$ yields $X^n + 1$.

**Algorithm B (Cyclotomic identification test).** Given odd prime $p$, compute
$A_p$ and $\Phi_{2p}$ independently (the latter by dividing $X^{2p}-1$ by
$\prod_{d \mid 2p, d < 2p}\Phi_d$) and confirm coefficient-wise equality.

**Algorithm C (Root/spectrum extraction).** Compute the complex roots of $A_p$
numerically and confirm each has unit modulus and argument an odd multiple of
$\pi/p$, i.e. each is a primitive $2p$-th root of unity, and that their count is
$p-1$.

---

## 11. Applications

- **OAM channel budgeting.** For a $T(2,p)$ knotted beam the number of
  independent OAM channels is $p-1$, located at $e^{i\pi(2k-1)/p}$ for
  $k = 1,\dots,p-1$ with $\gcd(2k-1,2p)=1$. This gives an exact, closed-form
  design table for encoding capacity.
- **Knot discrimination by spectrum.** Because $A_p$ is irreducible, the
  spectrum cannot be mimicked by any beam whose Alexander polynomial factors
  rationally; the crystalline/metallic dichotomy provides a coarse but robust
  invariant distinguishing torus from non-torus singular knots.
- **Colorability as a coarse label.** The determinant $=n$ result yields an
  instant $q$-colorability read-off: $T(2,n)$ is $q$-colorable iff $q \mid n$.

---

## 12. Discussion

The identification $A_p = \Phi_{2p}$ upgrades a collection of individual
root facts into a structural statement, and every downstream property (exact root
set, degree, irreducibility, determinant, colorability) becomes a corollary of a
single, well-understood object. The organizing principle is the master identity
$(X+1)A_n = X^n + 1$, which forces the roots onto the unit circle and connects the
knot family to the divisor lattice of $2p$. The figure-eight demonstrates that
this crystallinity is special: leave the torus family and the golden ratio
appears, roots leave the circle, and the tidy root-of-unity quantization breaks.

---

## 13. Future directions

1. **Composite factorization law.** For every odd $n$,
   $A_n = \prod_{d \mid 2n,\ d \nmid n} \Phi_d$, so the root set is the union of
   primitive $d$-th roots of unity over the divisors $d$ of $2n$ that do not
   divide $n$. The identity $(X+1)A_n = X^n + 1 = \prod_{d \mid 2n,\ d \nmid n}
   \Phi_d$ reduces this to divisor-set bookkeeping; the prime case collapses the
   product to one term.
2. **Crystalline/metallic frontier.** Characterize the knots with all Alexander
   roots on the unit circle as exactly those whose Alexander polynomial is a
   product of cyclotomics (Kronecker), with the figure-eight ($\varphi^{\pm 2}$)
   the smallest alternating violator.
3. **Determinant equals torsion order.** For $T(2,n)$, $|\Delta(-1)| = n$ equals
   the order of the first homology of the double branched cover, and $q \mid \det$
   characterizes $q$-colorability for every prime $q$.
4. **Reciprocity from a single symmetry.** Derive the reciprocity law
   $t^{2g}\Delta(1/t) = \Delta(t)$ and the normalization $\Delta(1) = \pm 1$ from
   an abstract Seifert-matrix axiomatization $\Delta(t) = \det(V - tV^{\top})$,
   uniformly rather than case by case.

---

## 14. Conclusion

For the $T(2,p)$ torus knots at odd primes $p$, the Alexander polynomial is the
$2p$-th cyclotomic polynomial. This single identification pins down the OAM
spectrum completely: the channels are exactly the primitive $2p$-th roots of
unity, they number $p-1$, they form one Galois orbit, and the knot determinant is
$p$ with $3$-colorability isolating the trefoil. The framework locates each
familiar torus-knot invariant inside the arithmetic of roots of unity and marks,
via the figure-eight and the golden ratio, precisely where the crystalline
picture ends.
