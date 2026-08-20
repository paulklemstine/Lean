import Catalog.Shared.ImmuneQuarantine

/-!
# Algorithmic Immune System, Part V: the reflexive oracle barrier

Part III proved that no *program* of the parasite calculus can be a sound and
complete behavioural detector.  A natural objection is that this might be a
limitation of computational power: perhaps a sufficiently strong immune system —
one with unbounded, even hypercomputational, analysis capability — could succeed.

Here we refute that objection in the strongest possible form.  We extend the
calculus with a primitive `ask` that queries an **arbitrary function**
`O : ℕ → ℕ` (the immune oracle: no computability whatsoever is assumed) on a
computed attestation tag, and we let programs use it freely.  Then:

* `no_correct_reflexive_oracle` — **for every** `O : ℕ → ℕ` there is a program
  whose behaviour `O` misdescribes.  Reflexivity, not computational power, is the
  barrier;
* `askFree_eval_oracle_indep`, `askFree_effect_oracle_indep` — programs that do
  not consult the immune system have oracle-independent behaviour;
* `oracle_correct_on_askFree` — and for those programs a correct (noncomputably
  defined) oracle *does* exist.

Together (`reflexive_dichotomy`) this locates the exact frontier: an immune
system can be perfectly correct about code that ignores it, and is necessarily
wrong about code that watches it.
-/

namespace ImmuneSystem

/-- ASTs of the *reflexive* calculus: as in Part I, but subprogram invocation is
replaced by `ask`, a query to the immune oracle. -/
inductive OAst : Type
  | inp : OAst
  | attack : OAst
  | lit : ℕ → OAst
  | ite : OAst → OAst → OAst → OAst
  | ask : OAst → OAst
  deriving DecidableEq, Repr

namespace OAst

/-- Attestation tag for reflexive ASTs. -/
def codeO : OAst → ℕ
  | inp => 0
  | attack => 1
  | lit n => 5 * n + 2
  | ite c a b => 5 * (Nat.pair (Nat.pair (codeO c) (codeO a)) (codeO b)) + 3
  | ask a => 5 * codeO a + 4

@[simp] theorem codeO_inp : codeO inp = 0 := rfl
@[simp] theorem codeO_attack : codeO attack = 1 := rfl
@[simp] theorem codeO_lit (n : ℕ) : codeO (lit n) = 5 * n + 2 := rfl
@[simp] theorem codeO_ite (c a b : OAst) :
    codeO (ite c a b) = 5 * (Nat.pair (Nat.pair (codeO c) (codeO a)) (codeO b)) + 3 := rfl
@[simp] theorem codeO_ask (a : OAst) : codeO (ask a) = 5 * codeO a + 4 := rfl

theorem codeO_injective : Function.Injective codeO := by
  intro s
  induction s with
  | inp => intro t h; cases t <;> simp_all [codeO]
  | attack => intro t h; cases t <;> simp_all [codeO]
  | lit n =>
      intro t h
      cases t with
      | lit m => simp only [codeO_lit] at h; simp; omega
      | _ => simp_all [codeO] <;> omega
  | ite c a b ihc iha ihb =>
      intro t h
      cases t with
      | ite c' a' b' =>
          simp only [codeO_ite] at h
          have hp : Nat.pair (Nat.pair (codeO c) (codeO a)) (codeO b)
              = Nat.pair (Nat.pair (codeO c') (codeO a')) (codeO b') := by omega
          rw [Nat.pair_eq_pair, Nat.pair_eq_pair] at hp
          obtain ⟨⟨h1, h2⟩, h3⟩ := hp
          rw [ihc h1, iha h2, ihb h3]
      | _ => simp_all [codeO] <;> omega
  | ask a iha =>
      intro t h
      cases t with
      | ask a' =>
          simp only [codeO_ask] at h
          rw [iha (by omega : codeO a = codeO a')]
      | _ => simp_all [codeO] <;> omega

variable (O : ℕ → ℕ)

/-- Value semantics relative to an arbitrary immune oracle `O`. -/
def evalO : OAst → ℕ → ℕ
  | inp, x => x
  | attack, _ => 1
  | lit n, _ => n
  | ite c a b, x => if evalO c x ≠ 0 then evalO a x else evalO b x
  | ask a, x => O (evalO a x)

/-- Effect semantics relative to `O`.  Consulting the immune system is itself
harmless; only `attack` on an executed branch counts. -/
def effectO : OAst → ℕ → Bool
  | inp, _ => false
  | attack, _ => true
  | lit _, _ => false
  | ite c a b, x => effectO c x || (if evalO O c x ≠ 0 then effectO a x else effectO b x)
  | ask a, x => effectO a x

@[simp] theorem evalO_inp (x : ℕ) : evalO O inp x = x := rfl
@[simp] theorem evalO_attack (x : ℕ) : evalO O attack x = 1 := rfl
@[simp] theorem evalO_lit (n x : ℕ) : evalO O (lit n) x = n := rfl
@[simp] theorem evalO_ite (c a b : OAst) (x : ℕ) :
    evalO O (ite c a b) x = if evalO O c x ≠ 0 then evalO O a x else evalO O b x := rfl
@[simp] theorem evalO_ask (a : OAst) (x : ℕ) : evalO O (ask a) x = O (evalO O a x) := rfl

@[simp] theorem effectO_inp (x : ℕ) : effectO O inp x = false := rfl
@[simp] theorem effectO_attack (x : ℕ) : effectO O attack x = true := rfl
@[simp] theorem effectO_lit (n x : ℕ) : effectO O (lit n) x = false := rfl
@[simp] theorem effectO_ite (c a b : OAst) (x : ℕ) :
    effectO O (ite c a b) x
      = (effectO O c x || (if evalO O c x ≠ 0 then effectO O a x else effectO O b x)) := rfl
@[simp] theorem effectO_ask (a : OAst) (x : ℕ) : effectO O (ask a) x = effectO O a x := rfl

/-- Self-execution in the reflexive calculus. -/
def maliciousO (t : OAst) : Prop := effectO O t (codeO t) = true

/-- The oracle is *correct* if its verdict on every attestation tag matches the
actual behaviour of the corresponding program **in the world containing the
oracle itself**. -/
def OracleCorrect : Prop := ∀ t : OAst, (O (codeO t) ≠ 0 ↔ maliciousO O t)

/-- The reflexive parasite: it asks the immune oracle about its own tag and
attacks exactly when it is cleared. -/
def refParasite : OAst := ite (ask inp) (lit 0) attack

theorem maliciousO_refParasite_iff :
    maliciousO O refParasite ↔ O (codeO (refParasite)) = 0 := by
  unfold maliciousO refParasite
  simp

/-- **The reflexive oracle barrier.**  No function `ℕ → ℕ` whatsoever — computable
or not, of any complexity or logical strength — correctly classifies the
behaviour of all programs that may consult it.  The obstruction to a perfect
immune system is reflexivity, not computational power. -/
theorem no_correct_reflexive_oracle : ∀ O : ℕ → ℕ, ¬ OracleCorrect O := by
  intro O hO
  have h := hO refParasite
  rw [maliciousO_refParasite_iff O] at h
  by_cases hz : O (codeO refParasite) = 0
  · exact (h.2 hz) hz
  · exact hz (h.1 hz)

/-- Programs that never consult the immune system. -/
def askFree : OAst → Bool
  | inp => true
  | attack => true
  | lit _ => true
  | ite c a b => askFree c && askFree a && askFree b
  | ask _ => false

@[simp] theorem askFree_ite (c a b : OAst) :
    askFree (ite c a b) = (askFree c && askFree a && askFree b) := rfl
@[simp] theorem askFree_ask (a : OAst) : askFree (ask a) = false := rfl

/-- Oracle-independence of values for non-reflexive programs. -/
theorem askFree_eval_oracle_indep :
    ∀ {t : OAst}, askFree t = true → ∀ (O O' : ℕ → ℕ) (x : ℕ), evalO O t x = evalO O' t x := by
  intro t
  induction t with
  | inp => intro _ O O' x; rfl
  | attack => intro _ O O' x; rfl
  | lit n => intro _ O O' x; rfl
  | ite c a b ihc iha ihb =>
      intro h O O' x
      simp only [askFree_ite, Bool.and_eq_true] at h
      obtain ⟨⟨hc, ha⟩, hb⟩ := h
      simp only [evalO_ite, ihc hc O O' x, iha ha O O' x, ihb hb O O' x]
  | ask a _ => intro h; simp at h

/-- Oracle-independence of effects for non-reflexive programs. -/
theorem askFree_effect_oracle_indep :
    ∀ {t : OAst}, askFree t = true → ∀ (O O' : ℕ → ℕ) (x : ℕ), effectO O t x = effectO O' t x := by
  intro t
  induction t with
  | inp => intro _ O O' x; rfl
  | attack => intro _ O O' x; rfl
  | lit n => intro _ O O' x; rfl
  | ite c a b ihc iha ihb =>
      intro h O O' x
      simp only [askFree_ite, Bool.and_eq_true] at h
      obtain ⟨⟨hc, ha⟩, hb⟩ := h
      simp only [effectO_ite, ihc hc O O' x, iha ha O O' x, ihb hb O O' x,
        askFree_eval_oracle_indep hc O O' x]
  | ask a _ => intro h; simp at h

/-- Maliciousness of non-reflexive programs does not depend on the oracle. -/
theorem maliciousO_oracle_indep {t : OAst} (h : askFree t = true) (O O' : ℕ → ℕ) :
    maliciousO O t ↔ maliciousO O' t := by
  unfold maliciousO
  rw [askFree_effect_oracle_indep h O O' (codeO t)]

open Classical in
/-- The canonical immune oracle: it flags a tag iff that tag belongs to a
non-reflexive malicious program.  (Defined by unrestricted comprehension: no
computability is claimed, and none is needed.) -/
noncomputable def canonicalOracle : ℕ → ℕ := fun n =>
  if ∃ t : OAst, codeO t = n ∧ askFree t = true ∧ maliciousO (fun _ => 0) t then 1 else 0

/-- **A perfect immune oracle exists for non-reflexive code.**  Contrast with
`no_correct_reflexive_oracle`: correctness is achievable exactly as long as the
analysed programs do not observe the analyser. -/
theorem oracle_correct_on_askFree :
    ∃ O : ℕ → ℕ, ∀ (O' : ℕ → ℕ) (t : OAst), askFree t = true →
      (O (codeO t) ≠ 0 ↔ maliciousO O' t) := by
  classical
  refine ⟨canonicalOracle, ?_⟩
  intro O' t ht
  unfold canonicalOracle
  by_cases hmal : maliciousO (fun _ => 0) t
  · have hex : ∃ s : OAst, codeO s = codeO t ∧ askFree s = true
        ∧ maliciousO (fun _ => 0) s := ⟨t, rfl, ht, hmal⟩
    simp only [hex, if_true]
    exact ⟨fun _ => (maliciousO_oracle_indep ht _ O').1 hmal, fun _ => one_ne_zero⟩
  · have hex : ¬ ∃ s : OAst, codeO s = codeO t ∧ askFree s = true
        ∧ maliciousO (fun _ => 0) s := by
      rintro ⟨s, hs, _, hsm⟩
      exact hmal (codeO_injective hs ▸ hsm)
    simp only [hex, if_false]
    constructor
    · intro hne; exact absurd rfl hne
    · intro hm
      exact absurd ((maliciousO_oracle_indep ht O' (fun _ => 0)).1 hm) hmal

/-- **The reflexive dichotomy.**  A perfect immune oracle exists for programs
that ignore it, and none exists once programs may observe it. -/
theorem reflexive_dichotomy :
    (∃ O : ℕ → ℕ, ∀ (O' : ℕ → ℕ) (t : OAst), askFree t = true →
        (O (codeO t) ≠ 0 ↔ maliciousO O' t)) ∧
      (∀ O : ℕ → ℕ, ¬ OracleCorrect O) :=
  ⟨oracle_correct_on_askFree, no_correct_reflexive_oracle⟩

end OAst
end ImmuneSystem