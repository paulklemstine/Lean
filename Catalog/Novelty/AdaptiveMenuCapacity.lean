import Novelty.StatisticRealizationBound

/-!
# Cycle 3: adaptive query policies cannot beat menu indistinguishability

Cycles 1–2 priced the oracle navigation sensor and showed that *static* residue policies realize
none of it.  The laboratory's strongest policies were **adaptive** (`ADAPTIVE-NB`), choosing the
next query in the light of earlier answers, so a complete account must cover adaptivity.

This file models an adaptive policy as a decision tree whose internal nodes are queries drawn
from a menu `M` of Boolean functions of the sample, and proves that adaptivity buys nothing
against indistinguishability: two samples that agree on every menu query receive the *same*
answer from every tree over that menu, of any depth, however it was fitted.  Instantiated at the
navigation sensor this yields: for every modulus `L` and threshold `B`, every adaptive residue
policy errs on one of two explicit semiprimes.

## Main results

* `QueryTree.eval_eq_of_menu_agree` : menu-indistinguishable samples get equal answers from any
  tree over the menu (induction on the tree);
* `QueryTree.errs_of_menu_agree` : hence every such tree errs on one of a pair whose target
  values differ;
* `QueryTree.numLeaves_le_two_pow_depth` : a depth-`k` tree has at most `2 ^ k` leaves, so it is
  measurable with respect to a statistic with at most `2 ^ k` classes — the capacity reading of
  the crediting law of `Novelty.StatisticRealizationBound`;
* `adaptive_residue_policy_errs` : the navigation-sensor instance — no adaptive residue policy,
  of any depth, matches the sensor on the whole semiprime population.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): adaptivity is irrelevant to the realization gap, because the gap is
caused by the *information* in the menu, not by the order in which it is read.

Experiment (Experimenter): the pair produced by `residue_menu_blind` (a prime square `p²` and a
semiprime `p·q₂` with `q₂ ≡ p mod L`) has identical residues modulo `L` and opposite sensor
values; every decision tree over residue queries therefore has accuracy exactly `1/2` on it —
the two-point analogue of the measured "strict crediting `0 %`".

Analysis (Analyst): the induction is short because indistinguishability propagates through the
branch: both samples take the same branch at every node.  This is the structural reason a
`z`-score of `+118` pooled can coexist with `z ≤ 2.3` within strata: pooling changes the target,
not the information.

Critique (Critic): a decision tree is the right model only if queries are deterministic
functions of the sample; randomized policies are not covered and would need an averaging
argument.  The depth bound is stated separately from the error bound, since the error bound
holds at *every* depth — including depth exceeding the menu size.
-/

namespace AdaptiveMenu

/-- An adaptive query policy: a decision tree whose nodes are Boolean queries. -/
inductive QueryTree (ι : Type*) where
  | leaf : Bool → QueryTree ι
  | node : (ι → Bool) → QueryTree ι → QueryTree ι → QueryTree ι

namespace QueryTree

variable {ι : Type*}

/-- Running the policy on a sample. -/
def eval : QueryTree ι → ι → Bool
  | leaf b, _ => b
  | node m t f, i => if m i then eval t i else eval f i

/-- All queries of the tree come from the menu `M`. -/
def Uses (M : Set (ι → Bool)) : QueryTree ι → Prop
  | leaf _ => True
  | node m t f => m ∈ M ∧ Uses M t ∧ Uses M f

/-- The number of leaves of the tree. -/
def numLeaves : QueryTree ι → ℕ
  | leaf _ => 1
  | node _ t f => numLeaves t + numLeaves f

/-- The depth of the tree. -/
def depth : QueryTree ι → ℕ
  | leaf _ => 0
  | node _ t f => max (depth t) (depth f) + 1

/-- **Capacity.**  A depth-`k` adaptive policy distinguishes at most `2 ^ k` outcomes. -/
theorem numLeaves_le_two_pow_depth (t : QueryTree ι) : t.numLeaves ≤ 2 ^ t.depth := by
  induction t with
  | leaf b => simp [numLeaves, depth]
  | node m l r ihl ihr =>
      have hl : l.numLeaves ≤ 2 ^ (max l.depth r.depth) :=
        ihl.trans (Nat.pow_le_pow_right (by norm_num) (le_max_left _ _))
      have hr : r.numLeaves ≤ 2 ^ (max l.depth r.depth) :=
        ihr.trans (Nat.pow_le_pow_right (by norm_num) (le_max_right _ _))
      simp only [numLeaves, depth, pow_succ]
      omega

/-- **Adaptivity buys nothing.**  Samples agreeing on every menu query receive the same answer
from every adaptive policy built from that menu. -/
theorem eval_eq_of_menu_agree {M : Set (ι → Bool)} (t : QueryTree ι) (ht : t.Uses M) {i j : ι}
    (hag : ∀ m ∈ M, m i = m j) : t.eval i = t.eval j := by
  induction t with
  | leaf b => rfl
  | node m l r ihl ihr =>
      obtain ⟨hm, hl, hr⟩ := ht
      have hmij : m i = m j := hag m hm
      simp only [eval, hmij]
      cases hmj : m j with
      | true => simpa using ihl hl
      | false => simpa using ihr hr

/-- Every adaptive policy over the menu errs on one member of an indistinguishable pair whose
target values differ. -/
theorem errs_of_menu_agree {M : Set (ι → Bool)} (s : ι → Bool) (t : QueryTree ι)
    (ht : t.Uses M) {i j : ι} (hag : ∀ m ∈ M, m i = m j) (hne : s i ≠ s j) :
    t.eval i ≠ s i ∨ t.eval j ≠ s j := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2⟩ := hcon
  exact hne (by rw [← h1, ← h2, eval_eq_of_menu_agree t ht hag])

end QueryTree

open OracleRealizationGap

/-- The residue menu modulo `L`: all queries "is `N ≡ r` mod `L`?" of the sample's value. -/
def residueMenu (L : ℕ) : Set (ℕ × ℕ → Bool) :=
  {m | ∃ r : ℕ, m = fun x => decide ((x.1 * x.2) % L = r)}

/-- **No adaptive residue policy realizes the navigation sensor.**  For every modulus `L ≠ 0`
and threshold `B` there are two semiprimes on which every adaptive policy built from residue
queries — of any depth, however fitted — makes a mistake. -/
theorem adaptive_residue_policy_errs (L B : ℕ) (hL : L ≠ 0) :
    ∃ p q₁ q₂ : ℕ, p.Prime ∧ q₁.Prime ∧ q₂.Prime ∧ q₁ ≠ q₂ ∧
      ∀ t : QueryTree (ℕ × ℕ), t.Uses (residueMenu L) →
        t.eval (p, q₁) ≠ sensor B p q₁ ∨ t.eval (p, q₂) ≠ sensor B p q₂ := by
  obtain ⟨p, q₁, q₂, hp, hq₁, hq₂, _, _, _, _, _, hmod, hlo, hhi⟩ :=
    residue_menu_blind L B hL
  have hne : q₁ ≠ q₂ := by
    intro h; rw [h] at hlo; omega
  refine ⟨p, q₁, q₂, hp, hq₁, hq₂, hne, ?_⟩
  intro t ht
  have hag : ∀ m ∈ residueMenu L, m (p, q₁) = m (p, q₂) := by
    rintro m ⟨r, rfl⟩
    have hres : (p * q₁) % L = (p * q₂) % L := hmod
    simp only [hres]
  refine QueryTree.errs_of_menu_agree (fun x => sensor B x.1 x.2) t ht hag ?_
  have hs₁ : sensor B p q₁ = true := by simp [sensor, hlo]
  have hs₂ : sensor B p q₂ = false := by
    simp only [sensor, decide_eq_false_iff_not, not_le]; omega
  simp [hs₁, hs₂]

end AdaptiveMenu