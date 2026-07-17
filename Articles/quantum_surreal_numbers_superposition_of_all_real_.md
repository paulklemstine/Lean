# When Infinity Enters the Laboratory: What Quantum-Surreal Measurement Really Sees

Imagine a number line that does not stop at the real numbers. Between zero and every positive real number lie positive infinitesimals: quantities greater than zero yet smaller than $1/n$ for every ordinary positive integer $n$. Beyond every real number lie infinite quantities. Conway’s surreal numbers organize all of these—ordinary reals, infinitesimals, and infinities—inside a single ordered arithmetic universe.

Now imagine using such numbers as labels for the possible outcomes of a quantum experiment. A state might be written

$$
|\psi\rangle=\sum_i \alpha_i|s_i\rangle,
$$

where each $s_i$ is a surreal number and each $\alpha_i$ is an amplitude. This creates an evocative picture: a quantum system suspended across zero, finite values, infinitesimals, and perhaps even infinities. But the picture raises a deceptively simple question. If one possible outcome is labelled by an infinitesimal $\varepsilon$, does that make the outcome itself nearly impossible to observe?

The answer is no. The central lesson is a separation of roles: **labels say what an outcome is; amplitudes say how likely it is**. An infinitesimal label is not the same thing as an infinitesimal amplitude.

## Two kinds of number in one quantum state

For a finite state, the basis vectors $|s_i\rangle$ are assumed orthogonal when their labels are distinct. The squared norm is therefore

$$
\|\psi\|^2=\sum_i |\alpha_i|^2.
$$

The exact Born weight of branch $i$ is

$$
w_i=\frac{|\alpha_i|^2}{\sum_j|\alpha_j|^2}.
$$

Notice what does not occur in this formula: the magnitude of $s_i$. The label could be $0$, $10^{100}$, an infinitesimal, or an infinite surreal number. Provided it identifies an orthogonal branch, its numerical size does not multiply the probability.

To connect a non-Archimedean amplitude system with ordinary observations, introduce the **standard-part map**. For every finite non-Archimedean number $x$, its standard part $\operatorname{st}(x)$ is the unique real number infinitely close to $x$. Thus

$$
\operatorname{st}\!\left(\frac12+\delta\right)=\frac12
$$

whenever $\delta$ is infinitesimal, while a positive infinitesimal itself satisfies

$$
\operatorname{st}(\delta)=0.
$$

The observed probability is then

$$
p_i=\operatorname{st}(w_i),
$$

whenever the exact weight is finite.

This map acts on the **weight**, not on the label.

## The equal-amplitude obstruction

Consider two distinct surreal labels $s\neq t$ and a common nonzero amplitude $a$. Form the state

$$
|\psi\rangle=a|s\rangle+a|t\rangle.
$$

Orthogonality gives

$$
\|\psi\|^2=a^2+a^2=2a^2.
$$

Each exact Born weight is consequently

$$
\frac{a^2}{2a^2}=\frac12.
$$

Taking standard parts changes nothing, because $1/2$ is already real. We obtain the **Equal-Amplitude Theorem**: for two distinct surreal-labelled branches carrying the same nonzero amplitude, both observed probabilities equal $1/2$, regardless of the arithmetic size or infinitesimal status of either label.

Now choose $s=0$ and $t=\varepsilon$, where $\varepsilon$ is a nonzero infinitesimal surreal. The state

$$
|\psi\rangle=\frac{1}{\sqrt2}|0\rangle+\frac{1}{\sqrt2}|\varepsilon\rangle
$$

has probability $1/2$ at zero and probability $1/2$ at $\varepsilon$. The infinitesimal-labelled outcome is not hidden at all. It appears in half the trials.

This calculation exposes the flaw in a tempting alternative formula that assigns the second branch a weight resembling $\tfrac12\varepsilon^2$. That expression quietly multiplies amplitude mass by the square of the label. Standard quantum measurement does no such thing. The ket $|\varepsilon\rangle$ names a coordinate; it is not the scalar $\varepsilon$ multiplying that coordinate.

A familiar analogy helps. In a spin experiment, calling outcomes $+1$ and $-1$ does not force their probabilities to be proportional to $1^2$ and $(-1)^2$. Nor would relabelling them $1000$ and $10^{-1000}$ alter the apparatus. Labels identify detector channels. Amplitudes govern the traffic through those channels.

## Where infinitesimals really can disappear

Infinitesimal unobservability is nevertheless possible. It happens when the **amplitude weight** is infinitesimal.

Suppose a normalized two-branch state has exact weights

$$
w_0=1-\eta,
\qquad
w_1=\eta,
$$

where $\eta>0$ is infinitesimal. The exact model remembers both branches and preserves normalization:

$$
w_0+w_1=1.
$$

But ordinary observation takes standard parts:

$$
p_0=\operatorname{st}(1-\eta)=1,
\qquad
p_1=\operatorname{st}(\eta)=0.
$$

The observed probabilities still sum to one. The second branch disappears because its normalized squared amplitude has zero standard part—not because of its name.

This gives the **Infinitesimal-Amplitude Collapse Principle**: in a finite normalized state, a branch with infinitesimal exact Born weight has observed probability zero under standard-part observation. The exact and observed descriptions answer different questions. The exact distribution retains sub-real distinctions; the observed distribution records the ordinary real shadow visible at finite resolution.

The principle resembles many coarse-graining procedures in physics. Microscopic corrections may be indispensable to an exact model while vanishing at the scale of an instrument. Standard part is an idealized resolution threshold: it preserves every appreciable real component and discards purely infinitesimal residue.

## A discrete mirror

The same pattern appears without amplitudes. Consider a finite sample space with one distinguished ordinary atom of mass $1$ and several “visible” atoms each carrying a formal infinitesimal mass. A convenient lexicographic weight records a pair

$$
(r,k),
$$

where $r$ is ordinary mass and $k$ counts an infinitesimal contribution. Addition is componentwise, but the standard part keeps only the ordinary coordinate:

$$
\operatorname{st}(r,k)=r.
$$

Arrange the finite model so that the total probability has standard part $1$. Then the whole sample space has observed mass $1$, while every individual atom carrying only infinitesimal mass has observed mass $0$.

This is the **Finite Discrete Collapse Theorem**: for every finite lexicographic infinitesimal probability model of this form, the standard part of total mass is $1$, and the standard part of each purely infinitesimal atom is $0$.

The amplitude model and the discrete model are built differently, yet their observational signatures coincide. Both preserve exact infinitesimal information; both send an individual purely infinitesimal weight to zero; and both retain ordinary normalization at the finite level. This bridge suggests that standard part is not merely a trick tied to one representation. It is a general passage from a fine non-Archimedean probability space to its real-valued observable shadow.

## Relabelling cannot change a detector count

The two-branch formula also proves a useful invariance. Swapping $s$ and $t$ merely exchanges coordinate names:

$$
a|s\rangle+a|t\rangle=a|t\rangle+a|s\rangle.
$$

Both probabilities remain $1/2$. More generally, the Born weights of a finite state follow amplitudes under a permutation of labels. A branch does not become rare because its new label lies closer to zero, farther into infinity, or earlier in the construction of the surreal numbers.

This invariance is more than aesthetic. It is a consistency test for any proposed quantum-surreal measurement rule. If changing labels while holding amplitudes fixed changes detector statistics, the rule has confused the spectrum’s names with the state’s mass distribution.

## A practical calculation pipeline

The mathematics suggests a simple measurement procedure for finite states:

1. Combine amplitudes attached to identical labels.
2. Compute each squared amplitude $|\alpha_i|^2$.
3. Sum them to obtain the squared norm $Z=\sum_i|\alpha_i|^2$.
4. Require $Z\neq0$, and normalize to $w_i=|\alpha_i|^2/Z$.
5. Apply standard part to each finite weight: $p_i=\operatorname{st}(w_i)$.
6. Report labels together with their observed probabilities.

The order matters. One must combine coincident labels before squaring, because amplitudes interfere. One must also normalize before taking standard parts: an amplitude can be infinitesimal while its normalized weight is appreciable if every branch is scaled by the same infinitesimal factor.

For example, multiplying both amplitudes in an equal pair by a common nonzero infinitesimal $\delta$ produces exact weights

$$
\frac{\delta^2}{2\delta^2}=\frac12.
$$

A tiny global scale cancels. Visibility depends on relative normalized weights.

## Why the correction matters

The distinction also changes how one should design an experiment. Suppose a detector has two channels, one calibrated to display $0$ and the other calibrated to display an infinitesimal $\varepsilon$. If the incoming state gives both channels equal amplitude, repeated trials approach a fifty–fifty frequency split. Reprinting the second channel’s screen with a smaller numeral cannot alter those frequencies. To suppress the second count, one must modify the state preparation so that its normalized squared amplitude becomes infinitesimal.

This separates three layers that are often blended together. The **outcome space** lists possible labels. The **state** assigns amplitudes to the corresponding orthogonal coordinates. The **observation map** converts finite exact weights to real probabilities by standard part. Surreal arithmetic enriches the first layer; non-Archimedean amplitudes enrich the second; standard part links the third to ordinary statistics. A sound model must say explicitly which layer contains each infinitesimal.

There is also a conceptual gain. Zero observed probability need not mean exact impossibility. An infinitesimal-weight branch can remain present in the fine model even though its standard probability is zero. Conversely, an infinitesimal-labelled branch can have positive, even dominant, observed probability. Thus the framework distinguishes logical absence, infinitesimal mass, and an infinitesimal numerical outcome—three notions that ordinary real-valued language can make easy to confuse.

## The horizon beyond finite states

Finite systems behave cleanly, but infinity reopens the story. Imagine a hyperfinite collection of branches, each with an infinitesimal exact weight, whose total exact mass is $1$. Branch by branch, standard part gives zero; summed first, the standard part gives one. Symbolically, the danger is

$$
\sum_i \operatorname{st}(w_i)=0
\qquad\text{while}\qquad
\operatorname{st}\!\left(\sum_i w_i\right)=1.
$$

Finite additivity prevents this mismatch for an ordinary finite number of terms. An unlimited number of terms can defeat termwise passage to standard parts unless an additional tightness or uniformity condition controls the tail.

That boundary points toward deeper questions: a spectral theory over non-Archimedean fields, a standard-part functor for finite probability spaces, and a precise criterion for which branches remain visible. But the foundation is already sharp.

A surreal outcome may be infinitesimal, yet perfectly observable. An ordinary-looking outcome may be unobservable if its amplitude weight is infinitesimal. Quantum probability does not ask how large the label is. It asks how much normalized amplitude stands behind it.

That distinction—between the name on the door and the probability of walking through it—is the key to bringing infinitesimals into measurement without losing the logic of quantum mechanics.
