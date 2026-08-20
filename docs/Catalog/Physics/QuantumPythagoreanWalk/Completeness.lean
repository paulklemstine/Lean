import Physics.QuantumPythagoreanWalk.Walk

/-!
# Quantum-Pythagorean-Walk — V. Completeness of the walk (Berggren descent)

The resonance mechanism of `Collapse.lean` is only useful if the walk can *see* every
primitive Pythagorean triple.  Here we prove exactly that, i.e. Berggren's theorem in the
form needed for the walk:

`walk` is a **bijection** from walk words onto the primitive Pythagorean triples with odd
first leg (`walk_bijective_onto_oddPPT`, `walk_injective`, `exists_word_of_isPPT`).

The proof is a descent.  For a node `t = (a,b,c)` put

`u = a + 2b - 2c`,  `v = 2a + b - 2c`,  `c₀ = 3c - 2a - 2b`.

* `u` is odd, hence never `0` (parity is an invariant of the tree, `walk_odd_a`);
* `v = 0` forces `t = (3,4,5)` (`v_eq_zero_iff_root`);
* `u < 0` and `v < 0` are incompatible: squaring `2c ≥ a+2b` and `2c ≥ 2a+b` gives
  `3a ≥ 4b` and `3b ≥ 4a`, whence `9ab ≥ 16ab` (`not_both_nonpos`);
* in each remaining sign sector exactly one of the three inverse Berggren maps has positive
  legs, and it lowers the hypotenuse (`parent_hyp_lt`, from the catalog file
  `Shared/BerggrenTrees/Parent_hyp_lt.lean`, reproved here for `Node`).

Consequences: the depth-`n` layer of the walk consists of exactly `3ⁿ` distinct triples
(`card_layer`), so the counting used in the barrier of `Barrier.lean` is *sharp*, and the
resonance set of `Walk.lean` is the exact set of resonant primitive triples of depth `n`.
-/

namespace QuantumPythagoreanWalk

open Node

namespace Node

/-! ### Parity is an invariant: the first leg is always odd -/

theorem odd_a_stepA {t : Node} (h : t.a % 2 = 1) : (stepA t).a % 2 = 1 := by
  simp only [stepA_a]; omega

theorem odd_a_stepB {t : Node} (h : t.a % 2 = 1) : (stepB t).a % 2 = 1 := by
  simp only [stepB_a]; omega

theorem odd_a_stepC {t : Node} (h : t.a % 2 = 1) : (stepC t).a % 2 = 1 := by
  simp only [stepC_a]; omega

theorem odd_a_branch {t : Node} (h : t.a % 2 = 1) (i : Fin 3) : (branch i t).a % 2 = 1 := by
  fin_cases i
  · exact odd_a_stepA h
  · exact odd_a_stepB h
  · exact odd_a_stepC h

/-! ### The two descent coordinates and their sign sectors -/

/-- First descent coordinate `u = a + 2b - 2c`. -/
def uu (t : Node) : ℤ := t.a + 2 * t.b - 2 * t.c

/-- Second descent coordinate `v = 2a + b - 2c`. -/
def vv (t : Node) : ℤ := 2 * t.a + t.b - 2 * t.c

@[simp] lemma uu_stepA (s : Node) : uu (stepA s) = s.a := by simp [uu]; ring
@[simp] lemma vv_stepA (s : Node) : vv (stepA s) = -s.b := by simp [vv]; ring
@[simp] lemma uu_stepB (s : Node) : uu (stepB s) = s.a := by simp [uu]; ring
@[simp] lemma vv_stepB (s : Node) : vv (stepB s) = s.b := by simp [vv]; ring
@[simp] lemma uu_stepC (s : Node) : uu (stepC s) = -s.a := by simp [uu]; ring
@[simp] lemma vv_stepC (s : Node) : vv (stepC s) = s.b := by simp [vv]; ring

/-! ### The three inverse (parent) maps -/

/-- Parent through branch `A`. -/
def parA (t : Node) : Node :=
  ⟨t.a + 2 * t.b - 2 * t.c, -2 * t.a - t.b + 2 * t.c, -2 * t.a - 2 * t.b + 3 * t.c⟩

/-- Parent through branch `B`. -/
def parB (t : Node) : Node :=
  ⟨t.a + 2 * t.b - 2 * t.c, 2 * t.a + t.b - 2 * t.c, -2 * t.a - 2 * t.b + 3 * t.c⟩

/-- Parent through branch `C`. -/
def parC (t : Node) : Node :=
  ⟨-t.a - 2 * t.b + 2 * t.c, 2 * t.a + t.b - 2 * t.c, -2 * t.a - 2 * t.b + 3 * t.c⟩

@[simp] lemma parA_a (t : Node) : (parA t).a = t.a + 2 * t.b - 2 * t.c := rfl
@[simp] lemma parA_b (t : Node) : (parA t).b = -2 * t.a - t.b + 2 * t.c := rfl
@[simp] lemma parA_c (t : Node) : (parA t).c = -2 * t.a - 2 * t.b + 3 * t.c := rfl
@[simp] lemma parB_a (t : Node) : (parB t).a = t.a + 2 * t.b - 2 * t.c := rfl
@[simp] lemma parB_b (t : Node) : (parB t).b = 2 * t.a + t.b - 2 * t.c := rfl
@[simp] lemma parB_c (t : Node) : (parB t).c = -2 * t.a - 2 * t.b + 3 * t.c := rfl
@[simp] lemma parC_a (t : Node) : (parC t).a = -t.a - 2 * t.b + 2 * t.c := rfl
@[simp] lemma parC_b (t : Node) : (parC t).b = 2 * t.a + t.b - 2 * t.c := rfl
@[simp] lemma parC_c (t : Node) : (parC t).c = -2 * t.a - 2 * t.b + 3 * t.c := rfl

theorem stepA_parA (t : Node) : stepA (parA t) = t := by
  simp only [stepA, parA_a, parA_b, parA_c]
  cases t
  simp only [Node.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem stepB_parB (t : Node) : stepB (parB t) = t := by
  simp only [stepB, parB_a, parB_b, parB_c]
  cases t
  simp only [Node.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem stepC_parC (t : Node) : stepC (parC t) = t := by
  simp only [stepC, parC_a, parC_b, parC_c]
  cases t
  simp only [Node.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem parA_stepA (t : Node) : parA (stepA t) = t := by
  simp only [parA, stepA_a, stepA_b, stepA_c]
  cases t
  simp only [Node.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem parB_stepB (t : Node) : parB (stepB t) = t := by
  simp only [parB, stepB_a, stepB_b, stepB_c]
  cases t
  simp only [Node.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem parC_stepC (t : Node) : parC (stepC t) = t := by
  simp only [parC, stepC_a, stepC_b, stepC_c]
  cases t
  simp only [Node.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-! ### The descent estimates -/

/-- The parent hypotenuse `3c - 2a - 2b` is smaller than `c` (catalog: `parent_hyp_lt`). -/
theorem parent_hyp_lt {t : Node} (h : t.IsPPT) : -2 * t.a - 2 * t.b + 3 * t.c < t.c := by
  nlinarith [h.pyth, h.pos_a, h.pos_b, sq_nonneg (t.a + t.b - t.c), sq_nonneg (t.a - t.b)]

/-- The parent hypotenuse is positive (catalog: `parent_hyp_pos`). -/
theorem parent_hyp_pos {t : Node} (h : t.IsPPT) : 0 < -2 * t.a - 2 * t.b + 3 * t.c := by
  nlinarith [h.pyth, h.pos_a, h.pos_b, h.pos_c, sq_nonneg (3 * t.c - 2 * t.a - 2 * t.b),
    sq_nonneg (t.a - t.b), mul_pos h.pos_a h.pos_b]

/-- The two descent coordinates cannot both be nonpositive. -/
theorem not_both_nonpos {t : Node} (h : t.IsPPT)
    (hu : t.a + 2 * t.b - 2 * t.c ≤ 0) (hv : 2 * t.a + t.b - 2 * t.c ≤ 0) : False := by
  have hpy := h.pyth
  have ha := h.pos_a
  have hb := h.pos_b
  have hc := h.pos_c
  -- squaring `2c ≥ a + 2b` gives `3a² ≥ 4ab`, i.e. `3a ≥ 4b`
  have h1 : 3 * t.a ^ 2 ≥ 4 * t.a * t.b := by nlinarith
  have h2 : 3 * t.b ^ 2 ≥ 4 * t.a * t.b := by nlinarith
  nlinarith [mul_pos ha hb]

/-- The first descent coordinate is odd, hence nonzero, when the first leg is odd. -/
theorem u_ne_zero {t : Node} (h : t.a % 2 = 1) : t.a + 2 * t.b - 2 * t.c ≠ 0 := by omega

/-- The second descent coordinate vanishes only at the root. -/
theorem v_eq_zero_iff_root {t : Node} (h : t.IsPPT) (hv : 2 * t.a + t.b - 2 * t.c = 0) :
    t = root := by
  have hpy := h.pyth
  have ha := h.pos_a
  have hb := h.pos_b
  have hc := h.pos_c
  have hac := h.a_lt_c
  -- `b = 2c - 2a` forces `(5a - 3c)(a - c) = 0`, hence `5a = 3c`
  have hfac : (5 * t.a - 3 * t.c) * (t.a - t.c) = 0 := by nlinarith
  have h5 : 5 * t.a = 3 * t.c := by
    rcases mul_eq_zero.mp hfac with h' | h'
    · omega
    · omega
  -- so `a = 3k, b = 4k, c = 5k`; primitivity forces `k = 1`
  obtain ⟨k, hk⟩ : (3 : ℤ) ∣ t.a := by omega
  have hc5 : t.c = 5 * k := by omega
  have hb4 : t.b = 4 * k := by omega
  have hkpos : 0 < k := by omega
  have hunit : IsUnit (k : ℤ) := by
    have hcop := h.cop
    rw [hk, hb4] at hcop
    exact IsCoprime.isUnit_of_dvd' hcop ⟨3, by ring⟩ ⟨4, by ring⟩
  have hk1 : k = 1 := by
    rcases Int.isUnit_iff.mp hunit with h' | h' <;> omega
  cases t
  simp_all [root]

/-! ### Every primitive triple with odd first leg has a Berggren parent -/

/-- The parent triples satisfy the Pythagorean relation. -/
theorem parA_pyth {t : Node} (h : t.IsPPT) :
    (parA t).a ^ 2 + (parA t).b ^ 2 = (parA t).c ^ 2 := by
  simp only [parA_a, parA_b, parA_c]; linear_combination h.pyth

theorem parB_pyth {t : Node} (h : t.IsPPT) :
    (parB t).a ^ 2 + (parB t).b ^ 2 = (parB t).c ^ 2 := by
  simp only [parB_a, parB_b, parB_c]; linear_combination h.pyth

theorem parC_pyth {t : Node} (h : t.IsPPT) :
    (parC t).a ^ 2 + (parC t).b ^ 2 = (parC t).c ^ 2 := by
  simp only [parC_a, parC_b, parC_c]; linear_combination h.pyth

/-- Coprimality descends to the parents (the Berggren matrices are unimodular). -/
private theorem cop_of_step {s t : Node} (hs : s.a ^ 2 + s.b ^ 2 = s.c ^ 2)
    (hcop : IsCoprime t.a t.b) (α₁ α₂ α₃ β₁ β₂ β₃ : ℤ)
    (ha : t.a = α₁ * s.a + α₂ * s.b + α₃ * s.c)
    (hb : t.b = β₁ * s.a + β₂ * s.b + β₃ * s.c) : IsCoprime s.a s.b := by
  rw [Int.isCoprime_iff_gcd_eq_one] at hcop ⊢
  by_contra hne
  obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd hne
  have hpg : (p : ℤ) ∣ ((Int.gcd s.a s.b : ℕ) : ℤ) := Int.natCast_dvd_natCast.mpr hpd
  have hpa : (p : ℤ) ∣ s.a := hpg.trans (Int.gcd_dvd_left s.a s.b)
  have hpb : (p : ℤ) ∣ s.b := hpg.trans (Int.gcd_dvd_right s.a s.b)
  have hpc : (p : ℤ) ∣ s.c := dvd_c_of_dvd_legs hs hpa hpb
  have hta : (p : ℤ) ∣ t.a := by
    rw [ha]
    exact dvd_add (dvd_add (Dvd.dvd.mul_left hpa _) (Dvd.dvd.mul_left hpb _))
      (Dvd.dvd.mul_left hpc _)
  have htb : (p : ℤ) ∣ t.b := by
    rw [hb]
    exact dvd_add (dvd_add (Dvd.dvd.mul_left hpa _) (Dvd.dvd.mul_left hpb _))
      (Dvd.dvd.mul_left hpc _)
  have hdvd := Int.dvd_gcd hta htb
  rw [hcop] at hdvd
  have hp1 : p ∣ 1 := by exact_mod_cast hdvd
  exact hp.ne_one (Nat.dvd_one.mp hp1)

/-- **Descent.**  Every primitive triple with odd first leg other than the root is the child
of a (unique, see `walk_injective`) primitive triple with odd first leg and strictly smaller
hypotenuse. -/
theorem exists_parent {t : Node} (h : t.IsPPT) (hodd : t.a % 2 = 1) (hne : t ≠ root) :
    ∃ (s : Node) (i : Fin 3), s.IsPPT ∧ s.a % 2 = 1 ∧ s.c < t.c ∧ branch i s = t := by
  have hu := u_ne_zero hodd
  have hv : 2 * t.a + t.b - 2 * t.c ≠ 0 := fun hv => hne (v_eq_zero_iff_root h hv)
  have hclt := parent_hyp_lt h
  have hcpos := parent_hyp_pos h
  rcases lt_or_gt_of_ne hu with hu' | hu'
  · -- u < 0 : then v > 0 and the parent is `parC`
    have hv' : 0 < 2 * t.a + t.b - 2 * t.c := by
      rcases lt_or_gt_of_ne hv with h' | h'
      · exact absurd (not_both_nonpos h (by omega) (by omega)) (by simp)
      · exact h'
    refine ⟨parC t, 2, ⟨parC_pyth h, by simp only [parC_a]; omega, by simp only [parC_b]; omega,
      by simp only [parC_c]; omega, ?_⟩, by simp only [parC_a]; omega,
      by simp only [parC_c]; omega, by simpa using stepC_parC t⟩
    refine cop_of_step (t := t) (parC_pyth h) h.cop (-1) 2 2 (-2) 1 2 ?_ ?_
    · simp only [parC_a, parC_b, parC_c]; ring
    · simp only [parC_a, parC_b, parC_c]; ring
  · rcases lt_or_gt_of_ne hv with hv' | hv'
    · -- u > 0, v < 0 : the parent is `parA`
      refine ⟨parA t, 0, ⟨parA_pyth h, by simp only [parA_a]; omega, by simp only [parA_b]; omega,
        by simp only [parA_c]; omega, ?_⟩, by simp only [parA_a]; omega,
        by simp only [parA_c]; omega, by simpa using stepA_parA t⟩
      refine cop_of_step (t := t) (parA_pyth h) h.cop 1 (-2) 2 2 (-1) 2 ?_ ?_
      · simp only [parA_a, parA_b, parA_c]; ring
      · simp only [parA_a, parA_b, parA_c]; ring
    · -- u > 0, v > 0 : the parent is `parB`
      refine ⟨parB t, 1, ⟨parB_pyth h, by simp only [parB_a]; omega, by simp only [parB_b]; omega,
        by simp only [parB_c]; omega, ?_⟩, by simp only [parB_a]; omega,
        by simp only [parB_c]; omega, by simpa using stepB_parB t⟩
      refine cop_of_step (t := t) (parB_pyth h) h.cop 1 2 2 2 1 2 ?_ ?_
      · simp only [parB_a, parB_b, parB_c]; ring
      · simp only [parB_a, parB_b, parB_c]; ring

end Node

/-! ### Surjectivity: every primitive triple with odd first leg is on the tree -/

theorem walk_odd_a (w : List (Fin 3)) : (walk w).a % 2 = 1 := by
  induction w with
  | nil => decide
  | cons i w ih => exact Node.odd_a_branch ih i

/-- **Completeness of the Berggren walk (surjectivity).**  Every primitive Pythagorean
triple with odd first leg is reached by some walk word. -/
theorem exists_word_of_isPPT : ∀ (t : Node), t.IsPPT → t.a % 2 = 1 → ∃ w, walk w = t := by
  have key : ∀ (m : ℕ) (t : Node), t.c.toNat ≤ m → t.IsPPT → t.a % 2 = 1 → ∃ w, walk w = t := by
    intro m
    induction m with
    | zero =>
        intro t hm ht _
        exfalso
        have := ht.five_le_c
        omega
    | succ m ih =>
        intro t hm ht hodd
        by_cases hroot : t = root
        · exact ⟨[], by simp [hroot]⟩
        · obtain ⟨s, i, hs, hsodd, hlt, hstep⟩ := Node.exists_parent ht hodd hroot
          have hsm : s.c.toNat ≤ m := by
            have h5 := ht.five_le_c
            have := hs.pos_c
            omega
          obtain ⟨w, hw⟩ := ih s hsm hs hsodd
          exact ⟨i :: w, by rw [walk_cons, hw, hstep]⟩
  intro t ht hodd
  exact key t.c.toNat t le_rfl ht hodd

/-! ### Injectivity: the branch is recoverable from the child -/

theorem walk_root_iff {w : List (Fin 3)} : walk w = Node.root ↔ w = [] := by
  constructor
  · intro h
    cases w with
    | nil => rfl
    | cons i w =>
        exfalso
        have hlt := Node.hyp_lt_branch (walk_isPPT w) i
        have hc : (walk w).c ≥ 5 := (walk_isPPT w).five_le_c
        rw [walk_cons] at h
        rw [h] at hlt
        simp only [Node.root] at hlt
        omega
  · intro h; simp [h]

/-- **Uniqueness of the walk word (injectivity).**  Different words reach different triples;
the sign pattern of `(a + 2b - 2c, 2a + b - 2c)` recovers the last branch taken. -/
theorem walk_injective : Function.Injective walk := by
  intro w
  induction w with
  | nil =>
      intro w' h
      exact (walk_root_iff.mp (by rw [← h]; simp)).symm
  | cons i w ih =>
      intro w' h
      cases w' with
      | nil =>
          exfalso
          have hr : walk (i :: w) = Node.root := by rw [h]; simp
          have := walk_root_iff.mp hr
          simp at this
      | cons j w' =>
          have hs := walk_isPPT w
          have hs' := walk_isPPT w'
          rw [walk_cons, walk_cons] at h
          -- the sign sector of the child determines the branch index
          have p1 := hs.pos_a
          have p2 := hs.pos_b
          have p3 := hs'.pos_a
          have p4 := hs'.pos_b
          have hij : i = j := by
            fin_cases i <;> fin_cases j
            · rfl
            · exfalso
              have h2 : Node.stepA (walk w) = Node.stepB (walk w') := h
              have hv := congrArg Node.vv h2
              simp only [Node.vv_stepA, Node.vv_stepB] at hv
              omega
            · exfalso
              have h2 : Node.stepA (walk w) = Node.stepC (walk w') := h
              have hu := congrArg Node.uu h2
              simp only [Node.uu_stepA, Node.uu_stepC] at hu
              omega
            · exfalso
              have h2 : Node.stepB (walk w) = Node.stepA (walk w') := h
              have hv := congrArg Node.vv h2
              simp only [Node.vv_stepA, Node.vv_stepB] at hv
              omega
            · rfl
            · exfalso
              have h2 : Node.stepB (walk w) = Node.stepC (walk w') := h
              have hu := congrArg Node.uu h2
              simp only [Node.uu_stepB, Node.uu_stepC] at hu
              omega
            · exfalso
              have h2 : Node.stepC (walk w) = Node.stepA (walk w') := h
              have hu := congrArg Node.uu h2
              simp only [Node.uu_stepA, Node.uu_stepC] at hu
              omega
            · exfalso
              have h2 : Node.stepC (walk w) = Node.stepB (walk w') := h
              have hu := congrArg Node.uu h2
              simp only [Node.uu_stepB, Node.uu_stepC] at hu
              omega
            · rfl
          subst hij
          have hww : walk w = walk w' := by
            fin_cases i
            · have := congrArg Node.parA h
              simpa [Node.parA_stepA] using this
            · have := congrArg Node.parB h
              simpa [Node.parB_stepB] using this
            · have := congrArg Node.parC h
              simpa [Node.parC_stepC] using this
          rw [ih hww]

/-- **Berggren bijection.**  The walk is a bijection from words onto the primitive
Pythagorean triples with odd first leg. -/
theorem walk_bijective_onto_oddPPT :
    Function.Injective walk ∧
      (∀ t : Node, (t.IsPPT ∧ t.a % 2 = 1) ↔ ∃ w, walk w = t) := by
  refine ⟨walk_injective, fun t => ⟨fun h => exists_word_of_isPPT t h.1 h.2, ?_⟩⟩
  rintro ⟨w, rfl⟩
  exact ⟨walk_isPPT w, walk_odd_a w⟩

/-- The depth-`n` layer of the walk consists of exactly `3ⁿ` distinct primitive triples, so
the counting behind the search barrier is sharp. -/
theorem card_layer (n : ℕ) :
    (Finset.image (fun w : Fin n → Fin 3 => walk (wordOf w)) Finset.univ).card = 3 ^ n := by
  rw [Finset.card_image_of_injective _ ?_]
  · simp
  · intro w w' h
    have : wordOf w = wordOf w' := walk_injective h
    have hlen : List.ofFn w = List.ofFn w' := this
    exact List.ofFn_injective hlen

end QuantumPythagoreanWalk