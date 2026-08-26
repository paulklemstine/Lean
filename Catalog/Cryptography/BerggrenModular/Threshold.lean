import Cryptography.BerggrenModular.Hardness

/-!
# The modulus threshold: where seed recovery flips from easy to impossible

`Cryptography.BerggrenModular.Hardness` shows that modular seed recovery is
impossible once `m³ < 3^k`.  This file proves the **positive companion**: if the
modulus is large enough that no state of a length-`k` trajectory can wrap around,
then a modular observer recovers the control word exactly, by the same
`whichMove` peeling used over `ℤ`.

The growth bound is `c ↦ ≤ 7c` per move, so a length-`k` trajectory from the root
`(3,4,5)` stays below `5·7^k`.  Hence

* `modSeedRecoverable_of_large_modulus` : `5·7^k < m` ⟹ recovery is possible;
* `not_modSeedRecoverable_of_card`      : `m³ < 3^k` ⟹ recovery is impossible.

Writing `m = 7^{αk}` the transition therefore sits somewhere in
`α ∈ [log 3 / (3 log 7), 1]`, and pinning it down is left as an explicit open
problem in `FUTURE_DIRECTIONS.md`.

## Main results

* `hyp_applyWord_le` — the `7^k` growth bound along any control word.
* `liftTri_stateMod` — below the threshold the modular observation determines the
  integer state.
* `recoverModFrom_correct`, `modSeedRecoverable_of_large_modulus`.
* `berggren_threshold_sandwich` — the two-sided statement.
-/

namespace Cryptography
namespace BerggrenModular

/-! ## Growth of the hypotenuse -/

/-- One move multiplies the hypotenuse by at most `7`. -/
theorem hyp_applyMove_le {i : Move} {v : Tri} (h : Valid v) :
    (applyMove i v).2.2 ≤ 7 * v.2.2 := by
  have h1 := valid_leg_lt_hyp₁ h
  have h2 := valid_leg_lt_hyp₂ h
  obtain ⟨ha, hb, hc, hp⟩ := h
  cases i <;> simp only [applyMove] <;> linarith

/-- A control word of length `ℓ` cannot push the hypotenuse past `5·7^ℓ`. -/
theorem hyp_applyWord_le (u : List Move) : (applyWord u root).2.2 ≤ 5 * 7 ^ u.length := by
  induction u with
  | nil => simp [root]
  | cons i rest ih =>
      have hv : Valid (applyWord rest root) := applyWord_valid rest root_valid
      have := hyp_applyMove_le (i := i) hv
      have h7 : (0 : ℤ) < 7 := by norm_num
      calc (applyWord (i :: rest) root).2.2 = (applyMove i (applyWord rest root)).2.2 := rfl
        _ ≤ 7 * (applyWord rest root).2.2 := this
        _ ≤ 7 * (5 * 7 ^ rest.length) := by linarith
        _ = 5 * 7 ^ (i :: rest).length := by simp [List.length_cons, pow_succ]; ring

/-- Uniform bound for all words of length at most `k`. -/
theorem hyp_applyWord_le_of_length_le {u : List Move} {k : ℕ} (hu : u.length ≤ k) :
    (applyWord u root).2.2 ≤ 5 * 7 ^ k := by
  refine (hyp_applyWord_le u).trans ?_
  have : (7 : ℤ) ^ u.length ≤ 7 ^ k := pow_le_pow_right₀ (by norm_num) hu
  linarith

/-! ## Below the threshold the residue determines the state -/

/-- If the modulus exceeds `5·7^k`, the canonical lift of the observed residue is
the true integer state. -/
theorem liftTri_stateMod {m k : ℕ} [NeZero m] (hm : 5 * 7 ^ k < m) {u : List Move}
    (hu : u.length ≤ k) : liftTri m (stateMod m u) = applyWord u root := by
  have hv : Valid (applyWord u root) := applyWord_valid u root_valid
  have hbound : (applyWord u root).2.2 ≤ 5 * 7 ^ k := hyp_applyWord_le_of_length_le hu
  have hmZ : (5 : ℤ) * 7 ^ k < (m : ℤ) := by exact_mod_cast hm
  have h3 : (applyWord u root).2.2 < (m : ℤ) := lt_of_le_of_lt hbound hmZ
  have h1 : (applyWord u root).1 < (m : ℤ) := lt_of_lt_of_le (valid_leg_lt_hyp₁ hv) (le_of_lt h3)
  have h2 : (applyWord u root).2.1 < (m : ℤ) := lt_of_lt_of_le (valid_leg_lt_hyp₂ hv) (le_of_lt h3)
  exact liftTri_redTri (le_of_lt hv.1) (le_of_lt hv.2.1) (le_of_lt hv.2.2.1) h1 h2 h3

/-- Below the threshold, distinct control words are distinguishable: the observed
residue of a nonempty word differs from the residue of the root. -/
theorem stateMod_ne_root {m k : ℕ} [NeZero m] (hm : 5 * 7 ^ k < m) {u : List Move}
    (hu : u.length ≤ k) (hne : u ≠ []) : stateMod m u ≠ redTri m root := by
  intro hEq
  have h1 : liftTri m (stateMod m u) = applyWord u root := liftTri_stateMod hm hu
  have h2 : liftTri m (stateMod m ([] : List Move)) = root := by
    simpa using liftTri_stateMod (m := m) (k := k) hm (u := ([] : List Move)) (by simp)
  have h3 : stateMod m ([] : List Move) = redTri m root := by simp [stateMod]
  rw [h3] at h2
  exact applyWord_ne_root hne (by rw [← h1, hEq, h2])

/-! ## Self-terminating modular recovery -/

/-- Modular seed recovery with a root test: peel moves off the observed residue
until the residue of the root is reached. -/
def recoverModFrom (m : ℕ) [NeZero m] : ℕ → TriM m → List Move
  | 0, _ => []
  | n + 1, w =>
      if w = redTri m root then []
      else whichMoveMod m w :: recoverModFrom m n (invMoveM m (whichMoveMod m w) w)

theorem recoverModFrom_correct {m k : ℕ} [NeZero m] (hm : 5 * 7 ^ k < m) :
    ∀ (n : ℕ) (u : List Move), u.length ≤ n → n ≤ k → recoverModFrom m n (stateMod m u) = u := by
  intro n
  induction n with
  | zero =>
      intro u hu _
      simp only [Nat.le_zero, List.length_eq_zero_iff] at hu
      subst hu; rfl
  | succ n ih =>
      intro u hu hnk
      match u with
      | [] => simp [recoverModFrom, stateMod]
      | i :: rest =>
          have hlen : rest.length ≤ n := by
            simpa [List.length_cons, Nat.succ_le_succ_iff] using hu
          have hrestk : rest.length ≤ k := hlen.trans (by omega)
          have hconsk : (i :: rest).length ≤ k := by
            simpa [List.length_cons] using Nat.succ_le_of_lt (lt_of_lt_of_le (by omega) hnk)
          have hne : stateMod m (i :: rest) ≠ redTri m root :=
            stateMod_ne_root hm hconsk (List.cons_ne_nil i rest)
          have hval : Valid (applyWord rest root) := applyWord_valid rest root_valid
          have hbound : (applyMove i (applyWord rest root)).2.2 < (m : ℤ) := by
            have hb := hyp_applyWord_le_of_length_le (u := i :: rest) hconsk
            have hmZ : (5 : ℤ) * 7 ^ k < (m : ℤ) := by exact_mod_cast hm
            have : (applyWord (i :: rest) root).2.2 = (applyMove i (applyWord rest root)).2.2 :=
              rfl
            linarith [this ▸ hb]
          have hclass : whichMoveMod m (stateMod m (i :: rest)) = i := by
            show whichMoveMod m (redTri m (applyWord (i :: rest) root)) = i
            rw [applyWord_cons]
            exact whichMoveMod_redTri i hval hbound
          have hinv : invMoveM m i (stateMod m (i :: rest)) = stateMod m rest := by
            show invMoveM m i (redTri m (applyWord (i :: rest) root))
              = redTri m (applyWord rest root)
            rw [applyWord_cons, redTri_applyMove, invMoveM_applyMoveM]
          rw [recoverModFrom, if_neg hne, hclass, hinv, ih rest hlen (by omega)]

/-- **Modular seed recovery is possible above the wrap-around threshold.** -/
theorem modSeedRecoverable_of_large_modulus (m k : ℕ) [NeZero m] (hm : 5 * 7 ^ k < m) :
    ModSeedRecoverable m k :=
  ⟨recoverModFrom m k, fun u hu => recoverModFrom_correct hm k u hu le_rfl⟩

/-! ## The sandwich -/

/-- **Two-sided threshold theorem.**  Recovery of a length-`k` Berggren control
word from a single state in `(ℤ/m)³` is

* possible when `5·7^k < m`, and
* impossible when `m³ < 3^k`.

So the phase transition in `m` lies between `3^{k/3}` and `5·7^k`; no modulus can
satisfy both conditions. -/
theorem berggren_threshold_sandwich (m k : ℕ) [NeZero m] :
    (5 * 7 ^ k < m → ModSeedRecoverable m k) ∧ (m ^ 3 < 3 ^ k → ¬ ModSeedRecoverable m k) :=
  ⟨modSeedRecoverable_of_large_modulus m k, not_modSeedRecoverable_of_card m k⟩

/-- The two regimes are genuinely disjoint: no modulus is simultaneously large
enough for recovery and small enough for the counting obstruction. -/
theorem threshold_regimes_disjoint (m k : ℕ) [NeZero m] (h1 : 5 * 7 ^ k < m) :
    ¬ (m ^ 3 < 3 ^ k) := by
  intro h2
  have hle : 3 ^ k ≤ 7 ^ k := Nat.pow_le_pow_left (by norm_num) k
  have h5 : 5 * 7 ^ k < m := h1
  have : m ^ 3 ≥ m := Nat.le_self_pow (by norm_num) m
  omega

end BerggrenModular
end Cryptography