# The Definability Boundary for External Interpretations

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $M$ be a set acted on by a group $G$ of symmetries, and let an *external interpretation* be an arbitrary map $I : M \to V$ into a value set $V$ regarded as lying outside the structure. We ask when such an interpretation is *recoverable from structural truth*, i.e. when it factors through the quotient of $M$ by structural indistinguishability, and when it is moreover *definable* in a language of invariant predicates.

We prove that recoverability is exactly orbit constancy, with a unique factorisation, and that the orbit map is the universal recoverable interpretation. We then analyse the definability side. In any invariant language, definability implies orbit constancy, so the conjunction "orbit-constant and definable" is redundant. For the *maximal* invariant language — the algebra of all invariant sets — definability and recoverability coincide with no cardinality hypotheses. For bounded invariant languages on infinite carriers the two notions come apart: parity on $\mathbb{N}$ with trivial symmetry group is recoverable but undefinable in the finite/cofinite language. For finite carriers we prove a four-way collapse: recoverable $\iff$ orbit-constant $\iff$ definable in the maximal invariant language $\iff$ each fibre is a Boolean combination of orbit-counting predicates; and we show the counting enrichment is necessary, since the trivial invariant language defines no non-constant interpretation.

On the quantitative side we introduce the **meaning-loss exponent** $\ell(M) = |M| - \#\mathrm{Orb}(M)$ and prove: the total interpretation count factors as $|V|^{|M|} = |V|^{\#\mathrm{Orb}} \cdot |V|^{\ell(M)}$; $\ell$ is additive over disjoint unions; $\ell(M) = 0$ exactly for rigid models, equivalently exactly when every interpretation is recoverable; and $\ell(M) = \sum_{O} (|O| - 1)$. Combining the recoverable count with the orbit-counting lemma yields the identity $2^{\sum_{g} |\mathrm{Fix}(g)|} = R^{|G|}$ where $R$ is the number of recoverable Boolean interpretations.

Two structural refinements complete the picture. A **logical invariance theorem** shows that over a structureless carrier of arbitrary cardinality, an interpretation of finitely many coordinates is recoverable iff it depends only on the kernel of the tuple — only equality is logical — and that finiteness of the arity is sharp. A **Krasner-style reconstruction theorem** shows that a permutation lies in $G$ iff it preserves every $G$-recoverable interpretation of configurations, so that $G \mapsto \mathrm{Th}(G)$ is injective and strictly antitone, and symmetry groups are exactly the Galois-closed objects of the induced connection.

**Keywords:** external interpretation, orbit descent, invariant language, definability, permutation invariance, meaning-loss exponent, Burnside's lemma, Galois connection.

---

## 1. Introduction

### 1.1 The problem

A structure sees its own elements only up to its symmetries. When we lay an external labelling on top of a structure — colours on vertices, names on database entries, gauge choices on a field configuration, coordinates on a manifold — some of what we write down is intrinsic to the object and some is ours. The purpose of this paper is to make that distinction exact, to determine which languages can express the intrinsic part, and to measure the discarded part with a numerical invariant.

The setting is deliberately minimal. Let $G$ be a group acting on a set $M$. We think of $G$ as the automorphism group of whatever structure $M$ carries; the framework is indifferent to what that structure is, since only the induced action matters. An **external interpretation** is any function $I : M \to V$ into an arbitrary value set $V$.

Two elements $x, y \in M$ are **structurally indistinguishable**, written $x \sim_G y$, when $g \cdot x = y$ for some $g \in G$. This is an equivalence relation (reflexive by the identity, symmetric by inverses, transitive by products) and coincides with the orbit relation. Write $M/G$ for the orbit space and $[x]$ for the class of $x$.

We say $I$ is **recoverable from structural truth** when there exists $F : M/G \to V$ with $F([x]) = I(x)$ for all $x \in M$, and **orbit-constant** when $x \sim_G y$ implies $I(x) = I(y)$.

### 1.2 The conjecture under test

The investigation was organised around the following conjecture:

> An external interpretation is recoverable from structural truth exactly when it is constant on automorphism orbits **and** definable in the invariant language; for finite models, orbit constancy alone is sufficient after adding bounded counting modalities.

Our results show that this conjecture is neither simply true nor simply false: it is *under-specified*, and the three regimes it conflates have three different answers.

1. The conjunction is **redundant**: definability in any invariant language already entails orbit constancy (Theorem 4.3).
2. Read with "the invariant language" as the *maximal* one, the conjecture is **true**, and needs no finiteness (Theorem 5.2).
3. Read with a *bounded* invariant language, the conjecture is **false** on infinite carriers (Theorem 6.3).
4. The finite half is **true**, and the counting enrichment is **necessary** (Theorems 5.4, 5.6, 7.4).

### 1.3 Contributions

Beyond the resolution of the conjecture, the paper contributes:

- a universal property for the orbit map (§3.3), identifying the recoverable interpretations as the clone generated by it;
- the meaning-loss exponent and its structure theory: factorisation, additivity, rigidity criterion, orbit decomposition (§8);
- a bridge to Burnside's lemma expressing the recoverable count as a fixed-point character sum (§8.2);
- a sharp logical-invariance theorem for tuple interpretations with a counterexample at infinite arity (§9);
- a Krasner-style reconstruction theorem and a Galois connection between symmetry groups and interpretation theories (§10).

---

## 2. Preliminaries

Throughout, $G$ is a group acting on a set $M$, and $V$, $W$ are value sets. No finiteness is assumed unless stated.

**Definition 2.1 (Structural indistinguishability).** For $x, y \in M$, write $x \sim_G y$ iff $\exists g \in G,\ g \cdot x = y$.

**Lemma 2.2.** $\sim_G$ is an equivalence relation, and $x \sim_G y$ iff $x \in \mathrm{Orb}_G(y)$ iff $y \in \mathrm{Orb}_G(x)$.

*Proof.* Reflexivity from $1 \cdot x = x$; symmetry from $g^{-1}\cdot(g\cdot x) = x$; transitivity from $(h g)\cdot x = h\cdot(g\cdot x)$. The identification with orbit membership is immediate from the definition of an orbit. $\square$

**Definition 2.3 (Interpretations).** An *external interpretation* is a function $I : M \to V$. It is *orbit-constant* if $x \sim_G y \Rightarrow I(x) = I(y)$, and *recoverable* if there exists $F : M/G \to V$ with $F \circ \pi = I$, where $\pi : M \to M/G$ is the quotient map.

**Definition 2.4 (Invariant set).** $S \subseteq M$ is *invariant* if $x \in S \Rightarrow g \cdot x \in S$ for all $g \in G$.

Note that invariance under all of $G$ is automatically two-sided: if $S$ is invariant then so is $S^{c}$, since $g \cdot x \in S$ would give $x = g^{-1}\cdot(g \cdot x) \in S$. We record the closure facts we will need.

**Lemma 2.5.** $\emptyset$ is invariant; each orbit $\mathrm{Orb}_G(x)$ is invariant; invariant sets are closed under complement, union, intersection, and difference.

*Proof.* All four are direct. For orbits: if $y = g' \cdot x$ then $g \cdot y = (g g') \cdot x$. For complements: as above. For unions: case split. Intersection and difference follow from complement and union by De Morgan. $\square$

---

## 3. Orbit descent

### 3.1 The descent theorem

**Theorem 3.1 (Orbit Descent).** An external interpretation $I : M \to V$ is recoverable from structural truth if and only if it is orbit-constant.

*Proof.* ($\Rightarrow$) Suppose $F \circ \pi = I$ and $x \sim_G y$. Then $\pi(x) = \pi(y)$, so $I(x) = F(\pi(x)) = F(\pi(y)) = I(y)$.

($\Leftarrow$) Suppose $I$ is orbit-constant. Then $I$ is constant on each fibre of $\pi$, hence descends to a well-defined $F$ on the quotient with $F([x]) := I(x)$; the universal property of quotients supplies $F \circ \pi = I$. $\square$

**Theorem 3.2 (Uniqueness of recovery).** If $F_1 \circ \pi = I$ and $F_2 \circ \pi = I$, then $F_1 = F_2$.

*Proof.* $\pi$ is surjective; every element of $M/G$ is of the form $[x]$, and $F_1([x]) = I(x) = F_2([x])$. $\square$

### 3.2 Meaning collisions

**Corollary 3.3 (Meaning collision).** If $x \sim_G y$ and $I(x) \neq I(y)$, then $I$ is not recoverable.

**Theorem 3.4 (Total annihilation under full symmetry).** Let $G = \mathrm{Sym}(M)$ act naturally. Then $I : M \to V$ is recoverable iff $I$ is constant.

*Proof.* If $x \neq y$ the transposition $(x\ y)$ carries $x$ to $y$, so $x \sim_G y$ for all $x,y$; orbit constancy is then global constancy. Conversely constants are trivially orbit-constant, and Theorem 3.1 applies. $\square$

**Example 3.5.** On $M = \{ \mathrm{tt}, \mathrm{ff}\}$ under $\mathrm{Sym}(M)$, the identity interpretation $I = \mathrm{id}$ is not recoverable, since $I(\mathrm{tt}) \neq I(\mathrm{ff})$. This is the smallest meaning collision.

### 3.3 The universal property

**Definition 3.6.** The *orbit map* is $\pi : M \to M/G$, $\pi(x) = [x]$.

**Theorem 3.7 (Universality of the orbit map).** $\pi$ is recoverable, and every recoverable $I : M \to V$ factors through $\pi$ by a *unique* $F$. Hence $\pi$ is the finest recoverable interpretation of $M$.

*Proof.* $\pi$ is recoverable via $F = \mathrm{id}_{M/G}$. Existence of the factorisation is Theorem 3.1 and uniqueness is Theorem 3.2. $\square$

**Proposition 3.8 (Closure properties).** If $I : M \to V$ and $J : M \to W$ are recoverable and $\varphi : V \to V'$ is any function, then $\varphi \circ I$ and $x \mapsto (I(x), J(x))$ are recoverable. Conversely every $\varphi \circ \pi$ is recoverable.

*Proof.* Immediate from orbit constancy: if $x \sim_G y$ then $I(x) = I(y)$ gives $\varphi(I(x)) = \varphi(I(y))$, and likewise for pairs componentwise. $\square$

Proposition 3.8 says the recoverable interpretations of $M$ form the clone generated by the orbit map: the orbit map is not just *an* invariant, it is *the* invariant, and all others are its renamings.

---

## 4. Invariant languages and definability

### 4.1 The definition

**Definition 4.1 (Invariant language).** An *invariant language* on $(G, M)$ is a family $\mathcal{L}$ of subsets of $M$ such that $\emptyset \in \mathcal{L}$; $S \in \mathcal{L} \Rightarrow S^{c} \in \mathcal{L}$; $S, T \in \mathcal{L} \Rightarrow S \cup T \in \mathcal{L}$; and every $S \in \mathcal{L}$ is invariant.

The first three clauses make $\mathcal{L}$ a Boolean algebra of subsets — the extensions of the formulas of a propositional language closed under $\bot$, $\neg$, $\vee$. The fourth clause is the semantic content: the language can only talk about the structure, never about elements individually.

**Definition 4.2 (Definability).** $I : M \to V$ is *definable in* $\mathcal{L}$ when every meaning-fibre $I^{-1}(v) = \{x : I(x) = v\}$ belongs to $\mathcal{L}$.

### 4.2 The conjunction is redundant

**Theorem 4.3 (Definability entails orbit constancy).** If $I$ is definable in some invariant language $\mathcal{L}$, then $I$ is orbit-constant.

*Proof.* Let $x \sim_G y$, say $y = g\cdot x$. The fibre $S = I^{-1}(I(x))$ lies in $\mathcal{L}$ and contains $x$; by invariance $g \cdot x = y \in S$, i.e. $I(y) = I(x)$. $\square$

**Corollary 4.4 (Redundancy).** For any invariant language $\mathcal{L}$,
$$\text{$I$ definable in $\mathcal{L}$} \iff \bigl(\text{$I$ orbit-constant} \ \wedge\ \text{$I$ definable in $\mathcal{L}$}\bigr).$$
The conjunction in the original conjecture carries no information beyond its second conjunct.

**Corollary 4.5.** Definability in any invariant language implies recoverability.

*Proof.* Theorem 4.3 followed by Theorem 3.1. $\square$

So definability is, in general, the strictly stronger notion; the remaining question is *how much* stronger, and that turns entirely on the choice of language.

---

## 5. The maximal language and the finite collapse

### 5.1 The orbit language

**Definition 5.1.** The *orbit language* $\mathcal{O}$ on $(G,M)$ is the family of **all** invariant subsets of $M$.

By Lemma 2.5, $\mathcal{O}$ is an invariant language, and by the invariance clause of Definition 4.1, every invariant language is contained in $\mathcal{O}$: it is the maximal invariant language.

**Theorem 5.2 (Maximal-language theorem).** For every $I : M \to V$, with no finiteness hypothesis whatsoever,
$$\text{$I$ definable in $\mathcal{O}$} \iff \text{$I$ recoverable from structural truth}.$$

*Proof.* ($\Rightarrow$) is Corollary 4.5. ($\Leftarrow$) Suppose $I$ is orbit-constant and let $v \in V$. If $x \in I^{-1}(v)$ and $g \in G$, then $x \sim_G g\cdot x$ gives $I(g\cdot x) = I(x) = v$, so $g \cdot x \in I^{-1}(v)$. Thus every fibre is invariant, i.e. lies in $\mathcal{O}$. $\square$

Theorem 5.2 is the correct general form of the conjecture. Recoverability *is* definability — in the largest invariant language. The role of any finiteness hypothesis is only to replace that abstract language with a concrete, finitely generated one.

### 5.2 Orbit-counting modalities

**Definition 5.3.** The *counting language* $\mathcal{C}$ is the smallest family of subsets of $M$ containing every orbit $\mathrm{Orb}_G(x)$ and $\emptyset$, and closed under complement and union.

Members of $\mathcal{C}$ are exactly the Boolean combinations of orbit predicates; $\mathcal{C}$ is closed under intersection and difference by De Morgan.

**Theorem 5.4 (Soundness and finite completeness).** Every member of $\mathcal{C}$ is invariant. Conversely, if $M$ is finite, every invariant subset of $M$ lies in $\mathcal{C}$. Hence for finite $M$, $\mathcal{C} = \mathcal{O}$.

*Proof.* Soundness is induction on the generation of $\mathcal{C}$ using Lemma 2.5.

Completeness is strong induction on $|S|$ for invariant $S$. If $S = \emptyset$ we are done. Otherwise pick $x \in S$. Invariance gives $\mathrm{Orb}_G(x) \subseteq S$, and $x \in \mathrm{Orb}_G(x)$, so $S \setminus \mathrm{Orb}_G(x)$ is a *strictly* smaller set; it is invariant as the difference of invariant sets (Lemma 2.5). By induction it lies in $\mathcal{C}$, and
$$S = \mathrm{Orb}_G(x) \ \cup\ \bigl(S \setminus \mathrm{Orb}_G(x)\bigr)$$
exhibits $S$ as a union of two members of $\mathcal{C}$. $\square$

The proof is an *algorithm*: peel orbits off an invariant set one at a time. It terminates in at most $\#\mathrm{Orb}(M)$ steps and returns an explicit orbit decomposition, which is the normal form of any invariant predicate on a finite model.

### 5.3 The classification

**Theorem 5.5 (Finite classification).** Let $M$ be finite and $I : M \to V$. The following are equivalent:

1. $I$ is recoverable from structural truth;
2. $I$ is constant on automorphism orbits;
3. $I$ is definable in the maximal invariant language $\mathcal{O}$;
4. every fibre $I^{-1}(v)$ is a Boolean combination of orbit predicates, i.e. lies in $\mathcal{C}$.

*Proof.* (1) $\iff$ (2) is Theorem 3.1; (1) $\iff$ (3) is Theorem 5.2; (3) $\iff$ (4) is Theorem 5.4. $\square$

This is the conjectured finite collapse, made precise: on a finite model the semantic notion (recoverability), the algebraic notion (orbit constancy) and the syntactic notion (definability by counting modalities) are one and the same.

### 5.4 The enrichment is necessary

**Definition 5.6.** The *trivial invariant language* $\mathcal{T}$ consists of $\emptyset$ and $M$ only.

$\mathcal{T}$ is an invariant language, but a blind one.

**Proposition 5.7.** No non-constant interpretation is definable in $\mathcal{T}$.

*Proof.* If $I(x) \neq I(y)$, the fibre $S = I^{-1}(I(x))$ contains $x$ (so $S \neq \emptyset$) and misses $y$ (so $S \neq M$). $\square$

**Theorem 5.8 (Counting modalities strictly increase expressive power).** Let $M$ be finite and suppose $x \not\sim_G y$ for some $x, y$. Then the orbit indicator
$$\chi_x(z) = \begin{cases} \mathrm{tt} & z \in \mathrm{Orb}_G(x) \\ \mathrm{ff} & \text{otherwise}\end{cases}$$
is recoverable and definable in $\mathcal{C}$, but not definable in $\mathcal{T}$.

*Proof.* $\chi_x$ is invariant since orbits are, so its fibres lie in $\mathcal{O} = \mathcal{C}$ by Theorem 5.4, and it is recoverable by Theorem 5.5. But $\chi_x(x) = \mathrm{tt} \neq \mathrm{ff} = \chi_x(y)$ because $y \notin \mathrm{Orb}_G(x)$, so Proposition 5.7 forbids definability in $\mathcal{T}$. $\square$

So the enrichment demanded by the finite half of the conjecture is not a convenience: as soon as a finite model has at least two orbits, the counting modalities buy genuine expressive power.

---

## 6. The infinite boundary

The finite collapse is genuinely finite. On infinite carriers, orbit constancy and definability in a *bounded* language come apart, and a small example suffices.

**Definition 6.1.** Let $M = \mathbb{N}$ carry the action of the **trivial** group $G = \{1\}$ (formally, the bottom subgroup of $\mathrm{Sym}(\mathbb{N})$).

**Lemma 6.2.** Under the trivial group, $\sim_G$ is equality, and hence *every* interpretation $I : \mathbb{N} \to V$ is orbit-constant and recoverable.

*Proof.* The only group element acts as the identity, so $x \sim_G y$ iff $x = y$. $\square$

**Definition 6.3 (Bounded/cofinite language).** Let $\mathcal{F}$ be the family of $S \subseteq \mathbb{N}$ with $S$ finite or $S^{c}$ finite.

$\mathcal{F}$ is an invariant language: it contains $\emptyset$; it is closed under complement by symmetry of the definition; it is closed under union (the union of two finite sets is finite, and if either set is cofinite so is the union); and invariance is trivial because the group is trivial. Intuitively $\mathcal{F}$ is the language whose formulas can pin down only finitely much information, or whose negations can.

**Theorem 6.4 (The definability boundary is real).** Let $\mathrm{par}(n) = [\,n\text{ even}\,]$. Then $\mathrm{par}$ is orbit-constant — hence recoverable from structural truth — but is *not* definable in $\mathcal{F}$.

*Proof.* Orbit constancy is Lemma 6.2. For undefinability, the fibre $\mathrm{par}^{-1}(\mathrm{tt}) = \{n : n \text{ even}\}$ is infinite (it contains $2k$ for all $k$, and $k \mapsto 2k$ is injective) and its complement, the odd numbers, is also infinite (it contains $2k+1$ for all $k$). Hence the fibre is neither finite nor cofinite, so it does not lie in $\mathcal{F}$. $\square$

**Corollary 6.5.** There exists an interpretation which is recoverable but not definable. Consequently the implication "recoverable $\Rightarrow$ definable" fails for bounded invariant languages on infinite carriers, and the definability clause of the conjecture cannot be dropped in that regime.

The reconciliation with Theorem 5.2 is instructive: with the trivial group, *every* subset of $\mathbb{N}$ is invariant, so the maximal invariant language $\mathcal{O}$ is the full power set and the evens are of course in it. What fails for $\mathcal{F}$ is not invariance but *expressive capacity*. On finite carriers no such gap can open, because a finite Boolean algebra of invariant sets is already all of them (Theorem 5.4). Infinity is exactly what allows a language to be invariant yet incomplete.

---

## 7. Graphs: a worked laboratory

For a concrete family of intermediate symmetry groups, take simple graphs.

**Definition 7.1.** For a simple graph $\Gamma$ on vertex set $W$, $\mathrm{Aut}(\Gamma) \leq \mathrm{Sym}(W)$ is the subgroup of permutations $\sigma$ with $\Gamma(\sigma a, \sigma b) \iff \Gamma(a,b)$ for all $a, b$.

**Theorem 7.2 (Degree is recoverable).** For a finite graph $\Gamma$, the vertex-degree interpretation $v \mapsto \deg_\Gamma(v)$ is recoverable from structural truth.

*Proof.* An automorphism $\sigma$ maps the neighbourhood of $v$ bijectively onto the neighbourhood of $\sigma v$: $u \sim v$ iff $\sigma u \sim \sigma v$, and $\sigma$ is injective. Hence $\deg(\sigma v) = \deg(v)$, so degree is orbit-constant; apply Theorem 3.1. $\square$

**Theorem 7.3 (Complete graphs annihilate meaning).** Every permutation of $W$ is an automorphism of the complete graph $K_W$. Consequently an interpretation of $K_W$ is recoverable iff it is constant.

*Proof.* Adjacency in $K_W$ is $a \neq b$, which every bijection preserves. Then Theorem 3.4 applies. $\square$

**Theorem 7.4 (Complete classification for the $3$-path).** Let $P_3$ be the path $0 - 1 - 2$. Then $\mathrm{Aut}(P_3) = \{\mathrm{id}, (0\ 2)\}$, and an interpretation $I$ of $P_3$ is recoverable iff $I(0) = I(2)$.

*Proof.* That $(0\ 2)$ is an automorphism is a direct check on the three adjacency pairs; that no other non-identity permutation is one follows by exhausting the six permutations of a three-element set — any automorphism must fix the unique vertex of degree $2$, leaving only the identity and the endpoint swap. Given the group, orbit constancy says precisely $I(0) = I((0\ 2)\cdot 0) = I(2)$, and conversely this single equation forces constancy on both orbits $\{0,2\}$ and $\{1\}$. Theorem 3.1 concludes. $\square$

**Corollary 7.5.** Vertex labels on $P_3$ are not recoverable (since $0 \neq 2$), while degrees are, with $\deg 0 = \deg 2 = 1 \neq 2 = \deg 1$. Thus on $P_3$ the degree interpretation is not merely recoverable but *separating*: it is exactly as fine as structural truth permits.

$P_3$ is the smallest example where the boundary is neither trivial nor total, and it exhibits both sides simultaneously: a meaning that collides (labels) and a meaning that survives and is maximally informative (degree).

---

## 8. Quantitative theory: the meaning-loss exponent

Assume in this section that $M$ and $V$ are finite, with $n = |M|$, $k = \#\mathrm{Orb}_G(M)$.

### 8.1 Counting and factorisation

**Theorem 8.1 (Count of recoverable interpretations).** The recoverable interpretations $M \to V$ are in natural bijection with the functions $M/G \to V$. Hence there are exactly $|V|^{k}$ of them.

*Proof.* Theorems 3.1 and 3.2 give a bijection: $I \mapsto$ its unique recovery $F$, with inverse $F \mapsto F \circ \pi$. The two composites are the identity by uniqueness and by definition respectively. Counting functions on a $k$-element domain gives $|V|^k$. $\square$

**Definition 8.2 (Meaning-loss exponent).** $\ell(M) := n - k = |M| - \#\mathrm{Orb}_G(M)$.

Since $\pi$ is surjective, $k \le n$, so $\ell(M) \ge 0$.

**Theorem 8.3 (Meaning-loss factorisation).**
$$\underbrace{|V|^{n}}_{\text{all interpretations}} \;=\; \underbrace{|V|^{k}}_{\text{recoverable}} \;\cdot\; \underbrace{|V|^{\ell(M)}}_{\text{loss factor}}.$$

*Proof.* Immediate from Theorem 8.1 and $n = k + \ell(M)$, valid because $k \le n$. $\square$

The exponent $\ell(M)$ is therefore the precise multiplicative deficit, in units of $\log_{|V|}$, between what can be said and what can be remembered — and, notably, it does not depend on $V$.

**Theorem 8.4 (Strictness).** If $|V| \ge 2$ and some orbit is non-trivial (there exist $x \neq y$ with $x \sim_G y$), then strictly fewer interpretations are recoverable than exist.

*Proof.* Non-triviality of an orbit makes $\pi$ non-injective; being surjective and non-injective on finite sets forces $k < n$. Then $|V|^{k} < |V|^{n}$ since $|V| \ge 2$. $\square$

### 8.2 The Burnside bridge

**Theorem 8.5.** With $R := \#\{\text{recoverable interpretations } M \to \{\mathrm{tt},\mathrm{ff}\}\}$,
$$2^{\;\sum_{g \in G} |\mathrm{Fix}(g)|} \;=\; R^{\,|G|}.$$

*Proof.* By Theorem 8.1 with $|V| = 2$, $R = 2^{k}$. The orbit-counting lemma states $\sum_{g\in G} |\mathrm{Fix}(g)| = k\,|G|$. Hence $2^{\sum_g |\mathrm{Fix}(g)|} = 2^{k|G|} = (2^{k})^{|G|} = R^{|G|}$. $\square$

The identity translates a semantic quantity (how many meanings a structure can hold) into a group-theoretic character sum (how many points its symmetries fix, on average). Read in the classical direction it is the statement that counting essentially-distinct colourings of a symmetric object *is* counting the recoverable interpretations of that object.

### 8.3 Structure theory of $\ell$

**Lemma 8.6 (Orbits of a disjoint union).** For $G$ acting on $M$ and on $N$, the orbit space of the disjoint union $M \sqcup N$ is canonically the disjoint union of the orbit spaces:
$$(M \sqcup N)/G \;\cong\; (M/G) \ \sqcup\ (N/G).$$

*Proof sketch.* The action preserves the two summands, so the map sending the class of $\iota_M(a)$ to $\iota_{M/G}([a])$ and the class of $\iota_N(b)$ to $\iota_{N/G}([b])$ is well defined; the evident map back is well defined for the same reason, and the two composites are the identity on representatives. $\square$

**Corollary 8.7.** $\#\mathrm{Orb}(M \sqcup N) = \#\mathrm{Orb}(M) + \#\mathrm{Orb}(N)$.

**Theorem 8.8 (Additivity).** $\ell(M \sqcup N) = \ell(M) + \ell(N)$.

*Proof.* $|M \sqcup N| = |M| + |N|$ and Corollary 8.7, together with $\#\mathrm{Orb}(M) \le |M|$ and $\#\mathrm{Orb}(N) \le |N|$ so that the truncated subtractions behave additively. $\square$

Additivity marks $\ell$ as an *extensive* invariant, like entropy or dimension: independent systems placed side by side have exactly the sum of their capacities for forgetting.

**Theorem 8.9 (Rigidity criterion).** $\ell(M) = 0$ if and only if $M$ is *rigid*, i.e. $x \sim_G y \Rightarrow x = y$.

*Proof.* $\ell(M) = 0$ means $|M| = |M/G|$; since $\pi$ is always surjective, equality of cardinalities on finite sets makes $\pi$ bijective, in particular injective, which is precisely rigidity. Conversely, rigidity makes $\pi$ injective, giving $|M| \le |M/G|$, hence equality, hence $\ell(M) = 0$. $\square$

**Theorem 8.10 (Rigidity as total recoverability).** Suppose $|V| \ge 2$. Then $\ell(M) = 0$ if and only if *every* interpretation $M \to V$ is recoverable.

*Proof.* If $\ell(M) = 0$, rigidity makes indistinguishability equality, so orbit constancy is vacuous and every $I$ is recoverable. Conversely, suppose every $I$ is recoverable but $x \sim_G y$ with $x \neq y$. Pick distinct $v_0, v_1 \in V$ and take $I(z) = v_0$ if $z = x$, else $v_1$. Recoverability of $I$ forces $I(x) = I(y)$, i.e. $v_0 = v_1$, a contradiction. $\square$

Theorem 8.10 justifies the name: $\ell$ vanishes exactly when nothing is lost.

**Theorem 8.11 (Orbit decomposition of the exponent).**
$$\ell(M) \;=\; \sum_{O \in \mathrm{Orb}_G(M)} \bigl(|O| - 1\bigr).$$

*Proof.* The orbits partition $M$, so $|M| = \sum_O |O|$. Every orbit is non-empty, so $|O| - 1$ is an honest (untruncated) subtraction, and summing over the $k$ orbits gives $\sum_O (|O| - 1) = \sum_O |O| - k = |M| - k = \ell(M)$. $\square$

This is the most concrete reading. An orbit of size $m$ carries one "genuine" element and $m-1$ *duplicates* — copies the structure cannot separate. The meaning-loss exponent counts duplicates, and nothing else.

**Examples 8.12.**

| Structure | size $n$ | orbits | $\ell$ |
|---|---|---|---|
| Rigid $n$-element model | $n$ | $n$ singletons | $0$ |
| Bare $n$-set, full symmetry | $n$ | one orbit of size $n$ | $n-1$ |
| Path $P_3$ | $3$ | $\{0,2\}, \{1\}$ | $1$ |
| Cycle $C_4$ | $4$ | one orbit | $3$ |
| $P_3 \sqcup P_3$ | $6$ | four | $2 = 1 + 1$ |

---

## 9. Logical invariance: only equality is logical

We now interpret *tuples* rather than points, over a carrier $\alpha$ with no structure at all, so that the symmetry group is $\mathrm{Sym}(\alpha)$ acting coordinatewise on tuples.

**Definition 9.1 (Kernel).** For an index set $\iota$ and a tuple $f : \iota \to \alpha$, the *kernel* of $f$ is the equivalence relation $i \equiv_f j \iff f(i) = f(j)$, i.e. the pattern of coincidences among coordinates.

**Theorem 9.2 (Transport).** Let $\iota$ be finite and $f, g : \iota \to \alpha$ have the same kernel: $f(i) = f(j) \iff g(i) = g(j)$ for all $i,j$. Then there is a permutation $\sigma \in \mathrm{Sym}(\alpha)$ with $\sigma(f(i)) = g(i)$ for every $i$.

*Proof sketch.* Same-kernel means the assignment $f(i) \mapsto g(i)$ is a well-defined injection from the finite set $\mathrm{ran}(f)$ into $\alpha$: well defined because $f(i) = f(j) \Rightarrow g(i) = g(j)$, injective because $g(i) = g(j) \Rightarrow f(i) = f(j)$. It remains to extend this partial injection to a permutation of $\alpha$. Split on the cardinality of $\alpha$: if $\alpha$ is finite, a partial injection of a finite set into itself extends to a permutation by a counting argument; if $\alpha$ is infinite, the domain $\mathrm{ran}(f)$ has cardinality strictly less than $|\alpha|$ (being finite), and a partial injection with domain of strictly smaller cardinality extends to a bijection. $\square$

**Theorem 9.3 (Logical invariance).** Let $\iota$ be finite and $I : (\iota \to \alpha) \to V$ an interpretation of $\iota$-indexed tuples. Then $I$ is recoverable from structural truth (with respect to $\mathrm{Sym}(\alpha)$ acting coordinatewise) if and only if $I$ depends only on the kernel:
$$\bigl(\forall i,j:\ f(i) = f(j) \iff g(i) = g(j)\bigr) \ \Longrightarrow\ I(f) = I(g).$$

*Proof.* ($\Rightarrow$) If $f$ and $g$ have the same kernel, Theorem 9.2 gives $\sigma$ with $\sigma \cdot f = g$, so $f \sim g$ and orbit constancy gives $I(f) = I(g)$.

($\Leftarrow$) Conversely, if $I$ is kernel-determined and $g = \sigma \cdot f$, then $f$ and $g$ have the same kernel — $\sigma(f(i)) = \sigma(f(j))$ iff $f(i) = f(j)$, using that $\sigma$ is a bijection — hence $I(f) = I(g)$. Apply Theorem 3.1. $\square$

This is the permutation-invariance criterion for *logicality*, sharpened: the recoverable notions over a structureless universe are exactly those built from equality.

**Corollary 9.4 (Binary case).** A binary interpretation $I : \alpha \times \alpha \to V$ is recoverable iff it is a function of the truth value of $p_1 = p_2$; that is, iff $(p_1 = p_2 \iff q_1 = q_2)$ implies $I(p) = I(q)$.

**Corollary 9.5 (Equality is logical, order is not).** The equality relation $(x,y) \mapsto [x = y]$ is recoverable. The strict order on $\{0,1,2\}$, $(x,y) \mapsto [x < y]$, is *not*: the pairs $(0,1)$ and $(1,0)$ have identical equality patterns (both unequal) but opposite order values.

Order is thus an external interpretation in the strict sense of this paper: it is meaning we impose on a bare set, and it collides with itself under the set's own symmetries.

**Theorem 9.6 (Sharpness of the arity hypothesis).** For infinite index sets the kernel classification fails. Specifically, let $\mathrm{Surj}(f)$ assert that $f : \mathbb{N} \to \mathbb{N}$ is surjective. Then $\mathrm{Surj}$ is recoverable with respect to $\mathrm{Sym}(\mathbb{N})$ acting coordinatewise, but is not kernel-determined.

*Proof.* Recoverability: if $g = \sigma \cdot f$ then $f$ surjective $\iff$ $g$ surjective, since $\sigma$ is a bijection of the codomain. Failure of kernel-determination: $f(n) = 2n$ and $g(n) = n$ are both injective, hence have the same (discrete) kernel; but $g$ is surjective and $f$ is not, since $2m = 1$ has no solution. $\square$

The finiteness of the arity in Theorem 9.3 is therefore essential. With infinitely many coordinates there exist permutation-invariant properties of tuples that equality patterns cannot detect — the transport lemma breaks because the range of the tuple may exhaust the carrier.

---

## 10. Reconstruction: the theory determines the group

All previous sections take $G$ as given. We close by reversing the arrow.

**Definition 10.1 (Configurations).** Let $\mathrm{Cfg}(\alpha) := \alpha \to \alpha$, the $\alpha$-indexed configurations, with $\mathrm{Sym}(\alpha)$ acting on *values*: $(\sigma \cdot f)(a) = \sigma(f(a))$. Write $\mathrm{id}_\alpha \in \mathrm{Cfg}(\alpha)$ for the identity configuration.

**Definition 10.2.** For $G \le \mathrm{Sym}(\alpha)$, the *interpretation theory* of $G$ is
$$\mathrm{Th}(G) := \{\,I : \mathrm{Cfg}(\alpha) \to \mathbf{Prop} \ \mid\ I \text{ is $G$-recoverable}\,\}.$$
A permutation $\sigma$ *preserves* $I$ when $I(\sigma \cdot f) = I(f)$ for every configuration $f$. For a set $\mathcal{S}$ of interpretations, $\mathrm{Sym}(\mathcal{S})$ is the group of permutations preserving every member of $\mathcal{S}$ (a subgroup, since preservation is closed under products and inverses).

**Definition 10.3 (Membership interpretation).** For $G \le \mathrm{Sym}(\alpha)$ define
$$\mu_G(f) :\iff \exists\, g \in G,\ (a \mapsto g(a)) = f,$$
i.e. $f$ is meaningful exactly when it *is* an element of $G$ read as a tuple.

**Lemma 10.4.** $\mu_G \in \mathrm{Th}(G)$.

*Proof.* Let $\sigma \in G$. If $f = g$ for some $g \in G$ then $\sigma \cdot f = \sigma g \in G$; conversely if $\sigma \cdot f \in G$, say $\sigma \cdot f = h$, then $f = \sigma^{-1} h \in G$. So $\mu_G(\sigma\cdot f) \iff \mu_G(f)$: $\mu_G$ is orbit-constant, hence recoverable. $\square$

**Theorem 10.5 (Krasner-style reconstruction).** For $G \le \mathrm{Sym}(\alpha)$ and $\sigma \in \mathrm{Sym}(\alpha)$,
$$\sigma \in G \iff \sigma \text{ preserves every } I \in \mathrm{Th}(G).$$

*Proof.* ($\Rightarrow$) If $\sigma \in G$ and $I$ is $G$-recoverable then $f \sim_G \sigma\cdot f$, so $I(\sigma\cdot f) = I(f)$.

($\Leftarrow$) Suppose $\sigma$ preserves everything in $\mathrm{Th}(G)$. By Lemma 10.4 it preserves $\mu_G$, so $\mu_G(\sigma \cdot \mathrm{id}_\alpha) = \mu_G(\mathrm{id}_\alpha)$. The right-hand side holds, witnessed by $1 \in G$. Hence $\sigma \cdot \mathrm{id}_\alpha$ — which is the tuple $a \mapsto \sigma(a)$ — is an element of $G$. That element is $\sigma$ itself. $\square$

**Corollary 10.6 (Group-side closure is the identity).** $\mathrm{Sym}(\mathrm{Th}(G)) = G$ for every $G \le \mathrm{Sym}(\alpha)$.

**Corollary 10.7 (Injectivity).** $G \mapsto \mathrm{Th}(G)$ is injective: distinct symmetry groups have distinct stocks of recoverable interpretations.

*Proof.* Apply $\mathrm{Sym}(-)$ to an equality of theories and use Corollary 10.6. $\square$

**Theorem 10.8 (Galois connection and strict antitonicity).** $G \le H$ implies $\mathrm{Th}(H) \subseteq \mathrm{Th}(G)$, and $\mathcal{S} \subseteq \mathcal{T}$ implies $\mathrm{Sym}(\mathcal{T}) \le \mathrm{Sym}(\mathcal{S})$; moreover $G \le \mathrm{Sym}(\mathcal{S}) \iff \mathcal{S} \subseteq \mathrm{Th}(G)$, so the pair is a Galois connection. Furthermore $G < H$ implies $\mathrm{Th}(H) \subsetneq \mathrm{Th}(G)$.

*Proof.* Antitonicity in both directions is immediate from the definitions, as is the adjunction, both sides unwinding to "every $g \in G$ preserves every $I \in \mathcal{S}$". For strictness: $G < H$ gives $\mathrm{Th}(H) \subseteq \mathrm{Th}(G)$, and if the inclusion were an equality then injectivity (Corollary 10.7) would force $H = G$, contradicting strictness. $\square$

**Example 10.9.** On the two-element carrier, the trivial group and the full symmetric group are distinct, hence have genuinely different theories — the swap is recoverable-preserving for one and not the other.

The consequence for the programme as a whole is conceptual: the recoverability boundary is an intrinsic invariant of structural truth, not an artefact of a chosen group presentation. *More symmetry means strictly fewer meanings*, with no ties.

---

## 11. Algorithms

The finite theory is entirely effective. We record the three procedures the proofs supply.

**Algorithm A (Orbit partition).** Given a finite carrier $M$ and generators of $G$ acting on it, compute the orbit partition by union–find over the generator action: for each generator $g$ and each $x$, union $x$ with $g\cdot x$. Cost $O(|M|\cdot|S|\cdot \alpha(|M|))$ for $|S|$ generators, $\alpha$ the inverse-Ackermann function. Output: the orbit of each element, hence $\#\mathrm{Orb}$, hence $\ell(M) = |M| - \#\mathrm{Orb}$.

**Algorithm B (Recoverability test and recovery).** Given $I : M \to V$ and the orbit partition, $I$ is recoverable iff $I$ is constant on each block; if so, the unique recovery $F$ sends each block to that common value. Cost $O(|M|)$ after Algorithm A. This is the decision procedure for the Descent Theorem, and it also returns the witness.

**Algorithm C (Orbit normal form for invariant predicates).** Given an invariant $S \subseteq M$, repeatedly pick $x \in S$, emit $\mathrm{Orb}_G(x)$, and replace $S$ by $S \setminus \mathrm{Orb}_G(x)$. This terminates in at most $\#\mathrm{Orb}$ rounds and outputs the unique representation of $S$ as a disjoint union of orbits — the normal form promised by finite completeness of the counting language. Cost $O(|M|)$ after Algorithm A.

Algorithm C is the constructive content of Theorem 5.4 and makes the finite classification of Theorem 5.5 an effective one: given a fibre, we can *produce* the counting-language formula defining it, or report that none exists.

---

## 12. Applications

**Database genericity.** A query is *generic* when its answer is invariant under renaming of the domain elements. Descent characterises exactly the annotations that survive renaming; the meaning-loss exponent of a schema-with-symmetry quantifies how much annotation is destroyed, and additivity says that this quantity behaves predictably when independent relations are placed side by side.

**Gauge invariance.** Physically meaningful quantities are precisely those recoverable from the gauge orbit space. The collision theorem is the statement that a gauge-dependent quantity is not an observable, and the universal property says the gauge quotient is the finest observable — every observable is a function of it, uniquely.

**Equivariant learning.** A model constrained to be equivariant under a group $G$ can express only orbit-constant functions of the input. Theorem 8.1 gives the exact size of that hypothesis class, $|V|^{\#\mathrm{Orb}}$, and $\ell$ is an architecture-independent bound on what symmetry costs in expressivity. Theorem 8.10 characterises when the constraint costs nothing: exactly on rigid inputs.

**Logicality.** Theorem 9.3 is the permutation-invariance criterion for logical notions with a sharp hypothesis, and Theorem 9.6 shows the hypothesis cannot be weakened. Corollary 9.5 is the classical observation that equality is logical and order is not, with a two-line proof.

**Combinatorial enumeration.** Theorem 8.5 is a semantic reading of Burnside's lemma: counting colourings up to symmetry *is* counting recoverable interpretations.

---

## 13. Discussion

The original conjecture bundled three claims. Disentangling them yields the following picture.

*The conjunction was redundant.* Definability in an invariant language already implies orbit constancy, so the conjunction adds nothing. This is a small observation with a large consequence: the conjecture's real content was always about definability alone.

*The general statement is a theorem, in the right language.* Recoverability is precisely definability in the maximal invariant language, with no hypotheses at all. This says the semantic notion has a syntactic characterisation — the question is only whether the syntax is *finitely presented*.

*Finiteness is exactly what makes the syntax finitely presented.* On finite models the maximal language is generated by orbit predicates, which is why the conjectured counting modalities work; and they are provably necessary, since a weaker invariant language defines no non-constant interpretation. On infinite models the maximal language may be too large to present, and parity is the witness that a natural bounded language misses recoverable interpretations.

*The quantitative theory is the unexpected residue.* Having settled the qualitative question, the counting question produced an invariant that was not part of the original problem: $\ell(M) = |M| - \#\mathrm{Orb}(M)$, additive, vanishing exactly on rigid models, and equal to the duplicate count $\sum_O(|O|-1)$. These three properties — extensivity, a sharp vanishing criterion, a local decomposition — are the signature of a well-behaved structural invariant, and they suggest $\ell$ deserves study in its own right.

*The theory is self-determining.* The reconstruction theorem says the boundary does not depend on a presentation of the symmetry group; the group is recoverable from the theory it induces. So "structural truth" is a well-defined notion independent of how the structure was described.

---

## 14. Future directions

**Beyond finite: presentable invariant languages.** Between the bounded language $\mathcal{F}$ (too weak) and the maximal language $\mathcal{O}$ (not finitely presented), which invariant languages on infinite carriers capture recoverability? A natural conjecture: for oligomorphic groups — those with finitely many orbits on $n$-tuples for each $n$ — a counting language over orbits of tuples should suffice, giving an infinite analogue of the finite collapse.

**A continuous meaning-loss exponent.** For a compact group acting on a manifold, $\ell$ should be replaced by $\dim M - \dim(M/G)$, i.e. the generic orbit dimension. Is the analogue of additivity, rigidity and orbit decomposition true in that setting, and does a measure-theoretic version compute an entropy?

**Intermediate arities.** Theorem 9.3 holds for finite arity and fails for arity $\aleph_0$. What is the exact boundary? For a carrier of cardinality $\kappa$, one expects the classification to hold for arities of size $< \kappa$ and to fail at $\kappa$, since transport fails precisely when the tuple's range can exhaust the carrier.

**Effective reconstruction.** Corollary 10.6 recovers a group from its theory, but non-constructively via the membership interpretation. For finite carriers, how many interpretations must one test to pin down $G$, and what is the complexity of reconstruction from a bounded sample?

**Meaning loss under products and quotients.** Additivity handles disjoint unions. What is $\ell(M \times N)$ for the diagonal action, and how does $\ell$ behave under passing to a subgroup or a quotient of the acting group? A subgroup can only refine orbits, so $\ell$ is monotone decreasing in the group; quantifying that monotonicity would give a lattice-theoretic refinement of the Galois picture of §10.

---

## 15. Conclusion

Structure sees its elements only up to symmetry, and this simple fact has an exact theory. An external meaning survives exactly when it is constant on symmetry classes, in which case it survives in exactly one way, and the symmetry-class map is the universal survivor. Whether the survivors can also be *expressed* depends on the language: in the largest invariant language, expressibility and survival coincide with no hypotheses; in bounded languages on infinite carriers they diverge, with parity as witness; on finite carriers everything collapses into a single equivalence whose syntax is Boolean combinations of orbit predicates, and that syntax is necessary. The amount of meaning destroyed is a single natural number $\ell(M) = |M| - \#\mathrm{Orb}(M)$: additive over disjoint unions, zero exactly on rigid structures, and equal to the number of duplicate elements inside orbits. Over a structureless carrier, the surviving relations of finite arity are precisely those built from equality. And the whole boundary is intrinsic: the symmetry group is itself recoverable from the meanings it permits.
