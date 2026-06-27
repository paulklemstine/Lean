# Theorem Trace (internal anti-hallucination ledger)

Every theorem/definition below is taken verbatim from the Phase A Lean output.
No result is stated in ARTICLE.md or RESEARCH_PAPER.md that is not in this table.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `IsAdmissible` | def (Admissible.lean) | A finite `H ⊆ ℤ` is admissible iff for every prime `p` there is a residue `r ∈ ℤ/pℤ` with `h ≢ r (mod p)` for all `h ∈ H`. | "missing residue" idea, §The Local Obstruction | Definition 1 |
| `exists_missing_residue` | thm (Admissible.lean) | If `p` prime and `H.card < p` then there is a residue `r mod p` missed by `H`. | "big primes are free" pigeonhole | Lemma 2 (Pigeonhole) |
| `isAdmissible_iff_small_primes` | thm (Admissible.lean) | `IsAdmissible H ↔ ∀ p prime, p ≤ H.card → ∃ r mod p missed by H`. | "infinite check becomes finite" | Theorem 3 (Finiteness/Decidability) |
| `twinTuple_admissible` | thm (Admissible.lean) | `IsAdmissible {0, 2}`. | twin example | Proposition 4 |
| `consecutive_not_admissible` | thm (Admissible.lean) | `¬ IsAdmissible {0, 1}`. | "why not n and n+1" | Proposition 5 |
| `primeGap` | def (BoundedGaps.lean) | `primeGap n = nth Prime (n+1) − nth Prime n`. | "the gap sequence" | Definition 6 |
| `next_prime_le_of_prime_lt` | thm (BoundedGaps.lean) | If `p`,`q` prime and `p < q` then `nth Prime (count Prime p + 1) ≤ q`. | "next prime can't skip past q" | Lemma 7 |
| `exists_index_gap_le` | thm (BoundedGaps.lean) | If for all `N` there exist primes `p<q≤p+B` with `N≤p`, then for all `M` there is `n≥M` with `primeGap n ≤ B`. | "bounded pairs force bounded consecutive gaps" | Theorem 8 |
| `liminf_primeGap_le` | thm (BoundedGaps.lean) | Infinitely many bounded prime pairs (gap `≤ B`) imply `liminf primeGap ≤ B`. | main reduction | Theorem 9 (Main Reduction) |
| `liminf_primeGap_le_246` | thm/corollary (BoundedGaps.lean docstring) | Maynard–Tao numerical corollary: `liminf primeGap ≤ 246`. | headline 246 | Corollary 10 |

Referenced-but-not-restated (mentioned only as framework/future work, matching the Phase A docstrings & future directions, never claimed as proved here beyond their stated role):
- `InfinitelyOftenTuplePrime` (analytic input predicate)
- `liminf_le_of_infinitelyOften` (bridge lemma)
- `selberg_weight_eq_squarefree_indicator` (GPY/Selberg weight bridge)
