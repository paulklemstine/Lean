# Generation Certificates for Matrix Groups: Irreducible Characteristic Polynomials as Witnesses of Irreducible Action

## Abstract

We develop a certificate-based framework connecting an easily computable
algebraic invariant — the irreducibility of the characteristic polynomial of a
linear endomorphism — to the structural property of *irreducible action*: the
absence of any nontrivial invariant subspace. The framework is designed for the
study of random generation in finite linear groups, where such structural
properties serve as *certificates* feeding into probabilistic lower bounds. Our
central result states that if an endomorphism $\varphi$ of a finite-dimensional
vector space has irreducible characteristic polynomial, then every
$\varphi$-invariant submodule is either trivial or the whole space. We derive
three corollaries that interpret this fact in coding theory (orbit spanning),
finite geometry (Singer cycles with no fixed proper projective subspace), and
group theory (positive certificate density yielding generation lower bounds).
We package the abstract pattern as a *generation certificate system* unifying
the matrix-group and symmetric-group settings, define a quantitative
*certificate density*, and record two conjectures bounding the density of
irreducible-fingerprint elements in $\mathrm{GL}_n(\mathbb{F}_q)$. All principal
results have been formalized and machine-checked, and the proof proceeds
through a clean chain of classical ingredients: the Cayley–Hamilton theorem,
the divisibility of minimal polynomials under restriction, and dimension
counting.

**Keywords:** matrix groups, characteristic polynomial, irreducibility,
invariant subspaces, minimal polynomial, Singer cycle, random generation,
certificate density, finite fields.

---

## 1. Introduction

A recurring theme in computational group theory is the search for *certificates*
of structural properties: small, efficiently checkable pieces of data that
guarantee a global property without requiring exploration of an exponentially
large object. The paradigm originates with Dixon's theorem (1969) that two
random permutations generate the symmetric or alternating group with
probability tending to one, and runs through the matrix-group recognition
program of Neumann and Praeger (1992) and its descendants. In each case, one
identifies elements whose presence forces any containing subgroup to be large,
and then argues that such elements are dense, so a few random draws suffice.

For matrix groups over finite fields, the cleanest such certificate is
*irreducibility of action*: an element whose linear action admits no nontrivial
invariant subspace cannot be confined to a block-reducible subgroup. The
difficulty is that irreducibility of action is, prima facie, a statement
quantified over all subspaces — of which there are super-polynomially many.
The contribution of this work is to reduce that quantified geometric statement
to a single, polynomial-time algebraic check: *irreducibility of the
characteristic polynomial*. We make the reduction fully rigorous and formal,
and we organize the surrounding theory — orbit spanning, projective
no-fixed-subspace, certificate density, and an abstract certificate system —
around it.

### 1.1 Setting and conventions

Throughout, $K$ is a field and $V$ a finite-dimensional $K$-vector space. We
write $\mathrm{End}_K(V)$ for the $K$-algebra of linear endomorphisms of $V$,
and for $\varphi \in \mathrm{End}_K(V)$ we write $\chi_\varphi \in K[X]$ for its
characteristic polynomial and $\mu_\varphi \in K[X]$ for its minimal
polynomial. We use $\mathbb{F}_q$ for the finite field with $q$ elements and
$\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$ for the prime field. The dimension of
$V$ is $n = \dim_K V$, and $\deg \chi_\varphi = n$.

---

## 2. Definitions

We begin with the four definitions that organize the development.

**Definition 2.1 (Invariant submodule).** Let $\varphi \in \mathrm{End}_K(V)$
and let $W \subseteq V$ be a submodule (subspace). We say $W$ is
*$\varphi$-invariant*, written $\mathrm{IsInvariantSubmodule}(\varphi, W)$, if

$$
\forall w \in W,\quad \varphi(w) \in W.
$$

Equivalently, $W$ is a submodule of $V$ regarded as a $K[X]$-module via
$X \cdot v := \varphi(v)$. Invariant submodules are precisely the structures
through which a linear action can be decomposed, which is why their absence is
the hallmark of irreducibility.

**Definition 2.2 (Linear generation certificate).** For $K$ a field and $V$ a
finite free $K$-module, a *linear generation certificate* is a triple

$$
(\varphi,\ \text{invertible},\ \text{charpoly\_irreducible})
$$

consisting of an endomorphism $\varphi \in \mathrm{End}_K(V)$ together with a
proof that $\varphi$ is bijective and a proof that $\chi_\varphi$ is irreducible
in $K[X]$. This is the matrix-group analogue of a symmetric-group generation
certificate: it isolates elements whose algebraic structure guarantees
usefulness for generation.

**Definition 2.3 (Certificate density).** For a finite group $G$ and a
decidable predicate $C : G \to \mathrm{Prop}$, the *certificate density* is the
rational number

$$
\mathrm{density}(C) \;=\; \frac{\#\{g \in G : C(g)\}}{\#G} \in \mathbb{Q}.
$$

This is the quantitative input to probabilistic generation arguments: higher
density yields stronger guarantees that random sampling lands on certified
elements.

**Definition 2.4 (Generation certificate system).** For a group $G$, a
*generation certificate system* consists of a predicate
$\mathrm{Cert} : G \to \mathrm{Prop}$ together with the guarantee that for every
$g$ with $\mathrm{Cert}(g)$ and every subgroup $H \leq G$ containing $g$,

$$
H = G \quad\text{or}\quad [G : H] \leq 2.
$$

This abstracts the common pattern shared by symmetric-group certificates
(Dixon) and linear-group certificates (Singer): a certified element forces any
containing subgroup to be everything, or at most an index-two near-miss.

---

## 3. Technical lemmas: transferring polynomial identities under restriction

The proof of the main theorem rests on understanding how an endomorphism's
polynomial identities behave under restriction to an invariant subspace. Let
$\varphi \in \mathrm{End}_K(V)$ and let $W$ be $\varphi$-invariant. Invariance
lets us define the *restriction* $\varphi|_W \in \mathrm{End}_K(W)$ by
$\varphi|_W(w) = \varphi(w)$, which is well defined precisely because
$\varphi(w) \in W$.

**Lemma 3.1 (Restriction intertwines the inclusion).** With $\iota_W : W
\hookrightarrow V$ the inclusion,

$$
\iota_W \circ \varphi|_W \;=\; \varphi \circ \iota_W .
$$

*Proof sketch.* Both sides send $w \in W$ to $\varphi(w)$, by the definition of
the restriction and of the inclusion. $\square$

**Lemma 3.2 (Restriction inherits annihilating polynomials).** Let $p \in K[X]$
with $p(\varphi) = 0$ (evaluation in the endomorphism algebra). Then

$$
p(\varphi|_W) = 0 .
$$

*Proof sketch.* By Lemma 3.1 and induction on $k$, the $k$-th power satisfies
$(\varphi|_W)^k(w) = \varphi^k(w)$ for all $w \in W$. Writing $p = \sum_k a_k
X^k$ and evaluating, $p(\varphi|_W)(w) = \sum_k a_k \varphi^k(w) = p(\varphi)(w)
= 0$ for every $w \in W$. Hence $p(\varphi|_W) = 0$ as an endomorphism of $W$.
$\square$

**Lemma 3.3 (Minimal polynomial divides under restriction).**

$$
\mu_{\varphi|_W} \,\mid\, \mu_\varphi .
$$

*Proof sketch.* By Lemma 3.2 applied to $p = \mu_\varphi$ (which annihilates
$\varphi$ by definition), we have $\mu_\varphi(\varphi|_W) = 0$. Since
$\mu_{\varphi|_W}$ is the minimal annihilating polynomial of $\varphi|_W$, it
divides any annihilating polynomial, in particular $\mu_\varphi$. $\square$

**Lemma 3.4 (Irreducible charpoly forces $\mu = \chi$).** If $\chi_\varphi$ is
irreducible then

$$
\mu_\varphi = \chi_\varphi .
$$

*Proof sketch.* When $V$ is nonzero, $\mu_\varphi$ divides $\chi_\varphi$ (a
standard consequence of Cayley–Hamilton, $\chi_\varphi(\varphi) = 0$), both are
monic, and $\chi_\varphi$ is irreducible; a monic irreducible polynomial has, up
to units, only itself and constants as divisors, and $\mu_\varphi$ is nonconstant
on a nonzero space, so $\mu_\varphi = \chi_\varphi$. The degenerate case $V = 0$
is handled separately: there $\varphi = 0$ and $\chi_\varphi$ would be a unit or
of degree $\leq 1$, contradicting irreducibility, so the case is vacuous.
$\square$

These four lemmas isolate the only nontrivial algebra in the development.
Everything else is dimension bookkeeping.

---

## 4. Main theorem: irreducible characteristic polynomial implies irreducible action

**Theorem 4.1 (Irreducible Action Theorem).** Let $V$ be a finite-dimensional
$K$-vector space and $\varphi \in \mathrm{End}_K(V)$ with $\chi_\varphi$
irreducible. Then for every $\varphi$-invariant submodule $W \subseteq V$,

$$
W = \{0\} \quad\text{or}\quad W = V .
$$

*Proof sketch.* Suppose $W$ is $\varphi$-invariant and $W \neq \{0\}$; we show
$W = V$. Consider the restriction $\varphi|_W$.

1. *The restricted minimal polynomial is the full $\chi_\varphi$.* By Lemma 3.3,
   $\mu_{\varphi|_W} \mid \mu_\varphi$, and by Lemma 3.4, $\mu_\varphi =
   \chi_\varphi$, so $\mu_{\varphi|_W} \mid \chi_\varphi$. Because $W \neq
   \{0\}$, the restricted map acts on a nonzero space, so $\mu_{\varphi|_W} \neq
   1$. Since $\chi_\varphi$ is irreducible and $\mu_{\varphi|_W}$ is a monic
   nonconstant divisor of it, $\mu_{\varphi|_W} = \chi_\varphi$.

2. *Dimension counting.* The degree of the minimal polynomial of any
   endomorphism is at most the dimension of the space it acts on (it divides
   the characteristic polynomial of that restricted map, whose degree equals
   $\dim W$). Hence

   $$
   \dim_K W \;\geq\; \deg \mu_{\varphi|_W} \;=\; \deg \chi_\varphi \;=\; \dim_K V .
   $$

   Combined with $\dim_K W \leq \dim_K V$ (as $W \subseteq V$), we get
   $\dim_K W = \dim_K V$, and therefore $W = V$. $\qquad\blacksquare$

The theorem is sharp in its hypotheses. Irreducibility cannot be weakened to,
say, having no repeated roots: a diagonalizable map with distinct eigenvalues in
$K$ has many invariant lines. And the field must be one over which the
characteristic polynomial can genuinely be irreducible of degree $> 1$; over an
algebraically closed field the theorem is non-vacuous only in dimension one.

---

## 5. Corollaries across three domains

### 5.1 Coding theory: orbit spanning

**Lemma 5.1 (Orbit span is invariant).** For any $\varphi \in \mathrm{End}_K(V)$
and any $v \in V$, the subspace

$$
\mathrm{span}_K \{\,\varphi^m v : m \in \mathbb{N}\,\}
$$

is $\varphi$-invariant.

*Proof sketch.* On a generator $\varphi^m v$, applying $\varphi$ yields
$\varphi^{m+1} v$, again a generator; invariance extends to the whole span by
linearity. $\square$

**Theorem 5.2 (Orbit Spanning Theorem).** If $\chi_\varphi$ is irreducible and
$v \neq 0$, then

$$
\mathrm{span}_K \{\,\varphi^m v : m \in \mathbb{N}\,\} = V .
$$

*Proof sketch.* The orbit span is invariant (Lemma 5.1), hence $\{0\}$ or $V$
(Theorem 4.1). It contains $v = \varphi^0 v \neq 0$, so it is not $\{0\}$;
therefore it is $V$. $\square$

This is the algebraic backbone of *linear feedback shift registers* and *cyclic
codes*: an irreducible (indeed primitive) connection polynomial makes the state
orbit visit a maximal spanning sequence, the source of maximal-length
pseudorandom sequences and of cyclic codes generated by a single polynomial.

### 5.2 Finite geometry: Singer cycles

**Theorem 5.3 (No Fixed Proper Projective Subspace).** If $\chi_\varphi$ is
irreducible, there is no submodule $W$ with $\{0\} \neq W \neq V$ that is
$\varphi$-invariant.

*Proof sketch.* Immediate contrapositive of Theorem 4.1: such a $W$ would be a
$\varphi$-invariant submodule equal to neither $\{0\}$ nor $V$. $\square$

In projective terms, an endomorphism with irreducible fingerprint induces a
collineation of $\mathrm{PG}(n-1, q)$ fixing no proper projective subspace — a
*Singer cycle*, after Singer's 1938 demonstration that such maps permute the
points of a finite projective space in a single cycle. Singer cycles are the
most transitive collineations a finite projective geometry admits.

### 5.3 Group theory: certificate density and generation

**Theorem 5.4 (Generation Lower Bound from Certificate Density).** Let $G$ be a
finite group and $C : G \to \mathrm{Prop}$ a decidable predicate with at least
one $g$ satisfying $C(g)$. Then

$$
\mathrm{density}(C) > 0 .
$$

*Proof sketch.* The numerator $\#\{g : C(g)\}$ is positive because the witness
$g$ inhabits the subtype, and the denominator $\#G$ is positive because $G$
contains the identity; the quotient of two positive naturals, cast to
$\mathbb{Q}$, is positive. $\square$

Modest as it is, this lemma is the formal hinge of every probabilistic
generation argument: once a constant fraction of $G$ is certified, independent
random draws hit certified elements with overwhelming probability, and certified
elements — by Definition 2.4 — force the generated subgroup to be (almost) all
of $G$.

### 5.4 Specialization to prime fields

**Theorem 5.5 (Singer certificate over $\mathbb{F}_p$).** Let $p$ be prime and
$V$ a finite-dimensional $\mathbb{F}_p$-vector space. If $\varphi \in
\mathrm{End}_{\mathbb{F}_p}(V)$ has irreducible $\chi_\varphi$, then every
$\varphi$-invariant submodule is $\{0\}$ or $V$.

*Proof sketch.* Direct instantiation of Theorem 4.1 with $K = \mathbb{F}_p =
\mathbb{Z}/p\mathbb{Z}$. $\square$

This is the case of greatest computational importance, since prime-field
matrices are the workhorses of computational group theory and cryptography.

---

## 5.5 A worked example over $\mathbb{F}_5$

To make the mechanism concrete, take $K = \mathbb{F}_5$ and the companion matrix
of the polynomial $X^2 + X + 1$,

$$
A = \begin{pmatrix} 0 & 4 \\ 1 & 4 \end{pmatrix} \in M_2(\mathbb{F}_5),
$$

whose characteristic polynomial is exactly $\chi_A(X) = X^2 + X + 1$. This
quadratic has no root in $\mathbb{F}_5$ (one checks $x^2 + x + 1 \not\equiv 0$
for $x = 0,1,2,3,4$), hence it is irreducible. By Theorem 4.1, $A$ has no
invariant line. Indeed, an invariant line would be spanned by an eigenvector,
and the absence of eigenvalues in $\mathbb{F}_5$ rules this out. Correspondingly,
the orbit of, say, $v = (1,0)^\top$ is

$$
v = (1,0)^\top,\quad Av = (0,1)^\top,
$$

which are already linearly independent and so span all of $\mathbb{F}_5^2$,
confirming Theorem 5.2. By contrast, the companion matrix of the *reducible*
polynomial $X^2 - 1 = (X-1)(X+1)$,

$$
B = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix},
$$

fixes the two eigenlines spanned by $(1,1)^\top$ and $(1,-1)^\top$, so it admits
nontrivial invariant subspaces — exactly the non-certified case. This dichotomy
is the empirical content reproduced by the accompanying numerical demonstrations.

## 6. Algorithms

The theory translates directly into certification procedures.

**Algorithm A (Certify irreducible action).** *Input:* a matrix $A \in
M_n(\mathbb{F}_q)$. *Output:* a boolean certifying that $A$ has no nontrivial
invariant subspace.

1. Compute $\chi_A(X) = \det(X I - A) \in \mathbb{F}_q[X]$ (e.g. by the
   Faddeev–LeVerrier recurrence or fraction-free Gaussian elimination),
   $O(n^3)$ field operations.
2. Test $\chi_A$ for irreducibility over $\mathbb{F}_q$ (e.g. Rabin's test:
   verify $X^{q^n} \equiv X$ and $\gcd(X^{q^{n/\ell}} - X,\, \chi_A) = 1$ for
   each prime $\ell \mid n$), polynomial time in $n$ and $\log q$.
3. Return *true* iff $\chi_A$ is irreducible.

By Theorem 4.1, a *true* verdict is a sound certificate of irreducible action.

**Algorithm B (Orbit-span verification).** *Input:* $A \in M_n(\mathbb{F}_q)$,
nonzero $v \in \mathbb{F}_q^n$. *Output:* the dimension of the orbit span.

1. Initialize a list with $v$; maintain a row-echelon basis.
2. Repeatedly append $A^m v$, reducing against the current basis; stop when a
   new iterate is linearly dependent (which must occur within $n$ steps).
3. Return the basis size.

By Theorem 5.2, if $\chi_A$ is irreducible and $v \neq 0$ the returned dimension
is exactly $n$; this gives an independent empirical check of the theorem.

**Algorithm C (Certificate-density estimate).** *Input:* a finite group $G$
(given by efficient sampling) and predicate $C$. *Output:* a Monte-Carlo
estimate of $\mathrm{density}(C)$.

1. Draw $N$ independent uniform samples $g_1, \dots, g_N$ from $G$.
2. Return $\frac{1}{N}\sum_i \mathbf{1}[C(g_i)]$.

For $C(g) = $ "$\chi_g$ is irreducible," Theorem 5.4 guarantees the true density
is positive, and the conjectures of §8 predict its asymptotics.

---

## 7. Applications

- **Cryptography.** Maximal-period linear feedback shift registers require a
  connection polynomial that is irreducible (indeed primitive); Theorem 5.2
  certifies the spanning property that yields maximal-length sequences for
  stream ciphers and pseudorandom generators. Densely certified matrix groups
  underpin randomized key-agreement and hashing constructions.

- **Coding theory.** Cyclic codes are exactly the ideals of $\mathbb{F}_q[X] /
  (X^m - 1)$, generated by a single polynomial; irreducible-fingerprint shifts
  give minimal cyclic codes and BCH-type constructions with controlled distance.

- **Computational group theory.** The recognition algorithms of Neumann–Praeger
  and successors rely on finding elements with irreducible (or "ppd") action to
  pin down the isomorphism type of an unknown matrix group; Algorithm A is
  precisely the certification step, and Theorem 5.4 supplies the density
  guarantee that randomized search terminates quickly.

- **Finite geometry.** Singer cycles (Theorem 5.3) organize $\mathrm{PG}(n-1,q)$
  as a single orbit, the foundation of difference-set and perfect-difference
  family constructions.

---

## 8. Conjectures and future directions

The formal development records two conjectures that quantify the qualitative
theory above.

**Conjecture A (Linear certificate-density lower bound).** For fixed prime power
$q$ and growing $n$, the density of elements of $\mathrm{GL}_n(\mathbb{F}_q)$
with irreducible characteristic polynomial satisfies

$$
\frac{\#\{\,g \in \mathrm{GL}_n(\mathbb{F}_q) : \chi_g \text{ irreducible}\,\}}
     {\#\mathrm{GL}_n(\mathbb{F}_q)} \;\geq\; \frac{c_q}{n}
$$

for some constant $c_q > 0$. (The expected leading behavior is $\sim 1/n$, in
analogy with the proportion of irreducible monic polynomials of degree $n$,
$\approx 1/n$ by the prime-polynomial theorem.)

**Conjecture B (Certificate sufficiency for high-probability generation).** For
random $g, h \in \mathrm{GL}_n(\mathbb{F}_q)$, if $\chi_g$ is irreducible and
$\det(h)$ generates $\mathbb{F}_q^\times$, then

$$
\Pr[\,\langle g, h\rangle = \mathrm{GL}_n(\mathbb{F}_q)\,] \;\geq\; 1 - O(q^{-1}).
$$

Further directions naturally suggested by the framework:

1. **From $\mathrm{End}$ to $\mathrm{GL}$.** Promote the certificate from a
   structural statement about a single endomorphism to a quantitative bound on
   pairs, formalizing Conjecture B via the irreducible-action of $g$ together
   with the determinant condition on $h$.
2. **Primitive prime divisor (ppd) certificates.** Replace plain irreducibility
   with the weaker, denser ppd condition of Neumann–Praeger, broadening the
   certified class while preserving the generation guarantee.
3. **Effective density bounds.** Make $c_q$ in Conjecture A explicit using
   cycle-index / generating-function machinery for $\mathrm{GL}_n(\mathbb{F}_q)$,
   yielding concrete sample-complexity bounds for Algorithm C.
4. **Tensor and wreath structures.** Extend the no-invariant-subspace criterion
   to modules with extra structure (tensor decompositions, imprimitivity
   blocks), matching the Aschbacher class analysis used in matrix-group
   recognition.
5. **Projective and unitary analogues.** Transport the Singer-cycle statement
   (Theorem 5.3) to other classical groups, certifying maximal collineations in
   symplectic, orthogonal, and unitary geometries.

---

## 8.1 On the role of the finite field

The theory is genuinely a finite-field phenomenon. Over $\mathbb{C}$, or any
algebraically closed field, every polynomial of degree $\geq 2$ factors, so the
only endomorphisms with irreducible characteristic polynomial act on
one-dimensional spaces and Theorem 4.1 is vacuous beyond $n = 1$. Over
$\mathbb{R}$ irreducible quadratics exist (e.g. rotations), giving genuine
two-dimensional examples, but no higher-degree irreducibles. It is precisely
over finite fields $\mathbb{F}_q$ — where irreducible polynomials of *every*
degree $n$ exist, and in abundance ($\approx q^n/n$ of them) — that the theorem
becomes a rich source of irreducible actions in all dimensions. This is also
why the construction matters computationally: finite fields are the arena of
coding theory, cryptography, and computational group theory, and the existence
of irreducible polynomials of every degree is what makes Singer cycles, maximal
shift registers, and densely generated matrix groups possible.

It is instructive to relate the theorem to the $K[X]$-module viewpoint. The
pair $(V, \varphi)$ is a module over the principal ideal domain $K[X]$, with
$X$ acting as $\varphi$. Invariant subspaces are exactly $K[X]$-submodules, so
Theorem 4.1 says: *if $\chi_\varphi$ is irreducible, then $(V, \varphi)$ is a
simple $K[X]$-module.* By the structure theorem, $(V,\varphi) \cong
K[X]/(\mu_\varphi)$ when the module is cyclic, and $K[X]/(f)$ is a field — hence
simple — exactly when $f$ is irreducible. Our development reaches the same
conclusion by an elementary minimal-polynomial-and-dimension argument that
avoids invoking the full structure theorem, which keeps the formal proof short
and its dependencies light.

## 9. Discussion

The conceptual content of this work is a reduction: a property quantified over
all subspaces (irreducible action) becomes a single polynomial-time algebraic
test (irreducibility of $\chi_\varphi$). The reduction is not new mathematics —
it is folklore that an irreducible characteristic polynomial yields a cyclic,
irreducible module — but rendering it as a clean chain of formally verified
lemmas, and surrounding it with the certificate abstractions (Definitions
2.2–2.4) that connect it to the random-generation literature, gives a reusable,
trustworthy core. The technical heart is small and robust: Cayley–Hamilton, the
inheritance of annihilating polynomials under restriction (Lemma 3.2), and
dimension counting. Everything domain-specific — coding theory, finite geometry,
group theory — is a corollary obtained by reinterpreting the same structural
fact. We regard this economy as the main strength of the framework: one theorem,
formally certified, paying dividends across four neighboring fields.

---

## References

- Dixon, J. D. (1969). *The probability of generating the symmetric group.*
  Mathematische Zeitschrift, 110, 199–205.
- Huppert, B. (1967). *Endliche Gruppen I.* Springer.
- Neumann, P. M., Praeger, C. E. (1992). *A recognition algorithm for special
  linear groups.* Proc. London Math. Soc., 65(3), 555–603.
- Singer, J. (1938). *A theorem in finite projective geometry and some
  applications to number theory.* Trans. Amer. Math. Soc., 43, 377–385.
