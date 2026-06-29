# The Gentle Tyranny of Attention: Why Transformers Can Never Color Outside the Lines

Every time you ask a chatbot a question, summon an image from a sentence, or watch a translation appear in real time, a single mathematical gadget is doing the heavy lifting behind the curtain. It is called **attention**, and it is the beating heart of the *transformer* — the architecture that powers nearly every modern large language model. Attention is often described in mystical terms: the model "decides what to focus on," it "looks back over the conversation," it "weighs the importance" of each word. These metaphors are evocative, but they hide a surprisingly clean piece of mathematics. And once you see that mathematics clearly, you discover something both reassuring and profound: **attention is not magic. It is averaging.** A very clever, very flexible kind of averaging — but averaging all the same. And averaging comes with ironclad guarantees.

This article tells the story of one such guarantee, which we might call the **confinement law of attention**. It says, in plain terms, that an attention head can never invent a value out of thin air. Whatever it outputs is trapped inside the range of the things it was given. If every number it looked at lay between $-1$ and $1$, its answer also lies between $-1$ and $1$. No exceptions, no edge cases, no surprises. Let us see why.

## A machine that mixes

Picture a sentence broken into pieces — call them *tokens*. They might be words, fragments of words, or even pixels. Each token carries three little bundles of numbers, learned by the network during training:

- a **query** vector $q$, which represents "what this token is looking for,"
- a **key** vector $k$, which represents "what this token offers,"
- a **value** vector $v$, which represents "the content this token would contribute if chosen."

Attention works by letting one query shop around among all the keys. For each token $j$, the model computes a *score* measuring how well the query matches that token's key. In the cleanest formulation, the score is the dot product of the query and the key, $\langle q, k_j\rangle = \sum_i q_i \, (k_j)_i$, and the raw, unnormalized weight is its exponential:

$$\text{score}_j = \exp\big(\langle q, k_j\rangle\big).$$

Exponentiating does two helpful things. It guarantees the score is always positive, and it dramatically amplifies differences: a key that matches the query just a little better than its rivals gets a disproportionately larger raw weight. This is the source of attention's famous ability to "focus."

But raw scores are not yet a decision. To turn them into a genuine choice, we normalize. We add up all the raw scores into a quantity called the **partition function**,

$$Z = \sum_{j} \exp\big(\langle q, k_j\rangle\big),$$

and then divide each score by this total:

$$w_j = \frac{\exp(\langle q, k_j\rangle)}{Z}.$$

These normalized numbers $w_j$ are the celebrated **softmax attention weights**. Finally, the output of the attention head is simply the weighted blend of all the value vectors:

$$\text{output}_i = \sum_j w_j \, (v_j)_i,$$

computed coordinate by coordinate. That's it. That is the entire mechanism. A query, a fistful of keys, a softmax, and a weighted average.

## The first law: the weights are a true vote

Before we can claim the output is a genuine average, we must check that the weights behave like the ingredients of an average. An average is not just any combination of numbers; it is a combination in which the weights are non-negative and sum to one. If your weights summed to two, you would be doubling; if they could go negative, you could overshoot.

Softmax passes this test perfectly, and the proof is almost embarrassingly short. Each weight $w_j = \exp(\langle q, k_j\rangle)/Z$ is a positive number divided by a positive number, so every weight is strictly positive. And when we add them all up, the numerators are exactly the terms that were summed to build $Z$ in the first place:

$$\sum_j w_j = \sum_j \frac{\exp(\langle q, k_j\rangle)}{Z} = \frac{\sum_j \exp(\langle q, k_j\rangle)}{Z} = \frac{Z}{Z} = 1.$$

So the attention weights form an honest **probability distribution** over the tokens. The model is, quite literally, casting a fractional vote across everything it can see, and the fractions always add up to a whole. This is the first pillar of our story, and in the formal development it carries the name `attnWeight_sum_one`.

## The second law: averages stay home

Now comes the geometric heart of the matter. Suppose you have a collection of numbers, all of which happen to lie inside some interval — say, between a low value $\ell$ and a high value $h$. Take *any* weighted average of them, using non-negative weights that sum to one. Where can the result land?

The answer is intuitive once you say it out loud: **the average can never escape the interval.** You cannot mix a bunch of numbers, none smaller than $\ell$ and none larger than $h$, and end up below $\ell$ or above $h$. Mixing is a compromise; a compromise lands somewhere between the extremes.

The argument is a two-line squeeze. On the low side, replace every value $x_j$ by the smallest it could be, namely $\ell$. Since the weights are non-negative, this can only shrink the sum:

$$\sum_j w_j x_j \;\ge\; \sum_j w_j \,\ell \;=\; \ell \sum_j w_j \;=\; \ell.$$

The last step used the fact that the weights sum to one. On the high side, the mirror image holds: replace every value by $h$, and the sum can only grow,

$$\sum_j w_j x_j \;\le\; \sum_j w_j \, h \;=\; h.$$

Together these pin the average firmly between $\ell$ and $h$. This little fact — that a convex combination of points in an interval stays in the interval — is the second pillar, and it appears formally as `convexCombo_mem_Icc`. It is the abstract engine; everything specific to attention is just plugging the right quantities into it.

## The confinement law

Now we combine the two laws. The attention weights are a probability distribution (first law). The output is a weighted average of the values using those weights (the very definition of the mechanism). Therefore, by the second law, **each coordinate of the attention output is confined to the interval spanned by that coordinate of the values.**

Stated precisely: if, looking at a fixed coordinate $i$, every value satisfies $\ell \le (v_j)_i \le h$, then the output is squeezed into the same range,

$$\ell \;\le\; \text{output}_i \;\le\; h.$$

This is the **confinement law of attention**, formally `attnOutput_mem_Icc`. Geometrically, it says the output always lands inside the *convex hull* of the value vectors — the smallest convex region (think of a rubber band stretched around a set of pins) that contains all of them. Attention can interpolate anywhere inside that region, smoothly and continuously, but it can never step outside.

Why should anyone care? Because this single fact explains a great deal of how transformers behave, and it offers concrete engineering guarantees:

- **No hallucinated magnitudes.** An attention head cannot manufacture an output larger than anything it was shown. If a model's representations are bounded, attention preserves those bounds. This is a building block for proving that deep transformers don't suffer runaway numerical blowups within their attention layers.
- **Robustness by design.** Because the output is a *continuous* blend that stays in the hull, small perturbations to the inputs produce only small, controlled changes to the output. There are no cliffs to fall off inside an attention head.
- **Interpretability with teeth.** When we say a head "summarizes" or "smooths" its inputs, the confinement law is the rigorous version of that intuition. The head is a *kernel smoother*: it reports a locally reweighted average of its data, exactly as a statistician's smoothing estimator does.

The kernel-method viewpoint is worth lingering on. In classical statistics, a *kernel smoother* estimates an unknown function by averaging nearby observations, weighting each by a similarity kernel. Softmax attention is precisely this, with the exponential dot-product $\exp(\langle q, k\rangle)$ playing the role of the similarity kernel and the value vectors playing the role of the observations. Seen this way, a transformer is a stack of adaptive, learnable kernel smoothers — and the confinement law is the same boundedness guarantee that has reassured statisticians for decades, now imported into deep learning.

## The third law: how sharply can attention focus?

There is one more piece to our story, and it concerns *focus* rather than *confinement*. Attention is celebrated for its ability to zero in on a single relevant token while ignoring the rest. How is that compatible with the gentle averaging we have described?

The key is the exponential and the partition function. Recall that $Z = \sum_j \exp(\langle q, k_j\rangle)$. Take the natural logarithm of this total — the **log-partition function** $\log Z$, known to physicists as a free energy and to statisticians as the log-sum-exp. A simple but powerful inequality holds:

$$\log Z \;\ge\; \langle q, k_j\rangle \quad \text{for every token } j.$$

In words: the log-partition function dominates every individual score. The proof is immediate. Because exponentials are positive, the full sum $Z$ is at least as large as any single term $\exp(\langle q, k_j\rangle)$; taking logarithms (which preserve order) gives the claim. Formally this is `logPartition_ge_term`.

This inequality is the quiet workhorse behind softmax's focusing power. Whenever one score $\langle q, k_{j^\star}\rangle$ towers over the others, the term $\exp(\langle q, k_{j^\star}\rangle)$ dominates the partition function, the corresponding weight $w_{j^\star}$ approaches $1$, and all the other weights are crushed toward $0$. The output then nearly equals $v_{j^\star}$ alone — attention has "focused." When the scores are all comparable, $Z$ spreads its mass evenly and the output is a broad average. The log-sum-exp inequality is the hinge between these two regimes, and it is also the numerical trick (the "max-subtraction" stabilization) that every practical softmax implementation uses to avoid overflow.

## The attention sink, foreshadowed

The log-partition view also illuminates one of the strangest empirical discoveries about large language models: the **attention sink**. In practice, models lavish a stubbornly large fraction of their attention on a few special tokens — often the very first token in the sequence — even when those tokens carry no obvious meaning. Why?

The arithmetic of the partition function tells the tale. Suppose one token has a logit advantage of $g$ over each of its $n-1$ competitors. Then the partition function factors as $Z = e^{z}\big(1 + (n-1)e^{-g}\big)$, and the favored token's weight is $1/\big(1+(n-1)e^{-g}\big)$. For this token to keep a non-vanishing share of attention as the context grows to length $n$, its advantage must scale like $g \approx \log n$. A token that earns even a logarithmically growing edge becomes a permanent *sink* that soaks up attention no matter how long the conversation gets. The confinement and log-partition laws we have proved are exactly the tools needed to make this phase-transition story rigorous, and pinning down its sharp threshold is one of the open frontiers this work opens up.

## The bigger picture: bounded, but boundlessly expressive

It would be a mistake to read the confinement law as a *limitation*. Quite the opposite. The set of points an attention head can reach — the open interior of the convex hull of its values — is enormous. By choosing keys and queries appropriately, the softmax weights can be steered to *any* interior point of the probability simplex, which means the output can be placed *anywhere* inside the convex hull, arbitrarily close to any target. This is the seed of a **universal approximation** theorem: stack enough of these flexible, bounded averagers, give them enough values to mix, and they can approximate astonishingly rich sequence-to-sequence functions to any desired accuracy.

So the picture that emerges is one of *disciplined expressiveness*. Attention is bounded — it stays inside the hull, it never invents magnitudes, it averages rather than extrapolates. And yet, within those boundaries, it is extraordinarily expressive, able to focus sharply or blend broadly, to interpolate anywhere it likes. The genius of the transformer is to compose millions of these gentle, well-behaved averagers into a system that can write poetry, prove theorems, and hold a conversation.

The next time someone tells you a language model "decided to focus" on a word, you can smile and translate: it took a weighted average, with positive weights that summed to one, and the answer — guaranteed, provably, with no exceptions — landed somewhere inside the range of what it had already seen. The tyranny of attention is real, but it is a gentle one. It keeps the machine honest, and in that honesty lies its power.
