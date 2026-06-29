# The Magic Number $2n-1$: How Many Numbers Must You Gather Before a Perfect Subset Appears?

## A game with remainders

Imagine you are handed a long line of whole numbers and a single secret rule:
you are only allowed to care about their *remainders* after dividing by some
fixed number $n$. Maybe $n = 12$, like the hours on a clock; maybe $n = 7$,
like the days of the week. Your task is deceptively simple. From the line of
numbers in front of you, pick out exactly $n$ of them so that their sum is a
perfect multiple of $n$ — in clock language, so that the hands return exactly
to twelve.

If someone hands you only a few numbers, you may be stuck: there might be no
way to choose precisely $n$ of them that "close the loop." But intuition says
that if the line is long enough, you will *always* succeed, no matter which
numbers were chosen, no matter how adversarial your opponent was when writing
them down.

This raises a sharp and beautiful question. **What is the shortest line length
that guarantees success — every single time?** Not for one lucky sequence, but
for *all* possible sequences at once.

The answer, astonishingly clean, is

$$2n - 1.$$

With $2n-1$ numbers in hand you can *always* find $n$ of them whose sum is
divisible by $n$. With only $2n-2$, a cunning opponent can arrange things so
that you never can. This article tells the story of that exact threshold, why
it is neither one less nor one more, and how it can be turned into an algorithm
that actually hands you the winning subset.

## Erdős, Ginzburg, and Ziv

In 1961, three mathematicians — Paul Erdős, Abraham Ginzburg, and Abraham Ziv —
proved a statement that has rippled through combinatorics and number theory ever
since. In modern language it reads:

> **Erdős–Ginzburg–Ziv theorem.** Among any $2n-1$ integers, there exist $n$ of
> them whose sum is divisible by $n$.

It is one of those rare results that is easy to state to a curious teenager and
yet hard enough to have spawned dozens of generalizations, competition problems,
and research papers. The number $n$ appears twice in the conclusion — *$n$
chosen items, divisible by $n$* — and that double role is exactly what makes the
problem subtle. You are not merely looking for *some* subset that sums to a
multiple of $n$ (that is comparatively easy); you must hit the sum *and* the
exact count simultaneously.

To make all of this rigorous, mathematicians work not with integers directly but
with their remainders. The remainders modulo $n$ form a small, self-contained
number system called the **cyclic group** $\mathbb{Z}/n\mathbb{Z}$, often
written $C_n$. In it, addition wraps around: $7 + 8 = 3$ when $n = 12$, just
like a clock. "Sum divisible by $n$" becomes the crisp statement "sum equals
$0$ in $C_n$."

## Naming the threshold

To talk precisely about *the shortest guaranteeing length*, we give it a name.
Say that a length $m$ **has the EGZ property for $n$** if the following holds:

> For *every* sequence $a_1, a_2, \dots, a_m$ of elements of $C_n$, there is a
> choice of exactly $n$ positions whose entries sum to $0$.

Notice the universal quantifier: the property is about *all* sequences of length
$m$, not a single favorable one. If $m$ is large the property is easy to satisfy;
if $m$ is small it fails. The **Erdős–Ginzburg–Ziv constant** of $C_n$ is the
smallest length that works:

$$\mathrm{EGZ}(n) = \min\{\, m : m \text{ has the EGZ property for } n \,\}.$$

The central theorem of this work is the exact evaluation of this constant.

> **Main theorem.** For every $n \ge 1$,
> $$\mathrm{EGZ}(n) = 2n - 1.$$

Everything else is the scaffolding that pins this number down from both sides:
it cannot be smaller, and it does not need to be larger.

## Why $2n-2$ is not enough: the saboteur's sequence

Let us first see why the threshold cannot drop even to $2n-2$. To prove a
*guarantee* fails, we only need to exhibit one stubborn counterexample — a single
sequence of length $2n-2$ in which no $n$ entries sum to zero. This is the role
of the saboteur.

The saboteur's construction is gloriously simple. Take

$$\underbrace{0, 0, \dots, 0}_{n-1 \text{ copies}}, \quad
  \underbrace{1, 1, \dots, 1}_{n-1 \text{ copies}}.$$

That is $n-1$ zeros followed by $n-1$ ones, for a total length of $2n-2$.

Now suppose you try to pick $n$ of these entries. Say you grab $k$ of the ones
and the rest from the zeros. Because there are only $n-1$ zeros available, you
are *forced* to take at least one of the ones, so $k \ge 1$. And because there
are only $n-1$ ones available, you can take at most $n-1$ of them, so
$k \le n-1$. The sum of your chosen entries is exactly $k$ (each one contributes
$1$, each zero contributes nothing). For that sum to vanish in $C_n$ we would
need $k$ to be a multiple of $n$. But $1 \le k \le n-1$, so $k$ is strictly
between $0$ and $n$ — never a multiple of $n$.

Conclusion: **no** choice of $n$ entries sums to zero. The saboteur wins at
length $2n-2$. Therefore $\mathrm{EGZ}(n) > 2n-2$, i.e. $\mathrm{EGZ}(n) \ge
2n-1$.

In the formal development this argument is captured by two companion facts:
a bookkeeping identity, `extremalSeq_sum_eq`, which says that the sum over any
chosen subset of the saboteur's sequence equals (the remainder of) the number of
ones you picked; and the impossibility lemma `not_hasEGZProperty_two_mul_sub_two`,
which packages the "$1 \le k \le n-1$ so $k \ne 0$ mod $n$" reasoning into a
clean statement that the EGZ property fails at length $2n-2$.

## Why $2n-1$ always succeeds: the deep direction

The hard half is the *guarantee*: with $2n-1$ numbers, success is unavoidable.
This is the genuine content of the Erdős–Ginzburg–Ziv theorem, and unlike the
saboteur's one-line construction, it requires real machinery.

The classical proof proceeds in two stages. First one reduces the general case
to the case where $n = p$ is prime, using a multiplicative trick: if the theorem
holds for $a$ and for $b$, it holds for the product $ab$. So the entire weight of
the theorem rests on prime moduli. Second, for a prime $p$, the result follows
from a gem of finite-field algebra known as the **Chevalley–Warning theorem**,
which controls the number of solutions to systems of polynomial equations over a
finite field. One cleverly encodes "choose $p$ items with zero sum" as a pair of
polynomial congruences of low degree; Chevalley–Warning then forces the number
of solutions to be divisible by $p$, and since the trivial all-zero solution is
always present, a second, nontrivial solution must exist — and that solution *is*
the zero-sum subset.

In the formal artifact this entire chain is invoked through the library result
`ZMod.erdos_ginzburg_ziv`, and the packaged statement
`exists_contiguous_zero_block_in_some_length` records its consequence in the form
we need:

> **Upper bound.** For every $n$ and every sequence $a : \{1, \dots, 2n-1\} \to
> C_n$, there is a subset $t$ of size exactly $n$ with $\sum_{i \in t} a_i = 0$.

A word on the name. Historically the result is sometimes described as producing
a "zero-sum block." But the winning $n$ elements need not be *contiguous* — they
can be any $n$ of the $2n-1$ positions. The formal statement is careful to phrase
the conclusion as an arbitrary subset of size $n$, correcting a common
misconception baked into the informal nickname.

## Closing the vise

With both halves in place, the exact value follows by a squeeze. Define the set

$$S = \{\, m : m \text{ has the EGZ property for } n \,\}.$$

The upper bound says $2n-1 \in S$. The lower bound, amplified by a simple
monotonicity observation — *if a length works, every longer length works too*,
since you can ignore the extra entries (`hasEGZProperty_mono`) — says that no
$m < 2n-1$ belongs to $S$. Hence the least element of $S$ is exactly $2n-1$:

$$\mathrm{EGZ}(n) = 2n - 1.$$

The monotonicity step deserves a moment of appreciation. It is the bridge that
turns a single counterexample at length $2n-2$ into a blanket failure at *every*
length below the threshold. Without it, ruling out $2n-2$ would not automatically
rule out, say, $2n-5$. With it, one extremal sequence does all the work
(`not_hasEGZProperty_of_lt`).

## From existence to construction

A pure existence theorem can feel unsatisfying: *yes, the subset is there, but
where?* The development closes this gap with an explicit extractor,
`findZeroSumSubset`, which takes any sequence of length $2n-1$ and returns a
concrete witnessing subset. Its specification, `findZeroSumSubset_spec`,
guarantees two things at once: the returned subset has exactly $n$ elements, and
those elements sum to zero modulo $n$.

In practice the subset can be found efficiently. Over a prime modulus $p$, a
classical sorting argument finds the zero-sum subset in roughly $p \log p$ time:
sort the $2p-1$ remainders, look at the $p-1$ consecutive *gaps* between the
$i$-th and $(i+p-1)$-th sorted values, and a pigeonhole on these gaps modulo $p$
delivers the answer. For composite $n$ one recurses through the prime
factorization. The accompanying demonstrations implement exactly this pipeline,
turning the abstract guarantee into runnable code that prints the chosen indices
and verifies that their sum vanishes.

## Why anyone should care

At first glance this is a puzzle about clocks and remainders. But the
Erdős–Ginzburg–Ziv constant sits at a busy intersection of mathematics.

**Zero-sum theory.** EGZ launched an entire subfield asking, for a finite
abelian group $G$, how long a sequence must be before a zero-sum subsequence of a
prescribed shape is forced. Cousins of $\mathrm{EGZ}(n)$ include the *Davenport
constant* (shortest sequence forcing *some* nonempty zero-sum subsequence) and a
whole zoo of weighted and higher-dimensional variants. The clean value $2n-1$ is
the anchoring example that every student meets first.

**Factorization and chemistry of numbers.** Davenport-type constants measure how
badly unique factorization can fail in algebraic number fields — they bound the
lengths of factorizations of algebraic integers into irreducibles. Zero-sum
combinatorics is, quite literally, the arithmetic of how things can be
decomposed.

**Coding theory and design.** Zero-sum conditions over $C_n$ appear in the
construction of error-correcting codes and combinatorial designs, where balanced
selections summing to a fixed target are exactly what one needs.

**A model of effective mathematics.** The original conjecture motivating this
work asked whether such thresholds, often proved by soft asymptotic arguments,
can be made *constructive* with explicit, computable bounds. The case of the
cyclic group answers this in the most decisive way possible: the threshold is not
merely bounded by some computable function — it is the exact, closed-form,
optimal value $2n-1$, and a subset achieving it can be extracted by an explicit
algorithm. There is no hidden constant, no unquantified "for large enough $n$."
The bound is sharp on the nose.

## The shape of certainty

There is a particular pleasure in problems whose answer is a single tidy formula.
Ask "how many?" and the universe replies "$2n-1$," not approximately, not
eventually, but always and exactly. One side of the equality is held down by a
saboteur's sequence of zeros and ones so simple a child could write it; the other
is held up by a tower of finite-field algebra reaching back to Chevalley and
Warning. Between them, squeezed to a point, sits the number $2n-1$ — the exact
length at which coincidence becomes inevitability.
