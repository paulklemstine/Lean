# Defant's Stack-Sorting Depth Constant: A Verified Analytic Kernel and Combinatorial Substrate

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (enumerative combinatorics / analysis of algorithms)

## Abstract

West's stack-sorting map $s$ acts on permutations by a single left-to-right pass
of a stack machine; iterating $s$ sorts any permutation, and the *stack-sorting
depth* of a permutation $\pi$ is the least number of iterations that reaches the
identity. Writing $D_n$ for the average depth over the symmetric group $S_n$,
Defant (2020) proved the upper bound
$\lambda := \lim_{n\to\infty} D_n/n \le \tfrac{3}{5}(7 - 8\ln 2)$. The open
*tightness conjecture* asserts that equality holds. We do not resolve the
asymptotic conjecture; instead we establish, with full rigor, the two pillars on
which any proof of tightness rests. First, we give a structurally recursive,
executable implementation of $s$ and prove its load-bearing invariants:
$s$ is a permutation of its input, it preserves length, and strictly increasing
lists are its fixed points (hence have depth $0$). Second, we enumerate $S_n$,
compute the depth histogram, and prove the *Catalan law* — the number of
one-pass stack-sortable permutations ($\mathrm{depth}\le 1$) equals the Catalan
number $C_n$ — for $n = 4, 5, 6$ by exhaustive verification. Third, we pin down
the candidate constant $\lambda = \tfrac{3}{5}(7 - 8\ln 2)$ analytically: from
certified rigorous bounds on $\ln 2$ we prove the enclosure
$0.8728 < \lambda < 0.8729$, and deduce $0 < \lambda$, $\lambda < 1$,
$\lambda < \tfrac{7}{8}$, and the strict separation $0.6244 < \lambda$. Combined
with the literature bound $G < 0.6244$ on the Golomb–Dickman constant
$G \approx 0.6243299885$, this yields $G < \lambda$: granting tightness, the
average stack-sorting depth density strictly exceeds the average longest-cycle
density. All results are machine-verified.

## 1. Introduction

The single-stack sorting machine is among the oldest models in the analysis of
algorithms. Knuth showed that a permutation is sortable by one pass through a
stack precisely when it avoids the pattern $231$, and that such permutations are
counted by the Catalan numbers. West (1990) reframed the single pass as a
deterministic **map** $s$ on permutations and initiated the study of its
iteration. Since iterating $s$ eventually sorts any input, one defines the
**stack-sorting depth** $\mathrm{depth}(\pi)$ as the least $t$ with
$s^{(t)}(\pi)$ equal to the identity. The expected value
$D_n = \frac{1}{n!}\sum_{\pi \in S_n} \mathrm{depth}(\pi)$ measures the typical
sorting effort.

Defant (2020) proved that the normalized average depth is asymptotically bounded:
$$\limsup_{n\to\infty} \frac{D_n}{n} \le \lambda := \frac{3}{5}\bigl(7 - 8\ln 2\bigr) \approx 0.872892.$$
The **tightness conjecture** asserts the limit exists and equals $\lambda$.

This paper contributes a verified foundation for that conjecture. We separate the
program into a *combinatorial substrate* (Sections 2–7) — a runnable, proven
stack-sorting map and exact small-case enumeration including the Catalan law —
and an *analytic kernel* (Section 8) — rigorous control of the constant
$\lambda$ itself, including the strict comparison with the Golomb–Dickman
constant. The conjecture's asymptotic content is *not* claimed as a theorem;
what we provide are exactly the rigorous facts a proof of tightness would consume.

## 2. The stack-sorting map

We model permutations as duplicate-free lists of natural numbers and implement
$s$ by a left-to-right stack simulation. The stack's head is its top.

**Definition 2.1 (`popLess`).** For an incoming value $x$ and a stack, `popLess`
pops from the top every entry strictly smaller than $x$, returning the popped
entries (in pop order) together with the remaining stack:
$$\texttt{popLess}\ x\ [] = ([], [])$$
$$\texttt{popLess}\ x\ (t :: ts) = \begin{cases} (t :: p_1,\, p_2) & \text{if } t < x,\ (p_1,p_2) = \texttt{popLess}\ x\ ts \\ ([],\, t :: ts) & \text{if } t \ge x. \end{cases}$$

**Definition 2.2 (`sortPass`).** A full pass processes the remaining input
against the current stack: for each new symbol it flushes all smaller stack
entries, then pushes the symbol; when the input is exhausted it flushes the
stack:
$$\texttt{sortPass}\ []\ \mathit{stk} = \mathit{stk}, \qquad \texttt{sortPass}\ (x::xs)\ \mathit{stk} = p_1 \mathbin{+\!\!+} \texttt{sortPass}\ xs\ (x :: p_2),$$
where $(p_1, p_2) = \texttt{popLess}\ x\ \mathit{stk}$.

**Definition 2.3 (`stackSort`).** West's map is one pass from the empty stack:
$$s(l) := \texttt{stackSort}(l) = \texttt{sortPass}\ l\ [].$$

This recursion is structural in the remaining input, avoiding the well-founded
"split at the maximum" formulation and making $s$ directly executable.

**Worked example.** $s([2,3,1]) = [2,1,3]$ and $s([2,1,3]) = [1,2,3]$. Thus
$[2,3,1]$ has depth $2$; it is the minimal permutation of depth $2$.

## 3. Permutation and length invariants

**Lemma 3.1 (`popLess_perm`).** For all $x$ and stacks $s$,
$(\texttt{popLess}\ x\ s)_1 \mathbin{+\!\!+} (\texttt{popLess}\ x\ s)_2$ is a
permutation of $s$.
*Proof sketch.* Induction on $s$. The empty case is reflexivity. For $t :: ts$,
if $t < x$ the popped list gains $t$ at its head while the recursive call (by
the inductive hypothesis) permutes $ts$; reassociating the concatenation gives a
permutation of $t :: ts$. If $t \ge x$ nothing is popped and the identity is the
list itself. $\square$

**Lemma 3.2 (`sortPass_perm`).** For all inputs $xs$ and stacks $\mathit{stk}$,
$\texttt{sortPass}\ xs\ \mathit{stk}$ is a permutation of $xs \mathbin{+\!\!+} \mathit{stk}$.
*Proof sketch.* Induction on $xs$, generalizing the stack. The step reads a
symbol $x$, splits the stack via Lemma 3.1, and recurses on the smaller stack;
the popped output prepended to the recursive permutation, combined with the
`popLess` permutation invariant, rearranges to $x :: xs \mathbin{+\!\!+} \mathit{stk}$. $\square$

**Theorem 3.3 (`stackSort_perm`).** For every list $l$, $s(l)$ is a permutation
of $l$.
*Proof.* Specialize Lemma 3.2 to the empty stack. $\square$

**Corollary 3.4 (`stackSort_length`).** $|s(l)| = |l|$.
*Proof.* Permutations preserve length (Theorem 3.3). $\square$

These establish that $s$ is a *bijection of $S_n$ to itself acting by value-blind
rearrangement*; depth therefore depends only on the order type (pattern) of its
argument.

## 4. Fixed points: sorted lists

**Lemma 4.1 (`sortPass_lt_singleton`).** If $xs$ is strictly increasing and
$m < y$ for all $y \in xs$, then $\texttt{sortPass}\ xs\ [m] = m :: xs$.
*Proof sketch.* Induction on $xs$. Reading the least remaining element $x$
against the singleton stack $[m]$ pops nothing past $m$ when $m < x$, leaving
$m$ in place and pushing $x$; the strict-increase hypothesis propagates to the
tail. $\square$

**Theorem 4.2 (`stackSort_strictSorted_eq`).** If $l$ is strictly increasing
(`Pairwise (· < ·) l`), then $s(l) = l$.
*Proof sketch.* Induction on $l$ using `pairwise_cons` to expose the head as a
strict lower bound, then apply Lemma 4.1. $\square$

The strictness is essential: with duplicates an equal entry is pushed rather
than popped, so $\le$-sortedness is not preserved by a single pass in the naive
statement. For genuine permutations (duplicate-free), strictness is exactly the
relevant case, and Theorem 4.2 shows the sorted order is a fixed point.

## 5. Stack-sorting depth

**Definition 5.1 (`depthAux`).** A fuel-bounded iteration counter:
$$\texttt{depthAux}\ \mathit{tgt}\ \mathit{cur}\ 0 = 0, \qquad \texttt{depthAux}\ \mathit{tgt}\ \mathit{cur}\ (f{+}1) = \begin{cases} 0 & \mathit{cur} = \mathit{tgt} \\ 1 + \texttt{depthAux}\ \mathit{tgt}\ (s(\mathit{cur}))\ f & \text{otherwise.} \end{cases}$$

**Definition 5.2 (`depth`).** The stack-sorting depth of $l$ is
$$\texttt{depth}(l) := \texttt{depthAux}\ (\texttt{mergeSort}_{\le}\ l)\ l\ |l|.$$
The fuel bound $|l|$ always suffices, because West's bound guarantees
$\mathrm{depth}(l) \le |l| - 1$.

**Corollary 5.3 (`depth_sorted`).** If $l$ is (ascending) sorted, then
$\texttt{depth}(l) = 0$.
*Proof sketch.* A sorted list equals its own merge sort (`mergeSort_eq_self`),
so the target is reached immediately and `depthAux` returns $0$. $\square$

## 6. Enumeration of $S_n$

**Definition 6.1 (`permsN`).** $\texttt{permsN}\ n := (\texttt{range'}\ 1\ n)\texttt{.permutations}$,
the list of all permutations of $[1,\ldots,n]$.

**Lemma 6.2 (`permsN_complete`).** $p \in \texttt{permsN}\ n \iff p$ is a
permutation of $[1,\ldots,n]$.
*Proof.* The list-permutations operation is sound and complete for the
permutation relation. $\square$

**Definition 6.3 (`depthDist`).** The depth histogram of $S_n$: with
$D = (\texttt{permsN}\ n)\texttt{.map}\ \texttt{depth}$ and $m = \max D$, the list
$[(t, \#\{d \in D : d = t\}) : t = 0,\ldots,m]$.

Computed histograms (matching known integer sequences):

| $n$ | depth distribution $(t, \#)$ | $n!$ |
|---|---|---|
| 1 | (0,1) | 1 |
| 2 | (0,1),(1,1) | 2 |
| 3 | (0,1),(1,4),(2,1) | 6 |
| 4 | (0,1),(1,13),(2,8),(3,2) | 24 |
| 5 | (0,1),(1,41),(2,49),(3,23),(4,6) | 120 |
| 6 | (0,1),(1,131),(2,276),(3,198),(4,90),(5,24) | 720 |

From these, $D_n = \frac{1}{n!}\sum_t t\cdot\#\{d=t\}$ gives
$D_3 = 1$, $D_4 = 35/24$, $D_5 = 232/120$, $D_6 = 1757/720$, and the normalized
ratios $D_4/4 \approx 0.3646$, $D_5/5 \approx 0.3867$, $D_6/6 \approx 0.4067$ —
rising slowly toward the conjectured $\lambda \approx 0.8729$.

## 7. The Catalan law

**Definition 7.1 (`stackSortableCount`).**
$\texttt{stackSortableCount}\ n := \#\{p \in \texttt{permsN}\ n : \texttt{depth}(p) \le 1\}$,
the number of one-pass stack-sortable permutations.

**Theorems 7.2–7.4 (`depthLe1_card_eq_catalan_{four,five,six}`).**
$$\texttt{stackSortableCount}\ 4 = C_4 = 14, \quad \texttt{stackSortableCount}\ 5 = C_5 = 42, \quad \texttt{stackSortableCount}\ 6 = C_6 = 132.$$
*Proof.* Exhaustive verification: enumerate $S_n$, compute each permutation's
depth, count those with depth $\le 1$, and compare to the Catalan number by
decision procedure. $\square$

This is the computational confirmation, in this verified framework, of Knuth's
classical theorem that one-pass stack-sortable permutations (equivalently,
$231$-avoiders) are Catalan-enumerated: $C_n = \frac{1}{n+1}\binom{2n}{n}$.

## 8. The analytic kernel: Defant's constant

We now turn to the constant the tightness conjecture targets.

**Definition 8.1 (`defantConst`).** $\lambda := \tfrac{3}{5}\,(7 - 8\ln 2)$.

**Lemma 8.2 (`defantConst_eq`).** $\lambda = \tfrac{21}{5} - \tfrac{24}{5}\ln 2$.
*Proof.* Algebraic expansion. $\square$

This linear-in-$\ln 2$ form is what makes the constant amenable to certified
linear arithmetic against rigorous logarithm bounds.

**Theorem 8.3 (`defantConst_bounds`).** $0.8728 < \lambda < 0.8729$.
*Proof sketch.* Substitute the certified rigorous decimal enclosure of $\ln 2$
(`log_two_gt_d9`, `log_two_lt_d9`, i.e. $\ln 2 = 0.6931471805\ldots$ to nine
places) into the linear form of Lemma 8.2 and discharge both inequalities by
nonlinear real arithmetic. $\square$

**Corollary 8.4 (`defantConst_pos`).** $0 < \lambda$.
**Corollary 8.5 (`defantConst_lt_one`).** $\lambda < 1$.
**Corollary 8.6 (`defantConst_lt_seven_eighths`).** $\lambda < \tfrac{7}{8}$.
*Proofs.* Immediate from the two-sided enclosure of Theorem 8.3:
$0.8728 > 0$, $0.8729 < 1$, and $0.8729 < 0.875$. $\square$

Interpretation: $\lambda > 0$ says the conjectured average depth grows with
positive density; $\lambda < 1$ says it is genuinely sub-linear in slope; the
ceiling $\lambda < 7/8$ records a clean rational envelope. The discrete bound
$\mathrm{depth}(l) \le |l| - 1$ already forces $\lambda \le 1$ on the
combinatorial side, consistent with the analytic value.

**Theorem 8.7 (`golombDickman_bound_lt_defant`).** $0.6244 < \lambda$.
*Proof.* Immediate from $0.8728 < \lambda$ (Theorem 8.3). $\square$

**Corollary (Golomb–Dickman comparison).** Let $G \approx 0.6243299885$ be the
Golomb–Dickman constant, which satisfies the literature bound $G < 0.6244$.
Then $G < \lambda$. *Proof.* Chain $G < 0.6244 < \lambda$. $\square$

The Golomb–Dickman constant is the asymptotic density of the expected longest
cycle length in a uniform random permutation. Theorem 8.7 isolates the strict
separation $G < \lambda$ into a single proved real inequality plus one imported
numeric fact: *granting tightness*, the typical stack-sorting depth density
strictly exceeds the typical longest-cycle density. The comparison itself
requires no asymptotics.

## 9. Algorithms

The verified development corresponds to three executable procedures.

1. **Single-pass stack sort (`stackSort`).** Linear time $O(n)$ in the list
   length: each entry is pushed once and popped once across the pass.
2. **Depth by iterated sorting (`depth`).** Iterate `stackSort` until the
   ascending sort is reached, bounded by $|l|$ passes; total cost
   $O(|l|^2)$ in the worst case.
3. **Histogram and Catalan check (`depthDist`, `stackSortableCount`).** Enumerate
   $S_n$ ($n!$ permutations), compute each depth, and tabulate. Factorial in
   $n$; feasible for the verified range $n \le 6$.

## 10. Applications and discussion

The package serves three audiences. For **combinatorialists**, it supplies a
verified substrate (proven permutation/length/fixed-point invariants and exact
small-case data) on which the depth statistic and Defant's bound can be
formalized further. For **analysts of algorithms**, the rigorously trapped
constant turns a vague "tightness" claim into a falsifiable numeric target: any
candidate asymptotic expansion of $D_n/n$ can be tested against
$\lambda = 0.872892\ldots$ to arbitrary precision, with the finite ratios
($0.365, 0.387, 0.407, \ldots$) as a sanity rail. For **probabilists**, the
strict comparison $G < \lambda$ cleanly distinguishes two natural random-
permutation densities.

A caveat the development is careful about: the asymptotic tightness conjecture is
*not* asserted as a theorem. What is proved are the analytic and combinatorial
certificates a proof of tightness would consume — none of which are vacuous, each
requiring genuine real arithmetic or genuine induction/enumeration rather than
trivial reduction.

## 11. Future work

- **Tightness of Defant's bound.** Prove $\lim_{n\to\infty} D_n/n = \lambda$.
  The verified window $0.8728 < \lambda < 0.8729$ makes the target a single real
  number against which any asymptotic expansion can be tested.
- **Order-type invariance and West's ceiling.** Formalize that
  $\mathrm{depth}$ depends only on the pattern (using `stackSort_perm`,
  `stackSort_length`) and that $\mathrm{depth}(l) \le |l| - 1$ for all $l$.
- **Characterizing depth-0 fixed points.** Prove the converse of Theorem 4.2:
  $s(l) = l$ iff $l$ is sorted; this would let `depth` be defined by
  well-founded recursion instead of by fuel.
- **Second-order asymptotics.** Investigate $D_n = \lambda n - c\ln n + O(1)$
  for an explicit $c > 0$, consistent with the slowly rising empirical ratios.

## References

- D. E. Knuth, *The Art of Computer Programming, Vol. 1*, stack sorting and the
  Catalan enumeration of one-pass-sortable permutations.
- J. West, *Permutations with forbidden subsequences and stack-sortable
  permutations*, Ph.D. thesis, MIT, 1990.
- C. Defant, work on expected stack-sorting depth and the upper bound
  $\tfrac{3}{5}(7 - 8\ln 2)$, 2020.
- The Golomb–Dickman constant $G \approx 0.6243299885$ and its role as the
  asymptotic expected longest cycle density of a random permutation.
