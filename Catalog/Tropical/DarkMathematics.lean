import Mathlib

/-!
# Dark mathematics: an abstract provability analysis

The proposed notion is studied relative to an abstract proof predicate `Pr`.  The only
closure principle assumed is that a proof can be transported along a metatheoretically
valid implication.  This isolates the logical content from any particular arithmetization
of PA.
-/

namespace DarkMathematics

/-- A minimal closure property of a proof predicate: valid proof transformations preserve
provability. -/
class ProofTransport (Pr : Prop → Prop) : Prop where
  map {P Q : Prop} : (P → Q) → Pr P → Pr Q

/-- `T` is dark: its existential closure is provable, but no named instance is. -/
def Dark (Pr : Prop → Prop) (T : α → Prop) : Prop :=
  Pr (∃ x, T x) ∧ ∀ x, ¬ Pr (T x)

/-- Level `k` darkness asks for a provable family of `k` distinct witnesses, while still
forbidding a proof of any named instance. -/
def DarkLevel (Pr : Prop → Prop) (k : ℕ) (T : α → Prop) : Prop :=
  Pr (∃ f : Fin k → α, Function.Injective f ∧ ∀ i, T (f i)) ∧
    ∀ x, ¬ Pr (T x)

/-- Tagging each possible witness with `Fin k` amplifies one dark existential to every
finite level. -/
def tagged (T : α → Prop) (p : Fin k × α) : Prop := T p.2

/-
The basic notion is exactly level-one darkness.
-/
theorem dark_iff_level_one [ProofTransport Pr] :
    Dark Pr T ↔ DarkLevel Pr 1 T := by
  constructor;
  · intro h;
    refine' ⟨ _, h.2 ⟩;
    convert ‹ProofTransport Pr›.map _ h.1;
    exact fun ⟨ x, hx ⟩ => ⟨ fun _ => x, by simp +decide [ Function.Injective ], fun _ => hx ⟩;
  · exact fun h => ⟨ by simpa using ( ‹ProofTransport Pr›.map ( by aesop_cat ) h.1 ), h.2 ⟩

/-
**Hierarchy-collapse theorem.** Every dark predicate uniformly yields a level-`k`
dark predicate, merely by tagging a hidden witness `k` times.  Thus witness count alone
does not define a strict hierarchy of logical strength.
-/
theorem dark_amplifies_to_every_level [ProofTransport Pr]
    (h : Dark Pr T) (k : ℕ) : DarkLevel Pr k (tagged (k := k) T) := by
  obtain ⟨h₁, h₂⟩ := h;
  constructor;
  · grind +splitIndPred;
  · exact fun x => h₂ x.2

/-
Higher levels imply lower levels on the same predicate.
-/
theorem darkLevel_mono [ProofTransport Pr] {k l : ℕ} (hkl : k ≤ l)
    (h : DarkLevel Pr l T) : DarkLevel Pr k T := by
  refine' ⟨ _, _ ⟩;
  · convert ‹ProofTransport Pr›.map _ h.1;
    exact fun ⟨ f, hf₁, hf₂ ⟩ => ⟨ fun i => f ⟨ i, by linarith [ Fin.is_lt i ] ⟩, hf₁.comp fun i j hij => by simpa [ Fin.ext_iff ] using hij, fun i => hf₂ _ ⟩;
  · exact h.2

/-- A theory with a numerical existence property cannot have dark predicates.
This pinpoints the missing metatheoretic feature: classical PA lacks this property for
arbitrary formulas. -/
def NumericalExistenceProperty (Pr : Prop → Prop) : Prop :=
  ∀ (T : ℕ → Prop), Pr (∃ n, T n) → ∃ n, Pr (T n)

theorem no_dark_of_numericalExistenceProperty
    (hnep : NumericalExistenceProperty Pr) (T : ℕ → Prop) :
    ¬ Dark Pr T := by
  exact fun h => by obtain ⟨ n, hn ⟩ := hnep T h.1; exact h.2 n hn;

/-- Splitting an undecided sentence into two cases gives the canonical abstract dark
predicate. -/
def split (U : Prop) : Bool → Prop
  | false => U
  | true => ¬ U

/-
If a theory proves excluded middle for `U` but decides neither side, `split U` is
dark.  This is incompleteness in an existential disguise.
-/
theorem split_is_dark [ProofTransport Pr] {U : Prop}
    (hem : Pr (U ∨ ¬ U)) (hU : ¬ Pr U) (hnU : ¬ Pr (¬ U)) :
    Dark Pr (split U) := by
  constructor <;> simp_all +decide
  · exact ProofTransport.map (fun h => h) hem
  · exact ⟨hU, hnU⟩

/-
Consequently the split construction gives levels 1, 2, and 3 (indeed every level)
without any stronger independence phenomenon.
-/
theorem split_is_dark_at_every_level [ProofTransport Pr] {U : Prop}
    (hem : Pr (U ∨ ¬ U)) (hU : ¬ Pr U) (hnU : ¬ Pr (¬ U)) (k : ℕ) :
    DarkLevel Pr k (tagged (k := k) (split U)) := by
  grind +splitIndPred

/-- With ordinary semantic truth as the "proof" predicate, darkness is impossible:
an existential witness itself supplies a true named instance. -/
theorem no_semantic_darkness (T : α → Prop) :
    ¬ Dark (fun P => P) T := by
  rintro ⟨⟨a, ha⟩, hnone⟩
  exact hnone a ha

/-- Soundness plus completeness for the individual instances rules out darkness.  This
makes precise that darkness requires incompleteness rather than a new phenomenon beyond
it. -/
theorem no_dark_of_sound_instance_complete
    (sound : ∀ P, Pr P → P) (complete : ∀ x, T x → Pr (T x)) :
    ¬ Dark Pr T := by
  rintro ⟨hex, hnone⟩
  obtain ⟨x, hx⟩ := sound _ hex
  exact hnone x (complete x hx)

/-- No predicate with a provable named instance can be dark.  In particular, a family
all of whose concrete finite instances are PA-provable cannot itself supply the proposed
example. -/
theorem provable_instance_refutes_dark (T : α → Prop) (a : α)
    (ha : Pr (T a)) : ¬ Dark Pr T := by
  exact fun h => h.2 a ha

end DarkMathematics