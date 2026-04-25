/-! # CatalogBuild.Pythagorean.Core.PythagoreanFactoring

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A same-parity divisor pair of `n²` is a pair `(d, e)` with `d * e = n²`,
`d < e`, and `d ≡ e (mod 2)`. -/
structure DivisorPair (n : ℕ) where
  d : ℕ
  e : ℕ
  product : d * e = n ^ 2
  lt : d < e
  same_parity : d % 2 = e % 2


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 12] -/
noncomputable def divisorPairToTriple {n : ℕ} (hn : 0 < n) (dp : DivisorPair n) :
    PythTriple n where
  b := (dp.e - dp.d) / 2
  c := (dp.e + dp.d) / 2
  hyp := by
    -- Let's expand the right-hand side: ((dp.e + dp.d) / 2) ^ 2.
    have h_expand : ((dp.e + dp.d) / 2) ^ 2 = (dp.e ^ 2 + 2 * dp.e * dp.d + dp.d ^ 2) / 4 := by
      -- Since $dp.e$ and $dp.d$ are both even or both odd, their sum is even, so $(dp.e + dp.d) / 2$ is an integer.
      have h_even : Even (dp.e + dp.d) := by
        rw [ Nat.even_add ] ; have := dp.same_parity ; ( rw [ Nat.even_iff, Nat.even_iff ] at * ; omega; );
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_four ( by nlinarith only [ Nat.div_mul_cancel ( even_iff_two_dvd.mp h_even ) ] ) );
    -- By definition of $dp$, we know that $dp.e * dp.d = n^2$ and $dp.d < dp.e$.
    obtain ⟨h_prod, h_lt, h_parity⟩ := dp;
    rw [ ← h_parity, h_expand ];
    exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_four ( by nlinarith only [ Nat.div_mul_cancel ( show 2 ∣ h_lt - h_prod from Nat.dvd_of_mod_eq_zero ( by omega ) ), Nat.sub_add_cancel ( le_of_lt ‹_› ) ] ) )
  b_pos := by
    refine' Nat.div_pos _ ( by decide );
    by_contra h_contra; have := dp.same_parity; interval_cases _ : dp.e - dp.d <;> simp_all +decide [ Nat.even_sub dp.lt.le ] ;
    · linarith [ dp.lt, Nat.sub_pos_of_lt dp.lt ];
    · omega


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 12] -/
noncomputable def tripleToDivisorPair {n : ℕ} (hn : 1 < n) (t : PythTriple n) :
    DivisorPair n where
  d := t.c - t.b
  e := t.c + t.b
  product := by
    nlinarith only [ Nat.sub_add_cancel ( show t.b ≤ t.c from by nlinarith only [ t.hyp ] ), t.hyp ]
  lt := by
    exact lt_add_of_le_of_pos ( Nat.sub_le _ _ ) t.b_pos
  same_parity := by
    zify;
    rw [ Int.ofNat_sub ( by nlinarith [ t.hyp ] ) ] ; omega;


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 12] -/
theorem diff_of_squares_pyth {n b c : ℤ} (h : n ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = n ^ 2 := by
      linarith


theorem divisor_pair_gives_triple {n d e : ℤ} (hprod : d * e = n ^ 2)
    (hparity : (d + e) % 2 = 0) :
    n ^ 2 + ((e - d) / 2) ^ 2 = ((e + d) / 2) ^ 2 := by
      cases abs_cases d <;> cases abs_cases e <;> nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ e-d from Int.dvd_of_emod_eq_zero <| by omega ), Int.ediv_mul_cancel ( show 2 ∣ e+d from Int.dvd_of_emod_eq_zero <| by omega ) ] ;


theorem gcd_factor_of_n {n d e : ℕ} (hn : 1 < n) (hprod : d * e = n ^ 2)
    (hgcd_gt : 1 < Nat.gcd d n) (hgcd_lt : Nat.gcd d n < n) :
    Nat.gcd d n ∣ n ∧ 1 < Nat.gcd d n ∧ Nat.gcd d n < n := by
      exact ⟨ Nat.gcd_dvd_right _ _, hgcd_gt, hgcd_lt ⟩


theorem semiprime_factor_triple {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p < q) (hodd_p : p % 2 = 1) (hodd_q : q % 2 = 1) :
    let n := p * q
    let d := p
    let e := p * q ^ 2
    d * e = n ^ 2 ∧ Nat.gcd d n = p := by
      exact ⟨ by ring, Nat.gcd_eq_left ( dvd_mul_right _ _ ) ⟩


theorem prime_unique_triple (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
    ∀ b c : ℕ, p ^ 2 + b ^ 2 = c ^ 2 → b > 0 →
    b = (p ^ 2 - 1) / 2 ∧ c = (p ^ 2 + 1) / 2 := by
      intros b c h_eq h_pos
      have h_divisors : (c - b) * (c + b) = p^2 := by
        nlinarith [ Nat.sub_add_cancel ( by nlinarith : b ≤ c ) ];
      -- Since $p$ is prime, the only divisors of $p^2$ are $1$, $p$, and $p^2$. Therefore, $(c - b)$ must be $1$, $p$, or $p^2$.
      have h_divisors_cases : (c - b = 1 ∧ c + b = p^2) ∨ (c - b = p ∧ c + b = p) ∨ (c - b = p^2 ∧ c + b = 1) := by
        have : c - b ∣ p^2 := h_divisors ▸ dvd_mul_right _ _;
        rw [ Nat.dvd_prime_pow hp ] at this;
        rcases this with ⟨ k, hk₁, hk₂ ⟩ ; interval_cases k <;> simp_all +decide [ pow_succ' ] ;
        · grind +revert;
        · rcases p with ( _ | _ | p ) <;> simp_all +decide [ ne_of_gt ];
      grind


theorem composite_multiple_triples (n : ℕ) (hn : 1 < n) (hodd : n % 2 = 1)
    (hcomp : ¬ Nat.Prime n) :
    ∃ b₁ c₁ b₂ c₂ : ℕ, b₁ > 0 ∧ b₂ > 0 ∧
    n ^ 2 + b₁ ^ 2 = c₁ ^ 2 ∧
    n ^ 2 + b₂ ^ 2 = c₂ ^ 2 ∧
    (b₁, c₁) ≠ (b₂, c₂) := by
      -- Let's choose any non-trivial factorization of $n^2$.
      obtain ⟨d, e, hde, hde_pos⟩ : ∃ d e : ℕ, 1 < d ∧ 1 < e ∧ d * e = n ^ 2 ∧ d < e ∧ d % 2 = e % 2 := by
        obtain ⟨ k, hk ⟩ := Nat.exists_prime_and_dvd hn.ne';
        obtain ⟨ m, rfl ⟩ := hk.2;
        use k, k * m^2;
        rcases k with ( _ | _ | k ) <;> rcases m with ( _ | _ | m ) <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at *;
        · contradiction;
        · exact ⟨ by nlinarith, by ring, by norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] ; have := Nat.mod_lt k zero_lt_two; have := Nat.mod_lt m zero_lt_two; interval_cases k % 2 <;> interval_cases m % 2 <;> trivial ⟩;
      -- Using the divisor pair $(d, e)$, we construct the Pythagorean triple $(n, (e - d)/2, (e + d)/2)$.
      obtain ⟨b₁, c₁, hb₁⟩ : ∃ b₁ c₁ : ℕ, n ^ 2 + b₁ ^ 2 = c₁ ^ 2 ∧ b₁ > 0 ∧ c₁ > 0 ∧ b₁ = (e - d) / 2 ∧ c₁ = (e + d) / 2 := by
        refine' ⟨ _, _, _, _, _, rfl, rfl ⟩;
        · nlinarith only [ Nat.div_mul_cancel ( show 2 ∣ e - d from Nat.dvd_of_mod_eq_zero <| by omega ), Nat.div_mul_cancel ( show 2 ∣ e + d from Nat.dvd_of_mod_eq_zero <| by omega ), Nat.sub_add_cancel hde_pos.2.2.1.le, hde_pos.2.1 ];
        · exact Nat.div_pos ( Nat.le_of_dvd ( Nat.sub_pos_of_lt hde_pos.2.2.1 ) ( Nat.dvd_of_mod_eq_zero ( by omega ) ) ) zero_lt_two;
        · omega;
      refine' ⟨ b₁, c₁, ( n ^ 2 - 1 ) / 2, ( n ^ 2 + 1 ) / 2, hb₁.2.1, _, hb₁.1, _, _ ⟩ <;> simp_all +decide [ ne_of_gt ];
      · exact Nat.le_sub_one_of_lt ( by nlinarith only [ hn ] );
      · nlinarith only [ Nat.div_mul_cancel ( show 2 ∣ n ^ 2 + 1 from even_iff_two_dvd.mp ( by simpa [ parity_simps ] using Nat.odd_iff.mpr hodd ) ), Nat.div_mul_cancel ( show 2 ∣ n ^ 2 - 1 from even_iff_two_dvd.mp ( by rw [ Nat.even_sub ( by nlinarith only [ hn ] ) ] ; simpa [ parity_simps ] using Nat.odd_iff.mpr hodd ) ), Nat.sub_add_cancel ( by nlinarith only [ hn ] : 1 ≤ n ^ 2 ) ];
      · intro h; omega;


theorem parametrize_primitive (a b c : ℕ) (ha : a % 2 = 1) (hb : b % 2 = 0)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hprim : Nat.gcd a b = 1) (ha_pos : 0 < a)
    (hb_pos : 0 < b) :
    ∃ m n : ℕ, m > n ∧ n > 0 ∧ Nat.gcd m n = 1 ∧ (m - n) % 2 = 1 ∧
    a = m ^ 2 - n ^ 2 ∧ b = 2 * m * n ∧ c = m ^ 2 + n ^ 2 := by
      obtain ⟨m, n, hm, hn, hmn⟩ : ∃ m n : ℕ, m > n ∧ n > 0 ∧ Nat.gcd m n = 1 ∧ a = m ^ 2 - n ^ 2 ∧ b = 2 * m * n ∧ c = m ^ 2 + n ^ 2 := by
        have h_eq : ∃ m n : ℕ, a = m ^ 2 - n ^ 2 ∧ b = 2 * m * n ∧ c = m ^ 2 + n ^ 2 := by
          obtain ⟨ m, rfl ⟩ := Nat.dvd_of_mod_eq_zero hb;
          -- Since $c^2 - a^2 = (c - a)(c + a) = 4m^2$, we can write $c - a = 2k$ and $c + a = 2l$ for some integers $k$ and $l$.
          obtain ⟨k, l, hk, hl⟩ : ∃ k l : ℕ, c - a = 2 * k ∧ c + a = 2 * l ∧ k * l = m ^ 2 := by
            use (c - a) / 2, (c + a) / 2;
            exact ⟨ by rw [ Nat.mul_div_cancel' ( even_iff_two_dvd.mp ( by rw [ Nat.even_sub ( by nlinarith ) ] ; replace hpyth := congr_arg Even hpyth; simp_all +decide [ ← Nat.odd_iff, parity_simps ] ) ) ], by rw [ Nat.mul_div_cancel' ( even_iff_two_dvd.mp ( by rw [ Nat.even_add ] ; replace hpyth := congr_arg Even hpyth; simp_all +decide [ ← Nat.odd_iff, parity_simps ] ) ) ], by nlinarith only [ Nat.div_mul_cancel ( show 2 ∣ c - a from even_iff_two_dvd.mp ( by rw [ Nat.even_sub ( by nlinarith ) ] ; replace hpyth := congr_arg Even hpyth; simp_all +decide [ ← Nat.odd_iff, parity_simps ] ) ), Nat.div_mul_cancel ( show 2 ∣ c + a from even_iff_two_dvd.mp ( by rw [ Nat.even_add ] ; replace hpyth := congr_arg Even hpyth; simp_all +decide [ ← Nat.odd_iff, parity_simps ] ) ), Nat.sub_add_cancel ( by nlinarith : a ≤ c ), hpyth ] ⟩;
          -- Since $k$ and $l$ are coprime and their product is $m^2$, they must both be perfect squares.
          obtain ⟨u, hu⟩ : ∃ u : ℕ, k = u^2 := by
            have h_coprime : Nat.gcd k l = 1 := by
              -- By contradiction, assume that $k$ and $l$ are not coprime.
              by_contra h_not_coprime;
              -- If $k$ and $l$ are not coprime, then there exists a prime $p$ such that $p \mid k$ and $p \mid l$.
              obtain ⟨p, hp_prime, hp_div_k, hp_div_l⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ k ∧ p ∣ l := by
                exact Nat.Prime.not_coprime_iff_dvd.mp h_not_coprime;
              exact hp_prime.not_dvd_one <| hprim ▸ Nat.dvd_gcd ( show p ∣ a by convert Nat.dvd_sub ( hp_div_l ) ( hp_div_k ) using 1; rw [ Nat.sub_eq_of_eq_add ] ; linarith [ Nat.sub_add_cancel <| show a ≤ c from by nlinarith only [ hpyth ] ] ) ( show p ∣ 2 * m by exact dvd_mul_of_dvd_right ( show p ∣ m by exact hp_prime.dvd_of_dvd_pow <| hl.2 ▸ dvd_mul_of_dvd_left hp_div_k _ ) _ );
            exact exists_eq_pow_of_mul_eq_pow ( by aesop ) hl.2
          obtain ⟨v, hv⟩ : ∃ v : ℕ, l = v^2 := by
            use m / u;
            rw [ Nat.div_pow ];
            · rw [ Nat.div_eq_of_eq_mul_left ] <;> nlinarith only [ hu, hl.2, show u > 0 from Nat.pos_of_ne_zero ( by rintro rfl; nlinarith ) ];
            · exact Nat.pow_dvd_pow_iff two_ne_zero |>.1 <| hu ▸ hl.2 ▸ dvd_mul_right _ _;
          use v, u;
          exact ⟨ eq_tsub_of_add_eq <| by linarith [ Nat.sub_add_cancel <| show a ≤ c from by nlinarith only [ hpyth ] ], by rw [ ← sq_eq_sq₀ ] <;> first | positivity | nlinarith only [ hl, hu, hv ], by linarith [ Nat.sub_add_cancel <| show a ≤ c from by nlinarith only [ hpyth ] ] ⟩
        obtain ⟨ m, n, rfl, rfl, rfl ⟩ := h_eq;
        refine' ⟨ m, n, _, _, _, rfl, rfl, rfl ⟩;
        · exact not_le.mp fun h => by rw [ Nat.sub_eq_zero_of_le ( Nat.pow_le_pow_left h 2 ) ] at ha_pos; contradiction;
        · exact Nat.pos_of_ne_zero ( by aesop_cat );
        · simp_all +decide [ Nat.sq_sub_sq, Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
      use m, n;
      cases Nat.mod_two_eq_zero_or_one m <;> cases Nat.mod_two_eq_zero_or_one n <;> simp_all +decide [ Nat.sq_sub_sq, Nat.add_mod, Nat.mul_mod ]


theorem prime_triple_params (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) (hp3 : 3 ≤ p) :
    let m := (p + 1) / 2
    let n := (p - 1) / 2
    m > n ∧ n > 0 ∧ p = m ^ 2 - n ^ 2 := by
      cases Nat.Prime.eq_two_or_odd hp <;> simp_all +decide [ Nat.div_le_iff_le_mul_add_pred ];
      exact ⟨ by omega, Nat.le_sub_one_of_lt hp3, eq_tsub_of_add_eq <| by nlinarith only [ Nat.div_mul_cancel ( show 2 ∣ p + 1 from Nat.dvd_of_mod_eq_zero <| by omega ), Nat.div_mul_cancel ( show 2 ∣ p - 1 from Nat.dvd_of_mod_eq_zero <| by omega ), Nat.sub_add_cancel hp.pos ] ⟩


theorem berggren_depth_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) (hp5 : 5 ≤ p) :
    let m := (p + 1) / 2
    -- The Berggren tree depth = m - 2 = (p - 3) / 2
    m ≥ 2 ∧ m - 2 = (p - 3) / 2 := by
      lia


end
