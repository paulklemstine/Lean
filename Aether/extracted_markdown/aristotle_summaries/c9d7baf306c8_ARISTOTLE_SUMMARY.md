# Summary of changes for run bd8ad397-9b18-47c2-ada1-46dd35fcc56b
## What was delivered

I created a new, self-contained Lean development formalizing the mathematical core of Tononi's Integrated Information Theory (IIT), plus a research-directions document.

**New files (under `Speculative/IIT/`):**
- `Foundations.lean` — a complete, `sorry`-free formalization that builds cleanly and depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
- `FUTURE_DIRECTIONS.md` — five falsifiable conjectures extending the work, each with a "key insight" and "why now" justification.

**Mathematical content (all proved, no `sorry`):**

Layer 1 — Discrete Kullback–Leibler divergence `klDivFin`:
- `klDivFin_term_le`: the per-coordinate Gibbs bound `p − q ≤ p·log(p/q)`.
- `klDivFin_nonneg`: Gibbs' inequality (KL ≥ 0 for probability mass functions, under absolute continuity), proved from scratch.
- `klDivFin_eq_zero_iff`: the equality case — KL vanishes iff the distributions coincide (via the strict log bound).

Layer 2 — Effective information across a bipartition (`crossInfo`):
- `crossInfo_nonneg`: a cut never destroys negative information.
- `crossInfo_eq_zero_iff_reducible`: the information-theoretic heart of IIT — a cut has zero effective information exactly when the two parts are probabilistically independent (the cut is "reducible").
- `crossInfo_pos_of_irreducible`: irreducibility ⇒ strictly positive effective information.

Layer 3 — Integrated information `Φ` as the Minimum Information Partition (MIP):
- `Phi_le`, `exists_mip`: Φ is a lower bound on every cut and is attained — it really is the *minimum* information partition.
- `Phi_nonneg`.
- `Phi_eq_zero_iff` (main dichotomy): Φ = 0 iff some cut factorizes the system.
- `Phi_pos_iff`: Φ > 0 iff the system is irreducible across *every* cut — the formal statement that an integrated system cannot be decomposed into independent parts.
- `Phi_antitone_cuts`: monotonicity of Φ as the family of candidate partitions grows.

**Worked examples (proved):** two independent uniform bits give Φ = 0 (reducible), while two perfectly correlated bits give Φ > 0 (genuinely integrated).

The directional proof sketches are included in-file as `-- !-- ... -- !--` comment blocks, as requested. The build was verified module-by-module and a `sorry`/`exact?` scan confirms none remain in the proofs.