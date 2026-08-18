import Logic.AlmostLossless.Instances

/-!
# Optimality: randomness is never useful, and honesty is free

Two structural results that close the loop opened by `Core` and `Scheme`.

* `AlmostLossless.randomized_epsilon_pigeonhole` — the exact `ε`-pigeonhole
  characterisation survives randomisation: if *any* randomized ensemble of codes
  has average failure probability `≤ ε`, then already a set of `≤ |C|` source
  words carries probability `≥ 1 - ε`, so a *deterministic* code achieves the
  same `ε`.  Shared randomness buys nothing, for **every** source (the earlier
  `randomized_avg_failProb_lower` was the uniform-source special case).

* `AlmostLossless.exists_scanScheme_of_code` — conversely, *every* code, honest
  or not, is matched on its correct set by a uniqueness-scan code, whose decoder
  probes at most **one** candidate.  So the "no silent corruption" guarantee
  costs one extra alphabet symbol and nothing else: no checksum, no rate loss
  beyond `+1`, no decoding time.
-/

namespace AlmostLossless

open Finset

variable {S C : Type*} [Fintype S] [DecidableEq S]

/-! ## Randomness never helps -/

/-- Some seed of an ensemble is at least as good as the average. -/
theorem exists_seed_failProb_le_avg {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (μ : Source S) (K : Ω → Code S C) :
    ∃ ω : Ω, failProb μ (K ω) ≤ avgFailProb μ K := by
  have hΩ : (0 : ℚ) < (Fintype.card Ω : ℚ) := by exact_mod_cast Fintype.card_pos (α := Ω)
  have hsum : ∑ ω : Ω, failProb μ (K ω) ≤ ∑ _ω : Ω, avgFailProb μ K := by
    have heq : ∑ _ω : Ω, avgFailProb μ K = ∑ ω : Ω, failProb μ (K ω) := by
      rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ, avgFailProb]
      field_simp
    rw [heq]
  obtain ⟨ω, -, hω⟩ :=
    Finset.exists_le_of_sum_le (Finset.univ_nonempty (α := Ω)) hsum
  exact ⟨ω, hω⟩

/-- **Randomness never helps, for every source.**  If a randomized ensemble of
codes into `C` has average failure probability `≤ ε`, then some set of at most
`|C|` source words already carries probability `≥ 1 - ε`; by
`epsilon_pigeonhole_iff` a deterministic code into `C` then achieves failure
probability `≤ ε` as well. -/
theorem randomized_epsilon_pigeonhole [Fintype C] [DecidableEq C] [Nonempty C]
    {Ω : Type*} [Fintype Ω] [Nonempty Ω] (μ : Source S) (K : Ω → Code S C) (ε : ℚ)
    (h : avgFailProb μ K ≤ ε) :
    ∃ T : Finset S, T.card ≤ Fintype.card C ∧ 1 - ε ≤ μ.prob T := by
  obtain ⟨ω, hω⟩ := exists_seed_failProb_le_avg μ K
  exact (epsilon_pigeonhole_iff μ ε).1 ⟨K ω, le_trans hω h⟩

/-- Derandomisation of an arbitrary ensemble: a single deterministic code is at
least as reliable as the randomized average. -/
theorem exists_deterministic_code_of_ensemble [Fintype C] [DecidableEq C] [Nonempty C]
    {Ω : Type*} [Fintype Ω] [Nonempty Ω] (μ : Source S) (K : Ω → Code S C) (ε : ℚ)
    (h : avgFailProb μ K ≤ ε) :
    ∃ K' : Code S C, failProb μ K' ≤ ε := by
  exact (epsilon_pigeonhole_iff μ ε).2 (randomized_epsilon_pigeonhole μ K ε h)

/-! ## Honesty is free -/

omit [Fintype S] [DecidableEq S] in
/-- The encoder is injective on the correctly decoded words. -/
theorem injOn_enc_of_correct (K : Code S C) {x y : S} (hx : Correct K x) (hy : Correct K y)
    (h : K.enc x = K.enc y) : x = y := by
  have : (some x : Option S) = some y := by
    unfold Correct at hx hy
    rw [← hx, ← hy, h]
  exact Option.some_inj.mp this

/-- **Honesty is free.**  Every code `K` — honest or not — is matched, on its
correct set, by a uniqueness-scan code: the scan code is honest for free, has
exactly the same correct set, and its decoder probes at most one candidate.  The
only cost is the single extra alphabet symbol of `Option C`. -/
theorem exists_scanScheme_of_code [DecidableEq C] (K : Code S C) :
    ∃ P : ScanScheme S Unit C,
      (∀ s : S, Correct (P.code ()) s ↔ Correct K s) ∧
      Honest (P.code ()) ∧
      (∀ m : C, P.decodeCost () m ≤ 1) := by
  classical
  refine ⟨{ typical := ({s | Correct K s} : Finset S)
            hash := fun _ s => K.enc s
            cand := fun _ m => {s ∈ ({s | Correct K s} : Finset S) | K.enc s = m}
            cand_subset := fun _ _ => Finset.filter_subset _ _
            self_mem_cand := fun _ _ hs => Finset.mem_filter.2 ⟨hs, rfl⟩ }, ?_, ?_, ?_⟩
  · intro s
    constructor
    · intro hcor
      by_contra hK
      have hK' : ¬ (K.dec (K.enc s) = some s) := hK
      simp [Correct, ScanScheme.code, hK'] at hcor
    · intro hK
      have hs : s ∈ ({s | Correct K s} : Finset S) := by simpa using hK
      refine correct_scanCode _ () ?_ hs
      intro x hx y hy hxy
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx hy
      exact injOn_enc_of_correct K hx hy hxy
  · exact honest_scanCode _ ()
  · intro m
    show ({s ∈ ({s | Correct K s} : Finset S) | K.enc s = m} : Finset S).card ≤ 1
    rw [Finset.card_le_one]
    intro x hx y hy
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx hy
    exact injOn_enc_of_correct K hx.1 hy.1 (by rw [hx.2, hy.2])

end AlmostLossless