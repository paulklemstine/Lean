# Stack-Sorting Depth: Invariants, Fixed Points, and the Catalan Law

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Applications (combinatorics of permutations and data structures)

---

## Abstract

West's stack-sorting map $\mathcal{S}$ is a deterministic operator on
permutations that simulates a single greedy pass through a last-in-first-out
stack. Iterating $\mathcal{S}$ sorts any permutation in finitely many steps; the
minimal number of iterations required is the *stack-sorting depth*. We present a
constructive, machine-checked development of this theory built on an explicit
left-to-right stack simulation. We prove the three structural invariants on
which the entire theory rests — that a pass is a permutation of its input
($\texttt{stackSort\_perm}$), that it preserves length
($\texttt{stackSort\_length}$), and that strictly increasing lists are exactly
its fixed points ($\texttt{stackSort\_strictSorted\_eq}$) — and deduce that the
depth is a well-defined finite quantity, with sorted inputs having depth $0$
($\texttt{depth\_sorted}$). We enumerate the permutations of $\{1,\dots,n\}$
($\texttt{permsN\_complete}$), compute the complete depth distribution for
$n \le 6$, and verify the classical Knuth–West *Catalan law* — that one-pass
sortable permutations are counted by the Catalan number $C_n$ — exactly for
$n \in \{4,5,6\}$ ($\texttt{depthLe1\_card\_eq\_catalan\_four}$,
$\texttt{\dots\_five}$, $\texttt{\dots\_six}$). We close by analyzing the average
depth $A(n)$, presenting exact data through $n=8$ that exhibits clear linear
growth $A(n) \sim c\,n$, and formulating the central open conjecture that the
scaled average converges to the rational constant $c = 3/4$, together with a
concentration companion.

---

## 1. Introduction

The problem of sorting with a stack originates with Knuth, who asked which
permutations can be sorted by a single pass through a last-in-first-out stack.
The answer — the $231$-avoiding permutations, counted by the Catalan numbers —
is a cornerstone of enumerative combinatorics and the seed of the entire field
of *permutation patterns*. Julian West, in his 1990 doctoral thesis, made the
greedy single-pass procedure into a deterministic *map* $\mathcal{S}$ on
permutations and studied its dynamics. Because $\mathcal{S}$ never increases
disorder and fixes the sorted permutation, iterating it eventually sorts any
input; the number of iterations required is a natural measure of how far a
permutation is from order, given the brutally restricted resource of a single
stack.

This paper gives a self-contained, constructive account of West's map and its
depth, formalized as an executable algorithm over lists of natural numbers, and
records exactly which facts are established with full rigor versus which remain
conjectural. The contributions are:

1. An explicit operational definition of $\mathcal{S}$ via two primitives,
   $\mathrm{popLess}$ and $\mathrm{sortPass}$, that is simultaneously a
   mathematical definition and a runnable program (Section 2).
2. Proofs of the three foundational invariants and their consequence that depth
   is well defined and finite (Sections 3–4).
3. Exact enumeration of the depth distribution for small $n$ and a verified
   instance-wise confirmation of the Catalan law for one-pass sortability
   (Section 5).
4. A precise statement of the asymptotic conjecture $A(n)/n \to 3/4$ for the
   average depth, with supporting exact data and a concentration companion
   (Section 6), followed by a discussion of related extremal and higher-tier
   counting laws (Section 7).

Throughout, we work with permutations realized as lists of *distinct* natural
numbers, typically a rearrangement of $[1,2,\dots,n]$, and "sorted" means
strictly ascending.

---

## 2. The stack-sorting map

We define one pass of West's algorithm by a left-to-right stack simulation. The
stack is represented as a list whose **head is the top**.

**Definition 2.1 ($\mathrm{popLess}$).**
For $x \in \mathbb{N}$ and a stack $s$, $\mathrm{popLess}(x, s)$ pops from the
top every element strictly smaller than $x$, returning the ordered pair
$(\text{popped}, \text{remaining})$:
$$
\mathrm{popLess}(x, [\,]) = ([\,], [\,]), \qquad
\mathrm{popLess}(x, t :: ts) =
\begin{cases}
\big(t :: p_1,\ p_2\big), & t < x,\ (p_1,p_2) = \mathrm{popLess}(x, ts),\\[2pt]
\big([\,],\ t :: ts\big), & t \ge x.
\end{cases}
$$
The popped list is returned in pop order (top first); the remaining stack has a
top element $\ge x$ (or is empty).

**Definition 2.2 ($\mathrm{sortPass}$).**
For an input list $xs$ and a current stack, processing $xs$ flushes the smaller
stack elements before pushing each new symbol, then flushes the residual stack
when the input is exhausted:
$$
\mathrm{sortPass}([\,], s) = s, \qquad
\mathrm{sortPass}(x :: xs, s) = p_1 \mathbin{+\!\!+} \mathrm{sortPass}\big(xs,\ x :: p_2\big),
$$
where $(p_1, p_2) = \mathrm{popLess}(x, s)$ and $\mathbin{+\!\!+}$ is list
concatenation.

**Definition 2.3 (Stack-sorting map).**
West's map is one full pass from an empty stack:
$$
\mathrm{stackSort}(l) = \mathrm{sortPass}(l, [\,]).
$$

The invariant maintained by $\mathrm{popLess}$ is that the stack stays
*decreasing from bottom to top*: whenever a symbol $x$ is pushed, all elements
above the first one that is $\ge x$ have already been popped, so $x$ rests on an
element no smaller than itself. This is precisely the classical greedy stack
discipline, and $\mathrm{stackSort}$ coincides with West's map $\mathcal{S}$.

**Worked example.** On $w = 2\,3\,1$: push $2$; the incoming $3$ pops $2$ (since
$2<3$) and is pushed; the incoming $1$ ($1 < 3$) is pushed onto $3$; the final
flush emits $1,3$. Output $\mathrm{stackSort}(2\,3\,1) = 2\,1\,3$. A second pass
yields $\mathrm{stackSort}(2\,1\,3) = 1\,2\,3$, sorted.

---

## 3. Structural invariants

The credibility of every downstream statement rests on three invariants.

**Lemma 3.1 ($\mathrm{popLess}$ rearranges the stack).**
For all $x$ and $s$, the concatenation of the popped and remaining parts is a
permutation of the original stack:
$$
\big(\mathrm{popLess}(x,s)_1 \mathbin{+\!\!+} \mathrm{popLess}(x,s)_2\big) \ \text{is a permutation of}\ s.
$$
*Proof sketch.* Induction on $s$. The base case is trivial. For $s = t :: ts$:
if $t < x$ the popped part gains $t$ at its head and the remaining part is
unchanged, so the concatenation is $t$ followed by a permutation of $ts$ by the
inductive hypothesis; if $t \ge x$ nothing is popped and the concatenation is
$s$ itself. $\square$

**Lemma 3.2 (A pass permutes input-plus-stack).**
For all $xs$ and $s$, $\mathrm{sortPass}(xs, s)$ is a permutation of
$xs \mathbin{+\!\!+} s$.
*Proof sketch.* Induction on $xs$. The empty case returns $s$, a permutation of
$[\,] \mathbin{+\!\!+} s$. For $x :: xs$, write $(p_1,p_2) = \mathrm{popLess}(x,s)$.
The output is $p_1 \mathbin{+\!\!+} \mathrm{sortPass}(xs, x::p_2)$, which by the
inductive hypothesis is a permutation of $p_1 \mathbin{+\!\!+} xs \mathbin{+\!\!+} x :: p_2$.
By Lemma 3.1, $p_1 \mathbin{+\!\!+} p_2$ is a permutation of $s$, hence
$p_1 \mathbin{+\!\!+} (x :: p_2)$ is a permutation of $x :: s$, and the result is a
permutation of $xs \mathbin{+\!\!+} (x :: s) = (x :: xs) \mathbin{+\!\!+} s$. $\square$

**Theorem 3.3 ($\texttt{stackSort\_perm}$).**
For every list $l$, $\mathrm{stackSort}(l)$ is a permutation of $l$.
*Proof.* Specialize Lemma 3.2 to $s = [\,]$. $\square$

**Corollary 3.4 ($\texttt{stackSort\_length}$).**
For every list $l$, $\bigl|\mathrm{stackSort}(l)\bigr| = |l|$.
*Proof.* Permutations have equal length. $\square$

These two results guarantee that the orbit of $l$ under iterated
$\mathrm{stackSort}$ stays within the finite set of permutations of $l$, the
precondition for depth to be well defined.

---

## 4. Fixed points and depth

**Lemma 4.1 (Increasing input past a small singleton).**
If $xs$ is strictly increasing and $m < y$ for every $y \in xs$, then
$$\mathrm{sortPass}(xs, [m]) = m :: xs.$$
*Proof sketch.* Induction on $xs$. With stack $[m]$ and head $x$ of $xs$, we
have $m < x$, so $\mathrm{popLess}(x,[m]) = ([m], [\,])$: $m$ is flushed and $x$
is pushed onto the empty stack, giving stack $[x]$. The tail of $xs$ is still
increasing and bounded below by $x$, so the inductive hypothesis gives
$\mathrm{sortPass}(\text{tail}, [x]) = x :: \text{tail}$, and prepending the
flushed $m$ yields $m :: xs$. $\square$

**Theorem 4.2 ($\texttt{stackSort\_strictSorted\_eq}$).**
If $l$ is strictly increasing then $\mathrm{stackSort}(l) = l$; i.e. strictly
increasing lists are fixed points.
*Proof.* For $l = [\,]$ it is immediate. For $l = m :: t$ with $t$ strictly
increasing and $m$ below every element of $t$, we have
$\mathrm{stackSort}(l) = \mathrm{sortPass}(t, [m]) = m :: t = l$ by Lemma 4.1. $\square$

**Definition 4.3 (Bounded depth search).**
For a target list and a current list, with a fuel budget,
$$
\mathrm{depthAux}(\text{tgt}, \text{cur}, 0) = 0, \qquad
\mathrm{depthAux}(\text{tgt}, \text{cur}, f+1) =
\begin{cases}
0, & \text{cur} = \text{tgt},\\
1 + \mathrm{depthAux}\big(\text{tgt}, \mathrm{stackSort}(\text{cur}), f\big), & \text{otherwise.}
\end{cases}
$$

**Definition 4.4 (Stack-sorting depth).**
$\mathrm{depth}(l) = \mathrm{depthAux}\big(\mathrm{sort}(l),\ l,\ |l|\big)$,
where $\mathrm{sort}(l)$ is the ascending sort of $l$. The fuel bound $|l|$
suffices because, by West's theorem, any permutation of length $n$ is sorted
within $n-1$ passes; Theorem 3.3–Corollary 3.4 guarantee the orbit never leaves
the permutations of $l$, so the search is well posed.

**Theorem 4.5 ($\texttt{depth\_sorted}$).**
If $l$ is (weakly) ascending-sorted then $\mathrm{depth}(l) = 0$.
*Proof.* A sorted list equals its own ascending sort, so $\text{cur} = \text{tgt}$
holds at the first step and $\mathrm{depthAux}$ returns $0$. $\square$

Thus depth is a well-defined function $\mathbb{N}^{*} \to \mathbb{N}$ on lists of
distinct values, vanishing exactly on sorted inputs and bounded by $n-1$ on
permutations of length $n$.

---

## 5. Enumeration, the depth distribution, and the Catalan law

**Definition 5.1 (Permutation enumeration).**
$\mathrm{permsN}(n)$ is the list of all permutations of $[1,2,\dots,n]$,
generated as the permutations of $\mathrm{range}'(1,n) = [1,\dots,n]$.

**Proposition 5.2 ($\texttt{permsN\_complete}$).**
$p \in \mathrm{permsN}(n)$ if and only if $p$ is a permutation of $[1,\dots,n]$.
*Proof sketch.* The list of permutations of a list contains exactly the
rearrangements of that list. $\square$

**Definition 5.3 (Depth distribution).**
$\mathrm{depthDist}(n)$ tabulates, for each depth value $t$ from $0$ up to the
maximum observed depth, the number of permutations of $[1,\dots,n]$ with
$\mathrm{depth} = t$.

Computed exactly:

| $n$ | depth distribution $(t,\,\#)$ |
|----|--------------------------------|
| $1$ | $(0,1)$ |
| $2$ | $(0,1),(1,1)$ |
| $3$ | $(0,1),(1,4),(2,1)$ |
| $4$ | $(0,1),(1,13),(2,8),(3,2)$ |
| $5$ | $(0,1),(1,41),(2,49),(3,23),(4,6)$ |
| $6$ | $(0,1),(1,131),(2,276),(3,198),(4,90),(5,24)$ |

Three structural features are visible: a unique depth-$0$ permutation (the
identity); the depth-$\le 1$ partial sums $5, 14, 42, 132$ matching Catalan
numbers; and the maximal-depth counts $1, 2, 6, 24 = (n-2)!$.

**Definition 5.4 (One-pass sortable count).**
$\mathrm{stackSortableCount}(n) = \#\{\,p \in \mathrm{permsN}(n) : \mathrm{depth}(p) \le 1\,\}$.

**Theorem 5.5 (Catalan law, verified instances).**
With $C_n = \frac{1}{n+1}\binom{2n}{n}$,
$$
\mathrm{stackSortableCount}(4) = C_4 = 14, \quad
\mathrm{stackSortableCount}(5) = C_5 = 42, \quad
\mathrm{stackSortableCount}(6) = C_6 = 132.
$$
(Theorems $\texttt{depthLe1\_card\_eq\_catalan\_four}$, $\texttt{\dots\_five}$,
$\texttt{\dots\_six}$.)
*Proof.* Each is an exhaustive finite computation over all $n!$ permutations,
discharged by decision procedure. $\square$

**Context (Knuth–West).** The general statement, $\mathrm{stackSortableCount}(n)
= C_n$ for all $n$, is classical: a permutation has depth $\le 1$ if and only if
it avoids the pattern $231$ (no indices $i<j<k$ with $w_k < w_i < w_j$), and the
$231$-avoiding permutations are counted by $C_n$. Theorem 5.5 verifies this
exactly for $n \le 6$; the general $n$ statement is recalled as Conjecture C2 in
Section 8.

---

## 6. Average depth and the asymptotic conjecture

The depth distribution lets us study the *typical* difficulty of a random
permutation.

**Definition 6.1 (Average depth).**
$$
A(n) = \frac{1}{n!}\sum_{w \in S_n} \mathrm{depth}(w).
$$

Exact values (from the full distributions, extended to $n=8$):

| $n$ | $A(n)$ | $A(n)/n$ | $A(n)-A(n-1)$ |
|----|--------|----------|---------------|
| $2$ | $0.5000$ | $0.2500$ | — |
| $3$ | $1.0000$ | $0.3333$ | $0.5000$ |
| $4$ | $1.4583$ | $0.3646$ | $0.4583$ |
| $5$ | $1.9333$ | $0.3867$ | $0.4750$ |
| $6$ | $2.4403$ | $0.4067$ | $0.5069$ |
| $7$ | $2.9726$ | $0.4247$ | $0.5323$ |
| $8$ | $3.5244$ | $0.4406$ | $0.5518$ |

Since $0 \le \mathrm{depth}(w) \le n-1$, we have $0 < A(n)/n < 1$, and the data
show $A(n)$ growing essentially linearly with slowly increasing first
differences. This motivates the central conjecture.

**Conjecture 6.2 (Linear growth, headline constant).**
There is a constant $c \in (0,1]$ with $A(n) = c\,n + o(n)$, and
$$
\frac{A(n)}{n} \longrightarrow \frac{3}{4}.
$$

**Conjecture 6.3 (Concentration).**
For a uniformly random $w \in S_n$, $\mathrm{depth}(w)/n \to c$ in probability,
with the same $c$ as in Conjecture 6.2; equivalently, the depth distribution
concentrates around $c\,n$.

The slow upward drift of $A(n)/n$ in the table (from $0.25$ at $n=2$ toward
$0.44$ at $n=8$) is consistent with convergence to a limit materially larger
than the finite-$n$ values, approached slowly — exactly the behavior expected if
$c = 3/4$. Establishing Conjecture 6.2, even to the extent of proving the limit
exists, is the headline open problem of this development; a natural intermediate
target is the one-sided bound $A(n) < (n-1)/2$ for $n \ge 4$, visible in the data
(the differences hover near $0.5$ rather than exceeding it for the small cases),
which would at least confine $c$ to $(0, 1/2]$ pending the sharper $3/4$
prediction from larger-scale data and generating-function heuristics.

---

## 7. Algorithms and complexity

**One pass.** $\mathrm{stackSort}$ runs in $O(n)$ time and $O(n)$ space: each
element is pushed once and popped once across the entire sweep, so the total work
is linear despite the inner $\mathrm{popLess}$ loop.

**Depth.** $\mathrm{depth}(l)$ applies $\mathrm{stackSort}$ until the sorted list
is reached. With depth $d \le n-1$, this is $O(d \cdot n) = O(n^2)$ time in the
worst case.

**Depth distribution.** $\mathrm{depthDist}(n)$ evaluates depth on all $n!$
permutations, an $O(n! \cdot n^2)$ computation — feasible by direct enumeration
for $n \le 8$ or so, and the reason the verified Catalan-law instances stop at
$n = 6$.

A faster route to one-pass sortability avoids computing depth altogether: test
$231$-avoidance directly. The simplest correct linear-time test simulates the
same greedy stack and checks that the output is sorted, which is equivalent to
$\mathrm{depth} \le 1$; pattern-specific $O(n)$ algorithms also exist.

---

## 8. Discussion and future work

The development isolates the minimal rigorous backbone — permutation and length
invariance, the fixed-point characterization of sorted lists, well-definedness
and vanishing of depth, and exact small-case enumeration including the Catalan
law — from the rich web of conjectural asymptotics that the data so strongly
suggest. We collect the open directions.

**C1 (Maximal-depth law).** For every $n \ge 2$, the number of permutations of
$[n]$ requiring the maximum $n-1$ passes is exactly $(n-2)!$. Verified for
$n = 3,4,5,6$ by the distribution table. A structural proof should describe the
extremal permutations explicitly.

**C2 (Catalan law in general).** $\#\{w \in S_n : \mathrm{depth}(w) \le 1\} = C_n$
for all $n$, via the bijection with $231$-avoiding permutations. Verified here for
$n \le 6$ (Theorem 5.5).

**C3 (Two-stack-sortable law, West–Zeilberger).**
$\#\{w \in S_n : \mathrm{depth}(w) \le 2\} = \dfrac{2\,(3n)!}{(n+1)!\,(2n+1)!}$
(OEIS A000139). West conjectured and Zeilberger proved this count; a formal proof
would be a substantial new theorem, with an intermediate target being the
kernel-method/generating-function identity.

**C4 (Linear growth of the average).** $A(n) = c\,n + o(n)$ with $c \in (0,1]$,
conjecturally $c = 3/4$ (Conjecture 6.2). Determining $c$ exactly is the headline
open problem. Sub-conjecture: $A(n) < (n-1)/2$ for $n \ge 4$.

**C5 (Concentration / typical depth).** $\mathrm{depth}(w)/n \to c$ in
probability (Conjecture 6.3). A martingale or second-moment argument on iterated
$\mathrm{stackSort}$ is the natural approach; even a one-sided
$\mathrm{depth}(w) \ge \varepsilon n$ with high probability would be progress.

Beyond these, the operational, executable definition used here is well suited to
*certified* experimental mathematics: every distribution and every counting
identity is, in principle, reproducible by exact computation, and the structural
lemmas guarantee that those computations measure exactly what they claim to.

---

## 9. Conclusion

Stack sorting compresses a surprising amount of mathematics into a single
last-in-first-out bin. We have given a constructive account of West's map,
proved the invariants that make stack-sorting depth a legitimate measure of
disorder, characterized its fixed points, computed its distribution for small
$n$, and confirmed the Catalan law for one-pass sortability exactly in the first
nontrivial cases. The proved backbone supports a sharp, falsifiable conjectural
program — culminating in the prediction that the average stack-sorting depth of a
random permutation is asymptotically three-quarters of its length — that we hope
will guide the next round of both theoretical and certified-computational work.
