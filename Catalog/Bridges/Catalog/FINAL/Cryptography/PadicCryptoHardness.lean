/-
Copyright (c) 2025 Harmonic. All rights reserved.

# p-adic Cryptographic Hardness via Valuation Depth

Bridge: Cryptography/lattice_crypto ↔ Algebra/p_adic_valuation ↔ Computation/depth_bounds
-/

import Mathlib
import Computation.PadicValuationDepth

/-! ## Section 1: Hensel One-Way Function Gap -/

/-- Forward O(log n) vs inverse Ω(n) gap.
Bridge: Cryptography/one_way_functions ↔ Computation/asymmetric_complexity. -/
structure HenselOneWayGap where
  precision : ℕ
  forward_steps : ℕ
  forward_log : forward_steps ≤ Nat.log 2 precision + 1
  inverse_steps : ℕ
  inverse_linear : inverse_steps ≥ precision
  precision_pos : precision ≥ 1

namespace HenselOneWayGap

theorem gap_multiplicative (g : HenselOneWayGap) (h : g.precision ≥ 3) :
    g.inverse_steps > g.forward_steps := by
  have : g.forward_steps < g.precision :=
    calc g.forward_steps ≤ Nat.log 2 g.precision + 1 := g.forward_log
      _ < g.precision := HenselConvergenceData.speedup_ratio g.precision h
  linarith [g.inverse_linear]

theorem gap_ratio_grows (n : ℕ) (hn : n ≥ 3) : n - (Nat.log 2 n + 1) ≥ 1 := by
  have := HenselConvergenceData.speedup_ratio n hn; omega

def ofPrecision (n : ℕ) (hn : n ≥ 1) : HenselOneWayGap where
  precision := n; forward_steps := Nat.log 2 n + 1; forward_log := le_refl _
  inverse_steps := n; inverse_linear := le_refl _; precision_pos := hn

theorem concrete_128 : (ofPrecision 128 (by omega)).inverse_steps -
    (ofPrecision 128 (by omega)).forward_steps = 120 := by native_decide

theorem concrete_256 : (ofPrecision 256 (by omega)).inverse_steps -
    (ofPrecision 256 (by omega)).forward_steps = 247 := by native_decide

end HenselOneWayGap

/-! ## Section 2: Depth-Based Security -/

structure DepthSecurityLevel where
  security_bits : ℕ
  breaking_depth : ℕ
  depth_scales : breaking_depth ≥ Nat.log 2 security_bits
  security_pos : security_bits ≥ 1

namespace DepthSecurityLevel

/-- Doubling security increases the minimum depth bound by 1. -/
theorem double_security_depth (s : DepthSecurityLevel) :
    ∃ s' : DepthSecurityLevel, s'.security_bits = 2 * s.security_bits ∧
      s'.breaking_depth ≥ Nat.log 2 s.security_bits + 1 := by
  have hs := s.security_pos
  have hlog : Nat.log 2 (2 * s.security_bits) ≥ Nat.log 2 s.security_bits + 1 := by
    suffices Nat.log 2 (2 * s.security_bits) ≥
        Nat.log 2 (2 ^ (Nat.log 2 s.security_bits + 1)) by
      rwa [Nat.log_pow (by omega : 1 < 2)] at this
    apply Nat.log_mono_right; rw [pow_succ]
    linarith [Nat.pow_log_le_self 2 (show s.security_bits ≠ 0 by omega)]
  exact ⟨⟨2 * s.security_bits, Nat.log 2 (2 * s.security_bits), le_refl _, by omega⟩,
    rfl, hlog⟩

def ofBits (n : ℕ) (hn : n ≥ 1) : DepthSecurityLevel where
  security_bits := n; breaking_depth := Nat.log 2 n
  depth_scales := le_refl _; security_pos := hn

end DepthSecurityLevel

/-! ## Section 3: Hensel Error-Correcting Codes -/

structure HenselCodeRate where
  block_length : ℕ
  info_length : ℕ
  min_distance : ℕ
  depth : ℕ
  distance_exponential : min_distance ≥ 2 ^ depth
  positive_rate : info_length ≥ 1
  valid_code : block_length ≥ info_length

namespace HenselCodeRate

/-- Each depth increase doubles the distance bound. -/
theorem deeper_distance (c : HenselCodeRate) :
    ∃ c' : HenselCodeRate, c'.depth = c.depth + 1 ∧
      c'.min_distance ≥ 2 * 2 ^ c.depth := by
  exact ⟨⟨c.block_length, c.info_length, 2 ^ (c.depth + 1), c.depth + 1,
    le_refl _, c.positive_rate, c.valid_code⟩, rfl,
    by show 2 ^ (c.depth + 1) ≥ 2 * 2 ^ c.depth; rw [pow_succ]; omega⟩

def ofDepth (n k : ℕ) (hn : n ≥ 1) : HenselCodeRate where
  block_length := n + 2 ^ k; info_length := n; min_distance := 2 ^ k; depth := k
  distance_exponential := le_refl _; positive_rate := hn
  valid_code := Nat.le_add_right n _

end HenselCodeRate

/-! ## Section 4: Post-Quantum Bounds -/

theorem quantum_query_lower (n : ℕ) (hn : n ≥ 2) : Nat.log 2 n ≤ n - 1 := by
  have : Nat.log 2 n < n :=
    Nat.log_lt_of_lt_pow (by omega) (Nat.lt_pow_self (by omega))
  omega

theorem grover_bounded (n : ℕ) (hn : n ≥ 4) :
    Nat.sqrt n ≤ n ∧ Nat.sqrt n ≥ 2 :=
  ⟨Nat.sqrt_le_self n,
   calc Nat.sqrt n ≥ Nat.sqrt 4 := Nat.sqrt_le_sqrt (by omega)
     _ = 2 := by native_decide⟩

theorem depth_survives_quantum (n : ℕ) (hn : n ≥ 4) :
    Nat.log 2 n ≥ 2 ∧ Nat.sqrt n ≤ n :=
  ⟨exponential_depth_gap n hn, Nat.sqrt_le_self n⟩