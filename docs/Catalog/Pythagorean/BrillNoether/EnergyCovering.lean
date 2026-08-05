/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# The energy pairing of a graph: Cheeger's inequality and a covering radius bound

This file develops the *energy quadratic form* (Dirichlet form) of a finite
simple graph together with two quantitative results about it that are the
analytic core of the geometry-of-numbers approach to Brill–Noether theory on
graphs.

The energy form is `E(x) = ∑_{i ∼ j} (x i - x j)²` (each edge counted once),
i.e. the quadratic form of the graph Laplacian.  The *Laplacian lattice* is the
set of integer vectors `L f`, `f : V → ℤ`, which is exactly the group of
principal divisors of the graph; the covering radius of this lattice with
respect to the energy form governs the Brill–Noether behaviour of the graph.

## Main definitions

* `BrillNoetherEnergy.energy` — the energy (Dirichlet) form of the graph.
* `BrillNoetherEnergy.cut` — the number of ordered pairs crossing a vertex cut.
* `BrillNoetherEnergy.spectralGap` — the variational second Laplacian eigenvalue
  `λ₂ = inf { E(x) / ‖x‖² : ∑ x = 0, x ≠ 0 }`.
* `BrillNoetherEnergy.lapR` — a lattice point `L f` of the Laplacian lattice,
  viewed as a real vector.
* `BrillNoetherEnergy.crossFunctional` — the linear functional
  `φ_S(x) = ∑_{v ∈ S} x v - (|S| / n) ∑_v x v`, which is integer valued on the
  Laplacian lattice and vanishes on constants.

## Main results

* `energy_indicator` — `E(1_S)` equals the size of the cut `(S, Sᶜ)`.
* `spectralGap_mul_variance_le_energy` — the Poincaré inequality `λ₂ · Var(x) ≤ E(x)`.
* `spectralGap_mul_le_cut` — the easy direction of **Cheeger's inequality**:
  `λ₂ · |S| · |Sᶜ| ≤ n · cut(S)`; in the balanced form
  `spectralGap_le_two_mul_cut_div` this reads `λ₂ ≤ 2 · cut(S) / |S|` for
  `2|S| ≤ n`.
* `crossFunctional_sq_bound` — the dual (Cauchy–Schwarz) bound
  `n · λ₂ · φ_S(x)² ≤ |S| · |Sᶜ| · E(x)`.
* `exists_far_from_lapLattice` — a **lower bound for the covering radius** of the
  Laplacian lattice in the energy metric: there is a point `y` with
  `n · λ₂ ≤ 4 · |S| · |Sᶜ| · E(y - L f)` for *every* lattice point `L f`.
  Specialising to a single vertex gives `exists_far_from_lapLattice_vertex`.
-/

open Finset Matrix

namespace BrillNoetherEnergy

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## The energy form -/

/-- The energy (Dirichlet) form of a graph: `E(x) = ∑_{i ∼ j} (x i - x j)²`,
each edge being counted once. -/
noncomputable def energy (x : V → ℝ) : ℝ :=
  (∑ i, ∑ j, if G.Adj i j then (x i - x j) ^ 2 else 0) / 2

omit [DecidableEq V] in
theorem energy_nonneg (x : V → ℝ) : 0 ≤ energy G x := by
  apply div_nonneg _ (by norm_num)
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => by positivity

omit [DecidableEq V] in
/-- The energy form is invariant under adding a constant vector. -/
theorem energy_sub_const (x : V → ℝ) (c : ℝ) : energy G (fun v => x v - c) = energy G x := by
  simp [energy, sub_sub_sub_cancel_right]

/-- The energy form is the quadratic form of the graph Laplacian. -/
theorem energy_eq_lapMatrix (x : V → ℝ) :
    energy G x = Matrix.toLinearMap₂' ℝ (G.lapMatrix ℝ) x x :=
  (G.lapMatrix_toLinearMap₂' ℝ x).symm

/-- The number of ordered pairs `(i, j)` with `i ∈ S`, `j ∉ S` and `i ∼ j`, i.e.
the number of edges of the cut determined by `S`. -/
def cut (S : Finset V) : ℕ := ∑ i ∈ S, ∑ j ∈ Sᶜ, if G.Adj i j then 1 else 0

theorem cut_cast (S : Finset V) :
    (cut G S : ℝ) = ∑ i ∈ S, ∑ j ∈ Sᶜ, if G.Adj i j then (1 : ℝ) else 0 := by
  rw [cut]; push_cast; simp

theorem cut_symm_real (S : Finset V) :
    (∑ i ∈ Sᶜ, ∑ j ∈ S, if G.Adj i j then (1 : ℝ) else 0) = (cut G S : ℝ) := by
  rw [cut_cast, Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by simp [G.adj_comm]

/-- **The energy of an indicator vector is the size of the corresponding cut.** -/
theorem energy_indicator (S : Finset V) :
    energy G (fun v => if v ∈ S then (1 : ℝ) else 0) = (cut G S : ℝ) := by
  have key : ∀ i j : V, (if G.Adj i j then
      (((if i ∈ S then (1 : ℝ) else 0) - (if j ∈ S then (1 : ℝ) else 0)) ^ 2) else 0)
      = (if G.Adj i j then (if i ∈ S then (if j ∈ S then (0 : ℝ) else 1)
          else (if j ∈ S then 1 else 0)) else 0) := by
    intro i j
    by_cases h : G.Adj i j <;> by_cases hi : i ∈ S <;> by_cases hj : j ∈ S <;> simp [h, hi, hj]
  have step : ∀ i : V, (∑ j, if G.Adj i j then (if i ∈ S then (if j ∈ S then (0 : ℝ) else 1)
      else (if j ∈ S then 1 else 0)) else 0)
      = if i ∈ S then (∑ j ∈ Sᶜ, if G.Adj i j then (1 : ℝ) else 0)
        else (∑ j ∈ S, if G.Adj i j then (1 : ℝ) else 0) := by
    intro i
    by_cases hi : i ∈ S
    · simp only [if_pos hi]
      rw [← Finset.sum_add_sum_compl S,
        Finset.sum_eq_zero (fun x hx => by simp [hx] : ∀ x ∈ S,
          (if G.Adj i x then (if x ∈ S then (0 : ℝ) else 1) else 0) = 0), zero_add]
      exact Finset.sum_congr rfl fun x hx => by simp [Finset.mem_compl.mp hx]
    · simp only [if_neg hi]
      rw [← Finset.sum_add_sum_compl S,
        Finset.sum_eq_zero (fun x hx => by simp [Finset.mem_compl.mp hx] : ∀ x ∈ Sᶜ,
          (if G.Adj i x then (if x ∈ S then (1 : ℝ) else 0) else 0) = 0), add_zero]
      exact Finset.sum_congr rfl fun x hx => by simp [hx]
  rw [energy]
  simp_rw [key, step]
  rw [← Finset.sum_add_sum_compl S,
    Finset.sum_congr rfl (fun i hi => if_pos hi),
    Finset.sum_congr rfl (fun i hi => if_neg (Finset.mem_compl.mp hi))]
  rw [← cut_cast, cut_symm_real]
  ring

/-! ## The spectral gap and Cheeger's inequality -/

/-- The variational spectral gap of the graph, i.e. the second smallest
eigenvalue of the Laplacian, described as the infimum of the Rayleigh quotient
over nonzero vectors of mean zero. -/
noncomputable def spectralGap : ℝ :=
  sInf {r : ℝ | ∃ x : V → ℝ, (∑ v, x v = 0) ∧ x ≠ 0 ∧ r = energy G x / (∑ v, (x v) ^ 2)}

omit [DecidableEq V] in
theorem spectralGap_nonneg : 0 ≤ spectralGap G := by
  apply Real.sInf_nonneg
  rintro r ⟨x, _, _, rfl⟩
  exact div_nonneg (energy_nonneg G x) (Finset.sum_nonneg fun v _ => sq_nonneg _)

omit [DecidableEq V] in
theorem spectralGap_le_rayleigh {x : V → ℝ} (hx : ∑ v, x v = 0) (hx0 : x ≠ 0) :
    spectralGap G ≤ energy G x / (∑ v, (x v) ^ 2) := by
  apply csInf_le
  · refine ⟨0, ?_⟩
    rintro r ⟨y, _, _, rfl⟩
    exact div_nonneg (energy_nonneg G y) (Finset.sum_nonneg fun v _ => sq_nonneg _)
  · exact ⟨x, hx, hx0, rfl⟩

omit [DecidableEq V] in
/-- **Poincaré inequality.**  The variance of a vector is controlled by its energy:
`λ₂ · ∑_v (x v - mean)² ≤ E(x)`. -/
theorem spectralGap_mul_variance_le_energy [Nonempty V] (x : V → ℝ) (m : ℝ)
    (hm : m = (∑ v, x v) / (Fintype.card V)) :
    spectralGap G * (∑ v, (x v - m) ^ 2) ≤ energy G x := by
  have hcard : (Fintype.card V : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  set y : V → ℝ := fun v => x v - m with hy
  have hsum : ∑ v, y v = 0 := by
    simp only [hy, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, hm]
    field_simp
    ring
  by_cases hy0 : y = 0
  · show spectralGap G * (∑ v, (y v) ^ 2) ≤ energy G x
    rw [hy0]
    simpa using energy_nonneg G x
  · have h1 : spectralGap G ≤ energy G y / (∑ v, (y v) ^ 2) := spectralGap_le_rayleigh G hsum hy0
    have hpos : 0 < ∑ v, (y v) ^ 2 := by
      rcases Function.ne_iff.mp hy0 with ⟨v, hv⟩
      exact Finset.sum_pos' (fun i _ => sq_nonneg _)
        ⟨v, Finset.mem_univ v, pow_two_pos_of_ne_zero hv⟩
    show spectralGap G * (∑ v, (y v) ^ 2) ≤ energy G x
    calc spectralGap G * (∑ v, (y v) ^ 2) ≤ (energy G y / (∑ v, (y v) ^ 2)) * (∑ v, (y v) ^ 2) :=
          mul_le_mul_of_nonneg_right h1 (le_of_lt hpos)
      _ = energy G y := by field_simp
      _ = energy G x := energy_sub_const G x m

/-- The variance of the indicator vector of `S` equals `|S| · |Sᶜ| / n`. -/
theorem variance_indicator [Nonempty V] (S : Finset V) :
    ∑ v, ((if v ∈ S then (1 : ℝ) else 0) - (S.card : ℝ) / (Fintype.card V)) ^ 2
      = (S.card : ℝ) * (Sᶜ.card : ℝ) / (Fintype.card V) := by
  have hcard : (Fintype.card V : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  have hsplit : (S.card : ℝ) + (Sᶜ.card : ℝ) = (Fintype.card V : ℝ) := by
    have := Finset.card_add_card_compl S
    exact_mod_cast this
  have e1 : ∀ v ∈ S, ((if v ∈ S then (1 : ℝ) else 0) - (S.card : ℝ) / (Fintype.card V)) ^ 2
      = (1 - (S.card : ℝ) / (Fintype.card V)) ^ 2 := fun v hv => by rw [if_pos hv]
  have e2 : ∀ v ∈ Sᶜ, ((if v ∈ S then (1 : ℝ) else 0) - (S.card : ℝ) / (Fintype.card V)) ^ 2
      = (0 - (S.card : ℝ) / (Fintype.card V)) ^ 2 :=
    fun v hv => by rw [if_neg (Finset.mem_compl.mp hv)]
  have ht : (Sᶜ.card : ℝ) = (Fintype.card V : ℝ) - (S.card : ℝ) := by linarith
  rw [← Finset.sum_add_sum_compl S, Finset.sum_congr rfl e1, Finset.sum_congr rfl e2]
  simp only [Finset.sum_const, nsmul_eq_mul]
  rw [ht]
  field_simp
  ring

/-- **Cheeger's inequality (easy direction).**  The spectral gap is bounded by the
normalised size of any cut: `λ₂ · |S| · |Sᶜ| ≤ n · cut(S)`. -/
theorem spectralGap_mul_le_cut [Nonempty V] (S : Finset V) :
    spectralGap G * ((S.card : ℝ) * (Sᶜ.card : ℝ)) ≤ (Fintype.card V : ℝ) * (cut G S : ℝ) := by
  have hcard : (0 : ℝ) < (Fintype.card V : ℝ) := by exact_mod_cast Fintype.card_pos
  have hP := spectralGap_mul_variance_le_energy G (fun v => if v ∈ S then (1 : ℝ) else 0)
    ((S.card : ℝ) / (Fintype.card V)) (by
      simp [Finset.sum_ite_mem, Finset.sum_const])
  have hvarS : ∑ v, ((if v ∈ S then (1 : ℝ) else 0) - (S.card : ℝ) / (Fintype.card V)) ^ 2
      = (S.card : ℝ) * (Sᶜ.card : ℝ) / (Fintype.card V) := variance_indicator S
  have hE : energy G (fun v => if v ∈ S then (1 : ℝ) else 0) = (cut G S : ℝ) :=
    energy_indicator G S
  have hP' : spectralGap G * ((S.card : ℝ) * (Sᶜ.card : ℝ) / (Fintype.card V))
      ≤ (cut G S : ℝ) := by
    rw [← hvarS, ← hE]; exact hP
  rw [mul_div_assoc', div_le_iff₀ hcard] at hP'
  linarith [hP']

/-- Cheeger's inequality in the usual normalised form: for a set `S` occupying at
most half the vertices, `λ₂ ≤ 2 · cut(S) / |S|`. -/
theorem spectralGap_le_two_mul_cut_div [Nonempty V] (S : Finset V) (hS : S.Nonempty)
    (hhalf : 2 * S.card ≤ Fintype.card V) :
    spectralGap G ≤ 2 * (cut G S : ℝ) / (S.card : ℝ) := by
  have hs : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hS
  have hcard : (0 : ℝ) < (Fintype.card V : ℝ) := by exact_mod_cast Fintype.card_pos
  have hsplit : (S.card : ℝ) + (Sᶜ.card : ℝ) = (Fintype.card V : ℝ) := by
    have := Finset.card_add_card_compl S
    exact_mod_cast this
  have hhalf' : 2 * (S.card : ℝ) ≤ (Fintype.card V : ℝ) := by exact_mod_cast hhalf
  have hmain := spectralGap_mul_le_cut G S
  have hgap := spectralGap_nonneg G
  rw [le_div_iff₀ hs]
  nlinarith [hmain, hgap, hs, hcard, hsplit, hhalf']

/-! ## The Laplacian lattice and a covering radius lower bound -/

/-- The lattice point of the Laplacian lattice associated with `f : V → ℤ`,
regarded as a real vector.  These are precisely the principal divisors of the
graph. -/
noncomputable def lapR (f : V → ℤ) : V → ℝ := fun v => ((G.lapMatrix ℤ *ᵥ f) v : ℝ)

/-- Points of the Laplacian lattice have coordinate sum zero. -/
theorem sum_lapR (f : V → ℤ) : ∑ v, lapR G f v = 0 := by
  have h : ∑ v, (G.lapMatrix ℤ *ᵥ f) v = 0 := by
    have h1 : ∑ v, (G.lapMatrix ℤ *ᵥ f) v = (fun _ : V => (1 : ℤ)) ⬝ᵥ (G.lapMatrix ℤ *ᵥ f) := by
      simp [dotProduct]
    rw [h1, dotProduct_mulVec]
    have h2 : vecMul (fun _ : V => (1 : ℤ)) (G.lapMatrix ℤ) = 0 := by
      rw [← mulVec_transpose, show (G.lapMatrix ℤ)ᵀ = G.lapMatrix ℤ from G.isSymm_lapMatrix]
      exact G.lapMatrix_mulVec_const_eq_zero
    rw [h2]; simp
  have : ∑ v, lapR G f v = ((∑ v, (G.lapMatrix ℤ *ᵥ f) v : ℤ) : ℝ) := by
    simp [lapR]
  rw [this, h]; simp

/-- The linear functional `φ_S(x) = ∑_{v ∈ S} x v - (|S| / n) ∑_v x v`.  It
vanishes on constant vectors and takes integer values on the Laplacian lattice. -/
noncomputable def crossFunctional (S : Finset V) (x : V → ℝ) : ℝ :=
  ∑ v ∈ S, x v - (S.card : ℝ) / (Fintype.card V) * ∑ v, x v

omit [DecidableEq V] in
theorem crossFunctional_sub (S : Finset V) (x z : V → ℝ) :
    crossFunctional S (x - z) = crossFunctional S x - crossFunctional S z := by
  simp only [crossFunctional, Pi.sub_apply, Finset.sum_sub_distrib]
  ring

/-- On the Laplacian lattice the functional `φ_S` takes integer values. -/
theorem crossFunctional_lapR_int (S : Finset V) (f : V → ℤ) :
    ∃ m : ℤ, crossFunctional S (lapR G f) = (m : ℝ) := by
  refine ⟨∑ v ∈ S, (G.lapMatrix ℤ *ᵥ f) v, ?_⟩
  rw [crossFunctional, sum_lapR G f]
  simp [lapR]

omit [DecidableEq V] in
/-- `φ_S` is the sum over `S` of the centred vector. -/
theorem crossFunctional_eq_sum_centred [Nonempty V] (S : Finset V) (x : V → ℝ) :
    crossFunctional S x = ∑ v ∈ S, (x v - (∑ w, x w) / (Fintype.card V)) := by
  rw [crossFunctional, Finset.sum_sub_distrib]
  simp only [Finset.sum_const, nsmul_eq_mul]
  ring

/-- **Dual bound for the functional `φ_S` with respect to the energy form.**
This is the Cauchy–Schwarz estimate that converts the spectral gap into a bound
on the dual norm of `φ_S`. -/
theorem crossFunctional_sq_bound [Nonempty V] (S : Finset V) (x : V → ℝ) :
    (Fintype.card V : ℝ) * spectralGap G * (crossFunctional S x) ^ 2
      ≤ (S.card : ℝ) * (Sᶜ.card : ℝ) * energy G x := by
  have hcard : (0 : ℝ) < (Fintype.card V : ℝ) := by exact_mod_cast Fintype.card_pos
  have hsplit : (S.card : ℝ) + (Sᶜ.card : ℝ) = (Fintype.card V : ℝ) := by
    have := Finset.card_add_card_compl S
    exact_mod_cast this
  set m : ℝ := (∑ w, x w) / (Fintype.card V) with hm
  set y : V → ℝ := fun v => x v - m with hy
  have hphi : crossFunctional S x = ∑ v ∈ S, y v := crossFunctional_eq_sum_centred S x
  have hzero : ∑ v ∈ S, y v + ∑ v ∈ Sᶜ, y v = 0 := by
    rw [Finset.sum_add_sum_compl]
    simp only [hy, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, hm]
    field_simp
    ring
  -- Cauchy–Schwarz on `S` and on its complement
  have hCS1 : (∑ v ∈ S, y v) ^ 2 ≤ (S.card : ℝ) * ∑ v ∈ S, (y v) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hCS2 : (∑ v ∈ Sᶜ, y v) ^ 2 ≤ (Sᶜ.card : ℝ) * ∑ v ∈ Sᶜ, (y v) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hvar : ∑ v ∈ S, (y v) ^ 2 + ∑ v ∈ Sᶜ, (y v) ^ 2 = ∑ v, (y v) ^ 2 :=
    Finset.sum_add_sum_compl S _
  have hP := spectralGap_mul_variance_le_energy G x m hm
  have hgap := spectralGap_nonneg G
  have hs : (0 : ℝ) ≤ (S.card : ℝ) := Nat.cast_nonneg _
  have ht : (0 : ℝ) ≤ (Sᶜ.card : ℝ) := Nat.cast_nonneg _
  -- `n · P² ≤ |S| · |Sᶜ| · Var(x)`
  have hkey : (Fintype.card V : ℝ) * (∑ v ∈ S, y v) ^ 2
      ≤ (S.card : ℝ) * (Sᶜ.card : ℝ) * (∑ v, (y v) ^ 2) := by
    have h2 : (∑ v ∈ S, y v) ^ 2 = (∑ v ∈ Sᶜ, y v) ^ 2 := by
      have : ∑ v ∈ Sᶜ, y v = -(∑ v ∈ S, y v) := by linarith
      rw [this]; ring
    have hA : (∑ v ∈ S, y v) ^ 2 ≤ (Sᶜ.card : ℝ) * ∑ v ∈ Sᶜ, (y v) ^ 2 := by
      rw [h2]; exact hCS2
    calc (Fintype.card V : ℝ) * (∑ v ∈ S, y v) ^ 2
        = (S.card : ℝ) * (∑ v ∈ S, y v) ^ 2 + (Sᶜ.card : ℝ) * (∑ v ∈ S, y v) ^ 2 := by
          rw [← hsplit]; ring
      _ ≤ (S.card : ℝ) * ((Sᶜ.card : ℝ) * ∑ v ∈ Sᶜ, (y v) ^ 2)
            + (Sᶜ.card : ℝ) * ((S.card : ℝ) * ∑ v ∈ S, (y v) ^ 2) :=
          add_le_add (mul_le_mul_of_nonneg_left hA hs) (mul_le_mul_of_nonneg_left hCS1 ht)
      _ = (S.card : ℝ) * (Sᶜ.card : ℝ) * (∑ v ∈ S, (y v) ^ 2 + ∑ v ∈ Sᶜ, (y v) ^ 2) := by ring
      _ = (S.card : ℝ) * (Sᶜ.card : ℝ) * (∑ v, (y v) ^ 2) := by rw [hvar]
  have hvar' : spectralGap G * (∑ v, (y v) ^ 2) ≤ energy G x := hP
  calc (Fintype.card V : ℝ) * spectralGap G * (crossFunctional S x) ^ 2
      = spectralGap G * ((Fintype.card V : ℝ) * (∑ v ∈ S, y v) ^ 2) := by rw [hphi]; ring
    _ ≤ spectralGap G * ((S.card : ℝ) * (Sᶜ.card : ℝ) * (∑ v, (y v) ^ 2)) :=
        mul_le_mul_of_nonneg_left hkey hgap
    _ = ((S.card : ℝ) * (Sᶜ.card : ℝ)) * (spectralGap G * (∑ v, (y v) ^ 2)) := by ring
    _ ≤ ((S.card : ℝ) * (Sᶜ.card : ℝ)) * energy G x :=
        mul_le_mul_of_nonneg_left hvar' (mul_nonneg hs ht)
    _ = (S.card : ℝ) * (Sᶜ.card : ℝ) * energy G x := by ring

/-- **A Cheeger-style lower bound for the covering radius of the Laplacian
lattice.**  For every cut `(S, Sᶜ)` there is a real vector `y` whose energy
distance to *every* point `L f` of the Laplacian lattice satisfies
`n · λ₂ ≤ 4 · |S| · |Sᶜ| · E(y - L f)`.

Thus a graph with a large spectral gap has a Laplacian lattice with large
covering radius in the energy metric. -/
theorem exists_far_from_lapLattice [Nonempty V] (S : Finset V) (hS : S.Nonempty)
    (hSc : Sᶜ.Nonempty) :
    ∃ y : V → ℝ, ∀ f : V → ℤ,
      (Fintype.card V : ℝ) * spectralGap G
        ≤ 4 * ((S.card : ℝ) * (Sᶜ.card : ℝ)) * energy G (y - lapR G f) := by
  have hcard : (0 : ℝ) < (Fintype.card V : ℝ) := by exact_mod_cast Fintype.card_pos
  have hs : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hS
  have ht : (0 : ℝ) < (Sᶜ.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hSc
  have hsplit : (S.card : ℝ) + (Sᶜ.card : ℝ) = (Fintype.card V : ℝ) := by
    have := Finset.card_add_card_compl S
    exact_mod_cast this
  have ht' : (Sᶜ.card : ℝ) = (Fintype.card V : ℝ) - (S.card : ℝ) := by linarith
  set c : ℝ := (Fintype.card V : ℝ) / (2 * (S.card : ℝ) * (Sᶜ.card : ℝ)) with hc
  refine ⟨fun v => if v ∈ S then c else 0, fun f => ?_⟩
  set y : V → ℝ := fun v => if v ∈ S then c else 0 with hy
  -- the chosen point satisfies `φ_S(y) = 1/2`
  have hyS : ∀ v ∈ S, y v = c := fun v hv => by simp [hy, hv]
  have hySc : ∀ v ∈ Sᶜ, y v = 0 := fun v hv => by simp [hy, Finset.mem_compl.mp hv]
  have h1 : ∑ v ∈ S, y v = (S.card : ℝ) * c := by
    rw [Finset.sum_congr rfl hyS]
    simp
  have h2 : ∑ v, y v = (S.card : ℝ) * c := by
    rw [← Finset.sum_add_sum_compl S, h1, Finset.sum_eq_zero hySc, add_zero]
  have hphiy : crossFunctional S y = 1 / 2 := by
    rw [crossFunctional, h1, h2, hc]
    have hne : (2 * (S.card : ℝ) * (Sᶜ.card : ℝ)) ≠ 0 := by positivity
    field_simp
    nlinarith [hsplit]
  obtain ⟨m, hm⟩ := crossFunctional_lapR_int G S f
  have hphi : crossFunctional S (y - lapR G f) = 1 / 2 - (m : ℝ) := by
    rw [crossFunctional_sub, hphiy, hm]
  have hsq : (1 : ℝ) / 4 ≤ (crossFunctional S (y - lapR G f)) ^ 2 := by
    rw [hphi]
    by_cases h : (m : ℝ) ≤ 0
    · nlinarith
    · have hm1 : (1 : ℝ) ≤ (m : ℝ) := by
        have : (0 : ℤ) < m := by exact_mod_cast lt_of_not_ge h
        exact_mod_cast this
      nlinarith
  have hbound := crossFunctional_sq_bound G S (y - lapR G f)
  have hgap := spectralGap_nonneg G
  have hnn : (0 : ℝ) ≤ (Fintype.card V : ℝ) * spectralGap G := mul_nonneg (le_of_lt hcard) hgap
  have hstep : (Fintype.card V : ℝ) * spectralGap G * (1 / 4)
      ≤ (Fintype.card V : ℝ) * spectralGap G * (crossFunctional S (y - lapR G f)) ^ 2 :=
    mul_le_mul_of_nonneg_left hsq hnn
  linarith [hbound, hstep]

/-- The covering radius bound specialised to a single vertex: for every vertex `v`
there is a point at energy distance at least `λ₂ / (4 (n - 1))` from the whole
Laplacian lattice. -/
theorem exists_far_from_lapLattice_vertex [Nonempty V] [Nontrivial V] (v : V) :
    ∃ y : V → ℝ, ∀ f : V → ℤ,
      (Fintype.card V : ℝ) * spectralGap G
        ≤ 4 * ((Fintype.card V : ℝ) - 1) * energy G (y - lapR G f) := by
  classical
  have hS : ({v} : Finset V).Nonempty := ⟨v, Finset.mem_singleton_self v⟩
  have hSc : ({v} : Finset V)ᶜ.Nonempty := by
    obtain ⟨w, hw⟩ := exists_ne v
    exact ⟨w, by simp [hw]⟩
  obtain ⟨y, hy⟩ := exists_far_from_lapLattice G {v} hS hSc
  refine ⟨y, fun f => ?_⟩
  have hcompl : (({v} : Finset V)ᶜ.card : ℝ) = (Fintype.card V : ℝ) - 1 := by
    have := Finset.card_compl ({v} : Finset V)
    have h1 : 1 ≤ Fintype.card V := Fintype.card_pos
    rw [this]
    simp only [Finset.card_singleton]
    push_cast [Nat.cast_sub h1]
    ring
  have := hy f
  rwa [Finset.card_singleton, hcompl, Nat.cast_one, one_mul] at this

end BrillNoetherEnergy