# The Program That Rewrites Itself — and Still Can't Predict Its Own Fate

Imagine a piece of software with a superpower: while it runs, it can reach in and
rewrite its own instructions. Not just its data — its *code*. Line by line, mid-flight,
it can become a different program than the one you launched. This is not science
fiction; it is the world of viruses that mutate to dodge antivirus scanners, of
just-in-time compilers that rewrite hot loops on the fly, and of the wilder dreams of
artificial intelligence that improves its own source. A natural fear follows: if a
program can endlessly reinvent itself, surely it becomes unpredictable in some deep,
new way. Surely such a shape-shifting thing is *harder to reason about* than an
ordinary, fixed program.

This article tells the story of a precise mathematical answer to that fear — and the
answer is a beautiful surprise. Self-modifying code is genuinely undecidable: there is
no general method that can look at such a program and always correctly predict whether
it will eventually stop. But it is *not one bit harder* than the classical case of a
program that never touches its own code. And the reason both facts are true turns out to
be a single, elegant principle — the same principle that Georg Cantor used in 1891 to
prove that some infinities are bigger than others.

## Three impossibilities, one idea

At the heart of this story is a chain of famous impossibility results that mathematicians
long suspected were secretly the same theorem wearing different costumes:

- **Cantor's theorem** (set theory): no list can ever catch all the subsets of a set.
- **The halting problem** (computer science): no program can decide, for every program,
  whether it stops.
- **Gödel's incompleteness** (logic): no consistent formal system can prove all truths
  about arithmetic.

In the 1960s the category theorist F. William Lawvere distilled the shared engine of all
of these into one crisp statement about *fixed points*. A fixed point of a function $f$
is simply a value $b$ that the function leaves alone: $f(b) = b$. Lawvere's insight is
that a certain kind of "richness" in a system *forces* fixed points to exist — and,
turned around, the *absence* of a fixed point makes that richness impossible.

**Lawvere's Fixed-Point Theorem.** *Suppose there is a map $g$ that assigns to each point
$a$ of a space $A$ a function $g(a) : A \to B$, and suppose this assignment is rich enough
to reach every function from $A$ to $B$ (it is "point-surjective"). Then every self-map
$f : B \to B$ has a fixed point — some $b$ with $f(b) = b$.*

The proof is a single diagonal move, and it is worth savoring because everything else
flows from it. Consider the "diagonal" function that sends each point $a$ to $f(g(a)(a))$
— feed $a$ into its own associated function, then apply $f$. Because $g$ reaches every
function, some point $a_\star$ has $g(a_\star) = $ this diagonal function. Now evaluate
at $a_\star$ itself: on one hand $g(a_\star)(a_\star)$ is just some value $b$; on the
other hand, by the definition of the diagonal, it equals $f(g(a_\star)(a_\star)) = f(b)$.
So $b = f(b)$. A fixed point, conjured out of pure self-reference.

Read the contrapositive and Cantor's theorem falls out instantly. Take $B$ to be the two
truth values, $\{\text{true}, \text{false}\}$, and let $f$ be negation, which flips them.
Negation has *no* fixed point — nothing equals its own opposite. So there can be no
point-surjective $g : A \to (A \to \{\text{true}, \text{false}\})$. In plain words:

**Cantor's Theorem (Boolean form).** *No set can be paired up with all of its own
yes/no predicates. No listing of "properties of $A$", indexed by $A$ itself, can ever be
complete.*

The same move, with subsets in place of predicates, gives the classic statement that no
map from a set $A$ onto its power set $\mathcal{P}(A)$ can be surjective — the diagonal
subset "all $a$ not belonging to the subset $g(a)$ names" is always missed.

## From diagonals to deciders

Now watch this set-theoretic fact turn into a statement about computation with no extra
work. Suppose someone hands you a complete catalogue $\text{enum}$ of all yes/no tests on
some space — for each index $i$, a test $\text{enum}(i)$ that answers yes or no on each
input $a$. And suppose they also hand you a **decider**: a single table $d(i, a)$ that
claims to reproduce the answer of test $i$ on input $a$, for *every* $i$ and $a$
simultaneously. Cantor's theorem says this is impossible. A total decider that mirrors a
complete enumeration of predicates cannot exist, because such an enumeration cannot exist
in the first place. This is the **diagonalization engine** behind every undecidability
proof: the request to decide "everything at once" collapses under the weight of its own
completeness.

That is the abstract skeleton. The flesh-and-blood halting problem is what happens when
we make the "tests" into real programs and "does it answer?" into "does it stop?"

## Machines that rewrite themselves

To talk about self-modifying code precisely, we need a model. Picture a machine with two
parts: a **program** $P$ and a **state** $S$. An ordinary computer keeps the program
fixed and only changes the state as it runs. A **self-modifying machine** is more
liberal: its single-step rule takes the *pair* (program, state) and returns a new
(program, state) pair — or a special "halt" signal. Because each step can hand back a
different program, the code itself can drift, mutate, or completely reinvent itself from
one instruction to the next.

Formally, one step is a function
$$\text{step} : P \times S \to (P \times S) \;\cup\; \{\text{halt}\}.$$
We *run* the machine by iterating: from a configuration, apply the step; if it says halt,
we are done; otherwise repeat on the new configuration. The machine **halts** from a
starting configuration if some finite number of steps eventually produces the halt signal.

This is genuinely more expressive than a fixed-program machine, at least on paper. So the
first question is stark: does the ability to rewrite your own code let you compute things,
or hide from analysis in ways, that a fixed program never could?

## The great deflation: self-modification adds nothing

Here is the first main result, and it is a splash of cold, clarifying water.

**Simulation Theorem.** *Every self-modifying machine can be simulated by an ordinary
fixed-program machine that never rewrites its code. Concretely, package the mutable
program into the machine's data: treat the pair (program, state) as one big state, and
let a fixed transition rule shuffle that combined state around. The self-modifying
machine halts from a given configuration if and only if this fixed-program simulation
halts from the same configuration.*

The proof is a clean induction on the number of steps: the simulation's step and the
original machine's step agree at every configuration, so their runs of length $n$ produce
identical results for every $n$, and therefore one reaches "halt" exactly when the other
does. The moral is the old wisdom that *code is data*. The moment you are willing to
store a program as a value your ordinary machine can read and act on, self-modification
stops being a new kind of power. It becomes an ordinary program manipulating an ordinary
piece of data that it happens to interpret as instructions. Every mutating virus, every
self-rewriting optimizer, is — from the standpoint of what can be computed and what can
halt — just a regular program with a fancy data structure.

This already answers half of the original fear. Self-modifying code is not *strictly
harder* to analyze, because it is not doing anything a fixed program with a good encoding
cannot do.

## But it is still impossible to predict

Deflation is not the same as triviality. The second main result shows that the halting
question for self-modifying machines is *genuinely undecidable* — there is no algorithm
that always answers it — and, crucially, this is proved in a way that is not a hollow
technicality.

The trap to avoid is subtle and worth naming. It is tempting to "prove" undecidability by
invoking the diagonalization engine above with a complete enumeration of programs. But
Cantor's theorem tells us that such a complete enumeration of *predicates* cannot exist —
so any statement whose hypothesis assumes one is **vacuously true**, proving nothing about
actual machines. A vacuous impossibility is a mirage.

To avoid the mirage, we build a specific, honest machine and connect it to the bedrock
halting problem of a universal model of computation. Fix an input $n$. Define a
self-modifying machine whose state is a step counter $s$ starting at $0$, and whose rule,
given a program $c$ and counter $s$, asks the universal evaluator a bounded question: "Has
program $c$, run on input $n$, produced an output within $s$ steps of effort?" If yes, the
machine halts. If no, it increments the counter to $s+1$ and continues. As the counter
climbs, the machine gives $c$ ever more time to produce an answer.

A short induction proves the key **Bridge Lemma**: this machine halts from the initial
configuration $(c, 0)$ if and only if the program $c$ actually halts on input $n$ in the
universal model. We have wired our self-modifying machine's fate directly to the classical
halting problem — not to a phantom enumeration, but to the real thing.

**Undecidability of Self-Modifying Halting.** *There is no algorithm that, given a
program $c$, always correctly decides whether the self-modifying machine above halts from
$(c, 0)$. The halting predicate of a self-modifying machine is not computable.*

The proof is now a one-line reduction: if such a decider existed, then by the Bridge Lemma
it would decide the ordinary halting problem, which is impossible. And by the Simulation
Theorem, the very same undecidability transfers verbatim to the fixed-program simulation.
The two facts click together into a single sentence: **self-modifying halting is exactly
as hard as classical halting — no harder, no easier, and both are impossible to decide.**

## Kleene's revenge: the program you cannot change

There is one more twist, and it speaks directly to the fantasy of code that endlessly
improves itself. Suppose you invent an *automatic rewriter*: a computable rule
$\text{modify}$ that takes any program and returns a "modified" version — patched,
optimized, mutated, whatever. Could such a rule change the behavior of *every* program?
Could you guarantee that your rewrite always does *something*?

No. This is Kleene's celebrated Recursion Theorem, read through the lens of
self-modification.

**Behavioral Fixed-Point Theorem.** *For every computable rewriting rule
$\text{modify}$, there exists a program $c$ whose rewritten version $\text{modify}(c)$
computes exactly the same function as $c$ itself.*

In other words, no matter how clever your self-modification scheme, some program is a
*behavioral fixed point*: the rewrite may change its text, but not what it does. There is
always a program your rewriter cannot truly alter — an unstoppable, self-reproducing core,
a mathematical quine that shrugs off every edit. It is the same diagonal spirit as
Lawvere's theorem, now in the category of computable maps: richness forces fixed points,
and the fixed points are the programs that recreate themselves.

## Why it all rhymes

Step back and the architecture is stunning. A single diagonal argument — richness forces a
fixed point; the absence of a fixed point forbids richness — accounts for:

- Cantor's theorem that no set catches all its subsets;
- the impossibility of a universal decider for yes/no tests;
- the undecidability of halting, even for programs that rewrite themselves;
- and Kleene's guarantee that every rewriting rule has a program it cannot change.

These are not four analogies. They are four *readings of one theorem*. The bridge can be
stated as a single sentence over any space of machine configurations: no configuration
space can enumerate all its own predicates; the self-modifying halting problem over it is
undecidable; and so is its fixed-program simulation. The first is Cantor; the second and
third are Turing; and the diagonal engine underneath is Lawvere's.

## The takeaway

The dream of self-modifying software — code that grows, mutates, and rewrites itself
toward some goal — runs into a wall that is older than computers and deeper than any
particular machine. You can let a program rewrite every line of itself, and you will not
gain a single drop of new computational power, nor will you be able to predict its
stopping any better or worse than before. And whatever rewriting rule you cook up, there
will always be a program that laughs it off, reproducing its own behavior no matter how
you edit it.

The unpredictability of self-modifying code is real, but it is not exotic. It is the same
ancient diagonal that runs through Cantor's infinities, Gödel's unprovable truths, and
Turing's undecidable machines — the mathematics of self-reference, insisting once more
that any system rich enough to describe itself is rich enough to escape its own grasp.
