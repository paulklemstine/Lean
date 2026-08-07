# The Fitness Landscape of Mathematical Theories

## Why some libraries of mathematics win

Every working mathematician has, at some point, had the following argument.

One side says: *write it in full generality*. Set up the abstract machinery, prove the theorem once, and every special case falls out for free. The other side says: *just prove the thing*. The abstract setup costs three hundred pages before it says anything, and you only ever wanted the one corollary.

Both sides are right, and both sides know it, and the argument never ends — because it has never been an argument about mathematics. It has been an argument about *economics*: how much does a piece of mathematics cost to write down, and how much does it buy you?

This article is about what happens when you take that economic question literally. Fix a finite list of statements you want proved — call it the **corpus**. Consider all the possible bodies of mathematics that prove it. Charge each one for the total length of everything it actually needs, counting shared material once. Divide the number of theorems proved by the total cost. Call that number the **fitness** of the theory.

You now have a landscape. Each possible development of the subject is a point; its fitness is its altitude. The abstract library and the hand-rolled special case are two nearby points, and the question "which is better?" has become the question "which one is higher?"

The surprise is how much of that landscape can be mapped exactly.

---

## Charging honestly: the cost of a theory

The first thing you need is an honest accounting rule, and getting it right is more delicate than it sounds.

Naively, the cost of a development is the number of lines you wrote. But mathematics is not written in isolation. A proof of the class number formula rests on algebraic number theory, which rests on commutative algebra, which rests on set theory. If you charge the proof for all of that, you get an absurd number. If you charge it for none of it, you can "prove" anything for free by declaring the hard part a prerequisite.

The rule that works is: **charge for the transitive dependency closure, and charge each item exactly once.**

Formally: suppose each mathematical item $i$ — a definition, a lemma, a theorem — has a set of *direct* dependencies $\mathrm{deps}(i)$, the things its statement and proof invoke immediately. Call a collection $S$ of items **dependency-closed** if it contains the direct dependencies of everything in it: $\mathrm{deps}(i) \subseteq S$ for all $i \in S$. A dependency-closed collection is exactly a collection you could actually read from beginning to end without ever encountering an undefined term.

Now, given a starting set $B$ of items you want, the **transitive closure** $\overline{B}$ is what you get by repeatedly throwing in the dependencies of what you already have, until nothing new appears. Inside any fixed finite universe of items this terminates — each round either adds something or stops, and there are only finitely many things to add. What makes the definition canonical rather than arbitrary is:

> **Minimality of the closure.** $\overline{B}$ is dependency-closed, contains $B$, and is contained in *every* dependency-closed set containing $B$.

So $\overline{B}$ is not merely *a* reasonable notion of "everything you need". It is the unique smallest one. There is no accounting slack. Anyone who insists on a different notion of what a development requires is insisting on a set that either fails to be readable or strictly contains the canonical answer.

With that fixed, assign each item $i$ a source length $\ell(i) \geq 0$ and define, for a development $T$ with dependency closure $C(T)$ proving a set $P(T)$ of corpus statements:

$$\mathrm{cost}(T) \;=\; \sum_{i \in C(T)} \ell(i), \qquad \mathrm{fitness}(T) \;=\; \frac{|P(T)|}{\mathrm{cost}(T)}.$$

Two structural facts make this cost model well behaved rather than merely definable.

**Dependency-closed collections form a lattice.** If $S$ and $T$ are both dependency-closed, so are $S \cup T$ and $S \cap T$. The intersection statement is the important one: it says the *shared* material of two developments is itself a legitimate, self-contained body of mathematics. That is precisely what licenses the phrase "charge shared dependencies once" — the shared part is a real thing, not a bookkeeping fiction.

**Merging obeys exact inclusion–exclusion.** If $T$ and $U$ are pooled into a single development $T \sqcup U$ whose closure is $C(T) \cup C(U)$,

$$\mathrm{cost}(T \sqcup U) \;+\; \sum_{i \in C(T) \cap C(U)} \ell(i) \;=\; \mathrm{cost}(T) + \mathrm{cost}(U).$$

In words: *pooling saves exactly the shared mass.* Not approximately, not asymptotically — exactly. That identity is the engine behind almost everything that follows.

---

## Fitness is just cost, upside down

Here is the first simplification, and it is a large one. On a fixed corpus — that is, when comparing developments that all prove the same number of statements — fitness is a purely *ordinal* inverse of cost:

> For nonempty corpora of equal size and positive costs, $\mathrm{fitness}(T) \leq \mathrm{fitness}(U)$ if and only if $\mathrm{cost}(U) \leq \mathrm{cost}(T)$.

Nothing about the corpus matters except how big it is. This collapses a question about ratios of possibly-irrational-looking quantities into a question about comparing two integers, and it means the whole landscape metaphor can be run on cost alone.

It has an immediate consequence. Suppose you are handed any nonempty finite collection of competing developments. Since a finite set of rational numbers has a maximum:

> **Finite maximum principle.** Any nonempty finite comparison class of theories contains a fitness champion.

That sounds trivial, and as a piece of mathematics it is. Its role is different: it tells you exactly which part of the "which library is best?" question is mathematics and which part is empirical measurement. Existence of a champion is free. *Identifying* it is the real work — and the answer turns out to depend delicately on the rules of the game.

---

## The champion is the shared core — and here is why

The folklore claim is that a mature, heavily reused general library beats a collection of bespoke developments. Under the cost model above, this is not folklore. It is a theorem, and it comes in two forms.

**The abstract form.** Suppose $L$ is a development whose dependency closure embeds into the closure of every competitor, all of them proving corpora of the same size. Then $L$ is the champion: $\mathrm{fitness}(T) \le \mathrm{fitness}(L)$ for every competitor $T$. This is immediate once you know that cost is monotone in the closure and fitness is inverted cost — but it is worth saying out loud what it means. *Being contained in everyone else is the same thing as winning.* Generality is not a cost to be justified; it is a structural advantage, provided the general material is genuinely what everyone needs.

**The sharp form.** The abstract statement has a hypothesis you have to check. It can be replaced by a construction. Fix a **proof system**: each corpus statement $s$ comes with the set $\mathrm{base}(s)$ of items its chosen proof consumes. Define the **canonical library** for the corpus as the transitive closure of the union of all the proof bases:

$$C_{\mathrm{can}} \;=\; \overline{\textstyle\bigcup_{s \in \mathrm{corpus}} \mathrm{base}(s)}.$$

Then two things hold. The canonical library proves the entire corpus — every proof base sits inside it by construction. And *every* dependency-closed development that proves the corpus contains it, by minimality of the closure. Therefore:

> **Dependency-adjusted global champion.** Over the whole, unbounded class of dependency-closed developments proving a fixed corpus, the canonical library is a fitness maximum. Any competitor achieving the same fitness has exactly the same cost.

This is the sharpest possible version of "reuse wins". It is not a statement about a finite tournament; it is a statement about all conceivable developments at once. The shared core wins not because it is elegant, but because logic forces every rival to contain it.

---

## Exactly how much reuse saves

The champion theorem says the shared library wins. A separate identity says by how much, and it is exact.

Split a corpus into $k$ blocks. A **specialist** for block $i$ writes the general core from scratch plus its own private material $\mathrm{priv}(i)$. A **shared library** writes the core once and puts all the private material on top. Assume the private parts are pairwise disjoint and disjoint from the core. Then

$$\mathrm{cost}(\text{library}) \;+\; k \cdot \mathrm{cost}(\text{core}) \;=\; \sum_{i=1}^{k} \mathrm{cost}(\text{specialist } i) \;+\; \mathrm{cost}(\text{core}).$$

Rearranged: the suite of specialists costs exactly $(k-1)$ extra copies of the core. So as soon as $k \geq 2$ and the core is nonempty, the shared library is strictly cheaper, hence strictly fitter, than the pooled suite proving the very same corpus. The saving is linear in the number of clients — which is why libraries pay off slowly at first and then decisively.

---

## Where the champion stops being canonical

Every clean theorem has a boundary, and this one's is instructive.

The canonical champion argument used a *fixed* proof system: one chosen proof per statement. Real mathematics does not work like that. There are two proofs of quadratic reciprocity before breakfast.

What happens with alternatives? Consider the minimal example. One statement, two proof routes, each requiring a single item of length one, and the two items are different. Both routes prove the corpus. Both cost $1$. Both have fitness $1$. Their dependency closures are incomparable — neither contains the other — and their intersection is *empty*, so it proves nothing at all.

So the covering developments have no least element. There is no canonical champion. The tidy "minimality of the closure" argument evaporates the moment routes branch.

What survives is existence, and it survives in the right generality. In a multi-route system, where each statement carries a finite set of alternative proof routes and a development proves a statement if it contains at least one route, one still has:

> **Existence of a minimum-cost cover.** Inside a finite universe that itself covers the corpus, some sub-collection covers the corpus at minimal cost, and it is therefore a fitness maximum among all covering sub-collections.

The champion still exists; it merely stops being computable by taking a closure. What has appeared instead is a weighted set-cover problem in disguise — which is to say, the moment mathematics offers you choices about how to prove things, choosing the cheapest overall library becomes a genuinely combinatorial optimisation problem rather than a matter of following dependencies downhill.

---

## Combining libraries: a phase transition

Now suppose you have two established developments and you want to merge them. Pooling saves the shared mass — that is the inclusion–exclusion identity. But merging is not free: you must write an **adapter layer** of cost $A$ reconciling the two sets of conventions.

Compare two options for proving the union of the two corpora. Keep them separate, paying $\mathrm{cost}(T) + \mathrm{cost}(U)$ with every shared dependency paid for twice. Or compose, paying $\mathrm{cost}(T \sqcup U) + A$. The inclusion–exclusion identity converts this into a clean threshold:

> **Composition threshold.** Composition strictly increases fitness if and only if $A < \mathrm{shared\ mass}$; it is fitness-neutral if and only if $A = \mathrm{shared\ mass}$; and it strictly decreases fitness if and only if $A > \mathrm{shared\ mass}$.

There is a sharp critical point, and it sits at a directly measurable quantity: the total length of the material the two developments have in common. Dividing through by the duplicated cost gives the same statement in normalised form — composition pays exactly when the *adapter density* falls below the *dependency density*. Both are dimensionless numbers you can measure on a real corpus.

A worked instance makes it concrete. Two developments of four items each, sharing two, every item of length $10$. Separate cost: $80$. Pooled cost: $60$. Shared mass: $20$. With an adapter costing $10$, fitness rises from $4/80$ to $4/70$. With an adapter costing $30$, it falls to $4/90$. At exactly $20$, nothing changes. The transition is a genuine crossing, not a gradual trend.

There is one further effect that eventually swamps the adapter. If the composite proves not the *union* but the *product* of the two corpora — every combination of a fact from one side with a fact from the other, as happens when two theories genuinely interact — then the numerator multiplies while the denominator only adds. Concretely, whenever

$$\mathrm{cost}(T) + \mathrm{cost}(U) + A \;<\; \mathrm{cost}(T)\cdot|P(U)|,$$

composition beats the first component outright, *whatever* the adapter costs. Multiplicative growth eventually beats additive cost. This is the formal residue of the observation that fields which fuse — algebraic geometry, analytic number theory — pay a large one-off translation cost and then reap combinatorially many theorems.

---

## Counting how many libraries there are

Behind "candidates multiply" is a combinatorial claim that can be checked exactly. Given a body of items with a dependency structure, how many *usable* sub-libraries does it have — how many dependency-closed subsets?

Three exact answers.

**Independent parts multiply.** If the items split into two groups $A$ and $B$ with no dependency crossing between them, then the dependency-closed subsets of the whole are exactly the pairs (closed subset of $A$, closed subset of $B$):

$$N(A \cup B) = N(A)\cdot N(B).$$

This is a bijection, not an estimate: intersect a closed subset with $A$ and with $B$ to go one way, take the union to go back.

**The free extreme.** If nothing depends on anything, every subset is usable, so $n$ items give exactly $2^n$ usable sub-libraries.

**The rigid extreme.** If the items form a chain — item $i$ depends on item $i-1$ — then a dependency-closed subset must be downward closed, hence an initial segment $\{0, 1, \dots, k-1\}$. There are exactly $n + 1$ of them.

So dependency density collapses the candidate population from $2^n$ to $n+1$: for every $n \geq 2$ the chain has strictly fewer usable sub-libraries than the independent family, and the gap is exponential.

This is the trade-off at the heart of library design stated in exact numbers. Dependencies are what make reuse possible — they are how the core gets shared. They are also what destroy modularity, because each one prunes the tree of things you can extract and use on their own. A body of mathematics can be highly reusable *as a whole* while offering almost nothing usable *in part*. Both extremes are computed here, and every real library lives between them.

---

## Valleys, and why fields don't migrate

So far the landscape has been described by its peaks. Its valleys are where the drama is.

Suppose you want to migrate a development from one abstraction layer to another — recast a piece of analysis in measure-theoretic language, say, or rebuild a combinatorial argument algebraically. You do it in small, meaning-preserving steps: a path $w_0, w_1, \dots, w_n$ through the space of developments, each step a bounded refactoring, the mathematical content unchanged throughout.

Two facts about such a path. The first is purely combinatorial: if the endpoints are written against inequivalent interfaces, then some *single* step crosses the boundary. You cannot get from one convention to another by a sequence of steps none of which changes the convention. Obvious, but it localises the problem to a single transition.

The second quantifies the damage. Suppose a state that straddles the boundary must implement both interfaces at once, so its source length is at least $(1+\alpha)$ times the intrinsic size $C$ of the content. Suppose the endpoints are efficient: their length is at most $(1+\beta) C$ with $\beta < \alpha$. Then:

> **Adapter valley.** Every semantics-preserving migration path contains an intermediate state whose length exceeds the smaller endpoint length by at least the fixed positive fraction $\dfrac{\alpha - \beta}{1 + \beta}$ of it.

The overshoot depends only on the two efficiency exponents — not on the length of the path, not on how cleverly you refactor, not on the size of the development. With a crossing state at $1.5\times$ content and endpoints at $1.1\times$, the guaranteed overshoot is $(0.5 - 0.1)/1.1 = 4/11$: any migration must at some point be at least $36\%$ bloated relative to where it started.

That is a *barrier*. And since fitness is inverted cost, a length barrier is a fitness valley. You cannot walk from one convention to another downhill; you must climb out of your own basin first.

---

## Three peaks, no summit

Which brings us to the shape of the whole landscape.

Call a development a **strict local maximum** if every neighbour reachable by one bounded refactoring is strictly less fit. The natural way to get one is to be the best in your own style with a neighbourhood that never leaves it:

> **Style-centre theorem.** If a development is strictly optimal among all developments of its own methodological style, and every bounded refactoring preserves style, then it is a strict local maximum.

The value of separating those two hypotheses is that each is independently measurable: "best in style" is a comparison within a class, "style-closed neighbourhood" is a property of the refactoring relation. The hypothesis can even be weakened realistically: boundary crossings *may* be allowed, provided cross-style neighbours are strictly less fit — the adapter valley result is exactly what supplies that. And local maximality is invariant under meaning-preserving renaming, so the notion descends to the quotient in which two developments differing only in names are identified. Nobody's peak is an artefact of notation.

Instantiate this with nine developments of one corpus, three each in algebraic, analytic, and combinatorial style, with measured fitnesses $1, 2, 5 \mid 3, 7, 4 \mid 6, 2, 9$ and refactorings that stay within style. Then the three stylewise winners — the $5$, the $7$, the $9$ — are three *distinct* strict local maxima, one per style. And the first two are not global: $5 < 9$ and $7 < 9$. The landscape is genuinely multi-peaked. There is no path of small improvements from the algebraic peak to the combinatorial one, even though the combinatorial one is better.

If you have ever wondered why two communities can work on the same theorems for decades with incompatible toolkits, each locally unable to improve by adopting the other's methods, this is the geometry of it. Both are right that every small step towards the other side makes things worse. Both are wrong that this settles which peak is higher.

---

## The catch: there is no global champion at all

The final result is the one that keeps everything else honest.

Everything above compares developments *on a fixed corpus*. Drop that, and measure raw theorems-per-line over everything expressible, and the whole enterprise collapses. Here is why.

Consider any language of developments in which you can perform **conservative inflation**: state $n$ further consequences of what you have already proved, at *sublinear* marginal source cost — say $\sqrt{n}$ extra lines for $n$ extra statements. This is not a contrived operation; it is what happens whenever a general theorem is instantiated in a hundred special cases, each one line long.

Then raw fitness is unbounded. Given any target $M$, inflate enough and the ratio $\big(\mathrm{count} + n\big) / \big(\mathrm{len} + \sqrt{n}\big)$ exceeds it, because the numerator grows like $n$ and the denominator like $\sqrt{n}$. Hence:

> **No universal maximum without normalisation.** In any language admitting conservative inflation at sublinear marginal cost, raw theorem-per-line fitness has no global maximum.

And — this is the sting — *every one of those record-breaking developments means exactly the same thing as the one it came from*. Conservative inflation, by definition, adds no semantic content. The unbounded family is semantically inert. The fitness diverges to infinity while the mathematics stands perfectly still.

Put beside the finite maximum principle, this is a sharp dichotomy: **maxima exist on every finite normalised comparison class, and never on the full expressible class.** Normalisation is not a technical convenience. It is the entire content of the claim that a champion exists.

---

## What this is really about

None of these results tells you which textbook to buy. That is not what they are for.

What they do is convert a perpetual argument into a set of measurements. "Is the general library worth it?" becomes: measure the shared mass, measure the adapter, compare two integers. "Why won't they adopt our methods?" becomes: measure the two efficiency exponents, compute $(\alpha - \beta)/(1+\beta)$, and read off the height of the wall between the camps. "Which library is the best?" becomes: *the best on which corpus, with which dependencies charged, in which bounded universe?* — because without those three answers the question provably has none.

And there is a lesson in the structure of the results themselves. The theorems that came out cleanest — closure minimality, the reuse identity, the composition threshold, the exact counts $2^n$ and $n+1$ — are all *accounting* results. They say what the numbers must be, given the model. The things that stayed hard, and remain conjectural, are all about *choice*: which proof route, which interface, which style. That is where the mathematics stops and the sociology of a discipline begins.

Which is, perhaps, exactly where you would expect the boundary to be.
