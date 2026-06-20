# The Combinatorial and Probabilistic Structure of the Library of Babel

**Author:** Aristotle
**Date:** 2026-06-20

## Abstract

We give a complete, elementary, and fully rigorous account of the combinatorial
and probabilistic structure of Borges' *Library of Babel*, modeled as the finite
set of all length-$L$ strings over a $b$-symbol alphabet equipped with the
uniform probability measure. We prove that the library has cardinality $b^L$,
that each volume has probability $b^{-L}$, and that two independent uniform
volumes coincide with probability $b^{-L}$. Turning to substring occurrences, we
establish via a first-moment (linearity of expectation) argument that the
expected number of occurrences of a fixed length-$k$ pattern in a random
length-$L$ volume is exactly $(L-k+1)\,b^{-k}$, yielding a union upper bound
$\Pr[\text{contains}] \le (L-k+1)\,b^{-k}$. Because this bound is vacuous for
large $L$, we develop a complementary *disjoint-block* lower bound: partitioning
a volume into $\lfloor L/k\rfloor$ aligned, independent blocks of length $k$, we
count exactly the volumes avoiding the pattern on every block — there are
$(b^k-1)^{\lfloor L/k\rfloor}\, b^{\,L-\lfloor L/k\rfloor k}$ of them — and deduce
$\Pr[\text{contains}] \ge 1 - (1-b^{-k})^{\lfloor L/k\rfloor}$, a bound that is
non-vacuous for every $L$. As a corollary we obtain *Borges completeness*: for
$b \ge 2$ and any fixed finite pattern, the containment probability tends to $1$
as $L \to \infty$. Every result has been formalized and machine-verified with no
unproved assumptions.

**Keywords:** Library of Babel, uniform measure on words, substring occurrence,
first moment method, linearity of expectation, union bound, disjoint-block
independence, exponential avoidance decay, almost-sure containment.

---

## 1. Introduction

Borges' 1941 story *The Library of Babel* imagines a universe of books
containing every possible arrangement of a fixed alphabet across a fixed number
of pages. While the story is a literary meditation on totality and meaning, the
object it describes is a precise finite combinatorial structure: the set of all
strings of a given length over a finite alphabet. This paper carries out the
elementary but complete analysis of that structure as a probability space.

Two questions organize the development:

1. **Counting and uniform sampling.** How many volumes are there, and what is
   the probability of individual volumes and of coincidences?
2. **Substring occurrence.** Given a fixed target pattern, how many times does it
   appear in a random volume, and how likely is it to appear at all? How does
   that likelihood behave as the volumes grow?

The answer to (1) is the immediate $b^L$ and $b^{-L}$. The interesting content
lies in (2). A first-moment computation gives the exact expected occurrence
count and, through it, a one-sided union bound that is sharp for small $L$ but
*vacuous* for large $L$. The resolution is a disjoint-block independence argument
that produces a two-sided picture: an always-meaningful lower bound and, in the
limit, almost-sure containment of any fixed text. The latter is the rigorous
formalization of Borges' central conceit.

All statements below are theorems with fully checked formal proofs; we present
mathematical proof sketches rather than formal code.

---

## 2. Definitions

Throughout, $b$ (the alphabet size) and $L$ (the volume length) are natural
numbers, and we identify the alphabet with $\{0,\dots,b-1\}$ and positions with
$\{0,\dots,L-1\}$.

**Definition 2.1 (Volume).** A *volume* of length $L$ over a $b$-symbol alphabet
is a function $v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b$, i.e. an assignment of a
symbol to each position. We write $\mathrm{Volume}(b,L)$ for the type of such
functions.

**Definition 2.2 (Library).** The *library* $\mathrm{Library}(b,L)$ is the finite
set of all volumes of length $L$, i.e. the full (finite) universe of
$\mathrm{Volume}(b,L)$.

**Definition 2.3 (Uniform probability).** For a finite sample space $s$ (a finite
set of points) and an event $A$ (a set of points), the *uniform probability* is
the counting ratio
$$ \Pr_s(A) = \frac{\#\{ x \in s : x \in A\}}{\#\,s}. $$
Applied to $s = \mathrm{Library}(b,L)$ this is the uniform measure on all
volumes. We write $\Pr$ for $\Pr_{\mathrm{Library}(b,L)}$ when the space is clear.

**Definition 2.4 (Reading a symbol).** For a volume $v$ and an index $n \in
\mathbb{N}$, $\mathrm{readAt}(v,n)$ returns $v(n)$ if $n < L$ and $\bot$ (none)
otherwise. This total, bounds-checked reader makes occurrence statements clean at
the boundary.

**Definition 2.5 (Occurrence at a position).** For a pattern $p :
\mathrm{Fin}\,k \to \mathrm{Fin}\,b$, a volume $v$, and a start index $i$, we say
$p$ *occurs at* $i$ in $v$, written $\mathrm{OccursAt}(p,v,i)$, if
$$ \forall j \in \mathrm{Fin}\,k,\quad \mathrm{readAt}(v, i+j) = p(j). $$
That is, the $k$ consecutive symbols of $v$ from position $i$ match $p$ exactly
(and all lie in range).

**Definition 2.6 (Occurrence count).** The *occurrence count* of $p$ in $v$ is
the number of legal start positions at which $p$ occurs:
$$ \mathrm{occurrenceCount}(p,v) = \#\{\, i \in \{0,\dots,L-k\} : \mathrm{OccursAt}(p,v,i)\,\}, $$
where the start ranges over $\{0, \dots, L-k\}$, a set of size $L - k + 1$ (using
truncated subtraction, so this is $0$ when $k > L$).

**Definition 2.7 (Containment).** The volume $v$ *contains* the pattern $p$,
written $\mathrm{Contains}(p,v)$, if $\exists i,\ \mathrm{OccursAt}(p,v,i)$.

**Definition 2.8 (Expected occurrences).** The *expected occurrence count* is the
average of $\mathrm{occurrenceCount}(p,\cdot)$ over the library:
$$ \mathbb{E}[\mathrm{occ}] = \frac{1}{\#\,\mathrm{Library}(b,L)} \sum_{v} \mathrm{occurrenceCount}(p,v). $$

**Definition 2.9 (No aligned block match).** Fix $k \ge 1$. Partition positions
into the $\lfloor L/k\rfloor$ *aligned blocks* $[\,t k,\ tk+k)$ for
$t \in \{0,\dots,\lfloor L/k\rfloor - 1\}$. A volume $v$ has *no aligned block
match*, $\mathrm{NoAlignedBlockMatch}(p,v)$, if for every such $t$ the pattern
fails to occur at the block start $tk$:
$$ \forall t \in \mathrm{Fin}(\lfloor L/k\rfloor),\quad \neg\,\mathrm{OccursAt}(p, v, tk). $$

---

## 3. Counting the library and uniform sampling

**Theorem 3.1 (`card_library`).** $\#\,\mathrm{Library}(b,L) = b^L$.

*Proof sketch.* A volume is a function $\mathrm{Fin}\,L \to \mathrm{Fin}\,b$; the
number of functions from an $L$-element set to a $b$-element set is $b^L$. $\square$

**Theorem 3.2 (`prob_singleton`).** For every volume $v$,
$$ \Pr(\{v\}) = b^{-L}. $$

*Proof sketch.* The event $\{v\}$ contains exactly one point of the library, so
its count is $1$; dividing by $\#\,\mathrm{Library}(b,L) = b^L$ gives $1/b^L =
b^{-L}$ (interpreting the integer power $b^{-L}$ over the reals). $\square$

**Theorem 3.3 (`prob_pair_coincide`).** Sampling a pair of volumes uniformly and
independently from $\mathrm{Library}(b,L) \times \mathrm{Library}(b,L)$,
$$ \Pr\big[\,v_1 = v_2\,\big] = b^{-L}. $$

*Proof sketch.* The product space has $\,(b^L)^2 = b^{2L}$ points. The diagonal
$\{(v,v)\}$ is the image of the library under the injection $v \mapsto (v,v)$, so
it has exactly $b^L$ points. The ratio $b^L / b^{2L} = b^{-L}$. All edge cases
($L=0$, $b=0$) are handled directly. $\square$

**Theorem 3.4 (`prob_le_one`).** For any finite sample space $s$ and event $A$,
$\Pr_s(A) \le 1$.

*Proof sketch.* The filtered count $\#\{x \in s : x \in A\}$ is at most $\#\,s$,
so their ratio is at most $1$ (with the usual convention for $\#\,s = 0$). $\square$

---

## 4. The first moment: expected substring occurrences

The technical core of the counting is the following exact count of volumes that
agree with a fixed pattern along a fixed family of positions.

**Lemma 4.1 (`card_filter_agree`).** Let $\alpha,\beta$ be finite types, $p$ a
decidable predicate on $\alpha$, and $g : \alpha \to \beta$ a fixed function. The
number of functions $v : \alpha \to \beta$ that agree with $g$ on every point
satisfying $p$ is
$$ \#\{ v : \forall a,\ p(a) \Rightarrow v(a) = g(a)\} = (\#\beta)^{\,\#\{a : \neg p(a)\}}. $$

*Proof sketch.* The constrained set is the dependent product (`piFinset`)
$\prod_{a}\big(\,\{g(a)\}$ if $p(a)$, else all of $\beta\,\big)$. Its cardinality
is the product of the factor sizes: $1$ at each constrained point and $\#\beta$ at
each free point, giving $(\#\beta)^{\#\{a : \neg p(a)\}}$. $\square$

**Lemma 4.2 (`card_agree_inj`).** Let $\varphi : \mathrm{Fin}\,k \to
\mathrm{Fin}\,L$ be injective and $p$ a pattern. The number of volumes agreeing
with $p$ along $\varphi$ is
$$ \#\{ v : \forall j,\ v(\varphi(j)) = p(j)\} = b^{\,L-k}. $$

*Proof sketch.* Apply Lemma 4.1 with predicate "is in the range of $\varphi$".
Injectivity gives exactly $k$ constrained positions, hence $L-k$ free positions,
so the count is $b^{L-k}$. The degenerate case $b=0$ is handled separately. $\square$

**Lemma 4.3 (`card_occursAt`).** For a valid start $i$ with $i + k \le L$,
$$ \#\{ v : \mathrm{OccursAt}(p,v,i)\} = b^{\,L-k}. $$

*Proof sketch.* Occurrence at $i$ constrains exactly the $k$ positions
$i, i+1, \dots, i+k-1$ to match $p$. The map $j \mapsto i+j$ is injective into
$\mathrm{Fin}\,L$ under $i+k \le L$, so Lemma 4.2 gives $b^{L-k}$. $\square$

**Theorem 4.4 (`expected_substring_count`).** For $k \le L$ and $b \ge 1$ and any
pattern $p$ of length $k$,
$$ \mathbb{E}[\mathrm{occ}] = (L - k + 1)\, b^{-k}. $$

*Proof sketch.* By linearity of expectation,
$$ \sum_{v} \mathrm{occurrenceCount}(p,v)
   = \sum_{v}\ \sum_{i=0}^{L-k} \mathbf{1}[\mathrm{OccursAt}(p,v,i)]
   = \sum_{i=0}^{L-k}\ \#\{v : \mathrm{OccursAt}(p,v,i)\}. $$
Each valid start $i \in \{0,\dots,L-k\}$ satisfies $i + k \le L$, so Lemma 4.3
gives $\#\{v : \mathrm{OccursAt}(p,v,i)\} = b^{L-k}$. There are $L-k+1$ such
starts, so the double sum equals $(L-k+1)\,b^{L-k}$. Dividing by
$\#\,\mathrm{Library}(b,L) = b^L$ and using $b^{L-k}/b^L = b^{-k}$ (valid since
$k \le L$ and $b \ge 1$) yields $(L-k+1)\,b^{-k}$. The hypothesis $b \ge 1$
ensures the library is nonempty so the average is well-defined. $\square$

**Theorem 4.5 (`prob_contains_substring_bound`, union upper bound).** For
$k \le L$,
$$ \Pr\big[\,\mathrm{Contains}(p,\cdot)\,\big] \le (L - k + 1)\, b^{-k}. $$

*Proof sketch.* Containment is the event $\{\mathrm{occurrenceCount} \ge 1\}$. By
Markov's inequality / the union bound, the probability of at least one occurrence
is at most the expected number of occurrences, which is $(L-k+1)b^{-k}$ by
Theorem 4.4. Equivalently, sum the per-window occurrence probabilities $b^{-k}$
over the $L-k+1$ windows. $\square$

**Remark 4.6 (vacuity).** For fixed $k$ and $b$, the right-hand side
$(L-k+1)b^{-k}$ grows linearly in $L$ and exceeds $1$ once $L > b^k + k - 1$.
Beyond that point Theorem 4.5 carries no information. This motivates §5.

---

## 5. The disjoint-block lower bound

The union bound fails for large $L$ precisely because the $L-k+1$ overlapping
windows are highly dependent. We recover control by passing to *disjoint* blocks,
which are genuinely independent.

**The reindexing.** Write $m = \lfloor L/k\rfloor$. Since $mk \le L$, a volume of
length $L$ decomposes canonically into $m$ blocks of length $k$ followed by a
remainder of $L - mk$ free symbols. Formally there is an equivalence
$$ \mathrm{blockEquiv} : \mathrm{Volume}(b,L) \ \simeq\
   \big(\mathrm{Fin}\,m \to \mathrm{Fin}\,k \to \mathrm{Fin}\,b\big)\ \times\
   \big(\mathrm{Fin}(L-mk) \to \mathrm{Fin}\,b\big), $$
sending a volume to (its $m$ block-contents, its remainder), with the block index
arithmetic given explicitly: block $t$, offset $j$, sits at position $tk + j$
(`blockEquiv_index`, `blockEquiv_fst_apply`).

**Lemma 5.1 (`noAligned_iff`).** For $k \ge 1$,
$$ \mathrm{NoAlignedBlockMatch}(p,v) \iff \forall t \in \mathrm{Fin}\,m,\
   \mathrm{blockEquiv}(v).1\,t \ne p. $$
That is, no aligned block matches the pattern iff every block-content under the
reindexing differs from $p$.

*Proof sketch.* The block at index $t$ starts at position $tk$, and occurrence at
$tk$ is, position-by-position via `blockEquiv_index`, exactly the statement that
the $t$-th block content equals $p$. Negating both sides gives the equivalence.
$\square$

**Lemma 5.2 (`card_avoid`).** The number of $m$-tuples of length-$k$ blocks none
equal to a fixed pattern is
$$ \#\{ g : \mathrm{Fin}\,m \to (\mathrm{Fin}\,k \to \mathrm{Fin}\,b) :
   \forall t,\ g(t) \ne p\} = (b^k - 1)^m. $$

*Proof sketch.* There are $b^k$ possible block contents; removing the single
value $p$ leaves $b^k - 1$ choices for each of the $m$ independent coordinates,
giving $(b^k-1)^m$ by the product rule (`Fintype.card_piFinset`). $\square$

**Theorem 5.3 (`card_noAlignedBlockMatch`).** For $k \ge 1$,
$$ \#\{ v : \mathrm{NoAlignedBlockMatch}(p,v)\} = (b^k - 1)^{\lfloor L/k\rfloor}\,
   b^{\,L - \lfloor L/k\rfloor\, k}. $$

*Proof sketch.* Transport the count through $\mathrm{blockEquiv}$. By Lemma 5.1
the no-match set corresponds to (block tuples avoiding $p$) $\times$ (arbitrary
remainder). By Lemma 5.2 the first factor has $(b^k-1)^m$ elements; the remainder
factor $\mathrm{Fin}(L-mk) \to \mathrm{Fin}\,b$ has $b^{L-mk}$ elements. Since
$\mathrm{blockEquiv}$ is a bijection, the product $(b^k-1)^m b^{L-mk}$ counts the
original set. $\square$

**Theorem 5.4 (`prob_avoids_substring_bound`, exponential avoidance decay).** For
$k \ge 1$,
$$ \Pr\big[\,\neg\,\mathrm{Contains}(p,\cdot)\,\big] \le
   \left(1 - b^{-k}\right)^{\lfloor L/k\rfloor}. $$

*Proof sketch.* If a volume contains the pattern nowhere, then in particular no
aligned block matches it, so
$\{\neg\mathrm{Contains}\} \subseteq \{\mathrm{NoAlignedBlockMatch}\}$ and
$\Pr[\neg\mathrm{Contains}] \le \#\{\mathrm{NoAlignedBlockMatch}\}/b^L$. By
Theorem 5.3 this equals
$(b^k-1)^m b^{L-mk}/b^L$. Writing $b^L = b^{mk} b^{L-mk}$ and
$(b^k-1)^m/b^{mk} = ((b^k-1)/b^k)^m = (1 - b^{-k})^m$ gives the bound. The case
$b = 0$ is vacuous because a nonempty pattern forces $b \ge 1$. $\square$

**Theorem 5.5 (`prob_contains_substring_lower_bound`).** For $k \ge 1$,
$$ \Pr\big[\,\mathrm{Contains}(p,\cdot)\,\big] \ge
   1 - \left(1 - b^{-k}\right)^{\lfloor L/k\rfloor}. $$

*Proof sketch.* Take complements in Theorem 5.4:
$\Pr[\mathrm{Contains}] = 1 - \Pr[\neg\mathrm{Contains}] \ge
1 - (1 - b^{-k})^{\lfloor L/k\rfloor}$. $\square$

**Remark 5.6 (never vacuous).** Since $0 \le 1 - b^{-k} \le 1$ for $b \ge 1$, the
right-hand side of Theorem 5.5 lies in $[0,1]$ for every $L$; the bound is always
meaningful, in contrast to Theorem 4.5.

---

## 6. Borges completeness

**Theorem 6.1 (`prob_contains_tendsto_one`).** Let $b \ge 2$ and let $p$ be a
fixed pattern of length $k \ge 1$. Then
$$ \lim_{L \to \infty} \Pr\big[\,\mathrm{Contains}(p,\cdot)\,\big] = 1. $$

*Proof sketch.* For $b \ge 2$ and $k \ge 1$ we have $b^k \ge 2$, hence
$0 \le 1 - b^{-k} < 1$. Therefore $(1 - b^{-k})^n \to 0$ as $n \to \infty$
(a geometric sequence with ratio in $[0,1)$). Since $\lfloor L/k\rfloor \to
\infty$ as $L \to \infty$, the composite $(1-b^{-k})^{\lfloor L/k\rfloor} \to 0$,
so the lower bound $1 - (1-b^{-k})^{\lfloor L/k\rfloor} \to 1$ (Theorem 5.5).
Combined with the universal upper bound $\Pr[\cdot] \le 1$ (Theorem 3.4), the
squeeze theorem forces $\Pr[\mathrm{Contains}] \to 1$. $\square$

**Interpretation.** This is the precise sense in which the Library of Babel
"contains everything": for any alphabet with at least two symbols and any finite
target text, a uniformly random volume contains that text with probability
approaching $1$ as the volume length grows. The hypothesis $b \ge 2$ is
essential: a unary alphabet ($b = 1$) yields a single volume per length, which
contains only constant strings.

---

## 7. Algorithms

The proofs are constructive enough to read off explicit, exact algorithms over
the rationals (or exact integers), avoiding floating-point error entirely.

**Algorithm 7.1 (Exact library statistics).** Given $b, L, k$, compute
$\#\mathrm{Library} = b^L$, $\Pr(\text{single}) = b^{-L}$,
$\mathbb{E}[\mathrm{occ}] = (L-k+1)b^{-k}$, the union upper bound, and the
disjoint-block lower bound, all as exact rationals. Complexity is dominated by
big-integer exponentiation, $O(\mathrm{poly}\log)$ multiplications on numbers of
$O(L\log b)$ bits.

**Algorithm 7.2 (Threshold length).** Given $b, k$ and a target containment
probability $1 - \varepsilon$, find the smallest $L$ for which the certified
lower bound $1 - (1-b^{-k})^{\lfloor L/k\rfloor}$ reaches $1-\varepsilon$. Since
the bound is monotone in $L$, solve $(1-b^{-k})^{\lfloor L/k\rfloor} \le
\varepsilon$ for the block count $m = \lceil \log\varepsilon / \log(1-b^{-k})
\rceil$, then $L = mk$. This is the rigorous "how long must a book be to almost
surely contain my text" calculator.

---

## 8. Applications

- **Combinatorics on words.** The disjoint-block method is a clean, reusable
  technique for lower-bounding the probability that a random word contains a
  factor, sidestepping the dependence in overlapping-window analyses.
- **Random text and Monte Carlo intuition.** The expected-count formula and the
  threshold calculator quantify how long a randomly generated text must be before
  a fixed motif appears — relevant to password-space heuristics, random-search
  baselines, and "infinite monkey" estimates.
- **Pedagogy of the probabilistic method.** The pair (first-moment union bound,
  disjoint-block second argument) is a self-contained illustration of why the
  first moment alone is insufficient and how independence rescues a lower bound.

---

## 9. Discussion

The development is deliberately elementary: only finite counting, linearity of
expectation, a single bijective reindexing, and the convergence of a geometric
sequence. Its value is methodological clarity. The exact expected count
$(L-k+1)b^{-k}$ is attractive but yields only the one-directional union bound,
which becomes information-free exactly in the large-$L$ regime of interest. The
disjoint-block decomposition sacrifices the use of all $L-k+1$ overlapping
windows — keeping only $\lfloor L/k\rfloor$ of them — but gains genuine
independence, and that is enough: the resulting lower bound is non-vacuous for
every $L$ and sharpens into almost-sure containment in the limit. The qualitative
phase transition sits at the scale $L \sim b^k$: below it a fixed pattern is
unlikely, above it nearly certain.

A subtle point worth emphasizing is that the lower bound never uses the
overlapping windows at all, so there is no inclusion–exclusion: the inclusion
$\{\text{some aligned block matches}\} \subseteq \{\text{contains}\}$ is exact and
one-directional, which is what keeps the argument short.

---

## 10. Future directions

(See the dedicated Future Directions section accompanying this package for the
detailed program.) Natural extensions include: a parametric family of bounds
trading block count against block overlap to interpolate between the union and
disjoint-block estimates; second-moment (Paley–Zygmund) refinements giving
concentration of the occurrence count, not merely its expectation; multi-pattern
and approximate-match versions; and quantitative central-limit behavior of the
occurrence count for fixed $k$ as $L \to \infty$.

---

## 11. Conclusion

We have given a complete and machine-verified account of the Library of Babel as
a uniform probability space: it has $b^L$ volumes each of probability $b^{-L}$;
the expected number of occurrences of a length-$k$ pattern is exactly
$(L-k+1)b^{-k}$; containment satisfies the matching bounds
$$ 1 - (1-b^{-k})^{\lfloor L/k\rfloor} \ \le\ \Pr[\text{contains}] \ \le\
   (L-k+1)\,b^{-k}, $$
and, for $b \ge 2$, containment of any fixed finite text becomes certain in the
limit of long volumes. Borges' intuition that the library contains everything is,
in this precise probabilistic sense, a theorem.
