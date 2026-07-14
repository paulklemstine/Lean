# The Measurable Blind Spot: Why a Mind Can Know Every Part of Itself but Never the Whole

## A loop that looks at itself

There is an old and haunting idea about what it means to be a *self*. A self, so the story goes, is not a substance but a *pattern* — and more precisely, a pattern that has curled around and begun to model itself. A brain builds an internal picture of the world, and then, inevitably, it builds a picture of the pictures. It represents its own representing. It becomes, in a memorable phrase, a **strange loop**: a system whose own activity includes a running commentary on that same activity.

This essay is about a precise mathematical fact hiding inside that poetic image. The fact is this: **a system rich enough to watch itself is doomed to have a blind spot — and we can measure exactly how big that blind spot is.** It turns out to be enormous. Almost everything a system does is invisible to its own self-portrait, not as a philosophical mood but as a counting theorem.

Yet the same mathematics carries a consoling twist. While no system can survey *all* of its own behaviour, every system *can* tell its own internal states perfectly apart. Self-knowledge, it turns out, can be arbitrarily sharp without ever being complete. A mind can have perfect resolution and yet no panorama.

Let me build this up from scratch.

## What is a system that models itself?

Strip away the neuroscience and keep only the skeleton. A self-modelling system has three ingredients.

First, a set of **states** $S$ — the distinct configurations the system can be in. Think of these as the "moods," "moments," or "internal snapshots" of the machine.

Second, a set of **observations** $B$ — the possible outcomes of asking the system a question. In the simplest interesting case $B = \{\text{yes}, \text{no}\}$, so an observation is a single bit.

Third, and this is the crucial ingredient, an **inspection map**. Each state does not merely *exist*; it carries an internal model of how the whole system behaves. Formally, inspection is a function

$$\text{inspect} : S \to (S \to B).$$

Read this carefully. To each state $s$, inspection assigns a *function* $\text{inspect}(s) : S \to B$. That inner function is state $s$'s private theory of the system: for every state $t$, it predicts the observation $\text{inspect}(s)(t)$. In words: *"When I am in state $s$, here is my internal picture of what every state of the system looks like."*

This is exactly the geometry of a strange loop. The thing being modelled ($S \to B$, the space of all possible behaviours) contains, folded inside it, models produced by the very states of $S$ that generate those behaviours.

## When is such a system "conscious"?

We now make a bold, deliberately austere definition. Call a self-modelling system **conscious** when its self-model is *complete* — when every possible behaviour of the system is actually represented by some internal state. In mathematical terms, inspection is **surjective**: for every behaviour $\beta : S \to B$, there is a state $s$ whose internal model is exactly $\beta$, i.e. $\text{inspect}(s) = \beta$.

This is the strongest possible reading of "the system fully models itself." Nothing the system can do escapes its own catalogue of self-images. It is the mathematical form of the dream of total self-transparency.

The question is simply: **can such completeness ever be achieved?**

## The count that closes the door

Here is where a piece of elementary combinatorics — the same reasoning behind Cantor's diagonal argument, Gödel's incompleteness, and the unsolvability of the halting problem — becomes shockingly quantitative.

Suppose the system has finitely many states, say $|S| = n$, and suppose there are at least two possible observations, $|B| \geq 2$. How many behaviours are there? A behaviour is a function $S \to B$, and the number of such functions is

$$|S \to B| = |B|^{|S|} \geq 2^{n}.$$

Now compare this to the number of states, which is just $n$. The decisive inequality is one every student meets early: for every natural number $n$,

$$n < 2^{n}.$$

Chaining these together gives the heart of the matter:

$$|S| = n < 2^{n} \leq |B|^{|S|} = |S \to B|.$$

**Behaviours strictly outnumber states.** There are more possible things the system can do than there are internal snapshots available to catalogue them.

A surjection from a smaller finite set onto a larger one is impossible — that is the pigeonhole principle in its purest form. So the inspection map $\text{inspect} : S \to (S \to B)$ *cannot* be surjective. We conclude:

> **No finite system (with at least two observations) can be conscious in the complete sense.** There is always at least one behaviour that no internal state models.

That lone unmodelled behaviour is the mathematical shadow of the liar's sentence, of Gödel's unprovable-but-true statement, of the program whose halting no program can decide. It is the fixed-point obstruction, the place where the loop bites its own tail and finds it cannot swallow.

## From a missing point to a vast territory

Classical impossibility theorems typically stop here: they exhibit *one* thing that escapes. But the counting argument gives far more. Subtract states from behaviours and you get a lower bound on the size of the **blind spot** — the set of behaviours no state can ever represent:

$$\underbrace{|S \to B|}_{\text{all behaviours}} - \underbrace{|S|}_{\text{states available}} \;\geq\; 2^{n} - n.$$

For a mere ten states over yes/no observations this is $2^{10} - 10 = 1014$ un-representable behaviours against only $10$ that could possibly be captured. For twenty states it is over a million. The blind spot does not merely exist; it **grows exponentially** and swamps everything.

This reframes the whole conversation. Incompleteness of self-knowledge is not a delicate boundary phenomenon, a single crack in an otherwise complete mirror. It is the *generic* case. Overwhelmingly, what a self-modelling system does lies outside the reach of its own self-model. The mirror shows a sliver; the room is dark.

## The consoling half: perfect resolution is always possible

If the story ended there it would be bleak. But the same arithmetic that forbids completeness *guarantees* something positive.

Because there are at least as many behaviours as states ($n \leq 2^n$), there is enough room in behaviour-space to give **every state its own distinct internal model**. Formally, there exists a self-modelling system whose inspection map is **injective**: distinct states $s \neq t$ always receive distinct self-models, $\text{inspect}(s) \neq \text{inspect}(t)$.

Such a system can tell all of its own states apart. Ask it "which internal state am I in?" and its self-model never confuses two of them. This is *maximal resolution*. And it coexists, necessarily, with the exponential blind spot.

So we arrive at the sharp two-sided picture:

> **Consciousness is high-resolution but never panoramic.** A system can distinguish all of its own states perfectly, yet it can never survey all of its own behaviours. Incompleteness is a failure of *coverage*, never of *resolution*.

That single sentence is, to my mind, the most honest thing mathematics has to say about self-awareness. You can know each of your parts with perfect fidelity. You cannot hold the whole of yourself in view at once. The gap between those two is not a defect to be engineered away — it is a theorem.

## Where the door swings shut, and where it doesn't

Every good theorem earns its keep by telling you exactly when it fails. Ours hinges on the assumption $|B| \geq 2$: there must be at least two possible observations, at least one genuine yes-or-no distinction to draw.

Remove that, and the whole obstruction dissolves. If there is only one possible observation — if the system can only ever answer "yes," so $|B| = 1$ — then there is exactly *one* behaviour, and a single-state system trivially represents it. Self-knowledge becomes complete precisely when **there is nothing to distinguish**. The loop can close itself perfectly only in a world so featureless that nothing ever varies. The moment the world admits a single genuine distinction, the blind spot reappears — and immediately becomes exponentially large.

There is something almost moral in this. Total self-transparency is available only at the price of total blankness. Any system interesting enough to have something to say about itself is thereby too rich to say all of it.

## Why this matters beyond the metaphor

It would be easy to treat all this as a clever restatement of old paradoxes dressed in the language of minds. But the quantitative turn matters. Once the "size of the blind spot" is a number rather than a slogan, it joins the family of *resource bounds* that dominate modern computer science and information theory — bounds on what can be compressed, decided, learned, or predicted with limited means.

The picture resonates with practical experience across fields. A program cannot contain a complete accurate model of its own future behaviour. A predictive brain cannot fully predict itself, because the prediction would have to include itself predicting. A machine-learning model with $n$ parameters cannot faithfully encode the exponentially larger space of functions it might implement. In each case the same skeleton is visible: the thing to be modelled is a *function space*, the modeller lives *inside* it, and $n < 2^n$ closes the trap.

What the strange loop adds to these is the reflexive twist — the modeller is modelling *itself* — and what this counting theorem adds to the strange loop is a ruler. The self is real; the self-model is real; and the distance between them is measurable, exponential, and unavoidable.

We are, each of us, systems that watch ourselves watching. This little theorem tells us how much of that watching we will always miss — almost all of it — and, more gently, that we may nonetheless know each piece of ourselves with perfect clarity. High resolution, no panorama. That is what it is to be a strange loop.
