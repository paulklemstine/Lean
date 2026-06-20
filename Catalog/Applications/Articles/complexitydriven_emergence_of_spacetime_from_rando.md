# The Shape of Information: How Spacetime Emerges from a Code

## A geometry hiding inside a ledger

Imagine you keep a meticulous ledger. For every region of a boundary — think of it as the outer skin of some space — you record a single number: how much *information* lives there. Not what the information says, just how much of it there is. You might expect such a ledger to be a flat, lifeless accounting document. Instead, something astonishing happens. If you look closely at how the numbers in the ledger fit together, a *geometry* appears — distances, areas, even curvature — as if a hidden landscape were folded inside the bookkeeping.

This is not a fairy tale. It is the central intuition behind one of the most provocative ideas in modern physics: that **spacetime is a kind of error-correcting code**. The fabric of the universe, in this picture, is not fundamental. It is *emergent* — a large-scale, smooth-looking shadow cast by an underlying web of quantum information. The branch of physics called holography makes this precise through the idea that what happens deep inside a region of space (the "bulk") is fully encoded on its boundary, the way a hologram stores a 3D scene on a 2D film.

In this article we make a small but completely rigorous corner of that grand vision concrete. We will build, from scratch, a finite mathematical object — a kind of toy universe — in which "information" and "geometry" are two names for the same thing. And we will prove, with no hand-waving, three facts that physicists usually state as deep principles:

1. **Curvature is nonnegative** — a precise inequality forces our toy geometry to bend only one way.
2. **A quantum-information law (strong subadditivity) is *equivalent* to a geometric law (area submodularity)** once you accept a single bridge formula.
3. **The bulk can be reconstructed from the boundary**, and this reconstruction only gets *easier* as you look at more of the boundary.

Everything below is a faithful retelling of mathematics that has been checked down to its logical bedrock. Where physicists rely on intuition, we will have theorems.

## The dictionary: entropy, area, and the magic factor of four

Let us set the stage. Our "universe" has a boundary made of finitely many pieces — call them sites. A **region** is just a subset $X$ of those sites. To each region we attach three numbers:

- an **entropy** $S(X)$ — how much information that region carries,
- an **area** $\mathrm{area}(X)$ — the size of the surface needed to wall the region off,
- a **distance** proxy $\mathrm{dist}(X)$ — a measure of how hard the region is to disturb.

These are not arbitrary. They obey a handful of natural rules that any sensible information–geometry ledger must satisfy. The empty region has no entropy and no area: $S(\varnothing) = 0$ and $\mathrm{area}(\varnothing) = 0$. All three quantities are nonnegative. Entropy never exceeds the number of sites in a region: $S(X) \le |X|$. And — most importantly — two structural laws tie everything together.

The first is the famous **Ryu–Takayanagi relation**, the beating heart of holography. It says that entropy and area are literally proportional, with a universal constant:
$$ S(X) = \frac{\mathrm{area}(X)}{4}. $$
That factor of $4$ is not a typo or a convenience. In real physics it is $4G$, where $G$ is Newton's gravitational constant — the same constant that governs how apples fall and planets orbit. Here we have normalized it to $4$. The message is breathtaking: *the amount of information in a region equals the area of the surface bounding it.* Information is not stored in a volume, the way bits sit in a hard drive. It is stored on a surface, like ink on a page.

The second law is **strong subadditivity**, the deepest known inequality of quantum information. In our ledger it takes the form of **submodularity**: for any two regions $X$ and $Y$,
$$ S(X) + S(Y) \ \ge\ S(X \cap Y) + S(X \cup Y). $$
Read aloud: the information in two overlapping regions, counted separately, is at least the information in their shared core plus the information in their combined whole. Overlap "double counts" something, and submodularity is the precise statement that the double counting goes one way and not the other.

That is the entire setup. From these axioms — and nothing else — geometry pours out.

## Curvature, defined as a failure to add up

Here is the conceptual leap. In ordinary life, when you measure two things and combine them, you expect the measurements to add cleanly. When they *don't* add cleanly, something is interacting. We turn that failure into a number. Define the **syndrome defect** of two regions:
$$ \mathrm{defect}(X, Y) \ =\ S(X) + S(Y) - S(X \cap Y) - S(X \cup Y). $$
The word "syndrome" is borrowed from coding theory, where a syndrome is the telltale signature of an error. Here the defect measures how far the entropy ledger is from adding up perfectly across the pair $(X, Y)$.

And now the punchline, our **first theorem**:
$$ \mathrm{defect}(X, Y) \ \ge\ 0 \qquad \text{always.} $$
This is immediate from strong subadditivity — but its *meaning* is profound. The defect is a discrete stand-in for **curvature**. Zero defect means the geometry is flat in that direction; the ledger adds up perfectly, regions don't interact. Positive defect means the geometry *bends*. And our theorem says it can only ever bend one way: curvature is nonnegative. In a slogan: **gravity is the shadow of information that refuses to subtract cleanly.**

We can say even more. If the defect is *strictly* positive, then
$$ S(X \cap Y) + S(X \cup Y) \ <\ S(X) + S(Y), $$
a strict inequality — the regions genuinely interact, the geometry genuinely curves. And the defect behaves exactly the way curvature should: a region has no curvature with itself ($\mathrm{defect}(X,X) = 0$), curvature between two regions doesn't depend on which you name first ($\mathrm{defect}(X,Y) = \mathrm{defect}(Y,X)$), and an empty region contributes no curvature anywhere ($\mathrm{defect}(\varnothing, Y) = 0$).

## The bridge: when an information law *becomes* a geometry law

So far we have phrased everything in the language of information (entropy). But the Ryu–Takayanagi relation lets us translate every statement into the language of geometry (area). What happens when we do?

Define the **area defect** by the same recipe, with area in place of entropy:
$$ \mathrm{areaDefect}(X, Y) = \mathrm{area}(X) + \mathrm{area}(Y) - \mathrm{area}(X \cap Y) - \mathrm{area}(X \cup Y). $$
Because $S = \mathrm{area}/4$, a single line of algebra gives the **exact bridge formula**:
$$ \mathrm{defect}(X, Y) \ =\ \frac{\mathrm{areaDefect}(X, Y)}{4}. $$
Information curvature *is* geometric curvature, divided by four. The two notions are not analogies that happen to rhyme. They are the same quantity in two costumes.

This leads to the centerpiece of the whole construction — our **second theorem**, a genuine cross-domain equivalence:

> **Strong subadditivity of entropy holds for every pair of regions if and only if area submodularity holds for every pair of regions.**

On the left is the most important inequality in quantum information. On the right is a purely geometric statement about how the areas of surfaces combine. The two are *logically equivalent*, and the dictionary that translates between them is the Ryu–Takayanagi relation. Physicists have long suspected that geometry is "the visible face of information constraints." Here that suspicion becomes a proven biconditional: every quantum-information inequality of this shape is a geometric inequality in disguise, and vice versa.

A pleasant corollary falls out for free. Combining $S(X) \le |X|$ with the RT relation gives
$$ \mathrm{area}(X) \ \le\ 4\,|X|, $$
a clean geometric bound: the area of any region's wall is at most four times the number of sites it contains. The microscopic count of "atoms of space" controls the macroscopic area — exactly the kind of statement that, in real gravity, becomes the celebrated *Bekenstein–Hawking* bound on black-hole entropy.

## Codes, distance, and why you can trust the hologram

The phrase "spacetime as an error-correcting code" deserves to be cashed out. An error-correcting code stores a few precious **logical** bits inside many redundant **physical** bits, so that even if some physical bits are erased, the logical information survives. Three numbers describe a code on a region $X$: the number of physical qubits $N(X)$, the number of logical qubits $K(X)$, and the **code distance** $D(X)$ — the minimum number of erasures needed to destroy the encoded information.

These obey the classical **Singleton bound**, the oldest inequality in coding theory:
$$ N(X) - K(X) \ \le\ 2\,(D(X) - 1). $$
Rearranged, it becomes a *lower* bound on logical content — our coding-theoretic theorem:
$$ K(X) \ \ge\ N(X) - 2\,(D(X) - 1). $$
High code distance forces high logical content. In the holographic dictionary, where area tracks physical qubits and entropy tracks logical ones, this is a constraint linking how much surface a region has to how much bulk information it can protect. Robust codes carry rich bulks.

The reason the hologram is *trustworthy* is captured by **reconstruction**. We say a region $U$ can be reconstructed from a boundary region $X$ when $U \subseteq X$ and $U$ is small enough that erasures can't exceed its protective distance: $|U| < D(U)$. The bulk physics encoded in $U$ can then be recovered from $X$ even after damage. And here is the reassuring **third theorem**:

> **If $U$ is reconstructable from $X$, and $X$ sits inside a larger boundary region $Y$, then $U$ is reconstructable from $Y$.**

Looking at *more* of the boundary never costs you the ability to recover the bulk. Reconstruction is **monotone**: knowledge only accumulates. This is the precise sense in which a bigger window onto the hologram always shows you at least as much of the hidden scene.

## Wedges: drawing the boundary's reach into the bulk

There is a beautiful geometric refinement of reconstruction. Given a piece $B$ of the boundary, which parts of the bulk does it "own"? The natural answer uses distance: a bulk point belongs to $B$'s **entanglement wedge** if it is strictly closer to $B$ than to the rest of the boundary. "Closer" here is measured in a tropical, or *min-plus*, geometry — the geometry of shortest paths, where to combine two legs of a journey you *add* their lengths and to choose between routes you take the *minimum*. The distance from a point to a region is just the smallest distance to any site in it.

With this definition, the wedge of $B$ is exactly the set of bulk points strictly nearer to $B$ than to its complement. We prove this region is **robust**: if you jiggle all the distances by less than half the "winning margin" — the gap by which a point preferred $B$ — then the point stays in the wedge. Small metric perturbations cannot tear the bulk's allegiance away from its boundary. Geometry emerging from information is *stable*, not a fragile coincidence.

Finally, the wedge delivers a clean reconstruction guarantee in its own right. Each boundary site reports a **min-plus convolution** of the bulk state — the smallest value of "bulk value plus distance," a tropical echo of how a signal smears as it travels. We prove that if two bulk configurations produce identical boundary reports across all of $B$, and each wedge point has a unique nearest boundary witness, then the two configurations must agree throughout the wedge. The boundary readings on $B$ pin down the bulk on $B$'s wedge — a finite, fully rigorous version of the celebrated **entanglement wedge reconstruction** principle.

## A threshold for spacetime

Where does the original dream — a *phase transition* into smooth spacetime — fit? In the tensor-network picture, each link carries a "bond dimension" $D$, a measure of how much entanglement it can support. Below a critical value, the network is too sparse to weave a smooth geometry; above it, a manifold-like bulk crystallizes. Our toy model encodes the threshold cleanly: the **critical bond dimension** needed to faithfully represent a chain of length $n$ grows steadily with $n$,
$$ D_c(n) = 1 + \frac{n}{10}, $$
and we prove it is **strictly increasing** — longer chains demand richer links, with no exceptions and no plateaus. It is the simplest honest fingerprint of the sharp transition that the full conjecture predicts: more complexity, more bond dimension, more geometry.

## Why this matters

Step back and look at what we have. Starting from a ledger of information — entropy assigned to regions — and two physical principles (Ryu–Takayanagi and strong subadditivity), we derived, with airtight logic:

- a notion of curvature (the syndrome defect) that is provably nonnegative;
- an exact equivalence between a quantum-information inequality and a geometric one;
- a coding bound linking area to protected information;
- a monotone, stable reconstruction of bulk from boundary, refined by entanglement wedges;
- a strictly increasing threshold for the emergence of geometry.

None of this proves that *our* universe is an error-correcting code. But it proves something quietly remarkable: that the slogans of holography — "geometry is information," "spacetime is a code," "the bulk lives on the boundary" — are not merely poetic. In a clean, finite setting they are *theorems*, each following inevitably from a small set of assumptions about how information is allowed to distribute itself.

The deepest dream behind this program is to **derive Einstein's equations from the theory of computation** — to show that the curving of spacetime is, at bottom, a statement about the cost and structure of information. We are not there. But the bridge in this article — the proven equivalence between strong subadditivity and area submodularity — is exactly the kind of plank such a bridge is built from. It shows that when you write down what information is allowed to do, geometry is not added by hand. It is already there, waiting in the arithmetic, in the shape of a ledger that almost, but not quite, adds up.
