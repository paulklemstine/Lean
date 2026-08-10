import ToricCode.Basic

/-!
# Bounded local geometry of the square torus cellulation

The previous research cycle explicitly flagged that its counterexamples were
*not* claimed to come from bounded-degree local cellulations, and listed
"bounded face size and bounded vertex degree" as a missing ingredient.  This
file supplies exactly that data for the square torus, for every `M, N ≥ 2`:

* `vertex_degree_eq_four` : every `Z`-stabilizer (vertex) acts on exactly `4`
  qubits;
* `face_size_eq_four` : every `X`-stabilizer (face) acts on exactly `4` qubits;
* `qubit_Z_degree_eq_two` and `qubit_X_degree_eq_two` : every qubit is touched
  by exactly `2` checks of each type.

Hence the toric code is an LDPC code with all check weights and qubit degrees
bounded by `4`, uniformly in `M` and `N`.  Combined with `ToricCode.Distance` this makes
the family a genuine geometric witness: bounded local geometry, fixed genus one,
and unbounded distance.
-/

open Matrix

namespace ToricCode

variable (M N : ℕ) [NeZero M] [NeZero N]

section Local

variable (hM : 2 ≤ M) (hN : 2 ≤ N)

include hM hN

omit [NeZero M] [NeZero N] in
lemma step_ne_zero (b : Bool) : step M N b ≠ 0 := by
  haveI : Fact (1 < M) := ⟨hM⟩
  haveI : Fact (1 < N) := ⟨hN⟩
  haveI := ZMod.nontrivial M
  haveI := ZMod.nontrivial N
  intro h
  cases b
  · exact one_ne_zero (congrArg Prod.fst h)
  · exact one_ne_zero (congrArg Prod.snd h)

omit [NeZero M] [NeZero N] in
/-- Incidence criterion for the vertex boundary map. -/
lemma d1_ne_zero_iff (v : Vert M N) (b : Bool) (u : ZMod M × ZMod N) :
    d1 M N v (b, u) ≠ 0 ↔ (u = v ∨ u = v - step M N b) := by
  have hs := step_ne_zero M N hM hN b
  constructor
  · intro h
    by_cases h1 : v = u
    · exact Or.inl h1.symm
    · by_cases h2 : v = u + step M N b
      · right; rw [h2]; ring
      · exact absurd (by simp [d1, h1, h2]) h
  · rintro (rfl | rfl)
    · have hne : ¬ (u = u + step M N b) := fun hc => hs (by linear_combination -hc)
      simp only [d1, if_neg hne]
      decide
    · have hne : ¬ (v = v - step M N b) := fun hc => hs (by linear_combination hc)
      have hb : v - step M N b + step M N b = v := by ring
      simp only [d1, if_neg hne, hb]
      decide

omit [NeZero M] [NeZero N] in
/-- Incidence criterion for the face boundary map. -/
lemma d2_ne_zero_iff (f : Face M N) (b : Bool) (u : ZMod M × ZMod N) :
    d2 M N (b, u) f ≠ 0 ↔ (u = f ∨ u = f + step M N (!b)) := by
  have hs := step_ne_zero M N hM hN (!b)
  constructor
  · intro h
    by_cases h1 : u = f
    · exact Or.inl h1
    · by_cases h2 : u = f + step M N (!b)
      · exact Or.inr h2
      · exact absurd (by simp [d2, h1, h2]) h
  · rintro (rfl | rfl)
    · have hne : ¬ (u = u + step M N (!b)) := fun hc => hs (by linear_combination -hc)
      simp only [d2, if_neg hne]
      decide
    · have hne : ¬ (f + step M N (!b) = f) := fun hc => hs (by linear_combination hc)
      simp only [d2, if_neg hne]
      decide

/-! ### Check weights -/

/-- The qubits acted on by the `Z`-check at the vertex `v`. -/
def zSupport (v : Vert M N) : Finset (Edge M N) :=
  Finset.univ.filter (fun e => d1 M N v e ≠ 0)

/-- **Every `Z`-stabilizer has weight `4`.** -/
theorem vertex_degree_eq_four (v : Vert M N) : (zSupport M N v).card = 4 := by
  classical
  have hs := step_ne_zero M N hM hN
  have hmap : zSupport M N v = Finset.univ.image
      (fun bs : Bool × Bool => ((bs.1, v - (if bs.2 then step M N bs.1 else 0)) : Edge M N)) := by
    ext e
    obtain ⟨b, u⟩ := e
    simp only [zSupport, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image,
      Prod.exists, Prod.mk.injEq]
    rw [d1_ne_zero_iff M N hM hN]
    constructor
    · rintro (rfl | rfl)
      · exact ⟨b, false, rfl, by simp⟩
      · exact ⟨b, true, rfl, by simp⟩
    · rintro ⟨b2, s, rfl, hu⟩
      cases s
      · left; simpa using hu.symm
      · right; simpa using hu.symm
  rw [hmap, Finset.card_image_of_injective _ ?inj, Finset.card_univ]
  · simp
  case inj =>
    rintro ⟨b1, s1⟩ ⟨b2, s2⟩ h
    simp only [Prod.mk.injEq] at h
    obtain ⟨rfl, hu⟩ := h
    have h3 : (if s1 then step M N b1 else 0) = (if s2 then step M N b1 else 0) := by
      linear_combination -hu
    cases s1 <;> cases s2
    · rfl
    · exact absurd (by simpa using h3.symm) (hs b1)
    · exact absurd (by simpa using h3) (hs b1)
    · rfl

/-- The qubits acted on by the `X`-check at the face `f`. -/
def xSupport (f : Face M N) : Finset (Edge M N) :=
  Finset.univ.filter (fun e => d2 M N e f ≠ 0)

/-- **Every `X`-stabilizer has weight `4`.** -/
theorem face_size_eq_four (f : Face M N) : (xSupport M N f).card = 4 := by
  classical
  have hs := step_ne_zero M N hM hN
  have hmap : xSupport M N f = Finset.univ.image
      (fun bs : Bool × Bool =>
        ((bs.1, f + (if bs.2 then step M N (!bs.1) else 0)) : Edge M N)) := by
    ext e
    obtain ⟨b, u⟩ := e
    simp only [xSupport, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image,
      Prod.exists, Prod.mk.injEq]
    rw [d2_ne_zero_iff M N hM hN]
    constructor
    · rintro (rfl | rfl)
      · exact ⟨b, false, rfl, by simp⟩
      · exact ⟨b, true, rfl, by simp⟩
    · rintro ⟨b2, s, rfl, hu⟩
      cases s
      · left; simpa using hu.symm
      · right; simpa using hu.symm
  rw [hmap, Finset.card_image_of_injective _ ?inj, Finset.card_univ]
  · simp
  case inj =>
    rintro ⟨b1, s1⟩ ⟨b2, s2⟩ h
    simp only [Prod.mk.injEq] at h
    obtain ⟨rfl, hu⟩ := h
    have h3 : (if s1 then step M N (!b1) else 0) = (if s2 then step M N (!b1) else 0) := by
      linear_combination hu
    cases s1 <;> cases s2
    · rfl
    · exact absurd (by simpa using h3.symm) (hs (!b1))
    · exact absurd (by simpa using h3) (hs (!b1))
    · rfl

/-! ### Qubit degrees -/

/-- The `Z`-checks acting on the qubit `e`. -/
def zChecks (e : Edge M N) : Finset (Vert M N) :=
  Finset.univ.filter (fun v => d1 M N v e ≠ 0)

/-- **Every qubit meets exactly two `Z`-checks** — its two endpoints. -/
theorem qubit_Z_degree_eq_two (e : Edge M N) : (zChecks M N e).card = 2 := by
  classical
  obtain ⟨b, u⟩ := e
  have hs := step_ne_zero M N hM hN b
  have hne : ¬ (u = u + step M N b) := fun hc => hs (by linear_combination -hc)
  have hmap : zChecks M N (b, u)
      = Finset.univ.image (fun s : Bool => (if s then u + step M N b else u : Vert M N)) := by
    ext v
    simp only [zChecks, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    rw [d1_ne_zero_iff M N hM hN]
    constructor
    · rintro (h | h)
      · exact ⟨false, by simp [h]⟩
      · refine ⟨true, ?_⟩
        show u + step M N b = v
        rw [h]
        ring
    · rintro ⟨s, hsv⟩
      cases s
      · left; simpa using hsv
      · right
        have hsv' : u + step M N b = v := hsv
        rw [← hsv']
        ring
  rw [hmap, Finset.card_image_of_injective _ ?inj, Finset.card_univ]
  · simp
  case inj =>
    intro s1 s2 h
    cases s1 <;> cases s2
    · rfl
    · exact absurd (by simpa using h) hne
    · exact absurd (by simpa using h.symm) hne
    · rfl

/-- The `X`-checks acting on the qubit `e`. -/
def xChecks (e : Edge M N) : Finset (Face M N) :=
  Finset.univ.filter (fun f => d2 M N e f ≠ 0)

/-- **Every qubit meets exactly two `X`-checks** — the two faces it separates. -/
theorem qubit_X_degree_eq_two (e : Edge M N) : (xChecks M N e).card = 2 := by
  classical
  obtain ⟨b, u⟩ := e
  have hs := step_ne_zero M N hM hN (!b)
  have hne : ¬ (u = u - step M N (!b)) := fun hc => hs (by linear_combination hc)
  have hmap : xChecks M N (b, u)
      = Finset.univ.image (fun s : Bool => (if s then u - step M N (!b) else u : Face M N)) := by
    ext f
    simp only [xChecks, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    rw [d2_ne_zero_iff M N hM hN]
    constructor
    · rintro (h | h)
      · exact ⟨false, by simp [h]⟩
      · refine ⟨true, ?_⟩
        show u - step M N (!b) = f
        rw [h]
        ring
    · rintro ⟨s, hsv⟩
      cases s
      · left; simpa using hsv
      · right
        have hsv' : u - step M N (!b) = f := hsv
        rw [← hsv']
        ring
  rw [hmap, Finset.card_image_of_injective _ ?inj, Finset.card_univ]
  · simp
  case inj =>
    intro s1 s2 h
    cases s1 <;> cases s2
    · rfl
    · exact absurd (by simpa using h) hne
    · exact absurd (by simpa using h.symm) hne
    · rfl

/-- **The toric code is a bounded-geometry (LDPC) code.**  Every check has
weight `4` and every qubit is involved in exactly `2` checks of each type,
uniformly in `M` and `N`. -/
theorem toric_bounded_local_geometry :
    (∀ v : Vert M N, (zSupport M N v).card = 4) ∧
    (∀ f : Face M N, (xSupport M N f).card = 4) ∧
    (∀ e : Edge M N, (zChecks M N e).card = 2) ∧
    (∀ e : Edge M N, (xChecks M N e).card = 2) :=
  ⟨vertex_degree_eq_four M N hM hN, face_size_eq_four M N hM hN,
    qubit_Z_degree_eq_two M N hM hN, qubit_X_degree_eq_two M N hM hN⟩

end Local

end ToricCode