# Computational Evidence

## Scope

The principal claims are structural implications between abstract classes of decision problems and analytic inequalities derived from a finite fluctuation identity. They do not define an integer sequence or a parameterized finite search whose sampling could support the universal statements. Consequently, computation is used only for boundary-case diagnostics; the conclusions rest on the exact hypotheses stated in the accompanying results.

## Small-case calculations

The finite information-bearing object is a single Boolean memory. Its uniform distribution has two outcomes of weight `1/2`, while the erased distribution has weights `1` and `0`. The exact entropy calculations are

| distribution | weights | Shannon entropy |
|---|---:|---:|
| uniform bit | `1/2, 1/2` | `log 2` |
| erased bit | `1, 0` | `0` |

Thus one-bit erasure loses exactly `log 2` nats. At positive `k` and `T`, the resulting lower bound `k T log 2` is strictly positive. The zero-work boundary is therefore inconsistent with the stated finite Jarzynski condition, rather than an example violating the derived second-law inequality.

## OEIS search

No sequence arises from the abstract reduction, hierarchy-collapse, or finite one-bit thermodynamic statements, so an OEIS comparison is not applicable.

## Counterexample hunt

The assumptions were varied at their sharp boundaries:

| altered condition | consequence |
|---|---|
| omit the extended Church–Turing inclusion | physical realizability no longer implies machine-polynomial membership |
| omit reduction closure | an easy hard language need not transfer easiness to its source class |
| omit positive temperature or positive `k` | strict positivity of `k T log 2` is unavailable |
| omit the Jarzynski condition | no lower bound on expected work follows in this model |
| omit stable propagation of adjacent hierarchy equality | collapse at one pair of levels need not identify all higher levels |
| replace erasure by an injective operation | the one-bit logical-irreversibility conclusion does not apply |

These checks expose necessary boundaries rather than counterexamples to the guarded theorems. In particular, no claim is made that every polynomial-time computation erases information or that a complexity-class collapse by itself has a thermodynamic consequence.
