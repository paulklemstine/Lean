# Minimal Obstructions to Total Rainbow Forests: An Edge-Deletion Analysis

## Abstract

We study obstructions to the existence of large *total rainbow forests* in edge-colored graphs, framed through matroid intersection. A total rainbow forest is a set of edges that is simultaneously a forest (independent in the graphic matroid) and rainbow (independent in the color partition matroid); by Edmonds' Matroid Intersection Theorem, the maximum size of such a set equals the minimum over all edge subsets $A$ of the objective $\mathrm{obj}(A) = r_1(A) + r_2(A^c)$, where $r_1, r_2$ are the two rank functions and $A^c = E \setminus A$. We say a graph is an *obstruction* at target $t$ if $\mathrm{obj}(A) < t$ for some $A$. Motivated by the conjecture that a *minimal* obstruction fails the corresponding inequality for exactly one subset, we analyze minimality under edge deletion and prove a sharp negative result: **edge-minimal obstructions do not exist for monotone matroid ranks.** The mechanism is a monotonicity principle — the Edmonds objective can only decrease under edge deletion — which makes RFI-failure closed under deletion. We prove (i) the weak-duality half of Edmonds' theorem (the Rainbow Forest Inequality), (ii) deletion monotonicity of the objective, (iii) that a single satisfied deletion forces the inequality for the whole graph, and (iv) the resulting non-existence of edge-minimal obstructions. We confirm the hypotheses are non-vacuous with a concrete two-edge obstruction, and we contrast the negative deletion result with the positive lattice structure of failing certificates for a fixed obstruction. All results hold for arbitrary monotone integer rank functions on a finite ground set, hence apply well beyond the graphic/partition special case.

**Keywords:** matroid intersection, rainbow forest, Edmonds' theorem, weak duality, submodularity, edge deletion, minimal obstruction, graphic matroid, partition matroid.

---

## 1. Introduction

Let $G$ be a finite graph whose edge set $E = E(G)$ has been assigned colors. Two independence structures live on the same ground set $E$:

- The **graphic (cycle) matroid** $M_1$, whose independent sets are the *forests* of $G$ (acyclic edge sets), with rank function $r_1$. For $A \subseteq E$, $r_1(A)$ is the maximum size of a forest contained in $A$; equivalently $r_1(A) = |V| - c(A)$ where $c(A)$ counts connected components of the subgraph $(V,A)$.
- The **partition matroid** $M_2$ induced by the coloring, whose independent sets are the *rainbow* edge sets (at most one edge per color), with rank function $r_2$. For $A \subseteq E$, $r_2(A)$ is the number of distinct colors appearing among the edges of $A$.

A **total rainbow forest** is a common independent set of $M_1$ and $M_2$: a set of edges that is both a forest and rainbow. Total rainbow forests interpolate two classical themes — spanning forests and rainbow (properly multicolored) substructures — and appear across scheduling, network design, and combinatorial optimization, where colors model categories, time slots, frequencies, or ownership, and the forest condition models absence of redundancy or conflict.

The size of the largest total rainbow forest is governed by **Edmonds' Matroid Intersection Theorem**. Define the **Edmonds intersection objective**

$$\mathrm{obj}(A) \;=\; r_1(A) + r_2(A^c), \qquad A^c = E \setminus A.$$

Then

$$\max\{ |I| : I \text{ a total rainbow forest} \} \;=\; \min_{A \subseteq E} \mathrm{obj}(A). \tag{Edmonds}$$

We say $G$ satisfies the **Rainbow Forest Inequality (RFI)** at target $t \in \mathbb{Z}$ if

$$t \le \mathrm{obj}(A) \quad \text{for all } A \subseteq E,$$

which by (Edmonds) is equivalent to the existence of a total rainbow forest of size $t$. When RFI fails, $G$ is an **obstruction**: some subset $A$ with $\mathrm{obj}(A) < t$ certifies that no rainbow forest of size $t$ exists.

### The conjecture and our contribution

The guiding conjecture reads:

> *For a minimal obstruction to total rainbow forests, there is a unique subset $A$ with $\mathrm{obj}(A) < t$, and the failure is strict for no other subset.*

The phrase "minimal obstruction" invites a concrete interpretation: $G$ is an **edge-minimal obstruction** if RFI fails for $G$ but holds for every single-edge deletion $G - e$. This is the natural analogue of critical/minimal objects throughout structural graph theory.

Our central finding is that this interpretation is **vacuous for matroids**: no edge-minimal obstruction exists. We isolate the root cause — a monotonicity principle for the Edmonds objective under deletion — and derive from it a short chain of results. We then explain what genuinely survives of the conjecture: for a *fixed* obstruction, the failing subsets form a lattice with a unique minimal and maximal certificate. All statements are proved for arbitrary **monotone** integer-valued rank functions $r_1, r_2$ on a finite ground set, so they apply to any pair of matroids, not merely the graphic/partition pair.

The results here concern *weak duality* (the $\le$ direction of Edmonds' theorem), which suffices for the entire deletion analysis; the strong direction is discussed as future work.

---

## 2. Setting and definitions

Throughout, fix a finite ground set $\alpha$ (thought of as $E(G)$), with subsets ranging over the Boolean lattice $2^\alpha$. Complementation $A^c = E \setminus A$ is taken relative to the full ground set $E = \alpha$. We work with two integer-valued rank functions $r_1, r_2 : 2^\alpha \to \mathbb{Z}$.

**Definition 2.1 (Objective).** The *Edmonds intersection objective* is
$$\mathrm{obj}(A) = r_1(A) + r_2(A^c).$$

**Definition 2.2 (Rainbow Forest Inequality).** For a target $t \in \mathbb{Z}$, RFI at $t$ is the predicate
$$\mathrm{RFI}(t) \;:\equiv\; \forall A \subseteq E,\; t \le \mathrm{obj}(A).$$

**Definition 2.3 (Monotone rank).** A rank function $r$ is *monotone* if $X \subseteq Y \implies r(X) \le r(Y)$. Every matroid rank function is monotone (and submodular), so all standing hypotheses below are satisfied by genuine matroids.

**Definition 2.4 (Common independent set).** A set $I \subseteq E$ is a *common independent set* of $r_1, r_2$ if every subset has full rank in both matroids:
$$\forall X \subseteq I,\quad r_1(X) = |X| \ \text{ and } \ r_2(X) = |X|.$$
This downward-closed formulation captures exactly a total rainbow forest together with the hereditary independence that both matroids enjoy.

**Definition 2.5 (Deletion objective and DeletionRFI).** For an edge $e$, the deletion $G - e$ lives on $E \setminus \{e\}$. Its objective at a subset $A \subseteq E \setminus \{e\}$ is $r_1(A) + r_2\big((E \setminus \{e\}) \setminus A\big)$ (restriction rank agrees with ambient rank on subsets avoiding $e$). We define
$$\mathrm{DeletionRFI}(t, e) \;:\equiv\; \forall A \subseteq E \setminus \{e\},\; t \le r_1(A) + r_2\big((E \setminus \{e\}) \setminus A\big).$$

**Definition 2.6 (Obstruction; edge-minimal obstruction).** $G$ is an *obstruction at $t$* if $\neg \mathrm{RFI}(t)$, i.e. $\exists A,\ \mathrm{obj}(A) < t$. It is an *edge-minimal obstruction* if additionally $\mathrm{DeletionRFI}(t, e)$ holds for every edge $e$.

---

## 3. The Rainbow Forest Inequality (weak duality)

**Theorem 3.1 (Rainbow Forest Inequality).** *Let $r_1, r_2$ be monotone. If $I$ is a common independent set, then for every $A \subseteq E$,*
$$|I| \le \mathrm{obj}(A) = r_1(A) + r_2(A^c).$$

*Proof.* Partition $I$ by $A$:
$$|I| = |I \cap A| + |I \setminus A|. \tag{1}$$
Since $I \cap A \subseteq I$, common independence gives $r_1(I \cap A) = |I \cap A|$; since $I \cap A \subseteq A$ and $r_1$ is monotone,
$$|I \cap A| = r_1(I \cap A) \le r_1(A). \tag{2}$$
Similarly $I \setminus A \subseteq I$ gives $r_2(I \setminus A) = |I \setminus A|$; and $I \setminus A \subseteq A^c$ with $r_2$ monotone yields
$$|I \setminus A| = r_2(I \setminus A) \le r_2(A^c). \tag{3}$$
Adding (2) and (3) and using (1) gives $|I| \le r_1(A) + r_2(A^c) = \mathrm{obj}(A)$. $\qquad\blacksquare$

Theorem 3.1 is the weak-duality half of Edmonds' theorem specialized to the graphic/partition pair; the proof uses only monotonicity and the additive split of cardinality, so it holds verbatim for any two monotone ranks.

**Corollary 3.2 (RFI from a witness).** *If there is a common independent set $I$ with $|I| = t$, then $\mathrm{RFI}(t)$ holds.*

*Proof.* For any $A$, Theorem 3.1 gives $t = |I| \le \mathrm{obj}(A)$. $\qquad\blacksquare$

Corollary 3.2 is the practical direction: producing one total rainbow forest of size $t$ certifies the inequality against *all* certificates $A$ at once. Its contrapositive says an obstruction ($\exists A,\ \mathrm{obj}(A) < t$) rules out any rainbow forest of size $t$.

---

## 4. Edge deletion and the collapse of edge-minimality

We now show that RFI-failure is *closed under edge deletion*, from which the non-existence of edge-minimal obstructions follows.

**Theorem 4.1 (Deletion monotonicity of the objective).** *Let $r_1, r_2$ be monotone. For every edge $e$ and every $A \subseteq E$,*
$$r_1(A \setminus \{e\}) + r_2\big((E \setminus \{e\}) \setminus (A \setminus \{e\})\big) \;\le\; \mathrm{obj}(A).$$

*Proof.* For the first term, $A \setminus \{e\} \subseteq A$ and monotonicity give $r_1(A \setminus \{e\}) \le r_1(A)$. For the second term we claim
$$(E \setminus \{e\}) \setminus (A \setminus \{e\}) \subseteq A^c.$$
Indeed, if $x$ lies in the left side then $x \ne e$, $x \in E$, and $x \notin A \setminus \{e\}$; the latter with $x \ne e$ forces $x \notin A$, i.e. $x \in A^c$. Monotonicity of $r_2$ then gives $r_2\big((E \setminus \{e\}) \setminus (A \setminus \{e\})\big) \le r_2(A^c)$. Adding the two bounds yields the claim. $\qquad\blacksquare$

Intuitively: deleting $e$ can only shrink the largest forest inside $A$ (first term) and only shrink the color pool available outside $A$ (second term). Deletion never improves the objective.

**Corollary 4.2 (Deletion preserves obstructions).** *If $\mathrm{obj}(A) < t$ for some $A$, then for every edge $e$ the deletion $G - e$ has a certificate below $t$: taking $A' = A \setminus \{e\} \subseteq E \setminus \{e\}$,*
$$r_1(A') + r_2\big((E \setminus \{e\}) \setminus A'\big) \le \mathrm{obj}(A) < t.$$

*Proof.* Immediate from Theorem 4.1. $\qquad\blacksquare$

**Theorem 4.3 (One good deletion forces RFI).** *Let $r_1, r_2$ be monotone. If $\mathrm{DeletionRFI}(t, e)$ holds for some edge $e$, then $\mathrm{RFI}(t)$ holds.*

*Proof.* Let $A \subseteq E$ be arbitrary. Since $A \setminus \{e\} \subseteq E \setminus \{e\}$, applying $\mathrm{DeletionRFI}(t,e)$ to $A \setminus \{e\}$ gives
$$t \le r_1(A \setminus \{e\}) + r_2\big((E \setminus \{e\}) \setminus (A \setminus \{e\})\big).$$
By Theorem 4.1 the right side is $\le \mathrm{obj}(A)$, so $t \le \mathrm{obj}(A)$. As $A$ was arbitrary, $\mathrm{RFI}(t)$ holds. $\qquad\blacksquare$

**Theorem 4.4 (No edge-minimal obstruction).** *For monotone $r_1, r_2$ there is no edge-minimal obstruction at any target $t$ on a nonempty ground set. That is, the conjunction "$\neg\mathrm{RFI}(t)$ and $\mathrm{DeletionRFI}(t,e)$ for all $e$" is contradictory.*

*Proof.* Suppose $\mathrm{DeletionRFI}(t,e)$ holds for every $e$; pick any edge $e_0$. By Theorem 4.3, $\mathrm{RFI}(t)$ holds — contradicting $\neg\mathrm{RFI}(t)$. $\qquad\blacksquare$

Theorem 4.4 is the promised negative result. The "unique failing subset of a minimal obstruction" cannot be discussed, because the very object — an edge-minimal obstruction — does not exist. Failure is inherited by every deletion (Corollary 4.2), so no obstruction can have all its deletions repaired.

---

## 5. Non-vacuity: an honest obstruction

To confirm the hypotheses are inhabited (i.e. obstructions genuinely exist, so Theorem 4.4 is not vacuous), consider the two-element ground set $E = \{a, b\}$ (two edges) with both matroids **free** — every subset is independent in each:

- $r_1(A) = |A|$ (both edges are an independent forest, e.g. a path on three vertices);
- $r_2(A) = |A|$ (the two edges carry distinct colors).

Both are monotone (indeed matroid ranks). Then for every $A \subseteq \{a,b\}$,
$$\mathrm{obj}(A) = |A| + |A^c| = 2,$$
so the objective is identically $2$. Taking target $t = 3$, the Rainbow Forest Inequality fails for **every** subset $A$ (each gives $\mathrm{obj}(A) = 2 < 3$): this is an honest obstruction, since the largest total rainbow forest has size $2 < 3$. Consistently with Corollary 4.2, deleting either edge leaves a one-edge graph whose minimum objective is $1 < 3$ — the obstruction persists, as it must. This concrete instance shows Theorems 4.1–4.4 are statements about a nonempty class of objects. (Here the failing certificates are *all* subsets, so the certificate lattice of §6 is the entire Boolean lattice, with least element $\varnothing$ and greatest element $E$.)

---

## 6. What survives: the lattice of certificates

The negative result kills *edge-minimality* but not the *spirit* of the conjecture. Fix a single obstruction and consider the family
$$\mathcal{F} = \{ A \subseteq E : \mathrm{obj}(A) = \min_{B} \mathrm{obj}(B) \}$$
of minimizing certificates. The objective $\mathrm{obj}(A) = r_1(A) + r_2(A^c)$ is **submodular** in $A$: $r_1$ is submodular, and $A \mapsto r_2(A^c)$ is submodular because $r_2$ is submodular and complementation reverses the lattice while preserving the submodular inequality. A standard fact about submodular functions is that their set of minimizers is closed under union and intersection:
$$A, B \in \mathcal{F} \implies A \cup B \in \mathcal{F} \text{ and } A \cap B \in \mathcal{F}.$$
Hence $\mathcal{F}$ is a (distributive) **sublattice** of $2^E$, with a unique least element $A_{\min} = \bigcap \mathcal{F}$ and a unique greatest element $A_{\max} = \bigcup \mathcal{F}$.

This is the correct replacement for naive uniqueness. In general $\mathcal{F}$ has many elements, so "exactly one failing subset" is *false*. But the failing certificates are highly structured: there is always a **unique smallest** and a **unique largest** certificate, nested $A_{\min} \subseteq A_{\max}$, with every minimizer sandwiched between them under the lattice operations. Combining §4 and §6, the true picture of the conjecture is:

> The minimizing (failing) subsets of a fixed obstruction form a distributive sublattice — with a unique smallest and a unique largest certificate — while *edge-minimal* obstructions do not exist at all.

The edges $e$ for which $\min \mathrm{obj}_{G-e} = \min \mathrm{obj}_G$ (i.e. deletion does not even change the optimum) are precisely those lying in every maximum total rainbow forest; characterizing them sharpens Theorem 4.1 to an equality-case analysis (see §8).

---

## 7. Algorithmic remarks

Two computational tasks accompany the theory.

1. **Certifying / refuting RFI.** By (Edmonds), one computes $\min_A \mathrm{obj}(A)$ via matroid intersection in polynomial time (in the number of edges), returning either a maximum total rainbow forest of size $\ge t$ (RFI holds) or a certificate $A$ with $\mathrm{obj}(A) < t$ (obstruction). Corollary 3.2 is the correctness core of the "accept" branch; Corollary 4.2 explains why the "reject" branch is robust to deletions.

2. **Brute-force verification on small ground sets.** For a ground set of size $n$, one can enumerate all $2^n$ subsets, evaluate $\mathrm{obj}$, and directly witness the minimizer lattice $\mathcal{F}$ and the failure of edge-minimality. This is the basis of the numerical demonstrations accompanying this paper, which confirm Theorems 4.1–4.4 and exhibit the sublattice $\mathcal{F}$ on explicit examples.

---

## 8. Discussion and future directions

We highlight the open threads this analysis surfaces.

1. **Contraction minimality.** Deletion cannot repair RFI (Theorem 4.4). *Contraction* $G/e$ changes both ranks non-monotonically in $A$, so the deletion-monotonicity argument does not apply. Is there a contraction-minimal notion under which a genuine uniqueness statement holds? Making the contracted rank $r_{M/e}$ and its objective precise would let one test this.

2. **Sharp uniqueness criterion.** Characterize exactly when a tight obstruction has a single failing subset, i.e. when $A_{\min} = A_{\max}$. Candidate sufficient conditions include strict submodularity of one rank or connectivity of the exchange graph.

3. **Quantitative deletion bound.** Strengthen Theorem 4.1 to an equality-case analysis: for which $e$ is $\min \mathrm{obj}_{G-e} = \min \mathrm{obj}_G$? These are exactly the edges lying in every maximum total rainbow forest.

4. **Full Edmonds min–max.** Only weak duality ($\le$) is used here. Proving the strong direction — existence of a common independent set meeting the minimum — would close the loop and is a substantial contribution in its own right.

---

## 9. Conclusion

Framing total rainbow forests through matroid intersection, we proved the weak-duality Rainbow Forest Inequality and a monotonicity principle showing that the Edmonds objective can only decrease under edge deletion. The immediate consequence is that RFI-failure is closed under deletion, so **edge-minimal obstructions do not exist** for monotone matroid ranks. This resolves the minimal-obstruction reading of the guiding conjecture in the negative — not because uniqueness is subtle, but because its subject is a phantom. The genuine structure lies elsewhere: for a fixed obstruction, the failing certificates form a distributive sublattice with a unique smallest and largest element. The methods use only monotonicity and submodularity of rank, so they apply to arbitrary matroid pairs and set the stage for the contraction-based and strong-duality questions above.
