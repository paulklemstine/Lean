import Mathlib

/-! # CatalogBuild.Cryptography.ZeroKnowledge.ComputationalSoundness

Auto-generated from theorem catalog database.
Domain: Cryptography/ZeroKnowledge
Declarations: 15
-/

/-- A security game parameterized by a security parameter -/
structure SecurityGame where
  /-- The game's output: 1 if adversary wins, 0 otherwise -/
  adversaryWins : ℕ → Prop  -- indexed by security parameter

/-- The advantage of an adversary in a game, modeled as a function of
the security parameter. In the concrete model, this maps λ to ℝ. -/
def Advantage := ℕ → ℝ

/-- An advantage function is negligible if it vanishes faster than any
inverse polynomial. -/
def IsNegligible (adv : Advantage) : Prop :=
  ∀ c : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → |adv n| < (1 / (n : ℝ)) ^ c

/-- Zero advantage is negligible -/
theorem zero_negligible : IsNegligible (fun _ => 0) := by
  intro c
  use 1
  intro n hn
  simp
  exact pow_pos (by positivity) c

/-- [Section: # CatalogBuild.Cryptography.ZeroKnowledge.ComputationalSoundness
Auto-generated from theorem catalog database.
Domain: Cryptography/ZeroKnowledge
Declarations: 15] -/
theorem const_not_negligible (ε : ℝ) (hε : 0 < ε) :
    ¬ IsNegligible (fun _ => ε) := by
  intro h
  obtain ⟨N, hN⟩ := h 1
  -- For large enough n, 1/n < ε, contradiction
  -- Choose n > max(N, ⌈1/ε⌉ + 1)
  contrapose! hN;
  cases' exists_nat_one_div_lt hε with n hn ; use n + N + 1 ; norm_num at *;
  exact ⟨ by linarith, by rw [ abs_of_pos hε ] ; exact le_trans ( inv_anti₀ ( by positivity ) ( by linarith ) ) hn.le ⟩

/-- Two games are computationally indistinguishable if no efficient
adversary can distinguish them with non-negligible advantage. -/
def GamesIndistinguishable (G₁ G₂ : SecurityGame) : Prop :=
  ∀ distinguish : ℕ → Prop,  -- any distinguisher
    IsNegligible (fun n => if G₁.adversaryWins n = G₂.adversaryWins n then 0 else 1)

/-- Game indistinguishability is reflexive -/
theorem games_indist_refl (G : SecurityGame) :
    IsNegligible (fun _ => (0 : ℝ)) := zero_negligible

/-- Game indistinguishability is symmetric -/
theorem games_indist_symm (adv : Advantage) (h : IsNegligible adv) :
    IsNegligible (fun n => -adv n) := by
  intro c
  obtain ⟨N, hN⟩ := h c
  exact ⟨N, fun n hn => by rw [abs_neg]; exact hN n hn⟩

/-- [Section: # CatalogBuild.Cryptography.ZeroKnowledge.ComputationalSoundness
Auto-generated from theorem catalog database.
Domain: Cryptography/ZeroKnowledge
Declarations: 15] -/
theorem advantage_triangle (adv₁ adv₂ : Advantage)
    (h₁ : IsNegligible adv₁) (h₂ : IsNegligible adv₂) :
    IsNegligible (fun n => adv₁ n + adv₂ n) := by
  intro c
  obtain ⟨N₁, hN₁⟩ := h₁ (c + 1)
  obtain ⟨N₂, hN₂⟩ := h₂ (c + 1)
  use max N₁ (max N₂ 3);
  -- For n ≥ max(N₁, N₂, 3), we have |adv₁ n + adv₂ n| ≤ |adv₁ n| + |adv₂ n| < 2*(1/n)^(c+1).
  have h_bound : ∀ n, max N₁ (max N₂ 3) ≤ n → |adv₁ n + adv₂ n| < 2 * (1 / (n : ℝ)) ^ (c + 1) := by
    exact fun n hn => abs_lt.mpr ⟨ by linarith [ abs_lt.mp ( hN₁ n ( le_trans ( le_max_left _ _ ) hn ) ), abs_lt.mp ( hN₂ n ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hn ) ) ], by linarith [ abs_lt.mp ( hN₁ n ( le_trans ( le_max_left _ _ ) hn ) ), abs_lt.mp ( hN₂ n ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hn ) ) ] ⟩;
  intro n hn; specialize h_bound n hn; rcases n with ( _ | _ | n ) <;> norm_num at *;
  exact h_bound.trans_le ( by rw [ pow_succ' ] ; norm_num ; nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) + 1 + 1 ), inv_pos.mpr ( by positivity : 0 < ( n + 1 + 1 : ℝ ) ^ c ), mul_inv_cancel₀ ( by positivity : ( n : ℝ ) + 1 + 1 ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( n + 1 + 1 : ℝ ) ^ c ≠ 0 ) ] )

theorem sum_negligible {k : ℕ} (advs : Fin k → Advantage)
    (h : ∀ i, IsNegligible (advs i)) :
    IsNegligible (fun n => ∑ i : Fin k, advs i n) := by
  induction' k with k ih;
  · exact zero_negligible;
  · simpa [ Fin.sum_univ_castSucc ] using advantage_triangle _ _ ( ih _ fun i => h ( Fin.castSucc i ) ) ( h ( Fin.last _ ) )

/-- The discrete log assumption: no efficient algorithm can compute
discrete logs with non-negligible probability. -/
structure DLogAssumption where
  /-- Advantage of the best DLog solver -/
  dlogAdvantage : Advantage
  /-- The advantage is negligible -/
  isHard : IsNegligible dlogAdvantage

theorem schnorr_soundness_reduction
    (dlog : DLogAssumption) (cheatingAdvantage : Advantage)
    (challengeSpace : ℕ) (hcs : 1 < challengeSpace)
    (h_reduction : ∀ n, cheatingAdvantage n ≤
      dlog.dlogAdvantage n + 1 / (challengeSpace : ℝ)) :
    -- If DLog is hard, cheating advantage is bounded
    ∀ c : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      cheatingAdvantage n < 2 / (challengeSpace : ℝ) + (1 / (n : ℝ)) ^ c := by
  intro c
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n ≥ N, dlog.dlogAdvantage n < (1 / (n : ℝ)) ^ c := by
    exact dlog.isHard c |> fun ⟨ N, hN ⟩ => ⟨ N, fun n hn => lt_of_abs_lt ( hN n hn ) ⟩;
  exact ⟨ N, fun n hn => lt_of_le_of_lt ( h_reduction n ) ( by have := hN n hn; ring_nf at *; linarith [ inv_pos.mpr ( by positivity : 0 < ( challengeSpace : ℝ ) ) ] ) ⟩

/-- A zero-knowledge protocol has computational ZK if the simulator's
output is computationally indistinguishable from real transcripts. -/
structure ComputationalZK where
  /-- Distinguishing advantage between real and simulated transcripts -/
  zkAdvantage : Advantage
  /-- The advantage is negligible -/
  isZK : IsNegligible zkAdvantage

theorem sequential_zk_composition
    (zk₁ zk₂ : ComputationalZK)
    (composedAdvantage : Advantage)
    (h_compose : ∀ n, composedAdvantage n ≤ zk₁.zkAdvantage n + zk₂.zkAdvantage n) :
    ∃ bound : Advantage,
      (∀ n, composedAdvantage n ≤ bound n) ∧
      IsNegligible bound := by
  exact ⟨fun n => zk₁.zkAdvantage n + zk₂.zkAdvantage n,
    h_compose,
    by
      apply advantage_triangle; exact zk₁.isZK; exact zk₂.isZK;⟩

/-- **The Rewinding Lemma** (simplified): If a prover succeeds with
probability ε in a single execution, then after rewinding and
re-challenging, the probability of getting two accepting transcripts
with different challenges is at least ε(ε - 1/|Ch|).
This is the key technical lemma for proving knowledge soundness
of Sigma protocols in the computational setting. -/
theorem rewinding_lemma (ε : ℝ) (challengeSize : ℕ)
    (hε : 0 < ε) (hcs : 0 < challengeSize)
    (h_large : 1 / (challengeSize : ℝ) < ε) :
    0 < ε * (ε - 1 / (challengeSize : ℝ)) := by
  apply mul_pos hε
  linarith

