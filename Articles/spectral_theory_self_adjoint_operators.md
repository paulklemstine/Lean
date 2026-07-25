# The Quarter-Modulus Safety Margin: Why Noisy Arithmetic Can Still Be Trusted

A secure message can survive noise for the same reason a well-designed railway junction can survive a small positioning error: the possible destinations are separated by a generous gap. If a switch is meant to point left or right, a tiny vibration does not matter provided it cannot push the mechanism across the midpoint. Modern lattice-based cryptography turns this geometric intuition into arithmetic. It deliberately adds error to conceal secret information, yet arranges the encoding so that legitimate decryption remains reliable.

The setting is Learning with Errors, or LWE. Its basic samples look like linear equations whose right-hand sides have been perturbed. Without perturbation, enough equations reveal the secret through ordinary linear algebra. With a carefully chosen small error, recovering the secret appears computationally difficult. This tension—error large enough to hide structure, but small enough to preserve meaning—is the heart of the construction.

The results developed here isolate the elementary algebra and inequalities that make this tension manageable. They show that invertible affine transformations preserve uniformity over a prime finite field; that many bounded errors accumulate at most linearly; that two noisy bit encodings remain separated when each error is smaller than one quarter of the modulus; that a hybrid argument loses at most a factor equal to the secret dimension; and that modulus switching and repetition obey clean quantitative bounds.

## A finite world that can be shuffled without bias

Fix a prime number $p$. Arithmetic modulo $p$ forms a field, denoted here by $\mathbb{Z}_p$. Every nonzero element $a$ has a multiplicative inverse. Consequently, the affine map

$$
x \longmapsto ax+b
$$

is a permutation of $\mathbb{Z}_p$ whenever $a\ne 0$.

This simple fact is cryptographically potent. Imagine drawing $x$ uniformly from all residues modulo $p$. Applying any permutation merely rearranges those residues, so $ax+b$ is still uniform. No residue becomes more likely than another. The inverse transformation is explicit:

$$
y \longmapsto a^{-1}(y-b).
$$

Two affine transformations also compose to another affine transformation. If the first is $x\mapsto a_2x+b_2$ and the second is $x\mapsto a_1x+b_1$, their composition is

$$
x\longmapsto (a_1a_2)x+(a_1b_2+b_1).
$$

This closure makes affine rerandomization easy to analyze. It also yields a useful averaging identity: for every real-valued function $f$ on $\mathbb{Z}_p$,

$$
\sum_{x\in\mathbb{Z}_p} f(ax+b)=\sum_{x\in\mathbb{Z}_p}f(x).
$$

The proof is no more than relabeling a finite sum along a permutation. In security reductions, however, that relabeling explains why a transformed wrong guess can look exactly uniform rather than merely approximately uniform.

## The arithmetic of accumulated noise

Encryption procedures often combine many samples. Their errors therefore add. Suppose $e_1,\ldots,e_m$ are integers or real numbers, and each satisfies $|e_i|\le B$. The triangle inequality gives the noise accumulation bound

$$
\left|\sum_{i=1}^{m}e_i\right|\le \sum_{i=1}^{m}|e_i|\le mB.
$$

If only a subset $S$ of the errors is selected, the sharper statement is

$$
\left|\sum_{i\in S}e_i\right|\le |S|B.
$$

These bounds are worst-case guarantees. Random errors may cancel, and probabilistic analysis can produce much tighter typical estimates. But worst-case bounds provide something probability alone cannot: a deterministic safety certificate. If the maximum possible accumulated error remains inside the decoding region, every allowed execution decrypts correctly.

## Two bits, half a modulus apart

Take a positive real modulus $q$. Represent bit $0$ near $0$ and bit $1$ near $q/2$. An error $e$ changes the transmitted representative. For bit $0$, the received value is $e$; for bit $1$, it is $q/2+e$.

The decisive threshold is $q/4$. If

$$
|e|<\frac q4,
$$

then the noisy zero lies strictly between $-q/4$ and $q/4$. The noisy one lies strictly between $q/4$ and $3q/4$:

$$
\frac q4<\frac q2+e<\frac{3q}{4}.
$$

Thus the two decoding regions do not overlap. The requirement $q>0$ is essential: it makes the phrase “one quarter of the modulus” a genuine positive error budget.

The separation can be expressed even more directly. Let $e$ perturb the zero codeword and let $e'$ perturb the one codeword. If both satisfy $|e|<q/4$ and $|e'|<q/4$, then

$$
\frac q2-|e|-|e'|>0.
$$

So even after allowing both points to move toward one another by their full error magnitudes, a positive gap remains. This is the quarter-modulus safety margin.

There is also a compact correctness statement valid for any real message multiplier $\mu$. The received value $\mu(q/2)+e$ differs from its intended center by exactly $|e|$:

$$
\left|\mu\frac q2+e-\mu\frac q2\right|=|e|<\frac q4.
$$

For encrypted bits, $\mu$ is usually $0$ or $1$. Writing the identity more generally exposes the true reason for correctness: translation by a codeword center does not change the magnitude of the error.

## Modulus switching: budgeting a second source of error

Cryptographic systems often change moduli to improve efficiency or fit different stages of a computation. Rounding during such a change creates additional error. Suppose an original error has magnitude at most $B$, and $n$ rounding coordinates each contribute an error of magnitude at most $\delta$. Their combined disturbance obeys

$$
\left|e_{\mathrm{LWE}}+\sum_{i=1}^{n}r_i\right|
\le B+n\delta.
$$

The proof combines the triangle inequality with the linear accumulation bound. It immediately gives a decryption criterion: if

$$
B+n\delta<\frac q4,
$$

then the post-switching error is still below the quarter-modulus threshold. This turns system design into an explicit budget. The original noise consumes $B$ units, rounding consumes at most $n\delta$, and their total must fit inside $q/4$.

## From a global distinguisher to one useful coordinate

A search-to-decision reduction asks whether an algorithm that merely distinguishes structured samples from random ones can help recover a hidden secret. A standard path changes the secret one coordinate at a time and compares adjacent hybrid distributions.

Suppose there are $n>0$ coordinates, the total distinguishing gap is at least $\varepsilon$, and the coordinate gaps are $g_1,\ldots,g_n$ with

$$
\varepsilon\le \sum_{i=1}^{n}g_i.
$$

Then at least one coordinate satisfies

$$
g_i\ge \frac{\varepsilon}{n}.
$$

Otherwise every $g_i$ would be strictly smaller than $\varepsilon/n$, forcing their sum below $\varepsilon$. This pigeonhole argument quantifies the price of moving from a global signal to a single coordinate: the guaranteed advantage can shrink by a factor of $n$.

The affine-permutation theorem complements this argument. Over a prime modulus, multiplying by a nonzero residue and translating preserves uniformity. That algebraic invariance is what allows wrong coordinate guesses in the reduction to be rerandomized into uniform-looking samples.

## Repetition and parameter tradeoffs

If one trial succeeds with probability $p$, then $k$ independent trials fail together with probability $(1-p)^k$. The probability of at least one success is therefore

$$
1-(1-p)^k.
$$

For $0\le p\le1$ and every positive integer $k$, this is at least $p$. Repetition never reduces the chance of success, and for nontrivial $p$ it generally improves it.

A final inequality records a common modulus-noise tradeoff. For $n\ge0$ and $q>0$, if a noise-rate parameter $\alpha$ satisfies

$$
\alpha\ge \frac{2\sqrt n}{q},
$$

then multiplying by the positive modulus gives

$$
\alpha q\ge 2\sqrt n.
$$

The statement is elementary, but its design message is useful: changing $q$ changes which values of $\alpha$ meet a target product. Security and correctness constraints often pull these parameters in different directions, so explicit inequalities prevent informal intuition from hiding an impossible combination.

## Why strict boundaries matter

A safety margin is most useful when it tells us not only what works, but exactly where certainty ends. If an error reaches $q/4$, a point may sit precisely halfway between the two codeword centers. At that boundary, “choose the nearer center” no longer determines a unique answer. The strict hypothesis $|e|<q/4$ excludes this ambiguity. Likewise, requiring a positive modulus is not ceremonial notation: inequalities reverse when multiplied by negative quantities, and a negative “radius” cannot describe a decoding neighborhood.

This attention to hypotheses is part of the engineering lesson. A theorem becomes a reliable component only when its input contract is explicit. Prime moduli guarantee that every nonzero multiplier is invertible. Bounded errors guarantee an additive budget. Positive dimensions make averaging meaningful. Independence justifies multiplying failure probabilities. Each condition guards a specific step, and removing one changes what can honestly be promised.

Seen this way, noisy cryptography is a discipline of controlled transformations. Information may be shuffled, combined, rounded, tested coordinate by coordinate, and repeated—but at each transition an invariant survives: uniformity, a magnitude bound, a positive gap, or a quantified probability. Those invariants are the rails that guide a secret safely through deliberate noise.


## A coherent engineering picture

Taken together, the results form a compact pipeline. Prime-field affine maps provide exact, bias-free rerandomization. Triangle inequalities control how noise grows under combination. Quarter-modulus intervals provide disjoint decoding zones. Hybrid averaging identifies a coordinate carrying a detectable fraction of the total signal. Modulus switching receives an additive error budget, and repetition converts a weak chance of success into a stronger one.

None of these ingredients is mysterious in isolation. Their power comes from fitting together without gaps. Cryptography routinely builds elaborate security claims from familiar mathematics—field inverses, finite permutations, the triangle inequality, and the pigeonhole principle. The art lies in choosing representations whose margins remain visible at every stage.

The quarter-modulus rule is the clearest emblem of that art. Noise is not merely tolerated after the fact; it is assigned a region in advance. Correctness becomes geometry on a circle of residues: place the two codewords half a modulus apart, allow each less than a quarter-modulus of movement, and the territories remain disjoint. Secure computation begins not by eliminating uncertainty, but by drawing boundaries that uncertainty cannot cross.
