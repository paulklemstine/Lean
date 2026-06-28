import Mathlib

/-!
# Finite Wasserstein distance and its metric axioms

This file defines the (finite) optimal-transport value
`wValue d a b = ⨅ { transportCost d π | π a plan between a and b }`
of a *ground cost* `d` between two mass distributions `a, b` on `Fin n`, and proves
the metric-style axioms of the associated Wasserstein distance:

* `wValue_nonneg` — nonnegativity (for a nonnegative ground cost);
* `wValue_self` — `wValue d a a = 0` when the ground cost vanishes on the diagonal;
* `wValue_symm` — symmetry, when the ground cost is symmetric.

It re-states the Kantorovich primitives (`IsTransportPlan`, `transportCost`,
`feasibleSet`) of `Novelty.OptimalTransport.Kantorovich` so that the file is
self-contained; the development is the square (`n = m`) case of that file.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the optimal-transport value of a metric ground cost
should itself be a (pseudo)metric on distributions — the Wasserstein distance.
Experiment (Experimenter): define `wValue` as an `sInf` of the cost image and prove
nonnegativity, self-distance zero (via the diagonal coupling), and symmetry (via the
transpose coupling).  Analysis (Analyst): nonnegativity and symmetry are "soft" and
need only order/bijection arguments; the diagonal coupling makes `wValue d a a = 0`
because its cost is `∑ a i * d i i = 0`.  The triangle inequality is the genuinely
hard axiom (gluing lemma with division by the middle marginal) and is recorded as a
future direction.  Critique (Critic): we require `d ≥ 0` for nonnegativity and the
sInf to be well-behaved; without it the value can be negative and the "distance"
interpretation fails, so the hypothesis is correctly guarded.
-- !-- end Lab Notes -- !--
-/

namespace Novelty.OptimalTransport

open scoped BigOperators
open Set

variable {n : ℕ}

/-- `π` is a transport plan (coupling) between distributions `a` and `b` on `Fin n`:
entrywise nonnegative, with row marginals `a` and column marginals `b`. -/
def IsTransportPlan (a b : Fin n → ℝ) (π : Fin n → Fin n → ℝ) : Prop :=
  (∀ i j, 0 ≤ π i j) ∧ (∀ i, ∑ j, π i j = a i) ∧ (∀ j, ∑ i, π i j = b j)

/-- Total transport cost of plan `π` against ground cost `d`. -/
def transportCost (d : Fin n → Fin n → ℝ) (π : Fin n → Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, π i j * d i j

/-- Feasible set of couplings between `a` and `b`. -/
def feasibleSet (a b : Fin n → ℝ) : Set (Fin n → Fin n → ℝ) :=
  {π | IsTransportPlan a b π}

/-- The diagonal coupling of a distribution with itself: mass `a i` stays at `i`. -/
def diagPlan (a : Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => if i = j then a i else 0

/-
The diagonal coupling is a transport plan from `a` to `a` (for `a ≥ 0`).
-/
theorem diagPlan_isTransportPlan (a : Fin n → ℝ) (ha : ∀ i, 0 ≤ a i) :
    IsTransportPlan a a (diagPlan a) := by
  refine' ⟨ fun i j => _, fun i => _, fun j => _ ⟩ <;> simp +decide [ diagPlan ];
  split_ifs <;> linarith [ ha i ]

/-
A transport plan of a nonnegative ground cost has nonnegative total cost.
-/
theorem transportCost_nonneg {a b : Fin n → ℝ} (d : Fin n → Fin n → ℝ)
    (hd : ∀ i j, 0 ≤ d i j) {π : Fin n → Fin n → ℝ} (hπ : IsTransportPlan a b π) :
    0 ≤ transportCost d π := by
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg ( hπ.1 i j ) ( hd i j )

/-
The cost of the diagonal coupling under a diagonal-vanishing ground cost is `0`.
-/
theorem transportCost_diagPlan (a : Fin n → ℝ) (d : Fin n → Fin n → ℝ)
    (hd0 : ∀ i, d i i = 0) :
    transportCost d (diagPlan a) = 0 := by
  simp [transportCost, diagPlan, hd0]

/-- The **finite optimal-transport (Wasserstein) value** of ground cost `d` between
distributions `a` and `b`: the infimum of the transport cost over feasible plans. -/
noncomputable def wValue (d : Fin n → Fin n → ℝ) (a b : Fin n → ℝ) : ℝ :=
  sInf (transportCost d '' feasibleSet a b)

/-
The cost image is bounded below by `0` for a nonnegative ground cost.
-/
theorem bddBelow_cost_image (d : Fin n → Fin n → ℝ) (a b : Fin n → ℝ)
    (hd : ∀ i j, 0 ≤ d i j) :
    BddBelow (transportCost d '' feasibleSet a b) := by
  exact ⟨ 0, Set.forall_mem_image.2 fun π hπ => transportCost_nonneg d hd hπ ⟩

/-
**Nonnegativity of the Wasserstein value.**
-/
theorem wValue_nonneg (d : Fin n → Fin n → ℝ) (a b : Fin n → ℝ)
    (hd : ∀ i j, 0 ≤ d i j) (hne : (feasibleSet a b).Nonempty) :
    0 ≤ wValue d a b := by
  apply le_csInf;
  · exact hne.image _;
  · rintro _ ⟨ π, hπ, rfl ⟩ ; exact transportCost_nonneg d hd hπ;

/-
**Self-distance is zero.** If the ground cost vanishes on the diagonal and is
nonnegative, the Wasserstein value of a distribution to itself is `0`.
-/
theorem wValue_self (d : Fin n → Fin n → ℝ) (a : Fin n → ℝ)
    (hd : ∀ i j, 0 ≤ d i j) (hd0 : ∀ i, d i i = 0) (ha : ∀ i, 0 ≤ a i) :
    wValue d a a = 0 := by
  refine' le_antisymm _ _;
  · refine' csInf_le _ _;
    · exact bddBelow_cost_image d a a hd;
    · exact ⟨ diagPlan a, diagPlan_isTransportPlan a ha, transportCost_diagPlan a d hd0 ⟩;
  · apply wValue_nonneg;
    · assumption;
    · exact ⟨ _, diagPlan_isTransportPlan a ha ⟩

/-
**Symmetry of the Wasserstein value** for a symmetric ground cost.
-/
theorem wValue_symm (d : Fin n → Fin n → ℝ) (a b : Fin n → ℝ)
    (hd_symm : ∀ i j, d i j = d j i) :
    wValue d a b = wValue d b a := by
  refine' congr_arg _ ( Set.ext _ );
  intro x;
  constructor <;> rintro ⟨ π, hπ, rfl ⟩;
  · refine' ⟨ fun i j => π j i, _, _ ⟩ <;> simp_all +decide [ IsTransportPlan, feasibleSet ];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hd_symm ] );
  · refine' ⟨ fun i j => π j i, _, _ ⟩ <;> simp_all +decide [ IsTransportPlan, feasibleSet ];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by aesop )

end Novelty.OptimalTransport