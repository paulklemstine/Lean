/-
# Almost-lossless compression IV: Monte-Carlo codebooks and their derandomisation

Shannon's random-coding argument compresses by drawing a *random* codebook
`h : α → Fin m` and hoping that `h` is injective on the typical set `S`.  This
file proves, by exact counting, both halves of the story.

## Main results

* `AlmostLossless.two_mul_pow_le` — the descending-factorial inequality
  `2 mᵍ ≤ 2 · m^(q̲) + q(q-1) m^(q-1)` (the counting heart of the birthday bound),
  proved by induction.
* `AlmostLossless.card_badCodebooks_add` — exactly `m.descFactorial q` of the
  `m ^ q` codebooks are injective.
* `AlmostLossless.collision_prob_le` — **the Monte-Carlo failure bound**: a
  uniformly random codebook `Fin q → Fin m` fails (collides) with probability at
  most `q (q - 1) / (2 m)`.
* `AlmostLossless.exists_injective_codebook` — **derandomisation**: as soon as the
  bound is `< 1`, a *deterministic* injective codebook exists.
* `AlmostLossless.rng_no_rate_advantage` — any codebook, random or not, that is
  injective on the typical set forces `|S| ≤ m`, which is exactly the condition
  under which the *deterministic, linear-time* enumerative code of
  `Applications.AlmostLossless.Enumerative` already works.
* `AlmostLossless.monte_carlo_derandomised` — the conclusion of the thread: a
  successful random codebook can always be replaced by the enumerative code, with
  the same rate, the same failure probability, sound failure reporting, and
  decoding cost `k + 2` instead of `2 ^ k`.
-/
import Mathlib
import Applications.AlmostLossless.Complexity

namespace AlmostLossless

open Finset

/-! ## The counting heart of the birthday bound -/

/-- `2 mᵠ⁺¹ ≤ 2 · descFactorial m (q+1) + (q+1) q mᵠ`: the number of *colliding*
maps `Fin (q+1) → Fin m` is at most `binom(q+1,2) · mᵠ`. -/
theorem two_mul_pow_le (m : ℕ) : ∀ q : ℕ,
    2 * m ^ (q + 1) ≤ 2 * m.descFactorial (q + 1) + (q + 1) * q * m ^ q := by
  intro q
  induction q with
  | zero => simp [Nat.descFactorial]
  | succ q ih =>
      by_cases hm : m ≤ q + 1
      · -- the descending factorial may vanish; the linear term already suffices
        have h1 : 2 * m ≤ (q + 2) * (q + 1) := by nlinarith
        have h2 : 2 * m ^ (q + 2) = (2 * m) * m ^ (q + 1) := by ring
        calc 2 * m ^ (q + 2) = (2 * m) * m ^ (q + 1) := h2
          _ ≤ ((q + 2) * (q + 1)) * m ^ (q + 1) := Nat.mul_le_mul_right _ h1
          _ ≤ 2 * m.descFactorial (q + 2) + (q + 2) * (q + 1) * m ^ (q + 1) := by omega
      · push_neg at hm
        -- genuine descending-factorial recursion
        have hle : (q + 1 : ℕ) ≤ m := le_of_lt hm
        set P : ℤ := (m : ℤ) ^ q with hP
        set D : ℤ := (m.descFactorial (q + 1) : ℤ) with hDdef
        have e1 : (m : ℤ) ^ (q + 1) = (m : ℤ) * P := by rw [hP, pow_succ]; ring
        have e2 : (m : ℤ) ^ (q + 2) = (m : ℤ) * ((m : ℤ) * P) := by
          rw [hP, pow_succ, pow_succ]; ring
        have hsucc : (m.descFactorial (q + 2) : ℤ) = ((m : ℤ) - ((q : ℤ) + 1)) * D := by
          rw [hDdef, Nat.descFactorial_succ]
          push_cast [Nat.cast_sub hle]
          ring
        have hD : D ≤ (m : ℤ) * P := by
          have := Nat.descFactorial_le_pow m (q + 1)
          have h' : D ≤ (m : ℤ) ^ (q + 1) := by rw [hDdef]; exact_mod_cast this
          rwa [e1] at h'
        have hIH : 2 * ((m : ℤ) * P) ≤ 2 * D + ((q : ℤ) + 1) * (q : ℤ) * P := by
          have : (2 : ℤ) * (m : ℤ) ^ (q + 1)
              ≤ 2 * D + ((q : ℤ) + 1) * (q : ℤ) * (m : ℤ) ^ q := by
            rw [hDdef]; exact_mod_cast ih
          rwa [e1, ← hP] at this
        have hmnn : (0 : ℤ) ≤ (m : ℤ) := Int.natCast_nonneg m
        have hq1 : (0 : ℤ) ≤ (q : ℤ) + 1 := by positivity
        have h1 : 2 * ((m : ℤ) * ((m : ℤ) * P))
            ≤ 2 * ((m : ℤ) * D) + ((q : ℤ) + 1) * (q : ℤ) * ((m : ℤ) * P) := by nlinarith
        have h2 : 2 * ((q : ℤ) + 1) * D ≤ 2 * ((q : ℤ) + 1) * ((m : ℤ) * P) := by nlinarith
        have hstep : 2 * (m : ℤ) ^ (q + 2)
            ≤ 2 * (m.descFactorial (q + 2) : ℤ)
              + ((q : ℤ) + 2) * ((q : ℤ) + 1) * (m : ℤ) ^ (q + 1) := by
          rw [hsucc, e1, e2]
          nlinarith [h1, h2]
        exact_mod_cast hstep

/-! ## Counting codebooks -/

/-- The colliding codebooks: maps `Fin q → Fin m` that are *not* injective. -/
def badCodebooks (q m : ℕ) : Finset (Fin q → Fin m) :=
  univ.filter (fun h => ¬ Function.Injective h)

/-- Exactly `m.descFactorial q` of the `m ^ q` codebooks are collision-free. -/
theorem card_badCodebooks_add (q m : ℕ) :
    (badCodebooks q m).card + m.descFactorial q = m ^ q := by
  classical
  have hgood : (univ.filter (fun h : Fin q → Fin m => Function.Injective h)).card
      = m.descFactorial q := by
    have h1 : Fintype.card {h : Fin q → Fin m // Function.Injective h} = m.descFactorial q := by
      rw [Fintype.card_congr (Equiv.subtypeInjectiveEquivEmbedding _ _), Fintype.card_embedding_eq]
      simp
    rw [← h1, Fintype.card_subtype]
  have htot := Finset.card_filter_add_card_filter_not (s := (univ : Finset (Fin q → Fin m)))
    (fun h : Fin q → Fin m => Function.Injective h)
  rw [hgood] at htot
  have hcard : (univ : Finset (Fin q → Fin m)).card = m ^ q := by
    simp [Finset.card_univ]
  rw [hcard] at htot
  rw [badCodebooks]
  omega

/-- **Birthday bound, counting form.**  At most `q (q-1) m^(q-1) / 2` of the `m ^ q`
codebooks collide. -/
theorem card_badCodebooks_le (q m : ℕ) :
    2 * (badCodebooks q m).card ≤ q * (q - 1) * m ^ (q - 1) := by
  cases q with
  | zero =>
      have h : (badCodebooks 0 m).card = 0 := by
        have h0 := card_badCodebooks_add 0 m
        simpa using h0
      simp [h]
  | succ q =>
      have hsum := card_badCodebooks_add (q + 1) m
      have hineq := two_mul_pow_le m q
      simp only [Nat.add_sub_cancel]
      omega


/-- **The birthday bound is tight at `q = 2`.**  Exactly `m` of the `m ^ 2` codebooks
`Fin 2 → Fin m` collide, and `2 * m = 2 * (2 - 1) * m ^ (2 - 1)`: the counting bound
`card_badCodebooks_le` holds with equality, so it cannot be improved in general. -/
theorem card_badCodebooks_two (m : ℕ) : (badCodebooks 2 m).card = m := by
  have h := card_badCodebooks_add 2 m
  have hd : Nat.descFactorial m 2 = (m - 1) * m := by
    simp [Nat.descFactorial, Nat.mul_comm]
  rw [hd] at h
  cases m with
  | zero => simpa using h
  | succ n =>
      simp only [Nat.succ_sub_one] at h
      nlinarith [h, sq_nonneg n]

/-- Consequently the Monte-Carlo collision probability at `q = 2` is exactly `1 / m`,
matching `collision_prob_le`. -/
theorem collision_prob_two (m : ℕ) (hm : 0 < m) :
    ((badCodebooks 2 m).card : ℝ) / (m : ℝ) ^ 2 = 1 / m := by
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [card_badCodebooks_two]
  field_simp

/-! ## The Monte-Carlo failure probability -/

/-- **Monte-Carlo failure bound.**  A uniformly random codebook `Fin q → Fin m`
fails to be injective with probability at most `q (q-1) / (2 m)`. -/
theorem collision_prob_le (q m : ℕ) (hm : 0 < m) :
    ((badCodebooks q m).card : ℝ) / (m : ℝ) ^ q ≤ (q * (q - 1) : ℕ) / (2 * m) := by
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  cases q with
  | zero =>
      have h : (badCodebooks 0 m).card = 0 := by
        have h0 := card_badCodebooks_add 0 m
        simpa using h0
      simp [h]
  | succ q =>
      have hcount : 2 * ((badCodebooks (q + 1) m).card : ℝ)
          ≤ ((q + 1) * q : ℕ) * (m : ℝ) ^ q := by
        have := card_badCodebooks_le (q + 1) m
        simp only [Nat.add_sub_cancel] at this
        exact_mod_cast this
      have hpow : (m : ℝ) ^ (q + 1) = (m : ℝ) ^ q * m := by ring
      rw [div_le_div_iff₀ (by positivity) (by positivity), hpow]
      have hqq : (((q + 1) * ((q + 1) - 1) : ℕ) : ℝ) = ((q + 1) * q : ℕ) := by
        simp
      rw [hqq]
      nlinarith [hcount, pow_pos hmR q]

/-- **Derandomisation.**  If the birthday bound is nontrivial, a deterministic
collision-free codebook exists — no randomness is needed to obtain one. -/
theorem exists_injective_codebook (q m : ℕ) (h : q * (q - 1) < 2 * m) :
    ∃ f : Fin q → Fin m, Function.Injective f := by
  cases q with
  | zero => exact ⟨Fin.elim0, fun a _ _ => a.elim0⟩
  | succ q =>
      have hm : 0 < m := by omega
      have hbad := card_badCodebooks_le (q + 1) m
      simp only [Nat.add_sub_cancel] at hbad
      have hlt : (badCodebooks (q + 1) m).card < m ^ (q + 1) := by
        have hkey : (q + 1) * q * m ^ q < 2 * (m ^ q * m) := by
          have hq : (q + 1) * q < 2 * m := by simpa using h
          have hpos : 0 < m ^ q := Nat.pow_pos hm
          calc (q + 1) * q * m ^ q < (2 * m) * m ^ q := by
                exact Nat.mul_lt_mul_of_lt_of_le hq (le_refl _) hpos
            _ = 2 * (m ^ q * m) := by ring
        have hpowsucc : m ^ (q + 1) = m ^ q * m := by ring
        omega
      have hne : (badCodebooks (q + 1) m) ≠ univ := by
        intro hcon
        rw [hcon, Finset.card_univ, Fintype.card_fun] at hlt
        simp at hlt
      obtain ⟨f, hf⟩ : ∃ f : Fin (q + 1) → Fin m, f ∉ badCodebooks (q + 1) m := by
        by_contra hcon
        push_neg at hcon
        exact hne (Finset.eq_univ_of_forall hcon)
      refine ⟨f, ?_⟩
      by_contra hni
      exact hf (by simp [badCodebooks, hni])

/-! ## Randomness buys no rate -/

variable {α : Type*} [Fintype α] [DecidableEq α]

omit [Fintype α] [DecidableEq α] in
/-- **A random codebook cannot beat counting.**  Whatever the codebook `f` (drawn
at random or designed), if it is injective on the typical set `S` then
`|S| ≤ m`: the rate is governed by `|S|`, exactly as for the deterministic
enumerative code. -/
theorem rng_no_rate_advantage {S : Finset α} {m : ℕ} {f : α → Fin m} (hf : Set.InjOn f S) :
    S.card ≤ m := by
  have : S.card ≤ (univ : Finset (Fin m)).card :=
    Finset.card_le_card_of_injOn f (fun a _ => by simp) hf
  simpa using this

/-- **The conclusion of Phase B, Question 2.**  Suppose a Monte-Carlo scheme
succeeds: a codebook `f : α → Fin (2 ^ k)` is injective on a typical set `S` of
mass `≥ 1 - ε`.  Then the *deterministic* enumerative code achieves

* the same rate (`k + 1` bits, one of which is the failure flag),
* failure probability `≤ ε`,
* sound, explicitly reported failures (never silent), and
* decoding cost `k + 2` steps on every typical source

— whereas decoding the random codebook by exhaustive search costs up to `2 ^ k`
probes (`Complexity.scanI_cost_exponential`).  Random number generators therefore
buy nothing in rate and cost an exponential factor in decoding time. -/
theorem monte_carlo_derandomised {p : α → ℝ} (hsum : ∑ x, p x = 1) {S : Finset α} {k : ℕ}
    {ε : ℝ} (hmass : 1 - ε ≤ ∑ x ∈ S, p x) {f : α → Fin (2 ^ k)} (hf : Set.InjOn f S) :
    Sound (enumCode S k) ∧ LengthBound (enumCode S k) (k + 1) ∧
      failProb p (enumCode S k) ≤ ε ∧
      (∀ x ∉ S, (enumCode S k).dec ((enumCode S k).enc x) = none) ∧
      (∀ x ∈ S, (enumDecI S ((enumCode S k).enc x)).2 = k + 2) := by
  have hcard : S.card ≤ 2 ^ k := rng_no_rate_advantage hf
  refine ⟨enumCode_sound S k hcard, enumCode_lengthBound S k, ?_,
    fun x hx => enumCode_detects_failure hx, fun x hx => enumDecI_cost_enc hcard hx⟩
  have hmg : ∑ x ∈ goodSet (enumCode S k), p x = 1 - failProb p (enumCode S k) :=
    mass_goodSet hsum _
  rw [goodSet_enumCode S k hcard] at hmg
  linarith

end AlmostLossless