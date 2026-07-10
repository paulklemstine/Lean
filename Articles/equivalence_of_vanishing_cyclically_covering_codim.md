# When Every Rotation Misses the Target: A Hidden Bridge Between Covering Spaces and Perfect Codewords

## A puzzle about rotations

Imagine a clock face with $n$ hours, but instead of numbers you write down a
list of $n$ symbols drawn from a fixed alphabet — say the digits $0$ through
$q-1$. Such a list is a *word*, and the collection of all possible words is a
vast $n$-dimensional space. Now suppose you are handed a *filter*: a rule that
accepts some words and rejects others. The filter is not arbitrary; it is a
*linear* rule, the kind you build out of sums and scalings, so the set of
accepted words forms a flat subspace of the whole space.

Here is the game. You may *rotate* a word — pick up the clock, spin it, and read
the symbols off again from a new starting hour. The question is:

> Given any word at all, can you always rotate it until the filter accepts it?

If the answer is yes for *every* starting word, we call the filter **cyclically
covering**. A covering filter is powerful: no matter what the universe throws at
you, a suitable rotation lands inside it. The whole space is trivially covering
(it accepts everything), but the interesting covering filters are the *small*
ones — the subspaces of low dimension that still manage to catch every word up
to rotation.

The measure of how small they can get is a single number, written $h_q(n)$: the
**largest codimension** — that is, the largest number of independent linear
constraints — that a cyclically covering subspace can carry. A large $h_q(n)$
means you can impose many constraints and still cover everything by rotating; a
value of $h_q(n) = 0$ means the opposite, the most rigid possible situation: the
*only* cyclically covering subspace is the entire space. Not one single
constraint can be added without breaking the covering property.

## A puzzle about codewords

Set that aside and consider a completely different-looking object from the theory
of error-correcting codes. A **cyclic code** is a linear subspace of words that
is *closed under rotation*: rotate any accepted word and it is still accepted.
Cyclic codes are the workhorses of digital communication — the Reed–Solomon
codes on your DVDs, the BCH codes in deep-space telemetry, and the CRC checksums
in every network packet are all cyclic.

Inside a code, some words are more "generic" than others. A word has **full
Hamming weight** if *none* of its coordinates is zero — every hour on the clock
shows a nonzero symbol. Full-weight words are the maximally spread-out members of
a code, using every coordinate at once. A natural question:

> Does every nonzero cyclic code contain at least one full-weight word?

Sometimes yes, sometimes no. Over the binary alphabet with $n = 3$, the
*even-weight code* — all binary triples whose entries sum to zero — is cyclic and
nonzero, yet its only words are $000, 110, 101, 011$. The all-ones word $111$,
the sole full-weight candidate, is missing. So the answer here is *no*.

## The surprise: they are the same question

The two puzzles come from different worlds. One is about *covering* an entire
space by rotating into a fixed subspace; the other is about the *internal
richness* of rotation-invariant codes. Yet the central theorem of this work is
that they are, precisely, two faces of one coin:

> **Bridge Theorem.** For every alphabet size $q$ (a prime power) and every
> length $n$, the covering codimension vanishes,
> $$h_q(n) = 0,$$
> **if and only if** every nonzero cyclic code in $q$-ary words of length $n$
> contains a full-weight codeword.

In words: the most rigid possible covering behavior is *exactly* equivalent to
the most generous possible code behavior. Rotations can be starved of room to
maneuver precisely when codes are guaranteed to be rich enough to contain a
fully spread-out word.

## How the two worlds are wired together

The connecting cable is a construction with the flavor of a Fourier transform.
Fix a "test vector" $a$ and define a map $\Phi_a$ that sends a word $x$ to a new
word whose $k$-th coordinate records the inner product of $a$ against the
$k$-fold rotation of $x$:
$$\Phi_a(x)_k \;=\; \langle a,\; \mathrm{rot}^k(x)\rangle \;=\; \sum_i a_i\, x_{i+k}.$$
This is nothing but the sliding correlation of $x$ against $a$ — the same
operation a radar uses to detect an echo at every possible delay $k$.

Two facts make $\Phi_a$ the perfect translator.

**First, its output is always a cyclic code.** Rotating the input $x$ merely
rotates the output $\Phi_a(x)$, so the set of all outputs is closed under
rotation. The image of $\Phi_a$ is therefore automatically a cyclic code — and
as $a$ ranges over all test vectors, these images sweep out every cyclic code.

**Second — the heart of the matter — a covering statement about $a$ translates
into a full-weight statement about the code.** Consider the hyperplane
$\{x : \langle a, x\rangle = 0\}$, the words orthogonal to $a$. Then:

> The hyperplane $\{\langle a,\cdot\rangle = 0\}$ is cyclically covering **if and
> only if** the cyclic code $\Phi_a(V)$ contains *no* full-weight word.

The reason is almost a tautology once the definitions are unfolded. Saying the
hyperplane is covering means: for every word $x$ there is some rotation $k$ with
$\langle a, \mathrm{rot}^k(x)\rangle = 0$ — that is, the output word $\Phi_a(x)$
has a zero somewhere. Having a zero somewhere is exactly the negation of full
weight. So "every input can be rotated into the hyperplane" says precisely
"every output word of $\Phi_a$ has a zero coordinate," i.e. no output is
full-weight. The covering property of a hyperplane and the full-weight-freeness
of a code are the *same statement*, read from two directions.

## Closing the loop

With this dictionary in hand, both directions of the Bridge Theorem fall out
cleanly.

**If codes are always rich, covering is rigid.** Suppose every nonzero cyclic
code has a full-weight word, and imagine, for contradiction, some *proper*
covering subspace $U$. Any proper subspace lies inside a hyperplane, and enlarging
a covering set keeps it covering, so we get a covering hyperplane
$\{\langle a,\cdot\rangle = 0\}$ with $a \neq 0$. By the dictionary, the cyclic
code $\Phi_a(V)$ has no full-weight word. But $\Phi_a(V)$ is a genuine nonzero
cyclic code, so by assumption it *must* contain a full-weight word —
contradiction. Hence no proper covering subspace exists, and $h_q(n) = 0$.

**If covering is rigid, codes are rich.** Conversely, suppose $h_q(n) = 0$ and
take any nonzero cyclic code $C$; pick a nonzero word $c$ inside it. Feed the
*reversal* of $c$ (the word read backwards around the clock) into the machine as
the test vector. A short computation shows that every output of $\Phi_{\mathrm{rev}(c)}$
is a linear combination of rotations of $c$ — and since $C$ is closed under
rotation and addition, all of these outputs live inside $C$. If $C$ had no
full-weight word, then neither would the output code, and the dictionary would
declare the corresponding hyperplane covering. But a covering hyperplane is a
*proper* covering subspace, impossible when $h_q(n) = 0$. So $C$ must contain a
full-weight word after all.

The reversal trick is the one subtlety: it is what lets us aim the correlation
machine at a *prescribed* code $C$ rather than merely reading off whatever code
the machine happens to produce. With it, the correspondence becomes a perfect
two-way bridge.

## Why the small example is not a coincidence

Return to binary words of length $3$. We saw the even-weight code has no
full-weight word, so the full-weight property *fails*. The Bridge Theorem then
guarantees, without any further computation, that $h_2(3) \neq 0$ — there *must*
exist a proper covering subspace. Notably, the even-weight code $\{x_0+x_1+x_2=0\}$
is *not* itself the covering witness: rotation preserves the coordinate sum, so a
word with odd sum (such as $111$) can never be rotated into it. The theorem's
construction instead points to a *different* hyperplane. Pick any nonzero word of
the even-weight code, say $c = 110$, and reverse it around the clock to get
$a = 101$; the orthogonal hyperplane $\{x_0 + x_2 = 0\}$ turns out to be
cyclically covering. Concretely, for every binary triple $x$ there is a rotation
$k$ with $x_k = x_{k+2}$, which is exactly the condition to land in this
hyperplane. It has codimension $1$, so $h_2(3) \geq 1$, and a dimension count
pins down $h_2(3) = 1$. The theorem converts a concrete failure of code-richness
into a concrete covering subspace, and vice versa — but through the reversal, not
by using the deficient code directly.

More generally, whenever the length $n$ shares a factor with the alphabet
characteristic — or, in ring-theoretic terms, whenever $x^n - 1$ has a repeated
factor — the ambient space develops "degenerate" cyclic codes like the
even-weight code, code-richness fails, and $h_q(n)$ jumps to at least $1$. When
$n$ and $q$ are coprime and the arithmetic is clean, code-richness can be
restored and $h_q(n)$ can collapse back to $0$. The Bridge Theorem is the exact
accounting identity behind these phenomena.

## The bigger picture

Correlation, rotation, orthogonality, spread-out signals — these are the raw
ingredients of signal processing, radar, and coding theory. What this work
reveals is that a purely *geometric* extremal quantity (how much can you
constrain a subspace and still cover the space by rotating into it?) and a purely
*combinatorial* code property (must a rotation-invariant code always contain a
maximally spread word?) are not merely analogous — they are logically
equivalent, tied together by a single correlation transform and a reversal.

Bridges like this are the connective tissue of mathematics. They let a hard
question in one language become an easy question in another, and they let
concrete examples on one side manufacture concrete examples on the other. The
covering number $h_q(n)$ has been studied for its own sake in combinatorics; the
full-weight question is bread-and-butter coding theory. The Bridge Theorem shows
that anyone computing one has, without realizing it, been computing the other all
along.
