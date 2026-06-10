# When Elections Can't Be Hacked: The Mathematics of Unshakeable Winners

## A small nudge shouldn't change everything

Imagine you're watching a cooking competition. Five chefs stand before a panel of judges. In each round, the chef with the lowest cumulative score is eliminated. The process repeats—four become three, three become two—until a single winner remains. It's a format audiences understand intuitively: sequential elimination.

Now imagine someone tampers with the scores. Not dramatically—just a tiny adjustment here, a fractional nudge there. Could that be enough to crown a completely different winner?

The answer, it turns out, depends on something precise and beautiful: the *gap*. If the loser of each round was losing by a wide enough margin, then no small perturbation can change their fate. The wrong chef still goes home. The right chef still wins. The entire elimination sequence is frozen in place, immune to interference.

This idea—that sufficient separation between competitors makes outcomes robust—has been formalized into a rigorous mathematical theory with machine-verified proofs. The results don't just apply to cooking shows. They reach into the heart of modern artificial intelligence, where classifiers that mimic this elimination process must be defended against adversarial attacks.

## The classifier that votes candidates off the island

In machine learning, a *classifier* is an algorithm that assigns a label to an input. Show it an image, and it tells you: cat, dog, or bird. One powerful approach uses *multiclass scoring*: the algorithm computes a numerical score for each possible label, then uses those scores to choose a winner.

The simplest approach picks whichever label has the highest score. But there's a more sophisticated alternative inspired by election theory: *instant-runoff classification*. Instead of simply picking the top scorer, the algorithm runs a sequential elimination tournament. In each round, it identifies the label with the *lowest* score and eliminates it. The process continues until a single label survives.

Why bother with this complexity? Because instant-runoff methods can capture subtler relationships between classes. They're particularly natural when scores come from *tropical geometry*—an exotic branch of mathematics where addition becomes maximization and multiplication becomes addition. Tropical score maps arise naturally in certain neural network architectures, and they produce classifiers with elegant geometric structure.

But this sophistication comes with a vulnerability. If an adversary can perturb the input—adding imperceptible noise to an image, for instance—the scores shift. And if the scores shift, the elimination order might change. A different label gets eliminated first, which changes who survives to the next round, which cascades into a completely different winner.

The question that keeps AI safety researchers up at night: *how much perturbation can the classifier withstand?*

## The gap certificate: a shield against chaos

The answer lies in a concept called a *gap certificate*. At each round of the elimination, we measure how far the loser's score falls below every surviving competitor. This distance—call it γ (gamma)—is the gap. A gap certificate is a guarantee that this separation holds at every single round of the elimination process.

Here's the critical insight, now proven with mathematical certainty: if every round has a gap of at least γ, then any perturbation of size at most ε to each score can shrink the gap by at most 2ε. The factor of two is exact and unavoidable—the loser's score might rise by ε while a competitor's score drops by ε, closing the gap from both sides simultaneously.

The magic threshold is **2ε < γ**. When the perturbation is small enough that twice its magnitude stays below the gap, the loser of each round remains the loser. The elimination order is completely preserved. The winner doesn't change.

This isn't an approximation or a heuristic. It's a theorem—proven by induction on the number of surviving candidates, verified step by step, with no room for error.

## From scores to inputs: the Lipschitz connection

But we don't usually care about perturbations to scores directly. We care about perturbations to *inputs*. An adversary doesn't manipulate the classifier's internal scores—they manipulate the image, the audio signal, the data point.

This is where Lipschitz continuity enters the picture. A score function is *K-Lipschitz* if perturbing the input by at most r in any coordinate changes each score by at most K·r. The constant K measures the sensitivity of the scoring function—how dramatically scores react to input changes.

The full robustness theorem chains these ideas together beautifully: if the score function is K-Lipschitz and the elimination process has a gap certificate of γ, then any input perturbation of radius r is harmless as long as **2Kr < γ**. The certified robustness radius is γ/(2K).

This gives practitioners a concrete, computable quantity. Given a specific input and its scores, compute the gap at each elimination round. Divide the minimum gap by twice the Lipschitz constant. The result is a *certified radius*: a guarantee that no adversarial perturbation within that ball can change the classifier's output. Not probably. Not approximately. Certainly.

## Why this matters now

The timing of this work is no accident. Adversarial robustness has become one of the central challenges in deploying AI systems safely. Self-driving cars must not misclassify a stop sign because someone placed a sticker on it. Medical imaging systems must not change a diagnosis because of sensor noise. Content moderation systems must not be fooled by subtle manipulations.

Most existing robustness certificates work only for the simplest classifiers—those that pick the label with the highest score. The instant-runoff setting is fundamentally harder because the elimination creates a cascade: changing one round's outcome can ripple through all subsequent rounds. The gap certificate approach tames this cascade by ensuring stability at every stage simultaneously.

The mathematical framework also reveals something deeper about the geometry of robust classification. The gap certificate is not just a technical device—it measures how "decisively" the classifier makes its choices. A large gap means the classifier is confident at every stage of its reasoning. A small gap means it's balanced on a knife's edge, vulnerable to the slightest push.

## The architecture of certainty

The proof itself has an elegant recursive structure that mirrors the elimination process it analyzes. At its foundation lies a lemma about unique minimizers: if one element of a finite set has a strictly lower value than all others, then any procedure that selects a minimizer must select that element. This is the mathematical equivalent of saying that a clear loser is unambiguously identified.

Built on this foundation, the one-round perturbation lemma (`gap_preserved_under_perturbation` in the formal development; see @file:Catalog/Bridges/IRVStability.lean) provides the algebraic core. It shows precisely how perturbation erodes the gap: a gap of γ becomes a gap of γ − 2ε after perturbation of size ε. The arithmetic is tight—no slack, no approximation.

The main stability theorem (`eliminationOrderOn_stable`) then applies this reasoning inductively. Each round of elimination preserves the gap condition for subsequent rounds, because the perturbed scores still produce the same loser, which means the same candidate is erased, which means the next round operates on the same reduced set. The induction closes cleanly.

Finally, the Lipschitz composition theorem (`irvWinner_certified_robust`) translates input-space perturbations to score-space perturbations and applies the elimination stability result. The chain is complete: input perturbation → score perturbation → gap preservation → elimination stability → winner preservation.

## The mathematics of cascading decisions

What makes the instant-runoff setting fundamentally more challenging than simpler decision procedures is the *cascade effect*. In a straightforward "pick the highest score" classifier, robustness analysis is local: you only need to compare the top two scores. But in sequential elimination, changing the outcome of a single round reshuffles everything downstream.

Consider five candidates with scores 1.0, 2.0, 3.5, 5.0, and 4.2. Under normal elimination, the candidate scoring 1.0 goes first, then 2.0, then 3.5, and finally 4.2, leaving 5.0 as the winner. But if a perturbation swaps the first two eliminations—sending the 2.0-scoring candidate home before the 1.0—the entire subsequent sequence can change, potentially crowning a different winner.

The gap certificate approach defuses this bomb at every stage. By requiring that each round's loser is separated from the pack by at least γ, it ensures that no perturbation smaller than γ/2 can swap any elimination. The cascade never starts.

This is a deeply satisfying mathematical structure: a local condition (per-round gap) yields a global guarantee (full-sequence invariance). The proof makes this precise through induction, showing that stability at round k implies the correct setup for round k+1, all the way to the final survivor.

## Looking forward

This work opens several compelling directions. The gap certificate framework could be extended to weighted elimination schemes, where different rounds use different scoring functions. It could be adapted to randomized tie-breaking rules, replacing the deterministic uniqueness assumption with probabilistic guarantees. And it connects naturally to broader questions in computational social choice theory, where understanding the stability of voting procedures under noise is a fundamental concern.

Perhaps most intriguingly, the tropical geometry connection suggests that the *structure* of the score function—not just its Lipschitz constant—might yield tighter robustness certificates. Tropical polynomials have a piecewise-linear geometry that could be exploited to compute gaps more efficiently and prove stronger stability results for specific classifier architectures.

Beyond adversarial robustness, the framework speaks to a broader question: *when can we trust algorithmic decisions?* The gap certificate provides a quantitative answer. It doesn't just say "this classifier is robust"—it says "this classifier is robust by exactly this much, and here's the proof." That level of precision is rare in machine learning, where most guarantees are statistical rather than deterministic.

The mathematics of robust classification is still young, but results like these—precise, general, and machine-verified—provide the kind of firm foundation on which a mature theory can be built. In a world increasingly reliant on algorithmic decision-making, knowing exactly when those decisions can't be shaken is not just mathematically satisfying. It's essential.
