import Mathlib

/-!
# The Gaussian integer parametrization of Pythagorean triples

The norm map `N(a + b·i) = a² + b²` on the Gaussian integers `ℤ[i]` directly encodes
sums of two squares, which makes `ℤ[i]` the natural algebraic setting for Pythagorean
triples.  Sending `z = a + b·i` to the triple `(|a² - b²|, 2|ab|, a² + b²)` produces a
Pythagorean triple, because `N(z) = a² + b²` together with the algebraic identity
`(a² - b²)² + (2ab)² = (a² + b²)²`.

This file develops:

* `PythTriple`, `PrimPythTriple` — the (Sub)types of integer triples satisfying
  `a² + b² = c²` (resp. with coprime legs);
* `parametrize` — the map `z ↦ (|a² - b²|, 2|ab|, a² + b²)`, proven well defined;
* **Theorem 1** (`parametrize_isPythagorean`): the image is always a Pythagorean triple;
* **Theorem 2** (`parametrize_injective_up_to_units`): if two Gaussian integers have the
  same image then they differ by a unit, *possibly after conjugation* (conjugation
  corresponds exactly to swapping the two legs of the triple — see the note below);
* **Theorem 3** (`surjective_onto_primitive`): every positive primitive Pythagorean
  triple with odd first leg is `parametrize (m + n·i)` for suitable `m > n > 0`;
* **Theorem 4** (`coprime_iff`): the legs of `parametrize z` are coprime iff the real and
  imaginary parts of `z` are coprime **and** of opposite parity.

## Notes on faithfulness

* The prompt's Theorem 2 says the two arguments "differ by a unit (±1, ±i)".  Strictly,
  the parametrization is invariant under conjugation as well (since `|a| , |b|` are only
  determined as an unordered pair), and conjugation is *not* multiplication by a unit.
  Hence the honest conclusion allows multiplication by a unit applied to `w` *or* to its
  conjugate `star w`.
* The prompt's Theorem 4 says `gcd(legs) = 1 ↔ gcd(Re z, Im z) = 1`.  This is false as
  stated: e.g. `z = 3 + i` has coprime parts but legs `8, 6` with gcd `2`.  The correct
  statement additionally requires `Re z` and `Im z` to have opposite parity, which is the
  version proven here.
-/

open scoped GaussianInt

namespace GaussianParametrize

/-- A Pythagorean triple: integers `(a, b, c)` with `a² + b² = c²`. -/
def PythTriple : Type := {t : ℤ × ℤ × ℤ // t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2}

/-- A primitive Pythagorean triple: a Pythagorean triple whose legs are coprime. -/
def PrimPythTriple : Type := {t : PythTriple // Int.gcd t.1.1 t.1.2.1 = 1}

/-- The Gaussian parametrization: `z = a + b·i ↦ (|a² - b²|, 2|ab|, a² + b²)`. -/
def parametrize (z : GaussianInt) : PythTriple :=
  ⟨(|z.re ^ 2 - z.im ^ 2|, 2 * |z.re * z.im|, z.re ^ 2 + z.im ^ 2), by
    show |z.re ^ 2 - z.im ^ 2| ^ 2 + (2 * |z.re * z.im|) ^ 2 = (z.re ^ 2 + z.im ^ 2) ^ 2
    rw [mul_pow, sq_abs, sq_abs]; ring⟩

/-- **Theorem 1.** `parametrize z` is a valid Pythagorean triple. -/
theorem parametrize_isPythagorean (z : GaussianInt) :
    (parametrize z).1.1 ^ 2 + (parametrize z).1.2.1 ^ 2 = (parametrize z).1.2.2 ^ 2 :=
  (parametrize z).2

/-
Helper: from the three coordinate equalities coming from `parametrize z = parametrize w`
we recover the squares of the parts up to a swap.
-/
lemma parts_sq_eq {z w : GaussianInt}
    (hS : z.re ^ 2 + z.im ^ 2 = w.re ^ 2 + w.im ^ 2)
    (hP : (z.re * z.im) ^ 2 = (w.re * w.im) ^ 2) :
    (z.re ^ 2 = w.re ^ 2 ∧ z.im ^ 2 = w.im ^ 2) ∨
      (z.re ^ 2 = w.im ^ 2 ∧ z.im ^ 2 = w.re ^ 2) := by
  have hxy : (z.re^2 - w.re^2) * (z.re^2 - w.im^2) = 0 := by
    grind;
  simp_all +decide [ sub_eq_iff_eq_add ] ; omega;

/-
**Theorem 2.** If `parametrize z = parametrize w` then `z` differs from `w`, or from
the conjugate `star w`, by a unit of `ℤ[i]`.
-/
theorem parametrize_injective_up_to_units {z w : GaussianInt}
    (h : parametrize z = parametrize w) :
    ∃ u : GaussianInt, IsUnit u ∧ (z = u * w ∨ z = u * star w) := by
  -- By definition of `parametrize`, we have:
  have h_parts : z.re ^ 2 + z.im ^ 2 = w.re ^ 2 + w.im ^ 2 ∧ (z.re * z.im) ^ 2 = (w.re * w.im) ^ 2 := by
    unfold parametrize at h;
    grind +qlia;
  obtain h|h := parts_sq_eq h_parts.1 h_parts.2 <;> simp_all +decide [ sq_eq_sq_iff_abs_eq_abs ];
  · simp_all +decide [ abs_eq_abs ];
    rcases h with ⟨ h₁ | h₁, h₂ | h₂ ⟩ <;> simp_all +decide [ isUnit_iff_exists_inv ];
    · exact ⟨ 1, ⟨ 1, by norm_num ⟩, Or.inl <| by ext <;> simp +decide [ * ] ⟩;
    · refine' ⟨ 1, ⟨ 1, by simp +decide ⟩, Or.inr _ ⟩ ; ext <;> simp +decide [ * ];
    · refine' ⟨ -1, ⟨ -1, by simp +decide ⟩, _ ⟩ ; simp_all +decide;
      exact Or.inr ( by ext <;> simp +decide [ * ] );
    · refine' ⟨ -1, ⟨ -1, by simp +decide ⟩, Or.inl _ ⟩ ; ext <;> simp +decide [ * ];
  · simp_all +decide [ abs_eq_abs ];
    rcases h with ⟨ h₁ | h₁, h₂ | h₂ ⟩ <;> simp_all +decide [ isUnit_iff_exists_inv ];
    · refine' ⟨ ⟨ 0, 1 ⟩, _, _ ⟩;
      · exists ⟨ 0, -1 ⟩;
      · exact Or.inr ( by ext <;> simp +decide [ * ] );
    · refine' ⟨ ⟨ 0, -1 ⟩, _, _ ⟩;
      · exists ⟨ 0, 1 ⟩;
      · exact Or.inl <| Zsqrtd.ext ( by simp +decide [ h₁ ] ) ( by simp +decide [ h₂ ] );
    · refine' ⟨ ⟨ 0, 1 ⟩, _, _ ⟩;
      · exists ⟨ 0, -1 ⟩;
      · exact Or.inl <| Zsqrtd.ext ( by simp +decide [ h₁ ] ) ( by simp +decide [ h₂ ] );
    · refine' ⟨ ⟨ 0, -1 ⟩, _, _ ⟩;
      · exists ⟨ 0, 1 ⟩;
      · exact Or.inr ( by ext <;> simp +decide [ * ] )

/-
**Theorem 4.** The legs of `parametrize z` are coprime iff the real and imaginary
parts of `z` are coprime and of opposite parity.
-/
theorem coprime_iff (z : GaussianInt) :
    Int.gcd (parametrize z).1.1 (parametrize z).1.2.1 = 1 ↔
      Int.gcd z.re z.im = 1 ∧ z.re % 2 ≠ z.im % 2 := by
  -- In this direction, we assume that $\gcd(a^2 - b^2, 2ab) = 1$ and derive that $\gcd(a, b) = 1$ and $a$ and $b$ have opposite parity.
  apply Iff.intro
  intro h;
  · constructor <;> contrapose! h;
    · -- If $\gcd(z.re, z.im) \neq 1$, then there exists a prime $p$ such that $p$ divides both $z.re$ and $z.im$.
      obtain ⟨p, hp_prime, hp_div_re, hp_div_im⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ z.re ∧ (p : ℤ) ∣ z.im := by
        exact Nat.Prime.not_coprime_iff_dvd.mp h |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩;
      refine' Nat.Prime.not_coprime_iff_dvd.mpr ⟨ p, hp_prime, _ ⟩;
      simp_all +decide [ ← Int.natCast_dvd_natCast, parametrize ];
      exact ⟨ dvd_sub ( hp_div_re.pow two_ne_zero ) ( hp_div_im.pow two_ne_zero ), dvd_mul_of_dvd_right ( dvd_mul_of_dvd_left ( by simpa using hp_div_re.trans ( by norm_num ) ) _ ) _ ⟩;
    · refine' fun h' => absurd ( h'.symm ▸ Int.dvd_gcd ( show 2 ∣ |z.re ^ 2 - z.im ^ 2| from _ ) ( show 2 ∣ 2 * |z.re * z.im| from dvd_mul_right _ _ ) ) ( by norm_num );
      cases abs_cases ( z.re ^ 2 - z.im ^ 2 ) <;> simp +decide [ *, ← even_iff_two_dvd, parity_simps ];
      · rw [ Int.even_iff, Int.even_iff, h ];
      · grind;
  · intro h_coprime_parity
    have h_coprime : Int.gcd (z.re ^ 2 - z.im ^ 2) (2 * z.re * z.im) = 1 := by
      simp_all +decide [ Int.gcd_eq_natAbs, Int.natAbs_mul, Nat.coprime_mul_iff_right ];
      constructor;
      · constructor;
        · cases Int.emod_two_eq_zero_or_one z.re <;> cases Int.emod_two_eq_zero_or_one z.im <;> simp_all +decide [ ← Int.odd_iff, parity_simps ];
          · exact iff_of_false ( by obtain ⟨ k, hk ⟩ := ‹2 ∣ z.re›; simp +decide [ hk, parity_simps ] ) ( by simpa using ‹Odd z.im› );
          · exact even_iff_two_dvd.mpr ‹_›;
        · refine' Nat.Coprime.symm <| Nat.coprime_of_dvd' _;
          intro k hk hk₁ hk₂; have := Nat.dvd_gcd hk₁ ( show k ∣ z.im.natAbs from ?_ ) ; simp_all +decide ;
          rw [ ← Int.natCast_dvd ] at *; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
          haveI := Fact.mk hk; aesop;
      · refine' Nat.Coprime.symm <| Nat.coprime_of_dvd' _;
        intro k hk hk₁ hk₂; have := Nat.dvd_gcd ( show k ∣ Int.natAbs z.re from ?_ ) hk₁; simp_all +decide ;
        rw [ ← Int.natCast_dvd ] at *;
        exact Int.Prime.dvd_pow' hk ( by simpa using dvd_add hk₂ ( hk₁.pow two_ne_zero ) );
    simp_all +decide [ mul_assoc, Int.gcd, Int.natAbs_mul ];
    unfold parametrize; simp_all +decide [ Int.natAbs_mul, Int.natAbs_abs ] ;

/-
**Theorem 3.** Every positive primitive Pythagorean triple with odd first leg arises
as `parametrize (m + n·i)` for some `m > n > 0` with `gcd(m, n) = 1` and `m, n` of
opposite parity.
-/
theorem surjective_onto_primitive {x y z : ℤ}
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hpyth : x ^ 2 + y ^ 2 = z ^ 2) (hcop : Int.gcd x y = 1) (hodd : x % 2 = 1) :
    ∃ m n : ℤ, n > 0 ∧ m > n ∧ Int.gcd m n = 1 ∧ m % 2 ≠ n % 2 ∧
      (parametrize ⟨m, n⟩).1 = (x, y, z) := by
  obtain ⟨m₀, n₀, hxy, hzpm, hmn, hpar⟩ : ∃ m₀ n₀ : ℤ, (x = m₀^2 - n₀^2 ∧ y = 2 * m₀ * n₀) ∧ z = m₀^2 + n₀^2 ∧ Int.gcd m₀ n₀ = 1 ∧ (m₀ % 2 ≠ n₀ % 2) := by
    have h_class : ∃ m₀ n₀ : ℤ, (x = m₀^2 - n₀^2 ∧ y = 2 * m₀ * n₀) ∨ (x = 2 * m₀ * n₀ ∧ y = m₀^2 - n₀^2) := by
      have := @PythagoreanTriple.coprime_classification x y z; simp_all +decide [ PythagoreanTriple ] ;
      exact this.mp ( by linarith ) |> fun ⟨ m, n, h₁, h₂, h₃, h₄ ⟩ => ⟨ m, n, h₁ ⟩;
    obtain ⟨ m₀, n₀, h | h ⟩ := h_class <;> simp_all +decide [ parity_simps ];
    · refine' ⟨ m₀, n₀, ⟨ rfl, rfl ⟩, _, _, _ ⟩;
      · nlinarith only [ hpyth, hz ];
      · by_contra h_contra;
        -- If $\gcd(m₀, n₀) \neq 1$, then there exists a prime $p$ such that $p$ divides both $m₀$ and $n₀$.
        obtain ⟨p, hp_prime, hp_div_m₀, hp_div_n₀⟩ : ∃ p : ℕ, Nat.Prime p ∧ (p : ℤ) ∣ m₀ ∧ (p : ℤ) ∣ n₀ := by
          exact Nat.Prime.not_coprime_iff_dvd.mp h_contra |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩;
        exact Nat.Prime.not_dvd_one hp_prime ( hcop ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd ( dvd_sub ( hp_div_m₀.pow two_ne_zero ) ( hp_div_n₀.pow two_ne_zero ) ) ( dvd_mul_of_dvd_left ( dvd_mul_of_dvd_right hp_div_m₀ _ ) _ ) ) );
      · cases Int.emod_two_eq_zero_or_one m₀ <;> cases Int.emod_two_eq_zero_or_one n₀ <;> simp_all +decide [ sq, Int.sub_emod, Int.mul_emod ];
        rw [ Int.emod_eq_zero_of_dvd ‹_› ] ; norm_num;
    · norm_num [ Int.mul_emod ] at hodd;
  refine' ⟨ |m₀|, |n₀|, _, _, _, _, _ ⟩ <;> simp_all +decide [ Int.gcd, Int.natAbs_abs ];
  · aesop_cat;
  · rw [ ← sq_lt_sq ] ; aesop;
  · cases abs_cases m₀ <;> cases abs_cases n₀ <;> simp +decide [ * ];
  · unfold parametrize; simp +decide [ abs_of_nonneg, hx.le ] ;
    cases abs_cases m₀ <;> cases abs_cases n₀ <;> simp +decide [ * ] <;> nlinarith

end GaussianParametrize