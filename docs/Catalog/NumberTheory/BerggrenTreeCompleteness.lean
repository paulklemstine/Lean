import Mathlib

/-!
# The Berggren ternary tree: closure and completeness

Berggren's three matrices

```
B₁ = ⎡ 1 -2  2⎤   B₂ = ⎡1 2 2⎤   B₃ = ⎡-1  2 2⎤
     ⎢ 2 -1  2⎥        ⎢2 1 2⎥        ⎢-2  1 2⎥
     ⎣ 2 -2  3⎦        ⎣2 2 3⎦        ⎣-2  2 3⎦
```

act on integer triples.  Starting from the root `(3,4,5)` they generate a ternary
tree.  This file proves the two halves of Berggren's theorem in the form needed
for counting:

* `reach_valid` : every triple in the tree is a *positive primitive Pythagorean
  triple with odd first leg* (`Valid`);
* `valid_reach` : conversely every such triple lies in the tree.  The proof is a
  descent: the "parent hypotenuse" `w = 3c - 2a - 2b` satisfies `0 < w < c`, and
  exactly one of the three inverse matrices returns a positive triple, the sign
  pattern being governed by `u = a + 2b - 2c` and `v = 2a + b - 2c`.

Together (`reach_iff_valid`) the tree is *exactly* the set of positive primitive
Pythagorean triples with odd first leg.
-/

namespace BerggrenTree

/-- A triple of integers. -/
abbrev Tri := ℤ × ℤ × ℤ

/-- Berggren child `B₁`. -/
def bA (t : Tri) : Tri :=
  (t.1 - 2 * t.2.1 + 2 * t.2.2, 2 * t.1 - t.2.1 + 2 * t.2.2, 2 * t.1 - 2 * t.2.1 + 3 * t.2.2)

/-- Berggren child `B₂`. -/
def bB (t : Tri) : Tri :=
  (t.1 + 2 * t.2.1 + 2 * t.2.2, 2 * t.1 + t.2.1 + 2 * t.2.2, 2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- Berggren child `B₃`. -/
def bC (t : Tri) : Tri :=
  (-t.1 + 2 * t.2.1 + 2 * t.2.2, -2 * t.1 + t.2.1 + 2 * t.2.2, -2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- The Berggren tree rooted at `(3,4,5)`. -/
inductive Reach : Tri → Prop
  | root : Reach (3, 4, 5)
  | stepA {t : Tri} : Reach t → Reach (bA t)
  | stepB {t : Tri} : Reach t → Reach (bB t)
  | stepC {t : Tri} : Reach t → Reach (bC t)

/-- A positive primitive Pythagorean triple with odd first leg. -/
def Valid (t : Tri) : Prop :=
  0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧
    Int.gcd t.1 t.2.1 = 1 ∧ t.1 % 2 = 1

/-- No integer `> 1` divides all three coordinates. -/
def Prim3 (t : Tri) : Prop := ∀ d : ℤ, d ∣ t.1 → d ∣ t.2.1 → d ∣ t.2.2 → IsUnit d

/-- Auxiliary: a common divisor of three quantities divides any integer combination. -/
lemma dvd_lin {d x y z : ℤ} (hx : d ∣ x) (hy : d ∣ y) (hz : d ∣ z) (p q r : ℤ) :
    d ∣ p * x + q * y + r * z :=
  dvd_add (dvd_add (hx.mul_left p) (hy.mul_left q)) (hz.mul_left r)

lemma prim3_of_gcd (a b c : ℤ) (h : Int.gcd a b = 1) : Prim3 (a, b, c) := by
  intro d hda hdb _
  exact (Int.isCoprime_iff_gcd_eq_one.mpr h).isUnit_of_dvd' hda hdb

lemma gcd_of_prim3 {a b c : ℤ} (hp : Prim3 (a, b, c)) (hpy : a ^ 2 + b ^ 2 = c ^ 2) :
    Int.gcd a b = 1 := by
  have hga : ((Int.gcd a b : ℤ)) ∣ a := Int.gcd_dvd_left a b
  have hgb : ((Int.gcd a b : ℤ)) ∣ b := Int.gcd_dvd_right a b
  have hgc : ((Int.gcd a b : ℤ)) ∣ c := by
    have h2 : ((Int.gcd a b : ℤ)) ^ 2 ∣ c ^ 2 := by
      rw [← hpy]
      exact dvd_add (pow_dvd_pow_of_dvd hga 2) (pow_dvd_pow_of_dvd hgb 2)
    exact (Int.pow_dvd_pow_iff (by norm_num)).1 h2
  have hu := hp _ hga hgb hgc
  have hcase := Int.isUnit_iff.1 hu
  have hnn : (0 : ℤ) ≤ ((Int.gcd a b : ℤ)) := by positivity
  omega

/-! ### Closure: children of a valid triple are valid -/

lemma hyp_gt_leg {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2) : b < c ∧ a < c := by
  constructor <;> nlinarith

lemma valid_bA {t : Tri} (h : Valid t) : Valid (bA t) := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := h
  simp only at ha hb hc hpy hgcd hodd
  obtain ⟨hbc, hac⟩ := hyp_gt_leg ha hb hc hpy
  refine ⟨by simp only [bA]; linarith, by simp only [bA]; linarith,
    by simp only [bA]; linarith, by simp only [bA]; ring_nf; linarith [hpy], ?_, ?_⟩
  · -- primitivity
    have hp3 : Prim3 (bA (a, b, c)) := by
      intro d hd1 hd2 hd3
      simp only [bA] at hd1 hd2 hd3
      have hda : d ∣ a := by
        have hex : a = 1 * (a - 2 * b + 2 * c) + 2 * (2 * a - b + 2 * c)
            + (-2) * (2 * a - 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 1 2 (-2)
        rwa [← hex] at hcomb
      have hdb : d ∣ b := by
        have hex : b = (-2) * (a - 2 * b + 2 * c) + (-1) * (2 * a - b + 2 * c)
            + 2 * (2 * a - 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 (-2) (-1) 2
        rwa [← hex] at hcomb
      have hdc : d ∣ c := by
        have hex : c = (-2) * (a - 2 * b + 2 * c) + (-2) * (2 * a - b + 2 * c)
            + 3 * (2 * a - 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 (-2) (-2) 3
        rwa [← hex] at hcomb
      exact prim3_of_gcd a b c hgcd d hda hdb hdc
    exact gcd_of_prim3 hp3 (by simp only [bA]; ring_nf; linarith [hpy])
  · simp only [bA]; omega

lemma valid_bB {t : Tri} (h : Valid t) : Valid (bB t) := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := h
  simp only at ha hb hc hpy hgcd hodd
  obtain ⟨hbc, hac⟩ := hyp_gt_leg ha hb hc hpy
  refine ⟨by simp only [bB]; linarith, by simp only [bB]; linarith,
    by simp only [bB]; linarith, by simp only [bB]; ring_nf; linarith [hpy], ?_, ?_⟩
  · have hp3 : Prim3 (bB (a, b, c)) := by
      intro d hd1 hd2 hd3
      simp only [bB] at hd1 hd2 hd3
      have hda : d ∣ a := by
        have hex : a = 1 * (a + 2 * b + 2 * c) + 2 * (2 * a + b + 2 * c)
            + (-2) * (2 * a + 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 1 2 (-2)
        rwa [← hex] at hcomb
      have hdb : d ∣ b := by
        have hex : b = 2 * (a + 2 * b + 2 * c) + 1 * (2 * a + b + 2 * c)
            + (-2) * (2 * a + 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 2 1 (-2)
        rwa [← hex] at hcomb
      have hdc : d ∣ c := by
        have hex : c = (-2) * (a + 2 * b + 2 * c) + (-2) * (2 * a + b + 2 * c)
            + 3 * (2 * a + 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 (-2) (-2) 3
        rwa [← hex] at hcomb
      exact prim3_of_gcd a b c hgcd d hda hdb hdc
    exact gcd_of_prim3 hp3 (by simp only [bB]; ring_nf; linarith [hpy])
  · simp only [bB]; omega

lemma valid_bC {t : Tri} (h : Valid t) : Valid (bC t) := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := h
  simp only at ha hb hc hpy hgcd hodd
  obtain ⟨hbc, hac⟩ := hyp_gt_leg ha hb hc hpy
  refine ⟨by simp only [bC]; linarith, by simp only [bC]; linarith,
    by simp only [bC]; linarith, by simp only [bC]; ring_nf; linarith [hpy], ?_, ?_⟩
  · have hp3 : Prim3 (bC (a, b, c)) := by
      intro d hd1 hd2 hd3
      simp only [bC] at hd1 hd2 hd3
      have hda : d ∣ a := by
        have hex : a = (-1) * (-a + 2 * b + 2 * c) + (-2) * (-2 * a + b + 2 * c)
            + 2 * (-2 * a + 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 (-1) (-2) 2
        rwa [← hex] at hcomb
      have hdb : d ∣ b := by
        have hex : b = 2 * (-a + 2 * b + 2 * c) + 1 * (-2 * a + b + 2 * c)
            + (-2) * (-2 * a + 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 2 1 (-2)
        rwa [← hex] at hcomb
      have hdc : d ∣ c := by
        have hex : c = (-2) * (-a + 2 * b + 2 * c) + (-2) * (-2 * a + b + 2 * c)
            + 3 * (-2 * a + 2 * b + 3 * c) := by ring
        have hcomb := dvd_lin hd1 hd2 hd3 (-2) (-2) 3
        rwa [← hex] at hcomb
      exact prim3_of_gcd a b c hgcd d hda hdb hdc
    exact gcd_of_prim3 hp3 (by simp only [bC]; ring_nf; linarith [hpy])
  · simp only [bC]; omega

/-- Every triple of the Berggren tree is a positive primitive Pythagorean triple with
odd first leg. -/
theorem reach_valid {t : Tri} (h : Reach t) : Valid t := by
  induction h with
  | root => exact ⟨by norm_num, by norm_num, by norm_num, by norm_num, by decide, by norm_num⟩
  | stepA _ ih => exact valid_bA ih
  | stepB _ ih => exact valid_bB ih
  | stepC _ ih => exact valid_bC ih

/-! ### Descent: every valid triple lies in the tree -/

/-- The parent hypotenuse `3c - 2a - 2b` is positive and smaller than `c`. -/
lemma parent_hyp_bounds {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2) : 0 < 3 * c - 2 * a - 2 * b ∧ 3 * c - 2 * a - 2 * b < c := by
  constructor
  · nlinarith [sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (3 * c - 2 * a - 2 * b)]
  · nlinarith [mul_pos ha hb]

/-- The two sign parameters of the descent cannot both be non-positive. -/
lemma sign_dichotomy {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2) : 0 < a + 2 * b - 2 * c ∨ 0 < 2 * a + b - 2 * c := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2⟩ := hcon
  have hu2 : 4 * b ≤ 3 * a := by nlinarith
  have hv2 : 4 * a ≤ 3 * b := by nlinarith
  nlinarith

/-- If `a + 2b = 2c` for a valid triple, we get a contradiction with `a` odd. -/
lemma u_ne_zero {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2) (hodd : a % 2 = 1) : a + 2 * b - 2 * c ≠ 0 := by
  intro h
  have h4 : 4 * b = 3 * a := by nlinarith
  omega

/-- If `2a + b = 2c` for a valid triple, then it is the root `(3,4,5)`. -/
lemma v_zero_root {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2) (hgcd : Int.gcd a b = 1) (hv : 2 * a + b - 2 * c = 0) :
    a = 3 ∧ b = 4 ∧ c = 5 := by
  have h4 : 4 * a = 3 * b := by nlinarith
  have h3a : (3 : ℤ) ∣ a := by omega
  obtain ⟨k, hk⟩ := h3a
  have hbk : b = 4 * k := by omega
  have hkpos : 0 < k := by omega
  have hka : k ∣ a := ⟨3, by omega⟩
  have hkb : k ∣ b := ⟨4, by omega⟩
  have hunit : IsUnit k := (Int.isCoprime_iff_gcd_eq_one.mpr hgcd).isUnit_of_dvd' hka hkb
  have hk1 : k = 1 := by
    have := Int.isUnit_iff.1 hunit
    omega
  refine ⟨by omega, by omega, ?_⟩
  have hc2 : c ^ 2 = 25 := by rw [← hpy, show a = 3 by omega, show b = 4 by omega]; ring
  nlinarith

/-- The candidate parent `(ε u, δ v, w)` of a valid triple is again valid, provided its
first two coordinates are positive.  Here `u = a + 2b - 2c`, `v = 2a + b - 2c` and
`w = 3c - 2a - 2b`, and `ε, δ ∈ {±1}`. -/
lemma parent_valid {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2) (hgcd : Int.gcd a b = 1) (hodd : a % 2 = 1)
    {e f : ℤ} (he : e = 1 ∨ e = -1) (hf : f = 1 ∨ f = -1)
    (hp1 : 0 < e * (a + 2 * b - 2 * c)) (hp2 : 0 < f * (2 * a + b - 2 * c)) :
    Valid (e * (a + 2 * b - 2 * c), f * (2 * a + b - 2 * c), 3 * c - 2 * a - 2 * b) := by
  obtain ⟨hwpos, hwlt⟩ := parent_hyp_bounds ha hb hc hpy
  have hpyp : (e * (a + 2 * b - 2 * c)) ^ 2 + (f * (2 * a + b - 2 * c)) ^ 2
      = (3 * c - 2 * a - 2 * b) ^ 2 := by
    rcases he with rfl | rfl <;> rcases hf with rfl | rfl <;> nlinarith [hpy]
  refine ⟨hp1, hp2, hwpos, hpyp, ?_, ?_⟩
  · -- primitivity of the parent
    have hp3 : Prim3 (e * (a + 2 * b - 2 * c), f * (2 * a + b - 2 * c), 3 * c - 2 * a - 2 * b) := by
      intro d hd1 hd2 hd3
      simp only at hd1 hd2 hd3
      have hdu : d ∣ a + 2 * b - 2 * c := by
        rcases he with rfl | rfl
        · simpa using hd1
        · have : d ∣ -(a + 2 * b - 2 * c) := by simpa using hd1
          exact (dvd_neg.mp this)
      have hdv : d ∣ 2 * a + b - 2 * c := by
        rcases hf with rfl | rfl
        · simpa using hd2
        · have : d ∣ -(2 * a + b - 2 * c) := by simpa using hd2
          exact (dvd_neg.mp this)
      have hda : d ∣ a := by
        have hex : a = 1 * (a + 2 * b - 2 * c) + 2 * (2 * a + b - 2 * c)
            + 2 * (3 * c - 2 * a - 2 * b) := by ring
        have hcomb := dvd_lin hdu hdv hd3 1 2 2
        rwa [← hex] at hcomb
      have hdb : d ∣ b := by
        have hex : b = 2 * (a + 2 * b - 2 * c) + 1 * (2 * a + b - 2 * c)
            + 2 * (3 * c - 2 * a - 2 * b) := by ring
        have hcomb := dvd_lin hdu hdv hd3 2 1 2
        rwa [← hex] at hcomb
      have hdc : d ∣ c := by
        have hex : c = 2 * (a + 2 * b - 2 * c) + 2 * (2 * a + b - 2 * c)
            + 3 * (3 * c - 2 * a - 2 * b) := by ring
        have hcomb := dvd_lin hdu hdv hd3 2 2 3
        rwa [← hex] at hcomb
      exact prim3_of_gcd a b c hgcd d hda hdb hdc
    exact gcd_of_prim3 hp3 hpyp
  · simp only
    rcases he with rfl | rfl <;> omega

/-- **Descent step.**  A valid triple other than the root has a valid parent of strictly
smaller hypotenuse, one of whose three Berggren children it is. -/
lemma descent_step {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2) (hgcd : Int.gcd a b = 1) (hodd : a % 2 = 1)
    (hne : ¬ (a = 3 ∧ b = 4 ∧ c = 5)) :
    ∃ p : Tri, Valid p ∧ p.2.2 < c ∧
      (bA p = (a, b, c) ∨ bB p = (a, b, c) ∨ bC p = (a, b, c)) := by
  obtain ⟨hwpos, hwlt⟩ := parent_hyp_bounds ha hb hc hpy
  have huz : a + 2 * b - 2 * c ≠ 0 := u_ne_zero ha hb hc hpy hodd
  have hvz : 2 * a + b - 2 * c ≠ 0 := fun h => hne (v_zero_root ha hb hc hpy hgcd h)
  rcases lt_trichotomy (a + 2 * b - 2 * c) 0 with hun | hu0 | hup
  · -- branch C : ε = -1, δ = +1
    have hvp : 0 < 2 * a + b - 2 * c := by
      rcases sign_dichotomy ha hb hc hpy with h | h
      · omega
      · exact h
    refine ⟨((-1) * (a + 2 * b - 2 * c), 1 * (2 * a + b - 2 * c), 3 * c - 2 * a - 2 * b),
      parent_valid ha hb hc hpy hgcd hodd (Or.inr rfl) (Or.inl rfl) (by omega) (by omega),
      by simpa using hwlt, Or.inr (Or.inr ?_)⟩
    simp only [bC]
    refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> ring
  · exact absurd hu0 huz
  · rcases lt_trichotomy (2 * a + b - 2 * c) 0 with hvn | hv0 | hvp
    · -- branch A : ε = +1, δ = -1
      refine ⟨(1 * (a + 2 * b - 2 * c), (-1) * (2 * a + b - 2 * c), 3 * c - 2 * a - 2 * b),
        parent_valid ha hb hc hpy hgcd hodd (Or.inl rfl) (Or.inr rfl) (by omega) (by omega),
        by simpa using hwlt, Or.inl ?_⟩
      simp only [bA]
      refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> ring
    · exact absurd hv0 hvz
    · -- branch B : ε = +1, δ = +1
      refine ⟨(1 * (a + 2 * b - 2 * c), 1 * (2 * a + b - 2 * c), 3 * c - 2 * a - 2 * b),
        parent_valid ha hb hc hpy hgcd hodd (Or.inl rfl) (Or.inl rfl) (by omega) (by omega),
        by simpa using hwlt, Or.inr (Or.inl ?_)⟩
      simp only [bB]
      refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> ring

/-- **Berggren completeness.**  Every positive primitive Pythagorean triple with odd
first leg is generated from `(3,4,5)` by the three Berggren matrices. -/
theorem valid_reach : ∀ (n : ℕ) (t : Tri), t.2.2.toNat ≤ n → Valid t → Reach t := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rintro ⟨a, b, c⟩ hn h
    obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := h
    simp only at ha hb hc hpy hgcd hodd hn
    by_cases hroot : a = 3 ∧ b = 4 ∧ c = 5
    · obtain ⟨h3, h4, h5⟩ := hroot
      rw [h3, h4, h5]
      exact Reach.root
    · obtain ⟨p, hpv, hplt, hchild⟩ := descent_step ha hb hc hpy hgcd hodd hroot
      have hppos : 0 < p.2.2 := hpv.2.2.1
      have hsmall : p.2.2.toNat < n := by omega
      have hrec : Reach p := ih p.2.2.toNat hsmall p le_rfl hpv
      rcases hchild with h | h | h
      · rw [← h]; exact Reach.stepA hrec
      · rw [← h]; exact Reach.stepB hrec
      · rw [← h]; exact Reach.stepC hrec

/-- **Berggren's theorem.**  The tree rooted at `(3,4,5)` is exactly the set of positive
primitive Pythagorean triples with odd first leg. -/
theorem reach_iff_valid (t : Tri) : Reach t ↔ Valid t :=
  ⟨reach_valid, fun h => valid_reach t.2.2.toNat t le_rfl h⟩

end BerggrenTree