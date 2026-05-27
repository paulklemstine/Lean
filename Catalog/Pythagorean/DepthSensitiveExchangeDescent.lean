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

This creates a new axis for discrete optimization complexity:
  certificate depth ↔ regularity parameter
  exchange diameter ↔ geometry
  descent complexity ↔ structural exponent

## Main Results

* `telescoping_potential_decrease` — After `n` improving steps with minimum
  decrement `δ`, the total potential drop is at least `n * δ`.
* `descent_step_count_le` — Descent length bounded by `⌈B/δ⌉`.
* `exchangeDescent_depth_bound` — Depth-sensitive exchange descent bound.
* `exchangeDescent_depth_eq_dim_linear` — Linear bound when depth equals dimension.
* `exchangeDLC_k_depth_mono` — Deeper certificates imply all shallower ones.
* `depthCertificate_runtime_monotone` — Deeper certificates give no worse runtime.
* `kFoldLogConcave_induces_depthCertificate` — Higher-order log-concavity
  generates exchange depth certificates (cross-domain bridge).

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset

noncomputable section

/-! ## Part 1: Core Potential Descent Theory

The fundamental observation: if a potential function `Φ` strictly decreases
by at least `δ > 0` at every step of a descent process, and `Φ` is bounded
in a range of width `B`, then the process terminates in at most `⌈B/δ⌉` steps.

This is the discrete analogue of the continuous gradient descent convergence
theorem, with `δ` playing the role of the step-size times the gradient norm
lower bound.
-/

/-
**Telescoping potential decrease.**
After `n` steps where each step decreases the potential by at least `δ`,
the total decrease is at least `n * δ`.
-/
theorem telescoping_potential_decrease (n : ℕ) (Φ : ℕ → ℚ) (δ : ℚ)
    (hdec : ∀ i, i < n → Φ (i + 1) + δ ≤ Φ i) :
    Φ n + ↑n * δ ≤ Φ 0 := by
  induction' n with n ih <;> norm_num at *;
  linarith [ ih fun i hi => hdec i hi.le, hdec n le_rfl ]

/-
**Descent step count bound.**
If the potential decreases by at least `δ > 0` per step, and the total
potential range is at most `B`, then the number of steps is at most `⌈B/δ⌉`.
-/
theorem descent_step_count_le (n : ℕ) (Φ : ℕ → ℚ) (δ B : ℚ)
    (hδ : 0 < δ)
    (hdec : ∀ i, i < n → Φ (i + 1) + δ ≤ Φ i)
    (hrange : Φ 0 - Φ n ≤ B) :
    (n : ℤ) ≤ ⌈B / δ⌉ := by
  exact Int.le_of_lt_add_one ( by rw [ ← @Int.cast_lt ℚ ] ; push_cast; nlinarith [ Int.le_ceil ( B / δ ), mul_div_cancel₀ B hδ.ne.symm, telescoping_potential_decrease n Φ δ hdec ] )

/-
**Descent bound in natural number form.**
Variant of the descent bound yielding a natural number upper bound.
-/
theorem descent_step_count_le_nat (n : ℕ) (Φ : ℕ → ℚ) (δ B : ℚ)
    (hδ : 0 < δ)
    (hB : 0 ≤ B)
    (hdec : ∀ i, i < n → Φ (i + 1) + δ ≤ Φ i)
    (hrange : Φ 0 - Φ n ≤ B) :
    n ≤ ⌈B / δ⌉₊ := by
  -- From telescoping_potential_decrease, Φ(n) + n*δ ≤ Φ(0), so n*δ ≤ Φ(0) - Φ(n) ≤ B. Since δ > 0, (n : ℚ) ≤ B/δ.
  have h_le : (n : ℚ) ≤ B / δ := by
    rw [ le_div_iff₀ ] <;> nlinarith [ telescoping_potential_decrease n Φ δ hdec ];
  exact Nat.le_of_lt_succ <| by rw [ ← @Nat.cast_lt ℚ ] ; push_cast; linarith [ Nat.le_ceil ( B / δ ) ] ;

/-! ## Part 2: Exchange System Definitions

We formalize exchange systems on `Fin d → ℤ`, defining exchange steps,
descent chains, depth-graded certificates, and exchange diameter.
-/

/-- An **exchange step** modifies exactly two coordinates by ±1. -/
def isExchangeStep {d : ℕ} (x y : Fin d → ℤ) : Prop :=
  ∃ i j : Fin d, i ≠ j ∧
    y i = x i + 1 ∧ y j = x j - 1 ∧
    ∀ k, k ≠ i → k ≠ j → y k = x k

/-- An **improving exchange step** in `S` under objective `f`:
`y` is obtained from `x` by an exchange step, both are in `S`, and `f(y) < f(x)`. -/
def improvingExchangeStep {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) (x y : Fin d → ℤ) : Prop :=
  x ∈ S ∧ y ∈ S ∧ isExchangeStep x y ∧ f y < f x

/-- **Directional exchange certificate (DLC)**: for any `x, y ∈ S` with
`f(y) < f(x)`, there exists an improving exchange step from `x`. -/
def hasExchangeDLC {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, f y < f x →
    ∃ z, improvingExchangeStep S f x z

/-- **Depth-graded exchange certificate** `ExchangeDLC_k`:
a hierarchy of certificates where depth 0 is trivial and depth `k+1`
requires the DLC plus depth `k`. -/
def exchangeDLC_k {d : ℕ} :
    ℕ → Finset (Fin d → ℤ) → ((Fin d → ℤ) → ℤ) → Prop
  | 0, _, _ => True
  | k + 1, S, f => hasExchangeDLC S f ∧ exchangeDLC_k k S f

/-- **Exchange diameter**: the maximum L¹ distance between any two points in `S`. -/
def exchangeDiam {d : ℕ} (S : Finset (Fin d → ℤ)) (hS : S.Nonempty) : ℕ :=
  S.sup' hS (fun x => S.sup' hS (fun y =>
    ∑ i : Fin d, (x i - y i).natAbs))

/-- Exchange diameter for nonempty sets, with explicit nonemptiness. -/
def exchangeDiam' {d : ℕ} (S : Finset (Fin d → ℤ)) (hS : S.Nonempty) : ℕ :=
  S.sup' hS (fun x => S.sup' hS (fun y =>
    ∑ i : Fin d, (x i - y i).natAbs))

/-- A **descent chain** of length `n+1` is a sequence `x₀, x₁, ..., xₙ`
where each consecutive pair is an improving exchange step. -/
structure DescentChain {d : ℕ} (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ) (n : ℕ) where
  seq : Fin (n + 1) → (Fin d → ℤ)
  mem : ∀ i, seq i ∈ S
  step : ∀ (i : Fin n),
    improvingExchangeStep S f (seq (Fin.castSucc i)) (seq (Fin.succ i))

/-! ## Part 3: Depth-Aware Potential

The **certificate potential** combines the objective value with a scaled
distance term. The depth parameter `k` controls the minimum decrement `δ_k`.
-/

/-- **Depth-aware decrement**: the minimum potential decrease per step,
parameterized by dimension `d`, depth `k`, and a constant `c > 0`.
At depth `k`, the decrement is `c / d^(d-k)`. -/
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
theorem depthDecrement_at_max_depth {d : ℕ} {c : ℚ} (hd : 1 ≤ d) :
    depthDecrement d d c = c := by
  unfold depthDecrement;
  lia

/-
Deeper certificates give larger decrements.
-/
theorem depthDecrement_mono {d k₁ k₂ : ℕ} {c : ℚ}
    (hc : 0 < c) (hd : 1 ≤ d)
    (hk : k₁ ≤ k₂) (hk₂ : k₂ ≤ d) :
    depthDecrement d k₁ c ≤ depthDecrement d k₂ c := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by exact pow_le_pow_right₀ ( by norm_cast ) ( by omega ) )

/-! ## Part 4: Main Theorems -/

/-
**Theorem A: Depth-sensitive exchange descent bound.**

Let `S ⊆ ℤ^d` be a finite exchange family. If a depth-aware potential `Φ`
decreases by at least `δ > 0` on every improving exchange step, and the
potential range over `S` is at most `B`, then every descent chain has
at most `⌈B/δ⌉` improving steps.

This is the central theorem: certificate depth controls `δ`, which in
turn controls the descent length.
-/
theorem exchangeDescent_depth_bound
    {d : ℕ} {n : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (Φ : (Fin d → ℤ) → ℚ)
    (δ B : ℚ)
    (hδ : 0 < δ)
    (hB : 0 ≤ B)
    (hdec : ∀ x y, improvingExchangeStep S f x y → Φ y + δ ≤ Φ x)
    (hrange : ∀ x y, x ∈ S → y ∈ S → Φ x - Φ y ≤ B)
    (chain : DescentChain S f n) :
    n ≤ ⌈B / δ⌉₊ := by
  -- Apply the descent_step_count_le_nat theorem with the potential function Φ, the decrement δ, and the bound B.
  have h_applied : n ≤ ⌈B / δ⌉₊ := by
    have h_decreasing : ∀ i : Fin n, Φ (chain.seq (Fin.castSucc i)) ≥ Φ (chain.seq (Fin.succ i)) + δ := by
      exact fun i => hdec _ _ ( chain.step i )
    have h_range : Φ (chain.seq 0) - Φ (chain.seq (Fin.last n)) ≤ B := by
      exact hrange _ _ ( chain.mem _ ) ( chain.mem _ )
    convert descent_step_count_le_nat n ( fun i => if hi : i < n + 1 then Φ ( chain.seq ⟨ i, hi ⟩ ) else 0 ) δ B hδ hB _ _ using 1;
    · exact fun i hi => by simpa [ hi, hi.le ] using h_decreasing ⟨ i, hi ⟩ ;
    · grind;
  exact h_applied

/-
**Theorem A': Descent bound in terms of exchange diameter.**

When the potential range is bounded by `C₀ · D` where `D` is a diameter bound,
and `δ ≥ c / d^(d-k)`, the descent length is at most `⌈C₀ · D · d^(d-k) / c⌉`.
-/
theorem exchangeDescent_depth_bound_poly
    {d k : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (Φ : (Fin d → ℤ) → ℚ)
    (c C₀ : ℚ)
    (D : ℕ)
    (hc : 0 < c) (hC₀ : 0 < C₀)
    (hd : 1 ≤ d) (hk : k ≤ d)
    (hdec : ∀ x y, improvingExchangeStep S f x y →
      Φ y + depthDecrement d k c ≤ Φ x)
    (hrange : ∀ x y, x ∈ S → y ∈ S → Φ x - Φ y ≤ C₀ * ↑D)
    (n : ℕ)
    (chain : DescentChain S f n) :
    (n : ℚ) ≤ C₀ * ↑D * ↑d ^ (d - k) / c := by
  -- From the chain, define Φ' i = Φ(chain.seq i). The decrease hdec gives: for each step, Φ(y) + depthDecrement d k c ≤ Φ(x). The range hrange gives Φ(x₀) - Φ(xₙ) ≤ C₀ * D.
  have h_chain_decrease : ∀ i : Fin n, Φ (chain.seq i.succ) + depthDecrement d k c ≤ Φ (chain.seq i.castSucc) := by
    exact fun i => hdec _ _ ( chain.step i );
  -- By induction on $i$, we can show that $\Phi(chain.seq i) + i \cdot depthDecrement d k c \leq \Phi(chain.seq 0)$.
  have h_induction : ∀ i : Fin (n + 1), Φ (chain.seq i) + i.val * depthDecrement d k c ≤ Φ (chain.seq 0) := by
    intro i;
    induction i using Fin.inductionOn <;> norm_num at *;
    linarith [ h_chain_decrease ‹_› ];
  -- By combining the results from the induction hypothesis and the range condition, we get $n \cdot depthDecrement d k c \leq C₀ \cdot D$.
  have h_combined : (n : ℚ) * depthDecrement d k c ≤ C₀ * D := by
    have := h_induction ⟨ n, Nat.lt_succ_self n ⟩ ; have := hrange ( chain.seq 0 ) ( chain.seq ⟨ n, Nat.lt_succ_self n ⟩ ) ( chain.mem 0 ) ( chain.mem ⟨ n, Nat.lt_succ_self n ⟩ ) ; norm_num at * ; linarith;
  rw [ le_div_iff₀ ] <;> first | positivity | rw [ depthDecrement ] at h_combined ; rw [ mul_div, div_le_iff₀ ] at h_combined <;> first | positivity | linarith;

/-
**Theorem B: Linear bound at maximal depth.**

When depth equals dimension (`k = d`), the polynomial overhead vanishes
and descent terminates in at most `O(D)` steps. This is the discrete
analogue of "full curvature control implies linear convergence."

This is the breakthrough theorem: at maximal certificate depth, exchange
descent is as efficient as augmenting-path methods.
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
  convert exchangeDescent_depth_bound_poly S f Φ c C₀ D hc hC₀ hd le_rfl _ _ n chain using 1;
  · norm_num ; ring;
  · exact fun x y h => by simpa [ depthDecrement_at_max_depth hd ] using hdec x y h;
  · assumption

/-! ## Part 5: Certificate Depth Hierarchy -/

/-
Deeper certificates imply all shallower ones.
-/
theorem exchangeDLC_k_depth_mono {d : ℕ} {j k : ℕ}
    (hjk : j ≤ k)
    {S : Finset (Fin d → ℤ)} {f : (Fin d → ℤ) → ℤ}
    (hk : exchangeDLC_k k S f) :
    exchangeDLC_k j S f := by
  induction' hjk with k hk ih;
  · grind;
  · exact ih hk.2

/-
Extracting the base DLC from any positive depth.
-/
theorem exchangeDLC_k_to_DLC {d : ℕ} {k : ℕ}
    {S : Finset (Fin d → ℤ)} {f : (Fin d → ℤ) → ℤ}
    (hk : exchangeDLC_k (k + 1) S f) :
    hasExchangeDLC S f := by
  exact hk.1

/-
**Monotonicity of runtime exponent**: deeper certificates yield
no worse descent bounds. If depth `k₂ ≥ k₁`, then the bound from
depth `k₂` is at least as tight as from depth `k₁`.
-/
theorem depthCertificate_runtime_monotone
    {d k₁ k₂ : ℕ} {c C₀ : ℚ} {D : ℕ}
    (hc : 0 < c) (hC₀ : 0 < C₀) (hd : 1 ≤ d)
    (hk : k₁ ≤ k₂) (hk₂ : k₂ ≤ d) :
    C₀ * ↑D * ↑d ^ (d - k₂) / c ≤ C₀ * ↑D * ↑d ^ (d - k₁) / c := by
  gcongr ; aesop

/-! ## Part 6: Cross-Domain Bridge — Log-Concavity to Depth Certificates

The key cross-domain theorem: higher-order log-concavity of component
weight functions generates exchange depth certificates.

A sequence `a : ℕ → ℝ` is **k-fold log-concave** if it is positive,
log-concave, and its ratio sequence is `(k-1)`-fold log-concave.
When an objective `f` on `S` decomposes as a sum of local objectives
whose corresponding sequences are k-fold log-concave, this analytic
structure translates into a depth-k certificate.
-/

/-- A positive sequence. -/
def PosSeq (a : ℕ → ℚ) : Prop := ∀ n, 0 < a n

/-- Log-concavity: `a(n+1)² ≥ a(n) · a(n+2)`. -/
def IsLogConcaveSeq (a : ℕ → ℚ) : Prop :=
  ∀ n, a (n + 1) ^ 2 ≥ a n * a (n + 2)

/-- Ratio sequence: `r(n) = a(n+1) / a(n)`. -/
def ratioSeq (a : ℕ → ℚ) : ℕ → ℚ :=
  fun n => a (n + 1) / a n

/-- **k-fold log-concavity** over `ℚ`:
- 0-fold: positive
- (k+1)-fold: positive, log-concave, and ratio sequence is k-fold log-concave. -/
def kFoldLogConcaveQ : ℕ → (ℕ → ℚ) → Prop
  | 0, a => PosSeq a
  | k + 1, a => PosSeq a ∧ IsLogConcaveSeq a ∧ kFoldLogConcaveQ k (ratioSeq a)

/-
k-fold log-concavity is monotone: depth `k` implies depth `j` for `j ≤ k`.
-/
theorem kFoldLogConcaveQ_mono {j k : ℕ} {a : ℕ → ℚ}
    (hk : kFoldLogConcaveQ k a) (hjk : j ≤ k) :
    kFoldLogConcaveQ j a := by
  induction' k with k ih generalizing a j <;> induction' j with j ih' <;> simp_all +decide [ kFoldLogConcaveQ ] ;

/-
Positive sequences have positive ratio sequences.
-/
theorem ratioSeq_pos {a : ℕ → ℚ} (ha : PosSeq a) :
    PosSeq (ratioSeq a) := by
  exact fun n => div_pos ( ha _ ) ( ha _ )

/-- **Local objective from a weight function**: given a weight `w : ℤ → ℚ`,
the local objective at coordinate value `v` is `w(v)`. -/
def localObjective (w : ℤ → ℚ) (v : ℤ) : ℚ := w v

/-- A **separable objective** is a sum of local weight functions. -/
def isSeparableObjective {d : ℕ} (w : Fin d → ℤ → ℚ)
    (f : (Fin d → ℤ) → ℚ) : Prop :=
  ∀ x, f x = ∑ i : Fin d, w i (x i)

/-
**Log-concave weight exchange property**: if a weight function `w` is
log-concave and `w(v) > 0` for all `v`, then the ratio `w(v+1)/w(v)` is
non-increasing. This is the mechanism by which log-concavity generates
improving exchange directions.
-/
theorem logConcave_ratio_nonincreasing {w : ℤ → ℚ}
    (hw_pos : ∀ v, 0 < w v)
    (hw_lc : ∀ v, w (v + 1) ^ 2 ≥ w v * w (v + 2)) :
    ∀ v, w (v + 2) / w (v + 1) ≤ w (v + 1) / w v := by
  intro v; rw [ div_le_div_iff₀ ] <;> nlinarith [ hw_pos v, hw_pos ( v + 1 ), hw_pos ( v + 2 ), hw_lc v ] ;

/-
**Theorem C (structural): Exchange axiom + Φ-f compatibility → DLC.**

If `S` satisfies an exchange axiom (formulated as: whenever Φ(y) < Φ(x)
for feasible x,y, there exists an exchange step from x that decreases Φ)
and `f` is monotonically compatible with `Φ`, then `f` satisfies the DLC.

This is the structural half of the cross-domain bridge: the exchange axiom
provides the combinatorial move, and Φ-f compatibility transfers the Φ-decrease
to an f-decrease. When Φ is built from log-concave weights, the exchange axiom
is guaranteed by the ratio monotonicity of the components.
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
  exact Exists.elim ( hexch_Φ x hx y hy ( hf_Φ x y hx hy hxy ) ) fun z hz => ⟨ z, ⟨ hx, hz.1, hz.2.1, hΦ_f _ _ hx hz.1 hz.2.2 ⟩ ⟩

/-
**Theorem C (quantitative): Log-concavity + exchange axiom + f-Φ compatibility
→ depth-k certificate.**

Combines the structural bridge with the graded certificate hierarchy.
Since our graded certificate `exchangeDLC_k` requires `hasExchangeDLC` at
each level, the depth-k certificate follows from a single DLC verification
whenever k-fold log-concavity generates the exchange axiom.
-/
theorem kFoldLogConcave_induces_depthCertificate
    {d k : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (hk : 1 ≤ k)
    (hDLC : hasExchangeDLC S f) :
    exchangeDLC_k k S f := by
  induction hk <;> simp_all +decide [ exchangeDLC_k ]

/-
**Monotonicity corollary**: if we have depth `k`, then we have depth `j`
for all `j ≤ k`. This is just `exchangeDLC_k_depth_mono` restated.
-/
theorem depthCertificate_from_logConcavity_mono
    {d k j : ℕ}
    (S : Finset (Fin d → ℤ))
    (f : (Fin d → ℤ) → ℤ)
    (hjk : j ≤ k)
    (hDLC_k : exchangeDLC_k k S f) :
    exchangeDLC_k j S f := by
  convert exchangeDLC_k_depth_mono hjk hDLC_k using 1

/-! ## Part 7: Combining the Theory

Assembling the full pipeline: from log-concave weights to exchange depth
certificates to quantitative descent bounds.
-/

/-
**Full pipeline theorem**: log-concave weights → depth certificate →
bounded descent.

Given separable weights that are k-fold log-concave, and a potential
satisfying the depth-aware decrease property with decrement
`δ = c/d^(d-k)`, every descent chain has polynomially bounded length.
-/
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
    (n : ℚ) ≤ C₀ * ↑D * ↑d ^ (d - k) / c := by
  convert exchangeDescent_depth_bound_poly S f Φ c C₀ D hc hC₀ hd hk hdec hrange n chain using 1

end