import Mathlib
import Novelty.PosetTheory.CrystalSkeletonContraction

/-!
# Reachability and characters under crystal-skeleton contraction

A crystal skeleton is obtained by replacing each quasicrystal component by one
vertex.  A second contraction replaces each Young-quasisymmetric tile by one
vertex.  This file gives an abstract theorem explaining when these contractions
preserve all order-theoretic information: every directed path in the quotient
lifts to a directed path upstairs precisely when points in each fiber can be
joined in the required direction.

Together with the fiber-character identities from
`CrystalSkeletonContraction`, this separates the two ingredients of the
construction: connectivity controls Bruhat reachability, while finite summation
controls the character.

-- !-- Lab Notes -- !--
Hypothesis: Six ranked conjectures guided the investigation.  (1) Young-
  quasisymmetric tile contraction realizes Bruhat reachability; (2) directed
  fiber connectivity is sufficient for exact path lifting; (3) iterated
  contraction preserves both reachability and character; (4) reachability
  descends to a partial order whenever it is antisymmetric upstairs; (5) the
  tile-character theorem extends from polynomial weights to every additive
  commutative monoid; (6) ordinary undirected fiber connectivity suffices.
  Conjectures (1), (3), and (4) are high-impact bridges between crystal
  combinatorics, order theory, and algebraic characters.  The remaining targets
  isolate the precise structural mechanism.
Experiment: A single quotient edge has unrelated chosen endpoints, so lifting a
  path requires an internal path joining the current representative to the
  source of the next edge.  Directed, rather than merely undirected,
  connectivity is therefore the exact useful hypothesis.
Analysis: The path-lifting induction proves both the one-stage theorem and,
  after applying it twice, the quasicrystal-to-tile-to-Bruhat theorem.  The
  independent fiber-character theorem shows that the same two-stage quotient
  preserves total character.
Critique: Surjectivity is unnecessary for paths whose endpoints are images of
  original vertices.  Antisymmetry is not automatic: it must come from the
  original reachability relation, so it is isolated as an explicit hypothesis
  in the order theorem.  Conjecture (6) fails for a two-vertex fiber with its
  sole edge oriented opposite to the required lift.  Conjecture (1) remains a
  paper-specific identification: the present theorem proves its abstract
  contraction mechanism but does not reconstruct tableaux or Coxeter labels.
  No claim is made that an arbitrary crystal has these properties.
Synthesis: Directed fiber connectivity is the bridge between graph contraction
  and order contraction; associativity of finite fiber sums is the parallel
  bridge between contraction and Young-quasisymmetric character expansions.
-- !-- Lab Notes -- !--
-/

namespace CrystalSkeleton

variable {V Q S A : Type*}

/-- Every two vertices represented by the same contracted vertex are joined by
an oriented path inside the original graph. -/
def DirectedFiberConnected (E : V → V → Prop) (q : V → Q) : Prop :=
  ∀ ⦃x y : V⦄, q x = q y → Relation.ReflTransGen E x y

/-
A quotient edge can be lifted from any prescribed representative of its
source fiber to some representative of its target fiber.
-/
lemma lift_contract_edge (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q) {x : V} {b : Q}
    (h : contract E q (q x) b) :
    ∃ y : V, q y = b ∧ Relation.ReflTransGen E x y := by
  -- By definition of `contract`, we know that there exist $u, v \in V$ such that $q u = q x$, $q v = b$, and $E u v$.
  obtain ⟨u, hu⟩ : ∃ u, q u = q x ∧ ∃ v, q v = b ∧ E u v := by
    exact ⟨ _, h.choose_spec.choose_spec.1, _, h.choose_spec.choose_spec.2.1, h.choose_spec.choose_spec.2.2 ⟩;
  obtain ⟨ v, hv₁, hv₂ ⟩ := hu.2;
  exact ⟨ v, hv₁, hconn hu.1.symm |> fun h => h.trans ( Relation.ReflTransGen.single hv₂ ) ⟩

/-
**Path-lifting theorem.** Under directed connectivity of every fiber, a
path between contracted vertices is equivalent to a path between any chosen
representatives of those fibers.
-/
theorem reflTransGen_contract_iff (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q) {x y : V} :
    Relation.ReflTransGen (contract E q) (q x) (q y) ↔
      Relation.ReflTransGen E x y := by
  refine' ⟨ fun h => _, fun href => path_maps_to_contract E q href ⟩;
  have h_lift : ∀ {a b : Q}, Relation.ReflTransGen (contract E q) a b → ∀ {x : V}, q x = a → ∃ y : V, q y = b ∧ Relation.ReflTransGen E x y := by
    intro a b hab x hx
    induction' hab with a b hab ha hb ih generalizing x;
    · exact ⟨ x, hx, by rfl ⟩;
    · rcases hb hx with ⟨ y, hy, hy' ⟩ ; rcases lift_contract_edge E q hconn ( by aesop : contract E q ( q y ) b ) with ⟨ z, hz, hz' ⟩ ; exact ⟨ z, hz, hy'.trans hz' ⟩ ;
  obtain ⟨ y', hy₁, hy₂ ⟩ := h_lift h rfl; exact hy₂.trans ( hconn hy₁ ) ;

/-
Reachability on original vertices is constant on both coordinates of a
connected contraction fiber.
-/
theorem reachability_fiber_invariant (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q) {x x' y y' : V}
    (hx : q x = q x') (hy : q y = q y') :
    Relation.ReflTransGen E x y ↔ Relation.ReflTransGen E x' y' := by
  rw [ ← reflTransGen_contract_iff E q hconn, ← reflTransGen_contract_iff E q hconn ];
  rw [ hx, hy ]

/-
Two-stage path lifting for the passage from crystal vertices to
quasicrystals and then to Young-quasisymmetric skeleton components.
-/
theorem reflTransGen_two_stage_iff (E : V → V → Prop) (q : V → Q) (r : Q → S)
    (hq : DirectedFiberConnected E q)
    (hr : DirectedFiberConnected (contract E q) r) {x y : V} :
    Relation.ReflTransGen (contract (contract E q) r) (r (q x)) (r (q y)) ↔
      Relation.ReflTransGen E x y := by
  apply Iff.intro;
  · exact fun h => ( CrystalSkeleton.reflTransGen_contract_iff ( contract E q ) r hr ).mp h |> fun h' => ( CrystalSkeleton.reflTransGen_contract_iff E q hq ).mp h';
  · intro hxy;
    convert path_maps_to_contract _ _ ( Relation.ReflTransGen.trans ( path_maps_to_contract _ _ hxy ) _ ) using 1;
    rfl

/-
If reachability upstairs is antisymmetric, then equality of reachable
contracted representatives forces equality of their contracted vertices.  This
is the abstract order-theoretic core of obtaining Bruhat order after
contraction.
-/
theorem contracted_reachability_antisymm (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q)
    (hanti : ∀ {x y : V}, Relation.ReflTransGen E x y →
      Relation.ReflTransGen E y x → x = y)
    {x y : V}
    (hxy : Relation.ReflTransGen (contract E q) (q x) (q y))
    (hyx : Relation.ReflTransGen (contract E q) (q y) (q x)) :
    q x = q y := by
  have := hanti ( CrystalSkeleton.reflTransGen_contract_iff E q hconn |>.1 hxy ) ( CrystalSkeleton.reflTransGen_contract_iff E q hconn |>.1 hyx ) ; aesop;

section Character

variable [Fintype V] [Fintype Q]
  [DecidableEq Q] [DecidableEq S] [AddCommMonoid A]

/-- **Character tiling theorem.** The character assigned to a
Young-quasisymmetric skeleton component is the sum of the characters of its
quasicrystal vertices, and equivalently the direct sum of the original crystal
weights in that component. -/
theorem youngQuasisymmetric_tile_character (q : V → Q) (r : Q → S)
    (w : V → A) (s : S) :
    fiberCharacter (r ∘ q) w s =
      fiberCharacter r (fiberCharacter q w) s := by
  exact fiberCharacter_comp q r w s

/-
Summing the characters of all Young-quasisymmetric tiles recovers the
character of the entire crystal.
-/
theorem sum_youngQuasisymmetric_tile_characters [Fintype S]
    (q : V → Q) (r : Q → S) (w : V → A) :
    ∑ s : S, fiberCharacter r (fiberCharacter q w) s = ∑ x : V, w x := by
  unfold fiberCharacter;
  simp +decide [Finset.sum_comm]

end Character

end CrystalSkeleton