# Ramsey Theory: Bounds and Constructions

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Combinatorics / Extremal Graph Theory)

## Abstract

We present a unified, fully rigorous development of finite two-colour Ramsey theory built on a single primitive — the *arrow relation* $n \rightarrow (s,t)$ — and use it to establish both exact small Ramsey numbers and general asymptotic bounds. We prove the Erdős–Szekeres recursion and its binomial consequence $R(s+1,t+1) \le \binom{s+t}{s}$; the three classical exact diagonal and off-diagonal values $R(3,3) = 6$, $R(3,4) = 9$, and $R(4,4) = 18$; the central binomial estimate $\binom{2k}{k} \le 4^k$ and the resulting exponential diagonal bound $R(k+1,k+1) \le 4^k$; and the colour-swap symmetry $n \rightarrow (s,t) \iff n \rightarrow (t,s)$. The exact values are pinned by explicit extremal constructions — the pentagon $C_5$ for $R(3,3)$, the Möbius ladder $C_8(1,4)$ for $R(3,4)$, and the Paley graph on $\mathbb{Z}/17$ for $R(4,4)$ — each certified clique-free by exhaustive finite verification. We also situate these results against the probabilistic lower bound, which shows the diagonal Ramsey number is exponential in $k$ from both sides. Every theorem stated here has been formally verified.

## 1. Introduction

Ramsey theory studies the principle that sufficiently large combinatorial structures necessarily contain highly ordered substructures, regardless of how their elements are partitioned. For graphs, the canonical statement concerns two-colourings of the edges of a complete graph: given target clique sizes $s$ and $t$, every sufficiently large complete graph whose edges are coloured red and blue must contain a red clique of size $s$ or a blue clique of size $t$. The least size guaranteeing this is the **Ramsey number** $R(s,t)$.

Two complementary problems define the field:

1. **Upper bounds** (forcing results): proving that order is *unavoidable* at a given size. The principal tool is the Erdős–Szekeres recursion (1935).
2. **Lower bounds** (constructions): exhibiting a colouring at the largest possible size that *avoids* the target cliques, thereby proving the Ramsey number is strictly larger.

An exact value $R(s,t) = n$ requires both: a forcing proof that $n \rightarrow (s,t)$ and an extremal construction showing $\neg\,(n-1) \rightarrow (s,t)$.

This paper develops the theory from a single relational primitive, proves the foundational recursion and binomial bound, establishes the three smallest non-trivial exact values, and derives the general exponential diagonal upper bound together with the unifying colour symmetry. All constructions are explicit and their clique-freeness is decidable.

## 2. Definitions and Framework

### 2.1 Colourings as graphs

A two-colouring of the edges of a complete graph on vertex type $V$ is encoded by a single simple graph $G$ on $V$: an edge of $G$ is **red**, and a non-edge (an edge of the complement $G^{\mathsf c}$) is **blue**. A **red clique** is a clique of $G$; a **blue clique** is a clique of $G^{\mathsf c}$, equivalently an independent set of $G$.

We write $G.\mathrm{IsNClique}\ s\ S$ for the property that the finite set $S$ of vertices has cardinality $s$ and induces a clique in $G$.

### 2.2 The arrow relation

The central definition packages monotonicity and locality so that the Erdős–Szekeres recursion is convenient to state.

> **Definition 2.1 (Arrow relation).** For naturals $n, s, t$, the relation $\mathrm{Arrows}\ n\ s\ t$ (classically $n \rightarrow (s,t)$) holds iff for every vertex type $V$, every simple graph $G$ on $V$, and every finite vertex set $W \subseteq V$ with $|W| \ge n$, there exists $S \subseteq W$ with $G.\mathrm{IsNClique}\ s\ S$ (a red $s$-clique) or $S \subseteq W$ with $G^{\mathsf c}.\mathrm{IsNClique}\ t\ S$ (a blue $t$-clique).

Quantifying over an arbitrary ambient vertex type together with a finite subset $W$ (rather than fixing $V = \mathrm{Fin}\ n$) bakes monotonicity directly into the definition and lets the two recursive sub-calls of the Erdős–Szekeres step live on subsets of one common vertex set.

The Ramsey number is then $R(s,t) = \min\{\, n : \mathrm{Arrows}\ n\ s\ t \,\}$.

> **Lemma 2.2 (Monotonicity).** If $\mathrm{Arrows}\ n\ s\ t$ and $n \le n'$, then $\mathrm{Arrows}\ n'\ s\ t$.

*Proof.* Immediate from the definition: a vertex set of size $\ge n'$ has size $\ge n$. $\quad\blacksquare$

## 3. The Erdős–Szekeres Recursion and Binomial Bound

### 3.1 The inductive step

> **Theorem 3.1 (Erdős–Szekeres step).** If $m \rightarrow (s, t+1)$ and $n \rightarrow (s+1, t)$, with $m, n \ge 1$, then $(m+n) \rightarrow (s+1, t+1)$.

*Proof sketch.* Let $W$ be a vertex set with $|W| \ge m+n$ and let $G$ be a colouring. Pick any $v \in W$. Partition the remaining $|W| - 1 \ge m + n - 1$ vertices into the red neighbours $R = \{w \in W \setminus \{v\} : G.\mathrm{Adj}\ v\ w\}$ and the blue neighbours $B = \{w \in W \setminus \{v\} : \neg\, G.\mathrm{Adj}\ v\ w\}$. Since $|R| + |B| \ge m + n - 1$, either $|R| \ge m$ or $|B| \ge n$.

- If $|R| \ge m$: apply $m \rightarrow (s, t+1)$ to $R$. A blue $(t+1)$-clique completes the proof directly. Otherwise we obtain a red $s$-clique $S \subseteq R$; since every vertex of $R$ is red-adjacent to $v$, the set $S \cup \{v\}$ is a red $(s+1)$-clique.
- If $|B| \ge n$: apply $n \rightarrow (s+1, t)$ to $B$, symmetrically. A red $(s+1)$-clique completes the proof; otherwise a blue $t$-clique $S \subseteq B$ extends, via $v$ (blue-adjacent to all of $B$), to a blue $(t+1)$-clique. $\quad\blacksquare$

### 3.2 Base cases and the binomial bound

> **Lemma 3.2 (Trivial arrows).** For all $b$, $\mathrm{Arrows}\ 1\ 1\ b$; and for all $a$, $\mathrm{Arrows}\ 1\ a\ 1$.

*Proof.* A non-empty vertex set contains a single vertex, which is simultaneously a red $1$-clique and a blue $1$-clique. $\quad\blacksquare$

> **Theorem 3.3 (Erdős–Szekeres binomial bound).** For all naturals $s, t$,
> $$\mathrm{Arrows}\ \binom{s+t}{s}\ (s+1)\ (t+1), \qquad\text{i.e.}\qquad R(s+1, t+1) \le \binom{s+t}{s}.$$

*Proof sketch.* Double induction on $s$ and $t$. The base cases $s = 0$ or $t = 0$ are Lemma 3.2, using $\binom{t}{0} = \binom{s}{s} = 1$. For the inductive step, Pascal's rule
$$\binom{s+t}{s} = \binom{(s-1)+t}{s-1} + \binom{s+(t-1)}{s}$$
splits the threshold so that Theorem 3.1 combines the two smaller instances $\binom{(s-1)+t}{s-1} \rightarrow (s, t+1)$ and $\binom{s+(t-1)}{s} \rightarrow (s+1, t)$ into $\binom{s+t}{s} \rightarrow (s+1, t+1)$. $\quad\blacksquare$

This single inequality bounds every Ramsey number. It is sharp for $R(3,3)$ but only an over-estimate for larger values.

## 4. Exact Small Ramsey Numbers

### 4.1 $R(3,3) = 6$

> **Theorem 4.1 (Upper bound).** $\mathrm{Arrows}\ 6\ 3\ 3$.

*Proof.* The instance $s = t = 2$ of Theorem 3.3, since $\binom{4}{2} = 6$. $\quad\blacksquare$

The lower bound uses the **pentagon** $C_5$, the graph on $\mathbb{Z}/5$ with $a \sim b \iff a + 1 = b$ or $b + 1 = a$.

> **Lemma 4.2.** $C_5$ has no red triangle, and $C_5^{\mathsf c}$ (also a $5$-cycle) has no blue triangle.

*Proof.* Exhaustive finite check over all $\binom{5}{3} = 10$ triples. $\quad\blacksquare$

> **Theorem 4.3 (Lower bound).** $\neg\,\mathrm{Arrows}\ 5\ 3\ 3$.

*Proof.* Apply the supposed arrow to $C_5$ on its $5$ vertices; either branch contradicts Lemma 4.2. $\quad\blacksquare$

> **Theorem 4.4.** $R(3,3) = 6$, i.e. $\mathrm{Arrows}\ 6\ 3\ 3 \wedge \neg\,\mathrm{Arrows}\ 5\ 3\ 3$.

### 4.2 $R(3,4) = 9$

The binomial bound gives only $R(3,4) \le \binom{5}{2} = 10$. The sharp value requires a parity refinement.

**Handshake parity.** The key arithmetic input is:

> **Lemma 4.5 (Handshake).** For any colouring $G$ and finite set $W$,
> $$\sum_{v \in W} \bigl|\{\, w \in W \setminus \{v\} : G.\mathrm{Adj}\ v\ w \,\}\bigr| \ \text{is even.}$$

*Proof sketch.* The sum counts ordered red pairs $(v,w)$ inside $W$; the involution $(v,w) \mapsto (w,v)$ is fixed-point-free, so the count is twice the number of red edges. $\quad\blacksquare$

**Local degree obstructions.** Two lemmas bound how many red and blue neighbours a vertex can have before a target clique is forced.

> **Lemma 4.6.** If $v \in W$ has $\ge 4$ red neighbours in $W$, then $W$ contains a red triangle or a blue $K_4$.

*Proof.* Among $4$ red neighbours of $v$, either two are red-adjacent (a red triangle with $v$), or all $\binom{4}{2} = 6$ pairs are blue (a blue $K_4$). $\quad\blacksquare$

> **Lemma 4.7.** If $v \in W$ has $\ge 6$ blue neighbours in $W$, then $W$ contains a red triangle or a blue $K_4$.

*Proof.* Apply $R(3,3) = 6$ (Theorem 4.1) to the $6$ blue neighbours: a red triangle finishes; a blue triangle extends through $v$ (blue-adjacent to all of them) to a blue $K_4$. $\quad\blacksquare$

> **Theorem 4.8 (Upper bound).** $\mathrm{Arrows}\ 9\ 3\ 4$.

*Proof sketch.* Suppose a colouring of a $9$-set $W$ avoids both a red triangle and a blue $K_4$. By Lemmas 4.6–4.7 every vertex has $\le 3$ red neighbours and $\le 5$ blue neighbours, but red plus blue degree is $8$, forcing red-degree exactly $3$ at every vertex. Then the total red-degree is $9 \cdot 3 = 27$, which is odd — contradicting Lemma 4.5. $\quad\blacksquare$

The lower bound uses the **Möbius ladder** $C_8(1,4)$ on $\mathbb{Z}/8$: $a \sim b \iff a - b \in \{\pm 1, 4\}$.

> **Lemma 4.9.** $C_8(1,4)$ has no red triangle, and its complement has no blue $K_4$.

*Proof.* Exhaustive finite verification. $\quad\blacksquare$

> **Theorem 4.10.** $R(3,4) = 9$, i.e. $\mathrm{Arrows}\ 9\ 3\ 4 \wedge \neg\,\mathrm{Arrows}\ 8\ 3\ 4$.

### 4.3 $R(4,4) = 18$

**Colour symmetry.** Swapping the two colours leaves the arrow relation invariant.

> **Theorem 4.11 (Colour-swap symmetry).** $\mathrm{Arrows}\ n\ s\ t \implies \mathrm{Arrows}\ n\ t\ s$; consequently $\mathrm{Arrows}\ n\ s\ t \iff \mathrm{Arrows}\ n\ t\ s$, and $R(s,t) = R(t,s)$.

*Proof.* Given a colouring $G$, apply $\mathrm{Arrows}\ n\ s\ t$ to the complement $G^{\mathsf c}$. A red $s$-clique of $G^{\mathsf c}$ is a blue $s$-clique of $G$; a blue $t$-clique of $G^{\mathsf c}$ (a clique of $G^{\mathsf{cc}} = G$) is a red $t$-clique of $G$. The two outputs are exactly those required by $\mathrm{Arrows}\ n\ t\ s$. $\quad\blacksquare$

In particular, from $R(3,4) \le 9$ we obtain $R(4,3) \le 9$, i.e. $\mathrm{Arrows}\ 9\ 4\ 3$, for free.

> **Theorem 4.12 (Upper bound).** $\mathrm{Arrows}\ 18\ 4\ 4$.

*Proof.* The single Erdős–Szekeres step (Theorem 3.1) with $m = n = 9$, $s = t = 3$, combining $9 \rightarrow (3,4)$ and $9 \rightarrow (4,3)$ to yield $18 \rightarrow (4,4)$. No parity refinement is needed: the binomial bound $\binom{6}{3} = 20$ is loosened by symmetry to the sharp $9 + 9 = 18$. $\quad\blacksquare$

The lower bound uses the **Paley graph** on $\mathbb{Z}/17$. Since $17 \equiv 1 \pmod 4$, the set of nonzero quadratic residues
$$\mathrm{QR}_{17} = \{1, 2, 4, 8, 9, 13, 15, 16\}$$
is symmetric under negation, so $a \sim b \iff a - b \in \mathrm{QR}_{17}$ defines an undirected graph. This graph is self-complementary (the non-residues are exactly a multiplicative translate of the residues).

> **Lemma 4.13.** The Paley graph on $\mathbb{Z}/17$ has no red $K_4$, and its complement has no blue $K_4$.

*Proof.* Exhaustive finite verification over all $4$-subsets, exploiting that the construction is self-complementary so a single clique-freeness check suffices for both colours. $\quad\blacksquare$

> **Theorem 4.14 (Lower bound).** $\neg\,\mathrm{Arrows}\ 17\ 4\ 4$.

*Proof.* Apply the supposed arrow to the Paley graph on its $17$ vertices; either branch contradicts Lemma 4.13. $\quad\blacksquare$

> **Theorem 4.15.** $R(4,4) = 18$, i.e. $\mathrm{Arrows}\ 18\ 4\ 4 \wedge \neg\,\mathrm{Arrows}\ 17\ 4\ 4$.

## 5. The Exponential Diagonal Bound

Specializing the binomial bound to the diagonal $s = t = k$ gives the central binomial coefficient. We bound it crudely but sufficiently.

> **Theorem 5.1 (Central binomial estimate).** For all $k$, $\displaystyle \binom{2k}{k} \le 4^k$.

*Proof.* The central coefficient is one term of the full binomial row sum:
$$\binom{2k}{k} \le \sum_{i=0}^{2k} \binom{2k}{i} = 2^{2k} = 4^k. \qquad\blacksquare$$

> **Theorem 5.2 (Exponential diagonal bound).** For all $k$, $\mathrm{Arrows}\ (4^k)\ (k+1)\ (k+1)$, i.e. $R(k+1, k+1) \le 4^k$.

*Proof.* Theorem 3.3 with $s = t = k$ gives $\mathrm{Arrows}\ \binom{2k}{k}\ (k+1)\ (k+1)$. By Theorem 5.1, $\binom{2k}{k} \le 4^k$, so monotonicity (Lemma 2.2) raises the vertex threshold to $4^k$. $\quad\blacksquare$

The bound is qualitatively correct (exponential) but quantitatively loose for small $k$: it yields $R(3,3) \le 16$ (true value $6$) and $R(4,4) \le 64$ (true value $18$). The exact values of Section 4 genuinely beat the generic estimate, which is sharp only after colour symmetry collapses the two off-diagonal recursive feeds.

## 6. The Lower Bound Side: The Probabilistic Method

While this paper's main contributions are the exact values and the exponential *upper* bound, the matching *lower* bound is supplied by Erdős's probabilistic method, captured here through a counting argument over $r$-uniform hypergraph colourings.

> **Theorem 6.1 (Counting lower bound).** If $2 \binom{n}{k} < 2^{\binom{k}{r}}$, then there exists an $r$-uniform two-colouring of the complete $r$-uniform hypergraph on $n$ vertices with no monochromatic clique of size $k$; equivalently the corresponding hypergraph Ramsey number exceeds $n$.

*Proof sketch.* Colour each $r$-subset independently and uniformly. For a fixed $k$-set $T$, the probability all $\binom{k}{r}$ of its $r$-subsets share a colour is $2 \cdot 2^{-\binom{k}{r}}$. A union bound over all $\binom{n}{k}$ candidate $k$-sets gives total monochromatic probability $\le 2\binom{n}{k} 2^{-\binom{k}{r}}$. If this is $< 1$, some colouring has none. $\quad\blacksquare$

For graphs ($r = 2$), $\binom{k}{2} = k(k-1)/2$, yielding $R(k,k) > 2^{k/2}$ (to leading order). Combined with Theorem 5.2 this brackets the diagonal Ramsey number between $2^{k/2}$ and $4^k$: both walls are exponential, while the exact exponential base remains one of the central open problems of combinatorics.

## 7. Algorithms

The exact small-value results are anchored by decidable clique-freeness checks of explicit circulant/Cayley constructions. We describe the core procedures.

**Algorithm A — Monochromatic clique search.** Given an adjacency predicate on a finite vertex set and a target clique size $s$, decide whether a red $s$-clique (or, by passing the complement, a blue $s$-clique) exists by enumerating $s$-subsets and testing pairwise adjacency. This is the computational kernel behind Lemmas 4.2, 4.9, and 4.13.

**Algorithm B — Erdős–Szekeres threshold composition.** Given proven thresholds $m$ for $(s, t+1)$ and $n$ for $(s+1, t)$, return $m + n$ as a valid threshold for $(s+1, t+1)$. Iterating from the base cases tabulates the binomial bound $\binom{s+t}{s}$.

**Algorithm C — Paley / circulant construction.** Given a prime $p \equiv 1 \pmod 4$, compute the quadratic-residue difference set and emit the circulant adjacency predicate; the resulting graph is self-complementary, so a single clique-freeness pass certifies both colours.

## 8. Applications and Discussion

Ramsey-type results and their proof techniques permeate modern mathematics and computer science:

- **The probabilistic method**, originating in Ramsey lower bounds (Theorem 6.1), is now foundational across theoretical computer science, coding theory, and randomized algorithms.
- **Self-complementary pseudo-random graphs** such as the Paley graph (Section 4.3) are central objects in the study of quasirandomness, expander graphs, and cryptographic constructions.
- **Parity / handshake obstructions** (Lemma 4.5) connect graph colouring to arithmetic invariants and recur throughout extremal combinatorics.
- The **Hales–Jewett theorem** abstracts Ramsey phenomena to colourings of high-dimensional combinatorial cubes, implying that unavoidable monochromatic structure is a feature of essentially any sufficiently rich coloured discrete space.

The persistent gap between the $2^{k/2}$ lower and $4^k$ upper diagonal bounds — unresolved at the level of the exponential base despite eight decades of effort — exemplifies a recurring theme: existence of extremal objects is far easier to prove than their explicit, optimal construction.

## 9. Future Directions

(See the `future_directions` field of the accompanying package for the full statements.) Promising next steps include: pinning $R(3,5) = 14$ via a circulant construction on $\mathbb{Z}/13$ reusing the certified clique-freeness toolchain; abstracting the handshake/regularity obstruction into a general sharpness criterion for off-diagonal Ramsey bounds; formalizing the probabilistic diagonal lower bound $R(k+1,k+1) > 2^{k/2}$ by specializing the hypergraph counting bound to $r = 2$, thereby bracketing the diagonal Ramsey number from both sides; and investigating the conjectured necessity of self-complementarity for extremal diagonal colourings.

## 10. Conclusion

From a single relational primitive we have rigorously derived the Erdős–Szekeres recursion and binomial bound, the three smallest non-trivial exact Ramsey numbers $R(3,3)=6$, $R(3,4)=9$, $R(4,4)=18$ — each via an explicit, verified extremal construction (pentagon, Möbius ladder, Paley graph) — and the general exponential diagonal bound $R(k+1,k+1) \le 4^k$, unified by colour symmetry. Together these results give a complete, self-contained account of where order becomes inevitable in two-coloured complete graphs, and of how fast that inevitability sets in.
