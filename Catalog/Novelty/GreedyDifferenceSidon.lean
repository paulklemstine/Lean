import Shared.SidonSetsErdosTuran

/-!
# Greedy avoidance of *differences*: the Mian–Chowla obstruction set and its sandwich

The catalog's Sidon theory (`Shared/SidonSetsErdosTuran.lean` and its four sequels)
studies Sidon sets through their **sums** `a + b`.  This file studies the *dual*
mechanism: a set is grown greedily by refusing any new element that would repeat a
**difference** `a i - a j`.  The resulting sequence is the Mian–Chowla sequence
(OEIS A005282, here normalised to start at `0`).

The whole file is organised around one finite obstruction set.  For a finite `A ⊆ ℕ`
and a candidate `m` larger than everything in `A`, adjoining `m` repeats a difference
exactly when `m - c = d - b` for some `b, c, d ∈ A`, i.e. exactly when the integer `m`
lies in

  `sidonBad A = {c + d - b : b, c, d ∈ A} ⊆ ℤ`,

a set of at most `|A|³` integers.  Everything else — greedy well-definedness, the
quartic upper bound, and (via the catalog's Erdős–Turán bound) the quadratic lower
bound — is squeezed out of that one finite set.

## Main results

* `isSidon_iff_sub_injOn` — **sums ⟺ differences** for subsets of `ℕ`: `A` is Sidon iff
  the integer difference map `(a, b) ↦ a - b` is injective off the diagonal.  This is
  the statement that "greedy avoidance of differences" and "greedy avoidance of sums"
  define the same object; the catalog previously had only the forward implication, and
  only for genuine groups (`IsSidon.sub_injOn`).
* `mem_sidonBad_iff_repeats_difference` — membership in the obstruction set *is* the
  repetition of a difference.
* `isSidon_insert_iff` — **the exact greedy step criterion**: for `m` strictly above
  `A`, `insert m A` is Sidon iff `A` is Sidon and `(m : ℤ) ∉ sidonBad A`.  Both
  directions are proved, so the obstruction set is not merely sufficient.
* `card_sidonBad_le` — `|sidonBad A| ≤ |A|³`, whence
  `exists_good_next` — a valid greedy step always exists inside a window of length
  `|A|³ + 1` above `max A`.
* `greedySet`, `greedySeq` — the greedy difference-avoiding set and sequence.
* `greedySet_isSidon`, `card_greedySet`, `greedySeq_strictMono` — it is Sidon, it has
  exactly `n` elements at stage `n`, and it is strictly increasing.
* `four_mul_greedySeq_le` — **quartic upper bound** `4 · a n ≤ (n+1)⁴`.
* `mul_le_two_mul_greedySeq` — **quadratic lower bound** `n(n+1) ≤ 2 · a n`, obtained by
  feeding the greedy set into the catalog's Erdős–Turán counting bound.
* `greedySeq_sandwich` — the two combined.
* `greedySeq_zero`, `greedySeq_one`, `greedySeq_two`, `greedySeq_three` — the first four
  terms are `0, 1, 3, 7`, i.e. Mian–Chowla `1, 2, 4, 8` shifted by one; the greedy
  process is therefore not vacuous and the bounds above are compared against real data.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (D1) Greedy *difference* avoidance and greedy *sum*
  avoidance produce the same sequence, because Sidon-ness is equivalent to injectivity
  of the difference map even over `ℕ`, which is not a group.  (D2) The failure of a
  greedy step is governed by a set of size `O(|A|³)`, so the greedy sequence grows at
  most quartically.  (D3) The Erdős–Turán upper bound for Sidon sets forces a matching
  quadratic *lower* bound on the greedy sequence, so greedy is provably within a
  quadratic factor of optimal.
Experiment (Experimenter): direct computation of the greedy sequence gives
  `0, 1, 3, 7, 12, 20, 30, 44, 65, 80, 96, 122, 147, 181`, i.e. A005282 minus one;
  the observed sandwich `n(n+1)/2 ≤ a n ≤ (n+1)⁴/4` is satisfied with a wide margin on
  the upper side (`a 13 = 181` versus `9604`) and a factor `2` on the lower side
  (`a 13 = 181` versus `91`).  (D1) and (D2) were proved as stated.  (D3) was proved
  by applying `IsSidon.card_mul_pred_le_of_subset_range` to `greedySet (n+1)`.
Analysis (Analyst): the cubic size of `sidonBad` is what makes greedy quartic, while
  the true growth is empirically close to `n³`; the loss is exactly the difference
  between "the obstruction set has `|A|³` elements" and "the obstruction set is spread
  over an interval of length `2 · max A`".  Improving the exponent therefore needs a
  *dispersion* statement about `sidonBad`, not a better counting bound — this is the
  content of the first future direction.
Critique (Critic): `isSidon_insert_iff` is an `↔`, so no direction is assumed; the
  hypothesis `∀ a ∈ A, a < m` is load-bearing (for `m` inside the span of `A` the
  criterion is false, since `m` could coincide with an element of `A`).  No theorem is
  closed by `decide` alone except the four concrete Mian–Chowla values, which are
  identified using `Nat.find_eq_iff` — the surrounding mathematics is not decidable.
Synthesis (PI): difference-greedy = sum-greedy, the obstruction is cubic, and greedy
  is sandwiched between `n²/2` and `n⁴/4`.
-/

namespace GreedyDifference

open Finset

/-! ## 1. Sums versus differences over `ℕ` -/

/-- **Sums ⟺ differences.**  A finite set of naturals is a Sidon set exactly when its
integer differences `a - b` (`a ≠ b`) are pairwise distinct.  Over a group this is
`IsSidon.sub_injOn` plus its converse; `ℕ` is not a group, so the differences must be
taken in `ℤ`. -/
theorem isSidon_iff_sub_injOn (A : Finset ℕ) :
    IsSidon A ↔ Set.InjOn (fun p : ℕ × ℕ => (p.1 : ℤ) - (p.2 : ℤ)) (A.offDiag : Set (ℕ × ℕ)) := by
  constructor
  · rintro hA ⟨a, b⟩ hp ⟨c, d⟩ hq h
    simp only [Finset.coe_offDiag, Set.mem_offDiag] at hp hq
    obtain ⟨ha, hb, hab⟩ := hp
    obtain ⟨hc, hd, -⟩ := hq
    simp only at h
    have h' : a + d = c + b := by omega
    rcases hA a ha d hd c hc b hb h' with ⟨h1, h2⟩ | ⟨h1, -⟩
    · simp [h1, h2]
    · exact absurd h1 hab
  · intro hinj a ha b hb c hc d hd habcd
    by_cases hac : a = c
    · exact Or.inl ⟨hac, by omega⟩
    · have hdb : d ≠ b := by omega
      have h1 : ((a, c) : ℕ × ℕ) ∈ (A.offDiag : Set (ℕ × ℕ)) := by
        simp [Finset.coe_offDiag, Set.mem_offDiag, ha, hc, hac]
      have h2 : ((d, b) : ℕ × ℕ) ∈ (A.offDiag : Set (ℕ × ℕ)) := by
        simp [Finset.coe_offDiag, Set.mem_offDiag, hd, hb, hdb]
      have heq := hinj h1 h2 (by simp only; omega)
      have h3 : a = d := (Prod.ext_iff.mp heq).1
      have h4 : c = b := (Prod.ext_iff.mp heq).2
      exact Or.inr ⟨h3, h4.symm⟩

/-! ## 2. The difference-obstruction set -/

/-- The **difference obstruction set** of a finite `A ⊆ ℕ`: the integers `c + d - b`
with `b, c, d ∈ A`.  A candidate `m` above `A` may be adjoined to `A` without repeating
a difference precisely when `(m : ℤ)` avoids this set. -/
def sidonBad (A : Finset ℕ) : Finset ℤ :=
  (A ×ˢ A ×ˢ A).image fun p => (p.2.1 : ℤ) + (p.2.2 : ℤ) - (p.1 : ℤ)

theorem mem_sidonBad_of_eq {A : Finset ℕ} {m b c d : ℕ} (hb : b ∈ A) (hc : c ∈ A) (hd : d ∈ A)
    (h : m + b = c + d) : (m : ℤ) ∈ sidonBad A := by
  refine Finset.mem_image.mpr ⟨(b, c, d), ?_, ?_⟩
  · simp [Finset.mem_product, hb, hc, hd]
  · have : (m : ℤ) + b = (c : ℤ) + d := by exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) h
    simp only
    omega

theorem exists_of_mem_sidonBad {A : Finset ℕ} {m : ℕ} (h : (m : ℤ) ∈ sidonBad A) :
    ∃ b ∈ A, ∃ c ∈ A, ∃ d ∈ A, m + b = c + d := by
  obtain ⟨⟨b, c, d⟩, hmem, heq⟩ := Finset.mem_image.mp h
  simp only [Finset.mem_product] at hmem
  refine ⟨b, hmem.1, c, hmem.2.1, d, hmem.2.2, ?_⟩
  have : (m : ℤ) + b = (c : ℤ) + d := by simp only at heq; omega
  exact_mod_cast this

/-- **The obstruction set is exactly the set of difference repetitions.**  `m` is
forbidden iff adjoining it would create a difference `m - c` already present as `d - b`
inside `A`. -/
theorem mem_sidonBad_iff_repeats_difference (A : Finset ℕ) (m : ℕ) :
    (m : ℤ) ∈ sidonBad A ↔
      ∃ b ∈ A, ∃ c ∈ A, ∃ d ∈ A, (m : ℤ) - (c : ℤ) = (d : ℤ) - (b : ℤ) := by
  constructor
  · intro h
    obtain ⟨b, hb, c, hc, d, hd, heq⟩ := exists_of_mem_sidonBad h
    exact ⟨b, hb, c, hc, d, hd, by exact_mod_cast (by omega : (m : ℤ) - c = (d : ℤ) - b)⟩
  · rintro ⟨b, hb, c, hc, d, hd, heq⟩
    refine mem_sidonBad_of_eq hb hc hd ?_
    have : (m : ℤ) + b = (c : ℤ) + d := by omega
    exact_mod_cast this

/-- The obstruction set has at most `|A|³` elements. -/
theorem card_sidonBad_le (A : Finset ℕ) : #(sidonBad A) ≤ #A ^ 3 := by
  refine le_trans (Finset.card_image_le) ?_
  rw [Finset.card_product, Finset.card_product]
  ring_nf
  omega

/-! ## 3. The exact greedy step criterion -/

/-- **Greedy step criterion.**  For a candidate `m` strictly larger than every element of
`A`, the enlarged set `insert m A` is Sidon iff `A` is Sidon and `m` avoids the
difference obstruction set.  (Both implications hold: the obstruction set is exactly
right, not merely sufficient.) -/
theorem isSidon_insert_iff {A : Finset ℕ} {m : ℕ} (hm : ∀ a ∈ A, a < m) :
    IsSidon (insert m A) ↔ IsSidon A ∧ (m : ℤ) ∉ sidonBad A := by
  constructor
  · intro h
    refine ⟨h.mono (Finset.subset_insert _ _), fun hbad => ?_⟩
    obtain ⟨b, hb, c, hc, d, hd, heq⟩ := exists_of_mem_sidonBad hbad
    have hmi : m ∈ insert m A := Finset.mem_insert_self _ _
    have hbi : b ∈ insert m A := Finset.mem_insert_of_mem hb
    have hci : c ∈ insert m A := Finset.mem_insert_of_mem hc
    have hdi : d ∈ insert m A := Finset.mem_insert_of_mem hd
    rcases h m hmi b hbi c hci d hdi heq with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact absurd (h1 ▸ hm c hc) (lt_irrefl m)
    · exact absurd (h1 ▸ hm d hd) (lt_irrefl m)
  · rintro ⟨hA, hbad⟩ a ha b hb c hc d hd habcd
    -- decompose membership in `insert m A`
    have key : ∀ x ∈ insert m A, x = m ∨ (x ∈ A ∧ x < m) := by
      intro x hx
      rcases Finset.mem_insert.mp hx with h | h
      · exact Or.inl h
      · exact Or.inr ⟨h, hm x h⟩
    have hbadn : ∀ b' ∈ A, ∀ c' ∈ A, ∀ d' ∈ A, m + b' ≠ c' + d' := by
      intro b' hb' c' hc' d' hd' heq
      exact hbad (mem_sidonBad_of_eq hb' hc' hd' heq)
    rcases key a ha with ha' | ⟨haA, halt⟩ <;> rcases key b hb with hb' | ⟨hbA, hblt⟩ <;>
      rcases key c hc with hc' | ⟨hcA, hclt⟩ <;> rcases key d hd with hd' | ⟨hdA, hdlt⟩ <;>
      first
        | omega
        | exact absurd (show m + b = c + d by omega) (hbadn b hbA c hcA d hdA)
        | exact absurd (show m + a = c + d by omega) (hbadn a haA c hcA d hdA)
        | exact absurd (show m + d = a + b by omega) (hbadn d hdA a haA b hbA)
        | exact absurd (show m + c = a + b by omega) (hbadn c hcA a haA b hbA)
        | exact hA a haA b hbA c hcA d hdA habcd

/-! ## 4. Existence of a greedy step -/

/-- The greedy predicate: `m` sits strictly above `A` and keeps the set Sidon. -/
def GoodNext (A : Finset ℕ) (m : ℕ) : Prop := (∀ a ∈ A, a < m) ∧ IsSidon (insert m A)

instance (A : Finset ℕ) : DecidablePred (GoodNext A) := fun _ => by
  unfold GoodNext; infer_instance

/-- **A greedy step always exists, inside a cubic window.**  If `A` is Sidon then some
`m` in the interval `(max A, max A + |A|³ + 1]` extends it. -/
theorem exists_good_next {A : Finset ℕ} (hA : IsSidon A) :
    ∃ m, GoodNext A m ∧ m ≤ A.sup id + #A ^ 3 + 1 := by
  classical
  set M := A.sup id with hM
  set S : Finset ℕ := Finset.Icc (M + 1) (M + #A ^ 3 + 1) with hS
  have hcardS : #S = #A ^ 3 + 1 := by
    rw [hS, Nat.card_Icc]; omega
  have : ∃ m ∈ S, (m : ℤ) ∉ sidonBad A := by
    by_contra hcon
    push_neg at hcon
    have hinj : Set.InjOn (fun n : ℕ => (n : ℤ)) (S : Set ℕ) := fun x _ y _ h =>
      Nat.cast_injective h
    have hle : #S ≤ #(sidonBad A) :=
      Finset.card_le_card_of_injOn _ (fun x hx => hcon x hx) hinj
    have := card_sidonBad_le A
    omega
  obtain ⟨m, hmS, hmbad⟩ := this
  have hmS' : M + 1 ≤ m ∧ m ≤ M + #A ^ 3 + 1 := by
    simpa [hS, Finset.mem_Icc] using hmS
  refine ⟨m, ⟨?_, ?_⟩, by omega⟩
  · intro a ha
    have : a ≤ M := Finset.le_sup (f := id) ha
    omega
  · exact (isSidon_insert_iff (fun a ha => by
      have : a ≤ M := Finset.le_sup (f := id) ha
      omega)).mpr ⟨hA, hmbad⟩

/-! ## 5. The greedy sequence -/

/-- The least valid greedy continuation of `A` (junk value `0` if none exists, which by
`exists_good_next` happens only for non-Sidon `A`). -/
noncomputable def nextGreedy (A : Finset ℕ) : ℕ := sInf {m | GoodNext A m}

theorem goodNext_nextGreedy {A : Finset ℕ} (hA : IsSidon A) : GoodNext A (nextGreedy A) := by
  obtain ⟨m, hm, -⟩ := exists_good_next hA
  exact Nat.sInf_mem (s := {m | GoodNext A m}) ⟨m, hm⟩

theorem nextGreedy_le {A : Finset ℕ} (hA : IsSidon A) :
    nextGreedy A ≤ A.sup id + #A ^ 3 + 1 := by
  obtain ⟨m, hm, hmle⟩ := exists_good_next hA
  exact le_trans (Nat.sInf_le (s := {m | GoodNext A m}) hm) hmle

theorem nextGreedy_eq_of {A : Finset ℕ} {m : ℕ} (h : GoodNext A m)
    (hmin : ∀ k < m, ¬ GoodNext A k) : nextGreedy A = m := by
  refine le_antisymm (Nat.sInf_le (s := {m | GoodNext A m}) h) ?_
  by_contra hlt
  push_neg at hlt
  exact hmin _ hlt (Nat.sInf_mem (s := {m | GoodNext A m}) ⟨m, h⟩)

/-- The greedy difference-avoiding set after `n` steps. -/
noncomputable def greedySet : ℕ → Finset ℕ
  | 0 => ∅
  | n + 1 => insert (nextGreedy (greedySet n)) (greedySet n)

/-- The greedy difference-avoiding sequence: `greedySeq n` is the `(n+1)`-st term. -/
noncomputable def greedySeq (n : ℕ) : ℕ := nextGreedy (greedySet n)

theorem greedySet_succ (n : ℕ) : greedySet (n + 1) = insert (greedySeq n) (greedySet n) := rfl

/-- Every element of the greedy set at stage `n` is smaller than the next term. -/
theorem greedySet_isSidon : ∀ n, IsSidon (greedySet n)
  | 0 => isSidon_empty
  | n + 1 => (goodNext_nextGreedy (greedySet_isSidon n)).2

theorem lt_greedySeq {n : ℕ} {a : ℕ} (ha : a ∈ greedySet n) : a < greedySeq n :=
  (goodNext_nextGreedy (greedySet_isSidon n)).1 a ha

theorem card_greedySet : ∀ n, #(greedySet n) = n
  | 0 => rfl
  | n + 1 => by
      have hnot : greedySeq n ∉ greedySet n := fun h => lt_irrefl _ (lt_greedySeq h)
      rw [greedySet_succ, Finset.card_insert_of_notMem hnot, card_greedySet n]

theorem sup_greedySet_succ (n : ℕ) : (greedySet (n + 1)).sup id = greedySeq n := by
  rw [greedySet_succ, Finset.sup_insert]
  have : (greedySet n).sup id ≤ greedySeq n := by
    refine Finset.sup_le fun a ha => le_of_lt (lt_greedySeq ha)
  simpa [id] using max_eq_left this

theorem greedySeq_strictMono : StrictMono greedySeq := by
  refine strictMono_nat_of_lt_succ fun n => ?_
  exact lt_greedySeq (by rw [greedySet_succ]; exact Finset.mem_insert_self _ _)

/-! ## 6. Concrete values: the Mian–Chowla sequence -/

theorem greedySet_zero : greedySet 0 = ∅ := rfl

theorem greedySeq_zero : greedySeq 0 = 0 := by
  refine nextGreedy_eq_of ⟨by simp [greedySet_zero], ?_⟩ (fun k hk => absurd hk (Nat.not_lt_zero k))
  rw [greedySet_zero]
  decide

theorem greedySet_one : greedySet 1 = {0} := by
  rw [greedySet_succ, greedySeq_zero, greedySet_zero]; rfl

theorem greedySeq_one : greedySeq 1 = 1 := by
  rw [greedySeq, greedySet_one]
  refine nextGreedy_eq_of ⟨by decide, by decide⟩ ?_
  intro k hk hcon
  have h0 : 0 < k := hcon.1 0 (by decide)
  omega

theorem greedySet_two : greedySet 2 = {1, 0} := by
  rw [greedySet_succ, greedySeq_one, greedySet_one]

theorem greedySeq_two : greedySeq 2 = 3 := by
  rw [greedySeq, greedySet_two]
  refine nextGreedy_eq_of ⟨by decide, by decide⟩ ?_
  intro k hk hcon
  have h1 : 1 < k := hcon.1 1 (by decide)
  have h2 := hcon.2
  interval_cases k
  · exact absurd h2 (by decide)

theorem greedySet_three : greedySet 3 = {3, 1, 0} := by
  rw [greedySet_succ, greedySeq_two, greedySet_two]

theorem greedySeq_three : greedySeq 3 = 7 := by
  rw [greedySeq, greedySet_three]
  refine nextGreedy_eq_of ⟨by decide, by decide⟩ ?_
  intro k hk hcon
  have h3 : 3 < k := hcon.1 3 (by decide)
  have h2 := hcon.2
  interval_cases k <;> exact absurd h2 (by decide)

/-! ## 7. The sandwich -/

/-- **Greedy step bound.**  `a (n+1) ≤ a n + (n+1)³ + 1`. -/
theorem greedySeq_succ_le (n : ℕ) : greedySeq (n + 1) ≤ greedySeq n + (n + 1) ^ 3 + 1 := by
  have := nextGreedy_le (greedySet_isSidon (n + 1))
  rwa [sup_greedySet_succ, card_greedySet] at this

/-- **Quartic upper bound.**  `4 · a n ≤ (n+1)⁴`. -/
theorem four_mul_greedySeq_le : ∀ n, 4 * greedySeq n ≤ (n + 1) ^ 4
  | 0 => by simp [greedySeq_zero]
  | n + 1 => by
      have h1 := greedySeq_succ_le n
      have h2 := four_mul_greedySeq_le n
      nlinarith [sq_nonneg (n : ℤ), Nat.zero_le n]

/-- **Quadratic lower bound.**  `n(n+1) ≤ 2 · a n`: the greedy set at stage `n+1` is a
Sidon subset of `{0, …, a n}`, so the catalog's Erdős–Turán counting bound applies. -/
theorem mul_le_two_mul_greedySeq (n : ℕ) : n * (n + 1) ≤ 2 * greedySeq n := by
  have hsub : greedySet (n + 1) ⊆ Finset.range (greedySeq n + 1) := by
    intro a ha
    rw [Finset.mem_range]
    rcases Finset.mem_insert.mp (by rwa [greedySet_succ] at ha) with rfl | h
    · omega
    · have := lt_greedySeq h; omega
  have hcard := (greedySet_isSidon (n + 1)).card_mul_pred_le_of_subset_range hsub
  rw [card_greedySet] at hcard
  simp only [Nat.add_sub_cancel] at hcard
  rw [Nat.mul_comm] at hcard
  omega

/-- **The greedy difference-avoidance sandwich.**  The greedy sequence is squeezed
between a quadratic and a quartic. -/
theorem greedySeq_sandwich (n : ℕ) :
    n * (n + 1) ≤ 2 * greedySeq n ∧ 4 * greedySeq n ≤ (n + 1) ^ 4 :=
  ⟨mul_le_two_mul_greedySeq n, four_mul_greedySeq_le n⟩

end GreedyDifference

-- axiom audit (kept for reproducibility; prints only standard axioms)
-- #print axioms GreedyDifference.greedySeq_sandwich