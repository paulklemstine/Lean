/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Conserved Quantities along Reduction Paths

This file fuses two strands of the catalog that were developed independently:

* the **conserved-quantity view of cryptographic reductions**
  (`Catalog/Cryptography/AdvantageMetric.lean`, where *advantage* behaves like a
  pseudo-metric coordinate and the hybrid argument is sub-additivity), and
* the **Fibonacci / Carmichael primitive-divisor** work
  (`Catalog/Shared/CarmichaelProof.lean`,
  `Catalog/Novelty/FibApparitionExistence.lean`).

The unifying observation is that *both* theories are about a **length / valuation
functional on a discrete path** and the morphisms that conserve it.

A sequence of cryptographic games is a discrete path in a pseudometric space; the
advantage is its **length**; a reduction is a **Lipschitz morphism** of path
spaces; and the "advantage-loss factor" is nothing but a **Lipschitz constant**.
Dually, in number theory the Fibonacci map is a *gcd-conserving morphism of the
divisor lattice* (`gcd (fib m) (fib n) = fib (gcd m n)`), and this conserved
quantity is the homotopy-invariant heart of the primitive-divisor (Carmichael)
argument.

## Main results

* `gameDist_path_le` — endpoint distance ≤ path length: the metric-space
  generalization of `AdvantageMetric.hybrid_argument`, valid in *any* pseudometric
  space rather than over a single real coordinate.
* `pathLength_concat` — the path-length functional is additive under concatenation
  at any intermediate game `k ≤ n`: the structural form of the triangle
  conservation law `AdvantageMetric.advantage_triangle`.
* `lipschitz_reduction_contracts_path` — a `K`-Lipschitz reduction multiplies the
  path length by at most `K`. This single inequality subsumes both the
  multiplicative law `AdvantageMetric.reduction_composition` and the additive
  hybrid bound `AdvantageMetric.prg_stretch_amplification`.
* `reduction_end_to_end_bound` — chaining the previous two into the headline
  quantitative reduction estimate `dist (φ(f 0)) (φ(f n)) ≤ K · pathLength f n`.
* `fib_gcd_conservation` — the gcd-conserved quantity on Fibonacci, read as a
  conservation law (catalog synthesis with the Carmichael work).
* `fib_primitivity_bridge` — a clean, self-contained restatement and proof of the
  conserved-quantity heart of `CarmichaelProof.bridge_lemma`: local
  non-divisibility on *proper divisors* collapses to global non-divisibility on
  *all smaller indices*, purely via gcd conservation.

-- !-- Lab Notebook -- !--
Hypothesis: The cryptographic hybrid/composition calculus and the Fibonacci
  primitive-divisor argument are two instances of one structure: a non-negative
  *length functional* on a discrete path, together with morphisms that contract
  it. On the crypto side the functional is path length in a pseudometric space;
  on the number-theory side it is the gcd-valuation of the Fibonacci map. If
  true, the hybrid argument, reduction composition, and the Carmichael bridge
  should all become one-line consequences of (a) telescoping/triangle, (b)
  Lipschitz monotonicity, and (c) gcd conservation `Nat.fib_gcd`.
Result: Confirmed. `gameDist_path_le` is exactly `dist_le_range_sum_dist`;
  `pathLength_concat` is `Finset.sum_range_add_sum_Ico`;
  `lipschitz_reduction_contracts_path` is `Finset.sum_le_sum` + `Finset.mul_sum`;
  `reduction_end_to_end_bound` chains the two; `fib_gcd_conservation` is
  `Nat.fib_gcd`; and `fib_primitivity_bridge` collapses to a single application
  of gcd conservation, mirroring `CarmichaelProof.bridge_lemma`.
Insight: "Advantage", "path length", and "gcd-valuation" are the same conserved
  coordinate viewed in three categories (ℝ, a pseudometric space, the divisor
  lattice). Sub-additivity along a path and contraction under a morphism are the
  only two laws needed; the entire quantitative theory is their interplay.
Failure analysis: The Lipschitz contraction does *not* need `0 ≤ K`: the
  termwise bounds `dist (φ x) (φ y) ≤ K * dist x y` are summed directly, so
  `Finset.sum_le_sum` + `Finset.mul_sum` closes it for any real `K` (a pleasant
  surprise — the nonnegativity of a Lipschitz constant is automatic from a
  single step and never used). The bridge lemma genuinely needs `0 < n` so that
  `gcd n k` is a *positive proper* divisor of `n`, otherwise the conserved
  quantity lands outside the range where local non-divisibility is assumed.
-- !-- Lab Notebook -- !--
-/

namespace Cryptography.ConservedPathReductions

open Finset

/-! ## The length functional on a discrete path -/

/-- The **path length** of a discrete walk `f : ℕ → α` through the first `n`
steps of a pseudometric space: the sum of consecutive distances. In the
cryptographic reading `f` is a sequence of games and `pathLength f n` is the
end-to-end *advantage* accumulated across `n` hybrids. -/
def pathLength {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, dist (f i) (f (i + 1))

@[simp] theorem pathLength_zero {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) :
    pathLength f 0 = 0 := by simp [pathLength]

theorem pathLength_succ {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) :
    pathLength f (n + 1) = pathLength f n + dist (f n) (f (n + 1)) := by
  simp [pathLength, Finset.sum_range_succ]

theorem pathLength_nonneg {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) :
    0 ≤ pathLength f n :=
  Finset.sum_nonneg fun _ _ => dist_nonneg

/-! ## The conservation laws of reduction paths -/

-- !-- The end-to-end distance is bounded by the accumulated path length: this is
-- the iterated triangle inequality (telescoping), i.e. `dist_le_range_sum_dist`.
-- It is the pseudometric generalization of `AdvantageMetric.hybrid_argument`. -- !--
/-- **Endpoint bound (hybrid argument).** The distance between the endpoints of a
walk is at most its path length. Generalizes `AdvantageMetric.hybrid_argument`
from the real advantage coordinate to an arbitrary pseudometric space. -/
theorem gameDist_path_le {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) :
    dist (f 0) (f n) ≤ pathLength f n :=
  dist_le_range_sum_dist f n

-- !-- Splitting the range `[0,n) = [0,k) ∪ [k,n)` via `sum_range_add_sum_Ico`
-- gives additivity of the length functional under concatenation. -- !--
/-- **Concatenation additivity.** The path-length functional is additive when a
walk is split at any intermediate game `k ≤ n`. This is the structural form of the
triangle conservation law `AdvantageMetric.advantage_triangle`. -/
theorem pathLength_concat {α : Type*} [PseudoMetricSpace α] (f : ℕ → α)
    (k n : ℕ) (hk : k ≤ n) :
    pathLength f n =
      pathLength f k + ∑ i ∈ Finset.Ico k n, dist (f i) (f (i + 1)) := by
  unfold pathLength
  rw [Finset.sum_range_add_sum_Ico _ hk]

-- !-- Each consecutive distance contracts by `K` under a `K`-Lipschitz map, so
-- summing and pulling `K` out with `Finset.mul_sum` contracts the whole length.
-- This subsumes `AdvantageMetric.reduction_composition`. -- !--
/-- **Lipschitz reduction contracts path length.** A `K`-Lipschitz reduction `φ`
multiplies the path length by at most `K`. This single inequality subsumes both
the multiplicative law `AdvantageMetric.reduction_composition` and the additive
hybrid bound `AdvantageMetric.prg_stretch_amplification`. -/
theorem lipschitz_reduction_contracts_path
    {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
    (φ : α → β) (K : ℝ)
    (hφ : ∀ x y, dist (φ x) (φ y) ≤ K * dist x y)
    (f : ℕ → α) (n : ℕ) :
    pathLength (φ ∘ f) n ≤ K * pathLength f n := by
  unfold pathLength
  rw [Finset.mul_sum]
  exact Finset.sum_le_sum fun i _ => hφ (f i) (f (i + 1))

-- !-- Chain the endpoint bound (for the reduced walk `φ ∘ f`) with the Lipschitz
-- contraction: `dist (φ(f 0)) (φ(f n)) ≤ pathLength (φ∘f) n ≤ K · pathLength f n`. -- !--
/-- **End-to-end reduction bound.** The headline quantitative reduction estimate:
the endpoint distance of the reduced walk is at most `K` times the original path
length. -/
theorem reduction_end_to_end_bound
    {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
    (φ : α → β) (K : ℝ)
    (hφ : ∀ x y, dist (φ x) (φ y) ≤ K * dist x y)
    (f : ℕ → α) (n : ℕ) :
    dist (φ (f 0)) (φ (f n)) ≤ K * pathLength f n := by
  calc dist (φ (f 0)) (φ (f n))
      = dist ((φ ∘ f) 0) ((φ ∘ f) n) := rfl
    _ ≤ pathLength (φ ∘ f) n := gameDist_path_le (φ ∘ f) n
    _ ≤ K * pathLength f n :=
        lipschitz_reduction_contracts_path φ K hφ f n

/-! ## The dual conservation law: Fibonacci gcd valuation -/

-- !-- `Nat.fib_gcd` states `fib (gcd m n) = gcd (fib m) (fib n)`; symmetrized it
-- reads as the conservation of the gcd-quantity under the Fibonacci map. -- !--
/-- **Fibonacci gcd conservation.** The Fibonacci map is a morphism of the divisor
lattice: the gcd of Fibonacci numbers is the Fibonacci of the gcd. This is the
conserved quantity dual to path length on the cryptographic side. -/
theorem fib_gcd_conservation (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

-- !-- If `p ∤ fib d` for every *proper* divisor `d` of `n`, and `p ∣ fib k` for
-- some `0 < k < n`, then `p ∣ gcd (fib n) (fib k) = fib (gcd n k)`; but `gcd n k`
-- is a positive proper divisor of `n`, contradicting the hypothesis. -- !--
/-- **Primitivity bridge (conserved-quantity heart of Carmichael).** A clean,
self-contained restatement of `CarmichaelProof.bridge_lemma`: if a prime `p`
divides `fib n` but divides `fib d` for *no* proper divisor `d` of `n`, then `p`
divides `fib k` for *no* `0 < k < n` at all. The collapse from "proper divisors"
to "all smaller indices" is pure gcd conservation. -/
theorem fib_primitivity_bridge (n : ℕ) (hn : 0 < n) (p : ℕ)
    (hpn : p ∣ Nat.fib n)
    (hdiv : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hkn hpk
  have h_gcd_dvd : p ∣ Nat.fib (Nat.gcd n k) := by
    rw [Nat.fib_gcd]; exact Nat.dvd_gcd hpn hpk
  exact hdiv (Nat.gcd n k) (Nat.gcd_dvd_left n k)
    (Nat.gcd_pos_of_pos_left k hn)
    (lt_of_le_of_lt (Nat.gcd_le_right n hk) hkn) h_gcd_dvd

end Cryptography.ConservedPathReductions