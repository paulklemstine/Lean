# Computational Evidence

## Small-case calculations

For affine causal feedback `F(x) = a x + b`, the boundary equation `F(x) = x` gives `x = b/(1-a)` whenever `a ≠ 1`. The contractive examples below illustrate geometric relaxation.

| `a` | `b` | consistent state | iterates from `x₀ = 0` |
|---:|---:|---:|:---|
| `1/2` | `3` | `6` | `0, 3, 4.5, 5.25, 5.625, …` |
| `-1/2` | `3` | `2` | `0, 3, 1.5, 2.25, 1.875, …` |
| `1/4` | `-2` | `-8/3` | `0, -2, -2.5, -2.625, -2.65625, …` |

In each case the observed error ratio is `|a|`, agreeing with contraction theory.

## Polynomial tests and counterexample hunt

The universal claim that every polynomial return law has a real self-consistent state fails immediately:

| return map `F(x)` | fixed-point equation | real solutions |
|:---|:---|:---|
| `x² + 1` | `x² - x + 1 = 0` | none; discriminant `-3` |
| `x²` | `x(x-1)=0` | `0, 1` |
| `x³ - x` | `x(x²-2)=0` | `0, ±√2` |
| `x/2 + 3` | `x/2 + 3=x` | unique solution `6` |

This hunt demonstrates that polynomiality neither guarantees existence nor uniqueness. The guarded theorem therefore requires a nonempty complete invariant domain and contraction of the restricted map.

## Discrete paradox test

On the two Boolean states, negation exchanges `false` and `true`, so neither state is fixed. This is the smallest deterministic boundary-value problem with no self-consistent history.

## Sequence-database relevance

No integer sequence arises naturally in the existence and uniqueness statements, so an OEIS lookup is not pertinent. The quantities under study are fixed points, contraction rates, and metric error bounds rather than enumerative data.

## External-signal note

No arXiv abstract, OEIS sequence, or LMFDB object was supplied with the research prompt. Consequently, target selection was driven by the stated Banach/polynomial bridge and by counterexamples internal to that framing rather than by an unsupported external citation.
