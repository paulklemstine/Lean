import Cryptography.BerggrenModular.Threshold

/-!
# The silver-ratio spectrum of `B₂` and the Pell reduction of its discrete logarithm

The Berggren matrix `B₂ = !![1,2,2; 2,1,2; 2,2,3]` has characteristic polynomial

```
λ³ − 5λ² − 5λ + 1 = (λ + 1)(λ² − 6λ + 1),
```

whose non-trivial roots `3 ± 2√2 = (1 ± √2)²` are the squares of the silver ratio.
This is the structural reason why the `B₂`-orbit of the root `(3,4,5)` is a Pell
sequence, and hence why the "discrete logarithm for `B₂` mod `m`" appearing in
`Cryptography.BerggrenModular.Hardness` is really an *index-finding problem for
the Pell/NSW sequences modulo `m`*.

Concretely, writing `orbit2 t` for the state after `t` applications of `B₂`,
`pellS t = a_t + b_t` and `pellC t = c_t`, we prove

* `pellS_succ`, `pellC_succ` — the pair `(pellS, pellC)` evolves by `!![3,4;2,3]`;
* `pellS_recurrence`, `pellC_recurrence` — both satisfy `x_{t+2} = 6x_{t+1} − x_t`;
* `pell_conic` — `pellS t ² − 2·pellC t ² = −1`: the orbit is exactly the ladder of
  solutions of the **negative Pell equation**;
* `leg_difference` — the two legs differ by `(−1)^{t+1}`, the eigenvalue `−1` of `B₂`;
* `cayley_hamilton_B2`, `silver_factorization_B2` — the spectral identities;
* `stateMod_replicate_eq_iff_pell` — for odd `m` and exponents of equal parity, two
  `B₂`-powers are indistinguishable modulo `m` **iff** their Pell data coincide
  modulo `m`.  This is the promised equivalence between the `B₂` discrete
  logarithm and Pell index-finding.
-/

namespace Cryptography
namespace BerggrenModular

/-! ## Spectral identities for `B₂` -/

/-- **Cayley–Hamilton for `B₂`**: `B₂³ = 5B₂² + 5B₂ − I`. -/
theorem cayley_hamilton_B2 :
    bergMatrix Move.m2 ^ 3
      = (5 : ℤ) • bergMatrix Move.m2 ^ 2 + (5 : ℤ) • bergMatrix Move.m2 - 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [bergMatrix, pow_succ, Matrix.mul_apply, Fin.sum_univ_three]

/-- **The silver factorisation**: `(B₂ + I)(B₂² − 6B₂ + I) = 0`.  The quadratic factor
has roots `3 ± 2√2 = (1 ± √2)²`. -/
theorem silver_factorization_B2 :
    (bergMatrix Move.m2 + 1) *
      (bergMatrix Move.m2 ^ 2 - (6 : ℤ) • bergMatrix Move.m2 + 1) = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [bergMatrix, pow_succ, Matrix.mul_apply, Matrix.add_apply,
      Fin.sum_univ_three, Matrix.one_apply]

/-- The same identities hold after reduction modulo `m`. -/
theorem silver_factorization_B2_mod (m : ℕ) :
    (bergMatrixM m Move.m2 + 1) *
      (bergMatrixM m Move.m2 ^ 2 - (6 : ℤ) • bergMatrixM m Move.m2 + 1) = 0 := by
  have h := congrArg (Int.castRingHom (ZMod m)).mapMatrix silver_factorization_B2
  simp only [map_mul, map_add, map_sub, map_pow, map_one, map_zero, map_zsmul,
    RingHom.mapMatrix_apply] at h
  exact h

/-! ## The `B₂`-orbit of the root -/

/-- The state after `t` applications of the move `B₂` to `(3,4,5)`. -/
def orbit2 (t : ℕ) : Tri := applyWord (List.replicate t Move.m2) root

@[simp] theorem orbit2_zero : orbit2 0 = root := rfl

theorem orbit2_succ (t : ℕ) : orbit2 (t + 1) = applyMove Move.m2 (orbit2 t) := by
  rw [orbit2, List.replicate_succ, applyWord_cons, orbit2]

theorem orbit2_valid (t : ℕ) : Valid (orbit2 t) := applyWord_valid _ root_valid

/-- The Pell coordinate `a_t + b_t`. -/
def pellS (t : ℕ) : ℤ := (orbit2 t).1 + (orbit2 t).2.1

/-- The Pell coordinate `c_t` (the hypotenuse). -/
def pellC (t : ℕ) : ℤ := (orbit2 t).2.2

@[simp] theorem pellS_zero : pellS 0 = 7 := rfl
@[simp] theorem pellC_zero : pellC 0 = 5 := rfl

theorem pellS_succ (t : ℕ) : pellS (t + 1) = 3 * pellS t + 4 * pellC t := by
  simp only [pellS, pellC, orbit2_succ, applyMove]; ring

theorem pellC_succ (t : ℕ) : pellC (t + 1) = 2 * pellS t + 3 * pellC t := by
  simp only [pellS, pellC, orbit2_succ, applyMove]; ring

@[simp] theorem pellS_one : pellS 1 = 41 := by simp [pellS_succ]
@[simp] theorem pellC_one : pellC 1 = 29 := by simp [pellC_succ]

/-- **Pell recurrence for the leg sum.** -/
theorem pellS_recurrence (t : ℕ) : pellS (t + 2) = 6 * pellS (t + 1) - pellS t := by
  rw [pellS_succ (t + 1), pellS_succ t, pellC_succ t]; ring

/-- **Pell recurrence for the hypotenuse.** -/
theorem pellC_recurrence (t : ℕ) : pellC (t + 2) = 6 * pellC (t + 1) - pellC t := by
  rw [pellC_succ (t + 1), pellS_succ t, pellC_succ t]; ring

/-- **The `B₂`-orbit lies on the negative Pell conic** `x² − 2y² = −1`. -/
theorem pell_conic (t : ℕ) : pellS t ^ 2 - 2 * pellC t ^ 2 = -1 := by
  induction t with
  | zero => norm_num
  | succ n ih =>
      rw [pellS_succ, pellC_succ]
      linear_combination ih

/-- The eigenvalue `−1` of `B₂` in action: the two legs of the orbit always differ
by exactly one, with alternating sign. -/
theorem leg_difference (t : ℕ) : (orbit2 t).1 - (orbit2 t).2.1 = (-1) ^ (t + 1) := by
  induction t with
  | zero => norm_num [root]
  | succ n ih =>
      rw [orbit2_succ]
      simp only [applyMove]
      rw [show (-1 : ℤ) ^ (n + 1 + 1) = -((-1 : ℤ) ^ (n + 1)) by ring, ← ih]
      ring

theorem two_mul_fst (t : ℕ) : 2 * (orbit2 t).1 = pellS t + (-1) ^ (t + 1) := by
  rw [← leg_difference t]; simp only [pellS]; ring

theorem two_mul_snd (t : ℕ) : 2 * (orbit2 t).2.1 = pellS t - (-1) ^ (t + 1) := by
  rw [← leg_difference t]; simp only [pellS]; ring

/-- The `B₂`-power states of `Hardness` are exactly the orbit points. -/
theorem stateMod_replicate_eq (m t : ℕ) :
    stateMod m (List.replicate t Move.m2) = redTri m (orbit2 t) := rfl

/-! ## The Pell reduction of the `B₂` discrete logarithm -/

theorem neg_one_pow_congr {t₁ t₂ : ℕ} (h : t₁ % 2 = t₂ % 2) :
    ((-1 : ℤ)) ^ (t₁ + 1) = ((-1 : ℤ)) ^ (t₂ + 1) := by
  rcases Nat.even_or_odd t₁ with he | ho
  · have h2 : Even t₂ := by
      rw [Nat.even_iff] at he ⊢; omega
    rw [(Even.add_one he).neg_one_pow, (Even.add_one h2).neg_one_pow]
  · have h2 : Odd t₂ := by
      rw [Nat.odd_iff] at ho ⊢; omega
    rw [(Odd.add_one ho).neg_one_pow, (Odd.add_one h2).neg_one_pow]

theorem isUnit_two_of_odd {m : ℕ} [NeZero m] (hm : Odd m) : IsUnit (2 : ZMod m) := by
  have hco : Nat.Coprime 2 m := Nat.coprime_two_left.mpr hm
  have := (ZMod.isUnit_iff_coprime 2 m).2 hco
  simpa using this

/-- **From Pell data to the state.**  For odd `m` and exponents of equal parity, if the
Pell pair agrees modulo `m` then the observed `B₂`-power states agree. -/
theorem stateMod_replicate_eq_of_pell {m : ℕ} [NeZero m] (hm : Odd m) {t₁ t₂ : ℕ}
    (hpar : t₁ % 2 = t₂ % 2)
    (hs : ((pellS t₁ : ℤ) : ZMod m) = ((pellS t₂ : ℤ) : ZMod m))
    (hc : ((pellC t₁ : ℤ) : ZMod m) = ((pellC t₂ : ℤ) : ZMod m)) :
    stateMod m (List.replicate t₁ Move.m2) = stateMod m (List.replicate t₂ Move.m2) := by
  have hu := isUnit_two_of_odd (m := m) hm
  have hsign : ((((-1 : ℤ)) ^ (t₁ + 1) : ℤ) : ZMod m) = ((((-1 : ℤ)) ^ (t₂ + 1) : ℤ) : ZMod m) := by
    rw [neg_one_pow_congr hpar]
  have h1 : ((orbit2 t₁).1 : ZMod m) = ((orbit2 t₂).1 : ZMod m) := by
    refine hu.mul_left_cancel ?_
    have e1 : (2 : ZMod m) * ((orbit2 t₁).1 : ZMod m) = ((2 * (orbit2 t₁).1 : ℤ) : ZMod m) := by
      push_cast; ring
    have e2 : (2 : ZMod m) * ((orbit2 t₂).1 : ZMod m) = ((2 * (orbit2 t₂).1 : ℤ) : ZMod m) := by
      push_cast; ring
    rw [e1, e2, two_mul_fst, two_mul_fst]
    push_cast at hs hsign ⊢
    rw [hs, hsign]
  have h2 : ((orbit2 t₁).2.1 : ZMod m) = ((orbit2 t₂).2.1 : ZMod m) := by
    refine hu.mul_left_cancel ?_
    have e1 : (2 : ZMod m) * ((orbit2 t₁).2.1 : ZMod m) = ((2 * (orbit2 t₁).2.1 : ℤ) : ZMod m) := by
      push_cast; ring
    have e2 : (2 : ZMod m) * ((orbit2 t₂).2.1 : ZMod m) = ((2 * (orbit2 t₂).2.1 : ℤ) : ZMod m) := by
      push_cast; ring
    rw [e1, e2, two_mul_snd, two_mul_snd]
    push_cast at hs hsign ⊢
    rw [hs, hsign]
  have h3 : ((orbit2 t₁).2.2 : ZMod m) = ((orbit2 t₂).2.2 : ZMod m) := hc
  rw [stateMod_replicate_eq, stateMod_replicate_eq, redTri, redTri]
  exact Prod.ext h1 (Prod.ext h2 h3)

/-- **From the state to the Pell data.**  Conversely the Pell pair is a function of
the observed state, with no hypothesis on `m`. -/
theorem pell_of_stateMod_replicate_eq {m t₁ t₂ : ℕ}
    (h : stateMod m (List.replicate t₁ Move.m2) = stateMod m (List.replicate t₂ Move.m2)) :
    ((pellS t₁ : ℤ) : ZMod m) = ((pellS t₂ : ℤ) : ZMod m) ∧
    ((pellC t₁ : ℤ) : ZMod m) = ((pellC t₂ : ℤ) : ZMod m) := by
  rw [stateMod_replicate_eq, stateMod_replicate_eq, redTri, redTri, Prod.mk.injEq,
    Prod.mk.injEq] at h
  obtain ⟨h1, h2, h3⟩ := h
  refine ⟨?_, h3⟩
  simp only [pellS]
  push_cast
  rw [h1, h2]

/-- **The `B₂` discrete logarithm modulo an odd `m` is exactly Pell index-finding.**
Two exponents of the same parity are indistinguishable in `(ℤ/m)³` if and only if
the corresponding Pell pairs agree modulo `m`. -/
theorem stateMod_replicate_eq_iff_pell {m : ℕ} [NeZero m] (hm : Odd m) {t₁ t₂ : ℕ}
    (hpar : t₁ % 2 = t₂ % 2) :
    stateMod m (List.replicate t₁ Move.m2) = stateMod m (List.replicate t₂ Move.m2) ↔
      (((pellS t₁ : ℤ) : ZMod m) = ((pellS t₂ : ℤ) : ZMod m) ∧
        ((pellC t₁ : ℤ) : ZMod m) = ((pellC t₂ : ℤ) : ZMod m)) :=
  ⟨pell_of_stateMod_replicate_eq, fun h => stateMod_replicate_eq_of_pell hm hpar h.1 h.2⟩

/-! ## Consequences for the search space -/

/-- The hypotenuse of the `B₂`-orbit grows like the silver ratio squared: `c_{t+1} > 5 c_t`.
Together with `hyp_applyWord_le` this pins the growth rate of the `B₂` spine between
`5` and `7` per step. -/
theorem pellC_growth (t : ℕ) : 5 * pellC t < pellC (t + 1) := by
  have hv := orbit2_valid t
  have h1 := valid_leg_lt_hyp₁ hv
  have h2 := valid_leg_lt_hyp₂ hv
  have h3 := valid_hyp_lt_sum hv
  rw [pellC_succ]
  simp only [pellS, pellC]
  linarith

/-- Hence the `B₂` spine leaves any fixed window `[0, m)` after `O(log m)` steps:
`pellC t ≥ 5^{t+1}`. -/
theorem pellC_lower_bound (t : ℕ) : (5 : ℤ) ^ (t + 1) ≤ pellC t := by
  induction t with
  | zero => norm_num
  | succ n ih =>
      have hgrow := pellC_growth n
      have hpow : (5 : ℤ) ^ (n + 1 + 1) = 5 * 5 ^ (n + 1) := by ring
      linarith

end BerggrenModular
end Cryptography