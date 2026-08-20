# Kernel Patterns: Complete Invariants of Tuples under Alphabet Permutations, and the Bell–Stirling Calculus They Generate

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

For a tuple $x = (x_1,\dots,x_n)$ with entries in a set $\alpha$, its *kernel* (equality pattern) is the equivalence relation $i \sim_x j \iff x_i = x_j$ on the index set. We develop a complete theory of this invariant for the natural action of the symmetric group $\operatorname{Sym}(\alpha)$ on $\alpha^n$ by relabelling of entries. We introduce a computable canonical form $\operatorname{can}(x)_i = \min\{j : x_j = x_i\}$, characterise its image as the set of *idempotent contracting retractions* of $\{0,\dots,n-1\}$ (the restricted growth encodings of set partitions), and prove that the kernel is both invariant and complete: two tuples over the same alphabet — finite or infinite, with no cardinality hypotheses — have the same kernel if and only if they lie in a common $\operatorname{Sym}(\alpha)$-orbit. We then establish that the resulting type of patterns is canonically isomorphic to the lattice of equivalence relations on an $n$-element set, whence its cardinality is the Bell number $B_n$; as a by-product we obtain a self-contained proof that the binomial-recurrence Bell numbers count set partitions, with the first six values $1,1,2,5,15,52$ (OEIS A000110) obtained by exhaustive enumeration of the finite set of patterns. Refining by the number of blocks yields the Stirling numbers of the second kind $S(n,k)$ together with $\sum_k S(n,k) = B_n$; realisability over an alphabet of size $a$ yields a truncated Stirling row $\sum_{k \le a} S(n,k)$ as the exact orbit count for *every* finite alphabet, with the closed forms $2^{n}$ (binary, length $n+1$) and $(3^{n}+1)/2$ (ternary, length $n+1$). Fibring the tuples over their patterns gives the connection formula $a^n = \sum_k S(n,k)\, a^{\underline{k}}$ between ordinary powers and falling factorials as a pure counting identity. Finally, we compute the dimension of the space of relabelling-invariant $K$-valued functions of an $n$-tuple: it equals $B_n$ whenever $n \le |\alpha|$.

**Keywords:** equality pattern, kernel of a tuple, set partition, Bell number, Stirling number of the second kind, restricted growth string, complete invariant, symmetric group orbit, falling factorial.

---

## 1. Introduction

### 1.1 The question

Let $\alpha$ be a set (the *alphabet*) and let $n \ge 0$. The symmetric group $\operatorname{Sym}(\alpha)$ — the group of all bijections $\alpha \to \alpha$ — acts on the set $\alpha^n$ of $n$-tuples by postcomposition:
$$ \sigma \cdot (x_1,\dots,x_n) = (\sigma x_1, \dots, \sigma x_n). $$
This action formalises the idea of *renaming the letters*. Two natural questions arise.

1. **Invariants.** What features of a tuple survive renaming?
2. **Classification.** How many orbits are there, and can they be listed effectively?

The answer to (1) is a single feature — the pattern of coincidences among the entries — and the answer to (2) is the Bell number, together with a precise correction when the alphabet is too small to realise every pattern. This paper develops both answers in full, with the intermediate combinatorics (Bell recurrence, Stirling recurrence, power/falling-factorial connection formula) derived from the classification rather than assumed.

### 1.2 Overview of results

Throughout, indices run over $[n] := \{0, 1, \dots, n-1\}$ with its usual linear order.

- **§2** defines the kernel, the canonical form $\operatorname{can}$, and the class of *patterns*, and proves invariance (Theorem 2.7) and completeness (Theorems 2.9 and 6.1) of the kernel invariant.
- **§3** proves that the number of equivalence relations on an $n$-element set is the Bell number $B_n$ (Theorem 3.5), and identifies patterns with equivalence relations (Theorem 3.6), giving the orbit count $B_n$ for $n \le |\alpha|$ (Theorem 3.9).
- **§4** refines the count by block number, obtaining the Stirling numbers of the second kind (Theorem 4.4) and $\sum_k S(n,k) = B_n$ (Corollary 4.5).
- **§5** removes the hypothesis $n \le |\alpha|$: patterns realisable over $\alpha$ are exactly those with at most $|\alpha|$ blocks (Theorem 5.2), the orbit count is a truncated Stirling row (Theorem 5.4), and the binary and ternary cases have closed forms (Theorems 5.6, 5.8).
- **§6** gives the completeness theorem over arbitrary (possibly infinite) alphabets, the connection formula $a^n = \sum_k S(n,k)a^{\underline{k}}$ (Theorem 6.4), and the dimension $B_n$ of the space of invariant functions (Theorem 6.6).
- **§7** discusses algorithms, **§8** applications, **§9** open directions.

---

## 2. The kernel, its canonical form, and patterns

### 2.1 The kernel

**Definition 2.1 (Kernel).** For $x \in \alpha^n$, the *kernel* of $x$ is the equivalence relation $\ker x$ on $[n]$ defined by
$$ i \mathrel{(\ker x)} j \iff x_i = x_j. $$
Reflexivity, symmetry and transitivity are inherited from equality, so $\ker x$ is indeed an equivalence relation.

**Definition 2.2 (Same kernel).** For $x \in \alpha^n$ and $y \in \beta^n$ (possibly over *different* alphabets) write
$$ \operatorname{SameKer}(x,y) \iff \bigl(\forall i, j \in [n]:\; x_i = x_j \leftrightarrow y_i = y_j\bigr). $$

**Lemma 2.3.** $\operatorname{SameKer}$ is reflexive, symmetric and transitive across alphabets, and $\operatorname{SameKer}(x,y) \iff \ker x = \ker y$.

*Proof.* Immediate from the definitions; the second claim is extensionality of relations. $\square$

### 2.2 The canonical form

**Definition 2.4 (Canonical form).** For $x \in \alpha^n$ define $\operatorname{can}(x) : [n] \to [n]$ by
$$ \operatorname{can}(x)_i \;=\; \min\{\, j \in [n] : x_j = x_i \,\}. $$
The set is nonempty (it contains $i$) and finite, so the minimum exists.

**Lemma 2.5 (Basic properties).** For all $i,j$:
1. $x_{\operatorname{can}(x)_i} = x_i$;
2. $\operatorname{can}(x)_i \le i$, and more generally $x_j = x_i \Rightarrow \operatorname{can}(x)_i \le j$;
3. $\operatorname{can}(x)_i = \operatorname{can}(x)_j \iff x_i = x_j$;
4. $\operatorname{can}(x)_{\operatorname{can}(x)_i} = \operatorname{can}(x)_i$ (idempotence).

*Proof.* (1) and (2) are the defining properties of a minimum of the set $\{j : x_j = x_i\}$. For (3): if the canonical indices agree then $x_i = x_{\operatorname{can}(x)_i} = x_{\operatorname{can}(x)_j} = x_j$ by (1); conversely $x_i = x_j$ makes the two defining sets literally equal, hence their minima equal. (4) is (3) applied to (1). $\square$

**Proposition 2.6 (Completeness of the encoding).** For $x \in \alpha^n$, $y \in \beta^n$:
$$ \operatorname{SameKer}(x,y) \iff \operatorname{can}(x) = \operatorname{can}(y). $$

*Proof.* ($\Rightarrow$) Same kernel makes the defining sets $\{j : x_j = x_i\}$ and $\{j : y_j = y_i\}$ equal for each $i$, hence the minima agree. ($\Leftarrow$) By Lemma 2.5(3), $x_i = x_j \iff \operatorname{can}(x)_i = \operatorname{can}(x)_j = \operatorname{can}(y)_i = \operatorname{can}(y)_j \iff y_i = y_j$. $\square$

### 2.3 Invariance

**Theorem 2.7 (Invariance under injective relabelling).** Let $f : \alpha \to \beta$ be *injective*. Then for all $x \in \alpha^n$,
$$ \operatorname{can}(f \circ x) = \operatorname{can}(x), \qquad\text{hence}\qquad \operatorname{SameKer}(f\circ x, x). $$

*Proof.* Injectivity gives $f(x_j) = f(x_i) \iff x_j = x_i$, so the two defining sets coincide for each $i$; take minima. $\square$

In particular, for any $\sigma \in \operatorname{Sym}(\alpha)$ the tuples $\sigma \circ x$ and $x$ have the same kernel: **the kernel is a $\operatorname{Sym}(\alpha)$-invariant**. Note that Theorem 2.7 is strictly stronger — the kernel is stable under arbitrary injections, including injections between different alphabets, so canonical forms are comparable across alphabets.

### 2.4 Completeness over a finite alphabet

**Theorem 2.9 (Completeness, finite alphabet).** Let $\alpha$ be finite and $x, y \in \alpha^n$. Then
$$ \operatorname{SameKer}(x,y) \iff \exists\, \sigma \in \operatorname{Sym}(\alpha):\ \sigma \circ x = y. $$

*Proof.* ($\Leftarrow$) is Theorem 2.7. ($\Rightarrow$) Let $S = \{x_i : i \in [n]\}$ and $T = \{y_i : i \in [n]\}$ be the value sets. For $a \in S$ pick an index $\iota(a)$ with $x_{\iota(a)} = a$, and define $f : S \to T$ by $f(a) = y_{\iota(a)}$.
- *Well defined and injective.* If $f(a) = f(b)$, i.e. $y_{\iota(a)} = y_{\iota(b)}$, then same kernel gives $x_{\iota(a)} = x_{\iota(b)}$, i.e. $a = b$.
- *Surjective.* Given $b = y_i \in T$, put $a = x_i \in S$. Then $x_{\iota(a)} = a = x_i$, so same kernel gives $y_{\iota(a)} = y_i = b$, i.e. $f(a) = b$.

So $f : S \to T$ is a bijection between two subsets of the finite set $\alpha$; they have equal cardinality, hence so do their complements, and $f$ extends to a permutation $\sigma$ of $\alpha$. For each $i$, taking $a = x_i$ we get $x_{\iota(a)} = x_i$, hence $y_{\iota(a)} = y_i$ by same kernel, hence $\sigma(x_i) = f(x_i) = y_i$. $\square$

### 2.5 Patterns

**Definition 2.10 (Pattern).** A map $p : [n] \to [n]$ is a *pattern* if for every $i$,
$$ p(i) \le i \qquad\text{(contracting)} \qquad\text{and}\qquad p(p(i)) = p(i) \qquad\text{(idempotent)}. $$
Write $\mathcal{P}_n$ for the set of patterns on $n$ letters. Both conditions are decidable, so $\mathcal{P}_n$ is an explicitly enumerable finite set with decidable equality.

Patterns are precisely the *restricted growth encodings* of set partitions of $[n]$: $p(i)$ names the block of $i$ by its least element.

**Theorem 2.11 (Retraction).** $\operatorname{can}$ maps $\alpha^n$ onto $\mathcal{P}_n$, and every pattern is its own canonical form: $\operatorname{can}(p) = p$ for $p \in \mathcal{P}_n$. Consequently $\operatorname{can}$ is an idempotent retraction of tuples onto patterns, and $\mathcal{P}_n$ is a complete and irredundant set of normal forms for the kernel.

*Proof.* That $\operatorname{can}(x)$ is a pattern is Lemma 2.5(2),(4). For the second claim let $p$ be a pattern and $i \in [n]$. Since $p(p(i)) = p(i)$, the index $p(i)$ lies in $\{j : p(j) = p(i)\}$, so $\operatorname{can}(p)_i \le p(i)$. Conversely, $p(\operatorname{can}(p)_i) = p(i)$ by Lemma 2.5(1), and $p$ is contracting, so $p(i) = p(\operatorname{can}(p)_i) \le \operatorname{can}(p)_i$. Antisymmetry gives equality. Surjectivity follows since $\operatorname{can}(p) = p$. $\square$

**Definition 2.12.** For $x \in \alpha^n$ write $\operatorname{pat}(x) := \operatorname{can}(x) \in \mathcal{P}_n$, the *pattern of $x$*.

**Corollary 2.13.** For finite $\alpha$ and $x,y \in \alpha^n$: $\operatorname{pat}(x) = \operatorname{pat}(y)$ if and only if $x$ and $y$ lie in the same $\operatorname{Sym}(\alpha)$-orbit.

---

## 3. Counting: patterns are equivalence relations, and there are $B_n$ of them

### 3.1 Bell numbers

**Definition 3.1.** The Bell numbers are defined by the binomial recurrence
$$ B_0 = 1, \qquad B_{n+1} = \sum_{k=0}^{n} \binom{n}{k} B_{n-k}. $$

We prove that this recurrence counts equivalence relations. Write $E(m)$ for the number of equivalence relations on an $m$-element set (this is well defined: any bijection of underlying sets transports equivalence relations bijectively).

### 3.2 The distinguished-point fibration

Let $\beta$ be a finite set and consider equivalence relations on $\beta \sqcup \{\ast\}$, where $\ast$ is a distinguished extra point.

**Definition 3.2.** For an equivalence relation $s$ on $\beta \sqcup \{\ast\}$, let $\operatorname{blk}(s) = \{ b \in \beta : b \mathrel{s} \ast \}$ be the set of partners of $\ast$.

**Definition 3.3 (Gluing).** Given a subset $S \subseteq \beta$ and an equivalence relation $t$ on $\beta \setminus S$, define a relation $R(S,t)$ on $\beta \sqcup \{\ast\}$ by
$$
\begin{aligned}
&\ast \mathrel{R} \ast; \qquad \ast \mathrel{R} b \iff b \in S; \qquad a \mathrel{R} \ast \iff a \in S; \\
&a \mathrel{R} b \iff \begin{cases} b \in S & \text{if } a \in S,\\ \text{false} & \text{if } a \notin S,\ b \in S,\\ a \mathrel{t} b & \text{if } a,b \notin S.\end{cases}
\end{aligned}
$$

**Lemma 3.4 (Fibre description).** $R(S,t)$ is an equivalence relation with $\operatorname{blk}(R(S,t)) = S$; and the assignments $t \mapsto R(S,t)$ and $s \mapsto (s\ \text{restricted to}\ \beta\setminus S)$ are mutually inverse bijections
$$ \{\, s : \operatorname{blk}(s) = S \,\} \;\longleftrightarrow\; \{\,\text{equivalence relations on } \beta \setminus S \,\}. $$

*Proof sketch.* Reflexivity, symmetry and transitivity of $R(S,t)$ are checked case-by-case on whether each argument is $\ast$, in $S$, or outside $S$; the only nontrivial cases are transitivity chains that cross the boundary of $S$, which are handled by the observation that $R$ never relates a point of $S$ to a point outside $S$. That $\operatorname{blk}(R(S,t)) = S$ is immediate. For the bijection: starting from $s$ with $\operatorname{blk}(s) = S$, one shows $s = R(S, s|_{\beta \setminus S})$ by the same case analysis, using $b \in S \iff b \mathrel{s} \ast$ and transitivity of $s$ to identify the $S \times S$ and $S \times S^{c}$ blocks. Conversely $R(S,t)$ restricted to $\beta \setminus S$ is $t$ by definition. $\square$

**Theorem 3.5 (Bell numbers count equivalence relations).** For all $n$, $E(n) = B_n$.

*Proof.* Summing Lemma 3.4 over the fibres of $\operatorname{blk}$ gives
$$ E(m+1) \;=\; \sum_{S \subseteq \beta} E(|\beta| - |S|) \;=\; \sum_{k=0}^{m} \binom{m}{k} E(m-k) $$
for $|\beta| = m$, where the second equality groups subsets by size. Also $E(0) = 1$, since the empty set carries exactly one (empty) relation. This is precisely the recurrence of Definition 3.1, and strong induction on $n$ finishes the proof. $\square$

### 3.3 Patterns are equivalence relations

**Theorem 3.6 (Classification of patterns).** The maps
$$ p \mapsto \ker p, \qquad s \mapsto \operatorname{can}\bigl(i \mapsto [i]_s\bigr) $$
are mutually inverse bijections between $\mathcal{P}_n$ and the set of equivalence relations on $[n]$. (Here $[i]_s$ denotes the $s$-class of $i$, so $i \mapsto [i]_s$ is a tuple over the quotient set.)

*Proof.* First, the quotient map $q_s : i \mapsto [i]_s$ satisfies $\ker q_s = s$, since $[i]_s = [j]_s \iff i \mathrel{s} j$. Second, $\ker \operatorname{can}(x) = \ker x$ for any $x$, by Lemma 2.5(3). Hence $\ker\bigl(\operatorname{can}(q_s)\bigr) = \ker q_s = s$: one composite is the identity. For the other, let $p$ be a pattern; then $\operatorname{SameKer}(q_{\ker p}, p)$ holds, so by Proposition 2.6 $\operatorname{can}(q_{\ker p}) = \operatorname{can}(p) = p$ by Theorem 2.11. $\square$

**Theorem 3.7 (Pattern count).** $|\mathcal{P}_n| = B_n$.

*Proof.* Combine Theorem 3.6 with Theorem 3.5. $\square$

**Theorem 3.8 (Small values).** $|\mathcal{P}_0|, \dots, |\mathcal{P}_5| = 1, 1, 2, 5, 15, 52$, hence
$$ (B_0,B_1,B_2,B_3,B_4,B_5) = (1,1,2,5,15,52) \qquad \text{(OEIS A000110)}. $$

*Proof.* $\mathcal{P}_n$ is a decidable subset of the finite set $[n]^{[n]}$, so its cardinality is obtained by exhaustive enumeration; transport to $B_n$ along Theorem 3.7. $\square$

### 3.4 The orbit count

**Theorem 3.9 (Orbit count for a large alphabet).** Let $\alpha$ be finite with $n \le |\alpha|$. Then the number of $\operatorname{Sym}(\alpha)$-orbits on $\alpha^n$ is exactly $B_n$, and the orbit invariant is $\operatorname{pat}$.

*Proof.* By Corollary 2.13, $\operatorname{pat}$ descends to an injection from the orbit space into $\mathcal{P}_n$. For surjectivity, given $p \in \mathcal{P}_n$, choose an injection $f : [n] \hookrightarrow \alpha$ (possible since $n \le |\alpha|$); then by Theorem 2.7 and Theorem 2.11, $\operatorname{pat}(f \circ p) = \operatorname{can}(p) = p$. Hence the orbit space is in bijection with $\mathcal{P}_n$, of size $B_n$ by Theorem 3.7. $\square$

**Example 3.10.** $\operatorname{Sym}(\{1,\dots,5\})$ has exactly $52$ orbits on the $3125$ quintuples over a five-letter alphabet.

---

## 4. The block-refined count: Stirling numbers of the second kind

**Definition 4.1 (Blocks).** For $p \in \mathcal{P}_n$ let $\operatorname{blocks}(p) = |\,p([n])\,|$, the number of distinct values of $p$. Equivalently (by idempotence) it is the number of fixed points of $p$, and equivalently the number of classes of $\ker p$.

**Lemma 4.2.** For any $x \in \alpha^n$, $\operatorname{blocks}(\operatorname{pat}(x)) = |\{x_i : i \in [n]\}|$: the block count of the pattern of a tuple is the number of distinct entries.

*Proof.* The map $j \mapsto x_j$ restricts to a bijection from the image of $\operatorname{can}(x)$ (a set of block representatives, each a fixed point of $\operatorname{can}(x)$) onto the value set of $x$: it is well defined, injective by Lemma 2.5(3) together with fixedness, and surjective since $x_{\operatorname{can}(x)_i} = x_i$. $\square$

**Definition 4.3 (Stirling numbers of the second kind).**
$$ S(0,0) = 1,\quad S(0,k+1) = 0,\quad S(n+1,0)=0,\quad S(n+1,k+1) = (k+1)S(n,k+1) + S(n,k). $$

**Theorem 4.4 (Block-refined count).** The number of patterns on $n$ letters with exactly $k$ blocks equals $S(n,k)$.

*Proof (last-letter fibration).* Let $N(n,k)$ denote the number of such patterns. Deleting the last coordinate of $p \in \mathcal{P}_{n+1}$ yields a well-defined restriction $\rho(p) \in \mathcal{P}_n$ (contraction guarantees the values stay in range, and idempotence is preserved). Conversely, an extension of $q \in \mathcal{P}_n$ is determined by the value $v$ at the new last coordinate, and $v$ is *admissible* precisely when either
- $v$ is a fixed point of $q$ (a block representative), in which case the extension joins an existing block and $\operatorname{blocks} = \operatorname{blocks}(q)$; or
- $v$ is the new coordinate itself, in which case a new singleton block is created and $\operatorname{blocks} = \operatorname{blocks}(q)+1$.

Thus the fibre of $\rho$ above $q$, intersected with the patterns having $k+1$ blocks, has size $k+1$ if $\operatorname{blocks}(q) = k+1$ (choose one of the $k+1$ representatives), size $1$ if $\operatorname{blocks}(q) = k$ (the new-block extension), and $0$ otherwise. Summing over $q$:
$$ N(n+1,k+1) = (k+1) N(n,k+1) + N(n,k). $$
The base cases match: $N(0,0)=1$ (the empty pattern), $N(0,k+1)=0$, and $N(n+1,0)=0$ since a nonempty pattern has at least one block. Induction gives $N = S$. $\square$

**Corollary 4.5.** $\displaystyle \sum_{k=0}^{n} S(n,k) = B_n$.

*Proof.* Partition $\mathcal{P}_n$ by block count; every pattern has at most $n$ blocks. Apply Theorems 4.4 and 3.7. $\square$

**Example 4.6.** Row $n=4$: $(0,1,7,6,1)$, summing to $15 = B_4$. Row $n=5$: $(0,1,15,25,10,1)$, summing to $52 = B_5$.

---

## 5. Small alphabets: realisability and truncated Stirling rows

Theorem 3.9 assumed $n \le |\alpha|$. Without that hypothesis, some patterns are simply unattainable.

**Lemma 5.1.** For finite $\alpha$ and $x \in \alpha^n$, $\operatorname{blocks}(\operatorname{pat}(x)) \le |\alpha|$.

*Proof.* By Lemma 4.2, the block count is the number of distinct entries, a subset of $\alpha$. $\square$

**Theorem 5.2 (Realisability).** Let $\alpha$ be finite and $p \in \mathcal{P}_n$. Then $p = \operatorname{pat}(x)$ for some $x \in \alpha^n$ if and only if $\operatorname{blocks}(p) \le |\alpha|$.

*Proof.* Necessity is Lemma 5.1. For sufficiency, choose an injection $e$ from the image $p([n])$ (of size $\operatorname{blocks}(p) \le |\alpha|$) into $\alpha$, and set $x_i = e(p(i))$. Then $\operatorname{SameKer}(x, p)$ because $e$ is injective, so $\operatorname{pat}(x) = \operatorname{can}(p) = p$. $\square$

**Theorem 5.3 (Classification over an arbitrary finite alphabet).** For every finite alphabet $\alpha$ and every $n$, the map $\operatorname{pat}$ induces a bijection
$$ \alpha^n / \operatorname{Sym}(\alpha) \;\xrightarrow{\ \sim\ }\; \{\, p \in \mathcal{P}_n : \operatorname{blocks}(p) \le |\alpha| \,\}. $$

*Proof.* Injectivity is Corollary 2.13; well-definedness of the codomain restriction is Lemma 5.1; surjectivity is Theorem 5.2. $\square$

**Theorem 5.4 (Truncated Stirling row).** For every finite alphabet $\alpha$ with $|\alpha| = a$,
$$ \bigl|\alpha^n / \operatorname{Sym}(\alpha)\bigr| \;=\; \sum_{k=0}^{a} S(n,k). $$

*Proof.* Combine Theorem 5.3 with Theorem 4.4, partitioning the patterns with at most $a$ blocks by their exact block count. $\square$

### 5.1 Closed forms for tiny alphabets

**Lemma 5.5.** $S(m+1,1) = 1$ and $S(m+2,2) + 1 = 2^{m+1}$ (i.e. $S(m,2) = 2^{m-1}-1$ for $m \ge 2$).

*Proof.* Both by induction from the recurrence: $S(m+2,1) = 1\cdot S(m+1,1) + S(m+1,0) = 1$; and $S(m+2,2) = 2 S(m+1,2) + S(m+1,1)$, so $S(m+2,2)+1 = 2(S(m+1,2)+1)$, which doubles from the base value $2$. (The statement is phrased additively to avoid truncated subtraction.) $\square$

**Theorem 5.6 (Binary alphabet).** For every $n$, the $(n+1)$-tuples over a two-letter alphabet fall into exactly $2^{n}$ orbits under the letter-swapping group.

*Proof.* By Theorem 5.4 the count is $S(n+1,0)+S(n+1,1)+S(n+1,2) = 0 + 1 + (2^{n}-1) = 2^{n}$ for $n \ge 1$, and the case $n = 0$ is a direct check. $\square$

**Theorem 5.7 (Strictness).** For $n \ge 3$, the orbit count over a binary alphabet is *strictly* smaller than $B_n$.

*Proof.* The difference is $\sum_{k \ge 3} S(n,k)$, which is positive because $S(n,3) > 0$ for $n \ge 3$ (induction: $S(3,3)=1$, and $S(n+1,3) \ge S(n,3)$). Concretely, at $n=3$ the count is $4$ versus $B_3 = 5$; the unattainable pattern is the one with three singleton blocks. $\square$

**Theorem 5.8 (Ternary alphabet).** For every $n$, the $(n+1)$-tuples over a three-letter alphabet fall into $N$ orbits where
$$ 2N = 3^{n} + 1, \qquad \text{i.e. } N = \tfrac{3^{n}+1}{2}. $$

*Proof.* By Theorem 5.4, $N = \sum_{k \le 3} S(n+1,k)$; one shows $2\sum_{k \le 3} S(m+1,k) = 3^{m}+1$ by induction on $m$ using the Stirling recurrence, the base case $m=0$ being $2 \cdot 1 = 1 + 1$. (The integral formulation avoids division.) $\square$

---

## 6. Arbitrary alphabets, the connection formula, and invariant functions

### 6.1 Completeness with no finiteness hypothesis

**Theorem 6.1 (Completeness, general alphabet).** For an arbitrary set $\alpha$ and $x,y \in \alpha^n$:
$$ \operatorname{SameKer}(x,y) \iff \exists\, \sigma \in \operatorname{Sym}(\alpha):\ \sigma \circ x = y. $$

*Proof.* The finite case is Theorem 2.9. If $\alpha$ is infinite, construct the bijection $f : S \to T$ between the (finite) value sets exactly as in the proof of Theorem 2.9. To extend $f$ to all of $\alpha$ one needs a bijection $\alpha \setminus S \to \alpha \setminus T$; since $S$ and $T$ are finite and $\alpha$ is infinite, both complements have cardinality $|\alpha|$, so such a bijection exists. Gluing gives $\sigma$, and $\sigma(x_i) = y_i$ follows as before. $\square$

**Example 6.2.** Over $\mathbb{N}$, the tuples $(0,0,1)$ and $(5,5,7)$ have the same kernel, hence there is a permutation $\sigma$ of $\mathbb{N}$ with $\sigma \circ (0,0,1) = (5,5,7)$.

### 6.2 The connection formula between powers and falling factorials

Fix a finite alphabet of size $a$ and write $a^{\underline{k}} = a(a-1)\cdots(a-k+1)$ for the falling factorial (with $a^{\underline{k}} = 0$ when $k > a$).

**Theorem 6.3 (Fibre size).** For $p \in \mathcal{P}_n$ with $k = \operatorname{blocks}(p)$,
$$ \bigl|\{\, x \in \alpha^n : \operatorname{pat}(x) = p \,\}\bigr| \;=\; a^{\underline{k}}. $$

*Proof.* A tuple $x$ with $\operatorname{pat}(x) = p$ is exactly the datum of an *injective* labelling of the blocks of $p$ by letters: given $x$, the map $\text{block} \mapsto \text{the common value of } x \text{ on that block}$ is injective (distinct blocks would otherwise merge, changing the pattern); conversely, any injection $\varphi$ from the $k$-element block set into $\alpha$ produces $x_i = \varphi(\text{block of } i)$ with $\operatorname{pat}(x) = \operatorname{can}(p) = p$ by Theorem 2.7 and Theorem 2.11. These assignments are mutually inverse. The number of injections from a $k$-set to an $a$-set is $a^{\underline{k}}$. $\square$

**Theorem 6.4 (Connection formula).** For every $a, n \ge 0$,
$$ a^{n} \;=\; \sum_{k=0}^{n} S(n,k)\, a^{\underline{k}}. $$

*Proof.* Count $\alpha^n$ (of size $a^n$) by fibring over the pattern map, then grouping patterns by block count: by Theorem 6.3 each pattern with $k$ blocks contributes $a^{\underline{k}}$, and by Theorem 4.4 there are $S(n,k)$ of them. $\square$

**Remark 6.5.** Theorem 6.4 explains the truncation in Theorem 5.4 conceptually: the terms with $k > a$ vanish because $a^{\underline{k}} = 0$ — exactly the patterns that Theorem 5.2 declares unrealisable. Numerical check at $a=3$, $n=4$: $81 = 0\cdot1 + 1\cdot3 + 7\cdot6 + 6\cdot6 + 1\cdot0$.

### 6.3 The dimension of the space of invariant functions

Let $K$ be a field and $\beta$ a finite alphabet. Consider
$$ \operatorname{Inv}_K(\beta, n) \;=\; \bigl\{\, f : \beta^n \to K \ \bigm|\ f(\sigma \circ x) = f(x) \ \ \forall \sigma \in \operatorname{Sym}(\beta),\ \forall x \,\bigr\}, $$
a $K$-subspace of the space of all functions $\beta^n \to K$ (it is closed under addition and scalar multiplication because the condition is linear in $f$).

**Theorem 6.6 (Dimension).** If $n \le |\beta| < \infty$, then
$$ \dim_K \operatorname{Inv}_K(\beta, n) \;=\; B_n. $$

*Proof.* Restriction along the quotient map $\beta^n \to \beta^n/\operatorname{Sym}(\beta)$ is a $K$-linear isomorphism from the space of *all* functions on the (finite) orbit space onto $\operatorname{Inv}_K(\beta,n)$: an invariant function is constant on orbits and hence factors uniquely through the quotient, and conversely every function on the quotient pulls back to an invariant function. The space of $K$-valued functions on a finite set of size $m$ has dimension $m$; by Theorem 3.9 the orbit space has size $B_n$. $\square$

**Interpretation.** A relabelling-invariant function of $n$ arguments drawn from a sufficiently large alphabet is *precisely* a function of the equality pattern, and has exactly $B_n$ degrees of freedom — $52$ for $n = 5$, regardless of how large the alphabet is. Over a small alphabet the dimension drops to the truncated row $\sum_{k \le |\beta|} S(n,k)$ by the same argument combined with Theorem 5.4.

---

## 7. Algorithms

All the objects above are effectively computable. We record the three core routines and their complexities. Let $n$ be the tuple length and $a$ the alphabet size.

### 7.1 Canonical form

Computing $\operatorname{can}(x)_i = \min\{j : x_j = x_i\}$ naively costs $O(n^2)$ comparisons. A single left-to-right pass with a dictionary from value to first index computes the whole canonical form in $O(n)$ expected time (or $O(n\log n)$ with a comparison-based map):

> for $i = 0, 1, \dots, n-1$: if $x_i$ is unseen, record $\text{first}[x_i] \leftarrow i$; output $\operatorname{can}(x)_i = \text{first}[x_i]$.

Correctness: the recorded index is the least $j$ with $x_j = x_i$ by construction of the pass order. This is precisely the restricted-growth normalisation, and it gives an $O(n)$ test for "are these two tuples renamings of one another?" — compare canonical forms elementwise, by Proposition 2.6 and Theorem 6.1.

### 7.2 Enumerating patterns

Patterns can be generated directly by the last-letter recursion of Theorem 4.4, which produces each of the $B_n$ patterns exactly once with no rejection: extend a pattern $q$ on $n$ letters by choosing the last value among the fixed points of $q$ (join an existing block) or the new index itself (open a new block). The cost is $O(n \cdot B_n)$ output-sensitive time — optimal up to the factor $n$ needed to write each pattern down. Brute-force filtering of all $n^n$ maps by the two pattern conditions is also possible and is what makes the small values verifiable by exhaustive search, but it is exponentially wasteful for $n \gtrsim 8$.

### 7.3 Counting

Bell and Stirling numbers are computed by dynamic programming from their recurrences in $O(n^2)$ arithmetic operations. The orbit count over an alphabet of size $a$ is then the prefix sum $\sum_{k \le a} S(n,k)$, computable in $O(n^2)$ as well. For the two smallest alphabets, Theorems 5.6 and 5.8 replace the sum by $2^{n-1}$ and $(3^{n-1}+1)/2$ respectively.

---

## 8. Applications and connections

**Alpha-equivalence and name-independence.** In logic, programming-language theory and databases, the doctrine that *names of atoms do not matter* is exactly the statement that the meaningful content of a tuple of names is its kernel. Theorem 6.1 says this doctrine loses nothing and hides nothing: two name-tuples are interchangeable if and only if their coincidence patterns agree. Canonical forms play the role that de Bruijn indices play for bound variables.

**Query evaluation over an active domain.** A relational query whose answer must be equivariant under renaming of constants can only depend on the pattern; Theorem 5.4 gives the exact number of distinguishable $n$-tuples over a domain with $a$ constants, and the connection formula (Theorem 6.4) tells you how many concrete tuples realise each of them.

**Permutation-equivariant learning.** Models that consume a set or list of tokens and are required to be invariant under relabelling of the token vocabulary can, by Theorem 6.6, express exactly $B_n$ independent scalar features of an $n$-token input — an absolute expressivity ceiling that does not improve with vocabulary size, and drops to $\sum_{k \le a} S(n,k)$ for small vocabularies.

**Hash collision structure.** The pattern of a list of hash values is its collision structure. Theorem 6.3 states that, over a codomain of size $a$, exactly $a^{\underline{k}}$ assignments realise a fixed collision structure with $k$ distinct values; summing gives the familiar $a^n$ and, after dividing, the classical birthday-problem probabilities.

**A proof of a classical identity by counting.** The change of basis $x^n = \sum_k S(n,k)\, x^{\underline{k}}$ between the monomial and falling-factorial bases of the polynomial ring is usually proved by induction on the Stirling recurrence or by umbral/generating-function methods. Theorem 6.4 derives it, for every nonnegative integer $x = a$, purely by counting a finite set in two ways — and since two polynomials agreeing at infinitely many integers are equal, this yields the polynomial identity as well.

---

## 9. Discussion and future directions

Three sharp questions remain open on top of the theory developed here.

**(D1) A Dobiński-type analytic bridge.** Dobiński's formula states
$$ B_n \;=\; \frac{1}{e}\sum_{k=0}^{\infty} \frac{k^n}{k!}. $$
Our development already provides the combinatorial engine: the connection formula $k^n = \sum_j S(n,j)\, k^{\underline{j}}$ (Theorem 6.4) holds for each $k$, and summing it against the Poisson weights $e^{-1}/k!$ turns each term $\sum_k e^{-1} k^{\underline{j}}/k!$ into $1$, leaving $\sum_j S(n,j) = B_n$ by Corollary 4.5. The only missing ingredient is the analytic justification of the exchange of the two summations. This is a genuinely modest gap, and closing it would give a fully self-contained derivation of Dobiński from the pattern classification.

**(D2) The pattern poset is the partition lattice.** Order $\mathcal{P}_n$ by refinement: $p \le q$ if and only if $p(i) = p(j) \Rightarrow q(i) = q(j)$. Conjecturally the bijection of Theorem 3.6 upgrades to an *order* isomorphism onto the lattice of equivalence relations on $[n]$; then $\mathcal{P}_n$ is a complete lattice, is non-distributive for $n \ge 3$, and its Möbius function satisfies $\mu(\hat{0},\hat{1}) = (-1)^{n-1}(n-1)!$. The plausible route is that $\operatorname{can}$ is a *monotone* retraction: $\operatorname{can}(x)$ depends only on $\ker x$, so the refinement order on tuples descends to patterns without extra combinatorial input. The non-distributivity claim is settled at $n=3$ by exhaustive check, and the Möbius value by induction on the lattice structure. The value of this upgrade is that it supplies a computable, exhaustively enumerable encoding of the partition lattice, on which incidence-algebra computations can be run directly.

**(D3) Kernels as complete invariants for injections, not only permutations.** Theorem 2.7 shows the kernel is invariant under arbitrary injective relabelling, including relabellings between *different* alphabets, whereas the completeness Theorems 2.9 and 6.1 invert this only inside a single alphabet. The natural common generalisation: for arbitrary sets $\alpha,\beta$ and tuples $x \in \alpha^n$, $y \in \beta^n$, one should have $\operatorname{SameKer}(x,y)$ if and only if there exist a set $\gamma$, a tuple $z \in \gamma^n$ and injections $f : \gamma \hookrightarrow \alpha$, $g : \gamma \hookrightarrow \beta$ with $f \circ z = x$ and $g \circ z = y$; moreover the universal such $z$ should be the canonical form itself, with $\gamma = [n]$ and $z = \operatorname{can}(x)$. This would identify $\operatorname{can}$ as the terminal object of a comma category of injective relabellings, giving the canonical form a universal property rather than merely an ad-hoc definition.

**Further avenues.** Beyond (D1)–(D3): a $q$-analogue via patterns of tuples over a vector space (replacing equality by linear dependence); the analogous classification for the action of $\operatorname{Sym}(\alpha) \times \operatorname{Sym}([n])$ on tuples, whose invariant is the *multiset* of block sizes and whose count is the partition number $p(n)$; and asymptotics of the truncated rows $\sum_{k \le a} S(n,k)$, which for fixed $a$ grow like $a^{n}/a!$ and thus quantify precisely how much of the Bell count a bounded alphabet can see.

---

## 10. Summary of principal results

| Statement | Content |
|---|---|
| Invariance | $\operatorname{can}(f \circ x) = \operatorname{can}(x)$ for every injection $f$ |
| Completeness | Over any alphabet: same kernel $\iff$ same permutation orbit |
| Normal forms | Kernels $\leftrightarrow$ idempotent contracting retractions of $[n]$ |
| Classification | Patterns $\leftrightarrow$ equivalence relations on $[n]$ |
| Bell count | $|\mathcal{P}_n| = B_n$; first six values $1,1,2,5,15,52$ |
| Orbit count | $B_n$ orbits on $n$-tuples when $n \le |\alpha|$ |
| Stirling refinement | Patterns with $k$ blocks number $S(n,k)$; $\sum_k S(n,k) = B_n$ |
| Small alphabets | Orbit count $=\sum_{k\le|\alpha|}S(n,k)$; $2^{n}$ (binary) and $(3^{n}+1)/2$ (ternary) for length $n+1$ |
| Connection formula | $a^n = \sum_k S(n,k)\, a^{\underline{k}}$ |
| Invariant functions | $\dim_K \operatorname{Inv}_K(\beta,n) = B_n$ for $n \le |\beta|$ |
