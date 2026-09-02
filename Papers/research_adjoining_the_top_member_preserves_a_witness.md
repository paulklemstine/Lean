# Surplus Calculus for Union-Closed Families: Adjoining the Top, Averaging Criteria, and a Sharp Local Degree Law

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

Let $F$ be a finite family of finite subsets of a set $\alpha$, let $\deg_F(x)$ denote the number of members of $F$ containing $x$, and call $x$ *abundant* in $F$ when $|F| \le 2\deg_F(x)$. Abundance is the notion appearing in Frankl's union-closed sets conjecture. We study the operation $F \mapsto F^{+} := F \cup \{\bigvee F\}$ of adjoining the *top* $\bigvee F = \bigcup_{A \in F} A$, the first step of the union closure, and we develop an exact accounting — the *surplus calculus* — for how such adjunctions move the abundance threshold.

Our results are of four kinds. (i) **Transport.** If $x$ is abundant in $F$ and $x \in \bigvee F$, then $x$ is abundant in $F^{+}$; the surplus $\sigma_F(x) = 2\deg_F(x) - |F|$ increases by exactly $1$ when the top is new. The parity of $|F|$ is not an obstruction (it yields a free strengthening instead), and the exact boundary is degeneracy: for an abundant $x$, abundance survives adjoining the top **iff** $F \ne \varnothing$, with $F = \varnothing$ the unique counterexample. The hypothesis that the adjoined set contains $x$ is sharp, and one step further — pairwise completion or the full closure — abundance can be destroyed. (ii) **Creation.** Via the double count $\sum_{x \in s}\deg_F(x) = \sum_{A \in F}|A|$, an averaging hypothesis $|s|\,|F| \le 2\sum_{A\in F}|A|$ on a nonempty ground set $s$ containing all members forces some element of $s$ to be abundant — with no union-closedness assumed. This criterion is itself preserved by adjoining the top, so the local and global mechanisms agree; and the operation strictly increases the rational density $\deg_F(x)/|F|$ whenever the top is new and $x$ misses some member. (iii) **A sharp local law.** For union-closed $F$ with $a \in A \in F$, $|F| \le (2^{|A|-1}+1)\deg_F(a)$, and the constant is attained for every $|A|$ by the family consisting of all subsets of $A\setminus\{a\}$ together with $A$. Consequently no argument using a *single* member of size $\ge 2$ can prove Frankl's conjecture. (iv) **Unconditional cases and certificates.** Frankl's conjecture is proved here for families containing a singleton, families containing a pair, chains of arbitrary length, families with at most four members, families satisfying the averaging criterion, and all families over a three-element ground set. Existence of an abundant element in a nonempty ground set $s$ is equivalent to the single numerical test $|F| \le 2\max_{x\in s}\deg_F(x)$, a certificate that adjoining the top improves monotonically.

**Keywords:** union-closed families, Frankl's conjecture, abundant element, surplus, double counting, averaging criterion, union closure, extremal family.

---

## 1. Introduction

### 1.1 Frankl's conjecture

A finite family $F$ of finite sets is **union-closed** if $A \cup B \in F$ whenever $A, B \in F$. In 1979 Péter Frankl conjectured:

> If a union-closed family has at least one nonempty member, then some element of the ground set belongs to at least half of the members of the family.

Despite its elementary statement the conjecture is open. Much of what is known consists of unconditional special cases (small families, families containing small members, families over small ground sets) and of asymptotic results bounding the best guaranteed fraction away from $0$.

The present work does not resolve the conjecture. Instead it studies, exactly and completely, one primitive operation on families — adjoining the top — and extracts from it a bookkeeping device that (a) explains why that operation is always safe, (b) predicts precisely when larger closure steps are dangerous, and (c) interacts consistently with a global averaging criterion for the existence of abundant elements. We also prove a *sharp* local degree law that rules out an entire family of proof strategies.

### 1.2 Conventions

Throughout, $\alpha$ is a type (equivalently, a ground universe) with decidable equality, and a *family* is a finite set $F$ of finite subsets of $\alpha$. We write $|F|$ for the number of members and $|A|$ for the cardinality of a member. All sums are finite.

---

## 2. Definitions

**Definition 2.1 (Degree).** For a family $F$ and an element $x$,
$$\deg_F(x) := \#\{A \in F : x \in A\}.$$

**Definition 2.2 (Abundance).** An element $x$ is **abundant** in $F$ if
$$|F| \le 2\deg_F(x).$$
Equivalently, $x$ lies in at least half of the members of $F$. Note that every $x$ is (vacuously) abundant in the empty family.

**Definition 2.3 (Top).** The **top** of $F$ is $\bigvee F := \bigcup_{A \in F} A$, the union of all members. Every member is contained in the top, and $x \in \bigvee F$ iff $x \in A$ for some $A \in F$.

**Definition 2.4 (Adjoining the top).** $F^{+} := F \cup \{\bigvee F\}$.

**Definition 2.5 (Surplus).** The **surplus** of $x$ in $F$ is the integer
$$\sigma_F(x) := 2\deg_F(x) - |F| \in \mathbb{Z}.$$

**Definition 2.6 (Union closure).** The **union closure** $\mathrm{ucl}(F)$ is the family of all unions $\bigvee S$ over nonempty subfamilies $S \subseteq F$.

**Definition 2.7 (Pairwise completion).** $\mathrm{pu}(F) := F \cup \{A \cup B : A, B \in F\}$.

**Definition 2.8 (Total size).** $T(F) := \sum_{A \in F} |A|$, the number of incidences $(x, A)$ with $x \in A \in F$.

**Definition 2.9 (Density).** For $F \ne \varnothing$, the **density** of $x$ is the rational number $d_F(x) := \deg_F(x)/|F| \in [0,1]$.

Two immediate facts are used constantly: $\deg_F(x) \le |F|$, and the members containing $x$ together with the members avoiding $x$ partition $F$, so
$$\deg_F(x) + \#\{A \in F : x \notin A\} = |F|. \tag{2.1}$$

**Proposition 2.10 (Abundance as a sign condition).** $x$ is abundant in $F$ if and only if $\sigma_F(x) \ge 0$.

*Proof.* Immediate from the definitions, casting the inequality $|F| \le 2\deg_F(x)$ between $\mathbb{N}$ and $\mathbb{Z}$. $\square$

---

## 3. The surplus calculus

The engine of the paper is a two-line observation about how a single adjunction moves the surplus.

**Lemma 3.1 (Unit steps).** Let $A \notin F$.
1. If $x \in A$ then $\sigma_{F \cup \{A\}}(x) = \sigma_F(x) + 1$.
2. If $x \notin A$ then $\sigma_{F \cup \{A\}}(x) = \sigma_F(x) - 1$.

*Proof.* In case 1, both $|F|$ and $\deg_F(x)$ increase by exactly $1$ (the new member is counted once in the family and once in the filter of members containing $x$, and it is new in both), so $\sigma$ changes by $2 \cdot 1 - 1 = +1$. In case 2, $|F|$ increases by $1$ and the degree is unchanged, so $\sigma$ changes by $-1$. $\square$

This is the **two-versus-one accounting**: a new member is charged once against the family size but twice in favour of the degree, provided it contains $x$.

**Lemma 3.2 (Additivity over disjoint batches).** If $F$ and $G$ are disjoint families then
$$\deg_{F \cup G}(x) = \deg_F(x) + \deg_G(x), \qquad \sigma_{F\cup G}(x) = \sigma_F(x) + \sigma_G(x).$$

*Proof.* Filtering commutes with disjoint union and cardinality is additive on disjoint unions; the surplus identity follows by linearity. $\square$

**Corollary 3.3 (Batch stability).** Let $F$ and $G$ be disjoint. If $x$ is abundant in $F$ and $\sigma_G(x) \ge 0$ — i.e. at least half of the sets in the batch $G$ contain $x$ — then $x$ is abundant in $F \cup G$.

*Proof.* By Proposition 2.10 and Lemma 3.2, $\sigma_{F \cup G}(x) = \sigma_F(x) + \sigma_G(x) \ge 0$. $\square$

For singleton batches, $\sigma_{\{A\}}(x) = +1$ if $x \in A$ and $-1$ otherwise. Adjoining the top is the batch of size one with surplus $+1$; this single sentence contains the main theorem of Section 4 and the counterexamples of Section 5.

---

## 4. Adjoining the top

**Lemma 4.1 (The top is stable).** $\bigvee F^{+} = \bigvee F$, and $(F^{+})^{+} = F^{+}$; moreover $F \subseteq F^{+}$ and $F^{+} \ne \varnothing$ always.

*Proof.* $\bigvee(F \cup \{\bigvee F\}) = (\bigvee F) \cup (\bigvee F) = \bigvee F$; idempotence follows since the top of $F^{+}$ is already a member of $F^{+}$. Nonemptiness holds since $\bigvee F \in F^{+}$ even when $F = \varnothing$ (then $F^{+} = \{\varnothing\}$). $\square$

**Lemma 4.2 (Union-closed families own their top).** If $F$ is union-closed and $S \subseteq F$ is nonempty then $\bigvee S \in F$. In particular a nonempty union-closed family satisfies $F^{+} = F$.

*Proof.* Induction on the nonempty finite subfamily $S$: for a singleton $\{A\}$ the union is $A \in F$; for $S = \{A\} \sqcup S'$ we have $\bigvee S = A \cup \bigvee S' \in F$ by the inductive hypothesis and union-closedness. Applying this with $S = F$ gives $\bigvee F \in F$, hence $F^{+} = F$. $\square$

So adjoining the top is a genuine one-step move toward the union closure: it does nothing exactly on families that already contain their top.

**Lemma 4.3 (Redundancy of the membership hypothesis).** If $F$ is nonempty and $x$ is abundant in $F$, then $x \in \bigvee F$.

*Proof.* $|F| \ge 1$ and $|F| \le 2\deg_F(x)$ force $\deg_F(x) \ge 1$, so some member contains $x$, so $x$ lies in the union of all members. $\square$

**Theorem 4.4 (Main theorem: adjoining the top preserves a witness).** *Let $x$ be abundant in $F$ with $x \in \bigvee F$. Then $x$ is abundant in $F^{+}$. Moreover, if $\bigvee F \notin F$ then*
$$\sigma_{F^{+}}(x) = \sigma_F(x) + 1.$$

*Proof.* If $\bigvee F \in F$ then $F^{+} = F$ and there is nothing to prove. Otherwise apply Lemma 3.1(1) with $A = \bigvee F$, which contains $x$ by hypothesis: the surplus rises by $1$, and a nonnegative surplus stays nonnegative. $\square$

**Corollary 4.5.** If $F$ is nonempty and $x$ is abundant in $F$, then $x$ is abundant in $F^{+}$ (Lemma 4.3 supplies the membership hypothesis). More generally, adjoining *any* set containing $x$ preserves the abundance of $x$.

**Theorem 4.6 (Exact boundary).** *Let $x$ be abundant in $F$. Then*
$$x \text{ is abundant in } F^{+} \iff F \ne \varnothing.$$

*Proof.* ($\Leftarrow$) is Corollary 4.5. ($\Rightarrow$): if $F = \varnothing$ then $\bigvee F = \varnothing$ and $F^{+} = \{\varnothing\}$, a one-member family whose unique member contains nothing; then $|F^{+}| = 1 > 0 = 2\deg_{F^{+}}(x)$, so $x$ is not abundant. $\square$

Thus $F = \varnothing$ is the unique counterexample to the unguarded claim, and **nonemptiness is exactly the additional hypothesis required**. (Every element is abundant in $\varnothing$ vacuously; the operation destroys all of them at once.)

**Theorem 4.7 (Parity is a bonus, not an obstruction).** *If $|F|$ is odd and $x$ is abundant in $F$, then in fact $|F| + 1 \le 2\deg_F(x)$: abundance on odd families is automatically strict.*

*Proof.* Write $|F| = 2k+1$. Then $2k+1 \le 2\deg_F(x)$ with the right side even forces $2k + 2 \le 2\deg_F(x)$. $\square$

The heuristic that a threshold condition of the form $|F| \le 2\deg$ should be parity-sensitive is therefore precisely inverted: odd families carry a unit of slack, and the adjunction adds a further unit to the surplus. Monotonicity holds in general:

**Proposition 4.8.** If $x \in \bigvee F$ then $\sigma_F(x) \le \sigma_{F^{+}}(x)$.

### 4.1 Sharpness of the hypotheses

**Proposition 4.9 (The adjoined set must contain $x$).** *There are a family $F$, a set $A$ and an element $x$ with $x$ abundant in $F$, $x \notin A$, and $x$ not abundant in $F \cup \{A\}$.*

*Proof.* Over the ground set $\{0,1\}$ take $F = \{\varnothing, \{0\}\}$, $A = \{1\}$, $x = 0$. Then $|F| = 2$, $\deg_F(0) = 1$, so $x$ is abundant on the nose ($\sigma = 0$). After adjoining $A$: $|F \cup \{A\}| = 3$ and $\deg = 1$, so $\sigma = -1 < 0$. $\square$

This matches Lemma 3.1(2) exactly: a bad set costs one unit.

---

## 5. One step further: pairwise completion and the closure

**Proposition 5.1 (Closure basics).** $\mathrm{ucl}(F)$ is union-closed, contains $F$, and is contained in every union-closed family containing $F$; hence it is the least union-closed family containing $F$, and $\mathrm{ucl}(F) = F$ iff $F$ is union-closed. Moreover if $F \ne \varnothing$ then $\bigvee F \in \mathrm{ucl}(F)$, so $F^{+} \subseteq \mathrm{ucl}(F)$; and $\mathrm{pu}(F) \subseteq \mathrm{ucl}(F)$, with $\mathrm{pu}(F) = F$ iff $F$ is union-closed.

*Proof sketch.* Members of $\mathrm{ucl}(F)$ are the sups $\bigvee S$ of nonempty $S \subseteq F$; the union of two such is $\bigvee(S \cup T)$, giving union-closedness. Each $A \in F$ is $\bigvee\{A\}$. Minimality is Lemma 4.2 applied to any union-closed $G \supseteq F$. The statements about $\mathrm{pu}$ are direct. $\square$

**Theorem 5.2 (The boundary is sharp at one set).** *There exist a nonempty family $F$ and an element $x$ such that $x$ is abundant in $F$ and in $F^{+}$, but not in $\mathrm{pu}(F)$ and not in $\mathrm{ucl}(F)$.*

*Proof.* Over the ground set $\{0,1,2\}$ take
$$F = \{\{0,1,2\},\ \{0,1\},\ \{1\},\ \{2\}\}, \qquad x = 0 .$$
Then $|F| = 4$ and $\deg_F(0) = 2$, so $\sigma_F(0) = 0$ and $x$ is abundant. The top $\{0,1,2\}$ is already a member, so $F^{+} = F$. One pairwise step adds $\{1\}\cup\{2\} = \{1,2\}$, a set avoiding $0$: now $|{\mathrm{pu}(F)}| = 5$ with $\deg = 2$, so $\sigma = -1$. The full closure is $\{\{1\},\{2\},\{1,2\},\{0,1\},\{0,1,2\}\}$, with $5$ members of which $2$ contain $0$. $\square$

This is the structural reason Frankl's conjecture is difficult: **abundance is not monotone along the closure**. Each adjunction is worth exactly $\pm 1$ to a fixed element, and the closure interleaves good and bad steps; the conjecture asserts something about the endpoint that no step-by-step monotonicity can supply.

---

## 6. Creating abundance: double counting and an averaging criterion

**Theorem 6.1 (Double counting).** *Let $s$ be a finite set with $A \subseteq s$ for every $A \in F$. Then*
$$\sum_{x \in s} \deg_F(x) = \sum_{A \in F} |A| = T(F).$$

*Proof.* Write $\deg_F(x) = \sum_{A \in F} [\![x \in A]\!]$ and exchange the order of summation: $\sum_{x\in s}\sum_{A\in F}[\![x \in A]\!] = \sum_{A \in F} \#(A \cap s) = \sum_{A\in F}|A|$, using $A \subseteq s$. $\square$

Taking $s = \bigvee F$, which contains every member, gives $\sum_{x \in \bigvee F}\deg_F(x) = T(F)$ unconditionally.

**Theorem 6.2 (Averaging criterion).** *Let $s$ be nonempty with $A \subseteq s$ for all $A \in F$, and suppose*
$$|s| \cdot |F| \le 2\,T(F).$$
*Then some $x \in s$ is abundant in $F$. No union-closedness is assumed.*

*Proof.* Suppose not: $2\deg_F(x) < |F|$ for every $x \in s$. Summing this strict inequality over the nonempty index set $s$ gives
$$2\sum_{x \in s}\deg_F(x) < |s| \cdot |F|,$$
and the left-hand side equals $2T(F)$ by Theorem 6.1, contradicting the hypothesis. $\square$

The hypothesis says exactly that the members of $F$ have average size at least $|s|/2$. Nonemptiness of $s$ is essential (for $s = \varnothing$ the conclusion is unsatisfiable while the hypothesis $0 \le 2T$ is automatic). On the canonical ground set the criterion reads
$$|{\textstyle\bigvee F}| \cdot |F| \le 2\,T(F) \implies \exists\, x \in {\textstyle\bigvee F} \text{ abundant in } F. \tag{6.1}$$

**Proposition 6.3 (Sufficient but not necessary).** *There is a union-closed family with an abundant element in its top that violates the averaging hypothesis.*

*Proof.* $F = \{\varnothing, \{0\}, \{1\}, \{0,1\}, \{0,1,2\}\}$ over $\{0,1,2\}$ is union-closed with $|F| = 5$, $\bigvee F = \{0,1,2\}$, and $\deg_F(0) = 3 \ge 5/2$, so $0$ is abundant. But $T(F) = 0+1+1+2+3 = 7$ and $|\bigvee F|\cdot|F| = 15 > 14 = 2T(F)$. $\square$

So the criterion is a genuine implication, not a characterisation: sparse union-closed families may still have abundant elements that averaging cannot detect. In particular Theorem 6.2 cannot prove Frankl's conjecture — the union-closed family $\{\varnothing, \{0\}\}$ already has average member size below half its top.

### 6.1 Stability of the criterion under adjoining the top

**Lemma 6.4.** If $\bigvee F \notin F$ then $T(F^{+}) = T(F) + |\bigvee F|$ and $|F^{+}| = |F| + 1$.

**Theorem 6.5 (The averaging hypothesis survives the operation).** *If $|\bigvee F| \cdot |F| \le 2T(F)$, then*
$$|{\textstyle\bigvee F^{+}}| \cdot |F^{+}| \le 2\,T(F^{+}).$$

*Proof.* By Lemma 4.1 the top is unchanged; write $m := |\bigvee F|$. If $\bigvee F \in F$ then $F^{+} = F$ and the claim is the hypothesis. Otherwise, by Lemma 6.4 the desired inequality is $m(|F|+1) \le 2T(F) + 2m$, i.e. $m|F| + m \le 2T(F) + 2m$, which follows from the hypothesis $m|F| \le 2T(F)$ together with $m \le 2m$. $\square$

The operation therefore preserves not merely one witness (Theorem 4.4) but the **global hypothesis that manufactures witnesses**. The two mechanisms are consistent, as they must be: adjoining the top adds one row to the incidence matrix which is maximal in every column indexed by the top, so both the row statistic (member size) and the column statistics (degrees) move in the favourable direction.

**Corollary 6.6.** If $\bigvee F$ is nonempty and $|\bigvee F|\cdot|F| \le 2T(F)$, then some $x \in \bigvee F$ is abundant in $F^{+}$ — obtainable either by transporting the witness of Theorem 6.2 through Theorem 4.4, or by applying Theorem 6.2 to $F^{+}$ via Theorem 6.5.

### 6.2 Strict improvement of density

**Theorem 6.7 (Adjoining a new top strictly increases density).** *Suppose $F \ne \varnothing$, $\bigvee F \notin F$, $x \in \bigvee F$, and $\deg_F(x) < |F|$. Then*
$$\frac{\deg_F(x)}{|F|} \;<\; \frac{\deg_{F^{+}}(x)}{|F^{+}|}.$$

*Proof.* Write $d = \deg_F(x)$, $n = |F| > 0$. Then $\deg_{F^{+}}(x) = d+1$ and $|F^{+}| = n+1$. Cross-multiplying (both denominators positive), the claim $d/n < (d+1)/(n+1)$ is equivalent to $d(n+1) < n(d+1)$, i.e. $d < n$, which is the hypothesis. $\square$

The excluded case is exactly the trivial one: if $\deg_F(x) = |F|$ the density is already $1$ and cannot increase. So the operation is not merely non-harmful but strictly beneficial whenever there is room to improve — a refinement of the integer statement "$\sigma$ increases by $1$" to the scale-free statistic.

---

## 7. A sharp local degree law

We now bound the degree of an element from below using a *single* member of a union-closed family, and show the bound is optimal.

**Theorem 7.1 (Fibre bound).** *Let $F$ be union-closed, $A \in F$ and $a \in A$. Then*
$$\#\{B \in F : a \notin B\} \;\le\; 2^{|A| - 1}\,\deg_F(a).$$

*Proof.* Let $G := \{B \in F : a \notin B\}$ and consider $\varphi : G \to F$, $\varphi(B) = B \cup A$. Since $F$ is union-closed, $\varphi(B) \in F$; and $a \in A \subseteq \varphi(B)$, so $\varphi(G) \subseteq \{C \in F : a \in C\}$, whence $|\varphi(G)| \le \deg_F(a)$.

It remains to bound the fibres. Fix $C \in \varphi(G)$ and consider $B \in G$ with $B \cup A = C$. The map $B \mapsto B \cap A$ is injective on this fibre: indeed $B = (C \setminus A) \cup (B \cap A)$, since every element of $B$ either lies outside $A$ — and then lies in $C \setminus A$ — or lies in $B \cap A$; conversely $C \setminus A \subseteq B$ because $C = B \cup A$. And $B \cap A \subseteq A \setminus \{a\}$ because $a \notin B$. Hence each fibre injects into the power set of $A \setminus\{a\}$, of size $2^{|A|-1}$.

Combining, $|G| \le 2^{|A|-1}\,|\varphi(G)| \le 2^{|A|-1}\deg_F(a)$. $\square$

**Theorem 7.2 (Local degree bound).** *Let $F$ be union-closed, $A \in F$, $a \in A$. Then*
$$|F| \;\le\; \bigl(2^{|A|-1} + 1\bigr)\deg_F(a).$$

*Proof.* By the partition (2.1), $|F| = \deg_F(a) + \#\{B : a \notin B\} \le \deg_F(a) + 2^{|A|-1}\deg_F(a)$. $\square$

**Corollary 7.3 (Frankl's singleton case).** *If a union-closed family contains $\{a\}$ then $a$ is abundant.*

*Proof.* Take $A = \{a\}$ in Theorem 7.2: $|A|-1 = 0$, so $|F| \le 2\deg_F(a)$. $\square$

(An independent proof: $B \mapsto B \cup \{a\}$ injects the members avoiding $a$ into those containing $a$, since $B$ is recovered as $(B\cup\{a\})\setminus\{a\}$.)

**Corollary 7.4.** *If a union-closed family contains a two-element set $\{a,b\}$ with $a \ne b$ then $|F| \le 3\deg_F(a)$ and $|F| \le 3\deg_F(b)$.*

This is a two-sided constraint, weaker than abundance but applying to both elements simultaneously — unlike the pair theorem below, which yields abundance for only one of them.

**Definition 7.5 (Extremal family).** For $a \in A$ set
$$E(A,a) := \{A\} \cup \mathcal{P}(A \setminus \{a\}),$$
all subsets of $A$ with $a$ removed, together with $A$ itself.

**Theorem 7.6 (Sharpness).** *For every finite $A$ and $a \in A$, the family $E(A,a)$ is union-closed, contains $A$, and satisfies*
$$|E(A,a)| = \bigl(2^{|A|-1}+1\bigr)\deg_{E(A,a)}(a),$$
*i.e. the bound of Theorem 7.2 holds with equality. Hence the constant $2^{|A|-1}+1$ is optimal for every size of $A$.*

*Proof.* Union-closedness: the union of two subsets of $A\setminus\{a\}$ is again one; the union of $A$ with a subset of $A \setminus \{a\}$ is $A$. Degree: the only member containing $a$ is $A$ itself, since no subset of $A\setminus\{a\}$ contains $a$; so $\deg(a) = 1$. Cardinality: $A \notin \mathcal{P}(A\setminus\{a\})$ (as $a \in A$), so $|E(A,a)| = 2^{|A\setminus\{a\}|} + 1 = 2^{|A|-1}+1$. Multiplying by $\deg(a) = 1$ gives equality. $\square$

**Discussion.** Theorems 7.2 and 7.6 together constitute an *obstruction result*. For $|A| = 1$ the law gives abundance. For $|A| \ge 2$ it gives at best $|F| \le 3\deg$, and by sharpness no argument that uses only the existence of a single member of size $k \ge 2$ can do better than the factor $2^{k-1}+1$. Any proof of Frankl's conjecture must therefore use several members simultaneously — as, for instance, the pair theorem of the next section does.

---

## 8. Unconditional cases of Frankl's conjecture

**Theorem 8.1 (Pair case).** *If $F$ is union-closed and $\{a,b\} \in F$, then $a$ or $b$ is abundant in $F$.*

*Proof.* Write $D_a, D_b$ for the sets of members containing $a$, resp. $b$. The key inequality is
$$|F| \le \deg_F(a) + \deg_F(b). \tag{8.1}$$
To prove it, let $N := \{B \in F : a \notin B,\ b \notin B\}$ and $I := D_a \cap D_b$. The map $B \mapsto B \cup \{a,b\}$ sends $N$ into $I$ (union-closedness, using $\{a,b\} \in F$), and is injective on $N$: if $B \cup \{a,b\} = B' \cup \{a,b\}$ with $a,b \notin B, B'$, then removing $a$ and $b$ from both sides recovers $B = B'$. Hence $|N| \le |I|$. By inclusion–exclusion $|D_a \cup D_b| + |D_a \cap D_b| = \deg_F(a) + \deg_F(b)$, and $|D_a \cup D_b| + |N| = |F|$. Therefore
$$|F| = |D_a \cup D_b| + |N| \le |D_a\cup D_b| + |I| = \deg_F(a) + \deg_F(b).$$
Now suppose neither $a$ nor $b$ is abundant, i.e. $2\deg_F(a) < |F|$ and $2\deg_F(b) < |F|$. Doubling (8.1) gives $2|F| \le 2\deg_F(a) + 2\deg_F(b) < |F| + |F| = 2|F|$, a contradiction. $\square$

**Theorem 8.2 (Chains).** *Let $F$ be totally ordered by inclusion ($A \subseteq B$ or $B \subseteq A$ for all $A,B \in F$) and suppose $F$ has a nonempty member. Then $F$ is union-closed and has an abundant element, whatever $|F|$ is.*

*Proof.* Union-closedness is immediate: the union of two comparable sets is the larger. Let $S$ be the subfamily of nonempty members; $S \ne \varnothing$. Choose $M \in S$ of minimum cardinality and pick $x \in M$. For any $N \in S$, comparability gives $M \subseteq N$ or $N \subseteq M$; in the second case minimality forces $|M| \le |N|$, hence $N = M$. Either way $x \in N$. So $S \subseteq D_x$ and $\deg_F(x) \ge |S|$. At most one member of $F$ is empty, so $|S| \ge |F| - 1$ and $|S| \ge 1$. Then $2\deg_F(x) \ge 2|S| \ge |S| + 1 \ge |F|$, using $|S| \ge 1$ and $|S| \ge |F| - 1$. $\square$

**Theorem 8.3 (Small families).** *Every union-closed family with a nonempty member and at most four members has an abundant element.*

*Proof.* If $|F| \le 2$, pick $x$ in the nonempty member $A$: then $\deg_F(x) \ge 1$ and $2 \ge |F|$. If $|F| \in \{3,4\}$: at most one member is empty, so there are two distinct nonempty members $B \ne C$. We claim some element has degree $\ge 2$. If $B \cup C = B$ then $C \subseteq B$ and any $x \in C$ lies in both. Otherwise $B \cup C \ne B$ is a member distinct from $B$, and any $x \in B$ lies in both $B$ and $B \cup C$. Either way $\deg_F(x)\ge 2$, so $2\deg_F(x) \ge 4 \ge |F|$. $\square$

**Theorem 8.4 (Three-element ground sets).** *Every union-closed family over a three-element ground set with a nonempty member has an abundant element.* This is verified by exhaustive evaluation over all $2^8 = 256$ families.

Note the standard exception: $F = \{\varnothing\}$ is union-closed and nonempty yet has no abundant element, which is why the conjecture requires a nonempty member.

**Transport.** Each of these unconditional witnesses survives adjoining the top: applying Corollary 4.5 gives, for instance, that a union-closed family with at most four members and a nonempty member has an element abundant in $F^{+}$, and likewise for chains and for the singleton case applied to the union closure of an arbitrary family containing $\{a\}$:

**Corollary 8.5.** *For any family $F$ (union-closed or not) containing $\{a\}$, the element $a$ is abundant in $\mathrm{ucl}(F)$, and remains abundant in $(\mathrm{ucl}(F))^{+}$. Similarly, if $\{a,b\} \in F$, then $a$ or $b$ is abundant in $\mathrm{ucl}(F)$.*

---

## 9. Algorithms and certificates

**Theorem 9.1 (Single-maximum certificate).** *Let $s$ be a nonempty finite set. Then*
$$\bigl(\exists\, x \in s : x \text{ abundant in } F\bigr) \iff |F| \le 2\max_{x \in s}\deg_F(x).$$

*Proof.* ($\Rightarrow$) The witness's degree is at most the maximum. ($\Leftarrow$) The maximum over a nonempty finite set is attained at some $x \in s$, and that $x$ is abundant. $\square$

**Proposition 9.2 (Monotonicity of the certificate).** *Degrees are monotone in the family: $F \subseteq G \Rightarrow \deg_F(x) \le \deg_G(x)$. Hence $\max_{x\in s}\deg_F(x) \le \max_{x\in s}\deg_{F^{+}}(x)$: adjoining the top never decreases the certificate value.*

**Corollary 9.3 (Certificate stability).** *If $s$ is nonempty and $|F| \le 2\max_{x\in s}\deg_F(x)$, then either $F = \varnothing$ or $|F^{+}| \le 2\max_{x\in s}\deg_{F^{+}}(x)$.* This is the computational restatement of Theorem 4.4, with the same unique exception.

Note that the certificate is an equivalence, not a shortcut to the conjecture: computing the maximum degree costs $O(|F| \cdot |s|)$, linear in the family, but the family itself may be exponential in the ground set. Nothing here reduces the complexity of the open problem.

### 9.1 Procedures

The results above translate into four concrete procedures.

1. **Degree/surplus profile.** Given $F$ over ground set $s$, compute $\deg_F(x)$ for all $x \in s$ in one pass over the incidence structure, $O(|F|\,|s|)$ time, and report $\sigma_F(x) = 2\deg_F(x) - |F|$ together with the abundant elements. By Theorem 9.1 the existence question is answered by the maximum.

2. **Adjoin-the-top audit.** Compute $\bigvee F$, test membership, and predict the new surplus profile from Lemma 3.1 without recomputing degrees: every $x \in \bigvee F$ gains $+1$, everyone else loses $1$ — and "everyone else" is empty here, since the top contains every element occurring in $F$. This is the algorithmic content of "the operation is safe".

3. **Averaging test.** Compute $T(F) = \sum_{A\in F}|A|$ in $O(|F|\,|s|)$ and test $|s|\,|F| \le 2T(F)$. If it passes, an abundant element exists and is found by taking any maximiser of the degree — no search over subsets required (Theorem 6.2).

4. **Closure with a surplus ledger.** Compute $\mathrm{ucl}(F)$ by repeated pairwise completion until stabilisation, recording at each adjunction whether the new set contains the tracked element $x$ ($+1$) or not ($-1$). The resulting lattice path is the object of Direction 1 in Section 11. Worst-case cost is exponential in $|F|$, but the ledger is what makes small-scale experimentation informative.

---

## 10. Discussion

The question that opened this investigation — *does adjoining the top preserve an abundant witness, and does the parity of $|F|$ falsify it?* — has a clean resolution with an instructive twist. The claim is true; parity is a red herring; the unique failure is the empty family. The reason is the two-versus-one accounting of Lemma 3.1, which says a new member costs one unit of family size and pays two units of degree when it contains the tracked element.

That accounting turned out to be the right general instrument:

- it *explains* Theorem 4.4 (the top is a $+1$ batch);
- it *predicts* Theorem 5.2 (the pairwise step adds a $-1$ set, one net unit too many);
- it *quantifies* the cost of any batch (Corollary 3.3: one unit per new set avoiding $x$);
- and it has a scale-free refinement (Theorem 6.7: densities strictly increase).

Independently, the incidence-matrix viewpoint yields a *creation* mechanism: the averaging criterion of Theorem 6.2, which requires no union-closedness at all, and which — remarkably — is preserved by the very same operation (Theorem 6.5). The consistency of the two mechanisms is not a coincidence but a reflection of the fact that degrees and total size are the column and row marginals of one matrix, and adjoining the top appends a row that is maximal on the support.

Finally, Theorems 7.2 and 7.6 draw a hard line around a natural family of strategies. A single member of size $k$ in a union-closed family constrains degrees only by the factor $2^{k-1}+1$, and this is attained by a power set with a single cap. For $k = 1$ that factor is $2$ and one gets Frankl's singleton case for free; for $k \ge 2$ it is at least $3$ and abundance is out of reach. Progress must be multi-member.

**Limitations.** None of these results proves Frankl's conjecture, and none reduces its complexity. The averaging criterion is silent on sparse families (Proposition 6.3), the local degree law is provably unimprovable, the certificate of Theorem 9.1 does not shrink the search space, and the counterexample of Theorem 5.2 shows the closure can destroy any specific witness one has in hand. What the paper contributes is an exact calculus for the one operation that *is* always safe, a precise identification of where safety ends, and a quantitative obstruction that redirects effort away from single-member arguments.

---

## 11. Future directions

**Direction 1 — Batch-surplus schedules for the union closure.** The counterexample of Theorem 5.2 shows the closure can be surplus-negative, but it reaches its closure through many single adjunctions, each of which is worth exactly $+1$ or $-1$. *Conjecture: for every union-closed target there is an ordering of the added sets along which the running surplus of some fixed element never drops below its starting value.* Adjoining the top is safe because it is the batch of size one with positive surplus, so the question is not whether a batch is dangerous but whether it can be *scheduled* into safe increments. Surplus additivity (Lemma 3.2) makes the schedule a purely combinatorial object — a lattice path — so the conjecture is testable by exhaustive search on three- and four-element ground sets before any proof attempt.

**Direction 2 — The $2^{k-1}+1$ law as a Frankl obstruction.** Theorem 7.6 shows a single member of size $k$ can force nothing better than $|F| \le (2^{k-1}+1)\deg$, and that this is attained. *Conjecture: for a union-closed family in which every nonempty member has size at least $k$, the best possible abundance ratio degrades exactly like $2^{k-1}+1$, i.e. the extremal family $E(A,a)$ is the unique extremiser up to isomorphism.* The extremal family is a power set with a single "cap", so extremality is a statement about how much of a Boolean lattice can sit below one cap. Both the bound and its attainment are already established, so uniqueness is the only missing ingredient, and it can be probed by enumerating extremisers on a four-element ground set.

**Direction 3 — Frankl for structured families beyond chains and small sizes.** Chains (Theorem 8.2) and families of at most four members (Theorem 8.3) are the two extremes of the same counting: chains maximise how many members contain a fixed minimal element, small families minimise how many members must be covered. Interpolating structures — families of bounded width in the inclusion order, families generated by few sets, families with a bounded number of maximal members — are the natural next targets, and the surplus ledger provides a uniform way to measure how far each is from the threshold.

**Direction 4 — Quantitative averaging.** Theorem 6.2 is a threshold statement. What is the best abundance guarantee obtainable as a function of the average member density $T(F)/(|s|\,|F|)$? A quantitative version would interpolate between the trivial regime and the criterion, and could be combined with structural information about union-closed families to enlarge the reach of the argument.

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Unit steps (Lemma 3.1) | A new set containing $x$ raises $\sigma$ by $1$; one avoiding $x$ lowers it by $1$ |
| Surplus additivity (Lemma 3.2) | $\sigma_{F\sqcup G}(x) = \sigma_F(x)+\sigma_G(x)$ |
| Main theorem (Thm 4.4) | $x$ abundant in $F$, $x \in \bigvee F$ $\Rightarrow$ $x$ abundant in $F^{+}$ |
| Exact boundary (Thm 4.6) | For abundant $x$: abundance survives iff $F \ne \varnothing$ |
| Parity (Thm 4.7) | On odd families abundance is automatically strict |
| Sharpness (Prop 4.9, Thm 5.2) | A set avoiding $x$, or one pairwise-completion step, can destroy abundance |
| Double counting (Thm 6.1) | $\sum_{x\in s}\deg_F(x) = \sum_{A\in F}|A|$ |
| Averaging criterion (Thm 6.2) | $|s|\,|F| \le 2T(F)$ $\Rightarrow$ some $x \in s$ abundant |
| Stability (Thm 6.5) | The averaging criterion is preserved by adjoining the top |
| Density (Thm 6.7) | A new top strictly increases $\deg_F(x)/|F|$ unless $x$ is in every member |
| Local law (Thms 7.2, 7.6) | $|F| \le (2^{|A|-1}+1)\deg_F(a)$, attained for every $|A|$ |
| Frankl cases (Thms 8.1–8.4) | Singleton, pair, chains, $|F|\le 4$, three-element ground sets |
| Certificate (Thm 9.1) | Abundance in $s$ $\iff$ $|F| \le 2\max_{x\in s}\deg_F(x)$ |
