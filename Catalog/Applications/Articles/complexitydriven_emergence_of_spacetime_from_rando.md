# When Spacetime Has to Choose: Phase Transitions, Golden Networks, and the Arithmetic of Emergent Geometry

## A universe woven from threads

Imagine you could pull spacetime apart the way you unravel a sweater, tugging until
you found the single thread it was knitted from. For a long time physicists assumed
that thread would be something *geometric* — a tiny line element, a quantum of area,
a fundamental length. But over the last decade a stranger idea has taken hold: the
thread might not be geometric at all. It might be **information**. More precisely, it
might be *entanglement* — the quiet, invisible correlation that ties the parts of a
quantum system together.

The slogan for this idea, coined by physicists working on the holographic principle,
is blunt: **"It from Qubit."** Geometry — distance, curvature, the smooth fabric of
Einstein's relativity — is not put in by hand. It *emerges* from how a vast collection
of quantum bits are entangled with one another. Pull the entanglement apart, and the
geometry comes apart with it.

The most concrete laboratory for this idea is a mathematical object called a **random
tensor network**. Picture a graph — vertices connected by edges. On each vertex sits a
small quantum object; along each edge runs a "bond" that can carry a certain amount of
quantum information, measured by a number called the **bond dimension** $D$. A bond of
dimension $D$ is like a wire that can transmit $\log D$ bits' worth of quantum
correlation. Wire the vertices together with random quantum gates and something
remarkable happens: the network starts to behave like a *hologram*. The information
living on its boundary reconstructs a geometry living in its interior — a "bulk." When
the wires are fat enough, that bulk looks smooth, like a curved spacetime. When the
wires are too thin, the bulk shatters into something fractal and pathological, a
geometry that no amount of coarse-graining can iron flat.

This article is about a precise, fully machine-checked piece of that story. It does not
settle the grand physical conjecture — that smooth Einsteinian spacetime emerges above
a critical bond dimension and dissolves below it. Instead it nails down the *skeleton*
of the conjecture: the exact arithmetic of **when a holographic encoding can exist at
all**, an information-theoretic **area law** that caps how much a network can entangle,
and a beautiful number-theoretic surprise hiding inside a special class of networks
built from the most famous irrational number in mathematics — the **golden ratio**.

## The first lesson: encoding is all-or-nothing

Start with the most basic question you can ask of a holographic code. You have a "bulk"
worth of quantum information you want to protect and reconstruct. Concretely, suppose
your bulk lives on $N$ vertices, each carrying a quantum object of rank $k$, so the bulk
has $k^N$ possible states. You want to faithfully record those states on a boundary made
of $b$ bonds, each of dimension $D$, giving $D^b$ possible boundary states. A faithful
holographic encoding is an *injection*

$$\mathrm{Fin}(k^N) \hookrightarrow \mathrm{Fin}(D^b),$$

a one-to-one map that loses no information — every bulk state gets its own distinct
boundary fingerprint.

When does such a map exist? The answer is almost insultingly simple, and that simplicity
is the point: you can fit $k^N$ pigeons into $D^b$ holes exactly when there are at least
as many holes as pigeons, i.e. when $D^b \ge k^N$. Solving for the bond dimension, an
encoding exists **if and only if**

$$D \ge D_c(N) := \left\lceil \big(k^N\big)^{1/b} \right\rceil.$$

That ceiling, $D_c(N)$, is the **critical bond dimension**. Below it, no encoding exists;
information is irretrievably lost. At it or above it, a perfect encoding appears. There is
no gradual fade, no partial credit. The transition is *sharp* — a clean, all-or-nothing
jump from "geometry impossible" to "geometry possible." In the formalization this is two
companion facts: a witness that the encoding genuinely exists at $D = D_c$, and a proof
that it strictly fails for every $D < D_c$.

A worked example makes it vivid. Take qubits ($k = 2$), a bulk of $N = 10$ of them, and a
boundary of $b = 4$ bonds. The bulk has $2^{10} = 1024$ states. We need $D^4 \ge 1024$.
Try $D = 5$: $5^4 = 625 < 1024$ — not enough, information is lost. Try $D = 6$:
$6^4 = 1296 \ge 1024$ — it fits, and a faithful hologram exists. So $D_c(10) = 6$, and the
geometry "switches on" precisely as the bond dimension crosses $6$.

This is the discrete, order-theoretic shadow of a thermodynamic phase transition. In
statistical physics a sharp phase boundary — water freezing to ice — is where a system's
character changes discontinuously. Here the "character" is whether a smooth bulk can be
encoded at all, and the control knob is the bond dimension. The lesson: **emergent
geometry has a threshold, and the threshold is exact.**

## The second lesson: you cannot entangle more than your wires allow

A sharp threshold for *existence* is only half the story. The deeper physical content of
holography is the **area law**: the amount of entanglement between a region and its
surroundings is proportional not to the region's *volume* but to its *boundary area*.
This is exactly the scaling obeyed by the entropy of a black hole — the Bekenstein–Hawking
formula — and it is the single most important clue that gravity is secretly about
information.

In a tensor network the "area" of a region is just the number of bonds you have to cut to
isolate it, and each bond of dimension $D$ can carry at most $\log D$ units of
entanglement entropy. So if a boundary consists of $b$ bonds, the entanglement entropy
$S$ it can support is capped by

$$S \le b \cdot \log D.$$

This is the area law in its barest, most honest form: entropy bounded by (number of bonds)
$\times$ (capacity per bond). And the bound is **tight**. It is *saturated* — achieved with
equality — exactly when the entanglement spectrum is uniform, i.e. when every channel
through the cut is maximally and equally entangled. A maximally random network is, in this
precise sense, the most geometric network there is: it pushes entanglement right up to the
area-law ceiling, which is exactly the regime in which the holographic bulk looks smoothest.

## The third lesson: golden networks live below the ceiling — forever

Now for the surprise. The area law says entanglement is *at most* $b\log D$. But what if
the building blocks of your network are not ordinary qubits, with their freewheeling
$2^n$-dimensional state spaces, but exotic particles whose very combinatorics forbid them
from filling that space? Then the network is permanently parked *below* the area-law
ceiling — and the size of the gap turns out to be a universal constant of nature for that
kind of matter.

The cleanest example uses **Fibonacci anyons**. Anyons are quasiparticles that live in two
dimensions and obey "fusion rules" — recipes for what happens when you bring two of them
together. Fibonacci anyons are the simplest non-trivial kind, and they are a darling of
quantum-computing research because braiding them around one another performs robust,
error-resistant quantum gates. Their fusion rule has a single, severe constraint, which we
can model with a binary string: think of a chain of $n$ anyons as a string of $0$s and
$1$s, where a $1$ marks a "fusion event," and the rule forbids **two consecutive $1$s**.

How many distinct admissible chains of length $n$ are there? Call this count
$\mathrm{fusionCount}(n)$; it is precisely the dimension of the chain's quantum state space —
the number of independent ways the anyons can fuse. Counting binary strings with no two
adjacent $1$s is a classic puzzle, and the answer obeys a recurrence: a length-$(n+2)$
string is either a valid length-$(n+1)$ string with a safe symbol appended, or a valid
length-$n$ string with a constrained tail. Formally,

$$\mathrm{fusionCount}(0) = 1, \quad \mathrm{fusionCount}(1) = 2, \quad
\mathrm{fusionCount}(n+2) = \mathrm{fusionCount}(n+1) + \mathrm{fusionCount}(n).$$

That is the Fibonacci recurrence! And indeed the first machine-checked theorem says the
dimension *is* a Fibonacci number — exactly,

$$\boxed{\;\mathrm{fusionCount}(n) = F_{n+2}\;}$$

where $F$ is the usual Fibonacci sequence $0,1,1,2,3,5,8,13,21,\dots$. The chain dimensions
march out as $1, 2, 3, 5, 8, 13, 21, 34, \dots$ — Fibonacci numbers, one for every length.
The golden ratio $\varphi = (1+\sqrt5)/2 \approx 1.618$, which governs how fast Fibonacci
numbers grow, is therefore the *effective bond dimension* of a single Fibonacci anyon.

Now compare to a chain of ordinary qubits, whose state space has the full dimension $2^n$.
The second theorem is a **sub-qubit area law**: the Fibonacci chain is always at most as big
as the qubit chain,

$$\mathrm{fusionCount}(n) \le 2^n,$$

and — crucially — the inequality is **strict for every chain of length $n \ge 2$**:

$$\mathrm{fusionCount}(n) < 2^n \quad \text{for all } n \ge 2.$$

Check it: at $n=2$, $3 < 4$; at $n=3$, $5 < 8$; at $n=4$, $8 < 16$; at $n=10$, the gap is
already $144$ versus $1024$. The fusion constraint — "no two consecutive $1$s" — physically
*starves* the network of entanglement. It can never reach the qubit ceiling. And because
$F_{n+2}$ grows like $\varphi^n$ while $2^n$ grows like $2^n$, the entanglement density
settles at

$$\frac{\log \mathrm{fusionCount}(n)}{n} \;\longrightarrow\; \log \varphi \approx 0.481
\;<\; \log 2 \approx 0.693.$$

The difference, $\log 2 - \log\varphi \approx 0.212$, is a fixed, model-independent
**"curvature deficit"** — a universal gauge of how much less geometry a golden network can
support compared to a qubit network. The arithmetic of the golden ratio is literally
setting a geometric speed limit.

## The fourth lesson: networks made of golden threads are *commensurable*

Here is where the number theory becomes genuinely beautiful. Fibonacci numbers obey one of
the most elegant identities in all of mathematics: the greatest common divisor of two
Fibonacci numbers is itself a Fibonacci number, indexed by the gcd of their positions —
$\gcd(F_a, F_b) = F_{\gcd(a,b)}$. Translated to anyon chains, this becomes a statement
about how two chains *share structure*. The third theorem says that the gcd of two chain
dimensions is again a chain dimension:

$$\gcd\big(\mathrm{fusionCount}(m),\, \mathrm{fusionCount}(n)\big)
= \mathrm{fusionCount}\big(\gcd(m+2,\,n+2) - 2\big),$$

valid whenever $\gcd(m+2, n+2) \ge 2$. For example, a length-$4$ chain (dimension $8$) and a
length-$10$ chain (dimension $144$) have $\gcd(8,144) = 8$ — and $8$ is exactly the dimension
of the chain whose index is $\gcd(6,12) - 2 = 4$. The shared "sub-geometry" of two golden
networks is *itself a golden network*. The pieces fit; the family is closed under taking
common factors. This is what physicists mean by **commensurability**, and here it is an exact
arithmetic fact rather than an approximation.

## The fifth lesson: even golden networks have a threshold

Finally, the two threads — phase transitions and golden ratios — are tied together. Recall
the first lesson: a length-$n$ chain can be holographically encoded only if its bond
dimension clears the critical value $D_c$ for that length. A single Fibonacci anyon carries
bond dimension $\varphi \approx 1.618$. So we can ask: **how long a golden chain can the
golden ratio actually encode?**

Define a chain to be *encodable* when its critical bond dimension is strictly below $\varphi$.
The final theorem pins the threshold exactly:

$$\text{a length-}n\text{ Fibonacci chain is encodable} \iff n < 7.$$

A length-$6$ chain just makes it; a length-$7$ chain does not. The number $7$ is not a
guess or a numerical fit — it is a proven, sharp boundary, complete with explicit
verifications that length $6$ works and length $7$ fails. The same all-or-nothing character
we saw in the abstract pigeonhole threshold reappears here, now decorated with $\sqrt5$ and
the golden ratio.

## Why this matters

None of these results, on its own, derives Einstein's equations from quantum complexity.
That remains a grand and open conjecture. What these results *do* is lay down the load-bearing
beams of the argument with total rigor:

- **Emergent geometry has a sharp on/off switch** (the critical bond dimension), and that
  switch is governed by exact, countable arithmetic — not approximation.
- **Entanglement obeys an area law with a tight ceiling**, saturated precisely by the most
  random, most geometric networks.
- **The microscopic matter you build from controls the geometry you get**: golden networks
  sit permanently below the ceiling by a universal deficit, and they assemble into a
  commensurable family closed under arithmetic.

Each of these is the kind of statement that, in the physical conjecture, has always been
waved at heuristically — "the transition is sharp," "the area law holds," "anyonic networks
are sub-maximal." Here they are theorems. They convert slogans into structure, and structure
is what a real theory of emergent spacetime will have to be built from. The thread that
spacetime is knitted from may be information; if so, these are some of the exact knots.
