# Summary of changes for run 4021714c-f019-4592-9323-00a378343884
## Eastin–Knill Theorem & Fault-Tolerance Threshold — Lean 4 Formalization

I added a new self-contained Lean file `Catalog/Physics/EastinKnillThreshold.lean` (builds cleanly in the Catalog project, **0 sorries**, depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`), plus `Catalog/Physics/EastinKnillThreshold_FUTURE_DIRECTIONS.md`.

### Theorems proved (Step 1 declarations, all `proved`)
**Part I — the fault-tolerance threshold.** Modeling code concatenation by the quadratic error-suppression recursion `p_{n+1} = c·p_n²` (with physical rate `p_0 = p`):
1. `errorRate_rescaled` — the doubly-exponential law `c·p_n = (c·p)^{2^n}` (the rescaled rate satisfies `q_n = q_0^{2^n}`). Key insight: the recursion linearizes under rescaling; proved by induction.
2. `errorRate_closed_form` — `p_n = (1/c)·(c·p)^{2^n}`.
3. `errorRate_subthreshold_tendsto_zero` — below threshold (`c·p < 1`, i.e. `p < p_th = 1/c`) the logical error rate collapses to `0`.
4. `errorRate_at_threshold_const` — at threshold (`c·p = 1`) the rate is frozen at the unstable fixed point `1/c`.
5. `errorRate_superthreshold_tendsto_top` — above threshold (`c·p > 1`) the rate diverges to `+∞`. Together (3)–(5) give a **sharp trichotomy** with `p_th = 1/c` as an exact phase boundary.
6. `threshold_one_percent` — the surface-code malignant-pair count `c = 100` gives the celebrated `p_th = 0.01 (≈1%)`.

**Part II — the Eastin–Knill theorem (abstract group-theoretic core).**
7. `eastin_knill_not_universal` — in an infinite logical-unitary group, a *finite* transversal-gate group can never be the whole group, so transversal gates are never universal.
8. `eastin_knill_proper` — the corollary that a finite transversal group is a strict subset of the (infinite) ambient group.

### Catalog synthesis
The error-radius constant `c`/`t` connects to `CodeParams.t` in `StabilizerBounds.lean`; the threshold-from-spectral-gap idea bridges to `GaugeCodeDistance.lean` and `ToricCode.lean`. These connections are made explicit in the proof sketches (`-- !-- ... -- !--` blocks) and in `FUTURE_DIRECTIONS.md`.

### FUTURE_DIRECTIONS.md
Five falsifiable conjectures, each with a "key insight" and "Why now?": (1) super-quadratic suppression `q_n = q_0^{(t+1)^n}` for distance-`d` codes; (2) the polylog(1/ε) resource-overhead law from inverting the tower of exponentials; (3) a quantitative covering-radius refinement of Eastin–Knill; (4) gap-controlled threshold `p_th(L) → 1` linking spectral gaps to thresholds; (5) two-sided sharpness (`c·p < 1 ↔ error rate → 0`).

Verified via a full module build and a `grep` confirming no remaining `sorry`.