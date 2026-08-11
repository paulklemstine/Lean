# The Sets That Cannot Be Broken

## A puzzle about coins

Imagine you are handed an infinite supply of coin denominations — a set $A$ of positive
whole numbers — and asked a simple question: *which totals can you pay exactly, using each
denomination at most once?*

If $A = \{1, 2, 4, 8, 16, \dots\}$, the powers of two, the answer is *everything*: binary
notation says so. If $A$ is the set of all even numbers, the answer is *only even totals*.
Somewhere between these extremes lies the interesting behaviour, and it has a name. Call a
set $A$ of natural numbers **complete** if every sufficiently large integer $n$ can be
written as
$$n = a_1 + a_2 + \cdots + a_r, \qquad a_1 < a_2 < \cdots < a_r, \quad a_i \in A .$$
That is: all but finitely many integers are sums of *distinct* elements of $A$. The squares
are complete; so are the primes; so is any set that grows slowly enough and is arithmetically
rich enough.

Now comes the twist that this article is about. Completeness, it turns out, can be a
*fragile* property — a property that a single deletion can destroy.

## The fragility of completeness

Consider the set
$$E_1 \;=\; \{0, 2, 4, 6, 8, \dots\} \cup \{1\},$$
all the even numbers together with the single odd number $1$. This set is complete: an even
total $n$ is simply $n$ itself, and an odd total $n$ is $1 + (n-1)$, a sum of two distinct
elements. Every integer from some point on is payable.

Now delete one coin — the coin labelled $1$. What remains is the set of even numbers, and
every subset sum of even numbers is even. Half of all integers have become unpayable. A set
that was complete has been reduced to a set that is not, by removing exactly one element out
of infinitely many.

This motivates a more robust notion. Say that $A$ is **strongly complete** if $A \setminus F$
is complete for *every* finite set $F$. Strong completeness is completeness that survives
sabotage: no matter which finite collection of denominations an adversary confiscates, you
can still pay all large totals.

The set $E_1$ is complete but not strongly complete. The question that organises everything
below is: **what makes a set strongly complete?**

## First simplification: only the tails matter

A pleasant first observation cuts the problem down to size. Deleting an arbitrary finite set
$F$ looks like a bewilderingly large family of tests — there are infinitely many finite sets.
But every finite set of natural numbers is bounded, so deleting $F$ removes no more than
deleting the entire initial segment $\{0, 1, \dots, k\}$ for a suitable $k$. And deleting
more can only make completeness harder. This gives the

> **Initial-Segment Criterion.** A set $A$ is strongly complete if and only if, for every
> $k$, the tail $A \cap (k, \infty)$ is complete.

So the infinitely many adversarial tests collapse to one nested sequence of canonical tests:
chop off the front, and see whether what remains can still pay its way. Together with the
obvious but useful fact that *any superset of a (strongly) complete set is again (strongly)
complete*, this is the toolkit we start from.

## The positive engine: blocks that cover intervals

How does one actually *prove* a set strongly complete? The classical mechanism is a greedy
argument, and it can be packaged as a clean structural criterion.

Suppose we can find inside $A$ an infinite sequence of finite, pairwise ordered "blocks"
$B_0, B_1, B_2, \dots$ — ordered meaning every element of $B_k$ is smaller than every element
of $B_{k+1}$ — and suppose that block $B_k$ is *rich enough* that its own subset sums realise
every integer in an interval $[\ell_k, h_k]$. Then the following three arithmetic conditions
on the intervals suffice for strong completeness:

* **positivity and monotonicity:** $\ell_k \ge 1$ and $\ell_k$ is nondecreasing;
* **doubling:** $2\ell_k \le h_k + 1$, i.e. each covered interval is at least as long as its
  own left endpoint;
* **overlap:** $\ell_{k+1} \le h_k + 1$, i.e. consecutive covered intervals abut or overlap.

> **Ordered-Block Criterion.** If $A$ contains such a system of blocks, then $A$ is strongly
> complete. In particular it is complete.

Why is it true? Fix a finite $F$ to be deleted. Because the blocks are ordered and nonempty,
the $k$-th block consists of numbers that are at least $k$; so all blocks past some index $m$
avoid $F$ entirely — the adversary can only ever damage finitely many blocks. The remaining
task is to show that the blocks $B_m, B_{m+1}, \dots$ alone represent every sufficiently
large integer, and here the greedy induction runs.

Suppose we already know that blocks $B_m, \dots, B_{m+j}$ represent every integer between
$\ell_m$ and $H_j := h_m + h_{m+1} + \cdots + h_{m+j}$, and we are handed a target $n$ with
$\ell_m \le n \le H_j + h_{k}$ where $k = m+j+1$. If $n \le H_j$ we are done by induction. If
$n \le h_k$, the single last block does the job — for the overlap condition guarantees
$\ell_k \le H_j + 1 \le n$, so $n$ lands inside the interval $[\ell_k, h_k]$ that $B_k$
covers. Otherwise $n$ exceeds both $H_j$ and $h_k$, and we split $n = u + v$ with $u$
represented by the earlier blocks and $v$ by the last one. Either $n \ge \ell_m + h_k$, in
which case take $v = h_k$ and $u = n - h_k$, or $n < \ell_m + h_k$, in which case take
$u = \ell_m$ and $v = n - \ell_m$; the doubling condition is exactly what guarantees that
$v = n - \ell_m$ still exceeds $\ell_k$ in the second case, and the earlier blocks are large
enough to absorb $u$ in the first. Since earlier blocks and the last block are disjoint by
the ordering, the two representations combine into one set of *distinct* elements. Finally,
because $h_k \ge 1$ always, the accumulated ceilings $H_j$ march off to infinity, so every
large $n$ is eventually caught.

The moral is that the greedy argument needs two things, and only two: intervals long enough
to keep doubling, and intervals close enough together to leave no gap.

## Dyadic blocks and a warning

A natural way to manufacture blocks is by scale. Define the **$k$-th dyadic block** of $A$ to
be
$$A \cap (2^k, \, 2^{k+1}],$$
the elements of $A$ between consecutive powers of two. Every integer $\ge 2$ lies in exactly
one dyadic range, so these blocks tile $A$ from $2$ upward. A classical theorem in this area
asserts that if, from some point on, every dyadic block of $A$ contains at least six
elements — *and* an auxiliary analytic condition holds — then $A$ is strongly complete.

The formal machinery confirms the easy end of this. If, from some index on, $A$ contains
*every* integer in each dyadic range, then $A$ is strongly complete: take as blocks the
unions of two consecutive dyadic ranges, $(2^{K+2j}, 2^{K+2j+2}]$, whose subset sums include
all their own singletons, so they cover the interval $[\,2^{K+2j}+1,\, 2^{K+2j+2}\,]$, and the
doubling condition $2(2^{K+2j}+1) \le 2^{K+2j+2}+1$ holds comfortably.

But here is where the story gets sharp — and here is the result that explains why the
classical theorem needs its analytic hypothesis at all.

> **Six elements per dyadic block are not enough.** There is a set with at least six elements
> in every dyadic block of index $\ge 5$ that is not even complete, let alone strongly
> complete.

The witness is embarrassingly simple: the multiples of $3$. In any dyadic range
$(2^k, 2^{k+1}]$ with $k \ge 5$, the range has length $2^k \ge 32$, so it contains at least
six multiples of $3$ in arithmetic progression — indeed $c, c+3, c+6, c+9, c+12, c+15$ for a
suitable multiple $c$ of $3$ just above $2^k$, since $15 < 32$. Yet every subset sum of
multiples of $3$ is a multiple of $3$, so two-thirds of all integers are unreachable. Density,
by itself, buys nothing.

The obstruction here is not size. It is *arithmetic*: the whole set sits inside a proper
subgroup of the integers, and no amount of local abundance can escape a subgroup.

## The two ingredients

The counterexample points at a general principle, which the rest of the story makes precise:
a robust completeness criterion needs **two independent mechanisms**, a *size* mechanism and
a *congruence* mechanism, and both must be immune to finite deletion.

Here is the criterion that isolates them.

> **Backbone-and-Residues Criterion.** Let $d \ge 1$. Suppose $A$ contains a subset $B$ which,
> after the deletion of any finite set, still represents every sufficiently large multiple of
> $d$ as a subset sum (call $B$ a *$d$-backbone*), and suppose that for every residue $r$
> modulo $d$, infinitely many elements of $A$ are congruent to $r$. Then $A$ is strongly
> complete.

The proof is a two-step payment scheme. Given a finite set $F$ to be deleted and a large
target $n$, first look at $n$ modulo $d$ and pick a *single* element $a \in A$ with
$a \equiv n \pmod d$ that is larger than everything in $F$ — the residue hypothesis guarantees
infinitely many candidates, so one of them lies out of the adversary's reach. Now $n - a$ is a
multiple of $d$, and it is large; the backbone, which also survives the deletion of $F$ (and,
for good measure, of everything below the finitely many chosen residue representatives),
represents it. The two pieces are disjoint because the backbone piece was forced to live above
$a$. Add them up, and $n$ is paid.

Two consequences are worth recording. First, a **multiples-and-residues** version: if $A$
contains every multiple $dm$ with $m \ge K$, and every residue class mod $d$ meets $A$
infinitely often, then $A$ is strongly complete. Second, a **dilation principle**: if $A$ is
strongly complete, then $d \cdot A = \{da : a \in A\}$ is a $d$-backbone, so
$d\cdot A \,\cup\, C$ is strongly complete for *any* set $C$ that supplies infinitely many
elements in every residue class mod $d$. This manufactures strongly complete sets living on
prescribed scales, arbitrarily sparse in absolute terms.

A pretty special case brings us back to our opening example. A set containing **all** even
numbers and **infinitely many** odd numbers is strongly complete. Compare $E_1$, which
contains all evens and exactly *one* odd number, and is not. The difference between fragility
and robustness is the difference between one and infinitely many.

## Parity is a red herring

That last comparison invites a conjecture, and it is a tempting one: *if $A$ is complete and
contains infinitely many odd elements, is $A$ strongly complete?* The intuition is that odd
elements are what let you repair parity, and infinitely many of them cannot all be deleted.

The conjecture is **false**, and the counterexample is as clean as the earlier one:
$$T \;=\; \{n : 3 \mid n\} \;\cup\; \{1, 2\},$$
the multiples of $3$ together with the two units $1$ and $2$.

* $T$ **is complete.** For $n \ge 3$: if $n \equiv 0 \pmod 3$ then $n \in T$ itself; if
  $n \equiv 1$ then $n = 1 + (n-1)$ with $n - 1$ a multiple of $3$; if $n \equiv 2$ then
  $n = 2 + (n-2)$, again with a multiple of $3$. In each case the two summands are distinct.
* $T$ **contains infinitely many odd elements** — every odd multiple of $3$, namely
  $3, 9, 15, 21, \dots$, i.e. all $6k + 3$.
* $T$ **is not strongly complete.** Delete the two-element set $\{1, 2\}$. What remains is
  exactly the multiples of $3$, whose subset sums are multiples of $3$.

So parity was never the point. Parity is merely the case $d = 2$ of an obstruction that exists
for every modulus $d$: a set can be complete only because of finitely many elements that
escape the subgroup $d\mathbb{Z}$, and deleting those finitely many exceptions collapses it.

Turning this around gives a clean necessary condition:

> **Congruence Necessity.** If $A$ is strongly complete, then for every $d \ge 2$ the set of
> elements of $A$ *not* divisible by $d$ is infinite.

Indeed, if only finitely many elements escaped $d\mathbb{Z}$, deleting exactly those would
leave a set inside $d\mathbb{Z}$, whose subset sums miss every integer not divisible by $d$.

## Where the analysis comes in

The classical theorem's auxiliary hypothesis is analytic and looks, at first sight, entirely
unrelated to residues. Write $\|x\|$ for the distance from a real number $x$ to the nearest
integer. The hypothesis is:
$$\text{for every non-integral } \theta \in \mathbb{R}, \qquad \sum_{a \in A} \|a\theta\|^2 = \infty .$$

What is this condition doing? It is a uniform way of saying that the elements of $A$ do not
conspire to line up with any single frequency. If $A$ were contained in $d\mathbb{Z}$, then at
$\theta = 1/d$ every term $\|a/d\|^2$ would vanish and the series would converge — trivially,
to zero. The hypothesis forbids exactly that.

And in fact, at the rational test points, the analytic condition is *precisely* a congruence
condition. Here is the bridge.

> **Rational Divergence Dictionary.** For every integer $d \ge 2$,
> $$\sum_{a \in A} \left\| \frac{a}{d} \right\|^2 = \infty \quad \Longleftrightarrow \quad
> \{a \in A : d \nmid a\} \text{ is infinite.}$$

The proof is a two-sided estimate on a single quantity. If $d \mid a$, then $a/d$ is an
integer and the term is $0$. If $d \nmid a$, then $a/d$ has fractional part $r/d$ with
$1 \le r \le d-1$, so its distance to the nearest integer is at least $1/d$ and the term is at
least $1/d^2$ — a fixed positive constant. Hence the series is a sum of finitely many or
infinitely many terms each bounded below by $1/d^2$, and it diverges exactly when infinitely
many are present.

Two corollaries fall out immediately, and together they place the whole picture in focus.

First, **the analytic hypothesis implies the necessary congruence condition**: any set
satisfying $\sum_{a} \|a\theta\|^2 = \infty$ for all non-integral $\theta$ automatically has
infinitely many elements outside every subgroup $d\mathbb{Z}$. This is why the classical
theorem is not contradicted by our counterexamples: the multiples of $3$, and the set
$T = 3\mathbb{Z}_{\ge 0} \cup \{1,2\}$, both *fail* the divergence hypothesis at $\theta = 1/3$
— in the first case every term vanishes, in the second all but two do. The theorem never
claimed them, and could not have.

Second, and in the other direction, **every strongly complete set satisfies all the rational
instances of the hypothesis**: combining congruence necessity with the dictionary, if $A$ is
strongly complete then $\sum_{a \in A} \|a/d\|^2 = \infty$ for every $d \ge 2$. So the analytic
condition, at least at rational points, is not an artifact of the proof technique. It is
*forced* by the conclusion.

## What the picture looks like now

Step back and the landscape is unexpectedly tidy. Strong completeness of a set of natural
numbers requires, and is delivered by, two things at once:

1. **Size that survives deletion.** Blocks whose subset sums cover long intervals — long
   enough to double, close enough to overlap — or a backbone that represents all large
   multiples of some $d$ no matter what is deleted.
2. **Congruence richness that survives deletion.** Infinitely many elements in every residue
   class, equivalently (at rational frequencies) the divergence of $\sum \|a\theta\|^2$.

Each alone provably fails. The multiples of $3$ have unlimited size — six elements in every
large dyadic block, and indeed a positive proportion of every interval — but no residue
richness, and they are not complete. The set $E_1$ of all evens plus the single odd number $1$
has a residue in every class, but only finitely often, and it is complete but shatters at the
first deletion. Only together do the two mechanisms produce robustness.

There is something appealing about the way an analytic hypothesis, expressed in terms of
distances to integers and divergent series, turns out at its rational specialisations to be a
statement about residue classes — the analysis and the arithmetic naming the same obstruction
in two languages. The full hypothesis, quantified over irrational $\theta$ as well, is a
uniform strengthening: it rules out not only the subgroup obstructions visible modulo $d$, but
also the subtler equidistribution failures that a set can suffer without lying in any
subgroup at all.

What remains open is whether congruence richness alone, in the presence of ordinary
completeness, is enough — that is, whether a complete set meeting every residue class modulo
every modulus infinitely often must be strongly complete. The backbone criterion settles this
whenever the set carries a backbone; the general case, where the size mechanism must be
extracted from completeness itself rather than assumed, is the natural next target. The
parity conjecture died because it tested only one modulus. Whether testing *all* moduli
suffices is a question that now has a precise shape.
