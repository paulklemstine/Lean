Formalize a focused bridge file completing the finite Rips-clique ↔ tropical-threshold story, but only through explicit intermediate lemmas that are likely to close in Lean.

Create a new file:
`Catalog/Bridges/RipsCliqueTropicalBridge.lean`

Imports should be minimal and centered on the existing tropical bridge foundation, especially:
- `Catalog/Bridges/RipsTropicalFunctor.lean`
plus whatever standard Mathlib finite-set/cardinality imports are actually needed.

Work in the context:
- `variable (α : Type*) [Fintype α] [DecidableEq α] [PseudoEMetricSpace α]`

Define:
- `IsRipsClique (ε : ℝ≥0∞) (s : Finset α) : Prop := ∀ ⦃x y⦄, x ∈ s → y ∈ s → x ≠ y → edist x y ≤ ε`
- `cliqueCount (m : ℕ) (ε : ℝ≥0∞) : ℕ := ...` as the cardinality of `m`-element finsets that are Rips cliques.

Target only the following theorem pipeline, with complete proofs and no `sorry`:

1. Monotonicity:
   `IsRipsClique_mono : ε₁ ≤ ε₂ → IsRipsClique α ε₁ s → IsRipsClique α ε₂ s`.

2. Finite extension lemma for finsets:
   prove that if `x ≠ y`, `2 ≤ m`, and `m ≤ Fintype.card α`, then there exists `s : Finset α` with
   `s.card = m`, `x ∈ s`, and `y ∈ s`.
   Use existing finite-set/cardinality lemmas rather than building ad hoc combinatorics.
   If the strongest exact statement is awkward, prove a helper by choosing an `m-2` subset of the complement of `{x,y}` and then inserting `x,y`.

3. Pairwise-threshold ↔ tropical threshold:
   identify and use the exact theorem already available in `Catalog/Bridges/RipsTropicalFunctor.lean` relating `tropBirthSum α ≤ ε` to pairwise edge bounds / complete 1-skeleton. Do not restate an unprovable variant; instead adapt your downstream statements to the theorem that already exists in the catalog.

4. All `m`-cliques characterization:
   prove a theorem of the form
   `all_m_cliques_iff_pairwise`:
   for `2 ≤ m` and `m ≤ Fintype.card α`,
   `((∀ s : Finset α, s.card = m → IsRipsClique α ε s) ↔ ∀ x y, x ≠ y → edist x y ≤ ε)`.
   Proof strategy:
   - forward direction: extend `{x,y}` to an `m`-element finset and apply the hypothesis;
   - reverse direction: immediate from the definition of `IsRipsClique`.

5. Combine (3) and (4) to obtain the tropical bridge:
   `all_m_cliques_iff_tropBirthSum_le`.
   This theorem should be stated in the exact orientation that best matches the imported theorem from `RipsTropicalFunctor`.

6. Maximal clique count characterization:
   prove that under `m ≤ Fintype.card α`,
   `cliqueCount α m ε = Nat.choose (Fintype.card α) m`
   iff every `m`-element finset is a clique; then combine with step (5) to derive
   `cliqueCount_eq_choose_iff_tropBirthSum_le` under `2 ≤ m` and `m ≤ Fintype.card α`.
   Recommended proof strategy:
   - identify `Finset.univ.filter (fun s : Finset α => s.card = m)` with `Finset.powersetCard m Finset.univ` or use a known cardinality theorem for `powersetCard`;
   - show the clique-filtered family is a subfinset of all `m`-subsets;
   - equality of cardinalities at the maximum implies every `m`-subset survives the filter.
   Keep the counting argument purely finite/combinatorial.

7. Optional final corollary:
   if there is an existing theorem in `RipsTropicalFunctor` expressing completeness of the Rips 1-skeleton, add
   `ripsComplete_iff_tropBirthSum_le`
   as a thin wrapper, but only if it is genuinely immediate from imported results.

Important constraints:
- Prefer theorem names and statements that align with what already exists in `Catalog/Bridges/RipsTropicalFunctor.lean`.
- Avoid header-only declarations. Every theorem included must be fully proved.
- If a previously intended theorem is too brittle, replace it by the exact imported equivalent plus a wrapper lemma.
- Keep the file standalone and mathematically clean: definitions, helper lemmas, main equivalences, then counting corollaries.

Deliverable: one complete Lean file with no `sorry`, no unfinished theorem bodies, and theorem statements specialized enough to be provable with current Mathlib/library support.