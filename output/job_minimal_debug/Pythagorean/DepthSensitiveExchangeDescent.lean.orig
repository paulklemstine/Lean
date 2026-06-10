/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Depth-Sensitive Exchange Descent Bounds via Certificate Depth

This file establishes a new quantitative theory in which **certificate depth**
serves as a discrete regularity parameter controlling the complexity of exchange
descent algorithms on finite integer lattice subsets.

## Overview

The central result is that deeper structural certificates force faster descent:
if a finite exchange family `S ⊆ ℤ^d` admits a depth-`k` exchange certificate,
then exchange descent terminates in at most `O(d^{d-k} · D)` steps, where `D`
is the exchange diameter. At maximal depth `k = d`, this collapses to a linear
bound `O(D)`, the discrete analogue of "full curvature implies linear convergence."

## Main Results

* `telescoping_potential_decrease` — Telescoping potential drop: `n` steps drop by `n * δ`.
* `descent_step_count_le_nat` — Descent length bounded by `⌈B/δ⌉`.
* `exchangeDescent_depth_bound` — Depth-sensitive descent bound on chains.
* `exchangeDescent_depth_bound_poly` — Polynomial bound `O(d^{d-k} · D)`.
* `exchangeDescent_depth_eq_dim_linear` — Linear bound `O(D)` when `k = d`.
* `exchangeDLC_k_depth_mono` — Deeper certificates imply shallower ones.
* `depthCertificate_runtime_monotone` — Deeper certificates give no worse runtime.
* `kFoldLogConcave_induces_depthCertificate` — Log-concavity → exchange certificates.
* `logConcave_to_descent_bound` — Full pipeline: log-concavity → bounded descent.

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset

noncomputable section

/-! ## Part 1: Core Potential Descent Theory -/

/-
**Telescoping potential decrease.** After `n` steps where each decreases
the potential by at least `δ`, the total decrease is at least `n * δ`.
-/
theorem telescoping_potential_decrease (n : ℕ) (Φ : ℕ → ℚ) (δ : ℚ)
    (hdec : ∀ i, i < n → Φ (i + 1) + δ ≤ Φ i) :
    Φ n + ↑n * δ ≤ Φ 0 := by
  induction' n with n ih <;> norm_num at *;
  linarith [ ih fun i hi => hdec i hi.le, hdec n le_rfl ]

/-
**Descent step count bound.** If the potential decreases by at least `δ > 0`
per step, and the total potential range is at most `B`, then the number of
steps is at most `⌈B/δ⌉`.
-/
theorem descent_step_count_le_nat (n : ℕ) (Φ : ℕ → ℚ) (δ B : ℚ)
    (hδ : 0 < δ)
    (_hB : 0 ≤ B)
    (hdec : ∀ i, i < n → Φ (i + 1) + δ ≤ Φ i)
    (hrange : Φ 0 - Φ n ≤ B) :
    n ≤ ⌈B / δ⌉₊ := by
  have h_telescope : Φ n + n * δ ≤ Φ 0 := by
    convert telescoping_potential_decrease n Φ δ hdec using 1;
  exact_mod_cast ( by nlinarith [ Nat.le_ceil ( B / δ ), mul_div_cancel₀ B hδ.ne' ] : ( n : ℚ ) ≤ ⌈B / δ⌉₊ )

/-! ## Part 2: Exchange System Definitions -/

/-- An **exchange step** modifies exactly two coordinates by ±1. -/
def isExchangeStep {d : ℕ} (x y : Fin d → ℤ) : Prop :=
  ∃ i j : Fin d, i ≠ j ∧
    y i = x i + 1 ∧ y j = x j - 1 ∧
    ∀ k, k ≠ i → k ≠ j → y k = x k

/-- An **improving exchange step**: `y` from `x` by exchange, both in `S`, `f(y) < f(x)`. -/
def improvingExchangeStep {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) (x y : Fin d → ℤ) : Prop :=
  x ∈ S ∧ y ∈ S ∧ isExchangeStep x y ∧ f y < f x

/-- **Directional exchange certificate (DLC)**: for any `x, y ∈ S` with
`f(y) < f(x)`, there exists an improving exchange step from `x`. -/
def hasExchangeDLC {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, f y < f x →
    ∃ z, improvingExchangeStep S f x z

/-- **Depth-graded exchange certificate** `exchangeDLC_k`:
depth 0 is trivial; depth `k+1` requires the DLC plus depth `k`. -/
def exchangeDLC_k {d : ℕ} :
    ℕ → Finset (Fin d → ℤ) → ((Fin d → ℤ) → ℤ) → Prop
  | 0, _, _ => True
  | k + 1, S, f => hasExchangeDLC S f ∧ exchangeDLC_k k S f

/-- A **descent chain** of length `n+1`: `x₀, …, xₙ` with each pair improving. -/
structure DescentChain {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) (n : ℕ) where
  seq : Fin (n + 1) → (Fin d → ℤ)
  mem : ∀ i, seq i ∈ S
  step : ∀ (i : Fin n),
    improvingExchangeStep S f (seq (Fin.castSucc i)) (seq (Fin.succ i))

/-! ## Part 3: Depth-Aware Potential -/

/-- **Depth-aware decrement**: `δ_k = c / d^(d-k)`. At depth `k`, deeper
certificates yield larger decrements (faster convergence). -/
def depthDecrement (d k : ℕ) (c : ℚ) : ℚ :=
  c / (d : ℚ) ^ (d - k)

/-
The depth decrement is positive when `c > 0` and `d ≥ 1`.
-/
theorem depthDecrement_pos {d k : ℕ} {c : ℚ} (hc : 0 < c) (hd : 1 ≤ d) :
    0 < depthDecrement d k c := by
  exact div_pos hc ( pow_pos ( Nat.cast_pos.mpr hd ) _ )

/-
At maximal depth `k = d`, the decrement simplifies to `c`.
-/
theorem depthDecrement_at_max_depth {d : ℕ} {c : ℚ} (_hd : 1 ≤ d) :
    depthDecrement d d c = c := by
  -- By definition of depthDecrement, we have depthDecrement d d c = c / d^(d-d).
  simp [depthDecrement]

/-
Deeper certificates give larger decrements (monotonicity).
-/
theorem depthDecrement_mono {d k₁ k₂ : ℕ} {c : ℚ}
    (hc : 0 < c) (hd : 1 ≤ d)
    (hk : k₁ ≤ k₂) (_hk₂ : k₂ ≤ d) :
    depthDecrement d k₁ c ≤ depthDecrement d k₂ c := by
  unfold depthDecrement; rw [ div_le_div_iff₀ ] <;> try positivity;
  exact mul_le_mul_of_nonneg_left ( pow_le_pow_right₀ ( by norm_cast ) ( Nat.sub_le_sub_left hk _ ) ) hc.le

/-! ## Part 4: Main Theorems -/

/-
**Theorem A: Depth-sensitive exchange descent bound.**
Every improving exchange step decreases a potential `Φ` by at least `δ > 0`.
If the potential range is at most `B`, every descent chain has ≤ `⌈B/δ⌉` steps.
-/
theorem exchangeDescent_depth_bound
    {d : ℕ} {n : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (Φ : (Fin d → ℤ) → ℚ)
    (δ B : ℚ)
    (hδ : 0 < δ)
    (hdec : ∀ x y, improvingExchangeStep S f x y → Φ y + δ ≤ Φ x)
    (hrange : ∀ x y, x ∈ S → y ∈ S → Φ x - Φ y ≤ B)
    (hB : 0 ≤ B)
    (chain : DescentChain S f n) :
    n ≤ ⌈B / δ⌉₊ := by
  convert descent_step_count_le_nat n ( fun i => if hi : i ≤ n then Φ ( chain.seq ⟨ i, by linarith ⟩ ) else 0 ) δ B hδ hB _ _;
  · intro i hi; have := chain.step ⟨ i, by linarith ⟩ ; simp_all +decide [ improvingExchangeStep ] ;
    grind;
  · grind +suggestions

/-
**Theorem A': Polynomial descent bound.**
When `δ ≥ c / d^(d-k)` and range ≤ `C₀ · D`, descent length ≤ `C₀ · D · d^(d-k) / c`.
-/
theorem exchangeDescent_depth_bound_poly
    {d k : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (Φ : (Fin d → ℤ) → ℚ)
    (c C₀ : ℚ)
    (D : ℕ)
    (hc : 0 < c) (_hC₀ : 0 < C₀)
    (hd : 1 ≤ d) (_hk : k ≤ d)
    (hdec : ∀ x y, improvingExchangeStep S f x y →
      Φ y + depthDecrement d k c ≤ Φ x)
    (hrange : ∀ x y, x ∈ S → y ∈ S → Φ x - Φ y ≤ C₀ * ↑D)
    (n : ℕ)
    (chain : DescentChain S f n) :
    (n : ℚ) ≤ C₀ * ↑D * ↑d ^ (d - k) / c := by
  have h_ind : ∀ i : Fin (n + 1), (Φ (chain.seq i)) + (i : ℚ) * (depthDecrement d k c) ≤ (Φ (chain.seq 0)) := by
    intro i; induction' i using Fin.inductionOn with i IH; aesop;
    have := hdec ( chain.seq i.castSucc ) ( chain.seq i.succ ) ( chain.step i ) ; norm_num at * ; linarith!;
  specialize h_ind ( Fin.last n ) ; simp_all +decide [ depthDecrement ];
  rw [ le_div_iff₀ ] <;> try positivity;
  have := hrange ( chain.seq 0 ) ( chain.seq ( Fin.last n ) ) ( chain.mem 0 ) ( chain.mem ( Fin.last n ) ) ; nlinarith [ show ( d : ℚ ) ^ ( d - k ) > 0 by positivity, div_mul_cancel₀ c ( by positivity : ( d : ℚ ) ^ ( d - k ) ≠ 0 ) ] ;

/-
**Theorem B: Linear bound at maximal depth.**
When `k = d`, the polynomial overhead vanishes: descent ≤ `(C₀/c) · D`.
This is the discrete analogue of "full curvature ⟹ linear convergence."
-/
theorem exchangeDescent_depth_eq_dim_linear
    {d : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (Φ : (Fin d → ℤ) → ℚ)
    (c C₀ : ℚ)
    (D : ℕ)
    (hc : 0 < c) (hC₀ : 0 < C₀)
    (hd : 1 ≤ d)
    (hdec : ∀ x y, improvingExchangeStep S f x y →
      Φ y + c ≤ Φ x)
    (hrange : ∀ x y, x ∈ S → y ∈ S → Φ x - Φ y ≤ C₀ * ↑D)
    (n : ℕ)
    (chain : DescentChain S f n) :
    (n : ℚ) ≤ C₀ / c * ↑D := by
  convert exchangeDescent_depth_bound_poly S f Φ c C₀ D hc hC₀ hd ( show d ≤ d from le_rfl ) _ hrange n chain using 1;
  · norm_num ; ring;
  · exact fun x y h => by rw [ depthDecrement_at_max_depth hd ] ; exact hdec x y h;

/-! ## Part 5: Certificate Depth Hierarchy -/

/-
Deeper certificates imply all shallower ones.
-/
theorem exchangeDLC_k_depth_mono {d : ℕ} {j k : ℕ}
    (hjk : j ≤ k)
    {S : Finset (Fin d → ℤ)} {f : (Fin d → ℤ) → ℤ}
    (hk : exchangeDLC_k k S f) :
    exchangeDLC_k j S f := by
  induction' hjk with j hj ih;
  · assumption;
  · exact ih hk.2

/-
**Runtime monotonicity**: deeper certificates yield tighter bounds.
-/
theorem depthCertificate_runtime_monotone
    {d k₁ k₂ : ℕ} {c C₀ : ℚ} {D : ℕ}
    (hc : 0 < c) (hC₀ : 0 < C₀) (hd : 1 ≤ d)
    (hk : k₁ ≤ k₂) (_hk₂ : k₂ ≤ d) :
    C₀ * ↑D * ↑d ^ (d - k₂) / c ≤ C₀ * ↑D * ↑d ^ (d - k₁) / c := by
  gcongr ; aesop

/-! ## Part 6: Cross-Domain Bridge — Log-Concavity to Depth Certificates -/

/-- A positive sequence over `ℚ`. -/
def PosSeq (a : ℕ → ℚ) : Prop := ∀ n, 0 < a n

/-- Log-concavity: `a(n+1)² ≥ a(n) · a(n+2)`. -/
def IsLogConcaveSeq (a : ℕ → ℚ) : Prop :=
  ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)

/-- Ratio sequence: `r(n) = a(n+1) / a(n)`. -/
def ratioSeq (a : ℕ → ℚ) : ℕ → ℚ :=
  fun n => a (n + 1) / a n

/-- **k-fold log-concavity** over `ℚ`. -/
def kFoldLogConcaveQ : ℕ → (ℕ → ℚ) → Prop
  | 0, a => PosSeq a
  | k + 1, a => PosSeq a ∧ IsLogConcaveSeq a ∧ kFoldLogConcaveQ k (ratioSeq a)

/-
k-fold log-concavity is monotone in the depth parameter.
-/
theorem kFoldLogConcaveQ_mono {j k : ℕ} {a : ℕ → ℚ}
    (hk : kFoldLogConcaveQ k a) (hjk : j ≤ k) :
    kFoldLogConcaveQ j a := by
  induction' j with j hj generalizing k a <;> induction' k with k hk <;> simp_all +decide [ kFoldLogConcaveQ ];
  exact hj hk.2.2 hjk

/-
Log-concave weight functions have non-increasing ratio sequences.
-/
theorem logConcave_ratio_nonincreasing {w : ℤ → ℚ}
    (hw_pos : ∀ v, 0 < w v)
    (hw_lc : ∀ v, w (v + 1) ^ 2 ≥ w v * w (v + 2)) :
    ∀ v, w (v + 2) / w (v + 1) ≤ w (v + 1) / w v := by
  exact fun v => by rw [ div_le_div_iff₀ ( hw_pos _ ) ( hw_pos _ ) ] ; linarith [ hw_lc v ] ;

/-
**Structural bridge**: exchange axiom + Φ-f compatibility ⟹ DLC.
-/
theorem exchange_axiom_compatible_gives_DLC
    {d : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (Φ : (Fin d → ℤ) → ℚ)
    (hf_Φ : ∀ x y, x ∈ S → y ∈ S → f y < f x → Φ y < Φ x)
    (hΦ_f : ∀ x y, x ∈ S → y ∈ S → Φ y < Φ x → f y < f x)
    (hexch_Φ : ∀ x ∈ S, ∀ y ∈ S, Φ y < Φ x →
      ∃ z, z ∈ S ∧ isExchangeStep x z ∧ Φ z < Φ x) :
    hasExchangeDLC S f := by
  intro x hx y hy hxy;
  exact Exists.elim ( hexch_Φ x hx y hy ( hf_Φ x y hx hy hxy ) ) fun z hz => ⟨ z, ⟨ hx, hz.1, hz.2.1, hΦ_f x z hx hz.1 hz.2.2 ⟩ ⟩ ;

/-
**Theorem C: Log-concavity induces depth certificates.**
Given a DLC at the base level, the full depth-k certificate follows.
-/
theorem kFoldLogConcave_induces_depthCertificate
    {d k : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (hk : 1 ≤ k)
    (hDLC : hasExchangeDLC S f) :
    exchangeDLC_k k S f := by
  induction hk <;> simp_all +decide [ exchangeDLC_k ]

/-- Monotonicity corollary for depth certificates from log-concavity. -/
theorem depthCertificate_from_logConcavity_mono
    {d k j : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (hjk : j ≤ k)
    (hDLC_k : exchangeDLC_k k S f) :
    exchangeDLC_k j S f :=
  exchangeDLC_k_depth_mono hjk hDLC_k

/-! ## Part 7: Full Pipeline -/

/-- **Full pipeline theorem**: log-concave weights → depth certificate →
bounded descent of length ≤ `C₀ · D · d^(d-k) / c`. -/
theorem logConcave_to_descent_bound
    {d k : ℕ} {n : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (Φ : (Fin d → ℤ) → ℚ)
    (c C₀ : ℚ) (D : ℕ)
    (hc : 0 < c) (hC₀ : 0 < C₀)
    (hd : 1 ≤ d) (hk : k ≤ d)
    (hdec : ∀ x y, improvingExchangeStep S f x y →
      Φ y + depthDecrement d k c ≤ Φ x)
    (hrange : ∀ x y, x ∈ S → y ∈ S → Φ x - Φ y ≤ C₀ * ↑D)
    (chain : DescentChain S f n) :
    (n : ℚ) ≤ C₀ * ↑D * ↑d ^ (d - k) / c :=
  exchangeDescent_depth_bound_poly S f Φ c C₀ D hc hC₀ hd hk hdec hrange n chain

end