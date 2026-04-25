/-! # CatalogBuild.Speculative.Other.MetaOracleHypotheses

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 17
-/

import Mathlib

noncomputable section

/-- The Goldbach representation count: number of ways to write n as p + q
with p ≤ q and both prime. -/
noncomputable def goldbachRepCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun p =>
    p.Prime ∧ (n - p).Prime ∧ p ≤ n - p ∧ p ≤ n)).card


/-- Distance from a real number to the nearest integer. -/
noncomputable def fracDist (x : ℝ) : ℝ :=
  min (Int.fract x) (1 - Int.fract x)


/-- The Lonely Runner bound: for n runners, each achieves distance ≥ 1/(n+1). -/
noncomputable def lonelyRunnerBound (n : ℕ) : ℝ := 1 / (n + 1 : ℝ)


/-- [Section: # CatalogBuild.Speculative.Other.MetaOracleHypotheses
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 17] -/
theorem lonely_runner_two : ∃ t : ℝ, fracDist t ≥ 1/3 ∧ fracDist (2 * t) ≥ 1/3 := by
  -- Consider $t = 1/3$.
  use 1 / 3;
  unfold fracDist; norm_num;


/-- For n = 3: 4/3 = 1/1 + 1/4 + 1/12. -/
theorem erdos_straus_three : isErdosStrausDecomp 3 1 4 12 := by
  unfold isErdosStrausDecomp
  norm_num


/-- For n = 5: 4/5 = 1/2 + 1/4 + 1/20 -/
theorem erdos_straus_five : isErdosStrausDecomp 5 2 4 20 := by
  unfold isErdosStrausDecomp
  norm_num


/-- For n = 7: 4/7 = 1/2 + 1/15 + 1/210... let's just check a few. -/
theorem erdos_straus_seven : isErdosStrausDecomp 7 2 28 28 := by
  unfold isErdosStrausDecomp
  norm_num


/-- [Section: # CatalogBuild.Speculative.Other.MetaOracleHypotheses
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 17] -/
theorem erdos_straus_even (k : ℕ) (hk : 0 < k) :
    isErdosStrausDecomp (2 * k) k (2 * k) (2 * k) := by
      constructor <;> try linarith;
      exact ⟨ by positivity, by positivity, by linarith, by linarith, by push_cast; ring ⟩


/-- π(n) ≤ n + 1 for all n. -/
theorem primeCount_le (n : ℕ) : primeCount n ≤ n + 1 := by
  unfold primeCount
  calc ((Finset.range (n + 1)).filter Nat.Prime).card
      ≤ (Finset.range (n + 1)).card := Finset.card_filter_le _ _
    _ = n + 1 := Finset.card_range (n + 1)


/-- There are no primes ≤ 1. -/
theorem primeCount_one : primeCount 1 = 0 := by
  unfold primeCount
  native_decide


/-- [Section: # CatalogBuild.Speculative.Other.MetaOracleHypotheses
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 17] -/
theorem primeCount_two : primeCount 2 = 1 := by
  decide +revert


/-- **Hypothesis 1 (Constellation Rigidity):**
The Goldbach representation count G(n) is asymptotically proportional to
n · (π(n)/n)² times a singular series correction.
This is stated as a proposition (not proven — equivalent to
Hardy-Littlewood Conjecture B, which is open). -/
def constellationRigidity : Prop :=
  ∃ α : ℝ, α > 0 ∧
  ∀ ε : ℝ, ε > 0 →
  ∃ N : ℕ, ∀ n : ℕ, N < n → Even n →
  let G := (goldbachRepCount n : ℝ)
  let ρ := (primeCount n : ℝ) / n
  |G - α * n * ρ^2| < ε * n * ρ^2


theorem irrational_orbit_dense (α : ℝ) (hα : Irrational α) (x : ℝ) (ε : ℝ) (hε : ε > 0) :
    ∃ n : ℤ, |Int.fract (n * α) - Int.fract x| < ε := by
      -- By the density of the sequence $\{n\alpha\}$ in $[0,1)$, there exists an $n$ such that $\{n\alpha\}$ is arbitrarily close to $x$.
      have h_dense : ∀ δ > 0, ∃ n : ℤ, |Int.fract (n * α) - Int.fract x| < δ := by
        intro δ hδ_pos
        obtain ⟨n, hn⟩ : ∃ n : ℤ, |Int.fract (n * α) - Int.fract x| < δ := by
          have h_dense : ∀ ε > 0, ∃ n : ℤ, |Int.fract (n * α)| < ε ∧ Int.fract (n * α) ≠ 0 := by
            intro ε hε_pos
            obtain ⟨n, hn⟩ : ∃ n : ℤ, 0 < Int.fract (n * α) ∧ Int.fract (n * α) < ε := by
              -- By the pigeonhole principle, there exist integers $m$ and $n$ with $0 < m < n$ such that $\{m\alpha\}$ and $\{n\alpha\}$ fall into the same subinterval of length $\epsilon$.
              obtain ⟨m, n, hmn, h_sub⟩ : ∃ m n : ℕ, 0 < m ∧ m < n ∧ |Int.fract (m * α) - Int.fract (n * α)| < ε := by
                -- By the pigeonhole principle, since there are infinitely many $n$ and only finitely many intervals of length $\epsilon$, there must be some interval that contains at least two of the fractional parts $\{n\alpha\}$.
                have h_pigeonhole : ∃ m n : ℕ, 0 < m ∧ m < n ∧ ⌊Int.fract (m * α) / ε⌋ = ⌊Int.fract (n * α) / ε⌋ := by
                  have h_pigeonhole : Set.Finite (Set.range (fun n : ℕ => ⌊Int.fract (n * α) / ε⌋)) := by
                    exact Set.Finite.subset ( Set.finite_Ico ( 0 : ℤ ) ( ⌈ε⁻¹⌉₊ : ℤ ) ) <| Set.range_subset_iff.mpr fun n => ⟨ Int.floor_nonneg.mpr <| div_nonneg ( Int.fract_nonneg _ ) hε_pos.le, Int.floor_lt.mpr <| by simpa using div_lt_iff₀ hε_pos |>.2 <| by nlinarith [ Nat.le_ceil ( ε⁻¹ ), Int.fract_lt_one ( ( n : ℝ ) * α ), mul_inv_cancel₀ hε_pos.ne' ] ⟩;
                  contrapose! h_pigeonhole;
                  exact Set.infinite_of_injective_forall_mem ( fun m n mn => le_antisymm ( not_lt.1 fun contra => h_pigeonhole _ _ ( by linarith ) ( by linarith ) mn.symm ) ( not_lt.1 fun contra => h_pigeonhole _ _ ( by linarith ) ( by linarith ) mn ) ) fun n => ⟨ n + 1, rfl ⟩;
                obtain ⟨ m, n, hm, hn, h ⟩ := h_pigeonhole;
                rw [ Int.floor_eq_iff ] at h;
                exact ⟨ m, n, hm, hn, abs_lt.mpr ⟨ by nlinarith [ Int.floor_le ( Int.fract ( n * α ) / ε ), Int.lt_floor_add_one ( Int.fract ( n * α ) / ε ), mul_div_cancel₀ ( Int.fract ( m * α ) ) hε_pos.ne', mul_div_cancel₀ ( Int.fract ( n * α ) ) hε_pos.ne' ], by nlinarith [ Int.floor_le ( Int.fract ( n * α ) / ε ), Int.lt_floor_add_one ( Int.fract ( n * α ) / ε ), mul_div_cancel₀ ( Int.fract ( m * α ) ) hε_pos.ne', mul_div_cancel₀ ( Int.fract ( n * α ) ) hε_pos.ne' ] ⟩ ⟩;
              cases' lt_trichotomy ( Int.fract ( m * α ) ) ( Int.fract ( n * α ) ) with h h <;> simp_all +decide [ abs_lt ];
              · use n - m;
                simp_all +decide [ sub_mul ];
                rw [ Int.fract, Int.fract ] at *;
                constructor <;> linarith [ show ( ⌊ ( n : ℝ ) * α - m * α⌋ : ℝ ) = ⌊ ( n : ℝ ) * α⌋ - ⌊ ( m : ℝ ) * α⌋ by exact_mod_cast Int.floor_eq_iff.mpr ⟨ by push_cast; linarith [ Int.floor_le ( ( n : ℝ ) * α ), Int.lt_floor_add_one ( ( n : ℝ ) * α ), Int.floor_le ( ( m : ℝ ) * α ), Int.lt_floor_add_one ( ( m : ℝ ) * α ) ], by push_cast; linarith [ Int.floor_le ( ( n : ℝ ) * α ), Int.lt_floor_add_one ( ( n : ℝ ) * α ), Int.floor_le ( ( m : ℝ ) * α ), Int.lt_floor_add_one ( ( m : ℝ ) * α ) ] ⟩ ];
              · cases' h with h h <;> [ use n - m; use m - n ] <;> simp_all +decide [ Int.fract_eq_fract, sub_mul ];
                · obtain ⟨ z, hz ⟩ := h; exact False.elim <| hα.ne_rat ( z / ( m - n ) ) <| by push_cast; rw [ eq_div_iff ] <;> nlinarith [ show ( m : ℝ ) < n by norm_cast ] ;
                · rw [ Int.fract_pos ];
                  constructor;
                  · exact fun h' => hα.ne_rat ( ⌊ ( m : ℝ ) * α - n * α⌋ / ( m - n ) ) <| by push_cast; rw [ eq_div_iff ( sub_ne_zero_of_ne <| by norm_cast; linarith ) ] ; linarith;
                  · rw [ Int.fract, Int.fract ] at *;
                    linarith [ show ( ⌊ ( m : ℝ ) * α - ( n : ℝ ) * α⌋ : ℝ ) ≥ ⌊ ( m : ℝ ) * α⌋ - ⌊ ( n : ℝ ) * α⌋ by exact_mod_cast Int.le_floor.2 <| by push_cast; linarith [ Int.floor_le ( ( m : ℝ ) * α ), Int.lt_floor_add_one ( ( m : ℝ ) * α ), Int.floor_le ( ( n : ℝ ) * α ), Int.lt_floor_add_one ( ( n : ℝ ) * α ) ] ];
            exact ⟨ n, by rw [ abs_of_pos hn.1 ] ; exact hn.2, hn.1.ne' ⟩
          -- Let $d = \{n\alpha\}$ for some $n$ such that $|d| < \delta$ and $d \neq 0$.
          obtain ⟨n, hn⟩ : ∃ n : ℤ, |Int.fract (n * α)| < δ ∧ Int.fract (n * α) ≠ 0 := h_dense δ hδ_pos
          set d := Int.fract (n * α) with hd_def
          have hd_abs : |d| < δ := by
            exact hn.1
          have hd_ne_zero : d ≠ 0 := by
            exact hn.2;
          -- Consider the sequence $\{kd\}$ for $k = 0, 1, 2, \ldots$. Since $|d| < \delta$, this sequence will cover the interval $[0,1)$ with steps of size less than $\delta$.
          have h_seq : ∃ k : ℤ, |Int.fract (k * d) - Int.fract x| < δ := by
            -- Since $|d| < \delta$, the sequence $\{kd\}$ will cover the interval $[0,1)$ with steps of size less than $\delta$.
            have h_seq_cover : ∀ y : ℝ, 0 ≤ y ∧ y < 1 → ∃ k : ℤ, |Int.fract (k * d) - y| < δ := by
              intros y hy
              obtain ⟨k, hk⟩ : ∃ k : ℤ, k * d ≤ y ∧ y < (k + 1) * d := by
                use Int.floor (y / d);
                exact ⟨ by nlinarith [ Int.floor_le ( y / d ), show 0 < d from lt_of_le_of_ne ( Int.fract_nonneg _ ) ( Ne.symm hd_ne_zero ), mul_div_cancel₀ y hd_ne_zero ], by nlinarith [ Int.lt_floor_add_one ( y / d ), show 0 < d from lt_of_le_of_ne ( Int.fract_nonneg _ ) ( Ne.symm hd_ne_zero ), mul_div_cancel₀ y hd_ne_zero ] ⟩;
              -- Since $|d| < \delta$, we have $|Int.fract (k * d) - y| \leq |d| < \delta$.
              use k
              have h_fract_kd : Int.fract (k * d) = k * d := by
                norm_num [ Int.fract_eq_iff ];
                constructor <;> nlinarith [ show ( k : ℝ ) ≥ 0 by exact_mod_cast Int.le_of_lt_add_one ( by { rw [ ← @Int.cast_lt ℝ ] ; push_cast; nlinarith [ abs_lt.mp hd_abs, Int.fract_nonneg ( ( n : ℝ ) * α ), Int.fract_lt_one ( ( n : ℝ ) * α ) ] } ), Int.fract_nonneg ( ( n : ℝ ) * α ), Int.fract_lt_one ( ( n : ℝ ) * α ) ] ;
              rw [h_fract_kd]
              exact abs_lt.mpr ⟨by linarith [abs_lt.mp hd_abs], by linarith [abs_lt.mp hd_abs]⟩;
            exact h_seq_cover _ ⟨ Int.fract_nonneg _, Int.fract_lt_one _ ⟩;
          obtain ⟨ k, hk ⟩ := h_seq; use k * n; simp_all +decide [ mul_assoc, Int.fract_eq_fract ] ;
          convert hk using 1;
          rw [ show ( k : ℝ ) * ( n * α ) = k * Int.fract ( n * α ) + k * ⌊ ( n : ℝ ) * α⌋ by rw [ Int.fract ] ; ring ] ; ring;
          rw [ show ( k : ℝ ) * Int.fract ( n * α ) + k * ⌊ ( n : ℝ ) * α⌋ = k * Int.fract ( n * α ) + ⌊ ( k : ℝ ) * ⌊ ( n : ℝ ) * α⌋⌋ by norm_num [ show ⌊ ( k : ℝ ) * ⌊ ( n : ℝ ) * α⌋⌋ = k * ⌊ ( n : ℝ ) * α⌋ by exact_mod_cast Int.floor_intCast _ ] ] ; rw [ Int.fract ] ; ring; norm_num; ring;
          rw [ show ( k : ℝ ) * Int.fract ( n * α ) + ( -⌊ ( k : ℝ ) * Int.fract ( n * α ) ⌋ - Int.fract x ) = -Int.fract x + Int.fract ( ( k : ℝ ) * Int.fract ( n * α ) ) by linarith [ Int.fract_add_floor ( ( k : ℝ ) * Int.fract ( n * α ) ) ] ];
        use n;
      exact h_dense ε hε


theorem erdos_straus_div4 (k : ℕ) (hk : 0 < k) :
    ∃ x y z : ℕ, isErdosStrausDecomp (4 * k) x y z := by
      use 2 * k, 4 * k, 4 * k;
      -- We need to verify that $1/(2k) + 1/(4k) + 1/(4k) = 4/(4k)$.
      simp [isErdosStrausDecomp];
      exact ⟨ hk, by linarith, by ring ⟩


theorem erdos_straus_div3 (k : ℕ) (hk : 0 < k) :
    ∃ x y z : ℕ, isErdosStrausDecomp (3 * k) x y z := by
      use k, 4 * k, 12 * k;
      exact ⟨ hk, by positivity, by positivity, by linarith, by linarith, by push_cast; ring ⟩


/-- fracDist is nonneg -/
theorem fracDist_nonneg (x : ℝ) : 0 ≤ fracDist x := by
  unfold fracDist
  exact le_min (Int.fract_nonneg x) (sub_nonneg.mpr (le_of_lt (Int.fract_lt_one x)))


theorem fracDist_le_half (x : ℝ) : fracDist x ≤ 1 / 2 := by
  exact min_le_iff.mpr ( by cases le_or_gt ( Int.fract x ) ( 1 / 2 ) <;> [ left; right ] <;> linarith [ Int.fract_nonneg x, Int.fract_lt_one x ] )


end
