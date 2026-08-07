# Dependency-Adjusted Fitness of Mathematical Theories

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

We develop an exact, reproducible cost model for comparing bodies of mathematics that prove the same finite corpus of statements. A *theory* is recorded by the transitive dependency closure of the material it uses together with the corpus statements it settles; its *dependency-adjusted cost* is the total source length of that closure, each item charged exactly once, and its *fitness* is the number of corpus statements proved per unit cost. Within this model we establish six groups of results.

First, the cost model is canonical: the transitive dependency closure of a base set exists inside any finite universe, is the least dependency-closed superset of that base, and dependency-closed collections are closed under union and intersection, so that the *shared* material of two developments is itself a legitimate development. Merging obeys the exact inclusion–exclusion identity $\mathrm{cost}(T\sqcup U) + \mathrm{shared} = \mathrm{cost}(T)+\mathrm{cost}(U)$.

Second, on a fixed corpus fitness is a purely ordinal inverse of cost, and every nonempty finite comparison class therefore has a champion (the *finite maximum principle*).

Third, for a fixed proof system the champion is not merely existent but canonical: the transitive closure of the corpus' proof bases proves the corpus, embeds in the closure of every dependency-closed competitor, and is therefore a global fitness maximum over the entire unbounded class of covering developments, unique up to cost. We exhibit the exact boundary of this result: with two inequivalent proof routes for a single statement there are two cost-equal champions with disjoint closures, so canonicity fails; existence of a minimum-cost cover nonetheless survives.

Fourth, we prove an exact $k$-fold reuse identity, $\mathrm{cost}(\mathrm{library}) + k\cdot\mathrm{core} = \sum_i \mathrm{cost}(\mathrm{specialist}_i) + \mathrm{core}$, giving strict dominance of the shared library over a suite of $k\ge 2$ specialists duplicating a nonempty core.

Fifth, composition of two developments through an adapter layer of cost $A$ exhibits a sharp phase transition: fitness strictly increases, is unchanged, or strictly decreases according as $A$ is less than, equal to, or greater than the shared dependency mass — equivalently, according as the adapter density falls below the dependency density. When the composite proves a *product* corpus, multiplicative growth of the candidate population eventually dominates additive cost regardless of the adapter charge. The combinatorial baseline is computed exactly: dependency-closed subsets multiply across independent splits, an independent family of $n$ items admits exactly $2^n$ usable sub-libraries, a chain admits exactly $n+1$, and the former strictly exceeds the latter for all $n \ge 2$.

Sixth, we describe the shape of the landscape. Any semantics-preserving migration between developments written against inequivalent interfaces contains an intermediate state overshooting the smaller endpoint length by at least the fixed positive fraction $(\alpha-\beta)/(1+\beta)$, where $1+\alpha$ bounds the cost of a boundary-crossing state below and $1+\beta$ bounds endpoint efficiency above. A stylewise-optimal development with a style-closed neighbourhood is a strict local maximum, a property invariant under semantics-preserving renaming; a computed nine-development landscape has three distinct strict local maxima, only one of which is global. Finally, in any language admitting conservative inflation at sublinear marginal source cost, raw theorem-per-line fitness is unbounded and admits no global maximum, and the unbounded witnesses are semantically inert — yielding a sharp dichotomy in which resource normalisation is the decisive hypothesis.

**Keywords:** dependency closure, theory fitness, reuse, phase transition, fitness landscape, local maxima, set cover, conservative extension.

---

## 1. Introduction

### 1.1 The question

Fix a finite list of mathematical statements — a *corpus* — and consider the many possible bodies of mathematics that prove all of them. Some are terse and specialised: each statement gets a bespoke argument. Some are general and abstract: an elaborate framework is erected, after which every statement is a corollary. Practitioners argue endlessly about which style is better, and the argument never resolves, because "better" has never been given a definition sharp enough to admit a proof.

This paper supplies such a definition and determines the resulting structure. The definition has three ingredients:

1. a **corpus**, fixing what counts as an achievement;
2. a **cost model**, fixing what counts as an expenditure;
3. a rule for **charging shared material**, fixing when two developments have genuinely done the same work.

The third ingredient is the delicate one and is what the phrase *dependency-adjusted* refers to. Once all three are fixed, a large fraction of the folklore becomes provable, and — equally importantly — a specific part of it becomes provably false without further hypotheses.

### 1.2 Summary of contributions

- A canonical cost model based on least dependency-closed supersets (§2), with a lattice structure on dependency-closed collections and exact inclusion–exclusion for merges.
- The ordinal reduction of fitness to cost and the finite maximum principle (§3).
- The dependency-adjusted global champion theorem for a fixed proof system, with a matched counterexample delimiting it and a survival result for the multi-route case (§4).
- The exact $k$-fold reuse identity and strict dominance of shared libraries (§5).
- The composition phase transition, in absolute and density form, plus the multiplicative-corpus criterion (§6).
- Exact candidate counts: multiplicativity across independent splits, $2^n$, $n+1$, and the strict collapse (§7).
- The quantitative adapter valley and three-style metastability (§8).
- Non-existence of a normalisation-free global maximum, with semantic inertness of the witnesses and the resulting dichotomy (§9).

---

## 2. The cost model

Throughout, mathematical items — definitions, lemmas, theorems, notations — are indexed by natural numbers, and all collections are finite.

### 2.1 Dependency closure

**Definition 2.1 (Dependency structure).** A *dependency structure* is a function $\mathrm{deps}$ assigning to each item $i$ a finite set $\mathrm{deps}(i)$ of items, its *direct dependencies*.

**Definition 2.2 (Dependency-closed).** A finite set $S$ of items is *dependency-closed* if $\mathrm{deps}(i) \subseteq S$ for every $i \in S$.

A dependency-closed set is precisely a self-contained development: one that can be read linearly without encountering an item whose prerequisites are missing.

**Lemma 2.3 (Lattice structure).** If $S$ and $T$ are dependency-closed then so are $S \cup T$ and $S \cap T$.

*Proof sketch.* For the union, an item $i \in S \cup T$ lies in one of the two, whose closedness places $\mathrm{deps}(i)$ inside that set and a fortiori inside the union. For the intersection, $i \in S \cap T$ gives $\mathrm{deps}(i) \subseteq S$ and $\mathrm{deps}(i) \subseteq T$, hence $\mathrm{deps}(i) \subseteq S \cap T$. $\square$

The intersection clause is not decoration. It states that the shared material of two self-contained developments is itself self-contained, which is exactly the licence needed to speak of "the shared dependency mass" as a real object rather than an accounting artefact.

**Definition 2.4 (Expansion step).** For a set $S$, let $\mathrm{step}(S) = S \cup \bigcup_{i \in S}\mathrm{deps}(i)$.

**Lemma 2.5.** $S \subseteq \mathrm{step}(S)$, and $\mathrm{step}(S) = S$ if and only if $S$ is dependency-closed. If $T$ is dependency-closed and $S \subseteq T$ then $\mathrm{step}(S) \subseteq T$.

**Definition 2.6 (Transitive closure).** Fix a finite universe $U$ and a base $B$. Define
$$\overline{B} \;=\; \mathrm{step}^{\,|U|+1}(B),$$
the result of $|U|+1$ rounds of expansion.

**Theorem 2.7 (Canonicity of the closure).** Suppose $B \subseteq U$ and $U$ is dependency-closed. Then:
1. $B \subseteq \overline{B}$;
2. $\overline{B} \subseteq U$;
3. $\overline{B}$ is dependency-closed;
4. **(minimality)** $\overline{B} \subseteq T$ for every dependency-closed $T$ with $B \subseteq T$.

*Proof sketch.* (1) and (2) follow by induction on the number of rounds, using $S \subseteq \mathrm{step}(S)$ and Lemma 2.5 respectively. (4) is again induction: if $\mathrm{step}^{k}(B) \subseteq T$ then $\mathrm{step}^{k+1}(B) \subseteq T$ by the last clause of Lemma 2.5. (3) is the substantive point: the iterates form an increasing chain inside $U$, so if no fixed point were reached within $|U|+1$ rounds, each round would strictly increase cardinality and $|\mathrm{step}^{|U|+1}(B)| \ge |U|+1 > |U|$, contradicting (2). Hence the chain stabilises and the value at round $|U|+1$ is a fixed point of $\mathrm{step}$, i.e. dependency-closed by Lemma 2.5. $\square$

Minimality is what makes the model canonical: $\overline{B}$ is not a plausible choice of "everything needed" but the unique smallest one, so there is no slack for an interested party to exploit in charging a development for its prerequisites.

### 2.2 Theories, cost, fitness

**Definition 2.8 (Theory).** A *theory* $T$ consists of a finite set $C(T)$ of items — its transitive dependency closure — and a finite set $P(T)$ of corpus statements it proves.

**Definition 2.9 (Cost and fitness).** Given a source-length function $\ell$ assigning a natural number to each item,
$$\mathrm{cost}_\ell(T) = \sum_{i \in C(T)} \ell(i), \qquad \mathrm{fit}_\ell(T) = \frac{|P(T)|}{\mathrm{cost}_\ell(T)} \in \mathbb{Q}.$$

Each item in the closure is charged once, however many times it is used. This is the entire content of "dependency-adjusted".

**Lemma 2.10 (Monotonicity).** If $C(T) \subseteq C(U)$ then $\mathrm{cost}_\ell(T) \le \mathrm{cost}_\ell(U)$.

**Definition 2.11 (Merge).** $T \sqcup U$ is the theory with $C(T\sqcup U) = C(T)\cup C(U)$ and $P(T \sqcup U) = P(T)\cup P(U)$.

**Theorem 2.12 (Exact merge accounting).**
$$\mathrm{cost}_\ell(T \sqcup U) \;+\; \sum_{i \in C(T)\cap C(U)} \ell(i) \;=\; \mathrm{cost}_\ell(T) + \mathrm{cost}_\ell(U).$$

*Proof sketch.* Summation over a union plus summation over the intersection equals the sum of the separate summations, since each item of the union is counted once on the left for each of the sets containing it. $\square$

**Corollary 2.13.** $\mathrm{cost}_\ell(T\sqcup U) \le \mathrm{cost}_\ell(T)+\mathrm{cost}_\ell(U)$: merging never costs more than duplicating.

---

## 3. Fitness is ordinally inverse to cost

**Theorem 3.1 (Ordinal reduction).** Let $T, U$ be theories with $|P(T)| = |P(U)| > 0$ and $\mathrm{cost}_\ell(T), \mathrm{cost}_\ell(U) > 0$. Then
$$\mathrm{fit}_\ell(T) \le \mathrm{fit}_\ell(U) \iff \mathrm{cost}_\ell(U) \le \mathrm{cost}_\ell(T),$$
and correspondingly with both inequalities strict.

*Proof sketch.* With a common positive numerator $n$, the map $x \mapsto n/x$ is strictly decreasing on the positive rationals. $\square$

Theorem 3.1 says that on a fixed corpus nothing about the corpus matters beyond its cardinality: comparing fitness reduces to comparing two natural numbers.

**Theorem 3.2 (Finite maximum principle).** For any nonempty finite index set $F$ and family of theories $(T_a)_{a\in F}$, there is $b \in F$ with $\mathrm{fit}_\ell(T_a) \le \mathrm{fit}_\ell(T_b)$ for all $a \in F$.

*Proof sketch.* A nonempty finite set of rationals attains its maximum. $\square$

Trivial as mathematics, this theorem plays a load-bearing methodological role: it isolates exactly what is *not* at issue in the "which library is best?" question. Existence is free. Everything interesting concerns identification, and — as §9 shows — the finiteness hypothesis cannot be dropped.

**Theorem 3.3 (Shared library is champion, abstract form).** Let $(T_a)_{a\in F}$ be theories with $|P(T_a)| = |P(L)| > 0$ for all $a$, and suppose $C(L) \subseteq C(T_a)$ for all $a\in F$, with $\mathrm{cost}_\ell(L) > 0$. Then $\mathrm{fit}_\ell(T_a) \le \mathrm{fit}_\ell(L)$ for all $a \in F$.

*Proof sketch.* Monotonicity (2.10) gives $\mathrm{cost}_\ell(L)\le\mathrm{cost}_\ell(T_a)$; Theorem 3.1 inverts. $\square$

**Theorem 3.4 (Champion characterisation).** Under the same corpus and positivity hypotheses, $T_b$ is a fitness champion of the family if and only if it has minimal cost in the family.

Theorem 3.4 makes the champion question *empirically decidable by a single measurement per competitor*: total source length of the transitive closure.

---

## 4. The canonical champion, and the exact boundary of canonicity

### 4.1 Fixed proof systems

**Definition 4.1 (Proof system).** A *proof system* consists of a dependency structure $\mathrm{deps}$ and a function assigning to each statement $s$ the set $\mathrm{base}(s)$ of items consumed by its chosen proof. A theory $T$ *proves* $s$ if $\mathrm{base}(s)\subseteq C(T)$, and *covers* a corpus if it proves each of its statements.

**Definition 4.2 (Canonical library).** For a corpus $K$ inside a universe $U$, the canonical closure is $C_{\mathrm{can}} = \overline{\bigcup_{s\in K}\mathrm{base}(s)}$, and the canonical library is the theory with closure $C_{\mathrm{can}}$ proving $K$.

**Lemma 4.3 (Coverage).** The canonical library covers $K$.

*Proof sketch.* Each $\mathrm{base}(s)$ is contained in the union of the bases, which is contained in its own closure by Theorem 2.7(1). $\square$

**Lemma 4.4 (Universal embedding).** If $T$ has dependency-closed closure and covers $K$, then $C_{\mathrm{can}} \subseteq C(T)$.

*Proof sketch.* Coverage places the union of the bases inside $C(T)$; minimality (Theorem 2.7(4)) then places its closure inside $C(T)$. $\square$

**Theorem 4.5 (Dependency-adjusted global champion).** Fix a corpus $K$ with $|K|>0$ and suppose the canonical library has positive cost. Then for every theory $T$ with $P(T)=K$, dependency-closed closure, and covering $K$,
$$\mathrm{fit}_\ell(T)\;\le\;\mathrm{fit}_\ell(\text{canonical library}).$$

*Proof sketch.* Lemma 4.4 plus monotonicity gives the cost inequality; Theorem 3.1 inverts it. $\square$

The quantifier is worth emphasising: the comparison class here is not a finite tournament but the entire class of dependency-closed covering developments. Reuse wins for a structural reason — every rival must, by minimality of the closure, contain the shared core.

**Theorem 4.6 (Uniqueness up to cost).** Any covering, dependency-closed $T$ with $P(T)=K$ whose fitness is at least that of the canonical library has exactly the same cost as it.

*Proof sketch.* Combine the two inequalities from Theorem 4.5 and Theorem 3.1. $\square$

### 4.2 Alternative routes destroy canonicity

Theorem 4.5 depends essentially on there being *one* chosen proof per statement. The following minimal example shows the dependence is not an artefact of the proof.

**Theorem 4.7 (No canonical champion with two routes).** Consider the corpus $\{s\}$ with two developments, $R_1$ with closure $\{a\}$ and $R_2$ with closure $\{b\}$, $a \ne b$, all items of length $1$, both proving $s$. Then
$$\mathrm{fit}(R_1) = \mathrm{fit}(R_2) = 1, \quad C(R_1)\not\subseteq C(R_2), \quad C(R_2)\not\subseteq C(R_1), \quad C(R_1)\cap C(R_2)=\varnothing.$$

*Proof sketch.* Direct computation: both costs are $1$ and both corpora have one element; the closures are distinct singletons. $\square$

So the covering developments have no least element, the intersection of the two optima proves nothing, and the canonical construction has no analogue. What fails is uniqueness and canonicity — not existence.

**Definition 4.8 (Multi-route system).** A *multi-route proof system* assigns to each statement $s$ a finite family $\mathrm{routes}(s)$ of alternative proof bases. A collection $c$ *proves* $s$ if $r \subseteq c$ for some $r \in \mathrm{routes}(s)$, and *covers* a corpus if it proves each statement.

**Theorem 4.9 (Existence of a minimum-cost cover).** Let $U$ be a finite universe covering the corpus $K$. Then there is $c \subseteq U$ covering $K$ with $\sum_{x\in c}\ell(x) \le \sum_{x \in d}\ell(x)$ for every $d\subseteq U$ covering $K$.

*Proof sketch.* The covering subsets of $U$ form a nonempty finite family (it contains $U$); a finite nonempty family of naturals attains a minimum. $\square$

**Theorem 4.10 (Champion with alternative routes).** With $|K|>0$ and all covering subsets of positive cost, a minimum-cost cover is a fitness maximum among all covering subsets of $U$. By Theorem 4.7 it need not be unique.

The transition from Theorem 4.5 to Theorem 4.10 is a transition in *character*: from an optimum computable by a closure operation to an optimum determined by an optimisation over an exponential family — a weighted set-cover instance in disguise. This is the precise sense in which choice of proof route, not dependency structure, is what makes library optimisation hard.

---

## 5. Exact $k$-fold reuse accounting

**Setting.** Fix a finite index set $F$ of size $k$, a *core* set of items $\mathrm{core}$, and pairwise disjoint *private* sets $\mathrm{priv}(i)$, each disjoint from the core. The **shared library** has closure $\mathrm{core}\cup\bigcup_{i\in F}\mathrm{priv}(i)$; the **specialist** $i$ has closure $\mathrm{core}\cup\mathrm{priv}(i)$, having rebuilt the core privately. All prove the same corpus.

**Theorem 5.1 (Exact reuse identity).**
$$\Big(\sum_{x\in\, \mathrm{core}\cup\bigcup_i \mathrm{priv}(i)} \ell(x)\Big) \;+\; k\cdot\Big(\sum_{x\in \mathrm{core}}\ell(x)\Big) \;=\; \sum_{i\in F}\Big(\sum_{x\in \mathrm{core}\cup\mathrm{priv}(i)}\ell(x)\Big) \;+\; \sum_{x\in \mathrm{core}}\ell(x).$$

*Proof sketch.* By disjointness, the left-hand library sum splits as $\mathrm{core} + \sum_i \mathrm{priv}(i)$, and the right-hand specialist sum splits as $k\cdot\mathrm{core} + \sum_i \mathrm{priv}(i)$. Substituting and cancelling gives the identity. $\square$

Rearranged, the identity says the pooled suite of specialists costs exactly $(k-1)$ redundant copies of the core.

**Theorem 5.2 (Strict cost dominance).** If $k \ge 2$ and the core has positive cost, then
$$\mathrm{cost}_\ell(\text{shared library}) \;<\; \sum_{i\in F}\mathrm{cost}_\ell(\text{specialist } i).$$

*Proof sketch.* Immediate from Theorem 5.1: the deficit is $(k-1)\cdot\mathrm{cost}(\mathrm{core}) > 0$. $\square$

**Theorem 5.3 (Strict fitness dominance).** Under the same hypotheses, with a nonempty corpus,
$$\frac{|K|}{\sum_{i\in F}\mathrm{cost}_\ell(\text{specialist } i)} \;<\; \mathrm{fit}_\ell(\text{shared library}).$$

*Proof sketch.* Theorem 5.2 plus positivity of the library cost (the core sits inside its closure) plus Theorem 3.1. $\square$

Theorems 5.1–5.3 constitute the dependency-adjusted champion conjecture, proved outright with an exact formula for the saving, for the canonical comparison class *core plus private material*. The saving grows linearly in the number of clients; this is the formal explanation of why general libraries are net-negative at $k=1$ and decisively positive at large $k$.

---

## 6. The composition phase transition

### 6.1 The threshold

**Definition 6.1.** For theories $T,U$ and an adapter charge $A \in \mathbb{N}$:
- the **shared mass** is $S(T,U) = \sum_{i\in C(T)\cap C(U)}\ell(i)$;
- the **composed cost** is $\mathrm{cost}_\ell(T\sqcup U) + A$;
- the **duplicate cost** is $\mathrm{cost}_\ell(T)+\mathrm{cost}_\ell(U)$;
- **composed fitness** is $|P(T)\cup P(U)|$ over composed cost; **duplicated fitness** is $|P(T)\cup P(U)|$ over duplicate cost.

**Lemma 6.2.** $\text{composed cost} + S(T,U) = \text{duplicate cost} + A$.

*Proof sketch.* Add $A$ to both sides of Theorem 2.12. $\square$

**Theorem 6.3 (Composition trichotomy).** Assume the composite corpus is nonempty and both costs are positive. Then

- composition strictly increases fitness $\iff A < S(T,U)$;
- composition is fitness-neutral $\iff A = S(T,U)$;
- composition strictly decreases fitness $\iff A > S(T,U)$.

*Proof sketch.* With a common positive numerator, comparing the two fitnesses is comparing the two denominators in reverse (Theorem 3.1), and by Lemma 6.2 composed cost is below/equal/above duplicate cost exactly as $A$ is below/equal/above $S(T,U)$. $\square$

The threshold is sharp and sits at a directly measurable quantity: the total source length of what the two developments have in common.

**Definition 6.4 (Densities).** $\rho = S(T,U)/\text{duplicate cost}$ is the *dependency density* and $\alpha_A = A/\text{duplicate cost}$ the *adapter density*.

**Theorem 6.5 (Density form).** Under the hypotheses of Theorem 6.3, composition strictly increases fitness if and only if $\alpha_A < \rho$.

*Proof sketch.* Divide both sides of $A < S(T,U)$ by the positive duplicate cost. $\square$

Both densities are dimensionless and measurable on a real corpus, which makes the threshold empirically testable without fixing a unit of source length.

### 6.2 A computed instance

Take two developments with closures $\{0,1,2,3\}$ and $\{2,3,4,5\}$, proving corpora $\{0,1\}$ and $\{2,3\}$, with $\ell \equiv 10$. Then the shared mass is $20$, the duplicate cost is $80$, and the pooled cost is $60$.

- $A = 10 < 20$: fitness rises from $4/80 = 1/20$ to $4/70 = 2/35$.
- $A = 20$: fitness is unchanged at $4/80 = 1/20$.
- $A = 30 > 20$: fitness falls to $4/90 = 2/45$.

Both phases are realised and the crossing is exact.

### 6.3 Multiplicative candidate populations

When two theories genuinely interact, the composite proves not the union but the *product* of the two corpora. Write $\mathrm{fit}^\times = |P(T)|\cdot|P(U)| \,/\, \text{composed cost}$.

**Theorem 6.6 (Multiplicative criterion).** With $\mathrm{cost}_\ell(T)>0$ and positive composed cost,
$$\mathrm{fit}_\ell(T) < \mathrm{fit}^\times \iff |P(T)|\cdot\text{composed cost} \;<\; |P(T)|\cdot|P(U)|\cdot \mathrm{cost}_\ell(T).$$

**Theorem 6.7 (Multiplicative growth beats additive cost).** If $|P(T)|>0$ and
$$\mathrm{cost}_\ell(T)+\mathrm{cost}_\ell(U)+A \;<\; \mathrm{cost}_\ell(T)\cdot |P(U)|,$$
then $\mathrm{fit}_\ell(T) < \mathrm{fit}^\times$.

*Proof sketch.* By Corollary 2.13 the composed cost is at most $\mathrm{cost}(T)+\mathrm{cost}(U)+A$; multiply the hypothesis by $|P(T)|>0$ and chain the inequalities. $\square$

The content is a growth-rate contrast: costs add (at worst), candidates multiply. Any second component with sufficiently large corpus makes composition profitable whatever the adapter charge — but "sufficiently large" is quantified explicitly, and for small $|P(U)|$ the adapter can dominate.

---

## 7. Exact candidate counts

Theorem 6.7 presupposes that combining independent components multiplies the population of achievable results. That combinatorial premise can be verified exactly, in the natural setting where the "candidates" are the *usable sub-libraries*.

**Definition 7.1.** For a dependency structure $\mathrm{deps}$ and a universe $U$, let $\mathcal{N}(U)$ denote the family of subsets $s\subseteq U$ that are dependency-closed, and $N(U) = |\mathcal{N}(U)|$.

**Theorem 7.2 (Independent parts multiply).** Let $U = A\cup B$ with $A,B$ disjoint, $\mathrm{deps}(i)\subseteq A$ for $i\in A$ and $\mathrm{deps}(i)\subseteq B$ for $i\in B$. Then
$$N(A\cup B) = N(A)\cdot N(B).$$

*Proof sketch.* The map $s \mapsto (s\cap A,\, s\cap B)$ sends closed subsets of $A\cup B$ to pairs of closed subsets, and $(p,q)\mapsto p\cup q$ is a two-sided inverse: closedness of a union of closed sets is Lemma 2.3, $s = (s\cap A)\cup(s\cap B)$ since $s\subseteq A\cup B$, and disjointness gives $(p\cup q)\cap A = p$, $(p\cup q)\cap B = q$. A bijection between finite sets equates cardinalities. $\square$

Note this is an exact bijection, not an asymptotic estimate.

**Theorem 7.3 (Free extreme).** If $\mathrm{deps}(i)=\varnothing$ for all $i$, then $N(U) = 2^{|U|}$.

*Proof sketch.* Every subset is vacuously closed, so $\mathcal{N}(U)$ is the full power set. $\square$

**Theorem 7.4 (Rigid extreme).** Let $\mathrm{deps}(0)=\varnothing$ and $\mathrm{deps}(i)=\{i-1\}$ for $i \ge 1$, and let $U = \{0,1,\dots,n-1\}$. Then $N(U) = n+1$.

*Proof sketch.* A closed subset is downward closed: by induction on $d$, if $i \in s$ then $i - d\in s$, since either $i-d = 0$ or the closure condition supplies $(i-d)-1$. A downward-closed nonempty finite set of naturals is $\{0,\dots,m\}$ where $m$ is its maximum, hence an initial segment; the initial segments contained in $\{0,\dots,n-1\}$ are exactly $\varnothing,\{0\},\dots,\{0,\dots,n-1\}$, and the map $k \mapsto \{0,\dots,k-1\}$ is injective (cardinalities differ). There are $n+1$. $\square$

**Theorem 7.5 (Dependency density collapses the population).** For all $n \ge 2$, the chain has strictly fewer usable sub-libraries than the independent family: $n+1 < 2^n$.

*Proof sketch.* Induction from the base case $n=2$ ($3 < 4$), using $2^{m}+2^{m}=2^{m+1}$ and $2^m \ge 1$. $\square$

The interpretation is a genuine design trade-off, now stated in exact numbers. Dependencies are what enable reuse — they are the mechanism by which a core is shared. They are simultaneously what destroys modularity, since every dependency prunes the family of self-contained fragments that can be extracted and reused in isolation. Between $n+1$ and $2^n$ lies every real library, and the location within that range is a measurable structural invariant.

---

## 8. The shape of the landscape

### 8.1 Migration paths and boundary crossings

**Definition 8.1 (Development state).** A state $w$ of a migration is a triple $(\mathrm{len}(w), \mathrm{iface}(w), \mathrm{content}(w))$: its source length, an identifier for the principal abstraction layer it is written against, and the intrinsic size of the mathematical content it implements. A *migration path* is a finite walk $w_0,\dots,w_n$ in which each step is a bounded refactoring, and it is *semantics preserving* if $\mathrm{content}(w_i) = \mathrm{content}(w_0)$ for all $i \le n$.

**Theorem 8.2 (Boundary crossing).** If $\mathrm{iface}(w_0)\ne\mathrm{iface}(w_n)$ then there is $i<n$ with $\mathrm{iface}(w_i)\ne\mathrm{iface}(w_{i+1})$.

*Proof sketch.* Otherwise induction shows $\mathrm{iface}(w_k)=\mathrm{iface}(w_0)$ for all $k\le n$, contradicting the endpoint hypothesis at $k=n$. $\square$

Elementary, but it localises the phenomenon: the whole penalty can be attributed to a single, measurable class of transitions rather than to the path as a whole.

**Theorem 8.3 (Quantitative adapter valley).** Let $w_0,\dots,w_n$ be semantics preserving with content $C>0$, let $0\le\beta<\alpha$, and assume:

- $\mathrm{iface}(w_0)\ne\mathrm{iface}(w_n)$;
- **(adapter law)** any state $w_i$ from which the interface changes satisfies $\mathrm{len}(w_i) \ge (1+\alpha)C$;
- **(endpoint efficiency)** $\mathrm{len}(w_0) \le (1+\beta)C$.

Then there is $i \le n$ with
$$\mathrm{len}(w_i) - m \;\ge\; \frac{\alpha-\beta}{1+\beta}\, m, \qquad m := \min\{\mathrm{len}(w_0),\mathrm{len}(w_n)\}.$$

*Proof sketch.* Take the crossing index $i$ from Theorem 8.2. The adapter law gives $\mathrm{len}(w_i) \ge (1+\alpha)C$, while $m \le \mathrm{len}(w_0)\le (1+\beta)C$. Since $\frac{\alpha-\beta}{1+\beta}\ge 0$ and $1+\beta>0$,
$$\frac{\alpha-\beta}{1+\beta}\,m \;\le\; \frac{\alpha-\beta}{1+\beta}\,(1+\beta)C \;=\; (\alpha-\beta)C \;\le\; (1+\alpha)C - (1+\beta)C \;\le\; \mathrm{len}(w_i)-m.$$
(The degenerate case $m\le 0$ is immediate.) $\square$

**Corollary 8.4.** The guaranteed relative overshoot $(\alpha-\beta)/(1+\beta)$ is strictly positive whenever $0\le\beta<\alpha$.

The overshoot depends only on the two efficiency exponents — not on the length of the path, the size of the development, or the ingenuity of the refactoring. Since fitness is inverted cost (Theorem 3.1), a length barrier is a fitness valley: one cannot walk downhill in cost from one convention to another.

**Worked instance.** A two-step migration $w_0 = (110, \text{iface }0, 100)$, $w_1 = (150, \text{iface }0, 100)$, $w_2 = (110, \text{iface }1, 100)$, with $\alpha = 1/2$ and $\beta = 1/10$: the endpoints are $1.1$-efficient, the crossing state costs $1.5\times$ content, and the guaranteed relative overshoot is $(0.5-0.1)/1.1 = 4/11 \approx 36.4\%$. The realised overshoot at $w_1$ is $40/110 = 4/11$ — the bound is attained.

### 8.2 Metastability of methodological styles

**Definition 8.5.** Given a fitness function $\mathrm{fit}$ and a neighbourhood relation $\mathrm{adj}$, a state $b$ is a *strict local maximum* if $\mathrm{fit}(t) < \mathrm{fit}(b)$ for every $t \ne b$ with $\mathrm{adj}(b,t)$. Given a style map $\mathrm{style}$, $b$ is *style-optimal* if $\mathrm{fit}(t) < \mathrm{fit}(b)$ for every $t \ne b$ with $\mathrm{style}(t)=\mathrm{style}(b)$.

**Theorem 8.6 (Style-centre theorem).** If every bounded refactoring preserves style, and $b$ is style-optimal, then $b$ is a strict local maximum.

*Proof sketch.* A neighbour $t\ne b$ has the same style by hypothesis, so style-optimality applies. $\square$

**Theorem 8.7 (Quarantine form).** If $b$ is style-optimal and every cross-style neighbour of $b$ is strictly less fit, then $b$ is a strict local maximum.

*Proof sketch.* Split on whether a neighbour shares $b$'s style. $\square$

Theorem 8.7 is the realistic hypothesis: boundaries may be crossed, provided crossing hurts — which is exactly what Theorem 8.3 supplies.

**Theorem 8.8 (Renaming invariance).** Let $\sigma$ be a bijection of the state space with $\mathrm{fit}(\sigma x) = \mathrm{fit}(x)$ for all $x$ and $\mathrm{adj}(\sigma x, \sigma y) \Rightarrow \mathrm{adj}(x,y)$. If $b$ is a strict local maximum, so is $\sigma b$.

*Proof sketch.* For a neighbour $t$ of $\sigma b$ distinct from it, $\sigma^{-1}t$ is a neighbour of $b$ distinct from $b$, so $\mathrm{fit}(\sigma^{-1}t) < \mathrm{fit}(b)$; transporting along $\sigma$ gives $\mathrm{fit}(t) < \mathrm{fit}(\sigma b)$. $\square$

Hence strict local maximality descends to the quotient by semantics-preserving renaming: no peak is an artefact of notation.

**Theorem 8.9 (Three-style metastability).** Consider nine developments of a fixed corpus, three per style (algebraic, analytic, combinatorial), with fitnesses
$$\underbrace{1,\,2,\,5}_{\text{algebraic}} \mid \underbrace{3,\,7,\,4}_{\text{analytic}} \mid \underbrace{6,\,2,\,9}_{\text{combinatorial}},$$
and bounded refactorings connecting developments of the same style. Then the three stylewise maximisers (of fitness $5$, $7$, $9$) are three *distinct* strict local maxima, one per style; and $5 < 9$, $7 < 9$, so two of them are not global.

*Proof sketch.* Theorem 8.6 applies to each stylewise maximiser, style-optimality being a finite check within each block of three; the styles are distinct by construction, and the comparison of values is direct. $\square$

The landscape is genuinely multi-peaked: no path of small local improvements connects the algebraic peak to the strictly better combinatorial one. This is the formal image of the familiar situation in which two communities work on the same theorems with incompatible methodologies, each correctly observing that every small step towards the other makes matters worse.

---

## 9. No universal maximum without resource normalisation

All the preceding comparisons hold a corpus fixed. Dropping that hypothesis destroys the theory, and this section makes the destruction precise.

**Definition 9.1 (Theory language).** A *theory language* $L$ consists of a type of developments, functions $\mathrm{count}$ (number of corpus statements stated and proved) and $\mathrm{len}$ (source length) into $\mathbb{N}$, a semantics map into sets of statements, a marginal-cost function $\mathrm{marg}:\mathbb{N}\to\mathbb{N}$, and an inflation operator $\mathrm{ext}(T,n)$ satisfying:

1. $\mathrm{count}(\mathrm{ext}(T,n)) = \mathrm{count}(T)+n$;
2. $\mathrm{len}(\mathrm{ext}(T,n)) = \mathrm{len}(T)+\mathrm{marg}(n)$;
3. **(conservativity)** $\mathrm{semantics}(\mathrm{ext}(T,n)) = \mathrm{semantics}(T)$;
4. **(sublinearity)** for every rational $c>0$ there is $N$ with $\mathrm{marg}(n)\le c\,n$ for all $n\ge N$.

*Raw fitness* is $\mathrm{raw}(T) = \mathrm{count}(T)/\mathrm{len}(T)$.

Inflation is not a contrived operation: it is what happens whenever a general theorem is instantiated in many one-line special cases, each of which counts as a stated and proved consequence while adding no semantic content.

**Theorem 9.2 (Unboundedness).** If $\mathrm{len}(T_0)>0$ then for every $M\in\mathbb{Q}$ there is $n$ with $M < \mathrm{raw}(\mathrm{ext}(T_0,n))$.

*Proof sketch.* It suffices to treat $M>0$. Sublinearity with rate $c = 1/(2M)$ yields $N$ with $\mathrm{marg}(n) \le n/(2M)$ for $n\ge N$; choose also $k$ with $k > 2M\,\mathrm{len}(T_0)$ and take $n > \max(N,k)$. Then
$$M\big(\mathrm{len}(T_0)+\mathrm{marg}(n)\big) \le M\,\mathrm{len}(T_0) + \tfrac{n}{2} < \tfrac{n}{2}+\tfrac{n}{2} = n \le \mathrm{count}(T_0)+n,$$
which is exactly $M < \mathrm{raw}(\mathrm{ext}(T_0,n))$ after clearing the positive denominator. $\square$

**Theorem 9.3 (No global maximum).** If some development has positive length, there is no $T$ with $\mathrm{raw}(U)\le\mathrm{raw}(T)$ for all $U$.

*Proof sketch.* Any candidate maximum is exceeded by a sufficiently large inflation of the positive-length development (Theorem 9.2). $\square$

**Theorem 9.4 (Semantic inertness of the witnesses).** For every $M$ there is $n$ with $M < \mathrm{raw}(\mathrm{ext}(T_0,n))$ and $\mathrm{semantics}(\mathrm{ext}(T_0,n)) = \mathrm{semantics}(T_0)$.

*Proof sketch.* Theorem 9.2 plus conservativity. $\square$

This is the decisive point. The unbounded family records no mathematical progress whatever: every record-breaking development means exactly what its predecessor meant. Raw fitness diverges while the mathematics stands still, which shows that unnormalised theorem-per-line is not merely maximum-free but *meaningless as a measure of value*.

**Theorem 9.5 (Sharp dichotomy).** Raw fitness attains a maximum on every nonempty finite comparison class, and on no theory language of the above kind does it attain a global maximum.

*Proof sketch.* Theorem 3.2 and Theorem 9.3. $\square$

**Theorem 9.6 (Non-vacuity).** The hypotheses are satisfiable. Take developments to be pairs $(\mathrm{count},\mathrm{len})\in\mathbb{N}^2$, semantics constant, $\mathrm{marg}(n) = \lfloor\sqrt{n}\rfloor$, and $\mathrm{ext}((a,b),n)=(a+n, b+\lfloor\sqrt{n}\rfloor)$. Then $\lfloor\sqrt{n}\rfloor$ is sublinear — given $c>0$ pick $k>1/c$; for $n>k^2$ we have $\lfloor\sqrt n\rfloor \ge k$, hence $c\lfloor\sqrt n\rfloor > 1$ and $\lfloor\sqrt n\rfloor \le c\lfloor\sqrt n\rfloor^2 \le c\,n$ — and this language has no fitness champion.

---

## 10. Algorithms

The results above are constructive and yield direct algorithms on measured data.

**Algorithm A (Transitive closure and cost).** Given $\mathrm{deps}$, a base $B$ and a universe $U$: iterate $S \leftarrow S\cup\bigcup_{i\in S}\mathrm{deps}(i)$ from $S = B$ until $S$ stops growing (at most $|U|$ rounds; a worklist implementation runs in $O(|U| + E)$ where $E$ is the number of dependency edges). Return $\sum_{i\in S}\ell(i)$. By Theorem 2.7 the output is the least dependency-closed superset of $B$, hence the canonical dependency-adjusted cost.

**Algorithm B (Champion by cost).** Given competitors on a fixed corpus, compute Algorithm A for each and return an argmin. By Theorems 3.1 and 3.4 this returns a fitness champion. Cost: one closure computation per competitor.

**Algorithm C (Composition threshold).** Compute the two closures, their intersection mass $S(T,U)$, and compare with the adapter charge $A$. By Theorem 6.3 the sign of $S(T,U) - A$ is exactly the sign of the fitness change. $O(|C(T)|+|C(U)|)$ with hashing.

**Algorithm D (Counting usable sub-libraries).** Decompose the dependency graph into weakly connected components; by Theorem 7.2 the count is the product over components. Within a component, count dependency-closed subsets by dynamic programming over a topological order (equivalently, count antichains/order ideals of the induced preorder). The two extremes $2^n$ and $n+1$ (Theorems 7.3, 7.4) serve as sanity checks and as the bracketing bounds for any real library.

**Algorithm E (Minimum-cost cover under multiple routes).** Given routes per statement, search for a minimum-cost covering subset — by Theorem 4.9 the minimum is attained. Exhaustive search over closed subsets is exponential; the canonical-closure heuristic (take the union of the cheapest single route per statement and close it) is a natural approximation, and by Theorem 4.7 no closure-based procedure can be exact in general.

---

## 11. Applications and interpretation

**Library design.** Theorem 5.1 quantifies the break-even point of factoring out a core: the suite of $k$ specialists wastes exactly $(k-1)$ copies of it. A core of size $s$ shared by $k$ clients saves $(k-1)s$; this should be compared against the abstraction overhead, and the comparison is a comparison of measured integers, not of aesthetics.

**Merger decisions.** Theorem 6.3 makes the decision to unify two developments a single measurement: compute the shared mass, estimate the adapter, compare. Theorem 6.5 restates this scale-free, so the criterion transfers between projects of different sizes.

**Modularity audits.** Theorem 7.5 gives a diagnostic. A development whose usable-sub-library count is near $n+1$ is a monolith: nothing can be extracted. Near $2^n$ it is fully modular but shares nothing. The count computed by Algorithm D locates a real project on this axis.

**Migration planning.** Theorem 8.3 predicts a *guaranteed* transient bloat of $(\alpha-\beta)/(1+\beta)$ during any interface migration, from two exponents that can be estimated in advance. Projects that abandon a migration midway are not necessarily mismanaged; they may be observing an unavoidable valley.

**Methodological pluralism.** Theorem 8.9 explains the empirical persistence of incompatible methodologies as metastability rather than error. Because Theorem 8.8 makes local maximality renaming-invariant, this cannot be dismissed as notational accident.

**Evaluation of formal or automated output.** Theorem 9.4 is a warning about metrics. Any measure of the form "results per unit effort", applied without fixing a corpus, can be driven to infinity by conservative inflation while producing no new mathematics. Fixing the corpus, the dependency accounting, and a bounded universe is not a technicality; by Theorem 9.5 it is the entire content of the assertion that a best theory exists.

---

## 12. Discussion

Three structural observations emerge.

**Accounting is easy; choice is hard.** Every result that came out exact — closure minimality, the merge identity, the reuse identity, the composition threshold, the counts $2^n$ and $n+1$ — is an accounting result: it determines what the numbers must be given the model. Every difficulty encountered concerns *choice*: which proof route (Theorem 4.7), which interface (Theorem 8.3), which style (Theorem 8.9). The boundary between the tractable and the intractable in this subject is exactly the boundary between bookkeeping and decision.

**Canonicity is fragile, existence is robust.** The canonical champion (Theorem 4.5) is a strong theorem with a brittle hypothesis. One extra proof route destroys it (Theorem 4.7); yet the minimum-cost cover survives (Theorem 4.10). What is lost is not the answer but the *method* of obtaining it: a closure computation becomes a combinatorial optimisation.

**Normalisation is the whole game.** The finite maximum principle (Theorem 3.2) and the non-existence result (Theorem 9.3) bracket the subject from both sides. Between them, the assertion "there is a best theory" is neither true nor false in general; it is true exactly to the extent that the comparison class has been normalised. This turns a vague universality claim into a sharp, falsifiable dichotomy.

**Limitations.** Source length is a crude proxy for cost, ignoring conceptual difficulty and reading effort; the model charges a hundred routine lines as much as a hundred subtle ones. Theorem counts are a crude proxy for value; the corpus mechanism handles this only by fiat. The adapter law of Theorem 8.3 is a hypothesis, not a theorem — the result derives the valley *given* the law, and validating the law on real corpora is empirical work. Finally, the multi-route model treats route sets as given, whereas in practice discovering a cheap route is itself the expensive activity.

---

## 13. Future directions

**Canonicity gap (route-choice hardness).** In the fixed-route model the champion is the canonical closure. Conjecture: with $r\ge 2$ alternative routes per statement, deciding whether a corpus admits a covering library of dependency-adjusted cost $\le B$ is NP-complete, and the gap between the canonical-closure heuristic and the true optimum is $\Theta(\log|\mathrm{corpus}|)$ in the worst case. The two cost-equal covering closures with empty intersection of Theorem 4.7 are the exact obstruction: the covering problem loses its least element the moment routes branch, and what remains is a weighted set-cover instance in disguise. Existence is not at risk (Theorem 4.10), so the open content is precisely the complexity of finding the optimum. This is attractive now because the fixed-route case is fully settled, leaving a finite, mechanically extractable combinatorial object.

**Sharp reuse threshold for realistic cost models.** The threshold $A \lessgtr S(T,U)$ of Theorem 6.3 assumes an additive adapter charge. Conjecture: for any subadditive adapter cost $A(s)\le c\,s^{\theta}$ with $\theta<1$, composing $k$ libraries of shared density $\rho$ increases fitness for all $k \ge k_0(\rho,\theta)$ with $k_0 = O(\rho^{-1/(1-\theta)})$, and this exponent is optimal. The exact identity of Theorem 5.1 makes the saving grow linearly in $k$ while a subadditive adapter grows sublinearly, so the crossing point is determined by a single exponent rather than by the libraries' contents. Both sides are already exactly computable, so the conjecture reduces to fitting $\theta$ on measured adapter sizes.

**Universality of quantitative adapter valleys.** Theorem 8.3 derives the relative overshoot $(\alpha-\beta)/(1+\beta)$ from an assumed adapter law. Conjecture: in any real corpus the adapter law holds with $\alpha\ge 1/4$ and endpoint efficiency $\beta\le 1/10$, so every semantics-preserving migration across an interface boundary incurs an overshoot of at least $(1/4-1/10)/(11/10) = 3/22$, roughly $14\%$. Theorem 8.2 reduces this to measuring a single class of cross-interface transitions rather than all intermediate states.

**Dependency-adjusted global champion, empirical form.** Theorems 3.3 and 4.5 identify exactly what remains empirical: a fixed comparison class, a reproducible cost model, and complete theorem-coverage measurements. The conjecture that a mature shared library maximises dependency-adjusted fitness among all developments proving a given corpus is now a measurement programme rather than a slogan.

**Three-style metastability, empirical form.** Theorem 8.9 realises three distinct strict local maxima in a computed landscape. The conjecture is that in a migration graph built from bounded refactorings of a real corpus, algebraic, analytic, and combinatorial developments each contain a distinct strict local maximum after quotienting by semantics-preserving renaming. Theorems 8.6–8.8 separate the two required conditions — stylewise efficiency and rarely-crossing neighbourhoods — making each independently measurable and falsifiable on a finite corpus.

**Beyond source length.** Replacing $\ell$ by a cost model sensitive to conceptual depth (proof-term size, elaboration time, reader-effort estimates) leaves all the ordinal results of §3 intact, since they use only positivity and additivity. Which of §§5–7 survive a non-additive cost is open.

---

## 14. Conclusion

Fixing a finite corpus, a source-length function, and a transitive dependency closure charged exactly once produces a cost model in which the folklore of mathematical library design becomes provable or refutable. Within it: the shared core is the champion, canonically so for a fixed proof system and only up to cost ties otherwise; reuse saves exactly $(k-1)$ copies of the core; composition pays exactly when the adapter is cheaper than the shared mass; usable sub-libraries number between $n+1$ and $2^n$ with independent parts multiplying exactly; interface migrations must climb a valley of guaranteed relative depth $(\alpha-\beta)/(1+\beta)$; methodological styles can be genuinely metastable; and, without normalisation, there is no champion at all — for the decisive reason that theorem-per-line can be inflated arbitrarily without proving anything new.

The last result is the one to remember. A best theory exists only relative to a fixed question. Ask what mathematics is *for*, and the landscape has peaks. Ask only how much of it there is, and the landscape has no summit — only an infinite, empty ascent.
