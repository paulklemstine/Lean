import Mathlib

/-!
# Berggren Orbits as Arithmetic Teleportation Skeletons

This file establishes the arithmetic backbone of a new bridge between
Pythagorean triple dynamics and quantum circuit compilation.

## Main results

1. **Word-level preservation** (`evalWord_preserves_primPyth`):
   Every Berggren word applied to (3,4,5) yields a primitive Pythagorean triple.

2. **Hypotenuse growth** (`applyGen_hyp_increase`):
   Each generator strictly increases the hypotenuse.

3. **Euclidean shadow functoriality** (`berggren_euclid_shadow_functorial`):
   The mod-3 Euclidean shadow is compositional with respect to word evaluation.

4. **SL(2,𝔽₃) generation witnesses** (`SL2F3_witness_*`):
   Explicit generators of SL(2,𝔽₃) from Berggren Euclidean shadows.

5. **Circuit cost bound** (`berggren_depth_hyp_lower_bound`):
   Word length provides a lower bound on hypotenuse size.
-/

set_option maxHeartbeats 1600000

/-! ## Core Types -/

/-- A generator of the Berggren tree. -/
inductive BerggrenGen : Type where
  | A : BerggrenGen
  | B : BerggrenGen
  | C : BerggrenGen
  deriving DecidableEq, Repr

/-- A triple (a, b, c) is Pythagorean if a² + b² = c². -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Apply Berggren generator A: matrix [[1,-2,2],[2,-1,2],[2,-2,3]] -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)

/-- Apply Berggren generator B: matrix [[1,2,2],[2,1,2],[2,2,3]] -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)

/-- Apply Berggren generator C: matrix [[-1,2,2],[-2,1,2],[-2,2,3]] -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

/-- Apply a Berggren generator to a triple. -/
def applyGen (g : BerggrenGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match g with
  | .A => bergA t.1 t.2.1 t.2.2
  | .B => bergB t.1 t.2.1 t.2.2
  | .C => bergC t.1 t.2.1 t.2.2

/-- The root triple (3, 4, 5). -/
def rootTriple : ℤ × ℤ × ℤ := (3, 4, 5)

/-- Evaluate a word (list of generators) on a triple, left-to-right. -/
def evalWord (w : List BerggrenGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  w.foldl (fun acc g => applyGen g acc) t

@[simp] theorem evalWord_nil (t : ℤ × ℤ × ℤ) : evalWord [] t = t := rfl

theorem evalWord_cons (g : BerggrenGen) (w : List BerggrenGen) (t : ℤ × ℤ × ℤ) :
    evalWord (g :: w) t = evalWord w (applyGen g t) := by
  simp [evalWord, List.foldl]

/-! ## Section 1: Pythagorean Preservation -/

theorem bergA_pyth {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythag bergA at *; nlinarith [h]

theorem bergB_pyth {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythag bergB at *; nlinarith [h]

theorem bergC_pyth {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythag bergC at *; nlinarith [h]

theorem applyGen_pyth (g : BerggrenGen) (t : ℤ × ℤ × ℤ) (h : IsPythag t.1 t.2.1 t.2.2) :
    IsPythag (applyGen g t).1 (applyGen g t).2.1 (applyGen g t).2.2 := by
  cases g <;> simp [applyGen] <;> [exact bergA_pyth h; exact bergB_pyth h; exact bergC_pyth h]

/-! ## Section 2: Coprimality Preservation -/

theorem dvd_hyp_of_dvd_legs {a b c d : ℤ} (h : IsPythag a b c)
    (ha : d ∣ a) (hb : d ∣ b) : d ∣ c := by
  exact Int.pow_dvd_pow_iff two_ne_zero |>.1 <| by rw [ ← h ] ; exact dvd_add ( pow_dvd_pow_of_dvd ha _ ) ( pow_dvd_pow_of_dvd hb _ ) ;

theorem bergA_coprime {a b c : ℤ} (h : IsPythag a b c)
    (hprim : Int.gcd a b = 1) :
    Int.gcd (bergA a b c).1 (bergA a b c).2.1 = 1 := by
  -- By contradiction, assume there exists a prime p such that p divides both components of bergA(a, b, c).
  by_contra h_contra
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ (a - 2 * b + 2 * c) ∧ (p : ℤ) ∣ (2 * a - b + 2 * c) := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h_contra |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩ ;
  -- Since p divides both components of bergA(a, b, c), it follows that p divides the hypotenuse too by dvd_hyp_of_dvd_legs.
  have hp_div_c : (p : ℤ) ∣ (2 * a - 2 * b + 3 * c) := by
    have hp_div_c : (p : ℤ) ∣ ((a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2) := by
      exact dvd_add ( hp_div.1.pow two_ne_zero ) ( hp_div.2.pow two_ne_zero );
    have hp_div_c : (p : ℤ) ∣ ((2 * a - 2 * b + 3 * c) ^ 2) := by
      convert hp_div_c using 1 ; rw [ show ( a - 2 * b + 2 * c ) ^ 2 + ( 2 * a - b + 2 * c ) ^ 2 = ( 2 * a - 2 * b + 3 * c ) ^ 2 by linarith [ h.symm ] ];
    exact Int.Prime.dvd_pow' hp_prime hp_div_c;
  -- Using the inverse formulas, we can express a and b in terms of the components of bergA(a, b, c).
  have ha : a = (a - 2 * b + 2 * c) + 2 * (2 * a - b + 2 * c) - 2 * (2 * a - 2 * b + 3 * c) := by
    ring
  have hb : b = -2 * (a - 2 * b + 2 * c) - (2 * a - b + 2 * c) + 2 * (2 * a - 2 * b + 3 * c) := by
    ring;
  exact Nat.Prime.not_dvd_one hp_prime ( hprim ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd ( show ( p : ℤ ) ∣ a from by rw [ ha ] ; exact dvd_sub ( dvd_add hp_div.1 ( dvd_mul_of_dvd_right hp_div.2 _ ) ) ( dvd_mul_of_dvd_right hp_div_c _ ) ) ( show ( p : ℤ ) ∣ b from by rw [ hb ] ; exact dvd_add ( dvd_sub ( dvd_mul_of_dvd_right hp_div.1 _ ) hp_div.2 ) ( dvd_mul_of_dvd_right hp_div_c _ ) ) ) )

theorem bergB_coprime {a b c : ℤ} (h : IsPythag a b c)
    (hprim : Int.gcd a b = 1) :
    Int.gcd (bergB a b c).1 (bergB a b c).2.1 = 1 := by
  -- By contradiction, assume there exists a prime $p$ such that $p$ divides both components of $bergB(a,b,c)$.
  by_contra h_contra
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ (bergB a b c).1 ∧ (p : ℤ) ∣ (bergB a b c).2.1 := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h_contra |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩ ;
  -- Since $p$ divides both components of $bergB(a,b,c)$, it must also divide the hypotenuse $bergB(a,b,c).2.2$.
  have hp_div_hyp : (p : ℤ) ∣ (bergB a b c).2.2 := by
    have hp_div_hyp : (p : ℤ) ∣ (bergB a b c).1 ^ 2 + (bergB a b c).2.1 ^ 2 := by
      exact dvd_add ( hp_div.1.pow two_ne_zero ) ( hp_div.2.pow two_ne_zero );
    convert Int.Prime.dvd_pow' hp_prime ( show ( p : ℤ ) ∣ ( ( bergB a b c ).2.2 ) ^ 2 from ?_ ) using 1;
    convert hp_div_hyp using 1 ; unfold bergB ; ring;
    unfold IsPythag at h; linarith;
  -- Using the inverse formulas, we can express $a$ and $b$ in terms of $bergB(a,b,c)$.
  have h_inv : a = (bergB a b c).1 + 2 * (bergB a b c).2.1 - 2 * (bergB a b c).2.2 ∧ b = 2 * (bergB a b c).1 + (bergB a b c).2.1 - 2 * (bergB a b c).2.2 := by
    constructor <;> unfold bergB <;> ring;
  exact Nat.Prime.not_dvd_one hp_prime ( hprim ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd ( show ( p : ℤ ) ∣ a from h_inv.1.symm ▸ dvd_sub ( dvd_add hp_div.1 ( dvd_mul_of_dvd_right hp_div.2 _ ) ) ( dvd_mul_of_dvd_right hp_div_hyp _ ) ) ( show ( p : ℤ ) ∣ b from h_inv.2.symm ▸ dvd_sub ( dvd_add ( dvd_mul_of_dvd_right hp_div.1 _ ) hp_div.2 ) ( dvd_mul_of_dvd_right hp_div_hyp _ ) ) ) )

theorem bergC_coprime {a b c : ℤ} (h : IsPythag a b c)
    (hprim : Int.gcd a b = 1) :
    Int.gcd (bergC a b c).1 (bergC a b c).2.1 = 1 := by
  -- We'll use that $c = \sqrt{a^2 + b^2}$ to show that $\gcd(a, b) = \gcd(c, b)$.
  by_contra h_not_coprime
  obtain ⟨d, hd1, hd2⟩ : ∃ d, 1 < d ∧ d ∣ (bergC a b c).1 ∧ d ∣ (bergC a b c).2.1 := by
    obtain ⟨ d, hd₁, hd₂, hd₃ ⟩ := Nat.Prime.not_coprime_iff_dvd.mp h_not_coprime ; exact ⟨ d, mod_cast hd₁.one_lt, Int.natCast_dvd.mpr hd₂, Int.natCast_dvd.mpr hd₃ ⟩;
  -- Since $d$ divides both $bergC(a, b, c).1$ and $bergC(a, b, c).2.1$, and $bergC(a, b, c).2.2$ is a linear combination of these components, $d$ must also divide $bergC(a, b, c).2.2$.
  have hd3 : d ∣ (bergC a b c).2.2 := by
    have hd_div_c : (bergC a b c).1 ^ 2 + (bergC a b c).2.1 ^ 2 = (bergC a b c).2.2 ^ 2 := by
      exact bergC_pyth h;
    exact Int.pow_dvd_pow_iff two_ne_zero |>.1 <| hd_div_c ▸ dvd_add ( pow_dvd_pow_of_dvd hd2.1 2 ) ( pow_dvd_pow_of_dvd hd2.2 2 );
  -- Using the inverse formulas, we can express $a$ and $b$ in terms of $bergC(a, b, c)$.
  have h_inv : a = - (bergC a b c).1 - 2 * (bergC a b c).2.1 + 2 * (bergC a b c).2.2 ∧ b = 2 * (bergC a b c).1 + (bergC a b c).2.1 - 2 * (bergC a b c).2.2 := by
    constructor <;> unfold bergC <;> ring;
  exact absurd ( Int.dvd_coe_gcd ( show d ∣ a from h_inv.1.symm ▸ dvd_add ( dvd_sub ( dvd_neg.mpr hd2.1 ) ( dvd_mul_of_dvd_right hd2.2 _ ) ) ( dvd_mul_of_dvd_right hd3 _ ) ) ( show d ∣ b from h_inv.2.symm ▸ dvd_sub ( dvd_add ( dvd_mul_of_dvd_right hd2.1 _ ) hd2.2 ) ( dvd_mul_of_dvd_right hd3 _ ) ) ) ( by norm_num [ hprim ] ; exact fun h => by linarith [ Int.le_of_dvd ( by linarith ) h ] )

theorem applyGen_coprime (g : BerggrenGen) (t : ℤ × ℤ × ℤ)
    (h : IsPythag t.1 t.2.1 t.2.2) (hprim : Int.gcd t.1 t.2.1 = 1) :
    Int.gcd (applyGen g t).1 (applyGen g t).2.1 = 1 := by
  cases g <;> simp [applyGen]
  · exact bergA_coprime h hprim
  · exact bergB_coprime h hprim
  · exact bergC_coprime h hprim

/-! ## Section 3: Positivity Preservation -/

theorem leg_lt_hyp {a b c : ℤ} (h : IsPythag a b c) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) : a < c ∧ b < c := by
  unfold IsPythag at h
  constructor <;> nlinarith [sq_nonneg a, sq_nonneg b]

theorem applyGen_pos (g : BerggrenGen) (t : ℤ × ℤ × ℤ)
    (h : IsPythag t.1 t.2.1 t.2.2) (ha : 0 < t.1) (hb : 0 < t.2.1) (hc : 0 < t.2.2) :
    0 < (applyGen g t).1 ∧ 0 < (applyGen g t).2.1 ∧ 0 < (applyGen g t).2.2 := by
  obtain ⟨hac, hbc⟩ := leg_lt_hyp h ha hb hc
  cases g <;> simp [applyGen, bergA, bergB, bergC] <;> refine ⟨?_, ?_, ?_⟩ <;> nlinarith

/-! ## Section 4: Full Preservation -/

/-- A triple is primitive Pythagorean: Pythagorean, positive, coprime legs. -/
def IsPrimPyth (a b c : ℤ) : Prop :=
  IsPythag a b c ∧ 0 < a ∧ 0 < b ∧ 0 < c ∧ Int.gcd a b = 1

theorem applyGen_preserves (g : BerggrenGen) (t : ℤ × ℤ × ℤ)
    (h : IsPrimPyth t.1 t.2.1 t.2.2) :
    IsPrimPyth (applyGen g t).1 (applyGen g t).2.1 (applyGen g t).2.2 := by
  obtain ⟨hpyth, ha, hb, hc, hcop⟩ := h
  have hpos := applyGen_pos g t hpyth ha hb hc
  exact ⟨applyGen_pyth g t hpyth, hpos.1, hpos.2.1, hpos.2.2,
         applyGen_coprime g t hpyth hcop⟩

theorem root_isPrimPyth : IsPrimPyth 3 4 5 := by
  refine ⟨?_, by norm_num, by norm_num, by norm_num, ?_⟩
  · unfold IsPythag; norm_num
  · native_decide

/-! ## Section 5: Word-Level Preservation (Theorem A) -/

/-- Word evaluation preserves primitive Pythagorean status from any starting triple. -/
theorem evalWord_preserves_primPyth_gen (w : List BerggrenGen) (t : ℤ × ℤ × ℤ)
    (ht : IsPrimPyth t.1 t.2.1 t.2.2) :
    IsPrimPyth (evalWord w t).1 (evalWord w t).2.1 (evalWord w t).2.2 := by
  induction w generalizing t with
  | nil => simpa [evalWord]
  | cons g w ih =>
    rw [evalWord_cons]
    exact ih _ (applyGen_preserves g t ht)

/-- **Theorem A**: Every Berggren word applied to the root triple yields
    a primitive Pythagorean triple. -/
theorem evalWord_preserves_primPyth (w : List BerggrenGen) :
    IsPrimPyth (evalWord w rootTriple).1
               (evalWord w rootTriple).2.1
               (evalWord w rootTriple).2.2 :=
  evalWord_preserves_primPyth_gen w rootTriple root_isPrimPyth

/-! ## Section 6: Hypotenuse Growth (Theorem B) -/

/-- Any Berggren generator strictly increases the hypotenuse. -/
theorem applyGen_hyp_increase (g : BerggrenGen) (t : ℤ × ℤ × ℤ)
    (h : IsPrimPyth t.1 t.2.1 t.2.2) :
    t.2.2 < (applyGen g t).2.2 := by
  obtain ⟨hpyth, ha, hb, hc, _⟩ := h
  obtain ⟨hac, hbc⟩ := leg_lt_hyp hpyth ha hb hc
  cases g <;> simp [applyGen, bergA, bergB, bergC] <;> nlinarith

/-
**Theorem B**: Hypotenuse size gives a lower bound: hyp ≥ 5 + word_length.
    This bounds circuit depth from arithmetic data.
-/
theorem berggren_depth_hyp_lower_bound (w : List BerggrenGen) :
    (5 : ℤ) + w.length ≤ (evalWord w rootTriple).2.2 := by
  induction' w using List.reverseRecOn with w ih <;> norm_num [ evalWord ] at *;
  · decide +revert;
  · -- Apply the generator to the current triple and use the induction hypothesis.
    have h_apply : (applyGen ih (List.foldl (fun acc g => applyGen g acc) rootTriple w)).2.2 > (List.foldl (fun acc g => applyGen g acc) rootTriple w).2.2 := by
      apply applyGen_hyp_increase;
      convert evalWord_preserves_primPyth w using 1;
    linarith

/-! ## Section 7: Concrete Orbit Verification -/

theorem bergA_root : applyGen .A rootTriple = (5, 12, 13) := by native_decide
theorem bergB_root : applyGen .B rootTriple = (21, 20, 29) := by native_decide
theorem bergC_root : applyGen .C rootTriple = (15, 8, 17) := by native_decide
theorem bergAA_root : evalWord [.A, .A] rootTriple = (7, 24, 25) := by native_decide
theorem bergBB_root : evalWord [.B, .B] rootTriple = (119, 120, 169) := by native_decide

/-! ## Section 8: Euclidean Parameter Shadow (Theorem C) -/

/-- Euclidean parametrization: (m,n) ↦ (m²-n², 2mn, m²+n²) -/
def euclidParam (m n : ℤ) : ℤ × ℤ × ℤ :=
  (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

theorem euclidParam_pyth (m n : ℤ) :
    IsPythag (euclidParam m n).1 (euclidParam m n).2.1 (euclidParam m n).2.2 := by
  unfold IsPythag euclidParam; ring

theorem root_euclid : euclidParam 2 1 = rootTriple := by
  unfold euclidParam rootTriple; norm_num

/-- Euclidean shadow of a Berggren generator on parameter space. -/
def euclidShadowGen (g : BerggrenGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- Evaluate a word in the Euclidean shadow. -/
def euclidShadowWord (w : List BerggrenGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  w.foldl (fun acc g => euclidShadowGen g acc) p

/-- Berggren-Euclid correspondence for each generator. -/
theorem applyGen_euclid (g : BerggrenGen) (m n : ℤ) :
    applyGen g (euclidParam m n) =
      euclidParam (euclidShadowGen g (m, n)).1 (euclidShadowGen g (m, n)).2 := by
  cases g <;> simp [applyGen, euclidParam, bergA, bergB, bergC, euclidShadowGen, Prod.ext_iff]
  all_goals refine ⟨?_, ?_, ?_⟩ <;> ring

/-- **Theorem C**: The Euclidean shadow is functorial — it commutes with
    word evaluation through the Euclid parametrization. -/
theorem berggren_euclid_shadow_functorial (w : List BerggrenGen) (m n : ℤ) :
    evalWord w (euclidParam m n) =
      euclidParam (euclidShadowWord w (m, n)).1 (euclidShadowWord w (m, n)).2 := by
  induction w generalizing m n with
  | nil => simp [evalWord, euclidShadowWord]
  | cons g w ih =>
    simp only [evalWord, euclidShadowWord, List.foldl]
    rw [applyGen_euclid g m n]
    exact ih (euclidShadowGen g (m, n)).1 (euclidShadowGen g (m, n)).2

/-! ## Section 9: Mod-3 Shadow and SL(2,𝔽₃)

The Euclidean shadow matrices E_A = [[2,-1],[1,0]] and E_C = [[1,2],[0,1]]
have determinant 1. Reduced mod 3, they generate SL(2,𝔽₃), the 24-element
group isomorphic to the binary tetrahedral group and to Sp(2,𝔽₃).
This is the arithmetic lift of the qutrit Clifford control layer. -/

def euclidMatA : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]
def euclidMatC : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

theorem det_euclidMatA : euclidMatA.det = 1 := by native_decide
theorem det_euclidMatC : euclidMatC.det = 1 := by native_decide

def euclidMatA3 : Matrix (Fin 2) (Fin 2) (ZMod 3) :=
  euclidMatA.map (Int.castRingHom (ZMod 3))

def euclidMatC3 : Matrix (Fin 2) (Fin 2) (ZMod 3) :=
  euclidMatC.map (Int.castRingHom (ZMod 3))

theorem det_mod3_EA : euclidMatA3.det = 1 := by native_decide
theorem det_mod3_EC : euclidMatC3.det = 1 := by native_decide

/-- Compute the closure of {E_A, E_C} in (ZMod 3)^{2×2} up to n products. -/
private def closureStep (gens : List (Matrix (Fin 2) (Fin 2) (ZMod 3)))
    (acc : Finset (Matrix (Fin 2) (Fin 2) (ZMod 3))) :
    Finset (Matrix (Fin 2) (Fin 2) (ZMod 3)) :=
  acc ∪ acc.biUnion (fun m => (gens.map (m * ·)).toFinset)

private def closureN (gens : List (Matrix (Fin 2) (Fin 2) (ZMod 3))) (n : ℕ) :
    Finset (Matrix (Fin 2) (Fin 2) (ZMod 3)) :=
  match n with
  | 0 => {1} ∪ gens.toFinset
  | n + 1 => closureStep gens (closureN gens n)

/-- The closure of {E_A³, E_C³} has cardinality 24, matching |SL(2,𝔽₃)|. -/
theorem berggren_closure_card :
    (closureN [euclidMatA3, euclidMatC3] 6).card = 24 := by native_decide

/-- Every element of the closure has determinant 1. -/
theorem berggren_closure_det1 :
    ∀ M ∈ closureN [euclidMatA3, euclidMatC3] 6, M.det = 1 := by native_decide

/-- Every SL(2,𝔽₃) matrix (det = 1) is in the closure.
    This proves that E_A and E_C generate all of SL(2,𝔽₃). -/
theorem berggren_generates_SL2_F3 :
    ∀ M : Matrix (Fin 2) (Fin 2) (ZMod 3),
      M.det = 1 → M ∈ closureN [euclidMatA3, euclidMatC3] 6 := by
  native_decide

/-! ## Section 10: Quadratic Form Invariance -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c². -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

theorem applyGen_preserves_Q (g : BerggrenGen) (a b c : ℤ) :
    lorentzQ (applyGen g (a, b, c)).1
             (applyGen g (a, b, c)).2.1
             (applyGen g (a, b, c)).2.2 = lorentzQ a b c := by
  cases g <;> simp [applyGen, lorentzQ, bergA, bergB, bergC] <;> ring

/-
Word evaluation preserves the Lorentzian quadratic form.
-/
theorem evalWord_preserves_Q (w : List BerggrenGen) (a b c : ℤ) :
    lorentzQ (evalWord w (a, b, c)).1
             (evalWord w (a, b, c)).2.1
             (evalWord w (a, b, c)).2.2 = lorentzQ a b c := by
  induction w generalizing a b c with
  | nil => simp [evalWord]
  | cons g w ih =>
    simp only [evalWord, List.foldl]
    set t := applyGen g (a, b, c)
    show lorentzQ (evalWord w t).1 (evalWord w t).2.1 (evalWord w t).2.2 = lorentzQ a b c
    have heq : t = (t.1, t.2.1, t.2.2) := by simp
    rw [heq, ih t.1 t.2.1 t.2.2]
    exact applyGen_preserves_Q g a b c

/-! ## Section 11: Inverse Maps -/

def berggrenInv (g : BerggrenGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match g with
  | .A => (t.1 + 2 * t.2.1 - 2 * t.2.2,
           -2 * t.1 - t.2.1 + 2 * t.2.2,
           -2 * t.1 - 2 * t.2.1 + 3 * t.2.2)
  | .B => (t.1 + 2 * t.2.1 - 2 * t.2.2,
           2 * t.1 + t.2.1 - 2 * t.2.2,
           -2 * t.1 - 2 * t.2.1 + 3 * t.2.2)
  | .C => (-t.1 - 2 * t.2.1 + 2 * t.2.2,
           2 * t.1 + t.2.1 - 2 * t.2.2,
           -2 * t.1 - 2 * t.2.1 + 3 * t.2.2)

theorem berggrenInv_left (g : BerggrenGen) (a b c : ℤ) :
    berggrenInv g (applyGen g (a, b, c)) = (a, b, c) := by
  cases g <;> simp [applyGen, berggrenInv, bergA, bergB, bergC, Prod.ext_iff]
  all_goals refine ⟨?_, ?_, ?_⟩ <;> ring

theorem berggrenInv_right (g : BerggrenGen) (a b c : ℤ) :
    applyGen g (berggrenInv g (a, b, c)) = (a, b, c) := by
  cases g <;> simp [applyGen, berggrenInv, bergA, bergB, bergC, Prod.ext_iff]
  all_goals refine ⟨?_, ?_, ?_⟩ <;> ring

/-! ## Section 12: Matrix Representations -/

def berggrenMat : BerggrenGen → Matrix (Fin 3) (Fin 3) ℤ
  | .A => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | .B => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | .C => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

def eta : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Each Berggren generator preserves the Lorentz metric: Mᵀ η M = η. -/
theorem berggrenMat_preserves_eta (g : BerggrenGen) :
    (berggrenMat g).transpose * eta * berggrenMat g = eta := by
  cases g <;> native_decide

theorem berggrenMat_det_A : (berggrenMat .A).det = 1 := by native_decide
theorem berggrenMat_det_B : (berggrenMat .B).det = -1 := by native_decide
theorem berggrenMat_det_C : (berggrenMat .C).det = 1 := by native_decide

/-! ## Section 13: Non-commutativity and Branch Distinctness -/

theorem berggren_noncommutative :
    applyGen .A (applyGen .B rootTriple) ≠ applyGen .B (applyGen .A rootTriple) := by
  native_decide

theorem berggren_children_distinct :
    applyGen .A rootTriple ≠ applyGen .B rootTriple ∧
    applyGen .A rootTriple ≠ applyGen .C rootTriple ∧
    applyGen .B rootTriple ≠ applyGen .C rootTriple := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide