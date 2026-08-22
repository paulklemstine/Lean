# The Curvature of a Model Zoo

## What does it cost to be ready for anything?

Every compression scheme is a bet. A ZIP file is a bet that your data looks like English text or program source; a JPEG is a bet that your data is a photograph; an audio codec is a bet about the statistics of human speech. When the bet is right, the file shrinks. When the bet is wrong, the file can grow.

Suppose you refuse to bet. You want a single encoder that performs well no matter which of several plausible statistical models generated the data — the *universal* encoder. Information theory tells you exactly what such caution costs, and the answer is beautifully concrete.

Fix a finite alphabet of possible messages $X$, and a finite collection $A$ of candidate probabilistic models, each a probability distribution $P_i$ over $X$. Form the pointwise upper envelope

$$\hat P_A(x) \;=\; \max_{i \in A} P_i(x),$$

the best explanation any model in your collection can offer for the message $x$. Summing it gives the **Shtarkov sum**

$$C(A) \;=\; \sum_{x \in X} \hat P_A(x) \;\ge\; 1 .$$

The logarithm $\log_2 C(A)$ is the *worst-case regret* of the best universal code for the family $A$: the number of extra bits, in the worst case, that you pay relative to a clairvoyant who knew in advance which model was correct. We call $C(A)$ the **price of universality** of the library $A$. A library of one model has price exactly $1$ — no regret, no bet lost. A library of many wildly different models has a large price, because for many messages some model in the library is a much better explanation than the others, and the envelope towers above each individual distribution.

So here is the engineer's dilemma, and it is a completely practical one. You are shipping a compressor, a codebook, or a set of pretrained predictive models on a device. You can afford $k$ models out of a pool $\Omega$ of hundreds of candidates. Which $k$?

## Greedy, and why it is almost always good enough

Choosing the best $k$ out of hundreds is a combinatorial optimization problem, and in general a hard one. Fortunately, the price of universality has a structural property that rescues us: it is **submodular**. Adding a new model to a small library helps at least as much as adding it to a bigger library. In symbols, if $A \subseteq B$ and $j$ is a new model,

$$C(A \cup \{j\}) - C(A) \;\ge\; C(B \cup \{j\}) - C(B) .$$

Diminishing returns, in the purest form. It is also monotone ($C$ can only grow when you add models) and normalized ($C(\emptyset) = 0$ by convention).

For any monotone submodular function, a classical and famous theorem says that the greedy algorithm — repeatedly add whichever remaining candidate increases the value most — produces after $k$ steps a library worth at least a fraction

$$1 - \left(1 - \tfrac{1}{k}\right)^{k} \;\ge\; 1 - \tfrac{1}{e} \;\approx\; 63.2\%$$

of the best possible library of size $k$. That is a strong guarantee and it needs no assumptions at all. But it is also a *worst-case* guarantee, and worst cases are pathological. In practice, greedy library design almost always does far better than $63\%$. Why? And can we say when?

## Curvature: how far a function is from being additive

Here is the key idea, and it is the heart of this work.

The $1 - 1/e$ bound is tight only for functions that are maximally "curved": functions where a model, thrown into a large library, can become completely worthless even though on its own it was valuable. At the opposite extreme are **modular** functions, where value is simply additive: each model contributes the same amount no matter what else is in the library. For modular functions greedy is not approximately optimal — it is *exactly* optimal, because picking the $k$ largest items is obviously best.

The number that interpolates between these two worlds is the **curvature** of the candidate pool. Given the whole pool $\Omega$, define for each model $j \in \Omega$ its *marginal ratio*

$$r_j \;=\; \frac{C(\Omega) - C(\Omega \setminus \{j\})}{C(\{j\})},$$

the fraction of $j$'s solo value that survives when $j$ is competing against *every* other model in the pool. Since $C$ is submodular and monotone, $r_j$ always lies in $[0,1]$. Then the curvature is

$$\kappa \;=\; 1 - \min_{j \in \Omega} r_j \;\in\; [0,1].$$

Curvature $\kappa = 0$ means every model retains its full solo worth even in the crowd — the function is additive on the pool. Curvature $\kappa = 1$ means some model becomes completely redundant in the crowd — its marginal value collapses to zero.

Two easy facts make this parameter feel real. First, **curvature only grows as you widen the pool**: throwing more candidates into the shortlist can only make the guarantee worse, never better, because the minimum is over more terms and each ratio itself shrinks. Second, and more colourfully: **duplicates are fatal**. If your pool of pretrained models contains two identical copies of the same model, then deleting one of them costs nothing at all, the corresponding marginal ratio is $0$, and $\kappa = 1$ exactly. Curvature is, quite literally, a redundancy detector.

There is an even more striking version of that observation. Suppose your pool has more models than there are possible messages, $|\Omega| > |X|$. Then, by pigeonhole, some model in the pool is never the best explanation of *any* message: it never touches the envelope, so deleting it changes nothing, and $\kappa = 1$. **Curvature is only an informative parameter for pools smaller than the message space.** A pool with low curvature must be, in a precise sense, a *code*: a set of well-separated points in the space of distributions.

## What the curvature buys you

The definition of curvature can be turned into a usable inequality. For *any* sub-library $S$ of the pool and any model $j \in \Omega$ not already in $S$,

$$C(S \cup \{j\}) - C(S) \;\ge\; (1-\kappa)\, C(\{j\}) .$$

Adding a model is always worth at least a $(1-\kappa)$ share of its solo price, no matter what is already in the library. Summing this over disjoint families gives a *superadditivity* companion to submodularity: for sub-libraries $A, B$ of the pool,

$$C(A \cup B) \;\ge\; C(B) + (1-\kappa)\bigl(C(A) - C(A \cap B)\bigr).$$

At $\kappa = 1$ this says nothing but "$C$ is monotone". At $\kappa = 0$ it is the exact reverse of submodularity, and the two together pin $C$ down: on a zero-curvature pool the price of universality is *exactly modular*,

$$C(A \cup B) + C(A \cap B) = C(A) + C(B).$$

Feed the curvature inequality into the greedy analysis and the classical argument sharpens in a very intuitive way. In the curvature-free analysis, after $k$ greedy steps the remaining gap to the optimum of size $n$ is bounded by "$n$ greedy gains". With curvature, it becomes

$$\underbrace{C(B) - C(A_k)}_{\text{gap after } k \text{ steps}} \;\le\; \bigl(n - (1-\kappa)k\bigr)\cdot \rho_k ,$$

where $\rho_k$ is the value gained on the $k$-th greedy step and $B$ is any target library of size $n$. Every model already chosen shortens the remaining horizon by $(1-\kappa)$ — the models you already own keep working for you, and only curvature erodes their contribution. Unrolling this recursion gives the guarantee

$$C(B) - C(A_k) \;\le\; \left(\prod_{i=0}^{k-1}\Bigl(1 - \frac{1}{n - (1-\kappa)i}\Bigr)\right) C(B).$$

Now look at the endpoints.

**At $\kappa = 0$ the last factor is exactly zero** (when $i = n-1$ the denominator is $n - (n-1) = 1$), so the gap vanishes: *greedy library design on a zero-curvature pool is exactly optimal*. No approximation, no constant factor.

**At $\kappa = 1$** every denominator is $n$ and the product is $(1 - 1/n)^n \le e^{-1}$: we recover the classical $1 - 1/e$ guarantee, which therefore holds for *every* pool, curved or not.

**In between**, the product is always at most $(1-1/n)^k$, and one gets a clean quantitative low-curvature statement: for a target library of size $n$,

$$C(B) - C(A_n) \;\le\; \kappa\,(n-1)\, C(B).$$

Read this as the punchline. If you shortlist ten models and your pool has curvature $1\%$, greedy design lands within $9\%$ of optimal — far better than the $37\%$ slack that the general theory allows. This is the honest, provable version of "greedy works much better in practice than the worst case suggests": *practice has low curvature*.

The classical conjecture in this area, going back to work on curvature-aware submodular optimization, predicts the sharper factor $(1 - e^{-\kappa})/\kappa$. Half of it is delivered here: the numerator $1 - e^{-\kappa}$ is achieved, i.e. greedy always recovers at least a $(1 - e^{-\kappa})$-fraction of the optimum. The $1/\kappa$ amplification, however, does not follow from any step-by-step recursion of this kind, and it remains open. It is instructive to see how close the proved bound comes: for $\kappa = 0.1$ and $n = 3$, the guarantee proved here is $0.9418$, against a conjectured $0.9516$. Nearly, but not quite.

## The twist: nearly identical is *worse*, not better

Now for the part of the story that turned out backwards, and which is the most instructive lesson of the whole investigation.

Intuition says: a pool of nearly identical models should be easy. There is barely anything to choose between them, so surely any choice — including greedy's — is nearly optimal. Formalize "nearly identical" by total variation distance, $\delta_{TV}(p,q) = \tfrac12\sum_x |p(x) - q(x)|$, and conjecture that if all models in the pool are pairwise within $\delta$, then $\kappa \le \delta \cdot |\Omega|$: nearly identical pools are nearly flat, so greedy is nearly optimal.

This is **false**, and spectacularly so. Take a pool consisting of two identical fair coins. Their total variation distance is $\delta = 0$, so the conjecture predicts $\kappa \le 0$. But two identical models are duplicates, and duplicates force curvature exactly $1$. The conjecture fails at the most extreme possible margin: $1 > 0$.

And the failure is not an accident of an edge case; the truth runs precisely the other way. If the models of the pool are pairwise within total variation $\delta$, then

$$\kappa \;\ge\; 1 - (|\Omega| - 1)\,\delta .$$

**Statistical similarity forces *high* curvature.** The reason, once seen, is obvious: curvature measures redundancy, and similar models are redundant. A model that is nearly a copy of its neighbours adds almost nothing on top of them, its marginal ratio is nearly zero, and $\kappa$ is nearly $1$.

The inequality is sharp. For a pool of exactly two sources $\{a,b\}$, the curvature is *exactly*

$$\kappa = 1 - \delta_{TV}(P_a, P_b).$$

This is a small formula with a lot of content. It says that for pairs, curvature and statistical distance are the same quantity read from opposite ends, and it makes the whole curvature scale concrete: for any target value $\kappa_0 \in [0,1]$, take two coins with biases $\tfrac{1 \pm (1-\kappa_0)}{2}$, one favouring "heads" and the other "tails". Their total variation distance is $1 - \kappa_0$, and their pool has curvature exactly $\kappa_0$. Every point of the curvature scale is realized by a genuine, explicit pool of two biased coins, so none of the curvature-indexed guarantees above is vacuous.

So the correct slogan is not "nearly identical pools are easy" but its opposite:

> **Diverse pools are the easy ones. Redundant pools are the hard ones.**

That inversion has real design consequences. If you are assembling a shortlist of predictive models to hand to a greedy selector — a compression codebook, a model zoo for on-device inference, a set of statistical priors for a coding scheme — the way to make greedy provably near-optimal is to *deduplicate aggressively and spread your candidates out in distribution space*. Adding another near-copy "just in case" does not merely waste a slot; it pushes the curvature of the entire pool toward $1$ and destroys the guarantee for every selection made from it.

## Where this leaves us

The picture we now have is coherent. A single number $\kappa$, computable from the pool by $|\Omega|$ evaluations of the price functional, interpolates the entire spectrum from "greedy is exactly optimal" ($\kappa = 0$) to "greedy is $63\%$ optimal" ($\kappa = 1$), with an explicit decreasing family of guarantees in between. Curvature grows with the pool, saturates at $1$ whenever the pool contains duplicates or overflows the message alphabet, and is pinned to $1 - \delta_{TV}$ for pairs.

Two frontiers stand out. The first is the exact factor $(1 - e^{-\kappa})/\kappa$: numerical experiments are entirely consistent with it, but it cannot be reached by any single-step recursion, because it is really the value of a linear program in the whole vector of greedy gains $(\rho_0, \ldots, \rho_{n-1})$, constrained simultaneously by monotonicity of the gains, the covering inequalities at each step, and the curvature inequality applied at every already-chosen model. What is missing is a duality certificate for that program.

The second is the curvature–capacity trade-off hiding in the pigeonhole saturation. A pool can have $\kappa < 1$ only if $|\Omega| \le |X|$; so the useful regime of curvature-aware library design is exactly the regime where the pool is a code in the message alphabet. How low a curvature is achievable for a pool of $m$ models over an alphabet of size $N$? The two-source formula $\kappa = 1 - \delta_{TV}$ is the $m = 2$ answer. The general answer would be a genuine packing theorem in the simplex: a statement about how far apart $m$ distributions over $N$ symbols can be pushed, measured in exactly the currency that greedy library design cares about.

The moral, meanwhile, is one an engineer can act on tomorrow: *the price of universality rewards diversity, and greedy design rewards it twice over.*
