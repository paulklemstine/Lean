import Catalog.Shared.ImmuneOracle

/-!
# Algorithmic Immune System, Part VI: algebra of mutations and an uncertainty principle

Two structural readings of Parts I–IV.

**Algebraic.**  Self-modifications are endomorphisms of the space of ASTs, i.e.
elements of the monoid `Function.End PAst`.  The mutations that respect a
sanctioned set `S` form a submonoid `sanctionedEnd S`, and the immune system's
guard `guardEnd` is an idempotent retraction of the whole mutation monoid onto
maps with sanctioned values.  Guarded dynamics is then literally a monoid action
on the sanctioned set (`trace_iterate`).

**Information-theoretic.**  Semantic equivalence `SemEquiv` is an equivalence
relation whose classes are huge: a single class contains at least `2 ^ n`
programs of size `≤ 3n+1`.  Since attestation is syntactic, a monitor must either
*store* those variants or *reject* them.  The resulting inequality

`2 ^ n ≤ |S| + |padFamily n \ S|`   (`immune_uncertainty`)

is an uncertainty principle for algorithmic immunity: **memory + rigidity ≥
exponential**.  No monitor can be both small and permissive.
-/

namespace ImmuneSystem
namespace PAst

open Finset

/-! ### The monoid of mutations -/

/-- The submonoid of self-modifications that preserve the sanctioned set. -/
def sanctionedEnd (S : Finset PAst) : Submonoid (Function.End PAst) where
  carrier := {m | ∀ t ∈ S, m t ∈ S}
  one_mem' := fun _ ht => ht
  mul_mem' := fun ha hb t ht => ha _ (hb t ht)

theorem mem_sanctionedEnd {S : Finset PAst} {m : Function.End PAst} :
    m ∈ sanctionedEnd S ↔ ∀ t ∈ S, m t ∈ S := Iff.rfl

/-- The immunisation of a mutation: perform it, then quarantine. -/
def guardEnd (S : Finset PAst) (b : PAst) (m : Function.End PAst) : Function.End PAst :=
  fun t => quarantine S b (m t)

/-- Immunised mutations are sanctioned-valued, hence in particular they preserve
the sanctioned set. -/
theorem guardEnd_mem_sanctionedEnd {S : Finset PAst} {b : PAst} (hb : b ∈ S)
    (m : Function.End PAst) : guardEnd S b m ∈ sanctionedEnd S :=
  fun t _ => quarantine_mem hb (m t)

/-- Immunisation is idempotent: it is a retraction of the mutation monoid. -/
theorem guardEnd_idem {S : Finset PAst} {b : PAst} (hb : b ∈ S) (m : Function.End PAst) :
    guardEnd S b (guardEnd S b m) = guardEnd S b m := by
  funext t
  exact quarantine_idem hb (m t)

/-- A mutation is untouched by the immune system exactly when all of its outputs
are sanctioned. -/
theorem guardEnd_eq_self_iff {S : Finset PAst} {b : PAst} (hb : b ∈ S)
    (m : Function.End PAst) : guardEnd S b m = m ↔ ∀ t, m t ∈ S := by
  constructor
  · intro h t
    have : quarantine S b (m t) = m t := congrFun h t
    exact (quarantine_eq_self_iff hb).1 this
  · intro h
    funext t
    exact quarantine_of_mem (h t)

/-- **Guarded dynamics is a monoid action.**  Under a constant sanctioned
mutation the immune system is invisible: the trace is the plain iteration of the
mutation, and stays sanctioned forever. -/
theorem trace_iterate {S : Finset PAst} {b : PAst} (hb : b ∈ S) {m : Function.End PAst}
    (hm : m ∈ sanctionedEnd S) (n : ℕ) :
    trace S b (fun _ => m) n = m^[n] b := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hmem : m^[n] b ∈ S := ih ▸ trace_mem hb _ n
      rw [trace_succ, ih, Function.iterate_succ_apply']
      exact quarantine_of_mem (hm _ hmem)

/-! ### Semantic equivalence and the size of its classes -/

/-- Two programs are semantically equivalent when they agree on values and on
effects for every input. -/
def SemEquiv (s t : PAst) : Prop := ∀ x : ℕ, eval s x = eval t x ∧ effect s x = effect t x

theorem semEquiv_refl (t : PAst) : SemEquiv t t := fun _ => ⟨rfl, rfl⟩

theorem semEquiv_symm {s t : PAst} (h : SemEquiv s t) : SemEquiv t s :=
  fun x => ⟨(h x).1.symm, (h x).2.symm⟩

theorem semEquiv_trans {r s t : PAst} (h₁ : SemEquiv r s) (h₂ : SemEquiv s t) : SemEquiv r t :=
  fun x => ⟨(h₁ x).1.trans (h₂ x).1, (h₁ x).2.trans (h₂ x).2⟩

/-- Semantic equivalence is an equivalence relation. -/
def semSetoid : Setoid PAst where
  r := SemEquiv
  iseqv := ⟨semEquiv_refl, semEquiv_symm, semEquiv_trans⟩

/-- Every padded variant is semantically the constant-zero program: the immune
system's syntactic view separates programs that are behaviourally identical. -/
theorem semEquiv_pad (l : List Bool) : SemEquiv (pad l) (lit 0) :=
  fun x => ⟨by simp, by simp⟩

/-- A single semantic equivalence class contains at least `2 ^ n` programs of size
at most `3n+1`. -/
theorem semClass_card_exp (n : ℕ) :
    (padFamily n).card = 2 ^ n ∧
      ∀ t ∈ padFamily n, SemEquiv t (lit 0) ∧ size t ≤ 3 * n + 1 := by
  refine ⟨card_padFamily n, ?_⟩
  intro t ht
  have hb := padFamily_benign ht
  refine ⟨fun x => ⟨?_, ?_⟩, hb.2.2⟩
  · simpa using hb.1 x
  · simpa using hb.2.1 x

/-! ### An uncertainty principle for algorithmic immunity -/

/-- **Immune uncertainty principle.**  For every attestation whitelist `S` and
every `n`, the *memory* of the monitor plus its *rigidity* (the number of
behaviourally trivial programs of size `≤ 3n+1` it rejects) is at least `2 ^ n`.
A monitor can be small, or permissive, but not both. -/
theorem immune_uncertainty (S : Finset PAst) (n : ℕ) :
    2 ^ n ≤ S.card + (padFamily n \ S).card := by
  have h := (benign_rejection_card S n).1
  omega

/-- Permissiveness costs memory: a monitor that accepts the whole `n`-bit family
of behaviourally trivial variants must store at least `2 ^ n` tags. -/
theorem attestation_memory_lower_bound {S : Finset PAst} {n : ℕ} (h : padFamily n ⊆ S) :
    2 ^ n ≤ S.card := by
  have hsd : padFamily n \ S = ∅ := Finset.sdiff_eq_empty_iff_subset.2 h
  have := immune_uncertainty S n
  rw [hsd] at this
  simpa using this

/-- In bits: accepting all `n`-bit behaviourally trivial variants requires an
attestation database of at least `n` bits of entropy. -/
theorem attestation_bits_lower_bound {S : Finset PAst} {n : ℕ} (h : padFamily n ⊆ S) :
    n ≤ Nat.log 2 S.card := by
  have h2 : 2 ^ n ≤ S.card := attestation_memory_lower_bound h
  have hpos : 0 < S.card := lt_of_lt_of_le (Nat.two_pow_pos n) h2
  exact (Nat.le_log_iff_pow_le (by norm_num) (Nat.ne_of_gt hpos)).2 h2

/-- **Rigidity of finite monitors, semantic form.**  Every finite whitelist
rejects some program that is behaviourally identical to a program it accepts
(here: to the constant `0` program). -/
theorem finite_whitelist_not_semantically_closed {S : Finset PAst} (h0 : lit 0 ∈ S) :
    ∃ s t : PAst, s ∈ S ∧ t ∉ S ∧ SemEquiv t s := by
  obtain ⟨l, hl, _, _⟩ := finite_whitelist_rejects_benign S
  exact ⟨lit 0, pad l, h0, hl, semEquiv_pad l⟩

end PAst
end ImmuneSystem