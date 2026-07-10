# The P vs NP of Cooking: Why Some Dishes Are Harder to Make Than to Taste

Ask any home cook which is faster: making a soufflé, or deciding whether the soufflé turned out well. The answer feels obvious. Making it takes an hour of careful whisking, folding, and praying at the oven door. Judging it takes one bite. The *doing* is slow; the *checking* is quick.

That gap — between how long it takes to **produce** something and how long it takes to **verify** it — is one of the deepest questions in all of mathematics. Computer scientists call it **P versus NP**, and a million-dollar prize sits on top of it, unclaimed for over half a century. The astonishing thing is that you don't need a computer to meet this question. You can meet it in your kitchen.

This article tells the story of a small but complete mathematical theory that takes the metaphor "*every recipe is an algorithm*" absolutely literally — and then proves theorems about it.

## Recipes as algorithms

Strip a recipe down to its essence and it looks exactly like a computation. It takes **inputs** (ingredients), runs a **procedure** (chop, mix, heat), and returns an **output** (the dish). Two numbers capture the part we care about:

- The **cooking time** $C(R)$: how long it takes to prepare the dish.
- The **verification time** $V(R)$: how long it takes to taste the finished dish and decide whether it's good.

A **recipe** in our theory is nothing more than this pair of numbers, $R = (C(R), V(R))$, both non-negative whole numbers (say, minutes). Everything that follows is built from comparing these two quantities. That minimalism is the point: by throwing away flavor, texture, and technique, we expose the single structural feature that recipes share with algorithms.

## Three kinds of recipe

Once you look at every dish through the lens of "cook time versus taste time," recipes fall into exactly three families — and they mirror the three possible relationships in the theory of computation.

**Quick recipes** ($C(R) = V(R)$). Here cooking is no slower than tasting. Think of a simple salad or a cheese plate: assembling the dish takes about as long as inspecting it. This is the kitchen's version of the (widely disbelieved) world where **P = NP**, where finding a solution is as easy as checking one.

**Traditional recipes** ($V(R) < C(R)$). Verifying is strictly faster than cooking. This is the world almost every dish lives in — braises, breads, stocks, roasts. You labor for hours; you judge in a moment. This is the kitchen's **P ≠ NP**: the honest, hard-working majority.

**Overhard recipes** ($C(R) < V(R)$). Verifying is strictly *harder* than cooking. These are the strange dishes where the real difficulty is not in the making but in the knowing. The soufflé is the patron saint of this class: the only sure way to confirm it has risen correctly all the way through is to cut it open — which collapses it. Verification destroys the very thing being verified. These are the kitchen's genuinely **hard** problems.

Our first theorem says these three families are not just suggestive labels but an exact, exhaustive partition.

> **Trichotomy of Recipes.** Every recipe is exactly one of quick, traditional, or overhard. Precisely one of $C(R) = V(R)$, $V(R) < C(R)$, or $C(R) < V(R)$ holds.

The proof is a single line of arithmetic — any two whole numbers are equal, or one is smaller — but the framing is what matters. It tells us the classification is complete: there is no fourth kind of dish.

## Physical recipes: ruling out the impossible

Most real cooking obeys a sanity condition: you can taste a dish at least as fast as you made it. Call a recipe **physical** when $V(R) \le C(R)$. Physical recipes are precisely the quick and traditional ones together — everything except the overhard outliers.

> **Physicality Theorem.** A recipe is physical if and only if it is *not* overhard. Every physical recipe is either quick or traditional.

The soufflé, with its destructive verification, is the archetype of a *non*-physical recipe. Naming this condition lets us cordon off the well-behaved dishes and prove sharper results about them.

## Cooking one dish after another

Kitchens rarely make a single dish. They make menus. So we need a way to combine recipes. The natural operation is **sequential composition**: cook one dish, then the next. If you make recipe $R$ and then recipe $S$, the combined recipe $R \circ S$ has

$$C(R \circ S) = C(R) + C(S), \qquad V(R \circ S) = V(R) + V(S).$$

Times simply add. There is also an **empty recipe** — cook nothing, taste nothing — with both times zero, which acts as a "do nothing" step.

This tiny structure turns out to be a familiar algebraic object.

> **Monoid Theorem.** Recipes under sequential composition form a commutative monoid: composition is associative, the empty recipe is a neutral element, and the order of two independent dishes does not affect the total cooking and tasting budgets.

Commutativity has a homely meaning: whether you make the soup before the bread or the bread before the soup, the total time in the kitchen is the same.

## The classes survive combination

A good classification should respect the operations you build with. Ours does.

> **Closure Theorems.**
> - The composition of two quick recipes is quick.
> - A traditional recipe composed with any physical recipe stays traditional.
> - The composition of two physical recipes is physical.

The middle statement is the most telling: a genuine kitchen slowdown cannot be *cancelled* by pairing it with a well-behaved companion dish. If one course is honestly slow to make, the meal as a whole inherits that slowness. Hardness, once present, propagates.

## Slack: measuring how much harder cooking is

For a physical recipe, the difference $C(R) - V(R)$ measures the **speedup** — how much faster tasting is than cooking. Quick recipes have zero speedup; traditional recipes have positive speedup. In fact:

> **Speedup Characterization.** A recipe is quick if and only if it is physical and has zero speedup.

And slack behaves beautifully under composition:

> **Additivity of Speedup.** For physical recipes, the speedup of a two-course meal is the sum of the individual speedups: $\big(C(R\circ S) - V(R\circ S)\big) = \big(C(R)-V(R)\big) + \big(C(S)-V(S)\big).$

Physicality is essential here. Because our times are whole numbers, subtraction is *truncated* — it can't go below zero — so without the guarantee $V \le C$, the differences might clip and the clean addition would fail. This is a small but honest subtlety: the arithmetic of "how much harder" only works cleanly in the physical regime.

## Many servings

Cooking $n$ identical portions is just composing a recipe with itself $n$ times. Unsurprisingly but satisfyingly, both times scale linearly:

$$C(\underbrace{R\circ\cdots\circ R}_{n}) = n\,C(R), \qquad V(\underbrace{R\circ\cdots\circ R}_{n}) = n\,V(R).$$

So the *ratio* of cooking to tasting is unchanged by batching. Doubling the guest list doesn't change *what kind* of recipe you're making — a quick dish stays quick, a traditional dish stays traditional. Scale is neutral to complexity class.

## The Batch Quickness Theorem

Now the climax. Consider a whole menu — a list of physical dishes — and ask when the *entire menu* is quick, meaning its total cooking time equals its total tasting time. The answer is as clean as one could hope.

> **Batch Quickness Theorem.** A menu made entirely of physical recipes is globally quick if and only if *every single dish on it is quick*.

One slow dish is enough to make the whole menu slow. There is no way to average out a genuinely hard course against a pile of trivial ones. Mathematically this is the statement that a sum of non-negative slacks is zero exactly when each slack is zero — but read as a culinary law it is strikingly strong: **quickness is all-or-nothing across a physical menu.**

## The cooking ratio

Finally, the three classes can be read off a single number, the **cooking ratio** $C(R)/V(R)$ (for a dish that takes some time to taste):

- ratio $= 1$: quick,
- ratio $> 1$: traditional,
- ratio $< 1$: overhard.

This is the kitchen's dimensionless measure of hardness — a pure number, independent of units, that says how much harder a dish is to make than to judge.

## Why this is more than a joke

It would be easy to read all this as a clever pun. It is more than that. The value of the exercise is that it isolates, in the humblest possible setting, the *structural skeleton* of the P versus NP question: a resource for producing, a resource for verifying, and the relationship between them. Stripped of the machinery of Turing machines and polynomials, the essential drama survives — and every claim above is a genuine, fully proved theorem, not a metaphorically-waved hand.

There is real intuition to be gained here. The Batch Quickness Theorem tells you why a single hard subproblem can dominate a large computation, just as a single soufflé can dominate an evening's cooking. The closure theorems explain why hardness composes and refuses to be diluted. The truncation subtlety in the speedup law is exactly the kind of edge case that trips up careless reasoning about resource bounds. And the trichotomy reminds us that "easy," "hard," and "hard-to-even-check" are genuinely distinct regimes.

The great open question — does $C$ always exceed $V$ for the problems we truly care about? — remains open in the wider world of computation. But next time you stand at the oven, waiting an hour to make something you'll judge in a single bite, you can smile: you are living inside one of the deepest conjectures in mathematics. In most kitchens, as most mathematicians believe of the wider universe, doing is harder than checking.
