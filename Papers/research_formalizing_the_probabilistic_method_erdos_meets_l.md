# The Constructive Core of the Probabilistic Method: Ramsey Lower Bounds, the Lovász Local Lemma, and Turán's Theorem

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

The probabilistic method proves the existence of combinatorial objects by exhibiting a probability space in which a random object has the desired property with positive probability. We present a unified, self-contained development of three pillars of the method, emphasizing throughout that the underlying arguments are *constructive* — finite counting statements in disguise. First, we prove Erdős's exponential lower bound on the diagonal Ramsey numbers, $R(k,k) > 2^{k/2}$, entirely by a finite union-bound count over edge-colorings, with no appeal to measure theory. Second, we develop the measure-theoretic backbone of the probabilistic method in a general probability space: the first-moment (union-bound) existence principle, the independent case of the Lovász Local Lemma (yielding the exact product formula $P(\bigcap A_i^c) = \prod (1 - P(A_i))$), and a general **chain-rule positivity principle** that isolates the essential inductive content of the Local Lemma under a single conditional-avoidability hypothesis. Third, we package Turán's theorem in its classical real-analytic form, bounding the edges of a $K_{r+1}$-free graph by $(1 - 1/r)n^2/2$, with the bound achieved constructively by the Turán graph. We conclude with the algorithmic reading of these results — the Moser–Tardos resampling perspective — and discuss the sense in which Erdős's existence proofs are algorithms in disguise.

**Keywords:** probabilistic method, Ramsey numbers, Lovász Local Lemma, Turán's theorem, first-moment method, union bound, extremal graph theory, constructive existence.

---

## 1. Introduction

Since Erdős's 1947 note on the Ramsey numbers, the *probabilistic method* has grown from a single ingenious trick into a systematic engine of existence proofs across combinatorics, number theory, and theoretical computer science. Its logical shape is always the same: to prove that an object with a desired property $P$ exists, construct a probability space of candidate objects and show

$$P(\text{a random candidate has property } P) > 0.$$

An event of positive probability is nonempty, so a candidate with property $P$ must exist.

This paper assembles a coherent treatment of three landmark applications and the abstract principles beneath them, with two guiding themes.

1. **Unification.** The Ramsey lower bound, the Lovász Local Lemma, and (dually) Turán's theorem are usually taught as separate episodes. We present them from a common vantage: a small toolkit of positivity principles — the union bound, the independence product formula, and a chain-rule induction — from which the concrete results follow.

2. **Constructivity.** We stress that these existence proofs, despite their probabilistic framing, are finite and constructive at heart. The Ramsey bound is proved by counting colorings directly, without probability spaces. Turán's optimum is attained by an explicit graph. And the Local Lemma admits an algorithmic (Moser–Tardos) reading. Erdős's "non-constructive" proofs are, on inspection, algorithms wearing the costume of chance.

The remainder of the paper is organized as follows. Section 2 fixes notation. Section 3 develops the finite counting proof of the Ramsey lower bound. Section 4 develops the measure-theoretic principles: the first-moment method, the independent Local Lemma, and the chain-rule positivity principle. Section 5 treats Turán's theorem. Section 6 discusses algorithms and constructivity, and Section 7 lists open directions.

---

## 2. Preliminaries and Notation

For a natural number $n$ we write $[n] = \{0, 1, \dots, n-1\}$ for a set of $n$ vertices, and $K_n$ for the complete graph on $[n]$, whose edge set has size $\binom{n}{2}$. An **edge two-coloring** of $K_n$ is a function $c$ assigning to each unordered pair of distinct vertices a color in $\{\text{red}, \text{blue}\}$ (equivalently a Boolean).

Given a vertex set $S \subseteq [n]$, its **internal edge set** $E(S)$ consists of the unordered pairs of *distinct* vertices both lying in $S$; we have $|E(S)| = \binom{|S|}{2}$. A set $S$ is **monochromatic** under $c$ if all edges of $E(S)$ receive a single common color.

**Definition 2.1 (Arrow relation).** We say $n \to (k,k)$, read "$n$ arrows $(k,k)$," if *every* edge two-coloring of $K_n$ contains a monochromatic $k$-clique, i.e. some $k$-element set $S$ that is monochromatic. The diagonal Ramsey number is $R(k,k) = \min\{n : n \to (k,k)\}$. Thus $R(k,k) > n$ is *precisely* the statement $\neg\,(n \to (k,k))$: there exists a coloring of $K_n$ with no monochromatic $k$-clique.

For the measure-theoretic sections, we work over an arbitrary probability space $(\Omega, \mathcal{F}, \mu)$ with $\mu(\Omega) = 1$, and a finite family of measurable "bad events" $A_i \subseteq \Omega$, $i \in \iota$, where $\iota$ is a finite index set. We write $A_i^c$ for the complement. The object of interest is the "all good" event $\bigcap_i A_i^c$.

---

## 3. Erdős's Ramsey Lower Bound by Finite Counting

We prove $R(k,k) > 2^{k/2}$ by pure counting over the finite set of colorings, making the argument manifestly constructive.

### 3.1 The counting theorem

Let $N = \binom{n}{2}$ be the total number of edges of $K_n$, so there are exactly $2^N$ edge two-colorings.

**Lemma 3.1 (Internal edge count).** For any vertex set $S$, the number of internal edges is $|E(S)| = \binom{|S|}{2}$.

*Proof.* Internal edges of $S$ are exactly the two-element subsets of $S$, and there are $\binom{|S|}{2}$ of them. $\square$

**Lemma 3.2 (Union-bound count).** Fix a $k$-element vertex set $S$. The number of edge two-colorings under which $S$ is monochromatic is at most

$$2 \cdot 2^{\,N - \binom{k}{2}}.$$

*Proof.* A coloring making $S$ monochromatic is determined by two independent choices: (i) the single common color assigned to all $\binom{k}{2}$ internal edges of $S$ (2 choices), and (ii) an arbitrary assignment of colors to the remaining $N - \binom{k}{2}$ edges (at most $2^{N - \binom{k}{2}}$ choices). Formally, restricting a monochromatic-on-$S$ coloring to the edges *outside* $E(S)$ is injective once the common color is fixed, and there are two possible common colors; summing the two cases and bounding each restriction count by the total number of assignments of the outside edges gives the claim. $\square$

**Theorem 3.3 (Erdős's counting theorem).** Let $2 \le k \le n$. If

$$2 \cdot \binom{n}{k} < 2^{\binom{k}{2}},$$

then $\neg\,(n \to (k,k))$; equivalently $R(k,k) > n$.

*Proof.* Suppose for contradiction that $n \to (k,k)$: every coloring has a monochromatic $k$-set. Then every one of the $2^N$ colorings lies in the union, over all $k$-sets $S$, of the sets $M_S = \{c : S \text{ is monochromatic under } c\}$. Hence

$$2^N \;\le\; \sum_{|S| = k} |M_S| \;\le\; \binom{n}{k} \cdot 2 \cdot 2^{N - \binom{k}{2}},$$

using Lemma 3.2 and that there are $\binom{n}{k}$ vertex sets of size $k$. Dividing by $2^{N - \binom{k}{2}}$ yields $2^{\binom{k}{2}} \le 2\binom{n}{k}$, contradicting the hypothesis. Therefore some coloring avoids every monochromatic $k$-set. $\square$

The proof is a first-moment argument stated in the language of counting: $2\binom{n}{k}2^{-\binom{k}{2}}$ is exactly the expected number of monochromatic $k$-cliques under a uniformly random coloring, and Theorem 3.3 says that when this expectation is below one, a clique-free coloring exists. No probability space is required; the entire argument is a finite inequality between cardinalities.

### 3.2 The explicit exponential bound

To turn Theorem 3.3 into an explicit growth rate we choose $n = 2^{\lfloor k/2 \rfloor}$ and verify the hypothesis. Two elementary estimates do the work.

**Lemma 3.4 (Exponent inequality).** For all $k$, $\;\lfloor k/2 \rfloor \cdot k \le \binom{k}{2} + \lfloor k/2 \rfloor$. (Equality for even $k$; slack for odd $k$.)

**Lemma 3.5 (Factorial lower bound).** For $k \ge 3$, $\;2^{\lfloor k/2\rfloor + 1} < k!$.

**Theorem 3.6 (Number-theoretic core).** For $k \ge 3$ and $n = 2^{\lfloor k/2\rfloor}$,

$$2 \cdot \binom{n}{k} < 2^{\binom{k}{2}}.$$

*Proof sketch.* Using $\binom{n}{k} \le n^k / k!$ (from $n^{\underline{k}} = k!\binom{n}{k}$ and $n^{\underline{k}} \le n^k$) we get $k!\cdot 2\binom{n}{k} \le 2 n^k$. Since $n = 2^{\lfloor k/2\rfloor}$, Lemma 3.4 gives $2n^k = 2^{1 + \lfloor k/2\rfloor k} \le 2^{\binom{k}{2} + \lfloor k/2\rfloor + 1}$. Finally Lemma 3.5 gives $2^{\lfloor k/2\rfloor + 1} < k!$, so $2^{\binom{k}{2} + \lfloor k/2\rfloor + 1} < k! \cdot 2^{\binom{k}{2}}$. Chaining, $k!\cdot 2\binom{n}{k} < k!\cdot 2^{\binom{k}{2}}$, and cancelling $k! > 0$ yields the claim. $\square$

**Corollary 3.7 (Erdős's lower bound).** For $k \ge 3$,

$$R(k,k) > 2^{k/2}.$$

*Proof.* Combine Theorem 3.6 with Theorem 3.3 at $n = 2^{\lfloor k/2\rfloor}$ (handling the trivial regime $k > 2^{\lfloor k/2\rfloor}$ separately, where no $k$-set fits and the arrow relation fails outright). $\square$

**Concrete instances.** The counting theorem yields exact small cases directly:

- $R(4,4) > 5$: since $2\binom{5}{4} = 10 < 2^{\binom{4}{2}} = 2^6 = 64$, there is a red/blue coloring of $K_5$ with no monochromatic $K_4$. Hence $R(4,4) \ge 6$.
- $R(6,6) > 8$: since $2\binom{8}{6} = 56 < 2^{\binom{6}{2}} = 2^{15} = 32768$, there is a coloring of $K_8$ with no monochromatic $K_6$.

---

## 4. The Probabilistic Method in a General Probability Space

We now record the abstract positivity principles, valid over any probability space $(\Omega, \mathcal{F}, \mu)$ with finitely many measurable bad events $\{A_i\}_{i \in \iota}$.

### 4.1 The first-moment / union-bound principle

**Theorem 4.1 (First-moment positivity).** If $\sum_{i} \mu(A_i) < 1$, then

$$\mu\!\left(\bigcap_i A_i^c\right) > 0.$$

*Proof.* By finite subadditivity, $\mu(\bigcup_i A_i) \le \sum_i \mu(A_i) < 1$. Since $\bigcap_i A_i^c = (\bigcup_i A_i)^c$ and $\mu$ is a probability measure, $\mu(\bigcap_i A_i^c) = 1 - \mu(\bigcup_i A_i) > 0$. $\square$

**Corollary 4.2 (Probabilistic method).** If $\sum_i \mu(A_i) < 1$, there exists an outcome $\omega \in \Omega$ with $\omega \notin A_i$ for every $i$.

*Proof.* An event of positive measure is nonempty; take any point of $\bigcap_i A_i^c$. $\square$

This is the exact abstraction of the Ramsey argument of Section 3: with $\Omega$ the uniform space of colorings and $A_i$ the event "clique $i$ is monochromatic," the hypothesis $\sum_i \mu(A_i) < 1$ is $2\binom{n}{k}2^{-\binom{k}{2}} < 1$.

### 4.2 The Lovász Local Lemma: independent case

When the bad events are mutually independent, we get an exact formula rather than an inequality.

**Theorem 4.3 (Independent LLL, product formula).** If the events $\{A_i\}$ are mutually independent, then

$$\mu\!\left(\bigcap_i A_i^c\right) = \prod_i \bigl(1 - \mu(A_i)\bigr).$$

*Proof.* Mutual independence of the $A_i$ is inherited by their complements $A_i^c$; applying the independence multiplication rule to the finite family $\{A_i^c\}$ gives $\mu(\bigcap_i A_i^c) = \prod_i \mu(A_i^c)$, and $\mu(A_i^c) = 1 - \mu(A_i)$ since $\mu$ is a probability measure. $\square$

**Corollary 4.4 (Independent LLL, positivity).** If the $\{A_i\}$ are mutually independent and $\mu(A_i) < 1$ for every $i$, then $\mu(\bigcap_i A_i^c) > 0$; hence some outcome avoids all $A_i$.

*Proof.* Each factor $1 - \mu(A_i)$ is strictly positive, so their finite product is strictly positive. $\square$

This is the Local Lemma in the dependency-degree $d = 0$ regime. The requirement is dramatically weaker than the union bound: no constraint on the *sum* of probabilities, only that each individually is below $1$.

### 4.3 The chain-rule positivity principle

The genuine content of the Local Lemma is to reach the positivity conclusion $\mu(\bigcap_i A_i^c) > 0$ *without* assuming full independence. We isolate the measure-theoretic backbone common to every such argument: a greedy, chain-rule induction under a single conditional hypothesis.

**Definition 4.5 (Conditional avoidability).** The family $\{A_i\}$ is *conditionally avoidable* if for every finite set $S \subseteq \iota$ of indices and every $i \notin S$,

$$\mu\!\left(\bigcap_{j \in S} A_j^c\right) > 0 \;\;\Longrightarrow\;\; \mu\!\left(A_i \cap \bigcap_{j \in S} A_j^c\right) < \mu\!\left(\bigcap_{j \in S} A_j^c\right).$$

Equivalently, the conditional probability $\mu(A_i \mid \bigcap_{j\in S} A_j^c) < 1$: no single bad event fills up the space of outcomes already surviving $S$.

**Theorem 4.6 (Chain-rule positivity, induction form).** If $\{A_i\}$ is conditionally avoidable, then for *every* finite $S \subseteq \iota$,

$$\mu\!\left(\bigcap_{j \in S} A_j^c\right) > 0.$$

*Proof.* Induction on $S$. For $S = \emptyset$ the intersection is $\Omega$, of measure $1 > 0$. For the inductive step, insert a new index $i \notin S$ into a set with $\mu(\bigcap_{j\in S} A_j^c) > 0$. Write

$$\bigcap_{j \in S \cup \{i\}} A_j^c \;=\; A_i^c \cap \bigcap_{j\in S} A_j^c \;=\; \Bigl(\bigcap_{j\in S} A_j^c\Bigr) \setminus \Bigl(A_i \cap \bigcap_{j\in S} A_j^c\Bigr).$$

By the difference rule for measures, its measure equals $\mu(\bigcap_{j\in S} A_j^c) - \mu(A_i \cap \bigcap_{j\in S} A_j^c)$, which is strictly positive by the conditional-avoidability hypothesis applied to $S$ and $i$. $\square$

**Theorem 4.7 (Chain-rule LLL).** If $\{A_i\}_{i\in\iota}$ (with $\iota$ finite) is conditionally avoidable, then

$$\mu\!\left(\bigcap_{i} A_i^c\right) > 0,$$

and consequently there exists an outcome $\omega$ with $\omega \notin A_i$ for all $i$.

*Proof.* Apply Theorem 4.6 with $S = \iota$; positivity gives nonemptiness, hence the witnessing outcome. $\square$

Theorem 4.7 is the reusable core of the Local Lemma: dependency-graph bookkeeping is entirely abstracted into Definition 4.5. Specializing to independent events, the conditional probability $\mu(A_i \mid \bigcap_{j\in S} A_j^c)$ equals the unconditional $\mu(A_i) < 1$, recovering Corollary 4.4. For the full asymmetric Local Lemma with degree $d$ and $e\,p\,(d+1) \le 1$, the remaining work is precisely to *verify* Definition 4.5 via the standard conditional-probability induction $\mu(A_i \mid \bigcap_{j\in S} A_j^c) \le 2p$ — a program we outline in Section 7.

---

## 5. Turán's Theorem: the Extremal Dual

The probabilistic method produces objects that *avoid* structure. Its extremal dual asks how much structure can be packed in before an unavoidable clique appears. The archetype is Turán's theorem.

**Definition 5.1.** A graph $G$ is $K_{r+1}$-*free* (clique-free of order $r+1$) if it contains no $r+1$ pairwise-adjacent vertices.

**Definition 5.2 (Turán graph).** The Turán graph $T(n, r)$ is the complete $r$-partite graph on $n$ vertices whose parts are as equal in size as possible (each of size $\lfloor n/r\rfloor$ or $\lceil n/r\rceil$): two vertices are adjacent iff they lie in different parts. It is $K_{r+1}$-free, since any clique uses at most one vertex from each of the $r$ parts.

**Theorem 5.3 (Turán, combinatorial form).** Let $G$ be a $K_{r+1}$-free graph on $n$ vertices with $r \ge 1$. Then

$$2r \cdot |E(G)| \;\le\; (r-1)\, n^2.$$

*Proof sketch.* Among all $K_{r+1}$-free graphs on $n$ vertices there is an edge-maximal one, and it is isomorphic to the Turán graph $T(n,r)$. Thus $|E(G)|$ is at most the number of edges of $T(n,r)$, and a direct count of the complete $r$-partite graph with balanced parts gives $2r \cdot |E(T(n,r))| \le (r-1)n^2$. Chaining the two inequalities yields the bound. $\square$

**Theorem 5.4 (Turán, real-analytic form).** Under the hypotheses of Theorem 5.3,

$$|E(G)| \;\le\; \left(1 - \frac{1}{r}\right)\frac{n^2}{2}.$$

*Proof.* Divide the inequality of Theorem 5.3 by $2r > 0$ and simplify $\frac{(r-1)n^2}{2r} = \bigl(1 - \tfrac1r\bigr)\tfrac{n^2}{2}$. $\square$

Two features distinguish Turán's theorem from the probabilistic results. First, the bound is *tight*: it is attained exactly by the Turán graph $T(n,r)$ when $r \mid n$. Second, existence of the extremal object is fully *constructive* — the champion is written down explicitly. Where Ramsey's lower bound guarantees a clique-free coloring somewhere in an exponential haystack, Turán's theorem hands you the optimizer directly.

---

## 6. Algorithms and Constructivity

A recurring criticism of the probabilistic method is that it proves existence without exhibiting the object. The results above show this criticism is largely superficial.

**Ramsey is counting.** Theorem 3.3 makes no reference to probability: it is an inequality between the cardinality $2^N$ of all colorings and the sum of cardinalities $|M_S|$. In principle one could certify a clique-free coloring of $K_n$ by exhaustive or guided search over the finite space of colorings; the counting theorem guarantees the search is nonempty. The probabilistic phrasing is a convenience, not a necessity.

**Turán is explicit.** The extremal graph is $T(n,r)$, constructed directly. No search is needed at all.

**The Local Lemma is an algorithm.** The most striking modern development is the Moser–Tardos theorem: the existence conclusion of the Local Lemma is realized by a simple randomized *resampling algorithm*. In the variable model — where each bad event $A_i$ depends on a subset of independent random variables — the procedure is:

1. Sample all variables.
2. While some bad event $A_i$ currently holds, pick one and resample exactly the variables it depends on.
3. Output the assignment when no bad event holds.

Under the Local Lemma condition $e\,p\,(d+1) \le 1$, this loop terminates in an expected number of resamplings bounded (roughly) linearly in the number of events, by an *entropy-compression* / witness-tree argument: an execution that resampled too often could be encoded in fewer bits than its own randomness, an impossibility. Thus the Local Lemma is not an oracle but a constructive procedure with a proved expected running-time bound.

The unifying moral: Erdős's "non-constructive" proofs were algorithms in disguise. Behind the coin flips lies arithmetic; behind the arithmetic, a construction.

---

## 7. Discussion and Future Directions

The development above cleanly separates the *abstract positivity engine* (Section 4) from the *concrete instantiations* (Sections 3 and 5). This separation suggests several natural continuations.

1. **General (asymmetric) Lovász Local Lemma.** With the chain-rule positivity principle (Theorem 4.7) in place, the remaining work is to verify its conditional hypothesis (Definition 4.5) from a dependency graph of maximum degree $d$ satisfying $e\,p\,(d+1) \le 1$. The standard route is the induction on conditional probabilities $\mu(A_i \mid \bigcap_{j\in S} A_j^c) \le 2p$; this requires developing conditional-probability estimates and the mutual-independence-from-non-neighbours hypothesis on top of a general probability framework.

2. **Moser–Tardos constructive LLL.** Formalize the resampling algorithm and its expected $O(n \cdot d)$ running-time bound (the witness-tree / entropy-compression argument), turning the existence statement into an algorithm with a proved termination bound.

3. **Ramsey numbers as a defined quantity.** Combine the arrow relation and the counting bounds to define $R(k,k)$ as a genuine numerical invariant and derive both the lower bound $R(k,k) > 2^{k/2}$ and matching small-case computations within one framework.

4. **Higher moments and the Lovász sieve.** Extend the first-moment principle to second-moment and Janson-type inequalities, capturing concentration phenomena beyond mere positivity.

5. **Off-diagonal and hypergraph Ramsey bounds.** Generalize the counting theorem of Section 3 to $R(s,t)$ and to $r$-uniform hypergraphs, where the same union-bound skeleton applies with adjusted exponents.

---

## 8. Conclusion

We have presented a unified, self-contained account of three pillars of the probabilistic method: Erdős's exponential Ramsey lower bound $R(k,k) > 2^{k/2}$ proved by finite counting; a general measure-theoretic toolkit comprising the first-moment principle, the independent Lovász Local Lemma with its exact product formula, and a chain-rule positivity principle abstracting the Local Lemma's inductive core; and Turán's theorem in its classical real-analytic form with its explicit extremal graph. Throughout, the emphasis has been on constructivity: these celebrated existence results are, at bottom, finite counting statements and explicit constructions — algorithms in the costume of chance.
