import Physics.TropicalThermodynamics.Landauer

/-!
# Landauer's principle with a finite-system fluctuation correction

This file builds on the catalog's `entropyDefect`.  A deterministic operation is
logically irreversible when it is not injective.  Its thermodynamic realization is
represented only through an explicit lower-bound hypothesis relating dissipated heat
to the information defect; no microscopic dynamics are silently assumed.

For a one-bit erasure (`Bool → Unit`) the defect is exactly `log 2`.  Consequently,
the thermodynamic-limit constitutive inequality gives the usual `k T log 2` bound.
For a finite system, an exponential-work identity gives the exact Jarzynski-style
correction `-log A / β`, where `A` is the exponential average and `β` is inverse
temperature.  If `A ≤ 1`, this correction is nonnegative.
-/

open Real Set Fintype Filter Topology

namespace QuantumThermodynamics

/-- Canonical logical erasure of one bit. -/
def eraseBit : Bool → Unit := fun _ => ()

/-- Thermodynamic Landauer scale corresponding to an information defect. -/
noncomputable def landauerScale (k T defect : ℝ) : ℝ := k * T * defect

/-- The finite-system correction extracted from an exponential-work average `A` at
inverse temperature `β`. -/
noncomputable def jarzynskiCorrection (β A : ℝ) : ℝ := -Real.log A / β

/-- Erasing a Boolean bit loses exactly `log 2` natural units of information. -/
theorem eraseBit_entropyDefect : entropyDefect eraseBit = Real.log 2 := by
  unfold entropyDefect
  have h_card_bool : Fintype.card Bool = 2 := by decide
  have h_range : Set.range eraseBit = {()} := by
    ext x
    simp [eraseBit]
  have h_card_range : Fintype.card (Set.range eraseBit) = 1 := by
    simp [h_range]
  rw [h_card_bool, h_card_range]
  simp

/-- The thermodynamic-limit Landauer bound for one bit.  The hypothesis `hphysical`
is the constitutive link between dissipated heat and the catalog's information defect. -/
theorem landauer_one_bit
    (k T heat : ℝ)
    (hphysical : landauerScale k T (entropyDefect eraseBit) ≤ heat) :
    k * T * Real.log 2 ≤ heat := by
  simpa [landauerScale, eraseBit_entropyDefect] using hphysical

/-- A noninjective operation on a finite nonempty state space has strictly positive
information defect, strengthening the catalog's nonnegativity theorem. -/
theorem entropyDefect_pos_of_logically_irreversible
    {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] [Nonempty α]
    (f : α → β) (hirr : ¬ Function.Injective f) :
    0 < entropyDefect f := by
  unfold entropyDefect
  refine sub_pos_of_lt (Real.log_lt_log ?_ ?_)
  · exact Nat.cast_pos.mpr (Fintype.card_pos)
  · have hcard : Fintype.card (Set.range f) < Fintype.card α := by
      have hle := Fintype.card_range_le f
      refine lt_of_le_of_ne hle ?_
      intro heq
      apply hirr
      have hsurj : Function.Surjective fun x : α => (⟨f x, Set.mem_range_self x⟩ : Set.range f) := by
        intro ⟨b, hb⟩
        obtain ⟨a, rfl⟩ := hb
        exact ⟨a, rfl⟩
      have hbij : Function.Bijective fun x : α => (⟨f x, Set.mem_range_self x⟩ : Set.range f) := by
        rw [Fintype.bijective_iff_surjective_and_card]
        exact ⟨hsurj, heq.symm⟩
      exact fun x y hxy => hbij.1 (Subtype.ext hxy)
    exact_mod_cast hcard

/-- Logical irreversibility forces strictly positive thermodynamic dissipation whenever
`k`, `T`, and the physical realization's conversion factor are positive. -/
theorem logical_irreversibility_implies_thermodynamic_irreversibility
    {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] [Nonempty α]
    (f : α → β) (k T heat : ℝ)
    (hirr : ¬ Function.Injective f) (hk : 0 < k) (hT : 0 < T)
    (hphysical : landauerScale k T (entropyDefect f) ≤ heat) :
    0 < heat := by
  have hdefect : 0 < entropyDefect f :=
    entropyDefect_pos_of_logically_irreversible f hirr
  have hscale : 0 < landauerScale k T (entropyDefect f) := by
    exact mul_pos (mul_pos hk hT) hdefect
  exact lt_of_lt_of_le hscale hphysical

/-- Reversible finite logical operations have zero information defect. -/
theorem entropyDefect_eq_zero_of_bijective
    {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → β) (hf : Function.Bijective f) :
    entropyDefect f = 0 := by
  unfold entropyDefect
  have hrange : Set.range f = Set.univ := Set.range_eq_univ.mpr hf.2
  have hcard : Fintype.card α = Fintype.card β :=
    Fintype.card_congr (Equiv.ofBijective f hf)
  have hrangecard : Fintype.card (Set.range f) = Fintype.card β := by
    simp [hrange]
  rw [hrangecard, hcard]
  exact sub_self _

/-- Algebraic Jarzynski correction: an exponential-work identity determines the finite
heat exactly as the Landauer term plus `-log A / β`. -/
theorem finite_size_jarzynski_identity
    (β heat landauer A : ℝ) (hβ : 0 < β)
    (hfluctuation : Real.exp (-β * (heat - landauer)) = A) :
    heat = landauer + jarzynskiCorrection β A := by
  have hlog : -β * (heat - landauer) = Real.log A := by
    rw [← hfluctuation]
    exact (Real.log_exp _).symm
  have hdiv : heat - landauer = -Real.log A / β := by
    field_simp at hlog ⊢
    linarith
  rw [jarzynskiCorrection, ← hdiv]
  ring

/-- If the exponential average is at most one, the finite-size correction is
nonnegative. -/
theorem jarzynskiCorrection_nonneg
    (β A : ℝ) (hβ : 0 < β) (hA : 0 < A) (hAle : A ≤ 1) :
    0 ≤ jarzynskiCorrection β A := by
  unfold jarzynskiCorrection
  exact div_nonneg (neg_nonneg.mpr (Real.log_nonpos hA.le hAle)) hβ.le

/-- The finite-size one-bit Landauer bound.  Compared with `landauer_one_bit`, the
right side contains the explicit Jarzynski correction. -/
theorem finite_size_landauer_one_bit
    (k T β heat A : ℝ) (hβ : 0 < β) (hA : 0 < A) (hAle : A ≤ 1)
    (hfluctuation :
      Real.exp (-β * (heat - k * T * Real.log 2)) = A) :
    k * T * Real.log 2 ≤ heat := by
  have h1 := finite_size_jarzynski_identity β heat (k * T * Real.log 2) A hβ hfluctuation
  have h2 := jarzynskiCorrection_nonneg β A hβ hA hAle
  linarith

/-- The correction vanishes in the thermodynamic limit whenever the finite-system
exponential averages converge to one and inverse temperature converges to a positive
limit. -/
theorem jarzynskiCorrection_tendsto_zero
    (β A : ℕ → ℝ) (betaLim : ℝ) (hbetaLim : 0 < betaLim)
    (hβ : Tendsto β atTop (𝓝 betaLim)) (hA : Tendsto A atTop (𝓝 1)) :
    Tendsto (fun n => jarzynskiCorrection (β n) (A n)) atTop (𝓝 0) := by
  simp only [jarzynskiCorrection]
  have hlog : Tendsto (fun n => Real.log (A n)) atTop (𝓝 0) := by
    have := hA.log
    simp at this
    exact this
  have hneg : Tendsto (fun n => -Real.log (A n)) atTop (𝓝 0) := by simpa using hlog.neg
  have hdiv := hneg.div hβ (ne_of_gt hbetaLim)
  convert hdiv using 1
  simp

end QuantumThermodynamics