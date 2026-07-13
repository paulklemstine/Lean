# Well-Founded Argumentation Frameworks Have a Unique Complete Extension

## Abstract

We study Dung's abstract argumentation frameworks — a set of arguments equipped with a binary *attack* relation — and the lattice-theoretic semantics built on the *defense operator*. Building on the fact that the grounded extension (the least fixed point of the defense operator) is the least complete extension, we settle the opposite extreme. We prove two structural results. First, in *every* framework, the grounded extension equals the intersection of all complete extensions, and every stable extension is complete. Second, if the attack relation is *well-founded*, the framework has exactly one complete extension: the grounded extension, which is then simultaneously stable, preferred, admissible, and complete; the stable and preferred extensions are likewise unique and equal to it. The proofs are elementary but delicate: conflict-freeness of the grounded extension requires transfinite iteration of a non-continuous monotone operator, and uniqueness under well-foundedness follows from a well-founded induction establishing that the grounded extension attacks everything it excludes. We give complete definitions, statements, and proof sketches, together with algorithms and worked numerical examples.

---

## 1. Introduction

Abstract argumentation, introduced by Dung, provides a purely relational account of defeasible reasoning. One discards the internal structure of arguments and retains only *who attacks whom*. Remarkably, a rich theory of rational acceptability emerges from this skeleton, organized around several *extension semantics*: sets of arguments that can be collectively accepted according to varying standards of caution and commitment.

Among these, the **grounded extension** is the most skeptical: it accepts an argument only when compelled to. It is the least fixed point of a monotone *defense operator* and, by the Knaster–Tarski theorem, always exists. Prior work in this line established that the grounded extension is conflict-free, complete, and the least complete extension. The present paper answers the complementary questions:

1. *Globally*, how does the grounded extension relate to the family of all complete extensions? (Answer: it is their intersection.)
2. *When* does a framework admit a **unique** complete extension? (Answer: exactly when — sufficiently — the attack relation is well-founded, in which case the grounded, stable, and preferred semantics all coincide.)

The bridge is the notion of a **stable** extension, which we show is always complete. The main theorem, originally due to Dung (1995, Theorem 30), is here given a self-contained, rigorous treatment; we recover it from a clean well-founded induction.

---

## 2. Preliminaries: abstract argumentation frameworks

Throughout, fix a set $A$ of *arguments* and a binary *attack relation* $R$ on $A$. We read $R(a,b)$ as "$a$ attacks $b$." The pair $(A, R)$ is an **argumentation framework**. Sets of arguments are subsets $S \subseteq A$. We impose no finiteness assumption.

**Definition 2.1 (Conflict-free).** A set $S \subseteq A$ is *conflict-free* if
$$\forall a \in S,\ \forall b \in S,\ \lnot R(a,b).$$

**Definition 2.2 (Defense).** A set $S$ *defends* an argument $a$ if every attacker of $a$ is counter-attacked from $S$:
$$\mathrm{Defends}(S, a) \;:\equiv\; \forall b,\ R(b,a) \Rightarrow \exists c \in S,\ R(c, b).$$

**Definition 2.3 (Defense operator).** The *characteristic (defense) operator* $F \colon \mathcal{P}(A) \to \mathcal{P}(A)$ is
$$F(S) = \{\, a \in A : \mathrm{Defends}(S, a) \,\}.$$

**Definition 2.4 (Admissible).** $S$ is *admissible* if it is conflict-free and defends each of its members: $\mathrm{ConflictFree}(S)$ and $\forall a \in S,\ \mathrm{Defends}(S,a)$; equivalently, $S$ is conflict-free and $S \subseteq F(S)$.

**Definition 2.5 (Complete extension).** $S$ is *complete* if it is admissible and closed under defense: $\mathrm{Admissible}(S)$ and $F(S) \subseteq S$. Equivalently (Proposition 3.4), $S$ is complete iff it is a conflict-free fixed point of $F$.

**Definition 2.6 (Stable extension).** $S$ is *stable* if it is conflict-free and attacks every argument outside it:
$$\mathrm{ConflictFree}(S) \quad\text{and}\quad \forall a \notin S,\ \exists b \in S,\ R(b,a).$$

**Definition 2.7 (Preferred extension).** $S$ is *preferred* if it is a maximal admissible set: admissible, and every admissible $T \supseteq S$ satisfies $T = S$.

**Definition 2.8 (Well-founded relation).** The attack relation $R$ is *well-founded* if there is no infinite sequence $(a_n)_{n \in \mathbb{N}}$ with $R(a_{n+1}, a_n)$ for all $n$; equivalently, every nonempty subset of $A$ has an $R$-minimal element, and $R$ supports proof by induction: to prove $P(a)$ for all $a$, it suffices to prove $P(a)$ under the hypothesis that $P(b)$ holds for all $b$ with $R(b,a)$.

---

## 3. The defense operator and the grounded extension

**Lemma 3.1 (Monotonicity).** If $S \subseteq T$ then $F(S) \subseteq F(T)$.

*Proof.* If $S$ defends $a$, then for every attacker $b$ of $a$ there is $c \in S$ with $R(c,b)$; since $S \subseteq T$, that same $c$ lies in $T$. Hence $T$ defends $a$. $\square$

Thus $F$ is a monotone self-map of the complete lattice $(\mathcal{P}(A), \subseteq)$. By the Knaster–Tarski theorem it has a least fixed point.

**Definition 3.2 (Grounded extension).** The *grounded extension* $G$ is the least fixed point of $F$:
$$G = \operatorname{lfp}(F).$$
In particular $F(G) = G$ and $G \subseteq S$ for every $S$ with $F(S) \subseteq S$.

Because $F$ need not preserve arbitrary suprema (it is not $\omega$-continuous in general), the least fixed point is in general reached only by *transfinite* iteration. Writing $F^{(\alpha)}$ for the ordinal-indexed approximants starting from $\varnothing$ (successor step apply $F$, limit step take unions), we have $G = F^{(\alpha)}$ for some ordinal $\alpha$.

The following was established in the preceding stage of this project and is used here; we recall its statement and the key steps, since the uniqueness results depend on it.

**Lemma 3.3 (Conflict-freeness of $F$ and of $G$).**
1. If $S$ is conflict-free, then $F(S)$ is conflict-free.
2. A directed (chain) union of conflict-free sets is conflict-free.
3. Every ordinal approximant $F^{(\alpha)}$ is conflict-free.
4. Consequently, the grounded extension $G$ is conflict-free.

*Proof sketch.* (1) Suppose $a, b \in F(S)$ with $R(a,b)$. Since $b \in F(S)$ and $a$ attacks $b$, there is $c \in S$ with $R(c,a)$. Since $a \in F(S)$ and $c$ attacks $a$, there is $d \in S$ with $R(d,c)$. But $c, d \in S$ and $R(d,c)$ contradict conflict-freeness of $S$. (2) In a directed family, any two members lie in a common member, so any two elements of the union lie in one conflict-free set. (3) Transfinite induction: the base case $\varnothing$ is vacuously conflict-free; successor steps use (1); limit steps use (2), since the approximants form an increasing (hence directed) chain. (4) Since $G = F^{(\alpha)}$ for some $\alpha$. $\square$

We stress the delicacy noted in (1): conflict-freeness does **not** follow from the fixed-point equation $F(S) = S$ alone — there exist frameworks with non-least fixed points that are conflicting. Conflict-freeness is a property of the *least* fixed point, obtained via the transfinite construction.

**Proposition 3.4 (Characterization of completeness).** $S$ is complete if and only if $S$ is conflict-free and $F(S) = S$.

*Proof.* If $S$ is complete, it is admissible (so conflict-free and $S \subseteq F(S)$) and $F(S) \subseteq S$, hence $F(S) = S$. Conversely, if $S$ is conflict-free with $F(S) = S$, then $S \subseteq F(S)$ gives admissibility and $F(S) \subseteq S$ gives closure. $\square$

**Corollary 3.5.** $G$ is admissible and complete: $F(G) = G$ is a conflict-free fixed point.

**Proposition 3.6 (Grounded is least complete).** If $S$ is complete then $G \subseteq S$.

*Proof.* Completeness gives $F(S) \subseteq S$, so $S$ is a pre-fixed point of $F$; by the defining property of the least fixed point, $G \subseteq S$. $\square$

---

## 4. The intersection characterization (all frameworks)

**Theorem 4.1 (Grounded = intersection of complete extensions).** In every framework,
$$G = \bigcap \{\, S : S \text{ is complete} \,\}.$$

*Proof.* Let $\mathcal{C}$ be the family of complete extensions. By Corollary 3.5, $G \in \mathcal{C}$, so $\bigcap \mathcal{C} \subseteq G$. By Proposition 3.6, $G \subseteq S$ for every $S \in \mathcal{C}$, hence $G \subseteq \bigcap \mathcal{C}$. The two inclusions give equality. $\square$

Interpretively, the grounded extension is exactly the *common ground* of all complete positions: an argument is grounded iff no coherent, self-defending worldview can reject it.

---

## 5. Stable extensions are complete (all frameworks)

**Theorem 5.1 (Stability implies completeness).** Every stable extension is complete.

*Proof.* Let $S$ be stable, with conflict-freeness $(\ast)$ and totality $(\dagger)$: every $a \notin S$ has an attacker in $S$. We verify admissibility and defense-closure.

*Admissibility.* $S$ is conflict-free by $(\ast)$. For $a \in S$ and any attacker $b$ of $a$: if $b \in S$, then $R(b,a)$ with $a, b \in S$ contradicts $(\ast)$; so $b \notin S$, and by $(\dagger)$ there is $c \in S$ with $R(c,b)$. Thus $S$ defends every member, so $S \subseteq F(S)$.

*Defense-closure $F(S) \subseteq S$.* Suppose $a \in F(S)$ but $a \notin S$. By $(\dagger)$ there is $b \in S$ with $R(b,a)$. Since $a \in F(S)$ and $b$ attacks $a$, there is $c \in S$ with $R(c,b)$. But $b, c \in S$ with $R(c,b)$ contradicts $(\ast)$. Hence $a \in S$. $\square$

Consequently every stable extension is admissible, and (by Proposition 3.6) contains the grounded extension. Stability is strictly stronger than completeness: the two-cycle framework $\{a, b\}$ with $R(a,b)$ and $R(b,a)$ has grounded extension $\varnothing$ (complete), while $\{a\}$ and $\{b\}$ are the stable — and additional complete — extensions. Thus completeness does not imply uniqueness, and the empty grounded set is not stable there. Well-foundedness is what excludes such cycles.

---

## 6. Well-founded frameworks: uniqueness

We now assume $R$ is well-founded (Definition 2.8). The engine is the following.

**Theorem 6.1 (Grounded is stable under well-foundedness).** If $R$ is well-founded, then $G$ is a stable extension.

*Proof.* $G$ is conflict-free by Lemma 3.3(4). It remains to prove totality: every $a \notin G$ is attacked by some member of $G$. We prove, by well-founded induction on $R$, the stronger statement
$$P(a): \quad a \in G \ \lor\ \exists b \in G,\ R(b,a).$$
Fix $a$ and assume $P(b)$ for every $b$ with $R(b,a)$. Consider the attackers of $a$.

*Case 1:* some attacker $b$ of $a$ lies in $G$. Then the right disjunct of $P(a)$ holds.

*Case 2:* no attacker of $a$ lies in $G$. Take any attacker $b$ of $a$; then $R(b,a)$, so the induction hypothesis gives $P(b)$: either $b \in G$ (excluded in this case) or there is $c \in G$ with $R(c,b)$. Hence *every* attacker $b$ of $a$ is counter-attacked from $G$, i.e. $\mathrm{Defends}(G, a)$, so $a \in F(G) = G$ (Corollary 3.5). The left disjunct of $P(a)$ holds.

In either case $P(a)$ holds; by well-founded induction $P(a)$ holds for all $a$, which is exactly totality. $\square$

**Theorem 6.2 (Every complete extension is contained in $G$).** If $R$ is well-founded and $S$ is complete, then $S \subseteq G$.

*Proof.* By Theorem 6.1, $G$ is stable, and by Proposition 3.6, $G \subseteq S$. Suppose $a \in S$ but $a \notin G$. By stability of $G$ there is $b \in G$ with $R(b,a)$. Then $b \in G \subseteq S$ and $a \in S$ with $R(b,a)$ contradict conflict-freeness of $S$. Hence $a \in G$, i.e. $S \subseteq G$. $\square$

**Theorem 6.3 (Every complete extension equals $G$).** If $R$ is well-founded and $S$ is complete, then $S = G$.

*Proof.* Proposition 3.6 gives $G \subseteq S$; Theorem 6.2 gives $S \subseteq G$. $\square$

**Theorem 6.4 (Uniqueness of the complete extension).** If $R$ is well-founded, the grounded extension $G$ is the unique complete extension.

*Proof.* $G$ is complete (Corollary 3.5), and any complete $S$ equals $G$ by Theorem 6.3. $\square$

**Corollary 6.5 (Uniqueness and coincidence of stable extensions).** If $R$ is well-founded, then $G$ is stable, and it is the unique stable extension; every stable extension equals $G$.

*Proof.* $G$ is stable by Theorem 6.1. Any stable $S$ is complete by Theorem 5.1, hence equals $G$ by Theorem 6.3. $\square$

**Theorem 6.6 (Grounded is preferred; coincidence of semantics).** If $R$ is well-founded, $G$ is the unique preferred extension and the largest complete extension.

*Proof sketch.* Every preferred extension is a maximal admissible set and is in particular complete (a maximal admissible set is closed under defense, since adding a defended argument preserves admissibility). By Theorem 6.4 the only complete extension is $G$, so $G$ is the unique preferred extension. Being the unique complete extension, $G$ is trivially the largest one. Thus grounded, stable, and preferred semantics coincide. $\square$

Combining Sections 4–6: in a well-founded framework the grounded, stable, and preferred extensions collapse to a single set, which is simultaneously the least and the greatest complete extension and the intersection of all complete extensions (trivially, as there is only one).

---

## 7. Algorithms

For a *finite* framework, all extension semantics are computable. Since $F$ is monotone and, on finite frameworks, converges in finitely many steps, the grounded extension is obtained by Kleene iteration from $\varnothing$.

**Algorithm A (Grounded extension by Kleene iteration).**
Iterate $S_0 = \varnothing$, $S_{n+1} = F(S_n)$ until $S_{n+1} = S_n$. Because $\varnothing \subseteq F(\varnothing)$ and $F$ is monotone, the sequence is increasing; on a finite framework it stabilizes at $G$. Complexity $O(|A|^2 \cdot d)$ where $d$ is the number of iterations, bounded by $|A|$.

**Algorithm B (Extension classification by enumeration).**
For each subset $S \subseteq A$, test conflict-freeness, admissibility, completeness, and stability directly from the definitions; collect complete/stable extensions; take maxima under $\subseteq$ for preferred. Exponential in $|A|$, but a ground truth against which Algorithm A and the theorems are checked.

**Algorithm C (Well-foundedness / acyclicity test).**
The finite attack relation is well-founded iff its directed graph is acyclic; detect via depth-first search or repeated removal of sink-free... more precisely, repeatedly delete arguments with no incoming attack among the remaining arguments; well-founded iff all arguments are eventually deleted. When this returns "well-founded," Theorem 6.4 guarantees that Algorithm B returns exactly one complete extension, equal to Algorithm A's output.

---

## 8. Worked examples

**Example 8.1 (Well-founded chain).** $A = \{a, b, c\}$, $R = \{(a,b), (b,c)\}$. The relation is well-founded (a directed path). Kleene iteration: $S_0 = \varnothing$; $S_1 = F(\varnothing) = \{a\}$ ($a$ has no attacker; $b$ is attacked by $a \notin \varnothing$; $c$ is attacked by $b \notin \varnothing$); $S_2 = F(\{a\}) = \{a, c\}$ ($a$ defends $c$ by attacking $b$); $S_3 = \{a,c\} = S_2$. So $G = \{a, c\}$. It is conflict-free, attacks $b$ (via $a$), hence stable; and, as the theorems predict, it is the *unique* complete extension and the unique preferred extension.

**Example 8.2 (Two-cycle: ambiguity).** $A = \{a, b\}$, $R = \{(a,b), (b,a)\}$. Not well-founded. Complete extensions: $\varnothing$ (grounded), $\{a\}$, $\{b\}$. Stable extensions: $\{a\}$, $\{b\}$. Intersection of complete extensions $= \varnothing = G$, confirming Theorem 4.1. Uniqueness fails, exactly because the framework is not well-founded.

**Example 8.3 (Three-cycle).** $A = \{a,b,c\}$, $R = \{(a,b),(b,c),(c,a)\}$. Not well-founded. Grounded $= \varnothing$; there are *no* stable extensions; the only complete extension is $\varnothing$. Their intersection is $\varnothing = G$.

**Example 8.4 (Well-founded with defense).** $A=\{a,b,c,d\}$, $R = \{(a,b),(b,c),(c,d)\}$ together with $(a,c)$... a well-founded example where defense propagates: with $R = \{(a,b),(b,c)\}$ plus an isolated $d$, we get $G = \{a, c, d\}$, unique complete, stable, preferred.

These examples are reproduced numerically in the accompanying demonstration code, which recomputes each semantics by brute force and checks every theorem of Sections 4–6.

---

## 9. Discussion

The results delineate a sharp dividing line in Dung's theory. *Completeness* alone permits a multiplicity of verdicts, and *stability* — though strictly stronger — need not even exist (Example 8.3). The single hypothesis of well-foundedness of the attack relation collapses the entire landscape: grounded, stable, and preferred semantics coincide in a unique extension. The Intersection Theorem (Section 4) complements this by describing the grounded extension, in *any* framework, as the semantic infimum of all complete positions — the maximally skeptical yet coherent commitment.

Methodologically, two points deserve emphasis. First, the transfinite construction underlying Lemma 3.3 is essential: the defense operator is not $\omega$-continuous in general, and conflict-freeness of the *least* fixed point cannot be reduced to the fixed-point equation. Second, the uniqueness proof is remarkably economical once stability of the grounded extension is in hand: it is a single well-founded induction (Theorem 6.1) followed by two-line inclusions.

For system designers, the practical reading is direct: to guarantee a unique, unambiguous acceptance verdict, engineer the attack graph to be acyclic (well-founded); otherwise, adopt the grounded extension — the intersection of all complete extensions — as the safe, uncommitted stance.

---

## 10. Future directions

- **Kleene reachability for finitary frameworks.** When every argument has finitely many attackers, $F$ is $\omega$-continuous, so $G = \bigcup_{n} F^n(\varnothing)$. Formalizing $\omega$-continuity would yield an explicit union description and re-prove stability of $G$ for *finitary well-founded* frameworks by ordinary $\mathbb{N}$-indexed induction.

- **Preferred $\Rightarrow$ complete in general.** Establish that every preferred (maximal admissible) extension is complete without well-foundedness. Combined with Theorem 6.6 this upgrades uniqueness to "grounded = preferred = stable = complete" purely from the extension calculus.

- **Labelling correspondence.** Introduce complete labellings (in / out / undec) and the bijection with complete extensions; transport uniqueness to "the unique complete labelling has no undec label" on well-founded frameworks.

- **Quantitative well-foundedness.** Relate the ordinal rank of the attack relation to the least stage at which the approximants $F^{(\alpha)}$ stabilize, giving an ordinal bound on convergence of the grounded construction.

## References (classical background)

- P. M. Dung, *On the acceptability of arguments and its fundamental role in nonmonotonic reasoning, logic programming and n-person games*, Artificial Intelligence 77 (1995), 321–357.
