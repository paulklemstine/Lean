/-! # CatalogBuild.Speculative.QuadraticReciprocity

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.QuadraticReciprocity
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem euler_criterion_forward (p : ℕ) [Fact (Nat.Prime p)] (hodd : p ≠ 2)
    (a : ZMod p) (ha : a ≠ 0) (hx : ∃ x : ZMod p, x ^ 2 = a) :
    a ^ ((p - 1) / 2) = 1 := by
  obtain ⟨ x, rfl ⟩ := hx;
  rw [ ← pow_mul, Nat.mul_div_cancel' ( even_iff_two_dvd.mp <| Nat.Prime.even_sub_one Fact.out hodd ), ZMod.pow_card_sub_one_eq_one ] ; aesop


/-- The Legendre symbol is multiplicative. -/
theorem legendreSym_mul' (p : ℕ) [Fact (Nat.Prime p)] (a b : ℤ) :
    legendreSym p (a * b) = legendreSym p a * legendreSym p b :=
  legendreSym.mul p a b


/-- [Section: # CatalogBuild.Speculative.QuadraticReciprocity
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem neg_one_qr_iff_one_mod_four (p : ℕ) [Fact (Nat.Prime p)] (hodd : p ≠ 2) :
    (∃ x : ZMod p, x ^ 2 = -1) ↔ p % 4 = 1 := by
  constructor <;> intro h;
  · obtain ⟨ x, hx ⟩ := h;
    have := ZMod.exists_sq_eq_neg_one_iff ( p := p );
    exact this.mp ⟨ x, by rw [ sq ] at hx; linear_combination' hx.symm ⟩ |> fun h => by have := Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) ; omega;
  · have := ZMod.exists_sq_eq_neg_one_iff ( p := p );
    exact Exists.elim ( this.mpr ( by linarith ) ) fun x hx => ⟨ x, by rw [ sq, hx ] ⟩


/-- [Section: # CatalogBuild.Speculative.QuadraticReciprocity
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem two_qr_iff (p : ℕ) [Fact (Nat.Prime p)] (hodd : p ≠ 2) :
    (∃ x : ZMod p, x ^ 2 = 2) ↔ p % 8 = 1 ∨ p % 8 = 7 := by
  -- By definition of quadratic residue, we know that $2$ is a quadratic residue modulo $p$ if and only if $\left(\frac{2}{p}\right) = 1$.
  have h_legendre : (∃ x : ZMod p, x ^ 2 = 2) ↔ (legendreSym p 2 = 1) := by
    rw [ legendreSym.eq_one_iff ];
    · exact ⟨ fun ⟨ x, hx ⟩ => ⟨ x, by simpa [ sq, ← ZMod.intCast_eq_intCast_iff ] using hx.symm ⟩, fun ⟨ x, hx ⟩ => ⟨ x, by simpa [ sq, ← ZMod.intCast_eq_intCast_iff ] using hx.symm ⟩ ⟩;
    · simp +zetaDelta at *;
      erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( lt_of_le_of_ne ( Nat.Prime.two_le Fact.out ) ( Ne.symm hodd ) );
  convert h_legendre using 1;
  rw [ legendreSym.at_two ];
  · erw [ ZMod.χ₈_nat_mod_eight ] ; have := Nat.mod_lt p ( by decide : 0 < 8 ) ; interval_cases _ : p % 8 <;> simp +decide [ * ];
  · assumption


/-- Quadratic residues are closed under powers. -/
theorem qr_pow_closed (n : ℕ) (a : ZMod n) (k : ℕ) (hqr : ∃ x : ZMod n, x ^ 2 = a) :
    ∃ y : ZMod n, y ^ 2 = a ^ k := by
  obtain ⟨x, hx⟩ := hqr
  exact ⟨x ^ k, by rw [← pow_mul, mul_comm, pow_mul, hx]⟩


/-- The set of QRs mod n forms a submonoid under multiplication. -/
theorem qr_one (n : ℕ) : ∃ x : ZMod n, x ^ 2 = (1 : ZMod n) :=
  ⟨1, by ring⟩


theorem qr_mul' (n : ℕ) (a b : ZMod n)
    (ha : ∃ x : ZMod n, x ^ 2 = a)
    (hb : ∃ y : ZMod n, y ^ 2 = b) :
    ∃ z : ZMod n, z ^ 2 = a * b := by
  obtain ⟨x, hx⟩ := ha
  obtain ⟨y, hy⟩ := hb
  exact ⟨x * y, by rw [mul_pow, hx, hy]⟩


theorem two_qr_mod_7 : ∃ x : ZMod 7, x ^ 2 = 2 := ⟨3, by decide⟩

-- 2 is NOT a QR mod 5: check all residues


theorem two_not_qr_mod_5 : ¬ ∃ x : ZMod 5, x ^ 2 = 2 := by decide

-- -1 is a QR mod 5 (since 5 ≡ 1 mod 4): 2² = 4 ≡ -1 (mod 5)


theorem neg_one_qr_mod_5 : ∃ x : ZMod 5, x ^ 2 = -1 := ⟨2, by decide⟩

-- -1 is NOT a QR mod 3 (since 3 ≡ 3 mod 4)


theorem neg_one_not_qr_mod_3 : ¬ ∃ x : ZMod 3, x ^ 2 = -1 := by decide


