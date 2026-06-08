/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Valuated Matroid Exchange and Tropical Descent Theory

This file develops a **quantitative exchange descent theory** for valuated matroids
in the tropical/min-plus setting. It bridges discrete exchange axioms from matroid
theory with tropical valuation structures, establishing certified termination bounds
for exchange descent processes.

## Main Results

* `exists_exchange_nondecrease` — Quantitative exchange from the axiom
* `tropical_descent_strict` — Strict descent under depth certificate
* `int_descent_bound` — Integer descent telescoping lemma
* `tropical_descent_chain_bound` — Chain length bound via potential drop
* `tropical_exchangeDescent_no_infinite` — No infinite descent chains
* `tropical_depth_certificate_mono` — Depth certificate monotonicity
* `exchange_step_sdiff_eq` — Exchange step symmetric difference identity
* `exchange_step_dist_decrease` — Exchange toward target decreases distance
* `kFoldTropicalConcave_mono` — Cross-domain: tropical concavity hierarchy
* `kfold_concave_induces_exchange_family` — Cross-domain bridge theorem
-/

open Finset

noncomputable section

variable {α : Type*} [DecidableEq α]

/-! ## Core Definitions -/

/-- A **tropical exchange family** on a type `α`. The carrier predicate
identifies feasible bases, and `val` assigns an integer weight. The exchange
axiom requires that for any `x ∈ B₁ \ B₂`, there exists `y ∈ B₂ \ B₁`
preserving feasibility and satisfying a two-basis valuation inequality
(the tropical/M-convex exchange property). -/
structure TropicalExchangeFamily (α : Type*) [DecidableEq α] where
  carrier : Finset α → Prop
  val : Finset α → ℤ
  exchange :
    ∀ {B₁ B₂ : Finset α},
      carrier B₁ → carrier B₂ →
      ∀ ⦃x⦄, x ∈ B₁ \ B₂ →
      ∃ y ∈ B₂ \ B₁,
        carrier (Insert.insert y (B₁.erase x)) ∧
        val B₁ + val B₂ ≤
          val (Insert.insert y (B₁.erase x)) +
          val (Insert.insert x (B₂.erase y))

/-- A **tropical exchange step** from `B` to `B'`. -/
def TropicalExchangeStep (T : TropicalExchangeFamily α) (B B' : Finset α) : Prop :=
  T.carrier B ∧ T.carrier B' ∧
  ∃ x y, x ∈ B ∧ x ∉ B' ∧ y ∉ B ∧ y ∈ B' ∧
    B' = Insert.insert y (B.erase x)

/-- A basis `B` is **Φ-optimal** if it minimizes `Φ` among all feasible bases. -/
def TropicalOptimal (T : TropicalExchangeFamily α) (Φ : Finset α → ℤ)
    (B : Finset α) : Prop :=
  T.carrier B ∧ ∀ B', T.carrier B' → Φ B ≤ Φ B'

/-- The **tropical exchange distance** from `B₁` to `B₂`. -/
def tropicalExchangeDist (B₁ B₂ : Finset α) : ℕ := (B₁ \ B₂).card

/-- A **tropical depth certificate** of order `k` for potential `Φ`.
1. `k ≥ 1` (nontrivial descent speed).
2. Every exchange step from a non-optimal basis decreases `Φ` by at least `k`.
3. `Φ` is bounded below on feasible bases. -/
def TropicalDepthCertificate
    (T : TropicalExchangeFamily α)
    (Φ : Finset α → ℤ) (k : ℕ) : Prop :=
  (1 ≤ k) ∧
  (∀ B B' : Finset α, TropicalExchangeStep T B B' →
    ¬TropicalOptimal T Φ B → Φ B' + (k : ℤ) ≤ Φ B) ∧
  (∃ lb : ℤ, ∀ B, T.carrier B → lb ≤ Φ B)

/-- The initial potential gap. -/
def initialGap (_T : TropicalExchangeFamily α)
    (Φ : Finset α → ℤ) (B₀ : Finset α) (lb : ℤ) : ℕ :=
  (Φ B₀ - lb).toNat

/-! ## Theorem 1: Quantitative Exchange Improvement -/

/-- **Theorem 1.** The quantitative exchange axiom: for any two feasible
bases and any `x ∈ B₁ \ B₂`, there exists an exchange preserving feasibility
and the two-basis valuation inequality. -/
theorem exists_exchange_nondecrease
    (T : TropicalExchangeFamily α)
    {B₁ B₂ : Finset α}
    (h₁ : T.carrier B₁) (h₂ : T.carrier B₂)
    {x : α} (hx : x ∈ B₁ \ B₂) :
    ∃ y ∈ B₂ \ B₁,
      T.carrier (Insert.insert y (B₁.erase x)) ∧
      T.val B₁ + T.val B₂ ≤
        T.val (Insert.insert y (B₁.erase x)) +
        T.val (Insert.insert x (B₂.erase y)) :=
  T.exchange h₁ h₂ hx

/-! ## Theorem 2: Strict Descent Under Certificate -/

/-
**Theorem 2.** Under a depth certificate of order `k`, every exchange step
from a non-Φ-optimal basis strictly decreases `Φ`.
-/
theorem tropical_descent_strict
    (T : TropicalExchangeFamily α)
    (Φ : Finset α → ℤ) (k : ℕ)
    (hcert : TropicalDepthCertificate T Φ k)
    {B B' : Finset α}
    (hstep : TropicalExchangeStep T B B')
    (hnonterm : ¬TropicalOptimal T Φ B) :
    Φ B' < Φ B := by
      linarith [ hcert.2.1 B B' hstep hnonterm, hcert.1 ]

/-! ## Integer Descent Telescoping Lemma -/

/-
Integer descent bound: if `f(i+1) + k ≤ f(i)` for all `i`, then
`f(n) + n * k ≤ f(0)`.
-/
theorem int_descent_bound (f : ℕ → ℤ) (k : ℕ) (_hk : 1 ≤ k)
    (hdec : ∀ i, f (i + 1) + ↑k ≤ f i) :
    ∀ n : ℕ, f n + ↑n * ↑k ≤ f 0 := by
      exact fun n => Nat.recOn n ( by norm_num ) fun n ihn => by push_cast; linarith [ hdec n ] ;

/-! ## Theorem 3: Depth-Sensitive Complexity Bound -/

/-
**Theorem 3 (Chain bound).** Under a depth certificate, any infinite
sequence of exchange steps from non-optimal bases satisfies the telescoping
inequality: after `n` steps, the potential has dropped by at least `n * k`.
-/
theorem tropical_descent_chain_bound
    (T : TropicalExchangeFamily α)
    (Φ : Finset α → ℤ) (k : ℕ)
    (hcert : TropicalDepthCertificate T Φ k)
    (f : ℕ → Finset α)
    (hsteps : ∀ i, TropicalExchangeStep T (f i) (f (i + 1)))
    (hnonopt : ∀ i, ¬TropicalOptimal T Φ (f i)) :
    ∀ n : ℕ, (Φ ∘ f) n + ↑n * ↑k ≤ (Φ ∘ f) 0 := by
      -- Apply the integer descent bound with a = 0, b = n.
      intros n
      apply int_descent_bound (Φ ∘ f) k hcert.left (fun i => hcert.right.left (f i) (f (i + 1)) (hsteps i) (hnonopt i))

/-
**No infinite descent.** Under a depth certificate, there is no
infinite strictly descending exchange chain. Any exchange descent
process must reach an optimal basis in finitely many steps.
-/
theorem tropical_exchangeDescent_no_infinite
    (T : TropicalExchangeFamily α)
    (Φ : Finset α → ℤ) (k : ℕ)
    (hcert : TropicalDepthCertificate T Φ k)
    (f : ℕ → Finset α)
    (hsteps : ∀ i, TropicalExchangeStep T (f i) (f (i + 1)))
    (hnonopt : ∀ i, ¬TropicalOptimal T Φ (f i)) :
    False := by
      -- By the depth certificate, we have that there exists a lower bound `lb` such that `lb ≤ Φ (f n)` for all `n`.
      obtain ⟨lb, hlb⟩ : ∃ lb, ∀ n, lb ≤ Φ (f n) := by
        exact ⟨ hcert.2.2.choose, fun n => hcert.2.2.choose_spec _ ( hsteps n |>.1 ) ⟩;
      -- By the descent bound, we have that for all `n`, `Φ(f n) + n * k ≤ Φ(f 0)`.
      have hdescent : ∀ n, Φ (f n) + n * k ≤ Φ (f 0) := by
        convert tropical_descent_chain_bound T Φ k hcert f hsteps hnonopt using 1;
      exact absurd ( hdescent ( Int.toNat ( Φ ( f 0 ) - lb ) + 1 ) ) ( by push_cast; nlinarith [ Int.self_le_toNat ( Φ ( f 0 ) - lb ), hlb ( Int.toNat ( Φ ( f 0 ) - lb ) + 1 ), hcert.1 ] )

/-! ## Structural Lemmas -/

/-- Exchange distance to self is zero. -/
theorem tropicalExchangeDist_self (B : Finset α) :
    tropicalExchangeDist B B = 0 := by
  simp [tropicalExchangeDist]

/-
**Depth certificate monotonicity.** A certificate of higher depth `k`
implies a certificate of any lower depth `j ≥ 1`.
-/
theorem tropical_depth_certificate_mono
    (T : TropicalExchangeFamily α)
    (Φ : Finset α → ℤ)
    {j k : ℕ} (hj : 1 ≤ j) (hjk : j ≤ k)
    (hcert : TropicalDepthCertificate T Φ k) :
    TropicalDepthCertificate T Φ j := by
      exact ⟨ hj, fun B B' h h' => by linarith [ hcert.2.1 B B' h h' ], hcert.2.2 ⟩

/-! ## Exchange Distance Decrease -/

/-
The symmetric difference after an exchange toward a target equals the
original symmetric difference with the exchanged element removed.
-/
theorem exchange_step_sdiff_eq
    {B Bt : Finset α} {x y : α}
    (hxB : x ∈ B) (hxT : x ∉ Bt)
    (hyB : y ∉ B) (hyT : y ∈ Bt) :
    Insert.insert y (B.erase x) \ Bt = (B \ Bt).erase x := by
      grind

/-
**Exchange toward target decreases distance.** If `x ∈ B \ Bt` and
`y ∈ Bt \ B`, then replacing `x` with `y` strictly decreases the exchange
distance to `Bt`.
-/
theorem exchange_step_dist_decrease
    {B Bt : Finset α} {x y : α}
    (hxB : x ∈ B) (hxT : x ∉ Bt)
    (hyB : y ∉ B) (hyT : y ∈ Bt) :
    tropicalExchangeDist (Insert.insert y (B.erase x)) Bt <
      tropicalExchangeDist B Bt := by
        -- Use exchange_step_sdiff_eq to rewrite the LHS sdiff. Then tropicalExchangeDist (insert y (B.erase x)) Bt = ((B \ Bt).erase x).card.
        simp [tropicalExchangeDist, exchange_step_sdiff_eq hxB hxT hyB hyT];
        exact Finset.card_erase_lt_of_mem ( Finset.mem_sdiff.mpr ⟨ hxB, hxT ⟩ )

/-! ## Cross-Domain Bridge: k-Fold Tropical Concavity -/

/-- **k-fold tropical concavity** hierarchy, analogous to `KFoldLogConcave`. -/
def KFoldTropicalConcave (w : Finset α → ℤ) : ℕ → Prop
  | 0 => True
  | k + 1 =>
    (∀ (B₁ B₂ : Finset α) ⦃x⦄, x ∈ B₁ \ B₂ →
      ∃ y ∈ B₂ \ B₁,
        w B₁ + w B₂ ≤
          w (Insert.insert y (B₁.erase x)) +
          w (Insert.insert x (B₂.erase y))) ∧
    KFoldTropicalConcave w k

/-
Higher depth implies lower depth for tropical concavity.
-/
theorem kFoldTropicalConcave_mono
    {w : Finset α → ℤ}
    {j k : ℕ} (hjk : j ≤ k)
    (hk : KFoldTropicalConcave w k) :
    KFoldTropicalConcave w j := by
      induction' k with k ih generalizing j;
      · aesop;
      · exact ( if hj : j ≤ k then ih hj hk.2 else by rw [ show j = k + 1 by linarith ] ; exact hk )

/-
**Cross-domain theorem.** A 1-fold tropically concave valuation induces
a `TropicalExchangeFamily` on any carrier satisfying the matroid exchange
axiom. This bridges algebraic concavity to tropical optimization.
-/
theorem kfold_concave_induces_exchange_family
    {w : Finset α → ℤ}
    {carrier : Finset α → Prop}
    (hw : KFoldTropicalConcave w 1)
    (hcarrier : ∀ {B₁ B₂ : Finset α}, carrier B₁ → carrier B₂ →
      ∀ ⦃x⦄, x ∈ B₁ \ B₂ →
      ∃ y ∈ B₂ \ B₁, carrier (Insert.insert y (B₁.erase x))) :
    ∃ T : TropicalExchangeFamily α, T.carrier = carrier ∧ T.val = w := by
      refine' ⟨ ⟨ carrier, w, _ ⟩, rfl, rfl ⟩;
      intro B₁ B₂ h₁ h₂ x hx; obtain ⟨ y, hy₁, hy₂ ⟩ := hcarrier h₁ h₂ hx; use y; simp_all +decide [ KFoldTropicalConcave ] ;
      contrapose! hw;
      use {x}, ∅; simp [hx]

/-! ## Verified Descent Chain Checker -/

/-- Check that a list of integers is strictly decreasing. -/
def verifyStrictlyDecreasing : List ℤ → Bool
  | [] => true
  | [_] => true
  | v₁ :: v₂ :: rest => decide (v₂ < v₁) && verifyStrictlyDecreasing (v₂ :: rest)

/-
Correctness of the descent checker for the first step.
-/
theorem verifyStrictlyDecreasing_head {a b : ℤ} {rest : List ℤ}
    (h : verifyStrictlyDecreasing (a :: b :: rest) = true) :
    b < a := by
      exact ( by rw [ show verifyStrictlyDecreasing ( a :: b :: rest ) = ( decide ( b < a ) && verifyStrictlyDecreasing ( b :: rest ) ) by rfl ] at h; aesop )

/-- A verified descent chain checker. -/
def checkDescentChain (vals : List ℤ) : Option ℤ :=
  if verifyStrictlyDecreasing vals then
    match vals with
    | [] => none
    | [_] => some 0
    | v :: rest => some (v - rest.getLast!)
  else none

end