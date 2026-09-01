import Physics.AttentionKneeRigidity

/-!
# The master knee is not unique: 118 also reproduces the five-domain table

Fourth cycle of the NET-75 analysis.  In `AttentionKneeSpectrum` we showed
that a master profile with knee `120` reproduces the measured table
`code 12, EN/math 20, DE 24, FR 40` through the exponents `(10, 6, 6, 5, 3)`,
and that `120` is minimal *among masters that divide exactly*.

Dropping exact divisibility — which the ceiling law of `kgeom_root` does not
require — the picture changes: the master knee `118` reproduces the very same
table with the very same exponents, and `118` is the true minimum.  So the
five-domain data are compatible with a two-parameter family of masters and
cannot pin the master knee down; any claim that the tax exponents are
canonical must come with an independent measurement.

## Main results

* `five_domain_table_118` — the master knee `118` reproduces the table.
* `no_master_below_118` — no master knee below `118` reproduces it (finite
  verified search, with the unbounded exponent range reduced to `m ≤ B`).
* `master_knee_ambiguous` — consequently `118` and `120` are distinct masters
  with identical five-domain fingerprints.
* `master_solution_set` — the exact gauge freedom: the admissible masters for
  the exponent vector `(10, 6, 5, 3)` are exactly `{118, 119, 120}`.
* `knee_root_two_sided`, `french_knee_39_or_40` — the multiplicative law comes
  with an error strictly below the multiplier, so an English knee of `20`
  forces a French knee of `39` or `40` and nothing else.
-/

namespace Physics.AttentionKnee

/-- A master knee `B` *realizes* the table entry `v` if some tax exponent
sends `B` to `v` under the ceiling law. -/
def realizes (B v : ℕ) : Bool :=
  (List.range (B + 1)).any (fun m => 0 < m && B ⌈/⌉ m == v)

/-- A master knee covers the whole NET-75 five-domain table. -/
def coversTable (B : ℕ) : Bool :=
  realizes B 12 && realizes B 20 && realizes B 24 && realizes B 40

/-- A tax exponent that produces a table entry `≥ 2` cannot exceed the master
knee, which is what makes the search finite. -/
theorem exponent_le_of_ceilDiv_eq {B m v : ℕ} (hm : 0 < m) (h : B ⌈/⌉ m = v)
    (hv : 2 ≤ v) : m ≤ B := by
  by_contra hlt
  push_neg at hlt
  have h1 : B ⌈/⌉ m ≤ 1 := (ceilDiv_le_iff_le_mul hm).2 (by omega)
  omega

theorem realizes_iff (B v : ℕ) (hv : 2 ≤ v) :
    realizes B v = true ↔ ∃ m, 0 < m ∧ B ⌈/⌉ m = v := by
  constructor
  · intro h
    obtain ⟨m, _, hm⟩ := List.any_eq_true.1 h
    rw [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at hm
    exact ⟨m, hm.1, hm.2⟩
  · rintro ⟨m, hm, hv'⟩
    refine List.any_eq_true.2 ⟨m, ?_, ?_⟩
    · exact List.mem_range.2 (by have := exponent_le_of_ceilDiv_eq hm hv' hv; omega)
    · rw [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq]
      exact ⟨hm, hv'⟩

/-- **The master knee `118` reproduces the whole table**, with exactly the
same exponent vector `(10, 6, 6, 5, 3)` as the master knee `120`. -/
theorem five_domain_table_118 {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    (hmaster : kgeom r t = 118) :
    kgeom (r ^ 10) t = 12 ∧ kgeom (r ^ 6) t = 20 ∧ kgeom (r ^ 5) t = 24 ∧
      kgeom (r ^ 3) t = 40 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    · rw [kgeom_root hr0 hr1 ht (by norm_num), hmaster]
      decide

/-- Finite verified search: no `B < 118` covers the table. -/
theorem coversTable_false_below_118 :
    (List.range 118).all (fun B => !coversTable B) = true := by decide

/-- **Minimality of `118`.**  No master knee below `118` can reproduce the
five-domain table, even allowing arbitrary tax exponents and the ceiling law. -/
theorem no_master_below_118 {B : ℕ} (hB : B < 118) :
    ¬ (∃ m₁ m₂ m₃ m₄ : ℕ, 0 < m₁ ∧ 0 < m₂ ∧ 0 < m₃ ∧ 0 < m₄ ∧
        B ⌈/⌉ m₁ = 12 ∧ B ⌈/⌉ m₂ = 20 ∧ B ⌈/⌉ m₃ = 24 ∧ B ⌈/⌉ m₄ = 40) := by
  rintro ⟨m₁, m₂, m₃, m₄, h1, h2, h3, h4, e1, e2, e3, e4⟩
  have hcov : coversTable B = true := by
    simp only [coversTable, Bool.and_eq_true]
    exact ⟨⟨⟨(realizes_iff B 12 (by norm_num)).2 ⟨m₁, h1, e1⟩,
        (realizes_iff B 20 (by norm_num)).2 ⟨m₂, h2, e2⟩⟩,
      (realizes_iff B 24 (by norm_num)).2 ⟨m₃, h3, e3⟩⟩,
      (realizes_iff B 40 (by norm_num)).2 ⟨m₄, h4, e4⟩⟩
  have := List.all_eq_true.1 coversTable_false_below_118 B (List.mem_range.2 hB)
  rw [hcov] at this
  simp at this

/-- **The five-domain fingerprint does not determine the master.**  A profile
with master knee `118` and a profile with master knee `120` produce literally
the same four table entries under the same exponents, so the measured table
alone cannot identify the master profile. -/
theorem master_knee_ambiguous {r₁ r₂ t₁ t₂ : ℝ} (hr₁0 : 0 ≤ r₁) (hr₁1 : r₁ < 1)
    (ht₁ : 0 < t₁) (hr₂0 : 0 ≤ r₂) (hr₂1 : r₂ < 1) (ht₂ : 0 < t₂)
    (h118 : kgeom r₁ t₁ = 118) (h120 : kgeom r₂ t₂ = 120) :
    (kgeom (r₁ ^ 10) t₁ = kgeom (r₂ ^ 10) t₂ ∧ kgeom (r₁ ^ 6) t₁ = kgeom (r₂ ^ 6) t₂ ∧
      kgeom (r₁ ^ 5) t₁ = kgeom (r₂ ^ 5) t₂ ∧ kgeom (r₁ ^ 3) t₁ = kgeom (r₂ ^ 3) t₂) ∧
    kgeom r₁ t₁ ≠ kgeom r₂ t₂ := by
  obtain ⟨a1, a2, a3, a4⟩ := five_domain_table_118 hr₁0 hr₁1 ht₁ h118
  obtain ⟨b1, b2, b3, b4⟩ := five_domain_table hr₂0 hr₂1 ht₂ h120
  exact ⟨⟨by rw [a1, b1], by rw [a2, b2], by rw [a3, b3], by rw [a4, b4]⟩, by omega⟩

/-! ## The exact gauge freedom of the master knee -/

/-- A ceiling equation cuts out a half-open interval of master knees. -/
theorem ceilDiv_eq_iff {B m v : ℕ} (hm : 0 < m) (hv : 0 < v) :
    B ⌈/⌉ m = v ↔ m * (v - 1) < B ∧ B ≤ m * v := by
  constructor
  · intro h
    refine ⟨?_, (ceilDiv_le_iff_le_mul hm).1 (by omega)⟩
    by_contra hle
    push_neg at hle
    have : B ⌈/⌉ m ≤ v - 1 := (ceilDiv_le_iff_le_mul hm).2 hle
    omega
  · rintro ⟨h1, h2⟩
    have hup : B ⌈/⌉ m ≤ v := (ceilDiv_le_iff_le_mul hm).2 h2
    have hlow : ¬ B ⌈/⌉ m ≤ v - 1 := fun h => absurd ((ceilDiv_le_iff_le_mul hm).1 h) (by omega)
    omega

/-- **Exact gauge freedom.**  With the exponent vector `(10, 6, 5, 3)` the
five-domain table is reproduced by a master knee `B` **iff** `B ∈ {118, 119,
120}`.  The one-gate measurement determines the master profile only up to this
three-element ambiguity. -/
theorem master_solution_set {B : ℕ} :
    (B ⌈/⌉ 10 = 12 ∧ B ⌈/⌉ 6 = 20 ∧ B ⌈/⌉ 5 = 24 ∧ B ⌈/⌉ 3 = 40) ↔
      (B = 118 ∨ B = 119 ∨ B = 120) := by
  rw [ceilDiv_eq_iff (by norm_num) (by norm_num), ceilDiv_eq_iff (by norm_num) (by norm_num),
    ceilDiv_eq_iff (by norm_num) (by norm_num), ceilDiv_eq_iff (by norm_num) (by norm_num)]
  omega

/-! ## A two-sided prediction bound for the tax -/

/-- **Two-sided bound.**  Under an `m`-fold root tax the fine knee `B` and the
coarse knee `A` always satisfy `B ≤ m·A < B + m`: the multiplicative law holds
with an error strictly smaller than the multiplier itself. -/
theorem knee_root_two_sided {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    {m : ℕ} (hm : 0 < m) :
    kgeom r t ≤ m * kgeom (r ^ m) t ∧ m * kgeom (r ^ m) t < kgeom r t + m := by
  rw [kgeom_root hr0 hr1 ht hm]
  rcases Nat.eq_zero_or_pos (kgeom r t ⌈/⌉ m) with h0 | hpos
  · have hB : kgeom r t ≤ m * 0 := (ceilDiv_le_iff_le_mul hm).1 (by omega)
    simp only [h0]
    omega
  · obtain ⟨d, hd⟩ : ∃ d, kgeom r t ⌈/⌉ m = d + 1 := ⟨kgeom r t ⌈/⌉ m - 1, by omega⟩
    obtain ⟨hlow, hup⟩ := (ceilDiv_eq_iff (B := kgeom r t) hm hpos).1 rfl
    rw [hd] at hlow hup ⊢
    simp only [Nat.add_sub_cancel] at hlow
    rw [Nat.mul_succ] at hup ⊢
    omega

/-- **The French knee is 39 or 40.**  If the English profile is the square of
the French one and the English knee is `20`, then the French knee is forced
into `{39, 40}` — the reported `40` is right up to one position, and the
parity assumption of `french_knee_is_forty` is exactly what removes `39`. -/
theorem french_knee_39_or_40 {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    (hen : kgeom (r ^ 2) t = 20) :
    kgeom r t = 39 ∨ kgeom r t = 40 := by
  obtain ⟨h1, h2⟩ := knee_root_two_sided hr0 hr1 ht (m := 2) (by norm_num)
  rw [hen] at h1 h2
  omega

end Physics.AttentionKnee