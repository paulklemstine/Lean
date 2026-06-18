# Future Directions: Provability Logic GL and Tropical Extensions

## What We Built

A self-contained Lean 4 formalization (`Catalog/Logic/ProvabilityLogicComplete.lean`) of Godel-Lob provability logic (GL) via Kripke semantics, with 14 sorry-free theorems including:

- **Lob's theorem** (`loeb_semantic`): The semantic version, proved by well-founded induction on the converse accessibility relation. Uses no axioms beyond Lean's kernel.
- **Second incompleteness theorem** (`second_incompleteness`): A sound consistent world cannot prove its own consistency. Also axiom-free.
- **Tangling dichotomy** (`tangling_dichotomy_ext`): Every sound world is either terminal (vacuously omniscient) or tangled (has blind spots about its own soundness).
- **GL-strict-order bridge** (`gl_frame_strict_order`): GL frames are exactly well-founded strict partial orders.
- **GLP frames** (`GLPF`, `glp_loeb`): Polymodal provability logic with Lob at every level.
- **Tropical cost semantics** (`tcost`, `tcost_double_box`, `tropical_box_bound`): A novel quantitative semantics where the box modality adds +1 "reflection overhead."

---

## Direction 1: De Jongh-Sambin Fixed-Point Theorem

**Conjecture**: For any modal formula phi(p) where p occurs only under box, there exists a unique (up to GL-equivalence) formula psi not containing p such that GL validates psi <-> phi(psi). This can be formalized semantically using our `gforces` relation: define substitution on `MF`, formalize "modalized in p," and prove the fixed-point existence and uniqueness.

**The key insight is** that the fixed-point construction proceeds by iterating substitution, and termination follows because each step strictly reduces the modal depth of occurrences of p. Our `tcost` function could provide a quantitative measure of this convergence.

**Why now?** We have all the infrastructure: `MF` formulas, `gforces` semantics, `loeb_semantic`, and the well-founded induction machinery. The fixed-point theorem is the deepest result in provability logic that has never been machine-verified. The concrete test cases are clear: phi(p) = not(box p) should give psi = not(box bot) (the Godel sentence), and phi(p) = box p should give psi = top (the Henkin sentence).

---

## Direction 2: Tropical Lob and Proof Complexity Bounds

**Conjecture**: The tropical cost function satisfies a full tropical Lob's theorem: if tcost(w, box(box phi -> phi)) < infinity, then tcost(w, box phi) < infinity AND tcost(w, box phi) <= tcost(w, box(box phi -> phi)). Moreover, the iterated consistency hierarchy Con^n has tropical cost exactly n at any sound world with depth >= n.

**The key insight is** that our `tcost_double_box` theorem already shows the +2 overhead for double boxing, and `tropical_box_bound` gives the upper bound. Combining these should yield tight bounds on the consistency hierarchy: Con^n costs exactly n because each consistency step adds exactly 1 unit of reflection overhead, matching the +1 in the box clause of `tcost`.

**Why now?** The infrastructure for both the classical GL theory and the tropical cost function are in place. The missing piece is connecting them: showing that worlds of depth n have Con^n cost exactly n would establish the first quantitative proof-complexity result within the GL framework.

---

## Direction 3: Category of GL Frames and Bounded Morphisms

**Conjecture**: GL frames with bounded morphisms (p-morphisms) form a category with finite coproducts (our `GLF.disjointUnion`) and finite products (componentwise R). The tangling dichotomy is preserved by all categorical operations: if each component has a tangled world, so does the product/coproduct.

**The key insight is** that bounded morphisms preserve and reflect the forcing relation, so tangling (failure to force consistency) transfers across morphisms. Our `disjoint_union_left_embed` and `disjoint_union_right_embed` already show the embedding preserves R; the categorical structure formalizes this systematically.

**Why now?** We proved `GLF.disjointUnion` is a GL frame. Extending to products and formalizing morphisms would connect provability logic to Mathlib's category theory library, potentially allowing application of categorical fixed-point theorems (adjoint functor theorem, Knaster-Tarski) to the GL setting.

---

## Direction 4: Ordinal Assignment for GLP Frames

**Conjecture**: Our `natGLPF` frame admits a canonical ordinal assignment where world n at level 0 has ordinal n, and the "limit" of the frame under R_0 corresponds to omega. More ambitiously, there exists a GLP frame on ordinals below epsilon_0 where R_n corresponds to the n-th Veblen function, reproducing the standard ordinal analysis of Peano Arithmetic.

**The key insight is** that the monotonicity condition R_n+1 subset R_n means higher levels "see fewer" worlds, and our `glp_box_weaken` theorem shows how provability transfers across levels. An ordinal assignment that is strictly decreasing under each R_n would connect GLP frame semantics to proof-theoretic ordinals.

**Why now?** We have `GLPF`, `natGLPF`, and `glp_loeb`. The concrete `natGLPF` frame provides a testbed: R_0 is standard greater-than, R_1 requires gap >= 2, etc. The ordinal assignment for this frame is trivial (just the identity), but extending to a frame on ordinals below epsilon_0 would be the first machine-verified connection between polymodal provability logic and ordinal analysis.

---

## Direction 5: Tropical Semantics for Multi-Agent Provability

**Conjecture**: The tropical cost function extends naturally to multi-agent settings where different agents have different accessibility relations (and hence different provability predicates). In a GLP frame interpreted as a multi-agent system, the tropical cost of "agent n proves phi" accounts for the full overhead of agent n's proof search. The monotonicity G.mono ensures that agent n's proofs are at least as expensive as agent m's (for m <= n), formalizing the intuition that stronger proof systems have higher overhead.

**The key insight is** that our `tcost` function already handles the single-agent case via `tcost_box_ge`, and the GLP monotonicity (`G.mono`) provides the inter-agent cost ordering. Defining `tcost_glp` with level-indexed box costs would yield a multi-agent tropical provability theory where the consistency hierarchy has quantitative inter-agent structure.

**Why now?** Both `tcost` and `GLPF` are formalized. The combination is straightforward: define `tcost_glp` using `G.R n` instead of `M.R`, prove the multi-level reflection overhead, and show that the inter-level cost gap is exactly 1 (matching the gap in `natGLPF` where R_n requires n more steps than R_0).
