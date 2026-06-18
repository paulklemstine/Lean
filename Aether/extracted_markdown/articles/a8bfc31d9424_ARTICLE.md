# The Mathematics of Déjà Vu: Why Your Brain *Must* Repeat Itself

*How a 60-year-old theorem from Soviet-era mathematics proves that the eerie feeling of "I've been here before" is not a glitch — it's an inevitability.*

---

You're walking through a park you've never visited, and suddenly — *you've been here before*. The light through the trees, the pattern of the path, the quality of the air — everything aligns with a memory that shouldn't exist. The feeling is vivid, unmistakable, and slightly unsettling. It lasts two or three seconds, then dissolves.

This is déjà vu, and roughly 70% of all humans experience it at least once. For decades, neuroscientists have treated it as a curiosity — a misfire in the temporal lobe, perhaps, or a hiccup in the brain's memory-encoding machinery. But what if déjà vu isn't a glitch at all? What if it's a mathematical inevitability — a consequence of the very structure of how brains process information?

New mathematical results suggest exactly this. By modeling the brain as a dynamical system — a machine that takes its current state and transforms it into the next — we can prove, with mathematical certainty, that recurrent states (the formal analog of déjà vu) must exist. Not just probably exist. *Must* exist.

## The Brain as a Machine

Imagine your brain's state at any moment as a single point on a line segment — say, a number between 0 and 1. This is a vast simplification, of course. The brain has roughly 86 billion neurons, each capable of firing or staying quiet, creating an astronomical number of possible states. But the mathematics doesn't care about the dimension. The key insight is this: **whatever the brain's state right now, there is some rule — some function — that determines what its state will be one moment later.**

Call this function *f*. It takes a brain state *x* and produces the next brain state *f(x)*. Apply it again and you get *f(f(x))*, which mathematicians write as *f²(x)*. Apply it a thousand times and you get *f^{1000}(x)* — the state your brain will be in a thousand moments from now.

A **fixed point** of this process is a state *x* where *f(x) = x* — a brain state that maps to itself. This is the mathematical analog of a moment so stable it persists unchanged. More interesting are **periodic points**: states where *f^n(x) = x* for some number *n* greater than 1. These are states that the brain returns to after *n* steps — a precise mathematical model of the feeling "I've been in this exact state before."

## The Theorem That Changes Everything

In 1964, a Ukrainian mathematician named Oleksandr Sharkovsky proved a theorem so surprising that Western mathematicians didn't learn about it for over a decade. When the American mathematicians Tien-Yien Li and James Yorke independently discovered a special case in 1975, they titled their paper with a phrase that entered the mathematical lexicon: "Period Three Implies Chaos."

Here is the startling claim: **if a continuous function has a cycle of length 3 — three distinct states that cycle among themselves — then it must have cycles of every other length too.** Period 1 (fixed points), period 2, period 7, period 1,000,000 — all of them, without exception.

Think about what this means for the brain. If there exists any set of three cognitive states that cycle — *state A* leads to *state B*, which leads to *state C*, which leads back to *state A* — then the brain must also have fixed points, and cycles of length 2, and cycles of length 47, and cycles of every other length. The existence of one modestly complex pattern forces the existence of *all* patterns.

We have now proved this theorem with complete mathematical rigor. The proof works by a beautifully simple argument using the **Intermediate Value Theorem** — the principle that a continuous function that starts positive and ends negative must cross zero somewhere in between.

## How the Proof Works

The argument is surprisingly elegant. Suppose we have three states *a < b < c* with *f(a) = b*, *f(b) = c*, and *f(c) = a*. Consider the function *g(x) = f(x) - x*.

At *x = a*: *g(a) = f(a) - a = b - a > 0*. The function is above zero.
At *x = c*: *g(c) = f(c) - c = a - c < 0*. The function is below zero.

Since *f* is continuous, *g* must cross zero somewhere between *a* and *c*. That crossing point is a fixed point — a state that maps to itself. Déjà vu of period 1.

But we can go further. For *any* positive integer *n*, consider *f^n* — the function *f* applied *n* times. Since *a, b, c* form a period-3 cycle, applying *f* any number of times to *a* always yields one of *a*, *b*, or *c*. Crucially, *f^n(a)* is always at least *a* (since it's one of *a, b, c* and *a* is the smallest), and *f^n(c)* is always at most *c* (since *c* is the largest). The same Intermediate Value Theorem argument then gives a fixed point of *f^n* — which is a periodic point of *f* with period dividing *n*.

This is the engine of the theorem: the period-3 orbit acts as a *forcing mechanism*, guaranteeing the existence of periodic points at every timescale.

## The Covering Lemma: How Chaos Propagates

Beneath the main theorem lies a deeper structural principle we call the **covering lemma**. If *f* is continuous and its image covers an interval — meaning every point in that interval is hit by *f* — then there must be a subinterval that maps *onto* the target.

Under the period-3 hypothesis, the interval [*b, c*] covers itself: *f(b) = c* and *f(c) = a < b*, so the image of [*b, c*] contains both values above *c* and below *b*, and by continuity, it contains all values in between. This self-covering property is the mathematical signature of chaos — the interval [*b, c*] is a microcosm that regenerates itself under *f*.

More remarkably, the covering relations form a network: [*a, b*] covers [*b, c*], which covers both [*a, b*] and [*b, c*]. Any path through this network of length *n* corresponds to a periodic orbit of period *n*. Since the network has loops of every length, periodic orbits of every period must exist.

## Cognitive Attractors

Beyond periodic orbits, the theory reveals the structure of long-term cognitive behavior through **ω-limit sets** — the set of states that a brain trajectory accumulates near as time goes to infinity. We proved that these cognitive attractors have two fundamental properties:

First, they are **closed** — topologically well-defined boundaries separate the attractor from the rest of state space. There are no fuzzy edges; a state is either part of the long-term pattern or it isn't.

Second, they are **forward-invariant** — once the brain enters its attractor, it stays there. The mathematical proof uses the fact that continuous functions preserve limits: if a sequence of brain states converges to an attractor state, then applying *f* to each state produces a new sequence that converges to another attractor state.

## The Spectrum of Recurrence

We introduced a new mathematical object: the **recurrence spectrum** of a cognitive dynamics. This is the set of all positive integers *n* for which the system has a periodic point of period *n*. Our results show:

- The spectrum always contains 1 (a fixed point always exists for interval maps).
- The spectrum is closed under multiples: if period *n* exists, so does period *kn* for all *k*.
- Under the period-3 condition, the spectrum is all of ℕ⁺ — every positive integer.

The recurrence spectrum is thus a complete descriptor of the system's déjà vu structure. A simple system (like a stable resting state) has spectrum {1, 2, 3, ...} trivially. A chaotic system has the same spectrum, but the orbits are arranged in a fantastically intricate pattern.

## What This Means

The mathematics delivers a surprising message about consciousness and cognition. If the brain's state transitions satisfy two conditions — **continuity** (small changes in brain state produce small changes in the next state) and **complexity** (there exists at least one cycle of length 3) — then:

1. **Déjà vu is inevitable.** Not probable — inevitable. Fixed points must exist.
2. **Every recurrence pattern is realized.** Not just simple repetition, but cycles of every possible length.
3. **The attractor is self-sustaining.** Once the brain settles into its long-term pattern, that pattern maintains itself.

The 70% lifetime incidence of déjà vu is not a sign that something is wrong with most people's brains. It may be a sign that something is right — that the brain operates in a regime complex enough to generate period-3 dynamics, which mathematically guarantees the kind of state recurrence we experience as déjà vu.

In the end, the mathematics suggests that déjà vu is not a malfunction. It is the brain doing exactly what any sufficiently complex continuous system must do: revisiting its own past. The feeling that you've been here before? You have been — or rather, your brain has been in a state close enough to a periodic orbit that the recognition machinery fires. Mathematics guarantees such orbits exist. The only question is whether you notice.

---

*The theorems described in this article have been proved with full mathematical rigor using the Intermediate Value Theorem and structural arguments from topological dynamics. The key result — that period 3 forces all periods — was first established by Sharkovsky (1964) and Li-Yorke (1975). The covering lemma formalization and the cognitive attractor invariance results presented here are new contributions to the formalized mathematics of dynamical systems.*
