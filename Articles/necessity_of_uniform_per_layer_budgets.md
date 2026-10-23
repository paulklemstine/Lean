# The Budget That Lies: Why Shrinking a Neural Network Demands Worst-Case Thinking

*Many small measured errors can add up to a guarantee, but only under one condition. We now know exactly what that condition is, and why no shortcut can replace it.*

---

## A tempting piece of accounting

Imagine you run a large AI model in production. It is expensive, so your engineers make it cheaper. They prune weights from layer 3, round the numbers in layer 7 to fewer bits, and drop a few attention heads in layer 12. Each change is small and local. To check that nothing broke, they feed a batch of held-out examples through each modified layer and record how much that layer's output moved. Layer 3 moved by $0.2\%$, layer 7 by $0.1\%$, layer 12 by $0.3\%$. They add the numbers and report: *the compressed model differs from the original by at most $0.6\%$.*

This accounting feels reasonable, because errors usually add up. If you walk ten steps and each step is off by at most a centimetre, you end up at most ten centimetres from where you meant to be. So the sum of per-layer errors should bound the total error.

It does, but only for a specific kind of per-layer error. The new results described here show that this kind of error is the *only* one for which the accounting works. Any number measured more cheaply can be fooled, and fooled completely.

## Layers as little machines that shuffle probability

The setting is easiest to picture with a simple model of a network. Suppose the network's internal state at any moment is one of $k$ possibilities, say $k$ "moods" it can be in. Each layer is a small random machine: given the current mood $a$, it outputs a new mood at random, following a probability table $f(a)$. Mathematicians call such a machine a *channel*. A network is a *stack* of channels applied one after another.

If you are unsure what mood the network is in, you describe your uncertainty by a probability distribution $\mu$ over the $k$ moods, called a *law*. Passing $\mu$ through a layer gives a new law, and passing it through the whole stack gives the output law.

To measure how different two outputs are, we use the *total variation distance*: half the sum of the absolute differences of the probabilities. It is $0$ when the outputs are identical and $1$ when they share no outcomes at all. It also has a practical meaning. It is the largest possible difference, over all yes/no questions, between the probabilities the two models assign to "yes".

Now compare an *intact* stack of layers $f_1, f_2, \dots, f_n$ with a *pruned* stack $p_1, p_2, \dots, p_n$. The *joint damage* from an input law $\mu$ is the distance between the two output laws.

## The fine print in the classical argument

There is a well-known argument, the *hybrid argument*, for bounding the joint damage layer by layer. Swap the intact layers for pruned ones one at a time, starting at the bottom. Each swap changes the output by at most the damage that layer does locally, and the total change is at most the sum.

The weak point is *where* each layer's local damage gets measured. When you swap layer $j$, the layers below it have already been swapped for pruned ones. So layer $j$ receives a law that the *pruned* network produces, a law nobody ever fed to it in testing. To be safe, the bound on layer $j$ has to hold *for whatever input reaches it*. In other words, it must be a worst case over all possible upstream states:

$$U(f, p) = \max_{a} \operatorname{tv}\big(f(a),\, p(a)\big).$$

This is the *uniform budget*: the most that the pruned layer $p$ can differ from the intact layer $f$, over every mood $a$ the layer might receive. With uniform budgets the accounting works. A stack of $n$ layers, each at most $\varepsilon$ apart in the worst case, can never do more than $n\varepsilon$ damage. This is the depth-additive bound.

Is the worst case really necessary, though? It is expensive to certify. Measuring at a few representative inputs would be much cheaper.

## Result 1: Sound means worst-case, exactly

Call any rule that assigns a number $B(f,p)$ to each (intact, pruned) layer pair a *budget functional*. The rule can be anything: a formula, a measurement, a neural network's opinion. Call it *sound* if, for every pair of stacks of equal depth and every input law, the joint damage never exceeds the sum of the per-layer budgets.

**Theorem (soundness is uniform domination).** *A budget functional is sound if and only if, for every layer pair, it is at least as large as the worst-case perturbation: $B(f,p) \ge \max_a \operatorname{tv}(f(a), p(a))$. In particular, the uniform budget is the smallest sound budget.*

The proof of the "only if" direction takes one line. Take a network with a single layer and feed it an input that is certainly in mood $a$. The joint damage is then exactly $\operatorname{tv}(f(a), p(a))$, and the total budget is just $B(f,p)$. So soundness forces $B(f,p) \ge \operatorname{tv}(f(a),p(a))$ for every mood $a$, which is the worst case.

The "if" direction is the hybrid argument with one more observation. If a layer's perturbation is at most $\varepsilon$ at every individual mood, then it is at most $\varepsilon$ at every *blend* of moods, because a blend is an average and averages cannot exceed their largest term.

So "certify worst-case per-layer behaviour" is not one sensible policy among several. It is exactly what soundness means.

## Result 2: Probing works only if the probes span

There is a loophole, though. The worst case is over $k$ moods, which is finitely many. Perhaps measuring a layer at a few cleverly chosen inputs, a *probe set*, is enough to pin down its worst case?

For this to be a fair question, the budget must actually react to change. A rule that always charges $1$ is trivially sound, since the distance never exceeds $1$, but it tells you nothing. So we require the budget to be *calibrated*: an unchanged layer is charged $0$. We also require it to be *probe-local*: two layer pairs that respond identically at all the probes are charged the same.

The answer turns on a classical idea from linear algebra, the *span* of the probes. Think of each probe law as a vector of $k$ numbers. The probes *span* if every vector of $k$ numbers can be written as a combination of them, with coefficients allowed to be negative.

**Theorem (probe-budget dichotomy).** *A sound, calibrated, probe-local budget exists if and only if the probe vectors span (or there is only one mood). In particular, at least $k$ probes are needed, and the $k$ "pure-mood" inputs suffice.*

Why should linear algebra decide this? Because a channel acts *linearly* on laws: the output for a blend of inputs is the same blend of the outputs. If the probes span, every pure mood is a combination of probes, so the probe responses determine the layer completely. If they do not span, there is a direction in the space of laws that the probes cannot see. Two layers can then differ only along that direction and look identical at every probe.

The heart of the work is a construction that exploits this blind direction as hard as possible. Call it **witness interpolation**. Pick a set of weights $w_a$, one per mood, that averages to zero against every probe. Such weights exist exactly when the probes do not span. Rescale them so that the largest has size $1$, and call the result $u_a$. Now pick two distinct moods $x$ and $y$ and build two layers:

- layer $g$, on mood $a$, outputs $x$ with probability $\tfrac{1+u_a}{2}$ and $y$ otherwise;
- layer $q$, on mood $a$, outputs $x$ with probability $\tfrac{1-u_a}{2}$ and $y$ otherwise.

Feed either layer any probe and the output is a fair coin between $x$ and $y$, because the $u_a$ average to zero against every probe. The two layers are indistinguishable at the probes. But at the mood $a_0$ where $|u_{a_0}| = 1$, one layer outputs $x$ with certainty and the other outputs $y$ with certainty. Their outputs are at distance $1$, the maximum possible.

Put $g$ (respectively $q$) at the bottom of a stack, pad with any number of do-nothing layers, and you get a pair of networks of *any depth* whose total budget is exactly $0$ while their outputs from a pure input are completely different. No fudge factor rescues the budget either: no inequality of the form "damage $\le C \times$ budget $+\ \delta$" with $\delta < 1$ can hold, whatever the multiplier $C$.

A concrete case: with two moods, a single balanced probe (a fair coin) cannot tell the identity layer from a layer that *swaps* the two moods. A fair coin, swapped, is still a fair coin. Yet on a pure input the two layers disagree completely.

## Result 3: Your held-out window cannot certify more than it spans

The same reasoning covers the most common practice in machine learning: check that the compressed model agrees with the original on a held-out window of inputs, and conclude that it agrees everywhere.

**Theorem (window dichotomy).** *Exact agreement of two stacks on every input of a window guarantees agreement on all inputs if and only if the window spans. A window with fewer inputs than there are states never certifies anything: some pair of stacks agrees perfectly on the window and differs maximally somewhere else.*

In real networks the number of internal states is astronomically large, while any held-out set, however generous, explores only a sliver of it. The theorem says that a sliver can never be enough.

## Result 4: The masking suffix

A careful engineer might reply: "I don't measure layers in isolation. I ablate them *in context*. I swap one layer for its pruned version, run the whole network, and see whether the output changes. And I do this at as many inputs as I like."

The answer is a construction called the **masking suffix**, and it shows that even this can be fooled at *every* input. Take any intact stack $F$, any pruned stack $P$, and any law $d$. Wrap them as follows.

- Put a **collapsing prefix** at the bottom of both: a layer that ignores its input and outputs $d$.
- Put a **forgetful suffix** at the top of the intact stack: a layer that ignores its input and outputs the intact answer $F(d)$.
- Put a **transparent suffix** (the identity) at the top of the pruned stack.

**Theorem (masking suffix).** *The wrapped pair has exactly the same joint damage as the original pair at $d$, namely $\operatorname{tv}(F(d), P(d))$, from every input. Yet swapping any single layer of the wrapped intact stack for its pruned counterpart leaves the output completely unchanged, from every input.*

The reason is simple. Swapping the prefix changes nothing, because both stacks share it. Swapping a middle layer changes nothing, because the forgetful suffix overwrites whatever arrives. Swapping the suffix for the identity also changes nothing, because what arrives at the top is already $F(d)$. Every solo experiment comes back clean, but swapping everything at once does the full damage.

So, for any two laws, there are networks of every depth from three upward whose damage is as large as you like, up to total disagreement, at every input, while every one-at-a-time ablation reports zero. Any rule that turns solo ablation data into a damage estimate, and that reports zero when every ablation reports zero, can be fooled into certifying a network that is completely broken. Every pruning instance, however damaging, can be hidden from solo probing at the cost of two extra layers.

## What *does* work

The results are not only negative. They also show exactly what can be salvaged from finite measurements.

**Measure along the input's own path.** For a fixed input, run the intact network. At each layer, also apply the pruned layer to the *intact* layer's input and record how far apart the two outputs are. Add up these numbers. This *trajectory cost* is a genuine upper bound on the joint damage *for that input*. The failure in the counterexamples came from reusing these measurements for *other* inputs.

**Extrapolate through combinations, and pay the price.** If a new input $\mu$ can be written as a combination $\mu = \sum_i c_i w_i$ of measured window inputs (negative coefficients allowed), then

$$\text{damage at } \mu \;\le\; \sum_i |c_i| \cdot \big(\text{trajectory cost at } w_i\big).$$

The factor $\sum_i |c_i|$ is the **amplification** of the extrapolation. With two moods and window inputs that put probability $\tfrac14$ and $\tfrac34$ on mood $1$, the pure mood $0$ equals $\tfrac32$ times the first minus $\tfrac12$ times the second, so the amplification is $2$. If the window inputs are pushed closer to the fair coin, the amplification blows up like $1/(1-2\eta)$, where $\eta$ is how close each input comes to the centre.

**Design budgets.** Combining these ideas gives an explicit sound budget built only from probe measurements. Choose probes that span, write each pure mood as $\delta_a = \sum_i c_{a,i} s_i$, and charge each layer pair

$$\sum_a \sum_i |c_{a,i}| \cdot \operatorname{tv}(\text{layer outputs at probe } s_i).$$

This *design budget* is probe-local, calibrated, and provably sound. Choosing *which* probes to use becomes a concrete engineering question: find spanning probes whose expressing coefficients are as small as possible.

## Why it matters

These results have a direct consequence for anyone who compresses, quantises, or edits deployed models. **A sum of per-layer errors is a guarantee only when each term is a worst case.** Held-out measurements are useful estimates, but they are not bounds. They become bounds only through a spanning design, and only after paying that design's amplification factor. Ablation studies that change one component at a time can miss interactions entirely.

The results also open a research programme. Real inputs are never pure states. They are blends that sit strictly inside the space of possibilities. What is the smallest amplification achievable when every probe gives each state probability at least $\eta$? The conjectured answer is $(1+(k-2)\eta)/(1-k\eta)$, achieved by shrinking the pure states uniformly toward the centre. For two states this is exactly the $1/(1-2\eta)$ seen above. What happens when the state space is infinite, as it is for real activations? Then no finite set of probes can span, and it is conjectured that no finite probe set can ever support a sound, calibrated budget.

The opening question was whether small local errors add up to a small total error. They do, provided each local error is measured against the worst case.
