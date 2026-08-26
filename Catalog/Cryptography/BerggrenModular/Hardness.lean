import Cryptography.BerggrenModular.Modular

/-!
# Seed recovery: easy over `ℤ`, information-theoretically hard over `ℤ/m`

Fix the Berggren root `(3,4,5)` and a *control word* `u ∈ {B₁,B₂,B₃}^k`.  The
*seed-recovery problem* asks: from the single observed state `applyWord u root`,
reconstruct `u`.

* Over `ℤ` this is **easy**: `recoverFrom` solves it with `k` comparisons and `k`
  linear maps (`intSeedRecoverable`).  This is a corollary of the exactness of the
  classifier `whichMove` together with the freeness of the Berggren monoid.

* Over `ℤ/m` the same problem becomes **impossible** once `k` is large compared to
  the modulus, and quantitatively ambiguous long before that:

  - `mod_ambiguity_lower_bound` : for every `n` with `m³·n < 3^k` there is an
    observed modular state with more than `n` consistent control words.  Taking
    `n = ⌈3^k/m³⌉ − 1` this is the promised `Ω(3^k / poly(m))` bound: the
    modulus is polynomial-size, the ambiguity is exponential.
  - `not_modSeedRecoverable_of_card` : if `m³ < 3^k` no recovery function exists.
  - `not_modSeedRecoverable_of_dl` : recovery for *all* words of length `≤ k`
    would in particular solve the discrete-logarithm problem for the matrix `B₂`
    modulo `m`; and that problem is already unsolvable for `k ≥ m³` because the
    `B₂`-orbit has collided by then.  This is the precise sense of
    "hard unless the `B₂` discrete logarithm mod `m` is easy".

## Main results

* `intSeedRecoverable`
* `mod_ambiguity_lower_bound`
* `not_modSeedRecoverable_of_card`
* `dlEasy_of_modSeedRecoverable`
* `not_dlEasy_of_large`
* `berggren_modulus_separation` — the combined statement.
-/

namespace Cryptography
namespace BerggrenModular

/-! ## Integer seed recovery is easy -/

/-- A nonempty word moves the root. -/
theorem applyWord_ne_root {u : List Move} (hu : u ≠ []) : applyWord u root ≠ root := by
  match u with
  | [] => exact absurd rfl hu
  | i :: rest =>
      have h1 : root.2.2 ≤ (applyWord rest root).2.2 := hyp_le_applyWord rest root_valid
      have h2 : (applyWord rest root).2.2 < (applyMove i (applyWord rest root)).2.2 :=
        hyp_lt_applyMove (applyWord_valid rest root_valid)
      intro hEq
      have : (applyWord (i :: rest) root).2.2 = root.2.2 := by rw [hEq]
      rw [applyWord_cons] at this
      linarith

/-- Self-terminating integer seed recovery: peel moves until the root is reached. -/
def recoverFrom : ℕ → Tri → List Move
  | 0, _ => []
  | n + 1, v =>
      if v = root then []
      else whichMove v :: recoverFrom n (invMove (whichMove v) v)

theorem recoverFrom_correct : ∀ (n : ℕ) (u : List Move), u.length ≤ n →
    recoverFrom n (applyWord u root) = u := by
  intro n
  induction n with
  | zero =>
      intro u hu
      simp only [Nat.le_zero, List.length_eq_zero_iff] at hu
      subst hu; rfl
  | succ n ih =>
      intro u hu
      match u with
      | [] => simp [recoverFrom]
      | i :: rest =>
          have hne : applyWord (i :: rest) root ≠ root :=
            applyWord_ne_root (List.cons_ne_nil i rest)
          have hval : Valid (applyWord rest root) := applyWord_valid rest root_valid
          have hlen : rest.length ≤ n := by
            simpa [List.length_cons, Nat.succ_le_succ_iff] using hu
          rw [recoverFrom, if_neg hne, applyWord_cons, whichMove_applyMove i hval,
            invMove_applyMove, ih rest hlen]

/-- **Seed recovery over `ℤ` is solvable**, by an explicit `O(k)` algorithm. -/
theorem intSeedRecoverable (k : ℕ) :
    ∃ f : Tri → List Move, ∀ u : List Move, u.length ≤ k → f (applyWord u root) = u :=
  ⟨recoverFrom k, recoverFrom_correct k⟩

/-! ## The modular observation -/

/-- The modular state observed after running the control word `u` from the root. -/
def stateMod (m : ℕ) (u : List Move) : TriM m := redTri m (applyWord u root)

/-- Seed recovery modulo `m`, for control words of length at most `k`. -/
def ModSeedRecoverable (m k : ℕ) : Prop :=
  ∃ f : TriM m → List Move, ∀ u : List Move, u.length ≤ k → f (stateMod m u) = u

/-- If two different control words produce the same modular state, no recovery
function can exist. -/
theorem not_modSeedRecoverable_of_collision {m k : ℕ} {u w : List Move}
    (hu : u.length ≤ k) (hw : w.length ≤ k) (hne : u ≠ w)
    (hcol : stateMod m u = stateMod m w) : ¬ ModSeedRecoverable m k := by
  rintro ⟨f, hf⟩
  exact hne (((hf u hu).symm.trans (congrArg f hcol)).trans (hf w hw))

/-! ## Counting: `3^k` control words versus `m³` states -/

/-- The control words of length `k`, as functions. -/
def stateModF (m k : ℕ) (u : Fin k → Move) : TriM m := stateMod m (List.ofFn u)

theorem card_TriM (m : ℕ) [NeZero m] : Fintype.card (TriM m) = m ^ 3 := by
  simp only [TriM, Fintype.card_prod, ZMod.card]
  ring

theorem card_words (k : ℕ) : Fintype.card (Fin k → Move) = 3 ^ k := by
  simp [card_move]

/-- **Quantitative ambiguity: the `Ω(3^k / m³)` bound.**  For every `n` with
`m³ · n < 3^k` there is a modular observation that is consistent with strictly
more than `n` distinct control words of length `k`.  Since the state space has
only `m³ = poly` points while there are `3^k` words, an adversary holding one
observed state cannot do better than searching a set of size `Ω(3^k / m³)`. -/
theorem mod_ambiguity_lower_bound (m k n : ℕ) [NeZero m] (h : m ^ 3 * n < 3 ^ k) :
    ∃ s : TriM m, n < (Finset.univ.filter (fun u : Fin k → Move => stateModF m k u = s)).card := by
  have hmaps : ∀ u ∈ (Finset.univ : Finset (Fin k → Move)), stateModF m k u ∈
      (Finset.univ : Finset (TriM m)) := fun u _ => Finset.mem_univ _
  have hcard : (Finset.univ : Finset (TriM m)).card * n <
      (Finset.univ : Finset (Fin k → Move)).card := by
    rw [Finset.card_univ, Finset.card_univ, card_TriM, card_words]
    exact h
  obtain ⟨s, -, hs⟩ :=
    Finset.exists_lt_card_fiber_of_mul_lt_card_of_maps_to hmaps hcard
  exact ⟨s, hs⟩

/-- Two distinct control words of the same length `k` collide modulo `m`
as soon as `m³ < 3^k`. -/
theorem exists_mod_collision (m k : ℕ) [NeZero m] (h : m ^ 3 < 3 ^ k) :
    ∃ u w : List Move, u.length = k ∧ w.length = k ∧ u ≠ w ∧ stateMod m u = stateMod m w := by
  have hcard : Fintype.card (TriM m) < Fintype.card (Fin k → Move) := by
    rw [card_TriM, card_words]; exact h
  obtain ⟨u, w, hne, heq⟩ := Fintype.exists_ne_map_eq_of_card_lt (stateModF m k) hcard
  refine ⟨List.ofFn u, List.ofFn w, List.length_ofFn, List.length_ofFn, ?_, heq⟩
  intro hEq
  exact hne (List.ofFn_injective hEq)

/-- **Information-theoretic impossibility.**  Once `m³ < 3^k`, no function of the
observed modular state can return the control word. -/
theorem not_modSeedRecoverable_of_card (m k : ℕ) [NeZero m] (h : m ^ 3 < 3 ^ k) :
    ¬ ModSeedRecoverable m k := by
  obtain ⟨u, w, hu, hw, hne, hcol⟩ := exists_mod_collision m k h
  exact not_modSeedRecoverable_of_collision (le_of_eq hu) (le_of_eq hw) hne hcol

/-! ## The `B₂` discrete logarithm -/

/-- The discrete-logarithm-like problem for the Berggren matrix `B₂` modulo `m`:
given the state reached by `t` applications of `B₂`, return `t`.  By
`vecOfM_iterate_applyMoveM` this state is exactly `B₂^t · (3,4,5)ᵀ` over `ℤ/m`. -/
def DLEasy (m k : ℕ) : Prop :=
  ∃ g : TriM m → ℕ, ∀ t ≤ k, g (stateMod m (List.replicate t Move.m2)) = t

/-- The observed `B₂`-power state really is `B₂^t` applied to the root vector. -/
theorem stateMod_replicate_eq_matrix_pow (m t : ℕ) :
    vecOfM m (stateMod m (List.replicate t Move.m2))
      = ((bergMatrixM m Move.m2) ^ t).mulVec (vecOfM m (redTri m root)) := by
  rw [stateMod, redTri_applyWord, applyWordM_replicate, vecOfM_iterate_applyMoveM]

/-- **Reduction: seed recovery solves the `B₂` discrete logarithm.**  A recovery
algorithm for control words of length `≤ k` yields, with a single call, a solver
for the discrete logarithm of `B₂` modulo `m` for exponents up to `k`. -/
theorem dlEasy_of_modSeedRecoverable {m k : ℕ} (h : ModSeedRecoverable m k) : DLEasy m k := by
  obtain ⟨f, hf⟩ := h
  refine ⟨fun s => (f s).length, fun t ht => ?_⟩
  show (f (stateMod m (List.replicate t Move.m2))).length = t
  rw [hf (List.replicate t Move.m2) (by simpa using ht)]
  simp

/-- The `B₂`-orbit of the root modulo `m` collides within `m³` steps. -/
theorem exists_b2_orbit_collision (m : ℕ) [NeZero m] :
    ∃ t₁ t₂ : ℕ, t₁ ≤ m ^ 3 ∧ t₂ ≤ m ^ 3 ∧ t₁ ≠ t₂ ∧
      stateMod m (List.replicate t₁ Move.m2) = stateMod m (List.replicate t₂ Move.m2) := by
  have hcard : Fintype.card (TriM m) < Fintype.card (Fin (m ^ 3 + 1)) := by
    rw [card_TriM, Fintype.card_fin]; omega
  obtain ⟨t₁, t₂, hne, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt
      (fun t : Fin (m ^ 3 + 1) => stateMod m (List.replicate (t : ℕ) Move.m2)) hcard
  refine ⟨(t₁ : ℕ), (t₂ : ℕ), by omega, by omega, ?_, heq⟩
  intro hEq
  exact hne (Fin.ext hEq)

/-- **The `B₂` discrete logarithm mod `m` is not merely hard, it is ill-posed for
exponents beyond the orbit length.**  Hence for `k ≥ m³` no solver exists. -/
theorem not_dlEasy_of_large (m k : ℕ) [NeZero m] (hk : m ^ 3 ≤ k) : ¬ DLEasy m k := by
  obtain ⟨t₁, t₂, h1, h2, hne, heq⟩ := exists_b2_orbit_collision m
  rintro ⟨g, hg⟩
  exact hne (((hg t₁ (h1.trans hk)).symm.trans (congrArg g heq)).trans (hg t₂ (h2.trans hk)))

/-- **Seed recovery mod `m` fails for long words, via the `B₂` discrete
logarithm.**  This route is independent of the counting argument: it shows that
already the one-parameter family of `B₂`-power words is unrecoverable. -/
theorem not_modSeedRecoverable_of_dl (m k : ℕ) [NeZero m] (hk : m ^ 3 ≤ k) :
    ¬ ModSeedRecoverable m k :=
  fun h => not_dlEasy_of_large m k hk (dlEasy_of_modSeedRecoverable h)

/-! ## The separation -/

/-- **Main theorem (modulus separation for the Berggren tree).**

Fix a modulus `m ≥ 1` and a control-word length `k ≥ m³`.  Then

1. over `ℤ`, the control word is recovered from a single observed state by an
   explicit `O(k)` algorithm;
2. over `ℤ/m`, *no* function of the observed state recovers the control word;
3. quantitatively, some observed modular state is consistent with more than
   `n` control words for every `n` with `m³·n < 3^k`, i.e. the ambiguity is
   `Ω(3^k / m³)`.

The classifier itself is not at fault: by `whichMoveMod_redTri` it stays sound
for every state that has not wrapped around the modulus. -/
theorem berggren_modulus_separation (m k : ℕ) [NeZero m] (hk : m ^ 3 ≤ k) :
    (∃ f : Tri → List Move, ∀ u : List Move, u.length ≤ k → f (applyWord u root) = u) ∧
    ¬ ModSeedRecoverable m k ∧
    (∀ n : ℕ, m ^ 3 * n < 3 ^ k →
      ∃ s : TriM m,
        n < (Finset.univ.filter (fun u : Fin k → Move => stateModF m k u = s)).card) :=
  ⟨intSeedRecoverable k, not_modSeedRecoverable_of_dl m k hk,
    fun n hn => mod_ambiguity_lower_bound m k n hn⟩

end BerggrenModular
end Cryptography