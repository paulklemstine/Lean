import Mathlib
import Catalog.NumberTheory.Zeta

/-!
# Oriented zeta functions of `k`-fold norm covers

Cycle 1 computed the Dirichlet series of the Möbius integers,
`ζ̃(s) = 2 ζ(s)` (`Mobius.MInt.zetaTilde_eq_tsum`), and deduced that the Möbius
Riemann hypothesis is equivalent to the classical one.  Conjecture 3 of
`FUTURE_DIRECTIONS.md` predicted that this is a completely general phenomenon:
*a norm whose nonzero fibres all have the same finite cardinality `k` produces
the Dirichlet series `k ζ(s)`, so such a cover can never move a zero.*

This file proves that conjecture.

* `Mobius.IsKFoldNorm`: the hypothesis "every nonzero value of the norm is
  attained exactly `k` times".
* `Mobius.tsum_kFoldNorm`: **the general theorem** — for `Re s > 1`,
  `∑_{N x ≠ 0} N(x)^{-s} = k ζ(s)`.  The proof builds an explicit bijection
  between the nonzero part of the domain and `ℕ₊ × Fin k` and reindexes the
  sum.
* `Mobius.kFoldRiemannHypothesis_iff`: the associated "oriented Riemann
  hypothesis" is *equivalent* to the classical one for every `k ≥ 1`.  The
  multiplicity `k` is an additive constant in `log ζ`, never an Euler-factor
  multiplicity, so no oriented cover of this type can produce new zeros.
* `Mobius.MInt.zetaTilde_eq_tsum_of_general`: the Möbius computation of cycle 1
  is recovered as the case `k = 2`, and `Mobius.exists_kFoldNorm` shows every
  `k ≥ 1` really occurs, so the theorem is sharp in `k`.
-/

open Complex

namespace Mobius

/-- A norm `N : A → ℕ` is **`k`-fold** when `0` has a single preimage and every
nonzero value is attained exactly `k` times.  This is the abstract form of the
statement that the orientation group acts simply transitively on the nonzero
norm fibres (`Mobius.MInt.exists_unique_unit_of_norm_eq`). -/
structure IsKFoldNorm {A : Type*} (N : A → ℕ) (k : ℕ) : Prop where
  pos : 0 < k
  fiber : ∀ n : ℕ, n ≠ 0 → {x : A | N x = n}.ncard = k

variable {A : Type*}

/-- Each nonzero fibre of a `k`-fold norm is in bijection with `Fin k`. -/
theorem IsKFoldNorm.nonempty_fiber_equiv {N : A → ℕ} {k : ℕ} (h : IsKFoldNorm N k)
    (n : {m : ℕ // m ≠ 0}) : Nonempty ({x : A // N x = n.val} ≃ Fin k) := by
  have hcard : Nat.card {x : A // N x = n.val} = k := by
    rw [show {x : A // N x = n.val} = ↑({x : A | N x = n.val}) from rfl,
      Nat.card_coe_set_eq]
    exact h.fiber n.val n.2
  have hfin : Finite {x : A // N x = n.val} := (Nat.card_pos_iff.mp (hcard ▸ h.pos)).2
  obtain ⟨m, ⟨e⟩⟩ := Finite.exists_equiv_fin {x : A // N x = n.val}
  have hm : m = k := by rw [← hcard, Nat.card_eq_of_equiv_fin e]
  subst hm
  exact ⟨e⟩

/-- The fibre of the "norm value" map, as a subtype of the base. -/
def fiberEquiv (N : A → ℕ) (n : {m : ℕ // m ≠ 0}) :
    {x : {y : A // N y ≠ 0} // (⟨N x.val, x.2⟩ : {m : ℕ // m ≠ 0}) = n} ≃
      {x : A // N x = n.val} where
  toFun z := ⟨z.val.val, congrArg Subtype.val z.2⟩
  invFun w := ⟨⟨w.val, by rw [w.2]; exact n.2⟩, Subtype.ext w.2⟩
  left_inv z := by apply Subtype.ext; apply Subtype.ext; rfl
  right_inv w := by apply Subtype.ext; rfl

/-- Summing a function of the second coordinate over `ι × β` with `ι` finite
multiplies the sum by `#ι`. -/
theorem tsum_fin_prod {ι β : Type*} [Fintype ι] {g : β → ℂ} (hg : Summable g) :
    ∑' p : ι × β, g p.2 = (Fintype.card ι : ℂ) * ∑' b, g b := by
  have hsum : Summable (fun p : ι × β => g p.2) := by
    rw [← summable_norm_iff, summable_prod_of_nonneg (fun p => norm_nonneg _)]
    exact ⟨fun _ => hg.norm, Summable.of_finite⟩
  rw [hsum.tsum_prod, tsum_fintype]
  simp [Finset.sum_const, nsmul_eq_mul]

/-- The Riemann zeta function as a sum over the *nonzero* naturals. -/
theorem tsum_nonzero_nat_cpow {s : ℂ} (hs : 1 < s.re) :
    ∑' n : {m : ℕ // m ≠ 0}, 1 / ((n : ℕ) : ℂ) ^ s = riemannZeta s := by
  have hs0 : s ≠ 0 := by intro h; rw [h] at hs; norm_num at hs
  have hsub : Function.support (fun n : ℕ => 1 / ((n : ℂ)) ^ s) ⊆ {n : ℕ | n ≠ 0} := by
    intro x hx
    simp only [Function.mem_support] at hx
    intro hx0
    exact hx (by simp [hx0, Complex.zero_cpow hs0])
  rw [show (∑' n : {m : ℕ // m ≠ 0}, 1 / ((n : ℕ) : ℂ) ^ s)
      = ∑' n : ({m : ℕ | m ≠ 0} : Set ℕ), 1 / ((n : ℕ) : ℂ) ^ s from rfl,
    tsum_subtype_eq_of_support_subset hsub, zeta_eq_tsum_one_div_nat_cpow hs]

/-- Summability of the zeta summand over the nonzero naturals. -/
theorem summable_nonzero_nat_cpow {s : ℂ} (hs : 1 < s.re) :
    Summable (fun n : {m : ℕ // m ≠ 0} => 1 / ((n : ℕ) : ℂ) ^ s) := by
  have h : Summable (fun n : ℕ => 1 / ((n : ℂ)) ^ s) := Complex.summable_one_div_nat_cpow.2 hs
  exact h.subtype _

/-- **The oriented zeta theorem.**  If the norm `N` is `k`-fold, its Dirichlet
series is exactly `k` times the Riemann zeta function on the half plane of
absolute convergence.  The multiplicity of the cover appears as a *scalar*, not
inside the Euler factors. -/
theorem tsum_kFoldNorm {N : A → ℕ} {k : ℕ} (h : IsKFoldNorm N k) {s : ℂ} (hs : 1 < s.re) :
    ∑' x : {x : A // N x ≠ 0}, 1 / ((N x.val : ℕ) : ℂ) ^ s = k * riemannZeta s := by
  classical
  -- a choice of trivialisation of every nonzero fibre
  let eqv : ∀ n : {m : ℕ // m ≠ 0}, {x : A // N x = n.val} ≃ Fin k :=
    fun n => Classical.choice (h.nonempty_fiber_equiv n)
  set f : {y : A // N y ≠ 0} → {m : ℕ // m ≠ 0} := fun x => ⟨N x.val, x.2⟩ with hf
  let Φ : {y : A // N y ≠ 0} ≃ Fin k × ({m : ℕ // m ≠ 0}) :=
    ((Equiv.sigmaFiberEquiv f).symm.trans
      ((Equiv.sigmaCongrRight fun n => (fiberEquiv N n).trans (eqv n)).trans
        (Equiv.sigmaEquivProd _ _))).trans (Equiv.prodComm _ _)
  have hN : ∀ p : Fin k × ({m : ℕ // m ≠ 0}), N (Φ.symm p).val = p.2.val := by
    intro p
    have h1 : Φ.symm p = ((fiberEquiv N p.2).symm ((eqv p.2).symm p.1)).val := rfl
    rw [h1]
    exact congrArg Subtype.val ((fiberEquiv N p.2).symm ((eqv p.2).symm p.1)).2
  have hre : ∑' x : {x : A // N x ≠ 0}, 1 / ((N x.val : ℕ) : ℂ) ^ s
      = ∑' p : Fin k × ({m : ℕ // m ≠ 0}), 1 / ((p.2 : ℕ) : ℂ) ^ s := by
    refine (Equiv.tsum_eq Φ.symm (fun x : {x : A // N x ≠ 0} => 1 / ((N x.val : ℕ) : ℂ) ^ s)).symm.trans ?_
    exact tsum_congr fun p => by rw [hN p]
  rw [hre, tsum_fin_prod (summable_nonzero_nat_cpow hs), tsum_nonzero_nat_cpow hs,
    Fintype.card_fin]

/-- Every multiplicity `k ≥ 1` is realised by a `k`-fold norm, so the constant
in `tsum_kFoldNorm` is sharp. -/
theorem exists_kFoldNorm (k : ℕ) (hk : 0 < k) :
    ∃ (A : Type) (N : A → ℕ), IsKFoldNorm N k := by
  classical
  refine ⟨ℕ × Fin k, fun p => p.1, ⟨hk, ?_⟩⟩
  intro n hn
  have hset : {x : ℕ × Fin k | x.1 = n} = (fun i : Fin k => (n, i)) '' Set.univ := by
    ext ⟨m, i⟩
    simp only [Set.mem_setOf_eq, Set.image_univ, Set.mem_range, Prod.mk.injEq]
    constructor
    · rintro rfl; exact ⟨i, rfl, rfl⟩
    · rintro ⟨j, rfl, -⟩; rfl
  have hinj : Function.Injective (fun i : Fin k => ((n, i) : ℕ × Fin k)) := by
    intro i j hij
    simpa using hij
  rw [hset, Set.image_univ, Set.ncard_range_of_injective hinj, Nat.card_eq_fintype_card,
    Fintype.card_fin]

/-! ### No oriented cover of this type can move a zero -/

/-- The oriented zeta function attached to a multiplicity `k`. -/
noncomputable def zetaK (k : ℕ) (s : ℂ) : ℂ := k * riemannZeta s

/-- The Riemann hypothesis for the oriented zeta function `k ζ`. -/
def KFoldRiemannHypothesis (k : ℕ) : Prop :=
  ∀ s : ℂ, zetaK k s = 0 → (¬∃ n : ℕ, s = -2 * (n + 1)) → s ≠ 1 → s.re = 1 / 2

/-- **Conjecture 3, proved.**  For every multiplicity `k ≥ 1` the oriented
Riemann hypothesis is *equivalent* to the classical one: a `k`-fold norm cover
multiplies the Dirichlet series by the size of the fibre, an operation that
cannot create, destroy or move a zero. -/
theorem kFoldRiemannHypothesis_iff {k : ℕ} (hk : 0 < k) :
    KFoldRiemannHypothesis k ↔ RiemannHypothesis := by
  have hk0 : (k : ℂ) ≠ 0 := Nat.cast_ne_zero.2 hk.ne'
  constructor
  · intro h s hs htriv hne
    exact h s (by simp [zetaK, hs]) htriv hne
  · intro h s hs htriv hne
    rw [zetaK, mul_eq_zero] at hs
    rcases hs with hs | hs
    · exact absurd hs hk0
    · exact h s hs htriv hne

/-- The two Riemann hypotheses of the project agree, via the general theorem. -/
theorem mobiusRH_iff_kFold : MInt.MobiusRiemannHypothesis ↔ KFoldRiemannHypothesis 2 := by
  rw [MInt.mobiusRH_iff_riemannHypothesis, kFoldRiemannHypothesis_iff (by norm_num)]

namespace MInt

/-- The Möbius norm is a `2`-fold norm. -/
theorem isKFoldNorm_norm : IsKFoldNorm (norm : MInt → ℕ) 2 :=
  ⟨by norm_num, fun n hn => norm_fiber_card hn⟩

/-- **The cycle-1 computation `ζ̃ = 2ζ` is the case `k = 2` of the general
theorem.**  The Möbius doubling is nothing but the size of the orientation
group. -/
theorem zetaTilde_eq_tsum_of_general {s : ℂ} (hs : 1 < s.re) :
    zetaTilde s = ∑' x : {x : MInt // norm x ≠ 0}, 1 / ((norm x.val : ℕ) : ℂ) ^ s := by
  rw [tsum_kFoldNorm isKFoldNorm_norm hs, zetaTilde]
  norm_num

end MInt
end Mobius