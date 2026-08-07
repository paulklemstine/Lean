/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors
import Pythagorean.BrillNoether.EnergyCovering
import Pythagorean.BrillNoether.CoveringBridge

/-!
# An unconditional upper bound for the covering radius in the energy metric

`CoveringBridge.lean` shows that an *energy* covering radius `ε` for the Laplacian
lattice yields an `ℓ^∞` covering bound `√(d ε)` and hence Brill–Noether existence,
but leaves the existence of such an `ε` as a hypothesis.  Here it is proved
unconditionally for every connected graph:

`ε ≤ 2 Δ³ n`,  where `Δ` bounds the degrees and `n = #V`.

The argument is the geometry-of-numbers "round the coordinates" argument.

* On a connected graph the Laplacian maps `ℝ^V` *onto* the hyperplane of mean-zero
  vectors (`exists_mulVec_eq`): its kernel is one dimensional, by Mathlib's
  identification of the kernel with the space of functions constant on connected
  components, so its range has dimension `n - 1` and is contained in — hence equal
  to — the mean-zero hyperplane.
* Given a degree-zero divisor `A`, write `A = L x` with `x` real and round `x`
  coordinatewise to `f : V → ℤ`, so that `z = x - f` has `‖z‖_∞ ≤ 1/2` and
  `A - L f = L z`.
* Two elementary estimates, `energy_le_two_mul_maxDegree` (`E(w) ≤ 2Δ‖w‖²`) and
  `sum_sq_mulVec_le` (`‖L z‖² ≤ 2Δ E(z)`), give
  `E(L z) ≤ 2Δ‖L z‖² ≤ 4Δ² E(z) ≤ 8Δ³‖z‖² ≤ 2Δ³ n`.

Combining with `CoveringBridge.lean` yields an unconditional `ℓ^∞` covering bound
and a Brill–Noether existence statement in terms of the maximum degree and the
diameter (`isCoveringBound_of_maxDegree`, `rankAtLeast_of_maxDegree`).
-/

open Finset Matrix BrillNoetherDivisor BrillNoetherEnergy BrillNoetherCoveringBridge

namespace BrillNoetherEnergyRadius

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Two elementary energy estimates -/

omit [DecidableEq V] in
/-- Summing a function of the endpoint over all edges counts each vertex with
multiplicity its degree. -/
lemma sum_sum_neighbor (w : V → ℝ) :
    ∑ i, ∑ j ∈ G.neighborFinset i, w j = ∑ j, (G.degree j : ℝ) * w j := by
  classical
  have h1 : ∀ i : V, ∑ j ∈ G.neighborFinset i, w j = ∑ j, if G.Adj i j then w j else 0 := by
    intro i
    rw [← Finset.sum_filter]
    congr 1
    ext j
    simp [SimpleGraph.mem_neighborFinset]
  rw [Finset.sum_congr rfl fun i _ => h1 i, Finset.sum_comm]
  refine Finset.sum_congr rfl fun j _ => ?_
  have hfil : (univ.filter fun i => G.Adj i j) = G.neighborFinset j := by
    ext i
    simp [SimpleGraph.mem_neighborFinset, G.adj_comm]
  rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, Finset.sum_const, hfil,
    G.card_neighborFinset_eq_degree, nsmul_eq_mul]

omit [DecidableEq V] in
/-- Twice the energy is the full double sum of squared increments. -/
lemma two_mul_energy (x : V → ℝ) :
    2 * energy G x = ∑ i, ∑ j ∈ G.neighborFinset i, (x i - x j) ^ 2 := by
  classical
  rw [energy]
  have h1 : ∀ i : V, (∑ j, if G.Adj i j then (x i - x j) ^ 2 else 0)
      = ∑ j ∈ G.neighborFinset i, (x i - x j) ^ 2 := by
    intro i
    rw [← Finset.sum_filter]
    congr 1
    ext j
    simp [SimpleGraph.mem_neighborFinset]
  rw [Finset.sum_congr rfl fun i _ => h1 i]
  ring

omit [DecidableEq V] in
/-- **The energy form is bounded by the maximum degree**: `E(x) ≤ 2Δ ∑ x_v²`. -/
theorem energy_le_two_mul_maxDegree {Δ : ℕ} (hΔ : ∀ v, G.degree v ≤ Δ) (x : V → ℝ) :
    energy G x ≤ 2 * (Δ : ℝ) * ∑ v, (x v) ^ 2 := by
  classical
  have hbound : ∑ i, ∑ j ∈ G.neighborFinset i, (x i - x j) ^ 2
      ≤ ∑ i, ∑ j ∈ G.neighborFinset i, (2 * (x i) ^ 2 + 2 * (x j) ^ 2) := by
    refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
    nlinarith [sq_nonneg (x i + x j)]
  have hsplit : ∑ i, ∑ j ∈ G.neighborFinset i, (2 * (x i) ^ 2 + 2 * (x j) ^ 2)
      = 4 * ∑ v, (G.degree v : ℝ) * (x v) ^ 2 := by
    have h1 : ∀ i : V, ∑ j ∈ G.neighborFinset i, (2 * (x i) ^ 2 + 2 * (x j) ^ 2)
        = 2 * (G.degree i : ℝ) * (x i) ^ 2 + 2 * ∑ j ∈ G.neighborFinset i, (x j) ^ 2 := by
      intro i
      rw [Finset.sum_add_distrib, Finset.sum_const, ← Finset.mul_sum,
        G.card_neighborFinset_eq_degree, nsmul_eq_mul]
      ring
    rw [Finset.sum_congr rfl fun i _ => h1 i, Finset.sum_add_distrib, ← Finset.mul_sum,
      sum_sum_neighbor G (fun v => (x v) ^ 2)]
    have : ∑ i, 2 * (G.degree i : ℝ) * (x i) ^ 2 = 2 * ∑ i, (G.degree i : ℝ) * (x i) ^ 2 := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun i _ => by ring
    rw [this]
    ring
  have hdeg : ∑ v, (G.degree v : ℝ) * (x v) ^ 2 ≤ (Δ : ℝ) * ∑ v, (x v) ^ 2 := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun v _ => ?_
    have : (G.degree v : ℝ) ≤ (Δ : ℝ) := by exact_mod_cast hΔ v
    nlinarith [sq_nonneg (x v)]
  have h2 := two_mul_energy G x
  linarith

/-- The Laplacian written as a sum of increments over the neighbourhood. -/
lemma mulVec_eq_sum_sub (z : V → ℝ) (v : V) :
    (G.lapMatrix ℝ *ᵥ z) v = ∑ u ∈ G.neighborFinset v, (z v - z u) := by
  rw [G.lapMatrix_mulVec_apply, Finset.sum_sub_distrib, Finset.sum_const,
    G.card_neighborFinset_eq_degree, nsmul_eq_mul]

/-- **The Laplacian is bounded by the maximum degree**: `‖L z‖² ≤ 2Δ E(z)`. -/
theorem sum_sq_mulVec_le {Δ : ℕ} (hΔ : ∀ v, G.degree v ≤ Δ) (z : V → ℝ) :
    ∑ v, ((G.lapMatrix ℝ *ᵥ z) v) ^ 2 ≤ 2 * (Δ : ℝ) * energy G z := by
  classical
  have hterm : ∀ v : V, ((G.lapMatrix ℝ *ᵥ z) v) ^ 2
      ≤ (Δ : ℝ) * ∑ u ∈ G.neighborFinset v, (z v - z u) ^ 2 := by
    intro v
    have hcs : (∑ u ∈ G.neighborFinset v, (z v - z u)) ^ 2
        ≤ (#(G.neighborFinset v) : ℝ) * ∑ u ∈ G.neighborFinset v, (z v - z u) ^ 2 :=
      sq_sum_le_card_mul_sum_sq
    have hd : (#(G.neighborFinset v) : ℝ) ≤ (Δ : ℝ) := by
      rw [G.card_neighborFinset_eq_degree]
      exact_mod_cast hΔ v
    have hnn : 0 ≤ ∑ u ∈ G.neighborFinset v, (z v - z u) ^ 2 :=
      Finset.sum_nonneg fun u _ => sq_nonneg _
    rw [mulVec_eq_sum_sub]
    exact le_trans hcs (mul_le_mul_of_nonneg_right hd hnn)
  calc ∑ v, ((G.lapMatrix ℝ *ᵥ z) v) ^ 2
      ≤ ∑ v, (Δ : ℝ) * ∑ u ∈ G.neighborFinset v, (z v - z u) ^ 2 :=
        Finset.sum_le_sum fun v _ => hterm v
    _ = (Δ : ℝ) * ∑ v, ∑ u ∈ G.neighborFinset v, (z v - z u) ^ 2 := by rw [Finset.mul_sum]
    _ = (Δ : ℝ) * (2 * energy G z) := by rw [two_mul_energy]
    _ = 2 * (Δ : ℝ) * energy G z := by ring

/-! ## Surjectivity of the Laplacian onto the mean-zero hyperplane -/

/-- The linear functional `x ↦ ∑ v, x v`. -/
def sumLin : (V → ℝ) →ₗ[ℝ] ℝ where
  toFun x := ∑ v, x v
  map_add' x y := by simp [Finset.sum_add_distrib]
  map_smul' c x := by simp [Finset.mul_sum]

omit [DecidableEq V] in
lemma sumLin_apply (x : V → ℝ) : sumLin x = ∑ v, x v := rfl

lemma sum_mulVec_lapMatrix (x : V → ℝ) : ∑ v, (G.lapMatrix ℝ *ᵥ x) v = 0 := by
  have h1 : ∑ v, (G.lapMatrix ℝ *ᵥ x) v = (fun _ : V => (1 : ℝ)) ⬝ᵥ (G.lapMatrix ℝ *ᵥ x) := by
    simp [dotProduct]
  rw [h1, dotProduct_mulVec]
  have h2 : vecMul (fun _ : V => (1 : ℝ)) (G.lapMatrix ℝ) = 0 := by
    rw [← mulVec_transpose, show (G.lapMatrix ℝ)ᵀ = G.lapMatrix ℝ from G.isSymm_lapMatrix]
    exact G.lapMatrix_mulVec_const_eq_zero
  rw [h2]
  simp

/-- **The Laplacian of a connected graph is onto the mean-zero hyperplane.** -/
theorem exists_mulVec_eq (hG : G.Connected) {y : V → ℝ} (hy : ∑ v, y v = 0) :
    ∃ x : V → ℝ, G.lapMatrix ℝ *ᵥ x = y := by
  classical
  haveI : Nonempty V := hG.nonempty
  set L : (V → ℝ) →ₗ[ℝ] (V → ℝ) := Matrix.toLin' (G.lapMatrix ℝ) with hL
  have hdim : Module.finrank ℝ (V → ℝ) = Fintype.card V := Module.finrank_fintype_fun_eq_card ℝ
  -- the kernel of the Laplacian is one dimensional
  have hcc : Fintype.card G.ConnectedComponent = 1 := by
    refine Fintype.card_eq_one_iff.mpr ⟨G.connectedComponentMk (Classical.arbitrary V), ?_⟩
    intro c
    induction c using SimpleGraph.ConnectedComponent.ind with
    | _ u => exact SimpleGraph.ConnectedComponent.sound (hG.preconnected u _)
  have hker : Module.finrank ℝ (LinearMap.ker L) = 1 := by
    rw [hL, ← SimpleGraph.card_connectedComponent_eq_finrank_ker_toLin'_lapMatrix, hcc]
  -- hence the range has dimension `n - 1`
  have hrn : Module.finrank ℝ (LinearMap.range L) + Module.finrank ℝ (LinearMap.ker L)
      = Fintype.card V := by
    rw [LinearMap.finrank_range_add_finrank_ker L, hdim]
  -- the mean-zero hyperplane also has dimension `n - 1`
  have hsurj : Function.Surjective (sumLin : (V → ℝ) →ₗ[ℝ] ℝ) := by
    intro c
    refine ⟨Pi.single (Classical.arbitrary V) c, ?_⟩
    simp [sumLin_apply]
  have hrnW : Module.finrank ℝ (LinearMap.range (sumLin : (V → ℝ) →ₗ[ℝ] ℝ))
      + Module.finrank ℝ (LinearMap.ker (sumLin : (V → ℝ) →ₗ[ℝ] ℝ)) = Fintype.card V := by
    rw [LinearMap.finrank_range_add_finrank_ker, hdim]
  have hrangeW : Module.finrank ℝ (LinearMap.range (sumLin : (V → ℝ) →ₗ[ℝ] ℝ)) = 1 := by
    rw [LinearMap.range_eq_top.mpr hsurj]
    simp
  -- the range of the Laplacian is contained in the mean-zero hyperplane
  have hle : LinearMap.range L ≤ LinearMap.ker (sumLin : (V → ℝ) →ₗ[ℝ] ℝ) := by
    rintro w ⟨x, rfl⟩
    exact sum_mulVec_lapMatrix G x
  have heq : LinearMap.range L = LinearMap.ker (sumLin : (V → ℝ) →ₗ[ℝ] ℝ) :=
    Submodule.eq_of_le_of_finrank_eq hle (by omega)
  have hyW : y ∈ LinearMap.ker (sumLin : (V → ℝ) →ₗ[ℝ] ℝ) := hy
  rw [← heq] at hyW
  obtain ⟨x, hx⟩ := hyW
  exact ⟨x, hx⟩

/-! ## The energy covering radius -/

/-- **An unconditional energy covering radius for the Laplacian lattice.**  On a
connected graph with all degrees at most `Δ`, every degree-zero divisor lies within
energy distance `2Δ³n` of the Laplacian lattice. -/
theorem exists_energy_close (hG : G.Connected) {Δ : ℕ} (hΔ : ∀ v, G.degree v ≤ Δ)
    (A : Divisor V) (hA : deg A = 0) :
    ∃ f : V → ℤ, energy G (toReal (A - lap G f)) ≤ 2 * (Δ : ℝ) ^ 3 * (Fintype.card V : ℝ) := by
  classical
  have hAsum : ∑ v, ((A v : ℝ)) = 0 := by
    have : ((∑ v, A v : ℤ) : ℝ) = 0 := by rw [← deg, hA]; simp
    simpa using this
  obtain ⟨x, hx⟩ := exists_mulVec_eq G hG (y := fun v => (A v : ℝ)) hAsum
  refine ⟨fun v => round (x v), ?_⟩
  set f : V → ℤ := fun v => round (x v) with hf
  set z : V → ℝ := fun v => x v - (f v : ℝ) with hz
  -- the divisor `A - L f` is the Laplacian image of `z`
  have hval : toReal (A - lap G f) = G.lapMatrix ℝ *ᵥ z := by
    funext v
    have hlapf : (G.lapMatrix ℝ *ᵥ fun u => ((f u : ℤ) : ℝ)) v = ((lap G f v : ℤ) : ℝ) := by
      rw [G.lapMatrix_mulVec_apply, lap, G.lapMatrix_mulVec_apply]
      push_cast
      ring
    have hsub : G.lapMatrix ℝ *ᵥ z = (G.lapMatrix ℝ *ᵥ x) - (G.lapMatrix ℝ *ᵥ fun u => (f u : ℝ)) :=
      Matrix.mulVec_sub _ _ _
    rw [hsub]
    simp only [Pi.sub_apply, hx, hlapf, toReal, Pi.sub_apply]
    push_cast
    ring
  rw [hval]
  -- the rounding error is at most `1/2` in each coordinate
  have hzbound : ∀ v, (z v) ^ 2 ≤ 1 / 4 := by
    intro v
    have h1 : |z v| ≤ 1 / 2 := by
      have := abs_sub_round (x v)
      simpa [hz, hf] using this
    nlinarith [abs_nonneg (z v), sq_abs (z v)]
  have hzsum : ∑ v, (z v) ^ 2 ≤ (Fintype.card V : ℝ) / 4 := by
    calc ∑ v, (z v) ^ 2 ≤ ∑ _v : V, (1 / 4 : ℝ) := Finset.sum_le_sum fun v _ => hzbound v
      _ = (Fintype.card V : ℝ) / 4 := by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
          ring
  -- chain the two estimates
  have hΔ0 : (0 : ℝ) ≤ (Δ : ℝ) := Nat.cast_nonneg Δ
  have h1 : energy G (G.lapMatrix ℝ *ᵥ z) ≤ 2 * (Δ : ℝ) * ∑ v, ((G.lapMatrix ℝ *ᵥ z) v) ^ 2 :=
    energy_le_two_mul_maxDegree G hΔ _
  have h2 : ∑ v, ((G.lapMatrix ℝ *ᵥ z) v) ^ 2 ≤ 2 * (Δ : ℝ) * energy G z :=
    sum_sq_mulVec_le G hΔ z
  have h3 : energy G z ≤ 2 * (Δ : ℝ) * ∑ v, (z v) ^ 2 := energy_le_two_mul_maxDegree G hΔ z
  have h4 : energy G z ≤ 2 * (Δ : ℝ) * ((Fintype.card V : ℝ) / 4) :=
    le_trans h3 (mul_le_mul_of_nonneg_left hzsum (by linarith))
  have h5 : ∑ v, ((G.lapMatrix ℝ *ᵥ z) v) ^ 2 ≤ 2 * (Δ : ℝ) * (2 * (Δ : ℝ) *
      ((Fintype.card V : ℝ) / 4)) :=
    le_trans h2 (mul_le_mul_of_nonneg_left h4 (by linarith))
  calc energy G (G.lapMatrix ℝ *ᵥ z)
      ≤ 2 * (Δ : ℝ) * ∑ v, ((G.lapMatrix ℝ *ᵥ z) v) ^ 2 := h1
    _ ≤ 2 * (Δ : ℝ) * (2 * (Δ : ℝ) * (2 * (Δ : ℝ) * ((Fintype.card V : ℝ) / 4))) :=
        mul_le_mul_of_nonneg_left h5 (by linarith)
    _ = 2 * (Δ : ℝ) ^ 3 * (Fintype.card V : ℝ) := by ring

/-- **An unconditional `ℓ^∞` covering bound from the maximum degree and the
diameter.**  If all degrees of the connected graph `G` are at most `Δ` and all
distances are at most `d`, then the Laplacian lattice has `ℓ^∞`-covering radius at
most any integer `ρ ≥ √(2 d Δ³ n)`. -/
theorem isCoveringBound_of_maxDegree (hG : G.Connected) {Δ d : ℕ} (hΔ : ∀ v, G.degree v ≤ Δ)
    (hd : ∀ a b : V, G.dist a b ≤ d) {rho : ℕ}
    (hrho : Real.sqrt ((d : ℝ) * (2 * (Δ : ℝ) ^ 3 * (Fintype.card V : ℝ))) ≤ (rho : ℝ)) :
    IsCoveringBound G rho := by
  haveI : Nonempty V := hG.nonempty
  refine isCoveringBound_of_energy_covering G hG hd (fun A hA => ?_) hrho
  exact exists_energy_close G hG hΔ A hA

/-- **Brill–Noether existence from the maximum degree and the diameter.**  Under the
hypotheses of `isCoveringBound_of_maxDegree`, every divisor of degree at least
`n(ρ + r)` has Baker–Norine rank at least `r`. -/
theorem rankAtLeast_of_maxDegree (hG : G.Connected) {Δ d : ℕ} (hΔ : ∀ v, G.degree v ≤ Δ)
    (hd : ∀ a b : V, G.dist a b ≤ d) {rho r : ℕ}
    (hrho : Real.sqrt ((d : ℝ) * (2 * (Δ : ℝ) ^ 3 * (Fintype.card V : ℝ))) ≤ (rho : ℝ))
    (D : Divisor V) (h : (Fintype.card V : ℤ) * ((rho : ℤ) + (r : ℤ)) ≤ deg D) :
    RankAtLeast G D r := by
  haveI : Nonempty V := hG.nonempty
  exact rankAtLeast_of_covering G (isCoveringBound_of_maxDegree G hG hΔ hd hrho) D h

end BrillNoetherEnergyRadius