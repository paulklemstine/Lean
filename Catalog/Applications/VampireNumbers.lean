import Mathlib

/-!
# Vampire Numbers and the Arithmetic of Digit-Permutation Factorizations

A *vampire number* is a composite number `v` with an even number of (base-10)
digits admitting a factorization `v = x * y`, where `x` and `y` (the *fangs*)
each have half as many digits as `v` and **together use exactly the multiset of
digits of `v`**, subject to the classical side condition that `x` and `y` do not
both end in `0`.  The smallest example is `1260 = 21 · 60`.

The heart of the definition is a purely combinatorial constraint: the digits of
`x` and `y`, taken together, are a permutation of the digits of the product
`x * y`.  We isolate this as `DigitPermFactorization` and derive three
structural obstructions that every such factorization must satisfy.  These are
the arithmetic "silver bullets" that any candidate vampire pair must survive.

## Main results

* `VampireNumbers.castingOutNines` — **casting out nines for factorizations**:
  a digit-permutation factorization forces `x * y ≡ x + y [MOD 9]`,
  equivalently `(x-1)(y-1) ≡ 1 [MOD 9]`.
* `VampireNumbers.fang_not_one_mod_three` — a sharp corollary: neither fang can
  be `≡ 1 (mod 3)`.  This is a genuine sieve that eliminates candidate pairs.
* `VampireNumbers.digit_length_additive` — a digit-permutation factorization
  forces the product to have the *maximal* possible length
  `len(x*y) = len(x) + len(y)`, i.e. the multiplication loses no leading digit.

We then package the classical definition (`IsVampirePair` / `IsVampire`) and
verify `1260 = 21 · 60` as an honest instance, showing the three obstructions in
action.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):  We floated several conjectures.
  (H1) The stated density claim "vampire numbers have density → 1/√n in
       [10^{2n},10^{2n+1}]" is ill-posed: 1/√n → 0, so it asserts vanishing
       density, contradicting the intended reading of "density approaches 1".
       We flag it as false-as-stated and do not pursue it.
  (H2, SURVIVED) Casting out nines must constrain any digit-permutation
       factorization: since a number is ≡ its digit sum (mod 9) and the fang
       digits are a permutation of the product's digits, `x*y ≡ x+y (mod 9)`.
  (H3, SURVIVED, SURPRISING) The mod-9 identity `(x-1)(y-1) ≡ 1 (mod 9)` forces
       both `x-1` and `y-1` to be units mod 3, hence *no fang is ≡ 1 (mod 3)* —
       a one-line sieve rejecting ~1/3 of candidate factors.
  (H4, SURVIVED) The permutation condition forbids "carry shrinkage": the
       product must have length exactly len(x)+len(y).

Experiment (Experimenter):  Base cases confirm H2/H3/H4: for 1260 = 21·60,
  21·60 = 1260 ≡ 21+60 = 81 ≡ 0 (mod 9); 21 ≡ 0, 60 ≡ 0 (mod 3), neither ≡ 1;
  len(1260)=4 = len(21)+len(60)=2+2.  Mathlib supplies
  `Nat.modEq_nine_digits_sum` (`n ≡ (digits 10 n).sum [MOD 9]`), which is the
  exact fuel for H2.

Analysis (Analyst):  See sibling `Analysis` blocks; H2–H4 are all true and
  proved.  H1 is false as literally stated.  The multiset formulation (rather
  than `List.Perm`) is what makes the sum/length transfers a one-line
  `congrArg`.

Critique (Critic):  None of the three main theorems is `decide`/`native_decide`;
  each transports a Mathlib modular/multiset lemma through the permutation
  hypothesis.  The `1260` instance uses `decide` only for the concrete finite
  digit computation, not for a universally-quantified claim.

Synthesis (PI):  Casting out nines + the mod-3 unit obstruction + length
  additivity form a compact, reusable "bestiary sieve" for arithmetic monsters.
-/

namespace VampireNumbers

open Nat

/-- A **digit-permutation factorization**: the base-10 digits of the product
`x * y`, as a multiset, are exactly the digits of `x` together with the digits
of `y`.  This is the combinatorial core of every "vampire-style" definition. -/
def DigitPermFactorization (x y : ℕ) : Prop :=
  (↑(Nat.digits 10 (x * y)) : Multiset ℕ)
    = (↑(Nat.digits 10 x) : Multiset ℕ) + (↑(Nat.digits 10 y) : Multiset ℕ)

/-- The digit sums add: this is the multiset condition read through `sum`. -/
theorem digit_sum_additive {x y : ℕ} (h : DigitPermFactorization x y) :
    (Nat.digits 10 (x * y)).sum = (Nat.digits 10 x).sum + (Nat.digits 10 y).sum := by
  have := congrArg Multiset.sum h
  simpa using this

/-- **Casting out nines for digit-permutation factorizations.**
If the digits of `x` and `y` together permute the digits of `x * y`, then
`x * y ≡ x + y [MOD 9]`.  Equivalently `(x-1)(y-1) ≡ 1 (mod 9)`.

*Analysis:* the whole argument is `n ≡ digitsum(n) (mod 9)` applied three times,
glued by the additive digit-sum identity above. -/
theorem castingOutNines {x y : ℕ} (h : DigitPermFactorization x y) :
    x * y ≡ x + y [MOD 9] := by
  have hsum := digit_sum_additive h
  have hxy := Nat.modEq_nine_digits_sum (x * y)
  have hx := Nat.modEq_nine_digits_sum x
  have hy := Nat.modEq_nine_digits_sum y
  calc x * y ≡ (Nat.digits 10 (x * y)).sum [MOD 9] := hxy
    _ = (Nat.digits 10 x).sum + (Nat.digits 10 y).sum := hsum
    _ ≡ x + y [MOD 9] := (hx.add hy).symm

/-- The mod-3 shadow of casting out nines. -/
theorem castingOutThrees {x y : ℕ} (h : DigitPermFactorization x y) :
    x * y ≡ x + y [MOD 3] :=
  (castingOutNines h).of_dvd (by norm_num)

/-- **The mod-3 unit obstruction.**  In any digit-permutation factorization,
*neither fang is congruent to `1` modulo `3`*.  Indeed if `x ≡ 1 (mod 3)` then
`x*y ≡ x+y (mod 3)` collapses to `y ≡ 1 + y`, i.e. `0 ≡ 1 (mod 3)`.

*Analysis:* casting the mod-3 identity into `ZMod 3` turns the obstruction into
a two-element linear contradiction. -/
theorem fang_not_one_mod_three {x y : ℕ} (h : DigitPermFactorization x y) :
    x % 3 ≠ 1 ∧ y % 3 ≠ 1 := by
  have h3 := castingOutThrees h
  have hcast : (x : ZMod 3) * y = (x : ZMod 3) + y := by
    have := (ZMod.natCast_eq_natCast_iff _ _ _).mpr h3
    push_cast at this
    exact this
  have key : ∀ a b : ℕ, (a : ZMod 3) * b = (a : ZMod 3) + b → a % 3 ≠ 1 := by
    intro a b hab ha
    have hA1 : (a : ZMod 3) = 1 := by
      have h' : (a : ZMod 3) = ((a % 3 : ℕ) : ZMod 3) := by rw [ZMod.natCast_mod]
      rw [h', ha]; simp
    rw [hA1, one_mul] at hab
    have hcontra : (0 : ZMod 3) = 1 := by linear_combination hab
    exact absurd hcontra (by decide)
  exact ⟨key x y hcast, key y x (by rw [mul_comm, add_comm]; exact hcast)⟩

/-- **Length additivity / no carry shrinkage.**  A digit-permutation
factorization forces the product to attain the maximal possible number of
digits: `len(x*y) = len(x) + len(y)`.  Generically `len(x*y)` could be one less
(when the top digits multiply without carrying into a new place); the
permutation condition rules this out.

*Analysis:* multiset cardinality equals list length, so this is `congrArg
Multiset.card` applied to the defining equation. -/
theorem digit_length_additive {x y : ℕ} (h : DigitPermFactorization x y) :
    (Nat.digits 10 (x * y)).length
      = (Nat.digits 10 x).length + (Nat.digits 10 y).length := by
  have := congrArg Multiset.card h
  simpa using this

/-! ## The classical vampire number and a worked instance -/

/-- A **vampire pair**: `v = x * y` is a `2k`-digit number whose fangs `x, y`
each have `k` digits and together permute the digits of `v`, with the classical
"no trailing zeros in both fangs" side condition. -/
structure IsVampirePair (v x y : ℕ) : Prop where
  factor : v = x * y
  even_length : Even (Nat.digits 10 v).length
  equal_fang_length : (Nat.digits 10 x).length = (Nat.digits 10 y).length
  perm : DigitPermFactorization x y
  not_both_trailing_zero : ¬ (x % 10 = 0 ∧ y % 10 = 0)

/-- `v` is a **vampire number** if it has some vampire factorization. -/
def IsVampire (v : ℕ) : Prop := ∃ x y, IsVampirePair v x y

/-- `1260 = 21 · 60` is a vampire number. -/
theorem isVampire_1260 : IsVampire 1260 := by
  refine ⟨21, 60, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · decide
  · decide
  · show (↑(Nat.digits 10 (21 * 60)) : Multiset ℕ) = _
    decide
  · decide

/-- The three obstructions in action on the smallest vampire number,
each obtained from the general theorems rather than by direct computation. -/
theorem obstructions_1260 :
    (21 * 60 ≡ 21 + 60 [MOD 9]) ∧ (21 % 3 ≠ 1 ∧ 60 % 3 ≠ 1)
      ∧ (Nat.digits 10 (21 * 60)).length
          = (Nat.digits 10 21).length + (Nat.digits 10 60).length := by
  have hperm : DigitPermFactorization 21 60 := by
    show (↑(Nat.digits 10 (21 * 60)) : Multiset ℕ) = _
    decide
  exact ⟨castingOutNines hperm, fang_not_one_mod_three hperm,
    digit_length_additive hperm⟩

end VampireNumbers