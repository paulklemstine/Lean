# Summary of changes for run c59a8274-e4e4-42b1-ab61-b435a08ac83c
## Tropical Curves and the Moduli Space M_g^trop

Created `Tropical/TropicalModuliCurves.lean` (also mirrored in `Catalog/Tropical/`) and `FUTURE_DIRECTIONS.md`.

### What was formalized

The file formalizes tropical curves as combinatorial objects — finite metric graphs abstracted via degree sequences satisfying the handshaking constraint — and proves structural theorems about the tropical moduli space M_g^trop.

**Core definitions:**
- `CombType`: A combinatorial type of a tropical curve (vertex count, edge count, degree sequence with handshaking)
- `CombType.genus`: The cycle rank / first Betti number g = |E| − |V| + 1
- `CombType.IsStable`: Stability condition (every vertex has valence ≥ 3), the tropical analogue of Deligne–Mumford stability
- `TropicalCurve`: A combinatorial type equipped with positive real edge lengths

**Proved theorems (all sorry-free, verified with standard axioms only):**

1. **`stable_three_nV_le_two_nE`** — For stable tropical curves, 3|V| ≤ 2|E|. The fundamental inequality from which all moduli dimension bounds follow.

2. **`stable_edge_bound`** — The moduli dimension bound: |E| ≤ 3g − 3. This shows each cone in M_g^trop has dimension ≤ 3g − 3.

3. **`trivalent_edge_eq`** — For trivalent (3-regular) graphs, |E| = 3g − 3 exactly. Trivalent graphs correspond to top-dimensional cones in M_g^trop, establishing dim(M_g^trop) = 3g − 3.

4. **`stable_genus_ge_two`** — Stable tropical curves with ≥ 1 vertex have genus ≥ 2. This is why M_g^trop is first interesting at g = 2.

**Additional proved results:**
- `minDeg_nV_le_two_nE`: Generalization to arbitrary minimum degree k
- `regular_edge_eq`: For k-regular graphs, (k−2)|E| = k·g − k
- `regular_handshaking`: For k-regular graphs, k|V| = 2|E|
- `stable_nV_le_nE`, `stable_vertex_bound`: Supporting inequalities
- `TropicalCurve.totalLength_pos`: Total length of a tropical curve is positive

Each main theorem includes PEGB structure: worked examples (K₄, theta graph, Petersen graph), generalizations to arbitrary minimum degree/regularity, and boundary cases showing where hypotheses are essential.

### FUTURE_DIRECTIONS.md

Contains 5 research directions: marked curves (3g−3+n bound), Euler characteristic for disconnected graphs, tropical balancing condition in ℤⁿ, contraction morphisms and the face poset of M_g^trop, and the tropical Torelli map via graph Laplacians.