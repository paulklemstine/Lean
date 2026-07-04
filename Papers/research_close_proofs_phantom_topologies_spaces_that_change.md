# A Tractable Combinatorial Surrogate for Integrated Information

## Abstract

Integrated Information Theory (IIT) proposes a scalar quantity $\Phi$ intended to
measure the degree to which a system is *irreducible* — how much of its causal or
statistical structure would be lost by partitioning it into independent parts.
The canonical definitions of $\Phi$ are both conceptually intricate and
computationally forbidding. We introduce and analyze a **combinatorial
surrogate** for $\Phi$ that retains the qualitative core of the theory — maximal
irreducibility across bipartitions — while being an honest, finite, decidable
natural number. The surrogate is built from the *co-activation relation* of a
finite system of Boolean variables: two variables are co-active when they are
active together at least as often as statistical independence would predict.
Given this relation, $\Phi$ is defined as the maximum, over all bipartitions of
the variable set into two nonempty parts, of the number of co-active pairs that
cross the partition. We prove three principal results. First (**Cross-Score
Lemma**), for the *complete co-activation* — in which every pair of distinct
variables is co-active — the cross-score of a bipartition $(A,B)$ equals exactly
$|A|\cdot|B|$. Second (**Complete Integration Formula**), the surrogate
integrated information of the complete co-activation on $n$ variables equals
$\lfloor n^2/4\rfloor$, verified for all systems with $n \le 4$ and matching the
extremal count of Mantel/Turán type. Third (**Monotonicity under Independent
Extension**), adjoining a variable that is co-active with nothing never decreases
$\Phi$. We give a fully executable implementation that computes $\Phi$ for an
arbitrary binary distribution specified by exact rational weights on
configurations, and we verify worked examples: a perfectly correlated triple has
$\Phi = 2$, while an independent pair has $\Phi = 0$. We discuss complexity,
applications, and limitations.

**Keywords:** integrated information, $\Phi$, co-activation, bipartition,
cross-score, extremal graph theory, Mantel's theorem, computable surrogate.

---

## 1. Introduction

A recurring problem across neuroscience, network science, and machine learning is
to quantify when a system is *more than the sum of its parts*. Integrated
Information Theory (IIT) formalizes an answer through a scalar $\Phi$: a system
has high $\Phi$ when it cannot be decomposed into (near-)independent components
without a large loss of structure. The intuition is compelling, but the
operational definitions of $\Phi$ suffer from two well-known difficulties: they
depend on delicate choices (of distance measures between distributions, of
partitioning schemes, of "minimum information partition"), and they are
computationally intractable, requiring searches over exponentially many
partitions of quantities that are themselves expensive to evaluate.

This paper takes a deliberately modest and rigorous route. Rather than attempting
to compute the full $\Phi$, we isolate the *combinatorial skeleton* of the idea —
irreducibility measured across the best bipartition — and study it in a setting
where every quantity is a finite, decidable natural number. The result is a
surrogate that is provably well-behaved, exactly computable, and amenable to
closed-form analysis in the extremal case.

Our contributions are:

1. A precise, self-contained definition of a surrogate $\Phi$ built from the
   co-activation relation of a finite Boolean system (Section 3).
2. The **Cross-Score Lemma**: for the complete co-activation, the cross-score of
   a bipartition $(A,B)$ is exactly $|A|\cdot|B|$ (Section 4).
3. The **Complete Integration Formula**: $\Phi = \lfloor n^2/4\rfloor$ for the
   complete co-activation on $n$ variables (Section 5).
4. **Monotonicity under Independent Extension**: adjoining an uncorrelated
   variable never decreases $\Phi$ (Section 6).
5. A fully executable algorithm computing $\Phi$ from exact rational
   configuration weights, with verified worked examples (Section 7).

---

## 2. The probabilistic model

Let $\alpha$ be a finite index set of Boolean variables; we usually take
$\alpha = \{1, \dots, n\}$. A **configuration** is a function
$c : \alpha \to \{\text{false}, \text{true}\}$, assigning to each variable an
*inactive* (false) or *active* (true) state. A **system** is a probability
distribution $P$ over configurations, i.e. an assignment of nonnegative weights
summing to $1$ over the $2^n$ configurations.

From $P$ we extract the pairwise statistics that drive the surrogate.

**Definition 2.1 (Marginal).** The *marginal* of variable $i$ is the probability
that $i$ is active,
$$m_i \;=\; \Pr_{c\sim P}[\, c(i) = \text{true} \,] \;=\; \sum_{c} P(c)\,[\,c(i)=\text{true}\,].$$

**Definition 2.2 (Joint activation).** The *joint activation* of variables $i$
and $j$ is the probability that both are active,
$$J_{ij} \;=\; \Pr_{c\sim P}[\, c(i)=\text{true} \ \wedge\ c(j)=\text{true} \,].$$

**Definition 2.3 (Co-activity).** Variables $i$ and $j$ are **co-active** when
they are active together at least as often as independence predicts:
$$i \sim j \quad\Longleftrightarrow\quad m_i \cdot m_j \;\le\; J_{ij}.$$

Co-activity is the pairwise signature of positive association. It is symmetric,
and (with the non-strict inequality) reflexive-compatible; what matters for the
surrogate is only its restriction to distinct pairs.

**Definition 2.4 (Co-active coalition).** A set $S \subseteq \alpha$ is a
*co-active coalition* if every pair of distinct members of $S$ is co-active. In
graph-theoretic language, coalitions are cliques of the co-activation graph.

The co-activation relation is naturally encoded as a symmetric Boolean matrix
$R : \alpha \times \alpha \to \{\text{false},\text{true}\}$ with $R(i,j)$ true iff
$i \sim j$. All subsequent definitions depend on the system $P$ only through $R$,
which is what makes the surrogate combinatorial.

---

## 3. The surrogate $\Phi$

The qualitative content of IIT is that integration is *irreducibility across
cuts*: a system is integrated to the degree that every bipartition severs
substantial structure. We surrogate this on the co-activation relation.

**Definition 3.1 (Cross-score).** Given a symmetric relation
$R : \alpha \times \alpha \to \{\text{false},\text{true}\}$ and disjoint subsets
$A, B \subseteq \alpha$, the **cross-score** is the number of co-active pairs that
cross the cut:
$$\mathrm{cross}_R(A, B) \;=\; \#\{\,(i,j) \in A \times B \ :\ R(i,j) \,\}.$$

**Definition 3.2 (Surrogate integrated information).** The **surrogate integrated
information** of $R$ is the maximal cross-score over all bipartitions of $\alpha$
into two disjoint nonempty parts:
$$\Phi(R) \;=\; \max_{\substack{A, B \subseteq \alpha \\ A \cap B = \varnothing \\ A, B \ne \varnothing}} \ \mathrm{cross}_R(A, B).$$

(When $|\alpha| \le 1$ there is no such bipartition; we set $\Phi = 0$.)

Several features deserve emphasis:

- **$\Phi$ is a natural number.** Every ingredient is a finite count over finite
  sets, so $\Phi(R) \in \mathbb{N}$ with no analytic subtleties.
- **$\Phi$ is decidable and computable.** The maximum ranges over the finitely
  many ways of assigning each of $|\alpha|$ elements to $A$, to $B$, or to
  neither, giving an $O(2^{|\alpha|})$ (more precisely $O(3^{|\alpha|})$ naively,
  reducible) enumeration. In particular $\Phi$ can be evaluated by exhaustive
  search.
- **$\Phi$ measures maximal, not minimal, severed cohesion.** Taking the maximum
  cross-score identifies the cut that best exposes the system's crossing
  structure; it is the "most integration a single cut can witness," a
  conservative and monotone reading of irreducibility that is convenient to
  analyze.

The rest of the paper establishes the structural theory and computational content
of $\Phi$.

---

## 4. The Cross-Score Lemma

The extremal object of the theory is the *complete co-activation*: the relation
in which every pair of distinct variables is co-active.

**Definition 4.1 (Complete co-activation).** The **complete co-activation** on a
finite set $\alpha$ is the relation
$$K_\alpha(i, j) \;=\; [\, i \ne j \,],$$
true precisely for distinct pairs. It models a maximally integrated system in
which no pair is independent.

**Theorem 4.2 (Cross-Score Lemma).** For the complete co-activation $K_\alpha$
and disjoint subsets $A, B \subseteq \alpha$,
$$\mathrm{cross}_{K_\alpha}(A, B) \;=\; |A| \cdot |B|.$$

*Proof sketch.* The cross-score counts pairs $(i, j) \in A \times B$ with
$K_\alpha(i,j)$ true, i.e. with $i \ne j$. Since $A$ and $B$ are disjoint, every
pair $(i,j) \in A \times B$ automatically has $i \ne j$ (an element of $A$ cannot
equal an element of $B$). Hence the filtering condition is vacuously satisfied for
all of $A \times B$, and the cross-score equals the cardinality of the product
set, $|A \times B| = |A|\cdot|B|$. $\qquad\blacksquare$

The lemma reduces the analysis of the most integrated systems to a pure counting
problem: maximize $|A|\cdot|B|$ over bipartitions.

---

## 5. The Complete Integration Formula

**Theorem 5.1 (Complete Integration Formula).** For the complete co-activation
$K_n$ on $n$ variables,
$$\Phi(K_n) \;=\; \left\lfloor \frac{n^2}{4} \right\rfloor.$$
This holds in particular for all $n \le 4$, where it can be certified by direct
enumeration of co-active bipartitions.

*Proof sketch.* By the Cross-Score Lemma (Theorem 4.2), for the complete
co-activation every bipartition $(A,B)$ into nonempty disjoint parts has
cross-score $|A|\cdot|B|$. The maximum of $\Phi$ can moreover always be attained
by a bipartition that *covers* all $n$ variables (assigning a variable to neither
part only removes potential cross-pairs), so we may write $|A| = k$, $|B| = n-k$
with $1 \le k \le n-1$. Thus
$$\Phi(K_n) \;=\; \max_{1 \le k \le n-1} k(n-k).$$
The parabola $k \mapsto k(n-k)$ is maximized at $k = n/2$; over integers the
maximum is achieved at $k = \lfloor n/2\rfloor$, giving
$\lfloor n/2\rfloor \cdot \lceil n/2\rceil = \lfloor n^2/4\rfloor$. For $n \le 4$
the claim is verified by exhaustively enumerating the (finitely many) bipartitions
and their cross-scores, which yields the values $\Phi(K_1)=0$, $\Phi(K_2)=1$,
$\Phi(K_3)=2$, $\Phi(K_4)=4$, matching $\lfloor n^2/4\rfloor$. $\qquad\blacksquare$

**Remark 5.2 (Connection to extremal graph theory).** The quantity
$\lfloor n^2/4\rfloor$ is exactly the number of edges of the balanced complete
bipartite graph $K_{\lfloor n/2\rfloor, \lceil n/2\rceil}$, and by Mantel's
theorem it is the maximum number of edges in a triangle-free graph on $n$
vertices. The identification of the ceiling on surrogate integration with this
classical extremal quantity is not a coincidence: maximizing crossing cohesion
over a single cut is precisely the complete-bipartite optimization that Mantel's
theorem answers.

**Remark 5.3 (Small values).** The sequence $\lfloor n^2/4\rfloor$ for
$n = 1,2,3,4,5,6,\dots$ is $0,1,2,4,6,9,\dots$ — the "quarter-squares," a
classically studied integer sequence.

---

## 6. Monotonicity under independent extension

An honest measure of integration should not be *reduced* by adjoining an inert
component. We formalize this and record that the surrogate obeys it.

**Definition 6.1 (Independent extension).** Given a relation $R$ on $\alpha$, its
*independent extension* to $\alpha \sqcup \{\ast\}$ (adjoining one fresh variable
$\ast$) is the relation $R^{+}$ that agrees with $R$ on old pairs and sets
$R^{+}(\ast, x) = R^{+}(x, \ast) = \text{false}$ for every $x$: the new variable
is co-active with nothing.

**Theorem 6.2 (Monotonicity under Independent Extension).** For every relation
$R$ on a finite set $\alpha$,
$$\Phi(R^{+}) \;\ge\; \Phi(R).$$

*Proof sketch.* Let $(A, B)$ be a bipartition of $\alpha$ attaining $\Phi(R)$.
The same pair $(A, B)$ is a valid nonempty disjoint bipartition of the larger set
$\alpha \sqcup \{\ast\}$ (simply leaving $\ast$ unassigned, or placing it in
either part). Because $\ast$ is co-active with nothing, no cross-pair involving
$\ast$ is ever counted, so the cross-score of $(A,B)$ under $R^{+}$ equals its
cross-score under $R$. Hence
$\Phi(R^{+}) \ge \mathrm{cross}_{R^{+}}(A,B) = \mathrm{cross}_R(A,B) = \Phi(R)$.
$\qquad\blacksquare$

The result confirms that the surrogate treats uncorrelated additions as, at
worst, neutral — never destructive — which is the discrete analogue of the
stability one expects of any measure of wholeness.

---

## 7. Computation and worked examples

### 7.1 A computable pipeline over exact rationals

The surrogate is designed to be executed, not merely contemplated. An arbitrary
binary distribution on $n$ variables can be presented as a weight function
$w : (\{1,\dots,n\}\to\{\text{false},\text{true}\}) \to \mathbb{Q}$, i.e. an exact
rational weight on each of the $2^n$ configurations. From $w$ we compute, using
only exact rational arithmetic:

- the **marginal** $m_i = \sum_{c} w(c)\,[c(i)=\text{true}]$;
- the **joint activation**
  $J_{ij} = \sum_{c} w(c)\,[c(i)=\text{true}\wedge c(j)=\text{true}]$;
- the **co-activation matrix**, taking $i$ and $j$ co-active when
  $m_i \cdot m_j < J_{ij}$ (strict positive correlation);
- the surrogate $\Phi$, by maximizing the cross-score over all nonempty disjoint
  bipartitions.

Every step is a finite sum or a finite maximum over exact rationals, so the whole
pipeline is exact: no floating point, no rounding, and a definite integer output.

**Remark 7.1 (Strict vs. non-strict co-activity).** The structural theory
(Sections 4–6) uses the non-strict co-activity $m_i m_j \le J_{ij}$, which makes
the *complete* co-activation the natural extremal object. The computational
pipeline uses the strict version $m_i m_j < J_{ij}$ so that mere independence
($m_i m_j = J_{ij}$) does not register as integration. The two conventions agree
away from the independence boundary and are chosen to make each part of the theory
as clean as possible; the worked examples below illustrate both endpoints.

### 7.2 A perfectly correlated triple has $\Phi = 2$

Consider three variables that are locked together: the distribution places weight
$\tfrac12$ on the all-active configuration and weight $\tfrac12$ on the
all-inactive configuration (equivalently, $w(c)=\tfrac12$ exactly when
$c(1)=c(2)=c(3)$, and $0$ otherwise). Then for each variable $m_i = \tfrac12$, and
for each pair $J_{ij} = \tfrac12$, so $m_i m_j = \tfrac14 < \tfrac12 = J_{ij}$ and
all three pairs are co-active. The co-activation relation is exactly the complete
co-activation $K_3$, and by the Complete Integration Formula (Theorem 5.1)
$$\Phi = \left\lfloor \tfrac{3^2}{4}\right\rfloor = 2,$$
realized by any split into a singleton and a pair, whose cross-score is
$1 \cdot 2 = 2$.

### 7.3 An independent pair has $\Phi = 0$

Consider two variables that flip independently and fairly: every one of the four
configurations has weight $\tfrac14$. Then $m_1 = m_2 = \tfrac12$ and
$J_{12} = \tfrac14$, so $m_1 m_2 = \tfrac14 = J_{12}$: the pair is *not* strictly
co-active. The co-activation graph has no edges, every cut severs nothing, and
$$\Phi = 0.$$
A system of independent parts correctly registers zero integration.

### 7.4 Complexity

Evaluating marginals and joints is $O(2^n)$ per statistic. The maximization
defining $\Phi$ ranges over bipartitions of an $n$-element set, an $O(2^n)$
(or $O(3^n)$ naive) search. The overall procedure is therefore exponential in the
number of variables — expected for a quantity of IIT type — but entirely
practical for the small systems (say $n \le 20$) where exact, certified answers
are most valuable.

---

## 8. Applications

**Neuroscience and consciousness studies.** The surrogate provides a rigorous,
reproducible stand-in for $\Phi$ on small neural motifs, where the full IIT
computation is already at the edge of feasibility and where exact values (rather
than approximations of a contested definition) are useful for testing hypotheses
about which network structures maximize integration.

**Network and complexity science.** Interpreting the co-activation graph as a
correlation network, $\Phi$ becomes a max-cut-flavored measure of how strongly a
network's positive correlations bind it across its best partition — a
quantity with an explicit extremal characterization (Theorem 5.1) that other
"integration" heuristics lack.

**Machine learning representations.** Given the activation statistics of a layer
of Boolean (or thresholded) units over a dataset, the surrogate quantifies how
integrated the learned representation is, and the monotonicity result (Theorem
6.2) guarantees that adding uninformative, uncorrelated features cannot spuriously
lower the measured integration.

---

## 9. Discussion, limitations, and future work

The surrogate deliberately sacrifices some of IIT's ambitions — it uses only
pairwise co-activation, a single best cut, and integer counts — in exchange for
three assets that the full theory lacks: exact computability, closed-form
extremal behavior ($\lfloor n^2/4\rfloor$), and provable monotonicity. This makes
it a clean testbed and a conservative lower-bound-style proxy rather than a
replacement for $\Phi$.

**Limitations.** (i) Only pairwise structure is captured; genuine higher-order
integration (present when triples are correlated beyond their pairwise marginals)
is invisible to a relation on pairs. (ii) Taking the *maximum* cross-score
measures the most a single cut can witness, whereas some formulations of IIT
emphasize the *minimum* information partition; the two make different, both
defensible, design choices. (iii) The complexity is exponential, as is inherent to
partition-based measures.

**Future work.** Natural extensions include: a hypergraph surrogate that counts
co-active $k$-tuples to capture higher-order integration; a *minimum*-cut variant
and a comparison of its extremal theory to the maximum-cut version studied here; a
weighted cross-score using the correlation excess $J_{ij} - m_i m_j$ rather than a
Boolean threshold; and spectral or flow-based relaxations that approximate $\Phi$
in polynomial time while preserving the exact answer on the extremal complete
co-activation.

---

## Appendix: summary of results

- **Cross-Score Lemma (Thm 4.2).** For the complete co-activation and disjoint
  $A,B$: $\mathrm{cross}(A,B) = |A|\cdot|B|$.
- **Complete Integration Formula (Thm 5.1).** For the complete co-activation on
  $n$ variables: $\Phi = \lfloor n^2/4\rfloor$ (verified for $n \le 4$).
- **Monotonicity under Independent Extension (Thm 6.2).** Adjoining a variable
  co-active with nothing satisfies $\Phi(R^{+}) \ge \Phi(R)$.
- **Worked examples.** Perfectly correlated triple: $\Phi = 2$. Independent pair:
  $\Phi = 0$.
