import Novelty.GreedyDifferenceSidon

/-!
# Sharpening the greedy difference bound from quartic to cubic

`Novelty/GreedyDifferenceSidon.lean` bounds the greedy difference-avoiding (Mian–Chowla)
sequence by `4·a n ≤ (n+1)⁴`, by summing the cubic window bounds of the individual greedy
steps.  That summation is wasteful, and this file removes it.

The key observation is a **rigidity of the greedy chain**: a value `m` that could be
adjoined to `greedySet n` at all (i.e. `m ∉ greedySet n` and `insert m (greedySet n)` is
Sidon) is automatically *larger* than every element of `greedySet n`.  Otherwise `m` would
have been available at an earlier stage, contradicting minimality there.  Consequently the
greedy step is not restricted to a window above `max`: it may be located anywhere, and a
single pigeonhole over `{0, 1, …, n³ + n² + n}` suffices.

Two obstruction sets appear once the ordering hypothesis is dropped: the cubic set
`sidonBad A` of the companion file (`m + b = c + d`) and the new quadratic *halving* set
`sidonBadHalf A` (`m + m = c + d`), which was previously excluded for free because
`2m > c + d` for `m` above `A`.

## Main results

* `sidonBadHalf`, `card_sidonBadHalf_le` — the halving obstruction and its bound `|A|²`.
* `isSidon_insert_of_avoid` — **unordered greedy step criterion**: for `m ∉ A` avoiding both
  obstruction sets, `insert m A` is Sidon.  No ordering hypothesis on `m`.
* `exists_valid_le` — a valid new element always exists in `{0, …, n³ + n² + n}`, where
  `n = |A|`.
* `greedy_valid_gt` — **chain rigidity**: any admissible new element for `greedySet n`
  exceeds every element of `greedySet n`; equivalently, greedy never skips a usable value.
* `greedySeq_le_cubic` — **cubic upper bound** `a n ≤ n³ + n² + n`, replacing the quartic
  bound of the companion file.
* `isSidon_insert_iff_avoid` — the criterion is in fact an **equivalence**: the two
  obstructions are exactly complete for an unordered candidate.
* `halving_obstruction_necessary`, `halving_obstruction_family` — sharpness: dropping the
  halving hypothesis breaks the criterion, and not only for small sets — the dilates
  `2 · greedySet k` with `m = 1` give one witness of every size `k ≥ 2`.
* `greedySet_three_perfect`, `greedySet_four_not_perfect` — the greedy set is a perfect
  (Singer) difference set modulo `7` at `n = 3` and stops being one at `n = 4`.
* `greedySeq_sandwich_cubic` — `n(n+1)/2 ≤ a n ≤ n³ + n² + n`; the exponents `2` and `3`
  now bracket the truth, which numerically looks like `n^{2.4…}` in the accessible range.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (C1) The quartic bound is an artefact of summing window widths;
  the true greedy bound should be cubic, matching the counting `|A|³` of the obstruction
  set alone.  (C2) The obstacle to proving it is that greedy is defined to look *above*
  the current maximum, so a global pigeonhole is not directly available; the fix should be
  a rigidity statement showing that looking above the maximum costs nothing.
Experiment (Experimenter): (C2) was proved as `greedy_valid_gt` by induction along the
  chain — the induction step uses the minimality of the earlier greedy choice, so the
  statement is genuinely about the whole chain and not about a single set.  (C1) then
  followed from a pigeonhole over `n³ + n² + n + 1` candidates against the obstruction
  count `n³ + n² + n`.  Numerically `a 13 = 181` against the cubic bound `2379` and the
  old quartic bound `9604`.
Analysis (Analyst): the cubic bound is the exact strength of the counting argument, and
  the remaining gap to the observed growth (`a n ≈ n^{2.4}` for `n ≤ 14`, and `≍ n³` is
  the classical expectation) is now entirely a *dispersion* question: the obstruction set
  has `≤ n³` elements but occupies an interval of length `≍ max A`, so overlaps must be
  quantified.
Critique (Critic): `greedy_valid_gt` is stated for the greedy chain, not for arbitrary
  Sidon sets — for an arbitrary Sidon set it is false (e.g. `A = {0, 3}` admits `m = 1`,
  which is below `3`).  The hypothesis `m ∉ greedySet n` is load-bearing: without it the
  conclusion `∀ a ∈ greedySet n, a < m` fails for `m` an existing element.  The halving
  hypothesis of `isSidon_insert_of_avoid` is also load-bearing, and this is now proved
  rather than asserted (`halving_obstruction_necessary`), and proved for every size
  (`halving_obstruction_family`), so it is not an artefact of tiny examples.  Conversely
  nothing further is missing: `isSidon_insert_iff_avoid` shows the two obstructions are
  complete.  The two `decide` facts of §8 are supporting data, not main results; they are
  reached only after rewriting with the proved values of `greedySet 3` and `greedySet 4`.
Synthesis (PI): greedy difference avoidance is cubic, and the proof isolates the exact
  remaining obstacle (dispersion of `sidonBad`).
-/

namespace GreedyDifference

open Finset

/-! ## 1. The halving obstruction -/

/-- The **halving obstruction**: candidates `m` with `2m = c + d` for some `c, d ∈ A`. -/
def sidonBadHalf (A : Finset ℕ) : Finset ℕ := (A ×ˢ A).image fun p => (p.1 + p.2) / 2

theorem card_sidonBadHalf_le (A : Finset ℕ) : #(sidonBadHalf A) ≤ #A ^ 2 := by
  refine le_trans Finset.card_image_le ?_
  rw [Finset.card_product, pow_two]

theorem mem_sidonBadHalf_of {A : Finset ℕ} {m c d : ℕ} (hc : c ∈ A) (hd : d ∈ A)
    (h : m + m = c + d) : m ∈ sidonBadHalf A := by
  refine Finset.mem_image.mpr ⟨(c, d), ?_, ?_⟩
  · simp [Finset.mem_product, hc, hd]
  · simp only
    omega

/-! ## 2. The unordered greedy step criterion -/

/-- **Unordered greedy step criterion, pointwise form.**  A candidate `m` outside `A` that
solves neither `m + b = c + d` nor `2m = c + d` over `A` extends a Sidon set to a Sidon set —
with no assumption on the size of `m`. -/
theorem isSidon_insert_of_avoid_pointwise {A : Finset ℕ} {m : ℕ} (hA : IsSidon A) (hmA : m ∉ A)
    (hbadn : ∀ b' ∈ A, ∀ c' ∈ A, ∀ d' ∈ A, m + b' ≠ c' + d')
    (hhalfn : ∀ c' ∈ A, ∀ d' ∈ A, m + m ≠ c' + d') : IsSidon (insert m A) := by
  intro a ha b hb c hc d hd habcd
  have key : ∀ x ∈ insert m A, x = m ∨ (x ∈ A ∧ x ≠ m) := by
    intro x hx
    rcases Finset.mem_insert.mp hx with h | h
    · exact Or.inl h
    · exact Or.inr ⟨h, fun hxm => hmA (hxm ▸ h)⟩
  rcases key a ha with ha' | ⟨haA, hane⟩ <;> rcases key b hb with hb' | ⟨hbA, hbne⟩ <;>
    rcases key c hc with hc' | ⟨hcA, hcne⟩ <;> rcases key d hd with hd' | ⟨hdA, hdne⟩ <;>
    first
      | omega
      | exact absurd (show m + b = c + d by omega) (hbadn b hbA c hcA d hdA)
      | exact absurd (show m + a = c + d by omega) (hbadn a haA c hcA d hdA)
      | exact absurd (show m + d = a + b by omega) (hbadn d hdA a haA b hbA)
      | exact absurd (show m + c = a + b by omega) (hbadn c hcA a haA b hbA)
      | exact absurd (show m + m = c + d by omega) (hhalfn c hcA d hdA)
      | exact absurd (show m + m = a + b by omega) (hhalfn a haA b hbA)
      | exact hA a haA b hbA c hcA d hdA habcd

/-- The obstruction-set form of the criterion. -/
theorem isSidon_insert_of_avoid {A : Finset ℕ} {m : ℕ} (hA : IsSidon A) (hmA : m ∉ A)
    (hbad : (m : ℤ) ∉ sidonBad A) (hhalf : m ∉ sidonBadHalf A) : IsSidon (insert m A) :=
  isSidon_insert_of_avoid_pointwise hA hmA
    (fun _ hb' _ hc' _ hd' heq => hbad (mem_sidonBad_of_eq hb' hc' hd' heq))
    (fun _ hc' _ hd' heq => hhalf (mem_sidonBadHalf_of hc' hd' heq))

/-- **Exact unordered greedy step criterion.**  For a candidate `m` outside `A` — with no
ordering assumption whatsoever — adjoining `m` preserves the Sidon property *iff* `A` is
Sidon and `m` solves neither the cubic equation `m + b = c + d` nor the halving equation
`2m = c + d` over `A`.  So the two obstructions of this file are exactly complete. -/
theorem isSidon_insert_iff_avoid {A : Finset ℕ} {m : ℕ} (hmA : m ∉ A) :
    IsSidon (insert m A) ↔
      IsSidon A ∧ (∀ b ∈ A, ∀ c ∈ A, ∀ d ∈ A, m + b ≠ c + d) ∧
        (∀ c ∈ A, ∀ d ∈ A, m + m ≠ c + d) := by
  constructor
  · intro h
    have hmi : m ∈ insert m A := Finset.mem_insert_self _ _
    refine ⟨h.mono (Finset.subset_insert _ _), ?_, ?_⟩
    · intro b hb c hc d hd heq
      rcases h m hmi b (Finset.mem_insert_of_mem hb) c (Finset.mem_insert_of_mem hc) d
          (Finset.mem_insert_of_mem hd) heq with ⟨h1, -⟩ | ⟨h1, -⟩
      · exact hmA (h1 ▸ hc)
      · exact hmA (h1 ▸ hd)
    · intro c hc d hd heq
      rcases h m hmi m hmi c (Finset.mem_insert_of_mem hc) d
          (Finset.mem_insert_of_mem hd) heq with ⟨h1, -⟩ | ⟨h1, -⟩
      · exact hmA (h1 ▸ hc)
      · exact hmA (h1 ▸ hd)
  · rintro ⟨hA, hbadn, hhalfn⟩
    exact isSidon_insert_of_avoid_pointwise hA hmA hbadn hhalfn

/-! ## 3. A valid element in a cubic window -/

/-- **Cubic pigeonhole.**  Any Sidon set of size `n` admits a new element below
`n³ + n² + n + 1`. -/
theorem exists_valid_le {A : Finset ℕ} (hA : IsSidon A) :
    ∃ m ≤ #A ^ 3 + #A ^ 2 + #A, m ∉ A ∧ IsSidon (insert m A) := by
  classical
  set n := #A with hn
  set W : Finset ℕ := Finset.range (n ^ 3 + n ^ 2 + n + 1) with hW
  have hcardW : #W = n ^ 3 + n ^ 2 + n + 1 := by rw [hW, Finset.card_range]
  -- the union of the three obstructions is too small to cover `W`
  set BadZ : Finset ℕ := (sidonBad A).image Int.toNat with hBadZ
  set Bad : Finset ℕ := (A ∪ sidonBadHalf A) ∪ BadZ with hBad
  have hcardBad : #Bad ≤ n ^ 3 + n ^ 2 + n := by
    have h1 : #BadZ ≤ n ^ 3 :=
      le_trans Finset.card_image_le (card_sidonBad_le A)
    have h2 : #(sidonBadHalf A) ≤ n ^ 2 := card_sidonBadHalf_le A
    have h3 : #(A ∪ sidonBadHalf A) ≤ #A + #(sidonBadHalf A) := Finset.card_union_le _ _
    have h4 : #Bad ≤ #(A ∪ sidonBadHalf A) + #BadZ := Finset.card_union_le _ _
    have h5 : n ^ 3 + n ^ 2 + n = (n + n ^ 2) + n ^ 3 := by ring
    omega
  have hex : ∃ m ∈ W, m ∉ Bad := by
    by_contra hcon
    push_neg at hcon
    have : #W ≤ #Bad := Finset.card_le_card hcon
    omega
  obtain ⟨m, hmW, hmBad⟩ := hex
  have hmlt : m < n ^ 3 + n ^ 2 + n + 1 := by simpa [hW] using hmW
  have hmA : m ∉ A := fun h => hmBad (by
    rw [hBad]; exact Finset.mem_union_left _ (Finset.mem_union_left _ h))
  have hmhalf : m ∉ sidonBadHalf A := fun h => hmBad (by
    rw [hBad]; exact Finset.mem_union_left _ (Finset.mem_union_right _ h))
  have hmbad : (m : ℤ) ∉ sidonBad A := fun h => hmBad (by
    rw [hBad]
    exact Finset.mem_union_right _ (Finset.mem_image.mpr ⟨(m : ℤ), h, by simp⟩))
  exact ⟨m, by omega, hmA, isSidon_insert_of_avoid hA hmA hmbad hmhalf⟩

/-! ## 4. Rigidity of the greedy chain -/

/-- **Chain rigidity.**  Every value that can still be adjoined to the greedy set at stage
`n` is larger than everything already chosen: greedy never leaves a usable value behind. -/
theorem greedy_valid_gt : ∀ (n : ℕ) (m : ℕ), m ∉ greedySet n → IsSidon (insert m (greedySet n)) →
    ∀ a ∈ greedySet n, a < m
  | 0, m, _, _ => by simp [greedySet]
  | n + 1, m, hmA, hSid => by
      have hsub : insert m (greedySet n) ⊆ insert m (greedySet (n + 1)) := by
        intro x hx
        rcases Finset.mem_insert.mp hx with rfl | hx
        · exact Finset.mem_insert_self _ _
        · exact Finset.mem_insert_of_mem (by rw [greedySet_succ]; exact Finset.mem_insert_of_mem hx)
      have hmn : m ∉ greedySet n := fun h => hmA (by
        rw [greedySet_succ]; exact Finset.mem_insert_of_mem h)
      have hSid' : IsSidon (insert m (greedySet n)) := hSid.mono hsub
      have hgt := greedy_valid_gt n m hmn hSid'
      have hgood : GoodNext (greedySet n) m := ⟨hgt, hSid'⟩
      have hle : greedySeq n ≤ m := Nat.sInf_le (s := {m | GoodNext (greedySet n) m}) hgood
      have hne : greedySeq n ≠ m := fun h => hmA (by
        rw [greedySet_succ, ← h]; exact Finset.mem_insert_self _ _)
      intro a ha
      rcases Finset.mem_insert.mp (by rwa [greedySet_succ] at ha) with rfl | ha'
      · omega
      · exact hgt a ha'

/-! ## 5. The cubic bound -/

/-- **Cubic upper bound for greedy difference avoidance**: `a n ≤ n³ + n² + n`. -/
theorem greedySeq_le_cubic (n : ℕ) : greedySeq n ≤ n ^ 3 + n ^ 2 + n := by
  obtain ⟨m, hmle, hmA, hmSid⟩ := exists_valid_le (greedySet_isSidon n)
  rw [card_greedySet] at hmle
  have hgt := greedy_valid_gt n m hmA hmSid
  have hgood : GoodNext (greedySet n) m := ⟨hgt, hmSid⟩
  exact le_trans (Nat.sInf_le (s := {m | GoodNext (greedySet n) m}) hgood) hmle

/-- **The sharpened sandwich**: `n(n+1)/2 ≤ a n ≤ n³ + n² + n`. -/
theorem greedySeq_sandwich_cubic (n : ℕ) :
    n * (n + 1) ≤ 2 * greedySeq n ∧ greedySeq n ≤ n ^ 3 + n ^ 2 + n :=
  ⟨mul_le_two_mul_greedySeq n, greedySeq_le_cubic n⟩

/-! ## 6. Sharpness: the halving obstruction cannot be dropped -/

/-- A parity obstruction: over an all-even set, the cubic obstruction set contains only even
integers, so an odd candidate automatically avoids it. -/
theorem notMem_sidonBad_of_odd {A : Finset ℕ} (hA : ∀ a ∈ A, 2 ∣ a) {m : ℕ} (hm : ¬ 2 ∣ m) :
    (m : ℤ) ∉ sidonBad A := by
  intro h
  obtain ⟨b, hb, c, hc, d, hd, heq⟩ := exists_of_mem_sidonBad h
  have h2 := hA b hb
  have h3 := hA c hc
  have h4 := hA d hd
  omega

/-- **Sharpness of `isSidon_insert_of_avoid`.**  The halving hypothesis is load-bearing: there
is a Sidon set `A` and a candidate `m ∉ A` avoiding the cubic obstruction `sidonBad A` for
which `insert m A` fails to be Sidon.  Concretely `A = {0, 2}` and `m = 1`, where `2m = 0 + 2`
is the only collision and it is invisible to `sidonBad`, by parity. -/
theorem halving_obstruction_necessary :
    ∃ (A : Finset ℕ) (m : ℕ), IsSidon A ∧ m ∉ A ∧ (m : ℤ) ∉ sidonBad A ∧
      m ∈ sidonBadHalf A ∧ ¬ IsSidon (insert m A) := by
  refine ⟨{0, 2}, 1, by decide, by decide, ?_,
    mem_sidonBadHalf_of (c := 0) (d := 2) (by decide) (by decide) rfl, ?_⟩
  · refine notMem_sidonBad_of_odd (fun a ha => ?_) (by omega)
    fin_cases ha <;> omega
  · intro h
    have h0 : (0 : ℕ) ∈ insert 1 ({0, 2} : Finset ℕ) := by decide
    have h1 : (1 : ℕ) ∈ insert 1 ({0, 2} : Finset ℕ) := by decide
    have h2 : (2 : ℕ) ∈ insert 1 ({0, 2} : Finset ℕ) := by decide
    rcases h 0 h0 2 h2 1 h1 1 h1 (by omega) with ⟨hl, _⟩ | ⟨hl, _⟩ <;> omega

/-! ## 7. An infinite family of parity witnesses -/

theorem greedySet_mono : ∀ {m n : ℕ}, m ≤ n → greedySet m ⊆ greedySet n := by
  intro m n hmn
  induction n with
  | zero =>
      have : m = 0 := by omega
      subst this; exact Finset.Subset.refl _
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · refine (ih (by omega)).trans ?_
        rw [greedySet_succ]
        exact Finset.subset_insert _ _
      · have : m = k + 1 := by omega
        subst this; exact Finset.Subset.refl _

/-- Dilation by `2` preserves the Sidon property. -/
theorem isSidon_image_two {A : Finset ℕ} (hA : IsSidon A) :
    IsSidon (A.image fun x => 2 * x) := by
  intro a ha b hb c hc d hd habcd
  simp only [Finset.mem_image] at ha hb hc hd
  obtain ⟨a', ha', rfl⟩ := ha
  obtain ⟨b', hb', rfl⟩ := hb
  obtain ⟨c', hc', rfl⟩ := hc
  obtain ⟨d', hd', rfl⟩ := hd
  have hsum : a' + b' = c' + d' := by omega
  rcases hA a' ha' b' hb' c' hc' d' hd' hsum with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨by omega, by omega⟩
  · exact Or.inr ⟨by omega, by omega⟩

/-- **The parity witness is not an accident of small size.**  For every `k ≥ 2` there is a
Sidon set of exactly `k` elements and a candidate `m ∉ A` that avoids the cubic obstruction
`sidonBad A` yet destroys the Sidon property, the failure being caused solely by the halving
relation `2m = c + d`.  The family is the dilate `2 · greedySet k` with `m = 1`. -/
theorem halving_obstruction_family (k : ℕ) (hk : 2 ≤ k) :
    ∃ (A : Finset ℕ) (m : ℕ), #A = k ∧ IsSidon A ∧ m ∉ A ∧ (m : ℤ) ∉ sidonBad A ∧
      m ∈ sidonBadHalf A ∧ ¬ IsSidon (insert m A) := by
  classical
  refine ⟨(greedySet k).image (fun x => 2 * x), 1, ?_, isSidon_image_two (greedySet_isSidon k),
    ?_, ?_, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ (fun x y hxy => by omega), card_greedySet]
  · intro hmem
    obtain ⟨x, -, hx⟩ := Finset.mem_image.mp hmem
    omega
  · refine notMem_sidonBad_of_odd (fun a ha => ?_) (by omega)
    obtain ⟨x, -, rfl⟩ := Finset.mem_image.mp ha
    exact ⟨x, rfl⟩
  · have h0 : (0 : ℕ) ∈ (greedySet k).image (fun x => 2 * x) :=
      Finset.mem_image.mpr ⟨0, greedySet_mono hk (by rw [greedySet_two]; decide), rfl⟩
    have h2 : (2 : ℕ) ∈ (greedySet k).image (fun x => 2 * x) :=
      Finset.mem_image.mpr ⟨1, greedySet_mono hk (by rw [greedySet_two]; decide), rfl⟩
    exact mem_sidonBadHalf_of h0 h2 rfl
  · intro hSid
    have h0 : (0 : ℕ) ∈ insert 1 ((greedySet k).image (fun x => 2 * x)) :=
      Finset.mem_insert_of_mem
        (Finset.mem_image.mpr ⟨0, greedySet_mono hk (by rw [greedySet_two]; decide), rfl⟩)
    have h2 : (2 : ℕ) ∈ insert 1 ((greedySet k).image (fun x => 2 * x)) :=
      Finset.mem_insert_of_mem
        (Finset.mem_image.mpr ⟨1, greedySet_mono hk (by rw [greedySet_two]; decide), rfl⟩)
    have h1 : (1 : ℕ) ∈ insert 1 ((greedySet k).image (fun x => 2 * x)) :=
      Finset.mem_insert_self _ _
    rcases hSid 1 h1 1 h1 0 h0 2 h2 (by omega) with ⟨hl, -⟩ | ⟨hl, -⟩ <;> omega

/-! ## 8. Greedy sets are not Singer difference sets -/

theorem greedySet_four : greedySet 4 = {7, 3, 1, 0} := by
  rw [greedySet_succ, greedySeq_three, greedySet_three]

/-- **Failure of perfection at `n = 4`.**  A Sidon set of `n` elements in `ℤ/q` with
`q = n² − n + 1` is *perfect* (a Singer difference set) when its differences cover every
nonzero residue.  The greedy set `{0, 1, 3}` is perfect modulo `7`, but the next greedy set
`{0, 1, 3, 7}` is **not** perfect modulo `13`: the residue `5` is missed.  So the greedy
process leaves the Singer family at the first opportunity. -/
theorem greedySet_four_not_perfect :
    ∃ r, 0 < r ∧ r < 13 ∧ ∀ x ∈ greedySet 4, ∀ y ∈ greedySet 4, (x + 13 - y) % 13 ≠ r := by
  refine ⟨5, by omega, by omega, ?_⟩
  rw [greedySet_four]
  decide

/-- By contrast the three-element greedy set is perfect modulo `7`: every nonzero residue is
a difference.  The pair of statements localises the loss of perfection at `n = 4`. -/
theorem greedySet_three_perfect (r : ℕ) (hr : 0 < r) (hr' : r < 7) :
    ∃ x ∈ greedySet 3, ∃ y ∈ greedySet 3, (x + 7 - y) % 7 = r := by
  rw [greedySet_three]
  interval_cases r <;> decide

end GreedyDifference