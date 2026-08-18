import Mathlib

/-! # CatalogBuild.Speculative.BerggrenPythagoreanCore

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 59
-/

/-- A triple (a,b,c) is Pythagorean if a² + b² = c². -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren child A -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- Inverse Berggren A: B₁⁻¹ = Q B₁ᵀ Q where Q = diag(1,1,-1) -/
def invA (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- Inverse Berggren B -/
def invB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Inverse Berggren C -/
def invC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- The Lorentz quadratic form `a² + b² − c²` of signature `(2,1)`.  A triple is
Pythagorean exactly when it is a null vector of this form. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

theorem isPythag_iff_lorentzQ_zero (a b c : ℤ) : IsPythag a b c ↔ lorentzQ a b c = 0 := by
  unfold IsPythag lorentzQ; omega

/-- [Section: # CatalogBuild.Speculative.BerggrenPythagoreanCore
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 59] -/
theorem bergA_pyth (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythag bergA at *; nlinarith [h]

/-- [Section: # CatalogBuild.Speculative.BerggrenPythagoreanCore
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 59] -/
theorem bergB_pyth (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythag bergB at *; nlinarith [h]

theorem bergC_pyth (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythag bergC at *; nlinarith [h]

theorem bergA_preserves_Q (a b c : ℤ) :
    lorentzQ (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = lorentzQ a b c := by
  simp only [lorentzQ, bergA]; ring

theorem bergB_preserves_Q (a b c : ℤ) :
    lorentzQ (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = lorentzQ a b c := by
  simp only [lorentzQ, bergB]; ring

theorem bergC_preserves_Q (a b c : ℤ) :
    lorentzQ (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = lorentzQ a b c := by
  simp only [lorentzQ, bergC]; ring

def B₁_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

def B₂_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def B₃_mat : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

def QLor : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

theorem det_B₁ : Matrix.det B₁_mat = 1 := by
  simp [B₁_mat, Matrix.det_fin_three]

theorem det_B₂ : Matrix.det B₂_mat = -1 := by
  simp [B₂_mat, Matrix.det_fin_three]

theorem det_B₃ : Matrix.det B₃_mat = 1 := by
  simp [B₃_mat, Matrix.det_fin_three]

/-- B₁, B₃ are in SO(2,1;ℤ) while B₂ is in O(2,1;ℤ) \ SO(2,1;ℤ) -/
theorem det_asymmetry : Matrix.det B₁_mat = 1 ∧ Matrix.det B₂_mat = -1 ∧ Matrix.det B₃_mat = 1 :=
  ⟨det_B₁, det_B₂, det_B₃⟩

/-- Product of Berggren matrices remains in O(2,1;ℤ) -/
theorem B₁B₂_lorentz : (B₁_mat * B₂_mat).transpose * QLor * (B₁_mat * B₂_mat) = QLor := by
  decide

theorem B₁B₂B₃_lorentz :
    (B₁_mat * B₂_mat * B₃_mat).transpose * QLor * (B₁_mat * B₂_mat * B₃_mat) = QLor := by
  decide

theorem fwd_inv_A (a b c : ℤ) :
    invA (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = (a, b, c) := by
  simp only [bergA, invA, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem fwd_inv_B (a b c : ℤ) :
    invB (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = (a, b, c) := by
  simp only [bergB, invB, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem fwd_inv_C (a b c : ℤ) :
    invC (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = (a, b, c) := by
  simp only [bergC, invC, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem inv_fwd_A (a b c : ℤ) :
    bergA (invA a b c).1 (invA a b c).2.1 (invA a b c).2.2 = (a, b, c) := by
  simp only [bergA, invA, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem inv_fwd_B (a b c : ℤ) :
    bergB (invB a b c).1 (invB a b c).2.1 (invB a b c).2.2 = (a, b, c) := by
  simp only [bergB, invB, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem inv_fwd_C (a b c : ℤ) :
    bergC (invC a b c).1 (invC a b c).2.1 (invC a b c).2.2 = (a, b, c) := by
  simp only [bergC, invC, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem bergA_root : bergA 3 4 5 = (5, 12, 13) := by decide

theorem bergB_root : bergB 3 4 5 = (21, 20, 29) := by decide

theorem bergC_root : bergC 3 4 5 = (15, 8, 17) := by decide

theorem invA_recovers : invA 5 12 13 = (3, 4, 5) := by decide

theorem invB_recovers : invB 21 20 29 = (3, 4, 5) := by decide

theorem invC_recovers : invC 15 8 17 = (3, 4, 5) := by decide

theorem bergA_depth2 : bergA 5 12 13 = (7, 24, 25) := by decide

theorem bergB_depth2 : bergB 21 20 29 = (119, 120, 169) := by decide

theorem bergA_hyp_increase (a b c : ℤ) (ha : 0 < a) (_ : 0 < b) (_ : 0 < c)
    (_ : a < c) (hbc : b < c) :
    c < (bergA a b c).2.2 := by
  unfold bergA; nlinarith

theorem bergB_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (bergB a b c).2.2 := by
  unfold bergB; nlinarith

theorem bergC_hyp_increase (a b c : ℤ) (_ : 0 < a) (hb : 0 < b) (_ : 0 < c)
    (hab : a < c) (_ : b < c) :
    c < (bergC a b c).2.2 := by
  unfold bergC; nlinarith

theorem dvd_sq_hyp_of_dvd_legs (a b c d : ℤ) (h : IsPythag a b c)
    (ha : d ∣ a) (hb : d ∣ b) : d ^ 2 ∣ c ^ 2 := by
  exact h ▸ dvd_add ( pow_dvd_pow_of_dvd ha 2 ) ( pow_dvd_pow_of_dvd hb 2 )

theorem dvd_hyp_of_dvd_legs (a b c d : ℤ) (h : IsPythag a b c)
    (ha : d ∣ a) (hb : d ∣ b) : d ∣ c := by
  obtain ⟨ k₁, rfl ⟩ := ha;
  obtain ⟨ k₂, rfl ⟩ := hb;
  exact Int.pow_dvd_pow_iff two_ne_zero |>.1 ⟨ k₁ ^ 2 + k₂ ^ 2, by linarith! [ h.symm ] ⟩

theorem bergA_prim (a b c : ℤ) (h : IsPythag a b c) (hprim : Int.gcd a b = 1) :
    Int.gcd (bergA a b c).1 (bergA a b c).2.1 = 1 := by
  -- Assume there exists a prime $p$ such that $p$ divides both $(bergA a b c).1$ and $(bergA a b c).2.1$.
  by_contra h_contra
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ (bergA a b c).1 ∧ (p : ℤ) ∣ (bergA a b c).2.1 := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h_contra |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩;
  -- Since a'² + b'² = c'², we get p | c' by dvd_hyp_of_dvd_legs.
  have hp_div_c : (p : ℤ) ∣ (bergA a b c).2.2 := by
    exact dvd_hyp_of_dvd_legs _ _ _ _ ( bergA_pyth _ _ _ h ) hp_div.1 hp_div.2;
  -- Now from the inverse formula invA: a = a' + 2b' - 2c', b = -2a' - b' + 2c', c = -2a' - 2b' + 3c'.
  have h_inv : a = (bergA a b c).1 + 2 * (bergA a b c).2.1 - 2 * (bergA a b c).2.2 ∧ b = -2 * (bergA a b c).1 - (bergA a b c).2.1 + 2 * (bergA a b c).2.2 ∧ c = -2 * (bergA a b c).1 - 2 * (bergA a b c).2.1 + 3 * (bergA a b c).2.2 := by
    unfold bergA; ring_nf; aesop;
  exact Nat.Prime.not_dvd_one hp_prime ( hprim ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd ( show ( p : ℤ ) ∣ a from h_inv.1.symm ▸ dvd_sub ( dvd_add hp_div.1 ( dvd_mul_of_dvd_right hp_div.2 _ ) ) ( dvd_mul_of_dvd_right hp_div_c _ ) ) ( show ( p : ℤ ) ∣ b from h_inv.2.1.symm ▸ dvd_add ( dvd_sub ( dvd_mul_of_dvd_right hp_div.1 _ ) hp_div.2 ) ( dvd_mul_of_dvd_right hp_div_c _ ) ) ) )

theorem bergB_prim (a b c : ℤ) (h : IsPythag a b c) (hprim : Int.gcd a b = 1) :
    Int.gcd (bergB a b c).1 (bergB a b c).2.1 = 1 := by
  by_contra h_contra;
  -- Let p be a prime that divides both components of bergB a b c.
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ (bergB a b c).1 ∧ (p : ℤ) ∣ (bergB a b c).2.1 := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h_contra |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩;
  -- Then p divides c' by dvd_hyp_of_dvd_legs.
  have hp_div_c : (p : ℤ) ∣ (bergB a b c).2.2 := by
    exact dvd_hyp_of_dvd_legs _ _ _ _ ( bergB_pyth _ _ _ h ) hp_div.1 hp_div.2;
  -- From invB: a = a'+2b'-2c', b = 2a'+b'-2c', c = -2a'-2b'+3c'. Since p|a',b',c', we get p|a and p|b.
  have hp_div_a : (p : ℤ) ∣ a := by
    have hp_div_a : (p : ℤ) ∣ (bergB a b c).1 + 2 * (bergB a b c).2.1 - 2 * (bergB a b c).2.2 := by
      exact dvd_sub ( dvd_add hp_div.1 ( dvd_mul_of_dvd_right hp_div.2 _ ) ) ( dvd_mul_of_dvd_right hp_div_c _ );
    convert hp_div_a using 1 ; unfold bergB ; ring
  have hp_div_b : (p : ℤ) ∣ b := by
    simp_all +decide [ IsPythag, bergB ];
    haveI := Fact.mk hp_prime; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
    grind;
  exact Nat.Prime.not_dvd_one hp_prime ( hprim ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd hp_div_a hp_div_b ) )

theorem bergC_prim (a b c : ℤ) (h : IsPythag a b c) (hprim : Int.gcd a b = 1) :
    Int.gcd (bergC a b c).1 (bergC a b c).2.1 = 1 := by
  -- Let $d = \gcd(a - 2b + 2c, 2a - b + 2c)$.
  set d := Int.gcd (bergC a b c).1 (bergC a b c).2.1;
  -- Then $d \mid c'$, because $c'^2 = a'^2 + b'^2$.
  have hd_div_c' : (d : ℤ) ∣ (bergC a b c).2.2 := by
    exact dvd_hyp_of_dvd_legs _ _ _ _ ( bergC_pyth _ _ _ h ) ( Int.gcd_dvd_left _ _ ) ( Int.gcd_dvd_right _ _ );
  -- By definition of $invC$, we have $a = -a' - 2b' + 2c'$, $b = 2a' + b' - 2c'$, and $c = -2a' - 2b' + 3c'$.
  have h_invC : a = -(bergC a b c).1 - 2 * (bergC a b c).2.1 + 2 * (bergC a b c).2.2 ∧ b = 2 * (bergC a b c).1 + (bergC a b c).2.1 - 2 * (bergC a b c).2.2 ∧ c = -2 * (bergC a b c).1 - 2 * (bergC a b c).2.1 + 3 * (bergC a b c).2.2 := by
    unfold bergC; ring_nf; aesop;
  -- Since $d \mid a'$, $d \mid b'$, and $d \mid c'$, it follows that $d \mid a$ and $d \mid b$.
  have hd_div_a : (d : ℤ) ∣ a := by
    exact h_invC.1.symm ▸ dvd_add ( dvd_sub ( dvd_neg.mpr ( Int.gcd_dvd_left _ _ ) ) ( dvd_mul_of_dvd_right ( Int.gcd_dvd_right _ _ ) _ ) ) ( dvd_mul_of_dvd_right hd_div_c' _ )
  have hd_div_b : (d : ℤ) ∣ b := by
    exact h_invC.2.1.symm ▸ dvd_sub ( dvd_add ( dvd_mul_of_dvd_right ( Int.gcd_dvd_left _ _ ) _ ) ( Int.gcd_dvd_right _ _ ) ) ( dvd_mul_of_dvd_right hd_div_c' _ );
  exact Nat.dvd_one.mp ( hprim ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd hd_div_a hd_div_b ) )

/-- B-branch hypotenuse sequence: c₀=5, c₁=29, c_{n+2} = 6c_{n+1} - cₙ -/
def bHyp : ℕ → ℤ
  | 0 => 5
  | 1 => 29
  | n + 2 => 6 * bHyp (n + 1) - bHyp n

theorem bHyp_recurrence (n : ℕ) : bHyp (n + 2) = 6 * bHyp (n + 1) - bHyp n := rfl

theorem bHyp_values : bHyp 0 = 5 ∧ bHyp 1 = 29 ∧ bHyp 2 = 169 ∧ bHyp 3 = 985 ∧ bHyp 4 = 5741 := by
  constructor; · rfl
  constructor; · rfl
  constructor; · decide
  constructor; · decide
  · decide

/-- The Pell recurrence checks: 6·29-5=169, 6·169-29=985, 6·985-169=5741 -/
theorem pell_checks :
    6 * 29 - 5 = (169 : ℤ) ∧ 6 * 169 - 29 = (985 : ℤ) ∧ 6 * 985 - 169 = (5741 : ℤ) := by
  omega

theorem bHyp_increasing (n : ℕ) : bHyp n < bHyp (n + 1) := by
  -- We can prove this by induction on $n$.
  have h_ind : ∀ n, 0 < bHyp n ∧ bHyp n < bHyp (n + 1) := by
    intro n; induction n <;> simp_all +decide [ bHyp ] ; omega;
  exact h_ind n |>.2

/-- Steps in the Berggren tree -/
inductive BerggrenStep where | A | B | C
  deriving DecidableEq, Repr

/-- Applying one Berggren step to a triple. -/
def applyStep : BerggrenStep → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .A, (a, b, c) => bergA a b c
  | .B, (a, b, c) => bergB a b c
  | .C, (a, b, c) => bergC a b c

/-- Following a finite path of Berggren steps from the root triple `(3,4,5)`. -/
def applyPath (path : List BerggrenStep) : ℤ × ℤ × ℤ :=
  path.foldl (fun t s => applyStep s t) (3, 4, 5)

@[simp] theorem applyPath_nil : applyPath [] = (3, 4, 5) := rfl

theorem applyPath_concat (path : List BerggrenStep) (s : BerggrenStep) :
    applyPath (path ++ [s]) = applyStep s (applyPath path) := by
  simp [applyPath]

/-- Any Berggren step preserves the Pythagorean property -/
theorem step_preserves_pyth (s : BerggrenStep) (a b c : ℤ) (h : IsPythag a b c) :
    let t := applyStep s (a, b, c)
    IsPythag t.1 t.2.1 t.2.2 := by
  cases s <;> simp [applyStep]
  · exact bergA_pyth a b c h
  · exact bergB_pyth a b c h
  · exact bergC_pyth a b c h

theorem path_preserves_pyth (path : List BerggrenStep) :
    let t := applyPath path
    IsPythag t.1 t.2.1 t.2.2 := by
  induction' path using List.reverseRecOn with s l ih;
  · exact show IsPythag 3 4 5 from by trivial;
  · convert step_preserves_pyth l _ _ _ ih using 1;
    unfold applyPath; aesop;

/-- Binary expression tree -/
inductive BinTree (α : Type*) where
  | leaf : α → BinTree α
  | node : BinTree α → BinTree α → BinTree α

def BinTree.leaves : BinTree α → ℕ
  | .leaf _ => 1
  | .node l r => l.leaves + r.leaves

def BinTree.internals : BinTree α → ℕ
  | .leaf _ => 0
  | .node l r => 1 + l.internals + r.internals

theorem bin_tree_leaf_count (t : BinTree α) : t.leaves = t.internals + 1 := by
  induction t;
  · rfl;
  · simp +arith +decide [ *, BinTree.leaves, BinTree.internals ]

/-- Euclid parametrization: (m,n) ↦ (m²-n², 2mn, m²+n²) -/
def euclid (m n : ℤ) : ℤ × ℤ × ℤ := (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

theorem euclid_is_pythag (m n : ℤ) :
    IsPythag (euclid m n).1 (euclid m n).2.1 (euclid m n).2.2 := by
  unfold IsPythag euclid; ring

theorem euclid_root : euclid 2 1 = (3, 4, 5) := by decide

theorem euclid_5_12_13 : euclid 3 2 = (5, 12, 13) := by decide

theorem euclid_8_15_17 : euclid 4 1 = (15, 8, 17) := by decide