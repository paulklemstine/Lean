/-
# Erdős Problem 550 — multipartite framework and the exact base case

This file complements `ErdosProblem550Chvatal.lean`.  It records the structural
facts about complete multipartite graphs that underlie Erdős Problem 550, and
proves the **exact base case** of the conjecture's hierarchy:

  `R(T, K_{1,1}) = n`   for every `n`-vertex tree `T`.

Here `K_{1,1} = K₂` is a single edge, and `R(T, K_{1,1})` is exactly the quantity
`R(T, K_{m₁,m₂})` appearing on the right-hand side of the Erdős–550 bound in the
all-ones case `m₁ = m₂ = 1`.  Combined with `ErdosProblem550Chvatal`, this pins
down the base term of the conjectured recursion.

We also record the **all-ones identification** `K_{1,…,1} ≅ K_k`: the complete
multipartite graph all of whose parts have size one is the complete graph, the
fact that turns the all-ones case of Erdős 550 into Chvátal's theorem.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `R(T, K₂) = n` exactly, with the lower bound supplied by
  the disjoint-clique construction of the companion file and the upper bound by the
  dichotomy "a colouring of Kₙ is either all-red (so contains the tree) or has a blue
  edge".
Experiment (Experimenter): Formalise `RamseyArrows n T K₂` via the dichotomy, and read
  off the lower bound from `chvatal_lower_bound` specialised to `k = 2`.
Analysis (Analyst): The upper bound only needs `T ⊑ ⊤` (every graph embeds in the
  complete graph on the same vertex set) and the equivalence "blue edge ↔ K₂ ⊑ blue".
  No acyclicity of `T` is needed for the upper bound; the tree hypothesis enters only
  through the lower bound (which needs connectivity and `n ≥ 1`).
Critique (Critic): The all-ones identification must be stated as genuine mutual
  containment / isomorphism, not a definitional rename, to avoid a trivial theorem.
Synthesis (PI): The base case `R(T,K_{1,1}) = n` is exact and pairs with the general
  multipartite containment lemmas to frame the inductive structure of Erdős 550.
-/

import Novelty.ErdosProblem550Chvatal

open SimpleGraph

namespace Erdos550

/-- The complete multipartite graph `K_{m₀,…,m_{k-1}}` with parts indexed by `Fin k`,
the `i`-th part having `m i` vertices. -/
abbrev Kmultipartite {k : ℕ} (m : Fin k → ℕ) : SimpleGraph ((i : Fin k) × Fin (m i)) :=
  completeMultipartiteGraph (fun i => Fin (m i))

/-- Containment follows from the subgraph relation on a common vertex set. -/
theorem isContained_of_le {V : Type} {G H : SimpleGraph V} (h : G ≤ H) : G ⊑ H :=
  ⟨⟨⟨id, fun hh => h hh⟩, Function.injective_id⟩⟩

/-
**All-ones identification (≤ direction).**  `K_k` embeds into the complete
multipartite graph all of whose `k` parts have size one.
-/
theorem completeGraph_isContained_allOnes (k : ℕ) :
    (⊤ : SimpleGraph (Fin k)) ⊑ completeMultipartiteGraph (fun _ : Fin k => Fin 1) := by
  constructor;
  constructor;
  swap;
  constructor;
  rotate_left;
  exact fun i => ⟨ i, 0 ⟩;
  all_goals simp +decide [ Function.Injective ]

/-
**All-ones identification (≥ direction).**  The complete multipartite graph all
of whose `k` parts have size one embeds into `K_k`. Together with
`completeGraph_isContained_allOnes` this expresses `K_{1,…,1} ≅ K_k`.
-/
theorem allOnes_isContained_completeGraph (k : ℕ) :
    completeMultipartiteGraph (fun _ : Fin k => Fin 1) ⊑ (⊤ : SimpleGraph (Fin k)) := by
  use ⟨ fun x => x.1, by
    aesop ⟩
  generalize_proofs at *;
  exact fun x y h => by cases x; cases y; aesop;

/-- A complete multipartite graph is contained in the complete graph on its
(disjoint-union) vertex set: blue cliques live inside blue complete graphs. -/
theorem Kmultipartite_isContained_completeGraph {k : ℕ} (m : Fin k → ℕ) :
    Kmultipartite m ⊑ (⊤ : SimpleGraph ((i : Fin k) × Fin (m i))) :=
  isContained_of_le le_top

/-
**Base-case upper bound.**  Every red/blue colouring of `Kₙ` either is all red
(hence contains the `n`-vertex graph `T` as a red copy, since `T ⊑ Kₙ`) or has a
blue edge (a blue `K₂`).  Thus `R(T, K₂) ≤ n`.
-/
theorem ramsey_tree_edge_upper {n : ℕ} (T : SimpleGraph (Fin n)) :
    RamseyArrows n T (⊤ : SimpleGraph (Fin 2)) := by
  intro G
  by_cases h_all_red : ∀ u v, u ≠ v → G.Adj u v;
  · left;
    convert isContained_of_le _;
    exact fun u v huv => h_all_red u v ( by aesop );
  · simp +zetaDelta at *;
    obtain ⟨ u, v, hne, h ⟩ := h_all_red; right; use ⟨ fun i => if i = 0 then u else v, by
      simp +decide [ hne, h ];
      exact ⟨ Ne.symm hne, by rwa [ SimpleGraph.adj_comm ] ⟩ ⟩ ;
    intro i j; fin_cases i <;> fin_cases j <;> aesop;

/-- **Exact base case of Erdős 550.**  For every `n`-vertex tree `T`,
`R(T, K_{1,1}) = R(T, K₂) = n`: the colouring of `Kₙ` arrows to `(T, K₂)` while the
colouring of `K_{n-1}` does not.  The upper bound is `ramsey_tree_edge_upper`; the
lower bound is the `k = 2` instance of `chvatal_lower_bound`. -/
theorem ramsey_tree_edge {n : ℕ} (T : SimpleGraph (Fin n)) (hT : T.IsTree) :
    RamseyArrows n T (⊤ : SimpleGraph (Fin 2)) ∧
      ¬ RamseyArrows (n - 1) T (⊤ : SimpleGraph (Fin 2)) := by
  refine ⟨ramsey_tree_edge_upper T, ?_⟩
  have h := chvatal_lower_bound T hT (k := 2) (by norm_num)
  simpa using h

end Erdos550