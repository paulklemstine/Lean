# Theorem Trace — Möbius-Ladder Symmetry Certificate

Internal anti-hallucination map. Every name below is taken verbatim from the
Phase A Lean file `Catalog/Geometry/MobiusLadderCertificate.lean`
(namespace `MobiusLadderCertificate`). The prose in `ARTICLE.md` and
`RESEARCH_PAPER.md` states only these results.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `adj3` | def | Adjacency on `ZMod 6`: `j = i+1 ∨ i = j+1 ∨ j = i+3` | "rim plus rungs" description | Def. 1 |
| `adj3_symm` | thm | `adj3` is a symmetric relation | implicit | Def. 1 (well-definedness) |
| `MobiusLadder3` | def | The simple graph `M₃` on `ZMod 6` | "the graph M₃" | Def. 1 |
| `MobiusLadder3.cubic` | thm | `∀ v, degree v = 3` | "every junction has exactly three cables" | Thm. 1 |
| `MobiusLadder3.card_edges` | thm | `edgeFinset.card = 9` | "nine edges" | Prop. 2 |
| `MobiusLadder3.adj_iff_parity` | thm | `Adj i j ↔ i.val % 2 ≠ j.val % 2` (`M₃ ≅ K₃,₃`) | "it IS the utility graph K₃,₃" | Thm. 3 |
| `IsSym` | def | `σ` preserves adjacency both ways | "a symmetry" | Def. 4 |
| `isSym_one` | thm | identity is a symmetry | "doing nothing is a symmetry" | Lem. 5(i) |
| `isSym_mul` | thm | symmetries closed under composition | "chaining symmetries" | Lem. 5(ii) |
| `isSym_inv` | thm | symmetries closed under inverse | "undoing a symmetry" | Lem. 5(iii) |
| `baseEdge` | def | `s(0,1)` | "the anchor edge" | Def. 6 |
| `cert` | def | nine explicit permutations | "nine moves" | Def. 6 |
| `cert_isSym` | thm | every `σ ∈ cert` is a symmetry | "each move is legal" | Lem. 7 |
| `cert_covers` | thm | images of `baseEdge` under `cert` hit all 9 edges | "the anchor reaches everywhere" | Lem. 8 |
| `edge_transitive` | thm | any edge maps to any edge by a symmetry | MAIN: "all edges alike" | Thm. 9 (main) |
| `isSym_addRight` | thm | translation `x ↦ x+c` is a symmetry | "rotations are symmetries" | Lem. 10 |
| `vertex_transitive` | thm | any vertex maps to any vertex by a symmetry | "all corners alike" | Thm. 11 |

No theorem outside this list is asserted as proved in the prose. The broader
"Hamiltonian compression factor κ ≥ 2" program (half-rotation order-2
automorphism, infinite Möbius-ladder family) is presented only as context and
future work, not as a proved result of this file.
