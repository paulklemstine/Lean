# The Hidden Mathematics of Information Loss

## How a New Theory Reveals Why the Universe Forgets

Every time you compress a photograph, merge two spreadsheets into a summary, or blend ingredients into a smoothie, something irreversible happens. Information is lost. The individual pixels, the separate rows, the distinct fruits — they merge into something from which the originals cannot be recovered. This seemingly mundane observation turns out to conceal deep mathematical structure, and a new theoretical framework called *functorial entropy* is revealing just how deep it goes.

## The Problem of Measuring Irreversibility

Since Claude Shannon's groundbreaking 1948 paper, scientists have measured information using *entropy* — a single number capturing how much uncertainty or surprise a message contains. Shannon entropy has powered the digital revolution, enabling everything from ZIP files to streaming video. But Shannon's framework has a limitation: it measures the information *in* a signal, not the information *lost by a process*.

Consider two functions that each take six inputs and produce two outputs. Function A maps inputs {1,2,3} to output X and {4,5,6} to output Y — a clean, even split. Function B maps input {1} to X and {2,3,4,5,6} to Y — a lopsided split. Both lose information, but they lose it in fundamentally different ways. Shannon entropy can describe the output distributions, but it doesn't directly capture the structural character of the information loss itself.

This is where functorial entropy enters the picture.

## Fibers: The Anatomy of a Function

The key insight is deceptively simple: look at the *fibers* of a function. A fiber is the set of all inputs that map to the same output. For Function A above, the fibers are {1,2,3} and {4,5,6}, each of size 3. For Function B, the fibers are {1} (size 1) and {2,3,4,5,6} (size 5).

Functorial entropy, denoted H(f), is computed by weighting each fiber size by its logarithm:

> H(f) = Σ (fiber size / total inputs) × log(fiber size)

For Function A: H = (3/6)·log(3) + (3/6)·log(3) = log(3) ≈ 1.10

For Function B: H = (1/6)·log(1) + (5/6)·log(5) = (5/6)·log(5) ≈ 1.34

Function B has *higher* entropy despite producing the same number of outputs. Why? Because its lopsided fibers represent a more "violent" merging of inputs — one output absorbs far more information than the other.

## The Zero Entropy Theorem

The first major result is elegant in its simplicity: *a function has zero functorial entropy if and only if it is bijective* — that is, if it pairs each input with exactly one output, losing nothing.

When a function is bijective, every fiber has exactly one element. Since log(1) = 0, every term in the entropy sum vanishes. Conversely, any merging of inputs creates a fiber of size 2 or more, and log(2) > 0, so entropy becomes strictly positive.

This connects to a deep principle in physics: reversible processes — those that can be run backward without ambiguity — are precisely the ones that preserve all information.

## The Data Processing Inequality: Entropy Only Grows

The crown jewel of the theory is the *post-composition monotonicity theorem*, which states:

> If you process the output of function f through another function g, the combined entropy can only increase: H(g ∘ f) ≥ H(f).

This is the functorial analog of the celebrated *data processing inequality* from information theory: you cannot create information by processing data. Every additional transformation can only merge more fibers, creating larger clumps of indistinguishable inputs.

The proof rests on a beautiful inequality about the function x·log(x): it is *superadditive*, meaning that combining two groups always produces at least as much "weighted information content" as the groups had separately. When function g merges two fibers of f — say one of size 3 and one of size 5 — the resulting fiber of size 8 satisfies 8·log(8) ≥ 3·log(3) + 5·log(5). This is not obvious! It requires the convexity of x·log(x), a property rooted in the curvature of the logarithm.

## The Shannon Bridge

Perhaps the most surprising result is the *Entropy–Shannon Bridge*, which reveals that functorial entropy and Shannon entropy are two faces of the same coin:

> H(f) = log|domain| − H_Shannon(fiber distribution)

The functorial entropy of a function equals the maximum possible Shannon entropy of the domain minus the Shannon entropy of the fiber distribution. In other words, functorial entropy measures the *gap* between maximum disorder and the disorder of the fiber pattern.

This bridge theorem means that 75 years of information-theoretic results — coding theorems, channel capacity bounds, rate-distortion theory — can be translated into statements about functorial entropy, and vice versa. Two vast mathematical territories, developed independently, turn out to be connected by an underground passage.

## Landauer's Principle: The Thermodynamic Cost of Forgetting

In 1961, physicist Rolf Landauer made a provocative claim: erasing information has an unavoidable physical cost. Specifically, erasing one bit of information must dissipate at least kT·ln(2) joules of energy, where k is Boltzmann's constant and T is temperature. This is Landauer's principle, and it has been experimentally verified.

Functorial entropy gives Landauer's principle a precise mathematical backbone. The *Landauer cost* of a function is defined as log|domain| − log|range| — the logarithm of the ratio of input states to output states. The theory proves that:

1. Landauer cost is always nonneg (you cannot gain energy by computing).
2. Bijective functions have zero Landauer cost (reversible computation is thermodynamically free).

These are not approximations or physical assumptions — they are mathematical theorems about the structure of functions.

## The Entropy Defect: Measuring What Each Step Adds

When two functions compose — first f, then g — the total entropy H(g ∘ f) exceeds H(f) by an amount called the *entropy defect* δ(f, g) = H(g ∘ f) − H(f). The monotonicity theorem guarantees δ ≥ 0.

The entropy defect measures exactly how much additional information g destroys beyond what f already lost. If g is bijective (an identity, a permutation), then δ = 0: it adds no new information loss. This quantity could serve as a fine-grained complexity measure for pipelines of computations, distinguishing between steps that are merely rearranging data and steps that are genuinely discarding it.

## An Open Frontier

One conjecture remains tantalizingly open: does pre-composing with a *surjection* (an onto function) always increase entropy? Formally, if f is surjective, is H(g) ≤ H(g ∘ f)?

The conjecture has been verified computationally in numerous cases. For uniform surjections — where every fiber has the same size — the proof is straightforward. But non-uniform surjections create a subtle interplay between increasing fiber sizes and changing denominators that has resisted proof.

If true, this would complete the "functorial data processing inequality," showing that entropy is fully monotone with respect to both pre- and post-composition. It would mean that in any pipeline of computations, every step — whether it comes before or after — can only add to the total information loss.

## Why It Matters

Functorial entropy may seem abstract, but its implications ripple outward. In machine learning, each layer of a neural network is a function, and the entropy of these functions determines what information the network preserves and what it discards. In cryptography, the security of a hash function depends on how its fibers distribute inputs. In biology, the folding of proteins from sequence to structure is a many-to-one function whose fiber structure determines the robustness of the fold.

Perhaps most profoundly, functorial entropy provides a mathematical framework for thinking about the arrow of time. The second law of thermodynamics — entropy always increases — is usually stated for physical systems. But the composition monotonicity theorem shows that this arrow exists in pure mathematics: the composition of functions, like the passage of time, can only increase entropy. Information, once lost, cannot be recovered.

The universe, it seems, has been doing functorial entropy all along. We're just now learning to read the mathematics.

---

*This research develops a rigorous mathematical theory connecting information theory, category theory, and thermodynamics through the lens of fiber structures of functions between finite types.*
