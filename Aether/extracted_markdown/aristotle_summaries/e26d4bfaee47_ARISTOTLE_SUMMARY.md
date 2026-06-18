# Summary of changes for run 6362569d-185e-4695-9491-b6a21e00dbe1
Completed one research cycle on **Stereographic Neural Attention** (Cauchy-kernel attention via the Riemann sphere), delivered as a new module under `Catalog/MachineLearning/StereographicAttention/`.

## Lean files (10 fully-proved theorems, 0 sorry on all main results)

**`Core.lean`** — geometry of the Cauchy kernel `K(q,k) = 1/(1+‖q−k‖²)`:
- `cauchyKernel_pos`, `cauchyKernel_le_one` — scores lie in (0,1].
- `cauchyKernel_eq_one_iff` — the score saturates at 1 *exactly* on the diagonal `q=k` (absolute self-attention maximum).
- `stereo_on_sphere` — the stereographic projection lands on the unit sphere (well-typed).
- `stereo_chordal_eq_kernel` — the headline identity: the squared chordal distance from `σ(x)` to the north pole equals `4·K(x,0)`, i.e. a Cauchy score literally *is* a distance on the Riemann sphere.

**`Sparsity.lean`** — sparsity behaviour:
- `cauchyKernel_active_iff` — the τ-active key set is exactly a Euclidean ball of radius `√(1/τ−1)` around the query.
- `cauchyKernel_antitone` — closer keys score higher.
- `cauchy_total_weight_le` — total attention mass over N keys is ≤ N.
- `cauchy_sparsity_markov` (MAIN) — the rigorous sparsity backbone `τ·#active ≤ Σ scores`.
- `cauchy_sparsity_card_le` — combined bound `τ·#active ≤ N`.
- `cauchy_sublinear_mass_conjecture` — the one intentional, clearly-labeled conjecture (`sorry`), produced by the generalization loop.

## Notes & analysis
Both files contain `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and one-line proof-sketch comments per theorem. A key critique finding: the program's advertised "O(√N) sparsity" is **not** a dimension-free law — a shell-counting analysis shows the true total-mass bound for δ-separated keys in ℝ^d is `O(N^{(d-2)/d})`, with √N being exactly the `d=4` case, and the bound failing entirely in infinite dimensions. The corrected exponent is encoded in the Lean conjecture and explained in the notes.

## FUTURE_DIRECTIONS.md
Includes the required **Synthesis** and **Results Summary** sections plus 5 falsifiable research directions (sublinear total-mass law, universal Lipschitz robustness, Cauchy-kernel universal approximation, two-sided sparsity law, and a softmax–Cauchy interpolation family), each with hypothesis, test, "why now", and if-true/if-false consequences.

## Catalog synthesis
The work is positioned as a cross-domain bridge to the existing `Catalog/MachineLearning/Attention.lean` (attention as a natural transformation / Schur's lemma): that file treats attention *algebraically*, this one treats it *geometrically*, meeting on the diagonal fixed point.

Verification: both files compile with `lake env lean`; `Core.lean` is warning- and sorry-free, and the only `sorry` in the project is the explicitly-marked conjecture.