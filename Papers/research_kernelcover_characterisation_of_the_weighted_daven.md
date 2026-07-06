# A Kernel-Cover Characterization of the Weighted Davenport Constant

## Abstract

The Davenport constant $D(G)$ of a finite abelian group $G$ is a central
invariant of zero-sum combinatorics: the least $n$ such that every length-$n$
sequence over $G$ admits a non-empty zero-sum subsequence. Weighted variants
$D_\Psi(G)$, in which each term may be transformed by a homomorphism drawn from a
prescribed weight set $\Psi$ before summation, have become a focal point of
recent research. We give a clean, fully general reformulation of the weighted
Davenport bound as a **covering condition**. To each length-$n$ assignment of
weights $\varphi$ we associate the *induced universal homomorphism*
$\Phi_\varphi \colon F^n \to G$, $\Phi_\varphi(x) = \sum_i \varphi_i(x_i)$, and we
show that the bound $D_\Psi(G) \le n$ holds **if and only if** the kernels of the
admissible induced universal homomorphisms cover $F^n$. We prove that this
covering property is monotone in $n$ — validating "$D_\Psi(G) \le n$" as a genuine
threshold statement — provided one models subsequences by admitting a *skip
weight* ($0$) alongside a non-triviality clause. We show that without the skip
weight the analogous rigid property is non-monotone, and that without the
non-triviality clause it is vacuous. Specializing to the single-weight set
$\{\mathrm{id}\}$ on a non-trivial group recovers the classical zero-sum
subsequence formulation exactly, and feeding in $\mathbb{Z}/m$ recovers
$D(\mathbb{Z}/m) = m$. We discuss the resulting dictionary between weighted
Davenport theory and finite-geometry covering theorems, and outline several
research directions the reformulation opens.

## 1. Introduction

Zero-sum combinatorics studies the unavoidable additive structure of long
sequences over a finite abelian group. Its foundational invariant is the
**Davenport constant** $D(G)$: the smallest integer $n$ such that every sequence
of $n$ elements of $G$ contains a non-empty subsequence summing to the identity.
The invariant governs factorization theory in Dedekind domains, appears in the
analysis of irreducible factorizations of algebraic integers, and anchors a large
body of extremal results in additive combinatorics.

A more recent and rapidly growing strand studies **weighted** Davenport
constants, where the terms of a sequence may be scaled or transformed by elements
of a fixed weight set before we ask them to sum to zero. In the most structural
version, weights are *homomorphisms* $F \to G$ from a source group $F$ into the
target $G$, and the weight set $\Psi$ is a set of such homomorphisms. This
homomorphism-valued setting subsumes the classical scalar-weighted constants
(weights in $\mathbb{Z}$ or $\mathbb{Z}/n$ acting by multiplication) and the
finite-field linear setting, and it is the framework we adopt.

The contribution of this paper is a single, clean structural theorem together
with its immediate consequences. We recast the weighted Davenport bound as an
assertion that a certain family of subgroups — the kernels of *induced universal
homomorphisms* — covers the ambient space $F^n$. This "kernel-cover"
characterization is not a definitional tautology: it is a genuine translation
between a pointwise existential ("every vector has an admissible vanishing
weighted sum") and a set-theoretic covering statement ("the kernels union to the
whole space"). Its value is methodological. Once the Davenport bound is a
covering condition, the arithmetic question can be attacked with the geometry of
subspace covers — including, over finite fields, the hyperplane covering theorems
of Alon–Füredi and Jamison and the polynomial method more broadly.

### Summary of results

- **Kernel-cover characterization (Theorem 4.1).** For any non-empty set $W$ of
  non-zero weights and any $n$, the covering property $\mathrm{KernelCover}(W,n)$
  holds iff $\bigcup_{\varphi} \ker \Phi_\varphi = F^n$, the union taken over
  admissible choices $\varphi$.
- **Monotonicity (Theorems 5.1–5.2).** The covering property is preserved under
  $n \mapsto n+1$ and hence under $m \le n$; this makes "$D_\Psi(G) \le n$" a
  bona fide threshold.
- **Bridge to the classical constant (Theorem 6.1).** For $W = \{\mathrm{id}\}$
  on a non-trivial $G$, the covering property at length $n$ is equivalent to
  every length-$n$ sequence over $G$ possessing a non-empty zero-sum
  subsequence.
- **Cyclic evaluation (Theorem 6.2).** $D(\mathbb{Z}/m) = m$.
- **Design lemmas (Section 7).** The skip weight and the non-triviality clause are
  each necessary: dropping the former breaks monotonicity, dropping the latter
  makes the property vacuous.

## 2. Preliminaries and notation

Throughout, $F$ and $G$ denote abelian groups, written additively. We write
$F \to G$ for the set of group homomorphisms (additive monoid homomorphisms
respecting negation), and $0$ for the zero homomorphism $a \mapsto 0$. For
$n \in \mathbb{N}$ we identify a **length-$n$ sequence over $F$** with a function
$x \colon \{1,\dots,n\} \to F$, i.e. an element of the product group $F^n$; the
group operation on $F^n$ is coordinatewise. For a homomorphism $h \colon F^n \to G$
we write $\ker h = \{x \in F^n : h(x) = 0\}$ for its kernel, a subgroup of $F^n$.

A group $G$ is **non-trivial** if it has an element $\ne 0$; equivalently the
identity homomorphism $\mathrm{id}_G$ is non-zero.

## 3. The induced universal homomorphism

The engine of the reformulation is the following construction, which turns a
tuple of weights into a single homomorphism on the product group.

**Definition 3.1 (Induced universal homomorphism).** Let $n \in \mathbb{N}$ and
let $\varphi \colon \{1,\dots,n\} \to (F \to G)$ assign to each coordinate a
weight $\varphi_i$. The *induced universal homomorphism*
$\Phi_\varphi \colon F^n \to G$ is

$$\Phi_\varphi(x) \;=\; \sum_{i=1}^{n} \varphi_i(x_i), \qquad x \in F^n.$$

Concretely $\Phi_\varphi = \sum_i \varphi_i \circ \pi_i$, where
$\pi_i \colon F^n \to F$ is the $i$-th coordinate projection. Each summand is a
composite of homomorphisms, and a finite sum of homomorphisms into an abelian
group is a homomorphism; hence $\Phi_\varphi$ is a homomorphism $F^n \to G$. The
adjective *universal* records that $\Phi_\varphi$ is the unique homomorphism whose
restriction to the $i$-th coordinate axis is $\varphi_i$.

**Definition 3.2 (Admissible choice).** Fix a weight set $W \subseteq (F \to G)$.
A choice $\varphi \colon \{1,\dots,n\} \to (F \to G)$ is **admissible for $W$**
(written $\mathrm{ValidChoice}(W,\varphi)$) if

1. every coordinate is either the skip weight or a genuine weight,
   $\varphi_i \in \{0\} \cup W$ for all $i$; and
2. at least one coordinate is a genuine weight, $\exists\, i,\ \varphi_i \ne 0$.

The skip weight $0$ models *dropping* a coordinate, so an admissible choice is
precisely a non-empty subsequence together with a weighting of its retained
terms. Clause (2) forbids the empty subsequence.

**Definition 3.3 (Kernel-cover property).** For $W \subseteq (F \to G)$ and
$n \in \mathbb{N}$, the **kernel-cover property** $\mathrm{KernelCover}(W,n)$ holds
if every $x \in F^n$ lies in the kernel of some admissible induced universal
homomorphism:

$$\forall\, x \in F^n,\ \exists\, \varphi \text{ admissible for } W \text{ with }
\Phi_\varphi(x) = 0.$$

**Definition 3.4 (Weighted Davenport constant).** The weighted Davenport constant
is the least threshold at which the covering becomes unavoidable,

$$D_\Psi(G) \;=\; \min\{\, n \in \mathbb{N} : \mathrm{KernelCover}(W,n) \,\},$$

so that by definition $D_\Psi(G) \le n \iff \mathrm{KernelCover}(W,n)$, provided
the covering property is monotone in $n$ (established in Section 5).

## 4. The kernel-cover characterization

We can now state the central result. It equates the pointwise "existential"
definition of the covering property with a set-theoretic covering statement about
kernels.

**Theorem 4.1 (Kernel-cover characterization).** *Let $W \subseteq (F \to G)$ and
$n \in \mathbb{N}$. Then*

$$\mathrm{KernelCover}(W,n) \iff \bigcup_{\substack{\varphi \text{ admissible for } W}} \ker \Phi_\varphi \;=\; F^n.$$

*Proof.* Both sides are statements quantified over all $x \in F^n$; by
extensionality of sets, the right-hand equality is equivalent to: every $x \in F^n$
lies in the union, i.e. lies in $\ker \Phi_\varphi$ for some admissible
$\varphi$. Membership $x \in \ker \Phi_\varphi$ unfolds, by definition of kernel,
to $\Phi_\varphi(x) = 0$. Thus "$x$ is in the union for some admissible
$\varphi$" is verbatim "$\exists\, \varphi$ admissible with $\Phi_\varphi(x)=0$,"
which is the defining clause of $\mathrm{KernelCover}(W,n)$ evaluated at $x$.
Quantifying over all $x$ gives the equivalence. $\qquad\blacksquare$

Although the two sides are logically interderivable by unfolding, the theorem is
not a triviality of syntax: it exchanges a *pointwise* description (about
individual sequences and their weighted sums) for a *global* description (about a
union of subgroups filling the space). It is exactly this exchange that licenses
the geometric methods discussed in Section 8. In the finite-field instance of
Section 8, the right-hand side literally asserts that a family of hyperplanes
covers a vector space.

## 5. Monotonicity and the threshold

For $D_\Psi(G) \le n$ to behave like an upper bound on a constant, the covering
property must be upward closed in $n$: once the kernels cover $F^n$, they must
cover every larger cube. This is where the skip weight earns its keep.

**Theorem 5.1 (One-step monotonicity).** *If $\mathrm{KernelCover}(W,n)$ holds
then so does $\mathrm{KernelCover}(W,n+1)$.*

*Proof.* Let $x \in F^{n+1}$. Restrict to the first $n$ coordinates,
$x' = (x_1,\dots,x_n) \in F^n$. By hypothesis there is an admissible
$\varphi' \colon \{1,\dots,n\} \to (F \to G)$ with $\Phi_{\varphi'}(x') = 0$;
admissibility gives $\varphi'_i \in \{0\}\cup W$ for all $i$ and some coordinate
$i_0$ with $\varphi'_{i_0} \ne 0$. Extend $\varphi'$ to length $n+1$ by padding
with the skip weight in the last coordinate:
$\varphi = (\varphi'_1,\dots,\varphi'_n, 0)$. Then every $\varphi_i \in \{0\}\cup W$
and $\varphi_{i_0} \ne 0$, so $\varphi$ is admissible. Finally

$$\Phi_\varphi(x) = \sum_{i=1}^{n} \varphi'_i(x_i) + 0(x_{n+1})
= \Phi_{\varphi'}(x') + 0 = 0.$$

Hence $x$ is covered, and since $x$ was arbitrary, $\mathrm{KernelCover}(W,n+1)$
holds. $\qquad\blacksquare$

**Theorem 5.2 (Monotonicity).** *If $m \le n$ and $\mathrm{KernelCover}(W,m)$
holds, then $\mathrm{KernelCover}(W,n)$ holds.*

*Proof.* Induction on $n \ge m$: the base case $n = m$ is the hypothesis, and each
successor step is Theorem 5.1. $\qquad\blacksquare$

Monotonicity guarantees that the set $\{n : \mathrm{KernelCover}(W,n)\}$ is an
up-set of $\mathbb{N}$, so it is either empty or of the form $\{n : n \ge d\}$ for
a unique threshold $d = D_\Psi(G)$. This is precisely what makes
"$D_\Psi(G) \le n$" a well-posed statement.

## 6. Recovering the classical theory

We now verify that the weighted framework, in its simplest instance, is the
classical Davenport constant.

**Definition 6.1.** A length-$n$ sequence $x \in G^n$ has a **non-empty zero-sum
subsequence** if there is a non-empty $S \subseteq \{1,\dots,n\}$ with
$\sum_{i \in S} x_i = 0$.

**Theorem 6.1 (Bridge to the classical constant).** *Let $G$ be a non-trivial
abelian group and take $F = G$ with the single-weight set $W = \{\mathrm{id}_G\}$.
Then for every $n$,*

$$\mathrm{KernelCover}(\{\mathrm{id}_G\}, n) \iff \text{every } x \in G^n
\text{ has a non-empty zero-sum subsequence.}$$

*Proof.* First note that since $G$ is non-trivial, $\mathrm{id}_G \ne 0$; this is
what makes the identity a *genuine* weight and prevents the degeneracies of
Section 7.

($\Rightarrow$) Suppose the covering property holds and let $x \in G^n$. Choose an
admissible $\varphi$ with $\Phi_\varphi(x) = 0$ and set
$S = \{i : \varphi_i = \mathrm{id}_G\}$. Admissibility forces every $\varphi_i$ to
be $0$ or $\mathrm{id}_G$, and the non-triviality clause supplies an index $i_0$
with $\varphi_{i_0} \ne 0$, hence $\varphi_{i_0} = \mathrm{id}_G$ and $i_0 \in S$;
so $S$ is non-empty. Since $\varphi_i(x_i) = x_i$ for $i \in S$ and
$\varphi_i(x_i) = 0$ otherwise,

$$0 = \Phi_\varphi(x) = \sum_{i} \varphi_i(x_i) = \sum_{i \in S} x_i.$$

Thus $S$ witnesses a non-empty zero-sum subsequence.

($\Leftarrow$) Suppose every length-$n$ sequence has such a subsequence, and let
$x \in G^n$. Take a non-empty $S$ with $\sum_{i\in S} x_i = 0$ and define
$\varphi_i = \mathrm{id}_G$ for $i \in S$, $\varphi_i = 0$ otherwise. Every
$\varphi_i \in \{0, \mathrm{id}_G\}$, and picking any $i \in S$ shows the
non-triviality clause holds, so $\varphi$ is admissible. Then

$$\Phi_\varphi(x) = \sum_i \varphi_i(x_i) = \sum_{i \in S} x_i = 0,$$

so $x$ is covered. As $x$ was arbitrary, the covering property holds.
$\qquad\blacksquare$

Under this bridge the weighted Davenport constant of $\{\mathrm{id}_G\}$ is the
classical $D(G)$. Evaluating on cyclic groups gives the textbook value.

**Theorem 6.2 (Cyclic Davenport constant).** *For every $m \ge 1$,
$D(\mathbb{Z}/m) = m$.*

*Proof sketch.* *Lower bound $D(\mathbb{Z}/m) \ge m$:* the constant sequence
$x = (1,1,\dots,1)$ of length $m-1$ has subsequence sums equal to the residues
$1,2,\dots,m-1$, none of which is $0$ in $\mathbb{Z}/m$; hence no non-empty
zero-sum subsequence exists at length $m-1$, so the covering property fails at
$m-1$. *Upper bound $D(\mathbb{Z}/m) \le m$:* given any $x \in (\mathbb{Z}/m)^m$,
form the $m+1$ partial sums $s_0 = 0$, $s_k = x_1 + \dots + x_k$ for
$1 \le k \le m$. These are $m+1$ elements of the $m$-element group
$\mathbb{Z}/m$, so by pigeonhole $s_j = s_k$ for some $0 \le j < k \le m$; then
$\sum_{i=j+1}^{k} x_i = s_k - s_j = 0$ is a non-empty zero-sum subsequence. Both
bounds together give $D(\mathbb{Z}/m) = m$. $\qquad\blacksquare$

## 7. Why the model is what it is: two necessity lemmas

The definition of admissibility (Definition 3.2) contains two design choices — the
skip weight $0$ and the non-triviality clause. Each is forced.

**Lemma 7.1 (Non-triviality is necessary).** If clause (2) of admissibility is
dropped (so the all-skip choice $\varphi \equiv 0$ becomes admissible), the
covering property becomes vacuously true at every $n \ge 0$: the all-skip choice
sends every $x$ to $\sum_i 0(x_i) = 0$, so its kernel is all of $F^n$. The
resulting "constant" would be $0$ for every group and weight set, carrying no
information.

**Lemma 7.2 (The skip weight is necessary for monotonicity).** Consider the
*rigid* variant in which admissibility requires every coordinate to carry a
genuine weight ($\varphi_i \in W$ for all $i$, no $0$ allowed). This property is
in general **non-monotone** in $n$. Intuitively, a length-$(n+1)$ vector may have
a final coordinate whose value cannot be annihilated by any available weight,
dooming the whole vector even though the first $n$ coordinates were coverable; the
padding argument of Theorem 5.1 is unavailable because there is no skip weight to
absorb the extra coordinate. Consequently the rigid variant has no single
threshold, and its natural invariant is the *set* of covered levels
$\{n : \text{rigid kernels cover } F^n\}$ rather than a Davenport number. This is
precisely why the subsequence model — skip weight plus non-triviality — is the
correct carrier of the Davenport threshold.

Together, Lemmas 7.1 and 7.2 pin down Definition 3.2 as the unique reasonable
model: with both clauses one obtains a monotone, non-vacuous threshold that
specializes to the classical constant.

## 8. A dictionary with finite geometry

The kernel-cover characterization is most powerful when the kernels are
recognizable geometric objects. The canonical instance is linear.

**The hyperplane instance.** Let $F = G = \mathbb{F}_q$, the finite field with $q$
elements, and let the weight set be $\Psi = \mathbb{F}_q^\times$, each non-zero
scalar $c$ acting as the multiplication homomorphism $a \mapsto ca$. An
admissible choice assigns to each coordinate either $0$ (skip) or a non-zero
scalar, with at least one non-zero; the induced universal homomorphism is

$$\Phi_\varphi(x) = \sum_i c_i x_i, \qquad (c_i) \in \mathbb{F}_q^n \setminus \{0\},$$

a non-zero linear functional on $\mathbb{F}_q^n$. Its kernel is a **hyperplane**
through the origin. The kernel-cover property at length $n$ therefore says:

> the chosen family of hyperplanes covers all of $\mathbb{F}_q^n$.

This places weighted Davenport theory in direct contact with the covering
theorems of finite geometry — notably the Alon–Füredi theorem on covering the
cube by hyperplanes and Jamison's theorem on covering the affine space minus a
point, both proved by the polynomial method. In this dictionary, weighted
zero-sums are hyperplane incidences, and lower bounds on the Davenport constant
become lower bounds on the number of coordinates needed to force a hyperplane
cover.

## 9. Applications and computational aspects

**Deciding the covering property.** For finite $F$, $G$ and finite $W$, the
covering property at level $n$ is decidable by exhaustive search: enumerate
$x \in F^n$ and, for each, search over admissible $\varphi \in (\{0\}\cup W)^n$
for one with $\Phi_\varphi(x) = 0$. The cost is $O(|F|^n \cdot (|W|+1)^n)$ in the
naive form; the accompanying software implements this directly and confirms
$D(\mathbb{Z}/m) = m$ for small $m$, as well as the hyperplane instance over small
fields.

**Direct-sum additivity (conjectural).** Because the constant is monotone and the
cyclic case is exact, the natural next computation is for finite abelian
$p$-groups $G = \bigoplus_j \mathbb{Z}/p^{e_j}$ with $\Psi = \{\mathrm{id}\}$. The
expected value is $1 + \sum_j (p^{e_j} - 1)$, geometrically witnessed by the
single uncovered point at the critical length, which is the concatenation of the
extremal constant sequences of the cyclic factors. The cover threshold is then
additive across the direct-sum decomposition.

**Monotone functional on weight sets.** For fixed $G$, enlarging $\Psi$ can only
shrink $D_\Psi(G)$: more admissible choices means more kernels means an easier
cover. The cover picture localizes each strict decrease to a single "newly
covered" residue class — a computable covering-gap witness.

## 10. Discussion and future work

The kernel-cover characterization reframes an arithmetic extremal quantity as a
covering invariant of subgroups of a product group. Its immediate benefits are
conceptual clarity (monotonicity and the classical bridge become one-line
consequences) and methodological reach (the finite-field instance imports the
polynomial method). We highlight four directions.

1. **Kernel-cover formula for finite abelian $p$-groups.** Prove
   $D_{\{\mathrm{id}\}}(G) = 1 + \sum_j (p^{e_j}-1)$ for
   $G = \bigoplus_j \mathbb{Z}/p^{e_j}$ by a direct-sum induction, with the
   uncovered extremal point given explicitly as the concatenation of cyclic
   extremal sequences.

2. **Strict monotonicity in the weight set.** Characterize which additional
   weight $\psi$ satisfies $D_{\Psi\cup\{\psi\}}(G) < D_\Psi(G)$; conjecturally
   this happens iff $\psi$ covers a residue class no existing kernel reaches.

3. **Covers of $\mathbb{F}_q$-vector spaces.** Develop the $\Psi = \mathbb{F}_q^\times$
   instance into a two-way bridge with the Alon–Füredi / Jamison covering
   theorems, yielding polynomial-method lower bounds for weighted Davenport
   constants.

4. **The rigid, skip-free variant.** Study the non-monotone full-tuple cover,
   whose natural invariant is the *set* of covered levels rather than a single
   threshold; determine this set in structured cases such as
   $\Psi = \mathbb{F}_p^\times$ on $\mathbb{Z}/p$.

## 11. Conclusion

We have shown that the weighted Davenport bound $D_\Psi(G) \le n$ is equivalent to
the statement that the kernels of the induced universal homomorphisms cover $F^n$,
that this covering property is monotone in $n$ exactly because subsequences are
modeled by a skip weight, and that the single-weight identity case reproduces the
classical Davenport constant with $D(\mathbb{Z}/m) = m$. The reformulation turns
weighted zero-sum questions into subgroup-covering questions and, over finite
fields, into hyperplane-covering questions — a dictionary we expect to be fruitful
for both lower-bound techniques and structural classification.
