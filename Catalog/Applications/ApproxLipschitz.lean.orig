/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Novelty.CertifiedNovelty

/-!
# Approximate Lipschitz Maps and Certificate Transfer with Error

This file extends the catalog novelty framework along the **exact → approximate** axis.
Real-world embeddings (e.g. neural feature maps) rarely satisfy an exact Lipschitz or
antilipschitz bound; they satisfy one *up to an additive error*. We model this with

* `ApproxLipschitzWith K c f` — `dist (f x) (f y) ≤ K * dist x y + c`, and
* `ApproxAntilipschitzWith K c f` — `dist x y ≤ K * dist (f x) (f y) + c`.

The exact catalog theory is the `c = 0` fragment (`LipschitzWith.approxLipschitzWith`).
The fundamental structural law is the **affine accumulation of error under
composition** (`ApproxLipschitzWith.comp`):
`(K₂, c₂) ∘ (K₁, c₁) = (K₂ · K₁, K₂ · c₁ + c₂)`.

Iterating this law for a single self-map gives the **layer-budget theorem**
(Future Direction 2): the `n`-fold iterate is approximately Lipschitz with constant
`K^n` and additive error the geometric sum `c · ∑_{i<n} K^i`, which is the closed form
`c · (K^n − 1)/(K − 1)` whenever `K ≠ 1` (`ApproxLipschitzWith.iterate`,
`ApproxLipschitzWith.iterate_error_closed`).

Finally, `approx_novel_transfer` upgrades the catalog's
`novel_transport_antilipschitz` to the noisy setting: an approximate expanding
embedding still transports a novelty certificate, with the threshold deflated both
multiplicatively (`/K`) and additively (`−c`).

## Main results

* `ApproxLipschitzWith.comp` — affine error accumulation under composition.
* `ApproxLipschitzWith.iterate` — depth-`n` iterate bound with geometric error.
* `ApproxLipschitzWith.iterate_error_closed` — closed-form geometric error.
* `LipschitzWith.approxLipschitzWith` — the exact theory embeds (`c = 0`).
* `approx_novel_transfer` — error-aware novelty certificate transfer.
-/

namespace CertifiedNovelty

open Metric

variable {α β γ : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]

-- !-- Lab Notebook --------------------------------------------------------------- !--
-- Hypothesis: certificate transport should survive *approximate* Lipschitz bounds,
--   and the additive error should compose in a controlled (affine) way, yielding a
--   computable depth budget for stacked embeddings.
-- Result: the additive error obeys `e ↦ K·e + c` under composition, so the depth-n
--   iterate has error the geometric series `c·∑_{i<n} K^i = c·(Kⁿ−1)/(K−1)`; novelty
--   certificates transfer with threshold `(ε − c)/K`.
-- Insight: the exact catalog theory is exactly the `c = 0` slice, and every exact
--   transport theorem deforms continuously into an error-aware one.
-- Failure analysis: composition needs `0 ≤ K₂` to preserve the inequality direction
--   when scaling the inner bound; without it the affine law is false.
-- ------------------------------------------------------------------------------- !--

/-! ## Approximate Lipschitz / antilipschitz predicates -/

/-- `f` is **`(K, c)`-approximately Lipschitz** if it contracts distances up to a
multiplicative factor `K` and an additive slack `c`. -/
def ApproxLipschitzWith (K c : ℝ) (f : α → β) : Prop :=
  ∀ x y, dist (f x) (f y) ≤ K * dist x y + c

/-- `f` is **`(K, c)`-approximately antilipschitz** (approximately expanding) if it
separates points up to factor `K` and additive slack `c`. -/
def ApproxAntilipschitzWith (K c : ℝ) (f : α → β) : Prop :=
  ∀ x y, dist x y ≤ K * dist (f x) (f y) + c

/-! ## The exact theory is the `c = 0` fragment -/

-- !-- `LipschitzWith K f` gives `dist (f x) (f y) ≤ K * dist x y`, i.e. the `c = 0`
-- instance of the approximate bound. -- !--
/-- **Exact ⊆ approximate.** A genuine `LipschitzWith K` map is `(K, 0)`-approximately
Lipschitz, so the noisy theory strictly contains the catalog's exact theory. -/
theorem LipschitzWith.approxLipschitzWith {K : NNReal} {f : α → β}
    (hf : LipschitzWith K f) : ApproxLipschitzWith (K : ℝ) 0 f :=
  fun x y => by simpa using hf.dist_le_mul x y

/-! ## Affine accumulation of error under composition -/

-- !-- Chain the two bounds: `dist (f (g x)) (f (g y)) ≤ K₂ (K₁ d + c₁) + c₂`, which
-- needs `0 ≤ K₂` to scale the inner inequality. -- !--
/-- **Compositional error law.** If `g` is `(K₁, c₁)`-approximately Lipschitz and `f`
is `(K₂, c₂)`-approximately Lipschitz with `0 ≤ K₂`, then `f ∘ g` is
`(K₂ · K₁, K₂ · c₁ + c₂)`-approximately Lipschitz. The error coordinate transforms
affinely: `c ↦ K₂ · c + c₂`. -/
theorem ApproxLipschitzWith.comp {K₁ c₁ K₂ c₂ : ℝ} {f : β → γ} {g : α → β}
    (hf : ApproxLipschitzWith K₂ c₂ f) (hg : ApproxLipschitzWith K₁ c₁ g)
    (hK₂ : 0 ≤ K₂) :
    ApproxLipschitzWith (K₂ * K₁) (K₂ * c₁ + c₂) (f ∘ g) := by
  intro x y
  exact (hf (g x) (g y)).trans (by rw [mul_assoc]; nlinarith! [hg x y])

/-! ## Future Direction 2: the layer-budget theorem -/

-- !-- Induction on `n` via `Function.iterate_succ'` and `ApproxLipschitzWith.comp`;
-- the error recurrence `e ↦ K e + c` telescopes into `c · ∑_{i<n} K^i`. -- !--
/-- **Depth-`n` layer budget.** For a single self-map `g` that is
`(K, c)`-approximately Lipschitz with `0 ≤ K`, the `n`-fold iterate `g^[n]` is
`(K^n, c · ∑_{i<n} K^i)`-approximately Lipschitz: the multiplicative constant
compounds geometrically and the additive error accumulates as a geometric series. -/
theorem ApproxLipschitzWith.iterate {K c : ℝ} {g : α → α}
    (hg : ApproxLipschitzWith K c g) (hK : 0 ≤ K) (n : ℕ) :
    ApproxLipschitzWith (K ^ n) (c * ∑ i ∈ Finset.range n, K ^ i) (g^[n]) := by
  induction n with
  | zero => intro x y; simp
  | succ n ih =>
    have hcomp := ApproxLipschitzWith.comp hg ih hK
    rw [Function.iterate_succ']
    have hpow : K ^ (n + 1) = K * K ^ n := by ring
    have hsum : c * ∑ i ∈ Finset.range (n + 1), K ^ i
        = K * (c * ∑ i ∈ Finset.range n, K ^ i) + c := by
      rw [Finset.sum_range_succ', pow_zero, mul_add, mul_one]
      simp only [Finset.mul_sum]
      congr 1
      exact Finset.sum_congr rfl (fun i _ => by ring)
    rw [hpow, hsum]
    exact hcomp

-- !-- `geom_sum_eq` rewrites `∑_{i<n} K^i = (K^n − 1)/(K − 1)` for `K ≠ 1`. -- !--
/-- **Closed-form depth budget.** For `K ≠ 1` the accumulated additive error of the
depth-`n` iterate is `c · (K^n − 1)/(K − 1)`. This is the exact "budget" that governs
when a transferred certificate becomes vacuous. -/
theorem ApproxLipschitzWith.iterate_error_closed (K c : ℝ) (hK : K ≠ 1) (n : ℕ) :
    c * ∑ i ∈ Finset.range n, K ^ i = c * ((K ^ n - 1) / (K - 1)) := by
  rw [geom_sum_eq hK]

/-! ## Error-aware novelty certificate transfer -/

-- !-- `ε ≤ dist x s ≤ K · dist (f x) (f s) + c` gives
-- `dist (f x) (f s) ≥ (ε − c)/K`; finish with `div_le_iff₀`. -- !--
/-- **Approximate novelty transfer.** If `f` is `(K, c)`-approximately antilipschitz
with `0 < K` and `x` is `ε`-novel w.r.t. `S`, then `f x` is `((ε − c) / K)`-novel
w.r.t. the image `f '' S`. The certificate survives an approximate expanding embedding,
its threshold deflated multiplicatively by `K` and additively by the error `c`. -/
theorem approx_novel_transfer {K c : ℝ} {f : α → β}
    (hf : ApproxAntilipschitzWith K c f) (hK : 0 < K) {ε : ℝ} {S : Set α} {x : α}
    (hx : IsNovel ε S x) : IsNovel ((ε - c) / K) (f '' S) (f x) := by
  rintro _ ⟨s, hs, rfl⟩
  rw [div_le_iff₀ hK]
  linarith [hx s hs, hf x s]

end CertifiedNovelty