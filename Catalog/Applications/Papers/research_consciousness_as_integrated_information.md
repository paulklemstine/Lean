# A Formally Verified Structural Core for Integrated Information ($\Phi$)

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Novelty (Mathematical foundations of consciousness science)

## Abstract

Integrated Information Theory (IIT) proposes a scalar invariant $\Phi$ ("phi")
that quantifies the *irreducibility* of a system of interacting elements: the
degree to which the whole generates information above and beyond the information
generated independently by its parts. We isolate and rigorously establish the
combinatorial-order-theoretic skeleton on which every concrete formulation of
$\Phi$ rests. Working over a finite element set $\{0, \dots, n-1\}$, we define
the lattice of nontrivial bipartitions ("cuts"), model a system as an arbitrary
nonnegative *effective-information functional* $\mathrm{ei}$ on cuts, and define
the integrated information $\Phi$ as the value of $\mathrm{ei}$ at the **Minimum
Information Partition** (MIP), i.e. the minimum of $\mathrm{ei}$ over all cuts.
We prove: (i) the MIP exists and realizes $\Phi$; (ii) $\Phi$ is the greatest
lower bound of the effective-information landscape; (iii) $\Phi \ge 0$; (iv) the
reducibility characterization $\Phi = 0 \iff$ some cut destroys no information;
(v) monotonicity of $\Phi$ in the functional $\mathrm{ei}$; and (vi) a
shared-bottleneck rigidity result equating $\Phi$ across systems that agree at a
common minimizing cut. Crucially, every theorem depends only on the
nonnegativity of $\mathrm{ei}$, so the entire structure transfers verbatim to any
concrete information measure (mutual information, KL divergence, etc.). All
results have been formalized and machine-checked.

---

## 1. Introduction

### 1.1 Motivation

Integrated Information Theory, introduced by Tononi, seeks to characterize the
extent to which a physical system is an irreducible whole rather than a
collection of quasi-independent parts. Its central quantity, $\Phi$, is intended
to vanish precisely for systems that decompose into informationally independent
components and to be large for systems whose components are tightly bound. While
the philosophical claims of IIT — that $\Phi$ measures the *quantity* of
consciousness — are contested, the *mathematical* core of the theory is an
optimization problem over the bipartitions of a finite system, and that core can
be made fully precise.

The literature contains several competing definitions of the per-cut measure
(effective information, integrated conceptual information, $\Phi^{\max}$, and so
on), and arguments about $\Phi$ frequently entangle the choice of per-cut measure
with the structural properties of the minimization. The purpose of this paper is
to **disentangle** the two. We show that the foundational properties of $\Phi$ —
existence of the MIP, the greatest-lower-bound property, nonnegativity, the
reducibility equivalence, monotonicity, and bottleneck rigidity — are *purely
structural*: they require only that the per-cut measure is nonnegative. We
formalize the per-cut measure as an opaque nonnegative functional, prove the
structural theorems once, and thereby obtain results that hold for *every*
admissible instantiation simultaneously.

### 1.2 Contributions

1. A precise definition of the bipartition landscape $\mathrm{parts}(n)$ of a
   finite system and its boundary behavior (Section 2).
2. An abstract model of an IIT system as a nonnegative effective-information
   functional, with $\Phi$ defined as the MIP value (Section 2).
3. Six structural theorems characterizing $\Phi$ (Section 3), each proved from
   nonnegativity alone.
4. A discussion of computational complexity, instantiation by mutual
   information, and falsifiable extensions (Sections 4–6).

All definitions and theorems below correspond one-to-one to machine-checked
formal statements; the formal names are given in brackets, e.g. [`phi_nonneg`].

---

## 2. Definitions

Throughout, $n \in \mathbb{N}$ and the elements of the system are identified with
the finite set $\mathrm{Fin}\,n = \{0, 1, \dots, n-1\}$. Subsets of elements are
ranged over by $A, B$, and the complement of $A$ within the full element set is
written $A^{c}$.

### Definition 2.1 (Nontrivial bipartitions) [`parts`]

The set of **nontrivial bipartitions** of an $n$-element system is
$$
\mathrm{parts}(n) \;=\; \bigl\{\, A \subseteq \mathrm{Fin}\,n \;:\;
A \neq \varnothing \ \text{and}\ A \neq \mathrm{Fin}\,n \,\bigr\}.
$$
Each $A \in \mathrm{parts}(n)$ encodes the cut that separates $A$ from its
complement $A^{c}$. (As a cut, $A$ and $A^{c}$ describe the same separation;
this symmetry is harmless for everything below, which depends only on the value
of $\mathrm{ei}$.)

### Lemma 2.2 (Membership) [`mem_parts`]

For any $A \subseteq \mathrm{Fin}\,n$,
$$
A \in \mathrm{parts}(n) \iff A \neq \varnothing \ \wedge\ A \neq \mathrm{Fin}\,n .
$$
*Proof.* Immediate by unfolding the definition (a powerset filter). $\square$

The cardinality of $\mathrm{parts}(n)$ is $2^{n} - 2$.

### Lemma 2.4 (Boundary behavior) [`parts_nonempty`, `parts_eq_empty`]

1. If $2 \le n$, then $\mathrm{parts}(n) \neq \varnothing$.
2. If $n \le 1$, then $\mathrm{parts}(n) = \varnothing$.

*Proof.* (1) The singleton $\{0\}$ is nonempty, and it is proper because its
cardinality $1$ differs from $|\mathrm{Fin}\,n| = n \ge 2$; hence
$\{0\} \in \mathrm{parts}(n)$. (2) For $n \in \{0, 1\}$ every subset equals
$\varnothing$ or $\mathrm{Fin}\,n$, so no member satisfies both conditions of
Lemma 2.2; a finite case check closes both cases. $\square$

Lemma 2.4 records the natural domain of $\Phi$: integration is defined precisely
when the system has at least two elements.

### Definition 2.3 (IIT system) [`System`]

An **IIT system** on $n$ elements is a pair $S = (\mathrm{ei}, \text{nonneg})$
where
$$
\mathrm{ei} : \mathcal{P}(\mathrm{Fin}\,n) \to \mathbb{R}, \qquad
\mathrm{ei}(A) \ge 0 \ \text{ for all } A.
$$
The value $\mathrm{ei}(A)$ is the **effective information** lost when the cut $A$
is imposed. The sole axiom is nonnegativity: severing a cut never produces
negative information loss.

We emphasize what is *not* assumed: no symmetry, no additivity, no submodularity,
no particular functional form. The structural theory below uses nonnegativity and
nothing more.

### Definition 2.5 (Integrated information $\Phi$) [`Phi`]

Let $S$ be a system on $n$ elements with $2 \le n$ (so that
$\mathrm{parts}(n) \neq \varnothing$ by Lemma 2.4). The **integrated
information** of $S$ is
$$
\Phi(S) \;=\; \min_{A \,\in\, \mathrm{parts}(n)} \mathrm{ei}(A),
$$
the minimum of the effective information over all nontrivial cuts. The minimizing
cut is the **Minimum Information Partition (MIP)**. Formally $\Phi(S)$ is
$\min'$ of the finite nonempty image $\mathrm{ei}\bigl(\mathrm{parts}(n)\bigr)$,
where nonemptiness is supplied by Lemma 2.4(1).

The choice of *minimum* (rather than mean or maximum) encodes the principle that
a system is only as integrated as its weakest seam: a single low-cost cut
suffices to expose the system as nearly decomposable.

---

## 3. Main Results

Fix a system $S$ on $n$ elements with $2 \le n$ throughout this section.

### Theorem 3.1 ($\Phi$ is a lower bound) [`phi_le_ei`]

For every nontrivial cut $A \in \mathrm{parts}(n)$,
$$
\Phi(S) \le \mathrm{ei}(A).
$$
*Proof sketch.* $\mathrm{ei}(A)$ belongs to the finite image
$\mathrm{ei}(\mathrm{parts}(n))$, and $\Phi(S)$ is the minimum of that image; the
minimum is $\le$ each member (`Finset.min'_le`). $\square$

### Theorem 3.2 (Existence of the MIP) [`exists_MIP`]

There exists a nontrivial cut realizing $\Phi$:
$$
\exists\, A \in \mathrm{parts}(n), \quad \mathrm{ei}(A) = \Phi(S).
$$
*Proof sketch.* Since $\mathrm{parts}(n)$ is finite and nonempty, its image
under $\mathrm{ei}$ is a finite nonempty subset of $\mathbb{R}$, whose minimum is
a member of the image (`Finset.min'_mem`). Pulling that member back through
`Finset.mem_image` yields a witnessing partition. $\square$

The MIP need not be unique; Theorem 3.2 asserts only that the infimum is
attained, which is what distinguishes a genuine minimum from a mere bound.

### Theorem 3.3 ($\Phi$ is the greatest lower bound) [`le_phi`]

If $c \in \mathbb{R}$ is a common lower bound of the landscape — i.e.
$c \le \mathrm{ei}(A)$ for all $A \in \mathrm{parts}(n)$ — then
$$
c \le \Phi(S).
$$
*Proof sketch.* Every element of the image $\mathrm{ei}(\mathrm{parts}(n))$ has
the form $\mathrm{ei}(A)$ for some $A \in \mathrm{parts}(n)$ and hence is
$\ge c$; by `Finset.le_min'`, $c$ is below the minimum. $\square$

Theorems 3.1 and 3.3 together state exactly that $\Phi(S) = \inf$ of the
effective-information landscape: it is a lower bound (3.1) and the largest one
(3.3). This is the order-theoretic identity of $\Phi$.

### Corollary 3.4 (Nonnegativity) [`phi_nonneg`]

$$
0 \le \Phi(S).
$$
*Proof sketch.* Apply Theorem 3.3 with $c = 0$; the hypothesis
$0 \le \mathrm{ei}(A)$ for all $A$ is exactly the nonnegativity axiom of the
system. $\square$

### Theorem 3.5 (Reducibility characterization) [`phi_eq_zero_iff`]

$$
\Phi(S) = 0 \;\iff\; \exists\, A \in \mathrm{parts}(n),\ \mathrm{ei}(A) = 0.
$$
*Proof sketch.*
($\Rightarrow$) If $\Phi(S) = 0$, apply Theorem 3.2 to obtain a cut $A$ with
$\mathrm{ei}(A) = \Phi(S) = 0$.
($\Leftarrow$) Suppose $A \in \mathrm{parts}(n)$ has $\mathrm{ei}(A) = 0$. Then
$0 \le \Phi(S)$ by Corollary 3.4, while $\Phi(S) \le \mathrm{ei}(A) = 0$ by
Theorem 3.1; antisymmetry gives $\Phi(S) = 0$. $\square$

Theorem 3.5 is the formal content of "reducibility": a system has $\Phi = 0$
exactly when some nontrivial cut loses no effective information, i.e. when the
system decomposes (along that cut) into informationally independent parts.
Contrapositively, $\Phi(S) > 0$ iff **every** cut destroys information — the
defining signature of an integrated whole.

### Theorem 3.6 (Monotonicity in the functional) [`phi_mono`]

Let $S, T$ be systems on the same $n$ with $\mathrm{ei}_S(A) \le \mathrm{ei}_T(A)$
for every cut $A$. Then
$$
\Phi(S) \le \Phi(T).
$$
*Proof sketch.* Let $A$ be a MIP of $T$, so $\mathrm{ei}_T(A) = \Phi(T)$
(Theorem 3.2). Then
$\Phi(S) \le \mathrm{ei}_S(A) \le \mathrm{ei}_T(A) = \Phi(T)$,
using Theorem 3.1 for the first inequality and the hypothesis for the second.
$\square$

Monotonicity guarantees that uniformly strengthening (or never weakening) the
cut-wise information loss cannot decrease integration: $\Phi$ moves in the
expected direction as a substrate's couplings change.

### Theorem 3.7 (Shared-bottleneck rigidity) [`phi_eq_of_common_mip`]

Let $S, T$ be systems on the same $n$ and let $A_0 \in \mathrm{parts}(n)$ be a
common minimizer:
$$
\mathrm{ei}_S(A_0) \le \mathrm{ei}_S(B) \ \text{ and } \
\mathrm{ei}_T(A_0) \le \mathrm{ei}_T(B) \quad \text{for all } B \in \mathrm{parts}(n),
$$
and suppose the two systems agree there, $\mathrm{ei}_S(A_0) = \mathrm{ei}_T(A_0)$.
Then
$$
\Phi(S) = \Phi(T).
$$
*Proof sketch.* By Theorem 3.1, $\Phi(S) \le \mathrm{ei}_S(A_0)$; by Theorem 3.3
applied with $c = \mathrm{ei}_S(A_0)$ (a lower bound by hypothesis),
$\mathrm{ei}_S(A_0) \le \Phi(S)$. Hence $\Phi(S) = \mathrm{ei}_S(A_0)$, and
symmetrically $\Phi(T) = \mathrm{ei}_T(A_0)$. The agreement hypothesis then gives
$\Phi(S) = \Phi(T)$. $\square$

Theorem 3.7 isolates the locality of $\Phi$: integrated information is a function
of the bottleneck cut and its value there, independent of the system's behavior
along all other cuts. Two systems may differ arbitrarily away from their shared
weakest seam and still carry identical $\Phi$.

---

## 4. Algorithms and Complexity

The definition of $\Phi$ is a minimization over $\mathrm{parts}(n)$, which has
$2^{n} - 2$ elements. A direct evaluation therefore costs
$$
\Theta\!\left(2^{n}\right)
$$
calls to the effective-information functional $\mathrm{ei}$, each of which is
itself typically expensive (involving marginalization or divergence
computations). This exponential blow-up is intrinsic to the brute-force MIP
search and is the principal obstacle to applying IIT to large systems; it has
motivated a substantial literature on approximations and queyranne-style
submodular minimization heuristics for specific $\mathrm{ei}$.

We record the exact algorithm here, since it is what the structural theorems
certify.

**Algorithm (Exact MIP / $\Phi$ search).**
*Input:* $n \ge 2$ and an oracle for $\mathrm{ei} : \mathcal{P}(\mathrm{Fin}\,n)
\to \mathbb{R}_{\ge 0}$.
*Output:* $\Phi$ and a realizing MIP $A^{\star}$.
1. Enumerate all subsets $A \subseteq \{0, \dots, n-1\}$.
2. Discard $A = \varnothing$ and $A = \{0, \dots, n-1\}$ (Definition 2.1).
3. For each surviving $A$, evaluate $\mathrm{ei}(A)$.
4. Return the minimum value $\Phi$ (guaranteed to exist, Theorem 3.2) and an
   argmin $A^{\star}$.

By Theorem 3.2 step 4 always succeeds; by Theorems 3.1 and 3.3 the returned value
is the true infimum; by Theorem 3.5 the returned $\Phi$ is zero iff the loop
encountered a zero-cost cut. Restricting the cut set to a chosen subfamily (e.g.
only balanced cuts, or only contiguous cuts) yields a *restricted* $\Phi$ for
which the identical theorems hold, since they assume nothing about which family of
cuts is used beyond nonemptiness.

---

## 5. Applications and Instantiations

The abstraction by a nonnegative functional is not merely convenient; it is the
mechanism by which the structural theorems become reusable. Any concrete IIT
proposal that supplies a nonnegative per-cut measure inherits Theorems 3.1–3.7
for free. Two natural instantiations:

- **Mutual information across a cut.** Let the system state be a joint
  distribution and set $\mathrm{ei}(A) = I(A ; A^{c})$, the mutual information
  between the two sides. Mutual information is nonnegative (Gibbs' inequality) and
  vanishes exactly under independence, so $\Phi = 0$ (Theorem 3.5) reproduces the
  classical statement "$\Phi = 0$ iff the system factorizes across some cut," and
  $\Phi > 0$ certifies that no cut yields independent halves.

- **Kullback–Leibler effective information.** Set $\mathrm{ei}(A)$ to the KL
  divergence between the system's transition behavior and that of the
  cut-disconnected system. Nonnegativity of KL again places this within the
  framework, so the MIP exists and $\Phi$ is its canonical greatest lower bound.

In each case the *analytic* work is confined to proving nonnegativity of the
chosen measure; all *order-theoretic* and *combinatorial* content is already
discharged by the results above.

---

## 6. Discussion and Future Directions

We have made precise the structural backbone of $\Phi$ and proved that the
properties one expects of a measure of irreducibility — attained minimum, exact
infimum, nonnegativity, the reducibility equivalence, monotonicity, and
bottleneck rigidity — follow from a single nonnegativity hypothesis. This cleanly
separates the *combinatorics of cuts* from the *information theory of any one
cut*, and it guarantees that future work on concrete effective-information
measures may focus solely on analytic properties of those measures.

Several precise, falsifiable extensions arise once $\mathrm{ei}$ is instantiated
by mutual information $I(A; A^c)$:

- **Capacity bound.** $I(A; A^c) \le \log \min(|A\text{-states}|,
  |A^c\text{-states}|)$, hence $\Phi$ is bounded by the log-capacity of the
  smaller side of its MIP; equality is approached by perfectly correlated states.
- **Chain rule / refinement monotonicity.** Coarsening a cut (merging two sides)
  cannot decrease the cross-cut mutual information, via a conditional-mutual-
  information chain rule with a nonnegative remainder.
- **Data-processing monotonicity.** Applying a stochastic channel independently
  within each side of a cut cannot increase $I(A; A^c)$, so intra-part processing
  cannot manufacture integration; combined with Theorem 3.6 this bounds $\Phi$
  under local processing.
- **Reducibility = disconnection.** Over the full MIP family, $\Phi = 0$ iff the
  system's dependency hypergraph is disconnected, sharpening Theorem 3.5.
- **Continuity / stability.** Mutual-information-based $\Phi$ is uniformly continuous on
  the interior of the simplex and globally bounded, giving a modulus of stability
  under total-variation perturbations of the state.

Each is a concrete theorem-shaped target that sits directly on top of the
verified skeleton of Section 3.

---

## 7. Conclusion

Integrated Information Theory rests, mathematically, on minimizing an
effective-information functional over the bipartitions of a finite system. We
formalized that minimization, identified nonnegativity as its only essential
hypothesis, and proved the six structural theorems that make $\Phi$ a coherent
invariant: the MIP exists and realizes $\Phi$ (Theorem 3.2), $\Phi$ is the
greatest lower bound (Theorems 3.1, 3.3), $\Phi \ge 0$ (Corollary 3.4),
$\Phi = 0$ characterizes reducibility (Theorem 3.5), $\Phi$ is monotone in the
functional (Theorem 3.6), and $\Phi$ is determined by its bottleneck
(Theorem 3.7). Whatever one concludes about the relationship between $\Phi$ and
consciousness, the quantity itself now has a rigorous and reusable foundation.
