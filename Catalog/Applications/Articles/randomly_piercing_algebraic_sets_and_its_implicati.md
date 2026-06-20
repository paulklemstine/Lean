# The Smallest Machines That Never Forget Their Place

## A tiny memory, an infinite tape, and a surprisingly deep question

Imagine a machine so simple it can be drawn on the back of a napkin. It has a
handful of internal "moods" — call them states — and nothing else. No scratch
pad, no counter, no clock. You feed it a string of symbols one at a time. Each
symbol nudges the machine from its current mood into another, according to a
fixed rulebook. When the string runs out, the machine looks at the mood it
landed in and announces a single answer.

That is the whole device. It is called a **deterministic finite automaton with
output** — a *DFAO*, for short — and despite having less memory than a light
switch with three positions, it is one of the most quietly profound objects in
the theory of computation. This article is about what such machines can and
cannot do, and about a beautiful boundary line that separates the two.

## A sequence you can already compute in your head

Let's start with a number trick. Take any whole number $n$, write it in binary,
and count how many $1$s appear. If the count is even, write $0$; if it's odd,
write $1$. Doing this for $n = 0, 1, 2, 3, \dots$ produces

$$0,\ 1,\ 1,\ 0,\ 1,\ 0,\ 0,\ 1,\ 1,\ 0,\ 0,\ 1,\ \dots$$

This is the famous **Thue–Morse sequence**, and it shows up everywhere from
chess endgame rules to the design of fair coin-flipping protocols to the
spacing of musical rhythms that avoid monotony.

Here is the remarkable part. You do **not** need to count anything to compute
it with a machine. Build a DFAO with exactly two moods, "even" and "odd". Start
in "even". Reading a $0$ leaves your mood unchanged; reading a $1$ flips it.
Label the "even" mood with output $0$ and the "odd" mood with output $1$. Now
feed the machine the binary digits of $n$. The mood it ends in is exactly the
parity of the number of $1$s — so its output is exactly the $n$-th Thue–Morse
value. Two moods. No arithmetic. The entire infinite sequence is encoded in a
diagram you could sketch in five seconds.

A sequence that can be produced this way — by feeding the base-$k$ digits of $n$
into some fixed finite machine — is called **$k$-automatic**. The Thue–Morse
sequence is $2$-automatic. So is the sequence telling you whether $n$ is
divisible by $7$ (read the digits, track the remainder, output yes/no). So are
countless others. These sequences sit at a sweet spot: complex enough to be
interesting, structured enough to be completely understood.

## What "finite memory" really costs

The deep question is the flip side: **what is forever out of reach** for such a
machine? If a device has only finitely many moods, what kinds of patterns can it
*never* produce, no matter how cleverly you wire it?

The answer turns on a single, almost obvious-sounding observation, which is the
spine of everything that follows.

> **The Finite-Range Principle.** Every sequence produced by a finite-memory
> machine takes only finitely many distinct values.

Why? Because the machine's only act of "speaking" is to read off the label of
whichever mood it lands in. There are finitely many moods, so there are finitely
many possible labels, so there are finitely many possible answers — full stop.
The output of the $n$-th term is *always* one of the labels on the machine's
states, and a finite machine has only finitely many states.

This is the theorem the formal development calls **`range_finite`**: a
$k$-automatic sequence has finite range. It sounds modest. It is, in fact, a
sledgehammer.

## The sequence even a child can write, and no finite machine can

Consider the simplest infinite sequence imaginable:

$$0,\ 1,\ 2,\ 3,\ 4,\ 5,\ 6,\ \dots$$

the identity sequence, where the $n$-th term is just $n$ itself. A six-year-old
can continue it forever. Can a DFAO produce it?

No — and the reason is now a one-line knockout. The identity sequence takes
*infinitely many* distinct values: every natural number appears exactly once. By
the Finite-Range Principle, any automatic sequence takes only finitely many
values. A sequence cannot be both, so the identity sequence is **not
$k$-automatic for any $k$ whatsoever.**

In the formal development this is the result **`not_isKAutomatic_id`**, sitting
on top of its general engine **`not_of_range_infinite`** (infinite range forbids
automaticity). It is a clean impossibility theorem: there is no finite machine,
over any digit base, in any number of states, that prints the counting numbers
when fed their own digits. The humble act of *counting* — of producing ever-new
values — is precisely the thing a bounded memory cannot do. Finiteness of memory
is exactly a finiteness of vocabulary.

## Mapping the territory a machine can actually visit

If states are the machine's vocabulary, which states does it ever *use*? Starting
from its initial mood, reading symbols walks it around its state diagram like a
token on a board game. A state is **reachable** if some input word lands the
machine there. Some states might be islands, wired in but never visited.

How do you find the reachable ones? You explore outward in waves. Begin with
just the start state. In each round, add every state you can hop to in one step
from a state you already have. Repeat. This is breadth-first search, and the
formal development packages each wave as the operation **`expand`** and the
$n$-th wave as **`reach n`**.

Two facts make this exploration trustworthy and finite:

- **Soundness:** everything the search ever adds is genuinely reachable by a real
  input word (`mem_reach_imp_reachable`). The search never hallucinates a state.
- **Termination:** the waves can only grow, and they live inside a finite pool of
  states, so they must eventually stop growing. The formal argument
  (`reach_card_ge` feeding `exists_reach_stable`) is a crisp pigeonhole count: if
  the search had *not* settled down within its first $N$ rounds, where $N$ is the
  number of states, then round $N$ would already contain more than $N$ distinct
  states — impossible, since there are only $N$ to be had. So it *must* settle
  within $N$ rounds, and once a round adds nothing new (`reach_stable`), no later
  round ever will. The fixed point reached at round $N$ is the complete map of
  the machine's reachable world (`reachSet`).

This turns a question about *all infinitely many possible input strings* into a
finite computation you can actually run. And it immediately pays off.

## "Will this machine ever say that?" — decidably yes or no

Suppose you hand me a DFAO and ask: is there *any* input string at all — out of
the infinitely many possible strings — that makes this machine output the answer
`a`? At first glance you'd have to check infinitely many inputs.

You don't. Because an output is just a label on a *reachable* state, the machine
can produce `a` if and only if some reachable state is labeled `a`. And we just
showed the reachable states form a finite, computable set. So the question
reduces to scanning a finite list and checking labels. This is the result
**`decidableOccurs`**: for a fixed machine and target output, the existence of a
witnessing word is **decidable** — answerable, with certainty, by a terminating
search. The infinite search collapses into a finite one, exactly because finite
memory means a finite map.

## The unary world: where every story eventually repeats

There is one last corner worth visiting, and it is the purest expression of the
whole philosophy. Suppose the input alphabet has just a single symbol. Then
"reading a word of length $n$" means nothing more than "apply the one transition
$n$ times." The sequence of outputs is

$$\text{out}(q_0),\ \text{out}(\text{step}(q_0)),\ \text{out}(\text{step}(\text{step}(q_0))),\ \dots$$

— the machine repeatedly nudged by its single move. With finitely many states,
this walk is a token marching along arrows until it inevitably revisits a state
it has seen before. From that moment on, it is trapped in a cycle and repeats
forever.

So the output sequence has a "tail" shape: a finite, possibly irregular run-up,
followed by an endlessly repeating block. The formal result
**`eventuallyPeriodic`** states exactly this: every unary automaton's output
sequence is **eventually periodic**. This is the one-symbol shadow of a vast
truth in dynamics — any deterministic process in a finite world must, sooner or
later, cycle. There is no room to be eternally novel inside a finite space.

## The moral: finiteness is a vocabulary, not a vault

Step back and the pieces snap into a single picture. A finite machine is not a
vault holding boundless cleverness; it is a fixed, finite vocabulary of moods.
Everything it can ever say lives in that vocabulary. From this one fact flows the
whole landscape:

- It can produce intricate, aperiodic-looking sequences like Thue–Morse — but
  only ones that draw on **finitely many values** (`range_finite`).
- It can therefore **never** count, never produce the plain sequence
  $0, 1, 2, 3, \dots$, because counting demands endlessly fresh values
  (`not_isKAutomatic_id`).
- Its reachable behavior is a **finite, mappable** territory you can compute by
  breadth-first waves that provably terminate (`reach`, `exists_reach_stable`,
  `reachSet`).
- Questions about its infinite future therefore become **finite, decidable**
  checks (`decidableOccurs`).
- And in the most constrained setting of all, a single input symbol, its destiny
  is to **repeat forever** (`eventuallyPeriodic`).

These are not five unrelated facts. They are five faces of one principle:
*a finite memory can be endlessly subtle, but it can never be endlessly new.*
The boundary between what bounded computation can and cannot do is drawn,
precisely and provably, by the size of its own vocabulary. That a device simpler
than a doorbell already runs headlong into the limits of the possible is, in the
end, the quiet wonder at the heart of the theory of computation.
