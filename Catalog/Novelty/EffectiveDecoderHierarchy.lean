/-
# The effective decoding hierarchy: range decidability, selection, and the one-jump gap

This file continues `Catalog/Novelty/EffectiveDecoderSelection.lean`, which
separated *fibre constancy* (which settles the existence of a decoder
set-theoretically, and even the existence of a partial computable one) from
*uniform effective representative selection on the range of the functional map*
(which is what produces a **total** computable decoder).

Here we locate the exact complexity of the missing ingredient.

## 1. Selection is decidability of the range

For a computable channel `obs`, a computable uniform selector exists **iff** the
range of `obs` is a computable set (`computable_range_iff_computable_selector`).
One direction is a bounded/guarded search, the other is the observation that a
selector *certifies* membership in the range: `y` is emitted iff
`obs (sel y) = y`.  Consequently the diagonal trace channel of the previous file
has an undecidable range (`range_obsDiag_not_computable`) — a halting-problem
statement obtained purely from the decoding obstruction.

## 2. The finite-rate bridge

`Catalog/Novelty/BoundedError.lean` works with finite state spaces and finite
alphabets, i.e. with channels of finite rate.  We show that *every* channel of
finite rate is effectively decodable (`computable_decoder_of_finite_range`):
finite rate forces a decidable range, hence a computable selector, hence a total
computable decoder for every computable fibre-constant quantity.  The
rate–distortion analysis of `BoundedError.lean` therefore loses nothing by
ignoring definability; all the effective phenomena live at infinite rate.

## 3. The gap is exactly one jump

Finally we show the obstruction is never worse than a single limit: for any
computable channel and any computable fibre-constant quantity there is a
*computable double sequence* `approxDec` which converges to the correct decoded
value, with the explicit modulus `s > x` at any preimage `x`
(`limit_computable_decoder`).  Combined with the counterexample this is sharp:
the decoder of the diagonal trace channel is limit-computable but not computable
(`decoding_gap_exactly_one_jump`).
-/
import Novelty.EffectiveDecoderSelection

open Nat.Partrec Nat.Partrec.Code Denumerable

namespace EffectiveDecoder

variable {obs f : ℕ → ℕ}

/-! ## 1. Effective selection = decidability of the range -/

/-- **A selector certifies the range.**  If a computable uniform selector exists
then the range of the channel is a computable set: a record `y` is emitted
exactly when `obs (sel y) = y`, a decidable condition. -/
theorem computableRange_of_computable_selector {sel : ℕ → ℕ} (hobs : Computable obs)
    (hselc : Computable sel) (hsel : Selector obs sel) :
    ComputablePred fun y => ∃ n, obs n = y := by
  classical
  have key : ∀ y, (∃ n, obs n = y) ↔ obs (sel y) = y := by
    refine fun y => ⟨?_, fun h => ⟨sel y, h⟩⟩
    rintro ⟨n, rfl⟩
    exact hsel n
  have hc : Computable fun y => decide (obs (sel y) = y) := by
    have he : Computable fun q : ℕ × ℕ => decide (q.1 = q.2) := (Primrec.eq (α := ℕ)).decide.to_comp
    exact he.comp (Computable.pair (hobs.comp hselc) Computable.id :
      Computable fun y : ℕ => ((obs (sel y), y) : ℕ × ℕ))
  exact (Computable.computablePred hc).of_eq fun y => (key y).symm

/-- **A decidable range produces a selector.**  Guarded unbounded search: search
for a preimage, but abort immediately on records that are not emitted at all.
Decidability of the range makes the guard effective and the search total. -/
theorem exists_computable_selector_of_computable_range (hobs : Computable obs)
    (hr : ComputablePred fun y => ∃ n, obs n = y) :
    ∃ sel : ℕ → ℕ, Computable sel ∧ Selector obs sel := by
  classical
  have hrc : Computable fun y => decide (∃ n, obs n = y) := ComputablePred.decide hr
  set p : ℕ → ℕ → Bool := fun t n => decide (obs n = t) || !(decide (∃ m, obs m = t)) with hp
  have hpc : Computable₂ p := by
    have he : Computable fun q : ℕ × ℕ => decide (q.1 = q.2) := (Primrec.eq (α := ℕ)).decide.to_comp
    have h1 : Computable fun x : ℕ × ℕ => decide (obs x.2 = x.1) :=
      he.comp (Computable.pair (hobs.comp Computable.snd) Computable.fst :
        Computable fun x : ℕ × ℕ => ((obs x.2, x.1) : ℕ × ℕ))
    have h2 : Computable fun x : ℕ × ℕ => !(decide (∃ m, obs m = x.1)) :=
      Primrec.not.to_comp.comp (hrc.comp Computable.fst)
    have hor : Computable fun q : Bool × Bool => (q.1 || q.2) := Primrec.or.to_comp
    exact hor.comp (Computable.pair h1 h2 :
      Computable fun x : ℕ × ℕ =>
        ((decide (obs x.2 = x.1), !(decide (∃ m, obs m = x.1))) : Bool × Bool))
  have hdom : ∀ t : ℕ, (Nat.rfind fun n => (p t n : Part Bool)).Dom := by
    intro t
    by_cases ht : ∃ m, obs m = t
    · obtain ⟨m, hm⟩ := ht
      obtain ⟨n, hn, -⟩ := Nat.rfind_min' (p := p t) (m := m) (by simp [hp, hm])
      exact hn.fst
    · obtain ⟨n, hn, -⟩ := Nat.rfind_min' (p := p t) (m := 0) (by simp [hp, ht])
      exact hn.fst
  refine ⟨fun t => (Nat.rfind fun n => (p t n : Part Bool)).get (hdom t), ?_, ?_⟩
  · have hr2 : Partrec fun t => Nat.rfind fun n => ((p t n : Bool) : Part Bool) :=
      Partrec.rfind (Computable₂.partrec₂ hpc)
    exact Partrec.of_eq hr2 fun t => Part.eq_some_iff.2 (Part.get_mem (hdom t))
  · intro x
    have hex : ∃ m, obs m = obs x := ⟨x, rfl⟩
    have hmem : (Nat.rfind fun n => (p (obs x) n : Part Bool)).get (hdom (obs x)) ∈
        Nat.rfind fun n => (p (obs x) n : Part Bool) := Part.get_mem _
    have hspec : p (obs x)
        ((Nat.rfind fun n => (p (obs x) n : Part Bool)).get (hdom (obs x))) = true := by
      simpa using Nat.rfind_spec hmem
    simp only [hp, Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true',
      decide_eq_false_iff_not] at hspec
    rcases hspec with h | h
    · exact h
    · exact absurd hex h

/-- **Effective selection is exactly decidability of the range.**  For a
computable channel, uniform effective representative selection on the range is
possible if and only if the range itself is a computable set.  This pins the
decoding obstruction of the previous file to a single, classical invariant of the
channel. -/
theorem computable_range_iff_computable_selector (hobs : Computable obs) :
    (ComputablePred fun y => ∃ n, obs n = y) ↔ ∃ sel : ℕ → ℕ, Computable sel ∧ Selector obs sel :=
  ⟨fun hr => exists_computable_selector_of_computable_range hobs hr,
   fun ⟨_, hselc, hsel⟩ => computableRange_of_computable_selector hobs hselc hsel⟩

/-- **The diagonal trace channel has an undecidable range.**  A corollary of the
separation theorem: were the set of emitted records decidable, guarded search
would produce a selector and hence the decoder that cannot exist. -/
theorem range_obsDiag_not_computable :
    ¬ ComputablePred fun y => ∃ n, obsDiag n = y := by
  intro hr
  exact no_computable_selector_diag
    ((computable_range_iff_computable_selector computable_obsDiag).1 hr)

/-- **The range of a computable channel is always recursively enumerable.**
Search for a preimage: the search halts exactly on the emitted records. -/
theorem rePred_range (hobs : Computable obs) : REPred fun y => ∃ n, obs n = y := by
  classical
  have he : Computable fun q : ℕ × ℕ => decide (q.1 = q.2) := (Primrec.eq (α := ℕ)).decide.to_comp
  have h1 : Computable fun x : ℕ × ℕ => decide (obs x.2 = x.1) :=
    he.comp (Computable.pair (hobs.comp Computable.snd) Computable.fst :
      Computable fun x : ℕ × ℕ => ((obs x.2, x.1) : ℕ × ℕ))
  have hpart : Partrec fun y => Nat.rfind fun n => ((decide (obs n = y) : Bool) : Part Bool) :=
    Partrec.rfind (Computable₂.partrec₂ h1)
  refine hpart.dom_re.of_eq fun y => ⟨?_, ?_⟩
  · intro hdom
    have hmem := Part.get_mem hdom
    exact ⟨_, by simpa using Nat.rfind_spec hmem⟩
  · rintro ⟨n, hn⟩
    obtain ⟨m, hm, -⟩ := Nat.rfind_min' (p := fun n => decide (obs n = y)) (m := n) (by simp [hn])
    exact hm.fst

/-- **Σ₁ always, Δ₁ exactly when decodable.**  The emitted-record set of a
computable channel is always recursively enumerable, and it is *computable*
precisely when the channel admits a uniform effective representative selection.
Undecodability of the range is therefore the only possible obstruction to
effective reconstruction. -/
theorem range_re_and_computable_iff_selector (hobs : Computable obs) :
    (REPred fun y => ∃ n, obs n = y) ∧
      ((ComputablePred fun y => ∃ n, obs n = y) ↔
        ∃ sel : ℕ → ℕ, Computable sel ∧ Selector obs sel) :=
  ⟨rePred_range hobs, computable_range_iff_computable_selector hobs⟩

/-! ## 2. The finite-rate bridge to `BoundedError.lean` -/

/-- A channel of finite rate has a computable (indeed finite) range. -/
theorem computableRange_of_finite_range (hfin : (Set.range obs).Finite) :
    ComputablePred fun y => ∃ n, obs n = y := by
  classical
  obtain ⟨L, hL⟩ : ∃ L : List ℕ, ∀ y, y ∈ L ↔ ∃ n, obs n = y :=
    ⟨hfin.toFinset.toList, fun y => by simp [Set.Finite.mem_toFinset, eq_comm]⟩
  have hp : PrimrecPred fun y : ℕ => ∃ a ∈ L, a = y :=
    (Primrec.eq (α := ℕ)).exists_mem_list.comp (Primrec.const L) Primrec.id
  refine hp.computablePred.of_eq fun y => ⟨?_, ?_⟩
  · rintro ⟨a, ha, rfl⟩
    exact (hL a).1 ha
  · rintro ⟨n, rfl⟩
    exact ⟨obs n, (hL _).2 ⟨n, rfl⟩, rfl⟩

/-- **Finite rate implies effective decodability.**  On a channel of finite rate
— the situation studied in `Catalog/Novelty/BoundedError.lean`, where the record
alphabet is finite — every computable fibre-constant quantity has a *total
computable* decoder.  Definability is thus never an obstruction in the finite
theory, and the accuracy bounds proved there are the whole story. -/
theorem computable_decoder_of_finite_range (hobs : Computable obs) (hf : Computable f)
    (hfc : FibreConstant obs f) (hfin : (Set.range obs).Finite) :
    ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obs f dec := by
  obtain ⟨sel, hselc, hsel⟩ :=
    exists_computable_selector_of_computable_range hobs (computableRange_of_finite_range hfin)
  exact computable_decoder_of_selector hsel hselc hf hfc

/-! ## 3. The gap is exactly one jump: limit-computable decoders always exist -/

/-- The stage-`s` approximate decoder: scan the first `s` states and keep the
`f`-value of the last one whose record matches `y` (`0` if none matched). -/
def approxDec (obs f : ℕ → ℕ) (y s : ℕ) : ℕ :=
  Nat.rec 0 (fun k IH => if obs k = y then f k else IH) s

theorem computable_approxDec (hobs : Computable obs) (hf : Computable f) :
    Computable₂ (approxDec obs f) := by
  have hcond : Computable fun a : (ℕ × ℕ) × ℕ × ℕ =>
      if obs a.2.1 = a.1.1 then f a.2.1 else a.2.2 := by
    have he : Computable fun q : ℕ × ℕ => decide (q.1 = q.2) := (Primrec.eq (α := ℕ)).decide.to_comp
    have hb : Computable fun a : (ℕ × ℕ) × ℕ × ℕ => decide (obs a.2.1 = a.1.1) :=
      he.comp (Computable.pair (hobs.comp (Computable.fst.comp Computable.snd))
        (Computable.fst.comp Computable.fst) :
        Computable fun a : (ℕ × ℕ) × ℕ × ℕ => ((obs a.2.1, a.1.1) : ℕ × ℕ))
    have := Computable.cond hb (hf.comp (Computable.fst.comp Computable.snd))
      (Computable.snd.comp Computable.snd)
    simpa [Bool.cond_decide] using this
  exact Computable.nat_rec Computable.snd (Computable.const 0) hcond.to₂

/-- **Convergence with an explicit modulus.**  Past any preimage `x` of the
received record, the approximations have already settled on the correct value. -/
theorem approxDec_eq_of_lt (hfc : FibreConstant obs f) (x : ℕ) :
    ∀ s, x < s → approxDec obs f (obs x) s = f x := by
  intro s hs
  induction s with
  | zero => omega
  | succ k ih =>
    rcases Nat.lt_or_ge x k with h | h
    · have hk := ih h
      simp only [approxDec]
      by_cases hc : obs k = obs x
      · simp [hc, hfc k x hc]
      · simpa [hc] using hk
    · have hxk : x = k := by omega
      subst hxk
      simp [approxDec]

/-- **Every computable fibre-constant quantity has a limit-computable decoder.**
There is a computable double sequence converging to the decoded value, with
modulus bounded by any preimage of the received record.  So the obstruction
exhibited by `no_computable_decoder_diag` costs *exactly one limit*: decoders
always live at the second level of the arithmetical hierarchy, never higher. -/
theorem limit_computable_decoder (hobs : Computable obs) (hf : Computable f)
    (hfc : FibreConstant obs f) :
    ∃ g : ℕ → ℕ → ℕ, Computable₂ g ∧ ∀ x s, x < s → g (obs x) s = f x :=
  ⟨approxDec obs f, computable_approxDec hobs hf, fun x s hs => approxDec_eq_of_lt hfc x s hs⟩

/-- **Sharpness of the one-jump bound.**  For the diagonal trace channel the
decoding problem is limit-computable — with the explicit modulus `s > x` — yet
admits no computable decoder.  Uniform effective representative selection is
therefore strictly harder than fibre constancy, and strictly easier than any
obstruction beyond a single limit. -/
theorem decoding_gap_exactly_one_jump :
    (∃ g : ℕ → ℕ → ℕ, Computable₂ g ∧ ∀ x s, x < s → g (obsDiag x) s = fDiag x) ∧
      ¬ ∃ dec : ℕ → ℕ, Computable dec ∧ Decodes obsDiag fDiag dec :=
  ⟨limit_computable_decoder computable_obsDiag computable_fDiag fibreConstant_diag,
   no_computable_decoder_diag⟩

end EffectiveDecoder