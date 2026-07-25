import Mathlib
import Computation.CircuitComplexity.Monotone.ApproximationMethod

/-!
# Monotone CLIQUE Lower Bound via Approximation

This file defines the k-CLIQUE predicate on finite graphs and proves
that it is monotone. It then instantiates the abstract approximation
sandwich lower bound to obtain monotone circuit size lower bounds
for CLIQUE from certified approximation sandwiches.

## Main Definitions

- `hasClique` — the k-CLIQUE predicate on `SimpleGraph (Fin n)` (propositional)
- `cliqueBool` — decidable Boolean version of the clique predicate

## Main Results

- `hasClique_mono` — the clique predicate is monotone under edge addition
- `clique_monotone_size_lower_bound_of_approximation` — the Razborov skeleton:
  if a certified approximation sandwich defeats all circuits of size ≤ s,
  then CLIQUE has monotone circuit size > s

## References

* A. A. Razborov, "Lower bounds on the monotone complexity of some Boolean functions",
  Doklady Akademii Nauk SSSR, 1985.
-/

noncomputable section
open Classical Finset MonotoneComplexity

namespace MonotoneClique

/-! ## Graph Ordering -/

/-- The subgraph ordering on simple graphs: `G ≤ H` iff every edge of `G`
    is also an edge of `H`. -/
instance graphPreorder (V : Type*) : Preorder (SimpleGraph V) where
  le G H := ∀ v w, G.Adj v w → H.Adj v w
  le_refl G := fun _ _ h => h
  le_trans G H K hGH hHK := fun v w h => hHK v w (hGH v w h)

/-! ## CLIQUE Predicate -/

/-- The **k-CLIQUE predicate** (propositional version): `hasClique k G` holds iff
    the graph `G` contains a clique of size `k`. -/
def hasClique {V : Type*} (k : ℕ) (G : SimpleGraph V) : Prop :=
  ∃ S : Finset V, G.IsNClique k S

/-
The k-CLIQUE predicate is **monotone**: if `G ≤ H` (as subgraphs)
    and `G` contains a k-clique, then `H` also contains a k-clique.

    Proof: A k-clique `S` in `G` is pairwise adjacent in `G`.
    Since every edge of `G` is in `H`, `S` is pairwise adjacent in `H` too.
-/
theorem hasClique_mono {V : Type*} (k : ℕ) :
    ∀ G H : SimpleGraph V,
      (∀ v w, G.Adj v w → H.Adj v w) →
      hasClique k G → hasClique k H := by
  intro G H hGH hG
  obtain ⟨S, hS⟩ := hG
  use S;
  exact ⟨ fun v hv w hw hne => hGH v w ( hS.1 hv hw hne ), hS.2 ⟩

/-- Boolean version of the clique predicate, using classical decidability. -/
def cliqueBool (n k : ℕ) (G : SimpleGraph (Fin n)) : Bool :=
  if hasClique k G then true else false

/-
`cliqueBool` is monotone with respect to the subgraph ordering.
-/
theorem cliqueBool_monotone (n k : ℕ) :
    Monotone (cliqueBool n k) := by
  exact fun G H hGH hG => by have := hasClique_mono k G H hGH ( by unfold cliqueBool at hG; aesop ) ; unfold cliqueBool; aesop;

/-- Package the clique predicate as a `MonotoneBoolFun`. -/
def cliqueMonotoneBoolFun (n k : ℕ) :
    MonotoneBoolFun (SimpleGraph (Fin n)) :=
  ⟨cliqueBool n k, cliqueBool_monotone n k⟩

/-! ## Approximation Sandwich for CLIQUE -/

/-- A certified approximation sandwich for the k-CLIQUE predicate.
    The positive instances contain k-cliques, negative ones do not. -/
structure CliqueApproxSandwich (n k : ℕ) extends
    ApproximationSandwich (SimpleGraph (Fin n)) where
  /-- Every positive instance contains a k-clique -/
  pos_has_clique : ∀ G ∈ pos, cliqueBool n k G = true
  /-- No negative instance contains a k-clique -/
  neg_no_clique : ∀ G ∈ neg, cliqueBool n k G = false

/-! ## The Razborov Skeleton Theorem -/

/-
**Monotone CLIQUE Circuit Size Lower Bound via Approximation**.

    If a certified approximation sandwich for k-CLIQUE on `n`-vertex graphs
    defeats all monotone circuits of size at most `s` (i.e., every such circuit
    disagrees with the clique predicate on some test graph), then every monotone
    circuit computing k-CLIQUE has size greater than `s`.

    This is the formalized reduction from combinatorial approximation to circuit
    lower bounds — the conceptual core of Razborov's method.
-/
theorem clique_monotone_size_lower_bound_of_approximation
    {n k s : ℕ}
    (A : CliqueApproxSandwich n k)
    (happrox :
      ∀ C : MonotoneCircuitProfile (SimpleGraph (Fin n)),
        C.size ≤ s →
        ∃ G, G ∈ A.pos ∪ A.neg ∧
          C.eval G ≠ cliqueBool n k G) :
    ∀ C : MonotoneCircuitProfile (SimpleGraph (Fin n)),
      (∀ G, C.eval G = cliqueBool n k G) → s < C.size := by
  exact fun C hC => not_le.mp fun h => by obtain ⟨ G, hG₁, hG₂ ⟩ := happrox C h; exact hG₂ <| hC G;

end MonotoneClique