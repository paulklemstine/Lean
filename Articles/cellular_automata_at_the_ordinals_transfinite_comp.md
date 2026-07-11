# When Computers Count Past Infinity: Cellular Automata at the Ordinals

## A machine that never finishes—until it does

Imagine a row of light bulbs stretching off to the right, forever. They are numbered $0, 1, 2, 3, \dots$, one for every counting number. At the start, all of them are dark. Now we plug in a simple, rigid rule and let time tick forward:

- Bulb $0$ is special: it is wired directly to the wall, so it is always on.
- Every other bulb turns on at the next tick if and only if the bulb immediately to its *left* was on at the previous tick.

That is the whole machine. There is no controller, no memory, no clever program—just a local rule copied identically at every position, deciding each bulb's fate from the state of its neighbour. This is a *cellular automaton*, the same species of object that includes Conway's Game of Life and the intricate patterns of Rule 110.

Watch it run. At tick $1$, only bulb $0$ is on. At tick $2$, bulbs $0$ and $1$ glow. At tick $3$, bulbs $0, 1, 2$. In general, after $k$ ticks the lit bulbs are exactly $\{0, 1, \dots, k-1\}$—a wave of light advancing rightward at one bulb per tick, an unstoppable but agonizingly patient march.

Here is the puzzle. **Will every bulb eventually turn on?**

Your instinct says yes: give it enough time and the wave sweeps across the whole line. But "enough time" hides a trap. At *no finite moment* is the whole line lit. Pick any tick $k$ you like—a thousand, a trillion, a googolplex—and bulb number $k$ is still dark. The set of lit bulbs is always a *proper part* of the whole. The computation whose intended answer is "everything is on" never actually delivers that answer in ordinary time. It is a task that provably cannot be finished by any finite deadline.

And yet the answer is *supposed* to be "all of them." So where does the completed computation live?

## Counting past the last finite number

The resolution is one of the most beautiful ideas in mathematical logic: we let the clock run *past* infinity.

The ordinary counting numbers $0, 1, 2, \dots$ never reach an end—but mathematicians long ago learned to place a number *after all of them*. It is called $\omega$ (the Greek letter omega), the first *transfinite ordinal*. After $\omega$ come $\omega+1, \omega+2, \dots$, then $\omega \cdot 2$, and eventually $\omega^2$ and far beyond. These *ordinals* are the backbone of transfinite mathematics: an unending staircase where, crucially, some steps—the *limit stages* like $\omega$—sit at the very top of an infinite run of earlier steps with no immediate predecessor.

The question is what a machine should do *at* such a limit stage. It cannot look at "the previous step," because there is no previous step: $\omega$ has no ordinal just below it. So we need a *limit rule*. The natural one, the one used by *Infinite Time Turing Machines*—the transfinite computers studied in mathematical logic—is this:

> **At a limit stage, a bulb is on if it had switched on at some earlier stage and stayed on.**

In our automaton, once a bulb turns on it never turns off, so this rule simplifies beautifully: at the limit stage $\omega$, a bulb is on precisely if it was on at *some* finite tick. We take the *union* of everything that ever happened.

Now run the calculation. Every bulb $n$ turns on at tick $n+1$—a perfectly finite moment. So by the time we reach the limit stage $\omega$, *every* bulb has already had its turn. The union of all the finite stages is the entire line:

$$\text{(configuration at stage } \omega) \;=\; \bigcup_{k=0}^{\infty} \{0, 1, \dots, k-1\} \;=\; \{0, 1, 2, 3, \dots\}.$$

**At stage $\omega$, and not one moment sooner, every bulb is on.** The computation that could never finish in finite time finishes at the *first* infinite instant.

This is the whole drama in miniature. The task is impossible for every finite clock, yet completed at the first transfinite tick. Mathematicians say the automaton's **closure ordinal**—the exact stage at which it settles into its final, unchanging answer—is precisely $\omega$.

## Why the answer is "all of them," provably

It is one thing to watch the wave and *believe* it fills the line; it is another to *prove* that the fully-lit configuration is genuinely the right, canonical answer and not an arbitrary guess.

The rigorous formulation uses the idea of a *fixed point*. A configuration is *stable* under our rule if applying the rule changes nothing—the picture at the next tick is identical to the picture now. The all-on configuration is stable: bulb $0$ stays on (it is the source), and every other bulb stays on because its left neighbour is on. So "everything on" is a fixed point.

But is it the *right* fixed point? A cornerstone theorem about monotone rules—rules that never turn a bulb off once the input grows—guarantees that among all stable configurations there is a *least* one, the smallest fixed point reachable by starting from nothing and iterating. This *least fixed point* is the honest, canonical output of the computation. For our automaton one can prove, by a short induction sweeping rightward along the line, that the least fixed point is exactly the all-on configuration. The transfinite run does not merely *reach* some fixed point at stage $\omega$; it reaches *the* least fixed point—the intended answer, delivered on schedule at the first infinite ordinal.

## The dictionary between two worlds

The example is deliberately simple, but it is a window onto a sweeping correspondence—a dictionary translating the language of cellular automata into the language of transfinite computation:

| Cellular automaton | Ordinal computation |
| :--- | :--- |
| space of configurations | a complete lattice of states |
| local update rule | a monotone operator $f$ |
| one tick of the clock | one successor stage |
| the limit-of-time rule | a limit stage (take the union) |
| the completed computation | the least fixed point of $f$ |

The general principle behind the dictionary is a classical result on monotone operators: for *any* monotone update rule on *any* space of configurations that is rich enough to take unions (a "complete lattice"), the transfinite iteration—apply the rule at successor stages, take unions at limit stages—is *guaranteed* to reach the least fixed point at some ordinal stage. In other words:

> **Every monotone cellular-automaton rule, no matter how it is defined or on what space, has its final global answer reached by transfinite ordinal iteration.**

Ordinary Turing machines halt (or not) in finite time. Infinite Time Turing Machines keep computing across the ordinals, and this lets them decide problems no finite machine ever could. Our light bulbs are a cellular-automaton mascot for exactly this leap: the *finite-time* automaton is strictly weaker than its *transfinite* cousin, in the sharpest possible sense. There is a concrete, unambiguous task—light every bulb—that the finite machine can approach forever but never achieve, and the transfinite machine completes at its first infinite step.

## Beyond the first infinity

Why stop at $\omega$? The same machinery predicts a rich hierarchy. Consider an automaton on a *grid* of bulbs instead of a line, with the rule: fill row $i+1$ only once row $i$ is completely lit. Each individual row takes $\omega$ ticks to finish, and there are infinitely many rows to complete in sequence. Finishing all of them takes $\omega$ copies of $\omega$—the closure ordinal climbs to $\omega^2$. Stack the construction cleverly and you can engineer automata whose computations settle only at $\omega+1$, at $\omega \cdot 2$, at $\omega^2$, and onward up the transfinite staircase. The closure ordinal becomes a precise measure of a computation's *transfinite difficulty*.

There is a catch worth naming honestly. The clean fixed-point story relies on *monotonicity*—the promise that bulbs never switch off. The most famous cellular automata, like Rule 110, are *not* monotone; cells flicker on and off, and the tidy "take the union at limits" rule must be replaced by the more delicate *limit inferior* used by Infinite Time Turing Machines, which asks what a cell *eventually settles into*. Extending the transfinite picture to those genuinely oscillating, computationally universal automata is the frontier this work points toward: a full bridge on which the halting time of a cellular automaton becomes, literally, the halting time of a transfinite machine.

## Why it matters

At first glance, lighting an infinite row of bulbs is a toy. But it dramatizes a profound recalibration of what "computation" means. Computation need not end at a finite deadline; run on the ordinals, a rule as mindless as "copy your left neighbour" acquires the power to complete tasks that are demonstrably beyond every finite process. The same idea underlies the study of definability in logic, the analysis of when iterative processes stabilize, and the theory of super-Turing computation.

The moral is quietly radical. Infinity is not merely "a very long time." It is a *place*—a specific stage on a well-ordered staircase—where computations that were forever unfinished suddenly stand complete. Our little wave of light, which can never fill the line on any human or cosmic timescale, is already, waiting at the first step past infinity, entirely aglow.
