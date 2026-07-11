# Can a Mind Be Encoded? The Arithmetic of Digital Immortality

Imagine standing in front of a machine that promises to make you immortal. It will scan your brain, capture every neuron and every connection between them, and store the resulting "you" as a file. From then on, the reasoning goes, you could be copied, backed up, and reawakened forever. It is one of the oldest dreams of science fiction and one of the boldest promises of futurism.

But before we ask whether such a machine could ever be *built*, there is a more basic question a mathematician can answer today: **how big is a mind?** Not in kilograms, but in *bits*. How much information does it take, at minimum, to write down the wiring diagram of a brain — and does the universe even allow enough room to store it?

The surprising answer is that we can pin down these numbers precisely, and they lead to hard, unavoidable limits. A mind is not infinite, but it is *incompressibly large*, and the very laws of physics place a ceiling on how many neurons any physical archive can ever hold. This article walks through the arithmetic.

## A brain as a wiring diagram

Strip a brain down to its mathematical skeleton and you are left with a **connectome**: a list of neurons and a record of which pairs are connected. If we have $N$ neurons, then every *unordered pair* of them is a potential synapse — a slot that is either "wired" or "not wired."

How many such slots are there? Exactly the number of ways to choose $2$ neurons out of $N$:
$$\text{slots}(N) = \binom{N}{2} = \frac{N(N-1)}{2}.$$

For a tiny cluster of $5$ neurons this is $\binom{5}{2} = 10$ slots. For the human brain, with its roughly $86$ billion neurons, the number is astronomically larger — but the formula is the same, and its exact quadratic growth is the engine behind everything that follows.

A specific brain, then, is just a choice for each slot: connected or not. That is one bit per slot. So the set of *all possible* connectomes on $N$ neurons — the space of all minds that could be written on that many neurons — has size
$$2^{\binom{N}{2}}.$$

For our $5$-neuron toy brain that is $2^{10} = 1024$ possible minds. The number climbs with breathtaking speed: because the exponent grows like $N^2$, doubling the neurons doesn't double the number of minds — it *squares* it.

## Weighted synapses, one-way streets, and merged brains

Real synapses are not simple on/off switches. They have strengths. If we allow each slot to take one of $w$ distinct weight levels instead of just two, the count of distinguishable minds becomes
$$w^{\binom{N}{2}}.$$

The Boolean case is just $w = 2$. Storing strengths, not merely topology, costs $\binom{N}{2}\log_2 w$ bits instead of $\binom{N}{2}$.

Synapses also point in a direction: neuron $A$ influencing neuron $B$ is not the same as $B$ influencing $A$. If we track direction, each of the two orderings of a pair gets its own slot, so the number of directed slots is
$$N(N-1) = 2\binom{N}{2},$$
exactly *twice* the undirected count. Doubling the exponent has a dramatic effect: the number of directed minds is
$$2^{N(N-1)} = \left(2^{\binom{N}{2}}\right)^{2},$$
the **square** of the number of undirected minds. Adding directionality does not add a little detail; it squares the size of the space of possible selves.

There is an equally striking arithmetic when two minds *merge*. Suppose you fuse an $M$-neuron brain with an $N$-neuron brain. The combined brain has more slots than the two brains had separately — because now neurons in one brain can connect to neurons in the other. The exact bookkeeping is:
$$\binom{M+N}{2} = \binom{M}{2} + \binom{N}{2} + M\cdot N.$$

The first two terms are the internal wiring the two brains brought with them. The last term, $M\cdot N$, counts the brand-new *cross-connections* between the two hemispheres of the fused mind — one for every pair of neurons drawn from different brains. Merging is **superadditive**: the whole has strictly more capacity for wiring than the sum of its parts, and the surplus $M\cdot N$ is exactly the combinatorial "interface" between them.

## Most minds cannot be compressed

Here is where the dream of a compact "soul file" runs into trouble. Enthusiasts often imagine that a mind, once digitized, could be squeezed down — that beneath the messy biology there is a short, elegant description. Information theory says otherwise, and the argument is a clean counting puzzle.

Suppose we invent *any* scheme that assigns to each connectome a distinct code — a whole number acting as its compressed address. "Distinct" is the only assumption: two different minds must get two different codes, otherwise we could never tell them apart when decoding. A good compression is one whose code is a *small* number (a short description).

Now ask: how many minds can possibly receive a small code, say a code below some cutoff $B$? The answer is immediate. There are only $B$ whole numbers below $B$, so at most $B$ minds can be assigned to them:
$$\#\{\text{minds with code} < B\} \le B.$$

This is nothing more than the **pigeonhole principle** — you cannot fit more than $B$ distinct pigeons into $B$ holes. But its consequence is devastating for compression. Since there are $2^{\binom{N}{2}}$ minds in total, the number that *fail* to get a small code is at least
$$2^{\binom{N}{2}} - B.$$

Choose the cutoff to be a full half of the description length — take $B = 2^{\binom{N}{2}-1}$ — and you find that **at least half of all possible minds cannot be compressed below their raw slot count at all.** No cleverness in the encoding changes this; the bound holds for *every* distinct code simultaneously. The overwhelming majority of minds are, in the precise language of information theory, **incompressible**. There is no universal shortcut. For almost every mind, the wiring diagram *is* the shortest description of itself.

## Does the universe have enough room?

We have established that a mind of $N$ neurons demands about $\binom{N}{2}$ bits — a number growing with the *square* of the neuron count. The final question is physical, not mathematical: **can any region of space actually hold that many bits?**

Remarkably, physics answers with a hard "no, beyond a point." The **Bekenstein bound** is a deep result from the study of black holes and thermodynamics stating that any physical region of radius $R$ containing total energy $E$ can encode at most a finite amount of information:
$$I \le \frac{2\pi R E}{\hbar\, c\, \ln 2} \text{ bits},$$
where $\hbar$ is the reduced Planck constant and $c$ the speed of light. This is not an engineering limitation about today's hard drives — it is a ceiling written into the fabric of spacetime. Pack in more information and the region collapses into a black hole.

Now combine the two facts. A mind needs at least $\binom{N}{2}$ bits, and a region can hold at most $I$ bits. If the mind is to fit, we need $\binom{N}{2} \le I$. Using the exact identity $2\binom{N}{2} = N(N-1) \ge (N-1)^2$, a short calculation converts this storage requirement into a direct ceiling on the number of neurons:
$$(N-1)^2 \le 2I, \qquad\text{hence}\qquad N \le 1 + \sqrt{2\,I}.$$

This is the punchline. **The number of neurons whose complete connectome can be physically stored in a given region is capped at $1 + \sqrt{2I}$**, where $I$ is that region's Bekenstein capacity. Because the mind's information content grows quadratically while the storage grows only linearly with the region's size and energy, there is a definite, computable limit to how large a mind you can archive in any finite chunk of the universe. Immortality, if it is bounded by physics, is bounded by a square root.

## What the numbers really say

None of this proves that mind uploading is impossible. What it does is replace hand-waving with arithmetic. Three lessons emerge, each a theorem rather than a hope.

First, **the space of possible minds is unfathomably vast**, growing as $2^{\binom{N}{2}}$ — and richer variants (weighted strengths, directed connections, merged brains) enlarge it further in precise, predictable ways: multiplying, squaring, and adding cross-terms.

Second, **almost no mind can be meaningfully compressed.** The elegant, tiny "soul file" is a fantasy for all but a vanishing minority of possible minds. If you want to store a typical mind faithfully, you must essentially store the whole wiring diagram.

Third, **physics imposes a real ceiling.** The Bekenstein bound turns "how big can a mind be?" into a concrete inequality, $N \le 1 + \sqrt{2I}$, tying the maximum neuron count to the energy and size of your archive.

The dream of encoding a mind is, at heart, a question about information — and information, it turns out, obeys strict and beautiful laws. Whether or not we ever build the machine, we already know the shape of the mountain it would have to climb. It is quadratic on the way up, incompressible near the summit, and capped by the geometry of space itself.
