# Theorem Trace (internal — anti-hallucination)

Every named result below is taken directly from the Phase A Lean output. No
result outside this list is stated as a theorem in ARTICLE.md or
RESEARCH_PAPER.md.

| Lean name | File | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `PVar` (def) | Pigeonhole.lean | Variable type `Fin (n+1) × Fin n`, indexed by (pigeon, hole) | yes (prose) | yes (Def. PVar) |
| `pigeonClause` (def) | Pigeonhole.lean | "pigeon p sits in some hole": positive disjunction over holes | yes (prose) | yes (Def. clauses) |
| `holeClause` (def) | Pigeonhole.lean | "pigeons p1,p2 do not share hole h": binary negative clause | yes (prose) | yes (Def. clauses) |
| `PHP` (def) | Pigeonhole.lean | The full pigeonhole CNF over `PVar n` | yes (prose) | yes (Def. PHP) |
| `PHP_unsat` | Pigeonhole.lean | `PHP n` is unsatisfiable | yes | yes (Thm 1) |
| `PHP_no_refutation_sat` | Pigeonhole.lean | A resolution refutation of `PHP n` certifies its unsatisfiability | yes | yes (Thm 2) |
| `add_sound` | CuttingPlanes.lean | If `d1 ≤ ∑ c1·x` and `d2 ≤ ∑ c2·x` then `d1+d2 ≤ ∑ (c1+c2)·x` | yes | yes (Thm 3) |
| `cg_rounding_sound` | CuttingPlanes.lean | If `k>0`, `k ∣ c_i`, `d ≤ ∑ c_i x_i`, then `⌈d/k⌉ ≤ ∑ (c_i/k) x_i` | yes | yes (Thm 4) |
| `php_cp_counting` | CuttingPlanes.lean | No integer `x` satisfies pigeon lower bounds (≥1 per row) and hole upper bounds (≤1 per column) simultaneously: `n+1 ≤ ∑x ≤ n` is contradictory | yes (main example) | yes (Thm 5) |

Referenced supporting names (from `Resolution.lean` / bridge, named in docstrings):
`Derivable`, `Refutation`, `resolvent_sound`, `refutation_sound`,
`Bridges.PigeonholeInjectionBridge.no_injection_of_card_lt`,
`Fintype.card_le_of_injective`. These are described conceptually only; no new
theorem statements are invented for them.
