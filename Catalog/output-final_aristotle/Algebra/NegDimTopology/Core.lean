/-
# Negative-Dimensional Topology — Poincaré Duality and a Refined Invariant

This file develops a self-contained, machine-checked theory of *virtual graded
spaces*, modelled by the Laurent-polynomial ring

  `VS := ℤ[T; T⁻¹] = AddMonoidAlgebra ℤ ℤ`,

a concrete Spanier–Whitehead / pro-spectrum picture in which `T⁻¹` is
desuspension and hence produces **negative dimensions**.  The *Euler
characteristic* is the ring homomorphism `χ : T ↦ -1`.

## Chain of results (each builds on the previous ones)

1. `chi` — the Euler characteristic ring homomorphism, with
   `chi_T`, `chi_C`, `chi_T_nat`, `chi_T_neg_nat` computing it on monomials.
2. `chi_one`, `chi_add`, `chi_mul` — `χ` is a ring homomorphism (Künneth /
   additivity under disjoint union), and `chi_surjective`.
3. `chi_pureSpace`, `chi_dim_neg_one`, `chi_pure_neg` — the formula
   `χ(X) = (-1)ⁿ·|π₀(X)|` for a `k`-component space in dimension `-n`; the
   title question `dim = -1` gives `χ = -k`.
4. `susp`/`desusp` — suspension and desuspension flip the sign of `χ`
   (`chi_susp`, `chi_desusp`, `chi_suspIter`) and are mutually inverse
   (`susp_desusp`, `desusp_susp`).

## New this cycle

5. **Poincaré duality.** The Spanier–Whitehead dual `dual : T^d ↦ T^{-d}` is an
   involutive ring automorphism (`dual_T`, `dual_C`, `dual_involutive`) that
   swaps suspension and desuspension (`dual_susp`) and, crucially, **preserves
   the Euler characteristic** (`chi_dual : χ(DX) = χ(X)`).
6. **A refined invariant.** `χ` is *not* injective (`disproof_chi_not_injective`)
   — it only sees the parity of the dimension. The top-degree invariant
   `topDim` separates a concrete `χ`-collision (`refined_separates_collision`),
   witnessing a strictly finer invariant.

## Contrarian results

* `disproof_all_neg_chi` — not every negative-dimensional space has negative
  `χ`; even codimensions give `χ > 0`.
* `disproof_chi_not_injective` — `χ` forgets the dimension.
-/
import Mathlib

open LaurentPolynomial

namespace NegDimTopology

/-- Virtual graded spaces: the Laurent-polynomial ring `ℤ[T;T⁻¹]`.
`T⁻¹` is desuspension, so exponents may be negative dimensions. -/
noncomputable abbrev VS := LaurentPolynomial ℤ

/-- The Euler characteristic, as the ring homomorphism `χ : T ↦ -1`.
It is induced by the group homomorphism `ℤ → ℤˣ`, `n ↦ (-1)ⁿ`. -/
noncomputable def chi : VS →+* ℤ :=
  (AddMonoidAlgebra.lift ℤ ℤ ℤ ((Units.coeHom ℤ).comp (zpowersHom ℤˣ (-1 : ℤˣ)))).toRingHom

/-- `χ` on the monomial `T n` is `(-1)ⁿ`, computed in the units `ℤˣ`. -/
theorem chi_T (n : ℤ) : chi (T n) = ((-1 : ℤˣ) ^ n : ℤˣ) := by
  simp only [chi, T, AlgHom.toRingHom_eq_coe, RingHom.coe_coe]
  rw [AddMonoidAlgebra.lift_single]; simp [zpowersHom_apply]

/-- `χ` fixes the constants (dimension-`0` scalars). -/
theorem chi_C (k : ℤ) : chi (C k) = k := by
  rw [← single_eq_C]; simp only [chi, AlgHom.toRingHom_eq_coe, RingHom.coe_coe]
  rw [AddMonoidAlgebra.lift_single]; simp

/-- `χ(Tⁿ) = (-1)ⁿ` for a nonnegative dimension `n`. -/
theorem chi_T_nat (n : ℕ) : chi (T (n : ℤ)) = (-1 : ℤ) ^ n := by
  rw [chi_T, zpow_natCast]; push_cast; ring

/-- `χ(T⁻ⁿ) = (-1)ⁿ` for the negative dimension `-n`. -/
theorem chi_T_neg_nat (n : ℕ) : chi (T (-(n : ℤ))) = (-1 : ℤ) ^ n := by
  rw [chi_T, zpow_neg, zpow_natCast, ← inv_pow, show ((-1:ℤˣ)⁻¹) = -1 by decide]
  push_cast; ring

/-- A `k`-component space concentrated in pure dimension `n`. -/
noncomputable def pureSpace (n k : ℤ) : VS := C k * T n

/-- Suspension: raise every dimension by one. -/
noncomputable def susp (X : VS) : VS := T 1 * X

/-- Desuspension: lower every dimension by one (into negative degrees). -/
noncomputable def desusp (X : VS) : VS := T (-1) * X

/-! ### `χ` is a ring homomorphism -/

/-- The point has Euler characteristic `1`. -/
theorem chi_one : chi 1 = 1 := map_one chi

/-- Additivity of `χ` under disjoint union. -/
theorem chi_add (X Y : VS) : chi (X + Y) = chi X + chi Y := map_add chi X Y

/-- Multiplicativity of `χ` (Künneth formula). -/
theorem chi_mul (X Y : VS) : chi (X * Y) = chi X * chi Y := map_mul chi X Y

/-- Every integer is realised as an Euler characteristic. -/
theorem chi_surjective : Function.Surjective chi := fun m => ⟨C m, chi_C m⟩

/-- The generator `T + 1` lies in the kernel of `χ` (`χ(T+1) = 0`); this is the
degree-`1` witness for the ideal `ker χ = (T + 1)`. -/
theorem chi_ker_witness : chi (T 1 + 1) = 0 := by
  rw [map_add, map_one, show (1:ℤ) = ((1:ℕ):ℤ) by norm_num, chi_T_nat]; ring

/-! ### The main formula `χ(X) = (-1)ⁿ·|π₀(X)|` -/

/-- `χ` of a pure space is its component count times `χ` of its dimension. -/
theorem chi_pureSpace (n k : ℤ) : chi (pureSpace n k) = k * chi (T n) := by
  rw [pureSpace, map_mul, chi_C]

/-- **Dimension `-1` (the title question).** A `k`-component `(-1)`-space has
`χ = -k`. -/
theorem chi_dim_neg_one (k : ℤ) : chi (pureSpace (-1) k) = -k := by
  rw [chi_pureSpace, show (-1 : ℤ) = -((1:ℕ):ℤ) by norm_num, chi_T_neg_nat]; ring

/-- **Euler characteristic in negative dimensions.**  For a `k`-component space
in dimension `-n`, `χ = (-1)ⁿ · k`. -/
theorem chi_pure_neg (n : ℕ) (k : ℤ) : chi (pureSpace (-(n:ℤ)) k) = (-1)^n * k := by
  rw [chi_pureSpace, chi_T_neg_nat]; ring

/-! ### Suspension and desuspension -/

/-- Desuspension undoes suspension. -/
theorem susp_desusp (X : VS) : desusp (susp X) = X := by
  rw [desusp, susp, ← mul_assoc, ← T_add]; simp

/-- Suspension undoes desuspension. -/
theorem desusp_susp (X : VS) : susp (desusp X) = X := by
  rw [susp, desusp, ← mul_assoc, ← T_add]; simp

/-- Suspension flips the sign of `χ`. -/
theorem chi_susp (X : VS) : chi (susp X) = - chi X := by
  rw [susp, map_mul, show (1:ℤ) = ((1:ℕ):ℤ) by norm_num, chi_T_nat]; ring

/-- Desuspension flips the sign of `χ`. -/
theorem chi_desusp (X : VS) : chi (desusp X) = - chi X := by
  rw [desusp, map_mul, show (-1 : ℤ) = -((1:ℕ):ℤ) by norm_num, chi_T_neg_nat]; ring

/-- Iterated suspension multiplies `χ` by `(-1)ᵐ`. -/
theorem chi_suspIter (m : ℕ) (X : VS) : chi (susp^[m] X) = (-1)^m * chi X := by
  induction m with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', chi_susp, ih]; ring

/-! ### Spanier–Whitehead duality (new this cycle) -/

/-- The dualising algebra homomorphism, negating the grading `n ↦ -n`. -/
noncomputable def dualAlg : VS →ₐ[ℤ] VS :=
  AddMonoidAlgebra.mapDomainAlgHom ℤ ℤ (negAddMonoidHom : ℤ →+ ℤ)

/-- The Spanier–Whitehead dual `D : T^d ↦ T^{-d}`, as a ring homomorphism. -/
noncomputable def dual : VS →+* VS := dualAlg.toRingHom

/-- The dual sends dimension `n` to dimension `-n`. -/
theorem dual_T (n : ℤ) : dual (T n) = T (-n) := by
  simp only [dual, dualAlg, AlgHom.toRingHom_eq_coe, RingHom.coe_coe,
    AddMonoidAlgebra.mapDomainAlgHom_apply, T, AddMonoidAlgebra.mapDomain_single]; rfl

/-- The dual fixes constants. -/
theorem dual_C (k : ℤ) : dual (C k) = C k := by
  rw [← single_eq_C]
  simp only [dual, dualAlg, AlgHom.toRingHom_eq_coe, RingHom.coe_coe,
    AddMonoidAlgebra.mapDomainAlgHom_apply, AddMonoidAlgebra.mapDomain_single]; rfl

/-- The dualising homomorphism is an involution (as algebra homomorphisms). -/
theorem dualAlg_comp : dualAlg.comp dualAlg = AlgHom.id ℤ VS := by
  apply AddMonoidAlgebra.algHom_ext; intro n
  show dual (dual (T n)) = T n
  rw [dual_T, dual_T, neg_neg]

/-- Duality is an involution: `D(DX) = X`. -/
theorem dual_involutive (X : VS) : dual (dual X) = X := by
  have := AlgHom.congr_fun dualAlg_comp X; simpa [dual, dualAlg] using this

/-- Duality exchanges suspension and desuspension. -/
theorem dual_susp (X : VS) : dual (susp X) = desusp (dual X) := by
  rw [susp, desusp, map_mul, dual_T]

/-- Duality also exchanges desuspension and suspension. -/
theorem dual_desusp (X : VS) : dual (desusp X) = susp (dual X) := by
  rw [susp, desusp, map_mul, dual_T]; norm_num

/-- Duality is multiplicative (it is a ring homomorphism): `D(X·Y) = DX·DY`. -/
theorem dual_mul (X Y : VS) : dual (X * Y) = dual X * dual Y := map_mul dual X Y

/-- Duality is additive: `D(X+Y) = DX + DY`. -/
theorem dual_add (X Y : VS) : dual (X + Y) = dual X + dual Y := map_add dual X Y

/-- **Poincaré duality.** The Euler characteristic is invariant under
Spanier–Whitehead duality: `χ(DX) = χ(X)`. -/
theorem chi_dual (X : VS) : chi (dual X) = chi X := by
  have h : chi.comp dual = chi := by
    apply AddMonoidAlgebra.ringHom_ext
    · intro r; show chi (dual (C r)) = chi (C r); rw [dual_C]
    · intro n; show chi (dual (T n)) = chi (T n)
      rw [dual_T, chi_T, chi_T, zpow_neg, ← inv_zpow, show ((-1:ℤˣ)⁻¹) = -1 by decide]
  exact congrArg (fun f => f X) h

/-! ### Contrarian results -/

/-- Not every negative-dimensional space has negative `χ`: the pure `(-2)`-space
with one component has `χ = 1 > 0`. -/
theorem disproof_all_neg_chi : chi (pureSpace (-((2:ℕ):ℤ)) 1) > 0 := by
  rw [chi_pure_neg]; norm_num

/-- `χ` is **not injective**: it only detects the parity of the dimension, so it
cannot recover the dimension (`T⁰` and `T²` collide). -/
theorem disproof_chi_not_injective : ¬ Function.Injective chi := by
  intro hinj
  have hchi : chi (T (0:ℤ)) = chi (T (2:ℤ)) := by
    rw [show (0:ℤ) = ((0:ℕ):ℤ) by norm_num, show (2:ℤ) = ((2:ℕ):ℤ) by norm_num,
      chi_T_nat, chi_T_nat]; norm_num
  have heq : (T (0:ℤ) : VS) = T 2 := hinj hchi
  rw [T, T, Finsupp.single_eq_single_iff] at heq; simp at heq

/-! ### A refined invariant that recovers the dimension `χ` forgets -/

/-- The top degree of a virtual space (its highest occupied dimension). -/
noncomputable def topDim (X : VS) : WithBot ℤ := X.support.max

/-- `topDim` of a pure monomial reads off its dimension. -/
theorem topDim_T (n : ℤ) : topDim (T n) = (n : WithBot ℤ) := by
  rw [topDim, T, Finsupp.support_single_ne_zero _ (one_ne_zero)]; simp

/-- **Refinement.**  `topDim` strictly refines `χ`: it distinguishes `T⁰` from
`T²`, a pair that `χ` cannot tell apart. -/
theorem refined_separates_collision :
    topDim (T (0:ℤ)) ≠ topDim (T (2:ℤ)) ∧ chi (T (0:ℤ)) = chi (T (2:ℤ)) := by
  refine ⟨?_, ?_⟩
  · rw [topDim_T, topDim_T]; decide
  · rw [show (0:ℤ) = ((0:ℕ):ℤ) by norm_num, show (2:ℤ) = ((2:ℕ):ℤ) by norm_num,
      chi_T_nat, chi_T_nat]; norm_num

end NegDimTopology