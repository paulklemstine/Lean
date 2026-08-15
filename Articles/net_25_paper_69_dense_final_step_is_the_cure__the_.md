# The Last Word Matters Most

### How a single, richer "end-of-input" signal decides whether a machine that has learned to add can keep adding

---

## A machine that can add — until it can't

Teach a small recurrent machine to add two five-digit numbers, least significant digit first, and it learns the task perfectly. Then hand it an eight-digit problem. Nothing about the arithmetic has changed: the same rule that turns a pair of digits and an incoming carry into an output digit and an outgoing carry applies at position eight exactly as it applied at position three. And yet the machine collapses. Full-sequence accuracy at $n = 8$ drops to $0.008$, $0.005$, $0.002$ — barely above the noise floor, and hopelessly far from the $1.0000$ it achieves at $n = 5$.

This is the *length wall*, one of the most stubborn and least understood phenomena in sequence learning. It is the reason a language model that can multiply three-digit numbers falls apart on six-digit ones, and the reason "just train it longer" so often fails to help. The obvious explanations — the machine is too small, its inputs are too impoverished, it has lost track of where it is in the sequence — are all natural, all testable, and, as it turns out, all wrong.

The story below is about a controlled dissection of one instance of this wall, and about a small piece of mathematics that explains what actually happened. The punchline is strange enough to be worth stating up front:

> **The cure was not in the digits. It was in the full stop.**

The single learned vector fed to the machine at the *final* step — the "end of input, now produce your answer" token — turned out to be the entire lever. Widen that one vector from $20$ dimensions to $384$, change *nothing else at all*, and eight-digit accuracy goes from $0.026$ to $1.0000$.

---

## The setup, in plain terms

Fix a base $b$ (here $b = 10$) and two streams of digits $a_0, a_1, a_2, \dots$ and $b_0, b_1, b_2, \dots$, listed least significant first. Addition is the following one-line automaton. Start with carry $c_0 = 0$; at step $i$, emit

$$d_i = (a_i + b_i + c_i) \bmod b, \qquad c_{i+1} = \left\lfloor \frac{a_i + b_i + c_i}{b} \right\rfloor .$$

That's it. The state of this machine is a *single bit*: if every $a_i$ and $b_i$ is a genuine digit, i.e. $a_i, b_i < b$, then $c_i \in \{0, 1\}$ forever, because $a_i + b_i + c_i \le 2b - 1 < 2b$.

Write $\mathrm{val}(f, n) = \sum_{i<n} f_i \, b^i$ for the number represented by the first $n$ digits of a stream $f$. The automaton is exactly correct at *every* depth:

> **Theorem (exact length-generality of the carry transition).** For every base $b$, every pair of digit streams, and every $n \ge 0$,
> $$\mathrm{val}(d, n) + c_n \, b^{\,n} = \mathrm{val}(a, n) + \mathrm{val}(b, n).$$

The proof is a one-line induction: at each step the identity $d_i + b\, c_{i+1} = a_i + b_i + c_i$ (which is just division with remainder) lets you peel off the top digit. There is no hidden dependence on $n$ anywhere.

So far this is grade-school arithmetic dressed in symbols. The interesting part is what it says about *learned* machines.

---

## Learning the rule is a finite problem — and finite is enough

Suppose a machine has learned some step function $T$: given the two current digits and its current carry state, it produces an output digit and a next state. Call the triples $(x, y, c)$ with $x, y < b$ and $c \le 1$ the **reachable** triples. For base $10$ there are exactly $10 \times 10 \times 2 = 200$ of them, and *every one of them* is exercised by training data of depth two or more.

> **Theorem (local-to-global transfer).** If a learned step function agrees with the true transition on all $200$ reachable triples, then, run on any digit streams, it reproduces the true carry at every step and the true output digit at every step — and therefore satisfies the exact sum identity at *every* depth $n$, however large.

Again the proof is an induction, and again it is short: the carry stays inside $\{0,1\}$, so the machine never leaves the finite region where it was verified, and correctness there propagates forever. A companion observation shows the hypothesis is sharp: a step function that is wrong on a *single* reachable triple already emits a wrong digit at the very first step where that triple occurs.

This is the first blow to intuition. **The length wall is not a wall of expressive power.** A correct, exactly length-general step table exists; it is tiny; the training data pins it down completely; and once pinned down, it works at any depth. Whatever is going wrong at $n = 8$ is happening somewhere else.

And indeed the measurements agree. In every failing configuration, a probe of the machine's *final carry bit* — did it correctly decide whether the answer has an extra leading digit? — read between $0.86$ and $0.99$. The transition was fine. The **readout** was broken.

---

## Three suspects, three alibis

The experiment that generated this data was a controlled dissection. A previous round had found a working cure and attributed it to "content-rich learned features" produced by an encoder feeding the recurrent answer path. Three concrete hypotheses were put to the test, each isolating one variable.

**Suspect 1: capacity.** Maybe the failing machine is simply too small; the successful one had $335{,}242$ parameters, the failing one $125{,}214$. *Test:* enlarge the raw machine to $471{,}582$ parameters — more than the cure — with the same raw digit inputs. *Result:* $n=8$ accuracy $0.0078$ and $0.0063$. Capacity is not the lever.

**Suspect 2: learned representation.** Maybe rich, well-separated, *learned* features are what matter. *Test:* replace the learned encoder by a fixed, **untrained**, random $384$-dimensional projection of the very same one-hot digits. *Result:* $1.0000$ and $1.0000$. So learning the features is not the lever either — an untrained random projection cures it.

**Suspect 3: position.** Maybe the machine needs to know *where* it is; the encoder supplies positional information the raw machine lacks. *Test:* append an $8$-dimensional sinusoidal position code to the raw digits, giving $28$-dimensional inputs. *Result:* $0.0049$ and $0.0049$. Position adds nothing.

At this point every candidate had an alibi, and the surviving common feature of the two curing arms was almost embarrassing: they were *wide*. So the decisive control took the width and split it in two — wide *digit* inputs versus a wide *final-step* input.

**The control.** Take the raw one-hot digits and pad them with $364$ zeros, giving a $384$-dimensional input in which $364$ coordinates are permanently dead. The digit pathway carries no more information than before. But the machine's end-of-input token is a *learned dense vector of the full input width*, so in the padded arm that token is $384$-dimensional and the "dead" columns are very much alive for it. Because the random-number generator is drawn in the same order, the recurrent cell and output head in the padded arm and in a variant whose end token is only $20$-dimensional are **byte-identical for the same seed**. The two arms differ by exactly one number: the width of the final-step input.

| arm | end-token width | parameters | $n=8$ full accuracy |
|---|---|---|---|
| padded, dense end token, 4 seeds | $384$ | $335{,}242$ | $1.0000$ (all four) |
| padded, narrow end token, 2 seeds | $20$ | $334{,}878$ | $0.7441$, $0.0259$ |
| raw + position, 2 seeds | $28$ | $129{,}830$ | $0.0049$, $0.0049$ |
| raw baseline, 7 seeds | $20$ | $125{,}214$ | $0.0806 \dots 0.0020$ |
| capacity-matched raw, 2 seeds | $20$ | $471{,}582$ | $0.0078$, $0.0063$ |
| untrained random projection, 2 seeds | $384$ | $335{,}242$ | $1.0000$, $1.0000$ |

Chance level is $10^{-9}$. One architectural variable, moved alone, flips the outcome.

---

## Why width should be irrelevant — and why it isn't

Here is the paradox that the mathematics has to resolve. The end-of-input token is a *single learned vector* $e \in \mathbb{R}^d$. Everything it can ever do to the recurrent cell it does through the input matrix $W$, as the vector

$$v = W e \in \mathbb{R}^h .$$

So ask: what is the set of boundary contributions the machine can represent, as a function of $d$?

> **Theorem (expressivity invariance).** For every $d \ge 1$ and every target $v \in \mathbb{R}^h$ there are $W$ and $e$ with $W e = v$. Consequently, for any two widths $d_1, d_2 \ge 1$, the representable sets of boundary contributions are *the same set*, namely all of $\mathbb{R}^h$.

The proof is embarrassingly easy: let $e$ be the first standard basis vector and let $W$ have $v$ as its first column. A one-dimensional end token can already produce any boundary contribution whatsoever. So widening from $20$ to $384$ adds **no function** to the class. Capacity-style explanations are dead not just empirically but provably — at least along the boundary pathway.

And yet the two arms train to different solutions. If the function class is identical, the difference must live in the *optimisation geometry*: not in what can be represented, but in how fast the training dynamics can move there.

---

## The hidden preconditioner

Suppose the loss depends on the boundary contribution only through $v = We$, and write $g = \nabla_v L \in \mathbb{R}^h$ for its gradient. Gradient descent does not act on $v$; it acts on the *factors*. The chain rule gives

$$\nabla_W L = g\, e^{\mathsf T}, \qquad \nabla_e L = W^{\mathsf T} g,$$

so gradient flow is $\dot W = -g e^{\mathsf T}$, $\dot e = -W^{\mathsf T} g$, and the *induced* velocity of the quantity that actually matters is $\dot v = \dot W e + W \dot e$. Compute it:

> **Theorem (boundary drift).**
> $$\dot v = -\big(\|e\|^2 \, I + W W^{\mathsf T}\big)\, g .$$

The factorised parameterisation silently applies a **preconditioner** — the positive semidefinite matrix $\|e\|^2 I + W W^{\mathsf T}$ — to the descent direction. Taking the inner product with $g$ gives the rate at which the loss is actually being reduced along the boundary pathway:

> **Theorem (boundary gain).**
> $$\langle g, -\dot v\rangle \;=\; \|e\|^2 \|g\|^2 + \|W^{\mathsf T} g\|^2 \;\ge\; \|e\|^2\|g\|^2 ,$$
> and this bound is attained exactly when $W = 0$, so it cannot be improved in general.

Now put in the one thing that the width actually controls. If the end token is initialised with per-coordinate scale at least $c$ — which is what a standard initialiser does, independently of $d$ — then $\|e\|^2 \ge d\,c^2$, and hence

$$\langle g, -\dot v\rangle \;\ge\; d\,c^2\,\|g\|^2 .$$

**The guaranteed learning rate of the boundary pathway is linear in the width of the end token.** Going from $d = 20$ to $d = 384$ multiplies the guaranteed gain by $19.2$ — with byte-identical cell weights, and with no change whatsoever in what the machine can express.

Feeding this into a standard differential-inequality argument closes the loop. Write $\mathcal{L}(v) = \tfrac12\|v - v^\star\|^2$ for the squared distance of the boundary contribution to its target. Then along the factorised flow,

> **Theorem (dense-boundary contraction and budget).** $\mathcal{L}(v(t)) \le \mathcal{L}(v(0))\, e^{-2 d c^2 t}$, and therefore any training time
> $$t \;\ge\; \frac{\log\!\big(\mathcal{L}(v(0))/\varepsilon\big)}{2\,d\,c^{2}}$$
> suffices to bring the boundary loss below $\varepsilon$. The sufficient budget shrinks like $1/d$, strictly, as the width grows.

This is the whole mechanism, in one sentence: **the width of the final-step input is invisible to the function class and visible to the optimiser.**

---

## Why the readout, and not the transition, is the fragile part

One question remains. Why does a slow-to-condition boundary step destroy *deep* problems while leaving shallow ones intact — and why does the carry probe stay near-perfect while the digits come out wrong?

Model the recurrent cell in its linear regime as $x \mapsto Ax + u$ with a contraction factor $\lambda < 1$, meaning $\|Az\| \le \lambda\|z\|$. Two trajectories then approach each other geometrically:

$$\|f^{[n]}(x) - f^{[n]}(y)\| \le \lambda^n \|x - y\| .$$

A readout is a bounded linear functional $r$ with $\|r(z)\| \le R\|z\|$, and to decide anything it needs a margin $\gamma > 0$ between the readouts of states that ought to be distinguished. If the initial states are at most $\Delta$ apart, then as soon as $\lambda^n \Delta R < \gamma$ the readouts are provably within $\gamma$ of each other. Hence:

> **Theorem (the state horizon is real).** For a strictly contractive cell and any bounded linear readout, there is a finite depth $N$ beyond which *every* pair of states within distance $\Delta$ produces readouts closer than $\gamma$. No amount of training and no number of parameters can prevent this; only a less contractive cell, or extra gain at the boundary, can.

That explains the observed shape of the data beautifully. Seven seeds of the raw baseline gave $n=8$ accuracies $0.0806$, $0.6997$, $0.0103$, $0.0063$, $0.0093$, $0.0020$, $0.0132$ — not a hard wall but a *distribution*, because $\lambda$, $\Delta$, $R$, $\gamma$ all vary with the seed and so does the horizon. (An earlier two-seed reading of the same phenomenon had over-claimed a sharp threshold; at seven seeds the honest statement is "zero out of seven reach $1.0$", which is a distributional claim, not a wall.) It also explains why the carry probe survives: a one-bit state needs only a coarse decision, while the ten-way digit readout needs a fine one.

And it puts a firm, slightly deflating ceiling on the cure:

> **Theorem (boundary richness buys depth only logarithmically).** A final-step gain $m \ge 1$ extends the usable depth by $k$ steps whenever $m\lambda^k \le 1$, i.e. for
> $$k \;\ge\; \frac{\log m}{\log (1/\lambda)} .$$

Depth enters the margin exponentially; boundary gain enters it multiplicatively. So richness can only purchase depth through a logarithm. Multiplying the boundary gain by $19$ does not create a qualitatively new regime — it slides the horizon out by a constant number of steps. That constant happened to be enough to clear $n = 8$.

---

## What this predicts, and how it could be wrong

The value of a mechanism is that it sticks its neck out. Three predictions follow immediately, and each is cheap to test.

**A logarithmic depth law.** Since gain buys depth logarithmically, sweeping the end-token width over $d \in \{20, 28, 40, 64, 96, 160, 256, 384\}$ should give usable depths that are *equally spaced on a $\log d$ axis* — a smooth ramp, not a threshold. The current data leaves the interval between $28$ and $384$ entirely untested, so a sharp threshold there would be evidence against the story.

**A scale-invariance counter-prediction, and this is the sharp one.** The proved gain is $\|e\|^2\|g\|^2 \ge d c^2 \|g\|^2$; it depends on the *norm* of the end token, not on its dimension as such. So initialise the wide end token at per-coordinate scale $c/\sqrt{d}$, holding $\|e\|^2$ fixed as $d$ grows, and the cure should **evaporate** — the wide arm should fall straight back into the failing distribution. It is a one-line change to an initialiser, and it separates "richness" from "dimension". If the cure survives that change, the mechanism as stated is wrong.

**A narrower stable learning-rate window.** The same preconditioner $\|e\|^2 I + WW^{\mathsf T}$ that accelerates the continuous flow also bounds the step size at which a discrete optimiser remains stable, roughly $\eta < 1/(dc^2 + \|W\|^2)$. So wide end tokens should show their optimum at a learning rate smaller by a factor of about $20/384$, and should *diverge* rather than merely slow down above it.

---

## The design lesson

We are used to thinking of a sequence model's boundary tokens as bookkeeping — punctuation, a delimiter, a signal to start decoding. This dissection says something else. The final step is where a recurrent answer path is asked to convert an accumulated state into a fine-grained decision, and it is exactly there that a geometrically shrinking state meets a margin requirement that does not shrink. The input pathway at that step is not decoration; it is the conditioning of the hardest optimisation problem in the network.

So the lesson is not "use bigger models", nor "learn better features", nor "add positional information". All three were tested and all three failed. It is:

> **For length-general sequential computation in a state-augmented answer path, make the final step's input pathway rich. Boundary-condition richness — not feature content, not capacity, not position — is what keeps a recurrent readout in distribution at depth.**

There is something pleasing about the shape of the result. Two of the three components are pure, classical, provable mathematics — an automaton that is exactly right at every depth, and a contraction that provably forgets. The third is a two-line calculus computation showing that a reparameterisation which changes nothing about *what* can be computed changes everything about *how fast* it is found. The wall was never in the arithmetic. It was in the punctuation.
