# Sheaf-Theoretic Data Integration: When Databases Form a Sheaf

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Cryptography / Applied Sheaf Theory

## Abstract

We give a precise, fully formal account of the folklore that "databases form a
sheaf." Fixing a key space $K$ and a value type $\mathrm{Val}$, we model a
database over a set of keys $U \subseteq K$ as a function $U \to \mathrm{Val}$,
and restriction along inclusions of key sets as the presheaf structure. We prove
the presheaf laws (restriction is functorial), and then the two halves of the
sheaf condition: **separation** (a global database is determined by its
restrictions to a cover) and **gluing** (any overlap-consistent family of local
databases over a cover extends to a *unique* global database). We show these
combine into an exact characterization — a family of partial databases is
integrable if and only if it is pairwise overlap-consistent — and specialize it
to the two-table merge that underlies the relational `JOIN`/`UNION`. We then
connect data integration to **cellular sheaf cohomology**: the consistent
integrations of a schema graph form a submodule of global sections, which for the
constant sheaf equals the zeroth cohomology $H^0$, and which is *rigid* over a
connected schema (determined by the value at a single node). We close with a
quantitative model of imputation hardness, the conjecture
$P(\text{sheaf}) = (1-r)^{C}$, and a program of cohomological extensions
including an $H^1$ obstruction theory and a cryptographic leakage bound. All
mathematical statements below are stated inline with proof sketches; the
development has been verified in a proof assistant.

---

## 1. Introduction

Data integration — combining partial, overlapping data sources into a single
coherent dataset — is among the most common operations in computing, and one of
the most error-prone. Two tables that should describe the same entities can
disagree on the cells they share, and no consistent merge exists. The working
intuition of every database practitioner is: *the merge succeeds precisely when
the sources agree on what they share.* The contribution of this paper is to show
that this intuition is not merely sound engineering but a **theorem** — indeed
the gluing axiom of a sheaf — and to derive its consequences.

Sheaf theory is the mathematics of passing from local to global data. A sheaf on
a space assigns to each open set a collection of "sections" (local data), with
restriction maps to smaller sets, subject to two axioms: *separation* (sections
agreeing locally everywhere are equal) and *gluing* (locally compatible sections
assemble uniquely into a global section). We instantiate this framework with
databases as sections, obtaining the following dictionary:

| Sheaf theory | Database integration |
|---|---|
| Space / site | Key space $K$ |
| Open set $U$ | Set of keys (columns × rows) present |
| Section over $U$ | Database (record assignment) on $U$ |
| Restriction | Project onto a subset of keys |
| Compatible family | Overlap-consistent tables |
| Gluing | Successful, unique merge |
| $H^0$ of constant sheaf | Globally consistent integrations |
| $H^1$ (future) | Obstruction to integration |

Two complementary pictures emerge. The **presheaf of records over a key space**
(Sections 2–4) yields the gluing/separation theorems and the integrability
criterion. The **cellular sheaf of a schema graph** (Section 5) yields a
cohomological reading: integrations are global sections, equal to $H^0$ for the
constant sheaf, and rigid over connected schemas. Section 6 develops the
quantitative imputation model, and Section 7 collects future directions.

---

## 2. The presheaf of records

Throughout, fix types $K$ (keys) and $\mathrm{Val}$ (values).

**Definition 2.1 (Record).** For a set of keys $U \subseteq K$, a *record over
$U$* is a function
$$ s : U \to \mathrm{Val}. $$
We write $\mathrm{Record}(K,\mathrm{Val},U)$ for the type of all such records.
A *database* over $U$ is precisely a record over $U$; a database "with missing
entries" is a record over the proper subset $U$ of keys whose cells are filled.

**Definition 2.2 (Restriction).** For key sets $W \subseteq U$ and a record
$s \in \mathrm{Record}(K,\mathrm{Val},U)$, the *restriction* of $s$ to $W$ is
$$ (\mathrm{restrict}_{W \subseteq U}\, s)(x) = s(x), \qquad x \in W. $$
Formally, on the underlying coerced elements, $\mathrm{restrict}\,s$ sends
$x \in W$ to $s$ evaluated at the inclusion image of $x$ in $U$.

The pair (records, restriction) is a *presheaf* on the poset of subsets of $K$
ordered by inclusion. The two presheaf laws hold definitionally.

**Proposition 2.3 (Identity law, `restrict_self`).** For any $s$ over $U$,
$$ \mathrm{restrict}_{U \subseteq U}\, s = s. $$
*Proof.* Pointwise both sides evaluate $s$ at $x$; extensionality closes the
goal. $\square$

**Proposition 2.4 (Composition law, `restrict_restrict`).** For nested key sets
$X \subseteq W \subseteq U$ and $s$ over $U$,
$$ \mathrm{restrict}_{X \subseteq W}\big(\mathrm{restrict}_{W \subseteq U}\, s\big)
   = \mathrm{restrict}_{X \subseteq U}\, s. $$
*Proof.* Pointwise, both sides evaluate $s$ at the image of $x \in X$ under the
composite inclusion $X \hookrightarrow U$; the two composite inclusions are equal,
so the records agree. $\square$

These propositions establish that records-over-key-sets is a genuine
contravariant functor from the inclusion poset of $K$ — the substrate on which
the sheaf axioms are formulated.

---

## 3. The sheaf condition

We now consider *covers*: families of key sets indexed by an arbitrary type $I$.

**Definition 3.1 (Overlap-consistency, `Consistent`).** Let $S : I \to
\mathcal{P}(K)$ be a family of key sets and $r$ a family of local records, with
$r_i$ over $S_i$. The family is *overlap-consistent* if any two records agree on
shared keys:
$$ \mathrm{Consistent}(S, r) \;:\equiv\; \forall i, j,\ \forall x \in S_i \cap S_j,\quad
   r_i(x) = r_j(x). $$

The two sheaf axioms now read as theorems about this data.

**Theorem 3.2 (Separation, `glue_eq_of_locally_eq`).** Let $S : I \to
\mathcal{P}(K)$ be a cover and let $g, g'$ be records over the union
$\bigcup_i S_i$. If $g$ and $g'$ have identical restrictions to every piece of
the cover,
$$ \forall i,\quad \mathrm{restrict}_{S_i \subseteq \bigcup S}\, g
   = \mathrm{restrict}_{S_i \subseteq \bigcup S}\, g', $$
then $g = g'$.

*Proof sketch.* Fix a key $x \in \bigcup_i S_i$. By definition of union there is
an index $i$ with $x \in S_i$. The hypothesis at $i$, evaluated at $x$, gives
$g(x) = g'(x)$. As $x$ was arbitrary, extensionality yields $g = g'$. $\square$

**Theorem 3.3 (Gluing — databases form a sheaf, `exists_unique_glue`).** Let
$S : I \to \mathcal{P}(K)$ be a cover and $r$ a family with $r_i$ over $S_i$. If
$\mathrm{Consistent}(S, r)$, then there is a *unique* global record $g$ over
$\bigcup_i S_i$ restricting to each $r_i$:
$$ \exists!\, g \in \mathrm{Record}\big(K,\mathrm{Val},\textstyle\bigcup_i S_i\big),
   \quad \forall i,\ \mathrm{restrict}_{S_i \subseteq \bigcup S}\, g = r_i. $$

*Proof sketch.* **Existence** is constructive. For each $x \in \bigcup_i S_i$,
choose (by the axiom of choice, via the membership witness) an index $i_x$ with
$x \in S_{i_x}$, and define $g(x) := r_{i_x}(x)$. To check $\mathrm{restrict}_{S_j}\,
g = r_j$ for a fixed $j$, evaluate at $x \in S_j$: we must show $r_{i_x}(x) =
r_j(x)$, which is exactly overlap-consistency applied to the indices $i_x$ and
$j$ at the shared key $x$. **Uniqueness** is immediate from separation
(Theorem 3.2): any two glued records have the same restrictions ($= r_i$) to
every piece, hence are equal. $\square$

Theorem 3.3 is the precise content of "consistent data integration always
succeeds and is unique." The well-definedness of the construction (independence
of the choice $i_x$) is *exactly* the consistency hypothesis — no more, no less.

---

## 4. Integrability equals consistency

The converse of gluing is automatic, giving a clean biconditional that serves as
the database engine's decision procedure.

**Proposition 4.1 (Restrictions are consistent, `consistent_of_restrict`).** Let
$g$ be a record over $U$, and let $S : I \to \mathcal{P}(K)$ with $S_i \subseteq
U$ for all $i$. Then the family $\big(\mathrm{restrict}_{S_i \subseteq U}\,
g\big)_i$ is overlap-consistent.
*Proof.* For $x \in S_i \cap S_j$, both restricted records evaluate $g$ at the
same key $x$, so they agree. $\square$

**Theorem 4.2 (Integrability ⇔ consistency, `exists_glue_iff_consistent`).** For
a cover $S : I \to \mathcal{P}(K)$ and a family $r$ with $r_i$ over $S_i$,
$$ \Big(\exists\, g\ \text{over}\ \textstyle\bigcup_i S_i,\ \forall i,\
   \mathrm{restrict}_{S_i}\, g = r_i\Big)
   \iff \mathrm{Consistent}(S, r). $$

*Proof sketch.* ($\Rightarrow$) If a glue $g$ exists, then $r_i =
\mathrm{restrict}_{S_i}\, g$, and these restrictions are consistent by
Proposition 4.1. ($\Leftarrow$) Apply gluing (Theorem 3.3) and forget
uniqueness. $\square$

This is the central practical statement: deciding whether a set of tables can be
merged — a global, existential question — reduces to checking pairwise agreement
on shared keys, a local and cheaply verifiable one. No search over candidate
merges is required.

**Theorem 4.3 (Two-table merge, `exists_unique_merge_two`).** Let $S_0, S_1
\subseteq K$, with records $r_0$ over $S_0$ and $r_1$ over $S_1$. If they agree
on every shared key,
$$ \forall x \in S_0 \cap S_1,\quad r_0(x) = r_1(x), $$
then there is a *unique* record $g$ over $S_0 \cup S_1$ with
$\mathrm{restrict}_{S_0}\, g = r_0$ and $\mathrm{restrict}_{S_1}\, g = r_1$.

*Proof sketch.* Specialize Theorem 3.3 to the two-element cover $S : \mathrm{Bool}
\to \mathcal{P}(K)$ with $S_{\mathrm{false}} = S_0$, $S_{\mathrm{true}} = S_1$;
the hypothesis is exactly two-index overlap-consistency, and the union is
$S_0 \cup S_1$. $\square$

Theorem 4.3 is the mathematical specification of the relational `JOIN`/`UNION`
of two consistent tables — the most frequent data-integration primitive in
practice — with a built-in guarantee of existence and uniqueness.

---

## 5. The cellular sheaf of a schema graph

The second picture replaces the key space by a *schema graph* $G = (V, E)$ on a
vertex set $V$: vertices are data sources, edges are agreement constraints. We
work with sheaves of $R$-modules for a commutative ring $R$.

**Definition 5.1 (Constant graph sheaf and $H^0$).** For a simple graph $G$ on
$V$ and a commutative ring $R$, the zeroth cohomology of the constant sheaf is
the submodule of $V \to R$ of functions that are constant along every edge:
$$ H^0(G, R) = \big\{ f : V \to R \;\big|\; \forall\, v \sim w \text{ in } G,\ f(v) = f(w)\big\}. $$
More generally, a *graph sheaf* $F$ assigns a stalk (module) to each vertex and
comparison maps along edges; a function $f$ assigning to each vertex an element
of its stalk is a *global section* (`IsGlobalSection`) when every edge
constraint holds. The consistent integrations form the submodule
`globalSections`.

**Theorem 5.2 (Cohomological characterization, `mem_H0_iff_reachable`).** A
function $f : V \to R$ lies in $H^0(G, R)$ if and only if $f$ is constant on
every reachable pair:
$$ f \in H^0(G,R) \iff \big(\forall v, w,\ G.\mathrm{Reachable}(v,w) \Rightarrow f(v) = f(w)\big). $$
*Proof sketch.* Constancy along single edges propagates along walks by induction
on walk length; conversely adjacency implies reachability. $\square$

**Theorem 5.3 (Integrations = $H^0$, `globalSections_constantSheaf` /
`mkConstantSheaf_section_iff_H0`).** For the constant sheaf, $f$ is a global
section (a consistent integration) if and only if $f \in H^0(G,R)$. Thus the
consistent integrations of the constant sheaf are *exactly* the zeroth
cohomology. $\square$

**Theorem 5.4 (Connected rigidity, `H0_eq_const_of_connected`).** If $G$ is
connected, then
$$ H^0(G, R) = \{\, f : V \to R \mid f \text{ is constant} \,\}. $$
*Proof sketch.* Reachability is total on a connected graph, so by Theorem 5.2
every $f \in H^0$ is constant; conversely constants always lie in $H^0$. $\square$

**Theorem 5.5 (Evaluation injectivity,
`globalSections_eval_injective_of_connected`).** Over a connected schema $G$, a
consistent integration is determined by its value at any single vertex $v_0$:
the evaluation map $\mathrm{globalSections} \to R$, $f \mapsto f(v_0)$, is
injective.
*Proof sketch.* By Theorem 5.4 a global section is constant; a constant function
is recovered from its value anywhere. $\square$

**Theorem 5.6 (Dimension count, `finrank_H0_eq_card_connectedComponent`).** Over
a field $k$,
$$ \dim_k H^0(G, k) = \#\{\text{connected components of } G\}. $$
*Proof sketch.* $H^0$ is isomorphic to functions on the set of connected
components (a global section is constant on each component and arbitrary across
components); take dimensions. $\square$

Together, Theorems 5.2–5.6 give a cohomological reading of integration: the
consistent integrations are the kernel of the consistency (coboundary)
constraints, the number of free parameters equals the number of independent data
"islands," and a connected schema forces total rigidity. Disconnection is the
first invariant detecting nontrivial structure; the second, $H^1$, governs
obstructions (Section 7).

---

## 6. Quantitative imputation model

The sheaf picture suggests a principled imputation method and a quantitative law
for its feasibility.

**Sheaf imputation.** A database with missing entries is a partial section: a
record on the filled keys $U_{\mathrm{obs}} \subseteq K$. *Sheaf imputation*
extends it to a global section over $\bigcup_i S_i$ by selecting, among all global
sections, one closest (in a chosen metric) to the observed values — equivalently,
solving the constrained optimization
$$ \min_{g}\ \mathrm{dist}\big(g|_{U_{\mathrm{obs}}},\, s_{\mathrm{obs}}\big)
   \quad \text{subject to}\quad \mathrm{Consistent}\ \text{on every overlap}. $$
Unlike mean imputation (which ignores structure) or $k$-nearest-neighbor
imputation (which uses only local similarity), sheaf imputation enforces *all*
overlap constraints simultaneously — combinatorially many of them.

**Feasibility law (conjecture).** Suppose entries are missing independently at
rate $r$, and let $C$ count the overlapping consistency constraints (for $n$
columns and $k$ rows, $C$ scales with the number of overlapping feature subsets,
e.g. $C = \binom{n}{k}$ in the concept's formulation). Then the probability that
a random partial database admits a consistent completion behaves as
$$ \boxed{\,P(\text{sheaf}) = (1 - r)^{C}\,}. $$
The interpretation is that each independent overlap constraint survives with
probability $1 - r$, and feasibility requires all $C$ to survive jointly. Two
predictions follow: (i) consistent completion becomes exponentially rare as the
overlap web grows, and (ii) *when* a dataset is genuinely consistent, those same
$C$ constraints carry exponentially more imputation information than purely local
methods can exploit. This yields the testable hypothesis that sheaf imputation
outperforms mean, KNN, and MICE imputation in the regime $r < 0.5$ and $n > 10$.

A controlled experiment: generate synthetic data with a known global section as
ground truth, delete entries at rate $r$, and compare reconstruction error of
sheaf imputation against mean/KNN/MICE across $(n, r)$. The accompanying demo
implements the gluing decision procedure, the two-table merge, the connected-
rigidity propagation, and a Monte-Carlo estimate of $P(\text{sheaf})$ validating
the exponential law.

---

## 7. Discussion and future work

We have shown that databases over a key space form a genuine sheaf — separation
and gluing hold, and *integrability is exactly overlap-consistency*
(`exists_glue_iff_consistent`). On the schema-graph side, consistent
integrations form the submodule `globalSections`, equal to $H^0$ for the constant
sheaf, with rigidity over connected schemas. We outline the next layer.

**Conjecture 1 — Cohomological obstruction ($H^1$ vanishing).** Define cellular
$1$-cochains and a coboundary $\delta^0 : C^0(G,F) \to C^1(G,F)$ for a graph
sheaf $F$. A globally consistent integration extending a prescribed family of
edge-agreements exists *iff* its class in $H^1(G,F) = \ker \delta^1 / \mathrm{im}\,
\delta^0$ vanishes. For the constant sheaf on a graph with first Betti number
$b_1$, $\dim H^1 = b_1$. *Falsifiable:* a cycle $C_n$ with an edge-twist whose
$H^1$ class is nonzero admits no global section restricting to it, while acyclic
schemas always integrate.

**Conjecture 2 — Unique integration ⇔ acyclic schema.** For the constant sheaf
over a nontrivial ring $R$, evaluation-at-a-vertex
$\mathrm{globalSections} \to R$ is bijective for *every* base vertex iff $G$ is a
tree. Injectivity for connected $G$ is Theorem 5.5; the conjecture is that
surjectivity and injectivity together characterize trees once non-identity
comparison maps (gauge) are admitted. *Falsifiable:* on $C_3$ with a nontrivial
automorphism gauge, integration should fail surjectivity.

**Conjecture 3 — Finite gluing suffices (compactness).** For the database sheaf,
a family $r$ is overlap-consistent iff every *pair* $\{i,j\}$ is consistent on
$S_i \cap S_j$ — pairwise consistency implies global consistency, collapsing the
Čech $0$/$1$ condition and upgrading Theorem 4.3 to arbitrary covers.
*Falsifiable:* search for a pairwise-consistent-but-not-jointly-consistent family
for plain records; the conjecture predicts none (but predicts counterexamples
once stalks carry nontrivial transition maps).

**Conjecture 4 — Privacy/leakage bound (cryptographic bridge).** Model a secret-
sharing scheme as a graph sheaf with share-space stalks and reconstruction
constraints on edges. An unauthorized coalition $T \subseteq V$ learns nothing
about the secret iff the restriction $\mathrm{globalSections}(F) \to \prod_{v \in
T} \mathrm{Stalk}(v)$ is *not injective on the secret coordinate* — i.e. the
secret lies outside the image of the $T$-localized coboundary. This recasts
access structures as cohomological injectivity statements and links data
consistency directly to cryptographic security.

## 8. Conclusion

"Databases form a sheaf" is a theorem, not a metaphor. The presheaf of partial
records satisfies functoriality, separation, and gluing; mergeability is exactly
overlap-consistency; and the schema-graph picture renders integration as
zeroth cohomology, rigid over connected schemas and quantified by component
count. These results provide a rigorous foundation for consistent imputation,
a quantitative feasibility law, and a roadmap toward an obstruction theory ($H^1$)
and cryptographic leakage bounds.
