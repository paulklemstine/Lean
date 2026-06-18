# The Folding Trick: Why Deep Networks Beat Wide Ones

## A paper-folding puzzle

Take a strip of paper one meter long. Mark the left end "0" and the right end "1". Now fold it in half so the two ends meet, then unfold and look at the crease pattern. Fold again, and again. After ten folds, you have created a landscape of 1,024 tiny peaks and valleys packed into the original meter. The pattern is intricate — yet you produced it with ten almost identical, almost effortless motions.

This humble act of repeated folding is, it turns out, the secret behind one of the most important facts in modern artificial intelligence: **depth is exponentially more powerful than width.** A neural network that stacks many simple layers can express shapes that a single enormously wide layer cannot match without becoming astronomically large. This article tells the story of that fact — not as engineering folklore, but as a clean, provable piece of mathematics, with every claim stated precisely and verified.

## Neural networks, demystified

Strip away the hype and a neural network is just a recipe for building a function out of very simple parts. The simplest part is the **ReLU**, short for "rectified linear unit." It is the almost laughably plain function

> **relu(x) = max(x, 0).**

It returns its input if the input is positive, and zero otherwise. A graph of it looks like a hockey stick: flat along the negative axis, then a straight 45-degree ramp going up. That's it. That's the engine.

From this single bent line you can build anything piecewise-linear by adding shifted, scaled copies together. A **layer** of a network is a batch of such ReLUs computed in parallel; the number of ReLUs in a layer is its **width**. Stacking layers — feeding the output of one into the next — gives **depth**. The two great questions of the field are: *What can these networks represent?* and *How big must they be to do it?*

"Big" comes in two flavors. A **wide, shallow** network has one enormous layer. A **deep, narrow** network has many small layers. Both can, in principle, approximate any reasonable function. The deep question is whether one flavor is fundamentally more economical than the other. The answer is a resounding yes, and the cleanest way to see it is to build the paper-folding machine out of ReLUs.

## The tent map: one fold, made of two ramps

Here is the mathematical equivalent of a single fold. Define the **tent map**:

> **tent(x) = 1 − |2x − 1|.**

On the interval from 0 to 1, this draws a perfect symmetric triangle: it starts at 0 when x = 0, climbs steadily to its peak of 1 at the midpoint x = 1/2, then descends back to 0 at x = 1. A tent. A single fold of our paper strip.

The first thing to notice is that the tent map *is a neural network layer*. The absolute value function hides a pair of ReLUs, because for any number y,

> **|y| = relu(y) + relu(−y).**

Substituting y = 2x − 1 gives an exact, two-line identity:

> **tent(x) = 1 − relu(2x − 1) − relu(1 − 2x).**

This is a one-hidden-layer ReLU network of **width two**. No approximation, no hand-waving: the tent is literally two rectified ramps, one catching the rising part and one the falling part, combined by simple addition. This is the formally verified statement we call `tent_relu_repr`.

The tent map is also gentle in a precise sense: it is **2-Lipschitz**. "Lipschitz" is a mathematician's word for "has a bounded slope." A function is *K*-Lipschitz if, no matter which two points you pick, the output never changes faster than *K* times the input:

> **|f(a) − f(b)| ≤ K · |a − b|.**

The tent's steepest slope is 2 (it climbs from 0 to 1 over a horizontal distance of 1/2), so it is 2-Lipschitz. We call this `tent_lipschitz`. The Lipschitz constant is the single most important number in this whole story; hold onto it.

## Folding again: composition is depth

Now we fold the fold. **Composition** means applying the tent map to its own output. Apply it once, twice, *k* times, and write the result as **tentᵏ** (the "*k*-fold tent"). In network terms, each composition is one more layer. So tentᵏ is a ReLU network of depth *k* and constant width — exactly our paper-folding machine, expressed in silicon-friendly arithmetic.

What does tentᵏ look like? Something remarkable happens. Each application of the tent map takes the existing graph and reflects its right half back over its left half — it doubles the number of triangles. One tent has a single peak. Two folds (tent²) produce two peaks. Three folds, four peaks. After *k* folds you have a sawtooth of **2ᵏ⁻¹ peaks**, each a perfect triangle, all crammed into the unit interval. The output never leaves the range from 0 to 1 — the height of the landscape stays modest — but the *number* of oscillations explodes exponentially.

Three facts pin this down precisely, all formally verified:

- **It pins the left corner.** tentᵏ(0) = 0 for every *k*. The point 0 is a fixed point of the tent map, and folding never moves it. (`tent_iterate_zero`.)
- **It has a razor-thin first ramp.** The very first peak of tentᵏ sits at x = (1/2)ᵏ, and there the value is exactly 1. (`tent_iterate_peak`.) Combine this with the previous fact: the *k*-fold tent rockets from 0 all the way up to 1 across a horizontal distance of just **2⁻ᵏ**. At ten folds, that ramp is one part in a thousand wide. At twenty folds, one part in a million.
- **Its slope is brutal.** Composing a 2-Lipschitz map *k* times yields a **2ᵏ-Lipschitz** map. (`tent_iterate_lipschitz`.) The slopes multiply: two folds give slope 4, three give 8, and ten give 1,024. This is the inevitable arithmetic of stacking — a tiny cost per layer (a factor of 2) compounds into an exponential.

Here, then, is a function — buildable by a *narrow* network whose size grows only **linearly** with depth *k* — that is simultaneously bounded in height yet steeper than any cliff and busier than any comb. The question is whether a shallow network can keep up.

## Why width can't fake depth

A shallow ReLU network with bounded weights is, mathematically, just a Lipschitz function whose constant *K* is controlled by its width and the size of its weights. To match the *k*-fold tent's frantic oscillation it would need an enormous slope — and slope, for a Lipschitz function, is exactly what you cannot have for free. This tension is the heart of the **depth-separation theorem**, our main result, which we can now state in full:

> **Depth-separation theorem (`relu_depth_separation`).** Let *g* be any *K*-Lipschitz function, and suppose K · 2⁻ᵏ + 2ε < 1. Then *g* cannot approximate tentᵏ to within ε everywhere on the interval [0, 1]. That is, there is necessarily some point x in [0, 1] where |tentᵏ(x) − g(x)| > ε.

The proof is a three-line squeeze, and its logic is worth savoring because it is completely elementary. Look at just two points: the left corner x = 0 and the first peak x = (1/2)ᵏ. The true function tentᵏ takes the values 0 and 1 at these two points — it has *climbed a full unit*. The two points are only 2⁻ᵏ apart horizontally.

Now suppose, for contradiction, that *g* tracks tentᵏ within ε everywhere. Then at x = 0, *g* must be within ε of 0; at the peak, *g* must be within ε of 1. So *g* itself must climb at least 1 − 2ε across those two points. But *g* is *K*-Lipschitz, so the most it can climb across a gap of width 2⁻ᵏ is K · 2⁻ᵏ. Putting these together forces

> **1 − 2ε ≤ K · 2⁻ᵏ,  i.e.  K · 2⁻ᵏ + 2ε ≥ 1,**

which directly contradicts our assumption. Done. The approximation is impossible.

Rearrange the inequality and the punchline appears: to approximate the depth-*k* tent at any fixed accuracy ε < 1/2, a Lipschitz (bounded-weight, shallow) network must have

> **K ≥ (1 − 2ε) · 2ᵏ.**

Its Lipschitz constant — and therefore its weight-times-width budget — must grow like **2ᵏ**. A deep network achieves with *k* small layers what a shallow network can only achieve by ballooning to exponential size. Depth buys exponential expressiveness.

## The threshold is razor-sharp

A skeptic might wonder whether the strange-looking condition "K · 2⁻ᵏ + 2ε < 1" is just a convenient slack that could be tightened. It cannot — and we proved exactly why. The *k*-fold tent is itself 2ᵏ-Lipschitz and of course approximates itself perfectly (ε = 0). Plug K = 2ᵏ and ε = 0 into the budget:

> **2ᵏ · 2⁻ᵏ + 2·0 = 1,**

landing exactly on the boundary value of 1 (`relu_depth_separation_sharp`). The theorem forbids everything strictly below this threshold and the threshold is achieved by the honest self-approximation. The inequality is sharp; it cannot be relaxed from "<" to "≤". This is the kind of detail that separates a slogan from a theorem.

A concrete illustration drives it home. At depth k = 3, consider the laziest possible "shallow" model: the flat constant function g(x) = 1/2, which is 0-Lipschitz (K = 0). Can it approximate the depth-3 tent to accuracy 3/8? The budget reads 0 · 2⁻³ + 2 · (3/8) = 3/4 < 1, so the theorem says **no** — and indeed it cannot, because the true function spans the full distance from 0 to 1 while a flat line at 1/2 is always 1/2 away from one of the corners, exceeding 3/8.

## Two mechanisms, one phenomenon

There is a subtle and beautiful point buried in this construction. There are two completely different ways a deep network can outrun a shallow one, and the tent map isolates the more interesting one.

The first, cruder mechanism is **range explosion**: iterate a map that grows, like x ↦ 2x or an exponential, and the output values themselves blow up. A shallow network then fails simply because it cannot reach high enough. This is a real effect, but it feels like cheating — of course you can't approximate something that runs off to infinity.

The tent map does something far more subtle. Its output **never leaves [0, 1]**. The height of the landscape is fixed and modest. The difficulty lives entirely in the *oscillation* — the exponential number of peaks and the razor-thin ramps — not in the magnitude. This is the genuinely *neural*, piecewise-linear mechanism behind depth separation, the one identified in the work of Telgarsky and others as the real reason depth matters. Our theorem captures it in its purest analytic form: equal output range, exponential oscillation, provable impossibility.

## Why this matters beyond the page

The width-versus-depth trade-off is not an academic curiosity. It is the mathematical justification for the single most consequential design decision of the deep-learning era: the move from shallow, fat networks to deep, slim ones. Every modern architecture — the convolutional networks that recognize faces, the transformers that power language models — is *deep* for exactly the reason this theorem makes rigorous. Depth is not a fashion; it is an exponential efficiency.

The broader picture frames the universal-approximation landscape as a budget problem. To approximate a *K*-Lipschitz target on [−1, 1]ⁿ to accuracy ε:

- a **shallow** network needs width that scales roughly like ε⁻¹ in one dimension (and far worse, like ε⁻ⁿ, in *n* dimensions — the curse of dimensionality);
- a **deep** network can get away with depth scaling like log(1/ε), an exponential saving.

The tent map is the sharpest possible witness to the gap between these two budgets. It says: here is a single, concrete, bounded function that a deep network draws effortlessly with *k* tiny folds, and that no shallow network can imitate without an exponential, 2ᵏ-sized blowup. The folding paper strip, it turns out, was never just a puzzle. It was a proof.

## The takeaway

Strip everything down and the message is a single image: **folding is cheap, but unfolding is expensive.** A deep network folds — it composes simple steps, and a tiny per-step cost compounds into exponential intricacy. A shallow network must somehow draw the unfolded result in one stroke, and the bookkeeping of all those creases costs it exponentially. The tent map turns this intuition into theorems you can check line by line: it is two ReLUs wide, it folds the unit interval onto itself, and after *k* folds it is a function that is provably, sharply, exponentially beyond the reach of any gently-sloped competitor. That is why, when in doubt, we go deep.
