# The Fitness Landscape of Mathematical Theories

## What if we could measure how *good* a body of mathematics is?

Every working mathematician has an opinion about which developments are elegant
and which are bloated. A slick twenty-line derivation from the right abstraction
feels better than a hundred-line computation, even when both establish the same
theorem. But "elegant" is a word, not a number, and words do not settle
arguments.

Suppose we insist on a number. Fix a finite list of statements — call it the
**corpus** — that we want proved. A **theory** is any development that proves
some of them. Charge each theory for what it costs to write, and reward it for
what it proves. Then

$$\text{fitness} = \frac{\text{number of corpus statements proved}}{\text{cost of writing it down}}.$$

This is nothing more than yield per unit of effort. It is the same quantity a
biologist means by fitness: offspring per unit of resource. And once you have
it, you can ask the questions evolutionary biologists ask. Is there a global
champion? Are there local peaks that no small improvement can escape? What
happens when two lineages merge?

The surprise is that these questions, posed carefully, have exact answers — and
that the answers reproduce, as theorems, several folk beliefs about how
mathematical libraries actually behave: that abstraction pays for itself, that
merging two libraries is worth it only if they overlap enough, that the road
between two styles of mathematics runs through a valley, and that a naive
efficiency score can always be gamed.

## The one modelling decision that matters

Everything hinges on how you charge for cost. The naive answer — count the lines
of the development itself — is wrong, and wrong in an interesting way. A
development does not stand alone; it rests on a tower of prior definitions and
lemmas. If you ignore the tower you flatter every theory that leans on a large
one. If you charge for the tower twice when two parts of the same development
lean on the same lemma, you punish reuse, which is precisely the thing you want
to measure.

The fix is to charge for the **transitive dependency closure**, exactly once per
item. Model the world as a set of declarations, each declaration $i$ carrying a
source length $\ell(i)$ and a finite set $\mathrm{deps}(i)$ of things it directly
uses. A set $S$ of declarations is **dependency-closed** if it contains
$\mathrm{deps}(i)$ for every $i \in S$: it is a body of mathematics with no
dangling references. A theory is then a pair — a dependency-closed set of
declarations, and the set of corpus statements it proves — and its cost is

$$\mathrm{cost}(T) = \sum_{i \in \mathrm{closure}(T)} \ell(i).$$

Two facts make this canonical rather than arbitrary. First, every set of
declarations has a *smallest* dependency-closed superset, its transitive
closure, obtained by repeatedly adding the direct dependencies of whatever you
have; inside a finite universe this stabilises, and the result is contained in
every dependency-closed set containing what you started with. There is no choice
to make. Second, dependency-closed sets are closed under both union and
intersection. That second fact is what licenses the whole accounting scheme: the
material *shared* by two developments is itself a legitimate body of
mathematics, so it makes sense to speak of paying for it once. The bookkeeping
identity is exact:

$$\mathrm{cost}(T \cup U) + \mathrm{cost}(T \cap U) = \mathrm{cost}(T) + \mathrm{cost}(U).$$

Merging never costs more than duplicating, and the saving is precisely the
shared mass.

## Once the corpus is fixed, fitness is just cheapness

Here is the first structural theorem, and it is deflating in a useful way. If
two theories prove the same number of corpus statements — and at least one, and
both cost something — then

$$\mathrm{fitness}(T) \le \mathrm{fitness}(U) \iff \mathrm{cost}(U) \le \mathrm{cost}(T).$$

Fitness is a purely *ordinal* inverse of cost. Nothing about the corpus survives
except its size. This is not a weakness of the definition; it is what makes the
programme tractable, because it turns every fitness comparison into a single
integer measurement. And it immediately gives the **finite maximum principle**:
any nonempty finite collection of theories contains a champion. A finite set of
rationals has a largest element — that is the whole proof, and its triviality is
the point. Existence of a champion is free; everything interesting is about
*which* theory it is.

## Abstraction pays, and here is the receipt

Now the central claim of the programme, the one that says general abstraction
beats bespoke specialisation. Split the corpus into $k$ blocks. A **specialist**
for block $i$ writes a general core plus its own private material,
$\mathrm{core} \cup \mathrm{priv}_i$; a **shared library** writes the core once
and stacks all the private material on top,
$\mathrm{core} \cup \bigcup_i \mathrm{priv}_i$. Both prove the whole corpus.

Suppose the core is disjoint from each block's private material and the private
blocks are pairwise disjoint. Then the accounting is exact:

$$\mathrm{cost}(\text{library}) + k \cdot |\mathrm{core}| \;=\; \sum_{i=1}^{k} \mathrm{cost}(\text{specialist}_i) + |\mathrm{core}|,$$

where $|\mathrm{core}|$ abbreviates the summed source length of the core. Read
it as: pooling $k$ specialists saves exactly $k-1$ copies of the core. Nothing
is estimated. As soon as $k \ge 2$ and the core is nonempty, the library is
strictly cheaper than the suite of specialists — hence, by the ordinal
principle, strictly fitter on the same corpus.

There is a stronger version. Fix a proof system: each corpus statement $s$ comes
with the set of declarations $\mathrm{base}(s)$ its chosen proof consumes. Let
the **canonical library** be the transitive closure of $\bigcup_{s}
\mathrm{base}(s)$. It proves the whole corpus, and its closure sits inside the
closure of *every* dependency-closed development that proves the corpus.
Therefore it is a global fitness maximum — not merely the best in some finite
shortlist, but the best in the entire, unbounded class of developments that do
the job. Any rival matching its fitness must have exactly the same cost.

So the mature shared library wins. That is the theorem, and it is the reason
serious libraries look the way they do.

## Where canonicity breaks

The proof above quietly assumed something strong: one fixed proof route per
statement. Real mathematics offers alternatives. What happens then?

Canonicity fails, and it fails as sharply as possible. Take a corpus with one
statement provable in two genuinely different ways, using disjoint material —
route one costs a single declaration, route two costs a different single
declaration. Both developments prove the corpus; both cost the same; both have
equal, maximal fitness. Their dependency closures are incomparable and their
intersection is *empty*. There is no least covering closure. The champion is
determined only up to cost.

Existence, though, survives intact. In a proof system where each statement
carries a finite set of alternative routes, a minimum-cost covering
sub-library of any finite universe still exists — one simply minimises an
integer over a finite family — and it is a fitness maximum among all covering
sub-libraries. So the question "which library is fittest?" stays well posed the
moment routes branch; it merely stops having a canonical answer and becomes a
search problem, a weighted set cover in disguise.

## When is merging two libraries worth it?

Combining two developments pools their dependencies, so anything used by both
gets paid for once instead of twice. But it also costs an **adapter**: glue
reconciling two interfaces that were never designed to meet. Write $A$ for the
adapter's source length and let the **shared mass** be the summed length of the
declarations in both closures. The composite's cost is
$\mathrm{cost}(T \cup U) + A$; keeping the two apart costs
$\mathrm{cost}(T) + \mathrm{cost}(U)$. The exact identity

$$\big(\mathrm{cost}(T\cup U) + A\big) + \text{shared mass} = \mathrm{cost}(T) + \mathrm{cost}(U) + A$$

collapses the comparison to a single inequality. Composition strictly increases
fitness **if and only if** $A < \text{shared mass}$; it is exactly neutral when
$A$ equals the shared mass, and strictly harmful above it. There is a genuine
phase transition, and its location is not a matter of taste.

The same threshold in normalised form is even more usable. Divide both sides by
the duplicated cost to get an *adapter density* and a *dependency density*, two
dimensionless numbers you can measure on any pair of real libraries.
Composition pays exactly when adapter density is below dependency density.

A worked instance: two libraries of four declarations each, sharing two, every
declaration ten lines long. Duplicated cost $80$, pooled cost $60$, shared mass
$20$. An adapter of ten lines takes fitness from $4/80$ to $4/70$ — a win. An
adapter of thirty lines takes it to $4/90$ — a loss. At exactly twenty, nothing
changes.

And there is one more effect, which pushes the other way. If the composite can
prove not just the union of the two corpora but their *product* — every
statement of one crossed with every statement of the other, as happens when two
theories can be applied to each other — then the numerator multiplies while the
denominator merely adds. Whenever
$\mathrm{cost}(T) + \mathrm{cost}(U) + A < \mathrm{cost}(T) \cdot |{\rm corpus}(U)|$,
composition wins regardless of how expensive the adapter is. Costs add;
candidates multiply; multiplication eventually wins.

Why "eventually"? Because dependencies throttle the multiplication. Count the
usable sub-libraries of a body of $n$ declarations — the dependency-closed
subsets, the pieces you can actually reuse standalone. If a library splits into
two parts with no dependency crossing the split, the counts multiply *exactly*:
the closed subsets of the whole are precisely the pairs of closed subsets of the
parts, a bijection rather than an estimate. So $n$ mutually independent
declarations admit exactly $2^n$ usable sub-libraries. At the other extreme, a
chain — each declaration depending on the previous one — admits exactly $n+1$,
because a dependency-closed subset of a chain must be an initial segment. From
$n = 2$ upward the chain has strictly fewer, and the gap is exponential.
Dependency density is exactly the dial between $2^n$ and $n+1$.

## Valleys, peaks, and why styles persist

Now think of developments as points in a landscape, joined when a single bounded
refactoring turns one into the other, and ask about the shape.

**Valleys.** Suppose two developments implement the same mathematics but against
inequivalent abstraction layers. Any path of semantics-preserving refactorings
from one to the other must, at some single step, cross the interface boundary —
a two-line induction on the walk. Now add the assumption that a state straddling
the boundary must implement both interfaces, so its source length is at least
$(1+\alpha)$ times the intrinsic content, while the endpoints are efficient,
within a factor $(1+\beta)$ of the content, with $\beta < \alpha$. Then *every*
such path contains an intermediate state whose length exceeds the smaller
endpoint by at least the fixed positive fraction

$$\frac{\alpha - \beta}{1 + \beta}$$

of that endpoint. There is no cheap road. Concretely: two endpoints of intrinsic
content $100$ written at $10\%$ overhead, an adapter state at $50\%$ overhead;
the guaranteed overshoot is $(0.5 - 0.1)/1.1 = 4/11$, about $36\%$. A refactor
that looks like a $36\%$ regression is not a mistake — it is the mandatory floor
of the valley.

**Peaks.** Why do algebraic, analytic and combinatorial treatments of the same
material coexist instead of converging? The landscape answer is metastability:
each style holds a strict local maximum. Two conditions suffice, and they are
independently measurable. A development is *style-optimal* if it is strictly
fitter than every other development in its own style. If, in addition, bounded
refactorings never change a development's style, then a style-optimal
development is a strict local maximum — every neighbour is strictly worse. The
hypothesis can be weakened to *adapter quarantine*: boundaries may be crossed,
provided the cross-style neighbours are strictly less fit, which is exactly what
the valley theorem predicts. And local maximality is invariant under renaming,
so the notion descends to the quotient by cosmetic relabelling: it is about
mathematics, not identifiers.

A nine-development landscape — three per style, with measured fitnesses
$1,2,5$ / $3,7,4$ / $6,2,9$ — has exactly three strict local maxima, one per
style, at $5$, $7$ and $9$. Two of them are not global. Metastability is real:
you can be trapped on a peak that is genuinely a peak and genuinely not the
best.

## The catch: any naive score can be gamed

Finally, a warning that the framework proves about itself. Consider raw fitness
— theorems per line, no dependency accounting, no fixed corpus. Suppose the
language lets you tack $n$ further consequences of what you have already proved
onto a development, at a *sublinear* marginal cost $m(n)$, meaning $m(n)/n \to
0$. Adding corollaries is cheaper per corollary the more you add: you write the
schema once.

Then raw fitness is unbounded. For any target $M$, inflating far enough produces
a development scoring above $M$. So there is no global champion — and worse,
every witness in the unbounded family has *exactly the same semantics* as the
development it came from. The score diverges while the mathematics stands still.
This is not hypothetical: a language whose marginal cost is $\sqrt{n}$ satisfies
every hypothesis, and it has no champion.

Put beside the finite maximum principle, this gives a sharp dichotomy. On any
finite, normalised comparison class, a champion exists. On the unrestricted
class of expressible developments, none does. Normalisation — a fixed corpus,
fixed theorem identity, a bounded universe of admissible dependencies — is not a
technical convenience. It is the entire content of the claim that a global
champion exists at all.

## What this buys us

Nothing above is a metaphor. Each statement is a theorem about a cost model
precise enough to run on a real library: a finite corpus, a source-length
function, a transitive dependency closure charged once. And each theorem
converts a vague belief into a measurement. *Does abstraction pay?* Compare
closure costs. *Should we merge?* Compare adapter density to dependency density.
*Is our library stuck on a local peak?* Check style-optimality and cross-style
neighbour fitness. *Is our efficiency metric honest?* Check whether it is
normalised — because if it is not, someone can always inflate it without proving
anything new.

The fitness landscape of mathematics turns out to be exactly as rugged as
practitioners suspect: one canonical global peak once you fix your proof routes,
several stubborn local peaks once you allow methodological styles, mandatory
valleys between them, and an unbounded escape hatch for anyone who forgets to
normalise.
