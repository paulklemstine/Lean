# The Extrinsic Class-Group Representation Vector is a Residue Dial

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $D < 0$ be a discriminant, let $Q_1,\dots,Q_h$ be the reduced binary
quadratic forms of discriminant $D$, and for an integer $N$ define the
**representation vector**
$$r_D(N) = \big(\#\{(x,y)\in\mathbb{Z}^2 : Q_1(x,y)=N\},\ \dots,\ \#\{(x,y)\in\mathbb{Z}^2 : Q_h(x,y)=N\}\big).$$
Because $D$ is chosen independently of $N$ (it is *extrinsic*), $r_D(N)$ is
computable in time polynomial in $|D|$ and $\sqrt{N}$ with no factorization of
$N$, and one may ask whether the individual entries of $r_D(N)$ feel the
*separate* Legendre symbols $(D/p)$, $(D/q)$ of the prime factors of a semiprime
$N = pq$, thereby distinguishing factorization types that share the same residue
$N \bmod |D|$.

We prove that for $D=-20$ and $D=-84$ the answer is negative in the strongest
possible sense: the vector is a **pure residue dial**. We isolate the mechanism
in an abstract structure — a family of representability predicates equipped with
pairwise disjoint sets of admissible residues modulo $m$ — and show that any such
family is *factor-blind*: the observed class index is a function of $N \bmod m$
alone. We verify the hypotheses for $D=-20$ (class group $\mathbb{Z}/2$) and
$D=-84$ (class group $(\mathbb{Z}/2)^2$) by finite computations in
$\mathbb{Z}/20$ and $\mathbb{Z}/84$, realize Gauss composition by explicit
bilinear identities, and exhibit certified collisions: the representation
vectors of $21 = 3\cdot 7$ and $1189 = 29\cdot 41$ are both $(8,0)$ despite
opposite factorization types, and $253 = 11\cdot 23$, $589 = 19\cdot 31$ are both
$(8,0,0,0)$ at $D=-84$.

Three further results delimit the phenomenon. First, we prove the mechanism is
closed under products: the joint observation of two residue dials modulo $m_1$
and $m_2$ is a residue dial modulo $m_1m_2$, so *stacking discriminants* — hint
amplification — cannot escape the collapse; the stacked $(-20,-84)$ dial has
eight positions, modulus $1680$, and still confuses $109\cdot 421$ with
$23\cdot 107$. Second, we quantify the loss: in any finite group the fibre of
multiplication over a point has exactly $|G|$ elements, so an observation
reporting only the product of two prime classes is $|\mathrm{Cl}(D)|$-to-one on
pairs and retains at most $\log_2|\mathrm{Cl}(D)|$ bits — bits that are already
determined by $N \bmod |D|$. Third, we locate the boundary: at $D=-23$ (class
number $3$, one genus) the forms $x^2+xy+6y^2$ and $2x^2+xy+3y^2$ represent
*exactly the same* residues modulo $23$, and representability is provably not a
residue condition, since $59 \equiv 13 \pmod{23}$ with $59$ principal and $13$
not. Consequently no residue dial modulo $23$ contains both forms.

The picture that emerges is a conservation law: the representation vector is
cheap precisely when it is a residue dial, hence factor-blind, and it is
informative precisely when computing it is a question about splitting in the
Hilbert class field. We formulate this as the **Idoneal Dichotomy** conjecture.

**Keywords:** binary quadratic forms, class group, genus theory, Gauss
composition, idoneal numbers, representation numbers, integer factorization,
residue characters.

---

## 1. Introduction

### 1.1 The classical setting

A *binary quadratic form* is a homogeneous polynomial
$Q(x,y) = ax^2+bxy+cy^2$ with $a,b,c\in\mathbb{Z}$; its *discriminant* is
$D = b^2-4ac$. Throughout, $D<0$ and forms are positive definite ($a>0$). Two
forms are *equivalent* if one is carried to the other by an element of
$\mathrm{SL}_2(\mathbb{Z})$; equivalent forms represent the same integers.
Each equivalence class contains exactly one *reduced* representative, characterized
by $|b|\le a\le c$, with $b\ge 0$ when $|b|=a$ or $a=c$. The number of reduced
forms of discriminant $D$ is the **class number** $h(D)$, and the set of classes
carries Gauss's composition law, making it the **class group** $\mathrm{Cl}(D)$,
a finite abelian group.

We write $N$ for the integer under study, and we call $D$ *extrinsic* to
emphasize that $D$ is chosen in advance, with no reference to $N$ and in
particular no knowledge of $N$'s factorization.

**Definition 1.1 (Representation vector).** For a discriminant $D<0$ with
reduced forms $Q_1,\dots,Q_h$ and an integer $N$, set
$$r_D(N) := \big(r_{Q_1}(N),\dots,r_{Q_h}(N)\big), \qquad
r_{Q}(N) := \#\{(x,y)\in\mathbb{Z}^2 : Q(x,y)=N\}.$$

The vector is *computationally cheap*: since $Q_i$ is positive definite of
discriminant $D$, every solution of $Q_i(x,y)=N$ satisfies
$|y| \le 2\sqrt{N/|D|}$ and $|x| \le O(\sqrt{N/a_i})$, so a direct scan runs in
time $O(\sqrt{N/|D|}\cdot \mathrm{polylog})$ per form, and standard methods reduce
this to $\mathrm{poly}(|D|,\log N)$ arithmetic on the class group given only the
representability question. Crucially, no factorization of $N$ enters.

### 1.2 The hypothesis under test

If $p \nmid 2D$ is prime and $(D/p) = 1$, then $p$ is represented by exactly one
class $[\mathfrak p] \in \mathrm{Cl}(D)$ (up to inversion), and for a semiprime
$N = pq$ with both $p,q$ split, $N$ is represented by the product class
$[\mathfrak p][\mathfrak q]$ (again up to the ambiguity of choosing primes above
$p$ and $q$). The tempting inference is:

> *The entries of $r_D(N)$ respond to $(D/p)$ and $(D/q)$ separately, so the
> vector should separate factorization types — e.g. "both factors principal"
> (PP) from "both factors non-principal" (NN) — even when the two semiprimes
> share the same residue modulo $|D|$.*

If true, this would extract factorization-type information from $N$ in
polynomial time with no factoring: a *free witness*.

### 1.3 Results

We show the inference fails, and we characterize why.

1. **(Theorem 3.4, Theorem 4.3)** At $D=-20$ and $D=-84$ the class index of $N$
   (coprime to $D$) is a function of $N \bmod |D|$.
2. **(Theorem 2.4)** The mechanism is abstract: *soundness* plus *disjointness*
   of admissible-residue sets implies factor-blindness, with an explicit readout
   function $\mathbb{Z}/m \to \{\text{classes}\}$.
3. **(Theorem 3.8, Theorem 4.6)** Consequently distinct factorization types
   collide: $r_{-20}(21) = r_{-20}(1189) = (8,0)$ although $21=3\cdot 7$ is NN
   and $1189 = 29\cdot 41$ is PP; at $D=-84$ the three types $f_2f_2$, $f_3f_3$,
   $f_4f_4$ all map to $(\ast,0,0,0)$, realized by $r_{-84}(253) = r_{-84}(589) = (8,0,0,0)$.
4. **(Theorem 3.10)** The structural cause: the dial is a *group character* on
   the admissible residues, and characters annihilate squares.
5. **(Theorem 5.2)** Dials are closed under products; hence stacking finitely
   many extrinsic discriminants remains factor-blind.
6. **(Theorem 5.5)** Exact information accounting: the multiplication fibre in a
   finite group $G$ has cardinality $|G|$.
7. **(Theorems 6.1–6.3)** The boundary: at $D=-23$ the two
   forms represent identical residue sets, representability is not
   residue-determined, and no residue dial modulo $23$ contains both forms.

---

## 2. Residue dials

### 2.1 The abstract structure

**Definition 2.1 (Residue dial).** Let $m \ge 1$ and let $I$ be an index set. A
**residue dial of modulus $m$ with index set $I$** consists of

* a family of predicates $\mathrm{Rep}_i \subseteq \mathbb{Z}$ for $i \in I$
  ("$N$ is represented by class $i$");
* a family of finite sets $S_i \subseteq \mathbb{Z}/m$ for $i \in I$;

subject to two axioms:

* **(Soundness)** if $N$ is invertible modulo $m$ and $N \in \mathrm{Rep}_i$,
  then $(N \bmod m) \in S_i$;
* **(Disjointness)** $S_i \cap S_j = \emptyset$ whenever $i \ne j$.

The two axioms are the *entire* input; everything in this section is a formal
consequence.

**Lemma 2.2 (Uniqueness of the index).** In a residue dial, if $N$ is invertible
modulo $m$ and $N \in \mathrm{Rep}_i \cap \mathrm{Rep}_j$, then $i=j$.

*Proof.* Soundness places $N \bmod m$ in both $S_i$ and $S_j$; disjointness then
forces $i=j$. $\square$

**Definition 2.3 (Readout).** For $a \in \mathbb{Z}/m$ let
$\rho(a) := $ the unique $i$ with $a \in S_i$, if such an $i$ exists (well
defined by disjointness), and an arbitrary fixed default otherwise.

**Theorem 2.4 (Factor-blindness).** Let $(\mathrm{Rep}_i, S_i)$ be a residue dial
modulo $m$. Let $N, M$ be invertible modulo $m$ with $N \equiv M \pmod m$.
If $N \in \mathrm{Rep}_i$ and $M \in \mathrm{Rep}_j$, then $i = j$. Moreover
$\rho(N \bmod m) = i$ whenever $N$ is invertible modulo $m$ and
$N \in \mathrm{Rep}_i$.

*Proof.* By soundness, $N \bmod m \in S_i$ and $M \bmod m \in S_j$; since
$N \equiv M$, the same element of $\mathbb{Z}/m$ lies in both sets, and
disjointness gives $i=j$. For the readout claim, $N \bmod m \in S_i$ shows the
defining existential holds, and the chosen witness must equal $i$ again by
disjointness. $\square$

Theorem 2.4 is the *entire refutation*, modulo verifying the axioms in each case.
It says the observation factors as
$$N \ \longmapsto\ N \bmod m \ \stackrel{\rho}{\longmapsto}\ \text{class index},$$
so no arithmetic feature of $N$ finer than its residue can be extracted. In
particular the observation is invariant under any change of factorization that
preserves $N \bmod m$.

### 2.2 Interpretation

The disjointness axiom is exactly the statement that the classes are separated by
*genus characters* — congruence conditions modulo $|D|$. Genus theory says the
group of genera is $\mathrm{Cl}(D)/\mathrm{Cl}(D)^2$, so classes are separated by
congruences precisely when every class is alone in its genus, i.e.
$h(D) = $ number of genera. Section 6 shows that when this fails, so does the
dial.

---

## 3. The discriminant $D=-20$

### 3.1 The two classes

The reduced forms of discriminant $-20$ are
$$P(x,y) = x^2+5y^2, \qquad Q(x,y) = 2x^2+2xy+3y^2,$$
with $h(-20)=2$. Write $\mathrm{Rep}_P$ and $\mathrm{Rep}_Q$ for the sets of
integers they represent.

**Theorem 3.1 (Genus characters mod $20$).** Let $N$ be coprime to $20$.
$$N \in \mathrm{Rep}_P \ \Longrightarrow\ N \equiv 1,9 \pmod{20},$$
$$N \in \mathrm{Rep}_Q \ \Longrightarrow\ N \equiv 3,7 \pmod{20}.$$

*Proof sketch.* Both statements are finite: reduce modulo $20$ and check all
$20^2$ pairs $(x \bmod 20, y \bmod 20)$, retaining only those for which the value
is a unit. One finds the value sets $\{1,9\}$ and $\{3,7\}$ respectively.
(Conceptually: $(-20/N)=1$ forces $N \equiv 1,3,7,9$, and the additional
character $N \bmod 5 \in \{\pm 1\}$ splits these four residues into the two
genera.) $\square$

**Corollary 3.2.** $\{1,9\}$ and $\{3,7\}$ are disjoint, so
$(\{\mathrm{Rep}_P, \mathrm{Rep}_Q\}, \{\{1,9\},\{3,7\}\})$ is a residue dial of
modulus $20$ indexed by $\{P,Q\}$.

**Corollary 3.3 (Exclusivity).** No integer coprime to $20$ is represented by
both $P$ and $Q$.

**Theorem 3.4 (The dial at $D=-20$).** If $N,M$ are coprime to $20$ with
$N \equiv M \pmod{20}$, and $N$ is represented by the class $i$ and $M$ by the
class $j$, then $i=j$. Explicitly, for $N$ coprime to $20$ that is represented at
all,
$$N \in \mathrm{Rep}_P \iff N \equiv 1,9 \pmod{20}, \qquad
N \in \mathrm{Rep}_Q \iff N \equiv 3,7 \pmod{20}.$$

*Proof.* Theorem 2.4 applied to Corollary 3.2, together with exclusivity for the
"if" directions. $\square$

### 3.2 Gauss composition, explicitly

**Theorem 3.5 (Composition law).** For all integers $a,b$:

* if $a,b \in \mathrm{Rep}_P$ then $ab \in \mathrm{Rep}_P$;
* if $a,b \in \mathrm{Rep}_Q$ then $ab \in \mathrm{Rep}_P$;
* if $a \in \mathrm{Rep}_P$ and $b \in \mathrm{Rep}_Q$ then $ab \in \mathrm{Rep}_Q$.

Hence the two classes form the group $\mathbb{Z}/2$ under multiplication of
represented values, with $P$ principal.

*Proof sketch.* Each case is an explicit bilinear identity, verified by expanding
both sides. The first is Brahmagupta's identity for the norm form of
$\mathbb{Z}[\sqrt{-5}]$:
$$(x_1^2+5y_1^2)(x_2^2+5y_2^2) = (x_1x_2-5y_1y_2)^2 + 5(x_1y_2+x_2y_1)^2 .$$
The second and third are the corresponding identities for the non-principal
ideal class; for instance
$$(2x_1^2+2x_1y_1+3y_1^2)(2x_2^2+2x_2y_2+3y_2^2) = u^2+5v^2$$
with $u = 2x_1x_2 + x_1y_2 + x_2y_1 - 2y_1y_2$, $v = x_1y_2+x_2y_1+y_1y_2$,
an identity checked by expansion. $\square$

### 3.3 The refutation at $D=-20$

**Definition 3.6.** The *observation* available to an algorithm that computes the
representation vector's support is
$$\mathrm{obs}(N) := \big(\,[N \in \mathrm{Rep}_P],\ [N \in \mathrm{Rep}_Q]\,\big) \in \{0,1\}^2 .$$

**Theorem 3.7 (PP $=$ NN).** Let $p,q \in \mathrm{Rep}_P$ and
$p',q' \in \mathrm{Rep}_Q$, with $pq$ and $p'q'$ coprime to $20$. Then
$$\mathrm{obs}(pq) = \mathrm{obs}(p'q') = (1,0),$$
and moreover $pq$ and $p'q'$ lie in the same pair of residue classes
$\{1,9\}$ modulo $20$.

*Proof.* By Theorem 3.5, $pq \in \mathrm{Rep}_P$ and $p'q' \in \mathrm{Rep}_P$;
by exclusivity neither is in $\mathrm{Rep}_Q$. The residue claim is Theorem 3.1.
$\square$

Thus the two "same-class" factorization types PP and NN are *indistinguishable*.
The only type the observation separates is the mixed type:

**Proposition 3.8 (Mixed type).** If $p \in \mathrm{Rep}_P$, $q\in\mathrm{Rep}_Q$
and $pq$ is coprime to $20$, then $\mathrm{obs}(pq) = (0,1)$ — but this is already
visible from $pq \equiv 3,7 \pmod{20}$, hence requires no knowledge of the
factorization.

**Theorem 3.9 (Certified collision).** With $29 = 3^2+5\cdot 2^2$,
$41 = 6^2+5\cdot 1^2$ (both principal) and $3 = 2\cdot 0^2+2\cdot 0\cdot 1+3\cdot 1^2$,
$7 = 2\cdot 1^2 + 2\cdot 1\cdot 1 + 3\cdot 1^2$ (both non-principal),
$$\mathrm{obs}(1189) = \mathrm{obs}(21).$$
Quantitatively,
$$r_{-20}(21) = (8,0), \qquad r_{-20}(1189) = (8,0), \qquad r_{-20}(87) = (0,8).$$

*Proof sketch of the counts.* Any solution of $x^2+5y^2=N$ has $x^2 \le N$ and
$5y^2 \le N$, so all solutions lie in the box $|x| \le B_x$, $|y| \le B_y$ for any
$B_x, B_y$ with $N \le B_x^2$ and $N \le 5B_y^2$; the analogous bound for
$2x^2+2xy+3y^2 = N$ follows from $2N = (2x+y)^2 + 5y^2$. Exhaustive enumeration
inside the box is therefore exact. For $21$: $21 = 1^2+5\cdot 2^2 = 4^2+5\cdot1^2$,
giving $8$ points under the sign changes $(x,y)\mapsto(\pm x,\pm y)$. For $1189$:
$1189 = 28^2+5\cdot 9^2 = 8^2+5\cdot 15^2$, again $8$. For $87$ there is no
solution of $x^2+5y^2=87$ (check $y=0,\dots,4$), while
$87 = 2\cdot 3^2+2\cdot3\cdot(-5)+3\cdot 5^2$ and its orbit give $8$. $\square$

Divisibility by $4$ of these counts is not accidental: the unit group
$\{\pm 1\}$ acting by $(x,y)\mapsto(-x,-y)$ together with the extra involution
coming from $y \mapsto -y$ on the principal form acts freely when $N$ is coprime
to $20$ and is not a perfect square, so $4 \mid r_P(N)$.

### 3.4 Why the collision is forced: the dial is a character

Let $\mathcal{D}_{20} := \{1,3,7,9\} \subseteq (\mathbb{Z}/20)^\times$ be the set
of residues with $(-20/\cdot) = 1$, i.e. those that occur at all, and define the
**dial bit**
$$\delta(a) := \begin{cases} 0 & a \in \{1,9\},\\ 1 & a \in \{3,7\}.\end{cases}$$

**Theorem 3.10 (The dial is a quadratic character).** $\mathcal{D}_{20}$ is a
subgroup of $(\mathbb{Z}/20)^\times$, and $\delta : \mathcal{D}_{20} \to \mathbb{Z}/2$
is a group homomorphism:
$$\delta(ab) = \delta(a) + \delta(b) \pmod 2 .$$
Consequently $\delta(a^2) = 0$ for every $a \in \mathcal{D}_{20}$. Moreover, for
$N$ coprime to $20$ represented by class $i$, $\delta(N \bmod 20)$ equals the
index of $i$.

*Proof.* Both the closure of $\mathcal{D}_{20}$ and the multiplicativity of
$\delta$ are finite checks on $4\times 4 = 16$ pairs. $\square$

This is the algebraic root of the collapse. A semiprime $N=pq$ whose factors lie
in the *same* class has $\delta(N) = \delta(p)+\delta(q) = 0$ regardless of which
class that is: at the level of the observation, such an $N$ is a square, and all
squares read as principal. No refinement of the vector helps, because the
observation *is* the character.

---

## 4. The discriminant $D=-84$: four classes, same conclusion

### 4.1 The classes and their residues

The reduced forms of discriminant $-84$ are
$$f_1 = x^2+21y^2,\quad f_2 = 2x^2+2xy+11y^2,\quad f_3 = 3x^2+7y^2,\quad f_4 = 5x^2+4xy+5y^2,$$
so $h(-84)=4$ and $\mathrm{Cl}(-84) \cong (\mathbb{Z}/2)^2$, the Klein
four-group. Index the classes by $(\mathbb{Z}/2)^2$ with $f_1 \leftrightarrow (0,0)$,
$f_2 \leftrightarrow (1,0)$, $f_3\leftrightarrow (0,1)$, $f_4\leftrightarrow(1,1)$.

**Theorem 4.1 (Genus characters mod $84$).** Let $N$ be coprime to $84$. Then
$$N \in \mathrm{Rep}_{f_1} \Rightarrow N \equiv 1,25,37 \pmod{84}, \qquad
N \in \mathrm{Rep}_{f_2} \Rightarrow N \equiv 11,23,71,$$
$$N \in \mathrm{Rep}_{f_3} \Rightarrow N \equiv 19,31,55, \qquad
N \in \mathrm{Rep}_{f_4} \Rightarrow N \equiv 5,17,41 .$$
The four sets are pairwise disjoint.

*Proof sketch.* Finite verification in $\mathbb{Z}/84$: enumerate all
$(x,y) \in (\mathbb{Z}/84)^2$, keep those where the form value is one of the $24$
units of $\mathbb{Z}/84$, and collect the resulting value sets. $\square$

**Corollary 4.2.** The four classes and the four residue sets constitute a
residue dial of modulus $84$ indexed by $(\mathbb{Z}/2)^2$.

**Theorem 4.3 (The dial at $D=-84$).** For $N$ coprime to $84$, at most one class
represents $N$, and which one is a function of $N \bmod 84$.

### 4.2 Composition and the collision

**Theorem 4.4 (Klein composition).** For $i,j \in (\mathbb{Z}/2)^2$ and
represented integers $a \in \mathrm{Rep}_{f_i}$, $b \in \mathrm{Rep}_{f_j}$,
$$ab \in \mathrm{Rep}_{f_{i+j}}$$
where $i+j$ is the Klein group operation (coordinatewise XOR). In particular
every class is $2$-torsion: $a,b \in \mathrm{Rep}_{f_i} \Rightarrow ab \in \mathrm{Rep}_{f_1}$.

*Proof sketch.* Ten bilinear identities, one for each unordered pair of classes,
each verified by expansion. For example $f_3\cdot f_3 \to f_1$ is
$$(3x_1^2+7y_1^2)(3x_2^2+7y_2^2) = (3x_1x_2 - 7y_1y_2)^2 + 21(x_1y_2+x_2y_1)^2 .$$
$\square$

**Theorem 4.5 (Triple collision).** Let $p_2,q_2 \in \mathrm{Rep}_{f_2}$,
$p_3,q_3 \in \mathrm{Rep}_{f_3}$, $p_4,q_4 \in \mathrm{Rep}_{f_4}$, with each
product coprime to $84$. Then all three products have the same observation vector
$$(1,0,0,0),$$
i.e. represented by the principal form and by nothing else. Three distinct
factorization types, one observation.

*Proof.* Every class squares to the principal class (Theorem 4.4), so each
product lies in $\mathrm{Rep}_{f_1}$; by Theorem 4.3 no other class can represent
it. $\square$

**Theorem 4.6 (Certified collision).**
$$253 = 11 \cdot 23 \ (\text{type } f_2 f_2), \qquad 589 = 19 \cdot 31 \ (\text{type } f_3f_3),$$
both $\equiv 1 \pmod{84}$, and
$$r_{-84}(253) = r_{-84}(589) = (8,0,0,0).$$

*Proof sketch.* $253 = 13^2 + 21\cdot 2^2 = 8^2+21\cdot 3^2$ and
$589 = 20^2+21\cdot 3^2 = 8^2 + 21\cdot 5^2$; each gives an orbit of $4$ under
sign changes, total $8$. Exhaustiveness follows from the box bound
$x^2 \le N$, $21y^2 \le N$. The zero entries are forced by Theorem 4.3. $\square$

Increasing the class number produced *more* collisions, not fewer: with $h=4$
there are three same-class types instead of one, all of which merge.

---

## 5. Stacking discriminants, and the exact information budget

### 5.1 Dials are closed under products

The natural rescue is *hint amplification*: use several extrinsic discriminants
$D_1,\dots,D_k$ and concatenate. The following says this changes nothing.

**Definition 5.1 (Product dial).** Given residue dials
$(\mathrm{Rep}^{(1)}_i, S^{(1)}_i)$ of modulus $m_1$ with index set $I_1$ and
$(\mathrm{Rep}^{(2)}_j, S^{(2)}_j)$ of modulus $m_2$ with index set $I_2$, define
for $(i,j) \in I_1\times I_2$
$$\mathrm{Rep}_{(i,j)} := \mathrm{Rep}^{(1)}_i \cap \mathrm{Rep}^{(2)}_j, \qquad
S_{(i,j)} := \{ a \in \mathbb{Z}/m_1m_2 : \pi_1(a) \in S^{(1)}_i,\ \pi_2(a) \in S^{(2)}_j \},$$
where $\pi_1 : \mathbb{Z}/m_1m_2 \to \mathbb{Z}/m_1$ and
$\pi_2 : \mathbb{Z}/m_1m_2 \to \mathbb{Z}/m_2$ are the reduction maps.

**Theorem 5.2 (Tensoring).** The above data is a residue dial of modulus
$m_1m_2$ with index set $I_1 \times I_2$.

*Proof.* *Soundness*: if $N$ is invertible modulo $m_1m_2$, its reductions are
invertible modulo $m_1$ and $m_2$ (apply the ring maps $\pi_1,\pi_2$ to an
inverse), and $N \in \mathrm{Rep}^{(1)}_i \cap \mathrm{Rep}^{(2)}_j$; soundness of
each factor places $\pi_1(N) \in S^{(1)}_i$ and $\pi_2(N) \in S^{(2)}_j$, i.e.
$N \bmod m_1m_2 \in S_{(i,j)}$. *Disjointness*: if $(i_1,i_2) \ne (j_1,j_2)$ they
differ in some coordinate, say the first; then a common element $a$ would give
$\pi_1(a) \in S^{(1)}_{i_1} \cap S^{(1)}_{j_1} = \emptyset$. $\square$

**Corollary 5.3 (Stacking stays blind).** The joint class index under any finite
family of residue dials is a function of $N$ modulo the product of the moduli.
No finite family of extrinsic discriminants gives an asymmetric handle on $N$.

**Example 5.4 (The $(-20,-84)$ stack).** Stacking the two dials above yields a
residue dial of modulus $1680$ with $2 \times 4 = 8$ index positions, of which
exactly $4$ are occupied: since $\gcd(20,84)=4$ and the residue sets
$\{1,9\}$, $\{1,25,37\}$, $\{5,17,41\}$ consist of $1 \bmod 4$ while
$\{3,7\}$, $\{11,23,71\}$, $\{19,31,55\}$ consist of $3\bmod 4$, the two
genus readings must agree modulo $4$. The PP/NN
collision survives: if $p,q$ are principal for both discriminants and $p',q'$ are
in the non-principal classes $Q$ and $f_2$ for the two discriminants
respectively, then $pq$ and $p'q'$ both receive the joint index
$(\text{principal},\text{principal})$. The hypotheses are satisfiable:
$$109 = 8^2+5\cdot 3^2 = 5^2+21\cdot 2^2, \qquad 421 = 4^2+5\cdot 9^2 = 20^2+21\cdot 1^2$$
are principal for both, while
$$23 = 2(-1)^2+2(-1)(3)+3\cdot 3^2 = 2\cdot 2^2+2\cdot 2\cdot 1+11\cdot 1^2,$$
$$107 = 2\cdot 5^2+2\cdot 5\cdot 3 + 3\cdot 3^2 = 2\cdot 1^2 + 2\cdot 1\cdot 3 + 11\cdot 3^2$$
are non-principal for both. Hence the joint observation confuses
$109\cdot 421 = 45889$ with $23 \cdot 107 = 2461$.

### 5.2 The information budget

Even in the readable regime, the observation reports only the *product* of the
two prime classes. How much can such a report say?

**Theorem 5.5 (Multiplication fibres).** Let $G$ be a finite group and $c \in G$.
Then
$$\#\{(g_1,g_2) \in G\times G : g_1g_2 = c\} = |G| .$$

*Proof.* The map $(g_1,g_2)\mapsto g_1$ is a bijection onto $G$ with inverse
$g \mapsto (g, g^{-1}c)$. $\square$

**Corollary 5.6.** For $\mathrm{Cl}(-20) \cong \mathbb{Z}/2$ every observation is
compatible with exactly $2$ ordered pairs of factor classes (the PP/NN collision);
for $\mathrm{Cl}(-84) \cong (\mathbb{Z}/2)^2$, with exactly $4$.

Thus an observation of the product class retains at most
$\log_2|\mathrm{Cl}(D)|$ bits about the pair $([\mathfrak p],[\mathfrak q])$ —
one bit at $D=-20$, two at $D=-84$ — and by Theorem 2.4 those bits are already a
function of $N \bmod |D|$, hence available without any reference to the factors.
The net factorization information is zero.

---

## 6. Where the dial stops: $D = -23$

Everything above depended on *disjointness*, which is genus theory: classes are
separated by congruences exactly when each genus contains one class. Both $-20$
and $-84$ have this property ($h = $ number of genera; these are
idoneal-type discriminants). We now show the phenomenon is *exactly* a
one-class-per-genus phenomenon by exhibiting a discriminant where it provably
fails.

Take $D = -23$: $h(-23) = 3$, $\mathrm{Cl}(-23) \cong \mathbb{Z}/3$, and there is
a **single genus** (a group of odd order has trivial quotient by squares). The
reduced forms are
$$P_{23} = x^2+xy+6y^2, \qquad Q_{23} = 2x^2+xy+3y^2, \qquad \bar Q_{23} = 2x^2-xy+3y^2,$$
the latter two being inverse classes representing the same integers.

**Theorem 6.1 (No genus separation).** For every $a \in \mathbb{Z}/23$,
$$\exists\, x,y \in \mathbb{Z}/23 : x^2+xy+6y^2 = a \iff \exists\, x,y\in\mathbb{Z}/23 : 2x^2+xy+3y^2 = a .$$
The two forms have *identical* value sets modulo $23$.

*Proof.* Finite check over $\mathbb{Z}/23$. (Conceptually: modulo the prime $23$
the two forms become equivalent nondegenerate binary forms of the same
determinant class, hence surjective onto $\mathbb{Z}/23$ in the same way.) $\square$

So no choice of residue sets can separate the classes — the residue sets one
would have to use are equal, and equal nonempty sets are not disjoint. But one
might hope that some *coarser* congruence still detects representability. It does
not:

**Theorem 6.2 (Representability is not residue-determined at $-23$).** There exist
integers $N, M$ coprime to $23$ with $N \equiv M \pmod{23}$ such that $N$ is
represented by $P_{23}$, $M$ is not represented by $P_{23}$, and $M$ is
represented by $Q_{23}$. Explicitly $N = 59$, $M = 13$:
$$59 \equiv 13 \pmod{23}, \qquad 59 = 5^2 + 5\cdot 2 + 6\cdot 2^2, \qquad 13 = 2\cdot 2^2 + 2\cdot 1 + 3\cdot 1^2,$$
and $13 \ne x^2+xy+6y^2$ for all integers $x,y$.

*Proof.* The two representations are direct computations. For the negative
statement, multiply by $4$: $x^2+xy+6y^2 = 13$ is equivalent to
$(2x+y)^2 + 23y^2 = 52$, which forces $23y^2 \le 52$, i.e. $|y| \le 1$, and then
$(2x+y)^2 \le 52$, giving $|x| \le 4$. A finite search over
$x \in [-4,4]$, $y\in[-1,1]$ finds no solution. $\square$

**Theorem 6.3 (No residue dial at $D=-23$).** There is no residue dial of modulus
$23$ (with any index set) whose family of predicates includes both
$\mathrm{Rep}_{P_{23}}$ and $\mathrm{Rep}_{Q_{23}}$ at distinct indices.

*Proof.* Suppose $(\mathrm{Rep}_\bullet, S_\bullet)$ were such a dial, with
$\mathrm{Rep}_i = \mathrm{Rep}_{P_{23}}$ and $\mathrm{Rep}_j = \mathrm{Rep}_{Q_{23}}$.
Take $N=59$, $M=13$ from Theorem 6.2; both are coprime to $23$. Soundness gives
$59 \bmod 23 \in S_i$ and $13 \bmod 23 \in S_j$, and these are the same element of
$\mathbb{Z}/23$. Disjointness then forces $i=j$, whence
$\mathrm{Rep}_{P_{23}} = \mathrm{Rep}_{Q_{23}}$, contradicting
$13 \in \mathrm{Rep}_{Q_{23}} \setminus \mathrm{Rep}_{P_{23}}$. $\square$

This is a genuine boundary, not an artifact: the mechanism that collapses
$D=-20$ and $D=-84$ is *false* at $D=-23$.

---

## 7. Algorithms

Three procedures are implicit in the results and are worth stating.

### 7.1 Enumerating a representation vector with a certified box

**Input:** a positive definite reduced form $Q = ax^2+bxy+cy^2$ of discriminant
$D<0$, an integer $N>0$.
**Output:** the exact count $r_Q(N)$.

Completing the square gives $4a\,Q(x,y) = (2ax+by)^2 + |D| y^2$, so any solution
satisfies
$$|y| \le \sqrt{4aN/|D|}, \qquad |2ax+by| \le \sqrt{4aN}.$$
Enumerate $y$ in that range; for each $y$, solve the quadratic in $x$ exactly by
testing whether $4aN - |D|y^2$ is a perfect square and whether the resulting
$2ax = \pm\sqrt{\cdot} - by$ is divisible by $2a$. Cost:
$O(\sqrt{aN/|D|})$ integer operations, with no factorization of $N$. This
certified box is what makes counts such as $r_{-20}(21)=8$ and
$r_{-84}(589)=8$ exact rather than heuristic.

### 7.2 Reading the dial

**Input:** $D \in \{-20,-84\}$, an integer $N$ coprime to $D$.
**Output:** the class index of $N$, or "not represented".

Compute $a = N \bmod |D|$ and look up $a$ in the precomputed table of genus
residue sets ($\{1,9\},\{3,7\}$ for $-20$; $\{1,25,37\},\{11,23,71\},\{19,31,55\},\{5,17,41\}$
for $-84$). Cost: one modular reduction. Correctness is Theorem 3.4 / 4.3. The
contrast with §7.1 *is* the refutation: the expensive computation returns exactly
what the one-line computation already knew.

### 7.3 Detecting whether a discriminant supports a dial

**Input:** a discriminant $D<0$.
**Output:** whether $r_D$ is a residue dial (equivalently, whether $D$ has one
class per genus).

Enumerate the reduced forms of discriminant $D$ (all $(a,b,c)$ with
$|b|\le a \le c$, $b^2-4ac=D$, so $a \le \sqrt{|D|/3}$), and for each form compute
its value set modulo $|D|$ restricted to units. Report "dial" if and only if the
value sets are pairwise disjoint. Cost: $O(h(D)\cdot |D|^2)$ modular operations
by brute force. Running this over $D = -4,-8,\dots$ reproduces Euler's idoneal
list and immediately flags $-23$ as the first small failure with $h>1$.

---

## 8. Discussion

### 8.1 The verdict

The hypothesis under test — that the extrinsic class-group representation vector
separates factorization types beyond $N \bmod |D|$ — is **refuted** for
$D = -20$ and $D=-84$, and the refutation is structural rather than numerical:

* the observation factors through $N \bmod |D|$ (Theorems 2.4, 3.4, 4.3);
* the mechanism is a group character, and characters annihilate squares, so any
  same-class pair of factors is invisible (Theorem 3.10);
* stacking discriminants cannot help, because dials tensor (Theorem 5.2);
* even in the best case the observation is $|\mathrm{Cl}(D)|$-to-one on class
  pairs (Theorem 5.5).

In the language of the original programme: the extrinsic discriminant is "a
residue dial", and each new $D$ is a new dial rather than a new source of
information. The corner of the free-witness taxonomy occupied by extrinsic
algebraic structure of this kind is closed for idoneal-type discriminants.

### 8.2 The shape of the barrier

Two general lessons generalize beyond quadratic forms.

**(i) Congruence-visible structure is factor-blind by construction.** Any
invariant of $N$ that is provably constant on residue classes modulo a fixed
$m$ carries at most $\log_2 \varphi(m)$ bits, all of them computable in one
modular reduction. Genus theory is exactly the congruence-visible part of the
class group, which is why the collapse is total whenever the classes are
separated by genus characters and *only* then.

**(ii) Multiplicativity is the enemy.** The observation on $N=pq$ is a product of
per-factor observations. Any homomorphic invariant loses the distinction between
$(g,g)$ and $(g',g')$, since both products are squares. Breaking factoring by
such a route requires an observable that is *not* multiplicative in the factors —
which is precisely why a residue dial cannot be one.

### 8.3 Relation to class field theory

The residue dial is the abelian, ramified shadow of the class field of
$\mathbb{Q}(\sqrt{D})$. The genus field — the maximal subextension of the Hilbert
class field abelian over $\mathbb{Q}$ — is generated by square roots of divisors
of $D$, so splitting in it is a congruence condition modulo $|D|$: that is the
dial. The rest of the Hilbert class field is non-abelian over $\mathbb{Q}$, and
determining how $N$ splits there is not a congruence question. When $h(D)$ equals
the number of genera, the class field *is* the genus field, the dial is complete,
and the observation is free but empty. Otherwise the dial is incomplete, the
observation could in principle be informative, but computing it is no longer a
residue computation. This is the trade-off that Section 9 conjectures is exact.

---

## 9. Future work

### C1. The Idoneal Dichotomy

**Conjecture.** Let $D<0$ be a discriminant and let $r_D(N)$ be the
representation vector over the reduced forms of discriminant $D$. Exactly one of
the following holds.

1. $D$ has **one class per genus** (idoneal-type). Then $r_D$, restricted to
   integers coprime to $D$ that are represented at all, is a function of
   $N \bmod |D|$ — a residue dial, computable in $\mathrm{poly}(|D|,\log N)$ and
   factor-blind.
2. $D$ has **more than one class per genus**. Then $r_D$ is *not* a function of
   $N \bmod |D|$, and no algorithm computing $r_D(N)$ in time
   $\mathrm{poly}(|D|,\log N)$ is known; a polynomial-time algorithm would yield
   the splitting behaviour of $N$ in the Hilbert class field of
   $\mathbb{Q}(\sqrt D)$.

The key insight is that genus theory is exactly the part of the class group
visible in congruences, so "readable $\iff$ idoneal" is not a coincidence but an
equivalence: the residue dial is the abelianized, ramified shadow of the class
field, and everything beyond it is non-abelian over $\mathbb{Q}$.

Both halves are non-empty by the present work: $D=-20$ and $D=-84$ realize (1),
and $D=-23$ realizes the failure required by (2).

### C2. The Hardness Dial (converse of the refutation)

**Conjecture.** For every non-idoneal $D$, computing a single entry $r_Q(N)$ of
the representation vector for a semiprime $N$ is as hard as factoring $N$: there
is a randomized polynomial-time reduction from FACTOR to the computation of
$r_Q$.

The key insight is that for non-idoneal $D$ the entry $r_Q(N)$ distinguishes the
ideal classes $[\mathfrak p][\mathfrak q]$ from $[\mathfrak p][\bar{\mathfrak q}]$,
and the difference between those two is precisely the choice of a prime above
$p$ — a choice that, for $N=pq$, encodes the splitting of $N$ in a non-abelian
extension.

Together with C1 this would upgrade "refuted for these $D$" to "refuted for all
$D$", closing the extrinsic corner unconditionally: the vector is cheap exactly
when it is useless, and useful exactly when it is expensive.

### Further directions

* **Quantifying partial dials.** For a general $D$, the genus map
  $\mathrm{Cl}(D) \to \mathrm{Cl}(D)/\mathrm{Cl}(D)^2$ splits the observation into
  a residue-readable part and a residual part of size
  $|\mathrm{Cl}(D)^2|$. Making the exact "readable bits vs. hidden bits" count
  into a theorem for arbitrary $D$ would interpolate between the two halves of
  C1.
* **Higher-degree forms.** Norm forms of higher-degree number fields also admit
  genus-type congruence obstructions. Is the analogous dial theorem true — is the
  congruence-visible part of the class group always exactly the factor-blind
  part?
* **Beyond congruence observables.** The barrier identified here is
  multiplicativity. Systematically classifying the observables of $N$ that are
  *not* multiplicative in the factors, yet still cheap, would map the remaining
  frontier.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| Factor-blindness | Soundness + disjointness of admissible residue sets $\Rightarrow$ the class index of $N$ is a function of $N \bmod m$. |
| Dial at $D=-20$ | $x^2+5y^2$ takes unit values $\equiv 1,9 \pmod{20}$; $2x^2+2xy+3y^2$ takes unit values $\equiv 3,7$; the sets are disjoint. |
| Composition at $-20$ | $P\cdot P = P$, $Q\cdot Q = P$, $P\cdot Q = Q$: the class group is $\mathbb{Z}/2$. |
| PP $=$ NN | Semiprimes with both factors principal and both factors non-principal have identical observations; e.g. $r_{-20}(1189) = r_{-20}(21) = (8,0)$. |
| Character property | The dial bit is a homomorphism $\{1,3,7,9\} \to \mathbb{Z}/2$, hence blind to squares. |
| Dial at $D=-84$ | Four classes with disjoint residue triples mod $84$; class group $(\mathbb{Z}/2)^2$; three same-class types collide, e.g. $r_{-84}(253)=r_{-84}(589)=(8,0,0,0)$. |
| Tensoring | A product of residue dials is a residue dial; the $(-20,-84)$ stack is a dial mod $1680$ with $8$ positions and still confuses $109\cdot 421$ with $23\cdot 107$. |
| Information budget | In a finite group $G$, the multiplication fibre over any point has exactly $|G|$ elements; $2$ for $\mathrm{Cl}(-20)$, $4$ for $\mathrm{Cl}(-84)$. |
| Boundary at $D=-23$ | $x^2+xy+6y^2$ and $2x^2+xy+3y^2$ have identical value sets mod $23$; $59 \equiv 13 \pmod{23}$ with $59$ principal and $13$ not; hence no residue dial mod $23$ contains both forms. |
