# Verified Binary Search as Threshold Finding, with a Bridge to the Factorial Number System

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Formal Verification of Algorithms)

## Abstract

We present a complete, machine-checked treatment of binary search formulated as
*threshold finding* over a Boolean predicate, together with a formally verified
development of the factorial number system (the *factoradic*) and a bridge result
that connects the two. The central insight is methodological: by casting binary
search as the search for the point where a Boolean predicate $p$ flips from
*false* to *true*, full functional correctness reduces to a single loop invariant
($p(\text{lo}) = \text{false}$, $p(\text{hi}) = \text{true}$) that is preserved by
construction and requires *no monotonicity assumption whatsoever*. Monotonicity
re-enters only as an optional corollary that identifies the threshold as the first
index meeting a target in a sorted array. We establish a *tight* worst-case
complexity bound of $\lceil \log_2(\text{hi} - \text{lo}) \rceil$ comparisons —
the ceiling logarithm `Nat.clog 2`, not the floor logarithm — and explain why the
ceiling logarithm is forced: its defining recurrence
$\lceil \log_2 g \rceil = \lceil \log_2 \lceil g/2 \rceil \rceil + 1$ mirrors the
algorithm's recursion exactly, and the bound is attained (e.g. at gap $3$).
Independently, we verify the factorial number system: validity-bounded digit
tuples of length $k$ inject into and surject onto $\{0, \dots, k!-1\}$, with a
direct, non-circular uniqueness proof via mixed-radix splitting identities.
Finally, the bridge theorem `factoradic_search` composes these results: binary
search over the factoradic index space $[0, k!)$ is well-posed (the digit map is a
genuine bijection onto a size-$k!$ range) and costs at most $\lceil \log_2 k!
\rceil$ comparisons. The combinatorial complexity bound and the number-theoretic
density/injectivity facts are logically independent and meet only at the index
space's cardinality.

## 1. Introduction

Binary search is among the oldest and most widely deployed algorithms, yet it is
notorious for the difficulty of implementing it correctly: the first
fully-correct published version postdates the idea by sixteen years, and informal
surveys repeatedly find that a large majority of professional programmers
introduce boundary errors when writing it from scratch. The difficulty is almost
entirely concentrated in the *interface* between the search logic and the data
representation — the off-by-one questions of inclusive versus exclusive bounds,
the handling of the empty interval, and the precise meaning of the returned index.

Our thesis is that these difficulties dissolve under the right abstraction. We
separate two ideas that the conventional "search a sorted array" framing
conflates:

1. **The search itself**, which locates the boundary of a Boolean predicate.
2. **The sortedness assumption**, which is needed only to interpret that boundary
   as the first array index meeting a target.

Under this separation, correctness becomes a statement about a *loop invariant*
that holds for arbitrary predicates, while monotonicity is relegated to an
optional corollary. We pair this with a complexity analysis that pins the exact
worst case, and we connect the resulting verified search to a verified
positional number system — the factoradic — to demonstrate that the complexity
bound is reusable across mathematically distinct domains.

All results described below have been formalized and machine-checked. This paper
states each theorem inline with its full mathematical content and a proof sketch;
no external references are required to follow the development.

## 2. Binary search as threshold finding

### 2.1 The algorithm

Let $p : \mathbb{N} \to \{\text{false}, \text{true}\}$ be a Boolean predicate. We
define binary search over the open interval $(\text{lo}, \text{hi})$ recursively:

$$
\text{bsearch}(p, \text{lo}, \text{hi}) =
\begin{cases}
\text{bsearch}(p, \text{lo}, \text{mid}) & \text{if } \text{lo}+1 < \text{hi} \text{ and } p(\text{mid}) = \text{true},\\
\text{bsearch}(p, \text{mid}, \text{hi}) & \text{if } \text{lo}+1 < \text{hi} \text{ and } p(\text{mid}) = \text{false},\\
\text{hi} & \text{otherwise},
\end{cases}
$$

where $\text{mid} = \lfloor (\text{lo} + \text{hi})/2 \rfloor$. The recursion
terminates because the measure $\text{hi} - \text{lo}$ strictly decreases in both
recursive branches (when $\text{lo} + 1 < \text{hi}$, the midpoint satisfies
$\text{lo} < \text{mid} < \text{hi}$).

We define a parallel **step counter** with the identical control structure:

$$
\text{bsearchSteps}(p, \text{lo}, \text{hi}) =
\begin{cases}
1 + \text{bsearchSteps}(p, \text{lo}, \text{mid}) & \text{if } \text{lo}+1 < \text{hi},\ p(\text{mid}) = \text{true},\\
1 + \text{bsearchSteps}(p, \text{mid}, \text{hi}) & \text{if } \text{lo}+1 < \text{hi},\ p(\text{mid}) = \text{false},\\
0 & \text{otherwise}.
\end{cases}
$$

This counts the number of recursive iterations (equivalently, predicate
evaluations at midpoints) performed.

### 2.2 Functional correctness

**Theorem (`bsearch_spec`).** *Let $\text{lo} < \text{hi}$ with $p(\text{lo}) =
\text{false}$ and $p(\text{hi}) = \text{true}$. Then the returned index $r =
\text{bsearch}(p, \text{lo}, \text{hi})$ satisfies*

$$\text{lo} < r \le \text{hi}, \qquad p(r) = \text{true}, \qquad p(r-1) = \text{false}.$$

*No monotonicity of $p$ is assumed.*

*Proof sketch.* Strong induction on the gap $n = \text{hi} - \text{lo}$. Unfold
one step of the recursion and split on the two structural conditions.

- **Base case** ($\text{lo} + 1 \ge \text{hi}$, i.e. $\text{hi} = \text{lo} + 1$
  since $\text{lo} < \text{hi}$): the function returns $\text{hi}$. Then
  $\text{lo} < \text{hi} \le \text{hi}$ trivially, $p(\text{hi}) = \text{true}$ by
  hypothesis, and $p(\text{hi} - 1) = p(\text{lo}) = \text{false}$ by hypothesis.
  The truncated subtraction $r - 1$ is safe precisely because the invariant
  guarantees $\text{lo} < r$, so $r \ge 1$.
- **Recursive cases** ($\text{lo} + 1 < \text{hi}$): the midpoint satisfies
  $\text{lo} < \text{mid} < \text{hi}$. If $p(\text{mid}) = \text{true}$, the pair
  $(\text{lo}, \text{mid})$ again satisfies the invariant ($p(\text{lo}) =
  \text{false}$, $p(\text{mid}) = \text{true}$) with strictly smaller gap, so the
  induction hypothesis applies and transports the conclusion. Symmetrically, if
  $p(\text{mid}) = \text{false}$, the pair $(\text{mid}, \text{hi})$ satisfies the
  invariant with a smaller gap. In both branches, the invariant
  "$p$ is false at the left anchor and true at the right anchor" is preserved *by
  construction*, which is the heart of the argument. $\square$

The key conceptual content is that the invariant $\{p(\text{lo}) = \text{false},\,
p(\text{hi}) = \text{true}\}$ is the *only* precondition correctness needs.
Sortedness, comparison semantics, and array layout play no role.

### 2.3 Tight complexity: why ceiling logarithm

Define the ceiling base-2 logarithm $\text{clog}_2 : \mathbb{N} \to \mathbb{N}$ as
the least $m$ with $g \le 2^m$, equivalently characterized by the recurrence

$$\text{clog}_2(g) = \text{clog}_2(\lceil g/2 \rceil) + 1 \quad (g > 1), \qquad \text{clog}_2(g) = 0 \quad (g \le 1).$$

**Theorem (`bsearch_steps_le`).** *For all $p$, $\text{lo}$, $\text{hi}$,*

$$\text{bsearchSteps}(p, \text{lo}, \text{hi}) \le \text{clog}_2(\text{hi} - \text{lo}).$$

*Proof sketch.* Strong induction on $g = \text{hi} - \text{lo}$. If
$\text{lo} + 1 \ge \text{hi}$ then $g \le 1$ and $\text{bsearchSteps} = 0 \le
\text{clog}_2(g)$. Otherwise $g > 1$ and the algorithm takes one step plus a
recursive call on a subinterval. In either branch the new gap is at most
$\lceil g/2 \rceil$: the left branch $(\text{lo}, \text{mid})$ has gap
$\text{mid} - \text{lo} = \lfloor (\text{hi}-\text{lo})/2 \rfloor \le \lceil g/2
\rceil$, and the right branch $(\text{mid}, \text{hi})$ has gap
$\text{hi} - \text{mid} = \lceil (\text{hi}-\text{lo})/2 \rceil = \lceil g/2
\rceil$. By the induction hypothesis the recursive call costs at most
$\text{clog}_2(\lceil g/2 \rceil)$, so the total is at most
$1 + \text{clog}_2(\lceil g/2 \rceil) = \text{clog}_2(g)$ by the defining
recurrence. $\square$

**Remark (tightness and the floor-logarithm trap).** The bound is attained. For
the interval $(\text{lo}, \text{hi}) = (0, 3)$, an adversarial predicate forces
$\text{bsearchSteps} = 2$, while $\text{clog}_2(3) = 2$; so equality holds. By
contrast, the floor logarithm gives $\lfloor \log_2 3 \rfloor = 1$, which *fails*
as an upper bound. The naive patch "$\lfloor \log_2 g \rfloor + 1$" also fails as
an inductive invariant: the "$+1$" slack is consumed by the ceiling in the
$\lceil g/2 \rceil$ (right) branch — concretely $\lfloor \log_2 \lceil 3/2 \rceil
\rfloor = \lfloor \log_2 2 \rfloor = 1 > 0 = \lfloor \log_2 (3/2) \rfloor$ —
breaking the inductive step. The ceiling logarithm is the *correct* invariant
because its recurrence is isomorphic to the algorithm's: each iteration peels off
exactly one "$+1$" and replaces $g$ by $\lceil g/2 \rceil$.

### 2.4 The sorted-array corollary

Monotonicity is needed only to interpret the abstract threshold concretely.

**Corollary (`bsearch_sorted`).** *Let $a : \mathbb{N} \to \mathbb{Z}$ be
(weakly) monotone on the relevant range and let $t$ be a target. Define $p(i) :=
(a(i) \ge t)$, and suppose the anchors satisfy $a(\text{lo}) < t \le a(\text{hi})$
(so $p(\text{lo}) = \text{false}$, $p(\text{hi}) = \text{true}$). Then
$r = \text{bsearch}(p, \text{lo}, \text{hi})$ is the first index in
$(\text{lo}, \text{hi}]$ with $a(r) \ge t$; that is, $a(r) \ge t$ and
$a(j) < t$ for all $\text{lo} \le j < r$.*

*Proof sketch.* By `bsearch_spec`, $p(r) = \text{true}$ (so $a(r) \ge t$) and
$p(r-1) = \text{false}$ (so $a(r-1) < t$). Monotonicity upgrades the single
neighbor fact $a(r-1) < t$ to the universal statement $a(j) < t$ for all
$\text{lo} \le j < r$: since $a$ is increasing, $j \le r - 1$ implies
$a(j) \le a(r-1) < t$. Here the `Monotone` hypothesis is load-bearing — it is
precisely what converts the local boundary into a global "first index" claim.
$\square$

## 3. The factorial number system

We now develop the factoradic independently of any search content.

### 3.1 Values and validity

For a digit function $c : \mathbb{N} \to \mathbb{N}$ and a length $k$, define the
**length-$k$ factoradic value**

$$\text{value}(c, k) = \sum_{i < k} c(i) \cdot i!.$$

A digit function is **valid up to $k$**, written $\text{Valid}(c, k)$, if
$c(i) \le i$ for all $i < k$. Two immediate facts: $\text{value}(c, 0) = 0$, and
the peeling recurrence

$$\text{value}(c, k+1) = \text{value}(c, k) + c(k)\cdot k!. \tag{$\ast$}$$

### 3.2 The digit-bound estimate

**Lemma (`value_lt`).** *If $\text{Valid}(c, k)$ then $\text{value}(c, k) < k!$.*

*Proof sketch.* Induction on $k$. The base case is $0 < 0! = 1$. For the step,
by ($\ast$) and the induction hypothesis $\text{value}(c, k) < k!$, together with
the validity bound $c(k) \le k$,
$$\text{value}(c, k+1) = \text{value}(c, k) + c(k)\cdot k! < k! + k\cdot k! = (k+1)\cdot k! = (k+1)!. \qquad \square$$

This inequality — valid length-$k$ values never reach $k!$ — is the structural
engine of the whole system; everything else follows from it.

### 3.3 Mixed-radix splitting

**Lemma (`splitting_div`).** *If $\text{Valid}(c, k+1)$ then
$\lfloor \text{value}(c, k+1) / k! \rfloor = c(k)$.*

**Lemma (`splitting_mod`).** *If $\text{Valid}(c, k+1)$ then
$\text{value}(c, k+1) \bmod k! = \text{value}(c, k)$.*

*Proof sketch.* Write ($\ast$): $\text{value}(c, k+1) = \text{value}(c, k) +
c(k)\cdot k!$ with $\text{value}(c, k) < k!$ by `value_lt` applied to the
restriction of $c$ to length $k$. Division and remainder by $k!$ then separate
the two summands: the quotient is $c(k)$ (the low part contributes nothing since
it is below $k!$), and the remainder is $\text{value}(c, k)$. $\square$

### 3.4 Uniqueness (direct and non-circular)

**Theorem (`value_unique`).** *If $\text{Valid}(c, k)$, $\text{Valid}(d, k)$, and
$\text{value}(c, k) = \text{value}(d, k)$, then $c(i) = d(i)$ for all $i < k$.*

*Proof sketch.* Induction on $k$. The base case is vacuous. For $k+1$, apply
`splitting_div` to both sides to obtain $c(k) = d(k)$ (the top digits agree), and
`splitting_mod` to obtain $\text{value}(c, k) = \text{value}(d, k)$ (the tails
agree as values). The induction hypothesis applied to the tails gives
$c(i) = d(i)$ for all $i < k$; combined with $c(k) = d(k)$, this covers all
$i < k+1$. $\square$

We emphasize that this proof is **direct**: it uses only the digit-bound estimate
and the splitting identities. It does *not* route through surjectivity,
cardinality counting, an explicit bijection, or any enumeration theorem. The
existence results below come afterward and may depend on uniqueness, but
uniqueness never depends on them — eliminating any circularity.

### 3.5 Explicit digit extraction and existence

Define the explicit **digit extractor**

$$\text{digit}(n, i) = \left\lfloor \frac{n}{i!} \right\rfloor \bmod (i + 1).$$

**Lemma (`digit_valid`).** *For all $n$ and $k$, $\text{Valid}(\text{digit}(n,
\cdot), k)$.* Indeed $\text{digit}(n, i) = (\lfloor n / i! \rfloor) \bmod (i+1)
\le i$ by the modulus bound.

**Theorem (`value_digit`).** *If $n < k!$ then $\text{value}(\text{digit}(n,
\cdot), k) = n$.*

*Proof sketch.* The general identity, for every $k$,
$$n = \sum_{i < k} \big(\lfloor n/i!\rfloor \bmod (i+1)\big)\cdot i! \; + \; \lfloor n/k! \rfloor \cdot k!,$$
is proved by induction on $k$ using the division/remainder decomposition
$\lfloor n/k!\rfloor = (i+1)\lfloor n/(k+1)! \rfloor + (\lfloor n/k!\rfloor \bmod
(k+1))$ rearranged via the nested-division identity $n/((k+1)\cdot k!) =
(n/k!)/(k+1)$. When $n < k!$ the trailing term $\lfloor n/k! \rfloor \cdot k!$
vanishes, leaving $n = \text{value}(\text{digit}(n, \cdot), k)$. $\square$

Together, `value_unique`, `digit_valid`, and `value_digit` establish that the
digit map is a **bijection** between $\{0, 1, \dots, k! - 1\}$ and the valid
length-$k$ digit tuples.

## 4. The bridge: searching the factoradic index space

We now compose the search and number-theoretic developments.

**Theorem (`factoradic_search`).** *For every length $k$ and every Boolean
predicate $p$, the following three statements hold:*

1. *(Density / surjectivity.) For every $n < k!$,
   $\text{value}(\text{digit}(n, \cdot), k) = n$.*
2. *(Well-posedness / injectivity of search keys.) For all $m, n < k!$, if
   $\text{digit}(m, i) = \text{digit}(n, i)$ for every $i < k$, then $m = n$.*
3. *(Complexity.) $\text{bsearchSteps}(p, 0, k!) \le \text{clog}_2(k!)$.*

*Proof sketch.*
Part (1) is exactly `value_digit`.
For part (2), digit agreement on $[0, k)$ forces value agreement,
$\text{value}(\text{digit}(m, \cdot), k) = \text{value}(\text{digit}(n, \cdot),
k)$, because the value is a $\text{range}\,k$ sum of the digits times factorials;
applying `value_digit` to both sides (using $m, n < k!$) collapses this to
$m = n$. Note this step genuinely *uses* surjectivity (1): it is what converts
value-equality into index-equality, and the implication would not follow from
digit-agreement alone for arbitrary $n \ge k!$.
Part (3) is `bsearch_steps_le` instantiated at $\text{lo} = 0$, $\text{hi} = k!$,
where $\text{hi} - \text{lo} = k! - 0 = k!$. $\square$

**Non-circularity of the bridge.** The combinatorial bound
`bsearch_steps_le` contains no factoradic content, and the factoradic lemmas
contain no search content; the two compose only at the level of the index space's
cardinality, $k!$. The bridge therefore demonstrates genuine modularity: a
reusable complexity result and a reusable density/injectivity result meet at a
single shared quantity.

## 5. Algorithms

### 5.1 Threshold binary search

The verified algorithm of Section 2.1 translates directly into an iterative loop.
Given anchors $\text{lo} < \text{hi}$ with $p(\text{lo}) = \text{false}$ and
$p(\text{hi}) = \text{true}$, repeatedly bisect, maintaining the invariant
$p(\text{lo}) = \text{false} \wedge p(\text{hi}) = \text{true}$, until
$\text{hi} = \text{lo} + 1$; return $\text{hi}$. Worst-case predicate evaluations:
$\lceil \log_2(\text{hi} - \text{lo}) \rceil$.

### 5.2 Factoradic encode / decode

Encoding $n \mapsto (\text{digit}(n, 0), \dots, \text{digit}(n, k-1))$ via
$\text{digit}(n, i) = \lfloor n/i! \rfloor \bmod (i+1)$, and decoding
$(c_0, \dots, c_{k-1}) \mapsto \sum_i c_i \cdot i!$, are mutually inverse for
$n < k!$ and valid tuples. This realizes the bijection underlying permutation
ranking/unranking, in $O(k)$ arithmetic operations each.

## 6. Applications

- **Robust library search routines.** The threshold formulation gives a single
  correct primitive — locate the boundary of a monotone predicate — from which
  lower-bound, upper-bound, membership, and first/last-occurrence queries follow
  as instantiations of $p$, with a tight logarithmic worst-case guarantee.
- **Predicate search beyond arrays.** Because correctness needs no array and no
  sortedness, the same routine solves "smallest $x$ with property $P$" problems:
  integer square root, the smallest capacity feasible for a scheduling
  constraint, and other parametric-search tasks.
- **Permutation enumeration.** The verified factoradic bijection underwrites
  ranking and unranking of permutations, used in combinatorial generation and in
  compactly indexing the $k!$ orderings of $k$ objects.
- **Searching positional codes.** The bridge shows that searching a value space
  defined by a positional number system inherits the clean logarithmic cost,
  independent of the system's radices.

## 7. Discussion

The recurring theme is *separation of concerns*. Binary search becomes tractable
to verify once the threshold-finding core is divorced from the sortedness
assumption; the complexity analysis becomes exact once the correct logarithm
(ceiling, not floor) is identified by matching the algorithm's recurrence; and the
factoradic uniqueness proof becomes non-circular once it is derived directly from
the digit-bound estimate rather than from cardinality. The bridge then composes
these independently-verified pieces, and the very fact that they *can* be composed
so cleanly — sharing only the cardinality $k!$ — is evidence that the
abstractions were drawn along the right seams.

The ceiling-logarithm subtlety deserves emphasis. It is a small but instructive
example of a statement that is "true but needs a different definition": the
natural conjecture ("at most $\lfloor \log_2 g \rfloor + 1$ steps") is *true as a
loose bound* yet *false as an inductive invariant*, and only the ceiling
logarithm yields both a provable induction and a tight bound.

## 8. Future work

Several natural extensions follow directly from the verified core.

- **Matching lower bound for search.** Prove that for every $m \ge 1$ there exist
  $\text{lo} < \text{hi}$ and a predicate $p$ with $\text{bsearchSteps}(p,
  \text{lo}, \text{hi}) = \text{clog}_2(\text{hi} - \text{lo}) = m$, and that the
  bound is tight on *every* gap $g$ with $2^{m-1} < g \le 2^m$. This upgrades the
  upper bound into an exact $\Theta(\log)$ complexity theorem.
- **A field-generic Fourier inversion / convolution theorem.** Cast the discrete
  Fourier transform as a ring isomorphism carrying pointwise product to cyclic
  convolution, uniformly over $\mathbb{C}$ and $\mathbb{Z}/p\mathbb{Z}$ (number-
  theoretic transform), yielding a verified $O(n \log n)$ convolution kernel.
- **Refining a fast FFT against the DFT specification.** Prove that the recursive
  radix-2 FFT ($n = 2^k$) computes exactly the DFT, by induction on $k$ using only
  the splitting identity that $\omega^2$ is a primitive $(n/2)$-th root.
- **Uniform search cost across mixed-radix systems.** Generalize the factoradic
  bridge: for any mixed-radix system with radices $r_0, \dots, r_{k-1}$ (the
  factoradic being $r_i = i + 1$), binary search over $[0, \prod_i r_i)$ costs
  $\text{clog}_2(\prod_i r_i)$ comparisons, and the digit map is a bijection onto
  that range.

## 9. Conclusion

We have given a self-contained, verified account of binary search as threshold
finding, with full functional correctness from a single loop invariant (no
monotonicity required), a tight ceiling-logarithm complexity bound, and an
optional sorted-array corollary. Independently, we verified the factorial number
system with a direct uniqueness proof and an explicit digit bijection. The bridge
theorem `factoradic_search` then composes these into a precise statement about
searching the factoradic index space in $\lceil \log_2 k! \rceil$ comparisons,
demonstrating that a combinatorial complexity bound and a number-theoretic
structural fact can be made to interlock cleanly at a single shared quantity.
