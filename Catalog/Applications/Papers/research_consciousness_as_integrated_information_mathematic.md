# Integrated Information as a Maximum Co-Active Coalition: A Tractable Surrogate Model, Its Minimum-Information-Partition Law, and NP-Hardness

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Mathematical foundations of Integrated Information Theory)

## Abstract

Integrated Information Theory (IIT) posits a scalar $\Phi$ that quantifies the
extent to which a system forms an irreducible informational whole. The full IIT
functional — defined through earth-mover divergences between cause and effect
repertoires, optimized over all system bipartitions — is mathematically intricate
and computationally forbidding. We introduce a deliberately *tractable surrogate*
model of integrated information that retains the structural skeleton of IIT while
admitting fully rigorous theorems. A system is a joint probability distribution
over finitely many Boolean variables. From it we read off a *co-activation*
relation (two variables are co-active when they are jointly active with positive
probability), *co-active coalitions* (pairwise co-active variable sets), and the
integrated information $\Phi_{\mathrm{bip}}(A)$ across a bipartition $(A,A^c)$ as
the largest co-active coalition straddling the cut. The system-level invariant
$\Phi_{\max}$ maximizes this over all bipartitions. Our central structural result
is a *collapse theorem*: $\Phi_{\max}$ equals the global co-active number $\Omega$
(the size of the largest co-active coalition with at least two members),
establishing that the partition optimization is governed by a single global
quantity. We prove the natural ceiling $\Phi_{\max}\le n$ and its loose polynomial
form $\Phi_{\max}\le n^m$. We then give an explicit, polynomial-size reduction
$S(\cdot)$ from graphs to systems for which co-activation coincides with adjacency,
yielding $\Phi_{\max}(S(G)) = \omega(G)$, the clique number of $G$. Since maximum
clique is NP-hard, computing $\Phi_{\max}$ is NP-hard. Finally we discuss
polynomial-time approximation and fixed-parameter-tractable regimes inherited from
the clique literature. All results are formalized and machine-checked.

## 1. Introduction

A central challenge for any quantitative theory of consciousness is to specify a
measure of *integration* — the degree to which a system's behavior cannot be
decomposed into the behaviors of independent parts. Tononi's Integrated
Information Theory answers with $\Phi$: a system is conscious to the extent that
the information it generates exceeds the information generated independently by its
parts, evaluated at the *Minimum Information Partition* (MIP), the cut along which
the system is least integrated.

The conceptual appeal of $\Phi$ is matched by mathematical and computational
difficulty. The genuine IIT functional involves repertoires of conditional
distributions over the system's possible causes and effects, an earth-mover (or
related) distance between them, and an optimization over all bipartitions of the
system. Even careful expositions disagree on details, and exact computation is
infeasible beyond a handful of elements.

This paper takes a complementary route. Rather than formalize the full functional,
we isolate a **structural surrogate** that (i) is defined for genuine probabilistic
systems, (ii) keeps the two defining moves of IIT — *cut the system, measure what
the cut fails to separate, optimize over cuts* — and (iii) is simple enough that
the central complexity-theoretic statements about integration become honest,
machine-checked theorems. We regard the surrogate not as a replacement for $\Phi$
but as a rigorous lower-dimensional shadow in which qualitative phenomena (the role
of the partition optimization, the source of computational hardness) can be
understood exactly.

Our contributions are:

1. A finite-probability formalization of a co-activation–based surrogate for
   integrated information (Section 2).
2. The **collapse theorem** `phiMax_eq_global`: $\Phi_{\max}=\Omega$, identifying
   the partition-optimized invariant with a single global quantity (Section 3).
3. Structural bounds `phiMax_le_card` ($\Phi_{\max}\le n$) and `phiMax_le_pow`
   ($\Phi_{\max}\le n^m$) (Section 3).
4. An explicit polynomial reduction $S$ from graphs to systems, with
   `coactive_iff_adj` and `card_SSupport_le`, yielding $\Phi_{\max}(S(G))=\omega(G)$
   and hence NP-hardness of computing $\Phi_{\max}$ (Section 4).
5. A discussion of polynomial-time approximation and tractable special cases
   inherited from the maximum-clique literature (Section 5).

## 2. Definitions

Throughout, $\alpha$ is the (finite) index set of the system's variables, and a
*configuration* is a function $x:\alpha\to\{\text{false},\text{true}\}$, identifying
$\text{true}$ with the variable being active ($1$) and $\text{false}$ with inactive
($0$).

**Definition 2.1 (Probabilistic system).** A *probabilistic system* over $\alpha$
is a probability mass function on configurations,
$$P \in \mathrm{PMF}(\alpha \to \mathrm{Bool}).$$
We write $\mathrm{supp}(P)$ for the set of configurations of positive probability.

**Definition 2.2 (Co-activation).** Two variables $u,v\in\alpha$ are *co-active*
in $P$, written $\mathrm{Coactive}(P,u,v)$, if some positive-probability
configuration activates both:
$$\exists\, x\in\mathrm{supp}(P),\quad x(u)=\text{true}\ \wedge\ x(v)=\text{true}.$$
Equivalently $P(X_u=1\wedge X_v=1)>0$. Co-activation is symmetric.

**Definition 2.3 (Co-active coalition).** A finite set $K\subseteq\alpha$ is a
*co-active coalition*, $\mathrm{IsCoactiveSet}(P,K)$, if every pair of distinct
members is co-active:
$$\forall\, u,v\in K,\ u\neq v \implies \mathrm{Coactive}(P,u,v).$$

**Definition 2.4 (Straddling).** A set $K$ *straddles* the bipartition $(A,A^c)$,
written $\mathrm{Straddles}(A,K)$, if it meets both sides:
$$(\exists\, u\in K,\ u\in A)\ \wedge\ (\exists\, v\in K,\ v\notin A).$$

**Definition 2.5 (Integrated information across a bipartition).** For a finite
system ($\alpha$ a fintype) and a bipartition determined by $A\subseteq\alpha$,
$$\Phi_{\mathrm{bip}}(P,A) \;=\; \sup\{\, n : \exists K,\ |K|=n,\ \mathrm{IsCoactiveSet}(P,K),\ \mathrm{Straddles}(A,K)\,\},$$
the size of the largest co-active coalition split by the cut, taken to be $0$ when
none exists.

**Definition 2.6 (Maximum integrated information).**
$$\Phi_{\max}(P) \;=\; \sup\{\, n : \exists A,\ n=\Phi_{\mathrm{bip}}(P,A)\,\}.$$

**Definition 2.7 (Global co-active number).**
$$\Omega(P) \;=\; \sup\{\, n : \exists K,\ |K|=n,\ \mathrm{IsCoactiveSet}(P,K),\ 2\le |K|\,\}.$$

All suprema are over bounded subsets of $\mathbb{N}$ (coalition sizes are at most
$|\alpha|$), hence well-defined natural numbers.

**Remark 2.8 (Relation to IIT's MIP).** The genuine IIT $\Phi$ *minimizes* an
information-loss functional over cuts (the MIP). Our surrogate *maximizes* the
largest straddling coalition. Both implement the IIT principle "the value of the
system is determined by an optimization over partitions of a quantity measuring
what the partition fails to separate." Working with the maximum of a monotone
combinatorial witness, rather than the minimum of a divergence, is exactly what
makes the surrogate analytically and computationally transparent while keeping the
phenomenon of interest — the dependence on the partition family — intact. A
complementary fully formalized model based on the KL-divergence MIP (mutual
information across a cut, $\Phi$ as a minimum over cuts) is summarized in the
Future Directions.

## 3. Structural theory

We first record two elementary facts linking straddling and coalition size.

**Lemma 3.1 (`two_le_card_of_straddles`).** If $\mathrm{Straddles}(A,K)$ then
$|K|\ge 2$.

*Proof.* Straddling supplies $u\in K\cap A$ and $v\in K\setminus A$. Since $u\in A$
and $v\notin A$, we have $u\neq v$, so $\{u,v\}\subseteq K$ is a two-element subset
and $|K|\ge|\{u,v\}|=2$. $\square$

**Lemma 3.2 (`exists_straddles_of_two_le`).** If $|K|\ge 2$ then there exists a
bipartition $A$ with $\mathrm{Straddles}(A,K)$.

*Proof.* From $|K|\ge 2$ pick distinct $u,v\in K$. Take $A=\{u\}$. Then $u\in K\cap A$
and $v\in K$ with $v\notin\{u\}$ (as $v\neq u$), so $K$ straddles $(A,A^c)$. $\square$

These two facts are precisely the bridge between the partition-level and global
viewpoints, and they drive the main theorem.

**Theorem 3.3 (Collapse; `phiMax_eq_global`).** For every probabilistic system
$P$ on a finite variable set,
$$\Phi_{\max}(P) \;=\; \Omega(P).$$

*Proof.* We prove two inequalities.

($\le$) Let $A$ be any bipartition and let $K$ witness $\Phi_{\mathrm{bip}}(P,A)$,
i.e. $K$ is a co-active coalition straddling $A$. By Lemma 3.1, $|K|\ge 2$, so $K$
is admissible in the defining set of $\Omega(P)$; hence $|K|\le\Omega(P)$. Taking
suprema over witnesses and over $A$ gives $\Phi_{\max}(P)\le\Omega(P)$. (Boundedness
of all the sets by $|\alpha|$, via $|K|\le|\alpha|$, justifies the supremum
manipulations.)

($\ge$) Let $K$ witness $\Omega(P)$: a co-active coalition with $|K|\ge 2$. By
Lemma 3.2 there is a bipartition $A$ with $\mathrm{Straddles}(A,K)$. Then $K$ is an
admissible witness for $\Phi_{\mathrm{bip}}(P,A)$, so $|K|\le\Phi_{\mathrm{bip}}(P,A)$;
and $\Phi_{\mathrm{bip}}(P,A)$ is itself admissible for $\Phi_{\max}(P)$, so
$\Phi_{\mathrm{bip}}(P,A)\le\Phi_{\max}(P)$. Chaining, $|K|\le\Phi_{\max}(P)$, and
taking the supremum over witnesses $K$ gives $\Omega(P)\le\Phi_{\max}(P)$.

Antisymmetry of $\le$ yields equality. $\square$

Theorem 3.3 is the rigorous form of the "minimum/maximum information partition"
intuition: the optimization over the exponentially large family of $2^{|\alpha|}$
bipartitions does not introduce information beyond a single global structural
invariant, the largest co-active coalition. It is the engine for everything that
follows, because it converts a statement about *all cuts* into a statement about
*one global quantity*.

**Theorem 3.4 (Ceiling; `phiMax_le_card`).** $\Phi_{\max}(P)\le|\alpha|$ (with
$|\alpha|=\mathrm{Fintype.card}\,\alpha$).

*Proof.* By Theorem 3.3 it suffices to bound $\Omega(P)$. Every witness $K$ is a
finite subset of $\alpha$, so $|K|\le|\alpha|$; the supremum of these sizes is
therefore $\le|\alpha|$. $\square$

**Theorem 3.5 (Polynomial form; `phiMax_le_pow`).** If $|\alpha|\ge 1$ and $m\ge 1$,
then $\Phi_{\max}(P)\le|\alpha|^m$.

*Proof.* By Theorem 3.4, $\Phi_{\max}(P)\le|\alpha|=|\alpha|^1\le|\alpha|^m$, the
last step by monotonicity of $n\mapsto n^m$'s exponent for $n\ge 1$. $\square$

Theorem 3.5 is the loose form of a circuit-style bound $\Phi\le n^{O(d+k)}$; the
sharp content is the linear ceiling of Theorem 3.4. Both certify that integrated
information, in this model, is bounded by the system's representational size — a
basic adequacy condition for any integration measure.

## 4. NP-hardness via a reduction from CLIQUE

We now show that computing $\Phi_{\max}$ is at least as hard as computing the
clique number of a graph, which is NP-hard (maximum clique is among Karp's original
21 NP-complete problems).

**Construction 4.1 (The system $S(G)$).** Let $G$ be a simple graph with vertex
set $\alpha$ (a fintype), $n=|\alpha|$. Define $S(G)\in\mathrm{PMF}(\alpha\to\mathrm{Bool})$
as the uniform distribution over the following configurations:

- the all-off configuration $\mathbf{0}$ (every variable false); and
- for each edge $\{u,v\}\in E(G)$, the configuration $e_{u,v}$ that is true exactly
  at $u$ and $v$ and false elsewhere.

**Lemma 4.2 (Polynomial size; `card_SSupport_le`).**
$|\mathrm{supp}(S(G))| \le n^2 + 1.$

*Proof.* The support consists of $\mathbf{0}$ together with one configuration per
edge; the number of edges is at most $\binom{n}{2}\le n^2$, so the support has at
most $n^2+1$ elements. Hence $S(G)$ has a description polynomial in $|G|$ and is
computable from $G$. $\square$

**Lemma 4.3 (Faithfulness; `coactive_iff_adj`).** For distinct $u,v\in\alpha$,
$$\mathrm{Coactive}(S(G),u,v) \iff u \sim_G v.$$

*Proof.* ($\Leftarrow$) If $u\sim_G v$ then $e_{u,v}\in\mathrm{supp}(S(G))$ and it
activates both $u$ and $v$, witnessing co-activation. ($\Rightarrow$) Suppose some
$x\in\mathrm{supp}(S(G))$ has $x(u)=x(v)=\text{true}$. The all-off configuration
activates nothing, so $x=e_{a,b}$ for some edge $\{a,b\}$. A configuration of the
form $e_{a,b}$ is true at exactly two vertices, $a$ and $b$; since it is true at
both $u\neq v$, we must have $\{u,v\}=\{a,b\}$, an edge of $G$, i.e. $u\sim_G v$. $\square$

**Theorem 4.4 (Reduction; $\Phi_{\max}(S(G))=\omega(G)$).** For every finite simple
graph $G$,
$$\Phi_{\max}(S(G)) = \omega(G),$$
where $\omega(G)$ is the clique number (the size of the largest clique) of $G$,
under the convention $\omega(G)\ge 2$ exactly when $G$ has at least one edge (so
that single-vertex "cliques" are excluded, matching the $|K|\ge2$ requirement of
$\Omega$).

*Proof.* By Theorem 3.3, $\Phi_{\max}(S(G))=\Omega(S(G))$, the largest co-active
coalition of size $\ge 2$. By Lemma 4.3, $K$ is a co-active coalition in $S(G)$ iff
every pair of distinct members of $K$ is adjacent in $G$, i.e. iff $K$ is a clique
of $G$. Hence the co-active coalitions of $S(G)$ are exactly the cliques of $G$,
and the largest one of size $\ge 2$ has size $\omega(G)$ (when $G$ has an edge;
otherwise both sides are the degenerate $0$). $\square$

**Corollary 4.5 (NP-hardness).** Computing $\Phi_{\max}$ is NP-hard.

*Proof.* Construction 4.1 maps a graph $G$ to a system $S(G)$ of polynomial size
(Lemma 4.2) in polynomial time, and Theorem 4.4 shows that $\Phi_{\max}(S(G))$
equals $\omega(G)$. A polynomial-time algorithm for $\Phi_{\max}$ would therefore
solve the (NP-hard) maximum-clique optimization problem in polynomial time. Hence
$\Phi_{\max}$ is NP-hard. $\square$

The reduction is exact (not merely gap-preserving): the value of integrated
information *is* the clique number, vertex for vertex. Consequently every hardness
result for clique transfers verbatim. In particular, since maximum clique is
NP-hard to approximate within $n^{1-\varepsilon}$ for any $\varepsilon>0$ (Håstad;
Zuckerman), the same inapproximability holds for $\Phi_{\max}$ in this model: not
only exact computation but even strong approximation of integrated information is
intractable in the worst case.

### 4.1 A worked example

It is worth tracing the reduction on a concrete instance to see that every step is
effective. Take $G$ to be the complete graph $K_4$ on vertices $\{0,1,2,3\}$, which
has six edges and clique number $\omega(G)=4$. The system $S(G)$ is uniform over
seven configurations: the all-off vector $\mathbf{0}=(0,0,0,0)$ and the six
edge-indicators $(1,1,0,0)$, $(1,0,1,0)$, $(1,0,0,1)$, $(0,1,1,0)$, $(0,1,0,1)$,
$(0,0,1,1)$, each with probability $1/7$. The support has $7\le 4^2+1=17$ points,
confirming Lemma 4.2. Every pair of distinct vertices appears jointly active in its
edge-indicator, so all six pairs are co-active (Lemma 4.3), the co-activation graph
$G_{S(G)}$ is again $K_4$, and the largest co-active coalition is the full vertex set
of size $4$. Hence $\Omega(S(G))=4=\Phi_{\max}(S(G))=\omega(G)$, exactly as
Theorem 4.4 predicts.

Contrast this with the path $P_4$ on $\{0,1,2,3\}$ with edges
$\{0,1\},\{1,2\},\{2,3\}$. Now $S(G)$ is uniform over $\mathbf{0}$ and three
edge-indicators. Vertices $0$ and $2$ never appear active together (no edge joins
them), so they are not co-active; the largest co-active coalition is any single
edge, of size $2$, giving $\Phi_{\max}(S(G))=2=\omega(P_4)$. The model therefore
distinguishes a tightly bound system (the $K_4$ instance, integration $4$) from a
merely chain-connected one (the $P_4$ instance, integration $2$) precisely by the
size of the largest mutually co-active group — the combinatorial essence of
integration. These computations are reproduced and checked numerically in the
accompanying demonstrations.

## 5. Algorithms, approximation, and tractable regimes

The reduction is a two-way street. Because $\Phi_{\max}(S(G))=\omega(G)$ and, more
generally, $\Phi_{\max}(P)=\Omega(P)$ is a maximum-clique computation on the
*co-activation graph*
$$G_P = (\alpha,\ \{\{u,v\}:u\neq v,\ \mathrm{Coactive}(P,u,v)\}),$$
the entire algorithmic toolkit for cliques applies to integrated information.

**Algorithm 5.1 (Exact $\Phi_{\max}$ via co-activation graph).** Build $G_P$ by
testing co-activation for each of the $\binom{n}{2}$ variable pairs (each test
scans the support of $P$), then compute the maximum clique of $G_P$. Correctness is
Theorem 3.3 plus the definition of $G_P$. The clique step uses, e.g., the
Bron–Kerbosch algorithm; worst-case exponential, but excellent in practice on the
sparse, structured graphs typical of physical systems.

**Tractable regimes.** Several practically important cases are polynomial:

- *Bounded co-activation degree (sparsity).* If every variable is co-active with at
  most $\Delta$ others, then $\Omega(P)\le\Delta+1$ and a maximum clique can be
  found in time $O(n\cdot 3^{\Delta/3})$ — linear in $n$ for fixed $\Delta$. Real
  neural and physical systems are typically sparse, so this is the common case.
- *Perfect / chordal co-activation graphs.* If $G_P$ is perfect (e.g. chordal,
  interval, or comparability), maximum clique is solvable in polynomial time, so
  $\Phi_{\max}$ is exactly computable efficiently.
- *Fixed-parameter tractability.* Parameterizing by the target value $k$, one can
  decide $\Phi_{\max}\ge k$ in time $f(k)\cdot\mathrm{poly}(n)$ on bounded-degeneracy
  graphs, again matching the typical sparse regime.

**Approximation.** When exactness is infeasible one inherits clique approximation:

- *Greedy / degeneracy ordering.* A simple greedy pass over a degeneracy ordering of
  $G_P$ returns a co-active coalition; on bounded-degeneracy graphs it gives a
  constant-factor approximation to $\Omega(P)$.
- *SDP relaxation (Lovász theta).* The Lovász number $\vartheta(\overline{G_P})$
  sandwiches the clique number and is computable in polynomial time via semidefinite
  programming, yielding a certified upper bound on $\Phi_{\max}$ and, on many graph
  classes, tight estimates.

The upshot: worst-case intractability (Corollary 4.5) and practical computability
coexist, mediated entirely by the structure of the co-activation graph. The
model thus does double duty — it explains *why* integrated information is hard and
*where* the hardness dissolves.

## 6. Discussion

Our model trades the full IIT functional for a combinatorial surrogate, and the
trade is illuminating. Three points deserve emphasis.

First, the **collapse theorem** (3.3) isolates a phenomenon that is often implicit
in discussions of the MIP: the optimization over partitions, despite its
exponential search space, is controlled by a single global invariant. In our model
this is exact; we conjecture analogous "the partition optimization is a global
quantity in disguise" phenomena hold for restricted families in the full theory.

Second, the **hardness** (4.5) is structural, not incidental. It does not arise
from numerical precision or from the size of repertoires, but from the basic fact
that detecting irreducible shared structure subsumes clique-finding. This suggests
that *any* faithful integration measure that can encode pairwise-and-up
co-occurrence will be NP-hard, independent of the particular divergence used.

Third, the **two-way reduction** turns a negative (hardness) into a research
program (approximation and special-case algorithms). The co-activation graph is the
right intermediate object: it is computable from $P$ in polynomial time and exposes
exactly the structure that governs both the value and the difficulty of $\Phi_{\max}$.

A limitation worth stating plainly: the surrogate detects *co-occurrence* structure,
not the directed cause–effect structure of full IIT. It therefore captures the
*combinatorial* core of integration (irreducible togetherness) but not its
*dynamical/informational* refinements (how much the past constrains the future
beyond the parts). The complementary KL-divergence model summarized below addresses
the latter; unifying the two is the natural next step.

## 7. Future directions

The following directions, built on a companion fully-formalized discrete IIT core
(finite distributions, mutual information across a cut as KL divergence to the
product-of-marginals reference, the general Kullback–Leibler law, intrinsicality,
and the Minimum-Information-Partition $\Phi$ with its structural laws), are precise
and testable.

**C1. Additivity over independent composition.** For joint systems
$P_1$ on $\alpha_1\times\beta_1$ and $P_2$ on $\alpha_2\times\beta_2$, the mutual
information of $P_1\otimes P_2$ reindexed to $(\alpha_1\times\alpha_2)\times(\beta_1\times\beta_2)$
should equal $I(P_1)+I(P_2)$, so that $\Phi$ of a disjoint union is the sum. The
relative-entropy half is already proved (KL of a product is the sum of KLs); the
remaining step is to identify the marginals of the product with products of
marginals under the four-fold reindexing $(\alpha_1\times\beta_1)\times(\alpha_2\times\beta_2)\simeq(\alpha_1\times\alpha_2)\times(\beta_1\times\beta_2)$.
Falsifiable by a single mixed example with $I(P_1\otimes P_2)\neq I(P_1)+I(P_2)$.

**C2. Data-processing / coarse-graining monotonicity.** For any coarse-graining
$f:\beta\to\beta'$, mutual information should not increase:
$I(P.\mathrm{coarsen}\,f)\le I(P)$, making $\Phi$ monotone under loss of
micro-detail and formalizing IIT's "exclusion" intuition. This extends the
bijective equality case to non-injective maps.

**C3. Upper bound by the smaller part's entropy.** With Shannon entropy $H$,
conjecture $I(P)\le\min(H(P.\mathrm{fst}),H(P.\mathrm{snd}))$, hence
$\Phi\le\min$ over the cut of the part entropies — a first quantitative ceiling on
$\Phi$ from representational capacity. Requires building $H$ and subadditivity.

**C4. Strict super-additivity gap characterizes genuine integration.** Define the
disintegration gap $G(P,S)=H(P)-H(P\text{ across cut }S)$. Conjecture that $\Phi$
over the full cut family is $0$ iff some cut has $G=0$, and otherwise $\Phi$ is
bounded below by a spectral gap of the joint-vs-product correlation operator,
upgrading the qualitative $\Phi=0$ characterization to a quantitative certificate.

**C5. Continuity / stability of $\Phi$.** Conjecture $\Phi$ is locally Lipschitz in
the joint distribution away from the zero-marginal boundary, so small perturbations
of $P$ produce small changes in $\Phi$ — a robustness necessary for physical
meaning. Falsifiable via a discontinuity witness at an interior point.

## 8. Conclusion

We have given a tractable, fully rigorous surrogate model of integrated information
in which the principal claims about $\Phi$ become theorems: the partition
optimization collapses to a single global invariant ($\Phi_{\max}=\Omega$),
integration is bounded by system size ($\Phi_{\max}\le n$), and computing
integration is NP-hard via an exact reduction to maximum clique
($\Phi_{\max}(S(G))=\omega(G)$). The same reduction opens the door to the rich
algorithmic theory of cliques, delineating sparse and structured regimes where
integrated information is efficiently computable or approximable. The model is a
faithful combinatorial shadow of IIT — small enough to prove things about, large
enough to explain why measuring minds is hard, and where it is not.
