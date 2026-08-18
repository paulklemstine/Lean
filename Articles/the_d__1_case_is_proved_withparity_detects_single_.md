# The Geometry of Mistakes

*How a handful of counting arguments in a cube of zeros and ones decides
exactly which error-correcting codes can exist — and which cannot.*

---

## A message with a bruise

Send a string of bits across a noisy channel — a scratched disc, a radio
link to a spacecraft, a flash cell holding charge for a decade — and
some of the bits arrive wrong. You cannot stop this. What you *can* do
is arrange in advance that wrong strings are recognisably wrong, and
even that the right string can be recovered.

The whole theory rests on one idea: **distance**. Given two binary words
of the same length, say $x = 1011001$ and $y = 1001011$, count the
positions where they disagree — here positions $3$, $6$ and $7$, so the
*Hamming distance* is $d(x,y) = 3$. The $2^n$ binary words of length $n$
with this distance form a metric space, the **Hamming cube**. Noise
moves a word a short way through the cube; error correction is the art
of scattering codewords so far apart that noise can never carry one into
the neighbourhood of another.

A **code** $C$ of length $n$ is a set of binary words of length $n$. Its
**minimum distance** is
$$d = \min\{\, d(x,y) \;:\; x,y \in C,\; x \neq y \,\},$$
and everything about the code's error-handling power sits in this one
number. If $d \geq 2$, no single flip turns one codeword into another,
so single errors are always *detected*. If $d \geq 3$, no single flip
even brings a codeword closer to a *different* codeword than to its own,
so single errors are *corrected*. In general a code of minimum distance
$d$ detects $d - 1$ errors and corrects $\lfloor (d-1)/2 \rfloor$.

The central question of the subject is brutally simple to state and
notoriously hard to answer:

> **How many codewords of length $n$ can you have, if all of them must
> be at distance at least $d$ from one another?**

Write $A(n,d)$ for the answer. Almost the whole of combinatorial coding
theory is a campaign to pin down this function: upper bounds, lower
bounds, exact values, a classification of the best error-*detecting*
codes, and an arithmetic criterion deciding when the very best codes —
the *perfect* ones — exist at all.

---

## Balls, and how big they are

The first thing to do with a metric space is count balls. The ball of
radius $r$ around a word $c$ of length $n$ is the set of words within
distance $r$ of it. To be at distance exactly $i$ from $c$, a word must
disagree with $c$ in some choice of $i$ coordinates out of $n$ — and
every such choice gives a different word. So:

> **Ball Counting Lemma.** For every word $c$ of length $n$ and every
> radius $r$, the number of length-$n$ words within Hamming distance $r$
> of $c$ is
> $$V(n,r) \;=\; \sum_{i=0}^{r} \binom{n}{i}.$$

Two features matter enormously. First, the answer does not depend on the
centre: the Hamming cube is *homogeneous*, every point looks like every
other. Second, the proof is a recursion that reappears throughout the
theory. Peel off the first letter. A word within distance $r$ of
$c = b\,c'$ either starts with $b$, its tail then within $r$ of $c'$, or
starts with the other letter, its tail then within $r-1$ of $c'$. Hence
$$V(n+1, r) = V(n,r) + V(n, r-1),$$
which is Pascal's rule for partial binomial sums. Peeling the first
coordinate is the organising principle of the whole subject: it proves
ball counts, it proves connectivity of the cube, and it underwrites the
classification theorem below.

From the Ball Counting Lemma the first great bound is one line away.

> **Sphere-Packing (Hamming) Bound.** If $C$ is a code of length $n$
> with minimum distance at least $2t+1$, then
> $$|C| \cdot \sum_{i=0}^{t} \binom{n}{i} \;\leq\; 2^{n}.$$

Why? Because the balls of radius $t$ around distinct codewords are
*disjoint*. If a word $z$ lay in two of them, around $x$ and around $y$,
the triangle inequality would give $d(x,y) \le d(x,z) + d(z,y) \le 2t$,
contradicting the minimum distance. Disjoint sets inside a universe of
$2^n$ words cannot have total size more than $2^n$, and each has size
$V(n,t)$ by homogeneity. Done.

(A warning that is not pedantry: the triangle inequality genuinely
requires equal lengths. Compare a short word with a long one, inspecting
only the overlapping prefix, and it fails outright. Every distance
statement here is guarded by an equal-length hypothesis, and must be.)

A code making the sphere-packing inequality an *equality* is called
**perfect**. Its balls do not merely pack the cube — they tile it. Every
received word lies in exactly one ball, so the decoder never guesses.
Perfect codes are the crown jewels, and which ones exist is the
number-theoretic heart of this story.

---

## The cheapest useful code in the world

Before the jewels, the workhorse. Take any word $l$ of length $n$ and
append one extra bit: the **parity** of $l$, the XOR of all its letters.
Call the result $\widehat{l}$; the $2^n$ extended words form the
**parity code** of length $n+1$. Every reader has used this — the parity
bit of a serial line, the check digit of a barcode, the checksum bolted
onto a memory word. Three facts pin it down completely.

> **Parity is the mod-$2$ shadow of distance.** Two words of the same
> length have equal parity if and only if the Hamming distance between
> them is even.

That single observation does most of the work. Every extended word has
parity $0$, so any two codewords are at even distance; being distinct,
that distance is at least $2$. So the parity code detects every single
bit flip: a word at distance $1$ from a codeword has odd parity and is
instantly recognised as corrupt.

> **It cannot do better than detect.** For $n \geq 1$ two codewords sit
> at distance exactly $2$, with a received word halfway between them, at
> distance $1$ from each. Nothing can break the tie: the parity code
> detects one error and corrects none, and that is a fact about the
> geometry, not a defect of the decoder.

> **Optimality.** No code of length $n+1$ with minimum distance $2$ has
> more than $2^n$ words.

The proof is a perfect miniature. Delete the last coordinate of every
codeword. Two codewords colliding under deletion would differ in at most
that position, so at distance $1$ — impossible. Deletion is injective,
and the code embeds into the $2^n$ shorter words. The parity code
attains this: $A(n+1, 2) = 2^{n}$.

---

## Only two ways to be perfect at detecting

Attainment always raises the sharper question: *is the optimum unique?*

Alongside the parity (even-weight) code sits its shadow, the
**odd-weight code**: all words of length $n+1$ of parity $1$. There are
also $2^n$ of these, and the same evenness argument gives them minimum
distance $2$. So there are at least two optima — and no others.

> **Classification of Optimal Detecting Codes.** Let $C$ be a code of
> length $n+1$ with minimum distance $2$ and $|C| = 2^n$ words. Then $C$
> is either the even-weight code or the odd-weight code.

This is a rigidity theorem: the checksum you attach to a payload has no
freedom at all beyond a global flip. The argument runs in three moves,
and the third is the pretty one.

*Move 1 — puncturing is a bijection.* Deleting the last coordinate is
injective, as above, and now there are $2^n$ codewords landing among
$2^n$ shorter words, so it is a bijection. Every payload $l$ of length
$n$ has exactly one codeword $F(l) = l \, p(l)$ above it, carrying some
checksum bit $p(l)$.

*Move 2 — the parity of a codeword cannot change along an edge.* Let
payloads $x$ and $y$ differ in exactly one place. Their codewords
already differ there, so if the checksum bits agreed the codewords would
be at distance $1$ — forbidden; the checksum bits differ. But the
payload parities also differ, $x$ and $y$ being at odd distance. Two
flips: the codeword's total parity is unchanged. So
$l \mapsto \text{parity}(F(l))$ is constant along every edge.

*Move 3 — the cube is connected.* Here is the graph-theoretic
ingredient, proved by the very same peel-the-first-coordinate recursion
that gave the ball count:

> **Connectivity of the Hamming Cube.** Any function on the words of
> length $n$ that takes equal values on words at distance $1$ is
> constant.

So all codewords share a parity, they lie in one of the two weight
classes, and since that class also has $2^n$ elements the code fills it.
(The size hypothesis is essential: without it any subset of the parity
code would be a counterexample.)

---

## The cube is a group

Underneath the metric there is algebra. Combine two words coordinatewise
by XOR, written $x \oplus y$. This makes the Hamming cube an abelian
group, and the metric respects it perfectly:
$$d(x,y) = w(x \oplus y), \qquad d(x \oplus z,\, y \oplus z) = d(x,y),$$
where the **weight** $w(x)$ counts the ones in $x$. Distance is the
weight of the difference, and translation is an isometry. The Hamming
cube is a *metric group*.

Call a code **linear** if it contains the all-zero word and is closed
under $\oplus$. Then a quadratic condition collapses to a linear one:

> **Minimum Distance Equals Minimum Nonzero Weight.** For a linear code
> $C$ of length $n$, the minimum distance is at least $d$ if and only if
> every nonzero codeword has weight at least $d$.

Forward: $d(x, 0) = w(x)$. Backward: translation invariance gives
$d(x,y) = d(x \oplus y, 0) = w(x \oplus y)$, and $x \oplus y = 0$ exactly
when $x = y$. The saving is dramatic — $|C| - 1$ weights instead of
$\binom{|C|}{2}$ comparisons. The zero word is genuinely needed: a
translate of a linear code has all the same distances but no zero word,
and its weights then say nothing at all.

The parity code is exactly the set of even-weight words of length $n+1$,
which makes its linearity obvious: even XOR even is even.

---

## Squeezing $A(n,d)$ from both sides

Sphere packing bounds $A(n,d)$ from above using ball volumes. Three
further bounds complete the picture.

> **Singleton Bound.** A code of length $n$ with minimum distance
> $d \geq 1$ has at most $2^{\,n+1-d}$ words.

Proof by *puncturing*: keep only the first $k = n+1-d$ coordinates of
each codeword. If two codewords agreed on that prefix they would differ
only in the last $d-1$ places, contradicting minimum distance $d$. So
truncation is injective into a set of $2^{k}$ words. (Read with
truncated subtraction the statement stays correct when $d > n+1$, where
it says $|C| \le 1$ — and indeed a code whose minimum distance exceeds
its length has one word.)

> **Gilbert–Varshamov Bound.** For every $n$ and every $d \geq 1$ there
> *exists* a code $C$ of length $n$ with minimum distance $d$ satisfying
> $$|C| \cdot \sum_{i=0}^{d-1} \binom{n}{i} \;\geq\; 2^{n}.$$

This is the exact converse of sphere packing, and its proof is pure
greed. Pick a code of length $n$ with minimum distance $d$ that is
*maximal* — no further word can be added. Then every word is within
distance $d-1$ of some codeword, or it could have been added. So the
radius-$(d-1)$ balls *cover* the cube, and counting gives the bound.
Packing says radius-$t$ balls don't overlap; greed says radius-$(d-1)$
balls leave no gaps. Together,
$$\frac{2^{n}}{V(n,d-1)} \;\leq\; A(n,d) \;\leq\; 2^{\,n+1-d},$$
and the whole subject lives between these two walls.

The last bound handles the regime where sphere packing is useless: when
$d$ is large relative to $n$, the radius-$t$ balls exceed the cube and
the inequality says nothing. There **double counting** takes over.

> **Plotkin Bound.** If $C$ is a code of length $n$ with minimum
> distance $d$ and $n < 2d$, then
> $$|C| \cdot (2d - n) \;\leq\; 2d, \qquad\text{so in particular}\qquad
> |C| \le 2d.$$

Count the total pairwise distance $S = \sum_{x,y \in C} d(x,y)$ twice.
From below, every ordered pair of distinct codewords contributes at
least $d$: $S \geq d\,M(M-1)$, where $M = |C|$. From above, write the
distance as a sum over coordinates: at coordinate $j$, if $k_j$
codewords carry a $1$, the ordered disagreeing pairs number exactly
$2k_j(M - k_j) \le M^2/2$, since $4k(M-k) \le M^2$ is $(M-2k)^2 \ge 0$
in disguise. Summing, $2S \le n M^2$. Squeezing gives Plotkin.

A pleasing methodological point: the distance can be viewed
*recursively*, by peeling coordinates, or *globally*, as a sum over
positions. Packing wants the recursion, double counting wants the sum,
and both views of the same metric are indispensable.

---

## Which perfect codes can exist?

Now the jewels. Suppose $C$ is a **perfect single-error-correcting** code
of length $n$: minimum distance $3$, with the radius-$1$ balls around its
codewords tiling the cube. Each such ball holds $V(n,1) = n+1$ words, so
$$|C| \cdot (n+1) = 2^{n}.$$
Immediately $n+1$ divides $2^n$; and a divisor of a power of two is a
power of two. Hence:

> **Arithmetic Obstruction.** If a perfect single-error-correcting
> binary code of length $n$ exists, then $n + 1 = 2^{k}$ for some $k$.

So perfect codes live only in lengths $1, 3, 7, 15, 31, \dots$ In
particular **there is no perfect single-error-correcting binary code of
length $4$**: no construction will ever be found, because $5$ is not a
power of two. Better still, when $n+1$ is not a power of two the
sphere-packing bound is *strictly* unattainable.

Is the condition sufficient? Yes — and the construction is beautiful.
Here is the classical **Hamming code** of order $k$, without a single
matrix.

Number the coordinates of a word of length $2^k - 1$ by
$1, 2, \dots, 2^k - 1$: exactly the nonzero binary strings of $k$ bits.
The **syndrome** of a word is the bitwise XOR (as natural numbers) of
the indices of the positions carrying a $1$, and the Hamming code
$\mathcal{H}_k$ is the set of words with syndrome $0$. Everything falls
out of two elementary facts about XOR.

*It is a homomorphism:* the syndrome of $x \oplus y$ is the XOR of the
syndromes, so $\mathcal{H}_k$ is linear. (It also means the syndrome of
a corrupted codeword depends only on the error, not on what was sent.)

*Distinct nonzero indices never cancel:* $a \oplus b = 0$ only when
$a = b$. So a word of weight $1$ has syndrome a nonzero index, and one
of weight $2$ has syndrome the XOR of two distinct nonzero indices,
again nonzero. No nonzero codeword has weight $1$ or $2$; by the
minimum-weight criterion, the minimum distance of $\mathcal{H}_k$ is at
least $3$. (Classically this *is* the requirement that the columns of
the parity-check matrix be distinct and nonzero — here it is a one-line
property of XOR.)

*Syndromes are legal positions:* the XOR of numbers below $2^k$ is below
$2^k$, so the syndrome $v$ of a received word satisfies $v \le 2^k - 1$.
If $v = 0$ the word is a codeword; otherwise flipping position $v$
changes the syndrome by $v$, zeroing it. Every word is therefore within
distance $1$ of a codeword, and decoding is literally: *compute the
syndrome, flip that position*.

> **Perfect Codes Exist Exactly in the Admissible Lengths.** A perfect
> single-error-correcting binary code of length $n$ exists if and only
> if $n + 1$ is a power of two. For $n = 2^k - 1$ the Hamming code
> $\mathcal{H}_k$ is such a code, the radius-$1$ balls around its
> codewords tile the cube exactly, and decoding is unique: every
> received word has exactly one codeword within distance $1$.

Its size is not an input but an output: the tiling plus the ball count
force $|\mathcal{H}_k| \cdot 2^{k} = 2^{\,2^{k}-1}$, so
$|\mathcal{H}_k| = 2^{\,2^k - 1 - k}$. For $k = 3$ this is the famous
$[7,4,3]$ code: sixteen balls of eight words in the $128$-word cube, and
$16 \times 8 = 128$ exactly. For $k = 2$ it degenerates gracefully to
$\{000, 111\}$ — the triple-repetition code, the most elementary
error-correcting code of all, revealed as the smallest Hamming code.

And because sphere packing bounds from above while the Hamming code
attains it, the extremal function is determined exactly:
$$A(2^k - 1,\, 3) = 2^{\,2^k - 1 - k}, \qquad\text{in particular}\qquad
A(7,3) = 16.$$
Upper bound and lower bound shake hands.

---

## Why code tables only list odd distances

One last structural theorem ties the development together, and explains
a curiosity anyone who has read a table of best-known codes will have
noticed: the interesting rows are always the odd distances.

Take a code of *odd* minimum distance $d$ and append a parity bit to
every codeword. What is the new minimum distance? Naively you would hope
for $d$; in fact you always get $d+1$ — but not for the naive reason,
since the parity bit does *not* always disagree. Instead: all distances
in a parity-extended code are even, and an even number that is at least
the odd number $d$ is at least $d+1$. So extension takes $(n,d)$ to
$(n+1, d+1)$ with no loss of codewords.

Conversely, delete the last coordinate of a code of length $n+1$ with
minimum distance $d+1 \geq 2$. Distances drop by at most $1$, and the
deletion is injective. So puncturing takes $(n+1, d+1)$ back to $(n,d)$
with no loss of codewords. Combining:

> **Odd/Even Collapse.** For every odd $d$ and every $n$,
> $$A(n, d) = A(n+1, d+1).$$

Extension and puncturing are mutually inverse on *optimal* codes, so
every odd-distance result yields an even-distance twin for free. From
the trivial $A(n,1) = 2^n$ we get a second, purely structural proof that
$A(n+1,2) = 2^{n}$ — the parity code is optimal, no counting required.
From $A(7,3) = 16$ we get $A(8,4) = 16$: the *extended* Hamming code is
optimal at length $8$. In general
$$A(2^k, 4) = A(2^k - 1, 3) = 2^{\,2^k - 1 - k}.$$

The oddness is not decoration. For even $d$ the collapse fails:
$A(3,2) = 4$, while sphere packing gives $A(4,3) \le 3$ (balls of radius
$1$ in the $4$-cube hold $5$ words, and $|C| \cdot 5 \le 16$). So
$A(4,3) < A(3,2)$: no distance-$2$ optimum at length $3$ extends to a
distance-$3$ code at length $4$. Puncturing works unconditionally,
giving $A(n+1,d+1) \le A(n,d)$ always and, iterated, the
Singleton-style decay $A(n+j, d+j) \le A(n,d)$; only the *extension*
half needs oddness. The slogan: **odd distances are the primitive
ones** — which is exactly why the sphere-packing bound is naturally
stated at $d = 2t+1$.

---

## What the whole thing looks like from a distance

Step back and the architecture is remarkably economical. One recursion —
peel the first coordinate — yields the ball count and the connectivity
of the cube. Ball counting yields sphere packing above and, via greedy
maximality, Gilbert–Varshamov below. Splitting a word into blocks yields
Singleton; double counting yields Plotkin, covering the regime the
others miss. The equality case of packing converts counting into tiling,
tiling into divisibility, and divisibility — a divisor of $2^n$ is a
power of two — rules out infinitely many lengths at a stroke, while the
syndrome-as-XOR construction shows the survivors all work.

That such definite answers exist at all is the striking thing. "How many
messages can I send reliably?" sounds like a question with only
asymptotic, approximate answers. Instead one gets $A(7,3) = 16$ on the
nose, $A(8,4) = 16$ on the nose, an exact description of every optimal
single-error-detecting code, and an arithmetic criterion deciding, for
each of infinitely many lengths, whether a perfect code exists.

The Hamming code was found in 1950 by a frustrated researcher whose
weekend batch jobs kept dying on single-bit errors. Seventy-five years
later every constraint above still binds every code ever built, and the
geometry producing them — disjoint balls, tiled cubes, XOR as a group
law — has not aged a day. When your phone repairs a corrupted frame, or
a probe past Neptune gets its picture through, the reason it works is
that somebody counted the points in a ball.
