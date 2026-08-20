import Probability.TalagrandRep
import Probability.TalagrandAnalytic

/-!
# Talagrand's convex-distance inequality on finite product spaces

Let `α` be a finite alphabet and let `p i` be a probability weight on `α` for each
coordinate `i : Fin n` (the coordinates are independent but need *not* be
identically distributed).  Equip `Fin n → α` with the product measure
`Talagrand.mass p`.  The main theorem of this file is the exponential moment bound

  `Eexp p A * mass p A ≤ 1`,  where  `Eexp p A = ∑ x, wt p x * exp (dTsq A x / 4)`,

for every `A : Finset (Fin n → α)`.  This is Talagrand's convex-distance
inequality (with the explicit constant `1/4` in the exponent), proved by
induction on the number of coordinates.  The i.i.d. case is recorded separately as
`Talagrand.Eexp_mul_mass_le_one_iid`.

The three ingredients are

* `Talagrand.exists_isRepW_mix` — the geometric step: a convex combination of a
  representation of the section `sec A a` and a representation of the
  projection `proj A` represents `A` at `Fin.cons a y`, at the price of one unit
  in the new coordinate;
* `Talagrand.weighted_holder` — Hölder's inequality, used to interpolate the two
  inductive hypotheses;
* `Talagrand.exists_lambda_bound` — the scalar interpolation lemma
  `inf_lam exp ((1-lam)^2/4) r ^ (-lam) ≤ 2 - r`.

-/

namespace Talagrand

open Finset Real

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ### The product measure -/

/-- The product weight of a point of `Fin n → α`, for a *coordinatewise* family of
weights `p i` (the coordinates need not be identically distributed). -/
def wt {n : ℕ} (p : Fin n → α → ℝ) (x : Fin n → α) : ℝ := ∏ i, p i (x i)

/-- The product measure of a finite set of points. -/
def mass {n : ℕ} (p : Fin n → α → ℝ) (S : Finset (Fin n → α)) : ℝ := ∑ x ∈ S, wt p x

/-- The exponential moment of Talagrand's squared convex distance to `A`. -/
noncomputable def Eexp {n : ℕ} (p : Fin n → α → ℝ) (A : Finset (Fin n → α)) : ℝ :=
  ∑ x : Fin n → α, wt p x * Real.exp (dTsq A x / 4)

omit [Fintype α] [DecidableEq α] in
lemma wt_nonneg {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a) (x : Fin n → α) :
    0 ≤ wt p x :=
  Finset.prod_nonneg fun _ _ => hp0 _ _

omit [Fintype α] [DecidableEq α] in
lemma mass_nonneg {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (S : Finset (Fin n → α)) : 0 ≤ mass p S :=
  Finset.sum_nonneg fun x _ => wt_nonneg hp0 x

omit [Fintype α] [DecidableEq α] in
lemma mass_mono {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    {S T : Finset (Fin n → α)} (h : S ⊆ T) :
    mass p S ≤ mass p T :=
  Finset.sum_le_sum_of_subset_of_nonneg h fun x _ _ => wt_nonneg hp0 x

omit [DecidableEq α] in
/-- Decomposition of a sum over `Fin (n+1) → α` into the first coordinate and the rest. -/
lemma sum_cons_decomp {n : ℕ} (g : (Fin (n + 1) → α) → ℝ) :
    ∑ z : Fin (n + 1) → α, g z = ∑ b : α, ∑ y : Fin n → α, g (Fin.cons b y) := by
  have h1 : ∑ z : Fin (n + 1) → α, g z = ∑ q : α × (Fin n → α), g (Fin.cons q.1 q.2) :=
    (Fintype.sum_equiv (Fin.consEquiv (fun _ => α)) _ _ (fun _ => rfl)).symm
  rw [h1, Fintype.sum_prod_type]

/-- The same decomposition for a sum over a `Finset`. -/
lemma sum_finset_cons_decomp {n : ℕ} (A : Finset (Fin (n + 1) → α))
    (f : (Fin (n + 1) → α) → ℝ) :
    ∑ z ∈ A, f z
      = ∑ b : α, ∑ y : Fin n → α, if Fin.cons b y ∈ A then f (Fin.cons b y) else 0 := by
  classical
  have hA : A = Finset.univ.filter (fun z : Fin (n + 1) → α => z ∈ A) := by
    ext z; simp
  rw [hA, Finset.sum_filter, sum_cons_decomp]
  simp

omit [Fintype α] [DecidableEq α] in
/-- Splitting off the first coordinate of a product weight. -/
lemma wt_cons {n : ℕ} (p : Fin (n + 1) → α → ℝ) (b : α) (y : Fin n → α) :
    wt p (Fin.cons b y) = p 0 b * wt (Fin.tail p) y := by
  simp [wt, Fin.prod_univ_succ, Fin.tail]

omit [DecidableEq α] in
/-- The total mass of the product measure is `1`. -/
lemma sum_wt_eq_one : ∀ {n : ℕ} (p : Fin n → α → ℝ), (∀ i, ∑ a, p i a = 1) →
    ∑ x : Fin n → α, wt p x = 1 := by
  intro n
  induction n with
  | zero => intro p _; simp [wt]
  | succ n ih =>
      intro p hp1
      rw [sum_cons_decomp]
      have hstep : ∀ b : α, ∑ y : Fin n → α, wt p (Fin.cons b y) = p 0 b := by
        intro b
        simp only [wt_cons, ← Finset.mul_sum,
          ih (Fin.tail p) (fun i => hp1 i.succ), mul_one]
      simp_rw [hstep]
      exact hp1 0

omit [DecidableEq α] in
lemma mass_univ {n : ℕ} {p : Fin n → α → ℝ} (hp1 : ∀ i, ∑ a, p i a = 1) :
    mass p (Finset.univ : Finset (Fin n → α)) = 1 := by
  simpa [mass] using sum_wt_eq_one p hp1

/-! ### Sections and projections -/

/-- The section of `A` above the letter `a` in the first coordinate. -/
def sec {n : ℕ} (A : Finset (Fin (n + 1) → α)) (a : α) : Finset (Fin n → α) :=
  Finset.univ.filter (fun y => Fin.cons a y ∈ A)

/-- The projection of `A` forgetting the first coordinate. -/
def proj {n : ℕ} (A : Finset (Fin (n + 1) → α)) : Finset (Fin n → α) :=
  Finset.univ.filter (fun y => ∃ a, Fin.cons a y ∈ A)

@[simp] lemma mem_sec {n : ℕ} {A : Finset (Fin (n + 1) → α)} {a : α} {y : Fin n → α} :
    y ∈ sec A a ↔ Fin.cons a y ∈ A := by simp [sec]

@[simp] lemma mem_proj {n : ℕ} {A : Finset (Fin (n + 1) → α)} {y : Fin n → α} :
    y ∈ proj A ↔ ∃ a, Fin.cons a y ∈ A := by simp [proj]

lemma sec_subset_proj {n : ℕ} (A : Finset (Fin (n + 1) → α)) (a : α) :
    sec A a ⊆ proj A := by
  intro y hy
  exact mem_proj.2 ⟨a, mem_sec.1 hy⟩

/-- Mass decomposes over the first coordinate. -/
lemma mass_eq_sum_sec {n : ℕ} {p : Fin (n + 1) → α → ℝ} (A : Finset (Fin (n + 1) → α)) :
    mass p A = ∑ b : α, p 0 b * mass (Fin.tail p) (sec A b) := by
  classical
  rw [mass, sum_finset_cons_decomp]
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [mass, Finset.mul_sum]
  rw [sec, Finset.sum_filter]
  refine Finset.sum_congr rfl fun y _ => ?_
  by_cases h : Fin.cons b y ∈ A <;> simp [h, wt_cons]

/-! ### Transfer of sums over `A` to sums over sections and projections -/

lemma sum_sec_transfer {n : ℕ} (A : Finset (Fin (n + 1) → α)) (a : α)
    (h : (Fin n → α) → ℝ) :
    ∑ z ∈ A, (if z 0 = a ∧ Fin.tail z ∈ sec A a then h (Fin.tail z) else 0)
      = ∑ y ∈ sec A a, h y := by
  classical
  rw [sum_finset_cons_decomp, Finset.sum_comm]
  simp only [Fin.cons_zero, Fin.tail_cons]
  have hinner : ∀ y : Fin n → α,
      (∑ b : α, if Fin.cons b y ∈ A then
        (if b = a ∧ y ∈ sec A a then h y else 0) else 0)
        = if y ∈ sec A a then h y else 0 := by
    intro y
    refine (Finset.sum_eq_single a ?_ ?_).trans ?_
    · intro b _ hb
      simp [hb]
    · intro ha
      exact absurd (Finset.mem_univ a) ha
    · by_cases hy : y ∈ sec A a
      · simp [hy, mem_sec.1 hy]
      · simp [hy]
  simp only [hinner]
  rw [Finset.sum_ite_mem]
  simp

lemma sum_proj_transfer {n : ℕ} (A : Finset (Fin (n + 1) → α)) (c : (Fin n → α) → α)
    (hc : ∀ y ∈ proj A, Fin.cons (c y) y ∈ A) (h : (Fin n → α) → ℝ) :
    ∑ z ∈ A, (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A then h (Fin.tail z) else 0)
      = ∑ y ∈ proj A, h y := by
  classical
  rw [sum_finset_cons_decomp, Finset.sum_comm]
  simp only [Fin.cons_zero, Fin.tail_cons]
  have hinner : ∀ y : Fin n → α,
      (∑ b : α, if Fin.cons b y ∈ A then
        (if b = c y ∧ y ∈ proj A then h y else 0) else 0)
        = if y ∈ proj A then h y else 0 := by
    intro y
    refine (Finset.sum_eq_single (c y) ?_ ?_).trans ?_
    · intro b _ hb
      simp [hb]
    · intro ha
      exact absurd (Finset.mem_univ (c y)) ha
    · by_cases hy : y ∈ proj A
      · simp [hy, hc y hy]
      · simp [hy]
  simp only [hinner]
  rw [Finset.sum_ite_mem]
  simp

/-! ### The geometric step -/

/-- **Mixing lemma.**  Given a weight `w1` on the section `sec A a` and a weight
`w2` on the projection `proj A`, the `lam`-mixture of the two associated convex
combinations represents `A` at the point `Fin.cons a y`, at the cost of at most
`(1 - lam) ^ 2` in the new coordinate. -/
lemma exists_isRepW_mix {n : ℕ} (A : Finset (Fin (n + 1) → α)) (a : α) (y : Fin n → α)
    {lam : ℝ} (hlam0 : 0 ≤ lam) (hlam1 : lam ≤ 1)
    {w1 w2 : (Fin n → α) → ℝ} (hw10 : ∀ z, 0 ≤ w1 z) (hw20 : ∀ z, 0 ≤ w2 z)
    (hw1 : lam * (∑ z ∈ sec A a, w1 z) = lam) (hw2 : ∑ z ∈ proj A, w2 z = 1) :
    ∃ V, IsRepW A (Fin.cons a y) V ∧
      sqn V ≤ (1 - lam) ^ 2
        + lam * sqn (fun j => ∑ z ∈ sec A a, w1 z * hamm (y j) (z j))
        + (1 - lam) * sqn (fun j => ∑ z ∈ proj A, w2 z * hamm (y j) (z j)) := by
  classical
  have hBne : (proj A).Nonempty := by
    rcases Finset.eq_empty_or_nonempty (proj A) with h | h
    · rw [h] at hw2; simp at hw2
    · exact h
  obtain ⟨y0, hy0⟩ := hBne
  obtain ⟨b0, hb0⟩ := mem_proj.1 hy0
  -- a choice of a completion for each point of the projection
  set c : (Fin n → α) → α :=
    fun y' => if h : ∃ b, Fin.cons b y' ∈ A then h.choose else b0 with hc
  have hcmem : ∀ y' ∈ proj A, Fin.cons (c y') y' ∈ A := by
    intro y' hy'
    have h : ∃ b, Fin.cons b y' ∈ A := mem_proj.1 hy'
    simp only [hc, dif_pos h]
    exact h.choose_spec
  -- the mixed weight
  set W : (Fin (n + 1) → α) → ℝ := fun z =>
    lam * (if z 0 = a ∧ Fin.tail z ∈ sec A a then w1 (Fin.tail z) else 0)
      + (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A then w2 (Fin.tail z) else 0)
    with hW
  have hW0 : ∀ z, 0 ≤ W z := by
    intro z
    have h1 : 0 ≤ (if z 0 = a ∧ Fin.tail z ∈ sec A a then w1 (Fin.tail z) else 0) := by
      split <;> [exact hw10 _; exact le_rfl]
    have h2 : 0 ≤ (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A then w2 (Fin.tail z) else 0) := by
      split <;> [exact hw20 _; exact le_rfl]
    have := mul_nonneg hlam0 h1
    have := mul_nonneg (by linarith : (0:ℝ) ≤ 1 - lam) h2
    simp only [hW]
    positivity
  -- the weight is a probability weight on `A`
  have hWsum : ∑ z ∈ A, W z = 1 := by
    simp only [hW, Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [sum_sec_transfer A a w1, sum_proj_transfer A c hcmem w2, hw1, hw2]
    ring
  refine ⟨fun i => ∑ z ∈ A, W z * hamm ((Fin.cons a y : Fin (n+1) → α) i) (z i),
    ⟨W, hW0, hWsum, fun i => rfl⟩, ?_⟩
  set V : Fin (n + 1) → ℝ :=
    fun i => ∑ z ∈ A, W z * hamm ((Fin.cons a y : Fin (n+1) → α) i) (z i) with hV
  set u : Fin n → ℝ := fun j => ∑ z ∈ sec A a, w1 z * hamm (y j) (z j) with hu
  set v : Fin n → ℝ := fun j => ∑ z ∈ proj A, w2 z * hamm (y j) (z j) with hv
  -- the new coordinate
  have hV0nonneg : 0 ≤ V 0 :=
    Finset.sum_nonneg fun z _ => mul_nonneg (hW0 z) (hamm_nonneg _ _)
  have hV0 : V 0 ≤ 1 - lam := by
    have hterm : ∀ z ∈ A, W z * hamm ((Fin.cons a y : Fin (n+1) → α) 0) (z 0)
        ≤ (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
            then w2 (Fin.tail z) else 0) := by
      intro z _
      have hz0 : (Fin.cons a y : Fin (n+1) → α) 0 = a := by simp
      rw [hz0]
      have h1 : lam * (if z 0 = a ∧ Fin.tail z ∈ sec A a then w1 (Fin.tail z) else 0)
          * hamm a (z 0) = 0 := by
        by_cases hcase : z 0 = a ∧ Fin.tail z ∈ sec A a
        · have hz : hamm a (z 0) = 0 := by rw [hcase.1]; simp
          rw [hz, mul_zero]
        · rw [if_neg hcase]; ring
      have h2 : 0 ≤ (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
          then w2 (Fin.tail z) else 0) := by
        split <;> [exact hw20 _; exact le_rfl]
      have hlam' : (0:ℝ) ≤ 1 - lam := by linarith
      have h3 : (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
            then w2 (Fin.tail z) else 0) * hamm a (z 0)
          ≤ (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
            then w2 (Fin.tail z) else 0) := by
        have hb := hamm_le_one a (z 0)
        have hnn : 0 ≤ (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
            then w2 (Fin.tail z) else 0) := mul_nonneg hlam' h2
        nlinarith [hamm_nonneg a (z 0)]
      calc W z * hamm a (z 0)
          = lam * (if z 0 = a ∧ Fin.tail z ∈ sec A a then w1 (Fin.tail z) else 0) * hamm a (z 0)
            + (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
                then w2 (Fin.tail z) else 0) * hamm a (z 0) := by
            simp only [hW]; ring
        _ ≤ 0 + (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
                then w2 (Fin.tail z) else 0) := by rw [h1]; linarith [h3]
        _ = (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
                then w2 (Fin.tail z) else 0) := by ring
    calc V 0 ≤ ∑ z ∈ A, (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
            then w2 (Fin.tail z) else 0) := Finset.sum_le_sum hterm
      _ = (1 - lam) * ∑ y' ∈ proj A, w2 y' := by
          rw [← Finset.mul_sum, sum_proj_transfer A c hcmem w2]
      _ = 1 - lam := by rw [hw2, mul_one]
  -- the old coordinates
  have hVsucc : ∀ j : Fin n, V j.succ = lam * u j + (1 - lam) * v j := by
    intro j
    have hcons : ∀ z : Fin (n + 1) → α, z j.succ = Fin.tail z j := fun z => rfl
    have hy : (Fin.cons a y : Fin (n+1) → α) j.succ = y j := by simp
    have : V j.succ = ∑ z ∈ A, (lam * (if z 0 = a ∧ Fin.tail z ∈ sec A a
              then w1 (Fin.tail z) * hamm (y j) (Fin.tail z j) else 0)
            + (1 - lam) * (if z 0 = c (Fin.tail z) ∧ Fin.tail z ∈ proj A
              then w2 (Fin.tail z) * hamm (y j) (Fin.tail z j) else 0)) := by
      have hite : ∀ (P : Prop) [Decidable P] (s t : ℝ),
          (if P then s else 0) * t = if P then s * t else 0 := by
        intro P _ s t; split <;> simp
      simp only [hV, hy]
      refine Finset.sum_congr rfl fun z _ => ?_
      simp only [hW, hcons z, add_mul, mul_assoc, hite]
    rw [this, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
      sum_sec_transfer A a (fun z => w1 z * hamm (y j) (z j)),
      sum_proj_transfer A c hcmem (fun z => w2 z * hamm (y j) (z j))]
  -- summing the squares
  have hsq : sqn V = V 0 ^ 2 + ∑ j : Fin n, (V j.succ) ^ 2 := by
    simp [sqn, Fin.sum_univ_succ]
  have hconv : ∀ j : Fin n, (V j.succ) ^ 2 ≤ lam * (u j) ^ 2 + (1 - lam) * (v j) ^ 2 := by
    intro j
    rw [hVsucc j]
    nlinarith [sq_nonneg (u j - v j), mul_nonneg hlam0 (sub_nonneg.2 hlam1)]
  have hsum : ∑ j : Fin n, (V j.succ) ^ 2 ≤ lam * sqn u + (1 - lam) * sqn v := by
    calc ∑ j : Fin n, (V j.succ) ^ 2 ≤ ∑ j : Fin n, (lam * (u j) ^ 2 + (1 - lam) * (v j) ^ 2) :=
          Finset.sum_le_sum fun j _ => hconv j
      _ = lam * sqn u + (1 - lam) * sqn v := by
          rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]; rfl
  have hV0sq : V 0 ^ 2 ≤ (1 - lam) ^ 2 := by nlinarith [hV0nonneg, hV0]
  rw [hsq]
  linarith

/-- The convex distance to `A` at `Fin.cons a y`, controlled by the distances to the
section and to the projection. -/
lemma dTsq_cons_le {n : ℕ} (A : Finset (Fin (n + 1) → α)) (a : α) (y : Fin n → α)
    {lam : ℝ} (hlam0 : 0 ≤ lam) (hlam1 : lam ≤ 1) (hB : (proj A).Nonempty)
    (hsec : lam ≠ 0 → (sec A a).Nonempty) :
    dTsq A (Fin.cons a y) ≤
      (1 - lam) ^ 2 + lam * dTsq (sec A a) y + (1 - lam) * dTsq (proj A) y := by
  classical
  refine le_of_forall_pos_le_add fun ε hε => ?_
  -- a near-optimal weight for the projection
  obtain ⟨v, hvrep, hvlt⟩ := exists_isRepW_lt hB y (half_pos hε)
  obtain ⟨w2, hw20, hw2s, hveq⟩ := hvrep
  -- a near-optimal weight for the section (or the zero weight if `lam = 0`)
  obtain ⟨w1, hw10, hw1s, hw1sq⟩ :
      ∃ w1 : (Fin n → α) → ℝ, (∀ z, 0 ≤ w1 z) ∧ lam * (∑ z ∈ sec A a, w1 z) = lam ∧
        lam * sqn (fun j => ∑ z ∈ sec A a, w1 z * hamm (y j) (z j))
          ≤ lam * dTsq (sec A a) y + ε / 2 := by
    by_cases hlam : lam = 0
    · refine ⟨fun _ => 0, fun _ => le_rfl, by simp [hlam], ?_⟩
      simp [hlam, sqn]
      linarith
    · obtain ⟨u, hurep, hult⟩ := exists_isRepW_lt (hsec hlam) y (half_pos hε)
      obtain ⟨w1, hw10, hw1s, hueq⟩ := hurep
      refine ⟨w1, hw10, by rw [hw1s, mul_one], ?_⟩
      have hueq' : (fun j => ∑ z ∈ sec A a, w1 z * hamm (y j) (z j)) = u := by
        funext j; exact (hueq j).symm
      rw [hueq']
      nlinarith [hult.le, sq_nonneg lam, hε.le]
  obtain ⟨V, hVrep, hVle⟩ :=
    exists_isRepW_mix A a y hlam0 hlam1 hw10 hw20 hw1s hw2s
  have hveq' : (fun j => ∑ z ∈ proj A, w2 z * hamm (y j) (z j)) = v := by
    funext j; exact (hveq j).symm
  rw [hveq'] at hVle
  have h1 : dTsq A (Fin.cons a y) ≤ sqn V := dTsq_le_of_isRepW hVrep
  have h2 : (1 - lam) * sqn v ≤ (1 - lam) * dTsq (proj A) y + ε / 2 := by
    nlinarith [hvlt.le, hε.le]
  linarith

/-! ### The exponential moment bound -/

lemma Eexp_nonneg {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (A : Finset (Fin n → α)) : 0 ≤ Eexp p A :=
  Finset.sum_nonneg fun x _ => mul_nonneg (wt_nonneg hp0 x) (Real.exp_pos _).le

lemma one_le_Eexp {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (A : Finset (Fin n → α)) : 1 ≤ Eexp p A := by
  have h : ∀ x : Fin n → α, wt p x ≤ wt p x * Real.exp (dTsq A x / 4) := by
    intro x
    have hd : 0 ≤ dTsq A x / 4 := by
      have := dTsq_nonneg A x; linarith
    have : 1 ≤ Real.exp (dTsq A x / 4) := Real.one_le_exp hd
    nlinarith [wt_nonneg hp0 x]
  calc (1:ℝ) = ∑ x : Fin n → α, wt p x := (sum_wt_eq_one p hp1).symm
    _ ≤ Eexp p A := Finset.sum_le_sum fun x _ => h x

/-- **Talagrand's convex-distance inequality** on the product space `Fin n → α`
equipped with the product measure attached to the family of coordinate weights
`p : Fin n → α → ℝ`.  The coordinates are independent but need *not* be
identically distributed. -/
theorem Eexp_mul_mass_le_one : ∀ {n : ℕ} (p : Fin n → α → ℝ) (_ : ∀ i a, 0 ≤ p i a)
    (_ : ∀ i, ∑ a, p i a = 1) (A : Finset (Fin n → α)), Eexp p A * mass p A ≤ 1 := by
  intro n
  induction n with
  | zero =>
      intro p hp0 hp1 A
      rcases Finset.eq_empty_or_nonempty A with rfl | hA
      · simp [mass, Eexp]
      · have hall : ∀ x : Fin 0 → α, x ∈ A := by
          obtain ⟨x0, hx0⟩ := hA
          intro x
          have : x = x0 := Subsingleton.elim _ _
          rwa [this]
        have hE : Eexp p A = 1 := by
          have hx : ∀ x : Fin 0 → α, wt p x * Real.exp (dTsq A x / 4) = wt p x := by
            intro x
            rw [dTsq_eq_zero_of_mem (hall x)]
            simp
          rw [Eexp]
          simp_rw [hx]
          exact sum_wt_eq_one p hp1
        have hm : mass p A = 1 := by
          have hAu : A = Finset.univ := Finset.eq_univ_of_forall hall
          rw [hAu]
          exact mass_univ hp1
        rw [hE, hm]; norm_num
  | succ n ih =>
      intro p hp0 hp1 A
      -- the weights of the last `n` coordinates
      set q : Fin n → α → ℝ := Fin.tail p with hq
      have hq0 : ∀ i a, 0 ≤ q i a := fun i a => hp0 i.succ a
      have hq1 : ∀ i, ∑ a, q i a = 1 := fun i => hp1 i.succ
      rcases eq_or_lt_of_le (mass_nonneg hp0 A) with hmA | hmA
      · rw [← hmA, mul_zero]; norm_num
      -- the projection has positive mass
      have hBmass : 0 < mass q (proj A) := by
        by_contra hB
        push_neg at hB
        have hB0 : mass q (proj A) = 0 := le_antisymm hB (mass_nonneg hq0 _)
        have : mass p A ≤ mass q (proj A) := by
          rw [mass_eq_sum_sec A]
          calc ∑ b : α, p 0 b * mass q (sec A b)
              ≤ ∑ b : α, p 0 b * mass q (proj A) := by
                refine Finset.sum_le_sum fun b _ => ?_
                exact mul_le_mul_of_nonneg_left
                  (mass_mono hq0 (sec_subset_proj A b)) (hp0 0 b)
            _ = mass q (proj A) := by rw [← Finset.sum_mul, hp1 0, one_mul]
        linarith
      have hBne : (proj A).Nonempty := by
        rcases Finset.eq_empty_or_nonempty (proj A) with h | h
        · rw [h] at hBmass; simp [mass] at hBmass
        · exact h
      -- the key per-letter estimate
      have hkey : ∀ b : α,
          ∑ y : Fin n → α, wt q y * Real.exp (dTsq A (Fin.cons b y) / 4)
            ≤ (2 - mass q (sec A b) / mass q (proj A)) / mass q (proj A) := by
        intro b
        set mB := mass q (proj A) with hmB
        set mS := mass q (sec A b) with hmS
        have hmSnn : 0 ≤ mS := mass_nonneg hq0 _
        have hEB : Eexp q (proj A) ≤ 1 / mB := by
          have := ih q hq0 hq1 (proj A)
          rw [le_div_iff₀ hBmass]
          linarith [this]
        rcases eq_or_lt_of_le hmSnn with hS0 | hSpos
        · -- the section is null: use the crude bound
          have hpt : ∀ y : Fin n → α,
              Real.exp (dTsq A (Fin.cons b y) / 4)
                ≤ Real.exp (1/4) * Real.exp (dTsq (proj A) y / 4) := by
            intro y
            have hd := dTsq_cons_le A b y (lam := 0) le_rfl zero_le_one hBne
              (by intro h; exact absurd rfl h)
            rw [← Real.exp_add]
            refine Real.exp_le_exp.2 ?_
            simp only [sub_zero, one_pow, zero_mul, one_mul] at hd
            linarith
          have hbound : ∑ y : Fin n → α, wt q y * Real.exp (dTsq A (Fin.cons b y) / 4)
              ≤ Real.exp (1/4) * Eexp q (proj A) := by
            rw [Eexp, Finset.mul_sum]
            refine Finset.sum_le_sum fun y _ => ?_
            have := hpt y
            have hw := wt_nonneg hq0 (p := q) y
            nlinarith [Real.exp_pos (dTsq (proj A) y / 4)]
          have hexp : Real.exp (1/4 : ℝ) ≤ 2 := by
            have := exp_le_quadratic (t := (1/4 : ℝ)) (by norm_num) (by norm_num)
            norm_num at this ⊢
            linarith
          have hrzero : (2 - mS / mB) = 2 := by rw [← hS0]; simp
          rw [hrzero]
          calc ∑ y : Fin n → α, wt q y * Real.exp (dTsq A (Fin.cons b y) / 4)
              ≤ Real.exp (1/4) * Eexp q (proj A) := hbound
            _ ≤ 2 * (1 / mB) := by
                have h1 : 0 ≤ Eexp q (proj A) := Eexp_nonneg hq0 _
                have h2 : Real.exp (1/4 : ℝ) ≤ 2 := hexp
                nlinarith [Real.exp_pos (1/4 : ℝ), hEB]
            _ = 2 / mB := by ring
        · -- the generic case
          have hSne : (sec A b).Nonempty := by
            rcases Finset.eq_empty_or_nonempty (sec A b) with h | h
            · rw [hmS, h] at hSpos; simp [mass] at hSpos
            · exact h
          have hSB : mS ≤ mB := by
            rw [hmS, hmB]; exact mass_mono hq0 (sec_subset_proj A b)
          set r := mS / mB with hr
          have hr0 : 0 ≤ r := div_nonneg hmSnn hBmass.le
          have hr1 : r ≤ 1 := by
            rw [hr, div_le_one hBmass]; exact hSB
          obtain ⟨lam, hlam0, hlam1, hlam⟩ := exists_lambda_bound hr0 hr1
          have hES : Eexp q (sec A b) ≤ 1 / mS := by
            have := ih q hq0 hq1 (sec A b)
            rw [le_div_iff₀ hSpos]
            linarith [this]
          -- pointwise bound
          have hpt : ∀ y : Fin n → α,
              Real.exp (dTsq A (Fin.cons b y) / 4)
                ≤ Real.exp ((1 - lam) ^ 2 / 4)
                  * ((Real.exp (dTsq (sec A b) y / 4)) ^ lam
                    * (Real.exp (dTsq (proj A) y / 4)) ^ (1 - lam)) := by
            intro y
            have hd := dTsq_cons_le A b y hlam0 hlam1 hBne (fun _ => hSne)
            rw [← Real.exp_mul, ← Real.exp_mul, ← Real.exp_add, ← Real.exp_add]
            refine Real.exp_le_exp.2 ?_
            have hstep : dTsq A (Fin.cons b y) / 4
                ≤ ((1 - lam) ^ 2 + lam * dTsq (sec A b) y + (1 - lam) * dTsq (proj A) y) / 4 := by
              linarith
            calc dTsq A (Fin.cons b y) / 4 ≤ _ := hstep
              _ = (1 - lam) ^ 2 / 4 + (dTsq (sec A b) y / 4 * lam
                    + dTsq (proj A) y / 4 * (1 - lam)) := by ring
          -- Hölder
          have hhold : ∑ y : Fin n → α, wt q y *
                ((Real.exp (dTsq (sec A b) y / 4)) ^ lam
                  * (Real.exp (dTsq (proj A) y / 4)) ^ (1 - lam))
              ≤ (Eexp q (sec A b)) ^ lam * (Eexp q (proj A)) ^ (1 - lam) := by
            have hF : 0 < ∑ y : Fin n → α, wt q y * Real.exp (dTsq (sec A b) y / 4) := by
              have := one_le_Eexp hq0 hq1 (sec A b); rw [Eexp] at this; linarith
            have hG : 0 < ∑ y : Fin n → α, wt q y * Real.exp (dTsq (proj A) y / 4) := by
              have := one_le_Eexp hq0 hq1 (proj A); rw [Eexp] at this; linarith
            have := weighted_holder (Finset.univ : Finset (Fin n → α)) (wt q)
              (fun y => Real.exp (dTsq (sec A b) y / 4))
              (fun y => Real.exp (dTsq (proj A) y / 4)) hlam0 hlam1
              (fun y _ => wt_nonneg hq0 y)
              (fun y _ => (Real.exp_pos _).le) (fun y _ => (Real.exp_pos _).le) hF hG
            simpa [Eexp] using this
          -- put things together
          have hmono : (Eexp q (sec A b)) ^ lam * (Eexp q (proj A)) ^ (1 - lam)
              ≤ (1 / mS) ^ lam * (1 / mB) ^ (1 - lam) := by
            have h1 : (0:ℝ) ≤ Eexp q (sec A b) := Eexp_nonneg hq0 _
            have h2 : (0:ℝ) ≤ Eexp q (proj A) := Eexp_nonneg hq0 _
            have hp1' : (Eexp q (sec A b)) ^ lam ≤ (1 / mS) ^ lam :=
              Real.rpow_le_rpow h1 hES hlam0
            have hp2' : (Eexp q (proj A)) ^ (1 - lam) ≤ (1 / mB) ^ (1 - lam) :=
              Real.rpow_le_rpow h2 hEB (by linarith)
            have hq1' : (0:ℝ) ≤ (Eexp q (proj A)) ^ (1 - lam) :=
              Real.rpow_nonneg h2 _
            have hq2 : (0:ℝ) ≤ (1 / mS) ^ lam :=
              Real.rpow_nonneg (by positivity) _
            nlinarith
          have hrpow : (1 / mS) ^ lam * (1 / mB) ^ (1 - lam) = (1 / mB) * r ^ (-lam) := by
            have hmS' : (0:ℝ) < mS := hSpos
            have hmB' : (0:ℝ) < mB := hBmass
            have h1 : (1 / mS : ℝ) ^ lam = (mS ^ lam)⁻¹ := by
              rw [one_div, Real.inv_rpow hmS'.le]
            have h2 : (1 / mB : ℝ) ^ (1 - lam) = (mB ^ (1 - lam))⁻¹ := by
              rw [one_div, Real.inv_rpow hmB'.le]
            have h3 : (mB : ℝ) ^ (1 - lam) = mB / mB ^ lam := by
              rw [Real.rpow_sub hmB', Real.rpow_one]
            have h4 : (r : ℝ) ^ (-lam) = (mS ^ lam / mB ^ lam)⁻¹ := by
              rw [hr, Real.rpow_neg (by positivity), Real.div_rpow hmS'.le hmB'.le]
            have hSpow : (0:ℝ) < mS ^ lam := Real.rpow_pos_of_pos hmS' _
            have hBpow : (0:ℝ) < mB ^ lam := Real.rpow_pos_of_pos hmB' _
            rw [h1, h2, h3, h4]
            field_simp
          calc ∑ y : Fin n → α, wt q y * Real.exp (dTsq A (Fin.cons b y) / 4)
              ≤ ∑ y : Fin n → α, wt q y * (Real.exp ((1 - lam) ^ 2 / 4)
                  * ((Real.exp (dTsq (sec A b) y / 4)) ^ lam
                    * (Real.exp (dTsq (proj A) y / 4)) ^ (1 - lam))) := by
                refine Finset.sum_le_sum fun y _ => ?_
                exact mul_le_mul_of_nonneg_left (hpt y) (wt_nonneg hq0 y)
            _ = Real.exp ((1 - lam) ^ 2 / 4) * ∑ y : Fin n → α, wt q y *
                  ((Real.exp (dTsq (sec A b) y / 4)) ^ lam
                    * (Real.exp (dTsq (proj A) y / 4)) ^ (1 - lam)) := by
                rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun y _ => by ring
            _ ≤ Real.exp ((1 - lam) ^ 2 / 4) * ((1 / mS) ^ lam * (1 / mB) ^ (1 - lam)) := by
                have := hhold.trans hmono
                exact mul_le_mul_of_nonneg_left this (Real.exp_pos _).le
            _ = (Real.exp ((1 - lam) ^ 2 / 4) * r ^ (-lam)) * (1 / mB) := by
                rw [hrpow]; ring
            _ ≤ (2 - r) * (1 / mB) := by
                exact mul_le_mul_of_nonneg_right hlam (by positivity)
            _ = (2 - mS / mB) / mB := by rw [hr]; ring
      -- assemble
      have hEA : Eexp p A ≤ (2 - mass p A / mass q (proj A)) / mass q (proj A) := by
        have hsplit : Eexp p A
            = ∑ b : α, p 0 b * ∑ y : Fin n → α, wt q y * Real.exp (dTsq A (Fin.cons b y) / 4) := by
          rw [Eexp, sum_cons_decomp]
          refine Finset.sum_congr rfl fun b _ => ?_
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun y _ => by rw [wt_cons]; ring
        rw [hsplit]
        calc ∑ b : α, p 0 b * ∑ y : Fin n → α, wt q y * Real.exp (dTsq A (Fin.cons b y) / 4)
            ≤ ∑ b : α, p 0 b * ((2 - mass q (sec A b) / mass q (proj A)) / mass q (proj A)) := by
              refine Finset.sum_le_sum fun b _ => ?_
              exact mul_le_mul_of_nonneg_left (hkey b) (hp0 0 b)
          _ = (2 - mass p A / mass q (proj A)) / mass q (proj A) := by
              have hM : mass q (proj A) ≠ 0 := ne_of_gt hBmass
              have hms : ∑ b : α, p 0 b * mass q (sec A b) = mass p A :=
                (mass_eq_sum_sec A).symm
              have expand : ∀ b : α,
                  p 0 b * ((2 - mass q (sec A b) / mass q (proj A)) / mass q (proj A))
                    = 2 * p 0 b / mass q (proj A)
                      - p 0 b * mass q (sec A b) / (mass q (proj A)) ^ 2 := by
                intro b; field_simp
              rw [Finset.sum_congr rfl (fun b (_ : b ∈ Finset.univ) => expand b),
                Finset.sum_sub_distrib, ← Finset.sum_div, ← Finset.sum_div, ← Finset.mul_sum,
                hp1 0, mul_one, hms]
              field_simp
      -- final algebra
      have hmAB : mass p A ≤ mass q (proj A) := by
        rw [mass_eq_sum_sec A]
        calc ∑ b : α, p 0 b * mass q (sec A b)
            ≤ ∑ b : α, p 0 b * mass q (proj A) := by
              refine Finset.sum_le_sum fun b _ => ?_
              exact mul_le_mul_of_nonneg_left (mass_mono hq0 (sec_subset_proj A b)) (hp0 0 b)
          _ = mass q (proj A) := by rw [← Finset.sum_mul, hp1 0, one_mul]
      have hmApos : 0 < mass p A := hmA
      have hfin : (2 - mass p A / mass q (proj A)) / mass q (proj A) * mass p A ≤ 1 := by
        rw [div_mul_eq_mul_div, div_le_one hBmass]
        have hb := hBmass
        have key : (2 - mass p A / mass q (proj A)) * mass p A ≤ mass q (proj A) := by
          have h := sq_nonneg (mass q (proj A) - mass p A)
          have hdiv : mass p A / mass q (proj A) * mass q (proj A) = mass p A := by
            field_simp
          nlinarith [hb, hmApos]
        exact key
      calc Eexp p A * mass p A
          ≤ (2 - mass p A / mass q (proj A)) / mass q (proj A) * mass p A :=
            mul_le_mul_of_nonneg_right hEA (mass_nonneg hp0 A)
        _ ≤ 1 := hfin

/-! ### The i.i.d. special case -/

/-- The i.i.d. family of coordinate weights attached to a single weight `p`. -/
def iid (p : α → ℝ) (n : ℕ) : Fin n → α → ℝ := fun _ => p

omit [Fintype α] [DecidableEq α] in
@[simp] lemma iid_apply (p : α → ℝ) (n : ℕ) (i : Fin n) : iid p n i = p := rfl

/-- **Talagrand's convex-distance inequality, i.i.d. form.** -/
theorem Eexp_mul_mass_le_one_iid {p : α → ℝ} (hp0 : ∀ a, 0 ≤ p a) (hp1 : ∑ a, p a = 1)
    {n : ℕ} (A : Finset (Fin n → α)) : Eexp (iid p n) A * mass (iid p n) A ≤ 1 :=
  Eexp_mul_mass_le_one (iid p n) (fun _ a => hp0 a) (fun _ => hp1) A

end Talagrand