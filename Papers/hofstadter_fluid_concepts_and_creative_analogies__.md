# Computational evidence

The formal model is finite and its key bounds are proved symbolically, so computation is used only as a sanity check rather than as proof.

## Small cases

The executable checks at the end of `AnalogyOptimization.lean` evaluate three analogies on the two-element type `Bool`:

| analogy | forward/backward behavior | fixed-point similarity |
|---|---|---:|
| Copycat | identity / identity | 2 |
| flip | Boolean negation / Boolean negation | 2 |
| collapse | constant `false` / identity | 1 |

Thus maximum similarity need not identify Copycat uniquely: the flip symmetry is also perfect. The collapse example witnesses genuine information loss.

## Counterexample hunt

The flip example is a counterexample to the stronger claim that Copycat is the unique maximizer. Accordingly, the formal theorem states only that Copycat is a global maximizer. No counterexample exists to the proved upper bound because `similarity_le_card` proves it for every finite source type and every target type.

The one-sided definition of perfection also deliberately does not imply that the target round trip is an identity. For example, an injection with a left inverse may be source-perfect while leaving target points outside its image unrecovered.

## OEIS and plots

No numerical sequence is asserted, so an OEIS search is not applicable. The three-value table above is sufficient for the concrete finite sanity check; a plot would add no information.
