# THEOREM_TRACE.md (internal)

Anti-hallucination trace. Every theorem named below is drawn from this cycle's
Lean output (files `SpernerBrouwerBridge.lean` and
`BanachContractionFixedPoint.lean`) as summarized in the Phase A Future
Directions. No theorem is invented or renamed into a grander claim.

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `changes` (def) | For a 2-colouring `c : ℕ → Bool`, `changes c n` counts indices `i < n` with `c i ≠ c (i+1)` (bichromatic edges of a path). | §"Counting colour flips" | Def. 2.1 |
| `changes_succ` | `changes c (n+1) = changes c n + (if c n ≠ c (n+1) then 1 else 0)`. | §"Counting colour flips" | Lemma 3.1 |
| `sperner_parity` | `changes c n` is odd iff `c 0 ≠ c n` (parity is determined by the endpoints). | §"The parity trick" | Theorem 3.2 |
| `sperner_exists_change` | If `c 0 ≠ c n` then `∃ i < n, c i ≠ c (i+1)`: a path with mismatched endpoints has a bichromatic edge. | §"From parity to existence" | Corollary 3.3 |
| `brouwer_one_dim` | Every continuous `f : ℝ → ℝ` with `f x ∈ [0,1]` for all `x ∈ [0,1]` has a fixed point `x* ∈ [0,1]` with `f x* = x*`. | §"Brouwer on the interval" | Theorem 4.1 |
| `affine_fixedPoint_mem_Icc` | For affine `f x = a x + b` with `0 ≤ a < 1` that maps `[lo,hi]` into itself, the fixed point `x* = b/(1-a)` lies in `[lo,hi]`. | §"Schauder's shadow" | Theorem 5.1 |
| `affine_iterate_tendsto` | For `f x = a x + b` with `|a| < 1`, the iterates `f^[n] x₀ → b/(1-a)`. | §"Banach and the power of repetition" | Theorem 6.1 |

Derived/secondary inequalities referenced for the Banach quantitative bound
(a-posteriori Picard estimate, Conjecture 4 of Future Directions) are stated as
remarks, not as proved Lean theorems, and are flagged as such.
