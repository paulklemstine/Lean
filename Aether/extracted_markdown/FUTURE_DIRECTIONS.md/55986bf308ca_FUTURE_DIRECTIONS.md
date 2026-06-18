# Future Directions — Gravity from Information: Spacetime as a Quantum Error-Correcting Code

Derived from the v16a research cycle that produced `Bridges/QuantumSingletonCode.lean`
and `Bridges/RyuTakayanagiSingleton.lean`. Each conjecture below is bold, falsifiable,
and grows directly out of this cycle's verified findings (and its certified failures).

---

## 1. Holographic codes are forced to be quantum-MDS

**Conjecture.** Any boundary entropy functional `S` that (i) is submodular, (ii) obeys
the Ryu–Takayanagi relation `S = area/4`, and (iii) saturates the cardinality bound
`S(X) = |X|` on a generating laminar family, induces a region-wise code family that is
quantum-MDS *everywhere* (`∀ X, (f X).IsMDS`).

**The key insight is...** that RT does not merely *bound* the entropy — by
`rt_entropy_eq_logical_iff_mds`, equality with the maximal logical count `n - 2(d-1)`
is *equivalent* to Singleton saturation, so a geometry that realizes RT exactly must sit
on the extremal coding frontier.

**Why now?** This cycle proved the iff (`rt_entropy_eq_logical_iff_mds`) and the family
packaging (`mdsRegionalBound`); the only missing step is upgrading per-region saturation
to a *global* MDS theorem under submodularity — a finite, decidable combinatorial check.

---

## 2. The distance ladder is the discrete curvature spectrum

**Conjecture.** Define the holographic curvature spectrum of a code family as the
multiset `{ (f X).d : X }`. Then the syndrome defect of the catalog
`HolographicCoding` profile is a *strictly monotone* function of the distance gaps:
increasing any region's distance by one strictly increases the cumulative
`syndromeDefect`.

**The key insight is...** that `distance_drop` shows raising `d` by one costs exactly two
logical qubits; under RT (`area = 4S`) this is a fixed *area* quantum, so curvature
accumulates in discrete two-qubit steps rather than continuously.

**Why now?** `distance_drop` (proved) gives the exact `Δk = 2` quantum, and the catalog's
`syndromeDefect_list_sum_nonneg` already provides cumulative nonnegativity; linking the
two only requires a monotonicity lemma over distance increments.

---

## 3. The AdS₃ numeric dictionary must be replaced, not repaired

**Conjecture.** No assignment of the proposal's literal substitution
(`n = L/ℓ_P`, `d = L/(2ℓ_P)`, `k = S`) into the saturating identity yields a
non-constant entropy: every dimensionally-consistent completion forces `S` to be a fixed
constant (here `S = 2`). The correct invariant is the *dimensionless* ratio
`(n - k) / (2(d-1))`, which equals `1` exactly on the holographic frontier.

**The key insight is...** that `rt_AdS3_substitution_is_degenerate` already certifies the
collapse `S = 2` for the even-blocklength substitution; the genuine physics lives in the
saturation *ratio*, not in any single numeric plug-in.

**Why now?** The degeneracy is now a theorem, not a worry. Replacing the numeric test
with the ratio invariant is a clean reformulation this cycle's failure analysis demands.

---

## 4. Subsystem (tensor) codes add their Singleton slacks

**Conjecture.** For the "tensor product" of two code families
(`n = n₁+n₂`, `k = k₁+k₂`, `d = min(d₁,d₂)`), the combined Singleton slack
`(n - k) - 2(d-1)` is at least the sum of the individual slacks, with equality iff both
factors share the minimal distance. Hence MDS-ness is *not* generally preserved under
composition — composite spacetimes generically carry curvature even when their parts are
flat.

**The key insight is...** that `mds_iff_slack_zero` turns "flatness" into the vanishing of
a single integer (the slack), making sub-additivity of slack a concrete `omega`-style
target and giving an information-theoretic mechanism for emergent curvature.

**Why now?** With slack characterized exactly this cycle, composition laws become finite
arithmetic statements provable by `omega`/`linarith`, opening a path to a "curvature from
entanglement composition" theorem.

---

## 5. Bulk reconstruction is a distance threshold, sharply

**Conjecture.** Strengthen the catalog's `Reconstructable` predicate: a region `U` is
bulk-reconstructable from boundary `X` *iff* the induced code on `X` has distance
`d(X) > |U|`, and this threshold is sharp — at `d(X) = |U|` there exists an erasure
pattern destroying recovery.

**The key insight is...** that the quantum Singleton bound ties distance to redundancy
(`distance_le`), so the reconstruction threshold is governed by the same inequality that
fixes the entropy; recovery and entropy are two readouts of one bound.

**Why now?** The catalog already has `reconstructable_monotone` and `Reconstructable`;
this cycle supplies the distance arithmetic (`distance_le`, `n_ge`) needed to prove both
the sufficiency and the sharp-failure direction.
