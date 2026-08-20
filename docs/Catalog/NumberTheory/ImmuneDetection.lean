import Catalog.Shared.ImmuneSemantics

/-!
# Algorithmic Immune System, Part III: the diagonal parasite and immune escape

This is the adversarial heart of the development.  A *behavioural detector* is a
program `d` of the parasite calculus which is itself harmless (`IsPure`) and
which, given the attestation tag of a program, returns a nonzero verdict exactly
on the programs it accuses (`Flags`).  Soundness = no false alarms, completeness
= no missed attacks.

We construct, for every pure detector `d`, the **diagonal parasite**

```
parasite d l = ite (call d inp) (pad l) attack
```

which feeds its own attestation tag to the detector and attacks precisely when it
is cleared.  From the single lemma `malicious_parasite_iff` we derive:

* `no_perfect_detector`    — no pure detector is both sound and complete
  (a Cohen/Rice-style undecidability of virus detection, fully formalised);
* `detector_dilemma`       — every pure detector has an explicit adversarial
  witness on which it errs;
* `sound_detector_misses`  / `complete_detector_false_alarms` — the two horns;
* `escape_set_infinite`    — a sound detector misses *infinitely many* genuinely
  malicious programs;
* `escape_card_exp`        — quantitatively: at least `2 ^ n` missed attacks of
  size at most `size d + 3n + 5`, i.e. the immune escape set has exponential
  density in program size;
* `immune_dichotomy`       — the boundary: detection is perfectly solvable on
  self-reference-free code (`staticScan`) and unsolvable in general.  Quining is
  exactly the source of the undecidability.
-/

namespace ImmuneSystem
namespace PAst

/-- A detector program is *pure* if running it never triggers the forbidden
action: the immune system must not itself be a parasite. -/
def IsPure (d : PAst) : Prop := ∀ x : ℕ, effect d x = false

/-- The verdict of detector `d` on program `t`: `d` is run on the attestation tag
of `t` and accuses `t` iff it returns a nonzero value. -/
def Flags (d t : PAst) : Prop := eval d (code t) ≠ 0

/-- No false alarms. -/
def Sound (d : PAst) : Prop := ∀ t : PAst, Flags d t → malicious t

/-- No missed attacks. -/
def Complete (d : PAst) : Prop := ∀ t : PAst, malicious t → Flags d t

/-- Running a pure detector on the self register has no effect and returns the
detector's verdict on the current input. -/
theorem effect_call_pure {d : PAst} (hd : IsPure d) (x : ℕ) :
    effect (call d inp) x = false := by
  simp [hd x]

/-- **Generic diagonal branch.**  For a pure detector `d`, the program that asks
`d` about its own code and then runs `A` (if accused) or `B` (if cleared) has
exactly the effect of the branch selected by the detector's verdict. -/
theorem effect_diagonal {d : PAst} (hd : IsPure d) (A B : PAst) (x : ℕ) :
    effect (ite (call d inp) A B) x = if eval d x ≠ 0 then effect A x else effect B x := by
  simp [effect_call_pure hd]

/-- The **diagonal parasite** with benign padding `l`: it consults the detector on
its own attestation tag and attacks exactly when the detector clears it. -/
def parasite (d : PAst) (l : List Bool) : PAst := ite (call d inp) (pad l) attack

theorem size_parasite (d : PAst) (l : List Bool) :
    size (parasite d l) = size d + 3 * l.length + 5 := by
  simp [parasite, size_pad]
  omega

theorem parasite_injective (d : PAst) : Function.Injective (parasite d) := by
  intro l l' h
  simp only [parasite, PAst.ite.injEq] at h
  exact pad_injective h.2.1

/-- The parasite is self-referential: it reads the input (self) register. -/
theorem parasite_not_inpFree (d : PAst) (l : List Bool) : inpFree (parasite d l) = false := by
  simp [parasite]

/-- **The diagonal identity.**  A parasite attacks precisely when the detector
fails to flag it. -/
theorem malicious_parasite_iff {d : PAst} (hd : IsPure d) (l : List Bool) :
    malicious (parasite d l) ↔ ¬ Flags d (parasite d l) := by
  unfold malicious run Flags parasite
  rw [effect_diagonal hd]
  simp

/-- **No perfect immune detector exists.**  There is no harmless program of the
calculus that decides maliciousness of arbitrary (self-modifying) programs. -/
theorem no_perfect_detector : ¬ ∃ d : PAst, IsPure d ∧ Sound d ∧ Complete d := by
  rintro ⟨d, hd, hs, hc⟩
  by_cases h : Flags d (parasite d [])
  · have hmal : malicious (parasite d []) := hs _ h
    exact ((malicious_parasite_iff hd []).1 hmal) h
  · have hmal : malicious (parasite d []) := (malicious_parasite_iff hd []).2 h
    exact h (hc _ hmal)

/-- **The detector dilemma.**  Every harmless detector has an explicit witness on
which it either raises a false alarm or misses a real attack. -/
theorem detector_dilemma {d : PAst} (hd : IsPure d) :
    ∃ p : PAst, (Flags d p ∧ ¬ malicious p) ∨ (¬ Flags d p ∧ malicious p) := by
  refine ⟨parasite d [], ?_⟩
  by_cases h : Flags d (parasite d [])
  · exact Or.inl ⟨h, fun hm => (malicious_parasite_iff hd []).1 hm h⟩
  · exact Or.inr ⟨h, (malicious_parasite_iff hd []).2 h⟩

/-- First horn: a detector with no false alarms misses every diagonal parasite. -/
theorem sound_detector_misses {d : PAst} (hd : IsPure d) (hs : Sound d) (l : List Bool) :
    malicious (parasite d l) ∧ ¬ Flags d (parasite d l) := by
  have hnf : ¬ Flags d (parasite d l) := by
    intro hf
    exact ((malicious_parasite_iff hd l).1 (hs _ hf)) hf
  exact ⟨(malicious_parasite_iff hd l).2 hnf, hnf⟩

/-- Second horn: a detector that misses no attack raises a false alarm on every
diagonal parasite (all of which are, thanks to the alarm, perfectly harmless). -/
theorem complete_detector_false_alarms {d : PAst} (hd : IsPure d) (hc : Complete d)
    (l : List Bool) : ¬ malicious (parasite d l) ∧ Flags d (parasite d l) := by
  by_cases h : Flags d (parasite d l)
  · exact ⟨fun hm => (malicious_parasite_iff hd l).1 hm h, h⟩
  · exact absurd (hc _ ((malicious_parasite_iff hd l).2 h)) h

/-- **Immune escape is infinite.**  A harmless detector without false alarms
misses infinitely many genuinely malicious programs. -/
theorem escape_set_infinite {d : PAst} (hd : IsPure d) (hs : Sound d) :
    {t : PAst | malicious t ∧ ¬ Flags d t}.Infinite := by
  have hinj : Function.Injective (fun n : ℕ => parasite d (List.replicate n true)) := by
    intro m n h
    have := parasite_injective d h
    simpa using congrArg List.length this
  have hmaps : Set.range (fun n : ℕ => parasite d (List.replicate n true))
      ⊆ {t : PAst | malicious t ∧ ¬ Flags d t} := by
    rintro t ⟨n, rfl⟩
    exact sound_detector_misses hd hs _
  exact Set.Infinite.mono hmaps (Set.infinite_range_of_injective hinj)

/-- **Exponential immune escape.**  For every `n`, a harmless sound detector
misses at least `2 ^ n` distinct malicious programs, all of size at most
`size d + 3n + 5`: evasion is not a rare accident but has exponential density in
program size. -/
theorem escape_card_exp {d : PAst} (hd : IsPure d) (hs : Sound d) (n : ℕ) :
    ∃ S : Finset PAst, S.card = 2 ^ n ∧
      ∀ t ∈ S, malicious t ∧ ¬ Flags d t ∧ size t ≤ size d + 3 * n + 5 := by
  classical
  refine ⟨Finset.image (fun v : Fin n → Bool => parasite d (List.ofFn v)) Finset.univ, ?_, ?_⟩
  · have hinj : Function.Injective (fun v : Fin n → Bool => parasite d (List.ofFn v)) :=
      Function.Injective.comp (parasite_injective d) List.ofFn_injective
    rw [Finset.card_image_of_injective _ hinj]
    simp
  · intro t ht
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at ht
    obtain ⟨v, rfl⟩ := ht
    obtain ⟨h1, h2⟩ := sound_detector_misses hd hs (List.ofFn v)
    refine ⟨h1, h2, ?_⟩
    rw [size_parasite]
    simp


/-! ### Non-vacuity and sharpness of the dichotomy

The impossibility theorem is not vacuous: harmless detectors exist in abundance,
and each of the two requirements (soundness, completeness) is separately
achievable.  Only their conjunction is impossible. -/

theorem isPure_lit (n : ℕ) : IsPure (lit n) := fun _ => rfl

/-- The attack program is malicious. -/
theorem malicious_attack : malicious attack := rfl

/-- The empty-padding diagonal parasite of the *silent* detector really does
attack: an explicit, executable instance of immune escape. -/
theorem malicious_parasite_lit_zero : malicious (parasite (lit 0) []) := by
  have := (malicious_parasite_iff (isPure_lit 0) [])
  refine this.2 ?_
  simp [Flags]

/-- The silent detector never raises a false alarm … -/
theorem sound_lit_zero : Sound (lit 0) := by
  intro t ht
  exact absurd rfl ht

/-- … but it misses the attack program, so it is not complete. -/
theorem not_complete_lit_zero : ¬ Complete (lit 0) := by
  intro hc
  exact (hc attack malicious_attack) rfl

/-- The paranoid detector misses nothing … -/
theorem complete_lit_one : Complete (lit 1) := by
  intro t _
  simp [Flags]

/-- … but it accuses the harmless constant program, so it is not sound. -/
theorem not_sound_lit_one : ¬ Sound (lit 1) := by
  intro hs
  have : malicious (lit 0) := hs (lit 0) (by simp [Flags])
  exact absurd this (by decide)

/-- **The internal/external gap.**  Maliciousness *is* decidable as a
mathematical predicate — the external interpreter decides it — yet no harmless
program of the calculus decides it.  The obstruction is therefore not a lack of
computational power but reflexivity: the detector is part of the world it must
describe. -/
theorem internal_external_gap :
    (∃ D : PAst → Bool, ∀ t : PAst, D t = true ↔ malicious t) ∧
      ¬ ∃ d : PAst, IsPure d ∧ Sound d ∧ Complete d :=
  ⟨⟨run, fun _ => Iff.rfl⟩, no_perfect_detector⟩

/-- **The immune dichotomy.**  Detection of maliciousness is *perfectly solvable*
for self-reference-free code — the static scanner is sound and complete there —
and *unsolvable* in general.  Self-reference (quining) is therefore exactly the
frontier of the algorithmic immune system's power. -/
theorem immune_dichotomy :
    (∀ t : PAst, inpFree t = true → (staticScan t = true ↔ malicious t)) ∧
      ¬ ∃ d : PAst, IsPure d ∧ Sound d ∧ Complete d :=
  ⟨fun _ h => staticScan_correct h, no_perfect_detector⟩

end PAst
end ImmuneSystem