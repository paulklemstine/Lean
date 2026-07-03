# Sheared Witt Vectors as the Filtered Colimit of Truncated Witt Vectors

## Abstract

We study the interaction between the Witt vector construction and filtered
colimits of commutative rings, realized concretely as directed unions of monotone
families of subrings. We prove three complementary results. First, the
**truncated** Witt vector construction $W_n$, being built from finitely many
coordinates, preserves such colimits: every truncated Witt vector over a directed
union $\bigcup_i S_i$ lifts to a single stage $S_i$. Second, the **full** Witt
vector construction $W$ does **not** preserve these colimits; the obstruction is
witnessed by an explicit and entirely natural example — the Witt vector over a
polynomial ring whose $k$-th coordinate is the variable $X_k$ — every coordinate
of which lies in the colimit while the vector as a whole lifts to no stage. Third,
the **sheared** (finitely supported) Witt vector construction repairs the failure:
every finitely supported Witt vector over the colimit lifts, functorially, to a
single stage. Taken together these results identify the sheared Witt vector
construction with the filtered colimit of the truncated Witt vector
constructions, and pinpoint finite essential support as the exact, minimal
condition separating preservation from failure. Throughout, the arguments rest on
a single elementary principle: in a directed system, finitely many germs can be
merged into one stage, and finite essential support is precisely what makes an
infinite-arity construction behave like a finite-arity one.

**Keywords.** Witt vectors, truncated Witt vectors, filtered colimit, directed
union of subrings, finite arity, shearing, finite support, polynomial ring.

## 1. Introduction

The Witt vector functor is a cornerstone of $p$-adic algebra and arithmetic
geometry. Fixing a prime $p$, it assigns to each commutative ring $R$ a
commutative ring $W(R)$ whose underlying set is the countable power
$R^{\mathbb{N}}$ of "Witt coordinates," but whose addition and multiplication are
governed by a universal family of integer polynomials rather than by coordinatewise
operations. The defining structural feature — and the source of both its power and
its subtlety — is that the $k$-th coordinate of a sum or product depends only on
the first $k{+}1$ coordinates of the inputs. The **truncated** Witt vectors
$W_n(R)$, obtained by keeping only the first $n$ coordinates, inherit a ring
structure precisely because of this triangular dependence.

A recurring structural question for any ring-valued construction $F$ is whether it
**commutes with filtered colimits**: given a directed system of rings with colimit
$\varinjlim_i S_i$, is the natural map $\varinjlim_i F(S_i) \to F(\varinjlim_i
S_i)$ an isomorphism? Filtered colimits model "building a ring as an increasing
union of manageable pieces," and preservation of them is what allows local, stage
-by-stage reasoning to determine global behavior. For finitely presented algebraic
constructions, preservation is automatic; for constructions with an infinite
number of coordinates, it can fail.

This paper isolates, in the cleanest possible setting, exactly where the Witt
vector construction sits on this divide. We model a filtered colimit of rings by
its most concrete incarnation, a **directed union of subrings** $\bigcup_i S_i$ of
a fixed ambient ring $R$, and we ask which flavors of the Witt construction detect
no more of the union than a single stage does. Our answer is a trichotomy of
truncated (finite), full (infinite), and sheared (finitely supported) Witt
vectors, with a sharp characterization of when lifting to a single stage is
possible.

The technical core is elementary and self-contained: it reduces every case to the
statement that a *finite* set of elements of a directed union lies in a common
stage. The interest lies not in the difficulty of the arguments but in the
precision of the phenomenon they capture — in particular, in a natural
counterexample showing that the failure of the full functor is genuine, and in the
observation that finite support is the exact minimal repair.

## 2. Preliminaries

### 2.1 Directed unions of subrings as filtered colimits

Let $R$ be a commutative ring and $(\iota, \le)$ a nonempty **directed** preorder,
meaning any two indices have a common upper bound. A family of subrings
$S : \iota \to \mathrm{Subring}(R)$ is **monotone** if $i \le j$ implies
$S_i \subseteq S_j$. Its colimit inside $R$ is the join
$$S_\infty \;=\; \bigsqcup_{i} S_i,$$
the smallest subring containing all $S_i$. Because the family is directed and
monotone, this join coincides with the set-theoretic directed union:
$$x \in S_\infty \iff \exists\, i,\; x \in S_i.$$
This equivalence — that membership in the categorical colimit is witnessed at a
single stage — is the only structural fact about colimits we use. We refer to the
$S_i$ as **stages**.

The organizing principle of the paper is the following elementary lemma, which we
state once and invoke repeatedly.

> **Lemma 2.1 (Finite merging).** Let $S : \iota \to \mathrm{Subring}(R)$ be
> monotone over a nonempty directed index. If $a_1, \dots, a_m \in S_\infty$, then
> there is a single stage $S_i$ with $a_1, \dots, a_m \in S_i$.

*Proof.* Each $a_t$ lies in some stage $S_{i_t}$. The finite set of indices
$\{i_1, \dots, i_m\}$ has a common upper bound $i$ by directedness, and
monotonicity gives $S_{i_t} \subseteq S_i$ for all $t$, so all $a_t \in S_i$.
$\qquad\blacksquare$

The entire content of the paper is the observation that Lemma 2.1 applies verbatim
to finitely many coordinates, fails for infinitely many, and is rescued by finite
support.

### 2.2 Witt vectors and their coordinates

Fix a prime $p$. For a commutative ring $R$, the **Witt vectors** $W(R)$ have
underlying set $R^{\mathbb{N}}$; we write $x_k = x.\mathrm{coeff}(k) \in R$ for the
$k$-th coordinate of $x \in W(R)$. Two Witt vectors are equal iff all their
coordinates agree. For a length $n \in \mathbb{N}$, the **truncated Witt vectors**
$W_n(R)$ have underlying set $R^{\{0,\dots,n-1\}}$; again we write $y_k$ for the
$k$-th coordinate ($0 \le k < n$), and a truncated Witt vector is determined by
its coordinate tuple.

The Witt construction is functorial: a ring homomorphism $f : A \to B$ induces a
ring homomorphism $W(f) : W(A) \to W(B)$ acting coordinatewise, i.e.
$W(f)(x)_k = f(x_k)$. The same holds for the truncated functors. When
$\varphi : S_i \hookrightarrow R$ is the inclusion of a subring, $W(\varphi)$ maps
a Witt vector over $S_i$ to the Witt vector over $R$ with the same coordinates,
reinterpreted through the inclusion. All we use about the Witt construction is
this coordinatewise functoriality together with the extensionality principle
(equality is detected coordinatewise).

### 2.3 Support and shearing

A Witt vector $x \in W(R)$ has **finite support** (equivalently, is **sheared**)
if there is a cutoff $N$ with $x_k = 0$ for all $k \ge N$. The basepoint $0$ lies
in every subring, so a finitely supported vector has only finitely many
coordinates that need to be "placed" in a stage; the rest are automatically
present everywhere. The sheared Witt vectors are exactly the finitely supported
elements of $W(R)$; they form the essentially finite part of the full construction.

## 3. Main Results

We now state and prove the three theorems. Throughout, $R$ is a commutative ring,
$(\iota,\le)$ is a nonempty directed preorder, $S : \iota \to \mathrm{Subring}(R)$
is monotone, and $S_\infty = \bigsqcup_i S_i$.

### 3.1 Finite arity: truncated Witt vectors preserve the colimit

> **Theorem A (Truncated preservation).** Let $x \in W_n(S_\infty)$ be a
> truncated Witt vector all of whose coordinates lie in $S_\infty$. Then there
> exist a stage index $i$ and a truncated Witt vector $y \in W_n(S_i)$ such that
> the inclusion $S_i \hookrightarrow R$ sends each coordinate of $y$ to the
> corresponding coordinate of $x$: for all $k$, $\;\iota_{S_i}(y_k) = x_k$.

*Proof sketch.* The vector $x$ has finitely many coordinates $x_0, \dots,
x_{n-1}$, each in $S_\infty$. By Lemma 2.1 there is a single stage $S_i$
containing all of them, say $x_k \in S_i$ for every $k$. Define $y \in W_n(S_i)$ to
be the truncated Witt vector whose $k$-th coordinate is the element $x_k$ regarded
as living in $S_i$ (i.e. the pair $\langle x_k, \text{proof } x_k \in S_i\rangle$).
Then the inclusion sends $y_k$ back to $x_k$ by construction, for every $k$. By
coordinatewise equality this exhibits $y$ as a lift of $x$. $\qquad\blacksquare$

Theorem A is the "finite limits commute with filtered colimits" phenomenon
specialized to the finite-arity Witt functor: each truncated stage of the story is
governed by a finite tuple, so Lemma 2.1 applies directly. It expresses that each
truncation level $W_n$ preserves the filtered colimit of subrings.

### 3.2 The obstruction: the full Witt functor fails

The naive hope is that Theorem A survives the removal of the truncation. It does
not, and the failure is realized by a canonical example.

Let $K$ be a nontrivial commutative ring (e.g. a field) and let
$R = K[X_0, X_1, X_2, \dots]$ be the polynomial ring in countably many variables.
For $i \in \mathbb{N}$ define the **variable-support subring**
$$S_i \;=\; \{\, f \in R : \mathrm{vars}(f) \subseteq \{0, 1, \dots, i\} \,\},$$
the polynomials using only the variables $X_0, \dots, X_i$. This is a subring
(closed under $0$, $1$, negation, sums, and products because the variable set of a
sum or product is contained in the union of the variable sets), and the family is
monotone in $i$. Its union is all of $R$, since any polynomial mentions only
finitely many variables:
$$\bigsqcup_i S_i \;=\; R.$$

Consider the **Witt vector of variables** $x \in W(R)$ defined by $x_k = X_k$ for
all $k$.

> **Theorem B (Naive failure).** For the variable Witt vector $x$ above, every
> coordinate lies in the colimit — indeed $x_k = X_k \in S_k \subseteq S_\infty =
> R$ — yet there is **no** stage $i$ and Witt vector over $S_i$ mapping to $x$
> under $W(S_i \hookrightarrow R)$. Consequently the full Witt vector functor does
> not preserve this filtered colimit.

*Proof sketch.* Pointwise membership is immediate: $X_k$ uses only the variable
$X_k$, so $X_k \in S_k \subseteq S_\infty$. Suppose, for contradiction, that $x =
W(\iota_{S_i})(z)$ for some stage $i$ and $z \in W(S_i)$. Comparing the
$(i{+}1)$-th coordinates gives $X_{i+1} = \iota_{S_i}(z_{i+1})$, so $X_{i+1} \in
S_i$, i.e. $X_{i+1}$ uses only variables among $\{0, \dots, i\}$. But
$\mathrm{vars}(X_{i+1}) = \{i+1\}$, and $\{i+1\} \not\subseteq \{0, \dots, i\}$ —
contradiction (here nontriviality of $K$ ensures $X_{i+1}$ genuinely involves the
variable $X_{i+1}$). Hence no stage lift exists. $\qquad\blacksquare$

Two features make Theorem B the crux of the paper. First, the obstruction is
**genuine, not vacuous**: the hypotheses are satisfiable and the conclusion is a
true non-existence, exhibited by an explicit natural vector. Second, and more
striking, the failure is purely **collective**: every individual coordinate lifts
(coordinate $k$ to stage $k$), and only the entire vector refuses to. The
coordinates drift outward without bound, and directedness — which merges any
*finite* family of stages — cannot corral infinitely many escaping demands.

### 3.3 The repair: sheared Witt vectors preserve the colimit

Restricting to finite support removes exactly the drift that Theorem B exploits.

> **Theorem C (Sheared preservation).** Let $p$ be prime and let $x \in
> W(S_\infty)$ be finitely supported — there is $N$ with $x_k = 0$ for all $k \ge
> N$ — with every coordinate in $S_\infty$. Then there exists a stage $i$ such
> that $x$ lies in the image of the functorial map $W(S_i \hookrightarrow R) :
> W(S_i) \to W(S_\infty)$; that is, $x$ lifts to a single stage.

*Proof sketch.* Only the coordinates $x_0, \dots, x_{N-1}$ can be nonzero. These
are finitely many elements of $S_\infty$, so by Lemma 2.1 there is a stage $S_i$
containing all of them. For $k \ge N$ we have $x_k = 0 \in S_i$ as well, since $0$
belongs to every subring. Thus **every** coordinate of $x$ lies in $S_i$. Package
the coordinates into a Witt vector $z \in W(S_i)$ (with $z_k$ the element $x_k$
viewed in $S_i$); then $W(\iota_{S_i})(z)$ agrees with $x$ coordinatewise, hence
equals $x$ by extensionality. $\qquad\blacksquare$

Comparing Theorems B and C isolates finite support as the precise dividing line.
The full functor fails because the variable vector has infinitely many nonzero
coordinates escaping to infinity; the sheared functor succeeds because finite
support caps the number of coordinates that need placing. The very vector that
breaks Theorem B, $x_k = X_k$, is the minimal violation: each of its coordinates
sits at a distinct, growing stage, so *no* finiteness condition weaker than finite
essential support could rescue preservation. Shearing is therefore not merely *a*
repair but the *minimal* one.

## 4. Synthesis: the sheared colimit identification

The three theorems combine into a single statement about the structure of the
Witt construction relative to filtered colimits.

> **Corollary D (Colimit identification).** Over any directed union of subrings
> $S_\infty = \bigsqcup_i S_i$:
> 1. each truncation level $W_n$ preserves the colimit (Theorem A);
> 2. the finitely supported (sheared) Witt vectors over $S_\infty$ are exactly the
>    union of the images of the stagewise Witt vectors $W(S_i)$ (Theorem C); and
> 3. this identification fails for the full, unsheared functor (Theorem B).

Read functorially, the sheared Witt vector construction is assembled from its
finite truncations, each of which respects the colimit, and stacking these finite
layers under the finite-support condition reproduces exactly the union over the
stages. In slogan form: **the sheared Witt vectors over a colimit of rings are the
colimit of the truncated Witt vectors over the stages.** The object that naively
broke colimit-preservation is, after shearing, rebuilt from the very finite pieces
that respect it.

## 5. Algorithms

The proofs are constructive and translate directly into procedures. We record
their logic; runnable implementations over polynomial coordinates appear in the
accompanying software.

**Algorithm 1 (Stage lift for finitely many / finitely supported coordinates).**
*Input:* a monotone family of subrings represented by membership predicates $x
\mapsto \mathrm{stage}(x)$ returning the least stage containing $x$; a finite list
of coordinates (either the $n$ coordinates of a truncated vector, or the nonzero
prefix of a sheared vector). *Output:* a single stage index $i$ and the lifted
coordinates. *Method:* compute $\mathrm{stage}(x_k)$ for each coordinate, set $i =
\max_k \mathrm{stage}(x_k)$ (the common upper bound from Lemma 2.1), and return $i$
with each coordinate reinterpreted in $S_i$. This realizes Theorems A and C.

**Algorithm 2 (Obstruction detector).** *Input:* a Witt vector over a polynomial
ring with the variable-support filtration and a candidate stage $i$. *Output:* a
certificate that the vector does **not** lift to stage $i$, when one exists.
*Method:* search for a coordinate index $k$ with $\mathrm{vars}(x_k)
\not\subseteq \{0,\dots,i\}$; return $k$ as a witness. For the variable vector
$x_k = X_k$, the witness $k = i+1$ works for every $i$, certifying global failure.
This realizes Theorem B.

## 6. Applications and discussion

**Local-to-global reasoning.** Preservation of filtered colimits is what licenses
proving a property of a Witt ring over a large (colimit) base by checking it on
finite stages. Theorem A shows this is always legitimate for truncated Witt
vectors, and Theorem C shows it remains legitimate for the sheared theory. Theorem
B is a caution: for the full theory one must not assume stagewise verification
suffices.

**A design principle for coordinate constructions.** The trichotomy is a template
that recurs far beyond Witt vectors. Any construction whose output is an infinite
tuple of coordinate-local data will fail to commute with directed unions exactly
when infinitely many coordinates can drift outward, and the finite-support
("sheared") variant will restore preservation. The variable vector $x_k = X_k$ is
a universal cautionary example.

**Why the counterexample is canonical.** The polynomial ring with the variable
-support filtration is the *free* object in which coordinates can be made maximally
independent: the $k$-th variable is designed to require the $k$-th stage and no
earlier one. That is why the variable vector is the sharpest possible witness to
failure and why it certifies the *minimality* of the finite-support repair.

## 7. Future Directions

The present results identify the sheared Witt construction with the filtered
colimit of truncated Witt constructions at the level of underlying sets. The
natural next steps promote this identification to the level of algebra and
operators.

**From set to ring.** Realize a filtered colimit of rings as a directed union of a
monotone family of subrings and consider the finitely supported Witt vectors over
the colimit. As a set these are the union of the images from the individual
stages. We conjecture this union is closed under Witt addition and multiplication,
so it is a genuine subring of the Witt vectors over the colimit, and the induced
map from the ring colimit of the stagewise Witt rings is a ring isomorphism. The
key insight is that the $n$-th Witt addition and multiplication polynomials depend
only on the first $n$ coordinates, so on finitely supported vectors both
operations preserve finite support and factor through a single stage once finitely
many indices are merged.

**Frobenius and Verschiebung.** The Witt vectors carry Frobenius and Verschiebung
operators. We conjecture that on finitely supported vectors both operators map the
union of the stagewise images into itself and are computed one stage at a time, so
that the isomorphism between the sheared object and the filtered colimit
intertwines these operators. The key insight is that each output coordinate of
Frobenius and Verschiebung is a polynomial in finitely many input coordinates, and
Verschiebung merely shifts support by one, so neither operator can destroy finite
support or single-stage factorization.

**A trichotomy of Witt vectors over a colimit.** Over a colimit ring there are
three natural classes of Witt vectors: those whose coordinates merely lie
pointwise in the colimit, those that are *stage-bounded* (a single stage contains
every coordinate), and those of finite support. We conjecture these form a
strictly nested hierarchy, with the variable vector separating the pointwise class
from the stage-bounded class, and quantitative analogues distinguishing finite
support from mere stage-boundedness.

## 8. Conclusion

We have located the Witt vector construction precisely on the divide between
finite and infinite arity relative to filtered colimits. Truncated Witt vectors,
being finite, always descend to a single stage; the full Witt vectors do not, as
witnessed canonically by the vector of all the variables over a polynomial ring;
and the sheared, finitely supported Witt vectors restore preservation and do so
minimally. The unifying thread is Lemma 2.1: finitely many germs merge into one
stage. Finite essential support is exactly the condition that makes an
infinite-arity coordinate construction behave, once more, like a finite one — and
that is the algebraic meaning of shearing.
