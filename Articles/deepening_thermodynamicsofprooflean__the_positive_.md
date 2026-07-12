# The Heat of Forgetting: What Groups Teach Us About the Cost of Reasoning

## A thermostat for thought

Every act of reasoning throws something away. When you conclude "the sum is
even," you have deliberately forgotten *which* even number it was. When you
reduce a fraction, you discard the common factor. When you check a parity, a
sign, or a residue, you compress a rich, detailed object down to a single crude
label — and in doing so you lose the ability to walk backwards to where you
started.

Physics has a precise name for this kind of loss and a precise price tag for it.
In 1961 Rolf Landauer observed that erasing information is not free: forgetting a
single bit must release at least $k_B T \ln 2$ joules of heat into the
surroundings, where $k_B$ is Boltzmann's constant and $T$ is the temperature.
Erasure is the one genuinely irreversible thing a computer does, and Landauer's
principle is the exchange rate between lost information and dissipated heat.

This article is about a surprising and exact meeting point between that physical
law and pure algebra. It turns out that when a step of reasoning *respects
structure* — when it is a homomorphism of groups — the amount of information it
destroys is not merely bounded or estimated. It is pinned down **exactly**, and
the quantity that measures it is one of the oldest objects in algebra: the
**kernel**. The punchline, which we will call the **Kernel Law**, is a single
clean sentence:

> A structure-preserving reasoning step erases exactly $\log_2 |\ker f|$ bits.

Irreversibility, literally, is the logarithm of the kernel.

## Measuring what a step forgets

Let us make the accounting concrete. Model a single step of reasoning as a
function $f : \alpha \to \beta$ that takes each input to its conclusion. If the
input space $\alpha$ is finite, then before the step you face
$|\alpha|$ equally plausible possibilities, carrying $\log_2 |\alpha|$ bits of
uncertainty. After the step, all you can observe is the output; the number of
distinguishable outputs is the size of the image, $|\operatorname{im} f|$,
carrying $\log_2 |\operatorname{im} f|$ bits. The difference is exactly the
information the step has thrown away. We call it the **erased bits**:
$$
\operatorname{erasedBits}(f) \;=\; \log_2 |\alpha| \;-\; \log_2 |\operatorname{im} f|.
$$
A step that loses nothing — a relabelling, a reversible substitution — has as
many outputs as inputs, so its erased bits are zero. A step that crushes
everything to a single answer erases all $\log_2 |\alpha|$ bits. Multiply the
erased bits by $k_B T \ln 2$ and you get the **Landauer heat**, the minimum
energy the physical process must dissipate:
$$
\operatorname{Heat}(f) \;=\; \operatorname{erasedBits}(f)\cdot k_B T \ln 2.
$$

So far this is just careful bookkeeping. The magic begins when the step has
algebraic structure.

## Enter the kernel

Suppose the input space is not a mere set but a **group** $G$ — a collection of
objects you can combine and invert, like symmetries, integers under addition, or
residues modulo $n$ — and suppose the reasoning step $f : G \to H$ is a
**homomorphism**: it commutes with the group operation, $f(xy) = f(x)f(y)$. This
is the algebraic version of "the step respects the structure it operates on."

Every homomorphism carries two fingerprints. Its **image**, $\operatorname{im}
f$, is the set of conclusions it can actually produce. Its **kernel**, $\ker f$,
is the set of inputs it sends to the identity — the elements it treats as
"nothing." The kernel is exactly the record of what the step cannot tell apart:
two inputs $x$ and $y$ land on the same output precisely when they differ by a
kernel element, $x = yk$ with $k \in \ker f$. The kernel *is* the ambiguity the
step introduces.

There is a two-thousand-year-old counting fact lurking here. Lagrange's theorem,
combined with the First Isomorphism Theorem, gives the exact identity
$$
|\operatorname{im} f| \cdot |\ker f| \;=\; |G|.
$$
Read it as a conservation law: the group splits perfectly into "what survives"
(the image) times "what is forgotten" (the kernel). Nothing is double-counted;
nothing leaks.

Now feed this into the erasure formula. Taking base-2 logarithms turns the
product into a sum, and the arithmetic collapses beautifully:
$$
\operatorname{erasedBits}(f) = \log_2 |G| - \log_2 |\operatorname{im} f|
= \log_2 \frac{|G|}{|\operatorname{im} f|} = \log_2 |\ker f|.
$$

That is the **Kernel Law**. The heat radiated by a structure-preserving inference
is fixed entirely by the size of its kernel — the group of differences it renders
invisible. You do not need to know anything about the outputs, the target group,
or how the step is implemented. Count the things it deliberately confuses, take a
logarithm, and you have the exact thermodynamic cost.

## When is reasoning reversible?

The Kernel Law comes with an immediate and satisfying corollary. A homomorphic
step erases zero bits — dissipates no heat, loses no information, and can in
principle be undone — **exactly when its kernel is trivial**, containing only the
identity. And a homomorphism has trivial kernel exactly when it is injective.
So:

> A structure-preserving step is thermodynamically free if and only if it is
> reversible, if and only if it forgets nothing, if and only if its kernel is
> trivial.

Four descriptions — physical, logical, informational, algebraic — that turn out
to be one and the same. This is the kind of coincidence that tells you a
definition has found the joint of nature.

## The price of a quotient

One reasoning move appears everywhere in mathematics: forming a **quotient**.
"Work modulo $n$." "Consider everything up to symmetry." "Identify points that
differ by a translation." Each of these collapses a group $G$ down to a quotient
$G / N$, gluing together every element that differs by a member of the subgroup
$N$.

What does this cost? The quotient map has kernel exactly $N$, so the Kernel Law
answers instantly:
$$
\operatorname{erasedBits}(G \to G/N) \;=\; \log_2 |N|.
$$
Passing to a quotient erases precisely the entropy of the subgroup you quotient
by. Reducing integers modulo $12$ (a clock) forgets $\log_2 12 \approx 3.585$
bits per number. The heat of that forgetting, by Landauer, is
$\log_2|N| \cdot k_B T \ln 2$. Abstraction has a temperature.

## A conservation law for pipelines

Reasoning rarely happens in one step; we chain inferences into pipelines. If
$f$ then $g$ are two homomorphic steps, how do their costs combine? In general
erasure is only **sub-additive**: composing steps can never erase more than the
two steps' individual budgets, because information once lost cannot be lost
again, and a second step may re-confuse things the first step had cleanly
separated.

But there is a special, important case where the ledger balances *exactly*. If
the first step $f$ is **surjective** — it produces every possible intermediate
conclusion, wasting no expressive capacity — then the kernels multiply,
$|\ker(g \circ f)| = |\ker f| \cdot |\ker g|$, and the erased bits **add
exactly**:
$$
\operatorname{erasedBits}(g \circ f) \;=\; \operatorname{erasedBits}(f) + \operatorname{erasedBits}(g).
$$
Exactness of the pipeline restores a genuine conservation law: on an efficient
(surjective) first stage, no dissipation is hidden, double-counted, or refunded.
The total heat of a chain of tight, structure-respecting steps is simply the sum
of the heats of its parts.

## Why this is more than a metaphor

It is tempting to file "the thermodynamics of proof" under poetry. What makes
this different is that every statement above is an *equality*, not an analogy.
The erased bits are a defined, computable number. The Kernel Law is an exact
theorem, resting on Lagrange's theorem and the First Isomorphism Theorem — two of
the most solid pillars in mathematics. The reversibility criterion, the quotient
cost, and the additivity law are exact consequences. There is no fudge factor and
no "up to a constant."

The perspective also reorganizes familiar algebra around a physical intuition.
The First Isomorphism Theorem, usually taught as a statement about isomorphic
quotients, becomes a **conservation of information**: image times kernel equals
domain. The size of a kernel, usually a technical quantity, becomes a
**dissipation**. And Lagrange's ancient counting theorem becomes the reason the
books always balance.

## The road ahead

The Kernel Law opens onto bolder conjectures, each a bet that a classical
algebraic theorem is secretly a thermodynamic one.

**The length law.** To fully dismantle a finite (solvable) group down to nothing,
you can follow any *composition series* — a maximal chain of subgroups, each
normal in the next. The Jordan–Hölder theorem says the factors of such a chain
are independent of the route you take. Translated through the Kernel Law, this
should become a conservation of heat: the minimal total dissipation of collapsing
$G$ to the trivial group is exactly $\log_2 |G|$, realized step by step by any
composition series, regardless of the path. The exact additivity along surjective
pipelines is precisely the telescoping mechanism such a proof needs.

**The spectrum of an endomorphism.** Iterating a single reasoning step $f : G \to
G$ produces a sequence of growing kernels, and hence a sequence of erased-bit
values $\log_2 |\ker f^n|$. Because information already lost cannot be lost again,
this sequence should be non-decreasing, concave, and eventually constant — a
discrete "spectrum" measuring how quickly repeated reasoning saturates, with the
index of stabilization recording the nilpotency length of the step.

**Balanced ledgers around short exact sequences.** Every short exact sequence
$1 \to N \to G \to Q \to 1$ packages a quotient (which costs $\log_2 |N|$) beside
an inclusion (which *creates* capacity). The conjecture is that the two readings
of the same subgroup close the books exactly: a short exact sequence is a
lossless thermodynamic cycle, not a leaky one.

Each of these would turn a pillar of group theory into a statement about the heat
of thought. The Kernel Law is the first brick: irreversibility is the logarithm
of the kernel, and forgetting, it turns out, is something you can weigh.
