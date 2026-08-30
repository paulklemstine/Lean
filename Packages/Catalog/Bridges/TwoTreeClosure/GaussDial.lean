import Mathlib
import Bridges.TwoTreeClosure.TreeCore

/-!
# Gauss-sum magnitudes are residue dials, hence tree-blind

Strength (2) of the two-tree closure.  A *Gauss-sum probe* at modulus `M` reads

`G_M(N) = ∑_{x < M} exp(2πi x² N / M)`,

and derived probes read any function of `G_M(N)` (for instance its magnitude, its
argument, or a whole vector of such sums at several moduli).

`gaussSum_periodic` proves that `G_M` is invariant under `N ↦ N + M`, hence
`gaussSum_eq_mod` : `G_M(N) = G_M(N mod M)`.  So every Gauss-sum probe *is* a
residue dial, and `gaussProbe_letterBlind` transports the blindness theorem of
`Bridges.TwoTreeClosure.TreeCore` to it: no Gauss-sum probe at any modulus — in
particular none at the smooth modulus `720720` — can output the ascent letter of a
Berggren/Price node.
-/

namespace TwoTreeClosure

open Finset

/-- The quadratic Gauss sum of `N` at modulus `M`. -/
noncomputable def gaussSum (M N : ℕ) : ℂ :=
  ∑ x ∈ range M, Complex.exp (2 * Real.pi * Complex.I * ((x : ℂ) ^ 2 * (N : ℂ)) / (M : ℂ))

/-- **Gauss sums are `M`-periodic in `N`.** -/
theorem gaussSum_periodic (M N k : ℕ) (hM : 0 < M) :
    gaussSum M (N + k * M) = gaussSum M N := by
  unfold gaussSum
  refine Finset.sum_congr rfl ?_
  intro x _
  have hMne : (M : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hM.ne'
  have hsplit :
      2 * (Real.pi : ℂ) * Complex.I * ((x : ℂ) ^ 2 * ((N : ℂ) + (k : ℂ) * (M : ℂ))) / (M : ℂ)
        = 2 * (Real.pi : ℂ) * Complex.I * ((x : ℂ) ^ 2 * (N : ℂ)) / (M : ℂ)
          + ((x ^ 2 * k : ℕ) : ℂ) * (2 * (Real.pi : ℂ) * Complex.I) := by
    field_simp
    push_cast
    ring
  rw [show ((N + k * M : ℕ) : ℂ) = (N : ℂ) + (k : ℂ) * (M : ℂ) by push_cast; ring]
  rw [hsplit, Complex.exp_add, Complex.exp_nat_mul_two_pi_mul_I, mul_one]

/-- A Gauss sum only sees the residue of `N`. -/
theorem gaussSum_eq_mod (M N : ℕ) (hM : 0 < M) : gaussSum M N = gaussSum M (N % M) := by
  conv_lhs => rw [show N = N % M + (N / M) * M from (Nat.mod_add_div' N M).symm]
  exact gaussSum_periodic M (N % M) (N / M) hM

/-- **Gauss-sum probes are letter blind.**  For every modulus `M ≥ 1` and every
readout `g` of the Gauss sum (magnitude, phase, or anything else), the composite
probe fails to compute the ascent letter of a node. -/
theorem gaussProbe_letterBlind (M : ℕ) (hM : 1 ≤ M) (g : ℂ → Letter) :
    ¬ (∀ m n, IsNode m n → g (gaussSum M (hyp m n)) = letterOf m n) := by
  intro hg
  refine residue_dial_letterBlind M hM (fun r => g (gaussSum M r)) ?_
  intro m n hmn
  have hmod : gaussSum M (hyp m n % M) = gaussSum M (hyp m n) :=
    (gaussSum_eq_mod M (hyp m n) hM).symm
  show g (gaussSum M (hyp m n % M)) = letterOf m n
  rw [hmod]
  exact hg m n hmn

/-- The smooth-modulus instance actually used by the magnitude spectra:
`M = 720720 = 2⁴·3²·5·7·11·13`. -/
theorem gaussProbe_720720_letterBlind (g : ℂ → Letter) :
    ¬ (∀ m n, IsNode m n → g (gaussSum 720720 (hyp m n)) = letterOf m n) :=
  gaussProbe_letterBlind 720720 (by norm_num) g

/-- Even a whole finite battery of Gauss-sum probes, at arbitrarily many moduli,
stays blind: the joint readout is still a function of `N mod (∏ moduli)`, and the
blindness family of `letterOf_blind_of_residue` was built for an arbitrary modulus.
Concretely, a battery indexed by a finite set of moduli all dividing `M` is blind. -/
theorem gaussBattery_letterBlind (M : ℕ) (hM : 1 ≤ M) (s : Finset ℕ)
    (hs : ∀ d ∈ s, d ∣ M ∧ 0 < d) (G : (ℕ → ℂ) → Letter) :
    ¬ (∀ m n, IsNode m n → G (fun d => if d ∈ s then gaussSum d (hyp m n) else 0)
        = letterOf m n) := by
  intro hG
  refine residue_dial_letterBlind M hM
    (fun r => G (fun d => if d ∈ s then gaussSum d r else 0)) ?_
  intro m n hmn
  have hfun : (fun d => if d ∈ s then gaussSum d (hyp m n % M) else 0)
      = (fun d => if d ∈ s then gaussSum d (hyp m n) else 0) := by
    funext d
    by_cases hd : d ∈ s
    · simp only [hd, if_true]
      obtain ⟨hdvd, hdpos⟩ := hs d hd
      have hmod : (hyp m n % M) % d = hyp m n % d := Nat.mod_mod_of_dvd _ hdvd
      rw [gaussSum_eq_mod d (hyp m n % M) hdpos, gaussSum_eq_mod d (hyp m n) hdpos, hmod]
    · simp [hd]
  show G (fun d => if d ∈ s then gaussSum d (hyp m n % M) else 0) = letterOf m n
  rw [hfun]
  exact hG m n hmn

end TwoTreeClosure