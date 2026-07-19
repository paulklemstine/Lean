# What a Functor Forgets

## An entropy ledger for maps, classifications, and compressed descriptions

Imagine six sealed envelopes on a table. Each contains one of six distinct source states. A clerk passes every envelope through a machine and stamps it with one of three labels: $0$, $1$, or $2$. The rule is perfectly regular—two source states receive each label. When you see the label, you learn something, but not everything. The label narrows six possibilities to two.

How should we account for that change in knowledge?

The natural language is entropy. Yet there are two different quantities hiding in the story. One measures the diversity of labels that remain visible. The other measures the ambiguity concealed behind the label. Confusing them leads to attractive but incorrect formulas. Separating them yields a clean conservation law for every deterministic map between finite collections, and it clarifies what “information loss” can mean when the map is induced by a functor between categories.

The central message is simple: a deterministic map does not destroy the entire information budget. It divides that budget into what the output reveals and what its fibers hide.

## From objects to a deterministic channel

Let $A$ be a nonempty finite set of source objects, let $B$ be a finite set of possible output objects, and let

$$
f:A\to B
$$

be any map. In categorical applications, $f$ is the map on objects induced by a functor. Choose an element of $A$ uniformly at random and observe only its image in $B$.

For an output $b\in B$, the **fiber** above $b$ is

$$
f^{-1}(b)=\{a\in A:f(a)=b\}.
$$

Its output probability is therefore

$$
p_b=\frac{|f^{-1}(b)|}{|A|}.
$$

Empty fibers have probability zero. The nonempty fibers partition $A$, so the probabilities are nonnegative and satisfy

$$
\sum_{b\in B}p_b=1.
$$

This elementary partition is the engine behind everything that follows.

## Two numbers, not one

The first quantity is the Shannon entropy of the observed output:

$$
H_{\mathrm{out}}(f)=-\sum_{b\in B}p_b\log p_b.
$$

Here and throughout, $\log$ denotes the natural logarithm, so information is measured in nats. Terms with $p_b=0$ contribute zero. This entropy answers: **How diverse and unpredictable is the visible output?**

The second quantity is the expected logarithmic size of the observed fiber:

$$
L_{\mathrm{fib}}(f)=\sum_{b\in B}p_b\log |f^{-1}(b)|.
$$

This answers a different question: **After seeing the output, how much source ambiguity remains?** If the output is $b$, there are $|f^{-1}(b)|$ equally likely source objects compatible with the observation, so $\log|f^{-1}(b)|$ is the residual information needed to distinguish them.

These quantities can move in opposite directions. A constant map has no output diversity at all, but it hides every distinction among source objects. An injective map displays every distinction and hides none.

## The information ledger balances exactly

The key result is the **Entropy–Loss Chain Rule**.

**Theorem.** For every map $f:A\to B$ from a nonempty finite set $A$ to a finite set $B$,

$$
H_{\mathrm{out}}(f)+L_{\mathrm{fib}}(f)=\log |A|.
$$

The proof is a one-line idea expanded across the fibers. Whenever $p_b>0$,

$$
p_b=\frac{|f^{-1}(b)|}{|A|},
$$

and hence

$$
-\log p_b+\log |f^{-1}(b)|=\log |A|.
$$

Multiplying by $p_b$, summing over $b$, and using $\sum_b p_b=1$ gives the theorem. Empty fibers contribute nothing.

This identity is a conservation law for deterministic classification. The original uniform source contains $\log|A|$ nats. Observation converts part of that budget into visible output entropy; the remainder survives as hidden fiber ambiguity.

The theorem also explains why output entropy alone should not be called information loss. If all source objects collapse to one output, then $H_{\mathrm{out}}(f)=0$, even though the map has forgotten as much as possible. In that case $L_{\mathrm{fib}}(f)=\log|A|$. Conversely, an injective map can have large output entropy but zero loss.

## When does a map forget nothing?

The **Zero-Loss Characterization** gives a complete answer at object level.

**Theorem.** For a map $f:A\to B$ with $A$ nonempty and finite,

$$
L_{\mathrm{fib}}(f)=0
$$

if and only if $f$ is injective.

If $f$ is injective, every attained fiber has size one, and $\log 1=0$. Thus every term in the expected loss vanishes. Conversely, if $f$ is not injective, some fiber contains at least two elements. That fiber occurs with positive probability, its logarithmic size is positive, and all other contributions are nonnegative. The total loss must therefore be positive.

This result needs careful interpretation for categories. A functor is called **faithful** when it is injective on each map between morphism sets. Object injectivity is a different property. A functor may preserve all morphisms faithfully while identifying objects, or it may be injective on objects while identifying distinct morphisms. Therefore the scalar $L_{\mathrm{fib}}$ detects object identification, not categorical faithfulness. A genuinely morphism-sensitive entropy will need an additional component.

## Uniform fibers: the logarithmic quotient formula

The cleanest case occurs when every attained output has the same number $k$ of preimages. Suppose the image of $f$ contains $m$ outputs and every nonempty fiber has cardinality $k$. Then $|A|=mk$, and every attained output has probability $1/m$.

The **Uniform-Fiber Theorem** states:

$$
L_{\mathrm{fib}}(f)=\log k
$$

and

$$
H_{\mathrm{out}}(f)=\log m.
$$

Equivalently,

$$
L_{\mathrm{fib}}(f)=\log\frac{|A|}{m}.
$$

The distinction matters. The logarithm of the fiber size is the information loss; the logarithm of the number of attained outputs is the visible entropy. Together they give

$$
\log m+\log k=\log(mk)=\log|A|.
$$

Return to the six envelopes labeled by residues modulo three. The map sends each $i\in\{0,1,2,3,4,5\}$ to its remainder modulo $3$. There are $m=3$ labels and $k=2$ states per label. Consequently,

$$
H_{\mathrm{out}}=\log 3,
\qquad
L_{\mathrm{fib}}=\log 2,
$$

and their sum is $\log 6$.

At the two extremes, a constant map has $m=1$ and $k=|A|$, so its output entropy is zero and its loss is $\log|A|$. An injective map has $k=1$ and $m=|A|$, so its loss is zero and its output entropy is $\log|A|$.

## Why this belongs to category theory

A functor translates one mathematical world into another. A forgetful functor may discard structure; a quotient-like construction may identify objects; an inclusion may preserve distinctions. Looking only at the induced object map on finite collections turns the functor into a deterministic information channel.

This perspective is useful, but its scope must be respected. Raw object counts depend on how a category is presented. Equivalent categories can contain different numbers of displayed objects. Moreover, familiar large categories generally have too many objects for a uniform distribution to exist. One cannot simply count all topological spaces or all groups and divide by a total number of objects. Infinite entropy is a statement about a probability measure and a divergent expectation, not merely about the existence of one infinite fiber.

The finite theory therefore serves as a precise foundation rather than a license for unweighted infinite counting. It tells us exactly what survives any extension: probabilities belong on outputs, losses belong in conditional fibers, and the total must obey a chain rule.

## Where the idea appears in practice

Consider database anonymization. A record may be mapped to a coarser label such as an age band and region. Output entropy measures how varied those released labels are. Fiber loss measures how many original records remain compatible with a released label, averaged according to how often that label occurs. The same release can have high visible diversity and still conceal substantial identity information.

In clustering, a data point is sent to a cluster label. The entropy of cluster labels reports how balanced the clustering is. The expected log cluster size reports the ambiguity of recovering the original point from its label. Uniform clusters make the formulas especially transparent, but the chain rule remains exact for unequal clusters.

In lossy data processing, a many-to-one function compresses a state into a code. The output entropy describes the code stream under a uniform source; the fiber loss quantifies irreversible ambiguity. In reversible computation, this is the information that must be retained elsewhere if the overall process is to remain invertible.

And in mathematics itself, classification maps routinely replace an object by an invariant: dimension, rank, cardinality, homology, or isomorphism class. The fibers gather objects sharing the same invariant. The entropy ledger measures both the richness of the invariant’s values and the distinctions it leaves unresolved.

## The next layer

The finite object theory suggests several extensions. For composable maps, a relative chain rule should track the actual pushforward distribution at the intermediate stage; naive addition can fail when conditional fibers are not uniform. For finite groupoids, raw counts should be replaced by homotopy cardinalities that weight an isomorphism class by the reciprocal of its automorphism-group size. That correction aims to make entropy invariant under equivalence.

A fuller categorical theory should also split loss into object and morphism components. The object term developed here vanishes exactly under object injectivity. A morphism term could vanish exactly when the functor is faithful on the supported hom-sets. Finally, infinite categories require genuine probability measures on isomorphism classes and measurable conditional entropy. Divergence should occur when conditional fiber entropy is infinite on a set of positive output measure—not merely because an isolated fiber happens to be infinite.

The deepest lesson is not that every functor has one magical entropy. It is that translation has an information anatomy. A map creates a visible distribution and a hidden conditional ambiguity. Once those are named separately, the bookkeeping becomes exact:

$$
\text{visible information}+\text{hidden information}=\text{source information}.
$$

That balance turns the vague phrase “a functor forgets structure” into a quantitative question—and, in the finite setting, gives it a complete answer.
