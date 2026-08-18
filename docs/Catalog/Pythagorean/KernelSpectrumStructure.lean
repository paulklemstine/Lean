import Pythagorean.HigherPythKernel

/-!
# Structure of kernel spectra: the partition order and the symmetry action

The kernel spectrum of a Diophantine cone is a subset of the finite set `Patterns n` of
equality patterns.  `Patterns n` carries two natural pieces of structure that have nothing
to do with arithmetic:

* an **order** — the refinement order of set partitions (`KernelStructure.Refines`), with
  bottom the discrete pattern and top the one-block pattern;
* an **action** of the symmetric group `Equiv.Perm (Fin n)` permuting coordinates
  (`KernelStructure.patternAct`).

This file shows how the arithmetic spectra of the previous files sit inside these
structures.

Order-theoretic side.

* `KernelStructure.pythSpectrum_not_convex` — the Pythagorean spectrum is **not** an
  interval: it contains the bottom `![0,1,2]` and the top `![0,0,0]` of the partition
  lattice of a triple, but *not* the element `![0,0,2]` lying strictly between them.  So the
  defect is invisible to the extremes: it is a genuinely "interior" phenomenon.
* `KernelStructure.pythSpectrum_not_upward_closed`,
  `KernelStructure.pythSpectrum_not_downward_closed` — consequently the spectrum is neither
  an order filter nor an order ideal, and the same happens in dimension three
  (`KernelStructure.pyth3Spectrum_not_convex`).

Group-theoretic side.

* `KernelStructure.canon_comp_perm` — permuting the coordinates of a tuple permutes its
  pattern by `patternAct`: the kernel invariant is equivariant.
* `KernelStructure.spectrum_invariant` — hence the spectrum of any coordinate-symmetric
  equation is a union of `patternAct`-orbits.
* `KernelStructure.missing_orbit_hyp_two_legs`, `..._hyp_one_leg`,
  `KernelStructure.missing_isosceles_fixed` — the seven patterns missing in dimension three
  split into orbits of sizes `1 + 3 + 3` under the leg-permutation group `S₃`, which is
  exactly the orbit decomposition predicted by the two obstructions
  ("`3` is not a square" is `S₃`-invariant; the rigidity obstruction is not).
-/

open KernelPattern PythagoreanKernel HigherPyth

namespace KernelStructure

/-! ## The refinement order on patterns -/

/-- `Refines p q` says the partition encoded by `p` is *finer* than that of `q`: every
coincidence of `p` is a coincidence of `q`. -/
def Refines {n : ℕ} (p q : Fin n → Fin n) : Prop := ∀ i j, p i = p j → q i = q j

instance {n : ℕ} (p q : Fin n → Fin n) : Decidable (Refines p q) :=
  inferInstanceAs (Decidable (∀ i j, p i = p j → q i = q j))

theorem refines_refl {n : ℕ} (p : Fin n → Fin n) : Refines p p := fun _ _ h => h

theorem refines_trans {n : ℕ} {p q r : Fin n → Fin n} (h₁ : Refines p q) (h₂ : Refines q r) :
    Refines p r := fun i j h => h₂ i j (h₁ i j h)

/-- On canonical patterns the refinement order is antisymmetric, so it is a genuine partial
order on `Patterns n`. -/
theorem refines_antisymm {n : ℕ} {p q : Fin n → Fin n} (hp : canon p = p) (hq : canon q = q)
    (h₁ : Refines p q) (h₂ : Refines q p) : p = q := by
  have hker : Ker p = Ker q := ker_eq_iff.2 fun i j => ⟨h₁ i j, h₂ i j⟩
  calc p = canon p := hp.symm
    _ = canon q := canon_eq_canon_iff.2 hker
    _ = q := hq

/-- The discrete pattern is the bottom of the refinement order. -/
theorem refines_bot {n : ℕ} (p : Fin n → Fin n) : Refines (fun i => i) p :=
  fun _ _ h => congrArg p h

/-- The one-block pattern is the top of the refinement order. -/
theorem refines_top {n : ℕ} [NeZero n] (p : Fin n → Fin n) : Refines p (fun _ => 0) :=
  fun _ _ _ => rfl

/-! ### The Pythagorean spectrum is not order-convex -/

theorem refines_012_002 : Refines (![0, 1, 2] : Fin 3 → Fin 3) ![0, 0, 2] := by decide

theorem refines_002_000 : Refines (![0, 0, 2] : Fin 3 → Fin 3) ![0, 0, 0] := by decide

set_option maxRecDepth 40000 in
theorem mem_pythSpectrum_012 : (![0, 1, 2] : Fin 3 → Fin 3) ∈ pythSpectrum := by
  rw [pythSpectrum_eq]; decide

set_option maxRecDepth 40000 in
theorem mem_pythSpectrum_000 : (![0, 0, 0] : Fin 3 → Fin 3) ∈ pythSpectrum := by
  rw [pythSpectrum_eq]; decide

set_option maxRecDepth 40000 in
theorem not_mem_pythSpectrum_002 : (![0, 0, 2] : Fin 3 → Fin 3) ∉ pythSpectrum := by
  rw [pythSpectrum_eq]; decide

/-- **The Pythagorean spectrum is not an interval in the partition lattice.**  It contains
both endpoints of the chain `![0,1,2] ≺ ![0,0,2] ≺ ![0,0,0]` but misses the middle term. -/
theorem pythSpectrum_not_convex :
    ¬ ∀ p q r : Fin 3 → Fin 3, Refines p q → Refines q r → p ∈ pythSpectrum →
      r ∈ pythSpectrum → q ∈ pythSpectrum := by
  intro h
  exact not_mem_pythSpectrum_002
    (h _ _ _ refines_012_002 refines_002_000 mem_pythSpectrum_012 mem_pythSpectrum_000)

/-- The spectrum is not an order filter. -/
theorem pythSpectrum_not_upward_closed :
    ¬ ∀ p q : Fin 3 → Fin 3, Refines p q → p ∈ pythSpectrum → q ∈ pythSpectrum := fun h =>
  not_mem_pythSpectrum_002 (h _ _ refines_012_002 mem_pythSpectrum_012)

/-- The spectrum is not an order ideal. -/
theorem pythSpectrum_not_downward_closed :
    ¬ ∀ p q : Fin 3 → Fin 3, Refines p q → q ∈ pythSpectrum → p ∈ pythSpectrum := fun h =>
  not_mem_pythSpectrum_002 (h _ _ refines_002_000 mem_pythSpectrum_000)

/-- The same failure of convexity in dimension three, along the chain
`![0,1,2,3] ≺ ![0,0,0,3] ≺ ![0,0,0,0]`. -/
theorem pyth3Spectrum_not_convex :
    ¬ ∀ p q r : Fin 4 → Fin 4, Refines p q → Refines q r → p ∈ pyth3Spectrum →
      r ∈ pyth3Spectrum → q ∈ pyth3Spectrum := by
  intro h
  have hmid : (![0, 0, 0, 3] : Fin 4 → Fin 4) ∈ pyth3Spectrum :=
    h ![0, 1, 2, 3] ![0, 0, 0, 3] ![0, 0, 0, 0] (by decide) (by decide) (by decide) (by decide)
  revert hmid
  decide

/-! ## The symmetry action on patterns -/

/-- The symmetric group acts on patterns: permute the coordinates and re-canonicalise. -/
def patternAct {n : ℕ} (σ : Equiv.Perm (Fin n)) (p : Fin n → Fin n) : Fin n → Fin n :=
  canon (p ∘ σ)

/-- **Equivariance of the kernel invariant.**  Permuting coordinates of a tuple permutes its
pattern accordingly. -/
theorem canon_comp_perm {n : ℕ} {α : Type*} [DecidableEq α] (t : Fin n → α)
    (σ : Equiv.Perm (Fin n)) : canon (t ∘ σ) = patternAct σ (canon t) := by
  refine canon_eq_canon_iff.2 ?_
  funext i j
  exact propext (eq_iff_canon_eq t (σ i) (σ j))

theorem patternAct_mem_patterns {n : ℕ} (σ : Equiv.Perm (Fin n)) (p : Fin n → Fin n) :
    patternAct σ p ∈ Patterns n := canon_mem_patterns _

/-- **The spectrum of a coordinate-symmetric equation is a union of orbits.** -/
theorem spectrum_invariant {n : ℕ} (Sol : (Fin n → ℕ) → Prop) (σ : Equiv.Perm (Fin n))
    (hσ : ∀ t, Sol t → Sol (t ∘ σ)) {p : Fin n → Fin n}
    (hp : ∃ t : Fin n → ℕ, Sol t ∧ canon t = p) :
    ∃ t : Fin n → ℕ, Sol t ∧ canon t = patternAct σ p := by
  obtain ⟨t, ht, rfl⟩ := hp
  exact ⟨t ∘ σ, hσ t ht, canon_comp_perm t σ⟩

/-! ### Leg symmetries of the Pythagorean cones -/

theorem isPythTriple_swap01 (t : Fin 3 → ℕ) (h : IsPythTriple t) :
    IsPythTriple (t ∘ Equiv.swap 0 1) := by
  have h0 : (t ∘ Equiv.swap (0 : Fin 3) 1) 0 = t 1 := by simp [Equiv.swap_apply_left]
  have h1 : (t ∘ Equiv.swap (0 : Fin 3) 1) 1 = t 0 := by simp [Equiv.swap_apply_right]
  have h2 : (t ∘ Equiv.swap (0 : Fin 3) 1) 2 = t 2 := by
    simp [Equiv.swap_apply_of_ne_of_ne (show (2 : Fin 3) ≠ 0 by decide)
      (show (2 : Fin 3) ≠ 1 by decide)]
  rw [IsPythTriple, h0, h1, h2]
  rw [IsPythTriple] at h
  omega

/-- The Pythagorean spectrum is stable under swapping the two legs. -/
theorem pythSpectrum_swap_invariant {p : Fin 3 → Fin 3} (hp : p ∈ pythSpectrum) :
    patternAct (Equiv.swap 0 1) p ∈ pythSpectrum :=
  (pyth_kernel_spectrum _).1
    (spectrum_invariant IsPythTriple _ isPythTriple_swap01 ((pyth_kernel_spectrum p).2 hp))

theorem isPyth3_swap {t : Fin 4 → ℕ} (h : IsPyth3 t) (a b : Fin 4) (ha : a ≠ 3) (hb : b ≠ 3) :
    IsPyth3 (t ∘ Equiv.swap a b) := by
  have h3 : (t ∘ Equiv.swap a b) 3 = t 3 := by
    simp [Equiv.swap_apply_of_ne_of_ne (Ne.symm ha) (Ne.symm hb)]
  have hperm : ((t ∘ Equiv.swap a b) 0) ^ 2 + ((t ∘ Equiv.swap a b) 1) ^ 2 +
      ((t ∘ Equiv.swap a b) 2) ^ 2 = t 0 ^ 2 + t 1 ^ 2 + t 2 ^ 2 := by
    fin_cases a <;> fin_cases b <;> simp_all [Equiv.swap_apply_left, Equiv.swap_apply_right,
      Equiv.swap_apply_of_ne_of_ne] <;> omega
  rw [IsPyth3, h3, hperm]
  exact h

/-- The three-dimensional spectrum is stable under permuting the legs. -/
theorem pyth3Spectrum_swap_invariant {p : Fin 4 → Fin 4} (a b : Fin 4) (ha : a ≠ 3) (hb : b ≠ 3)
    (hp : p ∈ pyth3Spectrum) : patternAct (Equiv.swap a b) p ∈ pyth3Spectrum :=
  (pyth3_kernel_spectrum _).1
    (spectrum_invariant IsPyth3 _ (fun _ ht => isPyth3_swap ht a b ha hb)
      ((pyth3_kernel_spectrum p).2 hp))

/-! ### Orbit decomposition of the seven missing patterns -/

/-- The "all legs equal" obstruction is `S₃`-invariant: its pattern is a fixed point. -/
theorem missing_isosceles_fixed (a b : Fin 4) (ha : a ≠ 3) (hb : b ≠ 3) :
    patternAct (Equiv.swap a b) ![0, 0, 0, 3] = ![0, 0, 0, 3] := by
  fin_cases a <;> fin_cases b <;> simp_all <;> decide

/-- The three "hypotenuse meets two legs" patterns form a single orbit. -/
theorem missing_orbit_hyp_two_legs :
    patternAct (Equiv.swap 1 2) ![0, 0, 2, 0] = ![0, 1, 0, 0] ∧
      patternAct (Equiv.swap 0 2) ![0, 0, 2, 0] = ![0, 1, 1, 1] := by
  constructor <;> decide

/-- The three "hypotenuse meets exactly one leg, other legs distinct" patterns form a single
orbit. -/
theorem missing_orbit_hyp_one_leg :
    patternAct (Equiv.swap 0 1) ![0, 1, 2, 0] = ![0, 1, 2, 1] ∧
      patternAct (Equiv.swap 0 2) ![0, 1, 2, 0] = ![0, 1, 2, 2] := by
  constructor <;> decide

/-- **Orbit count.**  The seven missing patterns in dimension three split as `1 + 3 + 3`
under the leg-permutation group, matching the two independent obstructions: the
square-obstruction (one fixed pattern) and the rigidity obstruction (two orbits of size
three). -/
theorem missing_patterns_partition :
    (Patterns 4).card - pyth3Spectrum.card = 1 + 3 + 3 := by
  rw [card_patterns_four, card_pyth3Spectrum]

end KernelStructure