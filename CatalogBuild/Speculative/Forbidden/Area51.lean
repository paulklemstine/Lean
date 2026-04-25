/-! # CatalogBuild.Speculative.Forbidden.Area51

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Forbidden.Area51
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8] -/
theorem euclid_infinitude : ∀ n : ℕ, ∃ p, p > n ∧ Nat.Prime p := by
  exact fun n => Nat.exists_infinite_primes ( n + 1 ) |> Exists.imp fun p => by aesop;


/-- [Section: # CatalogBuild.Speculative.Forbidden.Area51
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8] -/
theorem prime_gap_arbitrarily_large :
    ∀ k : ℕ, ∃ n : ℕ, ∀ i : ℕ, i < k → ¬ Nat.Prime (n + i + 2) := by
  intro k; use Nat.factorial ( k + 2 ) !; intro i hi; have := Nat.dvd_factorial ( by linarith ) ( show i + 2 ≤ ( k + 2 ) ! from by linarith [ Nat.self_le_factorial ( k + 2 ) ] ) ; simp_all +decide [ Nat.factorial_succ ] ;
  rw [ show ( ( k + 1 + 1 ) * ( ( k + 1 ) * k ! ) ) ! + i + 2 = ( i + 2 ) * ( ( ( k + 1 + 1 ) * ( ( k + 1 ) * k ! ) ) ! / ( i + 2 ) + 1 ) by linarith [ Nat.div_mul_cancel this ] ] ; exact Nat.not_prime_mul ( by linarith ) ( by linarith [ Nat.div_pos ( Nat.le_of_dvd ( by positivity ) this ) ( by linarith : 0 < i + 2 ) ] ) ;


/-- [Section: # CatalogBuild.Speculative.Forbidden.Area51
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 8] -/
theorem wilson_forward (p : ℕ) (hp : Nat.Prime p) :
    (p - 1).factorial % p = p - 1 := by
  haveI := Fact.mk hp; simp +decide [ ← ZMod.val_natCast, Nat.cast_sub hp.pos ] ; (
  rcases p with ( _ | _ | p ) <;> norm_num at *);


theorem div3_digit_sum (n : ℕ) : n % 3 = (n % 10 + n / 10) % 3 := by
  omega


theorem div9_digit_sum (n : ℕ) : n % 9 = (n % 10 + n / 10) % 9 := by
  omega


theorem sqrt2_irrational : Irrational (Real.sqrt 2) := by
  exact irrational_sqrt_two


theorem pigeonhole_coprime (n : ℕ) (hn : 0 < n)
    (S : Finset ℕ) (hS : S.card = n + 1)
    (hrange : ∀ x ∈ S, 1 ≤ x ∧ x ≤ 2 * n) :
    ∃ a ∈ S, ∃ b ∈ S, a ≠ b ∧ Nat.Coprime a b := by
  -- By the pigeonhole principle, among any $n+1$ numbers from $\{1, \ldots, 2n\}$, there must be two consecutive numbers.
  obtain ⟨a, ha, b, hb, hab⟩ : ∃ a ∈ S, ∃ b ∈ S, a ≠ b ∧ b = a + 1 := by
    by_contra h;
    -- Let's consider the set $T = \{a + 1 \mid a \in S\}$. Since $S$ contains no consecutive integers, $T$ is disjoint from $S$.
    set T := Finset.image (fun a => a + 1) S with hT
    have h_disjoint : Disjoint S T := by
      exact Finset.disjoint_left.mpr fun x hx hx' => by obtain ⟨ y, hy, hy' ⟩ := Finset.mem_image.mp hx'; specialize h; aesop;
    -- Since $S$ and $T$ are disjoint subsets of $\{1, \ldots, 2n+1\}$, their union has size at most $2n+1$.
    have h_union_size : (S ∪ T).card ≤ 2 * n + 1 := by
      exact le_trans ( Finset.card_le_card ( show S ∪ T ⊆ Finset.Icc 1 ( 2 * n + 1 ) from Finset.union_subset ( fun x hx => Finset.mem_Icc.mpr ⟨ by linarith [ hrange x hx ], by linarith [ hrange x hx ] ⟩ ) ( Finset.image_subset_iff.mpr fun x hx => Finset.mem_Icc.mpr ⟨ by linarith [ hrange x hx ], by linarith [ hrange x hx ] ⟩ ) ) ) ( by simp +arith +decide );
    rw [ Finset.card_union_of_disjoint h_disjoint, Finset.card_image_of_injective _ ( add_left_injective _ ) ] at h_union_size ; linarith;
  exact ⟨ a, ha, b, hb, hab.1, by simp +decide [ hab.2 ] ⟩


theorem exists_prime_le (n : ℕ) (hn : 2 ≤ n) : ∃ p, Nat.Prime p ∧ p ≤ n := by
  exact ⟨ 2, Nat.prime_two, hn ⟩


end
