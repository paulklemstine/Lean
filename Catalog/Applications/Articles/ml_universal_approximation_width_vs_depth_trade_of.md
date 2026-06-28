# The Folded Ruler: Why Deep Networks Beat Wide Ones

Imagine you are handed a strip of paper and asked to draw a zig-zag line that climbs and falls a thousand times — a thousand sharp peaks marching across the page. You have two ways to do it.

The first way is to draw every peak by hand, one after another. A thousand peaks means a thousand strokes. This is the *wide* strategy: brute force, one piece of machinery per feature.

The second way is sneakier. Fold the paper in half, then in half again, and again — ten times. A single zig-zag drawn across the folded stack, when unfolded, becomes more than a thousand zig-zags. Ten folds, one drawing. This is the *deep* strategy: each fold doubles the complexity for free.

This little parable is, almost literally, the central drama of modern deep learning. The "folds" are the layers of a neural network. The question of whether folding really beats hand-drawing — whether **depth** is fundamentally more powerful than **width** — is one of the most important theoretical questions about why deep learning works at all. This article is about a clean, complete, two-sided answer to that question, built around one of the most elegant objects in mathematics: the *tent map*.

## The tent and the fold

Start with a single triangular bump. On the interval from $0$ to $1$, define the **tent map**:

$$\mathrm{tent}(x) = 1 - |2x - 1|.$$

Read it slowly. At $x = 0$ the value is $1 - |{-1}| = 0$. At $x = \tfrac12$ it is $1 - 0 = 1$. At $x = 1$ it is $1 - |1| = 0$. In between it rises in a straight line to a peak and falls in a straight line back down. It is a perfect symmetric tent, one peak, base from $0$ to $1$.

Now do something playful: feed the tent map into itself. Compute $\mathrm{tent}(\mathrm{tent}(x))$. The output of the inner tent sweeps from $0$ up to $1$ and back down to $0$ as $x$ goes from $0$ to $1$. The outer tent turns *that* single sweep into a full up-and-down. The result is a function with **two** peaks. Compose three times and you get four peaks. Compose $k$ times — written $\mathrm{tent}^{[k]}$ — and you get exactly $2^k$ peaks.

This is the mathematics of folding. Each composition is a fold. One application gives $1$ peak's worth of oscillation, $k$ applications give $2^k$. The number of wiggles explodes *geometrically* in the number of compositions, even though each composition is the same simple tent.

There is a beautifully precise way to see the explosion. Lay down a grid of dyadic points across $[0,1]$: the points $0, \tfrac{1}{2^k}, \tfrac{2}{2^k}, \ldots, 1$, of which there are $2^k + 1$. On this grid, the $k$-fold tent takes the values

$$\mathrm{tent}^{[k]}\!\left(\frac{i}{2^k}\right) = i \bmod 2,$$

that is, $0, 1, 0, 1, 0, 1, \ldots$ — a perfect alternation. The function jumps up by $1$, then down by $1$, then up by $1$, all the way across, $2^k$ times. It is a maximally jagged sawtooth.

## Measuring jaggedness: total variation

To compare "how wiggly" two functions are, we need a number. The right one is **discrete total variation**: walk across the grid and add up the absolute sizes of every step,

$$\mathrm{TV}_k(g) = \sum_{i=0}^{2^k - 1} \left| g\!\left(\frac{i+1}{2^k}\right) - g\!\left(\frac{i}{2^k}\right)\right|.$$

For the $k$-fold tent, every one of the $2^k$ steps has size exactly $1$, so its total variation is exactly $2^k$. Jaggedness, quantified.

Total variation is the hero of this story because it is *conserved* in a useful sense. It cannot be faked, and it cannot be hidden. If you want to build a function that wiggles $2^k$ times, you must pay for $2^k$ units of total variation somewhere in your machinery. The whole depth-versus-width theorem is, at heart, an accounting argument about who can afford that bill.

## What a neuron can buy

Both wide and deep networks are built from the same atom: the **rectified linear unit**, or ReLU,

$$\mathrm{relu}(y) = \max(y, 0).$$

It is the simplest possible nonlinearity: pass the signal through if positive, otherwise output zero. A single hidden layer — a **shallow** network of width $w$ — combines $w$ of these ramps:

$$\text{shallow}(x) = c + \sum_{j=1}^{w} a_j \,\mathrm{relu}(x - t_j).$$

Each term is a ramp that switches on at threshold $t_j$ and then climbs with slope $a_j$. This is the "draw every peak by hand" machine. How much total variation can $w$ such ramps produce? Here is the elementary but decisive fact: across any single cell of the grid, one ramp can change by at most the cell's width times its slope, and the absolute changes can never exceed the weight $|a_j|$ summed across the whole interval. Adding up,

$$\mathrm{TV}_k(\text{shallow}) \le \sum_{j=1}^{w} |a_j|.$$

A shallow network's jaggedness is bounded by the total magnitude of its weights. To buy $2^k$ units of wiggle, it must spend $2^k$ units of weight. And if no single neuron's weight may exceed a cap $A$ — a wholly realistic constraint, since real networks cannot use astronomically large numbers — then the number of neurons itself must satisfy

$$w \ge \frac{2^k}{A}.$$

The width must be **exponential** in the number of folds.

There is one subtlety worth honoring. Real networks rarely match a target *exactly*; they approximate it to some tolerance $\varepsilon$. Does approximation let a shallow network cheat? No — and the reason is a gentle one. If a shallow network stays within $\varepsilon$ of the alternating tent at every grid point, then at each step it must still travel almost the full distance of $1$, losing at most $2\varepsilon$ to the wiggle room at the two endpoints. So its total variation is still at least $2^k(1 - 2\varepsilon)$, and the width bound sharpens only slightly to

$$w \ge \frac{2^k(1 - 2\varepsilon)}{A}.$$

As long as $\varepsilon < \tfrac12$ — that is, as long as the approximation is good enough to be worth anything — the exponential wall stands. (At $\varepsilon = \tfrac12$ the wall vanishes, and rightly so: a flat line at height $\tfrac12$ is within $\tfrac12$ of *everything*, so it "approximates" the tent in a vacuous, useless sense.)

This is the **shallow lower bound**, and it is half the story. It says: hand-drawing $2^k$ peaks costs exponentially many strokes.

## What folding buys

Now the other half — and the part that makes the separation real rather than a one-sided complaint. We must show that the deep, folding machine genuinely does the job cheaply.

Begin with a small miracle of bookkeeping. The absolute value, which looks like it needs special hardware, is secretly built from two ReLUs:

$$|y| = \mathrm{relu}(y) + \mathrm{relu}(-y).$$

If $y > 0$, the first term gives $y$ and the second gives $0$. If $y < 0$, the first gives $0$ and the second gives $-y = |y|$. Either way, the sum is $|y|$. So the entire tent map collapses into a **two-neuron block**:

$$\mathrm{tent}(x) = 1 - \mathrm{relu}(2x - 1) - \mathrm{relu}(1 - 2x).$$

Two ReLUs, exactly — not approximately — reproduce the tent. This identity is purely algebraic; there is no limiting process, no error term, no continuity argument hiding in the basement. It is an *equation*.

The consequence cascades immediately. Since one fold is two neurons, $k$ folds are $k$ stacked copies of the same two-neuron block. We can describe a deep network as a list of such blocks, evaluated by composition — the output of one block feeds the input of the next — and define its total size as the sum of the neuron counts. Then the $k$-fold tent is realized **exactly** by a network of

$$\text{total size} = 2k.$$

Pause on the contrast. The target $\mathrm{tent}^{[k]}$ has $2^k$ oscillations. The deep network that produces it, exactly, uses $2k$ neurons. The deep size is the *logarithm* of the oscillation count:

$$2k = 2\log_2\!\left(2^k\right).$$

This is the **logarithmic-size law**. Depth converts a linear budget of neurons into an exponential budget of complexity. Where the shallow machine needs $2^k/A$ neurons, the deep machine needs $2k$. For $k = 20$ — a million oscillations — the shallow network needs on the order of a million neurons; the deep one needs forty.

## The two sides meet

Put the halves together and you get a genuine, two-sided **depth–width separation**. There is a single concrete target, $\mathrm{tent}^{[k]}$, such that:

- a **deep** network of constant width $2$ and total size $2k$ realizes it *exactly*; yet
- **any** shallow network that merely approximates it to accuracy $\varepsilon < \tfrac12$, with weights capped at $A$, is forced to width at least $2^k(1 - 2\varepsilon)/A$.

Linear cost on one side, exponential cost on the other, for the very same function. This is not a statement that deep networks *can sometimes* be smaller. It is a statement that for an explicit family of targets they are *unavoidably, exponentially* smaller — and the proof carries the exact constants.

How big can the gap get? Take the ratio of the forced shallow width to the actual deep size,

$$\frac{2^k(1 - 2\varepsilon)/A}{2k}.$$

The numerator grows like $2^k$; the denominator grows like $k$. Exponential beats linear, always and eventually. For any target ratio $R$ you care to name — a thousandfold, a millionfold — there is a depth $k$ beyond which the shallow network is at least $R$ times larger than the deep one. The advantage of depth is not bounded by any constant; it is **unbounded**.

## Why this matters beyond the tent

It is fair to ask whether a story about triangular bumps tells us anything about real networks that recognize faces or translate languages. It does, in two ways.

First, the tent is not a contrived curiosity; it is the cleanest possible instance of a universal phenomenon. Composition multiplies complexity. Every deep architecture — convolutional, residual, transformer — is in the business of composing simple transformations so that complexity compounds. The tent map is the hydrogen atom of that physics: simple enough to analyze completely, rich enough to exhibit the exponential payoff in full. The lesson it teaches — *depth manufactures oscillation for free, and width must buy it linearly* — is the mechanism, stripped to its bones.

Second, the argument exposes *why* the trade-off holds, not merely *that* it holds. The currency is total variation: a conserved, additive measure of complexity that depth mints geometrically and width can only purchase in proportion to its weight budget. This is a transferable idea. Whenever a learning problem has a complexity measure that compounds under composition, depth will tend to win, and one can hope to prove it by the same accounting.

A few honest caveats keep the picture sharp. The clean statements here are one-dimensional, a single input and a single output per fold; extending the exact realization to functions on $[-1,1]^n$ requires vector-valued blocks and is the natural next step. The strict numerical gap $2k < 2^k$ kicks in at $k = 3$ — for the first few folds the two budgets are comparable — which is exactly why the dramatic separation is an *asymptotic* statement about deep stacks. And the shallow bound needs the weight cap $A$; without it, a network could in principle smuggle complexity into infinitely precise numbers, which is the correct boundary of the theorem rather than a flaw in it.

## The shape of the answer

Strip away the formalism and what remains is a single, vivid image. To make a thousand peaks, you can carve each one — and pay a thousand times — or you can fold the paper ten times and draw once. The folds are layers. The peaks are the patterns a network can represent. And the theorem says, with the full force of proof and exact constants, that the folder always wins, and wins by a margin that grows without bound.

Depth is not a convenience. It is leverage. A tent, folded $k$ times, oscillates $2^k$ ways while costing only $2k$ — and no flat-stacked, hand-drawn machine, however wide, can keep up. That is the mathematical heart of why the deepest revolution in artificial intelligence was, quite literally, a matter of depth.
