# Every Translation Loses Something: The Hidden Entropy of Functors

Imagine handing a friend a beautifully wrapped gift and asking them to describe it — but only by its shape. A cube of chocolates, a cube of soap, a cube of cufflinks: all three come back described as "a box." Something true has been said, and yet something has been lost. The description *forgets*. And once you have forgotten which of three cubes you were holding, no amount of staring at the word "box" will bring it back.

This everyday act — describing, simplifying, forgetting — is exactly what mathematicians call applying a **functor**, and this article is about how to measure, in precise numerical terms, *how much a functor forgets*.

## Structures, and maps between them

Mathematics is full of objects that come with structure. A *group* is a set together with a way to combine its elements. A *topological space* is a set together with a notion of which points are "near" which others. A *vector space* is a set with addition and scaling. In each case there is a plain set underneath, dressed up with extra rules.

A **functor** is a structure-preserving translation from one such world to another. The most humble and most revealing example is the **forgetful functor**: take a group and simply throw away the multiplication, remembering only its underlying set. Take a topological space and forget which sets are open, remembering only the bare collection of points. The functor is honest — it never lies about what remains — but it is forgetful. Wildly different groups can sit on top of the very same set. A single three-element set underlies exactly one group up to relabeling, but a set of countably many points underlies an entire universe of distinct topologies, almost all of which collapse to the identical naked set once you forget.

Category theorists have long had a qualitative vocabulary for this. A functor that never confuses two genuinely different things is called **faithful**; one that blurs distinctions loses information. But "loses information" was always a metaphor. The question this work answers is: *can we attach an actual number to it?* And the answer turns out to be a familiar one, borrowed from a completely different corner of science.

## Entropy: the physics of not knowing

In 1948 Claude Shannon gave the world a formula for uncertainty. If a random signal takes value $x$ with probability $p(x)$, its **entropy** is
$$H = -\sum_x p(x)\,\log p(x).$$
Entropy is largest when every outcome is equally likely (maximum ignorance) and zero when one outcome is certain (perfect knowledge). It is measured in bits when the logarithm is base two, and it quietly governs everything from data compression to the thermodynamics of black holes.

Shannon's genius was to realize that *information is the resolution of uncertainty*. If I tell you the outcome of a fair coin flip, I have given you exactly one bit, because I have erased exactly one bit of your uncertainty. The bridge this article builds is simple to state: **a functor's forgetfulness is just uncertainty in disguise, and so it too can be measured in bits.**

## The right way to count forgetting

Here is where care is needed, because the obvious guess is wrong.

Suppose our functor $F$ sends objects of a world $C$ to objects of a world $D$. For each target object $d$, let $c_d$ be the number of objects of $C$ that $F$ maps to $d$ — the size of the **fiber** over $d$, the crowd of things that all get described the same way. If $C$ has $n$ objects in total, then a randomly chosen object lands in fiber $d$ with probability $c_d/n$.

One's first instinct is to compute the Shannon entropy of *where things land*. But this measures the wrong thing. Even a perfectly faithful functor — one that forgets nothing — will produce a spread-out landing distribution and hence a large entropy, simply because it has many possible outputs. That number measures the richness of the target, not the loss along the way.

The correct measure is the **conditional entropy**: given that I tell you the output $d$, how much uncertainty remains about which input you started with? If the fiber over $d$ contains $c_d$ equally plausible inputs, the leftover uncertainty is exactly $\log c_d$. Averaging this over all the fibers, weighted by how often each occurs, gives the definition at the heart of this work:

$$H(F) \;=\; \sum_{d}\frac{c_d}{n}\,\log c_d.$$

This is the **functorial entropy** — the average number of bits still hidden about an object after you have been told its image. It is the honest, information-theoretic shadow of functoriality. Read it aloud: *for each possible description, weigh how likely that description is by how many things it fails to distinguish, and add it all up.*

## What the number knows

The beauty of a good definition is that theorems fall out of it, and each theorem confirms that the number is measuring what we hoped. Six of them anchor the theory.

**Forgetting is never negative.** $H(F) \ge 0$ always. You cannot un-forget; a translation can only lose information or break even, never conjure it. This is the reassuring baseline.

**Zero forgetting means faithfulness.** $H(F) = 0$ *if and only if* $F$ is injective on objects — it never sends two distinct things to the same place. Every fiber holds at most one object, so $\log c_d$ is $\log 1 = 0$ across the board. This is the precise, quantitative version of the old qualitative slogan "faithful functors lose no information." The metaphor has become a theorem.

**Uniform blurring has a clean formula.** If every fiber has the same size $k$ — the functor spreads its forgetting evenly, gathering $k$ inputs under every output — then
$$H(F) = \log k = \log\frac{|\text{objects of } C|}{|\text{objects of } D|}.$$
The loss is simply the logarithm of how many-to-one the map is. A two-to-one functor loses exactly one bit; a functor that squashes a thousand into one loses about ten bits.

**Total collapse is maximal.** A **constant functor**, which crushes everything in $C$ down to a single object, loses $\log n$ — the entire information content of the domain. It is the description "it's a thing," true of everything and therefore useless.

**Nothing forgets more than there is to know.** For *any* functor, $H(F) \le \log n$. You cannot lose more information than the domain contained in the first place. The constant functor sits exactly at this ceiling.

**Forgetting compounds — the data-processing inequality.** This is the deepest of the six. Suppose you translate twice: first through $f$, then through a further functor $g$, obtaining the composite $g\circ f$. Then
$$H(f) \;\le\; H(g\circ f).$$
Each additional stage of translation can only *increase* the total loss, never repair it. Once information has fallen through the cracks of $f$, no downstream $g$ can recover it, and $g$ may well throw away more. This mirrors exactly the famous data-processing inequality of information theory: post-processing a signal cannot create information about its source. Here it becomes a statement about *composing functors* — a categorical law, proved from the categorical definition.

## The examples that started it all

Return to the forgetful functors that motivated the whole enterprise.

The functor **Ab** that turns any group into its "abelianization" — the closest commutative approximation of it — is genuinely many-to-one. Different noncommutative groups can share the same commutative shadow. On the finite models where the counting is exact, such an averaging functor forgets on the order of $\log 2$ — about one bit — matching the intuition that each abelian target typically hides a small nontrivial family of noncommutative preimages.

The **inclusion** of finite groups into all groups forgets nothing: each finite group is included as itself, no two are ever confused, the functor is injective on objects, and so $H = 0$, on the nose.

And the great forgetter — the functor from **topological spaces to sets** that discards the topology entirely — sits at the opposite extreme. Over an infinite set lie uncountably many distinct topologies, all collapsing to the same underlying points. Its fibers are infinite, and its entropy runs off to infinity. It is the ultimate act of mathematical forgetting.

## Why this matters

The moral is larger than any single formula. Entropy is usually introduced as a fact about *randomness* — coins, gases, noisy channels. What this work shows is that entropy is also a fact about *structure-preserving maps*, about the very act of translation between mathematical worlds. Every functor casts an information-theoretic shadow, and the length of that shadow is a number you can compute.

This reframes a philosophical intuition as arithmetic. We say that abstraction "throws away detail," that a model "simplifies reality," that a summary "loses nuance." Those are all functors, and all of them have an entropy. The data-processing inequality then says something almost moral: *layers of abstraction accumulate loss.* Each time you summarize a summary, you can only slip further from the source.

There is much still to explore. One can weight the objects unevenly, replacing the democratic uniform distribution with a prior that says some objects matter more — recovering the full Shannon conditional entropy. One can look not just at how a functor treats *objects* but at how it collapses the *maps between them*, a finer and richer accounting. One can chase the infinite examples rigorously, or seek a chain rule that decomposes the loss of a composite translation into a sum of stages, exactly as Shannon's $H(X,Y) = H(X) + H(Y\mid X)$ does for random variables.

But the core idea is already luminous, and it is this: to translate is to forget, and forgetting can be counted. Every functor loses information — and now we know precisely how much.
