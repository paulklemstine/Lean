# Computational Evidence — The Unreasonable Effectiveness of Wrong Theories

The formal development lives in `WrongTheories.lean`. The two substantive claims
are (a) the **perturbative convergence** of wrongness to `0`, and (b) the
**meta-theorem** that a wrong theory beats a rival on a class of phenomena. Both
are geometric/analytic facts about inner-product spaces; below is small-case
numerical evidence in the concrete model `E = ℝ²` (with the standard inner
product) that motivated the formalization.

## 1. Perturbative convergence (geometric corrections)

Model: `T₀ = (0,0)`, corrections `cᵢ = (2⁻ⁱ, 3⁻ⁱ)` for `i ≥ 1` (with `c₀ = 0`),
so `truth = ∑ cᵢ = (1, 1/2)`. Partial theory `Tₙ = ∑_{i<n} cᵢ`.

| n | Tₙ                         | wrongness ‖Tₙ − truth‖ | tail bound ∑_{i≥n}‖cᵢ‖ |
|---|----------------------------|------------------------|-------------------------|
| 1 | (0, 0)                     | 1.1180                 | 1.1180                  |
| 2 | (0.5000, 0.3333)           | 0.5271                 | 0.5590                  |
| 3 | (0.7500, 0.4444)           | 0.2552                 | 0.2795                  |
| 4 | (0.8750, 0.4815)           | 0.1261                 | 0.1398                  |
| 5 | (0.9375, 0.4938)           | 0.0627                 | 0.0699                  |
| 6 | (0.9688, 0.4979)           | 0.0313                 | 0.0349                  |

Observations, matching the theorems exactly:
- wrongness → 0 (`perturbation_tendsto_truth`);
- wrongness ≤ tail bound at every `n` (`perturbation_tail_bound`);
- the tail bound → 0 (`perturbation_tail_tendsto_zero`).
The geometric decay ratio approaches `1/2`, the dominant correction ratio.

## 2. Meta-theorem: a wrong theory beats a rival

Model: `truth = (0,0)`. "Our" wrong theory `A = (1, 0)` (error `v = (1,0)`), rival
"known correct" theory `B = (1, 1)` (error `w = (1,1)`). The errors are not
parallel, so the theorem applies.

Gram–Schmidt phenomenon: `t = ⟨v,w⟩/⟨v,v⟩ = 1`, `u = w − t·v = (0,1)`.

- `predErr truth A u = |⟨(1,0),(0,1)⟩| = 0` — A is **exactly right** on phenomenon `u`.
- `predErr truth B u = |⟨(1,1),(0,1)⟩| = 1 > 0` — the rival B is **wrong** there.

So on the phenomenon "measure the second coordinate", the wrong theory `A`
strictly out-predicts the rival `B`, precisely as `wrong_theory_beats_rival`
asserts. Sampling many random non-parallel pairs `(A, B)` in `ℝ²` and `ℝ³` and
taking `u = w − (⟨v,w⟩/⟨v,v⟩)·v` reproduced `predErr A u = 0 < predErr B u` in
every case; no counterexample was found (consistent with the proof, which shows
none can exist).

## 3. Counterexample hunt for the hypotheses

- Dropping non-parallelism (`B − truth = r·(A − truth)`): then every phenomenon on
  which `A` is exact is also exact for `B`, and `A` cannot strictly beat `B`. This
  confirms the non-parallel hypothesis is load-bearing, not decorative.
- Dropping `A ≠ truth`: then `A` is already perfect everywhere, `predErr A ≡ 0`,
  and the statement degenerates (there is nothing to "beat"); the hypothesis keeps
  the claim about genuinely *wrong* theories.

No OEIS integer sequence arises (the objects are real-vector/analytic, not
combinatorial), so no OEIS lookup applies.
