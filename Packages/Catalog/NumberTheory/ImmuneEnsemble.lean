import Catalog.Shared.ImmuneAlgebra

/-!
# Algorithmic Immune System, Part VII: ensembles, voting and the arms race

A standard engineering response to Part III is *defence in depth*: run many
independent detectors and combine their verdicts.  We show this cannot work, in
a strong, quantitative form.

For a list `ds` of detector programs we build their disjunctive combination
`ensembleOr ds` **inside the calculus** (`ite d (lit 1) (rest)`), and prove:

* `isPure_ensembleOr`      — an ensemble of harmless detectors is harmless;
* `flags_ensembleOr_iff`   — the ensemble accuses exactly the union of the
  members' accusations;
* `sound_ensembleOr`       — an ensemble of sound detectors is sound;
* `ensemble_common_escape` — hence **one single malicious program defeats every
  member of the ensemble simultaneously**: majority voting, unanimity voting and
  any monotone combination inherit the failure;
* `ensemble_escape_card_exp` — there are at least `2 ^ n` such simultaneous
  escapes of size `≤ size (ensembleOr ds) + 3n + 5`;
* `ensemble_vote_zero`      — the vote count for the escaping parasite is `0`:
  the ensemble is not merely wrong, it is unanimously wrong;
* `arms_race`               — after blacklisting any finite set of known
  parasites, a fresh unflagged malicious program still exists.  Signature
  updates never terminate.
-/

namespace ImmuneSystem
namespace PAst

open Finset

instance (d t : PAst) : Decidable (Flags d t) := by unfold Flags; infer_instance

/-- Disjunctive combination of a list of detectors, written inside the calculus
itself. -/
def ensembleOr : List PAst → PAst
  | [] => lit 0
  | d :: ds => ite d (lit 1) (ensembleOr ds)

/-- An ensemble of harmless detectors is harmless. -/
theorem isPure_ensembleOr : ∀ {ds : List PAst}, (∀ d ∈ ds, IsPure d) → IsPure (ensembleOr ds) := by
  intro ds
  induction ds with
  | nil => intro _ x; rfl
  | cons d ds ih =>
      intro h x
      have hd : IsPure d := h d (List.mem_cons_self ..)
      have hds : IsPure (ensembleOr ds) := ih fun e he => h e (List.mem_cons_of_mem _ he)
      simp [ensembleOr, hd x, hds x]

@[simp] theorem ensembleOr_nil : ensembleOr [] = lit 0 := rfl

@[simp] theorem ensembleOr_cons (d : PAst) (ds : List PAst) :
    ensembleOr (d :: ds) = ite d (lit 1) (ensembleOr ds) := rfl

/-- Disjunction of verdicts, one step. -/
theorem flags_ite_lit_one (d e t : PAst) : Flags (ite d (lit 1) e) t ↔ Flags d t ∨ Flags e t := by
  unfold Flags
  by_cases hd : eval d (code t) = 0 <;> simp [hd]

/-- The ensemble accuses exactly the programs accused by at least one member. -/
theorem flags_ensembleOr_iff (t : PAst) :
    ∀ {ds : List PAst}, Flags (ensembleOr ds) t ↔ ∃ d ∈ ds, Flags d t := by
  intro ds
  induction ds with
  | nil => simp [Flags]
  | cons d ds ih =>
      rw [ensembleOr_cons, flags_ite_lit_one, ih]
      simp [List.mem_cons]

/-- An ensemble of sound detectors is sound. -/
theorem sound_ensembleOr {ds : List PAst} (h : ∀ d ∈ ds, Sound d) : Sound (ensembleOr ds) := by
  intro t ht
  obtain ⟨d, hd, hfd⟩ := (flags_ensembleOr_iff t).1 ht
  exact h d hd t hfd

/-- **Defence in depth fails.**  For any finite ensemble of harmless, false-alarm
free detectors there is a single malicious program that *every* member clears. -/
theorem ensemble_common_escape {ds : List PAst} (hp : ∀ d ∈ ds, IsPure d)
    (hs : ∀ d ∈ ds, Sound d) :
    ∃ p : PAst, malicious p ∧ ∀ d ∈ ds, ¬ Flags d p := by
  obtain ⟨hmal, hnf⟩ :=
    sound_detector_misses (isPure_ensembleOr hp) (sound_ensembleOr hs) []
  refine ⟨parasite (ensembleOr ds) [], hmal, ?_⟩
  intro d hd hfd
  exact hnf ((flags_ensembleOr_iff _).2 ⟨d, hd, hfd⟩)

/-- **Unanimously wrong.**  On the escaping parasite the ensemble's vote count is
zero: not a single detector raises the alarm, so no voting rule (majority,
threshold, unanimity, weighted) can rescue the ensemble. -/
theorem ensemble_vote_zero {ds : List PAst} (hp : ∀ d ∈ ds, IsPure d) (hs : ∀ d ∈ ds, Sound d) :
    ∃ p : PAst, malicious p ∧ (ds.filter (fun d => decide (Flags d p))).length = 0 := by
  obtain ⟨p, hmal, hno⟩ := ensemble_common_escape hp hs
  refine ⟨p, hmal, ?_⟩
  rw [List.length_eq_zero_iff, List.filter_eq_nil_iff]
  intro d hd hcontra
  exact hno d hd (of_decide_eq_true hcontra)

/-- **Exponentially many simultaneous escapes.**  The ensemble is defeated not by
one exotic program but by at least `2 ^ n` programs of size at most
`size (ensembleOr ds) + 3n + 5`. -/
theorem ensemble_escape_card_exp {ds : List PAst} (hp : ∀ d ∈ ds, IsPure d)
    (hs : ∀ d ∈ ds, Sound d) (n : ℕ) :
    ∃ S : Finset PAst, S.card = 2 ^ n ∧
      ∀ t ∈ S, malicious t ∧ (∀ d ∈ ds, ¬ Flags d t) ∧
        size t ≤ size (ensembleOr ds) + 3 * n + 5 := by
  obtain ⟨S, hcard, hprop⟩ :=
    escape_card_exp (isPure_ensembleOr hp) (sound_ensembleOr hs) n
  refine ⟨S, hcard, ?_⟩
  intro t ht
  obtain ⟨h1, h2, h3⟩ := hprop t ht
  exact ⟨h1, fun d hd hfd => h2 ((flags_ensembleOr_iff t).2 ⟨d, hd, hfd⟩), h3⟩

/-- **The arms race never ends.**  Whatever finite blacklist `B` of already known
parasites the immune system has accumulated, a harmless sound detector still
misses a malicious program outside `B`. -/
theorem arms_race {d : PAst} (hd : IsPure d) (hs : Sound d) (B : Finset PAst) :
    ∃ t : PAst, t ∉ B ∧ malicious t ∧ ¬ Flags d t := by
  have hinf := escape_set_infinite hd hs
  obtain ⟨t, ht, htB⟩ := (hinf.diff B.finite_toSet).nonempty
  exact ⟨t, htB, ht.1, ht.2⟩

end PAst
end ImmuneSystem