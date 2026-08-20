import Physics.PlanckFoamTopology

/-!
# Stochastic Planck foam on the line

This file instantiates the abstract Wheeler foam of `Physics.PlanckFoamTopology`
at the Planck scale and adds the *stochastic* layer: each Planck cell
independently bifurcates with probability `p`.

The base is the real line `ℝ`.  A configuration of the foam is a finite set
`A : Finset (Fin N)` of *excited cells*; the branch locus is the corresponding
set of lattice sites `siteSet ℓ A = {ℓ * i | i ∈ A}` at Planck spacing `ℓ`, and
the foam has two sheets (`Bool`), i.e. each excited site is doubled.

## Main results

* `PlanckFoam.Stochastic.not_isOpen_of_finite_nonempty` — a nonempty finite set
  of reals is never open; hence a discrete branch locus is never open.
* `PlanckFoam.Stochastic.lineFoam_t2Space_iff` — the Planck foam over the line is
  Hausdorff **iff** no cell is excited.  Any amount of foam destroys
  Hausdorffness.
* `PlanckFoam.Stochastic.lineFoam_t1Space`, `lineFoam_connectedSpace`,
  `lineFoam_sheet_isOpenEmbedding`, `lineFoam_not_metrizableSpace` — the foam is
  nevertheless T1, connected, and locally homeomorphic to `ℝ`, while carrying no
  metric at all.
* `PlanckFoam.Stochastic.lineFoam_observable_blind` — no continuous
  `ℝ`-valued observable can distinguish the two branches over a Planck site.
* `PlanckFoam.Stochastic.sum_weightOn`, `sum_weightOn_mul_card` — the Bernoulli
  cell measure is a probability measure and its mean excitation number is
  `|s| * p` (proved by induction over the cell set).
* `PlanckFoam.Stochastic.hausdorffWeight_eq` — the total probability of the
  Hausdorff configurations is exactly `(1 - p) ^ N`, and
  `hausdorffWeight_le_exp` bounds it by `exp (-p N)`: Hausdorffness is
  exponentially improbable in the number of Planck cells.
* `PlanckFoam.Stochastic.tendsto_expected_count_atTop` — at fixed macroscopic
  length `L` the expected number of branch points diverges as the Planck spacing
  `ℓ → 0⁺`.
-/

open Set Finset Topology Filter

namespace PlanckFoam
namespace Stochastic

/-! ### Discrete branch loci are never open -/

/-- A nonempty finite set of reals is not open: a discrete (Planck lattice)
branch locus can never be "thick". -/
theorem not_isOpen_of_finite_nonempty {T : Set ℝ} (hfin : T.Finite) (hne : T.Nonempty) :
    ¬ IsOpen T := by
  intro hopen
  obtain ⟨x, hx⟩ := hne
  obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.1 hopen x hx
  have hsub : Set.Ioo x (x + ε) ⊆ T := by
    intro y hy
    refine hball ?_
    rw [Metric.mem_ball, Real.dist_eq, abs_lt]
    constructor <;> [linarith [hy.1]; linarith [hy.2]]
  exact (Set.Ioo_infinite (by linarith : x < x + ε)) (hfin.subset hsub)

/-- A finite set of reals has empty interior. -/
theorem interior_eq_empty_of_finite {T : Set ℝ} (hfin : T.Finite) : interior T = ∅ := by
  by_contra h
  exact not_isOpen_of_finite_nonempty (hfin.subset interior_subset)
    (Set.nonempty_iff_ne_empty.2 h) isOpen_interior

/-! ### The Planck lattice branch locus -/

variable {N : ℕ}

/-- The branch locus determined by a set `A` of excited Planck cells at
spacing `ℓ`. -/
def siteSet (ℓ : ℝ) (A : Finset (Fin N)) : Set ℝ := (fun i : Fin N => ℓ * (i : ℕ)) '' (A : Set (Fin N))

theorem siteSet_finite (ℓ : ℝ) (A : Finset (Fin N)) : (siteSet ℓ A).Finite :=
  (A.finite_toSet).image _

@[simp] theorem siteSet_eq_empty_iff (ℓ : ℝ) (A : Finset (Fin N)) :
    siteSet ℓ A = ∅ ↔ A = ∅ := by
  rw [siteSet, Set.image_eq_empty, Finset.coe_eq_empty]

theorem isOpen_siteSet_iff (ℓ : ℝ) (A : Finset (Fin N)) :
    IsOpen (siteSet ℓ A) ↔ A = ∅ := by
  constructor
  · intro h
    by_contra hA
    exact not_isOpen_of_finite_nonempty (siteSet_finite ℓ A)
      (Set.nonempty_iff_ne_empty.2 (by simpa [siteSet_eq_empty_iff] using hA)) h
  · rintro rfl
    simp [siteSet]

theorem isClosed_siteSet (ℓ : ℝ) (A : Finset (Fin N)) : IsClosed (siteSet ℓ A) :=
  (siteSet_finite ℓ A).isClosed

@[simp] theorem interior_siteSet (ℓ : ℝ) (A : Finset (Fin N)) : interior (siteSet ℓ A) = ∅ :=
  interior_eq_empty_of_finite (siteSet_finite ℓ A)

/-- The two-sheeted Planck foam over the real line. -/
abbrev LineFoam (ℓ : ℝ) (A : Finset (Fin N)) : Type := Foam ℝ (siteSet ℓ A) Bool

/-! ### Geometry of the line foam -/

/-- **Wheeler's line.** The Planck foam over `ℝ` is Hausdorff exactly when no
Planck cell is excited: any foam at all breaks the Hausdorff axiom. -/
theorem lineFoam_t2Space_iff (ℓ : ℝ) (A : Finset (Fin N)) :
    T2Space (LineFoam ℓ A) ↔ A = ∅ := by
  rw [t2Space_foam_iff, isOpen_siteSet_iff, and_iff_right (inferInstanceAs (T2Space ℝ))]

/-- The foam is always T1: points are closed even though they cannot be
separated. -/
theorem lineFoam_t1Space (ℓ : ℝ) (A : Finset (Fin N)) : T1Space (LineFoam ℓ A) :=
  t1Space_foam_iff.2 inferInstance

/-- Every sheet is an open embedding: a local observer sees an ordinary line. -/
theorem lineFoam_sheet_isOpenEmbedding (ℓ : ℝ) (A : Finset (Fin N)) (b : Bool) :
    IsOpenEmbedding (sheet (siteSet ℓ A) b : ℝ → LineFoam ℓ A) :=
  sheet_isOpenEmbedding (isClosed_siteSet ℓ A) b

/-- The foam is connected. -/
theorem lineFoam_connectedSpace (ℓ : ℝ) (A : Finset (Fin N)) :
    ConnectedSpace (LineFoam ℓ A) := by
  exact connectedSpace_foam ((siteSet_finite ℓ A).infinite_compl).nonempty

/-- With at least one excited cell there is **no Planck-scale distance
function**: the foam is not metrizable. -/
theorem lineFoam_not_metrizableSpace (ℓ : ℝ) {A : Finset (Fin N)} (hA : A ≠ ∅) :
    ¬ TopologicalSpace.MetrizableSpace (LineFoam ℓ A) :=
  not_metrizableSpace (by rw [isOpen_siteSet_iff]; exact hA)

/-- **Observational invisibility of the foam.** Any continuous real observable
takes the same value on both branches over every point of the line. -/
theorem lineFoam_observable_blind (ℓ : ℝ) (A : Finset (Fin N))
    {f : LineFoam ℓ A → ℝ} (hf : Continuous f) (x : ℝ) (b c : Bool) :
    f (sheet (siteSet ℓ A) b x) = f (sheet (siteSet ℓ A) c x) :=
  eq_of_continuous_t2 hf (by simp)

/-- Over an excited Planck site the fibre of the macroscopic projection has
exactly two points. -/
theorem lineFoam_card_fiber (ℓ : ℝ) (A : Finset (Fin N)) {x : ℝ} (hx : x ∈ siteSet ℓ A) :
    Nat.card (proj (siteSet ℓ A) Bool ⁻¹' {x}) = 2 := by
  rw [card_fiber_of_mem hx]
  simp

/-! ### The Bernoulli cell measure -/

variable {α : Type*} [DecidableEq α]

/-- Weight of the configuration `A` inside the cell set `s`: each cell of `s` is
excited with probability `p`, independently. -/
def weightOn (p : ℝ) (s A : Finset α) : ℝ := ∏ i ∈ s, (if i ∈ A then p else 1 - p)

theorem weightOn_empty (p : ℝ) (A : Finset α) : weightOn p ∅ A = 1 := by
  simp [weightOn]

theorem weightOn_insert_notMem {p : ℝ} {a : α} {s A : Finset α} (has : a ∉ s) (hA : A ⊆ s) :
    weightOn p (insert a s) A = (1 - p) * weightOn p s A := by
  have haA : a ∉ A := fun h => has (hA h)
  rw [weightOn, weightOn, Finset.prod_insert has, if_neg haA]

theorem weightOn_insert_mem {p : ℝ} {a : α} {s A : Finset α} (has : a ∉ s) :
    weightOn p (insert a s) (insert a A) = p * weightOn p s A := by
  rw [weightOn, weightOn, Finset.prod_insert has, if_pos (Finset.mem_insert_self a A)]
  congr 1
  refine Finset.prod_congr rfl fun i hi => ?_
  have hia : i ≠ a := fun h => has (h ▸ hi)
  simp [Finset.mem_insert, hia]

/-- The Bernoulli cell measure is a probability measure: the weights of all
configurations sum to one. -/
theorem sum_weightOn (p : ℝ) (s : Finset α) :
    ∑ A ∈ s.powerset, weightOn p s A = 1 := by
  induction s using Finset.induction_on with
  | empty => simp [weightOn]
  | insert a s has ih =>
      rw [Finset.sum_powerset_insert has]
      have h₁ : ∑ A ∈ s.powerset, weightOn p (insert a s) A
          = (1 - p) * ∑ A ∈ s.powerset, weightOn p s A := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun A hA => ?_
        exact weightOn_insert_notMem has (Finset.mem_powerset.1 hA)
      have h₂ : ∑ A ∈ s.powerset, weightOn p (insert a s) (insert a A)
          = p * ∑ A ∈ s.powerset, weightOn p s A := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun A hA => ?_
        exact weightOn_insert_mem has
      rw [h₁, h₂, ih]
      ring

/-- **Expected number of branch points.** The mean number of excited Planck
cells is `|s| * p`. -/
theorem sum_weightOn_mul_card (p : ℝ) (s : Finset α) :
    ∑ A ∈ s.powerset, weightOn p s A * A.card = s.card * p := by
  induction s using Finset.induction_on with
  | empty => simp [weightOn]
  | insert a s has ih =>
      rw [Finset.sum_powerset_insert has]
      have h₁ : ∑ A ∈ s.powerset, weightOn p (insert a s) A * A.card
          = (1 - p) * ∑ A ∈ s.powerset, weightOn p s A * A.card := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun A hA => ?_
        rw [weightOn_insert_notMem has (Finset.mem_powerset.1 hA)]
        ring
      have h₂ : ∑ A ∈ s.powerset, weightOn p (insert a s) (insert a A) * (insert a A).card
          = p * ((∑ A ∈ s.powerset, weightOn p s A * A.card) + ∑ A ∈ s.powerset, weightOn p s A) := by
        rw [mul_add, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
        refine Finset.sum_congr rfl fun A hA => ?_
        have hAs : A ⊆ s := Finset.mem_powerset.1 hA
        have haA : a ∉ A := fun h => has (hAs h)
        rw [weightOn_insert_mem has, Finset.card_insert_of_notMem haA]
        push_cast
        ring
      rw [h₁, h₂, ih, sum_weightOn p s, Finset.card_insert_of_notMem has]
      push_cast
      ring

/-! ### Probability of Hausdorffness -/

/-- Weight of a configuration of `N` Planck cells. -/
def cellWeight (p : ℝ) (A : Finset (Fin N)) : ℝ := weightOn p Finset.univ A

theorem cellWeight_empty (p : ℝ) : cellWeight (N := N) p ∅ = (1 - p) ^ N := by
  simp [cellWeight, weightOn]

theorem sum_cellWeight (p : ℝ) : ∑ A ∈ (Finset.univ : Finset (Fin N)).powerset, cellWeight p A = 1 :=
  sum_weightOn p _

/-- The expected number of excited Planck cells among `N` cells is `N * p`. -/
theorem expected_branch_count (p : ℝ) :
    ∑ A ∈ (Finset.univ : Finset (Fin N)).powerset, cellWeight p A * A.card = N * p := by
  simp only [cellWeight]
  simpa using sum_weightOn_mul_card (α := Fin N) p Finset.univ

open Classical in
/-- Total probability of those Planck-cell configurations whose foam is
Hausdorff. -/
noncomputable def hausdorffWeight (p ℓ : ℝ) (N : ℕ) : ℝ :=
  ∑ A ∈ (Finset.univ : Finset (Fin N)).powerset.filter
    (fun A => T2Space (LineFoam ℓ A)), cellWeight p A

/-- **Hausdorffness is exponentially improbable.** The probability that a
stochastic Planck foam with `N` cells is Hausdorff equals `(1 - p) ^ N`. -/
theorem hausdorffWeight_eq (p ℓ : ℝ) (N : ℕ) : hausdorffWeight p ℓ N = (1 - p) ^ N := by
  classical
  have hfilter : (Finset.univ : Finset (Fin N)).powerset.filter
      (fun A => T2Space (LineFoam ℓ A)) = {∅} := by
    ext A
    simp only [Finset.mem_filter, Finset.mem_powerset, Finset.mem_singleton,
      Finset.subset_univ, true_and]
    exact lineFoam_t2Space_iff ℓ A
  rw [hausdorffWeight, hfilter, Finset.sum_singleton, cellWeight_empty]

theorem hausdorffWeight_le_exp {p : ℝ} (hp1 : p ≤ 1) (ℓ : ℝ) (N : ℕ) :
    hausdorffWeight p ℓ N ≤ Real.exp (-(p * N)) := by
  rw [hausdorffWeight_eq]
  have h1 : (1 : ℝ) - p ≤ Real.exp (-p) := by
    have := Real.add_one_le_exp (-p)
    linarith
  calc (1 - p) ^ N ≤ (Real.exp (-p)) ^ N := by
        exact pow_le_pow_left₀ (by linarith) h1 N
    _ = Real.exp (-(p * N)) := by
        rw [← Real.exp_nat_mul]
        ring_nf

/-- With a positive excitation probability, Hausdorffness dies out as the number
of Planck cells grows. -/
theorem tendsto_hausdorffWeight_zero {p : ℝ} (hp0 : 0 < p) (hp1 : p ≤ 1) (ℓ : ℝ) :
    Tendsto (fun N => hausdorffWeight p ℓ N) atTop (𝓝 0) := by
  simp only [hausdorffWeight_eq]
  refine tendsto_pow_atTop_nhds_zero_of_lt_one (by linarith) ?_
  linarith

/-! ### Divergence of the branch density at the Planck scale -/

/-- **Planck-scale divergence.** Inside a fixed macroscopic interval of length
`L`, the expected number of branch points `p * ⌊L / ℓ⌋` diverges as the Planck
spacing `ℓ` tends to `0`. -/
theorem tendsto_expected_count_atTop {p L : ℝ} (hp : 0 < p) (hL : 0 < L) :
    Tendsto (fun ℓ : ℝ => p * (⌊L / ℓ⌋₊ : ℝ)) (𝓝[>] 0) atTop := by
  have h1 : Tendsto (fun ℓ : ℝ => L / ℓ) (𝓝[>] 0) atTop := by
    simpa [div_eq_mul_inv] using
      (tendsto_inv_nhdsGT_zero.const_mul_atTop hL)
  have h2 : Tendsto (fun ℓ : ℝ => (⌊L / ℓ⌋₊ : ℝ)) (𝓝[>] 0) atTop :=
    tendsto_natCast_atTop_atTop.comp (tendsto_nat_floor_atTop.comp h1)
  exact h2.const_mul_atTop hp

end Stochastic
end PlanckFoam