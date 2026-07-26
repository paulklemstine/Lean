/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Wetware Computation: A Bridge from Discrete Dynamics to the Information Cost of Determinism

A **wetware** computation is modelled as a discrete dynamical system: a *step map*
`step : S → S` on a (neural) state space `S`, run by iteration.  This file develops
the model and then proves a *connector* theorem linking two a-priori unrelated areas:

* **Enumerative combinatorics** — counting the configurations of two hardware models
  (deterministic transition maps vs. arbitrary connection matrices), and
* **Information theory / asymptotic analysis** — the Shannon information (energy, in
  bits) needed to specify one configuration, and its asymptotics.

## The model

* `WetwareSystem S` — a dynamical system on `S` given by its `step` map.
* `WetwareSystem.run t x = step^[t] x` — running the system for `t` steps.
* `run_add` — the *flow / semigroup* law `run (s+t) = run s ∘ run t`: a wetware
  system is a monoid action of `(ℕ, +)`, the mathematical core of "iterated computation".

## Computation

* `exists_wetware_computes` — **universality on finite data**: *every* function
  `f : X → Y` between finite types is computed by some wetware system (with an
  encoder and a decoder).  This is the finite-state analogue of Turing-completeness.
* `orbit_eventually_periodic` — the **dynamics ↔ finiteness** bridge: on a finite
  state space every orbit collides with itself, hence is eventually periodic
  (pigeonhole).  A wetware system with finitely many neurons cannot compute
  aperiodic behaviour by pure iteration.

## Energy — the connector theorem

For `n` neurons we compare two hardware disciplines by their number of
*distinguishable configurations* and take the base-2 logarithm (Shannon information):

* **Wetware** = a deterministic transition map `Fin n → Fin n`.
  `wetware_config_card : #(Fin n → Fin n) = n ^ n`, hence
  `wetwareEnergy_eq : wetwareEnergy n = n * logb 2 n`   — `Θ(n log n)` bits.
* **Silicon** = an arbitrary binary connection matrix `Fin n → Fin n → Bool`.
  `silicon_config_card : #(Fin n → Fin n → Bool) = 2 ^ (n ^ 2)`, hence
  `siliconEnergy_eq : siliconEnergy n = n ^ 2`          — `Θ(n²)` bits.

The bridge results:

* `wetware_beats_silicon` — for `n ≥ 1`, `wetwareEnergy n < siliconEnergy n`.
* `energy_ratio_tendsto_zero` — `wetwareEnergy n / siliconEnergy n → 0`:
  the information cost of *determinism* is asymptotically negligible next to the
  cost of arbitrary *connectivity*.

## Application keywords

dynamical systems, discrete dynamics, iteration, neural computation, wetware,
Turing completeness, pigeonhole, eventual periodicity, information theory, Shannon
information, enumerative combinatorics, asymptotics, little-o, geometry of state space
-/
import Mathlib

open Real Filter Topology

namespace Wetware

universe u

/-! ## The wetware dynamical system -/

/-- A **wetware system** on a state space `S`: a discrete dynamical system given by
its one-step transition (`step`) map.  Running the system means iterating `step`. -/
structure WetwareSystem (S : Type*) where
  /-- The one-step neural transition map. -/
  step : S → S

variable {S : Type*}

/-- Running a wetware system for `t` steps from state `x`. -/
def WetwareSystem.run (W : WetwareSystem S) (t : ℕ) (x : S) : S := W.step^[t] x

@[simp] theorem WetwareSystem.run_zero (W : WetwareSystem S) (x : S) : W.run 0 x = x := rfl

@[simp] theorem WetwareSystem.run_one (W : WetwareSystem S) (x : S) : W.run 1 x = W.step x := rfl

theorem WetwareSystem.run_succ (W : WetwareSystem S) (t : ℕ) (x : S) :
    W.run (t + 1) x = W.step (W.run t x) := by
  simp [WetwareSystem.run, Function.iterate_succ_apply']

/-- **Flow / semigroup law.**  A wetware system is a monoid action of `(ℕ, +)`:
running for `s + t` steps equals running for `t` then for `s` steps.  This is the
mathematical heart of "iterated computation". -/
theorem WetwareSystem.run_add (W : WetwareSystem S) (s t : ℕ) (x : S) :
    W.run (s + t) x = W.run s (W.run t x) := by
  simp [WetwareSystem.run, Function.iterate_add_apply]

/-! ## Computation: universality on finite data (finite-state Turing completeness) -/

/-- `W` **computes** `f : X → Y` in `T` steps with encoder `enc` and decoder `dec`
if decoding the state reached after running the encoded input for `T` steps returns
`f x`. -/
def Computes {X Y : Type*} (W : WetwareSystem S) (enc : X → S) (dec : S → Y)
    (T : ℕ) (f : X → Y) : Prop :=
  ∀ x, dec (W.run T (enc x)) = f x

/-- **Finite-state universality (Turing-completeness surrogate).**  Every function
`f : X → Y` between arbitrary types is computed by *some* wetware system, with an
encoder and decoder, in a single dynamical step.  The state space `X ⊕ Y` holds
either a pending input or a produced output, and one `step` performs the transition.
This is the finite-state analogue of neural Turing-completeness. -/
theorem exists_wetware_computes {X Y : Type u} (f : X → Y) :
    ∃ (S' : Type u) (W : WetwareSystem S') (enc : X → S') (dec : S' → Y),
      Computes W enc dec 1 f := by
  refine ⟨X ⊕ Y, ⟨Sum.elim (Sum.inr ∘ f) Sum.inr⟩, Sum.inl,
        Sum.elim f id, ?_⟩
  intro x
  simp [WetwareSystem.run]

/-! ## Dynamics ↔ finiteness: eventual periodicity -/

/-- **Pigeonhole for orbits.**  On a *finite* state space every orbit of a wetware
system revisits a state: there are steps `i < j` with `run i x = run j x`.  Hence the
orbit is eventually periodic and a finite wetware system cannot, by pure iteration,
realise aperiodic dynamics — a hard geometric limit on biological computation. -/
theorem orbit_eventually_periodic [Finite S] (W : WetwareSystem S) (x : S) :
    ∃ i j : ℕ, i < j ∧ W.run i x = W.run j x := by
  obtain ⟨i, j, hij, hEq⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fun k : ℕ => W.run k x)
  rcases lt_or_gt_of_ne hij with h | h
  · exact ⟨i, j, h, hEq⟩
  · exact ⟨j, i, h, hEq.symm⟩

/-! ## Energy: the connector theorem (combinatorics ↔ information/asymptotics) -/

/-- The **wetware energy** on `n` neurons: the Shannon information (bits) needed to
specify one deterministic transition map `Fin n → Fin n`, i.e. the base-2 log of the
number of such maps. -/
noncomputable def wetwareEnergy (n : ℕ) : ℝ :=
  Real.logb 2 (Fintype.card (Fin n → Fin n))

/-- The **silicon energy** on `n` neurons: the Shannon information (bits) needed to
specify one arbitrary binary connection matrix `Fin n → Fin n → Bool`. -/
noncomputable def siliconEnergy (n : ℕ) : ℝ :=
  Real.logb 2 (Fintype.card (Fin n → Fin n → Bool))

/-- Enumerative combinatorics: there are `n ^ n` deterministic transition maps. -/
theorem wetware_config_card (n : ℕ) : Fintype.card (Fin n → Fin n) = n ^ n := by
  simp

/-- Enumerative combinatorics: there are `2 ^ (n²)` binary connection matrices. -/
theorem silicon_config_card (n : ℕ) : Fintype.card (Fin n → Fin n → Bool) = 2 ^ (n ^ 2) := by
  simp [pow_two, pow_mul]

/-- **Wetware energy is `Θ(n log n)`**: exactly `n · log₂ n` bits. -/
theorem wetwareEnergy_eq (n : ℕ) : wetwareEnergy n = n * Real.logb 2 n := by
  rw [wetwareEnergy, wetware_config_card]
  push_cast
  rw [Real.logb_pow]

/-- **Silicon energy is `Θ(n²)`**: exactly `n²` bits. -/
theorem siliconEnergy_eq (n : ℕ) : siliconEnergy n = n ^ 2 := by
  rw [siliconEnergy, silicon_config_card]
  push_cast
  rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  push_cast
  ring

/-- **Connector, strict form.**  For `n ≥ 1` the information cost of a deterministic
wetware transition is strictly less than that of an arbitrary silicon connection
matrix: `n log₂ n < n²`.  Deterministic dynamics is cheaper than arbitrary
connectivity. -/
theorem wetware_beats_silicon {n : ℕ} (hn : 1 ≤ n) : wetwareEnergy n < siliconEnergy n := by
  rw [wetwareEnergy_eq, siliconEnergy_eq]
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have hlog : Real.logb 2 n < n := by
    have hlt : (n : ℝ) < (2 : ℝ) ^ n := by exact_mod_cast Nat.lt_two_pow_self
    calc Real.logb 2 n < Real.logb 2 ((2 : ℝ) ^ n) :=
          Real.logb_lt_logb (by norm_num) hn0 hlt
      _ = n := by rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num)]; ring
  calc (n : ℝ) * Real.logb 2 n < (n : ℝ) * n := mul_lt_mul_of_pos_left hlog hn0
    _ = (n : ℝ) ^ 2 := by ring

/-- Helper: `log₂ x / x → 0` as `x → ∞` over the reals. -/
theorem logb_div_atTop_tendsto_zero :
    Tendsto (fun x : ℝ => Real.logb 2 x / x) atTop (𝓝 0) := by
  -- We can use the change of variables $u = \frac{1}{x}$ to transform the limit expression.
  suffices h_change : Filter.Tendsto (fun u : ℝ => Real.logb 2 (1 / u) * u) (Filter.map (fun x => 1 / x) Filter.atTop) (nhds 0) by
    exact h_change.congr ( by simp +contextual [ div_eq_mul_inv ] );
  norm_num [ Real.logb, mul_comm ];
  exact tendsto_nhdsWithin_of_tendsto_nhds ( by simpa [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ] using Filter.Tendsto.neg ( Real.continuous_mul_log.tendsto 0 |> Filter.Tendsto.mul_const ( Real.log 2 ) ⁻¹ ) )

/-- **Connector, asymptotic form.**  The ratio of wetware to silicon energy tends to
`0`: the information cost of *determinism* (`Θ(n log n)`) is asymptotically negligible
compared with the cost of arbitrary *connectivity* (`Θ(n²)`).  This bridges
enumerative combinatorics (the configuration counts) to asymptotic real analysis. -/
theorem energy_ratio_tendsto_zero :
    Tendsto (fun n : ℕ => wetwareEnergy n / siliconEnergy n) atTop (𝓝 0) := by
  -- The composed limit `logb 2 n / n → 0`, plus that the ratio equals it for `n ≥ 1`.
  have hbase : Tendsto (fun n : ℕ => Real.logb 2 n / (n : ℝ)) atTop (𝓝 0) :=
    logb_div_atTop_tendsto_zero.comp tendsto_natCast_atTop_atTop
  refine hbase.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hn0 : (n : ℝ) ≠ 0 := by exact_mod_cast Nat.one_le_iff_ne_zero.1 hn
  rw [wetwareEnergy_eq, siliconEnergy_eq]
  field_simp

end Wetware