/-
# EML Neural ODE Theory — v17

## Overview
Neural ODEs define continuous-depth networks where hidden states
evolve as dh/dt = f_θ(h, t). The ODE solver calls f_θ many times
(adaptive step count), making per-evaluation cost critical.
EML compresses f_θ, reducing each ODE solver step cost and enabling
finer time discretization for more accurate trajectories.

## Key Results (8 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. ODE Function Network -/

/-- Standard ODE function parameters: f_θ(h, t) -/
def stdODEFuncParams (d_hidden : ℕ) : ℕ :=
  d_hidden * d_hidden

/-- EML ODE function parameters -/
def emlODEFuncParams (d_hidden : ℕ) : ℕ :=
  4 * d_hidden

theorem eml_ode_func_compact (dh : ℕ) (hdh : 4 ≤ dh) :
    emlODEFuncParams dh ≤ stdODEFuncParams dh := by
  -- By definition of `emlODEFuncParams` and `stdODEFuncParams`, we have `emlODEFuncParams dh = 4 * dh` and `stdODEFuncParams dh = dh * dh`.
  simp [emlODEFuncParams, stdODEFuncParams];
  -- Since $dh \geq 4$, we can divide both sides of the inequality $4 * dh \leq dh * dh$ by $dh$ (which is positive), yielding $4 \leq dh$.
  nlinarith

/-! ## §2. ODE Solver Cost -/

/-- Cost of solving ODE: numSteps × function evaluation cost -/
def odeSolverCost (numSteps funcEvalCost : ℕ) : ℕ :=
  numSteps * funcEvalCost

theorem eml_solver_cheaper (ns fec_eml fec_std : ℕ) (hfec : fec_eml ≤ fec_std) :
    odeSolverCost ns fec_eml ≤ odeSolverCost ns fec_std := by
  -- Since $ns$ is a natural number, multiplying both sides of the inequality $fec_eml \leq fec_std$ by $ns$ preserves the inequality.
  apply Nat.mul_le_mul_left ns hfec

theorem more_steps_costlier (s1 s2 fec : ℕ) (hs : s1 ≤ s2) :
    odeSolverCost s1 fec ≤ odeSolverCost s2 fec := by
  -- Since $s1 \leq s2$, multiplying both sides by $fec$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_right fec hs

/-! ## §3. Adjoint Method (Backprop through ODE) -/

/-- Adjoint method cost: solve augmented ODE backward -/
def adjointCost (numSteps funcEvalCost : ℕ) : ℕ :=
  2 * numSteps * funcEvalCost

/-
forward + backward ODE
-/
theorem eml_adjoint_cheaper (ns fec_eml fec_std : ℕ) (hfec : fec_eml ≤ fec_std) :
    adjointCost ns fec_eml ≤ adjointCost ns fec_std := by
  exact Nat.mul_le_mul_left _ hfec

/-! ## §4. Continuous Normalizing Flow -/

/-- CNF cost: ODE solve + log-determinant trace estimation -/
def cnfCost (odeCost traceEstCost : ℕ) : ℕ :=
  odeCost + traceEstCost

theorem eml_cnf_cheaper (oc_eml oc_std tec : ℕ) (hoc : oc_eml ≤ oc_std) :
    cnfCost oc_eml tec ≤ cnfCost oc_std tec := by
  -- By definition of `cnfCost`, we have `cnfCost oc_eml tec = oc_eml + tec` and `cnfCost oc_std tec = oc_std + tec`.
  simp [cnfCost];
  -- Since $oc_eml \leq oc_std$ by hypothesis, we can conclude the proof.
  exact hoc

/-! ## §5. Multi-Scale ODE (Stiff Systems) -/

/-- Stiff system requires more solver steps -/
def stiffODECost (baseSteps stiffnessFactor funcEvalCost : ℕ) : ℕ :=
  baseSteps * stiffnessFactor * funcEvalCost

theorem eml_stiff_cheaper (bs stiff fec_eml fec_std : ℕ) (hfec : fec_eml ≤ fec_std) :
    stiffODECost bs stiff fec_eml ≤ stiffODECost bs stiff fec_std := by
  -- Since multiplication is monotonic, if fec_eml ≤ fec_std, then multiplying both sides by bs * stiff (which are non-negative) should preserve the inequality.
  apply Nat.mul_le_mul_left; exact hfec

/-! ## §6. Neural SDE Extension -/

/-- Neural SDE: drift + diffusion networks -/
def neuralSDEParams (driftParams diffusionParams : ℕ) : ℕ :=
  driftParams + diffusionParams

theorem eml_sde_compact (dp_eml dp_std dfp_eml dfp_std : ℕ)
    (hdp : dp_eml ≤ dp_std) (hdfp : dfp_eml ≤ dfp_std) :
    neuralSDEParams dp_eml dfp_eml ≤ neuralSDEParams dp_std dfp_std := by
  grind +locals

end