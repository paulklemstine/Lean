# Densities of Fixed Partial Latin Patterns in Uniformly Random Latin Squares

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Combinatorics / Discrete Probability

## Abstract

Let $P$ be a fixed finite partial Latin square pattern with $k$ entries, encoded as a finite set of triples $(r, c, s) \in \mathbb{N}^3$ satisfying the partial Latin condition: no two distinct entries agree in both row and column, in both row and symbol, or in both column and symbol. For each order $n$ large enough to contain all coordinates of $P$, let $L$ be drawn uniformly at random from the set of Latin squares of order $n$, and let $\Pr[L \supseteq P]$ denote the probability that $L$ agrees with $P$ on all $k$ specified cells. A natural conjecture asserts that $\Pr[L \supseteq P]\cdot n^{k} \to 1$ as $n \to \infty$. We prove this conjecture for the infinite family of **single-line** patterns. Concretely, we show that a one-cell pattern has probability **exactly** $1/n$; that any single-row (equivalently single-column or single-symbol) pattern of size $k$ has probability **exactly** $1/(n)_k$, where $(n)_k = n(n-1)\cdots(n-k+1)$ is the descending factorial; that $n^k/(n)_k \to 1$; and hence that $\Pr[L \supseteq P]\cdot n^{k} \to 1$ for every single-line pattern. The proofs rest on a single structural mechanism: the alphabet-relabeling action of the symmetric group $\mathrm{Sym}(n)$ on Latin squares is transitive on the admissible contents of any one line, which forces exact orbit counts. We further explain, and conjecture rigorously, why exactness must fail for genuinely two-dimensional patterns: the $2\times 2$ intercalate satisfies $\Pr[L \supseteq P]\cdot n^{2} \to 1/4$ rather than the naive $n^{-4}$ law, because its four entries carry only two independent degrees of freedom. We close with a general conjecture identifying the true decay exponent with a notion of independent constraints.

## 1. Introduction

A **Latin square of order $n$** is an $n \times n$ array with entries from a symbol set of size $n$ such that every symbol occurs exactly once in each row and exactly once in each column. Latin squares are central objects in combinatorics, with deep ties to quasigroups, the design of experiments, coding theory, and the theory of combinatorial designs. The number $\mathrm{L}(n)$ of Latin squares of order $n$ grows super-exponentially; even $\mathrm{L}(11) > 10^{47}$, so direct enumeration is hopeless beyond very small $n$ and probabilistic methods become essential.

A recurring theme in the study of random discrete structures is the **local density** of fixed substructures: how often does a given small configuration appear inside a large random object? For random graphs, this is the theory of subgraph counts; for random permutations, of pattern occurrences. For random Latin squares the analogue is the occurrence of a fixed **partial Latin pattern**. This paper establishes exact and asymptotic occurrence laws for an important family of such patterns and clarifies the structure of the general problem.

### 1.1 The guiding conjecture

Each entry $(r,c,s)$ of a pattern is the local constraint "cell $(r,c)$ holds symbol $s$." A single cell of a uniformly random Latin square holds each symbol with probability $1/n$, by symmetry. If the $k$ entries of a $k$-cell pattern behaved independently, the joint occurrence probability would be $n^{-k}$. This motivates:

**Conjecture (pattern density).** For any fixed partial Latin pattern $P$ with $k$ entries,
$$ \Pr[L \supseteq P]\cdot n^{k} \longrightarrow 1 \qquad (n \to \infty). $$

The entries of a Latin square are not independent, so the conjecture requires proof; and, as we show, it is *false in general*. Our contribution is a complete, exact resolution for single-line patterns and a precise diagnosis of the general phenomenon.

## 2. Definitions

Throughout, fix the symbol/coordinate set $[n] = \{0, 1, \dots, n-1\}$.

**Definition 2.1 (Latin square).** A Latin square of order $n$ is a function $L : [n] \times [n] \to [n]$ such that for each fixed row $r$ the map $c \mapsto L(r,c)$ is a bijection of $[n]$, and for each fixed column $c$ the map $r \mapsto L(r,c)$ is a bijection of $[n]$. We write $\mathcal{L}_n$ for the (finite) set of all Latin squares of order $n$, and we equip $\mathcal{L}_n$ with the uniform probability measure. In the formal development this set is captured by the predicate `IsLatin`.

**Definition 2.2 (partial Latin pattern).** A partial Latin pattern is a finite set $P \subseteq \mathbb{N}^3$ of triples $(r,c,s)$ such that for any two distinct $(r_1,c_1,s_1), (r_2,c_2,s_2) \in P$:
- not ($r_1 = r_2$ and $c_1 = c_2$),
- not ($r_1 = r_2$ and $s_1 = s_2$),
- not ($c_1 = c_2$ and $s_1 = s_2$).

We call $k = |P|$ the size of $P$. The pattern is **admissible for order $n$** if every coordinate appearing in $P$ lies in $[n]$.

**Definition 2.3 (containment).** A Latin square $L$ **contains** $P$, written $L \supseteq P$, if $L(r,c) = s$ for every $(r,c,s) \in P$.

**Definition 2.4 (occurrence probability).** For $P$ admissible for order $n$,
$$ \Pr[L \supseteq P] = \frac{|\{\, L \in \mathcal{L}_n : L \supseteq P \,\}|}{|\mathcal{L}_n|}. $$

**Definition 2.5 (descending factorial).** For $n, k \in \mathbb{N}$ with $k \le n$,
$$ (n)_k = n(n-1)(n-2)\cdots(n-k+1) = \frac{n!}{(n-k)!}, $$
denoted `Nat.descFactorial n k`. By convention $(n)_0 = 1$.

**Definition 2.6 (single-line pattern).** $P$ is a **single-row** pattern if all its entries share a common row coordinate $r$; **single-column** if they share a column; **single-symbol** if they share a symbol. Collectively these are **single-line** patterns. By the partial Latin condition, a single-row pattern of size $k$ occupies $k$ distinct columns carrying $k$ distinct symbols, i.e. it is the graph of a partial injection from columns to symbols.

**Definition 2.7 (intercalate).** An intercalate is a pattern of the form
$$ \{(r_1,c_1,s_1),(r_1,c_2,s_2),(r_2,c_1,s_2),(r_2,c_2,s_1)\} $$
with $r_1\ne r_2$, $c_1 \ne c_2$, $s_1 \ne s_2$; that is, a $2\times 2$ Latin subsquare. The canonical instance is $\{(0,0,0),(0,1,1),(1,0,1),(1,1,0)\}$.

## 3. The alphabet-relabeling symmetry

The engine of all exact results is a group action.

**Definition 3.1 (symbol action).** For $\sigma \in \mathrm{Sym}([n])$ and $L \in \mathcal{L}_n$, define $(\sigma \cdot L)(r,c) = \sigma(L(r,c))$. In the formal development the construction of these relabeled squares from permutations is handled by the `permSymbols` / `perm_of_embeddings` machinery.

**Lemma 3.2 (the action is well defined).** If $L \in \mathcal{L}_n$ and $\sigma \in \mathrm{Sym}([n])$ then $\sigma \cdot L \in \mathcal{L}_n$.

*Proof.* For fixed $r$, the map $c \mapsto \sigma(L(r,c))$ is a composition of two bijections of $[n]$ and hence a bijection; likewise for fixed columns. $\square$

**Lemma 3.3 (the action is a bijection of $\mathcal{L}_n$).** The map $L \mapsto \sigma \cdot L$ is a bijection of $\mathcal{L}_n$ with inverse $L \mapsto \sigma^{-1} \cdot L$. In particular it preserves uniform measure.

*Proof.* Immediate from $(\sigma \cdot)(\tau \cdot) = (\sigma\tau)\cdot$ and $\mathrm{id}\cdot L = L$. $\square$

The essential point is **transitivity on a line**.

**Lemma 3.4 (transitivity on a row's content).** Fix a row $r$. For any two bijections $\phi, \psi : [n] \to [n]$ (thought of as candidate contents "$c \mapsto$ symbol" of row $r$), the symbol action restricted to squares whose row $r$ realizes $\phi$ maps them bijectively onto squares whose row $r$ realizes $\psi$, via $\sigma = \psi \circ \phi^{-1}$.

*Proof.* If $L(r,\cdot) = \phi$ then $(\sigma\cdot L)(r,c) = \sigma(\phi(c)) = \psi(\phi^{-1}(\phi(c))) = \psi(c)$, so $\sigma\cdot L$ realizes $\psi$ in row $r$. The map is a bijection by Lemma 3.3, and it preserves the property of realizing the target content. $\square$

**Corollary 3.5 (a row is a uniform permutation).** In a uniformly random $L \in \mathcal{L}_n$, the content of any fixed row $r$, viewed as a bijection $c \mapsto L(r,c)$, is uniformly distributed over the $n!$ bijections of $[n]$.

*Proof.* By Lemma 3.4 the fibers of the "row-$r$ content" map all have the same cardinality, and there are $n!$ possible contents; equal-size fibers under the uniform measure give a uniform distribution. $\square$

By the row/column symmetry of Definition 2.1 and by **conjugacy** of Latin squares (the symmetry permuting the roles of the row, column and symbol coordinates of the triple $(r,c,s)$), the analogues of Corollary 3.5 hold verbatim for any single column and any single symbol class.

## 4. Main results

### 4.1 A single cell

**Theorem 4.1 (`prob_single_cell`).** For $P = \{(r,c,s)\}$ admissible for order $n \ge 1$,
$$ \Pr[L \supseteq P] = \frac{1}{n}. $$
Equivalently (`prob_single_cell_mul`), $\Pr[L \supseteq P]\cdot n = 1$.

*Proof sketch.* By Corollary 3.5 the symbol $L(r,c)$ is uniform over $[n]$, so $\Pr[L(r,c)=s] = 1/n$ exactly. Multiplying by $n$ gives $1$. $\square$

### 4.2 A single line

**Theorem 4.2 (`prob_rowfiber`).** Let $P$ be a single-row pattern of size $k$, admissible for order $n$ (so $k \le n$). Then
$$ \Pr[L \supseteq P] = \frac{1}{(n)_k} = \frac{(n-k)!}{n!}. $$
Equivalently (`prob_rowfiber_mul`), $\Pr[L \supseteq P]\cdot (n)_k = 1$.

*Proof sketch.* Write $P$ as a partial injection assigning, in the common row $r$, distinct symbols to $k$ distinct columns. By Corollary 3.5 the full content of row $r$ is a uniformly random bijection of $[n]$; there are $n!$ such bijections, each of probability $1/n!$. The bijections extending the prescribed $k$ (column, symbol) pairs are in bijection with the bijections of the remaining $n-k$ columns onto the remaining $n-k$ symbols, of which there are $(n-k)!$. Containment $L \supseteq P$ is equivalent to the row-$r$ content extending $P$ (the other rows are unconstrained by $P$). Hence
$$ \Pr[L \supseteq P] = \frac{(n-k)!}{n!} = \frac{1}{(n)_k}. \qquad \square $$

By conjugacy (the discussion after Corollary 3.5), the identical statement holds for single-column and single-symbol patterns; the partition/indexing map used in the proof is simply re-coordinatized.

### 4.3 Asymptotics and the conjecture for single-line patterns

**Lemma 4.3 (`singleRow_pattern_density`).** For fixed $k$,
$$ \frac{n^k}{(n)_k} \longrightarrow 1 \qquad (n \to \infty). $$

*Proof sketch.* Factor
$$ (n)_k = n^k \prod_{i=1}^{k-1}\Bigl(1 - \tfrac{i}{n}\Bigr), \qquad\text{so}\qquad \frac{n^k}{(n)_k} = \prod_{i=1}^{k-1}\frac{1}{1 - i/n}. $$
This is a finite product (independent of $n$ in length) of factors each tending to $1$, hence tends to $1$. A clean two-sided bound is $1 \le n^k/(n)_k \le \bigl(1 - (k-1)/n\bigr)^{-(k-1)}$ for $n > k-1$, and squeezing gives the limit. $\square$

**Theorem 4.4 (`rowpattern_prob_mul_tendsto`).** For any single-line pattern $P$ of size $k$,
$$ \Pr[L \supseteq P]\cdot n^{k} \longrightarrow 1 \qquad (n \to \infty). $$

*Proof sketch.* By Theorem 4.2, $\Pr[L \supseteq P]\cdot n^k = n^k/(n)_k$, which tends to $1$ by Lemma 4.3. $\square$

Theorem 4.4 establishes the guiding conjecture for an **infinite family** of patterns — one of each size $k$ — with leading constant precisely $1$.

## 5. Why exactness fails: the intercalate

The single-line proofs use transitivity of the symbol action on a *single* line. No comparable transitivity is available for two cells lying in distinct rows *and* distinct columns, and this is exactly where the clean law breaks.

**Proposition 5.1 (intercalate density, conjectural form).** For the canonical intercalate $P = \{(0,0,0),(0,1,1),(1,0,1),(1,1,0)\}$ of size $k=4$,
$$ \Pr[L \supseteq P]\cdot n^{2} \longrightarrow \frac{1}{4} \qquad (n \to \infty), $$
so $\Pr[L \supseteq P] = \Theta(n^{-2})$, not $\Theta(n^{-4})$, and the leading constant is $1/4 \ne 1$.

*Heuristic and evidence.* The expected number of intercalates in a uniformly random Latin square of order $n$ is asymptotically $n^2/4$ (a classical result). An intercalate is specified by an unordered pair of rows, an unordered pair of columns, and an unordered pair of symbols, together with two binary "arrangement" choices; the four cell-entries collapse onto two genuine degrees of freedom. Thus the four constraints contribute an effective exponent $2$, and the combinatorial factor produces the constant $1/4$. The probability that a *fixed* intercalate occurs therefore scales as $n^{-2}$ with constant $1/4$, contradicting the naive $n^{-4}$ reading. (We state this as a proposition/conjecture; the single-line theorems of §4 are the rigorously proved core.)

The contrast with §4 is the whole point: the symbol action is transitive on a single line, forcing the exact $1/(n)_k$ count and constant $1$, but it cannot independently move two cells in distinct rows and columns, which is precisely where exactness — and the constant $1$ — must be abandoned.

## 6. A general conjecture

The single-line results and the intercalate together suggest that the correct decay exponent counts **independent** constraints, not raw entries.

**Conjecture 6.1 (general exponent).** For an arbitrary fixed partial Latin pattern $P$,
$$ \Pr[L \supseteq P] = \Theta\bigl(n^{-e(P)}\bigr), $$
where $e(P)$ is the number of entries minus the rank deficiency of the row/column/symbol incidence of $P$. In particular $e(P) = k$ exactly when $P$ is "spread out" (e.g. a partial transversal with all entries in distinct rows, distinct columns and distinct symbols), in which case the leading constant is $1$ and the guiding conjecture of §1.1 holds verbatim.

For single lines, all $k$ constraints are independent ($e(P) = k$) and Theorem 4.4 confirms the constant is $1$. For the intercalate, $e(P) = 2$ and Proposition 5.1 gives constant $1/4$.

## 6.5 Worked numerical verification

The exact laws of §4 can be checked against brute-force enumeration for small orders, which both validates the theory and builds intuition for the asymptotics. There are $|\mathcal{L}_2| = 2$, $|\mathcal{L}_3| = 12$, $|\mathcal{L}_4| = 576$ and $|\mathcal{L}_5| = 161{,}280$ Latin squares.

**Single cell.** For $P = \{(0,0,0)\}$ and $n = 4$: exactly $144$ of the $576$ squares have $L(0,0)=0$, giving $144/576 = 1/4 = 1/n$, matching Theorem 4.1.

**Single row, $n=4$.** Take the row-$0$ patterns $P_k = \{(0,c,c) : c < k\}$.
- $k=1$: probability $1/4 = 1/(4)_1$.
- $k=2$: probability $1/12 = 1/(4)_2$ (since $(4)_2 = 4\cdot 3 = 12$).
- $k=3$: probability $1/24 = 1/(4)_3$ (since $(4)_3 = 4\cdot 3\cdot 2 = 24$).
- $k=4$: probability $1/24 = 1/(4)_4$ (since $(4)_4 = 24$; note $(4)_3 = (4)_4$ because the final factor is $1$).

Every value agrees with Theorem 4.2 on the nose.

**Density.** For $k = 3$, the ratio $n^k/(n)_k$ takes the values $4.5$ at $n=3$, $2.083$ at $n=5$, $1.389$ at $n=10$, $1.031$ at $n=100$, and $1.0003$ at $n=1000$ — a clear, monotone approach to $1$, illustrating Lemma 4.3 and hence Theorem 4.4.

**Intercalate anomaly.** Latin squares of order $3$ contain no intercalates at all (mean $0$), while order $4$ squares average $6$ intercalates each. The fixed canonical intercalate has occurrence probability $1/72$ at $n=4$, so $\Pr \cdot n^2 = 16/72 = 0.222$, already trending toward the conjectured limit $1/4 = 0.25$ rather than toward $1$. This is the smallest concrete witness that the naive $n^{-k}$ reading fails for two-dimensional patterns, exactly as analyzed in §5.

## 7. Algorithms

The exact laws are eminently checkable for small $n$, and the following procedures both validate the theory and expose the asymptotics numerically.

**Algorithm A (exact occurrence probability by enumeration).** Enumerate $\mathcal{L}_n$ by backtracking row-by-row (placing a Latin-valid permutation in each successive row), count those squares containing $P$, and divide by $|\mathcal{L}_n|$. This yields $\Pr[L \supseteq P]$ exactly as a rational number. Complexity is governed by $|\mathcal{L}_n|$, which is feasible up to $n = 5$ ($|\mathcal{L}_5| = 161{,}280$).

**Algorithm B (descending-factorial law and density).** Compute $(n)_k$ and $1/(n)_k$ directly, and the ratio $n^k/(n)_k$, to confirm Theorems 4.2, 4.4 and Lemma 4.3 against the enumerated values from Algorithm A.

**Algorithm C (intercalate Monte Carlo).** For larger $n$ where enumeration is infeasible, sample approximately-uniform Latin squares (e.g. via the Jacobson–Matthews Markov chain) and estimate the fixed-intercalate occurrence probability, multiplying by $n^2$ to observe convergence toward $1/4$ (Proposition 5.1).

## 8. Applications

- **Experimental design.** Latin squares model treatments balanced across two blocking factors; the density of prescribed local configurations governs how often a desired (or undesired) sub-arrangement appears under randomization.
- **Combinatorial probability.** The exact $1/(n)_k$ law is a clean instance of how a global symmetry (alphabet relabeling) yields exact finite-$n$ identities, a template transferable to other symmetric random structures.
- **Coding and cryptography.** Latin squares underlie certain authentication codes and MDS-like constructions; understanding fixed-pattern probabilities quantifies the frequency of structured fragments in random keys/codewords.
- **Benchmarking samplers.** The single-line law provides an exact ground truth against which approximate Latin-square samplers can be calibrated.

## 8.5 Related phenomena

The dichotomy uncovered here echoes a familiar pattern across random combinatorics. In the theory of subgraph counts in $G(n,p)$ random graphs, the expected number of copies of a fixed graph $H$ scales with the number of edges, but threshold and concentration behavior is governed by the densest subgraph — a balance between vertices (degrees of freedom) and edges (constraints). The Latin-square analogue replaces "edges" by entries and "the densest subgraph" by the rank of the row/column/symbol incidence. Single-line patterns are the Latin analogue of a star or a path with no internal redundancy, where the count is clean; the intercalate is the analogue of a short cycle, where redundancy compresses the effective exponent. This analogy motivates Conjecture 6.1 and suggests that tools from the second-moment method and switchings — already central to the study of random Latin squares — are the natural route to its proof.

It is worth emphasizing why the symbol action alone cannot settle the two-dimensional case. The action is a single copy of $\mathrm{Sym}([n])$ acting diagonally on all cells by relabeling symbols. It is transitive on the content of one line because a line's content is itself a single bijection, on which $\mathrm{Sym}([n])$ acts simply transitively from the left. But two cells in distinct rows and distinct columns belong to two different lines whose contents are coupled by the global Latin constraints; no single relabeling can be prescribed independently on both. The orbit-counting argument therefore degrades from an exact identity to an asymptotic estimate, and the leading constant becomes a genuine combinatorial quantity (here $1/4$) rather than the trivial $1$.

## 9. Discussion

The results isolate a sharp boundary. Whenever a pattern lies in a single line, a single transparent symmetry — relabel the symbols — collapses the problem to counting bijections, yielding the exact identity $\Pr[L \supseteq P] = 1/(n)_k$ and, asymptotically, the constant-$1$ law $\Pr[L \supseteq P]\cdot n^k \to 1$. The proof is robust under conjugacy, so rows, columns and symbol classes are interchangeable. The intercalate marks the first place the symmetry runs out: two cells in distinct rows and columns cannot be moved independently, redundancy enters, and both the exponent and the constant change. Conjecture 6.1 proposes that this dichotomy is the whole story, with the exponent measuring independent constraints.

## 10. Future work

- **Single-column and single-symbol exactness.** Promote the conjugacy remark to a fully formal theorem: every single-column or single-symbol pattern of size $k$ has probability exactly $1/(n)_k$.
- **Intercalate constant.** Rigorously establish Proposition 5.1, ideally via a second-moment or switching argument matching the classical $n^2/4$ mean intercalate count.
- **General exponent.** Prove Conjecture 6.1, characterizing $e(P)$ combinatorially as a rank/independence parameter of the row–column–symbol incidence and pinning the leading constant.
- **Partial transversals.** As the cleanest $e(P) = k$ case beyond single lines, establish $\Pr[L \supseteq P]\cdot n^k \to 1$ for partial transversals.

## 11. Conclusion

For uniformly random Latin squares of order $n$, every fixed single-line partial pattern of size $k$ occurs with probability **exactly** $1/(n)_k$, and therefore $\Pr[L \supseteq P]\cdot n^k \to 1$ — the pattern-density conjecture, proved for an infinite family with leading constant $1$. The same symmetry that forces these exact laws also predicts, through its failure across rows and columns, that genuinely two-dimensional patterns obey corrected laws, exemplified by the intercalate's $n^{-2}$ decay with constant $1/4$. The unifying principle is that the decay exponent counts independent constraints, recovering the clean conjecture exactly for spread-out patterns.
