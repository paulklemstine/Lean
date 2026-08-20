import Tropical.EtaQuotientCongruence

/-!
# The tropical shadow of an eta quotient, and its incompleteness

The `X`-adic order of a power series is a valuation, so it turns products into sums.
Transporting it into the **tropical semiring** `Tropical ℕ∞` (where `⊗` is ordinary
addition and `⊕` is `min`) makes this into an honest algebraic statement:

* `tropOrder_mul`    : `trop ord` is *multiplicative*, `T(fg) = T(f) ⊗ T(g)`;
* `tropOrder_add_le` : it is *super-additive*, `T(f) ⊕ T(g) ≤ T(f + g)`;
* `tropOrder_one`, `tropOrder_zero`, `tropOrder_X_pow` : the normalisations.

Applied to the family of normalised eta quotients `F_a = ∏_m (1 - X^m)^{-b m}` this
says that `a ↦ T(F_a)` is a monoid homomorphism from `(ℕ → ℤ, +)` to the *units* of
the tropical semiring, and that it is the **constant** homomorphism: the tropical
shadow of every admissible eta quotient is the tropical unit `1 = trop 0`.

The point of the file is the last theorem, `tropOrder_not_injective_on_headCoeff`:
the tropical shadow is *blind* to the head coefficient.  Two exponent vectors with
the same (indeed, with the tropically trivial) valuation can have different values of
`c(1) = a₁(a₁+3)/2 + a₂`.  In the language of the surrounding files: the valuation is
the abelianised, tropical layer of the invariant tower, while `headCoeff` is the first
genuinely non-abelian (Heisenberg) layer, and the two layers are independent.
-/

namespace EtaHead

open PowerSeries Finset Tropical

/-! ## Tropicalising the `X`-adic order -/

/-- The tropical shadow of a power series: its `X`-adic order, viewed in the
tropical semiring `Tropical ℕ∞` (`⊗ = +`, `⊕ = min`). -/
noncomputable def tropOrder (f : PowerSeries ℤ) : Tropical ℕ∞ := trop f.order

@[simp] lemma untrop_tropOrder (f : PowerSeries ℤ) : untrop (tropOrder f) = f.order := rfl

/-- Tropical multiplicativity: the valuation axiom `ord (fg) = ord f + ord g`
becomes `T(fg) = T(f) ⊗ T(g)`. -/
theorem tropOrder_mul (f g : PowerSeries ℤ) :
    tropOrder (f * g) = tropOrder f * tropOrder g := by
  rw [tropOrder, tropOrder, tropOrder, trop_mul_def, PowerSeries.order_mul]
  rfl

/-- Tropical super-additivity: `ord (f + g) ≥ min (ord f) (ord g)` becomes
`T(f) ⊕ T(g) ≤ T(f + g)`. -/
theorem tropOrder_add_le (f g : PowerSeries ℤ) :
    tropOrder f + tropOrder g ≤ tropOrder (f + g) := by
  rw [tropOrder, tropOrder, tropOrder, trop_add_def]
  exact untrop_le_iff.mp (min_order_le_order_add f g)

@[simp] theorem tropOrder_one : tropOrder (1 : PowerSeries ℤ) = 1 := by
  rw [tropOrder, PowerSeries.order_one]
  rfl

@[simp] theorem tropOrder_zero : tropOrder (0 : PowerSeries ℤ) = 0 := by
  rw [tropOrder, PowerSeries.order_zero]
  rfl

theorem tropOrder_X_pow (n : ℕ) : tropOrder ((X : PowerSeries ℤ) ^ n) = trop (n : ℕ∞) := by
  rw [tropOrder, PowerSeries.order_X_pow]

/-- `T` sends powers to tropical powers, i.e. to multiples of the order. -/
theorem tropOrder_pow (f : PowerSeries ℤ) (n : ℕ) :
    tropOrder (f ^ n) = tropOrder f ^ n := by
  induction n with
  | zero => simp
  | succ k ih => rw [pow_succ, pow_succ, tropOrder_mul, ih]

/-! ## The tropical shadow of the eta quotients -/

/-- Every normalised eta quotient has tropically trivial shadow. -/
theorem tropOrder_etaQuotientProd (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    tropOrder ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := by
  rw [tropOrder, order_etaQuotientProd a hN]
  rfl

/-- `a ↦ T(F_a)` is a monoid homomorphism from `(ℕ → ℤ, +)` to `(Tropical ℕ∞, ⊗)`. -/
theorem tropOrder_etaQuotientProd_add (a a' : ℕ → ℤ) (N : ℕ) :
    tropOrder ((etaQuotientProd (a + a') N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = tropOrder ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
        * tropOrder ((etaQuotientProd a' N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  rw [etaQuotientProd_add, Units.val_mul, tropOrder_mul]

/-! ## The tropical shadow does not see the head coefficient -/

/-- **The tropical layer is strictly coarser than the head coefficient.**
There are two exponent vectors whose eta quotients have the *same* tropical shadow
(both tropically trivial) but *different* head coefficients `c(1)`.  Hence the
valuation-theoretic (tropical) invariant is a proper quotient of the invariant that
`coeff_two_etaQuotientProd` computes. -/
theorem tropOrder_not_injective_on_headCoeff {N : ℕ} (hN : 2 ≤ N) :
    ∃ a a' : ℕ → ℤ,
      tropOrder ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
          = tropOrder ((etaQuotientProd a' N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
        ∧ coeff 2 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
            ≠ coeff 2 ((etaQuotientProd a' N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  refine ⟨deltaExp, 0, ?_, ?_⟩
  · rw [tropOrder_etaQuotientProd _ hN, tropOrder_etaQuotientProd _ hN]
  · rw [coeff_two_via_recursion _ hN, coeff_two_via_recursion _ hN]
    simp [headCoeff, deltaExp]

/-- Quantitatively: the two exponent vectors above differ in `c(1)` by `324`, while
their tropical shadows are equal.  (`0` has `c(1) = 0`, `Δ` has `c(1) = 324`.) -/
theorem headCoeff_gap_delta_zero : headCoeff deltaExp - headCoeff (0 : ℕ → ℤ) = 324 := by
  simp [headCoeff, deltaExp]

end EtaHead