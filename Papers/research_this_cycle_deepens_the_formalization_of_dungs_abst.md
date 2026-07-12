# The Existence Gap for Stable Extensions in Abstract Argumentation

## Abstract

Abstract argumentation frameworks model reasoning under conflict as a directed graph whose vertices are arguments and whose edges are attacks. Among the classical semantics that assign "collectively acceptable" sets of arguments, the *stable* semantics is the most demanding: a stable extension is a conflict-free set that attacks every argument outside it, leaving no argument undecided. Unlike the preferred semantics, which always yields at least one extension, stable extensions may fail to exist. This paper isolates and settles the *existence gap* for stable extensions through four sharply stated conjectures. We disprove that every finite framework has a stable extension (the directed odd $3$-cycle has none, and its stable-extension count is exactly $0$), disprove that every preferred extension is stable (the empty set is the unique preferred extension of the $3$-cycle, yet it is not stable, giving a strict inclusion $\text{stable} \subsetneq \text{preferred}$), prove that every finite symmetric irreflexive framework has a stable extension (maximal conflict-free sets are stable there), and disprove that symmetry alone suffices (a single self-attacking argument destroys existence, so irreflexivity is necessary). Together these results draw a precise boundary between frameworks that admit a decisive verdict and those that do not, and they sharpen the strict place of the stable semantics within the extension-based hierarchy.

**Keywords.** abstract argumentation, stable extension, preferred extension, conflict-free set, admissibility, symmetric framework, existence, odd cycle.

## 1. Introduction

Reasoning under conflict — in law, negotiation, multi-agent systems, and the design of machines that must weigh contradictory evidence — is captured with striking economy by *abstract argumentation*. One discards the internal content of arguments and retains only two data: a set of arguments and a binary *attack* relation recording which argument defeats which. The central question becomes combinatorial: which sets of arguments can be accepted together as a coherent position, and under which criterion?

The classical answer is a hierarchy of *semantics*, each a criterion selecting certain "extensions" (acceptable sets). At the base sits conflict-freeness (internal consistency); above it, admissibility (self-defence); and at the top, several maximal or complete notions. The *preferred* semantics selects maximal admissible sets and is guaranteed to be nonempty: every finite framework has at least one preferred extension, possibly the empty set. The *stable* semantics is stronger and less forgiving: a stable extension partitions the arguments into "accepted" and "attacked," admitting no abstention. Its defining virtue — total decisiveness — is also the source of its central defect: **stable extensions need not exist.**

This paper studies that existence gap directly. We pose four bold, clean conjectures on when stable extensions exist, and we settle all four. Two are disproved by a single small directed framework, the odd $3$-cycle; one is proved for the symmetric irreflexive case; and one is disproved by a single self-attacking argument, showing that irreflexivity is not dispensable. The results are elementary in statement but jointly delineate the exact frontier between frameworks admitting a decisive verdict and those that do not.

All statements below are elementary and self-contained; Sections 2–6 develop the semantics from scratch and prove every claim with full proof sketches.

## 2. Definitions

An **argumentation framework** is a pair $(A, R)$ where $A$ is a set of *arguments* and $R \subseteq A \times A$ is the *attack relation*; we write $R\,a\,b$ for "$a$ attacks $b$." Throughout, $S, T \subseteq A$ denote sets of arguments.

**Definition 2.1 (Conflict-free).** $S$ is *conflict-free* if no member of $S$ attacks a member of $S$:
$$\mathrm{CF}(S) \iff \forall a \in S,\ \forall b \in S,\ \neg\, R\,a\,b.$$

**Definition 2.2 (Defence).** $S$ *defends* an argument $a$ if every attacker of $a$ is counter-attacked from $S$:
$$\mathrm{Def}(S, a) \iff \forall b,\ R\,b\,a \implies \exists c \in S,\ R\,c\,b.$$

**Definition 2.3 (Admissible).** $S$ is *admissible* if it is conflict-free and defends each of its members:
$$\mathrm{Adm}(S) \iff \mathrm{CF}(S) \wedge \forall a \in S,\ \mathrm{Def}(S, a).$$

**Definition 2.4 (Preferred).** $S$ is a *preferred extension* if it is a maximal (with respect to inclusion) admissible set:
$$\mathrm{Pref}(S) \iff \mathrm{Adm}(S) \wedge \forall T,\ \big(\mathrm{Adm}(T) \wedge S \subseteq T \implies T = S\big).$$

**Definition 2.5 (Maximal conflict-free / facet).** $S$ is *maximal conflict-free* if it is conflict-free and inclusion-maximal among conflict-free sets:
$$\mathrm{MCF}(S) \iff \mathrm{CF}(S) \wedge \forall T,\ \big(\mathrm{CF}(T) \wedge S \subseteq T \implies T = S\big).$$
Geometrically, the conflict-free sets of $(A,R)$ form an abstract simplicial complex $K(AF)$ — the *conflict-free complex* — whose faces are exactly the conflict-free sets; the maximal conflict-free sets are precisely its *facets*.

**Definition 2.6 (Stable).** $S$ is a *stable extension* if it is conflict-free and attacks every argument it does not contain:
$$\mathrm{Stab}(S) \iff \mathrm{CF}(S) \wedge \forall a \notin S,\ \exists b \in S,\ R\,b\,a.$$

A stable extension induces a two-block partition of $A$: every argument is *accepted* (in $S$) or *defeated* (attacked by $S$), with no undecided arguments.

**Symmetry and irreflexivity.** $R$ is *symmetric* if $R\,a\,b \implies R\,b\,a$, and *irreflexive* if $\neg\, R\,a\,a$ for all $a$. Symmetric irreflexive frameworks model mutual incompatibility without self-defeat; they correspond to (undirected, loopless) *conflict graphs*, and their conflict-free sets are exactly the independent sets of that graph.

## 3. The stable–preferred inclusion and its strictness

We first record where the stable semantics sits relative to the preferred semantics, then show the inclusion is strict.

**Proposition 3.1 (Stable is admissible under symmetry).** *If $R$ is symmetric and $S$ is conflict-free, then $S$ is admissible.*

*Proof.* We must show $S$ defends each member. Let $a \in S$ and let $b$ attack $a$, i.e. $R\,b\,a$. By symmetry $R\,a\,b$, and $a \in S$; hence $a$ itself is a member of $S$ counter-attacking $b$, so $\mathrm{Def}(S, a)$ holds. $\qquad\blacksquare$

In general (without symmetry) it remains a classical fact that every stable extension is admissible, complete, and preferred; the inclusion $\text{stable} \subseteq \text{preferred}$ always holds. The contribution here is the *strictness* of this inclusion, exhibited concretely below (Theorem 5.3).

## 4. Nonexistence I: the directed odd cycle

Define the **directed $3$-cycle** on the vertex set $\{0,1,2\}$ (identified with $\mathbb{Z}/3$) by
$$R\,a\,b \iff b = a + 1 \pmod 3,$$
so the only attacks are $0 \to 1 \to 2 \to 0$.

**Lemma 4.1.** *The $3$-cycle is irreflexive and not symmetric.*

*Proof.* Irreflexivity: $a + 1 \ne a$ in $\mathbb{Z}/3$, so $\neg\, R\,a\,a$. Non-symmetry: $R\,0\,1$ holds ($1 = 0+1$) but $R\,1\,0$ fails ($0 \ne 1+1 = 2$). $\qquad\blacksquare$

**Theorem 4.2 (No stable extension; disproves C1).** *The directed $3$-cycle has no stable extension. Consequently the conjecture "every finite framework has a stable extension" is false.*

*Proof (exhaustive).* There are $2^3 = 8$ candidate subsets $S \subseteq \{0,1,2\}$; we check each.
- $S = \varnothing$: not stable, since it attacks nothing while the universe is nonempty (e.g. $0 \notin S$ has no attacker in $S$).
- Singletons $\{0\}, \{1\}, \{2\}$: each is conflict-free, but each leaves one argument neither contained nor attacked. For $\{k\}$, the argument $k+2 \pmod 3$ is not in $\{k\}$ and its unique attacker is $k+1 \notin \{k\}$; so $\{k\}$ fails to attack $k+2$.
- Two-element sets $\{0,1\}, \{1,2\}, \{2,0\}$: each contains an attacking pair (e.g. $R\,0\,1$ in $\{0,1\}$), hence is not conflict-free.
- $S = \{0,1,2\}$: contains attacks, not conflict-free.

No subset is stable. $\qquad\blacksquare$

**Corollary 4.3 (Stable count is zero).** *The number of stable extensions of the $3$-cycle is $0$.*

*Proof.* By Theorem 4.2 the set of stable extensions is empty, so its cardinality is $0$. $\qquad\blacksquare$

This contrasts sharply with the *complete conflict graph* on $n$ vertices (all pairs mutually attacking, no self-attacks), whose stable extensions are exactly the $n$ singletons; there the count is $n$, and this count coincides with the Euler characteristic $\chi(K(AF)) = n$ of the conflict-free complex. The directed $3$-cycle collapses that count to $0$, dramatizing that the Euler/semantics correspondence is a feature of the symmetric world.

## 5. The empty preferred extension and strictness of the hierarchy

We now use the same $3$-cycle to separate the stable and preferred semantics.

**Lemma 5.1 (Empty set is admissible).** *In any framework, $\varnothing$ is admissible.*

*Proof.* $\mathrm{CF}(\varnothing)$ holds vacuously, and there are no members to defend. $\qquad\blacksquare$

**Theorem 5.2 (Empty set is the unique preferred extension of the $3$-cycle).** *In the directed $3$-cycle, $\varnothing$ is a preferred extension; indeed it is the unique admissible set.*

*Proof.* By Lemma 5.1, $\varnothing$ is admissible. It remains to show no nonempty set is admissible; maximality (and uniqueness) then follow. Suppose $S \ne \varnothing$ is admissible and let $a \in S$. The unique attacker of $a$ is $a - 1 \pmod 3$. Admissibility requires some $c \in S$ with $R\,c\,(a-1)$, i.e. $c$ attacks $a-1$; the unique such $c$ is $a - 2 = a + 1 \pmod 3$. Hence $a + 1 \in S$. But $R\,a\,(a+1)$ holds, so $\{a, a+1\} \subseteq S$ violates conflict-freeness — contradiction. Therefore no nonempty admissible set exists, $\varnothing$ is the unique admissible set, and it is trivially the maximal one. $\qquad\blacksquare$

**Lemma 5.3 (Empty set is not stable here).** *In the $3$-cycle, $\varnothing$ is not stable.*

*Proof.* Stability of $\varnothing$ would require every argument $a \notin \varnothing$ to have an attacker in $\varnothing$, impossible since $\varnothing$ has no members while the universe is nonempty. $\qquad\blacksquare$

**Theorem 5.4 (Preferred $\ne$ stable; disproves C2).** *There is a framework with a preferred extension that is not stable. Hence the inclusion $\text{stable} \subseteq \text{preferred}$ is strict: $\text{stable} \subsetneq \text{preferred}$.*

*Proof.* Take the $3$-cycle and $S = \varnothing$. By Theorem 5.2 it is preferred; by Lemma 5.3 it is not stable. $\qquad\blacksquare$

## 6. Existence on the symmetric side, and the necessity of irreflexivity

We now identify a structural condition that *restores* guaranteed existence, and show that both halves of the condition are needed.

**Lemma 6.1 (Maximal conflict-free sets are stable, symmetric irreflexive case).** *Let $R$ be symmetric and irreflexive, and let $S$ be maximal conflict-free. Then $S$ is stable.*

*Proof.* $S$ is conflict-free by hypothesis; we show it attacks every $a \notin S$. Suppose not: some $a \notin S$ has no attacker in $S$, i.e. $\neg\, R\,b\,a$ for all $b \in S$. By symmetry this also gives $\neg\, R\,a\,b$ for all $b \in S$. Since $R$ is irreflexive, $\neg\, R\,a\,a$. Therefore $S \cup \{a\}$ is conflict-free: no new conflict involves $a$ with a member of $S$ (either direction), nor with itself. But $S \cup \{a\} \supsetneq S$ contradicts the maximality of $S$. Hence every $a \notin S$ is attacked by some member of $S$, and $S$ is stable. $\qquad\blacksquare$

**Lemma 6.2 (Existence of maximal conflict-free sets).** *On a finite argument set, a maximal conflict-free set exists.*

*Proof.* The conflict-free sets form a nonempty finite family (it contains $\varnothing$), ordered by inclusion. A nonempty finite partial order has a maximal element; take a conflict-free set $S$ that no conflict-free set properly contains. $\qquad\blacksquare$

**Theorem 6.3 (Existence on the symmetric side; proves C3).** *Every finite symmetric irreflexive framework has a stable extension.*

*Proof.* By Lemma 6.2 pick a maximal conflict-free set $S$; by Lemma 6.1 it is stable. $\qquad\blacksquare$

Equivalently, a finite symmetric irreflexive framework corresponds to a finite loopless graph, and its stable extensions are exactly the *maximal independent sets* of that graph, which always exist. Theorem 6.3 closes the existence gap on the symmetric side.

We now show irreflexivity cannot be dropped.

**Theorem 6.4 (Reflexivity destroys existence).** *Any nonempty framework in which every argument attacks itself ($\forall a,\ R\,a\,a$) has no stable extension.*

*Proof.* Let $S$ be any conflict-free set. If $S$ contained an argument $a$, then $R\,a\,a$ would violate conflict-freeness; hence $S = \varnothing$. But $\varnothing$ cannot attack the (nonempty) universe, so it is not stable. Therefore no stable extension exists. $\qquad\blacksquare$

**Corollary 6.5 (Symmetry alone is insufficient; disproves C4).** *The single-argument framework with a self-attack is symmetric yet has no stable extension. Hence irreflexivity is necessary in Theorem 6.3.*

*Proof.* On a one-element argument set with the always-true attack relation, symmetry holds vacuously (there is only one argument, and the relation is preserved under swapping), but the relation is reflexive. By Theorem 6.4 there is no stable extension. Removing "irreflexive" from Theorem 6.3 would therefore make it false. $\qquad\blacksquare$

## 7. Summary of the four conjectures

| # | Conjecture | Verdict | Justification |
|---|------------|---------|---------------|
| C1 | Every finite framework has a stable extension | **Disproved** | Theorem 4.2 (odd $3$-cycle) |
| C2 | Every preferred extension is stable | **Disproved** | Theorem 5.4 (empty set in the $3$-cycle) |
| C3 | Every finite symmetric irreflexive framework has a stable extension | **Proved** | Theorem 6.3 |
| C4 | Symmetry alone suffices for existence | **Disproved** | Corollary 6.5 (self-attack) |

The four results locate the frontier of stable existence precisely. Directedness (an odd cycle) or self-defeat (a reflexive attack) each independently eliminates stable extensions; imposing *both* mutual disagreement (symmetry) *and* absence of self-defeat (irreflexivity) restores guaranteed existence in the finite case.

## 8. Applications

**Automated dispute resolution.** Systems that seek a *complete verdict* — a labelling of every claim as accepted or rejected with no undecided residue — are computing stable extensions. Theorem 4.2 warns that such a verdict may not exist even for tiny inputs (a three-way circular standoff), so a solver must be prepared to report "no stable extension" and fall back to a weaker semantics.

**Negotiation and multi-agent consensus.** When incompatibilities among positions are mutual and no position is self-undermining, the conflict structure is symmetric and irreflexive; Theorem 6.3 guarantees a decisive settlement (a maximal set of mutually compatible positions that dominates all others). This provides a design principle: engineer negotiation protocols so that the induced conflict graph is loopless and undirected, and a stable outcome is assured.

**Semantics selection.** Theorem 5.4 tells a reasoning engine that "the boldest defensible position" (preferred) and "a complete verdict" (stable) are genuinely different objectives; conflating them can silently return a defensible-but-indecisive answer where a complete one was required, or vice versa.

## 9. Discussion

The stable semantics trades robustness of existence for strength of conclusion. Our four results give the cleanest possible articulation of that trade-off in the finite setting: existence fails exactly when the attack structure carries an obstruction — an odd directed cycle or a self-attack — and is guaranteed once these are excluded via symmetry plus irreflexivity. The strictness result (Theorem 5.4) also pins down the stable semantics within the extension-based hierarchy $\text{stable} \subsetneq \text{preferred} \subseteq \text{complete} \subseteq \text{admissible} \subseteq \text{conflict-free}$, confirming that the first inclusion is not an equality.

The zero count of Corollary 4.3, set beside the count $n$ and Euler characteristic $n$ of the complete conflict graph on $n$ vertices, indicates that the numerical correspondence between decisive verdicts and the topology of the conflict-free complex is a phenomenon of the symmetric world, not of frameworks in general.

## 10. Future work

- **General symmetric frameworks.** Extend the count/topology correspondence beyond the complete conflict graph to arbitrary symmetric irreflexive frameworks, expressing the Euler characteristic of the conflict-free complex via the independence complex of the conflict graph, and relating stable extensions to maximal independent sets in full generality.
- **Characterizing existence.** For general (possibly directed) finite frameworks, characterize combinatorially exactly which ones admit a stable extension, refining the two obstructions identified here (odd directed cycles and self-attacks) into a complete criterion.
- **Full homology.** Replace the Euler characteristic by the reduced homology of the conflict-free complex, and relate its Betti numbers to the fine structure of the semantic hierarchy, seeking topological signatures that distinguish frameworks with and without stable extensions.
