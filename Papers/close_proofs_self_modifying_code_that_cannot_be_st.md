# Why computational evidence was skipped

The central claims are impossibility and computability-classification theorems over all partial-recursive program codes. Finite testing cannot provide meaningful evidence for noncomputability: every finite table of observed programs admits a total classifier agreeing on that sample. Likewise, small executions can illustrate individual halting runs but cannot distinguish a genuinely general predictor from one tailored to the tested cases.

The Lean development instead gives exact symbolic evidence: an explicit self-modifying transition system is related step-for-step to the universal partial-recursive evaluator; its halting predicate is proved recursively enumerable but undecidable; its nonhalting complement is proved not recursively enumerable; and its fixed-program simulation is proved behaviorally equivalent. These statements directly address the universal quantification that finite experiments cannot test.
