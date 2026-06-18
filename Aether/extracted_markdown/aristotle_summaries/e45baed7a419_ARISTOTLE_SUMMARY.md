# Summary of changes for run 2a3f0865-6abe-4395-8e7a-9163215ae55d
## Tropical Satake Support Reconstruction for GL₃ — Completed

### Formally Verified Mathematics (Lean 4)

All theorems are fully proved with no `sorry` and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Two Lean files in `Tropical/`:

**`FerrersShape.lean`** — Core definitions and reconstruction theorem:
- `FerrersShape` structure: finite downward-closed subsets of ℕ × ℕ
- `rowLen`, `colLen`, `diagLen`: three rank-1 marginal projections
- `row_initialSegment`, `col_initialSegment`: each row/column is an initial segment of ℕ
- `row_eq_range`: row b equals `Finset.range (rowLen S b)`
- `mem_iff_lt_rowLen`: membership characterized as `a < rowLen S b`
- `rowLen_antitone`: row lengths are antitone
- **`ext_of_rowLen`**: Two Ferrers shapes with equal row lengths are equal
- **`ext_of_three_marginals`**: Row + column + diagonal marginals determine the shape

**`Convolution.lean`** — Minkowski sum and cancellation:
- `supportConv`: Minkowski sum of finite sets in ℕ²
- `supportConv_lower`: Minkowski sum of Ferrers shapes is downward-closed
- `convShape`: Ferrers-shape-valued Minkowski sum
- `carrier_subset_convShape`: S ⊆ S ⊕ H when (0,0) ∈ H
- `zero_mem_of_nonempty`: nonempty Ferrers shapes contain (0,0)
- `convShape_singleton_eq`: S ⊕ {(0,0)} = S
- `rowLen_convShape_singleRow`: exact row-length formula for single-row H
- **`supportConv_right_cancel_singleRow`**: Single-row convolution is faithful

### Key Discovery: General Cancellation is FALSE

During the formalization, I discovered that the proposed general cancellation theorem `S ⊕ H = T ⊕ H → S = T` is **false**. Explicit counterexample:
- S with profile (5,3,1), T with profile (5,1,1), H with profile (3,1)
- S ⊕ H = T ⊕ H = shape with profile (7,5,3,1), but S ≠ T

The failure mechanism: H's large row 0 (width 3) dominates the Minkowski-sum contribution at row 1, "masking" the difference between S and T at that row. This is documented in the Lean file and verified computationally in Python.

Cancellation DOES hold when H is a single-row shape (proved) or more generally a rectangle (discussed in the paper). The precise characterization of which H give faithful convolution remains an interesting open question.

### Python Demonstrations (`demo_ferrers.py`)

Seven demos with generated visualizations:
1. Reconstruction from row lengths
2. Three marginals for different shapes
3. Minkowski sum of Ferrers shapes
4. **Counterexample to general cancellation** (with visualization)
5. Single-row cancellation works
6. Support functions and tropical geometry (with additivity verification)
7. GL₃ dominant coweight chamber interpretation

### Research Paper (`paper.md`)

Full paper covering:
- Mathematical content: definitions, theorems, proofs, counterexample analysis
- Tropical Satake interpretation: connection to GL₃ representation theory
- Scientific American-style discussion: "Staircases and Shadows" analogy
- Formal verification details and axiom audit
- Future directions: higher rank, weighted extensions, precise cancellation conditions