# Theorem Trace — Row Sum Fibonacci Property of a Pascal-like Riordan Array

Source of truth: `Catalog/Novelty/RiordanRowSumFibonacci.lean`
(namespace `RiordanRowSumFibonacci`). Every name below is copied verbatim
from that file. No other results are claimed in the prose.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `pascalRiordanA` | def | $A(n) = \sum_{k=0}^{n}\binom{n+k}{2k}$ | yes (the "row sum") | Def. 2.1 |
| `pascalRiordanB` | def | $B(n) = \sum_{k=0}^{n}\binom{n+k}{2k+1}$ | yes (the "companion sum") | Def. 2.2 |
| `pascalRiordanB_succ` | lemma | $B(n+1) = A(n) + B(n)$ | yes (the coupling) | Lemma 3.1 |
| `pascalRiordanA_succ` | lemma | $A(n+1) = A(n) + B(n+1)$ | yes (the coupling) | Lemma 3.2 |
| `pascalRiordan_pair` | lemma | $A(n)=F_{2n+1}\ \wedge\ B(n)=F_{2n}$ | yes (main statement) | Theorem 3.3 |
| `pascalRiordanA_eq_fib` | theorem | $\sum_{k=0}^{n}\binom{n+k}{2k}=F_{2n+1}$ | yes (headline) | Theorem 3.4 |
| `pascalRiordanB_eq_fib` | theorem | $\sum_{k=0}^{n}\binom{n+k}{2k+1}=F_{2n}$ | yes (companion) | Theorem 3.5 |
| `pascalRiordan_three_term` | theorem | $A(n+2)+A(n)=3A(n+1)$ | yes (recurrence) | Theorem 3.6 |

Notes / anti-hallucination guards:
- Fibonacci indexing follows Mathlib's `Nat.fib`: $F_0=0, F_1=1, F_2=1, F_3=2,\dots$
- The generating function $(1-x)/(1-3x+x^2)$ is described as the analytic
  shadow of `pascalRiordan_three_term`; it is discussed as motivation. The
  *proved* statements are the eight rows above. No power-series identity is
  claimed as proved in this project's source file.
- OEIS references: the array is A085478, the row sums A001519. These are
  descriptive cross-references, not proved theorems.
