# Summary of changes for run 9a445f94-d0ef-4fff-9a47-1e12dd00a89d
Delivered a new, fully-proved Lean file plus a research-roadmap document for this cycle on the rank of apparition.

**New Lean file:** `Catalog/Shared/StrongDivisibilityRankBridge.lean` (zero `sorry`; all main results verified to depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

It unifies and extends two existing catalog strands — the Fibonacci-specific rank theory in `Catalog/Applications/RankOfApparition.lean` (which is Fibonacci-only) and the structure-only `Catalog/Applications/StrongDivisibilitySequences.lean` (which had no rank function) — by equipping an *arbitrary* strong divisibility sequence with a rank-of-apparition function and then crossing a domain boundary to multiplicative-order theory.

4 main theorems (plus supporting lemmas):
- `seqRank_spine`: `m ∣ u n ↔ seqRank u m ∣ n` for any strong divisibility sequence in which `m` has a rank — the abstract form of the catalog's Fibonacci spine.
- `isPrimitive_iff_seqRank_eq`: `IsPrimitive u p n ↔ seqRank u p = n` (for `0 < n`) — primitive divisor ⟺ rank equals the index, at full generality.
- `mer_dvd_iff_orderOf_dvd`: `m ∣ aⁿ − 1 ↔ orderOf (a : ZMod m) ∣ n`.
- `seqRank_mer_eq_orderOf`: `seqRank (fun n => aⁿ − 1) m = orderOf (a : ZMod m)` for `1 ≤ a`, `0 < m`, `Nat.Coprime a m` — the rank of apparition and the multiplicative order are the same natural number (existence supplied via Euler's totient).

Supporting results proved: `IsStrongDivSeq.dvd_of_dvd`, `seqRank_pos`/`dvd_seqRank`/`seqRank_min`, `fib_isStrongDivSeq`, `mer_isStrongDivSeq`, `mer_dvd_iff_pow_eq_one`, `mer_hasRank_of_coprime`.

The file carries `-- !-- ... -- !--` proof sketches and `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) for every theorem, and cites the relevant catalog theorems it builds on in its module docstring.

**`FUTURE_DIRECTIONS.md`:** a narrative synthesis, a results table, and 5 falsifiable research directions (a unifying `StrongDivisibilitySequence` typeclass; the `r(p) ∣ p ± 1` entry-point law via the order bridge; an effective/`decide`-checkable rank algorithm with a proven `φ(m)` search bound; joint-apparition density; and Zsygmondy/Carmichael primitive divisors via the abstract primitivity law), each with an explicit "The key insight is…" and "Why now?" justification.

Note: the project's existing `lakefile.toml` targets (glob `Shared.+`) do not match the on-disk `Catalog/Shared/...` layout, so a plain project build is a pre-existing no-op; correctness of the new file was verified directly against the Lean 4.28 / Mathlib environment, confirming a clean compile with no `sorry` and only the permitted axioms.