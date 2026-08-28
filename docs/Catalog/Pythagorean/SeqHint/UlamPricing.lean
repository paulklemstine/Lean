import Pythagorean.SeqHint.Adaptive

/-!
# Sequential hint pricing IX: what one lie costs

The isolation ceiling of `SeqHint/Adaptive.lean` prices a *truthful* adaptive
hint channel at `2 ^ k`.  This file prices the same channel when the oracle is
allowed to lie **once**, and finds the answer to be

  `(k + 1) * (number of identifiable candidates) ≤ 2 ^ k`,

i.e. one lie costs exactly the factor `k + 1` — the *same* factor by which a
fixed comparison battery falls short of the adaptive law in
`SeqHint/Battery.lean`.  Noise and non-adaptivity are, in this channel, the same
tax.  (This is the classical Berlekamp/Ulam volume bound, here proved for
arbitrary adaptive strategies against the comparison oracle.)

The mechanism: for a fixed strategy and a fixed hidden value `x`, the `k + 1`
possible lie positions (`lie at step l`, or `no lie at all`) produce `k + 1`
*pairwise distinct* transcripts (`liarT_ne`), because two runs that first differ
at step `l` agree on the whole prefix before `l` and disagree at position `l`.
If the strategy identifies `x` under any single lie, those `k + 1`-element
transcript families must be pairwise disjoint across candidates, and all of them
live in the `2 ^ k` element set of length-`k` bit strings.
-/

namespace Pythagorean.SeqHint

open Finset

/-! ## Transcripts with one lie -/

/-- The transcript of `j` adaptive queries against the hidden value `x` when the
oracle lies exactly at step `l` (and tells the truth at every other step).
Taking `l ≥ j` gives the truthful transcript. -/
def liarT (S : Strategy) (x l : ℕ) : ℕ → List Bool
  | 0 => []
  | (j + 1) =>
      (liarT S x l j) ++ [xor (decide (x ≤ S (liarT S x l j))) (decide (j = l))]

@[simp] lemma liarT_zero (S : Strategy) (x l : ℕ) : liarT S x l 0 = [] := rfl

lemma liarT_succ (S : Strategy) (x l j : ℕ) :
    liarT S x l (j + 1)
      = (liarT S x l j) ++ [xor (decide (x ≤ S (liarT S x l j))) (decide (j = l))] := rfl

lemma liarT_length (S : Strategy) (x l : ℕ) : ∀ j, (liarT S x l j).length = j := by
  intro j
  induction j with
  | zero => simp
  | succ j ih => simp [liarT_succ, ih]

/-- Later transcripts extend earlier ones. -/
lemma liarT_append (S : Strategy) (x l : ℕ) :
    ∀ {i j : ℕ}, i ≤ j → ∃ t : List Bool, liarT S x l j = liarT S x l i ++ t := by
  intro i j hij
  induction j with
  | zero =>
      have : i = 0 := by omega
      subst this
      exact ⟨[], by simp⟩
  | succ j ih =>
      rcases Nat.lt_or_ge i (j + 1) with h | h
      · obtain ⟨t, ht⟩ := ih (by omega)
        refine ⟨t ++ [xor (decide (x ≤ S (liarT S x l j))) (decide (j = l))], ?_⟩
        rw [liarT_succ, ht, List.append_assoc]
      · have : i = j + 1 := by omega
        subst this
        exact ⟨[], by simp⟩

/-- Two runs that lie at different (late enough) steps agree on every earlier
prefix. -/
lemma liarT_agree_before (S : Strategy) (x : ℕ) :
    ∀ {l l' j : ℕ}, j ≤ l → j ≤ l' → liarT S x l j = liarT S x l' j := by
  intro l l' j
  induction j with
  | zero => intro _ _; rfl
  | succ j ih =>
      intro hj hj'
      have hprev := ih (by omega) (by omega)
      have hne : ¬ (j = l) := by omega
      have hne' : ¬ (j = l') := by omega
      rw [liarT_succ, liarT_succ, hprev]
      simp [hne, hne']

/-- **The `k + 1` lie patterns give `k + 1` distinct transcripts.**  Two runs
that lie at different steps disagree at the first of those steps. -/
lemma liarT_ne (S : Strategy) (x : ℕ) {l l' k : ℕ} (hl : l ≤ k) (hl' : l' ≤ k)
    (hne : l ≠ l') : liarT S x l k ≠ liarT S x l' k := by
  -- reduce to the case `l < l'`
  suffices H : ∀ a b : ℕ, a < b → b ≤ k → liarT S x a k ≠ liarT S x b k by
    rcases Nat.lt_or_ge l l' with h | h
    · exact H l l' h hl'
    · have hlt : l' < l := by omega
      exact fun hcon => H l' l hlt hl hcon.symm
  intro a b hab hbk hcon
  have hak : a < k := by omega
  -- the two runs agree on the first `a` steps
  have hprefix : liarT S x a a = liarT S x b a := liarT_agree_before S x le_rfl (by omega)
  -- and disagree at step `a`
  have hA : liarT S x a (a + 1)
      = liarT S x a a ++ [xor (decide (x ≤ S (liarT S x a a))) true] := by
    rw [liarT_succ]; simp
  have hB : liarT S x b (a + 1)
      = liarT S x b a ++ [xor (decide (x ≤ S (liarT S x b a))) false] := by
    rw [liarT_succ]
    have : ¬ (a = b) := by omega
    simp [this]
  -- read off position `a` of the full transcripts
  obtain ⟨t₁, ht₁⟩ := liarT_append S x a (show a + 1 ≤ k by omega)
  obtain ⟨t₂, ht₂⟩ := liarT_append S x b (show a + 1 ≤ k by omega)
  have hlenA : (liarT S x a (a + 1)).length = a + 1 := liarT_length S x a (a + 1)
  have hlenB : (liarT S x b (a + 1)).length = a + 1 := liarT_length S x b (a + 1)
  have hposA : (liarT S x a k)[a]? = (liarT S x a (a + 1))[a]? := by
    rw [ht₁]
    exact List.getElem?_append_left (by omega)
  have hposB : (liarT S x b k)[a]? = (liarT S x b (a + 1))[a]? := by
    rw [ht₂]
    exact List.getElem?_append_left (by omega)
  have hlenPrefA : (liarT S x a a).length = a := liarT_length S x a a
  have hvalA : (liarT S x a (a + 1))[a]?
      = some (xor (decide (x ≤ S (liarT S x a a))) true) := by
    rw [hA]
    simp [hlenPrefA]
  have hlenPrefB : (liarT S x b a).length = a := liarT_length S x b a
  have hvalB : (liarT S x b (a + 1))[a]?
      = some (xor (decide (x ≤ S (liarT S x b a))) false) := by
    rw [hB]
    simp [hlenPrefB]
  rw [hcon] at hposA
  rw [hposB, hvalB] at hposA
  rw [hvalA] at hposA
  rw [← hprefix] at hposA
  simp at hposA

/-! ## The volume bound -/

/-- Any family of length-`k` bit strings has at most `2 ^ k` members. -/
lemma card_le_two_pow_of_length {k : ℕ} (s : Finset (List Bool))
    (hs : ∀ l ∈ s, l.length = k) : s.card ≤ 2 ^ k := by
  have hcard : (Finset.univ : Finset (Fin k → Bool)).card = 2 ^ k := by simp
  rw [← hcard]
  refine Finset.card_le_card_of_injOn (fun l => fun i : Fin k => l.getD i.val false)
    (fun a _ => Finset.mem_coe.2 (Finset.mem_univ _)) ?_
  intro l₁ h₁ l₂ h₂ h
  have hl₁ := hs l₁ (Finset.mem_coe.1 h₁)
  have hl₂ := hs l₂ (Finset.mem_coe.1 h₂)
  refine List.ext_getElem (by rw [hl₁, hl₂]) ?_
  intro i hi₁ hi₂
  have hik : i < k := by rw [hl₁] at hi₁; exact hi₁
  have hget : l₁.getD i false = l₂.getD i false := congrFun h ⟨i, hik⟩
  rw [List.getD_eq_getElem _ _ hi₁, List.getD_eq_getElem _ _ hi₂] at hget
  exact hget

/-- A strategy **one-lie-identifies** the candidate set `C` in `k` queries if no
two distinct candidates can produce the same transcript, even when the oracle is
allowed to lie at one step (the pattern `l = k` meaning "no lie"). -/
def OneLieIdentifies (S : Strategy) (k : ℕ) (C : Finset ℕ) : Prop :=
  ∀ x ∈ C, ∀ y ∈ C, ∀ l ≤ k, ∀ l' ≤ k, liarT S x l k = liarT S y l' k → x = y

/-- **One lie costs the factor `k + 1` (Berlekamp/Ulam volume bound).**  A
`k`-query adaptive comparison strategy that is robust against a single lie can
identify at most `2 ^ k / (k + 1)` candidates — precisely the truthful ceiling
`2 ^ k` divided by the same `k + 1` that separates fixed batteries from adaptive
ones in the noiseless setting. -/
theorem ulam_volume_bound (S : Strategy) (k : ℕ) (C : Finset ℕ)
    (h : OneLieIdentifies S k C) : (k + 1) * C.card ≤ 2 ^ k := by
  classical
  set F : ℕ × ℕ → List Bool := fun p => liarT S p.1 p.2 k with hF
  have hmaps : ∀ p ∈ C ×ˢ range (k + 1), F p ∈ (C ×ˢ range (k + 1)).image F :=
    fun p hp => mem_image_of_mem F hp
  have hinj : Set.InjOn F ↑(C ×ˢ range (k + 1)) := by
    intro p hp q hq hpq
    rw [Finset.mem_coe, Finset.mem_product, mem_range] at hp hq
    have hpq' : liarT S p.1 p.2 k = liarT S q.1 q.2 k := hpq
    have hx : p.1 = q.1 := h p.1 hp.1 q.1 hq.1 p.2 (by omega) q.2 (by omega) hpq'
    have hl : p.2 = q.2 := by
      by_contra hne
      rw [hx] at hpq'
      exact liarT_ne S q.1 (show p.2 ≤ k by omega) (show q.2 ≤ k by omega) hne hpq'
    exact Prod.ext hx hl
  have hcardImage : ((C ×ˢ range (k + 1)).image F).card = (C ×ˢ range (k + 1)).card :=
    Finset.card_image_of_injOn hinj
  have hlen : ∀ l ∈ (C ×ˢ range (k + 1)).image F, l.length = k := by
    intro l hl
    rw [mem_image] at hl
    obtain ⟨p, -, rfl⟩ := hl
    exact liarT_length S p.1 p.2 k
  have hbound := card_le_two_pow_of_length _ hlen
  rw [hcardImage, Finset.card_product, card_range] at hbound
  calc (k + 1) * C.card = C.card * (k + 1) := by ring
    _ ≤ 2 ^ k := hbound

/-- **The noise tax equals the non-adaptivity tax.**  In the truthful channel a
`k`-query adaptive strategy resolves `2 ^ k` candidates and a `k`-threshold fixed
battery resolves `k + 1`; in the one-lie channel an adaptive strategy resolves at
most `2 ^ k / (k + 1)`.  The same factor `k + 1` appears on both sides. -/
theorem noise_tax_eq_nonadaptivity_tax (S : Strategy) (k : ℕ) (C : Finset ℕ)
    (h : OneLieIdentifies S k C) :
    (k + 1) * C.card ≤ 2 ^ k ∧ premium k = 2 ^ k / (k + 1) :=
  ⟨ulam_volume_bound S k C h, rfl⟩

/-- Concretely: no `20`-query strategy survives a single lie on the bit-length-40
window, even though `20` truthful queries pin it exactly.  Robustness to one lie
strictly raises the isolation budget. -/
theorem one_lie_breaks_the_twenty_query_pin (S : Strategy)
    (h : OneLieIdentifies S 20 (Finset.Ico 0 (2 ^ 20))) : False := by
  have hb := ulam_volume_bound S 20 _ h
  rw [Nat.card_Ico] at hb
  norm_num at hb

end Pythagorean.SeqHint