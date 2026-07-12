# The Sequences a Machine Can Remember

Imagine a machine with only a handful of internal states — no memory tape, no
scratch paper, no ability to count arbitrarily high. You feed it a number,
digit by digit, and when the digits run out it lights up one of a few colored
lamps. That lamp is the machine's answer. Sequences produced this way are called
**automatic sequences**, and they sit at a strange and beautiful crossroads
between number theory, computer science, and the theory of what can be computed
at all.

The most famous automatic sequence begins

$$0,\,1,\,1,\,0,\,1,\,0,\,0,\,1,\,1,\,0,\,0,\,1,\,0,\,1,\,1,\,0,\dots$$

This is the **Thue–Morse sequence**. Its $n$-th term is simply the *parity of the
number of ones* in the binary expansion of $n$: write $n$ in base $2$, count the
$1$-digits, and record whether that count is even ($0$) or odd ($1$). It shows
up in places nobody expected: in fair ways to divide a prize between two greedy
players, in the design of sequences that never repeat themselves too regularly,
in chess endgame rules, and even in the harmonics of certain musical
compositions.

This article is about a single, clean question: **which sequences can such a
finite-memory machine produce, and how would you recognize one if you saw it?**
The answer turns out to be astonishingly tidy, and it hides an idea powerful
enough to make an entire family of "chaotic-looking" sequences behave like
well-mannered algebra.

## Machines that read digits

Fix a base $k \ge 2$ — think $k = 2$ for binary. A finite-state reading machine
processes a number $n$ by consuming its base-$k$ digits and hopping between a
fixed, finite collection of internal states. Because the machine has only
finitely many states, it cannot "remember" the whole number; it can only
remember *which of its few states* it currently occupies. When the digits are
exhausted, an output function reads the final state and prints a symbol. A
sequence $(a_n)$ is **$k$-automatic** if some such machine outputs $a_n$ for
every $n$.

That definition is operational — it talks about gears and states. What we really
want is a definition that talks only about the *sequence itself*, so we can test
a sequence without ever building a machine. This is where the central idea
enters.

## Decimations: zooming in on a sequence

Take any sequence $a = (a_0, a_1, a_2, \dots)$ and any base $k$. A **decimation**
is what you get by sampling the sequence along an arithmetic progression whose
step is a power of $k$. Concretely, for exponents $i$ and an offset $r$, the
decimation is the new sequence

$$n \;\longmapsto\; a\big(k^{\,i}\, n + r\big).$$

For $k = 2$, the two most basic decimations are the *even-indexed* subsequence
$n \mapsto a(2n)$ and the *odd-indexed* subsequence $n \mapsto a(2n+1)$. These are
exactly the two "children" you get by asking: given that I have already read the
first digit of the input, what sequence of outputs remains? Reading one more
digit splits each child into two grandchildren, and so on.

Now collect **all** decimations of $a$ (over all valid $i$ and $r$) into one big
set. This set is called the **$k$-kernel** of $a$. And here is the theorem that
organizes everything:

> **The Finite-Kernel Criterion.** A sequence is $k$-automatic if and only if its
> $k$-kernel is *finite*.

The intuition is irresistible once you see it. The machine's *states* are
precisely its distinct "remaining behaviors" after reading some prefix of the
input — and those remaining behaviors are exactly the decimations. A machine
with finitely many states can produce only finitely many distinct decimations;
conversely, if there are only finitely many decimations, you can *use them as the
states* and build a machine. Decimations are states in disguise.

## The one identity that makes it all work

Why should the kernel ever be finite? The engine is a single composition law.
If you decimate a sequence and then decimate the result, you have not created
anything new — you land on another decimation of the original sequence. Written
out, decimating with parameters $(i, r)$ and then with $(j, s)$ gives

$$\text{(decimate by } (i,r)\text{, then by } (j,s)) \;=\; \text{decimate by } \big(i+j,\; k^{\,i} s + r\big).$$

This is the **decimation semigroup law**. It says the operation "sample along a
$k$-power progression" is closed under repetition: two zooms compose into one
zoom. Consequently the kernel is *self-contained* — every decimation of a
decimation is already inside the kernel. Testing automaticity becomes a
finiteness check on a set that can never accidentally spill outside itself.

A small but load-bearing inequality guarantees the offsets stay in range: when
$s < k^{\,j}$ and $r < k^{\,i}$, the combined offset satisfies $k^{\,i} s + r <
k^{\,i+j}$, so the composed decimation is a *bona fide* member of the kernel.
Everything hinges on this bookkeeping about digit positions.

## Thue–Morse: a two-state world

Return to Thue–Morse, $t_n = $ parity of the ones in the binary form of $n$.
Appending a $0$ to the binary expansion doubles the number and adds no new ones,
while appending a $1$ doubles it and adds exactly one. So the sequence obeys the
elegant recurrence

$$t_{2n} = t_n, \qquad t_{2n+1} = t_n + 1 \pmod 2.$$

Look at what this does to decimations. The even-child of $t$ is $t$ again. The
odd-child of $t$ is $t + 1$ (flip every bit). The children of $t+1$ are, by the
same rule, $t+1$ and $t$. No matter how deep you zoom, you only ever see one of
**two** sequences: $t$ itself, or its bitwise complement $t + 1$. The
$2$-kernel of Thue–Morse is *exactly* the two-element set $\{t,\; t+1\}$.

That is the whole proof that Thue–Morse is automatic: a two-element kernel means
a two-state machine. The abstract criterion delivers, on this flagship example,
the smallest possible witness. And the reason the kernel closes up so neatly is a
one-line fact of arithmetic modulo $2$: the map "add $1$" is an *involution* —
do it twice and you are back where you started. The two states are simply "even
number of ones so far" and "odd number of ones so far," and each input digit
either keeps you put or flips you.

## Parity and sign: the same sequence in two costumes

Thue–Morse has a multiplicative twin. Instead of recording the parity $t_n \in
\{0, 1\}$, record the **sign** $\varepsilon_n = (-1)^{\,t_n} \in \{+1, -1\}$. The
two descriptions carry identical information, dressed differently: $t_n = 0$
exactly when $\varepsilon_n = +1$, and $t_n = 1$ exactly when $\varepsilon_n =
-1$. The additive form lives in the world modulo $2$, where "flip a bit" is
addition; the multiplicative form lives in $\{\pm 1\}$, where the same flip is
multiplication by $-1$. Being able to pass losslessly between the two is what
lets number-theoretic identities about $\pm 1$ signs talk to combinatorial
identities about bit-parities.

## An algebra of automatic sequences

The finite-kernel viewpoint pays off far beyond a single example, because
finiteness is preserved by natural operations. Three closure properties follow
almost for free:

- **Constants are automatic.** A sequence that never changes has a kernel with a
  single element — one state, one lamp.
- **Recoloring preserves automaticity.** Apply any function $g$ to every output
  of an automatic sequence — merge colors, swap them, map them into a different
  alphabet — and the result is still automatic. Recoloring the outputs cannot
  increase the number of distinct decimations.
- **Pointwise combinations preserve automaticity.** If $a$ and $b$ are both
  $k$-automatic, so is any term-by-term combination $n \mapsto f(a_n, b_n)$. In
  particular, when the values live in a number system where you can add and
  multiply, the sum sequence $a_n + b_n$ and the product sequence $a_n \cdot b_n$
  are automatic. The kernel of the combination embeds into the (finite) set of
  pairs of kernels, so it too is finite.

There is also a satisfying sanity check: **every automatic sequence takes only
finitely many values.** A machine with finitely many states and one output lamp
per state simply cannot print infinitely many distinct symbols. Any sequence
that keeps producing genuinely new values — the positive integers $1, 2, 3,
\dots$, say — is therefore beyond the reach of finite memory.

Together these facts say that, for a fixed base, the automatic sequences form an
**algebra**: a robust class closed under the everyday operations of arithmetic
and relabeling, all traceable to the single composition identity for
decimations.

## Why this borders the halting problem

The title of this piece promised a brush with the halting problem — the
undecidable question of whether an arbitrary program ever stops. Automatic
sequences are, in a precise sense, the *opposite pole* of that difficulty. They
are the sequences a machine can compute with a bounded, forgetful, finite mind.
There is no unbounded loop to get stuck in, no possibility of running forever
searching for an answer, and — because the kernel is finite and the composition
law is explicit — deciding membership, comparing two automatic sequences, and
computing their combinations are all mechanically decidable.

This makes automaticity a natural frontier. On one side lie the finite-memory
sequences, fully tamed by the kernel criterion. On the other lie sequences whose
patterns demand unbounded memory — and, further out, sequences whose very
description entangles them with the undecidable. Knowing exactly where a sequence
falls is knowing exactly how much a machine must *remember* to reproduce it. The
finite-kernel criterion draws that line with a single, elegant idea: a sequence
is computable by a forgetful machine precisely when, no matter how far you zoom
in, you keep seeing the same finitely many faces.

## The takeaway

Strip away the machinery and one image remains. Take a sequence, zoom into it
along power-of-$k$ progressions, and watch the collection of distinct pictures
you obtain. If that gallery is finite, a small machine can paint the whole
sequence forever; if it is infinite, no finite machine ever will. Thue–Morse
lives in a gallery of exactly two pictures — itself and its mirror image — which
is why it is one of the most computable "complicated" sequences ever discovered.
Two states, an involution, and one composition law: that is all it takes to
capture an object that has fascinated mathematicians for more than a century.
