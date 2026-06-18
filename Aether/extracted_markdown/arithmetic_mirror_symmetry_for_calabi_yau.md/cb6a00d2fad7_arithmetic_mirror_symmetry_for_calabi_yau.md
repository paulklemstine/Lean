# When Elections Can't Be Hacked: The Mathematics of Unbreakable Rankings

## A small nudge shouldn't change who wins

Imagine a cooking competition with five contestants. Each round, the chef with the lowest score is eliminated. The process repeats until one remains — the winner. Simple enough.

Now imagine someone bumps the judges' scoring tablets. Every score shifts by a tiny, random amount — maybe a tenth of a point here, a quarter-point there. Does the same chef still win?

This question sounds like it belongs to the world of reality television. But a version of it sits at the heart of modern machine learning, electoral theory, and any system that makes sequential decisions based on numerical scores. And a new body of mathematical work has produced a precise, ironclad answer: **if the gaps between competitors are large enough relative to the perturbation, the outcome is guaranteed to be unchanged — not just probably, but provably.**

## The stakes are higher than you think

In 2018, researchers showed that adding a single carefully designed sticker to a stop sign could fool a state-of-the-art image classifier into reading it as a speed limit sign. In medical imaging, changing a single pixel in an X-ray can flip an AI diagnosis from benign to malignant. These aren't exotic attacks — they exploit a fundamental fragility in how machine learning systems make decisions.

The core vulnerability is simple: most classifiers operate on numerical scores, and small changes to those scores can change the outcome. When scores are close together, even tiny perturbations — from sensor noise, rounding errors, or deliberate adversarial manipulation — can tip the balance. What the mathematical community has long needed is not better defenses against specific attacks, but a *theory* of when and why certain decisions are immune to perturbation altogether.

That theory now exists.

## The instant-runoff machine

The elimination process described above has a formal name: **instant-runoff voting**, or IRV. In political elections, it's often called ranked-choice voting. Voters rank candidates; in each round, the candidate with the fewest first-choice votes is eliminated and their votes redistributed. But the same algorithmic skeleton appears far beyond ballot boxes.

In machine learning, multiclass classifiers often work by scoring each possible label and then selecting a winner. Some architectures — particularly those built on tropical geometry, a branch of mathematics that replaces ordinary addition and multiplication with minimum and addition operations — produce scores that feed naturally into an elimination-style decision process. A neural network might assign five scores to an image, one per possible class; the "weakest" class is eliminated, scores are recalculated, and the process repeats until a single classification remains.

Whether you're classifying images, ranking candidates, or triaging medical diagnoses, the question is the same: **how robust is this sequential elimination to noise?**

## The gap certificate: a mathematical insurance policy

The key insight is a concept called a **gap certificate**. At each round of elimination, the loser doesn't just have the lowest score — they have a score that is at least γ (gamma) points below every surviving competitor. This gap γ is the certificate. It's a quantitative measure of "how clearly the loser is losing."

Think of it as the margin of victory in reverse. In a close election, a recount might flip the result. But if the last-place candidate trails by a thousand votes, no reasonable recount could change who gets eliminated. The gap certificate makes this intuition precise.

The mathematical framework defines this rigorously: a candidate *i* in the active set *S* satisfies the gap condition when every other candidate *j* in *S* has a score at least γ above *i*'s score. When this condition holds at every round of the elimination process — from the first candidate eliminated all the way to the last two standing — we say the entire elimination is **gap-certified** with parameter γ.

## The perturbation lemma: where the magic happens

Here is the central algebraic insight, and it is beautifully simple.

Suppose every score shifts by at most ε (epsilon). The loser's score could go up by ε, and any competitor's score could go down by ε. In the worst case, the gap shrinks by 2ε — epsilon from each side.

So if the original gap was γ and the perturbation is at most ε, the new gap is at least γ − 2ε. As long as 2ε < γ, the gap remains positive. The loser is still the loser. The same candidate gets eliminated.

This is the **one-round perturbation lemma**, and it is the engine that drives everything else. It converts a quantitative separation condition into a qualitative stability guarantee.

## From one round to all rounds

One round of stability is useful. But an IRV election has many rounds — as many as there are candidates minus one. Does stability compound? Could small errors accumulate across rounds, eventually flipping the outcome even when each individual round is safe?

The answer, proved by induction on the number of surviving candidates, is no. If the *same* gap certificate γ holds at every round, and the perturbation ε satisfies 2ε < γ, then:

1. The first-round loser is unchanged.
2. After removing that loser, the remaining set inherits the gap certificate.
3. The second-round loser is unchanged.
4. And so on, all the way to the final survivor.

The **elimination-order stability theorem** states that the entire sequence of eliminations — not just the winner, but the precise order in which candidates are knocked out — is identical under the original scores and the perturbed scores. The **winner stability theorem** then follows as an immediate corollary: if the full elimination order is preserved, the last candidate standing is certainly preserved.

## The Lipschitz connection: from score perturbation to input perturbation

In machine learning, we rarely care about perturbations to scores directly. What matters is perturbation to *inputs* — pixels in an image, words in a document, sensor readings in a robot. The question becomes: if an adversary changes the input by at most *r* in each coordinate, can they change the classifier's output?

This is where the **Lipschitz condition** enters. A score function *s* is *K*-Lipschitz if perturbing inputs by at most *r* in each coordinate perturbs scores by at most *K·r* in each coordinate. The constant *K* measures the sensitivity of the scoring function to input changes.

Combining the Lipschitz bound with the winner stability theorem yields the **certified robustness theorem**: if the elimination is gap-certified with parameter γ, and the score function is *K*-Lipschitz, then any input perturbation of size at most *r* preserves the IRV winner, provided:

> **2Kr < γ**

This single inequality is a complete robustness certificate. Given a specific input, a specific score function, and a measured gap, you can compute exactly how large a perturbation the classifier can withstand. No probabilistic arguments, no sampling, no approximations — a hard mathematical guarantee.

## Why this matters now

Adversarial robustness has become one of the central challenges in deploying machine learning systems. A self-driving car that misclassifies a stop sign because someone stuck a small sticker on it is not a theoretical concern — it's a demonstrated vulnerability. Medical AI systems that change their diagnosis when a single pixel is altered in an X-ray image undermine the trust that clinical adoption requires.

Most existing robustness certificates apply to simple classifiers: pick the class with the highest score. But real-world systems increasingly use more complex decision procedures — ensemble methods, cascaded classifiers, sequential elimination schemes. The IRV framework captures a natural and important class of these architectures.

The gap certificate approach also connects to a deep mathematical tradition. Tropical geometry — the mathematics underlying many modern scoring architectures — naturally produces piecewise-linear score functions with computable Lipschitz constants. The GL₃ Satake correspondence, a construction from representation theory, provides a canonical way to build three-class tropical score maps with known geometric properties. The robustness theory developed here applies directly to classifiers built from these tropical foundations.

## The bigger picture

There is something satisfying about the structure of these results. The gap certificate is not just a sufficient condition for stability — it is a *natural* one. It measures exactly the quantity that perturbation attacks degrade. The factor of 2 in the condition 2ε < γ is not an artifact of loose analysis; it reflects the genuine worst case where the loser's score increases by ε while a competitor's score decreases by ε simultaneously.

The inductive structure of the proof mirrors the sequential nature of the algorithm itself. Each round inherits the certificate from the previous round, carrying stability forward through the entire elimination process. This compositionality — the fact that local stability implies global stability — is what makes the theory powerful.

And the final robustness corollary packages everything into a single, checkable inequality: **2Kr < γ**. Three numbers — the Lipschitz constant, the perturbation radius, and the gap — determine whether an adversary can change the outcome. In a world where AI systems are increasingly making consequential decisions, having a mathematical certificate that says "this decision cannot be flipped by any perturbation within this radius" is not just elegant mathematics. It is a practical tool for building systems we can trust.

The mathematics of unbreakable rankings tells us that when the margins are clear enough, no amount of noise — random or adversarial — can change who wins. In elections, in classifiers, and in any system that eliminates options one by one, clarity of separation is the ultimate defense against instability. And now we know exactly how much clarity is enough.

What makes this result particularly striking is its universality. The theory does not depend on the source of perturbation — whether it comes from random noise, sensor imprecision, adversarial attack, or computational rounding. It does not depend on the number of candidates or the dimension of the input space. It does not depend on the specific architecture of the score function, only on its Lipschitz constant. A single inequality — **2Kr < γ** — captures all of this, collapsing a complex multi-round analysis into three measurable quantities.

This is mathematics at its most powerful: taking a complicated, multi-step process and finding the single number that governs its behavior.

---

*The theorems described in this article have been machine-verified in their entirety. The complete formal development, including all definitions, lemma statements, and proofs, can be found in @Catalog/Bridges/IRVStability.lean.*
