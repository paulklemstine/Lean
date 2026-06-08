/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Arithmetic on the Möbius Band: The Ring ℤ√1

## Overview

The **Möbius ring** is `ℤ√1 = ℤ[ε]/(ε² - 1)`, the ring of integers adjoined with a
"twist element" ε satisfying ε² = 1. This ring captures the arithmetic structure of
the Möbius band: the identification (0, y) ~ (1, -y) on [0,1] × ℝ corresponds
algebraically to the involution ε ↦ -ε (conjugation/star).

Unlike ℤ[i] = ℤ√(-1) (the Gaussian integers), which is an integral domain (and even
a Euclidean domain), ℤ√1 has **zero divisors**: (1+ε)(1-ε) = 0. This makes the
Möbius ring a fundamentally different arithmetic object, where the topology of the
Möbius band manifests as algebraic non-integrity.

## Main Definitions

* `𝕄` — The Möbius ring ℤ√1, a commutative ring with zero divisors.
* `MoebiusRing.ε` — The twist element satisfying ε² = 1.
* `MoebiusFiber` — The set of elements with a given norm value.
* `MoebiusParity` — Classification of Möbius integers by orientation parity.

## Main Results

* `moebius_epsilon_sq` — ε² = 1 (the twist property).
* `moebius_not_domain` — ℤ√1 is not an integral domain.
* `moebius_norm_mul` — The norm is multiplicative: N(xy) = N(x)N(y).
* `moebius_zero_divisor_iff` — x is a zero divisor iff N(x) = 0.
* `moebius_units_classification` — The units are exactly {1, -1, ε, -ε}.
* `moebius_fiber_nonempty_iff` — Fiber(n) ≠ ∅ iff n ≢ 2 (mod 4).
-/

open Zsqrtd

/-! ### Basic Setup -/

/-- The Möbius ring: `ℤ√1 = ℤ[ε]/(ε² - 1)`. -/
abbrev 𝕄 := ℤ√(1 : ℤ)

namespace MoebiusRing

/-- The twist element ε, the fundamental generator satisfying ε² = 1. -/
def ε : 𝕄 := ⟨0, 1⟩

/-- The positive idempotent direction: (1+ε). -/
def ePlus : 𝕄 := ⟨1, 1⟩

/-- The negative idempotent direction: (1-ε). -/
def eMinus : 𝕄 := ⟨1, -1⟩

/-! ### The Twist Property -/

/-- **The Twist Theorem**: ε² = 1 in the Möbius ring.
    Traversing the band twice returns to the original orientation. -/
theorem moebius_epsilon_sq : ε * ε = 1 := by
  ext <;> simp [ε]

/-- Star (conjugation) negates the twist component: star(a + bε) = a - bε. -/
theorem moebius_star_def (x : 𝕄) : star x = ⟨x.re, -x.im⟩ := rfl

/-- The norm equals x · star(x). -/
theorem moebius_norm_eq_mul_conj (x : 𝕄) :
    (Zsqrtd.norm x : ℤ√(1:ℤ)) = x * star x :=
  Zsqrtd.norm_eq_mul_conj x

/-- The norm formula: N(a + bε) = a² - b². -/
theorem moebius_norm_formula (x : 𝕄) :
    Zsqrtd.norm x = x.re * x.re - x.im * x.im := by
  simp [Zsqrtd.norm]

/-! ### Zero Divisors and Non-Integrity -/

/-- The fundamental zero divisor relation: (1+ε)(1-ε) = 0. -/
theorem moebius_zero_divisor_product : ePlus * eMinus = 0 := by
  ext <;> simp [ePlus, eMinus]

/-- 1+ε is nonzero. -/
theorem ePlus_ne_zero : ePlus ≠ 0 := by
  intro h; exact absurd (congr_arg Zsqrtd.re h) (by simp [ePlus])

/-- 1-ε is nonzero. -/
theorem eMinus_ne_zero : eMinus ≠ 0 := by
  intro h; exact absurd (congr_arg Zsqrtd.re h) (by simp [eMinus])

/-- **Non-Integrity Theorem**: The Möbius ring ℤ√1 is NOT an integral domain. -/
theorem moebius_not_domain : ¬ NoZeroDivisors 𝕄 := by
  intro ⟨h⟩
  have := h moebius_zero_divisor_product
  rcases this with h1 | h1 <;> simp [Zsqrtd.ext_iff, ePlus, eMinus] at h1

/-! ### Norm Multiplicativity -/

/-- **Norm Multiplicativity**: N(xy) = N(x)·N(y). -/
theorem moebius_norm_mul (x y : 𝕄) :
    Zsqrtd.norm (x * y) = Zsqrtd.norm x * Zsqrtd.norm y :=
  Zsqrtd.norm_mul x y

/-- The norm of ε is -1. -/
theorem moebius_norm_epsilon : Zsqrtd.norm ε = -1 := by
  simp [Zsqrtd.norm, ε]

/-- The norm of 1+ε is 0. -/
theorem moebius_norm_ePlus : Zsqrtd.norm ePlus = 0 := by
  simp [Zsqrtd.norm, ePlus]

/-- The norm of 1-ε is 0. -/
theorem moebius_norm_eMinus : Zsqrtd.norm eMinus = 0 := by
  simp [Zsqrtd.norm, eMinus]

/-! ### Zero Divisor Classification -/

/-
Norm zero iff real part equals ±imaginary part.
-/
theorem moebius_norm_zero_iff (x : 𝕄) :
    Zsqrtd.norm x = 0 ↔ x.re = x.im ∨ x.re = -x.im := by
      rw [ Zsqrtd.norm ] ; exact ⟨ fun h => eq_or_eq_neg_of_sq_eq_sq _ _ <| by linarith, fun h => h.elim ( fun h => by simp [ h ] ) fun h => by simp [ h ] ⟩ ;

/-
**Zero Divisor Classification**: x is a zero divisor iff norm(x) = 0.
-/
theorem moebius_zero_divisor_iff (x : 𝕄) (hx : x ≠ 0) :
    (∃ y : 𝕄, y ≠ 0 ∧ x * y = 0) ↔ Zsqrtd.norm x = 0 := by
      constructor;
      · rintro ⟨ y, hy, hxy ⟩;
        simp_all +decide [ Zsqrtd.norm ];
        simp_all +decide [ Zsqrtd.ext_iff ];
        by_cases hy_re : y.re = 0 <;> by_cases hy_im : y.im = 0 <;> simp_all +decide [ add_eq_zero_iff_eq_neg ];
        cases lt_or_gt_of_ne hy_re <;> cases lt_or_gt_of_ne hy_im <;> cases le_or_gt 0 ( x.re ) <;> cases le_or_gt 0 ( x.im ) <;> nlinarith;
      · intro h_norm_zero
        by_cases h_re_im : x.re = x.im;
        · use eMinus; simp_all +decide [ eMinus ] ;
          exact Zsqrtd.ext ( by simp +decide [ h_re_im ] ) ( by simp +decide [ h_re_im ] );
        · use ePlus; simp_all +decide [ Zsqrtd.norm ] ;
          exact Zsqrtd.ext ( by norm_num [ ePlus ] ; cases lt_or_gt_of_ne h_re_im <;> nlinarith ) ( by norm_num [ ePlus ] ; cases lt_or_gt_of_ne h_re_im <;> nlinarith )

/-! ### Unit Classification -/

/-
Units have norm ±1.
-/
theorem moebius_isUnit_iff_norm (x : 𝕄) :
    IsUnit x ↔ Zsqrtd.norm x = 1 ∨ Zsqrtd.norm x = -1 := by
      convert Zsqrtd.isUnit_iff_norm_isUnit x using 1;
      rw [ Int.isUnit_iff ]

/-
**Unit Classification Theorem**: The units of the Möbius ring are
    exactly {1, -1, ε, -ε}, forming the Klein four-group V₄.
-/
theorem moebius_units_classification (x : 𝕄) :
    IsUnit x ↔ x = 1 ∨ x = -1 ∨ x = ε ∨ x = -ε := by
      constructor <;> intro hx;
      · obtain ⟨ u, hu ⟩ := hx.exists_left_inv;
        simp_all +decide [ Zsqrtd.ext_iff ];
        -- From the equations $u.re * x.re + u.im * x.im = 1$ and $u.re * x.im + u.im * x.re = 0$, we can solve for $x.re$ and $x.im$.
        have h_solve : x.re ^ 2 - x.im ^ 2 = 1 ∨ x.re ^ 2 - x.im ^ 2 = -1 := by
          have h_solve : (u.re ^ 2 - u.im ^ 2) * (x.re ^ 2 - x.im ^ 2) = 1 := by
            grind;
          exact Int.eq_one_or_neg_one_of_mul_eq_one <| by rwa [ mul_comm ] ;
        cases' h_solve with h h;
        · -- From the equation $x.re^2 - x.im^2 = 1$, we can factor it as $(x.re - x.im)(x.re + x.im) = 1$.
          have h_factor : (x.re - x.im) * (x.re + x.im) = 1 := by
            linarith;
          rw [ Int.mul_eq_one_iff_eq_one_or_neg_one ] at h_factor;
          grind;
        · -- From the equation $x.re^2 - x.im^2 = -1$, we can solve for $x.re$ and $x.im$.
          have h_solve : x.re = 0 ∧ x.im = 1 ∨ x.re = 0 ∧ x.im = -1 := by
            have h_solve : (x.re - x.im) * (x.re + x.im) = -1 := by
              linarith;
            rw [ Int.mul_eq_neg_one_iff_eq_one_or_neg_one ] at h_solve ; omega;
          grind +locals;
      · obtain rfl | rfl | rfl | rfl := hx;
        · exact isUnit_one;
        · exact isUnit_one.neg;
        · exact isUnit_iff_exists_inv.mpr ⟨ ε, by simp +decide [ moebius_epsilon_sq ] ⟩;
        · exact isUnit_iff_exists_inv.mpr ⟨ -ε, by simp +decide [ moebius_epsilon_sq ] ⟩

/-
Every unit in the Möbius ring is its own inverse (exponent 2).
-/
theorem moebius_unit_self_inverse (x : 𝕄) (hx : IsUnit x) : x * x = 1 := by
  rcases moebius_units_classification x |>.1 hx with ( rfl | rfl | rfl | rfl ) <;> simp +decide [ moebius_epsilon_sq ]

/-! ### The Möbius Fiber -/

/-- The Möbius fiber over n: elements with norm n (representations of n as a² - b²). -/
def MoebiusFiber (n : ℤ) : Set 𝕄 := {x : 𝕄 | Zsqrtd.norm x = n}

/-
Every odd integer is a difference of two squares.
-/
theorem odd_in_fiber (n : ℤ) (hn : n % 2 = 1 ∨ n % 2 = -1) :
    (MoebiusFiber n).Nonempty := by
      -- Let's choose any solution $a, b$ such that $a^2 - b^2 = n$.
      obtain ⟨a, b, hab⟩ : ∃ a b : ℤ, a^2 - b^2 = n := by
        exact ⟨ n / 2 + 1, n / 2, by linarith [ Int.emod_add_mul_ediv n 2, show n % 2 = 1 from hn.resolve_right ( by omega ) ] ⟩;
      use ⟨a, b⟩;
      exact Eq.symm ( by simpa [ Zsqrtd.norm ] using by linarith )

/-
Every multiple of 4 is a difference of two squares.
-/
theorem mul4_in_fiber (m : ℤ) :
    (MoebiusFiber (4 * m)).Nonempty := by
      use ⟨m + 1, m - 1⟩;
      unfold MoebiusFiber; norm_num [ Zsqrtd.norm ] ; ring;

/-
No element has norm ≡ 2 (mod 4).
-/
theorem no_norm_two_mod_four (x : 𝕄) :
    ¬ (Zsqrtd.norm x % 4 = 2 ∨ Zsqrtd.norm x % 4 = -2) := by
      norm_num [ Zsqrtd.norm ];
      constructor <;> norm_num [ Int.mul_emod, Int.sub_emod ] <;> have := Int.emod_nonneg x.re four_ne_zero <;> have := Int.emod_nonneg x.im four_ne_zero <;> have := Int.emod_lt_of_pos x.re zero_lt_four <;> have := Int.emod_lt_of_pos x.im zero_lt_four <;> interval_cases x.re % 4 <;> interval_cases x.im % 4 <;> trivial;

/-
**Möbius Fiber Theorem**: n is a difference of two squares iff n ≢ 2 (mod 4).
-/
theorem moebius_fiber_nonempty_iff (n : ℤ) :
    (MoebiusFiber n).Nonempty ↔ ¬ (n % 4 = 2 ∨ n % 4 = -2) := by
      constructor;
      · rintro ⟨ x, hx ⟩;
        exact fun h => no_norm_two_mod_four x <| by simp_all +decide [ MoebiusFiber ] ;
      · intro hn
        by_cases hn_odd : n % 2 = 1 ∨ n % 2 = -1;
        · exact odd_in_fiber n hn_odd;
        · obtain ⟨ k, hk ⟩ := Int.modEq_zero_iff_dvd.mp ( show n % 4 = 0 by omega ) ; exact ⟨ ⟨ k + 1, k - 1 ⟩, by simp +decide [ MoebiusFiber, Zsqrtd.norm ] ; linarith ⟩ ;

/-! ### Orientation Ideals -/

/-- The positive orientation ideal: multiples of (1+ε). -/
def orientIdealPlus : Ideal 𝕄 := Ideal.span {ePlus}

/-- The negative orientation ideal: multiples of (1-ε). -/
def orientIdealMinus : Ideal 𝕄 := Ideal.span {eMinus}

/-
Elements of I₊ have equal real and imaginary parts.
-/
theorem mem_orientIdealPlus_iff (x : 𝕄) :
    x ∈ orientIdealPlus ↔ x.re = x.im := by
      constructor <;> intro h;
      · obtain ⟨ y, hy ⟩ := Ideal.mem_span_singleton.mp h; simp_all +decide [ ePlus ] ; ring;
      · rw [ orientIdealPlus, Ideal.mem_span_singleton ];
        exact ⟨ ⟨ x.re, 0 ⟩, by ext <;> simp +decide [ h, ePlus ] ⟩

/-
Elements of I₋ have opposite real and imaginary parts.
-/
theorem mem_orientIdealMinus_iff (x : 𝕄) :
    x ∈ orientIdealMinus ↔ x.re = -x.im := by
      refine' ⟨ fun hx => _, fun hx => _ ⟩;
      · obtain ⟨ y, hy ⟩ := Ideal.mem_span_singleton.mp hx;
        simp_all +decide [ eMinus ];
      · -- If x.re = -x.im, then x = ⟨a, -a⟩ for some a. We can write x as a * eMinus.
        obtain ⟨a, ha⟩ : ∃ a : ℤ, x = ⟨a, -a⟩ := by
          exact ⟨ x.re, by ext <;> simp +decide [ hx ] ⟩;
        rw [ ha, orientIdealMinus ];
        exact Ideal.mem_span_singleton.mpr ⟨ ⟨ a, 0 ⟩, by ext <;> simp +decide [ eMinus ] ⟩

/-
I₊ · I₋ = {0}: the orientation ideals annihilate each other.
-/
theorem orientIdeals_product_zero :
    orientIdealPlus * orientIdealMinus = ⊥ := by
      rw [ show orientIdealPlus = Ideal.span { MoebiusRing.ePlus } from rfl, show orientIdealMinus = Ideal.span { MoebiusRing.eMinus } from rfl, Ideal.span_mul_span ];
      simp +decide [ Ideal.span_singleton_mul_span_singleton ]

/-! ### Twist Parity -/

/-- Classification of elements by behavior under conjugation. -/
inductive MoebiusParity where
  | symmetric      -- star(x) = x (im = 0)
  | antisymmetric  -- star(x) = -x (re = 0)
  | mixed          -- neither
  deriving DecidableEq, Repr

/-- Classify an element's parity under the twist involution. -/
def classify (x : 𝕄) : MoebiusParity :=
  if x.im = 0 then MoebiusParity.symmetric
  else if x.re = 0 then MoebiusParity.antisymmetric
  else MoebiusParity.mixed

/-- Symmetric elements are fixed by conjugation. -/
theorem symmetric_iff_star_eq (x : 𝕄) :
    classify x = MoebiusParity.symmetric ↔ star x = x := by
  constructor
  · intro h
    simp only [classify] at h
    split_ifs at h with him
    · ext <;> simp [moebius_star_def, him]
  · intro h
    have him : x.im = 0 := by
      have := congr_arg Zsqrtd.im h
      simp at this; omega
    simp [classify, him]

/-- The product of two antisymmetric elements is symmetric. -/
theorem antisymmetric_mul_symmetric (x y : 𝕄) (hx : x.re = 0) (hy : y.re = 0) :
    (x * y).im = 0 := by
  simp [hx, hy]

/-- ε swaps the real and imaginary coordinates. -/
theorem epsilon_mul_swap (x : 𝕄) : (ε * x).re = x.im ∧ (ε * x).im = x.re := by
  simp [ε]

end MoebiusRing