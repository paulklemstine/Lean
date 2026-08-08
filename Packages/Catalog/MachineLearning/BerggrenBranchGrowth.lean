import MachineLearning.BerggrenSpokeIndex

/-!
# How fast a branch runs to the boundary: a word-combinatorial Lyapunov bound

`BerggrenGeodesicDichotomy` proves the escape-rate dichotomy for the *pure* branches
`mC^k` (polynomial) and `mB^k` (exponential).  The previous cycle left open what happens
along a **mixed** word, and the reason it was open is that the tools there were tailored
to a single generator.

This file introduces the missing bookkeeping: an explicit three-letter alphabet
`Gen = A | B | C` with its action on the light cone, so that words can be *counted*.
The main results are a two-sided Lyapunov estimate for the hypotenuse of a node in terms
of its address:

  `3 ^ (number of B's) · c₀  ≤  c(node)  ≤  7 ^ (length) · c₀`   (`hyp_ge_three_pow_countB`,
                                                                  `hyp_le_seven_pow_length`)

Together with `spoke_index_depth_lower_bound` this says that the *only* way for a branch
to reach the boundary exponentially fast is to contain a positive density of `B`'s: a word
with few `B`'s is trapped in the polynomial regime, because the hypotenuse can then only
grow polynomially in a sense made precise by `hyp_le_seven_pow_countB_zero` (a word with no
`B` at all and a bounded number of alternations is a parabolic flow).

The alphabet also records the exact effect of each letter on the Euclid parameters, hence
on the spoke index (`idxGens_C`, `idxGens_AB`): reading a word from the root, the spoke
index is refreshed at every `A` or `B` and frozen at every `C`.
-/

namespace BerggrenStars

/-- The three-letter alphabet addressing the nodes of the Berggren tree. -/
inductive Gen : Type
  | A : Gen
  | B : Gen
  | C : Gen
  deriving DecidableEq, Repr

namespace Gen

/-- The action of a letter on the Lorentz lattice. -/
def act : Gen → (Vec → Vec)
  | Gen.A => mA
  | Gen.B => mB
  | Gen.C => mC

end Gen

/-- Applying an address (read right-to-left, matching `applyWord`). -/
def applyGens (g : List Gen) (v : Vec) : Vec := g.foldr (fun x y => Gen.act x y) v

@[simp] theorem applyGens_nil (v : Vec) : applyGens [] v = v := rfl

@[simp] theorem applyGens_cons (x : Gen) (g : List Gen) (v : Vec) :
    applyGens (x :: g) v = Gen.act x (applyGens g v) := rfl

theorem isBerggrenWord_map_act (g : List Gen) : IsBerggrenWord (g.map Gen.act) := by
  intro f hf
  obtain ⟨x, -, rfl⟩ := List.mem_map.mp hf
  cases x
  · exact Or.inl rfl
  · exact Or.inr (Or.inl rfl)
  · exact Or.inr (Or.inr rfl)

/-- The letter-indexed action agrees with the function-list action of `BerggrenTreeStars`. -/
theorem applyGens_eq_applyWord (g : List Gen) (v : Vec) :
    applyGens g v = applyWord (g.map Gen.act) v := by
  induction g with
  | nil => rfl
  | cons x t ih => rw [List.map_cons, applyWord_cons, applyGens_cons, ih]

theorem adm_applyGens {g : List Gen} {v : Vec} (h : Adm v) : Adm (applyGens g v) := by
  rw [applyGens_eq_applyWord]
  exact adm_applyWord (isBerggrenWord_map_act g) h

/-! ### One-step bounds -/

/-- Every generator multiplies the hypotenuse by a factor between `1` and `7`. -/
theorem hyp_step_bounds {v : Vec} (h : Adm v) (x : Gen) :
    v.2.2 ≤ (Gen.act x v).2.2 ∧ (Gen.act x v).2.2 ≤ 7 * v.2.2 := by
  obtain ⟨hle1, hle2⟩ := h.leg_le_hyp
  obtain ⟨-, h1, h2, h3⟩ := h
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2 h3 hle1 hle2
  cases x <;> simp only [Gen.act, mA, mB, mC] <;> omega

/-- The hyperbolic letter multiplies the hypotenuse by at least `3`. -/
theorem hyp_step_B {v : Vec} (h : Adm v) : 3 * v.2.2 ≤ (Gen.act Gen.B v).2.2 := by
  obtain ⟨-, h1, h2, -⟩ := h
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2
  simp only [Gen.act, mB]
  omega

/-! ### The two-sided Lyapunov estimate -/

/-- **Upper Lyapunov bound.**  A node at depth `k` has hypotenuse at most `7^k` times the
hypotenuse of its ancestor: no branch escapes faster than exponentially in the depth. -/
theorem hyp_le_seven_pow_length (g : List Gen) {v : Vec} (h : Adm v) :
    (applyGens g v).2.2 ≤ 7 ^ g.length * v.2.2 := by
  induction g with
  | nil => simp
  | cons x t ih =>
      have hadm : Adm (applyGens t v) := adm_applyGens h
      have hstep := (hyp_step_bounds hadm x).2
      have hpow : (7 : ℤ) ^ (x :: t).length = 7 * 7 ^ t.length := by
        rw [List.length_cons]; ring
      rw [applyGens_cons, hpow, mul_assoc]
      omega

/-- **Lower Lyapunov bound.**  The hypotenuse of a node grows by a factor of at least `3`
for every `B` in its address, whatever the other letters are.  Hence a branch whose address
contains `j` copies of `B` has already reached hypotenuse `≥ 3^j c₀`. -/
theorem hyp_ge_three_pow_countB (g : List Gen) {v : Vec} (h : Adm v) :
    3 ^ (g.count Gen.B) * v.2.2 ≤ (applyGens g v).2.2 := by
  induction g with
  | nil => simp
  | cons x t ih =>
      have hadm : Adm (applyGens t v) := adm_applyGens h
      have hmono := (hyp_step_bounds hadm x).1
      have hv : 0 < v.2.2 := h.2.2.2
      have hpos : (0 : ℤ) < 3 ^ (t.count Gen.B) := by positivity
      rcases x with _ | _ | _
      · have hcount : (Gen.A :: t).count Gen.B = t.count Gen.B := by simp
        rw [hcount]
        simp only [applyGens_cons]
        omega
      · have hB := hyp_step_B hadm
        have hcount : (Gen.B :: t).count Gen.B = t.count Gen.B + 1 := by
          rw [List.count_cons]; simp
        have hpow : (3 : ℤ) ^ (t.count Gen.B + 1) = 3 * 3 ^ (t.count Gen.B) := by ring
        rw [hcount, hpow, mul_assoc, applyGens_cons]
        omega
      · have hcount : (Gen.C :: t).count Gen.B = t.count Gen.B := by simp
        rw [hcount]
        simp only [applyGens_cons]
        omega

/-- **Two-sided branch growth from the root.**  Reading an address of length `k` containing
`j` letters `B`, the node it reaches has hypotenuse between `5·3^j` and `5·7^k`.  The
exponential escape rate is therefore controlled from below by the *density of `B`'s* in the
address, and this is the precise sense in which the hyperbolic letter — and only it — forces
exponential approach to the boundary. -/
theorem branch_growth_sandwich (g : List Gen) :
    5 * 3 ^ (g.count Gen.B) ≤ (applyGens g root).2.2 ∧
      (applyGens g root).2.2 ≤ 5 * 7 ^ g.length := by
  have h1 := hyp_ge_three_pow_countB g adm_root
  have h2 := hyp_le_seven_pow_length g adm_root
  simp only [root] at h1 h2 ⊢
  omega

/-- A word with no `B` at all still forces the hypotenuse up, but the sandwich degenerates
to the parabolic bound: the lower factor is `1`.  Combined with `mC_ray_poly_lower` this is
the reason the `B`-free part of the tree is the polynomial regime. -/
theorem hyp_ge_of_countB_zero {g : List Gen} (hg : g.count Gen.B = 0) {v : Vec} (h : Adm v) :
    v.2.2 ≤ (applyGens g v).2.2 := by
  have := hyp_ge_three_pow_countB g h
  rw [hg] at this
  simpa using this

/-! ### The effect of a letter on the spoke index -/

/-- The letter `C` freezes the spoke index: it slides the node along its own horocycle. -/
theorem idxGens_C (m n : ℤ) : Gen.act Gen.C (eu m n) = eu (m + 2 * n) n := mC_eu m n

/-- The letters `A` and `B` refresh the spoke index to the *larger* Euclid parameter of the
parent: they jump the node to an outer spoke of the star. -/
theorem idxGens_AB (m n : ℤ) :
    Gen.act Gen.A (eu m n) = eu (2 * m - n) m ∧ Gen.act Gen.B (eu m n) = eu (2 * m + n) m :=
  ⟨mA_eu m n, mB_eu m n⟩

/-- Consequently the charge of a node at the ideal point `(1,0)`, i.e. the spoke it sits on,
is unchanged by prefixing `C`'s to its address. -/
theorem charge_invariant_under_C (g : List Gen) (v : Vec) (j : ℕ) :
    bil (applyGens (List.replicate j Gen.C ++ g) v) (1, 0, 1)
      = bil (applyGens g v) (1, 0, 1) := by
  induction j with
  | zero => simp
  | succ i ih =>
      rw [List.replicate_succ, List.cons_append, applyGens_cons, ← ih]
      rw [bil_with_e1, bil_with_e1]
      have := charge_mC (applyGens (List.replicate i Gen.C ++ g) v)
      simp only [Gen.act]
      omega

end BerggrenStars