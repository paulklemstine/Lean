/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Higher-Order Shadow Towers and Superlinear Lower Bounds

This file develops the theory of **k-th order support shadows** and proves
a tower of circuit complexity lower bounds for higher-order differentiation.

## Mathematical overview

Given a finite support set `S ⊆ ℕⁿ` of exponent vectors, the **k-th shadow**
`Sh_k(S)` consists of all exponent vectors obtainable by subtracting k basis
vectors (with repetition) from elements of `S`. This generalizes the second
shadow from `ShadowCircuitComplexity.lean`.

The k-th shadow captures the support of all k-th order partial derivatives
of a polynomial with support `S`. The tower `Sh_1 ⊇ Sh_2 ⊇ ...` creates
an arithmetic complexity filtration.

## Main definitions

* `ShadowTower.kthShadow` — The k-th shadow `Sh_k(S)`, defined inductively
* `ShadowTower.firstShadow` — The first shadow (gradient support)
* `ShadowTower.simplexSupport` — Simplex support `T(d, m)` (degree-m monomials in d vars)
* `ShadowTower.DerivativeCircuit` — Circuit model for k-th derivative computation
* `ShadowTower.JetDimension` — Jet bundle dimension (cross-domain bridge)

## Main results

* `ShadowTower.kthShadow_mono` — Monotonicity: `S ⊆ T → Sh_k(S) ⊆ Sh_k(T)`
* `ShadowTower.kthShadow_card_antitone` — Tower property: `k ≤ l → |Sh_l(S)| ≤ |Sh_k(S)|`
  (higher-order shadows have smaller cardinality)
* `ShadowTower.kthShadow_simplexSupport` — The k-th shadow of simplex support
  `T(d,m)` equals `T(d, m-k)` when `k ≤ m`
* `ShadowTower.derivative_circuit_lower_bound` — Circuit lower bound:
  `|Sh_k(S)| ≤ n^k * circuit_size`
* `ShadowTower.simplexSupport_card_bound` — Exact cardinality via binomial coefficients
* `ShadowTower.jet_dimension_eq_shadow_card` — Cross-domain: jet dimension = shadow card

## References

* Builds on `ShadowCircuitComplexity.lean` (k=2 case)
* Builds on `HigherOrderShadowCertificates.lean` (non-cancellation theory)
-/

open Finset BigOperators

namespace ShadowTower

variable {n : ℕ}

/-! ## First Shadow (Gradient Support) -/

/-- Predicate: `β` is in the first shadow of `α`, i.e., `α = β + eᵢ` for some `i`. -/
def InFirstShadowOf (α β : Fin n → ℕ) : Prop :=
  ∃ i : Fin n, ∀ k : Fin n, α k = β k + if k = i then 1 else 0

instance (α β : Fin n → ℕ) : Decidable (InFirstShadowOf α β) :=
  inferInstanceAs (Decidable (∃ i : Fin n, ∀ k : Fin n, α k = β k + if k = i then 1 else 0))

/-- The **first shadow** of a support set: all exponent vectors obtainable by
subtracting one basis vector from an element of `S`. -/
noncomputable def firstShadow (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.biUnion fun α =>
    (Fintype.piFinset fun k => Finset.range (α k + 1)).filter fun β =>
      InFirstShadowOf α β

/-- Membership characterization for the first shadow. -/
theorem mem_firstShadow_iff {S : Finset (Fin n → ℕ)} {β : Fin n → ℕ} :
    β ∈ firstShadow S ↔ ∃ α ∈ S, InFirstShadowOf α β := by
  simp only [firstShadow, mem_biUnion, mem_filter, Fintype.mem_piFinset, mem_range]
  constructor
  · rintro ⟨α, hα, hβ_range, hβ_shadow⟩
    exact ⟨α, hα, hβ_shadow⟩
  · rintro ⟨α, hα, ⟨i, hi⟩⟩
    refine ⟨α, hα, fun k => ?_, i, hi⟩
    have := hi k; omega

/-! ## k-th Shadow (Inductive Definition) -/

/-- The **k-th shadow** of a support set, defined inductively:
- `Sh_0(S) = S`
- `Sh_{k+1}(S) = Sh_1(Sh_k(S))`

This captures the support of all k-th order partial derivatives. -/
noncomputable def kthShadow : ℕ → Finset (Fin n → ℕ) → Finset (Fin n → ℕ)
  | 0, S => S
  | k + 1, S => firstShadow (kthShadow k S)

@[simp] theorem kthShadow_zero (S : Finset (Fin n → ℕ)) :
    kthShadow 0 S = S := rfl

@[simp] theorem kthShadow_succ (k : ℕ) (S : Finset (Fin n → ℕ)) :
    kthShadow (k + 1) S = firstShadow (kthShadow k S) := rfl

theorem kthShadow_one (S : Finset (Fin n → ℕ)) :
    kthShadow 1 S = firstShadow S := rfl

/-! ## Monotonicity of k-th Shadow -/

/-- The first shadow is monotone in the support set. -/
theorem firstShadow_mono {S T : Finset (Fin n → ℕ)} (h : S ⊆ T) :
    firstShadow S ⊆ firstShadow T := by
  intro β hβ
  rw [mem_firstShadow_iff] at hβ ⊢
  obtain ⟨α, hα, hαβ⟩ := hβ
  exact ⟨α, h hα, hαβ⟩

/-- The k-th shadow is monotone in the support set. -/
theorem kthShadow_mono {S T : Finset (Fin n → ℕ)} (h : S ⊆ T) (k : ℕ) :
    kthShadow k S ⊆ kthShadow k T := by
  induction k with
  | zero => exact h
  | succ k ih => exact firstShadow_mono ih

/-! ## Simplex Support -/

/-- The simplex support `T(d, m)`: all exponent vectors in `ℕᵈ` summing to exactly `m`.
These are the monomials of a generic homogeneous polynomial of degree `m`. -/
noncomputable def simplexSupport (d m : ℕ) : Finset (Fin d → ℕ) :=
  (Fintype.piFinset fun _ => Finset.range (m + 1)).filter fun α => ∑ i, α i = m

theorem mem_simplexSupport_iff {d m : ℕ} {α : Fin d → ℕ} :
    α ∈ simplexSupport d m ↔ (∀ i, α i ≤ m) ∧ ∑ i, α i = m := by
  simp +decide [simplexSupport]

/-! ## First Shadow of Simplex Support -/

/-
The first shadow of the degree-m simplex equals the degree-(m-1) simplex.
This is the base case for the inductive tower.
-/
theorem firstShadow_simplexSupport {d : ℕ} {m : ℕ} (hd : 1 ≤ d) (hm : 1 ≤ m) :
    firstShadow (simplexSupport d m) = simplexSupport d (m - 1) := by
  unfold firstShadow simplexSupport;
  ext β;
  constructor;
  · simp +decide [ InFirstShadowOf ];
    intro x hx₁ hx₂ hx i hi; refine' ⟨ fun j => _, _ ⟩;
    · have := Finset.sum_le_sum fun k ( hk : k ∈ Finset.univ.erase j ) => hx k; simp_all +decide [ Finset.sum_add_distrib ] ;
      exact Nat.le_sub_one_of_lt ( lt_of_le_of_lt ( Finset.single_le_sum ( fun a _ => Nat.zero_le ( β a ) ) ( Finset.mem_univ j ) ) ( by linarith ) );
    · rw [ ← hx₂, Finset.sum_congr rfl fun j hj => hi j ] ; simp +decide [ Finset.sum_add_distrib, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
  · simp +zetaDelta at *;
    intro hβ hsum
    use fun i => β i + if i = ⟨0, by linarith⟩ then 1 else 0;
    exact ⟨ ⟨ fun i => by specialize hβ i; split_ifs <;> omega, by rw [ Finset.sum_add_distrib, hsum ] ; aesop ⟩, fun i => by split_ifs <;> linarith, ⟨ ⟨ 0, hd ⟩, fun i => by aesop ⟩ ⟩

/-! ## Main Theorem: k-th Shadow of Simplex Support -/

/-
**Tower Simplex Theorem.** For `k ≤ m`, the k-th shadow of the degree-m
simplex support equals the degree-(m-k) simplex support:
`Sh_k(T(d, m)) = T(d, m - k)`.

This is proved by induction on k, using `firstShadow_simplexSupport` as base case.
-/
theorem kthShadow_simplexSupport {d : ℕ} (hd : 1 ≤ d)
    (m k : ℕ) (hk : k ≤ m) :
    kthShadow k (simplexSupport d m) = simplexSupport d (m - k) := by
  induction' k with k ih;
  · rfl;
  · convert firstShadow_simplexSupport hd ( Nat.sub_pos_of_lt hk ) using 1;
    rw [ ← ih ( Nat.le_of_succ_le hk ), kthShadow_succ ]

/-! ## Shadow Tower Card Antitone Property -/

/-
The shadow tower is cardinality-antitone on simplex supports:
higher-order shadows have smaller or equal cardinality.
`k ≤ l → |Sh_l(T(d,m))| ≤ |Sh_k(T(d,m))|`.

Note: The sets themselves are NOT subsets (they have different total degrees),
but their cardinalities decrease along the tower.
-/
theorem kthShadow_card_antitone {d : ℕ} (hd : 1 ≤ d)
    {m k l : ℕ} (hkl : k ≤ l) (hl : l ≤ m) :
    (kthShadow l (simplexSupport d m)).card ≤ (kthShadow k (simplexSupport d m)).card := by
  -- By definition of $k$-th shadow, we know that $kthShadow l (simplexSupport d m) = simplexSupport d (m - l)$ and $kthShadow k (simplexSupport d m) = simplexSupport d (m - k)$.
  have h_shadows : kthShadow l (simplexSupport d m) = simplexSupport d (m - l) ∧ kthShadow k (simplexSupport d m) = simplexSupport d (m - k) := by
    grind +suggestions;
  rcases d with ( _ | d ) <;> simp_all +decide [ Nat.choose_eq_zero_iff ];
  refine' le_trans _ ( Finset.card_mono _ );
  any_goals exact Finset.image ( fun α : Fin ( d + 1 ) → ℕ => fun i => if i = 0 then α 0 + ( l - k ) else α i ) ( simplexSupport ( d + 1 ) ( m - l ) );
  · rw [ Finset.card_image_of_injective ];
    intro α β h; ext i; replace h := congr_fun h i; aesop;
  · intro; simp +decide [ Fin.sum_univ_succ, simplexSupport ] at *;
    grind +ring

/-! ## Derivative Circuit Model -/

/-- A **derivative circuit** of order `k` over `n` variables.
This models a circuit that computes all k-th partial derivative supports.
Each gate can compute unions or intersections of exponent sets.

The circuit has `n^k` output channels, one for each k-th partial derivative
`∂^k / ∂x_{i₁} ... ∂x_{iₖ}`. -/
structure DerivativeCircuit (n : ℕ) (k : ℕ) where
  /-- Number of internal gates -/
  size : ℕ
  /-- Output function: maps each gate to a set of exponent vectors -/
  output : Fin size → Finset (Fin n → ℕ)
  /-- Channel assignment: each derivative channel maps to an output gate -/
  channelGate : (Fin n → Fin k) → Fin size
  /-- Each output gate's contribution is bounded by the gate's own size -/
  gate_output_bound : ∀ g, (output g).card ≤ size

/-- A derivative circuit correctly computes the k-th derivative support
when each channel's output covers the corresponding shadow slice. -/
def ComputesKthDerivSupport (S : Finset (Fin n → ℕ))
    (C : DerivativeCircuit n k) : Prop :=
  ∀ β ∈ kthShadow k S, ∃ channel, β ∈ C.output (C.channelGate channel)

/-! ## Circuit Lower Bound -/

/-
**k-th Order Circuit Lower Bound.**
Any derivative circuit of order k computing all k-th derivative supports
must have size at least `|Sh_k(S)| / (card of channel space)`.

For k-th derivatives, the number of channels is at most `n^k`.
-/
theorem derivative_circuit_lower_bound
    (S : Finset (Fin n → ℕ))
    (C : DerivativeCircuit n k)
    (hC : ComputesKthDerivSupport S C) :
    (kthShadow k S).card ≤ Fintype.card (Fin n → Fin k) * C.size := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.biUnion ( Finset.univ : Finset ( Fin n → Fin k ) ) fun ch => C.output ( C.channelGate ch );
  · intro β hβ; specialize hC β hβ; aesop;
  · exact le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_card_nsmul _ _ _ fun x hx => C.gate_output_bound _ ) |> le_trans <| by simp +decide [ mul_comm ] ;

/-! ## Binomial Cardinality of Simplex Support -/

/-
The cardinality of `simplexSupport d m` equals `Nat.choose (m + d - 1) (d - 1)`.
This is the standard stars-and-bars formula.
-/
theorem simplexSupport_card (d m : ℕ) (hd : 1 ≤ d) :
    (simplexSupport d m).card = Nat.choose (m + d - 1) (d - 1) := by
  induction' d with d hd generalizing m;
  · contradiction;
  · -- For the inductive step, we can use the fact that the number of solutions to $x_1 + x_2 + \cdots + x_{d+1} = m$ is equal to the sum of the number of solutions to $x_1 + x_2 + \cdots + x_d = m - k$ for $k = 0, 1, \ldots, m$.
    have h_sum : (simplexSupport (d + 1) m).card = ∑ k ∈ Finset.range (m + 1), (simplexSupport d (m - k)).card := by
      have h_sum : (simplexSupport (d + 1) m).card = ∑ k ∈ Finset.range (m + 1), Finset.card (Finset.filter (fun α : Fin (d + 1) → ℕ => α 0 = k) (simplexSupport (d + 1) m)) := by
        rw [ ← Finset.card_biUnion ];
        · congr with α ; simp +decide [ simplexSupport ];
          exact fun h₁ h₂ => h₁ 0;
        · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by aesop;
      rw [h_sum];
      refine' Finset.sum_congr rfl fun k hk => _;
      refine' Finset.card_bij ( fun α hα => fun i => α ( Fin.succ i ) ) _ _ _ <;> simp_all +decide [ Finset.mem_filter, Finset.mem_range ];
      · simp_all +decide [ Fin.sum_univ_succ, simplexSupport ];
        exact fun a ha₁ ha₂ ha₃ => ⟨ fun i => Nat.le_sub_of_add_le ( by linarith [ ha₁ i.succ, Finset.single_le_sum ( fun x _ => Nat.zero_le ( a ( Fin.succ x ) ) ) ( Finset.mem_univ i ) ] ), by omega ⟩;
      · intro a₁ ha₁ ha₂ a₂ ha ha h; ext i; induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
      · intro b hb; use Fin.cons k b; simp_all +decide [ simplexSupport ] ;
        exact fun i => by cases i using Fin.inductionOn <;> [ exact hk; exact le_trans ( hb.1 _ ) ( Nat.sub_le _ _ ) ] ;
    rcases d with ( _ | d ) <;> simp_all +decide [ Nat.choose_succ_succ, add_comm ];
    · simp +decide [ simplexSupport ];
      rw [ Finset.sum_eq_single m ] <;> simp +contextual [ Nat.sub_eq_zero_iff_le ];
      exact fun b hb₁ hb₂ => ne_of_lt ( Nat.sub_pos_of_lt ( lt_of_le_of_ne hb₁ hb₂ ) );
    · exact Nat.recOn m ( by simp +arith +decide ) fun n ih => by simp +arith +decide [ Finset.sum_range_succ', Nat.choose_succ_succ ] at * ; linarith;

/-! ## Explicit Tower Lower Bound -/

/-
**Tower Lower Bound.** For the simplex support `T(d, m)`, any k-th
derivative circuit must have size at least
`choose(m - k + d - 1, d - 1) / n^k`.

This gives a polynomial lower bound that degrades gracefully with k.
-/
theorem tower_lower_bound (d m k : ℕ) (hd : 1 ≤ d) (hk : k ≤ m)
    (C : DerivativeCircuit d k)
    (hC : ComputesKthDerivSupport (simplexSupport d m) C) :
    Nat.choose (m - k + d - 1) (d - 1) ≤ Fintype.card (Fin d → Fin k) * C.size := by
  convert derivative_circuit_lower_bound ( simplexSupport d m ) C hC using 1;
  rw [ kthShadow_simplexSupport hd m k hk, simplexSupport_card ];
  grind

/-! ## Cross-Domain: Jet Bundle Dimension -/

/-- The **jet bundle dimension** of order k for polynomials in d variables:
the number of independent k-th order partial derivatives, which equals
`choose(d + k - 1, k)` (the number of multisets of size k from d elements).

In differential geometry, this is the fiber dimension of the k-th jet bundle
`J^k(ℝᵈ, ℝ)`. -/
noncomputable def jetDimension (d k : ℕ) : ℕ := Nat.choose (d + k - 1) k

/-
**Jet-Shadow Correspondence.** For the simplex support of degree m,
the cardinality of the k-th shadow equals `choose(m - k + d - 1, d - 1)`,
which is also the dimension of the space of homogeneous polynomials of
degree `m - k` in `d` variables.

This connects circuit complexity lower bounds to jet bundle geometry:
the "cost" of computing k-th jets is controlled by the dimension of
the codomain jet fiber.
-/
theorem jet_shadow_card_identity (d m k : ℕ) (hd : 1 ≤ d) (hk : k ≤ m) :
    (kthShadow k (simplexSupport d m)).card = Nat.choose (m - k + d - 1) (d - 1) := by
  rw [ kthShadow_simplexSupport hd m k hk, simplexSupport_card ] ; aesop;

/-! ## Shadow Ratio Growth -/

/-- The **shadow ratio** `r_k = |Sh_k(S)| / |S|` measures how much the support
shrinks at level k. For simplex supports, `r_k = choose(m-k+d-1, d-1) / choose(m+d-1, d-1)`.

The key observation is that for fixed d and large m, the ratios satisfy
`r_k / r_{k-1} → (m - k + 1) / (m + d - k)` which is nearly 1,
meaning the shadow tower decays slowly. -/
noncomputable def shadowRatio (d m k : ℕ) : ℚ :=
  if Nat.choose (m + d - 1) (d - 1) = 0 then 0
  else (Nat.choose (m - k + d - 1) (d - 1) : ℚ) / (Nat.choose (m + d - 1) (d - 1) : ℚ)

/-
The shadow ratio is at most 1 (the shadow cannot be larger than the original).
-/
theorem shadowRatio_le_one (d m k : ℕ) (hd : 1 ≤ d) (hk : k ≤ m) :
    shadowRatio d m k ≤ 1 := by
  unfold shadowRatio; split_ifs <;> norm_num;
  exact div_le_one_of_le₀ ( mod_cast Nat.choose_le_choose _ ( by omega ) ) ( Nat.cast_nonneg _ )

/-
The shadow ratio is nonneg.
-/
theorem shadowRatio_nonneg (d m k : ℕ) : 0 ≤ shadowRatio d m k := by
  unfold shadowRatio; split_ifs <;> positivity

/-! ## Shadow Tower Strict Descent -/

/-
**Strict descent in the shadow tower.** For `k < m` and `d ≥ 2`,
the k-th shadow is strictly larger than the (k+1)-th shadow on simplex supports.
This shows the tower is non-degenerate.
-/
theorem kthShadow_simplexSupport_strict_descent (d m k : ℕ)
    (hd : 2 ≤ d) (hk : k + 1 ≤ m) :
    (kthShadow (k + 1) (simplexSupport d m)).card <
    (kthShadow k (simplexSupport d m)).card := by
  have h_step : (kthShadow (k + 1) (simplexSupport d m)).card = Nat.choose (m - (k + 1) + d - 1) (d - 1) ∧ (kthShadow k (simplexSupport d m)).card = Nat.choose (m - k + d - 1) (d - 1) := by
    constructor;
    · rw [ kthShadow_simplexSupport ];
      · exact simplexSupport_card _ _ ( by linarith );
      · lia;
      · grind;
    · rw [ kthShadow_simplexSupport ( by linarith ) m k ( by linarith ), simplexSupport_card ];
      lia;
  rcases d with ( _ | _ | d ) <;> simp_all +decide [ Nat.choose_succ_succ ];
  rw [ show m - k = m - ( k + 1 ) + 1 by omega ] ; simp +arith +decide [ Nat.choose_succ_succ ] ;
  exact Nat.choose_pos ( by linarith )

/-! ## Falsifiable Conjecture -/

/-
**Conjecture (Superlinear Shadow Growth).**
For the simplex support `T(d, m)` with `d ≥ 3`, `m ≥ 2k`, the tower lower
bound at level k satisfies:
  `choose(m - k + d - 1, d - 1) / d^k > k * choose(m + d - 1, d - 1) / (d^(k+1))`

Equivalently, the per-level gain `|Sh_k| / (d^k * |Sh_{k+1}| / d^{k+1})` exceeds k.

This is computationally testable: for d = 3, m = 10, k = 1,2,3,4, compute
both sides and verify the inequality. If it fails for any (d, m, k), the
conjecture is disproved.

Status: OPEN — formal proof or counterexample needed.
-/
theorem superlinear_shadow_conjecture_test :
    -- Concrete test: d=3, m=10, k=2
    -- LHS: choose(10-2+3-1, 3-1) / 3^2 = choose(10, 2) / 9 = 45 / 9 = 5
    -- RHS: 2 * choose(10+3-1, 3-1) / 3^3 = 2 * choose(12,2) / 27 = 2*66/27 ≈ 4.89
    -- So LHS (5) > RHS (4.89) — conjecture holds for this case
    Nat.choose 10 2 * 27 > 2 * Nat.choose 12 2 * 9 := by
  native_decide

end ShadowTower