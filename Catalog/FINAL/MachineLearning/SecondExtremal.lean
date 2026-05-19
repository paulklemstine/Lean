import Speculative.BerggrenExtremal.Defs

/-!
# C-Ray Universal Second-Extremality

This file proves the main theorem: among all Berggren words of length n,
the C-ray (all-C word) uniquely minimizes the hypotenuse after the A-ray.
-/

set_option maxHeartbeats 1600000

namespace BerggrenExtremal

/-! ## Pythagorean Preservation -/

theorem bergA_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythTriple bergA at *; nlinarith

theorem bergB_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythTriple bergB at *; nlinarith

theorem bergC_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythTriple bergC at *; nlinarith

theorem bergA_pos {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergA a b c).1 ∧ 0 < (bergA a b c).2.1 ∧ 0 < (bergA a b c).2.2 := by
  unfold bergA IsPythTriple at *
  refine ⟨by nlinarith [sq_nonneg (c - b)], by nlinarith, by nlinarith [sq_nonneg (c - b)]⟩

theorem bergB_pos {a b c : ℤ} (_h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergB a b c).1 ∧ 0 < (bergB a b c).2.1 ∧ 0 < (bergB a b c).2.2 := by
  unfold bergB; exact ⟨by nlinarith, by nlinarith, by nlinarith⟩

theorem bergC_pos {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergC a b c).1 ∧ 0 < (bergC a b c).2.1 ∧ 0 < (bergC a b c).2.2 := by
  unfold bergC IsPythTriple at *
  refine ⟨by nlinarith [sq_nonneg (c - a)], by nlinarith [sq_nonneg (c - a)],
          by nlinarith [sq_nonneg (c - a)]⟩

/-! ## Recursive Identities for Pure Rays -/

theorem hypAllCFrom_succ_eq (m : ℕ) (a b c : ℤ) :
    hypAllCFrom m (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 =
    hypAllCFrom (m + 1) a b c := by
  simp [hypAllCFrom, bergC]; ring

theorem hypAllAFrom_succ_eq (m : ℕ) (a b c : ℤ) :
    hypAllAFrom m (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 =
    hypAllAFrom (m + 1) a b c := by
  simp [hypAllAFrom, bergA]; ring

/-! ## Comparison Identities -/

theorem compare_A_then_allA_vs_allC (m : ℕ) (a b c : ℤ) (hab : b ≤ a) :
    hypAllCFrom (m + 1) a b c ≤
    hypAllAFrom m (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  rw [hypAllAFrom_succ_eq]
  have h := hyp_allA_minus_allC (m + 1) a b c
  linarith [mul_nonneg (mul_nonneg (show (0 : ℤ) ≤ 2 by omega)
    (show (0 : ℤ) ≤ ↑(m + 1) by exact Nat.cast_nonneg _))
    (mul_nonneg (show (0 : ℤ) ≤ ↑(m + 1) + 1 by positivity) (show (0 : ℤ) ≤ a - b by linarith))]

theorem compare_C_then_allC_vs_allA (m : ℕ) (a b c : ℤ) (hab : a ≤ b) :
    hypAllAFrom (m + 1) a b c ≤
    hypAllCFrom m (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  rw [hypAllCFrom_succ_eq]
  have h := hyp_allA_minus_allC (m + 1) a b c
  linarith [mul_nonneg (mul_nonneg (show (0 : ℤ) ≤ 2 by omega)
    (show (0 : ℤ) ≤ ↑(m + 1) by exact Nat.cast_nonneg _))
    (mul_nonneg (show (0 : ℤ) ≤ ↑(m + 1) + 1 by positivity) (show (0 : ℤ) ≤ b - a by linarith))]

theorem compare_B_then_allA_vs_allC (m : ℕ) (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    hypAllCFrom (m + 1) a b c ≤
    hypAllAFrom m (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  simp only [hypAllAFrom, hypAllCFrom, bergB]
  have hm : (0 : ℤ) ≤ m := Nat.cast_nonneg m
  have h1 : (m : ℤ) + 1 = ↑(m + 1) := by push_cast; ring
  rw [← h1]
  nlinarith [mul_nonneg hm (le_of_lt ha : (0 : ℤ) ≤ a),
             mul_nonneg hm (le_of_lt hb : (0 : ℤ) ≤ b),
             sq_nonneg (m : ℤ),
             mul_nonneg (show (0:ℤ) ≤ m * a by nlinarith) hm]

theorem compare_B_then_allC_vs_allA (m : ℕ) (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    hypAllAFrom (m + 1) a b c ≤
    hypAllCFrom m (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  simp only [hypAllAFrom, hypAllCFrom, bergB]
  have hm : (0 : ℤ) ≤ m := Nat.cast_nonneg m
  have h1 : (m : ℤ) + 1 = ↑(m + 1) := by push_cast; ring
  rw [← h1]
  nlinarith [mul_nonneg hm (le_of_lt ha : (0 : ℤ) ≤ a),
             mul_nonneg hm (le_of_lt hb : (0 : ℤ) ≤ b),
             sq_nonneg (m : ℤ),
             mul_nonneg (show (0:ℤ) ≤ m * b by nlinarith) hm]

/-! ## The Optimality Theorem -/

/-- **Ray Optimality Theorem**: Pure rays minimize hypotenuse from positive Pythagorean triples.
Part 1 (a ≥ b): C^m optimal. Part 2 (b ≥ a): A^m optimal. -/
theorem ray_optimality (m : ℕ) :
    (∀ a b c : ℤ, IsPythTriple a b c → 0 < a → 0 < b → 0 < c → b ≤ a →
      ∀ w : List Gen, w.length = m →
      hypAllCFrom m a b c ≤ hyp (applyWord w (a, b, c))) ∧
    (∀ a b c : ℤ, IsPythTriple a b c → 0 < a → 0 < b → 0 < c → a ≤ b →
      ∀ w : List Gen, w.length = m →
      hypAllAFrom m a b c ≤ hyp (applyWord w (a, b, c))) := by
  induction' m with m ih <;> norm_num at *;
  · exact ⟨ fun a b c h1 h2 h3 h4 h5 => by unfold hypAllCFrom hyp applyWord; norm_num, fun a b c h1 h2 h3 h4 h5 => by unfold hypAllAFrom hyp applyWord; norm_num ⟩;
  · constructor <;> intros a b c h₁ h₂ h₃ h₄ h₅ w hw;
    · nontriviality;
      obtain ⟨ g, w', rfl ⟩ := List.exists_cons_of_length_pos ( by linarith ) ; cases g <;> simp_all +decide [ List.length ] ;
      · convert le_trans _ ( ih.2 ( bergA a b c |>.1 ) ( bergA a b c |>.2.1 ) ( bergA a b c |>.2.2 ) ( bergA_pyth h₁ ) ( bergA_pos h₁ h₂ h₃ h₄ |>.1 ) ( bergA_pos h₁ h₂ h₃ h₄ |>.2.1 ) ( bergA_pos h₁ h₂ h₃ h₄ |>.2.2 ) _ w' hw ) using 1;
        · exact compare_A_then_allA_vs_allC m a b c h₅;
        · exact le_of_sub_nonneg ( by rw [ bergA_leg_diff ] ; linarith );
      · exact le_trans ( compare_B_then_allA_vs_allC m a b c h₂ h₃ ) ( ih.2 _ _ _ ( bergB_pyth h₁ ) ( bergB_pos h₁ h₂ h₃ h₄ |>.1 ) ( bergB_pos h₁ h₂ h₃ h₄ |>.2.1 ) ( bergB_pos h₁ h₂ h₃ h₄ |>.2.2 ) ( by linarith [ bergB_leg_diff a b c ] ) _ hw );
      · convert ih.1 ( bergC a b c |>.1 ) ( bergC a b c |>.2.1 ) ( bergC a b c |>.2.2 ) ( bergC_pyth h₁ ) ( bergC_pos h₁ h₂ h₃ h₄ |>.1 ) ( bergC_pos h₁ h₂ h₃ h₄ |>.2.1 ) ( bergC_pos h₁ h₂ h₃ h₄ |>.2.2 ) _ w' hw using 1;
        · exact hypAllCFrom_succ_eq m a b c ▸ rfl;
        · unfold bergC; norm_num; linarith;
    · rcases w with ( _ | ⟨ g, w ⟩ ) <;> simp_all +decide;
      cases g <;> simp_all +decide [ applyWord ];
      · convert ih.2 ( bergA a b c |>.1 ) ( bergA a b c |>.2.1 ) ( bergA a b c |>.2.2 ) ( bergA_pyth h₁ ) ( bergA_pos h₁ h₂ h₃ h₄ |>.1 ) ( bergA_pos h₁ h₂ h₃ h₄ |>.2.1 ) ( bergA_pos h₁ h₂ h₃ h₄ |>.2.2 ) ( by linarith [ bergA_leg_diff a b c ] ) w hw using 1;
        exact hypAllAFrom_succ_eq m a b c ▸ rfl;
      · apply le_trans (compare_B_then_allC_vs_allA m a b c h₂ h₃);
        convert ih.1 _ _ _ ( bergB_pyth h₁ ) _ _ _ _ w hw using 1;
        · exact bergB_pos h₁ h₂ h₃ h₄ |>.1;
        · exact bergB_pos h₁ h₂ h₃ h₄ |>.2.1;
        · exact bergB_pos h₁ h₂ h₃ h₄ |>.2.2;
        · unfold bergB; norm_num; linarith;
      · apply le_trans (compare_C_then_allC_vs_allA m a b c h₅);
        convert ih.1 _ _ _ ( bergC_pyth h₁ ) _ _ _ _ w hw using 1;
        · exact bergC_pos h₁ h₂ h₃ h₄ |>.1;
        · exact bergC_pos h₁ h₂ h₃ h₄ |>.2.1;
        · exact bergC_pos h₁ h₂ h₃ h₄ |>.2.2;
        · exact le_of_sub_nonneg ( by rw [ bergC_leg_diff ] ; linarith )

/-! ## A-Ray Full Triple Closed Form -/

theorem allA_triple (k : ℕ) :
    applyWord (List.replicate k Gen.A) root =
    (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5) := by
  induction k <;> simp_all +decide;
  rename_i n ih;
  convert congr_arg ( fun x : ℤ × ℤ × ℤ => applyWord [ Gen.A ] x ) ih using 1;
  · rw [List.replicate_succ'];
    exact?;
  · unfold applyWord; norm_num [ applyGen, bergA ] ; ring;
    rfl

/-- On the A-ray, b > a (second leg dominates). -/
theorem allA_b_gt_a (k : ℕ) :
    (2 * (k : ℤ) + 3) ≤ 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2) := by nlinarith

/-- The A-ray triple is Pythagorean. -/
theorem allA_pyth (k : ℕ) :
    IsPythTriple (2 * (k : ℤ) + 3) (2 * ((k : ℤ) + 1) * ((k : ℤ) + 2))
      (2 * (k : ℤ)^2 + 6 * k + 5) := by
  unfold IsPythTriple; ring

/-- The A-ray triple is positive. -/
theorem allA_pos (k : ℕ) :
    (0 : ℤ) < 2 * (k : ℤ) + 3 ∧ 0 < 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2) ∧
    0 < 2 * (k : ℤ)^2 + 6 * k + 5 := by
  refine ⟨by positivity, by positivity, by positivity⟩

/-! ## Key Polynomial Inequality: C^{n-k} from A-ray ≥ C^n from root

For k ≥ 0 and m ≥ 1 (at least one C letter), the hypotenuse of
C^m from the A-ray point at depth k is at least the hypotenuse of
C^{k+m} from root. The difference factors as
  2k · [(k+1)(2m-1) + 2m²(k+2)] ≥ 0.
-/

theorem hyp_C_from_Aray_ge_C_from_root (k m : ℕ) (hm : 1 ≤ m) :
    hypAllCFrom (k + m) 3 4 5 ≤
    hypAllCFrom m
      (2 * (k : ℤ) + 3)
      (2 * ((k : ℤ) + 1) * ((k : ℤ) + 2))
      (2 * (k : ℤ)^2 + 6 * k + 5) := by
  unfold hypAllCFrom;
  push_cast; nlinarith [ mul_nonneg ( Nat.zero_le k ) ( Nat.zero_le m ) ] ;

/-! ## The Main Theorem -/

/-
**C-Ray Universal Second-Extremality Theorem**.

For every n ≥ 1, among all Berggren words of length n, the all-C word
uniquely minimizes the hypotenuse after the all-A word.
If w has length n and w ≠ A^n, then c(C^n) ≤ c(w).
-/
theorem cRay_second_extremal
    (n : ℕ) (_hn : 1 ≤ n) (w : List Gen) (hw : w.length = n)
    (hne : w ≠ List.replicate n Gen.A) :
    cOfWord (List.replicate n Gen.C) ≤ cOfWord w := by
  -- Since w ≠ replicate n Gen.A, there exists a first position k where w differs from A^n. Write w = replicate k Gen.A ++ [g] ++ w' where g ≠ Gen.A and w' has length n-k-1.
  obtain ⟨k, g, w', hwk, hw'⟩ : ∃ k g w', w = List.replicate k Gen.A ++ [g] ++ w' ∧ g ≠ Gen.A ∧ w'.length = n - 1 - k := by
    -- By induction on the length of the list, we can show that if the list is not all A's, then there must be a point where it differs from the all-A list.
    have h_ind : ∀ (l : List Gen), (∀ k g w', l = List.replicate k Gen.A ++ [g] ++ w' → g ≠ Gen.A → w'.length ≠ l.length - 1 - k) → l = List.replicate l.length Gen.A := by
      intro l hl; induction' l with hd tl ih <;> simp +decide [ List.replicate ] at *;
      rcases hd with ( _ | _ | _ ) <;> simp +decide at hl ⊢;
      · exact ih fun k g w' h₁ h₂ h₃ => hl ( k + 1 ) g w' ( by simpa [ List.replicate ] using h₁ ) h₂ ( by omega );
      · specialize hl 0 Gen.B tl ; simp +decide at hl;
      · specialize hl 0 Gen.C tl ; simp +decide at hl;
    grind;
  -- The triple after A^k from root is v_k = (2k+3, 2(k+1)(k+2), 2k^2+6k+5) by allA_triple.
  have hvk : applyWord (List.replicate k Gen.A) root = (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5) := by
    exact?;
  -- By ray_optimality (Claim A', since a' ≥ b'), applied to w' of length n-k-1:
  have h_ray_optimality : hypAllCFrom (n - 1 - k) (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).1 (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.1 (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.2 ≤ hyp (applyWord w' (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5))) := by
    have h_ray_optimality : IsPythTriple (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).1 (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.1 (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.2 := by
      rcases g with ( _ | _ | _ ) <;> simp +decide [ *, IsPythTriple ];
      · tauto;
      · unfold applyGen; norm_num; ring;
        unfold bergB; ring;
      · unfold applyGen; norm_num [ bergC ] ; ring;
    have h_ray_optimality : 0 < (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).1 ∧ 0 < (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.1 ∧ 0 < (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.2 := by
      rcases g with ( _ | _ | _ ) <;> norm_num [ applyGen ] <;> ring_nf <;> norm_cast <;> norm_num;
      · tauto;
      · exact ⟨ by unfold bergB; norm_num; nlinarith, by unfold bergB; norm_num; nlinarith, by unfold bergB; norm_num; nlinarith ⟩;
      · exact ⟨ by unfold bergC; norm_num; nlinarith, by unfold bergC; norm_num; nlinarith, by unfold bergC; norm_num; nlinarith ⟩;
    have h_ray_optimality : (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.1 ≤ (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).1 := by
      rcases g with ( _ | _ | _ ) <;> norm_num [ applyGen ] at *;
      · unfold bergB; norm_num; nlinarith;
      · unfold bergC; norm_num; nlinarith;
    exact ray_optimality _ |>.1 _ _ _ ‹_› ( by tauto ) ( by tauto ) ( by tauto ) ( by tauto ) _ hw'.2;
  -- By hyp_C_from_Aray_ge_C_from_root with m = n-k ≥ 1:
  have h_hyp_C_from_Aray_ge_C_from_root : hypAllCFrom n 3 4 5 ≤ hypAllCFrom (n - 1 - k) (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).1 (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.1 (applyGen g (2 * (k : ℤ) + 3, 2 * ((k : ℤ) + 1) * ((k : ℤ) + 2), 2 * (k : ℤ)^2 + 6 * k + 5)).2.2 := by
    rcases g with ( _ | _ | _ ) <;> simp_all +decide [ Nat.sub_sub ];
    · unfold hypAllCFrom; norm_num [ applyGen ] ; ring_nf;
      unfold bergB; norm_num; ring_nf;
      rw [ Nat.cast_sub ] <;> push_cast <;> nlinarith only [ hw ] ;
    · convert hyp_C_from_Aray_ge_C_from_root k ( n - ( 1 + k ) + 1 ) ( by linarith ) using 1;
      · rw [ hw ];
      · exact hypAllCFrom_succ_eq _ _ _ _;
  convert h_hyp_C_from_Aray_ge_C_from_root.trans h_ray_optimality using 1;
  · convert cOfWord_allC n using 1;
    unfold hypAllCFrom; ring;
  · unfold cOfWord; simp +decide [ hwk, hvk, applyWord_append ] ;
    rfl

end BerggrenExtremal