/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Gleason's length theorem: doubly-even self-dual codes have length divisible by 8

This file proves the **mod-8 refinement** that the catalog's
`Catalog.Applications.SmoothPoincare.SelfDualLength` explicitly leaves as the
"genuinely harder, weight-enumerator/invariant-theory step":

* `SelfDualLength.selfDual_doublyEven_length_div_four` shows a binary doubly-even
  self-dual code has length divisible by **4**.
* Here, `doublyEven_selfDual_length_div_eight` upgrades this to divisibility by **8**
  — the sharp constant, mirroring the lattice-side miracle that positive-definite even
  unimodular lattices exist only in rank divisible by `8` (`IntersectionForms.E8form`,
  `E8_even`, `even_not_stdDiagonalizable`).

The proof is the classical **Gauss-sum / MacWilliams** argument, formalized from
scratch over `ℂ`:

1. `csgn` is the multiplicative character `a ↦ (-1)^a` of `(ZMod 2, +)`, and
   `bchar x c = ∏ⱼ (-1)^(xⱼ·cⱼ) = (-1)^⟨x,c⟩`.
2. `char_orthogonality` — for a self-dual (hence linear) code `C`,
   `∑_{c∈C} (-1)^{⟨x,c⟩} = |C|` if `x ∈ C` and `0` otherwise (the standard
   "non-trivial character sums to zero" argument via the involution `c ↦ c + c₀`).
3. `fourier_iwt` — the per-coordinate factorization of the discrete Fourier transform
   of `x ↦ Iᵂᵗ⁽ˣ⁾` gives `∑ₓ Iᵂᵗ⁽ˣ⁾ (-1)^{⟨x,y⟩} = (1+I)^{n-wt y}(1-I)^{wt y}`,
   which collapses to `(1+I)ⁿ` when `y` is doubly even (since `1-I = -I·(1+I)` and
   `(-I)^{wt y} = 1`).
4. Evaluating the double sum `∑ₓ Iᵂᵗ⁽ˣ⁾ ∑_{c∈C} (-1)^{⟨x,c⟩}` two ways yields the
   master identity `(|C| : ℂ) = (1+I)ⁿ`.
5. Since `|C|` is a positive **real** number while `(1+I)⁴ = -4` and `(1+I)⁸ = 16`,
   positivity forces `n ≡ 0 (mod 8)`.

-- !-- Lab Notebook -- !--
Hypothesis: the mod-4 length theorem of `SelfDualLength` is not sharp; the true
  obstruction is mod 8 (Gleason), and it should follow from a self-contained Gauss-sum
  evaluation of `∑_{c∈C} I^{wt c}` rather than from full invariant theory.
Result: `doublyEven_selfDual_length_div_eight` proved `sorry`-free for arbitrary `n`,
  via the master identity `(|C| : ℂ) = (1+I)ⁿ` and the sign analysis `(1+I)⁴ = -4`.
Insight: self-duality is exactly the hypothesis that makes the code a *linear* subgroup
  on which character orthogonality holds; double-evenness is exactly what makes the
  MacWilliams transform value collapse from `(1+I)^{n-w}(1-I)^w` to `(1+I)ⁿ`. The two
  catalog predicates conspire to pin the complex number `|C|` onto the positive real
  axis of the `(1+I)`-tower, whose period is `8`.
Failure analysis: ℕ-subtraction in the exponent `n - wt y` is tamed by the algebraic
  identity `1 - I = (-I)·(1+I)`, turning `(1+I)^{n-w}(1-I)^w` into `(1+I)ⁿ·(-I)^w`
  with no truncated subtraction surviving into the final step.
-/

import Mathlib
import Applications.SmoothPoincare.SelfDualLength

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

/-! ## The multiplicative sign character of `ZMod 2` -/

/-- The non-trivial multiplicative character `a ↦ (-1)^a` of the additive group
`ZMod 2`, valued in `ℂ`. -/
def csgn (a : ZMod 2) : ℂ := if a = 0 then 1 else -1

@[simp] lemma csgn_zero : csgn (0 : ZMod 2) = 1 := by
  -- By definition of $csgn$, we know that $csgn(0) = 1$.
  simp [csgn]

lemma csgn_one : csgn (1 : ZMod 2) = -1 := by
  -- By definition of $csgn$, we know that $csgn(1) = -1$ because $1 \neq 0$.
  simp [csgn]

/-
`csgn` turns addition into multiplication: it is a group character.
-/
lemma csgn_add (a b : ZMod 2) : csgn (a + b) = csgn a * csgn b := by
  fin_cases a <;> fin_cases b <;> simp +decide [ csgn ]

/-
A nonzero element of `ZMod 2` has sign `-1`.
-/
lemma csgn_ne_zero {a : ZMod 2} (ha : a ≠ 0) : csgn a = -1 := by
  fin_cases a <;> aesop

/-! ## Bilinear form helpers -/

/-
`ip` is additive in its right argument.
-/
lemma ip_add_right (x c d : Fin n → ZMod 2) : ip x (c + d) = ip x c + ip x d := by
  unfold ip; simp +decide [ Finset.sum_add_distrib, mul_add ] ;

/-
`ip` is additive in its left argument.
-/
lemma ip_add_left (x c d : Fin n → ZMod 2) : ip (x + c) d = ip x d + ip c d := by
  convert ip_add_right d x c using 1;
  · exact Finset.sum_congr rfl fun _ _ => mul_comm _ _;
  · unfold ip; simp +decide [ mul_comm, Finset.sum_add_distrib ] ;

/-
The Hamming weight is at most the length.
-/
lemma wt_le (x : Fin n → ZMod 2) : wt x ≤ n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-! ## Self-dual codes are linear -/

/-
The zero word lies in any self-dual code.
-/
lemma zero_mem_selfDual (C : Finset (Fin n → ZMod 2))
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0) : (0 : Fin n → ZMod 2) ∈ C := by
      exact hSD 0 |>.2 fun _ _ => by simp +decide [ ip ] ;

/-
A self-dual code is closed under addition (it is a linear subspace).
-/
lemma add_mem_selfDual (C : Finset (Fin n → ZMod 2))
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0)
    {a b : Fin n → ZMod 2} (ha : a ∈ C) (hb : b ∈ C) : a + b ∈ C := by
      rw [ hSD ] at *;
      exact fun y hy => by rw [ ip_add_left, ha y hy, hb y hy, add_zero ] ;

/-! ## The character `bchar` and orthogonality -/

/-- The additive character `bchar x c = ∏ⱼ (-1)^{xⱼ cⱼ} = (-1)^{⟨x,c⟩}`. -/
def bchar (x c : Fin n → ZMod 2) : ℂ := ∏ j, csgn (x j * c j)

/-
   `bchar x c = ∏ⱼ (-1)^(xⱼ·cⱼ) = (-1)^⟨x,c⟩`.
-/
lemma bchar_eq_csgn_ip (x c : Fin n → ZMod 2) : bchar x c = csgn (ip x c) := by
  unfold bchar ip;
  induction' ( Finset.univ : Finset ( Fin n ) ) using Finset.induction <;> simp_all +decide [ Finset.prod_insert, Finset.sum_insert, csgn_add ]

/-
**Character orthogonality over a self-dual code.** For a self-dual code `C`,
`∑_{c∈C} (-1)^{⟨x,c⟩}` is `|C|` when `x ∈ C` and `0` otherwise.
-/
lemma char_orthogonality (C : Finset (Fin n → ZMod 2))
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0) (x : Fin n → ZMod 2) :
    ∑ c ∈ C, bchar x c = if x ∈ C then (C.card : ℂ) else 0 := by
      split_ifs with hx;
      · rw [ Finset.sum_congr rfl fun y hy => bchar_eq_csgn_ip x y, Finset.sum_congr rfl fun y hy => by rw [ hSD x |>.1 hx y hy, csgn_zero ] ] ; norm_num;
      · -- From `hSD` there is `c₀ ∈ C` with `ip x c₀ ≠ 0`, so `csgn (ip x c₀) = -1`.
        obtain ⟨c₀, hc₀⟩ : ∃ c₀ ∈ C, ip x c₀ ≠ 0 := by
          grind;
        -- Let `S := ∑ c ∈ C, bchar x c`. The map `c ↦ c + c₀` is a bijection `C → C` (closed under add by `add_mem_selfDual`, self-inverse since `c₀ + c₀ = 0` over `ZMod 2`).
        set S := ∑ c ∈ C, bchar x c
        have hS : S = ∑ c ∈ C, bchar x (c + c₀) := by
          apply Finset.sum_bij (fun c _ => c + c₀);
          · exact fun a ha => add_mem_selfDual C hSD ha hc₀.1;
          · simp +contextual;
          · intro b hb
            use b - c₀;
            simp +zetaDelta at *;
            convert add_mem_selfDual C hSD hb ( show -c₀ ∈ C from ?_ ) using 1;
            · rw [ sub_eq_add_neg ];
            · convert hc₀.1 using 1;
              ext i; simp +decide [ ZMod.neg_eq_self_iff ] ;
          · simp +decide [ add_assoc, CharTwo.add_self_eq_zero ];
            exact fun a ha => by congr; ext i; simp +decide [ ← two_mul ] ;
        -- For each `c`, `bchar x (c + c₀) = csgn (ip x (c+c₀)) = csgn (ip x c) * csgn (ip x c₀) = bchar x c * (-1) = - bchar x c` (via `bchar_eq_csgn_ip`, `ip_add_right`, `csgn_add`).
        have h_bchar_add : ∀ c ∈ C, bchar x (c + c₀) = -bchar x c := by
          intros c hc
          have h_bchar_add_step : bchar x (c + c₀) = csgn (ip x c) * csgn (ip x c₀) := by
            rw [ ← csgn_add, bchar_eq_csgn_ip, ip_add_right ];
          rw [ h_bchar_add_step, show csgn ( ip x c₀ ) = -1 from ?_ ];
          · rw [ bchar_eq_csgn_ip ] ; ring;
          · exact csgn_ne_zero hc₀.2;
        rw [ Finset.sum_congr rfl h_bchar_add ] at hS ; norm_num at hS ; linear_combination' hS / 2

/-! ## The character `iwt x = I^{wt x}` and its Fourier transform -/

/-- The function `x ↦ I^{wt x}`, written multiplicatively over coordinates. -/
def iwt (x : Fin n → ZMod 2) : ℂ := ∏ j, (if x j = 0 then 1 else Complex.I)

/-
`iwt x = I^{wt x}`.
-/
lemma iwt_eq_pow (x : Fin n → ZMod 2) : iwt x = Complex.I ^ (wt x) := by
  unfold iwt wt;
  rw [ Finset.card_filter ];
  rw [ ← Finset.prod_pow_eq_pow_sum ] ; congr ; ext i ; rcases x i with ( _ | _ | x ) <;> norm_num ; tauto;

/-
A doubly-even word satisfies `iwt x = 1` (as `I⁴ = 1`).
-/
lemma iwt_doublyEven {x : Fin n → ZMod 2} (hx : DoublyEven x) : iwt x = 1 := by
  obtain ⟨ k, hk ⟩ := hx;
  rw [ iwt_eq_pow, hk, pow_mul ] ; norm_num

/-
**Discrete Fourier transform of `iwt`.** Per-coordinate factorization gives
`∑ₓ iwt x · (-1)^{⟨x,y⟩} = (1+I)^{n-wt y}(1-I)^{wt y}`.
-/
lemma fourier_iwt (y : Fin n → ZMod 2) :
    ∑ x, iwt x * bchar x y
      = (1 + Complex.I) ^ (n - wt y) * (1 - Complex.I) ^ (wt y) := by
        convert Finset.prod_congr rfl fun j _ => show ∑ x : ZMod 2, ( if x = 0 then 1 else Complex.I ) * csgn ( x * y j ) = if y j = 0 then ( 1 + Complex.I ) else ( 1 - Complex.I ) from ?_ using 1;
        any_goals exact Finset.univ;
        · rw [ Finset.prod_sum ];
          refine' Finset.sum_bij ( fun x _ => fun j _ => x j ) _ _ _ _ <;> simp +decide [ iwt, bchar ];
          · simp +decide [ funext_iff ];
          · exact fun b => ⟨ fun j => b j ( Finset.mem_univ j ), rfl ⟩;
          · intro a; rw [ ← Finset.prod_mul_distrib ] ; congr; ext j; aesop;
        · rw [ Finset.prod_ite ] ; norm_num [ Finset.filter_congr, Finset.filter_eq', Finset.filter_ne' ] ; ring;
          rw [ show ( Finset.univ.filter fun x => y x = 0 ) = Finset.univ \ ( Finset.univ.filter fun x => ¬y x = 0 ) by ext; aesop, Finset.card_sdiff ] ; norm_num [ Finset.card_univ ] ; ring;
          rw [ show ( Finset.univ.filter fun x => ¬y x = 0 ) = Finset.univ.filter fun x => y x = 1 from Finset.filter_congr fun x _ => by have := Fin.exists_fin_two.mp ⟨ y x, rfl ⟩ ; aesop ] ; simp +decide [ wt ] ;
        · cases Fin.exists_fin_two.mp ⟨ y j, rfl ⟩ <;> simp +decide [ * ];
          · erw [ Fin.sum_univ_two ] ; norm_num;
          · rw [ Finset.sum_eq_add ( 0 : ZMod 2 ) ( 1 : ZMod 2 ) ] <;> simp +decide [ csgn ] ; ring

/-
For doubly-even `y`, the Fourier value collapses to `(1+I)ⁿ`, using
`1 - I = (-I)(1+I)` and `(-I)^{wt y} = 1`.
-/
lemma fourier_iwt_doublyEven {y : Fin n → ZMod 2} (hy : DoublyEven y) :
    ∑ x, iwt x * bchar x y = (1 + Complex.I) ^ n := by
      convert fourier_iwt y using 1;
      convert congr_arg ( fun x : ℂ => ( 1 + Complex.I ) ^ ( n - wt y ) * x ) _ using 1;
      rw [ ← pow_add, Nat.sub_add_cancel ( wt_le y ) ];
      obtain ⟨ k, hk ⟩ := hy;
      rw [ hk, pow_mul, pow_mul ];
      norm_num [ pow_succ, Complex.ext_iff ];
      ring_nf; norm_num [ pow_mul', ← Complex.ofReal_pow ] ;
      ring ; norm_num

/-! ## The master identity `(|C| : ℂ) = (1+I)ⁿ` -/

/-
**Master identity.** For a doubly-even self-dual code, evaluating the double sum
`∑ₓ iwt x · ∑_{c∈C} (-1)^{⟨x,c⟩}` two ways gives `(|C| : ℂ) = (1+I)ⁿ`.
-/
lemma card_eq_onePlusI_pow (C : Finset (Fin n → ZMod 2))
    (hDE : ∀ v ∈ C, DoublyEven v)
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0) :
    (C.card : ℂ) = (1 + Complex.I) ^ n := by
      have h_eval1 : ∑ x, iwt x * (∑ c ∈ C, bchar x c) = (C.card : ℂ) * (C.card : ℂ) := by
        have h_eval1 : ∑ x ∈ C, iwt x * (C.card : ℂ) = (C.card : ℂ) * (C.card : ℂ) := by
          rw [ Finset.sum_congr rfl fun x hx => by rw [ iwt_doublyEven ( hDE x hx ) ] ] ; norm_num [ mul_comm ];
        rw [ ← h_eval1, ← Finset.sum_subset ( Finset.subset_univ C ) ];
        · refine' Finset.sum_congr rfl fun x hx => _;
          rw [ char_orthogonality C hSD x, if_pos hx ];
        · intros x hx hx'; rw [ char_orthogonality C hSD x ] ; simp +decide [ hx' ] ;
      have h_eval2 : ∑ x, iwt x * (∑ c ∈ C, bchar x c) = (C.card : ℂ) * (1 + Complex.I) ^ n := by
        have h_eval2 : ∑ x, iwt x * (∑ c ∈ C, bchar x c) = ∑ c ∈ C, ∑ x, iwt x * bchar x c := by
          rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => Finset.mul_sum _ _ _ ];
        rw [ h_eval2, Finset.sum_congr rfl fun x hx => fourier_iwt_doublyEven ( hDE x hx ) ] ; norm_num;
      exact mul_left_cancel₀ ( Nat.cast_ne_zero.mpr <| show C.card ≠ 0 from Finset.card_ne_zero_of_mem <| zero_mem_selfDual C hSD ) <| by linear_combination' h_eval1.symm.trans h_eval2;

/-! ## Final number theory: a positive real power of `(1+I)` forces `8 ∣ n` -/

/-
If a positive natural number equals `(1+I)ⁿ` in `ℂ`, then `8 ∣ n`. The tower of
powers of `1+I` has period `8` (`(1+I)⁸ = 16`), and within one period only the
exponent `0` lands on the positive real axis (`(1+I)⁴ = -4 < 0`, the rest non-real).
-/
lemma eight_dvd_of_pos_real_pow (m : ℕ) (hm : 0 < m)
    (h : (m : ℂ) = (1 + Complex.I) ^ n) : 8 ∣ n := by
      -- Let's write $n$ as $8q + r$ where $0 \leq r < 8$.
      obtain ⟨q, r, hr⟩ : ∃ q r : ℕ, n = 8 * q + r ∧ r < 8 := by
        exact ⟨ n / 8, n % 8, by rw [ Nat.div_add_mod ], Nat.mod_lt _ <| by decide ⟩;
      -- We'll use that $(1 + \mathrm{i})^8 = 16$ to simplify $(1 + \mathrm{i})^n$.
      have h_simp : (1 + Complex.I) ^ n = (16 : ℂ) ^ q * (1 + Complex.I) ^ r := by
        rw [ hr.1, pow_add, pow_mul ] ; norm_num [ show ( 1 + Complex.I ) ^ 8 = 16 by norm_num [ Complex.ext_iff, pow_succ ] ] ;
      rcases hr with ⟨ rfl, hr ⟩ ; interval_cases r <;> norm_num [ h_simp, Complex.ext_iff ] at h ⊢;
      all_goals norm_cast at h; norm_num [ pow_succ' ] at h;
      · exact absurd h.2 ( by positivity );
      · norm_cast at h;
        linarith

/-! ## The Gleason length theorem -/

-- !-- Combine the master identity `(|C| : ℂ) = (1+I)ⁿ` (from Gauss-sum evaluation)
-- with the sign/period analysis `eight_dvd_of_pos_real_pow`; `|C| > 0` since `0 ∈ C`. -- !--
/-- **Gleason's length theorem.** Every binary doubly-even self-dual code has length
divisible by `8`. This is the sharp refinement of
`SelfDualLength.selfDual_doublyEven_length_div_four`, and the coding-theory shadow of
"positive-definite even unimodular lattices have rank divisible by 8". -/
theorem doublyEven_selfDual_length_div_eight
    (C : Finset (Fin n → ZMod 2))
    (hDE : ∀ v ∈ C, DoublyEven v)
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0) :
    8 ∣ n := by
  have hpos : 0 < C.card := Finset.card_pos.mpr ⟨0, zero_mem_selfDual C hSD⟩
  exact eight_dvd_of_pos_real_pow C.card hpos (card_eq_onePlusI_pow C hDE hSD)

/-! ## Instantiation on the extended Hamming code `[8,4,4]` -/

-- !-- The extended Hamming code is doubly even (`SelfDualLength.hamming_doublyEven`)
-- and self-dual (`SelfDualLength.hamming_selfDual`), so Gleason's theorem applies and
-- recovers `8 ∣ 8` — now from the sharp mod-8 theorem, not by hand. -- !--
/-- **Corollary.** The length `8` of the extended Hamming code (the mod-2 shadow of
`E8`) is divisible by `8`, recovered from the *general* Gleason theorem. -/
theorem hamming_length_div_eight : (8 : ℕ) ∣ 8 :=
  doublyEven_selfDual_length_div_eight hamming hamming_doublyEven hamming_selfDual

end Codes
end SmoothPoincare