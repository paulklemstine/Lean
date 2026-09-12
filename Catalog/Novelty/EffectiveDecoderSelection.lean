/-
# Effective reconstruction: fibre constancy versus uniform effective selection

`Catalog/Novelty/BoundedError.lean` studies surveillance channels `obs : S → M`
together with a *supplied* decoder `dec : M → S`, and bounds the accuracy of the
pair.  This file attacks the prior, **definability** question: given a channel
`obs` and a quantity `f` that the observer wants to recover, *when does a decoder
exist at all, and when does it exist computably?*

Set-theoretically the answer is classical and complete: a decoder exists iff `f`
is **fibre constant** along `obs`, i.e. `obs x = obs y → f x = f y`
(`fibreConstant_iff_exists_decoder`).  The theme of this file is that in the
effective (Turing-computable) world this equivalence **breaks**, and it breaks in
a precisely locatable place:

* fibre constancy always yields a *partial* computable decoder, correct on the
  whole range of the channel (`exists_partrec_decoder`);
* what it does **not** yield is a *total* computable decoder.  The extra
  ingredient needed is a **uniform effective representative selection on the
  range of the functional map** — a computable `sel` with
  `obs (sel (obs x)) = obs x` (`Selector`).  Given such a selector, every
  computable fibre-constant `f` is decoded by the computable map `f ∘ sel`
  (`computable_decoder_of_selector`);
* the separation is strict: there are computable `obs, f : ℕ → ℕ` with `f` fibre
  constant along `obs` and **no** total computable decoder
  (`no_computable_decoder_diag`), hence no computable selector
  (`no_computable_selector_diag`), even though the partial decoder of
  `exists_partrec_decoder` exists and even though set-theoretic decoders abound.

We also isolate a positive effectiveness criterion — computably bounded preimage
search suffices (`exists_computable_selector_of_bounded`) — and show that for
*injective* channels the two notions coincide: universal decodability of all
computable quantities is *equivalent* to computable selection
(`selector_iff_universal_decoding_of_injective`).  Finally the finite baseline
(`finite_selector_exists`) records that the whole phenomenon is infinitary: on a
finite state space, as in `BoundedError.lean`, selectors always exist, so
accuracy — not definability — is the only obstruction there.

The counterexample channel is the *diagonal trace channel*: on input `n = ⟨a, s⟩`
it runs the `a`-th machine on input `a` for `s` steps, emitting the record `a+1`
if the run halts and the blank record `0` otherwise; the quantity `f` is the
halting value (shifted).  Fibre constancy is the determinism of evaluation, while
a total computable decoder would compute `φ_a(a) + 1` on all self-halting `a`,
which Kleene's diagonal argument forbids.
-/
import Mathlib

open Nat.Partrec Nat.Partrec.Code Denumerable

namespace EffectiveDecoder

/-! ## 1. The abstract notions -/

/-- `f` is **fibre constant** along the channel `obs`: it is constant on each
fibre `obs ⁻¹ {m}`, i.e. it factors through `obs` as a function of sets. -/
def FibreConstant {α β γ : Type*} (obs : α → β) (f : α → γ) : Prop :=
  ∀ x y, obs x = obs y → f x = f y

/-- `dec` **decodes** `f` through the channel `obs`. -/
def Decodes {α β γ : Type*} (obs : α → β) (f : α → γ) (dec : β → γ) : Prop :=
  ∀ x, dec (obs x) = f x

/-- `sel` is a **uniform representative selection on the range of `obs`**: for
every record actually emitted by the channel, `sel` returns a state producing
that same record. -/
def Selector {α β : Type*} (obs : α → β) (sel : β → α) : Prop :=
  ∀ x, obs (sel (obs x)) = obs x

/-! ## 2. The set-theoretic answer: fibre constancy is exactly decodability -/

/-- **Definability of decoders (classical).**  A decoder for `f` through `obs`
exists if and only if `f` is constant on the fibres of `obs`.  Only the
non-effective direction uses choice. -/
theorem fibreConstant_iff_exists_decoder {α β γ : Type*} [Nonempty α]
    (obs : α → β) (f : α → γ) :
    FibreConstant obs f ↔ ∃ dec : β → γ, Decodes obs f dec := by
  constructor
  · intro hfc
    classical
    refine ⟨fun m => if h : ∃ x, obs x = m then f h.choose else f (Classical.arbitrary α), ?_⟩
    intro x
    have hx : ∃ y, obs y = obs x := ⟨x, rfl⟩
    simp only [hx, dif_pos]
    exact hfc _ _ hx.choose_spec
  · rintro ⟨dec, hdec⟩ x y hxy
    rw [← hdec x, ← hdec y, hxy]

/-- A selector composes with a fibre-constant quantity to give a decoder:
`f ∘ sel` decodes `f`.  This is the *uniform* form of the previous theorem — no
choice is involved, the representative is produced by `sel`. -/
theorem decodes_comp_selector {α β γ : Type*} {obs : α → β} {f : α → γ} {sel : β → α}
    (hfc : FibreConstant obs f) (hsel : Selector obs sel) :
    Decodes obs f (f ∘ sel) :=
  fun x => hfc _ _ (hsel x)

/-! ## 3. The effective side: what fibre constancy does and does not buy -/

variable {obs f : ℕ → ℕ}

/-- **Fibre constancy always gives a partial computable decoder.**  Search for
any preimage of the received record and apply `f` to it; fibre constancy makes
the answer independent of which preimage the search finds.  The resulting partial
function is defined (and correct) on the whole range of the channel.

Thus the effective obstruction is never *computation*, it is exactly
*totalisation*. -/
theorem exists_partrec_decoder (hobs : Computable obs) (hf : Computable f)
    (hfc : FibreConstant obs f) :
    ∃ dec : ℕ →. ℕ, Partrec dec ∧ ∀ x, f x ∈ dec (obs x) := by
  classical
  have he : Computable fun p : ℕ × ℕ => decide (p.1 = p.2) := (Primrec.eq (α := ℕ)).decide.to_comp
  have h1 : Computable fun x : ℕ × ℕ => decide (obs x.2 = x.1) :=
    he.comp (Computable.pair (hobs.comp Computable.snd) Computable.fst :
      Computable fun x : ℕ × ℕ => ((obs x.2, x.1) : ℕ × ℕ))
  refine ⟨fun m => (Nat.rfind fun n => Part.some (decide (obs n = m))).map f, ?_, ?_⟩
  · exact Partrec.map (Partrec.rfind (Computable₂.partrec₂ h1)) (hf.comp Computable.snd).to₂
  · intro x
    obtain ⟨n, hn, -⟩ := Nat.rfind_min' (p := fun n => decide (obs n = obs x)) (m := x) (by simp)
    refine (Part.mem_map_iff f).2 ⟨n, hn, ?_⟩
    have hx : obs n = obs x := by simpa using Nat.rfind_spec hn
    exact hfc _ _ hx

/-- **Effective selection gives effective decoding.**  If the channel admits a
computable uniform representative selection on its range, then every computable
fibre-constant quantity has a *total* computable decoder. -/
theorem computable_decoder_of_selector {sel : ℕ → ℕ} (hsel : Selector obs sel)
    (hselc : Computable sel) (hf : Computable f) (hfc : FibreConstant obs f) :
    ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obs f dec :=
  ⟨f ∘ sel, hf.comp hselc, decodes_comp_selector hfc hsel⟩

/-- **A positive effectiveness criterion: computably bounded preimage search.**
If some computable `b` bounds, for every emitted record, the least state
producing it, then the channel admits a computable selector (total bounded
search). -/
theorem exists_computable_selector_of_bounded (hobs : Computable obs) {b : ℕ → ℕ}
    (hb : Computable b) (hbound : ∀ x, ∃ y ≤ b (obs x), obs y = obs x) :
    ∃ sel : ℕ → ℕ, Computable sel ∧ Selector obs sel := by
  classical
  set p : ℕ → ℕ → Bool := fun t n => decide (obs n = t) || decide (b t ≤ n) with hp
  have hpc : Computable₂ p := by
    have he : Computable fun q : ℕ × ℕ => decide (q.1 = q.2) := (Primrec.eq (α := ℕ)).decide.to_comp
    have hle : Computable fun q : ℕ × ℕ => decide (q.1 ≤ q.2) := Primrec.nat_le.decide.to_comp
    have h1 : Computable fun x : ℕ × ℕ => decide (obs x.2 = x.1) :=
      he.comp (Computable.pair (hobs.comp Computable.snd) Computable.fst :
        Computable fun x : ℕ × ℕ => ((obs x.2, x.1) : ℕ × ℕ))
    have h2 : Computable fun x : ℕ × ℕ => decide (b x.1 ≤ x.2) :=
      hle.comp (Computable.pair (hb.comp Computable.fst) Computable.snd :
        Computable fun x : ℕ × ℕ => ((b x.1, x.2) : ℕ × ℕ))
    have hor : Computable fun q : Bool × Bool => (q.1 || q.2) := Primrec.or.to_comp
    exact hor.comp (Computable.pair h1 h2 :
      Computable fun x : ℕ × ℕ => ((decide (obs x.2 = x.1), decide (b x.1 ≤ x.2)) : Bool × Bool))
  have hdom : ∀ t : ℕ, (Nat.rfind fun n => (p t n : Part Bool)).Dom := by
    intro t
    obtain ⟨n, hn, -⟩ := Nat.rfind_min' (p := p t) (m := b t) (by simp [hp])
    exact hn.fst
  refine ⟨fun t => (Nat.rfind fun n => (p t n : Part Bool)).get (hdom t), ?_, ?_⟩
  · have hr : Partrec fun t => Nat.rfind fun n => ((p t n : Bool) : Part Bool) :=
      Partrec.rfind (Computable₂.partrec₂ hpc)
    refine Partrec.of_eq hr fun t => ?_
    exact Part.eq_some_iff.2 (Part.get_mem (hdom t))
  · intro x
    set t := obs x with ht
    set n := (Nat.rfind fun n => (p t n : Part Bool)).get (hdom t) with hn
    have hmem : n ∈ Nat.rfind fun n => (p t n : Part Bool) := Part.get_mem _
    have hspec : p t n = true := by simpa using Nat.rfind_spec hmem
    by_cases hcase : obs n = t
    · exact hcase
    · exfalso
      obtain ⟨y, hyb, hy⟩ := hbound x
      have hbt : b t ≤ n := by
        simp only [hp, Bool.or_eq_true, decide_eq_true_eq] at hspec
        rcases hspec with h | h
        · exact absurd h hcase
        · exact h
      have hyn : y < n := by
        rcases lt_or_eq_of_le (le_trans hyb hbt) with h | h
        · exact h
        · exact absurd (h ▸ hy) hcase
      have hfalse : p t y = false := by simpa using Nat.rfind_min hmem hyn
      simp only [hp, Bool.or_eq_false_iff, decide_eq_false_iff_not] at hfalse
      exact hfalse.1 hy

/-! ## 4. The diagonal trace channel: the strict separation -/

/-- One step-bounded run of the diagonal machine: on input `n = ⟨a, s⟩` run the
`a`-th partial recursive machine on input `a` for `s` steps. -/
def stepRun (n : ℕ) : Option ℕ :=
  evaln n.unpair.2 (ofNat Code n.unpair.1) n.unpair.1

theorem computable_stepRun : Computable stepRun := by
  have h1 : Computable fun n : ℕ => ((n.unpair.2, ofNat Code n.unpair.1), n.unpair.1) :=
    Computable.pair
      (Computable.pair (Computable.snd.comp Computable.unpair)
        ((Primrec.ofNat Code).to_comp.comp (Computable.fst.comp Computable.unpair)))
      (Computable.fst.comp Computable.unpair)
  exact Nat.Partrec.Code.primrec_evaln.to_comp.comp h1

/-- The **diagonal trace channel**: it reveals *which* machine halted on itself
(record `a + 1`), but not the halting value; a non-halting trace produces the
blank record `0`. -/
def obsDiag (n : ℕ) : ℕ :=
  Option.casesOn (stepRun n) 0 fun _ => n.unpair.1 + 1

/-- The quantity the observer wants to recover: the halting value (shifted by one
so that the blank record is unambiguous). -/
def fDiag (n : ℕ) : ℕ :=
  Option.casesOn (stepRun n) 0 fun v => v + 1

theorem computable_obsDiag : Computable obsDiag :=
  Computable.option_casesOn computable_stepRun (Computable.const 0)
    ((Computable.succ.comp (Computable.fst.comp Computable.unpair)).comp Computable.fst).to₂

theorem computable_fDiag : Computable fDiag :=
  Computable.option_casesOn computable_stepRun (Computable.const 0)
    (Computable.succ.comp Computable.snd).to₂

/-- **Fibre constancy of the halting value.**  Two traces producing the same
record either are both blank, or run the *same* machine on the *same* input for
possibly different numbers of steps; determinism of evaluation makes the halting
values agree. -/
theorem fibreConstant_diag : FibreConstant obsDiag fDiag := by
  intro x y hxy
  rcases hx : stepRun x with _ | v
  · rcases hy : stepRun y with _ | w
    · simp [fDiag, hx, hy]
    · exact absurd hxy (by simp [obsDiag, hx, hy])
  · rcases hy : stepRun y with _ | w
    · exact absurd hxy (by simp [obsDiag, hx, hy])
    · have hidx : x.unpair.1 = y.unpair.1 := by simpa [obsDiag, hx, hy] using hxy
      have hx' : v ∈ evaln x.unpair.2 (ofNat Code x.unpair.1) x.unpair.1 := hx
      have hy' : w ∈ evaln y.unpair.2 (ofNat Code y.unpair.1) y.unpair.1 := hy
      have h1 : v ∈ (ofNat Code x.unpair.1).eval x.unpair.1 := evaln_sound hx'
      have h2 : w ∈ (ofNat Code x.unpair.1).eval x.unpair.1 := by
        rw [hidx]; exact evaln_sound hy'
      simp [fDiag, hx, hy, Part.mem_unique h1 h2]

/-- **The separation theorem.**  There is *no* total computable decoder for the
fibre-constant quantity `fDiag` along the channel `obsDiag`: a decoder would
compute the diagonal value `φ_a(a) + 1` for every self-halting index `a`, and
feeding it its own index yields `d = d + 1`.

Together with `fibreConstant_iff_exists_decoder` and `exists_partrec_decoder`
this shows that fibre constancy — which fully settles the *existence* of a
decoder, and even the existence of a *partial computable* one — is strictly
weaker than the existence of an effective decoder. -/
theorem no_computable_decoder_diag :
    ¬ ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obsDiag fDiag dec := by
  rintro ⟨dec, hdec, hcorr⟩
  -- the total computable function `g a = dec (a+1)`
  set g : ℕ → ℕ := fun a => dec (a + 1) with hg
  have hgc : Computable g := hdec.comp Computable.succ
  obtain ⟨c, hc⟩ := Nat.Partrec.Code.exists_code.1 (Partrec.nat_iff.1 hgc)
  set a₀ : ℕ := Encodable.encode c with ha₀
  have hcode : ofNat Code a₀ = c := Denumerable.ofNat_encode c
  have hmem : g a₀ ∈ c.eval a₀ := by rw [hc]; exact Part.mem_some _
  obtain ⟨s, hs⟩ := Nat.Partrec.Code.evaln_complete.1 hmem
  -- assemble the trace `n = ⟨a₀, s⟩`
  set n : ℕ := Nat.pair a₀ s with hn
  have hstep : stepRun n = some (g a₀) := by
    unfold stepRun
    rw [hn, Nat.unpair_pair, hcode]
    exact hs
  have hobs : obsDiag n = a₀ + 1 := by
    unfold obsDiag; rw [hstep, hn, Nat.unpair_pair]
  have hf : fDiag n = g a₀ + 1 := by unfold fDiag; rw [hstep]
  have := hcorr n
  rw [hobs, hf] at this
  exact absurd this (by simp [hg])

/-- **No uniform effective representative selection on the range.**  Since the
channel carries a computable fibre-constant quantity with no computable decoder,
it cannot admit a computable selector: effective selection would manufacture the
missing decoder. -/
theorem no_computable_selector_diag :
    ¬ ∃ sel : ℕ → ℕ, Computable sel ∧ Selector obsDiag sel := by
  rintro ⟨sel, hselc, hsel⟩
  exact no_computable_decoder_diag
    (computable_decoder_of_selector hsel hselc computable_fDiag fibreConstant_diag)

/-- **No computable preimage bound.**  By the positive criterion, the diagonal
trace channel cannot admit a computable bound on the search for a preimage of an
emitted record: unbounded search is genuinely unavoidable here. -/
theorem no_computable_bound_diag :
    ¬ ∃ b : ℕ → ℕ, Computable b ∧ ∀ x, ∃ y ≤ b (obsDiag x), obsDiag y = obsDiag x := by
  rintro ⟨b, hb, hbound⟩
  exact no_computable_selector_diag
    (exists_computable_selector_of_bounded computable_obsDiag hb hbound)

/-! ## 5. Where the two notions do coincide -/

/-- **Injective channels: decoding is selection.**  For an injective channel
(every fibre a singleton, so fibre constancy is vacuous) the existence of a
computable decoder for *every* computable quantity is equivalent to the existence
of a computable uniform selector.  (The injectivity hypothesis is removed in
`Catalog/Novelty/EffectiveDecoderCompleteness.lean`, where the canonical
representative is shown to be a complete quantity for the decoding problem.) -/
theorem selector_iff_universal_decoding_of_injective (hinj : Function.Injective obs) :
    (∃ sel : ℕ → ℕ, Computable sel ∧ Selector obs sel) ↔
      ∀ g : ℕ → ℕ, Computable g → ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obs g dec := by
  constructor
  · rintro ⟨sel, hselc, hsel⟩ g hgc
    refine computable_decoder_of_selector hsel hselc hgc ?_
    intro x y hxy
    rw [hinj hxy]
  · intro H
    obtain ⟨dec, hdecc, hdec⟩ := H id Computable.id
    exact ⟨dec, hdecc, fun x => by simp [hdec x]⟩

/-- **Finite baseline.**  On a finite state space — the setting of
`Catalog/Novelty/BoundedError.lean` — a uniform representative selection always
exists (decidably, with no choice and no search), so definability is never an
obstruction there and accuracy is the only issue.  The effective phenomena of
§4 are therefore genuinely infinitary. -/
theorem finite_selector_exists {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (obs : α → β) : ∃ sel : β → α, Selector obs sel := by
  classical
  refine ⟨fun m => if h : ∃ x, obs x = m then h.choose else Classical.arbitrary α, fun x => ?_⟩
  have hx : ∃ y, obs y = obs x := ⟨x, rfl⟩
  simp only [hx, dif_pos]
  exact hx.choose_spec

end EffectiveDecoder