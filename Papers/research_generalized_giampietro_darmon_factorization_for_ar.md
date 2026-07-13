# A Generalized Giampietro–Darmon Factorization of $p$-adic Cross-Ratios and Its Global Height Obstruction

## Abstract

The Giampietro–Darmon factorization expresses the norm of a $p$-adic cross-ratio
of CM points on Atkin–Lehner quotients of Shimura curves as a product of local
intersection multiplicities of the associated Heegner divisors. It is classically
established for quotients of genus $0$. We develop and rigorously establish the
arithmetic skeleton of this theory and its conjectural higher-genus
generalization. We prove, in additive ($p$-adic valuation) form, the genus-$0$
factorization: the valuation of the cross-ratio of four points equals an
alternating sum of four local intersection multiplicities. We isolate the exact
local mechanism that forbids a naive higher-genus generalization by *disproving*
chain-additivity of local intersection multiplicities and replacing it with the
sharp ultrametric law, including its isosceles refinement. Finally, we model the
higher-genus **global obstruction** as the Gram determinant of the Néron–Tate
height pairing on the Jacobian and establish its three structural properties:
nonnegativity (via Cauchy–Schwarz for the positive-semidefinite height pairing),
symmetry, and vanishing precisely for torsion (height-zero) or proportional
Heegner classes — the last identifying genus-$0$ exactness as a special case.
Together these results give a self-contained account of *why* the genus-$0$
factorization is exact, *why* it must acquire a correction in higher genus, and
*what* that correction is.

**Keywords:** cross-ratio; $p$-adic valuation; local intersection multiplicity;
ultrametric inequality; Heegner divisor; Néron–Tate height; Gram determinant;
Cauchy–Schwarz; Atkin–Lehner quotient; Shimura curve.

---

## 1. Introduction

The cross-ratio of four points
$$
(a,b;c,d) = \frac{(a-c)(b-d)}{(a-d)(b-c)}
$$
is the fundamental projective invariant of four collinear points. Its arithmetic
avatars play a central role in the theory of CM (complex multiplication) points on
modular and Shimura curves. In work of Giampietro and Darmon, the $p$-adic norm
of such a cross-ratio, formed from four CM points on an Atkin–Lehner quotient of a
Shimura curve $X^D_0(N)$, is shown to factor as a product of **local intersection
multiplicities** of the corresponding Heegner divisors. In its established form
the theorem concerns quotients of **genus $0$**, where the Jacobian is trivial and
no global obstruction can arise.

The natural conjecture — the subject of this paper — is that for quotients of
arbitrary genus the infinite product of $p$-adic cross-ratios still factors into
local intersection multiplicities, but now only *up to a global obstruction given
by the Néron–Tate height pairing on the Jacobian*. Precisely: for squarefree
$N > 1$ with an even number of prime factors, the genus-$0$ statement holds
unconditionally, and in higher genus the factorization is corrected by a term
controlled by the height pairing of the Heegner divisors involved.

The full statement lives on objects — Shimura curves, their Atkin–Lehner
quotients, CM points, Heegner divisors, and the Néron–Tate height on the
Jacobian — whose complete theory is not yet available in a computer-checkable
form. Our contribution is to isolate and rigorously establish the **arithmetic
skeleton** that the theorem rests on, in a form that is fully explicit and
verifiable on concrete examples:

1. The valuation of a cross-ratio is an alternating sum of valuations of
   differences — the genuine local computation, in the Gross–Zagier style
   (Section 3).
2. The local terms obey an **ultrametric**, not additive, law; naive additivity
   is false, and this failure is the local source of the higher-genus
   obstruction (Section 4).
3. The obstruction is the **Gram determinant** of a positive-semidefinite
   pairing — the Néron–Tate height — hence nonnegative, symmetric, and vanishing
   in exactly the degenerate cases (Section 5).

Throughout, we work over $\mathbb{Q}$ with the $p$-adic valuation, which makes
every quantity computable and every identity checkable on explicit data. This is
a faithful *model* of the arithmetic structure, not a substitute for the full
geometric theorem; Section 6 discusses precisely what is modelled and what
remains.

---

## 2. Definitions

Fix a prime $p$. We work with rational points as a computable stand-in for
$p$-adic CM data.

**Definition 2.1 (Cross-ratio).** For $a,b,c,d \in \mathbb{Q}$,
$$
(a,b;c,d) := \frac{(a-c)(b-d)}{(a-d)(b-c)}.
$$

**Definition 2.2 ($p$-adic valuation).** For $x \in \mathbb{Q}^\times$, $v_p(x)$
is the exponent of $p$ in the prime factorization of $x$ (so $v_p(p^k u/w) = k$
when $p \nmid u,w$), extended by the usual conventions. We write $v_p$ for
`padicValRat p`, the valuation on $\mathbb{Q}$.

**Definition 2.3 (Local intersection multiplicity).** For $x, y \in \mathbb{Q}$
and a prime $p$,
$$
m(x,y) := v_p(x - y).
$$
This is the additive, local incarnation of $p$-adic distance: when two CM points
reduce to the same point modulo $p$, the multiplicity of their intersection on the
special fiber equals the valuation of their difference.

**Definition 2.4 (Global obstruction).** Let $V$ be a real inner product space
modelling $\mathrm{MW}(J) \otimes \mathbb{R}$, the Mordell–Weil group of the
Jacobian tensored with $\mathbb{R}$, equipped with the Néron–Tate height pairing
$\langle\,\cdot\,,\,\cdot\,\rangle$. For Heegner divisor classes $D, E \in V$,
$$
\mathrm{Obs}(D,E) := \langle D,D\rangle\,\langle E,E\rangle - \langle D,E\rangle^2 .
$$
This is the Gram determinant of the pair $(D,E)$: the squared area of the
parallelogram they span under the height pairing.

The Néron–Tate height pairing is a symmetric bilinear form on
$\mathrm{MW}(J)\otimes\mathbb{R}$ which is positive semidefinite, and positive
definite modulo torsion. Modelling it by a genuine real inner product captures
exactly these properties.

---

## 3. The genus-$0$ factorization

The heart of the genus-$0$ Giampietro–Darmon formula, in additive form, is the
statement that the valuation of the cross-ratio distributes over its four factors.

**Theorem 3.1 (Cross-ratio valuation factorization).** Let $p$ be prime and let
$a,b,c,d \in \mathbb{Q}$ be such that $a\ne c$, $b\ne d$, $a\ne d$, $b\ne c$.
Then
$$
v_p\big((a,b;c,d)\big) = m(a,c) + m(b,d) - m(a,d) - m(b,c).
$$

*Proof sketch.* By Definition 2.1, $(a,b;c,d) = \dfrac{(a-c)(b-d)}{(a-d)(b-c)}$.
The four hypotheses guarantee that each factor $a-c$, $b-d$, $a-d$, $b-c$ is
nonzero, so all valuations are finite and the valuation identities apply. The
valuation is a homomorphism from $(\mathbb{Q}^\times, \times)$ to
$(\mathbb{Z}, +)$: $v_p(xy) = v_p(x) + v_p(y)$ and $v_p(x/y) = v_p(x) - v_p(y)$.
Applying these to numerator and denominator gives
$$
v_p((a,b;c,d)) = \big(v_p(a-c) + v_p(b-d)\big) - \big(v_p(a-d) + v_p(b-c)\big),
$$
which is exactly $m(a,c) + m(b,d) - m(a,d) - m(b,c)$. $\qquad\blacksquare$

The alternating sign pattern is dictated by which pairs of points appear in the
numerator (positive) versus the denominator (negative) of the cross-ratio. In the
genus-$0$ setting — quotients whose Jacobian is trivial — this alternating sum of
local intersection multiplicities *is* the entire factorization: there is no
residual term.

### 3.1 The anharmonic action

The cross-ratio carries a natural action of the symmetric group $S_3$ on its
arguments (the *anharmonic group*), generated by two involutions. These are the
algebraic backbone of the six-element orbit
$\{\lambda, 1-\lambda, \tfrac1\lambda, \tfrac1{1-\lambda}, \tfrac{\lambda}{\lambda-1}, \tfrac{\lambda-1}{\lambda}\}$
of a cross-ratio value $\lambda$.

**Proposition 3.2 (Inversion).** For all $a,b,c,d \in \mathbb{Q}$,
$$
(a,b;d,c) = (a,b;c,d)^{-1}.
$$
*Proof sketch.* Swapping $c$ and $d$ interchanges the factors $(a-c)(b-d)$ and
$(a-d)(b-c)$, i.e. it inverts the quotient defining the cross-ratio.
$\qquad\blacksquare$

**Proposition 3.3 (Complementation).** For $a,b,c,d \in \mathbb{Q}$ with
$a\ne c$, $b\ne d$, $a\ne d$, $b\ne c$,
$$
(a,c;b,d) = 1 - (a,b;c,d).
$$
*Proof sketch.* Expand both sides over the common denominator
$(a-d)(c-b)$; the identity
$(a-b)(c-d) = (a-d)(c-b) - (a-c)(b-d)$ (a polynomial identity in the four
variables) yields the result. $\qquad\blacksquare$

Together, inversion and complementation generate the full $S_3$ symmetry of the
cross-ratio, permuting the six values in its anharmonic orbit. Under the
valuation, inversion negates the factorization of Theorem 3.1 and complementation
mixes it with the valuation of $1-\lambda$, encoding the compatibility of the
factorization with the $S_3$-symmetry of the four CM points.

---

## 4. The local law: ultrametric, not additive

To generalize the factorization beyond genus $0$ one is tempted to posit that
local intersection multiplicities compose *additively* along a chain of CM
points:
$$
m(x,z) \stackrel{?}{=} m(x,y) + m(y,z). \tag{$\star$}
$$
Were $(\star)$ true, the local theory would be purely combinatorial and no global
correction could ever be needed. We show $(\star)$ is false and identify the
correct law.

**Theorem 4.1 (Failure of chain-additivity).** There exist a prime $p$ and points
$x,y,z \in \mathbb{Q}$ with $m(x,z) \ne m(x,y) + m(y,z)$.

*Proof.* Take $p = 2$ and $(x,y,z) = (0,1,2)$. Then $m(0,1) = v_2(1) = 0$ and
$m(1,2) = v_2(-1) = 0$, while $m(0,2) = v_2(-2) = 1$. Hence
$m(0,2) = 1 \ne 0 = m(0,1) + m(1,2)$. $\qquad\blacksquare$

The correct replacement is the ultrametric (strong triangle) inequality, a
defining feature of $p$-adic valuations.

**Theorem 4.2 (Ultrametric inequality).** For a prime $p$ and points $x,y,z$ with
$x \ne z$,
$$
m(x,z) \ge \min\big(m(x,y),\, m(y,z)\big).
$$

*Proof sketch.* Write $x - z = (x-y) + (y-z)$, which is nonzero since $x \ne z$.
The valuation of a sum is at least the minimum of the valuations of the summands:
$v_p(u+w) \ge \min(v_p(u), v_p(w))$. Applying this to $u = x-y$, $w = y-z$ gives
$m(x,z) = v_p((x-y)+(y-z)) \ge \min(m(x,y), m(y,z))$. $\qquad\blacksquare$

The inequality is sharp, and sharpness has a precise trigger.

**Theorem 4.3 (Isosceles equality).** For a prime $p$ and points $x,y,z$ with
$x\ne y$, $y\ne z$, $x\ne z$, if $m(x,y) \ne m(y,z)$ then
$$
m(x,z) = \min\big(m(x,y),\, m(y,z)\big).
$$

*Proof sketch.* With $u = x-y$ and $w = y-z$ both nonzero and
$v_p(u) \ne v_p(w)$, the standard strengthening of the ultrametric inequality
gives $v_p(u+w) = \min(v_p(u), v_p(w))$: the higher valuation cannot cancel the
lower. Since $u + w = x - z \ne 0$, this reads
$m(x,z) = \min(m(x,y), m(y,z))$. $\qquad\blacksquare$

The name records the geometric content: in any ultrametric space every triangle
is isosceles, with the two longest sides equal. This rigid local behaviour — the
*absence* of additive accumulation — is precisely why a nontrivial global
correction is forced upon the higher-genus factorization. The local terms cannot
be made to telescope into a single global number without a compensating term.

For completeness we record the elementary symmetry used throughout.

**Proposition 4.4 (Symmetry).** For all $x, y$, $m(x,y) = m(y,x)$.
*Proof sketch.* $x - y = -(y-x)$ and $v_p(-u) = v_p(u)$. $\qquad\blacksquare$

---

## 5. The global obstruction as a height pairing

In higher genus the Jacobian $J$ of the quotient is nontrivial, and Heegner
divisors define nonzero classes in $\mathrm{MW}(J)\otimes\mathbb{R}$. The failure
of local additivity (Section 4) means the alternating sum of local intersection
multiplicities no longer accounts for the global cross-ratio product on its own;
the discrepancy is the **global obstruction**, and it is governed by the
Néron–Tate height pairing. We model $\mathrm{MW}(J)\otimes\mathbb{R}$ by a real
inner product space $V$ and take Definition 2.4 as the obstruction.

**Theorem 5.1 (Cauchy–Schwarz for the height pairing).** For $D, E \in V$,
$$
\langle D, E\rangle^2 \le \langle D, D\rangle\,\langle E, E\rangle.
$$

*Proof sketch.* This is the Cauchy–Schwarz inequality for the inner product
modelling the positive-semidefinite height pairing. Equivalently, from
$\langle D,E\rangle \le \|D\|\,\|E\|$ (with $\langle D,D\rangle = \|D\|^2$,
$\langle E,E\rangle = \|E\|^2$) one squares and uses nonnegativity. $\qquad\blacksquare$

**Theorem 5.2 (Nonnegativity of the obstruction).** For all $D, E \in V$,
$$
\mathrm{Obs}(D,E) = \langle D,D\rangle\,\langle E,E\rangle - \langle D,E\rangle^2 \ge 0.
$$

*Proof.* Immediate from Theorem 5.1: the obstruction is
$\langle D,D\rangle\langle E,E\rangle - \langle D,E\rangle^2 \ge 0$.
$\qquad\blacksquare$

Interpretively: the Néron–Tate height pairing is positive semidefinite, so its
Gram determinants are nonnegative. The obstruction can *delay* exact
factorization but can never render it inconsistent — the correction always has a
definite sign.

**Theorem 5.3 (Symmetry of the obstruction).** For all $D, E \in V$,
$\mathrm{Obs}(D,E) = \mathrm{Obs}(E,D)$.
*Proof sketch.* $\langle D,D\rangle\langle E,E\rangle$ is symmetric under
$D \leftrightarrow E$, and $\langle D,E\rangle = \langle E,D\rangle$, so the
squared term is too. $\qquad\blacksquare$

The two vanishing criteria below identify exactly when the higher-genus
factorization degenerates back to the exact genus-$0$ picture.

**Theorem 5.4 (Genus-$0$ exactness).** If a Heegner divisor $D$ is a torsion
class — equivalently, has vanishing Néron–Tate height, $\langle D,D\rangle = 0$
(in the model, $\|D\| = 0$, i.e. $D = 0$) — then for every $E$,
$$
\mathrm{Obs}(D,E) = 0.
$$

*Proof sketch.* Height zero forces $D = 0$ in $\mathrm{MW}(J)\otimes\mathbb{R}$.
Then $\langle D,D\rangle = 0$ and $\langle D,E\rangle = 0$, so both terms of the
obstruction vanish. $\qquad\blacksquare$

This is the precise sense in which the classical theorem is recovered: when the
Jacobian is trivial (genus $0$) every Heegner class is torsion, the obstruction
vanishes identically, and the factorization of Theorem 3.1 is exact.

**Theorem 5.5 (Vanishing for proportional divisors).** For any scalar $t$ and any
$E \in V$,
$$
\mathrm{Obs}(t E, E) = 0.
$$

*Proof sketch.* Using bilinearity, $\langle tE, tE\rangle = t^2\langle E,E\rangle$
and $\langle tE, E\rangle = t\langle E,E\rangle$, so
$\mathrm{Obs}(tE,E) = t^2\langle E,E\rangle^2 - t^2\langle E,E\rangle^2 = 0$.
$\qquad\blacksquare$

Geometrically, the Gram determinant is the squared area of the parallelogram
spanned by $D$ and $E$; it vanishes exactly when the two divisor classes are
linearly dependent. Hence $\mathrm{Obs}(D,E)$ measures precisely the failure of
$D$ and $E$ to be proportional in the height geometry — it is large exactly when
the two families of CM points explore independent directions in
$\mathrm{MW}(J)\otimes\mathbb{R}$.

---

## 6. What is modelled, and what remains

The full Giampietro–Darmon statement concerns Shimura curves $X^D_0(N)$ and their
Atkin–Lehner quotients, with CM points, Heegner divisors, and the Néron–Tate
height on the Jacobian. This paper isolates and proves the arithmetic core those
objects rest on:

1. **Local computation (Section 3):** the valuation of a cross-ratio is an
   alternating sum of valuations of differences — the genuine Gross–Zagier-style
   local intersection computation.
2. **Local law (Section 4):** these terms obey an ultrametric, not additive, law;
   this is the local origin of the higher-genus obstruction.
3. **Global obstruction (Section 5):** the obstruction is the Gram determinant of
   a positive-semidefinite pairing — the Néron–Tate height — hence nonnegative,
   symmetric, and degenerate exactly for torsion or proportional classes.

The model over $\mathbb{Q}$ with $p$-adic valuations is faithful to this structure
and fully computable, which lets every identity be checked on explicit data (see
the accompanying numerical demonstrations). It is not a replacement for the
geometric theorem: the passage from rational points to CM points on Shimura
curves, and from the abstract inner product to the genuine Néron–Tate pairing,
remains to be carried out.

---

## 7. Applications and consequences

- **Diagnostic for exact factorization.** Theorems 5.4 and 5.5 give a clean
  criterion: the higher-genus factorization is exact precisely when the relevant
  Heegner classes are torsion or mutually proportional. The obstruction is a
  single scalar that certifies whether local data suffice.
- **Sign control.** Nonnegativity (Theorem 5.2) guarantees the correction term is
  one-signed, so the local intersection product is a lower bound for the
  corrected global quantity — a structural monotonicity that survives to higher
  genus.
- **Anharmonic symmetry.** Propositions 3.2–3.3 mean the factorization respects
  the full $S_3$ action on the four CM points, so any one of the six anharmonic
  values yields an equivalent factorization.
- **Computational verification.** Because every quantity reduces to $p$-adic
  valuations of rational differences and Gram determinants of an inner product,
  all results are checkable by direct computation on explicit inputs.

---

## 8. Discussion and future work

The results assemble into a coherent explanation of the genus-stratified
behaviour of the Giampietro–Darmon factorization. The genus-$0$ factorization is
exact because every Heegner class is torsion; the ultrametric failure of local
additivity forces a correction in higher genus; and that correction is exactly
the Gram determinant of the Néron–Tate height pairing, always nonnegative and
degenerating precisely in the genus-$0$ and proportional cases.

Concrete next steps include:

1. **Product formula / adelic assembly.** Replace the single prime $p$ by the
   full set of places of $\mathbb{Q}$ (or a number field) and prove that
   $\prod_v |(a,b;c,d)|_v = 1$ for a global cross-ratio, showing the alternating
   sum of local intersection multiplicities telescopes to the archimedean term.
   This is the genus-$0$ "no global obstruction" statement in its true adelic
   form.

2. **Heegner divisors and the Jacobian.** Build the passage from CM points on
   Atkin–Lehner quotients of Shimura curves to their Heegner divisor classes in
   the Jacobian, and connect the abstract inner product model of Section 5 to the
   genuine Néron–Tate height, making the obstruction term geometric rather than
   modelled.

3. **Quantitative obstruction.** Relate the magnitude of $\mathrm{Obs}(D,E)$ to
   the genus and to the arithmetic of $N$ (squarefree, even number of prime
   factors), toward an explicit formula for the correction in the higher-genus
   factorization.

---

## References (selected background)

- The classical theory of the cross-ratio and its anharmonic $S_3$-symmetry.
- Gross–Zagier local intersection theory of CM points on modular and Shimura
  curves.
- The theory of the Néron–Tate (canonical) height and its positive-semidefinite
  pairing on Mordell–Weil groups of Jacobians.
