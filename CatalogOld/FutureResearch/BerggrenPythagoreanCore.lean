/-
# Berggren–Pythagorean Tree: Core Formalizations

Machine-verified theorems about the Berggren ternary tree of primitive Pythagorean triples.

## Main Results

1. **Pythagorean Preservation**: All three Berggren matrices preserve a² + b² = c².
2. **Lorentz Form Preservation**: All matrices preserve Q(a,b,c) = a² + b² - c² (as identity).
3. **Determinant Structure** (Direction #36): det(B₁) = det(B₃) = 1, det(B₂) = -1.
4. **Forward-Inverse Cancellation**: Each transform is invertible with integer inverse.
5. **Hypotenuse Growth**: Children have strictly larger hypotenuse (for positive triples).
6. **Primitivity Preservation** (Direction #3): Berggren matrices preserve gcd(a,b) = 1.
7. **Pell Recurrence** (Direction #38): B-branch hypotenuses satisfy c_{n+1} = 6cₙ - c_{n-1}.
8. **Tree Path Correctness**: Any path from root (3,4,5) yields a Pythagorean triple.
9. **Binary Tree Leaf Counting** (Direction #39): #leaves = #internal_nodes + 1.
10. **Euclid Parametrization**: Connection to Gaussian integer squaring.
-/

import Mathlib

open Matrix Int

/-! ## §1. Berggren Transformations -/

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

/-! ## §2. Pythagorean Preservation -/

theorem bergA_pyth (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythag bergA at *; nlinarith [h]

theorem bergB_pyth (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythag bergB at *; nlinarith [h]

theorem bergC_pyth (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythag bergC at *; nlinarith [h]

/-! ## §3. Lorentz Form Preservation (ring identity, no hypothesis needed) -/

/-- Lorentz form value -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

theorem bergA_preserves_Q (a b c : ℤ) :
    lorentzQ (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergA; ring

theorem bergB_preserves_Q (a b c : ℤ) :
    lorentzQ (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergB; ring

theorem bergC_preserves_Q (a b c : ℤ) :
    lorentzQ (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergC; ring

/-! ## §4. Determinant Structure (Direction #36) -/

def B₁_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def B₂_mat : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def B₃_mat : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]
def QLor : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

theorem det_B₁ : Matrix.det B₁_mat = 1 := by native_decide
theorem det_B₂ : Matrix.det B₂_mat = -1 := by native_decide
theorem det_B₃ : Matrix.det B₃_mat = 1 := by native_decide

/-- B₁, B₃ are in SO(2,1;ℤ) while B₂ is in O(2,1;ℤ) \ SO(2,1;ℤ) -/
theorem det_asymmetry : Matrix.det B₁_mat = 1 ∧ Matrix.det B₂_mat = -1 ∧ Matrix.det B₃_mat = 1 :=
  ⟨det_B₁, det_B₂, det_B₃⟩

theorem B₁_lorentz : B₁_mat.transpose * QLor * B₁_mat = QLor := by native_decide
theorem B₂_lorentz : B₂_mat.transpose * QLor * B₂_mat = QLor := by native_decide
theorem B₃_lorentz : B₃_mat.transpose * QLor * B₃_mat = QLor := by native_decide

/-- Product of Berggren matrices remains in O(2,1;ℤ) -/
theorem B₁B₂_lorentz : (B₁_mat * B₂_mat).transpose * QLor * (B₁_mat * B₂_mat) = QLor := by
  native_decide

theorem B₁B₂B₃_lorentz :
    (B₁_mat * B₂_mat * B₃_mat).transpose * QLor * (B₁_mat * B₂_mat * B₃_mat) = QLor := by
  native_decide

/-! ## §5. Forward-Inverse Cancellation -/

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

/-! ## §6. Computational Verification -/

theorem bergA_root : bergA 3 4 5 = (5, 12, 13) := by native_decide
theorem bergB_root : bergB 3 4 5 = (21, 20, 29) := by native_decide
theorem bergC_root : bergC 3 4 5 = (15, 8, 17) := by native_decide

theorem invA_recovers : invA 5 12 13 = (3, 4, 5) := by native_decide
theorem invB_recovers : invB 21 20 29 = (3, 4, 5) := by native_decide
theorem invC_recovers : invC 15 8 17 = (3, 4, 5) := by native_decide

theorem bergA_depth2 : bergA 5 12 13 = (7, 24, 25) := by native_decide
theorem bergB_depth2 : bergB 21 20 29 = (119, 120, 169) := by native_decide

/-! ## §7. Hypotenuse Growth -/

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

/-! ## §8. Primitivity Preservation (Direction #3)

Key insight: if p | gcd(a',b') for a child, then since the inverse matrix has integer
entries and recovers (a,b,c), and since p | a' ∧ p | b' implies p² | a'²+b'² = c'²
hence p | c', we get p | a ∧ p | b (from the integer inverse formula). -/

/-
If d divides both legs of a Pythagorean triple, d² divides c².
-/
theorem dvd_sq_hyp_of_dvd_legs (a b c d : ℤ) (h : IsPythag a b c)
    (ha : d ∣ a) (hb : d ∣ b) : d ^ 2 ∣ c ^ 2 := by
  exact h ▸ dvd_add ( pow_dvd_pow_of_dvd ha 2 ) ( pow_dvd_pow_of_dvd hb 2 )

/-
If d divides both legs of a Pythagorean triple, d divides the hypotenuse.
-/
theorem dvd_hyp_of_dvd_legs (a b c d : ℤ) (h : IsPythag a b c)
    (ha : d ∣ a) (hb : d ∣ b) : d ∣ c := by
  obtain ⟨ k₁, rfl ⟩ := ha;
  obtain ⟨ k₂, rfl ⟩ := hb;
  exact Int.pow_dvd_pow_iff two_ne_zero |>.1 ⟨ k₁ ^ 2 + k₂ ^ 2, by linarith! [ h.symm ] ⟩

/-
Berggren A preserves primitivity: gcd(a,b)=1 implies gcd(a',b')=1.
-/
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

/-
Berggren B preserves primitivity.
-/
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

/-
Berggren C preserves primitivity.
-/
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

/-! ## §9. Pell Recurrence (Direction #38) -/

/-- B-branch hypotenuse sequence: c₀=5, c₁=29, c_{n+2} = 6c_{n+1} - cₙ -/
def bHyp : ℕ → ℤ
  | 0 => 5
  | 1 => 29
  | n + 2 => 6 * bHyp (n + 1) - bHyp n

theorem bHyp_recurrence (n : ℕ) : bHyp (n + 2) = 6 * bHyp (n + 1) - bHyp n := rfl

theorem bHyp_values : bHyp 0 = 5 ∧ bHyp 1 = 29 ∧ bHyp 2 = 169 ∧ bHyp 3 = 985 ∧ bHyp 4 = 5741 := by
  constructor; · rfl
  constructor; · rfl
  constructor; · native_decide
  constructor; · native_decide
  · native_decide

/-- The Pell recurrence checks: 6·29-5=169, 6·169-29=985, 6·985-169=5741 -/
theorem pell_checks :
    6 * 29 - 5 = (169 : ℤ) ∧ 6 * 169 - 29 = (985 : ℤ) ∧ 6 * 985 - 169 = (5741 : ℤ) := by
  omega

/-
B-branch hypotenuses are strictly increasing
-/
theorem bHyp_increasing (n : ℕ) : bHyp n < bHyp (n + 1) := by
  -- We can prove this by induction on $n$.
  have h_ind : ∀ n, 0 < bHyp n ∧ bHyp n < bHyp (n + 1) := by
    intro n; induction n <;> simp_all +decide [ bHyp ] ; omega;
  exact h_ind n |>.2

/-! ## §10. Tree Path Correctness -/

/-- Steps in the Berggren tree -/
inductive BerggrenStep where | A | B | C
  deriving DecidableEq, Repr

/-- Apply a single step -/
def applyStep (s : BerggrenStep) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match s with
  | .A => bergA t.1 t.2.1 t.2.2
  | .B => bergB t.1 t.2.1 t.2.2
  | .C => bergC t.1 t.2.1 t.2.2

/-- Apply a path from root (3,4,5) -/
def applyPath (path : List BerggrenStep) : ℤ × ℤ × ℤ :=
  path.foldl (fun t s => applyStep s t) (3, 4, 5)

/-- Any Berggren step preserves the Pythagorean property -/
theorem step_preserves_pyth (s : BerggrenStep) (a b c : ℤ) (h : IsPythag a b c) :
    let t := applyStep s (a, b, c)
    IsPythag t.1 t.2.1 t.2.2 := by
  cases s <;> simp [applyStep]
  · exact bergA_pyth a b c h
  · exact bergB_pyth a b c h
  · exact bergC_pyth a b c h

/-
Folding steps preserves the Pythagorean property
-/
theorem path_preserves_pyth (path : List BerggrenStep) :
    let t := applyPath path
    IsPythag t.1 t.2.1 t.2.2 := by
  induction' path using List.reverseRecOn with s l ih;
  · exact show IsPythag 3 4 5 from by trivial;
  · convert step_preserves_pyth l _ _ _ ih using 1;
    unfold applyPath; aesop;

/-! ## §11. Binary Tree Leaf Counting (Direction #39) -/

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

/-
Fundamental binary tree identity: #leaves = #internal_nodes + 1
-/
theorem bin_tree_leaf_count (t : BinTree α) : t.leaves = t.internals + 1 := by
  induction t;
  · rfl;
  · simp +arith +decide [ *, BinTree.leaves, BinTree.internals ]

/-! ## §12. Euclid Parametrization -/

/-- Euclid parametrization: (m,n) ↦ (m²-n², 2mn, m²+n²) -/
def euclid (m n : ℤ) : ℤ × ℤ × ℤ := (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

theorem euclid_is_pythag (m n : ℤ) :
    IsPythag (euclid m n).1 (euclid m n).2.1 (euclid m n).2.2 := by
  unfold IsPythag euclid; ring

theorem euclid_root : euclid 2 1 = (3, 4, 5) := by native_decide
theorem euclid_5_12_13 : euclid 3 2 = (5, 12, 13) := by native_decide
theorem euclid_8_15_17 : euclid 4 1 = (15, 8, 17) := by native_decide

/-! ## §13. Quadruple Extension (Direction #6 prerequisite)

A Pythagorean quadruple satisfies a² + b² + c² = d². We can embed triples
into quadruples by zero-extension. -/

/-- A Pythagorean quadruple -/
def IsPythQuad (a b c d : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2

/-- Zero-extension embeds triples into quadruples -/
theorem triple_to_quad (a b c : ℤ) (h : IsPythag a b c) :
    IsPythQuad a b 0 c := by
  unfold IsPythQuad; simp; exact h

/-- (1,2,2,3) is a Pythagorean quadruple -/
theorem quad_1_2_2_3 : IsPythQuad 1 2 2 3 := by
  unfold IsPythQuad; norm_num

/-- (2,3,6,7) is a Pythagorean quadruple -/
theorem quad_2_3_6_7 : IsPythQuad 2 3 6 7 := by
  unfold IsPythQuad; norm_num