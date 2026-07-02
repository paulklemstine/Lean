# Superposition over Non-Archimedean Value Fields: The Standard Part as a Measurement Rule

## Abstract

We study finite superpositions whose amplitudes are drawn from a non-Archimedean
ordered field — an ordered field extending the real numbers and containing
nonzero infinitesimals, the setting exemplified by Conway's surreal numbers.
Assigning to each branch its Born weight $w_i = \alpha_i^2 / \sum_j \alpha_j^2$
produces a family of weights that sum to $1$ *exactly* in the field, but whose
individual entries may be infinitesimal. We propose the **standard part** of the
Born weight, $p_i = \mathrm{st}(w_i)$, as the rule governing what an observer
records, and we prove that it constitutes a coherent theory of measurement. Under
the natural hypotheses that all amplitudes are limited and the total weight is
appreciable, the observed probabilities are nonnegative, sum to $1$, are additive
over disjoint families of branches, and — decisively — assign probability
exactly $0$ to any branch of infinitesimal amplitude. Thus a branch may carry a
strictly positive weight in the exact ledger while being observationally
invisible. We show the same collapse arises in a purely classical
lexicographic-probability model, where the standard part reduces to projection
onto the leading (primary) layer, and we outline a hierarchy of visibility levels
indexed by infinitesimal order. The framework gives infinitesimal probabilities a
rigorous, conservative treatment: they are retained exactly in computation and
resolved only at the moment of observation.

**Keywords:** non-Archimedean field, infinitesimal, standard part, Born rule,
superposition, surreal numbers, lexicographic probability, quantum measurement,
finitely additive measure, orders of magnitude.

---

## 1. Introduction

The Born rule assigns to a superposition $|\psi\rangle = \sum_i \alpha_i |s_i\rangle$
the outcome probabilities $p_i \propto \alpha_i^2$. Classically the amplitudes
$\alpha_i$ are real (or complex) and the normalization $\sum_i p_i = 1$ is an
ordinary real identity. This paper asks what happens when the amplitudes are
allowed to range over a strictly larger ordered field — one containing genuine
infinitesimals. Such fields arise naturally: Conway's surreal numbers form the
largest ordered field and contain, alongside every real number, an entire scale
of infinities and infinitesimals; the hyperreals of nonstandard analysis and the
Levi-Civita field provide equally serviceable homes for the infinitely small.

The motivating puzzle is the status of an *infinitesimally weighted branch*. In
the exact arithmetic of the field, such a branch has a positive, nonzero weight,
and the total probability is conserved exactly. Yet no finite experiment can
distinguish an infinitesimal chance from zero. We resolve the tension with the
**standard part** map, the canonical ring homomorphism sending each limited field
element to the unique real number infinitesimally close to it. Applying it to the
Born weights yields observed probabilities that (i) reproduce ordinary
probability theory on the visible branches and (ii) annihilate every infinitesimal
branch, all while the underlying exact normalization is preserved. Infinitesimal
possibilities are thus *real in the ledger and invisible in the world*.

Our contributions are:

1. A precise definition of a **superposition over a non-Archimedean value field**
   and of its **observation functional** $p_i = \mathrm{st}(w_i)$ (Section 3).
2. Three core theorems — **exact normalization**, **standard normalization with
   nonnegativity**, and **unobservability of infinitesimal branches** (Section 4)
   — establishing that the observation functional is a legitimate probability
   assignment that suppresses the infinitely small.
3. A worked non-Archimedean example exhibiting a branch of positive weight and
   zero observed probability (Section 5).
4. A **classical lexicographic-probability model** exhibiting the identical
   collapse, identifying the standard part with projection onto the primary layer
   (Section 6).
5. A program of extensions: the observation functional as a finitely additive
   measure, observability as a scaling invariant, and a hierarchy of visibility
   levels indexed by infinitesimal order (Sections 7–8).

---

## 2. Non-Archimedean value fields and the standard part

Throughout, $F$ denotes an ordered field with $\mathbb{R} \subseteq F$ as an
ordered subfield, and $F$ is **non-Archimedean**: there exists $\varepsilon \in F$
with $0 < \varepsilon < 1/n$ for every positive integer $n$. Any such
$\varepsilon$ is called an **infinitesimal**. Concretely $F$ may be taken to be
the field of surreal numbers, a hyperreal field ${}^{\ast}\mathbb{R}$, or the
Levi-Civita field; only the order and field axioms plus the existence of an
infinitesimal are used.

**Definition 2.1 (Magnitude classes).** For $x \in F$:

- $x$ is **limited** (finite) if $|x| \le n$ for some positive integer $n$;
- $x$ is **infinitesimal** if $|x| < 1/n$ for every positive integer $n$
  (equivalently $|x| \le r$ for every real $r > 0$);
- $x$ is **appreciable** if $x$ is limited but not infinitesimal.

The limited elements form a subring $L \subseteq F$; the infinitesimals form an
ideal $I \subseteq L$; the appreciable elements are $L \setminus I$ together with
their sign data (equivalently, the limited elements whose reciprocal is also
limited). We record the arithmetic that drives every proof below.

**Lemma 2.2 (Magnitude arithmetic).**

1. A sum or product of limited elements is limited.
2. A product of an infinitesimal and a limited element is infinitesimal.
3. If $a$ is infinitesimal and $b$ is appreciable, then $a/b$ is infinitesimal.
4. The square of an infinitesimal is infinitesimal; the square of an appreciable
   element is appreciable.

*Proof.* (1)–(2) are immediate from the defining inequalities. For (3), $b$
appreciable means $1/b$ is limited, so $a/b = a\cdot(1/b)$ is infinitesimal by
(2). For (4), if $|a| \le r$ for all real $r>0$ then $|a|^2 \le r^2$ for all such
$r$, so $a^2$ is infinitesimal; if $b$ is appreciable then $|b| \ge c$ for some
real $c>0$ and $|b|\le n$ for some integer $n$, whence $c^2 \le b^2 \le n^2$. ∎

**Definition 2.3 (Standard part).** The **standard part** is the map
$\mathrm{st} : L \to \mathbb{R}$ sending a limited $x$ to the unique real number
$r$ with $x - r$ infinitesimal. (Existence and uniqueness of $r$ hold in every
non-Archimedean ordered field extension of $\mathbb R$ in which the limited
elements admit such a real shadow; this is standard for hyperreal and
Levi-Civita fields and is assumed as the defining property of the value field.)

**Proposition 2.4 (Properties of the standard part).** The map $\mathrm{st}$ is a
surjective ordered ring homomorphism:

1. $\mathrm{st}(x + y) = \mathrm{st}(x) + \mathrm{st}(y)$ and
   $\mathrm{st}(xy) = \mathrm{st}(x)\,\mathrm{st}(y)$ for $x, y \in L$;
2. $\mathrm{st}(r) = r$ for every real $r$; in particular $\mathrm{st}(1) = 1$;
3. $x \le y \implies \mathrm{st}(x) \le \mathrm{st}(y)$; hence $x \ge 0 \implies
   \mathrm{st}(x) \ge 0$;
4. for limited $x$, $\mathrm{st}(x) = 0$ if and only if $x$ is infinitesimal; the
   kernel of $\mathrm{st}$ is exactly the ideal $I$ of infinitesimals.

*Proof sketch.* Writing $x = \mathrm{st}(x) + \iota_x$ and $y = \mathrm{st}(y) +
\iota_y$ with $\iota_x, \iota_y$ infinitesimal, the sum and product identities
follow from Lemma 2.2: the error terms $\iota_x + \iota_y$ and
$\mathrm{st}(x)\iota_y + \mathrm{st}(y)\iota_x + \iota_x\iota_y$ are infinitesimal,
so the real parts are as claimed. Order preservation follows because a real
number strictly below $\mathrm{st}(x)$ stays below $x$. Statement (4) is the
definition of infinitesimal. ∎

Proposition 2.4 is the engine of the paper: it lets us transport an *exact*
non-Archimedean identity, term by term, into an ordinary real identity, while
sending every infinitesimal contribution to zero.

---

## 3. Superpositions over a value field

**Definition 3.1 (Superposition / quantum surreal state).** A **superposition
over $F$** is a finite indexed family
$$
|\psi\rangle = \big(\,(\alpha_i, s_i)\,\big)_{i=1}^n,
$$
where the **amplitudes** $\alpha_i \in F$ are field elements and the **branch
labels** $s_i$ are distinct symbols (interpreted as the possible measured values,
themselves drawn from $F$ or from any label set). We write it suggestively as
$|\psi\rangle = \sum_{i=1}^n \alpha_i\,|s_i\rangle$.

**Definition 3.2 (Total weight and Born weights).** The **total weight** of
$|\psi\rangle$ is
$$
Z(\psi) = \sum_{i=1}^n \alpha_i^2 \in F .
$$
When $Z(\psi) \ne 0$, the **Born weight** of branch $i$ is
$$
w_i = \frac{\alpha_i^2}{Z(\psi)} \in F .
$$

We call $|\psi\rangle$ **admissible** if every amplitude $\alpha_i$ is limited and
$Z(\psi)$ is appreciable. Admissibility is the exact non-Archimedean analogue of
"a well-normalizable state with bounded amplitudes."

**Definition 3.3 (Observation functional).** For an admissible superposition, the
**observed probability** of branch $i$ is
$$
p_i \;=\; \mathrm{st}(w_i) \;=\; \mathrm{st}\!\left(\frac{\alpha_i^2}{Z(\psi)}\right).
$$
For a subset $A \subseteq \{1,\dots,n\}$ of branches, the **observation
functional** is
$$
P(A) \;=\; \sum_{i \in A} p_i \;=\; \mathrm{st}\!\left(\sum_{i\in A} w_i\right),
$$
the second equality holding by additivity of $\mathrm{st}$.

Note that $w_i$ is limited whenever $|\psi\rangle$ is admissible: $\alpha_i^2$ is
limited by Lemma 2.2(4) and $1/Z$ is limited because $Z$ is appreciable, so the
standard part in Definition 3.3 is well defined.

---

## 4. Core theorems

Fix an admissible superposition $|\psi\rangle = \sum_{i=1}^n \alpha_i |s_i\rangle$
with total weight $Z = Z(\psi)$ and Born weights $w_i = \alpha_i^2 / Z$.

**Theorem 4.1 (Exact normalization).** In the field $F$,
$$
\sum_{i=1}^n w_i = 1 .
$$

*Proof.* $\sum_i w_i = \sum_i \alpha_i^2 / Z = \big(\sum_i \alpha_i^2\big)/Z =
Z/Z = 1$, valid since $Z \ne 0$. ∎

Exact normalization holds for *any* superposition with $Z \ne 0$, with no
appreciability hypothesis: probability is conserved perfectly at the level of the
value field.

**Theorem 4.2 (Nonnegativity and standard normalization).** The observed
probabilities satisfy $p_i \ge 0$ for all $i$ and
$$
\sum_{i=1}^n p_i = 1 .
$$

*Proof.* Each $w_i = \alpha_i^2 / Z \ge 0$: the numerator is a square hence
nonnegative, and $Z > 0$ since it is an appreciable sum of squares (a sum of
squares is $\ge 0$, and it is appreciable hence nonzero, so $> 0$). Order
preservation of $\mathrm{st}$ (Proposition 2.4(3)) gives $p_i = \mathrm{st}(w_i)
\ge 0$. For the sum, additivity of $\mathrm{st}$ and Theorem 4.1 yield
$$
\sum_i p_i = \sum_i \mathrm{st}(w_i) = \mathrm{st}\Big(\sum_i w_i\Big) =
\mathrm{st}(1) = 1 . \qquad \blacksquare
$$

**Theorem 4.3 (Unobservability of infinitesimal branches).** If the amplitude
$\alpha_k$ is infinitesimal, then $p_k = 0$.

*Proof.* By Lemma 2.2(4), $\alpha_k^2$ is infinitesimal. Since $Z$ is
appreciable, Lemma 2.2(3) gives $w_k = \alpha_k^2 / Z$ infinitesimal. By
Proposition 2.4(4), $p_k = \mathrm{st}(w_k) = 0$. ∎

**Corollary 4.4 (Coexistence of positive weight and zero observation).** If
$\alpha_k \ne 0$ is infinitesimal, then $w_k > 0$ in $F$ while $p_k = 0$. The
branch carries a strictly positive exact weight yet is observationally invisible.

*Proof.* $w_k = \alpha_k^2 / Z$ is a quotient of a positive element by a positive
element, hence positive; $p_k = 0$ by Theorem 4.3. ∎

**Theorem 4.5 (Finite additivity of the observation functional).** For disjoint
$A, B \subseteq \{1,\dots,n\}$,
$$
P(A \cup B) = P(A) + P(B), \qquad P(\varnothing) = 0, \qquad
P(\{1,\dots,n\}) = 1 .
$$
Consequently $P$ is a nonnegative, normalized, finitely additive set function on
the branch set — a finitely additive probability measure on the (finite) branch
$\sigma$-algebra.

*Proof.* Immediate from Definition 3.3 and additivity of finite sums: for
disjoint $A,B$, $\sum_{i\in A\cup B} p_i = \sum_{i\in A}p_i + \sum_{i\in B}p_i$.
The empty sum is $0$; the full sum is $1$ by Theorem 4.2; nonnegativity is
Theorem 4.2. ∎

Theorems 4.1–4.5 together say that the observation functional is a *bona-fide*
measurement rule: it conserves total probability exactly at the field level,
descends to an ordinary real probability distribution on the branches, and
suppresses precisely the infinitesimal branches.

---

## 5. A worked example

Let $\varepsilon \in F$ be a positive infinitesimal and consider the three-branch
superposition
$$
|\psi\rangle = \tfrac{1}{\sqrt{2}}\,|0\rangle + \tfrac{1}{\sqrt{2}}\,|1\rangle
              + \tfrac{1}{\sqrt{2}}\,\varepsilon\,|\varepsilon\rangle .
$$
The amplitudes are $\alpha_0 = \alpha_1 = \tfrac{1}{\sqrt2}$ (appreciable) and
$\alpha_\varepsilon = \tfrac{1}{\sqrt2}\varepsilon$ (infinitesimal), all limited.
The total weight is
$$
Z = \tfrac12 + \tfrac12 + \tfrac12\varepsilon^2 = 1 + \tfrac12\varepsilon^2,
$$
which is appreciable (it differs from the real number $1$ by an infinitesimal),
so $|\psi\rangle$ is admissible. The Born weights are
$$
w_0 = w_1 = \frac{1/2}{1 + \tfrac12\varepsilon^2}, \qquad
w_\varepsilon = \frac{\tfrac12\varepsilon^2}{1 + \tfrac12\varepsilon^2},
$$
and they sum to $1$ exactly (Theorem 4.1). Applying the standard part, and using
$\mathrm{st}(1 + \tfrac12\varepsilon^2) = 1$:
$$
p_0 = p_1 = \mathrm{st}\!\left(\frac{1/2}{1+\tfrac12\varepsilon^2}\right) =
\tfrac12, \qquad
p_\varepsilon = \mathrm{st}\!\left(\frac{\tfrac12\varepsilon^2}{1+\tfrac12
\varepsilon^2}\right) = 0 .
$$
The observer records outcome $0$ with probability $\tfrac12$, outcome $1$ with
probability $\tfrac12$, and the infinitesimal branch *never* — consistent with
Theorem 4.3 — while the observed probabilities sum to $1$ as guaranteed by
Theorem 4.2. This is the promised phenomenon: a branch present in the state, with
a strictly positive exact weight $w_\varepsilon > 0$, that is nonetheless
observationally invisible.

---

## 6. The classical mirror: lexicographic probability

The collapse of Section 4 is not special to amplitudes or to squaring; it is a
structural consequence of ranking possibilities by order of magnitude. We
exhibit the same phenomenon in a purely classical model.

**Definition 6.1 (Lexicographic probability system).** A **lexicographic
probability system** of depth $d$ on outcomes $\{1,\dots,n\}$ is an assignment to
each outcome $i$ of a vector
$$
\mathbf{q}_i = (q_i^{(0)}, q_i^{(1)}, \dots, q_i^{(d-1)}) \in \mathbb{R}_{\ge 0}^{d},
$$
whose level-$\ell$ marginals $\sum_i q_i^{(\ell)}$ are each equal to $1$ (each
level is itself a probability distribution). Outcomes are compared
lexicographically: $i$ is deemed *more likely* than $j$ if $q_i^{(0)} > q_j^{(0)}$,
or if they tie at level $0$ and $q_i^{(1)} > q_j^{(1)}$, and so on.

Such systems formalize beliefs in which some events are regarded as *infinitely*
less likely than others but not impossible. Encode a depth-$d$ system in the value
field via
$$
Q_i = q_i^{(0)} + q_i^{(1)}\varepsilon + q_i^{(2)}\varepsilon^2 + \cdots +
q_i^{(d-1)}\varepsilon^{d-1} \in F .
$$

**Proposition 6.2 (Lexicographic collapse).** With $Q_i$ as above,
$\sum_i Q_i = 1 + (\text{infinitesimal})$ is appreciable, each $Q_i$ is limited,
and the observation functional recovers the **primary layer**:
$$
\mathrm{st}\!\left(\frac{Q_i}{\sum_j Q_j}\right) = q_i^{(0)} .
$$
In particular an outcome with $q_i^{(0)} = 0$ but $q_i^{(1)} > 0$ — one that is
possible only at the secondary, infinitely-less-likely level — has observed
probability $0$.

*Proof.* $\sum_j Q_j = \sum_j q_j^{(0)} + (\sum_j q_j^{(1)})\varepsilon + \cdots =
1 + (\text{infinitesimal})$ because the level-$0$ marginal is $1$; this is
appreciable, so $\mathrm{st}(\sum_j Q_j) = 1$. Each $Q_i$ has real part
$q_i^{(0)}$, so $\mathrm{st}(Q_i) = q_i^{(0)}$. By multiplicativity of
$\mathrm{st}$ (Proposition 2.4), $\mathrm{st}(Q_i / \sum_j Q_j) =
\mathrm{st}(Q_i)/\mathrm{st}(\sum_j Q_j) = q_i^{(0)}/1 = q_i^{(0)}$. ∎

Thus the standard part is exactly *projection onto the primary layer* of a
lexicographic system, and the quantum unobservability theorem (Theorem 4.3) and
the classical lexicographic collapse (Proposition 6.2) are one theorem viewed
through two windows. The correspondence identifies "infinitesimal amplitude" with
"vanishing primary probability, positive secondary probability."

---

## 7. Algorithms

The framework is fully computable when $F$ is represented by truncated
$\varepsilon$-expansions (finite Laurent series in $\varepsilon$), as in the
Levi-Civita field. We record the two central procedures.

**Algorithm A (Observed probability distribution).**
*Input:* amplitudes $\alpha_1,\dots,\alpha_n$ as truncated $\varepsilon$-series.
*Output:* observed probabilities $p_1,\dots,p_n \in \mathbb{R}$.

```
1.  for i in 1..n:  a_i ← square(alpha_i)          # truncated-series product
2.  Z ← sum(a_1, ..., a_n)                          # truncated-series sum
3.  assert Z is appreciable                          # leading (order-0) term ≠ 0
4.  for i in 1..n:  w_i ← divide(a_i, Z)            # series inverse of Z, then ×
5.  for i in 1..n:  p_i ← standardPart(w_i)         # order-0 coefficient of w_i
6.  return (p_1, ..., p_n)
```

Correctness is Theorems 4.1–4.3; the output sums to $1$ by Theorem 4.2. With
series truncated at order $d$ and $n$ branches, each product/inverse costs
$O(d^2)$ and the whole procedure runs in $O(n\,d^2)$ time.

**Algorithm B (Visibility level of a branch).**
*Input:* amplitude $\alpha_k$ and total weight $Z$ as truncated series; refinement
depth $m$. *Output:* the smallest $\ell \le m$ at which branch $k$ becomes
visible, or "hidden beyond depth $m$."

```
1.  w_k ← divide(square(alpha_k), Z)
2.  v ← valuation(w_k)          # least power of ε with nonzero coefficient
3.  if v > m: return "hidden beyond depth m"
4.  return v                     # branch is first seen by the ε^v-refined lens
```

Algorithm B computes the level in the visibility hierarchy of Section 8: a branch
of weight $\sim \varepsilon^{\,v}$ is invisible to the ordinary standard part
(which is the $v=0$ lens) whenever $v \ge 1$, and is first resolved by the
$v$-th-order refined standard part.

---

## 8. Extensions and future directions

**8.1 The observation functional as a finitely additive measure (settled in part).**
Theorem 4.5 already establishes that $P$ is a nonnegative, normalized, finitely
additive set function on the finite branch algebra. The natural closure is to
extend this to superpositions with countably many branches and to identify the
resulting object as a genuine (finitely additive) probability measure on the full
branch set. The key mechanism is unchanged: because $\mathrm{st}$ is a ring
homomorphism on the limited elements, it transports the exact non-Archimedean
normalization identity to a real normalization identity term by term.

**8.2 Observability as a scaling invariant.** Say two superpositions are
*appreciably equivalent* if their amplitude vectors are related by multiplication
by a single appreciable factor (possibly branch-dependent but bounded above and
below by appreciable constants). We conjecture that observability is an invariant
of this equivalence: a branch unobservable in one representative is unobservable
in every representative. The reason is that observability depends only on the
*order of magnitude* of an amplitude relative to the total weight, and appreciable
rescalings do not change orders of magnitude — they multiply $w_i$ by an
appreciable factor, which cannot move an infinitesimal into the appreciable range
or vice versa.

**8.3 A hierarchy of visibility levels.** A single standard part resolves only the
leading real component of a weight. Refining the value field with higher-order
infinitesimals yields a sequence of successively finer observation functionals
$\mathrm{st}_0, \mathrm{st}_1, \mathrm{st}_2, \dots$, where $\mathrm{st}_k$ reads
the coefficient of $\varepsilon^k$. We conjecture that iterating the construction
produces a *strict* tower of visibility levels: a branch of weight
$\sim \varepsilon^{k}$ is invisible to $\mathrm{st}_0, \dots, \mathrm{st}_{k-1}$
but visible to $\mathrm{st}_k$, yielding a filtration of the state space by how
deeply a branch is hidden. The lexicographic model of Section 6 realizes this
tower explicitly: level $k$ corresponds to the $k$-th entry of the lexicographic
vector, and Algorithm B computes a branch's position in the tower.

---

## 9. Discussion

The proposal is deliberately conservative. Nothing about ordinary quantum
mechanics or ordinary probability is altered on the visible branches: the
observed distribution is an honest real probability distribution obeying the Born
rule. What the enlargement buys is a rigorous vocabulary for possibilities that
the real line is too coarse to record. An infinitesimal branch is neither
rounded to zero by fiat (which discards information) nor treated as a small real
number (which misrepresents an *infinitely* unlikely event as merely a *very*
unlikely one). Instead it is kept exactly throughout computation and resolved by a
single principled map at the moment of observation.

The dual appearance of the collapse — quantum in Section 4, classical
lexicographic in Section 6 — suggests that the phenomenon is fundamentally about
*orders of magnitude of belief or weight*, independent of the quantum
superstructure. This positions the standard-part measurement rule as a general
bridge between non-Archimedean analysis and the theory of chance.

## 10. Conclusion

We have shown that when the amplitudes of a finite superposition are drawn from a
non-Archimedean ordered field, the standard part of the Born weights is the
correct measurement rule. It preserves total probability exactly (Theorems 4.1
and 4.2), respects nonnegativity and finite additivity (Theorems 4.2 and 4.5),
and renders infinitesimal branches observationally invisible (Theorem 4.3,
Corollary 4.4) — as illustrated by an explicit three-branch state (Section 5) and
mirrored by a classical lexicographic model (Section 6). The extensions of
Section 8 chart a path toward a full non-Archimedean measurement theory, a
scaling-invariance principle for observability, and a graded hierarchy of hidden
branches. Infinitesimal probabilities, long treated informally, acquire a precise
and well-behaved home.
