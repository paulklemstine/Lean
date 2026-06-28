# The Two-Colour Ramsey Number as a Computable Function: Exact Values, Recursive and Probabilistic Bounds

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Combinatorics / Ramsey Theory)

---

## Abstract

We present a unified, machine-checked development of finite two-colour Ramsey
theory built on a single primitive: the *arrow relation* $n \to (s,t)$, which
asserts that every red/blue edge-colouring of a complete graph on $n$ vertices
contains a red clique of size $s$ or a blue clique of size $t$. From this
relation we define the **Ramsey number** as a genuine function
$R : \mathbb{N} \times \mathbb{N} \to \mathbb{N}$ via
$R(s,t) = \min\{n : n \to (s,t)\}$, and we establish its complete order-theoretic
API: it is an achieved threshold, it is the least such threshold, all values
below it admit escaping colourings, and a matching upper/lower pair pins it
exactly (the *sandwich* characterisation). On this foundation we prove the three
classical exact diagonal and near-diagonal values
$$R(3,3) = 6, \qquad R(3,4) = 9, \qquad R(4,4) = 18,$$
the off-diagonal base case $R(2,t+1) = t+1$, colour symmetry $R(s,t) = R(t,s)$,
and two families of quantitative bounds: the **Erdős–Szekeres binomial bound**
$R(s+1,t+1) \le \binom{s+t}{s}$ with its underlying recursion
$R(s,t) \le R(s-1,t) + R(s,t-1)$, and the **probabilistic (Erdős) lower bound**
yielding an explicit two-sided exponential sandwich
$2^{m-1} < R(2m,2m) \le 4^{2m-1}$ for $m \ge 4$. Each exact value is obtained by a
*different* extremal mechanism — pure recursion, recursion plus handshake parity,
and recursion plus an algebraic (Paley-graph) construction — exhibiting the
characteristic toolbox of the field. We give proof sketches, algorithmic content,
and numerical demonstrations throughout.

---

## 1. Introduction

Ramsey theory studies the inevitability of order in large structures: the slogan
"complete disorder is impossible" asserts that any sufficiently large system,
however unstructured, must contain a large, perfectly ordered substructure. The
canonical finite instance concerns two-colourings of complete graphs. Frank
Ramsey's 1928 theorem guarantees that for any target clique sizes $s,t$ there is a
finite threshold beyond which every red/blue colouring contains a red $K_s$ or a
blue $K_t$. The least such threshold is the *Ramsey number* $R(s,t)$.

While the existence and small values of Ramsey numbers are classical, a fully
rigorous, mechanically verified treatment must confront several distinct layers:

1. a clean encoding of two-colourings and the arrow relation that bakes in the
   monotonicity properties needed for induction;
2. the definition of $R(s,t)$ as a *function*, with the order theory making
   "least threshold" precise;
3. the recursion and binomial upper bound (Erdős–Szekeres);
4. exact small values, each requiring a matching explicit extremal colouring;
5. the probabilistic lower bound and a resulting exponential sandwich.

This paper assembles all five layers into one framework. Our organising
principle is that the arrow relation is a **two-parameter monotone family** —
monotone (weaker) as the vertex count grows, antitone (harder) as the clique
sizes grow — and that the Ramsey number is the infimum extracting the exact
threshold along the vertex axis.

---

## 2. The arrow relation and its monotonicity

### 2.1 Encoding colourings

A red/blue colouring of the complete graph on a vertex set $V$ is encoded by a
single `SimpleGraph` $G$ on $V$: the edges of $G$ are the **red** edges, and the
edges of its complement $G^{\mathsf c}$ are the **blue** edges. A red $s$-clique is
an $s$-clique of $G$; a blue $t$-clique is an $s$-clique of $G^{\mathsf c}$.

**Definition 2.1 (Arrow relation).** For $n,s,t \in \mathbb{N}$, write
$\mathrm{Arrows}\,n\,s\,t$ (classically $n \to (s,t)$) for the proposition
$$\forall V,\ \forall G : \mathrm{SimpleGraph}(V),\ \forall W \subseteq V,\
|W| \ge n \;\Rightarrow\;
\bigl(\exists S \subseteq W,\ G.\mathrm{IsNClique}\,s\,S\bigr)
\ \vee\
\bigl(\exists S \subseteq W,\ G^{\mathsf c}.\mathrm{IsNClique}\,t\,S\bigr).$$
Quantifying over an arbitrary vertex type and a *finite subset* $W$ (rather than
fixing $|V| = n$) bakes monotonicity into the definition and makes the
Erdős–Szekeres recursion — whose two recursive calls live on subsets of one
common vertex set — straightforward to state.

### 2.2 Two monotonicities

**Lemma 2.2 (`Arrows.mono`, vertex monotonicity).** If $n \to (s,t)$ and
$n \le n'$, then $n' \to (s,t)$.
*Proof.* Immediate from $|W| \ge n' \ge n$. $\quad\blacksquare$

**Lemma 2.3 (`arrows_mono_red`, `arrows_mono_blue`, clique-size monotonicity).**
If $n \to (s,t)$ and $s' \le s$ then $n \to (s',t)$; symmetrically in $t$.
*Proof sketch.* Cliques are hereditary in size: any $s$-clique contains an
$s'$-subclique (`exists_subclique_red`, via `Finset.exists_subset_card_eq`). The
blue case follows by colour symmetry (Lemma 5.1). $\quad\blacksquare$

Together these record that $\mathrm{Arrows}$ is monotone in the vertex count and
antitone in the clique sizes — the structural skeleton of the whole theory.

---

## 3. The Ramsey number as a function

The arrow relation is *satisfiable* for every pair $(s,t)$: there is always some
working threshold.

**Lemma 3.1 (`arrows_witness`).** For all $s,t$, $\exists n,\ n \to (s,t)$.
*Proof sketch.* If $s = 0$ or $t = 0$ the empty set is a $0$-clique, so $0$ works.
Otherwise write $s = S{+}1$, $t = T{+}1$ and use the binomial bound (Theorem 4.2)
with threshold $\binom{S+T}{S}$. $\quad\blacksquare$

**Definition 3.2 (Ramsey number).**
$$R(s,t) \;=\; \mathrm{ramseyNumber}\,s\,t \;:=\; \inf\{\,n : n \to (s,t)\,\}.$$
By Lemma 3.1 the set is non-empty, so this infimum over $\mathbb{N}$ is attained.

The following four results constitute the order-theoretic API and justify calling
$R$ a Ramsey *number*.

**Theorem 3.3 (`ramseyNumber_mem`).** $R(s,t) \to (s,t)$. *(The Ramsey number is
itself a working threshold.)*
*Proof.* `Nat.sInf_mem` applied to the non-empty witness set. $\quad\blacksquare$

**Theorem 3.4 (`ramseyNumber_le`).** If $n \to (s,t)$ then $R(s,t) \le n$. *(It is
the least working threshold.)*
*Proof.* `Nat.sInf_le`. $\quad\blacksquare$

**Theorem 3.5 (`lt_ramseyNumber`).** If $\lnot\,(n \to (s,t))$ then
$n < R(s,t)$. *(Every value below the threshold admits an escaping colouring.)*
*Proof.* If $n \ge R(s,t)$ then vertex monotonicity (Lemma 2.2) applied to
Theorem 3.3 would give $n \to (s,t)$, a contradiction. $\quad\blacksquare$

**Theorem 3.6 (Sandwich characterisation, `ramseyNumber_eq`).** If $n \to (s,t)$
but $\lnot\,((n-1) \to (s,t))$, then $R(s,t) = n$.
*Proof sketch.* By Theorem 3.4, $R(s,t) \le n$. If $R(s,t) < n$ then
$R(s,t) \le n-1$, and Theorem 3.3 with vertex monotonicity would give
$(n-1) \to (s,t)$, contradicting the hypothesis. No hypothesis $n \ge 1$ is
needed: for $n = 0$ the two hypotheses are contradictory and the claim holds
vacuously. $\quad\blacksquare$

Theorem 3.6 is the universal recipe for an *exact* value: combine a proof that
$n$ vertices always work with an explicit extremal colouring on $n-1$ vertices.

---

## 4. The Erdős–Szekeres recursion and binomial bound

**Lemma 4.1 (Erdős–Szekeres step, `arrows_step`).** If $m > 0$, $n > 0$,
$m \to (s,\,t{+}1)$ and $n \to (s{+}1,\,t)$, then
$(m+n) \to (s{+}1,\,t{+}1)$.
*Proof sketch.* In a colouring of $W$ with $|W| \ge m+n$, fix a vertex $v$. Its
non-$v$ neighbours split into the red set $R = \{x : v \sim x\}$ and blue set
$B = \{x : v \not\sim x\}$ with $|R| + |B| = |W| - 1 \ge m + n - 1$, so $|R| \ge m$
or $|B| \ge n$. If $|R| \ge m$, apply $m \to (s,t{+}1)$ to $R$: a blue
$(t{+}1)$-clique finishes; a red $s$-clique together with $v$ (red-adjacent to all
of $R$) yields a red $(s{+}1)$-clique. The case $|B| \ge n$ is symmetric.
$\quad\blacksquare$

The degenerate base cases are that a single vertex is simultaneously a red and a
blue $1$-clique: $1 \to (1,b)$ (`arrows_one_red`) and $1 \to (a,1)$
(`arrows_one_blue`).

**Theorem 4.2 (Binomial bound, `arrows_recursion` / `arrows_binomial_bound`).**
For all $s,t$,
$$\binom{s+t}{s} \to (s{+}1,\,t{+}1), \qquad\text{i.e.}\qquad
R(s{+}1,\,t{+}1) \le \binom{s+t}{s}.$$
*Proof sketch.* Double induction on $(s,t)$. The base cases use the single-vertex
cliques above. The inductive step combines the two smaller instances via Lemma
4.1; the thresholds add by Pascal's rule
$\binom{s+t}{s} = \binom{s-1+t}{s-1} + \binom{s+t-1}{s}$. $\quad\blacksquare$

In inequality form (`arrows_recursion_general`), shifting indices so both feeds
are non-degenerate, this is the textbook recursion
$$R(s,t) \le R(s-1,t) + R(s,t-1).$$

**Theorem 4.3 (Off-diagonal base, `arrows_two` / `not_arrows_two` /
`ramseyNumber_two_succ`).** $R(2,t+1) = t+1$.
*Proof sketch.* Upper bound $R(2,t) \le t$: any colouring of $K_t$ either has a
red edge (a red $K_2$) or is entirely blue, making the whole vertex set a blue
$K_t$. Lower bound: the all-blue colouring of $K_t$ has no red edge and its
complement has no blue $K_{t+1}$ (only $t$ vertices), so $t \not\to (2,t{+}1)$.
Apply Theorem 3.6. $\quad\blacksquare$

---

## 5. Colour symmetry

**Lemma 5.1 (Colour swap, `arrows_symm` / `arrows_iff_symm`).**
$n \to (s,t) \iff n \to (t,s)$, hence $R(s,t) = R(t,s)$
(`ramseyNumber_symm`).
*Proof.* Apply $n \to (s,t)$ to the complement $G^{\mathsf c}$: a red $s$-clique of
$G^{\mathsf c}$ is a blue $s$-clique of $G$, and a blue $t$-clique of
$G^{\mathsf c \mathsf c} = G$ is a red $t$-clique of $G$. $\quad\blacksquare$

Symmetry is the structural lemma that lets a single off-diagonal value feed both
branches of the recursion (used decisively for $R(4,4)$ below) and yields
$R(4,3) = 9$ from $R(3,4) = 9$ for free.

---

## 6. The exact small values

### 6.1 $R(3,3) = 6$

**Theorem 6.1 (`ramseyNumber_three_three`).** $R(3,3) = 6$.
*Proof sketch.*
**Upper bound** $6 \to (3,3)$ (`arrows_three_three`): the $s=t=2$ instance of
Theorem 4.2, since $\binom{4}{2} = 6$.
**Lower bound** $5 \not\to (3,3)$ (`not_arrows_five_three_three`): the **pentagon**
$C_5 = \mathrm{fromRel}(a+1=b)$ on $\mathbb{Z}/5$ has no red triangle, and its
complement (also a $5$-cycle) has no blue triangle, verified by exhaustive `decide`.
Apply Theorem 3.6. $\quad\blacksquare$

### 6.2 $R(3,4) = 9$

The binomial bound only gives $R(3,4) \le \binom{5}{2} = 10$; the sharp value
requires a parity refinement.

**Lemma 6.2 (Handshake parity, `red_nbrs_sum_even`).** For any colouring $G$ and
finite $W$, the total red-degree $\sum_{v\in W} |\{w \in W : w \ne v,\ v \sim w\}|$
is even.
*Proof sketch.* It counts ordered red pairs inside $W$; the swap
$(v,w)\mapsto(w,v)$ is a fixed-point-free involution, equivalently the count
equals $2\cdot(\text{number of red edges})$. $\quad\blacksquare$

**Lemma 6.3 (Local degree obstructions).**
(`red_or_blue_of_four_red_nbrs`) If some $v \in W$ has $\ge 4$ red neighbours in
$W$, then $W$ contains a red triangle or a blue $K_4$ (among $4$ red neighbours,
either two are red-adjacent, giving a red triangle with $v$, or all $6$ pairs are
blue, giving a blue $K_4$). (`red_or_blue_of_six_blue_nbrs`) If some $v$ has $\ge 6$
blue neighbours, apply $R(3,3)=6$ to them: a red triangle finishes, a blue
triangle extends by $v$ to a blue $K_4$.

**Theorem 6.4 (`ramseyNumber_three_four`).** $R(3,4) = 9$.
*Proof sketch.*
**Upper bound** $9 \to (3,4)$ (`arrows_three_four`): suppose a colouring of
$K_9$ has no red triangle and no blue $K_4$. By Lemma 6.3 every vertex has red
degree $\le 3$ and blue degree $\le 5$; since red + blue $= 8$, every vertex has
red degree *exactly* $3$. Then the red graph is $3$-regular on $9$ vertices, so the
total red-degree is $9 \cdot 3 = 27$ — odd, contradicting Lemma 6.2.
**Lower bound** $8 \not\to (3,4)$ (`not_arrows_eight_three_four`): the **Möbius
ladder** $C_8(1,4) = \mathrm{fromRel}(a-b \in \{1,4\})$ on $\mathbb{Z}/8$ is
triangle-free with $K_4$-free complement, verified by `decide`. Apply Theorem 3.6.
$\quad\blacksquare$

### 6.3 $R(4,4) = 18$

**Theorem 6.5 (`ramseyNumber_four_four`).** $R(4,4) = 18$.
*Proof sketch.*
**Upper bound** $18 \to (4,4)$ (`arrows_four_four`): purely recursive. From
$R(3,4)=9$ (Theorem 6.4) and colour symmetry $R(4,3)=9$ (`arrows_four_three`), a
single application of the step (Lemma 4.1) gives
$9 + 9 = 18 \to (4,4)$.
**Lower bound** $17 \not\to (4,4)$ (`not_arrows_seventeen_four_four`): the **Paley
graph** on $\mathbb{Z}/17$, $\mathrm{fromRel}(a - b \in \mathrm{QR}_{17})$ with
$\mathrm{QR}_{17} = \{1,2,4,8,9,13,15,16\}$ the nonzero quadratic residues. Since
$17 \equiv 1 \pmod 4$, $-1$ is a residue, so the residue set is symmetric and the
graph is well defined and self-complementary; an exhaustive `native_decide`
certifies it has neither a red $K_4$ nor a blue $K_4$. Apply Theorem 3.6.
$\quad\blacksquare$

The three exact values exhibit three distinct extremal mechanisms:
*recursion* (R(3,3)), *recursion + parity* (R(3,4)), and *recursion + algebraic
construction* (R(4,4)). By symmetry one also obtains $R(4,3) = 9$
(`ramseyNumber_four_three`).

---

## 7. The diagonal: exponential bounds

### 7.1 The exponential upper bound

**Lemma 7.1 (Central binomial estimate, `central_choose_le_four_pow`).**
$\binom{2k}{k} \le 4^k$.
*Proof sketch.* The central coefficient is one term of the binomial row-sum
$\sum_{i=0}^{2k}\binom{2k}{i} = 2^{2k} = 4^k$, hence bounded by it
(`Finset.single_le_sum`, `Nat.sum_range_choose`). $\quad\blacksquare$

**Theorem 7.2 (Exponential diagonal bound, `arrows_diagonal_pow`).**
$$4^k \to (k{+}1,\,k{+}1), \qquad\text{i.e.}\qquad R(k{+}1,\,k{+}1) \le 4^k.$$
*Proof.* Theorem 4.2 gives $\binom{k+k}{k} \to (k{+}1,k{+}1)$; by Lemma 7.1,
$\binom{2k}{k} \le 4^k$, and vertex monotonicity (Lemma 2.2) raises the threshold.
$\quad\blacksquare$

### 7.2 The probabilistic lower bound

We encode a colouring of $K_n$ by its red edge set $R \subseteq E(K_n)$, where
$|E(K_n)| = \binom{n}{2}$. For a $k$-set $T$, write $E(T)$ (`edgesOn`) for its
$\binom{k}{2}$ internal edges. A standard interval-counting argument on the
Boolean lattice of edge sets gives the two pillars
$$\bigl|\{R : E(T) \subseteq R\}\bigr| = 2^{\binom{n}{2} - \binom{k}{2}}
\quad(\text{`card\_filter\_superset`}),$$
$$\bigl|\{R : E(T) \cap R = \varnothing\}\bigr| = 2^{\binom{n}{2} - \binom{k}{2}}
\quad(\text{`card\_filter\_disjoint`}).$$

**Lemma 7.3 (Union bound, `exists_good_coloring`).** If $k \le n$ and
$2\binom{n}{k} < 2^{\binom{k}{2}}$, then there is a red edge set $R$ such that no
$k$-set is all-red ($E(T)\not\subseteq R$) and no $k$-set is all-blue
($E(T)\cap R \ne\varnothing$).
*Proof sketch.* Summing the two pillars over all $\binom{n}{k}$ choices of $T$, the
number of "bad" colourings (some $k$-set monochromatic) is at most
$2\binom{n}{k}\cdot 2^{\binom{n}{2}-\binom{k}{2}} < 2^{\binom{n}{2}}$, the total
number of colourings. Hence a good colouring exists. $\quad\blacksquare$

**Theorem 7.4 (Erdős lower bound, `not_arrows_of_counting`).** If $k \le n$ and
$2\binom{n}{k} < 2^{\binom{k}{2}}$, then $\lnot\,(n \to (k,k))$, i.e.
$R(k,k) > n$.
*Proof.* The good colouring of Lemma 7.3, read through the
clique-translation bridges (`isNClique_graphOf_iff`,
`isNClique_compl_graphOf_iff`), has no monochromatic $K_k$. $\quad\blacksquare$

**Corollary 7.5 (Exponential form, `not_arrows_of_pow`).** Using
$\binom{n}{k} \le n^k$: if $k \le n$ and $2n^k < 2^{\binom{k}{2}}$ then
$R(k,k) > n$. In particular $R(10,10) > 16$ (`ramsey_ten_lower`), since
$2 \cdot 16^{10} = 2^{41} < 2^{45} = 2^{\binom{10}{2}}$.

### 7.3 The two-sided exponential sandwich

**Theorem 7.6 (Even-diagonal sandwich, `ramsey_even_sandwich`).** For every
$m \ge 4$,
$$2^{\,m-1} \;<\; R(2m,\,2m) \;\le\; 4^{\,2m-1}.$$
*Proof sketch.* **Lower** (`ramsey_lower_even`): apply Corollary 7.5 with
$k = 2m$, $n = 2^{m-1}$. The side condition $2m \le 2^{m-1}$ holds from $m=4$
(`two_mul_le_two_pow`), and the exponent inequality
$2\cdot(2^{m-1})^{2m} < 2^{\binom{2m}{2}}$ reduces to $1 < m$
(`prob_exponent_lt`). **Upper** (`arrows_upper_even`): the colour-diagonal of
Theorem 7.2 at $k := 2m-1$. The interval is non-degenerate
($2^{m-1} < 4^{2m-1}$ for $m \ge 4$). $\quad\blacksquare$

The lower base $2^{(k/2)-1}$ and upper base $4^{2m-1} = 2^{2(k-1)}$ differ by a
factor of roughly $4$ in the exponent — precisely the still-open constant in
$R(k,k)^{1/k} \in [\sqrt 2, 4]$. The probabilistic side is loss-free in *form*;
all slack to the true base $\sqrt 2$ is in the crude step $\binom{n}{k} \le n^k$.

---

## 8. Algorithms

The development is constructive enough to drive direct computation. We highlight
three algorithms (full Python in `demo.py` and the package bundle).

1. **Exhaustive arrow verifier.** Given $n,s,t$, enumerate all
   $2^{\binom{n}{2}}$ two-colourings of $K_n$ and check each for a red $K_s$ or
   blue $K_t$. Correct but exponential; feasible only for tiny $n$. It directly
   certifies $n \to (s,t)$ and underlies the `decide` proofs for the extremal
   graphs.

2. **Erdős–Szekeres dynamic program.** Fill a table $R[s][t]$ using
   $R[1][t]=R[s][1]=1$ and $R[s][t] = R[s-1][t] + R[s][t-1]$, returning the
   binomial upper bounds $R(s,t) \le \binom{s+t-2}{s-1}$ in $O(st)$ time.

3. **Probabilistic threshold finder.** For each $n$, test whether
   $2\binom{n}{k} < 2^{\binom{k}{2}}$ (or the crude $2n^k < 2^{\binom{k}{2}}$);
   the largest passing $n$ is a certified lower bound $R(k,k) > n$. Constant work
   per $n$ with big-integer arithmetic.

---

## 9. Applications and discussion

Ramsey theory's reach extends well beyond graph parties:

- **Number theory.** The same circle of ideas yields van der Waerden's and
  Szemerédi's theorems on arithmetic progressions in dense sets.
- **Computational geometry.** The Erdős–Szekeres "happy ending" theorem
  (large point sets contain large convex polygons) shares the recursion above.
- **Theoretical computer science.** Ramsey-type lower bounds appear in circuit
  complexity, data structures, and communication complexity; the probabilistic
  method pervades randomized algorithms and coding theory.
- **Networks.** Threshold phenomena for unavoidable substructures inform robust
  and fault-tolerant network design.

The intellectual payload here is the *separation* between generic asymptotics and
exact values. The exponential bound gives $R(3,3) \le 16$ and $R(4,4) \le 64$,
far above the truths $6$ and $18$; only specialised arguments (parity, algebra)
recover sharpness. Conversely, no finite computation could establish the
*existence* portion of Ramsey's theorem for all $(s,t)$ — that requires the
recursion. The framework presented here is exactly the meeting point of these two
regimes.

A note on tractability: even $R(5,5)$ is unknown ($43 \le R(5,5) \le 48$),
illustrating Erdős's parable that computing $R(6,6)$ exactly is hopeless. Our
contribution is not to break those barriers but to give a single rigorous,
extensible foundation on which exact values, recursion, and probabilistic bounds
coexist.

---

## 10. Future directions

The cycle suggests several falsifiable next targets, each building on results
proved here.

1. **Off-diagonal closed form via iterated recursion.** Conjecture:
   $R(3,t+1) \le R(3,t) + t$, hence $R(3,t) \le \binom{t+1}{2} + 1 = (t^2+t+2)/2$.
   The recursion (Theorem 4.2 / `arrows_recursion_general`) plus the base case
   $R(2,t)=t$ (Theorem 4.3) already telescopes: $R(3,t+1) \le R(2,t+1) + R(3,t) =
   (t+1) + R(3,t)$. Only the induction packaging remains.

2. **Strict diagonal monotonicity.** Conjecture: $R(s,s) < R(s+1,s+1)$ for
   $s \ge 1$. The recursion gives $R(s+1,s+1) \le 2R(s,s+1)$, and the extremal
   colourings (pentagon, Möbius ladder, Paley) lift by one vertex; combining
   clique-size monotonicity (Lemma 2.3) with one strict anti-arrow per step
   should close it.

3. **Super-polynomial growth.** Conjecture: $R(k,k)$ grows faster than every
   polynomial. The sandwich (Theorem 7.6) gives $2^{m-1} < R(2m,2m)$, and $2^m$
   dominates every polynomial; the missing step relates $R(k,k)$ to
   $R(2\lfloor k/2\rfloor, 2\lfloor k/2\rfloor)$ via monotonicity.

4. **Sub-multiplicativity of the diagonal.** Conjecture:
   $R(s+t,s+t) \le R(2s,2s)\cdot R(2t,2t)$, a multiplicative companion to the
   additive recursion, via categorical products of extremal colourings.

5. **Tightness certificate of the binomial bound.** Conjecture: for $s,t\ge 1$,
   the Erdős–Szekeres binomial bound is tight, $R(s,t) = \binom{s+t-2}{s-1}$, iff
   $\min(s,t) \le 2$.

---

## 11. Conclusion

We have given a unified, fully verified development of two-colour Ramsey theory
centred on the Ramsey number as a computable function. From a single arrow
relation and its two monotonicities we derived the order-theoretic API, the
Erdős–Szekeres recursion and binomial bound, the colour symmetry, the exact
values $R(3,3)=6$, $R(3,4)=9$, $R(4,4)=18$ and $R(2,t+1)=t+1$, and a two-sided
exponential sandwich $2^{m-1} < R(2m,2m) \le 4^{2m-1}$ via the probabilistic
method. The three exact values display three distinct extremal mechanisms,
illustrating that exactness in Ramsey theory is won case by case even as the
asymptotic framework is uniform.

---

## References

- F. P. Ramsey, *On a problem of formal logic*, Proc. London Math. Soc. (1930).
- P. Erdős and G. Szekeres, *A combinatorial problem in geometry*, Compositio
  Math. (1935).
- P. Erdős, *Some remarks on the theory of graphs*, Bull. Amer. Math. Soc. (1947).
