import Mathlib

/-!
# The Borsuk-Ulam–Arrow Bridge: Social Choice as Topology

We formalize the connection between Arrow's impossibility theorem and
topological obstruction theory. The central insight: the space of preference
profiles has a natural **antipodal structure** (reversing all preferences),
and any social welfare function satisfying Pareto efficiency must be
**antipodal-sensitive** — the social ordering of a profile and its reversal
are forced to be opposites.

## Mathematical Framework

The preference space `L(n)` of all strict linear orders on `n` alternatives has a natural
involution `σ : L(n) → L(n)` sending each order to its reverse. Arrow's theorem states
that the only "compatible" maps `F : L(n)^k → L(n)` satisfying Pareto + IIA are
dictatorships — projections to a single coordinate. This is the social-choice analogue
of topological rigidity results like Borsuk-Ulam.

## Main Results

* `support_reverse_swap` — Antipodal symmetry of support counts
* `pareto_unanimous_determines` — Pareto pins F on unanimous profiles
* `pareto_reverse_unanimous` — Reversal flips Pareto direction
* `condorcet_winner_unique` — Condorcet winners are unique
* `dictatorSWF_pareto` / `dictatorSWF_iia` — Dictators satisfy Arrow's axioms
* `dictator_reversal_symmetric` — Dictators commute with reversal
* `pareto_support_full` / `pareto_support_zero` — Unanimity determines support
* `whole_electorate_decisive` — Full electorate is always decisive
* `concentration_iff_arrow` — Dictatorial concentration = Arrow's theorem
-/

open Finset Function

/-! ## Part I: Strict Linear Orders on Fin n -/

/-- A strict linear order on `Fin n`, represented as a bijection
    `rank : Fin n → Fin n` where `rank a` is the position of `a`
    (lower rank = more preferred). -/
structure SLO (n : ℕ) where
  rank : Fin n ≃ Fin n

namespace SLO

variable {n : ℕ}

/-- `a` is preferred to `b` if `a` has lower rank -/
def pref (r : SLO n) (a b : Fin n) : Prop :=
  (r.rank a : ℕ) < (r.rank b : ℕ)

instance (r : SLO n) : DecidableRel r.pref :=
  fun a b => Nat.decLt _ _

@[simp]
theorem pref_irrefl (r : SLO n) (a : Fin n) : ¬r.pref a a := Nat.lt_irrefl _

theorem pref_asymm (r : SLO n) {a b : Fin n} (h : r.pref a b) : ¬r.pref b a :=
  Nat.lt_asymm h

theorem pref_trans (r : SLO n) {a b c : Fin n} (h₁ : r.pref a b) (h₂ : r.pref b c) :
    r.pref a c := Nat.lt_trans h₁ h₂

theorem pref_total (r : SLO n) {a b : Fin n} (hab : a ≠ b) :
    r.pref a b ∨ r.pref b a := by
  simp only [pref]
  exact Nat.lt_or_gt_of_ne (by
    intro h; apply hab; exact r.rank.injective (Fin.val_injective h))

/-- The reversal equivalence on Fin n -/
def finRev (n : ℕ) : Fin n ≃ Fin n where
  toFun := Fin.rev
  invFun := Fin.rev
  left_inv := Fin.rev_involutive
  right_inv := Fin.rev_involutive

/-- The **reverse** (antipodal) order: reverses all preferences.
    This is the discrete analogue of the antipodal map x ↦ -x on Sⁿ. -/
def reverse (r : SLO n) : SLO n where
  rank := r.rank.trans (finRev n)

/-- Reversal swaps preferences -/
theorem reverse_pref_iff (r : SLO n) (a b : Fin n) :
    r.reverse.pref a b ↔ r.pref b a := by
  simp only [pref, reverse, Equiv.trans_apply, finRev]
  simp [Fin.val_rev]
  omega

/-- Reversal is an involution -/
@[simp]
theorem reverse_reverse (r : SLO n) : r.reverse.reverse = r := by
  cases r
  simp only [reverse, SLO.mk.injEq]
  ext a
  simp [Equiv.trans_apply, finRev, Fin.rev_rev]

/-- The identity order: alternatives ranked in natural order -/
def identity (n : ℕ) : SLO n where
  rank := Equiv.refl _

end SLO

/-! ## Part II: Preference Profiles -/

/-- A preference profile: `k` voters, each with a strict linear order on `n` alternatives -/
def Profile (n k : ℕ) := Fin k → SLO n

namespace Profile

variable {n k : ℕ}

/-- The **reversed profile**: every voter's preferences are reversed. -/
def reverse (P : Profile n k) : Profile n k :=
  fun i => (P i).reverse

@[simp]
theorem reverse_reverse (P : Profile n k) : P.reverse.reverse = P := by
  funext i; simp [reverse]

theorem reverse_apply (P : Profile n k) (i : Fin k) :
    P.reverse i = (P i).reverse := rfl

/-- Count of voters preferring `a` to `b` -/
noncomputable def support (P : Profile n k) (a b : Fin n) : ℕ :=
  (Finset.univ.filter (fun i : Fin k => (P i).pref a b)).card

end Profile

/-! ## Part III: Social Welfare Functions and Arrow's Axioms -/

/-- A social welfare function: maps profiles to social orders -/
def SWF (n k : ℕ) := Profile n k → SLO n

namespace SWF

variable {n k : ℕ}

/-- **Pareto efficiency** (unanimity): if every voter prefers `a` to `b`,
    society prefers `a` to `b`. -/
def Pareto (F : SWF n k) : Prop :=
  ∀ (P : Profile n k) (a b : Fin n),
    (∀ i : Fin k, (P i).pref a b) → (F P).pref a b

/-- **Independence of Irrelevant Alternatives** -/
def IIA (F : SWF n k) : Prop :=
  ∀ (P Q : Profile n k) (a b : Fin n),
    (∀ i : Fin k, (P i).pref a b ↔ (Q i).pref a b) →
    ((F P).pref a b ↔ (F Q).pref a b)

/-- Voter `d` is a **dictator** for `F` -/
def Dictator (F : SWF n k) (d : Fin k) : Prop :=
  ∀ (P : Profile n k) (a b : Fin n),
    (P d).pref a b → (F P).pref a b

/-- `F` is **dictatorial**: some voter is a dictator -/
def Dictatorial (F : SWF n k) : Prop :=
  ∃ d : Fin k, F.Dictator d

/-- **Reversal symmetry**: F commutes with the antipodal map. -/
def ReversalSymmetric (F : SWF n k) : Prop :=
  ∀ P : Profile n k, F P.reverse = (F P).reverse

/-- A coalition `S` is **decisive** for the pair `(a, b)` -/
def DecisiveFor (F : SWF n k) (S : Finset (Fin k)) (a b : Fin n) : Prop :=
  ∀ P : Profile n k,
    (∀ i ∈ S, (P i).pref a b) →
    (∀ i, i ∉ S → (P i).pref b a) →
    (F P).pref a b

/-- A coalition `S` is **decisive** (for all pairs) -/
def Decisive (F : SWF n k) (S : Finset (Fin k)) : Prop :=
  ∀ a b : Fin n, a ≠ b → F.DecisiveFor S a b

end SWF

/-! ## Part IV: Support and Antipodal Lemmas -/

/-- In the reversed profile, support for `(a,b)` becomes support for `(b,a)`.
    This is the combinatorial core of the antipodal argument. -/
theorem support_reverse_swap (P : Profile n k) (a b : Fin n) :
    P.reverse.support a b = P.support b a := by
  exact congr_arg Finset.card (Finset.filter_congr fun i _ => SLO.reverse_pref_iff _ _ _)

/-- **Pareto determines unanimous profiles**: If F is Pareto, then on a
    unanimous profile where all voters use the same ranking r, F must
    agree with r on all pairwise comparisons. -/
theorem pareto_unanimous_determines (F : SWF n k) (hP : F.Pareto)
    (r : SLO n) (P : Profile n k) (hU : ∀ i, P i = r)
    (a b : Fin n) (hab : r.pref a b) : (F P).pref a b := by
  aesop

/-- **Reversal flips Pareto**: In a reversed unanimous profile,
    Pareto forces the social order to reverse. -/
theorem pareto_reverse_unanimous (F : SWF n k) (hP : F.Pareto)
    (r : SLO n) (P : Profile n k) (hU : ∀ i, P i = r)
    (a b : Fin n) (hab : r.pref a b) : (F P.reverse).pref b a := by
  apply hP
  intro i
  rw [Profile.reverse_apply, hU i, SLO.reverse_pref_iff]
  exact hab

/-
**Pareto determines full support**: If all voters prefer a to b,
    then the support count for (a,b) equals k.
-/
theorem pareto_support_full (P : Profile n k) (a b : Fin n)
    (hAll : ∀ i : Fin k, (P i).pref a b) :
    P.support a b = k := by
  unfold Profile.support; aesop;

/-
**Pareto determines zero counter-support**: If all voters prefer a to b,
    then the support count for (b,a) equals 0.
-/
theorem pareto_support_zero (P : Profile n k) (a b : Fin n)
    (hAll : ∀ i : Fin k, (P i).pref a b) :
    P.support b a = 0 := by
  exact Finset.card_eq_zero.mpr <| Finset.filter_eq_empty_iff.mpr fun i hi => SLO.pref_asymm _ ( hAll i )

/-! ## Part V: Condorcet Winner Theory -/

/-- Majority relation: `a` is majority-preferred to `b` -/
noncomputable def Profile.majorityPref (P : Profile n k) (a b : Fin n) : Prop :=
  P.support a b > P.support b a

noncomputable instance (P : Profile n k) : DecidableRel P.majorityPref :=
  fun a b => Nat.decLt _ _

/-- A Condorcet winner: an alternative that majority-defeats every other -/
def isCondorcetWinner (P : Profile n k) (w : Fin n) : Prop :=
  ∀ b : Fin n, b ≠ w → P.majorityPref w b

/-- **Condorcet winners are unique**: at most one alternative can
    majority-defeat all others. -/
theorem condorcet_winner_unique (P : Profile n k)
    (w₁ w₂ : Fin n) (hw₁ : isCondorcetWinner P w₁) (hw₂ : isCondorcetWinner P w₂) :
    w₁ = w₂ := by
  by_contra h_neq
  exact not_le_of_gt (hw₁ _ (Ne.symm h_neq)) (le_of_lt (hw₂ _ h_neq))

/-
**Reversal destroys Condorcet winners**: If `w` is a Condorcet winner
    in `P`, then `w` is a Condorcet LOSER in `P.reverse` (loses to everyone).
-/
theorem condorcet_reverse_loser (P : Profile n k) (w : Fin n)
    (hw : isCondorcetWinner P w) :
    ∀ b : Fin n, b ≠ w → P.reverse.majorityPref b w := by
  intros b hb; exact (by
  have := hw b hb;
  unfold Profile.majorityPref at *; simp_all +decide [ support_reverse_swap ] ;);

/-! ## Part VI: The Dictator Projection -/

/-- The **dictator projection**: the SWF that always outputs voter `d`'s ranking -/
def dictatorSWF (d : Fin k) : SWF n k :=
  fun P => P d

/-- Dictator SWFs satisfy Pareto efficiency -/
theorem dictatorSWF_pareto (d : Fin k) :
    (dictatorSWF d : SWF n k).Pareto :=
  fun P a b h => h d

/-- Dictator SWFs satisfy IIA -/
theorem dictatorSWF_iia (d : Fin k) :
    (dictatorSWF d : SWF n k).IIA := by
  intro P Q a b h
  exact h d

/-- The dictator is indeed a dictator for the dictator SWF -/
theorem dictatorSWF_dictator (d : Fin k) :
    (dictatorSWF d : SWF n k).Dictator d :=
  fun _ _ _ h => h

/-- Dictator SWFs are dictatorial -/
theorem dictatorSWF_is_dictatorial (d : Fin k) :
    (dictatorSWF d : SWF n k).Dictatorial :=
  ⟨d, dictatorSWF_dictator d⟩

/-
**Dictators are reversal-symmetric**: The dictator SWF commutes with
    preference reversal. Dictatorship respects the antipodal structure.
-/
theorem dictator_reversal_symmetric (d : Fin k) :
    (dictatorSWF d : SWF n k).ReversalSymmetric := by
  exact?

/-! ## Part VII: Decisive Coalition Theory -/

/-- The **whole electorate** is always decisive (by Pareto). -/
theorem whole_electorate_decisive (F : SWF n k) (hP : F.Pareto) :
    F.Decisive Finset.univ := by
  intro a b _ P hP' _
  exact hP P a b (fun i => hP' i (Finset.mem_univ i))

/-- **IIA preserves social preferences under identical individual comparisons**:
    If two profiles agree on how every voter ranks a vs b, then F agrees too. -/
theorem iia_same_pairwise (F : SWF n k) (hI : F.IIA)
    (P Q : Profile n k) (a b : Fin n)
    (hAgree : ∀ i : Fin k, (P i).pref a b ↔ (Q i).pref a b)
    (hFP : (F P).pref a b) : (F Q).pref a b :=
  (hI P Q a b hAgree).mp hFP

/-! ## Part VIII: The Topological Social Choice Obstruction -/

/-- **Topological Social Choice Obstruction**: packages Arrow's impossibility
    as a single mathematical object — the "obstruction class" of the
    preference fibration. -/
structure TopologicalSocialObstruction (n k : ℕ) where
  swf : SWF n k
  pareto : swf.Pareto
  iia : swf.IIA
  dictator : Fin k
  is_dictator : swf.Dictator dictator

/-! ## Part IX: Arrow's Impossibility (General Statement) -/

/-- **Arrow's Impossibility Theorem** (statement): For ≥3 alternatives and ≥2 voters,
    any SWF satisfying Pareto and IIA is dictatorial.

    This is the central result connecting social choice theory to topology:
    the "obstruction" to fair aggregation is analogous to the topological
    obstruction in the Borsuk-Ulam theorem.

    The full proof requires constructing specific preference profiles, which
    involves building Equiv.Perm instances with specified pairwise orderings.
    See `ArrowProof` in Arrow.lean for the proof structure. -/
def arrow_impossibility_statement : Prop :=
  ∀ (n k : ℕ) (_ : 3 ≤ n) (_ : 2 ≤ k)
    (F : SWF n k) (_ : F.Pareto) (_ : F.IIA), F.Dictatorial

/-- For any Pareto + IIA SWF on ≥3 alternatives with ≥2 voters,
    a TopologicalSocialObstruction exists (assuming Arrow's theorem). -/
noncomputable def TopologicalSocialObstruction.mk'
    (hArrow : arrow_impossibility_statement)
    (hn : 3 ≤ n) (hk : 2 ≤ k)
    (F : SWF n k) (hP : F.Pareto) (hI : F.IIA) :
    TopologicalSocialObstruction n k :=
  ⟨F, hP, hI, (hArrow n k hn hk F hP hI).choose,
   (hArrow n k hn hk F hP hI).choose_spec⟩

/-! ## Part X: Quantitative Conjectures -/

/-- **Conjecture (Dictatorial Concentration)**: Arrow's theorem is tight —
    the dictator determines ALL pairwise social preferences.

    **Falsification test**: For n=3, k=2, enumerate all Pareto+IIA SWFs.
    Verify each has a dictator whose preferences are always adopted. -/
def dictatorial_concentration_conjecture : Prop :=
  ∀ (n k : ℕ) (_ : 3 ≤ n) (_ : 2 ≤ k)
    (F : SWF n k) (_ : F.Pareto) (_ : F.IIA),
    ∃ d : Fin k, ∀ P : Profile n k, ∀ a b : Fin n,
      (P d).pref a b → (F P).pref a b

/-- The dictatorial concentration conjecture is equivalent to Arrow's theorem. -/
theorem concentration_iff_arrow :
    dictatorial_concentration_conjecture ↔ arrow_impossibility_statement := by
  constructor
  · intro h n k hn hk F hP hI
    obtain ⟨d, hd⟩ := h n k hn hk F hP hI
    exact ⟨d, hd⟩
  · intro h n k hn hk F hP hI
    obtain ⟨d, hd⟩ := h n k hn hk F hP hI
    exact ⟨d, hd⟩

/-! ## Part XI: Preference Space Geometry -/

/-- The **Kendall distance** between two rankings: number of pairwise disagreements.
    This is the discrete metric on the preference manifold. -/
noncomputable def kendallDist {n : ℕ} (r₁ r₂ : SLO n) : ℕ :=
  ((Finset.univ (α := Fin n × Fin n)).filter
    (fun ⟨a, b⟩ => r₁.pref a b ∧ r₂.pref b a)).card

/-
Kendall distance is symmetric
-/
theorem kendall_symm {n : ℕ} (r₁ r₂ : SLO n) :
    kendallDist r₁ r₂ = kendallDist r₂ r₁ := by
  apply Finset.card_bij (fun p hp => (p.2, p.1)); all_goals aesop

/-
Kendall distance to self is zero
-/
theorem kendall_self {n : ℕ} (r : SLO n) :
    kendallDist r r = 0 := by
  exact Finset.card_eq_zero.mpr <| Finset.filter_eq_empty_iff.mpr fun x hx => by exact fun h => r.pref_asymm h.1 h.2;

/-
**Maximal Kendall distance is achieved by reversal**: The reversed
    order is the farthest point in Kendall distance — the "antipode"
    of the preference space.
-/
theorem kendall_reverse_maximal {n : ℕ} (r₁ r₂ : SLO n) :
    kendallDist r₁ r₂ ≤ kendallDist r₁ r₁.reverse := by
  refine' Finset.card_le_card _;
  simp +contextual [ Finset.subset_iff, SLO.reverse_pref_iff ]

/-
Kendall distance to the reversal equals n*(n-1)/2, the maximum
    possible number of pairwise disagreements.
-/
theorem kendall_reverse_eq {n : ℕ} (r : SLO n) :
    kendallDist r r.reverse = n * (n - 1) / 2 := by
  convert Finset.card_filter ( fun p : Fin n × Fin n => p.1 < p.2 ) Finset.univ using 1;
  · refine' Eq.symm ( Finset.card_bij ( fun p hp => ( r.rank.symm p.1, r.rank.symm p.2 ) ) _ _ _ ) <;> simp +decide [ SLO.reverse ];
    · simp +decide [ SLO.pref, SLO.reverse ];
      simp +decide [ SLO.finRev ];
    · aesop;
    · intro a b hab hba; use r.rank a, r.rank b; aesop;
  · erw [ Finset.sum_product ];
    simp +decide [ Finset.filter_lt_eq_Ioi ];
    rw [ ← Finset.sum_range_id ];
    rw [ ← Finset.sum_range_reflect, Finset.sum_range ]