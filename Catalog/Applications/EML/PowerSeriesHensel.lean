import Mathlib

/-!
# Henselian lifting for real power series, and evaluation into Hahn series

This file supplies the algebraic engine that the transseries files use to solve
polynomial equations that are *not* solvable by radicals.

The two ingredients are:

* the ring `ℝ⟦X⟧` of formal power series is `X`-adically complete
  (`PowerSeriesHensel.instIsAdicCompleteSpanX`), hence Henselian at the ideal `(X)`
  (this is `IsAdicComplete.henselianRing` from Mathlib);  consequently a monic
  polynomial over `ℝ⟦X⟧` whose *residue* polynomial in `ℝ[Y]` has a **simple** real
  root can be solved over `ℝ⟦X⟧` (`PowerSeriesHensel.exists_root_of_residue_simple_root`);

* the Hahn-series evaluation map `PowerSeries.heval` transports such a solution into
  any Hahn series field, once we substitute an infinitesimal for `X`
  (`PowerSeriesHensel.tsEval`, `PowerSeriesHensel.eval_map_tsEval_eq_zero`).

The composition of the two is Hensel's lemma for *one-parameter* deformations of a real
polynomial inside a Hahn-series (transseries) field: see
`Applications/EML/TransseriesHensel.lean`.

Everything here is stated for the coefficient field `ℝ` and an arbitrary linearly ordered
value group `Γ`; the transseries files instantiate `Γ` with the EML rank group.
-/

noncomputable section

open PowerSeries Polynomial HahnSeries

namespace PowerSeriesHensel

/-! ## `X`-adic completeness of `ℝ⟦X⟧` -/

/-- Membership in the `n`-th power of the ideal `(X)` (as a submodule of `ℝ⟦X⟧`) means that
the first `n` coefficients vanish. -/
theorem mem_pow_span_X_iff {n : ℕ} {f : ℝ⟦X⟧} :
    f ∈ (Ideal.span {(PowerSeries.X : ℝ⟦X⟧)}) ^ n • (⊤ : Submodule ℝ⟦X⟧ ℝ⟦X⟧) ↔
      ∀ m < n, (PowerSeries.coeff m) f = 0 := by
  have h : (Ideal.span {(PowerSeries.X : ℝ⟦X⟧)}) ^ n • (⊤ : Submodule ℝ⟦X⟧ ℝ⟦X⟧)
      = (Ideal.span {(PowerSeries.X : ℝ⟦X⟧)}) ^ n := by simp
  rw [h, Ideal.span_singleton_pow, Ideal.mem_span_singleton, PowerSeries.X_pow_dvd_iff]

instance : IsHausdorff (Ideal.span {(PowerSeries.X : ℝ⟦X⟧)}) ℝ⟦X⟧ where
  haus' x hx := by
    ext m
    have hm := hx (m + 1)
    rw [SModEq.zero, mem_pow_span_X_iff] at hm
    simpa using hm m (Nat.lt_succ_self m)

instance : IsPrecomplete (Ideal.span {(PowerSeries.X : ℝ⟦X⟧)}) ℝ⟦X⟧ where
  prec' f hf := by
    refine ⟨PowerSeries.mk fun i => PowerSeries.coeff i (f (i + 1)), fun n => ?_⟩
    rw [SModEq.sub_mem, mem_pow_span_X_iff]
    intro m hm
    have h := hf (show m + 1 ≤ n by omega)
    rw [SModEq.sub_mem, mem_pow_span_X_iff] at h
    have h2 := h m (Nat.lt_succ_self m)
    simp only [map_sub, coeff_mk, sub_eq_zero] at h2 ⊢
    exact h2.symm

instance instIsAdicCompleteSpanX :
    IsAdicComplete (Ideal.span {(PowerSeries.X : ℝ⟦X⟧)}) ℝ⟦X⟧ where

/-! ## Hensel's lemma over `ℝ⟦X⟧` -/

/-- **Hensel's lemma for real power series.**  Let `F` be a monic polynomial with power
series coefficients and let `F₀ ∈ ℝ[Y]` be the polynomial obtained by setting `X = 0`.
If `F₀` has a *simple* real root `a`, then `F` has a root in `ℝ⟦X⟧` whose constant term
is `a`: the real root deforms uniquely along the parameter `X`. -/
theorem exists_root_of_residue_simple_root (F : Polynomial ℝ⟦X⟧) (hF : F.Monic) (a : ℝ)
    (h0 : (F.map (PowerSeries.constantCoeff (R := ℝ))).eval a = 0)
    (h1 : (F.map (PowerSeries.constantCoeff (R := ℝ))).derivative.eval a ≠ 0) :
    ∃ y : ℝ⟦X⟧, F.eval y = 0 ∧ PowerSeries.constantCoeff y = a := by
  set cc := (PowerSeries.constantCoeff (R := ℝ)) with hcc
  set I : Ideal ℝ⟦X⟧ := Ideal.span {(PowerSeries.X : ℝ⟦X⟧)} with hI
  have hcca : cc ((PowerSeries.C a : ℝ⟦X⟧)) = a := by simp [hcc]
  have key : ∀ G : Polynomial ℝ⟦X⟧, cc (G.eval (PowerSeries.C a)) = (G.map cc).eval a := by
    intro G
    rw [Polynomial.eval_map, ← hcca, Polynomial.eval₂_hom]
    simp [hcca]
  have hmem : F.eval (PowerSeries.C a) ∈ I := by
    rw [hI, Ideal.mem_span_singleton, PowerSeries.X_dvd_iff, key F, h0]
  have hderiv : IsUnit (F.derivative.eval (PowerSeries.C a)) := by
    rw [PowerSeries.isUnit_iff_constantCoeff]
    have hd : cc (F.derivative.eval (PowerSeries.C a)) = (F.map cc).derivative.eval a := by
      rw [key F.derivative, Polynomial.derivative_map]
    rw [hd]
    exact h1.isUnit
  obtain ⟨y, hy, hy2⟩ := HenselianRing.is_henselian (I := I) F hF (PowerSeries.C a) hmem
    (RingHom.isUnit_map _ hderiv)
  refine ⟨y, hy, ?_⟩
  rw [hI, Ideal.mem_span_singleton, PowerSeries.X_dvd_iff] at hy2
  simp only [map_sub, sub_eq_zero] at hy2
  simpa [hcc] using hy2

/-! ## Evaluating a power series at an infinitesimal Hahn series -/

variable {Γ : Type*} [LinearOrder Γ] [AddCommGroup Γ] [IsOrderedCancelAddMonoid Γ]

/-- Substituting a Hahn series for the variable of a formal power series, landing in the
lexicographically ordered Hahn series field.  (For the substitution to be meaningful the
Hahn series must be infinitesimal, i.e. have positive `orderTop`; otherwise the map is the
junk value given by `PowerSeries.heval`.) -/
def tsEval (x : HahnSeries Γ ℝ) : ℝ⟦X⟧ →+* Lex (HahnSeries Γ ℝ) where
  toFun f := toLex (PowerSeries.heval x f)
  map_one' := congrArg toLex (map_one (PowerSeries.heval x))
  map_mul' f g := congrArg toLex (map_mul (PowerSeries.heval x) f g)
  map_zero' := congrArg toLex (map_zero (PowerSeries.heval x))
  map_add' f g := congrArg toLex (map_add (PowerSeries.heval x) f g)

@[simp] theorem tsEval_apply (x : HahnSeries Γ ℝ) (f : ℝ⟦X⟧) :
    tsEval x f = toLex (PowerSeries.heval x f) := rfl

theorem tsEval_X {x : HahnSeries Γ ℝ} (hx : 0 < x.orderTop) :
    tsEval x PowerSeries.X = toLex x := by
  rw [tsEval_apply, PowerSeries.heval_X x hx]

theorem tsEval_C (x : HahnSeries Γ ℝ) (r : ℝ) :
    tsEval x (PowerSeries.C r) = toLex (single (0 : Γ) r) := by
  rw [tsEval_apply, PowerSeries.heval_C]
  congr 1
  ext g
  simp only [HahnSeries.coeff_smul, smul_eq_mul]
  by_cases h : g = 0 <;> simp [h]

/-- The constant coefficient survives the substitution: the value of a power series at an
infinitesimal has the same "real part" as the power series. -/
theorem coeff_zero_tsEval (x : HahnSeries Γ ℝ) (f : ℝ⟦X⟧) :
    (ofLex (tsEval x f)).coeff 0 = PowerSeries.constantCoeff f :=
  PowerSeries.coeff_heval_zero (x := x) f

/-- Transport of a root along the substitution `X ↦ x`. -/
theorem eval_map_tsEval_eq_zero (x : HahnSeries Γ ℝ) {y : ℝ⟦X⟧} {F : Polynomial ℝ⟦X⟧}
    (hy : F.eval y = 0) : (F.map (tsEval x)).eval (tsEval x y) = 0 := by
  rw [Polynomial.eval_map, Polynomial.eval₂_hom, hy, map_zero]

end PowerSeriesHensel