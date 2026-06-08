/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Analysis of the Collatz Map: Core Definitions

This file introduces a spectral-theoretic framework for analyzing the Collatz
conjecture through parity words and their Fourier transforms.

## Key Insight

The Collatz orbit of any n can be encoded as a binary "parity word" recording
whether each iterate is odd (1) or even (0). The orbit contracts when the
density of 1s (odd steps) falls below the critical threshold log(2)/log(3).
The Fourier transform of this parity word measures the regularity of the
odd/even pattern, connecting spectral gaps to orbit dynamics.

## Main Definitions

* `collatzStep` — The standard Collatz map T(n) = n/2 if even, 3n+1 if odd
* `parityBit` — Parity of a single natural number (0 or 1)
* `collatzOrbitParity` — The parity word along a Collatz orbit
* `oddStepCount` — Number of odd steps in first k iterates
* `CollatzContractionExponent` — The quantity k·log(2) - j·log(3) controlling contraction
* `parityDensity` — Fraction of odd steps j/k in an orbit segment
* `spectralSum` — Discrete Fourier-type sum over the parity word
* `spectralEnergy` — Total spectral energy (L² norm of the Fourier transform)

## Novel Structure

* `CollatzOrbitData` — Packages an orbit segment with its combinatorial statistics
-/

import Mathlib

open Finset BigOperators Real

namespace CollatzSpectral

/-! ## §1. The Collatz Step Function -/

/-- The standard Collatz step function. -/
def collatzStep (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

@[simp] theorem collatzStep_zero : collatzStep 0 = 0 := by simp [collatzStep]

theorem collatzStep_even {n : ℕ} (h : n % 2 = 0) : collatzStep n = n / 2 := by
  simp [collatzStep, h]

theorem collatzStep_odd {n : ℕ} (h : n % 2 = 1) : collatzStep n = 3 * n + 1 := by
  simp [collatzStep, h]

/-- The k-th iterate of the Collatz step. -/
def collatzIter (n k : ℕ) : ℕ := (collatzStep^[k]) n

theorem collatzIter_zero (n : ℕ) : collatzIter n 0 = n := rfl

theorem collatzIter_succ (n k : ℕ) :
    collatzIter n (k + 1) = collatzStep (collatzIter n k) := by
  simp [collatzIter, Function.iterate_succ_apply']

/-! ## §2. Parity Tracking -/

/-- Parity bit: 1 if odd, 0 if even. -/
def parityBit (n : ℕ) : ℕ := n % 2

theorem parityBit_le_one (n : ℕ) : parityBit n ≤ 1 := by
  simp [parityBit]; omega

theorem parityBit_zero_or_one (n : ℕ) : parityBit n = 0 ∨ parityBit n = 1 := by
  simp [parityBit]; omega

/-- The parity of the k-th Collatz iterate of n. -/
def collatzOrbitParity (n k : ℕ) : ℕ := parityBit (collatzIter n k)

theorem collatzOrbitParity_le_one (n k : ℕ) : collatzOrbitParity n k ≤ 1 := by
  exact parityBit_le_one _

/-- Number of odd iterates in the first k steps of the orbit of n. -/
def oddStepCount (n : ℕ) : ℕ → ℕ
  | 0 => 0
  | k + 1 => oddStepCount n k + collatzOrbitParity n k

theorem oddStepCount_zero (n : ℕ) : oddStepCount n 0 = 0 := rfl

theorem oddStepCount_succ (n k : ℕ) :
    oddStepCount n (k + 1) = oddStepCount n k + collatzOrbitParity n k := rfl

/-- The count of odd steps never exceeds the total number of steps. -/
theorem oddStepCount_le (n k : ℕ) : oddStepCount n k ≤ k := by
  induction k with
  | zero => simp [oddStepCount]
  | succ k ih =>
    simp only [oddStepCount]
    have := collatzOrbitParity_le_one n k
    omega

/-- Number of even steps = total steps minus odd steps. -/
def evenStepCount (n k : ℕ) : ℕ := k - oddStepCount n k

/-- Partition identity: odd + even = total. -/
theorem step_partition (n k : ℕ) :
    oddStepCount n k + evenStepCount n k = k := by
  simp [evenStepCount]; exact Nat.add_sub_cancel' (oddStepCount_le n k)

/-! ## §3. The Contraction Exponent

The key quantity controlling Collatz orbit behavior is the "contraction exponent"
  δ(n,k) = k · log(2) - j · log(3)
where j = oddStepCount n k. When δ > 0, the orbit has contracted (on average)
by a factor of 2^k / 3^j > 1.

The critical threshold is j/k = log(2)/log(3) ≈ 0.6309.
-/

/-- The contraction exponent δ = k·log(2) - j·log(3).
    Positive δ means the orbit has contracted. -/
noncomputable def contractionExponent (j k : ℕ) : ℝ :=
  (k : ℝ) * Real.log 2 - (j : ℝ) * Real.log 3

/-- The multiplicative contraction factor 2^k / 3^j.
    Values > 1 indicate net contraction. -/
noncomputable def contractionFactor (j k : ℕ) : ℝ :=
  (2 : ℝ) ^ (k : ℤ) / (3 : ℝ) ^ (j : ℤ)

/-! ## §4. Novel Structure: Orbit Data Bundle -/

/-- A `CollatzOrbitData` packages an orbit segment with its combinatorial statistics.
    This is a novel structure capturing the spectral-relevant data of a Collatz orbit. -/
structure CollatzOrbitData where
  /-- Starting value of the orbit -/
  start : ℕ
  /-- Length of the orbit segment -/
  len : ℕ
  /-- Number of odd steps encountered -/
  oddSteps : ℕ
  /-- The orbit segment is consistent with actual Collatz dynamics -/
  consistent : oddSteps = oddStepCount start len
  /-- Odd steps are bounded by total length -/
  bounded : oddSteps ≤ len

/-- Construct orbit data from a starting value and length. -/
noncomputable def mkOrbitData (n k : ℕ) : CollatzOrbitData where
  start := n
  len := k
  oddSteps := oddStepCount n k
  consistent := rfl
  bounded := oddStepCount_le n k

/-- The contraction exponent of an orbit segment. -/
noncomputable def CollatzOrbitData.delta (d : CollatzOrbitData) : ℝ :=
  contractionExponent d.oddSteps d.len

/-- The parity density (fraction of odd steps) of an orbit segment. -/
noncomputable def CollatzOrbitData.parityDensity (d : CollatzOrbitData) : ℝ :=
  if d.len = 0 then 0 else (d.oddSteps : ℝ) / (d.len : ℝ)

/-! ## §5. Spectral Sums

The discrete Fourier transform of the parity word measures how "structured"
the distribution of odd/even steps is along the orbit. A "flat" spectrum
(spectral gap) corresponds to pseudo-random parity patterns.
-/

/-- The spectral sum at frequency ω, summing e^{2πiωk} · parityBit(orbit_k).
    We work with the real part (cosine sum) for formalization convenience. -/
noncomputable def spectralCosSum (n : ℕ) (K : ℕ) (ω : ℝ) : ℝ :=
  ∑ k ∈ range K, (collatzOrbitParity n k : ℝ) * Real.cos (2 * π * ω * (k : ℝ))

/-- The sine component of the spectral sum. -/
noncomputable def spectralSinSum (n : ℕ) (K : ℕ) (ω : ℝ) : ℝ :=
  ∑ k ∈ range K, (collatzOrbitParity n k : ℝ) * Real.sin (2 * π * ω * (k : ℝ))

/-- The spectral energy (squared modulus) at frequency ω. -/
noncomputable def spectralEnergy (n : ℕ) (K : ℕ) (ω : ℝ) : ℝ :=
  spectralCosSum n K ω ^ 2 + spectralSinSum n K ω ^ 2

/-- The DC component (ω = 0) of the spectral sum equals the odd step count. -/
theorem spectralCosSum_zero (n K : ℕ) :
    spectralCosSum n K 0 = (oddStepCount n K : ℝ) := by
  simp only [spectralCosSum, mul_zero]
  induction K with
  | zero => simp [oddStepCount]
  | succ k ih =>
    rw [Finset.sum_range_succ, ih, oddStepCount_succ]
    simp [Real.cos_zero]

end CollatzSpectral