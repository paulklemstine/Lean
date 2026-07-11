# Reliable Intuition as a Non-Computable Resource: Counting and Coding Barriers to a Ramanujan Oracle

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

Many of Srinivasa Ramanujan's identities were announced without proof and only later verified, suggesting a model of mathematical *intuition* as an **oracle**: a device that, presented with an encoded number-theoretic statement, returns a verdict — true or false — reliably but without a proof. We formalize an oracle as a Boolean-valued function on encoded statements and establish two complementary obstructions to such an oracle being computable. The first is a **cardinality obstruction**: by a diagonal argument the space of oracles admits no enumeration, whereas the computable oracles are countable, so a flawless oracle escapes any enumeration of programs. The second is a **quantitative combinatorial obstruction**: on a block of $N$ statements, a single oracle predicts correctly to within $d$ errors exactly for those truth patterns lying in a Hamming ball of radius $d$, whose size is the binomial partial sum $\sum_{k \le d}\binom{N}{k}$; consequently any family of oracles whose size is small compared to $2^N / \sum_{k\le d}\binom{N}{k}$ is *defeated* — some truth pattern is mispredicted with more than $d$ errors by every oracle in the family. Setting $d = N - m$ recasts "more than $d$ errors" as "accuracy below $m/N$," so a genuinely reliable oracle cannot be drawn from a small (for example, computably enumerable) pool. The bridge — Hamming balls from coding theory controlling the reach of an oracle from computability theory — is the cross-domain core. We close with conjectures relating reliable intuition to bi-immunity and to the Turing-jump hierarchy.

## 1. Introduction

In 1913, Ramanujan sent G. H. Hardy a series of letters containing dozens of identities in number theory and analysis, most stated without proof. A striking proportion turned out to be correct, their proofs supplied only later and often by others. This historical pattern motivates a question that can be made mathematically precise: if we model "intuition" as a reliable but proof-free verdict map on statements, can that map be an algorithm?

We answer in the negative, twice over. The two arguments are independent and illuminate different facets of the phenomenon.

- A **soft, cardinality-based** argument (Sections 3–4) shows that oracles are too numerous to enumerate, whereas programs are countable; hence a perfect oracle need not be computable, and indeed a diagonal construction exhibits, for any enumeration, a truth assignment whose perfect oracle escapes it.

- A **hard, quantitative** argument (Section 5) shows that even bounded-error reliability on a *finite* block forces an oracle into a small Hamming ball, so that any small family of oracles fails to cover all truth patterns. This turns non-computability into a concrete counting inequality with no appeal to infinity.

Throughout, statements are encoded as natural numbers, and an oracle (or truth assignment) is a function assigning a Boolean verdict to each encoded statement.

## 2. Definitions

**Definition 2.1 (Statement encoding).** Every mathematical statement is a finite string over a finite alphabet, and finite strings are placed in computable bijection with the natural numbers $\mathbb{N} = \{0, 1, 2, \dots\}$. We therefore identify the set of statements with $\mathbb{N}$ and write statement $n$ for the statement encoded by $n$.

**Definition 2.2 (Oracle).** An **oracle** is a function
$$
R : \mathbb{N} \to \{\text{false}, \text{true}\},
$$
equivalently a map $\mathbb{N} \to \{0, 1\}$. The same type of object serves as a **truth assignment** $T$, which we interpret as the ground truth: $T(n)$ is the actual truth value of statement $n$.

**Definition 2.3 (Accuracy and error).** On a finite block of statements indexed by $\{0, 1, \dots, N-1\}$, both an oracle $r$ and the truth $t$ restrict to strings in $\{0,1\}^N$. The **Hamming distance** $\operatorname{dist}(r, t)$ is the number of positions where they disagree. The oracle makes $d$ errors on the block if $\operatorname{dist}(r, t) = d$; its **accuracy** is $(N - \operatorname{dist}(r,t))/N$.

**Definition 2.4 (Computable oracle).** An oracle $R$ is **computable** if some algorithm, on input $n$, halts and outputs $R(n)$. Fixing a standard enumeration of programs induces an enumeration $\text{enum}: \mathbb{N} \to (\mathbb{N} \to \{0,1\})$ of the computable oracles; in particular the computable oracles form the range of a single map from $\mathbb{N}$, and are therefore countable. In what follows we model "the computable oracles" (or, more generally, any listable pool of methods) abstractly as the range of a fixed enumeration $\text{enum}$.

**Definition 2.5 (Hamming ball).** For $N, d \in \mathbb{N}$ and a center $r \in \{0,1\}^N$, the **Hamming ball** of radius $d$ is
$$
B_d(r) = \{\, t \in \{0,1\}^N : \operatorname{dist}(r,t) \le d \,\}.
$$

## 3. The space of oracles is not enumerable

**Theorem 3.1 (No enumeration of oracles).** There is no surjection $f : \mathbb{N} \to (\mathbb{N} \to \{0,1\})$. That is, no single list $R_0, R_1, R_2, \dots$ contains every oracle.

*Proof (Cantor diagonalization).* Suppose $f$ were such a surjection; write $R_n = f(n)$. Define an oracle $g$ by
$$
g(n) = \operatorname{not}\big(R_n(n)\big).
$$
By surjectivity there is $m$ with $f(m) = g$, hence $g(m) = R_m(m)$. But by definition $g(m) = \operatorname{not}(R_m(m))$, so $R_m(m) = \operatorname{not}(R_m(m))$, a contradiction on a Boolean value. Thus no surjection exists. $\qquad\blacksquare$

The space of oracles is uncountable, matching the uncountability of the reals: intuition ranges over uncountably many possible verdict-functions.

## 4. A perfect oracle escapes any enumeration of programs

Fix any enumeration $\text{enum}: \mathbb{N} \to (\mathbb{N} \to \{0,1\})$ — think of it as a listing of all computable oracles.

**Definition 4.1 (Diagonal oracle).** The **diagonal oracle** of $\text{enum}$ is
$$
D(n) = \operatorname{not}\big(\text{enum}(n)(n)\big).
$$

**Lemma 4.2 (Diagonal disagreement).** For every $n$, $D \ne \text{enum}(n)$.

*Proof.* If $D = \text{enum}(n)$ then evaluating at $n$ gives $D(n) = \text{enum}(n)(n)$; but $D(n) = \operatorname{not}(\text{enum}(n)(n))$, contradicting that a Boolean equals its own negation. $\qquad\blacksquare$

**Theorem 4.3 (Diagonal not in range).** $D \notin \operatorname{range}(\text{enum})$.

*Proof.* If $D = \text{enum}(n)$ for some $n$, Lemma 4.2 is violated at that $n$. $\qquad\blacksquare$

**Theorem 4.4 (A perfect oracle escapes).** For every enumeration $\text{enum}$ there exists a truth assignment $T$ (namely $T = D$) whose flawless oracle is not in $\operatorname{range}(\text{enum})$.

*Proof.* Take $T = D$ and apply Theorem 4.3. The oracle that agrees with $T$ everywhere is $T$ itself, which is not enumerated. $\qquad\blacksquare$

**Corollary 4.5 (Non-computability by counting).** Modeling the computable oracles as $\operatorname{range}(\text{enum})$, there is a truth assignment whose perfect oracle is not computable. A flawless intuition cannot be captured by any enumeration of algorithms.

This is the counting argument at the heart of the mission. It is decisive but qualitative: it requires *perfect* agreement and reasons about the infinite domain $\mathbb{N}$. Section 5 removes both limitations.

## 5. The quantitative accuracy barrier

We now work on a fixed finite block of $N$ statements, identifying oracles and truths with elements of $\{0,1\}^N$.

### 5.1 The size of a Hamming ball

**Lemma 5.1 (Subset counting).** The number of subsets of an $N$-element set with at most $d$ elements is
$$
\big|\{S \subseteq \{0,\dots,N-1\} : |S| \le d\}\big| = \sum_{k=0}^{d}\binom{N}{k}.
$$

*Proof.* Partition the subsets of size at most $d$ by their cardinality $k$, ranging over $k = 0, 1, \dots, d$. The subsets of size exactly $k$ number $\binom{N}{k}$, and these classes are disjoint; summing gives the claim. $\qquad\blacksquare$

**Theorem 5.2 (Ball-size formula).** For any center $r \in \{0,1\}^N$ and any $d$,
$$
|B_d(r)| = \sum_{k=0}^{d}\binom{N}{k},
$$
independent of the center $r$.

*Proof.* Map each $t \in B_d(r)$ to its **disagreement set** $S(t) = \{i : r_i \ne t_i\} \subseteq \{0,\dots,N-1\}$. Then $|S(t)| = \operatorname{dist}(r,t) \le d$, so $S(t)$ is a subset of size at most $d$. This map is a bijection: it is injective because $t$ is recovered from $r$ by flipping exactly the coordinates in $S(t)$, and surjective because for any subset $S$ of size $\le d$ the string obtained by flipping $r$ on $S$ lies in $B_d(r)$ and has disagreement set $S$. Hence $|B_d(r)|$ equals the number of subsets of size $\le d$, which is $\sum_{k\le d}\binom{N}{k}$ by Lemma 5.1. $\qquad\blacksquare$

**Lemma 5.3 (Cube size).** $|\{0,1\}^N| = 2^N$.

**Lemma 5.4 (Proper balls are strictly smaller than the cube).** If $d < N$ then $|B_d(r)| < 2^N$.

*Proof.* By Vandermonde's identity $\sum_{k=0}^{N}\binom{N}{k} = 2^N$. Splitting the sum at $d$,
$$
2^N = \sum_{k=0}^{d}\binom{N}{k} + \sum_{k=d+1}^{N}\binom{N}{k},
$$
and the second sum is strictly positive because $d < N$ makes it contain at least the term $\binom{N}{d+1} > 0$. Hence $\sum_{k\le d}\binom{N}{k} < 2^N$, i.e. $|B_d(r)| < 2^N$. $\qquad\blacksquare$

### 5.2 Small families are defeated

**Theorem 5.5 (Accuracy barrier).** Fix $N$ and an error budget $d < N$. Let $F \subseteq \{0,1\}^N$ be a finite family of oracles with
$$
|F| \cdot \sum_{k=0}^{d}\binom{N}{k} < 2^N.
$$
Then there exists a truth pattern $t \in \{0,1\}^N$ such that for every $r \in F$,
$$
\operatorname{dist}(r, t) > d.
$$

*Proof (covering / pigeonhole).* Let $\text{covered} = \bigcup_{r \in F} B_d(r)$ be the set of truth patterns predicted with at most $d$ errors by *some* oracle in $F$. By the union bound and the ball-size formula (Theorem 5.2),
$$
|\text{covered}| \le \sum_{r \in F} |B_d(r)| = |F|\cdot \sum_{k=0}^{d}\binom{N}{k} < 2^N = |\{0,1\}^N|.
$$
Since $\text{covered}$ has fewer elements than the full cube, some pattern $t \in \{0,1\}^N$ is not covered. Being uncovered means $t \notin B_d(r)$ for all $r \in F$, i.e. $\operatorname{dist}(r,t) > d$ for every $r \in F$. $\qquad\blacksquare$

**Corollary 5.6 (Reliability requires a large pool).** Writing accuracy as $m/N$ with $m = N - d$: if
$$
|F| < \frac{2^N}{\sum_{k=0}^{N-m}\binom{N}{k}},
$$
then some truth pattern is predicted with accuracy strictly below $m/N$ by *every* oracle in $F$. In particular no oracle in $F$ attains accuracy $m/N$ on that pattern.

**Corollary 5.7 (The $95\%$ barrier).** Take $m = \lceil 0.95\,N \rceil$, so $d = N - m \approx 0.05\,N$. As $N$ grows, $\sum_{k \le 0.05N}\binom{N}{k}$ grows only sub-exponentially in $N$ (its exponential rate is $2^{H(0.05)N}$ with binary entropy $H(0.05) \approx 0.286$), so the covering threshold $2^N/\sum_{k\le 0.05N}\binom{N}{k} \approx 2^{(1 - 0.286)N} = 2^{0.714 N}$ grows exponentially. Any family $F$ of sub-exponential size — in particular any pool of oracles drawn from a fixed finite prefix of a program enumeration — is eventually defeated: for large $N$ some truth pattern on the block is predicted with accuracy below $95\%$ by every oracle in $F$.

### 5.3 Why one-half is the threshold

The binary entropy function $H(p) = -p\log_2 p - (1-p)\log_2(1-p)$ governs the exponential growth of Hamming balls: $\sum_{k\le pN}\binom{N}{k} = 2^{H(p)N + o(N)}$ for $p \le 1/2$. Since $H(1/2) = 1$, a ball of radius $N/2$ fills essentially the whole cube, and a single (even constant) oracle covers almost all patterns — accuracy $1/2$ is free. For any target accuracy $\alpha > 1/2$ the relevant radius is $(1-\alpha)N < N/2$, giving $H(1-\alpha) < 1$ and a covering threshold $2^{(1 - H(1-\alpha))N}$ that is exponentially large. The transition from "trivial" to "requires an exponential pool" occurs precisely at $\alpha = 1/2$.

## 6. Algorithms

The results above are constructive and yield concrete algorithms, useful both for verification on small blocks and for exhibiting explicit hard instances.

**Algorithm A (Ball-size and threshold).** Given $N$ and $d$, compute $\sum_{k=0}^d \binom{N}{k}$ by an $O(d)$ multiplicative recurrence on binomial coefficients, and compare $|F|\cdot\sum_{k\le d}\binom{N}{k}$ against $2^N$ to certify whether a family of a given size *must* be defeated. Complexity $O(d)$ big-integer operations.

**Algorithm B (Diagonal oracle).** Given black-box access to an enumeration $\text{enum}$, the diagonal oracle $D(n) = \operatorname{not}(\text{enum}(n)(n))$ is computed pointwise; on each input it queries one listed oracle. This exhibits, on demand, an oracle differing from every listed one.

**Algorithm C (Uncovered-pattern search).** Given an explicit family $F \subseteq \{0,1\}^N$ with $|F|\cdot\sum_{k\le d}\binom{N}{k} < 2^N$, enumerate the $2^N$ patterns and return the first $t$ with $\operatorname{dist}(r,t) > d$ for all $r \in F$. Theorem 5.5 guarantees success. Naive complexity $O(2^N\cdot |F|\cdot N)$; for small $N$ this is a direct constructive witness to the barrier.

## 7. Applications and interpretation

The framework offers a precise vocabulary for a long-standing intuition about intuition.

- **Discovery without proof.** Ramanujan's practice — reliable verdicts unaccompanied by derivations — is exactly an accurate oracle. Our results say such reliability cannot be reduced to any single listable method: it is a genuinely non-algorithmic resource.

- **Limits of automated conjecture-generation.** Any finite ensemble of heuristics, learned models, or enumerated programs is a family $F$. Corollary 5.6 caps the accuracy such an ensemble can *guarantee* across all truth patterns of a block: to force accuracy $\alpha > 1/2$ on every possible world requires an ensemble of exponential size. High worst-case reliability is expensive by counting alone.

- **Coding-theoretic reading.** An oracle is a codeword; "predicting a truth pattern with $\le d$ errors" is decoding within radius $d$; a family that covers all patterns is a *covering code*. The accuracy barrier is the sphere-covering bound: covering codes of small size do not exist below the volume threshold. Reliable intuition is the demand for an impossibly efficient covering code.

## 8. Discussion

Two obstructions, one conclusion. The cardinality obstruction (Sections 3–4) is clean and absolute but requires perfection and infinity. The counting obstruction (Section 5) is finite, quantitative, and robust to the exact notion of "small pool," at the cost of speaking about worst-case truth patterns rather than a fixed one. Together they argue that reliable, proof-free mathematical intuition — if it is reliable in the strong, worst-case sense — cannot be an algorithm drawn from any list we could write.

A caveat sharpens the claim rather than weakening it. The counting barrier concerns worst-case truth patterns: for a *particular* structured truth assignment a clever algorithm might do well. The barrier says no fixed small pool is uniformly reliable across all possible worlds, which is exactly the sense in which a general-purpose "oracle for number theory" is being sought.

## 9. Future directions

**A sharp accuracy–enumeration tradeoff.** For every accuracy level $\alpha \in (1/2, 1)$ there should be a truth assignment on the integers such that no uniformly enumerated family of oracles of subexponential growth attains asymptotic accuracy $\alpha$ on the length-$N$ prefixes as $N \to \infty$; and this fails exactly at $\alpha = 1/2$, where trivial constant oracles suffice. The Hamming-ball count $\sum_{k\le(1-\alpha)N}\binom{N}{k}$ collapses super-polynomially once $\alpha > 1/2$, so the number of oracles required to cover all patterns crosses from polynomial to exponential precisely at $1/2$. The finite covering threshold $2^N/\sum_{k\le d}\binom{N}{k}$ proved here is exactly the quantity to promote to an asymptotic density statement via a limiting argument over growing blocks.

**Bi-immune truth assignments as intuition-hard instances.** There should exist truth assignments whose length-$N$ prefixes cannot be predicted by any single computable oracle with accuracy bounded away from $1/2$ on a set of prefixes of positive density — a block-wise strengthening of non-computability. Combining the per-block ball bound with diagonalization over programs should yield functions that are not merely non-computable but *approximation-resistant*: every algorithm eventually performs no better than coin-flipping on infinitely many blocks. The exact ball-size formula makes the per-block failure probability explicit, so the classical bi-immunity construction can be driven quantitatively.

**Intuition and the jump hierarchy.** Grading truth assignments by the least oracle-degree that predicts their prefixes with accuracy $\alpha \to 1$ should induce a strictly increasing hierarchy interleaving with the Turing-jump hierarchy: each jump level unlocks a new band of attainable accuracies, and no finite jump suffices for perfect prefix prediction of a sufficiently generic assignment. The "intuitive leap" would then be not a single non-computable act but a *graded* resource, with higher reliability costing strictly more oracle power, mirroring the strict increase of the jump operator. With the accuracy barrier established as a counting phenomenon, relativizing the same count to an oracle is the natural route.

## 10. Conclusion

We modeled Ramanujan-style intuition as a Boolean verdict map on encoded statements and proved it cannot be computable, for two independent reasons: the oracles are uncountable while programs are countable (a diagonal argument), and reliability confines an oracle to a Hamming ball of size $\sum_{k\le d}\binom{N}{k}$ so that small pools are defeated (a covering argument). The bridge between coding theory and computability — balls controlling the reach of an oracle — is what makes the second, quantitative barrier possible, and it locates the "intuitive leap" precisely: just beyond the countable world of algorithms, on the far side of the one-half accuracy cliff.
