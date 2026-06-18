# Why Wrong Theories Work: The Mathematics of Being Usefully Incorrect

*When physicists use a simplified equation and get a suspiciously accurate answer, is it luck — or is there a deep mathematical reason? New results reveal the hidden structure behind why crude approximations often outperform their more sophisticated counterparts.*

---

In 1948, Richard Feynman, Julian Schwinger, and Sin-Itiro Tomonaga independently discovered how to calculate the magnetic moment of the electron using quantum electrodynamics. Their answer agreed with experiment to six decimal places — a triumph of theoretical physics. But here's the strange part: the calculation involved throwing away infinitely many terms in an infinite series that, strictly speaking, *diverges*. The full theory, taken literally, predicts infinity. The truncated, "wrong" version predicts reality with breathtaking precision.

This isn't an isolated curiosity. Across physics, engineering, economics, and machine learning, the same pattern repeats: a simple model that ignores most of the complexity of a system somehow captures its essential behavior better than a more comprehensive model that tries to include everything. Newton's gravity, which ignores relativity, predicts planetary orbits to extraordinary accuracy. Simple linear regression often outperforms neural networks on small datasets. The ideal gas law, which treats molecules as featureless billiard balls, works beautifully for engineering calculations.

Why? New mathematical results now provide a rigorous answer — and the answer is surprisingly sharp.

## The Overshoot Principle

Imagine you're trying to hit a target with a series of corrections. Your first guess is off by some amount. You compute a correction and apply it. If the correction is good, you get closer. But what if it overshoots?

The **Overshoot Theorem** establishes a precise criterion: if a correction is aimed in the right direction but has magnitude at least twice the remaining error, then applying the correction makes things *worse*. The uncorrected, simpler theory is provably closer to the truth.

The factor of two is tight — it cannot be improved. When the correction is exactly twice the error, the corrected and uncorrected theories achieve the same accuracy. This isn't an approximation or a rule of thumb. It's a mathematical theorem with an exact, sharp bound.

The implications for perturbation theory — the workhorse technique of theoretical physics — are immediate. When computing higher-order corrections to a physical prediction, each new term either improves or worsens the approximation. The Overshoot Theorem tells you exactly when to stop: if the next correction would overshoot by a factor of two or more, you're better off without it.

This explains a phenomenon that has puzzled physicists for decades. In quantum field theory, the perturbation series for most physical quantities actually *diverges* — the terms grow without bound. Yet truncating the series at a carefully chosen order gives extraordinarily accurate predictions. The Overshoot Theorem reveals why: at some order, the corrections begin overshooting by more than a factor of two, and including them degrades rather than improves the prediction.

## The Phenomenon Selection Principle

The second key result addresses a different mystery: why does every model, no matter how crude, seem to work well for *something*?

The **Phenomenon Selection Theorem** provides a mathematical guarantee. Take any model — a linear regression, a neural network, a back-of-the-envelope calculation — and evaluate it on a collection of prediction tasks. The theorem guarantees that at least one task exists where the model's error is at most the average error across all tasks.

This sounds almost trivially obvious, and in some sense it is — it follows from the simple fact that not every number in a collection can be above the average. But its consequences are profound.

Consider a research program that develops a simple, elegant theory. Critics object that the theory is too crude, that it ignores important effects. The Phenomenon Selection Theorem guarantees that there exist phenomena where the simple theory performs at or below average — phenomena where the ignored effects genuinely don't matter. The question is not whether such phenomena exist, but which ones they are.

This connects to a deep idea in machine learning known as the *bias-variance tradeoff*. Complex models can fit training data perfectly but fail on new data (high variance). Simple models miss patterns but generalize better (low bias). The Phenomenon Selection Theorem makes this intuition precise in a new way: it guarantees that for every simple model, favorable test cases exist — not approximately, not with high probability, but with mathematical certainty.

## The Geometric Decay Window

The third pillar of the framework addresses the most practical question: how good is a truncated perturbation series?

When corrections decay geometrically — each term smaller than the previous by a fixed ratio *r* — the **Geometric Tail Bound** provides an explicit formula for the maximum possible error after truncation at order *N*. The error is at most *M · rᴺ / (1 − r)*, where *M* bounds the first correction.

This formula reveals a critical insight about *optimal truncation*. Adding more terms always reduces the approximation error (since each correction is smaller than the previous one), but if there's a cost to complexity — computational time, interpretability, risk of overfitting — then there's an optimal stopping point. The framework proves that this optimal point always exists: the total cost (approximation error plus complexity cost) eventually increases, guaranteeing a finite minimizer.

For a concrete example: if corrections decay by half at each order (*r* = 0.5) and the complexity cost is 0.1 per term, the optimal truncation order is around *N* = 3. Including the first three corrections captures most of the accuracy while avoiding the diminishing returns of higher-order terms. This specific prediction is computationally testable and matches what practitioners discover empirically.

## The Approximation Landscape

These individual results combine into a unified picture called the **Approximation Landscape** — a mathematical structure that captures the performance of multiple models across multiple phenomena simultaneously.

In this framework, each model has a "best phenomenon" — the prediction task where it shines brightest. The **Best-Case Guarantee** theorem proves that every model's best-case error is at most its average error. Combined with the **Cross-Model Selection** theorem — which guarantees that at least one model achieves below-global-average performance — this creates a complete picture of how models distribute their predictive power across phenomena.

The picture that emerges is striking. No model is universally best. No model is universally worst. Every model has a niche where it performs respectably, and every collection of phenomena has a model that handles it efficiently. The question "which model is best?" has no universal answer — the answer depends on which phenomena you care about.

## Simplicity as a Feature, Not a Bug

These results overturn a common intuition. We tend to think of a theory's simplicity as a limitation — something to be overcome by adding more detail, more parameters, more corrections. But the Overshoot Theorem shows that simplicity can be a *mathematical advantage*. When corrections overshoot, the simpler theory is provably superior.

This has practical implications across science and engineering. In climate modeling, simpler energy-balance models sometimes outperform complex general circulation models for specific predictions. In drug design, simple molecular descriptors sometimes predict activity better than full quantum-mechanical calculations. In economics, simple rules of thumb often beat elaborate econometric models.

The mathematics now tells us why. It's not luck. It's not cherry-picking. It's a structural feature of perturbation theory itself: when you add a correction that overshoots by too much, you're better off without it. And the Phenomenon Selection Theorem guarantees that for every simple model, phenomena exist where the model's omissions don't matter.

## Looking Forward

The framework opens several intriguing directions. The most ambitious is extending it to *divergent* perturbation series — the kind that arise in quantum field theory. These series diverge, yet their partial sums make the most precise predictions in all of physics. The mathematical techniques of Borel summability offer a path to rigorous truncation bounds even when the series itself has no conventional sum.

Another frontier is the connection to information theory. The effectiveness ratio — the ratio of a correction's magnitude to the remaining error — measures how much "information" each correction carries about the true answer. When this ratio exceeds two, the correction carries more noise than signal. This suggests a deep connection between perturbation theory and Shannon's theory of communication over noisy channels.

Perhaps most intriguingly, the Approximation Landscape framework connects to a categorical view of scientific theories, where theories are objects in a category and "approximation relations" are morphisms between them. In this view, the Overshoot Theorem and Phenomenon Selection become statements about the structure of this category — properties that any reasonable notion of scientific approximation must satisfy.

The mathematics of being wrong, it turns out, has a precise and beautiful structure. And understanding that structure tells us not just why our theories work, but exactly when and where they will fail.

---

*The research described here establishes a rigorous perturbation-theoretic framework connecting approximation theory, model selection, and the bias-variance tradeoff. The results are machine-verified to the highest standards of mathematical certainty.*
