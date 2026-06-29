# Theorem Trace — Incoherence Indices of Standard Social Decision Frames

Internal anti-hallucination ledger. Every mathematical claim in `ARTICLE.md`,
`RESEARCH_PAPER.md`, and `RESEARCH_PAPER.tex` must trace to a name below taken
from the Phase A Lean source `IncoherenceIndex.lean`. No theorem is paraphrased
into a grander claim, and no result appears in the prose that is absent here.

## Definitions

| Lean name | Statement | Article | Paper |
|-----------|-----------|---------|-------|
| `Frame n` (abbrev) | `Frame n := Finset (ZMod n)` — a finite set of atoms (majority-or-tie residues) in `ZMod n`. | §"The model" | Def. 1 |
| `IsBalanced F l` | `l ≠ [] ∧ (∀ x ∈ l, x ∈ F) ∧ l.sum = 0` — a non-empty list of atoms of `F` summing to `0`. | §"Balance" | Def. 2 |
| `balancedLengths F` | `{ k | ∃ l, IsBalanced F l ∧ l.length = k }` — set of lengths of balanced sequences. | §"Balance" | Def. 3 |
| `incoherenceIndex F` | `sInf (balancedLengths F)` — shortest balanced-sequence length (`0` if none). | §"The index" | Def. 4 |
| `IsMaximal F` | `AddSubgroup.closure (F : Set (ZMod n)) = ⊤` — atoms generate the whole space. | §"Maximal frames" | Def. 5 |

## Lemmas and Theorems

| Lean name | Statement | Article | Paper |
|-----------|-----------|---------|-------|
| `isMaximal_singleton_one` | For `n` with `NeZero n`, `IsMaximal ({1} : Frame n)`: the unit `1` generates `ZMod n`. | §"Maximal frames" | Lem. 6 |
| `incoherenceIndex_le` | For `0 < n` and non-empty `F`, `incoherenceIndex F ≤ n` (repeat one atom `n` times). | §"The ceiling" | Lem. 7 |
| `incoherenceIndex_singleton_one` | For `0 < n`, `incoherenceIndex ({1} : Frame n) = n`. | §"The cyclic frame" | Lem. 8 |
| `realization_even` | For even `n ≥ 4`, `∃ F, IsMaximal F ∧ incoherenceIndex F = n`. | Main thm | Thm. 9 |
| `incoherenceIndex_isGreatest` | For even `n ≥ 4`, `IsGreatest { k | ∃ F, F.Nonempty ∧ incoherenceIndex F = k } n`. | §"Sharpness" | Thm. 10 |
| `even_incoherenceIndex` | For `2 ∣ n` and `F` with all atoms odd (`χ a = 1`), `Even (incoherenceIndex F)`. | §"Parity" | Thm. 11 |
| `incoherence_unbounded` | `∀ N, ∃ n F, Even (incoherenceIndex F) ∧ N < incoherenceIndex F`. | §"Unboundedness" | Thm. 12 |

## Illustrative (non-theorem) facts used in prose

- `{1} ⊆ ZMod n` has shortest zero-sum `1,1,…,1` (`n` times) — instance of `incoherenceIndex_singleton_one`.
- `{1,3} ⊆ ZMod 4` has index `2` because `1 + 3 = 0`; used only as the
  "saturation contrast" example (Phase A `SaturationContrast.lean`,
  `incoherenceIndex_oneThree`, not in this file). Presented in prose as a worked
  numerical example, not as a theorem of this package.
