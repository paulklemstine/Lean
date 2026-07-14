# A Kernel-Cover Characterization of the Weighted Davenport Constant

## Abstract

We develop a self-contained algebraic model of weighted zero-sum problems over
abelian groups and prove a clean characterization of the weighted Davenport
constant in terms of a covering condition on kernels of linear maps. Let $F$ and
$G$ be abelian groups and let $W$ be a set of group homomorphisms $F \to G$
playing the role of a weight set. Any length-$n$ assignment of weights
$\varphi = (\varphi_0, \dots, \varphi_{n-1})$, with each $\varphi_i$ either the
zero map or a member of $W$, assembles into a single **induced universal
homomorphism** $\Phi_\varphi \colon F^n \to G$ given by
$\Phi_\varphi(x) = \sum_i \varphi_i(x_i)$. Modeling "skip this coordinate" as the
zero weight, we call a weighting *valid* when at least one coordinate carries a
genuine (nonzero) weight. The **kernel-cover property** $\mathrm{KC}(W, n)$
states that every $x \in F^n$ lies in the kernel of some valid $\Phi_\varphi$;
this is exactly the statement that the weighted Davenport constant satisfies
$D_W(G) \le n$. Our main results are: (1) $\mathrm{KC}(W, n)$ holds if and only
if the union of the kernels of the valid induced homomorphisms equals all of
$F^n$; (2) $\mathrm{KC}(W, \cdot)$ is monotone in $n$, so the least $n$ with the
property is a well-defined threshold; and (3) for the singleton weight set
$\{\mathrm{id}\}$ over a nontrivial group, $\mathrm{KC}(\{\mathrm{id}\}, n)$ is
equivalent to the classical statement that every length-$n$ sequence in $G$ has a
nonempty zero-sum subsequence. Together these show that the covering
reformulation is faithful, that the zero-weight ("subsequence") model is exactly
what makes the constant monotone, and that the classical Davenport constant is
recovered as one instance of the general framework. We include numerical
demonstrations over finite cyclic groups.

## 1. Introduction

Zero-sum theory studies the following template question: how long must a sequence
of elements of a finite abelian group $G$ be before it is *forced* to contain a
subsequence with a prescribed additive property? The oldest and most fundamental
instance is the **Davenport constant** $D(G)$, the least integer $\ell$ such that
every sequence of length $\ell$ over $G$ contains a nonempty subsequence summing
to zero. For a finite cyclic group $G = \mathbb{Z}/m\mathbb{Z}$ one has
$D(\mathbb{Z}/m\mathbb{Z}) = m$.

A far-reaching refinement replaces plain addition by *weighted* addition. Fix a
weight set — a set of allowed multipliers or, more generally, a set of
homomorphisms — and ask for a subsequence that can be *rescaled* by weights to
sum to zero. The resulting **weighted Davenport constant** depends on the weight
set and interpolates between many classically studied quantities. Weighted
zero-sum invariants arise in the arithmetic of non-unique factorization, in
coding theory, and in the additive combinatorics of finite groups.

This paper isolates the structural core of the weighted problem. We phrase it not
in terms of sequences and subsequence selections but in terms of a family of
group homomorphisms $F^n \to G$ and their kernels. The payoff is a single
geometric criterion — *the kernels cover the space* — that (i) is provably
equivalent to the combinatorial threshold condition, (ii) explains transparently
why the threshold is monotone (and hence well-defined), and (iii) contains the
classical Davenport constant as a special case. The exposition is self-contained:
all definitions and proofs are given inline.

## 2. The model

Throughout, $F$ and $G$ are abelian groups (written additively), and
$\operatorname{Hom}(F, G)$ denotes the group of homomorphisms $F \to G$. For
$n \in \mathbb{N}$ we write $F^n$ for the group of functions $\{0, \dots, n-1\}
\to F$, i.e. length-$n$ tuples with entrywise addition.

### 2.1 Weights and the induced universal homomorphism

**Definition 2.1 (Weight set).** A *weight set* is any subset
$W \subseteq \operatorname{Hom}(F, G)$.

The zero homomorphism $0 \colon F \to G$ is always available and will play a
distinguished role: it models the act of *skipping* a coordinate.

**Definition 2.2 (Choice of weights).** A *length-$n$ choice of weights* is a
tuple $\varphi = (\varphi_0, \dots, \varphi_{n-1})$ with each
$\varphi_i \in \operatorname{Hom}(F, G)$.

**Definition 2.3 (Induced universal homomorphism).** Given a length-$n$ choice
$\varphi$, the *induced universal homomorphism* is
$$\Phi_\varphi \colon F^n \to G, \qquad
  \Phi_\varphi(x) \;=\; \sum_{i=0}^{n-1} \varphi_i(x_i).$$

Because each $\varphi_i$ is a homomorphism and $G$ is abelian, $\Phi_\varphi$ is
itself a group homomorphism $F^n \to G$. Concretely,
$\Phi_\varphi = \sum_i \varphi_i \circ \pi_i$, where $\pi_i \colon F^n \to F$ is
the $i$-th coordinate projection. We record the defining evaluation for later
use.

**Lemma 2.4 (Evaluation).** For every choice $\varphi$ and every $x \in F^n$,
$\Phi_\varphi(x) = \sum_{i=0}^{n-1} \varphi_i(x_i)$.

*Proof.* Immediate from the definition of $\Phi_\varphi$ as the pointwise sum
$\sum_i \varphi_i \circ \pi_i$ evaluated at $x$, since a finite sum of
homomorphisms is evaluated coordinatewise. $\qquad\blacksquare$

### 2.2 Valid choices and the kernel-cover property

**Definition 2.5 (Valid choice).** Fix a weight set $W$. A length-$n$ choice
$\varphi$ is *valid for $W$* if
$$\varphi_i \in \{0\} \cup W \ \text{ for all } i, \qquad \text{and} \qquad
  \varphi_i \neq 0 \ \text{ for at least one } i.$$

The first condition says every coordinate is either skipped ($\varphi_i = 0$) or
weighted by a genuine element of $W$; the second forbids the degenerate
all-skip choice, which corresponds to the empty subsequence and would otherwise
make everything trivial.

**Definition 2.6 (Kernel-cover property).** The weight set $W$ has the
*kernel-cover property at length $n$*, written $\mathrm{KC}(W, n)$, if for every
$x \in F^n$ there exists a valid choice $\varphi$ with $\Phi_\varphi(x) = 0$.

**Definition 2.7 (Weighted Davenport constant).** The *weighted Davenport
constant* $D_W(G)$ (relative to $F$) is the least $n \ge 1$ such that
$\mathrm{KC}(W, n)$ holds, if such $n$ exists; otherwise $D_W(G) = \infty$. By
definition $D_W(G) \le n \iff \mathrm{KC}(W, n)$.

**Remark 2.8 (Necessity of the nonzero clause).** If the "at least one nonzero"
requirement were dropped, the all-zero choice would satisfy $\Phi_\varphi(x) = 0$
for every $x$, so $\mathrm{KC}(W, n)$ would hold vacuously for all $n \ge 1$ and
the constant would collapse to $1$. The clause is therefore essential to the
content of the definition.

## 3. Main results

### 3.1 The covering characterization

Our first theorem translates the pointwise existential condition of Definition
2.6 into a single statement about a union of subgroups.

**Theorem 3.1 (Kernel-cover characterization).** For any weight set
$W \subseteq \operatorname{Hom}(F, G)$ and any $n \in \mathbb{N}$,
$$\mathrm{KC}(W, n) \quad\Longleftrightarrow\quad
  \bigcup_{\substack{\varphi \ \text{valid for } W}} \ker \Phi_\varphi
  \;=\; F^n.$$

*Proof.* By definition, a union of subsets equals $F^n$ iff every $x \in F^n$
belongs to some member of the union. Fix $x$.

($\Rightarrow$) Assume $\mathrm{KC}(W, n)$. Then there is a valid $\varphi$ with
$\Phi_\varphi(x) = 0$, i.e. $x \in \ker \Phi_\varphi$; hence $x$ lies in the
union.

($\Leftarrow$) Assume the union is all of $F^n$. Then $x$ lies in
$\ker \Phi_\varphi$ for some valid $\varphi$, which is precisely the statement
$\Phi_\varphi(x) = 0$; hence $\mathrm{KC}(W, n)$ holds at $x$.

Since $x$ was arbitrary, the two conditions are equivalent. $\qquad\blacksquare$

The translation is genuine rather than definitional: the left side quantifies
existentially over choices *for each point separately*, while the right side is a
single set-theoretic identity. Theorem 3.1 is what licenses geometric reasoning —
dimension counts, inclusion–exclusion over the kernels, symmetry arguments — in
the study of $D_W(G)$.

### 3.2 Monotonicity

The next results show that the property, once achieved, persists — the feature
that makes $D_W(G)$ a bona fide threshold.

**Theorem 3.2 (One-step monotonicity).** If $\mathrm{KC}(W, n)$ holds then
$\mathrm{KC}(W, n+1)$ holds.

*Proof.* Let $x \in F^{n+1}$. Apply $\mathrm{KC}(W, n)$ to the truncation
$x' = (x_0, \dots, x_{n-1}) \in F^n$ to obtain a valid length-$n$ choice
$\varphi'$ with $\sum_{i<n} \varphi'_i(x'_i) = 0$ and $\varphi'_{i_0} \neq 0$ for
some $i_0 < n$. Extend $\varphi'$ to length $n+1$ by appending the zero weight in
the last coordinate: set $\varphi = (\varphi'_0, \dots, \varphi'_{n-1}, 0)$. Then
each $\varphi_i \in \{0\} \cup W$, and $\varphi_{i_0} \neq 0$, so $\varphi$ is
valid. Moreover
$$\Phi_\varphi(x) = \sum_{i<n} \varphi'_i(x_i) + 0(x_n)
  = \sum_{i<n} \varphi'_i(x'_i) + 0 = 0.$$
Hence $\mathrm{KC}(W, n+1)$ holds at $x$; as $x$ was arbitrary, we are done.
$\qquad\blacksquare$

The proof is exactly the "padding with zeros" argument, and it is where the
zero-weight model earns its keep: the extra coordinate is neutralized by the
skip-weight $0$, so no stray term can obstruct the previously found solution. With
a model that forced every coordinate to carry a nonzero weight, this step would
fail, and $\mathrm{KC}(W, \cdot)$ would not be monotone.

**Theorem 3.3 (Monotonicity).** If $m \le n$ and $\mathrm{KC}(W, m)$ holds, then
$\mathrm{KC}(W, n)$ holds.

*Proof.* Induct on $n \ge m$. The base case $n = m$ is the hypothesis. For the
inductive step, if $\mathrm{KC}(W, k)$ holds for some $k \ge m$, then Theorem 3.2
gives $\mathrm{KC}(W, k+1)$. $\qquad\blacksquare$

**Corollary 3.4.** The set $\{n : \mathrm{KC}(W, n)\}$ is upward closed, so
$D_W(G) = \min\{n : \mathrm{KC}(W, n)\}$ is well-defined whenever the property
holds for some $n$, and $\mathrm{KC}(W, n) \iff D_W(G) \le n$.

### 3.3 The bridge to the classical Davenport constant

We now verify that the framework specializes correctly. Take $F = G$ and the
singleton weight set $W = \{\mathrm{id}_G\}$, where $\mathrm{id}_G$ is the
identity homomorphism. A valid choice then assigns each coordinate either
$\mathrm{id}_G$ (keep) or $0$ (skip), which is exactly the data of a nonempty
subset $S \subseteq \{0, \dots, n-1\}$ of retained coordinates, and
$\Phi_\varphi(x) = \sum_{i \in S} x_i$.

**Definition 3.5 (Zero-sum subsequence).** A tuple $x \in G^n$ *has a nonempty
zero-sum subsequence* if there is a nonempty $S \subseteq \{0, \dots, n-1\}$ with
$\sum_{i \in S} x_i = 0$.

**Lemma 3.6.** If $G$ is nontrivial then $\mathrm{id}_G \neq 0$.

*Proof.* Choose $a \in G$ with $a \neq 0$ (possible since $G$ is nontrivial). If
$\mathrm{id}_G = 0$ then $a = \mathrm{id}_G(a) = 0(a) = 0$, a contradiction.
$\qquad\blacksquare$

**Theorem 3.7 (Bridge to the classical Davenport constant).** Let $G$ be a
nontrivial abelian group. For every $n$,
$$\mathrm{KC}(\{\mathrm{id}_G\}, n) \quad\Longleftrightarrow\quad
  \text{every } x \in G^n \text{ has a nonempty zero-sum subsequence.}$$

*Proof.* ($\Rightarrow$) Fix $x \in G^n$ and take a valid choice $\varphi$ with
$\Phi_\varphi(x) = 0$. Each $\varphi_i \in \{0\} \cup \{\mathrm{id}_G\}$, and by
Lemma 3.6 the value $\mathrm{id}_G$ is genuinely distinct from $0$; let
$S = \{i : \varphi_i = \mathrm{id}_G\}$. Validity provides an index $i_0$ with
$\varphi_{i_0} \neq 0$, i.e. $\varphi_{i_0} = \mathrm{id}_G$, so $i_0 \in S$ and
$S$ is nonempty. For $i \in S$ we have $\varphi_i(x_i) = x_i$, and for
$i \notin S$ we have $\varphi_i = 0$ so $\varphi_i(x_i) = 0$; therefore
$$0 = \Phi_\varphi(x) = \sum_{i=0}^{n-1} \varphi_i(x_i) = \sum_{i \in S} x_i,$$
exhibiting a nonempty zero-sum subsequence.

($\Leftarrow$) Suppose $x \in G^n$ has a nonempty zero-sum subsequence indexed by
$S$. Define $\varphi_i = \mathrm{id}_G$ if $i \in S$ and $\varphi_i = 0$
otherwise. Each $\varphi_i \in \{0\} \cup \{\mathrm{id}_G\}$; picking any
$i_0 \in S$ gives $\varphi_{i_0} = \mathrm{id}_G \neq 0$ by Lemma 3.6, so
$\varphi$ is valid. Then
$$\Phi_\varphi(x) = \sum_{i \in S} \mathrm{id}_G(x_i) + \sum_{i \notin S} 0
  = \sum_{i \in S} x_i = 0,$$
so $\mathrm{KC}(\{\mathrm{id}_G\}, n)$ holds at $x$. As $x$ was arbitrary, the
two statements are equivalent. $\qquad\blacksquare$

**Corollary 3.8.** With $G$ nontrivial and $W = \{\mathrm{id}_G\}$, the invariant
$D_W(G)$ equals the classical Davenport constant $D(G)$. In particular
$D_{\{\mathrm{id}\}}(\mathbb{Z}/m\mathbb{Z}) = m$.

**Remark 3.9 (Nontriviality is necessary).** If $G = 0$ then
$\mathrm{id}_G = 0$, the "keep" and "skip" weights coincide, and no valid choice
exists (validity requires a nonzero weight). The hypothesis $G \neq 0$ in
Theorem 3.7 is thus not cosmetic.

## 4. Discussion

### 4.1 Three moves, one theorem

The development rests on three conceptual reductions, each elementary but
individually decisive:

1. **Choice as a linear map.** A combinatorial selection-with-weights becomes a
   single homomorphism $\Phi_\varphi$, transporting the question into linear
   algebra over abelian groups (Definition 2.3, Lemma 2.4).
2. **Skip as the zero weight.** Modeling "omit a coordinate" by the zero
   homomorphism unifies "subsequence selection" and "full weighting" and, via
   padding, delivers monotonicity (Definition 2.5, Theorem 3.2).
3. **Guaranteed win as a covering.** The threshold condition becomes the single
   set identity $\bigcup_\varphi \ker \Phi_\varphi = F^n$ (Theorem 3.1).

### 4.2 The role of the weight set

Enlarging $W$ can only shrink $D_W(G)$: more weights mean more valid choices,
hence larger kernels and an easier cover. The demonstrations quantify this over
cyclic groups. For $G = \mathbb{Z}/m\mathbb{Z}$ with $F = G$, homomorphisms are
multiplications by ring elements, so weight sets are subsets of
$\mathbb{Z}/m\mathbb{Z}$. Empirically (see the accompanying computations):

| Weight set $W$ | $D_W(\mathbb{Z}/5\mathbb{Z})$ | $D_W(\mathbb{Z}/6\mathbb{Z})$ | $D_W(\mathbb{Z}/7\mathbb{Z})$ |
|---|---|---|---|
| $\{1\}$ (classical) | $5$ | $6$ | $7$ |
| $\{1, -1\}$ | $3$ | $3$ | $3$ |
| units | $2$ | $3$ | $2$ |
| all nonzero | $2$ | $2$ | $2$ |

These values are consistent with the classical bridge (top row equals $m$) and
with monotonicity in the weight set (each column is nonincreasing as $W$ grows).

### 4.3 Faithfulness of the model

The three theorems establish, respectively, that the covering reformulation is
*equivalent* to the original condition (not a mere analogy), that the constant is
a *genuine threshold* (upward-closed achievability), and that the classical
theory is *recovered exactly* (not merely approximated). Remarks 2.8 and 3.9
pinpoint the two hypotheses — the nonzero clause and nontriviality of $G$ —
without which the model degenerates, confirming that the definitions are tuned as
tightly as possible.

## 5. Algorithms

We summarize the effective content in three algorithms over a finite ambient
group, as realized in the accompanying code.

**Algorithm A (Kernel-cover decision).** Given a finite group $F$, a finite
weight set $W \subseteq \operatorname{Hom}(F, G)$, and a length $n$, decide
$\mathrm{KC}(W, n)$ by iterating over all $x \in F^n$ and, for each, searching for
a valid $\varphi$ with $\Phi_\varphi(x) = 0$. Complexity $O(|F|^n \cdot
(|W|+1)^n \cdot n)$.

**Algorithm B (Weighted Davenport constant).** Increment $n$ from $1$ and return
the first $n$ for which Algorithm A reports true. Correctness and termination
follow from monotonicity (Theorem 3.3) together with a finite upper bound (e.g.
$|G|$ for cyclic $G$ with $\mathrm{id} \in W$).

**Algorithm C (Cover verification).** Independently confirm Theorem 3.1 by
forming $\bigcup_\varphi \ker \Phi_\varphi$ explicitly and testing equality with
$F^n$; agreement with Algorithm A on all tested instances is a cross-check of the
characterization.

## 6. Applications

- **Non-unique factorization.** Weighted Davenport constants bound the lengths of
  irreducible factorizations in orders of algebraic number fields; the covering
  criterion reframes such bounds as questions about kernels filling a space.
- **Coding and ranking.** Weight sets model admissible rescalings in
  combinatorial ranking and in certain code constructions; the monotone threshold
  gives a clean design parameter.
- **Additive group theory.** The framework is a uniform host for many zero-sum
  invariants ($\pm 1$-weighted, unit-weighted, plus-minus constants), all read off
  from one covering condition.

## 7. Future work

Natural next steps include: computing $D_W(G)$ for structured weight sets (units,
squares, prescribed subgroups) across families of finite abelian groups; using
the covering formulation to obtain dimension- and symmetry-based lower bounds via
inclusion–exclusion on the kernels; extending the bridge to other classical
invariants (the EGZ-type constants and the $\eta$- and $\mathsf{s}$-constants) by
choosing the target $G$ and the validity predicate appropriately; and studying
the asymptotics of $D_W(G)$ as the weight set interpolates between the singleton
and the full homomorphism group.

## 8. Conclusion

By recasting weighted zero-sum problems in terms of induced universal
homomorphisms and their kernels, we obtained a single equivalence — the
kernel-cover characterization — from which monotonicity and the recovery of the
classical Davenport constant follow transparently. The framework is faithful
(equivalent to the original condition), robust (a genuine threshold), and
conservative (containing the classical theory), while opening the problem to the
methods of linear algebra and geometry.
