# Summary of changes for run 346ec571-dc7f-4664-9fe8-d7389e6dc6ba
I completed a full research cycle on **Zeta Functions of Directed Graphs and the Graph Riemann Hypothesis**, delivering verified Lean 4 code plus research notes.

## Deliverables

**Lean file:** `Speculative/DigraphZeta/Core.lean` (mirrored at `Catalog/Speculative/DigraphZeta/Core.lean`). It is self-contained (`import Mathlib`), compiles cleanly, and every stated theorem depends only on the standard axioms `propext, Classical.choice, Quot.sound` — no `sorry` on any result except the explicitly-marked open conjecture.

**Theorems proved (sorry-free):**
- `ihara_factor_root_RH_iff_ramanujan` — the heart: for a real eigenvalue λ and weight q>0, every root of the Ihara factor `q u² − λ u + 1` lies on the critical circle `normSq u = q⁻¹` **iff** the Ramanujan bound `λ² ≤ 4q` holds. This exposes the constant `2√q` as the discriminant threshold of a quadratic.
- `ramanujan_imp_circle` / `circle_imp_ramanujan` — the two directions (conjugate-root/Vieta argument; explicit positive-discriminant construction).
- `ihara_RH_iff_ramanujan_spectrum` — the global undirected/Hermitian (Lubotzky–Phillips–Sarnak) version over a whole real spectrum.
- `bowen_lanford_zeta_inv_eq_zero_iff` — directed zeta poles ↔ inverse eigenvalues.
- `digraph_bowen_lanford_RH_iff_circle` — directed-graph RH: all poles on the critical circle iff every nonzero eigenvalue lies on `normSq λ = q` (fully general complex spectra).
- `directed_ramanujan_naive_extension_false` — Critic counterexample: the naive complex disk-bound extension is **false** (witness λ = 2i, q = 1, root i(1+√2)).

**Open conjecture (stated, single `sorry`):** `directed_ramanujan_conjecture` — the genuine directed Ramanujan bridge for a d-out-regular digraph adjacency matrix, with its complex spectrum defined via the characteristic polynomial.

**Notes:** Each theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and a one–two sentence proof sketch. `FUTURE_DIRECTIONS.md` contains the required `## Synthesis` and `## Results Summary` sections plus 5 falsifiable research directions (Perron–Frobenius rigidity, abelian Cayley/circulant spectra, the λ²=4q boundary and zeta-zero multiplicity, the full Ihara determinant, and an Alon–Boppana zero-free-region analog).

**Key structural finding:** the "RH ⟺ Ramanujan" equivalence is, per eigenvalue, a discriminant-sign statement; the naive directed extension provably fails for complex eigenvalues, so the correct directed RH is the *circle* condition `normSq λ = q` (proved), and the remaining depth is purely combinatorial — isolated as the cycle's open conjecture.

The new file compiles as part of the root project's `Speculative` library (verified via build).