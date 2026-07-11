# Graded Connectomes and the Combinatorics of Merged Minds: Exact Description-Length and Superadditivity Laws

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

We develop the exact combinatorics of encoding a neural connectome, extending the
Boolean present/absent model of synaptic topology in two directions: *graded*
(weighted) synapses and the *merging* of arbitrarily many minds. Modelling a
connectome on $N$ neurons by its $\binom{N}{2}$ potential undirected synapse
slots, we prove a clean logarithmic description-length law
$\log_2(w^{\text{slots}}) = \text{slots}\cdot\log_2 w$, showing that recording
synaptic *strength* on a $w$-level scale costs exactly $\log_2 w$ additional bits
per slot, a premium independent of the neuron count. We show this premium is
strictly positive precisely when $w \ge 3$ and at least one slot is present, and
that the Boolean model ($w = 2$) is recovered as the one-bit-per-slot special
case. Passing to directed synapses doubles the slot count, giving a directed
graded state space of exactly $w^{N(N-1)} = (w^{\text{slots}})^2$ configurations.
Finally, we prove a general superadditive merge law
$\text{slots}(\sum_i N_i) = \sum_i \text{slots}(N_i) + \sum_{i<j} N_i N_j$,
identifying the cross term $\sum_{i<j} N_i N_j$ as the exact count of new
inter-brain slots produced by fusion, and relate it to the square-of-a-sum
identity $(\sum_i N_i)^2 = \sum_i N_i^2 + 2\sum_{i<j} N_i N_j$. These results
cleanly separate the intrinsic and relational parts of a fused mind and make the
quadratic combinatorial explosion of cross-connections explicit.

## 1. Introduction

The information content of the brain is a recurring question at the intersection
of neuroscience, information theory, and speculative computing. A useful
first-order abstraction represents a brain as a *connectome*: a graph whose
vertices are neurons and whose edges are synapses. The number of *potential*
synapses — the slots into which connectivity information must be written — is the
central combinatorial quantity, and its base-2 logarithm is the description length
of the connectome in bits.

The elementary Boolean model treats each slot as a single bit (present or absent),
yielding $\binom{N}{2}$ bits for an undirected connectome on $N$ neurons. This
paper refines the model along the two axes that most obviously distinguish a real
brain from a bare graph:

1. **Grading.** A biological synapse carries a *strength*, not a mere presence
   flag. Modelling each slot as one of $w$ weight levels multiplies the state
   space and raises the question of the exact marginal bit cost of strength.
2. **Merging.** Fusing minds is not the disjoint union of graphs: it creates the
   possibility of new synapses spanning previously separate brains. The exact
   accounting of these cross-connections is a combinatorial identity of
   independent interest.

We state and prove the exact laws governing both, together with the directed
variant. All statements are identities or sharp inequalities, holding for all
parameter values in their stated ranges with no error terms.

## 2. Definitions

Throughout, $N, M, w, k$ range over the natural numbers.

**Definition 2.1 (Synapse slots).** The number of *undirected synapse slots* on a
connectome of $N$ neurons is the number of unordered pairs of distinct neurons,
$$\text{slots}(N) = \binom{N}{2} = \frac{N(N-1)}{2}.$$

**Definition 2.2 (Directed slots).** The number of *directed synapse slots* is the
number of ordered pairs of distinct neurons,
$$\text{directedSlots}(N) = 2\binom{N}{2} = N(N-1).$$
Equivalently, $\text{directedSlots}(N) = 2\,\text{slots}(N)$.

**Definition 2.3 (Graded connectome).** For a weight alphabet of size $w$, a
*graded connectome* assigns to each of the $\text{slots}(N)$ slots one of $w$
values. The set of graded connectomes is therefore in bijection with functions
from a $\text{slots}(N)$-element set to a $w$-element set, of which there are
$w^{\text{slots}(N)}$.

**Definition 2.4 (Description length).** The *description length* (in bits) of a
finite configuration space of cardinality $C$ is $\log_2 C$.

**Definition 2.5 (Cross term).** For a finite list of neuron counts
$L = [N_1, \dots, N_k]$, the *cross term* is
$$\text{cross}(L) = \sum_{1 \le i < j \le k} N_i N_j,$$
defined by the recursion $\text{cross}([]) = 0$ and
$\text{cross}(x :: xs) = x\cdot(\textstyle\sum xs) + \text{cross}(xs)$, where
$\sum xs$ denotes the sum of the tail. In particular $\text{cross}([x]) = 0$.

## 3. The graded description-length law

Our first main result converts the multiplicative growth of the graded state
space into an additive law for its description length.

**Theorem 3.1 (Graded description-length law).** For all $N$ and all $w \ge 1$,
$$\log_2\!\left(w^{\text{slots}(N)}\right) = \text{slots}(N)\cdot\log_2 w.$$

*Proof.* The base-2 logarithm of a power satisfies $\log_2(a^n) = n\log_2 a$ for a
nonnegative real base $a$ and a natural exponent $n$. Applying this with
$a = w$ and $n = \text{slots}(N)$ gives the claim immediately. $\qquad\blacksquare$

**Interpretation.** The cost of naming a graded connectome is $\log_2 w$ bits per
slot. Because the number of slots depends only on the topology (the neuron count)
and the per-slot cost depends only on the weight resolution, the description
length is *bilinear* in these two quantities: topology sets the number of slots,
grading sets the price of each. Storing synaptic strength rather than mere
topology costs an additive premium of exactly $\log_2 w$ bits per potential
synapse, independent of $N$.

**Theorem 3.2 (Boolean specialisation).** For all $N$,
$$\log_2\!\left(2^{\text{slots}(N)}\right) = \text{slots}(N).$$

*Proof.* By Theorem 3.1 the left side equals $\text{slots}(N)\cdot\log_2 2$, and
$\log_2 2 = 1$. $\qquad\blacksquare$

Thus the Boolean model is exactly the one-bit-per-slot case, recovering the
$\binom{N}{2}$-bit description length of pure topology.

**Theorem 3.3 (Strictness of the graded premium).** If $w \ge 3$ and
$\text{slots}(N) \ge 1$, then
$$\text{slots}(N) < \log_2\!\left(w^{\text{slots}(N)}\right).$$

*Proof.* By Theorem 3.1 the right side is $\text{slots}(N)\cdot\log_2 w$. Since
$w \ge 3 > 2$ and $\log_2$ is strictly increasing on the positive reals,
$\log_2 w > \log_2 2 = 1$. With $\text{slots}(N) \ge 1$, multiplying the strict
inequality $\log_2 w > 1$ by the positive quantity $\text{slots}(N)$ yields
$\text{slots}(N)\cdot\log_2 w > \text{slots}(N)$. $\qquad\blacksquare$

**Remark 3.4 (The boundary $w = 1$).** A single weight level carries no
information: $\log_2 1 = 0$, so the graded description length collapses to $0$
regardless of the number of slots. The premium over the topological cost is
therefore genuinely positive only when the alphabet is nontrivial ($w \ge 2$),
and strictly exceeds the Boolean cost only when it is richer than Boolean
($w \ge 3$).

## 4. Directed graded connectomes

Directionality distinguishes the ordered pair $(A, B)$ from $(B, A)$, doubling the
number of slots.

**Theorem 4.1 (Directed graded state count).** For all $N$ and $w$,
$$w^{\text{directedSlots}(N)} = \left(w^{\text{slots}(N)}\right)^2.$$

*Proof.* By Definition 2.2, $\text{directedSlots}(N) = 2\,\text{slots}(N)$. Hence
$w^{\text{directedSlots}(N)} = w^{2\,\text{slots}(N)} = (w^{\text{slots}(N)})^2$
by the power law $a^{mn} = (a^m)^n$. $\qquad\blacksquare$

**Corollary 4.2 (Cardinality of the directed graded state space).** The set of
functions from the $\text{directedSlots}(N)$ directed slots to a $w$-element
weight alphabet has cardinality exactly $(w^{\text{slots}(N)})^2 = w^{N(N-1)}$.

*Proof.* The number of functions from an $m$-element set to a $w$-element set is
$w^m$; take $m = \text{directedSlots}(N) = N(N-1)$ and apply Theorem 4.1.
$\qquad\blacksquare$

Thus topology, strength, and direction compose into the single closed form
$w^{N(N-1)}$ for the full directed graded state space, whose description length is
$N(N-1)\cdot\log_2 w$ bits.

## 5. Merging a hierarchy of minds

We now turn to fusion. The base case is the two-brain merge law.

**Lemma 5.1 (Two-brain merge law).** For all $M, N$,
$$\text{slots}(M + N) = \text{slots}(M) + \text{slots}(N) + M\cdot N.$$

*Proof.* Expanding the binomial coefficient,
$$\binom{M+N}{2} = \frac{(M+N)(M+N-1)}{2} = \frac{M(M-1)}{2} + \frac{N(N-1)}{2} + MN = \binom{M}{2} + \binom{N}{2} + MN,$$
where the middle step regroups $(M+N)(M+N-1) = M(M-1) + N(N-1) + 2MN$.
$\qquad\blacksquare$

The three terms have transparent meaning: $\text{slots}(M)$ and $\text{slots}(N)$
are the *intrinsic* slots each brain already possessed, while $M\cdot N$ is the
*relational* interface — the new slots pairing a neuron of the first brain with a
neuron of the second.

**Theorem 5.2 (Square-of-a-sum identity).** For any finite list of neuron counts
$L = [N_1, \dots, N_k]$,
$$\left(\sum_{i} N_i\right)^2 = \sum_i N_i^2 + 2\,\text{cross}(L).$$

*Proof.* By induction on the list. For the empty list both sides are $0$. For
$L = x :: xs$, write $S = \sum xs$. Then
$$\left(x + S\right)^2 = x^2 + 2xS + S^2 = x^2 + 2xS + \Big(\sum_{i} N_i^2\big|_{xs} + 2\,\text{cross}(xs)\Big)$$
by the induction hypothesis applied to $xs$. Regrouping,
$$= \Big(x^2 + \sum_{i} N_i^2\big|_{xs}\Big) + 2\big(xS + \text{cross}(xs)\big) = \sum_i N_i^2\big|_{L} + 2\,\text{cross}(L),$$
using $\text{cross}(x :: xs) = xS + \text{cross}(xs)$ from Definition 2.5.
$\qquad\blacksquare$

This ties the cross term to the off-diagonal part of the square of the total
neuron count: $\text{cross}(L)$ is exactly half of $(\sum N_i)^2 - \sum N_i^2$.

**Theorem 5.3 (General mind-merge law).** For any finite list of neuron counts
$L = [N_1, \dots, N_k]$,
$$\text{slots}\!\left(\sum_i N_i\right) = \sum_i \text{slots}(N_i) + \text{cross}(L) = \sum_i \binom{N_i}{2} + \sum_{i<j} N_i N_j.$$

*Proof.* By induction on $L$, using Lemma 5.1 at each step. The empty list gives
$\text{slots}(0) = 0 = 0 + 0$. For $L = x :: xs$ with $S = \sum xs$,
$$\text{slots}(x + S) = \text{slots}(x) + \text{slots}(S) + xS$$
by Lemma 5.1. Applying the induction hypothesis to $xs$ gives
$\text{slots}(S) = \sum_{i}\text{slots}(N_i)\big|_{xs} + \text{cross}(xs)$, so
$$\text{slots}(x + S) = \Big(\text{slots}(x) + \sum_i \text{slots}(N_i)\big|_{xs}\Big) + \big(xS + \text{cross}(xs)\big) = \sum_i \text{slots}(N_i)\big|_L + \text{cross}(L),$$
again by the defining recursion for $\text{cross}$. $\qquad\blacksquare$

**Corollary 5.4 (Superadditivity).** For any finite list $L$,
$$\text{slots}\!\left(\sum_i N_i\right) \ge \sum_i \text{slots}(N_i),$$
with equality iff at most one $N_i$ is nonzero.

*Proof.* Theorem 5.3 gives the difference of the two sides as $\text{cross}(L) =
\sum_{i<j} N_i N_j \ge 0$, a sum of products of natural numbers. The sum is zero
iff no two distinct indices both have $N_i, N_j > 0$, i.e. iff at most one $N_i$ is
nonzero. $\qquad\blacksquare$

Merging therefore never destroys slots, and it strictly creates them whenever two
or more of the merged brains are nonempty.

## 6. The combinatorial explosion of fusion

Theorem 5.3 cleanly separates a fused mind's slots into an *intrinsic* part
$\sum_i \text{slots}(N_i)$ and a *relational* part $\text{cross}(L)$. Their
relative growth is the quantitative heart of the merging phenomenon.

**Proposition 6.1 (Asymptotic dominance of the interface).** Fuse $k$ brains each
of size $n \ge 1$. The intrinsic slots total $k\binom{n}{2} = \frac{kn(n-1)}{2}$
and the cross term is $\binom{k}{2}n^2 = \frac{k(k-1)}{2}n^2$. The fraction of
total slots that are relational is
$$\rho(k, n) = \frac{\binom{k}{2}n^2}{k\binom{n}{2} + \binom{k}{2}n^2} = \frac{(k-1)n}{(n-1) + (k-1)n},$$
which for fixed $n$ tends to $1$ as $k \to \infty$, and more precisely
$\rho(k,n) \to 1 - \frac{1}{k}\cdot\frac{n}{\,(n-1)/k + n\,} \approx 1 - \frac1k$
for large $n$.

*Proof.* Substitute the two closed forms from Theorem 5.3 (with all $N_i = n$) and
simplify; the intrinsic part grows linearly in $k$ while the relational part grows
quadratically, so the ratio tends to $1$. $\qquad\blacksquare$

A large collective of equal minds is thus asymptotically *all interface*: the
overwhelming majority of its potential synapses bridge two distinct individuals
rather than lying inside any one of them.

## 7. Algorithms

The results are directly computable. We record three procedures used in the
accompanying numerical demonstrations.

**Algorithm 7.1 (Graded bit-length).** Given $N$ and $w$, compute
$\text{slots}(N) = N(N-1)/2$ by integer arithmetic and return
$\text{slots}(N)\cdot\log_2 w$. Exact when $w$ is a power of two; otherwise a
floating-point value. Complexity $O(1)$ arithmetic operations (plus the cost of
the logarithm).

**Algorithm 7.2 (Cross term and merge).** Given a list $[N_1, \dots, N_k]$,
compute the running suffix sums and accumulate
$\text{cross} = \sum_i N_i\cdot(\sum_{j>i} N_j)$ in a single left-to-right pass,
returning $\sum_i \binom{N_i}{2} + \text{cross}$ as the merged slot count.
Complexity $O(k)$.

**Algorithm 7.3 (Optimal weight resolution under a bit budget).** Given a neuron
count $N$ and a total bit budget $B$, the largest admissible weight alphabet is
$w^\* = \lfloor 2^{\,B/\text{slots}(N)} \rfloor$, the largest $w$ with
$\text{slots}(N)\log_2 w \le B$. Complexity $O(1)$.

## 8. Applications and discussion

The laws above give an exact ledger for the storage cost of a modelled mind. Three
consequences stand out.

- **Marginal cost of realism.** Upgrading from a topological to a graded model
  costs precisely $\log_2 w$ bits per slot, a figure that lets one price the
  fidelity of a connectome model directly against a storage budget.
- **Direction as squaring.** Accounting for synaptic direction squares the state
  space, an exact statement that quantifies the representational cost of
  asymmetry.
- **Fusion economics.** The merge law shows that the informational "value" of a
  merged collective, if measured by potential connectivity, is dominated by the
  relational cross term, which grows quadratically in the number of participants
  while the intrinsic content grows only linearly.

Combined with a physical information bound of Bekenstein type — a ceiling $B$ on
the number of bits any bounded region can hold — the bilinear description length
$\text{slots}(N)\log_2 w \le B$ carves out an explicit feasible region in the
$(N, \log_2 w)$ plane, along which neuron count and weight resolution trade off
(Algorithm 7.3).

## 9. Future work

Several directions extend the theory. A *graded incompressibility theorem* would
upgrade the exact counts to a statement that almost every graded connectome
requires nearly $\text{slots}\cdot\log_2 w$ bits under any injective encoding
(a Kraft–McMillan style argument, independent of the weight alphabet). An
*entropy-of-merging* analysis would make Proposition 6.1 exact, characterising the
$1 - 1/k$ limiting fraction of relational slots. An *optimal-quantisation* study
would establish the concavity of the Pareto frontier $\text{slots}(N)\log_2 w \le
B$ in $(N, \log_2 w)$. Finally, one may seek a *strict superadditivity with exact
defect*, quantifying precisely the capacity gained by fusing a partitioned brain.

## 10. Conclusion

We have given the exact combinatorics of graded and merged connectomes: a
bilinear description-length law with a strictly positive grading premium, a
squaring law for directionality, and a general superadditive merge identity whose
cross term is the off-diagonal square of the total neuron count. Every statement
is a sharp identity or inequality. Together they turn speculative questions about
the information content and fusion of minds into precise, provable arithmetic.
