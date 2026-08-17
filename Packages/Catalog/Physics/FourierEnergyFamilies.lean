/-
# Two explicit families for which the Fourier covering bound beats pigeonhole

This file closes the second half of the problem left open by
`Catalog.Shared.FourierAdditive`: it exhibits **explicit infinite families** `A ⊆ G` for
which the covering bound `FourierAdd.card_support_rep_ge` is strictly stronger than the
pigeonhole bound `|A + A| ≥ |A|`, and it **computes the nonprincipal Fourier energy `E`
exactly** for them.

## Family 1 — the parabola in `(ZMod p)²` (odd prime `p`)

`P = {(x, x²) : x ∈ ZMod p}` is a Sidon set (two points of a conic determine the chord),
so by `FourierEnergy.fourierEnergy_sidon`:

* `|P| = p`, `|G| = p²`;
* additive energy `Ẽ = 2p² − p`;
* **`E = p⁴ − p³`**;
* covering bound `= p³/(2p − 1) ≥ p²/2`, versus pigeonhole `p`.

So the Fourier bound is **quadratically** stronger than pigeonhole; and since
`|P + P| = p(p+1)/2` this is sharp up to the factor `1 + o(1)`.

## Family 2 — the Hamming ball of radius one in `𝔽₂ⁿ`

`B = {0, e₁, …, eₙ} ⊆ 𝔽₂ⁿ` is Sidon *off the diagonal* (`IsSidon2`), the diagonal being
collapsed by `x + x = 0`.  By `FourierEnergy.fourierEnergy_sidon2`:

* `|B| = n + 1`, `|G| = 2ⁿ`;
* additive energy `Ẽ = 3n² + 4n + 1`;
* **`E = 2ⁿ(3n² + 4n + 1) − (n+1)⁴`**;
* covering bound `= (n+1)³/(3n+1) ≥ (n+1)²/3`, versus pigeonhole `n + 1`.

Here the group is a `ℤ/2`-vector space — the phase space of `n` classical bits — and the
bound certifies that `n + 1` "single-bit-flip" states already generate a sumset of size
`≳ n²/3`, quadratically more than pigeonhole detects.

Main results: `FourierEnergyFamilies.parabola_fourierEnergy`,
`FourierEnergyFamilies.parabola_fourierBound`,
`FourierEnergyFamilies.parabola_beats_pigeonhole`,
`FourierEnergyFamilies.hammingBall_fourierEnergy`,
`FourierEnergyFamilies.hammingBall_fourierBound`,
`FourierEnergyFamilies.hammingBall_beats_pigeonhole`, and the sumset corollaries
`FourierEnergyFamilies.parabola_card_add_ge`,
`FourierEnergyFamilies.hammingBall_card_add_ge`.
-/

import Mathlib
import Catalog.Physics.FourierEnergySidon

open Finset FourierAdd FourierEnergy
open scoped Pointwise

namespace FourierEnergyFamilies

/-! ## Family 1: the parabola in `(ZMod p)²` -/

section Parabola

variable (p : ℕ) [Fact p.Prime]

/-- The parabola `{(x, x²)}` in the plane over `ZMod p`. -/
def parabola : Finset (ZMod p × ZMod p) := Finset.univ.image (fun x : ZMod p => (x, x ^ 2))

theorem mem_parabola {a : ZMod p × ZMod p} : a ∈ parabola p ↔ ∃ x : ZMod p, (x, x ^ 2) = a := by
  simp [parabola]

theorem card_parabola : (parabola p).card = p := by
  have hinj : Function.Injective (fun x : ZMod p => (x, x ^ 2)) := fun x y h => congrArg Prod.fst h
  rw [parabola, Finset.card_image_of_injective _ hinj, Finset.card_univ, ZMod.card]

theorem parabola_nonempty : (parabola p).Nonempty := by
  refine Finset.card_pos.1 ?_
  rw [card_parabola]
  exact (Fact.out : p.Prime).pos

/-- The parabola is a Sidon set: a chord of the conic determines its two endpoints.
This is where the hypothesis `p ≠ 2` enters (in characteristic two the parabola is a
line). -/
theorem isSidon_parabola (hp : p ≠ 2) : IsSidon (parabola p) := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    have hdvd : ¬ (p ∣ 2) := by
      intro hd
      rcases (Nat.Prime.eq_one_or_self_of_dvd Nat.prime_two p hd) with h | h
      · exact (Fact.out : p.Prime).one_lt.ne' h
      · exact hp h
    have : ((2 : ℕ) : ZMod p) ≠ 0 := by
      rw [Ne, ZMod.natCast_eq_zero_iff]
      exact hdvd
    simpa using this
  intro a ha b hb c hc d hd habcd
  obtain ⟨x, rfl⟩ := (mem_parabola p).1 ha
  obtain ⟨y, rfl⟩ := (mem_parabola p).1 hb
  obtain ⟨u, rfl⟩ := (mem_parabola p).1 hc
  obtain ⟨v, rfl⟩ := (mem_parabola p).1 hd
  have h1 : x + y = u + v := congrArg Prod.fst habcd
  have hsq : x ^ 2 + y ^ 2 = u ^ 2 + v ^ 2 := congrArg Prod.snd habcd
  have hxy2 : 2 * (x * y) = 2 * (u * v) := by linear_combination (x + y + u + v) * h1 - hsq
  have hxy : x * y = u * v := mul_left_cancel₀ h2 hxy2
  have key : (x - u) * (x - v) = 0 := by linear_combination x * h1 - hxy
  rcases mul_eq_zero.1 key with h | h
  · have hxu : x = u := by linear_combination h
    subst hxu
    left
    refine ⟨rfl, ?_⟩
    have : y = v := by linear_combination h1
    rw [this]
  · have hxv : x = v := by linear_combination h
    subst hxv
    right
    refine ⟨rfl, ?_⟩
    have : y = u := by linear_combination h1
    rw [this]

/-- **The nonprincipal Fourier energy of the parabola**: `E = p⁴ − p³`. -/
theorem parabola_fourierEnergy (hp : p ≠ 2) :
    fourierEnergy (parabola p) (parabola p) = (p : ℝ) ^ 4 - (p : ℝ) ^ 3 := by
  have hcard : Fintype.card (ZMod p × ZMod p) = p * p := by
    simp [ZMod.card]
  rw [fourierEnergy_sidon (isSidon_parabola p hp), card_parabola, hcard]
  push_cast
  ring

/-- **The covering bound for the parabola** equals `p³/(2p − 1)`. -/
theorem parabola_fourierBound (hp : p ≠ 2) :
    fourierBound (parabola p) (parabola p) = (p : ℝ) ^ 3 / (2 * (p : ℝ) - 1) := by
  rw [fourierBound_sidon (isSidon_parabola p hp) (parabola_nonempty p), card_parabola]

/-- **The parabola beats pigeonhole**, strictly, for every odd prime. -/
theorem parabola_beats_pigeonhole (hp : p ≠ 2) :
    ((p : ℕ) : ℝ) < fourierBound (parabola p) (parabola p) := by
  have hk : 2 ≤ (parabola p).card := by
    rw [card_parabola]
    rcases (Fact.out : p.Prime).two_le.lt_or_eq with h | h
    · omega
    · exact absurd h.symm hp
  have := sidon_beats_pigeonhole (isSidon_parabola p hp) hk
  rwa [max_self, card_parabola] at this

/-- **Quadratic sumset bound for the parabola**: `|P + P| ≥ p²/2`, versus the pigeonhole
value `p`. -/
theorem parabola_card_add_ge (hp : p ≠ 2) :
    ((p : ℝ)) ^ 2 / 2 ≤ (((parabola p + parabola p).card : ℕ) : ℝ) := by
  have := card_add_ge_sidon (isSidon_parabola p hp) (parabola_nonempty p)
  rwa [card_parabola] at this

/-- **The exact sumset size of the parabola**: `|P + P| = p(p+1)/2`.  Together with
`parabola_fourierBound` this shows the covering bound `p³/(2p−1)` is sharp to within a
factor `1 + 1/(2p)`. -/
theorem parabola_card_add (hp : p ≠ 2) :
    2 * (parabola p + parabola p).card = p * (p + 1) := by
  have h := card_add_sidon_eq (isSidon_parabola p hp)
  rwa [card_parabola] at h

/-- **Quadratic lower bound for the parabola**: the covering bound is at least `p²/2`,
against the pigeonhole value `p`. -/
theorem parabola_bound_quadratic (hp : p ≠ 2) :
    ((p : ℝ)) ^ 2 / 2 ≤ fourierBound (parabola p) (parabola p) := by
  have h := sidon_quadratic (isSidon_parabola p hp) (parabola_nonempty p)
  rwa [card_parabola] at h

/-- The covering bound for the parabola is sharp up to the factor `1 + 1/(2p)`. -/
theorem parabola_bound_sharp (hp : p ≠ 2) :
    (((parabola p + parabola p).card : ℕ) : ℝ)
      ≤ (1 + 1 / (2 * (p : ℝ))) * fourierBound (parabola p) (parabola p) := by
  have h := sidon_bound_sharp (isSidon_parabola p hp) (parabola_nonempty p)
  rwa [card_parabola] at h

end Parabola

/-! ## Family 2: the Hamming ball of radius one in `𝔽₂ⁿ` -/

section HammingBall

variable {n : ℕ}

/-- The `i`-th standard basis vector of `𝔽₂ⁿ`. -/
def unitVec (i : Fin n) : Fin n → ZMod 2 := Pi.single i 1

theorem unitVec_apply (i j : Fin n) : unitVec i j = if j = i then 1 else 0 := by
  simp [unitVec, Pi.single_apply]

@[simp] theorem unitVec_self (i : Fin n) : unitVec i i = 1 := by simp [unitVec_apply]

theorem unitVec_of_ne {i j : Fin n} (h : j ≠ i) : unitVec i j = 0 := by
  simp [unitVec_apply, h]

theorem zmod2_one_ne_zero : (1 : ZMod 2) ≠ 0 := by decide

theorem unitVec_injective : Function.Injective (unitVec (n := n)) := by
  intro i j h
  by_contra hij
  have hval := congrArg (fun f => f i) h
  simp only [unitVec_self, unitVec_apply, if_neg hij] at hval
  exact zmod2_one_ne_zero hval

theorem unitVec_ne_zero (i : Fin n) : unitVec i ≠ 0 := by
  intro h
  have hval := congrArg (fun f => f i) h
  simp only [unitVec_self, Pi.zero_apply] at hval
  exact zmod2_one_ne_zero hval

/-- The Hamming ball of radius one: the all-zero vector together with the `n` weight-one
vectors. -/
def hammingBall (n : ℕ) : Finset (Fin n → ZMod 2) :=
  insert 0 (Finset.univ.image (unitVec (n := n)))

theorem mem_hammingBall {x : Fin n → ZMod 2} :
    x ∈ hammingBall n ↔ x = 0 ∨ ∃ i, x = unitVec i := by
  simp [hammingBall, eq_comm]

theorem card_hammingBall : (hammingBall n).card = n + 1 := by
  have h0 : (0 : Fin n → ZMod 2) ∉ Finset.univ.image (unitVec (n := n)) := by
    simp only [Finset.mem_image, Finset.mem_univ, true_and]
    rintro ⟨i, hi⟩
    exact unitVec_ne_zero i hi
  rw [hammingBall, Finset.card_insert_of_notMem h0,
    Finset.card_image_of_injective _ unitVec_injective, Finset.card_univ, Fintype.card_fin]

theorem hammingBall_nonempty : (hammingBall n).Nonempty := ⟨0, by simp [mem_hammingBall]⟩

/-- `𝔽₂ⁿ` has exponent two. -/
theorem exp_two (x : Fin n → ZMod 2) : x + x = 0 := by
  funext i
  have : ∀ a : ZMod 2, a + a = 0 := by decide
  simpa using this (x i)

/-- A vector with two distinct coordinates equal to `1` is not in the ball. -/
theorem notMem_hammingBall_of_two_ones {x : Fin n → ZMod 2} {i j : Fin n} (hij : i ≠ j)
    (hi : x i = 1) (hj : x j = 1) : x ∉ hammingBall n := by
  intro hx
  rcases mem_hammingBall.1 hx with rfl | ⟨k, rfl⟩
  · rw [Pi.zero_apply] at hi
    exact zmod2_one_ne_zero hi.symm
  · have h1 : i = k := by
      by_contra h
      rw [unitVec_of_ne h] at hi
      exact zmod2_one_ne_zero hi.symm
    have h2 : j = k := by
      by_contra h
      rw [unitVec_of_ne h] at hj
      exact zmod2_one_ne_zero hj.symm
    exact hij (h1.trans h2.symm)

/-- The triple-wise Sidon condition for the Hamming ball. -/
theorem hammingBall_triple (a : Fin n → ZMod 2) (ha : a ∈ hammingBall n)
    (b : Fin n → ZMod 2) (hb : b ∈ hammingBall n) (y : Fin n → ZMod 2)
    (hy : y ∈ hammingBall n) (hab : a ≠ b) (hya : y ≠ a) (hyb : y ≠ b) :
    a + b + y ∉ hammingBall n := by
  rcases mem_hammingBall.1 ha with rfl | ⟨i, rfl⟩
  · rcases mem_hammingBall.1 hb with rfl | ⟨j, rfl⟩
    · exact absurd rfl hab
    · rcases mem_hammingBall.1 hy with rfl | ⟨k, rfl⟩
      · exact absurd rfl hya
      · have hkj : k ≠ j := fun h => hyb (by rw [h])
        refine notMem_hammingBall_of_two_ones hkj.symm ?_ ?_
        · simp [unitVec_apply, Ne.symm hkj]
        · simp [unitVec_apply, hkj]
  · rcases mem_hammingBall.1 hb with rfl | ⟨j, rfl⟩
    · rcases mem_hammingBall.1 hy with rfl | ⟨k, rfl⟩
      · exact absurd rfl hyb
      · have hki : k ≠ i := fun h => hya (by rw [h])
        refine notMem_hammingBall_of_two_ones hki.symm ?_ ?_
        · simp [unitVec_apply, Ne.symm hki]
        · simp [unitVec_apply, hki]
    · have hij : i ≠ j := fun h => hab (by rw [h])
      rcases mem_hammingBall.1 hy with rfl | ⟨k, rfl⟩
      · refine notMem_hammingBall_of_two_ones hij ?_ ?_
        · simp [unitVec_apply, hij]
        · simp [unitVec_apply, Ne.symm hij]
      · have hki : k ≠ i := fun h => hya (by rw [h])
        have hkj : k ≠ j := fun h => hyb (by rw [h])
        refine notMem_hammingBall_of_two_ones hij ?_ ?_
        · simp [unitVec_apply, hij, Ne.symm hki]
        · simp [unitVec_apply, Ne.symm hij, Ne.symm hkj]

/-- The Hamming ball is Sidon off the diagonal. -/
theorem isSidon2_hammingBall : IsSidon2 (hammingBall n) :=
  isSidon2_of_triple exp_two hammingBall_triple

/-- **The additive energy of the Hamming ball**: `Ẽ = 3n² + 4n + 1`. -/
theorem hammingBall_addEnergy :
    FourierEnergy.addEnergy (hammingBall n) (hammingBall n) = 3 * n ^ 2 + 4 * n + 1 := by
  have h := addEnergy_sidon2 (A := hammingBall n) exp_two isSidon2_hammingBall
  rw [card_hammingBall] at h
  have hexp : 3 * (n + 1) ^ 2 = 3 * n ^ 2 + 6 * n + 3 := by ring
  omega

/-- **The nonprincipal Fourier energy of the Hamming ball**:
`E = 2ⁿ(3n² + 4n + 1) − (n+1)⁴`. -/
theorem hammingBall_fourierEnergy :
    fourierEnergy (hammingBall n) (hammingBall n)
      = 2 ^ n * (3 * (n : ℝ) ^ 2 + 4 * (n : ℝ) + 1) - ((n : ℝ) + 1) ^ 4 := by
  have hcard : Fintype.card (Fin n → ZMod 2) = 2 ^ n := by
    simp [ZMod.card]
  rw [fourierEnergy_sidon2 exp_two isSidon2_hammingBall, card_hammingBall, hcard]
  push_cast
  ring

/-- **The covering bound for the Hamming ball** equals `(n+1)³/(3n+1)`. -/
theorem hammingBall_fourierBound :
    fourierBound (hammingBall n) (hammingBall n)
      = ((n : ℝ) + 1) ^ 3 / (3 * (n : ℝ) + 1) := by
  rw [fourierBound_sidon2 exp_two isSidon2_hammingBall hammingBall_nonempty, card_hammingBall]
  push_cast
  ring_nf

/-- **The Hamming ball beats pigeonhole**, strictly, for every `n ≥ 2`. -/
theorem hammingBall_beats_pigeonhole (hn : 2 ≤ n) :
    ((n : ℝ) + 1) < fourierBound (hammingBall n) (hammingBall n) := by
  have hk : 3 ≤ (hammingBall n).card := by
    rw [card_hammingBall]; omega
  have h := sidon2_beats_pigeonhole (A := hammingBall n) exp_two isSidon2_hammingBall hk
  rw [max_self, card_hammingBall] at h
  push_cast at h
  linarith

/-- **Superlinear lower bound for the Hamming ball**: the covering bound is at least
`(n+1)²/3`, against the pigeonhole value `n + 1`. -/
theorem hammingBall_bound_superlinear :
    ((n : ℝ) + 1) ^ 2 / 3 ≤ fourierBound (hammingBall n) (hammingBall n) := by
  have h := sidon2_quadratic (A := hammingBall n) exp_two isSidon2_hammingBall
    hammingBall_nonempty
  rw [card_hammingBall] at h
  push_cast at h
  linarith

/-- **Superlinear sumset bound for the Hamming ball**: `|B + B| ≥ (n+1)²/3`, versus the
pigeonhole value `n + 1`. -/
theorem hammingBall_card_add_ge :
    ((n : ℝ) + 1) ^ 2 / 3 ≤ (((hammingBall n + hammingBall n).card : ℕ) : ℝ) := by
  have h := card_add_ge_sidon2 (A := hammingBall n) exp_two isSidon2_hammingBall
    hammingBall_nonempty
  rw [card_hammingBall] at h
  push_cast at h
  linarith

/-- **The exact sumset size of the Hamming ball**: `|B + B| = 1 + n(n+1)/2` (the zero
vector, the `n` weight-one vectors and the `n(n−1)/2` weight-two vectors). -/
theorem hammingBall_card_add :
    2 * (hammingBall n + hammingBall n).card = n ^ 2 + n + 2 := by
  have h := card_add_sidon2_eq (A := hammingBall n) exp_two isSidon2_hammingBall
    hammingBall_nonempty
  rw [card_hammingBall] at h
  have hsq : (n + 1) ^ 2 = n ^ 2 + 2 * n + 1 := by ring
  omega

/-- In exponent two the covering bound loses a factor `3/2`: the true sumset size
`1 + n(n+1)/2 ~ n²/2` is at most `3/2` times the bound `(n+1)³/(3n+1) ~ n²/3`, and this
is asymptotically attained. -/
theorem hammingBall_bound_within_three_halves :
    (((hammingBall n + hammingBall n).card : ℕ) : ℝ)
      ≤ 3 / 2 * fourierBound (hammingBall n) (hammingBall n) :=
  sidon2_bound_within_three_halves (A := hammingBall n) exp_two isSidon2_hammingBall
    hammingBall_nonempty

end HammingBall

end FourierEnergyFamilies