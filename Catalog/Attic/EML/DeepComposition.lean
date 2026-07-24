/-
# Deep Compositional Approximation via Telescoping Error Bounds

This file proves the depth-n compositional error propagation theorem:
when each layer of a deep network is approximated with bounded error,
the total end-to-end error satisfies a recursive bound involving
the per-layer errors and Lipschitz constants.

## Main results

* `deep_approx_recursive` — Recursive error bound for n-layer composition:
  `E(n+1) = ε(n) + L(n) * E(n)`.
* `deep_approx_sum` — Closed-form: total error ≤ Σᵢ εᵢ · Πⱼ>ᵢ Lⱼ.
* `UniformApproxOn.coord_approx` — Coordinatewise approximation for
  `Fin m → ℝ`-valued functions.
-/
import Mathlib
import EMLDeep.UniformApprox

noncomputable section

open Finset NNReal

/-! ## Iterated composition helpers -/

/-- Compose a sequence of functions from index 0 to n-1. -/
def composeN {α : Type*} (Φ : ℕ → α → α) : ℕ → α → α
  | 0 => id
  | n + 1 => Φ n ∘ composeN Φ n

@[simp] theorem composeN_zero {α : Type*} (Φ : ℕ → α → α) :
    composeN Φ 0 = id := rfl

@[simp] theorem composeN_succ {α : Type*} (Φ : ℕ → α → α) (n : ℕ) :
    composeN Φ (n + 1) = Φ n ∘ composeN Φ n := rfl

/-! ## Recursive error bound for deep composition -/

/-- The recursive error formula for deep composition:
`E(0) = 0`, `E(n+1) = ε(n) + L(n) * E(n)`. -/
def deepError (ε : ℕ → ℝ) (L : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => ε n + L n * deepError ε L n

@[simp] theorem deepError_zero (ε L : ℕ → ℝ) : deepError ε L 0 = 0 := rfl

@[simp] theorem deepError_succ (ε L : ℕ → ℝ) (n : ℕ) :
    deepError ε L (n + 1) = ε n + L n * deepError ε L n := rfl

/-
**Depth-n telescoping theorem (recursive form).**
If each layer `Φ i` is `L i`-Lipschitz and is approximated pointwise by `Ψ i`
within error `ε i`, then the n-fold composition `Φ₀ ∘ ... ∘ Φₙ₋₁` is
approximated by `Ψ₀ ∘ ... ∘ Ψₙ₋₁` within `deepError ε L n` on `K`.
-/
theorem deep_approx_recursive {α : Type*} [PseudoMetricSpace α]
    (K : Set α)
    (Φ Ψ : ℕ → α → α)
    (ε : ℕ → ℝ) (L : ℕ → NNReal)
    (hLip : ∀ i, LipschitzWith (L i) (Φ i))
    (hApprox : ∀ i x, dist (Φ i x) (Ψ i x) ≤ ε i)
    (hε : ∀ i, 0 ≤ ε i) :
    ∀ n, UniformApproxOn K (composeN Φ n) (composeN Ψ n)
      (deepError ε (fun i => (L i : ℝ)) n) := by
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · exact fun x hx => by simp +decide [ deepError ] ;
  · convert UniformApproxOn.comp₂ ih ( hLip n ) ( fun x => hApprox n x ) ( show 0 ≤ deepError ε ( fun i => ( L i : ℝ ) ) n from ?_ ) using 1;
    · rw [ deepError_succ, add_comm ];
    · exact Nat.recOn n ( by norm_num [ deepError_zero ] ) fun n ih => by rw [ deepError_succ ] ; exact add_nonneg ( hε _ ) ( mul_nonneg ( NNReal.coe_nonneg _ ) ih ) ;

/-! ## Closed-form error bound -/

/-- The closed-form error bound: `Σᵢ<n εᵢ · Πⱼ∈{i+1,...,n-1} Lⱼ`. -/
def deepErrorSum (n : ℕ) (ε : ℕ → ℝ) (L : ℕ → ℝ) : ℝ :=
  ∑ i ∈ Finset.range n,
    ε i * ∏ j ∈ (Finset.range n).filter (fun j => i < j), L j

/-
The recursive error equals the closed-form sum.
-/
theorem deepError_eq_sum (ε L : ℕ → ℝ) :
    ∀ n, deepError ε L n = deepErrorSum n ε L := by
  intro n;
  induction' n with n ih;
  · rfl;
  · simp +decide [ deepError, deepErrorSum, Finset.sum_range_succ, ih ];
    simp +decide [ add_comm, Finset.sum_add_distrib, mul_add, Finset.mul_sum _ _ _, Finset.sum_mul, Finset.prod_range_succ, Finset.prod_filter ];
    rw [ Finset.prod_eq_one fun x hx => if_neg ( by linarith [ Finset.mem_range.mp hx ] ) ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.sum_congr rfl fun i hi => if_pos ( Finset.mem_range.mp hi ) ]

/-- **Depth-n telescoping theorem (closed-form).**
The total composition error is bounded by the weighted sum
`Σᵢ<n εᵢ · Πⱼ>ᵢ Lⱼ`. -/
theorem deep_approx_sum {α : Type*} [PseudoMetricSpace α]
    (K : Set α)
    (Φ Ψ : ℕ → α → α)
    (ε : ℕ → ℝ) (L : ℕ → NNReal)
    (hLip : ∀ i, LipschitzWith (L i) (Φ i))
    (hApprox : ∀ i x, dist (Φ i x) (Ψ i x) ≤ ε i)
    (hε : ∀ i, 0 ≤ ε i)
    (n : ℕ) :
    UniformApproxOn K (composeN Φ n) (composeN Ψ n)
      (deepErrorSum n ε (fun i => (L i : ℝ))) := by
  rw [← deepError_eq_sum]
  exact deep_approx_recursive K Φ Ψ ε L hLip hApprox hε n

/-! ## Non-negativity of the error bound -/

/-
The recursive error is non-negative when per-layer errors are.
-/
theorem deepError_nonneg (ε L : ℕ → ℝ) (hε : ∀ i, 0 ≤ ε i)
    (hL : ∀ i, 0 ≤ L i) :
    ∀ n, 0 ≤ deepError ε L n := by
  -- We prove this by induction on $n$.
  intro n
  induction' n with n ih;
  · exact?;
  · exact add_nonneg ( hε _ ) ( mul_nonneg ( hL _ ) ih )

/-! ## Uniform Lipschitz bound: when all constants equal -/

/-
When all Lipschitz constants are the same `L` and all errors are `δ`,
the total error is at most `δ · (Lⁿ - 1) / (L - 1)` for `L ≠ 1`,
or `n · δ` for `L = 1`. In either case, `n · δ · max(1, L)^(n-1)` is a
simple universal upper bound.
-/
theorem deepError_uniform_bound (δ : ℝ) (Lval : ℝ) (hδ : 0 ≤ δ) (hL : 0 ≤ Lval) (n : ℕ) :
    deepError (fun _ => δ) (fun _ => Lval) n ≤ n * δ * (max 1 Lval) ^ n := by
  induction' n with n ih <;> simp_all +decide [ deepError ];
  rw [ pow_succ' ];
  cases max_cases 1 Lval <;> simp_all +decide [ add_mul, mul_assoc ];
  · nlinarith [ show 0 ≤ deepError ( fun x => δ ) ( fun x => Lval ) n from deepError_nonneg _ _ ( fun _ => hδ ) ( fun _ => hL ) n ];
  · nlinarith [ show 0 ≤ δ * Lval ^ n by positivity, show 0 ≤ δ * Lval ^ n * n by positivity, show 0 ≤ δ * Lval ^ n * Lval by positivity, show 0 ≤ δ * Lval ^ n * Lval * n by positivity, pow_le_pow_right₀ ( by linarith : 1 ≤ Lval ) n.zero_le ]

/-! ## Coordinatewise approximation for vector-valued functions -/

/-
If each coordinate function `fun x => f x i` can be uniformly approximated
within `δ` on `K`, then the vector-valued function `f` can be uniformly
approximated within `m * δ` on `K` in the sup-metric on `Fin m → ℝ`.
-/
theorem coord_approx_sup {α : Type*} {m : ℕ}
    (K : Set α) (f : α → Fin m → ℝ)
    (g : Fin m → α → ℝ) (δ : ℝ)
    (hδ : 0 ≤ δ)
    (happrox : ∀ i, ∀ x ∈ K, |f x i - g i x| ≤ δ) :
    UniformApproxOn K f (fun x i => g i x)
      (m * δ) := by
  intro x hx;
  rw [ dist_pi_le_iff ( by positivity ) ];
  exact fun i => le_trans ( happrox i x hx ) ( le_mul_of_one_le_left hδ ( mod_cast Fin.pos i ) )

/-
Stronger coordinatewise bound: in the `ℓ∞`-metric on `Fin m → ℝ`,
the sup over coordinates of `|f x i - g i x| ≤ δ` implies
`dist f(x) g(x) ≤ δ` directly (since `dist` on `Fin m → ℝ` is the sup).
-/
theorem coord_approx_linf {α : Type*} {m : ℕ}
    (K : Set α) (f : α → Fin m → ℝ)
    (g : Fin m → α → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (happrox : ∀ i, ∀ x ∈ K, |f x i - g i x| ≤ δ) :
    UniformApproxOn K f (fun x i => g i x) δ := by
  intro x hx; simp +decide [ *, dist_pi_le_iff ] ;
  exact fun i => Real.dist_eq _ _ ▸ happrox i x hx

end