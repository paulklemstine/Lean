# The Geometry of Mistakes
### A guided tour of binary codes: how far apart can messages be, and how far apart must they be?

Every message you have ever received arrived slightly wrong. A cosmic ray flips a
bit in a memory cell; a scratch swallows a pit on a disc; a radio link to a probe
past Neptune drops a symbol in the noise. You cannot prevent this. What you can do
is arrange, in advance, that wrong messages are *recognisably* wrong — and, if you
are willing to pay a little more, that the right message can be reconstructed from
the wrong one.

This page is a tour of the mathematics that decides how much that costs. By the end
you will know exactly how many messages you can send over a noisy channel, why the
answer is sometimes a beautiful round number and sometimes stubbornly unknown, and
why there is a code of length $7$ that is *perfect* while no code of length $4$ can
ever be.

---

## 1. Distance is everything

Fix a length $n$ and consider all $2^n$ binary words of that length. Given two of
them, count the positions where they disagree. That count is the **Hamming
distance**:

$$d(1011001,\; 1001011) = 3,$$

because the words differ in positions $3$, $6$ and $7$. The $2^n$ words with this
distance form the **Hamming cube** — a metric space in which noise is movement.
A single bit flip moves you a distance of $1$.

A **code** $C$ is any set of words, its members called **codewords**. Its
**minimum distance** $d$ is the smallest distance between two distinct codewords,
and it alone determines what the code can do:

- $d \ge 2$: no single flip turns a codeword into another codeword, so **every
  single error is detected**;
- $d \ge 3$: no single flip brings a codeword closer to a *different* codeword than
  to its own, so **every single error is corrected**;
- in general, a code of minimum distance $d$ detects $d-1$ errors and corrects
  $\lfloor (d-1)/2 \rfloor$ of them.

So error correction is a packing problem: scatter as many points as possible in the
cube while keeping them all far apart. Write

$$A(n,d) = \text{the largest possible size of a length-}n\text{ code with minimum distance }d.$$

Almost the entire subject is a campaign to pin down this one function.

<details>
<summary><b>A subtlety worth flagging before we start</b></summary>

Everything below compares words of the *same* length. That is not pedantry. If you
allow yourself to compare words of different lengths — inspecting only the
positions where both are defined — then the triangle inequality fails outright:
with $x = 00$, $y = 11$ and $z$ the empty word, $d(x,y) = 2$ while
$d(x,z) + d(z,y) = 0$. Since sphere packing is *nothing but* the triangle
inequality, every statement here carries an equal-length hypothesis, and it is
load-bearing.
</details>

---

## 2. Count the points in a ball

The first thing to do in a metric space is measure balls. The ball of radius $r$
around a word $c$ of length $n$ is everything within distance $r$ of it. To be at
distance exactly $i$ you must disagree with $c$ in some choice of $i$ coordinates
out of $n$, and each choice gives a distinct word. Hence the

> **Ball Counting Lemma.** For every centre $c$ of length $n$,
> $$V(n,r) \;=\; \sum_{i=0}^{r}\binom{n}{i}$$
> words lie within distance $r$ of $c$. The answer does not depend on $c$: the cube
> is homogeneous, every point looks like every other.

<details>
<summary><b>The proof — peel the first letter (this recursion will reappear everywhere)</b></summary>

Write $c = b\,c'$. A word $z = a\,z'$ is within $r$ of $c$ exactly when either
$a = b$ and $z'$ is within $r$ of $c'$, or $a \neq b$ and $z'$ is within $r-1$ of
$c'$. The two cases are disjoint because they differ in the leading letter, so

$$V(n+1,r) \;=\; V(n,r) + V(n,r-1),$$

which is precisely Pascal's rule for partial sums of binomial coefficients. The
base cases ($r=0$, or $n=0$) each give a single word.

"Peel the first coordinate" is the organising principle of the whole subject. It
proves the ball count; later it will prove that the cube is *connected*, which is
what makes the classification theorem in §7 work.
</details>

And now the first great bound is one line away. If a code has minimum distance
$2t+1$, the radius-$t$ balls around its codewords cannot overlap — an overlap would
put two codewords within $2t$ of each other. Disjoint sets in a universe of $2^n$
words give:

> **Sphere-Packing (Hamming) Bound.**
> $$|C| \cdot \sum_{i=0}^{t}\binom{n}{i} \;\le\; 2^{n}.$$

A code achieving equality is called **perfect**: its balls do not merely pack the
cube, they *tile* it. Every received word lies in exactly one ball, so the decoder
never has to guess. Perfect codes are the crown jewels of the subject, and §6 will
determine exactly which ones exist.

---

## 3. Four arguments, four regimes — explore them

Sphere packing is one of four constraints on $A(n,d)$, and each owns a different
corner of the parameter space. Rather than describe them, let me hand them to you.
Move the sliders; watch the "strongest" badge jump from one argument to another as
the distance grows relative to the length.

{{interactive_demo:1}}

The four arguments, in brief:

**Sphere packing** (above) — the packing constraint. Strongest when $d$ is small
relative to $n$, and completely vacuous once $2d > n$, because then the balls are
bigger than the cube.

**Singleton** — keep only the first $n+1-d$ coordinates of each codeword. Two
codewords agreeing on that prefix would differ only in the last $d-1$ places,
contradicting the minimum distance. So truncation is injective and
$$|C| \;\le\; 2^{\,n+1-d}.$$

**Plotkin** — for the high-distance regime $n < 2d$, count the total pairwise
distance twice over:
$$|C|\,(2d-n) \;\le\; 2d, \qquad\text{hence}\qquad |C| \le 2d,$$
a bound that does not mention the length at all.

<details>
<summary><b>The double count behind Plotkin, in full</b></summary>

Let $S = \sum_{x,y \in C} d(x,y)$, the total distance over ordered pairs, and
$M = |C|$.

*From below.* Every ordered pair of distinct codewords contributes at least $d$,
and there are $M(M-1)$ of them, so $S \ge d\,M(M-1)$.

*From above.* Write the distance as a sum over coordinates. At coordinate $j$, let
$k_j$ be the number of codewords carrying a $1$. The ordered disagreeing pairs at
that coordinate number exactly $2k_j(M - k_j)$, and
$$4k(M-k) \le M^{2}$$
because, writing $M = k+f$, this is $4kf \le (k+f)^2$, i.e. $(k-f)^2 \ge 0$.
Summing over the $n$ coordinates, $2S \le n M^2$.

*Squeeze.* $2dM(M-1) \le 2S \le nM^2$. Divide by $M$: $2d(M-1) \le nM$, i.e.
$M(2d-n) \le 2d$. When $n < 2d$ the factor $2d-n$ is at least $1$, so $M \le 2d$.

Notice the methodological point. The ball count wanted the metric *recursively*
(peel a coordinate); the double count wants it *globally* (sum over coordinates).
Both views of the same function are indispensable, and it matters that they are two
descriptions of one object.
</details>

**Gilbert–Varshamov** — the only bound pointing the other way, and the only
*existence* statement of the four. It is pure greed:

> Among all codes of length $n$ with minimum distance $d$, take a maximal one — one
> to which no word can be added. Then every word of the cube is within $d-1$ of
> some codeword, or it could have been added. So the radius-$(d-1)$ balls *cover*,
> and $2^n \le |C| \cdot V(n,d-1)$.

Sphere packing says balls of radius $t$ do not overlap; Gilbert–Varshamov says balls
of radius $d-1$ leave no gaps. Together they bracket the answer:

$$\frac{2^n}{V(n,d-1)} \;\le\; A(n,d) \;\le\; 2^{\,n+1-d}.$$

The whole subject lives inside that corridor. Here it is drawn, together with a map
of which argument wins where:

{{visualization:0}}

The Gilbert–Varshamov proof is not merely an existence argument — it is an
algorithm, and you can run it:

{{algorithm:1}}

---

## 4. The cheapest useful code in the world

Before the jewels, the workhorse. Take any word $l$ of length $n$ and append one
extra bit: the **parity** of $l$, the XOR of all its letters. Call the result
$\widehat{l}$, and let the **parity code** be the set of all $2^n$ such extensions.

You have used this. It is the parity bit on a serial line, the check digit on a
barcode, the checksum bolted onto a memory word. One observation makes it work:

> **Parity is the mod-$2$ shadow of distance.** Two words of the same length have
> equal parity if and only if their Hamming distance is even.

Every extended word has parity $0$, so any two codewords are at even distance,
hence at distance at least $2$. Therefore **every single flip is detected**: a
corrupted word has odd parity and is instantly recognised. Equally, the code
**cannot correct**: two codewords sit at distance exactly $2$, and a received word
halfway between them is at distance $1$ from each. The decoder has no way to break
the tie, and that is a fact about the geometry, not a failure of engineering.

And it is optimal. Delete the last coordinate of every codeword: if two codewords
collided they would differ only in that position, at distance $1$ — impossible. So
deletion embeds the code into the $2^n$ shorter words, giving

$$A(n+1, 2) \;=\; 2^{n}.$$

---

## 5. The cube is a group, and linearity buys you a lot

Underneath the metric there is algebra. Combine words coordinatewise with XOR,
written $x \oplus y$; let $w(x)$ count the ones. Then

$$d(x,y) = w(x \oplus y), \qquad d(x \oplus z,\; y \oplus z) = d(x,y).$$

Distance is the weight of the difference, and translation is an isometry: the
Hamming cube is a **metric group**. Call a code **linear** if it contains the
all-zero word and is closed under $\oplus$. Then:

> **Minimum distance equals minimum nonzero weight.** For a linear code, the
> minimum distance is at least $d$ if and only if every nonzero codeword has weight
> at least $d$.

A quadratic condition ($\binom{|C|}{2}$ pairwise comparisons) collapses into a
linear one ($|C|-1$ weights). The parity code turns out to be exactly the set of
even-weight words, which makes its linearity obvious: even XOR even is even.

<details>
<summary><b>Why the zero word must be in the code</b></summary>

Forward direction: for nonzero $x$ in the code, $d \le d(x, 0) = w(x)$. Backward:
for distinct $x,y$, closure gives $x \oplus y$ in the code, it is nonzero because
$x \neq y$, and translation invariance gives
$d(x,y) = d(x \oplus y, 0) = w(x \oplus y) \ge d$.

Drop the zero word and the backward direction dies. A *coset* $a \oplus C$ of a
linear code has exactly the same distances but no zero word, and its weights carry
no information whatever about its minimum distance. The demo below exhibits this
explicitly: shifting the $[7,4,3]$ code by a fixed word leaves the minimum distance
at $3$ while the minimum weight drops to $1$.
</details>

---

## 6. Perfection is an arithmetic question

Now the jewels. Suppose $C$ is a perfect single-error-correcting code of length $n$:
minimum distance $3$, and radius-$1$ balls that tile the cube. Each ball holds
$V(n,1) = n+1$ words, so
$$|C| \cdot (n+1) \;=\; 2^{n}.$$
Immediately $n+1$ divides $2^n$; and a divisor of a power of two is a power of two.

> **Arithmetic obstruction.** A perfect single-error-correcting binary code of
> length $n$ can exist only if $n+1 = 2^{k}$.

One line eliminates infinitely many lengths at a stroke. In particular there is **no
perfect code of length $4$**, and no clever construction will ever be found, because
$5$ does not divide $16$. Here is that fact, drawn, alongside the tiling that does
exist at length $7$:

{{visualization:1}}

Is the condition *sufficient*? Yes, and the construction is lovely — no matrices
required. Number the coordinates of a word of length $2^k-1$ by
$1, 2, \dots, 2^k-1$: these are exactly the nonzero $k$-bit patterns. Define the
**syndrome** of a word to be the bitwise XOR of the *indices* of the positions
carrying a $1$. The **Hamming code** $\mathcal{H}_k$ is the set of words with
syndrome $0$.

Play with it. Build a codeword, break it, and watch the syndrome name the broken
coordinate:

{{interactive_demo:0}}

<details>
<summary><b>Why the construction works — two facts about XOR</b></summary>

**XOR is additive**, so the syndrome of $x \oplus y$ is the XOR of the syndromes;
hence the code is linear. Moreover, if a codeword $c$ (syndrome $0$) is hit by an
error pattern $e$, the received word has syndrome exactly $s(e)$: the syndrome sees
the error and nothing else.

**Distinct nonzero indices never cancel**, since $a \oplus b = 0$ only when
$a = b$. So a weight-$1$ word has syndrome equal to a nonzero index, and a
weight-$2$ word has syndrome the XOR of two distinct nonzero indices, again
nonzero. Hence no nonzero codeword has weight $1$ or $2$, and by the linear
criterion of §5 the minimum distance is at least $3$. (In classical language, this
*is* the statement that the columns of the parity-check matrix are distinct and
nonzero — but here it is a one-liner about XOR.)

**Syndromes are legal addresses**, because the XOR of numbers below $2^k$ is below
$2^k$. So a nonzero syndrome $v$ satisfies $v \le 2^k-1$, and flipping coordinate
$v$ changes the syndrome by $v$, zeroing it. Every word is therefore within
distance $1$ of a codeword; combined with disjointness, the balls tile.
</details>

The size of the code is not an input to the construction but an *output*, forced by
the tiling and the ball count:
$$|\mathcal{H}_k| \cdot 2^{k} = 2^{\,2^k - 1}, \qquad\text{so}\qquad |\mathcal{H}_k| = 2^{\,2^k - 1 - k}.$$
For $k=3$: sixteen balls of eight words tiling the $128$-word cube — the famous
$[7,4,3]$ code. For $k=2$ it degenerates gracefully to the triple repetition code
$\{000, 111\}$, revealing the most elementary error-correcting code as the smallest
Hamming code.

Putting the two halves together:

> **A perfect single-error-correcting binary code of length $n$ exists if and only
> if $n+1$ is a power of two.**

And because sphere packing bounds from above while the Hamming code attains it,
$$A(2^k-1,\,3) \;=\; 2^{\,2^k-1-k}, \qquad\text{in particular}\qquad A(7,3) = 16.$$

The decoder is as cheap as error correction gets — one pass, no tables:

{{algorithm:0}}

---

## 7. Only two ways to be a perfect detector

Back to the humble parity code. We know it is optimal; is it *unique*?

Alongside the even-weight code sits its shadow, the **odd-weight code**: all words
of length $n+1$ with an odd number of ones. It also has $2^n$ words, and the same
evenness argument gives it minimum distance $2$. So there are at least two optima.
There are no others.

> **Classification.** A code of length $n+1$ with minimum distance $2$ and exactly
> $2^n$ codewords is either the even-weight code or the odd-weight code.

This is a rigidity theorem: the checksum you attach to a payload has no freedom at
all beyond a single global flip. Everyday practice turns out to be forced.

<details>
<summary><b>The proof in three moves — and the graph theory hiding in the third</b></summary>

**Move 1 — puncturing is a bijection.** Deleting the last coordinate is injective
(as in §4), and $2^n$ codewords land among $2^n$ shorter words, so it is onto. Every
payload $l$ has exactly one codeword $F(l) = l\,p(l)$ above it, carrying a checksum
bit $p(l)$.

**Move 2 — the codeword parity cannot change along an edge.** Let payloads $x$ and
$y$ differ in exactly one place. Their codewords already differ there, so if the
checksum bits agreed the codewords would be at distance $1$ — forbidden. So the
checksum bits differ. But the payload parities also differ, because $x$ and $y$ are
at odd distance. Two flips: the total parity of the codeword is unchanged. So
$l \mapsto \text{parity}(F(l))$ is constant along every edge of the cube.

**Move 3 — the cube is connected.** Here is the graph-theoretic ingredient, proved
by the very same peel-the-first-coordinate recursion that gave the ball count:

> *Any function on the words of length $n$ that takes equal values on words at
> distance $1$ is constant.*

So all codewords share a parity, they all lie in one of the two weight classes, and
since that class also has $2^n$ elements, the code fills it. Two optima, and no
more. (The size hypothesis is essential: any proper subset of the parity code still
has minimum distance $2$.)
</details>

---

## 8. Why code tables only list odd distances

One structural theorem ties the development together, and it explains something
anyone who has read a table of best-known codes will have noticed: the interesting
rows are always the odd distances.

Take a code of *odd* minimum distance $d$ and append a parity bit to every codeword.
What is the new minimum distance? Naively you would hope for $d$; in fact you always
get $d+1$ — but not for the naive reason. The parity bit does *not* always disagree.
Instead: all distances in a parity-extended code are even, and an even number that
is at least the odd number $d$ is at least $d+1$.

Conversely, delete the last coordinate of a code of distance $d+1 \ge 2$: the
deletion is injective and costs at most one unit of distance. So:

> **Odd/even collapse.** For every odd $d$, $\;A(n,d) = A(n+1, d+1)$.

Extension and puncturing are mutually inverse on optimal codes. Every odd-distance
result yields an even-distance twin for free: from the trivial $A(n,1) = 2^n$ we
recover $A(n+1,2) = 2^n$ with no counting at all; from $A(7,3) = 16$ we get
$A(8,4) = 16$, so the *extended* Hamming code of length $8$ is optimal — which is
exactly the "correct one error, detect two" behaviour of ECC memory, and it costs
one extra bit and not a single codeword.

The oddness is not decoration. $A(3,2) = 4$, but sphere packing gives
$A(4,3) \le 3$, so $A(4,3) < A(3,2)$ and the identity is false at even $d$.
Puncturing always works; extension is the fussy half. The slogan: **odd distances
are the primitive ones**, which is exactly why the sphere-packing bound is naturally
stated at $d = 2t+1$.

---

## 9. See it all at once

Two programs. The first walks through every result above and checks it numerically —
ball volumes against the binomial formula, all four bounds against greedily
constructed codes, the parity code and its rigidity by exhaustive search, the linear
criterion, Hamming decoding of every single-bit corruption, the arithmetic
obstruction, and the odd/even collapse:

{{demo:0}}

The second computes $A(n,d)$ *exactly* for small parameters — a maximum-clique
search on the Hamming cube — and puts the true values side by side with the
corridor. You can watch the corridor close precisely where the theory says the value
is determined, and see $A(7,3) = 16 = A(8,4)$ emerge from raw search:

{{demo:1}}

And here is the machinery that evaluates and compares the bounds, if you want to
generate the tables yourself:

{{algorithm:2}}

---

## 10. Where the frontier is

The architecture above is economical: one recursion gives the ball count and the
connectivity of the cube; ball counting gives packing above and greed gives
Gilbert–Varshamov below; block splitting gives Singleton; double counting gives
Plotkin; the equality case of packing turns counting into tiling, tiling into
divisibility, and divisibility into an arithmetic verdict. Three questions sit
immediately beyond it.

**Equality in Plotkin means a Hadamard matrix.** Equality in $|C|(2d-n) \le 2d$ at
$n = 2d-1$ forces every coordinate to split the code exactly in half *and* every
pair of codewords to be at distance exactly $d$. Written as $\pm 1$ vectors, the
codewords are then pairwise orthogonal — precisely a Hadamard matrix. The conjecture
is that $A(2d-1,d) = 2d$ holds exactly when a Hadamard matrix of order $2d$ exists.
The double-count proof already isolates the two inequalities whose equality cases
are needed.

**Binary codes meeting Singleton should be trivial.** A code with
$|C| = 2^{\,n+1-d}$ and $2 \le d \le n$ ought to be either the whole even-weight
code ($d=2$) or the repetition code ($d=n$). In the equality case the puncturing map
is a *bijection*, so every shortening of such a code is again extremal; iterating
reduces any candidate to a length-$d$ code of size $2$.

**The Hamming code should be unique.** For $k \ge 2$, any length-$(2^k-1)$ code with
minimum distance $3$ and $2^{\,2^k-1-k}$ words should equal $\mathcal{H}_k$ up to a
permutation of coordinates. Perfection is automatic; the content is that the tiling
determines the code up to symmetry.

Further out lie the linear-programming bounds (a genuinely different,
harmonic-analytic technique), the classification of *all* perfect binary codes —
where the Golay code $[23,12,7]$ makes its entrance — nonbinary alphabets, where
$V(n,r) = \sum_i \binom{n}{i}(q-1)^i$ and the same architecture goes through
unchanged, and the asymptotic regime, where these bounds become the classical
entropy-rate inequalities. Good places to read on:
[Hamming code](https://en.wikipedia.org/wiki/Hamming_code),
[Singleton bound](https://en.wikipedia.org/wiki/Singleton_bound),
[Gilbert–Varshamov bound](https://en.wikipedia.org/wiki/Gilbert%E2%80%93Varshamov_bound),
[Plotkin bound](https://en.wikipedia.org/wiki/Plotkin_bound),
[perfect codes](https://en.wikipedia.org/wiki/Perfect_code),
[Hadamard matrices](https://en.wikipedia.org/wiki/Hadamard_matrix).

---

Richard Hamming found his code in 1950 after one too many weekend batch jobs died on
a single flipped bit. Three quarters of a century later every constraint on this
page still binds every code ever built, and the geometry that produces them —
disjoint balls, tiled cubes, XOR as a group law — has not aged a day. When your
phone repairs a corrupted frame, the reason it works is that somebody counted the
points in a ball.
