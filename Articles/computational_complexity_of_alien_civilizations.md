# The Mathematics Every Alien Must Discover

Imagine, somewhere across the gulf of interstellar space, a civilization utterly
unlike our own. Perhaps its members are clouds of plasma dancing in a star's
corona, or crystalline lattices growing in the cold of a rogue planet, or vast
networks of chemical signals in a planet-wide ocean. They share none of our
biology, none of our history, none of our accidents of language. And yet — if
they build machines that compute, if they write anything we would recognize as a
*program* — they will inevitably run into exactly the same wall we did.

They will discover that some questions cannot be answered by any program at all.
They will discover that the universe of "problems" is bottomless, an infinite
staircase with no top step. They will discover that a program can be made to
print its own source code, and that no system powerful enough to talk about all
its own procedures can also decide the truth of all its own questions. And if
they somehow build a *hypercomputer* — a machine that transcends the ordinary
limits of computation — they will find that the wall has simply moved up one
floor and is waiting for them there too.

None of this is an accident of silicon, or of carbon, or of the particular
machines we happen to have built. It is a theorem about the *shape* of
computation itself. This article is about that theorem, and about why the deepest
truths of computer science are not inventions but discoveries — facts as
universal as the fact that a circle's circumference is $2\pi$ times its radius.

## One idea behind every impossibility

In our own history, the great impossibility results arrived one at a time, each
looking like its own separate marvel. Cantor proved that there is no way to list
all the real numbers — that infinity comes in different sizes. Russell found a
paradox at the heart of naive set theory: the set of all sets that do not contain
themselves. Gödel showed that any consistent mathematical system rich enough to
describe arithmetic must contain true statements it cannot prove. Turing proved
that no program can decide, in general, whether another program will eventually
halt. Tarski showed that no language can consistently define its own notion of
truth.

For decades these looked like five different mountains. But they are five faces
of a single peak. There is one clean statement of pure logic — nothing about
machines, nothing about physics, nothing about bits — from which every one of
them follows by choosing a couple of ingredients. It is called the **fixed-point
theorem**, and it goes like this.

Suppose we have a collection $A$ of "codes," and each code names a function that
takes a code and produces an "answer" of some type $B$. Write $\varphi(a)$ for
the function named by code $a$; then $\varphi(a)(x)$ is the answer that code $a$
gives when handed code $x$. Call the coding scheme **complete** if *every*
function from codes to answers is named by some code — nothing is left out.

**The Fixed-Point Theorem.** *If the coding scheme is complete, then every
transformation $f$ of answers has a fixed point: some answer $b$ with
$f(b) = b$.*

The proof is a single, almost magical line. Consider the "diagonal" function
$d(x) = f(\varphi(x)(x))$ — feed each code to itself, then bend the result with
$f$. Because the scheme is complete, some code $a$ names this very function, so
$\varphi(a) = d$. Now evaluate at $a$:
$$\varphi(a)(a) = d(a) = f(\varphi(a)(a)).$$
The value $b = \varphi(a)(a)$ satisfies $f(b) = b$. Done.

That is the whole engine. Everything else is a matter of what you plug in.

## Turning the crank

Read the theorem *backwards* and it becomes a machine for proving that things are
impossible. If some transformation $f$ has *no* fixed point, then no coding
scheme can be complete — something must always slip through the net.

Choose the answers to be just $\{\text{true}, \text{false}\}$ and let $f$ be
logical negation, which flips true and false and so obviously has no fixed point
(true is not false). Instantly you get **Cantor's theorem**: no scheme can name
every true/false function on $A$. The function $x \mapsto \text{not }
\varphi(x)(x)$ disagrees with every $\varphi(a)$ at the point $a$, so it is never
named. In the language of computation, let the codes be *programs* and let
$\varphi(a)(x)$ mean "program $a$ accepts program $x$." The unnamed function is
the **halting problem**: no program decides whether an arbitrary program halts.
Let the answers be *sentences* and $f$ be "prepend a negation," and out drops
**Gödel's incompleteness**. Let $\varphi(a)(x)$ mean "$x$ belongs to the set
coded by $a$" and you recover **Russell's paradox**. Five mountains, one peak.

The point for our alien friends is that this argument mentions no machine at all.
It never says what a program *is*. It needs only the notions of a code, a
function, and a transformation without a fixed point. Any civilization that can
express "a function from codes to answers" already has everything the proof
requires. The obstruction is not in the hardware. It is in the mathematics, and
the mathematics is the same everywhere.

## Modeling computation without committing to a machine

To make "any notion of computation" precise without smuggling in our own
prejudices, we strip the idea down to its bones. A **computation model** is
nothing more than a type of programs together with a rule that says, for each
pair of programs $p$ and $q$, whether $p$ *accepts* the code of $q$ — a single
true/false answer. No tapes. No clocks. No memory. No assumption that programs
are finite, or that the acceptance rule is itself computable. Just programs, and
a yes/no relation between them.

Even at this extreme level of generality, the diagonal bites. Define the
**diagonal behavior** of a model: on input $q$, return the *opposite* of what $q$
says about itself. Then no program in the model realizes this behavior, because
any program $p$ that tried would have to disagree with itself on the input $p$.

**Substrate Independence.** *Every computation model — whatever its programs are
made of — contains a decision behavior that none of its own programs can
perform.* There are no hypotheses to check. The gap between what can be *asked*
and what can be *computed* is a permanent feature of the landscape, present in
every model at once.

## The hypercomputer's false hope

A natural dream is to escape the wall by building a stronger machine. Give every
program access to an **oracle** — a magical black box that answers some question
no ordinary computer could, perhaps even a question that is not computable by any
conventional means at all. This is the mathematical stand-in for a
*hypercomputer*. Surely infinite power dissolves the obstruction?

It does not. Let the oracle be *absolutely anything* — any function from programs
to true/false, however exotic. The programs may consult it however they like. The
same diagonal construction produces the model's **jump**: the behavior that
contradicts each program's verdict on itself. And once again no program, oracle
and all, can realize it.

**The Hypercomputation Barrier.** *For every type of programs, every oracle
whatsoever, and every acceptance rule, there is a decision behavior no
oracle-program performs.* Adding power does not remove the wall; it only pushes
the wall up one floor. The "jump" of a class of machines always lands strictly
outside that class. A civilization of hypercomputers meets an exact analog of our
own halting problem — a question their superpowered machines cannot settle,
waiting for a still-more-powerful machine that will, in turn, have its own
unanswerable question.

## An infinite staircase of problems

If a single Cantor step lifts us from a set to the strictly larger set of its
true/false questions, why stop at one step? Build a tower. Let level $0$ be some
starting type $A$ — think of it as raw data. Let level $n+1$ be the set of all
true/false procedures over level $n$: the *problems about* level $n$. Then level
$2$ consists of problems about problems, level $3$ of problems about those, and
so on forever.

Two facts hold at every single step, and both are the two faces of Cantor's
theorem. First, each level **embeds** into the next: any object at level $n$ can
be encoded as the procedure "are you equal to me?", so decision-power never
decreases as we climb. Second, there is **no way to cover** level $n+1$ from
level $n$ — no map from a level onto the next is complete, by the diagonal.
Combining them, each level is *strictly* richer than the one below.

**The Universal Hierarchy.** *The tower $A,\; A\to\text{Bool},\;
(A\to\text{Bool})\to\text{Bool},\ldots$ strictly increases at every step, and it
has no maximal level.* Whatever height of decision-power a civilization reaches,
a provably greater height exists above it. In the language of sizes of infinity,
each level's cardinality is strictly smaller than the next's — the same
$2^\kappa > \kappa$ that separates the counting numbers from the real line,
iterated without end. This staircase is not something anyone designs. It is
forced into existence the moment a civilization can form the idea of "a question
about a question."

## The bright side: self-reference as a gift

Read forwards rather than backwards, the very same fixed-point theorem stops
being a prophet of doom and becomes a source of creative power. In a programming
system rich enough to represent all of its own program-transformations, *every*
transformation has a fixed program — a program that the transformation leaves
essentially unchanged. This is **Kleene's recursion theorem**, and it is the
secret behind one of computing's most charming tricks: the **quine**, a program
whose only output is its own source code.

Ask for the transformation "turn a program into the program that prints it," and
the theorem hands you a program that prints *itself*. The same principle
underlies compilers that compile their own source, systems that inspect and
modify their own code, and — in living systems — the machinery by which a cell's
instructions describe how to copy those very instructions. Self-reference, the
same trick that generates every impossibility when read backwards, generates
every self-reproducing structure when read forwards.

And here is the deep duality that any advanced civilization must confront. A
single system can be *complete for its own transformations* — able to name every
way of rewriting its programs, giving it recursion, quines, and self-modification
— and yet, in the very same breath, it can *never* be complete for its own
true/false questions. Creativity and limitation are not opposites. They are the
two readings of one theorem, distinguished only by whether the answers are
programs or truth values.

## Discovered, not invented

We tend to think of computer science as a human artifact, a tower of clever
conventions built on the accident of the transistor. This picture has it exactly
backwards. The transistor is the accident; the structure it reveals is eternal.
The halting problem, the endless hierarchy of harder and harder problems, the
persistence of the barrier even under hypercomputation, and the bright gift of
self-reference are not features of our machines. They are theorems about the bare
notion of a function acting on the codes that name it.

That is why we can say, with a confidence that goes beyond speculation, what an
alien civilization's computer scientists will know. They will not use our
notation or our names. But they will have their own Cantor, their own Turing,
their own Gödel and Kleene — because they will have the fixed-point theorem, and
from it everything else follows. Across every possible mind and every possible
machine, the mathematics of computation is one and the same. It is waiting to be
found, not made, on every world where anyone ever learns to ask a question about
a question.
