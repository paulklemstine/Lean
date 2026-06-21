# THEOREM_TRACE.md (internal anti-hallucination ledger)

Source of truth: `Catalog/Algebra/GCT/Foundation.lean` (Phase A Lean 4 output).
Every claim in `ARTICLE.md`, `RESEARCH_PAPER.md`, and `RESEARCH_PAPER.tex`
maps to one of the entries below. No theorem outside this list is asserted as proved.

## Definitions / Structures

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `RepIndex` | structure with `label : ℕ`, `weight : ℕ` (abstract irreducible GL-rep index = partition; `weight` = |λ|) | "label/weight of a representation" | Def. 1 |
| `GCTSystem` | class bundling `inClosure` (preorder via `inClosure_refl`, `inClosure_trans`), `orbitDim` with `dim_mono`, `circuitSize` with `small_circuit_closure`, `repMult` with `containment_mult_le` | "the five axioms" | Def. 2 |
| `ObstructionWitness f g` | structure: `idx : RepIndex`, `mult_gap : repMult idx f > repMult idx g` | "obstruction / certificate" | Def. 3 |
| `AlgSeparator α` | structure: `classify`, `maxWeight`, `sound`, `uses_bounded_reps` | "algebraic proof system" | Def. 4 |
| `HardClassData α` | structure: `hard`, `easy`, `exp_const ≥ 1`, `hard_exp_weight` (any rep with positive mult on `hard n` has weight ≥ 2^(exp_const·n)) | "hard class" | Def. 5 |

## Theorems

| # | Lean name | Statement | ARTICLE | PAPER |
|---|---|---|---|---|
| 1 | `obstruction_implies_noncontainment` | `ObstructionWitness f g → ¬ inClosure f g` | yes (main idea) | Thm 1 |
| 2 | `circuit_lower_bound_from_obstruction` | (∀ g, orbitDim g ≤ B·B → ObstructionWitness f g) → circuitSize f > B | yes | Thm 2 |
| 3 | `orbit_trans` | inClosure f g → inClosure g h → inClosure f h | yes | Thm 3 |
| 4 | `mult_dom_trans` | (∀ri, mult f ≤ mult g) → (∀ri, mult g ≤ mult h) → ∀ri, mult f ≤ mult h | — | Thm 4 |
| 5 | `orbit_dim_lower_bound` | (∀ g, orbitDim g ≤ D → ObstructionWitness f g) → orbitDim f > D | yes | Thm 5 |
| 6 | `no_obs_local_dom` | on Finset of indices, no gap → domination | — | Thm 6 |
| 7 | `direct_noncontainment` | repMult ri f > repMult ri g → ¬ inClosure f g | yes | Thm 7 |
| 8 | `simultaneous_noncontain` | witnesses vs g and h → ¬inClosure f g ∧ ¬inClosure f h | — | Thm 8 |
| 9 | `circuit_from_dim` | orbitDim f > B·B → circuitSize f > B | yes | Thm 9 |
| 10 | `no_self_obstruction` | IsEmpty (ObstructionWitness f f) | yes | Thm 10 |
| 11 | `algebraic_natural_proofs_barrier` | a sound separator classifying the hard class must have maxWeight ≥ 2^(exp_const·n) | yes (climax) | Thm 11 |

Notes:
- Theorem 11's statement is reconstructed from the `AlgSeparator`/`HardClassData`
  structures: combining `uses_bounded_reps` (separator uses a rep of weight ≤ maxWeight
  with a multiplicity gap, hence positive multiplicity on `hard n`) with `hard_exp_weight`
  (any such rep has weight ≥ 2^(exp_const·n)) forces `maxWeight ≥ 2^(exp_const·n)`.
- No curvature/Ricci/Lorentzian claims are asserted as proved — those appear only in the
  Phase A future-directions text and are clearly marked as conjectural.
