/-! # CatalogBuild.NumberTheory.Factoring.Basic

Auto-generated from theorem catalog database.
Domain: NumberTheory/Factoring
Declarations: 5
-/

import Mathlib

noncomputable section

def IsCollision {α : Type*} [DecidableEq α] (f : α → α) (x₀ : α) (i j : ℕ) : Prop :=
  i < j ∧ f^[i] x₀ = f^[j] x₀

/-- The standard quadratic map used in Pollard's rho: f(x) = x² + c in ℤ/nℤ. -/

noncomputable def reductionMap {n p : ℕ} (hp : p ∣ n) [NeZero n] [NeZero p] :
    ZMod n →+* ZMod p :=
  ZMod.castHom hp (ZMod p)

/-
The quadratic map commutes with reduction modulo divisors:
    if π : ℤ/nℤ → ℤ/pℤ is the natural map and f(x) = x²+c, then
    π(f(x)) = f(π(x)).
-/

theorem pollardMap_commutes_with_reduction {n p : ℕ} (hp : p ∣ n)
    [NeZero n] [NeZero p] (c : ZMod n) (x : ZMod n) :
    reductionMap hp (pollardMap n c x) =
      pollardMap p (reductionMap hp c) (reductionMap hp x) := by
  unfold pollardMap;
  grind +revert

/-
If per_n is a period of the orbit of f in ℤ/nℤ (beyond some tail), then per_n
    is also a period of the projected orbit in ℤ/pℤ.
-/

theorem orbit_period_projects {n p : ℕ} (hp : p ∣ n) [NeZero n] [NeZero p]
    (f : ZMod n → ZMod n) (g : ZMod p → ZMod p) (x₀ : ZMod n)
    (hcomm : ∀ x, reductionMap hp (f x) = g (reductionMap hp x))
    (tau per_n : ℕ) (hper_n : 0 < per_n)
    (hperiod_n : ∀ i, tau ≤ i → f^[i] x₀ = f^[i + per_n] x₀) :
    ∀ i, tau ≤ i →
      g^[i] (reductionMap hp x₀) = g^[i + per_n] (reductionMap hp x₀) := by
  -- By induction on $k$, we show that reductionMap hp (f^[k] x₀) = g^[k] (reductionMap hp x₀).
  have h_ind : ∀ k : ℕ, reductionMap hp (f^[k] x₀) = g^[k] (reductionMap hp x₀) := by
    intro k; induction k <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  exact fun i hi => h_ind i ▸ h_ind ( i + per_n ) ▸ hperiod_n i hi ▸ rfl

/-! ## Part V: Floyd's Cycle Detection -/

/-
Floyd's tortoise-and-hare algorithm: if there is a collision at (i, j) with j ≤ bound,
    then there exists k ≤ bound such that f^[k] x₀ = f^[2*k] x₀.
-/

theorem gcd_of_product_dvd {n : ℕ} (hn : 1 < n)
    (vals : Fin k → ℤ) (p : ℕ) (hp : Nat.Prime p) (hpn : p ∣ n)
    (j : Fin k) (hdvd : (p : ℤ) ∣ vals j) :
    1 < Int.gcd (∏ i, vals i) n := by
  refine' lt_of_lt_of_le hp.one_lt ( Nat.le_of_dvd ( Int.gcd_pos_of_ne_zero_right _ ( by positivity ) ) ( Nat.dvd_gcd ( Int.natCast_dvd.mp ( dvd_trans hdvd <| Finset.dvd_prod_of_mem _ <| Finset.mem_univ _ ) ) hpn ) )


end
