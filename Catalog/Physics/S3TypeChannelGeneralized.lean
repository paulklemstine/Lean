import Physics.S3TypeChannelLossy

/-!
# From one bit to `log₂ d`: the coupling-quotient law, and how it detects the Galois group

Second research cycle on the `S₃` type channel.  The one-bit law of
`Physics.S3TypeChannelUniversal` is the `d = 2` case of a *coupling-quotient law*: if the
only statistical coupling between a residue observable and a Frobenius observable is a
`D`-valued invariant which is balanced on both sides, then

  `I(residue ; Frobenius) = log₂ (card D)`   exactly.

For an `S₃`-cubic the coupling invariant is the sign character, `D = {±1}`, giving `1`.
For a *cyclic* cubic the coupling invariant is the whole Galois group `C₃`, giving
`log₂ 3 ≈ 1.585`.  And for the coarser splitting-type readout of a cyclic cubic the value
drops to `log₂ 3 - 2/3 ≈ 0.918`.  So the exact value `1.0000` is a *fingerprint of the
group `S₃`*: neither the cyclic cubic Frobenius channel nor its type channel attains it.

Main results.

* `S3General.Imut_transpose` — mutual information is symmetric in the two observables.
* `S3General.Imut_eq_HB_of_det` — determinism law in the second slot.
* `S3General.Imut_eq_logb_card_of_coupling` — **the coupling-quotient law**
  `I = log₂ (card D)`, for arbitrary finite `A`, `B`, `D`.
* `S3General.Imut_c3Frob_eq` — a cyclic cubic transmits `log₂ 3` bits to the Frobenius.
* `S3General.Imut_c3Type_eq` — its splitting-type readout transmits `log₂ 3 - 2/3` bits.
* `S3General.galois_group_is_detected` — the three values are pairwise different, and only
  the `S₃` type channel is exactly one bit.
-/

namespace S3General

open scoped BigOperators
open Finset S3Channel

variable {A B : Type*} [Fintype A] [Fintype B]

/-! ## Symmetry of mutual information -/

lemma total_transpose (n : A → B → ℕ) : total (fun b a => n a b) = total n := by
  simpa [total] using Finset.sum_comm (s := (univ : Finset B)) (t := (univ : Finset A))
    (f := fun b a => n a b)

lemma Hjoint_transpose (n : A → B → ℕ) : Hjoint (fun b a => n a b) = Hjoint n := by
  rw [Hjoint, Hjoint, total_transpose]
  simpa using Finset.sum_comm (s := (univ : Finset B)) (t := (univ : Finset A))
    (f := fun b a => sur ((n a b : ℝ) / (total n : ℝ)))

/-- **Mutual information is symmetric**: transposing the count table leaves `I` unchanged. -/
theorem Imut_transpose (n : A → B → ℕ) : Imut (fun b a => n a b) = Imut n := by
  have h1 : HA (fun b a => n a b) = HB n := by
    rw [HA, HB, total_transpose]; rfl
  have h2 : HB (fun b a => n a b) = HA n := by
    rw [HA, HB, total_transpose]; rfl
  rw [Imut, Imut, h1, h2, Hjoint_transpose]
  ring

/-- **Determinism law in the second slot.**  If the *second* observable is a function `f`
of the first, then `I(X;Y) = H(Y)`. -/
theorem Imut_eq_HB_of_det (n : A → B → ℕ) (f : A → B)
    (hdet : ∀ a b, b ≠ f a → n a b = 0) : Imut n = HB n := by
  have h := Imut_eq_HA_of_det (fun b a => n a b) f (fun b a hb => hdet a b hb)
  rw [Imut_transpose] at h
  rw [h, HA, HB, total_transpose]
  rfl

/-! ## The coupling-quotient law -/

section Coupling

variable {D : Type*} [Fintype D] [DecidableEq D] [Nonempty D]
variable (n : A → B → ℕ) (chi : A → D) (g : B → D) (m : B → ℕ) (k M2 : ℕ)

omit [Fintype B] [Nonempty D] in
lemma card_eq_card_mul_of_balanced
    (hk : ∀ c : D, (univ.filter (fun a => chi a = c)).card = k) :
    Fintype.card A = Fintype.card D * k := by
  have h : Fintype.card A = ∑ c : D, (univ.filter (fun a => chi a = c)).card := by
    simpa [Finset.card_univ] using Finset.card_eq_sum_card_fiberwise
      (f := chi) (s := (univ : Finset A)) (t := (univ : Finset D)) (fun a _ => mem_univ _)
  rw [h]
  simp [hk, Finset.card_univ, mul_comm]

omit [Fintype A] [Nonempty D] in
lemma sum_m_eq_card_mul
    (hM : ∀ c : D, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) :
    ∑ b, m b = Fintype.card D * M2 := by
  rw [← Finset.sum_fiberwise (univ : Finset B) g m]
  simp [hM, Finset.card_univ, mul_comm]

variable {n chi g m k M2}

omit [Fintype A] [Fintype D] [Nonempty D] in
lemma margA_coupling (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hM : ∀ c : D, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) (a : A) :
    margA n a = M2 := by
  have h1 : margA n a = ∑ b ∈ univ.filter (fun b => chi a = g b), m b := by
    rw [Finset.sum_filter]
    exact Finset.sum_congr rfl (fun b _ => hn a b)
  have h2 : (univ.filter (fun b => chi a = g b)) = univ.filter (fun b => g b = chi a) := by
    refine Finset.filter_congr (fun b _ => ?_)
    simp [eq_comm]
  rw [h1, h2, hM (chi a)]

omit [Fintype B] [Fintype D] [Nonempty D] in
lemma margB_coupling (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hk : ∀ c : D, (univ.filter (fun a => chi a = c)).card = k) (b : B) :
    margB n b = k * m b := by
  have h : margB n b = ∑ a ∈ univ.filter (fun a => chi a = g b), m b := by
    rw [Finset.sum_filter]
    exact Finset.sum_congr rfl (fun a _ => hn a b)
  rw [h, Finset.sum_const, hk (g b), smul_eq_mul]

omit [Nonempty D] in
lemma total_coupling (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hk : ∀ c : D, (univ.filter (fun a => chi a = c)).card = k)
    (hM : ∀ c : D, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) :
    total n = k * (Fintype.card D * M2) := by
  rw [total_eq_sum_margB]
  have h : ∑ b, margB n b = ∑ b, k * m b :=
    Finset.sum_congr rfl (fun b _ => margB_coupling hn hk b)
  rw [h, ← Finset.mul_sum, sum_m_eq_card_mul g m M2 hM]

/-- **The coupling-quotient law.**  Suppose the joint table of two finite observables is
supported on the "diagonal" of a `D`-valued invariant, with all fibres of the invariant on
the `A`-side of equal size `k > 0` and all fibres on the `B`-side of equal weight `M₂ > 0`.
Then the mutual information is exactly `log₂ (card D)` — the entropy of the coupling
quotient, and nothing else. -/
theorem Imut_eq_logb_card_of_coupling
    (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hk : ∀ c : D, (univ.filter (fun a => chi a = c)).card = k) (hk0 : 0 < k)
    (hM : ∀ c : D, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) (hM0 : 0 < M2) :
    Imut n = Real.logb 2 (Fintype.card D) := by
  have hd0 : 0 < Fintype.card D := Fintype.card_pos
  set d : ℕ := Fintype.card D with hd
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk0
  have hdR : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd0
  have hM2R : (0 : ℝ) < (M2 : ℝ) := by exact_mod_cast hM0
  have htot : total n = k * (d * M2) := total_coupling hn hk hM
  have hNR : ((total n : ℕ) : ℝ) = (k : ℝ) * ((d : ℝ) * (M2 : ℝ)) := by
    rw [htot]; push_cast; ring
  -- the `A`-entropy: `A` is uniform of size `d·k`
  have hHA : HA n = Real.logb 2 ((k : ℝ) * (d : ℝ)) := by
    have hbal : ∀ a : A, ((margA n a : ℕ) : ℝ) / ((total n : ℕ) : ℝ) = 1 / ((k : ℝ) * (d : ℝ)) := by
      intro a
      rw [margA_coupling hn hM a, hNR]
      field_simp
    have hsum : HA n = ∑ _a : A, sur (1 / ((k : ℝ) * (d : ℝ))) :=
      Finset.sum_congr rfl (fun a _ => by rw [hbal a])
    rw [hsum, Finset.sum_const, Finset.card_univ,
      card_eq_card_mul_of_balanced chi k hk, nsmul_eq_mul]
    have hinv := sur_inv ((k : ℝ) * (d : ℝ)) (by positivity)
    push_cast
    rw [← hinv]
    ring
  -- the joint entropy: `H(Y)` plus `log₂ k`
  have hHjoint : Hjoint n = HB n + Real.logb 2 (k : ℝ) := by
    have hswap : Hjoint n = ∑ b, ∑ a, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ)) := by
      simpa [Hjoint] using Finset.sum_comm (s := (univ : Finset A)) (t := (univ : Finset B))
        (f := fun a b => sur ((n a b : ℝ) / ((total n : ℕ) : ℝ)))
    have hinner : ∀ b : B, ∑ a, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ))
        = (k : ℝ) * sur (((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) / (k : ℝ)) := by
      intro b
      have hval : ∀ a : A, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ))
          = if chi a = g b then sur (((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) / (k : ℝ)) else 0 := by
        intro a
        by_cases h : chi a = g b
        · have hnab : ((n a b : ℕ) : ℝ) = (m b : ℝ) := by rw [hn a b, if_pos h]
          rw [hnab, hNR, if_pos h]
          congr 1
          field_simp
        · rw [hn a b, if_neg h, if_neg h]
          simp
      calc ∑ a, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ))
          = ∑ a, (if chi a = g b then
              sur (((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) / (k : ℝ)) else 0) :=
            Finset.sum_congr rfl (fun a _ => hval a)
        _ = ∑ _a ∈ univ.filter (fun a => chi a = g b),
              sur (((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) / (k : ℝ)) := (Finset.sum_filter _ _).symm
        _ = (k : ℝ) * sur (((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) / (k : ℝ)) := by
            rw [Finset.sum_const, hk (g b), nsmul_eq_mul]
    have hHBval : ∀ b : B, sur ((margB n b : ℝ) / ((total n : ℕ) : ℝ))
        = sur ((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) := by
      intro b
      rw [margB_coupling hn hk b, hNR]
      congr 1
      push_cast
      field_simp
    have hsumratio : ∑ b, ((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) = 1 := by
      rw [← Finset.sum_div]
      have hs : ((∑ b, m b : ℕ) : ℝ) = (d : ℝ) * (M2 : ℝ) := by
        rw [sum_m_eq_card_mul g m M2 hM]; push_cast; ring
      push_cast at hs ⊢
      rw [hs]
      field_simp
    calc Hjoint n = ∑ b, (k : ℝ) * sur (((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) / (k : ℝ)) := by
          rw [hswap]; exact Finset.sum_congr rfl (fun b _ => hinner b)
      _ = ∑ b, (sur ((m b : ℝ) / ((d : ℝ) * (M2 : ℝ)))
            + ((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))) * Real.logb 2 (k : ℝ)) :=
          Finset.sum_congr rfl (fun b _ => sur_div _ _ hkR)
      _ = (∑ b, sur ((m b : ℝ) / ((d : ℝ) * (M2 : ℝ))))
            + (∑ b, ((m b : ℝ) / ((d : ℝ) * (M2 : ℝ)))) * Real.logb 2 (k : ℝ) := by
          rw [Finset.sum_add_distrib, Finset.sum_mul]
      _ = HB n + Real.logb 2 (k : ℝ) := by
          rw [hsumratio, one_mul]
          congr 1
          exact (Finset.sum_congr rfl (fun b _ => hHBval b)).symm
  have hlog : Real.logb 2 ((k : ℝ) * (d : ℝ))
      = Real.logb 2 (k : ℝ) + Real.logb 2 (d : ℝ) :=
    Real.logb_mul (ne_of_gt hkR) (ne_of_gt hdR)
  rw [Imut, hHA, hHjoint, hlog]
  ring

/-- The `S₃` sign channel is the `d = 2` case of the coupling-quotient law. -/
theorem Imut_eq_one_of_two_coupling (hd2 : Fintype.card D = 2)
    (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hk : ∀ c : D, (univ.filter (fun a => chi a = c)).card = k) (hk0 : 0 < k)
    (hM : ∀ c : D, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) (hM0 : 0 < M2) :
    Imut n = 1 := by
  rw [Imut_eq_logb_card_of_coupling hn hk hk0 hM hM0, hd2]
  simp

end Coupling

/-! ## A cyclic cubic: the same machine, a different constant

For a cyclic cubic field (Galois group `C₃`, square discriminant — e.g. `x³ - 3x - 1`,
`disc = 81`) the Frobenius element is *itself* an abelian invariant, determined by the
residue class of `p` modulo the conductor.  The coupling quotient is now all of `C₃`, so
the channel carries `log₂ 3` bits, not one.  The coarser splitting-type readout
(split ⇔ Frobenius trivial) carries `log₂ 3 - 2/3` bits.  Neither equals `1`.
-/

/-- Chebotarev table of (residue class, Frobenius element) for a cyclic cubic: the residue
determines the Frobenius bijectively. -/
def c3FrobTable : ZMod 3 → ZMod 3 → ℕ := fun a f => if a = f then 1 else 0

/-- **A cyclic cubic transmits `log₂ 3` bits, not one.** -/
theorem Imut_c3Frob_eq : Imut c3FrobTable = Real.logb 2 3 := by
  have hcard : Fintype.card (ZMod 3) = 3 := by decide
  have h := Imut_eq_logb_card_of_coupling (A := ZMod 3) (B := ZMod 3) (D := ZMod 3)
    (n := c3FrobTable) (chi := id) (g := id) (m := fun _ => 1) (k := 1) (M2 := 1)
    (fun a b => rfl) (by decide) one_pos (by decide) one_pos
  rw [h, hcard]
  norm_num

/-- Chebotarev table of (residue class, splitting type) for a cyclic cubic: `p` splits
completely iff its Frobenius is trivial. -/
def c3TypeTable : ZMod 3 → Bool → ℕ := fun a r => if decide (a = 0) = r then 1 else 0

theorem c3TypeTable_total : total c3TypeTable = 3 := by decide

theorem c3TypeTable_margB_true : margB c3TypeTable true = 1 := by decide

theorem c3TypeTable_margB_false : margB c3TypeTable false = 2 := by decide

/-- **The splitting-type readout of a cyclic cubic carries `log₂ 3 - 2/3` bits.**
Here the type is a deterministic function of the residue, so the channel value is the type
entropy `H(1/3, 2/3)`. -/
theorem Imut_c3Type_eq : Imut c3TypeTable = Real.logb 2 3 - 2 / 3 := by
  have hdet : ∀ (a : ZMod 3) (b : Bool), b ≠ (fun a : ZMod 3 => decide (a = 0)) a →
      c3TypeTable a b = 0 := by
    intro a b hb
    simp only [c3TypeTable]
    rw [if_neg (fun h => hb h.symm)]
  rw [Imut_eq_HB_of_det c3TypeTable (fun a => decide (a = 0)) hdet]
  have h : HB c3TypeTable = sur (1 / 3 : ℝ) + sur (2 / 3 : ℝ) := by
    rw [HB, Fintype.sum_bool, c3TypeTable_margB_true, c3TypeTable_margB_false,
      c3TypeTable_total]
    norm_num
  rw [h, S3Lossy.sur_one_third, S3Lossy.sur_two_thirds]
  ring

lemma logb_two_three_lt_five_thirds : Real.logb 2 3 < 5 / 3 := by
  have h27 : Real.logb 2 (27 : ℝ) = 3 * Real.logb 2 3 := by
    rw [show (27 : ℝ) = 3 ^ (3 : ℕ) by norm_num, Real.logb_pow]
    norm_num
  have h32 : Real.logb 2 (32 : ℝ) = 5 := by
    rw [show (32 : ℝ) = 2 ^ (5 : ℕ) by norm_num, Real.logb_pow]
    simp
  have hlt : Real.logb 2 (27 : ℝ) < Real.logb 2 (32 : ℝ) :=
    Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)
  rw [h27, h32] at hlt
  linarith

/-- **The channel value detects the Galois group.**  Exactly one bit for the `S₃` type
channel; strictly less for the cyclic-cubic type channel; strictly more for the
cyclic-cubic Frobenius channel.  The value `1.0000` is a fingerprint of `S₃`, not an
artefact of the alphabet sizes. -/
theorem galois_group_is_detected :
    Imut (S3Universal.residueTable S3Universal.chi3) = 1 ∧
      Imut c3TypeTable < 1 ∧ 1 < Imut c3FrobTable := by
  refine ⟨S3Universal.Ires_xcubed_sub_three, ?_, ?_⟩
  · rw [Imut_c3Type_eq]; linarith [logb_two_three_lt_five_thirds]
  · rw [Imut_c3Frob_eq]; exact S3Lossy.one_lt_logb_two_three

end S3General