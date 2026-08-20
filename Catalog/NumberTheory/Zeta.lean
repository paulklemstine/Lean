import Catalog.NumberTheory.Factorization

/-!
# The Möbius zeta function

The Dirichlet series attached to the Möbius integers is

```
ζ̃(s) = ∑_{x ∈ Z̃, x ≠ 0} |x|^{-s}.
```

Since every radius `n ≥ 1` carries exactly two oriented points (`n⁺` and `n⁻`,
`Mobius.MInt.norm_fiber_card`) while the centre `0` carries only one
(`Mobius.MInt.norm_fiber_zero`: the ramification point of the Möbius cover),
the series is **twice** the Riemann zeta function:
`Mobius.MInt.zetaTilde_eq_tsum`.

Consequences established here.

* `Mobius.MInt.zetaTilde_eq_zero_iff`: `ζ̃` and `ζ` have *exactly* the same
  zeros.
* `Mobius.MInt.exists_zero_off_critical_line`: `ζ̃` **does** have zeros off the
  critical line — but only the trivial ones at `s = -2, -4, …`; this is a
  property `ζ̃` inherits from `ζ`, not a symptom of any exotic (non-Ore)
  behaviour, which was refuted in `Factorization.lean`.
* `Mobius.MInt.mobiusRH_iff_riemannHypothesis`: the Möbius Riemann hypothesis
  is *equivalent* to the classical one.  The Möbius twist gives no new
  information about the critical line.
* `Mobius.MInt.zetaTilde_ne_zeta_sq`: the double cover does **not** square the
  zeta function (which is what a genuine two-to-one cover of `Spec ℤ` would
  produce); it merely doubles it.  This is a quantitative form of the statement
  that the doubling comes from the unit group `ℤ/2`, not from splitting primes.
-/

open Complex

namespace Mobius
namespace MInt

/-! ### The fibres of the norm map -/

/-- Away from the centre, every radius supports exactly two oriented points. -/
theorem norm_fiber_card {n : ℕ} (hn : n ≠ 0) : {x : MInt | norm x = n}.ncard = 2 := by
  rw [norm_fiber_eq n, Set.ncard_pair (pos_ne_neg hn)]

/-- The centre of the band is the unique ramification point of the cover: the
fibre of the norm over `0` is a single point. -/
theorem norm_fiber_zero : {x : MInt | norm x = 0} = {0} := by
  ext x
  simp [norm_eq_zero_iff]

/-! ### The Möbius zeta function -/

/-- The **Möbius zeta function**.  By `zetaTilde_eq_tsum` this is exactly the
Dirichlet series `∑_{x ≠ 0} |x|^{-s}` of the Möbius integers on the half plane
of absolute convergence. -/
noncomputable def zetaTilde (s : ℂ) : ℂ := 2 * riemannZeta s

/-- Auxiliary computation: the two-sided integer Dirichlet series. -/
theorem tsum_int_natAbs_cpow {s : ℂ} (hs : 1 < s.re) :
    ∑' n : ℤ, (1 / (n.natAbs : ℂ) ^ s) = 2 * riemannZeta s := by
  have hs0 : s ≠ 0 := by intro h; rw [h] at hs; norm_num at hs
  have hsum : Summable (fun n : ℕ => 1 / ((n : ℂ)) ^ s) := Complex.summable_one_div_nat_cpow.2 hs
  have hsum1 : Summable (fun n : ℕ => 1 / (((n : ℂ)) + 1) ^ s) := by
    have := (summable_nat_add_iff (f := fun n : ℕ => 1 / ((n : ℂ)) ^ s) 1).2 hsum
    simpa using this
  have key : ∀ n : ℕ, (((n : ℤ) + 1).natAbs : ℂ) = (n : ℂ) + 1 := by
    intro n
    have h : ((n : ℤ) + 1).natAbs = n + 1 := by omega
    rw [h]; push_cast; ring
  have key' : ∀ n : ℕ, ((-((n : ℤ) + 1)).natAbs : ℂ) = (n : ℂ) + 1 := by
    intro n
    have h : (-((n : ℤ) + 1)).natAbs = n + 1 := by omega
    rw [h]; push_cast; ring
  have h1 : Summable (fun n : ℕ => 1 / ((((n : ℤ) + 1).natAbs : ℂ)) ^ s) := by
    refine hsum1.congr fun n => ?_; rw [key n]
  have h2 : Summable (fun n : ℕ => 1 / (((-((n : ℤ) + 1)).natAbs : ℂ)) ^ s) := by
    refine hsum1.congr fun n => ?_; rw [key' n]
  have e1 : (∑' n : ℕ, 1 / ((((n : ℤ) + 1).natAbs : ℂ)) ^ s) = ∑' n : ℕ, 1 / ((n : ℂ) + 1) ^ s :=
    tsum_congr fun n => by rw [key n]
  have e2 : (∑' n : ℕ, 1 / (((-((n : ℤ) + 1)).natAbs : ℂ)) ^ s) = ∑' n : ℕ, 1 / ((n : ℂ) + 1) ^ s :=
    tsum_congr fun n => by rw [key' n]
  have H := tsum_of_add_one_of_neg_add_one (f := fun n : ℤ => 1 / (n.natAbs : ℂ) ^ s) h1 h2
  rw [H, e1, e2]
  simp only [Int.natAbs_zero, Nat.cast_zero, Complex.zero_cpow hs0, div_zero, add_zero]
  rw [zeta_eq_tsum_one_div_nat_add_one_cpow hs]
  ring

/-- **The Möbius zeta function is the Dirichlet series of `Z̃`.**  Summing
`|x|^{-s}` over the nonzero Möbius integers gives `2 ζ(s)`: each radius is
counted twice, once for each orientation. -/
theorem zetaTilde_eq_tsum {s : ℂ} (hs : 1 < s.re) :
    zetaTilde s = ∑' x : {x : MInt // x ≠ 0}, 1 / (norm x.val : ℂ) ^ s := by
  have hs0 : s ≠ 0 := by intro h; rw [h] at hs; norm_num at hs
  -- the summand vanishes at the ramification point `0`
  have hsub : Function.support (fun n : ℤ => 1 / ((n.natAbs : ℂ)) ^ s) ⊆ {n : ℤ | n ≠ 0} := by
    intro x hx
    simp only [Function.mem_support] at hx
    intro hx0
    exact hx (by simp [hx0, Complex.zero_cpow hs0])
  -- transport the index set to the nonzero integers along the structure isomorphism
  let e : {x : MInt // x ≠ 0} ≃ ↑({n : ℤ | n ≠ 0}) :=
    Equiv.subtypeEquiv equivZ.toEquiv (fun x => by simp [Set.mem_setOf_eq, toZ_eq_zero_iff])
  have hreindex :
      ∑' x : {x : MInt // x ≠ 0}, 1 / (norm x.val : ℂ) ^ s
        = ∑' n : ℤ, 1 / ((n.natAbs : ℂ)) ^ s := by
    rw [← tsum_subtype_eq_of_support_subset hsub]
    refine Eq.trans ?_ (e.tsum_eq (fun n : ↑({n : ℤ | n ≠ 0}) => 1 / ((n.val.natAbs : ℂ)) ^ s))
    exact tsum_congr fun x => rfl
  rw [hreindex, tsum_int_natAbs_cpow hs, zetaTilde]

/-- **Euler product.**  On the half plane of absolute convergence the Möbius
zeta function is twice the Euler product over the rational primes: each
rational prime contributes *one* factor even though it carries two oriented
primes, because the two are associate. -/
theorem zetaTilde_eulerProduct {s : ℂ} (hs : 1 < s.re) :
    zetaTilde s = 2 * ∏' p : Nat.Primes, (1 - (p : ℂ) ^ (-s))⁻¹ := by
  rw [zetaTilde, riemannZeta_eulerProduct_tprod hs]

/-! ### Zeros -/

@[simp] theorem zetaTilde_eq_zero_iff (s : ℂ) : zetaTilde s = 0 ↔ riemannZeta s = 0 := by
  simp [zetaTilde]

/-- The Möbius zeta function has trivial zeros at the negative even integers. -/
theorem zetaTilde_neg_two_mul_nat_add_one (n : ℕ) : zetaTilde (-2 * (n + 1)) = 0 := by
  rw [zetaTilde_eq_zero_iff]
  exact riemannZeta_neg_two_mul_nat_add_one n

/-- **`ζ̃` has zeros off the critical line** — the conjecture is literally true,
but only because of the *trivial* zeros, which are inherited verbatim from `ζ`
and have nothing to do with the Möbius twist. -/
theorem exists_zero_off_critical_line : ∃ s : ℂ, zetaTilde s = 0 ∧ s.re ≠ 1 / 2 := by
  refine ⟨-2 * ((0 : ℕ) + 1), zetaTilde_neg_two_mul_nat_add_one 0, ?_⟩
  norm_num

/-- The Möbius analogue of the Riemann hypothesis. -/
def MobiusRiemannHypothesis : Prop :=
  ∀ s : ℂ, zetaTilde s = 0 → (¬∃ n : ℕ, s = -2 * (n + 1)) → s ≠ 1 → s.re = 1 / 2

/-- **The Möbius Riemann hypothesis is equivalent to the classical one.**  The
orientation double cover multiplies the zeta function by the order of the unit
group and therefore cannot move a single zero. -/
theorem mobiusRH_iff_riemannHypothesis : MobiusRiemannHypothesis ↔ RiemannHypothesis := by
  constructor
  · intro h s hs htriv hne
    exact h s (by simpa using hs) htriv hne
  · intro h s hs htriv hne
    exact h s ((zetaTilde_eq_zero_iff s).1 hs) htriv hne

/-! ### The doubling is additive, not multiplicative -/

/-- **A genuine double cover of `Spec ℤ` would square the zeta function; the
Möbius cover only doubles it.**  Concretely at `s = 2`, where `ζ(2) = π²/6`,
we have `ζ̃(2) = π²/3 ≠ π⁴/36 = ζ(2)²`.  Together with
`Mobius.MInt.span_pos_eq_span_neg` this is the analytic shadow of the fact that
the two oriented primes over `p` define the same point of the spectrum. -/
theorem zetaTilde_ne_zeta_sq : zetaTilde 2 ≠ (riemannZeta 2) ^ 2 := by
  rw [zetaTilde, riemannZeta_two]
  intro h
  have hpi : ((Real.pi : ℂ)) ^ 2 ≠ 0 := by
    simp [Complex.ofReal_ne_zero.2 Real.pi_ne_zero]
  field_simp at h
  have hreal : (12 : ℝ) = Real.pi ^ 2 := by
    have h2 : ((12 : ℝ) : ℂ) = ((Real.pi ^ 2 : ℝ) : ℂ) := by push_cast; linear_combination h
    exact_mod_cast h2
  nlinarith [Real.pi_lt_d2, Real.pi_gt_three]

end MInt
end Mobius