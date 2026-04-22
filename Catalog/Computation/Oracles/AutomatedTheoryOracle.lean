import Mathlib

/-! # CatalogBuild.Computation.Oracles.AutomatedTheoryOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 26
-/

noncomputable section

/-- The set of provable statements (theorems) of a formal system. -/
def FormalSystem.theorems {S P : Type*} (F : FormalSystem S P) : Set S :=
  { s | ∃ p, F.isProof p s }

/-- A Theory Oracle enumerates statements one at a time. -/
structure TheoryOracle (Statement : Type*) where
  enumerate : ℕ → Statement

/-- An oracle is **sound** if every output is provable. -/
def TheoryOracle.Sound {S P : Type*} (O : TheoryOracle S) (F : FormalSystem S P) : Prop :=
  ∀ n, O.enumerate n ∈ F.theorems

/-- An oracle is **complete** if it eventually outputs every provable statement. -/
def TheoryOracle.Complete {S P : Type*} (O : TheoryOracle S) (F : FormalSystem S P) : Prop :=
  ∀ s ∈ F.theorems, ∃ n, O.enumerate n = s

/-- **Theorem 1.1 (Existence of Sound Complete Oracle)**:
If the formal system has at least one theorem and both proofs and
statements can be enumerated, then a sound and complete oracle exists. -/
theorem sound_complete_oracle_exists {S P : Type*}
    (F : FormalSystem S P) (enumProofs : ℕ → P) (enumStatements : ℕ → S)
    (h_surj_P : Function.Surjective enumProofs)
    (h_surj_S : Function.Surjective enumStatements)
    (h_nonempty : ∃ s, s ∈ F.theorems) :
    ∃ O : TheoryOracle S, O.Sound F ∧ O.Complete F := by
  obtain ⟨s₀, hs₀⟩ := h_nonempty
  have h_surj_theorems : ∃ g : ℕ → S, (∀ n, g n ∈ F.theorems) ∧
      (∀ s ∈ F.theorems, ∃ n, g n = s) := by
    have h_ctble : Set.Countable F.theorems :=
      Set.countable_range enumStatements |> Set.Countable.mono fun x hx => by
        cases' hx with p hp; cases' h_surj_S x with i hi; aesop
    have := h_ctble.exists_eq_range
    exact Exists.elim (this ⟨s₀, hs₀⟩) fun f hf =>
      ⟨f, fun n => hf.symm ▸ Set.mem_range_self _,
       fun s hs => hf.subset hs⟩
  aesop

/-- **Theorem 2.1**: Cantor pairing at the boundary. -/
theorem cantor_pair_diagonal (n : ℕ) :
    cantorPair 0 n = n * (n + 1) / 2 + n := by
  simp [cantorPair]

/-- **Theorem 2.2**: Triangular number formula: ∑_{k=0}^{d} (k+1) = (d+1)(d+2)/2. -/
theorem dovetail_pairs_at_depth (d : ℕ) :
    (Finset.range (d + 1)).sum (fun k => k + 1) = (d + 1) * (d + 2) / 2 := by
  convert Finset.sum_range_id (d + 2) using 1 <;>
    simp +arith +decide [mul_comm, Finset.sum_range_succ']

/-- **Theorem 2.3 (Dovetail Coverage)**: Every pair (a,b) with a+b ≤ d
has Cantor index less than the (d+1)-th triangular number. -/
theorem dovetail_coverage (a b d : ℕ) (h : a + b ≤ d) :
    cantorPair a b < (d + 1) * (d + 2) / 2 := by
  unfold cantorPair
  rw [Nat.lt_iff_add_one_le, Nat.le_div_iff_mul_le] <;>
    nlinarith [Nat.div_mul_le_self ((a + b) * (a + b + 1)) 2]

/-- **Theorem 3.1 (Strict Hierarchy)**: Level n+1 strictly contains level n.
Abstract model of Post's theorem on the arithmetical hierarchy. -/
theorem oracle_hierarchy_strict (solvable : ℕ → Set ℕ)
    (h_mono : ∀ n, solvable n ⊆ solvable (n + 1))
    (h_strict : ∀ n, ∃ x, x ∈ solvable (n + 1) ∧ x ∉ solvable n) :
    ∀ n, solvable n ⊂ solvable (n + 1) := by
  intro n
  exact ⟨h_mono n, fun h => by
    obtain ⟨x, hx1, hx2⟩ := h_strict n
    exact hx2 (h hx1)⟩

/-- Oracle composition: combine outputs of two oracles. -/
def composeOracles (A B : TheoryOracle ℕ) : TheoryOracle ℕ where
  enumerate n :=
    let (a, b) := cantorUnpair n
    A.enumerate a + B.enumerate b

/-- **Theorem 3.2 (Composition Monotonicity)**: If B can output 0,
then the composed oracle's range contains A's range. -/
theorem compose_range_contains_left (A B : TheoryOracle ℕ)
    (h : ∃ m, B.enumerate m = 0) :
    Set.range A.enumerate ⊆ Set.range (composeOracles A B).enumerate := by
  obtain ⟨m, hm⟩ := h
  intro x hx
  obtain ⟨n, hn⟩ := hx
  use cantorPair n m
  simp [cantorPair]
  have h_unpair : cantorUnpair ((n + m) * (n + m + 1) / 2 + m) = (n, m) := by
    unfold cantorUnpair
    have hw : (Nat.sqrt (8 * ((n + m) * (n + m + 1) / 2 + m) + 1) - 1) / 2 = n + m := by
      rw [show 8 * ((n + m) * (n + m + 1) / 2 + m) + 1 = (2 * (n + m) + 1) ^ 2 + 8 * m by
        linarith [Nat.div_mul_cancel (show 2 ∣ (n + m) * (n + m + 1) from
          Nat.dvd_of_mod_eq_zero (by norm_num [Nat.add_mod, Nat.mod_two_of_bodd]))]]
      rw [Nat.le_antisymm_iff]
      exact ⟨Nat.le_of_lt_succ <| Nat.div_lt_of_lt_mul <| by
        linarith [Nat.sub_add_cancel <|
          show 1 ≤ Nat.sqrt ((2 * (n + m) + 1) ^ 2 + 8 * m) from
            Nat.sqrt_pos.mpr <| by positivity,
          show Nat.sqrt ((2 * (n + m) + 1) ^ 2 + 8 * m) ≤ 2 * (n + m) + 1 + 1 from
            Nat.le_of_lt_succ <| Nat.sqrt_lt.mpr <| by nlinarith],
        Nat.le_div_iff_mul_le zero_lt_two |>.2 <|
          Nat.le_sub_one_of_lt <| Nat.le_sqrt.mpr <| by nlinarith⟩
    simp +decide [hw]
  unfold composeOracles; aesop

/-- **Theorem 4.1 (Incompressibility counting)**: At most 2^(n-c) elements
of {0,...,2^n-1} have value below 2^(n-c). -/
theorem incompressibility_counting (n c : ℕ) (_hc : c ≤ n) :
    ((Finset.range (2^n)).filter (fun x => decide (x < 2^(n - c)) = true)).card
      ≤ 2^(n - c) := by
  norm_num [Finset.filter_lt_eq_Ioi]
  exact le_trans (Finset.card_le_card fun x hx =>
    Finset.mem_Iio.mpr <| Finset.mem_filter.mp hx |>.2) (by simp +decide)

/-- **Theorem 4.2 (Oracle Speed Limit)**: An oracle running for T steps
can output at most T distinct values. -/
theorem oracle_speed_limit (T : ℕ) (f : Fin T → ℕ) :
    (Finset.image (fun i => f i) Finset.univ).card ≤ T := by
  exact le_trans Finset.card_image_le (by simp)

/-- A theorem is "interesting" if its shortest proof exceeds a threshold. -/
def isInteresting (proofLength : ℕ → ℕ) (threshold : ℕ) (s : ℕ) : Prop :=
  proofLength s ≥ threshold

/-- The Busy Beaver domination property. -/
def EventuallyDominates (f g : ℕ → ℕ) : Prop :=
  ∃ N, ∀ n, n ≥ N → f n > g n

/-- **Theorem 5.1**: Any function assumed to dominate all functions does so. -/
theorem busybeaver_dominance
    (BB : ℕ → ℕ) (h_BB : ∀ f : ℕ → ℕ, EventuallyDominates BB f)
    (g : ℕ → ℕ) : EventuallyDominates BB g :=
  h_BB g

/-- **Theorem 6.1**: Oracle ordering is reflexive. -/
theorem oracle_le_refl (O : TheoryOracle ℕ) : O ≤ O :=
  Set.Subset.refl _

/-- **Theorem 6.2**: Oracle ordering is transitive. -/
theorem oracle_le_trans (O₁ O₂ O₃ : TheoryOracle ℕ)
    (h₁₂ : O₁ ≤ O₂) (h₂₃ : O₂ ≤ O₃) : O₁ ≤ O₃ :=
  Set.Subset.trans h₁₂ h₂₃

/-- The "union oracle": interleaves outputs of two oracles. -/
def unionOracle (O₁ O₂ : TheoryOracle ℕ) : TheoryOracle ℕ where
  enumerate n := if n % 2 = 0 then O₁.enumerate (n / 2) else O₂.enumerate (n / 2)

/-- **Theorem 6.3**: The union oracle contains the left oracle's range. -/
theorem union_oracle_contains_left (O₁ O₂ : TheoryOracle ℕ) :
    Set.range O₁.enumerate ⊆ Set.range (unionOracle O₁ O₂).enumerate := by
  intro x ⟨k, hk⟩
  exact ⟨2 * k, by simp [hk, unionOracle]⟩

/-- **Theorem 6.4**: The union oracle contains the right oracle's range. -/
theorem union_oracle_contains_right (O₁ O₂ : TheoryOracle ℕ) :
    Set.range O₂.enumerate ⊆ Set.range (unionOracle O₁ O₂).enumerate := by
  intro x hx
  obtain ⟨n, rfl⟩ := hx
  use 2 * n + 1
  simp +arith +decide [unionOracle]
  norm_num [Nat.add_div]

/-- Discovery count: distinct theorems with value ≤ L found in first T steps. -/
def discoveryCount (oracle : TheoryOracle ℕ) (T L : ℕ) : ℕ :=
  ((Finset.range T).image oracle.enumerate |>.filter (· ≤ L)).card

/-- **Theorem 7.1 (Monotonicity)**: More search steps → more discoveries. -/
theorem discovery_monotone_T (oracle : TheoryOracle ℕ) (T₁ T₂ L : ℕ) (h : T₁ ≤ T₂) :
    discoveryCount oracle T₁ L ≤ discoveryCount oracle T₂ L :=
  Finset.card_mono <| Finset.filter_subset_filter _ <|
    Finset.image_subset_image <| Finset.range_mono h

/-- **Theorem 7.2 (Bounded Discovery)**: At most L+1 distinct values ≤ L. -/
theorem discovery_bounded (oracle : TheoryOracle ℕ) (T L : ℕ) :
    discoveryCount oracle T L ≤ L + 1 :=
  le_trans (Finset.card_le_card <| fun x hx =>
    Finset.mem_range_succ_iff.2 <| Finset.mem_filter.1 hx |>.2)
    (by simp +decide)

/-- **Theorem 8.1 (Diagonal Lemma)**: The diagonal function
differs from every enumerated function at its own index. -/
theorem diagonal_lemma (enum : ℕ → ℕ → Bool) :
    ∀ n, (fun k => !(enum k k)) n ≠ enum n n := by
  intro n; simp

/-- **Theorem 8.2 (Abstract Fixed Point / Kleene's Recursion Theorem)**:
Any transformation F on a surjectively enumerated family has a fixed point. -/
theorem abstract_fixed_point {α : Type*} (F : (ℕ → α) → (ℕ → α))
    (enum : ℕ → ℕ → α) (h_surj : ∀ f : ℕ → α, ∃ n, enum n = f) :
    ∃ n, enum n = F (enum n) := by
  contrapose! h_surj
  have hg : ∃ g : ℕ → α, ∀ n, g n ≠ enum n n := by
    by_cases h : ∃ x : α, x ≠ enum 0 0
    · have h_nt : ∀ n, ∃ x : α, x ≠ enum n n := by
        intro n
        by_cases h_eq : ∀ x : α, x = enum n n
        · exact False.elim (h_surj n (funext fun m => by simp +decide [h_eq]))
        · exact not_forall.mp h_eq
      exact ⟨fun n => Classical.choose (h_nt n), fun n => Classical.choose_spec (h_nt n)⟩
    · simp_all +decide [funext_iff]
  exact ⟨hg.choose, fun n hn => hg.choose_spec n <| hn ▸ rfl⟩

end
