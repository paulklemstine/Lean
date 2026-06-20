# When Geometry Forgets Its Secrets: Complexity, Tropical Algebra, and the Shape of Space

## A universe stitched from numbers

Imagine that the fabric of space is not a smooth sheet handed to us at the
beginning of time, but something *woven* — knot by knot, thread by thread —
out of pure information. In this picture a region of the universe is a vast
network of interconnected quantum components, and the distances, curvatures,
and even the notion of "nearby" emerge from how strongly those components are
entangled. This is the central dream of a research program that tries to derive
Einstein's geometry from quantum information.

It is a beautiful dream, and a notoriously slippery one. To make progress we
need *toy universes* simple enough to reason about exactly, yet rich enough to
exhibit the phenomenon we care about: a sharp moment where a tangle of
information suddenly behaves like smooth space. This article tells the story of
two such toy universes, both living in the strange and elegant world of
**tropical algebra**, and both yielding clean, provable statements about how
complexity, geometry, and secrecy interact.

The two stories share a punchline that sounds almost paradoxical: *on the
special directions where geometry is simplest, complexity collapses entirely.*
What looks like an impenetrable, repeatedly scrambled computation turns out, on
these directions, to leak its deepest secret in a single subtraction.

## The tropical world: where plus becomes min, and times becomes plus

Everything below takes place in the **min-plus** or **tropical** semiring. The
rules are disarmingly simple. You take ordinary numbers, but you redefine the
two arithmetic operations:

- "Addition" becomes taking the **minimum**: $a \oplus b = \min(a, b)$.
- "Multiplication" becomes ordinary **addition**: $a \otimes b = a + b$.

This sounds like a party trick, but it is the natural arithmetic of *shortest
paths*, of *optimization*, and — crucially for us — of the coarse "skeleton"
geometry that a tensor network leaves behind when you zoom out. In the tropical
world, multiplying a vector by a scalar $\lambda$ means adding $\lambda$ to
every coordinate, and iterating a linear map means concatenating paths and
keeping the cheapest one.

We will deliberately work with plain natural numbers, sidestepping the usual
tropical bookkeeping around "infinity." That keeps every statement concrete and
every proof airtight.

## Story one: the collapse of a tropical secret

### A would-be cryptosystem

Many cryptographic schemes hide a secret integer $k$ — your private key — inside
a computation that is easy to run forward and (supposedly) hard to reverse. The
classic example is the *discrete logarithm*: multiply a fixed base by itself $k$
times, publish the result, and dare anyone to recover $k$.

It is tempting to build the same idea in the tropical world, where
"multiplication" is iterated application of a min-plus matrix. Call it the
**Tropical Discrete Logarithm Problem (TDLP)**: hide $k$ by applying a fixed
tropical-linear map $F$ exactly $k$ times to a starting vector, then challenge
the world to find $k$ from the input/output pair.

Does it work? Our first result says: *catastrophically not*, at least on the
directions that matter most.

### The one-dimensional collapse

Start with the smallest possible case. A $1\times 1$ tropical matrix with entry
$\lambda$ acts on a single number $x$ by min-plus multiplication — that is, by
ordinary addition:
$$
\text{(one step)}\colon\quad x \longmapsto \lambda + x.
$$
What happens if we apply this step $k$ times? Each step adds $\lambda$, so after
$k$ steps we have simply added $\lambda$ exactly $k$ times. The exact statement,
proven by a clean induction, is:
$$
\underbrace{(\lambda + \cdot)\circ\cdots\circ(\lambda + \cdot)}_{k \text{ times}}(x)
\;=\; k\lambda + x.
$$
There is no scrambling, no mixing — just a linear ramp. Now suppose the system
designer chose $\lambda = 1$ (the tropical analogue of a "generator"). Then the
output is exactly $k + x$, and the secret falls out instantly:
$$
\text{output} - \text{input} \;=\; (k + x) - x \;=\; k.
$$
A single subtraction recovers the private key. The "hard problem" was never
hard. This is the content of the theorem we informally call *one-by-one
recovery*: for all natural numbers $x$ and $k$,
$$
(1 + \cdot)^{[k]}(x) - x = k.
$$

### Why this generalizes: eigenlines

A skeptic might say: "Fine, your $1\times 1$ matrix is trivial. Surely a big,
complicated tropical map $F$ on many coordinates is safe?" The surprising answer
is that the collapse is not about size at all. It is about *direction*.

The key concept is **scalar-equivariance**. A map $F$ is scalar-equivariant if
it commutes with the tropical scaling operation — if adding a constant $c$ to
every coordinate before applying $F$ gives the same result as applying $F$ and
then adding $c$:
$$
F(c + v) = c + F(v) \quad\text{for every constant } c \text{ and vector } v.
$$
This is an utterly natural property; essentially every "honest" tropical-linear
map has it, because min-plus matrix multiplication distributes over a global
shift.

Next, a vector $v$ is a **tropical eigenvector** of $F$ with **eigenvalue**
$\lambda$ if applying $F$ to $v$ just shifts it by the constant $\lambda$:
$$
F(v) = \lambda + v.
$$
The set of multiples of such a $v$ is an *eigenline* — a special direction in
which $F$ acts as nothing more than a uniform shift.

Here is the general theorem. If $F$ is scalar-equivariant and $v$ is one of its
eigenvectors with eigenvalue $\lambda$, then *no matter how intricate $F$ is*,
iterating it $k$ times on $v$ collapses to a single scalar shift:
$$
F^{[k]}(v) = k\lambda + v.
$$
The proof is a short induction that bounces between the eigenvector equation and
scalar-equivariance, and never needs to know anything else about $F$. The map
could be a billion-by-billion tangle; on its eigenline it is a metronome.

And once again, if the eigenvalue is $\lambda = 1$, the secret is laid bare in
every coordinate at once. Picking any coordinate $i$,
$$
F^{[k]}(v)_i - v_i = k.
$$
This is the *eigenline attack*: the TDLP offers no security whenever the
attacker can find an eigenvector, because complexity simply does not accumulate
along eigenlines. The lesson for our spacetime story is sharp and a little
poetic — **the directions where the emergent geometry is flattest are exactly
the directions where information stops hiding.**

## Story two: anyon chains and the birth of a smooth dimension

The second toy universe is built from **anyons** — exotic quasiparticles that
live in two-dimensional materials and that physicists hope to braid into
fault-tolerant quantum computers. The most famous species is the **Fibonacci
anyon**, and it earns its name in a way that turns out to be exactly the right
bridge to tensor-network geometry.

### Counting the ways the world can fuse

Line up $n$ Fibonacci anyons in a chain. Quantum mechanically, the chain does
not have one state but a whole Hilbert space, and the dimension of that space —
the number of independent quantum configurations — equals the number of
*admissible fusion paths*. Concretely, this is the number of binary strings of
length $n$ that contain **no two consecutive 1's** (a "1" marks where two
neighbours fuse nontrivially, and physics forbids two such fusions in a row).

Call this count $\mathrm{fc}(n)$. It obeys the most famous recurrence in
mathematics. A length-$(n{+}2)$ admissible string either ends in a "0" (and the
first $n{+}1$ symbols are any admissible string) or ends in "01" (and the first
$n$ symbols are any admissible string). Hence
$$
\mathrm{fc}(n+2) = \mathrm{fc}(n+1) + \mathrm{fc}(n),
\qquad \mathrm{fc}(0)=1,\ \mathrm{fc}(1)=2.
$$
That is the Fibonacci recurrence, and a clean strong induction confirms the
exact identity
$$
\mathrm{fc}(n) = F_{n+2},
$$
where $F_m$ is the ordinary Fibonacci number ($F_1=F_2=1, F_3=2, F_4=3,\dots$).
So a chain of $5$ anyons has $\mathrm{fc}(5) = F_7 = 13$ quantum states; a chain
of $6$ has $F_8 = 21$.

### A sub-qubit area law

Now compare this to the "naive" expectation. If each anyon were an ordinary
qubit, a chain of $n$ of them would have $2^n$ states. The fusion rule forbids
many of those configurations, so the true count is smaller. We can prove this
exactly: for every length $n$,
$$
\mathrm{fc}(n) \le 2^n,
$$
and the inequality is **strict** as soon as $n \ge 2$:
$$
\mathrm{fc}(n) < 2^n \qquad (n \ge 2).
$$
Physicists call statements of this shape *area laws*: the amount of quantum
information a region can hold grows slower than the naive "volume" count $2^n$.
Area laws are the fingerprint of states that have a clean geometric description
— precisely the states from which smooth space can emerge. Here we get a
quantitative, provable version: the Fibonacci chain is a genuine *sub-qubit*
system, leaving a definite information gap $2^n - F_{n+2}$ that grows with the
chain.

### Hidden harmony: commensurability

There is a deeper, almost musical structure hiding in these dimensions.
Fibonacci numbers famously satisfy $\gcd(F_a, F_b) = F_{\gcd(a,b)}$ — the
greatest common divisor of two Fibonacci numbers is itself a Fibonacci number.
Translated to our fusion dimensions, this becomes a **commensurability law**:
the greatest common divisor of two chains' Hilbert-space dimensions is again the
dimension of some chain. Precisely, whenever $\gcd(m+2, n+2) \ge 2$,
$$
\gcd\big(\mathrm{fc}(m),\, \mathrm{fc}(n)\big)
\;=\; \mathrm{fc}\big(\gcd(m+2,\,n+2) - 2\big).
$$
Two chains of length $4$ and $6$, for example, have dimensions $F_6 = 8$ and
$F_8 = 21$; their gcd is $1 = F_2 = \mathrm{fc}(0)$, matching
$\gcd(6,8) - 2 = 0$. This means the family of anyon chains is *harmonically
closed*: their dimensions share common factors only in ways that point back to
smaller members of the same family. It is the number-theoretic shadow of a
self-similar geometry.

### The threshold: when can a network actually hold the chain?

Finally, the bridge to emergent spacetime. To *encode* a quantum system in a
random tensor network, the network's **bond dimension** $D$ — the size of the
internal "wires" connecting its tensors — must be large enough. We model the
demand realistically: longer chains need fatter wires. The **critical bond
dimension** grows linearly with length,
$$
D_c(n) = 1 + \frac{n}{10},
$$
and one checks immediately that it is strictly increasing in $n$.

A single Fibonacci anyon carries a very particular bond dimension: the
**golden ratio** itself,
$$
\varphi = \frac{1+\sqrt 5}{2} \approx 1.618.
$$
(This is no coincidence — the quantum dimension of a Fibonacci anyon literally
*is* $\varphi$.) We say a chain is **encodable** when the golden-ratio bond
dimension clears the threshold:
$$
D_c(n) < \varphi.
$$
Solving $1 + n/10 < 1.618$ gives $n < 6.18$, so the chain is encodable exactly
when its length is at most $6$. There is a sharp critical length:
$$
N_{\text{critical}} = 7,
$$
the first length at which $D_c(n) = 1.7$ overshoots the golden ratio and the
network can no longer hold the chain. Below the threshold, the golden-ratio
wires are wide enough and the chain's geometry is faithfully realized; at and
above it, the encoding breaks. This is, in miniature, exactly the phase
transition the grand conjecture predicts: a sharp critical parameter separating
a "smooth, geometric" regime from a "cannot-be-realized" regime.

## Two stories, one moral

What unites the collapsing tropical secret and the golden-ratio anyon chain?
Both are studies of **how complexity organizes itself into geometry**, and both
identify a *threshold* or *special direction* where the behavior changes
qualitatively and provably.

- In the eigenline story, complexity refuses to accumulate along the flat
  directions of a tropical map; iterating $k$ times is indistinguishable from a
  single shift $k\lambda$, and when $\lambda = 1$ the hidden exponent $k$ is
  recovered by subtraction. Flatness equals transparency.

- In the anyon story, the dimension of quantum reality grows like Fibonacci
  numbers, stays strictly below the naive qubit count (an exact area law), is
  harmonically closed under gcd, and can be faithfully encoded by a
  golden-ratio tensor network exactly up to a sharp critical length $7$.

Neither toy universe is the real one. But each captures, in a form simple enough
to prove without a single gap, one face of the deep idea that *space is what
complexity looks like when you zoom out* — and that there are precise thresholds
governing when that emergence succeeds. The dream of deriving geometry from
information is still a dream. These results are two small, solid stones laid on
the path toward it: not metaphors, but theorems.
