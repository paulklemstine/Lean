/-
# Conjecture A in its literal form

This is the headline file of the development: it states the parity-gap conjecture exactly as
posed —

> for all `n`, all injective `S, T : Fin n → ZMod p`, the parity-weighted exponent counter
> `permCoeff S T` is nonzero somewhere; in fact `max_r |permCoeff S T r| ≥ 1` is attained at a
> residue of the form `∑_j S (σ j) T j` for a permutation `σ` of minimal Coxeter length among
> those realising its exponent

— and proves it, combining

* `ParityGap.exists_permCoeff_ne_zero` (nonvanishing, i.e. Chebotarev's theorem),
* `ParityGap.permCoeff_abs_one_le_of_ne_zero` (integrality: a nonzero counter has modulus `≥ 1`),
* `ParityGap.coxeterLength` (inversion-counting length on the symmetric group).

The single statement `ParityGap.conjectureA` packages all three assertions.
-/

import Mathlib
import Probability.Chebotarev
import Probability.CoxeterLength

open Finset PrimeUncertainty

namespace ParityGap

variable {p : ℕ} [hp : Fact p.Prime] {n : ℕ}

omit hp in
/-- The counter takes integer values, so a nonzero value has modulus at least one. -/
theorem permCoeff_abs_one_le_of_ne_zero (S T : Fin n → ZMod p) (r : ZMod p)
    (h : permCoeff S T r ≠ 0) : 1 ≤ |permCoeff S T r| := by
  obtain ⟨z, hz⟩ : ∃ z : ℤ, permCoeff S T r = (z : ℚ) := ⟨_, permCoeff_eq_intCast S T r⟩
  have hz0 : z ≠ 0 := by
    intro h0
    rw [h0] at hz
    simp only [Int.cast_zero] at hz
    exact h hz
  have h1 : (1 : ℤ) ≤ |z| := Int.one_le_abs (by omega)
  rw [hz, ← Int.cast_abs]
  exact_mod_cast h1

/-- **Conjecture A, literal form.**  For every prime `p`, every `n`, and every pair of injective
families `S, T : Fin n → ZMod p` there is a permutation `σ` of `Fin n` such that

* the residue `E_σ = ∑_j S (σ j) T j` carries a parity-weighted count of modulus at least `1`
  (in particular the counter does not vanish identically);
* that residue realises the maximum `max_r |permCoeff S T r|`;
* and `σ` has minimal Coxeter length among all permutations with exponent `E_σ`. -/
theorem conjectureA (S T : Fin n → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    ∃ σ : Equiv.Perm (Fin n),
      1 ≤ |permCoeff S T (permExp S T σ)| ∧
      (∀ r : ZMod p, |permCoeff S T r| ≤ |permCoeff S T (permExp S T σ)|) ∧
      (∀ τ : Equiv.Perm (Fin n), permExp S T τ = permExp S T σ →
        coxeterLength σ ≤ coxeterLength τ) := by
  classical
  -- a residue where the counter is maximal in modulus
  have hne : (univ : Finset (ZMod p)).Nonempty := univ_nonempty
  obtain ⟨rmax, -, hmax⟩ := Finset.exists_max_image univ (fun r => |permCoeff S T r|) hne
  -- it is nonzero, because some residue has nonzero counter
  obtain ⟨r₀, hr₀⟩ := exists_permCoeff_ne_zero S T hS hT
  have hge : 1 ≤ |permCoeff S T rmax| :=
    le_trans (permCoeff_abs_one_le_of_ne_zero S T r₀ hr₀) (hmax r₀ (mem_univ r₀))
  have hrmax : permCoeff S T rmax ≠ 0 := by
    intro h0
    rw [h0] at hge
    norm_num at hge
  -- the fibre over `rmax` is nonempty
  have hfib : (univ.filter (fun σ : Equiv.Perm (Fin n) => permExp S T σ = rmax)).Nonempty := by
    rw [Finset.nonempty_iff_ne_empty]
    intro hempty
    apply hrmax
    rw [permCoeff_eq_intCast, hempty]
    simp
  -- pick a minimal-length permutation in that fibre
  obtain ⟨σ₀, hσ₀mem, hσ₀min⟩ := Finset.exists_min_image _ coxeterLength hfib
  have hσ₀ : permExp S T σ₀ = rmax := (Finset.mem_filter.mp hσ₀mem).2
  refine ⟨σ₀, by rw [hσ₀]; exact hge, fun r => ?_, fun τ hτ => ?_⟩
  · rw [hσ₀]; exact hmax r (mem_univ r)
  · exact hσ₀min τ (Finset.mem_filter.mpr ⟨mem_univ τ, by rw [hτ, hσ₀]⟩)

end ParityGap