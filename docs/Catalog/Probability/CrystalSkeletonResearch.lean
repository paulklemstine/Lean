import Mathlib

/-!
# Contraction calculus for crystal skeletons

This file formalizes the abstract graph- and character-theoretic mechanisms behind the
successive contractions in *Contractions and applications of crystal skeletons: Young
quasisymmetric and Stanley symmetric functions*.

A map `q : V → Q` identifies crystal vertices into components.  The induced relation
`contract E q` records precisely those directed edges having representatives upstairs.
The results form a dependency chain: one-edge contraction, path descent, path lifting,
exact preservation of reachability, two-stage preservation, and antisymmetry downstairs.
A parallel chain proves that fiber characters are associative and preserve total character.
The paper-specific identification of the final quotient with Bruhat order requires tableau
and crystal structures not reconstructed here; the theorem `two_stage_reachability_iff`
is the reusable core needed for that identification.
-/

namespace CrystalSkeletonResearch

section Relations

variable {V Q S T : Type*}

/-- Directed edge relation induced by identifying vertices through `q`. -/
def contract (E : V → V → Prop) (q : V → Q) : Q → Q → Prop :=
  fun a b => ∃ x y, q x = a ∧ q y = b ∧ E x y

/-- Every edge upstairs induces an edge between its images. -/
theorem edge_maps_to_contract (E : V → V → Prop) (q : V → Q)
    {x y : V} (hxy : E x y) : contract E q (q x) (q y) := by
  exact ⟨x, y, rfl, rfl, hxy⟩

/-- Every directed path upstairs descends to a directed path in the contraction. -/
theorem path_maps_to_contract (E : V → V → Prop) (q : V → Q)
    {x y : V} (hxy : Relation.ReflTransGen E x y) :
    Relation.ReflTransGen (contract E q) (q x) (q y) := by
  induction hxy with
  | refl => exact .refl
  | tail hpath hedge ih =>
      exact ih.tail (edge_maps_to_contract E q hedge)

/-- Contracting twice is exactly contraction by the composite quotient map. -/
theorem contract_comp (E : V → V → Prop) (q : V → Q) (r : Q → S) :
    contract (contract E q) r = contract E (r ∘ q) := by
  funext a b
  apply propext
  constructor
  · rintro ⟨u, v, hu, hv, x, y, hx, hy, hxy⟩
    exact ⟨x, y, by simpa [Function.comp, hx] using hu,
      by simpa [Function.comp, hy] using hv, hxy⟩
  · rintro ⟨x, y, hx, hy, hxy⟩
    exact ⟨q x, q y, hx, hy, x, y, rfl, rfl, hxy⟩

/-- Three contractions are likewise direct contraction by the three maps' composite. -/
theorem contract_comp_three (E : V → V → Prop) (q : V → Q)
    (r : Q → S) (t : S → T) :
    contract (contract (contract E q) r) t = contract E (t ∘ r ∘ q) := by
  rw [contract_comp, contract_comp]
  rfl

/-- A quotient fiber is directed-connected when any ordered pair of its representatives
is joined by a directed path upstairs. -/
def DirectedFiberConnected (E : V → V → Prop) (q : V → Q) : Prop :=
  ∀ ⦃x y : V⦄, q x = q y → Relation.ReflTransGen E x y

/-- Under directed fiber-connectivity, a quotient edge can be lifted starting at any
chosen representative of its source. -/
theorem lift_contract_edge (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q) {x : V} {b : Q}
    (h : contract E q (q x) b) :
    ∃ y : V, q y = b ∧ Relation.ReflTransGen E x y := by
  rcases h with ⟨u, v, hu, hv, huv⟩
  have hxu : Relation.ReflTransGen E x u := hconn hu.symm
  exact ⟨v, hv, hxu.tail huv⟩

/-- A contracted path can be lifted from any representative of its initial vertex. -/
theorem lift_contract_path (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q) {a b : Q}
    (hab : Relation.ReflTransGen (contract E q) a b) {x : V} (hx : q x = a) :
    ∃ y : V, q y = b ∧ Relation.ReflTransGen E x y := by
  induction hab generalizing x with
  | refl => exact ⟨x, hx, .refl⟩
  | tail hpath hedge ih =>
      rcases ih hx with ⟨y, hy, hxy⟩
      rcases hedge with ⟨u, v, hu, hv, huv⟩
      have hyu : Relation.ReflTransGen E y u := hconn (hy.trans hu.symm)
      exact ⟨v, hv, hxy.trans (hyu.tail huv)⟩

/-- **Exact reachability under contraction.** Directed fiber-connectivity is sufficient
for reachability between images to be equivalent to reachability upstairs. -/
theorem contracted_reachability_iff (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q) {x y : V} :
    Relation.ReflTransGen (contract E q) (q x) (q y) ↔
      Relation.ReflTransGen E x y := by
  constructor
  · intro h
    rcases lift_contract_path E q hconn h rfl with ⟨z, hz, hxz⟩
    exact hxz.trans (hconn hz)
  · exact path_maps_to_contract E q

/-- Reachability upstairs depends only on the source and target contraction fibers. -/
theorem reachability_fiber_invariant (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q) {x x' y y' : V}
    (hx : q x = q x') (hy : q y = q y') :
    Relation.ReflTransGen E x y ↔ Relation.ReflTransGen E x' y' := by
  rw [← contracted_reachability_iff E q hconn,
    ← contracted_reachability_iff E q hconn, hx, hy]

/-- **Two-stage contraction theorem.** This models crystal vertices contracted first to
quasicrystals and then to Young-quasisymmetric skeleton components. -/
theorem two_stage_reachability_iff (E : V → V → Prop) (q : V → Q) (r : Q → S)
    (hq : DirectedFiberConnected E q)
    (hr : DirectedFiberConnected (contract E q) r) {x y : V} :
    Relation.ReflTransGen (contract (contract E q) r) (r (q x)) (r (q y)) ↔
      Relation.ReflTransGen E x y := by
  rw [contracted_reachability_iff (contract E q) r hr,
    contracted_reachability_iff E q hq]

/-- If reachability upstairs is antisymmetric, mutual reachability of contracted images
forces equality of those images.  This is the order-theoretic mechanism used when the
final skeleton is identified with Bruhat order. -/
theorem contracted_reachability_antisymm (E : V → V → Prop) (q : V → Q)
    (hconn : DirectedFiberConnected E q)
    (hanti : ∀ {x y : V}, Relation.ReflTransGen E x y →
      Relation.ReflTransGen E y x → x = y)
    {x y : V}
    (hxy : Relation.ReflTransGen (contract E q) (q x) (q y))
    (hyx : Relation.ReflTransGen (contract E q) (q y) (q x)) :
    q x = q y := by
  have hxy' := (contracted_reachability_iff E q hconn).mp hxy
  have hyx' := (contracted_reachability_iff E q hconn).mp hyx
  exact congrArg q (hanti hxy' hyx')

end Relations

section Characters

variable {V Q S T A : Type*}

/-- Character of one contracted component, obtained by summing vertex weights in its fiber. -/
def fiberCharacter [Fintype V] [DecidableEq Q] [AddCommMonoid A]
    (q : V → Q) (w : V → A) (a : Q) : A :=
  ∑ x : V, if q x = a then w x else 0

/-- Summing the characters of every contracted component recovers the total character. -/
theorem sum_fiberCharacter [Fintype V] [Fintype Q] [DecidableEq Q]
    [AddCommMonoid A] (q : V → Q) (w : V → A) :
    ∑ a : Q, fiberCharacter q w a = ∑ x : V, w x := by
  unfold fiberCharacter
  rw [Finset.sum_comm]
  simp

/-- Fiber character formation is associative along two nested contractions. -/
theorem fiberCharacter_comp [Fintype V] [Fintype Q] [DecidableEq Q]
    [DecidableEq S] [AddCommMonoid A]
    (q : V → Q) (r : Q → S) (w : V → A) (b : S) :
    fiberCharacter (r ∘ q) w b =
      fiberCharacter r (fiberCharacter q w) b := by
  unfold fiberCharacter
  simp +decide [Finset.sum_ite, Function.comp]
  simp +decide only [Finset.sum_sigma']
  refine Finset.sum_bij (fun x _ => ⟨q x, x⟩) ?_ ?_ ?_ ?_ <;> aesop

/-- The character identity for the paper's two-stage tiling: a tile's character is the
sum of its quasicrystal characters, equivalently the sum of original vertex weights. -/
theorem youngQuasisymmetric_tile_character [Fintype V] [Fintype Q]
    [DecidableEq Q] [DecidableEq S] [AddCommMonoid A]
    (q : V → Q) (r : Q → S) (w : V → A) (s : S) :
    fiberCharacter (r ∘ q) w s =
      fiberCharacter r (fiberCharacter q w) s := by
  exact fiberCharacter_comp q r w s

/-- Summing all Young-quasisymmetric tile characters recovers the whole crystal character. -/
theorem sum_youngQuasisymmetric_tile_characters [Fintype V] [Fintype Q] [Fintype S]
    [DecidableEq Q] [DecidableEq S] [AddCommMonoid A]
    (q : V → Q) (r : Q → S) (w : V → A) :
    ∑ s : S, fiberCharacter r (fiberCharacter q w) s = ∑ x : V, w x := by
  rw [sum_fiberCharacter]
  exact sum_fiberCharacter q w

/-- The explicit three-level associativity formula for character contraction. -/
theorem fiberCharacter_comp_three [Fintype V] [Fintype Q] [Fintype S]
    [DecidableEq Q] [DecidableEq S] [DecidableEq T] [AddCommMonoid A]
    (q : V → Q) (r : Q → S) (t : S → T) (w : V → A) (c : T) :
    fiberCharacter (t ∘ r ∘ q) w c =
      fiberCharacter t (fiberCharacter r (fiberCharacter q w)) c := by
  rw [fiberCharacter_comp (r ∘ q) t]
  congr 1
  funext s
  exact fiberCharacter_comp q r w s

end Characters

end CrystalSkeletonResearch