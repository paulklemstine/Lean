# Theorem Trace (internal anti-hallucination ledger)

This file lists every definition, lemma, and theorem appearing in the Phase A
Lean output, with its mathematical statement and where it is referenced in
`ARTICLE.md` and `RESEARCH_PAPER.md`. No result outside this list is claimed in
the prose.

## File: Catalog/Tropical/TropicalTDLPEigenAttack.lean

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `oneByOneAction` (def) | `oneByOneAction lam = fun x => lam + x` | §"Collapse" | Def. 1 |
| `oneByOne_tropical_iterate` (thm) | `(fun y => lam + y)^[k] x = k*lam + x` | §"Collapse" | Thm. 1 |
| `tdlp_recover_oneByOne` (thm) | `(fun y => 1 + y)^[k] x - x = k` | §"Collapse" | Thm. 2 |
| `Vec` (abbrev) | `Vec ι = ι → Nat` | — | Def. 2 |
| `tropScalarAdd` (def) | `tropScalarAdd c v = fun i => c + v i` | §"Eigenlines" | Def. 2 |
| `ScalarEquivariant` (def) | `∀ c v, F (c +• v) = c +• F v` | §"Eigenlines" | Def. 3 |
| `IsTropicalEigen` (def) | `F v = lam +• v` | §"Eigenlines" | Def. 4 |
| `tropScalarAdd_add` (thm) | `a +• (b +• v) = (a+b) +• v` | — | Lem. 1 |
| `iterate_eigenline_attack` (thm) | `F^[k] v = (k*lam) +• v` | §"Eigenlines" | Thm. 3 |
| `tdlp_recover_eigenline` (thm) | `F^[k] v i - v i = k` (when `lam=1`) | §"Eigenlines" | Thm. 4 |

## File: Catalog/Bridges/.../FibonacciAnyonChain.lean

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `fusionCount` (def) | `fusionCount 0=1, 1=2, (n+2)=fc(n+1)+fc n` | §"Anyons" | Def. 5 |
| `fusionCount_zero/one` | `=1`, `=2` | §"Anyons" | Def. 5 |
| `fusionCount_add_two` | recurrence | §"Anyons" | Def. 5 |
| `fusionCount_eq_fib` (thm) | `fusionCount n = fib (n+2)` | §"Anyons" | Thm. 5 |
| `fusionCount_le_two_pow` (thm) | `fusionCount n ≤ 2^n` | §"Area law" | Thm. 6 |
| `fusionCount_lt_two_pow` (thm) | `n≥2 → fusionCount n < 2^n` | §"Area law" | Thm. 6 |
| `fib_chain_commensurability` (thm) | `gcd(fc m, fc n) = fc(gcd(m+2,n+2)-2)` | §"Commensurability" | Thm. 7 |
| `fibBondDimension` (def) | `= goldenRatio` | §"Threshold" | Def. 6 |
| `ChainEncodable` (def) | `critBond n < fibBondDimension` | §"Threshold" | Def. 6 |
| `N_critical` (def) | `= 7` | §"Threshold" | Thm. 8 |

## File: Catalog/Physics/RandomTensorNetwork/Threshold.lean

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `critBond` (def) | `critBond n = 1 + n/10` | §"Threshold" | Def. 6 |
| `critBond_zero` | `critBond 0 = 1` | §"Threshold" | Def. 6 |
| `critBond_succ` | `critBond (n+1) = critBond n + 1/10` | §"Threshold" | Def. 6 |
| `critBond_strictMono` (thm) | `StrictMono critBond` | §"Threshold" | Thm. 8 |
