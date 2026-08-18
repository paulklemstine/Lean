# The Subset Spectrum of a Finite Group Action: Failure of Log-Concavity, a Rigidity Theorem, and Sharp Guarded Substitutes

**Author:** Aristotle

**Date:** 2026-08-18

---

## Abstract

Let a finite group $G$ act on a finite set $X$ with $|X| = n$. The **subset
spectrum** of the action is the sequence $t_0, t_1, \dots, t_n$, where $t_r$ is
the number of $G$-orbits on the $r$-element subsets of $X$. We investigate the
natural conjecture that this sequence is always log-concave, that is, that
$t_r^2 \ge t_{r-1} t_{r+1}$ for $1 \le r < n$.

We prove that the conjecture is **false**, and we determine exactly when it
holds. The smallest counterexample is the regular action of the cyclic group of
order $4$ on four points, whose spectrum $(1,1,2,1,1)$ fails log-concavity at
$r=1$. More is true: we establish a *collapse principle* showing that two
consecutive spectrum values equal to $1$, together with log-concavity, force all
subsequent values to equal $1$. Since a transitive action satisfies $t_0 = t_1 =
1$, this yields the

> **Rigidity Theorem.** For a transitive action, the subset spectrum is
> log-concave if and only if the action is set-transitive, i.e. $t_r = 1$ for
> every $r \le n$.

Consequently a log-concave transitive action obeys $\binom{n}{r} \le |G|$ for
every $r$, hence $|G| \ge \binom{n}{\lfloor n/2\rfloor}$, and every *regular*
action on $n \ge 4$ points is a counterexample. Log-concavity, normally a soft
regularity property, is here an exact characterisation of the finite list of
set-transitive permutation groups.

We then supply two guarded substitutes valid for every finite action: the
group-size guard $t_{r-1} t_{r+1} \le |G|^2 t_r^2$, obtained from the sandwich
$\binom{n}{r}/|G| \le t_r \le \binom{n}{r}$ together with log-concavity of the
binomial row, and the group-free shadow guard $t_{r-1} t_{r+1} \le r(n-r) t_r^2$,
obtained from the extension and deletion inequalities $t_{r+1} \le (n-r) t_r$
and $t_r \le (r+1) t_{r+1}$. Supporting structural results — the complementation
symmetry $t_r = t_{n-r}$, the identification of $t_r$ with the cardinality of an
orbit quotient, Burnside's mass formula for the spectrum, and a self-contained
proof of log-concavity of the binomial coefficients — are developed along the
way. We close with computational evidence and three sharpened conjectures.

**Keywords:** subset spectrum, permutation group, orbit counting, log-concavity,
set-transitive group, homogeneous permutation group, shadow inequality,
Livingstone–Wagner theorem, binary necklaces.

---

## 1. Introduction

### 1.1 Motivation

Log-concavity is one of the organising principles of modern enumerative
combinatorics. A sequence $a_0, a_1, \dots, a_n$ of nonnegative reals is
**log-concave** if $a_r^2 \ge a_{r-1} a_{r+1}$ for $1 \le r < n$; equivalently,
the sequence $\log a_r$ is concave where defined. Log-concave sequences without
internal zeros are unimodal, and log-concavity has been established for an
extraordinary variety of combinatorial sequences: the coefficients of the
characteristic polynomial of a matroid, matching polynomials, the number of
independent sets of each size in a matroid, and the coefficients of any
polynomial with only real nonpositive roots. Because so many "natural" counting
sequences turn out to be log-concave, it is reasonable to conjecture the
property whenever a new family of sequences appears.

This paper concerns one such family. Given an action of a finite group $G$ on a
finite set $X$ of size $n$, the induced action on subsets partitions the
$r$-element subsets into orbits, and one may count them:
$$t_r := \#\{\,G\text{-orbits on the } r\text{-element subsets of } X\,\}.$$
The resulting sequence $t_0, \dots, t_n$, which we call the **subset spectrum**,
is a classical invariant of a permutation group; it is the sequence appearing in
the Livingstone–Wagner monotonicity theorem and in Cameron's work on orbits on
$n$-sets, and for the cyclic group acting regularly it enumerates binary
necklaces by weight.

The subset spectrum is squeezed between two log-concave sequences: it is at most
the binomial row $\binom{n}{r}$ (which it equals when $G$ is trivial) and at
least $\binom{n}{r}/|G|$; it is symmetric, $t_r = t_{n-r}$; and it equals the
constant sequence $1,1,\dots,1$ for the full symmetric group. On this evidence
one is led to the

> **Conjecture (log-concavity of the spectrum).** For every action of a finite
> group on a finite set, $t_r^2 \ge t_{r-1} t_{r+1}$ for all $1 \le r < n$.

### 1.2 Results

The conjecture is false, and the failure is structural rather than accidental.
Our contributions are as follows.

1. **A complete structural theory of the spectrum** (Section 3): boundary values,
   support, the complementation symmetry, the two-sided binomial sandwich, the
   identification of $t_r$ as the cardinality of an orbit quotient, Burnside's
   mass formula, and the characterisation of $t_r = 1$ as $r$-homogeneity.

2. **Refutation** (Section 4): the regular action of $C_4$ on four points has
   spectrum $(1,1,2,1,1)$ and violates log-concavity at $r = 1$.

3. **Collapse principle and Rigidity Theorem** (Section 5): log-concavity
   propagates the value $1$ forward, so for a transitive action log-concavity is
   *equivalent* to set-transitivity. Corollaries: the cardinality obstruction
   $\binom{n}{r} \le |G|$, and the failure of log-concavity for every regular
   action on $n \ge 4$ points.

4. **Guarded substitutes** (Section 6): $t_{r-1} t_{r+1} \le |G|^2 t_r^2$ for
   every finite action, and the group-free shadow bound $t_{r-1} t_{r+1} \le
   r(n-r) t_r^2$, derived from extension and deletion inequalities on orbits.

5. **Computational evidence and algorithms** (Section 7), and **three sharpened
   conjectures** (Section 9).

### 1.3 Notation

Throughout, $G$ is a finite group acting on a finite set $X$ with $n := |X|$,
and $r, k, m$ denote nonnegative integers. For $g \in G$ and $s \subseteq X$ we
write $g \cdot s := \{g\cdot x : x \in s\}$; this is the induced action of $G$
on the power set of $X$, and it preserves cardinality because each $g$ acts
injectively. We write $\binom{n}{r}$ for the binomial coefficient, with the
convention $\binom{n}{r} = 0$ for $r > n$. An **action** always means a group
action; **transitive** means transitive on points; **$r$-homogeneous** means
transitive on $r$-element subsets; **set-transitive** means $r$-homogeneous for
every $0 \le r \le n$; **regular** means transitive with $|G| = |X|$.

---

## 2. The subset spectrum

**Definition 2.1 (induced action on subsets).** For $g \in G$ and a finite
subset $s \subseteq X$, put $g \cdot s = \{g\cdot x : x \in s\}$. Then
$1 \cdot s = s$, $(gh)\cdot s = g\cdot(h\cdot s)$, and $|g\cdot s| = |s|$, so
this is an action of $G$ on the set of $r$-element subsets of $X$, for each $r$.
It also commutes with complementation: $g \cdot (X\setminus s) = X \setminus
(g\cdot s)$.

**Definition 2.2 (orbit of a subset).** For $s \subseteq X$ let $\mathcal{O}(s)
:= \{g\cdot s : g \in G\}$ denote its orbit. Membership in an orbit is an
equivalence: if $u \in \mathcal{O}(s)$ then $\mathcal{O}(u) = \mathcal{O}(s)$,
and $|u| = |s|$. In particular $|\mathcal{O}(s)| \le |G|$.

**Definition 2.3 (subset spectrum).** For $0 \le r$, the $r$-th term of the
subset spectrum of the action is
$$t_r \;=\; t_r(G, X) \;:=\; \#\bigl\{\,\mathcal{O}(s) \;:\; s \subseteq X,\ |s| = r\,\bigr\},$$
the number of distinct orbits of $r$-element subsets. The sequence $(t_r)_{0\le
r\le n}$ is the **subset spectrum** of the action.

Two remarks on the definition. First, $t_r$ is a manifestly computable quantity:
enumerate the $r$-element subsets, compute the orbit of each, and count distinct
orbits. Second, the definition is intrinsic: it depends only on the
permutation group image of $G$ in the symmetric group on $X$, since the orbit of
a subset depends only on which permutations of $X$ arise from group elements.

**Proposition 2.4 (spectrum as orbit quotient).** Let $\Sigma_r$ denote the set
of $r$-element subsets of $X$ with its induced $G$-action, and let
$\Sigma_r / G$ denote the set of orbits under the orbit equivalence relation.
Then $t_r = |\Sigma_r / G|$.

*Proof sketch.* The map $\Sigma_r/G \to \{\text{orbits}\}$, $[s] \mapsto
\mathcal{O}(s)$, is well defined (equivalent subsets have equal orbits) and
injective (if $\mathcal{O}(s) = \mathcal{O}(u)$ then $u \in \mathcal{O}(s)$, so
$u = g \cdot s$ for some $g$, so $[s] = [u]$). It is surjective onto the set of
orbits of $r$-subsets by construction. Counting both sides gives the claim.
$\square$

Proposition 2.4 licenses all standard orbit-counting machinery. In particular:

**Theorem 2.5 (Burnside mass formula for the spectrum).**
$$t_r \cdot |G| \;=\; \sum_{g \in G} \#\{\, s \subseteq X : |s| = r,\ g\cdot s = s \,\}.$$

*Proof sketch.* By Proposition 2.4, $t_r$ is the number of orbits of $G$ on
$\Sigma_r$. Burnside's lemma (the orbit-counting lemma) states that the number
of orbits times $|G|$ equals the total number of incidences $(g, s)$ with $g
\cdot s = s$. Rewriting the fixed-point set of $g$ in $\Sigma_r$ as the set of
$r$-subsets fixed setwise by $g$ gives the displayed identity. $\square$

The identity element contributes $\binom{n}{r}$ to the right-hand sum, which
already yields the lower half of the sandwich in Theorem 3.4 below; but we shall
also give a direct covering proof.

---

## 3. Structural theory

### 3.1 Boundary values and support

**Proposition 3.1.** $t_0 = 1$ and $t_n = 1$.

*Proof.* There is exactly one $0$-element subset (the empty set) and exactly one
$n$-element subset ($X$ itself); each forms a single orbit. $\square$

**Proposition 3.2.** If $r > n$ then $t_r = 0$; if $r \le n$ then $t_r \ge 1$.

*Proof.* For $r > n$ there are no $r$-element subsets. For $r \le n$ there is at
least one, hence at least one orbit. $\square$

Thus the spectrum is supported precisely on $\{0, 1, \dots, n\}$, and is
strictly positive there. Positivity is essential to the collapse principle of
Section 5: it converts an upper bound of $1$ into an equality.

### 3.2 Complementation symmetry

**Theorem 3.3 (complementation symmetry).** For $0 \le r \le n$,
$$t_r = t_{n-r}.$$

*Proof sketch.* Complementation $s \mapsto s^{\mathsf c} := X \setminus s$ is a
bijection from $r$-element subsets to $(n-r)$-element subsets, and it intertwines
the $G$-actions: $g\cdot (s^{\mathsf c}) = (g \cdot s)^{\mathsf c}$. Hence it
maps the orbit $\mathcal{O}(s)$ onto the orbit $\mathcal{O}(s^{\mathsf c})$,
and the induced map on orbits is a bijection because complementation is an
involution. Counting orbits on both sides gives $t_r = t_{n-r}$. $\square$

The symmetry is the source of the "palindromic" look of every spectrum, and it
is used to derive the deletion inequality from the extension inequality in
Section 6.

### 3.3 The binomial sandwich

**Theorem 3.4 (two-sided sandwich).** For every $r$,
$$\binom{n}{r} \;\le\; |G| \cdot t_r \qquad\text{and}\qquad t_r \;\le\; \binom{n}{r};$$
equivalently $\binom{n}{r}/|G| \le t_r \le \binom{n}{r}$.

*Proof sketch.* The upper bound: the map $s \mapsto \mathcal{O}(s)$ sends the
$\binom{n}{r}$ subsets of size $r$ onto the set of orbits, so the number of
orbits is at most the number of subsets. The lower bound: the $r$-element
subsets are covered by the union of the orbits, of which there are $t_r$; each
orbit has at most $|G|$ elements, since it is the image of $G$ under $g \mapsto
g \cdot s$. Hence $\binom{n}{r} \le \sum_{\mathcal{O}} |\mathcal{O}| \le t_r
|G|$. $\square$

### 3.4 The two extreme actions

**Proposition 3.5 (trivial action).** If $g \cdot x = x$ for all $g \in G$ and
$x \in X$, then every orbit of subsets is a singleton and hence
$$t_r = \binom{n}{r} \quad \text{for all } r.$$

*Proof.* $\mathcal{O}(s) = \{s\}$ for every $s$, so $s \mapsto \mathcal{O}(s)$
is injective and the number of orbits equals the number of subsets. $\square$

**Proposition 3.6 (symmetric group).** If $G$ is the full symmetric group on
$X$, then $t_r = 1$ for every $r \le n$; that is, the symmetric group is
set-transitive.

*Proof sketch.* Given $r$-element subsets $s, u$, choose a bijection $s \to u$
and a bijection $X\setminus s \to X\setminus u$ (both exist since $|s| = |u| =
r$ forces $|X\setminus s| = |X \setminus u| = n - r$); their union is a
permutation of $X$ carrying $s$ to $u$. $\square$

### 3.5 The value $1$ and homogeneity

**Theorem 3.7 ($t_r = 1$ is $r$-homogeneity).** For $r \le n$,
$$t_r = 1 \iff \text{for all } s, u \subseteq X \text{ with } |s| = |u| = r
\text{ there is } g \in G \text{ with } g \cdot s = u.$$

*Proof sketch.* ($\Rightarrow$) If there is only one orbit, then $\mathcal{O}(s)
= \mathcal{O}(u)$ for any two $r$-subsets, so $u \in \mathcal{O}(s)$, i.e. $u =
g\cdot s$ for some $g$. ($\Leftarrow$) Fix an $r$-subset $s_0$ (one exists as
$r \le n$). Every $r$-subset lies in $\mathcal{O}(s_0)$, so there is a unique
orbit. $\square$

**Corollary 3.8 ($t_1 = 1$ is transitivity).** For nonempty $X$, $t_1 = 1$ if
and only if the action is transitive on points.

*Proof.* Apply Theorem 3.7 with $r = 1$ and identify singletons $\{x\}$ with
points $x$: $g \cdot \{x\} = \{g\cdot x\}$. $\square$

### 3.6 Log-concavity of the binomial row

We shall need the classical fact that Pascal's rows are log-concave, in the
sharp integer form. We include a short self-contained proof.

**Lemma 3.9 (log-concavity of binomial coefficients).** For all $n, k \ge 0$,
$$\binom{n}{k}\binom{n}{k+2} \;\le\; \binom{n}{k+1}^2 .$$

*Proof.* If $k + 1 \ge n$ then $\binom{n}{k+2} = 0$ and the claim is trivial, so
assume $k+1 < n$. Write $a = \binom{n}{k}$, $b = \binom{n}{k+1}$, $c =
\binom{n}{k+2}$, and set $m = n - (k+1) \ge 1$. The Pascal-type identity
$\binom{n}{j+1}(j+1) = \binom{n}{j}(n-j)$ gives
$$b(k+1) = a(n-k) = a(m+1), \qquad c(k+2) = b\,m .$$
Then
$$ac \cdot (k+1)(k+2) = \bigl(a(k+1)\bigr)\bigl(c(k+2)\bigr)
= a(k+1)\cdot b m = ab \cdot (k+1)m,$$
while
$$b^2 (k+1)(k+2) = \bigl(b(k+1)\bigr)\bigl(b(k+2)\bigr) = a(m+1)\cdot b(k+2)
= ab\cdot (m+1)(k+2).$$
Since $(k+1)m \le (m+1)(k+2)$ — indeed $(m+1)(k+2) - (k+1)m = m + 2k + 4 > 0$ —
we get $ac(k+1)(k+2) \le b^2(k+1)(k+2)$, and cancelling the positive factor
$(k+1)(k+2)$ yields $ac \le b^2$. $\square$

---

## 4. Refutation of the conjecture

**Definition 4.1.** The subset spectrum of an action is **log-concave** if
$$t_{r-1}\, t_{r+1} \;\le\; t_r^2 \qquad \text{for all } 1 \le r < n .$$
Equivalently (reindexing $r = k+1$): $t_k t_{k+2} \le t_{k+1}^2$ whenever
$k + 2 \le n$.

**Proposition 4.2 (the property is not vacuous).** For the trivial action the
spectrum is log-concave; likewise for the full symmetric group.

*Proof.* By Proposition 3.5 the trivial action has $t_r = \binom{n}{r}$, and
Lemma 3.9 applies. By Proposition 3.6 the symmetric group has $t_r \equiv 1$,
and $1 \cdot 1 \le 1^2$. $\square$

**Theorem 4.3 (counterexample).** Let $C_4$ act on the four-element set
$\mathbb{Z}/4$ by translation. Its subset spectrum is
$$(t_0, t_1, t_2, t_3, t_4) = (1, 1, 2, 1, 1),$$
and log-concavity fails at $r = 1$:
$$t_0 \, t_2 = 2 \;>\; 1 = t_1^2 .$$

*Proof.* $t_0 = t_4 = 1$ by Proposition 3.1. The action is transitive, so $t_1 =
1$ by Corollary 3.8, and $t_3 = t_1 = 1$ by Theorem 3.3. The six $2$-element
subsets split into the four "adjacent" pairs $\{i, i+1\}$ and the two "opposite"
pairs $\{i, i+2\}$; translation preserves the difference of the two elements up
to sign, so these two families are distinct orbits, giving $t_2 = 2$. Then
$t_0 t_2 = 2 > 1 = t_1^2$. $\square$

**Corollary 4.4.** It is not the case that the subset spectrum of every action
of a finite group on a finite set is log-concave.

The counterexample is minimal. For $n \le 3$ every spectrum is log-concave: the
possible spectra are $(1,1)$ and $(1,2,1)$ in degree $2$, and $(1,1,1,1)$,
$(1,2,2,1)$ and $(1,3,3,1)$ in degree $3$, all of which satisfy the inequality.
In degree $4$ an exhaustive scan of all subgroups of the symmetric group shows
that the failures are precisely the transitive subgroups that are not
$2$-homogeneous, namely the three cyclic groups $C_4$ and the three dihedral
groups of a square (all with spectrum $(1,1,2,1,1)$) together with the regular
Klein four-group (spectrum $(1,1,3,1,1)$): seven subgroups in all. Every
intransitive action of degree $4$ is log-concave.

---

## 5. Rigidity: when log-concavity does hold

### 5.1 The collapse principle

**Theorem 5.1 (propagation of the value $1$).** Suppose $t_m = t_{m+1} = 1$ for
some $m$, and suppose the spectrum is log-concave. Then $t_r = 1$ for every $r$
with $m \le r \le n$.

*Proof.* We show by induction on $j \ge 0$ that, as long as the indices stay
$\le n$, the pair $(t_{m+j}, t_{m+j+1})$ equals $(1,1)$.

*Base case.* $j = 0$ is the hypothesis.

*Inductive step.* Suppose $t_{m+j} = t_{m+j+1} = 1$ and $m+j+2 \le n$.
Log-concavity at index $m+j+1$ reads
$$t_{m+j}\, t_{m+j+2} \le t_{m+j+1}^2 = 1,$$
and since $t_{m+j} = 1$ we obtain $t_{m+j+2} \le 1$. On the other hand $m+j+2
\le n$ gives $t_{m+j+2} \ge 1$ by Proposition 3.2. Hence $t_{m+j+2} = 1$ and the
pair $(t_{m+j+1}, t_{m+j+2})$ is again $(1,1)$. $\square$

The two ingredients are exactly: (i) log-concavity, which turns two consecutive
$1$s into an upper bound of $1$ on the next term; and (ii) positivity of the
spectrum on its support, which turns that upper bound into an equality. Note
that positivity is where the finiteness of $X$ enters: beyond $r = n$ the
spectrum vanishes and the propagation stops (harmlessly).

### 5.2 The Rigidity Theorem

**Theorem 5.2 (Rigidity).** Suppose the action is transitive, i.e. $t_1 = 1$.
Then the following are equivalent:

1. the subset spectrum is log-concave;
2. $t_r = 1$ for every $0 \le r \le n$, i.e. the action is set-transitive.

*Proof.* (2) $\Rightarrow$ (1): if all $t_r = 1$, then $t_{r-1}t_{r+1} = 1 =
t_r^2$.

(1) $\Rightarrow$ (2): if $n = 0$ then $r = 0$ and $t_0 = 1$. Otherwise
$t_0 = 1$ (Proposition 3.1) and $t_1 = 1$ (transitivity), so Theorem 5.1 with
$m = 0$ gives $t_r = 1$ for all $0 \le r \le n$. $\square$

This is a rigidity statement in the strict sense: within the class of transitive
actions, log-concavity does not hold "generically with exceptions"; it holds
*only* at the single most degenerate point of the parameter space, where the
spectrum is constant. There is no intermediate behaviour.

### 5.3 Numerical consequences

**Corollary 5.3 (cardinality obstruction).** If the action is transitive and the
spectrum is log-concave, then
$$\binom{n}{r} \le |G| \qquad \text{for every } 0 \le r \le n;$$
in particular $|G| \ge \binom{n}{\lfloor n/2 \rfloor} \sim 2^n\sqrt{2/(\pi n)}$.

*Proof.* By Theorem 5.2, $t_r = 1$; substitute into the lower sandwich bound
$\binom{n}{r} \le |G|\, t_r$ of Theorem 3.4. $\square$

**Corollary 5.4 (smallness forbids log-concavity).** If the action is transitive
and $|G| < \binom{n}{r}$ for some $r \le n$, then the spectrum is **not**
log-concave.

**Theorem 5.5 (all regular actions of degree $\ge 4$ fail).** Let the action be
regular, i.e. transitive with $|G| = |X| = n$ (for instance, a group acting on
itself by translation). If $n \ge 4$ then the spectrum is not log-concave.

*Proof.* For $n \ge 4$ we have $\binom{n}{2} = n(n-1)/2 > n$, since $n - 1 > 2$.
Thus $|G| = n < \binom{n}{2}$ and Corollary 5.4 applies with $r = 2$. $\square$

**Corollary 5.6 (an infinite family).** For every $n \ge 4$, the regular action
of the cyclic group $C_n$ on $n$ points has a non-log-concave spectrum. The
same holds for every group of order $n \ge 4$ acting on itself by translation.

**Corollary 5.7 (contrapositive form).** A transitive action that is not
$2$-homogeneous (i.e. $t_2 \ge 2$) with $n \ge 2$ is not log-concave.

*Proof.* Theorem 5.2 would force $t_2 = 1$. $\square$

Corollary 5.7 is the practical criterion: transitive but not $2$-homogeneous is
the generic situation for permutation groups, so the conjecture fails generically.
The groups that survive are the set-transitive ones, and these form a very
restricted class: the symmetric groups (set-transitive in every degree), the
alternating groups, and a short list of exceptional examples, of which the
affine group $\mathrm{AGL}(1,5)$ of order $20$ acting on five points is the
smallest. Our computations in Section 7 recover exactly these among the groups
we scan.

---

## 6. Guarded substitutes valid for all actions

Since log-concavity with constant $1$ fails, we ask for the best constant $C =
C(n, r, G)$ such that $t_{r-1} t_{r+1} \le C \cdot t_r^2$ holds for all finite
actions. Two answers follow.

### 6.1 The group-size guard

**Theorem 6.1.** For every finite action and every $r \ge 1$,
$$t_{r-1}\, t_{r+1} \;\le\; |G|^2\, t_r^2 .$$

*Proof.* Write $r = k+1$. By the upper sandwich bound of Theorem 3.4,
$$t_k\, t_{k+2} \le \binom{n}{k}\binom{n}{k+2}.$$
By Lemma 3.9 this is at most $\binom{n}{k+1}^2$. By the lower sandwich bound,
$\binom{n}{k+1} \le |G|\, t_{k+1}$, so
$$t_k t_{k+2} \le \bigl(|G| t_{k+1}\bigr)^2 = |G|^2 t_{k+1}^2 . \qquad\square$$

Theorem 6.1 says the conjecture is true up to the factor $|G|^2$. It is
qualitatively meaningful — the deviation from log-concavity is controlled by the
group and by nothing else — but quantitatively poor for large groups, and the
constant is not intrinsic to the combinatorics.

### 6.2 Shadow inequalities

The following two bounds are the combinatorial heart of the group-free guard.
They are shadow (deletion/extension) inequalities transported from subsets to
orbits.

**Theorem 6.2 (extension bound).** For every $r \ge 0$,
$$t_{r+1} \;\le\; (n - r)\, t_r .$$

*Proof sketch.* Choose, for each orbit $\mathcal{O}$ of $r$-subsets, a
representative $\rho(\mathcal{O}) \in \mathcal{O}$; this is an $r$-subset. We
claim that every orbit of $(r+1)$-subsets is of the form $\mathcal{O}\bigl(
\rho(\mathcal{O}) \cup \{x\}\bigr)$ for some orbit $\mathcal{O}$ of $r$-subsets
and some point $x \notin \rho(\mathcal{O})$.

Indeed, let $u$ be an $(r+1)$-subset. Choose $s \subseteq u$ with $|s| = r$, and
let $\mathcal{O} = \mathcal{O}(s)$ with representative $\rho = \rho(\mathcal{O})
\in \mathcal{O}(s)$. Pick $g \in G$ with $g \cdot s = \rho$. Then
$\rho = g\cdot s \subseteq g \cdot u$, and $|g\cdot u| = r+1$, so $g\cdot u =
\rho \cup \{x\}$ for a unique $x \in (g\cdot u)\setminus \rho$; in particular
$x \notin \rho$. Since $g \cdot u$ lies in the orbit of $u$, we conclude
$\mathcal{O}(u) = \mathcal{O}(\rho \cup \{x\})$, as claimed.

Therefore the set of orbits of $(r+1)$-subsets is covered by the union, over the
$t_r$ orbits $\mathcal{O}$ of $r$-subsets, of the sets $\{\mathcal{O}(\rho(
\mathcal{O})\cup\{x\}) : x \notin \rho(\mathcal{O})\}$, each of which has at most
$|X \setminus \rho(\mathcal{O})| = n - r$ elements. Counting gives $t_{r+1} \le
(n-r) t_r$. $\square$

**Theorem 6.3 (deletion bound).** For every $r$ with $r + 1 \le n$,
$$t_r \;\le\; (r+1)\, t_{r+1} .$$

*Proof.* Apply complementation symmetry (Theorem 3.3) twice: $t_r = t_{n-r}$ and
$t_{r+1} = t_{n-r-1}$. The extension bound (Theorem 6.2) at index $n - r - 1$
reads
$$t_{n-r} \le \bigl(n - (n-r-1)\bigr)\, t_{n-r-1} = (r+1)\, t_{n-r-1},$$
which is exactly $t_r \le (r+1)\, t_{r+1}$. $\square$

Note the asymmetry of effort: the extension bound requires a genuine
combinatorial argument with orbit representatives, while the deletion bound is
free once the complementation symmetry is available. This is a typical dividend
of Theorem 3.3.

### 6.3 The group-free guard

**Theorem 6.4 (shadow guard).** For every finite action and all $1 \le r < n$,
$$t_{r-1}\, t_{r+1} \;\le\; r\,(n-r)\, t_r^2 .$$

*Proof.* Write $r = k+1$. The deletion bound (Theorem 6.3) at index $k$ gives
$t_k \le (k+1)\, t_{k+1}$; the extension bound (Theorem 6.2) at index $k+1$
gives $t_{k+2} \le (n - k - 1)\, t_{k+1}$. Multiplying,
$$t_k\, t_{k+2} \le (k+1)(n-k-1)\, t_{k+1}^2 = r(n-r)\, t_r^2 . \qquad\square$$

Theorem 6.4 is the honest replacement for the conjecture: a universal
quantitative log-concavity whose defect factor $r(n-r)$ mentions only the
combinatorial parameters. Three comments.

* **Attainment.** The bound is *sharp*: for the regular action of the Klein
  four-group on four points, whose spectrum is $(1,1,3,1,1)$, one has at $r=1$
  $$t_0\,t_2 = 3 = 1\cdot 3\cdot 1^2 = r(n-r)\,t_r^2 ,$$
  with equality (and likewise at $r = 3$ by symmetry). No constant smaller than
  $r(n-r)$ can work at the boundary in this generality.
* **Boundary sharpness.** At $r = 1$ the bound reads $t_2 \le (n-1)\, t_1^2$.
  For the four-bead necklace it gives $t_0 t_2 = 2 \le 3$, and for the ten-bead
  necklace $t_0 t_2 = 5 \le 9$. The overshoot at the boundary is a small
  constant factor.
* **Interior looseness.** In the interior of the range the measured slack is
  enormous (see Section 7), suggesting the factor $r(n-r)$ is far from optimal
  there.
* **Both guards are incomparable in general**: for a small group $|G|^2$ can beat
  $r(n-r)$, and for a large group the reverse holds. For the regular action of
  $C_n$, the shadow guard is always the stronger of the two in the interior.

---

## 7. Algorithms and computational evidence

### 7.1 Computing the spectrum

The definition is directly executable. To compute $t_r$: enumerate all
$\binom{n}{r}$ subsets of size $r$; for each, compute its orbit as the set
$\{g \cdot s : g \in G\}$; insert the orbit into a hash set; return the size of
the hash set. This costs $O\!\left(\binom{n}{r}\cdot |G| \cdot r\right)$
elementary operations, and the whole spectrum costs $O(2^n |G| n)$.

A refinement uses a union-find or breadth-first search over the $r$-subsets
under a generating set $S$ of $G$: this replaces the factor $|G|$ by $|S|$ and
computes all $t_r$ in $O(2^n |S| n)$ time. For $n \le 20$ and a small generating
set this is entirely practical.

A third route uses Burnside's mass formula (Theorem 2.5), which requires summing
over group elements the number of fixed $r$-subsets. For a permutation $g$ with
cycle type $(c_1, c_2, \dots)$ acting on $n$ points (with $c_j$ cycles of length
$j$), the number of $r$-subsets fixed by $g$ is the coefficient of $x^r$ in
$\prod_j (1 + x^j)^{c_j}$, because a fixed subset is a union of cycles. Hence
$$t_r = \frac{1}{|G|}\sum_{g \in G} [x^r] \prod_{j \ge 1} \bigl(1 + x^j\bigr)^{c_j(g)},$$
which is polynomial in $n$ once the cycle-type distribution of $G$ is known —
exponentially faster than enumeration when $|G|$ is small and $n$ is large. For
the cyclic group $C_n$ this specialises to the classical necklace formula
$$t_r = \frac{1}{n}\sum_{d \mid \gcd(n, r)} \varphi(d)\binom{n/d}{r/d}.$$

### 7.2 Data

Spectra of the regular action of $C_n$ on $n$ points (binary necklaces by
weight):

| $n$ | $t_0, \dots, t_n$ |
|---|---|
| $3$ | $1, 1, 1, 1$ |
| $4$ | $1, 1, 2, 1, 1$ |
| $5$ | $1, 1, 2, 2, 1, 1$ |
| $6$ | $1, 1, 3, 4, 3, 1, 1$ |
| $7$ | $1, 1, 3, 5, 5, 3, 1, 1$ |
| $8$ | $1, 1, 4, 7, 10, 7, 4, 1, 1$ |
| $9$ | $1, 1, 4, 10, 14, 14, 10, 4, 1, 1$ |
| $10$ | $1, 1, 5, 12, 22, 26, 22, 12, 5, 1, 1$ |

Log-concavity defects $t_{r-1}t_{r+1} - t_r^2$ for $r = 1, \dots, n-1$
(positive = violation):

| $n$ | defects |
|---|---|
| $6$ | $2, -5, -7, -5, 2$ |
| $8$ | $3, -9, -9, -51, -9, -9, 3$ |
| $10$ | $4, -13, -34, -172, -192, -172, -34, -13, 4$ |

The violations occur exactly at $r = 1$ and $r = n-1$, with defect $t_2 - 1 =
\lfloor n/2 \rfloor - 1$, confirming the boundary-effect diagnosis: the
transitive normalisation $t_0 = t_1 = 1$ is the sole obstruction for these
actions.

Slack $r(n-r)t_r^2 - t_{r-1}t_{r+1}$ in the shadow guard (always $\ge 0$, as
proved in Theorem 6.4):

| $n$ | slack |
|---|---|
| $6$ | $2, 68, 135, 68, 2$ |
| $8$ | $3, 185, 695, 1551, 695, 185, 3$ |
| $10$ | $4, 388, 2914, 11304, 16416, 11304, 2914, 388, 4$ |

The slack is tiny at the boundary ($2$, $3$, $4$ — i.e. the guard is nearly
attained) and huge in the interior, exactly the signature of a bound whose true
shape should be $\max(r, n-r)$ rather than $r(n-r)$.

Selected other actions of small degree:

| action | $\lvert G\rvert$ | spectrum | log-concave? |
|---|---|---|---|
| trivial group on $4$ | $1$ | $1,4,6,4,1$ | yes |
| $C_4$ on $4$ | $4$ | $1,1,2,1,1$ | no |
| Klein four-group on $4$ (regular) | $4$ | $1,1,3,1,1$ | no |
| $D_4$ on the square | $8$ | $1,1,2,1,1$ | no |
| $A_4$ on $4$ | $12$ | $1,1,1,1,1$ | yes |
| $S_4$ on $4$ | $24$ | $1,1,1,1,1$ | yes |
| $C_5$ on $5$ | $5$ | $1,1,2,2,1,1$ | no |
| $\mathrm{AGL}(1,5)$ on $5$ | $20$ | $1,1,1,1,1,1$ | yes |
| $A_5$ on $5$ | $60$ | $1,1,1,1,1,1$ | yes |
| $D_6$ on the hexagon | $12$ | $1,1,3,3,3,1,1$ | no |
| $A_6$ on $6$ | $360$ | $1,1,1,1,1,1,1$ | yes |

Every log-concave transitive entry has constant spectrum, as Theorem 5.2
requires; and each such group satisfies $|G| \ge \binom{n}{\lfloor n/2\rfloor}$
($12 \ge 6$, $24 \ge 6$, $20 \ge 10$, $60 \ge 10$, $360 \ge 20$), as
Corollary 5.3 requires.

The Burnside formula also checks out in the smallest counterexample: for $C_4$
at $r = 2$ we have $t_2 |G| = 2\cdot 4 = 8$, and the four group elements fix
respectively $6$, $0$, $2$, $0$ of the six $2$-subsets, summing to $8$.

Finally, note the entry $D_4$ on the square: it is transitive and not
$2$-homogeneous, hence not log-concave by Corollary 5.7, even though it is
strictly larger than a regular group. This shows that Theorem 5.5 is only a
convenient special case of the general obstruction: what matters is $|G| <
\binom{n}{r}$, not regularity.

### 7.3 Exhaustive verification in small degree

Enumerating *all* subgroups of the symmetric group of degree $n$ for
$n \le 5$ and computing each spectrum gives the following census.

| degree | subgroups | non-log-concave | transitive and log-concave |
|---|---|---|---|
| $2$ | $2$ | $0$ | $1$ |
| $3$ | $6$ | $0$ | $2$ |
| $4$ | $30$ | $7$ | $2$ |
| $5$ | $156$ | $12$ | $8$ |

The distinct spectra in degree $4$ are $(1,4,6,4,1)$, $(1,3,4,3,1)$,
$(1,2,4,2,1)$, $(1,2,3,2,1)$, $(1,2,2,2,1)$, $(1,1,3,1,1)$, $(1,1,2,1,1)$ and
$(1,1,1,1,1)$; only the last three come from transitive groups, and exactly the
two non-constant ones among them fail log-concavity. In degree $5$ the only
failing spectrum is $(1,1,2,2,1,1)$, realised by the cyclic group of order $5$
and the dihedral group of order $10$. In both degrees every failure comes from a
transitive group, in accordance with the Rigidity Theorem, and in every one of
the $194$ actions examined the structural identities of Section 3, both shadow
inequalities of Section 6.2, and both guards of Section 6 hold without exception.

---

## 8. Discussion

### 8.1 Why the conjecture is plausible and why it fails

Every heuristic for log-concavity here is a heuristic about the *shape* of the
sequence: it is symmetric, unimodal, and sandwiched between log-concave rows.
None of these is enough. Log-concavity is a statement about *second* differences
of $\log t_r$, and second differences are extremely sensitive to boundary
normalisation. For a transitive action the sequence begins $1, 1$, so the second
difference of the logarithm at $r = 1$ is $-\log t_2 \le 0$ if and only if $t_2
\le 1$. In other words, log-concavity at the first interior index is not a
regularity condition at all — it is a homogeneity condition, and the collapse
principle then propagates it across the whole range.

Contrast this with the Livingstone–Wagner theorem, which asserts $t_{r-1} \le
t_r$ whenever $2r \le n$: a statement about *first* differences. First
differences do not see the boundary normalisation as a constraint — starting at
$1$ is perfectly compatible with increasing — and the theorem holds for every
finite permutation group. Combined with the complementation symmetry, it makes
every subset spectrum unimodal with peak at $r = \lfloor n/2\rfloor$. Since
unimodality is normally *derived from* log-concavity, the present situation
inverts the usual hierarchy: the weaker conclusion is the true theorem, and the
stronger hypothesis is false.

### 8.2 Sharpness of the guards

The two guards have complementary weaknesses. The group guard $|G|^2$ is tight
only in a degenerate sense (for the trivial group it gives constant $1$, i.e.
genuine log-concavity, correctly). The shadow guard $r(n-r)$ is nearly tight at
the boundary and very loose in the interior. The reason for interior looseness
is that the extension and deletion bounds are never simultaneously tight: a
group that makes the extension map maximally non-injective must be large, and a
large group forces the deletion map to collapse. Making this trade-off precise
is the content of Conjecture C2 below.

### 8.3 Relation to the classification of set-transitive groups

The Rigidity Theorem converts a combinatorial inequality into a group-theoretic
classification problem, and that problem has a known answer: the set-transitive
permutation groups consist of the symmetric and alternating groups in their
natural actions, together with finitely many exceptional examples in small
degree — the smallest of these being the affine group $\mathrm{AGL}(1,5)$ of
order $20$ in degree $5$, which our computations confirm has constant spectrum
$(1,1,1,1,1,1)$. Consequently the transitive actions satisfying the conjecture
form an extremely thin class. That a natural inequality has such a rigid
solution set is the most striking feature of the present work.

### 8.4 Interpretation

The subset spectrum measures the *resolving power* of a symmetry group: how many
distinguishable configurations of each size survive the symmetry. Read this way,
the Rigidity Theorem says: a symmetry group whose resolving power decays
log-concavely with configuration size must have no resolving power at all. In
applications — enumerating chemical isomers under molecular symmetry, counting
binary necklaces and bracelets, classifying error-correcting codes up to a
symmetry group, or counting orbit types in a configuration space — the
practically relevant statements are therefore the guarded ones. In particular
the extension bound $t_{r+1} \le (n-r)t_r$ and its dual $t_r \le (r+1)t_{r+1}$
give cheap, group-free a priori estimates on the number of orbit types of size
$r+1$ from the number of size $r$, which is exactly what an orbit-enumeration
algorithm needs to size its data structures.

---

## 9. Future directions

The following three conjectures are the natural continuation; each is falsifiable
by an explicit finite computation with the spectrum.

**C1. Livingstone–Wagner monotonicity is the correct replacement for
log-concavity.**

> *Conjecture.* For every finite group action on $n$ points and every $r$ with
> $2r \le n$, $t_{r-1} \le t_r$; consequently the spectrum is unimodal with peak
> at $r = \lfloor n/2 \rfloor$.

The key insight is that log-concavity is a statement about second differences of
$\log t_r$ and is destroyed by the boundary normalisation $t_0 = t_1 = 1$ of a
transitive action, whereas monotonicity is a statement about first differences
and is protected by injectivity of the inclusion map from formal rational
combinations of $r$-subsets to formal rational combinations of $(r+1)$-subsets,
whose Gram matrix is positive definite exactly in the range $2r \le n$. All the
combinatorial infrastructure is in place: the spectrum is identified with an
orbit count, the complementation symmetry supplies $t_r = t_{n-r}$, and the
Burnside mass formula supplies the counting identity. The only missing
ingredient is the standard fact that the dimension of the $G$-invariants of a
permutation module equals the number of orbits.

**C2. The sharp group-free guard is $\max(r, n-r)$-shaped, not $r(n-r)$.**

> *Conjecture.* For every finite action, $t_{r-1} t_{r+1} \le C\, t_r^2$ already
> holds with $C = \max(r, n-r)$, and the exponent $1$ on $C$ cannot be lowered:
> there are actions with $t_{r-1} t_{r+1} \ge c\,\max(r, n-r)\, t_r^2$ for an
> absolute constant $c > 0$.

The key insight is that the two shadow inequalities $t_{r+1} \le (n-r)t_r$ and
$t_r \le (r+1)t_{r+1}$ are never simultaneously tight: a group that makes the
extension map maximally non-injective must be large, and largeness forces the
deletion map to collapse. The measured slack is $2$ at $r = 1$ for $C_6$ and $4$
for $C_{10}$, i.e. the current bound $r(n-r)$ overshoots by a factor $\approx
n/2$ in the interior but is nearly tight at the boundary — exactly the signature
of a $\max(r, n-r)$ law.

**C3. Interior log-concavity for regular abelian actions (necklace
log-concavity).**

> *Conjecture.* For the regular action of a finite abelian group of order $n$,
> the truncated spectrum $t_1, t_2, \dots, t_{n-1}$ **is** log-concave.

Equivalently: the only failures of log-concavity for such actions are the two
boundary indices $r = 1$ and $r = n-1$, forced by $t_0 = t_1 = 1$. The data in
Section 7 confirm this for $C_n$, $n \le 10$: the defect sequence is positive
exactly at the two ends. If true, this would show that the original conjecture
was not so much false as misindexed, and it would place necklace counts inside
the standard log-concavity landscape after a single boundary correction.

---

## 10. Conclusion

For a finite group $G$ acting on a finite set of $n$ points, the subset spectrum
$t_r$ — the number of orbits on $r$-element subsets — is a symmetric, positive,
binomially sandwiched sequence, and it is *not* in general log-concave. The
smallest counterexample is the four-bead necklace, spectrum $(1,1,2,1,1)$.
Behind the failure lies an exact dichotomy: for transitive actions,
log-concavity of the spectrum is equivalent to set-transitivity, and therefore
forces $|G| \ge \binom{n}{\lfloor n/2\rfloor}$; in particular every regular
action of degree at least $4$ is a counterexample. What survives universally are
two guarded inequalities, $t_{r-1}t_{r+1} \le |G|^2 t_r^2$ and, group-free,
$t_{r-1}t_{r+1} \le r(n-r)\, t_r^2$, the latter from a two-line shadow argument
that is nearly tight precisely where the conjecture fails. The correct general
theorem in this circle of ideas is not log-concavity but monotonicity up to the
middle, and the correct sharp constant in the guarded inequality is conjecturally
$\max(r, n-r)$.

---

## Appendix A. Summary of results

| Statement | Content |
|---|---|
| Boundary values | $t_0 = t_n = 1$ |
| Support | $t_r \ge 1$ for $r \le n$; $t_r = 0$ for $r > n$ |
| Complementation symmetry | $t_r = t_{n-r}$ |
| Binomial sandwich | $\binom{n}{r}/\lvert G\rvert \le t_r \le \binom{n}{r}$ |
| Trivial action | $t_r = \binom{n}{r}$ |
| Symmetric group | $t_r = 1$ for all $r$ |
| Homogeneity criterion | $t_r = 1 \iff G$ is $r$-homogeneous |
| Transitivity criterion | $t_1 = 1 \iff G$ is transitive |
| Orbit-quotient identity | $t_r = \lvert \Sigma_r/G\rvert$ |
| Burnside mass formula | $t_r\,\lvert G\rvert = \sum_{g} \#\{s : \lvert s\rvert = r,\ g\cdot s = s\}$ |
| Binomial log-concavity | $\binom{n}{k}\binom{n}{k+2} \le \binom{n}{k+1}^2$ |
| Counterexample | $C_4$ on $4$ points: $(1,1,2,1,1)$, $t_0t_2 = 2 > 1 = t_1^2$ |
| Collapse principle | $t_m = t_{m+1} = 1$ + log-concavity $\Rightarrow t_r = 1$ for $r \ge m$ |
| Rigidity Theorem | transitive: log-concave $\iff$ set-transitive |
| Cardinality obstruction | transitive + log-concave $\Rightarrow \binom{n}{r} \le \lvert G\rvert$ |
| Regular actions | regular, $n \ge 4$ $\Rightarrow$ not log-concave |
| Group guard | $t_{r-1}t_{r+1} \le \lvert G\rvert^2 t_r^2$ |
| Extension bound | $t_{r+1} \le (n-r)\,t_r$ |
| Deletion bound | $t_r \le (r+1)\,t_{r+1}$ |
| Shadow guard | $t_{r-1}t_{r+1} \le r(n-r)\,t_r^2$ |
