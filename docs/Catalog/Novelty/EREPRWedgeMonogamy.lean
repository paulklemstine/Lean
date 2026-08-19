import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREPRBridge
import Novelty.EREPRThroatCapacity
import Novelty.EREPRUltrametricSpacetime

/-!
# Entanglement wedges, the lattice of minimal surfaces, and monogamy of bridges

Three further structural theorems for the min-cut model of
`Novelty.EmergentGeometryEntropyCone`.

* **Araki–Lieb** (`entropy_araki_lieb`, `entropy_araki_lieb_abs`): the triangle
  inequality for entropies, `|S(A) − S(B)| ≤ S(A ∪ B)`, obtained by combining
  purity with subadditivity.  (The entropy cone file proved subadditivity, strong
  subadditivity, monogamy and purity, but not this.)
* **The lattice of minimal surfaces and entanglement wedge nesting**
  (`minimal_surface_inter_union`, `wedge_nesting`): minimal surfaces for a fixed
  boundary region are closed under intersection and union, and for nested
  boundary regions `A ⊆ B` one can choose *nested* minimal surfaces.  This is the
  toy-model form of entanglement wedge nesting, the consistency condition behind
  subregion duality.
* **Monogamy of Einstein–Rosen bridges** (`cap_isosceles`,
  `monogamy_of_maximal_entanglement`): the three bridge capacities of any three
  cells form an isosceles triple whose two smallest members are equal (the
  ultrametric "tree" property, in capacity form), and a boundary cell that is
  *maximally* entangled with a partner has **no other bridge at all**: a wormhole
  has exactly two mouths.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  ER=EPR should inherit the monogamy of entanglement:
a maximally entangled pair cannot be entangled with anything else, hence the
bridge joining it must be geometrically isolated.  Bold form: *maximal
entanglement kills every other edge at that cell.*

EXPERIMENT (Experimenter).  In a model with no hidden bulk cells,
`S({u}) = Σ_{y ≠ u} w(u,y)` (`cutWeight_single`) while `I(u:v) = 2 w(u,v)`.
Saturation `I(u:v) = 2 S({u})` therefore forces `Σ_{y ≠ u, v} w(u,y) = 0`, and
nonnegativity of the weights makes every remaining edge vanish.  The
`Finset.sum_eq_zero_iff_of_nonneg` step is where the physics (positivity of
areas) enters.

ANALYSIS (Analyst).  Both monogamy statements have the same source: positivity
plus a *minimality/saturation* condition.  For capacities the corresponding
statement is `cap_isosceles`, a consequence of the Gomory–Hu inequality proved in
`Novelty.EREPRUltrametricSpacetime`; it says the wormhole network is a tree.

CRITIQUE (Critic).  `monogamy_of_maximal_entanglement` needs `NoBulk`: with
hidden bulk cells `S({u})` is a min-cut and can be smaller than the sum of the
incident weights, so saturation no longer forces the edges to vanish; the
hypothesis is therefore not cosmetic.  Nesting, by contrast, holds for arbitrary
models.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Araki–Lieb -/

/-- **Araki–Lieb inequality**: `S(A) ≤ S(A ∪ B) + S(B)` for disjoint boundary
regions.  Proved from purity plus subadditivity. -/
theorem entropy_araki_lieb (M : HoloModel V) (A B : Region V)
    (hAB : Disj A B) :
    entropy M A ≤ entropy M (fun v => A v || B v) + entropy M B := by
  set C : Region V := fun v => M.bdry v && !(A v || B v) with hC
  have hsplit : entropy M (fun v => M.bdry v && !(A v))
      = entropy M (fun v => C v || B v) := by
    refine entropy_congr_bdry M _ _ fun v hv => ?_
    show (M.bdry v && !(A v)) = (C v || B v)
    by_cases hA : A v = true
    · rw [hA, hv, hAB v hA]; simp [hC, hv, hA]
    · have hA' : A v = false := by
        cases h' : A v
        · rfl
        · exact absurd h' hA
      simp [hC, hv, hA']
  have h1 : entropy M A = entropy M (fun v => C v || B v) := by
    rw [← hsplit, entropy_complement]
  have h2 : entropy M C = entropy M (fun v => A v || B v) := entropy_complement M _
  have h3 := entropy_subadditive M C B
  rw [h1, ← h2]
  exact h3

/-- The two-sided Araki–Lieb ("triangle") inequality for holographic
entropies. -/
theorem entropy_araki_lieb_abs (M : HoloModel V) (A B : Region V)
    (hAB : Disj A B) :
    |entropy M A - entropy M B| ≤ entropy M (fun v => A v || B v) := by
  have h1 := entropy_araki_lieb M A B hAB
  have h2 := entropy_araki_lieb M B A hAB.symm
  have hcomm : (fun v => B v || A v) = fun v => A v || B v := by
    funext v; exact Bool.or_comm _ _
  rw [hcomm] at h2
  rw [abs_sub_le_iff]
  exact ⟨by linarith, by linarith⟩

/-! ## The lattice of minimal surfaces -/

/-- **Minimal surfaces form a lattice.**  If two bulk surfaces are both minimal
for the same boundary region, so are their intersection and their union. -/
theorem minimal_surface_inter_union (M : HoloModel V) (A : Region V) {f g : Region V}
    (hf : Admissible M A f) (hg : Admissible M A g)
    (hfv : cutWeight M.toBulkGraph f = entropy M A)
    (hgv : cutWeight M.toBulkGraph g = entropy M A) :
    cutWeight M.toBulkGraph (fun v => f v && g v) = entropy M A ∧
      cutWeight M.toBulkGraph (fun v => f v || g v) = entropy M A := by
  have hi : Admissible M A (fun v => f v && g v) := by
    intro v hv
    show (f v && g v) = A v
    rw [hf v hv, hg v hv]
    cases A v <;> rfl
  have hu : Admissible M A (fun v => f v || g v) := by
    intro v hv
    show (f v || g v) = A v
    rw [hf v hv, hg v hv]
    cases A v <;> rfl
  have e1 := entropy_le_of_admissible hi
  have e2 := entropy_le_of_admissible hu
  have hsub := cutWeight_submodular M.toBulkGraph f g
  constructor <;> linarith

/-- **Entanglement wedge nesting.**  If the boundary region `A` is contained in
`B`, then minimal surfaces can be chosen nested: the entanglement wedge of `A`
sits inside the entanglement wedge of `B`. -/
theorem wedge_nesting (M : HoloModel V) (A B : Region V)
    (hsub : ∀ v, M.bdry v = true → A v = true → B v = true) :
    ∃ f g : Region V, Admissible M A f ∧ Admissible M B g ∧
      (∀ v, f v = true → g v = true) ∧
      cutWeight M.toBulkGraph f = entropy M A ∧
      cutWeight M.toBulkGraph g = entropy M B := by
  obtain ⟨f₀, hf₀, hf₀v⟩ := exists_minimal_surface M A
  obtain ⟨g₀, hg₀, hg₀v⟩ := exists_minimal_surface M B
  have hi : Admissible M A (fun v => f₀ v && g₀ v) := by
    intro v hv
    show (f₀ v && g₀ v) = A v
    rw [hf₀ v hv, hg₀ v hv]
    by_cases hA : A v = true
    · rw [hA, hsub v hv hA]; rfl
    · have hA' : A v = false := by
        cases h' : A v
        · rfl
        · exact absurd h' hA
      rw [hA']; rfl
  have hu : Admissible M B (fun v => f₀ v || g₀ v) := by
    intro v hv
    show (f₀ v || g₀ v) = B v
    rw [hf₀ v hv, hg₀ v hv]
    by_cases hA : A v = true
    · rw [hA, hsub v hv hA]; rfl
    · have hA' : A v = false := by
        cases h' : A v
        · rfl
        · exact absurd h' hA
      rw [hA']; rfl
  have e1 := entropy_le_of_admissible hi
  have e2 := entropy_le_of_admissible hu
  have hsubm := cutWeight_submodular M.toBulkGraph f₀ g₀
  refine ⟨fun v => f₀ v && g₀ v, fun v => f₀ v || g₀ v, hi, hu, ?_, ?_, ?_⟩
  · intro v hv
    have hf : f₀ v = true := (Bool.and_eq_true (f₀ v) (g₀ v) ▸ hv).1
    simp [hf]
  · linarith
  · linarith

/-! ## Monogamy of Einstein–Rosen bridges -/

/-- **The wormhole network is a tree.**  If one of the three capacities of a
triple of cells is strictly the smallest, the other two are equal: an isosceles
condition characteristic of ultrametric (tree) geometry. -/
theorem cap_isosceles (G : BulkGraph V) {u v w : V} (huw : u ≠ w) (hvw : v ≠ w)
    (h : cap G u w < cap G u v) :
    cap G u w = cap G v w := by
  have h1 : min (cap G u v) (cap G v w) ≤ cap G u w := cap_min_le G v huw
  have h2 : min (cap G v u) (cap G u w) ≤ cap G v w := cap_min_le G u hvw
  rw [cap_comm G v u] at h2
  have hb : cap G v w ≤ cap G u w := by
    rcases min_cases (cap G u v) (cap G v w) with ⟨he, _⟩ | ⟨he, _⟩
    · rw [he] at h1; linarith
    · rw [he] at h1; linarith
  have hc : cap G u w ≤ cap G v w := by
    rcases min_cases (cap G u v) (cap G u w) with ⟨he, hle⟩ | ⟨he, _⟩
    · rw [he] at h2; linarith
    · rw [he] at h2; linarith
  linarith

private lemma sum_ite_zero_erase {W : Type*} [Fintype W] [DecidableEq W] (w : W → ℝ) (x : W) :
    ∑ y, (if y = x then (0:ℝ) else w y) = ∑ y ∈ univ.erase x, w y := by
  rw [Finset.sum_erase_eq_sub (mem_univ x), eq_sub_iff_add_eq]
  have h : ∀ y : W, (if y = x then (0:ℝ) else w y) = w y - (if y = x then w x else 0) := by
    intro y; by_cases h : y = x <;> simp [h]
  rw [Finset.sum_congr rfl (fun y _ => h y), Finset.sum_sub_distrib]
  simp

/-- The area of the surface around a single cell is the total weight of the
edges incident to it. -/
theorem cutWeight_single (G : BulkGraph V) (u : V) :
    cutWeight G (single u) = ∑ y ∈ univ.erase u, G.weight u y := by
  have key : ∀ x : V, ∑ y, (sepBit (single u x) (single u y) : ℝ) * G.weight x y
      = if x = u then ∑ y ∈ univ.erase u, G.weight u y else G.weight x u := by
    intro x
    by_cases h : x = u
    · subst h
      rw [if_pos rfl]
      have hy : ∀ y : V, (sepBit (single x x) (single x y) : ℝ) * G.weight x y
          = if y = x then 0 else G.weight x y := by
        intro y
        by_cases hy : y = x <;> simp [single, sepBit, hy]
      rw [Finset.sum_congr rfl (fun y _ => hy y)]
      exact sum_ite_zero_erase (G.weight x) x
    · rw [if_neg h]
      have hy : ∀ y : V, (sepBit (single u x) (single u y) : ℝ) * G.weight x y
          = if y = u then G.weight x u else 0 := by
        intro y
        by_cases hy : y = u <;> simp [single, sepBit, hy, h]
      rw [Finset.sum_congr rfl (fun y _ => hy y)]
      simp
  rw [cutWeight, Finset.sum_congr rfl (fun x _ => key x), ← Finset.add_sum_erase _ _ (mem_univ u)]
  have hrest : ∑ x ∈ univ.erase u,
      (if x = u then ∑ y ∈ univ.erase u, G.weight u y else G.weight x u)
      = ∑ x ∈ univ.erase u, G.weight u x := by
    refine Finset.sum_congr rfl fun x hx => ?_
    rw [if_neg (Finset.ne_of_mem_erase hx), G.weight_symm]
  rw [hrest, if_pos rfl]
  ring

/-- **Monogamy of Einstein–Rosen bridges.**  In a geometry with no hidden bulk
cells, if a boundary cell `u` saturates its entropy bound with a partner `v`
(`I(u:v) = 2 S({u})`, maximal entanglement), then `u` has no other bridge: every
other edge at `u` has zero area and `u` is unentangled with every other cell.  A
wormhole has exactly two mouths. -/
theorem monogamy_of_maximal_entanglement {M : HoloModel V} (hM : NoBulk M) {u v : V}
    (huv : u ≠ v)
    (hmax : mutualInfo M (single u) (single v) = 2 * entropy M (single u)) {z : V}
    (hzu : z ≠ u) (hzv : z ≠ v) :
    M.weight u z = 0 ∧ mutualInfo M (single u) (single z) = 0 := by
  have hS : entropy M (single u) = ∑ y ∈ univ.erase u, M.weight u y := by
    rw [entropy_of_noBulk hM, cutWeight_single]
  have hIuv : mutualInfo M (single u) (single v) = 2 * M.weight u v := by
    have := weight_eq_half_mutualInfo hM huv
    linarith
  have hvmem : v ∈ univ.erase u := mem_erase.2 ⟨Ne.symm huv, mem_univ v⟩
  have hsplit : ∑ y ∈ univ.erase u, M.weight u y
      = M.weight u v + ∑ y ∈ (univ.erase u).erase v, M.weight u y :=
    (Finset.add_sum_erase _ _ hvmem).symm
  have hzero : ∑ y ∈ (univ.erase u).erase v, M.weight u y = 0 := by
    rw [hS, hsplit] at hmax
    rw [hIuv] at hmax
    linarith
  have hnn : ∀ y ∈ (univ.erase u).erase v, 0 ≤ M.weight u y :=
    fun y _ => M.weight_nonneg u y
  have hzmem : z ∈ (univ.erase u).erase v :=
    mem_erase.2 ⟨hzv, mem_erase.2 ⟨hzu, mem_univ z⟩⟩
  have hwz : M.weight u z = 0 :=
    (Finset.sum_eq_zero_iff_of_nonneg hnn).1 hzero z hzmem
  refine ⟨hwz, ?_⟩
  have := weight_eq_half_mutualInfo hM (Ne.symm hzu : u ≠ z)
  rw [hwz] at this
  linarith

/-- The geometric face of monogamy: a maximally entangled cell has exactly one
neighbour in the emergent geometry. -/
theorem unique_bridge_of_maximal_entanglement {M : HoloModel V} (hM : NoBulk M) {u v : V}
    (huv : u ≠ v)
    (hmax : mutualInfo M (single u) (single v) = 2 * entropy M (single u)) {z : V}
    (hzu : z ≠ u) (hadj : BulkAdj M.toBulkGraph u z) :
    z = v := by
  by_contra hzv
  have := (monogamy_of_maximal_entanglement hM huv hmax hzu hzv).1
  have hpos : 0 < M.weight u z := hadj
  rw [this] at hpos
  exact lt_irrefl 0 hpos

end EmergentGeometry