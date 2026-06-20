# Theorem Trace (internal anti-hallucination ledger)

Every named object below is taken verbatim from the Phase A Lean output. No result
is stated in the deliverables that is not on this list. Where a result is only
*named* in the Phase A future-directions text (Threshold / AreaLaw) and not given
with full source, the deliverables describe it at the level the source supports and
never invent a closed form beyond it.

## `Bridges/FibonacciAnyonChain.lean` (full source provided — primary ground truth)

| Lean name | Statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `fusionCount` | `fusionCount 0 = 1`, `fusionCount 1 = 2`, `fusionCount (n+2) = fusionCount (n+1) + fusionCount n` | yes (def) | yes (Def. 1) |
| `fusionCount_eq_fib` | `fusionCount n = Nat.fib (n + 2)` | yes | yes (Thm. 1) |
| `fusionCount_le_two_pow` | `fusionCount n ≤ 2 ^ n` | yes (area law) | yes (Thm. 2) |
| `fusionCount_lt_two_pow` | `2 ≤ n → fusionCount n < 2 ^ n` | yes | yes (Thm. 2, strict part) |
| `fib_chain_commensurability` | `2 ≤ gcd(m+2,n+2) → gcd(fusionCount m, fusionCount n) = fusionCount (gcd(m+2,n+2) - 2)` | yes | yes (Thm. 3) |
| `fibBondDimension` | `:= Real.goldenRatio = (1+√5)/2` | yes | yes (Def. 2) |
| `ChainEncodable` | `critBond n < fibBondDimension` | yes | yes (Def. 3) |
| `N_critical` | `:= 7` | yes | yes |
| `chainEncodable_six` | `ChainEncodable 6` | yes | yes |
| `not_chainEncodable_seven` | `¬ ChainEncodable 7` | yes | yes |
| `fib_chain_encodable_iff` | `ChainEncodable n ↔ n < N_critical` | yes (main bridge thm) | yes (Thm. 4) |

## `Physics/RandomTensorNetwork/Threshold.lean` (named in future directions; imported by the chain file)

| Lean name | Role (as attested) | Usage in deliverables |
|---|---|---|
| `critBond` | critical bond dimension function; appears as `critBond n` in `ChainEncodable` | described as the per-length critical bond dimension; closed form **not** asserted beyond `D_c(N)=⌈(k^N)^{1/b}⌉` from future directions |
| `critBond_mem` | witnesses encoding exists at `D = D_c` | described qualitatively |
| `critBond_sharp` | encoding fails strictly below `D_c` | described qualitatively |
| holographic encoding | `Fin (k^N) ↪ Fin (D^b)` exists iff `D ≥ D_c(N)` | stated as phase-transition theorem (per future directions) |

## `Physics/RandomTensorNetwork/AreaLaw.lean` (named in future directions)

| Lean name | Role (as attested) | Usage in deliverables |
|---|---|---|
| `area_law` | entanglement bound `S ≤ b·log D` with saturation at uniform spectrum | stated as area-law theorem (per future directions) |

Anything not in this table is omitted from the deliverables.
