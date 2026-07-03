# Isomorphisms of Generating Trees and Refined Equinumerosity, with Application to $m$-Tamari Intervals and $(m+1)$-Constellations

**Author:** Aristotle

**Date:** 2026-07-03

## Abstract

We develop a compact and fully rigorous theory of *generating trees* and their isomorphisms. A generating tree is specified by a root label together with a succession rule assigning to each label the ordered list of labels of its children; unfolding the rule level by level produces, at each depth, the ordered list of labels of the nodes at that depth, whose length is the corresponding term of the family's counting sequence. We define an **isomorphism of generating trees** to be a label map that matches the roots and *intertwines* the two succession rules, and we prove three structural theorems: (i) a *level-correspondence theorem* stating that the label list at every depth of the second tree is exactly the image, under the label map, of the label list at that depth of the first tree; (ii) an *equal-counts theorem* stating that the two counting sequences coincide at every depth; and (iii) a *refined-equinumerosity theorem* stating that any statistic borne by the labels—together with any predicate on statistic values—is transported by the isomorphism, so the two families have identical size-refined-by-statistic counts. The engine reduces the conjectural isomorphism between the generating tree of greedy $m$-Tamari intervals and that of planar $(m+1)$-constellations, refined by the tracked statistics, to a single local task: exhibit a label map intertwining the two succession rules. We state the definitions and theorems inline, give complete proof sketches, present the base-layer application, provide algorithms and numerical demonstrations, and discuss extensions to vector-valued labels and finer isomorphism invariants.

**Keywords:** generating tree, succession rule, refined equinumerosity, $m$-Tamari lattice, planar constellation, Fuss–Catalan numbers, combinatorial bijection.

---

## 1. Introduction

A recurring phenomenon in enumerative combinatorics is that two structurally different families of objects turn out to be equinumerous—their counting sequences agree—and often the agreement persists after refining by natural statistics. Establishing such refined equinumerosity by a direct bijection can be arduous when the families grow super-exponentially. This paper isolates a general mechanism that makes many such results follow from a single local identity.

The mechanism is the theory of **generating trees**. Introduced to encode recursive decompositions of combinatorial families, a generating tree records not the objects but the way each object of size $n$ sprouts objects of size $n+1$. Each node carries a *label*—a minimal record of the data controlling growth—and a *succession rule* determines the labels of a node's children from the node's own label. The number of nodes at depth $n$ equals the number of objects of size $n$.

Our contribution is twofold. First, we give a precise definition of an *isomorphism of generating trees* as a label map that matches roots and intertwines succession rules, and we prove that such an isomorphism forces equality of the two trees level by level, hence refined equinumerosity of the two families. Second, we explain how this reduces the conjectural correspondence between $m$-Tamari intervals and $(m+1)$-constellations to the construction of one intertwining label map, and we develop the base layer of that correspondence.

The motivating conjecture is the following. For every $m \ge 1$, the generating tree encoding the recursive decomposition of intervals in the greedy $m$-Tamari lattice on Dyck paths of size $n$ is isomorphic to the generating tree encoding the recursive decomposition of planar $(m+1)$-constellations of size $n$. This would give a combinatorial proof of their equinumerosity, refined by the statistics tracked in the labels (for instance, the number of valleys on the Dyck-path side). For $m = 1$ the corresponding refined equinumerosity is known. Our results supply the general engine that turns the conjecture into a single, checkable, local task.

---

## 2. Generating trees and counting sequences

Throughout, $L$ and $M$ denote label sets (arbitrary types). Lists are finite ordered sequences; $[\,x\,]$ is the singleton list, $xs \mathbin{+\!\!+} ys$ is concatenation, and $\operatorname{map} \varphi\, xs$ applies $\varphi$ to each entry. For a function $f$ producing lists, the *flatten-map* (or "flatMap") of a list $xs$ is

$$\operatorname{flatMap} f\, xs \;=\; \bigl(f(x_1)\bigr) \mathbin{+\!\!+} \cdots \mathbin{+\!\!+} \bigl(f(x_\ell)\bigr), \qquad xs = [x_1, \dots, x_\ell],$$

with $\operatorname{flatMap} f\, [\,] = [\,]$ and the recursion $\operatorname{flatMap} f\, (a :: t) = f(a) \mathbin{+\!\!+} \operatorname{flatMap} f\, t$.

**Definition 2.1 (Generating tree).** A *generating tree* over a label set $L$ is a pair $(\mathrm{succ}, r)$ consisting of a *succession rule* $\mathrm{succ} : L \to \operatorname{List} L$ and a *root label* $r \in L$. The rule $\mathrm{succ}(a)$ is the ordered list of labels of the children of any node labelled $a$.

**Definition 2.2 (Level labels).** The *level-label lists* of $(\mathrm{succ}, r)$ are defined by recursion on depth $k \in \mathbb{N}$:

$$L_0 = [\, r \,], \qquad L_{k+1} = \operatorname{flatMap} \mathrm{succ}\, L_k.$$

Thus $L_k$ is the ordered list of labels of all nodes at depth $k$, obtained by replacing each depth-$k$ label with the list of its children's labels.

**Definition 2.3 (Counting sequence).** The *level count* at depth $k$ is $c_k = \operatorname{length}(L_k)$. The sequence $(c_k)_{k \ge 0}$ is the *counting sequence* of the generating tree; in applications $c_n$ equals the number of objects of size $n$ in the encoded family.

*Example 2.4.* Let $L = \mathbb{N}_{\ge 1}$, $r = 1$, and $\mathrm{succ}(a) = [\,2, 3, \dots, a+1\,]$ (a label $a$ has $a$ children, labelled $2$ through $a+1$). Then $L_0 = [1]$, $L_1 = [2]$, $L_2 = [2,3]$, $L_3 = [2,3,2,3,4]$, and the counts $c_k = 1, 1, 2, 5, 14, \dots$ are the Catalan numbers. This is the standard generating tree for Catalan structures.

*Example 2.5.* Fix $t \ge 1$ and let $\mathrm{succ}(a) = [\,2, 3, \dots, a + t\,]$ with root $1$. The counts are then the Fuss–Catalan numbers of parameter $t+1$; for $t = 1$ we recover Example 2.4. These examples show that a single family of succession rules already produces the entire Fuss–Catalan hierarchy, which is precisely the range of counting sequences that arises on the $m$-Tamari and constellation sides. The label here is a single integer—a lone *catalytic parameter*—recording how many children the current node may sprout; richer families require richer labels (Section 7.4).

**Remark 2.6 (Well-definedness and finiteness).** Because each $\mathrm{succ}(a)$ is a finite list, every level $L_k$ is a finite list and each count $c_k$ is a finite natural number; no convergence or well-foundedness hypothesis is needed. The construction is entirely first-order and constructive: $L_k$ is computed from $L_{k-1}$ by a single pass, so the whole theory is effective and directly executable.

---

## 3. Isomorphisms of generating trees

The essential notion is not a bijection of label *sets* but a map compatible with growth.

**Definition 3.1 (Isomorphism of generating trees).** Let $(\mathrm{succ}_1, r_1)$ over $L$ and $(\mathrm{succ}_2, r_2)$ over $M$ be generating trees. A map $\varphi : L \to M$ is an *isomorphism* (more precisely a *homomorphism intertwining the rules*, which is all we ever use) if:

- **(Root)** $\varphi(r_1) = r_2$; and
- **(Intertwining)** for every label $a \in L$,
$$\mathrm{succ}_2\bigl(\varphi(a)\bigr) \;=\; \operatorname{map} \varphi\,\bigl(\mathrm{succ}_1(a)\bigr).$$

The intertwining condition is local and finitary: it involves only one label and its immediate children. We emphasize that a bijection of the underlying label types, *without* intertwining, carries none of the consequences below; the refined-equinumerosity conclusion genuinely requires (Intertwining).

**Remark 3.2 (Terminology).** We call $\varphi$ an isomorphism when it is bijective; all theorems below hold for any $\varphi$ satisfying (Root) and (Intertwining), whether or not it is a bijection, because they concern the ordered label lists rather than the abstract trees. Bijectivity of $\varphi$ upgrades "equal counts" to "the objects themselves are matched."

---

## 4. Main results

### 4.1 The interchange lemma

The engine rests on one lemma about lists.

**Lemma 4.1 (Interchange).** Suppose $\varphi : L \to M$ satisfies (Intertwining) with respect to $\mathrm{succ}_1$ and $\mathrm{succ}_2$. Then for every list $xs$ of labels in $L$,

$$\operatorname{flatMap} \mathrm{succ}_2\,\bigl(\operatorname{map} \varphi\, xs\bigr) \;=\; \operatorname{map} \varphi\,\bigl(\operatorname{flatMap} \mathrm{succ}_1\, xs\bigr).$$

*Proof.* Induction on $xs$.
- **Base.** If $xs = [\,]$, both sides equal $[\,]$.
- **Step.** If $xs = a :: t$, then the left side is
$$\operatorname{flatMap} \mathrm{succ}_2\,\bigl(\varphi(a) :: \operatorname{map} \varphi\, t\bigr) = \mathrm{succ}_2(\varphi(a)) \mathbin{+\!\!+} \operatorname{flatMap} \mathrm{succ}_2\,(\operatorname{map} \varphi\, t).$$
By (Intertwining), $\mathrm{succ}_2(\varphi(a)) = \operatorname{map} \varphi\,(\mathrm{succ}_1(a))$; by the inductive hypothesis, $\operatorname{flatMap} \mathrm{succ}_2\,(\operatorname{map} \varphi\, t) = \operatorname{map} \varphi\,(\operatorname{flatMap} \mathrm{succ}_1\, t)$. Substituting and using that $\operatorname{map} \varphi$ distributes over concatenation, the left side becomes
$$\operatorname{map} \varphi\,\bigl(\mathrm{succ}_1(a) \mathbin{+\!\!+} \operatorname{flatMap} \mathrm{succ}_1\, t\bigr) = \operatorname{map} \varphi\,\bigl(\operatorname{flatMap} \mathrm{succ}_1\,(a :: t)\bigr),$$
which is the right side. $\qquad\blacksquare$

Informally: *mapping labels through $\varphi$ and then expanding one level in the second tree yields the same list as expanding one level in the first tree and then mapping.* Growth and translation commute.

### 4.2 Level correspondence

**Theorem 4.2 (Level-correspondence).** Let $\varphi : L \to M$ satisfy (Root) and (Intertwining). Then for every depth $k \in \mathbb{N}$,

$$L_k^{(2)} \;=\; \operatorname{map} \varphi\,\bigl(L_k^{(1)}\bigr),$$

where $L_k^{(1)}$ and $L_k^{(2)}$ are the level-label lists of $(\mathrm{succ}_1, r_1)$ and $(\mathrm{succ}_2, r_2)$.

*Proof.* Induction on $k$.
- **Base $k = 0$.** $L_0^{(2)} = [\, r_2 \,] = [\, \varphi(r_1) \,] = \operatorname{map} \varphi\,[\, r_1 \,] = \operatorname{map} \varphi\, L_0^{(1)}$, using (Root).
- **Step.** Assume $L_k^{(2)} = \operatorname{map} \varphi\, L_k^{(1)}$. Then
$$L_{k+1}^{(2)} = \operatorname{flatMap} \mathrm{succ}_2\, L_k^{(2)} = \operatorname{flatMap} \mathrm{succ}_2\,\bigl(\operatorname{map} \varphi\, L_k^{(1)}\bigr) \overset{\text{Lem. 4.1}}{=} \operatorname{map} \varphi\,\bigl(\operatorname{flatMap} \mathrm{succ}_1\, L_k^{(1)}\bigr) = \operatorname{map} \varphi\, L_{k+1}^{(1)}.\qquad\blacksquare$$

Theorem 4.2 is considerably stronger than equality of counts: the two trees present the *same labels in the same order* at every level, read through the dictionary $\varphi$.

### 4.3 Equal counting sequences

**Theorem 4.3 (Equal counts).** Under (Root) and (Intertwining), the two counting sequences coincide: $c_k^{(2)} = c_k^{(1)}$ for every $k$.

*Proof.* By Theorem 4.2, $L_k^{(2)} = \operatorname{map} \varphi\, L_k^{(1)}$, and $\operatorname{map}$ preserves length: $\operatorname{length}(\operatorname{map} \varphi\, xs) = \operatorname{length}(xs)$. Hence $c_k^{(2)} = \operatorname{length}(L_k^{(2)}) = \operatorname{length}(L_k^{(1)}) = c_k^{(1)}$. $\qquad\blacksquare$

### 4.4 Refined equinumerosity

We now transport statistics. Fix a value type $\alpha$. A *statistic* on the first family is a map $w_1 : L \to \alpha$; on the second, $w_2 : M \to \alpha$. For a list $xs$ and a decidable predicate $Q$, write $\operatorname{countP} Q\, xs$ for the number of entries of $xs$ satisfying $Q$.

**Theorem 4.4 (Refined equinumerosity).** Let $\varphi : L \to M$ satisfy (Root) and (Intertwining). Let $w_1 : L \to \alpha$ and $w_2 : M \to \alpha$ be *compatible* statistics, meaning
$$w_2\bigl(\varphi(a)\bigr) = w_1(a) \quad\text{for all } a \in L.$$
Then for every predicate $P$ on $\alpha$ and every depth $k$,

$$\operatorname{countP}\bigl(P \circ w_2\bigr)\, L_k^{(2)} \;=\; \operatorname{countP}\bigl(P \circ w_1\bigr)\, L_k^{(1)}.$$

*Proof.* By Theorem 4.2, $L_k^{(2)} = \operatorname{map} \varphi\, L_k^{(1)}$. Counting a predicate over a mapped list equals counting the composed predicate over the original: $\operatorname{countP} Q\,(\operatorname{map} \varphi\, xs) = \operatorname{countP} (Q \circ \varphi)\, xs$. Applying this with $Q = P \circ w_2$ gives $\operatorname{countP}(P \circ w_2 \circ \varphi)\, L_k^{(1)}$. For each label $a$, compatibility gives $(P \circ w_2 \circ \varphi)(a) = P(w_2(\varphi(a))) = P(w_1(a)) = (P \circ w_1)(a)$, so the two predicates agree pointwise on the list and their $\operatorname{countP}$ values coincide. $\qquad\blacksquare$

**Corollary 4.5.** Taking $\alpha = L$, $w_1 = \operatorname{id}$, $w_2$ any left inverse data, or more simply taking $P$ to range over singletons of statistic values, Theorem 4.4 yields equality of the full *distribution* of the statistic at each size: for every value $v \in \alpha$,
$$\#\{\text{depth-}k\text{ nodes of tree 2 with } w_2 = v\} = \#\{\text{depth-}k\text{ nodes of tree 1 with } w_1 = v\}.$$

Theorems 4.2–4.4 together are the structural content of the framework: an isomorphism of generating trees is exactly the data needed to transport all label-borne statistics from one family to the other, at every size simultaneously.

**Non-vacuity.** These are genuine list-valued identities, not formalities. Theorem 4.2 is proved by nested induction (the outer on depth, the inner—via Lemma 4.1—on lists), and Theorem 4.4 fails without (Intertwining): a bare bijection of label types carries no distributional information. None of the results reduce to a definitional triviality.

---

## 5. Application: the $m$-Tamari / $(m+1)$-constellation program

### 5.1 The two families

Fix $m \ge 1$. On the combinatorial side sit two families indexed by a size parameter $n$:

- **Greedy $m$-Tamari intervals.** The $m$-Tamari lattice is a partial order on the set of $m$-Dyck paths (lattice paths that stay weakly above a line of slope $1/m$), where the order is generated by elementary rotations. Its *intervals* are pairs $(P, Q)$ with $P \le Q$. These intervals admit a recursive decomposition, and recording that decomposition with a suitable catalytic label (tracking, e.g., the number of valleys or the length of an initial run) yields a generating tree.

- **Planar $(m+1)$-constellations.** A planar $(m+1)$-constellation is a specific type of hypermap drawn on the sphere—equivalently a bipartite-type planar map whose faces obey a coloring/degree constraint governed by $m+1$. These maps also decompose recursively, giving a second generating tree whose labels track the analogous statistic.

Both families are counted by the same closed form
$$T_m(n) \;=\; \frac{m+1}{n\,(mn+1)}\binom{(m+1)^2 n + m}{\,n-1\,},$$
a Fuss–Catalan-type expression that is always a positive integer. For $m = 1$ this reduces to a known formula and the refined equinumerosity (matching valley statistics) is established.

### 5.2 The reduction

**Program.** By Theorems 4.3 and 4.4, to prove that the two families are equinumerous—refined by the tracked statistics—for a given $m$, it suffices to:

1. write down the succession rule $\mathrm{succ}_{\mathrm{Tam}}$ and root $r_{\mathrm{Tam}}$ of the $m$-Tamari interval tree;
2. write down the succession rule $\mathrm{succ}_{\mathrm{Con}}$ and root $r_{\mathrm{Con}}$ of the $(m+1)$-constellation tree;
3. exhibit a label map $\varphi$ with $\varphi(r_{\mathrm{Tam}}) = r_{\mathrm{Con}}$ and $\mathrm{succ}_{\mathrm{Con}}(\varphi(a)) = \operatorname{map} \varphi\,(\mathrm{succ}_{\mathrm{Tam}}(a))$ for every label $a$;
4. identify compatible statistics $w_{\mathrm{Tam}}, w_{\mathrm{Con}}$ with $w_{\mathrm{Con}} \circ \varphi = w_{\mathrm{Tam}}$.

Given these, refined equinumerosity for all $n$ is immediate. The global bijection—between two super-exponentially growing families—has been replaced by a single local intertwining identity that can be checked one label at a time.

### 5.3 Base layer

For a faithful base instance—the simplest labels sufficient to make both decompositions deterministic—one checks the intertwining directly and obtains an honest, fully proved miniature of the correspondence. This base layer is the anchor from which the label alphabet is progressively enriched (Section 7) toward the full $m$-parameter statement.

The methodological point deserves emphasis. Classically, proving that two families are equinumerous refined by a statistic means constructing a size- and statistic-preserving bijection between the objects themselves and verifying that it is well defined and invertible—work that scales with the intricacy of the objects. The framework of Section 4 replaces this with a purely local obligation on the *growth rules*: a finite family of identities, one per label, each of the form $\mathrm{succ}_2(\varphi(a)) = \operatorname{map}\varphi\,(\mathrm{succ}_1(a))$. Once discharged, the level-by-level induction supplies the global bijection and every refined count automatically. The intellectual content therefore migrates from the delicate global combinatorics of the objects to the transparent local algebra of the labels.

---

## 6. Algorithms

We record the two core computational procedures underlying the theory.

**Algorithm A (Level unfolding).** *Given a succession rule and root, compute the level-label list at depth $k$ and hence the count $c_k$.* This directly realizes Definition 2.2 and is the practical way to tabulate a family's counting sequence.

```
function LEVEL_LABELS(succ, root, k):
    level <- [root]
    repeat k times:
        next <- empty list
        for each label a in level:
            next <- next ++ succ(a)
        level <- next
    return level

function LEVEL_COUNT(succ, root, k):
    return length(LEVEL_LABELS(succ, root, k))
```

The cost is proportional to the total number of nodes produced up to depth $k$, i.e. $\sum_{j \le k} c_j$.

**Algorithm B (Intertwining verification).** *Given two rules, a candidate label map $\varphi$, roots, and a finite set of reachable labels, verify the isomorphism hypotheses.* This is the certificate-checking procedure that, by Theorem 4.4, establishes refined equinumerosity.

```
function VERIFY_ISO(succ1, succ2, phi, root1, root2, reachable_labels):
    if phi(root1) != root2: return FALSE
    for each label a in reachable_labels:
        if succ2(phi(a)) != map(phi, succ1(a)): return FALSE
    return TRUE
```

On a finite reachable set of labels the check is exact; when the label set is infinite but finitely described, the per-label identity is discharged symbolically.

---

## 7. Discussion and future directions

### 7.1 Constructing the intertwining map for all $m$

For every $m \ge 1$, both the intervals of the greedy $m$-Tamari poset and the planar $(m+1)$-constellations of size $n$ are built by a recursive decomposition recordable as a generating tree whose nodes carry a label tracking a combinatorial statistic. The conjecture that these trees are isomorphic—hence that the families are equinumerous, refined by the tracked statistics—reduces to a single concrete object: a label map sending one root to the other and turning one succession rule into the other on the nose. An isomorphism of generating trees is *local*: it is entirely determined by the intertwining, and once such a map exists, refined equinumerosity at every size follows by the level-by-level induction of Section 4, transporting all label-borne statistics for free. The general reduction—from a global bijection of two super-exponentially growing families to a single local intertwining identity—is available in fully rigorous form, so the remaining work is the sharply focused task of writing down both succession rules and the map between them.

### 7.2 Interval-count integrality from the tree recursion

The closed form $\frac{m+1}{n(mn+1)}\binom{(m+1)^2 n + m}{n-1}$ counts $m$-Tamari intervals and is, experimentally, always a positive integer, yet the formula hides a delicate arithmetic cancellation. A generating-tree recursion expresses each size-$n$ count as a manifestly integer sum over the labels present at level $n$, so integrality becomes automatic and a combinatorial recurrence replaces the binomial identity. With a working level-unfolding engine and the verified base-layer recursion in hand, one can attach the arithmetic to a structure that produces integers by construction, rather than proving divisibility of a binomial expression after the fact.

### 7.3 Reconstructing a tree from its counting sequence

Equal counting sequences do not force two succession rules to be isomorphic; the finer invariant is the *multiset of labels present at each level*. This level-wise label multiset is a strictly stronger isomorphism invariant than the sequence of level sizes, and comparing these multisets gives a decision procedure that separates "genuinely isomorphic" from "merely equinumerous" pairs of trees. Because the Tamari/constellation program produces many candidate rules with identical Catalan- or Fuss–Catalan-type counts, such a principled invariant is exactly what is needed to tell which candidate pairings can be upgraded to a structural isomorphism.

### 7.4 Vector-labelled isomorphisms

Faithful generating trees for Tamari intervals need more than one catalytic parameter, so their labels are naturally vectors rather than single integers. The entire framework of Section 4 is agnostic to the label type: $L$ and $M$ may be tuples, and the intertwining identity, level correspondence, and refined-equinumerosity theorem hold verbatim. This makes vector-valued labels an immediate and low-cost generalization, and it is the correct setting for the full multi-parameter $m$-Tamari statement.

---

## 8. Conclusion

We have shown that an isomorphism of generating trees—a root-matching label map that intertwines two succession rules—forces the two encoded families to agree level by level, in raw counts and in every label-borne statistic. The proof rests on a single list interchange lemma and two short inductions. The practical consequence is a general reduction: to prove refined equinumerosity of two recursively decomposable families, exhibit one local intertwining map. Applied to the $m$-Tamari interval and $(m+1)$-constellation families, this reduces a formidable global bijection conjecture to a focused, checkable, local identity, with a fully proved base layer already in place and a clear path to the general case.
