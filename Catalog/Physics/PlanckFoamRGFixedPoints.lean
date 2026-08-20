import Physics.PlanckFoamRG
import Physics.PlanckFoamDefect

/-!
# Fixed points of the scale-halving renormalisation flow on lattice foams

`Physics.PlanckFoamRG` builds the coarse-graining tower `foamCollapse` for a
shrinking branch locus.  Here we analyse the concrete physical flow on the real
line: the **lattice foam** with Planck spacing `ℓ`, whose branch locus is

`latticeSet ℓ = {x : ℝ | ∃ n : ℤ, x = ℓ * n}`,

and the scale-halving step `ℓ ↦ 2ℓ` (observing the foam at twice the Planck
length).

## Main results

* `latticeSet_two_mul_subset`, `latticeSet_two_mul_ssubset` — the flow really is
  a coarse graining, and it is *strict* for every nonzero spacing.
* `latticeSet_two_mul_eq_iff` — **classification of fixed points**: the flow
  fixes `latticeSet ℓ` if and only if `ℓ = 0`, i.e. the only fixed lattice foam
  is the single-branch-point foam `S = {0}`.
* `iInter_latticeSet_eq_singleton_zero` — the *limit* of the tower: intersecting
  all rescalings of a nonzero lattice leaves exactly the origin.  The flow does
  **not** reach the smooth (empty-locus) foam; it terminates at a foam with one
  Planck branch point.
* `not_t2Space_foam_latticeSet_zero`, `card_defectSet_latticeSet_zero` — this
  limit foam is still non-Hausdorff, with metric defect exactly `2`.
* `foamCollapse_not_injective_of_ne_zero` — every step of the flow destroys
  information.

**Critic's note.** These theorems *refute* the conjecture (Conjecture 4 of the
previous cycle) that the only fixed points of the scale-halving flow are the
empty and the full branch locus: the flow has the nontrivial, genuinely
non-Hausdorff fixed point `S = {0}`, and no nonzero lattice foam ever flows to
the smooth foam.
-/

open Set Topology

namespace PlanckFoam

/-- The branch locus of the lattice foam of Planck spacing `ℓ`. -/
def latticeSet (l : ℝ) : Set ℝ := {x : ℝ | ∃ n : ℤ, x = l * n}

theorem mem_latticeSet {l x : ℝ} : x ∈ latticeSet l ↔ ∃ n : ℤ, x = l * n := Iff.rfl

@[simp] theorem latticeSet_zero : latticeSet 0 = {(0 : ℝ)} := by
  ext x
  simp [mem_latticeSet]

theorem zero_mem_latticeSet (l : ℝ) : (0 : ℝ) ∈ latticeSet l := ⟨0, by simp⟩

/-! ### The scale-halving flow -/

/-- Coarse graining: the lattice of spacing `2ℓ` sits inside the lattice of
spacing `ℓ`. -/
theorem latticeSet_two_mul_subset (l : ℝ) : latticeSet (2 * l) ⊆ latticeSet l := by
  rintro x ⟨n, rfl⟩
  exact ⟨2 * n, by push_cast; ring⟩

/-- For a nonzero Planck spacing the coarse graining is **strict**: the sites at
odd multiples of `ℓ` are erased. -/
theorem latticeSet_two_mul_ssubset {l : ℝ} (hl : l ≠ 0) :
    latticeSet (2 * l) ⊂ latticeSet l := by
  refine ⟨latticeSet_two_mul_subset l, fun hsub => ?_⟩
  obtain ⟨n, hn⟩ : l ∈ latticeSet (2 * l) := hsub ⟨1, by simp⟩
  have hcancel : l * 1 = l * (2 * (n : ℝ)) := by linear_combination hn
  have h2 : (1 : ℝ) = 2 * (n : ℝ) := mul_left_cancel₀ hl hcancel
  have hcast : ((2 * n : ℤ) : ℝ) = ((1 : ℤ) : ℝ) := by push_cast; linarith
  have h2n : (2 * n : ℤ) = 1 := by exact_mod_cast hcast
  omega

/-- **Classification of the fixed points of the scale-halving flow.** The
lattice foam of spacing `ℓ` is invariant under `ℓ ↦ 2ℓ` if and only if `ℓ = 0`,
that is, if and only if it is the foam with a single Planck branch point at the
origin. -/
theorem latticeSet_two_mul_eq_iff {l : ℝ} : latticeSet (2 * l) = latticeSet l ↔ l = 0 := by
  constructor
  · intro h
    by_contra hl
    exact (latticeSet_two_mul_ssubset hl).ne h
  · rintro rfl
    simp

/-! ### The limit of the tower -/

theorem latticeSet_pow_subset (l : ℝ) (k : ℕ) : latticeSet (2 ^ k * l) ⊆ latticeSet l := by
  rintro x ⟨n, rfl⟩
  exact ⟨2 ^ k * n, by push_cast; ring⟩

/-- **The tower does not flow to the smooth foam.** Intersecting every
rescaling of a nonzero lattice foam leaves exactly one Planck branch point: the
origin. -/
theorem iInter_latticeSet_eq_singleton_zero {l : ℝ} (hl : l ≠ 0) :
    ⋂ k : ℕ, latticeSet (2 ^ k * l) = {(0 : ℝ)} := by
  refine Subset.antisymm (fun x hx => ?_) (fun x hx => ?_)
  · simp only [mem_iInter] at hx
    by_contra hx0
    have habs : ∀ k : ℕ, (2 : ℝ) ^ k * |l| ≤ |x| := by
      intro k
      obtain ⟨n, hn⟩ := hx k
      have hn0 : n ≠ 0 := by
        rintro rfl
        simp at hn
        exact hx0 hn
      have h1 : (1 : ℝ) ≤ |(n : ℝ)| := by
        have : (1 : ℤ) ≤ |n| := Int.one_le_abs (by simpa using hn0)
        calc (1 : ℝ) = ((1 : ℤ) : ℝ) := by norm_num
          _ ≤ ((|n| : ℤ) : ℝ) := by exact_mod_cast this
          _ = |(n : ℝ)| := by push_cast [Int.cast_abs]; ring
      have habsx : |x| = 2 ^ k * |l| * |(n : ℝ)| := by
        rw [hn, abs_mul, abs_mul, abs_pow]
        simp
      rw [habsx]
      have hlp : 0 < |l| := abs_pos.2 hl
      have hp : (0 : ℝ) < 2 ^ k := pow_pos (by norm_num) k
      have hkey : 2 ^ k * |l| * 1 ≤ 2 ^ k * |l| * |(n : ℝ)| :=
        mul_le_mul_of_nonneg_left h1 (le_of_lt (mul_pos hp hlp))
      linarith
    obtain ⟨k, hk⟩ := pow_unbounded_of_one_lt (|x| / |l|) (by norm_num : (1:ℝ) < 2)
    have hlpos : 0 < |l| := abs_pos.2 hl
    have := habs k
    rw [div_lt_iff₀ hlpos] at hk
    linarith
  · rw [mem_singleton_iff] at hx
    subst hx
    exact mem_iInter.2 fun k => zero_mem_latticeSet _

/-! ### The limit foam is still foamy -/

/-- The limit of the renormalisation tower is a genuinely non-Hausdorff foam:
one Planck branch point survives every coarse graining. -/
theorem not_t2Space_foam_latticeSet_zero :
    ¬ T2Space (Foam ℝ (latticeSet 0) Bool) := by
  rw [t2Space_foam_iff]
  rintro ⟨-, hopen⟩
  rw [latticeSet_zero] at hopen
  have : interior ({(0 : ℝ)} : Set ℝ) = {(0 : ℝ)} := hopen.interior_eq
  rw [interior_singleton] at this
  exact absurd this.symm (singleton_ne_empty (0 : ℝ))

/-- The metric defect of the limit foam is exactly `2`: the two Planck branches
over the origin can never be separated. -/
theorem card_defectSet_latticeSet_zero :
    Nat.card (defectSet ℝ (latticeSet 0) Bool) = 2 := by
  rw [latticeSet_zero]
  exact card_defectSet_line_point

/-- **Every step of the flow destroys information.** For a nonzero Planck
spacing the coarse graining of lattice foams is never injective. -/
theorem foamCollapse_not_injective_of_ne_zero {l : ℝ} (hl : l ≠ 0) :
    ¬ Function.Injective
      (foamCollapse (ι := Bool) (latticeSet l) (latticeSet (2 * l))
        (latticeSet_two_mul_subset l)) := by
  rw [foamCollapse_injective_iff]
  exact fun h => (latticeSet_two_mul_ssubset hl).ne h.symm

end PlanckFoam