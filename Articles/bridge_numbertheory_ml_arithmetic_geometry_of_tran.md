# The Arithmetic of Shrinking a Neural Network

## When a trillion knobs get rounded off

A modern language model is, at heart, an enormous list of numbers. Each of those numbers — a *weight* — is a dial that the training process has painstakingly tuned. There can be hundreds of billions of them, and in their pristine form each one is stored as a full floating-point real number: sixteen or thirty-two bits of precision apiece.

Then comes deployment. To run on a phone, a laptop, or simply on fewer GPUs, the model is **quantized**: every weight is snapped to the nearest point of a coarse arithmetic grid. Instead of $0.4173\ldots$, the weight becomes $0.4$, or in the four-bit world, one of only sixteen permitted values. Formally, one fixes a mesh $\delta > 0$ and replaces each weight $x$ by
$$Q_\delta(x) \;=\; \delta \cdot \operatorname{round}(x/\delta),$$
the nearest point of the lattice $\delta\mathbb{Z}$. It is the crudest imaginable act of vandalism against a delicately trained object, and it works spectacularly well in practice. Models survive it; sometimes they barely notice.

Why? The engineering answer is "the errors are small and they average out." That is not a theorem. This article is about what happens when you insist on one — and about the surprise at the end of that insistence: the damage quantization does to a model's optimization landscape is governed not by the size of the rounding error but by **number theory**, specifically by the *denominators* of the fractions you use when you blend two models together.

## The landscape and its convexity

Training a network means walking downhill on a *loss landscape*: a function $f$ that assigns to every possible setting of the weights a number measuring how badly the model performs. Weight space is $\mathbb{R}^\iota$, one coordinate for each of the $|\iota|$ weights; we measure distances in it by the largest single-coordinate discrepancy, $\|W\| = \max_i |W_i|$, because that is exactly the quantity quantization controls.

The single most consequential property a landscape can have is **convexity**. A function $f$ is convex if for any two weight settings $x, y$ and any blend $a x + b y$ with $a, b \ge 0$, $a + b = 1$,
$$f(a x + b y) \;\le\; a\, f(x) + b\, f(y).$$
In words: the loss of a mixture never exceeds the mixture of the losses. Convexity is the guarantee that there are no false valleys — every local minimum is global, gradient descent cannot get stuck, and the shape of the problem is fundamentally benign. Real transformer landscapes are not globally convex, but convexity and its quantitative cousins describe the parts where training actually happens.

So here is the sharp question. **You quantize a model. Does the landscape's convexity survive?**

## The first answer: yes, up to the covering radius

The one thing we know about $Q_\delta$ is that it does not move any weight far. Every real number is within $\delta/2$ of a grid point, so
$$|Q_\delta(x) - x| \le \delta/2 \quad\text{for all } x,$$
and applying $Q_\delta$ coordinatewise to a whole weight tensor moves it by at most $\delta/2$ in our max-norm. The number $r = \delta/2$ is the **covering radius** of the lattice: the radius of the largest ball you can hide in the grid without touching a grid point.

That single fact, combined with the assumption that the loss is $L$-Lipschitz — that changing the weights by $\varepsilon$ changes the loss by at most $L\varepsilon$, which is what a bounded gradient means — is enough to prove the fundamental transfer theorem.

> **Theorem A (Quantized Convexity Transfer).** Let $f$ be convex and $L$-Lipschitz, and let $Q$ be any map with $\|Q(x) - x\| \le r$ for all $x$. Then the quantized landscape $f \circ Q$ is convex up to an additive error $2Lr$: for all $x, y$ and all $a, b \ge 0$ with $a + b = 1$,
> $$f(Q(a x + b y)) \;\le\; a\, f(Q(x)) + b\, f(Q(y)) + 2Lr.$$

The proof is three inequalities in a row. Quantizing the blended point raises the loss by at most $Lr$; the true loss at the blended point is at most the blend of the true losses by convexity; and each of those true losses is at most the quantized loss plus $Lr$. Add them up: two units of $Lr$ survive. For the $\delta$-grid, $r = \delta/2$, so the defect is exactly $L\delta$ — one Lipschitz constant times one mesh.

Everything else about the landscape follows the same script, and the results form a small catalogue.

**No optimum is lost.** If $x_0$ is a global minimizer of the true loss, its *rounded* version $Q(x_0)$ — an actual, storable, low-precision weight setting — is within $Lr$ of optimal against every real weight setting whatsoever: $f(Q(x_0)) \le f(x) + Lr$ for all $x$. Whatever the best real model achieves, a lattice model nearly achieves.

**The optimal value is stable.** The best loss achievable over the entire lattice and the best loss achievable over all of $\mathbb{R}^\iota$ differ by at most $Lr$.

**The basin does not move.** Suppose the loss grows quadratically around its minimum, $f(x) - f(x_0) \ge \frac{\mu}{2}\|x - x_0\|^2$ — the standard consequence of $\mu$-strong convexity, and a statement about curvature. Then *any* weight $\hat w$ that is optimal within the lattice satisfies
$$\|\hat w - x_0\| \;\le\; \sqrt{2Lr/\mu}.$$
Quantization can perturb which point you land on, but it cannot relocate the valley. Note the square root: to halve the localization error you must quarter the mesh, i.e. spend one extra bit for a factor-two gain in $r$ — and then another.

**Curvature itself is preserved.** The full strong-convexity inequality, with its curvature term $-ab\frac{\mu}{2}\|x-y\|^2$, transfers to the quantized landscape with the *same* modulus $\mu$ and the same additive defect $2Lr$. Quantization is a zeroth-order perturbation; it does not flatten the bowl.

**Level sets are sandwiched.** For every threshold $c$, the sublevel set of the quantized loss is trapped between two genuinely convex sets:
$$\{f \le c - Lr\} \;\subseteq\; \{f \circ Q \le c\} \;\subseteq\; \{f \le c + Lr\},$$
and both outer sets are convex because $f$ is. Any invariant of the sublevel filtration — connectedness, star-shapedness, contractibility — survives up to a level shift of $Lr$.

## The second answer: no, and here is the bump

A cautious reader should now ask whether Theorem A says anything at all. Perhaps quantized landscapes are *exactly* convex, and the $2Lr$ is slack.

They are not. Take the simplest convex $1$-Lipschitz loss there is, $f(x) = |x|$, and quantize with mesh $\delta$. The weights $2\delta/5$ and $3\delta/5$ both round toward the grid, but in *opposite directions*: $2\delta/5 \mapsto 0$ and $3\delta/5 \mapsto \delta$. Their midpoint is exactly $\delta/2$, which sits on the rounding threshold and (by the round-half-up convention) jumps to $\delta$. So the quantized loss at the midpoint is $\delta$, while the average of the quantized losses at the endpoints is $\frac{1}{2}\cdot 0 + \frac{1}{2}\cdot\delta = \delta/2$. The convexity inequality is violated by $\delta/2$. Any valid approximate-convexity certificate must have $\varepsilon \ge \delta/2$, and in particular the quantized landscape of $|x|$ is **not convex for any positive mesh**.

So the true defect for this example lies in $[\delta/2, \delta]$, and the general bound $2Lr = \delta$ is right to within a factor of two. Where is the truth?

## The surprise: the answer depends on a denominator

The natural guess is that the factor of two is an artifact of the crude proof, and that nearest-point rounding — a much more disciplined operation than an arbitrary radius-$r$ displacement — should really give $Lr$. Two pieces of evidence encouraged this. First, for a genuinely arbitrary quantizer of radius $r$, the constant $2Lr$ is *exactly* optimal: the map that sends every weight $x$ to $x - r$ except that it sends $4r$ to $5r$ has displacement exactly $r$ everywhere, and composed with $|x|$ it has defect exactly $2r$ at the pair $(3r, 5r)$. Second — and this is the good news for practitioners — for **balanced** blends, the guess is correct:

> **Theorem (Model Soups Are Gentle).** For a convex $L$-Lipschitz loss and entrywise $\delta$-grid quantization,
> $$f\Big(Q_\delta\big(\tfrac{W + V}{2}\big)\Big) \;\le\; \tfrac{1}{2} f(Q_\delta(W)) + \tfrac{1}{2} f(Q_\delta(V)) + \tfrac{L\delta}{2},$$
> i.e. defect $L\delta/2 = Lr$, exactly half of the general bound — and this constant is attained.

The engine behind that halving is a purely arithmetic fact about rounding, and it is charming: for any two reals $X, Y$,
$$\big|\operatorname{round}(X) + \operatorname{round}(Y) - 2\operatorname{round}\big(\tfrac{X+Y}{2}\big)\big| \;\le\; 1.$$
An integer sandwiched between two half-open intervals cannot escape by more than one. In plain terms: the two endpoints and their midpoint are forbidden from rounding "in opposite directions" too aggressively at once. Averaging two quantized checkpoints — the widely used "model soup" — is provably kinder to the landscape than an arbitrary interpolation.

But the conjecture that $Lr$ holds *in general* is false, and the counterexample explains everything that follows. Take the loss $f(w) = |w - \delta|$, the distance to a target weight sitting on a grid point, and the two weights $\delta/2$ and $-\delta/2$. These round *away from each other*, to $\delta$ and to $0$. Now blend them with the badly unbalanced weights $a = 1 - 1/n$ and $b = 1/n$. The blend is $\delta/2 - \delta/n$, which sits just *below* the rounding threshold and therefore rounds **down** to $0$ — precisely where the loss is maximal. The defect works out to exactly $\delta(1 - 1/n)$, which tends to $\delta = 2Lr$ as $n$ grows. The general constant $2Lr$ is therefore exactly right, even for honest nearest-point rounding.

Stare at that formula. The defect is $\delta(1 - 1/n)$ and $n$ is the **denominator of the blending weight**. That is not a coincidence; it is a law.

> **The Denominator Law.** For a convex $L$-Lipschitz loss, $\delta$-grid quantization, and any blending weight $a = k/q$, the convexity defect is at most
> $$\Big(1 - \frac{1}{q}\Big) L \delta.$$
> Balanced blending ($q = 2$) costs $L\delta/2$; the full $L\delta$ is approached only along weights of large denominator.

The mechanism is a small piece of lattice arithmetic. All three roundings involved — of $x$, of $y$, and of $ax + (1-a)y$ — land on the lattice $\delta\mathbb{Z}$. The *discrepancy*
$$D \;=\; a\,Q_\delta(x) + (1-a)\,Q_\delta(y) - Q_\delta\big(ax + (1-a)y\big)$$
is therefore a rational combination whose denominator is $q$: it lies in the finer lattice $(\delta/q)\mathbb{Z}$. Separately, a covering-radius argument shows $|D| < \delta$ strictly. A multiple of $\delta/q$ that is strictly less than $\delta$ is at most $(1 - 1/q)\delta$. Geometry provides the strict bound; arithmetic provides the quantization of the possible values; together they pin the constant.

## The whole spectrum, and nothing but the spectrum

The story does not stop at an upper bound. One can ask exactly *which* defects are achievable at a given blending weight $k/q$, and the answer is as clean as the law that predicted it.

> **Theorem (The Defect Spectrum).** Let $\gcd(k, q) = 1$. For every residue $j$ with $0 \le j < q$ there is a convex $1$-Lipschitz loss and a pair of weights whose $\delta$-grid quantized convexity defect at blending weight $k/q$ equals **exactly** $\delta j / q$.

The achievable defects form the complete arithmetic progression
$$\frac{\delta}{q}\{0, 1, 2, \ldots, q-1\},$$
the entire lattice slice that the denominator law permits. Nothing in it is missing, and nothing outside it occurs. The proof is a covering statement in the cyclic group $\mathbb{Z}/q\mathbb{Z}$: the numerator of the discrepancy is $k \cdot (\operatorname{round}X - \operatorname{round}Y) \bmod q$, and as the integer difference $\operatorname{round}X - \operatorname{round}Y$ ranges over all of $\mathbb{Z}$, that expression sweeps out every residue class exactly when $k$ is invertible mod $q$ — which is exactly coprimality. Bézout's identity supplies the witnesses; each one is an explicit "distance to a target weight" loss and an explicit pair of weights.

Two corollaries sharpen the picture into something genuinely arithmetic.

**Only the reduced denominator matters.** For a general (not necessarily reduced) weight $k/q$, the exact maximal defect is
$$\Big(1 - \frac{\gcd(k,q)}{q}\Big)\delta,$$
which depends only on the reduced denominator $q/\gcd(k,q)$. The blending weight $2/4$ costs exactly what $1/2$ costs, and strictly less than the nearby weight $3/7$. **The convexity cost of an interpolation weight is an arithmetic invariant, not a metric one.** Two blending weights can be as close as you like in the real line and have wildly different worst-case costs, because one has denominator $2$ and the other has denominator $1000$.

**The defects are a fingerprint.** Read backwards, the exact constants become an identification theorem. The set of achievable defects determines the mesh $\delta$ of the quantizer that produced them; and at a fixed mesh, it determines the reduced denominator of the blending weight. Both are recoverable from landscape measurements alone — you can, in principle, learn the arithmetic of a quantizer by probing how badly convexity fails.

## Codebooks are torsion points

Where does the arithmetic really live? Weights are periodic in a natural sense: if a fixed-point format has dynamic range $\delta$, then the meaningful object is the **weight torus** $\mathbb{R}/\delta\mathbb{Z}$. And an $m$-level codebook — the $m$ symbols an $m$-level quantizer can emit — maps into that torus by sending the code $k$ to the weight $k\delta/m$.

This map is injective (no precision is wasted; distinct codes name distinct weights), and its image is not merely *contained in* the $m$-torsion subgroup of the torus — it is *exactly* the $m$-torsion:
$$\{\text{codes of an } m\text{-level quantizer}\} \;=\; \{x \in \mathbb{R}/\delta\mathbb{Z} : m x = 0\}.$$
Quantized weights are precisely the arithmetic points of the weight torus. There are exactly $m$ of them; a weight tensor with $|\iota|$ entries has exactly $m^{|\iota|}$ codes. Refining precision from $m$ to a multiple $m'$ enlarges the torsion subgroup by exactly the index $m'/m$. And coprime precisions split: by the Chinese Remainder Theorem, an $mn$-level codebook with $\gcd(m,n)=1$ decomposes canonically as the product of an $m$-level and an $n$-level codebook, giving a mixed-precision scheme a clean arithmetic meaning.

The union of all finite codebooks is the full torsion subgroup of the torus — an avatar of $\mathbb{Q}/\mathbb{Z}$ — and it is **dense**. That density is the arithmetic reason the whole enterprise works: the tower of finite codebooks sees all of weight space in the limit.

For a $b$-bit uniform quantizer of dynamic range $\delta$, the mesh is $\delta/2^b$ and the transfer theorem reads
$$\text{defect}(b) \;=\; \frac{L\delta}{2^b},$$
so each additional bit halves the convexity defect while doubling the codebook — a conserved scaling law, $\text{defect}(b)\cdot 2^b = L\delta$, independent of the bit width. Going from INT8 to INT4 costs you exactly sixteen times the convexity defect. That is a design rule, not a heuristic.

## The reverse direction: certifying convexity from finite data

The most striking consequence runs backwards. Everything above sends information from the continuous landscape down to the quantized one. But the transfer is *two-sided*: if the quantized landscape at a single precision is $\varepsilon$-approximately convex, then the true continuous loss is $(\varepsilon + 2Lr)$-approximately convex. Certificates travel in both directions with the same toll of $2Lr$.

Push the precision to infinity and the toll vanishes.

> **Theorem (Reverse Transfer).** Let $f$ be $L$-Lipschitz and let $Q_1, Q_2, \ldots$ be a tower of quantizers whose covering radii tend to $0$ — for instance, the grids of mesh $\delta/m$ along a divisibility tower. If the quantized landscape $f \circ Q_m$ is $\varepsilon_m$-approximately convex with $\varepsilon_m \to 0$, then $f$ is **exactly convex**.

This is a genuine converse, and it changes the epistemic status of convexity. Convexity of a real-valued landscape over a continuum of real weight settings is, on its face, an uncountable assertion — untestable. The reverse transfer theorem says it is *certifiable from finite, quantized data*: measure the convexity defect of your model at a sequence of shrinking precisions, watch those defects go to zero, and you have proved exact convexity of the underlying continuous landscape. Every measurement in that argument is a computation on integers.

## What it all means

The picture that emerges has three layers, and they interlock.

The **analytic** layer says quantization is a bounded perturbation: every convexity invariant of a Lipschitz loss landscape — the convexity inequality, the curvature modulus, the optimal value, the location of the basin, the shape of the sublevel filtration — survives quantization with a distortion controlled by the covering radius alone, and vanishing as the radius does.

The **arithmetic** layer says the codebook is not an arbitrary finite set but the torsion subgroup of a circle, with all the structure that implies: a divisibility tower with exact indices, a Chinese Remainder decomposition for mixed precision, a density theorem in the limit, and a bit-width scaling law that is exactly conserved.

The **spectral** layer, where the two meet, is the surprise. The exact loss of convexity is not governed by how *big* the rounding error is. It is governed by the *denominator* of the blending weight, in lowest terms; the achievable defects form a complete arithmetic progression $\frac{\delta}{q}\{0, \ldots, q-1\}$; and that spectrum is a fingerprint from which the mesh and the reduced denominator can both be read off.

There is a practical moral for anyone who blends models. Averaging with weight $1/2$ costs $L\delta/2$; blending with $0.37$, whose denominator is $100$, costs $0.99\,L\delta$ — twice as bad, though the two operations look identical to the eye. If you must blend unevenly, blend with a small denominator: use $1/3$, not $33/100$.

And there is a broader moral. We are used to thinking of neural networks as objects of analysis — gradients, norms, continuity, measure. Quantization forces integers into the picture, and once integers are in the picture, number theory has jurisdiction. The finite codebook is a torsion group. The rounding error is a lattice point. The convexity defect is a residue class. The mesh and the denominator are recoverable invariants. A pipeline built entirely for engineering reasons turns out to be arithmetic geometry in disguise — and the arithmetic, once you look, predicts things the engineering could not.
