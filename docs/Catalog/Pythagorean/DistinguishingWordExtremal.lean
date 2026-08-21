import Pythagorean.DistinguishingWordSharpness

/-!
# The Moore bound is attained for *every* pair of state-set sizes

`DistinguishingWordSharpness.lean` exhibits one family (a saturating counter against a
one-state machine) attaining the bounds.  Here we show that the linear bound
`|S| + |T| - 2` of `exists_distinguishing_word_moore` is attained for **every** pair of
sizes `(n, m)`, and already over the *unary* alphabet `Unit`.

## The construction

Write `n = n' + 1`, `m = m' + 1` and put `r = (n' + m') % m`.

* `tailMachine` — a saturating chain on `Fin n`: the `ℓ`-th observation is the value at
  state `min ℓ n'`, and the top state observes `false`.  Below the top the outputs are
  chosen to copy the cyclic machine.
* `cycleMachine` — a cycle on `Fin m` whose `ℓ`-th observation is `ℓ % m = r`.

The two agree on every word of length `< n' + m'` and differ at length exactly
`n' + m' = |S| + |T| - 2`: the `m` consecutive indices `n', …, n' + m'` hit the residue
`r` exactly once, at the very last one.  This is the automata-theoretic shadow of the
Fine–Wilf periodicity phenomenon: a preperiod-`n'` sequence and a period-`m` sequence can
agree for `n' + m' ` steps and no longer.

## Main result

* `moore_bound_attained` — for all `n' m'`, the two machines above have
  `|S| = n' + 1`, `|T| = m' + 1`, are inequivalent, every distinguishing word has length
  at least `|S| + |T| - 2`, and some word of exactly that length distinguishes them.
-/

namespace Pythagorean.DistinguishingWord

namespace Machine

namespace Extremal

variable (n' m' : ℕ)

/-- The residue at which the cyclic machine fires. -/
def resid : ℕ := (n' + m') % (m' + 1)

/-- A saturating chain of `n' + 1` states whose observations copy the cyclic machine
below the top state and are `false` at the top. -/
def tailMachine : Machine Unit Bool (Fin (n' + 1)) where
  step i _ := ⟨min ((i : ℕ) + 1) n', by omega⟩
  out i := decide ((i : ℕ) < n' ∧ (i : ℕ) % (m' + 1) = resid n' m')

/-- A cycle of `m' + 1` states observing `true` exactly at the residue `resid n' m'`. -/
def cycleMachine : Machine Unit Bool (Fin (m' + 1)) where
  step j _ := ⟨((j : ℕ) + 1) % (m' + 1), Nat.mod_lt _ (Nat.succ_pos m')⟩
  out j := decide ((j : ℕ) = resid n' m')

theorem tailMachine_run :
    ∀ (w : List Unit) (i : Fin (n' + 1)),
      (((tailMachine n' m').run i w : Fin (n' + 1)) : ℕ) = min ((i : ℕ) + w.length) n' := by
  intro w
  induction w with
  | nil => intro i; have := i.is_le; simp; omega
  | cons a v ih =>
      intro i
      rw [run_cons, ih]
      have hstep : (((tailMachine n' m').step i a : Fin (n' + 1)) : ℕ) = min ((i : ℕ) + 1) n' :=
        rfl
      rw [hstep]
      simp only [List.length_cons]
      omega

theorem cycleMachine_run :
    ∀ (w : List Unit) (j : Fin (m' + 1)),
      (((cycleMachine n' m').run j w : Fin (m' + 1)) : ℕ) = ((j : ℕ) + w.length) % (m' + 1) := by
  intro w
  induction w with
  | nil => intro j; simpa using (Nat.mod_eq_of_lt j.isLt).symm
  | cons a v ih =>
      intro j
      rw [run_cons, ih]
      have hstep :
          (((cycleMachine n' m').step j a : Fin (m' + 1)) : ℕ) = ((j : ℕ) + 1) % (m' + 1) := rfl
      rw [hstep, List.length_cons]
      conv_rhs => rw [show (j : ℕ) + (v.length + 1) = ((j : ℕ) + 1) + v.length by omega]
      rw [Nat.add_mod, Nat.mod_mod_of_dvd, ← Nat.add_mod]
      exact dvd_rfl

/-- The observation of the chain after `ℓ` inputs. -/
theorem tailMachine_obs (w : List Unit) :
    (tailMachine n' m').obs ⟨0, Nat.succ_pos n'⟩ w =
      decide (min w.length n' < n' ∧ (min w.length n') % (m' + 1) = resid n' m') := by
  have h := tailMachine_run n' m' w ⟨0, Nat.succ_pos n'⟩
  simp only [Nat.zero_add] at h
  show decide ((((tailMachine n' m').run ⟨0, Nat.succ_pos n'⟩ w : Fin (n' + 1)) : ℕ) < n' ∧
      ((((tailMachine n' m').run ⟨0, Nat.succ_pos n'⟩ w : Fin (n' + 1)) : ℕ)) % (m' + 1)
        = resid n' m') = _
  rw [h]

/-- The observation of the cycle after `ℓ` inputs. -/
theorem cycleMachine_obs (w : List Unit) :
    (cycleMachine n' m').obs ⟨0, Nat.succ_pos m'⟩ w =
      decide (w.length % (m' + 1) = resid n' m') := by
  have h := cycleMachine_run n' m' w ⟨0, Nat.succ_pos m'⟩
  simp only [Nat.zero_add] at h
  show decide ((((cycleMachine n' m').run ⟨0, Nat.succ_pos m'⟩ w : Fin (m' + 1)) : ℕ)
      = resid n' m') = _
  rw [h]

/-- Key arithmetic step: in the window of `m'` indices just below `n' + m'`, no index is
congruent to `resid n' m'` modulo `m' + 1`. -/
theorem not_resid_of_window {l : ℕ} (h1 : n' ≤ l) (h2 : l < n' + m') :
    l % (m' + 1) ≠ resid n' m' := by
  intro hcon
  have hmod : (n' + m') % (m' + 1) = l % (m' + 1) := hcon.symm
  have hdvd : (m' + 1) ∣ (n' + m' - l) := by
    have : l ≡ n' + m' [MOD m' + 1] := hcon.trans rfl
    exact (Nat.modEq_iff_dvd' (by omega)).mp this
  have hle : m' + 1 ≤ n' + m' - l := Nat.le_of_dvd (by omega) hdvd
  omega

/-- The two machines agree on every word shorter than `n' + m'`. -/
theorem obs_agree_of_lt (w : List Unit) (hw : w.length < n' + m') :
    (tailMachine n' m').obs ⟨0, Nat.succ_pos n'⟩ w =
      (cycleMachine n' m').obs ⟨0, Nat.succ_pos m'⟩ w := by
  rw [tailMachine_obs, cycleMachine_obs]
  rcases Nat.lt_or_ge w.length n' with hlt | hge
  · rw [Nat.min_eq_left (le_of_lt hlt)]
    simp [hlt]
  · rw [Nat.min_eq_right hge]
    have hne2 : w.length % (m' + 1) ≠ resid n' m' := not_resid_of_window n' m' hge hw
    simp [hne2]

/-- They differ on the word of length exactly `n' + m'`. -/
theorem obs_differ_at (w : List Unit) (hw : w.length = n' + m') :
    (tailMachine n' m').obs ⟨0, Nat.succ_pos n'⟩ w ≠
      (cycleMachine n' m').obs ⟨0, Nat.succ_pos m'⟩ w := by
  rw [tailMachine_obs, cycleMachine_obs, hw]
  rw [Nat.min_eq_right (by omega)]
  simp [resid]

/-- **The Moore bound is attained for every pair of sizes, over a unary alphabet.**
The machines `tailMachine` and `cycleMachine` have `n' + 1` and `m' + 1` states, are
behaviourally inequivalent, cannot be separated by any word shorter than
`|S| + |T| - 2`, and *are* separated by a word of exactly that length. -/
theorem moore_bound_attained (n' m' : ℕ) :
    ¬ Equivalent (tailMachine n' m') (cycleMachine n' m')
        ⟨0, Nat.succ_pos n'⟩ ⟨0, Nat.succ_pos m'⟩ ∧
      (∀ w : List Unit,
        (tailMachine n' m').obs ⟨0, Nat.succ_pos n'⟩ w ≠
          (cycleMachine n' m').obs ⟨0, Nat.succ_pos m'⟩ w →
          Fintype.card (Fin (n' + 1)) + Fintype.card (Fin (m' + 1)) - 2 ≤ w.length) ∧
      (∃ w : List Unit,
        w.length = Fintype.card (Fin (n' + 1)) + Fintype.card (Fin (m' + 1)) - 2 ∧
        (tailMachine n' m').obs ⟨0, Nat.succ_pos n'⟩ w ≠
          (cycleMachine n' m').obs ⟨0, Nat.succ_pos m'⟩ w) := by
  have hcard : Fintype.card (Fin (n' + 1)) + Fintype.card (Fin (m' + 1)) - 2 = n' + m' := by
    simp; omega
  refine ⟨?_, ?_, ?_⟩
  · intro hEq
    exact obs_differ_at n' m' (List.replicate (n' + m') ()) (by simp) (hEq _)
  · intro w hw
    rw [hcard]
    by_contra hlt
    push_neg at hlt
    exact hw (obs_agree_of_lt n' m' w hlt)
  · exact ⟨List.replicate (n' + m') (), by rw [List.length_replicate, hcard], obs_differ_at n' m' _ (by simp)⟩

end Extremal

end Machine

end Pythagorean.DistinguishingWord