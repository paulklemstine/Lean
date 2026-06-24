# Theorem Trace (internal anti-hallucination ledger)

Every result below is taken verbatim from the Phase-A Lean output. No result is
stated in ARTICLE.md / RESEARCH_PAPER.md that does not appear here.

## File: Catalog/Logic/TopoErrorMitigation/MajorityDecoding.lean

| Lean name | Statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `ones` (def) | `ones (s : Fin n → Bool) : ℕ := (univ.filter (fun i => s i = true)).card` — number of `true` readouts | yes (informal) | yes (Def 1) |
| `errors` (def) | `errors (s) (b) : ℕ := (univ.filter (fun i => s i ≠ b)).card` — Hamming weight of corruption vs true bit `b` | yes (informal) | yes (Def 2) |
| `majority` (def) | `majority (s) : Bool := decide (2 * ones s > n)` — returns `true` iff strictly more than half of readouts are `true` | yes (informal) | yes (Def 3) |
| `majority_decode_correct` | `2 * errors s b < n → majority s = b` | yes (main, plain language + example) | yes (Thm 1, full statement + proof sketch) |
| `majority_decode_correct_iff` | `majority s = true ↔ 2 * errors s true < n` | yes (informal) | yes (Thm 2, full statement + proof sketch) |
| `majority_threshold_tight` | `0 < k → ∃ s : Fin (2*k) → Bool, errors s true = k ∧ majority s ≠ true` | yes (sharpness) | yes (Thm 3, full statement + proof sketch) |

## File: Catalog/Logic/TopoErrorMitigation/PersistentH0.lean

| Lean name | Statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `betti0` (def) | `betti0 (r : V→V→Prop) [Fintype (Quot (EqvGen r))] : ℕ := Fintype.card (Quot (EqvGen r))` — number of connected components | yes (informal) | yes (Def 4) |
| `componentMap` (def) | for `r₁ ⊆ r₂`, `Quot (EqvGen r₁) → Quot (EqvGen r₂)` via `Quot.lift` + `EqvGen.mono` | yes (informal) | yes (Def 5) |
| `componentMap_surjective` | `r₁ ⊆ r₂ → Function.Surjective (componentMap r₁ r₂ h)` | yes (informal) | yes (Lemma 1, proof sketch) |
| `betti0_persistence` | `r₁ ⊆ r₂ → betti0 r₂ ≤ betti0 r₁` (H₀ persistence) | yes (main, plain language) | yes (Thm 4, full statement + proof sketch) |
| `componentMap_merges` | explicit `Bool` instance witnessing two distinct `r₁`-components merging under `r₂` (non-degeneracy) | yes (informal) | yes (Thm 5 / remark) |

## NOT claimed (guard against over-statement)
- The iff `majority s = b ↔ 2*err < n` is FALSE for `b = false` at the tie. Only the
  `true`-codeword iff (`majority_decode_correct_iff`) is asserted; the `false` direction is
  only the one-sided `majority_decode_correct`.
- No probabilistic decay rate is proved (that is Future Direction C3, stated as conjecture only).
- No claim that topological decoding equals Hamming decoding is proved (Future Direction C1, conjecture only).
