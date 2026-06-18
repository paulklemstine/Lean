# Future Directions: Discrete Lattice Isoperimetry

## 1. Exact Edge-Isoperimetric Profile of the Triangular Lattice

**Goal**: Prove the exact edge-isoperimetric inequality for finite subsets of the triangular lattice (A₂ root lattice with nearest-neighbor edges).

**Hypothesis**: The minimizers are hexagonal patches in the dual representation, connected to hex lattice results via planar duality. The triangular lattice is the 1-skeleton of the hexagonal tiling, so boundary minimization on one lattice corresponds to a dual problem on the other.

**Proof Strategy**: Transfer the compression arguments from the hex lattice via the duality map. Each hex cell corresponds to a triangular lattice vertex, and hex edges correspond to triangular faces. The edge boundary of a hex cell set maps to the vertex boundary in the triangular lattice under appropriate definitions.

**Cross-Domain Impact**: Triangular lattices model close-packed crystals (FCC metals), Ising models on triangular grids, and hex-based routing networks.

---

## 2. General Discrete Wulff Theorem for Abelian Cayley Graphs

**Goal**: Prove that for finitely generated abelian groups with centrally symmetric generating sets, the edge-isoperimetric minimizers are discrete Wulff shapes — zonotopes determined by the dual norm of the generating set.

**Hypothesis**: For any finite connected set S in such a Cayley graph with |S| = n, the edge boundary satisfies ∂S ≥ ∂W(n), where W(n) is the Wulff shape of volume n. The hex lattice theorem is the special case G = ℤ² with generators {±e₁, ±e₂, ±(e₁-e₂)}.

**Proof Strategy**:
1. Define the anisotropic perimeter norm dual to the generating set
2. Prove compression in each generator direction preserves volume and reduces boundary
3. Show fully compressed sets converge to Wulff zonotopes
4. Compute exact boundary of Wulff shapes via generating function methods

**Key Challenge**: Non-hexagonal lattices (e.g., BCC, diamond) have non-trivial Wulff shapes that are not regular polygons. The compression fixed-point analysis becomes more complex.

---

## 3. Stability Theorem: Quantitative Honeycomb Rigidity

**Goal**: Prove that sets with near-minimal boundary are close to hex patches in symmetric-difference distance.

**Precise Conjecture**: For any connected S ⊂ hex lattice with |S| = 3r²+3r+1 and ∂S ≤ 12r + 6 + δ, there exists a translate T of hexPatch(r) such that |S △ T| ≤ C·δ for a universal constant C.

**Proof Strategy**: 
1. Show that boundary deficit δ controls the number of "non-convex" fibers after compression
2. Use the compression trajectory to bound symmetric difference
3. Derive the optimal constant C by analyzing worst-case fiber deviations

**Applications**: Stability estimates are crucial for statistical mechanics (controlling fluctuations around equilibrium shapes) and for algorithmic applications (certifying that a region is "nearly optimal").

---

## 4. Anisotropic Variant: Weighted Edge Boundary Minimization

**Goal**: For direction-dependent edge weights w(d) on the 6 hex directions, identify the exact minimizers of the weighted boundary ∑ w(d) · (boundary edges in direction d).

**Hypothesis**: Minimizers are distorted hexagonal patches — the Wulff shapes of the anisotropic metric defined by the weights. When weights break the 6-fold symmetry, the optimal shape becomes a non-regular hexagon.

**Proof Strategy**:
1. Define anisotropic compression that respects the weight structure
2. Prove monotonicity of weighted boundary under weighted compression
3. Classify fixed points of anisotropic compression
4. Compute exact weighted boundary of distorted hex patches

**Physical Motivation**: Crystal surfaces in real materials have direction-dependent surface energies. This variant directly models anisotropic crystallization on hex lattices.

---

## 5. Hex-Lattice Mean Curvature Flow via Iterative Compression

**Goal**: Define a discrete mean curvature flow on hex lattice regions by iteratively removing boundary cells with highest local boundary contribution and adding cells to concave boundary positions. Prove convergence to the hex patch shape.

**Precise Formulation**:
1. Define the discrete curvature κ(p) of a boundary cell p as 6 - 2·(internal neighbors of p)
2. At each time step, remove the cell with highest κ and add a cell at the position with lowest κ (maintaining constant volume)
3. Prove this flow converges to a hex patch in O(r²) steps

**Cross-Domain Impact**: This connects discrete differential geometry to combinatorial optimization, providing:
- A polynomial-time algorithm for hex-lattice shape optimization
- A discrete analogue of continuous MCF with convergence guarantees
- A model for grain boundary migration in polycrystalline materials

**Computational Experiments**: Implement and benchmark the flow for regions up to 10⁴ cells. Measure convergence rates and compare with continuous MCF predictions.
