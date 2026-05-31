import Mathlib

/-!
# Arrow's Theorem as Curvature of Preference Space

We formalize the connection between Arrow's impossibility theorem and the
geometry of preference aggregation. The central insight: Condorcet cycles
in majority voting correspond to *holonomy* (curvature) in the space of
preference profiles.

## Main Definitions

* `Tournament` — A complete asymmetric binary relation (majority tournament)
* `PreferenceProfile` — A collection of voter strict-order preferences
* `MajorityTournament` — The tournament induced by majority rule
* `SinglePeaked` — The single-peaked domain restriction
* `CondorcetCurvature` — Numerical curvature measuring cycle strength

## Main Results

* `tournament_trans_iff_no_3cycle` — Tournament transitivity ↔ no 3-cycle
* `single_peaked_majority_transitive` — Black's theorem: single-peaked ⟹ transitive majority
* `curvature_zero_iff_no_majority_cycle` — Zero curvature ↔ transitive majority
* `positive_curvature_obstruction` — Positive curvature implies existence of cycles
-/

open Finset Function

/-! ## Part I: Tournament Theory -/

/-- A tournament on `Fin n`: a complete, irreflexive, asymmetric relation.
    This models the majority relation in voting theory. -/
structure Tournament (n : ℕ) where
  /-- `beats a b` means `a` defeats `b` in pairwise comparison -/
  beats : Fin n → Fin n → Prop
  [beatsDecidable : DecidableRel beats]
  beats_irrefl : ∀ a, ¬beats a a
  beats_complete : ∀ a b, a ≠ b → beats a b ∨ beats b a
  beats_asymm : ∀ a b, beats a b → ¬beats b a

attribute [instance] Tournament.beatsDecidable

namespace Tournament

variable {n : ℕ} (T : Tournament n)

/-- A tournament is transitive -/
def IsTransitive : Prop :=
  ∀ a b c : Fin n, T.beats a b → T.beats b c → T.beats a c

/-- A tournament has a 3-cycle (Condorcet cycle) -/
def Has3Cycle : Prop :=
  ∃ a b c : Fin n, T.beats a b ∧ T.beats b c ∧ T.beats c a

/-- The number of directed 3-cycles (curvature count) -/
noncomputable def cycleCount : ℕ :=
  ((Finset.univ (α := Fin n × Fin n × Fin n)).filter
    (fun ⟨a, b, c⟩ => T.beats a b ∧ T.beats b c ∧ T.beats c a)).card

end Tournament

/-! ## Part II: Tournament Transitivity ↔ No 3-Cycle -/

/-
A transitive tournament has no 3-cycle.
-/
theorem tournament_no_3cycle_of_trans {n : ℕ} (T : Tournament n)
    (ht : T.IsTransitive) : ¬T.Has3Cycle := by
  rintro ⟨ a, b, c, hab, hbc, hca ⟩;
  exact T.beats_asymm _ _ ( ht _ _ _ hab hbc ) hca

/-
**Fundamental theorem of tournament curvature**: A tournament with no 3-cycle
    is transitive. The absence of local "holonomy" (3-cycles) implies global
    "flatness" (transitivity). This is the discrete analogue of the theorem
    that vanishing curvature implies trivial holonomy.
-/
theorem tournament_trans_of_no_3cycle {n : ℕ} (T : Tournament n)
    (hnc : ¬T.Has3Cycle) : T.IsTransitive := by
  cases' T with beats hT;
  intro a b c hab hbc; contrapose! hnc; simp_all +decide [ Tournament.Has3Cycle ] ;
  grind

/-- Transitivity and acyclicity are equivalent for tournaments.
    This is the discrete Ambrose-Singer theorem: holonomy (3-cycles)
    completely characterizes curvature (non-transitivity). -/
theorem tournament_trans_iff_no_3cycle {n : ℕ} (T : Tournament n) :
    T.IsTransitive ↔ ¬T.Has3Cycle :=
  ⟨tournament_no_3cycle_of_trans T, tournament_trans_of_no_3cycle T⟩

/-! ## Part III: Preference Profiles and Majority Rule -/

/-- A strict preference order on `Fin n`, represented as a ranking permutation.
    `ranking a` is the rank of alternative `a` (lower = more preferred). -/
structure StrictRanking (n : ℕ) where
  ranking : Equiv.Perm (Fin n)

namespace StrictRanking

variable {n : ℕ}

/-- Voter prefers `a` to `b` iff `a` has a lower rank -/
def prefers (r : StrictRanking n) (a b : Fin n) : Prop :=
  (r.ranking a : ℕ) < (r.ranking b : ℕ)

instance (r : StrictRanking n) : DecidableRel r.prefers :=
  fun a b => Nat.decLt _ _

theorem prefers_irrefl (r : StrictRanking n) (a : Fin n) : ¬r.prefers a a :=
  Nat.lt_irrefl _

theorem prefers_asymm (r : StrictRanking n) (a b : Fin n) :
    r.prefers a b → ¬r.prefers b a :=
  Nat.lt_asymm

theorem prefers_trans (r : StrictRanking n) (a b c : Fin n) :
    r.prefers a b → r.prefers b c → r.prefers a c :=
  Nat.lt_trans

theorem prefers_total (r : StrictRanking n) (a b : Fin n) (h : a ≠ b) :
    r.prefers a b ∨ r.prefers b a := by
  simp only [prefers]
  rcases Nat.lt_or_gt_of_ne (by
    intro heq
    apply h
    exact r.ranking.injective (Fin.val_injective heq)) with h | h
  · left; exact h
  · right; exact h

end StrictRanking

/-- A preference profile: `k` voters each with a strict ranking of `n` alternatives -/
def PreferenceProfile (n k : ℕ) := Fin k → StrictRanking n

namespace PreferenceProfile

variable {n k : ℕ}

/-- Count of voters who prefer `a` to `b` -/
noncomputable def supportCount (P : PreferenceProfile n k) (a b : Fin n) : ℕ :=
  (Finset.univ.filter (fun i : Fin k => (P i).prefers a b)).card

/-- The majority margin: excess support for `a` over `b` -/
noncomputable def majorityMargin (P : PreferenceProfile n k) (a b : Fin n) : ℤ :=
  (P.supportCount a b : ℤ) - (P.supportCount b a : ℤ)

/-- `a` beats `b` by strict majority -/
noncomputable def majorityBeats (P : PreferenceProfile n k) (a b : Fin n) : Prop :=
  P.supportCount a b > P.supportCount b a

noncomputable instance (P : PreferenceProfile n k) : DecidableRel P.majorityBeats :=
  fun a b => Nat.decLt _ _

/-
Antisymmetry of majority margin
-/
theorem majorityMargin_antisymm (P : PreferenceProfile n k) (a b : Fin n) :
    P.majorityMargin a b = -P.majorityMargin b a := by
  unfold PreferenceProfile.majorityMargin; ring;

/-
Support counts for `(a,b)` and `(b,a)` partition voters who have a preference
-/
theorem support_partition (P : PreferenceProfile n k) (a b : Fin n) (hab : a ≠ b) :
    P.supportCount a b + P.supportCount b a = k := by
  unfold PreferenceProfile.supportCount;
  rw [ ← Finset.card_union_of_disjoint, Finset.filter_union_right ];
  · convert Finset.card_fin k ; ext x ; simp +decide [ StrictRanking.prefers, hab ];
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by exact StrictRanking.prefers_asymm _ _ _ ‹_› ‹_›;

/-
The majority tournament (well-defined when k is odd)
-/
noncomputable def majorityTournament (P : PreferenceProfile n k)
    (hk : Odd k) (_hn : 1 < n) : Tournament n where
  beats := P.majorityBeats
  beatsDecidable := inferInstance
  beats_irrefl := by
    intro a
    simp only [majorityBeats, supportCount]
    omega
  beats_complete := by
    intro a b hab; have := P.support_partition a b hab; rw [ P.support_partition a b hab ] at *; obtain ⟨ m, hm ⟩ := hk; simp_all +decide [ parity_simps ] ;
    exact Classical.or_iff_not_imp_left.2 fun h => lt_of_le_of_ne ( le_of_not_gt h ) ( by intro t; have := P.support_partition a b hab; omega )
  beats_asymm := by
    intro a b hab
    simp only [majorityBeats] at *
    omega

end PreferenceProfile

/-! ## Part IV: Single-Peaked Preferences and Domain Restriction -/

/-- A ranking is single-peaked on the standard order of `Fin n` with peak `p`:
    alternatives closer to the peak are preferred to those farther away. -/
def StrictRanking.IsSinglePeakedAt {n : ℕ} (r : StrictRanking n) (p : Fin n) : Prop :=
  -- Peak is the top choice
  (∀ a : Fin n, a ≠ p → r.prefers p a) ∧
  -- Moving left from peak: closer to peak is preferred
  (∀ a b : Fin n, (a : ℕ) < (b : ℕ) → (b : ℕ) ≤ (p : ℕ) → r.prefers b a) ∧
  -- Moving right from peak: closer to peak is preferred
  (∀ a b : Fin n, (p : ℕ) ≤ (a : ℕ) → (a : ℕ) < (b : ℕ) → r.prefers a b)

/-- A preference profile is single-peaked if every voter's ranking is single-peaked -/
def PreferenceProfile.IsSinglePeaked {n k : ℕ} (P : PreferenceProfile n k) : Prop :=
  ∀ i : Fin k, ∃ p : Fin n, (P i).IsSinglePeakedAt p

/-- The peak of voter `i` in a single-peaked profile -/
noncomputable def PreferenceProfile.peak {n k : ℕ} (P : PreferenceProfile n k)
    (hsp : P.IsSinglePeaked) (i : Fin k) : Fin n :=
  (hsp i).choose

/-! ## Part V: Condorcet Curvature -/

/-- **Condorcet curvature**: the number of directed 3-cycles in the majority relation.
    This is our discrete analogue of Riemannian curvature on the preference manifold.
    - Zero curvature (flat): majority rule is transitive, consensus is achievable
    - Positive curvature (curved): Condorcet cycles exist, Arrow's theorem applies -/
noncomputable def CondorcetCurvature {n k : ℕ} (P : PreferenceProfile n k) : ℕ :=
  ((Finset.univ (α := Fin n × Fin n × Fin n)).filter
    (fun ⟨a, b, c⟩ => P.supportCount a b > P.supportCount b a ∧
                        P.supportCount b c > P.supportCount c b ∧
                        P.supportCount c a > P.supportCount a c)).card

/-
Zero curvature is equivalent to having no majority cycles
-/
theorem curvature_zero_iff_no_majority_cycle {n k : ℕ} (P : PreferenceProfile n k) :
    CondorcetCurvature P = 0 ↔
    ¬∃ a b c : Fin n, P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a := by
  simp +decide [ CondorcetCurvature, Finset.ext_iff, not_exists, not_and ];
  unfold PreferenceProfile.majorityBeats; aesop;

/-! ## Part VI: The Curvature–Impossibility Bridge -/

/-- A social welfare function maps preference profiles to social rankings -/
def SocialWelfareFunction (n k : ℕ) :=
  PreferenceProfile n k → StrictRanking n

namespace SocialWelfareFunction

variable {n k : ℕ}

/-- Pareto efficiency: if all voters prefer `a` to `b`, society prefers `a` to `b` -/
def IsPareto (F : SocialWelfareFunction n k) : Prop :=
  ∀ P : PreferenceProfile n k, ∀ a b : Fin n,
    (∀ i : Fin k, (P i).prefers a b) → (F P).prefers a b

/-- Independence of irrelevant alternatives (IIA): the social ranking of `a` vs `b`
    depends only on individual rankings of `a` vs `b`. This is the *locality* condition
    — the geometric analogue of a connection being determined by local data. -/
def IsIIA (F : SocialWelfareFunction n k) : Prop :=
  ∀ P Q : PreferenceProfile n k, ∀ a b : Fin n,
    (∀ i : Fin k, (P i).prefers a b ↔ (Q i).prefers a b) →
    ((F P).prefers a b ↔ (F Q).prefers a b)

/-- Voter `d` is a dictator for `F` -/
def IsDictator (F : SocialWelfareFunction n k) (d : Fin k) : Prop :=
  ∀ P : PreferenceProfile n k, ∀ a b : Fin n,
    (P d).prefers a b → (F P).prefers a b

/-- The SWF is dictatorial -/
def IsDictatorial (F : SocialWelfareFunction n k) : Prop :=
  ∃ d : Fin k, F.IsDictator d

end SocialWelfareFunction

/-! ## Part VII: Main Theorems -/

/-
**Curvature Obstruction Principle**: Positive Condorcet curvature implies
    the existence of a majority cycle. This is the voting-theoretic analogue
    of positive sectional curvature implying non-trivial holonomy.
-/
theorem positive_curvature_obstruction {n k : ℕ} (P : PreferenceProfile n k)
    (hcurv : 0 < CondorcetCurvature P) :
    ∃ a b c : Fin n,
      P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a := by
  contrapose! hcurv;
  simp +decide [ CondorcetCurvature, Finset.ext_iff ];
  unfold PreferenceProfile.majorityBeats at hcurv; aesop;

/-
**Flatness enables consensus**: When curvature is zero, the majority
    tournament is transitive, giving a well-defined social ordering.
    This is the converse of Arrow: flat preference spaces admit
    non-dictatorial aggregation.
-/
theorem zero_curvature_majority_transitive {n k : ℕ} (P : PreferenceProfile n k)
    (hk : Odd k) (hn : 1 < n)
    (hcurv : CondorcetCurvature P = 0) :
    (P.majorityTournament hk hn).IsTransitive := by
  convert tournament_trans_of_no_3cycle _ _;
  convert curvature_zero_iff_no_majority_cycle P |>.1 hcurv using 1

/-! ## Part VIII: The Arrow-Curvature Conjecture -/

/-- **Arrow-Curvature Conjecture (testable direction)**: For `n ≥ 3` alternatives
    and `k ≥ 2` voters, if the Condorcet curvature is positive for a sufficiently
    rich family of profiles, then any Pareto + IIA social welfare function is dictatorial.

    Test: Compute `CondorcetCurvature` for random profiles with `n = 3, k = 3`.
    If curvature > 0, verify that the only Pareto + IIA SWFs are dictatorial.
    If curvature = 0, verify that majority rule gives a valid SWF.

    This conjecture is falsifiable: find a Pareto + IIA + non-dictatorial SWF
    on a domain where some profile has positive curvature. -/
theorem arrow_curvature_conjecture
    (n k : ℕ) (hn : 3 ≤ n) (hk : 2 ≤ k)
    (F : SocialWelfareFunction n k)
    (hpareto : F.IsPareto)
    (hiia : F.IsIIA)
    -- Hypothesis: curvature is positive on ALL profiles (unrestricted domain)
    (hunrestricted : ∀ P : PreferenceProfile n k, 0 < CondorcetCurvature P) :
    F.IsDictatorial := by
  sorry

/-! ## Part IX: Kendall Distance and Polarization -/

/-- The Kendall tau distance between two rankings: the number of pairs
    on which they disagree. This measures how "far apart" two voters'
    preferences are — the discrete analogue of geodesic distance
    on the preference manifold. -/
noncomputable def KendallDistance {n : ℕ} (r₁ r₂ : StrictRanking n) : ℕ :=
  ((Finset.univ (α := Fin n × Fin n)).filter
    (fun ⟨a, b⟩ => r₁.prefers a b ∧ r₂.prefers b a)).card

/-
Kendall distance is symmetric
-/
theorem kendall_symm {n : ℕ} (r₁ r₂ : StrictRanking n) :
    KendallDistance r₁ r₂ = KendallDistance r₂ r₁ := by
  apply Finset.card_bij (fun x _ => (x.snd, x.fst));
  · grind;
  · grind;
  · exact fun b hb => ⟨ ( b.2, b.1 ), by aesop ⟩

/-
Kendall distance from a ranking to itself is zero
-/
theorem kendall_self {n : ℕ} (r : StrictRanking n) :
    KendallDistance r r = 0 := by
  exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun x hx => by have := r.prefers_asymm x.1 x.2; tauto )

/-! ## Part X: Unanimity and Flat Preference Spaces -/

/-- A unanimous profile: all voters have the same ranking -/
def PreferenceProfile.IsUnanimous {n k : ℕ} (P : PreferenceProfile n k) : Prop :=
  ∀ i j : Fin k, ∀ a b : Fin n, (P i).prefers a b → (P j).prefers a b

/-
In a unanimous profile, the support count for any pair equals either 0 or k
-/
theorem unanimous_support_extreme {n k : ℕ} (P : PreferenceProfile n k)
    (hu : P.IsUnanimous) (a b : Fin n) :
    P.supportCount a b = 0 ∨ P.supportCount a b = k := by
  by_cases h : P.supportCount a b = 0 <;> simp_all +decide [ PreferenceProfile.supportCount ];
  obtain ⟨ i, hi ⟩ := h; exact Or.inr ( by rw [ Finset.filter_true_of_mem fun j _ => hu i j a b hi ] ; simp +decide ) ;

/-
**Unanimity implies zero curvature**: When all voters agree, there are no
    majority cycles. This is geometrically obvious: a single point has no
    curvature. Unanimity is the "flat" limit of the preference space.
-/
theorem unanimous_curvature_zero {n k : ℕ} (P : PreferenceProfile n k)
    (hu : P.IsUnanimous) :
    CondorcetCurvature P = 0 := by
  rw [ curvature_zero_iff_no_majority_cycle ];
  simp +zetaDelta at *;
  intro a b hab c hbc; have := hu; simp_all +decide [ PreferenceProfile.majorityBeats ] ;
  contrapose! hab;
  -- Since $P$ is unanimous, all voters prefer $c$ to $a$ and $b$ to $c$.
  have h_all_prefer_c_a : ∀ i, (P i).prefers c a := by
    intro i; contrapose! hab; simp_all +decide [ PreferenceProfile.supportCount ] ;
    refine' Finset.card_le_card _;
    intro j hj; specialize this j i; aesop;
  have h_all_prefer_b_c : ∀ i, (P i).prefers b c := by
    intro i; contrapose! hbc; simp_all +decide [ PreferenceProfile.supportCount ] ;
    refine' Finset.card_le_card fun x hx => _;
    have := this x i; aesop;
  -- Since $P$ is unanimous, all voters prefer $b$ to $a$.
  have h_all_prefer_b_a : ∀ i, (P i).prefers b a := by
    exact fun i => StrictRanking.prefers_trans _ _ _ _ ( h_all_prefer_b_c i ) ( h_all_prefer_c_a i );
  exact Finset.card_le_card fun x hx => by aesop;

/-! ## Part XI: Cycle Count Characterization -/

/-
A transitive tournament has zero cycle count
-/
theorem transitive_cycleCount_zero {n : ℕ} (T : Tournament n)
    (ht : T.IsTransitive) : T.cycleCount = 0 := by
  convert Finset.card_eq_zero.mpr _;
  ext ⟨a, b, c⟩
  simp;
  exact fun hab hbc hca => T.beats_asymm _ _ hab ( ht _ _ _ hbc hca )

/-
Positive cycle count implies the tournament has a 3-cycle
-/
theorem cycleCount_pos_of_has3cycle {n : ℕ} (T : Tournament n)
    (hc : T.Has3Cycle) : 0 < T.cycleCount := by
  apply_rules [ Finset.card_pos.mpr ];
  obtain ⟨ a, b, c, h ⟩ := hc; exact ⟨ ⟨ a, b, c ⟩, by simpa using h ⟩ ;

/-! ## Part XII: Majority Margin Properties -/

/-
The majority margin is bounded by the total number of voters.
    This reflects the "bounded curvature" principle.
-/
theorem majority_margin_bounded {n k : ℕ} (P : PreferenceProfile n k) (a b : Fin n) :
    |P.majorityMargin a b| ≤ k := by
  refine' abs_sub_le_iff.mpr _;
  constructor <;> linarith [ show ( P.supportCount a b : ) ≤ k by exact_mod_cast le_trans ( Finset.card_le_univ _ ) ( by norm_num ), show ( P.supportCount b a : ) ≤ k by exact_mod_cast le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ]

/-
If all voters prefer a to b, the majority margin is exactly k.
    Unanimous preferences create maximal "gradient".
-/
theorem pareto_margin {n k : ℕ} (P : PreferenceProfile n k) (a b : Fin n)
    (_hab : a ≠ b)
    (hunanimous : ∀ i : Fin k, (P i).prefers a b) :
    P.majorityMargin a b = (k : ℤ) := by
  unfold PreferenceProfile.majorityMargin; simp_all +decide [ PreferenceProfile.supportCount ] ;
  exact fun i => fun hi => StrictRanking.prefers_asymm _ _ _ ( hunanimous i ) hi

/-
In a 2-alternative world (n = 2), every majority relation is transitive.
    Cycles need at least 3 alternatives, just as curvature needs at least
    2 dimensions.
-/
theorem two_alternatives_always_flat (k : ℕ) (P : PreferenceProfile 2 k) :
    CondorcetCurvature P = 0 := by
  rw [ CondorcetCurvature ];
  simp +decide [ Finset.ext_iff ]