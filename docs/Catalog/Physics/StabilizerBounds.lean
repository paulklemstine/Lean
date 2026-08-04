/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Parameters of quantum stabilizer codes and the Singleton bound

An `[[n, k, d]]` stabilizer code encodes `k` logical qubits into `n` physical
qubits with distance `d`.  This file fixes the parameter bookkeeping used by the
geometric studies in the catalog: the record `CodeParams`, the predicate
`SingletonValidCode` recording the quantum Singleton bound `2d + k ≤ n + 2`
together with the basic sanity constraints `k ≤ n` and `1 ≤ d`, and elementary
consequences of that bound.

The Singleton bound itself is taken as the defining hypothesis of the predicate:
the point of the downstream files is to analyse which *further* conclusions the
inequality does and does not support.
-/

namespace QuantumStabilizer

/-- The parameters `[[n, k, d]]` of a quantum stabilizer code: `n` physical
qubits, `k` logical qubits, distance `d`. -/
structure CodeParams where
  /-- Number of physical qubits. -/
  n : ℕ
  /-- Number of logical qubits. -/
  k : ℕ
  /-- Code distance. -/
  d : ℕ

/-- A parameter triple satisfying the quantum Singleton bound `2d + k ≤ n + 2`,
together with the basic constraints `k ≤ n` and `1 ≤ d`. -/
structure SingletonValidCode (p : CodeParams) : Prop where
  /-- The quantum Singleton bound. -/
  singleton : 2 * p.d + p.k ≤ p.n + 2
  /-- There are no more logical than physical qubits. -/
  hk : p.k ≤ p.n
  /-- The distance is at least one. -/
  hd : 1 ≤ p.d

namespace SingletonValidCode

variable {p : CodeParams}

/-- The Singleton bound in redundancy form: `2(d - 1) ≤ n - k`. -/
theorem redundancy (h : SingletonValidCode p) : 2 * (p.d - 1) ≤ p.n - p.k := by
  have := h.singleton
  have := h.hk
  have := h.hd
  omega

/-- Twice the distance never exceeds `n + 2`. -/
theorem two_mul_d_le (h : SingletonValidCode p) : 2 * p.d ≤ p.n + 2 := by
  have := h.singleton
  omega

/-- The distance of a Singleton-valid code with at least one logical qubit is at
most `(n + 1)/2`. -/
theorem d_le_of_one_le_k (h : SingletonValidCode p) (hk : 1 ≤ p.k) :
    2 * p.d ≤ p.n + 1 := by
  have := h.singleton
  omega

end SingletonValidCode

/-- The `[[5, 1, 3]]` perfect code saturates the quantum Singleton bound. -/
theorem fiveQubitCode_valid :
    SingletonValidCode ⟨5, 1, 3⟩ ∧ 2 * (3 : ℕ) + 1 = 5 + 2 :=
  ⟨⟨by norm_num, by norm_num, by norm_num⟩, by norm_num⟩

/-- The `[[5, 1, 3]]` code is quantum MDS: it saturates the Singleton bound. -/
theorem five_qubit_mds :
    2 * (⟨5, 1, 3⟩ : CodeParams).d + (⟨5, 1, 3⟩ : CodeParams).k
      = (⟨5, 1, 3⟩ : CodeParams).n + 2 := by
  norm_num

/-- The `[[7, 1, 3]]` Steane code satisfies, but does not saturate, the bound. -/
theorem steaneCode_valid : SingletonValidCode ⟨7, 1, 3⟩ :=
  ⟨by norm_num, by norm_num, by norm_num⟩

end QuantumStabilizer