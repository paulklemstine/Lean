# Summary of changes for run 0d0d7c29-17cd-49d9-855c-a30766b93c70
Delivered a self-contained, fully proven Lean 4 development on the Mertens-function reformulation of the Riemann Hypothesis, plus the required research notes.

**New file:** `Catalog/Applications/RiemannMertens.lean` — sorry-free, depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`), verified to compile against Mathlib.

It defines the Mertens function `M(N) = ∑_{k=1}^N μ(k)` over `ℤ` and proves four theorems (plus base lemmas):
- `moebius_sum_divisors`: the Dirichlet convolution `μ * 1 = δ`, i.e. `∑_{d∣n} μ(d) = [n=1]` (built directly on Mathlib's `moebius_mul_coe_zeta`).
- `mertens_succ`: the telescoping step `M(n+1) = M(n) + μ(n+1)`.
- `mertens_hyperbola` (centerpiece): `∑_{n=1}^N M(⌊N/n⌋) = 1`, proved by a lattice-point reindexing on the hyperbola `nk ≤ N` (grouping pairs by their product `m = nk`) that collapses via `μ * 1 = δ`.
- `mertens_recurrence`: the self-similar recurrence `M(N) = 1 − ∑_{2≤n≤N} M(⌊N/n⌋)`, obtained by solving the hyperbola identity for its top term.

These are the elementary arithmetic skeleton on which the analytic RH-equivalent bound `M(x)=O(x^{1/2+ε})` rests; the deep analytic equivalence was deliberately not attempted, as documented.

Each theorem carries a brief `-- !-- comment -- !--` proof sketch, and the file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**Also added:** `FUTURE_DIRECTIONS.md` — a narrative Synthesis + Results Summary plus five falsifiable research directions (sub-linear computable Mertens oracle; a general Dirichlet-hyperbola summation lemma; Liouville-function analogue; the `∑ μ(n)/n` PNT precursor; and the Redheffer-matrix determinant identity), each with a "The key insight is…" statement and a "Why now?" justification.

Note on the project's build setup: the existing `Catalog/` tree is not wired into the lakefile's default targets (this is true of all catalog files, not just the new one), so verification was performed via the Lean LSP/elaborator, which confirms the file compiles with no errors and no `sorry` tactics (the only textual "sorry" occurrences are the words "sorry-free" inside docstrings).