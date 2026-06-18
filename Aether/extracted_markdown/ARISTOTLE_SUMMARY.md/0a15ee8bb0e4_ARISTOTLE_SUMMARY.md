# Summary of changes for run 9312c525-994d-4c05-bfbc-c144e9b38aa7
Created `Catalog/Bridges/KorseltFactorizationBridge.lean`, a self-contained factorization/divisibility bridge on natural numbers. It compiles cleanly (verified with `lake env lean`) and contains no `sorry`.

Contents:
- `dvd_iff_factorization_le`: the core bridge `a ∣ b ↔ ∀ p, a.factorization p ≤ b.factorization p`, proved as a thin wrapper around Mathlib's `Nat.factorization_le_iff_dvd` unfolded via `Finsupp.le_def`.
- `prime_dvd_iff_factorization_le`: specialization to a prime divisor `p ∣ n`.
- `dvd_pred_iff_factorization_le`: the generic `m ∣ (n - 1)` restatement (the shape of the `(p-1) ∣ (n-1)` Korselt clause).

Faithfulness note on hypotheses: the requested statements (with only `a ≠ 0`, etc.) are actually false when the dividend is `0` — divisibility by `0` is automatic while `(0).factorization` is the zero function, so e.g. `2 ∣ 0` holds but coordinate domination fails. As the task permits ("adapt the theorem statement accordingly" when the library lemma constrains both arguments), each theorem carries the necessary nonzero hypothesis on the dividend (`b ≠ 0`, `n ≠ 0`, `n - 1 ≠ 0`). This is documented in the docstrings.

The module documentation explains that "factorization-coordinate domination" means the pointwise inequality `∀ p, a.factorization p ≤ b.factorization p` on `Nat.factorization`. No Carmichael-number theory or Korselt proof is developed. The optional Korselt restatement was omitted because no existing criterion of the form `Squarefree n ∧ ∀ p, p.Prime → p ∣ n → (p-1) ∣ (n-1)` was found in the referenced project files. The file uses minimal setup (`import Mathlib`, a namespace) consistent with the other files in `Catalog/Bridges/`.