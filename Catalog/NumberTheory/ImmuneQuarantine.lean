import Catalog.Shared.ImmuneDetection

/-!
# Algorithmic Immune System, Part IV: attestation, quarantine and neutralization

Part III showed that *behavioural* detection of malice is impossible.  This part
shows what an immune system can nevertheless guarantee, and at what price.

The immune system is a **structural attestation monitor**: it stores a finite set
`tags` of attestation tags (Part I's Gödel numbers) of sanctioned program
variants and, after every mutation step of an *arbitrary, unknown, adversarial*
self-modification `adv : ℕ → PAst → PAst`, either accepts the mutant (its tag is
sanctioned) or rolls back to the trusted baseline.

Main results:

* `verify_iff_mem` — tag-based verification is exactly membership in the
  sanctioned set: attestation has **no collisions** (uses `code_injective`);
* `quarantine_mem`, `quarantine_idem` — quarantine is an idempotent retraction
  onto the sanctioned set;
* `trace_mem` — **containment**: whatever the adversary does, at every time step
  the running program is sanctioned;
* `neutralization` — **the headline theorem**: if every sanctioned variant is
  harmless, then no forbidden action is ever executed, for every adversary and
  all time;
* `alarm_iff_escape`, `rollback` — detection is *complete*: every unsanctioned
  mutation, however unknown, raises an alarm at the step it occurs and is
  reverted immediately;
* `finite_whitelist_rejects_benign`, `benign_rejection_card` — **the price**: any
  finite attestation whitelist rejects infinitely many, and at least
  `2 ^ n - |S|` of size `≤ 3n+1`, semantically benign refactorings;
* `immune_conservation` — the synthesis: perfect containment, exponential
  rigidity, and no perfect behavioural detector, in one statement.
-/

namespace ImmuneSystem
namespace PAst

open Finset

section Attestation

variable (S : Finset PAst)

/-- The attestation database: the tags of the sanctioned variants. -/
def tags : Finset ℕ := S.image code

/-- The monitor's verification step: recompute the tag of the running AST and
look it up in the attestation database. -/
def verify (t : PAst) : Prop := code t ∈ tags S

instance (t : PAst) : Decidable (verify S t) := by
  unfold verify; infer_instance

/-- **Attestation is collision-free.**  Tag verification is equivalent to genuine
membership of the sanctioned set — a direct consequence of injectivity of the
Gödel numbering (Part I). -/
theorem verify_iff_mem (t : PAst) : verify S t ↔ t ∈ S := by
  unfold verify tags
  constructor
  · intro h
    obtain ⟨s, hs, hcode⟩ := Finset.mem_image.1 h
    rwa [code_injective hcode] at hs
  · intro h
    exact Finset.mem_image.2 ⟨t, h, rfl⟩

end Attestation

/-- The quarantine operator: accept a sanctioned mutant, otherwise roll back to
the trusted baseline `b`. -/
def quarantine (S : Finset PAst) (b t : PAst) : PAst := if t ∈ S then t else b

theorem quarantine_of_mem {S : Finset PAst} {b t : PAst} (h : t ∈ S) :
    quarantine S b t = t := by simp [quarantine, h]

theorem quarantine_of_not_mem {S : Finset PAst} {b t : PAst} (h : t ∉ S) :
    quarantine S b t = b := by simp [quarantine, h]

/-- Quarantine always lands in the sanctioned set. -/
theorem quarantine_mem {S : Finset PAst} {b : PAst} (hb : b ∈ S) (t : PAst) :
    quarantine S b t ∈ S := by
  by_cases h : t ∈ S
  · rwa [quarantine_of_mem h]
  · rwa [quarantine_of_not_mem h]

/-- Quarantine is idempotent: it is a retraction of the space of ASTs onto the
sanctioned set. -/
theorem quarantine_idem {S : Finset PAst} {b : PAst} (hb : b ∈ S) (t : PAst) :
    quarantine S b (quarantine S b t) = quarantine S b t :=
  quarantine_of_mem (quarantine_mem hb t)

theorem quarantine_eq_self_iff {S : Finset PAst} {b t : PAst} (hb : b ∈ S) :
    quarantine S b t = t ↔ t ∈ S := by
  constructor
  · intro h; rw [← h]; exact quarantine_mem hb t
  · exact quarantine_of_mem

/-- The guarded execution trace under an **arbitrary, unknown, time-dependent
self-modification** `adv`.  At each step the adversary rewrites the running AST
however it likes; the monitor then verifies and, if necessary, rolls back. -/
def trace (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) : ℕ → PAst
  | 0 => b
  | n + 1 => quarantine S b (adv n (trace S b adv n))

@[simp] theorem trace_zero (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) :
    trace S b adv 0 = b := rfl

@[simp] theorem trace_succ (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (n : ℕ) :
    trace S b adv (n + 1) = quarantine S b (adv n (trace S b adv n)) := rfl

/-- **Containment.**  For every adversary and every time step the running program
lies in the sanctioned set. -/
theorem trace_mem {S : Finset PAst} {b : PAst} (hb : b ∈ S) (adv : ℕ → PAst → PAst) :
    ∀ n, trace S b adv n ∈ S := by
  intro n
  induction n with
  | zero => simpa using hb
  | succ n _ => exact quarantine_mem hb _

/-- **Neutralization theorem.**  If every sanctioned variant is harmless then, for
*every* unknown malicious self-modifying adversary and at *every* time step, the
running program is harmless: the forbidden action is never executed. -/
theorem neutralization {S : Finset PAst} {b : PAst} (hb : b ∈ S)
    (hsafe : ∀ t ∈ S, ¬ malicious t) (adv : ℕ → PAst → PAst) (n : ℕ) :
    ¬ malicious (trace S b adv n) :=
  hsafe _ (trace_mem hb adv n)

/-- The alarm raised by the monitor at step `n`. -/
def alarm (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (n : ℕ) : Prop :=
  ¬ verify S (adv n (trace S b adv n))

/-- **Detection completeness.**  The alarm at step `n` fires exactly when the
adversary's mutation leaves the sanctioned set — no unsanctioned mutation,
however unknown, goes unnoticed, and no sanctioned one triggers a false alarm. -/
theorem alarm_iff_escape (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (n : ℕ) :
    alarm S b adv n ↔ adv n (trace S b adv n) ∉ S := by
  unfold alarm
  rw [verify_iff_mem]

/-- **Immediate rollback.**  Whenever an alarm fires the system is restored to the
trusted baseline in the very same step; otherwise the sanctioned mutation is
accepted verbatim. -/
theorem rollback (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (n : ℕ) :
    (alarm S b adv n → trace S b adv (n + 1) = b) ∧
      (¬ alarm S b adv n → trace S b adv (n + 1) = adv n (trace S b adv n)) := by
  constructor
  · intro h
    exact quarantine_of_not_mem ((alarm_iff_escape S b adv n).1 h)
  · intro h
    exact quarantine_of_mem (not_not.1 (fun hn => h ((alarm_iff_escape S b adv n).2 hn)))

/-- A mutation that only ever produces sanctioned variants is never disturbed:
the immune system is transparent to legitimate updates. -/
theorem trace_of_sanctioned {S : Finset PAst} {b : PAst} (adv : ℕ → PAst → PAst)
    (h : ∀ n t, adv n t ∈ S) (n : ℕ) :
    trace S b adv (n + 1) = adv n (trace S b adv n) :=
  quarantine_of_mem (h _ _)

/-! ### The price of structural attestation

Attestation is *syntactic*, while program behaviour is *semantic*.  The gap is
not a small one: any finite whitelist rejects an infinite, indeed exponentially
dense, family of semantically identical benign programs. -/

/-- The `n`-bit family of benign padded variants. -/
noncomputable def padFamily (n : ℕ) : Finset PAst :=
  Finset.image (fun v : Fin n → Bool => pad (List.ofFn v)) Finset.univ

theorem card_padFamily (n : ℕ) : (padFamily n).card = 2 ^ n := by
  classical
  have hinj : Function.Injective (fun v : Fin n → Bool => pad (List.ofFn v)) :=
    Function.Injective.comp pad_injective List.ofFn_injective
  unfold padFamily
  rw [Finset.card_image_of_injective _ hinj]
  simp

theorem padFamily_benign {n : ℕ} {t : PAst} (ht : t ∈ padFamily n) :
    (∀ x, eval t x = 0) ∧ (∀ x, effect t x = false) ∧ size t ≤ 3 * n + 1 := by
  unfold padFamily at ht
  simp only [Finset.mem_image, Finset.mem_univ, true_and] at ht
  obtain ⟨v, rfl⟩ := ht
  refine ⟨fun x => eval_pad _ x, fun x => effect_pad _ x, ?_⟩
  rw [size_pad]
  simp

/-- **Finite attestation is necessarily over-rigid.**  For every finite whitelist
there is a perfectly benign program (semantically identical to the constant `0`
program, and effect-free) that the monitor rejects. -/
theorem finite_whitelist_rejects_benign (S : Finset PAst) :
    ∃ l : List Bool, pad l ∉ S ∧ (∀ x, eval (pad l) x = 0) ∧ (∀ x, effect (pad l) x = false) := by
  by_contra h
  push_neg at h
  have hall : ∀ l : List Bool, pad l ∈ (S : Set PAst) := by
    intro l
    by_contra hl
    obtain ⟨x, hx⟩ := h l (by simpa using hl) (fun x => eval_pad l x)
    exact hx (effect_pad l x)
  have : (S : Set PAst).Infinite :=
    Set.infinite_of_injective_forall_mem pad_injective hall
  exact this S.finite_toSet

/-- **Exponential false-rejection bound.**  A whitelist of size `|S|` rejects at
least `2 ^ n - |S|` benign programs of size at most `3n + 1`: sound structural
attestation buys containment at the cost of exponential rigidity. -/
theorem benign_rejection_card (S : Finset PAst) (n : ℕ) :
    2 ^ n - S.card ≤ (padFamily n \ S).card ∧
      ∀ t ∈ padFamily n \ S, (∀ x, effect t x = false) ∧ size t ≤ 3 * n + 1 := by
  constructor
  · have := Finset.le_card_sdiff S (padFamily n)
    rwa [card_padFamily n] at this
  · intro t ht
    obtain ⟨h1, h2, h3⟩ := padFamily_benign (Finset.mem_sdiff.1 ht).1
    exact ⟨h2, h3⟩

/-! ### Synthesis -/

/-- **Conservation law of algorithmic immunity.**  Simultaneously:

1. *containment / neutralization*: with a harmless sanctioned set, an arbitrary
   unknown self-modifying adversary never executes the forbidden action;
2. *rigidity*: the same monitor necessarily rejects at least `2 ^ n - |S|`
   semantically benign programs of size `≤ 3n + 1`;
3. *irreducibility*: this price cannot be avoided by switching to behavioural
   analysis, since no harmless detector of the calculus is both sound and
   complete.

Safety is therefore attainable, but only in the syntactic category, and the
semantic overshoot is exponentially large. -/
theorem immune_conservation {S : Finset PAst} {b : PAst} (hb : b ∈ S)
    (hsafe : ∀ t ∈ S, ¬ malicious t) (n : ℕ) :
    (∀ adv : ℕ → PAst → PAst, ∀ k : ℕ, ¬ malicious (trace S b adv k)) ∧
      2 ^ n - S.card ≤ (padFamily n \ S).card ∧
      ¬ ∃ d : PAst, IsPure d ∧ Sound d ∧ Complete d :=
  ⟨fun adv k => neutralization hb hsafe adv k, (benign_rejection_card S n).1,
    no_perfect_detector⟩

end PAst
end ImmuneSystem