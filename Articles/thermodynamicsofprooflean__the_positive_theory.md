# The Heat of Thinking: What It Costs to Prove Something

## A bill you never knew you were paying

Every time a computer forgets something, it warms the room a little. This is
not a metaphor. In 1961 the physicist Rolf Landauer noticed that the laws of
thermodynamics do not care whether the bits being shuffled around live in a
steam engine or a silicon chip. Erasing information — genuinely throwing it
away, so that it can never be recovered — has an unavoidable energy price. To
destroy a single bit at temperature $T$, you must release at least

$$
k_B\, T \ln 2
$$

joules of heat into the surroundings, where $k_B$ is Boltzmann's constant. At
room temperature that is about $3 \times 10^{-21}$ joules per bit: minuscule,
but stubbornly greater than zero. You cannot forget for free.

Landauer's principle is usually told as a story about *computation*. This
article is about a stranger and more beautiful idea: the same principle governs
*proof*. A mathematical derivation, it turns out, has a temperature. It
dissipates heat. And it obeys a second law of thermodynamics all its own.

## Proofs as machines that forget

Picture a proof not as a sequence of sentences but as a sequence of operations
on a *register* — a finite collection of possible states, like the settings of
a bank of switches. Each inference step is a function $f$ that takes the
register from one configuration to another. Modus ponens, a substitution, the
application of a lemma: each is a rule that reads the current state and writes a
new one.

Here is the crucial observation. Some steps are *reversible*: given the output,
you could reconstruct the input. Relabelling variables, negating a Boolean,
swapping two rows — no information is lost, because the map is a one-to-one
correspondence. Other steps are *irreversible*: they merge distinct
possibilities into one. The logical AND of two bits is the classic example.
From the answer "true" you can recover the inputs (both were true), but from
"false" you cannot tell which of three input patterns produced it. Three
possibilities have collapsed into one. That collapse is a forgetting, and by
Landauer's principle it must be paid for in heat.

To make this precise, measure the *size* of a register by the base-two
logarithm of how many states it can distinguish. A step $f : \alpha \to \beta$
takes a register that can be in $\lvert\alpha\rvert$ states and produces one
whose realized values number only $\lvert \operatorname{image} f\rvert$. The
**erased information** is the drop in that logarithmic size:

$$
\operatorname{erased}(f) \;=\; \log_2 \lvert\alpha\rvert \;-\; \log_2 \lvert \operatorname{image} f\rvert .
$$

Multiply by $k_B T \ln 2$ and you get the minimum heat the step must dissipate.
Everything in this article flows from that one definition.

## Four facts that pin the idea down

The definition immediately yields a handful of clean, exact statements — the
kind that turn a suggestive analogy into a theory.

**Erasure is never negative.** Since a function's image is never larger than its
domain, $\operatorname{erased}(f) \ge 0$ always. You cannot un-forget by
running a step; information does not spontaneously appear.

**Zero cost is exactly reversibility.** A step erases *no* information if and
only if it is injective — a genuine one-to-one map. This is the reversibility
criterion, and it is an *if and only if*: reversibility and free-of-charge are
the very same condition, not merely related. The NOT gate, a bijection, erases
nothing; the AND gate, which merges three inputs into one output, erases exactly
one bit.

**Irreversibility always costs.** Combine the two: at any positive temperature,
a step that is *not* injective dissipates strictly positive heat. This is
Landauer's principle in its sharpest form — not "roughly" or "on average," but
as a hard inequality with no exceptions.

**Forgetting is monotone along a pipeline.** If you run one step and then
another, the total information erased can only grow. Distinctions destroyed
early cannot be resurrected by anything downstream. Physicists call the analogue
a *data-processing inequality*; here it says that a proof cannot repair its own
forgetting.

Two tempting-sounding "obvious" claims turn out to be *false*, and catching them
is part of what makes the theory honest. First, it is *not* true that every
nontrivial step erases something — the NOT gate rearranges without forgetting.
Second, erasure is *not* additive: the information lost by doing $g$ after $f$
is generally *less* than the sum of what each loses alone, because $g$ may
merely re-collapse distinctions that $f$ already destroyed. The correct law is
sub-additivity, and getting this right is the key to everything that follows.

## Bennett's escape hatch: computing for free

If irreversibility costs energy, is thinking doomed to be expensive? Charles
Bennett found the loophole in the 1970s, and it survives intact here. Take any
step $f$, however lossy, and replace it with the map

$$
x \;\longmapsto\; (x, f(x)),
$$

which keeps a copy of the input alongside the output. This dilated map is
injective — you can always read off $x$ from the first coordinate — so it erases
*zero* bits. Computation *per se* is thermodynamically free. Only the act of
*discarding* the retained input, at the very end, incurs Landauer's charge.

But there is no free lunch, only a relocated bill. Retaining the input means
*allocating* fresh register space to hold the answer. If we track this
explicitly with a **creation** ledger — bits written into newly allocated
ancilla — then Bennett's trick erases nothing but *creates* exactly
$\log_2 \lvert\beta\rvert$ bits of new register, where $\beta$ is the space of
outputs. Erasure and creation are two columns of a single account book.
Reversibility is not free; it is *financed*, paid for in allocation rather than
in heat.

## A second law for derivations

The heart of this work lifts the single-step story to an entire proof. Model a
derivation as a list of steps $[f_1, f_2, \dots, f_k]$ applied in order to a
fixed register, with composite

$$
F \;=\; f_k \circ \cdots \circ f_2 \circ f_1 .
$$

The total information erased by the whole derivation is simply
$\operatorname{erased}(F)$. The subtle move — the one that makes the theory
work — is to attribute to each step not its *standalone* cost but its *marginal*
contribution in context: the drop in register size that *this* step causes given
everything before it. Call that the step's **entropy production**. Because
erasure is only sub-additive, standalone costs would not add up; marginal
productions do.

With that definition, three results snap into place, and together they form a
genuine second law of thermodynamics for proof.

**The ledger identity.** Appending one step to a derivation increases the total
erased information by *exactly* that step's entropy production. Nothing is lost
in the bookkeeping; the account balances to the last bit.

**Every step produces nonnegative entropy.** The marginal contribution of any
step is $\ge 0$ — the per-step data-processing inequality. No inference can
reduce the running total.

**The Clausius inequality for proofs.** Put these together and the total
information erased by a derivation *decomposes as a sum of nonnegative per-step
productions*, one contribution per inference, and that sum equals the total
dissipation exactly. This is the discrete analogue of Clausius's inequality, the
inequality that first made the word *entropy* necessary. A proof's total heat is
the sum of the heats of its steps, and each term is nonnegative.

From the Clausius decomposition, everything physical follows. **Extending a
derivation never decreases its dissipated heat**: a longer road to the same
conclusion is never thermodynamically cheaper. And a derivation dissipates
*zero* heat **if and only if** its composite is reversible — which happens
exactly when every step is reversible. Elegant proofs, in this precise sense,
are cool ones.

## Some proofs must run hot

Is any of this ever more than a rounding error? Yes — the cost can be made
arbitrarily, even *exponentially*, large.

Consider a family of "collapsing" steps that funnel an $n$-bit register down to
a single value. Verifying such a step erases $n$ bits — linear in the size of
the problem. A more dramatic family collapses a register of $2^m$ states,
erasing $2^m$ bits: exponential. There is no universal ceiling on how much a
single act of verification can forget.

The deepest instance is a counting argument in the spirit of Kolmogorov
complexity. There are $2^n$ possible Boolean predicates on $n$ input bits, but
only $2^n - 1$ possible programs shorter than $n$ bits. Pigeonhole is merciless:
*some* predicate cannot be described by any program shorter than itself. It is
*incompressible*. To verify such a predicate you must, in effect, handle its
entire truth table, and erasing that table costs at least $n \cdot k_B T \ln 2$
joules. There exist truths whose checking is intrinsically, unavoidably hot —
not because we are clumsy, but because information theory forbids anything
cheaper.

## Why this is beautiful, and where it points

Mathematicians prize *elegant* proofs and disdain *brute-force* ones, and they
have always described the difference in aesthetic language. This theory offers a
physical one. An elegant proof is a reversible one: it rearranges information
without destroying it, and dissipates no heat. A brute-force proof is a furnace,
forgetting mountains of case analysis and paying for every bit. The second law
of derivations says the ledger always balances and the heat only accumulates —
so the search for elegance is, quite literally, a search for cooler ways to
know.

The open horizon is inviting. Real proofs branch and merge rather than marching
in a line, and one expects the Clausius sum to survive on such networks as an
additive quantity over their edges, invariant under how one chooses to serialize
them. One expects reversibility to be checkable locally, step by step, without
ever forming the whole composite. And one expects Bennett's trade-off to be
*tight*: among all reversible ways to implement a lossy step, retaining the
input should create the least possible ancilla, with a matching lower bound
forbidding anything thriftier. Each of these is a sharp, testable claim — the
signature of a theory that has stopped being a metaphor and started being
mathematics.

Landauer said it best: *information is physical*. What this work adds is that
*proof* is physical too. Every theorem you have ever believed was purchased, at
the bottom, with a whisper of heat.
