import Mathlib
import Combinatorics.QuartetCodes

/-!
# A matching upper bound: two caterpillars on ten leaves always share a quartet

The companion file `Combinatorics.QuartetCodes` produces, by a first-moment count in ternary
quartet-signature space, exponentially many caterpillar trees with *no* common quartet.  This file
proves the opposite kind of statement for two trees, and is therefore the boundary of the
lower-bound method: **any two caterpillars on at least ten leaves display a common quartet**.

The engine is a self-contained proof of the Erdős–Szekeres theorem in the shape we need: an
injective map on a linearly ordered fintype with more than `9` elements has a strictly monotone
(increasing or decreasing) subset of size four.  Combined with the observation that a quadruple of
leaves ordered the same way — or in exactly opposite ways — by two caterpillars carries the same
quartet type, this yields the upper bound.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
Since the first-moment bound needs `n^4 < 3^m`, it is vacuous for two trees (`m = 1`).  Conjecture:
for two trees a *constant* number of leaves already forces a common quartet, and Erdős–Szekeres
supplies the constant.

## Experiment (Experimenter)
Exhaustive search over all `120^2` pairs of leaf orders on five leaves found pairs with no common
quartet; over all pairs on six leaves none exists (see `ComputationalEvidence.md`).  So the true
threshold for two caterpillars is `6`; Erdős–Szekeres with `r = s = 3` proves `10`, and the
five-leaf pair `not_isAgreementThreshold_five_two` shows the truth is at least `6`.

## Analysis (Analyst)
The gap `6 ≤ h_cat(2) ≤ 10` isolates exactly what the monotone-subsequence argument loses: it
insists on a quadruple that is monotone, whereas a common quartet only needs the *unordered*
`2 + 2` split to coincide.

## Critique (Critic)
The upper bound is proved for caterpillars (leaf orders), the same class in which the lower bound
constructs its avoiding families, so the two bounds are comparable.  Nothing here is proved by
`decide` on the whole statement: the Erdős–Szekeres step is a genuine pigeonhole over the pair
`(longest increasing chain, longest decreasing chain)`.
-/

open Finset

namespace QuartetCodes

/-! ## Erdős–Szekeres, self-contained -/

section ErdosSzekeres

variable {α β : Type*} [LinearOrder α] [Fintype α] [DecidableEq α] [LinearOrder β]

/-- `t` is a strictly increasing chain for `f`. -/
def IsIncChain (f : α → β) (t : Finset α) : Prop :=
  ∀ x ∈ t, ∀ y ∈ t, x < y → f x < f y

/-- `t` is a strictly decreasing chain for `f`. -/
def IsDecChain (f : α → β) (t : Finset α) : Prop :=
  ∀ x ∈ t, ∀ y ∈ t, x < y → f y < f x

instance (f : α → β) (t : Finset α) : Decidable (IsIncChain f t) := by
  unfold IsIncChain; infer_instance

instance (f : α → β) (t : Finset α) : Decidable (IsDecChain f t) := by
  unfold IsDecChain; infer_instance

/-- The increasing chains ending at `i`. -/
def incChainsTo (f : α → β) (i : α) : Finset (Finset α) :=
  {t : Finset α | IsIncChain f t ∧ i ∈ t ∧ ∀ j ∈ t, j ≤ i}

/-- The decreasing chains ending at `i`. -/
def decChainsTo (f : α → β) (i : α) : Finset (Finset α) :=
  {t : Finset α | IsDecChain f t ∧ i ∈ t ∧ ∀ j ∈ t, j ≤ i}

/-- Length of the longest increasing chain ending at `i`. -/
def incTo (f : α → β) (i : α) : ℕ := (incChainsTo f i).sup Finset.card

/-- Length of the longest decreasing chain ending at `i`. -/
def decTo (f : α → β) (i : α) : ℕ := (decChainsTo f i).sup Finset.card

lemma singleton_mem_incChainsTo (f : α → β) (i : α) : ({i} : Finset α) ∈ incChainsTo f i := by
  simp only [incChainsTo, Finset.mem_filter, Finset.mem_univ, true_and]
  refine ⟨?_, by simp, ?_⟩
  · intro x hx y hy hxy
    simp only [Finset.mem_singleton] at hx hy
    exact absurd (hx.trans hy.symm) (ne_of_lt hxy)
  · intro j hj; simp only [Finset.mem_singleton] at hj; exact le_of_eq hj

lemma singleton_mem_decChainsTo (f : α → β) (i : α) : ({i} : Finset α) ∈ decChainsTo f i := by
  simp only [decChainsTo, Finset.mem_filter, Finset.mem_univ, true_and]
  refine ⟨?_, by simp, ?_⟩
  · intro x hx y hy hxy
    simp only [Finset.mem_singleton] at hx hy
    exact absurd (hx.trans hy.symm) (ne_of_lt hxy)
  · intro j hj; simp only [Finset.mem_singleton] at hj; exact le_of_eq hj

lemma one_le_incTo (f : α → β) (i : α) : 1 ≤ incTo f i := by
  have h : ({i} : Finset α).card ≤ incTo f i :=
    Finset.le_sup (f := Finset.card) (singleton_mem_incChainsTo f i)
  rwa [Finset.card_singleton] at h

lemma one_le_decTo (f : α → β) (i : α) : 1 ≤ decTo f i := by
  have h : ({i} : Finset α).card ≤ decTo f i :=
    Finset.le_sup (f := Finset.card) (singleton_mem_decChainsTo f i)
  rwa [Finset.card_singleton] at h

/-- An increasing step strictly increases the longest increasing chain length. -/
lemma incTo_lt_incTo {f : α → β} {i j : α} (hij : i < j) (hf : f i < f j) :
    incTo f i < incTo f j := by
  obtain ⟨t, ht, hsup⟩ :=
    Finset.exists_mem_eq_sup (incChainsTo f i) ⟨{i}, singleton_mem_incChainsTo f i⟩ Finset.card
  simp only [incChainsTo, Finset.mem_filter, Finset.mem_univ, true_and] at ht
  obtain ⟨hchain, hmem, hle⟩ := ht
  have hjt : j ∉ t := fun hj => absurd (hle j hj) (not_le.2 hij)
  have hnew : insert j t ∈ incChainsTo f j := by
    simp only [incChainsTo, Finset.mem_filter, Finset.mem_univ, true_and]
    refine ⟨?_, Finset.mem_insert_self _ _, ?_⟩
    · intro x hx y hy hxy
      rcases Finset.mem_insert.1 hx with rfl | hx' <;> rcases Finset.mem_insert.1 hy with rfl | hy'
      · exact absurd rfl (ne_of_lt hxy)
      · exact absurd (hle y hy') (not_le.2 (lt_trans hij hxy))
      · -- `x ∈ t`, `y = j`
        have hxi : x ≤ i := hle x hx'
        rcases eq_or_lt_of_le hxi with rfl | hlt
        · exact hf
        · exact lt_trans (hchain x hx' i hmem hlt) hf
      · exact hchain x hx' y hy' hxy
    · intro y hy
      rcases Finset.mem_insert.1 hy with rfl | hy'
      · exact le_refl _
      · exact le_of_lt (lt_of_le_of_lt (hle y hy') hij)
  have hcard : (insert j t).card = t.card + 1 := Finset.card_insert_of_notMem hjt
  have hbig : t.card + 1 ≤ incTo f j := by
    rw [← hcard]; exact Finset.le_sup hnew
  have hi' : incTo f i = t.card := hsup
  omega

/-- A decreasing step strictly increases the longest decreasing chain length. -/
lemma decTo_lt_decTo {f : α → β} {i j : α} (hij : i < j) (hf : f j < f i) :
    decTo f i < decTo f j := by
  obtain ⟨t, ht, hsup⟩ :=
    Finset.exists_mem_eq_sup (decChainsTo f i) ⟨{i}, singleton_mem_decChainsTo f i⟩ Finset.card
  simp only [decChainsTo, Finset.mem_filter, Finset.mem_univ, true_and] at ht
  obtain ⟨hchain, hmem, hle⟩ := ht
  have hjt : j ∉ t := fun hj => absurd (hle j hj) (not_le.2 hij)
  have hnew : insert j t ∈ decChainsTo f j := by
    simp only [decChainsTo, Finset.mem_filter, Finset.mem_univ, true_and]
    refine ⟨?_, Finset.mem_insert_self _ _, ?_⟩
    · intro x hx y hy hxy
      rcases Finset.mem_insert.1 hx with rfl | hx' <;> rcases Finset.mem_insert.1 hy with rfl | hy'
      · exact absurd rfl (ne_of_lt hxy)
      · exact absurd (hle y hy') (not_le.2 (lt_trans hij hxy))
      · have hxi : x ≤ i := hle x hx'
        rcases eq_or_lt_of_le hxi with rfl | hlt
        · exact hf
        · exact lt_trans hf (hchain x hx' i hmem hlt)
      · exact hchain x hx' y hy' hxy
    · intro y hy
      rcases Finset.mem_insert.1 hy with rfl | hy'
      · exact le_refl _
      · exact le_of_lt (lt_of_le_of_lt (hle y hy') hij)
  have hcard : (insert j t).card = t.card + 1 := Finset.card_insert_of_notMem hjt
  have hbig : t.card + 1 ≤ decTo f j := by
    rw [← hcard]; exact Finset.le_sup hnew
  have hi' : decTo f i = t.card := hsup
  omega

/-- **Erdős–Szekeres.**  An injective map on a linearly ordered fintype with more than `r * r`
elements has a strictly monotone subset with more than `r` elements. -/
theorem exists_monotone_chain (f : α → β) (hf : Function.Injective f) {r : ℕ}
    (hcard : r * r < Fintype.card α) :
    ∃ t : Finset α, r < t.card ∧ (IsIncChain f t ∨ IsDecChain f t) := by
  by_contra hcon
  push_neg at hcon
  have hinc : ∀ i : α, incTo f i ≤ r := by
    intro i
    refine Finset.sup_le fun t ht => ?_
    simp only [incChainsTo, Finset.mem_filter, Finset.mem_univ, true_and] at ht
    by_contra hgt
    exact (hcon t (by omega)).1 ht.1
  have hdec : ∀ i : α, decTo f i ≤ r := by
    intro i
    refine Finset.sup_le fun t ht => ?_
    simp only [decChainsTo, Finset.mem_filter, Finset.mem_univ, true_and] at ht
    by_contra hgt
    exact (hcon t (by omega)).2 ht.1
  have hinj : ∀ i ∈ (Finset.univ : Finset α), ∀ j ∈ (Finset.univ : Finset α),
      (incTo f i, decTo f i) = (incTo f j, decTo f j) → i = j := by
    intro i _ j _ hpair
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · rcases lt_or_gt_of_ne (fun hfe => hne (hf hfe)) with hfv | hfv
      · exact absurd (congrArg Prod.fst hpair) (ne_of_lt (incTo_lt_incTo h hfv))
      · exact absurd (congrArg Prod.snd hpair) (ne_of_lt (decTo_lt_decTo h hfv))
    · rcases lt_or_gt_of_ne (fun hfe => hne (hf hfe)) with hfv | hfv
      · exact absurd (congrArg Prod.snd hpair).symm (ne_of_lt (decTo_lt_decTo h hfv))
      · exact absurd (congrArg Prod.fst hpair).symm (ne_of_lt (incTo_lt_incTo h hfv))
  have hmaps : ∀ i ∈ (Finset.univ : Finset α),
      (incTo f i, decTo f i) ∈ (Finset.Icc 1 r ×ˢ Finset.Icc 1 r : Finset (ℕ × ℕ)) := by
    intro i _
    simp only [Finset.mem_product, Finset.mem_Icc]
    exact ⟨⟨one_le_incTo f i, hinc i⟩, ⟨one_le_decTo f i, hdec i⟩⟩
  have hle := Finset.card_le_card_of_injOn (fun i => (incTo f i, decTo f i))
    (fun i hi => Finset.mem_coe.2 (hmaps i hi)) (fun i hi j hj h => hinj i hi j hj h)
  have hprod : (Finset.Icc 1 r ×ˢ Finset.Icc 1 r : Finset (ℕ × ℕ)).card = r * r := by
    simp [Finset.card_product, Nat.card_Icc]
  rw [Finset.card_univ, hprod] at hle
  omega

/-- The special case used below: more than nine elements force a monotone quadruple. -/
theorem exists_monotone_four (f : α → β) (hf : Function.Injective f)
    (hcard : 9 < Fintype.card α) :
    ∃ t : Finset α, 4 ≤ t.card ∧ (IsIncChain f t ∨ IsDecChain f t) := by
  obtain ⟨t, ht, hchain⟩ := exists_monotone_chain f hf (r := 3) (by omega)
  exact ⟨t, by omega, hchain⟩

end ErdosSzekeres

/-! ## Two caterpillars on ten leaves share a quartet -/

section PairUpperBound

variable {n : ℕ}

/-- Four leaves listed in increasing order of a monotone (or antitone) chain. -/
lemma exists_four_of_card {t : Finset (Fin n)} (ht : 4 ≤ t.card) :
    ∃ x y z w : Fin n, x ∈ t ∧ y ∈ t ∧ z ∈ t ∧ w ∈ t ∧ x < y ∧ y < z ∧ z < w := by
  obtain ⟨t', hsub, hcard⟩ := Finset.exists_subset_card_eq ht
  let e := t'.orderIsoOfFin hcard
  refine ⟨(e 0 : Fin n), (e 1 : Fin n), (e 2 : Fin n), (e 3 : Fin n),
    hsub (e 0).2, hsub (e 1).2, hsub (e 2).2, hsub (e 3).2, ?_, ?_, ?_⟩
  · exact (Subtype.coe_lt_coe).2 (e.lt_iff_lt.2 (by decide))
  · exact (Subtype.coe_lt_coe).2 (e.lt_iff_lt.2 (by decide))
  · exact (Subtype.coe_lt_coe).2 (e.lt_iff_lt.2 (by decide))

/-- **Upper bound for two trees.**  Any two caterpillars on at least ten leaves display a common
quartet. -/
theorem caterpillar_pair_common_quartet (hn : 10 ≤ n) (π ρ : Equiv.Perm (Fin n)) :
    ∃ a b c d : Fin n, a ≠ b ∧ a ≠ c ∧ a ≠ d ∧ b ≠ c ∧ b ≠ d ∧ c ≠ d ∧
      qcode π a b c d = qcode ρ a b c d := by
  set f : Fin n → Fin n := fun i => ρ (π.symm i) with hf
  have hfinj : Function.Injective f := fun x y hxy => by
    have := π.symm.injective (ρ.injective hxy)
    simpa using this
  have hcard : 9 < Fintype.card (Fin n) := by simpa using (by omega : 9 < n)
  obtain ⟨t, htcard, hchain⟩ := exists_monotone_four f hfinj hcard
  obtain ⟨i, j, k, l, hi, hj, hk, hl, hij, hjk, hkl⟩ := exists_four_of_card htcard
  refine ⟨π.symm i, π.symm j, π.symm k, π.symm l, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact fun h => absurd (π.symm.injective h) (ne_of_lt hij)
  · exact fun h => absurd (π.symm.injective h) (ne_of_lt (hij.trans hjk))
  · exact fun h => absurd (π.symm.injective h) (ne_of_lt (hij.trans (hjk.trans hkl)))
  · exact fun h => absurd (π.symm.injective h) (ne_of_lt hjk)
  · exact fun h => absurd (π.symm.injective h) (ne_of_lt (hjk.trans hkl))
  · exact fun h => absurd (π.symm.injective h) (ne_of_lt hkl)
  · have hpi : ∀ x : Fin n, π (π.symm x) = x := fun x => π.apply_symm_apply x
    have hcode_pi : qcode π (π.symm i) (π.symm j) (π.symm k) (π.symm l) = 0 := by
      unfold qcode
      rw [hpi, hpi, hpi, hpi]
      refine (code3_eq_zero_iff _ _ _ _).2 (Or.inl ?_)
      have h1 : i.val < j.val := hij
      have h2 : j.val < k.val := hjk
      have h3 : k.val < l.val := hkl
      omega
    have hcode_rho : qcode ρ (π.symm i) (π.symm j) (π.symm k) (π.symm l) = 0 := by
      have hval : ∀ x : Fin n, ρ (π.symm x) = f x := fun x => rfl
      unfold qcode
      rw [hval, hval, hval, hval]
      refine (code3_eq_zero_iff _ _ _ _).2 ?_
      rcases hchain with hinc | hdec
      · left
        have h1 : (f i).val < (f j).val := hinc i hi j hj hij
        have h2 : (f j).val < (f k).val := hinc j hj k hk hjk
        have h3 : (f k).val < (f l).val := hinc k hk l hl hkl
        omega
      · right
        have h1 : (f j).val < (f i).val := hdec i hi j hj hij
        have h2 : (f k).val < (f j).val := hdec j hj k hk hjk
        have h3 : (f l).val < (f k).val := hdec k hk l hl hkl
        omega
    rw [hcode_pi, hcode_rho]

end PairUpperBound

/-! ## A doubly exponential upper bound for any number of trees -/

section FamilyUpperBound

lemma IsIncChain.mono {α β : Type*} [LinearOrder α] [LinearOrder β] {f : α → β}
    {t s : Finset α} (h : IsIncChain f s) (hts : t ⊆ s) : IsIncChain f t :=
  fun x hx y hy hxy => h x (hts hx) y (hts hy) hxy

lemma IsDecChain.mono {α β : Type*} [LinearOrder α] [LinearOrder β] {f : α → β}
    {t s : Finset α} (h : IsDecChain f s) (hts : t ⊆ s) : IsDecChain f t :=
  fun x hx y hy hxy => h x (hts hx) y (hts hy) hxy

variable {α β : Type*} [LinearOrder α] [Fintype α] [DecidableEq α] [LinearOrder β]

omit [Fintype α] in
/-- Erdős–Szekeres inside a prescribed finite set. -/
lemma exists_monotone_chain_subset (f : α → β) (hf : Function.Injective f) {r : ℕ}
    {S : Finset α} (hcard : r * r < S.card) :
    ∃ t ⊆ S, r < t.card ∧ (IsIncChain f t ∨ IsDecChain f t) := by
  have hcard' : r * r < Fintype.card {x // x ∈ S} := by rwa [Fintype.card_coe]
  obtain ⟨t', ht', hchain⟩ := exists_monotone_chain (fun x : {x // x ∈ S} => f x.1)
    (fun x y h => Subtype.ext (hf h)) hcard'
  refine ⟨Finset.image (fun x : {x // x ∈ S} => (x : α)) t', ?_, ?_, ?_⟩
  · intro y hy
    obtain ⟨x, _, rfl⟩ := Finset.mem_image.1 hy
    exact x.2
  · rwa [Finset.card_image_of_injective _ Subtype.coe_injective]
  · rcases hchain with h | h
    · refine Or.inl fun x hx y hy hxy => ?_
      obtain ⟨x', hx', rfl⟩ := Finset.mem_image.1 hx
      obtain ⟨y', hy', rfl⟩ := Finset.mem_image.1 hy
      exact h x' hx' y' hy' (Subtype.coe_lt_coe.1 hxy)
    · refine Or.inr fun x hx y hy hxy => ?_
      obtain ⟨x', hx', rfl⟩ := Finset.mem_image.1 hx
      obtain ⟨y', hy', rfl⟩ := Finset.mem_image.1 hy
      exact h x' hx' y' hy' (Subtype.coe_lt_coe.1 hxy)

omit [Fintype α] in
/-- **Iterated Erdős–Szekeres.**  A set of more than `3 ^ (2 ^ k)` elements contains four elements
on which each of `k` given injections is monotone. -/
lemma exists_common_monotone (F : ℕ → α → β) (hF : ∀ i, Function.Injective (F i)) :
    ∀ (k : ℕ) (S : Finset α), 3 ^ (2 ^ k) < S.card →
      ∃ t ⊆ S, 3 < t.card ∧ ∀ i < k, (IsIncChain (F i) t ∨ IsDecChain (F i) t) := by
  intro k
  induction k with
  | zero =>
    intro S hS
    exact ⟨S, Finset.Subset.refl S, by simpa using hS, fun i hi => absurd hi (by omega)⟩
  | succ k ih =>
    intro S hS
    have hpow : (3 : ℕ) ^ (2 ^ k) * 3 ^ (2 ^ k) < S.card := by
      have : (3 : ℕ) ^ (2 ^ k) * 3 ^ (2 ^ k) = 3 ^ (2 ^ (k + 1)) := by
        rw [← pow_add, pow_succ]
        ring_nf
      rw [this]; exact hS
    obtain ⟨t₁, ht₁S, ht₁card, ht₁chain⟩ := exists_monotone_chain_subset (F k) (hF k) hpow
    obtain ⟨t, hts, htcard, hmono⟩ := ih t₁ ht₁card
    refine ⟨t, hts.trans ht₁S, htcard, fun i hi => ?_⟩
    rcases Nat.lt_succ_iff_lt_or_eq.1 hi with hlt | rfl
    · exact hmono i hlt
    · rcases ht₁chain with h | h
      · exact Or.inl (h.mono hts)
      · exact Or.inr (h.mono hts)

variable {n : ℕ}

/-- Four leaves in increasing order on which the leaf order `π` is monotone carry the quartet
type `0`. -/
lemma qcode_eq_zero_of_chain {π : Equiv.Perm (Fin n)} {t : Finset (Fin n)} {a b c d : Fin n}
    (ha : a ∈ t) (hb : b ∈ t) (hc : c ∈ t) (hd : d ∈ t) (hab : a < b) (hbc : b < c) (hcd : c < d)
    (h : IsIncChain (fun x => π x) t ∨ IsDecChain (fun x => π x) t) :
    qcode π a b c d = 0 := by
  unfold qcode
  refine (code3_eq_zero_iff _ _ _ _).2 ?_
  rcases h with h | h
  · left
    have h1 : (π a).val < (π b).val := h a ha b hb hab
    have h2 : (π b).val < (π c).val := h b hb c hc hbc
    have h3 : (π c).val < (π d).val := h c hc d hd hcd
    omega
  · right
    have h1 : (π b).val < (π a).val := h a ha b hb hab
    have h2 : (π c).val < (π b).val := h b hb c hc hbc
    have h3 : (π d).val < (π c).val := h c hc d hd hcd
    omega

/-- **Doubly exponential upper bound.**  Any `k` caterpillars on more than `3 ^ (2 ^ k)` leaves
display a common quartet.  Together with `exponential_lower_bound` this brackets the least leaf
number forcing a common quartet between an exponential and a doubly exponential function of the
number of trees. -/
theorem caterpillar_family_common_quartet {k : ℕ} (T : Fin k → Equiv.Perm (Fin n))
    (hn : 3 ^ (2 ^ k) < n) :
    ∃ a b c d : Fin n, a ≠ b ∧ a ≠ c ∧ a ≠ d ∧ b ≠ c ∧ b ≠ d ∧ c ≠ d ∧
      ∀ i : Fin k, qcode (T i) a b c d = 0 := by
  classical
  set F : ℕ → Fin n → Fin n := fun i => if h : i < k then ⇑(T ⟨i, h⟩) else id with hFdef
  have hF : ∀ i, Function.Injective (F i) := by
    intro i
    by_cases h : i < k
    · simpa [hFdef, h] using (T ⟨i, h⟩).injective
    · simpa [hFdef, h] using Function.injective_id
  have hcard : 3 ^ (2 ^ k) < (Finset.univ : Finset (Fin n)).card := by simpa using hn
  obtain ⟨t, _, htcard, hmono⟩ := exists_common_monotone F hF k Finset.univ hcard
  obtain ⟨a, b, c, d, ha, hb, hc, hd, hab, hbc, hcd⟩ := exists_four_of_card (by omega : 4 ≤ t.card)
  refine ⟨a, b, c, d, ne_of_lt hab, ne_of_lt (hab.trans hbc), ne_of_lt (hab.trans (hbc.trans hcd)),
    ne_of_lt hbc, ne_of_lt (hbc.trans hcd), ne_of_lt hcd, fun i => ?_⟩
  have hi := hmono i.val i.isLt
  have hFi : F i.val = ⇑(T i) := by
    simp only [hFdef, dif_pos i.isLt]
  rw [hFi] at hi
  exact qcode_eq_zero_of_chain ha hb hc hd hab hbc hcd hi

end FamilyUpperBound

end QuartetCodes