/-
# Convolution powers of an extremal function

`Catalog.Probability.FourierExtremalConvolution` shows that the convolution of two extremal
functions is `0` or extremal, the zero case occurring precisely when the two frequency cosets are
disjoint. For the convolution *powers* of a single extremal function the zero case can never
occur, because the frequency support is preserved exactly. This yields a clean dynamical
statement: the extremal class is a semigroup under convolution powers, and the support size is a
conserved quantity of the dynamics.

Main results:

* `FourierFA.convPow` : the `k`-fold convolution power (with `f^{*0} = δ₀`).
* `FourierFA.dft_convPow` : `(f^{*k})^ = (f̂)^k`.
* `FourierFA.convPow_ne_zero` : convolution powers of a nonzero function never vanish.
* `FourierFA.isExtremal_convPow` : every convolution power of an extremal function is extremal.
* `FourierFA.card_supp_convPow` : the support size is invariant along the convolution dynamics.
-/

import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality
import Shared.FourierExtremals
import Probability.FourierExtremalConverse
import Probability.FourierExtremalConvolution

open Finset ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-- The `k`-fold convolution power of `f`, with `f^{*0}` the Dirac delta at `0` (the unit of the
convolution algebra). -/
noncomputable def convPow (f : G → ℂ) : ℕ → (G → ℂ)
  | 0 => delta 0
  | (n + 1) => conv f (convPow f n)

@[simp] lemma convPow_zero (f : G → ℂ) : convPow f 0 = delta (0 : G) := rfl

@[simp] lemma convPow_succ (f : G → ℂ) (n : ℕ) :
    convPow f (n + 1) = conv f (convPow f n) := rfl

/-- The Dirac delta at `0` is the unit of the convolution algebra. -/
lemma conv_delta_zero (f : G → ℂ) : conv f (delta (0 : G)) = f := by
  funext x
  rw [conv, Finset.sum_eq_single x]
  · simp [delta]
  · intro y _ hy
    have hxy : x - y ≠ 0 := fun h => hy (by rwa [sub_eq_zero, eq_comm] at h)
    have : delta (0 : G) (x - y) = 0 := by
      simp only [delta, if_neg hxy]
    rw [this, mul_zero]
  · intro h; exact absurd (Finset.mem_univ x) h

@[simp] lemma convPow_one (f : G → ℂ) : convPow f 1 = f := by
  rw [convPow_succ, convPow_zero, conv_delta_zero]

/-- The Fourier transform turns convolution powers into pointwise powers. -/
theorem dft_convPow (f : G → ℂ) (k : ℕ) (ψ : AddChar G ℂ) :
    dft (convPow f k) ψ = (dft f ψ) ^ k := by
  induction k with
  | zero => simp [dft_delta, AddChar.map_zero_eq_one]
  | succ n ih => rw [convPow_succ, dft_conv, ih, pow_succ, mul_comm]

/-- Convolution powers of a nonzero function never vanish. -/
theorem convPow_ne_zero {f : G → ℂ} (hf : f ≠ 0) (k : ℕ) : convPow f k ≠ 0 := by
  obtain ⟨ψ, hψ⟩ := supp_nonempty_of_ne_zero (dft_ne_zero hf)
  intro h0
  have h1 : dft (convPow f k) ψ = 0 := by rw [h0, dft_zero]; rfl
  rw [dft_convPow] at h1
  exact pow_ne_zero k (mem_supp.1 hψ) h1

/-- The frequency support is exactly preserved by convolution powers (for `k ≥ 1`). -/
theorem supp_dft_convPow {f : G → ℂ} (k : ℕ) (hk : 1 ≤ k) :
    supp (dft (convPow f k)) = supp (dft f) := by
  ext ψ
  rw [mem_supp, mem_supp, dft_convPow]
  exact pow_ne_zero_iff (by omega)

/-- **Every convolution power of an extremal function is extremal.** -/
theorem isExtremal_convPow {f : G → ℂ} (hf : f ≠ 0) (hext : IsExtremal f) (k : ℕ) (hk : 1 ≤ k) :
    IsExtremal (convPow f k) := by
  induction k with
  | zero => omega
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hk with h1 | h1
    · rw [← h1, convPow_one]
      exact hext
    · have hn : 1 ≤ n := by omega
      have hnext := ih hn
      have hnne : convPow f n ≠ 0 := convPow_ne_zero hf n
      rcases isExtremal_conv hf hnne hext hnext with h0 | hgood
      · exact absurd h0 (convPow_ne_zero hf (n + 1))
      · exact hgood

/-- **The support size is a conserved quantity of the convolution dynamics** on extremal
functions. -/
theorem card_supp_convPow {f : G → ℂ} (hf : f ≠ 0) (hext : IsExtremal f) (k : ℕ) (hk : 1 ≤ k) :
    (supp (convPow f k)).card = (supp f).card := by
  have hk' := isExtremal_convPow hf hext k hk
  rw [IsExtremal, supp_dft_convPow k hk] at hk'
  have hBpos : 0 < (supp (dft f)).card :=
    Finset.card_pos.2 (supp_nonempty_of_ne_zero (dft_ne_zero hf))
  have : (supp (convPow f k)).card * (supp (dft f)).card
      = (supp f).card * (supp (dft f)).card := by rw [hk', hext]
  exact Nat.eq_of_mul_eq_mul_right hBpos this

end FourierFA