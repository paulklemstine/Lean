# Finite Two-Colour Ramsey Theory: Exact Small Values, an Exact Infinite Family, and the Erdős–Szekeres Bound

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Novelty (Combinatorics / Ramsey Theory)

## Abstract

We develop, from first principles, the elementary theory of finite two-colour
Ramsey numbers in a uniform graph-theoretic framework in which a two-colouring of
a complete graph is encoded by a single graph $G$ (its *red* subgraph), the
*blue* subgraph being the complement $G^{\mathsf c}$. The central object is the
*arrow relation* $n \to (s,t)$, asserting that every red/blue colouring of any
vertex set of size at least $n$ contains a red $s$-clique or a blue $t$-clique.
Within this framework we establish four interlocking results, each fully proved:
(i) the **Erdős–Szekeres recursion** $m\to(s,t{+}1)\wedge n\to(s{+}1,t)\Rightarrow
m{+}n\to(s{+}1,t{+}1)$ and the resulting **binomial upper bound**
$R(s{+}1,t{+}1)\le\binom{s+t}{s}$; (ii) the exact small value $R(3,3)=6$, with the
lower bound witnessed by the self-complementary pentagon $C_5$; (iii) the exact
infinite family $R(2,t)=t$; and (iv) the **colour symmetry** $n\to(s,t)\Rightarrow
n\to(t,s)$. The treatment is self-contained: the recursion is a single
vertex-splitting argument, the upper bound is Pascal's rule, and the lower bounds
are explicit extremal colourings (the pentagon for $R(3,3)$, the all-blue
colouring for $R(2,t)$). We close with algorithmic content, numerical
demonstrations, and the research frontier ($R(4,4)=18$ via Paley graphs, the
probabilistic method, Hales–Jewett).

---

## 1. Introduction

Ramsey theory makes precise the principle that *complete disorder is impossible*:
any sufficiently large structure, however it is partitioned, contains a large
homogeneous substructure. The prototypical statement is the two-colour graph
Ramsey theorem. Given two target sizes $s,t$, there is a least integer $R(s,t)$
— the **Ramsey number** — such that every red/blue colouring of the edges of the
complete graph $K_{R(s,t)}$ contains a red clique on $s$ vertices or a blue clique
on $t$ vertices, while some colouring of $K_{R(s,t)-1}$ contains neither.

Exact values are notoriously scarce. The diagonal values known exactly are tiny:
$R(3,3)=6$, $R(4,4)=18$, and a short list of off-diagonal values; $R(5,5)$ remains
unknown. The scarcity is precisely what makes the few exact results, and the
general bounds that frame them, worth formalizing rigorously.

This paper presents a compact, foundational development with four contributions,
all carried out over an arbitrary ambient vertex type for maximal reusability:

1. The **Erdős–Szekeres inductive step** and the **binomial upper bound**
   $R(s{+}1,t{+}1)\le\binom{s+t}{s}$ (§4).
2. The exact small value $R(3,3)=6$, upper bound from the binomial bound and
   lower bound from the pentagon $C_5$ (§5).
3. The exact infinite family $R(2,t)=t$ by elementary direct arguments (§6).
4. The **colour-symmetry** $R(s,t)=R(t,s)$ via complementation (§7).

## 2. The arrow framework

### 2.1 Encoding a two-colouring

**Definition 2.1 (Red/blue colouring).** A two-colouring of the complete graph on
a vertex set $V$ is encoded by a simple graph $G$ on $V$. The edges of $G$ are
**red**; the edges of the complement $G^{\mathsf c}$ are **blue**. A *red
$s$-clique* is an $s$-element set that is a clique of $G$ (in Lean,
`G.IsNClique s S`); a *blue $t$-clique* is a $t$-element clique of $G^{\mathsf c}$.

The ambient type for the diagonal-shaped problem is the abbreviation
`ArrowsType s t := SimpleGraph (Fin (s + t))`.

### 2.2 The arrow relation

**Definition 2.2 (Arrow relation, `Arrows`).** For $n,s,t\in\mathbb N$,
$$
\mathrm{Arrows}\,n\,s\,t \ :\equiv\
\forall V,\ \forall G:\mathrm{SimpleGraph}\,V,\ \forall W:\mathrm{Finset}\,V,\
n\le |W| \implies
$$
$$
\bigl(\exists S\subseteq W,\ G.\mathrm{IsNClique}\,s\,S\bigr)\ \vee\
\bigl(\exists S\subseteq W,\ G^{\mathsf c}.\mathrm{IsNClique}\,t\,S\bigr).
$$
We write $n\to(s,t)$ for $\mathrm{Arrows}\,n\,s\,t$. The Ramsey number is
$R(s,t) := \min\{\,n : n\to(s,t)\,\}$.

Quantifying over an arbitrary vertex type $V$ together with a finite vertex set
$W$ of size at least $n$ (rather than fixing $V=\mathrm{Fin}\,n$) is a deliberate
design choice: it bakes monotonicity into the definition and makes the
Erdős–Szekeres recursion state cleanly, because the two recursive calls live on
*subsets* of the same vertex set.

### 2.3 Monotonicity

**Lemma 2.3 (`Arrows.mono`).** If $n\to(s,t)$ and $n\le n'$, then $n'\to(s,t)$.

*Proof.* If $|W|\ge n'\ge n$, apply the hypothesis to $W$. ∎

## 3. Trivial base cases

**Lemma 3.1 (`arrows_one_red`).** $1\to(1,b)$ for every $b$.

**Lemma 3.2 (`arrows_one_blue`).** $1\to(a,1)$ for every $a$.

*Proof.* A nonempty $W$ contains a vertex $v$; the singleton $\{v\}$ is
simultaneously a red $1$-clique (a clique of $G$) and a blue $1$-clique (a clique
of $G^{\mathsf c}$), since a one-element set is vacuously a clique in any graph. ∎

These are the seeds of the Erdős–Szekeres induction.

## 4. The Erdős–Szekeres recursion and the binomial bound

### 4.1 The inductive step

**Theorem 4.1 (Erdős–Szekeres step, `arrows_step`).** If $m>0$, $n>0$,
$m\to(s,t{+}1)$, and $n\to(s{+}1,t)$, then
$$ m+n \ \to\ (s{+}1,\ t{+}1). $$

*Proof sketch.* Let $|W|\ge m+n$. Since $m+n\ge 1$, choose $v\in W$. Partition the
remaining vertices $W\setminus\{v\}$ by the colour of their edge to $v$:
$$
R = \{x\in W\setminus\{v\} : G.\mathrm{Adj}\,v\,x\},\qquad
B = \{x\in W\setminus\{v\} : \neg\,G.\mathrm{Adj}\,v\,x\}.
$$
These partition $W\setminus\{v\}$, so $|R|+|B| = |W|-1 \ge m+n-1$. Hence $|R|\ge m$
or $|B|\ge n$.

*Case $|R|\ge m$.* Apply $m\to(s,t{+}1)$ to $R$. If we obtain a blue
$(t{+}1)$-clique, we are done. Otherwise we obtain a red $s$-clique $S\subseteq R$.
Every vertex of $S$ is red-adjacent to $v$ (by definition of $R$) and $v\notin S$,
so $S\cup\{v\}$ is a red clique of size $s+1$.

*Case $|B|\ge n$.* Symmetric, applying $n\to(s{+}1,t)$ to $B$: a red
$(s{+}1)$-clique finishes directly, while a blue $t$-clique $S\subseteq B$ extends
by $v$ (which is blue-adjacent to all of $B$) to a blue $(t{+}1)$-clique. ∎

This is the single combinatorial heart of the entire upper-bound theory.

### 4.2 The binomial upper bound

**Theorem 4.2 (Erdős–Szekeres binomial bound, `arrows_recursion` /
`arrows_binomial_bound`).** For all $s,t\in\mathbb N$,
$$ \binom{s+t}{s} \ \to\ (s{+}1,\ t{+}1), \qquad\text{equivalently}\qquad
R(s{+}1,t{+}1) \le \binom{s+t}{s}. $$

*Proof sketch.* Double induction on $s$ and $t$.

- *Base $s=0$:* $\binom{t}{0}=1$, and $1\to(1,t{+}1)$ is `arrows_one_red`.
- *Base $t=0$:* $\binom{s}{s}=1$, and $1\to(s{+}1,1)$ is `arrows_one_blue`.
- *Step:* assume $\binom{(s)+(t{+}1)}{s}\to(s{+}1,t{+}2)$ and
  $\binom{(s{+}1)+t}{s{+}1}\to(s{+}2,t{+}1)$. By Theorem 4.1 (both thresholds are
  positive, being binomial coefficients of valid arguments),
  $$ \binom{s+(t{+}1)}{s} + \binom{(s{+}1)+t}{s{+}1} \ \to\ (s{+}2,\ t{+}2). $$
  By **Pascal's rule** the two summands add to $\binom{s+t+2}{s+1}=\binom{(s{+}1)+(t{+}1)}{s{+}1}$,
  giving the claim at $(s{+}1,t{+}1)$. ∎

Symmetry of the binomial coefficient $\binom{s+t}{s}=\binom{s+t}{t}$ reflects the
colour symmetry of §7 at the level of the bound.

## 5. The exact value $R(3,3)=6$

### 5.1 Upper bound

**Theorem 5.1 (`arrows_three_three`).** $6\to(3,3)$.

*Proof.* The case $s=t=2$ of Theorem 4.2: $\binom{2+2}{2}=6$, so
$6\to(3,3)$ directly. (Equivalently, the standard "pick a vertex with $\ge 3$
same-colour edges" pigeonhole argument.) ∎

### 5.2 The pentagon and the lower bound

**Definition 5.2 (Pentagon, `pentagon`).** Let $C_5$ be the graph on
$\mathrm{Fin}\,5$ with $a\sim b$ iff $a+1=b$ or $b+1=a$ (indices mod $5$), i.e.
the $5$-cycle. Concretely, `pentagon := SimpleGraph.fromRel (fun a b => a + 1 = b)`.

**Lemma 5.3 (`pentagon_no_triangle`).** $C_5$ contains no red triangle:
$\neg\,\exists S,\ C_5.\mathrm{IsNClique}\,3\,S$.

**Lemma 5.4 (`pentagon_compl_no_triangle`).** $C_5^{\mathsf c}$ contains no blue
triangle: $\neg\,\exists S,\ C_5^{\mathsf c}.\mathrm{IsNClique}\,3\,S$.

*Proof of 5.3–5.4.* Finite verification (`decide`). The five-cycle has girth $5$,
so it contains no triangle. Its complement is the pentagram, again a five-cycle
on five vertices, hence also triangle-free. The pentagon is therefore
*self-complementary*. ∎

**Theorem 5.5 (`not_arrows_five_three_three`).** $5\not\to(3,3)$.

*Proof.* Instantiate the (negated) arrow statement with $G=C_5$ on the full
vertex set $\mathrm{Fin}\,5$. A red triangle would contradict Lemma 5.3; a blue
triangle would contradict Lemma 5.4. Hence the pentagon colouring of $K_5$ has no
monochromatic triangle, so $5\not\to(3,3)$. ∎

**Theorem 5.6 (`ramsey_three_three`, $R(3,3)=6$).**
$$ 6\to(3,3)\ \wedge\ 5\not\to(3,3), \qquad\text{i.e.}\qquad R(3,3)=6. $$

*Proof.* Conjunction of Theorems 5.1 and 5.5. ∎

## 6. The exact infinite family $R(2,t)=t$

For $s=2$ a "red clique" is a single red edge, and the Ramsey number collapses to
a closed form. This family is proved by elementary direct arguments, with no
appeal to the Erdős–Szekeres machinery (hence no circular dependency).

**Theorem 6.1 (Upper bound, `arrows_two_t`).** $t\to(2,t)$ for every $t$.

*Proof sketch.* Let $|W|\ge t$. Decide whether $G$ has a red edge inside $W$,
i.e. whether there exist distinct $u,v\in W$ with $G.\mathrm{Adj}\,u\,v$.
- If yes, $\{u,v\}$ is a red $2$-clique.
- If no, then $W$ is independent in $G$, hence a clique in $G^{\mathsf c}$; any
  $t$-element subset $S\subseteq W$ (which exists since $|W|\ge t$) is a blue
  $t$-clique. ∎

**Theorem 6.2 (Clean lower bound, `not_arrows_two_succ`).**
$t\not\to(2,t{+}1)$ for every $t$.

*Proof.* Take $G=\bot$ (the empty graph, all edges blue) on $\mathrm{Fin}\,t$.
There is no red edge, so no red $2$-clique; and a blue $(t{+}1)$-clique would need
$t+1$ vertices, but only $t$ are available. ∎

**Theorem 6.3 (Predecessor lower bound, `not_arrows_pred_two_t`).** For $t\ge 1$,
$t-1\not\to(2,t)$.

*Proof.* Writing $t=t'+1$, this is exactly Theorem 6.2 for $t'$: the all-blue
colouring on $t-1$ vertices has no red edge and too few vertices for a blue
$t$-clique. ∎

**Theorem 6.4 (`ramsey_two_t`, $R(2,t)=t$).** For every $t\ge 1$,
$$ t\to(2,t)\ \wedge\ (t-1)\not\to(2,t), \qquad\text{i.e.}\qquad R(2,t)=t. $$

*Proof.* Conjunction of Theorems 6.1 and 6.3. ∎

The companion result $R(s,2)=s$ follows immediately by the colour symmetry of §7.

## 7. Colour symmetry

**Theorem 7.1 (`Arrows.symm`).** If $n\to(s,t)$ then $n\to(t,s)$. Consequently
$R(s,t)=R(t,s)$.

*Proof.* Given a colouring $G$ and a vertex set $W$ with $|W|\ge n$, apply the
hypothesis to the complemented colouring $G^{\mathsf c}$. It yields a red
$s$-clique of $G^{\mathsf c}$ or a blue $t$-clique of $(G^{\mathsf c})^{\mathsf c}=G$.
Since $(G^{\mathsf c})^{\mathsf c}=G$ (involutivity of complementation), these are
exactly a blue $s$-clique of $G$ or a red $t$-clique of $G$ — i.e. the disjunction
required for $n\to(t,s)$. ∎

This is why Ramsey tables are recorded only for $s\le t$.

## 8. Algorithmic content

The proofs are constructive and translate into algorithms.

**Algorithm A (Vertex-splitting clique search).** The Erdős–Szekeres step
(Theorem 4.1) is an algorithm: given a colouring on $m+n$ vertices, pick a vertex
$v$, split into red/blue neighbourhoods, recurse on the larger side, and prepend
$v$ to the returned clique. Unwinding the double induction of Theorem 4.2 yields a
recursive procedure that, on $\binom{s+t}{s}$ vertices, *constructs* a
monochromatic clique of the guaranteed size.

**Algorithm B (Exhaustive small-case verification).** For fixed small $n$ the
arrow predicate is decidable: enumerate the $2^{\binom{n}{2}}$ colourings and, for
each, search the $\binom{n}{s}$ and $\binom{n}{t}$ candidate cliques. This is how
the pentagon lemmas are discharged ($2^{10}=1024$ colourings on $5$ vertices) and
how $R(3,3)=6$ can be brute-force confirmed ($2^{15}=32768$ colourings on $6$
vertices).

**Algorithm C (Binomial-bound table).** Pascal's rule computes the upper-bound
table $\binom{s+t}{s}$ in $O(st)$ arithmetic operations, providing certified
upper bounds for all $R(s{+}1,t{+}1)$ simultaneously.

## 9. Numerical illustrations

- $R(3,3)=6$: every one of the $2^{15}=32768$ colourings of $K_6$ has a
  monochromatic triangle; the pentagon colouring of $K_5$ has none.
- $R(2,t)=t$: the binomial bound gives $\binom{1+(t-1)}{1}=t$, matching the exact
  value, and the all-blue colouring on $t-1$ vertices is the extremal witness.
- Binomial bounds: with $R(s{+}1,t{+}1)\le\binom{s+t}{s}$ we get
  $R(3,4)\le\binom{5}{2}=10$ (take $s=2,t=3$) and $R(4,4)\le\binom{6}{3}=20$
  (take $s=t=3$), both finite certified bounds (the true values $9$ and $18$
  require the constructions of §10).

## 10. Discussion and future directions

The exact results here — $R(3,3)=6$, $R(2,t)=t$, the recursion, the binomial
bound, and colour symmetry — are the rigorous base of finite Ramsey theory and
point directly at the frontier.

1. **Matching $R(4,4)=18$.** The binomial bound supplies $R(4,4)\le 20$, and the
   standard refinement gives $\le 18$; the missing exact lower bound is the
   **Paley graph** on $\mathrm{GF}(17)$ ($i\sim j$ iff $i-j$ is a nonzero
   quadratic residue mod $17$), a self-complementary strongly regular graph
   $\mathrm{srg}(17,8,3,4)$ with no $K_4$ in either colour. Brute force over
   $2^{\binom{17}{2}}$ is infeasible; the algebraic $\mathrm{srg}$ parameters make
   the check tractable.
2. **Off-diagonal probabilistic bounds**, e.g. $R(3,t)=\Omega(t^2/\log t)$ via a
   weighted/deletion union bound — replacing the uniform $2^{1-\binom{s}{2}}$
   clique weight by a biased-coin binomial weight.
3. **The probabilistic method** for general lower bounds: if
   $\binom{n}{s}2^{1-\binom{s}{2}}<1$ then $n\not\to(s,s)$.
4. **Hales–Jewett**: combinatorial lines in high-dimensional grids, the
   density/colouring backbone of modern Ramsey theory.

## 11. Conclusion

Working in a single uniform arrow framework over arbitrary vertex types, we have
given fully self-contained proofs of the Erdős–Szekeres recursion and binomial
bound $R(s{+}1,t{+}1)\le\binom{s+t}{s}$, the exact small value $R(3,3)=6$
(pentagon lower bound), the exact infinite family $R(2,t)=t$, and the colour
symmetry $R(s,t)=R(t,s)$. The combinatorial content is elementary — one
vertex-splitting recursion, Pascal's rule, and two explicit extremal colourings —
yet it furnishes a complete, exact, and reusable foundation on which the deeper
constructions of the frontier can be built.
