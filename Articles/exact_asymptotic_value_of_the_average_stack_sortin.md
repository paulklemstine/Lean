# The Patience of a Stack: How Many Passes Does It Take to Sort the World?

Imagine you are a clerk at an old-fashioned mail room. Letters arrive in a
jumbled order on a conveyor belt, and you have exactly one tool: a tall, narrow
bin. You can drop a letter onto the top of the bin, or you can lift the top
letter off and place it into the outgoing tray. You cannot reach into the
middle. You cannot peek ahead. The bin is a *stack* — last in, first out — and
your job is to get the letters into the tray in sorted order.

This humble picture, a stack and a stream of items, hides one of the most
beautiful stories in modern combinatorics. It connects a 1960s programming
puzzle posed by Donald Knuth to the Catalan numbers (the most famous integer
sequence after the primes), to a deceptively simple operation that, applied over
and over, eventually sorts *anything* — and to a question that remains stubbornly
open today: on average, how many passes does it take?

This article tells that story, and reports what can be proved rigorously about
it. Every definition and every result below is stated in full; you need nothing
but curiosity to follow along.

## One pass through the bin

Let us make the mail-room game precise. We are handed a sequence of distinct
numbers — say a shuffle of $1, 2, \dots, n$ — and we feed them one at a time
into the stack. The rule we follow is the *greedy* one, and it is the rule
discovered by Julian West in his 1990 thesis:

> When the next incoming item is **larger** than the item currently on top of
> the stack, the top item can never again be placed correctly, so pop it out to
> the tray. Keep popping until the top is larger than the incoming item (or the
> stack is empty), then push the incoming item on top.

Reading from the bottom of the bin to the top, the stack always stays in
*decreasing* order: each item sitting on another is smaller than the one beneath
it. When the input runs out, we flush whatever remains, smallest first.

Concretely, processing a new symbol $x$ against the current stack means popping
off every stack element strictly smaller than $x$ — this is the operation our
formalization calls $\mathrm{popLess}$ — recording those popped elements in the
output, and then pushing $x$. One sweep across the whole input, starting from an
empty bin, is **one pass** of West's stack-sorting map, which we write
$\mathrm{stackSort}$.

Let's watch it work on the permutation $2\,3\,1$:

- Push $2$. Stack (top first): $[2]$. Output: empty.
- Next is $3$, larger than top $2$, so pop $2$ to the tray, then push $3$.
  Stack: $[3]$. Output: $2$.
- Next is $1$, smaller than top $3$, so push it. Stack (top first): $[1,3]$.
- Input exhausted; flush smallest-first: $1$, then $3$. Output: $2\,1\,3$.

So $\mathrm{stackSort}(2\,3\,1) = 2\,1\,3$. One pass did *not* finish the job —
$2\,1\,3$ is still not sorted. But notice it is *closer*. Run the machine again:

- $\mathrm{stackSort}(2\,1\,3) = 1\,2\,3$.

A second pass finishes it. The permutation $2\,3\,1$ has **stack-sorting depth
$2$**: the least number of passes that turns it into $1\,2\,3$.

## Three things that are always true

Before chasing the hard questions, it pays to nail down the unglamorous facts
that make the whole edifice trustworthy. They sound obvious; proving them
rigorously is what separates a hunch from a theorem.

**Nothing is lost or duplicated.** A single pass only ever moves items around;
it never invents or destroys one. Formally, $\mathrm{stackSort}(l)$ is always a
*permutation* of the input list $l$. (In the formalization this is the lemma
`stackSort_perm`.) The proof rests on a tiny but crucial observation about the
$\mathrm{popLess}$ step: the items it pops, glued back onto the items it leaves
behind, are exactly the original stack rearranged. Push that invariant through
the whole left-to-right sweep and you learn that the output of a pass is a
rearrangement of the input concatenated with the stack — and so, starting from
an empty stack, a rearrangement of the input.

**The length never changes.** An immediate corollary: since a pass produces a
permutation, the output has exactly as many items as the input
(`stackSort_length`). This is what guarantees the machine cannot run away with
itself.

**Sorted means done.** If a list is already strictly increasing, a pass leaves
it completely untouched: it is a *fixed point* of $\mathrm{stackSort}$
(`stackSort_strictSorted_eq`). The intuition is exactly the conveyor belt: when
the items already arrive in increasing order, every new item is larger than
whatever is in the bin, so each one immediately falls through to the tray and
nothing piles up. The heart of the argument is a clean little lemma — feeding an
increasing sequence past a single waiting item $m$ that is smaller than all of
them simply outputs $m$ followed by that sequence, unchanged.

These three facts have a satisfying consequence for the notion of depth. We
define the **depth** of a list as the least number of passes needed to reach its
ascending sort, and we search for it with a bounded loop. Because each pass
preserves length and a sorted list is a fixed point, the search is well posed: a
list that is already sorted has depth $0$ (`depth_sorted`), and West proved that
*any* permutation of length $n$ is sorted after at most $n-1$ passes — so the
search bound of the list's own length is always generous enough.

## Knuth's bin and the Catalan numbers

Now the depth becomes a lens. Sort the world of permutations by how stubborn
they are, and patterns leap out.

The easiest permutations are those with depth $0$: only the already-sorted
identity. The next tier, **depth at most $1$**, are the permutations that a
*single* pass sorts completely. These are the celebrated **stack-sortable**
permutations, and counting them is where the magic starts.

Knuth asked exactly this question in *The Art of Computer Programming*: which
permutations can a single stack sort? His answer is one of the gems of the
field. A permutation is sortable in one pass **if and only if** it contains no
occurrence of the pattern $231$ — that is, no three positions (not necessarily
adjacent) whose values, read left to right, are in the relative order
medium–large–small. Our $2\,3\,1$ above *is* the pattern $231$, which is exactly
why one pass failed it.

And the number of $231$-avoiding permutations of $\{1,\dots,n\}$ is the $n$-th
**Catalan number**,
$$C_n = \frac{1}{n+1}\binom{2n}{n} = 1, 1, 2, 5, 14, 42, 132, 429, \dots$$
the same sequence that counts balanced strings of parentheses, triangulations of
a polygon, and binary trees. The stack is secretly a parenthesis: pushing is an
open bracket, popping is a close bracket, and a legal sorting is a legal
nesting.

This "Catalan law" is verified exactly in our formalization for the first
several cases. The number of one-pass-sortable permutations of $\{1,\dots,4\}$
is $C_4 = 14$; of $\{1,\dots,5\}$ it is $C_5 = 42$; and of $\{1,\dots,6\}$ it is
$C_6 = 132$ (the theorems `depthLe1_card_eq_catalan_four`, `..._five`, and
`..._six`, each checked by exhaustive machine computation over all $24$, $120$,
and $720$ permutations respectively).

## The full spectrum of difficulty

What about the stubborn permutations — the ones that need two, three, or more
passes? Tabulating the **depth distribution** (how many permutations of
$\{1,\dots,n\}$ require each possible depth) reveals a remarkably orderly
landscape. Writing $(t, k)$ for "$k$ permutations have depth $t$":

- $n=3$: $(0,1),\ (1,4),\ (2,1)$
- $n=4$: $(0,1),\ (1,13),\ (2,8),\ (3,2)$
- $n=5$: $(0,1),\ (1,41),\ (2,49),\ (3,23),\ (4,6)$
- $n=6$: $(0,1),\ (1,131),\ (2,276),\ (3,198),\ (4,90),\ (5,24)$

Several patterns sing out. There is always exactly one permutation of depth $0$
(the identity). The depth-$\le 1$ totals — $1+4=5=C_3$, $1+13=14=C_4$,
$1+41=42=C_5$, $1+131=132=C_6$ — reproduce the Catalan numbers, just as the law
predicts. And the count of *maximally* stubborn permutations (those needing the
full $n-1$ passes) is $1, 2, 6, 24, \dots$ — the factorials $(n-2)!$, a crisp
conjecture about the very hardest inputs.

The middle of each row swells and then tapers: most permutations are neither
trivially easy nor maximally hard, but cluster at a depth that creeps upward as
$n$ grows. That creeping is the doorway to the deepest question of all.

## The headline mystery: how hard is a typical shuffle?

Pick a permutation of $\{1,\dots,n\}$ uniformly at random and ask for its
expected depth,
$$A(n) = \frac{1}{n!}\sum_{w} \mathrm{depth}(w).$$
Direct computation gives
$$A(2)=0.5,\quad A(3)=1,\quad A(4)\approx 1.458,\quad A(5)\approx 1.933,\quad A(6)\approx 2.440,\quad A(7)\approx 2.973,\quad A(8)\approx 3.524.$$
The average depth grows steadily, and the gaps between consecutive values —
roughly $0.5, 0.46, 0.48, 0.51, 0.53, 0.55$ — drift upward. It looks
unmistakably *linear*: $A(n) \approx c\,n$ for some constant $c$.

What is $c$? This is the open problem at the center of the subject. The depth is
squeezed between $0$ and $n-1$, so $c$ lies in $(0, 1]$; the data so far sit well
below the midpoint, and the central conjecture of this line of work is that the
scaled average converges to a specific rational number,
$$\frac{A(n)}{n} \longrightarrow \frac{3}{4}.$$
A companion conjecture predicts that not just the *average* but a *typical*
permutation has depth close to $c\,n$: the distribution concentrates, so that a
random shuffle is, with overwhelming probability, neither freakishly easy nor
freakishly hard but right around the linear trend. Proving either statement — even
pinning down whether $c$ equals $3/4$ rather than some nearby value — would be a
genuine advance.

## Why a children's game deserves a proof

It is tempting to dismiss stack sorting as a toy. But the lesson of this
subject is that the toy is load-bearing. The same operation models a railway
shunting yard, a one-deep undo buffer, a parser's working memory, and a network
router with a single queue. The question "how many passes until sorted?" is the
question "how far is this arrangement from achievable order, given a brutally
limited tool?" — and that is a question about the structure of disorder itself.

What this formalized development secures is the foundation: that the
stack-sorting pass is a genuine, length-preserving rearrangement; that sorted
inputs are exactly the resting states; that depth is therefore a well-defined,
finite measure of stubbornness; and that the easy end of the spectrum obeys the
Catalan law on the nose. With those load-bearing facts proved beyond doubt, the
tantalizing asymptotic question — does the average depth of a random shuffle
really tend to three-quarters of its length? — stands on solid ground, waiting
for its proof.

The clerk in the mail room, it turns out, was doing combinatorics all along.
