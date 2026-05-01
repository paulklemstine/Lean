import Mathlib

/-! # CatalogBuild.Speculative.QuadraticReciprocityFull

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13
-/

/-- [Section: # CatalogBuild.Speculative.QuadraticReciprocityFull
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
theorem quadratic_reciprocity_legendre (p q : ℕ) [Fact (Nat.Prime p)] [Fact (Nat.Prime q)]
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym p q * legendreSym q p =
      (-1) ^ ((p - 1) / 2 * ((q - 1) / 2)) := by
  rw [ mul_comm, legendreSym.quadratic_reciprocity' ];
  · cases Nat.Prime.odd_of_ne_two Fact.out hp2 ; cases Nat.Prime.odd_of_ne_two Fact.out hq2 ; simp_all +decide [ Nat.even_div ];
    norm_num [ Nat.add_div, pow_mul ];
    simp +decide [ ← mul_assoc, ← pow_two, legendreSym ];
    simp +decide [ quadraticCharFun ];
    split_ifs <;> simp_all +decide [ ZMod.natCast_eq_zero_iff ];
    norm_cast at *;
    rw [ ZMod.natCast_eq_zero_iff ] at * ; simp_all +decide [ Nat.prime_dvd_prime_iff_eq ];
    simp_all +decide [ Nat.prime_dvd_prime_iff_eq Fact.out Fact.out ];
  · assumption;
  · assumption

/-- [Section: # CatalogBuild.Speculative.QuadraticReciprocityFull
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
theorem legendre_sym_neg_one_val (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2) :
    legendreSym p (-1) = (-1) ^ ((p - 1) / 2) := by
  rw [ legendreSym.at_neg_one ];
  · rw [ ← Nat.mod_add_div p 4 ] at *; have := Nat.mod_lt p four_pos; interval_cases p % 4 <;> simp_all +decide [ Nat.even_div ] ;
    · exact absurd ( Fact.out ( p := Nat.Prime ( 4 * ( p / 4 ) ) ) ) ( by norm_num [ Nat.prime_mul_iff ] );
    · ring_nf;
      exact?;
    · cases Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime ( 2 + 4 * ( p / 4 ) ) ) <;> omega;
    · ring_nf;
      exact?;
  · exact hp

theorem legendre_sym_two_val (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2) :
    legendreSym p 2 = (-1) ^ ((p ^ 2 - 1) / 8) := by
  have h_legendre_sym_2 : legendreSym p 2 = jacobiSym 2 p := by
    exact?;
  rw [ h_legendre_sym_2, jacobiSym.mod_right ];
  · rw [ ← Nat.mod_add_div p 8 ] ; have := Nat.mod_lt p ( by decide : 0 < 8 ) ; interval_cases _ : p % 8 <;> norm_num [ Nat.pow_add, Nat.pow_mul, Nat.mul_mod, Nat.pow_mod ] ;
    all_goals have := Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) ; simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 8 ) ];
    · ring_nf;
      norm_num [ add_assoc, Nat.add_div ];
      norm_num [ Nat.mul_div_assoc, Nat.mul_mod, Nat.pow_mod ];
      norm_num [ pow_add, pow_mul' ];
    · ring_nf;
      norm_num [ show 9 + p / 8 * 48 + ( p / 8 ) ^ 2 * 64 - 1 = 8 * ( 1 + p / 8 * 6 + ( p / 8 ) ^ 2 * 8 ) by rw [ Nat.sub_eq_of_eq_add ] ; ring ];
      norm_num [ pow_add, pow_mul' ];
    · ring_nf;
      norm_num [ show 25 + p / 8 * 80 + ( p / 8 ) ^ 2 * 64 - 1 = 8 * ( 3 + p / 8 * 10 + ( p / 8 ) ^ 2 * 8 ) by rw [ Nat.sub_eq_of_eq_add ] ; ring ];
      norm_num [ pow_add, pow_mul' ];
    · ring_nf;
      norm_num [ show 49 + p / 8 * 112 + ( p / 8 ) ^ 2 * 64 - 1 = 8 * ( 6 + p / 8 * 14 + ( p / 8 ) ^ 2 * 8 ) by rw [ Nat.sub_eq_of_eq_add ] ; ring ];
      norm_num [ pow_add, pow_mul' ];
  · exact Nat.Prime.odd_of_ne_two Fact.out hp

theorem sum_legendre_zero (p : ℕ) [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2) :
    ∑ a ∈ Finset.range (p - 1), legendreSym p ((a : ℤ) + 1) = 0 := by
  simp +decide only [legendreSym];
  -- Let's simplify the sum. Since we're working in a finite field, the sum of all non-zero elements is zero.
  have h_sum_zero : ∑ x ∈ Finset.univ.erase 0, quadraticChar (ZMod p) x = 0 := by
    -- Let $a$ be a quadratic non-residue modulo $p$.
    obtain ⟨a, ha⟩ : ∃ a : ZMod p, quadraticChar (ZMod p) a = -1 := by
      -- Since $p$ is an odd prime, there exists a quadratic non-residue modulo $p$.
      obtain ⟨a, ha⟩ : ∃ a : ZMod p, ¬IsSquare a := by
        by_contra! h;
        -- If every element in $ZMod p$ is a square, then the squaring map is surjective.
        have h_surjective : Function.Surjective (fun x : ZMod p => x^2) := by
          exact fun x => by obtain ⟨ y, rfl ⟩ := h x; exact ⟨ y, by ring ⟩ ;
        -- Since the squaring map is surjective, it must also be injective.
        have h_injective : Function.Injective (fun x : ZMod p => x^2) := by
          exact Finite.injective_iff_surjective.mpr h_surjective;
        have := @h_injective ( -1 ) 1 ; norm_num at this;
        rw [ neg_eq_iff_add_eq_zero ] at this;
        rcases p with ( _ | _ | _ | p ) <;> cases this <;> contradiction;
      use a; simp [ha, quadraticCharFun];
      exact fun h => ha <| h.symm ▸ ⟨ 0, by simp +decide ⟩;
    -- Consider the sum $\sum_{x \in \mathbb{F}_p^*} \left( \frac{ax}{p} \right)$.
    have h_sum_ax : ∑ x ∈ Finset.univ.erase 0, quadraticChar (ZMod p) (a * x) = ∑ x ∈ Finset.univ.erase 0, quadraticChar (ZMod p) x := by
      -- Since multiplication by a non-zero element is a bijection on the finite field, the sums are equal.
      have h_bij : Finset.image (fun x => a * x) (Finset.univ.erase 0) = Finset.univ.erase 0 := by
        refine' Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr _ ) _;
        · simp_all +decide [ quadraticCharFun ];
          grind;
        · rw [ Finset.card_image_of_injective _ fun x y hxy => mul_left_cancel₀ ( show a ≠ 0 from by rintro rfl; simp +decide at ha ) hxy ];
      conv_rhs => rw [ ← h_bij, Finset.sum_image ( Finset.card_image_iff.mp <| by aesop ) ] ;
    simp_all +decide [ Finset.mul_sum _ _ _, quadraticCharFun_mul ];
    bv_omega;
  rcases p with ( _ | _ | p ) <;> simp_all +decide [ Finset.sum_range, ZMod, Fin.sum_univ_succ ]

/-- Product of two quadratic non-residues is a quadratic residue. -/
theorem qnr_product_is_qr (p : ℕ) [hp : Fact (Nat.Prime p)]
    (a b : ℤ) (ha : legendreSym p a = -1) (hb : legendreSym p b = -1) :
    legendreSym p (a * b) = 1 := by
  rw [legendreSym.mul p a b, ha, hb]; ring

/-- Product of a QR and QNR is a QNR. -/
theorem qr_qnr_product_is_qnr (p : ℕ) [hp : Fact (Nat.Prime p)]
    (a b : ℤ) (ha : legendreSym p a = 1) (hb : legendreSym p b = -1) :
    legendreSym p (a * b) = -1 := by
  rw [legendreSym.mul p a b, ha, hb]; ring

theorem first_supplement (p : ℕ) [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2) :
    legendreSym p (-1) = 1 ↔ p % 4 = 1 := by
  rw [ legendreSym.at_neg_one ];
  · rw [ ZMod.χ₄_nat_mod_four ] ; have := Nat.mod_lt p zero_lt_four; interval_cases p % 4 <;> simp +decide ;
  · assumption

theorem second_supplement (p : ℕ) [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2) :
    legendreSym p 2 = 1 ↔ p % 8 = 1 ∨ p % 8 = 7 := by
  constructor <;> intro h;
  · haveI := Fact.mk hp.1; rw [ legendreSym.at_two ] at h;
    · rw [ ZMod.χ₈_nat_mod_eight ] at h ; have := Nat.mod_lt p ( by decide : 0 < 8 ) ; interval_cases _ : p % 8 <;> simp_all +decide;
    · exact hodd;
  · rw [ legendreSym.at_two ];
    · rcases h with ( h | h ) <;> rw [ ← Nat.mod_add_div p 8, h ] <;> norm_num [ ZMod, χ₈ ];
      · ring_nf;
        exact?;
      · ring_nf;
        exact?;
    · exact hodd

/-- Quadratic reciprocity verified for (3, 5). -/
theorem qr_3_5 : @legendreSym 3 ⟨Nat.prime_iff.mpr (by decide)⟩ 5 *
    @legendreSym 5 ⟨Nat.prime_iff.mpr (by decide)⟩ 3 = (-1) ^ (1 * 2) := by
  native_decide

/-- Quadratic reciprocity verified for (3, 7). -/
theorem qr_3_7 : @legendreSym 3 ⟨Nat.prime_iff.mpr (by decide)⟩ 7 *
    @legendreSym 7 ⟨Nat.prime_iff.mpr (by decide)⟩ 3 = (-1) ^ (1 * 3) := by
  native_decide

/-- Quadratic reciprocity verified for (5, 7). -/
theorem qr_5_7 : @legendreSym 5 ⟨Nat.prime_iff.mpr (by decide)⟩ 7 *
    @legendreSym 7 ⟨Nat.prime_iff.mpr (by decide)⟩ 5 = (-1) ^ (2 * 3) := by
  native_decide

/-- Quadratic reciprocity verified for (11, 13). -/
theorem qr_11_13 : @legendreSym 11 ⟨Nat.prime_iff.mpr (by decide)⟩ 13 *
    @legendreSym 13 ⟨Nat.prime_iff.mpr (by decide)⟩ 11 = (-1) ^ (5 * 6) := by
  native_decide

/-- Quadratic reciprocity verified for (5, 11). -/
theorem qr_5_11 : @legendreSym 5 ⟨Nat.prime_iff.mpr (by decide)⟩ 11 *
    @legendreSym 11 ⟨Nat.prime_iff.mpr (by decide)⟩ 5 = (-1) ^ (2 * 5) := by
  native_decide

