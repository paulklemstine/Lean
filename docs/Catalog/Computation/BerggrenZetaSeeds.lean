import Mathlib

/-!
# The Berggren tree in Euclid-seed coordinates

This file is the combinatorial foundation for the *Berggren tree zeta function*.

The Berggren (Barning–Hall) tree of primitive Pythagorean triples is generated from the
root `(3,4,5)` by the three Barning matrices

`A₁ = [[1,-2,2],[2,-1,2],[2,-2,3]]`, `A₂ = [[1,2,2],[2,1,2],[2,2,3]]`,
`A₃ = [[-1,2,2],[-2,1,2],[-2,2,3]]`.

Under the Euclid parametrisation `(m,n) ↦ (m² − n², 2mn, m² + n²)` these three matrices become
the three **seed moves**

`s₀(m,n) = (2m − n, m)`,  `s₁(m,n) = (2m + n, m)`,  `s₂(m,n) = (m + 2n, n)`,

acting on the root seed `(2,1)`.  All the structure of the tree — the number of nodes at
depth `k`, the injectivity of the labelling by words, and the completeness of the tree —
becomes elementary arithmetic in these coordinates.

## Main results

* `berggren_step_eq_barning` : the seed moves *are* the Barning matrices (the dictionary
  between this file and the catalog's `invB1/invB2/invB3` picture).
* `IsSeed.step` : the seed invariant `0 < n < m`, `gcd m n = 1`, `m + n` odd is preserved.
* `node_injective` : the labelling `List (Fin 3) → ℕ × ℕ` of tree nodes by words is injective;
  hence the depth-`k` layer has exactly `3 ^ k` nodes (`card_layer`).
* `seed_complete` : **Barning–Hall completeness** — every Euclid seed is a node of the tree,
  so `node` is a bijection onto the set of seeds (`nodeEquiv`), i.e. the tree enumerates every
  primitive Pythagorean triple with odd first leg exactly once.
* `pt_of_seed` : the triple attached to a node really is a primitive Pythagorean triple, with
  hypotenuse `m² + n²`.
-/

namespace BerggrenZeta

/-! ## Seeds and the three moves -/

/-- The three Berggren moves in Euclid-seed coordinates. -/
def step : Fin 3 → ℕ × ℕ → ℕ × ℕ
  | 0, (m, n) => (2 * m - n, m)
  | 1, (m, n) => (2 * m + n, m)
  | 2, (m, n) => (m + 2 * n, n)

/-- The node of the Berggren tree labelled by a word in `{0,1,2}`; the head of the list is the
last move applied.  The empty word is the root seed `(2,1)`, i.e. the triple `(3,4,5)`. -/
def node : List (Fin 3) → ℕ × ℕ
  | [] => (2, 1)
  | i :: w => step i (node w)

/-- A *Euclid seed*: `0 < n < m`, coprime, of opposite parity.  These parametrise exactly the
primitive Pythagorean triples with odd first leg. -/
structure IsSeed (p : ℕ × ℕ) : Prop where
  pos : 0 < p.2
  lt : p.2 < p.1
  cop : Nat.Coprime p.1 p.2
  parity : (p.1 + p.2) % 2 = 1

/-- The Pythagorean triple attached to a seed. -/
def tri (p : ℕ × ℕ) : ℕ × ℕ × ℕ := (p.1 ^ 2 - p.2 ^ 2, 2 * p.1 * p.2, p.1 ^ 2 + p.2 ^ 2)

/-- The hypotenuse of the triple attached to a seed. -/
def hyp (p : ℕ × ℕ) : ℕ := p.1 ^ 2 + p.2 ^ 2

/-- The hypotenuse of the node labelled by a word. -/
def chyp (w : List (Fin 3)) : ℕ := hyp (node w)

@[simp] lemma node_nil : node [] = (2, 1) := rfl

@[simp] lemma node_cons (i : Fin 3) (w : List (Fin 3)) : node (i :: w) = step i (node w) := rfl

@[simp] lemma step_zero (m n : ℕ) : step 0 (m, n) = (2 * m - n, m) := rfl
@[simp] lemma step_one (m n : ℕ) : step 1 (m, n) = (2 * m + n, m) := rfl
@[simp] lemma step_two (m n : ℕ) : step 2 (m, n) = (m + 2 * n, n) := rfl

lemma chyp_def (w : List (Fin 3)) : chyp w = (node w).1 ^ 2 + (node w).2 ^ 2 := rfl

/-! ## The dictionary with the Barning matrices

For a seed `(m,n)` write `(a,b,c) = (m²−n², 2mn, m²+n²)`.  The three seed moves induce exactly
the three Barning matrices on `(a,b,c)`.  We state this over `ℤ` to avoid truncated subtraction.
-/

/-- **The seed moves are the Barning matrices.**  With `a = m²−n²`, `b = 2mn`, `c = m²+n²`
(over `ℤ`), the triples of `s₀(m,n)`, `s₁(m,n)`, `s₂(m,n)` are `A₁(a,b,c)`, `A₂(a,b,c)`,
`A₃(a,b,c)` respectively. -/
theorem berggren_step_eq_barning (m n : ℤ) :
    (((2 * m - n) ^ 2 - m ^ 2, 2 * (2 * m - n) * m, (2 * m - n) ^ 2 + m ^ 2) =
        ((m ^ 2 - n ^ 2) - 2 * (2 * m * n) + 2 * (m ^ 2 + n ^ 2),
          2 * (m ^ 2 - n ^ 2) - 2 * m * n + 2 * (m ^ 2 + n ^ 2),
          2 * (m ^ 2 - n ^ 2) - 2 * (2 * m * n) + 3 * (m ^ 2 + n ^ 2))) ∧
    (((2 * m + n) ^ 2 - m ^ 2, 2 * (2 * m + n) * m, (2 * m + n) ^ 2 + m ^ 2) =
        ((m ^ 2 - n ^ 2) + 2 * (2 * m * n) + 2 * (m ^ 2 + n ^ 2),
          2 * (m ^ 2 - n ^ 2) + 2 * m * n + 2 * (m ^ 2 + n ^ 2),
          2 * (m ^ 2 - n ^ 2) + 2 * (2 * m * n) + 3 * (m ^ 2 + n ^ 2))) ∧
    (((m + 2 * n) ^ 2 - n ^ 2, 2 * (m + 2 * n) * n, (m + 2 * n) ^ 2 + n ^ 2) =
        (-(m ^ 2 - n ^ 2) + 2 * (2 * m * n) + 2 * (m ^ 2 + n ^ 2),
          -2 * (m ^ 2 - n ^ 2) + 2 * m * n + 2 * (m ^ 2 + n ^ 2),
          -2 * (m ^ 2 - n ^ 2) + 2 * (2 * m * n) + 3 * (m ^ 2 + n ^ 2))) := by
  refine ⟨?_, ?_, ?_⟩ <;> refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp <;> ring

/-! ## The seed invariant -/

lemma isSeed_mk {m n : ℕ} (h1 : 0 < n) (h2 : n < m) (h3 : Nat.Coprime m n)
    (h4 : (m + n) % 2 = 1) : IsSeed (m, n) := ⟨h1, h2, h3, h4⟩

lemma IsSeed.step (i : Fin 3) {p : ℕ × ℕ} (hp : IsSeed p) : IsSeed (step i p) := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hpos, hlt, hcop, hpar⟩ := hp
  simp only at hpos hlt hcop hpar
  fin_cases i
  · show IsSeed (2 * m - n, m)
    refine isSeed_mk (by omega) (by omega) ?_ (by omega)
    have hd : Nat.gcd (2 * m - n) m ∣ n := by
      have h1 : Nat.gcd (2 * m - n) m ∣ 2 * m - n := Nat.gcd_dvd_left _ _
      have h2 : Nat.gcd (2 * m - n) m ∣ 2 * m := (Nat.gcd_dvd_right _ _).mul_left 2
      have h3 := Nat.dvd_sub h2 h1
      rwa [show 2 * m - (2 * m - n) = n by omega] at h3
    have hdd : Nat.gcd (2 * m - n) m ∣ Nat.gcd m n := Nat.dvd_gcd (Nat.gcd_dvd_right _ _) hd
    rw [Nat.Coprime] at hcop ⊢
    rw [hcop] at hdd
    exact Nat.eq_one_of_dvd_one hdd
  · show IsSeed (2 * m + n, m)
    refine isSeed_mk (by omega) (by omega) ?_ (by omega)
    have hd : Nat.gcd (2 * m + n) m ∣ n := by
      have h1 : Nat.gcd (2 * m + n) m ∣ 2 * m + n := Nat.gcd_dvd_left _ _
      have h2 : Nat.gcd (2 * m + n) m ∣ 2 * m := (Nat.gcd_dvd_right _ _).mul_left 2
      have h3 := Nat.dvd_sub h1 h2
      rwa [show 2 * m + n - 2 * m = n by omega] at h3
    have hdd : Nat.gcd (2 * m + n) m ∣ Nat.gcd m n := Nat.dvd_gcd (Nat.gcd_dvd_right _ _) hd
    rw [Nat.Coprime] at hcop ⊢
    rw [hcop] at hdd
    exact Nat.eq_one_of_dvd_one hdd
  · show IsSeed (m + 2 * n, n)
    refine isSeed_mk (by omega) (by omega) ?_ (by omega)
    have hd : Nat.gcd (m + 2 * n) n ∣ m := by
      have h1 : Nat.gcd (m + 2 * n) n ∣ m + 2 * n := Nat.gcd_dvd_left _ _
      have h2 : Nat.gcd (m + 2 * n) n ∣ 2 * n := (Nat.gcd_dvd_right _ _).mul_left 2
      have h3 := Nat.dvd_sub h1 h2
      rwa [show m + 2 * n - 2 * n = m by omega] at h3
    have hdd : Nat.gcd (m + 2 * n) n ∣ Nat.gcd m n := Nat.dvd_gcd hd (Nat.gcd_dvd_right _ _)
    rw [Nat.Coprime] at hcop ⊢
    rw [hcop] at hdd
    exact Nat.eq_one_of_dvd_one hdd

lemma isSeed_root : IsSeed (2, 1) := ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- Every node of the tree is a Euclid seed. -/
theorem isSeed_node (w : List (Fin 3)) : IsSeed (node w) := by
  induction w with
  | nil => exact isSeed_root
  | cons i w ih => exact ih.step i

/-! ## The triple of a node is a primitive Pythagorean triple -/

private lemma sq_mod_two (m : ℕ) : m ^ 2 % 2 = m % 2 := by
  rw [pow_two, Nat.mul_mod]
  rcases Nat.mod_two_eq_zero_or_one m with h | h <;> simp [h]

/-- The triple attached to a seed is a primitive Pythagorean triple with positive legs. -/
theorem pt_of_seed {p : ℕ × ℕ} (hp : IsSeed p) :
    0 < (tri p).1 ∧ 0 < (tri p).2.1 ∧
      (tri p).1 ^ 2 + (tri p).2.1 ^ 2 = (tri p).2.2 ^ 2 ∧
      Nat.Coprime (tri p).1 (tri p).2.1 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hpos, hlt, hcop, hpar⟩ := hp
  simp only at hpos hlt hcop hpar
  have hn2 : n ^ 2 < m ^ 2 := Nat.pow_lt_pow_left hlt (by norm_num)
  have hk : m ^ 2 - n ^ 2 + n ^ 2 = m ^ 2 := by omega
  have hoddleg : (m ^ 2 - n ^ 2) % 2 = 1 := by
    have := sq_mod_two m
    have := sq_mod_two n
    omega
  refine ⟨by simp only [tri]; omega, by simp only [tri]; exact Nat.mul_pos (by omega) hpos, ?_, ?_⟩
  · simp only [tri]
    nlinarith [hk]
  · simp only [tri]
    by_contra hcon
    obtain ⟨q, hq, hq1, hq2⟩ := Nat.Prime.not_coprime_iff_dvd.mp hcon
    have hq2' : q ≠ 2 := by rintro rfl; omega
    have hqmn : q ∣ m * n := by
      rcases (Nat.Prime.dvd_mul hq).mp (by rw [mul_assoc] at hq2; exact hq2) with h | h
      · exact absurd ((Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp h) hq2'
      · exact h
    rcases (Nat.Prime.dvd_mul hq).mp hqmn with hm | hn
    · have hqn2 : q ∣ n ^ 2 := by
        have h1 : q ∣ m ^ 2 := dvd_pow hm (by norm_num)
        have h2 := Nat.dvd_sub h1 hq1
        rwa [show m ^ 2 - (m ^ 2 - n ^ 2) = n ^ 2 by omega] at h2
      have hqn : q ∣ n := hq.dvd_of_dvd_pow hqn2
      have : q ∣ Nat.gcd m n := Nat.dvd_gcd hm hqn
      rw [hcop] at this
      exact hq.one_lt.ne' (Nat.eq_one_of_dvd_one this)
    · have hqm2 : q ∣ m ^ 2 := by
        have h1 : q ∣ n ^ 2 := dvd_pow hn (by norm_num)
        have h2 := Nat.dvd_add hq1 h1
        rwa [hk] at h2
      have hqm : q ∣ m := hq.dvd_of_dvd_pow hqm2
      have : q ∣ Nat.gcd m n := Nat.dvd_gcd hqm hn
      rw [hcop] at this
      exact hq.one_lt.ne' (Nat.eq_one_of_dvd_one this)

/-! ## Injectivity of the word labelling -/

/-- The three moves are distinguished by the *ratio* of the two seed coordinates:
`s₀` lands in `m < 2n`, `s₁` in `2n < m < 3n`, `s₂` in `3n < m`.  Consequently a node
determines the move that produced it. -/
theorem step_eq_index {i j : Fin 3} {p q : ℕ × ℕ} (hp : IsSeed p) (hq : IsSeed q)
    (h : step i p = step j q) : i = j := by
  obtain ⟨m, n⟩ := p
  obtain ⟨m', n'⟩ := q
  obtain ⟨h1, h2, -, -⟩ := hp
  obtain ⟨h3, h4, -, -⟩ := hq
  simp only at h1 h2 h3 h4
  fin_cases i <;> fin_cases j <;> simp only [step, Prod.mk.injEq] at h <;> omega

/-- Inverse of the move `i`. -/
def unstep : Fin 3 → ℕ × ℕ → ℕ × ℕ
  | 0, (m, n) => (n, 2 * n - m)
  | 1, (m, n) => (n, m - 2 * n)
  | 2, (m, n) => (m - 2 * n, n)

lemma unstep_step (i : Fin 3) {p : ℕ × ℕ} (hp : IsSeed p) : unstep i (step i p) = p := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hpos, hlt, -, -⟩ := hp
  simp only at hpos hlt
  fin_cases i <;> simp only [step, unstep, Prod.mk.injEq] <;> constructor <;>
    first | trivial | omega

/-- The first coordinate strictly increases along every move: the tree grows outwards. -/
lemma step_fst_lt (i : Fin 3) {p : ℕ × ℕ} (hp : IsSeed p) : p.1 < (step i p).1 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hpos, hlt, -, -⟩ := hp
  simp only at hpos hlt
  fin_cases i <;> simp only [step] <;> omega

lemma two_le_node_fst (w : List (Fin 3)) : 2 ≤ (node w).1 := by
  have h1 := (isSeed_node w).pos
  have h2 := (isSeed_node w).lt
  omega

/-- **The labelling of the nodes of the Berggren tree by words in three letters is
injective**: distinct words give distinct Euclid seeds (equivalently, distinct primitive
Pythagorean triples). -/
theorem node_injective : Function.Injective node := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    cases w₂ with
    | nil => rfl
    | cons j w =>
      exfalso
      have hfst := step_fst_lt j (isSeed_node w)
      have h2 := two_le_node_fst w
      have hval := congrArg Prod.fst h
      simp only [node_nil, node_cons] at hval
      omega
  | cons i w₁ ih =>
    intro w₂ h
    cases w₂ with
    | nil =>
      exfalso
      have hfst := step_fst_lt i (isSeed_node w₁)
      have h2 := two_le_node_fst w₁
      have hval := congrArg Prod.fst h
      simp only [node_nil, node_cons] at hval
      omega
    | cons j w₂ =>
      simp only [node_cons] at h
      have hs₁ := isSeed_node w₁
      have hs₂ := isSeed_node w₂
      have hij : i = j := step_eq_index hs₁ hs₂ h
      subst hij
      have hpar : node w₁ = node w₂ := by
        rw [← unstep_step i hs₁, ← unstep_step i hs₂, h]
      rw [ih hpar]

/-! ## The depth-`k` layer has `3 ^ k` nodes -/

/-- The set of nodes at depth `k`. -/
def layer (k : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.univ : Finset (Fin k → Fin 3)).image (fun f => node (List.ofFn f))

/-- **The depth-`k` layer of the Berggren tree has exactly `3 ^ k` distinct nodes.** -/
theorem card_layer (k : ℕ) : (layer k).card = 3 ^ k := by
  rw [layer, Finset.card_image_of_injective _ ?inj, Finset.card_univ]
  · simp
  · intro f g hfg
    exact List.ofFn_injective (node_injective hfg)

/-! ## Completeness: every seed is a node (Barning–Hall) -/

/-- **Barning–Hall completeness.**  Every Euclid seed occurs in the tree. -/
theorem seed_complete : ∀ p : ℕ × ℕ, IsSeed p → ∃ w : List (Fin 3), node w = p := by
  intro p
  induction hM : p.1 using Nat.strong_induction_on generalizing p with
  | _ M ih =>
    intro hp
    obtain ⟨m, n⟩ := p
    obtain ⟨hpos, hlt, hcop, hpar⟩ := hp
    simp only at hpos hlt hcop hpar hM
    subst hM
    by_cases hroot : m = 2
    · refine ⟨[], ?_⟩
      have : n = 1 := by omega
      simp [hroot, this]
    have hne2 : m ≠ 2 * n := by
      rintro rfl
      have hd : n ∣ Nat.gcd (2 * n) n := Nat.dvd_gcd ⟨2, by ring⟩ dvd_rfl
      rw [hcop] at hd
      have : n = 1 := Nat.eq_one_of_dvd_one hd
      omega
    have hne3 : m ≠ 3 * n := by
      rintro rfl
      have hd : n ∣ Nat.gcd (3 * n) n := Nat.dvd_gcd ⟨3, by ring⟩ dvd_rfl
      rw [hcop] at hd
      have hn1 : n = 1 := Nat.eq_one_of_dvd_one hd
      subst hn1
      omega
    rcases lt_trichotomy m (2 * n) with h2 | h2 | h2
    · -- came from move 0 : parent (n, 2n − m)
      have hpar' : IsSeed (n, 2 * n - m) := by
        refine isSeed_mk (by omega) (by omega) ?_ (by omega)
        have hd : Nat.gcd n (2 * n - m) ∣ m := by
          have ha : Nat.gcd n (2 * n - m) ∣ 2 * n := (Nat.gcd_dvd_left _ _).mul_left 2
          have hb : Nat.gcd n (2 * n - m) ∣ 2 * n - m := Nat.gcd_dvd_right _ _
          have hc := Nat.dvd_sub ha hb
          rwa [show 2 * n - (2 * n - m) = m by omega] at hc
        have hdd : Nat.gcd n (2 * n - m) ∣ Nat.gcd m n := Nat.dvd_gcd hd (Nat.gcd_dvd_left _ _)
        rw [hcop] at hdd
        exact Nat.eq_one_of_dvd_one hdd
      obtain ⟨w, hw⟩ := ih n (by omega) (n, 2 * n - m) rfl hpar'
      refine ⟨0 :: w, ?_⟩
      rw [node_cons, hw, step_zero]
      refine Prod.ext ?_ rfl
      simp only
      omega
    · exact absurd h2 hne2
    · rcases lt_trichotomy m (3 * n) with h3 | h3 | h3
      · -- came from move 1 : parent (n, m − 2n)
        have hpar' : IsSeed (n, m - 2 * n) := by
          refine isSeed_mk (by omega) (by omega) ?_ (by omega)
          have hd : Nat.gcd n (m - 2 * n) ∣ m := by
            have ha : Nat.gcd n (m - 2 * n) ∣ 2 * n := (Nat.gcd_dvd_left _ _).mul_left 2
            have hb : Nat.gcd n (m - 2 * n) ∣ m - 2 * n := Nat.gcd_dvd_right _ _
            have hc := Nat.dvd_add ha hb
            rwa [show 2 * n + (m - 2 * n) = m by omega] at hc
          have hdd : Nat.gcd n (m - 2 * n) ∣ Nat.gcd m n := Nat.dvd_gcd hd (Nat.gcd_dvd_left _ _)
          rw [hcop] at hdd
          exact Nat.eq_one_of_dvd_one hdd
        obtain ⟨w, hw⟩ := ih n (by omega) (n, m - 2 * n) rfl hpar'
        refine ⟨1 :: w, ?_⟩
        rw [node_cons, hw, step_one]
        refine Prod.ext ?_ rfl
        simp only
        omega
      · exact absurd h3 hne3
      · -- came from move 2 : parent (m − 2n, n)
        have hpar' : IsSeed (m - 2 * n, n) := by
          refine isSeed_mk (by omega) (by omega) ?_ (by omega)
          have hd : Nat.gcd (m - 2 * n) n ∣ m := by
            have ha : Nat.gcd (m - 2 * n) n ∣ 2 * n := (Nat.gcd_dvd_right _ _).mul_left 2
            have hb : Nat.gcd (m - 2 * n) n ∣ m - 2 * n := Nat.gcd_dvd_left _ _
            have hc := Nat.dvd_add hb ha
            rwa [show m - 2 * n + 2 * n = m by omega] at hc
          have hdd : Nat.gcd (m - 2 * n) n ∣ Nat.gcd m n := Nat.dvd_gcd hd (Nat.gcd_dvd_right _ _)
          rw [hcop] at hdd
          exact Nat.eq_one_of_dvd_one hdd
        obtain ⟨w, hw⟩ := ih (m - 2 * n) (by omega) (m - 2 * n, n) rfl hpar'
        refine ⟨2 :: w, ?_⟩
        rw [node_cons, hw, step_two]
        refine Prod.ext ?_ rfl
        simp only
        omega

/-- The word labelling is a bijection onto the set of Euclid seeds. -/
noncomputable def nodeEquiv : List (Fin 3) ≃ {p : ℕ × ℕ // IsSeed p} :=
  Equiv.ofBijective (fun w => ⟨node w, isSeed_node w⟩)
    ⟨fun _ _ h => node_injective (congrArg Subtype.val h),
      fun ⟨p, hp⟩ => by obtain ⟨w, hw⟩ := seed_complete p hp; exact ⟨w, by simp [hw]⟩⟩

@[simp] lemma nodeEquiv_apply (w : List (Fin 3)) : (nodeEquiv w : ℕ × ℕ) = node w := rfl

end BerggrenZeta