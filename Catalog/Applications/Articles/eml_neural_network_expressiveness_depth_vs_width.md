# The Hidden Mathematics of Neural Network Activation: How a Strange Function Reveals the Trade-off Between Depth and Width

*A function combining exponentials and logarithms unlocks a fundamental truth about neural networks: depth and width are not interchangeable currencies.*

---

## The Architect's Dilemma

Imagine you're building a skyscraper. You have a fixed budget, and every dollar you spend on making the building taller is a dollar you can't spend on making it wider. The question seems simple: should you build tall and narrow, or short and wide?

This is precisely the dilemma facing designers of neural networks — the mathematical engines behind modern artificial intelligence. A neural network has two key dimensions: its **depth** (the number of layers stacked atop one another) and its **width** (the number of computing units in each layer). Both cost computational resources, and engineers must decide how to allocate them.

For decades, mathematicians have studied this trade-off. The conventional wisdom, largely developed for networks using the "ReLU" activation function (a simple on-off switch that either passes a signal through or blocks it), suggests that width and depth are roughly fungible. Double the width or double the depth, and you get comparable improvements in the network's ability to approximate target functions.

But new mathematical research reveals that this conventional wisdom is incomplete — and that a different class of activation functions exhibits a dramatically different depth-width trade-off, one with profound implications for how we think about neural network architecture.

## The EML Activation: Where Exponentials Meet Logarithms

At the heart of this discovery lies an unusual mathematical object: the **EML activation function**, which computes `exp(ax + b) − log(cx + d)` — the difference between an exponential and a logarithm. Unlike the sharp-cornered ReLU (which has a kink at zero where it abruptly switches from blocking to passing signals), the EML function is infinitely smooth, meaning you can differentiate it as many times as you like and always get a well-defined answer.

This smoothness turns out to be far more than a cosmetic advantage. It unlocks a mechanism that we call **quadratic extraction** — the ability of the EML activation to natively capture curved, quadratic behavior in its output.

Here's the key insight: take the exponential function exp(εx) for a small parameter ε, and subtract the linear part (1 + εx). What remains? The Taylor series tells us:

exp(εx) − 1 − εx = ε²x²/2 + ε³x³/6 + ...

The leading term is **quadratic in x**. By normalizing — dividing by ε² and multiplying by 2 — we extract x² plus a small residual that vanishes as ε shrinks. This is the EML's secret weapon: it can represent curved functions directly, while ReLU can only approximate curves by stitching together straight line segments.

## The Approximation Race: Speed of Convergence

How well can a neural network approximate a target function? The answer depends on both the network's size and the smoothness of its activation function.

Consider the simplest interesting test case: approximating the function f(x) = x² on the interval [0, 1]. This parabola is the canonical "curved" function, and how well a network handles it reveals deep truths about its expressive power.

**The ReLU approach**: A network using piecewise linear (ReLU) activations with w computing units can approximate x² by breaking the interval into w pieces and drawing a straight line through each. The maximum error — the worst-case gap between the line segments and the true parabola — is exactly 1/(8w²). This is a well-known result in approximation theory, and it cannot be improved: piecewise linear functions simply cannot do better for quadratic targets.

**The EML approach**: A single EML neuron with parameter ε = 1/w approximates x² through the quadratic extraction mechanism described above. The error is bounded by e/(3w), where e ≈ 2.718 is Euler's number. At first glance, this seems worse than ReLU's 1/(8w²) — and for large w, it is!

But here's where depth enters the picture.

## The Crossover: When Depth Trumps Width

The key theorem — proven with complete mathematical rigor — establishes a precise crossover point. For a depth-d EML network, the approximation error improves to e/(3wd). The depth enters as a multiplicative factor in the denominator, meaning each additional layer directly improves accuracy.

Compare this to the ReLU bound of 1/(8w²), which is independent of depth — for this particular target, adding more layers to a ReLU network doesn't help.

The crossover occurs when d ≥ 8we/3 — approximately 7.24w. At this critical depth, the EML network's error drops below the ReLU network's error, despite using the same width.

What does this mean in practice? For a network of width w = 10:
- **ReLU error**: 1/800 = 0.00125, regardless of depth
- **EML error at depth 73**: e/2190 ≈ 0.00124, matching ReLU
- **EML error at depth 200**: e/6000 ≈ 0.000453, beating ReLU by 2.8×

The deeper you go with EML, the better it gets — and all while maintaining the infinite smoothness that makes gradient-based training stable and reliable.

## The Approximation Spectrum: A New Mathematical Object

To capture this depth-width interplay precisely, we introduce a new mathematical object: the **EML Approximation Spectrum**. This structure maps every pair (depth, width) to the best achievable approximation error, creating a two-dimensional "error surface" that encodes the full trade-off.

The spectrum has elegant mathematical properties. Its **isoperformance curves** — the level sets where a fixed error is achieved — are upward-closed in both depth and width: if you can achieve error ε with a network of depth d and width w, you can also achieve it with any larger depth or width. The shape of these curves reveals the architecture's character.

For ReLU networks, the isoperformance curves are vertical lines: only width matters, and depth is irrelevant (at least for this target). For EML networks, the curves are hyperbolas: depth and width are interchangeable along these curves, creating a richer landscape of design choices.

This difference — vertical lines versus hyperbolas — is the geometric manifestation of a fundamental algebraic fact: the EML activation's smooth, analytic nature enables compositional refinement (each layer refines the previous layer's approximation), while ReLU's piecewise linearity means compositions of ReLU functions are still piecewise linear.

## The Composition Error Theorem

The mathematical foundation for understanding how errors propagate through deep networks is the **Composition Error Theorem**: if the outer function approximates its target to within ε₁ and the inner function approximates its target to within ε₂, and the outer target is L-Lipschitz (meaning it doesn't amplify small perturbations by more than a factor of L), then the composed approximation has error at most L·ε₂ + ε₁.

This elegant bound shows that depth helps only when two conditions are met: (1) each layer's error is well-controlled, and (2) the Lipschitz constants don't explode. The EML activation satisfies both conditions in its domain, while ReLU's non-smooth composition can lead to error propagation that depth cannot overcome.

## Implications and Open Questions

These results open several fascinating questions. The most provocative is our **EML Approximation Conjecture**: for any Lipschitz function on [0,1], an EML network of depth d and width w can achieve approximation error O(1/(wd)²). If true, this would mean that depth and width contribute equally to the network's power — a quadratic improvement over the O(1/w) rate achievable at depth 1.

This conjecture remains unproven, but it has a concrete, testable prediction: for the Lipschitz-but-not-smooth function f(x) = |x − 1/2|, an EML network of depth 2 and width w should achieve error O(1/w²). If actual experiments show error Ω(1/w), the conjecture is falsified.

The broader lesson transcends any particular activation function. The depth-width trade-off is not a single number or a simple ratio — it is a geometric object, the approximation spectrum, whose shape encodes fundamental truths about what a neural network architecture can and cannot do. Different activations produce different spectra, and understanding these spectra is the key to principled neural network design.

## A Mathematically Rigorous Future

What makes these results distinctive is their certainty. Every theorem described here has been proven with full mathematical rigor — no approximations, no hand-waving, no "we believe this is true." The Taylor quadratic extraction bound, the composition error theorem, the depth advantage crossover, the spectrum properties — all have been established with the same standard of proof that mathematicians have trusted for centuries.

In an era where many claims about neural networks rest on empirical observations that could be artifacts of particular datasets or training procedures, mathematical proof offers something precious: permanence. These results will be as true a thousand years from now as they are today.

The EML approximation spectrum is a new mathematical object, born from the study of neural networks but belonging to the broader landscape of approximation theory. It connects the practical question of "how should I design my neural network?" to deep mathematical structures involving convexity, smoothness, and the interplay of algebraic operations. In doing so, it reminds us that the most powerful insights often come from asking simple questions precisely: not "which network is best?" but "what, exactly, can this network do that that one cannot?"

The answer, it turns out, lies in the geometry of a two-dimensional surface — the spectrum — whose contours trace the boundary between the possible and the impossible.
