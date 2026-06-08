import Mathlib

/-!
# Dark Mathematics: Fast-Growing Hierarchies and Witness Complexity

This module formalizes the mathematical foundations of "dark theorems" —
statements whose existential quantifiers are provable but whose witnesses
grow so fast that no specific instance can be verified within a bounded system.

## Main Definitions

* `fastGrow` — The fast-growing (Wainer) hierarchy of functions ℕ → ℕ
* `DarknessLevel` — A structure capturing the level of unknowability
* `EventuallyDominates` — Eventual dominance relation on ℕ → ℕ
* `ackermann` — The Ackermann function (shown equal to fastGrow)
* `tower2` — Tower of 2s (tetration)

## Main Results

* `fastGrow_gt` — Each level of fastGrow exceeds its input
* `fastGrow_strictMono` — Each level is strictly monotone
* `fastGrow_level_mono` — Higher levels produce larger values
* `darkness_hierarchy_strict` — The darkness hierarchy is strict
* `ackermann_eq_fastGrow` — Ackermann = fastGrow
* `ackermann_dominates_polynomial` — Ackermann dominates all polynomials
* `ramsey_growth_exceeds_polynomial` — Exponential beats polynomial (Ramsey bridge)
* `diagonal_dominates_all_levels` — n ↦ fastGrow n n dominates every level

## References

* Wainer, S.S. "A classification of the ordinal recursive functions"
* Paris, J. & Harrington, L. "A Mathematical Incompleteness in Peano Arithmetic"
-/

open Nat

/-! ## Part I: The Fast-Growing Hierarchy -/

/-- The fast-growing hierarchy (Wainer/Ackermann hierarchy).
Level 0 is the successor function. Level k+1 iterates level k.
This hierarchy captures the growth rates corresponding to
provability strength in fragments of arithmetic. -/
def fastGrow : ℕ → ℕ → ℕ
  | 0, n => n + 1
  | k + 1, 0 => fastGrow k 1
  | k + 1, n + 1 => fastGrow k (fastGrow (k + 1) n)

/-
Level 1 computes n + 2.
-/
theorem fastGrow_one_eq (n : ℕ) : fastGrow 1 n = n + 2 := by
  induction n <;> simp +arith +decide [ *, fastGrow ]

/-- **Key theorem**: fastGrow k n > n for all k and n.
Proven by well-founded induction on the recursive structure. -/
theorem fastGrow_gt (k n : ℕ) : fastGrow k n > n := by
  induction k, n using fastGrow.induct with
  | case1 n => simp [fastGrow]
  | case2 k ih => unfold fastGrow; omega
  | case3 k n ih_inner ih_outer => unfold fastGrow; omega

/-
fastGrow k is strictly monotone in its second argument.
-/
theorem fastGrow_strictMono (k : ℕ) : StrictMono (fastGrow k) := by
  refine' strictMono_nat_of_lt_succ fun n => _;
  -- We proceed by induction on $k$.
  induction' k with k ih generalizing n;
  · grind +locals;
  · -- By definition of `fastGrow`, we have `fastGrow (k + 1) (n + 1) = fastGrow k (fastGrow (k + 1) n)`.
    have h_def : fastGrow (k + 1) (n + 1) = fastGrow k (fastGrow (k + 1) n) := by
      -- By definition of fastGrow, we have fastGrow (k + 1) (n + 1) = fastGrow k (fastGrow (k + 1) n) by the recursive definition.
      rw [fastGrow];
    -- By definition of `fastGrow`, we have `fastGrow k (fastGrow (k + 1) n) > fastGrow (k + 1) n`.
    have h_gt : fastGrow k (fastGrow (k + 1) n) > fastGrow (k + 1) n := by
      -- By definition of `fastGrow`, we have `fastGrow k (fastGrow (k + 1) n) > fastGrow (k + 1) n` because `fastGrow k` is strictly increasing.
      apply fastGrow_gt;
    grind

/-
Monotonicity in the level: higher levels produce larger values for n ≥ 1.
-/
theorem fastGrow_level_mono (k n : ℕ) (hn : n ≥ 1) :
    fastGrow (k + 1) n ≥ fastGrow k n := by
      induction' n with n ih <;> simp_all +arith +decide;
      rw [ show fastGrow ( k + 1 ) ( n + 1 ) = fastGrow k ( fastGrow ( k + 1 ) n ) from _ ];
      · rcases n with ( _ | n ) <;> simp_all +arith +decide;
        · exact fastGrow_strictMono k |> fun h => h.monotone ( show 1 ≤ fastGrow ( k + 1 ) 0 from Nat.one_le_of_lt ( fastGrow_gt _ _ ) );
        · exact fastGrow_strictMono k |> fun h => h.monotone ( by linarith [ fastGrow_gt k ( n + 1 ) ] );
      · rw [fastGrow]

/-! ## Part II: Darkness Hierarchy Structure -/

/-- A darkness level captures the growth rate of minimum witnesses.
A statement is "dark at level k" if the minimum witness for input n
is bounded below by fastGrow k n — meaning witnesses grow so fast
they escape any bounded verification system. -/
structure DarknessLevel where
  /-- The level in the fast-growing hierarchy -/
  level : ℕ
  /-- The witness bound function -/
  witnessBound : ℕ → ℕ
  /-- The bound grows at least as fast as fastGrow at this level -/
  growth_lower : ∀ n, witnessBound n ≥ fastGrow level n

/-- The canonical darkness level at level k uses fastGrow k itself. -/
def canonicalDarkness (k : ℕ) : DarknessLevel where
  level := k
  witnessBound := fastGrow k
  growth_lower := fun _ => le_refl _

/-- A function f eventually dominates g. -/
def EventuallyDominates (f g : ℕ → ℕ) : Prop :=
  ∃ N, ∀ n, n ≥ N → f n > g n

/-
EventuallyDominates is transitive.
-/
theorem EventuallyDominates.trans {f g h : ℕ → ℕ}
    (hfg : EventuallyDominates f g) (hgh : EventuallyDominates g h) :
    EventuallyDominates f h := by
      exact ⟨ Max.max hfg.choose hgh.choose, fun n hn => by linarith [ hfg.choose_spec n ( le_of_max_le_left hn ), hgh.choose_spec n ( le_of_max_le_right hn ) ] ⟩

/-
Darkness at level k+1 strictly dominates darkness at level k.
This is the fundamental strictness theorem of the darkness hierarchy.
-/
theorem darkness_hierarchy_strict (k : ℕ) :
    EventuallyDominates (fastGrow (k + 1)) (fastGrow k) := by
      use 2;
      intro n hn;
      induction' n with n ih;
      · contradiction;
      · -- By definition of fastGrow, we have fastGrow (k + 1) (n + 1) = fastGrow k (fastGrow (k + 1) n).
        have h_def : fastGrow (k + 1) (n + 1) = fastGrow k (fastGrow (k + 1) n) := by
          rw [fastGrow];
        rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
        · refine' strictMono_nat_of_lt_succ ( fun n => _ ) _;
          · exact fastGrow_strictMono k ( Nat.lt_succ_self _ );
          · refine' Nat.recOn k _ _ <;> simp +arith +decide [ * ];
            · native_decide +revert;
            · intro n hn; exact le_trans hn ( fastGrow_level_mono _ _ ( by norm_num ) ) ;
        · exact fastGrow_strictMono k ( by linarith [ fastGrow_gt k ( n + 2 ) ] )

/-! ## Part III: Ackermann Function -/

/-- The Ackermann function. -/
def ackermann : ℕ → ℕ → ℕ
  | 0, n => n + 1
  | m + 1, 0 => ackermann m 1
  | m + 1, n + 1 => ackermann m (ackermann (m + 1) n)

/-- The Ackermann function equals fastGrow. -/
theorem ackermann_eq_fastGrow (k n : ℕ) : ackermann k n = fastGrow k n := by
  induction k, n using ackermann.induct with
  | case1 n => simp [ackermann, fastGrow]
  | case2 k ih => simp [ackermann, fastGrow]; exact ih
  | case3 k n ih1 ih2 =>
    simp [ackermann, fastGrow]
    rw [ih2, ih1]

/-
Helper: fastGrow at level k+1 is at least fastGrow 3 for k ≥ 1 and n ≥ 1.
-/
theorem fastGrow_ge_level_three (k n : ℕ) (hk : k ≥ 3) (hn : n ≥ 1) :
    fastGrow k n ≥ fastGrow 3 n := by
      induction' hk with k hk ih;
      · rfl;
      · exact le_trans ih ( fastGrow_level_mono _ _ hn )

/-
Helper: 2^(n+3) eventually exceeds n^d + 3 for any fixed d.
-/
theorem exp_eventually_exceeds_poly (d : ℕ) :
    ∃ N, ∀ n, n ≥ N → 2 ^ (n + 3) > n ^ d + 3 := by
      -- We can prove this using the fact that exponential functions grow faster than any polynomial function. Specifically, we can use the fact that $2^n$ grows faster than any polynomial function.
      have h_exp_growth : Filter.Tendsto (fun n : ℕ => 2 ^ n / (n ^ d : ℝ)) Filter.atTop Filter.atTop := by
        -- We can convert this limit into a form that is easier to handle by substituting $m = n \log 2$.
        suffices h_log : Filter.Tendsto (fun m : ℝ => Real.exp m / m ^ d) Filter.atTop Filter.atTop by
          have h_subst : Filter.Tendsto (fun n : ℕ => Real.exp (n * Real.log 2) / (n * Real.log 2) ^ d) Filter.atTop Filter.atTop := by
            exact h_log.comp <| tendsto_natCast_atTop_atTop.atTop_mul_const <| Real.log_pos one_lt_two;
          convert h_subst.const_mul_atTop ( show 0 < ( Real.log 2 ) ^ d by positivity ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ] ; ring;
          norm_num [ mul_assoc, ne_of_gt, Real.log_pos ];
        exact Real.tendsto_exp_div_pow_atTop _;
      have := h_exp_growth.eventually_gt_atTop 8;
      obtain ⟨ N, hN ⟩ := Filter.eventually_atTop.mp this;
      exact ⟨ N + 1, fun n hn => by have := hN n ( by linarith ) ; rw [ lt_div_iff₀ ( pow_pos ( Nat.cast_pos.mpr <| by linarith ) _ ) ] at this; norm_cast at *; ring_nf at *; nlinarith [ pow_pos ( by linarith : 0 < n ) d ] ⟩

/-
Helper: fastGrow 3 n > n^d for large n.
-/
theorem fastGrow_three_dominates_poly (d : ℕ) :
    ∃ N, ∀ n, n ≥ N → fastGrow 3 n > n ^ d := by
      -- By definition of `fastGrow`, we know that `fastGrow 3 n = 2 ^ (n + 3) - 3`.
      have h_fastGrow_3 : ∀ n, fastGrow 3 n = 2 ^ (n + 3) - 3 := by
        intro n
        induction' n with n ih;
        · native_decide +revert;
        · have h_ind : ∀ m, fastGrow 2 m = 2 * m + 3 := by
            intro m; induction' m with m ih <;> simp_all +arith +decide;
            · native_decide +revert;
            · -- By definition of fastGrow, we have fastGrow 2 (m + 1) = fastGrow 1 (fastGrow 2 m).
              have h_def : fastGrow 2 (m + 1) = fastGrow 1 (fastGrow 2 m) := by
                -- By definition of `fastGrow`, we have `fastGrow 2 (m + 1) = fastGrow 1 (fastGrow 2 m)` because `fastGrow (k + 1) (n + 1) = fastGrow k (fastGrow (k + 1) n)`.
                rw [fastGrow]
              rw [h_def, ih]
              simp [fastGrow_one_eq];
          -- Apply the induction hypothesis to rewrite `fastGrow 3 n`.
          have h_step : fastGrow 3 (n + 1) = fastGrow 2 (fastGrow 3 n) := by
            rw [ fastGrow ];
          grind;
      -- By definition of `exp_eventually �_ex�ceeds_poly`, there exists an $N$ such that for all $n \geq N$, $2^{n+3} > n^d + 3$.
      obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, 2 ^ (n + 3) > n ^ d + 3 := exp_eventually_exceeds_poly d;
      exact ⟨ N, fun n hn => by rw [ h_fastGrow_3 ] ; exact lt_tsub_iff_right.mpr ( hN n hn ) ⟩

/-
The Ackermann function eventually dominates any polynomial.
This is the key property connecting computability theory to the
darkness hierarchy.
-/
theorem ackermann_dominates_polynomial (d : ℕ) :
    EventuallyDominates (ackermann (d + 2)) (fun n => n ^ (d + 1)) := by
      use (fastGrow_three_dominates_poly (d + 1)).choose + 1;
      intro n hn; have := Exists.choose_spec ( fastGrow_three_dominates_poly ( d + 1 ) ) n ( by linarith ) ; simp_all +decide [ ackermann_eq_fastGrow ] ;
      by_cases hd : d + 2 ≥ 3;
      · exact lt_of_lt_of_le this ( fastGrow_ge_level_three _ _ hd ( by linarith ) );
      · rcases d with ( _ | _ | d ) <;> simp_all +arith +decide;
        refine' Nat.recOn n _ _ <;> simp +arith +decide [ * ];
        · native_decide +revert;
        · exact fun n hn => Nat.succ_le_of_lt ( lt_of_le_of_lt ( Nat.succ_le_of_lt hn ) ( fastGrow_strictMono _ ( Nat.lt_succ_self _ ) ) )

/-! ## Part IV: Ramsey Theory Connection (Cross-Domain Bridge) -/

/-
Exponential growth 2^(k/2) ≥ k for k ≥ 6.
This is a key ingredient in Erdős's probabilistic lower bound for
Ramsey numbers R(k,k).
-/
theorem exp_half_ge_linear :
    ∀ k : ℕ, k ≥ 6 → 2 ^ (k / 2) ≥ k := by
      intro k hk; induction' k using Nat.strong_induction_on with k ih; rcases k with ( _ | _ | k ) <;> simp +arith +decide [ Nat.pow_succ ] at *;
      rcases hk with ( _ | _ | _ | _ | _ | k ) <;> simp +arith +decide [ Nat.pow_succ' ] at *;
      grind +ring

/-
**Cross-domain bridge** (Combinatorics ↔ Logic):
Exponential growth eventually exceeds any polynomial.
This formalizes why Ramsey-type witnesses are "dark at level ≥ 1":
the exponential lower bound on R(k,k) means witnesses grow faster
than polynomial, placing them at least at the level of fastGrow 2
in the darkness hierarchy.
-/
theorem ramsey_growth_exceeds_polynomial (d : ℕ) :
    ∃ N, ∀ k, k ≥ N → 2 ^ (k / 2) > k ^ d := by
      -- We'll use that exponential functions grow faster than polynomial functions.
      have h_exp_growth : Filter.Tendsto (fun k : ℕ => k ^ d / (2 : ℝ) ^ (k / 2)) Filter.atTop (nhds 0) := by
        -- We can use the fact that $k^d / 2^{k/2}$ tends to $0$ as $k$ tends to infinity.
        have h_lim : Filter.Tendsto (fun k : ℕ => (k : ℝ) ^ d / (Real.sqrt 2) ^ k) Filter.atTop (nhds 0) := by
          -- Let $y = k \ln \sqrt{2}$, therefore the limit becomes $\lim_{y \to \infty} \frac{y^d}{e^y}$.
          suffices h_log : Filter.Tendsto (fun y : ℝ => y ^ d / Real.exp y) Filter.atTop (nhds 0) by
            have h_subst : Filter.Tendsto (fun k : ℕ => (k * Real.log (Real.sqrt 2)) ^ d / Real.exp (k * Real.log (Real.sqrt 2))) Filter.atTop (nhds 0) := by
              exact h_log.comp <| tendsto_natCast_atTop_atTop.atTop_mul_const <| Real.log_pos <| Real.lt_sqrt_of_sq_lt <| by norm_num;
            convert h_subst.div_const ( Real.log ( Real.sqrt 2 ) ^ d ) using 2 <;> norm_num [ Real.exp_nat_mul, Real.exp_log ] ; ring;
            norm_num [ Real.log_sqrt ];
            norm_num [ mul_assoc, ← mul_pow ];
          simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero d;
        have h_exp_poly : Filter.Tendsto (fun k : ℕ => (k : ℝ) ^ d / (Real.sqrt 2) ^ (2 * (k / 2))) Filter.atTop (nhds 0) := by
          have h_exp_poly : Filter.Tendsto (fun k : ℕ => (k : ℝ) ^ d / (Real.sqrt 2) ^ k * (Real.sqrt 2) ^ (k % 2)) Filter.atTop (nhds 0) := by
            rw [ tendsto_zero_iff_norm_tendsto_zero ] at *;
            simp_all +decide [ abs_div, abs_mul ];
            exact squeeze_zero ( fun _ => by positivity ) ( fun x => mul_le_mul_of_nonneg_left ( show |Real.sqrt 2| ^ ( x % 2 ) ≤ |Real.sqrt 2| by exact le_trans ( pow_le_pow_right₀ ( by rw [ abs_of_nonneg ] <;> norm_num [ Real.sqrt_nonneg ] ) ( Nat.le_of_lt_succ ( Nat.mod_lt _ ( by norm_num ) ) ) ) ( by norm_num ) ) ( by positivity ) ) ( by simpa using h_lim.mul_const _ );
          refine h_exp_poly.congr' ?_;
          filter_upwards [ Filter.eventually_gt_atTop 0 ] with k hk using by rw [ show ( Real.sqrt 2 ) ^ k = ( Real.sqrt 2 ) ^ ( 2 * ( k / 2 ) ) * ( Real.sqrt 2 ) ^ ( k % 2 ) by rw [ ← pow_add, Nat.div_add_mod ] ] ; rw [ div_mul_eq_mul_div, div_eq_div_iff ] <;> ring <;> positivity;
        convert h_exp_poly using 2 ; norm_num [ pow_mul ];
      exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ ↦ ⟨ N, fun k hk ↦ by have := hN k hk; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩

/-! ## Part V: Tower Functions and Level 2+ -/

/-- Tower of 2s of height n: 2↑↑n. -/
def tower2 : ℕ → ℕ
  | 0 => 1
  | n + 1 => 2 ^ tower2 n

/-
tower2 is strictly increasing.
-/
theorem tower2_strictMono : StrictMono tower2 := by
  refine' strictMono_nat_of_lt_succ fun n => _;
  induction n <;> simp_all +arith +decide [ pow_succ' ];
  exact pow_lt_pow_right₀ ( by decide ) ‹_›

/-
tower2 n ≥ n + 1.
-/
theorem tower2_ge_succ (n : ℕ) : tower2 n ≥ n + 1 := by
  induction' n with n ih;
  · decide +revert;
  · refine' le_trans _ ( Nat.pow_le_pow_right ( by decide ) ih );
    exact Nat.recOn n ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ' ] at * ; linarith;

/-
fastGrow 2 n = 2n + 3 (the Ackermann level 2 formula).
-/
theorem fastGrow_two_eq (n : ℕ) : fastGrow 2 n = 2 * n + 3 := by
  induction' n with n ih;
  · native_decide +revert;
  · convert congr_arg ( fun x => x + 2 ) ih using 1;
    convert fastGrow_one_eq ( fastGrow 2 n ) using 1;
    -- By definition of `fastGrow`, we have `fastGrow 2 (n + 1) = fastGrow 1 (fastGrow 2 n)`.
    rw [fastGrow]

/-
fastGrow 3 n = 2^(n+3) - 3 (exponential growth at level 3).
-/
theorem fastGrow_three_eq (n : ℕ) : fastGrow 3 n = 2 ^ (n + 3) - 3 := by
  induction' n with n ih <;> simp_all +decide [ Nat.pow_succ' ];
  · native_decide +revert;
  · convert fastGrow_two_eq ( fastGrow 3 n ) using 1;
    · -- By definition of `fastGrow`, we have `fastGrow (k + 1) (n + 1) = fastGrow k (fastGrow (k + 1) n)`.
      rw [fastGrow];
    · grind

/-! ## Part VI: The Diagonal and Absolute Darkness -/

/-
The diagonal function n ↦ fastGrow n n grows faster than
any fixed level of the hierarchy. This is the key property that
makes the Ackermann function non-primitive-recursive, and
corresponds to "absolute darkness" — a theorem so dark that
no fixed level captures its witness complexity.
-/
theorem diagonal_dominates_all_levels (k : ℕ) :
    EventuallyDominates (fun n => fastGrow n n) (fastGrow k) := by
      -- By induction on $n - k �$,� we can show that $fastGrow n n \geq fastGrow (k+1) n$ for $n \geq k+1$.
      have h_ind : ∀ n ≥ k + 1, fastGrow n n ≥ fastGrow (k + 1) n := by
        intro n hn_ge_k1
        have h_ind : ∀ m ≥ k + 1, fastGrow m n ≥ fastGrow (k + 1) n := by
          intro m hm; induction hm <;> simp_all +decide [ fastGrow_level_mono ] ;
          refine' le_trans ‹_› _;
          exact fastGrow_level_mono _ _ ( by linarith );
        exact h_ind n hn_ge_k1;
      obtain ⟨ N, hN ⟩ := darkness_hierarchy_strict k;
      exact ⟨ Max.max ( k + 1 ) N, fun n hn => lt_of_lt_of_le ( hN n ( le_trans ( le_max_right _ _ ) hn ) ) ( h_ind n ( le_trans ( le_max_left _ _ ) hn ) ) ⟩

/-
Composition of witness bounds from two levels yields at least
the faster growth rate.
-/
theorem darkness_composition_bound (k₁ k₂ n : ℕ) :
    fastGrow k₁ (fastGrow k₂ n) ≥ fastGrow k₁ n := by
      exact ( fastGrow_strictMono k₁ ).monotone ( by linarith [ fastGrow_gt k₂ n ] )

/-! ## Part VII: Falsifiable Conjecture -/

/-
**Conjecture** (Darkness Density at Level 1):
fastGrow 2 n > 2 * fastGrow 1 n for all n ≥ 0.

This asserts that the gap between consecutive darkness levels
is already a factor of 2 starting from level 1 → 2.
Computational test: fastGrow 2 n = 2n+3, fastGrow 1 n = n+2,
so 2n+3 > 2(n+2) = 2n+4 fails. So the conjecture as stated is FALSE.
We formalize its negation, showing the precise relationship.
-/
theorem darkness_density_level_one_fails :
    ¬ (∀ n : ℕ, fastGrow 2 n > 2 * fastGrow 1 n) := by
      push_neg;
      exists 0;
      native_decide +revert

/-
The corrected density statement: at level 2→3,
the gap does eventually become multiplicatively large.
fastGrow 3 n = 2^(n+3) - 3, fastGrow 2 n = 2n + 3.
For n ≥ 2: 2^(n+3) - 3 > 2(2n+3) = 4n+6, which holds.
-/
theorem darkness_density_level_two :
    ∃ N : ℕ, ∀ n : ℕ, n ≥ N → fastGrow 3 n > 2 * fastGrow 2 n := by
      -- For n ≥ 2: fastGrow 3 n = 2^(n+3) - 3 and 2 * fastGrow 2 n = 2*(2n+3) = 4n+6. Need 2^(n+3) - 3 > 4n+6, i.e. 2^(n+3) > 4n+9.
      have h2 : ∀ n ≥ 2, 2 ^ (n + 3) > 4 * n + 9 := by
        exact fun n hn => by induction hn <;> norm_num [ pow_succ' ] at * ; linarith;
      use 2;
      intro n hn; rw [ fastGrow_three_eq, fastGrow_two_eq ] ; specialize h2 n hn; omega;

/-- **Falsifiable conjecture**: For all k ≥ 2, there exists N such that
fastGrow (k+1) n > 2 * fastGrow k n for all n ≥ N.
Prediction: N ≤ 10 for all k ≤ 100. -/
def darknessDensityConjecture : Prop :=
  ∀ k : ℕ, k ≥ 2 → ∃ N : ℕ, N ≤ 10 ∧ ∀ n : ℕ, n ≥ N →
    fastGrow (k + 1) n > 2 * fastGrow k n