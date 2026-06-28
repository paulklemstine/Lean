# THEOREM TRACE (internal anti-hallucination ledger)

Every name below is taken verbatim from the Phase A Lean output. No result is
stated in ARTICLE.md / RESEARCH_PAPER.md that is not on this list.

## `Catalog/Novelty/SCD/SuperExponential.lean` (namespace `Novelty.SCD`)

| Lean name | Statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `SuperExp` (def) | `SuperExp f := ∀ c : ℕ, ∃ N, ∀ n ≥ N, c^n < f n` | yes ("outruns every exponential") | Def. 2 |
| `factorial_superexp` | `SuperExp Nat.factorial` | yes (factorial beats every c^n) | Thm. 1 |
| `perm_card_superexp` | `SuperExp (fun n => Fintype.card (Equiv.Perm (Fin n)))` = SuperExp of `n!` | yes (shuffles) | Cor. 1 |
| `SuperExp.of_eventually_le` | `SuperExp f → (∃M,∀n≥M, f n ≤ g n) → SuperExp g` | yes (transfer principle) | Lem. 1 |
| `pow_const_not_superexp` | `¬ SuperExp (fun m => m ^ k)` | yes (polynomials are not) | Thm. 2 |

## `Catalog/Novelty/SCD/SymmetricChainCount.lean` (namespace `Novelty.SCD`)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `numSCD` (def) | number of symmetric chain decompositions of the two-level slab `CB n` (carrier `Bool × Fin n`) | yes | Def. 4 |
| `permChains` (def) | `Equiv.Perm (Fin n) → SCD(CB n)`, an injection | yes | Sec. 4 |
| `factorial_le_numSCD` | `n! ≤ numSCD n` | yes | Thm. 3 |
| `numSCD_superexp` | `SuperExp numSCD` | yes | Thm. 4 |

## `Catalog/Novelty/AlternatingCyclePosetLowerBound.lean` (namespace `AlternatingCyclePoset`)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `Crown` (def) | carrier `Fin w × Bool × Fin m`, the blown-up crown | yes | Def. 5 |
| `IsStrictAltCycle` (def) | predicate on `Fin w → α × α` | yes | Def. 5 |
| `Crown.card` | `Fintype.card (Crown w m) = 2*w*m` | yes | Sec. 5 |
| `Crown.hasWidth` | width of `Crown w m` is `w` | mention | Sec. 5 |
| `crown_strictAltCycle_card_lower` | `m^(2w) ≤ #{strict alt cycles}` | yes | Thm. 5 |

## `Catalog/Novelty/SCD/CrownBridge.lean` (namespace `Novelty.SCD`)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `crownAltCount` (def) | `#{p : Fin w → Crown w m × Crown w m | IsStrictAltCycle p}` | yes | Def. 6 |
| `pow_le_crownAltCount` | `m^(2w) ≤ crownAltCount w m` | yes | Lem. 2 |
| `crownAltCount_tendsto_atTop` | `Tendsto (crownAltCount w) atTop atTop` | yes | Thm. 6 |
| `crown_floor_not_superexp` | `¬ SuperExp (fun m => m^(2w))` | yes | Thm. 6 |
| `scd_strictly_outgrows_crown_floor` | `SuperExp numSCD ∧ ¬SuperExp(m↦m^{2w}) ∧ Tendsto (crownAltCount w) atTop atTop` | yes (main synthesis) | Thm. 7 |

## Naming discipline
- "main theorem" of the package = `scd_strictly_outgrows_crown_floor`.
- The exact identity `numSCD n = n!` is a CONJECTURE (Future Direction 1); only
  `factorial_le_numSCD` (`n! ≤ numSCD n`) is proved. Prose marks this clearly.
- `#SCD(M(n))` / `#SCD(L(m,n))` super-exponential is the CONJECTURE; the proved
  content is the abstract engine plus the two-level-slab instance.
