# The Hidden Sheet: Zombies, Memory, and the Mathematics of What Function Cannot See

Imagine a perfect duplicate of you. It answers every question as you would, recognizes friends, recoils from pain, writes poems about sunsets, and insists that it is conscious. Yet suppose—this is the philosopher’s provocation—that there is nothing it is like to be that duplicate. The lights are out inside.

Such a being is called a philosophical zombie. Whether one is physically possible is not the question addressed here. The sharper mathematical question is this: **what can a purely functional description determine?** If we record only what a system does, can that record settle what, if anything, the system experiences?

A clean answer emerges once behavior and experience are represented as different coordinates. The answer is both powerful and carefully limited. Functional data alone admits an experience-preserving copy and an experientially void twin with exactly the same behavior. This is a theorem about underdetermination, not a claim that actual humans have zombie duplicates. It says that a vocabulary restricted to function cannot, by itself, distinguish two states that differ only in a coordinate the vocabulary omits.

That simple “hidden coordinate” reappears in three apparently distant places: semantic incompleteness, integrated information, and finite memory. Together they form a mathematical story about forgetful maps—maps that preserve what can be observed while collapsing what cannot.

## Two maps out of a world

An **experience model** consists of a collection of possible worlds, a collection of functional profiles, a collection of experiential values, and two assignments. One assignment sends each world to its functional profile; the other sends it to its experiential value. Among the experiential values, one distinguished value means “void.”

Two worlds are **functional twins** when they receive the same functional profile. A world is **conscious**, in this minimal vocabulary, when its experiential value is not void. A **zombie twin** of a conscious world is a functional twin whose experiential value is void.

These definitions say almost nothing about the rich nature of consciousness. That restraint is deliberate. The framework isolates one issue: whether experience is determined by function.

Now take any experience model and duplicate every world into two sheets. A world $x$ becomes $(x,1)$ on the retained sheet and $(x,0)$ on the void sheet. Behavior ignores the second coordinate:

$$
B(x,b)=B(x).
$$

Experience, however, sees it. On the retained sheet, $(x,1)$ carries the original experience; on the void sheet, $(x,0)$ carries the void value. Thus

$$
E(x,1)=\operatorname{some}(E(x)), \qquad E(x,0)=\operatorname{none}.
$$

The notation “some” and “none” merely ensures that even an originally void-looking value becomes present on the retained sheet, while the other sheet is genuinely absent.

This gives the **Conservative Zombie Extension Theorem**: for every world $x$ in every experience model, the doubled model contains an alive copy and a zombie copy with the same original functional profile but different experiential values. The old functional description is preserved exactly.

The proof is visible in the construction. Both copies project to $x$, so their behavior agrees. Their experience differs because a present value cannot equal absence.

An immediate consequence concerns any proposed definition of consciousness that depends only on function. Let $P$ be any predicate on functional profiles. If $P(B(x))$ holds for the retained copy, then it also holds for the void copy, because both have the same value of $B$. No functional test can separate the sheets.

This result must not be overstated. It does **not** say that every fixed model already contains a zombie. Consider a one-world model in which the sole experiential value is void. It has no conscious original and therefore no zombie witness. The theorem says instead that any model has a conservative extension exhibiting the gap. The distinction between “already exists” and “can be added without changing function” is the logical heart of the result.

## A gap with exactly one witness per profile

The construction becomes especially transparent in a canonical model. Begin with any set $X$ of functional profiles. For each $x\in X$, create exactly two worlds, $(x,1)$ and $(x,0)$. Both behave as $x$; the first carries one qualitative marker and the second carries none.

Here every zombie contrast is determined uniquely by its profile. The conscious member must be $(x,1)$, the void member must be $(x,0)$, and functional agreement forces the same $x$ on both sides. Consequently, the set of functional profiles and the set of zombie witnesses correspond one-to-one:

$$
X \cong \{\text{zombie witnesses in the canonical model}\}.
$$

This classification matters. The hidden Boolean sheet does not create a shapeless multitude. In the minimal model, it creates exactly one experiential contrast over each functional profile.

## The semantic mirror

Now replace worlds by codes. A **semantic system** assigns to every code two properties: whether the code is true in an intended interpretation and whether the system accepts it. A **semantic gap** is a code that is true but not accepted.

Using the same profile set $X$, create codes $(x,b)$ with $b\in\{0,1\}$. Declare every code true, but accept exactly those on the $1$-sheet. The system is sound, because everything it accepts is true. Yet each $(x,0)$ is true and unaccepted.

Again there is exactly one gap witness per profile:

$$
X \cong \{\text{true but unaccepted codes}\}.
$$

Combining the two classifications yields the **Zombie–Semantic Gap Isomorphism**:

$$
\{\text{canonical zombie witnesses}\}
\cong
\{\text{canonical true but unaccepted codes}\}.
$$

The correspondence sends the experiential contrast over $x$ to the omitted true code $(x,0)$. Its inverse reads off $x$ and rebuilds the unique contrast above it.

This is a precise structural analogy to incompleteness: both sides contain a visible profile plus a hidden two-valued fiber, and the relevant witness lies on the omitted sheet. But it is not a claim that consciousness is arithmetic, nor a derivation of subjective experience from a classical incompleteness theorem. It is an isomorphism between two explicitly constructed witness spaces. Without shared coding assumptions, no universal isomorphism exists: the all-void experience model has no zombie witnesses, while the one-profile semantic construction has a true unaccepted code.

## Where integrated information fits—and where it does not

Functional organization can itself have rich quantitative structure. Consider a system with $n$ elements. Every nonempty proper subset $A$ specifies a nontrivial cut between $A$ and its complement. Assign to each cut a nonnegative effective-information value $I(A)$, interpreted as the information lost when the cut is made.

For $n\ge 2$, at least one such cut exists. Define integrated information by

$$
\Phi=\min_{\varnothing\ne A\subsetneq \{1,\ldots,n\}} I(A).
$$

A cut attaining this minimum is a **minimum-information partition**. Because the candidate set is finite and nonempty, such a partition always exists. The number $\Phi$ is nonnegative, is no larger than every cut value, and is the greatest common lower bound of all cut values.

Several useful consequences follow. First,

$$
\Phi=0
\quad\Longleftrightarrow\quad
\text{some nontrivial cut has }I(A)=0.
$$

Second, if two systems satisfy $I_S(A)\le I_T(A)$ for every cut, then $\Phi_S\le\Phi_T$. Third, if two systems share a minimizing cut and agree on its value, then their integrated information is equal.

These facts describe the landscape of functional decompositions. But the two-sheeted experiential coordinate is orthogonal to that landscape. A finite system may possess a minimum-information partition while a chosen functional profile simultaneously supports a zombie witness and a semantic-gap witness. The minimum over cuts does not inspect the hidden sheet. Thus even a sophisticated functional invariant need not determine experience unless experience is explicitly tied to it by an additional assumption.

The boundary $n\ge2$ is substantive, not cosmetic. Systems with zero or one element have no nonempty proper subset, so their minimum-information landscape is empty and $\Phi$ is not defined by this construction.

## Memory as quotienting

The same theme appears when a finite memory records an unlimited stream of events. Let an experience stream be a finite word over a nonempty alphabet. Concatenating words combines streams. A **compositional memory** is a map $m$ satisfying

$$
m(uv)=m(u)m(v), \qquad m(\varepsilon)=1,
$$

where $\varepsilon$ is the empty stream and $1$ is the neutral memory state.

There are infinitely many finite streams but only finitely many states in a finite memory. Therefore two distinct streams $u\ne v$ must satisfy

$$
m(u)=m(v).
$$

This is the **Finite Memory Loss Theorem**. It is not merely a counting curiosity. Equality of memories defines an observational indistinguishability relation, and compositionality makes this relation compatible with concatenation. If $u$ is indistinguishable from $u'$ and $v$ from $v'$, then $uv$ is indistinguishable from $u'v'$.

The streams erased all the way to neutral memory also have structure. The empty stream is erased, and concatenating two erased streams yields another erased stream. They form a submonoid: a collection closed under the operation and containing its identity.

Most importantly, the **Memory Quotient Theorem** says that the observable memory algebra is exactly the algebra of streams modulo indistinguishability:

$$
\frac{\text{all streams}}{u\sim v\iff m(u)=m(v)}
\cong
\text{reachable memory states}.
$$

So forgetting is quotienting. It turns distinct histories into a single observable class.

Targeted forgetting makes this concrete. Mark each event type as retained or erased, then delete every erased symbol from a stream. Any forgotten symbol maps to the neutral stream. Moreover, every compositional map that identifies at least the same pairs of streams factors uniquely through the quotient. This universal property says that the quotient is not just one convenient compression; it is the canonical interface for every downstream process that respects the chosen forgetting rule.

## One pattern, three languages

Zombies, semantic gaps, and memory loss share a diagrammatic idea. There is a richer space upstairs and an observable space downstairs. A forgetful map sends multiple upstairs states to one downstairs description. Its **fiber** over an observable value is the collection of hidden alternatives compatible with that value.

In the canonical consciousness model, each functional profile has a two-point fiber: present or void. In the semantic model, each profile has an accepted and an unaccepted code, with truth held fixed. In finite memory, some memory state must have at least two distinct histories in its fiber.

Mathematics does not decide which of these models nature chooses. What it does decide is the burden of explanation. If a theory speaks only the language of the downstairs variables, then distinctions living entirely in the fibers cannot be recovered without a new principle. Functional measures can be profound, predictive, and scientifically useful while still leaving a hidden coordinate underdetermined.

That is the lasting lesson of the hidden sheet. The mystery is not produced by vague talk about inner light. It arises from a precise structural question: **what did our map forget?**
