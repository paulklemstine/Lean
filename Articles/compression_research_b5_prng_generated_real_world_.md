# The Data That Compresses to Three Integers

## What if your file is not data at all, but a seed?

Every compression scheme ever written runs into the same wall. There are $2^n$ possible files of $n$ bits, and only $2^n - 1$ shorter strings to encode them with. So no compressor can shrink everything. Most files, in the brutal arithmetic of the pigeonhole principle, are incompressible.

And yet real-world data compresses beautifully — because real-world data is not random. It has structure. Usually that structure is *statistical*: letters follow letters, pixels resemble neighbours, and a good model of those tendencies buys you a factor of ten.

But there is a second, much rarer, and far more dramatic kind of structure. Sometimes a file is not merely *patterned*; it is **generated**. Somebody ran a short deterministic procedure — a pseudorandom number generator, a procedural terrain algorithm, a table-building loop — and wrote the output to disk. The file may be a gigabyte. The procedure that made it may be four lines long. If you can *recognise* that the file is generator output, and *recover the seed*, the file collapses to the seed. Not compressed by ten percent. Collapsed.

This article is about carrying that idea out to the end in one concrete, ancient, and completely explicit setting: **Pythagorean triples**.

## A generator hiding in plain sight

A Pythagorean triple is a triple of positive integers $(a,b,c)$ with
$$a^2 + b^2 = c^2.$$
The first one everybody meets is $(3,4,5)$. The next few are $(5,12,13)$, $(8,15,17)$, $(7,24,25)$, $(20,21,29)$.

Tables of these triples are genuinely real-world data. They appear in geometry software, in test suites, in procedurally generated meshes, in number-theory datasets, in the innards of exact-arithmetic libraries. They look, at a glance, like an irregular list of integers — the kind of thing you would gzip and move on.

They are not irregular at all. In 1963 F. J. M. Barning, and independently in 1934 B. Berggren, observed that every *primitive* triple (one where the legs share no common factor) is reachable from $(3,4,5)$ by repeatedly applying just three fixed linear maps. Write a triple as a column vector; the three maps are the matrices

$$
A=\begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\qquad
B=\begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\qquad
C=\begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}.
$$

Apply them to $(3,4,5)$ and you get $(5,12,13)$, $(21,20,29)$, and $(15,8,17)$. Apply them again and you get nine more triples. Keep going and you sweep out an infinite ternary tree that contains **every** primitive triple, each exactly once.

So a table of primitive Pythagorean triples is not data. It is generator output. The generator is a three-state machine; the "seed" of a triple is nothing more than the sequence of letters $A$, $B$, $C$ you have to type to reach it. That is the setting in which we can ask the compression question sharply — and answer every part of it.

## Question one: how do you *know* it is generator output?

Compression by seed recovery is useless if you cannot tell, cheaply, that seed recovery is even worth attempting. You need a **fingerprint**: a test you can run on the raw numbers, without guessing the seed, that shouts "a generator made this".

Here the fingerprint falls out of a two-hundred-year-old theorem. Every $3\times3$ matrix satisfies its own characteristic polynomial — that is the Cayley–Hamilton theorem — and a cubic characteristic polynomial means the matrix's powers satisfy a three-term linear relation. Translating: if a stream of vectors is the orbit of a fixed $3\times 3$ integer matrix $M$, then *any* linear measurement you take of that stream, say $y(t) = u_1 a(t) + u_2 b(t) + u_3 c(t)$, obeys the fixed recurrence

$$y(t+3) = \operatorname{tr}(M)\,y(t+2) \;-\; c_2(M)\,y(t+1) \;+\; \det(M)\,y(t),$$

where $\operatorname{tr}(M)$ is the trace, $\det(M)$ the determinant, and $c_2(M)$ the sum of the three principal $2\times2$ minors. The coefficients — engineers call them *taps* — depend only on the matrix, never on the seed.

That is the whole detection story, and it is beautifully robust: it doesn't matter *which* coordinate you look at, or which combination, or where the orbit started. Feeding the observed stream to a linear-complexity detector — the classical Berlekamp–Massey algorithm, which finds the shortest linear recurrence fitting a sequence — recovers the taps from a handful of samples.

For the Pythagorean generators, the taps are startlingly simple. Both $A$ and $C$ have characteristic polynomial $(\lambda - 1)^3$, giving

$$y(t+3) = 3y(t+2) - 3y(t+1) + y(t),$$

which is just the statement that the **third difference vanishes**: the stream is a quadratic polynomial in $t$. The matrix $B$ has characteristic polynomial $\lambda^3 - 5\lambda^2 - 5\lambda + 1$, so

$$y(t+3) = 5y(t+2) + 5y(t+1) - y(t).$$

You can see this in the numbers. Iterate $A$ from $(3,4,5)$ and you get
$$(3,4,5),\ (5,12,13),\ (7,24,25),\ (9,40,41),\ (11,60,61),\dots$$
The hypotenuses $5, 13, 25, 41, 61$ have second differences $8, 8, 8, 8$ — the quadratic $2t^2 + 6t + 5$, exactly as the closed form predicts. Iterate $B$ instead and the hypotenuses are $5, 29, 169, 985, 5741$, each roughly $5.83$ times the last: the Pell numbers, obeying $c(t+2) = 6c(t+1) - c(t)$, because $\lambda^3 - 5\lambda^2 - 5\lambda + 1$ factors as $(\lambda+1)(\lambda^2 - 6\lambda + 1)$ and the Pell factor $3 \pm 2\sqrt 2$ is what actually drives the growth.

And that order-3 bound is not slack: for the $A$- and $C$-branches, no order-2 recurrence fits the hypotenuse stream at all, while the $B$-branch hypotenuse fits order $2$ and nothing shorter. So the *complexity itself* is a classifier: measure the shortest recurrence length of one coordinate, get $3$, and you are on a unipotent branch; get $2$, and you are on the Pell branch. No seed search required.

## Question two: can you actually recover the seed?

Detection without recovery is a party trick. Here recovery is complete, and it is cheap.

For a single repeated move, the seed is literally the first three observed symbols: feed them into the recurrence and the reconstructed stream agrees with the observed one at *every* index, forever, exactly. A file of a million triples becomes three integers and a two-bit label.

For the full generator — where the control word $w \in \{A,B,C\}^*$ can mix the three moves — the recovery is a descent. Given a triple, we ask *which move made it*. The answer is decided by three sign tests: undo each of $A$, $B$, $C$ in turn and see which one lands you back in the positive quadrant. Exactly one does, and running it moves you strictly closer to the root, because each forward step increases the hypotenuse by at least $4$. So the descent terminates, and it recovers the control word letter for letter. Compress by writing the word; decompress by replaying it; the output is bit-for-bit the input.

Even better, the code is *uniquely decodable*: two different control words never produce the same triple. Combining that with the coverage theorem below, the map from words to triples is an honest bijection between $\{A,B,C\}^*$ and the set of normalised primitive Pythagorean triples.

## Question three: how much of the data is seed-compressible?

Here the answer splits in two, and the split is the real lesson of the whole exercise.

**Restricted to the data the generator was built for, the answer is: all of it.** Every primitive Pythagorean triple with positive legs and odd first leg is emitted by the generator, for exactly one control word. Not "most". Every one. The proof is a descent: any such triple with hypotenuse greater than $5$ has exactly one legitimate parent, whose hypotenuse is strictly smaller; iterate and you reach the unique small triple, $(3,4,5)$. So a corpus of primitive triples is 100% seed-compressible, and the seed is found in a number of sign tests linear in the size of the data — at most $(c-5)/4$ rounds for a triple with hypotenuse $c$.

**Restricted to arbitrary files, the answer is: almost none of it, and provably so.** Suppose we allow any of the three generators, started at any seed whose three coordinates lie in $[-N,N]$, and we ask how many length-$n$ files it can possibly produce. There are at most $3(2N+1)^3$ of them — three branch choices times the number of seeds. Crucially, that bound *does not grow with $n$*. Meanwhile the number of length-$n$ files over the same alphabet is $((2N+1)^3)^n$, which explodes. Already at $n=2$ and $N=1$ the count of candidate files, $729$, dwarfs the compressor's entire reach, $81$. Most files are not generator output, and the gap widens exponentially with length.

That is the pigeonhole principle doing its inevitable work, but stated in a useful form: seed compression is not a general-purpose compressor, it is a *detector* with a spectacular payoff on the tiny set it recognises. Which is exactly why the routing question — is this file seed-compressible or model-compressible? — is the operationally important one.

## The classifier, and what it costs

Routing turns out to be almost free, because the three generators are aggressively distinguishable.

First, there are three conserved quantities, one per branch, which can be read off two consecutive triples with two subtractions:

- On the $A$-branch, the gap $c - b$ **never changes**. (For the orbit from $(3,4,5)$ it is frozen at $1$: $5-4$, $13-12$, $25-24$, $41-40$, …)
- On the $C$-branch, the gap $c - a$ never changes (frozen at $2$ from the root: $17-15$, $37-35$, …).
- On the $B$-branch, the leg gap $b - a$ merely flips sign at each step, so its absolute value is frozen ($|4-3| = 1$, $|20-21| = 1$, …).

Second — and this is what makes routing a decision rather than a guess — on any triple with positive legs, the three moves land on three *distinct* triples. A single observed transition therefore pins down the branch. The formal classifier is trivially simple: given consecutive observations $p$ and $q$, try $Ap$, $Bp$, $Cp$ and report whichever matches. It is *sound* (whenever it commits, it is right), *complete* (if any Berggren move explains the transition, it finds one), and on triples with positive legs it is *exact* (the branch it returns is the branch). Consequently a stream can never be explained by two different branches: seed and family label are both uniquely recoverable.

Two concrete negative examples pin down where the scheme stops. A constant stream — the same triple repeated forever — is *not* a generator orbit, because every move strictly increases the hypotenuse. That data is highly compressible, but by a model ("repeat this"), not by a seed. And the triple $(6,8,10)$, the doubling of the root, has no legitimate parent at all: it can never occur after the first step of any orbit, which puts it outside the range of the control-word code entirely. Double a file that the control-word code had crushed to a handful of ternary symbols, and the compressor is thrown back on spelling out the triple. The scheme is exquisitely sensitive to normalisation — a lesson any real deployment would learn the hard way.

## Question four: is recovering the seed actually a *win*?

This is the sharpest surprise, and it is the reason detection and compression must be kept apart in one's head.

Consider two extreme control words of the same length $k$.

The word $BBB\cdots B$ produces a triple whose hypotenuse is at least $5 \cdot 3^k$ — in truth it grows like $(3+2\sqrt2)^k \approx 5.83^k$. To write that hypotenuse in binary costs about $k \log_2 5.83 \approx 2.5k$ bits; to write the seed costs $k$ trits, about $1.6k$ bits, plus a length. That is real, honest, logarithmic-in-the-data compression.

The word $AAA\cdots A$ produces a triple whose hypotenuse is exactly $2k^2 + 6k + 5$. Writing the hypotenuse in binary costs about $2\log_2 k$ bits. Writing the seed costs $k \approx \sqrt{c/2}$ trits. The "compressed" form is **exponentially larger than the raw data**. Seed compression is a catastrophic loss on that branch.

Both branches have identical detectability — order-3 linear recurrence, three-symbol fingerprint, same detector, same cost. They differ completely in profit. Stated in one breath: *for every $k$, the all-$B$ word emits a hypotenuse of at least $5 \cdot 3^k$, while the all-$A$ word emits one of at most $2(k+2)^2$.* At $k = 10$ the contrast is $295{,}245$ against $265$.

And there is a ceiling as well as a floor: one Berggren step multiplies the hypotenuse by at most $7$, so a word of length $k$ can never reach beyond $5 \cdot 7^k$. Consequently a seed can never be *shorter* than logarithmic in the data. Berggren coding beats binary by at most a constant factor, ever.

What separates the winning branch from the losing one is a single spectral quantity. The matrix $B$ has spectral radius $3 + 2\sqrt2 > 1$; its orbits grow exponentially, so a length-$k$ seed names an exponentially large object and the seed is short. The matrices $A$ and $C$ are *unipotent* — all their eigenvalues equal $1$ — so their orbits grow only polynomially, and the seed is long. Detectability is governed by the **degree** of the characteristic polynomial (always $3$, by Cayley–Hamilton). Compressibility is governed by the **root moduli** of the very same polynomial. Two different invariants of one matrix, pulling in different directions.

## What this actually teaches

It is tempting to read the Pythagorean case as a curiosity. It is better read as a fully worked miniature of the general problem, with every question answered exactly rather than empirically:

1. **Detection is easy and universal.** Any generator whose state evolves by a fixed $d \times d$ integer matrix leaves an order-$d$ linear recurrence on *every* linear observable. You do not need to know the matrix; Berlekamp–Massey extracts the recurrence from $2d$ samples. This survives composition: driving the machine with a repeating control word $w$ merely replaces the matrix by a product of matrices, which is still $3\times3$, and still order-3 detectable.

2. **Recovery, when detection fires, is exact and cheap.** Three symbols for a single-move stream; a linear-time descent by sign tests for the full tree; the falsifiability gate — decompressed output equals the input, exactly — is met in every case.

3. **Coverage is a matter of choosing the right corpus.** On its natural domain the generator covers everything; on arbitrary files it covers a set whose size does not even grow with the file length. A deployed system must therefore be a *router*, not a compressor: cheaply test for the fingerprint, seed-compress when it fires, fall back to a statistical model when it does not.

4. **Detectability and profitability are different invariants.** This is the finding a practitioner should carry away. You can be certain a file is generator output, recover the seed exactly, and *still* end up with something bigger than what you started with. Whether seeding wins is decided by the growth rate of the generator, not by how loudly it announces itself.

The pigeonhole principle guarantees that no compressor beats it in general. What the Pythagorean tree shows, in complete and checkable detail, is what beating it *locally* looks like: an exactly characterised island of data on which a gigabyte becomes a handful of trits — surrounded by an ocean where the same machinery, running perfectly, is worse than useless.

Somewhere in that picture is a design principle for real compressors, and a caution: the interesting question is never "can I find the seed?" but "will finding it pay?"
