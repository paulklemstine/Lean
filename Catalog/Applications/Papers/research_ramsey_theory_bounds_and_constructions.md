# Ramsey Theory: Exact Values, Erdős–Szekeres Bounds, and a Probabilistic Sandwich for the Diagonal

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Extremal & Probabilistic Combinatorics)

## Abstract

We present a unified, fully formalized development of finite two-color Ramsey theory built on a single primitive: the *arrow relation* $n \to (s,t)$. Within this framework we establish the three classically known exact small Ramsey numbers $R(3,3)=6$, $R(3,4)=9$, and $R(4,4)=18$; the Erdős–Szekeres recursion $R(s+1,t+1) \le R(s,t+1)+R(s+1,t)$ and its closed binomial form $R(s+1,t+1) \le \binom{s+t}{s}$; the exponential diagonal ceiling $R(k+1,k+1)\le 4^k$; the Erdős probabilistic lower bound, realized as an exact finite union-bound count, giving $R(k,k) > n$ whenever $2\binom{n}{k} < 2^{\binom{k}{2}}$; and a two-sided *exponential sandwich* $2^{m-1} < R(2m,2m) \le 4^{2m-1}$ for all $m\ge 4$. The lower-bound constructions are concrete: the pentagon $C_5$ for $R(3,3)$, a circulant graph on eight vertices for $R(3,4)$, and the Paley graph on $17$ vertices for $R(4,4)$. A handshake-parity obstruction is isolated as a reusable lemma underlying the $R(3,4)$ upper bound. We also record the connection to van der Waerden's theorem on monochromatic arithmetic progressions as the arithmetic shadow of the Hales–Jewett theorem. Every result has been formally verified.

## 1. Introduction

Ramsey theory makes precise the slogan that *complete disorder is impossible*: in any sufficiently large structure, any finite coloring must contain a highly ordered monochromatic substructure. The prototypical setting colors the edges of a complete graph with two colors (red/blue) and seeks monochromatic cliques.

Despite the elementary statement, exact Ramsey numbers are notoriously hard. Only finitely many diagonal and off-diagonal values are known, and the asymptotic growth rate of the diagonal numbers $R(k,k)$ remains open after eight decades, trapped between $\sqrt 2$ and $4$ as a base of exponential growth.

This paper formalizes the foundational layer of the theory on one framework and connects:
- exact small values, via explicit extremal constructions;
- the Erdős–Szekeres upper bounds, via a clean inductive recursion;
- the probabilistic lower bound, via an exact finite counting (union-bound) argument; and
- the resulting two-sided sandwich for the diagonal.

### 1.1 Notation and conventions

A two-coloring of the complete graph on a vertex set $V$ is encoded by a single `SimpleGraph` $G$ on $V$: edges of $G$ are **red**, edges of the complement $G^{c}$ are **blue**. A red $s$-clique is an $s$-clique of $G$; a blue $t$-clique is an $s$-clique of $G^c$. We write $K_r$ for a clique on $r$ vertices and $\binom{n}{k}$ for the binomial coefficient. All quantities are natural numbers unless noted.

## 2. The arrow framework

**Definition 2.1 (Arrow relation).** For naturals $n, s, t$, we say $n \to (s,t)$, formalized as `Arrows n s t`, if for every vertex type $V$, every coloring $G$ on $V$, and every finite vertex set $W \subseteq V$ with $|W| \ge n$, there exists $S \subseteq W$ that is a red $s$-clique ($G$-clique) or a blue $t$-clique ($G^c$-clique).

Quantifying over an arbitrary ambient type together with a finite vertex set $W$ bakes monotonicity in the number of vertices directly into the definition and makes the two recursive calls of the Erdős–Szekeres argument live on subsets of one common vertex set. The Ramsey number is $R(s,t) = \min\{ n : n \to (s,t)\}$; statements "$R(s,t) \le n$" become $n \to (s,t)$ and "$R(s,t) > n$" become $\neg\,(n \to (s,t))$.

**Lemma 2.2 (Vertex monotonicity, `Arrows.mono`).** If $n \to (s,t)$ and $n \le n'$, then $n' \to (s,t)$.

*Proof.* Immediate: a vertex set of size $\ge n'$ has size $\ge n$. $\square$

**Lemma 2.3 (Color symmetry, `arrows_symm` / `arrows_iff_symm`).** $n \to (s,t)$ if and only if $n \to (t,s)$.

*Proof sketch.* Apply the hypothesis to the complementary coloring $G^c$; since $(G^c)^c = G$, a red $t$-clique/blue $s$-clique for $G^c$ is a blue $t$-clique/red $s$-clique for $G$. Hence Ramsey numbers are symmetric: $R(s,t)=R(t,s)$. $\square$

## 3. The Erdős–Szekeres recursion and the binomial bound

**Theorem 3.1 (Inductive step, `arrows_step`).** If $m \to (s, t+1)$ and $n \to (s+1, t)$ with $m, n > 0$, then $(m+n) \to (s+1, t+1)$.

*Proof sketch.* Let $|W| \ge m+n$ and fix $v \in W$. Partition $W \setminus \{v\}$ into the red-neighborhood $R_v$ and blue-neighborhood $B_v$ of $v$. Since $|R_v| + |B_v| \ge m+n-1$, either $|R_v| \ge m$ or $|B_v| \ge n$.
- If $|R_v| \ge n$ in the appropriate feed: applying $n \to (s+1,t)$ to $R_v$ yields a red $K_{s+1}$ (done) or a blue $K_t$; the latter together with $v$ (blue to all of $B_v$) — handled symmetrically — extends a clique by one vertex.
- The two feeds are arranged so that a clique found among $v$'s same-color neighbors extends through $v$ to the demanded size, otherwise the opposite-color clique is already large enough.

Threading the two thresholds gives the bound on $|W|$ needed to force a red $K_{s+1}$ or blue $K_{t+1}$. $\square$

**Base cases (`arrows_one_red`, `arrows_one_blue`).** $1 \to (1, b)$ and $1 \to (a, 1)$: a single vertex is a (trivial) $1$-clique in either color.

**Theorem 3.2 (Binomial bound, `arrows_recursion` / `arrows_binomial_bound`).** For all $s,t$,
$$ \binom{s+t}{s} \to (s+1,\, t+1), \qquad\text{i.e.}\qquad R(s+1, t+1) \le \binom{s+t}{s}. $$

*Proof sketch.* Double induction on $s$ and $t$. The base cases use Lemma 3 of base cases above. The step combines `arrows_step` with Pascal's rule $\binom{s+t}{s} = \binom{(s-1)+t}{s-1} + \binom{s+(t-1)}{s}$, matching the additive recursion of `arrows_step` to the additive recursion of binomial coefficients. $\square$

## 4. Exact small values

### 4.1 $R(3,3)=6$

**Theorem 4.1 (`ramsey_three_three`).** $6 \to (3,3)$ and $\neg\,(5 \to (3,3))$; equivalently $R(3,3)=6$.

*Upper bound.* The instance $s=t=2$ of Theorem 3.2 gives $\binom{4}{2}=6 \to (3,3)$ (`arrows_three_three`).

*Lower bound (`not_arrows_five_three_three`).* The **pentagon** $C_5$ on $\mathbb{Z}/5$ (edges $a \sim a+1$) has no triangle (`pentagon_no_triangle`), and its complement is again a $5$-cycle (the pentagram), hence also triangle-free (`pentagon_compl_no_triangle`). Thus $C_5$ is a $5$-vertex coloring with no monochromatic $K_3$, witnessing $5 \not\to (3,3)$. $\square$

### 4.2 $R(3,4)=9$

**Theorem 4.2 (`ramsey_three_four`).** $9 \to (3,4)$ and $\neg\,(8 \to (3,4))$; equivalently $R(3,4)=9$.

*Upper bound (`arrows_three_four`).* Suppose a coloring of $9$ vertices has no red triangle and no blue $K_4$. A local analysis of any vertex $v$ forces its red-degree to be exactly $3$: too many red neighbors create a red triangle (since among $\ge 4$ red neighbors a red edge would form a triangle and otherwise they would be $4$ mutually blue vertices, a blue $K_4$), and too few red neighbors leave $\ge 6$ blue neighbors among which a blue $K_4$ or red triangle appears. Then *every* one of the $9$ vertices has odd red-degree, contradicting the parity obstruction below.

*Parity obstruction (`red_degree_parity_obstruction`).* For any coloring $G$ and finite $W$ with $|W|$ **odd**, it is impossible that every $v \in W$ has odd red-degree inside $W$. *Proof:* the sum $\sum_{v \in W} \deg^{\mathrm{red}}_W(v)$ counts each red edge twice, hence is even (`red_nbrs_sum_even`); but a sum of an odd number of odd terms is odd — contradiction. A corollary (`no_odd_regular_colouring`): if $n\cdot d$ is odd, no coloring of $n$ vertices can be red-$d$-regular.

*Lower bound (`not_arrows_eight_three_four`).* The circulant graph on $\mathbb{Z}/8$ with $a \sim b$ iff $a-b \in \{1,4\}$ (`graph34`) has no red triangle (`graph34_no_red_triangle`) and no blue $K_4$ (`graph34_no_blue_K4`), witnessing $8 \not\to (3,4)$. $\square$

### 4.3 $R(4,4)=18$

**Theorem 4.3 (`ramsey_four_four`).** $18 \to (4,4)$ and $\neg\,(17 \to (4,4))$; equivalently $R(4,4)=18$.

*Upper bound (`arrows_four_four`).* By color symmetry (Lemma 2.3), $R(4,3)=R(3,4)=9$ (`arrows_four_three`). Feeding $R(3,4)\le 9$ and $R(4,3)\le 9$ into the Erdős–Szekeres step gives $R(4,4) \le 9+9 = 18$.

*Lower bound (`not_arrows_seventeen_four_four`).* The **Paley graph** on $17$ vertices: take $V = \mathbb{Z}/17$ and the quadratic-residue set $Q = \{1,2,4,8,9,13,15,16\}$, with $a \sim b$ iff $a-b \in Q$ (`paley17`). It contains no red $K_4$ (`paley17_no_red_K4`) and, being self-complementary, no blue $K_4$ (`paley17_no_blue_K4`), witnessing $17 \not\to (4,4)$. $\square$

## 5. The exponential diagonal bound

**Lemma 5.1 (Central binomial estimate, `central_choose_le_four_pow`).** $\binom{2k}{k} \le 4^k$.

*Proof.* $\binom{2k}{k}$ is a single term of the row sum $\sum_{i=0}^{2k}\binom{2k}{i} = 2^{2k} = 4^k$, and all terms are nonnegative. $\square$

**Theorem 5.2 (Diagonal ceiling, `arrows_diagonal_pow`).** For all $k$, $\;4^k \to (k+1, k+1)$, i.e. $R(k+1,k+1) \le 4^k$.

*Proof.* Theorem 3.2 with $s=t=k$ gives $\binom{2k}{k} \to (k+1,k+1)$; Lemma 5.1 and vertex monotonicity (Lemma 2.2) raise the threshold to $4^k$. $\square$

For $k=2$ this yields $R(3,3)\le 16$ and for $k=3$ it yields $R(4,4)\le 64$ — far above the exact values $6$ and $18$, quantifying how much sharper the dedicated arguments of Section 4 are than the generic exponential bound.

## 6. The probabilistic lower bound (exact finite count)

We realize the Erdős first-moment argument as an exact count over colorings, avoiding measure theory entirely. Fix $n$ and work over $V = \mathrm{Fin}\,n$. A coloring is a subset $R$ of the edge set; there are $2^{\binom{n}{2}}$ of them.

**Definitions.** For $T \subseteq V$, `edgesOn T` is the set of $\binom{|T|}{2}$ edges with both endpoints in $T$ (`card_edgesOn`). `graphOf R` is the coloring whose red edges are $R$. The translation lemmas `isNClique_graphOf_iff` and `isNClique_compl_graphOf_iff` identify a red (resp. blue) $k$-clique on $T$ with "`edgesOn T` $\subseteq R$" (resp. "`edgesOn T` disjoint from $R$").

**Counting lemmas.** For $S \subseteq Gr$, the number of subsets of $Gr$ containing $S$ is $2^{|Gr|-|S|}$ (`card_filter_superset`), and the number disjoint from $S$ is likewise $2^{|Gr|-|S|}$ (`card_filter_disjoint`).

**Lemma 6.1 (Good coloring exists, `exists_good_coloring`).** If $k \le n$ and $2\binom{n}{k} < 2^{\binom{k}{2}}$, then there is a coloring $R$ such that no $k$-set has all edges red and no $k$-set has all edges blue.

*Proof sketch.* Each fixed $k$-set $T$ is "all red" in exactly $2^{\binom{n}{2}-\binom{k}{2}}$ colorings and "all blue" in the same number. Summing over the $\binom{n}{k}$ many $k$-sets, the number of colorings admitting *some* monochromatic $k$-clique is at most
$$ \sum_{|T|=k}\Big(2^{\binom{n}{2}-\binom{k}{2}} + 2^{\binom{n}{2}-\binom{k}{2}}\Big) = 2\binom{n}{k}\, 2^{\binom{n}{2}-\binom{k}{2}} < 2^{\binom{n}{2}}, $$
using the hypothesis $2\binom{n}{k} < 2^{\binom{k}{2}}$. Since the bad colorings are strictly fewer than all $2^{\binom{n}{2}}$ colorings, a good coloring exists. $\square$

**Theorem 6.2 (Probabilistic lower bound, `not_arrows_of_counting`).** If $k\le n$ and $2\binom{n}{k} < 2^{\binom{k}{2}}$, then $\neg\,(n \to (k,k))$, i.e. $R(k,k) > n$.

*Proof.* Apply Lemma 6.1 to obtain $R$; the coloring `graphOf R` has no monochromatic $K_k$ by the translation lemmas, contradicting $n \to (k,k)$. $\square$

**Corollary 6.3 (Clean exponential form, `not_arrows_of_pow`).** Using $\binom{n}{k} \le n^k$: if $k\le n$ and $2 n^k < 2^{\binom{k}{2}}$, then $R(k,k) > n$.

**Corollary 6.4 (`ramsey_ten_lower`).** $R(10,10) > 16$, since $2\cdot 16^{10} = 2^{41} < 2^{45} = 2^{\binom{10}{2}}$.

Asymptotically, $2\binom{n}{k} < 2^{\binom{k}{2}}$ holds up to $n \approx 2^{k/2}$, recovering the classical bound $R(k,k) > (1-o(1))\,\tfrac{k}{e\sqrt 2}\,2^{k/2}$; the formalized version isolates the clean exponential threshold $n \approx 2^{k/2}$.

## 7. The exponential sandwich for the diagonal

We combine Sections 5 and 6 on the even diagonal, instantiating $k = 2m$ and $n = 2^{m-1}$.

**Lemma 7.1 (Side conditions, `two_mul_le_two_pow`, `prob_exponent_lt`).** For $m \ge 4$, $2m \le 2^{m-1}$; and for $m \ge 2$, $2\,(2^{m-1})^{2m} < 2^{\binom{2m}{2}}$.

**Theorem 7.2 (Lower bound, `ramsey_lower_even`).** For $m\ge 4$, $\neg\,(2^{m-1} \to (2m,2m))$, i.e. $R(2m,2m) > 2^{m-1}$.

*Proof.* Corollary 6.3 with $n = 2^{m-1}$, $k = 2m$, using Lemma 7.1. $\square$

**Theorem 7.3 (Upper bound, `arrows_upper_even`).** For $m\ge 1$, $4^{2m-1} \to (2m,2m)$, i.e. $R(2m,2m) \le 4^{2m-1}$.

*Proof.* The color-diagonal of Theorem 5.2 at $k := 2m-1$. $\square$

**Theorem 7.4 (Sandwich, `ramsey_even_sandwich`).** For all $m \ge 4$,
$$ 2^{\,m-1} \;<\; R(2m,\,2m) \;\le\; 4^{\,2m-1}. $$

Writing $k=2m$, the lower bound is $2^{k/2-1}$ and the upper bound $2^{2(k-1)}$; the exponents differ by a factor of about $4$. This is exactly the still-open constant in $\lim_k R(k,k)^{1/k} \in [\sqrt 2,\,4]$. The probabilistic side is loss-free in *form* (an honest union bound); the slack to the conjectured base $\sqrt 2$ lies entirely in the crude step $\binom{n}{k}\le n^k$, not in the method. At $m=3$ the side condition $2m \le 2^{m-1}$ fails ($6 \le 4$ is false), so $m\ge 4$ is the precise boundary of the argument, not a convenience.

## 8. The arithmetic shadow: van der Waerden and Hales–Jewett

The same "order is unavoidable" phenomenon appears in the integers.

**Theorem 8.1 (van der Waerden, AP form).** For every finite color set $\kappa$, every coloring $C : \mathbb{N} \to \kappa$, and every length $k$, there exist a common difference $a > 0$, a start $b$, and a color $c$ with $C(b + a i) = c$ for all $i < k$: a monochromatic $k$-term arithmetic progression. Moreover the $k$ terms are distinct, so the progression is genuine.

*Proof sketch.* This is the canonical corollary of the **Hales–Jewett theorem** via a monochromatic homothetic copy of the finite set $\{0,1,\dots,k-1\}$ in the commutative monoid $\mathbb{N}$: the homothety $s \mapsto a\cdot s + b$ turns the abstract copy into the progression $b + a i$, with the returned scalar $a>0$ as common difference. Distinctness follows from injectivity of $i \mapsto b + ai$ when $a>0$. The length-$3$ case gives a monochromatic three-term progression $b, b+a, b+2a$ in any finite coloring of $\mathbb{N}$, and the general statement yields monochromatic progressions of *every* length. $\square$

The Hales–Jewett theorem is the structural heart: in a sufficiently high-dimensional combinatorial cube, every finite coloring contains a monochromatic *combinatorial line*. Van der Waerden's progressions are the image of such lines under coordinate-summation. (These arithmetic results connect the graph-theoretic Ramsey numbers above to the broader Ramsey-theoretic core.)

## 9. Algorithms

The development supports several effective procedures.

**(A) Exact Ramsey verification by clique search.** To certify $n \to (s,t)$ for small $n,s,t$, enumerate colorings (or use a SAT-style search) and check each for a red $K_s$ or blue $K_t$; to certify $\neg(n\to(s,t))$, exhibit a single witness coloring and verify it is clique-free. Complexity is governed by $\binom{n}{s}$- and $\binom{n}{t}$-clique scans per coloring.

**(B) Erdős–Szekeres dynamic program.** Compute the binomial upper-bound table $U(s,t) = \binom{s+t-2}{s-1}$ via Pascal's rule $U(s,t)=U(s-1,t)+U(s,t-1)$ with base $U(1,t)=U(s,1)=1$; $O(st)$ time.

**(C) Union-bound threshold search.** For diagonal lower bounds, find the largest $n$ with $2\binom{n}{k} < 2^{\binom{k}{2}}$ (or the crude $2n^k < 2^{\binom{k}{2}}$) by monotone search; certifies $R(k,k) > n$.

**(D) Paley-graph construction.** For a prime $p \equiv 1 \pmod 4$, build the self-complementary quadratic-residue circulant on $\mathbb{Z}/p$, the canonical extremal witness used here for $R(4,4)$ at $p=17$.

## 10. Applications and discussion

Ramsey theory and the probabilistic method permeate combinatorics and computer science: existence proofs for good error-correcting codes, expander graphs, and hard instances; lower bounds in communication and circuit complexity; and, via van der Waerden's theorem, the road to Szemerédi's theorem and the Green–Tao theorem on primes. The contrast between the *exactly* pinned small values (Section 4) and the *exponentially uncertain* diagonal (Section 7) crisply locates the frontier: the existence of order is certain, its precise cost is not.

## 11. Future work

Three concrete directions extend the formalized scaffolding:

1. **Deletion method.** Strengthen the union bound by allowing a few monochromatic cliques and deleting one vertex from each, pushing the lower bound to $R(k,k) \gtrsim \tfrac{k}{e}\sqrt 2 \cdot 2^{k/2}$. The first-moment scaffold (`exists_good_coloring`, the clique↔edge-subset bridges) already supports the required averaging-and-removal step.

2. **Off-diagonal counting.** Replace the symmetric count $2\binom{n}{k}2^{-\binom{k}{2}}$ by an asymmetric, biased count $\binom{n}{3}p^3 + \binom{n}{t}(1-p)^{\binom{t}{2}}$ with $p \asymp t^{-1/2}$ to obtain $R(3,t) \gtrsim t^{3/2}$; the `edgesOn`/`powersetCard` bookkeeping localizes the change.

3. **Finite van der Waerden numbers.** Derive the uniform finite bound $W(r,k)$ from Hales–Jewett by compactness, certifying that every $r$-coloring of $\{0,\dots,N-1\}$ contains a monochromatic $k$-AP for explicit $N$.

## 12. Conclusion

On a single arrow-relation framework we have formally established the exact values $R(3,3)=6$, $R(3,4)=9$, $R(4,4)=18$ with explicit extremal constructions (pentagon, circulant, Paley graph), the Erdős–Szekeres binomial bound, the diagonal ceiling $R(k+1,k+1)\le 4^k$, the probabilistic lower bound as an exact finite count, and the two-sided sandwich $2^{m-1} < R(2m,2m) \le 4^{2m-1}$. Together with the arithmetic shadow van der Waerden / Hales–Jewett, these results assemble a coherent, verified foundation for elementary Ramsey theory and a launching point for tightening the still-open diagonal constant.
