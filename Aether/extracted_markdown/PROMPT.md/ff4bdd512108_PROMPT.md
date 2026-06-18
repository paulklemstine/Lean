Produce a standalone Lean 4 file in the catalog that formalizes a finite combinatorial optimization model of an ecosystem of theories, following the finite niche/fitness description exactly and avoiding any placeholders, sketches, or entropy/log claims that are hard to complete. Use only results that can be fully proved from standard Mathlib finite-set and cardinality infrastructure.

Set up the following context.
- A finite type `T` with `[Fintype T] [DecidableEq T]`.
- A finite niche type `N` with `[Fintype N] [DecidableEq N]`.
- Integer invariants `connections proofDensity axiomCount : T → ℕ`.
- A standing hypothesis `hax : ∀ t, 0 < axiomCount t`.
- Define `fitness : T → ℚ` by `fitness t = ((connections t : ℚ) * proofDensity t) / axiomCount t`.
- For `E : Finset T` and `niche : T → N`, define `AtEquilibrium E niche : Prop` to mean `Set.InjOn niche (↑E : Set T)`.

The file should prove a coherent cluster of concrete theorems, with full proofs.

Required theorem family:
1. Basic positivity/well-definedness lemmas for `fitness`, e.g. denominator nonzero from `hax`, and `0 ≤ fitness t`.
2. A cardinality bound: if `AtEquilibrium E niche`, then `E.card ≤ Fintype.card N`.
3. A pigeonhole-style converse: if `Fintype.card N < E.card`, then `¬ AtEquilibrium E niche`.
4. If every `t ∈ E` satisfies `q ≤ fitness t`, prove `E.card • q ≤ ∑ t in E, fitness t` in a rational form appropriate for Lean; also derive an average lower bound when `E.Nonempty`.
5. Constructive nichewise selection: given a finite candidate set `C : Finset T`, define for each niche `n` the sub-finset of candidates in niche `n`, and when nonempty choose an element with maximal fitness in that niche using finite argmax machinery. From these choices define a selected finset `selectByNiche C niche` (or equivalent implementation). Prove:
   - every selected element lies in `C`;
   - selected elements have distinct niches, hence the selected finset is at equilibrium;
   - `card (selectByNiche C niche) ≤ Fintype.card N`;
   - if `x ∈ C` and `niche x = n`, then the chosen representative for niche `n` has fitness at least `fitness x`.
6. Uniqueness under strict dominance: formulate a usable hypothesis saying that within each niche, among candidates in `C`, there is a unique fitness-maximizer. Prove that any equilibrium finset `E ⊆ C` containing exactly one representative from each occupied niche and whose elements are all nichewise maximizers must equal `selectByNiche C niche`.

Implementation guidance:
- Prefer `Finset` statements over `Set` unless `Set.InjOn` is the cleanest formulation for equilibrium.
- Keep the development self-contained and robust: define helper lemmas for `Finset.filter`, membership in occupied niches, and cardinality of images/ranges as needed.
- Avoid introducing logs, entropy, powers of two, or any unfinished compression framework. The goal is a complete and elegant finite optimization theory, not an information-theoretic bridge.
- If argmax over `ℚ` is awkward, use the standard finite existence lemma for a maximal element of a nonempty finset under the linear order on `ℚ`, and package the chosen representative with `Classical.choose` cleanly.
- Include module documentation explaining the ecosystem interpretation and the mathematical content.

The result should be a single fully compiling Lean file with no `sorry`, no placeholders, and theorem statements strong enough to count as a substantial verified contribution. Name the file according to the domain, for example something like `Catalog/Novelty/EcosystemEquilibrium.lean` or another appropriate final path.