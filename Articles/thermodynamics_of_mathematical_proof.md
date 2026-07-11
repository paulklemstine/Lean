# The Heat of Thinking: Why Some Proofs Must Burn More Energy Than Others

## A puzzle at the edge of physics and logic

Imagine a mathematician at a chalkboard, working late into the night. Line by line,
she rewrites expressions, merges cases, discards dead ends, and finally circles a
conclusion. It feels like pure thought — weightless, immaterial, free. But there is a
stubborn law of nature lurking behind the chalk dust, and it says something startling:
**erasing information costs energy.** Not metaphorically. Physically. In joules.

This is *Landauer's principle*, discovered in 1961 by the physicist Rolf Landauer.
It states that whenever a computing device destroys one bit of information — when it
overwrites a memory cell without keeping a record of what was there — it must dump at
least

$$k_B \, T \ln 2$$

of energy into its surroundings as heat. Here $k_B$ is Boltzmann's constant, $T$ is the
absolute temperature of the environment, and $\ln 2 \approx 0.693$. At room temperature
this is a minuscule amount — about $3 \times 10^{-21}$ joules per bit — but it is not
zero, and it cannot be cheated. It is the thermodynamic price of forgetting.

The question this article explores is deceptively simple and, as far as we can tell,
rarely asked: **if reasoning is a kind of computation, does a mathematical proof have a
minimum energy cost? And do some theorems cost more to prove than others?** The answer,
it turns out, is yes — and dramatically so. We will see that there are statements whose
verification must erase *exponentially* more information than others, and that there is a
hard, uncrossable floor on how cheaply certain truths can ever be checked.

## Proof steps as machines that forget

To make this precise, we treat every elementary act of reasoning — a rewrite, a
substitution, a case merge, a table lookup, the final "and therefore, QED" — as a
function

$$f : \alpha \to \beta$$

between two finite collections of states. The input set $\alpha$ is everything the step
could have started from; the output set $\beta$ is what it produces. This is the natural
picture of a logic gate, a line of a calculation, or a single move in a formal argument.

The crucial physical fact is that **information is lost exactly when two different inputs
collapse to the same output.** If $f$ maps eight distinct starting states down to two
possible answers, then six distinctions have vanished — you can no longer tell, from the
output alone, which of several inputs you began with. That lost distinguishability is the
information erased by the step.

We measure it with a single clean quantity. Let $|\mathrm{im}\, f|$ denote the number of
*distinct* outputs $f$ actually produces (the size of its image). Then the bits erased by
the step are

$$\mathrm{erased}(f) \;=\; \log_2 |\alpha| \;-\; \log_2 |\mathrm{im}\, f|.$$

The first term is the information content of the input register (how many bits it takes to
name a starting state); the second is the information content of the output. Their
difference is the entropy that had to go somewhere — and by Landauer's principle, that
somewhere is the environment, as heat.

## The first rule: forgetting is a one-way street

The very first thing one can prove about this quantity is that it is never negative:

> **A proof step never un-erases information.** For any step $f$, $\mathrm{erased}(f) \ge 0$.

This sounds obvious, but it encodes something deep. A computation cannot spontaneously
*create* distinguishability out of nothing; the image of a function can never be larger
than its domain. Forgetting is a one-way street. You can always throw information away;
you can never conjure it back by fiat.

## The reversibility criterion: which steps are free?

If erasure costs energy, the natural question is: **which steps are free?** The answer is
crisp and complete.

> **Reversibility criterion.** A step erases exactly zero bits if and only if it is
> *injective* — that is, if and only if no two distinct inputs are ever sent to the same
> output.

An injective step is *logically reversible*: from the output you can always reconstruct
the input, because nothing was merged. The classic example is the NOT gate, which simply
swaps `true` and `false`. It is constantly busy, yet it destroys nothing — every output
tells you exactly what the input was. So NOT is thermodynamically free.

This immediately refutes a tempting misconception: that any step which *does something* —
any non-trivial computation — must cost energy. It doesn't. The NOT gate is a perfect
counterexample: a non-identity operation that flips every bit and yet dissipates nothing.
**It is not activity that costs energy. It is irreversibility.** Only when a step forgets
— when it genuinely merges distinct possibilities — does the thermodynamic meter start to
run.

## Landauer's principle, made into a theorem

With the criterion in hand, the physical principle becomes a mathematical certainty. Once
we assign an energy cost

$$\mathrm{cost}(f) \;=\; \mathrm{erased}(f)\cdot k_B \, T \ln 2$$

to a step operating at temperature $T$, we can state:

> **Landauer's principle (strict form).** Any *irreversible* step — one that is not
> injective — dissipates strictly positive energy at any positive temperature:
> $\mathrm{cost}(f) > 0$.

The canonical example is the humble **AND gate**, the workhorse of every processor on
Earth. It takes two input bits and returns one. Of its four possible inputs — `(F,F)`,
`(F,T)`, `(T,F)`, `(T,T)` — three produce the output `false` and only one produces `true`.
Four states collapse onto two. The erasure is

$$\log_2 4 - \log_2 2 = 2 - 1 = 1 \text{ bit},$$

exactly the textbook $k_B T \ln 2$ of dissipation. Every AND gate in every chip is,
quite literally, a tiny furnace, and this is why.

## Forgetting compounds: the data-processing inequality

Real proofs are not single steps but long chains. What happens to erasure as steps
compose? Here we meet a thermodynamic version of a famous law from information theory:

> **Erasure is monotone along a pipeline.** If you follow a step $f$ by another step $g$,
> the total erasure can only grow: $\mathrm{erased}(f) \le \mathrm{erased}(g \circ f)$.

Information destroyed early in an argument cannot be resurrected later. Once a case merge
throws away which branch you were in, no downstream manipulation recovers it. This is the
logical analogue of the physical arrow of time: entropy accumulates, and a proof pipeline
can only ever forget more, never less, as it proceeds.

Interestingly, erasure is *not* additive. If you compose two steps that each erase one
bit, the total is generally *not* two bits — often it is still just one, because the
second step may be collapsing states that were already collapsed. Erasure is
*sub*-additive: the whole forgets no more than the sum of its parts, and often much less.

## The escape hatch: you never *have* to forget

If irreversibility is what costs energy, is there any way to compute without paying? A
beautiful idea due to Charles Bennett says yes: **keep a copy of the input.** Instead of
running the step $f : \alpha \to \beta$ as-is, run the augmented step

$$x \;\longmapsto\; (x,\, f(x))$$

which returns the answer *together with* the original question. This augmented step is
always injective — the first coordinate remembers everything — so by the reversibility
criterion it erases exactly zero bits.

> **Bennett's reversible embedding.** Retaining the input makes any step reversible; it
> erases zero bits.

The lesson is profound: **computation itself is free.** There is no thermodynamic law
forcing you to spend energy to calculate. The cost appears only when you *discard* your
working — when you clean the chalkboard, free the memory, throw away the scratch paper.
The heat of thinking is not the heat of thought; it is the heat of forgetting what you
thought.

## The main event: proofs that must burn exponentially more

Now for the striking part. Different theorems demand wildly different amounts of erasure,
and the gap can be astronomical.

Consider a decision procedure that examines $2^n$ possible configurations and returns a
single verdict — "yes" or, in the extreme, always the same answer. Such a *collapse* of
$2^n$ states onto one answer erases exactly $n$ bits. That is linear growth: doubling the
search space adds one bit of heat.

But now consider a procedure over a *doubly*-exponential space of $2^{(2^m)}$
configurations, again collapsed to a single verdict. Its erasure is

$$\log_2 2^{(2^m)} = 2^m \text{ bits}.$$

Comparing the two families over the same parameter $m$, the second erases $2^m$ bits while
the first erases only $m$ — the erasure of the big collapse is $2$ raised to the erasure of
the small one. This gives our headline result:

> **Exponential erasure separation.** For any bound $C$, however large, there is a
> verification whose erasure exceeds $C$. Indeed, there are theorems whose checking erases
> exponentially many bits in a natural size parameter, and therefore dissipates
> exponentially more heat than others at the same temperature.

In physical terms: the dissipated heat of collapsing a $2^{(2^m)}$-state search to one
answer is $2^m \cdot k_B T \ln 2$, which explodes as $m$ grows. Some truths are simply
hotter to establish than others, and no amount of cleverness at fixed temperature can
avoid it — unless you are willing to keep all your scratch work forever.

## The floor beneath every proof: incompressibility

Is there a *minimum*? Could a sufficiently clever prover always find some short, cheap
route to any truth? Here we brush against one of the deepest ideas in computer science,
*Kolmogorov complexity* — the length of the shortest program that produces a given object.

A simple but powerful counting argument settles it. Consider all the Boolean predicates
on $n$ bits — all the possible "yes/no properties" of an $n$-bit string. There are $2^n$
of them (one for each possible truth table). Now try to give each one a short description,
a program of length less than $n$ bits. There are only $2^n - 1$ such short programs.
By the pigeonhole principle, you cannot fit $2^n$ distinct predicates into fewer than
$2^n$ pigeonholes:

> **Incompressibility.** There is no way to assign to every Boolean predicate on $n$ bits
> a distinct description shorter than $n$ bits. Hence some predicate has no proof, and no
> description, shorter than $n$ bits.

For such an incompressible predicate, verifying it — storing and eventually erasing its
full truth table — must destroy at least $n$ bits of information, and so must dissipate at
least

$$n \cdot k_B \, T \ln 2$$

of heat. There is a genuine floor. Most mathematical facts are, in this precise sense,
*hard*: they cannot be captured by any argument dramatically shorter than themselves, and
their verification carries an irreducible energy cost.

## Why this matters

At one level, this is a playful thought experiment: dressing up the ancient romance of
mathematical discovery in the language of furnaces and entropy. But the connections are
real, and they run in both directions.

For the **engineers** building the next generation of processors, Landauer's principle is
not a curiosity but a looming wall. As transistors shrink and clock speeds rise, the
$k_B T \ln 2$ per erased bit becomes a dominant term in the energy budget. Reversible
computing — computing that keeps its scratch work and thereby forgets nothing — is a
serious research program precisely because Bennett's embedding shows it is possible in
principle to compute for free.

For the **logicians and complexity theorists**, the framework offers a fresh lens on an
old mystery: why are some theorems so much harder than others? The exponential erasure
separation and the incompressibility floor suggest that "hardness" has a thermodynamic
shadow — that the difficulty of a proof is mirrored in the heat it must shed.

And for the rest of us, there is a quiet philosophical payoff. We often imagine thought
as ethereal, untethered from the physical world. The thermodynamics of proof insists
otherwise. Every deduction that discards a possibility, every case ruled out, every
alternative forgotten, leaves a faint warmth in the universe. Reasoning is not free. To
know something for certain — to collapse the vast space of what *might* be true down to
the single point of what *is* — is, in the most literal sense, to generate heat.

The chalkboard, it turns out, was never weightless after all.
