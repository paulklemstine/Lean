# The Meaning a Structure Cannot Keep

## What a triangle forgets

Draw an equilateral triangle and label its corners $A$, $B$, $C$. Now hand the drawing to someone who is allowed to rotate and reflect it as much as they like, and ask them: *which corner was $A$?*

They cannot tell you. Not because they are careless, and not because the information is hidden somewhere they failed to look. The labels simply are not part of the triangle. They were something you brought from outside — a private annotation laid over a shape that has no opinion about which of its three identical corners deserves which letter.

This is a small, almost silly, observation. It is also the seed of a precise mathematical theory: exactly how much externally imposed meaning a structure can carry, how much it destroys, and which languages are rich enough to talk about what survives.

The punchline, stated up front, is a single equation:

$$\ell(M) \;=\; |M| \;-\; \#\{\text{orbits of } M\}.$$

That number — call it the **meaning-loss exponent** — is the precise quantity of external meaning a structure annihilates. Everything below is the story of what it means, why it is the right number, and what it obeys.

## Interpretations, and what it means to recover one

Fix a mathematical object $M$ — points, the vertices of a graph, positions on a board. An **external interpretation** of $M$ is nothing more than a function

$$I : M \longrightarrow V$$

assigning to each element of $M$ some *meaning* drawn from a value set $V$. The meanings could be labels, colours, prices, truth values — semantic content of any kind. The essential point is that $V$ lives outside $M$: the interpretation is imposed, not intrinsic.

Meanwhile, $M$ has its own internal notion of sameness. Its symmetries — the transformations preserving whatever structure $M$ carries — form a group $G$. Two elements $x$ and $y$ are **structurally indistinguishable**, written $x \sim y$, when some symmetry $g \in G$ carries one to the other: $g \cdot x = y$. From the point of view of the structure itself, indistinguishable elements are the same element wearing different disguises.

The central question is now sharp. Call an interpretation $I$ **recoverable from structural truth** if it can be reconstructed from the structural data alone — formally, if there is a function $F$ defined on the *quotient* $M/\!\sim$ (the set of symmetry classes) with $F([x]) = I(x)$ for every $x$. Recoverability says: *the meaning was never really external; the structure was carrying it all along.*

Which interpretations are recoverable?

## The first theorem: descent

The answer is as clean as one could hope.

> **Orbit Descent Theorem.** An external interpretation $I : M \to V$ is recoverable from structural truth if and only if it is *orbit-constant*: whenever $x \sim y$, we have $I(x) = I(y)$. Moreover the recovering function $F$, when it exists, is unique.

The content is real: recoverability, stated as the *existence* of an object (a function on the quotient), is equivalent to a purely local *condition* (agreement on indistinguishable pairs) that you can check pointwise. And the uniqueness clause means there is never any ambiguity about *how* the structure remembers a meaning it can remember at all.

The uniqueness has a slicker form. The **orbit map** $x \mapsto [x]$, which sends each element to its own symmetry class, is itself a recoverable interpretation — and it is the *finest* one. Every recoverable interpretation factors through it, in exactly one way. The orbit map is thus the universal recoverable interpretation: *the* thing the structure knows about its own elements, with every other structurally-carried meaning a renaming of it. It follows immediately that recoverable interpretations are closed under composing with any function $V \to W$ and under pairing.

## Collisions, and the annihilation of meaning

The negative side of the coin is where things get vivid.

> **Meaning Collision.** If two indistinguishable elements are given different meanings — if $x \sim y$ but $I(x) \neq I(y)$ — then $I$ is not recoverable. Structure cannot hold that meaning.

Push this to the extreme. Suppose $M$ carries *no* structure at all, so that its symmetry group is the full symmetric group of all permutations. Then any two elements are indistinguishable, and:

> **Total Annihilation.** Under the full symmetric group, an interpretation is recoverable if and only if it is globally constant.

A bare set of five objects can hold exactly one bit of external meaning per possible value — that is, none at all beyond a single global choice. The smallest instance is already instructive: on a two-element set $\{ \text{true}, \text{false} \}$ with all permutations allowed, the identity interpretation — the one that says "this element means *itself*" — is not recoverable. The set knows it has two elements. It does not know which is which.

Maximal symmetry is maximal forgetting. This is the same phenomenon that makes it meaningless to ask which of two electrons is "the first one", and the same phenomenon that makes an unlabelled graph a genuinely different object from a labelled one.

## Graphs: a laboratory

Graphs make the boundary tangible, because their symmetry groups are intermediate — neither trivial nor total.

Take the three-vertex path $0 - 1 - 2$. Its symmetry group is small and completely computable: it consists of exactly two elements, the identity and the endpoint swap $0 \leftrightarrow 2$. Consequently:

> **Classification for the path.** An external interpretation of $0 - 1 - 2$ is recoverable if and only if it gives the two endpoints the same meaning.

So: vertex *labels* are not recoverable — the path cannot tell you which endpoint is "vertex $0$". But vertex *degrees* are: the degree function assigns $1, 2, 1$, constant on the endpoint pair. And degree is not merely recoverable but *maximally informative* here — it separates the midpoint from the endpoints, exactly as fine a distinction as the structure permits. Degree is the path's own intrinsic vocabulary; labels are our imposition.

That degrees survive is general: in any finite graph the degree function is constant on automorphism orbits, hence recoverable. And the extreme case reappears: on a *complete* graph all permutations are symmetries, and only the constant interpretations survive. A complete graph is a set that has forgotten it was ever anything else.

## How much is lost? An exponent

So far, qualitative. Now the counting, which is where a genuinely new invariant appears.

Suppose $M$ is finite with $|M| = n$ elements, the value set $V$ is finite, and the symmetry group carves $M$ into $k$ orbits. How many interpretations are there in total, and how many of those are recoverable?

Total: $|V|^n$, one free choice of meaning per element. Recoverable: by the Descent Theorem, a recoverable interpretation is exactly a function on the orbit space, so there are $|V|^k$ of them. Dividing:

> **Meaning-Loss Factorisation.** The total number of external interpretations factors as
> $$|V|^{n} \;=\; \underbrace{|V|^{k}}_{\text{recoverable}} \;\times\; \underbrace{|V|^{\,n-k}}_{\text{pure loss}}.$$

The exponent $\ell(M) = n - k$ is the **meaning-loss exponent**: the family of recoverable interpretations is exactly $|V|^{\ell(M)}$ times smaller than the family of all interpretations. It is a single natural number measuring how much semantic capacity the structure destroys, and it does not depend on $V$ at all. It is an invariant of the structure alone.

What does this number obey?

> **Additivity.** $\ell(M \sqcup N) = \ell(M) + \ell(N)$: meaning loss adds across disjoint unions.

This is the signature of a genuine extensive quantity, like entropy or dimension rather than like a probability. Put two independent systems side by side and their capacities for forgetting simply add. Underlying it is a structural fact worth stating on its own: the symmetry classes of a disjoint union are precisely the disjoint union of the symmetry classes — nothing new is identified and nothing old is split.

> **Rigidity Criterion.** $\ell(M) = 0$ if and only if $M$ is *rigid*: indistinguishable elements are equal. Equivalently — and this is the version that makes the concept earn its name — $\ell(M) = 0$ if and only if *every* external interpretation is recoverable.

So the exponent vanishes exactly for the structures that lose nothing, and every non-rigid structure has a strictly positive exponent. There is no partial credit and no boundary case.

> **Orbit Decomposition.** $\ell(M) = \sum_{\text{orbits } O} (|O| - 1)$.

This is the most concrete reading of all. Each orbit of size $m$ contributes $m - 1$: it has one "genuine" element and $m-1$ *duplicates*, copies the structure cannot tell apart. The meaning-loss exponent simply counts duplicates. A rigid structure has none. A bare $n$-element set is one orbit of size $n$, contributing $n-1$, which is the maximum possible — again the statement that a bare set holds essentially one meaning.

Finally, the count of recoverable interpretations plugs into classical group theory. Counting the recoverable *Boolean* interpretations (those with $V = \{\text{true},\text{false}\}$) gives $2^k$, and the orbit-counting lemma — which computes $k$ as the average number of points a symmetry leaves fixed — converts this into a purely group-theoretic identity:

$$2^{\sum_{g \in G} |\mathrm{Fix}(g)|} \;=\; \bigl(\#\text{recoverable Boolean interpretations}\bigr)^{|G|}.$$

Semantics on the left of the equals sign; fixed-point counts on the right. The number of meanings a structure can carry is a character sum.

## Which languages can *say* what survives?

Descent tells us which meanings survive. A different question is whether we can *express* the survivors — whether there is a language whose formulas pick out exactly the recoverable interpretations. The original conjecture that prompted this work said: recoverable should mean "orbit-constant **and** definable in the invariant language."

The first thing to notice is that this conjunction is doing no work.

Call a family of subsets of $M$ an **invariant language** if it is closed under complement and finite union, contains the empty set, and — the essential clause — every set in it is invariant under all symmetries. That last clause is what makes the language a language *about the structure*, blind to anything the structure cannot see. An interpretation is **definable** in such a language when each of its meaning-fibres $\{x : I(x) = v\}$ belongs to it.

> **Redundancy.** In *any* invariant language, definability already implies orbit constancy. So "orbit-constant and definable" says exactly "definable".

The reason is one line: an invariant fibre containing $x$ must contain everything indistinguishable from $x$, which is precisely orbit constancy. Definability is genuinely the stronger of the two notions; the conjunction was a redundancy.

Is it *strictly* stronger? That depends entirely on how rich the language is, and here the picture splits sharply.

**The largest language.** Take the language of *all* invariant sets — the orbit language. Every invariant language is contained in it. For this maximal language the answer is perfect and requires no finiteness:

> **Maximal-Language Theorem.** An interpretation is recoverable from structural truth if and only if it is definable in the largest invariant language.

**Bounded languages.** But if "the invariant language" is anything less than maximal, the conjecture is false, and a small example kills it. Take $M = \mathbb{N}$ with *trivial* symmetry group — no non-identity symmetries at all. Then indistinguishability is equality, so *every* interpretation of $\mathbb{N}$ is orbit-constant and hence recoverable. Now take the invariant language of sets that are finite or cofinite: a formula may pin down only finitely much information, or its negation may. And consider parity, $I(n) = [\,n \text{ is even}\,]$. Its fibre is the set of even numbers, which is infinite and has infinite complement. So:

> **The Boundary Is Real.** Parity on $\mathbb{N}$ is recoverable but not definable in the finite/cofinite invariant language. On infinite structures, orbit constancy is strictly weaker than definability.

So the definability clause cannot simply be dropped for infinite structures — but it also cannot be *kept* naively, because with the right (maximal) language it is equivalent to recoverability, and with a bounded language it is strictly stronger than it. The conjecture was neither true nor false; it was under-specified, and the correct statement identifies exactly which language makes it true.

**Finite structures.** For finite structures, everything collapses into one clean package. Enrich the language with *orbit-counting modalities*: predicates naming each orbit, plus Boolean combinations. Then:

> **Finite Classification.** For an interpretation of a finite structure, the following are equivalent: (i) it is recoverable from structural truth; (ii) it is constant on orbits; (iii) it is definable in the largest invariant language; (iv) each of its fibres is a Boolean combination of orbit predicates.

The hard clause is that on a finite structure *every* invariant set is a Boolean combination of orbits — proved by peeling off one orbit at a time from a shrinking invariant set. And the enrichment is genuinely needed: in the *trivial* invariant language (only $\emptyset$ and everything), no non-constant interpretation is definable at all, so as soon as a structure has two distinct orbits, adding counting modalities strictly increases expressive power. The finite half of the conjecture is true, and the enrichment it demands is necessary rather than merely convenient.

## Only equality is logical

There is a classical philosophical thesis lurking here, and the theory proves a sharp version of it.

Interpret not single points but *tuples*: an interpretation $I$ of $k$-tuples from a bare set $\alpha$ carrying no structure at all. Define the **kernel** of a tuple $(x_1, \dots, x_k)$ to be its pattern of coincidences — which coordinates are equal to which. Then:

> **Logical Invariance Theorem.** For a structureless set $\alpha$ of *any* cardinality, an interpretation of tuples with finitely many coordinates is recoverable from structural truth if and only if it depends only on the kernel of the tuple.

This is the formal form of the dictum that the only genuinely *logical* notions — the ones invariant under all permutations of the universe — are those built from equality. The binary case says it starkly: a two-place interpretation is recoverable exactly when it is a function of whether the two coordinates are equal. Equality itself is recoverable. Order is not: on a three-element set, the pairs $(0,1)$ and $(1,0)$ have identical equality patterns but opposite order values, so "less than" collides with itself and no structureless set can carry it. Order is something we bring.

The engine of the proof is a transport lemma: two finitely-indexed tuples with the same equality pattern are always carried onto each other by some permutation of the whole set. One builds the obvious bijection between their finite ranges and extends it to a permutation, splitting on whether the ambient set is finite or infinite.

And the finiteness of the *arity* is not a technicality. For infinitely many coordinates the classification fails outright: surjectivity of a sequence $\mathbb{N} \to \mathbb{N}$ is permutation-invariant, hence recoverable, yet the sequences $n \mapsto 2n$ and $n \mapsto n$ have the same kernel (both injective) and differ in surjectivity. With infinitely many coordinates there are permutation-invariant properties that equality patterns cannot see.

## The structure knows its own symmetries

One last turn, and the most self-referential. Everything above takes the symmetry group as given and asks what it makes recoverable. Reverse the arrow: *how much of the symmetry group is visible in the collection of interpretations it makes recoverable?*

The answer is: all of it, provided interpretations may speak about *configurations* — whole tuples of elements — rather than points.

> **Reconstruction Theorem.** A permutation $\sigma$ belongs to the symmetry group $G$ if and only if it preserves every $G$-recoverable interpretation of configurations.

The proof is a beautiful piece of self-reference. Given $G$, consider the *membership interpretation*: the interpretation of configurations which declares a configuration meaningful precisely when it *is* an element of $G$, viewed as a tuple. This interpretation is $G$-recoverable (because $G$ is closed under multiplication and inverses), and it detects $G$: any permutation preserving it must, by applying it to the identity configuration, land inside $G$.

The consequences cascade. The map sending a symmetry group to its recoverable theory is injective — distinct symmetry groups have genuinely distinct stocks of recoverable meanings. It is order-reversing, and strictly so: a strictly larger symmetry group has a strictly smaller theory. *More symmetry means strictly fewer recoverable meanings*, with no exceptions and no ties. Together with the reverse construction — sending a theory to the group of permutations preserving it — one gets a Galois connection in which the group-side closure operator is the identity: symmetry groups are exactly the Galois-closed objects on their side.

The moral for the whole programme: the recoverability boundary is not an artefact of how we chose to present the symmetry group. Structural truth determines its own symmetries. The boundary is intrinsic.

## Why any of this matters

The pattern is everywhere once you look for it.

In **databases**, a query is meaningful only if invariant under renaming the entities — the classical *genericity* requirement. Descent says which annotations survive renaming; the exponent counts how much a schema with symmetry destroys.

In **physics**, gauge-dependent quantities are precisely the non-recoverable interpretations: descriptions depending on a labelling the world does not provide. The gap between the vector potential and the field strength is the gap between a meaning that collides and one that survives.

In **machine learning**, a model equivariant under a symmetry group can only represent orbit-constant functions of its inputs; the exponent is a hard, architecture-independent bound on what such a model can express, and additivity says the bound behaves predictably when independent inputs are concatenated.

In **the philosophy of logic**, the Logical Invariance Theorem is the permutation-invariance criterion for logicality with an explicit and provably sharp finiteness hypothesis.

And in **combinatorics and chemistry**, the Burnside bridge is an old friend in new clothes: counting essentially-different colourings of a symmetric object *is* counting its recoverable interpretations.

## The shape of the answer

Start with a naive conjecture: meaning survives when it is orbit-constant and definable.

What the theory shows is that this splits into three separate truths, one for each regime. In the maximal invariant language, recoverability and definability are the *same thing*, with no hypotheses at all. In bounded languages on infinite structures, definability is *strictly stronger*, and parity is the witness. On finite structures, everything collapses to a single four-way equivalence, and the counting modalities that make it work are provably necessary.

And underneath all three sits one number, $\ell(M) = |M| - \#\text{orbits}$, additive over disjoint unions, vanishing exactly on rigid structures, and equal to the count of duplicate elements inside orbits — the exact quantity of external meaning that structure destroys.

Which corner of the triangle was $A$? The triangle has forgotten. Now we can say precisely how much it forgot: three corners, one orbit, $\ell = 2$.
