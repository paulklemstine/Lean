/-! # CatalogBuild.Best.11_CongruenceOfSquaresFactoring

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 14
-/

import Mathlib

theorem congruence_of_squares_factoring
    {n x y : ℤ} (hn : 1 < n)
    (hcong : (n : ℤ) ∣ x ^ 2 - y ^ 2)
    (hne_sub : ¬ (n : ℤ) ∣ x - y)
    (hne_add : ¬ (n : ℤ) ∣ x + y) :
    1 < Int.gcd (x - y) n ∧ Int.gcd (x - y) n < n.natAbs := by
  refine' ⟨ Nat.lt_of_le_of_ne ( Nat.pos_of_dvd_of_pos ( Int.natAbs_dvd_natAbs.mpr ( Int.gcd_dvd_right _ _ ) ) ( Int.natAbs_pos.mpr ( by linarith ) ) ) ( Ne.symm _ ), _ ⟩;
  · contrapose! hne_add;
    exact Int.dvd_of_dvd_mul_right_of_gcd_one ( by convert hcong using 1; ring ) ( Int.gcd_comm _ _ ▸ hne_add );
  · refine' lt_of_le_of_ne ( Nat.le_of_dvd ( Int.natAbs_pos.mpr ( by linarith ) ) ( Int.natCast_dvd.mp ( Int.gcd_dvd_right _ _ ) ) ) fun con => hne_sub _;
    exact Int.dvd_trans ( by norm_num ) ( con ▸ Int.gcd_dvd_left _ _ )


theorem congruence_of_squares_cofactor
    {n x y : ℤ} (hn : 1 < n)
    (hcong : (n : ℤ) ∣ x ^ 2 - y ^ 2) :
    (n : ℤ) ∣ ↑(Int.gcd (x - y) n) * ↑(Int.gcd (x + y) n) := by
  grind +suggestions


theorem gcd_sub_dvd_n (x y n : ℤ) : ↑(Int.gcd (x - y) n) ∣ n := by
  exact Int.gcd_dvd_right _ _


theorem gcd_product_bound
    {n x y : ℤ} (hn : 0 < n)
    (hcong : (n : ℤ) ∣ x ^ 2 - y ^ 2) :
    (Int.gcd (x - y) n : ℤ) * (Int.gcd (x + y) n : ℤ) ≤ n ^ 2 := by
  nlinarith [ Int.le_of_dvd ( by positivity ) ( Int.gcd_dvd_right ( x - y ) n ), Int.le_of_dvd ( by positivity ) ( Int.gcd_dvd_right ( x + y ) n ) ]


/-- A natural number is B-smooth if all its prime factors are ≤ B. -/
def isSmooth (B : ℕ) (n : ℕ) : Prop :=
  ∀ p : ℕ, p.Prime → p ∣ n → p ≤ B


theorem isSmooth_one (B : ℕ) : isSmooth B 1 := by
  exact fun p pp dp => pp.not_dvd_one.elim dp


theorem isSmooth_mul {B m n : ℕ} (hm : isSmooth B m) (hn : isSmooth B n) :
    isSmooth B (m * n) := by
  intro p pp dp; rw [ Nat.Prime.dvd_mul pp ] at dp; aesop;


theorem isSmooth_mono {B B' n : ℕ} (h : B ≤ B') (hn : isSmooth B n) :
    isSmooth B' n := by
  exact fun p pp dp => le_trans ( hn p pp dp ) h


theorem isSmooth_prime_iff {B p : ℕ} (hp : p.Prime) :
    isSmooth B p ↔ p ≤ B := by
  exact ⟨ fun h => h p hp dvd_rfl, fun h q hq hqp => by rw [ Nat.prime_dvd_prime_iff_eq ] at hqp <;> aesop ⟩


/-- The factor base: the set of primes up to bound B. -/
def factorBase (B : ℕ) : Finset ℕ :=
  (Finset.range (B + 1)).filter Nat.Prime


theorem factorBase_prime {B p : ℕ} (hp : p ∈ factorBase B) : p.Prime := by
  exact Finset.mem_filter.mp hp |>.2


theorem factorBase_le {B p : ℕ} (hp : p ∈ factorBase B) : p ≤ B := by
  exact Finset.mem_range_succ_iff.mp ( Finset.mem_filter.mp hp |>.1 )


theorem smooth_factors_in_base {B n : ℕ} (hn : 0 < n) (hs : isSmooth B n) :
    ∀ p : ℕ, p.Prime → p ∣ n → p ∈ factorBase B := by
  exact fun p pp dp => Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( Nat.lt_succ_of_le ( hs p pp dp ) ), pp ⟩


theorem relations_exceed_base_gives_dependency
    {k : ℕ} (relations : Fin (k + 1) → Fin k → ZMod 2) :
    ∃ S : Finset (Fin (k + 1)), S.Nonempty ∧
      ∀ j : Fin k, ∑ i ∈ S, relations i j = 0 := by
  by_contra h;
  -- By the pigeonhole principle, since there are $k+1$ vectors in a $k$-dimensional space, there must be a nontrivial linear combination that sums to zero.
  have h_pigeonhole : ∃ (s : Fin (k + 1) → ZMod 2), s ≠ 0 ∧ ∑ i, s i • relations i = 0 := by
    have h_pigeonhole : ∃ (s : Fin (k + 1) → ZMod 2), s ≠ 0 ∧ ∑ i, s i • relations i = 0 := by
      have h_rank : Module.rank (ZMod 2) (Fin k → ZMod 2) < k + 1 := by
        erw [ rank_fun' ] ; norm_cast ; norm_num
      have h_linear_dep : ¬LinearIndependent (ZMod 2) relations := by
        intro h_lin_ind
        have h_card : Module.rank (ZMod 2) (Fin k → ZMod 2) ≥ k + 1 := by
          have := h_lin_ind;
          have := this.cardinal_lift_le_rank;
          aesop;
        exact not_lt_of_ge h_card h_rank;
      rw [ Fintype.not_linearIndependent_iff ] at h_linear_dep ; tauto;
    exact h_pigeonhole;
  obtain ⟨ s, hs_ne_zero, hs_sum_zero ⟩ := h_pigeonhole;
  refine' h ⟨ Finset.univ.filter fun i => s i ≠ 0, _, _ ⟩ <;> simp_all +decide [ funext_iff, Finset.sum_filter ];
  · exact ⟨ hs_ne_zero.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hs_ne_zero.choose_spec ⟩ ⟩;
  · intro j; specialize hs_sum_zero j; rw [ Finset.sum_congr rfl fun i hi => by rw [ show s i * relations i j = if s i = 0 then 0 else relations i j by cases Fin.exists_fin_two.mp ⟨ s i, rfl ⟩ <;> aesop ] ] at hs_sum_zero; aesop;
