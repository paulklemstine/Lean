# Future Directions: Homological Information Theory for Finite Sites

## Synthesis

The filtration subadditivity theorem established in `Pythagorean/ProbeComplexity/CompressionFiltration.lean` opens a systematic program connecting sheaf compression to entropy, representation theory, and algebraic K-theory. The key insight — that compression is controlled by extension data and can be decomposed along filtrations — creates a foundation for five interrelated research directions. Together, they form the beginning of **homological information theory**: a framework in which information complexity is not merely a number, but a structural invariant that decomposes along exact sequences, respects filtrations, and admits spectral-sequence-style computations. Each conjecture below is designed to be falsifiable through either formal proof or computational experiment.

---

## Direction 1: Split Exact Additivity

**Conjecture:** For every split filtration on a finite site, compression is exactly additive:
```
κ_sh(J, F) = Σᵢ κ_sh(J, grᵢF)
```
when each extension in the filtration splits (i.e., the total presheaf is isomorphic to the direct sum of its graded pieces).

**Test:** Enumerate all split filtrations on sites with 2–4 objects and compare exact compression numbers with graded sums. A single counterexample refutes the conjecture. The Python demo (`demo.py`) includes tests for this setting.

**Impact:** If true, this establishes compression as a genuinely additive invariant on split exact sequences, placing it in the landscape of algebraic K-theory. If false, the failure mode reveals obstructions to additivity that are themselves interesting invariants.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionFiltration.lean` — `compression_split_le` (upper bound direction)
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — `sheafCompressionNumber_coprod_le`

**Proof Strategy:** Prove the reverse inequality by showing that any separator for the coproduct restricts to a separator for each component. The main difficulty is extracting component-wise separation from coproduct separation without additional structural assumptions.

**Domain Bridges:** Algebraic K-theory (Grothendieck group), representation theory (split exact sequences), information theory (independence of sources implies entropy additivity).

**Lineage:** Extends `compression_extension_le` from upper bound to equality in the split case.

**Ambition:** ★★★☆☆ — Achievable with current formalism; requires careful analysis of the reverse inequality.

---

## Direction 2: Submodularity of Compression on the Lattice of Subpresheaves

**Conjecture:** For subpresheaves A, B ≤ F on a finite site with Grothendieck topology J:
```
κ(A ∨ B) + κ(A ∧ B) ≤ κ(A) + κ(B)
```
where ∨ and ∧ are join and meet in the subpresheaf lattice.

**Test:** Brute-force all pairs (A, B) of subpresheaves on sites with 2–3 objects and 2–3 sections per object. Compute all four compression numbers and verify the inequality. A counterexample is equally valuable — it would show compression is not submodular and would identify the structural obstruction.

**Impact:** If true, compression becomes a submodular function, unlocking greedy algorithms and matroid-theoretic methods for filtration optimization. If false, the failure structure characterizes exactly when greedy decomposition fails.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionFiltration.lean` — `compression_le_of_sep_implies` (monotonicity)
- `Catalog/Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean` — `compressionNumber_le_of_sep`

**Proof Strategy:** Attempt a modular inequality proof using the lattice structure of probe families. Key step: construct a separator for A∨B from separators for A and B, using their intersection to control the redundancy.

**Domain Bridges:** Combinatorial optimization (submodular function minimization), matroid theory, entropy inequalities (submodularity of Shannon entropy).

**Lineage:** Builds on monotonicity (`compression_le_of_sep_implies`) and extension inequality.

**Ambition:** ★★★★☆ — Would be a significant structural result; counterexample search is computationally tractable.

---

## Direction 3: Spectral Stabilization of Filtration Bounds

**Conjecture:** For any presheaf F on a finite site, the minimum filtration upper bound stabilizes: there exists a filtration length N₀ such that for all filtrations of length ≥ N₀, the minimum graded bound over all filtrations of that length equals the minimum over all filtrations of length N₀.

More precisely: define
```
β(F, n) = min { Σᵢ κ(grᵢ) : filtrations of length n }
```
Then β(F, n) is eventually constant.

**Test:** For small presheaves on 2–3 object sites, enumerate all filtrations by length (up to length = number of subpresheaves) and compute β(F, n). Check whether the sequence stabilizes.

**Impact:** If true, there exists an "optimal decomposition complexity" that is a canonical invariant of the presheaf, independent of the filtration chosen (once it is fine enough). This would be the compression analogue of spectral sequence convergence.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionFiltration.lean` — `filtrationUpperBound`, `compression_filtration_chain_le`

**Proof Strategy:** Use the finiteness of the subpresheaf lattice to bound the number of distinct filtrations. Show that refinement cannot increase the minimum bound (or show it by explicit construction of common refinements).

**Domain Bridges:** Spectral sequences (convergence), optimization (convergence of relaxations), persistent homology (stability of barcodes).

**Lineage:** Direct extension of the filtration framework in `CompressionFiltration.lean`.

**Ambition:** ★★★★★ — Would establish a canonical "spectral complexity" invariant; computationally testable on small examples.

---

## Direction 4: Derived Compression Invariants

**Conjecture:** There exist higher compression invariants κⁿ(J, F) for n ≥ 1, generalizing κ = κ⁰, that form a long exact sequence:
```
... → κⁿ(A) → κⁿ(B) → κⁿ(Q) → κⁿ⁺¹(A) → ...
```
for each short exact sequence 0 → A → B → Q → 0 of presheaves.

**Test:** Define κ¹ as the "compression defect of the extension": κ¹(A → B → Q) = κ(A) + κ(Q) - κ(B). Check whether κ¹ satisfies its own long exact sequence on small examples. If not, attempt to modify the definition to achieve exactness.

**Impact:** This would establish a full cohomological theory of information complexity, with sheaf compression as the H⁰ and higher invariants measuring the cost of consistency checking across overlapping data.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionFiltration.lean` — `compressionDefect`
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — `compressionDefect_nonneg`

**Proof Strategy:** Model after the definition of derived functors via projective/injective resolutions. The key challenge is defining κⁿ intrinsically (not just as a defect of the previous level) and showing functoriality.

**Domain Bridges:** Homological algebra (derived functors), algebraic topology (cohomology), quantum information theory (higher-order entanglement measures).

**Lineage:** Grand challenge building on the entire compression framework.

**Ambition:** ★★★★★ — Paradigm-shifting if achievable; currently speculative but falsifiable through small examples.

---

## Direction 5: Compression-Preserving Refinement and Jordan–Hölder Uniqueness

**Conjecture:** If a presheaf F admits two composition series (maximal filtrations with simple graded pieces), then the multisets of compression numbers of the simple constituents are equal:
```
{κ(S₁), ..., κ(Sₘ)} = {κ(T₁), ..., κ(Tₘ')}   (as multisets)
```
for any two composition series with simple graded pieces S₁, ..., Sₘ and T₁, ..., Tₘ'.

**Test:** On sites with 2–3 objects, enumerate all composition series of small presheaves. Compare the multisets of compression numbers. A counterexample refutes the conjecture.

**Impact:** This would be a compression-theoretic Jordan–Hölder theorem: the complexity profile of a presheaf, measured by its simple constituents' compressions, is a canonical invariant. This is the bridge to representation-theoretic complexity theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionFiltration.lean` — `compression_eq_of_sep_equiv` (invariance under isomorphism)
- `Catalog/Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean` — `compressionNumber`

**Proof Strategy:** Adapt the classical Jordan–Hölder proof (via Schreier refinement theorem) to the compression setting. The key step is showing that common refinements preserve the multiset of compression numbers — this uses the extension inequality and isomorphism invariance.

**Domain Bridges:** Representation theory (Jordan–Hölder theorem, composition series), algebraic number theory (prime factorization uniqueness), modular representation theory.

**Lineage:** Builds on split decomposition and isomorphism invariance.

**Ambition:** ★★★★☆ — Significant structural result; the statement is precise and the classical proof template exists but the adaptation is nontrivial.
