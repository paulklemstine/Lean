# Sharp Small Ramsey Numbers and a Parity Obstruction: $R(3,3)=6$, $R(3,4)=9$, the Erdős–Szekeres Bound, and Probabilistic Lower Bounds

**Author:** Aristotle
**Date:** 2026-06-26

## Abstract

We develop, from first principles, the elementary theory of finite two-colour
Ramsey numbers and establish three sharp facts together with the structural
machinery behind them. Working with the *arrow relation* $n \to (s,t)$ — every
red/blue colouring of a complete graph on $\geq n$ vertices contains a red
$s$-clique or a blue $t$-clique — we prove the Erdős–Szekeres binomial ceiling
$R(s{+}1,t{+}1) \le \binom{s+t}{s}$ via a clean recursive step, and we determine
two exact values: $R(3,3) = 6$ (with the pentagon as extremal colouring) and
$R(3,4) = 9$ (with a Möbius-ladder circulant as the extremal colouring on eight
vertices). The upper bound $R(3,4) \le 9$ strictly improves the binomial
prediction of $10$, and we trace this improvement to a single arithmetic
phenomenon: a handshake-parity obstruction. We isolate that phenomenon as two
reusable theorems on arbitrary finite vertex sets — that the red-degrees inside
an odd-order set cannot all be odd, and equivalently that no $d$-regular red
colouring exists on $n$ vertices when $nd$ is odd. Finally, we record the
first-moment probabilistic lower bound for $r$-uniform hypergraph Ramsey
numbers, which for graphs yields $R(k,k) > 2^{k/2}$ and frames the classical
exponential sandwich $2^{k/2} < R(k,k) \le 4^k$. All results are formally
verified.

## 1. Introduction

Ramsey theory quantifies the principle that sufficiently large combinatorial
structures cannot be entirely disordered. The two-colour graph Ramsey number
$R(s,t)$ is the least $n$ such that every $2$-colouring of the edges of the
complete graph $K_n$ contains a red clique on $s$ vertices or a blue clique on
$t$ vertices. Three foundational themes organise the classical theory:

1. **Upper bounds by recursion.** The Erdős–Szekeres argument bounds
   $R(s,t)$ recursively and yields the binomial ceiling
   $R(s{+}1,t{+}1) \le \binom{s+t}{s}$.
2. **Exact small values.** The first nontrivial values, $R(3,3)=6$ and
   $R(3,4)=9$, require matching constructions (lower bounds) and combinatorial
   obstructions (upper bounds). For $R(3,4)$ the binomial ceiling is *not*
   tight, and an extra parity argument is needed.
3. **Lower bounds by the probabilistic method.** A first-moment computation
   shows that random colourings avoid large monochromatic cliques, giving
   exponential lower bounds — for graphs, $R(k,k) > 2^{k/2}$.

This paper presents a self-contained formal treatment of all three themes, with
particular emphasis on the structural reason that $R(3,4)=9$ beats its binomial
ceiling. We extract the deciding step into a general *parity obstruction* that
applies to any colouring on any finite vertex set, independent of the specific
clique sizes involved.

Throughout, a two-colouring of a complete graph on a vertex set $V$ is encoded
by a single `SimpleGraph` $G$ on $V$: the edges of $G$ are **red** and the edges
of its complement $G^{\mathsf c}$ are **blue**. A red $s$-clique is a clique of
$G$; a blue $t$-clique is a clique of $G^{\mathsf c}$.

## 2. The arrow relation and monotonicity

**Definition 1 (Arrow relation).** For naturals $n, s, t$, write $n \to (s,t)$,
formally `Arrows n s t`, to mean: for every type $V$ with decidable equality,
every graph $G$ on $V$, and every finite vertex set $W \subseteq V$ with
$|W| \ge n$, there exists $S \subseteq W$ with $G$ inducing an $s$-clique on $S$,
or there exists $S \subseteq W$ with $G^{\mathsf c}$ inducing a $t$-clique on
$S$.

Quantifying over an arbitrary ambient type together with a `Finset` $W$ builds
monotonicity into the definition and lets the recursion below operate on subsets
of a common vertex set. The Ramsey number is then $R(s,t) = \min\{ n : n \to (s,t)\}$.

**Lemma 2 (Monotonicity, `Arrows.mono`).** If $n \to (s,t)$ and $n \le n'$, then
$n' \to (s,t)$.

*Proof.* Any $W$ with $|W| \ge n'$ also has $|W| \ge n$, so the hypothesis
applies directly. $\square$

Two trivial base facts seed the recursion.

**Lemma 3 (`arrows_one_red`, `arrows_one_blue`).** For all $a,b$, $1 \to (1,b)$
and $1 \to (a,1)$.

*Proof.* A nonempty $W$ contains a vertex $v$; the singleton $\{v\}$ is
simultaneously a red $1$-clique (of $G$) and a blue $1$-clique (of
$G^{\mathsf c}$). $\square$

## 3. The Erdős–Szekeres recursion and binomial bound

**Lemma 4 (Erdős–Szekeres step, `arrows_step`).** If $m > 0$, $n > 0$,
$m \to (s, t{+}1)$ and $n \to (s{+}1, t)$, then $(m+n) \to (s{+}1, t{+}1)$.

*Proof sketch.* Let $W$ be a colouring with $|W| \ge m+n$ and fix $v \in W$.
Partition $W \setminus \{v\}$ into the set $R$ of red neighbours of $v$ and the
set $B$ of blue neighbours, so $|R| + |B| = |W| - 1 \ge m + n - 1$. Hence
$|R| \ge m$ or $|B| \ge n$.

- If $|R| \ge m$, apply $m \to (s, t{+}1)$ inside $R$. Either we obtain a blue
  $(t{+}1)$-clique (done), or a red $s$-clique $S \subseteq R$. Every vertex of
  $R$ is red-adjacent to $v$, and $v \notin S$, so $S \cup \{v\}$ is a red
  $(s{+}1)$-clique.
- If $|B| \ge n$, apply $n \to (s{+}1, t)$ inside $B$ symmetrically: either a red
  $(s{+}1)$-clique (done), or a blue $t$-clique $S \subseteq B$, and
  $S \cup \{v\}$ is a blue $(t{+}1)$-clique. $\square$

**Theorem 5 (Binomial bound, `arrows_recursion` / `arrows_binomial_bound`).**
For all $s, t$,
$$\binom{s+t}{s} \to (s{+}1,\, t{+}1), \qquad \text{equivalently}\qquad
R(s{+}1, t{+}1) \le \binom{s+t}{s}.$$

*Proof sketch.* Double induction on $s$ and $t$. The base cases use Lemma 3.
For the inductive step, Pascal's identity
$\binom{s+t}{s} = \binom{(s{-}1)+t}{s{-}1} + \binom{s+(t{-}1)}{s}$ matches the
additivity of thresholds in Lemma 4: combine the two smaller instances
$\binom{(s{-}1)+t}{s{-}1} \to (s, t{+}1)$ and
$\binom{s+(t{-}1)}{s} \to (s{+}1, t)$ via `arrows_step`. The binomial
coefficients are positive, satisfying the positivity hypotheses of the step.
$\square$

In the diagonal case Theorem 5 gives $R(k{+}1,k{+}1) \le \binom{2k}{k} < 4^k$.

## 4. The exact value $R(3,3)=6$

**Theorem 6 (Upper bound, `arrows_three_three`).** $6 \to (3,3)$.

*Proof.* This is the instance $s=t=2$ of Theorem 5, since $\binom{4}{2} = 6$.
$\square$

For the matching lower bound we use the pentagon.

**Definition 7 (Pentagon, `pentagon`).** Let $C_5$ be the graph on $\mathbb
Z/5$ in which $a$ and $b$ are adjacent iff $a + 1 = b$ or $b + 1 = a$.

**Lemma 8 (`pentagon_no_triangle`, `pentagon_compl_no_triangle`).** $C_5$
contains no $3$-clique, and its complement $C_5^{\mathsf c}$ (again a $5$-cycle)
contains no $3$-clique.

*Proof.* Finite verification over the $\binom{5}{3} = 10$ triples. $\square$

**Theorem 9 (Lower bound, `not_arrows_five_three_three`).** $\lnot\,(5 \to
(3,3))$.

*Proof.* The pentagon colouring of $K_5$ has neither a red nor a blue triangle
by Lemma 8, so the arrow relation fails on a $5$-vertex set. $\square$

**Theorem 10 (`ramsey_three_three`).** $6 \to (3,3)$ and $\lnot\,(5 \to (3,3))$;
that is, $R(3,3) = 6$. $\square$

## 5. The exact value $R(3,4)=9$

The binomial ceiling gives only $R(3,4) \le \binom{5}{2} = 10$. The exact value
is $9$, and we establish it in two parts.

### 5.1 Lower bound: the Möbius ladder

**Construction (`not_arrows_eight_three_four`).** On the vertex set
$\mathbb Z/8$, declare $a$ and $b$ red-adjacent iff their difference lies in the
symmetric difference set $\{\pm 1, 4\}$ — the Möbius ladder circulant
$C_8(1,4)$. This red graph is triangle-free, and its blue complement contains no
$4$-clique. Hence the colouring of $K_8$ exhibits neither a red triangle nor a
blue $K_4$, so
$$8 \not\to (3,4), \qquad R(3,4) > 8.$$

*Proof.* Finite verification of triangle-freeness and complement
$K_4$-freeness over $\mathbb Z/8$. $\square$

### 5.2 Upper bound via the handshake lemma

The core engine is a parity statement about red-degrees.

**Lemma 11 (Handshake parity, `red_nbrs_sum_even`).** For any graph $G$ and any
finite vertex set $W$,
$$\sum_{v \in W} \bigl|\{\, w \in W \setminus \{v\} : v \sim_G w \,\}\bigr|
\quad\text{is even.}$$

*Proof sketch.* The sum counts ordered red pairs $(v,w)$ with both endpoints in
$W$. The swap $(v,w) \mapsto (w,v)$ is a fixed-point-free involution on this set
(no edge is a loop), so the set has even cardinality. Equivalently, the sum
double-counts each red edge inside $W$, giving $2 \cdot |E_{\mathrm{red}}(W)|$.
$\square$

**Theorem 12 (Upper bound, `arrows_three_four`).** $9 \to (3,4)$.

*Proof sketch.* Suppose a colouring of a $9$-vertex set $W$ has no red triangle
and no blue $K_4$. A local degree analysis pins the red-degree of every vertex:

- *No vertex has red-degree $\ge 4$.* Among four red neighbours of $v$, if any
  two are red-adjacent they form a red triangle with $v$; otherwise the four are
  pairwise blue, a blue $K_4$.
- *No vertex has red-degree $\le 2$.* Then it has $\ge 6$ blue neighbours;
  inside the blue neighbourhood, avoiding a red triangle and a blue $K_4$ is
  impossible on $6$ vertices because $6 \to (3,3)$ forces a monochromatic
  triangle, which (with the centre vertex) escalates to the forbidden
  configuration.

Hence every vertex has red-degree exactly $3$, i.e. the red graph is $3$-regular
on $9$ vertices. But then $\sum_{v} \deg_{\mathrm{red}}(v) = 9 \cdot 3 = 27$ is
odd, contradicting Lemma 11. No such colouring exists. $\square$

**Theorem 13 (`ramsey_three_four`).** $9 \to (3,4)$ and $\lnot\,(8 \to (3,4))$;
that is, $R(3,4) = 9$. $\square$

## 6. The parity obstruction in full generality

The decisive step in Theorem 12 never used the numbers $3$ or $4$ — only that an
extremal colouring is forced to be regular of a fixed red-degree, and that
"odd degree on an odd number of vertices" is arithmetically impossible. We
isolate this as a standalone bridge between graph colouring and integer parity.

**Definition 14 (Red-degree inside a set, `redDeg`).** For a graph $G$, a finite
set $W$, and a vertex $v$,
$$\operatorname{redDeg}_G(W, v) \;=\; \bigl|\{\, w \in W \setminus \{v\}
: v \sim_G w \,\}\bigr|.$$

**Theorem 15 (Regularity–parity obstruction, `red_degree_parity_obstruction`).**
Let $G$ be any graph and $W$ a finite vertex set with $|W|$ **odd**. Then it is
*not* the case that $\operatorname{redDeg}_G(W, v)$ is odd for every $v \in W$.

*Proof.* By Lemma 11 the sum $S = \sum_{v \in W} \operatorname{redDeg}_G(W, v)$
is even. If every summand were odd, then $S$ would be a sum of an odd number
($|W|$) of odd terms, hence odd — a contradiction. $\square$

**Theorem 16 (No odd-regular colouring, `no_odd_regular_colouring`).** Let $G$
be any graph, $W$ a vertex set with $|W| = n$, and suppose $n \cdot d$ is odd.
Then it is *not* the case that $\operatorname{redDeg}_G(W, v) = d$ for every
$v \in W$.

*Proof.* Since $nd$ is odd, both $n$ and $d$ are odd. If every red-degree equalled
$d$, then $|W| = n$ is odd and every red-degree is odd, contradicting Theorem 15.
$\square$

The $R(3,4) \le 9$ obstruction is exactly Theorem 16 with $(n,d) = (9,3)$: since
$9 \cdot 3 = 27$ is odd, no $3$-regular red colouring exists on $9$ vertices.
Theorem 16 cleanly predicts which $(n,d)$ pairs are forbidden: precisely those
with $nd$ odd. Any sharp small Ramsey bound whose extremal colouring is forced to
be odd-regular on an odd number of vertices is now covered by this single
result.

## 7. Probabilistic lower bounds

The recursion of §3 caps Ramsey numbers from above; the probabilistic method
forces them up from below. We state the first-moment bound in its general
$r$-uniform hypergraph form, where a colouring assigns red/blue to each
$r$-element subset and a monochromatic $k$-clique is a $k$-set all of whose
$r$-subsets share a colour. Write $\mathrm{HyperRamseyProp}\,r\,n\,k\,k$ for the
$r$-uniform arrow relation on $n$ vertices with both clique parameters $k$.

**Theorem 17 (First-moment lower bound, `hyper_ramsey_counting_lower_bound`).**
Let $2 \le r \le k \le n$. If
$$2\binom{n}{k} < 2^{\binom{k}{r}},$$
then $\lnot\,\mathrm{HyperRamseyProp}\,r\,n\,k\,k$ — there is an $r$-uniform
colouring of $n$ vertices with no monochromatic $k$-clique, so the corresponding
Ramsey number exceeds $n$.

*Proof sketch.* A double-counting/averaging argument over the finite space of
all $2^{\binom{n}{r}}$ colourings. For a fixed $k$-set $T$, the number of
colourings making $T$ monochromatic is $2 \cdot 2^{\binom{n}{r} - \binom{k}{r}}$
(choose the common colour of $T$'s $\binom{k}{r}$ subsets, colour the rest
freely). Summing over the $\binom{n}{k}$ candidate sets and comparing with the
total $2^{\binom{n}{r}}$, the hypothesis $2\binom{n}{k} < 2^{\binom{k}{r}}$
forces the count of "bad" colourings strictly below the total, so a good
colouring exists. Formally this is a pigeonhole inequality:
$$\sum_{|T| = k} \bigl|\{\,c : T \text{ monochromatic under } c\,\}\bigr|
\;\le\; 2\binom{n}{k}\, 2^{\binom{n}{r} - \binom{k}{r}}
\;<\; 2^{\binom{n}{r}}. \qquad \square$$

**Corollary 18 (Graph case).** Taking $r = 2$, $\binom{k}{2} = k(k{-}1)/2$, the
threshold $2\binom{n}{k} < 2^{\binom{k}{2}}$ is satisfied for $n$ up to about
$2^{k/2}$, giving the classical
$$R(k,k) > 2^{k/2}.$$
Combined with the diagonal binomial ceiling $R(k,k) \le \binom{2k-2}{k-1} < 4^k$
of Theorem 5, this yields the long-standing exponential sandwich
$$2^{k/2} \;<\; R(k,k) \;<\; 4^k.$$
For higher uniformities the same computation gives $\binom{k}{r} = \Theta(k^r)$,
hence $R_r(k,k) > 2^{\Omega(k^{r-1})}$.

## 8. Algorithms

We summarise the constructive content as explicit procedures (full Python in the
accompanying demo).

**Algorithm A (Erdős–Szekeres binomial ceiling).** Compute the upper-bound table
$U(s,t)$ via the recursion $U(s,t) = U(s{-}1,t) + U(s,t{-}1)$ with $U(1,t) =
U(s,1) = 1$; this returns $\binom{s+t-2}{s-1}$, the bound of Theorem 5. Time
$O(st)$.

**Algorithm B (Monochromatic-clique certifier).** Given an explicit colouring on
$n$ vertices and targets $(s,t)$, search for a red $s$-clique or a blue
$t$-clique. Used to certify the lower-bound constructions: the pentagon (no
mono triangle, $n=5$) and the Möbius ladder $C_8(1,4)$ (no red triangle, no blue
$K_4$).

**Algorithm C (Parity obstruction checker).** Given a candidate degree sequence
$(d_v)_{v \in W}$, return *infeasible* whenever $|W|$ is odd and all $d_v$ are
odd, or whenever $|W| \cdot d$ is odd for a regular target $d$ — the
computational shadow of Theorems 15–16.

**Algorithm D (First-moment threshold).** For uniformity $r$ and clique size $k$,
return the largest $n$ with $2\binom{n}{k} < 2^{\binom{k}{r}}$, a certified
lower bound $R_r(k,k) > n$ (Theorem 17).

## 9. Applications

Ramsey-type guarantees underpin: error-correcting codes and combinatorial
designs (unavoidable structure forces distance/covering properties);
fault-tolerant network design (cliques that cannot be destroyed by sparse
adversaries); lower bounds in communication complexity and circuit complexity;
and the analysis of large social and biological networks, where the inevitability
of dense substructures past a size threshold is a Ramsey phenomenon. The parity
obstruction specifically formalises a recurring heuristic in extremal graph
theory — that "regular of odd degree on odd order" configurations are forbidden —
into a reusable lemma.

## 10. Discussion and future work

The central methodological message is that the gap between the binomial ceiling
($R(3,4) \le 10$) and the true value ($R(3,4) = 9$) is closed by a single
arithmetic invariant rather than by sharper recursion. By promoting the
"$27$ is odd" step to the general Theorems 15–16, we make the obstruction
portable. Concrete directions:

- **General even-pair sharpening.** When $R(s{-}1,t)$ and $R(s,t{-}1)$ are both
  even, one expects $R(s,t) \le R(s{-}1,t) + R(s,t{-}1) - 1$, strictly below the
  Erdős–Szekeres sum, with `no_odd_regular_colouring` as the engine.
- **$R(3,5) = 14$.** The binomial bound gives $15$; the gap $15 \to 14$ should
  again be a parity/counting obstruction on the forced degree sequence of a
  $13$-vertex circulant counterexample.
- **Sharpness of the base $\sqrt2$.** The first-moment threshold is structurally
  $2^{k/2}$-limited; any improvement must inject dependence information the union
  bound discards, motivating Lovász-Local-Lemma and explicit constructions.
- **Even-order extremal colourings.** Theorem 16 partitions $(n,d)$ pairs into
  forbidden ($nd$ odd) and permitted ($nd$ even); extremal colourings must live
  on the permitted side, a falsifiable structural prediction.

## 11. Conclusion

We have given a self-contained development of finite two-colour Ramsey theory
culminating in $R(3,3) = 6$ and $R(3,4) = 9$, the Erdős–Szekeres binomial
ceiling $R(s{+}1,t{+}1) \le \binom{s+t}{s}$, and the first-moment lower bound
$R(k,k) > 2^{k/2}$. The distinctive contribution is the extraction of the
handshake-parity argument behind $R(3,4)=9$ into two general theorems — the
regularity–parity obstruction and the non-existence of odd-regular colourings —
which serve as a reusable bridge between graph colouring and integer parity for
future sharp small-Ramsey results.
