# The Blind Spot of Attention — and Exactly How Big It Is

## A machine that cannot count to two

Here is a puzzle that sounds too easy to be interesting.

You are given a machine that reads a sequence of two numbers, $(x_1, x_2)$, and you want it to report the *first* one. Not the largest, not the sum, not the average — the first. The machine is built out of attention: it looks at every token in the sequence, decides how much each one matters, and mixes them together. It has unlimited width, unlimited depth, unlimited training data.

The one thing it does not have is a sense of place. Every token looks the same to it except for its contents; the machine is *permutation-invariant*, which means that if you hand it $(x_2, x_1)$ instead of $(x_1, x_2)$, it produces exactly the same answer.

That machine will never learn to report the first number. Worse — and this is the sharp part — it will never even get *close*. There is a precise floor on how badly it must fail:

> **The position-reading barrier.** Let $p$ be any function of sequences that is unchanged when a symmetry $\sigma$ shuffles the tokens, and suppose $\sigma$ actually moves position $i_0$. Then there is an input sequence $x$ on which $$\left| p(x) - x_{i_0} \right| \ \geq \ \tfrac{1}{2}.$$

The proof takes one line and a single test input. Let $u$ be the sequence that is $1$ at position $i_0$ and $0$ everywhere else. Then $u$ has a $1$ in the target slot, while the shuffled sequence $\sigma \cdot u$ has a $0$ there. The model, being blind to the shuffle, returns the *same number* $p(u)$ on both. One number cannot be within $\tfrac{1}{2}$ of both $0$ and $1$. Whichever way $p(u)$ leans, one of the two inputs catches it out.

That is the negative half of the story. The astonishing thing is that the same circle of ideas produces the *positive* half — a complete, exact description of everything such a machine **can** do, and an explicit repair that gives it back everything it cannot. This article is about that dichotomy.

## Attention, stripped to its skeleton

Modern sequence models — the ones behind machine translation, protein folding, and the language models that write code — are built on an operation called *attention*. Strip away the engineering and here is what one attention head does.

A sequence is a table $x$ of real numbers: $n$ tokens, each carrying $d$ features, so $x_{i,a}$ is feature $a$ of token $i$. A head assigns each token $j$ a score $s_j$, converts scores to weights by the softmax rule
$$\alpha_j = \frac{e^{s_j}}{\sum_k e^{s_k}},$$
and then reports the weighted average of a linear summary of each token:
$$\text{head}(x) = \sum_j \alpha_j \sum_a w_{j,a}\, x_{j,a}.$$

The softmax weights are the "attention": they decide who gets listened to. When all the scores are equal — say all zero — the softmax degenerates to uniform weights $\alpha_j = 1/n$, and the head becomes something completely transparent:
$$\text{head}(x) = \sum_j \sum_a \frac{w_{j,a}}{n} x_{j,a},$$
a plain linear functional of the table. We call such a thing a **readout**. So readouts are not a toy substitute for attention; they *are* attention heads, in the uniform-score regime.

Real transformers do more than average: they multiply, gate, and compose across layers. The mathematically clean way to capture "readouts plus everything you can build from them by adding and multiplying" is to take the **attention algebra**: the smallest collection of continuous functions of the sequence that contains every readout, contains the constants, and is closed under addition and multiplication. Products of readouts are exactly what multiplicative gating and residual composition generate, so this algebra is a faithful, architecture-agnostic stand-in for "what a deep attention stack can express".

## The one thing an algebra needs

There is a hundred-year-old theorem that says a subalgebra of continuous functions on a compact set is either dense — able to approximate everything, to any accuracy you name — or blocked by an obvious obstruction: it fails to tell two points apart. This is the Stone–Weierstrass theorem, and it converts an approximation question into a *separation* question.

Do readouts separate sequences? Yes, trivially. If tables $x$ and $y$ differ, they differ in some entry $x_{i_0,a_0} \neq y_{i_0,a_0}$; take the readout whose weight table is $1$ in that slot and $0$ elsewhere, and it returns precisely $x_{i_0,a_0}$ on one input and $y_{i_0,a_0}$ on the other. Different values. Separation done.

So on any compact set of sequences, the attention algebra approximates *every* continuous functional. That is a universality theorem, and it is the answer people usually quote when they ask whether transformers are expressive enough.

But it is the answer to the wrong question — because a transformer without positional information is not a free element of that algebra. It is constrained to the symmetric part of it. And that changes everything.

## What symmetry costs, measured exactly

Let $\Gamma$ be any finite group of token symmetries: a group acting on the positions $\{1,\dots,n\}$ by permutations. Two cases matter in practice.

- $\Gamma$ = **all** permutations. This is a bag-of-tokens model, a transformer with no positional encoding at all.
- $\Gamma$ = the **cyclic shifts**, generated by one rotation $r$ of the positions. This is the symmetry of relative positional encoding: the model knows *how far apart* tokens are, but not where they sit in absolute terms.

Call a functional $f$ *$\Gamma$-invariant* if $f(g \cdot x) = f(x)$ for every symmetry $g$, and call a set of sequences *$\Gamma$-saturated* if applying a symmetry to a member keeps you inside the set. Then:

> **Symmetric Universality Theorem.** Let $K$ be a compact, $\Gamma$-saturated set of sequences and let $g$ be a continuous $\Gamma$-invariant functional. For every $\varepsilon > 0$ there is a $\Gamma$-invariant element $p$ of the attention algebra with $|p(x) - g(x)| < \varepsilon$ for all $x \in K$.

The proof is a two-step trick that deserves to be better known. First, forget symmetry entirely and use Stone–Weierstrass to find *some* attention model $q$ with $|q - g| < \varepsilon$ on $K$. That $q$ has no reason to be symmetric. Second, average it over the group:
$$p(x) = \frac{1}{|\Gamma|} \sum_{g \in \Gamma} q(g \cdot x).$$
Averaging manifestly produces an invariant function. Two facts make it work. (i) The attention algebra is *stable* under the token action: permuting the input of a readout just permutes its weight table, so it is again a readout, and stability propagates to everything built from readouts. Hence $p$ is still an attention model. (ii) The averaging cannot hurt the error: since $g$ itself is invariant and $K$ is saturated, every term $q(g\cdot x)$ is within $\varepsilon$ of the *same* number $g(x)$, so their average is too. Symmetrizing is free.

Specializing to the full symmetric group gives universality for positional-encoding-free transformers over invariant targets; specializing to the cyclic group $\{r^k\}$ gives it for shift-invariant targets and relative encodings.

Now the converse. The invariant class is *uniformly closed*: if a target $g$ can be approximated to arbitrary accuracy by $\sigma$-invariant models on a $\sigma$-stable set, then $g$ was invariant all along. Why? Because of a defect inequality that costs three lines:
$$|g(x) - g(\sigma \cdot x)| \ \leq \ |p(x)-g(x)| \ + \ |p(\sigma \cdot x) - g(\sigma \cdot x)|,$$
valid whenever $p(\sigma \cdot x) = p(x)$. The left side does not depend on the model; the right side is at most twice the model's uniform error. Drive the error below a quarter of the defect and you get a contradiction unless the defect is zero.

So the reach of symmetric attention is exactly the invariant continuous functionals: dense inside, unreachable outside. And *outside*, the failure is quantitatively sharp.

> **Orbit Barrier Theorem.** Fix a target $g$ and a sequence $x$, and let
> $$\mathrm{osc}(g,x) \;=\; \max_{\sigma} g(\sigma \cdot x) \;-\; \min_{\sigma} g(\sigma \cdot x)$$
> be the oscillation of $g$ over the orbit of $x$. Then every permutation-invariant model $p$ satisfies
> $$\max_{\sigma} \left| p(\sigma \cdot x) - g(\sigma \cdot x) \right| \ \geq \ \frac{\mathrm{osc}(g,x)}{2},$$
> and this is achieved: the constant model equal to the orbit midpoint $\tfrac{1}{2}(\max + \min)$ attains exactly $\mathrm{osc}(g,x)/2$.

Half the oscillation — no more, no less. An invariant model must give a single answer on a whole orbit; the best single answer to a spread of values is their midpoint, and the midpoint is off by half the spread. The theorem says this naive bound is not merely necessary but optimal. The position-reading barrier we opened with is the special case where the target is "read coordinate $i_0$" and the orbit contains a $1$ and a $0$, so $\mathrm{osc} = 1$ and the floor is $\tfrac12$.

## The repair: geography as a feature

Practitioners solved this problem years ago, by feel: they *add positional encodings*, extra coordinates that tell each token where it lives. The dichotomy above lets us say exactly why this works, and it says something slightly surprising — the fix does not require breaking the symmetry of the model at all.

Take the one-hot positional encoding. Each token $i$ keeps its $d$ features and receives $n$ extra coordinates holding the indicator of its own position: coordinate $j$ of the new block is $1$ if $j = i$ and $0$ otherwise. Write the encoded sequence as $\iota(x)$, now living in feature space of dimension $d + n$.

The magic is that the encoded sequence can be *decoded by an invariant operation*. Define
$$\mathrm{dec}(z)_{i,a} \;=\; \sum_{j} z_{j,\,\mathrm{pos}(i)} \cdot z_{j,\,\mathrm{feat}(a)},$$
which is precisely an attention pattern: query the tag block for position $i$, use it as the attention weight, and read the feature block. Two facts:

- **The decoder inverts the encoder**: $\mathrm{dec}(\iota(x)) = x$, because the tag coordinates form an identity matrix and the sum collapses to the single surviving term.
- **The decoder is permutation-invariant**: it is a sum over tokens, and summing over tokens does not care in which order they arrive.

Put these together with the Symmetric Universality Theorem and you get the repair.

> **Positional Restoration Theorem.** For every continuous functional $g$ of sequences, every compact set $K$, and every $\varepsilon > 0$, there is a *fully permutation-invariant* attention model $p$ on the augmented feature space such that $|p(\iota(x)) - g(x)| < \varepsilon$ for all $x \in K$ — including the order-sensitive targets ruled out by the barrier.

The mechanism is exact: $g \circ \mathrm{dec}$ is a continuous, permutation-invariant functional of encoded sequences, so the symmetric theory approximates it; and on genuinely encoded inputs, $g \circ \mathrm{dec}$ *is* $g$. Applying this coordinatewise upgrades it to full sequence-to-sequence universality: every continuous map from sequences to sequences is approximated, uniformly on compacta and simultaneously in all output positions and features, by a family of permutation-invariant attention models fed positionally-encoded input.

The moral is delicate and worth stating plainly. Positional encoding does **not** work by making the model asymmetric. The model stays perfectly symmetric. What changes is that order information has been moved *into the data*, where a symmetric model is allowed to see it. Symmetry was never the enemy; ignorance was.

## The exact converse: symmetric attention computes exactly the equivariant maps

One question remains. Sequence models usually output sequences, not numbers. What is the honest characterization there?

The relevant notion is *equivariance*: $F$ is $\Gamma$-equivariant when permuting the input permutes the output the same way, $F(g\cdot x)_i = F(x)_{g(i)}$. This is precisely the symmetry a positional-encoding-free transformer layer has.

The bridge is a second encoding, even simpler than the positional one: the **marked-token encoding**. To query position $i$, append one extra feature that is $1$ at token $i$ and $0$ elsewhere; call the result $m_i(x)$. Then:

> **Equivariance–Invariance Representation Theorem.** A sequence-to-sequence map $F$ is continuous and $\Gamma$-equivariant **if and only if** there is a family of continuous $\Gamma$-*invariant* scalar functionals $G_a$ with $F(x)_{i,a} = G_a(m_i(x))$ for all $x$, $i$, $a$.

The construction in one direction is the *marked functional*: given equivariant $F$, set
$$G_a(z) \;=\; \sum_i F(\mathrm{feat}(z))_{i,a} \cdot \mathrm{mark}(z)_i,$$
contracting the output of $F$ against the mark coordinates. Equivariance of $F$ becomes invariance of $G_a$ under a change of summation index, and evaluating on $m_i(x)$ picks out exactly $F(x)_{i,a}$. In the other direction, if $F$ comes from an invariant $G$ then equivariance falls out of the identity $m_i(g \cdot x) = g \cdot m_{g(i)}(x)$.

Equivariance and invariance are the same data, seen through different windows. And once you know that, the universality theorem transfers for free:

> **Equivariant Universality Theorem.** For every finite symmetry group $\Gamma$, every continuous $\Gamma$-equivariant sequence-to-sequence map is uniformly approximated on compacta by $\Gamma$-invariant attention models queried through the marked-token encoding — and the resulting family of heads is itself *exactly* $\Gamma$-equivariant, not merely approximately so.

That last clause matters for applications. The approximation error lives in the values, not in the symmetry: the constructed model satisfies the equivariance identity on the nose, for every input, at every stage of training. A physicist modelling an $n$-body system, or a chemist predicting per-atom properties of a molecule, gets a guarantee that the symmetry of the answer is structural, not statistical.

## Why this is the right picture

Put the pieces side by side.

- Symmetric attention is **dense** in the invariant continuous functionals (positive half).
- Symmetric attention is **confined** to them, and the class is uniformly closed (negative half).
- Outside the class, the minimum achievable error is **exactly half the orbit oscillation** — a formula, not a bound with a mystery constant. Reading an absolute position costs at least $\tfrac12$.
- Adding one-hot positional coordinates removes the confinement **without removing the symmetry**, restoring full universality for functionals and for sequence-to-sequence maps.
- In the sequence-to-sequence setting, the expressive power of symmetric attention is **precisely** the continuous equivariant maps — and the approximants are exactly equivariant.

There is no gap between the two halves. Everything invariant is reachable; nothing else is; and the cost of the unreachable is computed to the last digit.

This is what a mature answer to an architecture question looks like. Deep learning is full of folklore of the form "you need positional encodings" or "attention is permutation-equivariant, so be careful". Folklore is useful, but it does not tell you what you lose or what you get back. Here we can say: you lose exactly the non-invariant functionals; the loss is exactly half an oscillation; and one-hot tags buy back exactly all of it. The whole picture rests on two classical ideas — Stone–Weierstrass and group averaging — meeting a modern architecture halfway.

There is even a design lesson buried in the proof. The averaging step shows that any expressive model can be symmetrized for free: whatever accuracy you had on an invariant target, symmetrizing preserves it. Symmetry, in other words, is never a *statistical* handicap when the truth is symmetric; it is only ever a handicap when the truth is not, and then the handicap is exactly measurable. That is a rare and satisfying thing to be able to say about a neural network.
