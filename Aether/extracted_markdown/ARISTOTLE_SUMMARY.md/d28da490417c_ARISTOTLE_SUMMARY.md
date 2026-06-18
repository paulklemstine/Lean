# Summary of changes for run 97a3e6df-466e-4727-a2f5-b0d8da034d9f
## Completed: Proof-Theoretic Ordinal Analysis Framework

### Deliverables

**1. `Pythagorean/ProofTheoreticOrdinals.lean`** — 221 lines, 0 sorries, all proofs verified with clean axioms (propext, Classical.choice, Quot.sound only).

**2. `FUTURE_DIRECTIONS.md`** — 5 testable research conjectures extending the framework.

### Mathematical Content

The file formalizes an abstract framework for proof-theoretic ordinal analysis, capturing the core insight that formal theories can be characterized by the ordinals they prove well-ordered.

**Core Structure:**
- `OrdinalTheory` — theories modeled as downward-closed, bounded sets of ordinals
- `OrdinalTheory.pto` — the proof-theoretic ordinal (supremum of provably WO ordinals)
- `depthDist` — ordinal-valued quasi-metric on theory space

**Main Theorems (all fully proved, no sorry):**

1. **`Iio_sSup_subset_initSeg`** — Half-saturation: every ordinal below the PTO belongs to the provably-WO set. Proved by contraposition using csSup_le and downward closure.

2. **`pto_monotone`** — PTO is monotone under theory inclusion (T₁ ≤ T₂ → pto(T₁) ≤ pto(T₂)). Uses csSup_le_csSup.

3. **`pto_le_of_not_mem`** — Any ordinal *not* provably WO is ≥ the PTO. The contrapositive of half-saturation.

4. **`pto_sandwich`** — Elements in the difference T₂ \ T₁ are sandwiched: pto(T₁) ≤ α ≤ pto(T₂).

5. **`pto_ofOrdinal_limit`** — The canonical theory for a limit ordinal α has PTO exactly α. Uses `Order.IsSuccLimit.sSup_Iio`.

6. **`depthDist_self_eq_zero`**, **`depthDist_comm`**, **`depthDist_eq_zero_iff`** — The quasi-metric vanishes on the diagonal, is symmetric, and separates points (zero iff equal PTOs).

7. **`join_pto_eq_max`** — The PTO of the join of two theories equals the maximum of their PTOs. Uses csSup_union.

**Discovery:** The originally conjectured `pto_strict_mono_of_ssubset` (strict inclusion ⟹ strict PTO) is **false** — counterexample: {β | β < ω} ⊂ {β | β ≤ ω} but both have sSup = ω. This is documented in the file with the corrected weaker theorems (`pto_le_of_not_mem`, `pto_sandwich`) that capture the actual structure.