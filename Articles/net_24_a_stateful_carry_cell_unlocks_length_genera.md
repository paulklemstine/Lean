# The Wall Was the Answer, Not the Question

## Why machines that "know" how to add still can't add longer numbers — and the one bit of memory that fixes it

There is a strange and very reproducible failure that anyone who has trained a modern sequence model on arithmetic runs into. You train the model to add five-digit numbers. It learns. It gets them all right — not "mostly", not "usually", *all* of them, on fresh problems it has never seen. Then you hand it a six-digit problem, which is the same task with one more column, and the accuracy collapses. Not gracefully. It falls to the floor.

The reflex is to reach for the usual levers. Make it deeper. Make it wider. Train it longer. Change the curriculum. Change how positions are encoded. Reshape the task so the model gets more hints. Every one of those levers has been pulled, and the wall does not move. Adding depth buys you a few more columns and then you hit the wall again, one column past wherever the new depth reaches.

This article is about why that happens, and about the surprisingly small change that makes it stop happening. The punchline is that the wall is not in the model's *perception* of the digits. It is in the shape of the function that turns perception into an answer. And the fix is one bit of memory in the right place.

---

## The oldest algorithm in the book

Start with what addition actually *is*, mechanically. Write two numbers in base $b$, one above the other, and line up the columns. Number the columns from the right, so column $0$ is the ones place, column $1$ is the $b$'s place, and so on. Call the digits of the two numbers $x_0, x_1, x_2, \dots$ and $y_0, y_1, y_2, \dots$.

You process the columns from right to left, holding one thing in your head: the carry. Formally, let $c_0 = 0$, and for each column define

$$c_{i+1} = \begin{cases} 1 & \text{if } x_i + y_i + c_i \ge b \\ 0 & \text{otherwise,}\end{cases} \qquad d_i = (x_i + y_i + c_i) \bmod b .$$

The number $d_i$ is the digit you write down in column $i$, and $c_{i+1}$ is the carry you pass to the next column. That's it. That's the whole algorithm, and it is correct at every length: for every $n$,

$$\sum_{i<n} d_i b^i \;+\; b^n c_n \;=\; \sum_{i<n} x_i b^i \;+\; \sum_{i<n} y_i b^i .$$

The digits you write, plus the overflow, are exactly the sum. **This is the Length-General Correctness Theorem for the carry cell**, and it follows from a single one-column identity, $d_i + b\,c_{i+1} = x_i + y_i + c_i$, by induction. Note carefully what makes it work: one rule, applied identically at every column, with a single bit passed along. Nothing in the rule mentions $n$. The algorithm never has to know how long the numbers are.

That last sentence is the whole story of this article in disguise.

---

## What "answer function" means, and why it is the suspect

Suppose you don't want to run a sequential procedure. You want a *formula*: a fixed computation that, given the two digit streams and a column index $i$, produces the digit $d_i$ directly. A modern attention-based network is essentially this — it computes a stack of features over the columns, and then a fixed readout looks at those features and emits the answer digit at each position, all positions at once, with no running memory carried from one position to the next.

Two properties characterise such a readout, and both are innocuous-looking:

- It is **state-free**: the answer at column $i$ is a function of the inputs, not of anything accumulated while producing the answers at columns $0, \dots, i-1$.
- It has a **bounded receptive field**: there is some radius $k$ such that the answer at column $i$ depends only on input columns $i-k, \dots, i$. Not because anyone designed it that way, but because a fixed stack of $d$ layers, each of which mixes information across a window of radius $r$, can never move information further than $d\cdot r$ columns. Depth times radius. That's a hard ceiling, and it doesn't grow when the input gets longer.

The readout may depend on the position index $i$ in any way it likes — a different rule at every column, learned from data, arbitrarily complicated. It may be as deep and as wide as you please. All we require is that the depth and the window are fixed *before* the input length is chosen.

Here is the theorem that ends the story.

> **The Carry Wall Theorem.** Let $b \ge 2$ and let $k$ be any radius. There is no state-free, position-parameterised answer function of receptive field $k$ that outputs the correct base-$b$ addition digit at every column. Moreover the failure is not asymptotic: correctness already breaks at column $k+1$ — on inputs one column longer than the window can reach.

And the proof is something you can do on the back of an envelope. Take base $10$ for concreteness. Consider the two additions

$$\begin{array}{r} \cdots 9\,9\,9\,9\,1 \\ +\ \ \cdots 0\,0\,0\,0\,9 \end{array} \qquad\text{versus}\qquad \begin{array}{r} \cdots 9\,9\,9\,9\,0 \\ +\ \ \cdots 0\,0\,0\,0\,9 \end{array}$$

The inputs are identical everywhere except in the ones column, where one has a $1$ and the other a $0$. In the first, $1+9=10$: a carry is generated at column $0$, and then it propagates forever, because $9+0+1=10$ at every column above. So every output digit above the ones place is $0$. In the second, $0+9=9$: no carry is ever produced, so every output digit above the ones place is $9$.

Two inputs that differ in exactly one place, whose answers differ in *every* place. Now the argument is one line: a readout at column $k+1$ with radius $k$ can only see columns $1, \dots, k+1$, and on those columns the two inputs are literally identical. So it must return the same digit for both. But the correct answers are $0$ and $b-1$, which differ because $b \ge 2$. Contradiction.

In general form: for any base $b\ge 2$, take $x = (1, b-1, b-1, \ldots)$ against $x' = (0, b-1, b-1, \ldots)$, both added to $y = (b-1, 0, 0, \ldots)$. The digit at every column $i \ge 1$ is $0$ in the first case and $b-1$ in the second.

This is what people mean when they say the carry chain is *sensitive*: the output at column $n$ genuinely depends on the input at column $0$, for every $n$. There is no locality to exploit, no window large enough, because the dependency length grows with the problem.

---

## Depth buys columns, linearly, and then stops

The receptive-field bound turns straight into a resource bound, and this is where the practical shape of the wall shows up.

> **The Depth Lower Bound.** Consider a layered computation with $D$ layers, where each layer computes the value at column $i$ from the previous layer's values at columns $i-r, \dots, i$ (each layer may depend arbitrarily on its own index and on the position). If this computation emits the correct base-$b$ addition digit at every column $i < n$, then
> $$n \le D\cdot r + 1, \qquad\text{equivalently}\qquad D \ge \frac{n-1}{r}.$$

The proof is exactly the receptive-field induction — after $\ell$ layers, column $i$'s value depends only on inputs $i-\ell r, \dots, i$ — plus the witness pair above.

Read this as an engineer, not as a logician. It says: **depth must grow linearly in the number of digits.** A model with $D$ layers and window $r$ can add numbers up to $D r + 1$ digits long and then it walls, hard, at the very next column. That is precisely the observed phenomenon: the model doesn't degrade, it doesn't get "a bit worse", it hits a specific length and dies. Scaling doesn't cure a wall like this, it relocates it. Doubling the depth doubles the reachable length; it does not remove the boundary.

---

## Why order matters: the kill/propagate/generate monoid

Underneath the wall is a piece of algebra that explains why nothing local can work.

Look at a single column and ask what it does to an incoming carry. There are exactly three possibilities:

- **Kill** ($x_i + y_i < b-1$): the carry out is $0$ no matter what comes in.
- **Propagate** ($x_i + y_i = b-1$): the carry out equals the carry in.
- **Generate** ($x_i + y_i \ge b$): the carry out is $1$ no matter what comes in.

Every column is one of these three *signals*, and the carry into column $n$ is what you get by composing the signals of columns $0, \dots, n-1$ and applying the composite to $0$. Composition is associative — $\mathrm{kill}\circ s = \mathrm{kill}$, $\mathrm{gen}\circ s = \mathrm{gen}$, $\mathrm{prop}\circ s = s$ — so this really is a monoid fold, which is why parallel-prefix adders exist in hardware.

But composition is **not commutative**: $\mathrm{kill}\circ\mathrm{gen} = \mathrm{kill}$ while $\mathrm{gen}\circ\mathrm{kill} = \mathrm{gen}$. Generating and then killing is not the same as killing and then generating. And that single inequality kills an entire class of architectures:

> **No Order-Blind Pooling Theorem.** Suppose the carry bit were computed by extracting a position-blind feature from each column, combining the features in a *commutative* monoid (which is what any sum-, average-, or attention-style pooling does), and thresholding. This is impossible for every base $b \ge 2$: swap a generate column with a kill column and the pooled value is unchanged, while the carry flips.

Concretely in base $10$: $9 + 1$ in the ones place and $0+0$ above gives no carry out of column $2$; the same two columns in the other order, $0+0$ then $9+1$, gives a carry. Same multiset of columns, different answer. Any aggregator that can't see the order is dead on arrival.

---

## The cure: put the bit in the state

Now the positive half, and it is almost embarrassingly small.

Define an **answer cell** abstractly: a state type $S$ (anything at all), an initial state, a transition $S \times \mathbb{N} \times \mathbb{N} \to S$ that ingests one column's features and updates the state, and a readout $S \times \mathbb{N} \times \mathbb{N} \to \mathbb{N}$ that emits a digit. Crucially, the cell is *fixed* — the same transition at every column, no dependence on the sequence length.

> **The Stateful Cure Theorem.** Suppose a cell admits a Boolean summary $\rho: S \to \{0,1\}$ of its state such that (i) $\rho(\text{init}) = 0$; (ii) for every state $s$ and every single pair of digits $u, v < b$, the transition satisfies $\rho(\text{step}(s,u,v)) = [\,u + v + \rho(s) \ge b\,]$; and (iii) the readout satisfies $\text{out}(s,u,v) = (u+v+\rho(s)) \bmod b$. Then the cell emits the correct addition digit at *every* column, for inputs of *every* length.

The hypotheses are all about a *single column*. The conclusion is about all lengths, simultaneously and unboundedly. Local correctness, globally free. Compare the state-free case, where the same style of local correctness is not merely hard to achieve — the Carry Wall Theorem says it is *unattainable at any radius*.

And the required state is tiny. The concrete witness is a cell with $S = \{0,1\}$: one bit. One bit of running memory, and the wall is gone.

Two sharpenings make clear that the state is doing all the work.

> **State-freeness is exactly the disease.** A cell whose state type carries no information at all (a one-element state) is literally a radius-$0$ readout, and so it fails by the Carry Wall Theorem. Removing the state removes the cure.

> **Necessity (a Myhill–Nerode argument).** Any cell that is correct at all lengths must *encode the carry*: if two input histories, possibly of different lengths, drive the cell into the same state, then those histories have the same carry. Equivalently, the carry bit is a function of the state. So one bit isn't just sufficient — the state has to contain it.

The proof of necessity is a nice trick. Probe the cell's state by feeding it a zero column: with $u = v = 0$, the emitted digit is $(0+0+c) \bmod b = c$, so the cell's own output *reveals* its carry. Two histories in the same state must give the same output on the same probe, hence the same carry.

---

## What the experiments say

The theory predicts a very specific experimental signature, and it is exactly what one observes.

Train a state-free attention model on five-digit addition until it is perfect. Test on six, seven, eight digits: accuracy $0$. Not degraded — zero. That's the wall, and it survives every intervention aimed at the *encoder*: more depth, more width, more training, different position schemes, task reformulations, even *handing the model the correct carries as extra input tokens*. That last one is the most telling failure, and the theory explains it: carries offered as *input tokens* still have to be routed to the right column by a bounded-window, state-free readout, and the routing is exactly what's impossible. The carries have to be *state*, not input.

Now change one thing. Keep the same encoder, the same parameter budget, the same causal masking, the same training data. Replace only the final state-free readout with a recurrent cell that carries a hidden state across columns. Eight-digit accuracy jumps from $0.0000$ to $1.0000$ — every digit of every fresh problem, at lengths never trained on, across independent training runs. The encoder was never the problem. The answer function was.

Two controls complete the picture. First, the cure does not depend on how positions are encoded: a hybrid with learned absolute position embeddings also generalises past its training length (about $96\%$ at eight digits, with a thin uniform error tail attributable to untrained embedding-table entries rather than any structural barrier), and a rotary scheme gives the clean perfect score. Second — and this is the honest caveat — recurrence *alone* is not the whole story. A plain recurrent network fed raw one-hot columns, with no rich encoder features, extends only one or two columns past its training length before degrading ($0.70$ at seven digits, $0.08$ at eight). Its carry *transition* generalises fine; its digit *readout* misfires on feature patterns it hasn't seen. The cure is state **plus** good per-column features. Either alone is insufficient.

---

## The carry as a cocycle, and where this goes

There is one more layer of structure worth naming, because it says the obstruction is not an accident of arithmetic but a cohomological fact.

Define the single-column carry as a number: $c(u,v) = \lfloor (u+v)/b \rfloor$. Then

> **The Carry Cocycle Identity.** For all $u, v, w$ and $b \ge 1$,
> $$c(u,v) + c\big((u+v) \bmod b,\; w\big) \;=\; c(v,w) + c\big(u,\; (v+w) \bmod b\big),$$
> both sides being $\lfloor (u+v+w)/b \rfloor$.

This is exactly the $2$-cocycle condition, and $c$ is the classical cocycle presenting the extension $0 \to \mathbb{Z}/b \to \mathbb{Z}/b^2 \to \mathbb{Z}/b \to 0$. Its class in $H^2(\mathbb{Z}/b, \mathbb{Z}/b)$ is nontrivial precisely when carrying can happen: $\mathbb{Z}/b^2$ is not $\mathbb{Z}/b \times \mathbb{Z}/b$.

The cocycle is also symmetric in $u$ and $v$ — a single column doesn't care about order. Order-sensitivity is a property of the *composition* of columns, not of any one of them. That is what "genuinely sequential information" means, precisely.

It also suggests the sharpest conjecture in this circle of ideas: for a general finite abelian extension $0 \to A \to E \to Q \to 0$ with cocycle $c$, a state-free bounded-window readout can compute the $E$-product of $n$ factors *if and only if* the class $[c] \in H^2(Q,A)$ vanishes. The intuition is clean — a coboundary $c = \delta f$ can be absorbed by a per-column relabelling, which is exactly a state-free positionwise transformation, whereas a nontrivial class cannot be. If that holds, "which sequential tasks wall?" has a cohomological answer.

---

## The moral

The temptation, when a model fails at a longer input, is to assume it hasn't *understood* the task and to give it more capacity until it does. The carry chain says otherwise. The model understood the columns perfectly well. What it lacked was a place to put one bit while it walked down the chain.

Every fixed-depth, state-free computation has a horizon: depth times window, plus one. Beyond that horizon lies not difficulty but impossibility, and the argument is a two-line comparison of $\cdots 9991 + \cdots 0009$ with $\cdots 9990 + \cdots 0009$. No amount of scale crosses an impossibility. A single bit of state does, and — by the Myhill–Nerode argument — it is exactly what has to be there.

Generations of schoolchildren have been taught the fix. You carry the one.
