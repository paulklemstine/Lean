# A Two-Sided Exponential Sandwich for Diagonal Ramsey Numbers via a Finite First-Moment Bound

**Author:** Aristotle

**Date:** 2026-06-27

## Abstract

We develop, on a single unified combinatorial framework, both the classical
upper and lower bounds for diagonal Ramsey numbers, and combine them into an
explicit two-sided exponential estimate valid on an infinite family of cases. The
framework is the two-colour *arrow relation* $\mathrm{Arrows}\,n\,s\,t$ (the
statement $n \to (s,t)$): every red/blue colouring of a complete graph on at
least $n$ vertices contains a red $s$-clique or a blue $t$-clique. On the upper
side we derive the Erdős–Szekeres binomial recursion $R(s+1,t+1) \le
\binom{s+t}{s}$ and, via the central binomial estimate $\binom{2k}{k} \le 4^k$,
the exponential diagonal bound $R(k+1,k+1) \le 4^k$. On the lower side we give a
fully finite (measure-theory-free) rendering of Erdős's first-moment argument: a
double count of red-edge sets shows that whenever $k \le n$ and
$2\binom{n}{k} < 2^{\binom{k}{2}}$, some colouring of $K_n$ avoids all
monochromatic $K_k$, hence $R(k,k) > n$. Specialising both bounds to the even
diagonal $k = 2m$ yields, for every $m \ge 4$, the sandwich
$2^{m-1} < R(2m, 2m) \le 4^{2m-1}$. We also recover the exact small values
$R(3,3) = 6$, $R(3,4) = 9$, $R(4,4) = 18$ through explicit extremal
constructions (the pentagon, the Möbius ladder $C_8(1,4)$, and the Paley graph on
$\mathbb{F}_{17}$). All results have been formalised and machine-checked. We
conclude by analysing precisely where the lower bound loses its constant factor
and outlining a programme to close it.

**Keywords:** Ramsey number, arrow relation, Erdős–Szekeres recursion,
probabilistic method, first-moment bound, central binomial coefficient, Paley
graph, diagonal Ramsey number.

## 1. Introduction

Ramsey theory quantifies the principle that sufficiently large combinatorial
structures cannot be wholly disordered. The prototypical objects are the
*Ramsey numbers* $R(s,t)$: the least number of vertices forcing, in any
two-colouring of the edges of a complete graph, a red clique of size $s$ or a
blue clique of size $t$. Although $R(s,t)$ is finite for all $s,t$ (Ramsey 1930;
Erdős–Szekeres 1935), exact values are known only for a handful of small cases,
and the asymptotic growth of the diagonal sequence $R(k,k)$ is among the most
notorious open problems in combinatorics: it is known only that
$$\sqrt 2 \;\le\; \liminf_{k\to\infty} R(k,k)^{1/k} \;\le\; \limsup_{k\to\infty} R(k,k)^{1/k} \;\le\; 4,$$
and closing this gap in the base has resisted effort since Erdős's 1947 lower
bound.

This paper has three goals. First, to develop the upper and lower theory on a
**single framework** — the arrow relation — so that both bounds become
statements of the same form and can be combined directly. Second, to render the
lower bound **entirely finite**: we replace the usual probabilistic phrasing (a
uniformly random colouring avoids all bad cliques with positive probability) by
an explicit double count of edge subsets, in which a union bound over $k$-sets is
compared against the total number of colourings. Third, to package both bounds as
an **explicit infinite family** of two-sided exponential estimates, exposing the
known constant-factor gap in concrete form and isolating the single arithmetic
step responsible for it.

### 1.1 Summary of results

- **`arrows_recursion` / `arrows_binomial_bound`** (§3): $\binom{s+t}{s} \to (s+1,t+1)$, i.e. $R(s+1,t+1) \le \binom{s+t}{s}$.
- **`central_choose_le_four_pow`** (§4): $\binom{2k}{k} \le 4^k$.
- **`arrows_diagonal_pow`** (§4): $4^k \to (k+1,k+1)$, i.e. $R(k+1,k+1) \le 4^k$.
- **`not_arrows_of_counting`** (§5): if $k \le n$ and $2\binom{n}{k} < 2^{\binom{k}{2}}$ then $\lnot\,(n \to (k,k))$, i.e. $R(k,k) > n$.
- **`not_arrows_of_pow`** (§5): the crude corollary using $\binom{n}{k} \le n^k$.
- **`ramsey_ten_lower`** (§5): $R(10,10) > 16$.
- **`ramsey_lower_even` / `arrows_upper_even` / `ramsey_even_sandwich`** (§6): for $m \ge 4$, $2^{m-1} < R(2m,2m) \le 4^{2m-1}$.
- **`ramsey_three_three`, `ramsey_three_four`, `ramsey_four_four`** (§7): $R(3,3)=6$, $R(3,4)=9$, $R(4,4)=18$.

## 2. The arrow framework

### 2.1 Encoding colourings

A two-colouring of the complete graph on a vertex set $V$ is encoded by a single
simple graph $G$ on $V$: the edges of $G$ are the **red** edges and the edges of
its complement $G^{c}$ are the **blue** edges. A red $s$-clique is then a clique
of size $s$ in $G$, and a blue $t$-clique is a clique of size $t$ in $G^{c}$.
This one-graph encoding is what makes colour-swap symmetry (passing to $G^{c}$)
trivial to state and apply.

### 2.2 The arrow relation

**Definition (`Arrows`).** For naturals $n, s, t$, the relation
$\mathrm{Arrows}\,n\,s\,t$ (written $n \to (s,t)$) holds when, for every
decidable-equality vertex type $V$, every simple graph $G$ on $V$, and every
finite vertex set $W \subseteq V$ with $|W| \ge n$, there is either a finset
$S \subseteq W$ that is a red $s$-clique ($G$.IsNClique $s$ $S$) or a finset
$S \subseteq W$ that is a blue $t$-clique ($G^{c}$.IsNClique $t$ $S$).

Quantifying over an arbitrary ambient vertex type together with a finite subset
$W$ has two advantages: it bakes monotonicity in the number of vertices directly
into the definition, and it makes the Erdős–Szekeres recursion easy to state,
since the two recursive calls live on subsets of the *same* vertex set.

**Definition (Ramsey number).** $R(s,t)$ is the least $n$ with $n \to (s,t)$. Thus
"$n \to (s,t)$" means $R(s,t) \le n$, and "$\lnot\,(n \to (s,t))$" means
$R(s,t) > n$.

**Lemma (`Arrows.mono`, monotonicity).** If $n \to (s,t)$ and $n \le n'$ then
$n' \to (s,t)$.
*Proof sketch.* A vertex set of size $\ge n'$ has size $\ge n$, so the hypothesis
applies verbatim. $\square$

**Lemma (`arrows_symm`, colour-swap symmetry).** If $n \to (s,t)$ then
$n \to (t,s)$; consequently $\mathrm{Arrows}\,n\,s\,t \iff \mathrm{Arrows}\,n\,t\,s$
(`arrows_iff_symm`) and $R(s,t) = R(t,s)$.
*Proof sketch.* Apply $n \to (s,t)$ to the complement graph $G^{c}$. A red
$s$-clique of $G^{c}$ is a blue $s$-clique of $G$; a blue $t$-clique of $G^{c}$ is
a clique of $G^{cc} = G$, i.e. a red $t$-clique of $G$. Swapping the two output
cases gives $n \to (t,s)$. $\square$

## 3. The Erdős–Szekeres recursion and the binomial bound

**Lemma (`arrows_step`, inductive step).** If $m,n > 0$, $m \to (s,t+1)$, and
$n \to (s+1,t)$, then $(m+n) \to (s+1,t+1)$.

*Proof sketch.* Take a colouring of $W$ with $|W| \ge m+n$ and fix a vertex
$v \in W$. Partition the remaining vertices by the colour of their edge to $v$:
let $R$ be the red-neighbours and $B$ the blue-neighbours, so
$|R| + |B| = |W| - 1 \ge m + n - 1$, forcing $|R| \ge m$ or $|B| \ge n$.

- If $|R| \ge m$, apply $m \to (s,t+1)$ inside $R$. Either we get a blue
  $(t+1)$-clique (done), or a red $s$-clique $S \subseteq R$; since every vertex
  of $R$ is red-adjacent to $v$, the set $S \cup \{v\}$ is a red $(s+1)$-clique.
- If $|B| \ge n$, apply $n \to (s+1,t)$ inside $B$. Either we get a red
  $(s+1)$-clique (done), or a blue $t$-clique $S \subseteq B$; since every vertex
  of $B$ is blue-adjacent to $v$, the set $S \cup \{v\}$ is a blue
  $(t+1)$-clique. $\square$

**Base cases.** A single vertex is simultaneously a red and a blue $1$-clique,
giving `arrows_one_red`: $1 \to (1,b)$, and `arrows_one_blue`: $1 \to (a,1)$.

**Theorem (`arrows_recursion` / `arrows_binomial_bound`, binomial bound).** For
all $s,t$,
$$\binom{s+t}{s} \to (s+1,\,t+1), \qquad\text{i.e.}\qquad R(s+1,t+1) \le \binom{s+t}{s}.$$
*Proof sketch.* Double induction on $s$ and $t$. The base cases use
`arrows_one_red` and `arrows_one_blue`. For the step, combine the two smaller
instances $\binom{(s-1)+t}{s-1} \to (s,t+1)$ and $\binom{s+(t-1)}{s} \to (s+1,t)$
via `arrows_step`; the vertex thresholds add by Pascal's rule
$$\binom{s+t}{s} = \binom{s-1+t}{s-1} + \binom{s+t-1}{s}. \qquad\square$$

## 4. The exponential diagonal upper bound

**Theorem (`central_choose_le_four_pow`).** For all $k$, $\binom{2k}{k} \le 4^k$.
*Proof sketch.* The central coefficient is a single term of the binomial row-sum
$$\sum_{i=0}^{2k} \binom{2k}{i} = 2^{2k} = 4^k,$$
and all terms are nonnegative, so $\binom{2k}{k} \le \sum_i \binom{2k}{i} = 4^k$
by `Finset.single_le_sum` and `Nat.sum_range_choose`. $\square$

**Theorem (`arrows_diagonal_pow`, diagonal upper bound).** For all $k$,
$$4^k \to (k+1,\,k+1), \qquad\text{i.e.}\qquad R(k+1,k+1) \le 4^k.$$
*Proof sketch.* `arrows_recursion k k` gives $\binom{k+k}{k} \to (k+1,k+1)$.
Since $\binom{k+k}{k} = \binom{2k}{k} \le 4^k$, monotonicity `Arrows.mono` raises
the threshold from $\binom{2k}{k}$ to $4^k$. $\square$

This is the classical first non-trivial ceiling on diagonal Ramsey growth. It is
not sharp for small cases — at $k=2$ it gives $R(3,3) \le 16$ versus the true
$6$, and at $k=3$ it gives $R(4,4) \le 64$ versus the true $18$ — which is
precisely why the exact small values require dedicated constructions (§7).

## 5. The finite first-moment lower bound

We now give the lower bound in fully finite form. Fix a vertex set $V = \mathrm{Fin}\,n$
and let $\mathrm{Gr}$ denote the finset of all *off-diagonal pairs* (the
potential edges), so $|\mathrm{Gr}| = \binom{n}{2}$. A colouring is encoded by its
set $R \subseteq \mathrm{Gr}$ of red edges; there are $2^{\binom{n}{2}}$ such
colourings in total.

### 5.1 Counting lemmas

**Lemma (`card_filter_superset`, up-set cardinality).** For finsets
$S \subseteq \mathrm{Gr}$, the number of subsets $A \subseteq \mathrm{Gr}$ with
$S \subseteq A$ is
$$\#\{A \subseteq \mathrm{Gr} : S \subseteq A\} = 2^{\,|\mathrm{Gr}| - |S|}.$$
*Proof sketch.* Such $A$ are in bijection with arbitrary subsets of
$\mathrm{Gr} \setminus S$ (choose the freely-varying edges); the Boolean lattice
on a set of size $|\mathrm{Gr}| - |S|$ has $2^{\,|\mathrm{Gr}|-|S|}$ elements. $\square$

**Lemma (`card_filter_disjoint`, down-set via complement involution).** The
number of subsets $A \subseteq \mathrm{Gr}$ disjoint from a fixed $S \subseteq
\mathrm{Gr}$ equals the number containing $S$, namely $2^{\,|\mathrm{Gr}|-|S|}$.
*Proof sketch.* The complement involution $A \mapsto \mathrm{Gr} \setminus A$ on
the powerset of $\mathrm{Gr}$ is a bijection exchanging the events "$A \supseteq S$"
and "$A \cap S = \varnothing$"; apply `card_filter_superset`. $\square$

For a $k$-set $T$ of vertices, write $\mathrm{edgesOn}\,T$ for the
$\binom{k}{2}$ internal pairs. The colourings making $T$ a **red** $K_k$ are
exactly those with $\mathrm{edgesOn}\,T \subseteq R$; by `card_filter_superset`
there are $2^{\binom{n}{2} - \binom{k}{2}}$ of them. The colourings making $T$ a
**blue** $K_k$ are those with $\mathrm{edgesOn}\,T$ disjoint from $R$; by
`card_filter_disjoint` there are likewise $2^{\binom{n}{2} - \binom{k}{2}}$.

### 5.2 The union bound and the existence of a good colouring

**Lemma (`exists_good_coloring`).** If $k \le n$ and
$2\binom{n}{k} < 2^{\binom{k}{2}}$, then there exists a red-edge set
$R \subseteq \mathrm{Gr}$ such that no $k$-set $T$ has
$\mathrm{edgesOn}\,T \subseteq R$ (no red $K_k$) and no $k$-set $T$ has
$\mathrm{edgesOn}\,T$ disjoint from $R$ (no blue $K_k$).

*Proof sketch.* The set of **bad** colourings is the union, over the
$\binom{n}{k}$ choices of $T$, of the red-bad events
$\{A : \mathrm{edgesOn}\,T \subseteq A\}$ and the blue-bad events
$\{A : \mathrm{edgesOn}\,T \cap A = \varnothing\}$. By the two counting lemmas and
the union bound,
$$\#\{\text{bad colourings}\} \;\le\; 2\,\binom{n}{k}\, 2^{\binom{n}{2} - \binom{k}{2}}.$$
Comparing with the total count $2^{\binom{n}{2}}$, the bad set fails to cover all
colourings precisely when
$$2\,\binom{n}{k}\, 2^{\binom{n}{2} - \binom{k}{2}} \;<\; 2^{\binom{n}{2}}
\quad\Longleftrightarrow\quad 2\,\binom{n}{k} \;<\; 2^{\binom{k}{2}}.$$
Hence some colouring is good. $\square$

**Theorem (`not_arrows_of_counting`, first-moment lower bound).** If $k \le n$
and $2\binom{n}{k} < 2^{\binom{k}{2}}$, then $\lnot\,(n \to (k,k))$; equivalently
$R(k,k) > n$.
*Proof sketch.* The good colouring of `exists_good_coloring` is, when read as a
red graph $G$ on $\mathrm{Fin}\,n$, a witness that the arrow relation fails: it
has neither a red $K_k$ nor a blue $K_k$ on the full vertex set. $\square$

The hypothesis $k \le n$ is recorded explicitly so that $\mathrm{edgesOn}\,T$ has
the expected $\binom{k}{2}$ edges and the counting is exact; for $k > n$ the
conclusion is still true but for the trivial reason that $K_n$ contains no
$k$-clique at all.

**Theorem (`not_arrows_of_pow`, exponential corollary).** If $k \le n$ and
$2\,n^k < 2^{\binom{k}{2}}$, then $\lnot\,(n \to (k,k))$.
*Proof sketch.* Crudely $\binom{n}{k} \le n^k$, so the hypothesis implies
$2\binom{n}{k} < 2^{\binom{k}{2}}$; apply `not_arrows_of_counting`. $\square$

**Corollary (`ramsey_ten_lower`).** $R(10,10) > 16$.
*Proof sketch.* Take $n = 16$, $k = 10$. Then $k \le n$ and
$2\binom{16}{10} = 2 \cdot 8008 = 16016 < 2^{45} = 2^{\binom{10}{2}}$, so
`not_arrows_of_counting` gives $\lnot\,(16 \to (10,10))$. $\square$

## 6. The two-sided exponential sandwich

We now pinch the diagonal Ramsey number between the two exponentials on an
explicit infinite family, specialising to the even diagonal $k = 2m$ with vertex
count $n = 2^{m-1}$.

### 6.1 Arithmetic inputs

**Lemma (`two_mul_le_two_pow`).** For $m \ge 4$, $2m \le 2^{m-1}$.
*Proof sketch.* The side condition $k \le n$ of the lower bound, here
$2m \le 2^{m-1}$. It holds at $m=4$ ($8 \le 8$) and the right side then doubles
each step while the left grows by $2$, so it persists for all $m \ge 4$;
formally, an induction with $1 \le 2^{m}$. The bound *fails* at $m = 3$
($6 \le 4$ is false), which is the precise boundary of the argument. $\square$

**Lemma (`prob_exponent_lt`).** For $m \ge 2$,
$2\,(2^{m-1})^{2m} < 2^{\binom{2m}{2}}$.
*Proof sketch.* This is the crude exponent inequality
$2\,n^k < 2^{\binom{k}{2}}$ at $n = 2^{m-1}$, $k = 2m$. Taking base-2 logarithms,
it reduces to $(m-1)\cdot 2m + 1 < \binom{2m}{2} = m(2m-1)$, i.e.
$2m^2 - 2m + 1 < 2m^2 - m$, i.e. $1 < m$. Using
$\binom{2m}{2} = m(2m-1)$ (`Nat.choose_two_right`) and monotonicity of $2^{(\cdot)}$
finishes the proof. $\square$

### 6.2 The two bounds and the sandwich

**Theorem (`ramsey_lower_even`, lower bound).** For $m \ge 4$,
$\lnot\,(2^{m-1} \to (2m,2m))$; equivalently $R(2m,2m) > 2^{m-1}$.
*Proof sketch.* Apply `not_arrows_of_pow` with $n = 2^{m-1}$, $k = 2m$, supplying
$k \le n$ from `two_mul_le_two_pow` and the exponent inequality from
`prob_exponent_lt`. $\square$

**Theorem (`arrows_upper_even`, upper bound).** For $m \ge 1$,
$4^{2m-1} \to (2m,2m)$; equivalently $R(2m,2m) \le 4^{2m-1}$.
*Proof sketch.* This is the colour-diagonal of `arrows_diagonal_pow` at
$k := 2m-1$: that theorem gives $4^{2m-1} \to ((2m-1)+1,\,(2m-1)+1)$, and
$(2m-1)+1 = 2m$ since $m \ge 1$. $\square$

**Theorem (`ramsey_even_sandwich`, two-sided sandwich).** For every $m \ge 4$,
$$2^{\,m-1} \;<\; R(2m,\,2m) \;\le\; 4^{\,2m-1}.$$
*Proof sketch.* Conjunction of `ramsey_lower_even` and `arrows_upper_even`. The
interval is non-degenerate because $2^{m-1} < 4^{2m-1}$ for all $m \ge 4$. $\square$

### 6.3 Discussion: the visible gap

Rewriting the exponents in terms of the clique size $k = 2m$, the lower wall is
$2^{(k/2)-1}$ and the upper wall is $4^{2m-1} = 2^{2(k-1)}$. The two differ by
roughly a factor of $4$ in the exponent — exactly the still-open constant in
$R(k,k)^{1/k} \in [\sqrt 2, 4]$. Crucially, the probabilistic side is *loss-free
in form*: the union bound in `exists_good_coloring` is an honest, tight
inequality. All slack between the proven base and the optimal $\sqrt 2$ resides
in the single crude step $\binom{n}{k} \le n^k$ used to pass from
`not_arrows_of_counting` to `not_arrows_of_pow`, which discards a factor of
$k!$. Reinstating $\binom{n}{k} \le n^k/k!$ would upgrade the present
$2^{(k/2)-1}$ family to the textbook-optimal $2^{k/2}$ with no change to the
counting core.

## 7. Exact small values

For completeness we record the three exact diagonal-adjacent values, each proved
by pairing the binomial/recursion upper bound with an explicit extremal
construction. These are sharper than the generic $4^k$ ceiling and showcase the
structural (rather than asymptotic) regime.

**Theorem (`ramsey_three_three`).** $R(3,3) = 6$: $6 \to (3,3)$ and
$\lnot\,(5 \to (3,3))$.
*Proof sketch.* Upper bound: the $s=t=2$ instance of `arrows_recursion`, since
$\binom{4}{2} = 6$. Lower bound: the **pentagon** $C_5$ (adjacency $a+1 = b$
mod $5$) has neither a red triangle (`pentagon_no_triangle`) nor a blue triangle
(`pentagon_compl_no_triangle`, its complement being again a $5$-cycle); both are
checked by finite decision. $\square$

**Theorem (`ramsey_three_four`).** $R(3,4) = 9$: $9 \to (3,4)$ and
$\lnot\,(8 \to (3,4))$.
*Proof sketch.* The binomial bound only gives $R(3,4) \le \binom{5}{2} = 10$; the
sharp value $9$ uses a **parity refinement**. In a hypothetical $8$-vertex-free
colouring on $9$ vertices, every vertex would need red-degree exactly $3$, making
the red graph $3$-regular on $9$ vertices — impossible, since the handshake sum
$9 \cdot 3 = 27$ is odd. Lower bound: the **Möbius ladder** $C_8(1,4)$ on
$\mathbb{Z}/8$ (difference set $\{\pm 1, 4\}$) is triangle-free with $K_4$-free
complement, verified by decision. $\square$

**Theorem (`ramsey_four_four`).** $R(4,4) = 18$: $18 \to (4,4)$ and
$\lnot\,(17 \to (4,4))$.
*Proof sketch.* Upper bound: colour symmetry (`arrows_symm`) turns $R(3,4)=9$
into $R(4,3)=9$ (`arrows_four_three`), and a single `arrows_step` gives
$9 + 9 \to (4,4)$, i.e. `arrows_four_four`. Lower bound: the **Paley graph** on
$\mathbb{F}_{17}$, with $a \sim b$ iff $a-b$ is a nonzero quadratic residue
$\{1,2,4,8,9,13,15,16\}$. Since $17 \equiv 1 \pmod 4$ the residue set is
symmetric, so the graph is well-defined and self-complementary; a direct check
(`not_arrows_seventeen_four_four`) shows it has no red $K_4$ and no blue $K_4$. $\square$

## 8. Algorithms

The constructive content of the paper yields three concrete algorithms.

**(A) Erdős–Szekeres recursion table.** Compute upper bounds
$U(s,t) = \binom{s+t-2}{s-1}$ for all small $s,t$ by dynamic programming on
Pascal's recurrence $U(s,t) \le U(s-1,t) + U(s,t-1)$ with base $U(1,t)=U(s,1)=1$.
This reproduces the binomial bound table and the diagonal ceiling $R(k+1,k+1) \le 4^k$.

**(B) First-moment lower-bound certifier.** Given $k$, find the largest $n$ with
$2\binom{n}{k} < 2^{\binom{k}{2}}$ (and $k \le n$). Increment $n$ from $k$ while
the inequality holds; the last passing $n$ certifies $R(k,k) > n$. Big-integer
arithmetic makes this exact; complexity is $O(n)$ binomial evaluations per $k$.

**(C) Extremal-graph verifier.** Given a circulant/Paley construction on
$\mathbb{Z}/N$ with difference set $D$, verify clique-freeness of both colours by
exhaustively testing every $\binom{N}{c}$ candidate clique of the relevant size
$c$. This certifies the lower bounds $R(3,3)>5$, $R(3,4)>8$, $R(4,4)>17$.

## 9. Applications

The probabilistic method born from the Ramsey lower bound is now foundational
across combinatorics and theoretical computer science: randomized algorithms,
expander and code constructions, hardness of approximation, and probabilistic
combinatorics all descend from the first-moment idea formalised here. Ramsey-type
guarantees underpin lower bounds for data structures and communication
complexity, and the diagonal sandwich is a clean testbed for studying the
$[\sqrt 2, 4]$ base gap. The finite double-count presentation, free of measure
theory, is also well-suited to formal verification and to teaching the
probabilistic method without probability prerequisites.

## 10. Discussion and future work

The sandwich makes the central open problem of diagonal Ramsey theory visible in
miniature: the gap between $2^{(k/2)-1}$ and $2^{2(k-1)}$ is exactly the
$[\sqrt 2, 4]$ base gap, and our analysis localises the lower-bound slack to a
single arithmetic step. We highlight four directions.

1. **Reach the true base $\sqrt 2$.** Replace $\binom{n}{k} \le n^k$ by
   $\binom{n}{k} \le n^k/k!$ to upgrade `not_arrows_of_counting` to a general
   $\forall k \ge 3,\ R(k,k) > \lfloor 2^{k/2}\rfloor$. The counting core is
   already base-free; only one inequality stands between the present
   $2^{k/2-1}$ family and the optimal constant.

2. **Lovász Local Lemma.** A symmetric-LLL refinement should yield
   $R(k,k) > (1+o(1))\,(k/(e\sqrt 2))\,2^{k/2}$, beating the first moment. The
   bad events (indexed by $k$-sets) are nearly independent — two interact only
   when their vertex sets share an edge — and their dependency graph is
   combinatorially explicit, making a finite LLL instance directly expressible.

3. **Off-diagonal $R(3,k) = \Theta(k^2/\log k)$.** The same edge-set model, made
   asymmetric (red events = triangles, a sparse structure), should prove the
   Kim-order lower bound $R(3,k) > c\,(k/\log k)^2$ via a triangle-free
   process / deletion argument stated as $\lnot\,(n \to (3,k))$.

4. **Derandomisation.** Make `exists_good_coloring` constructive via the method
   of conditional expectations, selecting edges one at a time to keep the
   expected number of monochromatic $K_k$ below $1$, yielding an explicit witness
   colouring.

## 11. Conclusion

We have placed the classical diagonal Ramsey bounds on one arrow-relation
framework, given a fully finite first-moment lower bound, and combined the two
into an explicit infinite family $2^{m-1} < R(2m,2m) \le 4^{2m-1}$, while also
recovering the exact small values $R(3,3)=6$, $R(3,4)=9$, $R(4,4)=18$ through
explicit extremal graphs. The presentation isolates precisely where the lower
bound loses its constant, charting a concrete path toward the optimal base.

## References

- F. P. Ramsey, *On a problem of formal logic*, Proc. London Math. Soc. (1930).
- P. Erdős and G. Szekeres, *A combinatorial problem in geometry*, Compositio Math. (1935).
- P. Erdős, *Some remarks on the theory of graphs*, Bull. Amer. Math. Soc. (1947).
- J. H. Spencer, *Ramsey's theorem — a new lower bound*, J. Combin. Theory Ser. A (1975).
- N. Alon and J. H. Spencer, *The Probabilistic Method*, Wiley.
