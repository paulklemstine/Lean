import Mathlib

/-! # CatalogBuild.Computation.Factoring.FutureExploration

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 34
-/

/-- B-smooth numbers are closed under multiplication. -/
theorem smooth_number_closure (B a b : ℕ) (ha : IsSmooth B a) (hb : IsSmooth B b) :
    IsSmooth B (a * b) := by
  intro p hp hd
  rcases hp.dvd_mul.mp hd with h | h
  · exact ha p hp h
  · exact hb p hp h

/-- Divisors of B-smooth numbers are B-smooth. -/
theorem smooth_number_divisor (B n d : ℕ) (hn : IsSmooth B n) (hd : d ∣ n) :
    IsSmooth B d := fun p hp hpd => hn p hp (dvd_trans hpd hd)

/-- The gcd of B-smooth numbers is B-smooth. -/
theorem smooth_number_gcd (B a b : ℕ) (ha : IsSmooth B a) :
    IsSmooth B (Nat.gcd a b) :=
  smooth_number_divisor B a _ ha (Nat.gcd_dvd_left a b)

/-- Any positive number ≤ B is B-smooth. -/
theorem smooth_all_below_base (B n : ℕ) (hn : 0 < n) (hnB : n ≤ B) : IsSmooth B n :=
  fun _p _hp hpn => le_trans (Nat.le_of_dvd hn hpn) hnB

/-- B-smoothness is monotone in B. -/
theorem smooth_monotone (B B' n : ℕ) (hBB : B ≤ B') (hn : IsSmooth B n) :
    IsSmooth B' n := fun p hp hd => le_trans (hn p hp hd) hBB

/-- Lucas recurrence. -/
theorem lucas_recurrence (n : ℕ) : lucas (n + 2) = lucas (n + 1) + lucas n := rfl

/-- [Section: # CatalogBuild.Computation.Factoring.FutureExploration
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 34] -/
theorem lucas_val_0 : lucas 0 = 2 := rfl

/-- [Section: # CatalogBuild.Computation.Factoring.FutureExploration
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 34] -/
theorem lucas_val_1 : lucas 1 = 1 := rfl

theorem lucas_val_2 : lucas 2 = 3 := rfl

theorem lucas_val_3 : lucas 3 = 4 := rfl

theorem lucas_val_4 : lucas 4 = 7 := rfl

theorem lucas_growth (n : ℕ) (hn : 1 ≤ n) : n ≤ lucas n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | k ) <;> simp_all! +arith +decide;
  grind +locals

theorem tribonacci_bound (n : ℕ) (hn : 1 ≤ n) : tribonacci n < 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, Nat.pow_succ' ];
  rw [ show tribonacci _ = _ + _ + _ from rfl ];
  grind

/-- Birthday collision: n+1 values in [0,n) must collide. -/
theorem birthday_collision (n : ℕ) (f : Fin (n + 1) → Fin n) :
    ∃ i j : Fin (n + 1), i ≠ j ∧ f i = f j :=
  Fintype.exists_ne_map_eq_of_card_lt f (by simp)

theorem orbit_eventually_periodic (n : ℕ) (_hn : 0 < n) (f : Fin n → Fin n)
    (x : Fin n) :
    ∃ i j : ℕ, i < j ∧ j ≤ n ∧ f^[i] x = f^[j] x := by
  by_contra! h_contra;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x ) ( Finset.Icc 0 n ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => h_contra _ _ hi' ( Finset.mem_Icc.mp hi |>.2 ) hij.symm ) ( le_of_not_gt fun hj' => h_contra _ _ hj' ( Finset.mem_Icc.mp hj |>.2 ) hij ) ] ; simp +arith +decide )

/-- Residue count: mod m gives at most m distinct residues. -/
theorem residue_count_bound (m : ℕ) (hm : 0 < m) (S : Finset ℕ) :
    (S.image (· % m)).card ≤ m := by
  calc (S.image (· % m)).card
      ≤ (Finset.range m).card := by
        apply Finset.card_le_card; intro x hx
        simp only [Finset.mem_image] at hx; obtain ⟨a, _, ha⟩ := hx
        subst ha; exact Finset.mem_range.mpr (Nat.mod_lt a hm)
    _ = m := Finset.card_range m

/-- Two moduli give at most m₁ · m₂ distinct residue pairs. -/
theorem crt_residue_count (m₁ m₂ : ℕ) (hm₁ : 0 < m₁) (hm₂ : 0 < m₂)
    (S : Finset ℕ) :
    (S.image (fun n => (n % m₁, n % m₂))).card ≤ m₁ * m₂ := by
  calc (S.image (fun n => (n % m₁, n % m₂))).card
      ≤ (Finset.range m₁ ×ˢ Finset.range m₂).card := by
        apply Finset.card_le_card; intro x hx
        simp only [Finset.mem_image] at hx
        obtain ⟨c, _, hc⟩ := hx; subst hc
        simp only [Finset.mem_product, Finset.mem_range]
        exact ⟨Nat.mod_lt c hm₁, Nat.mod_lt c hm₂⟩
    _ = m₁ * m₂ := by simp [Finset.card_product]

/-- CRT gives multiplicative reduction for coprime moduli. -/
theorem coprime_product_reduction (m₁ m₂ : ℕ) (hcop : Nat.Coprime m₁ m₂) :
    Nat.totient (m₁ * m₂) = Nat.totient m₁ * Nat.totient m₂ :=
  Nat.totient_mul hcop

/-- For any prime p ≤ B, p divides B!. -/
theorem prime_divides_factorial (B p : ℕ) (hp : Nat.Prime p) (hpB : p ≤ B) :
    p ∣ B ! :=
  Nat.dvd_factorial hp.pos hpB

/-- Trivial bound on prime counting function. -/
theorem prime_count_trivial_bound (N : ℕ) :
    ((Finset.range (N + 1)).filter Nat.Prime).card ≤ N + 1 :=
  le_trans (Finset.card_filter_le _ _) (by simp)

/-- Element order divides group order. -/
theorem element_order_divides {G : Type*} [Group G] [Fintype G] (g : G) :
    orderOf g ∣ Fintype.card G := orderOf_dvd_card

/-- The symmetric group Sₙ has order n!. -/
theorem symmetric_group_order (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = Nat.factorial n := by
  simp [Fintype.card_perm]

/-- Wilson's theorem. -/
theorem wilson_zmod (p : ℕ) [Fact (Nat.Prime p)] :
    ((p - 1)! : ZMod p) = -1 := ZMod.wilsons_lemma p

theorem mlc_strict_hierarchy (S k : ℕ) (hS : 2 ^ (k + 1) ≤ S) :
    S / 2 ^ (k + 1) < S / 2 ^ k := by
  refine' Nat.div_lt_of_lt_mul _;
  nlinarith [ Nat.div_add_mod S ( 2 ^ k ), Nat.mod_lt S ( pow_pos ( by decide : 0 < 2 ) k ), pow_pos ( by decide : 0 < 2 ) k, pow_succ' 2 k ]

/-- At most S lenses are meaningful. -/
theorem mlc_ceiling (S : ℕ) : S / 2 ^ S = 0 :=
  Nat.div_eq_of_lt (Nat.lt_pow_self (by omega : 1 < 2))

/-- MLC separation witness. -/
theorem mlc_separation_witness (k : ℕ) :
    2 ^ k / 2 ^ k = 1 := Nat.div_self (by positivity)

/-- Lens power law. -/
theorem lens_power_law (S a b : ℕ) :
    S / 2 ^ a / 2 ^ b = S / 2 ^ (a + b) := by
  rw [pow_add, Nat.div_div_eq_div_mul]

/-- Lens commutativity. -/
theorem lens_commutativity (S a b : ℕ) :
    S / 2 ^ a / 2 ^ b = S / 2 ^ b / 2 ^ a := by
  rw [lens_power_law, lens_power_law, Nat.add_comm]

/-- Qubit savings from k classical lenses. -/
theorem qubit_savings_bound (S k : ℕ) :
    Nat.sqrt (S / 2 ^ k) ≤ Nat.sqrt S :=
  Nat.sqrt_le_sqrt (Nat.div_le_self S _)

theorem nine_lens_qubit_savings (S : ℕ) (hS : 512 ≤ S) :
    Nat.sqrt (S / 512) < Nat.sqrt S := by
  rw [ Nat.sqrt_lt ];
  nlinarith [ Nat.lt_succ_sqrt S, Nat.div_mul_le_self S 512 ]

/-- Norm multiplicativity in ℤ[√d]. -/
theorem norm_mult_zsqrtd (d : ℤ) (a b : ℤ√d) :
    (a * b).norm = a.norm * b.norm := Zsqrtd.norm_mul a b

/-- Polynomial roots bounded by degree. -/
theorem poly_roots_bounded {R : Type*} [CommRing R] [IsDomain R]
    (f : Polynomial R) :
    Multiset.card f.roots ≤ f.natDegree := Polynomial.card_roots' f

/-- For primes p ≡ 1 (mod 4), -1 is a quadratic residue mod p. -/
theorem neg_one_qr_mod_4 (p : ℕ) [Fact (Nat.Prime p)] (hp4 : p % 4 = 1) :
    ∃ x : ZMod p, x ^ 2 = -1 := by
  have : IsSquare (-1 : ZMod p) := ZMod.exists_sq_eq_neg_one_iff.mpr (by omega)
  obtain ⟨x, hx⟩ := this
  exact ⟨x, by rw [sq]; exact hx.symm⟩

/-- Smooth numbers up to B: for any n with 0 < n ≤ B, n is B-smooth. -/
theorem all_up_to_B_smooth (B : ℕ) :
    ∀ n, 0 < n → n ≤ B → IsSmooth B n :=
  fun n hn hnB => smooth_all_below_base B n hn hnB

