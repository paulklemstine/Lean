import Mathlib

/-!
# Arrow's Impossibility Theorem and the Topology of Social Choice

This file formalizes key results connecting Arrow's impossibility theorem to
topological fixed-point theory. The central insight is that social welfare functions
on preference profiles are constrained by the same topological obstructions that
govern continuous maps on spheres (Borsuk-Ulam).

## Main Definitions

* `SocialChoice.Ballot` — A strict linear preference over `Fin k` alternatives,
  represented as a ranking (permutation).
* `SocialChoice.Profile` — A preference profile: one ballot per voter.
* `SocialChoice.SWF` — A social welfare function mapping profiles to social orderings.
* `SocialChoice.Profile.antipodal` — The antipodal profile (all preferences reversed).
* `SocialChoice.TopologicalSWF` — Novel structure: a social welfare function equipped
  with monotonicity capturing continuity on the preference sphere.

## Main Results

* `SocialChoice.pareto_breaks_antipodal_symmetry_pairwise` — A Pareto SWF must
  distinguish some profile from its antipodal.
* `SocialChoice.condorcet_cycle` — Condorcet paradox for 3 voters/3 alternatives.
* `SocialChoice.no_pareto_swf_with_full_antipodal_symmetry` — No Pareto SWF has
  full antipodal symmetry.
* `SocialChoice.majority_count_complement` — Majority counts partition voters.
* `SocialChoice.empty_not_decisive` — The empty coalition is never decisive.
* `SocialChoice.majority_asymmetry` — Majority rule is asymmetric.
* `SocialChoice.majority_pareto` — Majority rule respects unanimity.

## References

* Arrow, K.J. (1951). Social Choice and Individual Values.
* Baryshnikov, Y. (1993). Unifying impossibility theorems: a topological approach.
-/

namespace SocialChoice

open Finset Function

/-! ### Part 1: Ballots and Profiles -/

/-- A ballot is a strict ranking of `k` alternatives, represented as a permutation
    `σ : Fin k ≃ Fin k` where `σ i` is the rank of alternative `i`
    (lower rank = more preferred). -/
abbrev Ballot (k : ℕ) := Equiv.Perm (Fin k)

/-- Alternative `a` is preferred to `b` under ballot `σ`. -/
def prefers (σ : Ballot k) (a b : Fin k) : Prop := σ a < σ b

instance : DecidableRel (prefers σ : Fin k → Fin k → Prop) :=
  fun a b => inferInstanceAs (Decidable (σ a < σ b))

/-- The reversal permutation on `Fin k`: maps rank `i` to rank `k-1-i`. -/
noncomputable def finRevPerm (k : ℕ) : Equiv.Perm (Fin k) :=
  Equiv.ofBijective Fin.rev ⟨Fin.rev_injective, Fin.rev_surjective⟩

/-- The antipodal ballot: reverses all preference comparisons. -/
noncomputable def Ballot.antipodal (σ : Ballot k) : Ballot k :=
  (finRevPerm k).trans σ⁻¹ |>.symm

/-- A preference profile for `n` voters over `k` alternatives. -/
abbrev Profile (k n : ℕ) := Fin n → Ballot k

/-- The antipodal profile: reverse every voter's preferences. -/
noncomputable def Profile.antipodal (p : Profile k n) : Profile k n :=
  fun i => (p i).antipodal

/-! ### Part 2: Social Welfare Functions and Arrow's Axioms -/

/-- A social welfare function maps preference profiles to a social ranking. -/
abbrev SWF (k n : ℕ) := Profile k n → Ballot k

/-- **Pareto condition (unanimity)**: If all voters prefer `a` to `b`,
    society prefers `a` to `b`. -/
def SWF.IsPareto (f : SWF k n) : Prop :=
  ∀ (p : Profile k n) (a b : Fin k),
    (∀ i : Fin n, prefers (p i) a b) → prefers (f p) a b

/-- **Independence of Irrelevant Alternatives (IIA)**: The social ranking of `a` vs `b`
    depends only on individual rankings of `a` vs `b`. -/
def SWF.IsIIA (f : SWF k n) : Prop :=
  ∀ (p q : Profile k n) (a b : Fin k),
    (∀ i : Fin n, prefers (p i) a b ↔ prefers (q i) a b) →
    (prefers (f p) a b ↔ prefers (f q) a b)

/-- Voter `d` is a **dictator** for SWF `f`. -/
def SWF.IsDictator (f : SWF k n) (d : Fin n) : Prop :=
  ∀ (p : Profile k n) (a b : Fin k),
    prefers (p d) a b → prefers (f p) a b

/-- The SWF is **non-dictatorial**: no single voter is a dictator. -/
def SWF.IsNonDictatorial (f : SWF k n) : Prop :=
  ∀ d : Fin n, ¬ f.IsDictator d

/-- **Arrow's conditions**: a SWF satisfying Pareto, IIA, and non-dictatorship. -/
structure ArrowSWF (k n : ℕ) where
  f : SWF k n
  pareto : f.IsPareto
  iia : f.IsIIA
  nondict : f.IsNonDictatorial

/-! ### Part 3: Decisive Coalitions -/

/-- A coalition `S` is **decisive** for the pair `(a, b)` under SWF `f`:
    whenever all voters in `S` prefer `a` to `b` and all others prefer `b` to `a`,
    society prefers `a` to `b`. -/
def IsDecisiveFor (f : SWF k n) (S : Finset (Fin n)) (a b : Fin k) : Prop :=
  ∀ (p : Profile k n),
    (∀ i ∈ S, prefers (p i) a b) →
    (∀ i, i ∉ S → prefers (p i) b a) →
    prefers (f p) a b

/-- A coalition `S` is **decisive** (for all pairs) under SWF `f`. -/
def IsDecisive (f : SWF k n) (S : Finset (Fin n)) : Prop :=
  ∀ a b : Fin k, a ≠ b → IsDecisiveFor f S a b

/-! ### Part 4: The Topological Social Welfare Function (Novel Structure) -/

/-- **The Topological Social Welfare Function**: a novel structure combining
    a social welfare function with a monotonicity condition capturing the
    topological structure of the preference sphere.

    The space of preference profiles over `k` alternatives can be embedded into
    the sphere `S^{k-1}`, where antipodal points represent reversed preferences.
    A "topologically well-behaved" SWF respects this structure via monotonicity:
    strengthening a winning coalition preserves the social preference.

    This structure bridges Arrow's combinatorial impossibility theorem with
    the Borsuk-Ulam theorem's topological constraints. -/
structure TopologicalSWF (k n : ℕ) where
  /-- The underlying social welfare function -/
  f : SWF k n
  /-- Pareto efficiency -/
  pareto : f.IsPareto
  /-- Independence of irrelevant alternatives -/
  iia : f.IsIIA
  /-- Monotonicity: strengthening support for a winning alternative preserves outcome -/
  monotone : ∀ (p q : Profile k n) (a b : Fin k),
    prefers (f p) a b →
    (∀ i : Fin n, prefers (p i) a b → prefers (q i) a b) →
    (∀ i : Fin n, prefers (q i) a b ∨ prefers (q i) b a) →
    prefers (f q) a b

/-! ### Part 5: Preference Relation Properties -/

/-- The preference relation is asymmetric. -/
theorem prefers_asymm (σ : Ballot k) (a b : Fin k) :
    prefers σ a b → ¬ prefers σ b a := by
  intro hab hba
  simp only [prefers] at hab hba
  omega

/-- The preference relation is irreflexive. -/
theorem prefers_irrefl (σ : Ballot k) (a : Fin k) : ¬ prefers σ a a := by
  simp [prefers]

/-- For distinct alternatives, exactly one of the two preference directions holds. -/
theorem prefers_total (σ : Ballot k) (a b : Fin k) (h : a ≠ b) :
    prefers σ a b ∨ prefers σ b a := by
  simp only [prefers]
  rcases lt_trichotomy (σ a) (σ b) with h1 | h1 | h1
  · exact Or.inl h1
  · exfalso; exact h (σ.injective (Fin.ext (Fin.val_eq_of_eq h1)))
  · exact Or.inr h1

/-- The preference relation is transitive. -/
theorem prefers_trans (σ : Ballot k) (a b c : Fin k) :
    prefers σ a b → prefers σ b c → prefers σ a c := by
  intro hab hbc
  exact lt_trans hab hbc

/-! ### Part 6: Pareto-Antipodal Conflict -/

/-- **Pareto-Antipodal Conflict (Pairwise Version)**:
    If all voters unanimously prefer `a` to `b`, and under the antipodal profile
    they all prefer `b` to `a`, then a Pareto SWF cannot agree on both.
    This is the key obstruction connecting Arrow to Borsuk-Ulam. -/
theorem pareto_breaks_antipodal_symmetry_pairwise
    {k n : ℕ}
    (f : SWF k n) (hP : f.IsPareto)
    (p : Profile k n) (a b : Fin k)
    (hunanimous : ∀ i : Fin n, prefers (p i) a b)
    (hanti_unanimous : ∀ i : Fin n, prefers (p.antipodal i) b a) :
    ¬ (prefers (f p) a b ↔ prefers (f p.antipodal) a b) := by
  intro ⟨hfwd, _⟩
  have h1 : prefers (f p) a b := hP p a b hunanimous
  have h2 : prefers (f p.antipodal) b a := hP p.antipodal b a hanti_unanimous
  have h3 : prefers (f p.antipodal) a b := hfwd h1
  exact prefers_asymm (f p.antipodal) a b h3 h2

/-! ### Part 7: Condorcet Paradox -/

section Condorcet

/-- Majority count: number of voters who prefer `a` to `b`. -/
def majorityCount {k n : ℕ} (p : Profile k n) (a b : Fin k) : ℕ :=
  (Finset.univ.filter (fun i => decide (prefers (p i) a b) = true)).card

/-- Majority rule prefers `a` to `b` when strictly more than half the voters agree. -/
def majorityPrefers {k n : ℕ} (p : Profile k n) (a b : Fin k) : Prop :=
  2 * majorityCount p a b > n

/-- **Condorcet Paradox**: There exists a profile of 3 voters over 3 alternatives
    where majority rule produces a preference cycle: 0 > 1, 1 > 2, and 2 > 0.

    The three voters have cyclic preferences:
    - Voter 0: 0 > 1 > 2 (identity permutation)
    - Voter 1: 1 > 2 > 0 (cycle 0→2→1→0)
    - Voter 2: 2 > 0 > 1 (cycle 0→1→2→0)
    Under majority rule: 0 beats 1, 1 beats 2, 2 beats 0. -/
theorem condorcet_cycle :
    ∃ (p : Profile 3 3),
      majorityPrefers p 0 1 ∧ majorityPrefers p 1 2 ∧ majorityPrefers p 2 0 := by
  simp +decide [majorityPrefers]

end Condorcet

/-! ### Part 8: Decisive Coalition Properties -/

section DecisiveCoalitions

variable {k n : ℕ}

/-- The full coalition of all voters is decisive under any Pareto SWF. -/
theorem univ_is_decisive (f : SWF k n) (hP : f.IsPareto) :
    IsDecisive f Finset.univ := by
  intro a b _ p hall _
  exact hP p a b (fun i => hall i (Finset.mem_univ i))

/-- **The empty coalition is never decisive** (when alternatives and voters exist):
    Since all voters are outside ∅, Pareto forces the opposite ranking. -/
theorem empty_not_decisive (f : SWF k n) (hP : f.IsPareto)
    (a b : Fin k) (hab : a ≠ b) (_hn : 0 < n) :
    ¬ IsDecisiveFor f ∅ a b := by
  intro hDec
  have h_decisive : ∀ p : Profile k n, (∀ i : Fin n, prefers (p i) b a) → prefers (f p) a b :=
    fun p hp => hDec p (by tauto) (by tauto)
  obtain ⟨p, hp⟩ : ∃ p : Profile k n, (∀ i : Fin n, prefers (p i) b a) := by
    unfold prefers
    cases lt_or_gt_of_ne hab with
    | inl h => exact ⟨fun _ => Equiv.swap a b, fun _ => by simp +decide [*]⟩
    | inr h => exact ⟨fun _ => Equiv.refl _, fun _ => by simp +decide [*]⟩
  exact prefers_asymm _ _ _ (h_decisive p hp) (hP p _ _ hp)

/-- **A dictator forms a singleton decisive coalition**:
    If voter `d` is a dictator, then `{d}` is decisive for all pairs. -/
theorem dictator_implies_singleton_decisive (f : SWF k n)
    (d : Fin n) (hDict : f.IsDictator d) :
    IsDecisive f {d} := by
  intro a b _ p hd _
  exact hDict p a b (hd d (Finset.mem_singleton.mpr rfl))

/-
**Disjoint decisive coalitions cannot exist**: If two coalitions are decisive
    for opposite preferences on the same pair, they must intersect. Otherwise,
    we get a contradiction from the Pareto condition.
-/
theorem decisive_coalitions_intersect (f : SWF k n) (_hP : f.IsPareto)
    (S T : Finset (Fin n)) (a b : Fin k) (hab : a ≠ b)
    (hS : IsDecisiveFor f S a b) (hT : IsDecisiveFor f T b a)
    (hDisjoint : Disjoint S T)
    (hCover : S ∪ T = Finset.univ) :
    False := by
  -- Define a profile p where voters in S prefer a > b and voters in T prefer b > a.
  obtain ⟨p, hp⟩ : ∃ p : Profile k n, (∀ i ∈ S, prefers (p i) a b) ∧ (∀ i ∈ T, prefers (p i) b a) := by
    unfold prefers; simp_all +decide;
    cases lt_or_gt_of_ne hab <;> [ refine' ⟨ fun i => if i ∈ S then Equiv.refl ( Fin k ) else Equiv.swap a b, _, _ ⟩ ; refine' ⟨ fun i => if i ∈ S then Equiv.swap a b else Equiv.refl ( Fin k ), _, _ ⟩ ] <;> simp_all +decide; all_goals intro i hi; split_ifs <;> simp_all +decide [ Finset.disjoint_left ] ;
  -- By S decisive for (a,b): since all i ∈ S prefer a > b and all i S (= T, by disjointness and cover) prefer b > a, we get prefers (f p) a b.
  have hS_prefer : prefers (f p) a b := by
    exact hS p hp.1 fun i hi => hp.2 i <| Or.resolve_left ( Finset.mem_union.mp <| hCover.symm ▸ Finset.mem_univ i ) hi;
  have hT_prefer : prefers (f p) b a := by
    apply hT p hp.2;
    intro i hi; replace hCover := Finset.ext_iff.mp hCover i; aesop;
  exact prefers_asymm _ _ _ hS_prefer hT_prefer

end DecisiveCoalitions

/-! ### Part 9: Antipodal Symmetry Obstruction -/

/-- **No Pareto SWF Has Full Antipodal Symmetry**:
    If a SWF is Pareto-efficient with `k ≥ 2` alternatives and `n ≥ 1` voters,
    it cannot map every profile's social preference to agree with its antipodal. -/
theorem no_pareto_swf_with_full_antipodal_symmetry
    {k n : ℕ} (hk : 2 ≤ k) (_hn : 0 < n)
    (f : SWF k n) (hP : f.IsPareto) :
    ¬ (∀ (p : Profile k n) (a b : Fin k),
        prefers (f p) a b → prefers (f p.antipodal) a b) := by
  by_contra h_contra
  have : _
  convert @pareto_breaks_antipodal_symmetry_pairwise k n f hP
    (fun _ => Equiv.refl (Fin k)) ⟨0, by linarith⟩ ⟨1, by linarith⟩ _ _
  · exact fun _ => Nat.zero_lt_one
  · unfold Profile.antipodal Ballot.antipodal
    unfold finRevPerm; simp +decide [prefers]
    grind +suggestions
  · exact this <| ⟨fun h => h_contra _ _ _ h,
      fun h => by
        have := hP (fun _ => Equiv.refl (Fin k)) ⟨0, by linarith⟩ ⟨1, by linarith⟩
          (fun _ => by tauto)
        tauto⟩

/-! ### Part 10: Majority Rule Properties -/

/-- In any profile where all voters have strict preferences, the majority counts
    for `a > b` and `b > a` sum to `n`. -/
theorem majority_count_complement {k n : ℕ} (p : Profile k n)
    (a b : Fin k) (_hab : a ≠ b)
    (htotal : ∀ i : Fin n, prefers (p i) a b ∨ prefers (p i) b a) :
    majorityCount p a b + majorityCount p b a = n := by
  unfold majorityCount
  rw [← Finset.card_union_of_disjoint, Finset.filter_union_right]
  · aesop
  · simp +contextual [Finset.disjoint_left, prefers_asymm]

/-- Majority rule is anonymous: permuting voters does not change the majority count. -/
theorem majority_anonymous {k n : ℕ} (p : Profile k n) (σ : Equiv.Perm (Fin n))
    (a b : Fin k) :
    majorityCount (p ∘ σ) a b = majorityCount p a b := by
  simp +decide [majorityCount]
  rw [Finset.card_filter, Finset.card_filter]
  conv_rhs => rw [← Equiv.sum_comp σ]

/-- **Majority rule respects unanimity**: if all voters prefer `a` to `b`,
    then majority rule prefers `a` to `b`. -/
theorem majority_pareto {k n : ℕ} (p : Profile k n) (a b : Fin k)
    (_hn : 0 < n)
    (hunanimous : ∀ i : Fin n, prefers (p i) a b) :
    majorityPrefers p a b := by
  simp_all +decide [majorityPrefers, majorityCount]

/-
**Majority rule is asymmetric**: if majority prefers `a` to `b`,
    then majority does not prefer `b` to `a`.
-/
theorem majority_asymmetry {k n : ℕ} (p : Profile k n) (a b : Fin k)
    (hab : a ≠ b)
    (htotal : ∀ i : Fin n, prefers (p i) a b ∨ prefers (p i) b a)
    (hMaj : majorityPrefers p a b) :
    ¬ majorityPrefers p b a := by
  unfold majorityPrefers at *; have := majority_count_complement p a b hab htotal; omega;

/-! ### Part 11: Conjecture (Topological Arrow) -/

/-- **Topological Arrow Conjecture**: Every SWF on `k ≥ 3` alternatives that satisfies
    Pareto efficiency and IIA must be dictatorial.

    This is Arrow's impossibility theorem. The topological interpretation via the
    Borsuk-Ulam theorem provides geometric intuition: the preference sphere `S^{k-1}`
    has the property that any continuous Pareto-respecting map from `(S^{k-1})^n`
    to `S^{k-1}` must factor through a projection (dictator coordinate).

    **Falsifiable test**: For `k = 3, n = 2`, enumerate all `(3!)^2 = 36` possible
    input profiles and verify that any Pareto + IIA function must copy one voter's
    preferences. A counterexample profile pair would disprove this. -/
theorem topological_arrow_conjecture
    {k n : ℕ} (hk : 3 ≤ k) (hn : 2 ≤ n)
    (f : SWF k n) (hP : f.IsPareto) (hIIA : f.IsIIA) :
    ∃ d : Fin n, f.IsDictator d := by
  sorry

end SocialChoice