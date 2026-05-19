# The Machines That Can't Count: How Finite Automata Reveal the Secret Lives of Numbers

## A tiny machine meets an infinite decimal

Imagine you are building a machine — the simplest kind imaginable. It has a handful of internal states, like a combination lock with only a few positions. At each tick of a clock, it reads its current state, clicks to a new one according to a fixed rule, and writes down a digit. Turn after turn, it spits out an endless stream: 3, 1, 4, 1, 5, 9, 2, 6 …

This kind of device — a *finite-state machine* — is the workhorse of computer science. It powers the spell-checker in your phone, the traffic-light controller at the corner, and the lexical analyzer inside every compiler ever written. It is breathtakingly simple: a finite memory, a fixed transition rule, and no ability whatsoever to "learn" or grow more complex over time.

Now pose a deceptively innocent question: **Can such a machine write down the decimal expansion of the square root of two?**

The answer turns out to connect three seemingly unrelated fields — the theory of automata, the deep structure of algebraic numbers, and a branch of mathematics called symbolic dynamics that studies patterns in infinite sequences. And the answer is a resounding, provable *no*.

## Patterns in the digits of numbers

To understand why, we need to talk about patterns.

Take a rational number like 1/7, whose decimal expansion is 0.142857142857142857… The block "142857" repeats forever. That repetition is the hallmark of rationality: a number is rational if and only if its decimal expansion eventually settles into a repeating cycle.

Now consider an *algebraic irrational* number — a number like √2 (roughly 1.41421356…) that satisfies a polynomial equation with integer coefficients (x² = 2) but is not rational. Its digits never repeat. They seem chaotic, unpredictable, resistant to compression. But how resistant, exactly?

One way to measure the "complexity" of an infinite digit sequence is to count its *subword complexity*: for each length *n*, how many distinct blocks of *n* consecutive digits appear? A repeating sequence like 142857142857… has at most 6 distinct blocks of any length. A truly random sequence would have roughly 10ⁿ distinct blocks (in base 10). The subword complexity function, *p(n)*, captures how "patterned" or "chaotic" the digit stream really is.

## The Adamczewski–Bugeaud revolution

In 2007, two French mathematicians — Boris Adamczewski and Yann Bugeaud — proved something astonishing. They showed that if the digit sequence of a real number has *low* subword complexity — specifically, if *p(n)* grows at most linearly, bounded by *Cn + D* for some constants *C* and *D* — and if the number is algebraic, then the digit sequence must eventually repeat. In other words, the number must be rational.

Turn that around, and you get a powerful transcendence criterion: **if a number's digits have low complexity but don't repeat, the number must be transcendental** — it cannot satisfy any polynomial equation with integer coefficients. It is as arithmetically wild as π or *e*.

This was a landmark result, drawing on some of the heaviest artillery in number theory: the Schmidt Subspace Theorem, a deep generalization of results in Diophantine approximation. But it left a question hanging: **which naturally occurring digit sequences actually have low complexity?**

## Enter the sofic shift

This is where symbolic dynamics enters the story.

Symbolic dynamics studies the behavior of infinite sequences over a finite alphabet — exactly the kind of sequences that describe digit expansions. One of its central objects is the *shift space*: a collection of infinite sequences that is closed under the operation of "shifting" (dropping the first symbol and renaming the rest). Shift spaces are the symbolic cousins of dynamical systems, encoding their orbits as strings of symbols.

Among shift spaces, there is a particularly well-behaved class called *sofic shifts*. A sofic shift is one that can be described by a finite labeled graph: you walk along the edges of the graph forever, and the edge labels you read off form the sequences in the shift. Every regular language you ever encountered in a computer science class defines a sofic shift. They are the "finite-state" shift spaces.

Here is the key mathematical fact: **sofic shifts have linear subword complexity.** Because the sequences are constrained to follow paths in a finite graph, the number of distinct length-*n* subwords can grow at most linearly. The finite graph "compresses" the combinatorial possibilities.

## The synthesis: finite states force transcendence

Now the pieces snap together like a puzzle:

1. A sofic shift has linear subword complexity.
2. If a shift is *aperiodic* (no sequence in it is periodic) and *minimal* (every pattern that appears anywhere appears everywhere), then no sequence in it is eventually periodic.
3. Linear complexity plus non-periodicity, by the Adamczewski–Bugeaud theorem, implies transcendence.

**Conclusion: if you take any number whose digit expansion comes from a minimal aperiodic sofic shift, that number is transcendental.**

This is a theorem that converts *structural regularity* — membership in a finite-state dynamical system — into an *arithmetic impossibility*: the number cannot satisfy any polynomial equation.

## The compression gap

There is an even more striking way to state the result. Think about trying to "compress" the digit expansion of an algebraic irrational number using finite-state machines.

A finite-state machine with *K* states, iterating from an initial state, can only produce sequences that eventually cycle — by the *pigeonhole principle*, the machine must revisit a state within *K* steps, and from that point its output repeats forever. So any sequence produced by a fixed *K*-state machine is eventually periodic.

But the Adamczewski–Bugeaud theorem tells us that the digit expansion of an algebraic irrational with low subword complexity cannot be eventually periodic. This means:

**No finite-state machine of any fixed size can generate the digit expansion of an algebraic irrational number.**

To write down more and more digits of √2, you need machines with more and more states. The finite-state complexity of the digit prefixes is *unbounded*. This is a rigorous sense in which algebraic irrationals are "incompressible" by finite automata — a lower bound on the computational resources needed to describe their digits.

## Why this matters beyond pure mathematics

This result sits at a crossroads of several fields:

**Computer science.** It provides a formal lower bound on the complexity of a natural computational task — generating digits of algebraic numbers. This echoes the great theme of computational complexity theory: proving that certain problems *require* a minimum amount of resources.

**Information theory.** The unbounded finite-state complexity of algebraic irrationals can be read as a statement about their *information content*. Even though these numbers are determined by a finite polynomial equation, their digit expansions carry information that no finite-state device can replicate. There is an irreducible gap between the algebraic description of a number and the sequential description of its digits.

**Cryptography and pseudorandomness.** Sequences generated by finite-state machines are sometimes used as pseudorandom number generators. The fact that algebraic irrational digit expansions cannot be so generated means they have a provable form of pseudorandomness — at least against finite-state distinguishers.

**Dynamical systems.** The theorem turns a classification of shift spaces (sofic, minimal, aperiodic) into a classification of real numbers (transcendental). This is a new kind of bridge between the qualitative theory of dynamical systems and the quantitative world of number theory.

## Concrete examples

The theory applies to many familiar objects:

- **Sturmian sequences.** These are the simplest aperiodic sequences, with complexity *p(n) = n + 1*. They arise from irrational rotations of the circle. Any number whose digit expansion is Sturmian is transcendental.

- **The Thue–Morse sequence** (0, 1, 1, 0, 1, 0, 0, 1, …), defined by the parity of the number of 1s in the binary representation of *n*. This 2-automatic sequence has linear complexity and is not eventually periodic. The real number 0.01101001… (in base 2) is transcendental.

- **Substitution sequences.** Start with a single symbol and repeatedly apply a substitution rule (like a → ab, b → ba). The resulting fixed-point sequence often has linear complexity. If it is aperiodic, the corresponding digit real is transcendental.

Each of these examples was known individually, through separate arguments. What the sofic transcendence theorem provides is a *unified framework* that handles them all at once — and extends to sequences that have never been individually analyzed.

## The deeper invariant: follower sets

The sharpest version of the theory isolates the true combinatorial reason behind the linear complexity bound. In any shift space, the *follower set* of a word *w* is the collection of words that can appear immediately after *w* in some sequence of the shift. The number of distinct follower sets is an invariant of the shift.

If this number is finite — as it always is for sofic shifts — then the subword complexity grows at most linearly. This *finite follower-set principle* is more general than soficity alone: it applies to any shift with this finiteness property, including some that are not sofic.

This opens a corridor toward even broader transcendence results, applicable to wider classes of symbolic systems — S-adic sequences, quasi-sofic shifts, and beyond.

## A new arithmetic complexity theory

What makes this work genuinely new is not any single theorem, but the *framework* it establishes. It converts properties of abstract dynamical systems — minimality, aperiodicity, soficity, finite follower sets — directly into arithmetic conclusions about real numbers. It is the beginning of what might be called an *arithmetic complexity theory of digit expansions*:

- **Low dynamical complexity** (finite-state, sofic, linear subword growth) implies **high arithmetic complexity** (transcendence).
- **Algebraic simplicity** (being a root of a polynomial) implies **high sequential complexity** (unbounded finite-state description).

These are dual statements, and together they carve out a new landscape at the intersection of dynamics, computation, and number theory. The old intuition that "too much regularity forces transcendence" has been made precise, general, and machine-checkable. And the door is now open to explore how far it extends.
