Develop a coherent Lean 4 file formalizing the topology of finite argumentation frameworks via conflict-free sets, and explicitly correct the flawed original conjecture about preferred extensions.

Start from a finite Dung argumentation framework AF = (A,R), represented on a finite type of arguments α with a relation attacks : α → α → Prop (or a finite graph-style structure if a suitable catalog abstraction already exists). Work entirely in the finite setting.

Primary goals:

1. Refute the original conjecture precisely.
Define what it would mean for the preferred extensions to form a simplicial complex on A. Then give a concrete finite counterexample showing this is false in general because preferred extensions are maximal admissible sets and need not be downward closed. Keep this part simple and fully formalized: construct a tiny AF where some preferred extension S exists but a subset T ⊂ S is not preferred, hence the family of preferred extensions is not a simplicial complex.

2. Introduce the correct simplicial complex.
Define the family K_cf(AF) of conflict-free sets:
  S ⊆ A is conflict-free iff there do not exist a,b ∈ S with attacks a b.
Prove downward closure, so K_cf(AF) is a simplicial complex / set family closed under subsets. Use whichever existing notion in Mathlib or the catalog is most natural: a finite set family, abstract simplicial complex, or down-closed finite subsets. Do not invent unnecessary abstraction if a simple finite-set-family development is easier.

3. Relate K_cf(AF) to graph theory.
Define the undirected conflict graph G(AF) with an edge between a and b when attacks a b or attacks b a. Prove that K_cf(AF) coincides with the independence complex of G(AF). This should be the central theorem. If a graph-theoretic independence complex already exists in Mathlib or Catalog/FINAL, reuse it; otherwise define the needed notion directly and prove extensional equality of face families.

4. Derive concrete structural theorems.
Aim for several clean, complete theorems such as:
  - singleton vertices are always faces;
  - a 2-element set {a,b} is a face iff there is no attack in either direction between a and b;
  - facets of K_cf(AF) are exactly inclusion-maximal conflict-free sets;
  - if an argument is isolated (neither attacks nor is attacked by anything), then K_cf(AF) is a cone with apex that argument, yielding contractibility at the combinatorial level;
  - for disjoint unions of frameworks / conflict graphs, describe K_cf as the join of the corresponding complexes if that notion is available, otherwise at least prove a product-style face characterization.

5. Compute or characterize small examples.
Fully formalize at least one nontrivial family, such as:
  - a mutual-attack pair gives two vertices and no edge;
  - a directed 3-cycle has conflict graph K3, so K_cf consists only of ∅ and singletons;
  - an edgeless framework gives the full simplex on A.
These examples should culminate in explicit descriptions of the face sets.

6. Keep the development coherent and complete.
Do not mix in unrelated ECOC, coding theory, tropical geometry, or placeholder declarations. Produce one self-contained file with no sorrys, no unfinished theorem statements, and clear naming.

Proof strategy:
- Use finite-set extensionality aggressively.
- Favor simple lemmas about subset closure and pairwise conflict-freeness.
- Translate argumentation statements into graph-independence statements and reuse graph lemmas when possible.
- If full homology is too heavy, stop at the simplicial-complex / independence-complex equivalence plus explicit examples and cone/contractibility-style combinatorial results.

Deliverable expectations:
- A complete Lean file that typechecks.
- At least one theorem explicitly showing the preferred-extension family is not a simplicial complex in general.
- A main theorem identifying conflict-free sets with the independence complex of the conflict graph.
- Several small example computations.

If there is strong existing support in Catalog/FINAL for finite graphs, simplicial complexes, independence sets, or hereditary set systems, build on it directly and cite those files in comments.