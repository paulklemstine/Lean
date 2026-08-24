# Tropical Epistasis of Layer Ablations: Pruning Cost as a Min-Plus Minimum, and the Hitting-Set Origin of Co-Adapted Layer Units

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We develop a tropical (min-plus) model of the accuracy cost of ablating layers in
a trained deep network, and use it to explain a striking empirical phenomenon: in
a $24$-layer transformer subjected to a per-layer sparsification budget, layers
$22$ and $23$ each cost $0.03$ accuracy points when pruned alone, yet cost $0.42$
points when pruned together — a seven-fold super-additive blow-up — while other
pairs in the same network are exactly additive or strictly sub-additive.

The model represents a network as a finite family of *computation paths*, each
depending on a set of layers (its *support*) and carrying a loss. Pruning a layer
set $S$ destroys every path whose support meets $S$; the network's post-ablation
loss is the minimum loss among survivors, and the *pruning cost* of $S$ is the
increase of that minimum. This is literally a sum in the tropical semiring
$(\mathbb{Q} \cup \{\infty\}, \min, +)$, taken over the surviving paths.

Our results are of four kinds.

1. **Representation.** A cost profile $c$ on subsets of layers is realizable by
   some path system if and only if $c(\emptyset)=0$ and $c$ is monotone. Hence
   monotonicity is the *only* universal constraint: no additivity, sub-additivity
   or bounded-blow-up law holds, and there exist systems in which two layers cost
   exactly zero alone and any prescribed $r>0$ jointly. The pre-registered
   "ablation costs are essentially additive" hypothesis is refuted at the level
   of the entire model class, not merely by one counterexample.

2. **Interaction calculus.** The Möbius transform on the subset lattice inverts
   the cost profile: $c(S) = \sum_{A \subseteq S} m(A)$. Order-1 coefficients are
   solo costs, order-2 coefficients *are* pairwise epistasis, and order 3 yields a
   compounding law expressing a triple's excess as the sum of its three pairwise
   epistases plus one genuine third-order term.

3. **Combinatorial characterization.** Pruning $S$ costs more than $\varepsilon$
   if and only if $S$ is a transversal (hitting set) of the family of
   $\varepsilon$-near-optimal paths. Consequently the *epistasis order* — the least
   number of layers whose joint ablation is expensive — is the transversal number
   of the near-optimal path hypergraph, it equals $2$ exactly when all singletons
   are cheap and some pair is not, and it can be made equal to any prescribed $k$.
   A pair that is individually free but jointly costly is *co-adapted*: every
   near-optimal backup for one member routes through the other.

4. **A structural additivity criterion.** Epistasis vanishes exactly when backup
   routes can be merged. Under a two-path exchange axiom (*mergeability*),
   $\mathrm{cost}(S \cup T) \le \max(\mathrm{cost}(S), \mathrm{cost}(T))$ and, by
   induction, the cost of any set is bounded by its largest solo cost — so
   per-layer budgeting is provably safe. Conversely a single super-additive pair
   exhibits an explicit merge obstruction: two optimal backups whose common part
   is strictly worse than both.

Finally we construct an explicit $20$-path system on $24$ layers whose cost
profile reproduces the measured ablation table exactly, and derive the
experiment's verdicts as theorems: the tail pair is $7\times$ super-additive; three
of six arms are super-additive (refuting additivity); the tail triple compounds
at $4\times$ and is the costliest arm; the tail pair is co-adapted; the epistasis
order of the tail subsystem is exactly $2$; and the triple's third-order
interaction is $-0.37$ points, showing the tail unit saturates at width two.

**Keywords:** tropical semiring, min-plus algebra, layer ablation, epistasis,
Möbius inversion, hypergraph transversal, network pruning, co-adaptation.

---

## 1. Introduction

### 1.1 The measurement

Consider a trained transformer of depth $L = 24$. Impose a sparsification budget
of $k = 16$ retained components per layer, apply it to one layer at a time, and
measure held-out accuracy loss with no retraining. The resulting *solo cost
profile* assigns to each layer $i$ a number $c(\{i\}) \ge 0$.

Now apply the same budget to several layers simultaneously and compare the joint
cost to the sum of the members' solo costs. Six arms were measured. Costs are
reported in accuracy points; we will work internally in hundredths of a point so
that all quantities are integers.

| arm | layers | joint cost $c$ | $\sum$ solo | ratio | class |
|---|---|---|---|---|---|
| tail | $\{22,23\}$ | $0.42$ | $0.06$ | $7.0$ | **super-additive** |
| bulk | $\{12,15\}$ | $0.60$ | $0.79$ | $0.76$ | sub-additive |
| front | $\{0,1\}$ | $0.25$ | $0.25$ | $1.00$ | additive |
| mid | $\{10,11\}$ | $0.40$ | $0.28$ | $1.43$ | super-additive |
| cross | $\{12,22\}$ | $0.59$ | $0.60$ | $0.98$ | sub-additive |
| tail triple | $\{21,22,23\}$ | $0.76$ | $0.19$ | $4.0$ | **super-additive** |

The underlying solo profile is
$$c(\{0\})=0.13,\quad c(\{1\})=0.12,\quad c(\{10\})=c(\{11\})=0.14,$$
$$c(\{12\})=0.57,\quad c(\{15\})=0.22,\quad c(\{21\})=0.13,\quad c(\{22\})=c(\{23\})=0.03.$$

Three pre-registered hypotheses were tested.

- **P1** — *the tail pair is simultaneously cheapest by solo sum and
  disproportionately costly jointly.* **Confirmed:** solo sum $0.06$, the smallest
  of any arm; ratio $7$, the largest of any arm.
- **P2** — *joint ablation costs are essentially additive.* **Refuted:** three of
  six arms are super-additive, two are sub-additive, one additive.
- **P3** — *the tail triple compounds.* **Confirmed:** ratio $4$, and it is the
  costliest arm measured.

### 1.2 The problem

A cost table is not an explanation. Two questions demand a mathematical answer.

**(Q1) What kind of object is a pruning-cost profile?** Which functions $c$ on
subsets of layers can arise at all? If some additivity law were forced by the
structure of deep networks, the tail measurement would be an anomaly to be
explained away; if no such law exists, the measurement is a generic feature and
the *right* question is which layer sets exhibit it.

**(Q2) What distinguishes the tail pair from the front pair?** Both consist of two
adjacent layers with small solo costs. One is additive, the other blows up by
$7\times$. There must be a structural invariant separating them.

### 1.3 The answer in one paragraph

Model the network as a family of *computation paths*. Pruning destroys paths and
the network falls back on the best survivor; the post-pruning loss is therefore a
**minimum**, i.e. a tropical sum, and the cost is the increase of that minimum.
In this model (Q1) has the sharpest possible answer: *every* monotone normalized
profile is realizable, so monotonicity is the only law (Theorem 4.3), and
super-additivity is unbounded (Theorem 4.5). And (Q2) has a purely combinatorial
answer: an ablation is expensive precisely when it is a hitting set of the family
of near-optimal paths (Theorem 6.2), so the tail pair is a *minimal size-two
transversal* while the front pair is a union of two independent size-one
transversals. Additivity is recovered exactly under a two-path exchange axiom
(Theorem 7.2), and the tail pair furnishes an explicit obstruction to it (Theorem
7.6).

### 1.4 Why tropical

The min-plus semiring $\mathbb{T} = (\mathbb{Q} \cup \{\infty\}, \oplus, \odot)$,
with $x \oplus y = \min(x,y)$ and $x \odot y = x + y$, is the natural arithmetic
of "best route" problems: shortest paths, dynamic programming, scheduling,
piecewise-linear optimization. Our claim is that ablation cost belongs to this
family. The post-ablation loss is $\bigoplus_{i \text{ survives}} \mathrm{loss}(i)$
— an honest tropical sum; this is Proposition 3.7 below. The persistent
intuition that "damage adds up" is the intuition of the *wrong semiring*: it is
$\odot$-thinking applied to a $\oplus$-quantity. Deleting two terms from a $+$-sum
removes exactly two contributions; deleting two terms from a $\min$ can remove
nothing or everything, depending entirely on what lies beneath.

---

## 2. Related phenomena and terminology

The word *epistasis* is borrowed from genetics, where two loci each phenotypically
silent when knocked out singly can be jointly lethal — synthetic lethality. The
mathematics is identical: fitness is a best-available-pathway quantity, and a
knockout is expensive exactly when it hits every viable pathway.

The Möbius transform on a Boolean lattice appears in cooperative game theory as
the *Harsanyi dividend* decomposition of a characteristic function, and in
Boolean function analysis as the coefficients of the multilinear extension.
Nothing in Sections 5–7 requires the reader to know these connections, but they
explain why the second-order coefficient deserves the name *interaction*.

Hypergraph transversals (hitting sets, vertex covers) are the combinatorial
objects of Section 6. We use only the definition of a transversal and the
transversal number; no covering-number machinery is required.

---

## 3. The tropical model

### 3.1 Path systems

**Definition 3.1 (Prunable net).** Fix $n \in \mathbb{N}$, the number of layers,
indexed by $\{0,\dots,n-1\}$. A *prunable net* $N$ on $n$ layers consists of:

- a finite index set $\iota$ of **paths**;
- a **support** map $\mathrm{supp} : \iota \to \mathcal{P}(\{0,\dots,n-1\})$,
  assigning to each path the set of layers whose fine structure it depends on;
- a **loss** map $\mathrm{loss} : \iota \to \mathbb{Q}$;
- a distinguished **fallback path** $\mathrm{base} \in \iota$ with
  $\mathrm{supp}(\mathrm{base}) = \emptyset$.

The fallback path encodes the fact that even a fully pruned network computes
*something*; it guarantees that pruning never leaves an empty survivor set, so all
minima below are over nonempty finite sets and are well-defined.

**Definition 3.2 (Survivors).** For a layer set $S$, the survivors are
$$\mathrm{Surv}(S) = \{\, i \in \iota \;:\; \mathrm{supp}(i) \cap S = \emptyset \,\}.$$

Immediately: $\mathrm{base} \in \mathrm{Surv}(S)$ for all $S$, so
$\mathrm{Surv}(S) \ne \emptyset$; and $S \subseteq T$ implies $\mathrm{Surv}(T)
\subseteq \mathrm{Surv}(S)$ (antitonicity).

**Definition 3.3 (Net loss and pruning cost).**
$$\mathrm{netLoss}(S) = \min_{i \in \mathrm{Surv}(S)} \mathrm{loss}(i), \qquad
\mathrm{cost}(S) = \mathrm{netLoss}(S) - \mathrm{netLoss}(\emptyset).$$

**Definition 3.4 (Epistasis).** For layer sets $S, T$,
$$\mathrm{epi}(S,T) = \mathrm{cost}(S \cup T) - \mathrm{cost}(S) - \mathrm{cost}(T).$$
The pair is **super-additive** if $\mathrm{epi}(S,T) > 0$ and **sub-additive** if
$\mathrm{epi}(S,T) < 0$.

Note $\mathrm{epi}$ is symmetric and $\mathrm{epi}(S,\emptyset) = 0$.

### 3.2 Elementary properties

**Proposition 3.5 (Basic calculus).** For all layer sets $S \subseteq T$:

1. *(Upper bound)* If $\mathrm{supp}(i) \cap S = \emptyset$ then
   $\mathrm{netLoss}(S) \le \mathrm{loss}(i)$.
2. *(Lower bound)* If $q \le \mathrm{loss}(i)$ for every survivor $i$ of $S$, then
   $q \le \mathrm{netLoss}(S)$.
3. *(Attainment)* Some survivor $i$ of $S$ has $\mathrm{loss}(i) =
   \mathrm{netLoss}(S)$.
4. *(Monotonicity)* $\mathrm{netLoss}(S) \le \mathrm{netLoss}(T)$ and
   $\mathrm{cost}(S) \le \mathrm{cost}(T)$.
5. *(Normalization and positivity)* $\mathrm{cost}(\emptyset) = 0$ and
   $\mathrm{cost}(S) \ge 0$.

*Proof sketch.* (1)–(3) are the defining properties of a minimum over a nonempty
finite set. (4) follows from antitonicity of survivors: every survivor of $T$ is a
survivor of $S$, so the minimum over the smaller family is at least as large. (5)
is (4) with $S = \emptyset$. $\square$

**Corollary 3.6 (Witness rule).** If $i_0$ survives $S$ and $\mathrm{loss}(i_0) \le
\mathrm{loss}(i)$ for every survivor $i$ of $S$, then $\mathrm{netLoss}(S) =
\mathrm{loss}(i_0)$.

This rule is what makes concrete cost profiles computable: one exhibits an optimal
survivor and checks dominance over the (finitely many) other survivors.

### 3.3 The tropical identity

Let $\mathrm{trop} : \mathbb{Q} \cup \{\infty\} \to \mathbb{T}$ be the tropical
embedding and $\mathrm{untrop}$ its inverse, so that $\oplus = \min$.

**Proposition 3.7 (Net loss is a tropical sum).** For every layer set $S$,
$$\mathrm{untrop}\!\left( \bigoplus_{i \in \mathrm{Surv}(S)} \mathrm{trop}\big(\mathrm{loss}(i)\big) \right) \;=\; \mathrm{netLoss}(S).$$

*Proof sketch.* Tropical summation over a finite index set unfolds to the infimum
of the summands. One inequality uses the attained optimal survivor from
Proposition 3.5(3); the other uses Proposition 3.5(1) termwise. $\square$

Proposition 3.7 is the licence for the word "tropical" throughout: the quantity
whose increase we call cost is a min-plus sum over a *variable* index set, and
pruning is the operation of deleting summands.

---

## 4. Representation: which cost profiles exist?

This section answers (Q1) and refutes P2 at the level of the model class.

### 4.1 The canonical realization

**Definition 4.1.** Given any $c : \mathcal{P}(\{0,\dots,n-1\}) \to \mathbb{Q}$,
the *canonical net* $N_c$ has:

- paths indexed by subsets $A$ of layers,
- $\mathrm{supp}(A) = A$,
- $\mathrm{loss}(A) = c(A^{c})$,
- fallback path $A = \emptyset$.

The intuition: the path indexed by $A$ is the route that "protects" exactly the
layers in $A$, and it delivers the performance you would have after pruning
everything else.

**Lemma 4.2.** If $c$ is monotone ($S \subseteq T \Rightarrow c(S) \le c(T)$) then
$\mathrm{netLoss}_{N_c}(S) = c(S)$ for every $S$.

*Proof sketch.* For $\le$: the path indexed by $A = S^{c}$ has support disjoint
from $S$ and loss $c(S^{cc}) = c(S)$, so it is a survivor with loss exactly
$c(S)$. For $\ge$: if path $A$ survives $S$, then $A \cap S = \emptyset$, so $S
\subseteq A^{c}$, and monotonicity gives $c(S) \le c(A^{c}) = \mathrm{loss}(A)$.
Hence $c(S)$ is a lower bound for all survivors. $\square$

**Theorem 4.3 (Representation).** A function $c$ on subsets of $\{0,\dots,n-1\}$ is
the pruning-cost profile of some prunable net if and only if
$$c(\emptyset) = 0 \quad\text{and}\quad \big(S \subseteq T \Rightarrow c(S) \le c(T)\big).$$

*Proof sketch.* Necessity is Proposition 3.5(4)–(5). Sufficiency: by Lemma 4.2,
$\mathrm{netLoss}_{N_c}(S) = c(S)$ and $\mathrm{netLoss}_{N_c}(\emptyset) =
c(\emptyset) = 0$, so $\mathrm{cost}_{N_c}(S) = c(S)$. $\square$

### 4.2 Consequences: no additivity law of any kind

**Definition 4.4 (Pair profile).** For distinct layers $a,b$ and $r > 0$, let
$$c_{a,b,r}(S) = \begin{cases} r & \text{if } a \in S \text{ and } b \in S,\\ 0 & \text{otherwise.}\end{cases}$$

This is manifestly monotone and vanishes at $\emptyset$.

**Theorem 4.5 (Unbounded pure epistasis).** For any two distinct layers $a \ne b$
and any $r > 0$ there is a prunable net with
$$\mathrm{cost}(\{a\}) = 0, \qquad \mathrm{cost}(\{b\}) = 0, \qquad \mathrm{cost}(\{a,b\}) = r,$$
hence $\mathrm{epi}(\{a\},\{b\}) = r > 0$ and the pair is super-additive of
unbounded ratio.

*Proof sketch.* Apply Theorem 4.3 to $c_{a,b,r}$. $\square$

The observed factor of $7$ is therefore not an extreme value of a bounded
statistic; the statistic is unbounded, and indeed the ratio is undefined
(infinite) in the extremal profile.

**Theorem 4.6 (Sub-additivity is equally realizable).** The threshold profile
$c(S) = 1$ if $S \ne \emptyset$, $c(\emptyset)=0$, is monotone; the resulting net
has $\mathrm{cost}(\{a\}) = \mathrm{cost}(\{b\}) = \mathrm{cost}(\{a,b\}) = 1$, so
$\mathrm{epi}(\{a\},\{b\}) = -1$.

**Theorem 4.7 (Zero-epistasis null model).** Let $\varphi : \{0,\dots,n-1\} \to
\mathbb{Q}_{\ge 0}$ and let $c_\varphi(S) = \sum_{i \in S}\varphi(i)$ be the
*modular* profile. Then for disjoint $S, T$,
$$\mathrm{epi}(S,T) = 0.$$

*Proof sketch.* $c_\varphi$ is monotone and normalized, so Theorem 4.3 realizes it;
additivity of the sum over disjoint unions gives $c_\varphi(S \cup T) =
c_\varphi(S) + c_\varphi(T)$. $\square$

**Interpretation.** Theorems 4.5–4.7 together show that super-, sub- and exact
additivity all occur inside one model class, and Theorem 4.7 identifies exactly
when additivity holds: *epistasis is precisely the failure of the loss landscape
to be modular*. P2 is not "usually false"; it is false unless a strong structural
condition holds, and the empirical content of the NET-60 measurement is the
identification of which layer sets violate modularity.

---

## 5. The interaction calculus

Epistasis is the second term of a complete hierarchy. This section makes that
precise and derives the law governing triples.

**Definition 5.1 (Möbius / pure-interaction coefficient).** For a cost profile $c$
and a layer set $A$,
$$m_c(A) = \sum_{B \subseteq A} (-1)^{|A \setminus B|} c(B).$$

**Lemma 5.2 (Shift identity).** For $x \notin A$,
$$m_c(A \cup \{x\}) = m_{c^{(x)}}(A) - m_c(A), \qquad \text{where } c^{(x)}(B) := c(B \cup \{x\}).$$

*Proof sketch.* Split the power set of $A \cup \{x\}$ into subsets containing $x$
and subsets not containing $x$. For $B \subseteq A$: $(A \cup \{x\}) \setminus B$
has cardinality $|A \setminus B| + 1$, contributing the sign flip that produces
$-m_c(A)$; while $(A \cup \{x\}) \setminus (B \cup \{x\}) = A \setminus B$,
contributing $m_{c^{(x)}}(A)$ verbatim. $\square$

**Theorem 5.3 (Möbius inversion for pruning costs).** For every layer set $S$,
$$c(S) = \sum_{A \subseteq S} m_c(A).$$

*Proof sketch.* Induction on $S$, with the profile $c$ generalized. Base case
$S=\emptyset$: both sides equal $c(\emptyset)$. Inductive step for $S \cup \{x\}$
with $x \notin S$: split $\mathcal{P}(S \cup \{x\})$ into $\mathcal{P}(S)$ and its
$x$-shift, apply Lemma 5.2 to each term of the second half, and use the inductive
hypothesis twice — once for $c$ and once for $c^{(x)}$ — to obtain $c^{(x)}(S) =
c(S \cup \{x\})$. $\square$

**Corollary 5.4 (Low orders).** With $c(\emptyset)=0$:

- $m_c(\{i\}) = c(\{i\})$ — the solo cost;
- $m_c(\{a,b\}) = c(\{a,b\}) - c(\{a\}) - c(\{b\})$;
- $m_c(\{a,b,d\}) = c(\{a,b,d\}) - c(\{a,b\}) - c(\{a,d\}) - c(\{b,d\}) + c(\{a\}) + c(\{b\}) + c(\{d\})$.

**Theorem 5.5 (Epistasis is the second-order coefficient).** For distinct layers
$a \ne b$,
$$\mathrm{epi}(\{a\},\{b\}) = m_{\mathrm{cost}}(\{a,b\}).$$

This upgrades "joint minus sum of solos" from a diagnostic to a canonical
invariant: it is the unique degree-2 term in the unique decomposition of the cost
profile into pure interactions.

**Theorem 5.6 (Compounding law for triples).** For pairwise distinct $a,b,d$,
$$c(\{a,b,d\}) - \big(c(\{a\}) + c(\{b\}) + c(\{d\})\big)
= \mathrm{epi}(\{a\},\{b\}) + \mathrm{epi}(\{a\},\{d\}) + \mathrm{epi}(\{b\},\{d\}) + m_c(\{a,b,d\}).$$

*Proof sketch.* Expand all four Möbius coefficients via Corollary 5.4 and cancel;
equivalently, this is Theorem 5.3 at $S=\{a,b,d\}$ regrouped by order. $\square$

Theorem 5.6 is the correct replacement for the naive expectation that a triple's
excess is "the sum of its pairwise excesses". That expectation is exactly the
statement $m_c(\{a,b,d\}) = 0$, and Section 8 shows it fails for the measured
tail triple with a *negative* third-order term: the tail's co-adaptation is
genuinely pairwise and saturates.

---

## 6. Epistasis as a hitting-set number

This section answers (Q2). We fix a prunable net $N$ and a tolerance
$\varepsilon \ge 0$.

**Definition 6.1 (Near-optimal paths; transversal).** A path $i$ is
*$\varepsilon$-near-optimal* if $\mathrm{loss}(i) \le \mathrm{netLoss}(\emptyset) +
\varepsilon$. Write $\mathrm{Near}(\varepsilon)$ for the set of these paths. A
layer set $S$ is a *transversal* of $\mathrm{Near}(\varepsilon)$ if it meets the
support of every near-optimal path:
$$\forall\, i \in \mathrm{Near}(\varepsilon): \; \mathrm{supp}(i) \cap S \ne \emptyset.$$

Thus $\mathrm{Near}(\varepsilon)$ defines a hypergraph on the layer set, whose
edges are the supports of the near-optimal paths.

**Theorem 6.2 (Hitting-set characterization of cost).**
$$\mathrm{cost}(S) > \varepsilon \iff S \text{ is a transversal of } \mathrm{Near}(\varepsilon).$$

*Proof sketch.* ($\Rightarrow$, contrapositive) If some $\varepsilon$-near-optimal
path $i$ survives $S$, then $\mathrm{netLoss}(S) \le \mathrm{loss}(i) \le
\mathrm{netLoss}(\emptyset) + \varepsilon$, so $\mathrm{cost}(S) \le \varepsilon$.
($\Leftarrow$) Take the optimal survivor $i$ of $S$ (Proposition 3.5(3)). Since $S$
hits every near-optimal path and $i$ survives, $i$ is not near-optimal, so
$\mathrm{loss}(i) > \mathrm{netLoss}(\emptyset) + \varepsilon$; but
$\mathrm{netLoss}(S) = \mathrm{loss}(i)$, whence $\mathrm{cost}(S) >
\varepsilon$. $\square$

**Corollary 6.3 (Cheapness certificate).** If a path $i$ with $\mathrm{loss}(i) \le
\mathrm{netLoss}(\emptyset) + \varepsilon$ has support disjoint from $S$, then
$\mathrm{cost}(S) \le \varepsilon$. Exhibiting one surviving near-optimal path
certifies affordability.

**Definition 6.4 (Epistasis order).**
$$\mathrm{epiOrder}(\varepsilon) = \min\{\, |S| \;:\; \mathrm{cost}(S) > \varepsilon \,\}$$
(with the convention that the minimum of an empty set of sizes is $0$). By
Theorem 6.2 this is exactly the *transversal number* of the hypergraph
$\mathrm{Near}(\varepsilon)$.

**Proposition 6.5 (Below the order, everything is cheap; the order is attained).**
If $|S| < \mathrm{epiOrder}(\varepsilon)$ then $\mathrm{cost}(S) \le \varepsilon$.
If some set is expensive, then some set of cardinality exactly
$\mathrm{epiOrder}(\varepsilon)$ is expensive.

*Proof sketch.* Both are properties of an infimum over a nonempty set of naturals:
minimality gives the first, well-ordering the second. $\square$

**Theorem 6.6 (The order-two criterion).** Suppose $\varepsilon \ge 0$, every single
layer satisfies $\mathrm{cost}(\{i\}) \le \varepsilon$, and some pair satisfies
$\mathrm{cost}(\{a,b\}) > \varepsilon$. Then $\mathrm{epiOrder}(\varepsilon) = 2$.

*Proof sketch.* The pair witnesses $\mathrm{epiOrder} \le 2$. For the lower bound,
suppose an expensive set of cardinality $<2$ existed. Cardinality $0$ gives
$\mathrm{cost}(\emptyset) = 0 > \varepsilon \ge 0$, absurd; cardinality $1$
contradicts the singleton hypothesis. $\square$

This is the invariant separating the tail pair from the front pair. Both are pairs
of layers with small solo costs, but:

- the **tail pair** is a *minimal* size-two transversal: no single layer hits every
  near-optimal path, but $\{22,23\}$ does;
- the **front pair** is a *union of two independent size-one transversals* at the
  relevant tolerance, each covering its own family of near-optimal paths, and
  their costs therefore add.

**Theorem 6.7 (Co-adaptation).** Suppose $\mathrm{cost}(\{a\}) \le \varepsilon$,
$\mathrm{cost}(\{b\}) \le \varepsilon$, and $\mathrm{cost}(\{a,b\}) > \varepsilon$.
Then there exist $\varepsilon$-near-optimal paths $p$ and $q$ with
$$a \notin \mathrm{supp}(p), \quad b \in \mathrm{supp}(p), \qquad b \notin \mathrm{supp}(q), \quad a \in \mathrm{supp}(q).$$

*Proof sketch.* Let $p$ realize $\mathrm{netLoss}(\{a\})$. Then $p$ avoids $a$ and,
because the solo cost of $a$ is at most $\varepsilon$, $p$ is near-optimal. By
Theorem 6.2 the pair $\{a,b\}$ hits $p$; since $p$ avoids $a$, it must contain
$b$. Swap roles for $q$. $\square$

**Corollary 6.8 (Pure case).** If $\mathrm{cost}(\{a\}) = \mathrm{cost}(\{b\}) = 0$
and $\mathrm{cost}(\{a,b\}) > 0$, then the paths $p,q$ above are *exactly* optimal,
$\mathrm{loss}(p) = \mathrm{loss}(q) = \mathrm{netLoss}(\emptyset)$.

This is the formal meaning of "co-adapted during pretraining": the only optimal
backup for either layer routes through the other, and nothing else backs either
of them up. The two layers do not have separate roles that happen to interact;
they have one shared role, implemented redundantly across the pair.

**Theorem 6.9 (Every order is realizable).** Let $K$ be a nonempty set of $k$
layers and $r > 0$. The *block profile* $c_K(S) = r$ if $K \subseteq S$, else $0$,
is monotone and normalized; the resulting net satisfies
$$\mathrm{epiOrder}(0) = |K| = k.$$

*Proof sketch.* Realize $c_K$ by Theorem 4.3. Any expensive set must contain $K$,
so has cardinality $\ge k$; and $K$ itself is expensive. $\square$

Co-adapted units of any width therefore exist in the model. The empirical
question raised — whether trained networks of larger depth exhibit *wider* tail
units, and whether the units are contiguous intervals of layers — is exactly the
question of which block profiles are realized in practice.

---

## 7. When additivity holds: the merge axiom

Theorem 4.3 says no additivity law is forced. So an additivity law must come from
structure. This section identifies exactly which structure, in the form of a local
two-path exchange property whose consequences are global.

**Definition 7.1 (Mergeability).** A prunable net is *mergeable* if for all paths
$p,q$ there exists a path $r$ with
$$\mathrm{supp}(r) \subseteq \mathrm{supp}(p) \cap \mathrm{supp}(q), \qquad \mathrm{loss}(r) \le \max\big(\mathrm{loss}(p), \mathrm{loss}(q)\big).$$

In words: any two backup routes admit a common refinement — a route depending only
on the layers *both* of them need, and no worse than the worse of the two. No
capability lives in the disagreement between two routes.

**Theorem 7.2 (Merge bound).** In a mergeable net, for all layer sets $S, T$,
$$\mathrm{cost}(S \cup T) \le \max\big(\mathrm{cost}(S), \mathrm{cost}(T)\big).$$

*Proof sketch.* Let $p$ realize $\mathrm{netLoss}(S)$ and $q$ realize
$\mathrm{netLoss}(T)$, and let $r$ be their merge. Since $\mathrm{supp}(r)
\subseteq \mathrm{supp}(p)$ and $p$ avoids $S$, $r$ avoids $S$; similarly $r$
avoids $T$; hence $r$ survives $S \cup T$. Therefore
$$\mathrm{netLoss}(S \cup T) \le \mathrm{loss}(r) \le \max(\mathrm{loss}(p),\mathrm{loss}(q)) = \max(\mathrm{netLoss}(S),\mathrm{netLoss}(T)),$$
and subtracting $\mathrm{netLoss}(\emptyset)$ from both sides gives the claim.
$\square$

**Corollary 7.3 (Sub-additivity).** In a mergeable net, $\mathrm{cost}(S \cup T)
\le \mathrm{cost}(S) + \mathrm{cost}(T)$, hence $\mathrm{epi}(S,T) \le 0$ for all
$S,T$: no super-additive pair exists anywhere.

*Proof sketch.* Combine Theorem 7.2 with non-negativity of cost (Proposition
3.5(5)): the maximum of two non-negative numbers is at most their sum. $\square$

**Corollary 7.4 (Per-layer budgeting is safe).** In a mergeable net, for every
nonempty layer set $S$,
$$\mathrm{cost}(S) \le \max_{i \in S} \mathrm{cost}(\{i\}).$$

*Proof sketch.* Induction on $|S|$. Singletons are trivial. For $S = \{a\} \cup
S'$, Theorem 7.2 bounds $\mathrm{cost}(S)$ by $\max(\mathrm{cost}(\{a\}),
\mathrm{cost}(S'))$ and the inductive hypothesis bounds the second term. $\square$

This is the practical payoff: a *local* two-path exchange property, checkable
pairwise, upgrades to a bound over the entire Boolean lattice of $2^{n}$ subsets
simultaneously. Mergeability is exactly the licence to do per-layer accounting.

**Theorem 7.5 (Super-additivity refutes mergeability).** If any pair $(S,T)$ has
$\mathrm{epi}(S,T) > 0$, the net is not mergeable.

**Theorem 7.6 (Explicit merge obstruction).** Suppose $\mathrm{epi}(S,T) > 0$. Then
there exist paths $p, q$ with $p$ surviving $S$, $q$ surviving $T$,
$\mathrm{loss}(p) = \mathrm{netLoss}(S)$, $\mathrm{loss}(q) = \mathrm{netLoss}(T)$,
and such that **every** path $r$ with $\mathrm{supp}(r) \subseteq \mathrm{supp}(p)
\cap \mathrm{supp}(q)$ satisfies
$$\mathrm{loss}(r) > \max\big(\mathrm{loss}(p), \mathrm{loss}(q)\big).$$

*Proof sketch.* Take $p, q$ optimal for $S$ and $T$. If some $r$ inside the
intersection of supports were no worse than both, then $r$ would survive $S \cup
T$ and the computation in Theorem 7.2 would give $\mathrm{epi}(S,T) \le 0$,
contradiction. $\square$

Theorem 7.6 converts the numerical statement "$0.42$ against $0.06$" into a
structural one: *the network holds a capability located precisely in the
disagreement between two backup routes*, and no route depending only on their
common layers can reproduce it. That is the mathematical content of the phrase
"the tail is one coordinated unit".

---

## 8. The measured system, exactly solved

We now construct a concrete prunable net on $24$ layers reproducing the measured
table exactly, so that the experiment's verdicts become theorems about a
transparent finite object. Costs are in hundredths of an accuracy point.

### 8.1 The construction

The net has $20$ paths. Each path is a *retention pattern*: the path indexed by a
target set $T_j$ survives exactly the prunings $S \subseteq T_j$, i.e. its support
is the complement $T_j^{c}$. Its loss $\ell_j$ is the cost recorded for that
retention pattern.

| $j$ | target $T_j$ | loss $\ell_j$ | role |
|---|---|---|---|
| $0$ | $\emptyset$ | $0$ | unpruned optimum |
| $1$ | $\{0\}$ | $13$ | solo layer $0$ |
| $2$ | $\{1\}$ | $12$ | solo layer $1$ |
| $3$ | $\{10\}$ | $14$ | solo layer $10$ |
| $4$ | $\{11\}$ | $14$ | solo layer $11$ |
| $5$ | $\{12\}$ | $57$ | solo layer $12$ |
| $6$ | $\{15\}$ | $22$ | solo layer $15$ |
| $7$ | $\{21\}$ | $13$ | solo layer $21$ |
| $8$ | $\{22\}$ | $3$ | solo layer $22$ |
| $9$ | $\{23\}$ | $3$ | solo layer $23$ |
| $10$ | $\{0,1\}$ | $25$ | front arm |
| $11$ | $\{10,11\}$ | $40$ | mid arm |
| $12$ | $\{12,15\}$ | $60$ | bulk arm |
| $13$ | $\{12,22\}$ | $59$ | cross arm |
| $14$ | $\{22,23\}$ | $42$ | tail arm |
| $15$ | $\{21,22,23\}$ | $76$ | tail triple |
| $16$ | $\{21,22\}$ | $45$ | tail sub-pair |
| $17$ | $\{21,23\}$ | $45$ | tail sub-pair |
| $18$ | all untouched layers | $20$ | irrelevant-layer route |
| $19$ | all layers | $10000$ | fallback |

Path $19$ has empty support and is the fallback of Definition 3.1. Path $18$
records that pruning any layer outside the nine measured ones is comparatively
cheap. The unpruned optimum is $\mathrm{netLoss}(\emptyset) = \ell_0 = 0$, so cost
equals net loss throughout.

Each entry of the profile is verified by the witness rule (Corollary 3.6): exhibit
the optimal surviving path and check dominance over the other survivors. For
instance, pruning $\{22,23\}$ kills paths $0$–$9$ except those retaining both
(none), and $10$–$13$, leaving $14$ (loss $42$), $15,16,17$ (losses $76,45,45$) and
$19$ — hence $\mathrm{cost}(\{22,23\}) = 42$, exactly the measured $0.42$ points.

### 8.2 The verdicts as theorems

**Theorem 8.1 (Solo profile).**
$$\mathrm{cost}(\{0\}) = 13,\; \mathrm{cost}(\{1\}) = 12,\; \mathrm{cost}(\{10\}) = \mathrm{cost}(\{11\}) = 14,$$
$$\mathrm{cost}(\{12\}) = 57,\; \mathrm{cost}(\{15\}) = 22,\; \mathrm{cost}(\{21\}) = 13,\; \mathrm{cost}(\{22\}) = \mathrm{cost}(\{23\}) = 3.$$

**Theorem 8.2 (Arm profile).**
$$\mathrm{cost}(\{0,1\}) = 25,\quad \mathrm{cost}(\{10,11\}) = 40,\quad \mathrm{cost}(\{12,15\}) = 60,$$
$$\mathrm{cost}(\{12,22\}) = 59,\quad \mathrm{cost}(\{22,23\}) = 42,\quad \mathrm{cost}(\{21,22,23\}) = 76,$$
$$\mathrm{cost}(\{21,22\}) = \mathrm{cost}(\{21,23\}) = 45.$$

**Theorem 8.3 (P1: the tail ratio is exactly seven).**
$$\mathrm{cost}(\{22,23\}) = 7 \cdot \big(\mathrm{cost}(\{22\}) + \mathrm{cost}(\{23\})\big),$$
and $\mathrm{epi}(\{22\},\{23\}) = 36$, i.e. $0.36$ points of pure second-order
interaction.

**Theorem 8.4 (P1, comparative half).** Among the five pair arms, the tail pair has
the strictly smallest solo sum,
$$3+3 \;<\; 13+12,\quad 14+14,\quad 57+22,\quad 57+3,$$
and the strictly largest joint-to-solo ratio. (The ratio comparison is stated by
cross-multiplication, $c_{\mathrm{arm}} \cdot (3+3) < 42 \cdot \sum_{\mathrm{arm}}
\mathrm{solo}$, so that no division is needed.)

**Theorem 8.5 (P2 refuted: all three regimes in one net).**
$$\mathrm{epi}(\{22\},\{23\}) = 36 > 0, \qquad \mathrm{epi}(\{10\},\{11\}) = 12 > 0, \qquad \mathrm{epi}(\{21\},\{22,23\}) = 21 > 0,$$
$$\mathrm{epi}(\{12\},\{15\}) = -19 < 0, \qquad \mathrm{epi}(\{12\},\{22\}) = -1 < 0, \qquad \mathrm{epi}(\{0\},\{1\}) = 0.$$

Three super-additive arms, two sub-additive, one exactly additive. Additivity is
not a law even locally within a single trained network.

**Theorem 8.6 (P3: the triple compounds and is costliest).**
$$\mathrm{cost}(\{21,22,23\}) = 4 \cdot \big(\mathrm{cost}(\{21\}) + \mathrm{cost}(\{22\}) + \mathrm{cost}(\{23\})\big) = 76,$$
and $76$ strictly exceeds each of $25, 40, 60, 59, 42$.

**Theorem 8.7 (Co-adaptation of the tail pair).** At tolerance $\varepsilon = 3$
(the common solo cost of the tail layers), the tail pair is a transversal of the
near-optimal path family. Concretely, there is a near-optimal path avoiding layer
$22$ but routing through layer $23$, and a near-optimal path avoiding $23$ but
routing through $22$.

*Proof sketch.* Immediate from Theorem 6.7, since $\mathrm{cost}(\{22\}) =
\mathrm{cost}(\{23\}) = 3 \le 3 < 42 = \mathrm{cost}(\{22,23\})$. $\square$

**Theorem 8.8 (Epistasis order of the measured profile).** Every single layer
satisfies $\mathrm{cost}(\{i\}) \le 57$, and $\mathrm{cost}(\{12,15\}) = 60 > 57$.
Hence $\mathrm{epiOrder}(57) = 2$.

**Theorem 8.9 (The tail subsystem has epistasis order two).** Consider the
$5$-path subsystem retaining $\emptyset, \{22\}, \{23\}$, all layers outside the
tail, and everything, with losses $0, 3, 3, 3, 42$. Then every single layer costs
at most $3$, while $\mathrm{cost}(\{22,23\}) = 42$, so $\mathrm{epiOrder}(3) = 2$:
the transversal number of the tail's near-optimal hypergraph is exactly $2$, and
budgets must be assigned to the pair, never to its members.

**Theorem 8.10 (The measured net is not mergeable).** Since
$\mathrm{epi}(\{22\},\{23\}) = 36 > 0$, Theorem 7.5 applies. Moreover Theorem 7.6
produces the explicit obstruction: the optimal backup avoiding layer $22$ (loss
$3$) and the optimal backup avoiding layer $23$ (loss $3$) admit no common
refinement — every route depending only on the layers both of them require costs
strictly more than $3$.

### 8.3 Third-order structure: the unit saturates at width two

**Theorem 8.11 (Third-order interaction of the tail triple).**
$$m_{\mathrm{cost}}(\{21,22,23\}) = 76 - 45 - 45 - 42 + 13 + 3 + 3 = -37,$$
i.e. $-0.37$ accuracy points.

**Theorem 8.12 (Exact decomposition of the measured triple).**
$$\underbrace{76}_{\text{measured}} = \underbrace{(13 + 3 + 3)}_{\text{solo} = 19} + \underbrace{(29 + 29 + 36)}_{\text{pairwise} = 94} + \underbrace{(-37)}_{\text{third order}}.$$

*Proof sketch.* Theorem 5.6 applied to $\{21,22,23\}$, with the pairwise
epistases $\mathrm{epi}(\{21\},\{22\}) = 45-13-3 = 29$, $\mathrm{epi}(\{21\},\{23\})
= 29$, $\mathrm{epi}(\{22\},\{23\}) = 36$, and Theorem 8.11. $\square$

**Interpretation.** The third-order term is *negative* and large in magnitude
relative to the solo sum. The three pairwise interactions over-count what a triple
ablation actually costs; the genuine order-3 term corrects them downwards. Hence
the tail's co-adaptation does not compound indefinitely as one absorbs more layers
into the block — it saturates. The observed $4\times$ compounding of the triple is
compatible with a *width-two* co-adapted core (layers $22, 23$) into which layer
$21$ is only partially recruited. This is a falsifiable prediction: in a deeper
model, if the co-adapted core widens to three, the corresponding third-order
Möbius coefficient should turn positive.

---

## 9. Algorithms

Three computations underlie everything above; all are elementary and we state
their complexity in terms of the number of paths $P$, the depth $L$, and the size
$s$ of the layer set queried.

**A. Tropical evaluation of a cost profile.** To evaluate $\mathrm{cost}(S)$, scan
the paths, keep those whose support misses $S$, and return the minimum loss less
the baseline. Cost: $O(P \cdot L)$ with bitmask supports, $O(P)$ with machine-word
masks. Verifying an entire ablation table of $A$ arms costs $O(A \cdot P)$.

**B. Möbius transform and interaction spectrum.** Given a cost profile on a block
$K$ of $k$ layers ($2^{k}$ values), the pure interactions $m(A)$ for all $A
\subseteq K$ are computed by the fast zeta/Möbius transform in $O(k \cdot 2^{k})$
time and $O(2^{k})$ space, by sweeping one coordinate at a time and replacing each
value at a set containing $x$ by its difference with the value at the set without
$x$. This is the same butterfly as the fast Walsh–Hadamard transform, with
subtraction in place of $\pm$ combination. For a block of size $3$ — a tail triple
— this is seven subtractions.

**C. Epistasis order by transversal search.** By Theorem 6.2, computing
$\mathrm{epiOrder}(\varepsilon)$ is computing the transversal number of the
hypergraph whose edges are the supports of $\varepsilon$-near-optimal paths.
Exhaustive search over subsets of size $1, 2, \ldots$ costs $O(\binom{L}{k} \cdot
P)$ to certify order $k$; for $k \le 2$ and $L = 24$ this is a few hundred
evaluations, entirely practical. The general transversal-number problem is
NP-hard, which is precisely why the order-two criterion (Theorem 6.6) — all
singletons cheap, one pair expensive — is valuable: it certifies the answer from
$O(L^{2})$ measurements without any search.

The methodological payoff is that a $2^{L}$ subset sweep, which is hopeless for
$L = 24$, is replaced by $O(L^{2})$ pair ablations plus a covering fit.

---

## 10. Discussion

### 10.1 What the model does and does not claim

The model is a *representation* result, not a mechanistic account of transformers.
It says: whatever the internal mechanism, if post-ablation performance is the best
achievable over surviving computational routes, then (i) the cost profile is an
arbitrary monotone function, (ii) super-additivity is a hitting-set phenomenon,
and (iii) additivity is equivalent to a merge property of the route family. It
does not claim that a specific set of twenty paths exists inside the measured
network; the twenty-path system of Section 8 is an exact realization of the
measured profile, in the sense guaranteed by Theorem 4.3, and its role is to make
the verdicts checkable statements about a finite transparent object.

### 10.2 Consistency with correlational markers

The causal signature identified here — the tail as a single non-mergeable unit —
matches four independently observed correlational markers of the same layers:
that the tail's structure is far from the tropical (piecewise-linear extreme)
regime characteristic of the bulk; that a crystallization-style loss is
concentrated there; that decision divergence under perturbation is largest there;
and that tail structure is the least portable across models. Under the present
model these are not four facts but one: a co-adapted unit is a minimal transversal
of the near-optimal route family, and every one of those markers is a symptom of
having no single-layer backup.

### 10.3 The prescription

The operational conclusion is exact and follows from Corollary 7.4 read
contrapositively. Per-layer budget accounting is valid *precisely* under
mergeability; the tail pair certifies that mergeability fails; therefore
per-layer accounting is invalid for the tail. **Treat the last two layers as one
unit for bits and budgets, and never differentiate between its members.** For the
bulk and cross arms, which are sub-additive, per-layer accounting is conservative
and safe.

### 10.4 Limitations

The measurement is one model at one depth, one context length, one granularity
$k = 16$, and five chosen pairs out of $\binom{24}{2} = 276$; the arms were
pre-selected, not swept. The solo baseline is inherited from a prior profile of
the same model under the same budget. The theory is exact but the empirical scope
is narrow, and the central conjecture — that co-adapted units are contiguous
blocks whose width grows with depth — is untested.

---

## 11. Future directions

The formal development establishes: pruning cost is the increase of a tropical
(min-plus) minimum over surviving computation paths; the realizable cost profiles
are *exactly* the monotone normalized ones, so no additivity law exists and the
super-additivity ratio is unbounded, refuting the additivity horn at the level of
the whole model class; costing more than $\varepsilon$ is *equivalent* to being a
transversal of the $\varepsilon$-near-optimal path family, so the order at which
epistasis appears is a hypergraph transversal number, which can be made any
prescribed value; epistasis vanishes exactly when backups can be merged, the merge
axiom forcing $\mathrm{cost}(S \cup T) \le \max(\mathrm{cost}(S),
\mathrm{cost}(T))$, while a single super-additive pair produces an explicit merge
obstruction; and the measured ablation table is reproduced exactly by an explicit
twenty-path net whose verdicts are theorems.

The following conjectures are the next cycle.

### 11.1 Transversal-number depth law

**Conjecture.** For a depth-$L$ transformer the epistasis order at a fixed
tolerance grows like the width of the *deepest* co-adapted block, and this block
is an interval of layers: there is a partition of $\{0,\dots,L-1\}$ into intervals
such that the near-optimal path hypergraph is the union of the "all-of-a-block"
hyperedges of the partition.

The key insight is that a co-adapted unit is not a statistical cluster but a
*minimal transversal* of the near-optimal path family, and Theorem 6.9 shows
minimal transversals of any size are tropically realizable — the empirical
question is only whether the realized ones are contiguous.

**Why now?** The hitting-set characterization turns a costly ablation sweep into a
hypergraph-covering question that can be tested with $O(L^{2})$ pair ablations
plus a single fit, instead of $2^{L}$ subsets.

### 11.2 Merge-axiom certification of prunability

**Conjecture.** A layer-wise pruning budget is safe (per-layer accounting is
valid) **iff** the induced path system satisfies the merge axiom up to an additive
slack $\delta$, and the total super-additivity of a network is bounded by
(number of layers) $\cdot\, \delta$.

The key insight is that the per-layer budgeting bound (Corollary 7.4) upgrades a
*local* two-path exchange property into a *global* bound on every subset at once,
so a finite certificate implies a statement over the whole Boolean lattice.

**Why now?** The $\delta$-relaxed merge axiom is checkable from pairwise data
already collected, and would give the first certificate of safe per-layer
budgeting rather than a heuristic.

### 11.3 Further programme

Replication at larger scale (a $1.5$B-parameter model) to test whether tail units
widen with depth; a search for deeper-tail units on larger models guided by the
transversal criterion; a hybrid criterion combining structural probes with
recency-based importance; and evaluation on domain-jump corpora, where the
near-optimal path family — and hence the transversal structure — may reorganize.

---

## 12. Conclusion

Ablation cost is a tropical quantity: the increase of a minimum over surviving
computation routes. Once that is recognized, the empirical surprise dissolves into
three theorems. Monotonicity is the only universal constraint on cost profiles, so
additivity was never guaranteed. An ablation is expensive exactly when it hits
every near-optimal route, so the "order at which epistasis lives" is a hypergraph
transversal number. And additivity holds exactly when backup routes can be merged,
so a super-additive pair is a certificate that the network stores a capability in
the disagreement between two routes.

The last two layers of the measured network are a minimal size-two transversal of
their own near-optimal route family: each individually free because the other
covers, and jointly worth seven times their combined solo price. They are not two
components. They are one.
