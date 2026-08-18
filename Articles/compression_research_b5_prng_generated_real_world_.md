# The File That Was Never Random

## How a few dozen symbols can prove that a gigabyte was written by a formula

Somewhere on your hard drive there is a file that is not really a file. It looks
like data — megabytes of terrain heights, noise textures, particle positions, a
stream of "random" bytes in a test fixture — but it was never authored. It was
*computed*, from a short recipe and a starting number, by a pseudorandom number
generator. If you knew the recipe and the number, you could throw the file away
and regenerate it perfectly, on demand, from a few bytes.

This is a tantalising idea for anyone who thinks about compression. The
pigeonhole principle puts a hard ceiling on compressing arbitrary data: there
are $q^n$ files of $n$ symbols over an alphabet of size $q$, and no scheme maps
all of them to shorter descriptions. But pseudorandom data is not arbitrary. A
generator with a state space of size $|S|$ can only ever produce $|S|$ distinct
files of any given length. If your file is one of those, its true information
content is $\log_2 |S|$ bits — and the rest is free.

So the dream is a compressor that asks, of every file it meets: *were you
generated?* And if so: *by what, and from what seed?* This article is about
making that question precise, and about the surprisingly sharp answers it
admits. Three of them stand out.

1. **A universal certificate.** For the most important generator family — the
   linear feedback shift register of order $L$ — exactly $2L$ observed symbols
   suffice to certify a recovered generator *forever*. Not "with high
   probability", not "for typical seeds": if two order-$L$ generators, with
   arbitrary taps and arbitrary seeds, agree on their first $2L$ outputs, they
   agree at every index from now to eternity. And $2L-1$ symbols provably do
   not suffice.
2. **A hard ceiling on the whole programme.** Detecting the generator does not
   beat the pigeonhole bound. A "router" that inspects a file, picks any member
   from a whole zoo of generator families, and emits an index plus a seed can
   compress at most $\sum_i |S_i|$ files of each length — the total number of
   seeds across the zoo, and not one file more. Adding families adds their seed
   counts and nothing else.
3. **Noise breaks things in an unexpected way.** Real files are only *nearly*
   generator output — there are headers, checksums, interleaved metadata. The
   natural coding-theoretic guess, that $2L + 2e + 1$ symbols suffice to decode
   uniquely in the presence of $e$ corruptions, is *false* for every error
   budget $e \geq 1$. The correct threshold is not additive but multiplicative:
   $2L(2e+1)$. And that is sharp.

Let us take these in turn.

---

## Generators, streams, and the falsifiability gate

Strip a pseudorandom generator down to its bones and you get two functions: a
**step** map $\mathrm{step} : S \to S$ that advances an internal state, and an
**output** map $\mathrm{out} : S \to \alpha$ that extracts a visible symbol.
Starting from a seed $s$, the generator emits the stream

$$y_t = \mathrm{out}\big(\mathrm{step}^{t}(s)\big), \qquad t = 0, 1, 2, \dots$$

A finite file $x$ of length $n$ is **seed-compressible** for this generator if
some seed reproduces it *exactly*: $y_i = x_i$ for all $i < n$. Exactness is the
point. This is a falsifiable claim in the strictest sense — you decompress, you
compare byte for byte, and either it matches or the claim dies. There is no
partial credit.

Two facts follow immediately, and they set the boundaries of everything else.

**The pigeonhole ceiling.** At most $|S|$ files of length $n$ are
seed-compressible, because the map from seeds to length-$n$ prefixes cannot hit
more targets than it has sources. So as soon as $|S| < q^n$, some file of length
$n$ is *not* seed-compressible; and the fraction a perfect detector accepts —
its false-positive rate on uniformly random data — is at most $|S| / q^n$, which
collapses exponentially as the file grows.

**Finite state means eventual periodicity.** Run any finite-state generator for
$|S|$ steps and the pigeonhole principle forces a repeated state; from that
moment the trajectory cycles, with preperiod plus period at most $|S|$. The
consequence is striking: the *entire infinite stream* is determined by its first
$|S|$ symbols. This is the structural reason seed compression can work at all.

---

## The shift register, and why one recurrence catches two families

The workhorse of practical pseudorandomness is the **linear feedback shift
register**. Its state is a window of $L$ symbols $\sigma_0, \dots, \sigma_{L-1}$
drawn from a ring $K$; each tick, it emits the oldest cell $\sigma_0$, shifts
everything left, and refills the vacated cell with a linear combination
$\sum_j c_j \sigma_j$ of the current window, where $c = (c_0, \dots, c_{L-1})$
is the **tap vector**. Over the two-element field this is the classical binary
LFSR that appears inside stream ciphers, checksums, and any number of
"fast random" routines.

The first thing to establish is the **window lemma**: after $k$ ticks, cell $i$
of the register holds precisely the symbol that will be output at time $i + k$.
The state is not mysterious hidden information — the register is a sliding
window onto its own future output. Everything else is a corollary.

*Corollary one: the fingerprint.* Every stream generated this way satisfies the
order-$L$ linear recurrence

$$y_{t+L} \;=\; \sum_{j=0}^{L-1} c_j \, y_{t+j} \qquad \text{for all } t \geq 0.$$

*Corollary two: detection is exact, in both directions.* A stream $y$ satisfies
this recurrence **if and only if** it is the output of the order-$L$ register
with taps $c$ from *some* seed. The test is sound and complete simultaneously:
it never accepts an impostor and never rejects a genuine member.

*Corollary three: seed recovery is free.* The seed *is* the first $L$ output
symbols — no search, no inversion, no solver. And the recovered seed regenerates
the whole stream exactly, at every index, not merely on the window where you
checked. That is the falsifiability gate, discharged.

Now here is the pleasant surprise. The second great real-world family is the
**linear congruential generator**, $x \mapsto a x + b$ — the engine behind
`rand()`, behind countless game engines, behind a generation of simulation code.
It looks like a different animal: an affine map on a ring, not a shift register.
It is not. Subtract consecutive terms of $x_{t+1} = a x_t + b$ and the increment
$b$ cancels, leaving

$$x_{t+2} \;=\; (a+1)\, x_{t+1} \;-\; a\, x_t,$$

which is exactly the order-two shift-register recurrence with taps $(-a,\,a+1)$.
The full-output congruential generator is an order-two register in disguise. The
same detector catches both families, and the equivalent register seed is
$(x_0,\; a x_0 + b)$ — two observed symbols, and you are done. One pipeline, two
families.

---

## The $2L$ theorem: when is a recovered seed *certain*?

Suppose your detector has looked at a window and reported: *this is an order-$L$
register with taps $c$ and seed $\sigma$.* You now delete the file and keep only
$(c, \sigma)$. When is that safe?

The danger is not that the recovered generator disagrees with what you saw — you
checked that — but that it agrees on the window and then diverges past the end
of it, in a region you never examined. How long a window buys you certainty?

**The $2L$ theorem.** *Let $y$ and $z$ be sequences over a commutative ring,
each satisfying some order-$L$ linear recurrence — possibly with **different**
tap vectors. If $y_t = z_t$ for all $t < 2L$, then $y_t = z_t$ for every $t$.*

Twice the order. That is the whole answer, and it is uniform over the entire
family at once: it does not matter which taps, which seeds, or how long the file
is. A window of $2L$ matching symbols is a certificate valid to infinity.

The proof is a small piece of algebra with a lot of leverage. Let the shift
operator $\mathcal{S}$ act on sequences by $(\mathcal{S}y)_t = y_{t+1}$. It is
linear, so polynomials act on sequences: $p(X) = \sum_i p_i X^i$ sends $y$ to
$t \mapsto \sum_i p_i\, y_{t+i}$ — precisely a linear recurrence operator.
Attach to a tap vector $c$ its **characteristic polynomial**

$$f_c(X) \;=\; X^L - \sum_{j=0}^{L-1} c_j X^j,$$

monic of degree exactly $L$. Then "$y$ has taps $c$" says exactly that
$f_c(\mathcal{S})\,y = 0$: the sequence is *annihilated* by its characteristic
polynomial.

Now take our two sequences, with annihilators $f$ and $g$. Because polynomials
in a single operator commute, the product $fg$ annihilates *both* — and hence
the difference $w = y - z$. This is the step that fuses two different tap
vectors into one object, and $fg$ is monic of degree $2L$.

All that remains is a rigidity lemma: *a sequence annihilated by a monic
polynomial of degree $m$ that vanishes on $\{0, 1, \dots, m-1\}$ vanishes
identically.* Why? Monicity means the top coefficient is $1$, so the relation
$\sum_{i \le m} p_i\, w_{t+i} = 0$ solves for the newest term,
$w_{t+m} = -\sum_{i<m} p_i\, w_{t+i}$. Every value is forced by the $m$ before
it, and the first $m$ are zero, so strong induction sweeps the zero forward for
ever. Since $y$ and $z$ agree on $[0, 2L)$, their difference vanishes there, and
$2L$ is exactly the degree of $fg$. Done.

**And $2L-1$ is not enough.** Take the *impulse* seed $\sigma = (0,\dots,0,1)$
under two different tap vectors: with all taps zero the register empties,
producing the lone impulse $0^{L-1}\,1\,0\,0\cdots$; with taps $(1,0,\dots,0)$
the recurrence is the pure delay $y_{t+L} = y_t$, producing the periodic impulse
train $0^{L-1}\,1\,0^{L-1}\,1\cdots$. These agree on their first $2L-1$ symbols
and disagree at index $2L-1$. So no gate based on fewer than $2L$ observed
symbols can be sound; the constant is exactly right.

There is a matching counting shadow. Let $N_L(n)$ be the number of length-$n$
files producible by *some* order-$L$ register from *some* seed. Then $N_L(n)$
grows until $n = 2L$ and is constant thereafter: longer windows reveal no new
order-$L$ files, because $2L$ symbols already separate them all.

One more question: the detector returns *a* tap vector, but is it *the* tap
vector? Form the $L \times L$ **Hankel matrix** $H_{t,j} = y_{t+j}$ of the
observed window. If $H$ is nonsingular then any two tap vectors explaining the
same stream coincide, since their difference lies in the kernel of $H$.
Nondegeneracy of the window is precisely the condition under which seed recovery
has a unique answer rather than merely a consistent one.

---

## Counting the compressible: rarity, exactly

How much of the world is seed-compressible? Very little, and we can say how
little.

An order-$L$ register over an alphabet of size $q$ is described by $L$ taps and
$L$ seed symbols, so it produces at most $q^{2L}$ files of any length, out of
$q^n$. Once $n > 2L$, some file is produced by no order-$L$ register at all, and
the fraction that are is at most $q^{2L-n}$ — exponentially small. Bounded-order
seed compression is never universal at any order.

The crude count $q^{2L}$ is never attained, and one can see why in one line: the
$q^L$ parameter pairs with **zero seed** all produce the same file — the
all-zero one. Discounting that collapse gives the improved bound

$$N_L(n) \;\leq\; q^{2L} - q^{L} + 1,$$

a strict improvement for every $L \geq 1$.

At order one the count can be nailed exactly. Over a field, the order-one
register is multiplication by its single tap, so its output is the geometric
word $x_t = c^t s$. If $s \neq 0$ the parameters are recoverable from the first
two symbols ($c = x_1 / x_0$), giving $q(q-1)$ distinct words; if $s = 0$ the
word is all-zero whatever the tap. Hence, for every $n \geq 2$,

$$N_1(n) \;=\; q^2 - q + 1,$$

which meets the improved bound exactly — and, intriguingly, can be rewritten as

$$q^2 - q + 1 \;=\; \frac{q^3 + 1}{q + 1} \;=\; \frac{q^{2L+1}+1}{q+1} \Bigg|_{L=1}.$$

That closed form is conjectured to hold for every order, and the exhaustive
counts are strikingly obedient. Over the binary alphabet, orders $1$ through $5$
give $3,\ 11,\ 43,\ 171,\ 683$, matching $(2^{2L+1}+1)/3$; over the ternary
alphabet, orders $1, 2, 3$ give $7,\ 61,\ 547$, matching $(3^{2L+1}+1)/4$. Note
that $N_1 = q^2-q+1$ lies *strictly between* the general bounds $q^L$ and
$q^{2L}$, so the conjecture is a genuine claim about the degeneracy structure of
the family, not a pigeonhole estimate dressed up. Proving it for $L \geq 2$ is
open.

---

## No free lunch for the router

The engineering fantasy is a **router**: a front end that inspects a file,
consults a library of generator families — registers of every order,
congruential generators, whatever else — decides which one wrote it, and emits a
family index plus a seed. Surely a big enough library covers a lot of data?

It does not, and the bound is embarrassingly simple.

**Router capacity.** *For any finite family of generators $g_i$ with state
spaces $S_i$, the number of length-$n$ files reproducible by some member is at
most $\sum_i |S_i|$.*

That is the total number of seeds in the library, and nothing more: adding a
family adds its seed count, with no synergy and no combinatorial windfall. The
contrapositive is the sharpest way to say it: *a router that compresses
everything saves nothing* — if every length-$n$ file is reproducible by some
member, the library must carry at least $q^n$ seeds, exactly the number of files
it was supposed to compress.

The ceiling itself is usually not attained: at order one, the router that tries
every register of order $\leq 1$ carries $1 + q^2$ seeds but accepts exactly
$q^2 - q + 1$ files — a deficit of exactly $q$. There is also a structural
collapse worth knowing: padding a tap vector with a leading zero turns an
order-$L$ recurrence into an order-$(L{+}1)$ one for the same stream, so the
family of files of linear complexity $\leq M$ is *exactly* the order-$M$ family.
A router over all orders $\leq M$ is no more powerful than a detector at order
$M$ alone.

None of this kills the programme; it relocates it. Seed compression does not
beat the pigeonhole bound on average, it reallocates code space toward a sparse,
structured corner of file space. Whether that corner is where your data actually
lives is an empirical question — and a well-posed one, because the gate is exact
reproduction.

---

## Recovery in practice, and what noise does to it

The recovery procedure is almost anticlimactic. The candidate seed is the first
$L$ observed symbols; the only search is over tap vectors, keeping those that
reproduce the whole observed word from that seed. The test is **sound** (an
accepted tap vector regenerates the file symbol by symbol) and **complete** (it
accepts exactly the files of linear complexity $\leq L$), and once the window is
at least $2L$ long, *all* accepted candidates predict the same infinite stream:
ambiguity in the taps, if any, is invisible in the output.

At the other extreme sits the **impulse word** $0,0,\dots,0,1$, the worst case
for this whole enterprise. No register of order $L < n$ produces it: its first
$L$ symbols are all zero, so the only compatible seed is the zero seed, which
produces the all-zero file. Order $n$ does produce it, so its linear complexity
is *exactly* $n$ — maximal. This kills a natural conjecture: one might hope a
recovery routine could always return an order at most $\lceil n/2 \rceil$
consistent with the window it saw, but for $n \geq 2$ the impulse word is
consistent with no such order. The correct invariant is *minimality* of the
returned order.

Finally, noise. Real files are contaminated: a header here, a checksum there,
interleaved metadata. A practical detector must tolerate $e$ corrupted symbols,
and coding theory conditions one to expect an additive answer: $2L$ symbols to
pin the generator, $2e$ more to out-vote the errors, one to break ties — a
threshold of $2L + 2e + 1$.

**That guess is false, for every error budget $e \geq 1$.** Over the
three-element field, take the constant stream $y_t = 1$ (order one, tap $1$) and
the alternating stream $z_t = 2^t$, which there is $1, 2, 1, 2, \dots$ (order
one, tap $2$). These are distinct streams — yet they *agree at every even
index*. Now build an observed word of length exactly $2 \cdot 1 + 2e + 1$ whose
entries are all $1$ except a single $2$ at position $1$. It differs from the
constant stream in one place, and from the alternating stream in the $e$ odd
positions $3, 5, \dots, 2e+1$. Both distances are at most $e$: two distinct
generators, one observed word, no way to choose. The smallest instance takes
$e = 1$ and a window of five symbols.

The failure is structural, not accidental: the two streams agree on a
half-density set of indices, so their disagreements are spread out and *no*
window of $2L$ consecutive positions is error-free. Once you see that, the
repair suggests itself. Two streams within distance $e$ of a common word
disagree with it in at most $2e$ places combined; and $2e$ corrupted positions
cannot possibly meet all of $2e+1$ *disjoint* blocks of length $2L$. So at least
one clean block exists, and on a clean block the two streams agree on $2L$
consecutive symbols — which by the shifted $2L$ theorem forces them to agree
from there onward.

**Corrected threshold.** *A window of length $2L(2e+1)$ suffices: if an observed
word of that length is within Hamming distance $e$ of two streams of linear
complexity at most $L$, those streams agree from some index $j$ with
$j + 2L \leq n$ onward.*

The dependence on $e$ is multiplicative, not additive. And it is sharp, at least
at order one: at length $4e + 1 = 2 \cdot 1 \cdot (2e+1) - 1$, one symbol short,
unique decoding already fails. The witness is a word that splits its
disagreements evenly — $1$ at even indices, $1$ at the first $e$ odd indices,
$2$ at the last $e$ odd indices — sitting at distance exactly $e$ from each of
the two streams. So the multiplicative blow-up is not an artefact of the block
pigeonhole; it is the truth.

---

## What this all means

The seed-compression programme survives its own analysis, but in a chastened
form. It cannot be universal — the router capacity theorem forbids that in one
line, with no assumption about the generators — and it cannot help on average,
because the fraction of files it touches decays like $q^{-n}$.

What it *can* do is exact, cheap, and certified. If a file really is
shift-register output of order $L$, then $2L$ symbols are enough to recover the
generator and prove — not estimate — that it reproduces every remaining byte.
The seed is free to read, the congruential family comes along at order two for
no extra machinery, and when the file is only nearly generated, the price of
tolerating $e$ errors is a window growing like $2L(2e+1)$: a multiplicative, not
additive, tax, and a sharp one.

That is the honest shape of the answer to the question we started with. The file
that was never random can be recognised, recovered, and certified. There just
are not very many of them — and now we can count exactly how few.
